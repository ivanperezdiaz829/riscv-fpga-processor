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


package provide altera_xcvr_pll_av::interfaces 12.0

package require alt_xcvr::ip_tcl::ip_module
package require alt_xcvr::ip_tcl::messages

namespace eval ::altera_xcvr_pll_av::interfaces:: {
  namespace import ::alt_xcvr::ip_tcl::ip_module::*
  namespace import ::alt_xcvr::ip_tcl::messages::*

  namespace export \
    declare_interfaces \
    elaborate

  variable interfaces

  set interfaces {\
    {NAME                       DIRECTION WIDTH_EXPR              ROLE                      TERMINATION             TERMINATION_VALUE FRAGMENT_LIST IFACE_NAME                IFACE_TYPE  IFACE_DIRECTION ELABORATION_CALLBACK                                            }\
    {pll_powerdown              input     1                       pll_powerdown             false                   NOVAL             rst           pll_powerdown             conduit     end             ::altera_xcvr_pll_av::interfaces::elaborate_direction           }\
    {pll_refclk                 input     refclks                 pll_refclk                false                   NOVAL             refclk        pll_refclk                conduit     end             ::altera_xcvr_pll_av::interfaces::elaborate_pll_refclk          }\
    {pll_fbclk                  input     1                       pll_fbclk                 false                   NOVAL             fbclk         pll_fbclk                 conduit     end             ::altera_xcvr_pll_av::interfaces::elaborate_direction           }\
    \
    {pll_clkout                 output    1                       pll_clkout                false                   NOVAL             outclk        pll_clkout                conduit     end             ::altera_xcvr_pll_av::interfaces::elaborate_direction           }\
    {pll_locked                 output    1                       pll_locked                false                   NOVAL             locked        pll_locked                conduit     end             ::altera_xcvr_pll_av::interfaces::elaborate_direction           }\
    {fboutclk                   output    plls                    fboutclk                  false                    NOVAL            fboutclk      fboutclk                  conduit     end             ::altera_xcvr_pll_av::interfaces::elaborate_fboutclk_hclk       }\
    {hclk                       output    plls                    hclk                      false                    NOVAL            hclk          hclk                      conduit     end             ::altera_xcvr_pll_av::interfaces::elaborate_fboutclk_hclk       }\
    \
    {reconfig_to_xcvr           input     l_rcfg_to_xcvr_width    reconfig_to_xcvr          false                   NOVAL             NOVAL         reconfig_to_xcvr          conduit     end             ::altera_xcvr_pll_av::interfaces::elaborate_direction        }\
    {reconfig_from_xcvr         output    l_rcfg_from_xcvr_width  reconfig_from_xcvr        false                   NOVAL             NOVAL         reconfig_from_xcvr        conduit     end             ::altera_xcvr_pll_av::interfaces::elaborate_direction        }\
  }

}

proc ::altera_xcvr_pll_av::interfaces::declare_interfaces {} {
  variable interfaces
  ip_declare_interfaces $interfaces
}

proc ::altera_xcvr_pll_av::interfaces::elaborate {} {
  ip_elaborate_interfaces
}

proc ::altera_xcvr_pll_av::interfaces::elaborate_pll_refclk { PROP_IFACE_NAME PROP_DIRECTION refclks } {
  ip_set "port.pll_refclk.FRAGMENT_LIST" [list refclk@[expr $refclks - 1]:0]

  ::altera_xcvr_pll_av::interfaces::elaborate_direction  $PROP_IFACE_NAME $PROP_DIRECTION
}

proc ::altera_xcvr_pll_av::interfaces::elaborate_fboutclk_hclk { PROP_IFACE_NAME PROP_DIRECTION plls } {
  ip_set "port.fboutclk.FRAGMENT_LIST" [list fboutclk@[expr $plls - 1]:0]
  ip_set "port.hclk.FRAGMENT_LIST" [list hclk@[expr $plls - 1]:0]
  
  ::altera_xcvr_pll_av::interfaces::elaborate_direction  $PROP_IFACE_NAME $PROP_DIRECTION
}

proc ::altera_xcvr_pll_av::interfaces::elaborate_direction { PROP_IFACE_NAME PROP_DIRECTION } {
  ip_set "interface.${PROP_IFACE_NAME}.assignment" [list "ui.blockdiagram.direction" $PROP_DIRECTION]
}



