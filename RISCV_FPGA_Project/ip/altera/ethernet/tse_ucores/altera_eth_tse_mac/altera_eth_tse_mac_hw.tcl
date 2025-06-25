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


# +-----------------------------------
# | request TCL package from ACDS 12.1
# |
package require -exact qsys 12.1
# |
# +-----------------------------------

# +-----------------------------------
# | module altera_eth_tse_mac
# |
set_module_property NAME altera_eth_tse_mac
set_module_property AUTHOR "Altera Corporation"
set_module_property VERSION "13.1"
set_module_property INTERNAL true
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false
set_module_property ELABORATION_CALLBACK elaborate
set_module_property ANALYZE_HDL false
set_module_property HIDE_FROM_SOPC true

# Add synthesis and simulation fileset callback
add_fileset synthesis_fileset QUARTUS_SYNTH fileset_cb
add_fileset sim_ver_fileset SIM_VERILOG fileset_sim_cb
add_fileset sim_vhd_fileset SIM_VHDL fileset_sim_cb

#################################################################################################
# Global variables (constants)
#################################################################################################
source ../../altera_eth_tse/altera_eth_tse_common_constants.tcl

#################################################################################################
# HDL Parameters
#################################################################################################
array set mac_hdl_parameters {
   "ENABLE_MAGIC_DETECT"      {BOOLEAN 0}
   "ENABLE_MDIO"              {BOOLEAN 0}
   "ENABLE_SHIFT16"           {BOOLEAN 0}
   "ENABLE_SUP_ADDR"          {BOOLEAN 0}
   "CORE_VERSION"             {INTEGER 0}
   "CRC32GENDELAY"            {INTEGER 0}
   "MDIO_CLK_DIV"             {INTEGER 0}
   "ENA_HASH"                 {BOOLEAN 0}
   "USE_SYNC_RESET"           {BOOLEAN 0}
   "STAT_CNT_ENA"             {BOOLEAN 0}
   "ENABLE_EXTENDED_STAT_REG" {BOOLEAN 0}
   "ENABLE_HD_LOGIC"          {BOOLEAN 0}
   "REDUCED_INTERFACE_ENA"    {BOOLEAN 0}
   "CRC32S1L2_EXTERN"         {BOOLEAN 0}
   "ENABLE_GMII_LOOPBACK"     {BOOLEAN 0}
   "CRC32DWIDTH"              {INTEGER 0}
   "CUST_VERSION"             {INTEGER 0}
   "RESET_LEVEL"              {INTEGER 0}
   "CRC32CHECK16BIT"          {INTEGER 0}
   "ENABLE_MAC_FLOW_CTRL"     {BOOLEAN 0}
   "ENABLE_MAC_TXADDR_SET"    {BOOLEAN 0}
   "ENABLE_MAC_RX_VLAN"       {BOOLEAN 0}
   "ENABLE_MAC_TX_VLAN"       {BOOLEAN 0}
   "SYNCHRONIZER_DEPTH"       {INTEGER 3}
   "EG_FIFO"                  {INTEGER 0}
   "EG_ADDR"                  {INTEGER 0}
   "ING_FIFO"                 {INTEGER 0}
   "ENABLE_ENA"               {INTEGER 32}
   "ING_ADDR"                 {INTEGER 0}
   "RAM_TYPE"                 {STRING "AUTO"}
   "INSERT_TA"                {BOOLEAN 1}
   "ENABLE_PADDING"           {BOOLEAN 1}
   "ENABLE_LGTH_CHECK"        {BOOLEAN 1}
   "GBIT_ONLY"                {BOOLEAN 1}
   "MBIT_ONLY"                {BOOLEAN 1}
   "REDUCED_CONTROL"          {BOOLEAN 1}
   "DEVICE_FAMILY"            {STRING "ARRIAGX"}
}

foreach {param_name} [array names mac_hdl_parameters] {
   set param_type [lindex $mac_hdl_parameters($param_name) 0]
   set param_default_val [lindex $mac_hdl_parameters($param_name) 1]

   add_parameter $param_name $param_type $param_default_val
   set_parameter_property $param_name HDL_PARAMETER 1
}

#################################################################################################
# Core parameters
#################################################################################################
add_parameter ifGMII STRING MII_GMII
set_parameter_property ifGMII DISPLAY_NAME "Interface"
set_parameter_property ifGMII ALLOWED_RANGES {
   "MII_GMII:MII/GMII"
   "RGMII:RGMII"
   "MII:MII"
   "GMII:GMII"
}

