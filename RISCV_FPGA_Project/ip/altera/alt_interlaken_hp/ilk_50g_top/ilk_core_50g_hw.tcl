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


#|
#| altera_interlaken 50G
#|
#+-----------------------------

# +-----------------------------------
# | request TCL package from ACDS 12.1
# | 
package require -exact qsys 13.0
package require altera_terp 1.0
# | 
# +-----------------------------------

# +-----------------------------------
# | module interlaken_50G_8lane_6G
# | 
send_message PROGRESS "reading tcl" 

set_module_property NAME ilk_core_50g
set_module_property VERSION 13.1
set_module_property INTERNAL false
set_module_property DISPLAY_NAME "50G Interlaken"
set_module_property EDITABLE false
set_module_property ANALYZE_HDL false
set_module_property GROUP "Interface Protocols/Interlaken"
set_module_property AUTHOR "Altera Corporation"
set_module_property DESCRIPTION "Altera Interlaken"
set_module_property DATASHEET_URL "http://www.altera.com/literature/ug/ug_50g_interlaken.pdf"
set_module_property HIDE_FROM_QSYS true

add_fileset synth QUARTUS_SYNTH synth_proc
set_fileset_property synth TOP_LEVEL ilk_core_50g


set_module_property ELABORATION_CALLBACK elaborate
set_module_property VALIDATION_CALLBACK validate_proc

# # Add fileset for simulation  
add_fileset simulation_verilog SIM_VERILOG sim_ver
set_fileset_property simulation_verilog TOP_LEVEL ilk_core_50g

# # Add fileset for example_design
# add_fileset testbench EXAMPLE_DESIGN testbench_ver
# set_fileset_property testbench TOP_LEVEL ilk_core_50g

# | 
# +-----------------------------------

#+-----------------------------------
#| display tabs
#| 
add_display_item "" "General" GROUP
add_display_item "" "PCS" GROUP
add_display_item "" "Block Diagram" GROUP


#+-----------------------------------
#| parameters
#|

add_parameter DEVICE_FAMILY STRING
set_parameter_property DEVICE_FAMILY DISPLAY_NAME "Device family"
set_parameter_property DEVICE_FAMILY SYSTEM_INFO {DEVICE_FAMILY}
set_parameter_property DEVICE_FAMILY ALLOWED_RANGES {"Stratix V" "Arria V GZ" "Arria 10"}
set_parameter_property DEVICE_FAMILY DESCRIPTION "Supports Stratix V, Arria V GZ and  Arria 10 devices."
set_parameter_property DEVICE_FAMILY HDL_PARAMETER false
set_parameter_property DEVICE_FAMILY ENABLED false
add_display_item "General" DEVICE_FAMILY parameter

# FAMILY 
add_parameter FAMILY STRING
set_parameter_property FAMILY DEFAULT_VALUE "Stratix V"
set_parameter_property FAMILY DISPLAY_NAME "family"
set_parameter_property FAMILY ALLOWED_RANGES  {"Stratix V" "Arria V GZ" "Arria 10"}
set_parameter_property FAMILY DISPLAY_HINT ""
set_parameter_property FAMILY AFFECTS_ELABORATION true
set_parameter_property FAMILY AFFECTS_GENERATION true
set_parameter_property FAMILY DESCRIPTION "Specifies family type"
set_parameter_property FAMILY VISIBLE false
set_parameter_property FAMILY DERIVED true
set_parameter_property FAMILY HDL_PARAMETER ture
add_display_item "General" FAMILY parameter

add_parameter OPERATIONAL_MODE INTEGER 0 Duplex
set_parameter_property OPERATIONAL_MODE DISPLAY_NAME "Operational mode"
set_parameter_property OPERATIONAL_MODE ALLOWED_RANGES {0:Duplex }
set_parameter_property OPERATIONAL_MODE DISPLAY_HINT "string"
set_parameter_property OPERATIONAL_MODE DESCRIPTION "Only duplex mode is supported"
set_parameter_property OPERATIONAL_MODE AFFECTS_ELABORATION true
set_parameter_property OPERATIONAL_MODE HDL_PARAMETER false
set_parameter_property OPERATIONAL_MODE ENABLED false
set_parameter_property OPERATIONAL_MODE VISIBLE false
add_display_item "General" OPERATIONAL_MODE parameter

# # RXFIFO_ADDR_WIDTH, HDL parameter, 11
add_parameter RXFIFO_ADDR_WIDTH INTEGER 12
set_parameter_property RXFIFO_ADDR_WIDTH DEFAULT_VALUE 12
set_parameter_property RXFIFO_ADDR_WIDTH DISPLAY_NAME "RX FIFO address width"
set_parameter_property RXFIFO_ADDR_WIDTH ALLOWED_RANGES {11 12}
set_parameter_property RXFIFO_ADDR_WIDTH DISPLAY_HINT ""
set_parameter_property RXFIFO_ADDR_WIDTH AFFECTS_ELABORATION true
set_parameter_property RXFIFO_ADDR_WIDTH AFFECTS_GENERATION true
set_parameter_property RXFIFO_ADDR_WIDTH HDL_PARAMETER ture
set_parameter_property RXFIFO_ADDR_WIDTH VISIBLE false
set_parameter_property RXFIFO_ADDR_WIDTH DESCRIPTION "Receiver FIFO Address Width"
add_display_item "General" RXFIFO_ADDR_WIDTH parameter

# # CNTR_BITS, HDL parameter
add_parameter CNTR_BITS INTEGER 20
set_parameter_property CNTR_BITS DEFAULT_VALUE 20
set_parameter_property CNTR_BITS DISPLAY_NAME "Counter bits"
set_parameter_property CNTR_BITS ALLOWED_RANGES {6 20}
set_parameter_property CNTR_BITS DISPLAY_HINT ""
set_parameter_property CNTR_BITS AFFECTS_ELABORATION true
set_parameter_property CNTR_BITS AFFECTS_GENERATION true
set_parameter_property CNTR_BITS VISIBLE false
set_parameter_property CNTR_BITS HDL_PARAMETER ture
add_display_item "General" CNTR_BITS parameter

# # NUM_LANES, HDL parameter
add_parameter NUM_LANES INTEGER 8
set_parameter_property NUM_LANES DEFAULT_VALUE 8
set_parameter_property NUM_LANES DISPLAY_NAME "Number of lanes"
set_parameter_property NUM_LANES ALLOWED_RANGES {8}
set_parameter_property NUM_LANES DISPLAY_HINT ""
set_parameter_property NUM_LANES AFFECTS_ELABORATION true
set_parameter_property NUM_LANES AFFECTS_GENERATION true
set_parameter_property NUM_LANES HDL_PARAMETER ture
set_parameter_property NUM_LANES ENABLED false
set_parameter_property NUM_LANES DESCRIPTION "Supports 8-lane configuration. Additional lane and data rate configurations are available. Contact your Altera sales representative or email interlaken@altera.com for more information."
add_display_item "General" NUM_LANES parameter

# # CALENDAR_PAGES, HDL parameter, 1
add_parameter CALENDAR_PAGES INTEGER 1
set_parameter_property CALENDAR_PAGES DEFAULT_VALUE 1
set_parameter_property CALENDAR_PAGES DISPLAY_NAME "Number of calendar pages"
set_parameter_property CALENDAR_PAGES ALLOWED_RANGES {1,2,4,8,16}
set_parameter_property CALENDAR_PAGES DISPLAY_HINT ""
set_parameter_property CALENDAR_PAGES DESCRIPTION "In-band flow control supports 16-bit calendar pages. Supported numbers of pages are 1, 2, 4, 8, and 16. Flow control channels can be mapped to a calendar entry or entries."
set_parameter_property CALENDAR_PAGES HDL_PARAMETER true
set_parameter_property CALENDAR_PAGES AFFECTS_ELABORATION true
add_display_item "In-Band Flow Control" CALENDAR_PAGES parameter

# #  LOG_CALENDAR_PAGES, derived HDL parameter, 1 
add_parameter LOG_CALENDAR_PAGES INTEGER 1
set_parameter_property LOG_CALENDAR_PAGES DEFAULT_VALUE 1
set_parameter_property LOG_CALENDAR_PAGES ALLOWED_RANGES {1 2 3 4}
set_parameter_property LOG_CALENDAR_PAGES TYPE INTEGER
set_parameter_property LOG_CALENDAR_PAGES UNITS None
set_parameter_property LOG_CALENDAR_PAGES HDL_PARAMETER true
set_parameter_property LOG_CALENDAR_PAGES VISIBLE false
set_parameter_property LOG_CALENDAR_PAGES DERIVED true

# # # INCLUDE_TEMP_SENSE, HDL parameter, integer  
# add_parameter INCLUDE_TEMP_SENSE INTEGER 1
# set_parameter_property INCLUDE_TEMP_SENSE DEFAULT_VALUE 1
# set_parameter_property INCLUDE_TEMP_SENSE DISPLAY_NAME "Temperature sensor enable"
# set_parameter_property INCLUDE_TEMP_SENSE ALLOWED_RANGES {1}
# set_parameter_property INCLUDE_TEMP_SENSE DISPLAY_HINT ""
# set_parameter_property INCLUDE_TEMP_SENSE DESCRIPTION "Specifies the number of calendar pages; 16 bits per page"
# set_parameter_property INCLUDE_TEMP_SENSE HDL_PARAMETER true
# set_parameter_property INCLUDE_TEMP_SENSE AFFECTS_ELABORATION true
# add_display_item "Temperature enable " INCLUDE_TEMP_SENSE parameter

