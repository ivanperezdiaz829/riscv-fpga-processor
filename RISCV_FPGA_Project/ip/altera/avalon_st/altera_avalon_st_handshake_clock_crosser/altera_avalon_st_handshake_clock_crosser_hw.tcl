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


# $File: //acds/rel/13.1/ip/avalon_st/altera_avalon_st_handshake_clock_crosser/altera_avalon_st_handshake_clock_crosser_hw.tcl $
# $Revision: #2 $
# $Date: 2013/08/19 $
# $Author: tgngo $
#------------------------------------------------------------------------------

# +-----------------------------------
# | 
# | Avalon-ST Handshake Clock Crosser 
# | 
# +-----------------------------------

package require -exact sopc 9.1

# +-----------------------------------
# | module 
# | 
set_module_property DESCRIPTION "Connects streams that operate at different frequencie using a hand-shaking protocol to propagate transfer control signals and responses across the clock boundary and responses in the other direction."
set_module_property NAME altera_avalon_st_handshake_clock_crosser
set_module_property VERSION 13.1
set_module_property GROUP "Bridges and Adapters/Streaming"
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "Avalon-ST Handshake Clock Crosser"
set_module_property TOP_LEVEL_HDL_FILE altera_avalon_st_handshake_clock_crosser.v
set_module_property TOP_LEVEL_HDL_MODULE altera_avalon_st_handshake_clock_crosser
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false
set_module_property INTERNAL true
set_module_property ELABORATION_CALLBACK elaborate
set_module_property SIMULATION_MODEL_IN_VHDL true
set_module_property ANALYZE_HDL false
set_module_property DATASHEET_URL http://www.altera.com/literature/hb/qts/qsys_interconnect.pdf
# | 
# +-----------------------------------

# +-----------------------------------
# | files
# | 
# | shame that the source tree doesn't match the build tree
# +-----------------------------------
#add_file altera_avalon_st_handshake_clock_crosser.v {SYNTHESIS SIMULATION}
#add_file altera_avalon_st_clock_crosser.v {SYNTHESIS SIMULATION}
#add_file ../altera_avalon_st_pipeline_stage/altera_avalon_st_pipeline_base.v {SYNTHESIS SIMULATION}

add_fileset synthesis_fileset QUARTUS_SYNTH synth_callback_procedure
set_fileset_property synthesis_fileset TOP_LEVEL altera_avalon_st_handshake_clock_crosser
add_fileset simulation_fileset SIM_VERILOG synth_callback_procedure
set_fileset_property simulation_fileset TOP_LEVEL altera_avalon_st_handshake_clock_crosser
add_fileset vhdl_fileset SIM_VHDL synth_callback_procedure_vhdl
set_fileset_property vhdl_fileset TOP_LEVEL altera_avalon_st_handshake_clock_crosser

proc synth_callback_procedure { entity_name } {
    add_fileset_file altera_avalon_st_handshake_clock_crosser.v SYSTEM_VERILOG PATH "altera_avalon_st_handshake_clock_crosser.v"
    add_fileset_file altera_avalon_st_clock_crosser.v SYSTEM_VERILOG PATH "altera_avalon_st_clock_crosser.v"
    add_fileset_file altera_avalon_st_pipeline_base.v SYSTEM_VERILOG PATH "../altera_avalon_st_pipeline_stage/altera_avalon_st_pipeline_base.v"
}

