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
# altera_instrumentation_mirror_endpoint "altera_instrumentation_mirror_endpoint" v1.0
# 

# request TCL package from ACDS 13.0
# 
package require -exact qsys 13.0

# 
# module altera_instrumentation_mirror_endpoint
# 
set_module_property NAME altera_instrumentation_mirror_endpoint
set_module_property AUTHOR "Altera Corporation"
set_module_property GROUP "Verification/Debug & Performance"
set_module_property VERSION 13.1
set_module_property INTERNAL true
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property DISPLAY_NAME altera_instrumentation_mirror_endpoint
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false
set_module_property ANALYZE_HDL false
set_module_property REPORT_TO_TALKBACK true
set_module_property ALLOW_GREYBOX_GENERATION false
set_module_assignment debug.isTransparent true

# 
# file sets
# 
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL altera_instrumentation_mirror_endpoint_wrapper
set_fileset_property QUARTUS_SYNTH ENABLE_RELATIVE_INCLUDE_PATHS false
add_fileset_file altera_instrumentation_mirror_endpoint_wrapper.sv system_verilog path altera_instrumentation_mirror_endpoint_wrapper.sv


# 
# parameters
# 
add_parameter COUNT INTEGER 1
set_parameter_property COUNT AFFECTS_ELABORATION false
set_parameter_property COUNT AFFECTS_GENERATION false
set_parameter_property COUNT HDL_PARAMETER true

add_parameter WIDTH INTEGER 8
set_parameter_property WIDTH AFFECTS_ELABORATION true
set_parameter_property WIDTH AFFECTS_GENERATION false
set_parameter_property WIDTH HDL_PARAMETER true

add_parameter NODES STRING {}
set_parameter_property NODES AFFECTS_ELABORATION false
set_parameter_property NODES AFFECTS_GENERATION false
set_parameter_property NODES HDL_PARAMETER true

add_parameter CLOCKS STRING {}
set_parameter_property CLOCKS AFFECTS_ELABORATION false
set_parameter_property CLOCKS AFFECTS_GENERATION false
set_parameter_property CLOCKS HDL_PARAMETER true


# 
# display items
# 

#
# connection point nodes
#
add_interface nodes conduit start
set_interface_property nodes ENABLED true
add_interface_port nodes mirror_send receive Input WIDTH
add_interface_port nodes mirror_receive send Output WIDTH



proc log2 x {expr {int(ceil(log($x) / log(2)))}}
