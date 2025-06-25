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
# module altera_eth_tse_phyip_terminator
# 
set_module_property NAME altera_eth_tse_phyip_terminator
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
   tx_serial_data    {Input   1}
   rx_serial_data    {Output  1}
   tx_ready          {Input   1}
   rx_ready          {Input   1}
   pll_locked        {Input   1}
   rx_recovered_clk  {Input   1}
   sd_loopback       {Input   1}
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
add_parameter RECONFIG_TO_WIDTH INTEGER 140
set_parameter_property RECONFIG_TO_WIDTH HDL_PARAMETER 1

add_parameter RECONFIG_FROM_WIDTH INTEGER 92
set_parameter_property RECONFIG_FROM_WIDTH HDL_PARAMETER 1

add_parameter ENABLE_TIMESTAMPING BOOLEAN 0
set_parameter_property ENABLE_TIMESTAMPING HDL_PARAMETER 1

add_parameter phyip_en_synce_support BOOLEAN 0

#################################################################################################
# Elaboration callback
#################################################################################################
proc elaborate {} {
   set RECONFIG_TO_WIDTH [get_parameter_value RECONFIG_TO_WIDTH]
   set RECONFIG_FROM_WIDTH [get_parameter_value RECONFIG_FROM_WIDTH]
   set enable_timestamping [get_parameter_value ENABLE_TIMESTAMPING]
   set phyip_en_synce_support [get_parameter_value phyip_en_synce_support]

   set hdl_top_module altera_eth_tse_phyip_terminator
   
   global PCS_SERDES_CONTROL_CP_NAME
   global PMA_SERIAL_CP_NAME
   global phyip_port_list
   global PCS_CDR_REF_CLK_CP_NAME

   set AVALON_CLOCK_CP_NAME clk
   set AVALON_RESET_CP_NAME reset
   set AVALON_MASTER_CP_NAME av_dummy_master

   # Clock
   add_interface $AVALON_CLOCK_CP_NAME clock end
   add_interface_port $AVALON_CLOCK_CP_NAME clk clk Input 1
   set_interface_property $AVALON_CLOCK_CP_NAME ENABLED true

   # cdr_ref_clk
   if {$phyip_en_synce_support} {
      add_interface $PCS_CDR_REF_CLK_CP_NAME clock end
      add_interface_port $PCS_CDR_REF_CLK_CP_NAME cdr_ref_clk_in clk Input 1
      set_interface_property $PCS_CDR_REF_CLK_CP_NAME ENABLED true

      add_interface cdr_ref_clk_out conduit end
      add_interface_port cdr_ref_clk_out cdr_ref_clk_out "export" Output 1
   } else {
      add_interface UNUSED_CDR_REF_CLK conduit end
      add_interface_port UNUSED_CDR_REF_CLK cdr_ref_clk_out "export" Output 1
      add_interface_port UNUSED_CDR_REF_CLK cdr_ref_clk_in  "export" Input 1
      set_interface_property UNUSED_CDR_REF_CLK ENABLED false
   }

   # Reset
   add_interface $AVALON_RESET_CP_NAME reset end
   set_interface_property $AVALON_RESET_CP_NAME associatedClock $AVALON_CLOCK_CP_NAME
   set_interface_property $AVALON_RESET_CP_NAME synchronousEdges DEASSERT
   set_interface_property $AVALON_RESET_CP_NAME ENABLED true
   add_interface_port $AVALON_RESET_CP_NAME reset reset Input 1

   # Avalon MM slave
   add_interface $AVALON_MASTER_CP_NAME avalon master
   set_interface_property $AVALON_MASTER_CP_NAME addressUnits WORDS
   set_interface_property $AVALON_MASTER_CP_NAME associatedClock $AVALON_CLOCK_CP_NAME
   set_interface_property $AVALON_MASTER_CP_NAME associatedReset $AVALON_RESET_CP_NAME
   add_interface_port $AVALON_MASTER_CP_NAME address address Output 9
   add_interface_port $AVALON_MASTER_CP_NAME readdata readdata Input 32
   add_interface_port $AVALON_MASTER_CP_NAME read read Output 1
   add_interface_port $AVALON_MASTER_CP_NAME writedata writedata Output 32
   add_interface_port $AVALON_MASTER_CP_NAME write write Output 1
   add_interface_port $AVALON_MASTER_CP_NAME waitrequest waitrequest Input 1

   # Serial conduit interface
   add_interface $PMA_SERIAL_CP_NAME conduit end
   add_interface_port $PMA_SERIAL_CP_NAME rxp "export" Input 1
   add_interface_port $PMA_SERIAL_CP_NAME txp "export" Output 1

   # Serdes control interface
   add_interface $PCS_SERDES_CONTROL_CP_NAME conduit end
   add_interface_port $PCS_SERDES_CONTROL_CP_NAME rx_recovclkout "export" Output 1
   add_interface_port $PCS_SERDES_CONTROL_CP_NAME reconfig_togxb "export" Input $RECONFIG_TO_WIDTH
   add_interface_port $PCS_SERDES_CONTROL_CP_NAME reconfig_fromgxb "export" Output $RECONFIG_FROM_WIDTH

   # Interfaces to the PHYIP
   foreach {phyip_port} [array names phyip_port_list] {
      set direction [lindex $phyip_port_list($phyip_port) 0]
      set width [lindex $phyip_port_list($phyip_port) 1]

      add_interface $phyip_port conduit end
      add_interface_port $phyip_port $phyip_port "export" $direction $width
   }
   add_interface reconfig_to_xcvr conduit end
   add_interface_port reconfig_to_xcvr reconfig_to_xcvr reconfig_to_xcvr Output $RECONFIG_TO_WIDTH

   add_interface reconfig_from_xcvr conduit end
   add_interface_port reconfig_from_xcvr reconfig_from_xcvr reconfig_from_xcvr Input $RECONFIG_FROM_WIDTH
 
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
   set top_level_file altera_eth_tse_phyip_terminator.v

   add_fileset_file $top_level_file VERILOG PATH $top_level_file  {SYNTHESIS}
   add_fileset_file altera_tse_fake_master.v VERILOG PATH ../../altera_eth_tse/altera_tse_fake_master.v  {SYNTHESIS}

}

