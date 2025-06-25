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

package require -exact qsys 12.0

package require alt_mem_if::util::messaging
package require alt_mem_if::util::profiling
package require alt_mem_if::util::hwtcl_utils
package require alt_mem_if::util::qini

namespace import ::alt_mem_if::util::messaging::*

set_module_property DESCRIPTION "Avalon-MM Traffic Generator and BIST Engine Checker"
set_module_property NAME altera_mem_if_checker
set_module_property VERSION 13.1
::alt_mem_if::util::hwtcl_utils::set_module_internal_mode
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property DISPLAY_NAME "Avalon-MM Traffic Generator and BIST Engine Checker"
set_module_property GROUP [::alt_mem_if::util::hwtcl_utils::example_design_checkers_group_name]
set_module_property AUTHOR "Altera Corporation"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL TRUE


add_fileset sim_vhdl SIM_VHDL generate_vhdl_sim

add_fileset sim_verilog SIM_VERILOG generate_verilog_sim

add_fileset synth QUARTUS_SYNTH generate_synth


proc generate_vhdl_sim {name} {

		
	if {[string compare -nocase [get_parameter_value ENABLE_VCDPLUS] "true"] == 0} {
		set simulators_vcd [list]
		set simulators_novcd [list]
		foreach simatt [::alt_mem_if::util::hwtcl_utils::get_simulator_attributes 1] {
			if {[string compare -nocase $simatt "CADENCE_SPECIFIC"] == 0} {
				lappend simulators_novcd $simatt
			} else {
				lappend simulators_vcd $simatt
			}
		}
		add_fileset_file altera_mem_if_checker_no_ifdef_params.sv SYSTEM_VERILOG PATH altera_mem_if_checker_no_ifdef_params.sv $simulators_novcd
		add_fileset_file altera_mem_if_checker_enable_vcdplus.sv SYSTEM_VERILOG PATH altera_mem_if_checker_enable_vcdplus.sv $simulators_vcd
		
		add_fileset_file [file join mentor altera_mem_if_checker_no_ifdef_params.sv] SYSTEM_VERILOG_ENCRYPT PATH [file join mentor altera_mem_if_checker_enable_vcdplus.sv] {MENTOR_SPECIFIC}
	} else {
		set simulators [::alt_mem_if::util::hwtcl_utils::get_simulator_attributes 1]
		add_fileset_file altera_mem_if_checker_enable_vcdplus.sv SYSTEM_VERILOG PATH altera_mem_if_checker_no_ifdef_params.sv $simulators
		add_fileset_file [file join mentor altera_mem_if_checker_no_ifdef_params.sv] SYSTEM_VERILOG_ENCRYPT PATH [file join mentor altera_mem_if_checker_no_ifdef_params.sv] {MENTOR_SPECIFIC}
	}
}

proc generate_verilog_sim {name} {
	if {[string compare -nocase [get_parameter_value ENABLE_VCDPLUS] "true"] == 0} {
		set simulators_vcd [list]
		set simulators_novcd [list]
		foreach simatt [::alt_mem_if::util::hwtcl_utils::get_simulator_attributes 0] {
			if {[string compare -nocase $simatt "CADENCE_SPECIFIC"] == 0} {
				lappend simulators_novcd $simatt
			} else {
				lappend simulators_vcd $simatt
			}
		}
		add_fileset_file altera_mem_if_checker_no_ifdef_params.sv SYSTEM_VERILOG PATH altera_mem_if_checker_no_ifdef_params.sv $simulators_novcd
		add_fileset_file altera_mem_if_checker_enable_vcdplus.sv SYSTEM_VERILOG PATH altera_mem_if_checker_enable_vcdplus.sv $simulators_vcd
	} else {
		add_fileset_file altera_mem_if_checker_no_ifdef_params.sv SYSTEM_VERILOG PATH altera_mem_if_checker_no_ifdef_params.sv
	}
}

proc generate_synth {name} {
	_error "[get_module_property DESCRIPTION] does not support the QUARTUS_SYNTH fileset"
}


