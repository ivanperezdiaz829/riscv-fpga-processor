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






















package cpu_exception_gen;
use Exporter;
@ISA = Exporter;
@EXPORT = qw(
    &new_exc_signal
    &get_exc_signal_name
    &get_exc_nxt_signal_name
    &get_exc_signal_wave
    &new_exc_combo_signal
    &gen_exception_signals
    &gen_exception_cause_code
    &gen_exception_id
    &gen_exception_baddr
);

use cpu_utils;
use cpu_gen;
use cpu_exception;

use strict;














our %exception_signals;




our %speedup_signals;




our %speedup_signal_name_exists;




our %combo_signals;



















sub
new_exc_signal
{
    my $props = shift;

    validate_hash_keys("exc_signal", $props, 
      ["exc","initial_stage","speedup_stage","rhs"]) || return undef;

    my $exc = manditory_hash($props, "exc");
    my $initial_stage = not_empty_scalar($props, "initial_stage");
    my $speedup_stage = optional_scalar($props, "speedup_stage");
    my $rhs = not_empty_scalar($props, "rhs");


    if (get_exc_signal($exc)) {
        my $exc_name = get_exception_name($exc);
        &$error("Exception '$exc_name' already has an exception signal" .
          " associated with it.");
    }


    my $exc_sigs = $exception_signals{$initial_stage};
    if (!$exc_sigs) {
        $exc_sigs = [];
        $exception_signals{$initial_stage} = $exc_sigs;
    }

    my $exc_sig = {
        exc             => $exc,
        initial_stage   => $initial_stage,
        speedup_stage   => $speedup_stage,
        rhs             => $rhs,
    };


    push(@$exc_sigs, $exc_sig);


    return get_exc_signal_name($exc, $initial_stage);
}



sub
new_exc_combo_signal
{
    my $props = shift;

    validate_hash_keys("exc_combo_signal", $props, 
      ["name","stage","include_excs","exclude_excs","higher_pri_than_excs",
       "invalidates_inst_value"]) || return undef;

    my $name = not_empty_scalar($props, "name");
    my $stage = not_empty_scalar($props, "stage");
    my $include_excs = optional_array($props, "include_excs");
    my $exclude_excs = optional_array($props, "exclude_excs");
    my $higher_pri_than_excs = optional_array($props, "higher_pri_than_excs");
    my $invalidates_inst_value = $props->{invalidates_inst_value};

    if ((defined($include_excs) + defined($exclude_excs) + 
      defined($higher_pri_than_excs) + defined($invalidates_inst_value)) > 1) {
        &$error("The include_excs, exclude_excs, higher_pri_than_excs, and" .
          " invalidates_inst_value options to new_exc_combo_signal() are" .
          " mutually exclusive");
    }


    my $combo_sigs = $combo_signals{$stage};
    if (!$combo_sigs) {
        $combo_sigs = [];
        $combo_signals{$stage} = $combo_sigs;
    }

    my $combo_sig = {
        name                    => $name,
        stage                   => $stage,
        include_excs            => $include_excs,
        exclude_excs            => $exclude_excs,
        higher_pri_than_excs    => $higher_pri_than_excs,
        invalidates_inst_value  => $invalidates_inst_value,
    };


    push(@$combo_sigs, $combo_sig);
}


sub
get_exc_signal_name
{
    my $exc = shift;
    my $stage = shift;

    validate_exception($exc);

    my $stageless_signal_name = get_exc_stageless_signal_name($exc);

    return $stage . "_" . $stageless_signal_name;
}



sub
get_exc_nxt_signal_name
{
    my $exc = shift;
    my $stage = shift;

    validate_exception($exc);

    return get_exc_signal_name($exc, $stage) . "_nxt";
}



sub
get_exc_signal_wave
{
    my $exc = shift;
    my $stage = shift;

    validate_exception($exc);

    my $signal_name = get_exc_signal_name($exc, $stage);

    return { radix => "x", signal => $signal_name };
}







