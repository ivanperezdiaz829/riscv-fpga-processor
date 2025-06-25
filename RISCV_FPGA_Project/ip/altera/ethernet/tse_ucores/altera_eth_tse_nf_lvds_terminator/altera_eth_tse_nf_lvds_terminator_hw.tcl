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
# module altera_eth_tse_nf_lvds_terminator
# 
set_module_property NAME altera_eth_tse_nf_lvds_terminator
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
array set lvds_port_list {
   tbi_tx_d_muxed                   {tbi_tx_d_muxed         Input    10}
   tx_in                            {export                 Output   10}
   tbi_rx_d_lvds                    {tbi_rx_d_lvds          Output   10}
   rx_out                           {export                 Input    10}
   rx_in                            {export                 Output   1}
   tx_out                           {export                 Input    1}
   pll_locked                       {export                 Input    1}
   rx_cda_reset                     {rx_cda_reset           Input    1}
   rx_channel_data_align            {rx_channel_data_align  Input    1}
   rx_dpa_reset                     {export                 Output   1}
   rx_divfwdclk                     {export                 Input    1}
   tbi_rx_clk                       {tbi_rx_clk             Output   1}
   rx_locked                        {rx_locked              Output   1}
   rx_reset_ref_clk                 {rx_reset_ref_clk       Input    1}
   rx_channel_data_align_lvds       {export                 Output   1}
   rx_cda_reset_lvds                {export                 Output   1}
   reset_terminator_lvds_tx         {export                 Output   1}
   reset_terminator_lvds_rx         {export                 Output   1}
   reset_pcs_terminator             {reset_lvds             Input    1}
   lvds_tx_inclock                  {export                 Output   1}
   lvds_rx_inclock                  {export                 Output   1}
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


#################################################################################################
# Elaboration callback
#################################################################################################
proc elaborate {} {
   set hdl_top_module altera_eth_tse_nf_lvds_terminator
   
   global PMA_SERIAL_CP_NAME
   global lvds_port_list

   # Serial conduit interface
   add_interface $PMA_SERIAL_CP_NAME conduit end
   add_interface_port $PMA_SERIAL_CP_NAME rxp "export" Input 1
   add_interface_port $PMA_SERIAL_CP_NAME txp "export" Output 1

   # LVDS clockin
   add_interface lvds_inclock clock end
   add_interface_port lvds_inclock lvds_inclock clk Input 1

   # Interfaces to the lvds and pcs
   foreach {lvds_port} [array names lvds_port_list] {
      set role [lindex $lvds_port_list($lvds_port) 0]
      set direction [lindex $lvds_port_list($lvds_port) 1]
      set width [lindex $lvds_port_list($lvds_port) 2]

      add_interface $lvds_port conduit end
      add_interface_port $lvds_port $lvds_port $role $direction $width
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
   set top_level_file altera_eth_tse_nf_lvds_terminator.v

   add_fileset_file $top_level_file VERILOG PATH $top_level_file  {SYNTHESIS}
}

proc fileset_sim_cb {entityname} {
   set top_level_file altera_eth_tse_nf_lvds_terminator.v

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
