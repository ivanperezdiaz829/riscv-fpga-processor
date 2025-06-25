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
# | request TCL package from ACDS 9.1
# |
package require -exact sopc 11.0
# package require -exact altera_terp 1.0
# global env ;
# |
# +-----------------------------------
# set common_composed_mode 1
# +-----------------------------------
# | module altera_eth_10g_standalone_package
# |
set_module_property NAME altera_eth_10g_design_example
set_module_property AUTHOR "Altera Corporation"
set_module_property VERSION 13.1
set_module_property INTERNAL false
set_module_property GROUP "Interface Protocols/Ethernet/Example Designs"
set_module_property DISPLAY_NAME "Altera Ethernet 10G Design Example"
set_module_property DESCRIPTION "Altera Ethernet 10G Design Example"
set_module_property DATASHEET_URL "http://www.altera.com/literature/ug/10Gbps_MAC.pdf"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false
set_module_property ANALYZE_HDL false
set_module_property VALIDATION_CALLBACK validate
set_module_property COMPOSE_CALLBACK compose
# set_module_property ELABORATION_CALLBACK elaborate

#set_module_property _PREVIEW_GENERATE_VERILOG_SIMULATION_CALLBACK generate
#set_module_property GENERATION_CALLBACK generate

#source altera_eth_10g_system_common.tcl
# +-----------------------------------
# | define parameters
# | Add GUI parameter here


#| Configuration parameter 
add_display_item "" "Configuration" GROUP tab

add_parameter DEVICE_FAMILY_TOP STRING "Stratix IV"
set_parameter_property DEVICE_FAMILY_TOP SYSTEM_INFO {DEVICE_FAMILY}
# set_parameter_property DEVICE_FAMILY VISIBLE false
set_parameter_property DEVICE_FAMILY_TOP ENABLED false
set_parameter_property DEVICE_FAMILY_TOP DISPLAY_NAME "Device Family"
set_parameter_property DEVICE_FAMILY_TOP DESCRIPTION "Target Device Family for Ethernet 10G Design Example"
set_parameter_property DEVICE_FAMILY_TOP IS_HDL_PARAMETER false
add_display_item "Configuration" DEVICE_FAMILY_TOP parameter

add_parameter ENABLE_MAC_LOOPBACK STRING "10Gbps Ethernet MAC with LoopBack Enabled"
set_parameter_property ENABLE_MAC_LOOPBACK DISPLAY_NAME "Default Configuration"
set_parameter_property ENABLE_MAC_LOOPBACK ENABLED false
set_parameter_property ENABLE_MAC_LOOPBACK DESCRIPTION "Enable MAC and Loopback"
add_display_item "Configuration" ENABLE_MAC_LOOPBACK parameter

# add_parameter ENABLE_MDIO_2_WIRE_SERIAL_INT INTEGER 1
# set_parameter_property ENABLE_MDIO_2_WIRE_SERIAL_INT DISPLAY_NAME "Enable mdio or 2-wire serial interface"
# set_parameter_property ENABLE_MDIO_2_WIRE_SERIAL_INT DISPLAY_HINT boolean
# set_parameter_property ENABLE_MDIO_2_WIRE_SERIAL_INT DESCRIPTION "Enable mdio or 2-wire serial interface"
# add_display_item "Configuration" ENABLE_MDIO_2_WIRE_SERIAL_INT parameter

add_parameter CHOOSE_MDIO_2_WIRE_SERIAL_INT INTEGER 1
set_parameter_property CHOOSE_MDIO_2_WIRE_SERIAL_INT DEFAULT_VALUE 0
set_parameter_property CHOOSE_MDIO_2_WIRE_SERIAL_INT DISPLAY_NAME "MDIO"
set_parameter_property CHOOSE_MDIO_2_WIRE_SERIAL_INT DISPLAY_HINT radio
set_parameter_property CHOOSE_MDIO_2_WIRE_SERIAL_INT allowed_ranges {"0:MDIO" "1:None"}
set_parameter_property CHOOSE_MDIO_2_WIRE_SERIAL_INT DESCRIPTION "choose mdio"
add_display_item "Configuration" CHOOSE_MDIO_2_WIRE_SERIAL_INT parameter

add_parameter PHY_IP INTEGER 1
set_parameter_property PHY_IP DEFAULT_VALUE 0
set_parameter_property PHY_IP DISPLAY_NAME "Phy IP"
set_parameter_property PHY_IP DISPLAY_HINT radio
set_parameter_property PHY_IP allowed_ranges {"0:XAUI Phy" "1:10GBase-R Phy" "2:None"}
set_parameter_property PHY_IP DESCRIPTION "Choose Phy IP"
set_parameter_update_callback PHY_IP phy_ip_update_callback
add_display_item "Configuration" PHY_IP parameter

add_parameter CHOOSE_FIFO INTEGER 1
set_parameter_property CHOOSE_FIFO DISPLAY_NAME "FIFO"
set_parameter_property CHOOSE_FIFO DEFAULT_VALUE 0
set_parameter_property CHOOSE_FIFO DISPLAY_HINT radio
set_parameter_property CHOOSE_FIFO allowed_ranges {"0:Avalon-ST Single Clock FIFO" "1:Avalon-ST Dual Clock FIFO" "2:Avalon-ST Single Clock FIFO and Avalon-ST Dual Clock FIFO" "3:None"}
set_parameter_property CHOOSE_FIFO DESCRIPTION "Choose FIFO type"
add_display_item "Configuration" CHOOSE_FIFO parameter

# Finish General parameter |#

#| MAC parameter


add_display_item "" "MAC" GROUP tab
add_display_item "MAC" Parameters GROUP
add_display_item "MAC" "MAC Options" GROUP
add_display_item "MAC" "Resource Optimization Options" GROUP
add_display_item "MAC" "Timestamp Options" GROUP
source $env(QUARTUS_ROOTDIR)/../ip/altera/ethernet/altera_eth_10g_mac/altera_eth_10g_mac_conf.tcl

# MAC Parameter finish declare |#

#| MDIO parameter
add_display_item "" "MDIO" GROUP tab

add_parameter MDIO_MDC_DIVISOR INTEGER 1 
set_parameter_property MDIO_MDC_DIVISOR DEFAULT_VALUE 32
set_parameter_property MDIO_MDC_DIVISOR DISPLAY_NAME "Clock Divisor"
set_parameter_property MDIO_MDC_DIVISOR allowed_ranges {1:320}
set_parameter_property MDIO_MDC_DIVISOR DESCRIPTION "MDIO Clock Divisor"
add_display_item "MDIO" MDIO_MDC_DIVISOR parameter
# MDIO Finish declare|#

#| SC FIFO parameter
add_display_item "" "SC FIFO" GROUP tab
add_display_item "SC FIFO" "TX Single Clock FIFO" GROUP

add_parameter SYNC_TX_FIFO_SYMBOLS_PER_BEAT INTEGER 8 ""
set_parameter_property SYNC_TX_FIFO_SYMBOLS_PER_BEAT DEFAULT_VALUE 8
set_parameter_property SYNC_TX_FIFO_SYMBOLS_PER_BEAT DISPLAY_NAME "Symbols per beat"
add_display_item "TX Single Clock FIFO" "SYNC_TX_FIFO_SYMBOLS_PER_BEAT" parameter

add_parameter SYNC_TX_FIFO_BITS_PER_SYMBOL INTEGER 8 ""
set_parameter_property SYNC_TX_FIFO_BITS_PER_SYMBOL DEFAULT_VALUE 8
set_parameter_property SYNC_TX_FIFO_BITS_PER_SYMBOL DISPLAY_NAME "Bits per symbol"
add_display_item "TX Single Clock FIFO" "SYNC_TX_FIFO_BITS_PER_SYMBOL" parameter

add_parameter SYNC_TX_FIFO_DEPTH INTEGER 1
set_parameter_property SYNC_TX_FIFO_DEPTH DEFAULT_VALUE 512
set_parameter_property SYNC_TX_FIFO_DEPTH DISPLAY_NAME "FIFO depth"
set_parameter_property SYNC_TX_FIFO_DEPTH allowed_ranges {64 128 256 512 1024 2048 4096 8192}
set_parameter_property SYNC_TX_FIFO_DEPTH DESCRIPTION "FIFO depth"
add_display_item "TX Single Clock FIFO" "SYNC_TX_FIFO_DEPTH" parameter

add_parameter SYNC_TX_FIFO_ERROR_WIDTH INTEGER 1 ""
set_parameter_property SYNC_TX_FIFO_ERROR_WIDTH DEFAULT_VALUE 1
set_parameter_property SYNC_TX_FIFO_ERROR_WIDTH DISPLAY_NAME "Error Width"
add_display_item "TX Single Clock FIFO" "SYNC_TX_FIFO_ERROR_WIDTH" parameter

add_parameter SYNC_TX_USE_PACKETS INTEGER 1
set_parameter_property SYNC_TX_USE_PACKETS VISIBLE false
set_parameter_property SYNC_TX_USE_PACKETS DISPLAY_NAME "Use PACKETS"
set_parameter_property SYNC_TX_USE_PACKETS DISPLAY_HINT boolean
set_parameter_property SYNC_TX_USE_PACKETS DESCRIPTION "Use PACKETSS"
add_display_item "TX Single Clock FIFO" "SYNC_TX_USE_PACKETS" parameter

add_parameter SYNC_TX_USE_FILL INTEGER 1
set_parameter_property SYNC_TX_USE_FILL VISIBLE false
set_parameter_property SYNC_TX_USE_FILL DISPLAY_NAME "Use fill level"
set_parameter_property SYNC_TX_USE_FILL DISPLAY_HINT boolean
set_parameter_property SYNC_TX_USE_FILL DESCRIPTION "Use fill level"
add_display_item "TX Single Clock FIFO" "SYNC_TX_USE_FILL" parameter

add_parameter SYNC_TX_USE_STORE_AND_FORWARD INTEGER 1
set_parameter_property SYNC_TX_USE_STORE_AND_FORWARD DISPLAY_NAME "Use store and forward"
set_parameter_property SYNC_TX_USE_STORE_AND_FORWARD DISPLAY_HINT boolean
set_parameter_property SYNC_TX_USE_STORE_AND_FORWARD DESCRIPTION "Use store and forward"
add_display_item "TX Single Clock FIFO" "SYNC_TX_USE_STORE_AND_FORWARD" parameter

add_parameter SYNC_TX_USE_ALMOST_FULL INTEGER 1
set_parameter_property SYNC_TX_USE_ALMOST_FULL DEFAULT_VALUE false
set_parameter_property SYNC_TX_USE_ALMOST_FULL DISPLAY_NAME "Use almost full"
set_parameter_property SYNC_TX_USE_ALMOST_FULL DISPLAY_HINT boolean
set_parameter_property SYNC_TX_USE_ALMOST_FULL DESCRIPTION "Use almost full"
add_display_item "TX Single Clock FIFO" "SYNC_TX_USE_ALMOST_FULL" parameter

add_parameter SYNC_TX_USE_ALMOST_EMPTY INTEGER 1
set_parameter_property SYNC_TX_USE_ALMOST_EMPTY DEFAULT_VALUE false
set_parameter_property SYNC_TX_USE_ALMOST_EMPTY DISPLAY_NAME "Use almost empty"
set_parameter_property SYNC_TX_USE_ALMOST_EMPTY DISPLAY_HINT boolean
set_parameter_property SYNC_TX_USE_ALMOST_EMPTY DESCRIPTION "Use almost empty"
add_display_item "TX Single Clock FIFO" "SYNC_TX_USE_ALMOST_EMPTY" parameter

add_display_item "SC FIFO" "RX Single Clock FIFO" GROUP

add_parameter SYNC_RX_FIFO_SYMBOLS_PER_BEAT INTEGER 8 ""
set_parameter_property SYNC_RX_FIFO_SYMBOLS_PER_BEAT DEFAULT_VALUE 8
set_parameter_property SYNC_RX_FIFO_SYMBOLS_PER_BEAT DISPLAY_NAME "Symbols per beat"
add_display_item "RX Single Clock FIFO" "SYNC_RX_FIFO_SYMBOLS_PER_BEAT" parameter

add_parameter SYNC_RX_FIFO_BITS_PER_SYMBOL INTEGER 8 ""
set_parameter_property SYNC_RX_FIFO_BITS_PER_SYMBOL DEFAULT_VALUE 8
set_parameter_property SYNC_RX_FIFO_BITS_PER_SYMBOL DISPLAY_NAME "Bits per symbol"
add_display_item "RX Single Clock FIFO" "SYNC_RX_FIFO_BITS_PER_SYMBOL" parameter

add_parameter SYNC_RX_FIFO_DEPTH INTEGER 1
set_parameter_property SYNC_RX_FIFO_DEPTH DEFAULT_VALUE 512
set_parameter_property SYNC_RX_FIFO_DEPTH DISPLAY_NAME "FIFO depth"
set_parameter_property SYNC_RX_FIFO_DEPTH allowed_ranges {64 128 256 512 1024 2048 4096 8192}
set_parameter_property SYNC_RX_FIFO_DEPTH DESCRIPTION "FIFO depth"
add_display_item "RX Single Clock FIFO" "SYNC_RX_FIFO_DEPTH" parameter

add_parameter SYNC_RX_FIFO_ERROR_WIDTH INTEGER 6 ""
set_parameter_property SYNC_RX_FIFO_ERROR_WIDTH DEFAULT_VALUE 6
set_parameter_property SYNC_RX_FIFO_ERROR_WIDTH DISPLAY_NAME "Error Width"
add_display_item "RX Single Clock FIFO" "SYNC_RX_FIFO_ERROR_WIDTH" parameter

add_parameter SYNC_RX_USE_PACKETS INTEGER 1
set_parameter_property SYNC_RX_USE_PACKETS VISIBLE false
set_parameter_property SYNC_RX_USE_PACKETS DISPLAY_NAME "Use PACKETS"
set_parameter_property SYNC_RX_USE_PACKETS DISPLAY_HINT boolean
set_parameter_property SYNC_RX_USE_PACKETS DESCRIPTION "Use PACKETSS"
add_display_item "RX Single Clock FIFO" "SYNC_RX_USE_PACKETS" parameter

add_parameter SYNC_RX_USE_FILL INTEGER 1
set_parameter_property SYNC_RX_USE_FILL VISIBLE false
set_parameter_property SYNC_RX_USE_FILL DISPLAY_NAME "Use fill level"
set_parameter_property SYNC_RX_USE_FILL DISPLAY_HINT boolean
set_parameter_property SYNC_RX_USE_FILL DESCRIPTION "Use fill level"
add_display_item "RX Single Clock FIFO" "SYNC_RX_USE_FILL" parameter

add_parameter SYNC_RX_USE_STORE_AND_FORWARD INTEGER 1
set_parameter_property SYNC_RX_USE_STORE_AND_FORWARD DISPLAY_NAME "Use store and forward"
set_parameter_property SYNC_RX_USE_STORE_AND_FORWARD DISPLAY_HINT boolean
set_parameter_property SYNC_RX_USE_STORE_AND_FORWARD DESCRIPTION "Use store and forward"
add_display_item "RX Single Clock FIFO" "SYNC_RX_USE_STORE_AND_FORWARD" parameter

add_parameter SYNC_RX_USE_ALMOST_FULL INTEGER 1
set_parameter_property SYNC_RX_USE_ALMOST_FULL DISPLAY_NAME "Use almost full"
set_parameter_property SYNC_RX_USE_ALMOST_FULL DISPLAY_HINT boolean
set_parameter_property SYNC_RX_USE_ALMOST_FULL DESCRIPTION "Use almost full"
add_display_item "RX Single Clock FIFO" "SYNC_RX_USE_ALMOST_FULL" parameter

add_parameter SYNC_RX_USE_ALMOST_EMPTY INTEGER 1
set_parameter_property SYNC_RX_USE_ALMOST_EMPTY DISPLAY_NAME "Use almost empty"
set_parameter_property SYNC_RX_USE_ALMOST_EMPTY DISPLAY_HINT boolean
set_parameter_property SYNC_RX_USE_ALMOST_EMPTY DESCRIPTION "Use almost empty"
add_display_item "RX Single Clock FIFO" "SYNC_RX_USE_ALMOST_EMPTY" parameter

# SC FIFO Parameter finish declare |#


#| DC FIFO parameter
add_display_item "" "DC FIFO" GROUP tab
add_display_item "DC FIFO" "TX Dual Clock FIFO" GROUP

