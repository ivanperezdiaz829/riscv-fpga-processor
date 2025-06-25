# +-----------------------------------
# | 
# | altera_avalon_st_packets_to_bytes "Avalon-ST Packets to Bytes Converter"
# | Altera Corporation 2008.08.07.21:52:51
# | Avalon-ST Packets to Bytes Converter
# | 
# | ./altera_avalon_st_packets_to_bytes.v
# | 
# |    ./altera_avalon_st_packets_to_bytes.v syn, sim
# | 
# +-----------------------------------

package require -exact sopc 9.1

# +-----------------------------------
# | module altera_avalon_st_packets_to_bytes
# | 
set_module_property DESCRIPTION "Avalon-ST Packets to Bytes Converter"
set_module_property NAME altera_avalon_st_packets_to_bytes
set_module_property VERSION 13.1
set_module_property GROUP "Bridges and Adapters/Streaming"
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "Avalon-ST Packets to Bytes Converter"
set_module_property DATASHEET_URL http://www.altera.com/literature/hb/nios2/qts_qii55012.pdf
set_module_property TOP_LEVEL_HDL_FILE altera_avalon_st_packets_to_bytes.v
set_module_property TOP_LEVEL_HDL_MODULE altera_avalon_st_packets_to_bytes
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false
set_module_property SIMULATION_MODEL_IN_VHDL true
set_module_property ANALYZE_HDL false
# | 
# +-----------------------------------

# +-----------------------------------
# | files
# | 
add_file altera_avalon_st_packets_to_bytes.v {SYNTHESIS SIMULATION}
# | 
# +-----------------------------------

# +-----------------------------------
# | parameters
# | 

# | 
# +-----------------------------------
add_parameter CHANNEL_WIDTH INTEGER 8
set_parameter_property CHANNEL_WIDTH DISPLAY_NAME "Channel Width"
set_parameter_property CHANNEL_WIDTH ALLOWED_RANGES {0:127} 
set_parameter_property CHANNEL_WIDTH STATUS experimental
set_parameter_property CHANNEL_WIDTH HDL_PARAMETER true

add_parameter CHANNEL_WIDTH_DERIVED INTEGER 8
set_parameter_property CHANNEL_WIDTH_DERIVED ALLOWED_RANGES {0:127} 
set_parameter_property CHANNEL_WIDTH_DERIVED VISIBLE false
set_parameter_property CHANNEL_WIDTH_DERIVED DERIVED true

add_parameter ENCODING INTEGER 0
set_parameter_property ENCODING DISPLAY_NAME "Encoding"
set_parameter_property ENCODING ALLOWED_RANGES {"0:8 bit" "1:Variable length"}
set_parameter_property ENCODING STATUS experimental
set_parameter_property ENCODING HDL_PARAMETER true

# +-----------------------------------
# | connection point clk
# | 
add_interface clk clock end
set_interface_property clk ptfSchematicName ""

add_interface_port clk clk clk Input 1
add_interface_port clk reset_n reset_n Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point in_packets_stream
# | 
add_interface in_packets_stream avalon_streaming end
set_interface_property in_packets_stream dataBitsPerSymbol 8
set_interface_property in_packets_stream errorDescriptor ""
set_interface_property in_packets_stream maxChannel 1
set_interface_property in_packets_stream readyLatency 0
set_interface_property in_packets_stream symbolsPerBeat 1

set_interface_property in_packets_stream ASSOCIATED_CLOCK clk

add_interface_port in_packets_stream in_ready ready Output 1
add_interface_port in_packets_stream in_valid valid Input 1
add_interface_port in_packets_stream in_data data Input 8
add_interface_port in_packets_stream in_channel channel Input CHANNEL_WIDTH_DERIVED
add_interface_port in_packets_stream in_startofpacket startofpacket Input 1
add_interface_port in_packets_stream in_endofpacket endofpacket Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point out_bytes_stream
# | 
add_interface out_bytes_stream avalon_streaming start
set_interface_property out_bytes_stream dataBitsPerSymbol 8
set_interface_property out_bytes_stream errorDescriptor ""
set_interface_property out_bytes_stream maxChannel 0
set_interface_property out_bytes_stream readyLatency 0
set_interface_property out_bytes_stream symbolsPerBeat 1

set_interface_property out_bytes_stream ASSOCIATED_CLOCK clk

add_interface_port out_bytes_stream out_ready ready Input 1
add_interface_port out_bytes_stream out_valid valid Output 1
add_interface_port out_bytes_stream out_data data Output 8
# | 
# +-----------------------------------

# +-----------------------------------
# | elaboration call back
# | 
set_module_property ELABORATION_CALLBACK check_maxchannel_callback
proc check_maxchannel_callback {} {
   set channel_w [get_parameter_value CHANNEL_WIDTH]
   set encoding_value  [get_parameter_value ENCODING]

   if { $encoding_value == 0 } {
      set_parameter_property CHANNEL_WIDTH ENABLED FALSE
      
      set_port_property in_channel TERMINATION false
      set_parameter_value CHANNEL_WIDTH_DERIVED 8
      
      set channel_max [expr pow(2,8)-1 ]
      set_interface_property in_packets_stream maxChannel $channel_max
   } else {
      set_parameter_property CHANNEL_WIDTH ENABLED TRUE
      if { $channel_w == 0 } {
         # Setting channel to 1 for CHANNEL_WIDTH==0
         set_port_property in_channel TERMINATION true
         set_parameter_value CHANNEL_WIDTH_DERIVED 1
         
         set_interface_property in_packets_stream maxChannel 0
      } else {
         set_port_property in_channel TERMINATION false
         set_parameter_value CHANNEL_WIDTH_DERIVED $channel_w
         
         set channel_max [expr pow(2,$channel_w)-1 ]
         set_interface_property in_packets_stream maxChannel $channel_max
      }   
   } 
}
# | 
# +-----------------------------------
