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


























package nios2_opt;

use cpu_utils;
use nios_opt;
use nios2_isa;
use nios2_exceptions;
use nios2_control_regs;
use nios2_insts;
use nios2_mmu;
use nios2_mpu;
use nios2_custom_insts;
use strict;








sub
get_default_infos
{

    my $nios_infos = nios_opt::get_default_nios_infos();


    my $nios2_infos = {
      project_info => {

        module_lib_directory              => 
          $ENV{"SOPC_KIT_NIOS2"} . "/components/altera_nios2",
      },
      misc_info => {

        core_type                         => "fast",
        cpuid_value                       => 0,
        cpu_reset                         => 0,
        register_file_ram_type            => "AUTO",
      },
      debug_info => {
        include_third_party_debug_port    => 0,
    	avalon_debug_port_present         => 0,
        include_oci                       => 1,
        oci_offchip_trace                 => 0,
        oci_onchip_trace                  => 0,
        oci_data_trace                    => 0,
        oci_trace_addr_width              => 7,
        oci_num_xbrk                      => 0,
        oci_num_dbrk                      => 0,
        oci_sync_depth                    => 2,
        oci_dbrk_trace                    => 0,
        oci_dbrk_pairs                    => 0,
        oci_num_pm                        => 0,
        oci_pm_width                      => 32,
        oci_debugreq_signals              => 0,
        oci_trigger_arming                => 1,
        oci_embedded_pll                  => 0,
        oci_virtual_jtag_instance_id      => 0,
        oci_export_jtag_signals           => 0,
        oci_mem_ram_type                  => "AUTO",
      },
      multiply_info => {
        hardware_multiply_present         => 1,
        hardware_multiply_omits_msw       => 0,
        hardware_multiply_impl            => "dsp_mul",
      },
      vector_info => {
        reset_addr                        => 0x40000,
        general_exception_addr            => 0x40040,
        fast_tlb_miss_exception_addr      => 0x40020,
        break_addr                        => 0x81820,
      },

      avalon_slave_info => {
        avalon_data_slaves => {},
        avalon_instruction_slaves => {},
      },
      custom_inst_info => {
        custom_instructions => {
          cpu_bitswap_s1 => {
            type => "combo",
            addr_base => 0x0,
            addr_width => 0,
          },
          cpu_interrupt_vector_interrupt_vector => {
            type => "combo",
            addr_base => 0x1,
            addr_width => 0,
          },
          cpu_fpoint_s1 => {
            type => "multi",
            addr_base => 0xfc,
            addr_width => 2,
          },
        },
      },
      interrupt_info => {
        internal_irq_mask                 => 0x3,
      },
      mmu_info => {
        mmu_present                       => 0,
        process_id_num_bits               => 8,
        tlb_ptr_sz                        => 7,
        tlb_num_ways                      => 16,
        udtlb_num_entries                 => 6,
        uitlb_num_entries                 => 4,
        mmu_ram_type                      => "AUTO",
      },
      mpu_info => {
        mpu_present                       => 0,
        mpu_num_inst_regions              => 8,
        mpu_num_data_regions              => 8,
        mpu_min_inst_region_size_log2     => 12,
        mpu_min_data_region_size_log2     => 12,
        mpu_use_limit                     => 0,
      },
      exception_info => {
        reserved_instructions_trap        => 1,
        illegal_mem_exc                   => 1,
        imprecise_illegal_mem_exc         => 0,
        slave_access_error_exc            => 0,
        division_error_exc                => 0,
        extra_exc_info                    => 1,
      },
    };


    my $infos = {};
    add_to_ref($infos, $nios_infos, $nios2_infos);

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
      "debug_info",
      "multiply_info",
      "divide_info",
      "device_info",
      "vector_info",
      "avalon_master_info",
      "avalon_slave_info",
      "custom_inst_info",
      "interrupt_info",
      "brpred_info",
      "mmu_info",
      "mpu_info",
      "exception_info",
      "test_info",
    ]) || return undef;

    my $project_info = manditory_hash($infos, "project_info") || return undef;
    my $misc_info = manditory_hash($infos, "misc_info") || return undef;
    my $ecc_info = manditory_hash($infos, "ecc_info") || return undef;
    my $icache_info = manditory_hash($infos, "icache_info") || return undef;
    my $dcache_info = manditory_hash($infos, "dcache_info") || return undef;
    my $debug_info = manditory_hash($infos, "debug_info") || return undef;
    my $multiply_info = manditory_hash($infos, "multiply_info") || return undef;
    my $divide_info = manditory_hash($infos, "divide_info") || return undef;
    my $device_info = manditory_hash($infos, "device_info") || return undef;
    my $avalon_master_info = manditory_hash($infos, "avalon_master_info") || 
      return undef;
    my $avalon_slave_info = manditory_hash($infos, "avalon_slave_info") ||
      return undef;
    my $custom_inst_info = manditory_hash($infos, "custom_inst_info") ||
      return undef;
    my $interrupt_info = manditory_hash($infos, "interrupt_info") || 
      return undef;
    my $brpred_info = manditory_hash($infos, "brpred_info") || return undef;
    my $mmu_info = manditory_hash($infos, "mmu_info") || return undef;
    my $mpu_info = manditory_hash($infos, "mpu_info") || return undef;
    my $exception_info = manditory_hash($infos, "exception_info") || 
      return undef;
    my $vector_info = manditory_hash($infos, "vector_info") || return undef;
    my $test_info = manditory_hash($infos, "test_info") || return undef;




    my $nios_infos = {
      project_info          => $project_info,
      misc_info             => $misc_info,
      ecc_info              => $ecc_info,
      icache_info           => $icache_info,
      dcache_info           => $dcache_info,
      divide_info           => $divide_info,
      device_info           => $device_info,
      avalon_master_info    => $avalon_master_info,
      brpred_info           => $brpred_info,
      test_info             => $test_info,
      interrupt_info        => $interrupt_info,
    };

    my $elaborated_infos = nios_opt::elaborate_nios_infos(
      $nios_infos,
      manditory_bool($mmu_info, "mmu_present"),
      manditory_bool($mmu_info, "mmu_present"),
      manditory_bool($mpu_info, "mpu_present"),
    );

    if (!defined($elaborated_infos)) {
        return undef;
    }


    if (manditory_int($debug_info, "oci_num_pm") > 0) {
        $elaborated_infos->{test_info}{perf_cnt_present} = 1;
    }




    my $nios2_isa_info = nios2_isa::validate_and_elaborate();

    $elaborated_infos->{exception_info} = 
      nios2_exceptions::validate_and_elaborate();

    if ($mmu_info->{mmu_present}) {
        my $mmu_args = nios2_mmu::create_mmu_args_from_infos($mmu_info);

        $elaborated_infos->{mmu_info} = 
          nios2_mmu::validate_and_elaborate($mmu_args);


        nios2_mmu::convert_vectors_to_kernel_region($vector_info);
    }

    $elaborated_infos->{debug_info} = 
      elaborate_debug_info($debug_info, $test_info);
    $elaborated_infos->{interrupt_info} = 
      elaborate_interrupt_info($interrupt_info);
    $elaborated_infos->{exception_info} =
      elaborate_advanced_exc_info($exception_info, $mmu_info, $mpu_info,
        $interrupt_info, $misc_info, $ecc_info);
    if ($mpu_info->{mpu_present}) {
        my $mpu_args = nios2_mpu::create_mpu_args_from_infos(
            $mpu_info, 
            $elaborated_infos->{avalon_master_info},
        );
        $elaborated_infos->{mpu_info} = 
          nios2_mpu::validate_and_elaborate($mpu_args);
    }


    $elaborated_infos->{vector_info} = elaborate_vector_info($vector_info);


    my $control_reg_args = 
      nios2_control_regs::create_control_reg_args_from_infos(
        $nios2_isa_info,
        $interrupt_info,
        $exception_info,
        $misc_info,
        $ecc_info,
        $mmu_info,
        $mpu_info,
        $elaborated_infos->{mpu_info},
        $test_info,
        $elaborated_infos->{test_info},
        $elaborated_infos->{avalon_master_info},
        $icache_info,
        $elaborated_infos->{dcache_info},
    );

    $elaborated_infos->{control_reg_info} = 
      nios2_control_regs::validate_and_elaborate($control_reg_args);


    my $inst_args = nios2_insts::create_inst_args_from_infos(
        $nios2_isa_info,
        $misc_info,
        $custom_inst_info, 
        $elaborated_infos->{control_reg_info},
        $multiply_info,
        $divide_info,
        $exception_info,
        $elaborated_infos->{exception_info},
        $icache_info,
        $dcache_info,
        $elaborated_infos->{dcache_info},
        $elaborated_infos->{debug_info},
    );
    $elaborated_infos->{inst_info} = 
      nios2_insts::validate_and_elaborate($inst_args);

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

    my $ret = {};   # The return value

    $ret->{reset_word_addr} = $vector_info->{reset_addr} >> 2;
    $ret->{general_exception_word_addr} = 
      $vector_info->{general_exception_addr} >> 2;
    $ret->{break_word_addr} = $vector_info->{break_addr} >> 2;
    $ret->{fast_tlb_miss_exception_word_addr} = 
      $vector_info->{fast_tlb_miss_exception_addr} >> 2;

    return $ret;
}