sub 
gen_exception_signals
{
    my $gen_info = shift;
    my $exc_stages = shift;

    my $assignment_func = manditory_code($gen_info, "assignment_func");



    my $exc_signals_per_stage = get_exc_signals_per_stage($exc_stages);

    my $previous_stage;
    my @exc_signals_created;


    foreach my $stage (@$exc_stages) {


        foreach my $sig (@{$exception_signals{$stage}}) {
            my $exc = $sig->{exc};
            my $speedup_stage = $sig->{speedup_stage};
            my $initial_stage = $sig->{initial_stage};
            my $rhs = $sig->{rhs};





            my @exc_signal_stages = get_exc_signal_stages($exc_stages, $sig);

            if ($speedup_stage && 
              !grep(/^$speedup_stage$/, @exc_signal_stages)) {
                my $exc_name = get_exception_name($exc);
                &$error("Exception '$exc_name' speedup stage $speedup_stage" .
                  " is before the initial stage $initial_stage");
            }

            my %prioritize_expr;

            my $previous_exc_signal_stage;
    
            foreach my $exc_signal_stage (@exc_signal_stages) {


                if ($exc_signal_stage eq $speedup_stage) {
                    if (!$previous_stage) {
                        &$error("Speedup signal requested for stage $stage" .
                          " but there is no previous stage");
                    }
                    
                    create_speedup_signal($gen_info, $sig, $previous_stage,
                      $stage, $exc_signals_per_stage);
                }











                my $higher_priority_stage =
                  ($exc_signal_stage eq $initial_stage) ?
                      $exc_signal_stage : $previous_exc_signal_stage;



                my @higher_priority_signals = 
                  get_higher_priority_exc_signals($exc, 
                    $exc_signals_per_stage->{$higher_priority_stage});
    




                my @signals_needing_prioritization = 
                  get_remaining_higher_priority_signals($sig, 
                    \@higher_priority_signals);
    


                if (scalar(@signals_needing_prioritization) != 0) {
                    mark_higher_priority_signals($sig, 
                      \@signals_needing_prioritization);




                    my @prioritize_signal_names = 
                      get_signal_names_for_combining(
                        $higher_priority_stage, 
                        \@signals_needing_prioritization);
        

    
                    $prioritize_expr{$exc_signal_stage} = 
                      "~(" . join('|', @prioritize_signal_names) . ")";
    
                }
                    
                $previous_exc_signal_stage = $exc_signal_stage;
            }
    
            my $stageless_name = get_exc_stageless_signal_name($exc);
            my $new_signal_name = $exc_signal_stages[0] . "_" . $stageless_name;
    


            cpu_pipeline_signal($gen_info, 
              { name => $new_signal_name, sz => 1, rhs => $rhs,
                qualify_exprs => \%prioritize_expr, never_export => 1});


            push(@exc_signals_created, $sig);
        }


        foreach my $combo_signal (@{$combo_signals{$stage}}) {



            my @combo_signals;

            foreach my $exc_signal_created (@exc_signals_created) {
                if (defined($combo_signal->{include_excs})) {
                    my $include = 0;
                    foreach my $combo_exc (@{$combo_signal->{include_excs}}) {
                        if ($exc_signal_created->{exc} == $combo_exc) {
                            $include = 1;
                        }
                    }

                    if ($include) {
                        push(@combo_signals, $exc_signal_created);
                    }
                } elsif (defined($combo_signal->{exclude_excs})) {
                    my $exclude = 0;
                    foreach my $combo_exc (@{$combo_signal->{exclude_excs}}) {
                        if ($exc_signal_created->{exc} == $combo_exc) {
                            $exclude = 1;
                        }
                    }

                    if (!$exclude) {
                        push(@combo_signals, $exc_signal_created);
                    }
                } elsif (defined($combo_signal->{higher_pri_than_excs})) {
                    my $higher_pri = 1;
                    foreach my $combo_exc 
                      (@{$combo_signal->{higher_pri_than_excs}}) {
                        if (!is_exception_higher_priority(
                          $exc_signal_created->{exc}, $combo_exc)) {
                            $higher_pri = 0;
                        }
                    }

                    if ($higher_pri) {
                        push(@combo_signals, $exc_signal_created);
                    }
                } elsif (defined($combo_signal->{invalidates_inst_value})) {
                    if (get_exception_invalidates_inst_value($exc_signal_created->{exc})) {
                        push(@combo_signals, $exc_signal_created);
                    }
                } else {

                    push(@combo_signals, $exc_signal_created);
                }
            }




            my @combo_signal_names = 
              get_signal_names_for_combining($stage, \@combo_signals);
   

            &$assignment_func({
              lhs => $combo_signal->{name},
              rhs => join('|', @combo_signal_names),
              sz => 1,
              never_export => 1,
            });
        }

        $previous_stage = $stage;
    }

    return 1;   # Some defined value
}











