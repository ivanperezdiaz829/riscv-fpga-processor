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


###
#
# pll_reconfig GUI package
#
#   This package provides GUI widgets to display options associated with multiple PLL support. The package does
# not depend on parameters or information from the user/caller. The user/caller must provide information to
# this package and obtain results from the package.
#
# Limitations:
#   There can only be one instance of this package at any given point.
#
# How to use
# 1 - Call the "initialize" function during your IP's global phase.
# 2 - Call the "set_config" function early during validation phase.
# 3 - Call the "validate" function during the validation phase AFTER "set_config" but BEFORE
#     calling any of the result functions.
# 4 - Call the necessary "get_<parameter>" result functions
package provide alt_xcvr::gui::pll_reconfig 11.1

package require alt_xcvr::utils::rbc 
package require alt_xcvr::gui::messages

namespace eval ::alt_xcvr::gui::pll_reconfig:: {
  namespace export \
    init_pll_defaults \
    init_pushdown_main_pll \
    init_pushdown_tx_pll_counts \
    initialize \
    set_config \
    set_config_device_family \
    set_config_pll_count \
    set_config_refclk_count \
    set_config_allowed_pll_types \
    set_config_allowed_clk_network_sel \
    set_config_enable_cdr_refclk_select \
    set_config_enable_pll_reconfig \
    set_enabled \
    set_main_pll_settings \
    validate \
    get_refclk_freq_string \
    get_refclk_sel_string \
    get_cdr_refclk_sel \
    get_pll_type_string \
    get_pll_type \
    get_clk_network_sel_string \
    get_pll_data_rate_string \
    get_pll_count \
    get_main_pll_index \
    get_refclk_count

  variable pkg_string
  variable l_initialized
  variable l_validated
  variable l_enabled
  variable l_max_pll_count
  variable l_max_refclk_count
  variable l_enable_cdr_refclk_select

  # variables to override default initialization and validation behavior
  variable l_mapping
  variable l_support_cdr_refclk_select
  variable l_support_pll_reconfig
  variable l_pushdown_main_pll
  variable l_pushdown_tx_pll_counts
  variable l_default_data_rate
  variable l_default_refclk_freq

  # Derived variables
  variable l_pll_data_rate_list
  variable l_pll_type_list
  variable l_pll_type_ranges
  variable l_refclk_sel_list
  variable l_refclk_freq_list
  variable l_clk_network_sel_list
  variable l_clk_network_sel_ranges
  variable l_enable_external_pll
  variable l_param_list
  variable l_device_family
  variable l_main_pll_data_rate
  variable l_main_refclk_freq
  variable l_main_pll_type
  variable l_main_pll_enable_att
  variable l_main_pll_pll_feedback
  variable l_main_pll_pma_width
  variable l_main_pll_pma_data_rate
  variable l_main_pll_byte_serializer
  variable l_main_clk_network_sel
  # Variables for use with pushdown_tx_pll_counts
  variable l_pll_count
  variable l_pll_refclk_count
  variable l_main_pll_index

  variable l_data_rate
  variable l_enable_pll_reconfig

  set pkg_string "alt_xcvr::gui::pll_reconfig"
  set l_initialized 0
  set l_validated 0
  set l_enabled 0
  set l_max_pll_count 1
  set l_max_refclk_count 1

  set l_mapping 1
  set l_support_cdr_refclk_select 0
  set l_support_pll_reconfig 1
  set l_pushdown_main_pll 1
  set l_pushdown_tx_pll_counts 0

  set l_enable_cdr_refclk_select 0
  set l_default_data_rate "0 Mbps"
  set l_default_refclk_freq "0 MHz"
  set l_pll_data_rate_list {}
  set l_pll_type_list {}
  set l_pll_type_ranges {}
  set l_refclk_sel_list {}
  set l_refclk_freq_list {}
  set l_clk_network_sel_list {}
  set l_clk_network_sel_ranges {}
  set l_enable_external_pll 0
  set l_param_list ""

  set l_pll_count 1
  set l_pll_refclk_count 1
  set l_main_pll_index 0
  set l_main_pll_byte_serializer "disabled"
  set l_main_clk_network_sel "unused"

}


#############################################################################
#################### Initialization and Configuration #######################

