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






















package nios2_small;

use cpu_utils;
use cpu_wave_signals;
use cpu_inst_gen;
use europa_all;
use europa_utils;
use nios_europa;
use nios_brpred;
use nios_avalon_masters;
use nios_common;
use nios_isa;
use nios_icache;
use nios_div;
use nios_shift_rotate;
use nios2_insts;
use nios2_common;
use nios2_frontend_150;
use nios2_backend_400;
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
    };
}


sub
get_gen_info_stages
{
    return ["F", "D", "E", "M", "W"];
}

sub 
make_cpu
{
    my ($Opt, $top_module) = (@_);

    my $marker = e_default_module_marker->new($top_module);

    if ($Opt->{branch_prediction_type} eq "") {
        $Opt->{branch_prediction_type} = $STATIC_BRPRED;
    }

    set_pipeline_description($Opt);
    be_set_control_reg_pipeline_desc($Opt);

    my $testbench_submodule = nios2_be400_make_testbench($Opt);
    e_signal->adds({name => "test_ending", never_export => 1, width => 1});
    e_signal->adds({name => "test_has_ended", never_export => 1, width => 1});

    make_inst_decode($Opt);

    make_small_pipeline($Opt, $testbench_submodule);

    nios2_fe150_make_frontend($Opt);
    nios2_be400_make_backend($Opt);

    if ($perf_cnt_present) {
        make_perf_cnt($Opt);
    }

    if ($oci_present) {
        make_nios2_oci($Opt, $top_module);

    } elsif ($third_party_debug_present) {
        make_nios2_third_party_debugger_gasket($Opt, $top_module);
    }
}







sub set_pipeline_description
{
    my $Opt = shift;


    $Opt->{stages} = ["F", "D", "E", "M", "W"];


    $Opt->{exc_stages} = [];


    $Opt->{dispatch_stage} = "F";




    $Opt->{dispatch_raw_iw} = "F_ram_iw";


    $Opt->{fetch_npc} = "F_pc_nxt";


    $Opt->{fetch_npcb} = "F_pcb_nxt";


    $Opt->{brpred_table_output_stage} = "F";



    $Opt->{inst_ram_output_stage} = "F";


    $Opt->{ic_fill_stage} = "D";




    $Opt->{D_ic_want_fill} = "(~D_iw_valid & ~D_kill & ~M_pipe_flush)";


    $Opt->{cache_operation} = "(M_ctrl_invalidate_i & M_valid)";


    $Opt->{cache_operation_baddr} = "M_alu_result";


    $Opt->{inst_crst} = "(M_ctrl_crst & M_valid)";


    $Opt->{inst_crst_next_stage} = "(W_ctrl_crst & W_valid)";


    $Opt->{crst_taken} = "(M_ctrl_crst & M_valid & M_en)";


    $Opt->{bht_wr_data} = "M_bht_wr_data_filtered";
    $Opt->{bht_wr_en} = "M_bht_wr_en_filtered";
    $Opt->{bht_wr_addr} = "M_bht_ptr_filtered";
    $Opt->{bht_br_cond_taken_history} = "M_br_cond_taken_history";


    $Opt->{rf_a_field_name} = "a";


    $Opt->{rf_b_field_name} = "b";


    $Opt->{add_br_to_taken_history} = "E_add_br_to_taken_history_filtered";



    $Opt->{brpred_prediction_stage} = "D";


    $Opt->{brpred_resolution_stage} = "E";


    $Opt->{brpred_mispredict_stage} = "M";


    $Opt->{brpred_mispredict_reset} = "0";


    $Opt->{rdctl_stage} = "E";



    $Opt->{wrctl_setup_stage} = "E";


    $Opt->{wrctl_data} = "E_alu_result";


    $Opt->{control_reg_stage} = "M";


    $Opt->{ci_combo_stage} = "E";


    $Opt->{ci_multi_stage} = "M";



    $Opt->{non_pipelined_long_latency_input_stage} = "E";



    $Opt->{long_latency_output_stage} = "M";



    $Opt->{le_fast_shift_rot_cycles} = 3;

    $Opt->{le_fast_shift_rot_shfcnt} = "(E_src2[4:0])";

    $Opt->{le_fast_shift_data} = "E_src1";


    $Opt->{mul_cell_pipelined} = "0";


    $Opt->{div_done} = "av_ld_or_div_done";


    $Opt->{data_master_interrupt_sz} = 32;
}








