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
# | request TCL package from ACDS 10.1
# | 
package require -exact sopc 10.1
# | 
# +-----------------------------------

# +-----------------------------------
# | module interlaken_xcvr_8lane
# | 
set_module_property NAME alt_ntrlkn_hsio_bank_10g
set_module_property VERSION 13.1
set_module_property INTERNAL true
set_module_property DISPLAY_NAME alt_ntrlkn_hsio_bank_10g
set_module_property TOP_LEVEL_HDL_FILE alt_ntrlkn_hsio_bank_10g.v
set_module_property TOP_LEVEL_HDL_MODULE alt_ntrlkn_hsio_bank_10g
set_module_property STATIC_TOP_LEVEL_MODULE_NAME alt_ntrlkn_hsio_bank_10g
set_module_property EDITABLE false
set_module_property ANALYZE_HDL false
set_module_property AUTHOR "Altera Corporation"
set_module_property DESCRIPTION "Altera Interlaken HSIO Bank 10G"

# add_fileset synth2 QUARTUS_SYNTH generate_synth
# set_fileset_property synth2 TOP_LEVEL alt_ntrlkn_hsio_bank_10g

add_fileset simulation_verilog SIM_VERILOG sim_ver
set_fileset_property simulation_verilog TOP_LEVEL alt_ntrlkn_hsio_bank_10g

set_module_property ELABORATION_CALLBACK elaborate

# | 
# +-----------------------------------

add_file alt_ntrlkn_hsio_bank_10g.v {SYNTHESIS}
add_file alt_ntrlkn_gxb_10g.v {SYNTHESIS}
add_file alt_ntrlkn_reconfig_10g.v {SYNTHESIS}
add_file alt_ntrlkn_frequency_monitor_10g.v {SYNTHESIS}

set hsio_files {"alt_ntrlkn_hsio_bank_10g.v" "alt_ntrlkn_gxb_10g.v" "alt_ntrlkn_reconfig_10g.v" "alt_ntrlkn_frequency_monitor_10g.v"}


# this piece of code is for synthesis callback, waiting on SPR 353800 to be resolved before enabling this
# proc generate_synth {name} {

#     global hsio_files
    
#     foreach f $hsio_files {
# 	add_fileset_file $f VERILOG PATH $f
#     }

# }

proc sim_ver {name} {

    global hsio_files
    
    foreach f $hsio_files {
	add_fileset_file $f VERILOG PATH $f
    }
 }

# +-----------------------------------
# | parameters
# |

add_parameter WORD_LEN INTEGER 40
set_parameter_property WORD_LEN ALLOWED_RANGES {40}
set_parameter_property WORD_LEN VISIBLE false
set_parameter_property WORD_LEN AFFECTS_ELABORATION true
set_parameter_property WORD_LEN HDL_PARAMETER true

add_parameter LANES INTEGER 4
set_parameter_property LANES ALLOWED_RANGES {4}
set_parameter_property LANES VISIBLE false
set_parameter_property LANES AFFECTS_ELABORATION true
set_parameter_property LANES HDL_PARAMETER true

add_parameter SIM_FAST_RESET INTEGER 0
set_parameter_property SIM_FAST_RESET DEFAULT_VALUE 0
set_parameter_property SIM_FAST_RESET TYPE INTEGER
set_parameter_property SIM_FAST_RESET UNITS None
set_parameter_property SIM_FAST_RESET VISIBLE false
set_parameter_property SIM_FAST_RESET HDL_PARAMETER true


# +---------------------------------------
# | port connections
# |

proc elaborate {} {

    add_interfaces
}

proc add_interfaces {} {

    set word_length [get_parameter_value WORD_LEN]
    set num_lanes [get_parameter_value LANES]

    add_clock_or_reset ref_clk clock end true ref_clk Input
    add_clock_or_reset common_rx_clk clock end true common_rx_clk Input
    add_clock_or_reset clk_in clock end true clk_in Input
    add_clock_or_reset clk_out clock start true clk_out Output
    add_clock_or_reset cal_blk_clk clock end true cal_blk_clk Input

    add_conduit pll_powerdown end Input 1
    add_conduit tx_digitalreset end Input 1
    add_conduit rx_digitalreset end Input 1
    add_conduit tx_lane_arst_early end Input 1
    add_conduit rx_lane_arst_early end Input 1
    add_conduit rx_analogreset end Input 1

    add_conduit reco_busy start Output 1
    add_conduit pll_locked_n start Output 1
    add_conduit rx_freqlocked_n start Output 1

    add_interface tx_parallel_data conduit end
    add_interface_port tx_parallel_data tx_datain export Input [expr $word_length * $num_lanes]
 
    add_interface rx_parallel_data conduit start
    add_interface_port rx_parallel_data rx_dataout export Output [expr $word_length * $num_lanes]

    add_conduit rx_clk start Output [expr $num_lanes]    

    add_interface tx_serial_data conduit start
    add_interface_port tx_serial_data tx_pin export Output [expr $num_lanes]

    add_interface rx_serial_data conduit end
    add_interface_port rx_serial_data rx_pin export Input [expr $num_lanes]    
  
  
    add_conduit serial_loopback end Input 1
    set_interface_property serial_loopback ENABLED false

    add_conduit tx_error_inject end Input 1
    set_interface_property tx_error_inject ENABLED false

    
    add_conduit freq_ref end Input 1
    set_interface_property freq_ref ENABLED false
    
    
    
    add_conduit new_analog_params end Input 25
    set_interface_property new_analog_params ENABLED false

    

    add_conduit rd_analog end Input 1
    set_interface_property rd_analog ENABLED false

    add_conduit wr_analog end Input 1
    set_interface_property wr_analog ENABLED false
    
}

# +----------------------------------
# | procedure to add clocks and resets
# |

proc add_clock_or_reset {iface_name clk_or_rst iface_type is_enabled port_name dir} {
    add_interface $iface_name $clk_or_rst $iface_type
    set_interface_property $iface_name ENABLED $is_enabled

    if {$clk_or_rst == "clock"} {
	add_interface_port $iface_name $port_name clk $dir 1
    } else {
	add_interface_port $iface_name $port_name reset $dir 1
	set_interface_property $iface_name associatedClock ""
	set_interface_property $iface_name synchronousEdges NONE
    }
}

#+--------------------------------------
#| procedure to add conduit interfaces
#|

proc add_conduit {iface_name type dir width} {

    add_interface $iface_name conduit $type
    add_interface_port $iface_name $iface_name export $dir $width
    
    
}
