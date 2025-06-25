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






















package nevada_bit_inst;
use Exporter;
@ISA = Exporter;
@EXPORT = qw(
);

use cpu_utils;
use nios_europa;
use nios_isa;
use nios_altmult_add;
use europa_all;
use europa_utils;
use strict;




sub
gen_bit_inst
{
  my $Opt = shift;
  my $num;


  for ($num = 5; $num > 0; $num--) {
    my $i = $num * 6;
    e_assign->adds(
      [["E_clz_scnt$num", 3],
        "E_bit_src1[$i + 1] ? 3'd0 :
         E_bit_src1[$i + 0] ? 3'd1 :
         E_bit_src1[$i - 1] ? 3'd2 :
         E_bit_src1[$i - 2] ? 3'd3 :
         E_bit_src1[$i - 3] ? 3'd4 : 3'd5"],

      [["E_clz_nzero$num", 1],
        "(E_bit_src1[1+$i : $i - 4] == 0) ? 0 : 1"],
    );
  }

    e_assign->adds(

      [["E_bit_src1",32],
        "E_op_clo ? ~E_src1 : E_src1"],

      [["E_clz_scnt0",3],
        "E_bit_src1[1] ? 3'd0 : 3'd1"],

      [["E_clz_nzero0",1],
        "E_bit_src1[1:0] == 0 ? 0 : 1"],

      [["E_clz0_result", 32],
        "E_clz_nzero5 ? E_clz_scnt5 :
         E_clz_nzero4 ? (E_clz_scnt4 + 6) :
         E_clz_nzero3 ? (E_clz_scnt3 + 12) :
         E_clz_nzero2 ? (E_clz_scnt2 + 18) :
         E_clz_nzero1 ? (E_clz_scnt1 + 24) :
         E_clz_nzero0 ? (E_clz_scnt0 + 30) :
          32"],

      [["E_bit_result", 32],
        "E_op_seb ? {{24{E_src2[7]}},E_src2[7:0]} :
         E_op_seh ? {{16{E_src2[15]}},E_src2[15:0]} :
         E_op_wsbh ? {E_src2[23:16],E_src2[31:24],E_src2[7:0],E_src2[15:8]} :
         (E_op_rdpgpr | E_op_wrpgpr ) ? E_src2 :
         (E_op_movz | E_op_movn) ? E_src1 :
         E_clz0_result"],
    );
}

1;