add_parameter ASYNC_TX_FIFO_SYMBOLS_PER_BEAT INTEGER 8 ""
set_parameter_property ASYNC_TX_FIFO_SYMBOLS_PER_BEAT DEFAULT_VALUE 8
set_parameter_property ASYNC_TX_FIFO_SYMBOLS_PER_BEAT DISPLAY_NAME "Symbols per beat"
add_display_item "TX Dual Clock FIFO" "ASYNC_TX_FIFO_SYMBOLS_PER_BEAT" parameter

add_parameter ASYNC_TX_FIFO_BITS_PER_SYMBOL INTEGER 8 ""
set_parameter_property ASYNC_TX_FIFO_BITS_PER_SYMBOL DEFAULT_VALUE 8
set_parameter_property ASYNC_TX_FIFO_BITS_PER_SYMBOL DISPLAY_NAME "Bits per symbol"
add_display_item "TX Dual Clock FIFO" "ASYNC_TX_FIFO_BITS_PER_SYMBOL" parameter

add_parameter ASYNC_TX_FIFO_DEPTH INTEGER 1
set_parameter_property ASYNC_TX_FIFO_DEPTH DEFAULT_VALUE 16
set_parameter_property ASYNC_TX_FIFO_DEPTH DISPLAY_NAME "FIFO depth"
set_parameter_property ASYNC_TX_FIFO_DEPTH allowed_ranges { 16 32 64 128 256 512 1024 2048 4096 8192}
set_parameter_property ASYNC_TX_FIFO_DEPTH DESCRIPTION "FIFO depth"
add_display_item "TX Dual Clock FIFO" "ASYNC_TX_FIFO_DEPTH" parameter

add_parameter ASYNC_TX_FIFO_ERROR_WIDTH INTEGER 1 ""
set_parameter_property ASYNC_TX_FIFO_ERROR_WIDTH DEFAULT_VALUE 1
set_parameter_property ASYNC_TX_FIFO_ERROR_WIDTH DISPLAY_NAME "Error Width"
add_display_item "TX Dual Clock FIFO" "ASYNC_TX_FIFO_ERROR_WIDTH" parameter

add_parameter ASYNC_TX_USE_PKT INTEGER 1
set_parameter_property ASYNC_TX_USE_PKT DEFAULT_VALUE 1
set_parameter_property ASYNC_TX_USE_PKT VISIBLE false
set_parameter_property ASYNC_TX_USE_PKT DISPLAY_NAME "Use packets"
set_parameter_property ASYNC_TX_USE_PKT DISPLAY_HINT boolean
set_parameter_property ASYNC_TX_USE_PKT DESCRIPTION "Use packets"
add_display_item "TX Dual Clock FIFO" "ASYNC_TX_USE_PKT" parameter

add_parameter ASYNC_TX_USE_SINK_FILL INTEGER 1
set_parameter_property ASYNC_TX_USE_SINK_FILL DEFAULT_VALUE 0
set_parameter_property ASYNC_TX_USE_SINK_FILL VISIBLE false
set_parameter_property ASYNC_TX_USE_SINK_FILL DISPLAY_NAME "Use sink fill level"
set_parameter_property ASYNC_TX_USE_SINK_FILL DISPLAY_HINT boolean
set_parameter_property ASYNC_TX_USE_SINK_FILL DESCRIPTION "Use sink fill level"
add_display_item "TX Dual Clock FIFO" "ASYNC_TX_USE_SINK_FILL" parameter

add_parameter ASYNC_TX_USE_SRC_FILL INTEGER 1
set_parameter_property ASYNC_TX_USE_SRC_FILL DEFAULT_VALUE 0
set_parameter_property ASYNC_TX_USE_SRC_FILL VISIBLE false
set_parameter_property ASYNC_TX_USE_SRC_FILL DISPLAY_NAME "Use source fill level"
set_parameter_property ASYNC_TX_USE_SRC_FILL DISPLAY_HINT boolean
set_parameter_property ASYNC_TX_USE_SRC_FILL DESCRIPTION "Use source fill level"
add_display_item "TX Dual Clock FIFO" "ASYNC_TX_USE_SRC_FILL" parameter


add_display_item "DC FIFO" "RX Dual Clock FIFO" GROUP

add_parameter ASYNC_RX_FIFO_SYMBOLS_PER_BEAT INTEGER 8 ""
set_parameter_property ASYNC_RX_FIFO_SYMBOLS_PER_BEAT DEFAULT_VALUE 8
set_parameter_property ASYNC_RX_FIFO_SYMBOLS_PER_BEAT DISPLAY_NAME "Symbols per beat"
add_display_item "RX Dual Clock FIFO" "ASYNC_RX_FIFO_SYMBOLS_PER_BEAT" parameter

add_parameter ASYNC_RX_FIFO_BITS_PER_SYMBOL INTEGER 8 ""
set_parameter_property ASYNC_RX_FIFO_BITS_PER_SYMBOL DEFAULT_VALUE 8
set_parameter_property ASYNC_RX_FIFO_BITS_PER_SYMBOL DISPLAY_NAME "Bits per symbol"
add_display_item "RX Dual Clock FIFO" "ASYNC_RX_FIFO_BITS_PER_SYMBOL" parameter

add_parameter ASYNC_RX_FIFO_DEPTH INTEGER 1
set_parameter_property ASYNC_RX_FIFO_DEPTH DEFAULT_VALUE 16
set_parameter_property ASYNC_RX_FIFO_DEPTH DISPLAY_NAME "FIFO depth"
set_parameter_property ASYNC_RX_FIFO_DEPTH allowed_ranges { 16 32 64 128 256 512 1024 2048 4096 8192}
set_parameter_property ASYNC_RX_FIFO_DEPTH DESCRIPTION "FIFO depth"
add_display_item "RX Dual Clock FIFO" "ASYNC_RX_FIFO_DEPTH" parameter

add_parameter ASYNC_RX_FIFO_ERROR_WIDTH INTEGER 6 ""
set_parameter_property ASYNC_RX_FIFO_ERROR_WIDTH DEFAULT_VALUE 6
set_parameter_property ASYNC_RX_FIFO_ERROR_WIDTH DISPLAY_NAME "Error Width"
add_display_item "RX Dual Clock FIFO" "ASYNC_RX_FIFO_ERROR_WIDTH" parameter

add_parameter ASYNC_RX_USE_PKT INTEGER 1
set_parameter_property ASYNC_RX_USE_PKT DEFAULT_VALUE 1
set_parameter_property ASYNC_RX_USE_PKT VISIBLE false
set_parameter_property ASYNC_RX_USE_PKT DISPLAY_NAME "Use packets"
set_parameter_property ASYNC_RX_USE_PKT DISPLAY_HINT boolean
set_parameter_property ASYNC_RX_USE_PKT DESCRIPTION "Use packets"
add_display_item "RX Dual Clock FIFO" "ASYNC_RX_USE_PKT" parameter

add_parameter ASYNC_RX_USE_SINK_FILL INTEGER 1
set_parameter_property ASYNC_RX_USE_SINK_FILL DEFAULT_VALUE 0
set_parameter_property ASYNC_RX_USE_SINK_FILL VISIBLE false
set_parameter_property ASYNC_RX_USE_SINK_FILL DISPLAY_NAME "Use sink fill level"
set_parameter_property ASYNC_RX_USE_SINK_FILL DISPLAY_HINT boolean
set_parameter_property ASYNC_RX_USE_SINK_FILL DESCRIPTION "Use sink fill level"
add_display_item "RX Dual Clock FIFO" "ASYNC_RX_USE_SINK_FILL" parameter

add_parameter ASYNC_RX_USE_SRC_FILL INTEGER 1
set_parameter_property ASYNC_RX_USE_SRC_FILL DEFAULT_VALUE 0
set_parameter_property ASYNC_RX_USE_SRC_FILL VISIBLE false
set_parameter_property ASYNC_RX_USE_SRC_FILL DISPLAY_NAME "Use source fill level"
set_parameter_property ASYNC_RX_USE_SRC_FILL DISPLAY_HINT boolean
set_parameter_property ASYNC_RX_USE_SRC_FILL DESCRIPTION "Use source fill level"
add_display_item "RX Dual Clock FIFO" "ASYNC_RX_USE_SRC_FILL" parameter

# DC FIFO Parameter finish declare |#

#| 2-Wire Serial Interface parameter
#add_display_item "" "2-WIRE SERIAL INTERFACE" GROUP tab


# 2-Wire Serial Interface Finish declare|#

#| Base R Parameter
add_display_item "" "10GBase-R" GROUP tab

add_display_item "10GBase-R" "10GBase-R General Options" GROUP
add_parameter BASER_INTERFACE INTEGER 1
set_parameter_property BASER_INTERFACE DEFAULT_VALUE 0
set_parameter_property BASER_INTERFACE DISPLAY_NAME "10GBase-R interface type"
set_parameter_property BASER_INTERFACE allowed_ranges {"0:Soft 10GBase-R" "1:Hard 10GBase-R"}
set_parameter_property BASER_INTERFACE DESCRIPTION "10GBase-R interface type"
add_display_item "10GBase-R General Options" "BASER_INTERFACE" parameter

add_parameter BASER_PLL_TYPE STRING "CMU"
set_parameter_property BASER_PLL_TYPE DEFAULT_VALUE "CMU"
set_parameter_property BASER_PLL_TYPE DISPLAY_NAME "PLL type"
set_parameter_property BASER_PLL_TYPE allowed_ranges {"CMU" "ATX"}
set_parameter_property BASER_PLL_TYPE DESCRIPTION "Specific the PLL type"
add_display_item "10GBase-R General Options" "BASER_PLL_TYPE" parameter

add_parameter BASER_STARTING_CHANNEL_NUMBER integer 1
set_parameter_property BASER_STARTING_CHANNEL_NUMBER DEFAULT_VALUE "0"
set_parameter_property BASER_STARTING_CHANNEL_NUMBER DISPLAY_NAME "Starting channel number"
set_parameter_property BASER_STARTING_CHANNEL_NUMBER allowed_ranges {0,4,8,12,16,20,24,28,32,36,40,44,48,52,56,60,64,68,72,76,80,84,88,92,96}
set_parameter_property BASER_STARTING_CHANNEL_NUMBER DESCRIPTION "Physical starting channel number"
add_display_item "10GBase-R General Options" "BASER_STARTING_CHANNEL_NUMBER" parameter

add_parameter BASER_REF_CLK_FREQ STRING "644.53125 MHz"
set_parameter_property BASER_REF_CLK_FREQ DEFAULT_VALUE "644.53125 MHz"
set_parameter_property BASER_REF_CLK_FREQ DISPLAY_NAME "Reference clock frequency"
set_parameter_property BASER_REF_CLK_FREQ allowed_ranges {"322.265625 MHz" "644.53125 MHz"}
set_parameter_property BASER_REF_CLK_FREQ DESCRIPTION "Stratix V supports both frequencies. Stratix IV GT supports 644.53125"
add_display_item "10GBase-R General Options" "BASER_REF_CLK_FREQ" parameter

add_display_item "10GBase-R" "10GBase-R Analog Options" GROUP
add_display_item "10GBase-R Analog Options" siv_message_text TEXT "These options are only available for family Stratix IV."


add_parameter BASER_TRANSMITTER_TERMINATION STRING OCT_100_OHMS
set_parameter_property BASER_TRANSMITTER_TERMINATION DEFAULT_VALUE OCT_100_OHMS
set_parameter_property BASER_TRANSMITTER_TERMINATION DISPLAY_NAME "Transmitter termination resistance"
set_parameter_property BASER_TRANSMITTER_TERMINATION allowed_ranges {OCT_85_OHMS OCT_100_OHMS OCT_120_OHMS OCT_150_OHMS}
set_parameter_property BASER_TRANSMITTER_TERMINATION DESCRIPTION "Transmitter termination resistance"
add_display_item "10GBase-R Analog Options" "BASER_TRANSMITTER_TERMINATION" parameter

add_parameter BASER_PRE_EMPHASIS_PRE_TAP INTEGER 1
set_parameter_property BASER_PRE_EMPHASIS_PRE_TAP DEFAULT_VALUE 0
set_parameter_property BASER_PRE_EMPHASIS_PRE_TAP DISPLAY_NAME "Pre-emphasis pre-tap setting"
set_parameter_property BASER_PRE_EMPHASIS_PRE_TAP allowed_ranges {0:7}
set_parameter_property BASER_PRE_EMPHASIS_PRE_TAP DESCRIPTION "Pre-emphasis pre-tap setting"
add_display_item "10GBase-R Analog Options" "BASER_PRE_EMPHASIS_PRE_TAP" parameter

add_parameter BASER_PRE_EMPHASIS_PRE_TAP_POLARITY INTEGER 1
set_parameter_property BASER_PRE_EMPHASIS_PRE_TAP_POLARITY DEFAULT_VALUE "false"
set_parameter_property BASER_PRE_EMPHASIS_PRE_TAP_POLARITY DISPLAY_NAME "Pre-emphasis pre-tap polarity setting"
set_parameter_property BASER_PRE_EMPHASIS_PRE_TAP_POLARITY DISPLAY_HINT boolean
set_parameter_property BASER_PRE_EMPHASIS_PRE_TAP_POLARITY DESCRIPTION "Pre-emphasis pre-tap polarity setting"
add_display_item "10GBase-R Analog Options" "BASER_PRE_EMPHASIS_PRE_TAP_POLARITY" parameter

add_parameter BASER_PRE_EMPHASIS_FIRST_POST_TAP INTEGER 1
set_parameter_property BASER_PRE_EMPHASIS_FIRST_POST_TAP DEFAULT_VALUE 5
set_parameter_property BASER_PRE_EMPHASIS_FIRST_POST_TAP DISPLAY_NAME "Pre-emphasis first post-tap setting"
set_parameter_property BASER_PRE_EMPHASIS_FIRST_POST_TAP allowed_ranges {0:15}
set_parameter_property BASER_PRE_EMPHASIS_FIRST_POST_TAP DESCRIPTION "Pre-emphasis first post-tap setting"
add_display_item "10GBase-R Analog Options" "BASER_PRE_EMPHASIS_FIRST_POST_TAP" parameter

add_parameter BASER_PRE_EMPHASIS_SECOND_POST_TAP INTEGER 1
set_parameter_property BASER_PRE_EMPHASIS_SECOND_POST_TAP DEFAULT_VALUE 0
set_parameter_property BASER_PRE_EMPHASIS_SECOND_POST_TAP DISPLAY_NAME "Pre-emphasis second post-tap setting"
set_parameter_property BASER_PRE_EMPHASIS_SECOND_POST_TAP allowed_ranges {0:7}
set_parameter_property BASER_PRE_EMPHASIS_SECOND_POST_TAP DESCRIPTION "Pre-emphasis second post-tap setting"
add_display_item "10GBase-R Analog Options" "BASER_PRE_EMPHASIS_SECOND_POST_TAP" parameter

add_parameter BASER_PRE_EMPHASIS_SECOND_POST_TAP_POLARITY INTEGER 1
set_parameter_property BASER_PRE_EMPHASIS_SECOND_POST_TAP_POLARITY DEFAULT_VALUE "false"
set_parameter_property BASER_PRE_EMPHASIS_SECOND_POST_TAP_POLARITY DISPLAY_NAME "Pre-emphasis second post-tap polarity setting"
set_parameter_property BASER_PRE_EMPHASIS_SECOND_POST_TAP_POLARITY DISPLAY_HINT boolean
set_parameter_property BASER_PRE_EMPHASIS_SECOND_POST_TAP_POLARITY DESCRIPTION "Pre-emphasis second post-tap polarity setting"
add_display_item "10GBase-R Analog Options" "BASER_PRE_EMPHASIS_SECOND_POST_TAP_POLARITY" parameter

add_parameter BASER_TRANSMITTER_VOD INTEGER 1
set_parameter_property BASER_TRANSMITTER_VOD DEFAULT_VALUE 1
set_parameter_property BASER_TRANSMITTER_VOD DISPLAY_NAME "Transmitter VOD control setting"
set_parameter_property BASER_TRANSMITTER_VOD allowed_ranges {0:7}
set_parameter_property BASER_TRANSMITTER_VOD DESCRIPTION "Transmitter VOD control setting"
add_display_item "10GBase-R Analog Options" "BASER_TRANSMITTER_VOD" parameter

