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


























package nevada_opt;

use cpu_utils;
use nios_opt;
use nevada_isa;
use nevada_testbench;
use nevada_exceptions;
use nevada_control_regs;
use nevada_insts;
use nevada_mmu;
use strict;








sub
get_default_infos
{

    my $nios_infos = nios_opt::get_default_nios_infos();





    $nios_infos->{divide_info}{hardware_divide_impl} = "srt2";
    $nios_infos->{icache_info}{cache_icache_allow_tag_wrt} = "1";
    $nios_infos->{icache_info}{cache_icache_allow_bypass} = "1";
    $nios_infos->{dcache_info}{cache_dcache_allow_tag_wrt} = "1";
    $nios_infos->{dcache_info}{cache_dcache_st_bypass_hit_updates_cache} = "0";


    my $nevada_infos = {
      project_info => {

        module_lib_directory              => 
          $ENV{"SOPC_KIT_NEVADA"} . "/components/altera_mp32",
      },
      misc_info => {

        ebase_cpu_num                     => 0,
        debug_port_present                => 1,
        soft_reset_present                => 0,
        nmi_present                       => 0,
        dsp_block_has_pipeline_reg        => 0,
        register_file_ram_type            => "AUTO",
      },
      interrupt_info => {
        timer_ip_num                      => 7,
      },
      multiply_info => {
        hardware_multiply_impl            => "dsp_mul",
      },
      vector_info => {
        reset_paddr                       => undef,
        debug_paddr                       => undef,
      },
      mmu_info => {
        mmu_present                       => 1,
        tlb_present                       => 1,
        tlb_num_entries                   => 30,
        tlb_num_banks                     => 3,
        udtlb_num_entries                 => 6,
        uitlb_num_entries                 => 4,
      },
    };


    my $infos = {};
    add_to_ref($infos, $nios_infos, $nevada_infos);

    return $infos;
}




sub
elaborate_infos
{
    my $infos = shift;

    &$progress("  Elaborating CPU configuration settings");

    validate_hash_keys("infos", $infos, [
      "project_info",
      "misc_info",
      "ecc_info",
      "icache_info",
      "dcache_info",
      "multiply_info",
      "divide_info",
      "device_info",
      "vector_info",
      "avalon_master_info",
      "interrupt_info",
      "brpred_info",
      "mmu_info",
      "test_info",
      "interrupt_info"
    ]) || return undef;

    my $project_info = manditory_hash($infos, "project_info") || return undef;
    my $misc_info = manditory_hash($infos, "misc_info") || return undef;
    my $icache_info = manditory_hash($infos, "icache_info") || return undef;
    my $dcache_info = manditory_hash($infos, "dcache_info") || return undef;
    my $multiply_info = manditory_hash($infos, "multiply_info") || return undef;
    my $divide_info = manditory_hash($infos, "divide_info") || return undef;
    my $device_info = manditory_hash($infos, "device_info") || return undef;
    my $avalon_master_info = manditory_hash($infos, "avalon_master_info") || 
      return undef;
    my $interrupt_info = manditory_hash($infos, "interrupt_info") || 
      return undef;
    my $brpred_info = manditory_hash($infos, "brpred_info") || return undef;
    my $mmu_info = manditory_hash($infos, "mmu_info") || return undef;
    my $vector_info = manditory_hash($infos, "vector_info") || return undef;
    my $test_info = manditory_hash($infos, "test_info") || return undef;
    my $interrupt_info = manditory_hash($infos, "interrupt_info") || 
      return undef;




    my $nios_infos = {
      project_info          => $project_info,
      misc_info             => $misc_info,
      icache_info           => $icache_info,
      dcache_info           => $dcache_info,
      divide_info           => $divide_info,
      device_info           => $device_info,
      avalon_master_info    => $avalon_master_info,
      brpred_info           => $brpred_info,
      test_info             => $test_info,
      interrupt_info        => $interrupt_info,
    };

    my $local_mmu_present = manditory_bool($mmu_info, "mmu_present");
    my $local_tlb_present = 
      $local_mmu_present ? manditory_bool($mmu_info, "tlb_present") : 0;
    my $local_mpu_present = 0;

    my $elaborated_infos = nios_opt::elaborate_nios_infos(
      $nios_infos,
      $local_mmu_present,
      $local_tlb_present,
      $local_mpu_present,
    );

    if (!defined($elaborated_infos)) {
        return undef;
    }




    my $nevada_isa_info = nevada_isa::validate_and_elaborate();

    $elaborated_infos->{exception_info} = 
      nevada_exceptions::validate_and_elaborate();

    if ($local_mmu_present) {
        my $mmu_args = nevada_mmu::create_mmu_args_from_infos($mmu_info);

        $elaborated_infos->{mmu_info} = 
          nevada_mmu::validate_and_elaborate($mmu_args);
    }


    $elaborated_infos->{vector_info} = elaborate_vector_info($vector_info,
      $nevada_isa_info, $mmu_info, $misc_info);


    my $control_reg_args = 
      nevada_control_regs::create_control_reg_args_from_infos(
        $nevada_isa_info,
        $interrupt_info,
        $misc_info,
        $mmu_info,
        $dcache_info,
        $icache_info,
        $test_info,
        $elaborated_infos->{test_info},
        $elaborated_infos->{avalon_master_info},
    );

    $elaborated_infos->{control_reg_info} = 
      nevada_control_regs::validate_and_elaborate($control_reg_args);

    $elaborated_infos->{nevada_testbench_info} = 
      nevada_testbench::validate_and_elaborate(
        $elaborated_infos->{control_reg_info});


    my $nevada_inst_args = 
      nevada_insts::create_inst_args_from_infos($misc_info, $mmu_info);
    $elaborated_infos->{inst_info} = 
      nevada_insts::validate_and_elaborate($nevada_inst_args);

    return $elaborated_infos;
}