###
# initialize will create the needed GUI and derived parameters.
#
# @param group The component group to which to add the GUI components
# @param max_plls The maximum number of plls to be supported by this configuration
# @param max_refclks The maximum number of reference clocks to be supported by this configuration
#
proc ::alt_xcvr::gui::pll_reconfig::initialize { group max_plls max_refclks {support_cdr_refclk_select 0} {support_clk_network_sel 0} {support_external_pll 0} } {
  variable l_initialized
  variable l_max_pll_count
  variable l_max_refclk_count
  variable l_enable_cdr_refclk_select
  variable l_support_cdr_refclk_select
  variable l_support_clk_network_sel
  variable l_support_external_pll
  variable l_support_pll_reconfig
  variable l_pushdown_tx_pll_counts
  variable l_default_data_rate
  variable l_default_refclk_freq

  if {[verify_initialized 0] == 0} { return 0 }
  set l_max_pll_count $max_plls
  set l_max_refclk_count $max_refclks

  # Create GUI parameters
  if {$l_support_pll_reconfig == 1} {
    add_gui_parameter $group gui_pll_reconfig_enable_pll_reconfig BOOLEAN false "Allow PLL/CDR Reconfiguration"
    set description "Enables support for dynamic reconfiguration of the TX PLL and RX CDR. Enabling this option
      prevents TX PLL merging by default. You can manually specify merging through QSF assignments. This option
      also enables support for dynamic reconfiguration of TX PLLs and RX CDRs in simulation."
    set_parameter_property gui_pll_reconfig_enable_pll_reconfig DESCRIPTION $description
  }

  if {$l_pushdown_tx_pll_counts == 0} {
    # How many PLLs
    add_gui_parameter $group gui_pll_reconfig_pll_count STRING 1 "Number of TX PLLs"
    set description "The number of logical TX PLLs for dynamic reconfiguration. Use multiple TX PLLs
      if you intend to dynamically switch between PLLs."
    set_parameter_property gui_pll_reconfig_pll_count DESCRIPTION $description

    # How many reference clocks
    add_gui_parameter $group gui_pll_reconfig_refclk_count STRING 1 "Number of reference clocks"
    set description "The number of input or reference clocks to make available to the TX PLLs"
    if {$support_cdr_refclk_select == 1} {
      set description "${description} and RX CDRs"
    }
    set description "${description}."
    set_parameter_property gui_pll_reconfig_refclk_count DESCRIPTION $description
  
    # Which PLL is the main PLL
    add_gui_parameter $group gui_pll_reconfig_main_pll_index STRING 0 "Main TX PLL logical index"
    set description "Indicates which of the multiple TX PLLs is to be used as the \"main\" or \"initial\"
      TX PLL. The settings for the main TX PLL are configured on the \"General\" tab."
    set_parameter_property gui_pll_reconfig_main_pll_index DESCRIPTION $description
  }


  if {$support_cdr_refclk_select != 0} {
    set l_enable_cdr_refclk_select $support_cdr_refclk_select
    set l_support_cdr_refclk_select $support_cdr_refclk_select
    add_gui_parameter $group gui_pll_reconfig_cdr_pll_refclk_sel STRING 0 "CDR PLL input clock source" {0}
    set description "Selects the initial reference clock to be used for the RX CDR."
    set_parameter_property gui_pll_reconfig_cdr_pll_refclk_sel DESCRIPTION $description
  }
  
  set l_support_clk_network_sel $support_clk_network_sel
  
  set l_support_external_pll $support_external_pll

  for {set x 0} {$x < $l_max_pll_count} {incr x} {
    add_display_item $group "TX PLL ${x}" GROUP tab
    add_gui_parameter "TX PLL ${x}" "gui_pll_reconfig_pll${x}_pll_type" STRING "CMU" "PLL type"
    add_gui_parameter "TX PLL ${x}" "gui_pll_reconfig_pll${x}_data_rate" STRING $l_default_data_rate "PLL base data rate"
    add_gui_parameter "TX PLL ${x}" "gui_pll_reconfig_pll${x}_data_rate_der" STRING $l_default_data_rate "PLL base data rate"
    set_parameter_property "gui_pll_reconfig_pll${x}_data_rate_der" DERIVED "true"

    add_gui_parameter "TX PLL ${x}" "gui_pll_reconfig_pll${x}_refclk_freq" STRING $l_default_refclk_freq "Reference clock frequency"
    add_gui_parameter "TX PLL ${x}" "gui_pll_reconfig_pll${x}_refclk_sel" STRING 0 "Selected reference clock source"

    add_gui_parameter "TX PLL ${x}" "gui_pll_reconfig_pll${x}_clk_network" STRING "x1" "Selected clock network"

    # Descriptions
    set description "Selects the type of this TX PLL. Options depend on selected device family."
    set_parameter_property "gui_pll_reconfig_pll${x}_pll_type" DESCRIPTION $description

    set description "Specifies the base data rate for this TX PLL. TX PLLs that require merging must share
      the same base data rate. A PLL's base data rate is the PLL output clock frequency multiplied by 2.
      The base data rate is specified in Mbps or Gbps."
    set_parameter_property "gui_pll_reconfig_pll${x}_data_rate" DESCRIPTION $description
    set_parameter_property "gui_pll_reconfig_pll${x}_data_rate_der" DESCRIPTION $description

    set description "Selects the input reference clock frequency for this TX PLL and selected reference clock index." 
    set_parameter_property "gui_pll_reconfig_pll${x}_refclk_freq" DESCRIPTION $description

    set description "Selects the input reference clock index for this TX PLL." 
    set_parameter_property "gui_pll_reconfig_pll${x}_refclk_sel" DESCRIPTION $description

    set description "Selects the clock network of this TX PLL. Options depend on selected device family."
    set_parameter_property "gui_pll_reconfig_pll${x}_clk_network" DESCRIPTION $description
  }

  # Initialization complete
  set l_initialized 1

}

proc ::alt_xcvr::gui::pll_reconfig::init_pll_defaults { default_data_rate default_refclk_freq } {
  variable l_default_data_rate
  variable l_default_refclk_freq

  set l_default_data_rate $default_data_rate
  set l_default_refclk_freq $default_refclk_freq
}


###
# Initialize support for the pushing down the data rate to the package. Overrides
# default package behavior. Pushing down the data rate changes the behavior of
# the selected Main TX PLL such that the PLL data rate is populated as a list
# of options rather than a user entered String. Must be called before the 
# "initialize" routine.
#
# @param value - (0,1) Disable,Enable support for data rate pushdown
proc ::alt_xcvr::gui::pll_reconfig::init_pushdown_main_pll { value } {
  variable pkg_string
  variable l_pushdown_main_pll

  if {$value != 0 && $value != 1} {
    ::alt_xcvr::gui::messages::internal_error_message "Package ${pkg_string}::init_pushdown_main_pll illegal value: $value"
    set value 0
  }

  set l_pushdown_main_pll $value
}


###
# Initialize support for pushing down TX PLL counts. Overrides default
# package behavior. Allows the caller to specify the number of TX PLLs,
# number of TX PLL reference clocks, and which PLL is selected as the
# main TX PLL. When doing so, the package does not provide UI parameters
# to query the user for this things.
proc ::alt_xcvr::gui::pll_reconfig::init_pushdown_tx_pll_counts { value } {
  variable pkg_string
  variable l_pushdown_tx_pll_counts

  if {$value != 0 && $value != 1} {
    ::alt_xcvr::gui::messages::internal_error_message "Package ${pkg_string}::init_pushdown_tx_pll_counts illegal value: $value"
    set value 0
  }

  set l_pushdown_tx_pll_counts $value
}

###
# Initialize support for the enable_pll_reconfig parameter. Overrides default
# package behavior. Must be called before the "initialize" routine
#
# @param value - (0,1) Disable,Enable support for enable_pll_reconfig parameter
proc ::alt_xcvr::gui::pll_reconfig::init_support_pll_reconfig { value } {
  variable pkg_string
  variable l_support_pll_reconfig

  if {$value != 0 && $value != 1} {
    ::alt_xcvr::gui::messages::internal_error_message "Package ${pkg_string}::init_support_pll_reconfig illegal value: $value"
    set value 0
  }
  set l_support_pll_reconfig $value
}


