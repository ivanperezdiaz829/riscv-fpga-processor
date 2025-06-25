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
# | module alt_ntrlkn_reset
# | 
set_module_property NAME alt_ntrlkn_reset
set_module_property VERSION 13.1
set_module_property INTERNAL true 
set_module_property DISPLAY_NAME alt_ntrlkn_reset
set_module_property TOP_LEVEL_HDL_FILE alt_ntrlkn_reset.v
set_module_property TOP_LEVEL_HDL_MODULE alt_ntrlkn_reset
set_module_property STATIC_TOP_LEVEL_MODULE_NAME alt_ntrlkn_reset
set_module_property EDITABLE false
set_module_property ANALYZE_HDL false
set_module_property AUTHOR "Altera Corporation"
set_module_property DESCRIPTION "Altera Interlaken RESET Controller"

set_module_property ELABORATION_CALLBACK elaborate

# add_fileset synth2 QUARTUS_SYNTH generate_synth
# set_fileset_property synth2 TOP_LEVEL alt_ntrlkn_reset

add_fileset simulation_verilog SIM_VERILOG sim_ver
set_fileset_property simulation_verilog TOP_LEVEL alt_ntrlkn_reset

# | 
# +-----------------------------------


# +----------------------------------
# | 
add_file alt_ntrlkn_gxb_reset.v {SYNTHESIS}
add_file alt_ntrlkn_reset_delay.v {SYNTHESIS}
add_file alt_ntrlkn_reset.v {SYNTHESIS}

set reset_files {"alt_ntrlkn_gxb_reset.v" "alt_ntrlkn_reset_delay.v" "alt_ntrlkn_reset.v"}
# proc generate_synth {name} {
    
#     global reset_files
    
#     foreach f $reset_files {
# 	add_fileset_file $f VERILOG PATH $f
#     }
    
# }

proc sim_ver {name} {

    global reset_files
    
    foreach f $reset_files {
	add_fileset_file $f VERILOG PATH $f
    }
}

# +-----------------------------------
# | parameters
# |

add_parameter SIM_FAST_RESET INTEGER 0
set_parameter_property SIM_FAST_RESET DEFAULT_VALUE 0
set_parameter_property SIM_FAST_RESET TYPE INTEGER
set_parameter_property SIM_FAST_RESET UNITS None
set_parameter_property SIM_FAST_RESET VISIBLE false
set_parameter_property SIM_FAST_RESET HDL_PARAMETER true

add_parameter HSIO_INST_NUM INTEGER 4
set_parameter_property HSIO_INST_NUM ALLOWED_RANGES {1 2 3 4}
set_parameter_property HSIO_INST_NUM TYPE INTEGER
set_parameter_property HSIO_INST_NUM UNITS None
set_parameter_property HSIO_INST_NUM VISIBLE false
set_parameter_property HSIO_INST_NUM HDL_PARAMETER false



# +---------------------------------------
# | port connections
# |

proc elaborate {} {

    add_interfaces
}

