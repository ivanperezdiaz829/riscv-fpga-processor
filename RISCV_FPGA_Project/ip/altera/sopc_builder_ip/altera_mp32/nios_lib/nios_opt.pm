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


























package nios_opt;

use cpu_utils;
use nios_avalon_masters;
use nios_isa;
use strict;








sub
get_default_nios_infos
{
    my $nios_infos = {
      project_info => {
        name                              => "cpu",
        simgen                            => 0,
        do_build_sim                      => 1,
        system_directory                  => ".",
        simulation_directory              => "./sim",
        language                          => "verilog",
        clock_frequency                   => 100*1000*1000,
        copyright_notice                  => get_copyright_notice(),
        translate_off                     => "synthesis translate_off",
        translate_on                      => "synthesis translate_on",
        quartus_translate_off             => 
          "synthesis read_comments_as_HDL off",
        quartus_translate_on              => 
          "synthesis read_comments_as_HDL on",
        asic_enabled                      => 0,
        asic_third_party_synthesis        => "",
        device_family                     => "STRATIXIII",
      },
      misc_info => {
        big_endian                        => 0,
        be8                               => 0,
        altium_jtag                       => 0,
        internal_nios2                    => 0,
        export_pcb                        => 0,
        shift_rot_impl                    => "dsp_shift",
        num_shadow_reg_sets               => 0,
        export_large_RAMs                 => 0,
        use_designware                    => 0,
        export_vectors                    => 0,
        shared_exclusive_present          => 0,
      },
      ecc_info => {
        ecc_present                       => 0,
        ic_ecc_present                    => 0,
        dc_ecc_present                    => 0,
        rf_ecc_present                    => 0,
        itcm_ecc_present                  => 0,
        dtcm_ecc_present                  => 0,
        mmu_ecc_present                   => 0,
      },
      icache_info => {
        cache_has_icache                  => 1,
        cache_icache_size                 => 4*1024,
        cache_icache_line_size            => 32,
        cache_icache_burst_type           => "none",
        cache_icache_tag_ram_block_type   => "AUTO",
        cache_icache_ram_block_type       => "AUTO",
        cache_icache_allow_tag_wrt        => 0,
        cache_icache_allow_bypass         => 0,
      },
      dcache_info => {
        cache_has_dcache                  => 1,
        cache_dcache_size                 => 2*1024,
        cache_dcache_line_size            => 32,
        cache_dcache_bursts               => 0,
        cache_dcache_tag_ram_block_type   => "AUTO",
        cache_dcache_ram_block_type       => "AUTO",
        cache_dcache_allow_tag_wrt        => 0,
        cache_dcache_st_bypass_hit_updates_cache => 1,
        cache_dcache_victim_buf_impl      => "ram", # ram or reg
      },
      divide_info => {
        hardware_divide_present           => 1,
        hardware_divide_impl              => "variable_latency",
      },
      device_info => {
        dsp_block_supports_shift          => 0,
        address_stall_present             => 1,
        mrams_present                     => 0,
      },
      avalon_master_info => nios_avalon_masters::get_test_avalon_master_info(),
      brpred_info => {
        branch_prediction_type            => "Dynamic",
        bht_ptr_sz                        => 8,
        bht_index_pc_only                 => 0,
        bht_ram_type                      => "AUTO",
      },
      test_info => {
        activate_model_checker            => 0,
        activate_monitors                 => 1,
        activate_trace                    => 1,
        activate_test_end_checker         => 1,
        activate_ecc_sim_test_ports       => 0,
        always_bypass_dcache              => 0,
        always_encrypt                    => 0,
        bit_31_bypass_dcache              => 1,
        clear_x_bits_ld_non_bypass        => 1,
        debug_simgen                      => 0,
        full_waveform_signals             => 1,
        hbreak_test                       => 0,
        hdl_sim_caches_cleared            => 1,
        performance_counters_present      => 0,
        performance_counters_width        => 32,
        allow_break_inst                  => 0,
      },
      interrupt_info => {
        eic_present                       => 0,
      },
    };

    return $nios_infos;
}