sub 
gen_exception_cause_code
{
    my $stage = shift;


    my @exception_signals_unsorted;
    foreach my $initial_stage (keys(%exception_signals)) {
        foreach my $sig (@{$exception_signals{$initial_stage}}) {
            if (defined(get_exception_cause_code($sig->{exc}))) {
                push(@exception_signals_unsorted, $sig);
            }
        }
    }


    my @exception_signals_sorted =
      sort { exception_compare_full_priority($a->{exc}, $b->{exc}) } 
      @exception_signals_unsorted;

    my @mux_table;

    my $num_exception_signals = scalar(@exception_signals_sorted);


    for (my $i = 0; $i < ($num_exception_signals-1); $i++) {
        my $a = $exception_signals_sorted[$i];
        my $b = $exception_signals_sorted[$i+1];

        if (exception_compare_full_priority($a->{exc}, $b->{exc}) == 0) {
            my $exc_a_name = get_exception_name($a->{exc});
            my $exc_b_name = get_exception_name($b->{exc});
            return
              &$error("Exception '$exc_a_name' and '$exc_b_name' have the" .
              " same full priority");
        }
    }


    for (my $sig_index = 0; $sig_index < $num_exception_signals; $sig_index++) {
        my $sig = $exception_signals_sorted[$sig_index];
        my $sel_signal = ($sig_index == ($num_exception_signals-1)) ?
          "1" :
          get_exc_signal_name($sig->{exc}, $stage);

        push(@mux_table, $sel_signal => get_exception_cause_code($sig->{exc}));
    }

    return \@mux_table;
}










sub 
gen_exception_id
{
    my $stage = shift;


    my @exception_signals_unsorted;
    foreach my $initial_stage (keys(%exception_signals)) {
        foreach my $sig (@{$exception_signals{$initial_stage}}) {
            push(@exception_signals_unsorted, $sig);
        }
    }


    my @exception_signals_sorted =
      sort { exception_compare_full_priority($a->{exc}, $b->{exc}) } 
      @exception_signals_unsorted;

    my @mux_table;

    my $num_exception_signals = scalar(@exception_signals_sorted);


    for (my $i = 0; $i < ($num_exception_signals-1); $i++) {
        my $a = $exception_signals_sorted[$i];
        my $b = $exception_signals_sorted[$i+1];

        if (exception_compare_full_priority($a->{exc}, $b->{exc}) == 0) {
            my $exc_a_name = get_exception_name($a->{exc});
            my $exc_b_name = get_exception_name($b->{exc});
            return 
              &$error("Exception '$exc_a_name' and '$exc_b_name' have the" .
              " same full priority");
        }
    }


    for (my $sig_index = 0; $sig_index < $num_exception_signals; $sig_index++) {
        my $sig = $exception_signals_sorted[$sig_index];
        my $sel_signal = ($sig_index == ($num_exception_signals-1)) ?
          "1" :
          get_exc_signal_name($sig->{exc}, $stage);

        push(@mux_table, $sel_signal => get_exception_id($sig->{exc}));
    }

    return \@mux_table;
}











sub 
gen_exception_baddr
{
    my $stage = shift;


    my @exception_signals_unsorted;
    foreach my $stage (keys(%exception_signals)) {
        foreach my $sig (@{$exception_signals{$stage}}) {
            if (get_exception_record_addr($sig->{exc}) != $RECORD_NOTHING) {
                push(@exception_signals_unsorted, $sig);
            }
        }
    }


    my @exception_signals_sorted =
      sort { exception_compare_full_priority($a->{exc}, $b->{exc}) } 
      @exception_signals_unsorted;

    my @mux_table;
    my @record_signals;

    my $num_exception_signals = scalar(@exception_signals_sorted);


    for (my $i = 0; $i < ($num_exception_signals-1); $i++) {
        my $a = $exception_signals_sorted[$i];
        my $b = $exception_signals_sorted[$i+1];

        if (exception_compare_full_priority($a->{exc}, $b->{exc}) == 0) {
            my $exc_a_name = get_exception_name($a->{exc});
            my $exc_b_name = get_exception_name($b->{exc});
            &$error("Exception '$exc_a_name' and '$exc_b_name' have the" .
              " same full priority");
        }
    }


    for (my $sig_index = 0; $sig_index < $num_exception_signals; $sig_index++) {
        my $sig = $exception_signals_sorted[$sig_index];
        my $exc_signal_name = get_exc_signal_name($sig->{exc}, $stage);
        my $sel_signal = 
          ($sig_index == ($num_exception_signals-1)) ?  "1" : $exc_signal_name;
        my $addr_signal;

        my $record_addr = get_exception_record_addr($sig->{exc});

        if ($record_addr == $RECORD_TARGET_PCB) {
            $addr_signal = "${stage}_br_jmp_target_pcb";
        } elsif ($record_addr == $RECORD_DATA_ADDR) {
            $addr_signal = "${stage}_mem_baddr";
        } elsif ($record_addr == $RECORD_INST_ADDR) {
            $addr_signal = "${stage}_pcb";
        } else {
            &$error("create_exception_baddr: unknown value of '$record_addr'" .
              " for record_addr");
        }

        push(@mux_table, $sel_signal => $addr_signal);
        push(@record_signals, $exc_signal_name);
    }

    return (\@mux_table, \@record_signals);
}







