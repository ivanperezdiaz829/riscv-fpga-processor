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
# request TCL package from ACDS 13.1
# 
package require -exact qsys 13.1


# 
# module altera_throughput_tap_xlate 
# 
set_module_property DESCRIPTION ""
set_module_property NAME altera_throughput_tap_xlate
set_module_property VERSION 1.0
set_module_property INTERNAL true
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property AUTHOR ""
set_module_property DISPLAY_NAME "Avalon ST Throughput Tap Translator"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL AUTO
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false

set_module_property ELABORATION_CALLBACK elaborate


add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL altera_throughput_tap_xlate
set_fileset_property QUARTUS_SYNTH ENABLE_RELATIVE_INCLUDE_PATHS false
add_fileset_file altera_throughput_tap_xlate.sv VERILOG PATH altera_throughput_tap_xlate.sv TOP_LEVEL_FILE

add_fileset SIM_VERILOG SIM_VERILOG "" ""
set_fileset_property SIM_VERILOG TOP_LEVEL altera_throughput_tap_xlate
set_fileset_property SIM_VERILOG ENABLE_RELATIVE_INCLUDE_PATHS false
add_fileset_file altera_throughput_tap_xlate.sv VERILOG PATH altera_throughput_tap_xlate.sv

# 
# parameters
# 

add_parameter          ST_DATA_W        integer         100
set_parameter_property ST_DATA_W   DISPLAY_NAME         "Data Width"
set_parameter_property ST_DATA_W   DESCRIPTION          "Width of ST data."
set_parameter_property ST_DATA_W   UNITS                bits
set_parameter_property ST_DATA_W   ALLOWED_RANGES       1:500
set_parameter_property ST_DATA_W   HDL_PARAMETER        true
set_parameter_property ST_DATA_W   GROUP                "Port Widths"

add_parameter          BC_W        integer              3
set_parameter_property BC_W        DISPLAY_NAME         "Burstcount Width"
set_parameter_property BC_W        DESCRIPTION          "Width of burstcount signal"
set_parameter_property BC_W        UNITS                bits
set_parameter_property BC_W        ALLOWED_RANGES       1:10
set_parameter_property BC_W        HDL_PARAMETER        true
set_parameter_property BC_W        DERIVED              true
set_parameter_property BC_W        VISIBLE              false

add_parameter          BURSTCOUNT_LSB  integer         86
set_parameter_property BURSTCOUNT_LSB  DISPLAY_NAME    "PKT burstcount lsb"
set_parameter_property BURSTCOUNT_LSB  DESCRIPTION     "lowest bit of burstcount"
set_parameter_property BURSTCOUNT_LSB  UNITS            none
set_parameter_property BURSTCOUNT_LSB  ALLOWED_RANGES   0:500
set_parameter_property BURSTCOUNT_LSB  HDL_PARAMETER    true
set_parameter_property BURSTCOUNT_LSB  DERIVED          true
set_parameter_property BURSTCOUNT_LSB  VISIBLE          false

add_parameter          NUM_SYMBOLS  integer         4
set_parameter_property NUM_SYMBOLS  DISPLAY_NAME    "number of interface symbols"
set_parameter_property NUM_SYMBOLS  DESCRIPTION     "number of interface symbols"
set_parameter_property NUM_SYMBOLS  UNITS            none
set_parameter_property NUM_SYMBOLS  ALLOWED_RANGES   1:512
set_parameter_property NUM_SYMBOLS  HDL_PARAMETER    false
set_parameter_property NUM_SYMBOLS  GROUP            "Field Selects"

add_parameter          PKT_BYTE_CNT_H  integer         86
set_parameter_property PKT_BYTE_CNT_H  DISPLAY_NAME    "PKT Byte Count H"
set_parameter_property PKT_BYTE_CNT_H  DESCRIPTION     "highest bit of byte count"
set_parameter_property PKT_BYTE_CNT_H  UNITS            none
set_parameter_property PKT_BYTE_CNT_H  ALLOWED_RANGES   0:500
set_parameter_property PKT_BYTE_CNT_H  HDL_PARAMETER    true
set_parameter_property PKT_BYTE_CNT_H  GROUP            "Field Selects"

add_parameter          PKT_BYTE_CNT_L  integer         84
set_parameter_property PKT_BYTE_CNT_L  DISPLAY_NAME    "PKT Byte Count L"
set_parameter_property PKT_BYTE_CNT_L  DESCRIPTION     "lowest bit of byte count"
set_parameter_property PKT_BYTE_CNT_L  UNITS            none
set_parameter_property PKT_BYTE_CNT_L  ALLOWED_RANGES   0:500
set_parameter_property PKT_BYTE_CNT_L  HDL_PARAMETER    true
set_parameter_property PKT_BYTE_CNT_L  GROUP            "Field Selects"

