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


# $File: //acds/rel/13.1/ip/avalon_st/altera_avalon_st_pipeline_stage/altera_avalon_st_pipeline_stage_hw.tcl $
# $Revision: #2 $
# $Date: 2013/09/03 $
# $Author: wkleong $
#------------------------------------------------------------------------------

# +-----------------------------------
# | request TCL package from ACDS 9.1
# | 
package require -exact qsys 12.1
# | 
# +-----------------------------------

# +-----------------------------------
# | module altera_avalon_st_pipeline_stage
# | 
set_module_property NAME altera_avalon_st_pipeline_stage
set_module_property VERSION 13.1
set_module_property INTERNAL false
set_module_property GROUP "Bridges and Adapters/Streaming"
set_module_property DISPLAY_NAME "Avalon-ST Pipeline Stage"
set_module_property DESCRIPTION "Inserts a single pipeline (register) stage in the Avalon-ST command and response datapaths. Receives data on its Avalon-ST sink interfaces and drives it unchanged on its Avalon-ST source interface."
set_module_property AUTHOR "Altera Corporation"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false
set_module_property ELABORATION_CALLBACK elaborate
set_module_property VALIDATION_CALLBACK validate
set_module_property ANALYZE_HDL false
set_module_property DATASHEET_URL http://www.altera.com/literature/hb/qts/qsys_interconnect.pdf
# | 
# +-----------------------------------

# Utility routines
proc _get_packet_width {} {
  set use_packets [ get_parameter_value USE_PACKETS ]
  set packet_width 0
  if {$use_packets} {
    set packet_width 2
  }
  return $packet_width
}

proc _get_empty_width {} {
  set use_empty [ get_parameter_value USE_EMPTY ]
  set empty_width 0
  if {$use_empty} {
    set symbols_per_beat [ get_parameter_value SYMBOLS_PER_BEAT ]
    set empty_width [ expr int(ceil(log($symbols_per_beat) / log(2))) ]
  }
  return $empty_width
}

# | Callbacks
# | 

proc validate {} {
  set use_empty [ get_parameter_value USE_EMPTY ]
  set use_packets [ get_parameter_value USE_PACKETS ]
  if {![string compare $use_empty true] && ![string compare $use_packets false]} {
    send_message error "empty is not available without use_packets"
  }

  set symbols_per_beat [ get_parameter_value SYMBOLS_PER_BEAT ]
  if {![string compare $use_empty true] && $symbols_per_beat == 1} {
    send_message error "empty is not available when symbols_per_beat == 1"
  }
  set bits_per_symbol [ get_parameter_value BITS_PER_SYMBOL ]

  # Compute the value of derived parameters.
  # (This is redundant with code in the HDL implementation; this supports
  # two usage models, 1) component in SOPC Builder, 2) direct HDL
  # instantiation.
  set packet_width [ _get_packet_width ] 
  set_parameter_value PACKET_WIDTH $packet_width
  set empty_width [ _get_empty_width ]
  set_parameter_value EMPTY_WIDTH $empty_width

  # Calculate the required payload data width for the altera_avalon_st_pipeline_base
  # instance.  (The spec requires <= 2048.)
  set data_width [ expr $symbols_per_beat * $bits_per_symbol ]
  if { $data_width < 1 } {
    send_message error "Data Width less than 1 is not supported (SYMBOLS_PER_BEAT: $symbols_per_beat; BITS_PER_SYMBOL: $bits_per_symbol)"
  }
  set channel_width [ get_parameter_value CHANNEL_WIDTH ]
  set error_width [ get_parameter_value ERROR_WIDTH ]
  set payload_width [ 
    expr $data_width + $packet_width + $channel_width + $error_width + $empty_width
  ]
  if {$payload_width < 1 || $payload_width > 2048} {
    send_message error "Payload width $payload_width is not supported."
  }
}

