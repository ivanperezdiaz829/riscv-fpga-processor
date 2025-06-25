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
# module altera_eth_tse_bridge
# 
set_module_property NAME altera_eth_tse_bridge
set_module_property AUTHOR "Altera Corporation"
set_module_property VERSION "13.1"
set_module_property INTERNAL true
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false
set_module_property ANALYZE_HDL false
set_module_property HIDE_FROM_SOPC true
set_module_property ELABORATION_CALLBACK elaborate



#  -----------------------------------
# | parameters
#  -----------------------------------
add_parameter DATA_WIDTH INTEGER 1
set_parameter_property DATA_WIDTH DISPLAY_NAME "Width of the data"
set_parameter_property DATA_WIDTH ALLOWED_RANGES 1:1024
set_parameter_property DATA_WIDTH DESCRIPTION {Width of the data}

add_parameter INPUT_PORT_PROPERTY STRING_LIST "conduit,data"
set_parameter_property INPUT_PORT_PROPERTY DISPLAY_NAME "Input Port Property: Type, Role"

add_parameter OUTPUT_PORT_PROPERTY STRING_LIST "clock,clk"
set_parameter_property OUTPUT_PORT_PROPERTY DISPLAY_NAME "Output Port Property: Type, Role"

# 
# file sets
# 
#add_fileset altera_eth_tse_bridge.v {SYNTHESIS}
add_fileset synthesis_fileset QUARTUS_SYNTH fileset_cb
set_fileset_property synthesis_fileset TOP_LEVEL altera_eth_tse_bridge

# -----------------------------------
# IEEE encryption
# ----------------------------------- 
add_fileset simulation_verilog SIM_VERILOG sim_ver
add_fileset simulation_vhdl SIM_VHDL sim_ver
set_fileset_property simulation_verilog TOP_LEVEL altera_eth_tse_bridge
set_fileset_property simulation_vhdl TOP_LEVEL altera_eth_tse_bridge

proc sim_ver {name} {

   # Simulation files
   if {1} {
      add_fileset_file mentor/altera_eth_tse_bridge.v   VERILOG_ENCRYPT PATH mentor/altera_eth_tse_bridge.v    {MENTOR_SPECIFIC}
   }
   if {1} {
      add_fileset_file aldec/altera_eth_tse_bridge.v    VERILOG_ENCRYPT PATH aldec/altera_eth_tse_bridge.v      {ALDEC_SPECIFIC}
   }
   if {0} {
      add_fileset_file synopsys/altera_eth_tse_bridge.v VERILOG_ENCRYPT PATH synopsys/altera_eth_tse_bridge.v   {SYNOPSYS_SPECIFIC}
   }
   if {0} {
      add_fileset_file cadence/altera_eth_tse_bridge.v   VERILOG_ENCRYPT PATH cadence/altera_eth_tse_bridge.v   {CADENCE_SPECIFIC}
   }

}

proc fileset_cb {name} {
   add_fileset_file altera_eth_tse_bridge.v VERILOG PATH altera_eth_tse_bridge.v  {SYNTHESIS}
}

#  -----------------------------------
# | Elaboration callback
#  -----------------------------------
proc elaborate {} {

   set DATA_WIDTH [ get_parameter_value DATA_WIDTH ]
   set INPUT_PORT_PROPERTY [ get_parameter_value INPUT_PORT_PROPERTY ]
   set OUTPUT_PORT_PROPERTY [ get_parameter_value OUTPUT_PORT_PROPERTY ]

   foreach line $INPUT_PORT_PROPERTY {
      set port_info [split $line ","]
      set type [lindex $port_info 0]
      set role [lindex $port_info 1]
   }
       
   # +-----------------------------------
   # | connection point in_data
   # | 
   add_interface in_data $type end

   set_interface_property in_data ENABLED true
   add_interface_port in_data in_data $role Input $DATA_WIDTH
   # | 
   # +-----------------------------------

   foreach line $OUTPUT_PORT_PROPERTY {
      set port_info [split $line ","]
      set type [lindex $port_info 0]
      set role [lindex $port_info 1]
   }

   # +-----------------------------------
   # | connection point out_data
   # | 
   add_interface out_data $type start

   set_interface_property out_data ENABLED true
   add_interface_port out_data out_data $role Output $DATA_WIDTH
   # | 
   # +-----------------------------------
}


