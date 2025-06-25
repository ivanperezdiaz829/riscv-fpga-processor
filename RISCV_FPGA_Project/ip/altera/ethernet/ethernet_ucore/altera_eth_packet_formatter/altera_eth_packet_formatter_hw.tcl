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



# Ensure this component works in 9.1 environment
# ---------------------------------------------------------------------
package require -exact sopc 9.1


# Module settings
# ---------------------------------------------------------------------
set_module_property DESCRIPTION "Altera Ethernet Packet Formatter"
set_module_property NAME altera_eth_packet_formatter
set_module_property VERSION 13.1
set_module_property AUTHOR "Altera Corporation"
set_module_property INTERNAL true
set_module_property GROUP "Interface Protocols/Ethernet/Submodules"
set_module_property DISPLAY_NAME "Ethernet Packet Formatter"
set_module_property TOP_LEVEL_HDL_FILE altera_eth_packet_formatter.v
set_module_property TOP_LEVEL_HDL_MODULE altera_eth_packet_formatter
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property ELABORATION_CALLBACK elaborate
set_module_property VALIDATION_CALLBACK validate
set_module_property EDITABLE false
# set_module_property SIMULATION_MODEL_IN_VERILOG true
# set_module_property SIMULATION_MODEL_IN_VHDL true
set_module_property ANALYZE_HDL false

# -----------------------------------
# IEEE encryption
# ----------------------------------- 
set HDL_LIB_DIR "../lib"

add_fileset simulation_verilog SIM_VERILOG sim_ver
add_fileset simulation_vhdl SIM_VHDL sim_vhd
set_fileset_property simulation_verilog TOP_LEVEL altera_eth_packet_formatter

proc sim_ver {name} {
    if {1} {
        add_fileset_file mentor/altera_eth_packet_formatter.v VERILOG_ENCRYPT PATH "mentor/altera_eth_packet_formatter.v" {MENTOR_SPECIFIC}
    }
    if {1} {
        add_fileset_file aldec/altera_eth_packet_formatter.v VERILOG_ENCRYPT PATH "aldec/altera_eth_packet_formatter.v" {ALDEC_SPECIFIC}
    }
    if {0} {
        add_fileset_file cadence/altera_eth_packet_formatter.v VERILOG_ENCRYPT PATH "cadence/altera_eth_packet_formatter.v" {CADENCE_SPECIFIC}
    }
    if {0} {
        add_fileset_file synopsys/altera_eth_packet_formatter.v VERILOG_ENCRYPT PATH "synopsys/altera_eth_packet_formatter.v" {SYNOPSYS_SPECIFIC}
    }
}

proc sim_vhd {name} {
   if {1} {
      add_fileset_file mentor/altera_eth_packet_formatter.v VERILOG_ENCRYPT PATH "mentor/altera_eth_packet_formatter.v" {MENTOR_SPECIFIC}
   }
   if {1} {
      add_fileset_file aldec/altera_eth_packet_formatter.v VERILOG_ENCRYPT PATH "aldec/altera_eth_packet_formatter.v" {ALDEC_SPECIFIC}
   }
   if {0} {
      add_fileset_file cadence/altera_eth_packet_formatter.v VERILOG_ENCRYPT PATH "cadence/altera_eth_packet_formatter.v" {CADENCE_SPECIFIC}
   }
   if {0} {
      add_fileset_file synopsys/altera_eth_packet_formatter.v VERILOG_ENCRYPT PATH "synopsys/altera_eth_packet_formatter.v" {SYNOPSYS_SPECIFIC}
   }
}


# Files
# ---------------------------------------------------------------------
add_file altera_eth_packet_formatter.v {SYNTHESIS}
add_file altera_eth_packet_formatter.ocp {SYNTHESIS}




# Parameters Default Values
# ---------------------------------------------------------------------
set ERROR_WIDTH_VALUE                           1
set GET_PREAMBLE_VALUE                          0





# Constants
# ---------------------------------------------------------------------
set DATA_SINK_BITSPERSYMBOLS_VALUE              8
set DATA_SRC_BITSPERSYMBOLS_VALUE               [expr $DATA_SINK_BITSPERSYMBOLS_VALUE + 1]

set SYMBOLSPERBEAT_VALUE                        8





# Avalon Slave 
# ---------------------------------------------------------------------
# N/A



# Avalon Streaming Sink and Source
# ---------------------------------------------------------------------
add_parameter ERROR_WIDTH INTEGER $ERROR_WIDTH_VALUE
set_parameter_property ERROR_WIDTH DISPLAY_NAME ERROR_WIDTH
set_parameter_property ERROR_WIDTH HDL_PARAMETER true
set_parameter_property ERROR_WIDTH AFFECTS_ELABORATION true
set_parameter_property ERROR_WIDTH DERIVED false
set_parameter_property ERROR_WIDTH DESCRIPTION "Width of error signal"
set_parameter_property ERROR_WIDTH ALLOWED_RANGES 1:32
set_parameter_property ERROR_WIDTH ENABLED true
set_parameter_property ERROR_WIDTH VISIBLE true
set_parameter_property ERROR_WIDTH DISPLAY_HINT ""

