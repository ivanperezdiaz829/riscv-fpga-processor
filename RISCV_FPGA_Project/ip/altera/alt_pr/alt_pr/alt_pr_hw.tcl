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
# | $Header: //acds/rel/13.1/ip/alt_pr/alt_pr/alt_pr_hw.tcl#6 $
# | 
# +-----------------------------------

# request TCL package
package require -exact qsys 12.1

# Source files
source ./alt_pr_hw_proc.tcl

# +-----------------------------------
# | module Partial Reconfiguration
# +-----------------------------------
set_module_property NAME alt_pr
set_module_property VERSION 13.1
set_module_property DISPLAY_NAME "Partial Reconfiguration"
set_module_property DESCRIPTION "Partial Reconfiguration megafunction is used to reconfigure part of your design while the rest of your design continues to run."
set_module_property GROUP "Configuration & Programming"
set_module_property INTERNAL false
set_module_property AUTHOR "Altera Corporation"
set_module_property DATASHEET_URL "http://www.altera.com/literature/ug"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false
set_module_property HIDE_FROM_SOPC true

add_display_item "" "Settings" GROUP tab
add_display_item "" "General" GROUP tab

# +-----------------------------------
# | Parameters - Settings tab
# +-----------------------------------

# select Internal Host or External Host
add_parameter PR_INTERNAL_HOST boolean 1
set_parameter_property PR_INTERNAL_HOST DEFAULT_VALUE 1
set_parameter_property PR_INTERNAL_HOST DISPLAY_NAME "Use as PR Internal Host"
set_parameter_property PR_INTERNAL_HOST DESCRIPTION "Enable this option to use the PR megafunction as an Internal Host (i.e. both prblock and crcblock WYSIWYG are auto-instantiated as part of your design). Disable this option to use the PR megafunction as an External Host. You must connect additional interface signals to the dedicated PR pins or the external prblock and crcblock WYSIWYG interface signals if the PR megafunction is used as an External Host."
set_parameter_property PR_INTERNAL_HOST UNITS None
set_parameter_property PR_INTERNAL_HOST DISPLAY_HINT ""
set_parameter_property PR_INTERNAL_HOST AFFECTS_GENERATION true
set_parameter_property PR_INTERNAL_HOST AFFECTS_ELABORATION true
set_parameter_property PR_INTERNAL_HOST HDL_PARAMETER true
set_parameter_property PR_INTERNAL_HOST ENABLED true
add_display_item "Settings" PR_INTERNAL_HOST parameter

# select JTAG debug mode
add_parameter ENABLE_JTAG boolean 1
set_parameter_property ENABLE_JTAG DEFAULT_VALUE 1
set_parameter_property ENABLE_JTAG DISPLAY_NAME "Enable JTAG debug mode"
set_parameter_property ENABLE_JTAG DESCRIPTION "Enable this option to access the PR megafunction with the Programmer tool to perform Partial Reconfiguration."
set_parameter_property ENABLE_JTAG UNITS None
set_parameter_property ENABLE_JTAG DISPLAY_HINT ""
set_parameter_property ENABLE_JTAG AFFECTS_GENERATION true
set_parameter_property ENABLE_JTAG AFFECTS_ELABORATION true
set_parameter_property ENABLE_JTAG HDL_PARAMETER true
set_parameter_property ENABLE_JTAG ENABLED true
add_display_item "Settings" ENABLE_JTAG parameter

# select input data width
add_parameter DATA_WIDTH_INDEX INTEGER
set_parameter_property DATA_WIDTH_INDEX DEFAULT_VALUE 16
set_parameter_property DATA_WIDTH_INDEX DISPLAY_NAME "Input Data Width"
set_parameter_property DATA_WIDTH_INDEX DESCRIPTION "Size of the data interface in bits."
set_parameter_property DATA_WIDTH_INDEX TYPE INTEGER
set_parameter_property DATA_WIDTH_INDEX UNITS BITS
set_parameter_property DATA_WIDTH_INDEX AFFECTS_GENERATION true
set_parameter_property DATA_WIDTH_INDEX AFFECTS_ELABORATION true
set_parameter_property DATA_WIDTH_INDEX HDL_PARAMETER true
set_parameter_property DATA_WIDTH_INDEX ALLOWED_RANGES {1 2 4 8 16 32}
set_parameter_property DATA_WIDTH_INDEX ENABLED true
add_display_item "Settings" DATA_WIDTH_INDEX parameter 

# select CDRATIO
add_parameter CDRATIO INTEGER
set_parameter_property CDRATIO DEFAULT_VALUE 1
set_parameter_property CDRATIO DISPLAY_NAME "Clock-to-Data ratio"
set_parameter_property CDRATIO DESCRIPTION "Select 1 for plain PR data, 2 for encrypted PR data, or 4 for compressed PR data (with or without encryption)."
set_parameter_property CDRATIO TYPE INTEGER
set_parameter_property CDRATIO UNITS None
set_parameter_property CDRATIO AFFECTS_GENERATION true
set_parameter_property CDRATIO AFFECTS_ELABORATION true
set_parameter_property CDRATIO HDL_PARAMETER true
set_parameter_property CDRATIO ALLOWED_RANGES {1 2 4}
set_parameter_property CDRATIO ENABLED true
add_display_item "Settings" CDRATIO parameter 