# # METALEN, HDL parameter, 64, range  
add_parameter METALEN INTEGER 2048
set_parameter_property METALEN DEFAULT_VALUE 2048
set_parameter_property METALEN DISPLAY_NAME "Meta frame length in words"
set_parameter_property METALEN ALLOWED_RANGES 128:8191
set_parameter_property METALEN TYPE INTEGER
set_parameter_property METALEN UNITS None
set_parameter_property METALEN HDL_PARAMETER true
set_parameter_property METALEN DESCRIPTION "Specifies the meta frame length; possible lengths are 128-8191 words."
add_display_item "General" METALEN parameter

# # # SCRAM_CONST, HDL parameter, integer  
# add_parameter SCRAM_CONST INTEGER 1
# set_parameter_property SCRAM_CONST DEFAULT_VALUE 58'hdeadbeef123
# set_parameter_property SCRAM_CONST DISPLAY_NAME "SCRAM_CONST"
# set_parameter_property SCRAM_CONST ALLOWED_RANGES {58'hdeadbeef123}
# set_parameter_property SCRAM_CONST DISPLAY_HINT ""
# set_parameter_property SCRAM_CONST DESCRIPTION "This number need to be different for different instantiations of interlaken reduce cross talk"
# set_parameter_property SCRAM_CONST HDL_PARAMETER true
# set_parameter_property SCRAM_CONST AFFECTS_ELABORATION true
# add_display_item "SCRAM_CONST " SCRAM_CONST parameter

# # INTERNAL_WORDS, HDL parameter, 4
add_parameter INTERNAL_WORDS INTEGER 1
set_parameter_property INTERNAL_WORDS DEFAULT_VALUE 4
set_parameter_property INTERNAL_WORDS DISPLAY_NAME "Internal words"
set_parameter_property INTERNAL_WORDS ALLOWED_RANGES {4}
set_parameter_property INTERNAL_WORDS DISPLAY_HINT ""
set_parameter_property INTERNAL_WORDS DESCRIPTION "Internal words"
set_parameter_property INTERNAL_WORDS VISIBLE false
set_parameter_property INTERNAL_WORDS HDL_PARAMETER true
set_parameter_property INTERNAL_WORDS AFFECTS_ELABORATION true
add_display_item "Internal words" INTERNAL_WORDS parameter

# # W_BUNDLE_TO_XCVR  
add_parameter W_BUNDLE_TO_XCVR INTEGER 70
set_parameter_property W_BUNDLE_TO_XCVR DEFAULT_VALUE 70
set_parameter_property W_BUNDLE_TO_XCVR DISPLAY_NAME "W_BUNDLE_TO_XCVR"
set_parameter_property W_BUNDLE_TO_XCVR ALLOWED_RANGES {70}
set_parameter_property W_BUNDLE_TO_XCVR DISPLAY_HINT ""
set_parameter_property W_BUNDLE_TO_XCVR DESCRIPTION "W_BUNDLE_TO_XCVR"
set_parameter_property W_BUNDLE_TO_XCVR VISIBLE false
set_parameter_property W_BUNDLE_TO_XCVR HDL_PARAMETER true
set_parameter_property W_BUNDLE_TO_XCVR AFFECTS_ELABORATION true
add_display_item "W_BUNDLE_TO_XCVR" W_BUNDLE_TO_XCVR parameter

# # W_BUNDLE_FROM_XCVR
add_parameter W_BUNDLE_FROM_XCVR INTEGER 46
set_parameter_property W_BUNDLE_FROM_XCVR DEFAULT_VALUE 46
set_parameter_property W_BUNDLE_FROM_XCVR DISPLAY_NAME "W_BUNDLE_FROM_XCVR"
set_parameter_property W_BUNDLE_FROM_XCVR ALLOWED_RANGES {46}
set_parameter_property W_BUNDLE_FROM_XCVR DISPLAY_HINT ""
set_parameter_property W_BUNDLE_FROM_XCVR DESCRIPTION "W_BUNDLE_FROM_XCVR"
set_parameter_property W_BUNDLE_FROM_XCVR VISIBLE false
set_parameter_property W_BUNDLE_FROM_XCVR HDL_PARAMETER true
set_parameter_property W_BUNDLE_FROM_XCVR AFFECTS_ELABORATION true
add_display_item "W_BUNDLE_FROM_XCVR" W_BUNDLE_FROM_XCVR parameter

# USE_ATX 
# add_parameter USE_ATX Boolean 1
# set_parameter_property USE_ATX DEFAULT_VALUE 1
# set_parameter_property USE_ATX DISPLAY_NAME "USE_ATX"
# # set_parameter_property USE_ATX ALLOWED_RANGES {0 1}
# set_parameter_property USE_ATX DISPLAY_HINT ""
# set_parameter_property USE_ATX AFFECTS_ELABORATION true
# set_parameter_property USE_ATX AFFECTS_GENERATION true
# set_parameter_property USE_ATX VISIBLE false
# set_parameter_property USE_ATX HDL_PARAMETER ture
# add_display_item "Reconfig Settings" USE_ATX parameter

# # BONDED 
# add_parameter BONDED INTEGER 0 
# set_parameter_property BONDED DISPLAY_NAME "BONDED"
# set_parameter_property BONDED ALLOWED_RANGES {0 1 }
# set_parameter_property BONDED DISPLAY_HINT "BONDED"
# set_parameter_property BONDED DESCRIPTION "BONDED"
# set_parameter_property BONDED AFFECTS_ELABORATION true
# set_parameter_property BONDED HDL_PARAMETER true
# set_parameter_property BONDED ENABLED false
# add_display_item "General" BONDED parameter


# # DATA_RATE 
# add_parameter DATA_RATE STRING
# set_parameter_property DATA_RATE DEFAULT_VALUE "6250.0 Mbps"
# set_parameter_property DATA_RATE DISPLAY_NAME "Data rate"
# set_parameter_property DATA_RATE ALLOWED_RANGES {"6250.0 Mbps"}
# set_parameter_property DATA_RATE DISPLAY_HINT ""
# set_parameter_property DATA_RATE AFFECTS_ELABORATION true
# set_parameter_property DATA_RATE AFFECTS_GENERATION true
# set_parameter_property DATA_RATE DESCRIPTION "Specifies data rate on each lane"
# set_parameter_property DATA_RATE ENABLED false
# set_parameter_property DATA_RATE HDL_PARAMETER ture
# add_display_item "General" DATA_RATE parameter

# DATA_RATE_GUI 
add_parameter DATA_RATE_GUI STRING
set_parameter_property DATA_RATE_GUI DEFAULT_VALUE "6.25"
set_parameter_property DATA_RATE_GUI DISPLAY_NAME "Data rate"
set_parameter_property DATA_RATE_GUI ALLOWED_RANGES {"6.25" }
set_parameter_property DATA_RATE_GUI UNITS GigabitsPerSecond
set_parameter_property DATA_RATE_GUI DISPLAY_HINT ""
set_parameter_property DATA_RATE_GUI AFFECTS_ELABORATION true
set_parameter_property DATA_RATE_GUI AFFECTS_GENERATION true
set_parameter_property DATA_RATE_GUI DESCRIPTION "Supports one data rate: 6.25 Gbps."
add_display_item "General" DATA_RATE_GUI parameter

# DATA_RATE 
add_parameter DATA_RATE STRING
set_parameter_property DATA_RATE DEFAULT_VALUE "6250.0 Mbps"
set_parameter_property DATA_RATE DISPLAY_NAME "Data rate internal"
set_parameter_property DATA_RATE ALLOWED_RANGES {"6250.0 Mbps"}
set_parameter_property DATA_RATE DISPLAY_HINT ""
set_parameter_property DATA_RATE AFFECTS_ELABORATION true
set_parameter_property DATA_RATE AFFECTS_GENERATION true
set_parameter_property DATA_RATE DESCRIPTION "Specifies data rate on each lane"
set_parameter_property DATA_RATE VISIBLE false
set_parameter_property DATA_RATE DERIVED true
set_parameter_property DATA_RATE HDL_PARAMETER ture
add_display_item "General" DATA_RATE parameter

# PLL_OUT_FREQ
add_parameter PLL_OUT_FREQ STRING
set_parameter_property PLL_OUT_FREQ DEFAULT_VALUE "3125.0 MHz"
set_parameter_property PLL_OUT_FREQ DISPLAY_NAME "PLL_OUT_FREQ"
set_parameter_property PLL_OUT_FREQ ALLOWED_RANGES {"3125.0 MHz"}
set_parameter_property PLL_OUT_FREQ DISPLAY_HINT ""
set_parameter_property PLL_OUT_FREQ AFFECTS_ELABORATION true
set_parameter_property PLL_OUT_FREQ AFFECTS_GENERATION true
set_parameter_property PLL_OUT_FREQ VISIBLE false
set_parameter_property PLL_OUT_FREQ HDL_PARAMETER ture
set_parameter_property PLL_OUT_FREQ DERIVED true
add_display_item "Reconfig Settings" PLL_OUT_FREQ parameter

# PLL_REFCLK_FREQ
add_parameter PLL_REFCLK_FREQ STRING
set_parameter_property PLL_REFCLK_FREQ DEFAULT_VALUE "312.5 MHz"
set_parameter_property PLL_REFCLK_FREQ DISPLAY_NAME "Transceiver reference clock frequency"
set_parameter_property PLL_REFCLK_FREQ ALLOWED_RANGES {"156.25 MHz" "195.3125 MHz" "250.0 MHz" "312.5 MHz" "390.625 MHz" "500.0 MHz" "625.0 MHz" }
set_parameter_property PLL_REFCLK_FREQ DISPLAY_HINT ""
set_parameter_property PLL_REFCLK_FREQ AFFECTS_ELABORATION true
set_parameter_property PLL_REFCLK_FREQ AFFECTS_GENERATION true
set_parameter_property PLL_REFCLK_FREQ VISIBLE true
set_parameter_property PLL_REFCLK_FREQ HDL_PARAMETER ture
# set_parameter_property PLL_REFCLK_FREQ DERIVED true
set_parameter_property PLL_REFCLK_FREQ DESCRIPTION "Supports multiple transceiver reference clock frequencies for flexibility in oscillator and PLL choices."
add_display_item "General" PLL_REFCLK_FREQ parameter

