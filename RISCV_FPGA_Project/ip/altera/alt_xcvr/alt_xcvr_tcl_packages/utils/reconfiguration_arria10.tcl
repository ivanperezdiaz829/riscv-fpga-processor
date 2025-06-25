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


## \file reconfiguration_arria10.tcl
# includes common reconfiguration parameters, port definitions and validation callbacks for NF Native PHY and PLLs

package provide alt_xcvr::utils::reconfiguration_arria10 13.1

package require alt_xcvr::ip_tcl::messages
package require alt_xcvr::ip_tcl::ip_module
package require alt_xcvr::utils::device
package require alt_xcvr::utils::ipgen
package require alt_xcvr::utils::fileset
package require alt_xcvr::utils::common

namespace eval ::alt_xcvr::utils::reconfiguration_arria10:: {
   namespace import ::alt_xcvr::ip_tcl::messages::*
   namespace import ::alt_xcvr::ip_tcl::ip_module::*

   namespace export \
      declare_display_items \
      declare_parameters \
      generate_config_files \

      variable display_items
      variable parameters

      variable rcfg_criteria {M_RCFG_REPORT 1}

   set display_items {\
      {NAME                         GROUP                      ENABLED             VISIBLE   TYPE   ARGS  }\
      {"Dynamic Reconfiguration"    ""                         NOVAL               NOVAL     GROUP  tab   }\
      {"Configuration Files"        "Dynamic Reconfiguration"  NOVAL               NOVAL     GROUP  noval }\
      {"Configuration Profiles"     "Dynamic Reconfiguration"  NOVAL               false     GROUP  NOVAL }\
      {"Store profile"              "Configuration Profiles"   rcfg_multi_enable   false     action ::alt_xcvr::utils::reconfiguration_arria10::action_store_profile}\
      {"Clear all profiles"         "Configuration Profiles"   rcfg_multi_enable   false     action ::alt_xcvr::utils::reconfiguration_arria10::action_clear_profiles}\
      {"Reconfiguration Parameters" "Configuration Profiles"   rcfg_multi_enable   false     GROUP TABLE }\
    }

