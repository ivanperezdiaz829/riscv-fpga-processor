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






















package nios2_frontend;
use Exporter;
@ISA = Exporter;
@EXPORT = qw(
);

use cpu_utils;
use cpu_wave_signals;
use cpu_file_utils;
use cpu_bit_field;
use cpu_control_reg;
use cpu_exception_gen;
use europa_all;
use europa_utils;
use nios_utils;
use nios_addr_utils;
use nios_avalon_masters;
use nios_isa;
use nios_icache;
use nios2_isa;
use nios2_insts;
use nios2_mmu;
use nios2_mpu;
use nios2_exceptions;
use nios2_common;
use nios_common;
use nios2_control_regs;
use nios_ecc_encoder;
use nios_ecc_decoder;
use strict;


















sub 
gen_ram_instruction_word_mux
{
    my $Opt = shift;

    my $whoami = "RAM instruction word mux";

    my $inst_crst_next_stage = not_empty_scalar($Opt, "inst_crst_next_stage");



    my $cmp_pcb_sz = $mmu_present ? 32 : manditory_int($Opt, "i_Address_Width");

    my $avalon_master_info = manditory_hash($Opt, "avalon_master_info");


    my @sel_signals = make_master_address_decoder({
      avalon_master_info    => $avalon_master_info,
      normal_master_name    => 
        ($instruction_master_present ? "instruction_master" : ""),
      tightly_coupled_master_names => manditory_array($avalon_master_info,
        "avalon_tightly_coupled_instruction_master_list"), 
      addr_signal           => "F_pcb[$cmp_pcb_sz-1:0]", 
      addr_sz               => $cmp_pcb_sz, 
      sel_prefix            => "F_sel_",
      mmu_present           => $mmu_present,
      master_paddr_mapper_func => \&nios2_mmu::master_paddr_mapper,
    });




    my @ram_iw_mux_table;

    if ($icache_present) {
        push(@ram_iw_mux_table,
          "F_sel_instruction_master" => "F_ic_iw");
    }

    if ($ecc_present && $itcm_present && $itcm_ecc_present) {
        my $ecc_bits = calc_num_ecc_bits($datapath_sz);
        my $ecc_data_sz =  $datapath_sz + $ecc_bits;
        my @tcim_ecc_error;



        if (manditory_int($Opt, "num_tightly_coupled_instruction_masters") > 0) {
            

            nios_ecc_decoder->add({
              name => "tightly_coupled_instruction_master_0_ecc_decoder",
              codeword_width          => $ecc_data_sz,
              dataword_width          => $datapath_sz,
              standalone_decoder      => 1,
              correct_parity          => 1,
              port_map => {
                data          => "icm0_readdata",
                q             => "icm0_instword",
                one_bit_err   => "icm0_one_bit_err_nxt",
                two_bit_err   => "icm0_two_bit_err_nxt",
                corrected_data => "icm0_corrected_data_nxt",
                one_two_or_three_bit_err     => "icm0_one_two_three_bit_err",
              },
            });
        }


        for (my $cmi = 1; 
          $cmi < manditory_int($Opt, "num_tightly_coupled_instruction_masters");
          $cmi++) {
            my $module_name = "tightly_coupled_instruction_master_${cmi}";
            e_blind_instance->add({
                use_sim_models => 1,
                name => "tightly_coupled_instruction_master_${cmi}_ecc_decoder",
                module => "tightly_coupled_instruction_master_0_ecc_decoder_module",
                in_port_map => {
                    data          => "icm${cmi}_readdata",
                },
                out_port_map => {
                    q             => "icm${cmi}_instword",
                    one_bit_err   => "icm${cmi}_one_bit_err_nxt",
                    two_bit_err   => "icm${cmi}_two_bit_err_nxt",
                    corrected_data => "icm${cmi}_corrected_data_nxt",
                    one_two_or_three_bit_err     => "icm${cmi}_one_two_three_bit_err",
                },
            });
        }


        for (my $cmi = 0; 
          $cmi < manditory_int($Opt, "num_tightly_coupled_instruction_masters");
          $cmi++) {
            my $master_name = "tightly_coupled_instruction_master_${cmi}";
            my $sel_name = "F_sel_" . $master_name;
            my $data_name = "icm${cmi}_instword";
        
            if ($cmi == (manditory_int($Opt, 
              "num_tightly_coupled_instruction_masters") - 1)) {
                push(@ram_iw_mux_table,
                  "1'b1" => $data_name);
            } else {
                push(@ram_iw_mux_table,
                  $sel_name => $data_name);
            }
            
            e_register->adds(
                {out => ["D_icm${cmi}_writedata", $ecc_data_sz],    in => "icm${cmi}_corrected_data_nxt",
                 enable => "D_en"},
                {out => ["E_icm${cmi}_writedata", $ecc_data_sz],    in => "D_icm${cmi}_writedata",
                 enable => "E_en"},
                {out => ["M_icm${cmi}_writedata", $ecc_data_sz],    in => "E_icm${cmi}_writedata",
                 enable => "M_en"},
                {out => ["D_icm${cmi}_one_bit_err", 1],    in => "W_config_reg_eccen & icm${cmi}_one_bit_err_nxt",
                 enable => "D_en"},
                {out => ["E_icm${cmi}_one_bit_err", 1],    in => "D_icm${cmi}_one_bit_err",
                 enable => "E_en"},
                {out => ["M_icm${cmi}_one_bit_err", 1],    in => "E_icm${cmi}_one_bit_err",
                 enable => "M_en"},

                {out => ["D_icm${cmi}_two_bit_err", 1],    in => "W_ecc_exc_enabled & icm${cmi}_two_bit_err_nxt",
                 enable => "D_en"},
                 

                {out => ["itcm${cmi}_re", 1],    in => "icm${cmi}_one_bit_err_nxt",
                 enable => "1'b1"},         
                {out => ["itcm${cmi}_ue", 1],    in => "icm${cmi}_two_bit_err_nxt",
                 enable => "1'b1"},
            );


            e_signal->adds({ name => "icm${cmi}_one_two_three_bit_err", width => 1, never_export => 1 });
            
            push(@tcim_ecc_error, "D_icm${cmi}_two_bit_err");
        }
        
        new_exc_signal({
            exc             => $ecc_inst_error_exc,
            initial_stage   => "D", 
            rhs             => join(" | ", @tcim_ecc_error),
        });
    } else {
        for (my $cmi = 0; 
          $cmi < manditory_int($Opt, "num_tightly_coupled_instruction_masters");
          $cmi++) {
            my $master_name = "tightly_coupled_instruction_master_${cmi}";
            my $sel_name = "F_sel_" . $master_name;
            my $data_name = "icm${cmi}_readdata";
        
            if ($cmi == (manditory_int($Opt, 
              "num_tightly_coupled_instruction_masters") - 1)) {
                push(@ram_iw_mux_table,
                  "1'b1" => $data_name);
            } else {
                push(@ram_iw_mux_table,
                  $sel_name => $data_name);
            }
        }
    }

    e_mux->add ({
      lhs => ["F_ram_iw", $datapath_sz],
      type => "priority",
      table => \@ram_iw_mux_table,
      });





    if ($icache_present) {
        e_assign->adds(
          [["F_inst_ram_hit", 1], 
            "(F_ic_hit & ~($inst_crst_next_stage)) | 
             ~F_sel_instruction_master"],
        );
    } else {
        e_assign->adds(
          [["F_inst_ram_hit", 1], "1'b1"],
        );
    }

    if ($tlb_present) {
        my $match_mux_vaddr = not_empty_scalar($Opt, "uitlb_match_mux_vaddr");
        my $match_mux_paddr = not_empty_scalar($Opt, "uitlb_match_mux_paddr");

        e_assign->adds(




          [["F_iw_valid", 1], 
            "${match_mux_paddr}_got_pfn & 
              (F_inst_ram_hit | (~${match_mux_vaddr}_bypass_tlb & F_uitlb_m))"],
        );
    } else {
        e_assign->adds(

          [["F_iw_valid", 1], "F_inst_ram_hit"],
        );
    }






    e_assign->adds(
      [["F_issue", 1], "F_iw_valid & ~F_kill"],
    );

    if ($Opt->{full_waveform_signals} && (scalar(@sel_signals) > 1)) {
        push(@plaintext_wave_signals, 
            { divider => "instruction_master_sel" },
        );

        foreach my $sel_signal (@sel_signals) {
            push(@plaintext_wave_signals, 
              { radix => "x", signal => $sel_signal },
            );
        }
    }
}




sub 
gen_tlb_inst
{
    my $Opt = shift;

    my $whoami = "TLB instruction";

    my $cs = not_empty_scalar($Opt, "control_reg_stage");

    e_assign->adds(

      [["F_pc_vpn", $mmu_addr_vpn_sz], 
        "F_pc[$mmu_addr_vpn_msb-2:$mmu_addr_vpn_lsb-2]"], 
      [["D_pc_vpn", $mmu_addr_vpn_sz], 
        "D_pc[$mmu_addr_vpn_msb-2:$mmu_addr_vpn_lsb-2]"], 


      [["F_pc_page_offset", $mmu_addr_page_offset_sz-2], 
        "F_pc[$mmu_addr_page_offset_msb-2:$mmu_addr_page_offset_lsb]"], 


      [["F_pc_kernel_region", 1],
        "F_pc[$mmu_addr_kernel_region_msb-2:$mmu_addr_kernel_region_lsb-2]
          == $mmu_addr_kernel_region"],

      [["F_pc_io_region", 1],
        "F_pc[$mmu_addr_io_region_msb-2:$mmu_addr_io_region_lsb-2]
          == $mmu_addr_io_region"],

      [["D_pc_user_region", 1],
        "D_pc[$mmu_addr_user_region_msb-2:$mmu_addr_user_region_lsb-2]
          == $mmu_addr_user_region"],
      [["D_pc_supervisor_region", 1], "~D_pc_user_region"],

      [["D_pc_kernel_region", 1],
        "D_pc[$mmu_addr_kernel_region_msb-2:$mmu_addr_kernel_region_lsb-2]
          == $mmu_addr_kernel_region"],

      [["D_pc_io_region", 1],
        "D_pc[$mmu_addr_io_region_msb-2:$mmu_addr_io_region_lsb-2]
          == $mmu_addr_io_region"],


      [["F_pc_bypass_tlb", 1], "F_pc_kernel_region | F_pc_io_region"],
      [["D_pc_bypass_tlb", 1], "D_pc_kernel_region | D_pc_io_region"],
    );



    my $supervisor_inst_addr_exc_sig = new_exc_signal({
        exc             => $supervisor_inst_addr_exc,
        initial_stage   => "D",
        rhs             => "D_pc_supervisor_region & ${cs}_status_reg_u",
    });





    my $tlb_inst_miss_exc_sig = new_exc_signal({
        exc             => $tlb_inst_miss_exc,
        initial_stage   => "D",
        rhs             => "~D_pc_bypass_tlb & D_uitlb_m",
    });





    my $tlb_x_perm_exc_sig = new_exc_signal({
        exc             => $tlb_x_perm_exc,
        initial_stage   => "D", 
        rhs             => "~D_pc_bypass_tlb & ~D_uitlb_x",
    });


    my $uitlb_wave_signals = nios2_mmu::make_utlb($Opt, 0);


    e_register->adds(
      {out => ["D_uitlb_x", 1], 
       in => "F_uitlb_x",                       enable => "D_en"},
      {out => ["D_uitlb_m", 1], 
       in => "F_uitlb_m",                       enable => "D_en"},
      {out => ["D_pc_phy_got_pfn", 1], 
       in => "F_pc_phy_got_pfn",                enable => "D_en"},
      {out => ["D_pc_phy_pfn_valid", 1], 
       in => "F_pc_phy_pfn_valid",              enable => "D_en"},
      {out => ["D_pcb_phy", manditory_int($Opt, "i_Address_Width"),
       0, $force_never_export], 
       in => "F_pcb_phy",                       enable => "D_en"},
      {out => ["D_uitlb_index", $uitlb_index_sz],
      in => "F_uitlb_index",                    enable => "D_en"},
    );


    if ($ecc_present && $mmu_ecc_present) {        
        my $ecc_itlb_sig = new_exc_signal({
            exc             => $ecc_itlb_error_exc,
            initial_stage   => "D", 
            rhs             => "D_uitlb_two_bit_err",
        });

        my $tlb_way_sz = get_control_reg_field_sz($tlbmisc_reg_way);
        e_register->adds(
          {out => ["D_uitlb_two_bit_err", 1], 
           in => "F_uitlb_two_bit_err",         enable => "D_en"},
          {out => ["D_uitlb_way", $tlb_way_sz], 
           in => "F_uitlb_way",                 enable => "D_en"},
        );
    }

    if ($Opt->{full_waveform_signals}) {
        push(@plaintext_wave_signals, 
          @$uitlb_wave_signals,
          { divider => "TLB instruction Exceptions" },
          { radix => "x", signal => $supervisor_inst_addr_exc_sig },
          { radix => "x", signal => $tlb_inst_miss_exc_sig },
          { radix => "x", signal => $tlb_x_perm_exc_sig },
        );
    }
}




sub 
gen_impu
{
    my $Opt = shift;

    my $whoami = "IMPU";

    my $cs = not_empty_scalar($Opt, "control_reg_stage");


    e_mux->add ({
      lhs => ["D_impu_good_perm", 1],
      selecto => "D_impu_perm",
      table => [
        $mpu_inst_perm_super_none_user_none => "0",
        $mpu_inst_perm_super_exec_user_none => "~${cs}_status_reg_u",
        $mpu_inst_perm_super_exec_user_exec => "1",
        ],
      default => "0",
    });






    my @impu_exc_conds = ("~D_impu_hit", "~D_impu_good_perm");

    my $unused_pc_msb = 29;
    my $unused_pc_lsb = manditory_int($Opt, "i_Address_Width") - 2;
    my $unused_pc_sz = $unused_pc_msb - $unused_pc_lsb + 1;

    if ($unused_pc_sz > 0) {
        push(@impu_exc_conds, "(D_pc[$unused_pc_msb:$unused_pc_lsb] != 0)");
    }

    new_exc_signal({
        exc             => $mpu_inst_region_violation_exc,
        initial_stage   => "D", 
        rhs             => 
          "${cs}_config_reg_pe & ~W_debug_mode & " .
          "(" . join('|', @impu_exc_conds) . ")",
    });


    my $impu_region_wave_signals = nios2_mpu::make_mpu_regions($Opt, 0);


    e_register->adds(
      {out => ["D_impu_hit", 1], 
       in => "F_impu_hit",                      enable => "D_en"},
      {out => ["D_impu_perm", $mpu_inst_perm_sz], 
       in => "F_impu_perm",                     enable => "D_en"},
    );

    if ($Opt->{full_waveform_signals}) {
        push(@plaintext_wave_signals, 
          @$impu_region_wave_signals,
          { divider => "IMPU Exceptions" },
          get_exc_signal_wave($mpu_inst_region_violation_exc, "D"),
        );
    }
}

1;
