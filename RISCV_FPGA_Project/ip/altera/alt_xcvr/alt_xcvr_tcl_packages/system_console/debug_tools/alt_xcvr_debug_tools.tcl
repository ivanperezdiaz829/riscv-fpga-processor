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


package provide alt_xcvr::system_console::alt_xcvr_debug_tools 13.1

package require alt_xcvr::utils::device
package require alt_xcvr::system_console::alt_xcvr_reconfig_if

namespace eval ::alt_xcvr::system_console::alt_xcvr_debug_tools:: {
  namespace export \
    start

  variable dash
  variable param_data
} 

proc ::alt_xcvr::system_console::alt_xcvr_debug_tools::start {} {
  variable dash

  set name [expr { rand() } ]
  set dash [add_service dashboard "alt_xcvr_debug_tools_dash${name}" "Transceiver Debug Tools${name}" "Tools/Transceiver Debug Tools${name}"]
  build_param_data

  setup_main_page
  setup_param_tab
  setup_register_tab

  # Select JTAG master
  ::alt_xcvr::system_console::alt_xcvr_reconfig_if::use_default_master
  open_service master [lindex [get_service_paths master] 0]
  
}


proc ::alt_xcvr::system_console::alt_xcvr_debug_tools::build_param_data {} {
  variable param_data

  set regmap [::alt_xcvr::utils::device::get_arria10_regmap {pcs pma}]
  dict for {param attrib_values} $regmap {
    dict for {attrib_value offsets} $attrib_values {
      dict for {this_offset bit_offsets} $offsets {
        dict for {this_bit_offset bit_value} $bit_offsets {
          set is_direct [expr {$attrib_value == "DIRECT MAPPED"}]
          set bit_val_info [build_bit_val_info $is_direct $this_bit_offset $bit_value]
          dict set param_data $param $attrib_value $this_offset $this_bit_offset $bit_val_info
          dict set param_data $param $attrib_value $this_offset $this_bit_offset bit_value $bit_value
        }
      }
    }
  }
}


proc ::alt_xcvr::system_console::alt_xcvr_debug_tools::setup_main_page {} {
  variable dash

  dashboard_set_property $dash self itemsPerRow 1

  dashboard_add $dash general_group group self
  dashboard_set_property $dash general_group title "General options"
  dashboard_set_property $dash general_group itemsPerRow 3

  dashboard_add $dash general_group_address_label label general_group
  dashboard_set_property $dash general_group_address_label text "Address offset of PLL or channel from debug master starting address (HEX):"

  dashboard_add $dash general_group_address_textfield textField general_group
  dashboard_set_property $dash general_group_address_textfield text "0x00000000"

  # Add tab group
  dashboard_add $dash main_tabs tabbedGroup self
}


