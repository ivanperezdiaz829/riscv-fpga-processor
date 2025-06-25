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
# altera_vic_driver.tcl
#

# Create a new driver
create_driver altera_vic_driver

# Associate it with some hardware known as "altera_vic"
set_sw_property hw_class_name altera_vic

# The version of this driver
set_sw_property version 13.1

# This driver may be incompatible with versions of hardware less
# than specified below. Updates to hardware and device drivers
# rendering the driver incompatible with older versions of
# hardware are noted with this property assignment.
#
# Multiple-Version compatibility was introduced in version 7.1;
# prior versions are therefore excluded.
set_sw_property min_compatible_hw_version 9.1

# Initialize the driver in alt_irq_init() if this module
# is recognized as containing an interrupt controller.
set_sw_property irq_auto_initialize true

# Location in generated BSP that above sources will be copied into
set_sw_property bsp_subdirectory drivers

# This driver supports the HAL & uC/OS-II (OS) types
add_sw_property supported_bsp_type HAL
add_sw_property supported_bsp_type UCOSII

#
# Source file listings...
#

# C/C++ source files
add_sw_property c_source HAL/src/altera_vic.c
add_sw_property c_source HAL/src/altera_vic_irq_init.c
add_sw_property c_source HAL/src/altera_vic_isr_register.c
add_sw_property c_source HAL/src/altera_vic_sw_intr.c
add_sw_property c_source HAL/src/altera_vic_set_level.c

# Assembly source files
add_sw_property asm_source HAL/src/altera_vic_funnel_non_preemptive.S
add_sw_property asm_source HAL/src/altera_vic_funnel_non_preemptive_nmi.S
add_sw_property asm_source HAL/src/altera_vic_funnel_preemptive.S

# Include files
add_sw_property include_source HAL/inc/altera_vic_irq.h
add_sw_property include_source HAL/inc/altera_vic_funnel.h
add_sw_property include_source inc/altera_vic_regs.h

# set up module instance callbacks
set_sw_property callback_source_file callbacks.tcl
set_sw_property initialization_callback initialize
set_sw_property generation_callback generate
set_sw_property validation_callback validate

# set up per class callbacks
set_sw_property class_initialization_callback class_initialize
set_sw_property class_validation_callback class_validate

# End of file