proc synth_callback_procedure_vhdl { entity_name } {
   if {1} {
      add_fileset_file mentor/altera_avalon_st_handshake_clock_crosser.v SYSTEM_VERILOG_ENCRYPT PATH "mentor/altera_avalon_st_handshake_clock_crosser.v" {MENTOR_SPECIFIC}
      add_fileset_file mentor/altera_avalon_st_clock_crosser.v SYSTEM_VERILOG_ENCRYPT PATH "mentor/altera_avalon_st_clock_crosser.v" {MENTOR_SPECIFIC}
      add_fileset_file mentor/altera_avalon_st_pipeline_base.v SYSTEM_VERILOG_ENCRYPT PATH "../altera_avalon_st_pipeline_stage/mentor/altera_avalon_st_pipeline_base.v" {MENTOR_SPECIFIC}
   }
   if {1} {
      add_fileset_file aldec/altera_avalon_st_handshake_clock_crosser.v SYSTEM_VERILOG_ENCRYPT PATH "aldec/altera_avalon_st_handshake_clock_crosser.v" {ALDEC_SPECIFIC}
      add_fileset_file aldec/altera_avalon_st_clock_crosser.v SYSTEM_VERILOG_ENCRYPT PATH "aldec/altera_avalon_st_clock_crosser.v" {ALDEC_SPECIFIC}
      add_fileset_file aldec/altera_avalon_st_pipeline_base.v SYSTEM_VERILOG_ENCRYPT PATH "../altera_avalon_st_pipeline_stage/aldec/altera_avalon_st_pipeline_base.v" {ALDEC_SPECIFIC}   
   }
   if {0} {
      add_fileset_file cadence/altera_avalon_st_handshake_clock_crosser.v SYSTEM_VERILOG_ENCRYPT PATH "cadence/altera_avalon_st_handshake_clock_crosser.v" {CADENCE_SPECIFIC}
      add_fileset_file cadence/altera_avalon_st_clock_crosser.v SYSTEM_VERILOG_ENCRYPT PATH "cadence/altera_avalon_st_clock_crosser.v" {CADENCE_SPECIFIC}
      add_fileset_file cadence/altera_avalon_st_pipeline_base.v SYSTEM_VERILOG_ENCRYPT PATH "../altera_avalon_st_pipeline_stage/cadence/altera_avalon_st_pipeline_base.v" {CADENCE_SPECIFIC}   
   }
   if {0} {
      add_fileset_file synopsys/altera_avalon_st_handshake_clock_crosser.v SYSTEM_VERILOG_ENCRYPT PATH "synopsys/altera_avalon_st_handshake_clock_crosser.v" {SYNOPSYS_SPECIFIC}
      add_fileset_file synopsys/altera_avalon_st_clock_crosser.v SYSTEM_VERILOG_ENCRYPT PATH "synopsys/altera_avalon_st_clock_crosser.v" {SYNOPSYS_SPECIFIC}
      add_fileset_file synopsys/altera_avalon_st_pipeline_base.v SYSTEM_VERILOG_ENCRYPT PATH "../altera_avalon_st_pipeline_stage/synopsys/altera_avalon_st_pipeline_base.v" {SYNOPSYS_SPECIFIC}   
   }   
}

# +-----------------------------------
# | parameters
# | 
add_parameter DATA_WIDTH INTEGER 8
set_parameter_property DATA_WIDTH DISPLAY_NAME "Data width" 
set_parameter_property DATA_WIDTH DESCRIPTION {Specifies the width of the data signal.}
set_parameter_property DATA_WIDTH UNITS None
set_parameter_property DATA_WIDTH DISPLAY_HINT ""
set_parameter_property DATA_WIDTH AFFECTS_GENERATION false
set_parameter_property DATA_WIDTH AFFECTS_ELABORATION true
set_parameter_property DATA_WIDTH HDL_PARAMETER true

add_parameter BITS_PER_SYMBOL INTEGER 8
set_parameter_property BITS_PER_SYMBOL DISPLAY_NAME "Bits per symbol" 
set_parameter_property BITS_PER_SYMBOL DESCRIPTION {Specifies the number of bits per symbol which is 8 for byte-oriented data}
set_parameter_property BITS_PER_SYMBOL UNITS None
set_parameter_property BITS_PER_SYMBOL DISPLAY_HINT ""
set_parameter_property BITS_PER_SYMBOL AFFECTS_ELABORATION true
set_parameter_property BITS_PER_SYMBOL HDL_PARAMETER true

add_parameter USE_PACKETS INTEGER 0 0
set_parameter_property USE_PACKETS DISPLAY_NAME "Use packets" 
set_parameter_property USE_PACKETS DESCRIPTION {When enabled, the data source and sink transfer data in packets}
set_parameter_property USE_PACKETS UNITS None
set_parameter_property USE_PACKETS ALLOWED_RANGES 0:1
set_parameter_property USE_PACKETS DISPLAY_HINT boolean
set_parameter_property USE_PACKETS AFFECTS_ELABORATION true
set_parameter_property USE_PACKETS HDL_PARAMETER true

add_parameter USE_CHANNEL INTEGER 0 0
set_parameter_property USE_CHANNEL DISPLAY_NAME "Use channel"
set_parameter_property USE_CHANNEL DESCRIPTION {When enabled, there are multiple channels}
set_parameter_property USE_CHANNEL UNITS None
set_parameter_property USE_CHANNEL ALLOWED_RANGES 0:1
set_parameter_property USE_CHANNEL DISPLAY_HINT boolean
set_parameter_property USE_CHANNEL AFFECTS_ELABORATION true
set_parameter_property USE_CHANNEL HDL_PARAMETER true

add_parameter CHANNEL_WIDTH INTEGER 1 0
set_parameter_property CHANNEL_WIDTH DISPLAY_NAME "Channel width" 
set_parameter_property CHANNEL_WIDTH DESCRIPTION {Specifies the width of the channel signal}
set_parameter_property CHANNEL_WIDTH UNITS None
set_parameter_property CHANNEL_WIDTH ALLOWED_RANGES 1:1024
set_parameter_property CHANNEL_WIDTH DISPLAY_HINT ""
set_parameter_property CHANNEL_WIDTH AFFECTS_ELABORATION true
set_parameter_property CHANNEL_WIDTH HDL_PARAMETER true

