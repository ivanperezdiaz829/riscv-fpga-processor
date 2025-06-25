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


package require -exact qsys 12.1

# module properties
set_module_property NAME {altera_avalon_monitor_and_gatherer}
set_module_property DISPLAY_NAME {Throughput Monitor and Stats Gatherer}

set_module_property VERSION 13.1
set_module_property GROUP "Verification/Debug & Performance"
set_module_property DESCRIPTION ""
set_module_property AUTHOR "Altera Corporation"
set_module_property COMPOSITION_CALLBACK compose
set_module_property OPAQUE_ADDRESS_MAP false
set_module_property INTERNAL true

# 
# parameters for the altera_avst_performance_monitor instance
# 
# MASTER_SIDE is unused; at some point, delete it and remove it from transform
# code.
add_parameter          MASTER_SIDE       boolean  true
set_parameter_property MASTER_SIDE       DISPLAY_NAME    "Master-side"
set_parameter_property MASTER_SIDE       DESCRIPTION     "master-side vs slave-side"
set_parameter_property MASTER_SIDE       HDL_PARAMETER   true
set_parameter_property MASTER_SIDE       GROUP           "connection type"

add_parameter          ST_DATA_W        integer         100
set_parameter_property ST_DATA_W   DISPLAY_NAME         "ST Data Width"
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

add_parameter          PKT_BYTE_CNT_L  integer         86
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

# PKT_DEST_ID_H, PKT_DEST_ID_L, PKT_SRC_ID_H, PKT_SRC_ID_L are unused; at some point, delete them and
# remove them from transform code.
add_parameter          PKT_DEST_ID_H  integer         2
set_parameter_property PKT_DEST_ID_H  DISPLAY_NAME    "Destination ID H"
set_parameter_property PKT_DEST_ID_H  DESCRIPTION     "highest bit of dest id field"
set_parameter_property PKT_DEST_ID_H  UNITS            none
set_parameter_property PKT_DEST_ID_H  ALLOWED_RANGES   0:500
set_parameter_property PKT_DEST_ID_H  HDL_PARAMETER    true
set_parameter_property PKT_DEST_ID_H  GROUP            "Field Selects"

add_parameter          PKT_DEST_ID_L  integer         0
set_parameter_property PKT_DEST_ID_L  DISPLAY_NAME    "Destination ID L"
set_parameter_property PKT_DEST_ID_L  DESCRIPTION     "lowest bit of dest id field"
set_parameter_property PKT_DEST_ID_L  UNITS            none
set_parameter_property PKT_DEST_ID_L  ALLOWED_RANGES   0:500
set_parameter_property PKT_DEST_ID_L  HDL_PARAMETER    true
set_parameter_property PKT_DEST_ID_L  GROUP            "Field Selects"

add_parameter          PKT_SRC_ID_H  integer         2
set_parameter_property PKT_SRC_ID_H  DISPLAY_NAME    "Source ID H"
set_parameter_property PKT_SRC_ID_H  DESCRIPTION     "highest bit of src id field"
set_parameter_property PKT_SRC_ID_H  UNITS            none
set_parameter_property PKT_SRC_ID_H  ALLOWED_RANGES   0:500
set_parameter_property PKT_SRC_ID_H  HDL_PARAMETER    true
set_parameter_property PKT_SRC_ID_H  GROUP            "Field Selects"

add_parameter          PKT_SRC_ID_L  integer         0
set_parameter_property PKT_SRC_ID_L  DISPLAY_NAME    "Source ID L"
set_parameter_property PKT_SRC_ID_L  DESCRIPTION     "lowest bit of src id field"
set_parameter_property PKT_SRC_ID_L  UNITS            none
set_parameter_property PKT_SRC_ID_L  ALLOWED_RANGES   0:500
set_parameter_property PKT_SRC_ID_L  HDL_PARAMETER    true
set_parameter_property PKT_SRC_ID_L  GROUP            "Field Selects"

add_parameter          NUM_SYMBOLS  integer         4
set_parameter_property NUM_SYMBOLS  DISPLAY_NAME    "number of interface symbols"
set_parameter_property NUM_SYMBOLS  DESCRIPTION     "number of interface symbols"
set_parameter_property NUM_SYMBOLS  UNITS            none
set_parameter_property NUM_SYMBOLS  ALLOWED_RANGES   1:512
set_parameter_property NUM_SYMBOLS  HDL_PARAMETER    false
set_parameter_property NUM_SYMBOLS  GROUP            "Field Selects"

# altera_trace_stats_gatherer instance parameters
add_parameter START_ENABLED BOOLEAN false
set_parameter_property START_ENABLED DISPLAY_NAME START_ENABLED
set_parameter_property START_ENABLED UNITS None
set_parameter_property START_ENABLED HDL_PARAMETER false