###
# Initialize support for mapped parameters. Default behavior of the package uses parameter
# mapping. This can lead to unpredictable behavior and a mismatch between displayed values and
# actual parameter values. 
#
# @param value - (0,1) Disable,Enable support for mapped parameters
proc ::alt_xcvr::gui::pll_reconfig::init_mapping { value } {
  variable pkg_string
  variable l_mapping

  if {$value != 0 && $value != 1} {
    ::alt_xcvr::gui::messages::internal_error_message "Package ${pkg_string}::init_mapping illegal value: $value"
    set value 0
  }
  set l_mapping $value
}


###
# Configure the package. Required! Allows user to set the conditions for the package. Allows further restriction
# of the values during initialization
#
# @param device_family - May be overloaded to contain "device_family*speedgrade"
# @param new_pll_count - New count for max number of PLLs. Must be <= the value given during initialization.
# @param new_refclk_count - New count for max number of reference clocks. Must be <= the value given during initialization.
# @param allowed_pll_types - A list of allowed PLL types
# @param enable_cdr_refclk_select - Optional. 1 enables support for separate CDR reference clock (must be supported via initialize call)
# @param enable_pll_reconfig - Optional. 1 enables support for PLL reconfiguration (displays checkbox).
# @param allowed_clk_network_sel - A list of allowed clock network selections
#
proc ::alt_xcvr::gui::pll_reconfig::set_config {device_family pll_count refclk_count allowed_pll_types {enable_cdr_refclk_select 0} {enable_pll_reconfig 0} {allowed_clk_network_sel "unused"} {enable_ext_pll 0}} {
  set_config_device_family $device_family
  set_config_pll_count $pll_count
  set_config_refclk_count $refclk_count
  set_config_allowed_pll_types $allowed_pll_types
  set_config_allowed_clk_network_sel $allowed_clk_network_sel
  set_config_enable_cdr_refclk_select $enable_cdr_refclk_select
  set_config_enable_pll_reconfig $enable_pll_reconfig
  set_config_enable_external_pll $enable_ext_pll
}


###
# Configure the device family.
#
# @param device_family - May be overloaded to contain "device_family*speedgrade"
#
proc ::alt_xcvr::gui::pll_reconfig::set_config_device_family {device_family} {
  variable l_validated
  variable l_device_family
  # Clear validated flag
  set l_validated 0

  set l_device_family $device_family
}


###
# Configure the number of PLLs.
#
# @param pll_count - New count for max number of PLLs. Must be <= the value given during initialization.
#
proc ::alt_xcvr::gui::pll_reconfig::set_config_pll_count {pll_count} {
  variable l_validated
  variable l_pushdown_tx_pll_counts
  # Clear validated flag
  set l_validated 0
  if {$l_pushdown_tx_pll_counts == 0} {
    set_max_pll_count $pll_count
  }
}


###
# Configure the number of reference clocks.
#
# @param refclk_count - New count for max number of reference clocks. Must be <= the value given during initialization.
#
proc ::alt_xcvr::gui::pll_reconfig::set_config_refclk_count {refclk_count} {
  variable l_validated
  variable l_pushdown_tx_pll_counts

  # Clear validated flag
  set l_validated 0
  if {$l_pushdown_tx_pll_counts == 0} {
    set_max_refclk_count $refclk_count
  }
}


###
# Configure the allowed PLL types.
#
# @param allowed_pll_types - A list of allowed PLL types
#
proc ::alt_xcvr::gui::pll_reconfig::set_config_allowed_pll_types {allowed_pll_types} {
  variable l_validated
  variable l_pll_type_ranges

  # Clear validated flag
  set l_validated 0
  set l_pll_type_ranges $allowed_pll_types
}


###
# Configure the allowed clock network selection options.
#
# @param allowed_clk_network_sel - A list of allowed clock network selections
#
proc ::alt_xcvr::gui::pll_reconfig::set_config_allowed_clk_network_sel {allowed_clk_network_sel} {
  variable l_validated
  variable l_clk_network_sel_ranges

  # Clear validated flag
  set l_validated 0
  set l_clk_network_sel_ranges $allowed_clk_network_sel
}


###
# Configure support for separate CDR/PLL reference clocks.
#
# @param enable_cdr_refclk_select - Optional. 1 enables support for separate CDR reference clock (must be supported via initialize call)
#
proc ::alt_xcvr::gui::pll_reconfig::set_config_enable_cdr_refclk_select {enable_cdr_refclk_select} {
  variable l_validated
  variable l_enable_cdr_refclk_select
  variable l_support_cdr_refclk_select
  variable pkg_string

  # Clear validated flag
  set l_validated 0
  if {$enable_cdr_refclk_select == 0} {
    set l_enable_cdr_refclk_select 0
  } elseif {$l_support_cdr_refclk_select == 1} {
      set l_enable_cdr_refclk_select 1
  } else {
    ::alt_xcvr::gui::messages::internal_error_message "Package ${pkg_string}::set_config illegal value: enable_cdr_refclk_select=$enable_cdr_refclk_select"
  }
  
}


###
# Configure support for PLL the PLL reconfiguration options.
#
# @param enable_pll_reconfig - Optional. 1 enables support for PLL reconfiguration (displays checkbox).
#
proc ::alt_xcvr::gui::pll_reconfig::set_config_enable_pll_reconfig {enable_pll_reconfig} {
  variable l_validated
  variable l_support_pll_reconfig
  variable l_enable_pll_reconfig
  variable pkg_string

  # Clear validated flag
  set l_validated 0
  if { $enable_pll_reconfig == 1 && $l_support_pll_reconfig == 0} {
    ::alt_xcvr::gui::messages::internal_error_message "Package ${pkg_string}::set_config illegal value: enable_pll_reconfig=$enable_pll_reconfig"
  }
  set l_enable_pll_reconfig $enable_pll_reconfig

}

###
#
# @param enable_external_pll - Optional. 1 enables support for external pll (displays checkbox).
#
proc ::alt_xcvr::gui::pll_reconfig::set_config_enable_external_pll {{enable_ext_pll 0}} {
  variable l_validated
  variable l_enable_external_pll

  # Clear validated flag
  set l_validated 0
  set l_enable_external_pll $enable_ext_pll
}


