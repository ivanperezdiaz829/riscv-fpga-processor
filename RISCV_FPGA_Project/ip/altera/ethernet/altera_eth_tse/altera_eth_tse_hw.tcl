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


package require -exact qsys 13.1

# 
# module altera_eth_tse
# 
set_module_property NAME altera_eth_tse
set_module_property AUTHOR "Altera Corporation"
set_module_property VERSION "13.1"
set_module_property INTERNAL false
set_module_property GROUP "Interface Protocols/Ethernet"
set_module_property DISPLAY_NAME "Triple-Speed Ethernet"
set_module_property DESCRIPTION "Altera Triple Speed Ethernet"
set_module_property DATASHEET_URL "http://www.altera.com/literature/ug/ug_ethernet.pdf"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false
set_module_property COMPOSITION_CALLBACK compose
set_module_property ANALYZE_HDL false
set_module_property HIDE_FROM_SOPC true
set_module_property VALIDATION_CALLBACK validate
set_module_property PARAMETER_UPGRADE_CALLBACK ip_upgrade

#################################################################################################
# Global variables (constants)
#################################################################################################
source ./altera_eth_tse_common_constants.tcl

#################################################################################################
# Parameters/GUI
#################################################################################################
# Core parameters and GUI
source ./altera_eth_tse_conf.tcl

#################################################################################################
# Testbench
#################################################################################################
source ./altera_eth_tse_tb_gen.tcl

#################################################################################################
# Parameters upgrade callback
################################################################################################
proc ip_upgrade {ip_core_type version parameters} {

   set ifPCSuseEmbeddedSerdes 1

   send_message PROGRESS "Upgrading $ip_core_type version $version"

   foreach { param_name param_value } $parameters {

      if {[expr {$param_name == "ifPCSuseEmbeddedSerdes"}] } {
         # Log the value for this old parameter, we need to use it later
         set ifPCSuseEmbeddedSerdes $param_value
      } else {

         set known_param 0

         # Check if the old parameter is compatible with new core parameter
         foreach {core_param} [get_parameters] {
            if { [expr {$core_param == $param_name}] } {
               set known_param 1
            }
         }

         if {$known_param} {
            set_parameter_value $param_name $param_value
            send_message PROGRESS "Setting parameter $param_name with value $param_value"
         } else {
            send_message PROGRESS "Ignore old parameter $param_name with value $param_value"
         }

      }
   }

   # Update transceiver_type based on ifPCSuseEmbeddedSerdes old parameter
   if [expr {$ifPCSuseEmbeddedSerdes == 0}] {
      send_message PROGRESS "Upgrade transceiver_type parameter value to NONE"
      set_parameter_value transceiver_type "NONE"
   }
}

#################################################################################################
# Compose
#################################################################################################
proc compose {} {

   set isUseMAC [get_parameter_value isUseMAC]
   set isUsePCS [get_parameter_value isUsePCS]
   set enable_use_internal_fifo [get_parameter_value enable_use_internal_fifo]
   set transceiver_type [get_parameter_value transceiver_type]
   set deviceFamily [get_parameter_value deviceFamily]

   # MAC only stuff and if PCS is enabled, instantiate the avalon master arbiter and 
   if {$isUseMAC} {
      # MAC with FIFO
      if {$enable_use_internal_fifo} {
         compose_mac 
      } else {
         # MAC without FIFO
         compose_fifoless_mac
      }
   }

   if {$isUsePCS} {
      switch $transceiver_type {
         LVDS_IO {
            if {[expr {"$deviceFamily" == "ARRIA10"}]} {
               compose_pcs_pma_nf_lvds
            } else {
               # PCS PMA using LVDS IO
               compose_pcs_pma_lvds
            }
         }
         GXB {
            # PCS PMA GXB using PHYIP
            if { [is_use_phyip] } {
               compose_pcs_pma_gxb_phyip
            } elseif { [is_use_nf_phyip] } {
               # PCS PMA GXB using PHYIP for NightFury device family
               compose_pcs_pma_gxb_nf_phyip
            } else {
               # PCS PMA GXB without using PHYIP
               compose_pcs_pma_gxb
            }
         }
         NONE {
            # PCS (without embedded serdes)
            compose_pcs
         }
      }
   }
}

# Compose the mac
# For MAC + PCS, we will instantiate the necessary
# instances like avalon arbiter, clocks, reset so
# that we can connect them to PCS instances later
proc compose_mac {} {
   global mac_instance

   # Connection point names
   global AVALON_CP_NAME
   global AVALON_CLOCK_CP_NAME
   global AVALON_RESET_CP_NAME

   global ATLANTIC_SOURCE_CLOCK_CP_NAME
   global ATLANTIC_SINK_CLOCK_CP_NAME

   global ATLANTIC_SOURCE_CP_NAME
   global ATLANTIC_SINK_CP_NAME

   global ATLANTIC_SOURCE_PACKET_CLASS_CP_NAME

   global WIRE_MISC_CP_NAME
   global MAC_GMII_CP_NAME
   global MAC_MII_CP_NAME
   global MAC_RGMII_CP_NAME
   global MAC_STATUS_CP_NAME
   global MAC_MDIO_CP_NAME

   global PCS_MAC_TX_CLOCK_NAME
   global PCS_MAC_RX_CLOCK_NAME

   set isUseMAC [get_parameter_value isUseMAC]
   set isUsePCS [get_parameter_value isUsePCS]
   set useMDIO [get_parameter_value useMDIO]
   set ifGMII [get_parameter_value ifGMII]
   set deviceFamily [get_parameter_value deviceFamily]

   set use_misc_ports [get_parameter_value use_misc_ports]
   add_instance $mac_instance altera_eth_tse_mac
   # Update MAC instance parameters
   update_mac_instance_param

   if {$isUsePCS} {
      # MAC + PCS variant, we need a avalon arbiter, clock and reset source.
      set_instance_parameter $mac_instance connect_to_pcs true

      # Common register interface clock source and reset source
      add_instance reg_clk_module altera_clock_bridge
      add_instance reg_rst_module altera_reset_bridge

      add_interface $AVALON_CLOCK_CP_NAME clock end
      set_interface_property $AVALON_CLOCK_CP_NAME EXPORT_OF reg_clk_module.in_clk
      set_interface_property $AVALON_CLOCK_CP_NAME PORT_NAME_MAP "clk in_clk"

      add_interface $AVALON_RESET_CP_NAME reset end
      set_interface_property $AVALON_RESET_CP_NAME EXPORT_OF reg_rst_module.in_reset
      set_interface_property $AVALON_RESET_CP_NAME PORT_NAME_MAP "reset in_reset"

      add_connection reg_clk_module.out_clk reg_rst_module.clk

      # Common Avalon slave arbiter
      add_instance avalon_arbiter altera_eth_tse_avalon_arbiter
      set_instance_parameter avalon_arbiter MAX_CHANNELS 1
      set_instance_parameter avalon_arbiter MAC_ONLY 0

      add_connection reg_clk_module.out_clk avalon_arbiter.clk
      add_connection reg_rst_module.out_reset avalon_arbiter.reset

      # Export Avalon slave arbiter slave connection point
      add_interface $AVALON_CP_NAME avalon end
      set_interface_property $AVALON_CP_NAME EXPORT_OF avalon_arbiter.av_slave
      set_interface_property $AVALON_CP_NAME PORT_NAME_MAP "read read write write 
      readdata readdata writedata writedata waitrequest waitrequest address address"

      # Connect clock and reset connection points MAC instance
      add_connection reg_clk_module.out_clk $mac_instance.$AVALON_CLOCK_CP_NAME
      add_connection reg_rst_module.out_reset $mac_instance.$AVALON_RESET_CP_NAME

      # Avalon slave connection point
      add_connection avalon_arbiter.av_mac_master_0 $mac_instance\.$AVALON_CP_NAME

      # We will connect the MAC to PCS after we instantiate the PCS later.

   } else {
      # Export MAC connection points
      add_interface $AVALON_CLOCK_CP_NAME clock end
      set_interface_property $AVALON_CLOCK_CP_NAME EXPORT_OF $mac_instance\.$AVALON_CLOCK_CP_NAME
      compose_rename_and_register_ports $mac_instance $AVALON_CLOCK_CP_NAME

      add_interface $AVALON_RESET_CP_NAME reset end
      set_interface_property $AVALON_RESET_CP_NAME EXPORT_OF $mac_instance\.$AVALON_RESET_CP_NAME
      compose_rename_and_register_ports $mac_instance $AVALON_RESET_CP_NAME

      add_interface $AVALON_CP_NAME avalon end
      set_interface_property $AVALON_CP_NAME EXPORT_OF $mac_instance\.$AVALON_CP_NAME
      compose_rename_and_register_ports $mac_instance $AVALON_CP_NAME

      # Export PCS clocks
      add_interface $PCS_MAC_TX_CLOCK_NAME clock end
      set_interface_property $PCS_MAC_TX_CLOCK_NAME EXPORT_OF $mac_instance\.$PCS_MAC_TX_CLOCK_NAME
      compose_rename_and_register_ports $mac_instance $PCS_MAC_TX_CLOCK_NAME

      add_interface $PCS_MAC_RX_CLOCK_NAME clock end
      set_interface_property $PCS_MAC_RX_CLOCK_NAME EXPORT_OF $mac_instance\.$PCS_MAC_RX_CLOCK_NAME
      compose_rename_and_register_ports $mac_instance $PCS_MAC_RX_CLOCK_NAME

      # Export Protocol specific interface accordingly
      add_interface $MAC_STATUS_CP_NAME conduit end
      set_interface_property $MAC_STATUS_CP_NAME EXPORT_OF $mac_instance\.$MAC_STATUS_CP_NAME
      compose_rename_and_register_ports $mac_instance $MAC_STATUS_CP_NAME

      switch $ifGMII {
         RGMII {
            add_interface $MAC_RGMII_CP_NAME conduit end
            set_interface_property $MAC_RGMII_CP_NAME EXPORT_OF $mac_instance\.$MAC_RGMII_CP_NAME
            compose_rename_and_register_ports $mac_instance $MAC_RGMII_CP_NAME
         }
         GMII {
            add_interface $MAC_GMII_CP_NAME conduit end
            set_interface_property $MAC_GMII_CP_NAME EXPORT_OF $mac_instance\.$MAC_GMII_CP_NAME
            compose_rename_and_register_ports $mac_instance $MAC_GMII_CP_NAME
         }
         MII {
            add_interface $MAC_MII_CP_NAME conduit end
            set_interface_property $MAC_MII_CP_NAME EXPORT_OF $mac_instance\.$MAC_MII_CP_NAME
            compose_rename_and_register_ports $mac_instance $MAC_MII_CP_NAME  
         }
         MII_GMII {
            add_interface $MAC_GMII_CP_NAME conduit end
            set_interface_property $MAC_GMII_CP_NAME EXPORT_OF $mac_instance\.$MAC_GMII_CP_NAME
            compose_rename_and_register_ports $mac_instance $MAC_GMII_CP_NAME

            add_interface $MAC_MII_CP_NAME conduit end
            set_interface_property $MAC_MII_CP_NAME EXPORT_OF $mac_instance\.$MAC_MII_CP_NAME
            compose_rename_and_register_ports $mac_instance $MAC_MII_CP_NAME
         }
      }
   }

   add_interface $ATLANTIC_SOURCE_CLOCK_CP_NAME clock end
   set_interface_property $ATLANTIC_SOURCE_CLOCK_CP_NAME EXPORT_OF $mac_instance\.$ATLANTIC_SOURCE_CLOCK_CP_NAME
   compose_rename_and_register_ports $mac_instance $ATLANTIC_SOURCE_CLOCK_CP_NAME

   add_interface $ATLANTIC_SINK_CLOCK_CP_NAME clock end
   set_interface_property $ATLANTIC_SINK_CLOCK_CP_NAME EXPORT_OF $mac_instance\.$ATLANTIC_SINK_CLOCK_CP_NAME
   compose_rename_and_register_ports $mac_instance $ATLANTIC_SINK_CLOCK_CP_NAME

   add_interface $ATLANTIC_SOURCE_CP_NAME avalon_streaming source
   set_interface_property $ATLANTIC_SOURCE_CP_NAME EXPORT_OF $mac_instance\.$ATLANTIC_SOURCE_CP_NAME
   compose_rename_and_register_ports $mac_instance $ATLANTIC_SOURCE_CP_NAME

   add_interface $ATLANTIC_SINK_CP_NAME avalon_streaming sink
   set_interface_property $ATLANTIC_SINK_CP_NAME EXPORT_OF $mac_instance\.$ATLANTIC_SINK_CP_NAME
   compose_rename_and_register_ports $mac_instance $ATLANTIC_SINK_CP_NAME

   if {$useMDIO} {
      add_interface $MAC_MDIO_CP_NAME conduit end
      set_interface_property $MAC_MDIO_CP_NAME EXPORT_OF $mac_instance\.$MAC_MDIO_CP_NAME
      compose_rename_and_register_ports $mac_instance $MAC_MDIO_CP_NAME
   }

   if {$use_misc_ports} {
      add_interface $WIRE_MISC_CP_NAME conduit end
      set_interface_property $WIRE_MISC_CP_NAME EXPORT_OF $mac_instance\.$WIRE_MISC_CP_NAME
      compose_rename_and_register_ports $mac_instance $WIRE_MISC_CP_NAME
   }

   # Special handling for RGMII interface for Arria 10 device
   # since altera_gpio is used as replacement for altddio_in and altddio_out
   if {[expr {"$deviceFamily" == "ARRIA10"}] && [expr {"$ifGMII" == "RGMII"}]} {
      create_and_connect_altera_gpio_instances 0 $mac_instance
   }
}