sub
get_exc_signals_per_stage
{
    my $exc_stages = shift;



    my %exc_signals_per_stage;


    foreach my $stage (@$exc_stages) {
        $exc_signals_per_stage{$stage} = [];
    }




    foreach my $stage (keys(%exception_signals)) {
        foreach my $sig (@{$exception_signals{$stage}}) {
            my @exc_signal_stages = 
              get_exc_signal_stages($exc_stages, $sig);

            foreach my $exc_signal_stage (@exc_signal_stages) {
                push(@{$exc_signals_per_stage{$exc_signal_stage}}, $sig);
            }
        }
    }

    return \%exc_signals_per_stage;
}




sub
get_exc_signal_stages
{
    my $exc_stages = shift;
    my $sig = shift;

    my @stages;
    my $append_stages = 0;

    foreach my $stage (@$exc_stages) {
        if ($stage eq $sig->{initial_stage}) {
            $append_stages = 1;
        }

        if ($append_stages) {
            push(@stages, $stage);
        }
    }

    if (scalar(@stages) == 0) {
        my $exc_name = get_exception_name($sig->{exc});
        &$error("Exception '$exc_name' associated with a non-existant" .
          " initial stage $sig->{initial_stage}");
    }

    return @stages;
}



sub
get_higher_priority_exc_signals
{
    my $exc = shift;
    my $signals_this_stage = shift;

    validate_exception($exc);

    my @higher_priority_exc_signals;

    if ($signals_this_stage) {
        foreach my $es (@$signals_this_stage) {
            if (is_exception_higher_priority($es->{exc}, $exc)) {
                push(@higher_priority_exc_signals, $es);
            }
        }
    }

    return @higher_priority_exc_signals;
}




sub
get_remaining_higher_priority_signals
{
    my $sig = shift;
    my $higher_priority_signals_ref = shift;

    my @signals_needing_prioritization;     # return value


    my $prioritized_excs = $sig->{prioritized_excs};
    if (!$prioritized_excs) {
        $prioritized_excs = {};
        $sig->{prioritized_excs} = $prioritized_excs;
    }



    foreach my $higher_priority_signal (@$higher_priority_signals_ref) {
        my $exc = $higher_priority_signal->{exc};

        if (!$prioritized_excs->{$exc}) {
            push(@signals_needing_prioritization, $higher_priority_signal);
        }
    }

    return @signals_needing_prioritization;
}



sub
mark_higher_priority_signals
{
    my $sig = shift;
    my $signals_needing_prioritization_ref = shift;

    my $prioritized_excs = $sig->{prioritized_excs};

    foreach my $other_sig (@$signals_needing_prioritization_ref) {
        my $exc = $other_sig->{exc};

        $prioritized_excs->{$exc} = 1;
    }
}
    


sub
create_speedup_signal
{
    my $gen_info = shift;
    my $sig = shift;
    my $previous_stage = shift;
    my $current_stage = shift;
    my $exc_signals_per_stage = shift;

    my $exc = $sig->{exc};


    my @prev_higher_priority_signals = get_higher_priority_exc_signals($exc, 
      $exc_signals_per_stage->{$previous_stage});
  


    my @signals_needing_prioritization = 
      get_remaining_higher_priority_signals($sig, 
        \@prev_higher_priority_signals);
 

    if (scalar(@signals_needing_prioritization) == 0) {
        return;
    }


    my @speedup_excs = map { $_->{exc} } @signals_needing_prioritization;


    my $speedup_signal = {
         excs    => \@speedup_excs,
    };




    my @prioritize_signal_names = get_signal_names_for_combining(
      $previous_stage, \@signals_needing_prioritization);


    if (scalar(@prioritize_signal_names) <= 1) {
        return;
    }

    my $current_signal_name = 
      get_speedup_signal_name($current_stage, $speedup_signal);

    if ($speedup_signal_name_exists{$current_signal_name}) {

        return;
    }

    my $rhs = join('|', @prioritize_signal_names);
    my $stageless_signal_name = 
      get_speedup_stageless_signal_name($speedup_signal);

    my $new_signal_name = $previous_stage . "_" . $stageless_signal_name;



    cpu_pipeline_signal($gen_info, 
      { name => $new_signal_name, sz => 1, rhs => $rhs,
        stages => [$previous_stage, $current_stage], never_export => 1});



    my $speedup_signals_current_stage = $speedup_signals{$current_stage};
    if (!$speedup_signals_current_stage) {
        $speedup_signals_current_stage = [];
        $speedup_signals{$current_stage} = $speedup_signals_current_stage;
    }


    push(@$speedup_signals_current_stage, $speedup_signal);

    $speedup_signal_name_exists{$current_signal_name} = 1;
}




