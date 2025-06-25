#
# altera_avalon_jtag_uart_lwhal_sw.tcl
#

# Create a new driver
create_driver altera_avalon_jtag_uart_lwhal_driver

# Associate it with some hardware known as "altera_avalon_jtag_uart"
set_sw_property hw_class_name altera_avalon_jtag_uart

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

# Location in generated BSP that above sources will be copied into
set_sw_property bsp_subdirectory drivers

#
# Source file listings...
#

# C/C++ source files
add_sw_property c_source LWHAL/src/altera_avalon_jtag_uart_lwhal_putchar.c

# Include files
add_sw_property include_source LWHAL/inc/altera_avalon_jtag_uart_lwhal.h
add_sw_property include_source inc/altera_avalon_jtag_uart_regs.h

# This driver supports LWHAL (OS) types
add_sw_property supported_bsp_type LWHAL

# End of file