add_parameter BASER_RECEIVER_TERMINATION STRING OCT_100_OHMS
set_parameter_property BASER_RECEIVER_TERMINATION DEFAULT_VALUE OCT_100_OHMS
set_parameter_property BASER_RECEIVER_TERMINATION DISPLAY_NAME "Receiver termination resistance"
set_parameter_property BASER_RECEIVER_TERMINATION allowed_ranges {OCT_85_OHMS OCT_100_OHMS OCT_120_OHMS OCT_150_OHMS}
set_parameter_property BASER_RECEIVER_TERMINATION DESCRIPTION "Receiver termination resistance"
add_display_item "10GBase-R Analog Options" "BASER_RECEIVER_TERMINATION" parameter

add_parameter BASER_RECEIVER_DC_GAIN INTEGER 1
set_parameter_property BASER_RECEIVER_DC_GAIN DEFAULT_VALUE 0
set_parameter_property BASER_RECEIVER_DC_GAIN DISPLAY_NAME "Receiver DC gain"
set_parameter_property BASER_RECEIVER_DC_GAIN allowed_ranges {0:4}
set_parameter_property BASER_RECEIVER_DC_GAIN DESCRIPTION "Receiver DC gain"
add_display_item "10GBase-R Analog Options" "BASER_RECEIVER_DC_GAIN" parameter

add_parameter BASER_RECEIVER_STATIC_EQUALIZER INTEGER 1
set_parameter_property BASER_RECEIVER_STATIC_EQUALIZER DEFAULT_VALUE 14
set_parameter_property BASER_RECEIVER_STATIC_EQUALIZER DISPLAY_NAME "Receiver statis equalizer setting"
set_parameter_property BASER_RECEIVER_STATIC_EQUALIZER allowed_ranges {0:16}
set_parameter_property BASER_RECEIVER_STATIC_EQUALIZER DESCRIPTION "Receiver statis equalizer setting"
add_display_item "10GBase-R Analog Options" "BASER_RECEIVER_STATIC_EQUALIZER" parameter

add_display_item "10GBase-R" "10GBase-R Advanced Options" GROUP

add_parameter BASER_EXT_PMA_CONTROL_CONF INTEGER 1
set_parameter_property BASER_EXT_PMA_CONTROL_CONF DEFAULT_VALUE 0
set_parameter_property BASER_EXT_PMA_CONTROL_CONF DISPLAY_NAME "Use external PMA control and reconfig"
set_parameter_property BASER_EXT_PMA_CONTROL_CONF DISPLAY_HINT boolean
set_parameter_property BASER_EXT_PMA_CONTROL_CONF DESCRIPTION "Use external PMA control and reconfig"
add_display_item "10GBase-R Advanced Options" "BASER_EXT_PMA_CONTROL_CONF" parameter

add_parameter BASER_ENA_ADD_CONTROL_STAT INTEGER 1
set_parameter_property BASER_ENA_ADD_CONTROL_STAT DEFAULT_VALUE 0
set_parameter_property BASER_ENA_ADD_CONTROL_STAT DISPLAY_NAME "Enable additional control and status pins"
set_parameter_property BASER_ENA_ADD_CONTROL_STAT DISPLAY_HINT boolean
set_parameter_property BASER_ENA_ADD_CONTROL_STAT DESCRIPTION "Enable additional control and status pins"
add_display_item "10GBase-R Advanced Options" "BASER_ENA_ADD_CONTROL_STAT" parameter

add_parameter BASER_RECOVERED_CLK_OUT INTEGER 1
set_parameter_property BASER_RECOVERED_CLK_OUT DEFAULT_VALUE 0
set_parameter_property BASER_RECOVERED_CLK_OUT DISPLAY_NAME "Enable rx_recovered_clk pin"
set_parameter_property BASER_RECOVERED_CLK_OUT DISPLAY_HINT boolean
set_parameter_property BASER_RECOVERED_CLK_OUT DESCRIPTION "Enable rx_recovered_clk pin"
add_display_item "10GBase-R Advanced Options" "BASER_RECOVERED_CLK_OUT" parameter



# |#
#| Xaui Parameter
add_display_item "" "XAUI" GROUP tab
add_display_item "XAUI" "General Options" GROUP

add_parameter XAUI_STARTING_CHANNEL_NUMBER INTEGER 1
set_parameter_property XAUI_STARTING_CHANNEL_NUMBER DEFAULT_VALUE 0
set_parameter_property XAUI_STARTING_CHANNEL_NUMBER DISPLAY_NAME "Starting channel number"
set_parameter_property XAUI_STARTING_CHANNEL_NUMBER allowed_ranges {0,4,8,12,16,20,24,28,32,36,40,44,48,52,56,60,64,68,72,76,80,84,88,92,96}
set_parameter_property XAUI_STARTING_CHANNEL_NUMBER DESCRIPTION "Possible values are from 0 to 127"
add_display_item "General Options" "XAUI_STARTING_CHANNEL_NUMBER" parameter


lappend auto_path $env(QUARTUS_ROOTDIR)/../ip/altera/alt_xcvr/alt_xcvr_tcl_packages
lappend auto_path $env(QUARTUS_ROOTDIR)/../ip/altera/alt_xcvr/altera_xcvr_reset_control
package require alt_xcvr::utils::rbc
package require altera_xcvr_reset_control::fileset

add_display_item "XAUI" "Analog Options" GROUP
add_display_item "Analog Options" sv_message_text TEXT "These options are only available for families Stratix IV, Arria II and Cyclone IV."
add_display_item "XAUI" "Advanced Options" GROUP
source $env(QUARTUS_ROOTDIR)/../ip/altera/alt_interlaken/alt_interlaken_pcs/parameter_manager.tcl
source $env(QUARTUS_ROOTDIR)/../ip/altera/alt_xaui/lib/alt_xaui_common.tcl
source $env(QUARTUS_ROOTDIR)/../ip/altera/alt_xaui/lib/ipcc_tcl_helper.tcl
common_add_parameters_for_native_phy



# XAUI parameter finish declare |#



# set_parameter_property device_family VISIBLE false

# |
# +-----------------------------------


sopc::preview_add_transform "foo" "PREVIEW_AVALON_MM_TRANSFORM"

proc phy_ip_update_callback {arg1} {
    set phy_ip [get_parameter_value $arg1]

    # 1588 not supported for XAUI PHY
    if {$phy_ip == 0} {
        set_parameter_value ENABLE_TIMESTAMPING 0
        update_1step ENABLE_TIMESTAMPING
    }
    
    # 1G/10G MAC not supported for XAUI PHY and 10GBASE-R PHY
    if {$phy_ip == 0 || $phy_ip == 1} {
        set_parameter_value ENABLE_1G10G_MAC 0
    }
}

proc validate {} {
    # validate for MAC
    
    set stat_ena [get_parameter_value INSTANTIATE_STATISTICS]
	set device_family [get_parameter_value DEVICE_FAMILY_TOP]
    set interface_type [get_parameter_value interface_type]
    set external_pma_ctrl_config [get_parameter_value BASER_EXT_PMA_CONTROL_CONF]
    set preamble_passthrough [get_parameter_value PREAMBLE_PASSTHROUGH]
    set DATAPATH_OPTION [get_parameter_value DATAPATH_OPTION]
    
    set xaui_pll_type [get_parameter_value xaui_pll_type]
    set external_pma_ctrl_reconf [get_parameter_value external_pma_ctrl_reconf]
    set tx_termination [get_parameter_value tx_termination]
    set tx_vod_selection [get_parameter_value tx_vod_selection]
    set tx_preemp_pretap [get_parameter_value tx_preemp_pretap]
    set tx_preemp_pretap_inv [get_parameter_value tx_preemp_pretap_inv]
    set tx_preemp_tap_1 [get_parameter_value tx_preemp_tap_1]
    set tx_preemp_tap_2 [get_parameter_value tx_preemp_tap_2]
    set tx_preemp_tap_2_inv [get_parameter_value tx_preemp_tap_2_inv]
    set rx_common_mode [get_parameter_value rx_common_mode]
    set rx_termination [get_parameter_value rx_termination]
    set rx_eq_dc_gain [get_parameter_value rx_eq_dc_gain]
    set rx_eq_ctrl [get_parameter_value rx_eq_ctrl]
    set number_of_interfaces [get_parameter_value number_of_interfaces] 
    set phy_ip [get_parameter_value PHY_IP] 

    
    # MAC
    ethernet_10g_mac_update_gui
    if {$phy_ip == 0} {
        set_parameter_property ENABLE_TIMESTAMPING ENABLED false
    } else {
        set_parameter_property ENABLE_TIMESTAMPING ENABLED true
    }
    
    # 1G/10G MAC not supported for XAUI PHY and 10GBASE-R PHY
    if {$phy_ip == 0 || $phy_ip == 1} {
        set_parameter_property ENABLE_1G10G_MAC ENABLED false
    } else {
        set_parameter_property ENABLE_1G10G_MAC ENABLED true
    }
    
    # fix seperate tx and rx mode
    
    set_parameter_property DATAPATH_OPTION ENABLED false

    
    # Xaui 
    # same effect applicable for all device family
    set_parameter_property xaui_pll_type VISIBLE false 
    set_parameter_property number_of_interfaces VISIBLE false
    set_parameter_property data_rate VISIBLE false
    set_parameter_property starting_channel_number VISIBLE false
    
    # Xaui device dependent parameter
    if {$device_family == "Stratix V" || $device_family == "Cyclone IV GX"} {
    set_parameter_property external_pma_ctrl_reconf VISIBLE false 
    } else {
    set_parameter_property external_pma_ctrl_reconf VISIBLE true 
    }
    
    
    if {$device_family == "Stratix V"} {
    set_parameter_property XAUI_STARTING_CHANNEL_NUMBER VISIBLE false 
    } else {
    set_parameter_property XAUI_STARTING_CHANNEL_NUMBER VISIBLE true 
    }
    
    if {$interface_type == "Soft XAUI"} {
    set_parameter_property gui_pll_type ENABLED true
    } else {
    set_parameter_property gui_pll_type ENABLED false
    }
    
    # hide analog setting
    # if {$device_family == "Stratix V" || $device_family == "HardCopy IV"} {
    # set_parameter_property tx_termination VISIBLE false
    # set_parameter_property tx_vod_selection VISIBLE false
    # set_parameter_property tx_preemp_pretap VISIBLE false
    # set_parameter_property tx_preemp_pretap_inv VISIBLE false
    # set_parameter_property tx_preemp_tap_1 VISIBLE false
    # set_parameter_property tx_preemp_tap_2 VISIBLE false
    # set_parameter_property tx_preemp_tap_2_inv VISIBLE false
    # set_parameter_property rx_common_mode VISIBLE false
    # set_parameter_property rx_termination VISIBLE false
    # set_parameter_property rx_eq_dc_gain VISIBLE false
    # set_parameter_property rx_eq_ctrl VISIBLE false
    
    # }

    # hide Note
    set_parameter_property soft_xaui_cfg VISIBLE false
    set_parameter_property hard_xaui_cfg VISIBLE false
    
    
    # Xaui interface type restriction
    if {$device_family == "Cyclone IV GX" || $device_family == "Arria II GX" || $device_family == "Arria II GZ"} {
    set_parameter_property interface_type allowed_ranges {"Hard XAUI"} 
    }
    
    if {$device_family == "Stratix IV" || $device_family == "HardCopy IV"} {
	set_parameter_property interface_type allowed_ranges {"Hard XAUI" "Soft XAUI"}
    }
    
    if {$device_family == "Stratix V" || $device_family == "Arria V" || $device_family == "Cyclone V" || $device_family == "Arria V GZ"} {
    set_parameter_property interface_type allowed_ranges {"Soft XAUI"} 
    }
    
    
    # Base R device dependent parameter
    if {$device_family == "Stratix IV"} {
		set_parameter_property BASER_INTERFACE allowed_ranges {"0:Soft 10GBASE-R"}
        set_parameter_property BASER_INTERFACE ENABLED false
        set_parameter_property BASER_STARTING_CHANNEL_NUMBER ENABLED true
        set_parameter_property BASER_STARTING_CHANNEL_NUMBER VISIBLE true
        set_parameter_property BASER_REF_CLK_FREQ allowed_ranges {"644.53125 MHz"}
	} else {
		set_parameter_property BASER_INTERFACE allowed_ranges {"0:Hard 10GBASE-R"}
        set_parameter_property BASER_INTERFACE ENABLED false
        set_parameter_property BASER_STARTING_CHANNEL_NUMBER ENABLED false
        set_parameter_property BASER_STARTING_CHANNEL_NUMBER VISIBLE false 
        set_parameter_property BASER_REF_CLK_FREQ allowed_ranges {"322.265625 MHz" "644.53125 MHz"}
        set_parameter_property BASER_EXT_PMA_CONTROL_CONF VISIBLE false
        # set_parameter_property BASER_TRANSMITTER_TERMINATION VISIBLE false 
        # set_parameter_property BASER_PRE_EMPHASIS_PRE_TAP VISIBLE false
        # set_parameter_property BASER_PRE_EMPHASIS_PRE_TAP_POLARITY VISIBLE false
        # set_parameter_property BASER_PRE_EMPHASIS_FIRST_POST_TAP VISIBLE false
        # set_parameter_property BASER_PRE_EMPHASIS_SECOND_POST_TAP VISIBLE false
        # set_parameter_property BASER_PRE_EMPHASIS_SECOND_POST_TAP_POLARITY VISIBLE false
        # set_parameter_property BASER_TRANSMITTER_VOD VISIBLE false
        # set_parameter_property BASER_RECEIVER_TERMINATION VISIBLE false
        # set_parameter_property BASER_RECEIVER_DC_GAIN VISIBLE false
        # set_parameter_property BASER_RECEIVER_STATIC_EQUALIZER VISIBLE false
        # set_parameter_property BASER_EXT_PMA_CONTROL_CONF VISIBLE false
        
	}
	
    
    
	# Disable certain configuration. for display purpose only
	set_parameter_property SYNC_TX_FIFO_SYMBOLS_PER_BEAT ENABLED false
	set_parameter_property SYNC_TX_FIFO_BITS_PER_SYMBOL ENABLED false
	
	set_parameter_property SYNC_RX_FIFO_SYMBOLS_PER_BEAT ENABLED false
	set_parameter_property SYNC_RX_FIFO_BITS_PER_SYMBOL ENABLED false
	
	set_parameter_property ASYNC_TX_FIFO_SYMBOLS_PER_BEAT ENABLED false
	set_parameter_property ASYNC_TX_FIFO_BITS_PER_SYMBOL  ENABLED false
	
	set_parameter_property ASYNC_RX_FIFO_SYMBOLS_PER_BEAT ENABLED false
	set_parameter_property ASYNC_RX_FIFO_BITS_PER_SYMBOL  ENABLED false
    
    set_parameter_property SYNC_TX_FIFO_ERROR_WIDTH ENABLED false
    set_parameter_property SYNC_RX_FIFO_ERROR_WIDTH ENABLED false
    set_parameter_property ASYNC_TX_FIFO_ERROR_WIDTH ENABLED false
    set_parameter_property ASYNC_RX_FIFO_ERROR_WIDTH ENABLED false
    set_parameter_property SYNC_RX_USE_ALMOST_FULL ENABLED false
    set_parameter_property SYNC_RX_USE_ALMOST_EMPTY ENABLED false
    
}