sub
get_signal_names_for_combining
{
    my $stage = shift;
    my $signals_needing_combining_ref = shift;

    my @signals_needing_combining = @$signals_needing_combining_ref;

    my @combo_signal_names;        # Return value




    my @candidate_speedup_signals;




    foreach my $speedup_signal (@{$speedup_signals{$stage}}) {

        my @excs;

        my $all_speedup_excs_need_combining = 1;

        foreach my $speedup_exc (@{$speedup_signal->{excs}}) {
            my $exc_needs_combining = 0;

            foreach my $signal_needing_combining 
              (@signals_needing_combining) {
                if ($speedup_exc == $signal_needing_combining->{exc}) {
                    $exc_needs_combining = 1;
                }
            }

            if ($exc_needs_combining) {
                push(@excs, $speedup_exc);
            } else {


                $all_speedup_excs_need_combining = 0;
            }
        }

        if ((scalar(@excs) > 0) && $all_speedup_excs_need_combining) {
            push(@candidate_speedup_signals, {
              speedup_signal => $speedup_signal,
              excs            => \@excs,
            });
        }
    }








    my @sorted_candidate_speedup_signals =
      sort { scalar($b->{excs}) <=> scalar($a->{excs}) }
      @candidate_speedup_signals;

    foreach my $candidate_speedup_signal (@sorted_candidate_speedup_signals) {
        my $speedup_signal = $candidate_speedup_signal->{speedup_signal};
        my @excs = @{$candidate_speedup_signal->{excs}};

        my @signals_needing_combining_nxt;
        my $speedup_used = 0;





        foreach my $signal_needing_combining (@signals_needing_combining) {
            my $combined_by_speedup = 0;

            foreach my $speedup_exc (@excs) {
                if ($speedup_exc == $signal_needing_combining->{exc}) {
                    $combined_by_speedup = 1;
                    $speedup_used = 1;
                }
            }

            if (!$combined_by_speedup) {
                push(@signals_needing_combining_nxt, 
                  $signal_needing_combining);
            }
        }

        if ($speedup_used) {


            push(@combo_signal_names, 
              get_speedup_signal_name($stage, $speedup_signal));
        }

        @signals_needing_combining = @signals_needing_combining_nxt;
    }



    foreach my $signal_needing_combining (@signals_needing_combining) {
        push(@combo_signal_names, 
          get_exc_signal_name($signal_needing_combining->{exc}, $stage));
    }

    return @combo_signal_names;
}


sub
get_exc_stageless_signal_name
{
    my $exc = shift;

    validate_exception($exc);

    my $exc_name = get_exception_name($exc);
    my $exc_priority = get_exception_priority($exc);

    return "exc_" . $exc_name . "_pri" . $exc_priority;
}


sub
get_speedup_signal_name
{
    my $stage = shift;
    my $speedup_signal = shift;

    return $stage . "_" . get_speedup_stageless_signal_name($speedup_signal);
}


sub
get_speedup_stageless_signal_name
{
    my $speedup_signal = shift;


    my @sorted_excs = 
      sort { get_exception_id($a) <=> get_exception_id($b) }
      @{$speedup_signal->{excs}};

    my $suffix;
    
    $suffix .= "_id";
    foreach my $exc (@sorted_excs) {
        $suffix .= "_" . get_exception_id($exc);
    }

    $suffix .= "_pri";
    foreach my $exc (@sorted_excs) {
        $suffix .= "_" . get_exception_priority($exc);
    }

    return "exc_speedup" . $suffix;
}



sub
get_exc_signal
{
    my $desired_exc = shift;

    foreach my $stage (keys(%exception_signals)) {
        foreach my $sig (@{$exception_signals{$stage}}) {
            if ($sig->{exc} == $desired_exc) {
                return $sig;
            }
        }
    }

    return undef;
}

1;
