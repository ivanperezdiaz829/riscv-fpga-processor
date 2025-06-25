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






























package nios2_ptf_utils;
use Exporter;
@ISA = Exporter;
@EXPORT = qw(
    &get_nios2_infos
);

use cpu_utils;
use nios_ptf_utils;
use nios_brpred;
use nios2_opt;
use europa_all;
use europa_utils;
use s_avalon_slave_arbitration_module;
use strict;










sub
get_nios2_infos
{
    my $project = shift;

    &$progress("  Getting CPU configuration settings");


    my $nios_infos = get_nios_infos($project);


    my $nios2_infos = {};

    $nios2_infos->{misc_info} = get_misc_info($project);
    $nios2_infos->{debug_info} = get_debug_info($project);
    $nios2_infos->{multiply_info} = get_multiply_info($project);
    $nios2_infos->{avalon_slave_info} = get_avalon_slave_info($project,
      $nios_infos->{avalon_master_info});
    $nios2_infos->{custom_inst_info} = get_custom_inst_info($project);
    $nios2_infos->{interrupt_info} = 
      get_interrupt_info($project, $nios_infos->{avalon_master_info});
    $nios2_infos->{mmu_info} = get_mmu_info($project);
    $nios2_infos->{mpu_info} = get_mpu_info($project);
    $nios2_infos->{exception_info} = get_exception_info($project);
    $nios2_infos->{vector_info} = get_vector_info($project, 
      $nios2_infos->{mmu_info});


    add_to_ref($nios2_infos, $nios_infos);

    return $nios2_infos;
}





sub
get_misc_info
{
    my $project = shift;

    my $local_info = {};    # Don't want these to be returned.

    copy_from_wsa($project, $local_info, {
      CPU_Implementation        => undef,
      cpuid_value               => 0,
      dont_overwrite_cpuid      => 0,
      num_shadow_reg_sets       => 0,
    });

    my $info = {};    # Anonymous hash reference loaded with all info


    $info->{core_type} = $local_info->{CPU_Implementation};

    if ($local_info->{dont_overwrite_cpuid}) {

        $info->{cpuid_value} = eval($local_info->{cpuid_value});
    } else {

        $info->{cpuid_value} = calc_cpuid($project);
    }

    copy_from_wsa($project, $info, {
      cpu_reset                 => 0,
      register_file_ram_type            => "AUTO",
    });

    return $info;
}

sub
get_debug_info
{
    my $project = shift;

    my $local_info = {};    # Don't want these values returned

    copy_from_wsa($project, $local_info, {
      oci_assign_jtag_instance_id   => 0,
      oci_jtag_instance_id          => 0,
    });

    my $info = {};    # Anonymous hash reference loaded with all info

    copy_from_wsa($project, $info, {
      include_third_party_debug_port => 0,
	  avalon_debug_port_present     => 0,
      include_oci                   => 0,
      oci_offchip_trace             => 0,
      oci_onchip_trace              => 0,
      oci_data_trace                => 0,
      oci_trace_addr_width          => 7,
      oci_num_xbrk                  => 0,
      oci_num_dbrk                  => 0,
      oci_sync_depth                => 2,
      oci_dbrk_trace                => 0,
      oci_dbrk_pairs                => 0,
      oci_num_pm                    => 0,
      oci_pm_width                  => 40,
      oci_debugreq_signals          => 0,
      oci_trigger_arming            => 1,
      oci_embedded_pll              => 1,
      oci_export_jtag_signals       => 0,
      altium_jtag                   => 0,
      internal_nios2                => 0,
      oci_mem_ram_type              => "AUTO",
    });

    &validate_parameter ({
        hash    => $info,
        name    => "include_oci",
        type    => "boolean",
        default => 0,
    });


    if ($info->{include_oci}) {
        $info->{oci_virtual_jtag_instance_id} =
          $local_info->{oci_assign_jtag_instance_id} ? 
            $local_info->{oci_jtag_instance_id} : 
            $project->assign_available_SLD_Node_Instance_Id(
              "jtag_debug_module");
    }




    return $info;
}

sub
get_multiply_info
{
    my $project = shift;

    my $info = {};    # Anonymous hash reference loaded with all info

    copy_from_wsa($project, $info, {
      hardware_multiply_present     => undef,
      hardware_multiply_omits_msw   => 0,
      hardware_multiply_impl        => undef,
    });

    return $info;
}



