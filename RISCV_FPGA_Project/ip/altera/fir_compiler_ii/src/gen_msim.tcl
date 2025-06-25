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


# Create msim tcl file

#package require ::quartus::flow
#package require ::quartus::project
#package require ::quartus::iptclgen

set out_dir [lindex $argv 0]
set top_entity [lindex $argv 1]
set core_version [lindex $argv 2]
set device_family [lindex $argv 3]
set QUARTUS_ROOTDIR [lindex $argv 4]

set file_name "${out_dir}${top_entity}_msim.tcl"

if { [ catch { set out_file [ open $file_name w ] } err ] } {
    send_message "error" "$err"
    return
}

	puts $out_file {
## ================================================================================
## Legal Notice: Copyright (C) 1991-2009 Altera Corporation
## Any megafunction design, and related net list (encrypted or decrypted),
## support information, device programming or simulation file, and any other
## associated documentation or information provided by Altera or a partner
## under Altera's Megafunction Partnership Program may be used only to
## program PLD devices (but not masked PLD devices) from Altera.  Any other
## use of such megafunction design, net list, support information, device
## programming or simulation file, or any other related documentation or
## information is prohibited for any other purpose, including, but not
## limited to modification, reverse engineering, de-compiling, or use with
## any other silicon devices, unless such use is explicitly licensed under
## a separate agreement with Altera or a megafunction partner.  Title to
## the intellectual property, including patents, copyrights, trademarks,
## trade secrets, or maskworks, embodied in any such megafunction design,
## net list, support information, device programming or simulation file, or
## any other related documentation or information provided by Altera or a
## megafunction partner, remains with Altera, the megafunction partner, or
## their respective licensors.  No other licenses, including any licenses
## needed under any third party's intellectual property, are provided herein.
## ================================================================================
##
}

	puts $out_file ""

	puts $out_file "transcript on"
	puts $out_file "write transcript ${top_entity}_transcript"
	puts $out_file ""
	  
	puts $out_file "# START MEGAWIZARD INSERT VARIABLES"
	puts $out_file "set top_entity $top_entity"
	puts $out_file "set timing_resolution \"1ps\""
	puts $out_file "set core_version $core_version"
	puts $out_file "set device_family $device_family"  
	puts $out_file "set quartus_rootdir $QUARTUS_ROOTDIR"
	puts $out_file "# Change to \"gate_level\" for gate-level sim"
	puts $out_file "set sim_type \"rtl\""
	puts $out_file "# END MEGAWIZARD INSERT VARIABLES"
	puts $out_file ""
	
