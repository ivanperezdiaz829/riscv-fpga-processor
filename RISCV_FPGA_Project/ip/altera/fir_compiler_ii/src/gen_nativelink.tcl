# (C) 2001-2013 Altera Corporation. All rights reserved.
# Your use of Altera Corporation's design tools, logic functions and other 
# software and tools, and its AMPP partner logic functions, and any output 
# files any of the foregoing (including device programming or simulation 
# files), and any associated documentation or information are expressly subject 
# to the terms and conditions of the Altera Program License Subscription 
# Agreement, Altera MegaCore Function License Agreement, or other applicable 
# license agreement, including, without limitation, that your use is for the 
# sole purpose of programming logic devices manufactured by Altera and sold by 
# Altera or its authorized distributors.  Please refer to the applicable 
# agreement for further details.


# Create nativelink tcl file

set outdir [lindex $argv 0]
set entity_name [lindex $argv 1]
set hdl_type [string toupper [lindex $argv 2]]
set file_name "${outdir}${entity_name}_nativelink.tcl"

if { [ catch { set out_file [ open $file_name w ] } err ] } {
    send_message "error" "$err"
    return
}

	puts $out_file "## ================================================================================"
	puts $out_file "## Legal Notice: Copyright (C) 1991-2009 Altera Corporation"
	puts $out_file "## Any megafunction design, and related net list (encrypted or decrypted),"
	puts $out_file "## support information, device programming or simulation file, and any other"
	puts $out_file "## associated documentation or information provided by Altera or a partner"
	puts $out_file "## under Altera's Megafunction Partnership Program may be used only to"
	puts $out_file "## program PLD devices (but not masked PLD devices) from Altera.  Any other"
	puts $out_file "## use of such megafunction design, net list, support information, device"
	puts $out_file "## programming or simulation file, or any other related documentation or"
	puts $out_file "## information is prohibited for any other purpose, including, but not"
	puts $out_file "## limited to modification, reverse engineering, de-compiling, or use with"
	puts $out_file "## any other silicon devices, unless such use is explicitly licensed under"
	puts $out_file "## a separate agreement with Altera or a megafunction partner.  Title to"
	puts $out_file "## the intellectual property, including patents, copyrights, trademarks,"
	puts $out_file "## trade secrets, or maskworks, embodied in any such megafunction design,"
	puts $out_file "## net list, support information, device programming or simulation file, or"
	puts $out_file "## any other related documentation or information provided by Altera or a"
	puts $out_file "## megafunction partner, remains with Altera, the megafunction partner, or"
	puts $out_file "## their respective licensors.  No other licenses, including any licenses"
	puts $out_file "## needed under any third party's intellectual property, are provided herein."
	puts $out_file "## ================================================================================"
	puts $out_file "##"
	puts $out_file ""
	puts $out_file "# Testbench simulation files"
	puts $out_file "set testbench_files \[glob -nocomplain -- *.hex\]"
	puts $out_file "set input_files \[glob -nocomplain -- *input.txt\]"
	#puts $out_file "catch {set coef_files \[glob -nocomplain ${component_name}_coef*.txt\]} error_msg"
	puts $out_file ""	

#	puts $out_file "# The top-level in HDL type \"$hdl_type\""
# if {$hdl_type == "VHDL"} {
# 	puts $out_file "set ipfs_ext vho"	
# 	puts $out_file "if {[file exists $entity_name.vho]} {"
# 	puts $out_file "set hdl_ext "vhd""
# } else {
# 	puts $out_file "set ipfs_ext vo"
# 	puts $out_file "if {[file exists ${entity_name}.vo]} {"
# 	puts $out_file "set hdl_ext v"
# }
#	puts $out_file "} else {"
#	puts $out_file "puts \"Warning: Could not find $(entity_name).\$ipfs_ext!\""
#	puts $out_file "}"
#	puts $out_file ""	

	puts $out_file "set_global_assignment -name EDA_OUTPUT_DATA_FORMAT $hdl_type -section_id eda_simulation"
	puts $out_file ""		
	puts $out_file "# Set test bench name"
	puts $out_file "set_global_assignment -name EDA_TEST_BENCH_NAME tb -section_id eda_simulation"
	puts $out_file ""	
	puts $out_file "# Test bench settings"
	puts $out_file "set_global_assignment -name EDA_DESIGN_INSTANCE_NAME DUT -section_id tb"
	puts $out_file "set_global_assignment -name EDA_TEST_BENCH_MODULE_NAME work.${entity_name}_tb -section_id tb"
	puts $out_file "set_global_assignment -name EDA_TEST_BENCH_GATE_LEVEL_NETLIST_LIBRARY work -section_id tb"
	puts $out_file ""	
#	puts $out_file "# IPFS file"
#	puts $out_file "set_global_assignment -name EDA_IPFS_FILE ${entity_name}.\$ipfs_ext -section_id eda_simulation -library work"
#	puts $out_file ""	
	puts $out_file "# Add Testbench files "
	puts $out_file "foreach i \$testbench_files {"
	puts $out_file "  set_global_assignment -name EDA_TEST_BENCH_FILE \$i -section_id tb -library work"
	puts $out_file "}"
	puts $out_file ""
#	puts $out_file "# Add coef files"
#	puts $out_file "foreach i \$coef_files {"
#	puts $out_file "  set_global_assignment -name EDA_TEST_BENCH_FILE \$i -section_id tb -library work"
#	puts $out_file "}"
#	puts $out_file ""		

	puts $out_file "if {\[file exists ${entity_name}_coef_reload.txt\]} {"
	puts $out_file "  set_global_assignment -name EDA_TEST_BENCH_FILE ${entity_name}_coef_reload.txt -section_id tb -library work"
	puts $out_file "}"

	puts $out_file "if {\[file exists ${entity_name}_coef_reload_rtl.txt\]} {"
	puts $out_file "  set_global_assignment -name EDA_TEST_BENCH_FILE ${entity_name}_coef_reload_rtl.txt -section_id tb -library work"
	puts $out_file "}"

	puts $out_file "set_global_assignment -name EDA_TEST_BENCH_FILE ${entity_name}_input.txt -section_id tb -library work"
	puts $out_file ""	
	puts $out_file "set_global_assignment -name EDA_TEST_BENCH_FILE ${entity_name}_tb.vhd -section_id tb -library work"
	puts $out_file ""	
	puts $out_file "# Specify testbench mode for nativelink"
	puts $out_file "set_global_assignment -name EDA_TEST_BENCH_ENABLE_STATUS TEST_BENCH_MODE -section_id eda_simulation"
	puts $out_file ""		
	puts $out_file "# Specify active testbench for nativelink"
	puts $out_file "set_global_assignment -name EDA_NATIVELINK_SIMULATION_TEST_BENCH tb -section_id eda_simulation"

#	puts $out_file "#SPR250732"
#if ($Aion_selected) {
#	puts $out_file "set_global_assignment -name EDA_DESIGN_EXTRA_ALTERA_SIM_LIB stratix -section_id eda_simulation"
#}

close $out_file

