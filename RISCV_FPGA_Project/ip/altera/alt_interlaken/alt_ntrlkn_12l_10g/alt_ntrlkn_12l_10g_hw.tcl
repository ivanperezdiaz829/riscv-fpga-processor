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
# | module interlaken_xcvr_12lane
# | 
set_module_property NAME alt_ntrlkn_12l_10g
set_module_property VERSION 13.1
set_module_property INTERNAL true
set_module_property DISPLAY_NAME altera_interlaken_12lane_10g
set_module_property TOP_LEVEL_HDL_FILE alt_ntrlkn_12l_10g_xcvr_12lane.v
set_module_property TOP_LEVEL_HDL_MODULE alt_ntrlkn_12l_10g_xcvr_12lane
set_module_property STATIC_TOP_LEVEL_MODULE_NAME alt_ntrlkn_12l_10g_xcvr_12lane
set_module_property EDITABLE false
set_module_property GROUP "Interface Protocols/Interlaken"
set_module_property ANALYZE_HDL false
set_module_property AUTHOR "Altera Corporation"
set_module_property DESCRIPTION "Altera Interlaken"

set_module_property ELABORATION_CALLBACK elaborate
set_module_property VALIDATION_CALLBACK validate

#enable when SPR:353800 is fixed
#add_fileset synth2 QUARTUS_SYNTH generate_synth
#set_fileset_property synth2 TOP_LEVEL alt_ntrlkn_12l_10g_xcvr_12lane

add_fileset simulation_verilog SIM_VERILOG sim_ver
set_fileset_property simulation_verilog TOP_LEVEL alt_ntrlkn_12l_10g_xcvr_12lane


# | 
# +-----------------------------------

#+-----------------------------------
#|
#| files
add_file alt_ntrlkn_12l_10g_align_dcf.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_align_fifo.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_alignment_pipe.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_arbiter.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_avalon_to_ilk_adapter_8.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_buffer_1_to_2.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_buffer_2_to_1.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_buffered_read_scheduler_8.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_channel_fifo.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_compact_words_8.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_crc24_dat64.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_crc24_dat64_factor.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_crc24_dat64_flat.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_crc24_dat64_only_flat.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_crc24_multiple_upto10.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_crc24_multiple_upto2.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_crc24_multiple_upto3.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_crc24_multiple_upto4.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_crc24_multiple_upto5.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_crc24_multiple_upto6.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_crc24_multiple_upto7.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_crc24_multiple_upto8.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_crc24_multiple_upto9.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_crc24_zer64_flat.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_crc24_zer64x10_flat.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_crc24_zer64x2_flat.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_crc24_zer64x3_flat.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_crc24_zer64x4_flat.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_crc24_zer64x5_flat.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_crc24_zer64x6_flat.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_crc24_zer64x7_flat.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_crc24_zer64x8_flat.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_crc24_zer64x9_flat.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_crc32c_d64x2.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_crc32c_d64x2_factor.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_crc32c_d64x2_flat.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_crc32c_dat64.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_crc32c_dat64_factor.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_crc32c_dat64_flat.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_crc32c_dat64_only.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_crc32c_dat64_only_factor.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_crc32c_dat64_only_flat.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_crc32c_z64x2.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_crc32c_z64x2_factor.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_crc32c_z64x2_flat.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_crc32c_zer64.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_crc32c_zer64_factor.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_crc32c_zer64_flat.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_dec_67_64.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_enc_64_67.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_fifo_36_to_72.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_fifo_72_to_36.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_frame_sync_control.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_gearbox_40_67.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_gearbox_67_40.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_lal_cfifo.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_lal_dcfifo.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_lal_dfifo_auto.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_lane_alignment.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_lane_alignment_nav.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_lane_alignment_ram.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_lane_rx.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_lane_rx_crc.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_lane_status_monitor.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_lane_tx.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_lane_tx_crc.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_packet_annotate.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_packet_regroup_8.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_pipelined_any_flag.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_ram_navigate.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_read_calendar_8.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_read_calendar_single_page_8.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_read_scheduler_8.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_ready_skid.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_regroup_8.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_routing_pipe.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_rx_12lane.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_rx_buffer_fifo_2.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_rx_channel_filter_8.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_rx_crc24_check_8.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_rx_datapath_12lane.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_rx_stripe_adapter.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_scrambler_lfsr.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_sim_packet_client.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_six_three_comp.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_sum_of_3bit_pair.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_synchronizer.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_ternary_add.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_twelve_four_comp.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_tx_12lane.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_tx_2channel_arbiter.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_tx_4channel_arbiter.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_tx_buffer_fifo_8word.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_tx_buffer_fifo_nav.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_tx_buffer_fifo_ram.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_tx_buffer_fifo_ram_loose.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_tx_control_insertion_8.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_tx_crc24_insertion_8.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_tx_datapath_12lane.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_tx_flow_adapter.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_tx_stripe_adapter.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_wide_word_ram.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_wide_word_ram_8.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_word_align_control.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_xcvr_12lane.v {SYNTHESIS}
add_file alt_ntrlkn_12l_10g_xor6.v {SYNTHESIS}
add_file ../alt_interlaken_sdc_files/alt_ntrlkn_12l_10g.sdc {SDC}


