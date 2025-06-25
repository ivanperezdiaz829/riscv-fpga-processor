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






















package nevada_frontend_150;
use Exporter;
@ISA = Exporter;
@EXPORT = qw(
    &nevada_fe150_make_frontend
);

use cpu_utils;
use cpu_wave_signals;
use europa_all;
use europa_utils;
use nios_avalon_masters;
use nios_brpred;
use nios_isa;
use nios_icache;
use nios_frontend_150;
use nevada_insts;
use nevada_common;
use nevada_frontend;
use nevada_mmu;
use strict;







sub 
nevada_fe150_make_frontend
{
    my $Opt = shift;

    &$progress("    Pipeline front-end");

    gen_pc($Opt);


    nios_frontend_150::gen_frontend_150($Opt);


    nevada_frontend::gen_ram_instruction_word_mux($Opt);

    if ($mmu_present) {

        nevada_frontend::decode_mmu_inst_regions($Opt);
    
        if ($tlb_present) {
            &$progress("      Micro-ITLB");
            nevada_frontend::gen_tlb_inst($Opt);
        } else {
            &$progress("      IFMT");
            my $ifmt_wave_signals = nevada_mmu::make_fmt($Opt, 0);

            if ($Opt->{full_waveform_signals}) {
                push(@plaintext_wave_signals, @$ifmt_wave_signals);
            }
        }
    }
}

sub 
gen_pc
{
    my $Opt = shift;


    e_register->adds(
      {out => ["F_pcb", $pcb_sz], in => "F_pcb_nxt", enable => "F_en"},
    );

    e_assign->adds(

      [["F_pc", $pc_sz], "F_pcb[$pcb_sz-1:2]"],


      [["F_pc_plus_one", $pc_sz], "F_pc + 1"],
    );








    if ($pc_sz > $iw_imm26_sz) {
        e_assign->adds(
          [["F_jmp_direct_target_waddr", $pc_sz], 
            "{F_pc_plus_one[$pc_sz-1:$iw_imm26_sz], 
              F_iw[$iw_imm26_msb:$iw_imm26_lsb]}"],
        );
    } else {
        e_assign->adds(
          [["F_jmp_direct_target_waddr", $pc_sz], 
            "F_iw[$iw_imm26_msb:$iw_imm26_lsb]"],
        );
    }


    e_assign->adds(
      [["F_jmp_direct_target_baddr", $pcb_sz], 
        "{F_jmp_direct_target_waddr, 2'b00}"]
    );

}

1;
