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






















package nevada_backend_500;
use Exporter;
@ISA = Exporter;
@EXPORT = qw(
    &nevada_be500_make_backend
);

use cpu_utils;
use cpu_wave_signals;
use cpu_file_utils;
use cpu_gen;
use cpu_inst_gen;
use cpu_exception_gen;
use europa_all;
use europa_utils;
use nios_utils;
use nios_europa;
use nios_addr_utils;
use nios_sdp_ram;
use nios_avalon_masters;
use nios_brpred;
use nios_common;
use nios_isa;
use nios_icache;
use nios_dcache;
use nios_div;
use nios_shift_rotate;
use nios_backend_500;
use nevada_isa;
use nevada_insts;
use nevada_control_regs;
use nevada_frontend;
use nevada_mmu;
use nevada_exceptions;
use nevada_common;
use nevada_backend;
use nevada_backend_control_regs;
use nevada_mul;
use nevada_bit_inst;

use strict;











sub 
nevada_be500_make_backend
{
    my $Opt = shift;

    &$progress("    Pipeline back-end");




    nios_backend_500::gen_backend_500($Opt);

    be_make_alu($Opt);
    be_make_stdata($Opt);
    if ($debug_port_present) {
        be_make_debug_port($Opt);
    }
    if ($soft_reset_present) {
        be_make_soft_reset($Opt);
    }




    make_base_pipeline($Opt);
    make_fetch_npcb($Opt);
    make_reg_cmp($Opt);
    make_src_operands($Opt);
    make_interrupts($Opt);

    nevada_mul::gen_mul($Opt);
    nevada_bit_inst::gen_bit_inst($Opt);

    make_dcache_controls($Opt);
    nevada_frontend::make_icache_controls($Opt);

    if ($mmu_present) {
        decode_mmu_data_regions($Opt);

        if ($tlb_present) {
            &$progress("      Micro-DTLB");
            make_tlb_data($Opt);
        } else {
            &$progress("      DFMT");
            my $dfmt_wave_signals = nevada_mmu::make_fmt($Opt, 1);
    
            if ($Opt->{full_waveform_signals}) {
                push(@plaintext_wave_signals, @$dfmt_wave_signals);
            } 
        }
    } else {
        e_assign->adds(

          [["E_mem_baddr_privileged_region", 1], "0"],
        );
    }
}





