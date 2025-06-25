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


## \file mcgb.tcl
# lists all the parameters used in Master CGB, as well as associated validation callbacks

package provide mcgb_package_vi::mcgb 13.1

## \todo review below
package require alt_xcvr::ip_tcl::ip_module
package require alt_xcvr::ip_tcl::messages
package require alt_xcvr::gui::messages
package require alt_xcvr::utils::device
package require alt_xcvr::utils::common

namespace eval ::mcgb_package_vi::mcgb:: {
   namespace import ::alt_xcvr::ip_tcl::ip_module::*
   namespace import ::alt_xcvr::ip_tcl::messages::*

   namespace export \
      set_mcgb_display_item_properties \
      declare_mcgb_display_items \
      set_protocol_mode_maps_from \
      set_silicon_rev_maps_from \
      set_output_clock_frequency_maps_from \
      set_hip_cal_done_enable_maps_from \
      declare_mcgb_parameters \
      declare_mcgb_interfaces \

   variable mcgb_display_items
 
   variable mcgb_parameters
   variable pll_parameters_used_in_mcgb_validation_callbacks
   variable mcgb_atom_parameters
   variable mcgb_parameters_to_be_removed

   variable mcgb_interfaces

   set mcgb_display_items {\
      {NAME                             GROUP                              ENABLED             VISIBLE   TYPE   ARGS  }\
      {"Master Clock Generation Block"  ""                                 NOVAL               NOVAL     GROUP  TAB   }\
      {"MCGB"                           "Master Clock Generation Block"    NOVAL               NOVAL     GROUP  NOVAL }\
      {"Bonding"                        "Master Clock Generation Block"    NOVAL               NOVAL     GROUP  NOVAL }\
   }

   set mcgb_parameters {\
      {NAME                                      M_CONTEXT M_USED_FOR_RCFG M_SAME_FOR_RCFG DERIVED HDL_PARAMETER TYPE      DEFAULT_VALUE         ENABLED               VISIBLE DISPLAY_HINT DISPLAY_UNITS DISPLAY_ITEM  DISPLAY_NAME                                            ALLOWED_RANGES                                         VALIDATION_CALLBACK                                           DESCRIPTION }\
      {enable_mcgb                               NOVAL     1               1               false   true          INTEGER   0                     true                  true    BOOLEAN      NOVAL         "MCGB"        "Include Master Clock Generation Block"                 NOVAL                                                  NOVAL                                                         "When enabled Master CGB will be included as part of IP an PLL output will feed Master CGB input as well."}\
      {mcgb_div                                  NOVAL     1               1               false   false         INTEGER   1                     enable_mcgb           true    NOVAL        NOVAL         "MCGB"        "Clock division factor"                                 { 1 2 4 8 }                                            NOVAL                                                         "Divides the Master CGB clock input before generating bonding clocks."}\
      {enable_hfreq_clk                          NOVAL     1               1               false   false         INTEGER   0                     enable_mcgb           true    BOOLEAN      NOVAL         "MCGB"        "Enable x6/xN non-bonded high-speed clock output port"  NOVAL                                                  NOVAL                                                         "This output port can be used to access x6/xN clock lines for non-bonded designs"}\
      {enable_mcgb_pcie_clksw                    NOVAL     1               1               false   false         INTEGER   0                     enable_mcgb           true    BOOLEAN      NOVAL         "MCGB"        "Enable PCIe clock switch interface"                    NOVAL                                                  NOVAL                                                         "Enables the control signals for PCIe clock switch circuitry"}\
      {mcgb_aux_clkin_cnt                        NOVAL     1               1               false   false         INTEGER   0                     enable_mcgb           true    NOVAL        NOVAL         "MCGB"        "Number of auxilary MCGB clock input ports."            { 0 1 }                                                ::mcgb_package_vi::mcgb::update_mcgb_aux_clkin_cnt            "Auxilary input is intended for PCIe Gen3, hence not available in FPLL"}\
      {mcgb_in_clk_freq                          NOVAL     0               0               true    false         FLOAT     0                     true                  true    NOVAL        MHz           "MCGB"        "MCGB input clock frequency"                            NOVAL                                                  ::mcgb_package_vi::mcgb::update_mcgb_in_clk_freq              "This parameter is not settable by user."}\
      {mcgb_out_datarate                         NOVAL     0               0               true    false         FLOAT     0                     true                  true    NOVAL        Mbps          "MCGB"        "MCGB output data rate"                                 NOVAL                                                  ::mcgb_package_vi::mcgb::update_mcgb_out_datarate             "This parameter is not settable by user. The value is calculated based on \"MCGB input clock frequency\" and \"Master CGB clock division factor\""}\
      {enable_bonding_clks                       NOVAL     1               1               false   false         INTEGER   0                     enable_mcgb           true    BOOLEAN      NOVAL         "Bonding"     "Enable bonding clock output ports"                     NOVAL                                                  NOVAL                                                         "Should be enable for bonded designs"}\
      {enable_fb_comp_bonding                    NOVAL     1               1               false   false         INTEGER   0                     enable_bonding_clks   true    BOOLEAN      NOVAL         "Bonding"     "Enable feedback compensation bonding"                  NOVAL                                                  NOVAL                                                         "NOVAL"}\
      {mcgb_enable_iqtxrxclk                     NOVAL     0               0               true    false         STRING    "disable_iqtxrxclk"   enable_bonding_clks   false   NOVAL        NOVAL         NOVAL         NOVAL                                                   { "disable_iqtxrxclk" "enable_iqtxrxclk"}              ::mcgb_package_vi::mcgb::convert_enable_fb_comp_bonding       "NOVAL"}\
      {pma_width                                 NOVAL     1               1               false   false         INTEGER   64                    enable_bonding_clks   true    NOVAL        NOVAL         "Bonding"     "PMA interface width"                                   { 8 10 16 20 32 40 64 }                                NOVAL                                                         "PMA-PCS Interface width. Proper value must be selected for bonding clocks to be generated properly for Native PHY IP."}\
      {enable_mcgb_debug_ports_parameters        NOVAL     0               0               true    true          INTEGER   0                     false                 false   NOVAL        NOVAL         NOVAL         NOVAL                                                   { 0 1 }                                                NOVAL                                                         NOVAL}\
      {enable_pld_mcgb_cal_busy_port             NOVAL     1               1               false   false         INTEGER   0                     false                 false   BOOLEAN      NOVAL         NOVAL         NOVAL                                                   { 0 1 }                                                NOVAL                                                         NOVAL}\
      {check_output_ports                        NOVAL     0               0               true    false         INTEGER   0                     false                 false   NOVAL        NOVAL         NOVAL         NOVAL                                                   NOVAL                                                  ::mcgb_package_vi::mcgb::validate_check_output_ports          NOVAL}\
   }

