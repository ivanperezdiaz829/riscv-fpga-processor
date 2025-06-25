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
# | $Header: //acds/rel/13.1/ip/altchip_id/source/altchip_id_hw.tcl#1 $
# | 
# +-----------------------------------

# request TCL package
package require -exact qsys 12.1

# Source files
source altchip_id_proc_hw.tcl

# +-----------------------------------
# | module Unique Chip ID
# +-----------------------------------
set_module_property NAME altchip_id
set_module_property VERSION 13.1
set_module_property DISPLAY_NAME "Altera Unique Chip ID"
set_module_property DESCRIPTION "The ALTCHIP_ID megafunction allows you to read the unique chip ID"
set_module_property GROUP "Configuration & Programming"
set_module_property INTERNAL false
set_module_property AUTHOR "Altera Corporation"
#set_module_property DATASHEET_URL "http://www.altera.com/literature/ug"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false
set_module_property HIDE_FROM_SOPC true

add_display_item "" "General" GROUP tab
add_display_item "" "Simulation" GROUP tab

# +-----------------------------------
# | Parameters - General tab
# +-----------------------------------
add_display_item "General" "Information" TEXT "Maximum frequency of clkin signal is 100MHz"

add_parameter DEVICE_FAMILY STRING
set_parameter_property DEVICE_FAMILY VISIBLE false
set_parameter_property DEVICE_FAMILY SYSTEM_INFO {DEVICE_FAMILY}
set_parameter_property DEVICE_FAMILY HDL_PARAMETER true

# +-----------------------------------
# | Parameters - Simulation tab
# +-----------------------------------
add_parameter ID_VALUE STD_LOGIC_VECTOR
set_parameter_property ID_VALUE WIDTH 64
set_parameter_property ID_VALUE DEFAULT_VALUE 0xffffffffffffffff
set_parameter_property ID_VALUE ALLOWED_RANGES {0x0000000000000000:0xffffffffffffffff}
set_parameter_property ID_VALUE DISPLAY_NAME "Please enter the desired Unique Chip ID in Hexadecimal for simulation:"
set_parameter_property ID_VALUE DESCRIPTION "Specifies the Unique Chip ID for simulation of ALTCHIP_ID"
set_parameter_property ID_VALUE DISPLAY_HINT "64-bit in Hexadecimal"
set_parameter_property ID_VALUE HDL_PARAMETER true
add_display_item "Simulation" ID_VALUE parameter 

add_display_item "Simulation" "Note" TEXT \
"NOTE: The actual Unique Chip ID needs to retrieve from device by running this Megafunction."

# +-----------------------------------
# | UI Interface
# +-----------------------------------
#clkin port
set CLKIN_INTERFACE "clkin"
add_interface $CLKIN_INTERFACE clock end
add_interface_port $CLKIN_INTERFACE $CLKIN_INTERFACE clk Input 1

#reset port
set RESET_INTERFACE "reset"
add_interface $RESET_INTERFACE reset end
set_interface_property $RESET_INTERFACE associatedClock clkin
add_interface_port $RESET_INTERFACE $RESET_INTERFACE reset Input 1

#output port - data_valid, chip_id
add_interface output avalon_streaming start
set_interface_property output associatedClock clkin
add_interface_port output "data_valid" valid Output 1
add_interface_port output "chip_id" data Output 64

set_module_property ELABORATION_CALLBACK elaboration_callback

# +-----------------------------------
# | Fileset Callbacks
# +----------------------------------- 
add_fileset quartus_synth QUARTUS_SYNTH generate_synth
set_fileset_property quartus_synth TOP_LEVEL altchip_id

#simulation
add_fileset sim_vhdl SIM_VHDL generate_vhdl_sim
set_fileset_property sim_vhdl TOP_LEVEL altchip_id

add_fileset sim_verilog SIM_VERILOG generate_verilog_sim
set_fileset_property sim_verilog TOP_LEVEL altchip_id