proc add_interfaces {} {

    set num_hsio_inst [get_parameter_value HSIO_INST_NUM]

    add_clock_or_reset cal_blk_clk clock end true cal_blk_clk Input
    add_clock_or_reset tx_mac_clk clock end true tx_mac_clk Input
    add_clock_or_reset rx_mac_clk clock end true rx_mac_clk Input
    add_clock_or_reset common_rx_clk clock end true common_rx_clk Input
    add_clock_or_reset common_tx_clk clock end true common_tx_clk Input

#   add_clock_or_reset tx_mac_arst reset start true tx_mac_arst Output
#   add_clock_or_reset rx_mac_arst reset start true rx_mac_arst Output

    add_conduit reset end Input 1
#   add_clock_or_reset reset end true reset Input
    add_conduit tx_mac_arst start Output 1
    add_conduit rx_mac_arst start Output 1
    add_conduit tx_lane_arst start Output 1
#   add_conduit rx_lane_arst start Output 1

    add_conduit hs0_reco_busy end input 1
    add_conduit hs0_rx_freqlocked_n end Input 1
    add_conduit hs0_pll_locked_n end_n input 1

    add_conduit hs0_pll_powerdown start Output 1
    add_conduit hs0_tx_digitalreset start Output 1
    add_conduit hs0_rx_digitalreset start Output 1
    add_conduit hs0_rx_analogreset start Output 1
    add_conduit hs0_tx_lane_arst_early start Output 1
    add_conduit hs0_rx_lane_arst_early start Output 1

    add_conduit hs1_reco_busy end input 1
    add_conduit hs1_rx_freqlocked_n end Input 1
    add_conduit hs1_pll_locked_n end input 1

    add_conduit hs1_pll_powerdown start Output 1
    add_conduit hs1_tx_digitalreset start Output 1
    add_conduit hs1_rx_digitalreset start Output 1
    add_conduit hs1_rx_analogreset  start Output 1
    add_conduit hs1_tx_lane_arst_early start Output 1
    add_conduit hs1_rx_lane_arst_early start Output 1

    add_conduit hs2_reco_busy end input 1
    add_conduit hs2_rx_freqlocked_n end Input 1
    add_conduit hs2_pll_locked_n end input 1

    add_conduit hs2_pll_powerdown start Output 1
    add_conduit hs2_tx_digitalreset start Output 1
    add_conduit hs2_rx_digitalreset start Output 1
    add_conduit hs2_rx_analogreset  start Output 1
    add_conduit hs2_tx_lane_arst_early start Output 1
    add_conduit hs2_rx_lane_arst_early start Output 1

    add_conduit hs3_reco_busy end input 1
    add_conduit hs3_rx_freqlocked_n end Input 1
    add_conduit hs3_pll_locked_n end input 1

    add_conduit hs3_pll_powerdown start Output 1
    add_conduit hs3_tx_digitalreset start Output 1
    add_conduit hs3_rx_digitalreset start Output 1
    add_conduit hs3_rx_analogreset  start Output 1
    add_conduit hs3_tx_lane_arst_early start Output 1
    add_conduit hs3_rx_lane_arst_early start Output 1

    if {$num_hsio_inst == 1} {
        send_message info "num_hsio_inst is $num_hsio_inst"
        
        set_interface_property hs1_reco_busy ENABLED false
        set_interface_property hs1_rx_freqlocked_n ENABLED false
        set_interface_property hs1_pll_locked_n ENABLED false

        set_interface_property hs2_reco_busy ENABLED false
        set_interface_property hs2_rx_freqlocked_n ENABLED false
        set_interface_property hs2_pll_locked_n ENABLED false

        set_interface_property hs3_reco_busy ENABLED false
        set_interface_property hs3_rx_freqlocked_n ENABLED false
        set_interface_property hs3_pll_locked_n ENABLED false


    } elseif {$num_hsio_inst == 2} {
        send_message info "num_hsio_inst is $num_hsio_inst"
        set_interface_property hs2_reco_busy ENABLED false
        set_interface_property hs2_rx_freqlocked_n ENABLED false
        set_interface_property hs2_pll_locked_n ENABLED false

        set_interface_property hs3_reco_busy ENABLED false
        set_interface_property hs3_rx_freqlocked_n ENABLED false
        set_interface_property hs3_pll_locked_n ENABLED false

    } elseif {$num_hsio_inst == 3} {
        send_message info "num_hsio_inst is $num_hsio_inst"
        set_interface_property hs3_reco_busy ENABLED false
        set_interface_property hs3_rx_freqlocked_n ENABLED false
        set_interface_property hs3_pll_locked_n ENABLED false

    } elseif {$num_hsio_inst == 4} {
        send_message info "num_hsio_inst is $num_hsio_inst"
    } else {
        send_message error "This HSIO doesn't support data rates other than 6250 Mbps or 6375 Mbps"
    }

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