add_parameter SAMPLE_PERIOD FLOAT 20
set_parameter_property SAMPLE_PERIOD HDL_PARAMETER false
set_parameter_property SAMPLE_PERIOD DISPLAY_NAME "Sample period"

add_parameter SAMPLE_PERIOD_UNITS STRING MSEC
set_parameter_property SAMPLE_PERIOD_UNITS HDL_PARAMETER false
set_parameter_property SAMPLE_PERIOD_UNITS DISPLAY_NAME "Units of sample period"
set_parameter_property SAMPLE_PERIOD_UNITS ALLOWED_RANGES {USEC:us MSEC:ms SEC:s}

add_parameter MAX_SAMPLE_PERIOD FLOAT 1000
set_parameter_property MAX_SAMPLE_PERIOD HDL_PARAMETER false
set_parameter_property MAX_SAMPLE_PERIOD DISPLAY_NAME "Maximum sample period"

add_parameter MAX_SAMPLE_PERIOD_UNITS STRING MSEC
set_parameter_property MAX_SAMPLE_PERIOD_UNITS HDL_PARAMETER false
set_parameter_property MAX_SAMPLE_PERIOD_UNITS DISPLAY_NAME "Units of maximum sample period"
set_parameter_property MAX_SAMPLE_PERIOD_UNITS ALLOWED_RANGES {USEC:us MSEC:ms SEC:s}

add_instance clk clock_source
set_instance_parameter_value clk clockFrequencyKnown {0}
set_instance_parameter_value clk resetSynchronousEdges {DEASSERT}

add_interface clk clock sink
set_interface_property clk EXPORT_OF clk.clk_in

proc compose { } {

    add_instance gatherer altera_trace_stats_gatherer
    set sg_parameters {
      "START_ENABLED"
      "SAMPLE_PERIOD"
      "SAMPLE_PERIOD_UNITS"
      "MAX_SAMPLE_PERIOD"
      "MAX_SAMPLE_PERIOD_UNITS"
    }
    foreach param $sg_parameters {
      set_instance_parameter_value gatherer $param [get_parameter_value $param]
    }

    # Always enable the stats gatherer's internal FIFO.
    set_instance_parameter_value gatherer USE_INTERNAL_FIFO true


    add_instance pm altera_avst_throughput_monitor
    set pm_parameters {
      "ST_DATA_W"
      "PKT_BYTE_CNT_H"
      "PKT_BYTE_CNT_L"
      "PKT_TRANS_WRITE"
      "PKT_TRANS_READ"
      "NUM_SYMBOLS"
    }
    foreach param $pm_parameters {
      set_instance_parameter_value pm $param [get_parameter_value $param]
    }

    add_instance trace_endpoint altera_trace_monitor_endpoint
    set_instance_parameter_value trace_endpoint TRACE_WIDTH 32
    set_instance_parameter_value trace_endpoint ADDR_WIDTH 6
    set_instance_parameter_value trace_endpoint READ_LATENCY 0

    # Everything on the same clock domain
    add_connection clk.clk pm.avs_clock clock
    add_connection clk.clk pm.if_clock clock
    add_connection clk.clk gatherer.clock clock
    add_connection clk.clk trace_endpoint.clk clock

    # User reset domain
    add_connection clk.clk_reset pm.if_reset reset

    # Reset connections from the trace endpoint (debug reset domain).
    add_connection trace_endpoint.debug_reset pm.avs_reset reset
    add_connection trace_endpoint.debug_reset gatherer.reset reset

    add_connection gatherer.data pm.data avalon
    set_connection_parameter_value gatherer.data/pm.data arbitrationPriority {1}
    set_connection_parameter_value gatherer.data/pm.data baseAddress {0x0000}
    set_connection_parameter_value gatherer.data/pm.data defaultConnection {0}

    add_connection gatherer.config pm.config avalon
    set_connection_parameter_value gatherer.config/pm.config arbitrationPriority {1}
    set_connection_parameter_value gatherer.config/pm.config baseAddress {0x0000}
    set_connection_parameter_value gatherer.config/pm.config defaultConnection {0}

    add_connection gatherer.capture trace_endpoint.capture avalon_streaming

    add_connection trace_endpoint.control gatherer.control avalon

    # exported interfaces
    add_interface reset reset sink
    set_interface_property reset EXPORT_OF clk.clk_in_reset

    add_interface cp conduit end
    set_interface_property cp EXPORT_OF pm.cp
    add_interface rp conduit end
    set_interface_property rp EXPORT_OF pm.rp
}
