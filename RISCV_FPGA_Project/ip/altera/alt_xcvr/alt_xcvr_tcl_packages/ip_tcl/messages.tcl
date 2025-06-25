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


package provide alt_xcvr::ip_tcl::messages 13.1

package require alt_xcvr::ip_tcl::ip_module
package require alt_xcvr::utils::common

namespace eval ::alt_xcvr::ip_tcl::messages:: {
  namespace export \
    ip_message \
    internal_error \
    module_exists \
    module_not_exist \
    set_auto_message_level \
    set_message_filter_criteria \
    set_mapping_enabled \
    set_deferred_messaging \
    get_invalid_current_value_string \
    get_invalid_antecedents_string \
    invalid_value_message \
    auto_invalid_value_message \
    auto_invalid_string_number_format_message \
    auto_value_out_of_range_message

  # Declare internal variables
  variable package_name
  variable l_auto_message_level
  variable l_mapping
  variable l_message_filter_criteria
  variable l_deferred_messaging
  variable l_deferred_message_list

  # Initialize internal variables
  set package_name "alt_xcvr::ip_tcl::messages"
  set l_auto_message_level "error"
  set l_mapping 0
  set l_message_filter_criteria {ENABLED 1 DERIVED 0}
  set l_deferred_messaging 0
  set l_deferred_message_list {}
}

proc ::alt_xcvr::ip_tcl::messages::ip_message { level message_string } {
  # TODO - added catch to workaround QSys 12.1 bug. Will remove later
  catch {
    send_message $level $message_string
  }
  #puts "$level $message_string"

}

proc ::alt_xcvr::ip_tcl::messages::internal_error { message_string } {
  set message_string "INTERNAL ERROR: $message_string" 
  ip_message error $message_string
}


proc ::alt_xcvr::ip_tcl::messages::module_exists { module_name {context ""} } {
  internal_error "Module ${module_name} already exist. ${context}"
}


proc ::alt_xcvr::ip_tcl::messages::module_not_exist {module_name {context ""} } {
  internal_error "Module ${module_name} does not exist. ${context}"
}


#****************************************************************************
#******************* Message creation utility functions *********************
proc ::alt_xcvr::ip_tcl::messages::set_auto_message_level { auto_message_level } {
  variable package_name
  variable l_auto_message_level
  if {$auto_message_level == "warning" || $auto_message_level == "error"} {
    set l_auto_message_level $auto_message_level
  } else {
    internal_error "\[::${package_name}::set_auto_message_level\] Illegal argument value: auto_message_level=${auto_message_level}"
  }
}


###
# Sets the message filtering criteria. This controls which messages will be allowed to be displayed
# by the invalid_value_message and auto_invalid_value_message procedures.
#
# @param new_criteria - A list of attribute value pairs. For a given parameter, the associated
#   attributes must match their indicated values or the message for that parameter will be blocked.
#   For example, the default criteria for a parameter's message to be displayed is that it must
#   be enabled AND not derived. The criteria list is thus {ENABLED 1 DERIVED 0}
proc ::alt_xcvr::ip_tcl::messages::set_message_filter_criteria { new_criteria } {
  variable l_message_filter_criteria

  set l_message_filter_criteria $new_criteria
}


proc ::alt_xcvr::ip_tcl::messages::set_mapping_enabled { enabled } {
  variable package_name
  variable l_mapping

  if {$enabled == "0" || $enabled == "1"} {
    set l_mapping $enabled
  } else {
    internal_error "\[::${package_name}::set_mapping_enabled\] Illegal argument value: enabled=${enabled}"
  }
}


###
# Enables or disables deferred messaging. With deferred messaging,
# auto messages are collected and can then be issued at a later time
# using the issue_deferred_messages API
proc ::alt_xcvr::ip_tcl::messages::set_deferred_messaging { enabled } {
  variable package_name
  variable l_deferred_messaging

  if {$enabled == "0" || $enabled == "1"} {
    set l_deferred_messaging $enabled
  } else {
    internal_error "\[::${package_name}::set_deferred_messaging\] Illegal argument value: enabled=${enabled}"
  }
}


proc ::alt_xcvr::ip_tcl::messages::get_invalid_current_value_string { param_name param_value } {
  set message "The current value [get_value_display_string $param_name $param_value] for parameter <b>\"[::alt_xcvr::ip_tcl::ip_module::ip_get "parameter.${param_name}.display_name"]\"</b> (${param_name}) is invalid."
}


proc ::alt_xcvr::ip_tcl::messages::get_value_display_string { param_name param_value } {
  set disp_val [get_mapped_display_hint_string $param_name $param_value]
  set val_string "<b>\"${disp_val}\"</b>"
  if {$disp_val != $param_value} {
    set val_string "${val_string} (${param_value})"
  }

  return $val_string
}

