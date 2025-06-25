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


package provide alt_mem_if::util::hwtcl_utils 0.1

package require alt_mem_if::util::messaging
package require alt_mem_if::util::qini


namespace eval ::alt_mem_if::util::hwtcl_utils:: {
	
	
	variable COMPONENT_ROOT_FOLDER "Memories and Memory Controllers/External Memory Interfaces"
	variable INTERNAL_COMPONENT_ROOT_FOLDER "$COMPONENT_ROOT_FOLDER/Internal Components"

	namespace import ::alt_mem_if::util::messaging::*
	
}


proc ::alt_mem_if::util::hwtcl_utils::_add_parameter {parameter_name parameter_type parameter_default} {

	if {[lsearch -exact [get_parameters] $parameter_name] == -1} {
		add_parameter $parameter_name $parameter_type $parameter_default
	} else {
		_error "Fatal Error: Parameter $parameter_name is already defined!"
	}

	return 1
}

proc ::alt_mem_if::util::hwtcl_utils::rename_exported_interface_ports {instance_name interface_name exported_interface_name {old_index ""} {new_index ""}} {

	_dprint 1 "Preparing to rename interface port of interface $exported_interface_name based on interface $interface_name on $instance_name"
	
	if {[lsearch -exact [get_instances] $instance_name] == -1} {
		_eprint "Unknown instance $instance_name"
		_eprint "Valid instances are: [get_instances]"
		_error "Fatal Error: Illegal instance name $instance_name"
	}
	
	if {[lsearch -exact [get_instance_interfaces $instance_name] $interface_name] == -1} {
		_eprint "Unknown interface $interface_name on $instance_name"
		_eprint "Valid instances are: [get_instance_interfaces $instance_name]"
		_error "Fatal Error: Illegal interface name $interface_name on $instance_name"
	}

	if {[lsearch -exact [get_interfaces] $exported_interface_name] == -1} {
		_eprint "Unknown interface $exported_interface_name"
		_eprint "Valid instances are: [get_interfaces]"
		_error "Fatal Error: Illegal interface name $exported_interface_name"
	}


	set port_map [list]
	foreach port_name [get_instance_interface_ports $instance_name $interface_name] {
                if { [string compare $old_index ""] == 0 || [string compare $new_index ""] == 0 } {
                        _dprint 1 "Performing mapping of $port_name"
		        lappend port_map $port_name
		        lappend port_map $port_name
                } else {
                        regsub -all $old_index $port_name $new_index new_port_name
                        _dprint 1 "Performing mapping of $port_name"
		        lappend port_map $new_port_name
		        lappend port_map $port_name
                }
	}
	_dprint 2 "Complete mapping of $exported_interface_name interface = $port_map"
	set_interface_property $exported_interface_name PORT_NAME_MAP $port_map


	return 1
}


proc ::alt_mem_if::util::hwtcl_utils::set_interface_termination {interface_name interface_active} {

	if {$interface_active} {
		foreach port_name [get_interface_ports $interface_name] {
			set_port_property $port_name termination false
		}
	} else {
		foreach port_name [get_interface_ports $interface_name] {
			set_port_property $port_name termination true
			if {[string compare -nocase [get_port_property $port_name direction] "input"] == 0} {
				set_port_property $port_name termination_value 0
			}
		}
	}
}

proc ::alt_mem_if::util::hwtcl_utils::get_simulator_attributes {{nomentor 0}} {

	set sim_att_list [list \
		"CADENCE_SPECIFIC" \
		"SYNOPSYS_SPECIFIC" \
		"ALDEC_SPECIFIC" \
	]

	if {$nomentor == 0} {
		lappend sim_att_list "MENTOR_SPECIFIC"
	}

	return $sim_att_list
}

