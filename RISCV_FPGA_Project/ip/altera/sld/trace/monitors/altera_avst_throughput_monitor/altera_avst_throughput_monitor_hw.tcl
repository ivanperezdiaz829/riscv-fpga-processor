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


package require -exact qsys 13.1

# module properties
set_module_property NAME altera_avst_throughput_monitor
set_module_property DISPLAY_NAME "AvST Throughput Monitor"

# default module properties
set_module_property VERSION 13.1
set_module_property GROUP "Verification/Debug & Performance"
set_module_property INTERNAL true
set_module_property DESCRIPTION ""
set_module_property AUTHOR "Altera Corporation"

set_module_property COMPOSITION_CALLBACK compose
set_module_property opaque_address_map false

# 
# parameters
# 


add_parameter          BC_W        integer              3
set_parameter_property BC_W        DISPLAY_NAME         "Burstcount Width"
set_parameter_property BC_W        DESCRIPTION          "Width of burstcount signal"
set_parameter_property BC_W        UNITS                bits
set_parameter_property BC_W        ALLOWED_RANGES       1:10
set_parameter_property BC_W        HDL_PARAMETER        true
set_parameter_property BC_W        GROUP                "Port Widths"
set_parameter_property BC_W        DERIVED              true

add_parameter          ST_DATA_W        integer         100
set_parameter_property ST_DATA_W   DISPLAY_NAME         "Data Width"
set_parameter_property ST_DATA_W   DESCRIPTION          "Width of ST data."
set_parameter_property ST_DATA_W   UNITS                bits
set_parameter_property ST_DATA_W   ALLOWED_RANGES       1:500
set_parameter_property ST_DATA_W   HDL_PARAMETER        true
set_parameter_property ST_DATA_W   GROUP                "Port Widths"

add_parameter          PKT_BYTE_CNT_H  integer         86
set_parameter_property PKT_BYTE_CNT_H  DISPLAY_NAME    "PKT Byte Count H"
set_parameter_property PKT_BYTE_CNT_H  DESCRIPTION     "highest bit of byte count"
set_parameter_property PKT_BYTE_CNT_H  UNITS            none
set_parameter_property PKT_BYTE_CNT_H  ALLOWED_RANGES   0:500
set_parameter_property PKT_BYTE_CNT_H  HDL_PARAMETER    true
set_parameter_property PKT_BYTE_CNT_H  GROUP            "Field Selects"

add_parameter          PKT_BYTE_CNT_L  integer         83
set_parameter_property PKT_BYTE_CNT_L  DISPLAY_NAME    "PKT Byte Count L"
set_parameter_property PKT_BYTE_CNT_L  DESCRIPTION     "lowest bit of byte count"
set_parameter_property PKT_BYTE_CNT_L  UNITS            none
set_parameter_property PKT_BYTE_CNT_L  ALLOWED_RANGES   0:500
set_parameter_property PKT_BYTE_CNT_L  HDL_PARAMETER    true
set_parameter_property PKT_BYTE_CNT_L  GROUP            "Field Selects"

add_parameter          PKT_TRANS_WRITE  integer         39
set_parameter_property PKT_TRANS_WRITE  DISPLAY_NAME    "Write bit"
set_parameter_property PKT_TRANS_WRITE  DESCRIPTION     "bit position of write"
set_parameter_property PKT_TRANS_WRITE  UNITS            none
set_parameter_property PKT_TRANS_WRITE  ALLOWED_RANGES   0:500
set_parameter_property PKT_TRANS_WRITE  HDL_PARAMETER    true
set_parameter_property PKT_TRANS_WRITE  GROUP            "Field Selects"

add_parameter          PKT_TRANS_READ  integer         38
set_parameter_property PKT_TRANS_READ  DISPLAY_NAME    "Read bit"
set_parameter_property PKT_TRANS_READ  DESCRIPTION     "bit position of read"
set_parameter_property PKT_TRANS_READ  UNITS            none
set_parameter_property PKT_TRANS_READ  ALLOWED_RANGES   0:500
set_parameter_property PKT_TRANS_READ  HDL_PARAMETER    true
set_parameter_property PKT_TRANS_READ  GROUP            "Field Selects"

add_parameter          NUM_SYMBOLS  integer         4
set_parameter_property NUM_SYMBOLS  DISPLAY_NAME    "number of interface symbols"
set_parameter_property NUM_SYMBOLS  DESCRIPTION     "number of interface symbols"
set_parameter_property NUM_SYMBOLS  UNITS            none
set_parameter_property NUM_SYMBOLS  ALLOWED_RANGES   1:512
set_parameter_property NUM_SYMBOLS  HDL_PARAMETER    false
set_parameter_property NUM_SYMBOLS  GROUP            "Field Selects"

