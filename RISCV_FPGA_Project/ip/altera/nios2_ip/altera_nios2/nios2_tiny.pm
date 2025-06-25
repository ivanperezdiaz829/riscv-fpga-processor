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






















package nios2_tiny;

use cpu_utils;
use cpu_wave_signals;
use cpu_file_utils;
use cpu_inst_desc;
use cpu_inst_gen;
use europa_all;
use europa_utils;
use nios_utils;
use nios_europa;
use nios_testbench_utils;
use nios_sdp_ram;
use nios_avalon_masters;
use nios_common;
use nios_isa;
use nios2_isa;
use nios2_insts;
use nios2_control_regs;
use nios2_common;
use nios2_custom_insts;
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
    return ["F", "D", "R"];
}

sub 
make_cpu
{
    my ($Opt, $top_module) = (@_);

    my $marker = e_default_module_marker->new($top_module);

    set_pipeline_description($Opt);

    my $testbench_submodule = make_testbench($Opt);
    e_signal->adds({name => "test_ending", never_export => 1, width => 1});
    e_signal->adds({name => "test_has_ended", never_export => 1, width => 1});

    make_inst_decode($Opt);

    make_tiny_pipeline($Opt, $testbench_submodule);

    if ($oci_present) {
        make_nios2_oci($Opt, $top_module);

    } elsif ($third_party_debug_present) {
        make_nios2_third_party_debugger_gasket($Opt, $top_module);
    }
}







sub set_pipeline_description
{
    my $Opt = shift;


    $Opt->{stages} = ["F", "D", "R", "E", "W"];


    $Opt->{exc_stages} = [];


    $Opt->{dispatch_stage} = "F";


    $Opt->{fetch_npc} = "F_pc_nxt";


    $Opt->{fetch_npcb} = "F_pcb_nxt";


    $Opt->{rdctl_stage} = "E";


    $Opt->{control_reg_stage} = "W";


    $Opt->{ci_combo_stage} = "E";


    $Opt->{ci_multi_stage} = "E";



    $Opt->{non_pipelined_long_latency_input_stage} = "E";



    $Opt->{long_latency_output_stage} = "E";


    $Opt->{data_master_interrupt_sz} = 32;
}







sub make_testbench
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
      ["D"]);




    if (manditory_bool($Opt, "simgen")) {
        make_potential_tb_logic($Opt);
    }

    my @x_signals = (
       { sig => "F_valid",                                          },
       { sig => "D_valid",                                          },
       { sig => "E_valid",                                          },
       { sig => "W_valid",                                          },
       { sig => "R_wr_dst_reg", qual => "W_valid",                  },
       { sig => "W_wr_data",    qual => "W_valid & R_wr_dst_reg",   },
       { sig => "R_dst_regnum", qual => "W_valid & R_wr_dst_reg",   },
       { sig => "d_write",                                          },
       { sig => "d_byteenable", qual => "d_write",                  },
       { sig => "d_address",    qual => "d_write | d_read",         },
       { sig => "d_read",                                           },
       { sig => "i_read",                                           },
       { sig => "i_address",    qual => "i_read",                   },
       { sig => "i_readdata",   qual => "i_read & ~i_waitrequest",  },
       { sig => "av_ld_data_aligned_unfiltered", 
         qual => "W_valid & R_ctrl_ld",
         warn => 1,                                                 },
       { sig => "W_wr_data",    
         qual => "W_valid & R_wr_dst_reg",
         warn => 1,                                                 },
    );

    e_signal->adds(


      {name => "av_ld_data_aligned_filtered", width => $datapath_sz, 
       export => $force_export},
    );

    if ($Opt->{clear_x_bits_ld_non_bypass}) {





        create_x_filter({
          lhs       => "av_ld_data_aligned_filtered",
          rhs       => "av_ld_data_aligned_unfiltered", 
          sz        => $datapath_sz,
          qual_expr => "R_ctrl_ld_non_io",
        });
    } else {

        e_assign->adds({
          lhs       => "av_ld_data_aligned_filtered",
          rhs       => "av_ld_data_aligned_unfiltered",
          comment   => "Propagating 'X' data bits",
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
          "W_valid & (
             (D_op_wrctl & (D_iw_control_regnum == $sim_reg_regnum) &
              W_rf_wr_data[$sim_reg_stop_lsb]) |
             (D_op_cmpltui & (D_iw_a == 0) & (D_iw_b == 0) &
              ((D_iw_imm16 == 16'habc1) | (D_iw_imm16 == 16'habc2))))";
    }

    my $crst_active = "D_op_crst & W_valid";
    my $pc = "F_pcb";
    my $dstRegVal = "W_rf_wr_data";

    my $crst_active = "D_op_crst";
    my $intr_active = "D_op_intr";
    my $hbreak_active = "D_op_hbreak";

    my $iw_valid_expr;
    $iw_valid_expr = "~($intr_active | $hbreak_active)";

    my $reset_entry = {
        hard_reset_expr => "~reset_n",
        cpu_only_reset_expr => $cpu_reset ? $crst_active : undef,
    };

    my $hbreak_entry = {
        condition   => "(W_valid & D_op_hbreak)",
        pc          => $pc,
        dstRegWr    => "R_wr_dst_reg",
        dstRegNum   => "R_dst_regnum",
        dstRegVal   => $dstRegVal,
    };

    my $intr_entry = {
        condition   => "(W_valid & D_op_intr)",
        pc          => $pc,
        dstRegWr    => "R_wr_dst_reg",
        dstRegNum   => "R_dst_regnum",
        dstRegVal   => $dstRegVal,
    };
    
    my $inst_entry = {
        condition   => "W_valid", # reset/hbreak/intr take higher priority
        exc         => "(R_ctrl_exception | R_ctrl_break)",
        pc          => $pc,
        ivValid     => $iw_valid_expr,
        iv          => "D_iw",
        dstRegWr    => "R_wr_dst_reg",
        dstRegNum   => "R_dst_regnum",
        dstRegVal   => $dstRegVal,
        memAddr     => "W_mem_baddr",
        stData      => "E_st_data",
        stByteEn    => "E_mem_byte_en",
        pass        => "W_cmp_result",
        targetPC    => "E_alu_result",
    };

    my $cpu_info = {
        CpuCoreName     => "NiosII/e",
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
      "F_pcb",
      "W_vinst",
      "W_valid",
      "D_iw",
    );

    push(@simgen_wave_signals,
        { radix => "x", signal => "$testbench_instance_name/F_pcb" },
        { radix => "a", signal => "$testbench_instance_name/W_vinst" },
        { radix => "x", signal => "$testbench_instance_name/W_valid" },
        { radix => "x", signal => "$testbench_instance_name/D_iw" },
    );

    return $submodule;
}





