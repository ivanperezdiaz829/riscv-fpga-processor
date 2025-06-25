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






















package nevada_common;
use Exporter;
@ISA = Exporter;
@EXPORT = qw(
    $perf_cnt_inc_rd_stall
    $perf_cnt_inc_wr_stall
    $global_prefix
    $soft_reset_present
    $nmi_present
    $debug_port_present
);

use cpu_utils;
use strict;







our $perf_cnt_inc_rd_stall = "1'b0";
our $perf_cnt_inc_wr_stall = "1'b0";
our $global_prefix = "mips32_";
our $soft_reset_present;
our $nmi_present;
our $debug_port_present;

sub 
initialize_config_constants
{
    my $Opt = shift;





    $soft_reset_present = manditory_bool($Opt, "soft_reset_present");
    $nmi_present = manditory_bool($Opt, "nmi_present");
    $debug_port_present = manditory_bool($Opt, "debug_port_present");
}

1;