add_parameter use_misc_ports BOOLEAN 0
set_parameter_property use_misc_ports DISPLAY_NAME "Enable misc ports"

add_parameter connect_to_pcs BOOLEAN 0
set_parameter_property connect_to_pcs DISPLAY_NAME "Connect this mac instance to pcs"

#################################################################################################
# Synthesis and simulation fileset callback
#################################################################################################
proc fileset_cb {entityname} {
   global mac_rtl_files
   global common_rtl_files
   global mac_ocp_files

   set top_level_file altera_eth_tse_mac.v

   add_fileset_file $top_level_file VERILOG PATH $top_level_file {SYNTHESIS}

   foreach {file_name filetype} $mac_rtl_files {
      add_fileset_file $file_name $filetype PATH ../../altera_eth_tse/$file_name {SYNTHESIS}
   }
   
   foreach {file_name filetype} $common_rtl_files {
      add_fileset_file $file_name $filetype PATH ../../altera_eth_tse/$file_name {SYNTHESIS}
   }

   foreach {file_name filetype} $mac_ocp_files {
      add_fileset_file $file_name $filetype PATH ../../altera_eth_tse/$file_name {SYNTHESIS}
   }

   sdc_file_gen
}

proc sdc_file_gen {} {
   set sdc_template "altera_eth_tse_mac.sdc"
   set sdc_out_file [create_temp_file altera_eth_tse_mac.sdc]
   set out [ open $sdc_out_file w ]
   set in [open $sdc_template r]

   # SDC file parameters
   # Mapping between SDC file parameter with core parameter
   set mac_sdc_parameters {
      IS_SMALLMAC             REDUCED_CONTROL
      ENABLE_SUP_ADDR         ENABLE_SUP_ADDR
      ENABLE_MAC_FLOW_CTRL    ENABLE_MAC_FLOW_CTRL
      ENABLE_MAGIC_DETECT     ENABLE_MAGIC_DETECT
      ENABLE_HD_LOGIC         ENABLE_HD_LOGIC
      ENABLE_ENA              ENABLE_ENA
   }

   while {[gets $in line] != -1} {
      if [string match "*CORE_PARAMETERS*" $line] {
         puts $out $line

         foreach {sdc_param module_param} $mac_sdc_parameters {
            set param_value [get_parameter_value $module_param]
      
            if { [string match -nocase "BOOLEAN" [get_parameter_property $module_param TYPE]] } {
               # Convert boolean parameter to 0/1 value
               if {[get_parameter_value $module_param]} {
                  puts $out "set $sdc_param 1"
               } else {
                  puts $out "set $sdc_param 0"
               }
            } else {
               puts $out "set $sdc_param $param_value"
            }
         }

      } else {
         puts $out $line
      }
   }
   close $in
   close $out
   add_fileset_file altera_eth_tse_mac.sdc SDC PATH $sdc_out_file {SYNTHESIS}
}

proc fileset_sim_cb {entityname} {
   global mac_rtl_files
   global common_rtl_files

   set top_level_file altera_eth_tse_mac.v

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

   # MAC files
   foreach {file_name filetype} $mac_rtl_files {
      if {1} {
         add_fileset_file mentor/$file_name $filetype\_ENCRYPT PATH ../../altera_eth_tse/mentor/$file_name  {MENTOR_SPECIFIC}
      }
      if {1} {
         add_fileset_file aldec/$file_name $filetype\_ENCRYPT PATH ../../altera_eth_tse/aldec/$file_name  {ALDEC_SPECIFIC}
      }
      if {0} {
         add_fileset_file synopsys/$file_name $filetype\_ENCRYPT PATH ../../altera_eth_tse/synopsys/$file_name  {SYNOPSYS_SPECIFIC}
      }
      if {0} {
         add_fileset_file cadence/$file_name $filetype\_ENCRYPT PATH ../../altera_eth_tse/cadence/$file_name  {CADENCE_SPECIFIC}
      }
   }

   # Common files
   foreach {file_name filetype} $common_rtl_files {
      if {1} {
         add_fileset_file mentor/$file_name $filetype\_ENCRYPT PATH ../../altera_eth_tse/mentor/$file_name  {MENTOR_SPECIFIC}
      }
      if {1} {
         add_fileset_file aldec/$file_name $filetype\_ENCRYPT PATH ../../altera_eth_tse/aldec/$file_name  {ALDEC_SPECIFIC}
      }
      if {0} {
         add_fileset_file synopsys/$file_name $filetype\_ENCRYPT PATH ../../altera_eth_tse/synopsys/$file_name  {SYNOPSYS_SPECIFIC}
      }
      if {0} {
         add_fileset_file cadence/$file_name $filetype\_ENCRYPT PATH ../../altera_eth_tse/cadence/$file_name  {CADENCE_SPECIFIC}
      }
   }
}