add_parameter GET_PREAMBLE INTEGER $GET_PREAMBLE_VALUE
set_parameter_property GET_PREAMBLE DISPLAY_NAME GET_PREAMBLE
set_parameter_property GET_PREAMBLE UNITS None
set_parameter_property GET_PREAMBLE DISPLAY_HINT "boolean"
set_parameter_property GET_PREAMBLE AFFECTS_GENERATION false
set_parameter_property GET_PREAMBLE IS_HDL_PARAMETER false
set_parameter_property GET_PREAMBLE VISIBLE false


# Avalon Streaming Sink
# ---------------------------------------------------------------------
# N/A





set CLOCK_INTERFACE                             "clk"
set DATA_SINK_INTERFACE                         "data_sink"
set PREAMBLE_SINK_INTERFACE                     "preamble_sink"
set DATA_SRC_INTERFACE                          "data_src"



# Connection point - clock
# ---------------------------------------------------------------------
add_interface       $CLOCK_INTERFACE clock sink
add_interface_port  $CLOCK_INTERFACE clk clk Input 1
add_interface_port  $CLOCK_INTERFACE reset reset Input 1



# Avalon Slave connection point 
# ---------------------------------------------------------------------
# N/A



# Avalon Streaming Sink connection point 
# ---------------------------------------------------------------------
add_interface $DATA_SINK_INTERFACE avalon_streaming sink
set_interface_property $DATA_SINK_INTERFACE ENABLED true
set_interface_property $DATA_SINK_INTERFACE ASSOCIATED_CLOCK $CLOCK_INTERFACE
set_interface_property $DATA_SINK_INTERFACE dataBitsPerSymbol $DATA_SINK_BITSPERSYMBOLS_VALUE
set_interface_property $DATA_SINK_INTERFACE errorDescriptor ""
set_interface_property $DATA_SINK_INTERFACE maxChannel 0
set_interface_property $DATA_SINK_INTERFACE readyLatency 0
set_interface_property $DATA_SINK_INTERFACE symbolsPerBeat $SYMBOLSPERBEAT_VALUE

add_interface_port $DATA_SINK_INTERFACE data_sink_data data Input -1
add_interface_port $DATA_SINK_INTERFACE data_sink_sop startofpacket Input 1
add_interface_port $DATA_SINK_INTERFACE data_sink_eop endofpacket Input 1
add_interface_port $DATA_SINK_INTERFACE data_sink_empty empty Input -1
add_interface_port $DATA_SINK_INTERFACE data_sink_error error Input -1
add_interface_port $DATA_SINK_INTERFACE data_sink_valid valid Input 1
add_interface_port $DATA_SINK_INTERFACE data_sink_ready ready Output 1


# Avalon Streaming Preamble Sink connection point 
# ---------------------------------------------------------------------
add_interface $PREAMBLE_SINK_INTERFACE avalon_streaming sink
set_interface_property $PREAMBLE_SINK_INTERFACE ENABLED true
set_interface_property $PREAMBLE_SINK_INTERFACE ASSOCIATED_CLOCK $CLOCK_INTERFACE
set_interface_property $PREAMBLE_SINK_INTERFACE dataBitsPerSymbol $DATA_SINK_BITSPERSYMBOLS_VALUE
set_interface_property $PREAMBLE_SINK_INTERFACE errorDescriptor ""
set_interface_property $PREAMBLE_SINK_INTERFACE maxChannel 0
set_interface_property $PREAMBLE_SINK_INTERFACE readyLatency 0
set_interface_property $PREAMBLE_SINK_INTERFACE symbolsPerBeat $SYMBOLSPERBEAT_VALUE

add_interface_port $PREAMBLE_SINK_INTERFACE data_sink_data_preamble data Input 64
add_interface_port $PREAMBLE_SINK_INTERFACE data_sink_valid_preamble valid Input 1
add_interface_port $PREAMBLE_SINK_INTERFACE data_sink_ready_preamble ready Output 1


# Avalon Streaming Source connection point 
# ---------------------------------------------------------------------
add_interface $DATA_SRC_INTERFACE avalon_streaming source
set_interface_property $DATA_SRC_INTERFACE ENABLED true
set_interface_property $DATA_SRC_INTERFACE ASSOCIATED_CLOCK $CLOCK_INTERFACE
set_interface_property $DATA_SRC_INTERFACE dataBitsPerSymbol $DATA_SRC_BITSPERSYMBOLS_VALUE
set_interface_property $DATA_SRC_INTERFACE errorDescriptor ""
set_interface_property $DATA_SRC_INTERFACE maxChannel 0
set_interface_property $DATA_SRC_INTERFACE readyLatency 0
set_interface_property $DATA_SRC_INTERFACE symbolsPerBeat $SYMBOLSPERBEAT_VALUE