   set parameters {\
      {NAME                                 M_CONTEXT  M_USED_FOR_RCFG  M_SAME_FOR_RCFG  VALIDATION_CALLBACK                                                       DERIVED HDL_PARAMETER   TYPE         DEFAULT_VALUE            ALLOWED_RANGES                                        ENABLED                  VISIBLE                   DISPLAY_HINT  DISPLAY_UNITS DISPLAY_ITEM                 DISPLAY_NAME                                DESCRIPTION }\
      {rcfg_debug                           NOVAL      1                1                NOVAL                                                                     false   false           INTEGER      0                        { 0 1 }                                               false                    false                     BOOLEAN       NOVAL         NOVAL                        NOVAL                                       NOVAL}\
      {enable_pll_reconfig                  NOVAL      1                1                NOVAL                                                                     false   false           INTEGER      0                        NOVAL                                                 true                     true                      BOOLEAN       NOVAL         "Dynamic Reconfiguration"    "Enable reconfiguration"                    "Enables the dynamic reconfiguration interface." }\
      \
      {rcfg_file_prefix                     NOVAL      0                0                NOVAL                                                                     false   false           STRING       "altera_xcvr_rcfg_10"    NOVAL                                                 enable_pll_reconfig      true                      NOVAL         NOVAL         "Configuration Files"        "Configuration file prefix"                 "Specifies the file prefix to use for generated configuration files when enabled. Each variant of the IP should use a unique prefix for configuration files."}\
      {rcfg_sv_file_enable                  NOVAL      0                0                NOVAL                                                                     false   false           INTEGER      0                        NOVAL                                                 enable_pll_reconfig      true                      BOOLEAN       NOVAL         "Configuration Files"        "Generate SystemVerilog package file"       "When enabled, The IP will generate a SystemVerilog package file named \"(Configuration file prefix)_reconfig_parameters.sv\" containing parameters defined with the attribute values needed for reconfiguration."}\
      {rcfg_h_file_enable                   NOVAL      0                0                NOVAL                                                                     false   false           INTEGER      0                        NOVAL                                                 enable_pll_reconfig      true                      BOOLEAN       NOVAL         "Configuration Files"        "Generate C header file"                    "When enabled, The IP will generate a C header file named \"(Configuration file prefix)_reconfig_parameters.h\" containing macros defined with the attribute values needed for reconfiguration."}\
      {rcfg_txt_file_enable                 NOVAL      0                0                NOVAL                                                                     false   false           INTEGER      0                        NOVAL                                                 false                    false                     BOOLEAN       NOVAL         "Configuration Files"        "Generate text file"                        "When enabled, The IP will generate a text file named \"(Configuration file prefix)_reconfig_parameters.txt\" containing the attribute values needed for reconfiguration."}\
      {rcfg_mif_file_enable                 NOVAL      0                0                NOVAL                                                                     false   false           INTEGER      0                        NOVAL                                                 enable_pll_reconfig      true                      BOOLEAN       NOVAL         "Configuration Files"        "Generate MIF (Memory Initialize File)"     "When enabled The IP will generate an Altera MIF (Memory Initialization File) named \"(Configuration file prefix)_reconfig_parameters.mif\". The MIF file contains the attribute values needed for reconfiguration in a data format."}\
      \
      {rcfg_multi_enable                    NOVAL      0                0                NOVAL                                                                     false   false           INTEGER      0                        NOVAL                                                 enable_pll_reconfig      false                     BOOLEAN       NOVAL         "Configuration Profiles"     "Enable multiple reconfiguration profiles"  "When enabled, you can use the GUI to store multiple configurations. The IP will generate reconfiguration files for all of the stored profiles. The IP will also check your multiple reconfiguration profiles for consistency to ensure you can reconfigure between them."}\
      {rcfg_profile_cnt                     NOVAL      0                0                NOVAL                                                                     false   false           INTEGER      2                        { 2 3 }                                               rcfg_multi_enable        false                     NOVAL         NOVAL         "Configuration Profiles"     "Number of reconfiguration profiles"        "Specifies the number of reconfiguration profiles to support when multiple reconfiguration profiles are enabled."}\
      {rcfg_profile_select                  NOVAL      0                0                ::alt_xcvr::utils::reconfiguration_arria10::validate_rcfg_profile_select  false   false           INTEGER      1                        { 1 }                                                 rcfg_multi_enable        false                     NOVAL         NOVAL         "Configuration Profiles"     "Store current configuration to profile:"   "Selects which reconfiguration profile to store when clicking the \"Store profile\" button."}\
      \
      {rcfg_params                          NOVAL      0                0                ::alt_xcvr::utils::reconfiguration_arria10::validate_rcfg_params          true    false           STRING_LIST  NOVAL                    NOVAL                                                 false                    false                     FIXED_SIZE    NOVAL         NOVAL                         NOVAL                                      NOVAL}\
      {rcfg_param_labels                    NOVAL      0                0                ::alt_xcvr::utils::reconfiguration_arria10::validate_rcfg_param_labels    true    false           STRING_LIST  NOVAL                    NOVAL                                                 false                    false                     FIXED_SIZE    NOVAL         "Reconfiguration Parameters"  "IP Parameters"                            NOVAL}\
      {rcfg_param_vals0                     0          0                0                ::alt_xcvr::utils::reconfiguration_arria10::validate_rcfg_param_vals0     true    false           STRING_LIST  NOVAL                    NOVAL                                                 false                    false                     FIXED_SIZE    NOVAL         "Reconfiguration Parameters"  "Profile 0 (Current)"                      NOVAL}\
      {rcfg_param_vals1                     1          0                0                ::alt_xcvr::utils::reconfiguration_arria10::validate_rcfg_param_vals      false   false           STRING_LIST  NOVAL                    NOVAL                                                 false                    false                     FIXED_SIZE    NOVAL         "Reconfiguration Parameters"  "Profile 1"                                NOVAL}\
      {rcfg_param_vals2                     2          0                0                ::alt_xcvr::utils::reconfiguration_arria10::validate_rcfg_param_vals      false   false           STRING_LIST  NOVAL                    NOVAL                                                 false                    false                     FIXED_SIZE    NOVAL         "Reconfiguration Parameters"  "Profile 2"                                NOVAL}\
   }

}

proc ::alt_xcvr::utils::reconfiguration_arria10::declare_parameters {} {
   variable parameters
   ip_declare_parameters $parameters
}

proc ::alt_xcvr::utils::reconfiguration_arria10::declare_display_items { group_value args_value } {
   variable display_items
   set display_items [ip_set_property_byParameterIndex $display_items GROUP $group_value 1]
   set display_items [ip_set_property_byParameterIndex $display_items ARGS $args_value 1]
   ip_declare_display_items $display_items
}

