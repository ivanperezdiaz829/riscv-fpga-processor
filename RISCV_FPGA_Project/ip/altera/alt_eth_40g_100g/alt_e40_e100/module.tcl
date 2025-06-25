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


package provide alt_e40_e100::module 13.0

package require alt_xcvr::ip_tcl::ip_module 12.1
package require alt_e40_e100::parameters
package require alt_e40_e100::interfaces
package require alt_e40_e100::fileset

namespace eval ::alt_e40_e100::module:: {
  namespace import ::alt_xcvr::ip_tcl::ip_module::*

  namespace export \
    declare_module

  # Internal variables
  variable module {\
    {NAME                       VERSION                 INTERNAL  ANALYZE_HDL EDITABLE  ELABORATION_CALLBACK                            PARAMETER_UPGRADE_CALLBACK                               DISPLAY_NAME                        GROUP                                 AUTHOR                           DESCRIPTION DATASHEET_URL                                             }\
    {alt_e40_e100               13.1  true      true        true      ::alt_e40_e100::module::elaborate               ::alt_e40_e100::module::upgrade_callback                 "40G/100G Ethernet"                 "Interface Protocols/High Speed"      "Altera Corporation"             "http://www.altera.com/literature/ug/ug_40_100gbe.pdf" }\
  }
}


proc ::alt_e40_e100::module::declare_module {} {
  variable module
  ip_declare_module $module
  ::alt_e40_e100::fileset::declare_filesets
  ::alt_e40_e100::parameters::declare_parameters
  ::alt_e40_e100::interfaces::declare_interfaces
}

proc ::alt_e40_e100::module::elaborate {} {
  ::alt_e40_e100::parameters::validate
  ::alt_e40_e100::interfaces::elaborate
  ::alt_e40_e100::fileset::add_instances
}

#+--------------------------------
#| UPGRADE CALLBACK
#|
proc ::alt_e40_e100::module::upgrade_callback {ip_core_type version parameters} {
	if {$ip_core_type == "alt_e40_e100"} {
		set my_parameters [get_parameters]
		if {$version == "12.1"} {
			foreach { name value } $parameters {
				if {$name == "STATUS_CLK_KHZ_SIV"} {
					set_parameter_value $name [expr double($value) / 1000.0]
				} elseif {$name == "STATUS_CLK_KHZ_SV"} {
					set_parameter_value $name [expr double($value) / 1000.0]
				} elseif {$name == "ENABLE_STATISTICS_CNTR"} {
					if {$value == "true"} {
						set_parameter_value $name 1
					} else {
						set_parameter_value $name 0
					}
				} elseif {[lsearch $my_parameters $name] == -1} {
					# If the parameter no longer exists and is not applicable, then do nothing
				} else {
					# if the parameter exists and interpretation has not changed, then set it directly
					set_parameter_value $name $value 
				}
			}
		} elseif {$version == "13.0"} {
			foreach { name value } $parameters {
				 if {$name == "ENABLE_STATISTICS_CNTR"} {
					if {$value == "true"} {
							set_parameter_value $name 1
					} else {
							set_parameter_value $name 0
					}
				} elseif {[lsearch $my_parameters $name] == -1} {
					# If the parameter no longer exists and is not applicable, then do nothing
				} else {
					# if the parameter exists and interpretation has not changed, then set it directly
					set_parameter_value $name $value
				}
			}
		}
	}	
}