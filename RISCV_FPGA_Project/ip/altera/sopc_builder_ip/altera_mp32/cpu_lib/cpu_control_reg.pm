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






















package cpu_control_reg;
use Exporter;
@ISA = Exporter;
@EXPORT = qw(
    &create_control_reg
    &validate_control_reg
    &get_control_reg_names
    &get_control_regs_sorted
    &get_control_reg_max_num
    &get_control_reg_num_decode_sz
    &get_control_reg_max_select
    &get_control_reg_select_decode_sz
    &get_control_reg_into_scalars
    &get_control_reg_by_name
    &get_control_reg_by_name_or_undef
    &get_control_reg_by_num
    &get_control_reg_by_num_or_undef
    &get_control_reg_name
    &get_control_reg_num
    &get_control_reg_select
    &get_control_reg_hide
    &get_control_reg_fields
    &get_control_reg_has_writeable_fields
    &get_control_reg_has_readable_fields
    &get_control_reg_lsb
    &get_control_reg_msb
    &get_control_reg_sz
    &get_control_reg_unshifted_mask
    &get_control_reg_shifted_mask
    &convert_control_reg_to_c

    &add_control_reg_field
    &add_control_reg_reserved_fields
    &validate_control_reg_field
    &get_control_reg_field
    &get_control_reg_field_control_reg
    &get_control_reg_field_names
    &get_control_reg_field_into_scalars
    &get_control_reg_field_name
    &get_control_reg_field_lsb
    &get_control_reg_field_msb
    &get_control_reg_field_sz
    &get_control_reg_field_unshifted_mask
    &get_control_reg_field_shifted_mask
    &get_control_reg_field_reset_value
    &get_control_reg_field_constant_value
    &get_control_reg_field_mode
    &is_control_reg_field_readable
    &is_control_reg_field_writeable
    &convert_control_reg_field_to_c

    $CONTROL_REG_SZ
    $MODE_READ_WRITE
    $MODE_WRITE_ONLY
    $MODE_READ_ONLY
    $MODE_IGNORED
    $MODE_CONSTANT
    $MODE_RESERVED
);

use cpu_utils;
use cpu_bit_field;
use strict;












our $CONTROL_REG_SZ = 32;


our $MODE_READ_WRITE = 0;   # WRCTL writes field, RDCTL returns field
our $MODE_READ_ONLY = 1;    # WRCTL value must be 0, RDCTL returns field
our $MODE_WRITE_ONLY = 2;   # WRCTL writes field, RDCTL returns zero
our $MODE_IGNORED = 3;      # WRCTL value ignored, RDCTL returns zero
our $MODE_CONSTANT = 4;     # WRCTL value must be 0, RDCTL returns constant
our $MODE_RESERVED = 5;     # WRCTL value must be 0, RDCTL returns zero

our $max_allowed_msb = $CONTROL_REG_SZ - 1;      # Highest MSB index




















sub
create_control_reg
{
    my $props = shift;          # Hash reference with arguments

    validate_hash_keys("control_reg", $props, ["name","num","select","hide"])
      || return undef;

    my $name = not_empty_scalar($props, "name");
    if (!defined($name)) {
        return undef;
    }
    my $num = manditory_int($props, "num");
    if (!defined($num)) {
        return undef;
    }
    my $select = optional($props, "select");
    my $hide = optional_bool($props, "hide");


    my $control_reg = {
        type        => "control_reg",
        name        => $name,
        num         => $num,
        select      => $select,
        hide        => $hide,
        fields      => [],      # Anonymous array of fields (empty for now)
    };

    return $control_reg;
}




sub
validate_control_reg
{
    my $control_reg = shift;

    if (!defined($control_reg)) {
        return &$error("Control register reference is undefined");
    }

    if ($control_reg == 0) {
        return &$error("Control register reference is 0");
    }

    my $ref_type = ref($control_reg);
    if ($ref_type ne "HASH") {
        return &$error("Control register reference is to a $ref_type" .
          " but must be to a HASH");
    }

    my $type = $control_reg->{type};

    if (!defined($type)) {
        return &$error("Control register hash reference has" .
          " no \"type\" member");
    }

    if ($type ne "control_reg") {
        return &$error("Control register hash reference has incorrect type"
          . " of \"$type\"");
    }

    return $control_reg;
}


