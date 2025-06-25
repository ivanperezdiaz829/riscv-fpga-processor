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






















package cpu_inst_table;
use Exporter;
@ISA = Exporter;
@EXPORT = qw(
    &create_inst_table
    &validate_inst_table
    &get_inst_table_names
    &get_inst_table_child_table_infos
    &get_inst_table_by_name
    &get_inst_table_by_name_or_undef
    &get_inst_table_name
    &get_inst_table_inst_field
    &get_inst_table_inst_type
    &get_inst_table_opcodes
    &get_inst_table_parent_table
    &get_inst_table_opcode_type
    &convert_inst_table_to_c

    $OPCODE_TYPE_INST_NAME
    $OPCODE_TYPE_CHILD_TABLE_NAME
    $OPCODE_TYPE_RESERVED_NUM
);

use cpu_utils;
use cpu_inst_field;
use strict;




















our $OPCODE_TYPE_INST_NAME = 1;
our $OPCODE_TYPE_CHILD_TABLE_NAME = 2;
our $OPCODE_TYPE_RESERVED_NUM = 3;





















sub
create_inst_table
{
    my $props = shift;          # Hash reference with arguments

    validate_hash_keys("inst_table", $props, 
      ["name","inst_field","inst_type","opcodes","parent_table"]) ||
        return undef;

    my $err;

    my $name = not_empty_scalar($props, "name") || return undef;
    my $inst_field = manditory_hash($props, "inst_field") || return undef;
    validate_inst_field($inst_field) || return undef;

    $err = 0;
    my $inst_type = optional_scalar($props, "inst_type", \$err);
    if ($err) {
        return undef;
    }

    my $opcodes = manditory_array($props, "opcodes") || return undef;

    $err = 0;
    my $parent_table = optional_hash($props, "parent_table", \$err);
    if ($err) { return undef; }
    if (defined($parent_table)) {
        validate_inst_table($parent_table) || return undef;
    }


    my $num_opcode_entries = scalar(@$opcodes);
    my $expected_num_opcode_entries = (0x1 << get_inst_field_sz($inst_field));
    if ($num_opcode_entries != $expected_num_opcode_entries) {
        return &$error("Expected $expected_num_opcode_entries entries in the" .
          " opcodes array for instruction table '$name' but got " .
          $num_opcode_entries);
    }


    my $inst_table = {
        type            => "inst_table",
        name            => $name,
        inst_field      => $inst_field,
        inst_type       => $inst_type,
        opcodes         => $opcodes,
        parent_table    => $parent_table,
    };



    for (my $i=0; $i < $num_opcode_entries; $i++) {
        my $opcode = $opcodes->[$i];

        my $opcode_type = get_inst_table_opcode_type($opcode, $inst_table) ||
          return undef;

        if ($opcode_type == $OPCODE_TYPE_RESERVED_NUM) {
            if ($opcode != $i) {
                return &$error("Opcode entry '$opcode' of table '$name'" .
                  " is a reserved number but doesn't match the index of $i");
            }
        }
    }



    for (my $i=0; $i < $num_opcode_entries; $i++) {
        for (my $j=$i+1; $j < $num_opcode_entries; $j++) {
            my $i_opcode = $opcodes->[$i];
            my $j_opcode = $opcodes->[$j];

            if ($i_opcode eq $j_opcode) {


                my $i_opcode_type = 
                  get_inst_table_opcode_type($i_opcode, $inst_table) ||
                    return undef;
                my $j_opcode_type = 
                  get_inst_table_opcode_type($j_opcode, $inst_table) ||
                    return undef;

                if (
                  ($i_opcode_type == $OPCODE_TYPE_CHILD_TABLE_NAME) &&
                  ($j_opcode_type == $OPCODE_TYPE_CHILD_TABLE_NAME)) {
                    next;
                }

                return &$error("Found duplicate opcode entry '" . 
                  $opcodes->[$i] . "' at index $i and index $j of instruction" .
                  " table '$name'");
            }
        }
    }

    return $inst_table;
}




sub
validate_inst_table
{
    my $inst_table = shift;

    if (!defined($inst_table)) {
        return &$error("Instruction table reference is undefined");
    }

    if ($inst_table == 0) {
        return &$error("Instruction table reference is 0");
    }

    my $ref_type = ref($inst_table);
    if ($ref_type ne "HASH") {
        return &$error("Instruction table reference is to a $ref_type" .
          " but must be to a HASH");
    }

    my $type = $inst_table->{type};

    if (!defined($type)) {
        return &$error("Instruction table hash reference has" .
          " no \"type\" member");
    }

    if ($type ne "inst_table") {
        return &$error("Instruction table hash reference has" .
          " incorrect type of \"$type\"");
    }

    return $inst_table;
}



