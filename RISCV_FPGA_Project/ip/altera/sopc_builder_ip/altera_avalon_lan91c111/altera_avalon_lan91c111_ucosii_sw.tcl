#
# altera_avalon_lan91c111_driver_ucosii.tcl
#

# Create a new driver
create_driver altera_avalon_lan91c111_ucosii_driver

# Associate it with some hardware known as "altera_avalon_lan91c111"
set_sw_property hw_class_name altera_avalon_lan91c111

# The version of this driver
set_sw_property version 13.1

# This driver may be incompatible with versions of hardware less
# than specified below. Updates to hardware and device drivers
# rendering the driver incompatible with older versions of
# hardware are noted with this property assignment.
#
# Multiple-Version compatibility was introduced in version 7.1;
# prior versions are therefore excluded.
set_sw_property min_compatible_hw_version 7.1

# Initialize the driver in alt_sys_init()
set_sw_property auto_initialize true

# Location in generated BSP that above sources will be copied into
set_sw_property bsp_subdirectory drivers

# This driver supports the uC/OS-II (OS) type
add_sw_property supported_bsp_type UCOSII

# Interrupt properties: This driver supports both legacy and enhanced
# interrupt APIs. The ISR does not support preemption
set_sw_property supported_interrupt_apis "legacy_interrupt_api enhanced_interrupt_api"

#
# Source file listings...
#

# Include files
add_sw_property include_source UCOSII/inc/altera_avalon_lan91c111.h
add_sw_property include_source inc/altera_avalon_lan91c111_regs.h
add_sw_property include_source UCOSII/inc/iniche/altera_avalon_lan91c111_iniche.h
add_sw_property include_source UCOSII/inc/iniche/s91_port.h
add_sw_property include_source UCOSII/inc/iniche/smsc91x.h

# C/C++ source files - INICHE
add_sw_property c_source UCOSII/src/iniche/smsc91x.c
add_sw_property c_source UCOSII/src/iniche/smsc_mem.c
add_sw_property c_source UCOSII/src/iniche/smsc_phy.c

add_sw_property include_directory UCOSII/inc/iniche

# End of file