# select edcrc osc divider
add_parameter EDCRC_OSC_DIVIDER INTEGER
set_parameter_property EDCRC_OSC_DIVIDER DEFAULT_VALUE 1
set_parameter_property EDCRC_OSC_DIVIDER DISPLAY_NAME "Divide error detection frequency by"
set_parameter_property EDCRC_OSC_DIVIDER DESCRIPTION "Specifies the divide value of the internal clock, which determines the frequency of the error detection CRC. The divide value must be a power of two. Refer to the device handbook to find the frequency of the internal clock for the selected device."
set_parameter_property EDCRC_OSC_DIVIDER TYPE INTEGER
set_parameter_property EDCRC_OSC_DIVIDER UNITS None
set_parameter_property EDCRC_OSC_DIVIDER AFFECTS_GENERATION true
set_parameter_property EDCRC_OSC_DIVIDER AFFECTS_ELABORATION true
set_parameter_property EDCRC_OSC_DIVIDER HDL_PARAMETER true
set_parameter_property EDCRC_OSC_DIVIDER ALLOWED_RANGES {1 2 4 8 16 32 64 128 256}
add_display_item "Settings" EDCRC_OSC_DIVIDER parameter 

# set UNIQUE_IDENTIFIER
add_parameter UNIQUE_IDENTIFIER INTEGER
set_parameter_property UNIQUE_IDENTIFIER DEFAULT_VALUE 2013
set_parameter_property UNIQUE_IDENTIFIER TYPE INTEGER
set_parameter_property UNIQUE_IDENTIFIER UNITS None
set_parameter_property UNIQUE_IDENTIFIER AFFECTS_GENERATION true
set_parameter_property UNIQUE_IDENTIFIER AFFECTS_ELABORATION true
set_parameter_property UNIQUE_IDENTIFIER HDL_PARAMETER true
set_parameter_property UNIQUE_IDENTIFIER ALLOWED_RANGES {0:2147483647}
set_parameter_property UNIQUE_IDENTIFIER VISIBLE false
set_parameter_property UNIQUE_IDENTIFIER DERIVED true


# +-----------------------------------
# | Parameters - General tab
# +-----------------------------------
add_display_item "General" "Information1" TEXT "The input clk signal should be constrained by the user with a maximum frequency of 100MHz."
add_display_item "General" "Information2" TEXT "The same clk frequency is applied to PR_CLK signal during Partial Reconfiguration operation."
add_display_item "General" "Information3" TEXT "User must supply the input clk signal to meet the device PR_CLK Fmax specification."

add_parameter DEVICE_FAMILY STRING
set_parameter_property DEVICE_FAMILY VISIBLE false
set_parameter_property DEVICE_FAMILY SYSTEM_INFO {DEVICE_FAMILY}
set_parameter_property DEVICE_FAMILY HDL_PARAMETER true


# +-----------------------------------
# | UI Interface
# +-----------------------------------

#clk port
set CLK_INTERFACE "clk"
add_interface $CLK_INTERFACE clock end
add_interface_port $CLK_INTERFACE $CLK_INTERFACE clk Input 1

#nreset port
set NRESET_INTERFACE "nreset"
add_interface $NRESET_INTERFACE reset end
set_interface_property $NRESET_INTERFACE associatedClock clk
add_interface_port $NRESET_INTERFACE $NRESET_INTERFACE reset Input 1


# +-----------------------------------
# | connection point - input
# | 
add_interface pr_start conduit end
add_interface_port pr_start pr_start pr_start Input 1
set_interface_property pr_start ENABLED true

add_interface double_pr conduit end
add_interface_port double_pr double_pr double_pr Input 1
set_interface_property double_pr ENABLED true

add_interface data_valid conduit end
add_interface_port data_valid data_valid data_valid Input 1
set_interface_property data_valid ENABLED true

add_interface data conduit end
add_interface_port data data data Input DATA_WIDTH_INDEX
set_interface_property data ENABLED true
# | 
# +-----------------------------------


# +-----------------------------------
# | connection point - output
# | 
add_interface freeze conduit start
add_interface_port freeze freeze freeze Output 1
set_interface_property freeze ENABLED true

add_interface data_read conduit start
add_interface_port data_read data_read data_read Output 1
set_interface_property data_read ENABLED true

add_interface status conduit start
add_interface_port status status status Output 2
set_interface_property status ENABLED true
# | 
# +-----------------------------------


# +-----------------------------------
# | connection point - dedicated input
# | 
add_interface pr_ready_pin conduit end
add_interface_port pr_ready_pin pr_ready_pin pr_ready_pin Input 1

add_interface pr_done_pin conduit end
add_interface_port pr_done_pin pr_done_pin pr_done_pin Input 1

add_interface pr_error_pin conduit end
add_interface_port pr_error_pin pr_error_pin pr_error_pin Input 1

add_interface crc_error_pin conduit end
add_interface_port crc_error_pin crc_error_pin crc_error_pin Input 1
# | 
# +-----------------------------------


# +-----------------------------------
# | connection point - dedicated output
# | 
add_interface pr_request_pin conduit start
add_interface_port pr_request_pin pr_request_pin pr_request_pin Output 1

add_interface pr_clk_pin conduit start
add_interface_port pr_clk_pin pr_clk_pin pr_clk_pin Output 1

add_interface pr_data_pin conduit start
add_interface_port pr_data_pin pr_data_pin pr_data_pin Output 16
# | 
# +-----------------------------------


set_module_property ELABORATION_CALLBACK elaboration_callback

# +-----------------------------------
# | Fileset Callbacks
# +----------------------------------- 
add_fileset quartus_synth QUARTUS_SYNTH generate_synth
set_fileset_property quartus_synth TOP_LEVEL alt_pr