proc compose {} {
    #| Get parameters value
    # MAC parameter
    set supp_addr_ena [get_parameter_value ENABLE_SUPP_ADDR]
    set stat_ena [get_parameter_value INSTANTIATE_STATISTICS]
    set preamble_mode [get_parameter_value PREAMBLE_PASSTHROUGH]
    set pfc_ena [get_parameter_value ENABLE_PFC]
    set pfc_priority_num [get_parameter_value PFC_PRIORITY_NUM]
    set reg_stat [get_parameter_value REGISTER_BASED_STATISTICS]
    set crc_tx [get_parameter_value INSTANTIATE_TX_CRC]
	# set enable_mdio_2_wire_serial_int [get_parameter_value ENABLE_MDIO_2_WIRE_SERIAL_INT]
    set choose_mdio_2_wire_serial_int [get_parameter_value CHOOSE_MDIO_2_WIRE_SERIAL_INT]
	set mdio_mdc_divisor [get_parameter_value MDIO_MDC_DIVISOR] 
    set phy_ip [get_parameter_value PHY_IP]
    set choose_fifo [get_parameter_value CHOOSE_FIFO]
	set timestamp_ena [get_parameter_value ENABLE_TIMESTAMPING]
	set ptp_1step_ena [get_parameter_value ENABLE_PTP_1STEP]
	set tstamp_fp_width [get_parameter_value TSTAMP_FP_WIDTH]	
    set mac_1g10g_ena [get_parameter_value ENABLE_1G10G_MAC]	

    
    #| Parameters Xaui
    set xaui_starting_channel_number [get_parameter_value XAUI_STARTING_CHANNEL_NUMBER]
    set interface_type [get_parameter_value interface_type]
    set tx_termination [get_parameter_value tx_termination]
    set tx_vod_selection [get_parameter_value tx_vod_selection]
    set tx_preemp_pretap [get_parameter_value tx_preemp_pretap]
    set tx_preemp_pretap_inv [get_parameter_value tx_preemp_pretap_inv]
    set tx_preemp_tap_1 [get_parameter_value tx_preemp_tap_1]
    set tx_preemp_tap_2 [get_parameter_value tx_preemp_tap_2]
    set tx_preemp_tap_2_inv [get_parameter_value tx_preemp_tap_2_inv]
    set rx_common_mode [get_parameter_value rx_common_mode]
    set rx_termination [get_parameter_value rx_termination]
    set rx_eq_dc_gain [get_parameter_value rx_eq_dc_gain]
    set rx_eq_ctrl [get_parameter_value rx_eq_ctrl]
    set gui_pll_type [get_parameter_value gui_pll_type]
    set use_control_and_status_ports [get_parameter_value use_control_and_status_ports]
    set external_pma_ctrl_reconf [get_parameter_value external_pma_ctrl_reconf]
    set recovered_clk_out [get_parameter_value recovered_clk_out]
    
    #| Parameters Base R
    set baser_pll_type [get_parameter_value BASER_PLL_TYPE]
    set baser_starting_channel_number [get_parameter_value BASER_STARTING_CHANNEL_NUMBER]
    set baser_ref_clk_freq [get_parameter_value BASER_REF_CLK_FREQ]
    set baser_transmitter_termination [get_parameter_value BASER_TRANSMITTER_TERMINATION]
    set baser_pre_emphasis_pre_tap [get_parameter_value BASER_PRE_EMPHASIS_PRE_TAP]
    set baser_pre_emphasis_pre_tap_polarity [get_parameter_value BASER_PRE_EMPHASIS_PRE_TAP_POLARITY]
    set baser_pre_emphasis_first_post_tap [get_parameter_value BASER_PRE_EMPHASIS_FIRST_POST_TAP]
    set baser_pre_emphasis_second_post_tap [get_parameter_value BASER_PRE_EMPHASIS_SECOND_POST_TAP]
    set baser_pre_emphasis_second_post_tap_polarity [get_parameter_value BASER_PRE_EMPHASIS_SECOND_POST_TAP_POLARITY]
    set baser_transmitter_vod [get_parameter_value BASER_TRANSMITTER_VOD]
    set baser_receiver_termination [get_parameter_value BASER_RECEIVER_TERMINATION]
    set baser_receiver_dc_gain [get_parameter_value BASER_RECEIVER_DC_GAIN]
    set baser_receiver_static_equalizer [get_parameter_value BASER_RECEIVER_STATIC_EQUALIZER]
    set baser_ext_pma_control_conf [get_parameter_value BASER_EXT_PMA_CONTROL_CONF]
    set baser_ena_add_control_stat [get_parameter_value BASER_ENA_ADD_CONTROL_STAT]
    set baser_recovered_clk_out [get_parameter_value BASER_RECOVERED_CLK_OUT]
    
    #| Parameter SC FIFO
    set sync_tx_fifo_symbols_per_beat [get_parameter_value SYNC_TX_FIFO_SYMBOLS_PER_BEAT]
    set sync_tx_fifo_bits_per_symbol [get_parameter_value SYNC_TX_FIFO_BITS_PER_SYMBOL]
    set sync_tx_fifo_depth [get_parameter_value SYNC_TX_FIFO_DEPTH]
    set sync_tx_fifo_error_width [get_parameter_value SYNC_TX_FIFO_ERROR_WIDTH]
    set sync_tx_use_packets [get_parameter_value SYNC_TX_USE_PACKETS]
    set sync_tx_use_fill [get_parameter_value SYNC_TX_USE_FILL]
    set sync_tx_use_store_and_forward [get_parameter_value SYNC_TX_USE_STORE_AND_FORWARD]
    set sync_tx_use_almost_full [get_parameter_value SYNC_TX_USE_ALMOST_FULL]
    set sync_tx_use_almost_empty [get_parameter_value SYNC_TX_USE_ALMOST_EMPTY]
    set sync_rx_fifo_symbols_per_beat [get_parameter_value SYNC_RX_FIFO_SYMBOLS_PER_BEAT]
    set sync_rx_fifo_bits_per_symbol [get_parameter_value SYNC_RX_FIFO_BITS_PER_SYMBOL]
    set sync_rx_fifo_depth [get_parameter_value SYNC_RX_FIFO_DEPTH]
    set sync_rx_fifo_error_width [get_parameter_value SYNC_RX_FIFO_ERROR_WIDTH]
    set sync_rx_use_packets [get_parameter_value SYNC_RX_USE_PACKETS]
    set sync_rx_use_fill [get_parameter_value SYNC_RX_USE_FILL]
    set sync_rx_use_store_and_forward [get_parameter_value SYNC_RX_USE_STORE_AND_FORWARD]
    set sync_rx_use_almost_full [get_parameter_value SYNC_RX_USE_ALMOST_FULL]
    set sync_rx_use_almost_empty [get_parameter_value SYNC_RX_USE_ALMOST_EMPTY]
    
    #| Parameter DC FIFO
    set async_tx_fifo_depth [get_parameter_value ASYNC_TX_FIFO_DEPTH]
    set async_tx_fifo_error_width [get_parameter_value ASYNC_TX_FIFO_ERROR_WIDTH]
    set async_tx_use_pkt [get_parameter_value ASYNC_TX_USE_PKT] 
    set async_tx_use_sink_fill [get_parameter_value ASYNC_TX_USE_SINK_FILL]
    set async_tx_use_src_fill [get_parameter_value ASYNC_TX_USE_SRC_FILL]
    set async_rx_fifo_symbols_per_beat [get_parameter_value ASYNC_RX_FIFO_SYMBOLS_PER_BEAT]
    set async_rx_fifo_bits_per_symbol [get_parameter_value ASYNC_RX_FIFO_BITS_PER_SYMBOL]
    set async_rx_fifo_depth [get_parameter_value ASYNC_RX_FIFO_DEPTH]
    set async_rx_fifo_error_width [get_parameter_value ASYNC_RX_FIFO_ERROR_WIDTH]
    set async_rx_use_pkt [get_parameter_value ASYNC_RX_USE_PKT]
    set async_rx_use_sink_fill [get_parameter_value ASYNC_RX_USE_SINK_FILL]
    set async_rx_use_src_fill [get_parameter_value ASYNC_RX_USE_SRC_FILL]
    
    
    #| Add Clock Instance
    add_instance mm_clk_module clock_source  
    set_instance_parameter mm_clk_module clockFrequencyKnown "true"
    set_instance_parameter mm_clk_module clockFrequency "156250000"
    
    add_interface mm_clk clock end
    set_interface_property mm_clk export_of mm_clk_module.clk_in
    
    add_interface mm_reset reset end
    set_interface_property mm_reset export_of mm_clk_module.clk_in_reset
    
    add_instance tx_clk_module clock_source  
    set_instance_parameter tx_clk_module clockFrequencyKnown "true"
    set_instance_parameter tx_clk_module clockFrequency "156250000"
    
    add_interface tx_clk clock end
    set_interface_property tx_clk export_of tx_clk_module.clk_in
    
    add_interface tx_reset reset end
    set_interface_property tx_reset export_of tx_clk_module.clk_in_reset
    
   
    if {$phy_ip == 0 || $phy_ip == 1} {
    #| Add module instance    
    # MM Pipeline Bridge
    add_instance altera_avalon_mm_bridge altera_merlin_master_translator  
    set_instance_parameter altera_avalon_mm_bridge AV_ADDRESS_W "19"
    set_instance_parameter altera_avalon_mm_bridge AV_DATA_W "32"
    set_instance_parameter altera_avalon_mm_bridge AV_BURSTCOUNT_W "3"
    set_instance_parameter altera_avalon_mm_bridge AV_BYTEENABLE_W "4"
    set_instance_parameter altera_avalon_mm_bridge UAV_ADDRESS_W "32"
    set_instance_parameter altera_avalon_mm_bridge UAV_BURSTCOUNT_W "3"
    set_instance_parameter altera_avalon_mm_bridge AV_READLATENCY "0"
    set_instance_parameter altera_avalon_mm_bridge AV_WRITE_WAIT "0"
    set_instance_parameter altera_avalon_mm_bridge AV_READ_WAIT "0"
    set_instance_parameter altera_avalon_mm_bridge AV_DATA_HOLD "0"
    set_instance_parameter altera_avalon_mm_bridge AV_SETUP_WAIT "0"
    set_instance_parameter altera_avalon_mm_bridge USE_READDATA "1"
    set_instance_parameter altera_avalon_mm_bridge USE_WRITEDATA "1"
    set_instance_parameter altera_avalon_mm_bridge USE_READ "1"
    set_instance_parameter altera_avalon_mm_bridge USE_WRITE "1"
    set_instance_parameter altera_avalon_mm_bridge USE_BEGINBURSTTRANSFER "0"
    set_instance_parameter altera_avalon_mm_bridge USE_BEGINTRANSFER "0"
    set_instance_parameter altera_avalon_mm_bridge USE_BYTEENABLE "0"
    set_instance_parameter altera_avalon_mm_bridge USE_CHIPSELECT "0"
    set_instance_parameter altera_avalon_mm_bridge USE_ADDRESS "1"
    set_instance_parameter altera_avalon_mm_bridge USE_BURSTCOUNT "0"
    set_instance_parameter altera_avalon_mm_bridge USE_READDATAVALID "0"
    set_instance_parameter altera_avalon_mm_bridge USE_WAITREQUEST "1"
    set_instance_parameter altera_avalon_mm_bridge USE_LOCK "0"
    set_instance_parameter altera_avalon_mm_bridge AV_SYMBOLS_PER_WORD "4"
    set_instance_parameter altera_avalon_mm_bridge AV_ADDRESS_SYMBOLS "1"
    set_instance_parameter altera_avalon_mm_bridge AV_BURSTCOUNT_SYMBOLS "1"
    set_instance_parameter altera_avalon_mm_bridge AV_CONSTANT_BURST_BEHAVIOR "0"
    set_instance_parameter altera_avalon_mm_bridge AV_LINEWRAPBURSTS "0"
    set_instance_parameter altera_avalon_mm_bridge AV_MAX_PENDING_READ_TRANSACTIONS "0"
    set_instance_parameter altera_avalon_mm_bridge AV_BURSTBOUNDARIES "0"
    set_instance_parameter altera_avalon_mm_bridge AV_INTERLEAVEBURSTS "0"
    set_instance_parameter altera_avalon_mm_bridge AV_BITS_PER_SYMBOL "8"
    set_instance_parameter altera_avalon_mm_bridge AV_ISBIGENDIAN "0"
    set_instance_parameter altera_avalon_mm_bridge AV_ADDRESSGROUP "0"
    set_instance_parameter altera_avalon_mm_bridge UAV_ADDRESSGROUP "0"
    set_instance_parameter altera_avalon_mm_bridge AV_REGISTEROUTGOINGSIGNALS "0"
    set_instance_parameter altera_avalon_mm_bridge AV_REGISTERINCOMINGSIGNALS "0"
    set_instance_parameter altera_avalon_mm_bridge AV_ALWAYSBURSTMAXBURST "0"
    
    add_connection mm_clk_module.clk/altera_avalon_mm_bridge.clk
    add_connection mm_clk_module.clk_reset/altera_avalon_mm_bridge.reset
    
    add_interface mm_pipeline_bridge avalon end
    set_interface_property mm_pipeline_bridge export_of altera_avalon_mm_bridge.avalon_anti_master_0
    } else {
    #| Add module instance    
    # MM Pipeline Bridge
    add_instance altera_avalon_mm_bridge altera_merlin_master_translator  
    set_instance_parameter altera_avalon_mm_bridge AV_ADDRESS_W "17"
    set_instance_parameter altera_avalon_mm_bridge AV_DATA_W "32"
    set_instance_parameter altera_avalon_mm_bridge AV_BURSTCOUNT_W "3"
    set_instance_parameter altera_avalon_mm_bridge AV_BYTEENABLE_W "4"
    set_instance_parameter altera_avalon_mm_bridge UAV_ADDRESS_W "32"
    set_instance_parameter altera_avalon_mm_bridge UAV_BURSTCOUNT_W "3"
    set_instance_parameter altera_avalon_mm_bridge AV_READLATENCY "0"
    set_instance_parameter altera_avalon_mm_bridge AV_WRITE_WAIT "0"
    set_instance_parameter altera_avalon_mm_bridge AV_READ_WAIT "0"
    set_instance_parameter altera_avalon_mm_bridge AV_DATA_HOLD "0"
    set_instance_parameter altera_avalon_mm_bridge AV_SETUP_WAIT "0"
    set_instance_parameter altera_avalon_mm_bridge USE_READDATA "1"
    set_instance_parameter altera_avalon_mm_bridge USE_WRITEDATA "1"
    set_instance_parameter altera_avalon_mm_bridge USE_READ "1"
    set_instance_parameter altera_avalon_mm_bridge USE_WRITE "1"
    set_instance_parameter altera_avalon_mm_bridge USE_BEGINBURSTTRANSFER "0"
    set_instance_parameter altera_avalon_mm_bridge USE_BEGINTRANSFER "0"
    set_instance_parameter altera_avalon_mm_bridge USE_BYTEENABLE "0"
    set_instance_parameter altera_avalon_mm_bridge USE_CHIPSELECT "0"
    set_instance_parameter altera_avalon_mm_bridge USE_ADDRESS "1"
    set_instance_parameter altera_avalon_mm_bridge USE_BURSTCOUNT "0"
    set_instance_parameter altera_avalon_mm_bridge USE_READDATAVALID "0"
    set_instance_parameter altera_avalon_mm_bridge USE_WAITREQUEST "1"
    set_instance_parameter altera_avalon_mm_bridge USE_LOCK "0"
    set_instance_parameter altera_avalon_mm_bridge AV_SYMBOLS_PER_WORD "4"
    set_instance_parameter altera_avalon_mm_bridge AV_ADDRESS_SYMBOLS "1"
    set_instance_parameter altera_avalon_mm_bridge AV_BURSTCOUNT_SYMBOLS "1"
    set_instance_parameter altera_avalon_mm_bridge AV_CONSTANT_BURST_BEHAVIOR "0"
    set_instance_parameter altera_avalon_mm_bridge AV_LINEWRAPBURSTS "0"
    set_instance_parameter altera_avalon_mm_bridge AV_MAX_PENDING_READ_TRANSACTIONS "0"
    set_instance_parameter altera_avalon_mm_bridge AV_BURSTBOUNDARIES "0"
    set_instance_parameter altera_avalon_mm_bridge AV_INTERLEAVEBURSTS "0"
    set_instance_parameter altera_avalon_mm_bridge AV_BITS_PER_SYMBOL "8"
    set_instance_parameter altera_avalon_mm_bridge AV_ISBIGENDIAN "0"
    set_instance_parameter altera_avalon_mm_bridge AV_ADDRESSGROUP "0"
    set_instance_parameter altera_avalon_mm_bridge UAV_ADDRESSGROUP "0"
    set_instance_parameter altera_avalon_mm_bridge AV_REGISTEROUTGOINGSIGNALS "0"
    set_instance_parameter altera_avalon_mm_bridge AV_REGISTERINCOMINGSIGNALS "0"
    set_instance_parameter altera_avalon_mm_bridge AV_ALWAYSBURSTMAXBURST "0"
    
    add_connection mm_clk_module.clk/altera_avalon_mm_bridge.clk
    add_connection mm_clk_module.clk_reset/altera_avalon_mm_bridge.reset
    
    add_interface mm_pipeline_bridge avalon end
    set_interface_property mm_pipeline_bridge export_of altera_avalon_mm_bridge.avalon_anti_master_0
    }
    
        
    #|Composition for MAC + loopback only + phy
    if {$phy_ip == 0 || $phy_ip == 1} {
    add_instance ref_clk_module clock_source  
    set_instance_parameter ref_clk_module clockFrequencyKnown "true"
    
    add_interface ref_clk clock end
    set_interface_property ref_clk export_of ref_clk_module.clk_in
    
    add_interface ref_reset reset end
    set_interface_property ref_reset export_of ref_clk_module.clk_in_reset
    
        if {$phy_ip == 0} {
        compose_xaui $xaui_starting_channel_number $interface_type $tx_termination $tx_vod_selection $tx_preemp_pretap $tx_preemp_pretap_inv $tx_preemp_tap_1 $tx_preemp_tap_2 $tx_preemp_tap_2_inv $rx_common_mode $rx_termination $rx_eq_dc_gain $rx_eq_ctrl $gui_pll_type $use_control_and_status_ports $external_pma_ctrl_reconf $recovered_clk_out tx_clk_module.clk ref_clk_module.clk mm_clk_module.clk mm_clk_module.clk_reset altera_avalon_mm_bridge.avalon_universal_master_0
        
        set_instance_parameter ref_clk_module clockFrequency "156250000"
        
        } elseif {$phy_ip == 1} {
        compose_baser $timestamp_ena $baser_pll_type $baser_starting_channel_number $baser_ref_clk_freq $baser_transmitter_termination $baser_pre_emphasis_pre_tap $baser_pre_emphasis_pre_tap_polarity $baser_pre_emphasis_first_post_tap $baser_pre_emphasis_second_post_tap $baser_pre_emphasis_second_post_tap_polarity $baser_transmitter_vod $baser_receiver_termination $baser_receiver_dc_gain $baser_receiver_static_equalizer $baser_ext_pma_control_conf $baser_ena_add_control_stat $baser_recovered_clk_out tx_clk_module.clk ref_clk_module.clk mm_clk_module.clk mm_clk_module.clk_reset altera_avalon_mm_bridge.avalon_universal_master_0 
        
        set_instance_parameter ref_clk_module clockFrequency $baser_ref_clk_freq
        
        }
    
    } else {
    
    add_instance rx_clk_module clock_source  
    set_instance_parameter rx_clk_module clockFrequencyKnown "true"
    set_instance_parameter rx_clk_module clockFrequency "156250000"
    
    add_interface rx_clk clock end
    set_interface_property rx_clk export_of rx_clk_module.clk_in
    
    add_interface rx_reset reset end
    set_interface_property rx_reset export_of rx_clk_module.clk_in_reset
    }
    
    if {$choose_fifo == 3 } {
        
        if {$phy_ip == "0"} {
    
        compose_eth_and_loopback tx_clk_module.clk tx_clk_module.clk_reset xaui.xgmii_rx_clk ref_clk_module.clk_reset mm_clk_module.clk mm_clk_module.clk_reset altera_avalon_mm_bridge.avalon_universal_master_0 $supp_addr_ena $stat_ena $reg_stat $crc_tx $preamble_mode $pfc_ena $pfc_priority_num $timestamp_ena $ptp_1step_ena $tstamp_fp_width $mac_1g10g_ena
        } elseif {$phy_ip == "1"} {
        compose_eth_and_loopback tx_clk_module.clk tx_clk_module.clk_reset altera_10gbaser.xgmii_rx_clk ref_clk_module.clk_reset mm_clk_module.clk mm_clk_module.clk_reset altera_avalon_mm_bridge.avalon_universal_master_0 $supp_addr_ena $stat_ena $reg_stat $crc_tx $preamble_mode $pfc_ena $pfc_priority_num $timestamp_ena $ptp_1step_ena $tstamp_fp_width $mac_1g10g_ena
            
        } elseif {$phy_ip == "2"} {
        compose_eth_and_loopback tx_clk_module.clk tx_clk_module.clk_reset rx_clk_module.clk rx_clk_module.clk_reset mm_clk_module.clk mm_clk_module.clk_reset altera_avalon_mm_bridge.avalon_universal_master_0 $supp_addr_ena $stat_ena $reg_stat $crc_tx $preamble_mode $pfc_ena $pfc_priority_num $timestamp_ena $ptp_1step_ena $tstamp_fp_width $mac_1g10g_ena
        }
        
    } elseif {$choose_fifo == 0} {
    
        if {$phy_ip == "2"} {
        compose_eth_and_loopback tx_clk_module.clk tx_clk_module.clk_reset rx_clk_module.clk rx_clk_module.clk_reset mm_clk_module.clk mm_clk_module.clk_reset altera_avalon_mm_bridge.avalon_universal_master_0 $supp_addr_ena $stat_ena $reg_stat $crc_tx $preamble_mode $pfc_ena $pfc_priority_num $timestamp_ena $ptp_1step_ena $tstamp_fp_width $mac_1g10g_ena
        
        compose_sc_fifo $sync_tx_fifo_depth $sync_tx_fifo_error_width $sync_tx_use_store_and_forward tx_clk_module.clk  tx_clk_module.clk_reset mm_clk_module.clk altera_avalon_mm_bridge.avalon_universal_master_0 $sync_rx_fifo_depth $sync_rx_fifo_error_width $sync_rx_use_store_and_forward rx_clk_module.clk rx_clk_module.clk_reset $sync_tx_use_almost_full $sync_tx_use_almost_empty
            
        } elseif {$phy_ip == "0"} {
        compose_eth_and_loopback tx_clk_module.clk tx_clk_module.clk_reset xaui.xgmii_rx_clk ref_clk_module.clk_reset mm_clk_module.clk mm_clk_module.clk_reset altera_avalon_mm_bridge.avalon_universal_master_0 $supp_addr_ena $stat_ena $reg_stat $crc_tx $preamble_mode $pfc_ena $pfc_priority_num $timestamp_ena $ptp_1step_ena $tstamp_fp_width $mac_1g10g_ena
        
        compose_sc_fifo $sync_tx_fifo_depth $sync_tx_fifo_error_width $sync_tx_use_store_and_forward tx_clk_module.clk  tx_clk_module.clk_reset mm_clk_module.clk altera_avalon_mm_bridge.avalon_universal_master_0 $sync_rx_fifo_depth $sync_rx_fifo_error_width $sync_rx_use_store_and_forward xaui.xgmii_rx_clk ref_clk_module.clk_reset $sync_tx_use_almost_full $sync_tx_use_almost_empty

        } elseif {$phy_ip == "1"} {

        compose_eth_and_loopback tx_clk_module.clk tx_clk_module.clk_reset altera_10gbaser.xgmii_rx_clk ref_clk_module.clk_reset mm_clk_module.clk mm_clk_module.clk_reset altera_avalon_mm_bridge.avalon_universal_master_0 $supp_addr_ena $stat_ena $reg_stat $crc_tx $preamble_mode $pfc_ena $pfc_priority_num $timestamp_ena $ptp_1step_ena $tstamp_fp_width $mac_1g10g_ena
        
        compose_sc_fifo $sync_tx_fifo_depth $sync_tx_fifo_error_width $sync_tx_use_store_and_forward tx_clk_module.clk  tx_clk_module.clk_reset mm_clk_module.clk altera_avalon_mm_bridge.avalon_universal_master_0 $sync_rx_fifo_depth $sync_rx_fifo_error_width $sync_rx_use_store_and_forward altera_10gbaser.xgmii_rx_clk ref_clk_module.clk_reset $sync_tx_use_almost_full $sync_tx_use_almost_empty
        }    
        
    } elseif {$choose_fifo == 1} {
    
        add_instance dc_tx_clk_module clock_source  
        set_instance_parameter dc_tx_clk_module clockFrequencyKnown "true"
        set_instance_parameter dc_tx_clk_module clockFrequency "156250000"
        
        add_interface dc_tx_clk clock end
        set_interface_property dc_tx_clk export_of dc_tx_clk_module.clk_in
        
        add_interface dc_tx_reset reset end
        set_interface_property dc_tx_reset export_of dc_tx_clk_module.clk_in_reset
        
        add_instance dc_rx_clk_module clock_source  
        set_instance_parameter dc_rx_clk_module clockFrequencyKnown "true"
        set_instance_parameter dc_rx_clk_module clockFrequency "156250000"
        
        add_interface dc_rx_clk clock end
        set_interface_property dc_rx_clk export_of dc_rx_clk_module.clk_in
        
        add_interface dc_rx_reset reset end
        set_interface_property dc_rx_reset export_of dc_rx_clk_module.clk_in_reset
    
    
        if {$phy_ip == "2"} {
        compose_eth_and_loopback tx_clk_module.clk tx_clk_module.clk_reset rx_clk_module.clk rx_clk_module.clk_reset mm_clk_module.clk mm_clk_module.clk_reset altera_avalon_mm_bridge.avalon_universal_master_0 $supp_addr_ena $stat_ena $reg_stat $crc_tx $preamble_mode $pfc_ena $pfc_priority_num $timestamp_ena $ptp_1step_ena $tstamp_fp_width $mac_1g10g_ena
        
        compose_dc_fifo $async_tx_fifo_depth $async_tx_fifo_error_width $async_rx_fifo_depth $async_rx_fifo_error_width tx_clk_module.clk tx_clk_module.clk_reset rx_clk_module.clk rx_clk_module.clk_reset dc_tx_clk_module.clk dc_tx_clk_module.clk_reset dc_rx_clk_module.clk dc_rx_clk_module.clk_reset
            
        } elseif {$phy_ip == "0"} {
        compose_eth_and_loopback tx_clk_module.clk tx_clk_module.clk_reset xaui.xgmii_rx_clk ref_clk_module.clk_reset mm_clk_module.clk mm_clk_module.clk_reset altera_avalon_mm_bridge.avalon_universal_master_0 $supp_addr_ena $stat_ena $reg_stat $crc_tx $preamble_mode $pfc_ena $pfc_priority_num $timestamp_ena $ptp_1step_ena $tstamp_fp_width $mac_1g10g_ena
        
        compose_dc_fifo $async_tx_fifo_depth $async_tx_fifo_error_width $async_rx_fifo_depth $async_rx_fifo_error_width tx_clk_module.clk tx_clk_module.clk_reset xaui.xgmii_rx_clk ref_clk_module.clk_reset dc_tx_clk_module.clk dc_tx_clk_module.clk_reset dc_rx_clk_module.clk dc_rx_clk_module.clk_reset

        } elseif {$phy_ip == "1"} {

        compose_eth_and_loopback tx_clk_module.clk tx_clk_module.clk_reset altera_10gbaser.xgmii_rx_clk ref_clk_module.clk_reset mm_clk_module.clk mm_clk_module.clk_reset altera_avalon_mm_bridge.avalon_universal_master_0 $supp_addr_ena $stat_ena $reg_stat $crc_tx $preamble_mode $pfc_ena $pfc_priority_num $timestamp_ena $ptp_1step_ena $tstamp_fp_width $mac_1g10g_ena
        
        compose_dc_fifo $async_tx_fifo_depth $async_tx_fifo_error_width $async_rx_fifo_depth $async_rx_fifo_error_width tx_clk_module.clk tx_clk_module.clk_reset altera_10gbaser.xgmii_rx_clk ref_clk_module.clk_reset dc_tx_clk_module.clk dc_tx_clk_module.clk_reset dc_rx_clk_module.clk dc_rx_clk_module.clk_reset
        }
    } elseif {$choose_fifo == 2} {
    
        add_instance dc_tx_clk_module clock_source  
        set_instance_parameter dc_tx_clk_module clockFrequencyKnown "true"
        set_instance_parameter dc_tx_clk_module clockFrequency "156250000"
        
        add_interface dc_tx_clk clock end
        set_interface_property dc_tx_clk export_of dc_tx_clk_module.clk_in
        
        add_interface dc_tx_reset reset end
        set_interface_property dc_tx_reset export_of dc_tx_clk_module.clk_in_reset
        
        add_instance dc_rx_clk_module clock_source  
        set_instance_parameter dc_rx_clk_module clockFrequencyKnown "true"
        set_instance_parameter dc_rx_clk_module clockFrequency "156250000"
        
        add_interface dc_rx_clk clock end
        set_interface_property dc_rx_clk export_of dc_rx_clk_module.clk_in
        
        add_interface dc_rx_reset reset end
        set_interface_property dc_rx_reset export_of dc_rx_clk_module.clk_in_reset
    
    
        if {$phy_ip == "2"} {
        compose_eth_and_loopback tx_clk_module.clk tx_clk_module.clk_reset rx_clk_module.clk rx_clk_module.clk_reset mm_clk_module.clk mm_clk_module.clk_reset altera_avalon_mm_bridge.avalon_universal_master_0 $supp_addr_ena $stat_ena $reg_stat $crc_tx $preamble_mode $pfc_ena $pfc_priority_num $timestamp_ena $ptp_1step_ena $tstamp_fp_width $mac_1g10g_ena
        
        compose_dc_sc_fifo $async_tx_fifo_depth $async_tx_fifo_error_width $async_rx_fifo_depth $async_rx_fifo_error_width tx_clk_module.clk tx_clk_module.clk_reset rx_clk_module.clk tx_clk_module.clk_reset dc_tx_clk_module.clk dc_tx_clk_module.clk_reset dc_rx_clk_module.clk dc_rx_clk_module.clk_reset $sync_tx_fifo_depth $sync_tx_fifo_error_width $sync_tx_use_store_and_forward mm_clk_module.clk altera_avalon_mm_bridge.avalon_universal_master_0 $sync_rx_fifo_depth $sync_rx_fifo_error_width $sync_rx_use_store_and_forward $sync_tx_use_almost_full $sync_tx_use_almost_empty
            
        } elseif {$phy_ip == "0"} {
        compose_eth_and_loopback tx_clk_module.clk tx_clk_module.clk_reset xaui.xgmii_rx_clk ref_clk_module.clk_reset mm_clk_module.clk mm_clk_module.clk_reset altera_avalon_mm_bridge.avalon_universal_master_0 $supp_addr_ena $stat_ena $reg_stat $crc_tx $preamble_mode $pfc_ena $pfc_priority_num $timestamp_ena $ptp_1step_ena $tstamp_fp_width $mac_1g10g_ena
        
        compose_dc_sc_fifo $async_tx_fifo_depth $async_tx_fifo_error_width $async_rx_fifo_depth $async_rx_fifo_error_width tx_clk_module.clk tx_clk_module.clk_reset xaui.xgmii_rx_clk ref_clk_module.clk_reset dc_tx_clk_module.clk dc_tx_clk_module.clk_reset dc_rx_clk_module.clk dc_rx_clk_module.clk_reset $sync_tx_fifo_depth $sync_tx_fifo_error_width $sync_tx_use_store_and_forward mm_clk_module.clk altera_avalon_mm_bridge.avalon_universal_master_0 $sync_rx_fifo_depth $sync_rx_fifo_error_width $sync_rx_use_store_and_forward $sync_tx_use_almost_full $sync_tx_use_almost_empty

        } elseif {$phy_ip == "1"} {

        compose_eth_and_loopback tx_clk_module.clk tx_clk_module.clk_reset altera_10gbaser.xgmii_rx_clk ref_clk_module.clk_reset mm_clk_module.clk mm_clk_module.clk_reset altera_avalon_mm_bridge.avalon_universal_master_0 $supp_addr_ena $stat_ena $reg_stat $crc_tx $preamble_mode $pfc_ena $pfc_priority_num $timestamp_ena $ptp_1step_ena $tstamp_fp_width $mac_1g10g_ena
        
        compose_dc_sc_fifo $async_tx_fifo_depth $async_tx_fifo_error_width $async_rx_fifo_depth $async_rx_fifo_error_width tx_clk_module.clk tx_clk_module.clk_reset altera_10gbaser.xgmii_rx_clk ref_clk_module.clk_reset dc_tx_clk_module.clk dc_tx_clk_module.clk_reset dc_rx_clk_module.clk dc_rx_clk_module.clk_reset $sync_tx_fifo_depth $sync_tx_fifo_error_width $sync_tx_use_store_and_forward mm_clk_module.clk altera_avalon_mm_bridge.avalon_universal_master_0 $sync_rx_fifo_depth $sync_rx_fifo_error_width $sync_rx_use_store_and_forward $sync_tx_use_almost_full $sync_tx_use_almost_empty
        }
    
    }
        
         
    if {$phy_ip == "0"} {
    
    add_connection xaui.xgmii_rx_dc/eth_loopback_composed.lb_rx_sink_data
    add_connection eth_loopback_composed.lb_tx_src_data/xaui.xgmii_tx_dc 
           
    add_interface rx_serial_data conduit end
    set_interface_property rx_serial_data export_of xaui.xaui_rx_serial_data
    
    add_interface tx_serial_data conduit start
    set_interface_property tx_serial_data export_of xaui.xaui_tx_serial_data    
    
    add_interface rx_ready conduit start
    set_interface_property rx_ready export_of xaui.rx_ready
    
    add_interface tx_ready conduit start
    set_interface_property tx_ready export_of xaui.tx_ready  

    } elseif {$phy_ip == "1"} {     
    
    add_connection altera_10gbaser.xgmii_rx_dc_0/eth_loopback_composed.lb_rx_sink_data
    add_connection eth_loopback_composed.lb_tx_src_data/altera_10gbaser.xgmii_tx_dc_0 
     
    add_interface rx_serial_data conduit end
    set_interface_property rx_serial_data export_of altera_10gbaser.rx_serial_data_0
    
    add_interface tx_serial_data conduit start
    set_interface_property tx_serial_data export_of altera_10gbaser.tx_serial_data_0    
    
    add_interface rx_ready conduit start
    set_interface_property rx_ready export_of altera_10gbaser.rx_ready
    
    add_interface rx_data_ready conduit start
    set_interface_property rx_data_ready export_of altera_10gbaser.rx_data_ready
    
    add_interface tx_ready conduit start
    set_interface_property tx_ready export_of altera_10gbaser.tx_ready 
 
	if {$timestamp_ena == 1} {
        add_connection altera_10gbaser.rx_latency_adj_0/eth_10g_mac.rx_path_delay_10g
        add_connection altera_10gbaser.tx_latency_adj_0/eth_10g_mac.tx_path_delay_10g
    }
    
    } else {
        if {$timestamp_ena == 1} {
            add_interface tx_path_delay_10g conduit end
            set_interface_property tx_path_delay_10g export_of eth_10g_mac.tx_path_delay_10g
            
            add_interface rx_path_delay_10g conduit end
            set_interface_property rx_path_delay_10g export_of eth_10g_mac.rx_path_delay_10g
            
            if {$mac_1g10g_ena == 1 || $mac_1g10g_ena == 2} {
                add_interface tx_path_delay_1g conduit end
                set_interface_property tx_path_delay_1g export_of eth_10g_mac.tx_path_delay_1g
                
                add_interface rx_path_delay_1g conduit end
                set_interface_property rx_path_delay_1g export_of eth_10g_mac.rx_path_delay_1g
            }
        }
    }
    
    if {$timestamp_ena == 1} {
		#TX
		add_interface tx_egress_timestamp_request conduit end
		set_interface_property tx_egress_timestamp_request export_of eth_10g_mac.tx_egress_timestamp_request

		if {$ptp_1step_ena == 1} {
			add_interface tx_etstamp_ins_ctrl conduit end
			set_interface_property tx_etstamp_ins_ctrl export_of eth_10g_mac.tx_etstamp_ins_ctrl
		}
		
		add_interface tx_egress_timestamp_96b conduit start
		set_interface_property tx_egress_timestamp_96b export_of eth_10g_mac.tx_egress_timestamp_96b
        
        add_interface tx_egress_timestamp_64b conduit start
		set_interface_property tx_egress_timestamp_64b export_of eth_10g_mac.tx_egress_timestamp_64b
        
		#RX
		#  Export of RX Timestamp
		add_interface rx_ingress_timestamp_96b conduit start
		set_interface_property rx_ingress_timestamp_96b export_of eth_10g_mac.rx_ingress_timestamp_96b
        
        add_interface rx_ingress_timestamp_64b conduit start
		set_interface_property rx_ingress_timestamp_64b export_of eth_10g_mac.rx_ingress_timestamp_64b
    }

    if {$choose_fifo == 0} {  

    add_interface tx_sc_fifo_in avalon_streaming end
    set_interface_property tx_sc_fifo_in export_of tx_sc_fifo.in    
    
    add_connection tx_sc_fifo.out/eth_10g_mac.avalon_st_tx
    add_connection eth_10g_mac.avalon_st_rx/rx_sc_fifo.in
    
    add_interface rx_sc_fifo_out avalon_streaming start
    set_interface_property rx_sc_fifo_out export_of rx_sc_fifo.out
    
    } elseif {$choose_fifo == 1} {
    
	add_interface tx_dc_fifo_in avalon_streaming end
	set_interface_property tx_dc_fifo_in export_of tx_dc_fifo.in
    
    add_connection tx_dc_fifo.out/eth_10g_mac.avalon_st_tx
    
    add_interface avalon_st_pause avalon_streaming end
    set_interface_property avalon_st_pause export_of eth_10g_mac.avalon_st_pause
    
    add_connection eth_10g_mac.avalon_st_rx/rx_dc_fifo.in
    
    add_interface rx_dc_fifo_out avalon_streaming start
	set_interface_property rx_dc_fifo_out export_of rx_dc_fifo.out
    
    } elseif {$choose_fifo == 2} {
    
    add_interface tx_dc_fifo_in avalon_streaming end
	set_interface_property tx_dc_fifo_in export_of tx_dc_fifo.in
    
    add_connection tx_sc_fifo.out/eth_10g_mac.avalon_st_tx
    add_connection eth_10g_mac.avalon_st_rx/rx_sc_fifo.in
    
    add_interface rx_dc_fifo_out avalon_streaming start
	set_interface_property rx_dc_fifo_out export_of rx_dc_fifo.out
    
    } else {
    
    }
    
    if {$choose_fifo == 3 && $phy_ip !=2} {
    
    add_interface avalon_st_tx avalon_streaming end
    set_interface_property avalon_st_tx export_of eth_10g_mac.avalon_st_tx
    
    add_interface avalon_st_pause avalon_streaming end
    set_interface_property avalon_st_pause export_of eth_10g_mac.avalon_st_pause  
    
    add_interface avalon_st_rx avalon_streaming start
    set_interface_property avalon_st_rx export_of eth_10g_mac.avalon_st_rx
    }
    
    if {$choose_fifo != 3 && $phy_ip == 2} {
    
    add_interface xgmii_rx avalon_streaming end
    set_interface_property xgmii_rx export_of eth_loopback_composed.lb_rx_sink_data
    
    add_interface xgmii_tx avalon_streaming start
    set_interface_property xgmii_tx export_of eth_loopback_composed.lb_tx_src_data
    }
    
    if {$choose_fifo == 3 && $phy_ip == 2} {
    
    add_interface avalon_st_tx avalon_streaming end
    set_interface_property avalon_st_tx export_of eth_10g_mac.avalon_st_tx
    
    add_interface avalon_st_pause avalon_streaming end
    set_interface_property avalon_st_pause export_of eth_10g_mac.avalon_st_pause   
    
    add_interface avalon_st_rx avalon_streaming start
    set_interface_property avalon_st_rx export_of eth_10g_mac.avalon_st_rx
    
    add_interface xgmii_rx avalon_streaming end
    set_interface_property xgmii_rx export_of eth_loopback_composed.lb_rx_sink_data
    
    add_interface xgmii_tx avalon_streaming start
    set_interface_property xgmii_tx export_of eth_loopback_composed.lb_tx_src_data
    
 
    }
    
    
    #|#
    
    #|Composition for MDIO and 2-wire serial interface
    if {$choose_mdio_2_wire_serial_int == 0} {
	compose_mdio mm_clk_module.clk mm_clk_module.clk_reset altera_avalon_mm_bridge.avalon_universal_master_0 $mdio_mdc_divisor
    
	}
    #|#
    
    if { $stat_ena == 1 } {
        add_interface avalon_st_txstatus avalon_streaming start
        set_interface_property avalon_st_txstatus export_of eth_10g_mac.avalon_st_txstatus
    }
    
    if { $pfc_ena == 1 } {
        #  Export Avalon-ST PFC Generation Control TX
        add_interface avalon_st_tx_pfc_gen avalon_streaming end
        set_interface_property avalon_st_tx_pfc_gen export_of eth_10g_mac.avalon_st_tx_pfc_gen
        
        #  Export of PFC Status TX
        add_interface avalon_st_tx_pfc_status avalon_streaming start
        set_interface_property avalon_st_tx_pfc_status export_of eth_10g_mac.avalon_st_tx_pfc_status
        
        #  Export of PFC Pause Enable RX
        add_interface avalon_st_rx_pfc_pause avalon_streaming start
        set_interface_property avalon_st_rx_pfc_pause export_of eth_10g_mac.avalon_st_rx_pfc_pause
        
        #  Export of PFC Status RX
        add_interface avalon_st_rx_pfc_status avalon_streaming start
        set_interface_property avalon_st_rx_pfc_status export_of eth_10g_mac.avalon_st_rx_pfc_status
    }
	


}