proc ::alt_xcvr::system_console::alt_xcvr_debug_tools::setup_param_tab {} {
  variable dash
  variable param_data

  # Add group to tab
  dashboard_add $dash param_tab_group group main_tabs
  dashboard_set_property $dash param_tab_group itemsPerRow 4
  dashboard_set_property $dash param_tab_group title "Parameters"
  dashboard_set_property $dash param_tab_group expandableY 1

  # Add header row
  dashboard_add $dash "param_header_label" label param_tab_group
  dashboard_set_property $dash "param_header_label" text "Atom Parameter"

  dashboard_add $dash "param_values_header_label" label param_tab_group
  dashboard_set_property $dash "param_values_header_label" text "Parameter Values"

  # Add a "get all" button
  dashboard_add $dash "param_values_button_get_all" button param_tab_group
  dashboard_set_property $dash "param_values_button_get_all" text "Get all"
  dashboard_set_property $dash "param_values_button_get_all" onClick {::alt_xcvr::system_console::alt_xcvr_debug_tools::action_params_get_all}

  # Add a "set all" button
  dashboard_add $dash "param_values_button_set_all" button param_tab_group
  dashboard_set_property $dash "param_values_button_set_all" text "Set all"
  dashboard_set_property $dash "param_values_button_set_all" onClick {::alt_xcvr::system_console::alt_xcvr_debug_tools::action_params_set_all}

  # Add a row for each parameter
  dict for {param attrib_values} $param_data {
    dashboard_add $dash "${param}_label" label param_tab_group
    dashboard_set_property $dash "${param}_label" text "${param}:"

    # Build possible value list
    set attrib_list {}
    dict for {attrib_value offsets} $attrib_values {
      lappend attrib_list $attrib_value
    }
    if {[lindex $attrib_list 0] == "DIRECT MAPPED"} {
      dashboard_set_property $dash "${param}_label" text "${param} (HEX):"
      # Add a text field for this parameter (direct mapped)
      dashboard_add $dash "${param}_textfield" textField param_tab_group
      dashboard_set_property $dash "${param}_textfield" expandableX 1
      dashboard_set_property $dash "${param}_textfield" text "0x0"
    } else {
      # Add a dropdown for this parameter
      dashboard_add $dash "${param}_combo" comboBox param_tab_group
      dashboard_set_property $dash "${param}_combo" options $attrib_list
    }

    # Add a "get" button
    dashboard_add $dash "${param}_button_get" button param_tab_group
    dashboard_set_property $dash "${param}_button_get" text "Get"
    dashboard_set_property $dash "${param}_button_get" onClick [list ::alt_xcvr::system_console::alt_xcvr_debug_tools::action_param_get ${param}]
    dashboard_set_property $dash "${param}_button_get" expandableX 1

    # Add a "set" button
    dashboard_add $dash "${param}_button_set" button param_tab_group
    dashboard_set_property $dash "${param}_button_set" text "Set"
    dashboard_set_property $dash "${param}_button_set" onClick [list ::alt_xcvr::system_console::alt_xcvr_debug_tools::action_param_set ${param}]
    dashboard_set_property $dash "${param}_button_set" expandableX 1
  }
}


proc ::alt_xcvr::system_console::alt_xcvr_debug_tools::setup_register_tab {} {
  variable dash
  variable param_data

  # Add group to tab
  dashboard_add $dash register_tab_group group main_tabs
  dashboard_set_property $dash register_tab_group itemsPerRow 4
  dashboard_set_property $dash register_tab_group title "Registers"
  dashboard_set_property $dash register_tab_group expandableY 1

  # Add header row
  dashboard_add $dash "register_header_label" label register_tab_group
  dashboard_set_property $dash "register_header_label" text "Register"

  dashboard_add $dash "register_values_header_label" label register_tab_group
  dashboard_set_property $dash "register_values_header_label" text "Register Values (HEX)"

  # Add a "get all" button
  dashboard_add $dash "register_values_button_get_all" button register_tab_group
  dashboard_set_property $dash "register_values_button_get_all" text "Get all"
  dashboard_set_property $dash "register_values_button_get_all" onClick {::alt_xcvr::system_console::alt_xcvr_debug_tools::action_registers_get_all}

  # Add a "set all" button
  dashboard_add $dash "register_values_button_set_all" button register_tab_group
  dashboard_set_property $dash "register_values_button_set_all" text "Set all"
  dashboard_set_property $dash "register_values_button_set_all" onClick {::alt_xcvr::system_console::alt_xcvr_debug_tools::action_registers_set_all}

  # Add a row for each register
  for {set x 0} {$x < 512} {incr x} {
    dashboard_add $dash "reg_${x}_label" label register_tab_group
    dashboard_set_property $dash "reg_${x}_label" text "Offset 0x[format %03X $x]:"

    # Add a text field for this register
    dashboard_add $dash "reg_${x}_textfield" textField register_tab_group
    dashboard_set_property $dash "reg_${x}_textfield" expandableX 1
    dashboard_set_property $dash "reg_${x}_textfield" text "0x00"

    # Add a "get" button
    dashboard_add $dash "reg_${x}_button_get" button register_tab_group
    dashboard_set_property $dash "reg_${x}_button_get" text "Get"
    dashboard_set_property $dash "reg_${x}_button_get" onClick [list ::alt_xcvr::system_console::alt_xcvr_debug_tools::action_register_get ${x}]
    dashboard_set_property $dash "reg_${x}_button_get" expandableX 1

    # Add a "set" button
    dashboard_add $dash "reg_${x}_button_set" button register_tab_group
    dashboard_set_property $dash "reg_${x}_button_set" text "Set"
    dashboard_set_property $dash "reg_${x}_button_set" onClick [list ::alt_xcvr::system_console::alt_xcvr_debug_tools::action_register_set ${x}]
    dashboard_set_property $dash "reg_${x}_button_set" expandableX 1
  }
  dashboard_add $dash "reg_empty_label" label register_tab_group
  dashboard_set_property $dash "reg_empty_label" expandableY 1
}


