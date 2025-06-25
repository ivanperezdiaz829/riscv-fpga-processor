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






















package cpu_inst_gen;
use Exporter;
@ISA = Exporter;
@EXPORT = qw(
    &set_inst_ctrl_initial_stage
    &get_inst_ctrl_initial_stage
);

use cpu_utils;
use cpu_gen;
use cpu_inst_field;
use cpu_inst_desc;
use cpu_inst_ctrl;
use strict;






















sub 
gen_inst_fields
{
    my $gen_info = shift;
    my $inst_field_info = shift;
    my $stages = shift;                 # Manditory array of stage names

    my $assignment_func = manditory_code($gen_info, "assignment_func");

    foreach my $stage (@$stages) {
        foreach my $inst_field (@{$inst_field_info->{inst_fields}}) {
            my $field_name = get_inst_field_name($inst_field);
            my $msb = get_inst_field_msb($inst_field);
            my $lsb = get_inst_field_lsb($inst_field);
            my $sz = get_inst_field_sz($inst_field);

            &$assignment_func({
              lhs => "${stage}_iw_${field_name}",
              rhs => "${stage}_iw[$msb:$lsb]",
              sz => $sz,
              never_export => 1,
            });
        }

        my $extra_gen_func = $inst_field_info->{extra_gen_func};
        my $extra_gen_func_arg = $inst_field_info->{extra_gen_func_arg};
        if (defined($extra_gen_func)) {
            if (ref($extra_gen_func) ne "CODE") {
                return &$error("Expecting code reference for extra_gen_func" .
                  " but ref() returns '" . ref($extra_gen_func) . "'");
            }

            &$extra_gen_func($gen_info, $extra_gen_func_arg, $stage);
        }
    }

    return 1;   # Some defined value
}









sub 
gen_inst_decodes
{
    my $gen_info = shift;
    my $inst_desc_info = shift;
    my $stages = shift;
    my $create_register_stages = shift; # Optional array of stages for regs
    my $extra_create_register_stages = shift; # Optional array of stages
    my $reserved_stages = shift; # Optional array of stages

    my $assignment_func = manditory_code($gen_info, "assignment_func");
    my $register_func = manditory_code($gen_info, "register_func");

    my $previous_stage;

    foreach my $stage (@$stages) {


        my $create_register_this_stage = 0;
        if (defined($create_register_stages)) {
            foreach my $create_register_stage (@$create_register_stages) {
                if ($stage eq $create_register_stage) {
                    $create_register_this_stage = 1;
    
                    if (!defined($previous_stage)) {
                        return &$error("Asked to create registers for stage" .
                          " '$stage' but there is no previous stage");
                    }
                }
            }
        }

        my $create_reserved_this_stage;
        if (defined($reserved_stages)) {
            foreach my $reserved_stage (@$reserved_stages) {
                if ($stage eq $reserved_stage) {
                    $create_reserved_this_stage = 1;
                }
            }
        } else {

            $create_reserved_this_stage = 1;
        }

        foreach my $inst_desc (@{$inst_desc_info->{inst_descs}}) {


            if (!$create_reserved_this_stage) {
                if (
                  get_inst_desc_mode($inst_desc) == $INST_DESC_RESERVED_MODE) {
                    next;
                }
            }

            my $inst_name = get_inst_desc_name($inst_desc);
            my $lhs = "${stage}_op_${inst_name}";



            if ($create_register_this_stage) {
                &$register_func({
                  lhs => $lhs,
                  rhs => "${previous_stage}_op_${inst_name}",
                  sz => 1,
                  en => $stage . "_en",
                  never_export => 1,
                });
            } else {
                my $v_decode_func = get_inst_desc_v_decode_func($inst_desc);
                my $decode_arg = get_inst_desc_decode_arg($inst_desc);
                my $rhs = &$v_decode_func($decode_arg, $inst_desc, $stage);
    
                if (!defined($rhs)) {
                    return &$error(
                      "No expression provided to decode instruction" .
                        " '$inst_name'");
                }
        
                &$assignment_func({
                  lhs => $lhs,
                  rhs => $rhs,
                  sz => 1,
                  never_export => 1,
                });
            }
        }

        my $extra_gen_func = optional_code($inst_desc_info, "extra_gen_func");
        if (defined($extra_gen_func)) {
            my $extra_gen_func_arg = $inst_desc_info->{extra_gen_func_arg};

            my $extra_create_register_this_stage = 0;
            my $first_stage_with_register;
            if (defined($extra_create_register_stages)) {
                $first_stage_with_register = 
                  $extra_create_register_stages->[0];

                foreach my $extra_create_register_stage (
                  @$extra_create_register_stages) {
                    if ($stage eq $extra_create_register_stage) {
                        $extra_create_register_this_stage = 1;
        
                        if (!defined($previous_stage)) {
                            return 
                              &$error("Asked to create registers for stage" .
                              " '$stage' but there is no previous stage");
                        }
                    }
                }
            }


            &$extra_gen_func($gen_info, $extra_gen_func_arg, $stage,
              $extra_create_register_this_stage, $previous_stage,
              $first_stage_with_register);
        }

        $previous_stage = $stage;
    }

    return 1;   # Some defined value
}