   # IMPORTANT NOTE: M_MAPS_FROM should be updated with external calls
   set pll_parameters_used_in_mcgb_validation_callbacks {\
      { NAME                            TYPE       DERIVED   M_MAPS_FROM     M_MAP_VALUES VISIBLE}\
      { mapped_output_clock_frequency   STRING     true      NOVAL           NOVAL        false}\
      { mapped_hip_cal_done_port        INTEGER    true      NOVAL           NOVAL        false}\
   }

## \note: pma_cgb_master_cgb_enable_iqtxrxclk is used in ATX PLL validations
# eventually fpll might need to the same
   set mcgb_atom_parameters {\
      { NAME                                   M_RCFG_REPORT                                          TYPE       DERIVED   M_MAPS_FROM                     HDL_PARAMETER   ENABLED   VISIBLE VALIDATION_CALLBACK                                 M_MAP_VALUES }\
      { pma_cgb_master_prot_mode               "enable_mcgb && enable_mcgb_debug_ports_parameters"    STRING     true      NOVAL                           true            false     false   NOVAL                                               NOVAL }\
      { pma_cgb_master_silicon_rev             "enable_mcgb && enable_mcgb_debug_ports_parameters"    STRING     true      NOVAL                           true            false     false   NOVAL                                               NOVAL }\
      { pma_cgb_master_x1_div_m_sel            "enable_mcgb && enable_mcgb_debug_ports_parameters"    STRING     true      mcgb_div                        true            false     false   NOVAL                                               {"1:divbypass" "2:divby2" "4:divby4" "8:divby8"} }\
      { pma_cgb_master_cgb_enable_iqtxrxclk    "enable_mcgb && enable_mcgb_debug_ports_parameters"    STRING     true      mcgb_enable_iqtxrxclk           true            false     false   NOVAL                                               NOVAL }\
      { pma_cgb_master_ser_mode                "enable_mcgb && enable_mcgb_debug_ports_parameters"    STRING     true      pma_width                       true            false     false   NOVAL                                               {"8:eight_bit" "10:ten_bit" "16:sixteen_bit" "20:twenty_bit" "32:thirty_two_bit" "40:forty_bit" "64:sixty_four_bit"} }\
      { pma_cgb_master_data_rate               "enable_mcgb && enable_mcgb_debug_ports_parameters"    STRING     true      NOVAL                           true            false     false   ::mcgb_package_vi::mcgb::convert_mcgb_out_datarate  NOVAL }\
   }

# IMPORTANT NOTES
# 1) hssi_pma_cgb_master_cgb_power_down       default in atom is power_down_cgb, but normal_cgb is used as default in IP and wrappers
# 2) hssi_pma_cgb_master_input_select         default in atom is unused,         but lcpll_top  is used as default in IP and wrappers