# INT_TX_CLK_DIV, this value is derived based on frequency
add_parameter INT_TX_CLK_DIV INTEGER 1
set_parameter_property INT_TX_CLK_DIV DEFAULT_VALUE 1
set_parameter_property INT_TX_CLK_DIV DISPLAY_NAME "INT_TX_CLK_DIV"
set_parameter_property INT_TX_CLK_DIV ALLOWED_RANGES {1}
set_parameter_property INT_TX_CLK_DIV DISPLAY_HINT ""
set_parameter_property INT_TX_CLK_DIV AFFECTS_ELABORATION true
set_parameter_property INT_TX_CLK_DIV AFFECTS_GENERATION true
set_parameter_property INT_TX_CLK_DIV VISIBLE false
set_parameter_property INT_TX_CLK_DIV HDL_PARAMETER ture
set_parameter_property INT_TX_CLK_DIV DERIVED true
add_display_item "Reconfig Settings" INT_TX_CLK_DIV parameter

# LANE_PROFILE
add_parameter LANE_PROFILE Std_logic_vector 
set_parameter_property LANE_PROFILE WIDTH 24
set_parameter_property LANE_PROFILE DEFAULT_VALUE 24'b000000000000101101101101
set_parameter_property LANE_PROFILE DISPLAY_NAME "LANE_PROFILE"
# set_parameter_property LANE_PROFILE ALLOWED_RANGES {000000000000111111111111 111111111111111111111111}
set_parameter_property LANE_PROFILE DISPLAY_HINT ""
set_parameter_property LANE_PROFILE AFFECTS_ELABORATION true
set_parameter_property LANE_PROFILE AFFECTS_GENERATION true
set_parameter_property LANE_PROFILE VISIBLE false
set_parameter_property LANE_PROFILE HDL_PARAMETER ture
set_parameter_property LANE_PROFILE DERIVED true
add_display_item "Reconfig Settings" LANE_PROFILE parameter

# NUM_SIXPACKS is set as a default value of 2/replaced by count_sixpacks inside ilk_core_50g
add_parameter NUM_SIXPACKS INTEGER 2
set_parameter_property NUM_SIXPACKS DEFAULT_VALUE 2
set_parameter_property NUM_SIXPACKS DISPLAY_NAME "NUM_SIXPACKS"
set_parameter_property NUM_SIXPACKS ALLOWED_RANGES {2 4}
set_parameter_property NUM_SIXPACKS DISPLAY_HINT ""
set_parameter_property NUM_SIXPACKS AFFECTS_ELABORATION true
set_parameter_property NUM_SIXPACKS AFFECTS_GENERATION true
set_parameter_property NUM_SIXPACKS VISIBLE false
set_parameter_property NUM_SIXPACKS HDL_PARAMETER ture
set_parameter_property NUM_SIXPACKS DERIVED true
add_display_item "Reconfig Settings" NUM_SIXPACKS parameter

# Interleave
# add_parameter INTERLEAVE Boolean 1
# set_parameter_property INTERLEAVE DEFAULT_VALUE 1
# set_parameter_property INTERLEAVE DISPLAY_NAME "Interleave mode selection"
# set_parameter_property INTERLEAVE DISPLAY_HINT ""
# set_parameter_property INTERLEAVE AFFECTS_ELABORATION true
# set_parameter_property INTERLEAVE AFFECTS_GENERATION true
# set_parameter_property INTERLEAVE AFFECTS_VALIDATION true
# set_parameter_property INTERLEAVE VISIBLE false
# set_parameter_property INTERLEAVE HDL_PARAMETER false
# set_parameter_property INTERLEAVE DESCRIPTION "Interleave mode selection"
# add_display_item "Interleave Mode Selection" INTERLEAVE parameter

# RX_PKTMOD_ONLY
add_parameter RX_PKTMOD_ONLY INTEGER 0 Interleave
set_parameter_property RX_PKTMOD_ONLY DEFAULT_VALUE 1
set_parameter_property RX_PKTMOD_ONLY DISPLAY_NAME "RX Packet mode Selection"
set_parameter_property RX_PKTMOD_ONLY ALLOWED_RANGES {0:"Interleaved" 1:"Packet only" }
set_parameter_property RX_PKTMOD_ONLY DISPLAY_HINT ""
set_parameter_property RX_PKTMOD_ONLY AFFECTS_ELABORATION true
set_parameter_property RX_PKTMOD_ONLY AFFECTS_GENERATION true
set_parameter_property RX_PKTMOD_ONLY HDL_PARAMETER ture
# set_parameter_property RX_PKTMOD_ONLY DERIVED true
set_parameter_property RX_PKTMOD_ONLY VISIBLE false
set_parameter_property RX_PKTMOD_ONLY DESCRIPTION  ":  Supports two modes for packet transfer flexibility and ASIC/ASSP/FPGA/SoC interoperability."
add_display_item "User data transfer interface" RX_PKTMOD_ONLY parameter
 
 # TX_PKTMOD_ONLY
add_parameter TX_PKTMOD_ONLY INTEGER 0  
set_parameter_property TX_PKTMOD_ONLY DEFAULT_VALUE 0
set_parameter_property TX_PKTMOD_ONLY DISPLAY_NAME "Transfer mode selection"
set_parameter_property TX_PKTMOD_ONLY ALLOWED_RANGES {"0:Interleaved (segment)" "1:Packet" }
set_parameter_property TX_PKTMOD_ONLY DISPLAY_HINT radio
set_parameter_property TX_PKTMOD_ONLY AFFECTS_ELABORATION true
set_parameter_property TX_PKTMOD_ONLY AFFECTS_GENERATION true
set_parameter_property TX_PKTMOD_ONLY HDL_PARAMETER ture
# set_parameter_property TX_PKTMOD_ONLY DERIVED true
set_parameter_property TX_PKTMOD_ONLY VISIBLE true
set_parameter_property TX_PKTMOD_ONLY DESCRIPTION  "Supports two modes for packet transfer flexibility and ASIC/ASSP/FPGA/SoC interoperability."
add_display_item "User data transfer interface" TX_PKTMOD_ONLY parameter

#+-------------------------------
#| VALIDATE CALLBACK
#|


proc validate_proc {} {

    set dev [get_parameter_value DEVICE_FAMILY]
    set num_of_lanes [get_parameter_value NUM_LANES]
	set rx_packet_mode [get_parameter_value RX_PKTMOD_ONLY]
	set tx_packet_mode [get_parameter_value TX_PKTMOD_ONLY]
# METALEN
    set meta_len [get_parameter_value METALEN]	
	
    # if {$dev == "Stratix V"} {
	# send_message info "The device selected is Stratix V"
	# } elseif {$dev == "Arria V GZ"} {
	# send_message info "The device selected is Arria V GZ"	
	# } elseif {$dev == "Arria 10"} {
	# send_message info "The device selected is Arria 10"	
	# } else {
	# send_message error "$dev is not supported, only Stratix V,Arria V GZ  and Arria 10 is supported"
    # }  


    if {$dev == "Arria V GZ" && $num_of_lanes == 24} {
	send_message error "Please select 12 lanes for Arria V GZ device "
	} else {
 
    } 	
	
	
    if {$meta_len < 128 || $meta_len > 8191  } {
	send_message error "Please enter meta frame length between 128 and 8191"
    } else {
	# send_message info "Meta frame length entered is $meta_len"
    }  	
 

} 


# +-------------------------------
# |ELABORATE CALLBACK
# |

