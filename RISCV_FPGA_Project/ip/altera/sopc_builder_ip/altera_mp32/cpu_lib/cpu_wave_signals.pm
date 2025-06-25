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


























package cpu_wave_signals;
use Exporter;
@ISA = Exporter;
@EXPORT = qw(
    @plaintext_wave_signals
    @simgen_wave_signals
    &gen_wave_signal_do_file
);

use cpu_utils;
use strict;






our @plaintext_wave_signals;
our @simgen_wave_signals;










sub 
gen_wave_signal_do_file
{
    my $name = shift;                   # Module instance name
    my $simulation_directory = shift;   # Path to RTL simulation testbench dir
    my $wave_entries = shift;           # Array of signals/dividers

    assert_array_ref($wave_entries, "wave_entries") || return undef;

    unless (-d $simulation_directory) {
        return &$error("Can't find RTL simulation directory" .
          " '$simulation_directory'");
    }

    my $do_fname = $simulation_directory . "/" . $name . "_nios2_waves.do";

    &$progress("  Creating '$do_fname'");

    unlink($do_fname);

    if (!open(DO_FD, ">$do_fname")) {
        return &$error("Can't open '$do_fname' for writing\n");
    }

    foreach my $wave_entry (@$wave_entries) {

        if ($wave_entry eq "") {
            next;
        }

        my $str = "add wave -noupdate";

        if (defined($wave_entry->{divider})) {
            my $divider = $wave_entry->{divider};

            $str .= " -divider {" . $name . ": " . $divider . "}";
        } else {
            my $signal = not_empty_scalar($wave_entry, "signal") || 
              return undef;
            my $radix = not_empty_scalar($wave_entry, "radix") || 
              return undef;

            my $radix_str;
            if ($radix eq "d") {
                $radix_str = "decimal";
            } elsif ($radix eq "x") {
                $radix_str = "hexadecimal";
            } elsif ($radix eq "b") {
                $radix_str = "binary";
            } elsif ($radix eq "a") {
                $radix_str = "ascii";
            } else {
                return 
                  &$error("Bad radix type of '$radix' for signal '$signal'");
            }

            $str .= (
              " -format Logic -radix $radix_str" .
              " /NIOS2_INSTANCE_TOP/$signal"
            );
        }

        print DO_FD $str, "\n";
    }

    print DO_FD "\n";
    print DO_FD "configure wave -justifyvalue right\n";
    print DO_FD "configure wave -signalnamewidth 1\n";
    print DO_FD "TreeUpdate [SetDefaultTree]\n";

    close(DO_FD);

    return 1;   # Return some defined value
}





sub
get_project_info
{
    my $project = shift;

    my $info = {};    # Anonymous hash reference loaded with all info

    $info->{name} = $project->_target_module_name();
    $info->{do_build_sim} = $project->SYS_WSA()->{do_build_sim};
    $info->{system_directory} = $project->_system_directory();
    $info->{simulation_directory} = $project->simulation_directory();
    $info->{module_lib_directory} = $project->_module_lib_dir();
    $info->{language} = $project->language();
    $info->{clock_frequency} = $project->get_module_clock_frequency();
    $info->{copyright_notice} = $project->global_copyright_notice();
    $info->{is_hardcopy_compatible} = $project->is_hardcopy_compatible();
    $info->{translate_off} = $project->_translate_off();
    $info->{translate_on} = $project->_translate_on();
    $info->{quartus_translate_off} = $project->_quartus_translate_off();
    $info->{quartus_translate_on} = $project->_quartus_translate_on();
    $info->{asic_enabled} = $project->asic_enabled;
    $info->{asic_third_party_synthesis} = 
      $project->asic_third_party_synthesis();

    return $info;
}