sub make_inst_decode
{
    my $Opt = shift;





    my $gen_info = manditory_hash($Opt, "gen_info");




    cpu_inst_gen::gen_inst_fields($gen_info, $Opt->{inst_field_info},
      ["F_av", "F", "D"]);





    cpu_inst_gen::gen_inst_decodes($gen_info, $Opt->{inst_desc_info},
      ["F", "D"]);




    cpu_inst_gen::create_sim_wave_inst_names($gen_info, $Opt->{inst_desc_info},
      ["F", "D"]);




    cpu_inst_gen::create_sim_wave_vinst_names($gen_info, $Opt->{inst_desc_info},
      ["F", "D", "R", "E", "W"],
      { R => "D_inst", E => "D_inst", W => "D_inst" },  # inst signal names
      {},       # Default valid signal names
      );


    e_assign->adds([["R_en", 1], "1'b1"]);

    set_inst_ctrl_initial_stage($b_is_dst_ctrl, "D");
    set_inst_ctrl_initial_stage($ignore_dst_ctrl, "D");
    set_inst_ctrl_initial_stage($src2_choose_imm_ctrl, "D");

    set_inst_ctrl_initial_stage($br_ctrl, "D");
    set_inst_ctrl_initial_stage($br_uncond_ctrl, "D");
    set_inst_ctrl_initial_stage($jmp_direct_ctrl, "D");
    set_inst_ctrl_initial_stage($jmp_indirect_ctrl, "D");
    set_inst_ctrl_initial_stage($uncond_cti_non_br_ctrl, "D");

    set_inst_ctrl_initial_stage($exception_ctrl, "D");
    set_inst_ctrl_initial_stage($break_ctrl, "D");
    set_inst_ctrl_initial_stage($crst_ctrl, "D");

    set_inst_ctrl_initial_stage($implicit_dst_retaddr_ctrl, "D");
    set_inst_ctrl_initial_stage($implicit_dst_eretaddr_ctrl, "D");

    set_inst_ctrl_initial_stage($hi_imm16_ctrl, "D");
    set_inst_ctrl_initial_stage($unsigned_lo_imm16_ctrl, "D");
    set_inst_ctrl_initial_stage($alu_signed_comparison_ctrl, "D");
    set_inst_ctrl_initial_stage($alu_subtract_ctrl, "D");
    set_inst_ctrl_initial_stage($br_cmp_ctrl, "D");
    set_inst_ctrl_initial_stage($logic_ctrl, "D");
    set_inst_ctrl_initial_stage($retaddr_ctrl, "D");
    set_inst_ctrl_initial_stage($wrctl_inst_ctrl, "D");
    set_inst_ctrl_initial_stage($rdctl_inst_ctrl, "D");

    set_inst_ctrl_initial_stage($ld_ctrl, "D");
    set_inst_ctrl_initial_stage($ld_signed_ctrl, "D");
    set_inst_ctrl_initial_stage($ld_io_ctrl, "D");
    set_inst_ctrl_initial_stage($ld_non_io_ctrl, "D");
    set_inst_ctrl_initial_stage($st_ctrl, "D");

    set_inst_ctrl_initial_stage($custom_ctrl, "D");
    set_inst_ctrl_initial_stage($custom_multi_ctrl, "D");

    set_inst_ctrl_initial_stage($shift_rot_ctrl, "D");
    set_inst_ctrl_initial_stage($rot_right_ctrl, "D");
    set_inst_ctrl_initial_stage($shift_logical_ctrl, "D");
    set_inst_ctrl_initial_stage($shift_rot_right_ctrl, "D");
    set_inst_ctrl_initial_stage($shift_right_arith_ctrl, "D");

    my $default_allowed_modes = 
      manditory_array($Opt, "default_inst_ctrl_allowed_modes");

    my $force_src2_modes = [@$default_allowed_modes, $INST_DESC_RESERVED_MODE];


    my $force_src2_zero_ctrl = nios2_insts::additional_inst_ctrl($Opt, {
      name  => "force_src2_zero",
      ctrls => ["retaddr", "jmp_indirect", "jmp_direct", "illegal"],
      allowed_modes => $force_src2_modes,
    });
    set_inst_ctrl_initial_stage($force_src2_zero_ctrl, "D");




    my $alu_force_xor_ctrl = nios2_insts::additional_inst_ctrl($Opt, {
      name => "alu_force_xor",
      ctrls => ["br_cmp_eq_ne", "br_uncond"],
      allowed_modes => $default_allowed_modes,
    });
    set_inst_ctrl_initial_stage($alu_force_xor_ctrl, "D");

}





