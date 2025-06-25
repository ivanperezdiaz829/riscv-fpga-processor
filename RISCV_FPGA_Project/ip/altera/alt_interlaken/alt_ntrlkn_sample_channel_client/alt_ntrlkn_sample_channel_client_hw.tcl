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
set_module_property NAME alt_ntrlkn_sample_channel_client
set_module_property VERSION 13.1
set_module_property INTERNAL false
set_module_property DISPLAY_NAME "Interlaken Sample Client"
set_module_property TOP_LEVEL_HDL_FILE alt_ntrlkn_sample_channel_client.v
set_module_property TOP_LEVEL_HDL_MODULE alt_ntrlkn_sample_channel_client
set_module_property STATIC_TOP_LEVEL_MODULE_NAME alt_ntrlkn_sample_channel_client
set_module_property EDITABLE false
set_module_property GROUP "Interface Protocols/Interlaken"
set_module_property ANALYZE_HDL false
set_module_property AUTHOR "Altera Corporation"
set_module_property DESCRIPTION "Altera Interlaken Sample Client"
set_module_property DATASHEET_URL "http://www.altera.com/literature/ug/ug_interlaken.pdf"

set_module_property ELABORATION_CALLBACK elaborate
#set_module_property VALIDATION_CALLBACK validate

add_fileset simulation_verilog SIM_VERILOG sim_ver
set_fileset_property simulation_verilog TOP_LEVEL alt_ntrlkn_sample_channel_client

# to be enabled when SPR 353800 is fixed
#add_fileset synth2 QUARTUS_SYNTH generate_synth
#set_fileset_property synth2 TOP_LEVEL alt_ntrlkn_sample_channel_client

# | 
# +-----------------------------------

add_file alt_ntrlkn_sample_channel_client.v
add_file alt_ntrlkn_bus_mux.v
add_file alt_ntrlkn_sample_channel_client_2_word.v
add_file alt_ntrlkn_sample_channel_client_4_word.v
add_file alt_ntrlkn_sample_channel_client_8_word.v

# +--------------------------
# | display item
# |

add_display_item "" "General" GROUP

set client_files {"alt_ntrlkn_bus_mux.v" "alt_ntrlkn_sample_channel_client.v" "alt_ntrlkn_sample_channel_client_2_word.v" "alt_ntrlkn_sample_channel_client_4_word.v" "alt_ntrlkn_sample_channel_client_8_word.v"}

# +----------------------------
# | sim_ver

proc sim_ver {name} {

    global client_files
    foreach f $client_files {
	add_fileset_file $f VERILOG PATH $f
    }
}

# to be enabled when SPR 353800 is fixed
# proc generate_synth {name} {

#     global client_files
#     foreach f $client_files {
# 	add_fileset_file $f VERILOG PATH $f
#     }
# }


# +--------------------------
# | parameter
# |


add_parameter DATAPATH_WIDTH INTEGER 512
set_parameter_property DATAPATH_WIDTH DEFAULT_VALUE 512
set_parameter_property DATAPATH_WIDTH DISPLAY_NAME "Width of the datapath in bits"
set_parameter_property DATAPATH_WIDTH ALLOWED_RANGES {128 256 512}
set_parameter_property DATAPATH_WIDTH DISPLAY_HINT ""
set_parameter_property DATAPATH_WIDTH DESCRIPTION "Specifies the width of the datapath, possible widths are 128, 256 or 512 bits"
set_parameter_property DATAPATH_WIDTH AFFECTS_ELABORATION true
set_parameter_property DATAPATH_WIDTH HDL_PARAMETER false
add_display_item "General" DATAPATH_WIDTH parameter


add_parameter WORDS INTEGER 8
set_parameter_property WORDS DEFAULT_VALUE 8
set_parameter_property WORDS ALLOWED_RANGES {2 4 8}
set_parameter_property WORDS VISIBLE false
set_parameter_property WORDS DERIVED true
set_parameter_property WORDS AFFECTS_ELABORATION true
set_parameter_property WORDS HDL_PARAMETER true


add_parameter LOG_WORDS INTEGER 4
set_parameter_property LOG_WORDS DEFAULT_VALUE 4
set_parameter_property LOG_WORDS ALLOWED_RANGES {2 3 4}
set_parameter_property LOG_WORDS VISIBLE false
set_parameter_property LOG_WORDS DERIVED true
set_parameter_property LOG_WORDS AFFECTS_ELABORATION true
set_parameter_property LOG_WORDS HDL_PARAMETER true

