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






















package nios_dcache;
use Exporter;
@ISA = Exporter;
@EXPORT = qw(
    $dcache_present
    $wide_dcache_present
);

use europa_all;
use europa_utils;
use cpu_utils;
use cpu_file_utils;
use cpu_gen;
use cpu_bit_field;
use nios_sdp_ram;
use nios_tdp_ram;
use nios_avalon_masters;
use nios_common;
use nios_isa;
use nios_wide_dcache;
use nios_word_dcache;
use strict;











our $dcache_present;
our $wide_dcache_present;





sub
initialize_config_constants
{
    my $Opt = shift;


    $dcache_present = manditory_bool($Opt, "cache_has_dcache");


    $wide_dcache_present = 
      $dcache_present && (manditory_int($Opt, "cache_dcache_line_size") > 4);
}


sub
gen_dcache
{
    my $Opt = shift;

    if (!$dcache_present) {
        &$error("Called when data cache not present");
    }

    gen_controls($Opt);

    if ($wide_dcache_present) {
        nios_wide_dcache::gen_dcache($Opt);
    } else {
        nios_word_dcache::gen_dcache($Opt);
    }
}


sub
gen_controls
{
    my $Opt = shift;

    my $cs = not_empty_scalar($Opt, "control_reg_stage");

    my $ioregion_dcache = 0;
    if (defined $Opt->{ioregion_dcache}) {
        $ioregion_dcache = manditory_bool($Opt, "ioregion_dcache");
    }





    if (manditory_bool($Opt, "always_bypass_dcache")) {

        e_assign->adds(
          [["E_mem_bypass_non_io", 1], "1'b1"],
        );
    } elsif ($mpu_present) {
        if (manditory_bool($Opt, "bit_31_bypass_dcache")) {


            e_assign->adds(
              [["M_mem_bypass_non_io", 1], 
                "M_alu_result[$datapath_msb] | 
                  (~M_dmpu_c & ${cs}_config_reg_pe & ~W_debug_mode)"],
            );
        } else {

            e_assign->adds(
              [["M_mem_bypass_non_io", 1], 
                "~M_dmpu_c & ${cs}_config_reg_pe & ~W_debug_mode"],
            );
        }
    } elsif ($mmu_present) {


    } else {
        if (manditory_bool($Opt, "bit_31_bypass_dcache")) {


            e_assign->adds(
              [["E_mem_bypass_non_io", 1], "E_arith_result[$datapath_msb]"],
          );
        } elsif ($ioregion_dcache) {

        } else {

            e_assign->adds(
              [["E_mem_bypass_non_io", 1], "1'b0"],
            );
        }
    }
}

1;
