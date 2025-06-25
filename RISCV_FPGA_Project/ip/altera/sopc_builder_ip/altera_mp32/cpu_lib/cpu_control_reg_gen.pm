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






















package cpu_control_reg_gen;
use Exporter;
@ISA = Exporter;
@EXPORT = qw(
    &set_control_reg_pipeline_desc
    &set_control_reg_need_testbench_version
    &get_control_reg_need_testbench_version
    &set_control_reg_no_rdctl
    &get_control_reg_no_rdctl
    &set_control_reg_field_auto_input
    &get_control_reg_field_auto_input
    &set_control_reg_field_pri_mux_table
    &get_control_reg_field_pri_mux_table
    &set_control_reg_field_input_expr
    &get_control_reg_field_input_expr
    &set_control_reg_field_wr_en_expr
    &get_control_reg_field_wr_en_expr
    &set_control_reg_field_testbench_expr
    &get_control_reg_field_testbench_expr

    &gen_control_regs
    &get_control_regs_for_waves
);

use cpu_utils;
use cpu_control_reg;
use cpu_inst_field;
use strict;












our @stages;
our $control_reg_stage;
our $rdctl_stage;
our $wrctl_setup_stage;
our $wrctl_data;
our $regnum_field;
our $select_field;































sub
set_control_reg_pipeline_desc
{
    my $props = shift;          # Hash reference with arguments

    validate_hash_keys("props", $props, [
      "stages",
      "control_reg_stage",
      "rdctl_stage",
      "wrctl_setup_stage",
      "wrctl_data",
      "regnum_field",
      "select_field",
    ]) || return undef;

    my $stages_ref = manditory_array($props, "stages") || return undef;
    @stages = @$stages_ref;
    if (scalar(@stages) == 0) {
        return &$error("stages array is empty");
    }
    $control_reg_stage = not_empty_scalar($props, "control_reg_stage") || 
      return undef;
    $rdctl_stage = not_empty_scalar($props, "rdctl_stage") || return undef;
    $wrctl_setup_stage = not_empty_scalar($props, "wrctl_setup_stage") || 
      return undef;
    $wrctl_data = not_empty_scalar($props, "wrctl_data") || return undef;
    $regnum_field = manditory_hash($props, "regnum_field") ||
      return undef;
    validate_inst_field($regnum_field) || return undef;
    my $err = 0;
    $select_field = optional_hash($props, "select_field", \$err);
    if ($err) {
        return undef;
    }
    if ($select_field) {
        validate_inst_field($select_field) || return undef;
    }

    return 1;   # Just some defined value
}


sub
set_control_reg_need_testbench_version
{
    my $control_reg = shift;
    my $value = shift;

    if (!defined(validate_control_reg($control_reg))) {
        return undef;
    }

    $control_reg->{need_testbench_version} = $value;

    return 1;   # Some defined value
}


sub
get_control_reg_need_testbench_version
{
    my $control_reg = shift;

    if (!defined(validate_control_reg($control_reg))) {
        return undef;
    }

    return $control_reg->{need_testbench_version};
}


sub
set_control_reg_no_rdctl
{
    my $control_reg = shift;
    my $value = shift;

    if (!defined(validate_control_reg($control_reg))) {
        return undef;
    }

    $control_reg->{no_rdctl} = $value;

    return 1;   # Some defined value
}


sub
get_control_reg_no_rdctl
{
    my $control_reg = shift;

    if (!defined(validate_control_reg($control_reg))) {
        return undef;
    }

    return $control_reg->{no_rdctl};
}




sub
set_control_reg_field_auto_input
{
    my $field = shift;                  # Reference to control register field
    my $auto_input = shift;        # Boolean

    if (!defined(validate_control_reg_field($field))) {
        return undef;
    }

    my $control_reg = get_control_reg_field_control_reg($field);
    my $reg_name = get_control_reg_name($control_reg);
    my $field_name = get_control_reg_field_name($field);

    my $bool_value = validate_bool($auto_input);

    if (!defined($bool_value)) {
        return &$error("Automatic input argument '$auto_input' for field"
          . " $field_name of control register $reg_name is not a valid"
          . " boolean value");
    }

    if ($bool_value) {
        if (!is_control_reg_field_readable($field)) {
            return 
              &$error("Field $field_name of control register $reg_name is not"
              . " readable so you can't enable automatic input");
        }
    
        if (get_control_reg_field_input_expr($field) ne "") {
            return 
              &$error("Field $field_name of control register $reg_name can't"
              . " enable automatic input because it already has "
              . " an explicit input expression defined.");
        }
    }

    $field->{auto_input} = $bool_value;

    return 1;   # Some defined value
}


