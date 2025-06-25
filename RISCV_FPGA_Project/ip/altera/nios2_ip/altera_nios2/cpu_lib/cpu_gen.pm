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






















package cpu_gen;
use Exporter;
@ISA = Exporter;
@EXPORT = qw(
    &cpu_create_gen_info
    &cpu_pipeline_signal
    &cpu_pipeline_control_signal
);

use cpu_utils;
use strict;












sub
cpu_create_gen_info
{
    my $args = shift;

    validate_hash_keys("gen_info", $args, 
      ["assignment_func","register_func","binary_mux_func",
       "sim_wave_text_func","stages"]) || return undef;

    my $assignment_func = manditory_code($args, "assignment_func");
    my $register_func = manditory_code($args, "register_func");
    my $binary_mux_func = manditory_code($args, "binary_mux_func");
    my $sim_wave_text_func = manditory_code($args, "sim_wave_text_func");
    my $stages = manditory_array($args, "stages");

    return {
      assignment_func => $assignment_func,
      register_func   => $register_func,
      binary_mux_func => $binary_mux_func,
      sim_wave_text_func => $sim_wave_text_func,
      stages          => $stages,
    };
}






















sub 
cpu_pipeline_signal
{
    my $gen_info = shift;
    my $props = shift;

    validate_hash_keys("pipeline_signal", $props, 
      ["name","sz","rhs","stages","until_stage","qualify_exprs","never_export"])
      || return undef;

    my $assignment_func = manditory_code($gen_info, "assignment_func");
    my $register_func = manditory_code($gen_info, "register_func");

    my $name = not_empty_scalar($props, "name");
    if (!defined($name)) {
        return undef;
    }
    my $sz = manditory_int($props, "sz");
    if (!defined($sz)) {
        return undef;
    }
    my $err = 0;
    my $rhs = optional_scalar($props, "rhs", \$err);
    if ($err) {
        return undef;
    }
    my $stages = optional_array($props, "stages");
    if (!defined($stages)) {

        $stages = manditory_array($gen_info, "stages");
    }

    my $num_stages = scalar(@$stages);
    if ($num_stages == 0) {
        return &$error("Empty list of stages for signal '$name'.");
    }

    my $until_stage = optional_scalar($props, "until_stage");
    if (defined($until_stage)) {

        my $until_stage_is_known = 0;
        foreach my $stage (@$stages) {
            if ($stage eq $until_stage) {
                $until_stage_is_known = 1;
            }
        }

        if (!$until_stage_is_known) {
            return 
              &$error("The until_stage of '$until_stage' for signal '$name' doesn't exist.");
        }
    } else {

        my $until_stage = $stages->[$num_stages - 1];
    }

    my $qualify_exprs = optional_hash($props, "qualify_exprs");
    my $never_export = optional_bool($props, "never_export");




    my $initial_stage;
    my $stageless_name;
    my @later_stages;
    foreach my $stage (@$stages) {
        if (defined($initial_stage)) {
            push(@later_stages, $stage);
        } else {
            if ($name =~ /^${stage}_(.*)$/) {
                $initial_stage = $stage;
                $stageless_name = $1;
            }
        }


        if ($stage eq $until_stage) {
            last;
        }
    }
    if (!defined($initial_stage)) {
        return 
          &$error("Can't find stage prefix for signal '$name'");
    }

    if (defined($rhs)) { 


        my $rhs_empty = ($rhs =~ /^\s*$/);
        if ($rhs_empty) {
            $rhs = "${sz}'b0";
        } else {
            $rhs = add_qualify_expr($qualify_exprs, $initial_stage, $rhs);
        }
    

        &$assignment_func({
          lhs => $name,
          rhs => $rhs,
          sz => $sz,
          never_export => $never_export,
        });
    }


    my $previous_stage = $initial_stage;
    foreach my $stage (@later_stages) {
        my $regname = $stage . "_" . $stageless_name;
        my $regname_nxt = $regname . "_nxt";
        my $inputname = $previous_stage . "_" . $stageless_name;

        &$assignment_func({
          lhs => $regname_nxt,
          rhs => add_qualify_expr($qualify_exprs, $stage, $inputname),
          sz => $sz,
          never_export => $never_export,
        });

        &$register_func({
          lhs => $regname,
          rhs => $regname_nxt,
          sz => $sz,
          en => $stage . "_en",
          never_export => $never_export,
        });

        $previous_stage = $stage;
    }

    return 1;   # Some defined value
}










sub 
cpu_pipeline_control_signal
{
    my $gen_info = shift;
    my $stageless_name = shift;
    my $stages = shift;
    my $rhs = shift;
    my $qualify_exprs = shift;

    my $initial_name = ${$stages}[0] . "_" . $stageless_name;

    return cpu_pipeline_signal($gen_info, {
      name => $initial_name,
      sz => 1,
      rhs => $rhs,
      stages => $stages,
      qualify_exprs => $qualify_exprs,
      never_export => 1,
    });
}







sub
add_qualify_expr
{
    my $qualify_exprs = shift;
    my $stage = shift;
    my $expr = shift;

    if ($qualify_exprs) {
        my $qualified_expr = $qualify_exprs->{$stage};

        if ($qualified_expr) {

            return "(" . $expr . ") & (" . $qualified_expr . ")";
        }
    }

    return $expr;   # Just return the original expression.
}

1;