###
#
# Enables or disables the package. If disabled, all of the GUI components will be hidden
#
# @param torf - 1 - Enable the package, 0 - Disable
#
proc ::alt_xcvr::gui::pll_reconfig::set_enabled { {torf 1} } {
  variable l_enabled
  variable l_param_list

  if {[verify_initialized 1] == 0} { return } 

  set value "false"
  if {$torf == 1} {
    set value "true"
  }

  for {set x 0} {$x < [llength $l_param_list]} {incr x} {
    set_parameter_property [lindex $l_param_list $x] VISIBLE $value
  }
}


###
# Specify the maximum number of plls
#
# @param new_pll_count New number of plls to allow
#
proc ::alt_xcvr::gui::pll_reconfig::set_max_pll_count {new_pll_count} {
  variable l_max_pll_count
  variable l_validated
  variable pkg_string

  # Clear validated flag
  set l_validated 0

  if {[verify_initialized 1] == 0} { return 0 }

  if {$new_pll_count <= $l_max_pll_count} {
    # Construct PLL count allowed ranges list
    set ranges {}
    for {set x 1} {$x <= $new_pll_count} {incr x} {
      lappend ranges "${x}"
    }
    if {$new_pll_count == 0} {
      set ranges { "0" }
    }

    ::alt_xcvr::gui::pll_reconfig::map_allowed_range gui_pll_reconfig_pll_count $ranges

    #for {set i 0} {$i < $l_max_pll_count} {incr i} {
    #  set visible false
    #  if {$i < $new_pll_count} { set visible true }
    #  set_display_item_property "TX PLL ${i}" VISIBLE $visible
    #}

    return 1
  } else {
    ::alt_xcvr::gui::messages::internal_error_message "Package ${pkg_string}::set_max_pll_count illegal value: $new_pll_count"
  }
  return 1
}


###
# Sets a new maximum reference clock count. Internal use only
#
# @param new_refclk_count - The new reference clock count. Fails if the new count
#                           exceeds the value given during initialization
proc ::alt_xcvr::gui::pll_reconfig::set_max_refclk_count {new_refclk_count} {
  variable l_max_refclk_count
  variable l_validated
  variable pkg_string

  # Clear validated flag
  set l_validated 0

  if {[verify_initialized 1] == 0} { return 0 }
  if {$new_refclk_count <= $l_max_refclk_count} {
    set ranges {}
    for {set x 1} {$x <= $new_refclk_count} {incr x} {
      lappend ranges "${x}"
    }
    ::alt_xcvr::gui::pll_reconfig::map_allowed_range gui_pll_reconfig_refclk_count  $ranges
  } else {
    ::alt_xcvr::gui::messages::internal_error_message "Package ${pkg_string}::set_max_refclk_count illegal value: $new_refclk_count"
  }
  return 1
}


###
# Provide to this package information about the main TX PLL.
#
# @param refclk_freq - Frequency of the main TX PLL reference clock
# @param output_data_rate - Data rate of the main TX PLL
# @param pll_type - Type of the main TX PLL
# @param enable_att - OPTIONAL - "false","true"
# @param pll_feedback - "internal","PCS","PMA"
# @param pma_width - OPTIONAL - Required if PLL feedback is "PCS" or "PMA". PMA serializer/deserializer width 
# @param pma_data_rate - Required if PLL feedback is "PCS" or "PMA"
# @param byte_serializer - "disabled","2","4"; Required if PLL feedback is "PCS"
# @param clk_network_sel - OPTIONAL - Type of clock network selection
proc ::alt_xcvr::gui::pll_reconfig::set_main_pll_settings {refclk_freq output_data_rate pll_type {enable_att "false"} {pll_feedback "internal"} {pma_width "unused"} {pma_data_rate "unused"} {byte_serializer "disabled"} {clk_network_sel "unused"} } {
  variable pkg_string
  variable l_validated
  variable l_main_pll_data_rate
  variable l_main_refclk_freq
  variable l_main_pll_type
  variable l_main_clk_network_sel
  variable l_main_pll_enable_att
  variable l_main_pll_pll_feedback
  variable l_main_pll_pma_width
  variable l_main_pll_pma_data_rate
  variable l_main_pll_byte_serializer

  # Clear validated flag
  set l_validated 0

  if {[verify_initialized 1] == 0} { return }

  set l_main_pll_data_rate $output_data_rate
  set l_main_refclk_freq $refclk_freq
  set l_main_pll_type $pll_type
  set l_main_clk_network_sel $clk_network_sel
  set l_main_pll_enable_att $enable_att
  set l_main_pll_pll_feedback $pll_feedback
  set l_main_pll_pma_width $pma_width
  set l_main_pll_pma_data_rate $pma_data_rate
  set l_main_pll_byte_serializer $byte_serializer

}


proc ::alt_xcvr::gui::pll_reconfig::set_tx_pll_counts { plls pll_refclk_count main_pll_index } {
  variable l_pushdown_tx_pll_counts
  variable l_pll_count
  variable l_pll_refclk_count
  variable l_main_pll_index

  # Clear validated flag
  set l_validated 0

  if {[verify_initialized 1] == 0} { return }

  set l_pll_count $plls
  set l_pll_refclk_count $pll_refclk_count
  set l_main_pll_index $main_pll_index
}

################## End Initialization and Configuration #####################
#############################################################################



#############################################################################
############################## Validation ###################################