proc elaborate {} {
  set symbols_per_beat [ get_parameter_value SYMBOLS_PER_BEAT ]
  set bits_per_symbol [ get_parameter_value BITS_PER_SYMBOL ]

  set_interface_property sink0 dataBitsPerSymbol $bits_per_symbol
  set_interface_property sink0 symbolsPerBeat $symbols_per_beat
  set_interface_property source0 dataBitsPerSymbol $bits_per_symbol
  set_interface_property source0 symbolsPerBeat $symbols_per_beat

  set data_width [ expr $symbols_per_beat * $bits_per_symbol ]

  add_interface_port sink0 in_data data Input $data_width
  set_port_property  in_data vhdl_type std_logic_vector
  add_interface_port source0 out_data data Output $data_width 
  set_port_property  out_data vhdl_type std_logic_vector

  set channel_width [ get_parameter_value CHANNEL_WIDTH ]
  if {$channel_width > 0} {
    set max [ expr (-1 + (1 << $channel_width)) ]

    add_interface_port source0 out_channel channel Output $channel_width
	set_port_property  out_channel vhdl_type std_logic_vector
    add_interface_port sink0 in_channel channel Input $channel_width
	set_port_property  in_channel vhdl_type std_logic_vector
  } else {
    add_interface_port source0 out_channel channel Output 1
    set_port_property out_channel vhdl_type std_logic_vector
    add_interface_port sink0 in_channel channel Input 1
    set_port_property in_channel vhdl_type std_logic_vector

    set_port_property out_channel TERMINATION true
    set_port_property in_channel TERMINATION true
    set_port_property in_channel TERMINATION_VALUE 0
  }

  set max [ get_parameter_value MAX_CHANNEL ]
  set_interface_property sink0 maxChannel $max
  set_interface_property source0 maxChannel $max

  set_port_property in_startofpacket WIDTH_EXPR 1
  set_port_property in_endofpacket WIDTH_EXPR 1
  set_port_property out_startofpacket WIDTH_EXPR 1
  set_port_property out_endofpacket WIDTH_EXPR 1
  if {[ get_parameter_value USE_PACKETS ]} {
  } else {
    set_port_property in_startofpacket TERMINATION true
    set_port_property in_startofpacket TERMINATION_VALUE 0
    set_port_property out_startofpacket TERMINATION true
    set_port_property in_endofpacket TERMINATION true
    set_port_property in_endofpacket TERMINATION_VALUE 0
    set_port_property out_endofpacket TERMINATION true
  }

  if {[ get_parameter_value USE_EMPTY ]} {
    set empty_width [ _get_empty_width ]
    set_port_property in_empty WIDTH_EXPR $empty_width
	set_port_property  in_empty vhdl_type std_logic_vector
    set_port_property out_empty WIDTH_EXPR $empty_width
	set_port_property  out_empty vhdl_type std_logic_vector
  } else {
    set_port_property in_empty WIDTH_EXPR 1
    set_port_property  in_empty vhdl_type std_logic_vector
    set_port_property out_empty WIDTH_EXPR 1
    set_port_property  out_empty vhdl_type std_logic_vector
    set_port_property in_empty TERMINATION true
    set_port_property in_empty TERMINATION_VALUE 0
    set_port_property out_empty TERMINATION true
  }

  set error_width [ get_parameter_value ERROR_WIDTH ]
  if {$error_width > 0} {
    set_port_property in_error WIDTH_EXPR $error_width
	set_port_property  in_error vhdl_type std_logic_vector
    set_port_property out_error WIDTH_EXPR $error_width
	set_port_property  out_error vhdl_type std_logic_vector
  } else {
    set_port_property in_error WIDTH_EXPR 1
    set_port_property  in_error vhdl_type std_logic_vector
    set_port_property out_error WIDTH_EXPR 1
    set_port_property  out_error vhdl_type std_logic_vector
    set_port_property in_error TERMINATION true
    set_port_property in_error TERMINATION_VALUE 0
    set_port_property out_error TERMINATION true
  }
}

