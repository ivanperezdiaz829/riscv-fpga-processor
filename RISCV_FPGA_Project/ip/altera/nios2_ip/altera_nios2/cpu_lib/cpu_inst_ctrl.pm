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






















package cpu_inst_ctrl;
use Exporter;
@ISA = Exporter;
@EXPORT = qw(
    &create_inst_ctrl
    &validate_inst_ctrl
    &get_inst_ctrl_names
    &get_inst_ctrl_by_name
    &get_inst_ctrl_by_name_or_undef
    &get_inst_ctrl_name
    &get_inst_ctrl_allowed_modes
    &get_inst_ctrl_insts
    &get_inst_ctrl_ctrls
    &get_inst_ctrl_v_expr_func
    &get_inst_ctrl_c_expr_func
);

use cpu_utils;
use strict;



























sub
create_inst_ctrl
{
    my $props = shift;          # Hash reference with arguments

    validate_hash_keys("inst_ctrl", $props, 
      ["name","allowed_modes","insts","ctrls","v_expr_func","c_expr_func"]) ||
      return undef;

    my $name = not_empty_scalar($props, "name");
    my $allowed_modes = manditory_array($props, "allowed_modes");

    my $err = 0;
    my $insts = optional_array($props, "insts", \$err);
    my $ctrls = optional_array($props, "ctrls", \$err);
    my $v_expr_func = optional_code($props, "v_expr_func", \$err);
    my $c_expr_func = optional_code($props, "c_expr_func", \$err);

    if (!defined($name) || !defined($allowed_modes) || $err) {
        return undef;
    }
    if (!defined($insts)) {
        $insts = [];
    }
    if (!defined($ctrls)) {
        $ctrls = [];
    }


    my $inst_ctrl = {
        type            => "inst_ctrl",
        name            => $name,
        allowed_modes   => $allowed_modes,
        insts           => $insts,
        ctrls           => $ctrls,
        v_expr_func     => $v_expr_func,
        c_expr_func     => $c_expr_func,
    };

    return $inst_ctrl;
}




sub
validate_inst_ctrl
{
    my $inst_ctrl = shift;

    if (!defined($inst_ctrl)) {
        return &$error("Instruction control reference is undefined");
    }

    if ($inst_ctrl == 0) {
        return &$error("Instruction control reference is 0");
    }

    my $ref_type = ref($inst_ctrl);
    if ($ref_type ne "HASH") {
        return &$error("Instruction control reference is to a $ref_type" .
          " but must be to a HASH");
    }

    my $type = $inst_ctrl->{type};

    if (!defined($type)) {
        return &$error("Instruction control hash reference has" .
          " no \"type\" member");
    }

    if ($type ne "inst_ctrl") {
        return &$error("Instruction control hash reference has incorrect type"
          . " of \"$type\"");
    }

    return $inst_ctrl;
}


sub
get_inst_ctrl_names
{
    my $inst_ctrls = shift;

    my @names;

    foreach my $inst_ctrl (@$inst_ctrls) {
        push(@names, $inst_ctrl->{name});
    }

    my @sorted_names = sort(@names);

    return \@sorted_names;
}



sub
get_inst_ctrl_by_name
{
    my $inst_ctrls = shift;
    my $name = shift;   # lower-case name (e.g. "arithmetic")

    my $inst_ctrl = get_inst_ctrl_by_name_or_undef($inst_ctrls, $name);

    if (defined($inst_ctrl)) {
        return $inst_ctrl;
    }
    
    return &$error("Instruction control name '$name' not found.");
}



sub
get_inst_ctrl_by_name_or_undef
{
    my $inst_ctrls = shift;
    my $name = shift;   # lower-case name (e.g. "arithmetic")

    foreach my $inst_ctrl (@$inst_ctrls) {
        if ($name eq $inst_ctrl->{name}) {
            return $inst_ctrl;
        }
    }

    return undef;
}


sub
get_inst_ctrl_name
{
    my $inst_ctrl = shift;

    if (!defined(validate_inst_ctrl($inst_ctrl))) {
        return undef;
    }

    return $inst_ctrl->{name};
}


sub
get_inst_ctrl_allowed_modes
{
    my $inst_ctrl = shift;

    if (!defined(validate_inst_ctrl($inst_ctrl))) {
        return undef;
    }

    return $inst_ctrl->{allowed_modes};
}


sub
get_inst_ctrl_insts
{
    my $inst_ctrl = shift;

    if (!defined(validate_inst_ctrl($inst_ctrl))) {
        return undef;
    }

    return $inst_ctrl->{insts};
}


sub
get_inst_ctrl_ctrls
{
    my $inst_ctrl = shift;

    if (!defined(validate_inst_ctrl($inst_ctrl))) {
        return undef;
    }

    return $inst_ctrl->{ctrls};
}


sub
get_inst_ctrl_v_expr_func
{
    my $inst_ctrl = shift;

    if (!defined(validate_inst_ctrl($inst_ctrl))) {
        return undef;
    }

    return $inst_ctrl->{v_expr_func};
}


sub
get_inst_ctrl_c_expr_func
{
    my $inst_ctrl = shift;

    if (!defined(validate_inst_ctrl($inst_ctrl))) {
        return undef;
    }

    return $inst_ctrl->{c_expr_func};
}

1;
