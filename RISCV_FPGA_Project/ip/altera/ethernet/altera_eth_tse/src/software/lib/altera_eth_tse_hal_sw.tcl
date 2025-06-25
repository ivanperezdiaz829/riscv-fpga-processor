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


#
# altera_eth_tse_hal_sw.tcl
#

# Create a new driver named "altera_eth_tse_driver"
create_driver altera_eth_tse_driver_hal

# Associate it with some hardware known as "altera_eth_tse"
set_sw_property hw_class_name altera_eth_tse

# The version of this driver
set_sw_property version 13.1

# This driver may be incompatible with versions of hardware less
# than specified below. Updates to hardware and device drivers
# rendering the driver incompatible with older versions of
# hardware are noted with this property assignment.
set_sw_property min_compatible_hw_version 13.0

# Initialize the driver in alt_sys_init()
set_sw_property auto_initialize true

# Location in generated BSP that above sources will be copied into
set_sw_property bsp_subdirectory drivers

# This driver supports the UCOSII BSP (OS) type
add_sw_property supported_bsp_type HAL

# Add preprocessor flag "-DALTERA_TRIPLE_SPEED_MAC"
add_sw_property alt_cppflags_addition "-DALTERA_TRIPLE_SPEED_MAC"

#
# Source file listings...
#

# C/C++ source files
add_sw_property c_source HAL/src/altera_avalon_tse_system_info.c
add_sw_property c_source HAL/src/altera_avalon_tse.c

# Include files
add_sw_property include_source HAL/inc/altera_avalon_tse_system_info.h
add_sw_property include_source HAL/inc/altera_avalon_tse.h
add_sw_property include_source HAL/inc/altera_eth_tse.h
add_sw_property include_source inc/altera_eth_tse_regs.h

# Include Directory
add_sw_property include_directory HAL/inc
add_sw_property include_directory inc

# End of file
