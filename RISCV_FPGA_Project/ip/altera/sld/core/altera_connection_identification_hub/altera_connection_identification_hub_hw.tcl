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


# $Id: //acds/rel/13.1/ip/sld/core/altera_connection_identification_hub/altera_connection_identification_hub_hw.tcl#1 $
# $Revision: #1 $
# $Date: 2013/08/11 $
# $Author: swbranch $

package require -exact qsys 12.1
package require altera_terp 1.0

#  -----------------------------------
# | altera_debug_config_rom
#  -----------------------------------
set_module_property name altera_connection_identification_hub
set_module_property version 13.1
set_module_property group "Verification/Debug & Performance"
set_module_property display_name "Connection identification hub"
set_module_property editable false
set_module_property internal true
set_module_property elaboration_callback elaborate

add_fileset synth quartus_synth generate "Quartus Synthesis"

#  -----------------------------------
# | parameters
#  -----------------------------------
add_parameter DESIGN_HASH string "0"  "Design hash for the system"

add_parameter COUNT integer 1 "Number of roms"
add_parameter SETTINGS string "" "Settings for the individual roms"

#  -----------------------------------
# | Elaboration callback
#  -----------------------------------
proc elaborate {} {
	set count [get_parameter_value COUNT]
	set settings [get_parameter_value SETTINGS]

	for {set i 0} {$i < $count} {incr i} {
		array set s [lindex $settings $i]
		set dw $s(width)
		set l $s(latency)

		set aw [expr 7 - [log2 $dw]]

		if {$l > 0} {
			add_interface clock_$i clock end
			add_interface_port clock_$i clock_$i clk Input 1
		}

		add_interface node_$i conduit end
		add_interface_port node_$i address_$i address Input $aw
		add_interface_port node_$i contrib_$i writedata Input 4
		add_interface_port node_$i rdata_$i readdata Output $dw

		if {$l > 0} {
			set_interface_property node_$i associatedClock clock_$i
		}
	}
}

#  -----------------------------------
# | Generation callback
#  -----------------------------------
proc generate output_name {
    set this_dir      [get_module_property MODULE_DIRECTORY]
    set template_file [file join $this_dir "altera_connection_identification_hub.sv.terp"]

    set template    [read [ open $template_file r ] ]

    # Collect parameter values for Terp
    set params(output_name) $output_name
	set params(hash) [get_parameter_value DESIGN_HASH]

	set count [get_parameter_value COUNT]
	set settings [get_parameter_value SETTINGS]

	set rom_widths ""
	set latencies ""
	for {set i 0} {$i < $count} {incr i} {
		array set s [lindex $settings $i]
		lappend rom_widths $s(width)
		lappend latencies $s(latency)
	}

	set params(count) $count
	set params(rom_widths) $rom_widths
	set params(latencies) $latencies
	
	set result [altera_terp $template params]

    add_fileset_file ${output_name}.sv system_verilog text $result top_level_file
}

# Useful log2 function
proc log2 x {expr {int(ceil(log($x) / log(2)))}}