sub
get_control_reg_field_auto_input
{
    my $field = shift;

    if (!defined(validate_control_reg_field($field))) {
        return undef;
    }

    return $field->{auto_input};
}


sub
set_control_reg_field_pri_mux_table
{
    my $field = shift;            # Reference to control register field
    my $pri_mux_table = shift;        # Array reference

    if (!defined(validate_control_reg_field($field))) {
        return undef;
    }

    assert_array_ref($pri_mux_table, "pri_mux_table") || return undef;

    my $control_reg = get_control_reg_field_control_reg($field);
    my $reg_name = get_control_reg_name($control_reg);
    my $field_name = get_control_reg_field_name($field);


    set_control_reg_field_auto_input($field, 1) || return undef;

    $field->{pri_mux_table} = $pri_mux_table;

    return 1;   # Some defined value
}


sub
get_control_reg_field_pri_mux_table
{
    my $field = shift;

    if (!defined(validate_control_reg_field($field))) {
        return undef;
    }

    return $field->{pri_mux_table};
}



sub
set_control_reg_field_input_expr
{
    my $field = shift;          # Reference to control register field
    my $input_expr = shift;         # Register input expression_expr

    if (!defined(validate_control_reg_field($field))) {
        return undef;
    }

    my $control_reg = get_control_reg_field_control_reg($field);
    my $reg_name = get_control_reg_name($control_reg);
    my $field_name = get_control_reg_field_name($field);

    if ($input_expr ne "") {
        if (get_control_reg_field_auto_input($field)) {
            return 
              &$error("Field $field_name of control register $reg_name can't"
              . " have an explicit input expression because it already has "
              . " automatic input enabled.");
        }
    }

    $field->{input_expr} = $input_expr;

    return 1;   # Some defined value
}


sub
get_control_reg_field_input_expr
{
    my $field = shift;

    if (!defined(validate_control_reg_field($field))) {
        return undef;
    }

    return $field->{input_expr};
}



sub
set_control_reg_field_wr_en_expr
{
    my $field = shift;          # Reference to control register field
    my $wr_en_expr = shift;     # Register write enable expression

    if (!defined(validate_control_reg_field($field))) {
        return undef;
    }

    $field->{wr_en_expr} = $wr_en_expr;

    return 1;   # Some defined value
}


sub
get_control_reg_field_wr_en_expr
{
    my $field = shift;

    if (!defined(validate_control_reg_field($field))) {
        return undef;
    }

    return $field->{wr_en_expr};
}


sub
set_control_reg_field_testbench_expr
{
    my $field = shift;          # Reference to control register field
    my $testbench_expr = shift;     # Testbench expression

    if (!defined(validate_control_reg_field($field))) {
        return undef;
    }

    $field->{testbench_expr} = $testbench_expr;

    return 1;   # Some defined value
}


sub
get_control_reg_field_testbench_expr
{
    my $field = shift;

    if (!defined(validate_control_reg_field($field))) {
        return undef;
    }

    return $field->{testbench_expr};
}


sub
get_control_regs_for_waves
{
    my $control_regs = shift;

    assert_array_ref($control_regs, "control_regs") || return undef;

    my $cs = $control_reg_stage || return &$error("Missing control_reg_stage");

    my @wave_signals;


    foreach my $control_reg (@{get_control_regs_sorted($control_regs)}) {
        my $control_reg_name = get_control_reg_name($control_reg);

        push(@wave_signals,
          { radix => "x", signal => "${cs}_${control_reg_name}_reg" },
        );

        my @unsorted_fields = @{get_control_reg_fields($control_reg)};


        my @sorted_fields = sort { 
          get_control_reg_field_lsb($a) <=> get_control_reg_field_lsb($b) 
        } @unsorted_fields;

        foreach my $control_reg_field (@sorted_fields) {
            if (is_control_reg_field_readable($control_reg_field)) {
                my $control_reg_field_name = 
                  get_control_reg_field_name($control_reg_field);

                push(@wave_signals, { 
                  radix  => "x", 
                  signal => 
                    "${cs}_${control_reg_name}_reg_${control_reg_field_name}" ,
                });
            }
        }
    }

    return \@wave_signals;
}