add_interface_port $DATA_SRC_INTERFACE data_src_data data Output -1
add_interface_port $DATA_SRC_INTERFACE data_src_sop startofpacket Output 1
add_interface_port $DATA_SRC_INTERFACE data_src_eop endofpacket Output 1
add_interface_port $DATA_SRC_INTERFACE data_src_empty empty Output -1
add_interface_port $DATA_SRC_INTERFACE data_src_valid valid Output 1
add_interface_port $DATA_SRC_INTERFACE data_src_ready ready Input 1





# ------------------------------------------------------------------------------
proc elaborate {} {

    # Interface Names
    # ---------------------------------------------------------------------
    #set CLOCK_INTERFACE                        "clk"
    set DATA_SINK_INTERFACE                     "data_sink"
	set PREAMBLE_SINK_INTERFACE                 "preamble_sink"
    set DATA_SRC_INTERFACE                      "data_src"
    
    

    # Constants
    # ---------------------------------------------------------------------
    set DATA_SINK_BITSPERSYMBOLS_VALUE          8
    set DATA_SRC_BITSPERSYMBOLS_VALUE           [expr $DATA_SINK_BITSPERSYMBOLS_VALUE + 1]

    set SYMBOLSPERBEAT_VALUE                    8
    
    
    
    # Parameters
    # ---------------------------------------------------------------------
    set ERROR_WIDTH                             [ get_parameter_value ERROR_WIDTH ]
    set GET_PREAMBLE 						    [ get_parameter_value GET_PREAMBLE ]
    
    
    # Avalon Slave connection point 
    # ---------------------------------------------------------------------
    # N/A
    
    
    
    # Avalon Streaming Sink connection point 
    # ---------------------------------------------------------------------
    set_interface_property $DATA_SINK_INTERFACE symbolsPerBeat $SYMBOLSPERBEAT_VALUE
    
    set_port_property data_sink_data WIDTH [expr {$DATA_SINK_BITSPERSYMBOLS_VALUE * $SYMBOLSPERBEAT_VALUE }]
    set_port_property data_sink_empty WIDTH [ _get_empty_width $SYMBOLSPERBEAT_VALUE ]
    set_port_property data_sink_error WIDTH $ERROR_WIDTH
    
    
	set_interface_property $PREAMBLE_SINK_INTERFACE symbolsPerBeat $SYMBOLSPERBEAT_VALUE
    set_port_property data_sink_data_preamble WIDTH [expr {$DATA_SINK_BITSPERSYMBOLS_VALUE * $SYMBOLSPERBEAT_VALUE }]
    
    
    
    

    # Avalon Streaming Source connection point 
    # ---------------------------------------------------------------------
    set_interface_property $DATA_SRC_INTERFACE symbolsPerBeat $SYMBOLSPERBEAT_VALUE
    
    set_port_property data_src_data WIDTH [expr {$DATA_SRC_BITSPERSYMBOLS_VALUE * $SYMBOLSPERBEAT_VALUE }]
    set_port_property data_src_empty WIDTH [ _get_empty_width $SYMBOLSPERBEAT_VALUE ]
	
	# Termination
	# ---------------------------------------------------------------------
	if {$GET_PREAMBLE == 0} {
    set_port_property data_sink_valid_preamble DRIVEN_BY 0
	set_port_property data_sink_valid_preamble TERMINATION true
    set_port_property data_sink_valid_preamble TERMINATION_VALUE 0 
	
	set_port_property data_sink_data_preamble DRIVEN_BY 0
	set_port_property data_sink_data_preamble TERMINATION true
    set_port_property data_sink_data_preamble TERMINATION_VALUE 0 
	
	
	set_port_property data_sink_ready_preamble TERMINATION true
    set_port_property data_sink_ready_preamble TERMINATION_VALUE 0 
	
  }
}





# ------------------------------------------------------------------------------
proc validate {} {
    
    # Parameters
    # ---------------------------------------------------------------------
    # N/A
    
    
    # Avalon Slave connection point 
    # ---------------------------------------------------------------------
    # N/A
    
    
    # Avalon Streaming Source connection point 
    # ---------------------------------------------------------------------
    # N/A
    
    
    #  Avalon Streaming Sink connection point 
    # ---------------------------------------------------------------------
    # N/A
    
}





# ------------------------------------------------------------------------------
# Utility routines
proc _get_empty_width {symbols_per_beat} {
    set empty_width [ expr int(ceil(log($symbols_per_beat) / log(2))) ]
    return $empty_width
}