# Compose the fifoless MAC
# and instantiate the necessary components to connect to PCS in MAC+PCS variant
proc compose_fifoless_mac {} {

   global fifoless_mac_instance

   # Connection point names
   global AVALON_CP_NAME
   global AVALON_CLOCK_CP_NAME
   global AVALON_RESET_CP_NAME

   global ATLANTIC_SOURCE_CLOCK_CP_NAME
   global ATLANTIC_SINK_CLOCK_CP_NAME

   global ATLANTIC_SOURCE_CP_NAME
   global ATLANTIC_SINK_CP_NAME

   global ATLANTIC_SOURCE_PACKET_CLASS_CP_NAME

   global WIRE_MISC_CP_NAME
   global MAC_GMII_CP_NAME
   global MAC_MII_CP_NAME
   global MAC_RGMII_CP_NAME
   global MAC_STATUS_CP_NAME
   global MAC_MDIO_CP_NAME

   global PCS_MAC_TX_CLOCK_NAME
   global PCS_MAC_RX_CLOCK_NAME

   global MAC_TX_CLOCK_NAME
   global MAC_RX_CLOCK_NAME

   global MAC_RX_FIFO_STATUS_CLOCK_NAME
   global MAC_RX_FIFO_STATUS_NAME

   global MAC_REG_SHARE_OUT_NAME
   global MAC_REG_SHARE_IN_NAME
   
   global TX_PATH_DELAY
   global RX_PATH_DELAY
   global RX_TIME_OF_DAY_96B
   global RX_TIME_OF_DAY_64B
   global TX_TIME_OF_DAY_96B
   global TX_TIME_OF_DAY_64B   
   global RX_INGRESS_TIMESTAMP_96B   
   global RX_INGRESS_TIMESTAMP_64B   
   global TX_EGRESS_TIMESTAMP_96B   
   global TX_EGRESS_TIMESTAMP_64B   
   global TX_EGRESS_TIMESTAMP_REQUEST   
   global TX_ETSTAMP_INS_CTRL   

   set isUseMAC [get_parameter_value isUseMAC]
   set isUsePCS [get_parameter_value isUsePCS]
   set enable_use_internal_fifo [get_parameter_value enable_use_internal_fifo]
   set useMDIO [get_parameter_value useMDIO]
   set ifGMII [get_parameter_value ifGMII]
   set deviceFamily [get_parameter_value deviceFamily]

   set use_misc_ports [get_parameter_value use_misc_ports]
   set max_channels [get_parameter_value max_channels]
   
   # check 1588 criteria
   set enable_sgmii [get_parameter_value enable_sgmii]
   set core_variation [get_parameter_value core_variation]
   set deviceFamily [get_parameter_value deviceFamily]
   set transceiver_type [get_parameter_value transceiver_type]
   if { $enable_sgmii &&
      [expr {"$core_variation" == "MAC_PCS"}] &&
      [expr {"$transceiver_type" == "GXB"}] &&
      [expr {"$enable_use_internal_fifo" == "false"}] &&
      [expr {"$deviceFamily" == "ARRIA10"} || {"$deviceFamily" == "STRATIXV"} || {"$deviceFamily" == "ARRIAV"}  || {"$deviceFamily" == "ARRIAVGZ"}  || {"$deviceFamily" == "CYCLONEV"}]} {
      set enable_timestamping [get_parameter_value enable_timestamping]
   } elseif {[expr {$ifGMII == "MII_GMII"}] &&
      [expr {"$core_variation" == "MAC_ONLY"}] &&
      [expr {"$enable_use_internal_fifo" == "false"}] &&
      [expr {"$deviceFamily" == "ARRIA10"} || {"$deviceFamily" == "STRATIXV"} || {"$deviceFamily" == "ARRIAV"}  || {"$deviceFamily" == "ARRIAVGZ"}  || {"$deviceFamily" == "CYCLONEV"}]} {
      set enable_timestamping [get_parameter_value enable_timestamping]
   } else {
      set enable_timestamping 0
   }   

   set cb_reg_share_instance i_cb_reg_share
   
   # Common register interface clock source and reset source
   add_instance reg_clk_module altera_clock_bridge
   add_instance reg_rst_module altera_reset_bridge

   add_interface $AVALON_CLOCK_CP_NAME clock end
   set_interface_property $AVALON_CLOCK_CP_NAME EXPORT_OF reg_clk_module.in_clk
   set_interface_property $AVALON_CLOCK_CP_NAME PORT_NAME_MAP "clk in_clk"

   add_interface $AVALON_RESET_CP_NAME reset end
   set_interface_property $AVALON_RESET_CP_NAME EXPORT_OF reg_rst_module.in_reset
   set_interface_property $AVALON_RESET_CP_NAME PORT_NAME_MAP "reset in_reset"

   add_connection reg_clk_module.out_clk reg_rst_module.clk

   # Common Avalon slave arbiter
   add_instance avalon_arbiter altera_eth_tse_avalon_arbiter
   set_instance_parameter avalon_arbiter MAX_CHANNELS $max_channels
   # Decide if we need the arbiter to have ports for PCS
   if {$isUsePCS} {
      set_instance_parameter avalon_arbiter MAC_ONLY 0
   } else {
      set_instance_parameter avalon_arbiter MAC_ONLY 1
   }

   add_connection reg_clk_module.out_clk avalon_arbiter.clk
   add_connection reg_rst_module.out_reset avalon_arbiter.reset

   add_interface $AVALON_CP_NAME avalon end
   set_interface_property $AVALON_CP_NAME EXPORT_OF avalon_arbiter.av_slave
   set_interface_property $AVALON_CP_NAME PORT_NAME_MAP "read read write write 
      readdata readdata writedata writedata waitrequest waitrequest address address"

   # RX status clock source
   add_instance rx_fifo_status_clk_module altera_clock_bridge

   add_interface $MAC_RX_FIFO_STATUS_CLOCK_NAME clock end
   set_interface_property $MAC_RX_FIFO_STATUS_CLOCK_NAME EXPORT_OF rx_fifo_status_clk_module.in_clk
   set_interface_property $MAC_RX_FIFO_STATUS_CLOCK_NAME PORT_NAME_MAP "rx_afull_clk in_clk"

   # Channel adapter for RX status sink
   add_instance channel_adapter altera_eth_tse_channel_adapter
   set_instance_parameter channel_adapter CHANNEL_WIDTH [log2_in_int $max_channels]
   set_instance_parameter channel_adapter MAX_CHANNELS $max_channels

   add_connection rx_fifo_status_clk_module.out_clk channel_adapter.clk
   add_connection reg_rst_module.out_reset channel_adapter.reset

   add_interface $MAC_RX_FIFO_STATUS_NAME avalon_streaming sink
   set_interface_property $MAC_RX_FIFO_STATUS_NAME EXPORT_OF channel_adapter.channel_in
   set_interface_property $MAC_RX_FIFO_STATUS_NAME PORT_NAME_MAP "rx_afull_data rx_afull_data 
      rx_afull_valid rx_afull_valid rx_afull_channel rx_afull_channel"

   for {set index 0} { $index < $max_channels} {incr index} {
      set instance_name $fifoless_mac_instance\_$index
      add_instance $instance_name altera_eth_tse_fifoless_mac
      

      # Update fifoless MAC instance parameters
      update_fifoless_mac_instance_param $index
      set_instance_parameter $instance_name connect_to_pcs $isUsePCS

      # Connect clock and reset connection points for each MAC instance
      add_connection reg_clk_module.out_clk $instance_name.$AVALON_CLOCK_CP_NAME
      add_connection reg_rst_module.out_reset $instance_name.$AVALON_RESET_CP_NAME

      # Avalon slave connection point
      add_connection avalon_arbiter.av_mac_master_$index $instance_name\.$AVALON_CP_NAME

      # RX fifo status clock
      add_connection rx_fifo_status_clk_module.out_clk $instance_name.$MAC_RX_FIFO_STATUS_CLOCK_NAME

      # RX fifo status sink interface
      add_connection channel_adapter.channel_out_$index $instance_name\.$MAC_RX_FIFO_STATUS_NAME

      # Export MAC connection points


      add_interface $MAC_RX_CLOCK_NAME\_$index clock source
      set_interface_property $MAC_RX_CLOCK_NAME\_$index  EXPORT_OF $instance_name\.$MAC_RX_CLOCK_NAME
      compose_rename_and_register_ports $instance_name $MAC_RX_CLOCK_NAME $index

      add_interface $MAC_TX_CLOCK_NAME\_$index clock source
      set_interface_property $MAC_TX_CLOCK_NAME\_$index  EXPORT_OF $instance_name\.$MAC_TX_CLOCK_NAME
      compose_rename_and_register_ports $instance_name $MAC_TX_CLOCK_NAME $index

      add_interface $ATLANTIC_SOURCE_CP_NAME\_$index avalon_streaming source
      set_interface_property $ATLANTIC_SOURCE_CP_NAME\_$index  EXPORT_OF $instance_name\.$ATLANTIC_SOURCE_CP_NAME
      compose_rename_and_register_ports $instance_name $ATLANTIC_SOURCE_CP_NAME $index

      add_interface $ATLANTIC_SINK_CP_NAME\_$index avalon_streaming sink
      set_interface_property $ATLANTIC_SINK_CP_NAME\_$index  EXPORT_OF $instance_name\.$ATLANTIC_SINK_CP_NAME
      compose_rename_and_register_ports $instance_name $ATLANTIC_SINK_CP_NAME $index

      add_interface $ATLANTIC_SOURCE_PACKET_CLASS_CP_NAME\_$index avalon_streaming source
      set_interface_property $ATLANTIC_SOURCE_PACKET_CLASS_CP_NAME\_$index EXPORT_OF $instance_name\.$ATLANTIC_SOURCE_PACKET_CLASS_CP_NAME
      compose_rename_and_register_ports $instance_name $ATLANTIC_SOURCE_PACKET_CLASS_CP_NAME $index
     
     # Export timestamp port
      if {$enable_timestamping} {
         add_interface $RX_TIME_OF_DAY_96B\_$index  conduit end
         set_interface_property $RX_TIME_OF_DAY_96B\_$index  EXPORT_OF $instance_name\.$RX_TIME_OF_DAY_96B
         compose_rename_and_register_ports $instance_name $RX_TIME_OF_DAY_96B $index

         add_interface $RX_TIME_OF_DAY_64B\_$index  conduit end
         set_interface_property $RX_TIME_OF_DAY_64B\_$index  EXPORT_OF $instance_name\.$RX_TIME_OF_DAY_64B
         compose_rename_and_register_ports $instance_name $RX_TIME_OF_DAY_64B $index

         add_interface $TX_TIME_OF_DAY_96B\_$index  conduit end
         set_interface_property $TX_TIME_OF_DAY_96B\_$index  EXPORT_OF $instance_name\.$TX_TIME_OF_DAY_96B
         compose_rename_and_register_ports $instance_name $TX_TIME_OF_DAY_96B $index

         add_interface $TX_TIME_OF_DAY_64B\_$index  conduit end
         set_interface_property $TX_TIME_OF_DAY_64B\_$index  EXPORT_OF $instance_name\.$TX_TIME_OF_DAY_64B
         compose_rename_and_register_ports $instance_name $TX_TIME_OF_DAY_64B $index

         add_interface $RX_INGRESS_TIMESTAMP_96B\_$index  conduit end
         set_interface_property $RX_INGRESS_TIMESTAMP_96B\_$index  EXPORT_OF $instance_name\.$RX_INGRESS_TIMESTAMP_96B
         compose_rename_and_register_ports $instance_name $RX_INGRESS_TIMESTAMP_96B $index

         add_interface $RX_INGRESS_TIMESTAMP_64B\_$index  conduit end
         set_interface_property $RX_INGRESS_TIMESTAMP_64B\_$index  EXPORT_OF $instance_name\.$RX_INGRESS_TIMESTAMP_64B
         compose_rename_and_register_ports $instance_name $RX_INGRESS_TIMESTAMP_64B $index

         add_interface $TX_EGRESS_TIMESTAMP_96B\_$index  conduit end
         set_interface_property $TX_EGRESS_TIMESTAMP_96B\_$index  EXPORT_OF $instance_name\.$TX_EGRESS_TIMESTAMP_96B
         compose_rename_and_register_ports $instance_name $TX_EGRESS_TIMESTAMP_96B $index

         add_interface $TX_EGRESS_TIMESTAMP_64B\_$index  conduit end
         set_interface_property $TX_EGRESS_TIMESTAMP_64B\_$index  EXPORT_OF $instance_name\.$TX_EGRESS_TIMESTAMP_64B
         compose_rename_and_register_ports $instance_name $TX_EGRESS_TIMESTAMP_64B $index

         add_interface $TX_EGRESS_TIMESTAMP_REQUEST\_$index  conduit end
         set_interface_property $TX_EGRESS_TIMESTAMP_REQUEST\_$index  EXPORT_OF $instance_name\.$TX_EGRESS_TIMESTAMP_REQUEST
         compose_rename_and_register_ports $instance_name $TX_EGRESS_TIMESTAMP_REQUEST $index

         add_interface $TX_ETSTAMP_INS_CTRL\_$index  conduit end
         set_interface_property $TX_ETSTAMP_INS_CTRL\_$index  EXPORT_OF $instance_name\.$TX_ETSTAMP_INS_CTRL
         compose_rename_and_register_ports $instance_name $TX_ETSTAMP_INS_CTRL $index 
         
         if {[expr {"$core_variation" == "MAC_ONLY"}]} {
            add_interface $TX_PATH_DELAY\_$index  conduit end
            set_interface_property $TX_PATH_DELAY\_$index  EXPORT_OF $instance_name\.$TX_PATH_DELAY
            compose_rename_and_register_ports $instance_name $TX_PATH_DELAY $index   

            add_interface $RX_PATH_DELAY\_$index  conduit end
            set_interface_property $RX_PATH_DELAY\_$index  EXPORT_OF $instance_name\.$RX_PATH_DELAY
            compose_rename_and_register_ports $instance_name $RX_PATH_DELAY $index                
         }
      }

      if {$use_misc_ports} {
         add_interface $WIRE_MISC_CP_NAME\_$index  conduit end
         set_interface_property $WIRE_MISC_CP_NAME\_$index  EXPORT_OF $instance_name\.$WIRE_MISC_CP_NAME
         compose_rename_and_register_ports $instance_name $WIRE_MISC_CP_NAME $index
      }

      # Special handling for RGMII interface for Arria 10 device
      # since altera_gpio is used as replacement for altddio_in and altddio_out
      if {[expr {"$deviceFamily" == "ARRIA10"}] && [expr {"$ifGMII" == "RGMII"}]} {

         create_and_connect_altera_gpio_instances $index

         add_connection rgmii_in4_$index.core_pad_in $instance_name.rgmii_in4_pad
         add_connection rgmii_in4_$index.core_dout $instance_name.rgmii_in4_dout
         add_connection rgmii_in4_$index.core_ck $instance_name.rgmii_in4_ck
   
         add_connection rgmii_in1_$index.core_pad_in $instance_name.rgmii_in1_pad
         add_connection rgmii_in1_$index.core_dout $instance_name.rgmii_in1_dout
         add_connection rgmii_in1_$index.core_ck $instance_name.rgmii_in1_ck
   
         add_connection rgmii_out4_$index.core_pad_out $instance_name.rgmii_out4_pad
         add_connection rgmii_out4_$index.core_din $instance_name.rgmii_out4_din
         add_connection rgmii_out4_$index.core_ck $instance_name.rgmii_out4_ck
         add_connection rgmii_out4_$index.core_oe $instance_name.rgmii_out4_oe
   
         add_connection rgmii_out1_$index.core_pad_out $instance_name.rgmii_out1_pad
         add_connection rgmii_out1_$index.core_din $instance_name.rgmii_out1_din
         add_connection rgmii_out1_$index.core_ck $instance_name.rgmii_out1_ck
         add_connection rgmii_out1_$index.core_oe $instance_name.rgmii_out1_oe
      }
      if {$isUsePCS} {
         # We will connect the MAC to PCS during the PCS instantiation process later.
      } else {
         
         # Export PCS clocks
         add_interface $PCS_MAC_TX_CLOCK_NAME\_$index  clock end
         set_interface_property $PCS_MAC_TX_CLOCK_NAME\_$index  EXPORT_OF $instance_name\.$PCS_MAC_TX_CLOCK_NAME
         compose_rename_and_register_ports $instance_name $PCS_MAC_TX_CLOCK_NAME $index
   
         add_interface $PCS_MAC_RX_CLOCK_NAME\_$index  clock end
         set_interface_property $PCS_MAC_RX_CLOCK_NAME\_$index  EXPORT_OF $instance_name\.$PCS_MAC_RX_CLOCK_NAME
         compose_rename_and_register_ports $instance_name $PCS_MAC_RX_CLOCK_NAME $index
   
         # Export Protocol specific interface accordingly
         add_interface $MAC_STATUS_CP_NAME\_$index  conduit end
         set_interface_property $MAC_STATUS_CP_NAME\_$index EXPORT_OF $instance_name\.$MAC_STATUS_CP_NAME
         compose_rename_and_register_ports $instance_name $MAC_STATUS_CP_NAME $index
   
         switch $ifGMII {
            RGMII {
               add_interface $MAC_RGMII_CP_NAME\_$index conduit end
               set_interface_property $MAC_RGMII_CP_NAME\_$index EXPORT_OF $instance_name\.$MAC_RGMII_CP_NAME
               compose_rename_and_register_ports $instance_name $MAC_RGMII_CP_NAME $index
            }
            GMII {
               add_interface $MAC_GMII_CP_NAME\_$index conduit end
               set_interface_property $MAC_GMII_CP_NAME\_$index EXPORT_OF $instance_name\.$MAC_GMII_CP_NAME
               compose_rename_and_register_ports $instance_name $MAC_GMII_CP_NAME $index
            }
            MII {
               add_interface $MAC_MII_CP_NAME\_$index conduit end
               set_interface_property $MAC_MII_CP_NAME\_$index EXPORT_OF $instance_name\.$MAC_MII_CP_NAME
               compose_rename_and_register_ports $instance_name $MAC_MII_CP_NAME $index
            }
            MII_GMII {
               add_interface $MAC_GMII_CP_NAME\_$index conduit end
               set_interface_property $MAC_GMII_CP_NAME\_$index EXPORT_OF $instance_name\.$MAC_GMII_CP_NAME
               compose_rename_and_register_ports $instance_name $MAC_GMII_CP_NAME $index
   
               add_interface $MAC_MII_CP_NAME\_$index conduit end
               set_interface_property $MAC_MII_CP_NAME\_$index EXPORT_OF $instance_name\.$MAC_MII_CP_NAME
               compose_rename_and_register_ports $instance_name $MAC_MII_CP_NAME $index
            }
         }
      }

      if {[expr $max_channels == 1]} {
         # If we only have one channel, then we don't need the register sharing ports.
         set_instance_parameter $instance_name use_register_sharing 0
         # MDIO is only enabled in channel 0
         set_instance_parameter $instance_name ENABLE_MDIO $useMDIO

         # Export the MDIO connection point
         if {$useMDIO} {
            add_interface $MAC_MDIO_CP_NAME conduit end
            set_interface_property $MAC_MDIO_CP_NAME EXPORT_OF $instance_name\.$MAC_MDIO_CP_NAME
            compose_rename_and_register_ports $instance_name $MAC_MDIO_CP_NAME
         }
      } else {
         set_instance_parameter $instance_name use_register_sharing 1

         # Let us connect the reg_share_out to reg_share_in from instance 0 to other instance
         if {[expr $index == 0]} {
            # MDIO is only enabled in channel 0
            set_instance_parameter $instance_name ENABLE_MDIO $useMDIO

            # Export the MDIO connection point
            if {$useMDIO} {
               add_interface $MAC_MDIO_CP_NAME conduit end
               set_interface_property $MAC_MDIO_CP_NAME EXPORT_OF $instance_name\.$MAC_MDIO_CP_NAME
               compose_rename_and_register_ports $instance_name $MAC_MDIO_CP_NAME
            }

            add_instance $cb_reg_share_instance altera_eth_tse_conduit_fanout
            set_instance_parameter $cb_reg_share_instance NUM_FANOUT [expr $max_channels - 1]
            set_instance_parameter $cb_reg_share_instance PORT_LIST "pause_quant,16 frm_length_max,16 tx_ipg_len,5"

            add_connection $instance_name.$MAC_REG_SHARE_OUT_NAME $cb_reg_share_instance.sig_input

         } else {
            set instance_name_0 $fifoless_mac_instance\_0
            set index_minus_one [expr $index - 1]

            # MDIO is only enabled in channel 0
            set_instance_parameter $instance_name ENABLE_MDIO 0

            add_connection $cb_reg_share_instance.sig_fanout$index_minus_one $instance_name.$MAC_REG_SHARE_IN_NAME
         }
      }
   }
}

# Compose the pcs without transceiver
# and connect to MAC if it is MAC+PCS variant
proc compose_pcs {} {
   global mac_instance
   global fifoless_mac_instance
   global pcs_instance

   # Connection point names
   global AVALON_CP_NAME
   global AVALON_CLOCK_CP_NAME
   global AVALON_RESET_CP_NAME

   global PCS_MAC_TX_CLOCK_NAME
   global PCS_MAC_RX_CLOCK_NAME

   global PCS_TX_CLK_NAME
   global PCS_RX_CLK_NAME
   global PCS_REF_CLK_CP_NAME

   global PCS_TX_RESET_NAME
   global PCS_RX_RESET_NAME

   global PCS_GMII_CP_NAME
   global PCS_MII_CP_NAME

   global PCS_CLKENA_CP_NAME

   global PCS_SGMII_STATUS_CP_NAME
   global PCS_STATUS_LED_CP_NAME
   global PCS_SERDES_CONTROL_CP_NAME

   global PCS_TBI_CP_NAME

   global MAC_GMII_CP_NAME
   global MAC_MII_CP_NAME
   global MAC_STATUS_CP_NAME
   global WIRE_CLKENA_CP_NAME

   set isUseMAC [get_parameter_value isUseMAC]
   set isUsePCS [get_parameter_value isUsePCS]
   set enable_use_internal_fifo [get_parameter_value enable_use_internal_fifo]

   set max_channels [get_parameter_value max_channels]

   set enable_sgmii [get_parameter_value enable_sgmii]
   set enable_clk_sharing [get_parameter_value enable_clk_sharing]

   # Decide if this is a multiple channel MAC+PCS core variation
   if {$isUseMAC} {
      if {$enable_use_internal_fifo} {
         set pcs_max_channels 1
      } else {
         set pcs_max_channels $max_channels\
      }
   } else {
      set pcs_max_channels 1
   }

   if {$enable_clk_sharing} {
      # Common ref_clk clock source
      add_instance ref_clk_module altera_clock_bridge

      add_interface $PCS_REF_CLK_CP_NAME clock end
      set_interface_property $PCS_REF_CLK_CP_NAME EXPORT_OF ref_clk_module.in_clk
      set_interface_property $PCS_REF_CLK_CP_NAME PORT_NAME_MAP "ref_clk in_clk"
   }

   for {set index 0} { $index < $pcs_max_channels} {incr index} {
      set the_pcs_instance $pcs_instance\_$index

      add_instance $the_pcs_instance altera_eth_tse_pcs

      # Update the instance parameter
      update_pcs_instance_param $index
      set_instance_parameter $the_pcs_instance connect_to_mac $isUseMAC

      if {$isUseMAC} {
         # MAC+PCS variant, let us connect the MAC to PCS
         
         # Connect clock and reset connection points MAC instance
         add_connection reg_clk_module.out_clk $the_pcs_instance.$AVALON_CLOCK_CP_NAME
         add_connection reg_rst_module.out_reset $the_pcs_instance.$AVALON_RESET_CP_NAME

         # Connect the ref_clk if clock sharing is enabled
         if {$enable_clk_sharing} {
            add_connection ref_clk_module.out_clk $the_pcs_instance.$PCS_REF_CLK_CP_NAME
         }

         # Avalon slave connection point
         add_connection avalon_arbiter.av_pcs_master_$index $the_pcs_instance\.$AVALON_CP_NAME

         # Decide if we are connecting to fifoless mac or not
         if {$enable_use_internal_fifo} {
            set the_mac_instance $mac_instance
         } else {
            set the_mac_instance $fifoless_mac_instance\_$index
         }

         # Connect MAC to PCS clock
         add_connection $the_pcs_instance.$PCS_TX_CLK_NAME $the_mac_instance.$PCS_MAC_TX_CLOCK_NAME
         add_connection $the_pcs_instance.$PCS_RX_CLK_NAME $the_mac_instance.$PCS_MAC_RX_CLOCK_NAME
         
         # Connect reset to PCS tx clock and rx clock reset (QSYS will add the reset synchronizer for us)
         add_connection reg_rst_module.out_reset $the_pcs_instance.$PCS_TX_RESET_NAME
         add_connection reg_rst_module.out_reset $the_pcs_instance.$PCS_RX_RESET_NAME

         # Connect MAC to PCS ports
         add_connection $the_mac_instance\.$MAC_GMII_CP_NAME   $the_pcs_instance.$PCS_GMII_CP_NAME
         add_connection $the_mac_instance\.$MAC_MII_CP_NAME    $the_pcs_instance.$PCS_MII_CP_NAME
         add_connection $the_mac_instance\.$MAC_STATUS_CP_NAME $the_pcs_instance.$PCS_SGMII_STATUS_CP_NAME
         add_connection $the_mac_instance\.$WIRE_CLKENA_CP_NAME $the_pcs_instance.$PCS_CLKENA_CP_NAME

         # Export the status led, serdes control and tbi connection point
         # If it is MAC + PCS with FIFO variant, don't use index number.
         if {$enable_use_internal_fifo} {
            add_interface $PCS_STATUS_LED_CP_NAME conduit end
            set_interface_property $PCS_STATUS_LED_CP_NAME EXPORT_OF $the_pcs_instance\.$PCS_STATUS_LED_CP_NAME
            compose_rename_and_register_ports $the_pcs_instance $PCS_STATUS_LED_CP_NAME

            add_interface $PCS_SERDES_CONTROL_CP_NAME  conduit end
            set_interface_property $PCS_SERDES_CONTROL_CP_NAME  EXPORT_OF $the_pcs_instance\.$PCS_SERDES_CONTROL_CP_NAME
            compose_rename_and_register_ports $the_pcs_instance $PCS_SERDES_CONTROL_CP_NAME

            add_interface $PCS_TBI_CP_NAME  conduit end
            set_interface_property $PCS_TBI_CP_NAME  EXPORT_OF $the_pcs_instance\.$PCS_TBI_CP_NAME
            compose_rename_and_register_ports $the_pcs_instance $PCS_TBI_CP_NAME
         } else {
            add_interface $PCS_STATUS_LED_CP_NAME\_$index conduit end
            set_interface_property $PCS_STATUS_LED_CP_NAME\_$index  EXPORT_OF $the_pcs_instance\.$PCS_STATUS_LED_CP_NAME
            compose_rename_and_register_ports $the_pcs_instance $PCS_STATUS_LED_CP_NAME $index

            add_interface $PCS_SERDES_CONTROL_CP_NAME\_$index  conduit end
            set_interface_property $PCS_SERDES_CONTROL_CP_NAME\_$index  EXPORT_OF $the_pcs_instance\.$PCS_SERDES_CONTROL_CP_NAME
            compose_rename_and_register_ports $the_pcs_instance $PCS_SERDES_CONTROL_CP_NAME $index

            add_interface $PCS_TBI_CP_NAME\_$index  conduit end
            set_interface_property $PCS_TBI_CP_NAME\_$index  EXPORT_OF $the_pcs_instance\.$PCS_TBI_CP_NAME
            compose_rename_and_register_ports $the_pcs_instance $PCS_TBI_CP_NAME $index
         }

      } else {
         # Export PCS connection points
         add_interface $AVALON_CLOCK_CP_NAME clock end
         set_interface_property $AVALON_CLOCK_CP_NAME EXPORT_OF $the_pcs_instance\.$AVALON_CLOCK_CP_NAME
         compose_rename_and_register_ports $the_pcs_instance $AVALON_CLOCK_CP_NAME

         add_interface $AVALON_RESET_CP_NAME reset end
         set_interface_property $AVALON_RESET_CP_NAME EXPORT_OF $the_pcs_instance\.$AVALON_RESET_CP_NAME
         compose_rename_and_register_ports $the_pcs_instance $AVALON_RESET_CP_NAME

         add_interface $AVALON_CP_NAME avalon end
         set_interface_property $AVALON_CP_NAME EXPORT_OF $the_pcs_instance\.$AVALON_CP_NAME
         compose_rename_and_register_ports $the_pcs_instance $AVALON_CP_NAME

         add_interface $PCS_TX_CLK_NAME clock source
         set_interface_property $PCS_TX_CLK_NAME EXPORT_OF $the_pcs_instance\.$PCS_TX_CLK_NAME
         compose_rename_and_register_ports $the_pcs_instance $PCS_TX_CLK_NAME

         add_interface $PCS_RX_CLK_NAME clock source
         set_interface_property $PCS_RX_CLK_NAME EXPORT_OF $the_pcs_instance\.$PCS_RX_CLK_NAME
         compose_rename_and_register_ports $the_pcs_instance $PCS_RX_CLK_NAME

         add_interface $PCS_TX_RESET_NAME reset end
         set_interface_property $PCS_TX_RESET_NAME EXPORT_OF $the_pcs_instance\.$PCS_TX_RESET_NAME
         compose_rename_and_register_ports $the_pcs_instance $PCS_TX_RESET_NAME

         add_interface $PCS_RX_RESET_NAME reset end
         set_interface_property $PCS_RX_RESET_NAME EXPORT_OF $the_pcs_instance\.$PCS_RX_RESET_NAME
         compose_rename_and_register_ports $the_pcs_instance $PCS_RX_RESET_NAME

         add_interface $PCS_GMII_CP_NAME conduit end
         set_interface_property $PCS_GMII_CP_NAME EXPORT_OF $the_pcs_instance\.$PCS_GMII_CP_NAME
         compose_rename_and_register_ports $the_pcs_instance $PCS_GMII_CP_NAME

         if {$enable_sgmii} {
            add_interface $PCS_CLKENA_CP_NAME conduit end
            set_interface_property $PCS_CLKENA_CP_NAME EXPORT_OF $the_pcs_instance\.$PCS_CLKENA_CP_NAME
            compose_rename_and_register_ports $the_pcs_instance $PCS_CLKENA_CP_NAME

            add_interface $PCS_MII_CP_NAME conduit end
            set_interface_property $PCS_MII_CP_NAME EXPORT_OF $the_pcs_instance\.$PCS_MII_CP_NAME
            compose_rename_and_register_ports $the_pcs_instance $PCS_MII_CP_NAME
         
            add_interface $PCS_SGMII_STATUS_CP_NAME conduit end
            set_interface_property $PCS_SGMII_STATUS_CP_NAME EXPORT_OF $the_pcs_instance\.$PCS_SGMII_STATUS_CP_NAME
            compose_rename_and_register_ports $the_pcs_instance $PCS_SGMII_STATUS_CP_NAME
         }

         add_interface $PCS_STATUS_LED_CP_NAME conduit end
         set_interface_property $PCS_STATUS_LED_CP_NAME EXPORT_OF $the_pcs_instance\.$PCS_STATUS_LED_CP_NAME
         compose_rename_and_register_ports $the_pcs_instance $PCS_STATUS_LED_CP_NAME

         add_interface $PCS_SERDES_CONTROL_CP_NAME conduit end
         set_interface_property $PCS_SERDES_CONTROL_CP_NAME EXPORT_OF $the_pcs_instance\.$PCS_SERDES_CONTROL_CP_NAME
         compose_rename_and_register_ports $the_pcs_instance $PCS_SERDES_CONTROL_CP_NAME

         add_interface $PCS_TBI_CP_NAME conduit end
         set_interface_property $PCS_TBI_CP_NAME EXPORT_OF $the_pcs_instance\.$PCS_TBI_CP_NAME
         compose_rename_and_register_ports $the_pcs_instance $PCS_TBI_CP_NAME
      }
   }
}

