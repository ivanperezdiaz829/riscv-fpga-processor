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
# | TCL component declarations
# | $Header: //acds/rel/13.1/ip/altera_pcie_pipe/sv/sv_xcvr_pipe_native_hw.tcl#1 $
# | 
# +-----------------------------------

# +-----------------------------------
# | request TCL package from ACDS 10.1
# | 
package require -exact sopc 10.1
# | 
# +-----------------------------------

# +-----------------------------------
# | module pcie
# | 
set_module_property NAME sv_xcvr_pipe_native
set_module_property VERSION 13.1
set_module_property AUTHOR "Altera Corporation"
set_module_property INTERNAL true 
set_module_property GROUP "Interface Protocols/PCI"
set_module_property DISPLAY_NAME "Stratix V Native PHY for PCI Express (PIPE)" 
set_module_property EDITABLE true
set_module_property ELABORATION_CALLBACK elaboration_callback
set_module_property VALIDATION_CALLBACK my_validation_callback
set_module_property ANALYZE_HDL false

add_fileset sim_vhdl SIM_VHDL generate_vhdl_sim
set_fileset_property sim_vhdl TOP_LEVEL sv_xcvr_pipe_native
add_fileset sim_verilog SIM_VERILOG generate_verilog_sim
set_fileset_property sim_verilog TOP_LEVEL sv_xcvr_pipe_native
add_fileset synth2 QUARTUS_SYNTH generate_synth
set_fileset_property synth2  TOP_LEVEL sv_xcvr_pipe_native
set_module_property ALLOW_GREYBOX_GENERATION true 

# | 
# +-----------------------------------

#send_message info "hw.tcl dir is [get_module_property MODULE_DIRECTORY]"
#source ../../altera_xcvr_generic/alt_xcvr_common.tcl
#source ../../altera_xcvr_generic/ctrl/alt_xcvr_csr_fileset.tcl	
#source ../../altera_xcvr_generic/sv/sv_xcvr_native_fileset.tcl	
#source ../alt_xcvr_reconfig/alt_xcvr_reconfig/alt_xreconf_common.tcl	
source ../xcvr_generic/altera_xcvr_pipe_common.tcl

# +-----------------------------------
# | display items
# | 
proc elaboration_callback { } {
	# declare ports and mappings for elaboration callback
	common_clock_interfaces
	common_cal_blk_clk_interface

	#PIPE_RATE:0 for channel_based; 1 for shared
	common_pipe_interface_ports 0 

	conduits_for_native_phy

  # add conduit ports for reconfig  
  common_add_dynamic_reconfig_conduits 
}

# +-----------------------------------
# | validate parameters
# | 
proc my_validation_callback {} {

	common_parameter_validation
	validate_reconfiguration_parameters 
}


# +-----------------------------------
# | native PHY ports
# | 
proc conduits_for_native_phy { } {
	#parameter values needed for port widths:
	set deser_factor [get_parameter_value deser_factor]
	set lanes [get_parameter_value lanes]

	# shared inputs
	common_add_optional_conduit pll_powerdown input 1 true

	#conduits for inputs:
	common_add_optional_conduit tx_digitalreset input $lanes true
	common_add_optional_conduit rx_analogreset input $lanes true
	common_add_optional_conduit rx_digitalreset input $lanes true
	common_add_optional_conduit rx_set_locktodata input $lanes  true
	common_add_optional_conduit rx_set_locktoref input $lanes  true
	common_add_optional_conduit tx_invpolarity input $lanes  true

	#conduits for outputs:
	common_add_optional_conduit rx_errdetect output [expr ($lanes*$deser_factor)/8 ] true
	common_add_optional_conduit rx_disperr output [expr ($lanes*$deser_factor)/8 ] true
	common_add_optional_conduit rx_patterndetect output [expr ($lanes*$deser_factor)/8 ] true
	common_add_optional_conduit rx_phase_comp_fifo_error output $lanes  true
	common_add_optional_conduit tx_phase_comp_fifo_error output $lanes  true
	common_add_optional_conduit rx_signaldetect output $lanes  true
	common_add_optional_conduit rx_bitslipboundaryselectout output [expr $lanes*5] true
	common_add_optional_conduit rx_rlv output $lanes  true
}

# +-----------------------------------
# | parameters
# | 
common_add_parameters_for_native_phy 
common_add_extra_parameters_for_native_phy

######################################
# +-----------------------------------
# | Fileset callback functions
# +-----------------------------------
######################################

#
# declare all files, with appropriate implementation and tool-flow tags
#
sv_xcvr_native_decl_fileset_groups ../altera_xcvr_generic
alt_xcvr_csr_decl_fileset_groups ../altera_xcvr_generic
pipe_decl_fileset_groups_sv_xcvr_pipe_native .
	
proc generate_vhdl_sim {name} {
	common_add_fileset_files {S5 ALL_HDL ALL_SIM} {PLAIN MENTOR MSIM_SCRIPT}
}

proc generate_verilog_sim {name} {
	common_add_fileset_files {S5 ALL_HDL ALL_SIM} {PLAIN MSIM_SCRIPT}
}


proc generate_synth {name} {
	common_add_fileset_files {S5 ALL_HDL} {PLAIN QIP}
}

