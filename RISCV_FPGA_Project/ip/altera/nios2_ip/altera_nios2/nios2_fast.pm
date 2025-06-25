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






















package nios2_fast;

use cpu_utils;
use cpu_wave_signals;
use cpu_inst_gen;
use cpu_exception_gen;
use cpu_control_reg_gen;
use europa_all;
use europa_utils;
use nios_europa;
use nios_brpred;
use nios_avalon_masters;
use nios_common;
use nios_isa;
use nios_icache;
use nios_dcache;
use nios_div;
use nios_shift_rotate;
use nios2_control_regs;
use nios2_insts;
use nios2_exceptions;
use nios2_common;
use nios2_mmu;
use nios2_mpu;
use nios2_frontend_150;
use nios2_backend_500;
use nios2_backend_control_regs;
use nios2_custom_insts;
use nios2_mul;
use nios2_oci;
use nios2_third_party_debugger_gasket;

use strict;



















sub
get_core_funcs
{
    return {
      get_gen_info_stages   => \&get_gen_info_stages,
      make_cpu              => \&make_cpu,
      make_exc              => \&make_exc,
    };
}


sub
get_gen_info_stages
{
    return ["F", "D", "E", "M", "A", "W"];
}

sub 
make_cpu
{
    my ($Opt, $top_module) = @_;

    my $marker = e_default_module_marker->new($top_module);

    if (manditory_scalar($Opt, "branch_prediction_type") eq "") {
        $Opt->{branch_prediction_type} = $DYNAMIC_BRPRED;
    }

    set_pipeline_description($Opt);
    be_set_control_reg_pipeline_desc($Opt);

    my $testbench_submodule = nios2_be500_make_testbench($Opt);
    e_signal->adds({name => "test_ending", never_export => 1, width => 1});
    e_signal->adds({name => "test_has_ended", never_export => 1, width => 1});

    make_inst_decode($Opt);

    make_fast_pipeline($Opt, $testbench_submodule);

    nios2_fe150_make_frontend($Opt);
    nios2_be500_make_backend($Opt);

    if ($mmu_present) {
        my $tlb_wave_signals = nios2_mmu::make_tlb($Opt);

        if ($Opt->{full_waveform_signals}) {
            push(@plaintext_wave_signals, 
              @$tlb_wave_signals,
            );
        }
    }

    if ($perf_cnt_present) {
        make_perf_cnt($Opt);
    }

    if ($ecc_present) {
        make_ecc_event_bus($Opt);
    }

    if ($oci_present) {
        make_nios2_oci($Opt, $top_module);

    } elsif ($third_party_debug_present) {
        make_nios2_third_party_debugger_gasket($Opt, $top_module);
    }

}