###
# Validation callback. Must be called after "set_reconfig". Must be called prior to any result "get" functions.
#
proc ::alt_xcvr::gui::pll_reconfig::validate {} {
  variable l_max_pll_count
  variable l_pll_data_rate_list
  variable l_pll_type_list
  variable l_pll_type_ranges
  variable l_refclk_sel_list
  variable l_refclk_freq_list
  variable l_clk_network_sel_list
  variable l_clk_network_sel_ranges
  variable l_device_family
  variable l_main_pll_data_rate
  variable l_main_refclk_freq
  variable l_main_pll_type
  variable l_main_clk_network_sel
  variable l_main_pll_enable_att
  variable l_main_pll_pll_feedback
  variable l_main_pll_pma_width
  variable l_main_pll_pma_data_rate
  variable l_main_pll_byte_serializer
  variable l_enable_cdr_refclk_select 
  variable l_support_cdr_refclk_select 
  variable l_support_clk_network_sel
  variable l_enable_pll_reconfig
  variable l_support_pll_reconfig
  variable l_enable_external_pll
  variable l_validated
  variable l_pushdown_main_pll
  variable l_pushdown_tx_pll_counts
  variable l_data_rate

  if {[verify_initialized 1] == 0} { return }
  # Set validated flag
  set l_validated 1

  # Hide PLL options when external PLL used.
  if {$l_enable_external_pll == 1} {
    set pll_param_visible "false"
  } else {
    set pll_param_visible "true"
  }

  
  # Show or HIDE PLL reconfig support checkbox
  if {$l_support_pll_reconfig == 1} {
    set visible "true"
    if {$l_enable_pll_reconfig == 0} {
      set visible "false"
    }
    set_parameter_property gui_pll_reconfig_enable_pll_reconfig VISIBLE $visible
  }

  set temp_pll_count [get_pll_count]
  set temp_refclk_count [get_refclk_count]
  if { $temp_pll_count == 0 } {
    set tx_enable 0
  } else {
    set tx_enable 1
  }

  # Determine maximum PLL index
  if { $tx_enable == 1 } {
    set visible "true"
    set ranges  {}
    for {set x 0} {$x < $temp_pll_count} {incr x} {
      lappend ranges $x
    }
  } else {
    set visible "false"
    set ranges { "0" }
  }

  if {$l_pushdown_tx_pll_counts == 0} {
    # Update allowed ranges for Main PLL
    ::alt_xcvr::gui::pll_reconfig::map_allowed_range gui_pll_reconfig_main_pll_index $ranges $tx_enable
    # Hide Main TX PLL if no TX
    set_parameter_property gui_pll_reconfig_main_pll_index VISIBLE $visible
    set_parameter_property gui_pll_reconfig_pll_count VISIBLE $visible
    # Hide the reference clock count if neither TX or RX is enabled.
    if {$tx_enable == 0 && $l_enable_cdr_refclk_select == 0} {
      set_parameter_property gui_pll_reconfig_refclk_count VISIBLE false
    } else {
      set_parameter_property gui_pll_reconfig_refclk_count VISIBLE true
    }
  }

  # Determine which PLL is the selected PLL
  set main_pll_index [get_main_pll_index]

  # Determine maximum refclk index
  set refclk_sel_ranges {} 
  for {set x 0} {$x < $temp_refclk_count} {incr x} {
    lappend refclk_sel_ranges $x
  }

  # Hide the CDR refclk selection if not enabled
  if { $l_enable_cdr_refclk_select == 1 } {
    # Set ranges for CDR refclk select
    ::alt_xcvr::gui::pll_reconfig::map_allowed_range gui_pll_reconfig_cdr_pll_refclk_sel $refclk_sel_ranges
    set_parameter_property gui_pll_reconfig_cdr_pll_refclk_sel VISIBLE "true"
  } elseif {$l_support_cdr_refclk_select == 1 } {
    ::alt_xcvr::gui::pll_reconfig::map_allowed_range gui_pll_reconfig_cdr_pll_refclk_sel $refclk_sel_ranges
    set_parameter_property gui_pll_reconfig_cdr_pll_refclk_sel VISIBLE "false"
  }

  
  set l_pll_type_list {}
  set l_pll_data_rate_list {}
  set l_clk_network_sel_list {}
  set l_refclk_sel_list {}
  set l_refclk_freq_list {}
  for {set x 0} {$x < $l_max_pll_count} {incr x} {

    # Set visibility and enabled
    set temp_enabled "true"
    set int_enabled 1
    if [expr {$x >= $temp_pll_count}] {
      set temp_enabled "false"
      set int_enabled 0
    }
    set_display_item_property "TX PLL ${x}" VISIBLE $temp_enabled

    # Set allowed ranges for and refclk sel
    ::alt_xcvr::gui::pll_reconfig::map_allowed_range "gui_pll_reconfig_pll${x}_refclk_sel" $refclk_sel_ranges $int_enabled
    lappend l_refclk_sel_list [::alt_xcvr::gui::pll_reconfig::get_mapped_allowed_range_value "gui_pll_reconfig_pll${x}_refclk_sel"]
	set_parameter_property "gui_pll_reconfig_pll${x}_refclk_sel" VISIBLE $pll_param_visible 
	
    # Set allowed ranges for PLL type
    if {$x == $main_pll_index && $l_pushdown_main_pll == 1} {
      ::alt_xcvr::gui::pll_reconfig::map_allowed_range "gui_pll_reconfig_pll${x}_pll_type" [list $l_main_pll_type] $int_enabled
    } else {
      ::alt_xcvr::gui::pll_reconfig::map_allowed_range "gui_pll_reconfig_pll${x}_pll_type" $l_pll_type_ranges $int_enabled
    }
    set this_pll_type [::alt_xcvr::gui::pll_reconfig::get_mapped_allowed_range_value "gui_pll_reconfig_pll${x}_pll_type"]
    lappend l_pll_type_list $this_pll_type
	set_parameter_property "gui_pll_reconfig_pll${x}_pll_type" VISIBLE $pll_param_visible 


    # Set allowed ranges for PLL data rate for the main PLL
    set_parameter_value "gui_pll_reconfig_pll${x}_data_rate_der" $l_main_pll_data_rate

    if {$x == $main_pll_index} {
      lappend l_pll_data_rate_list $l_main_pll_data_rate
    } else {
      lappend l_pll_data_rate_list  [get_parameter_value "gui_pll_reconfig_pll${x}_data_rate"]
    }

    # Set allowed ranges for refclk  frequency
    if {$x == $main_pll_index && $l_pushdown_main_pll == 1} {
      ::alt_xcvr::gui::pll_reconfig::map_allowed_range "gui_pll_reconfig_pll${x}_refclk_freq" [list $l_main_refclk_freq] $int_enabled
    } else {
      set result {"unused"}
      if { $x < $temp_pll_count } {
        set this_data_rate [lindex $l_pll_data_rate_list $x]
        # Data rate validation
        if { ![::alt_xcvr::utils::common::validate_data_rate_string $this_data_rate] } {
          send_message error "The specified data rate for TX PLL $x is improperly formatted"
          ::alt_xcvr::gui::messages::data_rate_format_error
        }

        if {$x == $main_pll_index} {
          # We need to accomodate for PCS/PMA feedback mode for the main PLL
          set result \
            [::alt_xcvr::utils::rbc::get_valid_refclks  $l_device_family \
                                                    [lindex $l_pll_data_rate_list $x] \
                                                    [lindex $l_pll_type_list $x] \
                                                    $l_main_pll_enable_att \
                                                    $l_main_pll_pll_feedback \
                                                    $l_main_pll_pma_width \
                                                    $l_main_pll_pma_data_rate \
                                                    $l_main_pll_byte_serializer]
        } else {
          # Assume no feedback for non-Main PLL
          set result \
            [::alt_xcvr::utils::rbc::get_valid_refclks  $l_device_family \
                                                  [lindex $l_pll_data_rate_list $x] \
                                                  [lindex $l_pll_type_list $x]]
        }

        if {$result == "N/A"} {
          send_message error "The selected data rate \"[lindex $l_pll_data_rate_list $x]\" for TX PLL $x cannot be achieved for the selected PLL type and channel configuration."
          set result {}
        }

        set refclk_freq [::alt_xcvr::gui::pll_reconfig::get_mapped_allowed_range_value "gui_pll_reconfig_pll${x}_refclk_freq"]
        # Issue message if current selected value is illegal
        if {[lsearch $result $refclk_freq] == -1 && $l_enable_external_pll == 0 } {
          send_message error "The selected reference clock frequency \"$refclk_freq\" for TX PLL ${x} is invalid. Please change the PLL reference clock frequency or choose a different data rate."
          lappend result $refclk_freq
        }

      }
	  if { $l_enable_external_pll == 0 } {
        ::alt_xcvr::gui::pll_reconfig::map_allowed_range "gui_pll_reconfig_pll${x}_refclk_freq" $result $int_enabled
	  }
    }
    lappend l_refclk_freq_list [::alt_xcvr::gui::pll_reconfig::get_mapped_allowed_range_value "gui_pll_reconfig_pll${x}_refclk_freq"]
	set_parameter_property "gui_pll_reconfig_pll${x}_refclk_freq" VISIBLE $pll_param_visible 

    # Set allowed ranges for clock network

    if {$l_support_clk_network_sel == 1} {
      if {$x == $main_pll_index && $l_pushdown_main_pll == 1} {
        ::alt_xcvr::gui::pll_reconfig::map_allowed_range "gui_pll_reconfig_pll${x}_clk_network" [list $l_main_clk_network_sel] $int_enabled
      } else {
        ::alt_xcvr::gui::pll_reconfig::map_allowed_range "gui_pll_reconfig_pll${x}_clk_network" $l_clk_network_sel_ranges $int_enabled
      }
     set this_clk_network [::alt_xcvr::gui::pll_reconfig::get_mapped_allowed_range_value "gui_pll_reconfig_pll${x}_clk_network"]
     lappend l_clk_network_sel_list $this_clk_network
    } else {
      set_parameter_property "gui_pll_reconfig_pll${x}_clk_network" VISIBLE false
    }

    set is_main_pll "false"
    if {$x == $main_pll_index} {
      set is_main_pll "true"
    }
    set_pll_enabled $x $temp_enabled $is_main_pll
  }

  validate_refclks $temp_pll_count

}
############################## Validation ###################################
#############################################################################



