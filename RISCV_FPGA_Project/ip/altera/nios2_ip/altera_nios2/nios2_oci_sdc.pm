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






















use cpu_utils;
use europa_all;
use strict;












sub make_nios2_oci_sdc
{
  my $Opt = shift;

  my $filename = $Opt->{name} . ".sdc";
  my $cpu = $Opt->{name};
  my $onchip_trace = $Opt->{oci_onchip_trace};
  my $dbrk_present = ($Opt->{oci_num_dbrk} > 0);
  my $device_family = $Opt->{device_family};

  my $system_dir = $Opt->{system_directory};
  my $sdc_path = $system_dir . "/" . $filename;
  my $copyright_string = $Opt->{copyright_notice};
  my @copyright_lines = split(/\n/,$copyright_string);

  if (-e $sdc_path) {
    open (SDC_FILE, ">> $sdc_path") or die "Error while opening SDC file $sdc_path for write\n";
  } else {
  
    open (SDC_FILE, "> $sdc_path") or die "Error while opening SDC file $sdc_path for write\n";
    
    foreach my $copyright_line (@copyright_lines) {
      print SDC_FILE "\# ".$copyright_line."\n";
    }
    print SDC_FILE "\n";
  }

  my $old_device_family = (  ($device_family =~ m/^STRATIX$/) 
                          || ($device_family =~ m/^STRATIXII$/)
                          || ($device_family =~ m/^STRATIXIIGX$/)
                          || ($device_family =~ m/^STRATIXIIGXLITE$/)
                          || ($device_family =~ m/^STRATIXGX$/)
                          || ($device_family =~ m/^CYCLONE$/)
                          || ($device_family =~ m/^CYCLONEII$/)
                          || ($device_family =~ m/^HARDCOPY$/)
                          || ($device_family =~ m/^HARDCOPYII$/) );

  print SDC_FILE "\#**************************************************************\n";
  print SDC_FILE "\# Timequest JTAG clock definition\n";
  print SDC_FILE "\#   Uncommenting the following lines will define the JTAG\n";
  print SDC_FILE "\#   clock in TimeQuest Timing Analyzer\n";
  print SDC_FILE "\#**************************************************************\n";
  print SDC_FILE "\n";

  if (!$old_device_family) {
    print SDC_FILE "\#create_clock -period 10MHz {altera_reserved_tck}\n";
    print SDC_FILE "\#set_clock_groups -asynchronous -group {altera_reserved_tck}\n";
  } else {
    print SDC_FILE "\#create_clock -period 10MHz {altera_internal_jtag|tckutap}\n";
    print SDC_FILE "\#set_clock_groups -asynchronous -group {altera_internal_jtag|tckutap}\n";
  }
  print SDC_FILE "\n";

  print SDC_FILE "\#**************************************************************\n";
  print SDC_FILE "\# Set TCL Path Variables \n";
  print SDC_FILE "\#**************************************************************\n";
  print SDC_FILE "\n";
  print SDC_FILE "set \t$cpu \t$cpu:*\n";
  print SDC_FILE "set \t" . $cpu ."_oci \t" . $cpu . "_nios2_oci:the_" . $cpu .  "_nios2_oci\n";
  print SDC_FILE "set \t" . $cpu ."_oci_break \t" . $cpu . "_nios2_oci_break:the_" . $cpu .  "_nios2_oci_break\n";
  print SDC_FILE "set \t" . $cpu ."_ocimem \t" . $cpu .  "_nios2_ocimem:the_" . $cpu .  "_nios2_ocimem\n";
  print SDC_FILE "set \t" . $cpu ."_oci_debug \t" . $cpu . "_nios2_oci_debug:the_" . $cpu .  "_nios2_oci_debug\n";
  print SDC_FILE "set \t" . $cpu ."_wrapper \t" . $cpu .  "_jtag_debug_module_wrapper:the_" . $cpu .  "_jtag_debug_module_wrapper\n";
  print SDC_FILE "set \t" . $cpu ."_jtag_tck \t" . $cpu .  "_jtag_debug_module_tck:the_" . $cpu .  "_jtag_debug_module_tck\n";
  print SDC_FILE "set \t" . $cpu ."_jtag_sysclk \t" . $cpu .  "_jtag_debug_module_sysclk:the_" . $cpu .  "_jtag_debug_module_sysclk\n";
  print SDC_FILE "set \t" . $cpu . "_oci_path \t [format \"\%s|\%s\" \$".$cpu." \$".$cpu."_oci]\n";
  print SDC_FILE "set \t" . $cpu . "_oci_break_path \t [format \"\%s|\%s\" \$".$cpu. "_oci_path \$". $cpu . "_oci_break]\n";
  print SDC_FILE "set \t" . $cpu . "_ocimem_path \t [format \"\%s|\%s\" \$".$cpu. "_oci_path \$".  $cpu . "_ocimem]\n";
  print SDC_FILE "set \t" . $cpu . "_oci_debug_path \t [format \"\%s|\%s\" \$".$cpu. "_oci_path \$". $cpu . "_oci_debug]\n";
  print SDC_FILE "set \t" . $cpu . "_jtag_tck_path \t [format \"\%s|\%s|\%s\" \$".$cpu. "_oci_path \$". $cpu . "_wrapper \$". $cpu . "_jtag_tck]\n";
  print SDC_FILE "set \t" . $cpu . "_jtag_sysclk_path \t [format \"\%s|\%s|\%s\" \$".$cpu. "_oci_path \$". $cpu . "_wrapper \$". $cpu . "_jtag_sysclk]\n";

  print SDC_FILE "set \t" . $cpu . "_jtag_sr \t [format \"\%s|*sr\" \$".$cpu. "_jtag_tck_path]\n";

  if ($onchip_trace) {
  print SDC_FILE "\n";
  print SDC_FILE "set \t" . $cpu ."_oci_im \t" . $cpu . "_nios2_oci_im:the_" . $cpu .  "_nios2_oci_im\n";
  print SDC_FILE "set \t" . $cpu ."_oci_traceram \t" . $cpu .  "_traceram_lpm_dram_bdp_component_module:" . $cpu .  "_traceram_lpm_dram_bdp_component\n";
  print SDC_FILE "set \t" . $cpu ."_oci_itrace \t" . $cpu .  "_nios2_oci_itrace:the_" . $cpu .  "_nios2_oci_itrace\n";
  print SDC_FILE "set \t" . $cpu . "_oci_im_path \t [format \"\%s|\%s\" \$".$cpu. "_oci_path \$".  $cpu . "_oci_im]\n";
  print SDC_FILE "set \t" . $cpu . "_oci_itrace_path \t [format \"\%s|\%s\" \$".$cpu. "_oci_path \$". $cpu . "_oci_itrace]\n";
  print SDC_FILE "set \t" . $cpu . "_traceram_path \t [format \"\%s|\%s\" \$" . $cpu . "_oci_im_path \$" . $cpu . "_oci_traceram]\n";
  }
  print SDC_FILE "\n";
  
  print SDC_FILE "\#**************************************************************\n";
  print SDC_FILE "\# Set False Paths\n";
  print SDC_FILE "\#**************************************************************\n";
  print SDC_FILE "\n";
  print SDC_FILE "set_false_path -from [get_keepers *\$".$cpu."_oci_break_path|break_readreg*] -to [get_keepers *\$".$cpu."_jtag_sr*]\n";
  print SDC_FILE "set_false_path -from [get_keepers *\$".$cpu."_oci_debug_path|*resetlatch]     -to [get_keepers *\$".$cpu."_jtag_sr[33]]\n";
  print SDC_FILE "set_false_path -from [get_keepers *\$".$cpu."_oci_debug_path|monitor_ready]  -to [get_keepers *\$".$cpu."_jtag_sr[0]]\n";
  print SDC_FILE "set_false_path -from [get_keepers *\$".$cpu."_oci_debug_path|monitor_error]  -to [get_keepers *\$".$cpu."_jtag_sr[34]]\n";
  print SDC_FILE "set_false_path -from [get_keepers *\$".$cpu."_ocimem_path|*MonDReg*] -to [get_keepers *\$".$cpu."_jtag_sr*]\n";

  print SDC_FILE "set_false_path -from *\$".$cpu."_jtag_sr*    -to *\$".$cpu."_jtag_sysclk_path|*jdo*\n";
  print SDC_FILE "set_false_path -from sld_hub:*|irf_reg* -to *\$".$cpu."_jtag_sysclk_path|ir*\n";
  print SDC_FILE "set_false_path -from sld_hub:*|sld_shadow_jsm:shadow_jsm|state[1] -to *\$".$cpu."_oci_debug_path|monitor_go\n";


  if ($dbrk_present) {
  print SDC_FILE "set_false_path -from [get_keepers *\$".$cpu."_oci_break_path|dbrk_hit?_latch] -to [get_keepers *\$".$cpu."_jtag_sr*]\n";
  print SDC_FILE "set_false_path -from [get_keepers *\$".$cpu."_oci_break_path|trigbrktype] -to [get_keepers *\$".$cpu."_jtag_sr*]\n";
  print SDC_FILE "set_false_path -from [get_keepers *\$".$cpu."_oci_break_path|trigger_state] -to [get_keepers *\$".$cpu."_jtag_sr*]\n";
  }


  if ($onchip_trace) {
  print SDC_FILE "\n";
  print SDC_FILE "set_false_path -from [get_keepers *\$".$cpu."_traceram_path*address*] -to [get_keepers *\$".$cpu."_jtag_sr*]\n";
  print SDC_FILE "set_false_path -from [get_keepers *\$".$cpu."_traceram_path*we_reg*] -to [get_keepers *\$".$cpu."_jtag_sr*]\n";
  print SDC_FILE "set_false_path -from [get_keepers *\$".$cpu."_oci_im_path|*trc_im_addr*] -to [get_keepers *\$".$cpu."_jtag_sr*]\n";
  print SDC_FILE "set_false_path -from [get_keepers *\$".$cpu."_oci_im_path|*trc_wrap] -to [get_keepers *\$".$cpu."_jtag_sr*]\n";
  print SDC_FILE "set_false_path -from [get_keepers *\$".$cpu."_oci_itrace_path|trc_ctrl_reg*] -to [get_keepers *\$".$cpu."_jtag_sr*]\n";
  print SDC_FILE "set_false_path -from [get_keepers *\$".$cpu."_oci_itrace_path|d1_debugack] -to [get_keepers *\$".$cpu."_jtag_sr*]\n";
  }

  close (SDC_FILE);
}

1;





