#################################################################################################
# Elaboration callback
#################################################################################################
proc elaborate {} {
   
   # Set the fileset top level module
   set_fileset_property synthesis_fileset TOP_LEVEL "altera_eth_tse_mac"
   set_fileset_property sim_ver_fileset TOP_LEVEL "altera_eth_tse_mac"
   set_fileset_property sim_vhd_fileset TOP_LEVEL "altera_eth_tse_mac"

   # Build interfaces connection point for this module
   build_interfaces
}

#################################################################################################
# Interfaces
#################################################################################################
proc build_interfaces {} {
   set use_misc_ports [get_parameter_value use_misc_ports]
   set connect_to_pcs [get_parameter_value connect_to_pcs]
   set ifGMII [get_parameter_value ifGMII]
   set DEVICE_FAMILY [get_parameter_value DEVICE_FAMILY]

   # Connection point names
   global AVALON_CP_NAME
   global AVALON_CLOCK_CP_NAME
   global AVALON_RESET_CP_NAME

   global ATLANTIC_SOURCE_CLOCK_CP_NAME
   global ATLANTIC_SINK_CLOCK_CP_NAME

   global ATLANTIC_SOURCE_CP_NAME
   global ATLANTIC_SINK_CP_NAME

   global ATLANTIC_SOURCE_PACKET_CLASS_CP_NAME

   global MAC_GMII_CP_NAME
   global MAC_MII_CP_NAME
   global MAC_RGMII_CP_NAME
   global MAC_STATUS_CP_NAME
   global MAC_MDIO_CP_NAME

   global WIRE_MISC_CP_NAME
   global WIRE_CLKENA_CP_NAME

   global MAC_TX_CLOCK_NAME
   global MAC_RX_CLOCK_NAME

   global MAC_RX_FIFO_STATUS_CLOCK_NAME
   global MAC_RX_FIFO_STATUS_NAME

   global PCS_MAC_TX_CLOCK_NAME
   global PCS_MAC_RX_CLOCK_NAME

   global MAC_PCS_CP_NAME

   set ENABLE_MDIO [get_parameter_value ENABLE_MDIO]

   build_avalon_clock_interface $AVALON_CLOCK_CP_NAME
   build_avalon_reset_interface $AVALON_CLOCK_CP_NAME $AVALON_RESET_CP_NAME
   build_avalon_slave_interface $AVALON_CLOCK_CP_NAME $AVALON_RESET_CP_NAME $AVALON_CP_NAME

   # MAC with FIFO
   build_atlantic_sink_clock_interface $ATLANTIC_SINK_CLOCK_CP_NAME
   build_atlantic_source_clock_interface $ATLANTIC_SOURCE_CLOCK_CP_NAME
   build_atlantic_source_interface $ATLANTIC_SOURCE_CLOCK_CP_NAME $AVALON_RESET_CP_NAME $ATLANTIC_SOURCE_CP_NAME
   build_atlantic_sink_interface $ATLANTIC_SINK_CLOCK_CP_NAME $AVALON_RESET_CP_NAME $ATLANTIC_SINK_CP_NAME
   build_misc_conduit_interface $WIRE_MISC_CP_NAME

   # Protocol specific interfaces
   build_mdio_interface $MAC_MDIO_CP_NAME
   build_gmii_interface $MAC_GMII_CP_NAME
   build_rgmii_altgpio_interface
   build_rgmii_interface $MAC_RGMII_CP_NAME
   build_mii_interface $MAC_MII_CP_NAME
   build_status_interface $MAC_STATUS_CP_NAME
   build_clkena_conduit_interface $WIRE_CLKENA_CP_NAME
   
   # Build tx_clk and rx_clk connection point
   build_pcs_tx_rx_clock_interface $PCS_MAC_TX_CLOCK_NAME $PCS_MAC_RX_CLOCK_NAME
   
   # Enable/disable the misc ports based on user preferences
   if {$use_misc_ports} {
      set_interface_property $WIRE_MISC_CP_NAME ENABLED $use_misc_ports
   } else {
      set_interface_property $WIRE_MISC_CP_NAME ENABLED $use_misc_ports

      # Special termination value
      set_port_property "magic_sleep_n"   TERMINATION_VALUE 1
      set_port_property "magic_sleep_n"   TERMINATION 1
   }

   # Enable/disable the MDIO ports based on user preferences
   set_interface_property $MAC_MDIO_CP_NAME ENABLED $ENABLE_MDIO

   if {$connect_to_pcs} {
      
      set_interface_property $MAC_RGMII_CP_NAME ENABLED 0
      set_interface_property $WIRE_CLKENA_CP_NAME ENABLED 1

      enable_rgmii_altgpio_interface 0

   } else {
      set_interface_property $WIRE_CLKENA_CP_NAME ENABLED 0

      # Special termination value
      set_port_property "rx_clkena"   TERMINATION_VALUE 1
      set_port_property "rx_clkena"   TERMINATION 1

      set_port_property "tx_clkena"   TERMINATION_VALUE 1
      set_port_property "tx_clkena"   TERMINATION 1

      switch $ifGMII {
         RGMII {
            set_interface_property $MAC_RGMII_CP_NAME ENABLED 1
            set_interface_property $MAC_GMII_CP_NAME ENABLED 0
            set_interface_property $MAC_MII_CP_NAME ENABLED 0

            if {[expr {"$DEVICE_FAMILY" == "ARRIA10"}]} {
               enable_rgmii_altgpio_interface 1
            } else {
               enable_rgmii_altgpio_interface 0
            }
         }
         GMII {
            set_interface_property $MAC_RGMII_CP_NAME ENABLED 0
            set_interface_property $MAC_GMII_CP_NAME ENABLED 1
            set_interface_property $MAC_MII_CP_NAME ENABLED 0
            enable_rgmii_altgpio_interface 0
         }
         MII {
            set_interface_property $MAC_RGMII_CP_NAME ENABLED 0
            set_interface_property $MAC_GMII_CP_NAME ENABLED 0
            set_interface_property $MAC_MII_CP_NAME ENABLED 1
            enable_rgmii_altgpio_interface 0
         }
         MII_GMII {
            set_interface_property $MAC_RGMII_CP_NAME ENABLED 0
            set_interface_property $MAC_GMII_CP_NAME ENABLED 1
            set_interface_property $MAC_MII_CP_NAME ENABLED 1
            enable_rgmii_altgpio_interface 0
         }
      }
   }
}