sub 
gen_control_regs
{
    my $control_regs = shift;       # Reference to array of control regs
    my $assignment_func = shift;
    my $register_func = shift;
    my $binary_mux_func = shift;
    my $rdctl_info = shift;


    foreach my $control_reg (@$control_regs) {
        if (!defined(add_control_reg_reserved_fields($control_reg))) {
            return undef;
        }
    }




    if (!defined(gen_wrctl_reg_num_decode($control_regs, $assignment_func))) {
        return undef;
    }
    if (!defined(gen_wrctl_data($control_regs, $assignment_func))) {
        return undef;
    }
    if (!defined(gen_field_regs_for_all_control_regs($control_regs, 
      $assignment_func, $register_func))) {
        return undef;
    }
    if (!defined(combine_fields_for_all_control_regs($control_regs, 
      $assignment_func))) {
        return undef;
    }
    if (!defined(gen_rdctl($control_regs, $assignment_func, 
      $register_func, $binary_mux_func, $rdctl_info))) {
        return undef;
    }

    return 1;   # Some defined value
}





sub 
gen_wrctl_reg_num_decode
{
    my $control_regs = shift;       # Reference to array of control regs
    my $assignment_func = shift;

    my $wss = $wrctl_setup_stage ||
      return &$error("Missing wrctl_setup_stage");
    $regnum_field || return &$error("Missing regnum_field");

    my $regnum_field_name = get_inst_field_name($regnum_field);



    foreach my $control_reg (@$control_regs) {
        my $name = get_control_reg_name($control_reg);
        my $num = get_control_reg_num($control_reg);
        my $select = get_control_reg_select($control_reg);

        if (get_control_reg_has_writeable_fields($control_reg)) {
            my $rhs = "${wss}_ctrl_wrctl_inst";
            $rhs .= " & (${wss}_iw_${regnum_field_name} == $num)";

            if (defined($select)) {
                $select_field || return &$error("Missing select_field");

                my $select_field_name = get_inst_field_name($select_field);

                $rhs .= " & (${wss}_iw_${select_field_name} == $select)";
            }

            &$assignment_func({
              lhs => "${wss}_wrctl_${name}",
              rhs => $rhs,
              sz => 1
            });
        }
    }

    return 1;   # Some defined value
}





sub 
gen_wrctl_data
{
    my $control_regs = shift;       # Reference to array of control regs
    my $assignment_func = shift;

    my $wss = $wrctl_setup_stage ||
      return &$error("Missing wrctl_setup_stage");
    my $wdata = $wrctl_data || return &$error("Missing wrctl_data");

    foreach my $control_reg (@$control_regs) {
        my $reg_name = get_control_reg_name($control_reg);

        foreach my $field (@{get_control_reg_fields($control_reg)}) {
            if (is_control_reg_field_writeable($field)) {
                my $field_name = get_control_reg_field_name($field);
                my $sz = get_control_reg_field_sz($field);
                my $msb = get_control_reg_field_msb($field);
                my $lsb = get_control_reg_field_lsb($field);

                &$assignment_func({
                  lhs => "${wss}_wrctl_data_${reg_name}_reg_${field_name}",
                  rhs => ($sz > 1) ? "${wdata}\[$msb:$lsb]" : "${wdata}\[$lsb]",
                  sz => $sz,
                });
            }
        }
    }

    return 1;   # Some defined value
}





