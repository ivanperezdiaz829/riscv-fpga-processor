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


package provide alt_mem_if::gui::abstract_ram 0.1

package require alt_mem_if::util::messaging
package require alt_mem_if::util::hwtcl_utils


namespace eval ::alt_mem_if::gui::abstract_ram:: {
	variable guis
	
	namespace import ::alt_mem_if::util::messaging::*

}


proc ::alt_mem_if::gui::abstract_ram::create_parameters {} {
	
	_dprint 1 "Preparing to create parameters for abstract_ram"

	::alt_mem_if::util::hwtcl_utils::_add_parameter ENABLE_ABS_RAM_MEM_INIT boolean false 
	set_parameter_property ENABLE_ABS_RAM_MEM_INIT DISPLAY_NAME "Enable support for Nios II ModelSim flow in Eclipse"
	set_parameter_property ENABLE_ABS_RAM_MEM_INIT DESCRIPTION "Turn on to optimize the initialization of the memory contents for simulation."
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter ENABLE_ABS_RAM_INTERNAL boolean false 
	set_parameter_property ENABLE_ABS_RAM_INTERNAL DERIVED true
	set_parameter_property ENABLE_ABS_RAM_INTERNAL VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter ENABLE_ABSTRACT_RAM boolean false 
	set_parameter_property ENABLE_ABSTRACT_RAM DERIVED true
	set_parameter_property ENABLE_ABSTRACT_RAM VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter ABS_RAM_MEM_INIT_FILENAME string "meminit"
	set_parameter_property ABS_RAM_MEM_INIT_FILENAME DISPLAY_NAME "Memory initialization file basename"
	set_parameter_property ABS_RAM_MEM_INIT_FILENAME DESCRIPTION "The basename of the memory initialization filename.
	The initialization file will be created by the testbench generator.
	Provide a unique name for each UniPHY instance.
	No extension or filepath is required."
	set_parameter_property ABS_RAM_MEM_INIT_FILENAME VISIBLE false

	set_module_assignment postgeneration.simulation.init_file.param_name "ABS_RAM_MEM_INIT_FILENAME"
	set_module_assignment postgeneration.simulation.init_file.type "MEM_INIT"

	return 1
}


proc ::alt_mem_if::gui::abstract_ram::create_memif_gui {} {

	if {[::alt_mem_if::util::hwtcl_utils::is_hps_top]} {
		set_parameter_property ENABLE_ABS_RAM_MEM_INIT Visible false
		set_parameter_property ABS_RAM_MEM_INIT_FILENAME Visible false
		return
	}
	
	add_display_item "Simulation Options" ENABLE_ABS_RAM_MEM_INIT PARAMETER
	add_display_item "Simulation Options" ABS_RAM_MEM_INIT_FILENAME PARAMETER

	return 1
}



proc ::alt_mem_if::gui::abstract_ram::validate_component {} {

	if {[string compare -nocase [get_parameter_value ENABLE_ABS_RAM_MEM_INIT] "true"] == 0 ||
		[string compare -nocase [get_parameter_value ENABLE_ABS_RAM_INTERNAL] "true"] == 0} {
		if {[string compare -nocase [get_parameter_value HARD_EMIF] "true"] == 0} {
			_eprint "Nios II ModelSim flow in Eclipse is not supported for hard memory interfaces"
			set_parameter_value ENABLE_ABSTRACT_RAM false
		} else {
			set_parameter_value ENABLE_ABSTRACT_RAM true
		}
	} else {
		set_parameter_value ENABLE_ABSTRACT_RAM false
	}

	if {[string compare -nocase [get_parameter_value ENABLE_ABS_RAM_MEM_INIT] "true"] == 0} {
		if {[regexp -nocase {^[ ]*$} [get_parameter_value ABS_RAM_MEM_INIT_FILENAME] match] == 1} {
			_eprint "No memory initization file specified. This is required for the Eclipse run-as ModelSim flow"
		} elseif {[regexp -nocase {^[a-zA-Z0-9_]+$} [get_parameter_value ABS_RAM_MEM_INIT_FILENAME] match] == 0} {
			_eprint "Illegal filename [get_parameter_value ABS_RAM_MEM_INIT_FILENAME] specified.  Only [A-Za-z0-9_] is valid for character in file"
		}
		set_parameter_property ABS_RAM_MEM_INIT_FILENAME VISIBLE true
	} else {
		set_parameter_property ABS_RAM_MEM_INIT_FILENAME VISIBLE false
	}
	
	set validation_pass 1

	return $validation_pass

}

proc ::alt_mem_if::gui::abstract_ram::elaborate_component {} {
	
	if {[string compare -nocase [get_parameter_value ENABLE_ABS_RAM_MEM_INIT] "true"] == 0} {
		set_parameter_property ABS_RAM_MEM_INIT_FILENAME ENABLED true
	} else {
		set_parameter_property ABS_RAM_MEM_INIT_FILENAME ENABLED false
	}
	
	return 1
}


proc ::alt_mem_if::gui::abstract_ram::_init {} {
}


::alt_mem_if::gui::abstract_ram::_init
