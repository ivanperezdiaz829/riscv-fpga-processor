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
# | TCL component for Interlaken (PCS) PHY, including reconfig
# | $Header: //acds/rel/13.1/ip/alt_interlaken/alt_interlaken_pcs/altera_xcvr_interlaken_hw.tcl#1 $
# | 
# +-----------------------------------

# +-----------------------------------
# | request TCL package from ACDS 13.1
# | 
package require -exact sopc 10.0
# | 
# +-----------------------------------

# +-----------------------------------
# | module alt_interlaken_pcs_sv
# | 
set_module_property NAME altera_xcvr_interlaken
set_module_property VERSION 13.1
set_module_property INTERNAL true
set_module_property GROUP "Interface Protocols/Interlaken"
set_module_property DISPLAY_NAME "Interlaken PHY"
set_module_property DESCRIPTION "A multiple-lane Interlaken PCS component with integrated PMA and management layers"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ELABORATION_CALLBACK elaboration_callback
set_module_property VALIDATION_CALLBACK validation_callback
set_module_property ANALYZE_HDL FALSE
set_module_property AUTHOR "Altera Corporation"
set_module_property DATASHEET_URL "http://www.altera.com/literature/ug/xcvr_user_guide.pdf"

#enable greybox support
set_module_property ALLOW_GREYBOX_GENERATION true

##VHDL For VHDL, VERILOG sim
add_fileset sim_vhdl SIM_VHDL generate_vhdl_sim
set_fileset_property sim_vhdl TOP_LEVEL altera_xcvr_interlaken
add_fileset sim_verilog SIM_VERILOG generate_verilog_sim
set_fileset_property sim_verilog TOP_LEVEL altera_xcvr_interlaken
add_fileset synth2 QUARTUS_SYNTH generate_synth
set_fileset_property synth2 TOP_LEVEL altera_xcvr_interlaken



# +-----------------------------------
# | tabs
# |
add_display_item "" "General Options" GROUP tab
add_display_item "" "Advanced Options" GROUP tab
#add_display_item "" "PLL Reconfiguration" GROUP tab

#add_display_item "" "Analog Options" GROUP tab


# | 
# +-----------------------------------

# | 
# +-----------------------------------
# Use alt_xcvr TCL packages
lappend auto_path $env(QUARTUS_ROOTDIR)/../ip/altera/alt_xcvr/alt_xcvr_tcl_packages
lappend auto_path $env(QUARTUS_ROOTDIR)/../ip/altera/alt_xcvr/altera_xcvr_reset_control
package require alt_xcvr::gui::pll_reconfig
package require alt_xcvr::gui::messages
package require alt_xcvr::utils::params_and_ports
package require alt_xcvr::utils::fileset
package require altera_xcvr_reset_control::fileset


#send_message info "hw.tcl dir is [get_module_property MODULE_DIRECTORY]"
source ../../altera_xcvr_generic/alt_xcvr_common.tcl
source ../../altera_xcvr_generic/sv/sv_xcvr_native_fileset.tcl
source ../../altera_xcvr_generic/ctrl/alt_xcvr_csr_fileset.tcl
source ./sv_xcvr_interlaken_common.tcl
#source ../../alt_xcvr_reconfig/alt_xcvr_reconfig/alt_xreconf_common.tcl

# +-----------------------------------
# | parameters
# | 
common_add_parameters_for_native_phy
#add_pll_reconfig_parameters "PLL Reconfiguration"

#source parameter_manager.tcl
#add_pma_parameters_raw
#add_extra_parameters_for_top_phy


# +-----------------------------------
# | files
# | 
sv_xcvr_native_decl_fileset_groups ../../altera_xcvr_generic
alt_xcvr_csr_decl_fileset_groups ../../altera_xcvr_generic 1
common_decl_files_for_sv_xcvr ../alt_interlaken_pcs_sv
common_decl_files_for_sv_top .
#decl_extra_files_for_top_phy ../../altera_xcvr_generic
#xreconf_decl_fileset_groups ../../alt_xcvr_reconfig
::altera_xcvr_reset_control::fileset::declare_files

# | 
# +-----------------------------------


# +-----------------------------------
# | define interfaces and ports
# | 
proc elaboration_callback { } {
	# declare ports and mappings for elaboration callback
	common_clock_interfaces
	#	set_parameter_value mgmt_clk_in_mhz [expr [get_parameter_value mgmt_clk_in_hz] / 1000000]

	#PIPE_RATE:0 for channel_based; 1 for shared
	common_interlaken_interface_ports 1 

	# add memory-mapped slave interface, with 9-bit wide word address, readLatency of 0 (uses waitrequest)
	common_mgmt_interface 9 0

        # add conduit ports for reconfig  
        common_add_dynamic_reconfig_conduits "Stratix V"

    } 



# +-----------------------------------
# | validate parameters
# | 
proc validation_callback {} {

	common_parameter_validation
        validate_reconfiguration_parameters "Stratix V"

} 




# +-----------------------------------
# | files
# | 
proc generate_vhdl_sim {name} {

    common_add_fileset_files {S5 ALL_HDL ALL_SIM ALTERA_XCVR_RESET_CONTROL ALT_XCVR_CSR} {PLAIN MENTOR MSIM_SCRIPT}
}

proc generate_verilog_sim {name} {
    common_add_fileset_files {S5 ALL_HDL ALL_SIM ALTERA_XCVR_RESET_CONTROL ALT_XCVR_CSR} {PLAIN MSIM_SCRIPT}
}


proc generate_synth {name} {
    common_add_fileset_files {S5 ALL_HDL ALTERA_XCVR_RESET_CONTROL ALT_XCVR_CSR} {PLAIN QIP SDC}
}