add_parameter EMPTY_BITS INTEGER 6
set_parameter_property EMPTY_BITS DEFAULT_VALUE 6
set_parameter_property EMPTY_BITS ALLOWED_RANGES {4 5 6}
set_parameter_property EMPTY_BITS VISIBLE false
set_parameter_property EMPTY_BITS DERIVED true
set_parameter_property EMPTY_BITS AFFECTS_ELABORATION true
set_parameter_property EMPTY_BITS HDL_PARAMETER true



# +-------------------------
# | ELABORATE CALLBACK
# |

proc elaborate {} {

    set dpwidth [get_parameter_value DATAPATH_WIDTH]

    if {$dpwidth == 128} {
	set_parameter_value WORDS 2
	set_parameter_value LOG_WORDS 2
	set_parameter_value EMPTY_BITS 4
	set emptybits 4
	set iwords 2
    } elseif {$dpwidth == 256} {
	set_parameter_value WORDS 4
	set_parameter_value LOG_WORDS 3
	set_parameter_value EMPTY_BITS 5
	set emptybits 5
	set iwords 4	
    } elseif {$dpwidth == 512} {
	set_parameter_value WORDS 8
	set_parameter_value LOG_WORDS 4
	set_parameter_value EMPTY_BITS 6
	set emptybits 6
	set iwords 8
    } else {
	send_message error "Datapath width is incorrect, please choose 128, 256 or 512 bits"
    }


   
    # +--------------------------
    # | add clocks and resets
    # |

    add_clock_or_reset tx_clk clock end true tx_clk Input
    add_clock_or_reset tx_arst reset end true tx_arst Input
    add_clock_or_reset rx_clk clock end true rx_clk Input
    add_clock_or_reset rx_arst reset end true rx_arst Input

    # +------------------------
    # | Avalon streaming interfaces
    # |
    

    add_interface tx_dataout avalon_streaming start
    set_interface_property tx_dataout dataBitsPerSymbol 8
    set_interface_property tx_dataout maxChannel 0
    set_interface_property tx_dataout readyLatency 0
    set_interface_property tx_dataout symbolsPerBeat [expr $iwords * 8]
    set_interface_property tx_dataout ENABLED true
    set_interface_property tx_dataout ASSOCIATED_CLOCK tx_clk
    add_interface_port tx_dataout avl_data_out data Output [expr $iwords * 64]
    add_interface_port tx_dataout avl_valid_out valid Output 1
    add_interface_port tx_dataout avl_sop_out startofpacket Output 1
    add_interface_port tx_dataout avl_eop_out endofpacket Output 1
    add_interface_port tx_dataout avl_empty_out empty Output $emptybits
    add_interface_port tx_dataout avl_ready_in ready Input 1
    add_interface_port tx_dataout avl_error_out error Output 1

    add_interface rx_datain avalon_streaming end
    set_interface_property rx_datain dataBitsPerSymbol 8
    set_interface_property rx_datain maxChannel 0
    set_interface_property rx_datain readyLatency 0
    set_interface_property rx_datain symbolsPerBeat [expr $iwords * 8]
    set_interface_property rx_datain ENABLED true
    set_interface_property rx_datain ASSOCIATED_CLOCK rx_clk
    add_interface_port rx_datain avl_data_in data Input [expr $iwords * 64]
    add_interface_port rx_datain avl_data_valid_in valid Input 1
    add_interface_port rx_datain avl_sop_in startofpacket Input 1
    add_interface_port rx_datain avl_eop_in endofpacket Input 1
    add_interface_port rx_datain avl_empty_in empty Input $emptybits
    add_interface_port rx_datain avl_error_in error Input 1

    
    add_conduit tx_counter start Output 32
    add_conduit rx_counter start Output 32
    add_conduit din_ready start Output 1
    
        
}

proc log2 {val} {
    set log2 0
    while {$val > 0} {
	set val [expr $val >> 1]
	set log2 [expr $log2 + 1]

    }
    send_message info "val is $val"
    send_message info "log2 is $log2"
   
    return $log2
    
}

#+-----------------------------------------
#| procedure to add clocks and resets
#|
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