proc build_avalon_clock_interface {args} {
   set AVALON_CLOCK_CP_NAME [lindex $args 0]

   add_interface $AVALON_CLOCK_CP_NAME clock end
   add_interface_port $AVALON_CLOCK_CP_NAME clk clk Input 1
   set_interface_property $AVALON_CLOCK_CP_NAME ENABLED true
}

proc build_avalon_reset_interface {args} {
   set AVALON_CLOCK_CP_NAME [lindex $args 0]
   set AVALON_RESET_CP_NAME [lindex $args 1]

   add_interface $AVALON_RESET_CP_NAME reset end
   set_interface_property $AVALON_RESET_CP_NAME associatedClock $AVALON_CLOCK_CP_NAME
   set_interface_property $AVALON_RESET_CP_NAME synchronousEdges DEASSERT
   set_interface_property $AVALON_RESET_CP_NAME ENABLED true
   add_interface_port $AVALON_RESET_CP_NAME reset reset Input 1
}

proc build_avalon_slave_interface {args} {
   set AVALON_CLOCK_CP_NAME [lindex $args 0]
   set AVALON_RESET_CP_NAME [lindex $args 1]
   set AVALON_CP_NAME [lindex $args 2]

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
}

proc build_atlantic_source_clock_interface {args} {
   set ATLANTIC_SOURCE_CLOCK_CP_NAME [lindex $args 0]

   add_interface $ATLANTIC_SOURCE_CLOCK_CP_NAME clock end
   add_interface_port $ATLANTIC_SOURCE_CLOCK_CP_NAME ff_rx_clk clk Input 1
   set_interface_property $ATLANTIC_SOURCE_CLOCK_CP_NAME ENABLED true
}

