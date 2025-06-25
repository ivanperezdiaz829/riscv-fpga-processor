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


set alt_mem_if_tcl_libs_dir "$env(QUARTUS_ROOTDIR)/../ip/altera/alt_mem_if/alt_mem_if_tcl_packages"
if {[lsearch -exact $auto_path $alt_mem_if_tcl_libs_dir] == -1} {
	lappend auto_path $alt_mem_if_tcl_libs_dir
}



package require -exact sopc 10.1

package require alt_mem_if::util::messaging
package require alt_mem_if::util::profiling
package require alt_mem_if::util::hwtcl_utils
package require alt_mem_if::util::qini

namespace import ::alt_mem_if::util::messaging::*

set_module_property DESCRIPTION "Avalon-MM Traffic Generator and BIST Engine Coordinator"
set_module_property NAME altera_avalon_mm_traffic_generator_coordinator
set_module_property VERSION 13.1
::alt_mem_if::util::hwtcl_utils::set_module_internal_mode
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property DISPLAY_NAME "Avalon-MM Traffic Generator and BIST Engine Coordinator"
set_module_property GROUP [::alt_mem_if::util::hwtcl_utils::example_design_components_group_name]
set_module_property AUTHOR "Altera Corporation"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL TRUE


add_fileset sim_vhdl SIM_VHDL generate_vhdl_sim

add_fileset sim_verilog SIM_VERILOG generate_verilog_sim

add_fileset synth QUARTUS_SYNTH generate_synth


proc generate_vhdl_sim {name} {

        set simulators [::alt_mem_if::util::hwtcl_utils::get_simulator_attributes 1]
        add_fileset_file altera_avalon_mm_traffic_generator_coordinator.sv SYSTEM_VERILOG PATH altera_avalon_mm_traffic_generator_coordinator.sv $simulators
        add_fileset_file [file join mentor altera_avalon_mm_traffic_generator_coordinator.sv] SYSTEM_VERILOG_ENCRYPT PATH [file join mentor altera_avalon_mm_traffic_generator_coordinator.sv] {MENTOR_SPECIFIC}
}

proc generate_verilog_sim {name} {
        add_fileset_file altera_avalon_mm_traffic_generator_coordinator.sv SYSTEM_VERILOG PATH altera_avalon_mm_traffic_generator_coordinator.sv
}

proc generate_synth {name} {
        add_fileset_file altera_avalon_mm_traffic_generator_coordinator.sv SYSTEM_VERILOG PATH altera_avalon_mm_traffic_generator_coordinator.sv
}



add_parameter TGC_NUM_STATUS_INTERFACES_MAX INTEGER 12
set_parameter_property TGC_NUM_STATUS_INTERFACES_MAX VISIBLE false
set_parameter_property TGC_NUM_STATUS_INTERFACES_MAX AFFECTS_ELABORATION true

add_parameter TGC_NUM_STATUS_INTERFACES_TGEN INTEGER 1
set_parameter_property TGC_NUM_STATUS_INTERFACES_TGEN DISPLAY_NAME "Number of driver status interfaces"
set_parameter_property TGC_NUM_STATUS_INTERFACES_TGEN DESCRIPTION "Use this parameter to set the number of each of the driver status interfaces"
set_parameter_property TGC_NUM_STATUS_INTERFACES_TGEN AFFECTS_ELABORATION true
set_parameter_property TGC_NUM_STATUS_INTERFACES_TGEN ALLOWED_RANGES {1:12}

for {set port_id 0} {$port_id != 12} {incr port_id} {
        add_parameter TGC_TURN_PORT_${port_id} INTEGER 0
        set_parameter_property TGC_TURN_PORT_${port_id} DISPLAY_NAME "Port ${port_id} Turn"
        set_parameter_property TGC_TURN_PORT_${port_id} DESCRIPTION "Specify the turn when the driver for this port should be serve. (0 will be the earlieast and same number indicate the driver will be served at same time)"
        set_parameter_property TGC_TURN_PORT_${port_id} ALLOWED_RANGES {0 1 2 3 4 5 6 7 8 9 10 11}
        set_parameter_property TGC_TURN_PORT_${port_id} HDL_PARAMETER true

        add_parameter TGC_USE_SYNC_READY_${port_id} boolean false
        set_parameter_property TGC_USE_SYNC_READY_${port_id} DISPLAY_NAME "Use Synchronize ready for Port ${port_id}"
        set_parameter_property TGC_USE_SYNC_READY_${port_id} DESCRIPTION "When enable the port ready will be synchronize with othe port ready with same Turn no"
        set_parameter_property TGC_USE_SYNC_READY_${port_id} HDL_PARAMETER true
}


set_module_property elaboration_Callback ip_elaborate



proc ip_elaborate {} {

	set toplevel_name "altera_avalon_mm_traffic_generator_coordinator"

	set_fileset_property sim_vhdl TOP_LEVEL $toplevel_name
	set_fileset_property sim_verilog TOP_LEVEL $toplevel_name
	set_fileset_property synth TOP_LEVEL $toplevel_name

	
	add_interface avl_clock clock end
	set_interface_property avl_clock ENABLED true
	add_interface_port avl_clock clk clk Input 1
	
	add_interface avl_reset reset end
	set_interface_property avl_reset synchronousEdges NONE
	set_interface_property avl_reset ENABLED true
	add_interface_port avl_reset reset_n reset_n Input 1
	
	set num_tgen_status [get_parameter_value TGC_NUM_STATUS_INTERFACES_TGEN]
	set num_status_max [get_parameter_value TGC_NUM_STATUS_INTERFACES_MAX]
        
	for {set ii 0} {$ii < $num_status_max} {incr ii} {

		if {$ii == 0} {
			set suffix ""
		} else {
			set suffix "_${ii}"
		}

		add_interface "unique_done${suffix}" conduit start
		set_interface_property "unique_done${suffix}" ENABLED true
		add_interface_port "unique_done${suffix}" "unique_done${suffix}" unique_done Input 1

		add_interface "unique_ready${suffix}" conduit start
		set_interface_property "unique_ready${suffix}" ENABLED true
		add_interface_port "unique_ready${suffix}" "unique_ready${suffix}" unique_ready Input 1

                add_interface "coordinator_ready${suffix}" conduit end
                set_interface_property "coordinator_ready${suffix}" ENABLED true
                add_interface_port "coordinator_ready${suffix}" "coordinator_ready${suffix}" coordinator_ready output 1
	
		if {$ii >= $num_tgen_status} {
			set_port_property "unique_done${suffix}" termination true
			set_port_property "unique_done${suffix}" termination_value "1'b1"

			set_port_property "unique_ready${suffix}" termination true
			set_port_property "unique_ready${suffix}" termination_value "1'b1"

                        set_port_property "coordinator_ready${suffix}" termination true
                }
	}


}