sub make_tiny_pipeline
{
    my ($Opt, $testbench_submodule) = @_;






    $Opt->{data_master}{port_map} = {
      clk            => "clk",
      reset_n        => "reset_n",
      d_writedata    => "writedata",
      d_readdata     => "readdata",
      d_address      => "address",
      d_byteenable   => "byteenable",
      d_read         => "read",
      d_write        => "write",
      d_waitrequest  => "waitrequest",
      d_irq          => "irq",

      jtag_debug_module_debugaccess_to_roms  => "debugaccess",
    };

    $Opt->{instruction_master}{port_map} = {
      i_readdata      => "readdata",
      i_address       => "address",
      i_read          => "read",
      i_waitrequest   => "waitrequest",
    };


    if ($Opt->{hbreak_test}) {
        $Opt->{instruction_master}{port_map}->{test_hbreak_req} = "irq";
    }





    push(@{$Opt->{port_list}},

      [d_irq            => 32,                  "in" ],
      [d_waitrequest    => 1,                   "in" ],
      [d_address        => $mem_baddr_sz,       "out"],
      [d_byteenable     => $byte_en_sz,         "out"],
      [d_read           => 1,                   "out"],
      [d_readdata       => 32,                  "in" ],
      [d_write          => 1,                   "out"],
      [d_writedata      => 32,                  "out"],


      [i_waitrequest    => 1,                   "in" ],
      [i_address        => $pcb_sz,             "out"],
      [i_read           => 1,                   "out"],
      [i_readdata       => $iw_sz,              "in" ],
      );




    e_signal->adds(
      {name => "E_ci_result", width => $datapath_sz },
      {name => "E_ci_multi_stall", width => 1 },
    );

    if (nios2_custom_insts::has_insts($Opt->{custom_instructions})) {
        my $ci_master_ports = 
            {
                clk             => "clk",
                E_ci_dataa      => "dataa",
                E_ci_datab      => "datab",
                W_ci_ipending   => "ipending",
                W_ci_status     => "status",
                W_ci_estatus    => "estatus",
                D_ci_n          => "n",
                D_ci_a          => "a",
                D_ci_b          => "b",
                D_ci_c          => "c",
                D_ci_readra     => "readra",
                D_ci_readrb     => "readrb",
                D_ci_writerc    => "writerc",
                E_ci_result     => "result",
            };


        e_assign->adds(
          [["E_ci_dataa", $datapath_sz],    "E_src1"],
          [["E_ci_datab", $datapath_sz],    "E_src2"],
          [["W_ci_ipending", $interrupt_sz],"W_ipending_reg"],
          [["W_ci_status", $status_reg_sz], "W_status_reg"],
          [["W_ci_estatus", $status_reg_sz],"W_estatus_reg"],
          [["D_ci_n", $iw_custom_n_sz],     "D_iw_custom_n"],
          [["D_ci_a", $iw_a_sz],            "D_iw_a"],
          [["D_ci_b", $iw_b_sz],            "D_iw_b"],
          [["D_ci_c", $iw_c_sz],            "D_iw_c"],
          [["D_ci_readra", 1],              "D_iw_custom_readra"],
          [["D_ci_readrb", 1],              "D_iw_custom_readrb"],
          [["D_ci_writerc", 1],             "D_iw_custom_writerc"],
          [["E_ci_multi_clock", 1],         "clk"],
          [["E_ci_multi_reset", 1],         "~reset_n"],
          [["E_ci_multi_reset_req", 1],     "reset_req"],
        );


        push(@{$Opt->{port_list}},
          [E_ci_dataa           => $datapath_sz,        "out" ],
          [E_ci_datab           => $datapath_sz,        "out" ],
          [W_ci_ipending        => $interrupt_sz,       "out" ],
          [W_ci_status          => $status_reg_sz,      "out" ],
          [W_ci_estatus         => $estatus_reg_sz,     "out" ],
          [D_ci_n               => $iw_custom_n_sz,     "out" ],
          [D_ci_a               => $iw_a_sz,            "out" ],
          [D_ci_b               => $iw_b_sz,            "out" ],
          [D_ci_c               => $iw_c_sz,            "out" ],
          [D_ci_readra          => 1,                   "out" ],
          [D_ci_readrb          => 1,                   "out" ],
          [D_ci_writerc         => 1,                   "out" ],
          [E_ci_result          => $datapath_sz,        "in"  ],
        );

        if (nios2_custom_insts::has_multi_insts($Opt->{custom_instructions})) {

            $ci_master_ports->{E_ci_multi_clk_en} = "clk_en";
            $ci_master_ports->{E_ci_multi_clock} = "multi_clk";
            $ci_master_ports->{E_ci_multi_reset} = "multi_reset";
            $ci_master_ports->{E_ci_multi_reset_req} = "multi_reset_req";
            $ci_master_ports->{E_ci_multi_start} = "start";
            $ci_master_ports->{E_ci_multi_done} = "done";


            push(@{$Opt->{port_list}},
              [E_ci_multi_clk_en  => 1,                 "out" ],
              [E_ci_multi_clock  => 1,                  "out" ],
              [E_ci_multi_reset  => 1,                  "out" ],
              [E_ci_multi_start   => 1,                 "out" ],
              [E_ci_multi_done    => 1,                 "in"  ],
            );
        }


        e_custom_instruction_master->add ({
            name     => "custom_instruction_master",
            type_map => $ci_master_ports,
        });
    } else {

        e_assign->add(["E_ci_result", "0"]);
        
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

    if (!nios2_custom_insts::has_multi_insts($Opt->{custom_instructions})) {


        e_assign->add(["E_ci_multi_stall", "1'b0"]);
    }


    e_assign->adds(
      [["iactive", $interrupt_sz], 
        "d_irq[$interrupt_sz-1:0] & " . $Opt->{internal_irq_mask_bin}],
    );










    e_assign->adds(
      [["F_pc_sel_nxt", 2],
         "R_ctrl_exception                          ? 2'b00 :
          R_ctrl_break                              ? 2'b01 :
          (W_br_taken | R_ctrl_uncond_cti_non_br)   ? 2'b10 :
                                                    2'b11"],
      );


    if (manditory_bool($Opt, "export_vectors")) {
        e_port->adds(["reset_vector_word_addr", $pc_sz, "in"]);
        e_port->adds(["exception_vector_word_addr", $pc_sz, "in"]);
        e_port->adds(["break_vector_word_addr", $pc_sz, "in"]);
    }

    e_mux->add ({
      lhs => ["F_pc_no_crst_nxt", $pc_sz],
      selecto => "F_pc_sel_nxt",
      table => [
        "2'b00"                     => (manditory_bool($Opt, "export_vectors") ? "exception_vector_word_addr" : $Opt->{general_exception_word_addr}),
        "2'b01"                     => (manditory_bool($Opt, "export_vectors") ? "break_vector_word_addr" : $Opt->{break_word_addr}),
        "2'b10"                     => "E_arith_result[$pcb_sz-1:2]",
        "2'b11"                     => "F_pc_plus_one",
        ],
      });
    
    if ($cpu_reset) {
        e_assign->adds(
          [["F_pc_nxt", $pc_sz], 
            "R_ctrl_crst ? " . 
              (manditory_bool($Opt, "export_vectors") ? 
              "reset_vector_word_addr" : 
              $Opt->{reset_word_addr}). ": 
            F_pc_no_crst_nxt"],
        );
    } else {
        e_assign->adds(
          [["F_pc_nxt", $pc_sz], "F_pc_no_crst_nxt"],
        );
    }


    e_signal->adds({name => "F_pcb_nxt", never_export => 1, width => $pc_sz+2});
    e_assign->adds(["F_pcb_nxt", "{F_pc_nxt, 2'b00}"]);

    if ($cpu_reset) {

        e_signal->adds(
          {name => "cpu_resettaken", width => 1, export => $force_export },
        );

        push(@{$Opt->{port_list}},
          ["cpu_resetrequest" => 1, "in" ],
          ["cpu_resettaken"   => 1, "out" ],
        );


        e_assign->add(["cpu_resettaken", "R_ctrl_crst & E_valid"]);
    }





    e_assign->adds(


      [["F_pc_en", 1], "W_valid"],


      [["F_pc_plus_one", $pc_sz], "F_pc + 1"],
      );

    e_register->adds(
      {out => ["F_pc", $pc_sz], in => "F_pc_nxt", enable => "F_pc_en",
       async_value => (manditory_bool($Opt, "export_vectors") ? "reset_vector_word_addr" : "$reset_pc"), ip_debug_visible => 1},
      );


    e_signal->adds({name => "F_pcb", never_export => 1, width => $pc_sz+2});
    e_signal->adds({name => "F_pcb_plus_four", never_export => 1, 
      width => $pc_sz+2});
    e_assign->adds(["F_pcb", "{F_pc, 2'b00}"]);
    e_assign->adds(["F_pcb_plus_four", "{F_pc_plus_one, 2'b00}"]);





    e_assign->adds(

      [["F_valid", 1], "i_read & ~i_waitrequest"],        



      [["i_read_nxt", 1], "W_valid | (i_read & i_waitrequest)"],


      [["i_address", $pcb_sz], "{F_pc, 2'b00}"],
      );

    e_register->adds(

      {out => ["i_read", 1], in => "i_read_nxt",
       enable => "1'b1", async_value => "1'b1"},
      );












    if ($debugger_present || $hbreak_test_bench) { 
        if ($hbreak_test_bench) { 
            e_assign->adds(
              [["oci_tb_hbreak_req", 1],"test_hbreak_req"],
              [["oci_single_step_mode", 1, 0, 1],"1'b0"],
            );
        } else {
            e_assign->adds(
              [["oci_tb_hbreak_req", 1],"oci_hbreak_req"],
            );
        }
        e_assign->adds(
          [["hbreak_req", 1],
            "(oci_tb_hbreak_req | hbreak_pending) & hbreak_enabled & ".
            " ~(wait_for_one_post_bret_inst & ~W_valid)"],
        );








        e_assign->adds(
          [["hbreak_pending_nxt", 1], 
            "hbreak_pending ? hbreak_enabled 
                            : hbreak_req"],
        );


















        e_register->adds(
          { out => ["wait_for_one_post_bret_inst", 1, 0, 1], 
            in => "(~hbreak_enabled & oci_single_step_mode) ? 1'b1 ". 
                  " : (F_valid | ~oci_single_step_mode) ? 1'b0 ".
                  " : wait_for_one_post_bret_inst",
            enable => "1'b1", 
            async_value => "1'b0"
          },
          { out => ["hbreak_pending", 1, 0, 1], 
            in => "hbreak_pending_nxt",
            enable => "1'b1", 
            async_value => "1'b0"
          },
        );
    } else {
        e_assign->adds(
          [["hbreak_req", 1], "1'b0"],
        );
    }



    my $inject_crst = 
      $cpu_reset ? 
        (($debugger_present || $hbreak_test_bench) ? 
          "(cpu_resetrequest & hbreak_enabled)" : 
          "cpu_resetrequest") : 
        "1'b0";

    e_assign->adds(


      [["intr_req", 1], "W_status_reg_pie & (W_ipending_reg != 0)"],

      [["F_av_iw", $iw_sz], "i_readdata"],



      [["F_iw", $iw_sz], 
        "hbreak_req     ? $empty_hbreak_iw :
         $inject_crst   ? $empty_crst_iw :
         intr_req       ? $empty_intr_iw : 
                          F_av_iw"],
    );





    e_register->adds(

      {out => ["D_iw", $iw_sz], in => "F_iw", enable => "F_valid",
       ip_debug_visible => 1},



      {out => ["D_valid", 1], in => "F_valid", enable => "1'b1" },
      );








    e_assign->adds(
      [["D_dst_regnum", $regnum_sz], 
        "D_ctrl_implicit_dst_retaddr    ? $retaddr_regnum : 
         D_ctrl_implicit_dst_eretaddr   ? $eretaddr_regnum : 
         D_ctrl_b_is_dst                ? D_iw_b :
                                          D_iw_c"],

      [["D_wr_dst_reg", 1], "(D_dst_regnum != 0) & ~D_ctrl_ignore_dst"],
      );





    e_assign->adds(
      [["D_logic_op_raw", $logic_op_sz],
        "(D_op_opx ? D_iw_opx[$logic_op_msb:$logic_op_lsb] : 
          D_iw_op[$logic_op_msb:$logic_op_lsb])"],

      [["D_logic_op", $logic_op_sz],
        "D_ctrl_alu_force_xor ? $logic_op_xor : D_logic_op_raw"],

      [["D_compare_op", $compare_op_sz],
        "(D_op_opx ? D_iw_opx[$compare_op_msb:$compare_op_lsb] : 
          D_iw_op[$compare_op_msb:$compare_op_lsb])"],
      );
  







    if ($jmp_direct_hi_sz > 0) {
        e_assign->adds(
          [["F_jmp_direct_pc_hi", $jmp_direct_hi_sz],
            "F_pc[$pc_sz-1:$iw_imm26_sz]"],

          [["D_jmp_direct_target_waddr", $pc_sz], 
            "{F_jmp_direct_pc_hi, D_iw[$iw_imm26_msb:$iw_imm26_lsb]}"],
        );
    } else {
        e_assign->adds(
          [["D_jmp_direct_target_waddr", $pc_sz], 
            "D_iw[$iw_imm26_msb:$iw_imm26_lsb]"],
        );
    }





    e_register->adds(


      {out => ["R_valid", 1], in => "D_valid", enable => "1'b1" },


      {out => ["R_wr_dst_reg", 1],              in => "D_wr_dst_reg",
       enable => "1'b1"},
      {out => ["R_dst_regnum", $regnum_sz],     in => "D_dst_regnum",
       enable => "1'b1", ip_debug_visible => 1},
      {out => ["R_logic_op", $logic_op_sz],     in => "D_logic_op", 
       enable => "1'b1" },
      {out => ["R_compare_op", $compare_op_sz], in => "D_compare_op", 
       enable => "1'b1" },




      {out => ["R_src2_use_imm", 1],          
       in => "D_ctrl_src2_choose_imm | (D_ctrl_br & R_valid)",
       enable => "1'b1"},
      );





    e_signal->adds(

      ["R_rf_a", $datapath_sz],
      ["R_rf_b", $datapath_sz],
    );

    e_assign->adds(




      [["W_rf_wren", 1], "(R_wr_dst_reg & W_valid) | ~reset_n"],


      [["W_rf_wr_data", $datapath_sz], 
         "R_ctrl_ld ? av_ld_data_aligned_filtered : W_wr_data"],
      );

    my $rf_ram_a_fname = $Opt->{name} . "_rf_ram_a";


    if (manditory_bool($Opt, "use_designware")) {
        e_comment->add({
          comment => "BCM58 part used to replace register bank a\n",
        });

        e_blind_instance->add({
          name                     => $Opt->{name} . "_register_bank_a",
          module                   => "DWC_n2p_bcm58",
          use_sim_models           => 1,
          in_port_map              => {
            addr_r   => "D_iw_a",
            addr_w   => "R_dst_regnum",
            clk_r    => "clk",
            clk_w    => "clk",
            data_w   => "W_rf_wr_data",
            en_r_n   => qq(1'b0),
            en_w_n   => "~W_rf_wren",
            init_r_n => qq(1'b1),
            init_w_n => qq(1'b1),
            rst_r_n  => "reset_n",
            rst_w_n  => "reset_n"
          },
          out_port_map             => {
            data_r       => "R_rf_a",
            data_r_a     => ""
          },
          parameter_map            => {
            ADDR_WIDTH => $rf_addr_sz,
            WIDTH      => $datapath_sz,
            DEPTH      => $rf_num_reg,
            MEM_MODE   => 2,
            RST_MODE   => 0,
          },
        });
    } else {
        nios_sdp_ram->add({
          name => $Opt->{name} . "_register_bank_a",
          Opt                     => $Opt,
          data_width              => $datapath_sz,
          address_width           => $rf_addr_sz,
          num_words               => $rf_num_reg,
          contents_file           => $rf_ram_a_fname,
          ram_block_type          => qq("$Opt->{register_file_ram_type}"),
          port_map                => {
              clock     => "clk",


              data      => "W_rf_wr_data",
              wren      => "W_rf_wren",
              wraddress => "R_dst_regnum",
        

              rdaddress => "D_iw_a",
              q         => "R_rf_a",
            },
        });
    }

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


    if (manditory_bool($Opt, "use_designware")) {
        e_comment->add({
          comment => "BCM58 part used to replace register bank b\n",
        });

        e_blind_instance->add({
          name                     => $Opt->{name} . "_register_bank_b",
          module                   => "DWC_n2p_bcm58",
          use_sim_models           => 1, 
          in_port_map              => {
            addr_r   => "D_iw_b",
            addr_w   => "R_dst_regnum",
            clk_r    => "clk",
            clk_w    => "clk",
            data_w   => "W_rf_wr_data",
            en_r_n   => qq(1'b0),
            en_w_n   => "~W_rf_wren",
            init_r_n => qq(1'b1),
            init_w_n => qq(1'b1),
            rst_r_n  => "reset_n",
            rst_w_n  => "reset_n"
          },
          out_port_map             => {
            data_r       => "R_rf_b",
            data_r_a     => ""
          },
          parameter_map            => {
            ADDR_WIDTH => $rf_addr_sz,
            WIDTH      => $datapath_sz,
            DEPTH      => $rf_num_reg,
            MEM_MODE   => 2,
            RST_MODE   => 0
          },
        });
    } else {
        nios_sdp_ram->add({
          name => $Opt->{name} . "_register_bank_b",
          Opt                     => $Opt,
          data_width              => $datapath_sz,
          address_width           => $rf_addr_sz,
          num_words               => $rf_num_reg,
          contents_file           => $rf_ram_b_fname,
          ram_block_type          => qq("$Opt->{register_file_ram_type}"),
          port_map                => {
              clock     => "clk",


              data      => "W_rf_wr_data",
              wren      => "W_rf_wren",
              wraddress => "R_dst_regnum",
        

              rdaddress => "D_iw_b",
              q         => "R_rf_b",
            },
        });
    }

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































    e_mux->add ({
    lhs => ["R_src1", $datapath_sz],
      type => "priority",
      table => [
        "(R_ctrl_br & E_valid) | (R_ctrl_retaddr & R_valid)"
            => "{F_pc_plus_one, 2'b00}",
        "(R_ctrl_jmp_direct & E_valid)"   
            => "{D_jmp_direct_target_waddr, 2'b00}",
        "1'b1"              
            => "R_rf_a",
        ],
      });

    e_mux->add ({
      lhs => ["R_src2_lo", $datapath_sz/2],
      type => "priority",
      table => [
        "R_ctrl_force_src2_zero|R_ctrl_hi_imm16"  => "16'b0",
        "R_src2_use_imm"                        => "D_iw_imm16",
        "1'b1"                                  => "R_rf_b[15:0]",
        ],
      });

    e_mux->add ({
      lhs => ["R_src2_hi", $datapath_sz/2],
      type => "priority",
      table => [
        "R_ctrl_force_src2_zero|R_ctrl_unsigned_lo_imm16" => "16'b0",
        "R_ctrl_hi_imm16"                       => "D_iw_imm16",
        "R_src2_use_imm"                        => "{16 {D_iw_imm16[15]}}",
        "1'b1"                                  => "R_rf_b[31:16]",
        ],
      });

    e_assign->adds(
      [["R_src2", $datapath_sz], "{R_src2_hi, R_src2_lo}"],
      );





    e_register->adds(


      {out => ["E_valid", 1],                   in => "R_valid | E_stall",
       enable => "1'b1"},




      {out => ["E_new_inst", 1],                in => "R_valid",
       enable => "1'b1"},


      {out => ["E_src1", $datapath_sz],         in => "R_src1", 
       enable => "1'b1" },
      {out => ["E_src2", $datapath_sz],         in => "R_src2", 
       enable => "1'b1" },




      {out => ["E_invert_arith_src_msb", 1],          
       in => "D_ctrl_alu_signed_comparison & R_valid",
       enable => "1'b1"},




      {out => ["E_alu_sub", 1],          
       in => "D_ctrl_alu_subtract & R_valid",
       enable => "1'b1"},
      );

    e_assign->adds(

      [["E_stall", 1], 
        "E_shift_rot_stall | E_ld_stall | E_st_stall | E_ci_multi_stall"],
      );


    if (nios2_custom_insts::has_multi_insts($Opt->{custom_instructions})) {
        e_register->adds(


          {out => ["E_ci_multi_start", 1], 
           in => "E_ci_multi_start ? 1'b0 : 
             (R_ctrl_custom_multi & R_valid)",
           enable => "1'b1"},




          {out => ["E_ci_multi_clk_en", 1], 
           in => "E_ci_multi_clk_en ? ~E_ci_multi_done : 
             (R_ctrl_custom_multi & R_valid)",
           enable => "1'b1"},
        );

        e_assign->adds(


          ["E_ci_multi_stall", 
            "R_ctrl_custom_multi & E_valid & ~E_ci_multi_done"],
        );
    }






    e_assign->adds(
      [["E_arith_src1", $datapath_sz], 
        "{ E_src1[$datapath_msb] ^ E_invert_arith_src_msb, 
           E_src1[$datapath_msb-1:0]}"],
      [["E_arith_src2", $datapath_sz], 
        "{ E_src2[$datapath_msb] ^ E_invert_arith_src_msb, 
           E_src2[$datapath_msb-1:0]}"],
      );


    e_assign->adds(
      [["E_arith_result", $datapath_sz+1], "E_alu_sub ?
                       E_arith_src1 - E_arith_src2 :
                       E_arith_src1 + E_arith_src2"],
      );


    e_assign->adds(
      [["E_mem_baddr", $mem_baddr_sz], "E_arith_result[$mem_baddr_sz-1:0]"]
      );
 




    e_mux->add ({
      lhs => ["E_logic_result", $datapath_sz],
      selecto => "R_logic_op",
      table => [
        "$logic_op_nor" => "~(E_src1 | E_src2)",    # NOR
        "$logic_op_and" => "  E_src1 & E_src2 ",    # AND
        "$logic_op_or"  => "  E_src1 | E_src2 ",    # OR
        "$logic_op_xor" => "  E_src1 ^ E_src2 ",    # XOR, and br/cmp with eq/ne
        ],
      });

    e_assign->adds(
      [["E_logic_result_is_0", 1], "E_logic_result == 0"],
      );


    e_assign->adds(
      [["E_eq", 1],    "E_logic_result_is_0"],
      [["E_lt", 1],    "E_arith_result[$datapath_msb+1]"],
      );

    e_mux->add({
      lhs   => ["E_cmp_result", 1],
      selecto => "R_compare_op",
      table => [
        "$compare_op_eq"     => "E_eq",
        "$compare_op_ge"     => "~E_lt",
        "$compare_op_lt"     => "E_lt",
        "$compare_op_ne"     => "~E_eq",
       ],
      });









    e_assign->adds(
      [["E_shift_rot_cnt_nxt", $datapath_log2_sz],
        "E_new_inst ? E_src2[$datapath_log2_sz-1:0] : E_shift_rot_cnt-1"],

      [["E_shift_rot_done", 1], "(E_shift_rot_cnt == 0) & ~E_new_inst"],

      [["E_shift_rot_stall", 1], 
        "R_ctrl_shift_rot & E_valid & ~E_shift_rot_done"],


      [["E_shift_rot_fill_bit", 1],
        "R_ctrl_shift_logical ? 1'b0 :
          (R_ctrl_rot_right ? E_shift_rot_result[0] : 
                              E_shift_rot_result[31])"],
      );

    e_mux->add ({
      lhs => ["E_shift_rot_result_nxt", $datapath_sz],
      type => "priority",
      table => [

        "E_new_inst" => "E_src1",


        "R_ctrl_shift_rot_right" => 
          "{E_shift_rot_fill_bit, E_shift_rot_result[$datapath_msb:1]}",


        "1'b1" => 
          "{E_shift_rot_result[$datapath_msb-1:0], E_shift_rot_fill_bit}",
        ],
      });

    e_register->adds(
      {out => ["E_shift_rot_result", $datapath_sz], 
       in => "E_shift_rot_result_nxt", enable => "1'b1"},
      {out => ["E_shift_rot_cnt", $datapath_log2_sz], 
       in => "E_shift_rot_cnt_nxt", enable => "1'b1"},
      );






    my $rdctl_mux_table = [
      $status_reg_regnum    => "W_status_reg",
      $estatus_reg_regnum   => "W_estatus_reg",
      $bstatus_reg_regnum   => "W_bstatus_reg",
      $ienable_reg_regnum   => "W_ienable_reg",
      $ipending_reg_regnum  => "W_ipending_reg",
      $cpuid_reg_regnum     => "W_cpuid_reg",
    ];


    e_mux->add ({
      lhs => ["E_control_rd_data", $max_control_reg_sz],
      selecto => "D_iw_control_regnum",
      table => $rdctl_mux_table,
      });










    e_mux->add({
      lhs   => ["E_alu_result", $datapath_sz],
      type  => "priority",
      table => [
        "R_ctrl_br_cmp | R_ctrl_rdctl_inst"  => "0",
        "R_ctrl_shift_rot"                   => "E_shift_rot_result",
        "R_ctrl_logic"                       => "E_logic_result",
        "R_ctrl_custom"                      => "E_ci_result",
        "1'b1"                               => "E_arith_result",
        ],
      });





    e_assign->adds(
      [["R_stb_data", 8],  "R_rf_b[7:0]"],
      [["R_sth_data", 16], "R_rf_b[15:0]"],
      );



    e_mux->add({
      lhs   => ["E_st_data", $datapath_sz],
      type  => "priority",
      table => [
        "D_mem8"        => "{R_stb_data, R_stb_data, R_stb_data, R_stb_data}",
        "D_mem16"       => "{R_sth_data, R_sth_data}",
        "1'b1"          => "R_rf_b",
      ],
      });
    

    my $E_mem_byte_en_table = $big_endian ?
      [


        "{$iw_memsz_byte, 2'b00}" => "4'b1000",
        "{$iw_memsz_byte, 2'b01}" => "4'b0100",
        "{$iw_memsz_byte, 2'b10}" => "4'b0010",
        "{$iw_memsz_byte, 2'b11}" => "4'b0001",



        "{$iw_memsz_hword, 2'b00}" => "4'b1100",
        "{$iw_memsz_hword, 2'b01}" => "4'b1100",
        "{$iw_memsz_hword, 2'b10}" => "4'b0011",
        "{$iw_memsz_hword, 2'b11}" => "4'b0011",
      ] 
      :
      [


        "{$iw_memsz_byte, 2'b00}" => "4'b0001",
        "{$iw_memsz_byte, 2'b01}" => "4'b0010",
        "{$iw_memsz_byte, 2'b10}" => "4'b0100",
        "{$iw_memsz_byte, 2'b11}" => "4'b1000",



        "{$iw_memsz_hword, 2'b00}" => "4'b0011",
        "{$iw_memsz_hword, 2'b01}" => "4'b0011",
        "{$iw_memsz_hword, 2'b10}" => "4'b1100",
        "{$iw_memsz_hword, 2'b11}" => "4'b1100",
      ]; 

    e_mux->add ({
      lhs => ["E_mem_byte_en", $byte_en_sz],
      selecto => "{D_iw_memsz, E_mem_baddr[1:0]}",
      table => $E_mem_byte_en_table,
      default => "4'b1111",
    });





    e_assign->adds(


      [["d_read_nxt", 1], 
        "(R_ctrl_ld & E_new_inst) | (d_read & d_waitrequest)"],




      [["E_ld_stall", 1], 
        "R_ctrl_ld & ((E_valid & ~av_ld_done) | E_new_inst)"],



      [["d_write_nxt", 1], 
        "(R_ctrl_st & E_new_inst) | (d_write & d_waitrequest)"],


      [["E_st_stall", 1], "d_write_nxt"],



      [["d_address", $mem_baddr_sz], "W_mem_baddr"],


      [["av_ld_getting_data", 1], "d_read & ~d_waitrequest"],
      );

    e_register->adds(
      {out => "d_read",        in => "d_read_nxt",      enable => "1'b1"},
      {out => "d_writedata",   in => "E_st_data",       enable => "1'b1"},
      {out => "d_byteenable",  in => "E_mem_byte_en",   enable => "1'b1"},
      );





    e_assign->adds(










































      [["av_ld_align_cycle_nxt", 2], 
        "av_ld_getting_data ? 0 : (av_ld_align_cycle+1)"],



      [["av_ld_align_one_more_cycle", 1], 
        "av_ld_align_cycle == (D_mem16 ? 2 : 3)"],



      [["av_ld_aligning_data_nxt", 1], 
        "av_ld_aligning_data ? 
          ~av_ld_align_one_more_cycle : 
          (~D_mem32 & av_ld_getting_data)"],



      [["av_ld_waiting_for_data_nxt", 1], 
        "av_ld_waiting_for_data ? 
           ~av_ld_getting_data : 
           (R_ctrl_ld & E_new_inst)"],




      [["av_ld_done", 1], 
        "~av_ld_waiting_for_data_nxt & (D_mem32 | ~av_ld_aligning_data_nxt)"],





      [["av_ld_rshift8", 1], 
        "av_ld_aligning_data & 
         (av_ld_align_cycle < (${big_endian_tilde}W_mem_baddr[1:0]))"],
      [["av_ld_extend", 1], "av_ld_aligning_data"],
      );



    e_assign->adds(






      [["av_ld_byte0_data_nxt", 8], 
        "av_ld_rshift8      ? av_ld_byte1_data :
         av_ld_extend       ? av_ld_byte0_data :
                            d_readdata[7:0]"],

      [["av_ld_byte1_data_nxt", 8], 
        "av_ld_rshift8      ? av_ld_byte2_data :
         av_ld_extend       ? {8 {av_fill_bit}} :
                            d_readdata[15:8]"],

      [["av_ld_byte2_data_nxt", 8], 
        "av_ld_rshift8      ? av_ld_byte3_data :
         av_ld_extend       ? {8 {av_fill_bit}} :
                            d_readdata[23:16]"],

      [["av_ld_byte3_data_nxt", 8], 
        "av_ld_rshift8      ? av_ld_byte3_data :
         av_ld_extend       ? {8 {av_fill_bit}} :
                            d_readdata[31:24]"],




      [["av_ld_byte1_data_en", 1], 
        "~(av_ld_extend & D_mem16 & ~av_ld_rshift8)"],


      [["av_ld_data_aligned_unfiltered", $datapath_sz], 
        "{av_ld_byte3_data, av_ld_byte2_data, 
          av_ld_byte1_data, av_ld_byte0_data}"],



      [["av_sign_bit", 1], 
        "D_mem16 ? av_ld_byte1_data[7] : av_ld_byte0_data[7]"],



      [["av_fill_bit", 1], "av_sign_bit & R_ctrl_ld_signed"],
      );

    e_register->adds(
      {out => ["av_ld_align_cycle", 2],   in => "av_ld_align_cycle_nxt",
       enable => "1'b1"},
      {out => ["av_ld_waiting_for_data", 1], in => "av_ld_waiting_for_data_nxt",
       enable => "1'b1"},
      {out => ["av_ld_aligning_data", 1], in => "av_ld_aligning_data_nxt",
       enable => "1'b1"},


      {out => ["av_ld_byte0_data", 8], in => "av_ld_byte0_data_nxt",
       enable => "1'b1"},
      {out => ["av_ld_byte1_data", 8], in => "av_ld_byte1_data_nxt",
       enable => "av_ld_byte1_data_en"},
      {out => ["av_ld_byte2_data", 8], in => "av_ld_byte2_data_nxt",
       enable => "1'b1"},
      {out => ["av_ld_byte3_data", 8], in => "av_ld_byte3_data_nxt",
       enable => "1'b1"},

      );





    e_register->adds(


      {out => ["W_valid", 1],                       in => "E_valid & ~E_stall",
       enable => "1'b1", ip_debug_visible => 1},

      {out => ["W_control_rd_data", $max_control_reg_sz], 
       in => "E_control_rd_data", enable => "1'b1"},
      {out => ["W_cmp_result", 1],                  in => "E_cmp_result",
       enable => "1'b1"},




      {out => ["W_alu_result", $datapath_sz],       in => "E_alu_result",
       enable => "1'b1"},


      {out => ["W_status_reg_pie", $status_reg_pie_sz],
       in => "W_status_reg_pie_nxt", enable => "1'b1" },
      {out => ["W_estatus_reg", $status_reg_sz],    in => "W_estatus_reg_nxt", 
       enable => "1'b1" },
      {out => ["W_bstatus_reg", $status_reg_sz],    in => "W_bstatus_reg_nxt", 
       enable => "1'b1" },
      {out => ["W_ienable_reg", $interrupt_sz],     in => "W_ienable_reg_nxt", 
       enable => "1'b1" },
      {out => ["W_ipending_reg", $interrupt_sz],    in => "W_ipending_reg_nxt",
       enable => "1'b1" },
      );

    e_assign->adds(
      [["W_cpuid_reg", $max_control_reg_sz], $Opt->{cpuid_value}],
    );

    if ($Opt->{export_pcb}) {

        e_signal->adds(
          {name => "pc", width => $pcb_sz, export => $force_export },
          {name => "pc_valid", width => 1, export => $force_export },
        );

        push(@{$Opt->{port_list}},
          ["pc"         => $pcb_sz, "out" ],
          ["pc_valid"   => 1,       "out" ],
        );


        e_assign->adds(
          ["pc", "F_pcb"],
          ["pc_valid", "W_valid"],
        );
    }







    my $cmp_rdctl_non_zero_sz = $max_control_reg_sz;
    my $cmp_rdctl_non_zero_lsb = 0;
    my $cmp_rdctl_non_zero_msb = 
      $cmp_rdctl_non_zero_lsb + $cmp_rdctl_non_zero_sz - 1;
    my $cmp_rdctl_zero_sz = $datapath_sz - $cmp_rdctl_non_zero_sz;
    my $cmp_rdctl_zero_lsb = $cmp_rdctl_non_zero_msb + 1;
    my $cmp_rdctl_zero_msb = 
      $cmp_rdctl_zero_lsb + $cmp_rdctl_zero_sz - 1;



    e_assign->adds(
      [["W_wr_data_non_zero", $cmp_rdctl_non_zero_sz],
        "R_ctrl_br_cmp ? W_cmp_result :
         R_ctrl_rdctl_inst       ? W_control_rd_data :
            W_alu_result[$cmp_rdctl_non_zero_msb:$cmp_rdctl_non_zero_lsb]"],
      );



    if ($cmp_rdctl_zero_sz > 0) {
        e_assign->adds(
          [["W_wr_data", $datapath_sz], 
            "{ W_alu_result[$cmp_rdctl_zero_msb:$cmp_rdctl_zero_lsb],
               W_wr_data_non_zero }"],
        );
    } else {
        e_assign->adds(
          [["W_wr_data", $datapath_sz], "W_wr_data_non_zero"],
        );
    }

    e_assign->adds(

      [["W_br_taken", 1], "R_ctrl_br & W_cmp_result"],


      [["W_mem_baddr", $mem_baddr_sz], "W_alu_result[$mem_baddr_sz-1:0]"],
      );






    e_assign->adds(
      [["W_status_reg", $status_reg_sz], "W_status_reg_pie"],
      );


    e_assign->adds(
      [["E_wrctl_status", 1], "(R_ctrl_wrctl_inst & 
         (D_iw_control_regnum == $status_reg_regnum))"],
      [["E_wrctl_estatus", 1], "(R_ctrl_wrctl_inst & 
         (D_iw_control_regnum == $estatus_reg_regnum))"],
      [["E_wrctl_bstatus", 1], "(R_ctrl_wrctl_inst & 
         (D_iw_control_regnum == $bstatus_reg_regnum))"],
      [["E_wrctl_ienable", 1], "(R_ctrl_wrctl_inst & 
         (D_iw_control_regnum == $ienable_reg_regnum))"],
      );


    e_assign->adds(

      [["W_status_reg_pie_inst_nxt", $status_reg_pie_sz],
        "(R_ctrl_exception | R_ctrl_break | R_ctrl_crst) ? 1'b0 :
         (D_op_eret)                     ? W_estatus_reg[$status_reg_pie_lsb] :
         (D_op_bret)                     ? W_bstatus_reg[$status_reg_pie_lsb] :
         (E_wrctl_status)                ? E_src1[$status_reg_pie_lsb] :
                                           W_status_reg_pie"],



      [["W_status_reg_pie_nxt", $status_reg_pie_sz],
        "E_valid ? W_status_reg_pie_inst_nxt : W_status_reg_pie"],

      [["W_estatus_reg_inst_nxt", $status_reg_sz],
        "(R_ctrl_crst)        ? 0 :
         (R_ctrl_exception)   ? W_status_reg :
         (E_wrctl_estatus)    ? E_src1[$status_reg_msb:$status_reg_lsb] :
                                W_estatus_reg"],
      [["W_estatus_reg_nxt", $status_reg_sz],
        "E_valid ? W_estatus_reg_inst_nxt : W_estatus_reg"],

      [["W_bstatus_reg_inst_nxt", $status_reg_sz],
        "(R_ctrl_break)       ? W_status_reg :
         (E_wrctl_bstatus)    ? E_src1[$status_reg_msb:$status_reg_lsb] :
                                W_bstatus_reg"],
      [["W_bstatus_reg_nxt", $status_reg_sz],
        "E_valid ? W_bstatus_reg_inst_nxt : W_bstatus_reg"],

      [["W_ienable_reg_nxt", $interrupt_sz],
        "((E_wrctl_ienable & E_valid) ? 
          E_src1[$interrupt_sz-1:0] : W_ienable_reg) & " .
          $Opt->{internal_irq_mask_bin}],
      
      [["W_ipending_reg_nxt", $interrupt_sz],
        "iactive & W_ienable_reg & oci_ienable & " . 
        $Opt->{internal_irq_mask_bin}],
      );

    if (! $debugger_present) { 

      e_assign->adds(
        [["oci_ienable", 32, 0, 1], "{32{1'b1}}"],
      );
    } # otherwise, the oci_ienable signal will come from the OCI.

    if ($debugger_present || $hbreak_test_bench) { 




      e_register->adds(
        { out => ["hbreak_enabled", 1], 
          in => "R_ctrl_break ? 1'b0 : D_op_bret ? 1'b1 : hbreak_enabled",
          enable => "E_valid", 
          async_value => "1'b1"
        },
      );
    } 

    if (!manditory_bool($Opt, "simgen")) {
        make_potential_tb_logic($Opt);
    }




    create_ptf_signal_list($Opt);
}
   
sub
create_ptf_signal_list
{
    my ($Opt) = @_;

    my @common = (
        { divider => "common" },
        { radix => "x", signal => "clk" },
        { radix => "x", signal => "reset_n" },
        { radix => "x", signal => "F_pcb_nxt" },
        { radix => "x", signal => "F_pcb" },
        { radix => "a", signal => "F_vinst" },
        { radix => "a", signal => "D_vinst" },
        { radix => "a", signal => "R_vinst" },
        { radix => "a", signal => "E_vinst" },
        { radix => "a", signal => "W_vinst" },
        { radix => "x", signal => "F_valid" },
        { radix => "x", signal => "D_valid" },
        { radix => "x", signal => "R_valid" },
        { radix => "x", signal => "E_valid" },
        { radix => "x", signal => "W_valid" },
        { radix => "x", signal => "D_wr_dst_reg" },
        { radix => "x", signal => "D_dst_regnum" },
        { radix => "x", signal => "W_wr_data" },
        { radix => "x", signal => "F_iw" },
        { radix => "x", signal => "D_iw" },
    );

    my @ci_always = (
        { divider => "custom_instruction" },
        { radix => "x", signal => "R_ctrl_custom" },
        { radix => "x", signal => "R_ctrl_custom_multi" },
        { radix => "x", signal => "E_ci_dataa" },
        { radix => "x", signal => "E_ci_datab" },
        { radix => "x", signal => "W_ipending_reg" },
        { radix => "x", signal => "W_status_reg" },
        { radix => "x", signal => "W_estatus_reg" },
        { radix => "x", signal => "D_ci_n" },
        { radix => "x", signal => "D_ci_readra" },
        { radix => "x", signal => "D_ci_readrb" },
        { radix => "x", signal => "D_ci_writerc" },
        { radix => "x", signal => "E_ci_result" },
    );

    my @ci_multi = (
        { radix => "x", signal => "E_ci_multi_clk_en" },
        { radix => "x", signal => "E_ci_multi_start" },
        { radix => "x", signal => "E_ci_multi_done" },
        { radix => "x", signal => "E_ci_multi_stall" },
    );

    my @full = (
        { divider => "i_master" },
        { radix => "x", signal => "i_read" },
        { radix => "x", signal => "i_waitrequest" },
        { radix => "x", signal => "i_address" },
        { radix => "x", signal => "i_readdata" },
        { divider => "npc_mux" },
        { radix => "x", signal => "R_ctrl_exception" },
        { radix => "x", signal => "R_ctrl_break" },
        { radix => "x", signal => "W_br_taken" },
        { radix => "x", signal => "R_ctrl_uncond_cti_non_br" },
        { radix => "x", signal => "F_pc_sel_nxt" },
        { radix => "x", signal => "F_pcb_nxt" },
        { radix => "x", signal => "E_arith_result" },
        { radix => "x", signal => "F_pcb_plus_four" },
        { radix => "x", signal => "F_pc_en" },
        { radix => "x", signal => "W_valid" },
        { divider => "interrupts" },
        { radix => "x", signal => "W_status_reg_pie" },
        { radix => "x", signal => "W_ienable_reg" },
        { radix => "x", signal => "d_irq" },
        { radix => "x", signal => "intr_req" },
        { divider => "rf" },
        { radix => "x", signal => "D_iw_a" },
        { radix => "x", signal => "D_iw_b" },
        { radix => "x", signal => "D_ctrl_b_is_dst" },
        { radix => "x", signal => "D_ctrl_ignore_dst" },
        { radix => "x", signal => "D_ctrl_src2_choose_imm" },
        { radix => "x", signal => "D_dst_regnum" },
        { radix => "x", signal => "R_rf_a" },
        { radix => "x", signal => "R_rf_b" },
        { radix => "x", signal => "R_src1" },
        { radix => "x", signal => "R_src2_use_imm" },
        { radix => "x", signal => "R_src2_lo" },
        { radix => "x", signal => "R_src2_hi" },
        { radix => "x", signal => "R_src2" },
        { radix => "x", signal => "R_wr_dst_reg" },
        { radix => "x", signal => "R_dst_regnum" },
        { radix => "x", signal => "W_rf_wren" },
        { radix => "x", signal => "W_rf_wr_data" },
        { radix => "x", signal => "W_cmp_result" },
        { radix => "x", signal => "av_ld_done" },
        { radix => "x", signal => "av_ld_data_aligned_unfiltered" },
        { radix => "x", signal => "av_ld_data_aligned_filtered" },
        { divider => "alu" },
        { radix => "x", signal => "clk" },
        { radix => "x", signal => "E_arith_src1" },
        { radix => "x", signal => "E_arith_src2" },
        { radix => "x", signal => "D_ctrl_alu_signed_comparison" },
        { radix => "x", signal => "E_invert_arith_src_msb" },
        { radix => "x", signal => "D_ctrl_alu_subtract" },
        { radix => "x", signal => "E_alu_sub" },
        { radix => "x", signal => "E_arith_result" },
        { radix => "x", signal => "E_logic_result" },
        { radix => "x", signal => "R_compare_op" },
        { radix => "x", signal => "E_cmp_result" },
        { radix => "x", signal => "E_alu_result" },
        { radix => "x", signal => "E_control_rd_data" },
        { radix => "x", signal => "E_shift_rot_result" },
        { radix => "x", signal => "R_ctrl_br_cmp" },
        { radix => "x", signal => "R_ctrl_logic" },
        { radix => "x", signal => "R_ctrl_rdctl_inst" },
        { divider => "store" },
        { radix => "x", signal => "R_ctrl_st" },
        { radix => "x", signal => "E_valid" },
        { radix => "x", signal => "E_st_data" },
        { radix => "x", signal => "E_mem_byte_en" },
        { divider => "load_data" },
        { radix => "x", signal => "R_ctrl_ld" },
        { radix => "x", signal => "R_ctrl_ld_signed" },
        { radix => "x", signal => "E_mem_baddr" },
        { radix => "x", signal => "av_ld_data_aligned_unfiltered" },
        { radix => "x", signal => "av_ld_data_aligned_filtered" },
        { divider => "load_aligner" },
        { radix => "x", signal => "av_ld_align_cycle" },
        { radix => "x", signal => "av_ld_align_one_more_cycle" },
        { radix => "x", signal => "av_ld_aligning_data" },
        { radix => "x", signal => "av_ld_waiting_for_data" },
        { radix => "x", signal => "av_ld_done" },
        { radix => "x", signal => "av_ld_rshift8" },
        { radix => "x", signal => "av_ld_extend" },
        { radix => "x", signal => "av_ld_byte1_data_en" },
        { radix => "x", signal => "av_ld_data_aligned_unfiltered" },
        { radix => "x", signal => "av_ld_data_aligned_filtered" },
        { radix => "x", signal => "av_sign_bit" },
        { radix => "x", signal => "av_fill_bit" },
        { divider => "d_master" },
        { radix => "x", signal => "av_ld_getting_data" },
        { radix => "x", signal => "av_ld_aligning_data" },
        { radix => "x", signal => "av_ld_done" },
        { radix => "x", signal => "E_ld_stall" },
        { radix => "x", signal => "E_st_stall" },
        { radix => "x", signal => "d_read" },
        { radix => "x", signal => "d_write" },
        { radix => "x", signal => "d_address" },
        { radix => "x", signal => "d_waitrequest" },
        { radix => "x", signal => "d_readdata" },
        { radix => "x", signal => "av_ld_data_aligned_unfiltered" },
        { radix => "x", signal => "av_ld_data_aligned_filtered" },
        { radix => "x", signal => "d_writedata" },
        { radix => "x", signal => "d_byteenable" },
        { divider => "shift_rotate" },
        { radix => "x", signal => "R_ctrl_shift_rot" },
        { radix => "x", signal => "R_ctrl_shift_logical " },
        { radix => "x", signal => "R_ctrl_rot_right" },
        { radix => "x", signal => "R_ctrl_shift_rot_right" },
        { radix => "x", signal => "E_shift_rot_done" },
        { radix => "x", signal => "E_shift_rot_stall" },
        { radix => "x", signal => "E_shift_rot_fill_bit" },
        { radix => "x", signal => "E_shift_rot_cnt_nxt" },
        { radix => "x", signal => "E_shift_rot_cnt" },
        { radix => "x", signal => "E_shift_rot_result_nxt" },
        { radix => "x", signal => "E_shift_rot_result" },
        { divider => "control_registers" },
        { radix => "x", signal => "D_iw_control_regnum" },
        { radix => "x", signal => "E_control_rd_data" },
        { radix => "x", signal => "R_ctrl_rdctl_inst" },
        { radix => "x", signal => "E_valid" },
        { radix => "x", signal => "E_wrctl_status" },
        { radix => "x", signal => "E_wrctl_estatus" },
        { radix => "x", signal => "E_wrctl_bstatus" },
        { radix => "x", signal => "E_wrctl_ienable" },
        { radix => "x", signal => "R_ctrl_exception" },
        { radix => "x", signal => "D_op_intr" },
        { radix => "x", signal => "D_op_trap" },
        { radix => "x", signal => "D_op_break" },
        { radix => "x", signal => "D_op_hbreak" },
        { radix => "x", signal => "D_op_eret" },
        { radix => "x", signal => "D_op_bret" },
        { radix => "x", signal => "E_src1" },
        { radix => "x", signal => "W_status_reg" },
        { radix => "x", signal => "W_estatus_reg" },
        { radix => "x", signal => "W_bstatus_reg" },
        { radix => "x", signal => "W_ienable_reg" },
        { radix => "x", signal => "W_ipending_reg" },
    );

    my @hbreak = (
        { divider => "breaks" },
        { radix => "x", signal => "hbreak_req" },
        { radix => "x", signal => "oci_hbreak_req" },
        { radix => "x", signal => "hbreak_enabled" },
        { radix => "x", signal => "wait_for_one_post_bret_inst" },
    );

    my @cpu_reset = (
        { divider => "cpu_reset" },
        { radix => "x", signal => "cpu_resetrequest" },
        { radix => "x", signal => "cpu_resettaken" },
        { radix => "x", signal => "R_ctrl_crst" },
    );

    push(@plaintext_wave_signals, @common);

    if ($debugger_present) {
        push(@plaintext_wave_signals, @hbreak);
    }

    if ($cpu_reset) {
        push(@plaintext_wave_signals, @cpu_reset);
    }

    if (nios2_custom_insts::has_insts($Opt->{custom_instructions})) {
        push(@plaintext_wave_signals, @ci_always);
    }

    if (nios2_custom_insts::has_multi_insts($Opt->{custom_instructions})) {
        push(@plaintext_wave_signals, @ci_multi);
    }

    if ($Opt->{full_waveform_signals}) {
        push(@plaintext_wave_signals, @full);
    }
}




sub 
make_potential_tb_logic
{
    my $Opt = shift;

    e_register->adds(
      {out => ["d_write", 1, $force_export], in => "d_write_nxt",    
       enable => "1'b1"},
    );
}


1;