proc build_atlantic_sink_clock_interface {args} {
   set ATLANTIC_SINK_CLOCK_CP_NAME [lindex $args 0]

   add_interface $ATLANTIC_SINK_CLOCK_CP_NAME clock end
   add_interface_port $ATLANTIC_SINK_CLOCK_CP_NAME ff_tx_clk clk Input 1
   set_interface_property $ATLANTIC_SINK_CLOCK_CP_NAME ENABLED true
}

proc build_atlantic_source_interface {args} {
   set ATLANTIC_SOURCE_CLOCK_CP_NAME [lindex $args 0]
   set AVALON_RESET_CP_NAME [lindex $args 1]
   set ATLANTIC_SOURCE_CP_NAME [lindex $args 2]
   
   set fifowidth [get_parameter_value ENABLE_ENA]

   add_interface $ATLANTIC_SOURCE_CP_NAME avalon_streaming source
   set_interface_property $ATLANTIC_SOURCE_CP_NAME associatedClock $ATLANTIC_SOURCE_CLOCK_CP_NAME
   set_interface_property $ATLANTIC_SOURCE_CP_NAME associatedReset $AVALON_RESET_CP_NAME
   set_interface_property $ATLANTIC_SOURCE_CP_NAME dataBitsPerSymbol   8
   set_interface_property $ATLANTIC_SOURCE_CP_NAME symbolsPerBeat      [expr $fifowidth / 8]
   set_interface_property $ATLANTIC_SOURCE_CP_NAME readyLatency 2
   add_interface_port $ATLANTIC_SOURCE_CP_NAME ff_rx_data  data           Output    $fifowidth
   add_interface_port $ATLANTIC_SOURCE_CP_NAME ff_rx_eop   endofpacket    Output    1
   add_interface_port $ATLANTIC_SOURCE_CP_NAME rx_err      error          Output    6
   if {$fifowidth == 32} {
      add_interface_port $ATLANTIC_SOURCE_CP_NAME ff_rx_mod   empty          Output    2
   } else {
      add_interface $ATLANTIC_SOURCE_CP_NAME\_unused conduit end
      set_interface_property $ATLANTIC_SOURCE_CP_NAME\_unused ENABLED 0
      add_interface_port $ATLANTIC_SOURCE_CP_NAME\_unused ff_rx_mod "export" Output    2
   }
   add_interface_port $ATLANTIC_SOURCE_CP_NAME ff_rx_rdy   ready          Input   1
   add_interface_port $ATLANTIC_SOURCE_CP_NAME ff_rx_sop   startofpacket  Output    1
   add_interface_port $ATLANTIC_SOURCE_CP_NAME ff_rx_dval  valid          Output    1
}

proc build_atlantic_sink_interface {args} {
   set ATLANTIC_SINK_CLOCK_CP_NAME [lindex $args 0]
   set AVALON_RESET_CP_NAME [lindex $args 1]
   set ATLANTIC_SINK_CP_NAME [lindex $args 2]
   
   set fifowidth [get_parameter_value ENABLE_ENA]

   add_interface $ATLANTIC_SINK_CP_NAME avalon_streaming sink
   set_interface_property $ATLANTIC_SINK_CP_NAME associatedClock $ATLANTIC_SINK_CLOCK_CP_NAME
   set_interface_property $ATLANTIC_SINK_CP_NAME associatedReset $AVALON_RESET_CP_NAME
   set_interface_property $ATLANTIC_SINK_CP_NAME dataBitsPerSymbol   8
   set_interface_property $ATLANTIC_SINK_CP_NAME symbolsPerBeat      [expr $fifowidth / 8]
   add_interface_port $ATLANTIC_SINK_CP_NAME ff_tx_data  data           Input    $fifowidth
   add_interface_port $ATLANTIC_SINK_CP_NAME ff_tx_eop   endofpacket    Input    1
   add_interface_port $ATLANTIC_SINK_CP_NAME ff_tx_err   error          Input    1
   if {$fifowidth == 32} {
      add_interface_port $ATLANTIC_SINK_CP_NAME ff_tx_mod   empty          Input    2
   } else {
      add_interface $ATLANTIC_SINK_CP_NAME\_unused conduit end
      set_interface_property $ATLANTIC_SINK_CP_NAME\_unused ENABLED 0
      add_interface_port $ATLANTIC_SINK_CP_NAME\_unused ff_tx_mod "export" Input 2
   }
   add_interface_port $ATLANTIC_SINK_CP_NAME ff_tx_rdy   ready          Output   1
   add_interface_port $ATLANTIC_SINK_CP_NAME ff_tx_sop   startofpacket  Input    1
   add_interface_port $ATLANTIC_SINK_CP_NAME ff_tx_wren  valid          Input    1

}