##################################################################################################################################################
# VALIDATION CALLBACKS
##################################################################################################################################################
proc ::alt_xcvr::utils::reconfiguration_arria10::validate_rcfg_profile_select { PROP_NAME rcfg_profile_cnt } {
  set legal_values {}
  for {set x 1} {$x < $rcfg_profile_cnt} {incr x} {
    lappend legal_values $x
  }  
  ip_set "parameter.${PROP_NAME}.allowed_ranges" $legal_values
}

proc ::alt_xcvr::utils::reconfiguration_arria10::validate_rcfg_params { PROP_NAME } {
  # Initialize reconfiguration profile header
  dict set criteria M_USED_FOR_RCFG 1
  dict set criteria DERIVED 0
  set params [ip_get_matching_parameters $criteria]
  ip_set "parameter.${PROP_NAME}.value" $params
}

proc ::alt_xcvr::utils::reconfiguration_arria10::validate_rcfg_param_labels { PROP_NAME rcfg_params } {
  set labels {}
  foreach param $rcfg_params {
    lappend labels [ip_get "parameter.${param}.display_name"]
  }
  ip_set "parameter.${PROP_NAME}.value" $labels
}

proc ::alt_xcvr::utils::reconfiguration_arria10::validate_rcfg_param_vals0 { PROP_NAME rcfg_params enable_pll_reconfig } {
  if {$enable_pll_reconfig} {
    # We set the properties for the current configuration (profile 0)
    set vals {}
    foreach param $rcfg_params {
      lappend vals [ip_get "parameter.${param}.value"]
    }
    ip_set "parameter.${PROP_NAME}.value" $vals
  }
}

proc ::alt_xcvr::utils::reconfiguration_arria10::validate_rcfg_param_vals { PROP_NAME PROP_M_CONTEXT PROP_VALUE \
  rcfg_param_vals0 rcfg_params rcfg_param_labels rcfg_multi_enable rcfg_profile_cnt } {
  if {$rcfg_multi_enable} {
    # For profile we make sure the settings are consistent with the current profile.
    if {$PROP_M_CONTEXT < $rcfg_profile_cnt} {
      if {[llength $PROP_VALUE] == 0} {
        ip_message warning "Configuration profile $PROP_M_CONTEXT is empty."
      } else {
        for {set index 0} {$index < [llength $rcfg_params]} {incr index} {
          set param [lindex $rcfg_params $index]
          # Compare parameter values for all parameters that are marked as needing to be same for reconfig
          if {[ip_get "parameter.${param}.M_SAME_FOR_RCFG"] } {
            set cur_val [lindex $rcfg_param_vals0 $index]
            set this_val [lindex $PROP_VALUE $index]
            if {$cur_val != $this_val} {
              ip_message error "Parameter \"${param}\" ([lindex $rcfg_param_labels $index]) must be consistent for all reconfiguration profiles. Current value:${cur_val}; Profile${PROP_M_CONTEXT} value:${this_val}."
            }
          }
        }
      }
    }
  }

}

proc ::alt_xcvr::utils::reconfiguration_arria10::action_store_profile {} {
  set PROP_M_CONTEXT [ip_get "parameter.rcfg_profile_select.value"]
  set PROP_NAME "rcfg_param_vals${PROP_M_CONTEXT}"
  set rcfg_params [ip_get "parameter.rcfg_params.value"]
  set rcfg_multi_enable [ip_get "parameter.rcfg_multi_enable.value"]

  validate_rcfg_param_vals0 $PROP_NAME $rcfg_params $rcfg_multi_enable
}

proc ::alt_xcvr::utils::reconfiguration_arria10::action_clear_profiles {} {
  set rcfg_params {}
  set rcfg_multi_enable 1
  for {set PROP_M_CONTEXT 1} {$PROP_M_CONTEXT < 8} {incr PROP_M_CONTEXT} {
    set PROP_NAME "rcfg_param_vals${PROP_M_CONTEXT}"
    validate_rcfg_param_vals0 $PROP_NAME $rcfg_params $rcfg_multi_enable
  }
}

##################################################################################################################################################
# RECONFIGURATION FILE GENERATION FUNCTIONS
##################################################################################################################################################

