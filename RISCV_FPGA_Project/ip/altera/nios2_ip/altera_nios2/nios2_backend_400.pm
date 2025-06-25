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






















package nios2_backend_400;
use Exporter;
@ISA = Exporter;
@EXPORT = qw(
    &nios2_be400_make_backend
    &nios2_be400_make_testbench
);

use e_custom_instruction_master;
use cpu_utils;
use cpu_wave_signals;
use cpu_file_utils;
use cpu_inst_gen;
use europa_all;
use europa_utils;
use nios_utils;
use nios_europa;
use nios_testbench_utils;
use nios_sdp_ram;
use nios_avalon_masters;
use nios_brpred;
use nios_common;
use nios_isa;
use nios_div;
use nios_shift_rotate;
use nios2_isa;
use nios2_insts;
use nios2_common;
use nios2_backend;
use nios2_backend_control_regs;
use nios2_mul;
use nios2_custom_insts;

use strict;























sub 
nios2_be400_make_backend
{
    my $Opt = shift;



    nios_brpred::gen_backend($Opt);

    make_base_pipeline($Opt);

    if (nios2_custom_insts::has_insts($Opt->{custom_instructions})) {
        make_custom_instruction_master($Opt);
    } else {
        my $is_hw_tcl_core = optional_bool($Opt, "hw_tcl_core");
        if ( $is_hw_tcl_core ) {
           
            my $ci_ports = { no_ci_readra      => "combo_readra", };
            e_custom_instruction_master->add ({
                name     => "custom_instruction_master",
                type_map => $ci_ports,
            });
            
            e_assign->adds([["no_ci_readra", 1], "1'b0"]);
        }
    }

    make_fetch_npc($Opt);
    make_register_file($Opt);
    make_reg_cmp($Opt);
    make_src_operands($Opt);
    make_alu_controls($Opt);
    be_make_alu($Opt);
    be_make_stdata($Opt);
    be_make_control_regs($Opt);
    be_make_hbreak($Opt);
    if ($cpu_reset) {
        be_make_cpu_reset($Opt);
    }
    make_interrupts($Opt);

    make_data_master($Opt);
    make_data_master_ld_aligner($Opt);

    if ($hw_mul) {
        nios2_mul::gen_mul($Opt);
    }

    if ($hw_div) {
        nios_div::gen_div($Opt);
    }

    nios_shift_rotate::gen_shift_rotate($Opt);

    if (!manditory_bool($Opt, "simgen")) {
        make_potential_tb_logic($Opt);
    }
}