proc compose_eth_and_loopback {tx_clk_src tx_reset_src rx_clk_src rx_reset_src csr_clk_src csr_reset_src csr_connection supp_addr_ena stat_ena reg_stat crc_tx preamble_mode pfc_ena pfc_priority_num timestamp_ena ptp_1step_ena tstamp_fp_width mac_1g10g_ena} {
    # MAC
    add_instance eth_10g_mac altera_eth_10g_mac
    set_instance_parameter eth_10g_mac DATAPATH_OPTION "3"
    set_instance_parameter eth_10g_mac ENABLE_SUPP_ADDR $supp_addr_ena
    set_instance_parameter eth_10g_mac INSTANTIATE_STATISTICS $stat_ena
    set_instance_parameter eth_10g_mac REGISTER_BASED_STATISTICS $reg_stat
    set_instance_parameter eth_10g_mac INSTANTIATE_TX_CRC $crc_tx
    set_instance_parameter eth_10g_mac PREAMBLE_PASSTHROUGH $preamble_mode
    set_instance_parameter eth_10g_mac ENABLE_PFC $pfc_ena
    set_instance_parameter eth_10g_mac PFC_PRIORITY_NUM $pfc_priority_num
	set_instance_parameter eth_10g_mac ENABLE_TIMESTAMPING $timestamp_ena
	set_instance_parameter eth_10g_mac ENABLE_PTP_1STEP $ptp_1step_ena
	set_instance_parameter eth_10g_mac TSTAMP_FP_WIDTH $tstamp_fp_width
    set_instance_parameter eth_10g_mac ENABLE_1G10G_MAC $mac_1g10g_ena
    
    if {$mac_1g10g_ena == 1 || $mac_1g10g_ena == 2} {
    add_interface speed_sel conduit end
    set_interface_property speed_sel export_of eth_10g_mac.speed_sel    
    set_interface_property speed_sel PORT_NAME_MAP "speed_sel din"
    
    add_interface gmii_tx_clk clock end
    set_interface_property gmii_tx_clk export_of eth_10g_mac.gmii_tx_clk
    
    add_interface gmii_tx_d conduit start
    set_interface_property gmii_tx_d export_of eth_10g_mac.gmii_tx_d    
    set_interface_property gmii_tx_d PORT_NAME_MAP "gmii_tx_d gmii_source_data"    
    
    add_interface gmii_tx_err conduit start
    set_interface_property gmii_tx_err export_of eth_10g_mac.gmii_tx_err   
    set_interface_property gmii_tx_err PORT_NAME_MAP "gmii_tx_err gmii_source_error"
    
    add_interface gmii_tx_en conduit start
    set_interface_property gmii_tx_en export_of eth_10g_mac.gmii_tx_en   
    set_interface_property gmii_tx_en PORT_NAME_MAP "gmii_tx_en gmii_source_control"
    
    add_interface gmii_rx_clk clock end
    set_interface_property gmii_rx_clk export_of eth_10g_mac.gmii_rx_clk 
    
    add_interface gmii_rx_d conduit end
    set_interface_property gmii_rx_d export_of eth_10g_mac.gmii_rx_d 
    set_interface_property gmii_rx_d PORT_NAME_MAP "gmii_rx_d gmii_sink_data"
    
    add_interface gmii_rx_err conduit end
    set_interface_property gmii_rx_err export_of eth_10g_mac.gmii_rx_err 
    set_interface_property gmii_rx_err PORT_NAME_MAP "gmii_rx_err gmii_sink_error"
    
    add_interface gmii_rx_dv conduit end
    set_interface_property gmii_rx_dv export_of eth_10g_mac.gmii_rx_dv   
    set_interface_property gmii_rx_dv PORT_NAME_MAP "gmii_rx_dv gmii_sink_control"
    
    }
    if {$mac_1g10g_ena == 2} {
    add_interface mii_tx_d conduit start
    set_interface_property mii_tx_d export_of eth_10g_mac.mii_tx_d   
    
    add_interface mii_tx_err conduit start
    set_interface_property mii_tx_err export_of eth_10g_mac.mii_tx_err   
    
    add_interface mii_tx_en conduit start
    set_interface_property mii_tx_en export_of eth_10g_mac.mii_tx_en   
    
    add_interface mii_rx_d conduit start
    set_interface_property mii_rx_d export_of eth_10g_mac.mii_rx_d   
    
    add_interface mii_rx_err conduit start
    set_interface_property mii_rx_err export_of eth_10g_mac.mii_rx_err   
    
    add_interface mii_rx_dv conduit start
    set_interface_property mii_rx_dv export_of eth_10g_mac.mii_rx_dv   
    
    add_interface tx_clkena conduit start
    set_interface_property tx_clkena export_of eth_10g_mac.tx_clkena   
    
    add_interface rx_clkena conduit start
    set_interface_property rx_clkena export_of eth_10g_mac.rx_clkena   

    add_interface tx_clkena_half_rate conduit start
    set_interface_property tx_clkena_half_rate export_of eth_10g_mac.tx_clkena_half_rate   
    
    add_interface rx_clkena_half_rate conduit start
    set_interface_property rx_clkena_half_rate export_of eth_10g_mac.rx_clkena_half_rate   
    }
	
	if { $timestamp_ena == 1} {
		# add_instance tx_tod altera_eth_1588_tod
		# set_instance_parameter tx_tod DEFAULT_NSEC_PERIOD "6"
		# set_instance_parameter tx_tod DEFAULT_FNSEC_PERIOD "0x6666"		
		
		# add_connection tx_tod.tod_src/eth_10g_mac.tx_time_of_day_10g
    
		# add_connection ${csr_clk_src}/tx_tod.clock_reset
		# add_connection ${csr_reset_src}/tx_tod.clock_reset_reset
		# add_connection ${tx_clk_src}/tx_tod.period_clock
		# add_connection ${tx_reset_src}/tx_tod.period_clock_reset
		

		# add_connection ${csr_connection}/tx_tod.avalom_mm_csr
		# set_connection_parameter_value ${csr_connection}/tx_tod.avalom_mm_csr arbitrationPriority "1"
		# set_connection_parameter_value ${csr_connection}/tx_tod.avalom_mm_csr baseAddress "0x11000"	

		# add_instance rx_tod altera_eth_1588_tod
		# set_instance_parameter rx_tod DEFAULT_NSEC_PERIOD "6"
		# set_instance_parameter rx_tod DEFAULT_FNSEC_PERIOD "0x6666"		
		
		# add_connection rx_tod.tod_src/eth_10g_mac.rx_time_of_day_10g
		
		# add_connection ${csr_clk_src}/rx_tod.clock_reset
		# add_connection ${csr_reset_src}/rx_tod.clock_reset_reset
		# add_connection ${rx_clk_src}/rx_tod.period_clock
		# add_connection ${rx_reset_src}/rx_tod.period_clock_reset
		

		# add_connection ${csr_connection}/rx_tod.avalom_mm_csr
		# set_connection_parameter_value ${csr_connection}/rx_tod.avalom_mm_csr arbitrationPriority "1"
		# set_connection_parameter_value ${csr_connection}/rx_tod.avalom_mm_csr baseAddress "0x12000"		
        
        add_interface tx_time_of_day_96b_10g conduit end
        set_interface_property tx_time_of_day_96b_10g export_of eth_10g_mac.tx_time_of_day_96b_10g
        
        add_interface tx_time_of_day_64b_10g conduit end
        set_interface_property tx_time_of_day_64b_10g export_of eth_10g_mac.tx_time_of_day_64b_10g
        
        add_interface rx_time_of_day_96b_10g conduit end
        set_interface_property rx_time_of_day_96b_10g export_of eth_10g_mac.rx_time_of_day_96b_10g
        
        add_interface rx_time_of_day_64b_10g conduit end
        set_interface_property rx_time_of_day_64b_10g export_of eth_10g_mac.rx_time_of_day_64b_10g
        
        if {$mac_1g10g_ena == 1 || $mac_1g10g_ena == 2} {
            add_interface tx_time_of_day_96b_1g conduit end
            set_interface_property tx_time_of_day_96b_1g export_of eth_10g_mac.tx_time_of_day_96b_1g
            
            add_interface tx_time_of_day_64b_1g conduit end
            set_interface_property tx_time_of_day_64b_1g export_of eth_10g_mac.tx_time_of_day_64b_1g
            
            add_interface rx_time_of_day_96b_1g conduit end
            set_interface_property rx_time_of_day_96b_1g export_of eth_10g_mac.rx_time_of_day_96b_1g
            
            add_interface rx_time_of_day_64b_1g conduit end
            set_interface_property rx_time_of_day_64b_1g export_of eth_10g_mac.rx_time_of_day_64b_1g
        }
	}

    
    add_instance eth_loopback_composed altera_eth_loopback_composed
    
    add_connection ${tx_clk_src}/eth_10g_mac.tx_clk
    add_connection ${tx_clk_src}/eth_loopback_composed.tx_clk
    add_connection ${tx_reset_src}/eth_10g_mac.tx_reset
    add_connection ${tx_reset_src}/eth_loopback_composed.tx_reset

    add_connection ${rx_clk_src}/eth_10g_mac.rx_clk
    add_connection ${rx_clk_src}/eth_loopback_composed.rx_clk
    add_connection ${rx_reset_src}/eth_10g_mac.rx_reset
    add_connection ${rx_reset_src}/eth_loopback_composed.rx_reset    
    
    add_connection ${csr_clk_src}/eth_10g_mac.csr_clk
    add_connection ${csr_clk_src}/eth_loopback_composed.csr_clk
    add_connection ${csr_reset_src}/eth_10g_mac.csr_reset
    add_connection ${csr_reset_src}/eth_loopback_composed.csr_reset    
    
    add_connection ${csr_connection}/eth_10g_mac.csr
    set_connection_parameter_value ${csr_connection}/eth_10g_mac.csr arbitrationPriority "1"
    set_connection_parameter_value ${csr_connection}/eth_10g_mac.csr baseAddress "0x0000"
    
    add_connection ${csr_connection}/eth_loopback_composed.csr
    set_connection_parameter_value ${csr_connection}/eth_loopback_composed.csr arbitrationPriority "1"
    set_connection_parameter_value ${csr_connection}/eth_loopback_composed.csr baseAddress "0x10200"
    
    add_connection eth_10g_mac.xgmii_tx/eth_loopback_composed.lb_tx_sink_data
    add_connection eth_loopback_composed.lb_rx_src_data/eth_10g_mac.xgmii_rx
    
    
    add_interface avalon_st_rxstatus avalon_streaming start
    set_interface_property avalon_st_rxstatus export_of eth_10g_mac.avalon_st_rxstatus
    
    add_interface link_fault_status_xgmii_rx avalon_streaming start
    set_interface_property link_fault_status_xgmii_rx export_of eth_10g_mac.link_fault_status_xgmii_rx
    
       
}