sub
get_control_reg_names
{
    my $control_regs = shift;   # Reference to array of control registers.

    my @names;

    foreach my $control_reg (@$control_regs) {
        push(@names, $control_reg->{name});
    }

    my @sorted_names = sort(@names);

    return \@sorted_names;
}



sub
get_control_regs_sorted
{
    my $control_regs = shift;   # Reference to array of control registers.

    my @sorted_control_regs = 
      sort { control_reg_compare($a, $b) } @$control_regs;

    return \@sorted_control_regs;
}



sub
get_control_reg_max_num
{
    my $control_regs = shift;   # Reference to array of control registers.

    my $max_num = -1;

    foreach my $control_reg (@$control_regs) {
        my $num = get_control_reg_num($control_reg);
        
        if ($num > $max_num) {
            $max_num = $num;
        }
    }

    if ($max_num == -1) {
        return &$error("No control registers exist.");
    }

    return $max_num;
}



sub
get_control_reg_num_decode_sz
{
    my $control_regs = shift;   # Reference to array of control registers.

    return num2sz(get_control_reg_max_num($control_regs));
}



sub
get_control_reg_max_select
{
    my $control_regs = shift;   # Reference to array of control registers.

    my $max_select;

    foreach my $control_reg (@$control_regs) {
        my $select = get_control_reg_select($control_reg);
        if (!defined($select)) {
            next;
        }
        
        if (!defined($max_select) || ($select > $max_select)) {
            $max_select = $select;
        }
    }

    return $max_select;
}



sub
get_control_reg_select_decode_sz
{
    my $control_regs = shift;   # Reference to array of control registers.

    my $max_select = get_control_reg_max_select($control_regs);

    if (!defined($max_select)) {
        return 0;
    }

    return num2sz($max_select);
}