# | 
# +-----------------------------------


#+-----------------------------------
#| display tabs
#| 
add_display_item "" "General" GROUP
add_display_item "" "PCS" GROUP


#+-----------------------------------
#| parameters
#|

add_parameter DEVICE_FAMILY STRING
set_parameter_property DEVICE_FAMILY DISPLAY_NAME "Device family"
set_parameter_property DEVICE_FAMILY SYSTEM_INFO {DEVICE_FAMILY}
set_parameter_property DEVICE_FAMILY ALLOWED_RANGES {"Stratix IV"}
set_parameter_property DEVICE_FAMILY HDL_PARAMETER false
add_display_item "General" DEVICE_FAMILY parameter

add_parameter OPERATIONAL_MODE INTEGER 0 Duplex
set_parameter_property OPERATIONAL_MODE DISPLAY_NAME "Operational mode"
set_parameter_property OPERATIONAL_MODE ALLOWED_RANGES {0:Duplex 1:Rx 2:Tx}
set_parameter_property OPERATIONAL_MODE DISPLAY_HINT "string"
set_parameter_property OPERATIONAL_MODE AFFECTS_ELABORATION true
set_parameter_property OPERATIONAL_MODE HDL_PARAMETER false
add_display_item "General" OPERATIONAL_MODE parameter

add_parameter LANES INTEGER 12
set_parameter_property LANES DEFAULT_VALUE 12
set_parameter_property LANES DISPLAY_NAME "Number of lanes"
set_parameter_property LANES ALLOWED_RANGES {12}
set_parameter_property LANES DISPLAY_HINT ""
set_parameter_property LANES AFFECTS_ELABORATION true
set_parameter_property LANES AFFECTS_GENERATION true
set_parameter_property LANES HDL_PARAMETER false
add_display_item "General" LANES parameter

add_parameter META_FRAME_LEN INTEGER 2048
set_parameter_property META_FRAME_LEN DEFAULT_VALUE 2048
set_parameter_property META_FRAME_LEN DISPLAY_NAME "Meta frame length in words"
set_parameter_property META_FRAME_LEN ALLOWED_RANGES 10:8192
set_parameter_property META_FRAME_LEN TYPE INTEGER
set_parameter_property META_FRAME_LEN UNITS None
set_parameter_property META_FRAME_LEN HDL_PARAMETER true
add_display_item "General" META_FRAME_LEN parameter

add_parameter BURST_MAX INTEGER 2
set_parameter_property BURST_MAX DEFAULT_VALUE 2
set_parameter_property BURST_MAX DISPLAY_NAME "BURST MAX length in bytes"
set_parameter_property BURST_MAX ALLOWED_RANGES {2 4}
set_parameter_property BURST_MAX DISPLAY_HINT ""
set_parameter_property BURST_MAX UNITS None
set_parameter_property BURST_MAX HDL_PARAMETER false
set_parameter_property BURST_MAX VISIBLE false
add_display_item "Burst Parameters" BURST_MAX parameter