proc compose_mdio {csr_clk_src csr_reset_src csr_connection mdio_mdc_divisor} {

	add_instance eth_mdio altera_eth_mdio
	set_instance_parameter eth_mdio MDC_DIVISOR $mdio_mdc_divisor
	
	add_connection ${csr_clk_src}/eth_mdio.clock
    add_connection ${csr_reset_src}/eth_mdio.clock_reset
	
	add_connection ${csr_connection}/eth_mdio.csr
	set_connection_parameter_value ${csr_connection}/eth_mdio.csr arbitrationPriority "1"
	set_connection_parameter_value ${csr_connection}/eth_mdio.csr baseAddress "0x10000"
	
	add_interface mdio conduit end
	set_interface_property mdio export_of eth_mdio.mdio
}

proc compose_sc_fifo {sync_tx_fifo_depth sync_tx_fifo_error_width sync_tx_use_store_and_forward tx_clk_src  tx_reset_src csr_clk_src csr_connection sync_rx_fifo_depth sync_rx_fifo_error_width sync_rx_use_store_and_forward rx_clk_src rx_reset_src sync_tx_use_almost_full sync_tx_use_almost_empty} {
	
	#| transmit path
	add_instance tx_sc_fifo altera_avalon_sc_fifo
	set_instance_parameter tx_sc_fifo SYMBOLS_PER_BEAT "8"
	set_instance_parameter tx_sc_fifo BITS_PER_SYMBOL "8"
	set_instance_parameter tx_sc_fifo FIFO_DEPTH ${sync_tx_fifo_depth}
	set_instance_parameter tx_sc_fifo CHANNEL_WIDTH "0"
	set_instance_parameter tx_sc_fifo ERROR_WIDTH ${sync_tx_fifo_error_width}
	set_instance_parameter tx_sc_fifo USE_PACKETS "1"
	set_instance_parameter tx_sc_fifo USE_FILL_LEVEL "1"
	set_instance_parameter tx_sc_fifo USE_STORE_FORWARD ${sync_tx_use_store_and_forward}
	set_instance_parameter tx_sc_fifo USE_ALMOST_FULL_IF "${sync_tx_use_almost_full}"
	set_instance_parameter tx_sc_fifo USE_ALMOST_EMPTY_IF "${sync_tx_use_almost_empty}"
	# finish intantiate transmit path|#
	
	#| receive path
	add_instance rx_sc_fifo altera_avalon_sc_fifo
	set_instance_parameter rx_sc_fifo SYMBOLS_PER_BEAT "8"
	set_instance_parameter rx_sc_fifo BITS_PER_SYMBOL "8"
	set_instance_parameter rx_sc_fifo FIFO_DEPTH ${sync_rx_fifo_depth}
	set_instance_parameter rx_sc_fifo CHANNEL_WIDTH "0"
	set_instance_parameter rx_sc_fifo ERROR_WIDTH ${sync_rx_fifo_error_width}
	set_instance_parameter rx_sc_fifo USE_PACKETS "1"
	set_instance_parameter rx_sc_fifo USE_FILL_LEVEL "1"
	set_instance_parameter rx_sc_fifo USE_STORE_FORWARD ${sync_rx_use_store_and_forward}
	set_instance_parameter rx_sc_fifo USE_ALMOST_FULL_IF "1"
	set_instance_parameter rx_sc_fifo USE_ALMOST_EMPTY_IF "1"
	
	# finish instantiate receive path |#
	
	# Connection transmit path
	
	add_connection ${tx_clk_src}/tx_sc_fifo.clk
    add_connection ${tx_reset_src}/tx_sc_fifo.clk_reset
	add_connection ${csr_connection}/tx_sc_fifo.csr
	set_connection_parameter_value ${csr_connection}/tx_sc_fifo.csr arbitrationPriority "1"
	set_connection_parameter_value ${csr_connection}/tx_sc_fifo.csr baseAddress "0x10600"
	
	
	# finish connection of transmit path |#
	
	#| Connection of receive path
	
	add_connection ${rx_clk_src}/rx_sc_fifo.clk
    add_connection ${rx_reset_src}/rx_sc_fifo.clk_reset
	add_connection ${csr_connection}/rx_sc_fifo.csr
	set_connection_parameter_value ${csr_connection}/rx_sc_fifo.csr arbitrationPriority "1"
	set_connection_parameter_value ${csr_connection}/rx_sc_fifo.csr baseAddress "0x10400"
	
    
    #DC FIFO to clock cross pause control adapter 
    add_instance dc_fifo_pause_adapt_pause_gen altera_avalon_dc_fifo
    set_instance_parameter dc_fifo_pause_adapt_pause_gen SYMBOLS_PER_BEAT "1"
    set_instance_parameter dc_fifo_pause_adapt_pause_gen BITS_PER_SYMBOL "2"
    set_instance_parameter dc_fifo_pause_adapt_pause_gen FIFO_DEPTH "16"
    set_instance_parameter dc_fifo_pause_adapt_pause_gen CHANNEL_WIDTH "0"
    set_instance_parameter dc_fifo_pause_adapt_pause_gen ERROR_WIDTH "0"
    set_instance_parameter dc_fifo_pause_adapt_pause_gen USE_PACKETS "0"
    set_instance_parameter dc_fifo_pause_adapt_pause_gen USE_IN_FILL_LEVEL "0"
    set_instance_parameter dc_fifo_pause_adapt_pause_gen USE_OUT_FILL_LEVEL "0"
    set_instance_parameter dc_fifo_pause_adapt_pause_gen WR_SYNC_DEPTH "2"
    set_instance_parameter dc_fifo_pause_adapt_pause_gen RD_SYNC_DEPTH "2"
    set_instance_parameter dc_fifo_pause_adapt_pause_gen ENABLE_EXPLICIT_MAXCHANNEL "false"
    set_instance_parameter dc_fifo_pause_adapt_pause_gen EXPLICIT_MAXCHANNEL "0"
    
    add_instance pa_pg_before_timing_adapter timing_adapter
    set_instance_parameter pa_pg_before_timing_adapter generationLanguage "VERILOG"
    set_instance_parameter pa_pg_before_timing_adapter inBitsPerSymbol "2"
    set_instance_parameter pa_pg_before_timing_adapter inChannelWidth "0"
    set_instance_parameter pa_pg_before_timing_adapter inErrorDescriptor ""
    set_instance_parameter pa_pg_before_timing_adapter inErrorWidth "0"
    set_instance_parameter pa_pg_before_timing_adapter inMaxChannel "0"
    set_instance_parameter pa_pg_before_timing_adapter inReadyLatency "0"
    set_instance_parameter pa_pg_before_timing_adapter inSymbolsPerBeat "1"
    set_instance_parameter pa_pg_before_timing_adapter inUseEmpty "false"
    set_instance_parameter pa_pg_before_timing_adapter inUseEmptyPort "NO"
    set_instance_parameter pa_pg_before_timing_adapter inUsePackets "false"
    set_instance_parameter pa_pg_before_timing_adapter inUseReady "false"
    set_instance_parameter pa_pg_before_timing_adapter inUseValid "false"
    set_instance_parameter pa_pg_before_timing_adapter moduleName "pa_pg_before_timing_adapter"
    set_instance_parameter pa_pg_before_timing_adapter outReadyLatency "0"
    set_instance_parameter pa_pg_before_timing_adapter outUseReady "true"
    set_instance_parameter pa_pg_before_timing_adapter outUseValid "true"
    
    add_instance pa_pg_after_timing_adapter timing_adapter
    set_instance_parameter pa_pg_after_timing_adapter generationLanguage "VERILOG"
    set_instance_parameter pa_pg_after_timing_adapter inBitsPerSymbol "2"
    set_instance_parameter pa_pg_after_timing_adapter inChannelWidth "0"
    set_instance_parameter pa_pg_after_timing_adapter inErrorDescriptor ""
    set_instance_parameter pa_pg_after_timing_adapter inErrorWidth "0"
    set_instance_parameter pa_pg_after_timing_adapter inMaxChannel "0"
    set_instance_parameter pa_pg_after_timing_adapter inReadyLatency "0"
    set_instance_parameter pa_pg_after_timing_adapter inSymbolsPerBeat "1"
    set_instance_parameter pa_pg_after_timing_adapter inUseEmpty "false"
    set_instance_parameter pa_pg_after_timing_adapter inUseEmptyPort "NO"
    set_instance_parameter pa_pg_after_timing_adapter inUsePackets "false"
    set_instance_parameter pa_pg_after_timing_adapter inUseReady "true"
    set_instance_parameter pa_pg_after_timing_adapter inUseValid "true"
    set_instance_parameter pa_pg_after_timing_adapter moduleName "pa_pg_after_timing_adapter"
    set_instance_parameter pa_pg_after_timing_adapter outReadyLatency "0"
    set_instance_parameter pa_pg_after_timing_adapter outUseReady "false"
    set_instance_parameter pa_pg_after_timing_adapter outUseValid "false"
    
    
    add_connection ${rx_clk_src}/dc_fifo_pause_adapt_pause_gen.in_clk
    add_connection ${rx_reset_src}/dc_fifo_pause_adapt_pause_gen.in_clk_reset
    
    add_connection ${tx_clk_src}/dc_fifo_pause_adapt_pause_gen.out_clk
    add_connection ${tx_reset_src}/dc_fifo_pause_adapt_pause_gen.out_clk_reset
	
	add_instance eth_fifo_pause_ctrl_adapter altera_eth_fifo_pause_ctrl_adapter
	add_connection ${rx_clk_src}/eth_fifo_pause_ctrl_adapter.clock
    add_connection ${rx_reset_src}/eth_fifo_pause_ctrl_adapter.clock_reset
	
	add_connection rx_sc_fifo.almost_full/eth_fifo_pause_ctrl_adapter.avalon_streaming_sink_almost_full
	add_connection rx_sc_fifo.almost_empty/eth_fifo_pause_ctrl_adapter.avalon_streaming_sink_almost_empty
    
    add_connection ${rx_clk_src}/pa_pg_before_timing_adapter.clk
    add_connection ${rx_reset_src}/pa_pg_before_timing_adapter.reset
    add_connection ${tx_clk_src}/pa_pg_after_timing_adapter.clk
    add_connection ${tx_reset_src}/pa_pg_after_timing_adapter.reset
    
    add_connection eth_fifo_pause_ctrl_adapter.avalon_streaming_source/pa_pg_before_timing_adapter.in
    add_connection pa_pg_before_timing_adapter.out/dc_fifo_pause_adapt_pause_gen.in
    add_connection dc_fifo_pause_adapt_pause_gen.out/pa_pg_after_timing_adapter.in
    add_connection pa_pg_after_timing_adapter.out/eth_10g_mac.avalon_st_pause
	
	if {$sync_tx_use_almost_full == 1} {
    
    add_interface tx_ff_almost_full avalon_streaming start
    set_interface_property tx_ff_almost_full export_of tx_sc_fifo.almost_full
    }
    if {$sync_tx_use_almost_empty == 1} {
    
    add_interface tx_ff_almost_empty avalon_streaming start
    set_interface_property tx_ff_almost_empty export_of tx_sc_fifo.almost_empty
    }
	
}