proc build_mdio_interface {args} {
   set MAC_MDIO_CP_NAME [lindex $args 0]

   add_interface $MAC_MDIO_CP_NAME conduit end
   # MDIO ports
   add_interface_port $MAC_MDIO_CP_NAME "mdc"       "mdc"      Output   1
   add_interface_port $MAC_MDIO_CP_NAME "mdio_in"   "mdio_in"  Input    1
   add_interface_port $MAC_MDIO_CP_NAME "mdio_out"  "mdio_out" Output   1
   add_interface_port $MAC_MDIO_CP_NAME "mdio_oen"  "mdio_oen" Output   1

}

proc build_gmii_interface {args} {
   set MAC_GMII_CP_NAME [lindex $args 0]

   add_interface $MAC_GMII_CP_NAME conduit end
   # GMII ports
   add_interface_port $MAC_GMII_CP_NAME "gm_rx_d"      "gmii_rx_d"       Input    8
   add_interface_port $MAC_GMII_CP_NAME "gm_rx_dv"     "gmii_rx_dv"      Input    1
   add_interface_port $MAC_GMII_CP_NAME "gm_rx_err"    "gmii_rx_err"     Input    1
   add_interface_port $MAC_GMII_CP_NAME "gm_tx_d"      "gmii_tx_d"       Output   8
   add_interface_port $MAC_GMII_CP_NAME "gm_tx_en"     "gmii_tx_en"      Output   1
   add_interface_port $MAC_GMII_CP_NAME "gm_tx_err"    "gmii_tx_err"     Output   1

}

proc enable_rgmii_altgpio_interface {args} {
   set is_enabled [lindex $args 0]
   
   set_interface_property "rgmii_out4_din" ENABLED $is_enabled
   set_interface_property "rgmii_out4_pad" ENABLED $is_enabled
   set_interface_property "rgmii_out4_ck"  ENABLED $is_enabled
   set_interface_property "rgmii_out4_oe"  ENABLED $is_enabled
   set_interface_property "rgmii_out4_aclr" ENABLED $is_enabled

   set_interface_property "rgmii_out1_din" ENABLED $is_enabled
   set_interface_property "rgmii_out1_pad" ENABLED $is_enabled
   set_interface_property "rgmii_out1_ck"  ENABLED $is_enabled
   set_interface_property "rgmii_out1_oe"  ENABLED $is_enabled
   set_interface_property "rgmii_out1_aclr"  ENABLED $is_enabled

   set_interface_property "rgmii_in4_dout" ENABLED $is_enabled
   set_interface_property "rgmii_in4_pad"  ENABLED $is_enabled
   set_interface_property "rgmii_in4_ck"   ENABLED $is_enabled

   set_interface_property "rgmii_in1_dout" ENABLED $is_enabled
   set_interface_property "rgmii_in1_pad"  ENABLED $is_enabled
   set_interface_property "rgmii_in1_ck"   ENABLED $is_enabled
}

proc build_rgmii_altgpio_interface {} {
   array set altgpio_ports {
      "rgmii_out4_din"     {"export"   Output   8}
      "rgmii_out4_pad"     {"export"   Input    4}
      "rgmii_out4_ck"      {"export"   Output   1}
      "rgmii_out4_oe"      {"export"   Output   4}
      "rgmii_out4_aclr"    {"export"   Output   1}

      "rgmii_out1_din"     {"export"   Output   2}
      "rgmii_out1_pad"     {"export"   Input    1}
      "rgmii_out1_ck"      {"export"   Output   1}
      "rgmii_out1_oe"      {"export"   Output   1}
      "rgmii_out1_aclr"    {"export"   Output   1}

      "rgmii_in4_dout"     {"export"   Input    8}
      "rgmii_in4_pad"      {"export"   Output   4}
      "rgmii_in4_ck"       {"export"   Output   1}

      "rgmii_in1_dout"     {"export"   Input    2}
      "rgmii_in1_pad"      {"export"   Output   1}
      "rgmii_in1_ck"       {"export"   Output   1}
   }

   # Build interface to altgpio instances
   foreach {port} [array names altgpio_ports] {
      set role [lindex $altgpio_ports($port) 0]
      set direction [lindex $altgpio_ports($port) 1]
      set width [lindex $altgpio_ports($port) 2]

      add_interface $port conduit end
      add_interface_port $port $port $role $direction $width
   }
}