##
# Generate files needed for dynamic reconfiguration.
# These include reconfiguration report files
#
# @param opcodes - A list of optional opcodes to include in the MIF with
#               their values in this format:
#               <opcode0>=<value0> <opcode1>=<value1>
#               (E.g.) "channel_pll_refclk=0" "channel_cgb_select=1"
# @param regmap_list - A list of the desired blocks "pma, pcs, fpll, or atx" the register map should contain
#
proc ::alt_xcvr::utils::reconfiguration_arria10::generate_config_files {opcodes regmap_list} {
  variable rcfg_criteria
  # Bail if reconfiguration is disabled
  if { ![ip_get "parameter.enable_pll_reconfig.value"] } {
    return
  }

  # Determine which files are requested
  set rcfg_sv_file_enable [ip_get "parameter.rcfg_sv_file_enable.value"]
  set rcfg_h_file_enable [ip_get "parameter.rcfg_h_file_enable.value"]
  set rcfg_mif_file_enable [ip_get "parameter.rcfg_mif_file_enable.value"]

  # If no reconfiguration report files are requested, return
  if {!$rcfg_sv_file_enable && !$rcfg_h_file_enable && !$rcfg_mif_file_enable} {
    return
  }

  # Retrieve register map
  set regmap [::alt_xcvr::utils::device::get_arria10_regmap $regmap_list]
  if {$regmap == -1} {
    ip_message error "Register map data not available."
    return
  }

  # Get the configuration file prefix
  set rcfg_file_prefix [ip_get "parameter.rcfg_file_prefix.value"]
  set file_prefix "${rcfg_file_prefix}_reconfig_parameters"

  # Build reconfiguration data for this configuration
  set rcfg_data [build_config_data $rcfg_criteria $regmap]
  set ascii_data [dict get $rcfg_data ascii_data]
  set ram_data [dict get $rcfg_data ram_data]

  # Generate the SystemVerilog package file if requested
  if { $rcfg_sv_file_enable } {
    ::alt_xcvr::ip_tcl::messages::ip_message info "Generating SystemVerilog configuration file"
    set filename "${file_prefix}.sv"
    set file_contents [::alt_xcvr::utils::ipgen::create_system_verilog_param_package ${file_prefix} $ascii_data $ram_data]
    add_fileset_file "./reconfig/${filename}" SYSTEM_VERILOG_INCLUDE TEXT $file_contents
  }

  # Generate the C header file if requested
  if { $rcfg_h_file_enable } {
    ::alt_xcvr::ip_tcl::messages::ip_message info "Generating C header configuration file"
    set filename "${file_prefix}.h"
    set file_contents [::alt_xcvr::utils::ipgen::create_c_param_header ${file_prefix} $rcfg_file_prefix $ascii_data $ram_data]
    add_fileset_file "./reconfig/${filename}" OTHER TEXT $file_contents
  }

  # Generate the MIF file if requested
  if { $rcfg_mif_file_enable } {
    ::alt_xcvr::ip_tcl::messages::ip_message info "Generating MIF configuration file"
    set filename "${file_prefix}.mif"
    set file_contents [::alt_xcvr::utils::ipgen::create_series10_style_mif $ram_data]
    add_fileset_file "./reconfig/${filename}" OTHER TEXT $file_contents
  }
}



##################################################################################################################################################
# INTERNAL UTILITY FUNCTIONS
##################################################################################################################################################

