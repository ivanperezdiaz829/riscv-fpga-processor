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


# $Id: //acds/rel/13.1/ip/sld/core/altera_sld_hub_controller_system/altera_sld_hub_controller_system_hw.tcl#1 $
# $Revision: #1 $
# $Date: 2013/08/11 $
# $Author: swbranch $

# +-----------------------------------
# |
package require -exact sopc 11.0
# |
# +-----------------------------------

# +-----------------------------------
# | module altera_sld_hub_controller_system
# |
set_module_property NAME altera_sld_hub_controller_system
set_module_property AUTHOR "Altera Corporation"
set_module_property VERSION 13.1
set_module_property GROUP "Verification/Debug & Performance"
set_module_property DISPLAY_NAME "SLD Hub Controller System"
set_module_property DESCRIPTION ""
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false
set_module_property COMPOSE_CALLBACK compose
set_module_property ANALYZE_HDL false
set_module_property OPAQUE_ADDRESS_MAP false

add_parameter ENABLE_JTAG_IO_SELECTION INTEGER 0
set_parameter_property ENABLE_JTAG_IO_SELECTION DEFAULT_VALUE 0
set_parameter_property ENABLE_JTAG_IO_SELECTION DISPLAY_NAME ENABLE_JTAG_IO_SELECTION
set_parameter_property ENABLE_JTAG_IO_SELECTION TYPE INTEGER
# set_parameter_property ENABLE_JTAG_IO_SELECTION ALLOWED_RANGES {0 1}
set_parameter_property ENABLE_JTAG_IO_SELECTION DISPLAY_HINT BOOLEAN
set_parameter_property ENABLE_JTAG_IO_SELECTION HDL_PARAMETER true
set_parameter_property ENABLE_JTAG_IO_SELECTION AFFECTS_ELABORATION true
set_parameter_property ENABLE_JTAG_IO_SELECTION STATUS EXPERIMENTAL
# |

proc compose {} {
  #  Clock, reset 
  add_instance clock_bridge altera_clock_bridge  

  add_instance reset_bridge altera_reset_bridge
  set_instance_parameter reset_bridge SYNCHRONOUS_EDGES deassert
  add_connection clock_bridge.out_clk reset_bridge.clk

  # clock/reset interface exports
  add_interface clk clock end
  set_interface_property clk export_of clock_bridge.in_clk
  add_interface reset reset end
  set_interface_property reset export_of reset_bridge.in_reset

  add_instance link altera_mm_debug_link
  add_connection clock_bridge.out_clk link.clk
  add_connection reset_bridge.out_reset link.reset

  set has_csr [ get_parameter_value ENABLE_JTAG_IO_SELECTION ]
  set_instance_parameter link ENABLE_CSR_MASTER_INTERFACE $has_csr
  if { $has_csr } {
    add_connection link.csr_master hub_controller.csr
    set_connection_parameter_value link.csr_master/hub_controller.csr arbitrationPriority {1}
    set_connection_parameter_value link.csr_master/hub_controller.csr baseAddress {0}
  }

  # debug fabric
  add_instance fabric altera_debug_fabric
  set_instance_parameter_value fabric STREAMS 1
  set_instance_parameter_value fabric MASTERS 0
  set_instance_parameter_value fabric USE_ROM 0
  set_instance_parameter_value fabric STREAM_CONFIG {{ mfr_code 0x6E type_code 259 ready 1 channel_width 0 downReadyLatency 0 upReadyLatency 0 }}
  set_instance_parameter_value fabric CHANNEL_WIDTH 1
  add_connection clock_bridge.out_clk fabric.clk
  add_connection reset_bridge.out_reset fabric.reset

  # sld hub controller
  add_instance hub_controller altera_streaming_sld_hub_controller
  set_instance_parameter hub_controller ENABLE_JTAG_IO_SELECTION [ get_parameter_value ENABLE_JTAG_IO_SELECTION ]
  add_connection clock_bridge.out_clk hub_controller.clk
  add_connection reset_bridge.out_reset hub_controller.reset

  # internal connections
  add_connection link.h2t fabric.h2t 
  add_connection fabric.t2h link.t2h

  add_connection fabric.h2t_0 hub_controller.sink
  add_connection hub_controller.source fabric.t2h_0

  add_interface s0 avalon end
  set_interface_property s0 export_of link.s0
}

