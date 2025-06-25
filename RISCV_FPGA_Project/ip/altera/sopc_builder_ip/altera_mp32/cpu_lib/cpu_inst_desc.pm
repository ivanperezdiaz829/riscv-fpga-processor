#Copyright (C)2001-2010 Altera Corporation
#Any megafunction design, and related net list (encrypted or decrypted),
#support information, device programming or simulation file, and any other
#associated documentation or information provided by Altera or a partner
#under Altera's Megafunction Partnership Program may be used only to
#program PLD devices (but not masked PLD devices) from Altera.  Any other
#use of such megafunction design, net list, support information, device
#programming or simulation file, or any other related documentation or
#information is prohibited for any other purpose, including, but not
#limited to modification, reverse engineering, de-compiling, or use with
#any other silicon devices, unless such use is explicitly licensed under
#a separate agreement with Altera or a megafunction partner.  Title to
#the intellectual property, including patents, copyrights, trademarks,
#trade secrets, or maskworks, embodied in any such megafunction design,
#net list, support information, device programming or simulation file, or
#any other related documentation or information provided by Altera or a
#megafunction partner, remains with Altera, the megafunction partner, or
#their respective licensors.  No other licenses, including any licenses
#needed under any third party's intellectual property, are provided herein.
#Copying or modifying any file, or portion thereof, to which this notice
#is attached violates this copyright.






















package cpu_inst_desc;
use Exporter;
@ISA = Exporter;
@EXPORT = qw(
    &get_all_inst_desc_modes
    &create_inst_desc
    &validate_inst_desc
    &get_inst_desc_names
    &get_inst_desc_names_by_modes
    &get_inst_descs_by_modes
    &get_inst_desc_max_name_length
    &get_inst_desc_by_name
    &get_inst_desc_by_name_or_undef
    &get_inst_desc_name
    &get_inst_desc_code
    &get_inst_desc_mode
    &get_inst_desc_v_decode_func
    &get_inst_desc_c_decode_func
    &get_inst_desc_decode_arg
    &get_inst_desc_inst_type
    &get_inst_desc_inst_table
    &get_inst_desc_c_mask
    &get_inst_desc_c_match

    $INST_DESC_NORMAL_MODE
    $INST_DESC_RESERVED_MODE
    $INST_DESC_UNIMP_TRAP_MODE
    $INST_DESC_UNIMP_NOP_MODE
);

use cpu_utils;
use strict;












our $INST_DESC_NORMAL_MODE = 1;         # Instruction executes as normal
our $INST_DESC_RESERVED_MODE = 2;       # Reserved OP code
our $INST_DESC_UNIMP_TRAP_MODE = 3;     # Unimplemented instruction that traps
our $INST_DESC_UNIMP_NOP_MODE = 4;      # Unimplemented instruction that NOPs






sub
get_all_inst_desc_modes
{
    return [
        $INST_DESC_NORMAL_MODE,
        $INST_DESC_RESERVED_MODE,
        $INST_DESC_UNIMP_TRAP_MODE,
        $INST_DESC_UNIMP_NOP_MODE,
    ];
}
































sub
create_inst_desc
{
    my $props = shift;          # Hash reference with arguments

    validate_hash_keys("inst_desc", $props, 
      ["name","code","mode","v_decode_func","c_decode_func","decode_arg",
       "inst_type","inst_table","c_mask","c_match", "prefix"]) || return undef;

    my $name = not_empty_scalar($props, "name");
    if (!defined($name)) {
        return undef;
    }

    my $code = manditory_int($props, "code");
    if (!defined($code)) {
        return undef;
    }

    my $v_decode_func = manditory_code($props, "v_decode_func");
    if (!defined($v_decode_func)) {
        return undef;
    }
    my $c_decode_func = manditory_code($props, "c_decode_func");
    if (!defined($c_decode_func)) {
        return undef;
    }

    my $decode_arg = optional($props, "decode_arg");
    my $prefix = optional($props, "prefix");

    my $err = 0;
    my $inst_type = optional_scalar($props, "inst_type", \$err);
    if ($err) {
        return undef;
    }

    my $err = 0;
    my $inst_table = optional_hash($props, "inst_table", \$err);
    if ($err) {
        return undef;
    }

    my $mode = optional_scalar($props, "mode");
    if (!defined($mode)) {
        $mode = $INST_DESC_NORMAL_MODE;
    }

    if (
      ($mode != $INST_DESC_NORMAL_MODE) &&
      ($mode != $INST_DESC_RESERVED_MODE) &&
      ($mode != $INST_DESC_UNIMP_TRAP_MODE) &&
      ($mode != $INST_DESC_UNIMP_NOP_MODE)) {
        return &$error("Instruction description name '$name' has an unknown" .
          " mode of '$mode'");
    }

    my $c_mask;
    if (defined(optional($props, "c_mask"))) {
        $c_mask = optional_int($props, "c_mask");
        if (!defined($c_mask)) {
            return undef;
        }
    } 

    my $c_match;
    if (defined(optional($props, "c_match"))) {
        $c_match = optional_int($props, "c_match");
        if (!defined($c_match)) {
            return undef;
        }
    } 


    my $inst_desc = {
        type            => "inst_desc",
        name            => $name,
        code            => $code,
        mode            => $mode,
        v_decode_func   => $v_decode_func,
        c_decode_func   => $c_decode_func,
        decode_arg      => $decode_arg,
        inst_type       => $inst_type,
        inst_table      => $inst_table,
        c_mask          => $c_mask,
        c_match         => $c_match,
        prefix          => $prefix,
    };

    return $inst_desc;
}




