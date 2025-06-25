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






















package nevada_fast;

use cpu_utils;
use cpu_wave_signals;
use cpu_gen;
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
use nevada_control_regs;
use nevada_insts;
use nevada_isa;
use nevada_exceptions;
use nevada_common;
use nevada_mmu;
use nevada_testbench;
use nevada_frontend_150;
use nevada_backend_500;
use nevada_backend_control_regs;
use nevada_mul;

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

    set_pipeline_description($Opt);
    be_set_control_reg_pipeline_desc($Opt);

    my $testbench_submodule = nevada_make_testbench($Opt);
    e_signal->adds({name => "test_ending", never_export => 1, width => 1});
    e_signal->adds({name => "test_has_ended", never_export => 1, width => 1});

    make_inst_decode($Opt);

    make_fast_pipeline($Opt, $testbench_submodule);

    nevada_fe150_make_frontend($Opt);
    nevada_be500_make_backend($Opt);

    if ($mmu_present && $tlb_present) {
        my $mmu_wave_signals_array = nevada_mmu::make_tlb($Opt);

        if ($Opt->{full_waveform_signals}) {
            foreach my $mmu_wave_signals (@$mmu_wave_signals_array) {
                push(@plaintext_wave_signals, @$mmu_wave_signals);
            }
        }
    }



    be_make_control_regs($Opt);
}



