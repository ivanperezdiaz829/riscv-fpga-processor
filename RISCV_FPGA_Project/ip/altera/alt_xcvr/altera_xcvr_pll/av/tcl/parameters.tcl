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


package provide altera_xcvr_pll_av::parameters 12.0

package require alt_xcvr::ip_tcl::ip_module
package require alt_xcvr::ip_tcl::messages
package require alt_xcvr::gui::pll_reconfig
package require alt_xcvr::gui::messages
package require alt_xcvr::utils::device

namespace eval ::altera_xcvr_pll_av::parameters:: {
  namespace import ::alt_xcvr::ip_tcl::ip_module::*
  namespace import ::alt_xcvr::ip_tcl::messages::*

  namespace export \
    declare_parameters \
    validate

  variable parameters

  set parameters {\
    {NAME                                   DERIVED HDL_PARAMETER TYPE      DEFAULT_VALUE ALLOWED_RANGES          ENABLED     VISIBLE DISPLAY_HINT  DISPLAY_UNITS DISPLAY_ITEM  DISPLAY_NAME                        VALIDATION_CALLBACK                                                     DESCRIPTION }\
    {device_family                          false   false         STRING    "Arria V"    { "Arria V" }            true        false   NOVAL         NOVAL         NOVAL         NOVAL                               NOVAL                                                                   NOVAL       }\
    {plls                                   true    true          INTEGER   1             NOVAL                   false       false   NOVAL         NOVAL         NOVAL         "Number of PLLs"                    NOVAL                                                                   "Number of PLLs"}\
    {pll_type                               true    true          STRING    "CMU"         NOVAL                   true        false   NOVAL         NOVAL         NOVAL         NOVAL                               ::altera_xcvr_pll_av::parameters::validate_pll_type                     NOVAL       }\
    {pll_reconfig                           false   true          INTEGER   0             NOVAL                   true        true    boolean       NOVAL         NOVAL         "Enable PLL reconfiguration"        NOVAL                                                                   "Enabling this option has two effects: 1-The simulation model for the TX PLL will include support for dynamic reconfiguration. 2-Quartus will not merge the TX PLLs by default. Merging can be manually controlled through QSF assignments. Dynamic reconfiguration includes reference clock switching and data rate reconfiguration. Dynamic reconfiguration of ATX PLLs is not supported in the current release."}\
    {refclks                                false   true          INTEGER   1             {1 2 3 4 5}             true        true    NOVAL         NOVAL         NOVAL         "Number of TX PLL reference clocks" NOVAL                                                                   "Specifies the number of input reference clocks for the TX PLL."}\
    {reference_clock_frequency              true    true          STRING    "125.0 MHz"   NOVAL                   true        false   NOVAL         NOVAL         NOVAL         NOVAL                               ::altera_xcvr_pll_av::parameters::validate_reference_clock_frequency    NOVAL       }\
    {reference_clock_select                 true    true          STRING    "0"           NOVAL                   true        false   NOVAL         NOVAL         NOVAL         NOVAL                               ::altera_xcvr_pll_av::parameters::validate_reference_clock_select       NOVAL       }\
    {set_data_rate                          true    false         STRING    "0"    		  NOVAL                   true        false   NOVAL         NOVAL         NOVAL         "PLL output data rate"              NOVAL             NOVAL       }\
    {output_clock_datarate                  true    true          STRING    NOVAL         NOVAL                   true        false   NOVAL         NOVAL         NOVAL         NOVAL                               ::altera_xcvr_pll_av::parameters::validate_output_clock_datarate        NOVAL       }\
    {output_clock_frequency                 true    true          STRING    "0 ps"        NOVAL                   false       false   NOVAL         NOVAL         NOVAL         NOVAL                               NOVAL                                                                   NOVAL       }\
    {feedback_clk                           false   true          STRING    "internal"    {"internal"}            true        false   NOVAL         NOVAL         NOVAL         "PLL feedback path"                 NOVAL                                                                   NOVAL       }\
    \
    {sim_additional_refclk_cycles_to_lock   true    true          INTEGER   0             NOVAL                   false       false   NOVAL         NOVAL         NOVAL         NOVAL                               NOVAL                                                                   NOVAL       }\
    {duty_cycle                             true    true          INTEGER   50            NOVAL                   false       false   NOVAL         NOVAL         NOVAL         NOVAL                               NOVAL                                                                   NOVAL       }\
    {phase_shift                            true    true          STRING    "0 ps"        NOVAL                   false       false   NOVAL         NOVAL         NOVAL         NOVAL                               NOVAL                                                                   NOVAL       }\
    \
    {enable_hclk                            true    true          INTEGER   0             NOVAL                   false       false   NOVAL         NOVAL         NOVAL         NOVAL                               NOVAL                                                                   NOVAL       }\
    {enable_avmm                            true    true          INTEGER   1             NOVAL                   false       false   NOVAL         NOVAL         NOVAL         NOVAL                               NOVAL                                                                   NOVAL       }\
    {use_generic_pll                        true    true          INTEGER   0             NOVAL                   false       false   NOVAL         NOVAL         NOVAL         NOVAL                               NOVAL                                                                   NOVAL       }\
    {enable_mux                             true    true          INTEGER   1             NOVAL                   false       false   NOVAL         NOVAL         NOVAL         NOVAL                               NOVAL                                                                   NOVAL       }\
    \
	{l_pll_settings                         true    false         INTEGER   0             NOVAL                   true        false   NOVAL         NOVAL         NOVAL         NOVAL                               ::altera_xcvr_pll_av::parameters::validate_l_pll_settings               NOVAL       }\
    {l_rcfg_to_xcvr_width                   true    false         INTEGER   0             NOVAL                   true        false   NOVAL         NOVAL         NOVAL         NOVAL                               ::altera_xcvr_pll_av::parameters::validate_l_rcfg_to_xcvr_width         NOVAL       }\
    {l_rcfg_from_xcvr_width                 true    false         INTEGER   0             NOVAL                   true        false   NOVAL         NOVAL         NOVAL         NOVAL                               ::altera_xcvr_pll_av::parameters::validate_l_rcfg_from_xcvr_width       NOVAL       }\
  }
}