   set mcgb_parameters_to_be_removed {\
      { NAME                                                M_RCFG_REPORT                                          TYPE       DERIVED   HDL_PARAMETER   ENABLED   VISIBLE   DEFAULT_VALUE                VALIDATION_CALLBACK }\
      { pma_cgb_master_cgb_power_down                       "enable_mcgb && enable_mcgb_debug_ports_parameters"    STRING     true      true            false     false     "normal_cgb"                 ::mcgb_package_vi::mcgb::set_to_default }\
      { pma_cgb_master_master_cgb_clock_control             "enable_mcgb && enable_mcgb_debug_ports_parameters"    STRING     true      true            false     false     "master_cgb_no_dft_control"  ::mcgb_package_vi::mcgb::set_to_default }\
      { pma_cgb_master_observe_cgb_clocks                   "enable_mcgb && enable_mcgb_debug_ports_parameters"    STRING     true      true            false     false     "observe_nothing"            ::mcgb_package_vi::mcgb::set_to_default }\
      { pma_cgb_master_op_mode                              "enable_mcgb && enable_mcgb_debug_ports_parameters"    STRING     true      true            false     false     "enabled"                    ::mcgb_package_vi::mcgb::set_to_default }\
      { pma_cgb_master_tx_ucontrol_reset_pcie               "enable_mcgb && enable_mcgb_debug_ports_parameters"    STRING     true      true            false     false     "pcscorehip_controls_mcgb"   ::mcgb_package_vi::mcgb::set_to_default }\
      { pma_cgb_master_vccdreg_output                       "enable_mcgb && enable_mcgb_debug_ports_parameters"    STRING     true      true            false     false     "vccdreg_nominal"            ::mcgb_package_vi::mcgb::set_to_default }\
      { pma_cgb_master_input_select                         "enable_mcgb && enable_mcgb_debug_ports_parameters"    STRING     true      true            false     false     "lcpll_top"                  ::mcgb_package_vi::mcgb::validate_input_select }\
      { pma_cgb_master_input_select_gen3                    "enable_mcgb && enable_mcgb_debug_ports_parameters"    STRING     true      true            false     false     "unused"                     ::mcgb_package_vi::mcgb::validate_input_select_gen3 }\
   }

