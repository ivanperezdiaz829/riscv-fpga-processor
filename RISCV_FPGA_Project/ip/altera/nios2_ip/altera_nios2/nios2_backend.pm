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






















package nios2_backend;
use Exporter;
@ISA = Exporter;
@EXPORT = qw(
    &be_make_custom_instruction_master
    &be_make_alu
    &be_make_stdata
    &be_make_hbreak
    &be_make_cpu_reset
);

use europa_all;
use europa_utils;
use e_custom_instruction_master;
use cpu_utils;
use cpu_wave_signals;
use nios_europa;
use nios_avalon_masters;
use nios_common;
use nios_isa;
use nios2_isa;
use nios2_control_regs;
use nios2_insts;
use nios2_common;
use nios2_custom_insts;
use strict;









sub be_make_custom_instruction_master
{
    my $Opt = shift;

    my $whoami = "custom instruction master";

    my $cs = not_empty_scalar($Opt, "ci_combo_stage");
    my $ms = not_empty_scalar($Opt, "ci_multi_stage");
    my $control_reg_stage = not_empty_scalar($Opt, "control_reg_stage");

    my $ci_ports = 
        {
            clk      => "clk",
        };

    if ($cs eq $ms) {

        &$error("Must have different combo and multi custom instruciton stages");
    } else {

        if (nios2_custom_insts::has_combo_insts($Opt->{custom_instructions})) {
            e_signal->adds(
              {name => "${cs}_ci_combo_result", width => $datapath_sz },
            );
    

            $ci_ports->{"${cs}_ci_combo_dataa"} = "combo_dataa";
            $ci_ports->{"${cs}_ci_combo_datab"} = "combo_datab";
            $ci_ports->{"${cs}_ci_combo_ipending"} = "combo_ipending";
            $ci_ports->{"${cs}_ci_combo_status"} = "combo_status";
            $ci_ports->{"${cs}_ci_combo_estatus"} = "combo_estatus";
            $ci_ports->{"${cs}_ci_combo_n"} = "combo_n";
            $ci_ports->{"${cs}_ci_combo_a"} = "combo_a";
            $ci_ports->{"${cs}_ci_combo_b"} = "combo_b";
            $ci_ports->{"${cs}_ci_combo_c"} = "combo_c";
            $ci_ports->{"${cs}_ci_combo_readra"} = "combo_readra";
            $ci_ports->{"${cs}_ci_combo_readrb"} = "combo_readrb";
            $ci_ports->{"${cs}_ci_combo_writerc"} = "combo_writerc";
            $ci_ports->{"${cs}_ci_combo_result"} = "combo_result";
    

            e_assign->adds(
              [["${cs}_ci_combo_dataa", $datapath_sz], "${cs}_src1"],
              [["${cs}_ci_combo_datab", $datapath_sz], "${cs}_src2"],
              [["${cs}_ci_combo_ipending", $interrupt_sz], 
                "${control_reg_stage}_ipending_reg"],
              [["${cs}_ci_combo_status", $status_reg_sz], 
                "${control_reg_stage}_status_reg"],
              [["${cs}_ci_combo_estatus", $status_reg_sz], 
                "${control_reg_stage}_estatus_reg"],
              [["${cs}_ci_combo_n", $iw_custom_n_sz], "${cs}_iw_custom_n"],
              [["${cs}_ci_combo_a", $iw_a_sz], "${cs}_iw_a"],
              [["${cs}_ci_combo_b", $iw_b_sz], "${cs}_iw_b"],
              [["${cs}_ci_combo_c", $iw_c_sz], "${cs}_iw_c"],
              [["${cs}_ci_combo_readra", 1], "${cs}_iw_custom_readra"],
              [["${cs}_ci_combo_readrb", 1], "${cs}_iw_custom_readrb"],
              [["${cs}_ci_combo_writerc", 1], "${cs}_iw_custom_writerc"],
            );
    

            push(@{$Opt->{port_list}},
              ["${cs}_ci_combo_dataa"   => $datapath_sz,        "out" ],
              ["${cs}_ci_combo_datab"   => $datapath_sz,        "out" ],
              ["${cs}_ci_combo_ipending"=> $interrupt_sz,       "out" ],
              ["${cs}_ci_combo_status"  => $status_reg_sz,      "out" ],
              ["${cs}_ci_combo_estatus" => $status_reg_sz,      "out" ],
              ["${cs}_ci_combo_n"       => $iw_custom_n_sz,     "out" ],
              ["${cs}_ci_combo_a"       => $iw_a_sz,            "out" ],
              ["${cs}_ci_combo_b"       => $iw_b_sz,            "out" ],
              ["${cs}_ci_combo_c"       => $iw_c_sz,            "out" ],
              ["${cs}_ci_combo_readra"  => 1,                   "out" ],
              ["${cs}_ci_combo_readrb"  => 1,                   "out" ],
              ["${cs}_ci_combo_writerc" => 1,                   "out" ],
              ["${cs}_ci_combo_result"  => $datapath_sz,        "in"  ],
            );
    
            my @ci_combo = (
                { divider => "combinatorial_custom_instruction" },
                { radix => "x", signal => "${cs}_ctrl_custom_combo" },
                { radix => "x", signal => "${cs}_ci_combo_dataa" },
                { radix => "x", signal => "${cs}_ci_combo_datab" },
                { radix => "x", signal => "${cs}_ci_combo_ipending" },
                { radix => "x", signal => "${cs}_ci_combo_status" },
                { radix => "x", signal => "${cs}_ci_combo_estatus" },
                { radix => "x", signal => "${cs}_ci_combo_n" },
                { radix => "x", signal => "${cs}_ci_combo_readra" },
                { radix => "x", signal => "${cs}_ci_combo_readrb" },
                { radix => "x", signal => "${cs}_ci_combo_writerc" },
                { radix => "x", signal => "${cs}_ci_combo_result" },
            );
    
            push(@plaintext_wave_signals, @ci_combo);
        }
    
        if (nios2_custom_insts::has_multi_insts($Opt->{custom_instructions})) {

            $ci_ports->{"${ms}_ci_multi_dataa"} = "multi_dataa";
            $ci_ports->{"${ms}_ci_multi_datab"} = "multi_datab";
            $ci_ports->{"${ms}_ci_multi_ipending"} = "multi_ipending";
            $ci_ports->{"${ms}_ci_multi_status"} = "multi_status";
            $ci_ports->{"${ms}_ci_multi_estatus"} = "multi_estatus";
            $ci_ports->{"${ms}_ci_multi_n"} = "multi_n";
            $ci_ports->{"${ms}_ci_multi_a"} = "multi_a";
            $ci_ports->{"${ms}_ci_multi_b"} = "multi_b";
            $ci_ports->{"${ms}_ci_multi_c"} = "multi_c";
            $ci_ports->{"${ms}_ci_multi_readra"} = "multi_readra";
            $ci_ports->{"${ms}_ci_multi_readrb"} = "multi_readrb";
            $ci_ports->{"${ms}_ci_multi_writerc"} = "multi_writerc";
            $ci_ports->{"${ms}_ci_multi_result"} = "multi_result";
            $ci_ports->{"${ms}_ci_multi_clk_en"} = "multi_clk_en";
            $ci_ports->{"${ms}_ci_multi_clock"} = "multi_clk";
            $ci_ports->{"${ms}_ci_multi_reset"} = "multi_reset";
            $ci_ports->{"${ms}_ci_multi_start"} = "multi_start";
            $ci_ports->{"${ms}_ci_multi_done"} = "multi_done";
            $ci_ports->{"${ms}_ci_multi_reset_req"} = "reset_req";
    

            e_assign->adds(
              [["${ms}_ci_multi_dataa", $datapath_sz], "${ms}_ci_multi_src1"],
              [["${ms}_ci_multi_datab", $datapath_sz], "${ms}_ci_multi_src2"],
              [["${ms}_ci_multi_ipending", $interrupt_sz],
                "${ms}_ci_multi_ipending"],
              [["${ms}_ci_multi_status", $status_reg_sz],
                "${ms}_ci_multi_status"],
              [["${ms}_ci_multi_estatus", $status_reg_sz],
                "${ms}_ci_multi_estatus"],
              [["${ms}_ci_multi_n", $iw_custom_n_sz], "${ms}_iw_custom_n"],
              [["${ms}_ci_multi_a", $iw_a_sz], "${ms}_iw_a"],
              [["${ms}_ci_multi_b", $iw_b_sz], "${ms}_iw_b"],
              [["${ms}_ci_multi_c", $iw_c_sz], "${ms}_iw_c"],
              [["${ms}_ci_multi_readra", 1], "${ms}_iw_custom_readra"],
              [["${ms}_ci_multi_readrb", 1], "${ms}_iw_custom_readrb"],
              [["${ms}_ci_multi_writerc", 1], "${ms}_iw_custom_writerc"],
            );
    

            push(@{$Opt->{port_list}},
              ["${ms}_ci_multi_dataa"   => $datapath_sz,        "out" ],
              ["${ms}_ci_multi_datab"   => $datapath_sz,        "out" ],
              ["${ms}_ci_multi_ipending"=> $interrupt_sz,       "out" ],
              ["${ms}_ci_multi_status"  => $status_reg_sz,      "out" ],
              ["${ms}_ci_multi_estatus" => $status_reg_sz,      "out" ],
              ["${ms}_ci_multi_n"       => $iw_custom_n_sz,     "out" ],
              ["${ms}_ci_multi_a"       => $iw_a_sz,            "out" ],
              ["${ms}_ci_multi_b"       => $iw_b_sz,            "out" ],
              ["${ms}_ci_multi_c"       => $iw_c_sz,            "out" ],
              ["${ms}_ci_multi_readra"  => 1,    "out" ],
              ["${ms}_ci_multi_readrb"  => 1,    "out" ],
              ["${ms}_ci_multi_writerc" => 1,    "out" ],
              ["${ms}_ci_multi_result"  => $datapath_sz,        "in"  ],
              ["${ms}_ci_multi_clk_en"  => 1,                   "out" ],
              ["${ms}_ci_multi_start"   => 1,                   "out" ],
              ["${ms}_ci_multi_done"    => 1,                   "in"  ],
            );
    
            my @ci_multi = (
                { divider => "multicycle_custom_instruction" },
                { radix => "x", signal => "${ms}_ctrl_custom_multi" },
                { radix => "x", signal => "${ms}_ci_multi_dataa" },
                { radix => "x", signal => "${ms}_ci_multi_datab" },
                { radix => "x", signal => "${ms}_ci_multi_ipending" },
                { radix => "x", signal => "${ms}_ci_multi_status" },
                { radix => "x", signal => "${ms}_ci_multi_estatus" },
                { radix => "x", signal => "${ms}_ci_multi_n" },
                { radix => "x", signal => "${ms}_ci_multi_readra" },
                { radix => "x", signal => "${ms}_ci_multi_readrb" },
                { radix => "x", signal => "${ms}_ci_multi_writerc" },
                { radix => "x", signal => "${ms}_ci_multi_result" },
                { radix => "x", signal => "${ms}_ci_multi_clk_en" },
                { radix => "x", signal => "${ms}_ci_multi_start" },
                { radix => "x", signal => "${ms}_ci_multi_done" },
                { radix => "x", signal => "${ms}_ci_multi_stall" },
            );
    
            push(@plaintext_wave_signals, @ci_multi);
        }
    }


    e_custom_instruction_master->add ({
        name     => "custom_instruction_master",
        type_map => $ci_ports,
    });
}