proc elaborate {} {

    add_interfaces 

		set dev_family [get_parameter_value DEVICE_FAMILY]
        set num_of_lanes [get_parameter_value NUM_LANES]
        set data_rate_string [get_parameter_value DATA_RATE]
		# truncate Mbps and convert string to number
		set data_rate_num [expr [string trim $data_rate_string Mbps ] ]
		set meta_length [get_parameter_value METALEN]
		set pll_ref_string [get_parameter_value PLL_REFCLK_FREQ]
		set pll_ref_num [expr [string trim $pll_ref_string MHz ] ]
      if {$data_rate_string == "6250.0 Mbps"} {
		set atxpll_out_clk_freq "3125.0 MHz"
		# set pll_ref_num "156.25"
		# send_message info "atx pll out clock frequency is $atxpll_out_clk_freq" 
	   } else {
		# send_message info "atx pll out clock frequency is not set"
	   }
		
	if {$dev_family == "Arria 10"} {
	    # send_message info "The value of data rate num is $data_rate_num" 
	    # send_message info "The value of pll ref num is $pll_ref_num" 	

		   ########## add ATX PLL    ###############
		   add_hdl_instance atxpll altera_xcvr_atx_pll_a10
         set atxpll_param_val_list [list message_level error speed_grade fastest prot_mode Basic bw_sel low refclk_cnt 1 refclk_index 0  primary_pll_buffer {GX clock output buffer} enable_8G_path 1 set_output_clock_frequency $atxpll_out_clk_freq set_auto_reference_clock_frequency $pll_ref_num ]
           foreach {param val} $atxpll_param_val_list {
             set_instance_parameter_value atxpll $param $val
           }

         add_hdl_instance np altera_xcvr_native_a10
        set param_val_list [list device_family {Arria 10} protocol_mode interlaken_mode channels $num_of_lanes set_data_rate $data_rate_num plls 2 set_cdr_refclk_freq $pll_ref_num enable_ports_rx_manual_cdr_mode 1 enable_port_rx_seriallpbken 1 enh_pld_pcs_width 67 enh_txfifo_mode Interlaken enh_txfifo_pfull 13 enh_txfifo_pempty 5 enable_port_tx_enh_fifo_full 1 enable_port_tx_enh_fifo_pfull 1 enable_port_tx_enh_fifo_empty 1 enable_port_tx_enh_fifo_pempty 1 enable_port_tx_enh_fifo_cnt 1 enh_rxfifo_mode Interlaken enh_rxfifo_pempty 8 enable_port_rx_enh_data_valid 1 enable_port_rx_enh_fifo_full 1 enable_port_rx_enh_fifo_pfull 1 enable_port_rx_enh_fifo_empty 1 enable_port_rx_enh_fifo_pempty 1 enable_port_rx_enh_fifo_rd_en 1 enable_port_rx_enh_fifo_align_val 1 enable_port_rx_enh_fifo_align_clr 1 enh_tx_frmgen_enable 1 enh_tx_frmgen_mfrm_length $meta_length enh_tx_frmgen_burst_enable 1 enable_port_tx_enh_frame 1 enable_port_tx_enh_frame_diag_status 1 enable_port_tx_enh_frame_burst_en 1 enh_rx_frmsync_enable 1 enh_rx_frmsync_mfrm_length $meta_length enable_port_rx_enh_frame 1 enable_port_rx_enh_frame_lock 1 enable_port_rx_enh_frame_diag_status 1 enh_tx_crcgen_enable 1 enh_rx_crcchk_enable 1 enable_port_rx_enh_crc32_err 1 enh_tx_scram_enable 1 enh_tx_scram_seed 1 enh_rx_descram_enable 1 enh_tx_dispgen_enable 1 enh_rx_dispchk_enable 1 enh_rx_blksync_enable 1 enable_port_rx_enh_blk_lock 1 generate_add_hdl_instance_example 1 rcfg_enable 1 rcfg_shared 1 rcfg_file_prefix altera_xcvr_native_vi ]
         foreach {param val} $param_val_list {
           set_instance_parameter_value np $param $val
         }
	} else {
		# send_message info "******* not running add hdl inst ***************" 
	}	

	
} 

proc add_interfaces {} {

    set dev_family [get_parameter_value DEVICE_FAMILY]
	set internal_word_size [get_parameter_value INTERNAL_WORDS]
	set num_of_lanes [get_parameter_value NUM_LANES]
	set data_rate [get_parameter_value DATA_RATE]
	set rx_fifo_addr_width [get_parameter_value RXFIFO_ADDR_WIDTH]	
	set num_calendar_pgs [get_parameter_value CALENDAR_PAGES]
	# set interleave_mode [get_parameter_value INTERLEAVE]
	set num_of_sixpack [get_parameter_value NUM_SIXPACKS]


	set data_rate_gui [get_parameter_value DATA_RATE_GUI]
	
    if {$data_rate_gui == "6.25"} {
		set_parameter_value DATA_RATE "6250.0 Mbps"
		# send_message info "data rate gui is $data_rate_gui" 
	} else {
		send_message error "Data rate is not supported, set data rate"
		# send_message info "data rate gui is $data_rate_gui" 
	}

# family value in wrapper
	if {$dev_family == "Stratix V"} {
	   set_parameter_value FAMILY "Stratix V"
    } elseif {$dev_family == "Arria V GZ"} {
	   set_parameter_value FAMILY "Arria V GZ"  
    } elseif {$dev_family == "Arria 10"} {
	   set_parameter_value FAMILY "Arria 10"   
	} else {
		send_message error "device is not supported, please select Stratix V, Arria V GZ or Arria 10 "
	}
	
	# if {$dev_family == "Arria 10"} {
        # if {$data_rate == "6250.0 Mbps"} {
	           # set_parameter_property PLL_REFCLK_FREQ ALLOWED_RANGES {"156.25 MHz"  }
	        # } else {
	        	# send_message error "Data rate is not supported, set range of pll ref clk"
	        # }
	# } else {
         # if {$data_rate == "6250.0 Mbps"} {
	           # set_parameter_property PLL_REFCLK_FREQ ALLOWED_RANGES {"156.25 MHz" "195.3125 MHz" "250.0 MHz" "312.5 MHz" "390.625 MHz" "500.0 MHz" "625.0 MHz" }
	        # } else {
	        	# send_message error "Data rate is not supported, set range of pll ref clk"
	        # }
	# }	
	
# terminate value in interface
	if {$dev_family == "Arria 10"} {
	set termin_or_not "false"
	} else {
	set termin_or_not "true"
    }

	set termin_value 0
	
	# if {$interleave_mode == true} {
	    # # send_message info "interleave_mode is $interleave_mode" 
		# set_parameter_value RX_PKTMOD_ONLY 0
		# set_parameter_value TX_PKTMOD_ONLY 0
		# # send_message info "Interleave mode is selected, receiver expect traffic from transmit is interleaved or packet mode with burstmin nx64."
		# # send_message info "Interleave mode is selected, on transmitter side, user is responsible to provide itx_sob/itx_eob for instructing Interlaken core where to insert control word."		
	# } else {
		# # send_message info "interleave_mode is $interleave_mode" 
		# set_parameter_value RX_PKTMOD_ONLY 1
		# set_parameter_value TX_PKTMOD_ONLY 1
		# # send_message info "Packet only mode is selected, receiver expect traffic from transmit is packet based with burstmin/burstshort 32 byte up."
		# # send_message info "Packet only mode is selected, transmitter will ignore itx_sob/itx_eob  and use internal enhance scheduling for insert control word."
	# }	

	
	
	    if {$num_calendar_pgs == 1} {
		set_parameter_value LOG_CALENDAR_PAGES 1
    } elseif {$num_calendar_pgs == 2} {
		set_parameter_value LOG_CALENDAR_PAGES 1
    } elseif {$num_calendar_pgs == 4} {
		set_parameter_value LOG_CALENDAR_PAGES 2		
    } elseif {$num_calendar_pgs == 8} {
		set_parameter_value LOG_CALENDAR_PAGES 3
    } elseif {$num_calendar_pgs == 16} {
		set_parameter_value LOG_CALENDAR_PAGES 4
	} else {
		send_message error "Calendar width is not supported"
	}

	set pll_reference_clock [get_parameter_value PLL_REFCLK_FREQ]
	# send_message info "The transceiver reference clock frequency is set as  $pll_reference_clock"

# # Calculate width and add to/from_xcvr signals
    set bundle_width_to_xcvr [get_parameter_value W_BUNDLE_TO_XCVR]
    set bundle_width_from_xcvr [get_parameter_value W_BUNDLE_FROM_XCVR]

	if {$dev_family == "Arria V"} {
		if {$bond == 1} {
			set num_plls 1 
		} else {
			set num_plls $num_of_lanes 
		}
	} else {
	 set num_plls $num_of_sixpack
	} 

# reconfig_to_xcvr 
add_conduit reconfig_to_xcvr end Input [expr $bundle_width_to_xcvr * ( $num_of_lanes + $num_plls ) ]
# reconfig_from_xcvr
add_conduit reconfig_from_xcvr end output [expr $bundle_width_from_xcvr * ( $num_of_lanes + $num_plls ) ] 
	if {$dev_family == "Arria 10"} {
       set_port_property reconfig_to_xcvr TERMINATION true
       set_port_property reconfig_to_xcvr TERMINATION_VALUE 0 
       set_port_property reconfig_from_xcvr TERMINATION true
       set_port_property reconfig_from_xcvr TERMINATION_VALUE 0
	} 
	
# rx_pin, tx_pin
add_conduit rx_pin end Input $num_of_lanes
add_conduit tx_pin end output $num_of_lanes

# rx_dual_sop_enable
# add_conduit rx_dual_sop_enable end Input 1

# reset output
add_conduit tx_mac_srst end Output 1
add_conduit rx_mac_srst end Output 1
add_conduit tx_usr_srst end Output 1
add_conduit rx_usr_srst end Output 1

# Native PHY specific interface
add_interface np_interface conduit end
add_interface_port np_interface tx_pll_powerdown export output $num_of_sixpack
set_port_property tx_pll_powerdown TERMINATION $termin_or_not

add_interface_port np_interface mm_waitrequest export output 1
set_port_property mm_waitrequest TERMINATION $termin_or_not

add_interface_port np_interface tx_pll_locked export input $num_of_sixpack
set_port_property tx_pll_locked TERMINATION $termin_or_not
set_port_property tx_pll_locked TERMINATION_VALUE $termin_value

add_interface_port np_interface tx_serial_clk export input $num_of_lanes
set_port_property tx_serial_clk TERMINATION $termin_or_not
set_port_property tx_serial_clk TERMINATION_VALUE $termin_value

# add_interface_port np_interface tx_bonding_clocks export input [expr 6 * $num_of_lanes ]
# set_port_property tx_bonding_clocks TERMINATION $termin_or_not
# set_port_property tx_bonding_clocks TERMINATION_VALUE $termin_value
# TX status conduit
add_interface tx_status conduit end
add_interface_port tx_status tx_lanes_aligned export output 1
add_interface_port tx_status itx_hungry export output 1
add_interface_port tx_status itx_overflow export output 1
add_interface_port tx_status itx_underflow export output 1
add_interface_port tx_status itx_ready export output 1
# set_interface_property  tx_status ASSOCIATED_CLOCK tx_usr_clk

# # TX side Data Conduit Interface
add_interface tx_data conduit end
add_interface_port tx_data  itx_chan export input 8
add_interface_port tx_data  itx_num_valid export input 3
add_interface_port tx_data  itx_sop export input 1
add_interface_port tx_data  itx_eopbits export input 4
add_interface_port tx_data  itx_sob export input 1
add_interface_port tx_data  itx_eob export input 1
add_interface_port tx_data  itx_din_words export input  [expr 64 * $internal_word_size ]
add_interface_port tx_data  itx_calendar  export input [expr 16 * $num_calendar_pgs ]
# set_interface_property  tx_data ASSOCIATED_CLOCK tx_usr_clk
   
# Burst Control Settings		 
add_interface burst_control conduit end
add_interface_port burst_control burst_max_in export input 4
add_interface_port burst_control burst_short_in export input 4
add_interface_port burst_control burst_min_in export input 4

# RX side Data Conduit Interface, 
add_interface rx_data conduit end
add_interface_port rx_data irx_chan export output 8
add_interface_port rx_data irx_num_valid export output 3
add_interface_port rx_data irx_sop export output 1
add_interface_port rx_data irx_eopbits export output 4
add_interface_port rx_data irx_sob export output 1
add_interface_port rx_data irx_eob export output 1
add_interface_port rx_data irx_err export output 1
add_interface_port rx_data irx_dout_words export output  [expr 64 * $internal_word_size ]
add_interface_port rx_data irx_calendar export output  [expr 16 * $num_calendar_pgs ]
# set_interface_property rx_data ASSOCIATED_CLOCK rx_usr_clk

# RX side real-time status Conduit Interface 
add_interface rx_status conduit end
add_interface_port rx_status sync_locked export output $num_of_lanes
add_interface_port rx_status word_locked export output $num_of_lanes
add_interface_port rx_status rx_lanes_aligned export output 1
add_interface_port rx_status crc24_err export output 1
add_interface_port rx_status crc32_err export output $num_of_lanes
add_interface_port rx_status irx_overflow export output 1
add_interface_port rx_status rdc_overflow export output 1
add_interface_port rx_status rg_overflow export output 1
add_interface_port rx_status rxfifo_fill_level export output $rx_fifo_addr_width
add_interface_port rx_status sop_cntr_inc export output 1
add_interface_port rx_status eop_cntr_inc export output 1
add_interface_port rx_status nad_cntr_inc export output 1
# set_interface_property rx_status ASSOCIATED_CLOCK rx_usr_clk

# srst_tx_common
add_conduit srst_tx_common end output 1

# srst_rx_common
add_conduit srst_rx_common end output 1

# +-----------------------------------
# | connection point management_interface
# | 

add_interface management_interface avalon slave
set_interface_property management_interface addressUnits word
# set_interface_property management_interface burstCountUnits word
# set_interface_property management_interface constantBurstBehavior false
set_interface_property management_interface burstOnBurstBoundariesOnly false
set_interface_property management_interface holdTime 0
set_interface_property management_interface linewrapBursts false
# supported pending read 1
set_interface_property management_interface maximumPendingReadTransactions 1
# set_interface_property management_interface readLatency 1
set_interface_property management_interface readWaitTime 0
set_interface_property management_interface setupTime 0
set_interface_property management_interface timingUnits Cycles
set_interface_property management_interface writeWaitTime 0


set_interface_property management_interface ASSOCIATED_CLOCK  mm_clk
set_interface_property management_interface ENABLED true

# management_interface is associated with reset
set_interface_property management_interface associatedReset  reset_n

#  mm_clk_locked" signal is set as conduit
add_conduit mm_clk_locked end Input 1

add_interface_port management_interface mm_addr address Input 16
add_interface_port management_interface mm_write write Input 1
add_interface_port management_interface mm_write write Input 1
add_interface_port management_interface mm_read read Input 1
add_interface_port management_interface mm_rdata_valid readdatavalid output 1
add_interface_port management_interface mm_wdata writedata Input 32
add_interface_port management_interface mm_rdata readdata Output 32


}