sub
get_misc_info
{
    my $project = shift;

    my $local_info = {};    # Don't want these to be returned.

    my $info = {};    # Anonymous hash reference loaded with all info

    copy_from_wsa($project, $info, {
      big_endian                    => 0,
      be8                           => 0,
      altium_jtag                   => 0,
      export_pcb                    => 0,
      shift_rot_impl                => undef,
      num_shadow_reg_sets           => 0,
      export_large_RAMs             => 0,
      use_designware                => 0,
    });

    return $info;
}

sub
get_icache_info
{
    my $project = shift;

    my $info = {};    # Anonymous hash reference loaded with all info

    copy_from_wsa($project, $info, {
      cache_has_icache              => undef,
    });

    if (manditory_bool($info, "cache_has_icache")) {
        copy_from_wsa($project, $info, {
          cache_icache_size             => undef,
          cache_icache_line_size        => undef,
          cache_icache_burst_type       => "none",
          cache_icache_ram_block_type   => "AUTO",
          cache_icache_allow_tag_wrt    => 0,
        });
    }

    return $info;
}

sub
get_dcache_info
{
    my $project = shift;

    my $info = {};    # Anonymous hash reference loaded with all info

    copy_from_wsa($project, $info, {
      cache_has_dcache              => undef,
    });

    if (manditory_bool($info, "cache_has_dcache")) {
        copy_from_wsa($project, $info, {
          cache_dcache_size             => undef,
          cache_dcache_line_size        => undef,
          cache_dcache_bursts           => "none",
          cache_dcache_ram_block_type   => "AUTO",
          cache_dcache_allow_tag_wrt    => 0,
        });
    }

    return $info;
}

sub
get_divide_info
{
    my $project = shift;

    my $info = {};    # Anonymous hash reference loaded with all info

    copy_from_wsa($project, $info, {
      hardware_divide_present       => undef,
      hardware_divide_impl          => "variable_latency",
    });

    return $info;
}

sub
get_device_info
{
    my $project = shift;

    my $info = {};    # Anonymous hash reference loaded with all info

    copy_from_wsa($project, $info, {
      dsp_block_supports_shift      => 0,
      address_stall_present         => 0,
      mrams_present                 => 0,
    });

    if ($project->device_family() eq "") {
        &$error("Missing device_family in Europa project object");
    }

    $info->{device_family} = $project->device_family();

    return $info;
}



sub
get_avalon_master_info
{
    my $project = shift;

    my $info = {};    # Anonymous hash reference loaded with all master info

    my $module_name = $project->_target_module_name();




    my %avalon_masters = ();


    my @enabled_masters = $project->get_masters_by_module_name($module_name);


    foreach my $master_name (@enabled_masters) {
        my $sbi = $project->spaceless_system_ptf()->{MODULE}
          {$module_name}{MASTER}{$master_name}{SYSTEM_BUILDER_INFO};


        if (!is_avalon_master($project, $master_name)) {
            next;
        }

        my $avalon_master = {};

        if ($sbi->{Is_Instruction_Master}) {
            $avalon_master->{type} = "instruction";
        } elsif ($sbi->{Is_Data_Master}) {
            $avalon_master->{type} = "data";
        } else {
            &$error("Master $master_name isn't a data or instruction" .
              " Avalon master");
        }

        if ($sbi->{Is_Channel}) {


            $avalon_master->{is_tcm} = 1;

            my $master_id = $module_name . "/" . $master_name;
            my @slave_ids = $project->get_slaves_by_master_name($master_id);
            if (scalar(@slave_ids) != 1) {
                &$error("Master $master_name must be connected to only" .
                  " one slave");
            }
    
            validate_tightly_coupled_slave($project, $slave_ids[0], 
              $master_name, $avalon_master->{type});
        } else {
            $avalon_master->{is_tcm} = 0;
        }

        my $master_desc = join("/", $module_name, $master_name);

        ($avalon_master->{paddr_base}, $avalon_master->{paddr_top}) =
          s_avalon_slave_arbitration_module->
            get_address_range_of_slaves_by_master($master_desc, $project);

        $avalon_masters{$master_name} = $avalon_master;
    }

    $info->{avalon_masters} = \%avalon_masters;

    return $info;
}

