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






















package nios2_common;
use Exporter;
@ISA = Exporter;
@EXPORT = qw(
    $perf_cnt_inc_rd_stall
    $perf_cnt_inc_wr_stall
    $cpu_reset
    $illegal_mem_exc
    $imprecise_illegal_mem_exc
    $division_error_exc
    $slave_access_error_exc
    $extra_exc_info
    $oci_present
    $third_party_debug_present 
    $debugger_present
    $hbreak_test_bench
    $hbreak_present
    $create_comptr
);

use cpu_utils;
use strict;







our $perf_cnt_inc_rd_stall = "1'b0";
our $perf_cnt_inc_wr_stall = "1'b0";
our $cpu_reset;
our $illegal_mem_exc;
our $imprecise_illegal_mem_exc;
our $division_error_exc;
our $slave_access_error_exc;
our $extra_exc_info;
our $oci_present;
our $third_party_debug_present; 
our $debugger_present;
our $hbreak_test_bench;
our $hbreak_present;
our $create_comptr;

sub 
initialize_config_constants
{
    my $Opt = shift;






    $cpu_reset = manditory_bool($Opt, "cpu_reset");


    $illegal_mem_exc = manditory_bool($Opt, "illegal_mem_exc");


    $imprecise_illegal_mem_exc = 
      manditory_bool($Opt, "imprecise_illegal_mem_exc");



    $slave_access_error_exc = manditory_bool($Opt, "slave_access_error_exc");


    $extra_exc_info = manditory_bool($Opt, "extra_exc_info");


    $division_error_exc = manditory_bool($Opt, "division_error_exc");

    $oci_present = manditory_bool($Opt, "include_oci");
    $third_party_debug_present = 
      manditory_bool($Opt, "include_third_party_debug_port");
    $hbreak_test_bench = manditory_bool($Opt, "hbreak_test");
    $debugger_present = manditory_bool($Opt, "debugger_present");
    $hbreak_present = manditory_bool($Opt, "hbreak_present");


    $create_comptr = 
      $debugger_present && 
      manditory_bool($Opt, "activate_trace") &&
      ($ENV{"SOPC_KIT_NIOS2TEST"} || $ENV{"EPGTEST_HOME"});
}

1;
