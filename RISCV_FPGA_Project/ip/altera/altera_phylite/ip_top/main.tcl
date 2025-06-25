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


package provide altera_phylite::ip_top::main 0.1

package require altera_emif::util::messaging
package require altera_emif::util::qini
package require altera_emif::util::hwtcl_utils
package require altera_emif::util::enums
package require altera_phylite::util::enum_defs
package require altera_emif::util::device_family
package require altera_phylite::ip_top::general
package require altera_phylite::ip_top::group

namespace eval ::altera_phylite::ip_top::main:: {
   
   namespace import ::altera_emif::util::messaging::*
   namespace import ::altera_emif::util::qini::*
   namespace import ::altera_emif::util::enums::*
   namespace import ::altera_phylite::util::enum_defs
   namespace import ::altera_emif::util::hwtcl_utils::*
   namespace import ::altera_emif::util::device_family::*

   variable max_num_groups 12
}


proc ::altera_phylite::ip_top::main::create_parameters {} {
   variable max_num_groups

   altera_emif::util::device_family::create_parameters
   
   add_user_param     PHYLITE_NUM_GROUPS                    integer   1                    {1:12}

   
   ::altera_emif::util::hwtcl_utils::_add_parameter SYS_INFO_UNIQUE_ID string ""
   set_parameter_property SYS_INFO_UNIQUE_ID SYSTEM_INFO UNIQUE_ID
   set_parameter_property SYS_INFO_UNIQUE_ID VISIBLE false   
   
   

   
   ::altera_phylite::ip_top::general::create_parameters
   for { set i 0 } { $i < ${max_num_groups} } {incr i } {
      ::altera_phylite::ip_top::group::create_parameters $i
   }

   return 1
}

proc ::altera_phylite::ip_top::main::add_display_items {} {
   variable max_num_groups

   set general_tab [get_string TAB_GENERAL_NAME]

   set grp_tab_prefix [get_string TAB_GRP_NAME]
   set grp_tabs [list]
   for { set i 0 } { $i < ${max_num_groups} } {incr i } {
      lappend grp_tabs "${grp_tab_prefix}${i}"
   }

   add_display_item "" "Block Diagram" GROUP

   add_param_to_gui "" GUI_NUM_GROUPS

   add_display_item "" $general_tab GROUP tab
   for { set i 0 } { $i < ${max_num_groups} } {incr i } {
      add_display_item "" [lindex $grp_tabs $i] GROUP tab
   }
   
   ::altera_phylite::ip_top::general::add_display_items [list $general_tab]
   for { set i 0 } { $i < ${max_num_groups} } {incr i } {
       ::altera_phylite::ip_top::group::add_display_items [list [lindex $grp_tabs $i]] $i
   }

   return 1
}

proc ::altera_phylite::ip_top::main::composition_callback {} {

   _validate

   
   if {[has_pending_ipgen_e_msg]} {
      issue_pending_ipgen_e_msg_and_terminate
   } else {
      _compose
      
      issue_pending_ipgen_e_msg_and_terminate
   }
}


proc ::altera_phylite::ip_top::main::_validate {} {
   variable max_num_groups

   ::altera_emif::util::device_family::load_data
   
   _update_range_parameters

   set num_groups [get_parameter_value PHYLITE_NUM_GROUPS]

   set grp_tab_prefix [get_string TAB_GRP_NAME]
   for { set i 0 } { $i < ${max_num_groups} } {incr i } {
      if { $i < ${num_groups} } {
         set_display_item_property "${grp_tab_prefix}$i" VISIBLE true
      } else {
         set_display_item_property "${grp_tab_prefix}$i" VISIBLE false
      }
   }
   
   ::altera_phylite::ip_top::general::validate
   for { set i 0 } { $i < ${max_num_groups} } {incr i } {
      if { $i < ${num_groups} } {
         ::altera_phylite::ip_top::group::validate $i true
      } else {
         ::altera_phylite::ip_top::group::validate $i false
      }
   }
      
   return [expr {![has_pending_ipgen_e_msg]}]
}

proc ::altera_phylite::ip_top::main::_compose {} {

   set core_component altera_phylite_arch_nf
   set core_name "core"
   
   add_instance $core_name $core_component
   
   foreach param_name [get_parameters] {
      set param_val [get_parameter_value $param_name]
      set_instance_parameter_value $core_name $param_name $param_val
   }
   
   altera_emif::util::hwtcl_utils::export_all_interfaces_of_sub_component $core_name
   
   return 1
}

proc ::altera_phylite::ip_top::main::_update_range_parameters {} {
}

proc ::altera_phylite::ip_top::main::_get_protocol_list {} {
   set retval [list]
   
   foreach protocol_enum [enums_of_type PROTOCOL] {
      if { [get_feature_support_level FEATURE_EMIF $protocol_enum] != 0 } {
         lappend retval [enum_dropdown_entry $protocol_enum]
      }
   }
   return $retval
}

proc ::altera_phylite::ip_top::main::_init {} {
}

::altera_phylite::ip_top::main::_init
