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
# module altera_eth_tse_rx_status_channel_adapter
# 
set_module_property NAME altera_eth_tse_avalon_arbiter
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

add_parameter MAC_ONLY BOOLEAN 1
set_parameter_property MAC_ONLY HDL_PARAMETER 1

add_parameter SLAVE_ADDR_WIDTH INTEGER 8
set_parameter_property SLAVE_ADDR_WIDTH HDL_PARAMETER 1
set_parameter_property SLAVE_ADDR_WIDTH DERIVED 1

#################################################################################################
# Interfaces
#################################################################################################
set AVALON_CLOCK_CP_NAME clk
set AVALON_RESET_CP_NAME reset
set AVALON_CP_NAME av_slave
set AVALON_MAC_MASTER_NAME av_mac_master
set AVALON_PCS_MASTER_NAME av_pcs_master

# Clock
add_interface $AVALON_CLOCK_CP_NAME clock end
add_interface_port $AVALON_CLOCK_CP_NAME clk clk Input 1
set_interface_property $AVALON_CLOCK_CP_NAME ENABLED true

# Reset
add_interface $AVALON_RESET_CP_NAME reset end
set_interface_property $AVALON_RESET_CP_NAME associatedClock $AVALON_CLOCK_CP_NAME
set_interface_property $AVALON_RESET_CP_NAME synchronousEdges DEASSERT
set_interface_property $AVALON_RESET_CP_NAME ENABLED true
add_interface_port $AVALON_RESET_CP_NAME reset reset Input 1

# Avalon MM slave
add_interface $AVALON_CP_NAME avalon end
set_interface_property $AVALON_CP_NAME addressAlignment DYNAMIC
set_interface_property $AVALON_CP_NAME readWaitTime 1
set_interface_property $AVALON_CP_NAME writeWaitTime 1
set_interface_property $AVALON_CP_NAME associatedClock $AVALON_CLOCK_CP_NAME
set_interface_property $AVALON_CP_NAME associatedReset $AVALON_RESET_CP_NAME
add_interface_port $AVALON_CP_NAME address address Input 8
add_interface_port $AVALON_CP_NAME readdata readdata Output 32
add_interface_port $AVALON_CP_NAME read read Input 1
add_interface_port $AVALON_CP_NAME writedata writedata Input 32
add_interface_port $AVALON_CP_NAME write write Input 1
add_interface_port $AVALON_CP_NAME waitrequest waitrequest Output 1

# Avalon-MM for MAC and PCS
for {set index 0} { $index < 24} {incr index} {
   set interface_name $AVALON_MAC_MASTER_NAME\_$index

   add_interface $interface_name avalon master
   set_interface_property $interface_name associatedClock $AVALON_CLOCK_CP_NAME
   set_interface_property $interface_name associatedReset $AVALON_RESET_CP_NAME
   set_interface_property $interface_name addressUnits WORDS

   add_interface_port $interface_name mac_address_$index       address     Output   8
   add_interface_port $interface_name mac_readdata_$index      readdata    Input    32
   add_interface_port $interface_name mac_read_$index          read        Output   1
   add_interface_port $interface_name mac_writedata_$index     writedata   Output   32
   add_interface_port $interface_name mac_write_$index         write       Output   1
   add_interface_port $interface_name mac_waitrequest_$index   waitrequest Input    1
      
   set pcs_interface_name $AVALON_PCS_MASTER_NAME\_$index

   add_interface $pcs_interface_name avalon master
   set_interface_property $pcs_interface_name associatedClock $AVALON_CLOCK_CP_NAME
   set_interface_property $pcs_interface_name associatedReset $AVALON_RESET_CP_NAME
   set_interface_property $pcs_interface_name addressUnits WORDS
   add_interface_port $pcs_interface_name pcs_address_$index       address     Output   5
   add_interface_port $pcs_interface_name pcs_readdata_$index      readdata    Input    16
   add_interface_port $pcs_interface_name pcs_read_$index          read        Output   1
   add_interface_port $pcs_interface_name pcs_writedata_$index     writedata   Output   16
   add_interface_port $pcs_interface_name pcs_write_$index         write       Output   1
   add_interface_port $pcs_interface_name pcs_waitrequest_$index   waitrequest Input    1
}

#################################################################################################
# Elaboration callback
#################################################################################################
proc elaborate {} {
   set MAX_CHANNELS [get_parameter_value MAX_CHANNELS]
   set MAC_ONLY [get_parameter_value MAC_ONLY]

   set hdl_top_module altera_eth_tse_avalon_arbiter
   
   set extra_addr_bits [log2_in_int ($MAX_CHANNELS)]

   set_parameter_value SLAVE_ADDR_WIDTH [expr $extra_addr_bits + 8]
   
   global AVALON_CLOCK_CP_NAME clk
   global AVALON_RESET_CP_NAME reset
   global AVALON_CP_NAME av_slave
   global AVALON_MAC_MASTER_NAME av_mac_master
   global AVALON_PCS_MASTER_NAME av_pcs_master

   # Update the avalon slave address port width based on setting
   add_interface_port $AVALON_CP_NAME address address Input [expr $extra_addr_bits + 8]

   # Enable the Avalon MM masters that we need
   for {set index 0} { $index < 24} {incr index} {
      set mac_master $AVALON_MAC_MASTER_NAME\_$index
      set pcs_master $AVALON_PCS_MASTER_NAME\_$index

      if {$index < $MAX_CHANNELS} {
         set_interface_property $mac_master ENABLED 1
         
         if {$MAC_ONLY} {
            set_interface_property $pcs_master ENABLED 0
         } else {
            set_interface_property $pcs_master ENABLED 1
         }

      } else {
         set_interface_property $mac_master ENABLED 0
         set_interface_property $pcs_master ENABLED 0
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
   set top_level_file altera_eth_tse_avalon_arbiter.v

   add_fileset_file $top_level_file VERILOG PATH $top_level_file  {SYNTHESIS}
}

proc fileset_sim_cb {entityname} {
   set top_level_file altera_eth_tse_avalon_arbiter.v

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
#################################################################################################
# Helper function
#################################################################################################
# Calculates log2 for a given value in integer (round up)
proc log2_in_int {arg} {
   return [expr int ([expr ceil ([expr [expr log ($arg)] / [expr log (2)]])])]
}
