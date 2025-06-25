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
package require alt_mem_if::gui::uniphy_dll
package require alt_mem_if::gui::system_info
package require alt_mem_if::gen::uniphy_interfaces
package require alt_mem_if::util::hwtcl_utils

namespace import ::alt_mem_if::util::messaging::*



set_module_property DESCRIPTION "External Memory DLL block bridge"
set_module_property NAME altera_mem_if_dll_bridge
set_module_property VERSION 13.1
::alt_mem_if::util::hwtcl_utils::set_module_internal_mode
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property GROUP [::alt_mem_if::util::hwtcl_utils::memory_phys_group_name]
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "External Memory DLL block bridge"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL TRUE
set_module_property HIDE_FROM_SOPC true

add_display_item "" "Block Diagram" GROUP


alt_mem_if::gui::uniphy_dll::create_parameters 1
alt_mem_if::gui::system_info::create_parameters


::alt_mem_if::util::hwtcl_utils::_add_parameter HCX_COMPAT_MODE boolean false
set_parameter_property HCX_COMPAT_MODE VISIBLE false
set_parameter_property HCX_COMPAT_MODE DISPLAY_NAME "HardCopy Compatibility Mode"
set_parameter_property HCX_COMPAT_MODE DESCRIPTION "When turned on, the UniPHY memory interface generated has all required HardCopy compatibility options enabled.
For example PLLs and DLLs will have their reconfiguration ports exposed."
alt_mem_if::gui::system_info::create_gui



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
	alt_mem_if::gui::uniphy_dll::validate_component 1
}

proc ip_elaborate {} {
	_dprint 1 "Running IP Elaboration for [get_module_property NAME]"

	alt_mem_if::gui::system_info::elaborate_component
	alt_mem_if::gui::uniphy_dll::elaborate_component


	::alt_mem_if::gen::uniphy_interfaces::dll_sharing "sink" "_in"
	if {[string compare -nocase [get_parameter_value HCX_COMPAT_MODE] "true"] == 0} {
		::alt_mem_if::gen::uniphy_interfaces::hcx_dll_sharing "sink" "_in"
	}

	for {set ii -1} {$ii < [get_parameter_value NUM_DLL_SHARING_INTERFACES]} {incr ii} {

		if {$ii == 0} {
			set suffix {}
		} elseif {$ii == -1} {
			set suffix "_x"
		} else {
			set suffix "_${ii}"
		}

		::alt_mem_if::gen::uniphy_interfaces::dll_sharing "source" $suffix

		set port_list [get_interface_ports "dll_sharing${suffix}"]
		foreach port $port_list {
			if {[string compare -nocase [get_port_property $port DIRECTION] "input"] == 0} {
				if {$ii == -1} {
					set_port_property "[string trimright $port $suffix]_in" DRIVEN_BY $port
				} 
			} else { 
				set_port_property $port DRIVEN_BY "[string trimright $port $suffix]_in"
			}
		}

		if {[string compare -nocase [get_parameter_value HCX_COMPAT_MODE] "true"] == 0} {
			::alt_mem_if::gen::uniphy_interfaces::hcx_dll_sharing "source" $suffix

			set port_list [get_interface_ports "hcx_dll_sharing${suffix}"]
			foreach port $port_list {
				set_port_property $port DRIVEN_BY "[string trimright $port $suffix]_in"
			}
		}

	}

	if {[::alt_mem_if::util::qini::cfg_is_on alt_mem_if_rtl_calib]} {
		if {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "STRATIXV"] == 0} { 
			
			add_interface rtl_dll_sharing_in conduit end
			set_interface_property rtl_dll_sharing_in ENABLED true
			add_interface_port rtl_dll_sharing_in dll_offsetctrlout_in dll_offset_ctrl_offsetctrlout INPUT [get_parameter_value DLL_DELAY_CTRL_WIDTH]
			
			add_interface rtl_dll_sharing_x conduit end
			set_interface_property rtl_dll_sharing_x ENABLED true
			add_interface_port rtl_dll_sharing_x dll_offsetctrlout_x dll_offset_ctrl_offsetctrlout OUTPUT [get_parameter_value DLL_DELAY_CTRL_WIDTH]
			set port_list [get_interface_ports "rtl_dll_sharing_x"]
			foreach port $port_list {
				set_port_property $port DRIVEN_BY "[string trimright $port _x]_in"
			}
				
		}
	}

}