sub 
make_exc
{
    my $Opt = shift;

    my $whoami = "make_exc";

    my $exc_stages = manditory_array($Opt, "exc_stages");
    my $wss = not_empty_scalar($Opt, "wrctl_setup_stage");


    gen_exception_signals(manditory_hash($Opt, "gen_info"), $exc_stages);


    my @exc_stages_array = @$exc_stages;
    my $last_stage = $exc_stages_array[$#exc_stages_array];

    if ($wss ne $last_stage) {
        &$error("wrctl_setup_stage must be same as last exc_stages");
    }




    my $cause_mux_table = gen_exception_cause_code($wss);
    my $cause_code_signal = "${wss}_exc_highest_pri_cause_code";

    if (scalar(@$cause_mux_table)) {

        e_mux->add ({
          lhs => [$cause_code_signal, $cop0_cause_reg_exc_code_sz],
          type => "priority",
          table => $cause_mux_table,
        });
    } else {

        e_assign->adds(
          [[$cause_code_signal, $cop0_cause_reg_exc_code_sz], "0"],
        );
    }





    my $exc_id_mux_table = gen_exception_id($wss);
    my $exc_id_signal = "${wss}_exc_highest_pri_id";


    e_mux->add ({
      lhs => [$exc_id_signal, 32],
      type => "priority",
      table => $exc_id_mux_table,
    });




    my ($baddr_mux_table, $baddr_record_signals) = gen_exception_baddr($wss);

    my $baddr_addr_signal = "${wss}_exc_highest_pri_baddr";
    my $baddr_record_signal = "${wss}_exc_record_baddr";

    if (scalar(@$baddr_mux_table)) {

        e_mux->add ({
          lhs => [$baddr_addr_signal, $cop0_bad_vaddr_reg_sz],
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
          [[$baddr_addr_signal, $cop0_bad_vaddr_reg_sz], "0"],
          [[$baddr_record_signal, 1], "0"],
        );
    }

    if ($Opt->{full_waveform_signals}) {
        push(@plaintext_wave_signals,
          { radix => "d", signal => $cause_code_signal },
          { radix => "d", signal => $exc_id_signal },
          { radix => "x", signal => $baddr_addr_signal },
          { radix => "x", signal => $baddr_record_signal },
        );
    }
}







sub 
set_pipeline_description
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
  

    e_assign->adds(
      [["sync_wait_dc_wr_nxt", 1],
        "sync_wait_dc_wr ? A_dc_wb_wr_active_nxt : (A_op_sync & A_valid & A_dc_wb_wr_active_nxt)"],
      );
    e_register->adds(
      {out => ["sync_wait_dc_wr", 1],  in => "sync_wait_dc_wr_nxt",
       enable => "1"},
    );



    my $ic_want_fill_expr =
      "~D_iw_valid & ~D_kill & ~M_pipe_flush & ~D_ic_bypass_req" .
      " & ~(A_ctrl_ic_tag_rd  & A_valid) & ~sync_wait_dc_wr_nxt";


    my $ic_want_bypass_expr =
      "~D_iw_valid & ~D_kill & ~M_pipe_flush & D_ic_bypass_req";
      
    if ($mmu_present) {
        if ($tlb_present) {

            $Opt->{uitlb_match_mux_vaddr} = "F_pcb";
            $Opt->{udtlb_match_mux_vaddr} = "M_mem_baddr";
    



            $Opt->{uitlb_match_mux_paddr} = "F_pcb_phy";
            $Opt->{udtlb_match_mux_paddr} = "M_mem_baddr_phy";


            $Opt->{uitlb_want_fill} = "D_uitlb_want_fill";
            $Opt->{udtlb_want_fill} = "A_udtlb_want_fill";
    




            $Opt->{uitlb_want_fill_expr} = 
              "(~D_pcb_phy_got_pfn & ~D_kill & ~M_pipe_flush)";
    






            $Opt->{udtlb_want_fill_expr} = 
              "(~A_mem_baddr_phy_got_pfn & A_ctrl_mem_data_access & 
                A_pipe_flush & ~A_exc_any_active)";
    

            $ic_want_fill_expr .= " & D_pcb_phy_pfn_valid";
            $ic_want_bypass_expr .= " & D_pcb_phy_pfn_valid";
        } else {

            $Opt->{ifmt_stage} = "F";
            $Opt->{dfmt_stage} = "M";
    

            $Opt->{ifmt_vaddr} = "F_pcb";
            $Opt->{dfmt_vaddr} = "M_mem_baddr";
    

            $Opt->{ifmt_paddr} = "F_pcb_phy";
            $Opt->{dfmt_paddr} = "M_mem_baddr_phy";
        }
    }
    
    $Opt->{D_ic_want_fill} = $ic_want_fill_expr;
    $Opt->{D_ic_want_bypass} = $ic_want_bypass_expr;


    if ($dsp_block_has_pipeline_reg) {
       $Opt->{lo_accum_s} = "W";
       $Opt->{hi_accum_s} = "W1";
       $Opt->{hi_s} = "W2";
       $Opt->{lo_s} = "W1";
       $Opt->{extins_s} = "A";
    } elsif ($hw_mul_uses_embedded_mults) {
       $Opt->{lo_accum_s} = "W";
       $Opt->{hi_accum_s} = "W1";
       $Opt->{hi_s} = "W2";
       $Opt->{lo_s} = "W1";
       $Opt->{extins_s} = "M";
    } else {
       $Opt->{lo_accum_s} = "A";
       $Opt->{hi_accum_s} = "W";
       $Opt->{hi_s} = "W1";
       $Opt->{lo_s} = "W";
       $Opt->{extins_s} = "M";
    }


    $Opt->{cache_operation} = 
      " (
         (
          (A_ctrl_ic_tag_rd ) & 
          A_valid & ~A_en) | 
          A_exc_soft_reset_active 
        )";


    $Opt->{cache_operation_baddr} = "A_mem_baddr_phy";


    $Opt->{inst_crst} = "0";


    $Opt->{inst_soft_reset_next_stage} = "W_exc_soft_reset_active";


    $Opt->{soft_reset_taken} = "A_exc_soft_reset_active";


    $Opt->{bht_wr_data} = "M_bht_wr_data_filtered";
    $Opt->{bht_wr_en} = "M_bht_wr_en_filtered";
    $Opt->{bht_wr_addr} = "M_bht_ptr_filtered";
    $Opt->{bht_br_cond_taken_history} = "M_br_cond_taken_history";


    $Opt->{rf_a_field_name} = "rs";


    $Opt->{rf_b_field_name} = "rt";


    $Opt->{add_br_to_taken_history} = "E_add_br_to_taken_history_filtered";



    $Opt->{brpred_prediction_stage} = "D";


    $Opt->{brpred_resolution_stage} = "E";


    $Opt->{brpred_mispredict_stage} = "M";
     

    $Opt->{brpred_mispredict_reset} = "1";


    $Opt->{rdctl_stage} = "M";



    $Opt->{wrctl_setup_stage} = "A";


    $Opt->{wrctl_data} = "A_src2";


    $Opt->{control_reg_stage} = "W";


    $Opt->{divider_input_stage} = "M";



    $Opt->{non_pipelined_long_latency_input_stage} = "M";



    $Opt->{long_latency_output_stage} = "A";


    $Opt->{le_fast_shift_rot_cycles} = 2;

    $Opt->{le_fast_shift_rot_shfcnt} = "(E_ctrl_shift_rot_imm ? E_iw_sa : E_src1[4:0])";


    e_signal->adds({name => "E_shift_data", never_export => 1, width => 32});
    e_assign->adds(
      [["E_shift_data",32],
        "E_ctrl_extins ? E_src1 : E_src2"],
    );
    $Opt->{le_fast_shift_data} = "E_shift_data";


    $Opt->{mul_cell_pipelined} = "1";


    $Opt->{div_done} = "A_div_done";


    $Opt->{data_master_interrupt_sz} = $interrupt_sz;

    if ($tlb_present) {
        $Opt->{mmu_addr_pfn_lsb} = $mmu_addr_pfn_lsb;
    }
}








