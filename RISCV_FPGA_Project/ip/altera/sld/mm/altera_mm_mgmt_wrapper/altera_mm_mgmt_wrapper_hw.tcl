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

# 
# altera_mm_mgmt_wrapper "altera_mm_mgmt_wrapper" v1.0
# 

# request TCL package from ACDS 13.0
# 
package require -exact qsys 13.1

# 
# module altera_mm_mgmt_wrapper
# 
set_module_property NAME altera_mm_mgmt_wrapper
set_module_property AUTHOR "Altera Corporation"
set_module_property GROUP "Verification/Debug & Performance"
set_module_property VERSION 13.1
set_module_property INTERNAL true
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property DISPLAY_NAME altera_mm_mgmt_wrapper
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false
set_module_property ANALYZE_HDL false
set_module_property REPORT_TO_TALKBACK true
set_module_property ALLOW_GREYBOX_GENERATION false
set_module_property ELABORATION_CALLBACK elaborate

# 
# file sets
# 
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL altera_mm_mgmt_wrapper
set_fileset_property QUARTUS_SYNTH ENABLE_RELATIVE_INCLUDE_PATHS false
add_fileset_file altera_mm_mgmt_wrapper.sv system_verilog path altera_mm_mgmt_wrapper.sv


# 
# parameters
# 
add_parameter CHANNEL_WIDTH INTEGER 8
set_parameter_property CHANNEL_WIDTH ALLOWED_RANGES {2:24}
set_parameter_property CHANNEL_WIDTH AFFECTS_ELABORATION true
set_parameter_property CHANNEL_WIDTH AFFECTS_GENERATION false
set_parameter_property CHANNEL_WIDTH HDL_PARAMETER true


# 
# display items
# 

#
# connection point clk
#
add_interface clk clock end
set_interface_property clk ENABLED true
add_interface_port clk clk clk Input 1


#
# connection point reset
#
add_interface reset reset end
set_interface_property reset associatedClock clk
set_interface_property reset ENABLED true
add_interface_port reset reset reset Input 1


#
# connection point csr
#
add_interface csr avalon end
set_interface_property csr writeWaitTime 0
set_interface_property csr associatedClock clk
set_interface_property csr associatedReset reset
set_interface_property csr ENABLED true
add_interface_port csr csr_write write Input 1
add_interface_port csr csr_writedata writedata Input 32


#
# connection point mgmt
#
add_interface mgmt avalon_streaming start
set_interface_property mgmt dataBitsPerSymbol 1
set_interface_property mgmt associatedClock clk
set_interface_property mgmt associatedReset reset
set_interface_property mgmt ENABLED true
add_interface_port mgmt mgmt_valid valid Output 1
add_interface_port mgmt mgmt_data data Output 1
add_interface_port mgmt mgmt_channel channel Output CHANNEL_WIDTH


#
# Elaboration callback
#
proc elaborate {} {
    set CHANNEL_WIDTH [get_parameter_value CHANNEL_WIDTH]
    set_interface_property mgmt maxChannel [expr {(1 << $CHANNEL_WIDTH) - 1} ]
}