sub 
nios2_be400_make_testbench
{
    my $Opt = shift;

    my $submodule_name = $Opt->{name}."_test_bench";

    my $submodule = e_module->new({
      name        => $submodule_name,
      output_file => $submodule_name,
    });

    my $testbench_instance_name = "the_$submodule_name";
    my $testbench_instance = e_instance->add({
      module      => $submodule,
      name        => $testbench_instance_name,
    });

    my $marker = e_default_module_marker->new($submodule);

    my $gen_info = manditory_hash($Opt, "gen_info");





    cpu_inst_gen::gen_inst_decodes($gen_info, $Opt->{inst_desc_info},
      ["W"]);





    e_signal->adds(

      {name => "M_target_pcb", never_export => 1, width => $pcb_sz},
    );

    e_register->adds(
      {out => "M_target_pcb", in => "E_src1[$pcb_sz-1:0]", enable => "M_en"},
    );








    if (manditory_bool($Opt, "simgen")) {
        make_potential_tb_logic($Opt);
    }

    my @x_signals = (
      { sig => "W_wr_dst_reg",                             },
      { sig => "W_dst_regnum", qual => "W_wr_dst_reg",     },
      { sig => "W_wr_data",    qual => "W_wr_dst_reg",     },
      { sig => "W_valid",                                  },
      { sig => "W_pcb",        qual => "W_valid",          },
      { sig => "W_iw",         qual => "W_valid",          },
      { sig => "M_en",                                     },
      { sig => "E_valid",                                  },
      { sig => "M_valid",                                  },
      { sig => "M_wr_data_unfiltered",    
        qual => "M_valid & M_en & M_wr_dst_reg",
        warn => 1,                                         },
    );

    if ($instruction_master_present) {
        push(@x_signals,
          { sig => "i_read",                                   },
          { sig => "i_address",    qual => "i_read",           },
          { sig => "i_readdatavalid",                          },
        );
    }

    if ($data_master_present) {
        push(@x_signals,
          { sig => "d_write",                                   },
          { sig => "d_byteenable", qual => "d_write",           },
          { sig => "d_address",    qual => "d_write | d_read",  },
          { sig => "d_read",                                    },
        );
    }

    e_signal->adds(

      {name => "M_target_pcb", width => $pc_sz+2},



      {name => "M_wr_data_filtered", width => $datapath_sz, 
       export => $force_export},
    );

    if ($Opt->{clear_x_bits_ld_non_bypass}) {





        create_x_filter({
          rhs       => "M_wr_data_unfiltered",
          lhs       => "M_wr_data_filtered",
          sz        => $datapath_sz, 
          qual_expr => "M_ctrl_ld_non_io",
        });
    } else {

        e_assign->adds({
          comment => "Propagating 'X' data bits",
          lhs => "M_wr_data_filtered",
          rhs => "M_wr_data_unfiltered",
        });
    }

    if ($Opt->{branch_prediction_type} eq "Dynamic") {
        if (!$Opt->{bht_index_pc_only}) {
            e_signal->adds(


                {name => "E_add_br_to_taken_history_filtered", width => 1, 
                 export => $force_export},
            );
        }

        e_signal->adds(


            {name => "M_bht_wr_en_filtered", width => 1, 
             export => $force_export},
            {name => "M_bht_wr_data_filtered", width => $bht_data_sz, 
             export => $force_export},
            {name => "M_bht_ptr_filtered", width => $bht_ptr_sz, 
             export => $force_export},
        );


        if (!$Opt->{bht_index_pc_only}) {
            e_assign->adds({
              comment => "Propagating 'X' data bits",
              lhs => "E_add_br_to_taken_history_filtered",
              rhs => "E_add_br_to_taken_history_unfiltered",
            });
        }
        e_assign->adds({
          comment => "Propagating 'X' data bits",
          lhs => "M_bht_wr_en_filtered",
          rhs => "M_bht_wr_en_unfiltered",
        });
        e_assign->adds({
          comment => "Propagating 'X' data bits",
          lhs => "M_bht_wr_data_filtered",
          rhs => "M_bht_wr_data_unfiltered",
            });
        e_assign->adds({
          comment => "Propagating 'X' data bits",
          lhs => "M_bht_ptr_filtered",
          rhs => "M_bht_ptr_unfiltered",
        });
    }

    my $display = $NIOS_DISPLAY_INST_TRACE | $NIOS_DISPLAY_MEM_TRAFFIC;
    my $use_reg_names = "1";

    my $test_end_expr;

    if ($Opt->{activate_monitors} eq "1") {
        create_x_checkers(\@x_signals);
    }

    if ($Opt->{activate_test_end_checker} eq "1") {





        $test_end_expr = 
          "M_valid & M_en & (
            M_sim_reg_stop |
            (M_op_cmpltui & (M_iw_a == 0) & (M_iw_b == 0) &
              ((M_iw_imm16 == 16'habc1) | (M_iw_imm16 == 16'habc2))))";
    }

    my $crst_active = "M_op_crst & M_valid";
    my $pc = "M_pcb";
    my $dstRegVal = "M_wr_data_filtered";

    my $crst_active = "M_op_crst";
    my $intr_active = "M_op_intr";
    my $hbreak_active = "M_op_hbreak";

    my $iw_valid_expr;
    $iw_valid_expr = "~($intr_active | $hbreak_active)";

    my $reset_entry = {
        hard_reset_expr => "~reset_n",
        cpu_only_reset_expr => $cpu_reset ? $crst_active : undef,
    };

    my $hbreak_entry = {
        condition   => "(M_op_hbreak & M_valid)",
        pc          => $pc,
        dstRegWr    => "M_wr_dst_reg",
        dstRegNum   => "M_dst_regnum",
        dstRegVal   => $dstRegVal,
    };

    my $intr_entry = {
        condition   => "(M_op_intr & M_valid)",
        pc          => $pc,
        dstRegWr    => "M_wr_dst_reg",
        dstRegNum   => "M_dst_regnum",
        dstRegVal   => $dstRegVal,
    };
    
    my $inst_entry = {
        condition   => "M_valid & M_en",
        exc         => "(M_ctrl_exception | M_ctrl_break)",
        pc          => $pc,
        ivValid     => $iw_valid_expr,
        iv          => "M_iw",
        dstRegWr    => "M_wr_dst_reg",
        dstRegNum   => "M_dst_regnum",
        dstRegVal   => $dstRegVal,
        memAddr     => "M_mem_baddr",
        stData      => "M_st_data",
        stByteEn    => "M_mem_byte_en",
        pass        => "M_cmp_result",
        targetPC    => "M_target_pcb",
    };

    my $cpu_info = {
        CpuCoreName     => "NiosII/s",
        CpuInstanceName => not_empty_scalar($Opt, "name"),
        CpuArchName     => "Nios2",
        CpuArchRev      => "R1",
    };

    create_rtl_trace_and_testend({
      activate_trace    => manditory_bool($Opt, "activate_trace"),
      filename_base     => not_empty_scalar($Opt, "name"),
      reset_entry       => $reset_entry,
      intr_entry        => $intr_entry,
      hbreak_entry      => $hbreak_entry,
      inst_entry        => $inst_entry,
      control_regs      => manditory_array($Opt, "control_regs"),
      control_reg_stage => not_empty_scalar($Opt, "control_reg_stage"),
      cpu_info          => $cpu_info,
      test_end_expr     => $test_end_expr,
    });




    $submodule->sink_signals(
      "W_pcb",
      "W_vinst",
      "W_valid",
      "W_iw",
    );

    my @testbench_simgen_waves = (
        { radix => "x", signal => "$testbench_instance_name/W_pcb" },
        { radix => "a", signal => "$testbench_instance_name/W_vinst" },
        { radix => "x", signal => "$testbench_instance_name/W_valid" },
        { radix => "x", signal => "$testbench_instance_name/W_iw" },
    );

    push(@simgen_wave_signals, @testbench_simgen_waves);

    return $submodule;
}