proc compose { } {
    # Set derived parameter values.
    set burstcount_lsbs [ log2ceil [ get_parameter_value NUM_SYMBOLS ] ]
    set_parameter_value BC_W [ expr 1 + [ get_parameter_value PKT_BYTE_CNT_H] - [ get_parameter_value PKT_BYTE_CNT_L] - $burstcount_lsbs ]

    # Instances and instance parameters
    # (disabled instances are intentionally culled)
    add_instance pmon altera_avalon_throughput_monitor
    set pmon_parameters { "BC_W" }
    foreach param $pmon_parameters {
      set_instance_parameter_value pmon $param [get_parameter_value $param]
    }

    add_instance xlate altera_throughput_tap_xlate 1.0
    set xlate_parameters {
      "ST_DATA_W"
      "PKT_BYTE_CNT_H"
      "PKT_BYTE_CNT_L"
      "PKT_TRANS_WRITE"
      "PKT_TRANS_READ"
      "NUM_SYMBOLS"
      }

    foreach param $xlate_parameters {
      set_instance_parameter_value xlate $param [get_parameter_value $param]
    }

    add_instance avs_clock altera_clock_bridge 13.1
    set_instance_parameter_value avs_clock EXPLICIT_CLOCK_RATE {0.0}
    set_instance_parameter_value avs_clock NUM_CLOCK_OUTPUTS {1}

    add_instance avs_reset altera_reset_bridge 13.1
    set_instance_parameter_value avs_reset ACTIVE_LOW_RESET {0}
    set_instance_parameter_value avs_reset SYNCHRONOUS_EDGES {deassert}
    set_instance_parameter_value avs_reset NUM_RESET_OUTPUTS {1}

    add_instance if_reset altera_reset_bridge 13.1
    set_instance_parameter_value if_reset ACTIVE_LOW_RESET {0}
    set_instance_parameter_value if_reset SYNCHRONOUS_EDGES {deassert}
    set_instance_parameter_value if_reset NUM_RESET_OUTPUTS {1}

    add_instance if_clock altera_clock_bridge 13.1
    set_instance_parameter_value if_clock EXPLICIT_CLOCK_RATE {0.0}
    set_instance_parameter_value if_clock NUM_CLOCK_OUTPUTS {1}

    # connections and connection parameters
    add_connection avs_clock.out_clk avs_reset.clk clock

    add_connection avs_clock.out_clk pmon.avs_clock clock

    add_connection avs_reset.out_reset pmon.avs_reset reset

    add_connection if_clock.out_clk if_reset.clk clock

    add_connection if_clock.out_clk pmon.if_clock clock

    add_connection if_clock.out_clk xlate.if_clock clock

    add_connection if_reset.out_reset pmon.if_reset reset

    add_connection if_reset.out_reset xlate.if_reset reset

    add_connection xlate.if pmon.if conduit
    set_connection_parameter_value xlate.if/pmon.if endPort {}
    set_connection_parameter_value xlate.if/pmon.if endPortLSB {0}
    set_connection_parameter_value xlate.if/pmon.if startPort {}
    set_connection_parameter_value xlate.if/pmon.if startPortLSB {0}
    set_connection_parameter_value xlate.if/pmon.if width {0}

    # exported interfaces
    add_interface avs_clock clock sink
    set_interface_property avs_clock EXPORT_OF avs_clock.in_clk
    add_interface avs_reset reset sink
    set_interface_property avs_reset EXPORT_OF avs_reset.in_reset
    add_interface if_clock clock sink
    set_interface_property if_clock EXPORT_OF if_clock.in_clk
    add_interface if_reset reset sink
    set_interface_property if_reset EXPORT_OF if_reset.in_reset
    add_interface cp conduit end
    set_interface_property cp EXPORT_OF xlate.cp
    add_interface rp conduit end
    set_interface_property rp EXPORT_OF xlate.rp
    add_interface data avalon slave
    set_interface_property data EXPORT_OF pmon.data
    add_interface config avalon slave
    set_interface_property config EXPORT_OF pmon.config
}

proc log2ceil x "expr {int(ceil(log(\$x)/[expr log(2)]))}"

proc log2ceil {num} {
    #make log(0), log(1) = 1
    set val 1
    set i 1
    while {$i < $num} {
        set val [expr $val + 1]
        set i [expr 1 << $val]
    }
    return $val;
}