# +-----------------------------------
# | files
# | 

add_fileset synthesis_fileset QUARTUS_SYNTH synth_callback_procedure
set_fileset_property synthesis_fileset TOP_LEVEL altera_avalon_st_pipeline_stage 
add_fileset simulation_fileset SIM_VERILOG synth_callback_procedure
set_fileset_property simulation_fileset TOP_LEVEL altera_avalon_st_pipeline_stage
add_fileset vhdl_fileset SIM_VHDL synth_callback_procedure_vhdl
set_fileset_property vhdl_fileset TOP_LEVEL altera_avalon_st_pipeline_stage

proc synth_callback_procedure { entity_name } {
    add_fileset_file altera_avalon_st_pipeline_stage.sv SYSTEM_VERILOG PATH "altera_avalon_st_pipeline_stage.sv"
	add_fileset_file altera_avalon_st_pipeline_base.v SYSTEM_VERILOG PATH "altera_avalon_st_pipeline_base.v"
}

proc synth_callback_procedure_vhdl { entity_name } {
   if {1} {
      add_fileset_file mentor/altera_avalon_st_pipeline_stage.sv SYSTEM_VERILOG_ENCRYPT PATH "mentor/altera_avalon_st_pipeline_stage.sv" {MENTOR_SPECIFIC}
	  add_fileset_file mentor/altera_avalon_st_pipeline_base.v SYSTEM_VERILOG_ENCRYPT PATH "mentor/altera_avalon_st_pipeline_base.v" {MENTOR_SPECIFIC}
   }
   if {1} {
      add_fileset_file aldec/altera_avalon_st_pipeline_stage.sv SYSTEM_VERILOG_ENCRYPT PATH "aldec/altera_avalon_st_pipeline_stage.sv" {ALDEC_SPECIFIC}
	  add_fileset_file aldec/altera_avalon_st_pipeline_base.v SYSTEM_VERILOG_ENCRYPT PATH "aldec/altera_avalon_st_pipeline_base.v" {ALDEC_SPECIFIC}
   }
   if {0} {
      add_fileset_file cadence/altera_avalon_st_pipeline_stage.sv SYSTEM_VERILOG_ENCRYPT PATH "cadence/altera_avalon_st_pipeline_stage.sv" {CADENCE_SPECIFIC}
	  add_fileset_file cadence/altera_avalon_st_pipeline_base.v SYSTEM_VERILOG_ENCRYPT PATH "cadence/altera_avalon_st_pipeline_base.v" {CADENCE_SPECIFIC}
   }
   if {0} {
      add_fileset_file synopsys/altera_avalon_st_pipeline_stage.sv SYSTEM_VERILOG_ENCRYPT PATH "synopsys/altera_avalon_st_pipeline_stage.sv" {SYNOPSYS_SPECIFIC}
	  add_fileset_file synopsys/altera_avalon_st_pipeline_base.v SYSTEM_VERILOG_ENCRYPT PATH "synopsys/altera_avalon_st_pipeline_base.v" {SYNOPSYS_SPECIFIC}
   }    
}