sub make_base_pipeline
{
    my $Opt = shift;

    my $whoami = "backend 400 base pipeline";

    my $ds = not_empty_scalar($Opt, "dispatch_stage");


    e_signal->adds({name => "D_pcb", never_export => 1, width => $pcb_sz});
    e_signal->adds({name => "E_pcb", never_export => 1, width => $pcb_sz});
    e_signal->adds({name => "M_pcb", never_export => 1, width => $pcb_sz});
    e_signal->adds({name => "W_pcb", never_export => 1, width => $pcb_sz});

    e_assign->adds(["D_pcb", "{D_pc, 2'b00}"]);
    e_register->adds(
      {out => "E_pcb",             in => "D_pcb",         enable => "E_en"},
      {out => "M_pcb",             in => "E_pcb",         enable => "M_en",
       ip_debug_visible => 1},
      {out => "W_pcb",             in => "M_pcb",         enable => "1'b1"},
      );

    if ($Opt->{export_pcb}) {

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







    e_assign->adds(
      [["D_stall", 1], "E_stall"],

      [["D_en", 1], "~D_stall"],        
      );


    e_register->adds(
      {out => ["D_iw", $iw_sz],                 in => "F_iw",     
       enable => "D_en"},
      {out => ["D_pc", $pc_sz],                 in => "F_pc", 
       enable => "D_en"},
      {out => ["D_pc_plus_one", $pc_sz],        in => "F_pc_plus_one",
       enable => "D_en"},
      );





    e_assign->adds(





      [["D_valid", 1], "D_issue & ~M_pipe_flush"],
    );





    e_assign->adds(



      [["D_extra_pc", $pc_sz], 
        "D_br_pred_not_taken ? D_br_taken_waddr : 
                               D_pc_plus_one"],
    );


    e_signal->adds({name => "D_extra_pcb", never_export => 1, 
      width => $pcb_sz});
    e_assign->adds(["D_extra_pcb", "{D_extra_pc, 2'b00}"]);







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
      {out => ["E_extra_pc", $pc_sz],       in => "D_extra_pc", 
       enable => "E_en"},
      {out => ["E_pc", $pc_sz],             in => "D_pc", 
       enable => "E_en"},
      );


    if ($jmp_direct_hi_sz > 0) {
        e_register->adds(
          {out => ["E_jmp_direct_pc_hi", $jmp_direct_hi_sz],
           in => "D_pc[$pc_sz-1:$iw_imm26_sz]", enable => "E_en"},
        );
    }


    e_signal->adds({name => "E_extra_pcb", never_export => 1, 
      width => $pcb_sz});
    e_assign->adds(["E_extra_pcb", "{E_extra_pc, 2'b00}"]);


    e_assign->adds(["E_src1_corrupt", "1'b0"]);








    if ($pc_sz > $iw_imm26_sz) {
        e_assign->adds(
          [["E_jmp_direct_target_waddr", $pc_sz], 
            "{E_jmp_direct_pc_hi, E_iw[$iw_imm26_msb:$iw_imm26_lsb]}"],
        );
    } else {
        e_assign->adds(
          [["E_jmp_direct_target_waddr", $pc_sz], 
            "E_iw[$iw_imm26_msb:$iw_imm26_lsb]"],
        );
    }


    e_signal->adds({name => "E_jmp_direct_target_baddr", never_export => 1, 
      width => $pc_sz+2});
    e_assign->adds(["E_jmp_direct_target_baddr", 
     "{E_jmp_direct_target_waddr, 2'b00}"]);






    if (manditory_bool($Opt, "export_vectors")) {
        e_port->adds(["reset_vector_word_addr", $pc_sz, "in"]);
        e_port->adds(["exception_vector_word_addr", $pc_sz, "in"]);
        e_port->adds(["break_vector_word_addr", $pc_sz, "in"]);
    }

    e_assign->adds(


      [["E_valid", 1], "E_valid_from_D & ~E_cancel"],



      [["E_wr_dst_reg", 1], "E_wr_dst_reg_from_D & ~E_cancel"],



      [["E_valid_prior_to_hbreak", 1], "E_valid_from_D & ~M_pipe_flush"],



      [["E_cancel", 1], "M_pipe_flush | E_hbreak_req"],











      [["M_pipe_flush_nxt", 1], 
        "E_br_mispredict | 
         (E_valid & E_ctrl_flush_pipe_always) |
         (E_valid_prior_to_hbreak & E_hbreak_req)"],












      [["M_pipe_flush_waddr_nxt", $pc_sz],
        "E_hbreak_req        ? E_pc                       :
         E_ctrl_jmp_indirect ? E_src1[$pcb_sz-1:2]        :
         E_ctrl_jmp_direct   ? E_jmp_direct_target_waddr  :
         E_ctrl_crst         ? " .
            (manditory_bool($Opt, "export_vectors") ?
            "reset_vector_word_addr" :
            $Opt->{reset_word_addr} ). ":
         E_ctrl_exception    ? " .
            (manditory_bool($Opt, "export_vectors") ?
            "exception_vector_word_addr" :
            $Opt->{general_exception_word_addr} ). ":
         E_ctrl_break        ? " .
            (manditory_bool($Opt, "export_vectors") ?
            "break_vector_word_addr" :
            $Opt->{break_word_addr} ). ":
            E_extra_pc"],
    );


    e_signal->adds({name => "M_pipe_flush_baddr_nxt", never_export => 1, 
      width => $pcb_sz});
    e_assign->adds(["M_pipe_flush_baddr_nxt", 
      "{M_pipe_flush_waddr_nxt, 2'b00}"]);











    my $M_stall_inputs = "M_ld_stall | M_st_stall";

    if ($hw_mul) {
        if ($hw_mul_uses_dsp_block) {
            $M_stall_inputs .= " | M_mul_shift_rot_stall";
        } else {

            $M_stall_inputs .= " | M_mul_stall | M_shift_rot_stall";
        }
    } else {
        $M_stall_inputs .= " | M_shift_rot_stall";
    }

    if ($hw_div) {
        $M_stall_inputs .= " | M_div_stall";
    }

    if (nios2_custom_insts::has_multi_insts($Opt->{custom_instructions})) {
        $M_stall_inputs .= " | M_ci_multi_stall";
    }

    e_assign->adds(
      [["M_stall", 1], $M_stall_inputs],


      [["M_en", 1], "~M_stall"],        
      );

    e_signal->adds(


      {name => "M_cmp_result", never_export => 1, width => 1},
    );

    e_register->adds(
      {out => ["M_valid_from_E", 1],                in => "E_valid",
       enable => "M_en", ip_debug_visible => 1},
      {out => ["M_iw",  $iw_sz],                    in => "E_iw",
       enable => "M_en", ip_debug_visible => 1},
      {out => ["M_mem_byte_en", $byte_en_sz],       in => "E_mem_byte_en",
       enable => "M_en", },
      {out => ["M_alu_result", $datapath_sz],       in => "E_alu_result",
       enable => "M_en"},
      {out => ["M_st_data", $datapath_sz],          in => "E_st_data",
       enable => "M_en"},
      {out => ["M_dst_regnum", $regnum_sz],         in => "E_dst_regnum",
       enable => "M_en"},
      {out => "M_cmp_result",                       in => "E_cmp_result",
       enable => "M_en"},



      {out => ["M_wr_dst_reg", 1],                  in => "E_wr_dst_reg",
       enable => "M_en", async_value => "1'b1" },


      {out => ["M_pipe_flush", 1],              in => "M_pipe_flush_nxt",
       enable => "M_en", async_value => "1'b1" },
      {out => ["M_pipe_flush_waddr", $pc_sz],   in => "M_pipe_flush_waddr_nxt",
       enable => "M_en", async_value => (manditory_bool($Opt, "export_vectors") ? "reset_vector_word_addr" : "$reset_pc")},
      );


    e_signal->adds({name => "M_pipe_flush_baddr", never_export => 1, 
      width => $pcb_sz});
    e_assign->adds(["M_pipe_flush_baddr", "{M_pipe_flush_waddr, 2'b00}"]);

    e_assign->adds(


      [["M_mem_baddr", $mem_baddr_sz], "M_alu_result[$mem_baddr_sz-1:0]"],


      [["M_valid", 1], "M_valid_from_E"],
      );














    if ($hw_div) {
        e_register->adds(
          {out => ["av_ld_data_aligned_or_div", $datapath_sz], 
           in => "M_ctrl_div ? M_div_quot : av_ld_data_aligned_nxt",
           enable => "1'b1"},


          {out => ["av_ld_or_div_done", 1], 
           in => 
             "M_ctrl_div ? (M_en ? 0 : M_div_quot_ready) : av_ld_aligning_data",
           enable => "1'b1"},
        );
    } else {
        e_register->adds(
          {out => ["av_ld_data_aligned_or_div", $datapath_sz], 
           in => "av_ld_data_aligned_nxt",
           enable => "1'b1"},


          {out => ["av_ld_or_div_done", 1], 
           in => "av_ld_aligning_data",
           enable => "1'b1"},
        );
    }









    my $M_wr_data_mux_table = [];

    if ($hw_mul) {
        if ($hw_mul_uses_dsp_block) {
            push(@$M_wr_data_mux_table,
              "M_ctrl_mul_shift_rot"             => "M_mul_shift_rot_result",
            );
        } elsif ($hw_mul_uses_embedded_mults || $hw_mul_uses_les ) {
            push(@$M_wr_data_mux_table,
              "M_ctrl_mul_lsw"                   => "M_mul_result",
            );
            push(@$M_wr_data_mux_table,
              "M_ctrl_shift_rot"                 => "M_shift_rot_result",
            );
        } else {
            &$error("$whoami: unsupported hardware multiplier implementation");
        }
    } else {
        push(@$M_wr_data_mux_table,
          "M_ctrl_shift_rot"                 => "M_shift_rot_result",
        );
    }

    push(@$M_wr_data_mux_table, 
      "av_ld_or_div_done"                    => "av_ld_data_aligned_or_div",
    );

    if (nios2_custom_insts::has_multi_insts($Opt->{custom_instructions})) {
        push(@$M_wr_data_mux_table,
          "M_ctrl_custom_multi"              => "M_ci_multi_result_d1",
        );
    }

    push(@$M_wr_data_mux_table, 
      "1'b1"                                 => "M_alu_result",
    );

    e_mux->add ({
      lhs => ["M_wr_data_unfiltered", $datapath_sz],
      type => "priority",
      table => $M_wr_data_mux_table,
      });


    e_assign->adds(
      [["M_fwd_reg_data", $datapath_sz], "M_wr_data_filtered"],
      );







    e_assign->adds(
      [["W_stall", 1], "M_stall"],


      [["W_en", 1], "~W_stall"],        
      );

    e_signal->adds(

      {name => "W_iw",          never_export => 1, width => $iw_sz},
      {name => "W_valid",       never_export => 1, width => 1},
    );





    e_register->adds(
      {out => ["W_wr_data", $datapath_sz],          in => "M_wr_data_filtered",
       enable => "W_en"},
      {out => ["W_wr_dst_reg", 1],                  in => "M_wr_dst_reg & M_en",
       enable => "W_en"},
      {out => ["W_dst_regnum", $regnum_sz],         in => "M_dst_regnum",   
       enable => "W_en"},






      {out => "W_iw",         in => "M_iw",           enable => "1'b1"},
      {out => "W_valid",      in => "M_valid & M_en", enable => "1'b1"},
      );





    my @mem_load_store_wave_signals = (
        { divider => "mem" },
        { radix => "x", signal => "E_mem_baddr" },
        { radix => "x", signal => "M_mem_baddr" },
        { divider => "load" },
        { radix => "x", signal => "M_ctrl_ld" },
        { radix => "x", signal => "M_ctrl_ld_signed" },
        { radix => "x", signal => "M_mem_baddr" },
        { radix => "x", signal => "av_ld_or_div_done" },
        { radix => "x", signal => "M_wr_data_unfiltered" },
        { radix => "x", signal => "M_wr_data_filtered" },
        { radix => "x", signal => "av_ld_data_aligned_or_div" },
        { divider => "store" },
        { radix => "x", signal => "E_ctrl_st" },
        { radix => "x", signal => "E_valid" },
        { radix => "x", signal => "E_st_data" },
        { radix => "x", signal => "E_mem_byte_en" },
      );

    if ($Opt->{full_waveform_signals}) {
        push(@plaintext_wave_signals, @mem_load_store_wave_signals);
    }
}





sub make_custom_instruction_master
{
    my ($Opt) = @_;


    be_make_custom_instruction_master($Opt); 


    if (nios2_custom_insts::has_multi_insts($Opt->{custom_instructions})) {
        e_register->adds(

          {out => ["M_ci_multi_src1", $datapath_sz], in => "E_src1", 
           enable => "M_en"},
          {out => ["M_ci_multi_src2", $datapath_sz], in => "E_src2", 
           enable => "M_en"},



          {out => ["M_ci_multi_result_d1", $datapath_sz], 
           in => "M_ci_multi_result", enable => "1'b1"},




          {out => ["M_ci_multi_stall", 1], 
           in => "M_ci_multi_stall ? ~M_ci_multi_done : 
             (E_ctrl_custom_multi & E_valid & M_en)",
           enable => "1'b1"},



          {out => ["M_ci_multi_start", 1], 
           in => "M_ci_multi_start ? 1'b0 : 
             (E_ctrl_custom_multi & E_valid & M_en)",
           enable => "1'b1"},
        );




        e_assign->add([["M_ci_multi_clk_en", 1], "M_ci_multi_stall"]);
        e_assign->add([["A_ci_multi_clock", 1], "clk"]);
        e_assign->add([["A_ci_multi_reset", 1], "~reset_n"]);
        e_assign->add([["A_ci_multi_reset_req", 1], "reset_req"]);
    }
}






sub make_fetch_npc
{
    my ($Opt) = @_;

    my $whoami = "fetch next PC";

    my $fetch_npc = not_empty_scalar($Opt, "fetch_npc");
    my $fetch_npcb = not_empty_scalar($Opt, "fetch_npcb");
    my $ds = not_empty_scalar($Opt, "dispatch_stage");








    e_mux->add ({
      lhs => [$fetch_npc, $pc_sz],
      type => "priority",
      table => [
        "M_pipe_flush"                  => "M_pipe_flush_waddr",
        "D_refetch",                    => "D_pc",
        "D_br_pred_taken & D_issue"     => "D_br_taken_waddr",
        "1'b1"                          => "${ds}_pc_plus_one",
        ],
      });

    my @fetch_npc = (
        { divider => "fetch_npc" },
        { radix => "x", signal => "M_pipe_flush" },
        { radix => "x", signal => "M_pipe_flush_baddr" },
        { radix => "x", signal => "D_refetch" },
        { radix => "x", signal => "D_pcb" },
        { radix => "x", signal => "D_br_pred_taken" },
        { radix => "x", signal => "D_br_taken_baddr" },
        { radix => "x", signal => "$fetch_npcb" },
      );

    if ($Opt->{full_waveform_signals}) {
        push(@plaintext_wave_signals, @fetch_npc);
    }
}





sub make_register_file
{
    my $Opt = shift;

    my $whoami = "register file";

    my $ds = not_empty_scalar($Opt, "dispatch_stage");




    e_signal->adds(
      ["D_rf_a", $datapath_sz],
      ["D_rf_b", $datapath_sz],
      );

    my $rf_ram_a_fname = $Opt->{name} . "_rf_ram_a";


    nios_sdp_ram->add({
      name => $Opt->{name} . "_register_bank_a",
      Opt                     => $Opt,
      data_width              => $datapath_sz,
      address_width           => $rf_addr_sz,
      num_words               => $rf_num_reg,
      contents_file           => $rf_ram_a_fname,
      read_during_write_mode_mixed_ports => qq("OLD_DATA"),
      ram_block_type          => qq("$Opt->{register_file_ram_type}"),
      port_map => {
        clock     => "clk",


        data      => "M_wr_data_filtered",
        wren      => "M_wr_dst_reg",
        wraddress => "M_dst_regnum",


        rden      => "D_en",
        rdaddress => "${ds}_ram_iw_a",
        q         => "D_rf_a",
      },
    });

    my $do_build_sim = manditory_bool($Opt, "do_build_sim");
    my $simulation_directory = $do_build_sim ? 
        not_empty_scalar($Opt, "simulation_directory") : undef;

    make_contents_file_for_ram({
      filename_no_suffix        => $rf_ram_a_fname,
      data_sz                   => $datapath_sz,
      num_entries               => $rf_num_reg, 
      value_str                 => "deadbeef",
      clear_hdl_sim_contents    => 0,
      do_build_sim              => $do_build_sim,
      simulation_directory      => $simulation_directory,
      system_directory          => not_empty_scalar($Opt, "system_directory"),
    });

    my $rf_ram_b_fname = $Opt->{name} . "_rf_ram_b";


    nios_sdp_ram->add({
      name => $Opt->{name} . "_register_bank_b",
      Opt                     => $Opt,
      data_width              => $datapath_sz,
      address_width           => $rf_addr_sz,
      num_words               => $rf_num_reg,
      contents_file           => $rf_ram_b_fname,
      read_during_write_mode_mixed_ports => qq("OLD_DATA"),
      ram_block_type          => qq("$Opt->{register_file_ram_type}"),
      port_map => {
        clock     => "clk",


        data      => "M_wr_data_filtered",
        wren      => "M_wr_dst_reg",
        wraddress => "M_dst_regnum",
   

        rden      => "D_en",
        rdaddress => "${ds}_ram_iw_b",
        q         => "D_rf_b",
      },
    });

    make_contents_file_for_ram({
      filename_no_suffix        => $rf_ram_b_fname,
      data_sz                   => $datapath_sz,
      num_entries               => $rf_num_reg, 
      value_str                 => "deadbeef",
      clear_hdl_sim_contents    => 0,
      do_build_sim              => $do_build_sim,
      simulation_directory      => $simulation_directory,
      system_directory          => not_empty_scalar($Opt, "system_directory"),
    });

    my @src_operands = (
        { divider => "register_file" },
        { radix => "x", signal => "${ds}_ram_iw_a" },
        { radix => "x", signal => "${ds}_ram_iw_b" },
        { radix => "x", signal => "D_rf_a" },
        { radix => "x", signal => "D_rf_b" },
        { radix => "x", signal => "M_wr_dst_reg" },
        { radix => "x", signal => "M_dst_regnum" },
        { radix => "x", signal => "M_wr_data_unfiltered" },
        { radix => "x", signal => "M_wr_data_filtered" },
        { radix => "x", signal => "W_wr_data" },
      );

    if ($Opt->{full_waveform_signals}) {
        push(@plaintext_wave_signals, @src_operands);
    }
}





sub make_reg_cmp
{
    my ($Opt) = @_;

    my $whoami = "register compare";

    my $ds = not_empty_scalar($Opt, "dispatch_stage");
    my $di = not_empty_scalar($Opt, "dispatch_raw_iw");
    







    e_assign->adds(
      [["D_regnum_a_cmp_E", 1], "(D_iw_a == E_dst_regnum) & E_wr_dst_reg"],
      [["D_regnum_a_cmp_M", 1], "(D_iw_a == M_dst_regnum) & M_wr_dst_reg"],
      [["D_regnum_a_cmp_W", 1], "(D_iw_a == W_dst_regnum) & W_wr_dst_reg"],

      [["D_regnum_b_cmp_E", 1], "(D_iw_b == E_dst_regnum) & E_wr_dst_reg"],
      [["D_regnum_b_cmp_M", 1], "(D_iw_b == M_dst_regnum) & M_wr_dst_reg"],
      [["D_regnum_b_cmp_W", 1], "(D_iw_b == W_dst_regnum) & W_wr_dst_reg"],
      );






    e_assign->adds(
      [["D_ctrl_a_is_src", 1], "~D_ctrl_a_not_src"],
      [["D_ctrl_b_is_src", 1], "~D_ctrl_b_not_src"],
      );




    e_assign->adds(
      [["D_src1_hazard_E", 1], "D_regnum_a_cmp_E & D_ctrl_a_is_src"],
      [["D_src1_hazard_M", 1], "D_regnum_a_cmp_M & D_ctrl_a_is_src"],
      [["D_src1_hazard_W", 1], "D_regnum_a_cmp_W & D_ctrl_a_is_src"],
    
      [["D_src2_hazard_E", 1], "D_regnum_b_cmp_E & D_ctrl_b_is_src"],
      [["D_src2_hazard_M", 1], "D_regnum_b_cmp_M & D_ctrl_b_is_src"],
      [["D_src2_hazard_W", 1], "D_regnum_b_cmp_W & D_ctrl_b_is_src"],
      );


    e_register->adds(
      {out => ["E_src1_hazard_M", 1],           in => "D_src1_hazard_E", 
       enable => "E_en"},
      {out => ["E_src2_hazard_M", 1],           in => "D_src2_hazard_E", 
       enable => "E_en"},
      );









    e_assign->adds(
      [["D_dstfield_regnum", $regnum_sz], "D_ctrl_b_is_dst ? D_iw_b : D_iw_c"],

      [["D_dst_regnum", $regnum_sz], 
        "D_ctrl_implicit_dst_retaddr ? $retaddr_regnum : 
         D_ctrl_implicit_dst_eretaddr ? $eretaddr_regnum : 
         D_dstfield_regnum"],

      [["D_wr_dst_reg", 1], 
        "(D_dst_regnum != 0) & ~D_ctrl_ignore_dst & D_valid"],
      );

    my @reg_cmp = (
        { divider => "reg_cmp" },
        { radix => "x", signal => "D_regnum_a_cmp_E" },
        { radix => "x", signal => "D_regnum_a_cmp_M" },
        { radix => "x", signal => "D_regnum_a_cmp_W" },
        { radix => "x", signal => "D_regnum_b_cmp_E" },
        { radix => "x", signal => "D_regnum_b_cmp_M" },
        { radix => "x", signal => "D_regnum_b_cmp_W" },
        { radix => "x", signal => "D_ctrl_a_is_src" },
        { radix => "x", signal => "D_ctrl_b_is_src" },
        { radix => "x", signal => "D_ctrl_ignore_dst" },
        { radix => "x", signal => "D_dstfield_regnum" },
        { radix => "x", signal => "D_dst_regnum" },
        { radix => "x", signal => "D_wr_dst_reg" },
      );

    if ($Opt->{full_waveform_signals}) {
        push(@plaintext_wave_signals, @reg_cmp);
    }
}




sub make_src_operands
{
    my ($Opt) = @_;










    e_mux->add ({
    lhs => ["D_src1_prelim", $datapath_sz],
      type => "priority",
      table => [
        "D_src1_hazard_M"   => "M_fwd_reg_data",
        "D_src1_hazard_W"   => "W_wr_data",
        "1'b1"              => "D_rf_a",
        ],
      });







    e_mux->add ({
      lhs => ["D_src2_prelim", $datapath_sz],
      type => "priority",
      table => [
        "D_src2_hazard_M"   => "M_fwd_reg_data",
        "D_src2_hazard_W"   => "W_wr_data",
        "1'b1"              => "D_rf_b",
        ],
      });





    e_assign->adds(
      [["D_src2_imm_sel", 2], "{D_ctrl_hi_imm16,D_ctrl_unsigned_lo_imm16}"],
      );

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


    e_register->adds(
      {out => ["E_src1_prelim", $datapath_sz],  in => "D_src1_prelim", 
       enable => "E_en"},
      {out => ["E_src2_prelim", $datapath_sz],  in => "D_src2_prelim", 
       enable => "E_en"},
      {out => ["E_src2_imm", $datapath_sz],     in => "D_src2_imm", 
       enable => "E_en"},
    );







    e_assign->adds(
      [["E_src1", $datapath_sz], 
        "E_src1_hazard_M ? M_fwd_reg_data : E_src1_prelim"],

      [["E_src2_reg", $datapath_sz], 
        "E_src2_hazard_M ? M_fwd_reg_data : E_src2_prelim"],


      [["E_src2", $datapath_sz],
        "E_ctrl_src2_choose_imm ? E_src2_imm : E_src2_reg"],
      );

    my @src_operands = (
        { divider => "src_operands" },
        { radix => "x", signal => "D_src1_hazard_M" },
        { radix => "x", signal => "D_src1_hazard_W" },
        { radix => "x", signal => "D_src2_hazard_M" },
        { radix => "x", signal => "D_src2_hazard_W" },
        { radix => "x", signal => "D_src2_imm_sel" },
        { radix => "x", signal => "D_src1_prelim" },
        { radix => "x", signal => "D_src2_prelim" },
        { radix => "x", signal => "D_src2_imm" },
        { radix => "x", signal => "E_src1_prelim" },
        { radix => "x", signal => "E_src2_prelim" },
        { radix => "x", signal => "E_src2_imm" },
        { radix => "x", signal => "E_src1" },
        { radix => "x", signal => "E_src2" },
        { radix => "x", signal => "E_src2_reg" },
      );

    if ($Opt->{full_waveform_signals}) {
        push(@plaintext_wave_signals, @src_operands);
    }
}




sub make_alu_controls
{
    my ($Opt) = @_;





    e_assign->adds(
      [["D_logic_op", $logic_op_sz],
        "(D_op_opx ? D_iw_opx[$logic_op_msb:$logic_op_lsb] : 
          D_iw_op[$logic_op_msb:$logic_op_lsb])"],

      [["D_compare_op", $compare_op_sz],
        "(D_op_opx ? D_iw_opx[$compare_op_msb:$compare_op_lsb] : 
          D_iw_op[$compare_op_msb:$compare_op_lsb])"],
      );
  

    e_register->adds(
      {out => ["E_logic_op", $logic_op_sz], in => "D_logic_op", 
       enable => "E_en"},
      {out => ["E_compare_op", $compare_op_sz], in => "D_compare_op", 
       enable => "E_en"},
    );
}




sub make_interrupts
{
    my ($Opt) = @_;

    e_assign->adds(


      [["intr_req", 1], 
        "M_status_reg_pie & (M_ipending_reg != 0)"],
      );
}







sub make_data_master
{
    my ($Opt) = @_;

    $Opt->{data_master}{port_map} = {
      clk            => "clk",
      reset_n        => "reset_n",
      d_irq          => "irq",
      d_readdata     => "readdata",
      d_waitrequest  => "waitrequest",
      d_writedata    => "writedata",
      d_address      => "address",
      d_byteenable   => "byteenable",
      d_read         => "read",
      d_write        => "write",

      jtag_debug_module_debugaccess_to_roms  => "debugaccess",
    };

    my $data_addr_width = $Opt->{data_master}{Address_Width};

    push(@{$Opt->{port_list}},
      [clk              => 1,                 "in" ],
      [reset_n          => 1,                 "in" ],
      [d_readdata       => $datapath_sz,      "in" ],
      [d_waitrequest    => 1,                 "in" ],
      [d_irq            => $interrupt_sz,     "in" ],
      [d_address        => $data_addr_width,  "out"],
      [d_byteenable     => $byte_en_sz,       "out"],
      [d_read           => 1,                 "out"],
      [d_write          => 1,                 "out"],
      [d_writedata      => $datapath_sz,      "out"],
    );

    e_assign->adds(

      [["av_ld_req", 1], "E_ctrl_ld & E_valid & M_en"],



      [["M_ld_stall", 1], "M_ctrl_ld & M_valid & ~av_ld_or_div_done"],



      [["d_read_nxt", 1], "av_ld_req | (d_read & d_waitrequest)"],


      [["av_st_req", 1], "E_ctrl_st & E_valid & M_en"],


      [["M_st_stall", 1], "d_write & d_waitrequest"],



      [["d_write_nxt", 1], "av_st_req | (d_write & d_waitrequest)"],


      [["d_writedata", $datapath_sz], "M_st_data"],
      [["d_byteenable", $byte_en_sz], "M_mem_byte_en"],


      [["d_address", $mem_baddr_sz], "M_mem_baddr"],



      [["av_ld_data_transfer", 1], "d_read & ~d_waitrequest"],
      );

    e_register->adds(
      {out => ["d_write", 1],                   in => "d_write_nxt",    
       enable => "1'b1"},
      {out => ["d_read", 1],                    in => "d_read_nxt",    
       enable => "1'b1"},
      {out => ["d_readdata_d1", $datapath_sz],  in => "d_readdata",
       enable => "1'b1"},



      {out => ["av_ld_aligning_data", 1], in => "av_ld_data_transfer",
       enable => "1'b1"},
      );

    my @data_master = (
        { divider => "data_master" },
        { radix => "x", signal => "M_alu_result" },
        { radix => "x", signal => "av_ld_req" },
        { radix => "x", signal => "av_ld_data_transfer" },
        { radix => "x", signal => "av_ld_aligning_data" },
        { radix => "x", signal => "av_ld_or_div_done" },
        { radix => "x", signal => "M_ld_stall" },
        { radix => "x", signal => "av_st_req" },
        { radix => "x", signal => "M_st_stall" },
        { radix => "x", signal => "d_read" },
        { radix => "x", signal => "d_write" },
        { radix => "x", signal => "d_address" },
        { radix => "x", signal => "d_waitrequest" },
        { radix => "x", signal => "d_readdata" },
        { radix => "x", signal => "d_readdata_d1" },
        { radix => "x", signal => "d_writedata" },
        { radix => "x", signal => "d_byteenable" },
      );

    if ($Opt->{full_waveform_signals}) {
        push(@plaintext_wave_signals, @data_master);
    }
}









sub make_data_master_ld_aligner
{
    my ($Opt) = @_;


    e_assign->adds(

      [["av_sign_bit_16", 2], 
        "${big_endian_tilde}M_mem_baddr[1] ? 
          {d_readdata_d1[31], d_readdata_d1[23]} : 
          {d_readdata_d1[15], d_readdata_d1[7]}"],



      [["av_sign_bit", 1], 
        "((${big_endian_tilde}M_mem_baddr[0]) | M_mem16) ? 
            av_sign_bit_16[1] : av_sign_bit_16[0]"],



      [["av_fill_bit", 1], "av_sign_bit & M_ctrl_ld_signed"],



      [["M_ld_align_sh16", 1], "~M_mem32 & ${big_endian_tilde}M_mem_baddr[1]"],




      [["M_ld_align_sh8", 1], "M_mem8 & ${big_endian_tilde}M_mem_baddr[0]"],
      );




    e_assign->adds(
      [["av_ld16_data", 16], "M_ld_align_sh16 ? 
        d_readdata_d1[31:16] :
        d_readdata_d1[15:0]"],

      [["av_ld_byte0_data", 8], "M_ld_align_sh8 ? 
        av_ld16_data[15:8] :
        av_ld16_data[7:0]"],

      [["av_ld_byte1_data", 8], "M_mem8 ? 
        {8 {av_fill_bit}} : 
        av_ld16_data[15:8]"],

      [["av_ld_byte2_data", 8], "~M_mem32 ? 
        {8 {av_fill_bit}} : 
        d_readdata_d1[23:16]"],

      [["av_ld_byte3_data", 8], "~M_mem32 ? 
        {8 {av_fill_bit}} : 
        d_readdata_d1[31:24]"],

      [["av_ld_data_aligned_nxt", $datapath_sz], 
        "{av_ld_byte3_data, av_ld_byte2_data, 
          av_ld_byte1_data, av_ld_byte0_data}"],
      );

    my @data_master_ld_aligner = (
        { divider => "data_master_ld_aligner" },
        { radix => "x", signal => "av_sign_bit_16" },
        { radix => "x", signal => "av_sign_bit" },
        { radix => "x", signal => "av_fill_bit" },
        { radix => "x", signal => "M_ld_align_sh16" },
        { radix => "x", signal => "M_ld_align_sh8" },
        { radix => "x", signal => "av_ld16_data" },
        { radix => "x", signal => "av_ld_byte0_data" },
        { radix => "x", signal => "av_ld_byte1_data" },
        { radix => "x", signal => "av_ld_byte2_data" },
        { radix => "x", signal => "av_ld_byte3_data" },
        { radix => "x", signal => "av_ld_data_aligned_nxt" },
        { radix => "x", signal => "av_ld_data_aligned_or_div" },
    );

    if ($Opt->{full_waveform_signals}) {
        push(@plaintext_wave_signals, @data_master_ld_aligner);
    }
}




sub 
make_potential_tb_logic
{
    my $Opt = shift;



    e_assign->adds(
      [["E_src1_src2_fast_cmp", $datapath_sz+1], 
        "{1'b0, E_src1 ^ E_src2} - 33'b1"],

      [["E_src1_eq_src2", 1], "E_src1_src2_fast_cmp[$datapath_sz]"],
      );
}

1;
