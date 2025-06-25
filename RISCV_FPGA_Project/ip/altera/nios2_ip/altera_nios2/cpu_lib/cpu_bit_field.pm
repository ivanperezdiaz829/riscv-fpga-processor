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






















package cpu_bit_field;
use Exporter;
@ISA = Exporter;
@EXPORT = qw(
    &create_bit_field
    &validate_bit_field
    &detect_bit_field_overlap
    &get_bit_field_name
    &get_bit_field_lsb
    &get_bit_field_msb
    &get_bit_field_sz
    &get_bit_field_unshifted_mask
    &get_bit_field_shifted_mask
    &get_bit_field_into_scalars
    &get_bit_field_by_name
    &get_bit_field_by_name_or_undef
    &convert_bit_field_to_c
);

use cpu_utils;
use strict;











our $MAX_SZ = 32;           # Perl limited to 32-bit integers














sub
create_bit_field
{
    my $props = shift;          # Hash reference with arguments

    validate_hash_keys("bit_field", $props, ["name","lsb","sz"]) ||
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

    if ($lsb < 0) {
        return &$error("Attempt to create bit field '$name'" .
          " with an illegal LSB offset of $lsb");
    }

    if ($sz <= 0) {
        return &$error("Attempt to create bit field '$name'" .
          " with an illegal number of bits of $sz");
    }


    my $msb = $lsb + $sz - 1;
    my $unshifted_mask = sz2mask($sz);
    my $shifted_mask = $unshifted_mask << $lsb;

    my $max_msb = $MAX_SZ - 1;
    if ($msb > $max_msb) {
        return &$error("Attempt to create bit field '$name'" .
          " with an illegal MSB offset of $msb (max is $max_msb)");
    }


    my $bit_field = {
        type            => "bit_field",
        name            => $name,
        lsb             => $lsb,
        msb             => $msb,
        sz              => $sz,
        unshifted_mask  => $unshifted_mask,
        shifted_mask    => $shifted_mask,
    };

    return $bit_field;
}




sub
validate_bit_field
{
    my $bit_field = shift;

    if (!defined($bit_field)) {
        return &$error("Bit field reference is undefined");
    }

    if ($bit_field == 0) {
        return &$error("Bit field reference is 0");
    }

    my $ref_type = ref($bit_field);
    if ($ref_type ne "HASH") {
        return &$error("Bit field reference is to a $ref_type" .
          " but must be to a HASH");
    }

    my $type = $bit_field->{type};

    if (!defined($type)) {
        return &$error("Bit field hash reference has no" .
            " \"type\" member");
    }

    if ($type ne "bit_field") {
        return 
          &$error("Bit field hash reference has incorrect type"
                  . " of \"$type\"");
    }

    return $bit_field;
}



sub
detect_bit_field_overlap
{
    my $bit_field_0 = shift;
    my $bit_field_1 = shift;

    if (!defined(validate_bit_field($bit_field_0))) {
        return undef;
    }

    if (!defined(validate_bit_field($bit_field_1))) {
        return undef;
    }

    if (($bit_field_0->{shifted_mask} & $bit_field_1->{shifted_mask}) != 0) {
        my $name_0 = get_bit_field_name($bit_field_0);
        my $lsb_0 = get_bit_field_lsb($bit_field_0);
        my $msb_0 = get_bit_field_msb($bit_field_0);
        my $name_1 = get_bit_field_name($bit_field_1);
        my $lsb_1 = get_bit_field_lsb($bit_field_1);
        my $msb_1 = get_bit_field_msb($bit_field_1);

        return
          "Bit field '$name_0' (lsb=$lsb_0, msb=$msb_0) overlaps with " .
          "bit field '$name_1' (lsb=$lsb_1, msb=$msb_1)";
    }

    return "";  # No overlap
}


sub
get_bit_field_name
{
    my $bit_field = shift;

    if (!defined(validate_bit_field($bit_field))) {
        return undef;
    }

    return $bit_field->{name};
}


sub
get_bit_field_lsb
{
    my $bit_field = shift;

    if (!defined(validate_bit_field($bit_field))) {
        return undef;
    }

    return $bit_field->{lsb};
}


sub
get_bit_field_msb
{
    my $bit_field = shift;

    if (!defined(validate_bit_field($bit_field))) {
        return undef;
    }

    return $bit_field->{msb};
}