##
# Builds a dictionary containing register map information for parameters
# that can subsequently be used to create reconfiguration report files.
#
# @param criteria - A dictionary containing criteria for which IP parameters
#                   should be included in the returned data structure. This
#                   criteria will be passed to
#                   "::alt_xcvr::ip_tcl::ip_module::ip_get_matching_parameters"
#                   to obtain a parameter list.
#                   The criteria dictionary should contain a list of
#                   <parameter property->parameter property_value> pairs. Only
#                   those parameters whose properties meet all criteria will be
#                   included.
#
# @param rcfg_regmap - A dictionary of the format obtained from a call to
#                   "::alt_xcvr::utils::device::get_arria10_regmap" as an example.
#                   This dictionary contains register map data for each parameter.
#
# @return - Returns a dictionary that contains two important subdictionaries
#           ascii_data <data for creation of ascii report files>
#           ram_data <data for creation of address offset based files>
#
#           ascii_data is organized by parameter name
#           ram_data is organized by register offset
proc ::alt_xcvr::utils::reconfiguration_arria10::build_config_data { criteria rcfg_regmap } {
  # Initialize our config data dictionaries
  set ascii_data [dict create]
  set ram_data [dict create]

  # Get list of parameters that match the criteria
  set params [ip_get_matching_parameters $criteria]

  # Iterate over each parameter
  foreach param $params {
    # Get parameter value
    set val [ip_get "parameter.${param}.value"]

    # Convert parameter value to string if necessary and add to ascii data
    set str_val $val
    if {[string toupper [ip_get "parameter.${param}.type"]] == "STRING"} {
      set str_val "\"${str_val}\""
    } else {
      set width [ip_get "parameter.${param}.width"]
      if {$width != "NOVAL" && $width != ""} {
        set str_val "${width}'d${str_val}"
      } 
    }

    dict set ascii_data $param "value" $str_val

    # Get register map data for this parameter
    set regmap "NOVAL"
    if { [dict exists $rcfg_regmap $param] } {
      set regmap [dict get $rcfg_regmap $param]
    }

    if {$regmap != "NOVAL"} {
      # Iterate over attribute possible attribute values
      dict for {attrib_value offset} $regmap {

        # For direct mapped parameters override attribute value
        set is_direct [expr {$attrib_value == "DIRECT MAPPED"}]

        # Proceed if the attribute value matches
        if {$attrib_value == $val || $is_direct} {
          # If there are multiple address offsets, give them indices
          set addr_idx ""
          if {[dict size $offset] > 1} {
            set addr_idx 0
          }

          # Iterate over address offsets in the regmap data
          dict for {this_offset bit_offset} $offset {
            # Add address offset
            set this_offset_dec [expr 0x${this_offset}]
            dict set ascii_data $param "ADDR${addr_idx}_OFST" $this_offset_dec

            # If there are multiple bit offsets, give them indices
            set field_idx ""
            if {[dict size $bit_offset] > 1} {
              set field_idx 0
            }

            # definining regular expressions to be used to extract high and low indices from a range definition
            # range could be one of the following three cases (due to the way information is presented in register map spreadsheet) 
            # [M:N] where M is high index and N is low index ()
            # or [M] where M is both high and low index 
            # or M where M is both high and low index
            set reg_exp_for_high_index {(\[)?([0-9]*)(:)?([0-9]*)?(\])?}
            set reg_exp_for_low_index   {(\[)?([0-9]*:)?([0-9]*)(\])?}

            # Iterate over bitfield offsets
            dict for {this_bit_offset bit_value} $bit_offset {
              # Find low and high bits of bitfield range
              set bit_l [regsub $reg_exp_for_low_index $this_bit_offset {\3}]
              set bit_h [regsub $reg_exp_for_high_index $this_bit_offset {\2}]
              set bit_s [expr {($bit_h + 1) - $bit_l}]

              if {$is_direct} {
                # Modify value for direct mapped parameters
                set val_range_l [regsub $reg_exp_for_low_index $bit_value {\3}]
                set val_range_h [regsub $reg_exp_for_high_index $bit_value {\2}]
                set val_range_mask 0
                # Mask off needed bits
                for {set x $val_range_l} {$x <= $val_range_h} {incr x} {
                  set val_range_mask [expr {$val_range_mask | (1 << $x)}]
                }
                set bit_value [expr {($val & $val_range_mask) >> $val_range_l}]
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

              dict set ascii_data $param "ADDR${addr_idx}_FIELD${field_idx}_OFST" $bit_l
              dict set ascii_data $param "ADDR${addr_idx}_FIELD${field_idx}_HIGH" $bit_h
              dict set ascii_data $param "ADDR${addr_idx}_FIELD${field_idx}_SIZE" $bit_s
              dict set ascii_data $param "ADDR${addr_idx}_FIELD${field_idx}_BITMASK" "32'h[format %08X $mask]"
              dict set ascii_data $param "ADDR${addr_idx}_FIELD${field_idx}_VALMASK" "32'h[format %08X $mask_val]"
              dict set ascii_data $param "ADDR${addr_idx}_FIELD${field_idx}_VALUE" "$bit_s'h[format %X $bit_value]"

              dict set ram_data $this_offset_dec $bit_h mask $mask
              dict set ram_data $this_offset_dec $bit_h val_mask $mask_val
              dict set ram_data $this_offset_dec $bit_h param $param
              dict set ram_data $this_offset_dec $bit_h param_val $val
              dict set ram_data $this_offset_dec $bit_h bit_l $bit_l
              dict set ram_data $this_offset_dec $bit_h bit_h $bit_h
              dict set ram_data $this_offset_dec $bit_h bit_s $bit_s
              dict set ram_data $this_offset_dec $bit_h bit_value $bit_value

              # Increment to next field index if necessary
              if {$field_idx != ""} {
                incr field_idx
              }
            }
            # Increment to next address index if necessary
            if {$addr_idx != ""} {
              incr addr_idx
            }
          }
        }
      }
    }
  }
  #puts "\[build_config_data\] Returning"
  #::alt_xcvr::ip_tcl::ip_module::print_dict $ascii_data
  return [dict create ascii_data $ascii_data ram_data $ram_data]
}





