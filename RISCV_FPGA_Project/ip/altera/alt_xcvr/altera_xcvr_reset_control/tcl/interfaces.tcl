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


package provide altera_xcvr_reset_control::interfaces 12.0

package require alt_xcvr::ip_tcl::ip_module
package require alt_xcvr::ip_tcl::messages

namespace eval ::altera_xcvr_reset_control::interfaces:: {
  namespace import ::alt_xcvr::ip_tcl::ip_module::*
  namespace import ::alt_xcvr::ip_tcl::messages::*

  namespace export \
    declare_interfaces \
    elaborate

  variable interfaces

  set interfaces {\
    {NAME               DIRECTION WIDTH_EXPR          ROLE                TERMINATION           TERMINATION_VALUE SPLIT                 SPLIT_COUNT SPLIT_WIDTH         IFACE_NAME          IFACE_TYPE  IFACE_DIRECTION DYNAMIC ELABORATION_CALLBACK  }\
    {clock              input     1                   clk                 NOVAL                 NOVAL             NOVAL                 NOVAL       NOVAL               clock               clock       sink            false   NOVAL                 }\
    {reset              input     1                   reset               NOVAL                 NOVAL             NOVAL                 NOVAL       NOVAL               reset               reset       sink            false   ::altera_xcvr_reset_control::interfaces::elaborate_reset      }\
    \
    {pll_powerdown      output    PLLS                pll_powerdown       l_terminate_pll       NOVAL             gui_split_interfaces  PLLS        1                   pll_powerdown       conduit     end             true    ::altera_xcvr_reset_control::interfaces::elaborate_direction  }\
    \
    {tx_analogreset     output    CHANNELS            tx_analogreset      l_terminate_tx        NOVAL             gui_split_interfaces  CHANNELS    1                   tx_analogreset      conduit     end             true    ::altera_xcvr_reset_control::interfaces::elaborate_direction  }\
    {tx_digitalreset    output    CHANNELS            tx_digitalreset     l_terminate_tx        NOVAL             gui_split_interfaces  CHANNELS    1                   tx_digitalreset     conduit     end             true    ::altera_xcvr_reset_control::interfaces::elaborate_direction  }\
    {tx_ready           output    CHANNELS            tx_ready            l_terminate_tx        NOVAL             gui_split_interfaces  CHANNELS    1                   tx_ready            conduit     end             true    ::altera_xcvr_reset_control::interfaces::elaborate_direction  }\
    {pll_locked         input     PLLS                pll_locked          l_terminate_tx        NOVAL             gui_split_interfaces  CHANNELS    1                   pll_locked          conduit     end             true    ::altera_xcvr_reset_control::interfaces::elaborate_direction  }\
    {pll_select         input     l_pll_select_width  pll_select          l_terminate_tx        NOVAL             l_pll_select_split    CHANNELS    l_pll_select_base   pll_select          conduit     end             true    ::altera_xcvr_reset_control::interfaces::elaborate_direction  }\
    {tx_cal_busy        input     CHANNELS            tx_cal_busy         l_terminate_tx        NOVAL             gui_split_interfaces  CHANNELS    1                   tx_cal_busy         conduit     end             true    ::altera_xcvr_reset_control::interfaces::elaborate_direction  }\
    {tx_manual          input     CHANNELS            tx_reset_mode       l_terminate_tx_manual l_tx_manual_term  gui_split_interfaces  CHANNELS    1                   tx_reset_mode       conduit     end             true    ::altera_xcvr_reset_control::interfaces::elaborate_direction  }\
    \
    {rx_analogreset     output    CHANNELS            rx_analogreset      l_terminate_rx        NOVAL             gui_split_interfaces  CHANNELS    1                   rx_analogreset      conduit     end             true    ::altera_xcvr_reset_control::interfaces::elaborate_direction  }\
    {rx_digitalreset    output    CHANNELS            rx_digitalreset     l_terminate_rx        NOVAL             gui_split_interfaces  CHANNELS    1                   rx_digitalreset     conduit     end             true    ::altera_xcvr_reset_control::interfaces::elaborate_direction  }\
    {rx_ready           output    CHANNELS            rx_ready            l_terminate_rx        NOVAL             gui_split_interfaces  CHANNELS    1                   rx_ready            conduit     end             true    ::altera_xcvr_reset_control::interfaces::elaborate_direction  }\
    {rx_is_lockedtodata input     CHANNELS            rx_is_lockedtodata  l_terminate_rx        NOVAL             gui_split_interfaces  CHANNELS    1                   rx_is_lockedtodata  conduit     end             true    ::altera_xcvr_reset_control::interfaces::elaborate_direction  }\
    {rx_cal_busy        input     CHANNELS            rx_cal_busy         l_terminate_rx        NOVAL             gui_split_interfaces  CHANNELS    1                   rx_cal_busy         conduit     end             true    ::altera_xcvr_reset_control::interfaces::elaborate_direction  }\
    {rx_manual          input     CHANNELS            rx_reset_mode       l_terminate_rx_manual l_rx_manual_term  gui_split_interfaces  CHANNELS    1                   rx_reset_mode       conduit     end             true    ::altera_xcvr_reset_control::interfaces::elaborate_direction  }\
    \
    {tx_digitalreset_or input     CHANNELS            tx_digitalreset_or  true                  NOVAL             false                 CHANNELS    1                   tx_digitalreset_or  conduit     end             true    ::altera_xcvr_reset_control::interfaces::elaborate_direction  }\
    {rx_digitalreset_or input     CHANNELS            rx_digitalreset_or  true                  NOVAL             false                 CHANNELS    1                   rx_digitalreset_or  conduit     end             true    ::altera_xcvr_reset_control::interfaces::elaborate_direction  }\
  }

}

proc ::altera_xcvr_reset_control::interfaces::declare_interfaces {} {
  variable interfaces
  ip_declare_interfaces $interfaces
}

proc ::altera_xcvr_reset_control::interfaces::elaborate {} {
  ip_elaborate_interfaces
}

proc ::altera_xcvr_reset_control::interfaces::elaborate_reset {} {
  ip_set "interface.reset.synchronousEdges" NONE
}

proc ::altera_xcvr_reset_control::interfaces::elaborate_direction { PROP_IFACE_NAME PROP_DIRECTION } {
  ip_set "interface.${PROP_IFACE_NAME}.assignment" [list "ui.blockdiagram.direction" $PROP_DIRECTION]
}


