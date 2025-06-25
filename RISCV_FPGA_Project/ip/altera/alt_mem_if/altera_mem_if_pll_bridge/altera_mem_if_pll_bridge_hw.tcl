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
package require alt_mem_if::util::qini
package require alt_mem_if::gui::system_info
package require alt_mem_if::gen::uniphy_interfaces
package require alt_mem_if::util::hwtcl_utils

namespace import ::alt_mem_if::util::messaging::*



set_module_property DESCRIPTION "External Memory PLL block bridge"
set_module_property NAME altera_mem_if_pll_bridge
set_module_property VERSION 13.1
::alt_mem_if::util::hwtcl_utils::set_module_internal_mode
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property GROUP [::alt_mem_if::util::hwtcl_utils::memory_phys_group_name]
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "External Memory PLL block bridge"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL TRUE
set_module_property HIDE_FROM_SOPC true

add_display_item "" "Block Diagram" GROUP


alt_mem_if::gui::system_info::create_parameters


::alt_mem_if::util::hwtcl_utils::_add_parameter SEQUENCER_TYPE STRING "NIOS"
set_parameter_property SEQUENCER_TYPE DERIVED false
set_parameter_property SEQUENCER_TYPE DISPLAY_NAME "Sequencer optimization"
set_parameter_property SEQUENCER_TYPE AFFECTS_ELABORATION true
set_parameter_property SEQUENCER_TYPE ALLOWED_RANGES {"NIOS:Performance (Nios II-based Sequencer)" "RTL:Area (RTL Sequencer)"}
set_parameter_property SEQUENCER_TYPE DESCRIPTION "Selects optimized version of the sequencer, which performs memory calibration tasks.
Choose \"Performance\" to enable the Nios(R) II-based sequencer, or \"Area\" for a simple RTL-based sequencer."


::alt_mem_if::util::hwtcl_utils::_add_parameter RATE STRING "Half" 
set_parameter_property RATE DISPLAY_NAME "Rate on Avalon-MM interface"
set_parameter_property RATE UNITS None
set_parameter_property RATE AFFECTS_ELABORATION true
set_parameter_property RATE DESCRIPTION "This setting defines the width of data bus on the Avalon-MM interface.  
A setting of Full results in a width of 2x the memory data width. A setting of Half results in a width of 4x the memory data width. A setting of Quarter results in a width of 8x the memory data width."
set_parameter_property RATE ALLOWED_RANGES {Half Full Quarter}


::alt_mem_if::util::hwtcl_utils::_add_parameter CORE_PERIPHERY_DUAL_CLOCK BOOLEAN false

::alt_mem_if::util::hwtcl_utils::_add_parameter USE_DR_CLK BOOLEAN false

::alt_mem_if::util::hwtcl_utils::_add_parameter DUPLICATE_PLL_FOR_PHY_CLK boolean false



::alt_mem_if::util::hwtcl_utils::_add_parameter NUM_PLL_SHARING_INTERFACES INTEGER 1
set_parameter_property NUM_PLL_SHARING_INTERFACES DISPLAY_NAME "Number of PLL sharing interfaces"
set_parameter_property NUM_PLL_SHARING_INTERFACES DESCRIPTION "When set to \"No sharing\", a PLL block is instantiated but no PLL signals are exported.<br>When set to \"Master\", a PLL block is instantiated and the signals are exported.<br>When set to \"Slave\", a PLL interface is exposed and an external PLL Master must be connected to drive them."
set_parameter_property NUM_PLL_SHARING_INTERFACES ALLOWED_RANGES {1 2 3 4 5 6 7 8 9 10}
set_parameter_property NUM_PLL_SHARING_INTERFACES AFFECTS_ELABORATION true








if {[string compare -nocase [::alt_mem_if::util::hwtcl_utils::combined_callbacks] "false"] == 0} {
	set_module_property Validation_Callback ip_validate
	set_module_property elaboration_Callback ip_elaborate
} else {
	set_module_property elaboration_Callback combined_callback
}

proc combined_callback {} {
	ip_validate
	ip_elaborate
}

proc ip_validate {} {
	_dprint 1 "Running IP Validation for [get_module_property NAME]"

	alt_mem_if::gui::system_info::validate_component
}

proc ip_elaborate {} {
	_dprint 1 "Running IP Elaboration for [get_module_property NAME]"

	alt_mem_if::gui::system_info::elaborate_component


	::alt_mem_if::gen::uniphy_interfaces::pll_sharing "sink" "_in"

	for {set ii 0} {$ii < [get_parameter_value NUM_PLL_SHARING_INTERFACES]} {incr ii} {

		if {$ii == 0} {
			set suffix {}
		} else {
			set suffix "_${ii}"
		}

		::alt_mem_if::gen::uniphy_interfaces::pll_sharing "source" $suffix

		set port_list [get_interface_ports "pll_sharing${suffix}"]
		foreach port $port_list {
			set_port_property $port DRIVEN_BY "[string trimright $port $suffix]_in"
		}

	}

}