sub
elaborate_nios_infos
{
    my $nios_infos = shift;
    my $local_mmu_present = shift;
    my $local_tlb_present = shift;
    my $local_mpu_present = shift;

    validate_hash_keys("nios_infos", $nios_infos, [
      "project_info",
      "misc_info",
      "ecc_info",
      "icache_info",
      "dcache_info",
      "divide_info",
      "device_info",
      "avalon_master_info",
      "brpred_info",
      "test_info",
      "interrupt_info"]);

    assert_scalar($local_mmu_present, "local_mmu_present") || return undef;
    assert_scalar($local_tlb_present, "local_tlb_present") || return undef;
    assert_scalar($local_mpu_present, "local_mpu_present") || return undef;

    my $project_info = manditory_hash($nios_infos, "project_info");
    my $icache_info = manditory_hash($nios_infos, "icache_info");
    my $dcache_info = manditory_hash($nios_infos, "dcache_info");
    my $divide_info = manditory_hash($nios_infos, "divide_info");
    my $device_info = manditory_hash($nios_infos, "device_info");
    my $avalon_master_info = manditory_hash($nios_infos, "avalon_master_info");
    my $brpred_info = manditory_hash($nios_infos, "brpred_info");
    my $test_info = manditory_hash($nios_infos, "test_info");
    my $interrupt_info = manditory_hash($nios_infos, "interrupt_info");

    my $elaborated_infos = {};  # Return value

    $elaborated_infos->{nios_isa_info} = 
      nios_isa::validate_and_elaborate($local_mmu_present, $local_tlb_present,
        $local_mpu_present);

    my $avalon_master_args = 
      nios_avalon_masters::create_avalon_master_args_from_infos(
        $avalon_master_info, 
        $test_info,
        $local_mmu_present,
        $local_mpu_present,
    );
    $elaborated_infos->{avalon_master_info} = 
      nios_avalon_masters::validate_and_elaborate($avalon_master_args);

    $elaborated_infos->{test_info} = elaborate_test_info($test_info);
    $elaborated_infos->{dcache_info} = elaborate_dcache_info($dcache_info);

    return $elaborated_infos;
}

sub
merge_info_into_opt
{
    my $Opt = shift;
    my $info_name = shift;
    my $info = shift;
    

















    if (!defined($Opt->{$info_name})) {
        $Opt->{$info_name} = {};
    }
    add_to_ref($Opt->{$info_name}, $info) || return undef;


    add_to_ref($Opt, $info) || return undef;

    return 1;   # Some defined value
}







sub
elaborate_test_info
{
    my $test_info = shift;

    my $ret = {};   # The return value

    $ret->{perf_cnt_present} = 
      manditory_bool($test_info, "performance_counters_present");
    $ret->{sim_reg_present} = 
      $ret->{perf_cnt_present} || 
      manditory_bool($test_info, "activate_test_end_checker");
    $ret->{sim_reg_c_model_fields_present} = 0;

    return $ret;
}



sub
elaborate_dcache_info
{
    my $dcache_info = shift;

    my $ret = {};   # The return value



    $ret->{dcache_supports_initda} = 
      manditory_bool($dcache_info, "cache_has_dcache") && 
      (manditory_int($dcache_info, "cache_dcache_line_size") != 4);

    return $ret;
}

sub
get_copyright_notice
{
    my ($sec, $min, $hour, $mday, $mon, $year_offset) = localtime(time);

    my $year = $year_offset + 1900;

    my $copyright_notice = <<END_OF_COPYRIGHT_STRING;
Legal Notice: (C)$year Altera Corporation. All rights reserved.  Your
use of Altera Corporation\'s design tools, logic functions and other
software and tools, and its AMPP partner logic functions, and any
output files any of the foregoing (including device programming or
simulation files), and any associated documentation or information are
expressly subject to the terms and conditions of the Altera Program
License Subscription Agreement or other applicable license agreement,
including, without limitation, that your use is for the sole purpose
of programming logic devices manufactured by Altera and sold by Altera
or its authorized distributors.  Please refer to the applicable
agreement for further details.
END_OF_COPYRIGHT_STRING

    return $copyright_notice;
}

1;