proc build_rgmii_interface {args} {
   set MAC_RGMII_CP_NAME [lindex $args 0]

   add_interface $MAC_RGMII_CP_NAME conduit end
   # RGMII ports
   add_interface_port $MAC_RGMII_CP_NAME "rgmii_in"     "rgmii_in"      Input    4
   add_interface_port $MAC_RGMII_CP_NAME "rgmii_out"    "rgmii_out"     Output   4
   add_interface_port $MAC_RGMII_CP_NAME "rx_control"   "rx_control"    Input    1
   add_interface_port $MAC_RGMII_CP_NAME "tx_control"   "tx_control"    Output   1

}

proc build_mii_interface {args} {
   set MAC_MII_CP_NAME [lindex $args 0]
   set ENABLE_HD_LOGIC [get_parameter_value ENABLE_HD_LOGIC]
   set connect_to_pcs [get_parameter_value connect_to_pcs]

   add_interface $MAC_MII_CP_NAME conduit end

   # MII ports
   add_interface_port $MAC_MII_CP_NAME "m_rx_d"       "mii_rx_d"     Input    4
   add_interface_port $MAC_MII_CP_NAME "m_rx_en"      "mii_rx_dv"    Input    1
   add_interface_port $MAC_MII_CP_NAME "m_rx_err"     "mii_rx_err"   Input    1
   add_interface_port $MAC_MII_CP_NAME "m_tx_d"       "mii_tx_d"     Output   4
   add_interface_port $MAC_MII_CP_NAME "m_tx_en"      "mii_tx_en"    Output   1
   add_interface_port $MAC_MII_CP_NAME "m_tx_err"     "mii_tx_err"   Output   1

   # Collision interface ports (only enabled for PCS connection, or when HD_LOGIC is enabled)
   if {[expr {"$connect_to_pcs" != "false"} || {"$ENABLE_HD_LOGIC" != "false"}]} {
      add_interface_port $MAC_MII_CP_NAME "m_rx_crs"     "mii_crs"   Input    1
      add_interface_port $MAC_MII_CP_NAME "m_rx_col"     "mii_col"   Input    1

   } else {
      set UNUSED_WIRE_CP_NAME $MAC_MII_CP_NAME\_UNUSED
      add_interface $UNUSED_WIRE_CP_NAME conduit end
      set_interface_property $UNUSED_WIRE_CP_NAME ENABLED 0

      add_interface_port $UNUSED_WIRE_CP_NAME "m_rx_crs"     "mii_crs"   Input    1
      add_interface_port $UNUSED_WIRE_CP_NAME "m_rx_col"     "mii_col"   Input    1

   }
}

proc build_status_interface {args} {
   set MAC_STATUS_CP_NAME [lindex $args 0]
   set connect_to_pcs [get_parameter_value connect_to_pcs]

   add_interface $MAC_STATUS_CP_NAME conduit end
   # Other signals
   add_interface_port $MAC_STATUS_CP_NAME "set_10"       "set_10"       Input    1
   add_interface_port $MAC_STATUS_CP_NAME "set_1000"     "set_1000"     Input    1

   # Control interface signals
   if {$connect_to_pcs} {
      set UNUSED_WIRE_CP_NAME $MAC_STATUS_CP_NAME\_UNUSED
      add_interface $UNUSED_WIRE_CP_NAME conduit end
      set_interface_property $UNUSED_WIRE_CP_NAME ENABLED 0

      add_interface_port $UNUSED_WIRE_CP_NAME "eth_mode"     "eth_mode"     Output   1
      add_interface_port $UNUSED_WIRE_CP_NAME "ena_10"       "ena_10"       Output   1
   } else {
      add_interface_port $MAC_STATUS_CP_NAME "eth_mode"     "eth_mode"     Output   1
      add_interface_port $MAC_STATUS_CP_NAME "ena_10"       "ena_10"       Output   1
   }

}