   set mcgb_interfaces {\
      {NAME                  DIRECTION  UI_DIRECTION  WIDTH_EXPR         ROLE              TERMINATION_VALUE  IFACE_NAME         IFACE_TYPE         IFACE_DIRECTION  TERMINATION                                                        ELABORATION_CALLBACK }\
      {mcgb_rst               input     input         1                  mcgb_rst          NOVAL              mcgb_rst           conduit            end              "!enable_mcgb"                                                     NOVAL                }\
      {mcgb_aux_clk0          input     input         1                  tx_serial_clk     NOVAL              mcgb_aux_clk0      conduit            end              "!enable_mcgb || (mcgb_aux_clkin_cnt<1)"                           NOVAL                }\
      {mcgb_aux_clk1          input     input         1                  tx_serial_clk     NOVAL              mcgb_aux_clk1      conduit            end              "!enable_mcgb || (mcgb_aux_clkin_cnt<2)"                           NOVAL                }\
      {mcgb_aux_clk2          input     input         1                  tx_serial_clk     NOVAL              mcgb_aux_clk2      conduit            end              "!enable_mcgb || (mcgb_aux_clkin_cnt<3)"                           NOVAL                }\
      {tx_bonding_clocks      output    output        6                  clk               NOVAL              tx_bonding_clocks  hssi_bonded_clock  start            "!enable_mcgb || !enable_bonding_clks"                             NOVAL                }\
      {mcgb_serial_clk        output    output        1                  clk               NOVAL              mcgb_serial_clk    hssi_serial_clock  start            "!enable_mcgb || !enable_hfreq_clk"                                NOVAL                }\
      {pcie_sw                input     input         2                  pcie_sw           NOVAL              pcie_sw            conduit            end              "!enable_mcgb || !enable_mcgb_pcie_clksw"                          NOVAL                }\
      {pcie_sw_done           output    output        2                  pcie_sw_done      NOVAL              pcie_sw_done       conduit            end              "!enable_mcgb || !enable_mcgb_pcie_clksw"                          NOVAL                }\
      \
      {reconfig_clk1          input     input         1                  clk               NOVAL              reconfig_clk1      clock              sink             "!enable_mcgb_debug_ports_parameters"                              NOVAL                }\
      {reconfig_reset1        input     input         1                  reset             NOVAL              reconfig_reset1    reset              sink             "!enable_mcgb_debug_ports_parameters"                              ::mcgb_package_vi::mcgb::elaborate_reconfig_reset }\
      {reconfig_write1        input     input         1                  write             NOVAL              reconfig_avmm1     avalon             slave            "!enable_mcgb_debug_ports_parameters"                              NOVAL                }\
      {reconfig_read1         input     input         1                  read              NOVAL              reconfig_avmm1     avalon             slave            "!enable_mcgb_debug_ports_parameters"                              NOVAL                }\
      {reconfig_address1      input     input         10                 address           NOVAL              reconfig_avmm1     avalon             slave            "!enable_mcgb_debug_ports_parameters"                              NOVAL                }\
      {reconfig_writedata1    input     input         32                 writedata         NOVAL              reconfig_avmm1     avalon             slave            "!enable_mcgb_debug_ports_parameters"                              NOVAL                }\
      {reconfig_readdata1     output    output        32                 readdata          NOVAL              reconfig_avmm1     avalon             slave            "!enable_mcgb_debug_ports_parameters"                              NOVAL                }\
      {reconfig_waitrequest1  output    output        1                  waitrequest       NOVAL              reconfig_avmm1     avalon             slave            "!enable_mcgb_debug_ports_parameters"                              NOVAL                }\
      {mcgb_cal_busy          output    output        1                  mcgb_cal_busy     NOVAL              mcgb_cal_busy      conduit            end              "(!enable_mcgb_debug_ports_parameters) && (!enable_pld_mcgb_cal_busy_port)"               NOVAL                }\
      {mcgb_hip_cal_done      output    output        1                  hip_cal_done      NOVAL              mcgb_hip_cal_done  conduit            end              "!mapped_hip_cal_done_port"                    NOVAL                }\
   }

}

##################################################################################################################################################
# INTERNAL UTILITY FUNCTIONS
##################################################################################################################################################

proc ::mcgb_package_vi::mcgb::set_property_byParameterIndex { data propertyName propertyValue parameterIndex } {

   set headers [lindex $data 0]
   set propertyIndex [lsearch $headers $propertyName]
   if { $propertyIndex == -1 } {
      ip_message error "::mcgb_package_vi::mcgb::set_property_byParameterIndex:: property($propertyName) does not exist"
   }

   set length [llength $data]

   if { $length <= $parameterIndex || $parameterIndex < 1 } {
      ip_message error "::mcgb_package_vi::mcgb::set_property_byParameterIndex:: invalid parameter index($parameterIndex)"
   }

   set parameterProperties [lindex $data $parameterIndex]
   set parameterProperties [lreplace $parameterProperties $propertyIndex $propertyIndex $propertyValue]
   set data [lreplace $data $parameterIndex $parameterIndex $parameterProperties]

   return $data
}

proc ::mcgb_package_vi::mcgb::set_property_byParameterName  { data propertyName propertyValue parameterName } {
   # find the index of parameter
   set parameterIndex -1
   set headers [lindex $data 0]
   set parameterNameIndex [lsearch $headers NAME]
   set length [llength $data]
   for {set i 1} {$i < $length} {incr i} {
      set this_entry [lindex $data $i]
      if { [lindex $this_entry $parameterNameIndex] == $parameterName } {
         set parameterIndex $i
      }
   }

   if {$parameterIndex == -1} {
      ip_message error "::mcgb_package_vi::mcgb::set_property_byParameterName:: parameter($parameterName) does not exist"
   }

   return [set_property_byParameterIndex $data $propertyName $propertyValue $parameterIndex]
}