# Compose the pcs_pma_lvds
# and connect to MAC in MAC+PCS+PMA LVDS_IO variant
proc compose_pcs_pma_lvds {} {
   
   global mac_instance
   global fifoless_mac_instance
   global pcs_instance

   # Connection point names
   global AVALON_CP_NAME
   global AVALON_CLOCK_CP_NAME
   global AVALON_RESET_CP_NAME

   global PCS_MAC_TX_CLOCK_NAME
   global PCS_MAC_RX_CLOCK_NAME

   global PCS_TX_CLK_NAME
   global PCS_RX_CLK_NAME
   global PCS_REF_CLK_CP_NAME

   global PCS_TX_RESET_NAME
   global PCS_RX_RESET_NAME

   global PCS_GMII_CP_NAME
   global PCS_MII_CP_NAME

   global PCS_CLKENA_CP_NAME

   global PCS_SGMII_STATUS_CP_NAME
   global PCS_STATUS_LED_CP_NAME
   global PCS_SERDES_CONTROL_CP_NAME
   global PMA_SERIAL_CP_NAME
   global PMA_GXB_CAL_BLK_CLK_CP_NAME

   global MAC_GMII_CP_NAME
   global MAC_MII_CP_NAME
   global MAC_STATUS_CP_NAME
   global WIRE_CLKENA_CP_NAME

   set isUseMAC [get_parameter_value isUseMAC]
   set isUsePCS [get_parameter_value isUsePCS]
   set enable_use_internal_fifo [get_parameter_value enable_use_internal_fifo]
   set useMDIO [get_parameter_value useMDIO]

   set max_channels [get_parameter_value max_channels]

   set enable_sgmii [get_parameter_value enable_sgmii]
   set enable_clk_sharing [get_parameter_value enable_clk_sharing]

   # Decide if this is a multiple channel MAC+PCS core variation
   if {$isUseMAC} {
      if {$enable_use_internal_fifo} {
         set pcs_max_channels 1
      } else {
         set pcs_max_channels $max_channels\
      }
   } else {
      set pcs_max_channels 1
   }

   # Common ref_clk clock source
   add_instance ref_clk_module altera_clock_bridge

   add_interface $PCS_REF_CLK_CP_NAME clock end
   set_interface_property $PCS_REF_CLK_CP_NAME EXPORT_OF ref_clk_module.in_clk
   set_interface_property $PCS_REF_CLK_CP_NAME PORT_NAME_MAP "ref_clk in_clk"

   for {set index 0} { $index < $pcs_max_channels} {incr index} {
      set the_pcs_instance $pcs_instance\_$index

      add_instance $the_pcs_instance altera_eth_tse_pcs_pma_lvds

      # Update the instance parameter
      update_pcs_pma_lvds_instance_param $index
      set_instance_parameter $the_pcs_instance connect_to_mac $isUseMAC

      # Connect the ref_clk to PCS instance
      add_connection ref_clk_module.out_clk $the_pcs_instance.$PCS_REF_CLK_CP_NAME

      if {$isUseMAC} {
         # MAC+PCS variant, let us connect the MAC to PCS
         
         # Connect clock and reset connection points MAC instance
         add_connection reg_clk_module.out_clk $the_pcs_instance.$AVALON_CLOCK_CP_NAME
         add_connection reg_rst_module.out_reset $the_pcs_instance.$AVALON_RESET_CP_NAME

         # Avalon slave connection point
         add_connection avalon_arbiter.av_pcs_master_$index $the_pcs_instance\.$AVALON_CP_NAME

         # Decide if we are connecting to fifoless mac or not
         if {$enable_use_internal_fifo} {
            set the_mac_instance $mac_instance
         } else {
            set the_mac_instance $fifoless_mac_instance\_$index
         }

         # Connect MAC to PCS clock
         add_connection $the_pcs_instance.$PCS_TX_CLK_NAME $the_mac_instance.$PCS_MAC_TX_CLOCK_NAME
         add_connection $the_pcs_instance.$PCS_RX_CLK_NAME $the_mac_instance.$PCS_MAC_RX_CLOCK_NAME
         
         # Connect reset to PCS tx clock and rx clock reset (QSYS will add the reset synchronizer for us)
         add_connection reg_rst_module.out_reset $the_pcs_instance.$PCS_TX_RESET_NAME
         add_connection reg_rst_module.out_reset $the_pcs_instance.$PCS_RX_RESET_NAME

         # Connect MAC to PCS ports
         add_connection $the_mac_instance\.$MAC_GMII_CP_NAME   $the_pcs_instance.$PCS_GMII_CP_NAME
         add_connection $the_mac_instance\.$MAC_MII_CP_NAME    $the_pcs_instance.$PCS_MII_CP_NAME
         add_connection $the_mac_instance\.$MAC_STATUS_CP_NAME $the_pcs_instance.$PCS_SGMII_STATUS_CP_NAME
         add_connection $the_mac_instance\.$WIRE_CLKENA_CP_NAME $the_pcs_instance.$PCS_CLKENA_CP_NAME

         # Export the status led, serdes control and serial connection point
         # If it is MAC + PCS with FIFO variant, don't use index number.
         if {$enable_use_internal_fifo} {
            add_interface $PCS_STATUS_LED_CP_NAME conduit end
            set_interface_property $PCS_STATUS_LED_CP_NAME EXPORT_OF $the_pcs_instance\.$PCS_STATUS_LED_CP_NAME
            compose_rename_and_register_ports $the_pcs_instance $PCS_STATUS_LED_CP_NAME

            add_interface $PCS_SERDES_CONTROL_CP_NAME  conduit end
            set_interface_property $PCS_SERDES_CONTROL_CP_NAME EXPORT_OF $the_pcs_instance\.$PCS_SERDES_CONTROL_CP_NAME
            compose_rename_and_register_ports $the_pcs_instance $PCS_SERDES_CONTROL_CP_NAME

            add_interface $PMA_SERIAL_CP_NAME  conduit end
            set_interface_property $PMA_SERIAL_CP_NAME EXPORT_OF $the_pcs_instance\.$PMA_SERIAL_CP_NAME
            compose_rename_and_register_ports $the_pcs_instance $PMA_SERIAL_CP_NAME
         } else {
            add_interface $PCS_STATUS_LED_CP_NAME\_$index conduit end
            set_interface_property $PCS_STATUS_LED_CP_NAME\_$index  EXPORT_OF $the_pcs_instance\.$PCS_STATUS_LED_CP_NAME
            compose_rename_and_register_ports $the_pcs_instance $PCS_STATUS_LED_CP_NAME $index

            add_interface $PCS_SERDES_CONTROL_CP_NAME\_$index  conduit end
            set_interface_property $PCS_SERDES_CONTROL_CP_NAME\_$index  EXPORT_OF $the_pcs_instance\.$PCS_SERDES_CONTROL_CP_NAME
            compose_rename_and_register_ports $the_pcs_instance $PCS_SERDES_CONTROL_CP_NAME $index

            add_interface $PMA_SERIAL_CP_NAME\_$index  conduit end
            set_interface_property $PMA_SERIAL_CP_NAME\_$index  EXPORT_OF $the_pcs_instance\.$PMA_SERIAL_CP_NAME
            compose_rename_and_register_ports $the_pcs_instance $PMA_SERIAL_CP_NAME $index
         }

      } else {
         # Export PCS connection points
         add_interface $AVALON_CLOCK_CP_NAME clock end
         set_interface_property $AVALON_CLOCK_CP_NAME EXPORT_OF $the_pcs_instance\.$AVALON_CLOCK_CP_NAME
         compose_rename_and_register_ports $the_pcs_instance $AVALON_CLOCK_CP_NAME

         add_interface $AVALON_RESET_CP_NAME reset end
         set_interface_property $AVALON_RESET_CP_NAME EXPORT_OF $the_pcs_instance\.$AVALON_RESET_CP_NAME
         compose_rename_and_register_ports $the_pcs_instance $AVALON_RESET_CP_NAME

         add_interface $AVALON_CP_NAME avalon end
         set_interface_property $AVALON_CP_NAME EXPORT_OF $the_pcs_instance\.$AVALON_CP_NAME
         compose_rename_and_register_ports $the_pcs_instance $AVALON_CP_NAME

         add_interface $PCS_TX_CLK_NAME clock source
         set_interface_property $PCS_TX_CLK_NAME EXPORT_OF $the_pcs_instance\.$PCS_TX_CLK_NAME
         compose_rename_and_register_ports $the_pcs_instance $PCS_TX_CLK_NAME

         add_interface $PCS_RX_CLK_NAME clock source
         set_interface_property $PCS_RX_CLK_NAME EXPORT_OF $the_pcs_instance\.$PCS_RX_CLK_NAME
         compose_rename_and_register_ports $the_pcs_instance $PCS_RX_CLK_NAME

         add_interface $PCS_TX_RESET_NAME reset end
         set_interface_property $PCS_TX_RESET_NAME EXPORT_OF $the_pcs_instance\.$PCS_TX_RESET_NAME
         compose_rename_and_register_ports $the_pcs_instance $PCS_TX_RESET_NAME

         add_interface $PCS_RX_RESET_NAME reset end
         set_interface_property $PCS_RX_RESET_NAME EXPORT_OF $the_pcs_instance\.$PCS_RX_RESET_NAME
         compose_rename_and_register_ports $the_pcs_instance $PCS_RX_RESET_NAME

         add_interface $PCS_GMII_CP_NAME conduit end
         set_interface_property $PCS_GMII_CP_NAME EXPORT_OF $the_pcs_instance\.$PCS_GMII_CP_NAME
         compose_rename_and_register_ports $the_pcs_instance $PCS_GMII_CP_NAME

         if {$enable_sgmii} {
            add_interface $PCS_CLKENA_CP_NAME conduit end
            set_interface_property $PCS_CLKENA_CP_NAME EXPORT_OF $the_pcs_instance\.$PCS_CLKENA_CP_NAME
            compose_rename_and_register_ports $the_pcs_instance $PCS_CLKENA_CP_NAME

            add_interface $PCS_MII_CP_NAME conduit end
            set_interface_property $PCS_MII_CP_NAME EXPORT_OF $the_pcs_instance\.$PCS_MII_CP_NAME
            compose_rename_and_register_ports $the_pcs_instance $PCS_MII_CP_NAME
         
            add_interface $PCS_SGMII_STATUS_CP_NAME conduit end
            set_interface_property $PCS_SGMII_STATUS_CP_NAME EXPORT_OF $the_pcs_instance\.$PCS_SGMII_STATUS_CP_NAME
            compose_rename_and_register_ports $the_pcs_instance $PCS_SGMII_STATUS_CP_NAME
         }

         add_interface $PCS_STATUS_LED_CP_NAME conduit end
         set_interface_property $PCS_STATUS_LED_CP_NAME EXPORT_OF $the_pcs_instance\.$PCS_STATUS_LED_CP_NAME
         compose_rename_and_register_ports $the_pcs_instance $PCS_STATUS_LED_CP_NAME

         add_interface $PCS_SERDES_CONTROL_CP_NAME conduit end
         set_interface_property $PCS_SERDES_CONTROL_CP_NAME EXPORT_OF $the_pcs_instance\.$PCS_SERDES_CONTROL_CP_NAME
         compose_rename_and_register_ports $the_pcs_instance $PCS_SERDES_CONTROL_CP_NAME

         add_interface $PMA_SERIAL_CP_NAME conduit end
         set_interface_property $PMA_SERIAL_CP_NAME EXPORT_OF $the_pcs_instance\.$PMA_SERIAL_CP_NAME
         compose_rename_and_register_ports $the_pcs_instance $PMA_SERIAL_CP_NAME
      }
   }
}