add_parameter LOG_CALENDAR_PAGES INTEGER 4
set_parameter_property LOG_CALENDAR_PAGES DEFAULT_VALUE 4
set_parameter_property LOG_CALENDAR_PAGES ALLOWED_RANGES {1 3 4}
set_parameter_property LOG_CALENDAR_PAGES TYPE INTEGER
set_parameter_property LOG_CALENDAR_PAGES UNITS None
set_parameter_property LOG_CALENDAR_PAGES HDL_PARAMETER true
set_parameter_property LOG_CALENDAR_PAGES VISIBLE false
set_parameter_property LOG_CALENDAR_PAGES DERIVED true

add_parameter GUI_ENABLE_CALENDAR INTEGER 0
set_parameter_property GUI_ENABLE_CALENDAR DEFAULT_VALUE 0
set_parameter_property GUI_ENABLE_CALENDAR DISPLAY_NAME "Expose calendar ports"
set_parameter_property GUI_ENABLE_CALENDAR TYPE INTEGER
set_parameter_property GUI_ENABLE_CALENDAR UNITS None
set_parameter_property GUI_ENABLE_CALENDAR DISPLAY_HINT "Boolean"
set_parameter_property GUI_ENABLE_CALENDAR AFFECTS_ELABORATION true
set_parameter_property GUI_ENABLE_CALENDAR HDL_PARAMETER false
add_display_item "In-Band Flow Control" GUI_ENABLE_CALENDAR parameter

add_parameter CALENDAR_PAGES INTEGER 1
set_parameter_property CALENDAR_PAGES DEFAULT_VALUE 1
set_parameter_property CALENDAR_PAGES DISPLAY_NAME "Number of calendar pages"
set_parameter_property CALENDAR_PAGES ALLOWED_RANGES {1 8 16}
set_parameter_property CALENDAR_PAGES DISPLAY_HINT ""
set_parameter_property CALENDAR_PAGES HDL_PARAMETER true
set_parameter_property CALENDAR_PAGES AFFECTS_ELABORATION true
add_display_item "In-Band Flow Control" CALENDAR_PAGES parameter

add_parameter GUI_ENABLE_DYNAMIC_BURST INTEGER 0
set_parameter_property GUI_ENABLE_DYNAMIC_BURST DEFAULT_VALUE 0
set_parameter_property GUI_ENABLE_DYNAMIC_BURST DISPLAY_NAME "Enable dynamic burst parameters"
set_parameter_property GUI_ENABLE_DYNAMIC_BURST TYPE INTEGER
set_parameter_property GUI_ENABLE_DYNAMIC_BURST UNITS None
set_parameter_property GUI_ENABLE_DYNAMIC_BURST DISPLAY_HINT "Boolean"
set_parameter_property GUI_ENABLE_DYNAMIC_BURST AFFECTS_ELABORATION true
set_parameter_property GUI_ENABLE_DYNAMIC_BURST HDL_PARAMETER false
add_display_item "Burst Parameters" GUI_ENABLE_DYNAMIC_BURST parameter

add_parameter GUI_BURST_SHORT INTEGER 1
set_parameter_property GUI_BURST_SHORT DEFAULT_VALUE 32
set_parameter_property GUI_BURST_SHORT DISPLAY_NAME "BURST SHORT length in bytes"
set_parameter_property GUI_BURST_SHORT ALLOWED_RANGES {32 64}
set_parameter_property GUI_BURST_SHORT DISPLAY_HINT ""
set_parameter_property GUI_BURST_SHORT HDL_PARAMETER false
set_parameter_property GUI_BURST_SHORT AFFECTS_ELABORATION true
add_display_item "Burst Parameters" GUI_BURST_SHORT parameter

add_parameter NUM_CHANNELS INTEGER 2
set_parameter_property NUM_CHANNELS DEFAULT_VALUE 2
set_parameter_property NUM_CHANNELS ALLOWED_RANGES 2
set_parameter_property NUM_CHANNELS TYPE INTEGER
set_parameter_property NUM_CHANNELS UNITS None
set_parameter_property NUM_CHANNELS VISIBLE false
set_parameter_property NUM_CHANNELS AFFECTS_ELABORATION true
set_parameter_property NUM_CHANNELS AFFECTS_GENERATION false
set_parameter_property NUM_CHANNELS HDL_PARAMETER false

