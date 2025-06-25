#
# altera_avalon_lan91c111_driver_hal.tcl
#

# Create a new driver
create_driver altera_avalon_lan91c111_hal_driver

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
set_sw_property auto_initialize false

# Location in generated BSP that above sources will be copied into
set_sw_property bsp_subdirectory drivers

# This driver supports the HAL (OS) type
add_sw_property supported_bsp_type HAL

# Interrupt properties:
# This peripheral has an IRQ output but the driver doesn't currently
# have any interrupt service routine. To ensure that the BSP tools
# do not otherwise limit the BSP functionality for users of the
# Nios II enhanced interrupt port, these settings advertise 
# compliance with both legacy and enhanced interrupt APIs, and to state
# that any driver ISR supports preemption. If an interrupt handler
# is added to this driver, these must be re-examined for validity.
set_sw_property isr_preemption_supported true
set_sw_property supported_interrupt_apis "legacy_interrupt_api enhanced_interrupt_api"

#
# Source file listings...
#

# Include files
add_sw_property include_source HAL/inc/altera_avalon_lan91c111.h
add_sw_property include_source inc/altera_avalon_lan91c111_regs.h

# End of file