proc ::alt_xcvr::system_console::alt_xcvr_debug_tools::action_registers_get_all {} {
  send_message info "Reading all registers ..."
  set start_time [clock clicks -milliseconds]

  for {set x 0} {$x < 512} {incr x} {
    action_register_get $x
  }

  set elapsed [expr [clock clicks -milliseconds] - $start_time]
  send_message info "... All registers read in ${elapsed}ms"
}


proc ::alt_xcvr::system_console::alt_xcvr_debug_tools::action_registers_set_all {} {
  send_message info "Setting all registers ..."
  set start_time [clock clicks -milliseconds]

  for {set x 0} {$x < 512} {incr x} {
    action_register_set $x
  }

  set elapsed [expr [clock clicks -milliseconds] - $start_time]
  send_message info "... All registers set in ${elapsed}ms"
}


proc ::alt_xcvr::system_console::alt_xcvr_debug_tools::action_register_get { reg } {
  variable dash
  set value [do_read $reg]
  dashboard_set_property $dash "reg_${reg}_textfield" text "0x[format %02X $value]"
}


proc ::alt_xcvr::system_console::alt_xcvr_debug_tools::action_register_set { reg } {
  variable dash
  set value [dashboard_get_property $dash "reg_${reg}_textfield" text]
  regsub {0x} $value "" value
  regsub {0X} $value "" value
  if { [::alt_xcvr::utils::common::is_string_numeric $value "hex"] == 0} {
    send_message error "The current value:${value} specified for register offset 0x[format 0x%X $reg] is invalid. The value must be specified as a valid hexadecimal string."
    return
  }
  do_write $reg [expr 0x${value}]
}


proc ::alt_xcvr::system_console::alt_xcvr_debug_tools::action_params_get_all {} {
  variable param_data

  send_message info "Reading all parameters ..."
  set start_time [clock clicks -milliseconds]

  dict for {param values} $param_data {
    ::alt_xcvr::system_console::alt_xcvr_debug_tools::action_param_get $param
  }

  set elapsed [expr [clock clicks -milliseconds] - $start_time]
  send_message info "... All parameters read in ${elapsed}ms"
}


proc ::alt_xcvr::system_console::alt_xcvr_debug_tools::action_params_set_all {} {
  variable param_data

  send_message info "Setting all parameters ..."
  set start_time [clock clicks -milliseconds]

  dict for {param values} $param_data {
    ::alt_xcvr::system_console::alt_xcvr_debug_tools::action_param_set $param
  }

  set elapsed [expr [clock clicks -milliseconds] - $start_time]
  send_message info "... All parameters set in ${elapsed}ms"
}


proc ::alt_xcvr::system_console::alt_xcvr_debug_tools::action_param_get { param } {
  variable dash
  variable param_data

  #send_message info "Getting parameter ${param}"
  set attrib_values [dict get $param_data $param]
  set attrib_val0 [lindex [dict keys $attrib_values] 0]
  set is_direct [expr {$attrib_val0 == "DIRECT MAPPED"}]

  # Grab the first bit_value and retrieve data for each offset
  set attrib_read_data [dict create]
  dict for {offset bit_val_info} [dict get $param_data $param $attrib_val0] {
    dict set attrib_read_data $offset [do_read [expr 0x${offset}]]
  }

  set attrib_value [map_readdata_to_param_value $param $attrib_read_data]
  if {$is_direct} {
    dashboard_set_property $dash "${param}_textfield" text "0x[format %0X $attrib_value]"
  } elseif {$attrib_value != ""} {
    set selected [lsearch [dashboard_get_property $dash "${param}_combo" options] $attrib_value]
    dashboard_set_property $dash "${param}_combo" selected $selected
  }
  #send_message info "Read parameter ${param}=${attrib_value}"
}