# Compose the pcs_pma_nf_lvds
# and connect to MAC in MAC+PCS+PMA LVDS_IO variant
# for NightFury (Arria 10)
proc compose_pcs_pma_nf_lvds {} {
   
   global mac_instance
   global fifoless_mac_instance
   global pcs_instance
   global lvdsio_rx_instance
   global lvdsio_tx_instance
   global lvdsio_terminator_instance

   # Connection point names
   global AVALON_CP_NAME
   global AVALON_CLOCK_CP_NAME
   global AVALON_RESET_CP_NAME

   global PCS_MAC_TX_CLOCK_NAME
   global PCS_MAC_RX_CLOCK_NAME

   global PCS_TX_CLK_NAME
   global PCS_RX_CLK_NAME
   global PCS_REF_CLK_CP_NAME

   global PCS_TX_RESET_NAME
   global PCS_RX_RESET_NAME

   global PCS_GMII_CP_NAME
   global PCS_MII_CP_NAME

   global PCS_CLKENA_CP_NAME

   global PCS_SGMII_STATUS_CP_NAME
   global PCS_STATUS_LED_CP_NAME
   global PCS_SERDES_CONTROL_CP_NAME
   global PMA_GXB_CAL_BLK_CLK_CP_NAME
   global PMA_SERIAL_CP_NAME

   global MAC_GMII_CP_NAME
   global MAC_MII_CP_NAME
   global MAC_STATUS_CP_NAME
   global WIRE_CLKENA_CP_NAME

   set isUseMAC [get_parameter_value isUseMAC]
   set isUsePCS [get_parameter_value isUsePCS]
   set enable_use_internal_fifo [get_parameter_value enable_use_internal_fifo]
   set useMDIO [get_parameter_value useMDIO]

   set max_channels [get_parameter_value max_channels]

   set enable_sgmii [get_parameter_value enable_sgmii]
   set enable_clk_sharing [get_parameter_value enable_clk_sharing]

   # Decide if this is a multiple channel MAC+PCS core variation
   if {$isUseMAC} {
      if {$enable_use_internal_fifo} {
         set pcs_max_channels 1
      } else {
         set pcs_max_channels $max_channels\
      }
   } else {
      set pcs_max_channels 1
   }

   # Common ref_clk clock source
   add_instance ref_clk_module altera_clock_bridge

   add_interface $PCS_REF_CLK_CP_NAME clock end
   set_interface_property $PCS_REF_CLK_CP_NAME EXPORT_OF ref_clk_module.in_clk
   set_interface_property $PCS_REF_CLK_CP_NAME PORT_NAME_MAP "ref_clk in_clk"

   for {set index 0} { $index < $pcs_max_channels} {incr index} {
      set the_pcs_instance $pcs_instance\_$index
      set the_lvdsio_rx_instance $lvdsio_rx_instance\_$index
      set the_lvdsio_tx_instance $lvdsio_tx_instance\_$index
      set the_lvdsio_terminator_instance $lvdsio_terminator_instance\_$index

      add_instance $the_pcs_instance altera_eth_tse_pcs_pma_nf_lvds
      add_instance $the_lvdsio_rx_instance altera_lvds
      add_instance $the_lvdsio_tx_instance altera_lvds
      add_instance $the_lvdsio_terminator_instance altera_eth_tse_nf_lvds_terminator

      # Update the instance parameter
      update_pcs_pma_nf_lvds_instance_param $index
      set_instance_parameter $the_pcs_instance connect_to_mac $isUseMAC

      update_lvdsio_rx_instance_param $index
      update_lvdsio_tx_instance_param $index

      # Connect the ref_clk to PCS instance,
      # LVDS IO RX and LVDS IO TX
      add_connection ref_clk_module.out_clk $the_pcs_instance.$PCS_REF_CLK_CP_NAME
      add_connection ref_clk_module.out_clk $the_lvdsio_terminator_instance.lvds_inclock
      add_connection $the_lvdsio_terminator_instance.lvds_rx_inclock $the_lvdsio_rx_instance.inclock
      add_connection $the_lvdsio_terminator_instance.lvds_tx_inclock $the_lvdsio_tx_instance.inclock

      # Connect PCS, LVDS and LVDS IO terminator together
      add_connection $the_pcs_instance.tbi_tx_d_muxed $the_lvdsio_terminator_instance.tbi_tx_d_muxed
      add_connection $the_lvdsio_terminator_instance.rx_in $the_lvdsio_rx_instance.rx_in
      add_connection $the_lvdsio_terminator_instance.tx_in $the_lvdsio_tx_instance.tx_in
      add_connection $the_lvdsio_terminator_instance.tx_out $the_lvdsio_tx_instance.tx_out
        
      add_connection $the_pcs_instance.tbi_rx_d_lvds $the_lvdsio_terminator_instance.tbi_rx_d_lvds
      add_connection $the_lvdsio_terminator_instance.rx_out $the_lvdsio_rx_instance.rx_out
      
      add_connection $the_pcs_instance.tbi_rx_clk $the_lvdsio_terminator_instance.tbi_rx_clk
      add_connection $the_pcs_instance.rx_locked $the_lvdsio_terminator_instance.rx_locked
      add_connection $the_pcs_instance.rx_reset_ref_clk $the_lvdsio_terminator_instance.rx_reset_ref_clk
      add_connection $the_pcs_instance.rx_channel_data_align $the_lvdsio_terminator_instance.rx_channel_data_align
      add_connection $the_pcs_instance.rx_cda_reset $the_lvdsio_terminator_instance.rx_cda_reset

      add_connection $the_lvdsio_terminator_instance.pll_locked $the_lvdsio_rx_instance.pll_locked
      add_connection $the_lvdsio_terminator_instance.rx_cda_reset_lvds $the_lvdsio_rx_instance.rx_bitslip_reset
      add_connection $the_lvdsio_terminator_instance.rx_channel_data_align_lvds $the_lvdsio_rx_instance.rx_bitslip_ctrl
      add_connection $the_lvdsio_terminator_instance.rx_dpa_reset $the_lvdsio_rx_instance.rx_dpa_reset
      add_connection $the_lvdsio_terminator_instance.rx_divfwdclk $the_lvdsio_rx_instance.rx_divfwdclk
     
      #connecting the reset port
      add_connection $the_pcs_instance.reset_lvds $the_lvdsio_terminator_instance.reset_pcs_terminator
      add_connection $the_lvdsio_terminator_instance.reset_terminator_lvds_rx $the_lvdsio_rx_instance.pll_areset
      add_connection $the_lvdsio_terminator_instance.reset_terminator_lvds_tx $the_lvdsio_tx_instance.pll_areset
     
      if {$isUseMAC} {
         # MAC+PCS variant, let us connect the MAC to PCS
         
         # Connect clock and reset connection points MAC instance
         add_connection reg_clk_module.out_clk $the_pcs_instance.$AVALON_CLOCK_CP_NAME
         add_connection reg_rst_module.out_reset $the_pcs_instance.$AVALON_RESET_CP_NAME

         # Avalon slave connection point
         add_connection avalon_arbiter.av_pcs_master_$index $the_pcs_instance\.$AVALON_CP_NAME

         # Decide if we are connecting to fifoless mac or not
         if {$enable_use_internal_fifo} {
            set the_mac_instance $mac_instance
         } else {
            set the_mac_instance $fifoless_mac_instance\_$index
         }

         # Connect MAC to PCS clock
         add_connection $the_pcs_instance.$PCS_TX_CLK_NAME $the_mac_instance.$PCS_MAC_TX_CLOCK_NAME
         add_connection $the_pcs_instance.$PCS_RX_CLK_NAME $the_mac_instance.$PCS_MAC_RX_CLOCK_NAME
         
         # Connect reset to PCS tx clock and rx clock reset (QSYS will add the reset synchronizer for us)
         add_connection reg_rst_module.out_reset $the_pcs_instance.$PCS_TX_RESET_NAME
         add_connection reg_rst_module.out_reset $the_pcs_instance.$PCS_RX_RESET_NAME

         # Connect MAC to PCS ports
         add_connection $the_mac_instance\.$MAC_GMII_CP_NAME   $the_pcs_instance.$PCS_GMII_CP_NAME
         add_connection $the_mac_instance\.$MAC_MII_CP_NAME    $the_pcs_instance.$PCS_MII_CP_NAME
         add_connection $the_mac_instance\.$MAC_STATUS_CP_NAME $the_pcs_instance.$PCS_SGMII_STATUS_CP_NAME
         add_connection $the_mac_instance\.$WIRE_CLKENA_CP_NAME $the_pcs_instance.$PCS_CLKENA_CP_NAME

         # Export the status led, serdes control and serial connection point
         # If it is MAC + PCS with FIFO variant, don't use index number.
         if {$enable_use_internal_fifo} {
            add_interface $PCS_STATUS_LED_CP_NAME conduit end
            set_interface_property $PCS_STATUS_LED_CP_NAME EXPORT_OF $the_pcs_instance\.$PCS_STATUS_LED_CP_NAME
            compose_rename_and_register_ports $the_pcs_instance $PCS_STATUS_LED_CP_NAME

            add_interface $PCS_SERDES_CONTROL_CP_NAME  conduit end
            set_interface_property $PCS_SERDES_CONTROL_CP_NAME EXPORT_OF $the_pcs_instance\.$PCS_SERDES_CONTROL_CP_NAME
            compose_rename_and_register_ports $the_pcs_instance $PCS_SERDES_CONTROL_CP_NAME

            # Export the PMA serial connection point from LVDS IO terminator
            add_interface $PMA_SERIAL_CP_NAME  conduit end
            set_interface_property $PMA_SERIAL_CP_NAME EXPORT_OF $the_lvdsio_terminator_instance\.$PMA_SERIAL_CP_NAME
            compose_rename_and_register_ports $the_lvdsio_terminator_instance $PMA_SERIAL_CP_NAME

         } else {
            add_interface $PCS_STATUS_LED_CP_NAME\_$index conduit end
            set_interface_property $PCS_STATUS_LED_CP_NAME\_$index  EXPORT_OF $the_pcs_instance\.$PCS_STATUS_LED_CP_NAME
            compose_rename_and_register_ports $the_pcs_instance $PCS_STATUS_LED_CP_NAME $index

            add_interface $PCS_SERDES_CONTROL_CP_NAME\_$index  conduit end
            set_interface_property $PCS_SERDES_CONTROL_CP_NAME\_$index  EXPORT_OF $the_pcs_instance\.$PCS_SERDES_CONTROL_CP_NAME
            compose_rename_and_register_ports $the_pcs_instance $PCS_SERDES_CONTROL_CP_NAME $index

            # Export the PMA serial connection point from LVDS IO terminator
            add_interface $PMA_SERIAL_CP_NAME\_$index  conduit end
            set_interface_property $PMA_SERIAL_CP_NAME\_$index EXPORT_OF $the_lvdsio_terminator_instance\.$PMA_SERIAL_CP_NAME
            compose_rename_and_register_ports $the_lvdsio_terminator_instance $PMA_SERIAL_CP_NAME $index
         }

      } else {
         # Export PCS connection points
         add_interface $AVALON_CLOCK_CP_NAME clock end
         set_interface_property $AVALON_CLOCK_CP_NAME EXPORT_OF $the_pcs_instance\.$AVALON_CLOCK_CP_NAME
         compose_rename_and_register_ports $the_pcs_instance $AVALON_CLOCK_CP_NAME

         add_interface $AVALON_RESET_CP_NAME reset end
         set_interface_property $AVALON_RESET_CP_NAME EXPORT_OF $the_pcs_instance\.$AVALON_RESET_CP_NAME
         compose_rename_and_register_ports $the_pcs_instance $AVALON_RESET_CP_NAME

         add_interface $AVALON_CP_NAME avalon end
         set_interface_property $AVALON_CP_NAME EXPORT_OF $the_pcs_instance\.$AVALON_CP_NAME
         compose_rename_and_register_ports $the_pcs_instance $AVALON_CP_NAME

         add_interface $PCS_TX_CLK_NAME clock source
         set_interface_property $PCS_TX_CLK_NAME EXPORT_OF $the_pcs_instance\.$PCS_TX_CLK_NAME
         compose_rename_and_register_ports $the_pcs_instance $PCS_TX_CLK_NAME

         add_interface $PCS_RX_CLK_NAME clock source
         set_interface_property $PCS_RX_CLK_NAME EXPORT_OF $the_pcs_instance\.$PCS_RX_CLK_NAME
         compose_rename_and_register_ports $the_pcs_instance $PCS_RX_CLK_NAME

         add_interface $PCS_TX_RESET_NAME reset end
         set_interface_property $PCS_TX_RESET_NAME EXPORT_OF $the_pcs_instance\.$PCS_TX_RESET_NAME
         compose_rename_and_register_ports $the_pcs_instance $PCS_TX_RESET_NAME

         add_interface $PCS_RX_RESET_NAME reset end
         set_interface_property $PCS_RX_RESET_NAME EXPORT_OF $the_pcs_instance\.$PCS_RX_RESET_NAME
         compose_rename_and_register_ports $the_pcs_instance $PCS_RX_RESET_NAME

         add_interface $PCS_GMII_CP_NAME conduit end
         set_interface_property $PCS_GMII_CP_NAME EXPORT_OF $the_pcs_instance\.$PCS_GMII_CP_NAME
         compose_rename_and_register_ports $the_pcs_instance $PCS_GMII_CP_NAME

         if {$enable_sgmii} {
            add_interface $PCS_CLKENA_CP_NAME conduit end
            set_interface_property $PCS_CLKENA_CP_NAME EXPORT_OF $the_pcs_instance\.$PCS_CLKENA_CP_NAME
            compose_rename_and_register_ports $the_pcs_instance $PCS_CLKENA_CP_NAME

            add_interface $PCS_MII_CP_NAME conduit end
            set_interface_property $PCS_MII_CP_NAME EXPORT_OF $the_pcs_instance\.$PCS_MII_CP_NAME
            compose_rename_and_register_ports $the_pcs_instance $PCS_MII_CP_NAME
         
            add_interface $PCS_SGMII_STATUS_CP_NAME conduit end
            set_interface_property $PCS_SGMII_STATUS_CP_NAME EXPORT_OF $the_pcs_instance\.$PCS_SGMII_STATUS_CP_NAME
            compose_rename_and_register_ports $the_pcs_instance $PCS_SGMII_STATUS_CP_NAME
         }

         add_interface $PCS_STATUS_LED_CP_NAME conduit end
         set_interface_property $PCS_STATUS_LED_CP_NAME EXPORT_OF $the_pcs_instance\.$PCS_STATUS_LED_CP_NAME
         compose_rename_and_register_ports $the_pcs_instance $PCS_STATUS_LED_CP_NAME

         add_interface $PCS_SERDES_CONTROL_CP_NAME conduit end
         set_interface_property $PCS_SERDES_CONTROL_CP_NAME EXPORT_OF $the_pcs_instance\.$PCS_SERDES_CONTROL_CP_NAME
         compose_rename_and_register_ports $the_pcs_instance $PCS_SERDES_CONTROL_CP_NAME

         # Export the PMA serial connection point from LVDS IO terminator
         add_interface $PMA_SERIAL_CP_NAME  conduit end
         set_interface_property $PMA_SERIAL_CP_NAME EXPORT_OF $the_lvdsio_terminator_instance\.$PMA_SERIAL_CP_NAME
         compose_rename_and_register_ports $the_lvdsio_terminator_instance $PMA_SERIAL_CP_NAME

      }
   }
}

# Compose the pcs_pma_gxb
# and connect to MAC in MAC+PCS+PMA GXB variant
proc compose_pcs_pma_gxb {} {
   
   global mac_instance
   global fifoless_mac_instance
   global pcs_instance
   global altgxb_instance
   global pcs_altgxb_port_connection

   # Connection point names
   global AVALON_CP_NAME
   global AVALON_CLOCK_CP_NAME
   global AVALON_RESET_CP_NAME

   global PCS_MAC_TX_CLOCK_NAME
   global PCS_MAC_RX_CLOCK_NAME

   global PCS_TX_CLK_NAME
   global PCS_RX_CLK_NAME
   global PCS_REF_CLK_CP_NAME

   global PCS_TX_RESET_NAME
   global PCS_RX_RESET_NAME

   global PCS_GMII_CP_NAME
   global PCS_MII_CP_NAME

   global PCS_CLKENA_CP_NAME

   global PCS_SGMII_STATUS_CP_NAME
   global PCS_STATUS_LED_CP_NAME
   global PCS_SERDES_CONTROL_CP_NAME
   global PMA_SERIAL_CP_NAME
   global PMA_GXB_CAL_BLK_CLK_CP_NAME

   global MAC_GMII_CP_NAME
   global MAC_MII_CP_NAME
   global MAC_STATUS_CP_NAME
   global WIRE_CLKENA_CP_NAME

   set isUseMAC [get_parameter_value isUseMAC]
   set isUsePCS [get_parameter_value isUsePCS]
   set enable_use_internal_fifo [get_parameter_value enable_use_internal_fifo]

   set max_channels [get_parameter_value max_channels]

   set enable_sgmii [get_parameter_value enable_sgmii]
   set enable_clk_sharing [get_parameter_value enable_clk_sharing]

   set starting_channel_number [get_parameter_value starting_channel_number]

   # Decide if this is a multiple channel MAC+PCS core variation
   if {$isUseMAC} {
      if {$enable_use_internal_fifo} {
         set pcs_max_channels 1
      } else {
         set pcs_max_channels $max_channels\
      }
   } else {
      set pcs_max_channels 1
   }

   # Common ref_clk clock source
   add_instance ref_clk_module altera_clock_bridge

   add_interface $PCS_REF_CLK_CP_NAME clock end
   set_interface_property $PCS_REF_CLK_CP_NAME EXPORT_OF ref_clk_module.in_clk
   set_interface_property $PCS_REF_CLK_CP_NAME PORT_NAME_MAP "ref_clk in_clk"

   # Common calibration block clock
   add_instance cal_blk_clk_module altera_clock_bridge
   
   add_interface $PMA_GXB_CAL_BLK_CLK_CP_NAME clock end
   set_interface_property $PMA_GXB_CAL_BLK_CLK_CP_NAME EXPORT_OF cal_blk_clk_module.in_clk
   set_interface_property $PMA_GXB_CAL_BLK_CLK_CP_NAME PORT_NAME_MAP "gxb_cal_blk_clk in_clk"


   for {set index 0} { $index < $pcs_max_channels} {incr index} {
      set the_pcs_instance $pcs_instance\_$index
      set the_altgxb_instance $altgxb_instance\_$index

      add_instance $the_pcs_instance altera_eth_tse_pcs_pma_gxb
      add_instance $the_altgxb_instance altera_eth_tse_altgxb

      # Update the instance parameter
      update_pcs_pma_gxb_instance_param $index
      set_instance_parameter $the_pcs_instance connect_to_mac $isUseMAC

      update_altgxb_instance_param $index
      set_instance_parameter $the_altgxb_instance STARTING_CHANNEL_NUMBER [expr $starting_channel_number + $index * 4]


      # Connect the ref_clk to PCS instance
      add_connection ref_clk_module.out_clk $the_pcs_instance.$PCS_REF_CLK_CP_NAME

      # Connect the ref_clk to ALTGXB intance
      add_connection ref_clk_module.out_clk $the_altgxb_instance.$PCS_REF_CLK_CP_NAME

      # Connect the calibration block clock to ALTGXB instance
      add_connection cal_blk_clk_module.out_clk $the_altgxb_instance.$PMA_GXB_CAL_BLK_CLK_CP_NAME
         
      # Connect PCS to ALTGXB
      foreach {pcs_port} [array names pcs_altgxb_port_connection] {
         set altgxb_port $pcs_altgxb_port_connection($pcs_port)

         add_connection $the_pcs_instance\.$pcs_port $the_altgxb_instance\.$altgxb_port
      }

      if {$isUseMAC} {
         # MAC+PCS variant, let us connect the MAC to PCS
         
         # Connect clock and reset connection points MAC instance
         add_connection reg_clk_module.out_clk $the_pcs_instance.$AVALON_CLOCK_CP_NAME
         add_connection reg_rst_module.out_reset $the_pcs_instance.$AVALON_RESET_CP_NAME

         # Avalon slave connection point
         add_connection avalon_arbiter.av_pcs_master_$index $the_pcs_instance\.$AVALON_CP_NAME

         # Decide if we are connecting to fifoless mac or not
         if {$enable_use_internal_fifo} {
            set the_mac_instance $mac_instance
         } else {
            set the_mac_instance $fifoless_mac_instance\_$index
         }

         # Connect MAC to PCS clock
         add_connection $the_pcs_instance.$PCS_TX_CLK_NAME $the_mac_instance.$PCS_MAC_TX_CLOCK_NAME
         add_connection $the_pcs_instance.$PCS_RX_CLK_NAME $the_mac_instance.$PCS_MAC_RX_CLOCK_NAME
         
         # Connect reset to PCS tx clock and rx clock reset (QSYS will add the reset synchronizer for us)
         add_connection reg_rst_module.out_reset $the_pcs_instance.$PCS_TX_RESET_NAME
         add_connection reg_rst_module.out_reset $the_pcs_instance.$PCS_RX_RESET_NAME

         # Connect MAC to PCS ports
         add_connection $the_mac_instance\.$MAC_GMII_CP_NAME   $the_pcs_instance.$PCS_GMII_CP_NAME
         add_connection $the_mac_instance\.$MAC_MII_CP_NAME    $the_pcs_instance.$PCS_MII_CP_NAME
         add_connection $the_mac_instance\.$MAC_STATUS_CP_NAME $the_pcs_instance.$PCS_SGMII_STATUS_CP_NAME
         add_connection $the_mac_instance\.$WIRE_CLKENA_CP_NAME $the_pcs_instance.$PCS_CLKENA_CP_NAME

         # Export the status led, serdes control and serial connection point
         # If it is MAC + PCS with FIFO variant, don't use index number.
         if {$enable_use_internal_fifo} {
            add_interface $PCS_STATUS_LED_CP_NAME conduit end
            set_interface_property $PCS_STATUS_LED_CP_NAME EXPORT_OF $the_pcs_instance\.$PCS_STATUS_LED_CP_NAME
            compose_rename_and_register_ports $the_pcs_instance $PCS_STATUS_LED_CP_NAME

            add_interface $PCS_SERDES_CONTROL_CP_NAME  conduit end
            set_interface_property $PCS_SERDES_CONTROL_CP_NAME EXPORT_OF $the_altgxb_instance\.$PCS_SERDES_CONTROL_CP_NAME
            compose_rename_and_register_ports $the_altgxb_instance $PCS_SERDES_CONTROL_CP_NAME

            add_interface $PMA_SERIAL_CP_NAME  conduit end
            set_interface_property $PMA_SERIAL_CP_NAME EXPORT_OF $the_altgxb_instance\.$PMA_SERIAL_CP_NAME
            compose_rename_and_register_ports $the_altgxb_instance $PMA_SERIAL_CP_NAME
         } else {
            add_interface $PCS_STATUS_LED_CP_NAME\_$index conduit end
            set_interface_property $PCS_STATUS_LED_CP_NAME\_$index  EXPORT_OF $the_pcs_instance\.$PCS_STATUS_LED_CP_NAME
            compose_rename_and_register_ports $the_pcs_instance $PCS_STATUS_LED_CP_NAME $index

            add_interface $PCS_SERDES_CONTROL_CP_NAME\_$index  conduit end
            set_interface_property $PCS_SERDES_CONTROL_CP_NAME\_$index  EXPORT_OF $the_altgxb_instance\.$PCS_SERDES_CONTROL_CP_NAME
            compose_rename_and_register_ports $the_altgxb_instance $PCS_SERDES_CONTROL_CP_NAME $index

            add_interface $PMA_SERIAL_CP_NAME\_$index  conduit end
            set_interface_property $PMA_SERIAL_CP_NAME\_$index  EXPORT_OF $the_altgxb_instance\.$PMA_SERIAL_CP_NAME
            compose_rename_and_register_ports $the_altgxb_instance $PMA_SERIAL_CP_NAME $index
         }

      } else {
         # Export PCS connection points
         add_interface $AVALON_CLOCK_CP_NAME clock end
         set_interface_property $AVALON_CLOCK_CP_NAME EXPORT_OF $the_pcs_instance\.$AVALON_CLOCK_CP_NAME
         compose_rename_and_register_ports $the_pcs_instance $AVALON_CLOCK_CP_NAME

         add_interface $AVALON_RESET_CP_NAME reset end
         set_interface_property $AVALON_RESET_CP_NAME EXPORT_OF $the_pcs_instance\.$AVALON_RESET_CP_NAME
         compose_rename_and_register_ports $the_pcs_instance $AVALON_RESET_CP_NAME

         add_interface $AVALON_CP_NAME avalon end
         set_interface_property $AVALON_CP_NAME EXPORT_OF $the_pcs_instance\.$AVALON_CP_NAME
         compose_rename_and_register_ports $the_pcs_instance $AVALON_CP_NAME

         add_interface $PCS_TX_CLK_NAME clock source
         set_interface_property $PCS_TX_CLK_NAME EXPORT_OF $the_pcs_instance\.$PCS_TX_CLK_NAME
         compose_rename_and_register_ports $the_pcs_instance $PCS_TX_CLK_NAME

         add_interface $PCS_RX_CLK_NAME clock source
         set_interface_property $PCS_RX_CLK_NAME EXPORT_OF $the_pcs_instance\.$PCS_RX_CLK_NAME
         compose_rename_and_register_ports $the_pcs_instance $PCS_RX_CLK_NAME

         add_interface $PCS_TX_RESET_NAME reset end
         set_interface_property $PCS_TX_RESET_NAME EXPORT_OF $the_pcs_instance\.$PCS_TX_RESET_NAME
         compose_rename_and_register_ports $the_pcs_instance $PCS_TX_RESET_NAME

         add_interface $PCS_RX_RESET_NAME reset end
         set_interface_property $PCS_RX_RESET_NAME EXPORT_OF $the_pcs_instance\.$PCS_RX_RESET_NAME
         compose_rename_and_register_ports $the_pcs_instance $PCS_RX_RESET_NAME

         add_interface $PCS_GMII_CP_NAME conduit end
         set_interface_property $PCS_GMII_CP_NAME EXPORT_OF $the_pcs_instance\.$PCS_GMII_CP_NAME
         compose_rename_and_register_ports $the_pcs_instance $PCS_GMII_CP_NAME

         if {$enable_sgmii} {
            add_interface $PCS_CLKENA_CP_NAME conduit end
            set_interface_property $PCS_CLKENA_CP_NAME EXPORT_OF $the_pcs_instance\.$PCS_CLKENA_CP_NAME
            compose_rename_and_register_ports $the_pcs_instance $PCS_CLKENA_CP_NAME

            add_interface $PCS_MII_CP_NAME conduit end
            set_interface_property $PCS_MII_CP_NAME EXPORT_OF $the_pcs_instance\.$PCS_MII_CP_NAME
            compose_rename_and_register_ports $the_pcs_instance $PCS_MII_CP_NAME
         
            add_interface $PCS_SGMII_STATUS_CP_NAME conduit end
            set_interface_property $PCS_SGMII_STATUS_CP_NAME EXPORT_OF $the_pcs_instance\.$PCS_SGMII_STATUS_CP_NAME
            compose_rename_and_register_ports $the_pcs_instance $PCS_SGMII_STATUS_CP_NAME
         }

         add_interface $PCS_STATUS_LED_CP_NAME conduit end
         set_interface_property $PCS_STATUS_LED_CP_NAME EXPORT_OF $the_pcs_instance\.$PCS_STATUS_LED_CP_NAME
         compose_rename_and_register_ports $the_pcs_instance $PCS_STATUS_LED_CP_NAME

         add_interface $PCS_SERDES_CONTROL_CP_NAME conduit end
         set_interface_property $PCS_SERDES_CONTROL_CP_NAME EXPORT_OF $the_altgxb_instance\.$PCS_SERDES_CONTROL_CP_NAME
         compose_rename_and_register_ports $the_altgxb_instance $PCS_SERDES_CONTROL_CP_NAME

         add_interface $PMA_SERIAL_CP_NAME conduit end
         set_interface_property $PMA_SERIAL_CP_NAME EXPORT_OF $the_altgxb_instance\.$PMA_SERIAL_CP_NAME
         compose_rename_and_register_ports $the_altgxb_instance $PMA_SERIAL_CP_NAME
      }
   }
}