proc ::altera_xcvr_pll_av::parameters::declare_parameters { {device_family "Arria V"} } {
  variable parameters
  ip_declare_parameters $parameters

  ip_set "parameter.device_family.SYSTEM_INFO" DEVICE_FAMILY
  ip_set "parameter.device_family.DEFAULT_VALUE" $device_family
  ip_set "parameter.device_family.ALLOWED_RANGES" [list $device_family]
  # Initialize pll_reconfig gui package
  ::alt_xcvr::gui::pll_reconfig::init_pll_defaults "1250 Mbps" "125.0 MHz"
  ::alt_xcvr::gui::pll_reconfig::init_pushdown_main_pll 0
  ::alt_xcvr::gui::pll_reconfig::init_pushdown_tx_pll_counts 1
  ::alt_xcvr::gui::pll_reconfig::init_support_pll_reconfig 0
  ::alt_xcvr::gui::pll_reconfig::init_mapping 0
  ::alt_xcvr::gui::pll_reconfig::initialize "PLL Reconfiguration" 1 5 0
  ::alt_xcvr::gui::pll_reconfig::set_config_refclk_count 5
  ::alt_xcvr::gui::pll_reconfig::set_config_allowed_pll_types [::alt_xcvr::utils::device::get_hssi_pll_types $device_family]
  ::alt_xcvr::gui::pll_reconfig::set_config_enable_cdr_refclk_select 0
  ::alt_xcvr::gui::pll_reconfig::set_config_enable_pll_reconfig 0
}

proc ::altera_xcvr_pll_av::parameters::validate {} {
  ip_validate_parameters
}

##########################################################################
####################### Validation Callbacks #############################

proc ::altera_xcvr_pll_av::parameters::validate_pll_type { l_pll_settings } {
  ip_set "parameter.pll_type.value" [::alt_xcvr::gui::pll_reconfig::get_pll_type_string]
}

proc ::altera_xcvr_pll_av::parameters::validate_output_clock_datarate { l_pll_settings set_data_rate output_clock_datarate} {
  ip_set "parameter.output_clock_datarate.value" $set_data_rate
  ip_message info "::altera_xcvr_pll_av::parameters::validate_output_clock_datarate: $output_clock_datarate"
}


proc ::altera_xcvr_pll_av::parameters::validate_reference_clock_frequency { l_pll_settings } {
  ip_set "parameter.reference_clock_frequency.value" [::alt_xcvr::gui::pll_reconfig::get_refclk_freq_string]
}

###
# Validation for the reference_clock_select parameter
#
# @param l_pll_settings - Placed here merely to force validation of l_pll_settings before this
proc ::altera_xcvr_pll_av::parameters::validate_reference_clock_select { l_pll_settings } {
  ip_set "parameter.reference_clock_select.value" [::alt_xcvr::gui::pll_reconfig::get_refclk_sel_string] 
}


###
# 
# Validation for l_pll_settings parameter. Used to run configuration
# and validation of the pll_reconfig package.
#
# @param device_family - Resolved value of device_family parameter
proc ::altera_xcvr_pll_av::parameters::validate_l_pll_settings { device_family set_data_rate refclks } {

  set set_data_rate $set_data_rate
  
  ::alt_xcvr::gui::pll_reconfig::set_config $device_family 1 5 [::alt_xcvr::utils::device::get_hssi_pll_types $device_family] 0 0; # 1 PLLs, 5 refclks, types, enable rx refclk sel, enable PLL reconfig
  ::alt_xcvr::gui::pll_reconfig::set_main_pll_settings "unused" $set_data_rate "unused"
  ::alt_xcvr::gui::pll_reconfig::set_tx_pll_counts 1 $refclks 1
  ::alt_xcvr::gui::pll_reconfig::validate
  
  ip_set "parameter.set_data_rate.value" [::alt_xcvr::gui::pll_reconfig::get_pll_data_rate_string]
  
  ip_message info "::altera_xcvr_pll_av::parameters::validate_l_pll_settings: $set_data_rate"
}

proc ::altera_xcvr_pll_av::parameters::validate_l_rcfg_to_xcvr_width { device_family } {
   ip_set "parameter.l_rcfg_to_xcvr_width.value" [::alt_xcvr::utils::device::get_reconfig_to_xcvr_total_width $device_family 1]
}


proc ::altera_xcvr_pll_av::parameters::validate_l_rcfg_from_xcvr_width { device_family } {
  ip_set "parameter.l_rcfg_from_xcvr_width.value" [::alt_xcvr::utils::device::get_reconfig_from_xcvr_total_width $device_family 1]
}


####################### Validation Callbacks #############################
##########################################################################