proc compose_dc_fifo {async_tx_fifo_depth async_tx_fifo_error_width async_rx_fifo_depth async_rx_fifo_error_width tx_clk_src tx_reset_src rx_clk_src rx_reset_src dc_tx_clk dc_tx_reset dc_rx_clk dc_rx_reset} {

	#| transmit path
	add_instance tx_dc_fifo altera_avalon_dc_fifo
	set_instance_parameter tx_dc_fifo SYMBOLS_PER_BEAT "8"
	set_instance_parameter tx_dc_fifo BITS_PER_SYMBOL "8"
	set_instance_parameter tx_dc_fifo FIFO_DEPTH ${async_tx_fifo_depth}
	set_instance_parameter tx_dc_fifo CHANNEL_WIDTH "0"
	set_instance_parameter tx_dc_fifo ERROR_WIDTH ${async_tx_fifo_error_width}
	set_instance_parameter tx_dc_fifo USE_PACKETS "1"
	set_instance_parameter tx_dc_fifo USE_IN_FILL_LEVEL "0"
	set_instance_parameter tx_dc_fifo USE_OUT_FILL_LEVEL "0"
	# finish transmit path |#
	
	#| Receive path
	add_instance rx_dc_fifo altera_avalon_dc_fifo
	set_instance_parameter rx_dc_fifo SYMBOLS_PER_BEAT "8"
	set_instance_parameter rx_dc_fifo BITS_PER_SYMBOL "8"
	set_instance_parameter rx_dc_fifo FIFO_DEPTH ${async_rx_fifo_depth}
	set_instance_parameter rx_dc_fifo CHANNEL_WIDTH "0"
	set_instance_parameter rx_dc_fifo ERROR_WIDTH ${async_rx_fifo_error_width}
	set_instance_parameter rx_dc_fifo USE_PACKETS "1"
	set_instance_parameter rx_dc_fifo USE_IN_FILL_LEVEL "0"
	set_instance_parameter rx_dc_fifo USE_OUT_FILL_LEVEL "0"
	# finish receive path |#
	
	# Connection transmit path
	add_connection ${tx_clk_src}/tx_dc_fifo.out_clk
    add_connection ${tx_reset_src}/tx_dc_fifo.out_clk_reset
	add_connection ${dc_tx_clk}/tx_dc_fifo.in_clk
    add_connection ${dc_tx_reset}/tx_dc_fifo.in_clk_reset

	
	add_connection ${dc_rx_clk}/rx_dc_fifo.out_clk 
    add_connection ${dc_rx_reset}/rx_dc_fifo.out_clk_reset 
	add_connection ${rx_clk_src}/rx_dc_fifo.in_clk
    add_connection ${rx_reset_src}/rx_dc_fifo.in_clk_reset
	

}