sub 
create_sim_wave_inst_names
{
    my $gen_info = shift;
    my $inst_desc_info = shift;
    my $stages = shift;

    my $sim_wave_text_func = manditory_code($gen_info, "sim_wave_text_func");


    my $allowed_modes = [];
    foreach my $inst_desc_mode (@{get_all_inst_desc_modes()}) {
        if ($inst_desc_mode != $INST_DESC_RESERVED_MODE) {
            push(@$allowed_modes, $inst_desc_mode);
        }
    }


    my $inst_descs = get_inst_descs_by_modes(
      manditory_array($inst_desc_info, "inst_descs"), $allowed_modes);

    my $max_name_length = get_inst_desc_max_name_length($inst_descs);

    foreach my $stage (@$stages) {
        my @table;  # Array of hash references with name/decode_expr strings

        foreach my $inst_desc (@$inst_descs) {
            my $inst_name = get_inst_desc_name($inst_desc);

            push(@table, { 
               name         => $inst_name,
               decode_expr  => "${stage}_op_${inst_name}",
            });
        }


        &$sim_wave_text_func({
          lhs           => "${stage}_inst",
          table         => \@table,
          sz            => ($max_name_length*8),
          default_name  => "RSV",
          never_export  => 1,
        });
    }

    return 1;   # Some defined value
}






















sub 
create_sim_wave_vinst_names
{
    my $gen_info = shift;
    my $inst_desc_info = shift;
    my $stages = shift;
    my $inst_signal_names = shift;
    my $valid_signal_names = shift;

    my $assignment_func = manditory_code($gen_info, "assignment_func");

    my $inst_descs = $inst_desc_info->{inst_descs};
    my $max_name_length = get_inst_desc_max_name_length($inst_descs);

    foreach my $stage (@$stages) {

        my $inst_signal_name = 
          $inst_signal_names->{$stage} || "${stage}_inst";


        my $valid_signal_name = 
          $valid_signal_names->{$stage} || "${stage}_valid";


        &$assignment_func({
          lhs => "${stage}_vinst",
          rhs => "$valid_signal_name ? $inst_signal_name" .
            " : {${max_name_length}\{8'h2d}}",
          sz => ($max_name_length*8),
          never_export => 1,
          simulation => 1,
        });
    }

    return 1;   # Some defined value
}