sub
get_brpred_info
{
    my $project = shift;
    my $misc_info = shift;

    my $info = {};    # Anonymous hash reference loaded with all info

    copy_from_wsa($project, $info, {
      branch_prediction_type        => "",
      bht_ptr_sz                    => 8,
      bht_index_pc_only             => 0,
    });

    return $info;
}

sub
get_test_info
{
    my $project = shift;

    my $info = {};    # Anonymous hash reference loaded with all info

    copy_from_wsa($project, $info, {
      activate_model_checker        => 0,
      activate_monitors             => 1,
      activate_trace                => 1,
      activate_test_end_checker     => 0,
      always_bypass_dcache          => 0,
      always_encrypt                => 1,
      bit_31_bypass_dcache          => 1,
      clear_x_bits_ld_non_bypass    => 1,
      debug_simgen                  => 0,
      full_waveform_signals         => 0,
      hbreak_test                   => 0,
      hdl_sim_caches_cleared        => 1,
      performance_counters_present  => 0,
      performance_counters_width    => 32,
    });

    return $info;
}


sub 
validate_tightly_coupled_slave
{
    my ($project, $slave_id, $master_name, $master_type) = @_;

    my $msg = "Incompatible slave $slave_id connected to" .
      " tightly-coupled master $master_name: ";

    my $slave_SBI = $project->SBI($slave_id) ||
      &$error("Can't find SBI section for $slave_id");

    my $read_wait_states = $slave_SBI->{Read_Wait_States};
    my $read_latency = $slave_SBI->{Read_Latency};


    $read_wait_states =~ s/\s*cycles$//;
    $read_latency =~ s/\s*cycles$//;

    if ($slave_SBI->{Is_Channel} ne "1") {
        &$error($msg . "Not a channel-compatible slave");
    }
    if ($slave_SBI->{Data_Width} ne "32") {
        &$error($msg . "Data_Width must be 32 bits");
    }
    if ($read_wait_states ne "0") {
        &$error($msg . "Read_Wait_States must be 0.  It is '" .
          $slave_SBI->{Read_Wait_States} . "'.");
    }
    if ($read_latency ne "1") {
        &$error($msg . "Read_Latency must be 1.  It is '". 
          $slave_SBI->{Read_Latency} . "'.");
    }



    if ($master_type eq "data") {
        my $write_wait_states = $slave_SBI->{Write_Wait_States};
        my $write_wait_latency = $slave_SBI->{Write_Wait_Latency};


        $write_wait_states =~ s/\s*cycles$//;
        $write_wait_latency =~ s/\s*cycles$//;

        if ($write_wait_states ne "0") {
            &$error($msg . "Write_Wait_States must be 0. It is '" .
              $slave_SBI->{Write_Wait_States} . "'.");
        }
        if (defined($slave_SBI->{Write_Wait_Latency}) && 
          ($write_wait_latency ne "0")) {
            &$error($msg . "Write_Wait_Latency must be 0. It is '" .
              $slave_SBI->{Write_Wait_Latency} . "'.");
        }
    }


    my $masters_ref = $slave_SBI->{MASTERED_BY} ||
      &$error($msg . "Missing MASTERED_BY entry in SBI");

    my @master_ids = keys(%$masters_ref);

    if (@master_ids == 0) {
        &$error($msg . "No masters on this slave");
    }

    if (@master_ids != 1) {
        &$error($msg . "Multiple masters on slave not allowed");
    }
}

sub
is_avalon_master
{
    my $project = shift;
    my $master_name = shift;

    my $module_name = $project->_target_module_name();
    my $sbi = $project->spaceless_system_ptf()->{MODULE}
      {$module_name}{MASTER}{$master_name}{SYSTEM_BUILDER_INFO};

    my $master_bus_type = not_empty_scalar($sbi, "Bus_Type");

    return ($master_bus_type =~ /^avalon$/i);
}

1;

