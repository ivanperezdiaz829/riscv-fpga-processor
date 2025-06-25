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


## \file file_utils.tcl
# includes common functions to generate parameter documentation & hdl tcl instance example for IPs

package provide alt_xcvr::ip_tcl::file_utils 13.1

package require alt_xcvr::ip_tcl::messages
package require alt_xcvr::ip_tcl::ip_module

namespace eval ::alt_xcvr::ip_tcl::file_utils:: {
   namespace import ::alt_xcvr::ip_tcl::messages::*
   namespace import ::alt_xcvr::ip_tcl::ip_module::*

   namespace export \
      generate_doc_files \
      generate_add_hdl_instance_example \

}

##
# Generates a file "<ip_name>_parameters.csv" that contains static information for this
# IP core's parameters.
# Fields in the CSV are:
# parameter name, display name, allowed ranges, default value, description
# The file is automatically added to the fileset
#
# @param ip_name - The name of this IP core or IP instance
# @param fileset - The fileset to which to add the generated file (QUARTUS_SYNTH, SIM_VERILOG, SIM_VHDL)
proc ::alt_xcvr::ip_tcl::file_utils::generate_doc_files {ip_name fileset} {
  # Generate parameter documentation file
  set fields {NAME DISPLAY_NAME ALLOWED_RANGES DEFAULT_VALUE DESCRIPTION}

  set contents ""
  #Print out the header row
  for {set x 0} {$x < [llength $fields]} {incr x} {
    set field [lindex $fields $x]
    if {$x != 0} {
      set contents "${contents},"
    }
    set contents "${contents}${field}"
  }
  set contents "${contents}\n"

  dict set criteria DERIVED 0
  set params [ip_get_matching_parameters $criteria]
  foreach param $params {
    for {set x 0} {$x < [llength $fields]} {incr x} {
      set field [lindex $fields $x]
      if {$x != 0} {
        set contents "${contents},"
      }

      set val [ip_get "parameter.${param}.${field}"]

      # Create allowed_ranges for boolean display hint parameters if allowed_ranges is not specified
      if {$field == "ALLOWED_RANGES" && ${val} == "NOVAL"} {
        set type [string toupper [ip_get "parameter.${param}.type"]]
        set display_hint [string toupper [ip_get "parameter.${param}.display_hint"]]
        if {$type == "INTEGER" && $display_hint == "boolean"} {
          set val "{0 1}"
        }
        if {$type == "STRING" && $display_hint == "boolean"} {
          set val "{true false}"
        }
      }
      set contents "${contents}\"${val}\""
    }
    set contents "${contents}\n"
  }
  set filename "${ip_name}_parameters.csv"
  add_fileset_file "./docs/${filename}" OTHER TEXT $contents
  
}


##
# Generates a file "<ip_name>_add_hdl_instance_example" that contains an example usages
# of the "_hw.tcl" add_hdl_instance API for the current configuration of this IP core.
# The file is automatically added to the fileset
#
# @param ip_name - The name of this IP core or IP instance
# @param fileset - The fileset to which to add the generated file (QUARTUS_SYNTH, SIM_VERILOG, SIM_VHDL)
proc ::alt_xcvr::ip_tcl::file_utils::generate_add_hdl_instance_example { ip_name fileset } {
  set criteria [dict create DERIVED 0]
  set params [ip_get_matching_parameters $criteria]

  # Create list of param value pairs
  set param_list {}
  foreach param $params {
    # Only include parameters that are not set to the default (to reduce list)
    set param_val [ip_get "parameter.${param}.value"]
    set default_val [ip_get "parameter.${param}.default_value"]
    if { $param_val != $default_val } {
      lappend param_list $param
      lappend param_list $param_val
    }
  }

  # Create file
  set contents "add_hdl_instance ${ip_name}_inst $ip_name\n"
  if {[llength $param_list] > 0} {
    set contents "${contents}set param_val_list \{${param_list}\}\n"
    set contents "${contents}foreach \{param val\} \$param_val_list \{\n"
    set contents "${contents}  set_instance_parameter_value ${ip_name}_inst \$param \$val\n"
    set contents "${contents}\}\n"
  }
  
  set filename "${ip_name}_add_hdl_instance_example.tcl"
  add_fileset_file "./docs/${filename}" OTHER TEXT $contents
}