sub 
gen_field_regs_for_all_control_regs
{
    my $control_regs = shift;       # Reference to array of control regs
    my $assignment_func = shift;
    my $register_func = shift;

    my $cs = $control_reg_stage || 
      return &$error("Missing control_reg_stage");


    foreach my $control_reg (@$control_regs) {
        my $reg_name = get_control_reg_name($control_reg);

        foreach my $field (@{get_control_reg_fields($control_reg)}) {
            if (is_control_reg_field_readable($field)) {
                my $field_name = get_control_reg_field_name($field);
                my $sz = get_control_reg_field_sz($field);
                my $reg_out_signal = "${cs}_${reg_name}_reg_${field_name}";

                my $input_signal = $reg_out_signal . "_nxt";



                my $input_expr = get_control_reg_field_auto_input($field) ?
                    construct_auto_input_expr($field) :
                    get_control_reg_field_input_expr($field);

                if ($input_expr eq "") {
                    return 
                      &$error("Missing register input expression for" .
                      " field $field_name of control register $reg_name");
                }

                &$assignment_func({
                  lhs => $input_signal,
                  rhs => $input_expr,
                  sz => $sz
                });

                my $wr_en_signal = $reg_out_signal . "_wr_en";
                my $wr_en_expr = get_control_reg_field_wr_en_expr($field);



                if ($wr_en_expr eq "") {
                    $wr_en_expr = "${cs}_en";
                }

                &$assignment_func({
                  lhs => $wr_en_signal,
                  rhs => $wr_en_expr,
                  sz => 1
                });

                &$register_func({
                  lhs => $reg_out_signal,
                  rhs => $input_signal,
                  sz => $sz,
                  reset_value => get_control_reg_field_reset_value($field),
                  en => $wr_en_signal,
                });
            }
        }
    }

    return 1;   # Some defined value
}




sub
construct_auto_input_expr
{
    my $field = shift;

    my $control_reg = get_control_reg_field_control_reg($field);
    my $reg_name = get_control_reg_name($control_reg);
    my $field_name = get_control_reg_field_name($field);

    my $wss = $wrctl_setup_stage ||
      return &$error("Missing wrctl_setup_stage");
    my $cs = $control_reg_stage || 
      return &$error("Missing control_reg_stage");


    my $wrctl_sel = "${wss}_wrctl_${reg_name} & ${wss}_valid";
    my $wrctl_val = "${wss}_wrctl_data_${reg_name}_reg_${field_name}";
    my $wrctl_added = 0;

    my $input_expr;

    my $pri_mux_table = get_control_reg_field_pri_mux_table($field);

    if ($pri_mux_table) {
        my $num_entries = scalar(@$pri_mux_table);

        if ($num_entries & 0x1) {
            return &$error("Priority mux table for field $field_name of" .
              " control register $reg_name has an odd number of entries of" .
              " $num_entries");
        }

        for (my $i = 0; $i < $num_entries; $i += 2) {
            my $sel = $pri_mux_table->[$i];
            my $val = $pri_mux_table->[$i+1];

            if ($sel eq "") {
                return &$error("Priority mux table for field $field_name of" .
                  " control register $reg_name has an empty select at" .
                  " index $i");
            }



            if ($sel eq "wrctl") {
                if (!is_control_reg_field_writeable($field)) {
                    return 
                      &$error("Priority mux table for field $field_name of" .
                        " control register $reg_name specifies wrctl but the" .
                        " field isn't writeable.");
                }

                $sel = $wrctl_sel;
                $val = $wrctl_val;
                $wrctl_added = 1;
            }

            if ($val eq "") {
                return &$error("Priority mux table for field $field_name of" .
                  " control register $reg_name has an empty value at" .
                  " index $i");
            }

            $input_expr .= 
              "($sel) ? ($val) :
              ";
        }
    }



    if (is_control_reg_field_writeable($field) && !$wrctl_added) {
        $input_expr .= 
            "($wrctl_sel) ? ($wrctl_val) :
            ";
    }


    $input_expr .= "${cs}_${reg_name}_reg_${field_name}";

    return $input_expr;
}






sub 
combine_fields_for_all_control_regs
{
    my $control_regs = shift;       # Reference to array of control regs
    my $assignment_func = shift;

    my $cs = $control_reg_stage || 
      return &$error("Missing control_reg_stage");

    foreach my $control_reg (@$control_regs) {

        if (!defined(combine_fields_for_one_control_reg($control_regs, 
          $assignment_func, $control_reg, 0))) {
            return undef;
        }


        if (get_control_reg_need_testbench_version($control_reg)) {
            if (!defined(combine_fields_for_one_control_reg($control_regs, 
              $assignment_func, $control_reg, 1))) {
                return undef;
            }
        }
    }

    return 1;   # Some defined value
}