proc build_misc_conduit_interface {args} {
   set WIRE_CP_NAME [lindex $args 0]

   set ENABLE_MAGIC_DETECT [get_parameter_value ENABLE_MAGIC_DETECT]
   set ENABLE_MAC_FLOW_CTRL [get_parameter_value ENABLE_MAC_FLOW_CTRL]

   add_interface $WIRE_CP_NAME conduit end

   # Flow control signals
   if {$ENABLE_MAC_FLOW_CTRL} {
      add_interface_port $WIRE_CP_NAME "xon_gen"         "export"    Input    1
      add_interface_port $WIRE_CP_NAME "xoff_gen"        "export"    Input    1
   } else {
      set UNUSED_WIRE_CP_NAME "unused_flow_control_conduit"
      add_interface $UNUSED_WIRE_CP_NAME conduit end
      set_interface_property $UNUSED_WIRE_CP_NAME ENABLED 0

      add_interface_port $UNUSED_WIRE_CP_NAME "xon_gen"         "export"    Input    1
      add_interface_port $UNUSED_WIRE_CP_NAME "xoff_gen"        "export"    Input    1
   }

   # Magic packet detect signals
   if {$ENABLE_MAGIC_DETECT} {
      add_interface_port $WIRE_CP_NAME "magic_wakeup"    "export"    Output   1
      add_interface_port $WIRE_CP_NAME "magic_sleep_n"   "export"    Input    1
   } else {
      set UNUSED_WIRE_CP_NAME "unused_flow_control_conduit"
      add_interface $UNUSED_WIRE_CP_NAME conduit end
      set_interface_property $UNUSED_WIRE_CP_NAME ENABLED 0

      add_interface_port $UNUSED_WIRE_CP_NAME "magic_wakeup"    "export"    Output   1
      add_interface_port $UNUSED_WIRE_CP_NAME "magic_sleep_n"   "export"    Input    1

      # Special termination value for magic_sleep_n input port
      set_port_property "magic_sleep_n" TERMINATION_VALUE 1
      set_port_property "magic_sleep_n" TERMINATION 1
   }

   # Transmit FIFO Signals
   add_interface_port $WIRE_CP_NAME "ff_tx_crc_fwd"   "export"    Input    1
   add_interface_port $WIRE_CP_NAME "ff_tx_septy"     "export"    Output   1
   add_interface_port $WIRE_CP_NAME "tx_ff_uflow"     "export"    Output   1
   add_interface_port $WIRE_CP_NAME "ff_tx_a_full"    "export"    Output   1
   add_interface_port $WIRE_CP_NAME "ff_tx_a_empty"   "export"    Output   1

   # Receive FIFO Signals
   add_interface_port $WIRE_CP_NAME "rx_err_stat"     "export"    Output   18
   add_interface_port $WIRE_CP_NAME "rx_frm_type"     "export"    Output   4
   add_interface_port $WIRE_CP_NAME "ff_rx_dsav"      "export"    Output   1
   add_interface_port $WIRE_CP_NAME "ff_rx_a_full"    "export"    Output   1
   add_interface_port $WIRE_CP_NAME "ff_rx_a_empty"   "export"    Output   1

}

proc build_clkena_conduit_interface {args} {
   set WIRE_CP_NAME [lindex $args 0]

   add_interface $WIRE_CP_NAME conduit end
      
   # Clock enable signals
   add_interface_port $WIRE_CP_NAME "rx_clkena"    "rx_clkena"    Input    1
   add_interface_port $WIRE_CP_NAME "tx_clkena"    "tx_clkena"    Input    1
}

proc build_pcs_tx_rx_clock_interface {args} {
   set PCS_MAC_TX_CLOCK_NAME [lindex $args 0]
   set PCS_MAC_RX_CLOCK_NAME [lindex $args 1]

   add_interface $PCS_MAC_TX_CLOCK_NAME clock end
   add_interface_port $PCS_MAC_TX_CLOCK_NAME tx_clk clk Input 1
   set_interface_property $PCS_MAC_TX_CLOCK_NAME ENABLED true

   add_interface $PCS_MAC_RX_CLOCK_NAME clock end
   add_interface_port $PCS_MAC_RX_CLOCK_NAME rx_clk clk Input 1
   set_interface_property $PCS_MAC_RX_CLOCK_NAME ENABLED true

}