sub
get_avalon_slave_info
{
    my $project = shift;
    my $avalon_master_info = shift;

    my $info = {};    # Anonymous hash reference loaded with all info

    $info->{avalon_data_slaves} = 
      get_avalon_slaves($project, $avalon_master_info, "data");
    $info->{avalon_instruction_slaves} = 
      get_avalon_slaves($project, $avalon_master_info, "instruction");

    return $info;
}



sub
get_custom_inst_info
{
    my $project = shift;

    my $info = {};    # Anonymous hash reference loaded with all master info

    my $module_name = $project->_target_module_name();


    my @enabled_masters = $project->get_masters_by_module_name($module_name);

    my $ci_master_name;


    foreach my $master_name (@enabled_masters) {

        if (!is_custom_instruction_master($project, $master_name)) {
            next;
        }

        if (defined($ci_master_name)) {
            &$error("Only one custom instruction master port is supported");
        }

        $ci_master_name = $master_name;
    }




    my %custom_instructions = ();

    if (defined($ci_master_name)) {


        my $ci_master_id = $module_name . "/" . $ci_master_name;
        my @ci_slave_ids = $project->get_slaves_by_master_name($ci_master_id);


        foreach my $ci_slave_id (@ci_slave_ids) {

            my $custom_instruction = {};



            my $ci_name = $ci_slave_id;
            $ci_name =~ s!/!_!g;

            my $ci_inst_type = $project->get_ci_slave_inst_type($ci_slave_id);
            if (
              $ci_inst_type eq "fixed multicycle" ||
              $ci_inst_type eq "variable multicycle") {
                $custom_instruction->{type} = "multi";
            } elsif ($ci_inst_type eq "combinatorial") {
                $custom_instruction->{type} = "combo";
            } else {
                &$error(
                  "Bad custom instruction type $ci_inst_type for $ci_slave_id");
            }

            $custom_instruction->{addr_base} = 
              $project->get_ci_slave_base_addr($ci_slave_id);
            $custom_instruction->{addr_width} = 
              $project->get_ci_slave_address_width($ci_slave_id);

            $custom_instructions{$ci_name} = $custom_instruction;
        }
    }

    $info->{custom_instructions} = \%custom_instructions;

    return $info;
}

sub
get_interrupt_info
{
    my $project = shift;
    my $avalon_master_info = shift;

    my $info = {};

    my $internal_irq_mask = 0;       # 32-bit mask of used interrupts (1=used)

    my $module_name = $project->_target_module_name();

    my $data_master_present = 
      defined($avalon_master_info->{avalon_masters}{data_master});


    if ($data_master_present) {
        my $data_master_desc = join("/", $module_name, "data_master");
    
        my $data_master_irq_hash_ref = $project->get_module_slave_hash(
          ["SYSTEM_BUILDER_INFO", "IRQ_MASTER", $data_master_desc, 
          "IRQ_Number"]);
    
        foreach my $irq (values(%$data_master_irq_hash_ref)) {

            next unless ($irq =~ /^\d+$/);
    
            $internal_irq_mask |= 0x1 << $irq;
        }
    }

    $info->{internal_irq_mask} = $internal_irq_mask;

    return $info;
}

sub
get_mmu_info
{
    my $project = shift;

    my $info = {};    # Anonymous hash reference loaded with all info

    copy_from_wsa($project, $info, {
      mmu_present       => 0,
    });

    if (manditory_bool($info, "mmu_present")) {
        copy_from_wsa($project, $info, {
          process_id_num_bits   => undef,
          tlb_ptr_sz            => undef,
          tlb_num_ways          => undef,
          udtlb_num_entries     => undef,
          uitlb_num_entries     => undef,
          mmu_ram_type          => undef,
        });
    }

    return $info;
}

sub
get_mpu_info
{
    my $project = shift;

    my $info = {};    # Anonymous hash reference loaded with all info

    copy_from_wsa($project, $info, {
      mpu_present       => 0,
    });

    if (manditory_bool($info, "mpu_present")) {
        copy_from_wsa($project, $info, {
          mpu_num_inst_regions              => undef,
          mpu_num_data_regions              => undef,
          mpu_min_inst_region_size_log2     => undef,
          mpu_min_data_region_size_log2     => undef,
          mpu_use_limit                     => undef,
        });
    }

    return $info;
}