sub 
combine_fields_for_one_control_reg
{
    my $control_regs = shift;       # Reference to array of control regs
    my $assignment_func = shift;
    my $control_reg = shift;
    my $testbench_version = shift;

    my $cs = $control_reg_stage || 
      return &$error("Missing control_reg_stage");

    my $reg_name = get_control_reg_name($control_reg);


    if (!defined(add_control_reg_reserved_fields($control_reg))) {
        return undef;
    }

    my @unsorted_fields = @{get_control_reg_fields($control_reg)};


    my @sorted_fields = sort { 
      get_control_reg_field_msb($b) <=> get_control_reg_field_msb($a) 
    } @unsorted_fields;

    my @field_exprs = ();

    my $total_sz = 0;

    foreach my $field (@sorted_fields) {
        my $field_name = get_control_reg_field_name($field);
        my $sz = get_control_reg_field_sz($field);
        my $mode = get_control_reg_field_mode($field);

        if ($mode == $MODE_READ_WRITE || $mode == $MODE_READ_ONLY) {

            my $field_expr = "${cs}_${reg_name}_reg_${field_name}";

            my $testbench_expr = 
              get_control_reg_field_testbench_expr($field);


            if ($testbench_version && $testbench_expr) {
                $field_expr = $testbench_expr;
            }

            push(@field_exprs, $field_expr);
        } elsif ($mode == $MODE_WRITE_ONLY || 
                 $mode == $MODE_IGNORED ||
                 $mode == $MODE_RESERVED) {

            push(@field_exprs, "${sz}'d0");
        } elsif ($mode == $MODE_CONSTANT) {

            my $constant_value = 
              get_control_reg_field_constant_value($field);
            push(@field_exprs, "${sz}'d${constant_value}");
        } else {
            return &$error("Unknown mode $mode for" .
              " field $field_name of control register $reg_name");
        }
        
        $total_sz += $sz;
    }

    if ($total_sz != $CONTROL_REG_SZ) {
        return &$error("Total size of all fields for" .
          " control register $reg_name (including reserved fields)" .
          " should be $CONTROL_REG_SZ but is $total_sz");
    }

    my $signal = "${cs}_${reg_name}_reg";
    if ($testbench_version) {
        $signal .= "_tb";
    }

    &$assignment_func({
      lhs => $signal,
      rhs => "{ " . join(", ", @field_exprs) . " }",
      sz => $CONTROL_REG_SZ,
      never_export => get_control_reg_no_rdctl($control_reg)
    });

    return 1;   # Some defined value
}






