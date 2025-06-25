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
# module altera_eth_tse_nf_phyip_terminator
# 
set_module_property NAME altera_eth_tse_nf_phyip_terminator
set_module_property AUTHOR "Altera Corporation"
set_module_property VERSION "13.1"
set_module_property INTERNAL true
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false
set_module_property ANALYZE_HDL false
set_module_property HIDE_FROM_SOPC true
set_module_property ELABORATION_CALLBACK elaborate

# Source the common parameters for TSE
source ../../altera_eth_tse/altera_eth_tse_common_constants.tcl

#################################################################################################
# Global parameter
#################################################################################################
array set phyip_port_list {
   tx_serial_data          {tx_serial_data            Input    1}
   rx_serial_data          {rx_serial_data            Output   1}
   sd_loopback             {sd_loopback               Input    1}
   rx_seriallpbken         {rx_seriallpbken           Output   1}
   rx_rmfifodatainserted   {rx_rmfifodatainserted     Output   1}
   rx_rmfifodatadeleted    {rx_rmfifodatadeleted      Output   1}
   rx_rmfifostatus         {rx_rmfifostatus           Input    2}
   unused_tx_parallel_data {unused_tx_parallel_data   Output   119}
   rx_runlengthviolation   {rx_runlengthviolation     Output   1}
   tx_pcs_clk              {tx_pcs_clk                Output   1}
   rx_pcs_clk              {rx_pcs_clk                Output   1}
}

#################################################################################################
# Add synthesis and simulation fileset callback
#################################################################################################
add_fileset synthesis_fileset QUARTUS_SYNTH fileset_cb
add_fileset sim_ver_fileset SIM_VERILOG fileset_sim_cb
add_fileset sim_vhd_fileset SIM_VHDL fileset_sim_cb

#################################################################################################
# Parameters
#################################################################################################
add_parameter ENABLE_SGMII BOOLEAN 0

add_parameter ENABLE_TIMESTAMPING BOOLEAN 0
set_parameter_property ENABLE_TIMESTAMPING HDL_PARAMETER 1

# Port width for unused_rx_parallel_data
add_parameter UNUSED_RX_PARALLEL_DATA_WIDTH INTEGER 112
set_parameter_property UNUSED_RX_PARALLEL_DATA_WIDTH HDL_PARAMETER 1
set_parameter_property UNUSED_RX_PARALLEL_DATA_WIDTH DERIVED 1
set_parameter_property UNUSED_RX_PARALLEL_DATA_WIDTH VISIBLE 0

#################################################################################################
# Elaboration callback
#################################################################################################
proc elaborate {} {
   set enable_timestamping [get_parameter_value ENABLE_TIMESTAMPING]
   set enable_sgmii [get_parameter_value ENABLE_SGMII]
   set hdl_top_module altera_eth_tse_nf_phyip_terminator
   
   global PCS_SERDES_CONTROL_CP_NAME
   global PMA_SERIAL_CP_NAME
   global phyip_port_list
   global PCS_CDR_REF_CLK_CP_NAME

   # Clock connections
   add_interface tx_clk clock end
   add_interface_port tx_clk tx_clk clk Input 1

   add_interface rx_clk clock end
   add_interface_port rx_clk rx_clk clk Input 1

   add_interface tx_coreclk clock source
   add_interface_port tx_coreclk tx_coreclk clk Output 1

   add_interface rx_coreclk clock source
   add_interface_port rx_coreclk rx_coreclk clk Output 1

   # Recovered clock input
   add_interface rx_recovered_clk clock end
   add_interface_port rx_recovered_clk rx_recovered_clk clk Input 1
   set_interface_property rx_recovered_clk ENABLED true

   # Serial conduit interface
   add_interface $PMA_SERIAL_CP_NAME conduit end
   add_interface_port $PMA_SERIAL_CP_NAME rxp "export" Input 1
   add_interface_port $PMA_SERIAL_CP_NAME txp "export" Output 1

   # Serdes control interface
   add_interface $PCS_SERDES_CONTROL_CP_NAME conduit end
   add_interface_port $PCS_SERDES_CONTROL_CP_NAME rx_recovclkout "export" Output 1

   # Interfaces to the PHYIP
   foreach {phyip_port} [array names phyip_port_list] {
      set role [lindex $phyip_port_list($phyip_port) 0]
      set direction [lindex $phyip_port_list($phyip_port) 1]
      set width [lindex $phyip_port_list($phyip_port) 2]

      add_interface $phyip_port conduit end
      add_interface_port $phyip_port $phyip_port $role $direction $width
   }

   if {$enable_sgmii} {
      set_interface_property rx_rmfifodatainserted ENABLED 0
      set_interface_property rx_rmfifodatadeleted  ENABLED 0
      set_interface_property rx_rmfifostatus       ENABLED 0

      add_interface unused_rx_parallel_data conduit end
      add_interface_port unused_rx_parallel_data unused_rx_parallel_data unused_rx_parallel_data Input 114
      set_parameter_value UNUSED_RX_PARALLEL_DATA_WIDTH 114
   } else {
      set_interface_property rx_rmfifodatainserted ENABLED 1
      set_interface_property rx_rmfifodatadeleted  ENABLED 1
      set_interface_property rx_rmfifostatus       ENABLED 1

      add_interface unused_rx_parallel_data conduit end
      add_interface_port unused_rx_parallel_data unused_rx_parallel_data unused_rx_parallel_data Input 112
      set_parameter_value UNUSED_RX_PARALLEL_DATA_WIDTH 112
   }
 
   if {$enable_timestamping} {
      add_interface terminate_rx_recovered_clk conduit end
      add_interface_port terminate_rx_recovered_clk terminate_rx_recovered_clk export Input 1
   } else {
      add_interface terminate_rx_recovered_clk_unused conduit end
      add_interface_port terminate_rx_recovered_clk_unused terminate_rx_recovered_clk export Input 1
      set_interface_property terminate_rx_recovered_clk_unused ENABLED 0
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
   set top_level_file altera_eth_tse_nf_phyip_terminator.v

   add_fileset_file $top_level_file VERILOG PATH $top_level_file  {SYNTHESIS}
}

proc fileset_sim_cb {entityname} {
   set top_level_file altera_eth_tse_nf_phyip_terminator.v

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