# Compose the pcs_pma_gxb_phyip
# and connect to MAC in MAC+PCS+PMA GXB phyip variant
proc compose_pcs_pma_gxb_phyip {} {

   global mac_instance
   global fifoless_mac_instance
   global pcs_instance
   global phyip_instance
   global phyip_terminator_instance

   # Connection point names
   global AVALON_CP_NAME
   global AVALON_CLOCK_CP_NAME
   global AVALON_RESET_CP_NAME

   global WIRE_MISC_CP_NAME

   global PCS_MAC_TX_CLOCK_NAME
   global PCS_MAC_RX_CLOCK_NAME

   global PCS_TX_CLK_NAME
   global PCS_RX_CLK_NAME
   global PCS_REF_CLK_CP_NAME
   global PCS_CDR_REF_CLK_CP_NAME

   global PCS_TX_RESET_NAME
   global PCS_RX_RESET_NAME

   global PCS_GMII_CP_NAME
   global PCS_MII_CP_NAME

   global PCS_CLKENA_CP_NAME

   global PCS_SGMII_STATUS_CP_NAME
   global PCS_STATUS_LED_CP_NAME
   global PCS_SERDES_CONTROL_CP_NAME
   global PMA_SERIAL_CP_NAME
   global PMA_GXB_CAL_BLK_CLK_CP_NAME

   global MAC_GMII_CP_NAME
   global MAC_MII_CP_NAME
   global MAC_STATUS_CP_NAME
   global WIRE_CLKENA_CP_NAME

   global pcs_pma_phyip_port_connection
   global phyip_terminator_port_connection
   
   global RX_LATENCY_ADJ
   global TX_LATENCY_ADJ
   global RX_PATH_DELAY
   global TX_PATH_DELAY
   global PCS_PHASE_MEASURE_CLK

   set isUseMAC [get_parameter_value isUseMAC]
   set isUsePCS [get_parameter_value isUsePCS]
   set enable_use_internal_fifo [get_parameter_value enable_use_internal_fifo]

   set max_channels [get_parameter_value max_channels]

   set enable_sgmii [get_parameter_value enable_sgmii]
   set enable_clk_sharing [get_parameter_value enable_clk_sharing]
   set phyip_en_synce_support [get_parameter_value phyip_en_synce_support]
   
   # check 1588 criteria
   set core_variation [get_parameter_value core_variation]
   set deviceFamily [get_parameter_value deviceFamily]
   set transceiver_type [get_parameter_value transceiver_type]
   if { $enable_sgmii &&
      [expr {"$core_variation" == "MAC_PCS"}] &&
      [expr {"$transceiver_type" == "GXB"}] &&
        [expr {"$enable_use_internal_fifo" == "false"}] &&
        [expr {"$deviceFamily" == "ARRIA10"} || {"$deviceFamily" == "STRATIXV"} || {"$deviceFamily" == "ARRIAV"}  || {"$deviceFamily" == "ARRIAVGZ"}  || {"$deviceFamily" == "CYCLONEV"}]} {
      set enable_timestamping [get_parameter_value enable_timestamping]
      set enable_ptp_1step [get_parameter_value enable_ptp_1step]
      set tstamp_fp_width [get_parameter_value tstamp_fp_width]  
   } else {
      set enable_timestamping 0
      set enable_ptp_1step 0
      set tstamp_fp_width 4
   }

   # Decide if this is a multiple channel MAC+PCS core variation
   # If we don't are in PCS_ONLY configuration,
   # create the common register interface clock source and reset source
   if {$isUseMAC} {
      if {$enable_use_internal_fifo} {
         set pcs_max_channels 1
      } else {
         set pcs_max_channels $max_channels\
      }
   } else {
      set pcs_max_channels 1

      # Common register interface clock source and reset source
      add_instance reg_clk_module altera_clock_bridge
      add_instance reg_rst_module altera_reset_bridge

      add_interface $AVALON_CLOCK_CP_NAME clock end
      set_interface_property $AVALON_CLOCK_CP_NAME EXPORT_OF reg_clk_module.in_clk
      set_interface_property $AVALON_CLOCK_CP_NAME PORT_NAME_MAP "clk in_clk"

      add_interface $AVALON_RESET_CP_NAME reset end
      set_interface_property $AVALON_RESET_CP_NAME EXPORT_OF reg_rst_module.in_reset
      set_interface_property $AVALON_RESET_CP_NAME PORT_NAME_MAP "reset in_reset"

      add_connection reg_clk_module.out_clk reg_rst_module.clk

   }

   # Common ref_clk clock source
   add_instance ref_clk_module altera_clock_bridge

   add_interface $PCS_REF_CLK_CP_NAME clock end
   set_interface_property $PCS_REF_CLK_CP_NAME EXPORT_OF ref_clk_module.in_clk
   set_interface_property $PCS_REF_CLK_CP_NAME PORT_NAME_MAP "ref_clk in_clk"

   # Timestamp pcs phase measure clock source
   if {$enable_timestamping} {
      add_instance pcs_phase_measure_clk_module altera_clock_bridge

      add_interface $PCS_PHASE_MEASURE_CLK clock end
      set_interface_property $PCS_PHASE_MEASURE_CLK PORT_NAME_MAP "pcs_phase_measure_clk in_clk"
      set_interface_property $PCS_PHASE_MEASURE_CLK EXPORT_OF pcs_phase_measure_clk_module.in_clk
   }

   for {set index 0} { $index < $pcs_max_channels} {incr index} {
      set the_pcs_instance $pcs_instance\_$index
      set the_phyip_instance $phyip_instance\_$index
      set the_phyip_terminator_instance $phyip_terminator_instance\_$index
      set phyip_rxclkout_splitter_instance phyip_rxclkout_splitter_instance_$index

      add_instance $the_pcs_instance altera_eth_tse_pcs_pma_phyip

      add_instance $the_phyip_instance altera_xcvr_custom_phy
      set_instance_property $the_phyip_instance SUPPRESS_ALL_INFO_MESSAGES true
      set_instance_property $the_phyip_instance SUPPRESS_ALL_WARNINGS true

      add_instance $the_phyip_terminator_instance altera_eth_tse_phyip_terminator
      set_instance_parameter $the_phyip_terminator_instance phyip_en_synce_support $phyip_en_synce_support

      # Connect sd_loopback control signal from PCS to PHYIP terminator
      add_connection $the_pcs_instance\.sd_loopback $the_phyip_terminator_instance\.sd_loopback
     
      # Add splitter instance for rx_clkout because need to fan out to phyip terminator and pcs
      add_instance $phyip_rxclkout_splitter_instance altera_eth_tse_conduit_fanout
      set_instance_parameter $phyip_rxclkout_splitter_instance PORT_LIST "export,1"
      if {$enable_timestamping} {
         set_instance_parameter $phyip_rxclkout_splitter_instance NUM_FANOUT 2
      } else {
         set_instance_parameter $phyip_rxclkout_splitter_instance NUM_FANOUT 1
      }      
     
      # Update the instance parameter
      update_pcs_pma_phyip_instance_param $index
      set_instance_parameter $the_pcs_instance connect_to_mac $isUseMAC

      update_phyip_instance_param $index
     
      set_instance_parameter $the_phyip_terminator_instance ENABLE_TIMESTAMPING $enable_timestamping
      set_instance_parameter $the_pcs_instance ENABLE_TIMESTAMPING $enable_timestamping

      # Clock and reset connection to PHYIP
      add_connection reg_clk_module.out_clk $the_phyip_instance\.phy_mgmt_clk
      add_connection reg_rst_module.out_reset $the_phyip_instance\.phy_mgmt_clk_reset
      add_connection ref_clk_module.out_clk $the_phyip_instance\.pll_ref_clk

      if {$phyip_en_synce_support} {
         add_interface $PCS_CDR_REF_CLK_CP_NAME\_$index clock end
         set_interface_property $PCS_CDR_REF_CLK_CP_NAME\_$index EXPORT_OF $the_phyip_terminator_instance.$PCS_CDR_REF_CLK_CP_NAME
         set_interface_property $PCS_CDR_REF_CLK_CP_NAME\_$index PORT_NAME_MAP "cdr_ref_clk_$index cdr_ref_clk_in"
         add_connection $the_phyip_terminator_instance.cdr_ref_clk_out $the_phyip_instance.cdr_ref_clk
      }

      # Clock and reset connection to PHYIP terminator
      add_connection reg_clk_module.out_clk $the_phyip_terminator_instance\.clk
      add_connection reg_rst_module.out_reset $the_phyip_terminator_instance\.reset

      # Connect clock and reset connection points pcs instance
      add_connection reg_clk_module.out_clk $the_pcs_instance.$AVALON_CLOCK_CP_NAME
      add_connection reg_rst_module.out_reset $the_pcs_instance.$AVALON_RESET_CP_NAME
     
      # Connect rx_clkout from phyip to the splitter
      add_connection $the_phyip_instance.rx_clkout $phyip_rxclkout_splitter_instance\.sig_input
  
      # Connect pcs_measure_phase_clk to pcs instance
      if {$enable_timestamping} {
         add_connection pcs_phase_measure_clk_module.out_clk $the_pcs_instance.$PCS_PHASE_MEASURE_CLK
      }  

      # Connect PHYIP and PCS together
      foreach {pcs_port} [array names pcs_pma_phyip_port_connection] {
         set phyip_port $pcs_pma_phyip_port_connection($pcs_port)

         add_connection $the_pcs_instance\.$pcs_port $the_phyip_instance\.$phyip_port
      }
      if {$enable_sgmii} { 
      } else {
         add_connection $the_pcs_instance\.rx_rmfifodatainserted $the_phyip_instance\.rx_rmfifodatainserted
         add_connection $the_pcs_instance\.rx_rmfifodatadeleted $the_phyip_instance\.rx_rmfifodatadeleted
      }
      add_connection $phyip_rxclkout_splitter_instance\.sig_fanout0 $the_pcs_instance\.rx_pcs_clk

      # Connect PHYIP and its terminator together
      foreach {phyip_port} [array names phyip_terminator_port_connection] {
         set terminator_port $phyip_terminator_port_connection($phyip_port)

         add_connection $the_phyip_instance\.$phyip_port $the_phyip_terminator_instance\.$terminator_port
      }
      # In timestamp mode, rx recovered clock is from rxclkout. Else, it is from phyip recovered clock.
      if {$enable_timestamping} {
         add_connection $phyip_rxclkout_splitter_instance\.sig_fanout1 $the_phyip_terminator_instance\.rx_recovered_clk
         add_connection $the_phyip_instance\.rx_recovered_clk $the_phyip_terminator_instance\.terminate_rx_recovered_clk
      } else {
         add_connection $the_phyip_instance\.rx_recovered_clk $the_phyip_terminator_instance\.rx_recovered_clk
      }
      add_connection $the_phyip_terminator_instance\.av_dummy_master $the_phyip_instance.phy_mgmt

      if {$isUseMAC} {
         # MAC+PCS variant, let us connect the MAC to PCS
         
         # Connect the ref_clk
         add_connection ref_clk_module.out_clk $the_pcs_instance.$PCS_REF_CLK_CP_NAME

         # Avalon slave connection point
         add_connection avalon_arbiter.av_pcs_master_$index $the_pcs_instance\.$AVALON_CP_NAME

         # Decide if we are connecting to fifoless mac or not
         if {$enable_use_internal_fifo} {
            set the_mac_instance $mac_instance
         } else {
            set the_mac_instance $fifoless_mac_instance\_$index
         }

         # Connect MAC to PCS clock
         add_connection $the_pcs_instance.$PCS_TX_CLK_NAME $the_mac_instance.$PCS_MAC_TX_CLOCK_NAME
         add_connection $the_pcs_instance.$PCS_RX_CLK_NAME $the_mac_instance.$PCS_MAC_RX_CLOCK_NAME
         
         # Connect reset to PCS tx clock and rx clock reset (QSYS will add the reset synchronizer for us)
         add_connection reg_rst_module.out_reset $the_pcs_instance.$PCS_TX_RESET_NAME
         add_connection reg_rst_module.out_reset $the_pcs_instance.$PCS_RX_RESET_NAME

         # Connect MAC to PCS ports
         add_connection $the_mac_instance\.$MAC_GMII_CP_NAME   $the_pcs_instance.$PCS_GMII_CP_NAME
         add_connection $the_mac_instance\.$MAC_MII_CP_NAME    $the_pcs_instance.$PCS_MII_CP_NAME
         add_connection $the_mac_instance\.$MAC_STATUS_CP_NAME $the_pcs_instance.$PCS_SGMII_STATUS_CP_NAME
         add_connection $the_mac_instance\.$WIRE_CLKENA_CP_NAME $the_pcs_instance.$PCS_CLKENA_CP_NAME
          
         # Connect PCS TX/RX latency adj port to MAC
         if {$enable_timestamping} {
            add_connection $the_pcs_instance.$RX_LATENCY_ADJ $the_mac_instance.$RX_PATH_DELAY
            add_connection $the_pcs_instance.$TX_LATENCY_ADJ $the_mac_instance.$TX_PATH_DELAY
         }

         # Export the status led, serdes control and serial interface
         # If it is MAC + PCS with FIFO variant, don't use index number.
         if {$enable_use_internal_fifo} {
            add_interface $PCS_STATUS_LED_CP_NAME conduit end
            set_interface_property $PCS_STATUS_LED_CP_NAME EXPORT_OF $the_pcs_instance\.$PCS_STATUS_LED_CP_NAME
            compose_rename_and_register_ports $the_pcs_instance $PCS_STATUS_LED_CP_NAME

            add_interface $PCS_SERDES_CONTROL_CP_NAME conduit end
            set_interface_property $PCS_SERDES_CONTROL_CP_NAME EXPORT_OF $the_phyip_terminator_instance\.$PCS_SERDES_CONTROL_CP_NAME
            compose_rename_and_register_ports $the_phyip_terminator_instance $PCS_SERDES_CONTROL_CP_NAME

            add_interface $PMA_SERIAL_CP_NAME conduit end
            set_interface_property $PMA_SERIAL_CP_NAME EXPORT_OF $the_phyip_terminator_instance\.$PMA_SERIAL_CP_NAME
            compose_rename_and_register_ports $the_phyip_terminator_instance $PMA_SERIAL_CP_NAME
         } else {
            add_interface $PCS_STATUS_LED_CP_NAME\_$index conduit end
            set_interface_property $PCS_STATUS_LED_CP_NAME\_$index  EXPORT_OF $the_pcs_instance\.$PCS_STATUS_LED_CP_NAME
            compose_rename_and_register_ports $the_pcs_instance $PCS_STATUS_LED_CP_NAME $index

            add_interface $PCS_SERDES_CONTROL_CP_NAME\_$index conduit end
            set_interface_property $PCS_SERDES_CONTROL_CP_NAME\_$index EXPORT_OF $the_phyip_terminator_instance\.$PCS_SERDES_CONTROL_CP_NAME
            compose_rename_and_register_ports $the_phyip_terminator_instance $PCS_SERDES_CONTROL_CP_NAME $index

            add_interface $PMA_SERIAL_CP_NAME\_$index conduit end
            set_interface_property $PMA_SERIAL_CP_NAME\_$index EXPORT_OF $the_phyip_terminator_instance\.$PMA_SERIAL_CP_NAME
            compose_rename_and_register_ports $the_phyip_terminator_instance $PMA_SERIAL_CP_NAME $index

         }

      } else {
         # Export PCS connection points
         add_interface $AVALON_CP_NAME avalon slave
         set_interface_property $AVALON_CP_NAME EXPORT_OF $the_pcs_instance\.$AVALON_CP_NAME
         compose_rename_and_register_ports $the_pcs_instance $AVALON_CP_NAME

         # Connect the ref_clk
         add_connection ref_clk_module.out_clk $the_pcs_instance.$PCS_REF_CLK_CP_NAME

         add_interface $PCS_TX_CLK_NAME clock source
         set_interface_property $PCS_TX_CLK_NAME EXPORT_OF $the_pcs_instance\.$PCS_TX_CLK_NAME
         compose_rename_and_register_ports $the_pcs_instance $PCS_TX_CLK_NAME

         add_interface $PCS_RX_CLK_NAME clock source
         set_interface_property $PCS_RX_CLK_NAME EXPORT_OF $the_pcs_instance\.$PCS_RX_CLK_NAME
         compose_rename_and_register_ports $the_pcs_instance $PCS_RX_CLK_NAME

         add_interface $PCS_TX_RESET_NAME reset end
         set_interface_property $PCS_TX_RESET_NAME EXPORT_OF $the_pcs_instance\.$PCS_TX_RESET_NAME
         compose_rename_and_register_ports $the_pcs_instance $PCS_TX_RESET_NAME

         add_interface $PCS_RX_RESET_NAME reset end
         set_interface_property $PCS_RX_RESET_NAME EXPORT_OF $the_pcs_instance\.$PCS_RX_RESET_NAME
         compose_rename_and_register_ports $the_pcs_instance $PCS_RX_RESET_NAME

         add_interface $PCS_GMII_CP_NAME conduit end
         set_interface_property $PCS_GMII_CP_NAME EXPORT_OF $the_pcs_instance\.$PCS_GMII_CP_NAME
         compose_rename_and_register_ports $the_pcs_instance $PCS_GMII_CP_NAME

         if {$enable_sgmii} {
            add_interface $PCS_CLKENA_CP_NAME conduit end
            set_interface_property $PCS_CLKENA_CP_NAME EXPORT_OF $the_pcs_instance\.$PCS_CLKENA_CP_NAME
            compose_rename_and_register_ports $the_pcs_instance $PCS_CLKENA_CP_NAME

            add_interface $PCS_MII_CP_NAME conduit end
            set_interface_property $PCS_MII_CP_NAME EXPORT_OF $the_pcs_instance\.$PCS_MII_CP_NAME
            compose_rename_and_register_ports $the_pcs_instance $PCS_MII_CP_NAME
         
            add_interface $PCS_SGMII_STATUS_CP_NAME conduit end
            set_interface_property $PCS_SGMII_STATUS_CP_NAME EXPORT_OF $the_pcs_instance\.$PCS_SGMII_STATUS_CP_NAME
            compose_rename_and_register_ports $the_pcs_instance $PCS_SGMII_STATUS_CP_NAME
         }

         add_interface $PCS_STATUS_LED_CP_NAME conduit end
         set_interface_property $PCS_STATUS_LED_CP_NAME EXPORT_OF $the_pcs_instance\.$PCS_STATUS_LED_CP_NAME
         compose_rename_and_register_ports $the_pcs_instance $PCS_STATUS_LED_CP_NAME

         add_interface $PCS_SERDES_CONTROL_CP_NAME conduit end
         set_interface_property $PCS_SERDES_CONTROL_CP_NAME EXPORT_OF $the_phyip_terminator_instance\.$PCS_SERDES_CONTROL_CP_NAME
         compose_rename_and_register_ports $the_phyip_terminator_instance $PCS_SERDES_CONTROL_CP_NAME

         add_interface $PMA_SERIAL_CP_NAME conduit end
         set_interface_property $PMA_SERIAL_CP_NAME EXPORT_OF $the_phyip_terminator_instance\.$PMA_SERIAL_CP_NAME
         compose_rename_and_register_ports $the_phyip_terminator_instance $PMA_SERIAL_CP_NAME

      }
   }
}

