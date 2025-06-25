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






















package nios2_frontend_150;
use Exporter;
@ISA = Exporter;
@EXPORT = qw(
    &nios2_fe150_make_frontend
);

use cpu_utils;
use europa_all;
use europa_utils;
use nios_avalon_masters;
use nios_brpred;
use nios_isa;
use nios_icache;
use nios_frontend_150;
use nios2_insts;
use nios2_common;
use nios2_frontend;
use strict;







sub 
nios2_fe150_make_frontend
{
    my $Opt = shift;

    &$progress("    Pipeline frontend");

    gen_pc($Opt);


    nios_frontend_150::gen_frontend_150($Opt);


    nios2_frontend::gen_ram_instruction_word_mux($Opt);

    if ($mmu_present) {
        &$progress("      Micro-ITLB");
        nios2_frontend::gen_tlb_inst($Opt);
    }

    if ($mpu_present) {
        &$progress("      IMPU");
        nios2_frontend::gen_impu($Opt);
    }
}

sub 
gen_pc
{
    my $Opt = shift;


    e_signal->adds({name => "F_pcb_nxt", never_export => 1, width => $pcb_sz});
    e_signal->adds({name => "F_pcb", never_export => 1, width => $pcb_sz});

    e_assign->adds(["F_pcb_nxt", "{F_pc_nxt, 2'b00}"]);
    e_assign->adds(["F_pcb", "{F_pc, 2'b00}"]);


    e_register->adds(
      {out => ["F_pc", $pc_sz],                   in => "F_pc_nxt", 
       enable => "F_en"},
      );

    e_assign->adds(
      [["F_pc_plus_one", $pc_sz], "F_pc + 1"],
    );
}

1;
