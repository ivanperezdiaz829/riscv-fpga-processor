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


#==============================================================================
# Setup               
#==============================================================================
set_global_assignment -name DEVICE EP4SGX230KF40C2ES

#==============================================================================
# Pins Assignments                
#==============================================================================
set_location_assignment PIN_AA2 -to ref_clk
set_location_assignment PIN_AC34 -to clk_50Mhz
set_location_assignment PIN_AK35 -to reset_n
set_location_assignment PIN_AG2 -to xaui_rx_serial_export_to_the_xaui[3]
set_location_assignment PIN_AJ2 -to xaui_rx_serial_export_to_the_xaui[2]
set_location_assignment PIN_AR2 -to xaui_rx_serial_export_to_the_xaui[1]
set_location_assignment PIN_AU2 -to xaui_rx_serial_export_to_the_xaui[0]
set_location_assignment PIN_AF4 -to xaui_tx_serial_export_from_the_xaui[3]
set_location_assignment PIN_AH4 -to xaui_tx_serial_export_from_the_xaui[2]
set_location_assignment PIN_AP4 -to xaui_tx_serial_export_from_the_xaui[1]
set_location_assignment PIN_AT4 -to xaui_tx_serial_export_from_the_xaui[0]
set_location_assignment PIN_AU8 -to mdc_from_the_mdio
set_location_assignment PIN_AT8 -to mdio_in_out_from_the_mdio

#==============================================================================
# Set IO Standards                
#==============================================================================
set_global_assignment -name STRATIX_DEVICE_IO_STANDARD "2.5 V"
set_instance_assignment -name IO_STANDARD LVDS -to ref_clk
set_instance_assignment -name IO_STANDARD "2.5 V" -to reset_n
set_instance_assignment -name IO_STANDARD "1.4-V PCML" -to xaui_rx_serial_export_to_the_xaui[3]
set_instance_assignment -name IO_STANDARD "1.4-V PCML" -to xaui_rx_serial_export_to_the_xaui[2]
set_instance_assignment -name IO_STANDARD "1.4-V PCML" -to xaui_rx_serial_export_to_the_xaui[1]
set_instance_assignment -name IO_STANDARD "1.4-V PCML" -to xaui_rx_serial_export_to_the_xaui[0]
set_instance_assignment -name IO_STANDARD "1.4-V PCML" -to xaui_tx_serial_export_from_the_xaui[3]
set_instance_assignment -name IO_STANDARD "1.4-V PCML" -to xaui_tx_serial_export_from_the_xaui[2]
set_instance_assignment -name IO_STANDARD "1.4-V PCML" -to xaui_tx_serial_export_from_the_xaui[1]
set_instance_assignment -name IO_STANDARD "1.4-V PCML" -to xaui_tx_serial_export_from_the_xaui[0]

export_assignments