sub 
make_exc
{
    my $Opt = shift;

    my $whoami = "make_exc";

    my $exc_stages = manditory_array($Opt, "exc_stages");
    my $wss = not_empty_scalar($Opt, "wrctl_setup_stage");

    my @extra_exc_info_wave_signals;


    gen_exception_signals($Opt->{gen_info}, $exc_stages);

    if ($Opt->{extra_exc_info}) {
        my @exc_stages_array = @$exc_stages;
        my $last_stage = $exc_stages_array[$#exc_stages_array];

        if ($wss ne $last_stage) {
            &$error("wrctl_setup_stage must be same as last exc_stages");
        }


        my $cause_mux_table = gen_exception_cause_code($wss);
        my $cause_code_signal = "${wss}_exc_highest_pri_cause_code";

        if (scalar(@$cause_mux_table)) {

            e_mux->add ({
              lhs => [$cause_code_signal, $exception_reg_cause_sz],
              type => "priority",
              table => $cause_mux_table,
            });
        } else {

            e_assign->adds(
              [[$cause_code_signal, $exception_reg_cause_sz], "0"],
            );
        }


        my $exc_id_mux_table = gen_exception_id($wss);
        my $exc_id_signal = "${wss}_exc_highest_pri_exc_id";

        if (scalar(@$exc_id_mux_table)) {

            e_mux->add ({
              lhs => [$exc_id_signal, 32],
              type => "priority",
              table => $exc_id_mux_table,
            });
        } else {

            e_assign->adds(
              [[$exc_id_signal, 32], "0"],
            );
        }


        my ($baddr_mux_table, $baddr_record_signals) = 
          gen_exception_baddr($wss);

        my $baddr_addr_signal = "${wss}_exc_highest_pri_baddr";
        my $baddr_record_signal = "${wss}_exc_record_baddr";

        if (scalar(@$baddr_mux_table)) {

            e_mux->add ({
              lhs => [$baddr_addr_signal, $badaddr_reg_baddr_sz],
              type => "priority",
              table => $baddr_mux_table,
            });


            e_assign->adds(
              [[$baddr_record_signal, 1], 
                "A_exc_allowed & " .
                "(" . join('|', @$baddr_record_signals) . ")"],
            );
        } else {

            e_assign->adds(
              [[$baddr_addr_signal, $badaddr_reg_baddr_sz], "0"],
              [[$baddr_record_signal, 1], "0"],
            );
        }

        my @extra_exc_info_wave_signals = (
          { divider => "extra_exc_info" },
          { radix => "d", signal => $cause_code_signal },
          { radix => "x", signal => $baddr_addr_signal },
          { radix => "x", signal => $baddr_record_signal },
        );
    }

    if ($Opt->{full_waveform_signals} && scalar(@extra_exc_info_wave_signals)) {
        push(@plaintext_wave_signals, @extra_exc_info_wave_signals);
    }
}







sub set_pipeline_description
{
    my $Opt = shift;


    $Opt->{stages} = ["F", "D", "E", "M", "A", "W"];


    $Opt->{exc_stages} = ["D", "E", "M", "A"];


    $Opt->{dispatch_stage} = "F";




    $Opt->{dispatch_raw_iw} = "F_ram_iw";


    $Opt->{fetch_npc} = "F_pc_nxt";


    $Opt->{fetch_npcb} = "F_pcb_nxt";


    $Opt->{brpred_table_output_stage} = "F";



    $Opt->{inst_ram_output_stage} = "F";


    $Opt->{ic_fill_stage} = "D";

    if ($mmu_present) {

        $Opt->{uitlb_match_cmp_stage} = "F";
        $Opt->{udtlb_match_cmp_stage} = "E";


        $Opt->{uitlb_match_cmp_vpn} = "F_pc_vpn";
        $Opt->{udtlb_match_cmp_vpn} = "E_mem_baddr_vpn";


        $Opt->{uitlb_match_mux_stage} = "F";
        $Opt->{udtlb_match_mux_stage} = "M";


        $Opt->{uitlb_match_mux_vaddr} = "F_pc";
        $Opt->{udtlb_match_mux_vaddr} = "M_mem_baddr";




        $Opt->{uitlb_match_mux_paddr} = "F_pc_phy";
        $Opt->{udtlb_match_mux_paddr} = "M_mem_baddr_phy";


        $Opt->{uitlb_fill_stage} = "D";
        $Opt->{udtlb_fill_stage} = "A";


        $Opt->{uitlb_fill_vpn} = "D_pc_vpn";
        $Opt->{udtlb_fill_vpn} = "A_mem_baddr_vpn";


        $Opt->{uitlb_want_fill} = "D_uitlb_want_fill";
        $Opt->{udtlb_want_fill} = "A_udtlb_want_fill";





        $Opt->{uitlb_want_fill_expr} = 
          "(~D_pc_phy_got_pfn & ~D_kill & ~M_pipe_flush)";







        $Opt->{udtlb_want_fill_expr} = 
          "(~A_mem_baddr_phy_got_pfn & A_ctrl_mem_data_access & 
            A_pipe_flush & ~A_exc_any_active)";


        $Opt->{uitlb_lru_stage} = "E";
        $Opt->{udtlb_lru_stage} = "A";


        $Opt->{D_ic_want_fill} = 
          "(~D_iw_valid & ~D_kill & ~M_pipe_flush & D_pc_phy_pfn_valid)";
    } else {



        $Opt->{D_ic_want_fill} = "(~D_iw_valid & ~D_kill & ~M_pipe_flush)";
    }

    if ($advanced_exc) {

        $Opt->{cache_operation} = "((A_ctrl_invalidate_i & A_valid) | A_exc_crst_active)";


        $Opt->{cache_operation_baddr} = "A_inst_result";


        $Opt->{inst_crst} = "A_exc_crst_active";


        $Opt->{inst_crst_next_stage} = "W_exc_crst_active";


        $Opt->{crst_taken} = "A_exc_crst_active";
    } else {

        $Opt->{cache_operation} = "(M_ctrl_invalidate_i & M_valid)";


        $Opt->{cache_operation_baddr} = "M_alu_result";


        $Opt->{inst_crst} = "(M_ctrl_crst & M_valid)";


        $Opt->{inst_crst_next_stage} = "A_valid_crst";


        $Opt->{crst_taken} = "(M_ctrl_crst & M_valid & M_en)";
    }


    $Opt->{bht_wr_data} = "M_bht_wr_data_filtered";
    $Opt->{bht_wr_en} = "M_bht_wr_en_filtered";
    $Opt->{bht_wr_addr} = "M_bht_ptr_filtered";
    $Opt->{bht_br_cond_taken_history} = "M_br_cond_taken_history";


    $Opt->{rf_a_field_name} = "a";


    $Opt->{rf_b_field_name} = "b";



    $Opt->{current_register_set} = "W_status_reg_crs";
    $Opt->{previous_register_set} = "W_status_reg_prs";


    $Opt->{add_br_to_taken_history} = "E_add_br_to_taken_history_filtered";



    $Opt->{brpred_prediction_stage} = "D";


    $Opt->{brpred_resolution_stage} = "E";


    $Opt->{brpred_mispredict_stage} = "M";


    $Opt->{brpred_mispredict_reset} = "0";


    $Opt->{rdctl_stage} = "M";



    $Opt->{wrctl_setup_stage} = $advanced_exc ? "A" : "M";


    $Opt->{wrctl_data} = $advanced_exc ? "A_inst_result" : "M_alu_result";


    $Opt->{control_reg_stage} = $advanced_exc ? "W" : "A";


    $Opt->{ci_combo_stage} = "E";


    $Opt->{ci_multi_stage} = "A";



    $Opt->{non_pipelined_long_latency_input_stage} = "M";



    $Opt->{long_latency_output_stage} = "A";



    $Opt->{le_fast_shift_rot_cycles} = 1;

    $Opt->{le_fast_shift_rot_shfcnt} = "(E_src2[4:0])";

    $Opt->{le_fast_shift_data} = "E_src1";


    $Opt->{mul_cell_pipelined} = "1";


    $Opt->{div_done} = "A_div_done";


    $Opt->{data_master_interrupt_sz} = 32;

    if ($mmu_present) {
        $Opt->{mmu_addr_pfn_lsb} = $mmu_addr_pfn_lsb;
    }
}