proc ::alt_mem_if::util::hwtcl_utils::get_file_type {file_name {rtl_only 1} {encrypted 0} {allow_all 0}} {

	set file_ext [file extension $file_name]

	if {[regexp -nocase {^[ ]*\.iv[ ]*$} [file extension $file_name]] == 1 } {
		return "VERILOG_INCLUDE"
	} elseif {[regexp -nocase {^[ ]*\.v[ ]*$} [file extension $file_name]] == 1 } {
		if {$encrypted} {
			return "VERILOG_ENCRYPT"
		} else {
			return "VERILOG"
		}
	} elseif {[regexp -nocase {^[ ]*\.sv[ ]*$} [file extension $file_name]] == 1 } {
		if {$encrypted} {
			return "SYSTEM_VERILOG_ENCRYPT"
		} else {
			return "SYSTEM_VERILOG"
		}
	} elseif {[regexp -nocase {^[ ]*\.vho[ ]*$|^[ ]*\.vhd[ ]*$|^[ ]*\.vhdl[ ]*$} [file extension $file_name]] == 1 } {
		return "VHDL"
	} elseif {[regexp -nocase {^[ ]*\.mif[ ]*$} [file extension $file_name]] == 1 } {

			return "MIF"

	} elseif {[regexp -nocase {^[ ]*\.hex[ ]*$} [file extension $file_name]] == 1 } {
		if {$rtl_only} {
			_error "Fatal Error: Attempting to return file type $file_ext for file $file_name in RTL only fileset"
		} else {
			return "HEX"
		}
	} elseif {[regexp -nocase {^[ ]*\.dat[ ]*$} [file extension $file_name]] == 1 } {
		if {$rtl_only} {
			_error "Fatal Error: Attempting to return file type $file_ext for file $file_name in RTL only fileset"
		} else {
			return "DAT"
		}
	} elseif {[regexp -nocase {^[ ]*\.sdc[ ]*$} [file extension $file_name]] == 1 } {
		if {$rtl_only} {
			_error "Fatal Error: Attempting to return file type $file_ext for file $file_name in RTL only fileset"
		} else {
			return "SDC"
		}
	} elseif {[regexp -nocase {^[ ]*\.txt[ ]*$|^[ ]*\.sopc[ ]*$|^[ ]*\.sopcinfo[ ]*$|^[ ]*\.tcl[ ]*$|^[ ]*\.log[ ]*$|^[ ]*\.so[ ]*$|^[ ]*\.ppf[ ]*$|^[ ]*\.[cho][ ]*$} [file extension $file_name]] == 1 } {
		if {$rtl_only} {
			_error "Fatal Error: Attempting to return file type $file_ext for file $file_name in RTL only fileset"
		} else {
			return "OTHER"
		}
	} elseif {$allow_all} {
			return "OTHER"
	} else {
		error "Fatal Error: Unknown file type $file_ext for file $file_name"
	}

}


proc ::alt_mem_if::util::hwtcl_utils::print_user_parameter_values {} {
	if {[::alt_mem_if::util::qini::qini_value "debug_msg_level" 0] > 0} {
		foreach param_name [lsort [get_parameters]] {
			if {[get_parameter_property $param_name DERIVED] == 0} {
				_dprint 1 "Non-derived user parameter: $param_name = [get_parameter_value $param_name]"
			}
		}
	}
}


proc ::alt_mem_if::util::hwtcl_utils::set_module_internal_mode {} {

	if {[::alt_mem_if::util::qini::cfg_is_on "alt_mem_if_enable_internal_components"]} {
		set_module_property INTERNAL false
	} else {
		set_module_property INTERNAL true
	}

}


proc ::alt_mem_if::util::hwtcl_utils::memory_controller_group_name {} {
	variable COMPONENT_ROOT_FOLDER
	variable INTERNAL_COMPONENT_ROOT_FOLDER
	
	return "${INTERNAL_COMPONENT_ROOT_FOLDER}/Memory Controllers"
}

proc ::alt_mem_if::util::hwtcl_utils::memory_controller_components_group_name {} {
	variable COMPONENT_ROOT_FOLDER
	variable INTERNAL_COMPONENT_ROOT_FOLDER
	
	return "${INTERNAL_COMPONENT_ROOT_FOLDER}/Memory Controller Components"
}

proc ::alt_mem_if::util::hwtcl_utils::memory_models_group_name {} {
	variable COMPONENT_ROOT_FOLDER
	variable INTERNAL_COMPONENT_ROOT_FOLDER
	
	return "${COMPONENT_ROOT_FOLDER}/Memory Models"
}

proc ::alt_mem_if::util::hwtcl_utils::memory_perf_monitors_group_name {} {
	variable COMPONENT_ROOT_FOLDER
	variable INTERNAL_COMPONENT_ROOT_FOLDER
	
	return "${COMPONENT_ROOT_FOLDER}/Performance Monitors"
}

proc ::alt_mem_if::util::hwtcl_utils::memory_perf_monitor_components_group_name {} {
	variable COMPONENT_ROOT_FOLDER
	variable INTERNAL_COMPONENT_ROOT_FOLDER
	
	return "${INTERNAL_COMPONENT_ROOT_FOLDER}/Performance Monitor Components"
}

proc ::alt_mem_if::util::hwtcl_utils::memory_pattern_gen_group_name {} {
	variable COMPONENT_ROOT_FOLDER
	variable INTERNAL_COMPONENT_ROOT_FOLDER
	
	return "${COMPONENT_ROOT_FOLDER}/Pattern Generators"
}

