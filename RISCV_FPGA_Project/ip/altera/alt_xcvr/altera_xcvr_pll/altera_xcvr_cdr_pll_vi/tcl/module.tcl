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



package provide altera_xcvr_cdr_pll_vi::module 13.1

package require alt_xcvr::ip_tcl::ip_module
package require altera_xcvr_cdr_pll_vi::parameters
package require altera_xcvr_cdr_pll_vi::interfaces
package require altera_xcvr_cdr_pll_vi::fileset

namespace eval ::altera_xcvr_cdr_pll_vi::module:: {
  namespace import ::alt_xcvr::ip_tcl::ip_module::*

  namespace export \
    declare_module 

  # Internal variables
  variable module {\
    {NAME                    VERSION                 SUPPORTED_DEVICE_FAMILIES     INTERNAL  ANALYZE_HDL EDITABLE  ELABORATION_CALLBACK                          DISPLAY_NAME                   GROUP    AUTHOR                DESCRIPTION DATASHEET_URL                                               DESCRIPTION      }\
    {altera_xcvr_cdr_pll_a10  13.1  { "Arria VI" "Arria 10" }     true      false       false     ::altera_xcvr_cdr_pll_vi::module::elaborate  "Arria 10 Transceiver CMU PLL"  "PLL"    "Altera Corporation"  NOVAL       "http://www.altera.com/literature/ug/xcvr_user_guide.pdf"   "Arria 10 Transceiver CMU PLL."}\
  }
}


proc ::altera_xcvr_cdr_pll_vi::module::declare_module {} {
  variable module
  ip_declare_module $module
  ::altera_xcvr_cdr_pll_vi::fileset::declare_filesets
  ::altera_xcvr_cdr_pll_vi::parameters::declare_parameters
  ::altera_xcvr_cdr_pll_vi::interfaces::declare_interfaces
}

proc ::altera_xcvr_cdr_pll_vi::module::elaborate {} {
  ::altera_xcvr_cdr_pll_vi::parameters::validate
  ::altera_xcvr_cdr_pll_vi::interfaces::elaborate
}