sub
elaborate_debug_info
{
    my $debug_info = shift;
    my $test_info = shift;

    my $ret = {};   # The return value

    if (
      $debug_info->{include_oci} &&
      $debug_info->{include_third_party_debug_port}) {
        return 
          &$error("Both Altera OCI and 3rd party debugging port requested." .
            " You may only have one or the other.");
    }


    $ret->{debugger_present} = 
      $debug_info->{include_oci} ||
      $debug_info->{include_third_party_debug_port};


    $ret->{hbreak_present} = 
      $ret->{debugger_present} || $test_info->{hbreak_test};

    return $ret;
}



sub
elaborate_interrupt_info
{
    my $interrupt_info = shift;

    my $ret = {};   # The return value


    $ret->{internal_irq_mask_bin} = 
      sprintf("32'b%032b", $interrupt_info->{internal_irq_mask});

    return $ret;
}



sub
elaborate_advanced_exc_info
{
    my $exception_info = shift;
    my $mmu_info = shift;
    my $mpu_info = shift;
    my $interrupt_info = shift;
    my $misc_info = shift;
    my $ecc_info = shift;

    my $ret = {};   # The return value


    $ret->{advanced_exc} = 
      manditory_bool($mmu_info, "mmu_present") ||
      manditory_bool($mpu_info, "mpu_present") ||
      manditory_bool($exception_info, "illegal_mem_exc") ||
      manditory_bool($exception_info, "extra_exc_info") ||
      manditory_bool($exception_info, "slave_access_error_exc") ||
      manditory_bool($exception_info, "division_error_exc") ||
      manditory_bool($interrupt_info, "eic_present") ||
      (manditory_int($misc_info, "num_shadow_reg_sets") > 0) ||
      manditory_bool($ecc_info, "ecc_present");

    return $ret;
}

1;