proc ::alt_xcvr::system_console::alt_xcvr_debug_tools::map_readdata_to_param_value { param readdata } {
  variable param_data

  # Iterate over every possible parameter value and compare would-be data with actual data
  # First one that matches wins
  set is_direct 0
  dict for {current_val offsets} [dict get $param_data $param] {
    if {$current_val == "DIRECT MAPPED"} {
      set is_direct 1
      set current_val 0
    }
    # Assume a match until proven guilty
    set match 1
    # Iterate over every address offset and compare would-be data with actual data
    dict for {this_offset bit_offsets} $offsets {
      dict for {this_bit_offset bit_val_info} $bit_offsets {
        # Build up the mask and mask_val for this possible parameter value
        set mask_val [dict get $bit_val_info mask_val]
        set mask [dict get $bit_val_info mask]
        set readval [dict get $readdata $this_offset]
        #puts "readval=${readval}"
        #puts "Considering param:${param} value:${current_val} mask:${mask} mask_val:${mask_val} readval:${readval}"
        # AND the read data with the mask
        set readval [expr {$readval & $mask}]
        # If it's a direct value parameter we OR the read data with the running paramete value
        if {$is_direct} {
          set bit_l [dict get $bit_val_info bit_l]
          set val_range_l [dict get $bit_val_info val_range_l]
          # Shift readvalue by the bit mask then shift it back by the value mask
          set readval [expr $readval >> $bit_l]
          set readval [expr $readval << $val_range_l] 
          # OR the shifted read value with the accumulated value
          set current_val [expr $current_val | $readval]
        } else {
          if { $mask_val != $readval } {
            set match 0
          }
        }
      }
    }
    # If a match was found for the current value, return the current value
    if {$match && !$is_direct} {
      return $current_val
    }
  }
  # Return the accumulated value for direct mapped parameters
  if {!$is_direct} {
    send_message error "No matching parameter value for parameter ${param} with following address:readdata $readdata"
  }
  return $current_val
}


proc ::alt_xcvr::system_console::alt_xcvr_debug_tools::action_param_set { param } {
  variable dash
  variable param_data

  set attrib_values [dict get $param_data $param]
  set reginfo ""
  set is_direct [expr {[lindex [dict keys $attrib_values] 0] == "DIRECT MAPPED"}]

  if {$is_direct} {
    set current_val [dashboard_get_property $dash "${param}_textfield" text]
    regsub {0x} $current_val "" current_val
    regsub {0X} $current_val "" current_val
    if { [::alt_xcvr::utils::common::is_string_numeric $current_val "hex"] == 0} {
      send_message error "The current value:${current_val} specified for parameter $param is invalid. The value must be specified as a valid hexadecimal string."
      return
    }
    set current_val [expr 0x${current_val}]
    set reginfo [dict get $param_data $param "DIRECT MAPPED"]
  } else {
    set current_val [lindex [dashboard_get_property $dash "${param}_combo" options] [dashboard_get_property $dash "${param}_combo" selected]]
    if {[dict exists $param_data $param $current_val]} {
      set reginfo [dict get $param_data $param $current_val]
    } else {
      send_message error "No register information found for ${param}:${current_val}."
      return
    }
  }

  #send_message info "Setting parameter ${param} to value ${current_val}"
  # Iterate over bitfield offsets
  dict for {this_offset bit_offset} $reginfo {
    set offset_info [build_offset_val_info [dict get $reginfo $this_offset] $is_direct $current_val]
    do_read_modify_write [expr 0x$this_offset] [dict get $offset_info mask] [dict get $offset_info mask_val]
  }
}


