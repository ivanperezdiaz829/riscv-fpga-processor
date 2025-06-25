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



#!!!!!!!!!!!!!!!!!!!!!!!! DEPRECATED !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# NOTE - This file has been deprecated. It is kept to maintain backwards
# compatibility but should no longer be used. Use the needed TCL packages
# accordingly
set alt_xcvr_packages_dir "$env(QUARTUS_ROOTDIR)/../ip/altera/alt_xcvr/alt_xcvr_tcl_packages"
if { [lsearch -exact $auto_path $alt_xcvr_packages_dir] == -1 } {
  lappend auto_path $alt_xcvr_packages_dir
}

package require alt_xcvr::utils::common
package require alt_xcvr::utils::device
package require alt_xcvr::utils::fileset
package require alt_xcvr::utils::params_and_ports
package require alt_xcvr::gui::messages

namespace import ::alt_xcvr::utils::device::*
namespace import ::alt_xcvr::utils::fileset::*
namespace import ::alt_xcvr::utils::params_and_ports::*


#!!!!!!!!!!!!!!!!!!!!!!!! DEPRECATED !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
proc common_get_reconfig_to_xcvr_width { fam } {
  return [::alt_xcvr::utils::device::get_reconfig_to_xcvr_width $fam]
}
proc common_get_reconfig_from_xcvr_width { fam } {
  return [::alt_xcvr::utils::device::get_reconfig_from_xcvr_width $fam]
}
proc common_get_reconfig_interface_count { fam channels tx_plls } {
  return [::alt_xcvr::utils::device::get_reconfig_interface_count $fam $channels $tx_plls]
}
proc common_get_reconfig_to_xcvr_total_width { fam reconfig_interfaces } {
  return [::alt_xcvr::utils::device::get_reconfig_to_xcvr_total_width $fam $reconfig_interfaces]
}
proc common_get_reconfig_from_xcvr_total_width { fam reconfig_interfaces } {
  return [::alt_xcvr::utils::device::get_reconfig_from_xcvr_total_width $fam $reconfig_interfaces]
}
proc common_map_allowed_range { gui_param_name legal_values } {
  return [::alt_xcvr::utils::common::map_allowed_range $gui_param_name $legal_values]
}
proc common_get_mapped_allowed_range_value { gui_param_name } {
  return [::alt_xcvr::utils::common::get_mapped_allowed_range_value $gui_param_name]
}
proc common_display_reconfig_interface_message { fam channels tx_plls } {
  return [::alt_xcvr::gui::messages::reconfig_interface_message $fam $channels $tx_plls]
}

