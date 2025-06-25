#
# altera_avalon_dma_driver.tcl
#

# Create a new driver
create_driver altera_avalon_dma_driver

# Associate it with some hardware known as "altera_avalon_dma"
set_sw_property hw_class_name altera_avalon_dma

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

# This driver supports the HAL & uC/OS-II (OS) types
add_sw_property supported_bsp_type HAL
add_sw_property supported_bsp_type UCOSII

# Interrupt properties: This driver supports both legacy and enhanced
# interrupt APIs, as well as ISR preemption.
set_sw_property isr_preemption_supported true
set_sw_property supported_interrupt_apis "legacy_interrupt_api enhanced_interrupt_api"

#
# Source file listings...
#

# C/C++ source files
add_sw_property c_source HAL/src/altera_avalon_dma.c

# Include files
add_sw_property include_source HAL/inc/altera_avalon_dma.h
add_sw_property include_source inc/altera_avalon_dma_regs.h

# End of file