sub make_small_pipeline
{
    my ($Opt, $testbench_submodule) = @_;







    e_assign->adds(
      [["F_stall", 1], "D_stall"],



      [["F_en", 1], "~F_stall"],        
      );



    my $inject_crst = 
      $cpu_reset ? 
        (($debugger_present || $hbreak_test_bench) ? 
          "(cpu_resetrequest & hbreak_enabled)" : 
          "cpu_resetrequest") : 
        "1'b0";
        
    e_assign->adds(



      [["F_iw", $iw_sz], 
        "(latched_oci_tb_hbreak_req & hbreak_enabled) ? $empty_hbreak_iw :
         $inject_crst                                 ? $empty_crst_iw :
         intr_req                                     ? $empty_intr_iw : 
                                                        F_ram_iw"],
    );





    e_assign->adds(




      [["F_kill", 1], 
        "D_refetch | (D_br_pred_taken & D_valid) | M_pipe_flush"],
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
    );






    my @pipeline_wave_signals = (
        { divider => "base pipeline" },
        { radix => "x", signal => "clk" },
        { radix => "x", signal => "reset_n" },
        { radix => "x", signal => "M_stall" },
        { radix => "x", signal => "F_pcb_nxt" },
        { radix => "x", signal => "F_pcb" },
        { radix => "x", signal => "D_pcb" },
        { radix => "x", signal => "E_pcb" },
        { radix => "x", signal => "M_pcb" },
        { radix => "x", signal => "W_pcb" },
        { radix => "a", signal => "F_vinst" },
        { radix => "a", signal => "D_vinst" },
        { radix => "a", signal => "E_vinst" },
        { radix => "a", signal => "M_vinst" },
        { radix => "a", signal => "W_vinst" },
        { radix => "x", signal => "F_inst_ram_hit" },
        { radix => "x", signal => "F_iw_valid" },
        { radix => "x", signal => "F_issue" },
        { radix => "x", signal => "F_kill" },
        { radix => "x", signal => "D_kill" },
        { radix => "x", signal => "D_refetch" },
        { radix => "x", signal => "D_issue" },
        { radix => "x", signal => "D_valid" },
        { radix => "x", signal => "E_valid" },
        { radix => "x", signal => "M_valid" },
        { radix => "x", signal => "W_valid" },
        { radix => "x", signal => "W_wr_dst_reg" },
        { radix => "x", signal => "W_dst_regnum" },
        { radix => "x", signal => "W_wr_data" },
        { radix => "x", signal => "F_en" },
        { radix => "x", signal => "D_en" },
        { radix => "x", signal => "E_en" },
        { radix => "x", signal => "M_en" },
        { radix => "x", signal => "F_iw" },
        { radix => "x", signal => "D_iw" },
        { radix => "x", signal => "E_iw" },
        { radix => "x", signal => "E_valid_prior_to_hbreak" },
        { radix => "x", signal => "M_pipe_flush_nxt" },
        { radix => "x", signal => "M_pipe_flush_baddr_nxt" },
        { radix => "x", signal => "M_status_reg_pie" },
        { radix => "x", signal => "M_ienable_reg" },
        { radix => "x", signal => "intr_req" },
    );

    push(@plaintext_wave_signals, @pipeline_wave_signals);
}







sub make_inst_decode
{
    my $Opt = shift;





    my $gen_info = manditory_hash($Opt, "gen_info");




    cpu_inst_gen::gen_inst_fields($gen_info, $Opt->{inst_field_info},
      ["F", "F_ram", "D", "E", "M", "W"]);





    cpu_inst_gen::gen_inst_decodes($gen_info, $Opt->{inst_desc_info},
      ["F", "D", "E", "M", "W"]);




    cpu_inst_gen::create_sim_wave_inst_names($gen_info, $Opt->{inst_desc_info},
      ["F", "D", "E", "M", "W"]);




    cpu_inst_gen::create_sim_wave_vinst_names($gen_info, $Opt->{inst_desc_info},
      ["F", "D", "E", "M", "W"], $Opt->{inst_descs},
      { F => "F_iw_valid", D => "D_issue" });

    set_inst_ctrl_initial_stage($a_not_src_ctrl, "D");
    set_inst_ctrl_initial_stage($b_not_src_ctrl, "D");
    set_inst_ctrl_initial_stage($b_is_dst_ctrl, "D");
    set_inst_ctrl_initial_stage($ignore_dst_ctrl, "D");
    set_inst_ctrl_initial_stage($src2_choose_imm_ctrl, "D");

    set_inst_ctrl_initial_stage($br_ctrl, "D");
    set_inst_ctrl_initial_stage($br_uncond_ctrl, "D");
    set_inst_ctrl_initial_stage($br_cond_ctrl, "D");
    set_inst_ctrl_initial_stage($br_always_pred_taken_ctrl, "D");
    set_inst_ctrl_initial_stage($jmp_direct_ctrl, "D");
    set_inst_ctrl_initial_stage($jmp_indirect_ctrl, "D");

    set_inst_ctrl_initial_stage($exception_ctrl, "D");
    set_inst_ctrl_initial_stage($break_ctrl, "D");
    set_inst_ctrl_initial_stage($crst_ctrl, "D");
    set_inst_ctrl_initial_stage($invalidate_i_ctrl, "E");

    set_inst_ctrl_initial_stage($custom_combo_ctrl, "D");
    set_inst_ctrl_initial_stage($custom_multi_ctrl, "D");

    set_inst_ctrl_initial_stage($implicit_dst_retaddr_ctrl, "D");
    set_inst_ctrl_initial_stage($implicit_dst_eretaddr_ctrl, "D");
    set_inst_ctrl_initial_stage($hi_imm16_ctrl, "D");
    set_inst_ctrl_initial_stage($unsigned_lo_imm16_ctrl, "D");
    set_inst_ctrl_initial_stage($alu_signed_comparison_ctrl, "D");
    set_inst_ctrl_initial_stage($alu_subtract_ctrl, "D");
    set_inst_ctrl_initial_stage($cmp_ctrl, "D");
    set_inst_ctrl_initial_stage($logic_ctrl, "D");
    set_inst_ctrl_initial_stage($retaddr_ctrl, "D");
    set_inst_ctrl_initial_stage($wrctl_inst_ctrl, "D");
    set_inst_ctrl_initial_stage($rdctl_inst_ctrl, "D");

    set_inst_ctrl_initial_stage($ld_ctrl, "D");
    set_inst_ctrl_initial_stage($ld_signed_ctrl, "D");
    set_inst_ctrl_initial_stage($ld_io_ctrl, "D");
    set_inst_ctrl_initial_stage($ld_non_io_ctrl, "D");
    set_inst_ctrl_initial_stage($st_ctrl, "D");

    if ($hw_mul) {
        if ($hw_mul_uses_designware || $hw_mul_uses_les || 
          $hw_mul_uses_embedded_mults) {
            set_inst_ctrl_initial_stage($mul_lsw_ctrl, "D");
        } elsif ($hw_mul_uses_dsp_block) {
            set_inst_ctrl_initial_stage($mulx_ctrl, "D");
            set_inst_ctrl_initial_stage($mul_shift_rot_ctrl, "D");





            set_inst_ctrl_initial_stage($mul_shift_src1_signed_ctrl, "D");
            set_inst_ctrl_initial_stage($mul_shift_src2_signed_ctrl, "D");
        } else {
            &$error("make_inst_decode: unsupported multiplier implementation");
        }
    }

    if ($fast_shifter_uses_dsp_block) {
        set_inst_ctrl_initial_stage($rot_ctrl, "D");
        set_inst_ctrl_initial_stage($shift_rot_ctrl, "D");
        set_inst_ctrl_initial_stage($shift_rot_right_ctrl, "D");
        set_inst_ctrl_initial_stage($shift_right_ctrl, "D");
    } elsif ($fast_shifter_uses_les) {
        set_inst_ctrl_initial_stage($rot_ctrl, "D");
        set_inst_ctrl_initial_stage($shift_rot_ctrl, "D");
        set_inst_ctrl_initial_stage($shift_rot_right_ctrl, "D");
        set_inst_ctrl_initial_stage($shift_rot_left_ctrl, "D");
        set_inst_ctrl_initial_stage($shift_right_arith_ctrl, "D");
    } elsif ($small_shifter_uses_les) {
        set_inst_ctrl_initial_stage($shift_rot_ctrl, "D");
        set_inst_ctrl_initial_stage($rot_right_ctrl, "D");
        set_inst_ctrl_initial_stage($shift_logical_ctrl, "D");
        set_inst_ctrl_initial_stage($shift_rot_right_ctrl, "D");
        set_inst_ctrl_initial_stage($shift_right_arith_ctrl, "D");
    } else {
        &$error("make_inst_decode: unsupported shifter implementation");
    }

    if ($hw_div) {
        set_inst_ctrl_initial_stage($div_ctrl, "D");
        set_inst_ctrl_initial_stage($div_signed_ctrl, "D");
    }

    my $exception_allowed_modes = 
      manditory_array($Opt, "exception_inst_ctrl_allowed_modes");


    my $flush_pipe_always_ctrl = nios2_insts::additional_inst_ctrl($Opt, {
      name  => "flush_pipe_always",
      ctrls => ["flush_pipe", "wr_ctl_reg", "jmp_direct", "jmp_indirect"],
      allowed_modes => $exception_allowed_modes,
    });
    set_inst_ctrl_initial_stage($flush_pipe_always_ctrl, "D");
}






sub make_perf_cnt
{
    my ($Opt) = @_;


    my $perf_cnt_sz = $Opt->{performance_counters_width};






    e_register->adds(
      {out => "E_refetch",                      in => "D_refetch",
       enable => "E_en"},
      {out => "W_pipe_flush",                   in => "M_pipe_flush", 
       enable => "1'b1"},


      {out => ["perf_clr", 1], 
       in => "(E_wrctl_sim & E_valid) ? E_wrctl_data_sim_reg_perf_cnt_clr : 0",
       enable => "M_en", async_value => "1'b1" },
      );











    e_assign->adds(


      [["D_no_disp_pipe_flush", 1], 
        "M_pipe_flush | W_pipe_flush"],


      [["D_no_disp_branch_penalty", 1], 
        "D_kill & ~E_refetch & ~D_no_disp_pipe_flush"],
    );

    if ($icache_present) {
        e_assign->adds(

          [["D_no_disp_icache_miss", 1], "D_ic_want_fill | E_refetch"],
        );
    }








    e_assign->adds(

      [["perf_cycles_nxt", $perf_cnt_sz], "perf_cycles + 1"],


      [["perf_dispatched_nxt", $perf_cnt_sz], 
        "(D_valid & E_en) ? perf_dispatched + 1 : perf_dispatched"],


      [["perf_retired_nxt", $perf_cnt_sz], 
        "(M_valid & M_en) ? perf_retired + 1 : perf_retired"],


      [["perf_M_ld_stall_nxt", $perf_cnt_sz], 
        "(M_ld_stall) ? perf_M_ld_stall + 1 : perf_M_ld_stall"],


      [["perf_M_st_stall_nxt", $perf_cnt_sz], 
        "(M_st_stall) ? perf_M_st_stall + 1 : perf_M_st_stall"],



      [["perf_no_disp_pipe_flush_nxt", $perf_cnt_sz], 
        "(D_no_disp_pipe_flush & ~E_stall) ? 
           perf_no_disp_pipe_flush + 1 : perf_no_disp_pipe_flush"],



      [["perf_no_disp_branch_penalty_nxt", $perf_cnt_sz], 
        "(D_no_disp_branch_penalty & ~E_stall) ? 
           perf_no_disp_branch_penalty + 1 : perf_no_disp_branch_penalty"],



      [["perf_br_pred_bad_nxt", $perf_cnt_sz], 
        "(M_br_mispredict & ~M_stall) ? 
           perf_br_pred_bad + 1 : perf_br_pred_bad"],



      [["perf_br_pred_good_nxt", $perf_cnt_sz], 
        "(M_ctrl_br_cond & ~M_br_mispredict & ~M_stall) ? 
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

    e_assign->adds(
      [["perf_en", 1], "M_sim_reg_perf_cnt_en"],
    );   

    e_register->adds(
      {out => ["perf_cycles", $perf_cnt_sz], 
       in => "perf_clr ? 0 : perf_cycles_nxt", enable => "perf_en"},
      {out => ["perf_dispatched", $perf_cnt_sz], 
       in => "perf_clr ? 0 : perf_dispatched_nxt", enable => "perf_en"},
      {out => ["perf_retired", $perf_cnt_sz], 
       in => "perf_clr ? 0 : perf_retired_nxt", enable => "perf_en"},
      {out => ["perf_M_ld_stall", $perf_cnt_sz], 
       in => "perf_clr ? 0 : perf_M_ld_stall_nxt", enable => "perf_en"},
      {out => ["perf_M_st_stall", $perf_cnt_sz], 
       in => "perf_clr ? 0 : perf_M_st_stall_nxt", enable => "perf_en"},
      {out => ["perf_no_disp_pipe_flush", $perf_cnt_sz], 
       in => "perf_clr ? 0 : perf_no_disp_pipe_flush_nxt", 
       enable => "perf_en"},
      {out => ["perf_no_disp_branch_penalty", $perf_cnt_sz], 
       in => "perf_clr ? 0 : perf_no_disp_branch_penalty_nxt", 
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
        { radix => "a", signal => "W_vinst" },
        { radix => "x", signal => "F_iw_valid" },
        { radix => "x", signal => "F_issue" },
        { radix => "x", signal => "F_kill" },
        { radix => "x", signal => "D_kill" },
        { radix => "x", signal => "D_refetch" },
        { radix => "x", signal => "D_iw_valid" },
        { radix => "x", signal => "D_issue" },
    );

    if ($icache_present) {
        push(@perf_counters,
          { radix => "x", signal => "D_ic_want_fill" },
          { radix => "x", signal => "E_refetch" },
        );
    }

    push(@perf_counters,
        { radix => "d", signal => "perf_cycles" },
        { radix => "d", signal => "perf_dispatched" },
        { radix => "d", signal => "perf_retired" },
        { radix => "d", signal => "perf_M_ld_stall" },
        { radix => "d", signal => "perf_M_st_stall" },
        { radix => "d", signal => "perf_no_disp_pipe_flush" },
        { radix => "d", signal => "perf_no_disp_branch_penalty" },
    );

    if ($icache_present) {
        push(@perf_counters,
          { radix => "d", signal => "perf_no_disp_icache_miss" },
        );
    }

    push(@perf_counters,
        { radix => "d", signal => "perf_br_pred_bad" },
        { radix => "d", signal => "perf_br_pred_good" },
    );

    if ($perf_cnt_present) {
        push(@plaintext_wave_signals, @perf_counters);
    }
}

1;