add_parameter MAX_CHANNEL INTEGER 0 0
set_parameter_property MAX_CHANNEL DISPLAY_NAME "Maximum channel value" 
set_parameter_property MAX_CHANNEL DESCRIPTION {Specifies the maximum number of channels}
set_parameter_property MAX_CHANNEL UNITS None
set_parameter_property MAX_CHANNEL DISPLAY_HINT ""
set_parameter_property MAX_CHANNEL AFFECTS_ELABORATION true
set_parameter_property MAX_CHANNEL HDL_PARAMETER false

add_parameter USE_ERROR INTEGER 0 0
set_parameter_property USE_ERROR DISPLAY_NAME "Use error"
set_parameter_property USE_ERROR DESCRIPTION {When enabled, the error signal is used}
set_parameter_property USE_ERROR UNITS None
set_parameter_property USE_ERROR ALLOWED_RANGES 0:1
set_parameter_property USE_ERROR DISPLAY_HINT boolean
set_parameter_property USE_ERROR AFFECTS_ELABORATION true
set_parameter_property USE_ERROR HDL_PARAMETER true

add_parameter ERROR_WIDTH INTEGER 1 0
set_parameter_property ERROR_WIDTH DISPLAY_NAME "Error width" 
set_parameter_property ERROR_WIDTH DESCRIPTION {Specifies the width of the error signal}
set_parameter_property ERROR_WIDTH UNITS None
set_parameter_property ERROR_WIDTH ALLOWED_RANGES 1:1024
set_parameter_property ERROR_WIDTH DISPLAY_HINT ""
set_parameter_property ERROR_WIDTH AFFECTS_ELABORATION true
set_parameter_property ERROR_WIDTH HDL_PARAMETER true

add_parameter VALID_SYNC_DEPTH INTEGER 2
set_parameter_property VALID_SYNC_DEPTH DISPLAY_NAME "Valid synchronizer depth"
set_parameter_property VALID_SYNC_DEPTH DESCRIPTION {Specifies the depth of the synchronizer for the valid handshake signal}
set_parameter_property VALID_SYNC_DEPTH UNITS None
set_parameter_property VALID_SYNC_DEPTH DISPLAY_HINT ""
set_parameter_property VALID_SYNC_DEPTH AFFECTS_GENERATION false
set_parameter_property VALID_SYNC_DEPTH HDL_PARAMETER true

add_parameter READY_SYNC_DEPTH INTEGER 2
set_parameter_property READY_SYNC_DEPTH DISPLAY_NAME "Ready synchronizer depth"
set_parameter_property READY_SYNC_DEPTH DESCRIPTION {Specifies the depth of the synchronizer for the ready handshake signal}
set_parameter_property READY_SYNC_DEPTH UNITS None
set_parameter_property READY_SYNC_DEPTH DISPLAY_HINT ""
set_parameter_property READY_SYNC_DEPTH AFFECTS_GENERATION false
set_parameter_property READY_SYNC_DEPTH HDL_PARAMETER true

add_parameter USE_OUTPUT_PIPELINE INTEGER 1
set_parameter_property USE_OUTPUT_PIPELINE DISPLAY_NAME "Use output pipeline"
set_parameter_property USE_OUTPUT_PIPELINE DESCRIPTION {Adds an additional pipeline stage to the output of the Clock Crosser to increase fmax.}
set_parameter_property USE_OUTPUT_PIPELINE UNITS None
set_parameter_property USE_OUTPUT_PIPELINE ALLOWED_RANGES 0:1
set_parameter_property USE_OUTPUT_PIPELINE DISPLAY_HINT "boolean"
set_parameter_property USE_OUTPUT_PIPELINE AFFECTS_GENERATION false
set_parameter_property USE_OUTPUT_PIPELINE HDL_PARAMETER true

# | 
# +-----------------------------------

# +-----------------------------------
# | connection point in_clk
# | 
add_interface in_clk clock end
set_interface_property in_clk ptfSchematicName ""

set_interface_property in_clk ENABLED true

add_interface_port in_clk in_clk clk Input 1
add_interface_port in_clk in_reset reset Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point out_clk
# | 
add_interface out_clk clock end
set_interface_property out_clk ptfSchematicName ""

set_interface_property out_clk ENABLED true

add_interface_port out_clk out_clk clk Input 1
add_interface_port out_clk out_reset reset Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point in
# | 
add_interface in avalon_streaming end
set_interface_property in dataBitsPerSymbol 8
set_interface_property in errorDescriptor ""
set_interface_property in maxChannel 0
set_interface_property in readyLatency 0
set_interface_property in symbolsPerBeat 1