sub
get_exception_info
{
    my $project = shift;

    my $local_info = {};        # Don't want this returned
    copy_from_wsa($project, $local_info, {
      illegal_memory_access_detection   => 0,
      illegal_instructions_trap         => 0,
    });

    my $info = {};    # Anonymous hash reference loaded with all info


    $info->{imprecise_illegal_mem_exc} =
      $local_info->{illegal_memory_access_detection};
    $info->{reserved_instructions_trap} = 
      $local_info->{illegal_instructions_trap};

    copy_from_wsa($project, $info, {
      illegal_mem_exc           => 0,
      slave_access_error_exc    => 0,
      division_error_exc        => 0,
      extra_exc_info            => 0,
    });

    return $info;
}

sub
get_vector_info
{
    my $project = shift;
    my $mmu_info = shift;

    my $local_info = {};        # Don't want this returned

    copy_from_wsa($project, $local_info, {
      reset_slave               => undef,
      reset_offset              => undef,
      exc_slave                 => undef,
      exc_offset                => undef,
      break_slave               => undef,
      break_offset              => undef,
    });

    &validate_parameter ({
        hash      => $local_info,
        name      => "reset_slave",
        type      => "string",
        });

    &validate_parameter ({
        hash      => $local_info,
        name      => "reset_offset",
        type      => "integer",
        default   => "0",
        });

    &validate_parameter ({
        hash      => $local_info,
        name      => "exc_slave",
        type      => "string",
        });

    &validate_parameter ({
        hash      => $local_info,
        name      => "exc_offset",
        type      => "integer",
        default   => "0",
        });
                        
    &validate_parameter ({
        hash      => $local_info,
        name      => "break_slave",
        type      => "string",
        });

    &validate_parameter ({
        hash      => $local_info,
        name      => "break_offset",
        type      => "integer",
        default   => "0",
        });

    my $reset_slave_SBI  = $project->SBI($local_info->{reset_slave}) ||
      &$error("Couldn't find SBI section for " . $local_info->{reset_slave});
    my $exc_slave_SBI   = $project->SBI($local_info->{exc_slave}) ||
      &$error("Couldn't find SBI section for " . $local_info->{exc_slave});
    my $break_slave_SBI  = $project->SBI($local_info->{break_slave}) ||
      &$error("Couldn't find SBI section for " . $local_info->{break_slave});

    my $info = {};    # Anonymous hash reference loaded with all info

    $info->{reset_addr} = eval($reset_slave_SBI->{Base_Address});
    $info->{general_exception_addr} = eval($exc_slave_SBI->{Base_Address});
    $info->{break_addr} = eval($break_slave_SBI->{Base_Address});

    $info->{reset_addr} += eval($local_info->{reset_offset});
    $info->{general_exception_addr}   += eval($local_info->{exc_offset} );
    $info->{break_addr} += eval($local_info->{break_offset});

    if (manditory_bool($mmu_info, "mmu_present")) {
        copy_from_wsa($project, $local_info, {
          fast_tlb_miss_exc_slave   => undef,
          fast_tlb_miss_exc_offset  => undef,
        });

        &validate_parameter ({
            hash      => $local_info,
            name      => "fast_tlb_miss_exc_slave",
            type      => "string",
            });
    
        &validate_parameter ({
            hash      => $local_info,
            name      => "fast_tlb_miss_exc_offset",
            type      => "integer",
            default   => "0",
            });

        my $fast_tlb_miss_exc_slave_SBI   = 
          $project->SBI($local_info->{fast_tlb_miss_exc_slave}) ||
            &$error("Couldn't find SBI section for " . 
              $local_info->{fast_tlb_miss_exc_slave});
    
        $info->{fast_tlb_miss_exception_addr} = 
          eval($fast_tlb_miss_exc_slave_SBI->{Base_Address});
        $info->{fast_tlb_miss_exception_addr} +=
          eval($local_info->{fast_tlb_miss_exc_offset});
    }

    return $info;
}