proc ::alt_xcvr::system_console::alt_xcvr_debug_tools::build_offset_val_info { offset_info is_direct {direct_mapped_val 0}} {
  # Iterate over bitfield offsets
  set mask 0
  set mask_val 0
  dict for {this_bit_offset bit_val_info} $offset_info {
    set mask [expr {$mask | [dict get $bit_val_info mask]}]
    set this_mask_val [dict get $bit_val_info mask_val]
    if {$is_direct} {
      # Mask and shift direct mapped data value to obtain mapped value for this address and bit offset
      set this_mask_val [expr {($direct_mapped_val & [dict get $bit_val_info val_range_mask]) >> [dict get $bit_val_info val_range_l]}]
      set this_mask_val [expr {$this_mask_val << [dict get $bit_val_info bit_l]}]
    }
    # OR this mask value with accumulated mask value
    set mask_val [expr {$mask_val | $this_mask_val}]
  }
  set offset_val_info [dict create mask $mask mask_val $mask_val]
  return $offset_val_info
}


proc ::alt_xcvr::system_console::alt_xcvr_debug_tools::build_bit_val_info { is_direct bit_offset bit_value {direct_mapped_val 0} } {
  # Find low and high bits of bitfield range
  set bit_l [regsub {.*\[([0-9]*)\:([0-9]*)\]} $bit_offset "\\2"]
  set bit_h [regsub {.*\[([0-9]*)\:([0-9]*)\]} $bit_offset "\\1"]
  set val_range_l ""
  set val_range_h ""
  set val_range_mask ""
  
  if {$is_direct} {
    # Modify value for direct mapped parameters
    set val_range_l [regsub {\[([0-9]*)\:([0-9]*)\]} $bit_value "\\2"]
    set val_range_h [regsub {\[([0-9]*)\:([0-9]*)\]} $bit_value "\\1"]
    set val_range_mask 0
    # Mask off needed bits
    for {set x $val_range_l} {$x <= $val_range_h} {incr x} {
      set val_range_mask [expr {$val_range_mask | (1 << $x)}]
    }
    set bit_value [expr {($direct_mapped_val & $val_range_mask) >> $val_range_l}]
  } else {
    # Convert non-direct mapped parameters from binary to decimal
    set bit_value [regsub {[0-9]*'b([01]*)} $bit_value "\\1"]
    set bit_value [::alt_xcvr::utils::common::bin_to_dec $bit_value]
  }
  
  # Create bitfield mask
  set mask 0
  for {set x $bit_l} {$x <= $bit_h} {incr x} {
    set mask [expr {$mask | (1 << $x)}]
  }
  set mask_val [expr {$bit_value << $bit_l}]

  set bit_val_info [dict create]
  dict set bit_val_info bit_l $bit_l
  dict set bit_val_info bit_h $bit_h
  dict set bit_val_info bit_value $bit_value
  dict set bit_val_info val_range_l $val_range_l 
  dict set bit_val_info val_range_h $val_range_h 
  dict set bit_val_info val_range_mask $val_range_mask
  dict set bit_val_info mask $mask
  dict set bit_val_info mask_val $mask_val
}

proc ::alt_xcvr::system_console::alt_xcvr_debug_tools::do_read { address } {
  set val [::alt_xcvr::system_console::alt_xcvr_reconfig_if::reconfig_read $address]
  #send_message info "Read 0x[format %02X $val] from address 0x[format %0X $address]"
  return $val
}

proc ::alt_xcvr::system_console::alt_xcvr_debug_tools::do_write { address data } {
  ::alt_xcvr::system_console::alt_xcvr_reconfig_if::reconfig_write $address $data
  #send_message info "Wrote 0x[format %02X $data] to address 0x[format %0X $address]"
}

proc ::alt_xcvr::system_console::alt_xcvr_debug_tools::do_read_modify_write { address mask data } {
  set val [do_read $address]
  set mask [expr {$mask ^ 0xff}]
  set val [expr $val & $mask]
  set val [expr $val | $data]
  do_write $address $val
}