proc ::alt_xcvr::ip_tcl::messages::get_mapped_display_hint_string { param_name param_value } {
  set display_hint [string toupper [::alt_xcvr::ip_tcl::ip_module::ip_get "parameter.${param_name}.display_hint"]]
  if { $display_hint == "HEXADECIMAL" } {
    set param_value [subst [regsub -all {[0-9]+} $param_value {0x[format %lX "&"]}]]
  } elseif { $display_hint == "BOOLEAN" } {
    if { $param_value } {
      set param_value "enabled"
    } else {
      set param_value "disabled"
    }
  } else {
    set param_value [get_param_display_value $param_name $param_value]
  }

  return $param_value
}


proc ::alt_xcvr::ip_tcl::messages::get_param_display_value { param_name param_value } {
  set ranges [::alt_xcvr::ip_tcl::ip_module::ip_get "parameter.${param_name}.allowed_ranges"]

  foreach value $ranges {
    set mapping [split $value ":"]
    if {[lindex $mapping 0] == $param_value} {
      if {[llength $mapping] == 2} {
        return [lindex $mapping 1]
      } else {
        return $param_value
      }
    }
  }

}


proc ::alt_xcvr::ip_tcl::messages::get_invalid_antecedents_string { {antecedents {}} } {
  set message ""
  if { [llength $antecedents] > 0 } {
    set message "${message} The parameter value is invalid under these current parameter settings: "
    set index 0
    foreach ant $antecedents {
      if {$index != 0} {
        set message "$message &&"
      }
      set param_value [::alt_xcvr::ip_tcl::ip_module::ip_get "parameter.${ant}.value"]
      set message "${message} <b>\"[::alt_xcvr::ip_tcl::ip_module::ip_get "parameter.${ant}.display_name"]\"</b> (${ant})=[get_value_display_string $ant $param_value]"
      incr index
    }
  }
  return $message
}


proc ::alt_xcvr::ip_tcl::messages::invalid_value_message { message_level param_name param_value param_legal_values {antecedents {} } {rules {} } } {
  # Add invalid string for current value
  set message [get_invalid_current_value_string $param_name $param_value]

  # Add list of legal values
  if {[llength $param_legal_values] > 0} {
    set message "${message} Possible valid values are:"
    foreach str $param_legal_values {
      # Add value to string
      set message "${message} [get_value_display_string $param_name $str]"
    }
    set message "${message}."
  }

  # Add list of antecedents
  set message "${message} [get_invalid_antecedents_string $antecedents]"
  if {[llength $rules] != 0} {
    set message "${message}. Rule(s)"
    foreach rule $rules {
      set message "${message}: $rule"
    }
    set message "${message}."
  }

  ip_message $message_level $message
}


proc ::alt_xcvr::ip_tcl::messages::auto_invalid_value_message_internal { message_level param_name param_value param_legal_values {antecedents {} } } {
  variable l_mapping
  variable l_message_filter_criteria
  variable l_auto_message_level
  variable l_deferred_messaging
  variable l_deferred_message_list

  if { $message_level == "auto" } {
    set message_level $l_auto_message_level
  }
  
  set rule_name $param_name
  # If mapping is enabled, perform the necessary mapping here
  if {$l_mapping} {
    # Get the mapped parameter name in the UI
    set maps_from [::alt_xcvr::ip_tcl::ip_module::ip_get_mapped_parameter_name $param_name 1]
    # Get the current value of the mapped parameter
    set maps_from_value [::alt_xcvr::ip_tcl::ip_module::ip_get "parameter.${maps_from}.value"]
    # Get the list of mapped legal values
    set maps_from_legal_values [::alt_xcvr::ip_tcl::ip_module::ip_get_mapped_from_values_recursive $param_name $param_legal_values]
  
    # Get the list of mapped antecedents
    set mapped_antecedents {}
    foreach ant $antecedents {
      lappend mapped_antecedents [::alt_xcvr::ip_tcl::ip_module::ip_get_mapped_parameter_name $ant 1]
    }
    set param_name $maps_from
    set param_value $maps_from_value
    set param_legal_values $maps_from_legal_values
    set antecedents $mapped_antecedents
  }

  # We only display messages for parameters that match the filtering criteria
  foreach {attrib attrib_val} $l_message_filter_criteria {
    if { [::alt_xcvr::ip_tcl::ip_module::ip_get "parameter.${param_name}.${attrib}"] != $attrib_val } {
      return
    }
  }
  
  # Filter antecedents
  # We only display antecedents that the user can control (parameter is enabled)
  set filtered_antecedents {}
  foreach ant $antecedents {
    if { [::alt_xcvr::ip_tcl::ip_module::ip_get "parameter.${ant}.enabled"] && \
        ![::alt_xcvr::ip_tcl::ip_module::ip_get "parameter.${ant}.derived"] } {
      lappend filtered_antecedents $ant
    } else {
      puts "\[auto_invalid_value_message_internal\] : Not reporting derived antecedent \"${ant}\""
    }
  }
  
  if {$l_deferred_messaging} {
    dict set l_deferred_message_list $param_name $rule_name param_value $param_value
    dict set l_deferred_message_list $param_name $rule_name param_legal_values $param_legal_values
    dict set l_deferred_message_list $param_name $rule_name param_antecedents $filtered_antecedents
    dict set l_deferred_message_list $param_name $rule_name message_level $message_level
  } else {
    invalid_value_message $message_level $param_name $param_value $param_legal_values $filtered_antecedents [list $rule_name]
  }
}