proc ::alt_mem_if::util::hwtcl_utils::memory_pattern_gen_components_group_name {} {
	variable COMPONENT_ROOT_FOLDER
	variable INTERNAL_COMPONENT_ROOT_FOLDER
	
	return "${INTERNAL_COMPONENT_ROOT_FOLDER}/Pattern Generator Components"
}

proc ::alt_mem_if::util::hwtcl_utils::example_design_checkers_group_name {} {
	variable COMPONENT_ROOT_FOLDER
	variable INTERNAL_COMPONENT_ROOT_FOLDER
	
	return "${COMPONENT_ROOT_FOLDER}/Example Design Checkers"
}


proc ::alt_mem_if::util::hwtcl_utils::memory_phys_group_name {} {
	variable COMPONENT_ROOT_FOLDER
	variable INTERNAL_COMPONENT_ROOT_FOLDER
	
	return "${INTERNAL_COMPONENT_ROOT_FOLDER}/Memory PHYs"
}

proc ::alt_mem_if::util::hwtcl_utils::memory_sequencer_components_group_name {} {
	variable COMPONENT_ROOT_FOLDER
	variable INTERNAL_COMPONENT_ROOT_FOLDER
	
	return "${INTERNAL_COMPONENT_ROOT_FOLDER}/Memory Sequencer Components"
}

proc ::alt_mem_if::util::hwtcl_utils::memory_sequencers_group_name {} {
	variable COMPONENT_ROOT_FOLDER
	variable INTERNAL_COMPONENT_ROOT_FOLDER
	
	return "${INTERNAL_COMPONENT_ROOT_FOLDER}/Memory Sequencers"
}

proc ::alt_mem_if::util::hwtcl_utils::memory_afi_mux_group_name {} {
	variable COMPONENT_ROOT_FOLDER
	variable INTERNAL_COMPONENT_ROOT_FOLDER
	
	return "${INTERNAL_COMPONENT_ROOT_FOLDER}/Memory AFI Multiplexers"
}

proc ::alt_mem_if::util::hwtcl_utils::memory_afi_gasket_group_name {} {
	variable COMPONENT_ROOT_FOLDER
	variable INTERNAL_COMPONENT_ROOT_FOLDER
	
	return "${INTERNAL_COMPONENT_ROOT_FOLDER}/Memory AFI Gaskets"
}

proc ::alt_mem_if::util::hwtcl_utils::example_designs_group_name {} {
	variable COMPONENT_ROOT_FOLDER
	variable INTERNAL_COMPONENT_ROOT_FOLDER
	
	return "${INTERNAL_COMPONENT_ROOT_FOLDER}/Example Designs"
}

proc ::alt_mem_if::util::hwtcl_utils::example_design_components_group_name {} {
	variable COMPONENT_ROOT_FOLDER
	variable INTERNAL_COMPONENT_ROOT_FOLDER
	
	return "${INTERNAL_COMPONENT_ROOT_FOLDER}/Example Design Components"
}

proc ::alt_mem_if::util::hwtcl_utils::mem_ifs_group_name {} {
	variable COMPONENT_ROOT_FOLDER
	variable INTERNAL_COMPONENT_ROOT_FOLDER
	
	return "${COMPONENT_ROOT_FOLDER}"
}

proc ::alt_mem_if::util::hwtcl_utils::mem_if_components_group_name {} {
	variable COMPONENT_ROOT_FOLDER
	variable INTERNAL_COMPONENT_ROOT_FOLDER
	
	return "${INTERNAL_COMPONENT_ROOT_FOLDER}/Memory Interface Components"
}

proc ::alt_mem_if::util::hwtcl_utils::log2 {n} {
	return [expr {log($n) / log(2)}]
}


proc ::alt_mem_if::util::hwtcl_utils::is_hps_top {} {

	return [expr [string compare -nocase [get_module_property NAME] "altera_hps"] == 0]

}

proc ::alt_mem_if::util::hwtcl_utils::combined_callbacks {} {

	return "false"

}

proc ::alt_mem_if::util::hwtcl_utils::param_compare {param value} {

	if {[string compare -nocase [get_parameter_value $param] $value] == 0} {
		return 1
	} else {
		return 0
	}
}

proc ::alt_mem_if::util::hwtcl_utils::param_is_on {param} {

	set value [get_parameter_value $param]
	if {[string compare -nocase $value "true"] == 0} {
		return 1
	} elseif {$value == 1} {
		return 1
	} else {
		return 0
	}
}


proc ::alt_mem_if::util::hwtcl_utils::_init {} {

	return 1
}


::alt_mem_if::util::hwtcl_utils::_init