# Compose the pcs_pma_gxb_phyip
# and connect to MAC in MAC+PCS+PMA GXB phyip variant
proc compose_pcs_pma_gxb_nf_phyip {} {

   global mac_instance
   global fifoless_mac_instance
   global pcs_instance
   global nf_phyip_instance
   global nf_phyip_terminator_instance

   # Connection point names
   global AVALON_CP_NAME
   global AVALON_CLOCK_CP_NAME
   global AVALON_RESET_CP_NAME

   global WIRE_MISC_CP_NAME

   global PCS_MAC_TX_CLOCK_NAME
   global PCS_MAC_RX_CLOCK_NAME

   global PCS_TX_CLK_NAME
   global PCS_RX_CLK_NAME
   global PCS_REF_CLK_CP_NAME
   global PCS_CDR_REF_CLK_CP_NAME

   global PCS_TX_RESET_NAME
   global PCS_RX_RESET_NAME

   global PCS_GMII_CP_NAME
   global PCS_MII_CP_NAME

   global PCS_CLKENA_CP_NAME

   global PCS_SGMII_STATUS_CP_NAME
   global PCS_STATUS_LED_CP_NAME
   global PCS_SERDES_CONTROL_CP_NAME
   global PMA_SERIAL_CP_NAME
   global PMA_GXB_CAL_BLK_CLK_CP_NAME

   global MAC_GMII_CP_NAME
   global MAC_MII_CP_NAME
   global MAC_STATUS_CP_NAME
   global WIRE_CLKENA_CP_NAME

   global pcs_pma_nf_phyip_port_connection
   global nf_phyip_terminator_port_connection
   
   global RX_LATENCY_ADJ
   global TX_LATENCY_ADJ
   global RX_PATH_DELAY
   global TX_PATH_DELAY
   global PCS_PHASE_MEASURE_CLK

   global NF_PHYIP_RECONFIG_CLK_NAME
   global NF_PHYIP_RECONFIG_RESET_NAME
   global NF_PHYIP_RECONFIG_SLAVE_NAME

   set isUseMAC [get_parameter_value isUseMAC]
   set isUsePCS [get_parameter_value isUsePCS]
   set enable_use_internal_fifo [get_parameter_value enable_use_internal_fifo]

   set max_channels [get_parameter_value max_channels]

   set enable_sgmii [get_parameter_value enable_sgmii]
   set enable_clk_sharing [get_parameter_value enable_clk_sharing]
   set nf_phyip_rcfg_enable [get_parameter_value nf_phyip_rcfg_enable]
   
   # check 1588 criteria
   set core_variation [get_parameter_value core_variation]
   set deviceFamily [get_parameter_value deviceFamily]
   set transceiver_type [get_parameter_value transceiver_type]
   if { $enable_sgmii &&
      [expr {"$core_variation" == "MAC_PCS"}] &&
      [expr {"$transceiver_type" == "GXB"}] &&
        [expr {"$enable_use_internal_fifo" == "false"}] &&
        [expr {"$deviceFamily" == "ARRIA10"} || {"$deviceFamily" == "STRATIXV"} || {"$deviceFamily" == "ARRIAV"}  || {"$deviceFamily" == "ARRIAVGZ"}  || {"$deviceFamily" == "CYCLONEV"}]} {
      set enable_timestamping [get_parameter_value enable_timestamping]
      set enable_ptp_1step [get_parameter_value enable_ptp_1step]
      set tstamp_fp_width [get_parameter_value tstamp_fp_width]  
   } else {
      set enable_timestamping 0
      set enable_ptp_1step 0
      set tstamp_fp_width 4
   }

   # Decide if this is a multiple channel MAC+PCS core variation
   # If we don't are in PCS_ONLY configuration,
   # create the common register interface clock source and reset source
   if {$isUseMAC} {
      if {$enable_use_internal_fifo} {
         set pcs_max_channels 1
      } else {
         set pcs_max_channels $max_channels\
      }
   } else {
      set pcs_max_channels 1

      # Common register interface clock source and reset source
      add_instance reg_clk_module altera_clock_bridge
      add_instance reg_rst_module altera_reset_bridge

      add_interface $AVALON_CLOCK_CP_NAME clock end
      set_interface_property $AVALON_CLOCK_CP_NAME EXPORT_OF reg_clk_module.in_clk
      set_interface_property $AVALON_CLOCK_CP_NAME PORT_NAME_MAP "clk in_clk"

      add_interface $AVALON_RESET_CP_NAME reset end
      set_interface_property $AVALON_RESET_CP_NAME EXPORT_OF reg_rst_module.in_reset
      set_interface_property $AVALON_RESET_CP_NAME PORT_NAME_MAP "reset in_reset"

      add_connection reg_clk_module.out_clk reg_rst_module.clk

   }
   

   # Common ref_clk clock source
   add_instance ref_clk_module altera_clock_bridge

   add_interface $PCS_REF_CLK_CP_NAME clock end
   set_interface_property $PCS_REF_CLK_CP_NAME EXPORT_OF ref_clk_module.in_clk
   set_interface_property $PCS_REF_CLK_CP_NAME PORT_NAME_MAP "ref_clk in_clk"

   # Timestamp pcs phase measure clock source
   if {$enable_timestamping} {
      add_instance pcs_phase_measure_clk_module altera_clock_bridge

      add_interface $PCS_PHASE_MEASURE_CLK clock end
      set_interface_property $PCS_PHASE_MEASURE_CLK PORT_NAME_MAP "pcs_phase_measure_clk in_clk"
      set_interface_property $PCS_PHASE_MEASURE_CLK EXPORT_OF pcs_phase_measure_clk_module.in_clk
   }

   for {set index 0} { $index < $pcs_max_channels} {incr index} {
      set the_pcs_instance $pcs_instance\_$index
      set the_phyip_instance $nf_phyip_instance\_$index
      set the_phyip_terminator_instance $nf_phyip_terminator_instance\_$index
      set phyip_rxclkout_splitter_instance phyip_rxclkout_splitter_instance_$index      
      set phyip_rxclkout_splitter_bridge_instance phyip_rxclkout_splitter_bridge_instance$index      
      set phyip_rxclkout_rx_recovered_clk_bridge_instance phyip_rxclkout_rx_recovered_clk_bridge_instance$index      

      add_instance $the_pcs_instance altera_eth_tse_pcs_pma_nf_phyip
      add_instance $the_phyip_instance altera_xcvr_native_a10
      set_instance_property $the_phyip_instance SUPPRESS_ALL_WARNINGS true
      set_instance_property $the_phyip_instance SUPPRESS_ALL_INFO_MESSAGES true
      
      add_instance $the_phyip_terminator_instance altera_eth_tse_nf_phyip_terminator
      
      # Add splitter instance for rx_clkout because need to fan out to phyip terminator and pcs
      add_instance $phyip_rxclkout_splitter_instance altera_eth_tse_conduit_fanout
      set_instance_parameter $phyip_rxclkout_splitter_instance PORT_LIST "rx_pcs_clk,1"
      if {$enable_timestamping} {
         set_instance_parameter $phyip_rxclkout_splitter_instance NUM_FANOUT 2
      } else {
         set_instance_parameter $phyip_rxclkout_splitter_instance NUM_FANOUT 1
      } 

      if {$enable_timestamping} {      
         # Add bridge to connect between two different type of port
         add_instance $phyip_rxclkout_splitter_bridge_instance altera_eth_tse_bridge
         set_instance_parameter $phyip_rxclkout_splitter_bridge_instance INPUT_PORT_PROPERTY "conduit,rx_pcs_clk"
         set_instance_parameter $phyip_rxclkout_splitter_bridge_instance OUTPUT_PORT_PROPERTY "clock,clk"
         set_instance_parameter $phyip_rxclkout_splitter_bridge_instance DATA_WIDTH 1
         
         # Add bridge to connect between two different type of port
         add_instance $phyip_rxclkout_rx_recovered_clk_bridge_instance altera_eth_tse_bridge
         set_instance_parameter $phyip_rxclkout_rx_recovered_clk_bridge_instance INPUT_PORT_PROPERTY "clock,clk"
         set_instance_parameter $phyip_rxclkout_rx_recovered_clk_bridge_instance OUTPUT_PORT_PROPERTY "conduit,export"
         set_instance_parameter $phyip_rxclkout_rx_recovered_clk_bridge_instance DATA_WIDTH 1 
      }      

      # Connect sd_loopback control signal from PCS to PHYIP terminator
      add_connection $the_pcs_instance\.sd_loopback $the_phyip_terminator_instance\.sd_loopback
     
      # Update the instance parameter
      update_pcs_pma_phyip_instance_param $index
      set_instance_parameter $the_pcs_instance connect_to_mac $isUseMAC

      update_nf_phyip_instance_param $index
     
      set_instance_parameter $the_phyip_terminator_instance ENABLE_TIMESTAMPING $enable_timestamping
      set_instance_parameter $the_phyip_terminator_instance ENABLE_SGMII $enable_sgmii
      set_instance_parameter $the_pcs_instance ENABLE_TIMESTAMPING $enable_timestamping

      # Connect clock and reset connection points pcs instance
      add_connection reg_clk_module.out_clk $the_pcs_instance.$AVALON_CLOCK_CP_NAME
      add_connection reg_rst_module.out_reset $the_pcs_instance.$AVALON_RESET_CP_NAME
     
  
      # Connect pcs_measure_phase_clk to pcs instance
      if {$enable_timestamping} {
         add_connection pcs_phase_measure_clk_module.out_clk $the_pcs_instance.$PCS_PHASE_MEASURE_CLK
      }  

      # Connect PHYIP and PCS together
      foreach {pcs_port} [array names pcs_pma_nf_phyip_port_connection] {
         set phyip_port $pcs_pma_nf_phyip_port_connection($pcs_port)

         add_connection $the_pcs_instance\.$pcs_port $the_phyip_instance\.$phyip_port
      }

      if {$enable_sgmii} {
      } else {
         add_connection $the_phyip_instance\.rx_rmfifostatus $the_phyip_terminator_instance\.rx_rmfifostatus
         add_connection $the_pcs_instance\.rx_rmfifodatainserted $the_phyip_terminator_instance\.rx_rmfifodatainserted
         add_connection $the_pcs_instance\.rx_rmfifodatadeleted $the_phyip_terminator_instance\.rx_rmfifodatadeleted
      }

      # Connect PCS to PHYIP terminator
      add_connection $the_pcs_instance\.rx_runlengthviolation $the_phyip_terminator_instance\.rx_runlengthviolation
      add_connection $the_pcs_instance\.tx_pcs_clk $the_phyip_terminator_instance\.tx_pcs_clk
      
      #add_connection $the_pcs_instance\.rx_pcs_clk $the_phyip_terminator_instance\.rx_pcs_clk
      # Connect rx_clkout from phyip terminator to the splitter
      add_connection $the_phyip_terminator_instance.rx_pcs_clk $phyip_rxclkout_splitter_instance\.sig_input
      add_connection $phyip_rxclkout_splitter_instance\.sig_fanout0 $the_pcs_instance\.rx_pcs_clk      

      # Connect PHYIP and its terminator together
      foreach {phyip_port} [array names nf_phyip_terminator_port_connection] {
         set terminator_port $nf_phyip_terminator_port_connection($phyip_port)

         add_connection $the_phyip_instance\.$phyip_port $the_phyip_terminator_instance\.$terminator_port
      }

      # Connect PHYIP recovered clock to its terminator
      #add_connection $the_phyip_instance.rx_pma_div_clkout $the_phyip_terminator_instance.rx_recovered_clk
      # In timestamp mode, rx recovered clock is from rxclkout. Else, it is from phyip recovered clock.
      if {$enable_timestamping} {
         add_connection $phyip_rxclkout_splitter_instance\.sig_fanout1 $phyip_rxclkout_splitter_bridge_instance\.in_data
         add_connection $phyip_rxclkout_splitter_bridge_instance\.out_data $the_phyip_terminator_instance\.rx_recovered_clk
         add_connection $the_phyip_instance\.rx_pma_div_clkout $phyip_rxclkout_rx_recovered_clk_bridge_instance\.in_data
         add_connection $phyip_rxclkout_rx_recovered_clk_bridge_instance\.out_data $the_phyip_terminator_instance\.terminate_rx_recovered_clk
      } else {
         add_connection $the_phyip_instance\.rx_pma_div_clkout $the_phyip_terminator_instance\.rx_recovered_clk
      }      

      add_connection $the_phyip_terminator_instance\.tx_coreclk $the_phyip_instance\.tx_coreclkin
      add_connection $the_phyip_terminator_instance\.rx_coreclk $the_phyip_instance\.rx_coreclkin

      if {$isUseMAC} {
         # MAC+PCS variant, let us connect the MAC to PCS
         
         # Connect the ref_clk
         add_connection ref_clk_module.out_clk $the_pcs_instance.$PCS_REF_CLK_CP_NAME

         # Avalon slave connection point
         add_connection avalon_arbiter.av_pcs_master_$index $the_pcs_instance\.$AVALON_CP_NAME

         # Decide if we are connecting to fifoless mac or not
         if {$enable_use_internal_fifo} {
            set the_mac_instance $mac_instance
         } else {
            set the_mac_instance $fifoless_mac_instance\_$index
         }

         # Connect MAC to PCS clock
         add_connection $the_pcs_instance.$PCS_TX_CLK_NAME $the_mac_instance.$PCS_MAC_TX_CLOCK_NAME
         add_connection $the_pcs_instance.$PCS_RX_CLK_NAME $the_mac_instance.$PCS_MAC_RX_CLOCK_NAME
         
         # Connect reset to PCS tx clock and rx clock reset (QSYS will add the reset synchronizer for us)
         add_connection reg_rst_module.out_reset $the_pcs_instance.$PCS_TX_RESET_NAME
         add_connection reg_rst_module.out_reset $the_pcs_instance.$PCS_RX_RESET_NAME

         # Connect MAC to PCS ports
         add_connection $the_mac_instance\.$MAC_GMII_CP_NAME   $the_pcs_instance.$PCS_GMII_CP_NAME
         add_connection $the_mac_instance\.$MAC_MII_CP_NAME    $the_pcs_instance.$PCS_MII_CP_NAME
         add_connection $the_mac_instance\.$MAC_STATUS_CP_NAME $the_pcs_instance.$PCS_SGMII_STATUS_CP_NAME
         add_connection $the_mac_instance\.$WIRE_CLKENA_CP_NAME $the_pcs_instance.$PCS_CLKENA_CP_NAME
          
         # Connect PCS TX/RX latency adj port to MAC
         if {$enable_timestamping} {
            add_connection $the_pcs_instance.$RX_LATENCY_ADJ $the_mac_instance.$RX_PATH_DELAY
            add_connection $the_pcs_instance.$TX_LATENCY_ADJ $the_mac_instance.$TX_PATH_DELAY
         }

         # Export the status led, serdes control and serial interface
         # If it is MAC + PCS with FIFO variant, don't use index number.
         if {$enable_use_internal_fifo} {
            add_interface $PCS_STATUS_LED_CP_NAME conduit end
            set_interface_property $PCS_STATUS_LED_CP_NAME EXPORT_OF $the_pcs_instance\.$PCS_STATUS_LED_CP_NAME
            compose_rename_and_register_ports $the_pcs_instance $PCS_STATUS_LED_CP_NAME

            add_interface $PCS_SERDES_CONTROL_CP_NAME conduit end
            set_interface_property $PCS_SERDES_CONTROL_CP_NAME EXPORT_OF $the_phyip_terminator_instance\.$PCS_SERDES_CONTROL_CP_NAME
            compose_rename_and_register_ports $the_phyip_terminator_instance $PCS_SERDES_CONTROL_CP_NAME

            add_interface $PMA_SERIAL_CP_NAME conduit end
            set_interface_property $PMA_SERIAL_CP_NAME EXPORT_OF $the_phyip_terminator_instance\.$PMA_SERIAL_CP_NAME
            compose_rename_and_register_ports $the_phyip_terminator_instance $PMA_SERIAL_CP_NAME

            # Export the following clock input interfaces from NF PHYIP
            add_interface tx_serial_clk hssi_serial_clock end
            set_interface_property tx_serial_clk EXPORT_OF $the_phyip_instance\.tx_serial_clk0
            set_interface_property tx_serial_clk PORT_NAME_MAP "tx_serial_clk tx_serial_clk0"

            add_interface rx_cdr_refclk clock end
            set_interface_property rx_cdr_refclk EXPORT_OF $the_phyip_instance\.rx_cdr_refclk0
            set_interface_property rx_cdr_refclk PORT_NAME_MAP "rx_cdr_refclk rx_cdr_refclk0"

            # Export the following interfaces from NF PHYIP
            foreach {phyip_conduit_interface} {tx_analogreset \
               tx_digitalreset \
               rx_analogreset \
               rx_digitalreset \
               tx_cal_busy \
               rx_cal_busy \
               rx_set_locktodata \
               rx_set_locktoref \
               rx_is_lockedtoref \
               rx_is_lockedtodata} {
      
               add_interface $phyip_conduit_interface conduit end
               set_interface_property $phyip_conduit_interface EXPORT_OF $the_phyip_instance\.$phyip_conduit_interface
               set_interface_property $phyip_conduit_interface PORT_NAME_MAP "$phyip_conduit_interface $phyip_conduit_interface"
            }

            # Export the reconfiguration interface from Native PHYIP if it is enabled
            if {$nf_phyip_rcfg_enable} {
               add_interface $NF_PHYIP_RECONFIG_CLK_NAME clock end
               set_interface_property $NF_PHYIP_RECONFIG_CLK_NAME  EXPORT_OF $the_phyip_instance\.$NF_PHYIP_RECONFIG_CLK_NAME
               compose_rename_and_register_ports $the_phyip_instance $NF_PHYIP_RECONFIG_CLK_NAME
      
               add_interface $NF_PHYIP_RECONFIG_RESET_NAME reset end
               set_interface_property $NF_PHYIP_RECONFIG_RESET_NAME EXPORT_OF $the_phyip_instance\.$NF_PHYIP_RECONFIG_RESET_NAME
               compose_rename_and_register_ports $the_phyip_instance $NF_PHYIP_RECONFIG_RESET_NAME
      
               add_interface $NF_PHYIP_RECONFIG_SLAVE_NAME avalon end
               set_interface_property $NF_PHYIP_RECONFIG_SLAVE_NAME EXPORT_OF $the_phyip_instance\.$NF_PHYIP_RECONFIG_SLAVE_NAME
               compose_rename_and_register_ports $the_phyip_instance $NF_PHYIP_RECONFIG_SLAVE_NAME
            }
         } else {
            add_interface $PCS_STATUS_LED_CP_NAME\_$index conduit end
            set_interface_property $PCS_STATUS_LED_CP_NAME\_$index  EXPORT_OF $the_pcs_instance\.$PCS_STATUS_LED_CP_NAME
            compose_rename_and_register_ports $the_pcs_instance $PCS_STATUS_LED_CP_NAME $index

            add_interface $PCS_SERDES_CONTROL_CP_NAME\_$index conduit end
            set_interface_property $PCS_SERDES_CONTROL_CP_NAME\_$index EXPORT_OF $the_phyip_terminator_instance\.$PCS_SERDES_CONTROL_CP_NAME
            compose_rename_and_register_ports $the_phyip_terminator_instance $PCS_SERDES_CONTROL_CP_NAME $index

            add_interface $PMA_SERIAL_CP_NAME\_$index conduit end
            set_interface_property $PMA_SERIAL_CP_NAME\_$index EXPORT_OF $the_phyip_terminator_instance\.$PMA_SERIAL_CP_NAME
            compose_rename_and_register_ports $the_phyip_terminator_instance $PMA_SERIAL_CP_NAME $index

            # Export the following clock input interfaces from NF PHYIP
            add_interface tx_serial_clk\_$index hssi_serial_clock end
            set_interface_property tx_serial_clk\_$index EXPORT_OF $the_phyip_instance\.tx_serial_clk0
            set_interface_property tx_serial_clk\_$index PORT_NAME_MAP "tx_serial_clk\_$index tx_serial_clk0"
            
            add_interface rx_cdr_refclk\_$index clock end
            set_interface_property rx_cdr_refclk\_$index EXPORT_OF $the_phyip_instance\.rx_cdr_refclk0
            set_interface_property rx_cdr_refclk\_$index PORT_NAME_MAP "rx_cdr_refclk\_$index rx_cdr_refclk0"

            # Export the following interfaces from NF PHYIP
            foreach {phyip_conduit_interface} {tx_analogreset \
               tx_digitalreset \
               rx_analogreset \
               rx_digitalreset \
               tx_cal_busy \
               rx_cal_busy \
               rx_set_locktodata \
               rx_set_locktoref \
               rx_is_lockedtoref \
               rx_is_lockedtodata} {
      
               add_interface $phyip_conduit_interface\_$index conduit end
               set_interface_property $phyip_conduit_interface\_$index EXPORT_OF $the_phyip_instance\.$phyip_conduit_interface
               set_interface_property $phyip_conduit_interface\_$index PORT_NAME_MAP "$phyip_conduit_interface\_$index $phyip_conduit_interface"
            }

            # Export the reconfiguration interface from Native PHYIP if it is enabled
            if {$nf_phyip_rcfg_enable} {
               add_interface $NF_PHYIP_RECONFIG_CLK_NAME\_$index clock end
               set_interface_property $NF_PHYIP_RECONFIG_CLK_NAME\_$index  EXPORT_OF $the_phyip_instance\.$NF_PHYIP_RECONFIG_CLK_NAME
               compose_rename_and_register_ports $the_phyip_instance $NF_PHYIP_RECONFIG_CLK_NAME $index
      
               add_interface $NF_PHYIP_RECONFIG_RESET_NAME\_$index reset end
               set_interface_property $NF_PHYIP_RECONFIG_RESET_NAME\_$index  EXPORT_OF $the_phyip_instance\.$NF_PHYIP_RECONFIG_RESET_NAME
               compose_rename_and_register_ports $the_phyip_instance $NF_PHYIP_RECONFIG_RESET_NAME $index
      
               add_interface $NF_PHYIP_RECONFIG_SLAVE_NAME\_$index avalon end
               set_interface_property $NF_PHYIP_RECONFIG_SLAVE_NAME\_$index  EXPORT_OF $the_phyip_instance\.$NF_PHYIP_RECONFIG_SLAVE_NAME
               compose_rename_and_register_ports $the_phyip_instance $NF_PHYIP_RECONFIG_SLAVE_NAME $index
            }

         }

      } else {
         # Export PCS connection points
         add_interface $AVALON_CP_NAME avalon slave
         set_interface_property $AVALON_CP_NAME EXPORT_OF $the_pcs_instance\.$AVALON_CP_NAME
         compose_rename_and_register_ports $the_pcs_instance $AVALON_CP_NAME

         # Connect the ref_clk
         add_connection ref_clk_module.out_clk $the_pcs_instance.$PCS_REF_CLK_CP_NAME

         add_interface $PCS_TX_CLK_NAME clock source
         set_interface_property $PCS_TX_CLK_NAME EXPORT_OF $the_pcs_instance\.$PCS_TX_CLK_NAME
         compose_rename_and_register_ports $the_pcs_instance $PCS_TX_CLK_NAME

         add_interface $PCS_RX_CLK_NAME clock source
         set_interface_property $PCS_RX_CLK_NAME EXPORT_OF $the_pcs_instance\.$PCS_RX_CLK_NAME
         compose_rename_and_register_ports $the_pcs_instance $PCS_RX_CLK_NAME

         add_interface $PCS_TX_RESET_NAME reset end
         set_interface_property $PCS_TX_RESET_NAME EXPORT_OF $the_pcs_instance\.$PCS_TX_RESET_NAME
         compose_rename_and_register_ports $the_pcs_instance $PCS_TX_RESET_NAME

         add_interface $PCS_RX_RESET_NAME reset end
         set_interface_property $PCS_RX_RESET_NAME EXPORT_OF $the_pcs_instance\.$PCS_RX_RESET_NAME
         compose_rename_and_register_ports $the_pcs_instance $PCS_RX_RESET_NAME

         add_interface $PCS_GMII_CP_NAME conduit end
         set_interface_property $PCS_GMII_CP_NAME EXPORT_OF $the_pcs_instance\.$PCS_GMII_CP_NAME
         compose_rename_and_register_ports $the_pcs_instance $PCS_GMII_CP_NAME

         if {$enable_sgmii} {
            add_interface $PCS_CLKENA_CP_NAME conduit end
            set_interface_property $PCS_CLKENA_CP_NAME EXPORT_OF $the_pcs_instance\.$PCS_CLKENA_CP_NAME
            compose_rename_and_register_ports $the_pcs_instance $PCS_CLKENA_CP_NAME

            add_interface $PCS_MII_CP_NAME conduit end
            set_interface_property $PCS_MII_CP_NAME EXPORT_OF $the_pcs_instance\.$PCS_MII_CP_NAME
            compose_rename_and_register_ports $the_pcs_instance $PCS_MII_CP_NAME
         
            add_interface $PCS_SGMII_STATUS_CP_NAME conduit end
            set_interface_property $PCS_SGMII_STATUS_CP_NAME EXPORT_OF $the_pcs_instance\.$PCS_SGMII_STATUS_CP_NAME
            compose_rename_and_register_ports $the_pcs_instance $PCS_SGMII_STATUS_CP_NAME
         }

         add_interface $PCS_STATUS_LED_CP_NAME conduit end
         set_interface_property $PCS_STATUS_LED_CP_NAME EXPORT_OF $the_pcs_instance\.$PCS_STATUS_LED_CP_NAME
         compose_rename_and_register_ports $the_pcs_instance $PCS_STATUS_LED_CP_NAME

         add_interface $PCS_SERDES_CONTROL_CP_NAME conduit end
         set_interface_property $PCS_SERDES_CONTROL_CP_NAME EXPORT_OF $the_phyip_terminator_instance\.$PCS_SERDES_CONTROL_CP_NAME
         compose_rename_and_register_ports $the_phyip_terminator_instance $PCS_SERDES_CONTROL_CP_NAME

         add_interface $PMA_SERIAL_CP_NAME conduit end
         set_interface_property $PMA_SERIAL_CP_NAME EXPORT_OF $the_phyip_terminator_instance\.$PMA_SERIAL_CP_NAME
         compose_rename_and_register_ports $the_phyip_terminator_instance $PMA_SERIAL_CP_NAME

         # Export the following clock input interfaces from NF PHYIP
         add_interface tx_serial_clk hssi_serial_clock end
         set_interface_property tx_serial_clk EXPORT_OF $the_phyip_instance\.tx_serial_clk0
         set_interface_property tx_serial_clk PORT_NAME_MAP "tx_serial_clk tx_serial_clk0"

         add_interface rx_cdr_refclk clock end
         set_interface_property rx_cdr_refclk EXPORT_OF $the_phyip_instance\.rx_cdr_refclk0
         set_interface_property rx_cdr_refclk PORT_NAME_MAP "rx_cdr_refclk rx_cdr_refclk0"

         # Export the following interfaces from NF PHYIP
         foreach {phyip_conduit_interface} {tx_analogreset \
            tx_digitalreset \
            rx_analogreset \
            rx_digitalreset \
            tx_cal_busy \
            rx_cal_busy \
            rx_set_locktodata \
            rx_set_locktoref \
            rx_is_lockedtoref \
            rx_is_lockedtodata} {
   
            add_interface $phyip_conduit_interface conduit end
            set_interface_property $phyip_conduit_interface EXPORT_OF $the_phyip_instance\.$phyip_conduit_interface
            set_interface_property $phyip_conduit_interface PORT_NAME_MAP "$phyip_conduit_interface $phyip_conduit_interface"
         }

         # Export the reconfiguration interface from Native PHYIP if it is enabled
         if {$nf_phyip_rcfg_enable} {
            add_interface $NF_PHYIP_RECONFIG_CLK_NAME clock end
            set_interface_property $NF_PHYIP_RECONFIG_CLK_NAME EXPORT_OF $the_phyip_instance\.$NF_PHYIP_RECONFIG_CLK_NAME
            compose_rename_and_register_ports $the_phyip_instance $NF_PHYIP_RECONFIG_CLK_NAME
   
            add_interface $NF_PHYIP_RECONFIG_RESET_NAME reset end
            set_interface_property $NF_PHYIP_RECONFIG_RESET_NAME EXPORT_OF $the_phyip_instance\.$NF_PHYIP_RECONFIG_RESET_NAME
            compose_rename_and_register_ports $the_phyip_instance $NF_PHYIP_RECONFIG_RESET_NAME
   
            add_interface $NF_PHYIP_RECONFIG_SLAVE_NAME avalon end
            set_interface_property $NF_PHYIP_RECONFIG_SLAVE_NAME EXPORT_OF $the_phyip_instance\.$NF_PHYIP_RECONFIG_SLAVE_NAME
            compose_rename_and_register_ports $the_phyip_instance $NF_PHYIP_RECONFIG_SLAVE_NAME
         }

      }
   }
}