#set megacore_lib_dir {$build_dir}
#set is_reg_test $is_reg_test
#set fir_arch "$fir_arch"
#set new_flow $new_flow
#set tag "$tag"

	puts $out_file "set q_sim_lib \[file join \$quartus_rootdir eda sim_lib\]"
	puts $out_file ""
	
	puts $out_file "# Close existing ModelSim simulation"
	puts $out_file "quit -sim"
	puts $out_file ""
		
	puts $out_file "if {\[file exists \[file join simulation modelsim \${top_entity}.vo\]\] && \[string match \"gate_level\" \$sim_type\]} {"
	puts $out_file "    puts \"Info: Gate Level \${top_entity}.vo found\""
	puts $out_file "    set language_ext \"vo\""
	puts $out_file "    set use_ipfs 1"
	puts $out_file "    set flow \"gate_level\"" 
	puts $out_file "} elseif {\[file exists \[file join simulation modelsim \${top_entity}.vho\]\] && \[string match \"gate_level\" \$sim_type\]} {"
	puts $out_file "    puts \"Info: Gate Level \${top_entity}.vho found\""
	puts $out_file "    set language_ext \"vho\""
	puts $out_file "    set use_ipfs 1"
	puts $out_file "    set flow \"gate_level\""
	puts $out_file "} else {"
	puts $out_file "    puts \"Info: RTL simulation.\""
	puts $out_file "    set use_ipfs 0"
	puts $out_file "    set flow \"rtl\""
	puts $out_file "}"
	puts $out_file ""

	puts $out_file "if {\[string match \$flow \"gate_level\"\] } {"
	puts $out_file "    file copy \${top_entity}_input.txt simulation/modelsim"
	puts $out_file "    cd simulation/modelsim"
	puts $out_file "}"
	puts $out_file ""

	puts $out_file "regsub {\[ \]+} \$device_family \"\" temp_device_family"
	puts $out_file "regsub {\[ \]+} \$temp_device_family \"\" temp_device_family2"
	puts $out_file "set device_lib_name \[string tolower \$temp_device_family2\]"
	puts $out_file ""

	puts $out_file "set libs \[list \\"
	puts $out_file "    \$device_lib_name \\"
	puts $out_file "    altera \\"
	puts $out_file "    work\]"
	puts $out_file ""

	puts $out_file "foreach {lib} \$libs {"
	puts $out_file "    if {\[file exist \$lib\]} {"
	puts $out_file "        catch {eval \"file delete -force -- \$lib\"} fid"
	puts $out_file "        puts \"file delete command returned \$fid\\n\""
	puts $out_file "    }"
	puts $out_file "    if {\[file exist \$lib\] == 0} 	{"
	puts $out_file "        vlib \$lib"
	puts $out_file "        vmap \$lib \$lib"
	puts $out_file "    }"
	puts $out_file "}"
	puts $out_file ""

	puts $out_file "# RTL Simulation"
	puts $out_file ""

	puts $out_file "if {\[string match \$flow \"rtl\"\] } {"
	puts $out_file ""

	puts $out_file "    # Compile all required simulation library files"
	puts $out_file "    set quartus_libs \[list \\"
	puts $out_file "        altera_mf   {altera_mf_components altera_mf}   {altera_mf} \"\$q_sim_lib\" \\"
	puts $out_file "        lpm         {220pack 220model}                 {220model}  \"\$q_sim_lib\" \\"
	puts $out_file "        sgate       {sgate_pack sgate}                 {sgate}     \"\$q_sim_lib\" \]"
	puts $out_file ""
	
	puts $out_file "	foreach {lib file_vhdl_list file_verilog_list src_files_loc} \$quartus_libs {"
	puts $out_file "        if {\[file exist \$lib\]} {"
	puts $out_file "            catch {eval \"file delete -force -- \$lib\"} fid"
	puts $out_file "            puts \"file delete command returned \$fid\\n\""
	puts $out_file "        }"
	puts $out_file "        if {\[file exist \$lib\] == 0} 	{"
	puts $out_file "            vlib \$lib"
	puts $out_file "            vmap \$lib \$lib"
	puts $out_file "        }"
	puts $out_file "		foreach file_item \$file_vhdl_list {"
	puts $out_file "		  catch {vcom -explicit -93 -work \$lib \[file join \$src_files_loc \${file_item}.vhd\]} err_msg"
	puts $out_file "		  if {!\[string match \"\" \$err_msg\]} {return \$err_msg}"
	puts $out_file "		}"
	puts $out_file "	}"
	puts $out_file ""

 	puts $out_file "	vcom -93 -work altera \$q_sim_lib/altera_primitives_components.vhd"
	puts $out_file "	vcom -93 -work altera \$q_sim_lib/altera_primitives.vhd"
	puts $out_file ""

	puts $out_file "    # Compile all FIR Compiler II RTL files"
	puts $out_file "    vlog -work work altera_avalon_sc_fifo.v"
	puts $out_file "    vcom -93 -work work auk_dspip_math_pkg_hpfir.vhd"
	puts $out_file "    vcom -93 -work work auk_dspip_lib_pkg_hpfir.vhd"
	puts $out_file "    vcom -93 -work work auk_dspip_roundsat_hpfir.vhd"
	puts $out_file "    vcom -93 -work work auk_dspip_avalon_streaming_source_hpfir.vhd"
	puts $out_file "    vcom -93 -work work auk_dspip_avalon_streaming_sink_hpfir.vhd"
	puts $out_file "    vcom -93 -work work auk_dspip_avalon_streaming_controller_hpfir.vhd"
	puts $out_file "    vcom -93 -work work dspba_library_package.vhd"
	puts $out_file "    vcom -93 -work work dspba_library.vhd"
	puts $out_file ""

	puts $out_file "    if {\[file exists ${top_entity}.vhd\]} {vcom -93 -work work ${top_entity}.vhd}"
	puts $out_file "    if {\[file exists ${top_entity}.v\]} {vlog -work work ${top_entity}.v}"
	puts $out_file "    vcom -93 -work work ${top_entity}_ast.vhd"
	puts $out_file "    vcom -93 -work work ${top_entity}_rtl.vhd"
	puts $out_file ""
   
	puts $out_file "    vcom -93 -work work \${top_entity}_tb.vhd"
	puts $out_file ""

    puts $out_file "} else {"	
	puts $out_file ""

	puts $out_file "# Gate Level Simulation"
	puts $out_file ""

	puts $out_file "    # Compile all required simulation library files and the simulation netlist file"
        puts $out_file "    # If the following automatic mapping doesn't work, modify the code below to match the device chosen"
        puts $out_file "    if {\[string match \$language_ext \"vho\"\]} {" 
	puts $out_file "        vcom -93 -work altera \$q_sim_lib/altera_primitives_components.vhd"
	puts $out_file "	    vcom -93 -work altera \$q_sim_lib/altera_primitives.vhd"
	puts $out_file " 	    vcom -93 -work \$device_lib_name \[file join \$q_sim_lib \${device_lib_name}_atoms.vhd\]"
	puts $out_file "		vcom -93 -work \$device_lib_name \[file join \$q_sim_lib \${device_lib_name}_components.vhd\]"
	puts $out_file "        vcom -93 -work work \${top_entity}.vho"
	puts $out_file "    } else {"
	puts $out_file "	    vlog -work altera \$q_sim_lib/altera_primitives.v"
	puts $out_file "		vlog -work \$device_lib_name \[file join \$q_sim_lib \${device_lib_name}_atoms.v\]"
	puts $out_file "	    vlog -work work \${top_entity}.vo"
	puts $out_file "    }"
	puts $out_file ""

	puts $out_file "    vcom -93 -work work ../../\${top_entity}_tb.vhd"
	puts $out_file "}"
	puts $out_file ""

	puts $out_file "# Prepare simulation command"
	puts $out_file ""
	
	puts $out_file "set vsim_cmd vsim"
	puts $out_file ""
	
	puts $out_file "if {\[string match \$flow \"rtl\"\]} {"
	puts $out_file "    lappend vsim_cmd \"-L\" \"\$device_lib_name\" \"-L\" \"altera_mf\" \"-L\" \"lpm\" \"-L\" \"Sgate\" \"-L\" \"altera\" \"-L\" \"work\""
	puts $out_file "} else {"
	puts $out_file "    lappend vsim_cmd \"-L\" \"\$device_lib_name\" \"-L\" \"altera\" \"-L\" \"work\""
	puts $out_file "    if {\[string match \$language_ext \"vho\"\]} {"
	puts $out_file "	    if {\[file exists \${top_entity}_vhd.sdo\]} {"
	puts $out_file "	        lappend vsim_cmd \"-sdftyp\" \"/\${top_entity}_tb/DUT=\${top_entity}_vhd.sdo\"}"
	puts $out_file "    }"
	puts $out_file "    if {\[string match \$language_ext \"vo\"\]} {"
	puts $out_file "	    if {\[file exists \${top_entity}_v.sdo\]} {"
	puts $out_file "	        lappend vsim_cmd \"-sdftyp\" \"/\${top_entity}_tb/DUT=\${top_entity}_v.sdo\"}"
	puts $out_file "    }"
	puts $out_file "}"
	puts $out_file ""

	puts $out_file "lappend vsim_cmd \"work.\${top_entity}_tb\" \"-t\" \"\$timing_resolution\""
	puts $out_file ""
	
	puts $out_file "catch {	eval \$vsim_cmd } vsim_msg"
	puts $out_file "puts \$vsim_msg"
	puts $out_file ""
	
# Waveform formation
##  I would like to load this waveforms only in interactive mode
##  in testing mode they shouldn't be loaded.   TBD

	puts $out_file "if {\[file exists \"wave.do\"\]} {"
	puts $out_file "    do wave.do"
	puts $out_file "} else {"
	puts $out_file "    add wave sim:/\${top_entity}_tb/*"
	puts $out_file "}"
	puts $out_file ""
	
	puts $out_file "# Start simulation silently"
	puts $out_file ""

	puts $out_file "set StdArithNoWarnings 1"
	puts $out_file "run 0 ns"
	puts $out_file "set StdArithNoWarnings 0"
	puts $out_file "catch {run -all} run_msg"
	puts $out_file "puts \$run_msg"

close $out_file
