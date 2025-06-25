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


























package nevada_gen;

use cpu_utils;
use nios_gen;
use nevada_opt;
use nevada_common;
use nevada_mmu;
use nevada_mul;
use nevada_fast;
use europa_all;
use europa_utils;
use strict;









sub
create
{
    my $project = shift;
    my $infos = shift;

    my $elaborated_infos = nevada_opt::elaborate_infos($infos);

    my $Opt = nevada_opt::create_opt($infos, $elaborated_infos);


    my $core_funcs = nevada_fast::get_core_funcs();

    nios_gen::add_to_Opt($Opt, $infos, $core_funcs);
    nevada_common::initialize_config_constants($Opt);
    nevada_mmu::initialize_config_constants(manditory_hash($Opt, "mmu_info"));
    nevada_mul::initialize_config_constants(
      manditory_hash($Opt, "multiply_info"), 
      manditory_hash($Opt, "misc_info"));

    &$progress("  Creating all objects for CPU");

    nios_gen::gen_cpu_logic($Opt, $project, $core_funcs);

    if (manditory_bool($Opt, "do_build_sim")) {
        nios_gen::gen_wave_signals($Opt, $project);
    }

    return manditory_array($Opt, "port_list");
}

1;

