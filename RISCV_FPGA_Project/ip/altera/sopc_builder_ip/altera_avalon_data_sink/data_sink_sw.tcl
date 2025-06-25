#
# data sink driver
#

# Create a new driver and associate it with some hardware known 
# as "data_sink"
create_driver data_sink

set_sw_property hw_class_name data_sink

# The version of this driver
set_sw_property version 13.1

# This driver may be incompatible with versions of hardware less
# than specified below. Updates to hardware and device drivers
# rendering the driver incompatible with older versions of
# hardware are noted with this property assignment.
set_sw_property min_compatible_hw_version 7.2

# Initialize the driver in alt_sys_init()
set_sw_property auto_initialize false

# Location in generated BSP that above sources will be copied into
set_sw_property bsp_subdirectory drivers

# This driver supports the HAL & uC/OS-II (OS) types
add_sw_property supported_bsp_type HAL
add_sw_property supported_bsp_type UCOSII

#
# Source file listings...
#

# C/C++ source files
add_sw_property c_source HAL/src/data_sink_util.c

# Include files
add_sw_property include_source HAL/inc/data_sink_util.h
add_sw_property include_source inc/data_sink_regs.h

# End of file
