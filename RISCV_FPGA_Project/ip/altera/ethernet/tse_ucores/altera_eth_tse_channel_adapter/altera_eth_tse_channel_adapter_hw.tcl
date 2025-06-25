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

# 
# module altera_eth_tse_channel_adapter
# 
set_module_property NAME altera_eth_tse_channel_adapter
set_module_property AUTHOR "Altera Corporation"
set_module_property VERSION "13.1"
set_module_property INTERNAL true
set_module_property GROUP "Interface Protocols/Ethernet"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false
set_module_property ANALYZE_HDL false
set_module_property HIDE_FROM_SOPC true
set_module_property ELABORATION_CALLBACK elaborate

#################################################################################################
# Add synthesis and simulation fileset callback
#################################################################################################
add_fileset synthesis_fileset QUARTUS_SYNTH fileset_cb
add_fileset sim_ver_fileset SIM_VERILOG fileset_sim_cb
add_fileset sim_vhd_fileset SIM_VHDL fileset_sim_cb

#################################################################################################
# Parameters
#################################################################################################
add_parameter MAX_CHANNELS INTEGER 1
set_parameter_property MAX_CHANNELS HDL_PARAMETER 1
set_parameter_property MAX_CHANNELS ALLOWED_RANGES { 1 4 8 12 16 20 24 }

add_parameter CHANNEL_WIDTH INTEGER 1
set_parameter_property CHANNEL_WIDTH HDL_PARAMETER 1

#################################################################################################
# Interfaces
#################################################################################################
# Clock and reset connections
add_interface clk clock end
add_interface_port clk   clk clk Input 1

add_interface reset reset end
set_interface_property reset associatedClock clk
set_interface_property reset synchronousEdges DEASSERT
add_interface_port reset reset reset Input 1

# Sink interface with multiple channel
add_interface channel_in avalon_streaming sink
set_interface_property channel_in associatedClock clk
set_interface_property channel_in associatedReset reset
set_interface_property channel_in dataBitsPerSymbol   2
set_interface_property channel_in symbolsPerBeat      1

add_interface_port channel_in   rx_afull_data       data     Input 2
add_interface_port channel_in   rx_afull_valid      valid    Input 1
add_interface_port channel_in   rx_afull_channel    channel  Input 1

for {set index 0} { $index < 24} {incr index} {
   set interface_name channel_out_$index

   # Single channel source interface
   add_interface $interface_name avalon_streaming source
   set_interface_property $interface_name associatedClock clk
   set_interface_property $interface_name associatedReset reset
   set_interface_property $interface_name dataBitsPerSymbol   2
   set_interface_property $interface_name symbolsPerBeat      1

   add_interface_port $interface_name   rx_afull_data_out_$index       data     Output 2
   add_interface_port $interface_name   rx_afull_valid_out_$index      valid    Output 1

}


#################################################################################################
# Elaboration callback
#################################################################################################
proc elaborate {} {
   set MAX_CHANNELS [get_parameter_value MAX_CHANNELS]
   set CHANNEL_WIDTH [get_parameter_value CHANNEL_WIDTH]

   set hdl_top_module altera_eth_tse_channel_adapter

   # This port type must be set to STD_LOGIC_VECTOR as the port width is varying
   # across different setting
   set_port_property rx_afull_channel VHDL_TYPE STD_LOGIC_VECTOR
   
   # Update channel_in channel port width
   set_port_property rx_afull_channel WIDTH_EXPR $CHANNEL_WIDTH

   # Enable the source interface that we need
   for {set index 0} { $index < 24} {incr index} {
      set interface_name channel_out_$index

      if {$index < $MAX_CHANNELS} {
         set_interface_property $interface_name ENABLED 1
      } else {
         set_interface_property $interface_name ENABLED 0
      }
   }

   # Set the fileset top level
   set_fileset_property synthesis_fileset TOP_LEVEL $hdl_top_module
   set_fileset_property sim_ver_fileset TOP_LEVEL $hdl_top_module
   set_fileset_property sim_vhd_fileset TOP_LEVEL $hdl_top_module
}

#################################################################################################
# Synthesis and simulation fileset callback
#################################################################################################
proc fileset_cb {entityname} {
   set top_level_file altera_eth_tse_channel_adapter.v

   add_fileset_file $top_level_file VERILOG PATH $top_level_file  {SYNTHESIS}
}

proc fileset_sim_cb {entityname} {
   set top_level_file altera_eth_tse_channel_adapter.v

   # Simulation files
   if {1} {
      add_fileset_file mentor/$top_level_file   VERILOG_ENCRYPT PATH mentor/$top_level_file     {MENTOR_SPECIFIC}
   }
   if {1} {
      add_fileset_file aldec/$top_level_file    VERILOG_ENCRYPT PATH aldec/$top_level_file      {ALDEC_SPECIFIC}
   }
   if {0} {
      add_fileset_file synopsys/$top_level_file VERILOG_ENCRYPT PATH synopsys/$top_level_file   {SYNOPSYS_SPECIFIC}
   }
   if {0} {
      add_fileset_file cadence/$top_level_file   VERILOG_ENCRYPT PATH cadence/$top_level_file    {CADENCE_SPECIFIC}
   }

}