sub
get_control_reg_into_scalars
{
    my $control_regs = shift;
    my $control_reg = shift;

    if (!defined(validate_control_reg($control_reg))) {
        return undef;
    }

    my $name = get_control_reg_name($control_reg);
    my $num = get_control_reg_num($control_reg);
    my $select = get_control_reg_select($control_reg);

    my $num_decode_sz = get_control_reg_num_decode_sz($control_regs);
    if (!defined($num_decode_sz)) {
        return undef;
    }

    my $select_decode_sz = get_control_reg_select_decode_sz($control_regs);

    my @cmds;

    my $prefix = '$' . $name . '_reg_';

    push(@cmds, $prefix . 'regnum = "' . $num_decode_sz . q('d) . $num . q("));

    my $select = get_control_reg_select($control_reg);
    if (defined($select)) {
        if (!defined($select_decode_sz)) {
            return &$error("Register $num has a select field of $select" .
              " but select_decode_sz is undefined");
        }
        push(@cmds, 
          $prefix . 'select = "' . $select_decode_sz . q('d) .
          $select . q("));
    }

    my $lsb = get_control_reg_lsb($control_reg);
    if (defined($lsb)) {
        push(@cmds, $prefix . 'lsb = ' . $lsb);
    }

    my $msb = get_control_reg_msb($control_reg);
    if (defined($msb)) {
        push(@cmds, $prefix . 'msb = ' . $msb);
    }

    my $sz = get_control_reg_sz($control_reg);
    if ($sz > 0) {
        push(@cmds, $prefix . 'sz = ' . $sz);
    }

    return \@cmds;
}



sub
get_control_reg_by_name
{
    my $control_regs = shift;   # Reference to array of control registers.
    my $name = shift;   # lower-case name (e.g. "status")

    my $control_reg = get_control_reg_by_name_or_undef($control_regs, $name);

    if (defined($control_reg)) {
        return $control_reg;
    }
    
    return &$error("Control register name $name not found.");
}



sub
get_control_reg_by_name_or_undef
{
    my $control_regs = shift;   # Reference to array of control registers.

    my $name = shift;   # lower-case name (e.g. "status")

    foreach my $control_reg (@$control_regs) {
        if ($name eq $control_reg->{name}) {
            return $control_reg;
        }
    }

    return undef;
}




sub
get_control_reg_by_num
{
    my $control_regs = shift;   # Reference to array of control registers.
    my $num = shift;            # Register number encoding
    my $select = shift;         # Manditory if $num has $select

    my $control_reg = get_control_reg_by_num_or_undef($control_regs, $num,
      $select);

    if (defined($control_reg)) {
        return $control_reg;
    }

    return &$error("Control register number $num not found.");
}




sub
get_control_reg_by_num_or_undef
{
    my $control_regs = shift;   # Reference to array of control registers.
    my $num = shift;            # Register number encoding
    my $select = shift;         # Manditory if $num has $select

    assert_scalar($num) || return undef;
    if (defined($select)) {
        assert_scalar($select) || return undef;
    }

    foreach my $control_reg (@$control_regs) {
        if ($num == get_control_reg_num($control_reg)) {
            if (defined(get_control_reg_select($control_reg))) {
                if (!defined($select)) {
                    return &$error("Control register '" .
                      get_control_reg_name($control_reg) . "' with" .
                      " number '$num' requires" .
                      " a select to be specified for uniqueness");
                }

                if ($select == get_control_reg_select($control_reg)) {
                    return $control_reg;
                }
            } else {
                if (defined($select)) {
                    return &$error("Control register '" .
                      get_control_reg_name($control_reg) . "' with" .
                      " number '$num' doesn't" .
                      " have a select but one is provided");
                }

                return $control_reg;
            }
        }
    }

    return undef;
}


sub
get_control_reg_name
{
    my $control_reg = shift;

    if (!defined(validate_control_reg($control_reg))) {
        return undef;
    }

    return $control_reg->{name};
}


sub
get_control_reg_num
{
    my $control_reg = shift;

    if (!defined(validate_control_reg($control_reg))) {
        return undef;
    }

    return $control_reg->{num};
}


sub
get_control_reg_select
{
    my $control_reg = shift;

    if (!defined(validate_control_reg($control_reg))) {
        return undef;
    }

    return $control_reg->{select};
}


sub
get_control_reg_hide
{
    my $control_reg = shift;

    if (!defined(validate_control_reg($control_reg))) {
        return undef;
    }

    return $control_reg->{hide};
}


sub
get_control_reg_fields
{
    my $control_reg = shift;

    if (!defined(validate_control_reg($control_reg))) {
        return undef;
    }

    return $control_reg->{fields};
}


sub
get_control_reg_has_writeable_fields
{
    my $control_reg = shift;

    if (!defined(validate_control_reg($control_reg))) {
        return undef;
    }

    my $at_least_one_writeable_field = 0;
    foreach my $field (@{$control_reg->{fields}}) {
        if (is_control_reg_field_writeable($field)) {
            $at_least_one_writeable_field = 1;
        }
    }

    return $at_least_one_writeable_field;
}


sub
get_control_reg_has_readable_fields
{
    my $control_reg = shift;

    if (!defined(validate_control_reg($control_reg))) {
        return undef;
    }

    my $at_least_one_readable_field = 0;
    foreach my $field (@{$control_reg->{fields}}) {
        if (is_control_reg_field_readable($field)) {
            $at_least_one_readable_field = 1;
        }
    }

    return $at_least_one_readable_field;
}



sub
get_control_reg_lsb
{
    my $control_reg = shift;

    if (!defined(validate_control_reg($control_reg))) {
        return undef;
    }

    my $min_lsb = $CONTROL_REG_SZ;

    foreach my $field (@{$control_reg->{fields}}) {
        my $mode = get_control_reg_field_mode($field);
        if ($mode == $MODE_RESERVED || $mode == $MODE_IGNORED) {
            next;
        }

        my $lsb = get_control_reg_field_lsb($field);

        if ($lsb < $min_lsb) {
            $min_lsb = $lsb;
        }
    }

    if ($min_lsb == $CONTROL_REG_SZ) {
        return undef;
    }

    return $min_lsb;
}


sub
get_control_reg_msb
{
    my $control_reg = shift;

    if (!defined(validate_control_reg($control_reg))) {
        return undef;
    }

    my $max_msb = -1;

    foreach my $field (@{$control_reg->{fields}}) {
        my $mode = get_control_reg_field_mode($field);
        if ($mode == $MODE_RESERVED || $mode == $MODE_IGNORED) {
            next;
        }

        my $msb = get_control_reg_field_msb($field);

        if ($msb > $max_msb) {
            $max_msb = $msb;
        }
    }

    if ($max_msb == -1) {
        return undef;
    }

    return $max_msb;
}



sub
get_control_reg_sz
{
    my $control_reg = shift;

    if (!defined(validate_control_reg($control_reg))) {
        return undef;
    }

    my $msb = get_control_reg_msb($control_reg);
    my $lsb = get_control_reg_lsb($control_reg);

    if (!defined($msb) || !defined($lsb)) {
        return 0;
    }

    my $sz = $msb - $lsb + 1;

    if (($sz < 1) || ($sz > $CONTROL_REG_SZ)) {
        return &$error("Control register " . 
          get_control_reg_name($control_reg) .
          " has an illegal size of $sz bits");
    }

    return $sz;
}



sub
get_control_reg_unshifted_mask
{
    my $control_reg = shift;

    if (!defined(validate_control_reg($control_reg))) {
        return undef;
    }

    my $sz = get_control_reg_sz($control_reg);

    if ($sz == 0) {
        return undef;
    }

    return sz2mask($sz);
}



sub
get_control_reg_shifted_mask
{
    my $control_reg = shift;

    if (!defined(validate_control_reg($control_reg))) {
        return undef;
    }

    my $sz = get_control_reg_sz($control_reg);

    if ($sz == 0) {
        return undef;
    }

    my $lsb = get_control_reg_lsb($control_reg);

    return sz2mask($sz) << $lsb;
}


sub
convert_control_reg_to_c
{
    my $control_reg = shift;
    my $c_lines = shift;        # Reference to array of lines for *.c file
    my $h_lines = shift;        # Reference to array of lines for *.h file
    my $prefix = shift;         # Optional prefix

    if (!defined(validate_control_reg($control_reg))) {
        return undef;
    }

    my $name = uc(get_control_reg_name($control_reg));

    push(@$h_lines, "");
    push(@$h_lines, "/* $name register */");


    if (!defined(add_control_reg_reserved_fields($control_reg))) {
        return &$error("Can't add reserved fields for control reg $name\n");
    }


    push(@$h_lines, format_c_macro($prefix . $name . "_REG_REGNUM", 
      get_control_reg_num($control_reg)));
    if (defined(get_control_reg_select($control_reg))) {
        push(@$h_lines, format_c_macro($prefix . $name . "_REG_SELECT", 
          get_control_reg_select($control_reg)));
    }
    push(@$h_lines, format_c_macro($prefix . $name . "_REG_LSB", 
      get_control_reg_lsb($control_reg)));
    push(@$h_lines, format_c_macro($prefix . $name . "_REG_MSB", 
      get_control_reg_msb($control_reg)));
    push(@$h_lines, format_c_macro($prefix . $name . "_REG_SZ", 
      get_control_reg_sz($control_reg)));
    push(@$h_lines, format_c_macro($prefix . $name . "_REG_UNSHIFTED_MASK", 
      get_control_reg_unshifted_mask($control_reg), $FMT_HEX));
    push(@$h_lines, format_c_macro($prefix . $name . "_REG_SHIFTED_MASK", 
      get_control_reg_shifted_mask($control_reg), $FMT_HEX));
    push(@$h_lines, format_c_macro($prefix . $name . "_REG_MASK", 
      "(" . $prefix . $name . "_REG_SHIFTED_MASK)", $FMT_UNQUOTED_STR));

    foreach my $field (@{get_control_reg_fields($control_reg)}) {
        if (!defined(convert_control_reg_field_to_c($field, 
          $c_lines, $h_lines, $prefix))) {
            return undef;
        }
    }

    return 1;   # Some defined value
}



















sub
add_control_reg_field
{
    my $control_reg = shift;    # Reference to control register entry
    my $props = shift;          # Hash reference with arguments

    validate_hash_keys("control_reg_field", $props, 
      ["name","lsb","sz","mode","constant_value","reset_value"]) || 
      return undef;

    if (!defined(validate_control_reg($control_reg))) {
        return undef;
    }

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

    my $control_reg_name = get_control_reg_name($control_reg);

    if (defined(get_control_reg_field_or_undef($control_reg, $name))) {
        return &$error("Control register field $name of $control_reg_name" .
          " already exists");
    }

    my $bit_field = create_bit_field({
        name    => $name,
        lsb     => $lsb,
        sz      => $sz
    });

    if (!defined($bit_field)) {
        return undef;
    }

    my $mode = $props->{mode};
    if (!defined($mode)) { 
        $mode = $MODE_READ_WRITE;
    }

    my $constant_value = $props->{constant_value};
    my $constant_value_defined = defined($constant_value);

    if ($constant_value_defined && ($mode != $MODE_CONSTANT)) {
        return &$error("Control register field $name of $control_reg_name" .
          " isn't in the constant mode but a constant_value was specified");
    }

    if (!$constant_value_defined && ($mode == $MODE_CONSTANT)) {
        return &$error("Control register field $name of $control_reg_name" .
          " is in the constant mode but no constant_value was specified");
    }

    my $reset_value = $props->{reset_value};
    my $reset_value_defined = defined($reset_value);
    if (!$reset_value_defined) { 
        $reset_value = $constant_value_defined ? $constant_value : 0; 
    }

    my $unshifted_mask = get_bit_field_unshifted_mask($bit_field);
    if (($reset_value & ~$unshifted_mask) != 0) {
        return &$error("Reset value of $reset_value doesn't fit in" .
          " field $name of $control_reg_name");
    }

    if (($constant_value & ~$unshifted_mask) != 0) {
        return &$error("Constant value of $constant_value doesn't fit in" .
          " field $name of $control_reg_name");
    }



    if ($reset_value_defined && $constant_value_defined && 
      ($reset_value != $constant_value)) {
        return &$error("Constant value of $constant_value doesn't match the" .
          " reset_value value $reset_value for field $name" .
          " of $control_reg_name");
    }


    my $field = {
        type            => "control_reg_field",
        control_reg     => $control_reg,
        bit_field       => $bit_field,
        reset_value     => $reset_value,
        constant_value  => $constant_value,
        mode            => $mode,
    };

    my $fields_ref = get_control_reg_fields($control_reg);


    foreach my $existing_field (@$fields_ref) {
        my $existing_bit_field = $existing_field->{bit_field};
        my $overlap_ret = detect_bit_field_overlap($bit_field,
          $existing_bit_field);
        if (!defined($overlap_ret)) {
            return undef;
        }
        if ($overlap_ret ne "") {
            return &$error("Register $control_reg_name: $overlap_ret");
        }
    }


    push(@$fields_ref, $field);

    return $field;
}






sub
add_control_reg_reserved_fields
{
    my $control_reg = shift;

    if (!defined(validate_control_reg($control_reg))) {
        return undef;
    }

    my $reg_name = get_control_reg_name($control_reg);
    my @unsorted_fields = @{get_control_reg_fields($control_reg)};


    my @sorted_fields = sort { 
      get_control_reg_field_msb($b) <=> get_control_reg_field_msb($a) 
    } @unsorted_fields;



    my @reserved = ();

    my $msb = $CONTROL_REG_SZ-1;

    while ($msb >= 0) {
        if (scalar(@sorted_fields) > 0) {
            my $next_field = $sorted_fields[0];
            my $next_field_msb = get_control_reg_field_msb($next_field);

            if ($msb > $next_field_msb) {

                my $gap_sz = $msb - $next_field_msb;
                push(@reserved, { msb => $msb, sz => $gap_sz});
                $msb -= $gap_sz;
            } elsif ($msb == $next_field_msb) {

                shift(@sorted_fields);
                $msb -= get_control_reg_field_sz($next_field);
            } else {
                my $field_name = get_control_reg_field_name($next_field);
                return &$error("msb of $msb should never be less" .
                  " than the next field msb of $next_field_msb for" .
                  " field $field_name of control register $reg_name");
            }
        } else {

            my $gap_sz = $msb + 1;
            push(@reserved, { msb => $msb, sz => $gap_sz});
            $msb -= $gap_sz;
        }
    } 



    my $rsv_index = 0;
    foreach my $reserved (reverse(@reserved)) {
        my $msb = $reserved->{msb};
        my $sz = $reserved->{sz};

        if (!defined(add_control_reg_field($control_reg, { 
            name => "rsv" . $rsv_index, 
            lsb => ($msb - $sz + 1),
            sz => $sz,
            mode => $MODE_RESERVED,
          }))) {
            return undef;
        }

        $rsv_index++;
    }

    return 1;   # Some defined value
}




sub
validate_control_reg_field
{
    my $field = shift;

    if (!defined($field)) {
        return &$error("Control register field reference is undefined");
    }

    if ($field == 0) {
        return &$error("Control register field reference is 0");
    }

    my $ref_type = ref($field);
    if ($ref_type ne "HASH") {
        return &$error("Control register field reference is to a $ref_type" .
          " but must be to a HASH");
    }

    my $type = $field->{type};

    if (!defined($type)) {
        return &$error("Control register field hash reference has no" .
            " \"type\" member");
    }

    if ($type ne "control_reg_field") {
        return 
          &$error("Control register field hash reference has incorrect type"
                  . " of \"$type\"");
    }

    return $field;
}



sub
get_control_reg_field
{
    my $control_reg = shift;    # Reference to control register entry
    my $name = shift;           # Lowercase name of field (e.g. pie)

    if (!defined(validate_control_reg($control_reg))) {
        return undef;
    }

    my $control_reg_name = get_control_reg_name($control_reg);
    my $field = get_control_reg_field_or_undef($control_reg, $name);

    if (defined($field)) {
        return $field;
    }

    return &$error("Control register field $name in register" .
      " $control_reg_name not found.");
}



sub
get_control_reg_field_or_undef
{
    my $control_reg = shift;    # Reference to control register entry
    my $name = shift;           # Lowercase name of field (e.g. pie)

    if (!defined(validate_control_reg($control_reg))) {
        return undef;
    }

    my $fields_ref = get_control_reg_fields($control_reg);

    foreach my $field (@$fields_ref) {
        if ($name eq get_control_reg_field_name($field)) {
            return $field;
        }
    }

    return undef;
}




sub
get_control_reg_field_names
{
    my $control_reg = shift;    # Reference to control register entry
    my @names;

    if (!defined(validate_control_reg($control_reg))) {
        return undef;
    }

    foreach my $field (@{$control_reg->{fields}}) {
        my $mode = get_control_reg_field_mode($field);
        if ($mode == $MODE_RESERVED) {
            next;
        }

        push(@names, get_control_reg_field_name($field));
    }

    my @sorted_names = sort(@names);

    return \@sorted_names;
}






sub
get_control_reg_field_into_scalars
{
    my $field = shift;    # Reference to field

    if (!defined(validate_control_reg_field($field))) {
        return undef;
    }

    my $control_reg = get_control_reg_field_control_reg($field);
    my $reg_name = get_control_reg_name($control_reg);



    my $prefix = $reg_name . '_reg_';

    return get_bit_field_into_scalars($field->{bit_field}, $prefix);
}


sub
get_control_reg_field_control_reg
{
    my $field = shift;

    if (!defined(validate_control_reg_field($field))) {
        return undef;
    }

    return $field->{control_reg};
}


sub
get_control_reg_field_name
{
    my $field = shift;

    if (!defined(validate_control_reg_field($field))) {
        return undef;
    }

    return get_bit_field_name($field->{bit_field});
}


sub
get_control_reg_field_lsb
{
    my $field = shift;

    if (!defined(validate_control_reg_field($field))) {
        return undef;
    }

    return get_bit_field_lsb($field->{bit_field});
}


sub
get_control_reg_field_msb
{
    my $field = shift;

    if (!defined(validate_control_reg_field($field))) {
        return undef;
    }

    return get_bit_field_msb($field->{bit_field});
}


sub
get_control_reg_field_sz
{
    my $field = shift;

    if (!defined(validate_control_reg_field($field))) {
        return undef;
    }

    return get_bit_field_sz($field->{bit_field});
}


sub
get_control_reg_field_unshifted_mask
{
    my $field = shift;

    if (!defined(validate_control_reg_field($field))) {
        return undef;
    }

    return get_bit_field_unshifted_mask($field->{bit_field});
}


sub
get_control_reg_field_shifted_mask
{
    my $field = shift;

    if (!defined(validate_control_reg_field($field))) {
        return undef;
    }

    return get_bit_field_shifted_mask($field->{bit_field});
}


sub
get_control_reg_field_reset_value
{
    my $field = shift;

    if (!defined(validate_control_reg_field($field))) {
        return undef;
    }

    return $field->{reset_value};
}


sub
get_control_reg_field_constant_value
{
    my $field = shift;

    if (!defined(validate_control_reg_field($field))) {
        return undef;
    }

    return $field->{constant_value};
}


sub
get_control_reg_field_mode
{
    my $field = shift;

    if (!defined(validate_control_reg_field($field))) {
        return undef;
    }

    return $field->{mode};
}



sub
is_control_reg_field_readable
{
    my $field = shift;

    if (!defined(validate_control_reg_field($field))) {
        return undef;
    }

    return 
      ($field->{mode} == $MODE_READ_WRITE) ||
      ($field->{mode} == $MODE_READ_ONLY);
}


sub
is_control_reg_field_writeable
{
    my $field = shift;

    if (!defined(validate_control_reg_field($field))) {
        return undef;
    }

    return 
      ($field->{mode} == $MODE_READ_WRITE) ||
      ($field->{mode} == $MODE_WRITE_ONLY);
}


sub
convert_control_reg_field_to_c
{
    my $field = shift;
    my $c_lines = shift;        # Reference to array of lines for *.c file
    my $h_lines = shift;        # Reference to array of lines for *.h file
    my $prefix = shift;         # Optional prefix

    if (!defined(validate_control_reg_field($field))) {
        return undef;
    }

    my $control_reg = get_control_reg_field_control_reg($field);
    my $reg_name = get_control_reg_name($control_reg);

    return convert_bit_field_to_c($field->{bit_field}, $c_lines, $h_lines,
      $prefix . $reg_name . "_REG_", "Reg");
}







sub
control_reg_compare
{
    my $control_reg0 = shift;
    my $control_reg1 = shift;


    my $num_cmp = 
      get_control_reg_num($control_reg0) <=> 
      get_control_reg_num($control_reg1);

    if ($num_cmp != 0) {

        return $num_cmp;
    }

    if (!defined(get_control_reg_select($control_reg0))) {
        return 
          &$error("Control register '" . get_control_reg_name($control_reg0) .
            "' needs to have a select field to make the control register" .
            " number " . get_control_reg_num($control_reg0) . " unique");
    }

    if (!defined(get_control_reg_select($control_reg1))) {
        return 
          &$error("Control register '" . get_control_reg_name($control_reg1) .
            "' needs to have a select field to make the control register" .
            " number " . get_control_reg_num($control_reg1) . " unique");
    }


    my $select_cmp =
      get_control_reg_select($control_reg0) <=> 
      get_control_reg_select($control_reg1);

    return $select_cmp;
}


1;