add_parameter ENABLE_VCDPLUS BOOLEAN false
set_parameter_property ENABLE_VCDPLUS DISPLAY_NAME "Enable VCDplus in initial block"
set_parameter_property ENABLE_VCDPLUS DESCRIPTION "Use this parameter to add vcspluson to the initial block in the simulation model"
set_parameter_property ENABLE_VCDPLUS HDL_PARAMETER true

add_parameter NUM_STATUS_INTERFACES_MAX INTEGER 12
set_parameter_property NUM_STATUS_INTERFACES_MAX VISIBLE false
set_parameter_property NUM_STATUS_INTERFACES_MAX AFFECTS_ELABORATION true

add_parameter NUM_STATUS_INTERFACES_TGEN INTEGER 1
set_parameter_property NUM_STATUS_INTERFACES_TGEN DISPLAY_NAME "Number of driver status interfaces"
set_parameter_property NUM_STATUS_INTERFACES_TGEN DESCRIPTION "Use this parameter to set the number of each of the driver status interfaces"
set_parameter_property NUM_STATUS_INTERFACES_TGEN AFFECTS_ELABORATION true
set_parameter_property NUM_STATUS_INTERFACES_TGEN ALLOWED_RANGES {1:12}

add_parameter NUM_STATUS_INTERFACES INTEGER 1
set_parameter_property NUM_STATUS_INTERFACES DISPLAY_NAME "Number of status interfaces"
set_parameter_property NUM_STATUS_INTERFACES DESCRIPTION "Use this parameter to set the number of each of the memory interface status interfaces"
set_parameter_property NUM_STATUS_INTERFACES AFFECTS_ELABORATION true
set_parameter_property NUM_STATUS_INTERFACES ALLOWED_RANGES {1:12}

set_module_property elaboration_Callback ip_elaborate



proc ip_elaborate {} {

	set toplevel_name "altera_mem_if_checker_no_ifdef_params"
	if {[string compare -nocase [get_parameter_value ENABLE_VCDPLUS] "true"] == 0} {
		set toplevel_name "altera_mem_if_checker_enable_vcdplus"
	}

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
	
	set num_tgen_status [get_parameter_value NUM_STATUS_INTERFACES_TGEN]
        set num_emif_status [get_parameter_value NUM_STATUS_INTERFACES]
	set num_status_max [get_parameter_value NUM_STATUS_INTERFACES_MAX]

	
	for {set ii 0} {$ii < $num_status_max} {incr ii} {

		if {$ii == 0} {
			set suffix ""
		} else {
			set suffix "_${ii}"
		}

		add_interface "drv_status${suffix}" conduit end
		set_interface_property "drv_status${suffix}" ENABLED true
		add_interface_port "drv_status${suffix}" "test_complete${suffix}" test_complete Input 1
		add_interface_port "drv_status${suffix}" "fail${suffix}" fail Input 1
		add_interface_port "drv_status${suffix}" "pass${suffix}" pass Input 1
	
		add_interface "emif_status${suffix}" conduit end
		set_interface_property "emif_status${suffix}" ENABLED true
		add_interface_port "emif_status${suffix}" "local_init_done${suffix}" local_init_done Input 1
		add_interface_port "emif_status${suffix}" "local_cal_success${suffix}" local_cal_success Input 1
		add_interface_port "emif_status${suffix}" "local_cal_fail${suffix}" local_cal_fail Input 1
		if {$ii >= $num_tgen_status} {
			set_port_property "test_complete${suffix}" termination true
			set_port_property "test_complete${suffix}" termination_value "1'b1"
			set_port_property "fail${suffix}" termination true
			set_port_property "fail${suffix}" termination_value "1'b0"
			set_port_property "pass${suffix}" termination true
			set_port_property "pass${suffix}" termination_value "1'b1"
                }

                if {$ii >= $num_emif_status} {
			set_port_property "local_init_done${suffix}" termination true
			set_port_property "local_init_done${suffix}" termination_value "1'b1"
			set_port_property "local_cal_success${suffix}" termination true
			set_port_property "local_cal_success${suffix}" termination_value "1'b1"
			set_port_property "local_cal_fail${suffix}" termination true
			set_port_property "local_cal_fail${suffix}" termination_value "1'b0"
		}
	}
}