sub make_fast_pipeline
{
    my ($Opt, $testbench_submodule) = @_;

    my $whoami = "fast_pipeline";

    my $cs = not_empty_scalar($Opt, "control_reg_stage");







    e_assign->adds(
      [["F_stall", 1], "D_stall"],



      [["F_en", 1], "~F_stall"],        
      );

    if ($advanced_exc) {


        e_assign->adds([["F_iw", $iw_sz], "F_ram_iw"]);
    } else {






        my $inject_crst = 
          $cpu_reset ? 
            ($hbreak_present ? 
              "(cpu_resetrequest & hbreak_enabled)" : 
              "cpu_resetrequest") : 
            "1'b0";


        my $inject_intr = "(norm_intr_req";
        if ($imprecise_illegal_mem_exc) {
            $inject_intr .= " | mem_exception_pending";
        }
        $inject_intr .= ")";

        e_assign->adds(
          [["F_iw", $iw_sz], 
            "(latched_oci_tb_hbreak_req & hbreak_enabled) ? $empty_hbreak_iw :
             $inject_crst                                 ? $empty_crst_iw :
             $inject_intr                                 ? $empty_intr_iw : 
                                                            F_ram_iw"],
        );
    }





    e_assign->adds(





      [["F_kill", 1], 
        "D_refetch | M_pipe_flush | E_valid_jmp_indirect |
        ((D_br_pred_taken | D_ctrl_uncond_cti_non_br) & D_issue)"],
    );
      




    my $partial_br_offset_sz = ($pc_sz < 10) ? $pc_sz : 10;

    e_assign->adds(






      [["F_br_taken_waddr_partial", $partial_br_offset_sz+1],
        "F_pc_plus_one[$partial_br_offset_sz-1:0] + 
         F_ram_iw_imm16[$partial_br_offset_sz+1:2]"],
      );






    e_register->adds(
      {out => ["D_iw_valid", 1],                in => "F_iw_valid",  
       enable => "D_en"},
      {out => ["D_issue", 1],                   in => "F_issue",  
       enable => "D_en"},
      {out => ["D_kill", 1],                    in => "F_kill",
       enable => "D_en"},
      {out => ["D_br_taken_waddr_partial", $partial_br_offset_sz+1],
       in => "F_br_taken_waddr_partial", enable => "D_en"},
      );






    e_assign->adds(
      [["D_refetch", 1], "~D_iw_valid & ~D_kill"],
    );





    my $remaining_br_offset_sz = $pc_sz - $partial_br_offset_sz;

    if ($remaining_br_offset_sz > 0) {
        e_assign->adds(

          [["D_br_offset_sex", 30-$partial_br_offset_sz], 
            "{{16 {D_iw_imm16[15]}}, D_iw_imm16[15:$partial_br_offset_sz+2]}"],
        );
    
        e_assign->adds(

          [["D_br_offset_remaining", $remaining_br_offset_sz], 
             "D_br_offset_sex[$remaining_br_offset_sz-1:0]"],



          [["D_br_taken_waddr", $pc_sz], 
             "{ D_pc_plus_one[$pc_sz-1:$partial_br_offset_sz] +
                D_br_offset_remaining + 
                D_br_taken_waddr_partial[$partial_br_offset_sz],
                D_br_taken_waddr_partial[$partial_br_offset_sz-1:0]}"],
        );
    } else {

        e_assign->adds(


          [["D_br_taken_waddr", $pc_sz], 
             "D_br_taken_waddr_partial[$pc_sz-1:0]"],
        );
    }


    e_signal->adds({name => "D_br_taken_baddr", never_export => 1, 
      width => $pc_sz+2});
    e_assign->adds(["D_br_taken_baddr", "{D_br_taken_waddr, 2'b00}"]);

    e_register->adds(
      {out => ["E_br_taken_baddr", $pc_sz+2, 0, $force_never_export], 
       in => "D_br_taken_baddr",  enable => "E_en"},
      {out => ["M_br_taken_baddr", $pc_sz+2, 0, $force_never_export], 
       in => "E_br_taken_baddr",  enable => "M_en"},
      {out => ["A_br_taken_baddr", $pc_sz+2, 0, $force_never_export], 
       in => "M_br_taken_baddr",  enable => "A_en"},
      {out => ["W_br_taken_baddr", $pc_sz+2, 0, $force_never_export], 
       in => "A_br_taken_baddr",  enable => "1'b1"},
    );






    my @pipeline_wave_signals = (
        { divider => "base pipeline" },
        { radix => "x", signal => "clk" },
    );






    my @pipeline_wave_signals = (
        { divider => "base pipeline" },
        { radix => "x", signal => "clk" },
        { radix => "x", signal => "reset_n" },
        { radix => "x", signal => "D_stall" },
        { radix => "x", signal => "A_stall" },
        { radix => "x", signal => "F_pcb_nxt" },
        { radix => "x", signal => "F_pcb" },
        { radix => "x", signal => "D_pcb" },
        { radix => "x", signal => "E_pcb" },
        { radix => "x", signal => "M_pcb" },
        { radix => "x", signal => "A_pcb" },
        { radix => "x", signal => "W_pcb" },
        { radix => "a", signal => "F_vinst" },
        { radix => "a", signal => "D_vinst" },
        { radix => "a", signal => "E_vinst" },
        { radix => "a", signal => "M_vinst" },
        { radix => "a", signal => "A_vinst" },
        { radix => "a", signal => "W_vinst" },
        { radix => "x", signal => "F_inst_ram_hit" },
        { radix => "x", signal => "F_iw_valid" },
        { radix => "x", signal => "F_issue" },
        { radix => "x", signal => "F_kill" },
        { radix => "x", signal => "D_kill" },
        { radix => "x", signal => "D_refetch" },
        { radix => "x", signal => "D_issue" },
        { radix => "x", signal => "D_valid" },
        { radix => "x", signal => "D_rdprs_stall" },
        { radix => "x", signal => "D_rdprs_stall_done" },
        { radix => "x", signal => "E_valid" },
        { radix => "x", signal => "M_valid" },
        { radix => "x", signal => "A_valid" },
        { radix => "x", signal => "W_valid" },
        { radix => "x", signal => "W_wr_dst_reg" },
        { radix => "x", signal => "W_dst_regnum" },
        { radix => "x", signal => "W_wr_data" },
        { radix => "x", signal => "D_en" },
        { radix => "x", signal => "E_en" },
        { radix => "x", signal => "M_en" },
        { radix => "x", signal => "A_en" },
        { radix => "x", signal => "F_iw" },
        { radix => "x", signal => "D_iw" },
        { radix => "x", signal => "E_iw" },
        { radix => "x", signal => "M_pipe_flush" },
        { radix => "x", signal => "M_pipe_flush_baddr" },
        { radix => "x", signal => 
          $eic_present ? "ext_intr_req" : "norm_intr_req"},
        $imprecise_illegal_mem_exc ? 
          { radix => "x", signal => "A_mem_addr_exception" } : "",
        $imprecise_illegal_mem_exc ? 
          { radix => "x", signal => "mem_exception_pending" } : "",
        @{get_control_regs_for_waves($Opt->{control_regs})},
    );

    if ($advanced_exc) {
        push(@pipeline_wave_signals, 
          { radix => "x", signal => "A_pipe_flush" },
          { radix => "x", signal => "A_pipe_flush_baddr" },
        );
    } else {
        push(@pipeline_wave_signals, 
          { radix => "x", signal => "E_valid_prior_to_hbreak" },
        );
    }

    push(@plaintext_wave_signals, @pipeline_wave_signals);
}







sub make_inst_decode
{
    my $Opt = shift;

    &$progress("    Instruction decoding");





    my $gen_info = manditory_hash($Opt, "gen_info");




    &$progress("      Instruction fields");
    cpu_inst_gen::gen_inst_fields($gen_info, $Opt->{inst_field_info},
      ["F", "F_ram", "D", "E", "M", "A", "W"]);





    &$progress("      Instruction decodes");
    cpu_inst_gen::gen_inst_decodes($gen_info, $Opt->{inst_desc_info},
      ["F", "D", "E", "M", "A", "W"]);




    &$progress("      Signals for RTL simulation waveforms");
    cpu_inst_gen::create_sim_wave_inst_names($gen_info, $Opt->{inst_desc_info},
      ["F", "D", "E", "M", "A", "W"]);




    cpu_inst_gen::create_sim_wave_vinst_names($gen_info, $Opt->{inst_desc_info},
      ["F", "D", "E", "M", "A", "W"],
      {},       # Default inst signal names
      { F => "F_iw_valid", D => "D_issue" });

    &$progress("      Instruction controls");

    set_inst_ctrl_initial_stage($a_not_src_ctrl, "F");
    set_inst_ctrl_initial_stage($b_not_src_ctrl, "F");
    set_inst_ctrl_initial_stage($b_is_dst_ctrl, "F");
    set_inst_ctrl_initial_stage($ignore_dst_ctrl, "F");
    set_inst_ctrl_initial_stage($src2_choose_imm_ctrl, "F");

    set_inst_ctrl_initial_stage($br_ctrl, "F");
    set_inst_ctrl_initial_stage($br_uncond_ctrl, "F");
    set_inst_ctrl_initial_stage($br_cond_ctrl, "D");
    set_inst_ctrl_initial_stage($br_always_pred_taken_ctrl, "D");
    set_inst_ctrl_initial_stage($jmp_direct_ctrl, "F");
    set_inst_ctrl_initial_stage($jmp_indirect_ctrl, "D");
    set_inst_ctrl_initial_stage($uncond_cti_non_br_ctrl, "D");

    set_inst_ctrl_initial_stage($supervisor_only_ctrl, "D");
    set_inst_ctrl_initial_stage($unimp_trap_ctrl, "D");
    set_inst_ctrl_initial_stage($unimp_nop_ctrl, "D");
    set_inst_ctrl_initial_stage($illegal_ctrl, "D");
    set_inst_ctrl_initial_stage($exception_ctrl, "D");
    set_inst_ctrl_initial_stage($break_ctrl, "D");
    set_inst_ctrl_initial_stage($crst_ctrl, "D");
    set_inst_ctrl_initial_stage($implicit_dst_retaddr_ctrl, "F");
    set_inst_ctrl_initial_stage($implicit_dst_eretaddr_ctrl, "F");
    set_inst_ctrl_initial_stage($hi_imm16_ctrl, "F");
    set_inst_ctrl_initial_stage($unsigned_lo_imm16_ctrl, "F");
    set_inst_ctrl_initial_stage($alu_signed_comparison_ctrl, "D");
    set_inst_ctrl_initial_stage($alu_subtract_ctrl, "D");
    set_inst_ctrl_initial_stage($cmp_ctrl, "D");
    set_inst_ctrl_initial_stage($logic_ctrl, "D");
    set_inst_ctrl_initial_stage($retaddr_ctrl, "D");
    set_inst_ctrl_initial_stage($wrctl_inst_ctrl, "E");
    set_inst_ctrl_initial_stage($rdctl_inst_ctrl, "E");

    set_inst_ctrl_initial_stage($ld_ctrl, "D");
    set_inst_ctrl_initial_stage($ld_dcache_management_ctrl, "E");
    set_inst_ctrl_initial_stage($ld_signed_ctrl, "E");
    set_inst_ctrl_initial_stage($ld8_ctrl, "E");
    set_inst_ctrl_initial_stage($ld16_ctrl, "E");
    set_inst_ctrl_initial_stage($ld32_ctrl, "E");
    set_inst_ctrl_initial_stage($ld8_ld16_ctrl, "E");
    set_inst_ctrl_initial_stage($ld_io_ctrl, "E");
    set_inst_ctrl_initial_stage($ld_non_io_ctrl, "E");

    set_inst_ctrl_initial_stage($st_ctrl, "E");
    set_inst_ctrl_initial_stage($st8_ctrl, "E");
    set_inst_ctrl_initial_stage($st16_ctrl, "E");
    set_inst_ctrl_initial_stage($st_non32_ctrl, "E");
    set_inst_ctrl_initial_stage($st_io_ctrl, "E");
    set_inst_ctrl_initial_stage($st_io_non_st32_ctrl, "E");
    set_inst_ctrl_initial_stage($st_non_io_non_st32_ctrl, "E");
    set_inst_ctrl_initial_stage($st_non_io_ctrl, "E");

    set_inst_ctrl_initial_stage($mem_ctrl, "E");
    set_inst_ctrl_initial_stage($mem_data_access_ctrl, "E");
    set_inst_ctrl_initial_stage($mem8_ctrl, "E");
    set_inst_ctrl_initial_stage($mem16_ctrl, "E");
    set_inst_ctrl_initial_stage($mem32_ctrl, "E");
    set_inst_ctrl_initial_stage($ld_st_ctrl, "E");
    set_inst_ctrl_initial_stage($ld_st_io_ctrl, "E");
    set_inst_ctrl_initial_stage($ld_st_non_io_ctrl, "E");
    set_inst_ctrl_initial_stage($ld_st_non_io_non_st32_ctrl, "E");
    set_inst_ctrl_initial_stage($ld_st_non_st32_ctrl, "E");
    set_inst_ctrl_initial_stage($invalidate_i_ctrl, "E");
    set_inst_ctrl_initial_stage($dcache_management_ctrl, "E");

    set_inst_ctrl_initial_stage($custom_combo_ctrl, "D");
    set_inst_ctrl_initial_stage($custom_multi_ctrl, "D");

    my $late_result_ctrl_names = ["ld","shift_rot","rdctl_inst","custom_multi"];

    if ($hw_mul) {
        if ($hw_mul_uses_designware || $hw_mul_uses_les || 
          $hw_mul_uses_embedded_mults) {
            set_inst_ctrl_initial_stage($mul_lsw_ctrl, "D");
            push(@$late_result_ctrl_names, "mul_lsw");
        } elsif ($hw_mul_uses_dsp_block) {
            set_inst_ctrl_initial_stage($mulx_ctrl, "D");
            set_inst_ctrl_initial_stage($mul_shift_rot_ctrl, "M");





            set_inst_ctrl_initial_stage($mul_shift_src1_signed_ctrl, "D");
            set_inst_ctrl_initial_stage($mul_shift_src2_signed_ctrl, "D");

            push(@$late_result_ctrl_names, "mul");
        } else {
            &$error("make_inst_decode: unsupported multiplier implementation");
        }
    }

    if ($fast_shifter_uses_dsp_block) {
        set_inst_ctrl_initial_stage($rot_ctrl, "D");
        set_inst_ctrl_initial_stage($shift_rot_ctrl, "D");
        set_inst_ctrl_initial_stage($shift_rot_right_ctrl, "D");
        set_inst_ctrl_initial_stage($shift_right_ctrl, "D");
    } elsif ($fast_shifter_uses_les || $fast_shifter_uses_designware) {
        set_inst_ctrl_initial_stage($rot_ctrl, "D");
        set_inst_ctrl_initial_stage($shift_rot_ctrl, "D");
        set_inst_ctrl_initial_stage($shift_rot_right_ctrl, "D");
        set_inst_ctrl_initial_stage($shift_rot_left_ctrl, "D");
        set_inst_ctrl_initial_stage($shift_right_arith_ctrl, "D");
    } elsif ($small_shifter_uses_les) {
        set_inst_ctrl_initial_stage($shift_rot_ctrl, "M");
        set_inst_ctrl_initial_stage($rot_right_ctrl, "M");
        set_inst_ctrl_initial_stage($shift_logical_ctrl, "M");
        set_inst_ctrl_initial_stage($shift_rot_right_ctrl, "M");
        set_inst_ctrl_initial_stage($shift_right_arith_ctrl, "M");
    } else {
        &$error("make_inst_decode: unsupported shifter implementation");
    }

    if ($hw_div) {
        set_inst_ctrl_initial_stage($div_ctrl, "D");
        set_inst_ctrl_initial_stage($div_signed_ctrl, "D");
        push(@$late_result_ctrl_names, "div");
    }


    if ($dcache_present) {
        set_inst_ctrl_initial_stage($dc_index_nowb_inv_ctrl, "E");

        if ($wide_dcache_present) {
            set_inst_ctrl_initial_stage($dc_index_wb_inv_ctrl, "E");
            set_inst_ctrl_initial_stage($dc_addr_wb_inv_ctrl, "E");
            set_inst_ctrl_initial_stage($dc_addr_nowb_inv_ctrl, "E");
            set_inst_ctrl_initial_stage($dc_index_inv_ctrl, "E");
            set_inst_ctrl_initial_stage($dc_addr_inv_ctrl, "E");
            set_inst_ctrl_initial_stage($dc_nowb_inv_ctrl, "E");
        } else {
            set_inst_ctrl_initial_stage($dc_wb_inv_ctrl, "E");
        }
    }

    if ($shadow_present) {
        set_inst_ctrl_initial_stage($rdprs_ctrl, "D");
    }

    my $default_allowed_modes = 
      manditory_array($Opt, "default_inst_ctrl_allowed_modes");
    my $exception_allowed_modes = 
      manditory_array($Opt, "exception_inst_ctrl_allowed_modes");


    my $flush_pipe_always_ctrl = nios2_insts::additional_inst_ctrl($Opt, {
      name  => "flush_pipe_always",
      ctrls => ["flush_pipe", "wr_ctl_reg"],
      allowed_modes => $exception_allowed_modes,
    });
    set_inst_ctrl_initial_stage($flush_pipe_always_ctrl, "D");




    my $alu_force_xor_ctrl = nios2_insts::additional_inst_ctrl($Opt, {
      name => "alu_force_xor",
      ctrls => ["br_cmp_eq_ne"],
      allowed_modes => $default_allowed_modes,
    });
    set_inst_ctrl_initial_stage($alu_force_xor_ctrl, "D");





    my $late_result_ctrl = nios2_insts::additional_inst_ctrl($Opt, {
      name  => "late_result",
      ctrls => $late_result_ctrl_names,
      allowed_modes => $default_allowed_modes,
    });
    set_inst_ctrl_initial_stage($late_result_ctrl, "D");
}






sub 
make_perf_cnt
{
    my $Opt = shift;

    my $whoami = "Performance counters";
    my $wss = not_empty_scalar($Opt, "wrctl_setup_stage");
    my $cs = not_empty_scalar($Opt, "control_reg_stage");
    my $wdata = not_empty_scalar($Opt, "wrctl_data");


    my $perf_cnt_sz = manditory_int($Opt, "performance_counters_width");






    e_register->adds(
      {out => "E_refetch_perf_cnt",         in => "D_refetch",
       enable => "E_en"},
      {out => "A_pipe_flush_perf_cnt",      in => "M_pipe_flush", 
       enable => "A_en"},


      {out => ["perf_clr", 1], 
       in => "(${wss}_wrctl_sim & ${wss}_valid) ? 
               ${wss}_wrctl_data_sim_reg_perf_cnt_clr : 0",
       enable => "${cs}_en", async_value => "1'b1" },
      );

    if ($dcache_present) {
        e_register->adds(

          {out => ["A_dc_hit_perf_cnt", 1], in => "M_dc_hit",
           enable => "A_en"},
      );
    }











    e_assign->adds(


      [["D_no_disp_pipe_flush", 1], 
        "M_pipe_flush | A_pipe_flush_perf_cnt"],


      [["D_no_disp_delay_slot", 1], 
        "D_kill & ~E_refetch_perf_cnt & ~D_no_disp_pipe_flush"],




      [["D_no_disp_data_depend", 1], 
        "D_data_depend & D_issue & ~M_pipe_flush"],
    );

    if ($icache_present) {
        e_assign->adds(

          [["D_no_disp_icache_miss", 1], "D_ic_want_fill | E_refetch_perf_cnt"],
        );
    }














    e_assign->adds(

      [["perf_cycles_nxt", $perf_cnt_sz], "perf_cycles + 1"],


      [["perf_dispatched_nxt", $perf_cnt_sz], 
        "(D_valid & E_en) ? perf_dispatched + 1 : perf_dispatched"],


      [["perf_retired_nxt", $perf_cnt_sz], 
        "(A_valid & A_en) ? perf_retired + 1 : perf_retired"],


      [["perf_A_rd_stall_nxt", $perf_cnt_sz], 
        "$perf_cnt_inc_rd_stall ? perf_A_rd_stall + 1 : perf_A_rd_stall"],


      [["perf_A_wr_stall_nxt", $perf_cnt_sz], 
        "$perf_cnt_inc_wr_stall ? perf_A_wr_stall + 1 : perf_A_wr_stall"],



      [["perf_no_disp_pipe_flush_nxt", $perf_cnt_sz], 
        "(D_no_disp_pipe_flush & ~E_stall) ? 
           perf_no_disp_pipe_flush + 1 : perf_no_disp_pipe_flush"],



      [["perf_no_disp_delay_slot_nxt", $perf_cnt_sz], 
        "(D_no_disp_delay_slot & ~E_stall) ? 
           perf_no_disp_delay_slot + 1 : perf_no_disp_delay_slot"],



      [["perf_no_disp_data_depend_nxt", $perf_cnt_sz], 
        "(D_no_disp_data_depend & ~E_stall) ? 
           perf_no_disp_data_depend + 1 : perf_no_disp_data_depend"],



      [["perf_br_pred_bad_nxt", $perf_cnt_sz], 
        "(M_br_mispredict & ~A_stall) ? 
           perf_br_pred_bad + 1 : perf_br_pred_bad"],



      [["perf_br_pred_good_nxt", $perf_cnt_sz], 
        "(M_ctrl_br_cond & ~M_br_mispredict & ~A_stall) ? 
           perf_br_pred_good + 1 : perf_br_pred_good"],
    );

    if ($icache_present) {
        e_assign->adds(


          [["perf_no_disp_icache_miss_nxt", $perf_cnt_sz], 
            "(D_no_disp_icache_miss & ~E_stall) ? 
               perf_no_disp_icache_miss + 1 : perf_no_disp_icache_miss"],
        );

        e_register->adds(
          {out => ["perf_no_disp_icache_miss", $perf_cnt_sz], 
           in => "perf_clr ? 0 : perf_no_disp_icache_miss_nxt", 
           enable => "perf_en"},
        );
    }

    if ($dcache_present) {
        e_assign->adds(

          [["perf_ld_hit_nxt", $perf_cnt_sz], 
            "(A_dc_hit_perf_cnt & A_ctrl_ld_non_bypass & A_valid & 
              A_wr_dst_reg & ~A_stall) ? perf_ld_hit + 1 : perf_ld_hit"],
    

          [["perf_ld_miss_nxt", $perf_cnt_sz], 
            "(~A_dc_hit_perf_cnt & A_ctrl_ld_non_bypass & A_valid & 
              A_wr_dst_reg & ~A_stall) ? perf_ld_miss + 1 : perf_ld_miss"],
    

          [["perf_st_hit_nxt", $perf_cnt_sz], 
            "(A_dc_hit_perf_cnt & A_ctrl_st_non_bypass & A_valid & ~A_stall) ?
              perf_st_hit + 1 : perf_st_hit"],
    

          [["perf_st_miss_nxt", $perf_cnt_sz], 
            "(~A_dc_hit_perf_cnt & A_ctrl_st_non_bypass & A_valid & ~A_stall) ?
              perf_st_miss + 1 : perf_st_miss"],
        );

        e_register->adds(
          {out => ["perf_ld_hit", $perf_cnt_sz], 
           in => "perf_clr ? 0 : perf_ld_hit_nxt", enable => "perf_en"},
          {out => ["perf_ld_miss", $perf_cnt_sz], 
           in => "perf_clr ? 0 : perf_ld_miss_nxt", enable => "perf_en"},
          {out => ["perf_st_hit", $perf_cnt_sz], 
           in => "perf_clr ? 0 : perf_st_hit_nxt", enable => "perf_en"},
          {out => ["perf_st_miss", $perf_cnt_sz], 
           in => "perf_clr ? 0 : perf_st_miss_nxt", enable => "perf_en"},
        );
    }

    e_assign->adds(
      [["perf_en", 1], "${cs}_sim_reg_perf_cnt_en"],
    );   

    e_register->adds(
      {out => ["perf_cycles", $perf_cnt_sz], 
       in => "perf_clr ? 0 : perf_cycles_nxt", enable => "perf_en"},
      {out => ["perf_dispatched", $perf_cnt_sz], 
       in => "perf_clr ? 0 : perf_dispatched_nxt", enable => "perf_en"},
      {out => ["perf_retired", $perf_cnt_sz], 
       in => "perf_clr ? 0 : perf_retired_nxt", enable => "perf_en"},
      {out => ["perf_A_rd_stall", $perf_cnt_sz], 
       in => "perf_clr ? 0 : perf_A_rd_stall_nxt", enable => "perf_en"},
      {out => ["perf_A_wr_stall", $perf_cnt_sz], 
       in => "perf_clr ? 0 : perf_A_wr_stall_nxt", enable => "perf_en"},
      {out => ["perf_no_disp_pipe_flush", $perf_cnt_sz], 
       in => "perf_clr ? 0 : perf_no_disp_pipe_flush_nxt", 
       enable => "perf_en"},
      {out => ["perf_no_disp_delay_slot", $perf_cnt_sz], 
       in => "perf_clr ? 0 : perf_no_disp_delay_slot_nxt", 
       enable => "perf_en"},
      {out => ["perf_no_disp_data_depend", $perf_cnt_sz], 
       in => "perf_clr ? 0 : perf_no_disp_data_depend_nxt", 
       enable => "perf_en"},
      {out => ["perf_br_pred_bad", $perf_cnt_sz], 
       in => "perf_clr ? 0 : perf_br_pred_bad_nxt", enable => "perf_en"},
      {out => ["perf_br_pred_good", $perf_cnt_sz], 
       in => "perf_clr ? 0 : perf_br_pred_good_nxt", enable => "perf_en"},
    );

    my @perf_counters = (
      { divider => "perf_counters" },
      { radix => "x", signal => "clk" },
      { radix => "x", signal => "perf_clr" },
      { radix => "x", signal => "perf_en" },
      { radix => "a", signal => "F_vinst" },
      { radix => "a", signal => "D_vinst" },
      { radix => "a", signal => "E_vinst" },
      { radix => "a", signal => "M_vinst" },
      { radix => "a", signal => "A_vinst" },
      { radix => "a", signal => "W_vinst" },
      { radix => "x", signal => "F_inst_ram_hit" },
      { radix => "x", signal => "F_issue" },
      { radix => "x", signal => "F_kill" },
      { radix => "x", signal => "D_kill" },
      { radix => "x", signal => "D_refetch" },
      { radix => "x", signal => "D_iw_valid" },
      { radix => "x", signal => "D_issue" },
      $icache_present ? { radix => "x", signal => "D_ic_want_fill" } : "",
      $icache_present ? { radix => "x", signal => "E_refetch_perf_cnt" } : "",
      { radix => "d", signal => "perf_cycles" },
      { radix => "d", signal => "perf_dispatched" },
      { radix => "d", signal => "perf_retired" },
      { radix => "d", signal => "perf_A_rd_stall" },
      { radix => "d", signal => "perf_A_wr_stall" },
      { radix => "d", signal => "perf_no_disp_pipe_flush" },
      { radix => "d", signal => "perf_no_disp_delay_slot" },
      { radix => "d", signal => "perf_no_disp_data_depend" },
      $icache_present ? 
        { radix => "d", signal => "perf_no_disp_icache_miss" } : "",
      { radix => "d", signal => "perf_br_pred_bad" },
      { radix => "d", signal => "perf_br_pred_good" },
      $dcache_present ? { radix => "d", signal => "perf_ld_hit" } : "",
      $dcache_present ? { radix => "d", signal => "perf_ld_miss" } : "",
      $dcache_present ? { radix => "d", signal => "perf_st_hit" } : "",
      $dcache_present ? { radix => "d", signal => "perf_st_miss" } : "",
    );

    push(@plaintext_wave_signals, @perf_counters);
}

sub
make_ecc_event_bus
{
    my $Opt = shift;

    &$progress("    ECC Event Bus");

    my @event_bus_signals;
    my @ecc_exception_list;



    my $event_bus_sz = 30;



    if (manditory_int($Opt, "num_tightly_coupled_data_masters") > 0) {
        push(@event_bus_signals, "1'b0");   # DTCM3_UE
        push(@event_bus_signals, "1'b0");   # DTCM3_RE
        push(@event_bus_signals, "1'b0");   # DTCM2_UE
        push(@event_bus_signals, "1'b0");   # DTCM2_RE
        push(@event_bus_signals, "1'b0");   # DTCM1_UE
        push(@event_bus_signals, "1'b0");   # DTCM1_RE
        push(@event_bus_signals, "1'b0");   # DTCM0_UE
        push(@event_bus_signals, "1'b0");   # DTCM0_RE
    } else {
        push(@event_bus_signals, "1'b0");   # DTCM3_UE
        push(@event_bus_signals, "1'b0");   # DTCM3_RE
        push(@event_bus_signals, "1'b0");   # DTCM2_UE
        push(@event_bus_signals, "1'b0");   # DTCM2_RE
        push(@event_bus_signals, "1'b0");   # DTCM1_UE
        push(@event_bus_signals, "1'b0");   # DTCM1_RE
        push(@event_bus_signals, "1'b0");   # DTCM0_UE
        push(@event_bus_signals, "1'b0");   # DTCM0_RE
    }

    if ($mmu_present && $mmu_ecc_present) {

        e_register->adds(

          {out => ["tlb_re_shifted", 1],    in => "tlb_re",
           enable => "1'b1"},         
          {out => ["tlb_ue_shifted", 1],    in => "tlb_ue",
           enable => "1'b1"},
          {out => ["tlb_sw_shifted", 1],    in => "tlb_sw",
           enable => "1'b1"},
        );
        
        e_assign->adds(
          [["ecc_event_tlb_re", 1], "tlb_re ^ tlb_re_shifted"],
          [["ecc_event_tlb_ue", 1], "tlb_ue ^ tlb_ue_shifted"],
          [["ecc_event_tlb_sw", 1], "tlb_sw ^ tlb_sw_shifted"],
        );
        
        push(@event_bus_signals, "ecc_event_tlb_sw"); # TLB_SW
        push(@event_bus_signals, "ecc_event_tlb_ue"); # TLB_UE
        push(@event_bus_signals, "ecc_event_tlb_re"); # TLB_RE
        push(@ecc_exception_list, "A_exc_ecc_error_itlb_active");
        push(@ecc_exception_list, "A_exc_ecc_error_dtlb_active");

    } else {
        push(@event_bus_signals, "1'b0");   # TLB_SW
        push(@event_bus_signals, "1'b0");   # TLB_UE
        push(@event_bus_signals, "1'b0");   # TLB_RE
    }
    
    if ($dc_ecc_present || $dtcm_present) {
        push(@ecc_exception_list, "A_exc_ecc_data_error_active");
    }


    if ($dc_ecc_present) {
        push(@event_bus_signals, "dc_wb_ecc_event_unrecoverable_err");   # DCWB_UE
        push(@event_bus_signals, "dc_wb_ecc_event_recoverable_err");     # DCWB_RE
        push(@event_bus_signals, "dc_data_ecc_event_unrecoverable_err"); # DCDAT_UE
        push(@event_bus_signals, "dc_data_ecc_event_recoverable_err");   # DCDAT_RE
        push(@event_bus_signals, "dc_tag_ecc_event_unrecoverable_err");  # DCTAG_UE
        push(@event_bus_signals, "dc_tag_ecc_event_recoverable_err");    # DCTAG_RE

    } else {
        push(@event_bus_signals, "1'b0");   # DCWB_UE
        push(@event_bus_signals, "1'b0");   # DCWB_RE
        push(@event_bus_signals, "1'b0");   # DCDAT_UE
        push(@event_bus_signals, "1'b0");   # DCDAT_RE
        push(@event_bus_signals, "1'b0");   # DCTAG_UE
        push(@event_bus_signals, "1'b0");   # DCTAG_RE
    }

    if ($itcm_ecc_present && manditory_int($Opt, "num_tightly_coupled_instruction_masters") > 0) {
        my $cmi = manditory_int($Opt, "num_tightly_coupled_instruction_masters");
        while ($cmi < 4) {
            push(@event_bus_signals, "1'b0");
            push(@event_bus_signals, "1'b0");
            $cmi = $cmi + 1;
        }
        
        for ($cmi = manditory_int($Opt, "num_tightly_coupled_instruction_masters"); 
          $cmi > 0;
          $cmi--) {
            my $cmi_minus1 = $cmi - 1;
            e_register->adds(

              {out => ["itcm${cmi_minus1}_re_shifted", 1],    in => "itcm${cmi_minus1}_re",
               enable => "1'b1"},         
              {out => ["itcm${cmi_minus1}_ue_shifted", 1],    in => "itcm${cmi_minus1}_ue",
               enable => "1'b1"},
            );
            
            e_assign->adds(
              [["ecc_event_itcm${cmi_minus1}_re", 1], "itcm${cmi_minus1}_re ^ itcm${cmi_minus1}_re_shifted"],
              [["ecc_event_itcm${cmi_minus1}_ue", 1], "itcm${cmi_minus1}_ue ^ itcm${cmi_minus1}_ue_shifted"],
            );
            
            push(@event_bus_signals, "ecc_event_itcm${cmi_minus1}_ue"); # ITCM_UE
            push(@event_bus_signals, "ecc_event_itcm${cmi_minus1}_re"); # ITCM_RE
        }       
    } else {
        push(@event_bus_signals, "1'b0");   # ITCM3_UE
        push(@event_bus_signals, "1'b0");   # ITCM3_RE
        push(@event_bus_signals, "1'b0");   # ITCM2_UE
        push(@event_bus_signals, "1'b0");   # ITCM2_RE
        push(@event_bus_signals, "1'b0");   # ITCM1_UE
        push(@event_bus_signals, "1'b0");   # ITCM1_RE
        push(@event_bus_signals, "1'b0");   # ITCM0_UE
        push(@event_bus_signals, "1'b0");   # ITCM0_RE
    }


    if ($ic_ecc_present) {

        e_register->adds(

          {out => ["ic_tag_re_shifted", 1],    in => "ic_tag_re",
           enable => "1'b1"},         
          {out => ["ic_dat_re_shifted", 1],    in => "ic_dat_re",
           enable => "1'b1"},
        );

        e_assign->adds(
          [["ecc_event_ic_tag_re", 1], "ic_tag_re ^ ic_tag_re_shifted"],
          [["ecc_event_ic_dat_re", 1], "ic_dat_re ^ ic_dat_re_shifted"],
        );

        push(@event_bus_signals, "ecc_event_ic_dat_re"); # ICDAT_RE
        push(@event_bus_signals, "ecc_event_ic_tag_re"); # ICTAG_RE
    } else {
        push(@event_bus_signals, "1'b0");   # ICDAT_RE
        push(@event_bus_signals, "1'b0");   # ICTAG_RE
    }


    if ($rf_ecc_present) {
        push(@event_bus_signals, "rf_ecc_event_unrecoverable_err"); # RF_UE
        push(@event_bus_signals, "rf_ecc_event_recoverable_err");   # RF_RE

        push(@ecc_exception_list, "A_exc_ecc_rf_error_active");
    } else {
        push(@event_bus_signals, "1'b0");       # RF_UE
        push(@event_bus_signals, "1'b0");       # RF_RE
    }

    e_assign->adds(
       [["ecc_exceptions",1], 
         scalar(@ecc_exception_list) ? join(' | ', @ecc_exception_list) : "1'b0"]
    );

    my $event_bus_concat = join(',', @event_bus_signals);

    e_register->adds(

      {out => ["ecc_event_eeh", 1],    in => "1'b1",
       enable => "W_ecc_exc_enabled & W_status_reg_eh & ecc_exceptions"},


      {out => ["ecc_event_bus_reg", $event_bus_sz],    in => "{${event_bus_concat},ecc_event_eeh}",
       enable => "1'b1"},
    );
    

    e_signal->adds(
      {name => "ecc_event_bus", width => $event_bus_sz, export => $force_export },
    );

    push(@{$Opt->{port_list}},
      ["ecc_event_bus"         => $event_bus_sz, "out" ],
    );
    
    e_assign->adds(
      [["ecc_event_bus", $event_bus_sz], "ecc_event_bus_reg"],
    );




    if ($ecc_test_ports_present) {
       my @ecc_ram_type = ("ic_tag", "ic_data", "dc_tag", "dc_data", 
         "rf", "dtcm0", "dtcm1", "dtcm2", "dtcm3", "tlb");

       foreach (@ecc_ram_type) {
           push(@{$Opt->{port_list}},
                ["ecc_test_${_}"         => 72,  "in" ],
                ["ecc_test_${_}_valid"   => 1,   "in" ],
                ["ecc_test_${_}_ready"   => 1,   "out" ],
           );
       }
    }
}

1;