sub 
calc_cpuid
{
    my $project = shift;


    my $num_cpus = 0;


    my $my_instance_name = $project->_target_module_name();

    my $cpuid_reg_value;



    foreach my $instance_name ($project->get_all_module_section_names()) {
        my $mod_ptf = $project->get_module_ptf_by_name($instance_name);
        my $mod_sbi = $mod_ptf->{SYSTEM_BUILDER_INFO};


        next unless ($mod_ptf->{class} eq "altera_nios2");


        next unless $mod_sbi->{Is_Enabled};


        next unless $mod_sbi->{Is_CPU};


        if ($instance_name eq $my_instance_name) {

            $cpuid_reg_value = $num_cpus;
        }


        $num_cpus++;
    }




    my $sys_ptf = $project->system_ptf();
    my $mod_ptf = $sys_ptf->{"MODULE $my_instance_name"};
    my $writeback_wsa = $mod_ptf->{WIZARD_SCRIPT_ARGUMENTS};

    $writeback_wsa->{cpuid_value} = $cpuid_reg_value;
    $writeback_wsa->{cpuid_sz} = max(num2sz($cpuid_reg_value), 1);

    return $cpuid_reg_value;
}

sub 
get_avalon_slaves
{
    my $project = shift;
    my $avalon_master_info = shift;
    my $master_type = shift;

    my $module_name = $project->_target_module_name();




    my %avalon_slaves = ();

    foreach my $master_name (keys(%{$avalon_master_info->{avalon_masters}})) {
        my $avalon_master = $avalon_master_info->{avalon_masters}{$master_name};


        if ($avalon_master->{type} ne $master_type) {
            next;
        }

        my $master_desc = $module_name . "/" . $master_name;
        my @slave_descs = $project->get_slaves_by_master_name($master_desc);

        foreach my $slave_desc (@slave_descs) {
            (my $base, my $end) = 
              s_avalon_slave_arbitration_module->
                get_address_range_of_one_slave_by_master($master_desc,
                  $slave_desc, $project);
            my $readonly = is_slave_readonly($project, $slave_desc);

            my $avalon_slave = {};

            $avalon_slave->{base} = $base;
            $avalon_slave->{end} = $end;
            $avalon_slave->{readonly} = $readonly;



            my $existing_avalon_slave = $avalon_slaves{$slave_desc};

            if (defined($existing_avalon_slave)) {
                if ($existing_avalon_slave->{base} != $base) {
                    &$error("Slave $slave_desc is connected to multiple" .
                      "masters but the base addresses don't match");
                }
                if ($existing_avalon_slave->{end} != $end) {
                    &$error("Slave $slave_desc is connected to multiple" .
                      "masters but the end addresses don't match");
                }
                if ($existing_avalon_slave->{readonly} != $readonly) {
                    &$error("Slave $slave_desc is connected to multiple" .
                      "masters but the readonly flags don't match");
                }
            } else {
                $avalon_slaves{$slave_desc} = $avalon_slave;
            }
        }
    }

    return \%avalon_slaves;
}

sub 
is_slave_readonly
{
    my $project = shift;
    my $slave_desc = shift;

    my ($module_name, $slave_name) = split (/\//, $slave_desc);

    my $slave_SBI = $project->SBI($slave_desc);
    if (!$slave_SBI) {
        &$error("Can't find slave SBI for $slave_desc");
    }


    if ($slave_SBI->{Is_Nonvolatile_Storage}) {
        return 1;
    }




    my $slave_readable = 
      ($slave_SBI->{Is_Readable} ne "") ? $slave_SBI->{Is_Readable} : 1;
    my $slave_writeable = 
      ($slave_SBI->{Is_Writeable} ne "") ? $slave_SBI->{Is_Writeable} :
      ($slave_SBI->{Is_Writable} ne "") ? $slave_SBI->{Is_Writable} :
      1;

    if ($slave_readable && !$slave_writeable) {
        return 1;
    }

    return 0;
}

sub
is_custom_instruction_master
{
    my $project = shift;
    my $master_name = shift;

    my $module_name = $project->_target_module_name();
    my $sbi = $project->spaceless_system_ptf()->{MODULE}
      {$module_name}{MASTER}{$master_name}{SYSTEM_BUILDER_INFO};

    my $master_bus_type = not_empty_scalar($sbi, "Bus_Type");

    return 
      (($master_bus_type =~ /^nios_custom_instruction$/i) ||
       ($master_bus_type =~ /^nios2_custom_instruction$/i));
}

1;