#############################################################################
######################### "Get" Result Functions ############################

###
# Get the configured reference clock frequencies
#
# @return - String - A list of comma seperated values where the leftmost value indicates
#           the frequency for refclk index 0. Any uninferred frequencies will 
#           show as "unused"
#
proc ::alt_xcvr::gui::pll_reconfig::get_refclk_freq_string {} {
  variable l_refclk_sel_list
  variable l_refclk_freq_list
  variable l_main_refclk_freq
  variable l_enable_cdr_refclk_select

  if {[verify_initialized 1] == 0} { return }
  if {[verify_validated] == 0} { return }

  # Convert PLL refclk list to refclk list
  set refclk_count [get_refclk_count]
  set pll_count [get_pll_count]

  set refclk_freq_list {}
  for {set x 0} {$x < $refclk_count} {incr x} {
    lappend refclk_freq_list "unused"
  }

  for {set x 0} {$x < $pll_count} {incr x} {
    set this_refclk_sel [lindex $l_refclk_sel_list $x]
    set this_refclk_freq [lindex $l_refclk_freq_list $x] 

    if {$this_refclk_sel < $refclk_count} { 
      set refclk_freq_list [lreplace $refclk_freq_list $this_refclk_sel $this_refclk_sel $this_refclk_freq]
    }
  }

  # Get CDR refclk
  set cdr_refclk_sel 0
  if {$l_enable_cdr_refclk_select == 1} {
    set cdr_refclk_sel [get_cdr_refclk_sel]
    set refclk_freq_list [lreplace $refclk_freq_list $cdr_refclk_sel $cdr_refclk_sel $l_main_refclk_freq]
  }

  return [get_string_from_list $refclk_freq_list $refclk_count]
}


###
# Get the configured reference clock selections for the TX PLLs.
#
# @return - String - A list of comma seperated values where the leftmost value indicates
#           the selected reference clock index for PLL 0
#
proc ::alt_xcvr::gui::pll_reconfig::get_refclk_sel_string {} {
  variable l_refclk_sel_list
  if {[verify_initialized 1] == 0} { return }
  if {[verify_validated] == 0} { return }

  return [get_string_from_list $l_refclk_sel_list [get_pll_count]]
}


