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


























package nios_gen;

use cpu_utils;
use cpu_wave_signals;
use cpu_gen;
use nios_europa;
use nios_avalon_masters;
use nios_brpred;
use nios_common;
use nios_icache;
use nios_dcache;
use nios_div;
use nios_shift_rotate;
use nios_opt;
use europa_all;
use europa_utils;
use strict;










sub
add_to_Opt
{
    my $Opt = shift;
    my $infos = shift;
    my $core_funcs = shift;


    my $get_gen_info_stages_func = 
      manditory_code($core_funcs, "get_gen_info_stages");

    $Opt->{gen_info} = cpu_create_gen_info({
      assignment_func => \&nios_europa_assignment,
      register_func   => \&nios_europa_register,
      binary_mux_func => \&nios_europa_binary_mux,
      sim_wave_text_func => \&nios_europa_sim_wave_text,
      stages          => &$get_gen_info_stages_func(),
    });


    $Opt->{port_list} = ();
    

    nios_avalon_masters::initialize_config_constants($Opt);
    nios_common::initialize_config_constants($Opt);
    nios_brpred::initialize_config_constants($Opt);
    nios_dcache::initialize_config_constants($Opt);
    nios_icache::initialize_config_constants($Opt);
    nios_div::initialize_config_constants(
      manditory_hash($Opt, "divide_info"));
    nios_shift_rotate::initialize_config_constants(
      manditory_hash($Opt, "misc_info"));
}



sub
gen_cpu_logic
{
    my $Opt = shift;
    my $project = shift;
    my $core_funcs = shift;

    my $top_module = $project->top();


    my $make_cpu_func = manditory_code($core_funcs, "make_cpu");
    &$make_cpu_func($Opt, $top_module);

    my $marker = e_default_module_marker->new($top_module);





    cpu_inst_gen::gen_inst_ctrls($Opt->{gen_info}, $Opt->{inst_ctrls},
      $Opt->{inst_desc_info});


    if (manditory_bool($Opt, "advanced_exc")) {
        my $make_exc = $core_funcs->{make_exc};
        if (defined($make_exc)) {
            &$make_exc($Opt);
        } else {
            &$error("Advanced exceptions not supported by CPU implementation '".
              $Opt->{core_type} . "'");
        }
    }


    foreach my $master_name (@{$Opt->{avalon_master_list}}) {
        if (!defined($Opt->{$master_name})) {
            &$error("Missing Opt information for $master_name");
        }
    
        if (!defined($Opt->{$master_name}{port_map})) {
            &$error("Missing port_map information for $master_name");
        }
    
        my $master_args = {
            name     => $master_name,
            type_map => $Opt->{$master_name}{port_map},
        };
    

        if (defined($Opt->{$master_name}{sideband_signals})) {
            $master_args->{sideband_signals} = 
              $Opt->{$master_name}{sideband_signals};
        }
    
        e_avalon_master->add($master_args);
    }
    
    my $port_list = manditory_array($Opt, "port_list");


    e_port->adds(@$port_list);
}

sub
gen_wave_signals
{
    my $Opt = shift;
    my $project = shift;


    my @wave_entries = 
      { divider => "top-level ports" };

    my $port_list = manditory_array($Opt, "port_list");
    foreach my $port_ref (@$port_list) {
        my @port_info = @$port_ref;
        my $signal_name = $port_info[0];

        push(@wave_entries, { radix => "x", signal => $signal_name });
    }


    if ($project->_simgen()) {
        push(@wave_entries, @simgen_wave_signals);
    } else {
        push(@wave_entries, @plaintext_wave_signals);
    }

    gen_wave_signal_do_file(
      not_empty_scalar($Opt, "name"),
      not_empty_scalar($Opt, "simulation_directory"),
      \@wave_entries);
}

1;