proc compose_dc_sc_fifo {async_tx_fifo_depth async_tx_fifo_error_width async_rx_fifo_depth async_rx_fifo_error_width tx_clk_src tx_reset_src rx_clk_src rx_reset_src dc_tx_clk dc_tx_reset dc_rx_clk dc_rx_reset sync_tx_fifo_depth sync_tx_fifo_error_width sync_tx_use_store_and_forward csr_clk_src csr_connection sync_rx_fifo_depth sync_rx_fifo_error_width sync_rx_use_store_and_forward sync_tx_use_almost_full sync_tx_use_almost_empty} {

    compose_dc_fifo $async_tx_fifo_depth $async_tx_fifo_error_width $async_rx_fifo_depth $async_rx_fifo_error_width $tx_clk_src $tx_reset_src $rx_clk_src $rx_reset_src $dc_tx_clk $dc_tx_reset $dc_rx_clk $dc_rx_reset
    
    compose_sc_fifo $sync_tx_fifo_depth $sync_tx_fifo_error_width $sync_tx_use_store_and_forward $tx_clk_src  $tx_reset_src $csr_clk_src $csr_connection $sync_rx_fifo_depth $sync_rx_fifo_error_width $sync_rx_use_store_and_forward $rx_clk_src $rx_reset_src $sync_tx_use_almost_full $sync_tx_use_almost_empty
    
    add_connection tx_dc_fifo.out/tx_sc_fifo.in
    add_connection rx_sc_fifo.out/rx_dc_fifo.in
    
}

proc compose_baser {ENABLE_TIMESTAMPING BASER_PLL_TYPE BASER_STARTING_CHANNEL_NUMBER BASER_REF_CLK_FREQ BASER_TRANSMITTER_TERMINATION BASER_PRE_EMPHASIS_PRE_TAP BASER_PRE_EMPHASIS_PRE_TAP_POLARITY BASER_PRE_EMPHASIS_FIRST_POST_TAP BASER_PRE_EMPHASIS_SECOND_POST_TAP BASER_PRE_EMPHASIS_SECOND_POST_TAP_POLARITY BASER_TRANSMITTER_VOD BASER_RECEIVER_TERMINATION BASER_RECEIVER_DC_GAIN BASER_RECEIVER_STATIC_EQUALIZER BASER_EXT_PMA_CONTROL_CONF BASER_ENA_ADD_CONTROL_STAT BASER_RECOVERED_CLK_OUT tx_clk_src ref_clk_src csr_clk_src csr_reset_src csr_connection} {

    add_instance altera_10gbaser altera_xcvr_10gbaser
    set_instance_parameter altera_10gbaser gui_pll_type ${BASER_PLL_TYPE}
    set_instance_parameter altera_10gbaser starting_channel_number ${BASER_STARTING_CHANNEL_NUMBER}
    set_instance_parameter altera_10gbaser ref_clk_freq ${BASER_REF_CLK_FREQ}
    set_instance_parameter altera_10gbaser external_pma_ctrl_config ${BASER_EXT_PMA_CONTROL_CONF}
    set_instance_parameter altera_10gbaser control_pin_out ${BASER_ENA_ADD_CONTROL_STAT}
    set_instance_parameter altera_10gbaser tx_termination ${BASER_TRANSMITTER_TERMINATION}
    set_instance_parameter altera_10gbaser tx_preemp_pretap ${BASER_PRE_EMPHASIS_PRE_TAP}
    set_instance_parameter altera_10gbaser tx_preemp_pretap_inv ${BASER_PRE_EMPHASIS_PRE_TAP_POLARITY}
    set_instance_parameter altera_10gbaser tx_preemp_tap_1 ${BASER_PRE_EMPHASIS_FIRST_POST_TAP}
    set_instance_parameter altera_10gbaser tx_preemp_tap_2 ${BASER_PRE_EMPHASIS_SECOND_POST_TAP}
    set_instance_parameter altera_10gbaser tx_preemp_tap_2_inv ${BASER_PRE_EMPHASIS_SECOND_POST_TAP_POLARITY}
    set_instance_parameter altera_10gbaser tx_vod_selection ${BASER_TRANSMITTER_VOD}
    set_instance_parameter altera_10gbaser rx_termination ${BASER_RECEIVER_TERMINATION}
    set_instance_parameter altera_10gbaser rx_eq_dc_gain ${BASER_RECEIVER_DC_GAIN}
    set_instance_parameter altera_10gbaser rx_eq_ctrl ${BASER_RECEIVER_STATIC_EQUALIZER}
    set_instance_parameter altera_10gbaser recovered_clk_out ${BASER_RECOVERED_CLK_OUT}
    if {$ENABLE_TIMESTAMPING == 1} {
        set_instance_parameter altera_10gbaser latadj 1        
    }
       
    add_connection ${tx_clk_src}/altera_10gbaser.xgmii_tx_clk
        
    add_interface xgmii_rx_clk clock start
    set_interface_property xgmii_rx_clk export_of altera_10gbaser.xgmii_rx_clk
    
    add_connection ${csr_clk_src}/altera_10gbaser.phy_mgmt_clk
    add_connection ${csr_reset_src}/altera_10gbaser.phy_mgmt_clk_reset
    add_connection ${ref_clk_src}/altera_10gbaser.pll_ref_clk
    
    add_connection ${csr_connection}/altera_10gbaser.phy_mgmt
	set_connection_parameter_value ${csr_connection}/altera_10gbaser.phy_mgmt arbitrationPriority "1"
	set_connection_parameter_value ${csr_connection}/altera_10gbaser.phy_mgmt baseAddress "0x040000"
    
    
    if {[get_device_type] == "Stratix IV"} {
    
        if {$BASER_EXT_PMA_CONTROL_CONF == 1 } {
                   
        add_interface reconfig_to_xcvr conduit end
        set_interface_property reconfig_to_xcvr export_of altera_10gbaser.reconfig_to_xcvr
    
        add_interface reconfig_from_xcvr conduit start
        set_interface_property reconfig_from_xcvr export_of altera_10gbaser.reconfig_from_xcvr
        
        add_interface gxb_pdn conduit end
        set_interface_property gxb_pdn export_of altera_10gbaser.gxb_pdn
    
        add_interface pll_locked conduit start
        set_interface_property pll_locked export_of altera_10gbaser.pll_locked
        
        add_interface pll_pdn conduit end
        set_interface_property pll_pdn export_of altera_10gbaser.pll_pdn
        
        add_interface cal_blk_pdn conduit end
        set_interface_property cal_blk_pdn export_of altera_10gbaser.cal_blk_pdn
        
        add_interface cal_blk_clk clock end
        set_interface_property cal_blk_clk export_of altera_10gbaser.cal_blk_clk
        
        }
    } else {

        add_interface reconfig_to_xcvr conduit end
        set_interface_property reconfig_to_xcvr export_of altera_10gbaser.reconfig_to_xcvr
    
        add_interface reconfig_from_xcvr conduit start
        set_interface_property reconfig_from_xcvr export_of altera_10gbaser.reconfig_from_xcvr

        
    }    
    
    
    if {$BASER_ENA_ADD_CONTROL_STAT == 1} {
            
    add_interface rx_block_lock conduit start
    set_interface_property rx_block_lock export_of altera_10gbaser.rx_block_lock
    
    add_interface rx_hi_ber conduit start
    set_interface_property rx_hi_ber export_of altera_10gbaser.rx_hi_ber
    
    }
    
    if {$BASER_RECOVERED_CLK_OUT == 1} {
    add_interface rx_recovered_clk clock start
    set_interface_property rx_recovered_clk export_of altera_10gbaser.rx_recovered_clk
    
    }
    

}

proc compose_xaui {XAUI_STARTING_CHANNEL_NUMBER interface_type tx_termination tx_vod_selection tx_preemp_pretap tx_preemp_pretap_inv tx_preemp_tap_1 tx_preemp_tap_2 tx_preemp_tap_2_inv rx_common_mode rx_termination rx_eq_dc_gain rx_eq_ctrl gui_pll_type use_control_and_status_ports external_pma_ctrl_reconf recovered_clk_out tx_clk_src ref_clk_src csr_clk_src csr_reset_src csr_connection} {

    add_instance xaui altera_xcvr_xaui
    set_instance_parameter xaui starting_channel_number ${XAUI_STARTING_CHANNEL_NUMBER}
    set_instance_parameter xaui interface_type ${interface_type}
    set_instance_parameter xaui gui_pll_type ${gui_pll_type}
    set_instance_parameter xaui use_control_and_status_ports ${use_control_and_status_ports}
    set_instance_parameter xaui external_pma_ctrl_reconf ${external_pma_ctrl_reconf}
    set_instance_parameter xaui tx_termination ${tx_termination}
    set_instance_parameter xaui tx_vod_selection ${tx_vod_selection}
    set_instance_parameter xaui tx_preemp_pretap ${tx_preemp_pretap}
    set_instance_parameter xaui tx_preemp_pretap_inv ${tx_preemp_pretap_inv}
    set_instance_parameter xaui tx_preemp_tap_1 ${tx_preemp_tap_1}
    set_instance_parameter xaui tx_preemp_tap_2 ${tx_preemp_tap_2}
    set_instance_parameter xaui tx_preemp_tap_2_inv ${tx_preemp_tap_2_inv}
    set_instance_parameter xaui rx_common_mode ${rx_common_mode}
    set_instance_parameter xaui rx_termination ${rx_termination}
    set_instance_parameter xaui rx_eq_dc_gain ${rx_eq_dc_gain}
    set_instance_parameter xaui rx_eq_ctrl ${rx_eq_ctrl}
    set_instance_parameter xaui recovered_clk_out ${recovered_clk_out}
    
    add_connection ${tx_clk_src}/xaui.xgmii_tx_clk

    add_interface xgmii_rx_clk clock start
    set_interface_property xgmii_rx_clk export_of xaui.xgmii_rx_clk
    
    
    add_connection ${csr_clk_src}/xaui.phy_mgmt_clk
    add_connection ${csr_reset_src}/xaui.phy_mgmt_clk_reset
    add_connection ${ref_clk_src}/xaui.pll_ref_clk
    
    
        # Add additional ports when control and status port is enable
        if {$use_control_and_status_ports == 1} {
        add_interface rx_digitalreset avalon_streaming end
        set_interface_property rx_digitalreset export_of xaui.rx_digitalreset
        
        add_interface tx_digitalreset avalon_streaming end
        set_interface_property tx_digitalreset export_of xaui.tx_digitalreset
        
        add_interface rx_channelaligned avalon_streaming start
        set_interface_property rx_channelaligned export_of xaui.rx_channelaligned
        
        add_interface rx_syncstatus avalon_streaming start
        set_interface_property rx_syncstatus export_of xaui.rx_syncstatus
        
        add_interface rx_disperr avalon_streaming start
        set_interface_property rx_disperr export_of xaui.rx_disperr
        
        add_interface rx_errdetect avalon_streaming start
        set_interface_property rx_errdetect export_of xaui.rx_errdetect
        
            if {$interface_type == "Hard XAUI"} {
            add_interface rx_analogreset avalon_streaming end
            set_interface_property rx_analogreset export_of xaui.rx_analogreset
            
            add_interface rx_invpolarity avalon_streaming end
            set_interface_property rx_invpolarity export_of xaui.rx_invpolarity
            
            add_interface rx_set_locktodata avalon_streaming end
            set_interface_property rx_set_locktodata export_of xaui.rx_set_locktodata
            
            add_interface rx_set_locktoref avalon_streaming end
            set_interface_property rx_set_locktoref export_of xaui.rx_set_locktoref
            
            add_interface rx_seriallpbken avalon_streaming end
            set_interface_property rx_seriallpbken export_of xaui.rx_seriallpbken
            
            add_interface tx_invpolarity avalon_streaming end
            set_interface_property tx_invpolarity export_of xaui.tx_invpolarity            
            
            add_interface rx_is_lockedtodata avalon_streaming start
            set_interface_property rx_is_lockedtodata export_of xaui.rx_is_lockedtodata     

            add_interface rx_phase_comp_fifo_error avalon_streaming start
            set_interface_property rx_phase_comp_fifo_error export_of xaui.rx_phase_comp_fifo_error       

            add_interface rx_is_lockedtoref avalon_streaming start
            set_interface_property rx_is_lockedtoref export_of xaui.rx_is_lockedtoref
            
            add_interface rx_rlv avalon_streaming start
            set_interface_property rx_rlv export_of xaui.rx_rlv
            
            add_interface rx_rmfifoempty avalon_streaming start
            set_interface_property rx_rmfifoempty export_of xaui.rx_rmfifoempty            

            add_interface rx_rmfifofull avalon_streaming start
            set_interface_property rx_rmfifofull export_of xaui.rx_rmfifofull
            
            add_interface tx_phase_comp_fifo_error avalon_streaming start
            set_interface_property tx_phase_comp_fifo_error export_of xaui.tx_phase_comp_fifo_error 
            
            add_interface rx_patterndetect avalon_streaming start
            set_interface_property rx_patterndetect export_of xaui.rx_patterndetect
            
            add_interface rx_rmfifodatadeleted avalon_streaming start
            set_interface_property rx_rmfifodatadeleted export_of xaui.rx_rmfifodatadeleted

            add_interface rx_rmfifodatainserted avalon_streaming start
            set_interface_property rx_rmfifodatainserted export_of xaui.rx_rmfifodatainserted

            add_interface rx_runningdisp avalon_streaming start
            set_interface_property rx_runningdisp export_of xaui.rx_runningdisp            
            }        
        }
        
        # Reconfig ports is added with condition. For SV reconfig ports will be always exposed
        
        if {[get_device_type] == "Stratix V" || [get_device_type] == "Arria V" || [get_device_type] == "Cyclone V"|| [get_device_type] == "Arria V GZ"} {
        
        add_interface reconfig_from_xcvr avalon_streaming start
        set_interface_property reconfig_from_xcvr export_of xaui.reconfig_from_xcvr

        add_interface reconfig_to_xcvr avalon_streaming end
        set_interface_property reconfig_to_xcvr export_of xaui.reconfig_to_xcvr          
        
        } 
        
        if {$external_pma_ctrl_reconf == 1} {
        add_interface cal_blk_powerdown avalon_streaming end
        set_interface_property cal_blk_powerdown export_of xaui.cal_blk_powerdown           
        
        add_interface pll_powerdown avalon_streaming end
        set_interface_property pll_powerdown export_of xaui.pll_powerdown

        add_interface gxb_powerdown avalon_streaming end
        set_interface_property gxb_powerdown export_of xaui.gxb_powerdown

        add_interface pll_locked avalon_streaming start
        set_interface_property pll_locked export_of xaui.pll_locked
        
            if {[get_device_type] != "Stratix V" || [get_device_type] != "Cyclone IV GX"} {
            
            add_interface reconfig_from_xcvr avalon_streaming start
            set_interface_property reconfig_from_xcvr export_of xaui.reconfig_from_xcvr

            add_interface reconfig_to_xcvr avalon_streaming end
            set_interface_property reconfig_to_xcvr export_of xaui.reconfig_to_xcvr  
        
            }
      
        }
        
        if {$recovered_clk_out == 1} {
        add_interface rx_recovered_clk clock start
        set_interface_property rx_recovered_clk export_of xaui.rx_recovered_clk
        
        }
    
    add_connection ${csr_connection}/xaui.phy_mgmt
	set_connection_parameter_value ${csr_connection}/xaui.phy_mgmt arbitrationPriority "1"
	set_connection_parameter_value ${csr_connection}/xaui.phy_mgmt baseAddress "0x040000"

}


proc get_device_type {} {
    set device_family_top [get_parameter_value DEVICE_FAMILY_TOP]

    return $device_family_top;
}

proc _get_device_type {} {
    set device_family [get_parameter_value DEVICE_FAMILY_TOP]
    
    if {![string compare $device_family "Cyclone IV GX"]} {
        return 1;
    } elseif {![string compare $device_family "Arria GX"]} {
        return 1;
    } else {
        return 0;
    }
}