sub
get_inst_table_names
{
    my $inst_tables = shift;

    my @names;

    foreach my $inst_table (@$inst_tables) {
        push(@names, $inst_table->{name});
    }

    my @sorted_names = sort(@names);

    return \@sorted_names;
}






sub
get_inst_table_child_table_infos
{
    my $inst_tables = shift;        # All instruction tables
    my $inst_table = shift;         # Table to find children in

    my @child_table_infos;

    my $opcodes = get_inst_table_opcodes($inst_table); 

    for (my $code=0; $code < scalar(@$opcodes); $code++) {
        my $opcode = $opcodes->[$code];
        my $opcode_type = get_inst_table_opcode_type($opcode, $inst_table) ||
          return undef;

        if ($opcode_type != $OPCODE_TYPE_CHILD_TABLE_NAME) {
            next;
        }

        my $child_table = get_inst_table_by_name($inst_tables, $opcode) 
          || return undef;

        my $existing_child_table_info = undef;
        foreach my $child_table_info (@child_table_infos) {
            if ($child_table == $child_table_info->{child_table}) {
                $existing_child_table_info = $child_table_info;
            }
        }

        if ($existing_child_table_info) {

            push(@{$existing_child_table_info->{codes}}, $code);
        } else {

            my $child_table_info = {
                child_table => $child_table,
                codes       => [$code],
            };

            push(@child_table_infos, $child_table_info);
        }
    }

    return \@child_table_infos;
}



sub
get_inst_table_by_name
{
    my $inst_tables = shift;
    my $name = shift;   # upper-case or lower-case name (e.g. "op")

    my $inst_table = get_inst_table_by_name_or_undef($inst_tables, $name);

    if (defined($inst_table)) {
        return $inst_table;
    }
    
    return &$error("Instruction table name '$name' not found.");
}




sub
get_inst_table_by_name_or_undef
{
    my $inst_tables = shift;
    my $name = shift;   # upper-case or lower-case name (e.g. "op")

    my $name_lc = lc($name);

    foreach my $inst_table (@$inst_tables) {
        if ($name_lc eq $inst_table->{name}) {
            return $inst_table;
        }
    }

    return undef;
}


sub
get_inst_table_name
{
    my $inst_table = shift;

    if (!defined(validate_inst_table($inst_table))) {
        return undef;
    }

    return $inst_table->{name};
}


sub
get_inst_table_inst_field
{
    my $inst_table = shift;

    if (!defined(validate_inst_table($inst_table))) {
        return undef;
    }

    return $inst_table->{inst_field};
}


sub
get_inst_table_inst_type
{
    my $inst_table = shift;

    if (!defined(validate_inst_table($inst_table))) {
        return undef;
    }

    return $inst_table->{inst_type};
}


sub
get_inst_table_opcodes
{
    my $inst_table = shift;

    if (!defined(validate_inst_table($inst_table))) {
        return undef;
    }

    return $inst_table->{opcodes};
}


sub
get_inst_table_parent_table
{
    my $inst_table = shift;

    if (!defined(validate_inst_table($inst_table))) {
        return undef;
    }

    return $inst_table->{parent_table};
}


sub
get_inst_table_opcode_type
{
    my $opcode = shift;
    my $inst_table = shift;     # Optional table reference for error messages

    if (defined($inst_table)) {
        validate_inst_table($inst_table) || return undef;
    }

    if ($opcode =~ /^[a-z][a-z0-9_]*$/) {
        return $OPCODE_TYPE_INST_NAME;
    }

    if ($opcode =~ /^[A-Z][A-Z0-9_]*$/) {
        return $OPCODE_TYPE_CHILD_TABLE_NAME;
    }

    if ($opcode =~ /^[0-9]+$/) {
        return $OPCODE_TYPE_RESERVED_NUM;
    }

    my $error_msg = 
      "Can't determine the opcode type for opcode table entry '$opcode'";

    if (defined($inst_table)) {
      $error_msg .= (" in table '" . get_inst_table_name($inst_table) . "'");

    }

    return &$error($error_msg);
}