add_parameter GUI_ENABLE_HSIO INTEGER 0
set_parameter_property GUI_ENABLE_HSIO DEFAULT_VALUE 0
set_parameter_property GUI_ENABLE_HSIO DISPLAY_NAME "Exclude Transceiver"
set_parameter_property GUI_ENABLE_HSIO TYPE INTEGER
set_parameter_property GUI_ENABLE_HSIO UNITS None
set_parameter_property GUI_ENABLE_HSIO DISPLAY_HINT "Boolean"
set_parameter_property GUI_ENABLE_HSIO AFFECTS_ELABORATION true
set_parameter_property GUI_ENABLE_HSIO HDL_PARAMETER false
add_display_item "General" GUI_ENABLE_HSIO parameter


#cannot pass a GUI only parameter to RTL, therefore had to derive a new parameter
add_parameter DISABLE_HSIO INTEGER 0
set_parameter_property DISABLE_HSIO DEFAULT_VALUE 0
set_parameter_property DISABLE_HSIO TYPE INTEGER
set_parameter_property DISABLE_HSIO UNITS None
set_parameter_property DISABLE_HSIO DERIVED true
set_parameter_property DISABLE_HSIO VISIBLE false
set_parameter_property DISABLE_HSIO HDL_PARAMETER true




#+-------------------------------
#| VALIDATE CALLBACK
#|


proc validate {} {

    set dev [get_parameter_value DEVICE_FAMILY]
    
    if {$dev == "Stratix IV"} {
	send_message info "The device selected is Stratix IV"
    } else {
	send_message error "$dev is not supported, only Stratix IV is supported"
    }    
} 


# +-------------------------------
# |ELABORATE CALLBACK
# |

proc elaborate {} {

    add_interfaces   

} 


