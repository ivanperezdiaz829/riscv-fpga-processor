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


package require -exact sopc 9.1

#################################################################################################
# module altera_eth_tse_gxb_inst
#################################################################################################
set_module_property NAME altera_eth_tse_altgxb
set_module_property AUTHOR "Altera Corporation"
set_module_property VERSION "13.1"
set_module_property INTERNAL true
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false 
set_module_property ANALYZE_HDL false
set_module_property ELABORATION_CALLBACK elaborate
set_module_property TOP_LEVEL_HDL_FILE altera_tse_altgxb.v
set_module_property TOP_LEVEL_HDL_MODULE altera_tse_altgxb
set_module_property SIMULATION_MODEL_IN_VERILOG true
set_module_property SIMULATION_MODEL_IN_VHDL true

#################################################################################################
# File sets
#################################################################################################
add_file altera_tse_altgxb.v {SYNTHESIS}
add_file altera_tse_gxb_gige_inst.v {SYNTHESIS}
add_file altera_tse_alt2gxb_gige.v {SYNTHESIS}
add_file altera_tse_alt2gxb_gige_wo_rmfifo.v {SYNTHESIS}
add_file altera_tse_alt4gxb_gige.v {SYNTHESIS}
add_file altera_tse_alt4gxb_gige_wo_rmfifo.v {SYNTHESIS}
add_file altera_tse_altgx_civgx_gige.v {SYNTHESIS}
add_file altera_tse_altgx_civgx_gige_wo_rmfifo.v {SYNTHESIS}

#################################################################################################
# Global variables (constants)
#################################################################################################
source ../../altera_eth_tse/altera_eth_tse_common_constants.tcl

#################################################################################################
# Parameters
#################################################################################################
add_parameter export_pwrdn BOOLEAN 0
set_parameter_property export_pwrdn DISPLAY_NAME "Export transceiver powerdown signal"

add_parameter DEVICE_FAMILY STRING STRATIXIV
set_parameter_property DEVICE_FAMILY HDL_PARAMETER 1

add_parameter STARTING_CHANNEL_NUMBER INTEGER 0
set_parameter_property STARTING_CHANNEL_NUMBER HDL_PARAMETER 1

# Looks like simgen is unhappy with BOOLEAN parameter type, 
# workaround using INTEGER type and limit the range to 0/1
add_parameter ENABLE_ALT_RECONFIG INTEGER 0
set_parameter_property ENABLE_ALT_RECONFIG HDL_PARAMETER 1
set_parameter_property ENABLE_ALT_RECONFIG ALLOWED_RANGES {0 1}

add_parameter ENABLE_SGMII INTEGER 0
set_parameter_property ENABLE_SGMII HDL_PARAMETER 1
set_parameter_property ENABLE_SGMII ALLOWED_RANGES {0 1}

#################################################################################################
# Derived HDL Parameters
#################################################################################################
add_parameter RECONFIG_TOGXB_WIDTH INTEGER 4
set_parameter_property RECONFIG_TOGXB_WIDTH HDL_PARAMETER 1
set_parameter_property RECONFIG_TOGXB_WIDTH DERIVED 1

add_parameter RECONFIG_FROMGXB_WIDTH INTEGER 17
set_parameter_property RECONFIG_FROMGXB_WIDTH HDL_PARAMETER 1
set_parameter_property RECONFIG_FROMGXB_WIDTH DERIVED 1

array set pcs_pma_connection_ports {
   rx_analogreset_sqcnr          {Input   1}
   rx_digitalreset_sqcnr_rx_clk  {Input   1}
   sd_loopback                   {Input   1}
   tx_kchar                      {Input   1}
   tx_frame                      {Input   8}
   tx_digitalreset_sqcnr_tx_clk  {Input   1}
   pll_locked                    {Output  1}
   rx_freqlocked                 {Output  1}
   rx_kchar                      {Output  1}
   rx_pcs_clk                    {Output  1}
   rx_frame                      {Output  8}
   rx_disp_err                   {Output  1}
   rx_char_err_gx                {Output  1}
   rx_patterndetect              {Output  1}
   rx_runlengthviolation         {Output  1}
   rx_syncstatus                 {Output  1}
   tx_pcs_clk                    {Output  1}
   rx_rmfifodatadeleted          {Output  1}
   rx_rmfifodatainserted         {Output  1}
   rx_runningdisp                {Output  1}
   gxb_pwrdn_in_to_pcs           {Output  1}
   reconfig_busy_to_pcs          {Output  1}
   pcs_pwrdn_out_from_pcs        {Input   1}
}

#################################################################################################
# Elaboration callback
#################################################################################################
proc elaborate {} {
   global pcs_pma_connection_ports
   
   set DEVICE_FAMILY [get_parameter_value DEVICE_FAMILY]

   # Build interface to PCS
   foreach {port} [array names pcs_pma_connection_ports] {
      set direction [lindex $pcs_pma_connection_ports($port) 0]
      set width [lindex $pcs_pma_connection_ports($port) 1]

      add_interface $port conduit end
      add_interface_port $port $port "export" $direction $width
   }

   # Update the reconfig_togxb and reconfig_fromgxb port width
   if {[expr {"$DEVICE_FAMILY" == "STRATIXIIGX"} || {"$DEVICE_FAMILY" == "ARRIAGX"}]} {
      # alt2gxb
      set_parameter_value RECONFIG_TOGXB_WIDTH 3
      set_parameter_value RECONFIG_FROMGXB_WIDTH 1
   } elseif { [expr {"$DEVICE_FAMILY" == "STRATIXIV"}] ||
      [expr {"$DEVICE_FAMILY" == "ARRIAIIGX"}] ||
	   [expr {"$DEVICE_FAMILY" == "HARDCOPYIV"}] ||
	   [expr {"$DEVICE_FAMILY" == "ARRIAIIGZ"}] } {
      # alt4gxb
      set_parameter_value RECONFIG_TOGXB_WIDTH 4
      set_parameter_value RECONFIG_FROMGXB_WIDTH 17
   } elseif {[expr {"$DEVICE_FAMILY" == "CYCLONEIVGX"}]} {
      # alt4gxb for STINGRAY family
      set_parameter_value RECONFIG_TOGXB_WIDTH 4
      set_parameter_value RECONFIG_FROMGXB_WIDTH 5
	} else {
      # we should not be here
      set_parameter_value RECONFIG_TOGXB_WIDTH 4
      set_parameter_value RECONFIG_FROMGXB_WIDTH 17
   }

   # Build interfaces
   build_interfaces
}