set_interface_property in ASSOCIATED_CLOCK in_clk
set_interface_property in ENABLED true

add_interface_port in in_ready ready Output 1
add_interface_port in in_valid valid Input  1
add_interface_port in in_startofpacket startofpacket Input  1
add_interface_port in in_endofpacket endofpacket Input  1
add_interface_port in in_empty empty Input 1
add_interface_port in in_channel channel Input 1
add_interface_port in in_error error Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point out
# | 
add_interface out avalon_streaming start
set_interface_property out dataBitsPerSymbol 8
set_interface_property out errorDescriptor ""
set_interface_property out maxChannel 0
set_interface_property out readyLatency 0
set_interface_property out symbolsPerBeat 1

set_interface_property out ASSOCIATED_CLOCK out_clk
set_interface_property out ENABLED true

add_interface_port out out_ready ready Input 1
add_interface_port out out_valid valid Output 1
add_interface_port out out_startofpacket startofpacket Output 1
add_interface_port out out_endofpacket endofpacket Output 1
add_interface_port out out_empty empty Output 1
add_interface_port out out_channel channel Output 1
add_interface_port out out_error error Output 1
# | 
# +-----------------------------------

# +-----------------------------------
# | Elaborate
# | 

proc elaborate {} {
  set bits_per_symbol  [ get_parameter_value BITS_PER_SYMBOL ]
  set data_width       [ get_parameter_value DATA_WIDTH ]
  set use_packets      [ get_parameter_value USE_PACKETS ]
  set symbols_per_beat [ expr $data_width / $bits_per_symbol ]
  set channel_width    [ get_parameter_value CHANNEL_WIDTH ]
  set use_channel      [ get_parameter_value USE_CHANNEL ]
  set error_width      [ get_parameter_value ERROR_WIDTH ]
  set use_error        [ get_parameter_value USE_ERROR ]
  set max_channel      [ get_parameter_value MAX_CHANNEL ]
  set need_empty       [ expr $use_packets && ($symbols_per_beat > 1) ]
  set empty_width      [ expr (int(ceil(log($symbols_per_beat) / log(2)))) ]

  add_interface_port in in_data data Input $data_width 
  add_interface_port out out_data data Output $data_width 

  set_interface_property in dataBitsPerSymbol $bits_per_symbol
  set_interface_property out dataBitsPerSymbol $bits_per_symbol
  set_port_property  in_data vhdl_type std_logic_vector
  set_port_property  out_data vhdl_type std_logic_vector

  if { $use_packets } {
      set_port_property in_startofpacket TERMINATION false
      set_port_property out_startofpacket TERMINATION false
      set_port_property in_endofpacket TERMINATION false
      set_port_property out_endofpacket TERMINATION false
  } else {
      set_port_property in_startofpacket TERMINATION true
      set_port_property out_startofpacket TERMINATION true
      set_port_property in_endofpacket TERMINATION true
      set_port_property out_endofpacket TERMINATION true
  }

  if { $need_empty } {
      set_port_property in_empty TERMINATION false
      set_port_property out_empty TERMINATION false

      set_port_property in_empty WIDTH $empty_width
      set_port_property out_empty WIDTH $empty_width
  } else {
      set_port_property in_empty TERMINATION true
      set_port_property out_empty TERMINATION true

      set_port_property in_empty WIDTH 1
      set_port_property out_empty WIDTH 1
  }
  	set_port_property in_empty vhdl_type std_logic_vector
	set_port_property out_empty vhdl_type std_logic_vector

  set_interface_property in maxChannel $max_channel
  set_interface_property out maxChannel $max_channel
  if { $use_channel } {
      set_port_property in_channel TERMINATION false
      set_port_property out_channel TERMINATION false
      set_port_property in_channel WIDTH $channel_width
      set_port_property out_channel WIDTH $channel_width
  } else {
      set_port_property in_channel TERMINATION true
      set_port_property out_channel TERMINATION true
      set_port_property in_channel WIDTH 1
      set_port_property out_channel WIDTH 1
  }
  	  set_port_property in_channel vhdl_type std_logic_vector
	  set_port_property out_channel vhdl_type std_logic_vector

  if { $use_error } {
      set_port_property in_error TERMINATION false
      set_port_property out_error TERMINATION false
      set_port_property in_error WIDTH $error_width
      set_port_property out_error WIDTH $error_width
  } else {
      set_port_property in_error TERMINATION true
      set_port_property out_error TERMINATION true
      set_port_property in_error WIDTH 1
      set_port_property out_error WIDTH 1
  }
  set_port_property in_error vhdl_type std_logic_vector
  set_port_property out_error vhdl_type std_logic_vector

}