# | 
# +-----------------------------------
# +-----------------------------------
# | parameters
# | 
add_parameter SYMBOLS_PER_BEAT INTEGER 1
set_parameter_property SYMBOLS_PER_BEAT DISPLAY_NAME "Symbols per beat"
set_parameter_property SYMBOLS_PER_BEAT DESCRIPTION {Symbols per beat}
set_parameter_property SYMBOLS_PER_BEAT UNITS None
set_parameter_property SYMBOLS_PER_BEAT AFFECTS_GENERATION false
set_parameter_property SYMBOLS_PER_BEAT IS_HDL_PARAMETER true
set_parameter_property SYMBOLS_PER_BEAT ALLOWED_RANGES 1:256
add_parameter BITS_PER_SYMBOL INTEGER 8
set_parameter_property BITS_PER_SYMBOL DISPLAY_NAME "Bits per symbol"
set_parameter_property BITS_PER_SYMBOL DESCRIPTION {Bits per symbol}
set_parameter_property BITS_PER_SYMBOL UNITS None
set_parameter_property BITS_PER_SYMBOL AFFECTS_GENERATION false
set_parameter_property BITS_PER_SYMBOL IS_HDL_PARAMETER true
set_parameter_property BITS_PER_SYMBOL ALLOWED_RANGES 1:2048
add_parameter USE_PACKETS INTEGER 0 "If enabled, include optional startofpacket and endofpacket signals"
set_parameter_property USE_PACKETS DISPLAY_NAME "Use packets"
set_parameter_property USE_PACKETS DISPLAY_HINT boolean
set_parameter_property USE_PACKETS UNITS None
set_parameter_property USE_PACKETS AFFECTS_GENERATION false
set_parameter_property USE_PACKETS AFFECTS_ELABORATION true
set_parameter_property USE_PACKETS GROUP "Packet options"
set_parameter_property USE_PACKETS IS_HDL_PARAMETER true
add_parameter USE_EMPTY INTEGER 0 "If enabled, include optional empty signal"
set_parameter_property USE_EMPTY DISPLAY_NAME "Use empty"
set_parameter_property USE_EMPTY UNITS None
set_parameter_property USE_EMPTY DISPLAY_HINT boolean
set_parameter_property USE_EMPTY AFFECTS_GENERATION false
set_parameter_property USE_EMPTY AFFECTS_ELABORATION true
set_parameter_property USE_EMPTY GROUP "Packet options"
set_parameter_property USE_EMPTY IS_HDL_PARAMETER true
add_parameter EMPTY_WIDTH INTEGER 0
set_parameter_property EMPTY_WIDTH DISPLAY_NAME "Empty width"
set_parameter_property EMPTY_WIDTH DESCRIPTION {Displays the automatically calculated width of the Avalon-ST empty signal for the pipeline stage.}
set_parameter_property EMPTY_WIDTH UNITS None
set_parameter_property EMPTY_WIDTH AFFECTS_GENERATION false
set_parameter_property EMPTY_WIDTH AFFECTS_ELABORATION true
set_parameter_property EMPTY_WIDTH IS_HDL_PARAMETER true
set_parameter_property EMPTY_WIDTH DERIVED true
set_parameter_property EMPTY_WIDTH GROUP "Derived parameters"
add_parameter CHANNEL_WIDTH INTEGER 0 "If non-zero, include optional channel signal"
set_parameter_property CHANNEL_WIDTH DISPLAY_NAME "Channel width"
set_parameter_property CHANNEL_WIDTH UNITS None
set_parameter_property CHANNEL_WIDTH AFFECTS_GENERATION false
set_parameter_property CHANNEL_WIDTH AFFECTS_ELABORATION true
set_parameter_property CHANNEL_WIDTH IS_HDL_PARAMETER true
set_parameter_property CHANNEL_WIDTH ALLOWED_RANGES 0:31

add_parameter MAX_CHANNEL INTEGER 0 "Sets the maximum channel value on the source and sink interfaces"
set_parameter_property MAX_CHANNEL DISPLAY_NAME "Maximum channel value"
set_parameter_property MAX_CHANNEL AFFECTS_ELABORATION true
set_parameter_property MAX_CHANNEL AFFECTS_GENERATION false
set_parameter_property MAX_CHANNEL IS_HDL_PARAMETER false
set_parameter_property MAX_CHANNEL ALLOWED_RANGES 0:2147483647