###
# Get the configured reference clock index for the CDR PLL. This function cannot be called unless
# CDR reference clock selection has been enabled via initialization and configuration.
#
# @return - Integer
#
proc ::alt_xcvr::gui::pll_reconfig::get_cdr_refclk_sel {} {
  variable l_enable_cdr_refclk_select
  variable pkg_string

  if {[verify_initialized 1] == 0} { return }
  if {[verify_validated] == 0} { return }

  # Verify that CDR refclk selection is enabled
  if {$l_enable_cdr_refclk_select == 0} {
    ::alt_xcvr::gui::messages::internal_error_message "Package ${pkg_string}::get_cdr_refclk_sel CDR refclk selection not enabled!"
    return
  } else {
    return [::alt_xcvr::gui::pll_reconfig::get_mapped_allowed_range_value gui_pll_reconfig_cdr_pll_refclk_sel]
  }
}


###
# Get the configured PLL types.
#
# @return - String - List of comma separated values where the leftmost value
#           corresponds to PLL 0
proc ::alt_xcvr::gui::pll_reconfig::get_pll_type_string {} {
  variable l_pll_type_list
  if {[verify_initialized 1] == 0} { return }
  if {[verify_validated] == 0} { return }

  return [get_string_from_list $l_pll_type_list [get_pll_count]]
}


###
# Get the PLL type for a specified index
#
# @return - String - PLL type corresponding to PLL <index>
proc ::alt_xcvr::gui::pll_reconfig::get_pll_type { index } {
  variable l_pll_type_list
  if {[verify_initialized 1] == 0} { return }
  if {[verify_validated] == 0} { return }

  return [lindex $l_pll_type_list $index]
}

###
# Get the configured clock network
#
# @return - String - List of comma separated values where the leftmost value
#           corresponds to PLL 0
proc ::alt_xcvr::gui::pll_reconfig::get_clk_network_sel_string {} {
  variable l_clk_network_sel_list
  if {[verify_initialized 1] == 0} { return }
  if {[verify_validated] == 0} { return }

  return [get_string_from_list $l_clk_network_sel_list [get_pll_count]]
}

###
# Get the configured PLL data rates.
#
# @return - String - List of comma separated values where the leftmost value
#           corresponds to PLL 0
proc ::alt_xcvr::gui::pll_reconfig::get_pll_data_rate_string {} {
  variable l_pll_data_rate_list
  if {[verify_initialized 1] == 0} { return }
  if {[verify_validated] == 0} { return }

  return [get_string_from_list $l_pll_data_rate_list [get_pll_count]]
}


###
# Get the configured number of TX PLLs
#
# @return - Integer
proc ::alt_xcvr::gui::pll_reconfig::get_pll_count {} {
  variable l_pushdown_tx_pll_counts
  variable l_pll_count

  if {[verify_initialized 1] == 0} { return }
  if {[verify_validated] == 0} { return }

  if {$l_pushdown_tx_pll_counts == 1} {
    return $l_pll_count
  } else {
    return [::alt_xcvr::gui::pll_reconfig::get_mapped_allowed_range_value gui_pll_reconfig_pll_count]
  }
}


###
# Get the configured index of the main TX PLL
#
# @return - Integer
#
proc ::alt_xcvr::gui::pll_reconfig::get_main_pll_index {} {
  variable l_pushdown_tx_pll_counts
  variable l_main_pll_index

  if {[verify_initialized 1] == 0} { return }
  if {[verify_validated] == 0} { return }

  if {$l_pushdown_tx_pll_counts == 1} {
    return $l_main_pll_index
  } else {
    return [::alt_xcvr::gui::pll_reconfig::get_mapped_allowed_range_value gui_pll_reconfig_main_pll_index]
  }
}


###
# Get the configured number of supported reference clocks
#
# @return - Integer
#
proc ::alt_xcvr::gui::pll_reconfig::get_refclk_count {} {
  variable l_pushdown_tx_pll_counts
  variable l_pll_refclk_count

  if {[verify_initialized 1] == 0} { return }
  if {[verify_validated] == 0} { return }

  if {$l_pushdown_tx_pll_counts == 1} {
    return $l_pll_refclk_count
  } else {
    return [::alt_xcvr::gui::pll_reconfig::get_mapped_allowed_range_value gui_pll_reconfig_refclk_count]
  }
}

###
# Determine whether PLL reconfiguration is enabled
# @return - Integer - 1=PLL reconfiguration is enabled, 0=PLL reconfiguration is not enabled.
proc ::alt_xcvr::gui::pll_reconfig::get_pll_reconfig {} {
  variable l_enable_pll_reconfig

  if {[verify_initialized 1] == 0} { return }
  if {[verify_validated] == 0} { return }

  set pll_reconfig [get_parameter_value gui_pll_reconfig_enable_pll_reconfig]
  if {$pll_reconfig == "true"} {
    set pll_reconfig 1
  } else { 
    set pll_reconfig 0
  }
  return $pll_reconfig
}

###################### End "Get" Result Functions ###########################
#############################################################################



#############################################################################
########################## Internal Functions ###############################

###
# Enable or disable a particular PLL. Hides the PLL from the display and performs
# no validation of its values if the PLL is disabled. A PLL may be visible but
# not enabled.
#
# @param pll_index - The index of the PLL to enable/disable
# @param enabled - true=enable, false=disable
# @param is_main_pll - true=treat as main PLL
#
proc ::alt_xcvr::gui::pll_reconfig::set_pll_enabled { pll_index enabled is_main_pll } {
  set der_enabled "false"
  if {$is_main_pll == "true" && $enabled == "true"} {
    set der_enabled true
  }

  set der_enabled_n "false"
  if {$der_enabled == "false"} {
    set der_enabled_n "true"
  }

  set x $pll_index
  set_parameter_property "gui_pll_reconfig_pll${x}_pll_type"      ENABLED $enabled
# set_parameter_property "gui_pll_reconfig_pll${x}_pll_type"      VISIBLE $enabled
  set_parameter_property "gui_pll_reconfig_pll${x}_refclk_freq"   ENABLED $enabled
# set_parameter_property "gui_pll_reconfig_pll${x}_refclk_freq"   VISIBLE $enabled
  set_parameter_property "gui_pll_reconfig_pll${x}_refclk_sel"    ENABLED $enabled
# set_parameter_property "gui_pll_reconfig_pll${x}_refclk_sel"    VISIBLE $enabled

  set_parameter_property "gui_pll_reconfig_pll${x}_data_rate"     ENABLED $enabled
  set_parameter_property "gui_pll_reconfig_pll${x}_data_rate"     VISIBLE $der_enabled_n
  set_parameter_property "gui_pll_reconfig_pll${x}_data_rate_der" ENABLED $enabled
  set_parameter_property "gui_pll_reconfig_pll${x}_data_rate_der" VISIBLE $der_enabled
  
  set_parameter_property "gui_pll_reconfig_pll${x}_clk_network"   ENABLED $enabled
}