sub 
make_base_pipeline
{
    my $Opt = shift;

    my $whoami = "backend 500 base pipeline";

    my $ds          = not_empty_scalar($Opt, "dispatch_stage");
    my $lo_accum_s  =  not_empty_scalar($Opt, "lo_accum_s");
    my $hi_accum_s  =  not_empty_scalar($Opt, "hi_accum_s");
    my $hi_s        =  not_empty_scalar($Opt, "hi_s");
    my $lo_s        =  not_empty_scalar($Opt, "lo_s");
    my $extins_s    =  not_empty_scalar($Opt, "extins_s");
    my $bit;

    my @pipe_flush_wave_signals = (
        { divider => "pipe_flush" },
    );

    my @exc_wave_signals = (
        { divider => "exceptions" },
    );










    e_assign->adds(
      [["D_stall", 1], "D_dep_stall | D_extra_stall | E_stall"],
      [["D_en", 1], "~D_stall"],        


      [["D_dep_stall", 1], "D_data_depend & D_issue & ~M_pipe_flush"],


      [["D_extra_stall_unfiltered", 1], 
        "D_need_extra_stall & ~D_extra_stall_done & ~M_pipe_flush"],



      [["D_need_extra_stall", 1], "D_issue_jmp_indirect | D_issue_ehb"],

      [["D_issue_jmp_indirect", 1], "D_issue & D_ctrl_jmp_indirect"],






      [["D_issue_ehb", 1], "D_issue & D_ctrl_ehb_inst"],































      [["D_extra_stall_done_nxt", 1], 
        "(D_extra_stall_done | M_pipe_flush) ? 0 :
         (
           (
             (D_issue_jmp_indirect & ~D_data_depend & (~D_iw_hint | ~E_valid)) |
             D_issue_ehb
           ) & ~E_stall
         )"],
      );



    new_exc_combo_signal({
        name                => "D_exc_invalidates_inst_value",
        stage               => "D",
        invalidates_inst_value          => 1,
    });




    create_x_filter({
      lhs       => "D_extra_stall",
      rhs       => "D_extra_stall_unfiltered",
      sz        => 1,
      qual_expr => "D_exc_invalidates_inst_value",
    });

    e_register->adds(
      {out => ["D_iw", $iw_sz],                 in => "${ds}_iw",     
       enable => "D_en"},
      {out => ["D_pcb", $pcb_sz],               in => "${ds}_pcb", 
       enable => "D_en"},
      {out => ["D_pc_plus_one", $pc_sz],        in => "${ds}_pc_plus_one",
       enable => "D_en"},
      {out => ["D_extra_stall_done", 1],        in => "D_extra_stall_done_nxt",
       enable => "1"},
      );

    e_assign->adds(

      [["D_pc", $pc_sz], "D_pcb[$pcb_sz-1:2]"],
    );





    e_assign->adds(






      [["D_valid", 1], 
        "D_issue & ~D_data_depend & ~D_extra_stall & ~M_pipe_flush"],
    );





    e_register->adds(


















      {out => ["D_jmp_target_baddr", $pcb_sz],  
       in => "(D_issue_jmp_indirect & D_stall) ? D_src1[$pcb_sz-1:0] : 
              D_stall                          ? D_jmp_target_baddr :
                                                 F_jmp_direct_target_baddr", 
       enable => "1"},
    );







    e_assign->adds(
      [["E_stall", 1], "M_stall"],


      [["E_en", 1], "~E_stall"],        
      );


    e_register->adds(
      {out => ["E_valid_from_D", 1],        in => "D_valid",
       enable => "E_en"},
      {out => ["E_iw", $iw_sz],             in => "D_iw", 
       enable => "E_en"},
      {out => ["E_dst_regnum", $regnum_sz], in => "D_dst_regnum", 
       enable => "E_en" },
      {out => ["E_wr_dst_reg_from_D", 1],   in => "D_wr_dst_reg", 
       enable => "E_en"},
      {out => ["E_pcb", $pcb_sz],           in => "D_pcb", 
       enable => "E_en"},
      {out => ["E_pc_plus_one", $pc_sz],    in => "D_pc_plus_one",
       enable => "E_en"},
      {out => ["E_pc_plus_two", $pc_sz],    in => "D_pc_plus_one+1",
       enable => "E_en"},
      {out => ["E_br_taken_waddr", $pc_sz], in => "D_br_taken_waddr",
       enable => "E_en"},
      );

    if ($tlb_present) {
        my $E_tlb_inst_refill_exc =
          get_exc_signal_name($tlb_inst_refill_exc, "E");

        e_assign->adds(



          [["E_valid_uitlb_lru_access", 1], 
            "E_valid_from_D & ~E_pcb_bypass_tlb & ~$E_tlb_inst_refill_exc"],
        );

        e_register->adds(
          {out => ["E_pcb_bypass_tlb", 1],
           in => "D_pcb_bypass_tlb",     enable => "E_en"},
          {out => ["E_uitlb_index", $uitlb_index_sz],
           in => "D_uitlb_index",       enable => "E_en"},
        );
    }





    e_assign->adds(


      [["E_mfmc0_reserved", 1], "E_is_mfmc0_inst &" .
        " ((E_iw_sa != 0) | (E_iw_rd != $cop0_status_reg_regnum))"],
    );

    if ($debug_port_present) {

        new_exc_signal({
            exc             => $sdbpp_inst_exc,
            initial_stage   => "E", 
            speedup_stage   => "E",
            rhs             => "E_op_sdbbp",
        });


        new_exc_signal({
            exc             => $debug_interrupt_exc,
            initial_stage   => "E", 
            rhs             => "(debug_intr_d1 ) & ~W_debug_mode",
        });


        new_exc_signal({
            exc             => $debug_hwbp_exc,
            initial_stage   => "E",
            rhs             => "(debug_hwbp_d1 ) & ~W_debug_mode",
        });


        push(@exc_wave_signals,
          get_exc_signal_wave($sdbpp_inst_exc, "E"),
          get_exc_signal_wave($debug_interrupt_exc, "E"),
          get_exc_signal_wave($debug_hwbp_exc, "E"),
        );
    }

    e_assign->adds(

      [["W_cop0_enabled", 1], 
         "W_cop0_status_reg_cu0 | W_kernel_mode | W_debug_mode"],
    );


    new_exc_signal({
        exc             => $cop0_unusable_exc,
        initial_stage   => "E", 
        speedup_stage   => "E",
        rhs             => "E_ctrl_cop0 & ~W_cop0_enabled",
    });



    new_exc_signal({
        exc             => $cop1_unusable_exc,
        initial_stage   => "E", 
        speedup_stage   => "E",
        rhs             => "E_ctrl_cop1_or_cop1x",
    });


    new_exc_signal({
        exc             => $cop2_unusable_exc,
        initial_stage   => "E", 
        speedup_stage   => "E",
        rhs             => "E_ctrl_cop2",
    });


    new_exc_signal({
        exc             => $reserved_inst_exc,
        initial_stage   => "E", 
        speedup_stage   => "E",
        rhs             => 
          "E_ctrl_reserved | E_rdhwr_reserved | E_mfmc0_reserved",
    });


    new_exc_signal({
        exc             => $trap_inst_exc,
        initial_stage   => "E", 
        speedup_stage   => "E",
        rhs             => "E_ctrl_trap & E_trap_result",
    });


    new_exc_signal({
        exc             => $syscall_inst_exc,
        initial_stage   => "E", 
        speedup_stage   => "E",
        rhs             => "E_op_syscall",
    });


    new_exc_signal({
        exc             => $break_inst_exc,
        initial_stage   => "E", 
        speedup_stage   => "E",
        rhs             => "E_op_break",
    });





    new_exc_signal({
        exc             => $load_addr_err_exc,
        initial_stage   => "E", 
        speedup_stage   => "E",
        rhs             => 
          "(E_ctrl_ld32 & (E_arith_result[1:0] != 2'b00)) |
           (E_ctrl_ld16 & (E_arith_result[0]   != 1'b0)) |
           (E_ctrl_ld_addr & E_mem_baddr_privileged_region & W_user_mode)",
    });




    new_exc_signal({
        exc             => $store_addr_err_exc,
        initial_stage   => "E", 
        speedup_stage   => "E",
        rhs             => 
          "(E_ctrl_st32 & (E_arith_result[1:0] != 2'b00)) |
           (E_ctrl_st16 & (E_arith_result[0]   != 1'b0)) |
           (E_ctrl_st & E_mem_baddr_privileged_region & W_user_mode)",
    });

    push(@exc_wave_signals,
      get_exc_signal_wave($cop0_unusable_exc, "E"),
      get_exc_signal_wave($reserved_inst_exc, "E"),
      get_exc_signal_wave($trap_inst_exc, "E"),
      get_exc_signal_wave($syscall_inst_exc, "E"),
      get_exc_signal_wave($break_inst_exc, "E"),
      get_exc_signal_wave($load_addr_err_exc, "E"),
      get_exc_signal_wave($store_addr_err_exc, "E"),
    );





    e_assign->adds(


      [["E_valid", 1], "E_valid_from_D & ~E_cancel"],



      [["E_wr_dst_reg", 1], "E_wr_dst_reg_from_D & ~E_cancel & ~E_mov_cancel"],



      [["E_cancel", 1], "M_pipe_flush"],





      [["M_pipe_flush_nxt", 1], "E_br_mispredict | A_pipe_flush_nxt"],














      [["M_br_mispredict_pc_nxt", $pc_sz], 
         "E_ctrl_br_likely ? E_pc_plus_two : E_pc_plus_one"],


      [["E_src2_eq_zero", 1], "E_src2 == 0"],


      [["E_mov_cancel", 1], 
        "(E_op_movz ? !E_src2_eq_zero : 
          E_op_movn ? E_src2_eq_zero : 
                      0) & E_valid"],
    );


    e_signal->adds({name => "M_br_mispredict_pcb_nxt", never_export => 1, 
      width => $pcb_sz});
    e_assign->adds(["M_br_mispredict_pcb_nxt", 
      "{M_br_mispredict_pc_nxt, 2'b00}"]);








    my $cmp_mem_baddr_sz = 
      $mmu_present ? 32 : manditory_int($Opt, "d_Address_Width");

    my $avalon_master_info = manditory_hash($Opt, "avalon_master_info");


    my @sel_signals = make_master_address_decoder({
      avalon_master_info    => $avalon_master_info,
      normal_master_name    => "data_master",
      tightly_coupled_master_names => manditory_array($avalon_master_info,
        "avalon_tightly_coupled_data_master_list"), 
      addr_signal           => "E_mem_baddr[$cmp_mem_baddr_sz-1:0]",
      addr_sz               => $cmp_mem_baddr_sz, 
      sel_prefix            => "E_sel_",
      mmu_present           => $mmu_present,
      master_paddr_mapper_func => \&nevada_mmu::master_paddr_mapper,
    });





    my $dc_bytes_per_line = 
      $dcache_present ? manditory_int($Opt, "cache_dcache_line_size") : 0;
    my $ic_bytes_per_line = 
      $icache_present ? manditory_int($Opt, "cache_icache_line_size") : 0;

    my $synci_step;

    if ($dcache_present && !$icache_present) {
        $synci_step = $dc_bytes_per_line;
    } elsif (!$dcache_present && $icache_present) {
        $synci_step = $ic_bytes_per_line;
    } elsif ($dcache_present && $icache_present) {

        $synci_step = 
          ($dc_bytes_per_line < $ic_bytes_per_line) ?
            $dc_bytes_per_line :
            $ic_bytes_per_line;
    } else {

        $synci_step = 0;
    }


    e_mux->add({
      lhs => ["E_rdhwr_data", $datapath_sz],
      selecto => "E_iw_rd",
      table => [
        $cop0_hwr_ena_reg_cpu_num_lsb    => 
          manditory_int($Opt, "ebase_cpu_num"),
        $cop0_hwr_ena_reg_synci_step_lsb => $synci_step,
        $cop0_hwr_ena_reg_cc_lsb         => "W_cop0_count_reg",
        ],


      default                           => "1",
    });




    e_mux->add({
      lhs => ["E_rdhwr_rd_implemented", 1],
      selecto => "E_iw_rd",
      table => [
        $cop0_hwr_ena_reg_cpu_num_lsb    => "1",
        $cop0_hwr_ena_reg_synci_step_lsb => "1",
        $cop0_hwr_ena_reg_cc_lsb         => "1",
        $cop0_hwr_ena_reg_cc_res_lsb     => "1",
        ],

      default                            => "0",
    });




    e_mux->add({
      lhs => ["E_rdhwr_rd_enabled", 1],
      selecto => "E_iw_rd",
      table => [
        $cop0_hwr_ena_reg_cpu_num_lsb    => "W_cop0_hwr_ena_reg_cpu_num",
        $cop0_hwr_ena_reg_synci_step_lsb => "W_cop0_hwr_ena_reg_synci_step",
        $cop0_hwr_ena_reg_cc_lsb         => "W_cop0_hwr_ena_reg_cc",
        ],


      default                            => "W_cop0_hwr_ena_reg_cc_res",
    });

    e_assign->adds(





      [["E_rdhwr_reserved", 1], 
        "E_op_rdhwr & 
          (~E_rdhwr_rd_implemented | (~E_rdhwr_rd_enabled & ~W_cop0_enabled))"],
    );







    e_assign->adds(
      [["M_stall", 1], "A_stall"],


      [["M_en", 1], "~M_stall"],        
    );

    e_signal->adds(



      {name => "M_cmp_result", never_export => 1, width => 1},
      {name => "M_br_result", never_export => 1, width => 1},
      {name => "M_target_pcb", never_export => 1, width => $pcb_sz},
    );

    e_register->adds(
      {out => ["M_valid_from_E", 1],                in => "E_valid",
       enable => "M_en"},
      {out => ["M_iw",  $iw_sz],                    in => "E_iw",
       enable => "M_en"},
      {out => ["M_mem_byte_en", $byte_en_sz],       in => "E_mem_byte_en",
       enable => "M_en", },
      {out => ["M_alu_result", $datapath_sz],       in => "E_alu_result",
       enable => "M_en"},
        {out => ["M_st_data", $datapath_sz],          in => "E_st_data",
       enable => "M_en"},
      {out => ["M_rdhwr_data", $datapath_sz],       in => "E_rdhwr_data",
       enable => "M_en"},
      {out => ["M_dst_regnum", $regnum_sz],         in => "E_dst_regnum",
       enable => "M_en"},
      {out => "M_cmp_result",                       in => "E_cmp_result",
       enable => "M_en"},
      {out => "M_br_result",                        in => "E_br_result",
       enable => "M_en"},
      {out => ["M_wr_dst_reg_from_E", 1],           in => "E_wr_dst_reg",
       enable => "M_en"},
      {out => "M_target_pcb",                       in => "E_src1[$pcb_sz-1:0]",
       enable => "M_en"},
      {out => ["M_pcb", $pcb_sz],                   in => "E_pcb", 
       enable => "M_en"},
      {out => ["M_br_taken_waddr", $pc_sz],         in => "E_br_taken_waddr",
       enable => "M_en"},
      {out => ["M_pipe_flush", 1],                  in => "M_pipe_flush_nxt",
       enable => "M_en", async_value => "1'b1" },





      {out => ["M_br_mispredict_pc", $pc_sz],    in => "M_br_mispredict_pc_nxt",
       enable => "M_en", async_value => $reset_pc},



      {out => ["M_arith_overflow_if_result_sign_flipped", 1],
       in => 
         "((E_op_add | E_op_addi) & (E_src1[31] == E_src2[31])) |
          (E_op_sub & (E_src1[31] != E_src2[31]))",
       enable => "M_en"},
    );


    foreach my $master (@{$Opt->{avalon_data_master_list}}) {
        e_register->adds(
          {out => ["M_sel_${master}", 1, 0, $force_never_export],
           in => "E_sel_${master}", enable => "M_en"},
        );
    }

    e_assign->adds(

      [["M_br_mispredict_pcb", $pcb_sz], "{M_br_mispredict_pc, 2'b00}"],



      [["M_mem_baddr", $mem_baddr_sz], "M_alu_result[$mem_baddr_sz-1:0]"],
    );




 
    push(@exc_wave_signals,
      { radix => "x", signal => "M_arith_overflow_if_result_sign_flipped" },
      get_exc_signal_wave($arith_overflow_exc, "M"),
      get_exc_signal_wave($interrupt_exc, "M"),
      get_exc_signal_wave($cop0_unusable_exc, "M"),
      get_exc_signal_wave($reserved_inst_exc, "M"),
      get_exc_signal_wave($trap_inst_exc, "M"),
      get_exc_signal_wave($syscall_inst_exc, "M"),
      get_exc_signal_wave($break_inst_exc, "M"),
      get_exc_signal_wave($load_addr_err_exc, "M"),
      get_exc_signal_wave($store_addr_err_exc, "M"),
    );


    new_exc_signal({
        exc             => $arith_overflow_exc,
        initial_stage   => "M", 
        rhs             => "M_arith_overflow_if_result_sign_flipped" .
                             " & (M_src1[31] != M_alu_result[31])",

    });




    new_exc_signal({
        exc             => $interrupt_exc,
        initial_stage   => "M", 
        rhs             => "M_intr_req",
    });

    if ($debug_port_present) {




        new_exc_signal({
            exc             => $debug_single_step_exc,
            initial_stage   => "M", 
            rhs             => "A_single_step_execution_step_done |
                                W_single_step_exception_pending",
        });

        push(@exc_wave_signals,
          get_exc_signal_wave($debug_single_step_exc, "M"),
          get_exc_signal_wave($debug_interrupt_exc, "M"),
          get_exc_signal_wave($debug_hwbp_exc, "M"),
          get_exc_signal_wave($sdbpp_inst_exc, "M"),
        );

        my $A_debug_single_step_exc_nxt = 
          get_exc_nxt_signal_name($debug_single_step_exc, "A");
        my $A_debug_interrupt_exc_nxt = 
          get_exc_nxt_signal_name($debug_interrupt_exc, "A");
        my $A_debug_hwbp_exc_nxt = 
          get_exc_nxt_signal_name($debug_hwbp_exc, "A");
        my $A_sdbpp_inst_exc_nxt = 
          get_exc_nxt_signal_name($sdbpp_inst_exc, "A");

        e_assign->adds(





          [["M_exc_debug", 1], 
            "$A_debug_single_step_exc_nxt | 
             $A_debug_interrupt_exc_nxt |
             $A_debug_hwbp_exc_nxt |
             $A_sdbpp_inst_exc_nxt"],
        );
    } else {
        e_assign->adds(
          [["M_exc_debug", 1], "0"]
        );
    }

    if ($soft_reset_present) {































    } else {
        e_assign->adds(
          [["M_exc_soft_reset", 1, 0, $force_never_export], "0"]
        );
    }

    if ($nmi_present) {
        new_exc_signal({
            exc             => $nmi_exc,
            initial_stage   => "M", 
            rhs             => "0",
        });

        my $A_nmi_exc_nxt = get_exc_nxt_signal_name($nmi_exc, "A");

        e_assign->adds(
          [["M_exc_nmi", 1], "$A_nmi_exc_nxt"],
        );
    } else {
        e_assign->adds(
          [["M_exc_nmi", 1, 0, $force_never_export], "0"]
        );
    }




    new_exc_combo_signal({
        name            => "M_exc_any",
        stage           => "M",
    });

    if ($tlb_present) {
        my $M_tlb_inst_refill_exc =
          get_exc_signal_name($tlb_inst_refill_exc, "M");
        my $M_tlb_inst_invalid_exc =
          get_exc_signal_name($tlb_inst_invalid_exc, "M");
        my $A_tlb_inst_refill_exc_nxt =
          get_exc_nxt_signal_name($tlb_inst_refill_exc, "A");
        my $A_tlb_load_refill_exc_nxt =
          get_exc_nxt_signal_name($tlb_load_refill_exc, "A");
        my $A_tlb_store_refill_exc_nxt =
          get_exc_nxt_signal_name($tlb_store_refill_exc, "A");

        e_assign->adds(






          [["M_exc_fast_tlb_miss", 1], 
            "~W_cop0_status_reg_exl & 
               ($A_tlb_inst_refill_exc_nxt | 
                $A_tlb_load_refill_exc_nxt |
                $A_tlb_store_refill_exc_nxt)"],




          [["M_exc_vpn2", $mmu_addr_vpn2_sz], 
            "($M_tlb_inst_refill_exc | $M_tlb_inst_invalid_exc) ? 
              M_pcb[$mmu_addr_vpn2_msb:$mmu_addr_vpn2_lsb] :
              M_mem_baddr[$mmu_addr_vpn2_msb:$mmu_addr_vpn2_lsb]"],




          [["M_udtlb_access", 1], 
            "M_ctrl_mem_data_access & ~M_mem_baddr_bypass_tlb"],
        );

        push(@exc_wave_signals,
          { radix => "x", signal => "M_exc_fast_tlb_miss" },
          { radix => "x", signal => "M_exc_vpn2" },
          { radix => "x", signal => "M_udtlb_access" },
          get_exc_signal_wave($tlb_inst_refill_exc, "M"),
          get_exc_signal_wave($tlb_inst_invalid_exc, "M"),
          get_exc_signal_wave($tlb_load_refill_exc, "M"),
          get_exc_signal_wave($tlb_store_refill_exc, "M"),
          get_exc_signal_wave($tlb_store_mod_exc, "M"),
        );
    }










    my @ram_rd_data_mux_table = (
        "M_sel_data_master" => "M_dc_rd_data",
    );

    for (my $cmi = 0; 
      $cmi < manditory_int($Opt, "num_tightly_coupled_data_masters"); $cmi++) {
        my $master_name = "tightly_coupled_data_master_${cmi}";
        my $sel_name = "M_sel_" . $master_name;
        my $data_name = "dcm${cmi}_readdata";

        if ($cmi == 
          (manditory_int($Opt, "num_tightly_coupled_data_masters") - 1)) {
            push(@ram_rd_data_mux_table,
              "1'b1" => $data_name);
        } else {
            push(@ram_rd_data_mux_table,
              $sel_name => $data_name);
        }
    }

    e_mux->add ({
      lhs => ["M_ram_rd_data", $datapath_sz],
      type => "priority",
      table => \@ram_rd_data_mux_table,
    });





    e_assign->adds(



      [["M_fwd_reg_data", $datapath_sz], "M_alu_result"],
    );

    e_register->adds(
        {out => ["M_bit_result", $datapath_sz],
        in  => "E_bit_result", enable => "A_en"},
    );











    e_mux->add ({
      lhs => ["M_inst_result", $datapath_sz],
      type => "priority",
      table => [
        "M_ctrl_rdctl_inst"   => "M_rdctl_data",
        "M_ctrl_ld"           => "M_ram_rd_data",
        "M_ctrl_bit"          => "M_bit_result",
        "M_op_rdhwr"          => "M_rdhwr_data",
        "M_op_sc"             => "{31'b0,W_llbit}",
        "1'b1"                => "M_alu_result",
      ],
    });

    


    e_assign->adds(
        [["M_valid_st_writes_mem", 1, 0, $force_never_export], 
          "M_ctrl_st & M_valid"],
    );





    e_assign->adds(
      [["A_ic_op_start_nxt", 1],
        "A_ic_op_start ? ~(A_ctrl_ic_tag_rd & A_valid) : 
                          (M_ctrl_ic_tag_rd & M_valid & A_en)"],
      );

      e_register->adds(
        {out => ["A_ic_op_start",1],
         in =>   "A_ic_op_start_nxt ",
         enable => "1'b1"},
        {out => ["A_ic_op_start_d1",1],
         in =>   "A_ic_op_start ",
         enable => "1'b1"},
      );




    e_signal->adds({name => "A_lwlr_data_align", never_export => 1, 
      width => $datapath_sz});

    e_assign->adds(
      [["A_lwlr_data", $datapath_sz], "A_dc_hit  ?
                                        A_dc_rd_data : d_readdata_d1 "],
      [["A_lwlr_data_align", $datapath_sz], "{A_lwlr_data_byte3,A_lwlr_data_byte2,
                                              A_lwlr_data_byte1,A_lwlr_data_byte0}"],
      [["A_lwlr_stall_start_nxt", 1],
          "M_ctrl_lwlr & M_valid & A_en"],

      [["A_lwlr_stall_stop_nxt", 1],
        "~A_mem_stall  & ~A_lwlr_stall_start_nxt"],

      [["A_lwlr_stall_nxt", 1],
        "A_lwlr_stall ? ~A_lwlr_stall_stop_nxt : A_lwlr_stall_start_nxt"],
      );

      e_register->adds(
          {out => ["A_lwlr_stall",1],
         in =>   "A_lwlr_stall_nxt ", 
         enable => "1'b1"},

          {out => ["M_src2_reg",$datapath_sz],
         in =>   "E_src2_reg ", 
         enable => "M_en"},

          {out => ["A_src2_reg",$datapath_sz],
         in =>   "M_src2_reg ", 
         enable => "A_en"},
      );

    if ($big_endian) {
    e_assign->adds(
      [["A_lwlr_data_byte0", 8], 
        "A_mem_baddr[1:0] == 2'b00 ? (A_op_lwl ? A_lwlr_data[7:0] : A_lwlr_data[31:24]) : 
         A_mem_baddr[1:0] == 2'b01 ? (A_op_lwl ? A_src2_reg[7:0] : A_lwlr_data[23:16]) : 
         A_mem_baddr[1:0] == 2'b10 ? (A_op_lwl ? A_src2_reg[7:0] : A_lwlr_data[15:8]) : 
                                     (A_op_lwl ? A_src2_reg[7:0] : A_lwlr_data[7:0])  "],

      [["A_lwlr_data_byte1", 8],
        "A_mem_baddr[1:0] == 2'b00 ? (A_op_lwl ? A_lwlr_data[15:8] : A_src2_reg[15:8]) : 
         A_mem_baddr[1:0] == 2'b01 ? (A_op_lwl ? A_lwlr_data[7:0] : A_lwlr_data[31:24]) : 
         A_mem_baddr[1:0] == 2'b10 ? (A_op_lwl ? A_src2_reg[15:8] : A_lwlr_data[23:16]) : 
                                     (A_op_lwl ? A_src2_reg[15:8] : A_lwlr_data[15:8])  "],

      [["A_lwlr_data_byte2", 8],
        "A_mem_baddr[1:0] == 2'b00 ? (A_op_lwl ? A_lwlr_data[23:16] : A_src2_reg[23:16]) : 
         A_mem_baddr[1:0] == 2'b01 ? (A_op_lwl ? A_lwlr_data[15:8] : A_src2_reg[23:16]) : 
         A_mem_baddr[1:0] == 2'b10 ? (A_op_lwl ? A_lwlr_data[7:0] : A_lwlr_data[31:24]) : 
                                     (A_op_lwl ? A_src2_reg[23:16] : A_lwlr_data[23:16]) "], 

      [["A_lwlr_data_byte3", 8],
        "A_mem_baddr[1:0] == 2'b00 ? (A_op_lwl ? A_lwlr_data[31:24] : A_src2_reg[31:24]) : 
         A_mem_baddr[1:0] == 2'b01 ? (A_op_lwl ? A_lwlr_data[23:16] : A_src2_reg[31:24]) : 
         A_mem_baddr[1:0] == 2'b10 ? (A_op_lwl ? A_lwlr_data[15:8] : A_src2_reg[31:24]) : 
                                     (A_op_lwl ? A_lwlr_data[7:0] : A_lwlr_data[31:24]) "], 
      );

    } else {
    e_assign->adds(
      [["A_lwlr_data_byte0", 8],
        "A_mem_baddr[1:0] == 2'b00 ? (A_op_lwl ? A_src2_reg[7:0] : A_lwlr_data[7:0]) : 
         A_mem_baddr[1:0] == 2'b01 ? (A_op_lwl ? A_src2_reg[7:0] : A_lwlr_data[15:8]) : 
         A_mem_baddr[1:0] == 2'b10 ? (A_op_lwl ? A_src2_reg[7:0] : A_lwlr_data[23:16]) : 
                                     (A_op_lwl ? A_lwlr_data[7:0] : A_lwlr_data[31:24])  "],

      [["A_lwlr_data_byte1", 8],
        "A_mem_baddr[1:0] == 2'b00 ? (A_op_lwl ? A_src2_reg[15:8] : A_lwlr_data[15:8]) : 
         A_mem_baddr[1:0] == 2'b01 ? (A_op_lwl ? A_src2_reg[15:8] : A_lwlr_data[23:16]) : 
         A_mem_baddr[1:0] == 2'b10 ? (A_op_lwl ? A_lwlr_data[7:0] : A_lwlr_data[31:24]) : 
                                     (A_op_lwl ? A_lwlr_data[15:8] : A_src2_reg[15:8])  "],

      [["A_lwlr_data_byte2", 8],
        "A_mem_baddr[1:0] == 2'b00 ? (A_op_lwl ? A_src2_reg[23:16] : A_lwlr_data[23:16]) : 
         A_mem_baddr[1:0] == 2'b01 ? (A_op_lwl ? A_lwlr_data[7:0] : A_lwlr_data[31:24]) : 
         A_mem_baddr[1:0] == 2'b10 ? (A_op_lwl ? A_lwlr_data[15:8] : A_src2_reg[23:16]) : 
                                     (A_op_lwl ? A_lwlr_data[23:16] : A_src2_reg[23:16]) "],

      [["A_lwlr_data_byte3", 8],
        "A_mem_baddr[1:0] == 2'b00 ? (A_op_lwl ? A_lwlr_data[7:0] : A_lwlr_data[31:24]) : 
         A_mem_baddr[1:0] == 2'b01 ? (A_op_lwl ? A_lwlr_data[15:8] : A_src2_reg[31:24]) : 
         A_mem_baddr[1:0] == 2'b10 ? (A_op_lwl ? A_lwlr_data[23:16] : A_src2_reg[31:24]) : 
                                     (A_op_lwl ? A_lwlr_data[31:24] : A_src2_reg[31:24]) "],
      );

    }






    e_assign->adds(



      [["M_ld_align_sh16", 1], 
        "(M_ctrl_ld8 | M_ctrl_ld16) & ${big_endian_tilde}M_mem_baddr[1]"],





      [["M_ld_align_sh8", 1], 
        "M_ctrl_ld8 & ${big_endian_tilde}M_mem_baddr[0]"],



      [["M_ld_align_byte1_fill", 1], "M_ctrl_ld8"],
      


      [["M_ld_align_byte2_byte3_fill", 1], "M_ctrl_ld8_ld16"],
    );





    e_assign->adds(





      [["M_cancel", 1], "A_pipe_flush | M_refetch | M_exc_any"],






      [["M_ignore_exc", 1],
        "A_pipe_flush | (M_refetch & ~M_exc_exclude_tlb_data)"],





      [["M_exc_allowed", 1], "M_valid_from_E & ~M_ignore_exc"],
    );

    push(@exc_wave_signals,
      { radix => "x", signal => "M_refetch" },
      { radix => "x", signal => "M_cancel" },
      { radix => "x", signal => "M_ignore_exc" },
      { radix => "x", signal => "M_exc_any" },
      { radix => "x", signal => "M_exc_allowed" },
    );

    if ($tlb_present) {


        new_exc_combo_signal({
            name                => "M_exc_exclude_tlb_data",
            stage               => "M",
            higher_pri_than_excs => [
              $tlb_load_refill_exc, 
              $tlb_load_invalid_exc,
              $tlb_store_refill_exc, 
              $tlb_store_invalid_exc, 
              $tlb_store_mod_exc
            ],
        });
        
        e_assign->adds(






          [["M_refetch", 1], 
            "M_ctrl_mem_data_access & ~M_mem_baddr_phy_got_pfn"],

        );
    } else {

        e_assign->adds(
          [["M_refetch", 1], "0"],
          [["M_exc_exclude_tlb_data", 1], "0"],
        );
    }
    
    e_assign->adds(

      [["A_refetch_qualified_nxt", 1],
        "M_refetch & M_valid_from_E & ~M_exc_exclude_tlb_data & ~A_pipe_flush"],



      [["M_valid", 1], "M_valid_from_E & ~M_cancel"],



      [["M_wr_dst_reg", 1], "M_wr_dst_reg_from_E & ~M_cancel"],
    );





    e_assign->adds(








      [["A_pipe_flush_nxt", 1], 
        "(M_exc_any | M_refetch | M_ctrl_flush_pipe) & M_valid_from_E &
          ~A_pipe_flush"],



      [["M_br_mispredict_fetch_taken_target", 1], 
         "M_br_mispredict & ~M_ctrl_br_likely & M_br_actually_taken &
           ~A_pipe_flush"],


      [["M_annul_delay_slot", 1], "M_ctrl_br_likely & ~M_br_actually_taken"],



      [["A_delay_slot_refetch", 1], "A_is_delay_slot & A_refetch_qualified"],
    







      [["A_pipe_fetch_nxt", 1], 
         "A_pipe_flush_nxt | 
          M_br_mispredict_fetch_taken_target |
          A_delay_slot_refetch"],
    );

    push(@pipe_flush_wave_signals,
      { radix => "x", signal => "M_exc_vector_pcb" },
      { radix => "x", signal => "M_exc_any" },
      { radix => "x", signal => "M_refetch" },
      { radix => "x", signal => "M_ctrl_flush_pipe" },
      { radix => "x", signal => "M_valid_from_E" },
      { radix => "x", signal => "A_pipe_flush_nxt" },
      { radix => "x", signal => "M_br_mispredict_fetch_taken_target" },
      { radix => "x", signal => "A_refetch_qualified" },
      { radix => "x", signal => "A_delay_slot_refetch" },
      { radix => "x", signal => "A_is_delay_slot" },
      { radix => "x", signal => "M_br_mispredict_fetch_taken_target" },
      { radix => "x", signal => "A_pipe_fetch_nxt" },
    );

    my $vector_offset_sz = 12;
    my $vector_offset_lsb = 0;
    my $vector_offset_msb = $vector_offset_lsb + $vector_offset_sz - 1;

    my $vector_base_sz = $pcb_sz - $vector_offset_sz;
    my $vector_base_lsb = $vector_offset_msb + 1;
    my $vector_base_msb = $vector_base_lsb + $vector_base_sz - 1;


    my $exc_vector_base_mux_table = [];
    my $exc_vector_offset_mux_table = [];

    push(@$exc_vector_base_mux_table, 
      "W_cop0_status_reg_bev" => 
        (manditory_int($Opt, "exception_boot_addr") >> $vector_offset_sz),
      "1'b1" => "W_cop0_ebase_reg[$vector_base_msb:$vector_base_lsb]",
    );

    e_mux->adds({
      lhs => ["M_exc_vector_base", $vector_base_sz],
      type => "priority",
      table => $exc_vector_base_mux_table,
    });

    push(@$exc_vector_offset_mux_table, 
      "W_cop0_status_reg_exl" => "W_cop0_status_reg_bev ?
                                     ${vector_offset_sz}'h380 :
                                     ${vector_offset_sz}'h180",

      "M_intr_req & W_cop0_cause_reg_iv" => "W_cop0_status_reg_bev ?
                                     ${vector_offset_sz}'h400 :
                                     ${vector_offset_sz}'h200",
    );

    if ($tlb_present) {
        push(@$exc_vector_offset_mux_table, 
          "M_exc_fast_tlb_miss" => "W_cop0_status_reg_bev ?
                                     ${vector_offset_sz}'h200 :
                                     ${vector_offset_sz}'h000",
        );
    }

    push(@$exc_vector_offset_mux_table, 
      "1'b1"                    => "W_cop0_status_reg_bev ?
                                     ${vector_offset_sz}'h380 :
                                     ${vector_offset_sz}'h180",
    );

    e_mux->adds({
      lhs => ["M_exc_vector_offset", $vector_offset_sz],
      type => "priority",
      table => $exc_vector_offset_mux_table,
    });

    e_assign->adds(

      [["M_exc_vector_pcb", $pcb_sz], 
        "{M_exc_vector_base, M_exc_vector_offset}"],
    );

    push(@exc_wave_signals,
      { radix => "x", signal => "M_exc_vector_pcb" },
      { radix => "x", signal => "M_exc_vector_base" },
      { radix => "x", signal => "M_exc_vector_offset" },
      { radix => "x", signal => "W_cop0_status_reg_bev" },
    );



    my $pipe_fetch_pcb_mux_table = [];

    push(@$pipe_fetch_pcb_mux_table, 



      "A_delay_slot_refetch" => "M_pcb",
    );

    if ($soft_reset_present) {
        push(@$pipe_fetch_pcb_mux_table, 
          "M_exc_soft_reset" => manditory_int($Opt, "reset_addr"),
        );
    }

    if ($debug_port_present) {
        push(@$pipe_fetch_pcb_mux_table, 
          "M_exc_debug | (M_exc_any & W_debug_mode)" => 
            ("debug_probe_trap_d1 ? $debug_probe_trap_enabled_addr : " .
             manditory_int($Opt, "debug_probe_trap_disabled_addr")),
        );
    }

    if ($nmi_present) {
        push(@$pipe_fetch_pcb_mux_table, 
          "M_exc_nmi" => manditory_int($Opt, "reset_addr"),
        );
    }

    push(@$pipe_fetch_pcb_mux_table, 

      "M_exc_any" => "M_exc_vector_pcb",


      "M_refetch" => "M_pcb",
    );

    if ($debug_port_present) {
        push(@$pipe_fetch_pcb_mux_table, 

          "M_op_deret" => "W_cop0_depc_reg",
        );
    }

    push(@$pipe_fetch_pcb_mux_table, 

      "M_op_eret" => 
        "W_cop0_status_reg_erl ?  W_cop0_error_epc_reg : W_cop0_epc_reg",



      "1'b1"                                => "{ M_br_taken_waddr, 2'b00 }",
    );

    e_mux->add ({
      lhs => ["A_pipe_fetch_pcb_nxt", $pcb_sz],
      type => "priority",
      table => $pipe_fetch_pcb_mux_table,
    });





    my @A_stall_inputs = (
        "A_mem_stall",
        "A_hilo_stall",
        "A_extins_stall",
        "A_lwlr_stall",
    );

    if ($tlb_present) {

        push(@A_stall_inputs, "A_tlb_inst_stall");
    }

    if ($hw_mul_has_stall) {

        push(@A_stall_inputs, "A_mul_stall",);
    }

    if ($fast_shifter_uses_dsp_block) {

    } elsif ($fast_shifter_uses_designware) {

    } elsif ($fast_shifter_uses_les || $small_shifter_uses_les) {
        push(@A_stall_inputs, "A_shift_rot_stall");
    } else {
        &$error("unsupported shifter implementation");
    }

    e_assign->adds(
      [["A_stall", 1], 
        scalar(@A_stall_inputs) ? join('|', @A_stall_inputs) : "0"],


      [["A_en", 1], "~A_stall"],        
    );

    e_signal->adds(



      {name => "A_cmp_result", never_export => 1, width => 1},
      {name => "A_br_result", never_export => 1, width => 1},
      {name => "A_mem_baddr", never_export => 1, width => $mem_baddr_sz},
      {name => "A_exc_fast_tlb_miss", never_export => 1, width => 1 },
    );

    e_register->adds(
      {out => ["A_pcb", $pcb_sz],                   in => "M_pcb", 
       enable => "A_en"},
      {out => ["A_previous_pcb", $pcb_sz],          in => "A_pcb", 
       enable => "A_valid & A_en"},
      {out => ["A_valid", 1],                       in => "M_valid",
       enable => "A_en", ip_debug_visible => 1},
      {out => ["A_iw",  $iw_sz],                    in => "M_iw",
       enable => "A_en", ip_debug_visible => 1},
      {out => ["A_inst_result", $datapath_sz],      in => "M_inst_result",
       enable => "A_en"},
      {out => ["A_src2", $datapath_sz],             in => "M_src2",
       enable => "A_en"},
      {out => ["A_mem_byte_en", $byte_en_sz],       in => "M_mem_byte_en",
       enable => "A_en", },
      {out => ["A_st_data", $datapath_sz],          in => "M_st_data",
       enable => "A_en"},
      {out => ["A_dst_regnum", $regnum_sz],         in => "M_dst_regnum",
       enable => "A_en"},
      {out => ["A_ld_align_sh16", 1],               in => "M_ld_align_sh16",
       enable => "A_en"},
      {out => ["A_ld_align_sh8", 1],                in => "M_ld_align_sh8",
       enable => "A_en"},
      {out => ["A_ld_align_byte1_fill", 1],         
       in => "M_ld_align_byte1_fill",
       enable => "A_en"},
      {out => ["A_ld_align_byte2_byte3_fill", 1],   
       in => "M_ld_align_byte2_byte3_fill",
       enable => "A_en"},
      {out => "A_cmp_result",                       in => "M_cmp_result",  
       enable => "A_en"},
      {out => "A_br_result",                        in => "M_br_result",  
       enable => "A_en"},
      {out => "A_mem_baddr",                        in => "M_mem_baddr",
       enable => "A_en"},




      {out => ["A_wr_dst_reg", 1],                  in => "M_wr_dst_reg",
       enable => "A_en", async_value => "1'b1" },

      {out => ["A_annul_delay_slot", 1],    in => "M_annul_delay_slot",
       enable => "A_en" },
      {out => ["A_refetch_qualified", 1],   in => "A_refetch_qualified_nxt",
       enable => "A_en" },
      {out => ["A_pipe_flush", 1],          in => "A_pipe_flush_nxt",
       enable => "A_en" },
      {out => ["A_pipe_fetch", 1],          in => "A_pipe_fetch_nxt",
       enable => "A_en" },
      {out => ["A_pipe_fetch_pcb", $pcb_sz],in => "A_pipe_fetch_pcb_nxt",
       enable => "A_en" },
      {out => ["A_exc_allowed", 1],         in => "M_exc_allowed", 
       enable => "A_en"},
      {out => ["A_exc_debug", 1],           in => "M_exc_debug",
       enable => "A_en"},
      {out => ["A_exc_soft_reset", 1],      in => "M_exc_soft_reset",
       enable => "A_en"},
      {out => ["A_exc_nmi", 1],             in => "M_exc_nmi",
       enable => "A_en"},
      {out => ["A_exc_any", 1],             in => "M_exc_any",
       enable => "A_en"},
    );

    if ($tlb_present) {
        e_register->adds(
          {out => ["A_exc_vpn2", $mmu_addr_vpn2_sz], in => "M_exc_vpn2",
           enable => "A_en"},
          {out => ["A_udtlb_access", 1],            in => "M_udtlb_access",
           enable => "A_en"},
          {out => ["A_udtlb_index", $udtlb_index_sz],
           in => "M_udtlb_index",        enable => "A_en"},
          {out => ["A_exc_fast_tlb_miss", 1],
           in  => "M_exc_fast_tlb_miss", enable  => "A_en"},
        );

        e_assign->adds(






          [["A_valid_udtlb_lru_access", 1], "A_valid & A_udtlb_access"],
        );
    }





    e_assign->adds(


      [["A_has_non_annulled_delay_slot", 1], 
        "A_ctrl_has_delay_slot & ~A_annul_delay_slot"],








      [["A_is_delay_slot_nxt", 1], 
         "A_is_delay_slot ?
            ~(A_valid | A_exc_any_active) :
            (A_valid & A_has_non_annulled_delay_slot)"],
    );

    e_register->adds(
      {out    => ["A_is_delay_slot", 1],  
       in     => "A_is_delay_slot_nxt",
       enable => "A_en" },
    );

    if ($debug_port_present) {
        e_assign->adds(






          [["A_single_step_execution_step_start", 1], 
            "A_op_deret & A_valid & A_en & W_cop0_debug_reg_sst"],







          [["A_single_step_execution_step_done", 1], 
            "W_single_step_execution_step_pending &
              ((A_valid & ~A_has_non_annulled_delay_slot) | 
               A_exc_active_no_debug)"],



          [["W_single_step_execution_step_pending_nxt", 1], 
            "W_single_step_execution_step_pending ? 
               ~(A_single_step_execution_step_done | A_exc_debug_active) :
               A_single_step_execution_step_start"],





          [["A_single_step_exception_pending_done", 1], 
            "W_single_step_exception_pending & A_exc_any_active"],



          [["W_single_step_exception_pending_nxt", 1], 
            "W_single_step_exception_pending ? 
               ~A_single_step_exception_pending_done :
               A_single_step_execution_step_done"],








          [["W_ejtagboot_active_nxt", 1], 
            "W_ejtagboot_active ? 
               ~A_exc_any_active :
               (ejtagboot_reset_d1 & debug_boot)"],
        );

        e_register->adds(
          {out    => ["W_single_step_execution_step_pending", 1],  
           in     => "W_single_step_execution_step_pending_nxt",
           enable => "W_en" },

          {out    => ["W_single_step_exception_pending", 1],  
           in     => "W_single_step_exception_pending_nxt",
           enable => "W_en" },



          {out => ["ejtagboot_reset_d1", 1],
           in => "0", 
           enable => "1",
           async_value => "1" },

          {out    => ["W_ejtagboot_active", 1],  
           in     => "W_ejtagboot_active_nxt",
           enable => "W_en" },
        );
    } else {
        e_assign->adds(
          [["W_ejtagboot_active", 1], "0"],
        );
    }






    e_register->adds(
      {out => ["W_llbit",1],
       in => "(A_op_ll & A_valid)   ? 1'b1 :
              (A_op_eret & A_valid) ? 1'b0 : 
              W_llbit",
       enable => "1"},
    );











    e_assign->adds(
      [["${hi_s}_hi_nxt",$datapath_sz], 
        "(${hi_accum_s}_ctrl_mult_accum & ${hi_accum_s}_valid) ? ${hi_accum_s}_accum_msw : 
         ${hi_accum_s}_mul_cell_result_msw"],
    );
    e_assign->adds(
      [["W_hi_en",1],
      "W_div_quot_ready | 
       (W_ctrl_wrt_hi & W_valid)"],
    );

    e_register->adds(
      {out => ["${hi_s}_hi",$datapath_sz],
       in => " ${hi_s}_hi_nxt",
       enable => "${hi_accum_s}_hi_en"}, 
    );


    e_assign->adds(
      [["${lo_s}_lo_nxt",$datapath_sz], 
        "(${lo_accum_s}_op_mtlo & ${lo_accum_s}_valid & ${lo_accum_s}_en) ? 
        ${lo_accum_s}_div_src1 :
        ${lo_accum_s}_div_quot_ready  ? ${lo_accum_s}_div_quot :
          (${lo_accum_s}_ctrl_mult_inst & ${lo_accum_s}_valid) ?  
            ${lo_accum_s}_mul_cell_result_lsw : 
          ${lo_accum_s}_accum_lsw[31:0]"],
    );
    e_assign->adds(
      [["${lo_accum_s}_lo_en",1], 
        "((${lo_accum_s}_ctrl_mult_inst | ${lo_accum_s}_ctrl_mult_accum | 
            ${lo_accum_s}_op_mtlo) & ${lo_accum_s}_valid & ${lo_accum_s}_en) |
            ${lo_accum_s}_div_quot_ready"],
    );
    e_register->adds(
      {out => ["${lo_s}_lo",$datapath_sz],
       in => "${lo_s}_lo_nxt",
       enable => " ${lo_accum_s}_lo_en"},
    );









    e_assign->adds(
      [["div_active_or_start",1],
        "div_active | div_active_nxt"],

      [["A_hilo_stall_start_nxt", 1],
        "(M_ctrl_wrt_lo & M_valid  & A_en & div_active_or_start) |
        (M_ctrl_wrt_hi & M_valid  & A_en & div_active_or_start) |
        (M_ctrl_rd_lo & M_valid  & A_en & div_active_or_start) |
        (M_ctrl_rd_hi & M_valid  & A_en & div_active_or_start) |
        (M_ctrl_hilo_inst & M_valid & A_en  & div_active_or_start) |
        (M_ctrl_div & M_valid & A_en  & A_ctrl_wrt_hilo & A_valid) |
         (M_ctrl_mfhilo_inst & M_valid & A_en)"],

      [["A_hilo_stall_stop_nxt", 1],
        "(${hi_accum_s}_hi_en_d1 & ~${hi_accum_s}_hi_en & ~W_hi_en & A_ctrl_rd_hi) | 
         (${lo_accum_s}_lo_en_d1 & A_ctrl_rd_lo & ~${lo_accum_s}_lo_en ) |
          (A_ctrl_mfhilo_inst & ~div_active & ~(W_hi_en | W1_hi_en | W_lo_en)) |
        (A_ctrl_wrt_hilo & ~div_active & (${hi_accum_s}_hi_en_d1 | ${lo_accum_s}_lo_en_d1))"],

      [["A_hilo_stall_nxt", 1],
        "A_hilo_stall ? ~A_hilo_stall_stop_nxt : A_hilo_stall_start_nxt"],
      );

    e_register->adds(
      {out => ["A_hilo_stall_unfiltered",1],
       in => "A_hilo_stall_nxt",
       enable => "1'b1"},

      {out => ["${hi_accum_s}_hi_en_d1",1],
       in => "${hi_accum_s}_hi_en",
       enable => "1'b1"},

      {out => ["${lo_accum_s}_lo_en_d1",1],
       in => "${lo_accum_s}_lo_en",
       enable => "1'b1"},
    );


    create_x_filter({
      lhs       => "A_hilo_stall",
      rhs       => "A_hilo_stall_unfiltered",
      sz        => 1,
      qual_expr => "div_active",
    });






    if ($hw_mul_uses_embedded_mults) {
      e_assign->adds(
        [["${lo_accum_s}_accum_lsw", $datapath_sz+1],
          " (${lo_accum_s}_op_msub | ${lo_accum_s}_op_msubu) ? 
                ${lo_s}_lo - ${lo_accum_s}_mul_cell_result_lsw :
                ${lo_s}_lo + ${lo_accum_s}_mul_cell_result_lsw"],

        [["${hi_accum_s}_accum_msw", $datapath_sz],
          "(${hi_accum_s}_op_msub | ${hi_accum_s}_op_msubu) ?
                ${hi_s}_hi - ${hi_accum_s}_mul_cell_result_msw - ${hi_accum_s}_accum_cin :
                ${hi_s}_hi + ${hi_accum_s}_mul_cell_result_msw + ${hi_accum_s}_accum_cin"],
      );
    } else {
      e_assign->adds(
        [["${lo_accum_s}_accum_lsw", $datapath_sz+1], 
          " (${lo_accum_s}_op_msub | ${lo_accum_s}_op_msubu) ? 
                ${lo_s}_lo - ${lo_accum_s}_mul_cell_result_lsw :
                ${lo_s}_lo + ${lo_accum_s}_mul_cell_result_lsw"],

        [["${hi_accum_s}_accum_msw", $datapath_sz], 
          "(${hi_accum_s}_op_msub | ${hi_accum_s}_op_msubu) ?
                ${hi_s}_hi - ${hi_accum_s}_mul_cell_result_msw - ${hi_accum_s}_accum_cin :
                ${hi_s}_hi + ${hi_accum_s}_mul_cell_result_msw + ${hi_accum_s}_accum_cin"],
      );
    }

      e_register->adds(
        {out => ["${hi_accum_s}_mul_cell_result_msw",$datapath_sz],
         in  => "${lo_accum_s}_div_quot_ready ? ${lo_accum_s}_div_rem : 
                 (${lo_accum_s}_op_mthi & ${lo_accum_s}_valid) ? ${lo_accum_s}_div_src1: 
                 ${lo_accum_s}_mul_cell_result_msw_adj",
         enable => "1'b1"},


        {out => ["${hi_accum_s}_accum_cin",1],
         in  => "${lo_accum_s}_accum_lsw[$datapath_msb+1]", enable => "1'b1"},

      );
      if ($dsp_block_has_pipeline_reg or $hw_mul_uses_embedded_mults){
        e_register->adds(
          {out => ["W1_hi_en",1],
          in  => "W_hi_en", enable => "1'b1"},

          {out => ["W1_ctrl_mult_accum",1],
          in  => "W_ctrl_mult_accum", enable => "1'b1"},

          {out => ["W1_valid",1],
          in  => "W_valid", enable => "1'b1"},

          {out => ["W1_op_msub",1],
          in  => "W_op_msub", enable => "1'b1"},

          {out => ["W1_op_msubu",1],
          in  => "W_op_msubu", enable => "1'b1"},

          {out => ["W_div_quot",32],
          in  => "A_div_quot", enable => "W_en"},

          {out => ["W_div_rem",32],
          in  => "A_div_rem", enable => "W_en"},

          {out => ["W_div_src1",32],
          in  => "A_div_src1", enable => "W_en"},

        );
      } else {
        e_assign->adds( [["W1_hi_en",1], "1'b0"],
                        [["W_lo_en",1], "1'b0"],
        );
      }





      if ($dsp_block_has_pipeline_reg){
          e_assign->adds(
            [["W_mul_cell_result_lsw", $datapath_sz], "A_mul_cell_result_lsw"],
             [["${lo_accum_s}_mul_cell_result_msw_adj",$datapath_sz], "${lo_accum_s}_mul_cell_result_msw"],
        );
      } elsif ($hw_mul_uses_embedded_mults) {
        e_register->adds(
          {out => ["W_mul_cell_result_lsw",$datapath_sz],
          in  => "A_mul_cell_result_lsw", enable => "W_en"},
          {out => ["W_mul_cell_result_msw",$datapath_sz],
          in  => "A_mul_cell_result_msw", enable => "W_en"},
          {out => ["W_mul_cell_result_b_co",2],
          in  => "A_mul_cell_result_b_co", enable => "W_en"},
          {out => ["W_mul_negate_result",1],
          in  => "A_mul_negate_result", enable => "W_en"},
          {out => ["W_mul_cell_result_neg_co",1],
          in  => "A_mul_cell_result_neg_co", enable => "W_en"},
        );
        e_assign->adds( [["${lo_accum_s}_mul_cell_result_msw_adj",$datapath_sz], 
          "W_mul_negate_result ?  (~(${lo_accum_s}_mul_cell_result_msw +  ${lo_accum_s}_mul_cell_result_b_co) + ${lo_accum_s}_mul_cell_result_neg_co) :
              (${lo_accum_s}_mul_cell_result_msw + ${lo_accum_s}_mul_cell_result_b_co)"],
        );
      } else {
        e_assign->adds( [["${lo_accum_s}_mul_cell_result_msw_adj",$datapath_sz], "${lo_accum_s}_mul_cell_result_msw"],
        );
      }





    e_signal->adds(
      {name => "A_extins_result", never_export => 1, width => $datapath_sz},
      {name => "M_ext_mask", never_export => 1, width => $datapath_sz},
      {name => "M_ins_mask", never_export => 1, width => $datapath_sz},
      {name => "M_extins_mask", never_export => 1, width => $datapath_sz},
    );

    e_assign->adds(
      ["M_extins_mask", "M_op_ext ? M_ext_mask : M_ins_mask"],
      ["M_extins_src", "M_op_ext ? 32'b0 : M_src2"],
    );

    for ($bit = 0; $bit < 32; $bit++) {
        e_assign->adds(
          ["M_ext_mask[$bit]",
             "($bit <= M_iw_rd) ? 1'b1 : 1'b0"],

          ["M_ins_mask[$bit]",
             "($bit >= M_iw_sa && ($bit <= M_iw_rd)) ? 1'b1 : 1'b0"],

      );
    }

  if ($hw_mul_uses_dsp_block) {
    for ($bit = 0; $bit < 32; $bit++) {
      e_assign->adds(
        ["A_extins_result[$bit]",
             "A_extins_mask[$bit] ? A_mul_shift_rot_result[$bit] : 
                                    A_extins_src[$bit]"],
        );
    }
  } elsif($hw_mul_uses_embedded_mults) {
    for ($bit = 0; $bit < 32; $bit++) {
      e_assign->adds(
        ["A_extins_result[$bit]",
             "A_extins_mask[$bit] ? A_shift_rot_result[$bit] : 
                                    A_extins_src[$bit]"],
        );
    }
  } else {
      &$error("unsupported hardware multiplier implementation");
  }



    my @A_extins_stall_inputs = ( "${extins_s}_ctrl_extins & ${extins_s}_valid & !A_extins_stall",);
    if ($dsp_block_has_pipeline_reg ) {
      push(@A_extins_stall_inputs, "A_mul_stall",);
    }



    e_register->adds(
        {out => ["A_extins_stall",1],
         in => join('&', @A_extins_stall_inputs),
         enable => "1'b1"},

        {out => ["A_extins_src",32],
         in =>   "M_extins_src", enable => "A_en"},

        {out => ["A_extins_mask",32],
         in =>   "M_extins_mask", enable => "A_en"},
    );












    my $slow_inst_result_table = [];
    my @slow_inst_sel_list = ();
    my @slow_inst_en_list = ();

    push(@$slow_inst_result_table,
      "A_op_mfhi"                  => "${hi_s}_hi",
      "A_op_mflo"                  => "${lo_s}_lo",
      "A_ctrl_extins"              => "A_extins_result",
      "A_ctrl_lwlr"                => "A_lwlr_data_align",
    );

    push(@slow_inst_en_list,  
        "A_ctrl_mfhilo_inst",
        "A_ctrl_extins",
        "A_ctrl_lwlr & ((A_dc_fill_miss_offset_is_next & d_readdatavalid_d1) | A_dc_hit)");







    push(@slow_inst_sel_list, "A_ctrl_ld_bypass", "(A_dc_want_fill & ~A_op_sc)", 
                              "A_ctrl_mfhilo_inst","A_ctrl_extins",
                              "A_ctrl_lwlr");








    push(@slow_inst_en_list,
      "((A_dc_fill_miss_offset_is_next | A_ctrl_ld_bypass) &
        d_readdatavalid_d1)");

    push(@$slow_inst_result_table,
      "1'b1"                        => "A_slow_ld_data_aligned_nxt",
    );


    e_assign->adds(
      [["A_slow_inst_result_en", 1], join('|', @slow_inst_en_list)],
    );






    e_assign->adds(
      [["A_slow_inst_sel_nxt", 1], 
         "A_en ? 0 : " . join('|', @slow_inst_sel_list)],
    );
 
    e_mux->add({
      lhs => ["A_slow_inst_result_nxt", $datapath_sz],
      type => "priority",
      table => $slow_inst_result_table,
    });

    e_register->adds(
      {out => ["A_slow_inst_sel", 1],
       in => "A_slow_inst_sel_nxt",        
       enable => "1'b1"},

      {out => ["A_slow_inst_result", $datapath_sz], 
       in => "A_slow_inst_result_nxt",     
       enable => "A_slow_inst_result_en"},
    );
  












    my $rf_wr_mux_table = [];

    push(@$rf_wr_mux_table, 
      "A_slow_inst_sel"                => "A_slow_inst_result",
    );

    if ($hw_mul_uses_dsp_block) {
        push(@$rf_wr_mux_table,
          "A_ctrl_mul_shift_rot"             => "A_mul_shift_rot_result",
          "1'b1"                            => "A_inst_result_aligned",
        );
    } elsif($hw_mul_uses_embedded_mults) {
        push(@$rf_wr_mux_table,
          "A_op_mul & A_valid"              => "A_mul_cell_result",
          "A_ctrl_shift_rot"                => "A_shift_rot_result",
          "1'b1"                            => "A_inst_result_aligned",
        );
    } else {
        &$error("unsupported hardware multiplier implementation");
    }


    e_mux->add ({
      lhs => ["A_wr_data_unfiltered", $datapath_sz],
      type => "priority",
      table => $rf_wr_mux_table,
    });


    e_assign->adds(
      [["A_fwd_reg_data", $datapath_sz], "A_wr_data_filtered"],
    );







    e_assign->adds(
      [["A_exc_any_active", 1], "A_exc_any & A_exc_allowed"],
      [["A_exc_debug_active", 1, 0, $force_never_export],
        "A_exc_debug & A_exc_allowed"],
      [["A_exc_soft_reset_active", 1], "A_exc_soft_reset & A_exc_allowed"],
      [["A_exc_nmi_active", 1], "A_exc_nmi & A_exc_allowed"],


      [["A_exc_err_active", 1], "(A_exc_soft_reset_active | A_exc_nmi_active)"],

      [["A_exc_active_no_debug", 1, 0, $force_never_export], 
         "A_exc_any_active & ~A_exc_debug"],
      [["A_exc_active_no_soft_reset", 1, 0, $force_never_export], 
         "A_exc_any_active & ~A_exc_soft_reset"],
      [["A_exc_active_no_debug_no_err", 1], 
         "A_exc_any_active & ~(A_exc_debug | A_exc_err_active)"],
    );

    if ($debug_port_present) {


        e_assign->adds(
          [["A_exc_debug_single_step_active", 1], "A_exc_allowed & " .
            get_exc_signal_name($debug_single_step_exc, "A")],
          [["A_exc_debug_interrupt_active", 1], "A_exc_allowed & " .
            get_exc_signal_name($debug_interrupt_exc, "A")],
          [["A_exc_debug_hwbp_active", 1], "A_exc_allowed & " .
            get_exc_signal_name($debug_hwbp_exc, "A")],
          [["A_exc_sdbpp_inst_active", 1], "A_exc_allowed & " .
            get_exc_signal_name($sdbpp_inst_exc, "A")],
        );
    }

    push(@exc_wave_signals,
      { radix => "x", signal => "A_exc_allowed" },
      { radix => "x", signal => "A_exc_any " },
      { radix => "x", signal => "A_exc_debug" },
      { radix => "x", signal => "A_exc_soft_reset" },
      { radix => "x", signal => "A_exc_nmi" },
      { radix => "x", signal => "A_exc_any_active" },
      { radix => "x", signal => "A_exc_debug_active" },
      { radix => "x", signal => "A_exc_soft_reset_active" },
      { radix => "x", signal => "A_exc_nmi_active" },
      { radix => "x", signal => "A_exc_err_active" },
      { radix => "x", signal => "A_exc_active_no_debug" },
      { radix => "x", signal => "A_exc_active_no_soft_reset" },
      { radix => "x", signal => "A_exc_active_no_debug_no_err" },
    );

    if ($tlb_present) {
        my $A_tlb_inst_refill_exc = 
          get_exc_signal_name($tlb_inst_refill_exc, "A");
        my $A_tlb_inst_invalid_exc =
          get_exc_signal_name($tlb_inst_invalid_exc, "A");
        my $A_tlb_load_refill_exc =
          get_exc_signal_name($tlb_load_refill_exc, "A");
        my $A_tlb_store_refill_exc =
          get_exc_signal_name($tlb_store_refill_exc, "A");
        my $A_tlb_load_invalid_exc =
          get_exc_signal_name($tlb_load_invalid_exc, "A");
        my $A_tlb_store_invalid_exc =
          get_exc_signal_name($tlb_store_invalid_exc, "A");
        my $A_tlb_store_mod_exc =
          get_exc_signal_name($tlb_store_mod_exc, "A");

        e_assign->adds(


          [["A_exc_tlb_inst_refill_active", 1], 
            "A_exc_allowed & $A_tlb_inst_refill_exc"],
          [["A_exc_tlb_inst_invalid_active", 1], 
            "A_exc_allowed & $A_tlb_inst_invalid_exc"],
          [["A_exc_tlb_data_refill_active", 1], 
            "A_exc_allowed & 
               ($A_tlb_load_refill_exc | $A_tlb_store_refill_exc)"],
          [["A_exc_tlb_data_invalid_active", 1], 
            "A_exc_allowed & 
              ($A_tlb_load_invalid_exc | $A_tlb_store_invalid_exc)"],
          [["A_exc_tlb_store_mod_active", 1], 
            "A_exc_allowed & $A_tlb_store_mod_exc"],



          [["A_exc_tlb_active", 1], 
            "(A_exc_tlb_inst_refill_active | 
              A_exc_tlb_data_refill_active |
              A_exc_tlb_inst_invalid_active | 
              A_exc_tlb_data_invalid_active |
              A_exc_tlb_store_mod_active)"],
        );

        if ($soft_reset_present) {
            push(@exc_wave_signals,
              get_exc_signal_wave($soft_reset_exc, "A"));
        }

        push(@exc_wave_signals,
          get_exc_signal_wave($interrupt_exc, "A"),
          get_exc_signal_wave($tlb_inst_refill_exc, "A"),
          get_exc_signal_wave($tlb_inst_invalid_exc, "A"),
          get_exc_signal_wave($tlb_load_refill_exc, "A"),
          get_exc_signal_wave($tlb_store_refill_exc, "A"),
          get_exc_signal_wave($tlb_load_invalid_exc, "A"),
          get_exc_signal_wave($tlb_store_invalid_exc, "A"),
          get_exc_signal_wave($tlb_store_mod_exc, "A"),
          { radix => "x", signal => "A_exc_tlb_inst_refill_active" },
          { radix => "x", signal => "A_exc_tlb_inst_invalid_active" },
          { radix => "x", signal => "A_exc_tlb_data_refill_active" },
          { radix => "x", signal => "A_exc_tlb_data_invalid_active" },
          { radix => "x", signal => "A_exc_tlb_store_mod_active" },
          { radix => "x", signal => "A_exc_tlb_active" },
        );
    }





    e_assign->adds(

      [["W_en", 1, 0, $force_never_export], "1'b1"],




      [["W_debug_mode", 1], $debug_port_present ? "W_cop0_debug_reg_dm" : "0"],

      [["W_kernel_mode", 1], 
        "~W_debug_mode & (~W_cop0_status_reg_um | W_cop0_status_reg_exl" .
        " | W_cop0_status_reg_erl)"],

      [["W_user_mode", 1], "~W_debug_mode & ~W_kernel_mode"],


      [["W_normal_mode", 1], 
        "~W_cop0_status_reg_exl & ~W_cop0_status_reg_erl & ~W_debug_mode"],
    );

    e_signal->adds(

      {name => "W_iw",          never_export => 1, width => $iw_sz},
      {name => "W_valid",       never_export => 1, width => 1},
      {name => "W_wr_dst_reg",  never_export => 1, width => 1},
      {name => "W_dst_regnum",  never_export => 1, width => $regnum_sz},
    );



    e_register->adds(
      {out => ["W_pcb", $pcb_sz, 0, $force_never_export], 
       in => "A_pcb",         
       enable => "1'b1", 
       ip_debug_visible => 1},

      {out => ["W_wr_data", $datapath_sz], in => "A_wr_data_filtered",
       enable => "1'b1"},
      {out => ["W_exc_soft_reset_active", 1, 0, $force_never_export],
       in => "A_exc_soft_reset_active",               enable => "1'b1" },
      




      {out => "W_iw",         in => "A_iw",           enable => "1'b1",
       ip_debug_visible => $mmu_present},
      {out => "W_valid",      in => "A_valid & A_en", enable => "1'b1"},
      {out => "W_wr_dst_reg", in => "A_wr_dst_reg & A_en", enable => "1'b1"},
      {out => "W_dst_regnum", in => "A_dst_regnum",   enable => "1'b1"},
    );

    if (manditory_bool($Opt, "export_pcb")) {

        e_signal->adds(
          {name => "pc", width => $pcb_sz, export => $force_export },
          {name => "pc_valid", width => 1, export => $force_export },
        );

        push(@{$Opt->{port_list}},
          ["pc"         => $pcb_sz, "out" ],
          ["pc_valid"   => 1,      "out" ],
        );


        e_assign->adds(
          ["pc", "W_pcb"],
          ["pc_valid", "W_valid"],
        );
    }





    if (manditory_bool($Opt, "full_waveform_signals")) {
        push(@plaintext_wave_signals, @pipe_flush_wave_signals);
        push(@plaintext_wave_signals, @exc_wave_signals);
        if (scalar(@sel_signals) > 1) {
            push(@plaintext_wave_signals, 
                { divider => "data_master_sel" },
            );

            foreach my $sel_signal (@sel_signals) {
                push(@plaintext_wave_signals, 
                  { radix => "x", signal => $sel_signal },
                );
            }
        }
    }

    my @mem_load_store_wave_signals = (
        { divider => "mem" },
        { radix => "x", signal => "E_mem_baddr" },
        { radix => "x", signal => "M_mem_baddr" },
        { divider => "load" },
        { radix => "x", signal => "M_ctrl_dcache_management" },
        { radix => "x", signal => "M_ctrl_ld8" },
        { radix => "x", signal => "M_ctrl_ld16" },
        { radix => "x", signal => "M_ctrl_ld_signed" },
        { radix => "x", signal => "M_ram_rd_data" },
        { radix => "x", signal => "M_inst_result" },
        { radix => "x", signal => "A_inst_result" },
        { radix => "x", signal => "A_inst_result_aligned" },
        { radix => "x", signal => "A_wr_data_unfiltered" },
        { radix => "x", signal => "A_wr_data_filtered" },
        { radix => "x", signal => "A_ld_align_sh16" },
        { radix => "x", signal => "A_ld_align_sh8" },
        { radix => "x", signal => "A_ld_align_byte1_fill" },
        { radix => "x", signal => "A_ld_align_byte2_byte3_fill" },
        { divider => "store" },
        { radix => "x", signal => "E_ctrl_st" },
        { radix => "x", signal => "E_ctrl_st8" },
        { radix => "x", signal => "E_ctrl_st16" },
        { radix => "x", signal => "E_valid" },
        { radix => "x", signal => "E_st_data" },
        { radix => "x", signal => "E_mem_byte_en" },
        { radix => "x", signal => "M_st_data" },
        { radix => "x", signal => "M_mem_byte_en" },
        { radix => "x", signal => "A_st_data" },
        { radix => "x", signal => "A_mem_byte_en" },

        { divider => "A_slow_inst_result_mux" },
        { radix => "x", signal => "A_ctrl_div" },
        { radix => "x", signal => "A_div_quot" },
        { radix => "x", signal => "A_div_quot_ready" },
        { radix => "x", signal => "A_slow_inst_result_en" },
        { radix => "x", signal => "A_dc_fill_miss_offset_is_next" },
        { radix => "x", signal => "A_ctrl_ld_bypass" },
        { radix => "x", signal => "d_readdatavalid_d1" },
        { radix => "x", signal => "A_ctrl_ld_bypass" },
        { radix => "x", signal => "A_dc_want_fill" },
        { radix => "x", signal => "A_slow_ld_data_aligned_nxt" },
        { radix => "x", signal => "A_slow_inst_sel_nxt" },
        { radix => "x", signal => "A_slow_inst_sel" },
        { radix => "x", signal => "A_slow_inst_result_en" },
        { radix => "x", signal => "A_slow_inst_result_nxt" },
        { radix => "x", signal => "A_slow_inst_result" },
    );

    if (manditory_bool($Opt, "full_waveform_signals")) {
        push(@plaintext_wave_signals, @mem_load_store_wave_signals);
    }
}






sub 
make_fetch_npcb
{
    my $Opt = shift;

    my $whoami = "fetch next PCB";

    my $fetch_npcb = not_empty_scalar($Opt, "fetch_npcb");
    my $ds = not_empty_scalar($Opt, "dispatch_stage");



















    e_mux->add ({
      lhs => [$fetch_npcb, $pcb_sz],
      type => "priority",
      table => [
        "A_pipe_fetch"                      => "A_pipe_fetch_pcb",
        "M_br_mispredict"                   => "M_br_mispredict_pcb",
        "D_refetch | D_inst_after_refetch"  => "D_pcb",
        "D_br_pred_taken & D_issue"         => "D_br_taken_baddr",
        "D_ctrl_jmp & D_issue"              => "D_jmp_target_baddr",
        "1'b1"                              => "{ ${ds}_pc_plus_one, 2'b00 }",
        ],
      });


    my $fetch_npc = not_empty_scalar($Opt, "fetch_npc");
    e_assign->adds(
      [[$fetch_npc, $pc_sz], "$fetch_npcb\[$pcb_sz-1:2]"],
    );

    my @fetch_npcb_signals = (
        { divider => "fetch_npcb" },
        { radix => "x", signal => "A_pipe_fetch" },
        { radix => "x", signal => "A_pipe_fetch_pcb" },
        { radix => "x", signal => "M_br_mispredict" },
        { radix => "x", signal => "M_br_mispredict_pcb" },
        { radix => "x", signal => "D_refetch" },
        { radix => "x", signal => "D_inst_after_refetch" },
        { radix => "x", signal => "D_pcb" },
        { radix => "x", signal => "D_br_pred_taken" },
        { radix => "x", signal => "D_br_taken_baddr" },
        { radix => "x", signal => "D_ctrl_jmp" },
        { radix => "x", signal => "D_jmp_target_baddr" },
        { radix => "x", signal => "$fetch_npcb" },
      );

    if ($Opt->{full_waveform_signals}) {
        push(@plaintext_wave_signals, @fetch_npcb_signals);
    }
}





sub 
make_reg_cmp
{
    my $Opt = shift;

    my $whoami = "register compare";

    my $ds = not_empty_scalar($Opt, "dispatch_stage");
    my $di = not_empty_scalar($Opt, "dispatch_raw_iw");
    












    e_assign->adds(
      [["D_wr_${ds}_iw_rs", 1], "D_wr_dst_reg & (${di}_rs == D_dst_regnum)"],
      [["E_wr_${ds}_iw_rs", 1], "E_wr_dst_reg & (${di}_rs == E_dst_regnum)"],
      [["M_wr_${ds}_iw_rs", 1], "M_wr_dst_reg & (${di}_rs == M_dst_regnum)"],
      [["A_wr_${ds}_iw_rs", 1], "A_wr_dst_reg & (${di}_rs == A_dst_regnum)"],

      [["D_wr_${ds}_iw_rt", 1], "D_wr_dst_reg & (${di}_rt == D_dst_regnum)"],
      [["E_wr_${ds}_iw_rt", 1], "E_wr_dst_reg & (${di}_rt == E_dst_regnum)"],
      [["M_wr_${ds}_iw_rt", 1], "M_wr_dst_reg & (${di}_rt == M_dst_regnum)"],
      [["A_wr_${ds}_iw_rt", 1], "A_wr_dst_reg & (${di}_rt == A_dst_regnum)"],
      );






    e_register->adds(
      {out => ["E_wr_D_iw_rs", 1],          
       in => "D_en ? D_wr_${ds}_iw_rs : 1'b0",         enable => "E_en"},
      {out => ["M_wr_D_iw_rs", 1],          
       in => "(E_ctrl_movzn & E_valid & E_mov_cancel) ? 1'b0 : D_en ? 
              E_wr_${ds}_iw_rs : E_wr_D_iw_rs", enable => "M_en"},
      {out => ["A_wr_D_iw_rs", 1],          
       in => "D_en ? M_wr_${ds}_iw_rs : M_wr_D_iw_rs", enable => "A_en"},
      {out => ["W_wr_D_iw_rs", 1],          
       in => "D_en ? A_wr_${ds}_iw_rs : A_wr_D_iw_rs", enable => "1'b1"},
      {out => ["E_wr_D_iw_rt", 1],          
       in => "D_en ? D_wr_${ds}_iw_rt : 1'b0",         enable => "E_en"},
      {out => ["M_wr_D_iw_rt", 1],          
       in => "(E_ctrl_movzn & E_valid & E_mov_cancel) ? 1'b0 : D_en ? 
               E_wr_${ds}_iw_rt : E_wr_D_iw_rt", enable => "M_en"},
      {out => ["A_wr_D_iw_rt", 1],          
       in => "D_en ? M_wr_${ds}_iw_rt : M_wr_D_iw_rt", enable => "A_en"},
      {out => ["W_wr_D_iw_rt", 1],          
       in => "D_en ? A_wr_${ds}_iw_rt : A_wr_D_iw_rt", enable => "1'b1"},
      );





    e_assign->adds(

      [["D_ctrl_rs_is_src", 1], "~D_ctrl_rs_not_src"],
    );










    e_assign->adds(
      [["D_src1_raw_hazard_E", 1], "E_wr_D_iw_rs & D_ctrl_rs_is_src & ~E_mov_cancel"],
      [["D_src1_raw_hazard_M", 1], "M_wr_D_iw_rs & D_ctrl_rs_is_src "],
      [["D_src1_raw_hazard_A", 1], "A_wr_D_iw_rs & D_ctrl_rs_is_src "],
      [["D_src1_raw_hazard_W", 1], "W_wr_D_iw_rs & D_ctrl_rs_is_src"],
    
      [["D_src2_raw_hazard_E", 1], 
        "E_wr_D_iw_rt & D_ctrl_rt_is_src_or_slow_dst & ~E_mov_cancel"],
      [["D_src2_raw_hazard_M", 1], 
        "M_wr_D_iw_rt & D_ctrl_rt_is_src_or_slow_dst "],
      [["D_src2_raw_hazard_A", 1], 
        "A_wr_D_iw_rt & D_ctrl_rt_is_src_or_slow_dst "],
      [["D_src2_raw_hazard_W", 1], 
        "W_wr_D_iw_rt & D_ctrl_rt_is_src_or_slow_dst"],
      );






    e_assign->adds(
      [["D_data_depend_unfiltered", 1], 
        "((D_src1_raw_hazard_E | D_src2_raw_hazard_E) & E_ctrl_late_result) |
         ((D_src1_raw_hazard_M | D_src2_raw_hazard_M) & M_ctrl_late_result)"],
      );




    create_x_filter({
      lhs       => "D_data_depend",
      rhs       => "D_data_depend_unfiltered",
      sz        => 1,
      qual_expr => "D_exc_invalidates_inst_value",
    });













    e_assign->adds(
      [["D_dstfield_regnum", $regnum_sz], 
        "D_ctrl_sel_rd_for_dst ? D_iw_rd : D_iw_rt"],

      [["D_dst_regnum", $regnum_sz], 
        "D_ctrl_implicit_dst_retaddr ? $ra_regnum : D_dstfield_regnum"],

      [["D_wr_dst_reg", 1], 
        "(D_dst_regnum != 0) & ~D_ctrl_ignore_dst & D_valid"],
      );

    my @reg_cmp = (
        { divider => "reg_cmp" },
        { radix => "x", signal => "E_wr_D_iw_rs" },
        { radix => "x", signal => "M_wr_D_iw_rs" },
        { radix => "x", signal => "A_wr_D_iw_rs" },
        { radix => "x", signal => "W_wr_D_iw_rs" },
        { radix => "x", signal => "E_wr_D_iw_rt" },
        { radix => "x", signal => "M_wr_D_iw_rt" },
        { radix => "x", signal => "A_wr_D_iw_rt" },
        { radix => "x", signal => "W_wr_D_iw_rt" },
        { radix => "x", signal => "D_ctrl_rs_is_src" },
        { radix => "x", signal => "D_ctrl_rt_is_src_or_slow_dst" },
        { radix => "x", signal => "D_ctrl_ignore_dst" },
        { radix => "x", signal => "D_ctrl_src2_choose_imm16" },
        { radix => "x", signal => "D_data_depend" },
        { radix => "x", signal => "D_dstfield_regnum" },
        { radix => "x", signal => "D_dst_regnum" },
        { radix => "x", signal => "D_wr_dst_reg" },
        { radix => "x", signal => "E_ctrl_late_result" },
        { radix => "x", signal => "M_ctrl_late_result" },
      );

    if ($Opt->{full_waveform_signals}) {
        push(@plaintext_wave_signals, @reg_cmp);
    }
}




sub 
make_src_operands
{
    my $Opt = shift;


    e_assign->adds(
      [["E_fwd_reg_data", $datapath_sz], "E_alu_result"],
      );




    e_mux->add ({
      lhs => ["D_src1_reg", $datapath_sz],
      type => "priority",
      table => [
        "D_src1_raw_hazard_E"   => "E_fwd_reg_data",
        "D_src1_raw_hazard_M"   => "M_fwd_reg_data",
        "D_src1_raw_hazard_A"   => "A_fwd_reg_data",
        "D_src1_raw_hazard_W"   => "W_wr_data",
        "1'b1"                  => "D_rf_a",
        ],
      });

    e_assign->adds(
      [["D_src1", $datapath_sz], "D_src1_reg"],
      );







    e_mux->add ({
      lhs => ["D_src2_reg", $datapath_sz],
      type => "priority",
      table => [
        "D_src2_raw_hazard_E"   => "E_fwd_reg_data",
        "D_src2_raw_hazard_M"   => "M_fwd_reg_data",
        "D_src2_raw_hazard_A"   => "A_fwd_reg_data",
        "D_src2_raw_hazard_W"   => "W_wr_data",
        "1'b1"                  => "D_rf_b",
        ],
      });



    e_assign->adds(
      [["D_src2_imm_sel", 2], "{D_ctrl_hi_imm16,D_ctrl_unsigned_lo_imm16}"],
      );


    my $imm16_sex_datapath_sz = $datapath_sz - 16;    

    e_mux->add ({
      lhs => ["D_src2_imm", $datapath_sz],
      selecto => "D_src2_imm_sel",
      table => [
        "2'b00" => "{{$imm16_sex_datapath_sz {D_iw_imm16[15]}}, D_iw_imm16}",
        "2'b01" => "{{$imm16_sex_datapath_sz {1'b0}}          , D_iw_imm16}",
        "2'b10" => "{D_iw_imm16                               , 16'b0     }",
        "2'b11" => "{{$imm16_sex_datapath_sz {1'b0}}          , 16'b0     }",
        ],
      });


    e_assign->adds(
      [["D_src2", $datapath_sz],
        "D_ctrl_src2_choose_imm16 ? D_src2_imm : D_src2_reg"],
      );


    e_register->adds(
      {out => ["E_src1", $datapath_sz],     in => "D_src1", 
       enable => "E_en"},
      {out => ["E_src2", $datapath_sz],     in => "D_src2", 
       enable => "E_en"},
      {out => ["E_src2_reg", $datapath_sz], in => "D_src2_reg", 
       enable => "E_en"},
    );

    my @src_operands = (
        { divider => "src_operands" },
        { radix => "x", signal => "D_src1_raw_hazard_E" },
        { radix => "x", signal => "D_src1_raw_hazard_M" },
        { radix => "x", signal => "D_src1_raw_hazard_A" },
        { radix => "x", signal => "D_src1_raw_hazard_W" },
        { radix => "x", signal => "D_src2_raw_hazard_E" },
        { radix => "x", signal => "D_src2_raw_hazard_M" },
        { radix => "x", signal => "D_src2_raw_hazard_A" },
        { radix => "x", signal => "D_src2_raw_hazard_W" },
        { radix => "x", signal => "D_src1_reg" },
        { radix => "x", signal => "D_src1" },
        { radix => "x", signal => "D_src2_imm" },
        { radix => "x", signal => "D_src2_reg" },
        { radix => "x", signal => "D_src2_imm_sel" },
        { radix => "x", signal => "D_src2" },
        { radix => "x", signal => "E_src1" },
        { radix => "x", signal => "E_src2" },
        { radix => "x", signal => "M_src1" },
        { radix => "x", signal => "M_src2" },
      );

    if ($Opt->{full_waveform_signals}) {
        push(@plaintext_wave_signals, @src_operands);
    }
}




sub 
make_interrupts
{
    my $Opt = shift;

    my $whoami = "interrupts";

    my $interrupts_enabled = "W_cop0_status_reg_ie & W_normal_mode";
    if ($debug_port_present) {
        $interrupts_enabled .= "& debug_dcr_int_e";
    }

    e_assign->adds(


      [["M_intr_req_nxt", 1],
        "$interrupts_enabled & (
            ((W_cop0_cause_reg_ip_7_2_nxt & W_cop0_status_reg_im_7_2) != 0) |
            (W_cop0_cause_reg_ip_1 & W_cop0_status_reg_im_1) |
            (W_cop0_cause_reg_ip_0 & W_cop0_status_reg_im_0))"],
    );




    e_register->adds(
      {out => ["M_intr_req", 1], in => "M_intr_req_nxt", enable => "M_en" },
    );
}




sub
make_dcache_controls
{
    my $Opt = shift;

    if (!$dcache_present) {
        &$error("D-cache isn't present");
    }











    my $gen_info = manditory_hash($Opt, "gen_info");
    my $bypass_stages = $mmu_present ? ["M", "A"] : ["E", "M", "A"];
    my $bs = $mmu_present ? "M" : "E";


    cpu_pipeline_control_signal($gen_info, "ctrl_ld_bypass", $bypass_stages,
      "${bs}_ctrl_ld & ${bs}_mem_bypass_non_io & ${bs}_sel_data_master");
    cpu_pipeline_control_signal($gen_info, "ctrl_st_bypass", $bypass_stages,
      "${bs}_ctrl_st & ${bs}_mem_bypass_non_io & ${bs}_sel_data_master &" .
      " (~${bs}_op_sc | W_llbit)");
    cpu_pipeline_control_signal($gen_info, "ctrl_ld_st_bypass", $bypass_stages,
      "${bs}_ctrl_ld_st & ${bs}_mem_bypass_non_io & ${bs}_sel_data_master");
    cpu_pipeline_control_signal($gen_info, 
      "ctrl_ld_st_bypass_or_dcache_management", $bypass_stages,
      "((${bs}_ctrl_ld_st & (~${bs}_op_sc | W_llbit)) & ${bs}_mem_bypass_non_io & 
          ${bs}_sel_data_master) |
        ${bs}_ctrl_cache_management");


    cpu_pipeline_control_signal($gen_info, "ctrl_ld_non_bypass", $bypass_stages,
      "${bs}_ctrl_ld & (~${bs}_mem_bypass_non_io | ~${bs}_sel_data_master)");
    cpu_pipeline_control_signal($gen_info, "ctrl_st_non_bypass", $bypass_stages,
      "${bs}_ctrl_st & (~${bs}_mem_bypass_non_io | ~${bs}_sel_data_master) &" .
      " (~${bs}_op_sc | W_llbit)");
    cpu_pipeline_control_signal($gen_info, "ctrl_ld_st_non_bypass", 
      $bypass_stages,
      "${bs}_ctrl_ld_st & (~${bs}_mem_bypass_non_io | ~${bs}_sel_data_master) &
      (~${bs}_op_sc | W_llbit)");

    if ($mmu_present) {

        my @always_bypass = (
            "M_mem_baddr_io_region",
            "M_mem_baddr_dseg_region_with_lsnm",
        );

        if ($tlb_present) {
            push(@always_bypass,
              "(M_mem_baddr_user_region & W_cop0_status_reg_erl)",
            );
        }

        my $bypass_table = [
            join('|', @always_bypass)           => "1",
            "M_mem_baddr_kernel_region"         => 
              "W_cop0_config_reg_k0 == $coherency_uncached",
        ];

        if ($tlb_present) {
            push(@$bypass_table,
              "1'b1"                            => "~M_udtlb_c",
            );
        } else {
            push(@$bypass_table,
              "M_mem_baddr_user_region"         => 
                "W_cop0_status_reg_erl ? 
                   1 : 
                   (W_cop0_config_reg_ku == $coherency_uncached)",

              "1'b1"                            => 
                "W_cop0_config_reg_k23 == $coherency_uncached",
            );
        }

        e_mux->add ({
          lhs => ["M_mem_bypass_non_io", 1],
          type => "priority",
          table => $bypass_table,
        });
    }
}




sub 
decode_mmu_data_regions
{
    my $Opt = shift;

    my $whoami = "Decode MMU data regions";

    my $data_addr_phy_sz  = manditory_int($Opt, "d_Address_Width");

    e_assign->adds(

      [["E_mem_baddr_user_region", 1],
        "E_mem_baddr[$mmu_addr_user_region_msb:$mmu_addr_user_region_lsb]
          == $mmu_addr_user_region"],

      [["E_mem_baddr_privileged_region", 1], "~E_mem_baddr_user_region"],

      [["M_mem_baddr_kernel_region", 1],
        "M_mem_baddr[$mmu_addr_kernel_region_msb:$mmu_addr_kernel_region_lsb]
          == $mmu_addr_kernel_region"],

      [["M_mem_baddr_io_region", 1],
        "M_mem_baddr[$mmu_addr_io_region_msb:$mmu_addr_io_region_lsb] 
          == $mmu_addr_io_region"],

      [["M_mem_baddr_user_region", 1],
        "M_mem_baddr[$mmu_addr_user_region_msb:$mmu_addr_user_region_lsb]
          == $mmu_addr_user_region"],

      [["E_mem_baddr_dseg_region", 1],
        "(E_mem_baddr[$mmu_addr_dseg_region_msb:$mmu_addr_dseg_region_lsb]
          == $mmu_addr_dseg_region) & W_debug_mode"],
    );


    e_register->adds(

      {out => ["M_mem_baddr_dseg_region_with_lsnm", 1],
       in => ("E_mem_baddr_dseg_region" . 
         ($debug_port_present ? "& ~W_cop0_debug_reg_lsnm" : "")),
       enable => "M_en"},

      {out => ["A_mem_baddr_phy", $data_addr_phy_sz, 0, $force_never_export],
       in => "M_mem_baddr_phy",                     enable => "A_en"},
    );
}




sub 
make_tlb_data
{
    my $Opt = shift;

    my $whoami = "TLB data";


    my $imm16_sex_datapath_sz = $datapath_sz - 16;    

    e_assign->adds(

      [["E_mem_baddr_for_vpn", $datapath_sz], 
        "E_src1 + {{$imm16_sex_datapath_sz {E_iw_imm16[15]}}, E_iw_imm16}"],


      [["E_mem_baddr_vpn", $mmu_addr_vpn_sz], 
        "E_mem_baddr_for_vpn[$mmu_addr_vpn_msb:$mmu_addr_vpn_lsb]"],
 

      [["A_mem_baddr_vpn", $mmu_addr_vpn_sz], 
        "A_mem_baddr[$mmu_addr_vpn_msb:$mmu_addr_vpn_lsb]"], 


      [["M_mem_baddr_page_offset", $mmu_addr_page_offset_sz], 
        "M_mem_baddr[$mmu_addr_page_offset_msb:$mmu_addr_page_offset_lsb]"], 



      [["M_mem_baddr_bypass_tlb", 1], 
        "M_mem_baddr_kernel_region | 
         M_mem_baddr_io_region |
         M_mem_baddr_dseg_region_with_lsnm |
         (M_mem_baddr_user_region & W_cop0_status_reg_erl)"],
    );

    e_register->adds(

      {out => ["M_mem_baddr_vpn", $mmu_addr_vpn_sz], 
       in => "E_mem_baddr_vpn",                     enable => "M_en"},

      {out => ["A_mem_baddr_phy_got_pfn", 1, 0, $force_never_export], 
       in => "M_mem_baddr_phy_got_pfn",             enable => "A_en"},
    );







    new_exc_signal({
        exc             => $tlb_load_refill_exc,
        initial_stage   => "M", 
        speedup_stage   => "M",
        rhs             => 
          "M_ctrl_ld_data_access &
             (~M_mem_baddr_bypass_tlb & M_udtlb_hit & M_udtlb_m)",
    });







    new_exc_signal({
        exc             => $tlb_store_refill_exc,
        initial_stage   => "M", 
        speedup_stage   => "M",
        rhs             => 
          "M_ctrl_st_data_access &
             (~M_mem_baddr_bypass_tlb & M_udtlb_hit & M_udtlb_m)",
    });




    new_exc_signal({
        exc             => $tlb_load_invalid_exc,
        initial_stage   => "M", 
        speedup_stage   => "M",
        rhs             => 
          "M_ctrl_ld_data_access &
             (~M_mem_baddr_bypass_tlb & M_udtlb_hit & ~M_udtlb_v)",
    });




    new_exc_signal({
        exc             => $tlb_store_invalid_exc,
        initial_stage   => "M", 
        speedup_stage   => "M",
        rhs             => 
          "M_ctrl_st_data_access &
             (~M_mem_baddr_bypass_tlb & M_udtlb_hit & ~M_udtlb_v)",
    });




    new_exc_signal({
        exc             => $tlb_store_mod_exc,
        initial_stage   => "M", 
        speedup_stage   => "M",
        rhs             => 
          "M_ctrl_st & 
             (~M_mem_baddr_bypass_tlb & M_udtlb_hit & ~M_udtlb_d)",
    });


    my $udtlb_wave_signals_array = nevada_mmu::make_utlb($Opt, 1);

    if ($Opt->{full_waveform_signals}) {
        foreach my $udtlb_wave_signals (@$udtlb_wave_signals_array) {
            push(@plaintext_wave_signals, @$udtlb_wave_signals);
        }
        push(@plaintext_wave_signals, 
          { divider => "TLB Data Exceptions" },
          get_exc_signal_wave($tlb_load_refill_exc, "M"),
          get_exc_signal_wave($tlb_store_refill_exc, "M"),
          get_exc_signal_wave($tlb_load_invalid_exc, "M"),
          get_exc_signal_wave($tlb_store_invalid_exc, "M"),
          get_exc_signal_wave($tlb_store_mod_exc, "M"),
        );
    }
}

1;