sub
get_bit_field_sz
{
    my $bit_field = shift;

    if (!defined(validate_bit_field($bit_field))) {
        return undef;
    }

    return $bit_field->{sz};
}


sub
get_bit_field_unshifted_mask
{
    my $bit_field = shift;

    if (!defined(validate_bit_field($bit_field))) {
        return undef;
    }

    return $bit_field->{unshifted_mask};
}


sub
get_bit_field_shifted_mask
{
    my $bit_field = shift;

    if (!defined(validate_bit_field($bit_field))) {
        return undef;
    }

    return $bit_field->{shifted_mask};
}






sub
get_bit_field_into_scalars
{
    my $bit_field = shift;      # Reference to field
    my $bit_field_prefix = shift; # String added to start of bit field name

    if (!defined(validate_bit_field($bit_field))) {
        return undef;
    }

    my $bit_field_name = get_bit_field_name($bit_field);




    my $prefix = '$' . $bit_field_prefix . $bit_field_name . '_';

    my @cmds;
    push(@cmds, $prefix . 'lsb = ' . get_bit_field_lsb($bit_field));
    push(@cmds, $prefix . 'msb = ' .  get_bit_field_msb($bit_field));
    push(@cmds, $prefix . 'sz = ' .  get_bit_field_sz($bit_field));

    return \@cmds;
}



sub
get_bit_field_by_name
{
    my $bit_fields = shift;
    my $name = shift;   # lower-case name (e.g. "arithmetic")

    my $bit_field = get_bit_field_by_name_or_undef($bit_fields, $name);

    if (defined($bit_field)) {
        return $bit_field;
    }
    
    return &$error("Bit field name '$name' not found.");
}



sub
get_bit_field_by_name_or_undef
{
    my $bit_fields = shift;
    my $name = shift;   # lower-case name (e.g. "arithmetic")

    foreach my $bit_field (@$bit_fields) {
        if ($name eq get_bit_field_name($bit_field)) {
            return $bit_field;
        }
    }

    return undef;
}


sub
convert_bit_field_to_c
{
    my $bit_field = shift;
    my $c_lines = shift;        # Reference to array of lines for *.c file
    my $h_lines = shift;        # Reference to array of lines for *.h file
    my $prefix = shift;
    my $macro_var_name = shift;

    if (!defined(validate_bit_field($bit_field))) {
        return undef;
    }

    my $name = uc(get_bit_field_name($bit_field));
    my $member_name = uc($prefix . $name);

    push(@$h_lines, format_c_macro($member_name . "_LSB", 
      get_bit_field_lsb($bit_field)));
    push(@$h_lines, format_c_macro($member_name . "_MSB", 
      get_bit_field_msb($bit_field)));
    push(@$h_lines, format_c_macro($member_name . "_SZ", 
      get_bit_field_sz($bit_field)));
    push(@$h_lines, format_c_macro($member_name . "_UNSHIFTED_MASK", 
      get_bit_field_unshifted_mask($bit_field), $FMT_HEX));
    push(@$h_lines, format_c_macro($member_name . "_SHIFTED_MASK", 
      get_bit_field_shifted_mask($bit_field), $FMT_HEX));
    push(@$h_lines, format_c_macro($member_name . "_MASK", 
      "(" .  $member_name . "_UNSHIFTED_MASK)", $FMT_UNQUOTED_STR));

    push(@$h_lines, 
      sprintf("#define GET_%s(%s) \\", $member_name, $macro_var_name));
    push(@$h_lines,
      sprintf("    (((%s) >> %s) & %s)", $macro_var_name, 
        $member_name . "_LSB", $member_name . "_UNSHIFTED_MASK"));

    push(@$h_lines, sprintf(
      "#define SET_%s(%s, Val) \\", $member_name, $macro_var_name));
    push(@$h_lines, sprintf(
      "    %s = (((%s) & (~%s)) | \\",
      $macro_var_name, $macro_var_name, $member_name . "_SHIFTED_MASK"));
    push(@$h_lines, sprintf(
      "         (((Val) & %s) << %s))",
      $member_name . "_UNSHIFTED_MASK", $member_name . "_LSB"));

    return 1;   # Some defined value
}

1;