sub 
gen_rdctl
{
    my $control_regs = shift;       # Reference to array of control regs
    my $assignment_func = shift;
    my $register_func = shift;
    my $binary_mux_func = shift;
    my $rdctl_info = shift;

    $rdctl_stage || return &$error("Missing rdctl_stage");
    $regnum_field || return &$error("Missing regnum_field");

    my $regnum_field_name = get_inst_field_name($regnum_field);
    my $regnum_field_sz = get_inst_field_sz($regnum_field);

    my $cs = $control_reg_stage || return &$error("Missing control_reg_stage");
    if (scalar(@stages) == 0) {
        return &$error("stages array is empty");
    }

    my @control_regs_muxed;
    my $muxed_some_registers_in_any_stage = 0;


    for (my $stage_index = 0; $stage_index < scalar(@stages); $stage_index++) {
        my $stage = $stages[$stage_index];
        my $stage_info = $rdctl_info->{$stage};
        my @control_regs_to_mux;

        if ($stage_info ne "") {
            my $ref_type = ref($stage_info);

            if ($ref_type eq "ARRAY") {


                foreach my $control_reg (@$stage_info) {

                    if ($control_reg eq "") {
                        next;
                    }

                    my $name = get_control_reg_name($control_reg);


                    foreach my $control_reg_muxed (@control_regs_muxed) {
                        if ($control_reg_muxed == $control_reg) {
                            return &$error("Attempt to mux register" .
                              " $name multiple times for RDCTL");
                        }
                    }


                    if (get_control_reg_no_rdctl($control_reg)) {
                        return &$error("Attempt to mux register" .
                          " $name for RDCTL but it doesn't want to be read");
                    }

                    push(@control_regs_to_mux, $control_reg);
                }
            } elsif ($ref_type eq "") {

                if ($stage_info ne "remaining") {
                    return &$error("Stage $stage has unknown string" .
                      " $stage_info\n");
                }


                foreach my $control_reg (@$control_regs) {

                    my $already_muxed = 0;
                    foreach my $control_reg_muxed (@control_regs_muxed) {
                        if ($control_reg_muxed == $control_reg) {
                            $already_muxed = 1;
                        }
                    }

                    if ($already_muxed) {
                        next;
                    }        


                    if (get_control_reg_no_rdctl($control_reg)) {
                        next;
                    }

                    push(@control_regs_to_mux, $control_reg);
                }
            }
        }


        my $muxed_some_registers_in_this_stage = 0;
        my $latest_control_reg_rddata_signal;

        if (scalar(@control_regs_to_mux) > 0) {
            my @mux_table;



            my $include_select = 0;
            my $select_field_name;
            my $select_field_sz;

            if (defined(get_control_reg_max_select(\@control_regs_to_mux))) {
                $include_select = 1;
                $select_field || return &$error("Missing select_field");
                $select_field_name = get_inst_field_name($select_field);
                $select_field_sz = get_inst_field_sz($select_field);
            }

            foreach my $control_reg (@control_regs_to_mux) {
                my $name = get_control_reg_name($control_reg);
                my $num = get_control_reg_num($control_reg);
                my $select = get_control_reg_select($control_reg);


                if (!defined($select)) {
                    $select = "0";
                }


                push(@control_regs_muxed, $control_reg);

                my $lhs = $include_select ?
                  "{ ${regnum_field_sz}'d$num, ${select_field_sz}'d$select }" :
                  "${regnum_field_sz}'d$num";


                push(@mux_table, $lhs => "${cs}_${name}_reg");
            }

            my $default;
            if ($muxed_some_registers_in_any_stage) {


                $default = "${stage}_control_reg_rddata";
            } else {




                my $rdctl_default = optional_scalar($rdctl_info, "default");

                if ($rdctl_default ne "") {
                    $default = $rdctl_default;
                }
            }



            $latest_control_reg_rddata_signal = 
              "${stage}_control_reg_rddata_muxed";

            my $sel_expr =
              $include_select ?
                "{ ${stage}_iw_${regnum_field_name}," .
                  " ${stage}_iw_${select_field_name} }" :
                "${stage}_iw_${regnum_field_name}";

            &$binary_mux_func({
              lhs => $latest_control_reg_rddata_signal,
              sel => $sel_expr,
              sz => $CONTROL_REG_SZ, 
              table => \@mux_table,
              default => $default,
            });

            $muxed_some_registers_in_this_stage = 1;
            $muxed_some_registers_in_any_stage = 1;
        } else {


            $latest_control_reg_rddata_signal = 
              "${stage}_control_reg_rddata";
        }



        if ($stage eq $rdctl_stage) {
            if (!$muxed_some_registers_in_any_stage) {
                return &$error("Reached RDCTL stage $rdctl_stage but" .
                  " no control registers have been muxed yet.");
            }

            &$assignment_func({
              lhs => "${stage}_rdctl_data",
              rhs => $latest_control_reg_rddata_signal,
              sz => $CONTROL_REG_SZ
            });


            last;
        }

        if ($muxed_some_registers_in_any_stage) {

            my $next_stage = $stages[$stage_index+1];

            if ($next_stage eq "") {
                return &$error("Attempt to pipeline to non-existant" .
                  " stage after $stage\n");
            }
            
            &$register_func({
              lhs => "${next_stage}_control_reg_rddata",
              rhs => $latest_control_reg_rddata_signal,
              sz => $CONTROL_REG_SZ,
              en => "${next_stage}_en",
              reset_value => 
            });
        }
    }


    foreach my $control_reg (@$control_regs) {
        my $name = get_control_reg_name($control_reg);

        my $been_muxed = 0;
        foreach my $control_reg_muxed (@control_regs_muxed) {
            if ($control_reg_muxed == $control_reg) {
                $been_muxed = 1;
            }
        }

        my $no_rdctl = get_control_reg_no_rdctl($control_reg);

        if ($been_muxed && $no_rdctl) {
            return &$error("control register" .
              " $name was asked not to be muxed for RDCTL but somehow it was");
        }

        if ($been_muxed || $no_rdctl) {
            next;
        }


        return &$error("control register '$name' never muxed for RDCTL");
    }

    return 1;   # Some defined value
}

1;