sub
create_opt
{
    my $infos = shift;
    my $elaborated_infos = shift;

    assert_hash_ref($infos, "infos");
    assert_hash_ref($elaborated_infos, "elaborated_infos");


    my $Opt = {};

    foreach my $info_name (keys(%$infos)) {
        nios_opt::merge_info_into_opt($Opt, $info_name, $infos->{$info_name}) ||
         return undef;
    }

    foreach my $info_name (keys(%$elaborated_infos)) {
        nios_opt::merge_info_into_opt($Opt, $info_name, 
          $elaborated_infos->{$info_name}) || return undef;
    }

    return $Opt;
}







sub
elaborate_vector_info
{
    my $vector_info = shift;
    my $nevada_isa_info = shift;
    my $mmu_info = shift;
    my $misc_info = shift;

    my $isa_constants = manditory_hash($nevada_isa_info, "isa_constants");
    my $mmu_present = manditory_bool($mmu_info, "mmu_present");
    my $debug_port_present = manditory_bool($misc_info, "debug_port_present");

    my $ret = {};   # The return value

    my $reset_paddr = (optional($vector_info, "reset_paddr") eq "") ?
      manditory_int($isa_constants, "default_reset_paddr") :
      manditory_int($vector_info, "reset_paddr");
    my $reset_addr = $mmu_present ?
      nevada_mmu::paddr_to_io_vaddr($reset_paddr) : $reset_paddr;



    $ret->{reset_addr} = $reset_addr;
    $ret->{exception_boot_addr} = $reset_addr + 
      manditory_int($isa_constants, "exception_boot_reset_offset");
    $ret->{debug_probe_trap_disabled_addr} = $reset_addr + 
      manditory_int($isa_constants, "debug_probe_trap_disabled_reset_offset");


    if ($debug_port_present) {
        my $debug_paddr = manditory_int($vector_info, "debug_paddr");

        if (!defined($mmu_addr_dseg_region_sz)) {
            &$error("The mmu_addr_dseg_region_sz global is undefined");
        }


        my $dseg_offset_sz = 32 - $mmu_addr_dseg_region_sz;

        my $dseg_offset_mask = sz2mask($dseg_offset_sz);

        if (($debug_paddr & $dseg_offset_mask) != 0) {
            &$error("The slave connected to the debug port at address " .
              sprintf("0x%x", $debug_paddr) . " isn't aligned to a " .
              (0x1 << $dseg_offset_sz) . " byte address");
        }
    }

    return $ret;
}

1;