##################################################################################################################################################
# EXPORTED FUNCTIONS
##################################################################################################################################################
proc ::mcgb_package_vi::mcgb::set_output_clock_frequency_maps_from { mapsFrom } {
   variable pll_parameters_used_in_mcgb_validation_callbacks
   set pll_parameters_used_in_mcgb_validation_callbacks [set_property_byParameterName $pll_parameters_used_in_mcgb_validation_callbacks M_MAPS_FROM $mapsFrom mapped_output_clock_frequency]
}

proc ::mcgb_package_vi::mcgb::set_hip_cal_done_enable_maps_from { mapsFrom } {
   variable pll_parameters_used_in_mcgb_validation_callbacks
   set pll_parameters_used_in_mcgb_validation_callbacks [set_property_byParameterName $pll_parameters_used_in_mcgb_validation_callbacks M_MAPS_FROM $mapsFrom mapped_hip_cal_done_port]
}

proc ::mcgb_package_vi::mcgb::set_protocol_mode_maps_from { mapsFrom } {
   variable mcgb_atom_parameters
   set mcgb_atom_parameters [set_property_byParameterName $mcgb_atom_parameters M_MAPS_FROM $mapsFrom pma_cgb_master_prot_mode]
}

proc ::mcgb_package_vi::mcgb::set_silicon_rev_maps_from { mapsFrom } {
   variable mcgb_atom_parameters
   set mcgb_atom_parameters [set_property_byParameterName $mcgb_atom_parameters M_MAPS_FROM $mapsFrom pma_cgb_master_silicon_rev]
}

proc ::mcgb_package_vi::mcgb::set_mcgb_display_item_properties { group_value args_value } {
   variable mcgb_display_items

   set mcgb_display_items [set_property_byParameterIndex $mcgb_display_items GROUP $group_value 1]
   set mcgb_display_items [set_property_byParameterIndex $mcgb_display_items ARGS $args_value 1]
}

proc ::mcgb_package_vi::mcgb::declare_mcgb_display_items {} {
   variable mcgb_display_items
   ip_declare_display_items $mcgb_display_items
}

proc ::mcgb_package_vi::mcgb::declare_mcgb_parameters {} {
   variable mcgb_parameters
   variable pll_parameters_used_in_mcgb_validation_callbacks
   variable mcgb_atom_parameters
   variable mcgb_parameters_to_be_removed
   ip_declare_parameters $mcgb_parameters
   ip_declare_parameters $pll_parameters_used_in_mcgb_validation_callbacks
   ip_declare_parameters $mcgb_atom_parameters
   ip_declare_parameters $mcgb_parameters_to_be_removed
}

proc ::mcgb_package_vi::mcgb::declare_mcgb_interfaces {} {
   variable mcgb_interfaces
   ip_declare_interfaces $mcgb_interfaces
}
##################################################################################################################################################
# functions: converting user parameters to their final form (appropriate for the hdl) 
##################################################################################################################################################

## \TODO some of these functions needs to be implemented as mapped parameters

proc ::mcgb_package_vi::mcgb::validate_check_output_ports {enable_bonding_clks enable_hfreq_clk enable_mcgb} {
   if {$enable_mcgb} {
      if {!$enable_bonding_clks && !$enable_hfreq_clk } {
         set port_name1  [ip_get "parameter.enable_bonding_clks.display_name"]
         set port_name2  [ip_get "parameter.enable_hfreq_clk.display_name"]
         ip_message error "Enable at least one output port for Master CGB using checkbox \"$port_name1\" and/or \"$port_name2\". "
      }
   }
}

##
# Don't allow auxilary input for Master CGB when instantiated through fPLL (this is to get around the PCIe Gen3 Issues)
# \todo add here notes to a document or FD, explaining what is the issue
# short summary: for Gen 3 designs we want ATX to instantiate M-CGB, fPLL should connect to aux input
proc ::mcgb_package_vi::mcgb::update_mcgb_aux_clkin_cnt { PROP_VALUE enable_mcgb_debug_ports_parameters } {
   if { $enable_mcgb_debug_ports_parameters==1 } {
      ip_set "parameter.mcgb_aux_clkin_cnt.ALLOWED_RANGES" {0 1 2 3}
   # if module name contains fpll it is most likely fpll not atx
   } elseif { [string first "fpll" [ip_get "module.name"]] >=0 } {
      ip_set "parameter.mcgb_aux_clkin_cnt.ALLOWED_RANGES" {0}
      if { $PROP_VALUE > 0 } {
         ip_message error "Auxilary clock input intended for PCIe Gen 3 designs. Use ATX PLL for PCIe Gen3 designs"
      }
   }
 }


