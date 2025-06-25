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


package provide altera_xcvr_10gkr_a10::module 13.1

package require alt_xcvr::ip_tcl::ip_module 
package require altera_xcvr_10gkr_a10::parameters
package require altera_xcvr_10gkr_a10::interfaces
package require altera_xcvr_10gkr_a10::fileset

namespace eval ::altera_xcvr_10gkr_a10::module:: {
  namespace import ::alt_xcvr::ip_tcl::ip_module::*

  namespace export \
    declare_module

  # Internal variables
  variable module {\
    {NAME                         VERSION            INTERNAL  ANALYZE_HDL EDITABLE  ELABORATION_CALLBACK                              DISPLAY_NAME                                    GROUP                           AUTHOR                DESCRIPTION                    DATASHEET_URL                                             }\
    {altera_xcvr_10gkr_a10   13.1  true      false       false     ::altera_xcvr_10gkr_a10::module::elaborate   "Arria 10 1G/10GbE and 10GBASE-KR PHY"       "Interface Protocols/Ethernet"  "Altera Corporation"  "1G/10GE and 10GBASE-KR PHY"  "http://www.altera.com/literature/ug/xcvr_user_guide.pdf" }\
  }
}


proc ::altera_xcvr_10gkr_a10::module::declare_module {} {
  variable module
  ip_declare_module $module
  ::altera_xcvr_10gkr_a10::fileset::declare_filesets
  ::altera_xcvr_10gkr_a10::parameters::declare_parameters
  ::altera_xcvr_10gkr_a10::interfaces::declare_interfaces
}

proc ::altera_xcvr_10gkr_a10::module::elaborate {} {
  ::altera_xcvr_10gkr_a10::fileset::generate_native_phy
  ::altera_xcvr_10gkr_a10::parameters::validate
  ::altera_xcvr_10gkr_a10::interfaces::elaborate
}