sub be_make_alu
{
    my ($Opt) = @_;

    my $whoami = "ALU";

    my $rdctl_stage = not_empty_scalar($Opt, "rdctl_stage");





    e_assign->adds(

      [["E_arith_src1", $datapath_sz], 
        "{ E_src1[$datapath_msb] ^ E_ctrl_alu_signed_comparison, 
           E_src1[$datapath_msb-1:0]}"],
      [["E_arith_src2", $datapath_sz], 
        "{ E_src2[$datapath_msb] ^ E_ctrl_alu_signed_comparison, 
           E_src2[$datapath_msb-1:0]}"],



      [["E_arith_result", $datapath_sz+1],
        "E_ctrl_alu_subtract ?
                       E_arith_src1 - E_arith_src2 :
                       E_arith_src1 + E_arith_src2"],


      [["E_mem_baddr", $mem_baddr_sz], "E_arith_result[$mem_baddr_sz-1:0]"],




      [["E_mem_baddr_corrupt", 1], "E_src1_corrupt"],
    );

    e_register->adds(
      { out => ["M_mem_baddr_corrupt", 1, 0, $force_never_export], 
        in => "E_mem_baddr_corrupt",
        enable => "M_en", },
    );
 




    e_mux->add ({
      lhs => ["E_logic_result", $datapath_sz],
      selecto => "E_logic_op",
      table => [
        "$logic_op_nor" => "~(E_src1 | E_src2)",    # NOR
        "$logic_op_and" => "  E_src1 & E_src2 ",    # AND
        "$logic_op_or"  => "  E_src1 | E_src2 ",    # OR
        "$logic_op_xor" => "  E_src1 ^ E_src2 ",    # XOR, and br/cmp with eq/ne
        ],
      });






    e_assign->adds(
      [["E_eq", 1],    "E_src1_eq_src2"],
      [["E_lt", 1],    "E_arith_result[$datapath_msb+1]"],
      );

    e_mux->add({
      lhs   => ["E_cmp_result", 1],
      selecto => "E_compare_op",
      table => [
        "$compare_op_eq"     => "E_eq",
        "$compare_op_ge"     => "~E_lt",
        "$compare_op_lt"     => "E_lt",
        "$compare_op_ne"     => "~E_eq",
       ],
      });

    e_assign->adds(
      [["E_br_result", 1], "E_cmp_result"],
    );







    my $alu_result_mux_table = [];

    push(@$alu_result_mux_table,
      "E_ctrl_cmp"          => "E_cmp_result",
    );

    if ($rdctl_stage eq "E") {
        push(@$alu_result_mux_table,
          "E_ctrl_rdctl_inst"            => "E_rdctl_data",
        );
    }

    push(@$alu_result_mux_table,
      "E_ctrl_logic"                     => "E_logic_result",
      "E_ctrl_retaddr"                   => "{E_extra_pc, 2'b00}",
    );
    
    if (nios2_custom_insts::has_combo_insts($Opt->{custom_instructions})) {
      push(@$alu_result_mux_table,
        "E_ctrl_custom_combo"            => "E_ci_combo_result",
      );
    }

    e_mux->add({
      lhs   => ["E_alu_result", $datapath_sz],
      type  => "and_or",
      table => $alu_result_mux_table,
      default => "E_arith_result[$datapath_msb:0]",
      });

    my @alu = (
        { divider => "alu" },
        { radix => "x", signal => "clk" },
        { radix => "x", signal => "E_src1" },
        { radix => "x", signal => "E_src2" },
        { radix => "x", signal => "E_arith_src1" },
        { radix => "x", signal => "E_arith_src2" },
        { radix => "x", signal => "E_ctrl_alu_signed_comparison" },
        { radix => "x", signal => "E_arith_result" },
        { radix => "x", signal => "E_logic_result" },
        { radix => "x", signal => "E_compare_op" },
        { radix => "x", signal => "E_cmp_result" },
        { radix => "x", signal => "E_alu_result" },
        { radix => "x", signal => "E_ctrl_cmp" },
        { radix => "x", signal => "E_ctrl_logic" },
        { radix => "x", signal => "E_ctrl_retaddr" },
      );

    if ($Opt->{full_waveform_signals}) {
        push(@plaintext_wave_signals, @alu);
    }
}




sub be_make_stdata
{
    my ($Opt) = @_;






    my $be8 = manditory_bool($Opt, "be8");
    if ($be8 == 1) {
      e_assign->adds(
        [["E_sth_data", 16], "{E_src2_reg[7:0],E_src2_reg[15:8]}"],
        [["E_stw_data", 32], "{E_src2_reg[7:0],E_src2_reg[15:8],
           E_src2_reg[23:16],E_src2_reg[31:24]}"],
        );
    } else {
      e_assign->adds(
        [["E_sth_data", 16], "E_src2_reg[15:0]"],
        [["E_stw_data", 32], "E_src2_reg[31:0]"],
        );
    }

    e_assign->adds(
       [["E_stb_data", 8],  "E_src2_reg[7:0]"],
    );


    if (!$dtcm_present) {


        e_mux->add({
          lhs   => ["E_st_data", $datapath_sz],
          type  => "priority",
          table => [
            "E_mem8"    => "{E_stb_data, E_stb_data, E_stb_data, E_stb_data}",
            "E_mem16"   => "{E_sth_data, E_sth_data}",
            "1'b1"      => "E_stw_data",
          ],
          });
    } else {



        e_mux->add({
          lhs   => ["E_st_data", $datapath_sz],
          selecto => "E_iw_memsz",
          table => [
            "$iw_memsz_byte"  => 
              "{E_stb_data, E_stb_data, E_stb_data, E_stb_data}",
            "$iw_memsz_hword" => 
              "{E_sth_data, E_sth_data}",
            ],
          default => "E_stw_data",
          });
    }


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
      selecto => "{E_iw_memsz, E_mem_baddr[1:0]}",
      table => $E_mem_byte_en_table,
      default => "4'b1111",
      });
}




