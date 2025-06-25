#
# altera_avalon_mailbox_driver.tcl
#

# Create a new driver
create_driver altera_avalon_mailbox_driver

# Associate it with some hardware known as "altera_avalon_mailbox"
set_sw_property hw_class_name altera_avalon_mailbox

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

#
# Source file listings...
#

# The mailbox is a super-set of the mutex component driver. Mutex
# drivers are always included when a mailbox is present in the system.
# If a mailbox *and* mutex are present, the mutex sources are merely
# copied into the generated BSP one extra time.

# C/C++ source files
add_sw_property c_source HAL/src/altera_avalon_mailbox.c
add_sw_property c_source HAL/src/altera_avalon_mutex.c

# Include files
add_sw_property include_source HAL/inc/altera_avalon_mailbox.h
add_sw_property include_source HAL/inc/altera_avalon_mutex.h
add_sw_property include_source inc/altera_avalon_mailbox_regs.h
add_sw_property include_source inc/altera_avalon_mutex_regs.h

# This driver supports HAL & UCOSII BSP (OS) types
add_sw_property supported_bsp_type HAL
add_sw_property supported_bsp_type UCOSII

# End of file