add_parameter PACKET_WIDTH INTEGER 0
set_parameter_property PACKET_WIDTH DISPLAY_NAME "Packet width"
set_parameter_property PACKET_WIDTH DESCRIPTION {Display the automatically calculated width of the Avalon-ST packet signals for the pipeline stage (sop + eop + empty_width).}
set_parameter_property PACKET_WIDTH UNITS None
set_parameter_property PACKET_WIDTH AFFECTS_GENERATION false
set_parameter_property PACKET_WIDTH AFFECTS_ELABORATION true
set_parameter_property PACKET_WIDTH IS_HDL_PARAMETER true
set_parameter_property PACKET_WIDTH DERIVED true
set_parameter_property PACKET_WIDTH GROUP "Derived parameters"
add_parameter ERROR_WIDTH INTEGER 0 "If non-zero, include optional error signal"
set_parameter_property ERROR_WIDTH DISPLAY_NAME "Error width"
set_parameter_property ERROR_WIDTH UNITS None
set_parameter_property ERROR_WIDTH AFFECTS_GENERATION false
set_parameter_property ERROR_WIDTH AFFECTS_ELABORATION true
set_parameter_property ERROR_WIDTH IS_HDL_PARAMETER true
set_parameter_property ERROR_WIDTH ALLOWED_RANGES 0:255
add_parameter PIPELINE_READY INTEGER 1 "If cleared, instantiate single stage pipeline"
set_parameter_property PIPELINE_READY DISPLAY_NAME "Pipeline ready signal"
set_parameter_property PIPELINE_READY DISPLAY_HINT boolean
set_parameter_property PIPELINE_READY UNITS None
set_parameter_property PIPELINE_READY AFFECTS_GENERATION false
set_parameter_property PIPELINE_READY AFFECTS_ELABORATION true
set_parameter_property PIPELINE_READY IS_HDL_PARAMETER true
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point cr0
# | 
add_interface cr0 clock end
set_interface_property cr0 ptfSchematicName ""

set_interface_property cr0 ENABLED true
set_interface_property cr0 EXPORT_OF true

add_interface_port cr0 clk clk Input 1
add_interface_port cr0 reset reset Input 1
# | 
# +-----------------------------------


# +-----------------------------------
# | connection point sink0
# | 
add_interface sink0 avalon_streaming end
set_interface_property sink0 dataBitsPerSymbol 1
set_interface_property sink0 errorDescriptor ""
set_interface_property sink0 readyLatency 0
set_interface_property sink0 symbolsPerBeat 1

set_interface_property sink0 ASSOCIATED_CLOCK cr0
set_interface_property sink0 ENABLED true
set_interface_property sink0 EXPORT_OF true

# | 
# +-----------------------------------

# +-----------------------------------
# | connection point source0
# | 
add_interface source0 avalon_streaming start
set_interface_property source0 dataBitsPerSymbol 1
set_interface_property source0 errorDescriptor ""
set_interface_property source0 readyLatency 0
set_interface_property source0 symbolsPerBeat 1

set_interface_property source0 ASSOCIATED_CLOCK cr0
set_interface_property source0 ENABLED true
set_interface_property source0 EXPORT_OF true

# | 
# +-----------------------------------


# Add always-present ports ready, valid, data.
add_interface_port sink0 in_ready ready Output 1
add_interface_port sink0 in_valid valid Input 1
add_interface_port sink0 in_data data Input 1
add_interface_port source0 out_ready ready Input 1
add_interface_port source0 out_valid valid Output 1
add_interface_port source0 out_data data Output 1


# For all optional ports: add and terminate, supplying termination value for
# inputs.  If an optional port turns out to exist, the elaboration callback
# will 1) unterminate the port, 2) set its width.
# Add and terminate channel ports

# Add and terminate sop, eop ports.
add_interface_port sink0 in_startofpacket startofpacket Input 1
add_interface_port sink0 in_endofpacket endofpacket Input 1
add_interface_port source0 out_startofpacket startofpacket Output 1
add_interface_port source0 out_endofpacket endofpacket Output 1

# Add and terminate empty ports.
add_interface_port sink0 in_empty empty Input 1
add_interface_port source0 out_empty empty Output 1

# Add and terminate error ports.
add_interface_port source0 out_error error Output 1
add_interface_port sink0 in_error error Input 1