sub
validate_inst_desc
{
    my $inst_desc = shift;

    if (!defined($inst_desc)) {
        return &$error("Instruction description reference is undefined");
    }

    if ($inst_desc == 0) {
        return &$error("Instruction description reference is 0");
    }

    my $ref_type = ref($inst_desc);
    if ($ref_type ne "HASH") {
        return &$error("Instruction description reference is to a $ref_type" .
          " but must be to a HASH");
    }

    my $type = $inst_desc->{type};

    if (!defined($type)) {
        return &$error("Instruction description hash reference has" .
          " no \"type\" member");
    }

    if ($type ne "inst_desc") {
        return &$error("Instruction description hash reference has" .
          " incorrect type of \"$type\"");
    }

    return $inst_desc;
}



sub
get_inst_desc_names
{
    my $inst_descs = shift;

    my @names;

    foreach my $inst_desc (@$inst_descs) {
        push(@names, $inst_desc->{name});
    }

    my @sorted_names = sort(@names);

    return \@sorted_names;
}



sub
get_inst_desc_names_by_modes
{
    my $inst_descs = shift;
    my $allowed_modes = shift;

    my @names;

    foreach my $inst_desc (@$inst_descs) {
        my $mode = get_inst_desc_mode($inst_desc);

        foreach my $allowed_mode (@$allowed_modes) {
            if ($mode == $allowed_mode) {
                push(@names, $inst_desc->{name});
                last;
            }
        }
    }

    my @sorted_names = sort(@names);

    return \@sorted_names;
}



sub
get_inst_descs_by_modes
{
    my $inst_descs = shift;
    my $allowed_modes = shift;

    my @matching_inst_descs;

    foreach my $inst_desc (@$inst_descs) {
        my $mode = get_inst_desc_mode($inst_desc);

        foreach my $allowed_mode (@$allowed_modes) {
            if ($mode == $allowed_mode) {
                push(@matching_inst_descs, $inst_desc);
                last;
            }
        }
    }

    return \@matching_inst_descs;
}


sub
get_inst_desc_max_name_length
{
    my $inst_descs = shift;

    my $max_name_length = 0;
    foreach my $inst_desc (@$inst_descs) {
        if (length($inst_desc->{name}) > $max_name_length) {
            $max_name_length = length($inst_desc->{name});
        }
    }

    return $max_name_length;
}



sub
get_inst_desc_by_name
{
    my $inst_descs = shift;
    my $name = shift;   # lower-case name (e.g. "arithmetic")

    my $inst_desc = get_inst_desc_by_name_or_undef($inst_descs, $name);

    if (defined($inst_desc)) {
        return $inst_desc;
    }
    
    return &$error("Instruction description name '$name' not found.");
}



sub
get_inst_desc_by_name_or_undef
{
    my $inst_descs = shift;
    my $name = shift;   # lower-case name (e.g. "arithmetic")

    foreach my $inst_desc (@$inst_descs) {
        if ($name eq $inst_desc->{name}) {
            return $inst_desc;
        }
    }

    return undef;
}


sub
get_inst_desc_name
{
    my $inst_desc = shift;

    if (!defined(validate_inst_desc($inst_desc))) {
        return undef;
    }

    return $inst_desc->{name};
}


sub
get_inst_desc_code
{
    my $inst_desc = shift;

    if (!defined(validate_inst_desc($inst_desc))) {
        return undef;
    }

    return $inst_desc->{code};
}


sub
get_inst_desc_mode
{
    my $inst_desc = shift;

    if (!defined(validate_inst_desc($inst_desc))) {
        return undef;
    }

    return $inst_desc->{mode};
}


sub
get_inst_desc_v_decode_func
{
    my $inst_desc = shift;

    if (!defined(validate_inst_desc($inst_desc))) {
        return undef;
    }

    return $inst_desc->{v_decode_func};
}


sub
get_inst_desc_c_decode_func
{
    my $inst_desc = shift;

    if (!defined(validate_inst_desc($inst_desc))) {
        return undef;
    }

    return $inst_desc->{c_decode_func};
}


sub
get_inst_desc_decode_arg
{
    my $inst_desc = shift;

    if (!defined(validate_inst_desc($inst_desc))) {
        return undef;
    }

    return $inst_desc->{decode_arg};
}


sub
get_inst_desc_inst_type
{
    my $inst_desc = shift;

    if (!defined(validate_inst_desc($inst_desc))) {
        return undef;
    }

    return $inst_desc->{inst_type};
}


sub
get_inst_desc_inst_table
{
    my $inst_desc = shift;

    if (!defined(validate_inst_desc($inst_desc))) {
        return undef;
    }

    return $inst_desc->{inst_table};
}


sub
get_inst_desc_c_mask
{
    my $inst_desc = shift;

    if (!defined(validate_inst_desc($inst_desc))) {
        return undef;
    }

    return $inst_desc->{c_mask};
}


sub
get_inst_desc_c_match
{
    my $inst_desc = shift;

    if (!defined(validate_inst_desc($inst_desc))) {
        return undef;
    }

    return $inst_desc->{c_match};
}


sub
get_inst_desc_prefix_func
{
    my $inst_desc = shift;

    if (!defined(validate_inst_desc($inst_desc))) {
        return undef;
    }

    return $inst_desc->{prefix};
}

1;