sub be_make_hbreak
{
    my ($Opt) = @_;

    my $whoami = "hbreak";

    my $cs = not_empty_scalar($Opt, "control_reg_stage");























    if ($hbreak_present) {







        if ($advanced_exc) {
            e_assign->adds(
              [["hbreak_enabled", 1, 0, 1],"~W_debug_mode"],
            );
        } else {
            e_register->adds(
              { out => ["hbreak_enabled", 1], 
                in => "M_ctrl_break ? 1'b0 : M_op_bret ? 1'b1 : hbreak_enabled",
                enable => "M_valid & M_en", 
                async_value => "1'b1"
              },
            );
        }

        if ($hbreak_test_bench) { 
            e_assign->adds(
              [["oci_tb_hbreak_req", 1, 0, 1],"(test_hbreak_req)"],
              [["oci_single_step_mode", 1, 0, 1],"1'b0"], 
            );
        } elsif (!$advanced_exc) {
            e_assign->adds(
              [["oci_tb_hbreak_req", 1, 0, 1],"oci_hbreak_req"],
            );
        } else {   #advanced exception
            e_assign->adds(
              [["oci_tb_hbreak_req", 1, 0, 1],"oci_async_hbreak_req"],
            );
        }
    
        if ($advanced_exc) {





          e_assign->adds(
            [["hbreak_req", 1], 
               "(oci_tb_hbreak_req | latched_oci_tb_hbreak_req) 
                 & hbreak_enabled
                 & (~wait_for_one_post_bret_inst | ~one_post_bret_inst_n)"],
          );

          if ($hbreak_test_bench) { 
            e_assign->adds(

              [["E_hbreak_req", 1], "(hbreak_req)"],
            );
          } else {
            e_assign->adds(


              [["E_hbreak_req", 1], "(hbreak_req | oci_sync_hbreak_req)"],
            );
          }

          e_assign->adds(






            [["latched_oci_tb_hbreak_req_next", 1], 
              "latched_oci_tb_hbreak_req ? hbreak_enabled 
                                      : (hbreak_req)"],
          );
        } else {
          e_assign->adds(
            [["hbreak_req", 1], 
               "(oci_tb_hbreak_req | latched_oci_tb_hbreak_req) 
                 & hbreak_enabled   
                 & ~(wait_for_one_post_bret_inst)"],


            [["E_hbreak_req", 1], "hbreak_req & 
                                   ~(E_op_hbreak & E_valid_prior_to_hbreak)"],
          );
          e_assign->adds(






            [["latched_oci_tb_hbreak_req_next", 1], 
              "latched_oci_tb_hbreak_req ? 
                  hbreak_enabled : 
                  (hbreak_req & E_valid_prior_to_hbreak)"],
          );
        }

        e_register->adds(
          { out => ["latched_oci_tb_hbreak_req", 1, 0, 1], 
            in => "latched_oci_tb_hbreak_req_next",
            enable => "1'b1", 
            async_value => "1'b0"
          },
        );




















        
        if ($advanced_exc) {
            e_assign->add(
              [["one_post_bret_inst_n", 1, 0, 1],
                 "(oci_single_step_mode & 
                    (~hbreak_enabled | ~(M_valid | A_exc_any_active)))"],
            );
            e_register->adds(
              { out => ["wait_for_one_post_bret_inst", 1, 0, 1], 
                in => "(~hbreak_enabled & oci_single_step_mode) ? 1'b1 
                        : ((~one_post_bret_inst_n) | 
                           (~oci_single_step_mode))             ? 1'b0 
                        : wait_for_one_post_bret_inst",
                enable => "1'b1", 
                async_value => "1'b0"
              },
            )
        } else {
            e_register->adds(
              { out => ["wait_for_one_post_bret_inst", 1, 0, 1], 
                in => "(~hbreak_enabled & oci_single_step_mode) ? 1'b1 
                        : ((E_en & E_valid_prior_to_hbreak) | 
                           (~oci_single_step_mode))             ? 1'b0 
                        : wait_for_one_post_bret_inst",
                enable => "1'b1", 
                async_value => "1'b0"
              },
            )
        }
    } else {


      e_assign->adds(
        [["hbreak_enabled", 1, 0, $force_never_export],             "1'b0"],
        [["hbreak_req", 1, 0, $force_never_export],                 "1'b0"],
        [["latched_oci_tb_hbreak_req", 1, 0, $force_never_export],  "1'b0"],
        [["E_hbreak_req", 1, 0, $force_never_export],               "1'b0"],
      );
    }

    if ($debugger_present) {
        my @hbreak_waves = (
            { divider => "hbreak" },
            { radix => "x", signal => "hbreak_req" },
            { radix => "x", signal => "hbreak_enabled" },
            { radix => "x", signal => "wait_for_one_post_bret_inst" },
            { radix => "x", signal => "E_pc" },
        );
        my @break_signals;
        if ($advanced_exc) {
          push(@break_signals,
            { radix => "x", signal => "oci_async_hbreak_req" },
            { radix => "x", signal => "oci_sync_hbreak_req" },
           );
        } else {
          push(@break_signals,
            { radix => "x", signal => "oci_hbreak_req" },
           );
        }
        push(@hbreak_waves, @break_signals); 
    }
}




sub be_make_cpu_reset
{
    my ($Opt) = @_;

    my $whoami = "cpu_reset";

    my $crst_taken = not_empty_scalar($Opt, "crst_taken");


    e_signal->adds(
      {name => "cpu_resettaken",   width => 1, export => $force_export },
    );


    e_assign->add(["cpu_resettaken", $crst_taken]);
    
    push(@{$Opt->{port_list}},
      ["cpu_resetrequest" => 1, "in" ],
      ["cpu_resettaken"   => 1, "out" ],
    );

    my @cpu_reset_waves = (
        { divider => "cpu_reset" },
        { radix => "x", signal => "cpu_resetrequest" },
        { radix => "x", signal => "cpu_resettaken" },
    );
   
    push(@plaintext_wave_signals, @cpu_reset_waves);
}

1;