sub
convert_inst_table_to_c
{
    my $inst_tables = shift;
    my $inst_table = shift;
    my $global_prefix = shift;  # Lower-case prefix for global variables
    my $c_lines = shift;        # Reference to array of lines for *.c file
    my $h_lines = shift;        # Reference to array of lines for *.h file

    my $prefix_uc = uc($global_prefix);

    if (!defined(validate_inst_table($inst_table))) {
        return undef;
    }

    my $opcodes = get_inst_table_opcodes($inst_table); 
    my $num_opcodes = scalar(@$opcodes);
    my $table_name = get_inst_table_name($inst_table);
    my $table_name_uc = uc($table_name);
    my $field = get_inst_table_inst_field($inst_table);
    my $field_name_uc = uc(get_inst_field_name($field));
    my $child_table_infos = 
      get_inst_table_child_table_infos($inst_tables, $inst_table);

    push(@$c_lines, 
      "",
      "/* $table_name_uc table instruction opcode values" .
        " (index is $field_name_uc field) */",
      "const char*",
      "${global_prefix}${table_name}_names[${prefix_uc}NUM_${table_name_uc}_INSTS]" .
        " = {");

    push(@$h_lines, 
      "",
      "/* $table_name_uc table instruction opcode values" .
        " (index is $field_name_uc field) */",
      "#define ${prefix_uc}NUM_${table_name_uc}_INSTS " . $num_opcodes,
      "#ifndef ALT_ASM_SRC",
      "extern const char*" .
        " ${global_prefix}${table_name}_names" .
        "[${prefix_uc}NUM_${table_name_uc}_INSTS];",
      "#endif /* ALT_ASM_SRC */");

    push(@$h_lines, 
      "",
      "/* $table_name_uc table instruction values */",
    );
    
    for (my $code=0; $code < $num_opcodes; $code++) {
        my $opcode = $opcodes->[$code];
        my $opcode_type = get_inst_table_opcode_type($opcode);
        my $c_name;
        my $h_name;

        if ($opcode_type == $OPCODE_TYPE_INST_NAME) {
            $c_name = $opcode;
            $h_name = $opcode;
        } elsif ($opcode_type == $OPCODE_TYPE_RESERVED_NUM) {
            $c_name = "";
            $h_name = "";
        } elsif ($opcode_type == $OPCODE_TYPE_CHILD_TABLE_NAME) {


            my $my_index;
            my $num_child_table_names_with_my_name = 0;

            for (my $other_code=0; $other_code < $num_opcodes; $other_code++) {
                my $other_opcode = $opcodes->[$other_code];
                my $other_opcode_type = 
                  get_inst_table_opcode_type($other_opcode);
                if (
                  ($other_opcode_type == $OPCODE_TYPE_CHILD_TABLE_NAME) &&
                  ($opcodes->[$other_code] eq $opcode)) {
                    if ($code == $other_code) {
                        if (defined($my_index)) {
                            return &$error("Hey, my_index is already defined");
                        }
                        $my_index = $num_child_table_names_with_my_name;
                    }

                    $num_child_table_names_with_my_name++;
                }
            }

            if (!defined($my_index)) {
                return &$error("Hey, my_index was never assigned to");
            }
            if ($num_child_table_names_with_my_name == 0) {
                return &$error("Hey, I never found my own child name");
            }

            $c_name = lc($opcode);
            $h_name = lc($opcode);
            if ($num_child_table_names_with_my_name > 1) {

                $h_name .= ("_" . $my_index);
            }
        } else {
            return &$error(
              "Unknown opcode_type of '$opcode_type' for opcode '$opcode'");
        }

        my $last = ($code == ($num_opcodes-1));
    
        push(@$c_lines, 
          "    \"$c_name\"" . ($last ? "" : ",") . 
            sprintf(" /* 0x%x */", $code, $code));
    
        if ($h_name ne "") {
            push(@$h_lines, 
              format_c_macro("${prefix_uc}${table_name_uc}_" . $h_name, $code));
        }
    }
    push(@$c_lines, "};");
    
    if (scalar(@$child_table_infos) > 0) {
        push(@$h_lines, 
          "",
          "/* Macros to detect instructions in child tables */",
        );

        for my $child_table_info (@$child_table_infos) {
            my $child_table = manditory_hash($child_table_info, "child_table");
            my $child_table_name = get_inst_table_name($child_table);
            my $child_table_name_uc = uc($child_table_name);
            my $codes = manditory_array($child_table_info, "codes");

            my @code_exprs;
            for (my $index = 0; $index < scalar(@$codes); $index++) {


                my $code_expr =
                  "(GET_${prefix_uc}IW_${field_name_uc}(Iw)" .
                    " == ${prefix_uc}${table_name_uc}_${child_table_name_uc}";
                if (scalar(@$codes) > 1) {
                    $code_expr .= ("_" . $index);
                }
                $code_expr .= ")";

                push(@code_exprs, $code_expr);
            }

            my $rhs = "(" . join('||', @code_exprs) . ")";

            if (get_inst_table_parent_table($inst_table)) {
                $rhs = "(" . $rhs . 
                  " && ${prefix_uc}IS_${table_name_uc}_INST(Iw))";
            }

            push(@$h_lines, 
              "#define ${prefix_uc}IS_${child_table_name_uc}_INST(Iw) $rhs");
        }
    }

    return 1;   # Some defined value
}

1;