#+--------------------------------------------
#| clocks interfaces
#|

# # clk_sys 
#     add_interface clk_sys clock end
#     set_interface_property clk_sys ENABLED true
# 	   add_interface_port clk_sys clk_sys clk Input 1

# tx_usr_clk 
    add_interface tx_usr_clk clock end
    set_interface_property tx_usr_clk ENABLED true
    add_interface_port tx_usr_clk tx_usr_clk clk Input 1

# rx_usr_clk 	
    add_interface rx_usr_clk clock end
    set_interface_property rx_usr_clk ENABLED true
    add_interface_port rx_usr_clk rx_usr_clk clk Input 1

# pll_ref_clk
    add_interface pll_ref_clk clock end
    set_interface_property pll_ref_clk ENABLED true
    add_interface_port pll_ref_clk pll_ref_clk clk Input 1

# clk_tx_common
    add_interface clk_tx_common clock start
    set_interface_property clk_tx_common ENABLED true
    add_interface_port clk_tx_common clk_tx_common clk Output 1
	
# 	clk_rx_common
    add_interface clk_rx_common clock start
    set_interface_property clk_rx_common ENABLED true
    add_interface_port clk_rx_common clk_rx_common clk Output 1
	
#  mm_clk
    add_interface mm_clk clock end
    set_interface_property mm_clk ENABLED true
    add_interface_port mm_clk mm_clk clk Input 1

#+--------------------------------------------
#| reset interfaces
#|	

# reset
    add_interface reset_n reset reset
    set_interface_property reset_n ENABLED true
	add_interface_port reset_n reset_n reset Input 1
	set_interface_property reset_n associatedClock clk_tx_common
    set_interface_property reset_n synchronousEdges BOTH

#+--------------------------------------
#| procedure to add conduit interfaces
#|

proc add_conduit {iface_name type dir width} {

    add_interface $iface_name conduit $type
    add_interface_port $iface_name $iface_name export $dir $width
  
}


#+--------------------------------------
#| specify verilog files
#|
	 