# Update the MAC instance parameters based on current core setting.
proc update_mac_instance_param {} {
   global mac_instance
   global mac_instance_param_map
   set use_misc_ports [get_parameter_value use_misc_ports]
   set stat_cnt_ena [get_parameter_value stat_cnt_ena]
   set ext_stat_cnt_ena [get_parameter_value ext_stat_cnt_ena]
   set isUsePCS [get_parameter_value isUsePCS]
   set enable_sgmii [get_parameter_value enable_sgmii]
   set enable_hd_logic [get_parameter_value enable_hd_logic]
   set ifGMII [get_parameter_value ifGMII]
   set enable_shift16 [get_parameter_value enable_shift16]
   set core_variation [get_parameter_value core_variation]
   set enable_ena [get_parameter_value enable_ena]

   # Certain MAC options are not available in small MAC variants
   switch $core_variation {
      SMALL_MAC_10_100 {
         # Parameterize the instance with parameters, then we overwrite some of them
         foreach instance_param [array names mac_instance_param_map] {
            set_instance_parameter $mac_instance $instance_param [get_parameter_value $mac_instance_param_map($instance_param)]
         }

         # Fifo width must be 32-bits
         set_instance_parameter $mac_instance ENABLE_ENA 32
         
         # The following MAC options are used with small MAC 10/100Mbps
         set_instance_parameter $mac_instance ENABLE_GMII_LOOPBACK 0
         set_instance_parameter $mac_instance ENABLE_SUP_ADDR 0
         set_instance_parameter $mac_instance STAT_CNT_ENA 0
         set_instance_parameter $mac_instance ENABLE_EXTENDED_STAT_REG 0
         set_instance_parameter $mac_instance ENA_HASH 0
         set_instance_parameter $mac_instance ENABLE_MAC_FLOW_CTRL 0
         set_instance_parameter $mac_instance ENABLE_MAC_RX_VLAN 0
         set_instance_parameter $mac_instance ENABLE_MAC_TX_VLAN 0
         set_instance_parameter $mac_instance ENABLE_MAGIC_DETECT 0

         # MII only
         set_instance_parameter $mac_instance ifGMII "MII"

      }
      SMALL_MAC_GIGE {
         # Parameterize the instance with parameters, then we overwrite some of them
         foreach instance_param [array names mac_instance_param_map] {
            set_instance_parameter $mac_instance $instance_param [get_parameter_value $mac_instance_param_map($instance_param)]
         }

         # Fifo width must be 32-bits
         set_instance_parameter $mac_instance ENABLE_ENA 32
         
         # The following MAC options are used with small MAC GIGE
         set_instance_parameter $mac_instance ENABLE_GMII_LOOPBACK 0
         set_instance_parameter $mac_instance ENABLE_SUP_ADDR 0
         set_instance_parameter $mac_instance STAT_CNT_ENA 0
         set_instance_parameter $mac_instance ENABLE_EXTENDED_STAT_REG 0
         set_instance_parameter $mac_instance ENA_HASH 0
         set_instance_parameter $mac_instance ENABLE_MAC_FLOW_CTRL 0
         set_instance_parameter $mac_instance ENABLE_MAC_RX_VLAN 0
         set_instance_parameter $mac_instance ENABLE_MAC_TX_VLAN 0
         set_instance_parameter $mac_instance ENABLE_MAGIC_DETECT 0

         # Halfduplex is not supported for GIGE only mode
         set_instance_parameter $mac_instance ENABLE_HD_LOGIC 0

         # GMII/RGMII - Range is controlled in GUI
         set_instance_parameter $mac_instance ifGMII $ifGMII
      }
      default {
         foreach instance_param [array names mac_instance_param_map] {
            set_instance_parameter $mac_instance $instance_param [get_parameter_value $mac_instance_param_map($instance_param)]
         }

         # Extended statistic register can only be enabled if we have statistic counter
         if {$stat_cnt_ena} {
            set_instance_parameter $mac_instance ENABLE_EXTENDED_STAT_REG $ext_stat_cnt_ena
         } else {
            set_instance_parameter $mac_instance ENABLE_EXTENDED_STAT_REG 0
         }
   
         # Enable HD logic is only applicable in MAC+PCS variant if SGMII is enabled
         if {$isUsePCS} {
            if {$enable_sgmii} {
               set_instance_parameter $mac_instance ENABLE_HD_LOGIC $enable_hd_logic
            } else {
               set_instance_parameter $mac_instance ENABLE_HD_LOGIC 0
            }
         } else {
            set_instance_parameter $mac_instance ENABLE_HD_LOGIC $enable_hd_logic
         }

         # Enable shift 16 is not applicable for FIFO 8 bit interface
         if {[expr $enable_ena == 8]} {
            set_instance_parameter $mac_instance ENABLE_SHIFT16 0
         }

         set_instance_parameter $mac_instance ifGMII $ifGMII
      }
   }

   set_instance_parameter $mac_instance use_misc_ports $use_misc_ports
   set_instance_parameter $mac_instance ENABLE_MAC_TXADDR_SET 1
   set_instance_parameter $mac_instance RESET_LEVEL 1
   set_instance_parameter $mac_instance RAM_TYPE "AUTO"
   # Backward compatible with qmegawiz flow, don't insert timing adapter
   set_instance_parameter $mac_instance INSERT_TA 0
   set_instance_parameter $mac_instance CUST_VERSION 0
   set_instance_parameter $mac_instance CRC32CHECK16BIT 0
   set_instance_parameter $mac_instance CRC32DWIDTH 8
   set_instance_parameter $mac_instance USE_SYNC_RESET 1
   set_instance_parameter $mac_instance CRC32S1L2_EXTERN 0
   set_instance_parameter $mac_instance CRC32GENDELAY 6

}

# Update the fifoless MAC instance parameters based on current core setting.
proc update_fifoless_mac_instance_param {args} {
   set index [lindex $args 0]

   global fifoless_mac_instance
   global fifoless_mac_instance_param_map

   set mac_instance $fifoless_mac_instance\_$index
   set use_misc_ports [get_parameter_value use_misc_ports]
   set stat_cnt_ena [get_parameter_value stat_cnt_ena]
   set ext_stat_cnt_ena [get_parameter_value ext_stat_cnt_ena]
   set isUsePCS [get_parameter_value isUsePCS]
   set enable_sgmii [get_parameter_value enable_sgmii]
   set enable_hd_logic [get_parameter_value enable_hd_logic]
   set ifGMII [get_parameter_value ifGMII]
   
   # check 1588 criteria
   set core_variation [get_parameter_value core_variation]
   set deviceFamily [get_parameter_value deviceFamily]
   set enable_use_internal_fifo [get_parameter_value enable_use_internal_fifo]
   set transceiver_type [get_parameter_value transceiver_type]
   if { $enable_sgmii &&
      [expr {"$core_variation" == "MAC_PCS"}] &&
      [expr {"$transceiver_type" == "GXB"}] &&
      [expr {"$enable_use_internal_fifo" == "false"}] &&
      [expr {"$deviceFamily" == "ARRIA10"} || {"$deviceFamily" == "STRATIXV"} || {"$deviceFamily" == "ARRIAV"}  || {"$deviceFamily" == "ARRIAVGZ"}  || {"$deviceFamily" == "CYCLONEV"}]} {
      set enable_timestamping [get_parameter_value enable_timestamping]
      set enable_ptp_1step [get_parameter_value enable_ptp_1step]
      set tstamp_fp_width [get_parameter_value tstamp_fp_width]  
   } elseif {[expr {$ifGMII == "MII_GMII"}] &&
      [expr {"$core_variation" == "MAC_ONLY"}] &&
      [expr {"$enable_use_internal_fifo" == "false"}] &&
      [expr {"$deviceFamily" == "ARRIA10"} || {"$deviceFamily" == "STRATIXV"} || {"$deviceFamily" == "ARRIAV"}  || {"$deviceFamily" == "ARRIAVGZ"}  || {"$deviceFamily" == "CYCLONEV"}]} { 
      set enable_timestamping [get_parameter_value enable_timestamping]
      set enable_ptp_1step [get_parameter_value enable_ptp_1step]
      set tstamp_fp_width [get_parameter_value tstamp_fp_width]      
   } else {
      set enable_timestamping 0
      set enable_ptp_1step 0
      set tstamp_fp_width 4
   }

   foreach instance_param [array names fifoless_mac_instance_param_map] {
      set_instance_parameter $mac_instance $instance_param [get_parameter_value $fifoless_mac_instance_param_map($instance_param)]
   }

   # Extended statistic register can only be enabled if we have statistic counter
   if {$stat_cnt_ena} {
      set_instance_parameter $mac_instance ENABLE_EXTENDED_STAT_REG $ext_stat_cnt_ena
   } else {
      set_instance_parameter $mac_instance ENABLE_EXTENDED_STAT_REG 0
   }

   # Enable HD logic is only applicable in MAC+PCS variant if SGMII is enabled
   if {$isUsePCS} {
      if {$enable_sgmii} {
         set_instance_parameter $mac_instance ENABLE_HD_LOGIC $enable_hd_logic
      } else {
         set_instance_parameter $mac_instance ENABLE_HD_LOGIC 0
      }
   } else {
      set_instance_parameter $mac_instance ENABLE_HD_LOGIC $enable_hd_logic
   }

   set_instance_parameter $mac_instance ifGMII $ifGMII
   set_instance_parameter $mac_instance use_misc_ports $use_misc_ports
   set_instance_parameter $mac_instance ENABLE_MAC_TXADDR_SET 1
   set_instance_parameter $mac_instance RESET_LEVEL 1
   set_instance_parameter $mac_instance CUST_VERSION 0
   set_instance_parameter $mac_instance CRC32CHECK16BIT 0
   set_instance_parameter $mac_instance CRC32DWIDTH 8
   set_instance_parameter $mac_instance USE_SYNC_RESET 1
   set_instance_parameter $mac_instance CRC32S1L2_EXTERN 0
   set_instance_parameter $mac_instance CRC32GENDELAY 6

   if {[expr $index == 0]} {
      set_instance_parameter $mac_instance ENABLE_REG_SHARING 0
   } else {
      set_instance_parameter $mac_instance ENABLE_REG_SHARING 1
   }
   
   if {[expr {"$core_variation" == "MAC_ONLY"}]} {
      set_instance_parameter $mac_instance MAC_ONLY 1
   } else {
      set_instance_parameter $mac_instance MAC_ONLY 0
   }
   
   set_instance_parameter $mac_instance ENABLE_TIMESTAMPING $enable_timestamping   
   set_instance_parameter $mac_instance ENABLE_PTP_1STEP $enable_ptp_1step   
   set_instance_parameter $mac_instance FINGERPRINT_WIDTH $tstamp_fp_width   
}

# Update the fifoless PCS instance parameters based on current core setting.
proc update_pcs_instance_param {args} {
   set index [lindex $args 0]

   global pcs_instance
   global pcs_instance_param_map

   set the_pcs_instance $pcs_instance\_$index

   foreach instance_param [array names pcs_instance_param_map] {
      set_instance_parameter $the_pcs_instance $instance_param [get_parameter_value $pcs_instance_param_map($instance_param)]
   }
}

# Update PCS PMA LVDS instance parameters based on current core setting.
proc update_pcs_pma_lvds_instance_param {args} {
   set index [lindex $args 0]

   global pcs_instance
   global pcs_pma_lvds_instance_param_map

   set the_pcs_instance $pcs_instance\_$index

   foreach instance_param [array names pcs_pma_lvds_instance_param_map] {
      set_instance_parameter $the_pcs_instance $instance_param [get_parameter_value $pcs_pma_lvds_instance_param_map($instance_param)]
   }
   
}

# Update PCS PMA LVDS instance parameters based on current core setting for NightFury (Arria 10) device family
proc update_lvdsio_rx_instance_param {args} {
   set index [lindex $args 0]

   global lvdsio_rx_instance
   set the_lvdsio_rx_instance $lvdsio_rx_instance\_$index

   set_instance_parameter $the_lvdsio_rx_instance MODE "RX_Soft-CDR"
   set_instance_parameter $the_lvdsio_rx_instance USE_EXTERNAL_PLL "false"
   set_instance_parameter $the_lvdsio_rx_instance USE_CLOCK_PIN "false"
   set_instance_parameter $the_lvdsio_rx_instance NUM_CHANNELS 1
   set_instance_parameter $the_lvdsio_rx_instance J_FACTOR 10
   set_instance_parameter $the_lvdsio_rx_instance DATA_RATE "1250.0"
   set_instance_parameter $the_lvdsio_rx_instance INCLOCK_FREQUENCY "125.0"
   set_instance_parameter $the_lvdsio_rx_instance RX_USE_BITSLIP "true"
   set_instance_parameter $the_lvdsio_rx_instance ACTUAL_INCLOCK_FREQUENCY "125.0"
   set_instance_parameter $the_lvdsio_rx_instance RX_INCLOCK_PHASE_SHIFT "0"
   set_instance_parameter $the_lvdsio_rx_instance RX_BITSLIP_USE_RESET "true"
   set_instance_parameter $the_lvdsio_rx_instance RX_BITSLIP_ASSERT_MAX "false"
   set_instance_parameter $the_lvdsio_rx_instance RX_DPA_USE_RESET "true"
   set_instance_parameter $the_lvdsio_rx_instance RX_DPA_LOSE_LOCK_ON_ONE_CHANGE "false"
   set_instance_parameter $the_lvdsio_rx_instance RX_DPA_ALIGN_TO_RISING_EDGE_ONLY "false"
   set_instance_parameter $the_lvdsio_rx_instance RX_DPA_LOCKED_USED "false"
   set_instance_parameter $the_lvdsio_rx_instance RX_FIFO_USE_RESET "false"
   set_instance_parameter $the_lvdsio_rx_instance RX_CDR_SIMULATION_PPM_DRIFT "0"
   set_instance_parameter $the_lvdsio_rx_instance TX_OUTCLOCK_PHASE_SHIFT "0"
   set_instance_parameter $the_lvdsio_rx_instance TX_OUTCLOCK_DIVISION "1"
   set_instance_parameter $the_lvdsio_rx_instance TX_EXPORT_CORECLOCK "false"
   set_instance_parameter $the_lvdsio_rx_instance PLL_CORECLOCK_RESOURCE "Auto"
   set_instance_parameter $the_lvdsio_rx_instance PLL_SPEED_GRADE "4"
   set_instance_parameter $the_lvdsio_rx_instance PLL_EXPORT_LOCK "true"
   set_instance_parameter $the_lvdsio_rx_instance PLL_USE_RESET "true"
}