add_parameter          PKT_TRANS_WRITE  integer         39
set_parameter_property PKT_TRANS_WRITE  DISPLAY_NAME    "PKT Write bit"
set_parameter_property PKT_TRANS_WRITE  DESCRIPTION     "bit position of write"
set_parameter_property PKT_TRANS_WRITE  UNITS            none
set_parameter_property PKT_TRANS_WRITE  ALLOWED_RANGES   0:500
set_parameter_property PKT_TRANS_WRITE  HDL_PARAMETER    true
set_parameter_property PKT_TRANS_WRITE  GROUP            "Field Selects"

add_parameter          PKT_TRANS_READ  integer         38
set_parameter_property PKT_TRANS_READ  DISPLAY_NAME    "PKT Read bit"
set_parameter_property PKT_TRANS_READ  DESCRIPTION     "bit position of read"
set_parameter_property PKT_TRANS_READ  UNITS            none
set_parameter_property PKT_TRANS_READ  ALLOWED_RANGES   0:500
set_parameter_property PKT_TRANS_READ  HDL_PARAMETER    true
set_parameter_property PKT_TRANS_READ  GROUP            "Field Selects"


# 
# connection point if_clock
# 
add_interface if_clock clock end
set_interface_property if_clock clockRate 0
set_interface_property if_clock ENABLED true
set_interface_property if_clock EXPORT_OF ""
set_interface_property if_clock PORT_NAME_MAP ""
set_interface_property if_clock SVD_ADDRESS_GROUP ""

add_interface_port if_clock if_clock clk Input 1


# 
# connection point if_reset
# 
add_interface if_reset reset end
set_interface_property if_reset associatedClock if_clock
set_interface_property if_reset synchronousEdges DEASSERT
set_interface_property if_reset ENABLED true
set_interface_property if_reset EXPORT_OF ""
set_interface_property if_reset PORT_NAME_MAP ""
set_interface_property if_reset SVD_ADDRESS_GROUP ""

add_interface_port if_reset if_reset reset Input 1



# 
# connection point cp
# 
add_interface cp conduit end
set_interface_property cp associatedClock if_clock
set_interface_property cp associatedReset if_reset
set_interface_property cp ENABLED true
set_interface_property cp EXPORT_OF ""
set_interface_property cp PORT_NAME_MAP ""
set_interface_property cp SVD_ADDRESS_GROUP ""

add_interface_port cp cp_valid  valid Input 1
add_interface_port cp cp_data   data  Input ST_DATA_W
add_interface_port cp cp_ready  ready Input 1

set_interface_assignment cp debug.visible true

# 
# connection point rp
# 
add_interface rp conduit end
set_interface_property rp associatedClock if_clock
set_interface_property rp associatedReset if_reset
set_interface_property rp ENABLED true
set_interface_property rp EXPORT_OF ""
set_interface_property rp PORT_NAME_MAP ""
set_interface_property rp SVD_ADDRESS_GROUP ""

add_interface_port rp rp_valid  valid Input 1

set_interface_assignment rp debug.visible true


# 
# connection point if
# 
add_interface if conduit start
set_interface_property if associatedClock if_clock
set_interface_property if associatedReset if_reset
set_interface_property if ENABLED true
set_interface_property if EXPORT_OF ""
set_interface_property if PORT_NAME_MAP ""
set_interface_property if SVD_ADDRESS_GROUP ""

add_interface_port if if_read read Output 1
add_interface_port if if_write write Output 1
add_interface_port if if_burstcount burstcount Output BC_W
add_interface_port if if_waitrequest waitrequest Output 1
add_interface_port if if_readdatavalid readdatavalid Output 1

set_interface_assignment if debug.visible true


proc elaborate {} {
  # set derived parameter values
  set burstcount_lsbs [ log2ceil [ p_value NUM_SYMBOLS ] ]
  set_parameter_value BC_W [ expr 1 + [ p_value PKT_BYTE_CNT_H] - [ p_value PKT_BYTE_CNT_L] - $burstcount_lsbs ]
  set_parameter_value BURSTCOUNT_LSB [ expr [ p_value PKT_BYTE_CNT_L] + $burstcount_lsbs ]
  
}

proc log2ceil x "expr {int(ceil(log(\$x)/[expr log(2)]))}"

proc p_value { p } { 
  return [ get_parameter_value $p ]
}