###
# Validate that all the reference clock selections and frequencies
# correlate. Issue an error if they do not. Basically no reference
# clock can be configured to two different frequencies
#
# @parameter pll_count (The number of PLLs)
#
proc ::alt_xcvr::gui::pll_reconfig::validate_refclks { pll_count } {
  variable l_pll_data_rate_list
  variable l_pll_type_list
  variable l_refclk_sel_list
  variable l_refclk_freq_list
  variable l_main_refclk_freq
  variable l_enable_cdr_refclk_select 

  # Get refclk for comparison
  set cdr_refclk_sel 0
  if {$l_enable_cdr_refclk_select == 1} {
    set cdr_refclk_sel [get_cdr_refclk_sel]
  }

  for {set x 0} {$x < $pll_count} {incr x} {
      set this_refclk_sel [lindex $l_refclk_sel_list $x]
      set this_refclk_freq [lindex $l_refclk_freq_list $x] 
    for {set y [expr {$x + 1}]} {$y < $pll_count} {incr y} {
      set that_refclk_sel [lindex $l_refclk_sel_list $y]
      if { $this_refclk_sel == $that_refclk_sel } {
        set that_refclk_freq [lindex $l_refclk_freq_list $y] 
        if { $this_refclk_freq  != $that_refclk_freq } {
          send_message warning "Logical PLL ${x} and Logical PLL ${y} specify the same logical input clock (${this_refclk_sel}) with different frequencies."
          return
        }
      }
    }

    # Validate against CDR refclk select
    # The refclk frequency for the CDR PLL must match the refclk frequency for the main PLL
    if {$l_enable_cdr_refclk_select == 1} {
      if {$this_refclk_sel == $cdr_refclk_sel} {
          if { $this_refclk_freq != $l_main_refclk_freq } {
            send_message error "Logical PLL ${x} and the CDR PLL specify the same logical input clock (${this_refclk_sel}) with different frequencies. The reference clock frequency for the CDR PLL must match the reference clock frequency for the main TX PLL"
            return
          }
      }
    }

  }
}


###
# Add a parameter to the UI. Common function for easy parameter adding.
#
# @param group - The display group to add the parameter to.
# @param name - The name of the parameter.
# @param type - The type of the parameter (STRING, INTEGER, BOOLEAN, etc.)
# @param default - The default value of the parameter.
# @param display_name - The display name of the parameter.
# @param allowed_ranges - Optional. The initial allowed ranges of the parameter
#
proc ::alt_xcvr::gui::pll_reconfig::add_gui_parameter {group name type default display_name {allowed_ranges "default"}} {
  variable l_param_list
  add_parameter $name $type $default
  set_parameter_property $name DEFAULT_VALUE $default
  set_parameter_property $name DISPLAY_NAME $display_name
  set_parameter_property $name AFFECTS_GENERATION true
  set_parameter_property $name HDL_PARAMETER false
  set_parameter_property $name ENABLED true
  #set_parameter_property $name VISIBLE true
  #set_parameter_property $name VISIBLE false
  add_display_item $group $name parameter
  if {$allowed_ranges != "default"} {
    set_parameter_property $name ALLOWED_RANGES $allowed_ranges
  }

  lappend l_param_list $name
}

               
###
# Verify that the package has been initialized. Internal use only. Caller can verify
# that the package either has or has not been initialized. Displays an error message
# if the current value does not match the expected value
#
# @param torf The expected initialization value.
# 
# @return 1 if the test passed, 0 otherwise
#
proc ::alt_xcvr::gui::pll_reconfig::verify_initialized {torf} {
  variable l_initialized
  variable pkg_string

  if {$l_initialized == $torf} {
    return 1
  }

  if {$torf == 0} {
    ::alt_xcvr::gui::messages::internal_error_message "Package ${pkg_string} already initialized"
  } else {
    ::alt_xcvr::gui::messages::internal_error_message "Package ${pkg_string}: Package not initialzied"
  }
  return 0

}

###
# Verify that the package has been validated. Internal use only.
# 
# @return 1 if the test passed, 0 otherwise
#
proc ::alt_xcvr::gui::pll_reconfig::verify_validated {} {
  variable l_validated
  variable pkg_string

  if {$l_validated == 0} {
    ::alt_xcvr::gui::messages::internal_error_message "Package ${pkg_string}: Validation not performed!" 
  }

  return $l_validated
}

###
# Convert a list to a comma seperated string of values.
#
# @param t_list - The list of values to convert to a string
# @param t_count - The number of values in the list
#
# @return - A string of comma seperated values. The leftmost value represents index
#           0 within the list.
#
proc ::alt_xcvr::gui::pll_reconfig::get_string_from_list {t_list t_count} {
  set t_string [lindex $t_list 0]
  for {set x 1} {$x < $t_count} {incr x} {
    set this_string [lindex $t_list $x]
    set t_string "${t_string},${this_string}"
  }

  return $t_string
}


proc ::alt_xcvr::gui::pll_reconfig::map_allowed_range { parameter ranges { enabled 1 }} {
  variable l_mapping

  if {$l_mapping} {
    ::alt_xcvr::utils::common::map_allowed_range $parameter $ranges
  } else {
    if { !$enabled } {
      set value [get_parameter_value $parameter]
      set ranges [list $value]
    }
    set_parameter_property $parameter ALLOWED_RANGES $ranges
  }
}


proc ::alt_xcvr::gui::pll_reconfig::get_mapped_allowed_range_value { parameter } {
  variable l_mapping

  if {$l_mapping} {
    return [::alt_xcvr::utils::common::get_mapped_allowed_range_value $parameter]
  } else {
    return [get_parameter_value $parameter]
  }
}
######################## End Internal Functions #############################
#############################################################################
               