sub 
make_fast_pipeline
{
    my $Opt = shift;
    my $testbench_submodule = shift;

    my $whoami = "fast_pipeline";

    my $cs = not_empty_scalar($Opt, "control_reg_stage");







    e_assign->adds(
      [["F_stall", 1], "D_stall"],



      [["F_en", 1], "~F_stall"],        

      [["F_iw", $iw_sz], "F_ram_iw"],
    );





    e_assign->adds(













      [["F_kill", 1], "D_refetch | M_pipe_flush"],
    );
      




    my $partial_br_offset_sz = ($pc_sz < 10) ? $pc_sz : 10;

    e_assign->adds(


      [["F_br_taken_waddr_partial", $partial_br_offset_sz+1],
        "F_pc_plus_one[$partial_br_offset_sz-1:0] + 
         F_iw_imm16[$partial_br_offset_sz-1:0]"],
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













    e_register->adds(
      {out => ["D_inst_after_refetch", 1],  in => "D_refetch & ~M_pipe_flush",  
       enable => "D_en"},
    );





    my $remaining_br_offset_sz = $pc_sz - $partial_br_offset_sz;

    if ($remaining_br_offset_sz > 0) {
        e_assign->adds(

          [["D_br_offset_sex", 32-$partial_br_offset_sz], 
            "{{16 {D_iw_imm16[15]}}, D_iw_imm16[15:$partial_br_offset_sz]}"],


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


    cpu_pipeline_signal(manditory_hash($Opt, "gen_info"), {
       name => "D_br_taken_baddr",
       sz => $pcb_sz,
       rhs => "{D_br_taken_waddr, 2'b00}",
       never_export => 1,
    });






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
        { radix => "x", signal => "D_data_depend" },
        { radix => "x", signal => "D_issue_jmp_indirect" },
        { radix => "x", signal => "D_issue_ehb" },
        { radix => "x", signal => "D_extra_stall" },
        { radix => "x", signal => "D_extra_stall_done" },
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
        { radix => "x", signal => "M_br_mispredict" },
        { radix => "x", signal => "M_br_mispredict_pcb" },
        { radix => "x", signal => "M_br_mispredict_fetch_taken_target" },
        { radix => "x", signal => "M_intr_req" },
        { radix => "x", signal => "A_ctrl_has_delay_slot" },
        { radix => "x", signal => "A_annul_delay_slot" },
        { radix => "x", signal => "A_is_delay_slot" },
        { radix => "x", signal => "A_previous_pcb" },
        { radix => "x", signal => "A_pipe_flush" },
        { radix => "x", signal => "A_pipe_fetch" },
        { radix => "x", signal => "A_pipe_fetch_pcb" },
        { radix => "x", signal => "W_debug_mode" },
        { radix => "x", signal => "W_kernel_mode" },
        { radix => "x", signal => "W_user_mode" },
        { radix => "x", signal => "W_normal_mode" },
        { radix => "x", signal => "W_ejtagboot_active" },
        @{get_control_regs_for_waves($Opt->{control_regs})},
    );

    push(@plaintext_wave_signals, @pipeline_wave_signals);
}







sub 
make_inst_decode
{
    my $Opt = shift;

    &$progress("    Instruction decoding");





    my $gen_info = manditory_hash($Opt, "gen_info");




    &$progress("      Instruction fields");
    cpu_inst_gen::gen_inst_fields($gen_info, $Opt->{inst_field_info},
      ["F", "F_ram", "D", "E", "M", "A", "W"]);





    &$progress("      Instruction decodes");
    cpu_inst_gen::gen_inst_decodes($gen_info, $Opt->{inst_desc_info},
      ["F", "D", "E", "M", "A", "W"],       # All stages
      ["E", "M", "A", "W"],      # Register stages for <stage>_op_<inst>
      ["D", "E", "M", "A", "W"], # Register stages for extra signals
      ["F", "D"],                # Stages for reserved instructions
      );




    &$progress("      Signals for RTL simulation waveforms");
    cpu_inst_gen::create_sim_wave_inst_names($gen_info, $Opt->{inst_desc_info},
      ["F", "D", "E", "M", "A", "W"]);




    cpu_inst_gen::create_sim_wave_vinst_names($gen_info, $Opt->{inst_desc_info},
      ["F", "D", "E", "M", "A", "W"],
      {},       # Default inst signal names
      { F => "F_iw_valid", D => "D_issue" });

    &$progress("      Instruction controls");

    my $late_result_ctrl_names = ["ld","shift_rot","rdctl_inst"];




    if ($hw_mul_uses_dsp_block) {
        set_inst_ctrl_initial_stage($mulx_ctrl, "D");
        set_inst_ctrl_initial_stage($mul_shift_rot_ctrl, "M");
        set_inst_ctrl_initial_stage($mult_accum_ctrl, "M");
        set_inst_ctrl_initial_stage($mult_inst_ctrl, "M");





        set_inst_ctrl_initial_stage($mul_shift_src1_signed_ctrl, "D");
        set_inst_ctrl_initial_stage($mul_shift_src2_signed_ctrl, "D");

        push(@$late_result_ctrl_names, "mul_lsw");
    } elsif ($hw_mul_uses_embedded_mults) {
        set_inst_ctrl_initial_stage($mulx_ctrl, "D");
        set_inst_ctrl_initial_stage($mul_shift_rot_ctrl, "M");
        set_inst_ctrl_initial_stage($mult_accum_ctrl, "M");
        set_inst_ctrl_initial_stage($mult_inst_ctrl, "M");





        set_inst_ctrl_initial_stage($mul_shift_src1_signed_ctrl, "D");
        set_inst_ctrl_initial_stage($mul_shift_src2_signed_ctrl, "D");

        push(@$late_result_ctrl_names, "mul_lsw");
    } else {
        &$error("Unsupported multiplier implementation");
    }




    set_inst_ctrl_initial_stage($hilo_inst_ctrl, "D");
    set_inst_ctrl_initial_stage($mfhilo_inst_ctrl, "D");
    set_inst_ctrl_initial_stage($mthilo_inst_ctrl, "D");
    set_inst_ctrl_initial_stage($rd_hi_ctrl, "D");
    set_inst_ctrl_initial_stage($rd_lo_ctrl, "D");
    set_inst_ctrl_initial_stage($wrt_hi_ctrl, "D");
    set_inst_ctrl_initial_stage($wrt_lo_ctrl, "D");
    set_inst_ctrl_initial_stage($wrt_hilo_ctrl, "D");
    set_inst_ctrl_initial_stage($rd_hilo_ctrl, "D");
    push(@$late_result_ctrl_names, "mfhilo_inst");




    set_inst_ctrl_initial_stage($bit_ctrl, "D");
    set_inst_ctrl_initial_stage($movzn_ctrl, "D");
    set_inst_ctrl_initial_stage($clzclo_ctrl, "D");
    push(@$late_result_ctrl_names, "bit","sc");




    set_inst_ctrl_initial_stage($div_ctrl, "D");
    set_inst_ctrl_initial_stage($div_signed_ctrl, "D");




    if ($fast_shifter_uses_dsp_block) {
        set_inst_ctrl_initial_stage($shift_right_ctrl, "D");
        set_inst_ctrl_initial_stage($shift_rot_right_ctrl, "D");
        set_inst_ctrl_initial_stage($shift_rot_imm_ctrl, "D");
        set_inst_ctrl_initial_stage($shift_rot_ctrl, "D");
        set_inst_ctrl_initial_stage($rot_ctrl, "D");
        set_inst_ctrl_initial_stage($extins_ctrl, "D");
    } elsif ($fast_shifter_uses_les || $fast_shifter_uses_designware) {
        set_inst_ctrl_initial_stage($shift_rot_imm_ctrl, "D");
        set_inst_ctrl_initial_stage($shift_right_arith_ctrl, "D");
        set_inst_ctrl_initial_stage($shift_rot_ctrl, "D");
        set_inst_ctrl_initial_stage($shift_rot_left_ctrl, "D");
        set_inst_ctrl_initial_stage($shift_rot_right_ctrl, "D");
        set_inst_ctrl_initial_stage($rot_ctrl, "D");
        set_inst_ctrl_initial_stage($extins_ctrl, "D");
    } elsif ($small_shifter_uses_les) {
        set_inst_ctrl_initial_stage($shift_right_arith_ctrl, "M");
        set_inst_ctrl_initial_stage($shift_logical_ctrl, "M");
        set_inst_ctrl_initial_stage($rot_right_ctrl, "M");
        set_inst_ctrl_initial_stage($shift_rot_right_ctrl, "M");
        set_inst_ctrl_initial_stage($shift_rot_ctrl, "M");
        set_inst_ctrl_initial_stage($extins_ctrl, "M");
    } else {
        &$error("Unsupported shifter implementation");
    }




    set_inst_ctrl_initial_stage($logic_ctrl, "D");
    set_inst_ctrl_initial_stage($alu_signed_comparison_ctrl, "D");
    set_inst_ctrl_initial_stage($alu_add_operation_ctrl, "D");
    set_inst_ctrl_initial_stage($alu_and_operation_ctrl, "D");
    set_inst_ctrl_initial_stage($alu_or_operation_ctrl, "D");
    set_inst_ctrl_initial_stage($alu_nor_operation_ctrl, "D");




    set_inst_ctrl_initial_stage($cmp_ctrl, "D");




    set_inst_ctrl_initial_stage($br_src1_eq_src2_ctrl, "D");
    set_inst_ctrl_initial_stage($br_src1_ne_src2_ctrl, "D");
    set_inst_ctrl_initial_stage($br_src1_lt_zero_ctrl, "D");
    set_inst_ctrl_initial_stage($br_src1_le_zero_ctrl, "D");
    set_inst_ctrl_initial_stage($br_src1_gt_zero_ctrl, "D");
    set_inst_ctrl_initial_stage($br_src1_ge_zero_ctrl, "D");
    set_inst_ctrl_initial_stage($br_likely_ctrl, "D");
    set_inst_ctrl_initial_stage($br_always_pred_taken_ctrl, "D");
    set_inst_ctrl_initial_stage($br_uncond_op_table_ctrl, "D");
    set_inst_ctrl_initial_stage($br_uncond_regimm_table_ctrl, "D");
    set_inst_ctrl_initial_stage($br_uncond_ctrl, "D");
    set_inst_ctrl_initial_stage($br_cond_ctrl, "D");
    set_inst_ctrl_initial_stage($br_op_table_ctrl, "F");
    set_inst_ctrl_initial_stage($br_regimm_table_ctrl, "D");
    set_inst_ctrl_initial_stage($br_ctrl, "D");
    set_inst_ctrl_initial_stage($has_delay_slot_ctrl, "D");  # Includes br/jmp




    set_inst_ctrl_initial_stage($jmp_indirect_ctrl, "F");
    set_inst_ctrl_initial_stage($jmp_direct_ctrl, "F");
    set_inst_ctrl_initial_stage($jmp_ctrl, "F");




    set_inst_ctrl_initial_stage($ld8_ctrl, "E");
    set_inst_ctrl_initial_stage($ld16_ctrl, "E");
    set_inst_ctrl_initial_stage($ld8_ld16_ctrl, "E");
    set_inst_ctrl_initial_stage($ld32_ctrl, "E");
    set_inst_ctrl_initial_stage($lwlr_ctrl, "E");
    set_inst_ctrl_initial_stage($swlr_ctrl, "E");
    set_inst_ctrl_initial_stage($ld_signed_ctrl, "E");
    set_inst_ctrl_initial_stage($ld_ctrl, "E");




    set_inst_ctrl_initial_stage($st8_ctrl, "E");
    set_inst_ctrl_initial_stage($st16_ctrl, "E");
    set_inst_ctrl_initial_stage($st32_ctrl, "E");
    set_inst_ctrl_initial_stage($st_ctrl, "E");
    set_inst_ctrl_initial_stage($sc_ctrl, "E");




    set_inst_ctrl_initial_stage($ld_st_ctrl, "E");
    set_inst_ctrl_initial_stage($ld_st_non_st32_ctrl, "E");
    set_inst_ctrl_initial_stage($mem8_ctrl, "D");
    set_inst_ctrl_initial_stage($mem16_ctrl, "D");
    set_inst_ctrl_initial_stage($mem32_ctrl, "D");
    set_inst_ctrl_initial_stage($mem_ctrl, "E");
    set_inst_ctrl_initial_stage($ld_addr_ctrl, "E");
    set_inst_ctrl_initial_stage($ld_data_access_ctrl, "E");
    set_inst_ctrl_initial_stage($st_data_access_ctrl, "E");
    set_inst_ctrl_initial_stage($mem_data_access_ctrl, "E");




    set_inst_ctrl_initial_stage($dcache_management_ctrl, "E");
    set_inst_ctrl_initial_stage($cache_management_ctrl, "E");
    set_inst_ctrl_initial_stage($dc_index_wb_inv_ctrl, "E");
    set_inst_ctrl_initial_stage($dc_index_store_tag_ctrl, "E");
    set_inst_ctrl_initial_stage($dc_addr_nowb_inv_ctrl, "E");
    set_inst_ctrl_initial_stage($dc_addr_wb_inv_ctrl, "E");
    set_inst_ctrl_initial_stage($dc_index_nowb_inv_ctrl, "E");
    set_inst_ctrl_initial_stage($dc_index_inv_ctrl, "E");
    set_inst_ctrl_initial_stage($dc_addr_inv_ctrl, "E");
    set_inst_ctrl_initial_stage($dc_nowb_inv_ctrl, "E");




    set_inst_ctrl_initial_stage($ic_index_inv_ctrl, "E");
    set_inst_ctrl_initial_stage($ic_addr_inv_ctrl, "E");
    set_inst_ctrl_initial_stage($ic_hit_inv_ctrl, "E");
    set_inst_ctrl_initial_stage($ic_tag_wdata_ctrl, "E");
    set_inst_ctrl_initial_stage($ic_tag_wr_ctrl, "E");
    set_inst_ctrl_initial_stage($ic_tag_rd_ctrl, "E");
    set_inst_ctrl_initial_stage($ic_only_read_tag_ctrl, "E");




    set_inst_ctrl_initial_stage($trap_src1_eq_src2_ctrl, "D");
    set_inst_ctrl_initial_stage($trap_src1_ne_src2_ctrl, "D");
    set_inst_ctrl_initial_stage($trap_src1_lt_src2_ctrl, "D");
    set_inst_ctrl_initial_stage($trap_src1_ge_src2_ctrl, "D");
    set_inst_ctrl_initial_stage($trap_ctrl, "D");




    set_inst_ctrl_initial_stage($hi_imm16_ctrl, "D");
    set_inst_ctrl_initial_stage($unsigned_lo_imm16_ctrl, "D");
    set_inst_ctrl_initial_stage($rs_not_src_ctrl, "F");
    set_inst_ctrl_initial_stage($rt_is_src_or_slow_dst_ctrl, "F");
    set_inst_ctrl_initial_stage($src2_choose_imm16_ctrl, "D");




    set_inst_ctrl_initial_stage($sel_rd_for_dst_ctrl, "D");
    set_inst_ctrl_initial_stage($implicit_dst_retaddr_ctrl, "D");
    set_inst_ctrl_initial_stage($ignore_dst_ctrl, "D");




    set_inst_ctrl_initial_stage($wrctl_inst_ctrl, "E");
    set_inst_ctrl_initial_stage($rdctl_inst_ctrl, "E");

    if ($tlb_present) {



        set_inst_ctrl_initial_stage($tlb_wr_inst_ctrl, "E");
        set_inst_ctrl_initial_stage($tlb_inst_ctrl, "E");
    }




    set_inst_ctrl_initial_stage($reserved_ctrl, "D");
    set_inst_ctrl_initial_stage($cop0_ctrl, "D");
    set_inst_ctrl_initial_stage($cop1_or_cop1x_ctrl, "D");
    set_inst_ctrl_initial_stage($cop2_ctrl, "D");
    set_inst_ctrl_initial_stage($flush_pipe_ctrl, "D");
    set_inst_ctrl_initial_stage($retaddr_ctrl, "D");
    set_inst_ctrl_initial_stage($ehb_inst_ctrl, "D");





    my $late_result_ctrl = nevada_insts::additional_inst_ctrl($Opt, {
      name  => "late_result",
      insts => ["rdhwr"],
      ctrls => $late_result_ctrl_names,
      allowed_modes => manditory_array($Opt, "default_inst_ctrl_allowed_modes"),
    });
    set_inst_ctrl_initial_stage($late_result_ctrl, "D");
}

1;