proc add_interfaces {} {


    set num_lanes [get_parameter_value LANES]
    set op_mode [get_parameter_value OPERATIONAL_MODE]

     set gui_hsio [get_parameter_value GUI_ENABLE_HSIO]
    
	set num_calendar_pgs [get_parameter_value CALENDAR_PAGES]
    if {$num_calendar_pgs == 1} {
		set_parameter_value LOG_CALENDAR_PAGES 1
    } elseif {$num_calendar_pgs == 8} {
		set_parameter_value LOG_CALENDAR_PAGES 3
    } elseif {$num_calendar_pgs == 16} {
		set_parameter_value LOG_CALENDAR_PAGES 4
	} else {
		send_message error "Only 16, 128, or 256 bits of calendar are supported"
	}

    if {$gui_hsio == 1} {
	set_parameter_value DISABLE_HSIO 1
    } else {
	set_parameter_value DISABLE_HSIO 0
    }


    if {$op_mode == 0} {
	set sup_tx 1
	set sup_tx_str "true"
	set sup_rx 1
	set sup_rx_str "true"
    } elseif {$op_mode == 1} {
	set sup_tx 0
	set sup_tx_str "false"
	set sup_rx 1
	set sup_rx_str "false"
    } elseif {$op_mode == 2} {
	set sup_rx 0
	set sup_rx_str "false"
	set sup_tx 1
	set sup_tx_str "true"
    } else {
	send_message error "Incorrect operational modes, supported modes are Duplex, Rx and Tx"
    }

    if {$num_lanes == 12} {
	send_message info "Number of lanes is $num_lanes"
    } else {
	send_message error "Number of lanes should be 12"
    }

    
   
    set num_chan [get_parameter_value NUM_CHANNELS]
   

    set iwords 8
    

    set log2_iwords 3
    

#+--------------------------------------------
#| add tx and rx related clocks and resets
#|

add_clock_or_reset tx_mac_clk clock end $sup_tx_str tx_mac_clk Input

#add_clock_or_reset tx_mac_arst reset end $sup_tx_str tx_mac_arst Input
add_conduit tx_mac_arst end Input 1
add_conduit rx_mac_arst end Input 1
add_conduit tx_lane_arst end Input 1

add_clock_or_reset tx_lane_clk clock end $sup_tx_str tx_lane_clk Input
#add_clock_or_reset tx_lane_arst reset end $sup_tx_str tx_lane_arst Input
add_clock_or_reset rx_mac_clk clock end $sup_rx_str rx_mac_clk Input
#add_clock_or_reset rx_mac_arst reset end $sup_rx_str rx_mac_arst Input
add_clock_or_reset common_rx_coreclk clock start $sup_rx_str common_rx_coreclk Output

    # +--------------------
    # | TX Input - avalon streaming
    # |

    for {set j 0} {$j < $num_chan} {incr j} {
    
	add_interface tx_ch${j}_datain avalon_streaming end
	set_interface_property tx_ch${j}_datain dataBitsPerSymbol 8
	set_interface_property tx_ch${j}_datain maxChannel 0
	set_interface_property tx_ch${j}_datain readyLatency 0
	set_interface_property tx_ch${j}_datain symbolsPerBeat [expr $iwords * 8]
	set_interface_property tx_ch${j}_datain ENABLED true
	set_interface_property tx_ch${j}_datain ASSOCIATED_CLOCK tx_mac_clk
	add_interface_port tx_ch${j}_datain tx_ch${j}_avl_data data Input [expr $iwords * 64]
	add_interface_port tx_ch${j}_datain tx_ch${j}_avl_valid valid Input 1
	add_interface_port tx_ch${j}_datain tx_ch${j}_avl_ready ready Output 1
	add_interface_port tx_ch${j}_datain tx_ch${j}_avl_sop startofpacket Input 1
	add_interface_port tx_ch${j}_datain tx_ch${j}_avl_eop endofpacket Input 1
	add_interface_port tx_ch${j}_datain tx_ch${j}_avl_error error Input 1
	add_interface_port tx_ch${j}_datain tx_ch${j}_avl_empty empty Input 6

}

    for {set j 0} {$j < $num_chan} {incr j} {
	add_interface rx_ch${j}_dataout avalon_streaming start
	set_interface_property rx_ch${j}_dataout dataBitsPerSymbol 8
	set_interface_property rx_ch${j}_dataout maxChannel 0
	set_interface_property rx_ch${j}_dataout readyLatency 0
	set_interface_property rx_ch${j}_dataout symbolsPerBeat [expr $iwords * 8]
	set_interface_property rx_ch${j}_dataout ENABLED true
	set_interface_property rx_ch${j}_dataout ASSOCIATED_CLOCK rx_mac_clk
	add_interface_port rx_ch${j}_dataout rx_ch${j}_avl_data data Output [expr $iwords * 64]
	add_interface_port rx_ch${j}_dataout rx_ch${j}_avl_valid valid Output 1
	add_interface_port rx_ch${j}_dataout rx_ch${j}_avl_error error Output 1
	add_interface_port rx_ch${j}_dataout rx_ch${j}_avl_sop startofpacket Output 1
	add_interface_port rx_ch${j}_dataout rx_ch${j}_avl_eop endofpacket Output 1
	add_interface_port rx_ch${j}_dataout rx_ch${j}_avl_empty empty Output 6
    }



    for {set i 0} {$i < 3} {incr i} {

	add_conduit rx_data$i end Input [expr 4 * 40]
	set_port_property rx_data$i FRAGMENT_LIST [list rx_data@[expr [expr $i+1] * 4 * 40 - 1]:[expr $i * 40 * 4]]
	
	
	add_conduit tx_data$i start Output [expr 4 * 40]
	set_port_property tx_data$i FRAGMENT_LIST [list tx_data@[expr [expr $i+1] * 4 * 40 - 1]:[expr $i * 40 * 4]]

	add_conduit rx_lane_clk$i end Input 4
	set_port_property rx_lane_clk$i FRAGMENT_LIST [list rx_lane_clk@[expr [expr $i+1] * 4 -1]:[expr  $i * 4]]
	

	
    }
    set dynamic_calendars [get_parameter_value GUI_ENABLE_CALENDAR]   
    set num_burst_max [get_parameter_value BURST_MAX]

    add_interface rx_status conduit start
    add_interface_port rx_status rx_per_lane_word_lock export Output $num_lanes
    add_interface_port rx_status rx_per_lane_sync_lock export Output $num_lanes
    add_interface_port rx_status rx_all_word_locked export Output 1
    add_interface_port rx_status rx_all_sync_locked export Output 1
    add_interface_port rx_status rx_fully_locked export Output 1
    add_interface_port rx_status rx_overflow export Output 1
    add_interface_port rx_status rx_locked_time export Output 16
    add_interface_port rx_status rx_error_count export Output 16
    add_interface_port rx_status rx_per_lane_crc32_errs export Output [expr $num_lanes * 8]
    add_interface_port rx_status rx_calendar export Output [expr 16 * $num_calendar_pgs]
	
    add_interface tx_status conduit start
    add_interface_port tx_status tx_hungry export Output 1
    add_interface_port tx_status tx_overflow export Output 1
    add_interface_port tx_status tx_underflow export Output 1
    
    add_interface tx_control conduit end
    add_interface_port tx_control tx_force_transmit export Input 1
    add_interface_port tx_control tx_channel_enable export Input $num_chan
	add_interface_port tx_control tx_calendar export Input [expr 16 * $num_calendar_pgs]

	if {!$dynamic_calendars} {
		set_port_property rx_calendar TERMINATION TRUE
		set_port_property tx_calendar TERMINATION TRUE
		if {$num_calendar_pgs == 1} {
			set_port_property tx_calendar TERMINATION_VALUE 0xFFFF
		} elseif {$num_calendar_pgs == 8} {
			set_port_property tx_calendar TERMINATION_VALUE 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
		} else {
			set_port_property tx_calendar TERMINATION_VALUE 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
		}
	}

	set dynamic_bursts [get_parameter_value GUI_ENABLE_DYNAMIC_BURST]
	set burst_short_bytes [get_parameter_value GUI_BURST_SHORT]
	add_interface_port tx_control burst_max_in export Input 4
	add_interface_port tx_control burst_short_in export Input 4
	if {!$dynamic_bursts} {
		set_port_property burst_short_in TERMINATION TRUE
		set_port_property burst_max_in TERMINATION TRUE
		set_port_property burst_max_in TERMINATION_VALUE $num_burst_max
		if {$burst_short_bytes == 64} {
			set_port_property burst_short_in TERMINATION_VALUE 0x2
		} else {
			# 32B case is default
			set_port_property burst_short_in TERMINATION_VALUE 0x1
		}
	}    
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

#+----------------------------------
#| adding avalon streaming interfaces
#|


proc add_avln_iface {name type assc_clk is_enabled dir width sym_per_beat} {
    add_interface $name avalon_streaming $type
    set_interface_property $name dataBitsPerSymbol $width
    set_interface_property $name maxChannel 0
    set_interface_property $name readyLatency 0
    set_interface_property $name symbolsPerBeat $sym_per_beat
    set_interface_property $name ENABLED $is_enabled
    set_interface_property $name ASSOCIATED_CLOCK $assc_clk
    set_interface_property $name data $dir $width
}

 set unencrypted_files {"alt_ntrlkn_12l_10g_crc32c_d64x2_factor.v" "alt_ntrlkn_12l_10g_crc32c_d64x2_flat.v" "alt_ntrlkn_12l_10g_crc32c_d64x2.v" "alt_ntrlkn_12l_10g_crc32c_dat64_factor.v" "alt_ntrlkn_12l_10g_crc32c_dat64_flat.v" "alt_ntrlkn_12l_10g_crc32c_dat64_only_factor.v" "alt_ntrlkn_12l_10g_crc32c_dat64_only_flat.v" "alt_ntrlkn_12l_10g_crc32c_dat64_only.v" "alt_ntrlkn_12l_10g_crc32c_dat64.v" "alt_ntrlkn_12l_10g_crc32c_z64x2_factor.v" "alt_ntrlkn_12l_10g_crc32c_z64x2_flat.v" "alt_ntrlkn_12l_10g_crc32c_z64x2.v" "alt_ntrlkn_12l_10g_crc32c_zer64_factor.v" "alt_ntrlkn_12l_10g_crc32c_zer64_flat.v" "alt_ntrlkn_12l_10g_crc32c_zer64.v" "alt_ntrlkn_12l_10g_arbiter.v" "alt_ntrlkn_12l_10g_buffered_read_scheduler_8.v" "alt_ntrlkn_12l_10g_lane_status_monitor.v" "alt_ntrlkn_12l_10g_packet_annotate.v" "alt_ntrlkn_12l_10g_read_scheduler_8.v" "alt_ntrlkn_12l_10g_ready_skid.v" "alt_ntrlkn_12l_10g_tx_2channel_arbiter.v" "alt_ntrlkn_12l_10g_tx_4channel_arbiter.v" "alt_ntrlkn_12l_10g_avalon_to_ilk_adapter_8.v" "alt_ntrlkn_12l_10g_compact_words_8.v" "alt_ntrlkn_12l_10g_crc24_dat64_factor.v" "alt_ntrlkn_12l_10g_crc24_dat64_flat.v" "alt_ntrlkn_12l_10g_crc24_dat64_only_flat.v" "alt_ntrlkn_12l_10g_crc24_dat64.v" "alt_ntrlkn_12l_10g_crc24_multiple_upto10.v" "alt_ntrlkn_12l_10g_crc24_multiple_upto2.v" "alt_ntrlkn_12l_10g_crc24_multiple_upto3.v" "alt_ntrlkn_12l_10g_crc24_multiple_upto4.v" "alt_ntrlkn_12l_10g_crc24_multiple_upto5.v" "alt_ntrlkn_12l_10g_crc24_multiple_upto6.v" "alt_ntrlkn_12l_10g_crc24_multiple_upto7.v" "alt_ntrlkn_12l_10g_crc24_multiple_upto8.v"	"alt_ntrlkn_12l_10g_crc24_multiple_upto9.v" "alt_ntrlkn_12l_10g_crc24_zer64_flat.v" "alt_ntrlkn_12l_10g_crc24_zer64x10_flat.v" "alt_ntrlkn_12l_10g_crc24_zer64x2_flat.v" "alt_ntrlkn_12l_10g_crc24_zer64x3_flat.v" "alt_ntrlkn_12l_10g_crc24_zer64x4_flat.v" "alt_ntrlkn_12l_10g_crc24_zer64x5_flat.v" "alt_ntrlkn_12l_10g_crc24_zer64x6_flat.v" "alt_ntrlkn_12l_10g_crc24_zer64x7_flat.v" "alt_ntrlkn_12l_10g_crc24_zer64x8_flat.v" "alt_ntrlkn_12l_10g_crc24_zer64x9_flat.v" "alt_ntrlkn_12l_10g_packet_regroup_8.v" "alt_ntrlkn_12l_10g_regroup_8.v" "alt_ntrlkn_12l_10g_rx_channel_filter_8.v" "alt_ntrlkn_12l_10g_wide_word_ram_8.v" "alt_ntrlkn_12l_10g_rx_12lane.v" "alt_ntrlkn_12l_10g_tx_12lane.v" "alt_ntrlkn_12l_10g_xcvr_12lane.v"}


    set encrypted_files { "alt_ntrlkn_12l_10g_align_dcf.v" "alt_ntrlkn_12l_10g_align_fifo.v" "alt_ntrlkn_12l_10g_alignment_pipe.v" "alt_ntrlkn_12l_10g_buffer_1_to_2.v" "alt_ntrlkn_12l_10g_buffer_2_to_1.v" "alt_ntrlkn_12l_10g_channel_fifo.v" "alt_ntrlkn_12l_10g_dec_67_64.v" "alt_ntrlkn_12l_10g_enc_64_67.v" "alt_ntrlkn_12l_10g_fifo_36_to_72.v" "alt_ntrlkn_12l_10g_fifo_72_to_36.v" "alt_ntrlkn_12l_10g_frame_sync_control.v" "alt_ntrlkn_12l_10g_gearbox_40_67.v" "alt_ntrlkn_12l_10g_gearbox_67_40.v" "alt_ntrlkn_12l_10g_lal_cfifo.v" "alt_ntrlkn_12l_10g_lal_dcfifo.v" "alt_ntrlkn_12l_10g_lal_dfifo_auto.v" "alt_ntrlkn_12l_10g_lane_alignment.v" "alt_ntrlkn_12l_10g_lane_alignment_nav.v" "alt_ntrlkn_12l_10g_lane_alignment_ram.v" "alt_ntrlkn_12l_10g_lane_rx.v" "alt_ntrlkn_12l_10g_lane_rx_crc.v" "alt_ntrlkn_12l_10g_lane_tx.v" "alt_ntrlkn_12l_10g_lane_tx_crc.v" "alt_ntrlkn_12l_10g_pipelined_any_flag.v" "alt_ntrlkn_12l_10g_ram_navigate.v" "alt_ntrlkn_12l_10g_read_calendar_8.v" "alt_ntrlkn_12l_10g_read_calendar_single_page_8.v" "alt_ntrlkn_12l_10g_routing_pipe.v" "alt_ntrlkn_12l_10g_rx_buffer_fifo_2.v" "alt_ntrlkn_12l_10g_rx_crc24_check_8.v" "alt_ntrlkn_12l_10g_rx_datapath_12lane.v" "alt_ntrlkn_12l_10g_rx_stripe_adapter.v" "alt_ntrlkn_12l_10g_scrambler_lfsr.v" "alt_ntrlkn_12l_10g_sim_packet_client.v" "alt_ntrlkn_12l_10g_six_three_comp.v" "alt_ntrlkn_12l_10g_sum_of_3bit_pair.v" "alt_ntrlkn_12l_10g_synchronizer.v" "alt_ntrlkn_12l_10g_ternary_add.v" "alt_ntrlkn_12l_10g_twelve_four_comp.v" "alt_ntrlkn_12l_10g_tx_buffer_fifo_8word.v" "alt_ntrlkn_12l_10g_tx_buffer_fifo_nav.v" "alt_ntrlkn_12l_10g_tx_buffer_fifo_ram.v" "alt_ntrlkn_12l_10g_tx_buffer_fifo_ram_loose.v" "alt_ntrlkn_12l_10g_tx_control_insertion_8.v" "alt_ntrlkn_12l_10g_tx_crc24_insertion_8.v" "alt_ntrlkn_12l_10g_tx_datapath_12lane.v" "alt_ntrlkn_12l_10g_tx_flow_adapter.v" "alt_ntrlkn_12l_10g_tx_stripe_adapter.v" "alt_ntrlkn_12l_10g_wide_word_ram.v" "alt_ntrlkn_12l_10g_word_align_control.v" "alt_ntrlkn_12l_10g_xor6.v"}
    

#+-----------------------
#| generate_synth
#|

# proc generate_synth {name} {

#     global unencrypted_files
#     global encrypted_files
    
#     foreach unenc_file $unencrypted_files {
	  
# 	  add_fileset_file $unenc_file VERILOG PATH $unenc_file
#       }
      
#       foreach enc_file $encrypted_files {
	   
# 	   add_fileset_file $enc_file VERILOG PATH $enc_file
#        }
      
# }


#+-----------------------
#| sim_ver
#|

proc sim_ver {name} {


    global unencrypted_files
    global encrypted_files
    
    foreach unenc_file $unencrypted_files {
	
	
	if {[file exist $unenc_file]} {
	    add_fileset_file ${unenc_file} VERILOG PATH ${unenc_file}
	} else {
	    send_message error "$unenc_file is missing"
	}
    }

    
    foreach enc_file $encrypted_files {
	if {[file exist "mentor/${enc_file}"]} {
	    add_fileset_file mentor/${enc_file} VERILOG PATH "mentor/${enc_file}" {MENTOR_SPECIFIC}
	} else {
	    set mentor_support 0
	}
	
	if {[file exist "aldec/${enc_file}"]} {
	    add_fileset_file aldec/${enc_file} VERIlOG PATH "aldec/${enc_file}" {ALDEC_SPECIFIC}
	} else {
	    set aldec_support 0
	}
	
	if {[file exist "cadence/${enc_file}"]} {
	    add_fileset_file cadence/${enc_file} VERILOG PATH "cadence/${enc_file}" {CADENCE_SPECIFIC}
	} else {
	    set cadence_support 0
	}
	
	if {[file exist "synopsys/${enc_file}"]} {
	    add_fileset_file synopsys/${enc_file} VERILOG PATH "synopsys/${enc_file}" {SYNOPSYS_SPECIFIC}
	} else {
	    set synopsys_support 0
	}
    }	
	
    

}