proc update_lvdsio_tx_instance_param {args} {
   set index [lindex $args 0]

   global lvdsio_tx_instance
   set the_lvdsio_tx_instance $lvdsio_tx_instance\_$index
   
   set_instance_parameter $the_lvdsio_tx_instance MODE "TX" 
   set_instance_parameter $the_lvdsio_tx_instance USE_EXTERNAL_PLL "false" 
   set_instance_parameter $the_lvdsio_tx_instance USE_CLOCK_PIN "false" 
   set_instance_parameter $the_lvdsio_tx_instance NUM_CHANNELS "1" 
   set_instance_parameter $the_lvdsio_tx_instance J_FACTOR "10" 
   set_instance_parameter $the_lvdsio_tx_instance DATA_RATE "1250.0" 
   set_instance_parameter $the_lvdsio_tx_instance INCLOCK_FREQUENCY "125.0" 
   set_instance_parameter $the_lvdsio_tx_instance ACTUAL_INCLOCK_FREQUENCY "125.0" 
   set_instance_parameter $the_lvdsio_tx_instance RX_INCLOCK_PHASE_SHIFT "0" 
   set_instance_parameter $the_lvdsio_tx_instance RX_DPA_USE_RESET "false" 
   set_instance_parameter $the_lvdsio_tx_instance RX_DPA_LOSE_LOCK_ON_ONE_CHANGE "false" 
   set_instance_parameter $the_lvdsio_tx_instance RX_DPA_ALIGN_TO_RISING_EDGE_ONLY "false" 
   set_instance_parameter $the_lvdsio_tx_instance RX_DPA_LOCKED_USED "false" 
   set_instance_parameter $the_lvdsio_tx_instance RX_FIFO_USE_RESET "false" 
   set_instance_parameter $the_lvdsio_tx_instance RX_CDR_SIMULATION_PPM_DRIFT "0" 
   set_instance_parameter $the_lvdsio_tx_instance TX_USE_OUTCLOCK "false"
   set_instance_parameter $the_lvdsio_tx_instance TX_OUTCLOCK_PHASE_SHIFT "0" 
   set_instance_parameter $the_lvdsio_tx_instance TX_OUTCLOCK_PHASE_SHIFT_ACTUAL "0" 
   set_instance_parameter $the_lvdsio_tx_instance TX_OUTCLOCK_DIVISION "1" 
   set_instance_parameter $the_lvdsio_tx_instance TX_EXPORT_CORECLOCK "false" 
   set_instance_parameter $the_lvdsio_tx_instance PLL_CORECLOCK_RESOURCE "Dual-Regional" 
   set_instance_parameter $the_lvdsio_tx_instance PLL_SPEED_GRADE "4" 
   set_instance_parameter $the_lvdsio_tx_instance PLL_EXPORT_LOCK "false" 
   set_instance_parameter $the_lvdsio_tx_instance PLL_USE_RESET "true" 
}

# Update PCS PMA GXB instance parameters based on current core setting.
proc update_pcs_pma_gxb_instance_param {args} {
   set index [lindex $args 0]

   global pcs_instance
   global pcs_pma_gxb_instance_param_map

   set the_pcs_instance $pcs_instance\_$index
   set deviceFamily [get_parameter_value deviceFamily]

   foreach instance_param [array names pcs_pma_gxb_instance_param_map] {
      set_instance_parameter $the_pcs_instance $instance_param [get_parameter_value $pcs_pma_gxb_instance_param_map($instance_param)]
   }

   # For ARRIAGX device family, the RTL is expecting the device name to be ARRIAGX, not STRATIXIIGXLITE
   if [expr {"$deviceFamily" == "STRATIXIIGXLITE"}] {
      set_instance_parameter $the_pcs_instance DEVICE_FAMILY "ARRIAGX"
   }

   if [expr {"$deviceFamily" == "STINGRAY"}] {
      set_instance_parameter $the_pcs_instance DEVICE_FAMILY "CYCLONEIVGX"
   }
}

# Update ALTGXB instance parameters based on current core setting.
proc update_altgxb_instance_param {args} {
   set index [lindex $args 0]

   global altgxb_instance

   global altgxb_instance_param_map

   set deviceFamily [get_parameter_value deviceFamily]
   set enable_alt_reconfig [get_parameter_value enable_alt_reconfig]
   set enable_sgmii [get_parameter_value enable_sgmii]

   set the_altgxb_instance $altgxb_instance\_$index

   foreach instance_param [array names altgxb_instance_param_map] {
      set_instance_parameter $the_altgxb_instance $instance_param [get_parameter_value $altgxb_instance_param_map($instance_param)]
   }

   if {$enable_sgmii} {
      set_instance_parameter $the_altgxb_instance ENABLE_SGMII 1
   } else {
      set_instance_parameter $the_altgxb_instance ENABLE_SGMII 0
   }

   # enable_alt_reconfig is only available for STRATIXIIGX and STRATIXIIGXLITE
   if {[expr {"$deviceFamily" == "STRATIXIIGX"} || {"$deviceFamily" == "STRATIXIIGXLITE"}]} {
      if {$enable_alt_reconfig} {
         set_instance_parameter $the_altgxb_instance ENABLE_ALT_RECONFIG 1
      } else {
         set_instance_parameter $the_altgxb_instance ENABLE_ALT_RECONFIG 0
      }
   } else {
      set_instance_parameter $the_altgxb_instance ENABLE_ALT_RECONFIG 1
   }

   # For ARRIAGX device family, the RTL is expecting the device name to be ARRIAGX, not STRATIXIIGXLITE
   if [expr {"$deviceFamily" == "STRATIXIIGXLITE"}] {
      set_instance_parameter $the_altgxb_instance DEVICE_FAMILY "ARRIAGX"
   }

   if [expr {"$deviceFamily" == "STINGRAY"}] {
      set_instance_parameter $the_altgxb_instance DEVICE_FAMILY "CYCLONEIVGX"
   }

}


# Update PCS PMA PHYIP instance parameters based on current core setting.
proc update_pcs_pma_phyip_instance_param {args} {
   set index [lindex $args 0]

   global pcs_instance
   global pcs_pma_phyip_instance_param_map

   set the_pcs_instance $pcs_instance\_$index

   foreach instance_param [array names pcs_pma_phyip_instance_param_map] {
      set_instance_parameter $the_pcs_instance $instance_param [get_parameter_value $pcs_pma_phyip_instance_param_map($instance_param)]
   }
}

proc update_phyip_instance_param {args} {
   set index [lindex $args 0]

   set deviceFamily [get_parameter_value deviceFamily]
   set enable_sgmii [get_parameter_value enable_sgmii]
   set phyip_pll_type [get_parameter_value phyip_pll_type]
   set phyip_en_synce_support [get_parameter_value phyip_en_synce_support]
   set phyip_pma_bonding_mode [get_parameter_value phyip_pma_bonding_mode]

   # check 1588 criteria
   set core_variation [get_parameter_value core_variation]
   set enable_use_internal_fifo [get_parameter_value enable_use_internal_fifo]
   set transceiver_type [get_parameter_value transceiver_type]
   if { $enable_sgmii &&
      [expr {"$core_variation" == "MAC_PCS"}] &&
      [expr {"$transceiver_type" == "GXB"}] &&
        [expr {"$enable_use_internal_fifo" == "false"}] &&
        [expr {"$deviceFamily" == "ARRIA10"} || {"$deviceFamily" == "STRATIXV"} || {"$deviceFamily" == "ARRIAV"}  || {"$deviceFamily" == "ARRIAVGZ"}  || {"$deviceFamily" == "CYCLONEV"}]} {
      set enable_timestamping [get_parameter_value enable_timestamping]
   } else {
      set enable_timestamping 0
   }   

   global phyip_instance

   set the_phyip_instance $phyip_instance\_$index

# TODO: Do we need to set these parameters since they are readonly
#   set_instance_parameter $the_phyip_instance use_8b10b_manual_control "false"
#   set_instance_parameter $the_phyip_instance gui_mgmt_clk_in_hz "125000000"
#   set_instance_parameter $the_phyip_instance byte_order_mode "none"

   set_instance_parameter $the_phyip_instance gui_use_8b10b "true"
   set_instance_parameter $the_phyip_instance gui_parameter_rules "GIGE"
   set_instance_parameter $the_phyip_instance gui_use_8b10b_status "1"
   set_instance_parameter $the_phyip_instance word_aligner_mode "sync_state_machine"
   set_instance_parameter $the_phyip_instance word_aligner_state_machine_datacnt "3"
   set_instance_parameter $the_phyip_instance word_aligner_state_machine_errcnt "4"
   set_instance_parameter $the_phyip_instance word_aligner_state_machine_patterncnt "4" 
   set_instance_parameter $the_phyip_instance gui_use_status "0"
   set_instance_parameter $the_phyip_instance word_aligner_pattern_length "7"
   set_instance_parameter $the_phyip_instance word_align_pattern "1111100"
   set_instance_parameter $the_phyip_instance gui_use_wa_status "1"
   set_instance_parameter $the_phyip_instance run_length_violation_checking "5"
   set_instance_parameter $the_phyip_instance gui_enable_run_length "1"
   set_instance_parameter $the_phyip_instance use_double_data_mode "auto"
   set_instance_parameter $the_phyip_instance gui_split_interfaces "0"
   set_instance_parameter $the_phyip_instance gui_rx_use_recovered_clk "1"
   set_instance_parameter $the_phyip_instance gui_pll_refclk_freq "125.0 MHz"
   set_instance_parameter $the_phyip_instance data_rate "1250Mbps"

   # Enabling SyncE support in Custom PHYIP
   set_instance_parameter $the_phyip_instance en_synce_support $phyip_en_synce_support

   # For Stratix V and Arria V GZ device family, user can choose ATX/CMU PLL type for TX PLL
   # else, it is default to CMU
   if {[expr {"$deviceFamily" == "STRATIXV"} || {"$deviceFamily" == "ARRIAVGZ"}]} {
      set_instance_parameter $the_phyip_instance gui_pll_type $phyip_pll_type
   }

   # For Arria V and Cyclone V device family, user can choose x1 or xN clock network for TX PLL
   # else, it is default to x1
   if {[expr {"$deviceFamily" == "ARRIAV"} || {"$deviceFamily" == "CYCLONEV"}]} {
      set_instance_parameter $the_phyip_instance gui_pma_bonding_mode $phyip_pma_bonding_mode
   }

   if {$enable_sgmii} {
      set_instance_parameter $the_phyip_instance use_rate_match_fifo "0"
      set_instance_parameter $the_phyip_instance gui_use_rmfifo_status "0"
   } else {
      set_instance_parameter $the_phyip_instance use_rate_match_fifo "1"
      set_instance_parameter $the_phyip_instance rate_match_pattern1 "10100010010101111100"
      set_instance_parameter $the_phyip_instance rate_match_pattern2 "10101011011010000011"
      set_instance_parameter $the_phyip_instance gui_use_rmfifo_status "1"
   }
   
   if {$enable_timestamping} {
      set_instance_parameter $the_phyip_instance std_tx_pcfifo_mode "register_fifo"
      set_instance_parameter $the_phyip_instance std_rx_pcfifo_mode "register_fifo"
   }
}

proc update_nf_phyip_instance_param {args} {
   set index [lindex $args 0]

   set deviceFamily [get_parameter_value deviceFamily]
   set enable_sgmii [get_parameter_value enable_sgmii]
   set nf_phyip_rcfg_enable [get_parameter_value nf_phyip_rcfg_enable]

   global nf_phyip_instance

   set the_phyip_instance $nf_phyip_instance\_$index

   if {$enable_sgmii} {
      set_instance_parameter $the_phyip_instance protocol_mode "gige_1588"
      set_instance_parameter $the_phyip_instance std_rx_rmfifo_mode "disabled"
      set_instance_parameter $the_phyip_instance std_tx_pcfifo_mode "register_fifo"
      set_instance_parameter $the_phyip_instance std_rx_pcfifo_mode "register_fifo"
   } else {
      set_instance_parameter $the_phyip_instance protocol_mode "gige"
      set_instance_parameter $the_phyip_instance std_rx_rmfifo_mode "gige" 
      set_instance_parameter $the_phyip_instance std_rx_rmfifo_pattern_n 702083 
      set_instance_parameter $the_phyip_instance std_rx_rmfifo_pattern_p 664956 
   }

   if {$nf_phyip_rcfg_enable} {
      set_instance_parameter $the_phyip_instance rcfg_enable 1
   } else {
      set_instance_parameter $the_phyip_instance rcfg_enable 0
   }

   set_instance_parameter $the_phyip_instance enable_simple_interface 1 
   set_instance_parameter $the_phyip_instance tx_pma_clk_div 2 
   set_instance_parameter $the_phyip_instance enable_ports_rx_manual_cdr_mode 1 
   set_instance_parameter $the_phyip_instance enable_port_rx_pma_div_clkout 1
   set_instance_parameter $the_phyip_instance rx_pma_div_clkout_divider 1
   set_instance_parameter $the_phyip_instance enable_port_rx_seriallpbken 1
   set_instance_parameter $the_phyip_instance std_tx_8b10b_enable 1 
   set_instance_parameter $the_phyip_instance std_rx_8b10b_enable 1 
   set_instance_parameter $the_phyip_instance std_rx_word_aligner_mode "synchronous state machine"
   set_instance_parameter $the_phyip_instance std_rx_word_aligner_pattern 124 
   set_instance_parameter $the_phyip_instance enable_port_rx_std_bitslipboundarysel 1 
}

# Update LVDS IO parameters based on current core setting for NightFury (Arria 10) device family
proc update_pcs_pma_nf_lvds_instance_param {args} {
   set index [lindex $args 0]

   global pcs_instance
   global pcs_pma_nf_lvds_instance_param_map

   set the_pcs_instance $pcs_instance\_$index

   foreach instance_param [array names pcs_pma_nf_lvds_instance_param_map] {
      set_instance_parameter $the_pcs_instance $instance_param [get_parameter_value $pcs_pma_nf_lvds_instance_param_map($instance_param)]
   }
   
}

# Create and connect altera_gpio instances to MAC with RGMII interface
proc create_and_connect_altera_gpio_instances {args} {
   set index [lindex $args 0]
   set mac_instance [lindex $args 1]

   add_instance rgmii_in4_$index altera_gpio
   set_instance_parameter rgmii_in4_$index SIZE 4
   set_instance_parameter rgmii_in4_$index PIN_TYPE "input"
   set_instance_parameter rgmii_in4_$index gui_io_reg_mode "DDIO"
   
   add_instance rgmii_in1_$index altera_gpio
   set_instance_parameter rgmii_in1_$index SIZE 1
   set_instance_parameter rgmii_in1_$index PIN_TYPE "input"
   set_instance_parameter rgmii_in1_$index gui_io_reg_mode "DDIO"
   
   add_instance rgmii_out4_$index altera_gpio
   set_instance_parameter rgmii_out4_$index SIZE 4
   set_instance_parameter rgmii_out4_$index PIN_TYPE "output"
   set_instance_parameter rgmii_out4_$index gui_io_reg_mode "DDIO"
   set_instance_parameter rgmii_out4_$index gui_areset_mode "clear"
   
   add_instance rgmii_out1_$index altera_gpio
   set_instance_parameter rgmii_out1_$index SIZE 1
   set_instance_parameter rgmii_out1_$index PIN_TYPE "output"
   set_instance_parameter rgmii_out1_$index gui_io_reg_mode "DDIO"
   set_instance_parameter rgmii_out1_$index gui_areset_mode "clear"

   add_connection rgmii_in4_$index.core_pad_in $mac_instance.rgmii_in4_pad
   add_connection rgmii_in4_$index.core_dout $mac_instance.rgmii_in4_dout
   add_connection rgmii_in4_$index.core_ck $mac_instance.rgmii_in4_ck
   
   add_connection rgmii_in1_$index.core_pad_in $mac_instance.rgmii_in1_pad
   add_connection rgmii_in1_$index.core_dout $mac_instance.rgmii_in1_dout
   add_connection rgmii_in1_$index.core_ck $mac_instance.rgmii_in1_ck
   
   add_connection rgmii_out4_$index.core_pad_out $mac_instance.rgmii_out4_pad
   add_connection rgmii_out4_$index.core_din $mac_instance.rgmii_out4_din
   add_connection rgmii_out4_$index.core_ck $mac_instance.rgmii_out4_ck
   add_connection rgmii_out4_$index.core_oe $mac_instance.rgmii_out4_oe
   add_connection rgmii_out4_$index.core_aclr $mac_instance.rgmii_out4_aclr
   
   add_connection rgmii_out1_$index.core_pad_out $mac_instance.rgmii_out1_pad
   add_connection rgmii_out1_$index.core_din $mac_instance.rgmii_out1_din
   add_connection rgmii_out1_$index.core_ck $mac_instance.rgmii_out1_ck
   add_connection rgmii_out1_$index.core_oe $mac_instance.rgmii_out1_oe
   add_connection rgmii_out1_$index.core_aclr $mac_instance.rgmii_out1_aclr
}

# A helper function to rename the ports for the connection points that we export from child
proc compose_rename_and_register_ports {args} {
   set dut_name [lindex $args 0]
   set interface [lindex $args 1]
   set index [lindex $args 2]

   set port_map_list {}

   if {[string equal $index ""]} {
      set postfix ""
   } else {
      set postfix "_$index"
   }

   foreach port [get_instance_interface_ports $dut_name $interface] {
      set port_name $port
      append port_name $postfix

      lappend port_map_list $port_name $port
   }

   append interface $postfix
   set_interface_property $interface PORT_NAME_MAP $port_map_list
}

# Calculates log2 for a given value in integer (round up)
proc log2_in_int {arg} {

   if {[expr $arg == 1]} {
      return 1;
   } else {
      return [expr int ([expr ceil ([expr [expr log ($arg)] / [expr log (2)]])])]
   }
}

#################################################################################################
# Validate
#################################################################################################
proc validate {} {
   get_device_family
   validate_version
   validate_parameters

   # Generate C Macros for embedded software driver
   gen_cmacros
}

#################################################################################################
# Generate C Macros for embedded software driver - called in validate callback,
# must be last after all validation
#################################################################################################
proc gen_cmacros {} {
   set ing_fifo [get_parameter_value ing_fifo]
   set eg_fifo [get_parameter_value eg_fifo]
   set enable_ena [get_parameter_value enable_ena]
   set core_variation [get_parameter_value core_variation]
   set ifGMII [get_parameter_value ifGMII]
   set useMDIO [get_parameter_value useMDIO]
   set max_channels [get_parameter_value max_channels]
   set enable_use_internal_fifo [get_parameter_value enable_use_internal_fifo]
   set isUseMAC [get_parameter_value isUseMAC]
   set isUsePCS [get_parameter_value isUsePCS]
   set enable_sgmii [get_parameter_value enable_sgmii]
   set phy_identifier [get_parameter_value phy_identifier]

   # C Macros
   set_module_assignment embeddedsw.CMacro.TRANSMIT_FIFO_DEPTH $eg_fifo
   set_module_assignment embeddedsw.CMacro.RECEIVE_FIFO_DEPTH $ing_fifo
   set_module_assignment embeddedsw.CMacro.FIFO_WIDTH $enable_ena

   if {[expr {"$core_variation" == "SMALL_MAC_10_100"}]} {
      set_module_assignment embeddedsw.CMacro.ENABLE_MACLITE 1
      set_module_assignment embeddedsw.CMacro.MACLITE_GIGE 0
   } elseif [expr {"$core_variation" == "SMALL_MAC_10_100"}] {
      set_module_assignment embeddedsw.CMacro.ENABLE_MACLITE 1
      set_module_assignment embeddedsw.CMacro.MACLITE_GIGE 1
   } else {
      set_module_assignment embeddedsw.CMacro.ENABLE_MACLITE 0
      set_module_assignment embeddedsw.CMacro.MACLITE_GIGE 0
   }

   if {[expr {"$ifGMII" == "RGMII"}]} {
      set_module_assignment embeddedsw.CMacro.RGMII 1
   } else {
      set_module_assignment embeddedsw.CMacro.RGMII 0
   }

   if {$useMDIO} {
      set_module_assignment embeddedsw.CMacro.USE_MDIO 1
   } else {
      set_module_assignment embeddedsw.CMacro.USE_MDIO 0
   }
   
   set_module_assignment embeddedsw.CMacro.NUMBER_OF_CHANNEL $max_channels
   set_module_assignment embeddedsw.CMacro.NUMBER_OF_MAC_MDIO_SHARED $max_channels

   # Decide if this is multichannel MAC
   if { $isUseMAC && [expr {"$enable_use_internal_fifo" == "false"}]} {
      set enable_multi_channel 1
   } else {
      set enable_multi_channel 0
   }

   if { $enable_multi_channel && [expr {$max_channels > 1}]} {
      set_module_assignment embeddedsw.CMacro.IS_MULTICHANNEL_MAC 1
      set_module_assignment embeddedsw.CMacro.MDIO_SHARED 1
      set_module_assignment embeddedsw.CMacro.REGISTER_SHARED 1
   } else {
      set_module_assignment embeddedsw.CMacro.IS_MULTICHANNEL_MAC 0
      set_module_assignment embeddedsw.CMacro.MDIO_SHARED 0
      set_module_assignment embeddedsw.CMacro.REGISTER_SHARED 0
   }

   if { $isUsePCS } {
      set_module_assignment embeddedsw.CMacro.PCS 1
   } else {
      set_module_assignment embeddedsw.CMacro.PCS 0
   }

   if { $enable_sgmii } {
      set_module_assignment embeddedsw.CMacro.PCS_SGMII 1
   } else {
      set_module_assignment embeddedsw.CMacro.PCS_SGMII 0
   }

   set_module_assignment embeddedsw.CMacro.PCS_ID $phy_identifier
   
   # Device tree parameters
   set_module_assignment embeddedsw.dts.vendor "altr"
   set_module_assignment embeddedsw.dts.group "ethernet"
   set_module_assignment embeddedsw.dts.name "tse"
   set_module_assignment embeddedsw.dts.compatible "altr,tse-1.0"
   set_module_assignment {embeddedsw.dts.params.ALTR,rx-fifo-depth} $ing_fifo
   set_module_assignment {embeddedsw.dts.params.ALTR,tx-fifo-depth} $eg_fifo
}
