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






















package nevada_frontend;
use Exporter;
@ISA = Exporter;
@EXPORT = qw(
);

use cpu_utils;
use cpu_wave_signals;
use cpu_file_utils;
use cpu_exception_gen;
use europa_all;
use europa_utils;
use nios_utils;
use nios_addr_utils;
use nios_avalon_masters;
use nios_isa;
use nios_icache;
use nevada_isa;
use nevada_insts;
use nevada_control_regs;
use nevada_mmu;
use nevada_exceptions;
use nevada_common;
use strict;


















sub 
gen_ram_instruction_word_mux
{
    my $Opt = shift;

    my $whoami = "RAM instruction word mux";

    my $inst_soft_reset_next_stage = 
      not_empty_scalar($Opt, "inst_soft_reset_next_stage");



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
      master_paddr_mapper_func => \&nevada_mmu::master_paddr_mapper,
    });




    my @ram_iw_mux_table = (
      "F_ic_bypass_hit"          => "i_readdata_d1",
      "F_sel_instruction_master" => "F_ic_iw",
    );

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

    e_mux->add ({
      lhs => ["F_ram_iw", $datapath_sz],
      type => "priority",
      table => \@ram_iw_mux_table,
      });






    e_assign->adds(
      [["F_inst_ram_hit", 1], 
        "(F_ic_hit & ~($inst_soft_reset_next_stage)) | 
         ~F_sel_instruction_master |
         F_ic_bypass_hit"],
    );

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
decode_mmu_inst_regions
{
    my $Opt = shift;

    my $whoami = "Decode MMU inst regions";

    e_assign->adds(

      [["F_pcb_kernel_region", 1],
        "F_pcb[$mmu_addr_kernel_region_msb:$mmu_addr_kernel_region_lsb]
          == $mmu_addr_kernel_region"],

      [["F_pcb_io_region", 1],
        "F_pcb[$mmu_addr_io_region_msb:$mmu_addr_io_region_lsb]
          == $mmu_addr_io_region"],

      [["F_pcb_user_region", 1, 0, $force_never_export],
        "F_pcb[$mmu_addr_user_region_msb:$mmu_addr_user_region_lsb]
          == $mmu_addr_user_region"],

      [["F_pcb_dseg_region", 1],
        "(F_pcb[$mmu_addr_dseg_region_msb:$mmu_addr_dseg_region_lsb]
          == $mmu_addr_dseg_region) & W_debug_mode"],

      [["D_pcb_kernel_region", 1, 0, $force_never_export],
        "D_pcb[$mmu_addr_kernel_region_msb:$mmu_addr_kernel_region_lsb]
          == $mmu_addr_kernel_region"],

      [["D_pcb_io_region", 1, 0, $force_never_export],
        "D_pcb[$mmu_addr_io_region_msb:$mmu_addr_io_region_lsb]
          == $mmu_addr_io_region"],

      [["D_pcb_user_region", 1],
        "D_pcb[$mmu_addr_user_region_msb:$mmu_addr_user_region_lsb]
          == $mmu_addr_user_region"],

      [["D_pcb_privileged_region", 1], "~D_pcb_user_region"],
    );

    if ($tlb_present) {
        e_assign->adds(


          [["F_pcb_bypass_tlb", 1], 
            "F_pcb_kernel_region | 
             F_pcb_io_region |
             F_pcb_dseg_region |
             (F_pcb_user_region & W_cop0_status_reg_erl)"],
        );

        e_register->adds(
          {out => ["D_pcb_bypass_tlb", 1],
           in => "F_pcb_bypass_tlb",              enable => "D_en"},
        );
    }


    e_register->adds(
      {out => ["D_pcb_dseg_region", 1, 0, $force_never_export],
       in => "F_pcb_dseg_region",             enable => "D_en"},
    );




    my $inst_addr_err_exc_sig = new_exc_signal({
        exc             => $inst_addr_err_exc,
        initial_stage   => "D",
        rhs             => 
          "(D_pcb_privileged_region & W_user_mode) | (D_pcb[1:0] != 2'b00)",
    });

    if ($Opt->{full_waveform_signals}) {
        push(@plaintext_wave_signals, 
          { divider => "MMU Inst Regions" },
          { radix => "x", signal => "D_pcb_kernel_region" },
          { radix => "x", signal => "D_pcb_io_region" },
          { radix => "x", signal => $inst_addr_err_exc_sig },
        );
    }
}




sub 
gen_tlb_inst
{
    my $Opt = shift;

    my $whoami = "TLB instruction";

    my $cs = not_empty_scalar($Opt, "control_reg_stage");

    e_assign->adds(

      [["F_pcb_vpn_nxt", $mmu_addr_vpn_sz], 
        "F_pcb_nxt[$mmu_addr_vpn_msb:$mmu_addr_vpn_lsb]"], 
      [["F_pcb_vpn", $mmu_addr_vpn_sz], 
        "F_pcb[$mmu_addr_vpn_msb:$mmu_addr_vpn_lsb]"], 
      [["D_pcb_vpn", $mmu_addr_vpn_sz], 
        "D_pcb[$mmu_addr_vpn_msb:$mmu_addr_vpn_lsb]"], 


      [["F_pcb_page_offset", $mmu_addr_page_offset_sz], 
        "F_pcb[$mmu_addr_page_offset_msb:$mmu_addr_page_offset_lsb]"], 
    );






    my $tlb_inst_refill_exc_sig = new_exc_signal({
        exc             => $tlb_inst_refill_exc,
        initial_stage   => "D",
        rhs             => "~D_pcb_bypass_tlb & D_uitlb_m",
    });



    my $tlb_inst_invalid_exc_sig = new_exc_signal({
        exc             => $tlb_inst_invalid_exc,
        initial_stage   => "D", 
        rhs             => "~D_pcb_bypass_tlb & ~D_uitlb_v",
    });


    my $uitlb_wave_signals_array = nevada_mmu::make_utlb($Opt, 0);


    e_register->adds(
      {out => ["D_uitlb_v", 1], 
       in => "F_uitlb_v",                       enable => "D_en"},
      {out => ["D_uitlb_m", 1], 
       in => "F_uitlb_m",                       enable => "D_en"},
      {out => ["D_pcb_phy_got_pfn", 1], 
       in => "F_pcb_phy_got_pfn",               enable => "D_en"},
      {out => ["D_pcb_phy_pfn_valid", 1], 
       in => "F_pcb_phy_pfn_valid",             enable => "D_en"},
      {out => ["D_uitlb_index", $uitlb_index_sz],
      in => "F_uitlb_index",                    enable => "D_en"},
    );

    if ($Opt->{full_waveform_signals}) {
        foreach my $uitlb_wave_signals (@$uitlb_wave_signals_array) {
            push(@plaintext_wave_signals, @$uitlb_wave_signals);
        }

        push(@plaintext_wave_signals, 
          { divider => "TLB instruction Exceptions" },
          { radix => "x", signal => $tlb_inst_refill_exc_sig },
          { radix => "x", signal => $tlb_inst_invalid_exc_sig },
        );
    }
}




sub
make_icache_controls
{
    my $Opt = shift;

    if (!$icache_present) {
        &$error("I-cache isn't present");
    }

    my @icache_bypass_wave_signals = (
      { divider => "I-cache Bypass" },
      { radix => "x", signal => "F_pcb_io_region" },
      { radix => "x", signal => "F_pcb_dseg_region" },
      { radix => "x", signal => "F_pcb_kernel_region" },
      { radix => "x", signal => "W_cop0_config_reg_k0" },
    );






    my @always_bypass = (
        "F_pcb_io_region",
        "F_pcb_dseg_region",
    );

    if ($tlb_present) {
        push(@always_bypass,
          "(F_pcb_user_region & W_cop0_status_reg_erl)",
        );

        push(@icache_bypass_wave_signals,
          { radix => "x", signal => "F_pcb_user_region" },
          { radix => "x", signal => "W_cop0_status_reg_erl" },
        );
    }

    my $bypass_table = [
      join('|', @always_bypass)             => "1",

      "F_pcb_kernel_region"                 =>
        "W_cop0_config_reg_k0 == $coherency_uncached",
    ];

    if ($tlb_present) {
        push(@$bypass_table,
          "1'b1"                            => "~F_uitlb_c",
        );

        push(@icache_bypass_wave_signals,
          { radix => "x", signal => "F_uitlb_c" },
        );
    } else {
        push(@$bypass_table,
          "F_pcb_user_region"    =>
            "W_cop0_status_reg_erl ? 
               1 : 
               (W_cop0_config_reg_ku == $coherency_uncached)",

          "1'b1"                      =>
            "W_cop0_config_reg_k23 == $coherency_uncached",
        );

        push(@icache_bypass_wave_signals,
          { radix => "x", signal => "F_pcb_user_region" },
          { radix => "x", signal => "W_cop0_status_reg_erl" },
          { radix => "x", signal => "W_cop0_config_reg_ku" },
          { radix => "x", signal => "W_cop0_config_reg_k23" },
        );
    }

    e_mux->adds({
      lhs => ["F_ic_bypass_req_unfiltered", 1],
      type => "priority",
      table => $bypass_table,
    });


    create_x_filter({
      lhs       => "F_ic_bypass_req",
      rhs       => "F_ic_bypass_req_unfiltered",
      sz        => 1,
    });

    e_assign->adds(




      [["F_pc_eq_bypass_pc",1], "F_pc == ic_bypass_pc"],




      [["F_ic_bypass_hit",1], "F_pc_eq_bypass_pc & ic_bypass_valid"],


      [["D_ic_want_bypass",1], not_empty_scalar($Opt, "D_ic_want_bypass")],



      [["ic_bypass_active_nxt",1],
        "D_ic_bypass_starting | (ic_bypass_active & ~iw_readdata_valid)"],








      [["ic_bypass_valid_nxt",1],
        "M_pipe_flush        ? 0 :
         ic_bypass_valid     ? ~(F_ic_bypass_hit & F_en) :
                                (ic_bypass_active & iw_readdata_valid & 
                                 ~ic_bypass_flushed)"],


      [["D_ic_bypass_starting",1],
        "D_ic_want_bypass & ~ic_bypass_active & ~ic_fill_active &
          ~(ic_bypass_valid & D_refetch)"],



      [["D_ic_bypass_start_avalon_read",1],
        "D_ic_bypass_starting & ~W_ejtagboot_active"],
         





      [["iw_readdata_valid",1],
        "i_readdatavalid_d1 | W_ejtagboot_active"],
    );

    e_register->adds(
      {out => ["D_ic_bypass_req", 1],
      in => "F_ic_bypass_req",
      enable => "D_en"},



      {out => ["ic_bypass_active", 1],
      in => "ic_bypass_active_nxt",
      enable => "1"},



      {out => ["ic_bypass_flushed", 1],
      in => "D_ic_bypass_starting ? 0 :
             ic_bypass_flushed    ? ic_bypass_active_nxt :
                                    (ic_bypass_active & M_pipe_flush)",
      enable => "1"},



      {out => ["ic_bypass_valid", 1],
      in => "ic_bypass_valid_nxt",
      enable => "1"},



      {out => ["ic_bypass_pc", $pc_sz],
      in => "D_pc",
      enable => "D_ic_bypass_starting"},
    );

    if ($Opt->{full_waveform_signals}) {
        push(@plaintext_wave_signals, 
          @icache_bypass_wave_signals,
          { radix => "x", signal => "F_ic_bypass_req" },
          { radix => "x", signal => "F_pc_eq_bypass_pc" },
          { radix => "x", signal => "F_ic_bypass_hit" },
          { radix => "x", signal => "D_ic_want_bypass" },
          { radix => "x", signal => "D_ic_bypass_starting" },
          { radix => "x", signal => "D_ic_bypass_start_avalon_read" },
          { radix => "x", signal => "ic_bypass_active" },
          { radix => "x", signal => "ic_bypass_flushed" },
          { radix => "x", signal => "ic_bypass_valid" },
          { radix => "x", signal => "ic_bypass_pc" },
          { radix => "x", signal => "iw_readdata_valid" },
        );
    }
}
1;
