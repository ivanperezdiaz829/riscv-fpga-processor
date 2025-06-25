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


# +---------------------------------
# | request TCL package from ACDS 10.1
# |
package require -exact sopc 10.1
# |
# +----------------------------------

# +----------------------------------
# | module alt_ntrlkn_oob_tx
# |
set_module_property NAME alt_ntrlkn_oob_tx
set_module_property VERSION 13.1
set_module_property INTERNAL true
set_module_property DISPLAY_NAME alt_ntrlkn_oob_tx
set_module_property TOP_LEVEL_HDL_FILE alt_ntrlkn_oob_flow_tx.v
set_module_property TOP_LEVEL_HDL_MODULE alt_ntrlkn_oob_flow_tx
set_module_property STATIC_TOP_LEVEL_MODULE_NAME alt_ntrlkn_oob_flow_tx
set_module_property EDITABLE false
set_module_property ANALYZE_HDL false
set_module_property AUTHOR "Altera Corporation"
set_module_property DESCRIPTION "Altera Interlaken Out of Band flow control for Transmitter"
set_module_property ELABORATION_CALLBACK elaborate

#enable when SPR:353800 is fixed
#add_fileset synth2 QUARTUS_SYNTH generate_synth
#set_fileset_property synth2 TOP_LEVEL alt_ntrlkn_oob_flow_tx

add_fileset simulation_verilog SIM_VERILOG sim_ver
set_fileset_property simulation_verilog TOP_LEVEL alt_ntrlkn_oob_flow_tx


# |
# +----------------------------------------

# +----------------------------------------
# | adding files
# |
add_file alt_ntrlkn_oob_flow_tx.v {SYNTHESIS}
# |
# +-----------------------------------------

# +----------------------------------------
# | parameters
# |
add_parameter CAL_BITS INTEGER 16
set_parameter_property CAL_BITS DEFAULT_VALUE 16
set_parameter_property CAL_BITS DISPLAY_NAME "Number of calendar bits"
set_parameter_property CAL_BITS ALLOWED_RANGES 2:256
set_parameter_property CAL_BITS TYPE INTEGER
set_parameter_property CAL_BITS AFFECTS_ELABORATION true
set_parameter_property CAL_BITS HDL_PARAMETER true
add_display_item "general" CAL_BITS parameter

add_parameter NUM_LANES INTEGER 8
set_parameter_property NUM_LANES DEFAULT_VALUE 8
set_parameter_property NUM_LANES DISPLAY_NAME "Number of lanes"
set_parameter_property NUM_LANES ALLOWED_RANGES {4 8 10 12 20}
set_parameter_property NUM_LANES TYPE INTEGER
set_parameter_property NUM_LANES AFFECTS_ELABORATION true
set_parameter_property NUM_LANES HDL_PARAMETER true
add_display_item "general" NUM_LANES parameter

# +---------------------------------
# | elaboration callback

proc elaborate {} {

    set calbits [get_parameter_value CAL_BITS]
    set lanes [get_parameter_value NUM_LANES]

    add_interface tx_oob_in conduit end
    add_interface_port tx_oob_in double_fc_clk export Input 1
    add_interface_port tx_oob_in double_fc_arst export Input 1
    add_interface_port tx_oob_in calendar export Input $calbits
    add_interface_port tx_oob_in lane_status export Input $lanes
    add_interface_port tx_oob_in link_status export Input 1
    add_interface_port tx_oob_in ena_status export Input 1
    
    add_interface tx_oob_out conduit start
    add_interface_port tx_oob_out fc_clk export Output 1
    add_interface_port tx_oob_out fc_data export Output 1
    add_interface_port tx_oob_out fc_sync export Output 1

    
    
}

proc add_conduit {iface_name port_name type dir width} {

    add_interface $iface_name conduit $type
    add_interface_port $iface_name $port_name export $dir $width
    
    
}


# proc generate_synth {name} {

#     add_fileset_file "alt_ntrlkn_oob_flow_tx.v" VERILOG PATH "alt_ntrlkn_oob_flow_tx.v"
#     add_fileset_file "alt_ntrlkn_log2.iv" VERILOG PATH "alt_ntrlkn_log2.iv"
# }

proc sim_ver {name} {

    set files {"alt_ntrlkn_oob_flow_tx.v"}

    foreach f $files {
	if {[file exist "mentor/${f}"]} {
	    add_fileset_file mentor/${f} VERILOG PATH "mentor/${f}" {MENTOR_SPECIFIC}
	} else {
	    set mentor_support 0
	}
	if {[file exist "aldec/${f}"]} {
	    add_fileset_file aldec/${f} VERILOG PATH "aldec/${f}" {ALDEC_SPECIFIC}
	} else {
	    set aldec_support 0
	}
	if {[file exist "cadence/${f}"]} {
	    add_fileset_file cadence/${f} VERILOG PATH "cadence/${f}" {CADENCE_SPECIFIC}
	} else {
	    set cadence_support 0
	} 
	if {[file exist "synopsys/${f}"]} {
	    add_fileset_file synopsys/${f} VERILOG PATH "synopsys/${f}" {SYNOPSYS_SPECIFIC}
	} else {
	    set synopsys_support 0
	}
    }
}