#################################################################################################
# Interfaces
#################################################################################################
proc build_interfaces {} {
   global PCS_REF_CLK_CP_NAME

   global PMA_SERIAL_CP_NAME
   global PCS_SERDES_CONTROL_CP_NAME
   global PMA_GXB_CAL_BLK_CLK_CP_NAME
   
   # Reference clock
   build_ref_clk_clock_interface $PCS_REF_CLK_CP_NAME

   # SERDES control interface
   build_pcs_serdes_control_interface $PCS_SERDES_CONTROL_CP_NAME

   # Serial interface
   build_pma_serial_interface $PMA_SERIAL_CP_NAME

   # Calibration block clock
   build_gxb_cal_blk_clk $PMA_GXB_CAL_BLK_CLK_CP_NAME
}

proc build_ref_clk_clock_interface {args} {
   set PCS_REF_CLK_CP_NAME [lindex $args 0]

   add_interface $PCS_REF_CLK_CP_NAME clock end
   add_interface_port $PCS_REF_CLK_CP_NAME ref_clk clk Input 1
}

proc build_pma_serial_interface {args} {
   set PMA_SERIAL_CP_NAME [lindex $args 0]

   # Serial interface
   add_interface $PMA_SERIAL_CP_NAME conduit end
   add_interface_port $PMA_SERIAL_CP_NAME txp   export   Output   1
   add_interface_port $PMA_SERIAL_CP_NAME rxp   export   Input    1
   
}

proc build_pcs_serdes_control_interface {args} {
   set PCS_SERDES_CONTROL_CP_NAME [lindex $args 0]
   
   set export_pwrdn [get_parameter_value export_pwrdn]
   set ENABLE_ALT_RECONFIG [get_parameter_value ENABLE_ALT_RECONFIG] 

   set RECONFIG_TOGXB_WIDTH [get_parameter_value RECONFIG_TOGXB_WIDTH]
   set RECONFIG_FROMGXB_WIDTH [get_parameter_value RECONFIG_FROMGXB_WIDTH]

   # Serdes control interface
   add_interface $PCS_SERDES_CONTROL_CP_NAME conduit end
   add_interface_port $PCS_SERDES_CONTROL_CP_NAME rx_recovclkout  export   Output   1

   if {$export_pwrdn} {
      add_interface_port $PCS_SERDES_CONTROL_CP_NAME gxb_pwrdn_in    export   Input    1
      add_interface_port $PCS_SERDES_CONTROL_CP_NAME pcs_pwrdn_out   export   Output   1
   } else {
      set unused_interface "UNUSED_PWRDN_CP"
      add_interface $unused_interface conduit end
      set_interface_property $unused_interface ENABLED 0

      add_interface_port $unused_interface gxb_pwrdn_in    export   Input    1
      add_interface_port $unused_interface pcs_pwrdn_out   export   Output   1

   }

   if {$ENABLE_ALT_RECONFIG} {
      add_interface_port $PCS_SERDES_CONTROL_CP_NAME reconfig_clk    export   Input    1
      add_interface_port $PCS_SERDES_CONTROL_CP_NAME reconfig_togxb  export   Input    $RECONFIG_TOGXB_WIDTH
      add_interface_port $PCS_SERDES_CONTROL_CP_NAME reconfig_fromgxb export  Output   $RECONFIG_FROMGXB_WIDTH
      add_interface_port $PCS_SERDES_CONTROL_CP_NAME reconfig_busy   export   Input    1

      # CASE:112048 Always ensure that the VHDL type for this port is std_logic_vector
      set_port_property reconfig_fromgxb VHDL_TYPE STD_LOGIC_VECTOR
   } else {
      set unused_interface "UNUSED_ALT_RECONFIG_CP"
      add_interface $unused_interface conduit end
      set_interface_property $unused_interface ENABLED 0

      add_interface_port $unused_interface reconfig_clk    export   Input    1
      add_interface_port $unused_interface reconfig_togxb  export   Input    $RECONFIG_TOGXB_WIDTH
      add_interface_port $unused_interface reconfig_fromgxb export  Output   $RECONFIG_FROMGXB_WIDTH
      add_interface_port $unused_interface reconfig_busy   export   Input    1
   }
}

proc build_gxb_cal_blk_clk {args} {
   set PMA_GXB_CAL_BLK_CLK_CP_NAME [lindex $args 0]

   add_interface $PMA_GXB_CAL_BLK_CLK_CP_NAME clock end
   add_interface_port $PMA_GXB_CAL_BLK_CLK_CP_NAME gxb_cal_blk_clk clk Input 1
   set_interface_property $PMA_GXB_CAL_BLK_CLK_CP_NAME ENABLED true
}