proc ::mcgb_package_vi::mcgb::convert_enable_fb_comp_bonding { enable_fb_comp_bonding } {
   set temp_mcgb_enable_iqtxrxclk "disable_iqtxrxclk"

   switch $enable_fb_comp_bonding {
      0 {set temp_mcgb_enable_iqtxrxclk "disable_iqtxrxclk"}
      1 {set temp_mcgb_enable_iqtxrxclk "enable_iqtxrxclk"}
      default  {set temp_mcgb_enable_iqtxrxclk "disable_iqtxrxclk"}
   }
   ip_set "parameter.mcgb_enable_iqtxrxclk.value" $temp_mcgb_enable_iqtxrxclk    
}

proc ::mcgb_package_vi::mcgb::elaborate_reconfig_reset { } {
  ip_set "interface.reconfig_reset1.associatedclock" reconfig_clk1
}

##
# NOTE: this is a dummy function, for parameters that will eventually be set through a validation_callback (but the functions are not ready yet).
# The parameters are listed in the IP anyways. This is to make sure that they will be part of reconfiguration files.
# However if enumerations for those values changes due to atom map changes, existing IP variant files need to be manually edited.
# This function will enable us to prevent that
proc ::mcgb_package_vi::mcgb::set_to_default { PROP_NAME } {
   set value [ip_get "parameter.${PROP_NAME}.DEFAULT_VALUE"]
   ip_set "parameter.${PROP_NAME}.value" $value
}

##
# There is a hard connection to lcpll_top input of the CGB from both fPLL and ATX PLL
# and for both PLLs input_select default is lcpll_top
# however for Gen 3, design we have the fpll connecting to aux0 of MasterCGB, which goes to fpll_top port of the Master CGB
# but we want Gen3 designs to start with Gen1-2 speeds hence the input port that fPLL is connected should be set as primary 
# \note master cgb instentiation at fpll IP is not allowed for gen 3 designs, hence only atx is of importance  
proc ::mcgb_package_vi::mcgb::validate_input_select { pma_cgb_master_prot_mode } {
   # if module name contains atx it is most likely atx not fpll
   if { [string first "atx" [ip_get "module.name"]] >=0 && $pma_cgb_master_prot_mode == "pcie_gen3_tx" } {
      ip_set "parameter.pma_cgb_master_input_select.value" "fpll_top"
   }
}

##
# There is a hard connection to lcpll_top input of the CGB from both fPLL and ATX PLL
# and for both PLLs input_select default is lcpll_top
# however for Gen 3, design we have the fpll connecting to aux0 of MasterCGB, which goes to fpll_top port of the Master CGB
# but we want Gen3 designs to start with Gen1-2 speeds and then switch to Gen 3 speed
# hence the input port that fPLL is connected should be set as primary (taken car of in the function validate_input_select) and
#       the input port that LCPLL is connected should be set as secondary (done by updating pma_cgb_master_input_select_gen3)
# \note master cgb instentiation at fpll IP is not allowed for gen 3 designs, hence only atx is of importance  
proc ::mcgb_package_vi::mcgb::validate_input_select_gen3 { pma_cgb_master_prot_mode } {
   # if module name contains atx it is most likely atx not fpll
   if { [string first "atx" [ip_get "module.name"]] >=0 && $pma_cgb_master_prot_mode == "pcie_gen3_tx" } {
      ip_set "parameter.pma_cgb_master_input_select_gen3.value" "lcpll_top"
   }
}

##
# Convert floating point to string
proc ::mcgb_package_vi::mcgb::convert_mcgb_out_datarate {PROP_NAME mcgb_out_datarate } {
   ip_set "parameter.${PROP_NAME}.value" "$mcgb_out_datarate Mbps"
}

##################################################################################################################################################
# functions: copying calculated pll settings to corresponding hdl parameters 
################################################################################################################################################## 

proc ::mcgb_package_vi::mcgb::update_mcgb_in_clk_freq { mapped_output_clock_frequency } {
        # strip off MHz
        set mcgb_in_freq [::alt_xcvr::utils::common::get_freq_in_mhz $mapped_output_clock_frequency]
	ip_set "parameter.mcgb_in_clk_freq.value" $mcgb_in_freq
}

proc ::mcgb_package_vi::mcgb::update_mcgb_out_datarate { mcgb_in_clk_freq mcgb_div} {
	set temp_mcgb_out_datarate [expr 2.0*$mcgb_in_clk_freq/($mcgb_div)]
	ip_set "parameter.mcgb_out_datarate.value" $temp_mcgb_out_datarate
}
