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


set dut_parameters [list]

# RUN_SCRIPT_PARAMETERS


if {[is_project_open]} {
	set project_name $::quartus(project)
	if {[string compare $project_name "generate_sim"] != 0} {
		post_message -type error "Invalid project \"$project_name\""
		post_message -type error "In order to generate the simulation model,"
		post_message -type error "please close the current project \"$project_name\""
		post_message -type error "and open the project \"generate_sim\""
		return 1
	}
}
set arg_list [list]
puts "Generating Verilog simulation model"
set output_dir [file join cpri_testbench ${variant_name}_sim]
set spd_filename [file join $output_dir ${variant_name}.spd]

lappend arg_list "--file-set=SIM_VERILOG"
lappend arg_list "--system-info=DEVICE_FAMILY=$dut_device_family"
lappend arg_list "--output-name=${variant_name}"
lappend arg_list "--output-dir=$output_dir"
lappend arg_list "--report-file=spd:$spd_filename"

set qdir $::env(QUARTUS_ROOTDIR)
catch {eval [concat [list exec "$qdir/sopc_builder/bin/ip-generate" --component-name=altera_cpri] $arg_list $dut_parameters]} temp
puts $temp

catch {eval [list exec "$qdir/sopc_builder/bin/ip-make-simscript" --spd=${spd_filename} --compile-to-work --output-directory=$output_dir]} temp
puts $temp
