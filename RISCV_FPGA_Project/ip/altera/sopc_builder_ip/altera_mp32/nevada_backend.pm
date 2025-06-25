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






















package nevada_backend;
use Exporter;
@ISA = Exporter;
@EXPORT = qw(
    &be_make_alu
    &be_make_stdata
    &be_make_debug_port
    &be_make_soft_reset
);

use europa_all;
use europa_utils;
use cpu_utils;
use cpu_wave_signals;
use nios_europa;
use nios_avalon_masters;
use nios_common;
use nios_isa;
use nevada_isa;
use nevada_control_regs;
use nevada_insts;
use nevada_common;
use strict;










sub 
be_make_alu
{
    my $Opt = shift;

    my $whoami = "ALU";

    my $rdctl_stage = not_empty_scalar($Opt, "rdctl_stage");






    my $logic_operation_sz = 2;
    my $logic_operation_and = "2'b00";
    my $logic_operation_or  = "2'b01";
    my $logic_operation_nor = "2'b10";
    my $logic_operation_xor = "2'b11";


    my $br_operation_sz = 3;
    my $br_operation_src1_eq_src2 = "3'b000";
    my $br_operation_src1_ne_src2 = "3'b001";
    my $br_operation_src1_lt_zero = "3'b010";
    my $br_operation_src1_le_zero = "3'b011";
    my $br_operation_src1_gt_zero = "3'b100";
    my $br_operation_src1_ge_zero = "3'b101";

    my $trap_operation_sz = 2;
    my $trap_operation_src1_eq_src2 = "2'b00";
    my $trap_operation_src1_ne_src2 = "2'b01";
    my $trap_operation_src1_lt_src2 = "2'b10";
    my $trap_operation_src1_ge_src2 = "2'b11";

    my $alu_result_sel_sz = 2;
    my $alu_result_sel_cmp     = "2'b00";
    my $alu_result_sel_logic   = "2'b01";
    my $alu_result_sel_retaddr = "2'b10";
    my $alu_result_sel_arith   = "2'b11";

    e_assign->adds(

      [["D_logic_operation", $logic_operation_sz],
        "D_ctrl_alu_and_operation ? $logic_operation_and : 
         D_ctrl_alu_or_operation  ? $logic_operation_or : 
         D_ctrl_alu_nor_operation ? $logic_operation_nor : 
                                    $logic_operation_xor"],


      [["D_br_operation", $br_operation_sz],
        "D_ctrl_br_src1_eq_src2 ? $br_operation_src1_eq_src2 : 
         D_ctrl_br_src1_ne_src2 ? $br_operation_src1_ne_src2 : 
         D_ctrl_br_src1_lt_zero ? $br_operation_src1_lt_zero : 
         D_ctrl_br_src1_le_zero ? $br_operation_src1_le_zero : 
         D_ctrl_br_src1_gt_zero ? $br_operation_src1_gt_zero : 
                                  $br_operation_src1_ge_zero"],


      [["D_trap_operation", $trap_operation_sz],
        "D_ctrl_trap_src1_eq_src2 ? $trap_operation_src1_eq_src2 : 
         D_ctrl_trap_src1_ne_src2 ? $trap_operation_src1_ne_src2 : 
         D_ctrl_trap_src1_lt_src2 ? $trap_operation_src1_lt_src2 : 
                                    $trap_operation_src1_ge_src2"],


        [["D_alu_result_sel", $alu_result_sel_sz],
          "D_ctrl_cmp     ? $alu_result_sel_cmp : 
          D_ctrl_logic   ? $alu_result_sel_logic : 
          D_ctrl_retaddr ? $alu_result_sel_retaddr : 
                            $alu_result_sel_arith"],
      );


    e_register->adds(
      {out => ["E_logic_operation", $logic_operation_sz], 
       in => "D_logic_operation",       enable => "E_en"},
      {out => ["E_br_operation", $br_operation_sz],
       in => "D_br_operation",          enable => "E_en"},
      {out => ["E_trap_operation", $trap_operation_sz],
       in => "D_trap_operation",        enable => "E_en"},
      {out => ["E_alu_result_sel", $alu_result_sel_sz],
       in => "D_alu_result_sel",        enable => "E_en"},
    );





    e_assign->adds(

      [["E_arith_src1", $datapath_sz], 
        "{ E_src1[$datapath_msb] ^ E_ctrl_alu_signed_comparison, 
           E_src1[$datapath_msb-1:0]}"],
      [["E_arith_src2", $datapath_sz], 
        "{ E_src2[$datapath_msb] ^ E_ctrl_alu_signed_comparison, 
           E_src2[$datapath_msb-1:0]}"],



      [["E_arith_result", $datapath_sz+1],
        "E_ctrl_alu_add_operation ?
           (E_arith_src1 + E_arith_src2) :
           (E_arith_src1 - E_arith_src2)"],


      [["E_mem_baddr", $mem_baddr_sz], "E_arith_result[$mem_baddr_sz-1:0]"],
    );
 




    e_mux->add ({
      lhs => ["E_logic_result", $datapath_sz],
      selecto => "E_logic_operation",
      table => [
        "$logic_operation_and" => "  E_src1 & E_src2 ",
        "$logic_operation_or"  => "  E_src1 | E_src2 ",
        "$logic_operation_nor" => "~(E_src1 | E_src2)",
        "$logic_operation_xor" => "  E_src1 ^ E_src2 ", # Also src1 eq/ne src2
        ],
    });




















    e_assign->adds(







      [["E_src1_ne_src2", 1], "~E_src1_eq_src2"],



      [["E_src1_lt_src2", 1], "E_arith_result[$datapath_msb+1]"],


      [["E_src1_ge_src2", 1], "~E_src1_lt_src2"],


      [["E_src1_eq_zero", 1], "E_src1 == 0"],


      [["E_src1_ne_zero", 1], "~E_src1_eq_zero"],


      [["E_src1_lt_zero", 1], "E_src1[$datapath_msb]"],


      [["E_src1_le_zero", 1], "E_src1_lt_zero | E_src1_eq_zero"],


      [["E_src1_ge_zero", 1], "~E_src1_lt_zero"],


      [["E_src1_gt_zero", 1], "E_src1_ge_zero & E_src1_ne_zero"],
    );


    e_mux->add({
      lhs   => ["E_br_result", 1],
      selecto => "E_br_operation",
      table => [
        "$br_operation_src1_eq_src2"    => "E_src1_eq_src2",
        "$br_operation_src1_ne_src2"    => "E_src1_ne_src2",
        "$br_operation_src1_lt_zero"    => "E_src1_lt_zero",
        "$br_operation_src1_le_zero"    => "E_src1_le_zero",
        "$br_operation_src1_gt_zero"    => "E_src1_gt_zero",
       ],
       default                          => "E_src1_ge_zero",
    });


    e_assign->adds(

      [["E_cmp_result", 1], "E_src1_lt_src2"],
    );


    e_mux->add({
      lhs   => ["E_trap_result", 1],
      selecto => "E_trap_operation",
      table => [
        "$trap_operation_src1_eq_src2"    => "E_src1_eq_src2",
        "$trap_operation_src1_ne_src2"    => "E_src1_ne_src2",
        "$trap_operation_src1_lt_src2"    => "E_src1_lt_src2",
        "$trap_operation_src1_ge_src2"    => "E_src1_ge_src2",
       ],
    });







      e_mux->add({
        lhs   => ["E_alu_result", $datapath_sz],
        selecto => "E_alu_result_sel",
        table => [
          "$alu_result_sel_cmp"       => "E_cmp_result",
          "$alu_result_sel_logic"     => "E_logic_result",
          "$alu_result_sel_retaddr"   => "{E_pc_plus_two, 2'b00}",
          "$alu_result_sel_arith"     => "E_arith_result[$datapath_msb:0]",
        ],
      });

    my @alu = (
        { divider => "alu" },
        { radix => "x", signal => "clk" },
        { radix => "x", signal => "E_src1" },
        { radix => "x", signal => "E_src2" },
        { radix => "x", signal => "E_arith_src1" },
        { radix => "x", signal => "E_arith_src2" },
        { radix => "x", signal => "E_src1_eq_src2" },
        { radix => "x", signal => "E_src1_ne_src2" },
        { radix => "x", signal => "E_src1_lt_src2" },
        { radix => "x", signal => "E_src1_ge_src2" },
        { radix => "x", signal => "E_src1_eq_zero" },
        { radix => "x", signal => "E_src1_ne_zero" },
        { radix => "x", signal => "E_src1_lt_zero" },
        { radix => "x", signal => "E_src1_le_zero" },
        { radix => "x", signal => "E_src1_ge_zero" },
        { radix => "x", signal => "E_src1_gt_zero" },
        { radix => "x", signal => "E_ctrl_alu_add_operation" },
        { radix => "x", signal => "E_arith_result" },
        { radix => "x", signal => "E_logic_operation" },
        { radix => "x", signal => "E_logic_result" },
        { radix => "x", signal => "E_cmp_result" },
        { radix => "x", signal => "E_ctrl_cmp" },
        { radix => "x", signal => "E_ctrl_logic" },
        { radix => "x", signal => "E_ctrl_retaddr" },
        { radix => "x", signal => "E_alu_result_sel" },
        { radix => "x", signal => "E_alu_result" },
        { radix => "x", signal => "E_ctrl_retaddr" },
        { radix => "x", signal => "E_br_operation" },
        { radix => "x", signal => "E_br_result" },
        { radix => "x", signal => "E_trap_operation" },
        { radix => "x", signal => "E_trap_result" },
      );

    if ($Opt->{full_waveform_signals}) {
        push(@plaintext_wave_signals, @alu);
    }
}




sub 
be_make_stdata
{
    my $Opt = shift;





    our $memsz_sz = 2;
    our $memsz_byte = "2'b00";
    our $memsz_hword = "2'b01";
    our $memsz_word = "2'b10";


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


      [["D_memsz", $memsz_sz],
        "D_ctrl_mem8    ? $memsz_byte : 
         D_ctrl_mem16   ? $memsz_hword : 
                          $memsz_word"],
    );


    e_register->adds(
      {out => ["E_memsz", $memsz_sz], 
       in => "D_memsz",         enable => "E_en"},
    );




    if ($big_endian) {
      e_assign->adds(
        [["E_swlr_data_byte0", 8],
          "E_mem_baddr[1:0] == 2'b00 ? E_src2_reg [7:0] :
           E_mem_baddr[1:0] == 2'b01 ? E_src2_reg[15:8] :
           E_mem_baddr[1:0] == 2'b10 ? E_src2_reg[23:16] :
                            (E_op_swl ? E_src2_reg[31:24] : E_src2_reg[7:0])"],

        [["E_swlr_data_byte1", 8],
           "E_mem_baddr[1:0] == 2'b00 ? E_src2_reg[15:8] :
            E_mem_baddr[1:0] == 2'b01 ? E_src2_reg[23:16] :
            E_mem_baddr[1:0] == 2'b10 ? (E_op_swl ? E_src2_reg[31:24] : E_src2_reg[7:0]) :
                                         E_src2_reg[15:8]"], 

        [["E_swlr_data_byte2", 8],
           "E_mem_baddr[1:0] == 2'b00 ? E_src2_reg[23:16] :
            E_mem_baddr[1:0] == 2'b01 ? (E_op_swl ? E_src2_reg[31:24] : E_src2_reg[7:0]) :
            E_mem_baddr[1:0] == 2'b10 ? E_src2_reg[15:8] :
                                         E_src2_reg[23:16]"], 

        [["E_swlr_data_byte3", 8],
           "E_mem_baddr[1:0] == 2'b00 ? (E_op_swl ? E_src2_reg[31:24] : E_src2_reg[7:0]) :
            E_mem_baddr[1:0] == 2'b01 ? E_src2_reg[15:8] :
            E_mem_baddr[1:0] == 2'b10 ? E_src2_reg[23:16] :
                                         E_src2_reg[31:24]"],


        [["E_swlr_byte_en", $byte_en_sz],
          "E_mem_baddr[1:0] == 2'b00 ? (E_op_swl ? 4'b1111 : 4'b1000) :
           E_mem_baddr[1:0] == 2'b01 ? (E_op_swl ? 4'b0111 : 4'b1100) :
           E_mem_baddr[1:0] == 2'b10 ? (E_op_swl ? 4'b0011 : 4'b1110) :
                                       (E_op_swl ? 4'b0001 : 4'b1111)"],
         );

    } else {
      e_assign->adds(
        [["E_swlr_data_byte0", 8],
          "E_mem_baddr[1:0] == 2'b00 ? (E_op_swl ? E_src2_reg[31:24] : E_src2_reg[7:0]) :
           E_mem_baddr[1:0] == 2'b01 ? E_src2_reg[23:16] :
           E_mem_baddr[1:0] == 2'b10 ? E_src2_reg[15:8] :
                                       E_src2_reg [7:0]"],

        [["E_swlr_data_byte1", 8],
           "E_mem_baddr[1:0] == 2'b00 ? E_src2_reg[15:8] :
            E_mem_baddr[1:0] == 2'b01 ? (E_op_swl ? E_src2_reg[31:24] : E_src2_reg[7:0]) :
            E_mem_baddr[1:0] == 2'b10 ? E_src2_reg[23:16] :
                                         E_src2_reg[15:8]"], 

        [["E_swlr_data_byte2", 8],
           "E_mem_baddr[1:0] == 2'b00 ? E_src2_reg[23:16] :
            E_mem_baddr[1:0] == 2'b01 ? E_src2_reg[15:8] :
            E_mem_baddr[1:0] == 2'b10 ? (E_op_swl ? E_src2_reg[31:24] : E_src2_reg[7:0]) :
                                         E_src2_reg[23:16]"],

        [["E_swlr_data_byte3", 8],
           "E_mem_baddr[1:0] == 2'b00 ? E_src2_reg[31:24] :
            E_mem_baddr[1:0] == 2'b01 ? E_src2_reg[23:16] :
            E_mem_baddr[1:0] == 2'b10 ? E_src2_reg[15:8] :
                             (E_op_swl ? E_src2_reg[31:24] : E_src2_reg[7:0])"],


        [["E_swlr_byte_en", $byte_en_sz],
          "E_mem_baddr[1:0] == 2'b00 ? (E_op_swl ? 4'b0001 : 4'b1111) :
           E_mem_baddr[1:0] == 2'b01 ? (E_op_swl ? 4'b0011 : 4'b1110) :
           E_mem_baddr[1:0] == 2'b10 ? (E_op_swl ? 4'b0111 : 4'b1100) :
                                       (E_op_swl ? 4'b1111 : 4'b1000)"],
         );
    }




    if (!$dtcm_present) {


        e_mux->add({
          lhs   => ["E_st_data", $datapath_sz],
          type  => "priority",
          table => [
            "E_ctrl_swlr" => "{E_swlr_data_byte3, E_swlr_data_byte2, E_swlr_data_byte1, E_swlr_data_byte0}",
            "E_ctrl_mem8" => "{E_stb_data, E_stb_data, E_stb_data, E_stb_data}",
            "E_ctrl_mem16" => "{E_sth_data, E_sth_data}",
            "1'b1" => "E_stw_data",
          ],
        });
    } else {



        e_mux->add({
          lhs   => ["E_st_data", $datapath_sz],
          selecto => "E_memsz",
          table => [
            "E_ctrl_swlr" => "{E_swlr_data_byte3, E_swlr_data_byte2, E_swlr_data_byte1, E_swlr_data_byte0}",
            "$memsz_byte"  => 
              "{E_stb_data, E_stb_data, E_stb_data, E_stb_data}",
            "$memsz_hword" => 
              "{E_sth_data, E_sth_data}",
            ],
          default => "E_stw_data",
          });
    }


    my $E_mem_byte_en_table = $big_endian ?
      [



        "{$memsz_byte, 2'b00}" => "4'b1000",
        "{$memsz_byte, 2'b01}" => "4'b0100",
        "{$memsz_byte, 2'b10}" => "4'b0010",
        "{$memsz_byte, 2'b11}" => "4'b0001",



        "{$memsz_hword, 2'b00}" => "4'b1100",
        "{$memsz_hword, 2'b01}" => "4'b1100",
        "{$memsz_hword, 2'b10}" => "4'b0011",
        "{$memsz_hword, 2'b11}" => "4'b0011",
      ] 
      :
      [



        "{$memsz_byte, 2'b00}" => "4'b0001",
        "{$memsz_byte, 2'b01}" => "4'b0010",
        "{$memsz_byte, 2'b10}" => "4'b0100",
        "{$memsz_byte, 2'b11}" => "4'b1000",



        "{$memsz_hword, 2'b00}" => "4'b0011",
        "{$memsz_hword, 2'b01}" => "4'b0011",
        "{$memsz_hword, 2'b10}" => "4'b1100",
        "{$memsz_hword, 2'b11}" => "4'b1100",
      ]; 

    e_mux->add ({
      lhs => ["E_mem_byte_en_noswlr", $byte_en_sz],
      selecto => "{E_memsz, E_mem_baddr[1:0]}",
      table => $E_mem_byte_en_table,
      default => "4'b1111",
    });
    e_assign->adds(
      [["E_mem_byte_en", $byte_en_sz],
        "E_ctrl_swlr ? E_swlr_byte_en : E_mem_byte_en_noswlr"],
    );
}




sub 
be_make_debug_port
{
    my $Opt = shift;

    my $whoami = "debug_port";

    push(@{$Opt->{port_list}},
      ["debug_intr"         => 1, "in" ],
      ["debug_boot"         => 1, "in" ],
      ["debug_probe_trap"   => 1, "in" ],
      ["debug_dcr_int_e"    => 1, "in" ],
      ["debug_hwbp     "    => 1, "in" ],
      ["debug_mode"         => 1, "out" ],
      ["debug_dpc   "       => 30, "out" ],
      ["debug_evalid  "     => 1, "out" ],
      ["debug_een  "        => 1, "out" ],
    );


    e_signal->adds(
      {name => "debug_intr",        width => 1 },
      {name => "debug_boot",        width => 1 },
      {name => "debug_probe_trap",  width => 1 },
      {name => "debug_dcr_int_e",   width => 1 },
      {name => "debug_hwbp",        width => 1 },
      {name => "debug_mode",        width => 1, export => $force_export },
      {name => "debug_dpc ",        width => 30, export => $force_export },
      {name => "debug_evalid ",     width => 1, export => $force_export },
      {name => "debug_een ",        width => 1, export => $force_export },
    );

    e_assign->adds(
      ["debug_mode", "W_debug_mode"],
      ["debug_evalid", "D_valid"],
      ["debug_dpc", "F_pc"],
      ["debug_een", "D_en"],
    );



    e_register->adds(
      { out => "debug_intr_d1", in => "debug_intr", enable => "1", },
      { out => "debug_hwbp_d1", in => "debug_hwbp", enable => "E_en", },
      { out => "debug_probe_trap_d1", in => "debug_probe_trap", 
        enable => "1", },
    );

    my @debug_port_waves = (
        { divider => "debug_port" },
        { radix => "x", signal => "debug_intr" },
        { radix => "x", signal => "debug_hwbp" },
        { radix => "x", signal => "debug_boot" },
        { radix => "x", signal => "debug_probe_trap" },
        { radix => "x", signal => "debug_dcr_int_e" },
        { radix => "x", signal => "debug_mode" },
    );

    push(@plaintext_wave_signals, @debug_port_waves);
}




sub 
be_make_soft_reset
{
    my $Opt = shift;

    my $whoami = "soft_reset";

    my $soft_reset_taken = not_empty_scalar($Opt, "soft_reset_taken");


    e_signal->adds(
      {name => "cpu_resettaken",   width => 1, export => $force_export },
    );


    e_assign->add(["cpu_resettaken", $soft_reset_taken]);
    
    push(@{$Opt->{port_list}},
      ["cpu_resetrequest" => 1, "in" ],
      ["cpu_resettaken"   => 1, "out" ],
    );

    my @soft_reset_waves = (
        { divider => "soft_reset" },
        { radix => "x", signal => "cpu_resetrequest" },
        { radix => "x", signal => "cpu_resettaken" },
    );
   
    push(@plaintext_wave_signals, @soft_reset_waves);
}

1;
