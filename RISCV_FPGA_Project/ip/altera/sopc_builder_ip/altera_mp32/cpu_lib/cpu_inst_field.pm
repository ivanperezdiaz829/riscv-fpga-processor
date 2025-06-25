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






















package cpu_inst_field;
use Exporter;
@ISA = Exporter;
@EXPORT = qw(
    &create_inst_field
    &validate_inst_field
    &get_inst_field_names
    &get_inst_field_into_scalars
    &get_inst_field_by_name
    &get_inst_field_by_name_or_undef
    &get_inst_field_name
    &get_inst_field_lsb
    &get_inst_field_msb
    &get_inst_field_sz
    &get_inst_field_unshifted_mask
    &get_inst_field_shifted_mask
    &convert_inst_field_to_c
);

use cpu_utils;
use cpu_bit_field;
use strict;




















sub
create_inst_field
{
    my $props = shift;          # Hash reference with arguments

    validate_hash_keys("inst_field", $props, ["name","lsb","sz"]) ||
      return undef;

    my $name = not_empty_scalar($props, "name");
    if (!defined($name)) {
        return undef;
    }
    my $lsb = manditory_int($props, "lsb");
    if (!defined($lsb)) {
        return undef;
    }
    my $sz = manditory_int($props, "sz");
    if (!defined($sz)) {
        return undef;
    }

    my $bit_field = create_bit_field({
        name    => $name,
        lsb     => $lsb,
        sz      => $sz
    });

    if (!defined($bit_field)) {
        return undef;
    }


    my $field = {
        type            => "inst_field",
        bit_field       => $bit_field,
    };

    return $field;
}




sub
validate_inst_field
{
    my $inst_field = shift;

    if (!defined($inst_field)) {
        return &$error("Instruction field reference is undefined");
    }

    if ($inst_field == 0) {
        return &$error("Instruction field reference is 0");
    }

    my $ref_type = ref($inst_field);
    if ($ref_type ne "HASH") {
        return &$error("Instruction field reference is to a $ref_type" .
          " but must be to a HASH");
    }

    my $type = $inst_field->{type};

    if (!defined($type)) {
        return &$error("Instruction field hash reference has" .
          " no \"type\" member");
    }

    if ($type ne "inst_field") {
        return &$error("Instruction field hash reference has" .
          " incorrect type of \"$type\"");
    }

    return $inst_field;
}



sub
get_inst_field_names
{
    my $inst_fields = shift;

    my @names;

    foreach my $inst_field (@$inst_fields) {
        push(@names, get_inst_field_name($inst_field));
    }

    my @sorted_names = sort(@names);

    return \@sorted_names;
}






sub
get_inst_field_into_scalars
{
    my $field = shift;    # Reference to field

    if (!defined(validate_inst_field($field))) {
        return undef;
    }



    my $prefix = "iw_";

    return get_bit_field_into_scalars($field->{bit_field}, $prefix);
}



sub
get_inst_field_by_name
{
    my $inst_fields = shift;
    my $name = shift;   # lower-case name (e.g. "op")

    my $inst_field = get_inst_field_by_name_or_undef($inst_fields, $name);

    if (defined($inst_field)) {
        return $inst_field;
    }
    
    return &$error("Instruction field name '$name' not found.");
}



sub
get_inst_field_by_name_or_undef
{
    my $inst_fields = shift;
    my $name = shift;   # lower-case name (e.g. "op")

    foreach my $inst_field (@$inst_fields) {
        if ($name eq get_inst_field_name($inst_field)) {
            return $inst_field;
        }
    }

    return undef;
}


sub
get_inst_field_name
{
    my $field = shift;

    if (!defined(validate_inst_field($field))) {
        return undef;
    }

    return get_bit_field_name($field->{bit_field});
}


sub
get_inst_field_lsb
{
    my $field = shift;

    if (!defined(validate_inst_field($field))) {
        return undef;
    }

    return get_bit_field_lsb($field->{bit_field});
}


sub
get_inst_field_msb
{
    my $field = shift;

    if (!defined(validate_inst_field($field))) {
        return undef;
    }

    return get_bit_field_msb($field->{bit_field});
}


sub
get_inst_field_sz
{
    my $field = shift;

    if (!defined(validate_inst_field($field))) {
        return undef;
    }

    return get_bit_field_sz($field->{bit_field});
}


sub
get_inst_field_unshifted_mask
{
    my $field = shift;

    if (!defined(validate_inst_field($field))) {
        return undef;
    }

    return get_bit_field_unshifted_mask($field->{bit_field});
}


sub
get_inst_field_shifted_mask
{
    my $field = shift;

    if (!defined(validate_inst_field($field))) {
        return undef;
    }

    return get_bit_field_shifted_mask($field->{bit_field});
}


sub
convert_inst_field_to_c
{
    my $field = shift;
    my $c_lines = shift;        # Reference to array of lines for *.c file
    my $h_lines = shift;        # Reference to array of lines for *.h file
    my $prefix = shift;         # Optional prefix

    if (!defined(validate_inst_field($field))) {
        return undef;
    }

    return convert_bit_field_to_c($field->{bit_field}, $c_lines, $h_lines,
      $prefix . "IW_", "Iw");
}

1;