sub
set_inst_ctrl_initial_stage
{
    my $inst_ctrl = shift;
    my $initial_stage = shift;

    if (!defined(validate_inst_ctrl($inst_ctrl))) {
        return undef;
    }

    if ($inst_ctrl->{initial_stage} ne "") {
        return &$error("Attempt to set initial_stage of instruction control '" .
          get_inst_ctrl_name($inst_ctrl) . "' to '$initial_stage' when it is" .
          " already set to '" . $inst_ctrl->{initial_stage} . "'");
    }

    if ($initial_stage eq "") {
        return &$error("Attempt to set initial_stage of instruction control '" .
          get_inst_ctrl_name($inst_ctrl) . "' to empty value");
    }

    $inst_ctrl->{initial_stage} = $initial_stage;

    return 1;   # Some defined value
}


sub
get_inst_ctrl_initial_stage
{
    my $inst_ctrl = shift;

    if (!defined(validate_inst_ctrl($inst_ctrl))) {
        return undef;
    }

    return $inst_ctrl->{initial_stage};
}










sub 
gen_inst_ctrls
{
    my $gen_info = shift;
    my $inst_ctrls = shift;
    my $inst_desc_info = shift;

    my $all_inst_descs = $inst_desc_info->{inst_descs};

    foreach my $inst_ctrl (@$inst_ctrls) {
        my $initial_stage = get_inst_ctrl_initial_stage($inst_ctrl);


        if ($initial_stage eq "") {
            next;
        }



        my $expanded_inst_descs = [];
        if (!defined(expand_ctrl_insts($inst_ctrls, $inst_ctrl, 
          $all_inst_descs, $expanded_inst_descs))) {
            return undef;
        }



        my $filtered_inst_descs = get_inst_descs_by_modes(
          $expanded_inst_descs, get_inst_ctrl_allowed_modes($inst_ctrl));



        my $ctrl_op_signal_names = [];
        foreach my $ctrl_inst_desc (@$filtered_inst_descs) {
            push(@$ctrl_op_signal_names, 
              $initial_stage . "_op_" . get_inst_desc_name($ctrl_inst_desc));
        }


        my $rhs;

        if (scalar(@$ctrl_op_signal_names) < 8) {

            $rhs = join('|', @$ctrl_op_signal_names);
        } else {

            $rhs = join('|
  ', @$ctrl_op_signal_names);
        }



        if (defined(get_inst_ctrl_v_expr_func($inst_ctrl))) {
            if ($rhs eq "") {
                $rhs = &{get_inst_ctrl_v_expr_func($inst_ctrl)}($initial_stage);
            } else {
                $rhs = "(" . $rhs . ") " . 
                  &{get_inst_ctrl_v_expr_func($inst_ctrl)}($initial_stage);
            }
        }

        my $new_signal_name = 
          $initial_stage . "_ctrl_" . get_inst_ctrl_name($inst_ctrl);
        

        if (!defined(cpu_pipeline_signal($gen_info, { 
          name          => $new_signal_name, 
          sz            => 1, 
          rhs           => $rhs, 
          never_export  => 1,
        }))) {
            return undef;
        }
    }

    return 1;   # Some defined value
}



sub
expand_ctrl_insts
{
    my $inst_ctrls = shift;
    my $inst_ctrl = shift;
    my $all_inst_descs = shift;
    my $expanded_inst_descs = shift;


    foreach my $inst_name (@{get_inst_ctrl_insts($inst_ctrl)}) {

        if (defined(
          get_inst_desc_by_name_or_undef($expanded_inst_descs, $inst_name))) {
            next;
        }


        my $inst_desc = get_inst_desc_by_name($all_inst_descs, $inst_name);
        if (!defined($inst_desc)) {
            return undef;
        }


        push(@$expanded_inst_descs, $inst_desc);
    }


    foreach my $other_ctrl_name (@{get_inst_ctrl_ctrls($inst_ctrl)}) {
        my $other_inst_ctrl = 
          get_inst_ctrl_by_name($inst_ctrls, $other_ctrl_name);
        if (!defined($other_inst_ctrl)) {
            return undef;
        }


        if (!defined(expand_ctrl_insts($inst_ctrls, $other_inst_ctrl, 
          $all_inst_descs, $expanded_inst_descs))) {
            return undef;
        }
    }

    return 1;   # Some defined value
}





1;