proc fileset_sim_cb {entityname} {
   set top_level_file altera_eth_tse_phyip_terminator.v

   # Simulation files
   if {1} {
      add_fileset_file mentor/$top_level_file   VERILOG_ENCRYPT PATH mentor/$top_level_file     {MENTOR_SPECIFIC}
      add_fileset_file mentor/altera_tse_fake_master.v VERILOG_ENCRYPT PATH ../../altera_eth_tse/mentor/altera_tse_fake_master.v  {MENTOR_SPECIFIC}
   }
   if {1} {
      add_fileset_file aldec/$top_level_file    VERILOG_ENCRYPT PATH aldec/$top_level_file      {ALDEC_SPECIFIC}
      add_fileset_file aldec/altera_tse_fake_master.v VERILOG_ENCRYPT PATH ../../altera_eth_tse/aldec/altera_tse_fake_master.v  {ALDEC_SPECIFIC}
   }
   if {0} {
      add_fileset_file synopsys/$top_level_file VERILOG_ENCRYPT PATH synopsys/$top_level_file   {SYNOPSYS_SPECIFIC}
      add_fileset_file synopsys/altera_tse_fake_master.v VERILOG_ENCRYPT PATH ../../altera_eth_tse/synopsys/altera_tse_fake_master.v  {SYNOPSYS_SPECIFIC}
   }
   if {0} {
      add_fileset_file cadence/$top_level_file   VERILOG_ENCRYPT PATH cadence/$top_level_file    {CADENCE_SPECIFIC}
      add_fileset_file cadence/altera_tse_fake_master.v  VERILOG_ENCRYPT PATH ../../altera_eth_tse/cadence/altera_tse_fake_master.v  {CADENCE_SPECIFIC}
   }
}