proc ::alt_xcvr::ip_tcl::messages::auto_invalid_value_message { message_level param_name param_value param_legal_values {antecedents {} } } {

  if { [lsearch $param_legal_values $param_value] == -1 } {
    auto_invalid_value_message_internal $message_level $param_name $param_value $param_legal_values $antecedents
  }
}


proc ::alt_xcvr::ip_tcl::messages::auto_invalid_string_number_format_message { message_level param_name param_value radix max_size {antecedents {} } } {
  variable l_auto_message_level
  # Legality test
  set illegal [expr [::alt_xcvr::utils::common::is_string_numeric $param_value $radix] == 0]
  if {!$illegal} {
    set illegal [expr {[::alt_xcvr::utils::common::get_numeric_string_size $param_value $radix] > $max_size}]
  }

  # Display message if value is illegal
  if { $illegal } {
    if { $message_level == "auto" } {
      set message_level $l_auto_message_level
    }
    # Get formated illegal value message
    set radix_str [expr {$radix == "dec" ? "decimal"
      : $radix == "hex" ? "hexadecimal"
        : $radix == "bin" ? "binary"
          : "unknown" }]

    set message [get_invalid_current_value_string $param_name $param_value]
    set message "${message} The value must be specified in ${radix_str} format and represent a number no more than ${max_size} bits in length."
    set message "${message} [get_invalid_antecedents_string $antecedents]"
    ip_message $message_level $message
  }

}

proc ::alt_xcvr::ip_tcl::messages::auto_value_out_of_range_message { message_level param_name param_value param_legal_values {antecedents {} } } {
  # See if the value is within the specified range
  foreach range $param_legal_values {
    set min_max [split $range ":"]
    set min [lindex $min_max 0]
    set max $min
    if {[llength $min_max] == 2} {
      set max [lindex $min_max 1]
    }
    if {$param_value <= $max && $param_value >= $min} {
      # The value is legal. Return
      return
    }
  }

  auto_invalid_value_message_internal $message_level $param_name $param_value $param_legal_values $antecedents
}


proc ::alt_xcvr::ip_tcl::messages::issue_deferred_messages { } {
  variable l_deferred_messaging
  variable l_deferred_message_list
  if {!$l_deferred_messaging} {
    internal_error "\[::${package_name}::issue_deferred_messages\] Deferred messaging not enabled!"
    return
  }

  # Iterate over each parameter
  dict for {param rules} $l_deferred_message_list {
    # Iterate over each rule
    set rule_list {}
    set param_value ""
    set message_level_list {}
    set param_legal_values_list {}
    set param_antecedents_list {}
    set index 0
    # Intersect all the rules for this parameter
    dict for {rule values} $rules {
      set param_value [dict get $values param_value]
      set legal_values [dict get $values param_legal_values]
      if {$index == 0} {
        set param_legal_values_list $legal_values
      } else {
        set param_legal_values_list [::alt_xcvr::utils::common::intersect $param_legal_values_list $legal_values]
      }

      # Append rule to list
      lappend rule_list $rule
      # Append message level to list
      lappend message_level_list [dict get $values message_level]
      # Append antecedents to list
      foreach ant [dict get $values param_antecedents] {
        if {[lsearch $param_antecedents_list $ant] == -1} {
          lappend param_antecedents_list $ant
        }
      }
      incr index
    }

    set message_level [get_highest_priority_message_level $message_level_list]
    invalid_value_message $message_level $param $param_value $param_legal_values_list $param_antecedents_list $rule_list
  }

  set l_deferred_message_list [dict create]
}


proc ::alt_xcvr::ip_tcl::messages::get_highest_priority_message_level {message_level_list} {
  set message_level "info"

  foreach level $message_level_list {
    set level [string tolower $level]
    if {$level == "error" || ($level == "warning" && $message_level == "info")} {
      set message_level $level
    }
  }
  return $message_level
}
#***************** End message creation utility functions *******************
#****************************************************************************