proc synth_proc {outputName} {

		set dev_family [get_parameter_value DEVICE_FAMILY]
       if {$dev_family == "Stratix V" || $dev_family == "Arria V GZ" } {
            add_pcs_lib
	   # send_message info "******* add pcs lib in synth  ***************" 
       } else {
       	# send_message info "******* skip add pcs lib in synth ***************" 
       }
	   

# ###################
# ilk_pcs directory

# add if statement for A10 only
       if {$dev_family == "Arria 10" } {
          add_fileset_file "../ilk_pcs/ilk_rx_aligner.sv" SYSTEM_VERILOG PATH "../ilk_pcs/ilk_rx_aligner.sv"  
          add_fileset_file "../ilk_pcs/ilk_tx_aligner.sv" SYSTEM_VERILOG PATH "../ilk_pcs/ilk_tx_aligner.sv"  
          add_fileset_file "../ilk_pcs/pempty_gen_a10.sv" SYSTEM_VERILOG PATH "../ilk_pcs/pempty_gen_a10.sv"  
          add_fileset_file "../ilk_pcs/ilk_hard_pcs_csr_a10.sv" SYSTEM_VERILOG PATH "../ilk_pcs/ilk_hard_pcs_csr_a10.sv"  
          add_fileset_file "../ilk_pcs/ilk_hard_pcs_assembly_a10.sv" SYSTEM_VERILOG PATH "../ilk_pcs/ilk_hard_pcs_assembly_a10.sv"  
          add_fileset_file "../ilk_pcs/alt_xcvr_reset_counter.sv" SYSTEM_VERILOG PATH "../ilk_pcs/alt_xcvr_reset_counter.sv"  
          add_fileset_file "../ilk_pcs/altera_xcvr_reset_control.sv" SYSTEM_VERILOG PATH "../ilk_pcs/altera_xcvr_reset_control.sv" 
          add_fileset_file "../ilk_pcs/tx_fifo_write.sv" SYSTEM_VERILOG PATH "../ilk_pcs/tx_fifo_write.sv"  			  
           # add_fileset_file "../ilk_pcs/alt_xcvr_resync.sv" SYSTEM_VERILOG PATH "../ilk_pcs/alt_xcvr_resync.sv"  
           # add_fileset_file "../ilk_pcs/altera_xcvr_functions.sv" SYSTEM_VERILOG PATH "../ilk_pcs/altera_xcvr_functions.sv"
	   # send_message info "******* add reset files in synth  for a10 ***************" 
       } else {
	      add_fileset_file "../ilk_pcs/ilk_pcs_assembly.sv" SYSTEM_VERILOG PATH  "../ilk_pcs/ilk_pcs_assembly.sv" 
          add_fileset_file "../ilk_pcs/ilk_reconfig_bundle_merger.sv" SYSTEM_VERILOG PATH "../ilk_pcs/ilk_reconfig_bundle_merger.sv" 
          add_fileset_file "../ilk_pcs/ilk_reconfig_bundle_to_xcvr.sv" SYSTEM_VERILOG PATH "../ilk_pcs/ilk_reconfig_bundle_to_xcvr.sv"  
          add_fileset_file "../ilk_pcs/sv_ilk_sixpack.sv" SYSTEM_VERILOG PATH "../ilk_pcs/sv_ilk_sixpack.sv" 
       	# send_message info "******* skip adding reset files in synth ***************" 
       }

# middle level directories, because of encryption sub-directories
# for verilog files
set synth_med_level_dir { "../components" "../ilk_50g_mac" "../ilk_oob/ilk_oob_rx" "../ilk_oob/ilk_oob_tx" "../ilk_50g_regroup"  "../ilk_striper/top" "../ilk_striper/8lane" }

foreach synth_med_dir1 $synth_med_level_dir {
# add all .v files
             set file_med_lst [glob -- -path $synth_med_dir1/*.v]
                     foreach file ${file_med_lst} {
						 set file_string [split $file /]
                         set file_name [lindex $file_string end]                                                 
                     add_fileset_file "$synth_med_dir1/$file_name" VERILOG PATH ${file}
					 
                     }
     }	 
# add OCP file
add_fileset_file "../ilk_50g_mac/ilk_iw4_iw2_tx_datapath.ocp" OTHER PATH "../ilk_50g_mac/ilk_iw4_iw2_tx_datapath.ocp"
add_fileset_file "../ilk_50g_regroup/ilk_iw4_iw2_rx_packet_regroup.ocp" OTHER PATH "../ilk_50g_regroup/ilk_iw4_iw2_rx_packet_regroup.ocp"

# ilk_striper/top SYSTEM_VERILOG
add_fileset_file "../ilk_striper/ilk_50g_striper/ilk_rx_stripe_adapter.sv" SYSTEM_VERILOG_ENCRYPT PATH "../ilk_striper/ilk_50g_striper/ilk_rx_stripe_adapter.sv"
add_fileset_file "../ilk_striper/ilk_50g_striper/ilk_tx_stripe_adapter.sv" SYSTEM_VERILOG_ENCRYPT PATH "../ilk_striper/ilk_50g_striper/ilk_tx_stripe_adapter.sv"


# set synth_med_level_sv_dir { "../ilk_striper/top" }
# #for SystemVerilog files
# foreach synth_med_sv_dir1 $synth_med_level_sv_dir {
# # add the .sv files
#              set file_med_sv_lst [glob -- -path $synth_med_sv_dir1/*.sv]
#                      foreach file ${file_med_sv_lst} {
# 						 set file_string [split $file /]
#                          set file_name [lindex $file_string end]                                                  
#                      add_fileset_file "$synth_med_sv_dir1/$file_name" SYSTEM_VERILOG PATH ${file}
# 					 
#                      }
#      }		 

# add top-level file
add_fileset_file ilk_core_50g.sv SYSTEM_VERILOG PATH ilk_core_50g.sv 	 

# add SDC files
add_fileset_file ilk_50g_top.sdc SDC PATH ilk_50g_top.sdc
	 
send_message PROGRESS "synth_proc done" 

}
	   
proc sim_ver {outputName} {


		set dev_family [get_parameter_value DEVICE_FAMILY]
       	
       if {$dev_family == "Stratix V" || $dev_family == "Arria V GZ" } {
       add_pcs_lib
	   # send_message info "******* add pcs lib in sim ver ***************" 
       } else {
       	# send_message info "******* skip add pcs lib in sim ver ***************" 
       }
	   
# ###################
# ilk_pcs directory

# add if statement for A10 only
       if {$dev_family == "Arria 10" } {
          add_fileset_file "../ilk_pcs/ilk_rx_aligner.sv" SYSTEM_VERILOG PATH "../ilk_pcs/ilk_rx_aligner.sv"  
          add_fileset_file "../ilk_pcs/ilk_tx_aligner.sv" SYSTEM_VERILOG PATH "../ilk_pcs/ilk_tx_aligner.sv"  
          add_fileset_file "../ilk_pcs/pempty_gen_a10.sv" SYSTEM_VERILOG PATH "../ilk_pcs/pempty_gen_a10.sv"  
          add_fileset_file "../ilk_pcs/ilk_hard_pcs_csr_a10.sv" SYSTEM_VERILOG PATH "../ilk_pcs/ilk_hard_pcs_csr_a10.sv"  
          add_fileset_file "../ilk_pcs/ilk_hard_pcs_assembly_a10.sv" SYSTEM_VERILOG PATH "../ilk_pcs/ilk_hard_pcs_assembly_a10.sv"  
          add_fileset_file "../ilk_pcs/alt_xcvr_reset_counter.sv" SYSTEM_VERILOG PATH "../ilk_pcs/alt_xcvr_reset_counter.sv"  
          add_fileset_file "../ilk_pcs/altera_xcvr_reset_control.sv" SYSTEM_VERILOG PATH "../ilk_pcs/altera_xcvr_reset_control.sv"  
          add_fileset_file "../ilk_pcs/tx_fifo_write.sv" SYSTEM_VERILOG PATH "../ilk_pcs/tx_fifo_write.sv"  			  
           # add_fileset_file "../ilk_pcs/alt_xcvr_resync.sv" SYSTEM_VERILOG PATH "../ilk_pcs/alt_xcvr_resync.sv"  
           # add_fileset_file "../ilk_pcs/altera_xcvr_functions.sv" SYSTEM_VERILOG PATH "../ilk_pcs/altera_xcvr_functions.sv"
	   # send_message info "******* add reset files in synth  for a10 ***************" 
       } else {
	      add_fileset_file "../ilk_pcs/ilk_pcs_assembly.sv" SYSTEM_VERILOG PATH  "../ilk_pcs/ilk_pcs_assembly.sv" 
          add_fileset_file "../ilk_pcs/ilk_reconfig_bundle_merger.sv" SYSTEM_VERILOG PATH "../ilk_pcs/ilk_reconfig_bundle_merger.sv" 
          add_fileset_file "../ilk_pcs/ilk_reconfig_bundle_to_xcvr.sv" SYSTEM_VERILOG PATH "../ilk_pcs/ilk_reconfig_bundle_to_xcvr.sv"  
          add_fileset_file "../ilk_pcs/sv_ilk_sixpack.sv" SYSTEM_VERILOG PATH "../ilk_pcs/sv_ilk_sixpack.sv" 
       	# send_message info "******* skip adding reset files in synth ***************" 
       }
	
# ##########################################    Encrypted Eiles    ##########################################    


# #### SYNOPSYS files ####

# ilk_striper/top/synopsys SYSTEM_VERILOG
# add_fileset_file "../synopsys/ilk_striper/ilk_50g_striper/ilk_rx_stripe_adapter.sv" SYSTEM_VERILOG_ENCRYPT PATH "../ilk_striper/ilk_50g_striper/synopsys/ilk_rx_stripe_adapter.sv" SYNOPSYS_SPECIFIC
# add_fileset_file "../synopsys/ilk_striper/ilk_50g_striper/ilk_tx_stripe_adapter.sv" SYSTEM_VERILOG_ENCRYPT PATH "../ilk_striper/ilk_50g_striper/synopsys/ilk_tx_stripe_adapter.sv" SYNOPSYS_SPECIFIC

set sim_synopsys_dir {"../components/synopsys" "../ilk_50g_regroup/synopsys" "../ilk_50g_mac/synopsys" "../ilk_oob/ilk_oob_rx/synopsys" "../ilk_oob/ilk_oob_tx/synopsys" "../ilk_striper/top/synopsys" "../ilk_striper/8lane/synopsys" }

set dest_path_sy                "../synopsys"

foreach sim_sy_dir1 $sim_synopsys_dir {
# add everything, including .sv in ilk_pcs
      # replace ../ with / , so "../ilk_regroup/synopsys" become "/ilk_regroup/synopsys"
      regsub ../ $sim_sy_dir1 / tmp01
      # replace /synopsys with /, so "/ilk_regroup/synopsys" become "/ilk_regroup"	  
      regsub /synopsys $tmp01 / individual_dir
               set file_sim_sy_lst [glob -nocomplain -- -path $sim_sy_dir1/*.v]	  
               # windows doesn't have files for synopsys and cadence, so use -nocomplain here
                     foreach file ${file_sim_sy_lst} {
                         # split a string by / and store it in an array(file_string), so split ../dir1/dir2/rtl.v, file_string has .. dir1 dir2 rlt.v
						 set file_string [split $file /]
						 # take the last element from array file_string, which is rtl.v
                         set file_name [lindex $file_string end]  
                         add_fileset_file "$dest_path_sy$individual_dir$file_name" VERILOG_ENCRYPT PATH ${file} SYNOPSYS_SPECIFIC
                     }
     }	

	 
set sim_synopsys_dir_sv { "../ilk_striper/ilk_50g_striper/synopsys" }

set dest_path_sy_sv                "../synopsys"

foreach sim_sy_dir1 $sim_synopsys_dir_sv {
# add everything, including .sv in ilk_pcs
      # replace ../ with / , so "../ilk_regroup/synopsys" become "/ilk_regroup/synopsys"
      regsub ../ $sim_sy_dir1 / tmp01
      # replace /synopsys with /, so "/ilk_regroup/synopsys" become "/ilk_regroup"	  
      regsub /synopsys $tmp01 / individual_dir
               set file_sim_sy_lst [glob -nocomplain -- -path $sim_sy_dir1/*.sv]	  
               # windows doesn't have files for synopsys and cadence, so use -nocomplain here
                     foreach file ${file_sim_sy_lst} {
                         # split a string by / and store it in an array(file_string), so split ../dir1/dir2/rtl.v, file_string has .. dir1 dir2 rlt.v
						 set file_string [split $file /]
						 # take the last element from array file_string, which is rtl.v
                         set file_name [lindex $file_string end]  
                         add_fileset_file "$dest_path_sy_sv$individual_dir$file_name" SYSTEM_VERILOG_ENCRYPT PATH ${file} SYNOPSYS_SPECIFIC
                     }
     }	
	 
# #### CADENCE files ####
	
# ilk_striper/top/cadence SYSTEM_VERILOG
# add_fileset_file "../cadence/ilk_striper/ilk_50g_striper/ilk_rx_stripe_adapter.sv" SYSTEM_VERILOG_ENCRYPT PATH "../ilk_striper/ilk_50g_striper/cadence/ilk_rx_stripe_adapter.sv" CADENCE_SPECIFIC
# add_fileset_file "../cadence/ilk_striper/ilk_50g_striper/ilk_tx_stripe_adapter.sv" SYSTEM_VERILOG_ENCRYPT PATH "../ilk_striper/ilk_50g_striper/cadence/ilk_tx_stripe_adapter.sv" CADENCE_SPECIFIC

set sim_cadence_dir {"../components/cadence" "../ilk_50g_regroup/cadence" "../ilk_50g_mac/cadence" "../ilk_oob/ilk_oob_rx/cadence" "../ilk_oob/ilk_oob_tx/cadence"  "../ilk_striper/top/cadence" "../ilk_striper/8lane/cadence" }

set dest_path_ca                "../cadence"
	
foreach sim_ca_dir1 $sim_cadence_dir {
# add everything, including .sv in ilk_pcs
      # replace ../ with / , so "../ilk_regroup/synopsys" become "/ilk_regroup/synopsys"
      regsub ../ $sim_ca_dir1 / tmp02
      # replace /synopsys with /, so "/ilk_regroup/synopsys" become "/ilk_regroup"	  
      regsub /cadence $tmp02 / individual_dir
	         # windows doesn't have files for synopsys and cadence, so use -nocomplain here
             set file_sim_ca_lst [glob -nocomplain -- -path $sim_ca_dir1/*.v]
                     foreach file ${file_sim_ca_lst} {
                         # split a string by / and store it in an array(file_string), so split ../dir1/dir2/rtl.v, file_string has .. dir1 dir2 rlt.v
						 set file_string [split $file /]
						 # take the last element from array file_string, which is rtl.v
                         set file_name [lindex $file_string end]  
                         add_fileset_file "$dest_path_ca$individual_dir$file_name" VERILOG_ENCRYPT PATH ${file} CADENCE_SPECIFIC
                     }
     }	

set sim_cadence_dir_sv { "../ilk_striper/ilk_50g_striper/cadence" }

set dest_path_ca_sv                "../cadence"
	
foreach sim_ca_dir1 $sim_cadence_dir_sv {
# add everything, including .sv in ilk_pcs
      # replace ../ with / , so "../ilk_regroup/synopsys" become "/ilk_regroup/synopsys"
      regsub ../ $sim_ca_dir1 / tmp02
      # replace /synopsys with /, so "/ilk_regroup/synopsys" become "/ilk_regroup"	  
      regsub /cadence $tmp02 / individual_dir
	         # windows doesn't have files for synopsys and cadence, so use -nocomplain here
             set file_sim_ca_lst [glob -nocomplain -- -path $sim_ca_dir1/*.sv]
                     foreach file ${file_sim_ca_lst} {
                         # split a string by / and store it in an array(file_string), so split ../dir1/dir2/rtl.v, file_string has .. dir1 dir2 rlt.v
						 set file_string [split $file /]
						 # take the last element from array file_string, which is rtl.v
                         set file_name [lindex $file_string end]  
                         add_fileset_file "$dest_path_ca_sv$individual_dir$file_name" SYSTEM_VERILOG_ENCRYPT PATH ${file} CADENCE_SPECIFIC
                     }
     }	

	 	 
# set sim_bottom_level_dir {"../ilk_regroup/cadence" "../ilk_regroup/mentor" "../ilk_100g_mac/cadence" "../ilk_100g_mac/mentor" 
# "../ilk_striper/top/cadence" "../ilk_striper/top/mentor"  "../ilk_oob/ilk_oob_rx/cadence"  "../ilk_oob/ilk_oob_rx/mentor"  
# "../ilk_oob/ilk_oob_tx/cadence" "../ilk_oob/ilk_oob_tx/mentor" }

# #### MENTOR files ####
	
# ilk_striper/top/mentor SYSTEM_VERILOG
add_fileset_file "../mentor/ilk_striper/ilk_50g_striper/ilk_rx_stripe_adapter.sv" SYSTEM_VERILOG_ENCRYPT PATH "../ilk_striper/ilk_50g_striper/mentor/ilk_rx_stripe_adapter.sv" MENTOR_SPECIFIC
add_fileset_file "../mentor/ilk_striper/ilk_50g_striper/ilk_tx_stripe_adapter.sv" SYSTEM_VERILOG_ENCRYPT PATH "../ilk_striper/ilk_50g_striper/mentor/ilk_tx_stripe_adapter.sv" MENTOR_SPECIFIC

set sim_mentor_dir {"../components/mentor" "../ilk_50g_regroup/mentor" "../ilk_50g_mac/mentor"  "../ilk_oob/ilk_oob_rx/mentor" "../ilk_oob/ilk_oob_tx/mentor"   "../ilk_striper/top/mentor" "../ilk_striper/8lane/mentor" }

set dest_path_me "../mentor"
	
foreach sim_me_dir1 $sim_mentor_dir {
# add everything, including .sv in ilk_pcs
      # replace ../ with / , so "../ilk_regroup/mentor" become "/ilk_regroup/mentor"
      regsub ../ $sim_me_dir1 / tmp03
      # replace /mentor with /, so "/ilk_regroup/mentor" become "/ilk_regroup"	  
      regsub /mentor $tmp03 / individual_dir
	  
             set file_sim_me_lst [glob -- -path $sim_me_dir1/*.v]
                     foreach file ${file_sim_me_lst} {
                         # split a string by / and store it in an array(file_string), so split ../dir1/dir2/rtl.v, file_string has .. dir1 dir2 rlt.v
						 set file_string [split $file /]
						 # take the last element from array file_string, which is rtl.v
                         set file_name [lindex $file_string end]  
                         add_fileset_file "$dest_path_me$individual_dir$file_name" VERILOG_ENCRYPT PATH ${file} MENTOR_SPECIFIC
                     }
     }	

	 
add_fileset_file ilk_core_50g.sv SYSTEM_VERILOG PATH ilk_core_50g.sv 
 



	set num_of_lanes_tb [get_parameter_value NUM_LANES]
	set data_rate_tb [get_parameter_value DATA_RATE]
    # set lane_profile_tb [get_parameter_value LANE_PROFILE]
    set int_tx_clk_div_tb [get_parameter_value INT_TX_CLK_DIV]
	set num_calendar_pgs_tb [get_parameter_value CALENDAR_PAGES]
    set log_num_calendar_pgs_tb [get_parameter_value LOG_CALENDAR_PAGES]
    set tx_packet_mode_tb [get_parameter_value TX_PKTMOD_ONLY]
    set pll_out_freq_tb [get_parameter_value PLL_OUT_FREQ]
   ## set metalen_tb [get_parameter_value METALEN]
	set pll_refclk_tb [get_parameter_value PLL_REFCLK_FREQ]
	# set rx_dual_seg_tb [get_parameter_value RX_DUAL_SEG]

	## the top_tb is changed to txt file extension to bypass make check
	if {$dev_family == "Arria 10" } {
            set template "../testbench/example_design_50g_a10/top_tb.txt"
      } else {
    set template "../testbench/example_design_50g/top_tb.txt"
    }
    set template_fd [open $template "r"]
    set template_contents [read $template_fd]
    
	### Don't put white space between variable_to_values and parenthese, otherwise it won't work
	set variable_to_values(family_select) \"$dev_family\"
    set variable_to_values(tx_packet_mode) $tx_packet_mode_tb
    set variable_to_values(num_lane) $num_of_lanes_tb
    set variable_to_values(data_rate) \"$data_rate_tb\"
    # set variable_to_values(lane_profile) $lane_profile_tb
    set variable_to_values(clk_div) $int_tx_clk_div_tb
    set variable_to_values(pll_out_freq) \"$pll_out_freq_tb\"
    ##set variable_to_values(metalen) $metalen_tb
	set variable_to_values(tx_pakect_only) $tx_packet_mode_tb
	set variable_to_values(pll_ref_clk_freq) \"$pll_refclk_tb\"
	# set variable_to_values(rx_dual_segment) $rx_dual_seg_tb
	set variable_to_values(cal_pages) $num_calendar_pgs_tb	
	set variable_to_values(log_cal_pages) $log_num_calendar_pgs_tb
	
    set contents [altera_terp $template_contents variable_to_values]
	# write out to be a systemverilog file
    add_fileset_file "../testbench/top_tb.sv" SYSTEM_VERILOG TEXT  $contents

  	 if {$dev_family == "Arria 10" } {
         add_fileset_file "../testbench/ilk_pkt_gen.sv" SYSTEM_VERILOG PATH  "../testbench/example_design_50g_a10/ilk_pkt_gen.sv" 
         add_fileset_file "../testbench/ilk_pkt_checker.sv" SYSTEM_VERILOG PATH  "../testbench/example_design_50g_a10/ilk_pkt_checker.sv" 
         add_fileset_file "../testbench/example_design.sv" SYSTEM_VERILOG PATH  "../testbench/example_design_50g_a10/example_design.sv"
         add_fileset_file "../testbench/vlog.do" OTHER PATH  "../testbench/example_design_50g_a10/vlog.do" 
      } else {
    add_fileset_file "../testbench/ilk_pkt_gen.sv" SYSTEM_VERILOG PATH  "../testbench/example_design_50g/ilk_pkt_gen.sv" 
    add_fileset_file "../testbench/ilk_pkt_checker.sv" SYSTEM_VERILOG PATH  "../testbench/example_design_50g/ilk_pkt_checker.sv" 
    add_fileset_file "../testbench/example_design.sv" SYSTEM_VERILOG PATH  "../testbench/example_design_50g/example_design.sv"
    
    add_fileset_file "../testbench/vlog.do" OTHER PATH  "../testbench/example_design_50g/vlog.do" 
    }

    send_message PROGRESS "Finish adding example design" 
   send_message PROGRESS "sim_proc done" 

}

proc add_pcs_lib {} {

send_message PROGRESS "running add_pcs_lib" 

add_fileset_file "./pcs_lib/sv_xcvr_h.sv"  SYSTEM_VERILOG PATH "../../altera_xcvr_generic/sv/sv_xcvr_h.sv"
add_fileset_file "./pcs_lib/alt_xcvr_csr_common_h.sv"  SYSTEM_VERILOG PATH "../../altera_xcvr_generic/ctrl/alt_xcvr_csr_common_h.sv"
add_fileset_file "./pcs_lib/altera_xcvr_functions.sv" SYSTEM_VERILOG PATH "../../altera_xcvr_generic/altera_xcvr_functions.sv"

add_fileset_file "./pcs_lib/sv_hssi_10g_rx_pcs_rbc.sv" SYSTEM_VERILOG PATH "../../altera_xcvr_generic/sv/rbc/sv_hssi_10g_rx_pcs_rbc.sv"
add_fileset_file "./pcs_lib/sv_hssi_10g_tx_pcs_rbc.sv" SYSTEM_VERILOG PATH "../../altera_xcvr_generic/sv/rbc/sv_hssi_10g_tx_pcs_rbc.sv"
add_fileset_file "./pcs_lib/sv_hssi_common_pcs_pma_interface_rbc.sv" SYSTEM_VERILOG PATH "../../altera_xcvr_generic/sv/rbc/sv_hssi_common_pcs_pma_interface_rbc.sv"
add_fileset_file "./pcs_lib/sv_hssi_common_pld_pcs_interface_rbc.sv" SYSTEM_VERILOG PATH "../../altera_xcvr_generic/sv/rbc/sv_hssi_common_pld_pcs_interface_rbc.sv"
add_fileset_file "./pcs_lib/sv_hssi_rx_pcs_pma_interface_rbc.sv" SYSTEM_VERILOG PATH "../../altera_xcvr_generic/sv/rbc/sv_hssi_rx_pcs_pma_interface_rbc.sv"
add_fileset_file "./pcs_lib/sv_hssi_rx_pld_pcs_interface_rbc.sv" SYSTEM_VERILOG PATH "../../altera_xcvr_generic/sv/rbc/sv_hssi_rx_pld_pcs_interface_rbc.sv"
add_fileset_file "./pcs_lib/sv_hssi_tx_pcs_pma_interface_rbc.sv" SYSTEM_VERILOG PATH "../../altera_xcvr_generic/sv/rbc/sv_hssi_tx_pcs_pma_interface_rbc.sv"
add_fileset_file "./pcs_lib/sv_hssi_tx_pld_pcs_interface_rbc.sv" SYSTEM_VERILOG PATH "../../altera_xcvr_generic/sv/rbc/sv_hssi_tx_pld_pcs_interface_rbc.sv"

add_fileset_file "./pcs_lib/sv_pcs_ch.sv"  SYSTEM_VERILOG PATH "../../altera_xcvr_generic/sv/sv_pcs_ch.sv"
add_fileset_file "./pcs_lib/sv_pcs.sv"  SYSTEM_VERILOG PATH "../../altera_xcvr_generic/sv/sv_pcs.sv"
add_fileset_file "./pcs_lib/sv_pma.sv"  SYSTEM_VERILOG PATH "../../altera_xcvr_generic/sv/sv_pma.sv"
add_fileset_file "./pcs_lib/sv_reconfig_bundle_merger.sv"  SYSTEM_VERILOG PATH "../../altera_xcvr_generic/sv/sv_reconfig_bundle_merger.sv"
add_fileset_file "./pcs_lib/sv_reconfig_bundle_to_xcvr.sv"  SYSTEM_VERILOG PATH "../../altera_xcvr_generic/sv/sv_reconfig_bundle_to_xcvr.sv"
add_fileset_file "./pcs_lib/sv_reconfig_bundle_to_ip.sv"  SYSTEM_VERILOG PATH "../../altera_xcvr_generic/sv/sv_reconfig_bundle_to_ip.sv"

add_fileset_file "./pcs_lib/sv_rx_pma.sv"  SYSTEM_VERILOG PATH "../../altera_xcvr_generic/sv/sv_rx_pma.sv"
add_fileset_file "./pcs_lib/sv_tx_pma_ch.sv"  SYSTEM_VERILOG PATH "../../altera_xcvr_generic/sv/sv_tx_pma_ch.sv"
add_fileset_file "./pcs_lib/sv_tx_pma.sv"  SYSTEM_VERILOG PATH "../../altera_xcvr_generic/sv/sv_tx_pma.sv"

add_fileset_file "./pcs_lib/sv_xcvr_avmm_csr.sv"  SYSTEM_VERILOG PATH "../../altera_xcvr_generic/sv/sv_xcvr_avmm_csr.sv"
add_fileset_file "./pcs_lib/sv_xcvr_avmm_dcd.sv"  SYSTEM_VERILOG PATH "../../altera_xcvr_generic/sv/sv_xcvr_avmm_dcd.sv"
add_fileset_file "./pcs_lib/sv_xcvr_avmm.sv"  SYSTEM_VERILOG PATH "../../altera_xcvr_generic/sv/sv_xcvr_avmm.sv"

add_fileset_file "./pcs_lib/alt_xcvr_csr_common.sv"  SYSTEM_VERILOG PATH "../../altera_xcvr_generic/ctrl/alt_xcvr_csr_common.sv"
add_fileset_file "./pcs_lib/alt_xcvr_csr_pcs8g_h.sv"  SYSTEM_VERILOG PATH "../../altera_xcvr_generic/ctrl/alt_xcvr_csr_pcs8g_h.sv"
add_fileset_file "./pcs_lib/alt_xcvr_csr_pcs8g.sv"  SYSTEM_VERILOG PATH "../../altera_xcvr_generic/ctrl/alt_xcvr_csr_pcs8g.sv"
add_fileset_file "./pcs_lib/alt_xcvr_csr_selector.sv"  SYSTEM_VERILOG PATH "../../altera_xcvr_generic/ctrl/alt_xcvr_csr_selector.sv"

add_fileset_file "./pcs_lib/alt_xcvr_mgmt2dec.sv"  SYSTEM_VERILOG PATH "../../altera_xcvr_generic/ctrl/alt_xcvr_mgmt2dec.sv"
add_fileset_file "./pcs_lib/altera_wait_generate.v"  VERILOG PATH "../../altera_xcvr_generic/ctrl/altera_wait_generate.v"
add_fileset_file "./pcs_lib/alt_xcvr_interlaken_amm_slave.v"  VERILOG PATH "../../alt_interlaken/alt_interlaken_pcs_sv/alt_xcvr_interlaken_amm_slave.v"
add_fileset_file "./pcs_lib/alt_xcvr_interlaken_soft_pbip.sv"  SYSTEM_VERILOG PATH "../../alt_interlaken/alt_interlaken_pcs_sv/alt_xcvr_interlaken_soft_pbip.sv"

add_fileset_file "./pcs_lib/sv_xcvr_interlaken_native.sv"  SYSTEM_VERILOG PATH "../../alt_interlaken/alt_interlaken_pcs_sv/sv_xcvr_interlaken_native.sv"
add_fileset_file "./pcs_lib/sv_xcvr_interlaken_nr.sv"  SYSTEM_VERILOG PATH "../../alt_interlaken/alt_interlaken_pcs_sv/sv_xcvr_interlaken_nr.sv"
add_fileset_file "./pcs_lib/altera_xcvr_interlaken.sv"  SYSTEM_VERILOG PATH "../../alt_interlaken/alt_interlaken_pcs/altera_xcvr_interlaken.sv"
add_fileset_file "./pcs_lib/altera_xcvr_reset_control.sv"  SYSTEM_VERILOG PATH "../../alt_xcvr/altera_xcvr_reset_control/altera_xcvr_reset_control.sv"
add_fileset_file "./pcs_lib/alt_xcvr_reset_counter.sv" SYSTEM_VERILOG PATH "../../alt_xcvr/altera_xcvr_reset_control/alt_xcvr_reset_counter.sv"

add_fileset_file "./pcs_lib/alt_xcvr_resync.sv" SYSTEM_VERILOG PATH "../../altera_xcvr_generic/ctrl/alt_xcvr_resync.sv"
add_fileset_file "./pcs_lib/sv_xcvr_native.sv"  SYSTEM_VERILOG PATH "../../altera_xcvr_generic/sv/sv_xcvr_native.sv"
add_fileset_file "./pcs_lib/sv_xcvr_plls.sv"  SYSTEM_VERILOG PATH "../../altera_xcvr_generic/sv/sv_xcvr_plls.sv"

add_fileset_file "./pcs_lib/sv_xcvr_data_adapter.sv"  SYSTEM_VERILOG PATH "../../altera_xcvr_generic/sv/sv_xcvr_data_adapter.sv"

add_fileset_file "./pcs_lib/sv_hssi_8g_pcs_aggregate_rbc.sv" SYSTEM_VERILOG PATH "../../altera_xcvr_generic/sv/rbc/sv_hssi_8g_pcs_aggregate_rbc.sv"
add_fileset_file "./pcs_lib/sv_hssi_8g_rx_pcs_rbc.sv" SYSTEM_VERILOG PATH "../../altera_xcvr_generic/sv/rbc/sv_hssi_8g_rx_pcs_rbc.sv"
add_fileset_file "./pcs_lib/sv_hssi_8g_tx_pcs_rbc.sv" SYSTEM_VERILOG PATH "../../altera_xcvr_generic/sv/rbc/sv_hssi_8g_tx_pcs_rbc.sv"

# add_fileset_file "./pcs_lib/sv_hssi_pipe_gen1_2_rbc.sv" SYSTEM_VERILOG PATH "../../altera_xcvr_generic/sv/rbc/sv_hssi_pipe_gen1_2_rbc.sv"
# add_fileset_file "./pcs_lib/sv_hssi_pipe_gen3_rbc.sv" SYSTEM_VERILOG PATH "../../altera_xcvr_generic/sv/rbc/sv_hssi_pipe_gen3_rbc.sv"

send_message PROGRESS "finish adding pcs_lib" 
}




















