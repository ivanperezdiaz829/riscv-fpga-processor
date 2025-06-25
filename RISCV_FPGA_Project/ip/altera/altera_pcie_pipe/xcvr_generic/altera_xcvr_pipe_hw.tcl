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



# +-----------------------------------
# | 
# | TCL component for PHY IP Core for PCI Express (PIPE) without reconfig
# | $Header: //acds/rel/13.1/ip/altera_pcie_pipe/xcvr_generic/altera_xcvr_pipe_hw.tcl#1 $
# | 
# +-----------------------------------

# +-----------------------------------
# | request TCL package from ACDS 13.1
# | 
package require -exact sopc 10.1
# | 
# +-----------------------------------

# +-----------------------------------
# | module pcie
# | 
set_module_property NAME altera_xcvr_pipe
set_module_property VERSION 13.1
set_module_property INTERNAL true 
set_module_property GROUP "Interface Protocols/PCI Express"
set_module_property DISPLAY_NAME "PHY IP Core for PCI Express (PIPE)" 
set_module_property AUTHOR "Altera Corporation"
set_module_property DESCRIPTION "Implements the PCS and PMA modules as defined by the Intel PHY Interface for PCI Express (PIPE) Architecture specification."
set_module_property DATASHEET_URL "http://www.altera.com/literature/ug/xcvr_user_guide.pdf"

add_fileset sim_vhdl SIM_VHDL generate_vhdl_sim
set_fileset_property sim_vhdl TOP_LEVEL altera_xcvr_pipe
add_fileset sim_verilog SIM_VERILOG generate_verilog_sim
set_fileset_property sim_verilog TOP_LEVEL altera_xcvr_pipe
add_fileset synth2 QUARTUS_SYNTH generate_synth
set_fileset_property synth2  TOP_LEVEL altera_xcvr_pipe
set_module_property ALLOW_GREYBOX_GENERATION true 

set_module_property EDITABLE true
set_module_property ELABORATION_CALLBACK elaboration_callback
set_module_property VALIDATION_CALLBACK validation_callback
set_module_property ANALYZE_HDL false
# | 
# +-----------------------------------


# +-----------------------------------
# | tabs
# |
add_display_item "" "General Options" GROUP tab

# Use alt_xcvr TCL packages
lappend auto_path $env(QUARTUS_ROOTDIR)/../ip/altera/alt_xcvr/altera_xcvr_reset_control
lappend auto_path $env(QUARTUS_ROOTDIR)/../ip/altera/alt_xcvr/alt_xcvr_tcl_packages
package require alt_xcvr::gui::pll_reconfig
package require alt_xcvr::gui::messages
package require alt_xcvr::utils::params_and_ports
package require alt_xcvr::utils::fileset
package require altera_xcvr_reset_control::fileset

#send_message info "hw.tcl dir is [get_module_property MODULE_DIRECTORY]"
source altera_xcvr_pipe_common.tcl


# +-----------------------------------
# | define interfaces and ports
# | 
proc elaboration_callback { } {

	# declare ports and mappings for elaboration callback
	common_clock_interfaces
	set_parameter_value mgmt_clk_in_mhz [expr [get_parameter_value mgmt_clk_in_hz] / 1000000]

	#PIPE_RATE:0 for channel_based; 1 for shared
	common_pipe_interface_ports 1 

	# add memory-mapped slave interface, with 9-bit wide word address, readLatency of 0 (uses waitrequest)
	common_mgmt_interface 9 0

        # add conduit ports for reconfig  
        common_add_dynamic_reconfig_conduits 
}

# +-----------------------------------
# | validate parameters
# | 
proc validation_callback {} {

	common_parameter_validation 
	validate_reconfiguration_parameters 
}

# | 
# +-----------------------------------

# +-----------------------------------
# | parameters
# | 
common_add_parameters_for_native_phy 
add_extra_parameters_for_top_phy  

# +-----------------------------------
# | files
# | 
pipe_decl_fileset_groups_top .


proc generate_vhdl_sim {name} {
	set device_family [get_parameter_value device_family]
	# Workaround to allow legacy cores which did not have the device_family parameter to still generate properly 
	# Stratix V is chosen because it was the only option at the time
	if {![::alt_xcvr::utils::device::has_s5_style_hssi $device_family] && ![::alt_xcvr::utils::device::has_a5_style_hssi $device_family]} {
		set device_family "Stratix V"
	}
	if {[::alt_xcvr::utils::device::has_s5_style_hssi $device_family]} {
		common_add_fileset_files {S5 ALL_HDL ALL_SIM ALTERA_XCVR_RESET_CONTROL ALT_XCVR_CSR} [concat PLAIN [common_fileset_tags_all_simulators] ]
#{PLAIN MENTOR MSIM_SCRIPT}
	} elseif {[::alt_xcvr::utils::device::has_a5_style_hssi $device_family]} {
		common_add_fileset_files {A5 ALL_HDL ALL_SIM ALTERA_XCVR_RESET_CONTROL ALT_XCVR_CSR} [concat PLAIN [common_fileset_tags_all_simulators] ] 
#{PLAIN MENTOR MSIM_SCRIPT}
	}
}

proc generate_verilog_sim {name} {
	set device_family [get_parameter_value device_family]
	# Workaround to allow legacy cores which did not have the device_family parameter to still generate properly 
	# Stratix V is chosen because it was the only option at the time
	if { ![::alt_xcvr::utils::device::has_s5_style_hssi $device_family] && ![::alt_xcvr::utils::device::has_a5_style_hssi $device_family] } {
		set device_family "Stratix V"
	}
	if {[::alt_xcvr::utils::device::has_s5_style_hssi $device_family]} {
		common_add_fileset_files {S5 ALL_HDL ALL_SIM ALTERA_XCVR_RESET_CONTROL ALT_XCVR_CSR} [concat PLAIN [common_fileset_tags_all_simulators] ]
# {PLAIN MSIM_SCRIPT}
	} elseif {[::alt_xcvr::utils::device::has_a5_style_hssi $device_family]} {
		common_add_fileset_files {A5 ALL_HDL ALL_SIM ALTERA_XCVR_RESET_CONTROL ALT_XCVR_CSR} [concat PLAIN [common_fileset_tags_all_simulators] ]
#{PLAIN MSIM_SCRIPT}
	}

}


proc generate_synth {name} {
	set device_family [get_parameter_value device_family]
	# Workaround to allow legacy cores which did not have the device_family parameter to still generate properly 
	# Stratix V is chosen because it was the only option at the time
	if { ![::alt_xcvr::utils::device::has_s5_style_hssi $device_family] && ![::alt_xcvr::utils::device::has_a5_style_hssi $device_family] } {
		set device_family "Stratix V"
	}
	if {[::alt_xcvr::utils::device::has_s5_style_hssi $device_family]} {
		common_add_fileset_files {S5 ALL_HDL ALTERA_XCVR_RESET_CONTROL ALT_XCVR_CSR} {PLAIN QIP}
	} elseif {[::alt_xcvr::utils::device::has_a5_style_hssi $device_family]} {
		common_add_fileset_files {A5 ALL_HDL ALTERA_XCVR_RESET_CONTROL ALT_XCVR_CSR} {PLAIN QIP}
	}
}
