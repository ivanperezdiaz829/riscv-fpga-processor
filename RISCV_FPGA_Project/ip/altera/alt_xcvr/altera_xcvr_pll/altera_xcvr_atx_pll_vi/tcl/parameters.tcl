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


## \file parameters.tcl
# lists all the parameters used in NF ATX PLL IP GUI & HDL WRAPPER, as well as associated validation callbacks

package provide altera_xcvr_atx_pll_vi::parameters 13.1

package require alt_xcvr::ip_tcl::ip_module
package require alt_xcvr::ip_tcl::messages
package require alt_xcvr::gui::messages
package require alt_xcvr::utils::device
package require alt_xcvr::utils::common
package require altera_xcvr_atx_pll_vi::pll_calculations
package require mcgb_package_vi::mcgb
package require alt_xcvr::utils::reconfiguration_arria10

namespace eval ::altera_xcvr_atx_pll_vi::parameters:: {
   namespace import ::alt_xcvr::ip_tcl::ip_module::*
   namespace import ::alt_xcvr::ip_tcl::messages::*
   namespace import ::altera_xcvr_atx_pll_vi::pll_calculations::*

   namespace export \
      declare_parameters \
      validate \

   variable display_items_pll
   variable generation_display_items
   variable parameters
   variable parameters_allowed_range
   variable atom_parameters
   variable logical_parameters
   variable parameters_to_be_removed

   set display_items_pll {\
      {NAME                         GROUP                      ENABLED             VISIBLE   TYPE   ARGS  }\
      {"PLL"                        ""                         NOVAL               NOVAL     GROUP  tab   }\
      {"General"                    "PLL"                      NOVAL               NOVAL     GROUP  noval }\
      {"Feedback"                   "PLL"                      NOVAL               NOVAL     GROUP  noval }\
      {"Ports"                      "PLL"                      NOVAL               NOVAL     GROUP  noval }\
      {"Output Frequency"           "PLL"                      NOVAL               NOVAL     GROUP  noval }\
   }

   ## \todo move to file_utils package ??
   set generation_display_items {\
      {NAME                         GROUP                      ENABLED             VISIBLE   TYPE   ARGS  }\
      {"Generation Options"         ""                         NOVAL               NOVAL     GROUP  tab   }\
   }

   # \OPEN how to use and display hclk_divide? [CM: ]
   # \OPEN bonding_mode needs to be reviewed
   # \OPEN enable_bonding_reset needs to be reviewed (reverse logic as well)
   ## \todo insert a reference for FD which includes dependency graph for the parameters
   ## \todo make fb_select, bonding_reset_enable reconfigurable --> convert to 2 parameters 
   ## \todo direct reference to enable_fb_comp_bonding in cgb BAD!!!! 
   set parameters {\
      {NAME                                 M_USED_FOR_RCFG  M_SAME_FOR_RCFG  VALIDATION_CALLBACK                                                 DERIVED HDL_PARAMETER   TYPE         DEFAULT_VALUE            ALLOWED_RANGES                                        ENABLED                  VISIBLE                      DISPLAY_HINT  DISPLAY_UNITS DISPLAY_ITEM                   DISPLAY_NAME                                            DESCRIPTION }\
      {enable_advanced_options              0                0                NOVAL                                                               true    false           INTEGER      0                        { 0 1 }                                               true                     false                        NOVAL         NOVAL         NOVAL                          NOVAL                                                   NOVAL}\
      {enable_hip_options                   0                0                NOVAL                                                               true    false           INTEGER      0                        { 0 1 }                                               true                     false                        NOVAL         NOVAL         NOVAL                          NOVAL                                                   NOVAL}\
      {enable_manual_configuration          0                0                NOVAL                                                               true    false           INTEGER      0                        { 0 1 }                                               true                     false                        NOVAL         NOVAL         NOVAL                          NOVAL                                                   NOVAL}\
      {generate_docs                        0                0                NOVAL                                                               false   false           INTEGER      1                        NOVAL                                                 true                     true                         BOOLEAN       NOVAL         "Generation Options"           "Generate parameter documentation file"                 "When enabled, generation will produce a .CSV file with descriptions of the IP parameters."}\
      {generate_add_hdl_instance_example    0                0                NOVAL                                                               false   false           INTEGER      0                        NOVAL                                                 enable_advanced_options  enable_advanced_options      BOOLEAN       NOVAL         "Generation Options"           "Generate '_hw.tcl' 'add_hdl_instance' example file"    "When enabled, generation will produce a file containing an example of how to use the '_hw.tcl' 'add_hdl_instance' API. The example will be correct for the current configuration of the IP."}\
      {device_family                        0                0                NOVAL                                                               false   false           STRING       "Arria VI"               NOVAL                                                 true                     false                        NOVAL         NOVAL         NOVAL                          NOVAL                                                   NOVAL}\
      \
      {test_mode                            0                0                NOVAL                                                               false   false           INTEGER      0                        NOVAL                                                 true                     false                        BOOLEAN       NOVAL         "PLL"                          "Enable Test Mode"                                      NOVAL}\
      \
      {enable_debug_ports_parameters        0                0                NOVAL                                                               false   false           INTEGER      0                        { 0 1 }                                               true                     false                        NOVAL         NOVAL         NOVAL                          NOVAL                                                   NOVAL}\
      {enable_pld_atx_cal_busy_port         1                1                NOVAL                                                               false   false           INTEGER      1                        { 0 1 }                                               false                    false                        BOOLEAN       NOVAL         NOVAL                          NOVAL                                                   NOVAL}\
      \
      {support_mode                         1                0                ::altera_xcvr_atx_pll_vi::parameters::validate_support_mode         false   false           STRING       "user_mode"              {"user_mode" "engineering_mode"}                      enable_advanced_options  enable_advanced_options      NOVAL         NOVAL         "General"                      "Support mode"                                          "Selects the support mode (user or engineering). Engineering mode options are not officially supported by Altera or Quartus II."}\
      {message_level                        0                0                NOVAL                                                               false   false           STRING       "error"                  {error warning}                                       true                     true                         NOVAL         NOVAL         "General"                      "Message level for rule violations"                     "Specifies the messaging level to use for parameter rule violations. Selecting \"error\" will cause all rule violations to prevent IP generation. Selecting \"warning\" will display all rule violations as warnings and will allow IP generation in spite of violations."}\
      {speed_grade                          0                0                NOVAL                                                               false   false           STRING       "fastest"                NOVAL                                                 true                     true                         NOVAL         NOVAL         "General"                      "Device speed grade"                                    "Specifies the desired device speedgrade. This information is used for pll frequency validation."}\
      {speed_grade_fnl                      0                0                ::altera_xcvr_atx_pll_vi::parameters::convert_speed_grade           true    false           STRING       "2"                      { "2" "3" "4" }                                       true                     false                        NOVAL         NOVAL         NOVAL                          NOVAL                                                   NOVAL}\
      {prot_mode                            1                0                NOVAL                                                               false   false           STRING       "Basic"                  { "Basic" "PCIe Gen 1" "PCIe Gen 2" "PCIe Gen 3"}     true                     true                         NOVAL         NOVAL         "General"                      "Protocol mode"                                         "The parameter is used to govern the rules for internal settings of the VCO. This parameter is not a \"preset\". You must still correctly set all other parameters for your protocol and application."}\
      {prot_mode_fnl                        0                0                ::altera_xcvr_atx_pll_vi::parameters::convert_prot_mode             true    false           STRING       "basic_tx"               NOVAL                                                 true                     false                        NOVAL         NOVAL         NOVAL                          NOVAL                                                   NOVAL}\
      {bw_sel                               1                0                NOVAL                                                               false   false           STRING       "low"                    NOVAL                                                 true                     true                         NOVAL         NOVAL         "General"                      "Bandwidth"                                             "Specifies the VCO bandwidth."}\
      {refclk_cnt                           1                1                NOVAL                                                               false   false           INTEGER      1                        { 1 2 3 4 5 }                                         true                     true                         NOVAL         NOVAL         "General"                      "Number of PLL reference clocks"                        "Specifies the number of input reference clocks for the ATX PLL."}\
      {refclk_index                         1                0                ::altera_xcvr_atx_pll_vi::parameters::update_refclk_index           false   false           INTEGER      0                        NOVAL                                                 true                     true                         NOVAL         NOVAL         "General"                      "Selected reference clock source"                       "Specifies the initially selected reference clock input to the ATX PLL."}\
      {silicon_rev                          0                0                NOVAL                                                               false   false           BOOLEAN      false                    NOVAL                                                 true                     false                        NOVAL         NOVAL         "General"                      "Silicon revision ES"                                   NOVAL}\
      {silicon_rev_fnl                      0                0                ::altera_xcvr_atx_pll_vi::parameters::convert_silicon_rev           true    false           STRING       "reva"                   { "reva" "revb" "revc" }                              true                     false                        NOVAL         NOVAL         NOVAL                          NOVAL                                                   NOVAL}\
      \
      {fb_select_fnl                        0                0                ::altera_xcvr_atx_pll_vi::parameters::convert_fb_select             true    false           STRING       "direct_fb"              { "direct_fb" "iqtxrxclk_fb" }                        true                     false                        NOVAL         NOVAL         NOVAL                          NOVAL                                                   NOVAL}\
      {primary_pll_buffer                   1                0                NOVAL                                                               false   false           STRING       "GX clock output buffer" { "GX clock output buffer" "GT clock output buffer" } true                     true                         NOVAL         NOVAL         "Ports"                        "Primary PLL clock output buffer"                       "Specifies initially which PLL output is active. If GX is selected \"Enable PLL GX clock output port\" should be enabled as well, if GT is selected \"Enable PLL GT clock output port\" should be enabled as well."}\
      {enable_8G_buffer_fnl                 0                0                ::altera_xcvr_atx_pll_vi::parameters::update_enable_8G_buffer_fnl   true    false           STRING       "true"                   { "true" "false" }                                    true                     false                        NOVAL         NOVAL         NOVAL                          NOVAL                                                   NOVAL}\
      {enable_16G_buffer_fnl                0                0                ::altera_xcvr_atx_pll_vi::parameters::update_enable_16G_buffer_fnl  true    false           STRING       "false"                  { "true" "false" }                                    true                     false                        NOVAL         NOVAL         NOVAL                          NOVAL                                                   NOVAL}\
      {enable_8G_path                       1                1                NOVAL                                                               false   false           INTEGER      1                        NOVAL                                                 true                     true                         BOOLEAN       NOVAL         "Ports"                        "Enable PLL GX clock output port"                       "GX output port feeds x1 clock lines. Must be selected for PLL output frequency smaller than 8GHz. If GX is selected in \"Primary PLL clock output buffer\", the port should be enabled as well."}\
      {enable_16G_path                      1                1                NOVAL                                                               false   false           INTEGER      0                        NOVAL                                                 true                     true                         BOOLEAN       NOVAL         "Ports"                        "Enable PLL GT clock output port"                       "GT output port feeds dedicated high speed clock lines. Must be selected for PLL output frequency greater than 8GHz. If GT is selected in \"Primary PLL clock output buffer\", the port should be enabled as well."}\
      {enable_pcie_clk                      1                1                NOVAL                                                               false   false           INTEGER      0                        NOVAL                                                 true                     true                         BOOLEAN       NOVAL         "Ports"                        "Enable PCIe clock output port"                         "This is the fixed PCIe clock output port"}\
      {enable_cascade_out                   1                1                NOVAL                                                               false   false           INTEGER      0                        NOVAL                                                 enable_advanced_options  enable_advanced_options      BOOLEAN       NOVAL         "Ports"                        "Enable cascade clock output port"                      NOVAL}\
      {enable_hip_cal_done_port             1                1                NOVAL                                                               false   false           INTEGER      0                        NOVAL                                                 enable_hip_options       enable_hip_options           BOOLEAN       NOVAL         "Ports"                        "Enable calibration status ports for HIP"                "Enables calibration status port from PLL and Master CGB(if enabled) for HIP"}\
      \
      {select_manual_config                 1                0                NOVAL                                                               false   false           INTEGER      0                        NOVAL                                                 true                     enable_manual_configuration  BOOLEAN       NOVAL         "Output Frequency"             "Configure counters manually"                           "Needs to be reviewed!"}\
      {enable_fractional                    1                0                NOVAL                                                               false   false           BOOLEAN      false                    NOVAL                                                 false                    false                        NOVAL         NOVAL         "Output Frequency"             "Use fractional capability"                             "Needs to be reviewed!"}\
      {dsm_mode                             0                0                ::altera_xcvr_atx_pll_vi::parameters::convert_dsm_mode              true    false           STRING       "dsm_mode_integer"       { "dsm_mode_integer" "dsm_mode_phase" }               true                     false                        NOVAL         NOVAL         NOVAL                          NOVAL                                                   NOVAL}\
      \
      {set_output_clock_frequency           1                0                NOVAL                                                               false   false           FLOAT        2500.0                   NOVAL                                                 true                     "!select_manual_config"      NOVAL         MHz           "Output Frequency"             "PLL output frequency"                                  "Specifies the target output frequency for the PLL."}\
      {output_clock_frequency               0                0                ::altera_xcvr_atx_pll_vi::parameters::update_output_clock_frequency true    false           STRING       "2500 MHz"               NOVAL                                                 true                     select_manual_config         NOVAL         NOVAL         "Output Frequency"             "PLL output frequency"                                  NOVAL}\
      \
      {set_auto_reference_clock_frequency   1                0                ::altera_xcvr_atx_pll_vi::parameters::update_refclk_auto            false   false           FLOAT        100.000000               NOVAL                                                 true                     "!select_manual_config"      NOVAL         MHz           "Output Frequency"             "PLL reference clock frequency"                         "Selects the input reference clock frequency for the PLL."}\
      {set_manual_reference_clock_frequency 1                0                NOVAL                                                               false   false           FLOAT        100.000000               NOVAL                                                 true                     select_manual_config         NOVAL         MHz           "Output Frequency"             "PLL reference clock frequency"                         NOVAL}\
      {reference_clock_frequency_fnl        0                0                ::altera_xcvr_atx_pll_vi::parameters::update_reflk_freq             true    false           STRING       "100.000000 MHz"         NOVAL                                                 true                     false                        NOVAL         NOVAL         NOVAL                          NOVAL                                                   NOVAL}\
      \
      {feedback_clock_frequency_fnl         0                0                ::altera_xcvr_atx_pll_vi::parameters::update_fbclk_freq             true    false           FLOAT        100.000000               NOVAL                                                 true                     false                        NOVAL         MHz           "Output Frequency"             "External feedback frequency"                           "In feedback compensation bonding mode. The feedback frequency is determined based on \"Master CGB division factor\", \"Master CGB pma width\" and \"PLL output frequency\""}\
      \
      {m_counter                            0                0                ::altera_xcvr_atx_pll_vi::parameters::update_m_counter              true    false           INTEGER      NOVAL                    NOVAL                                                 true          "(!select_manual_config)&&(!enable_fb_comp_bonding)"    NOVAL         NOVAL         "Output Frequency"             "Multiply factor (M-Counter)"                           NOVAL}\
      {effective_m_counter                  0                0                ::altera_xcvr_atx_pll_vi::parameters::update_effective_m_counter    true    false           INTEGER      1                        NOVAL                                                 true           "(!select_manual_config)&&(enable_fb_comp_bonding)"    NOVAL         NOVAL         "Output Frequency"             "Effective M-Counter"                                   "In feedback compensation bonding modes, ratio of output clock to feedback clock." }\
      {set_m_counter                        1                0                NOVAL                                                               false   false           INTEGER      1                        NOVAL                                                 true                     select_manual_config         NOVAL         NOVAL         "Output Frequency"             "Multiply factor (M-Counter)"                           NOVAL}\
      {ref_clk_div                          0                0                ::altera_xcvr_atx_pll_vi::parameters::update_n_counter              true    false           INTEGER      NOVAL                    NOVAL                                                 true                     "!select_manual_config"      NOVAL         NOVAL         "Output Frequency"             "Divide factor (N-Counter)"                             "See the Transceivers User Manual for detailed description."}\
      {set_ref_clk_div                      1                0                NOVAL                                                               false   false           INTEGER      1                        { 1 2 4 8 }                                           true                     select_manual_config         NOVAL         NOVAL         "Output Frequency"             "Divide factor (N-Counter)"                             NOVAL}\
      {l_counter                            0                0                ::altera_xcvr_atx_pll_vi::parameters::update_l_counter              true    false           INTEGER      NOVAL                    NOVAL                                                 true                     "!select_manual_config"      NOVAL         NOVAL         "Output Frequency"             "Divide factor (L-Counter)"                             "See the Transceivers User Manual for detailed description."}\
      {set_l_counter                        1                0                NOVAL                                                               false   false           INTEGER      2                        { 1 2 4 8 16 }                                        true                     select_manual_config         NOVAL         NOVAL         "Output Frequency"             "Divide factor (L-Counter)"                             NOVAL}\
      {k_counter                            0                0                ::altera_xcvr_atx_pll_vi::parameters::update_k_counter              true    false           INTEGER      NOVAL                    NOVAL                                                 true                     false                        NOVAL         NOVAL         "Output Frequency"             "Fractional multiply factor (K)"                        "See the Transceivers User Manual for detailed description."}\
      {set_k_counter                        1                0                NOVAL                                                               false   false           INTEGER      1                        { 1 ? ? ? ? ? }                                       true                     false                        NOVAL         NOVAL         "Output Frequency"             "Fractional multiply factor (K)"                        NOVAL}\
      \
      {hclk_divide                          1                0                NOVAL                                                               false   false           INTEGER      1                        { 1 3 5 6 8 10 12 16 20 }                             true                     false                        NOVAL         NOVAL         NOVAL                          NOVAL                                                   NOVAL}\
      \
      {auto_list                            0                0                ::altera_xcvr_atx_pll_vi::parameters::calculate_pll_auto            true    false           STRING       NOVAL                    NOVAL                                                 true                     false                        NOVAL         NOVAL         NOVAL                          NOVAL                                                   NOVAL}\
      {manual_list                          0                0                ::altera_xcvr_atx_pll_vi::parameters::calculate_pll_manual          true    false           STRING       NOVAL                    NOVAL                                                 true                     false                        NOVAL         NOVAL         NOVAL                          NOVAL                                                   NOVAL}\
      {pll_setting                          0                0                ::altera_xcvr_atx_pll_vi::parameters::update_pll_setting            true    false           STRING       NOVAL                    NOVAL                                                 true                     false                        NOVAL         NOVAL         NOVAL                          NOVAL                                                   NOVAL}\
      \
      {tank_sel                             0                0                ::altera_xcvr_atx_pll_vi::parameters::update_tank_sel               true    false           STRING       NOVAL                    NOVAL                                                 true                     false                        NOVAL         NOVAL         NOVAL                          NOVAL                                                   NOVAL}\
      {tank_band                            0                0                ::altera_xcvr_atx_pll_vi::parameters::update_tank_band              true    false           STRING       NOVAL                    NOVAL                                                 true                     false                        NOVAL         NOVAL         NOVAL                          NOVAL                                                   NOVAL}\
   }

set parameters_allowed_range {\
      {NAME           ALLOWED_RANGES }\
      {prot_mode_fnl  { "unused" "basic_tx" "basic_kr_tx" "pcie_gen1_tx" "pcie_gen2_tx" "pcie_gen3_tx" "pcie_gen4_tx" "cei_tx" "qpi_tx" "cpri_tx" "fc_tx" "srio_tx" "gpon_tx" "sdi_tx" "sata_tx" "xaui_tx" "obsai_tx" "gige_tx" "higig_tx" "sonet_tx" "sfp_tx" "xfp_tx" "sfi_tx" } }\
      {bw_sel         { "low" "medium" "high" } }\
      {set_m_counter  { 100 80 64 60 50 48 40 36 32 30 25 24 20 18 16 15 12 10  9  8  6  5   4   3   2   1 } }\
   }

## \todo atx_pll_cgb_div maps from another package -- fix that
## \todo atx_pll_bonding_mode maps from another package -- fix that
## \note atx_pll_bonding_mode default is cpri -- but it is ok, fitter will ignore it if overall feedback mode is internal
set atom_parameters {\
      { NAME                                          M_RCFG_REPORT   TYPE       DERIVED   M_MAPS_FROM                     HDL_PARAMETER   ENABLED   VISIBLE   M_MAP_VALUES }\
      { atx_pll_bonding_mode                          1               STRING     true      enable_fb_comp_bonding          true            false     false     {"0:cpri_bonding" "1:pll_bonding"} }\
      { atx_pll_cgb_div                               1               INTEGER    true      mcgb_div                        true            false     false     NOVAL }\
      { atx_pll_pma_width                             1               INTEGER    true      pma_width                       true            false     false     NOVAL }\
      { atx_pll_speed_grade                           1               STRING     true      speed_grade_fnl                 true            false     false     NOVAL }\
      { atx_pll_prot_mode                             1               STRING     true      prot_mode_fnl                   true            false     false     NOVAL }\
      { atx_pll_bw_sel                                1               STRING     true      bw_sel                          true            false     false     NOVAL }\
      { atx_pll_silicon_rev                           1               STRING     true      silicon_rev_fnl                 true            false     false     NOVAL }\
      { atx_pll_fb_select                             1               STRING     true      fb_select_fnl                   true            false     false     NOVAL }\
      { atx_pll_l_counter_enable                      1               STRING     true      enable_8G_buffer_fnl            true            false     false     NOVAL }\
      { atx_pll_dsm_mode                              1               STRING     true      dsm_mode                        true            false     false     NOVAL }\
      { atx_pll_output_clock_frequency                1               STRING     true      output_clock_frequency          true            false     false     NOVAL }\
      { atx_pll_reference_clock_frequency             1               STRING     true      reference_clock_frequency_fnl   true            false     false     NOVAL }\
      { atx_pll_m_counter                             1               INTEGER    true      m_counter                       true            false     false     NOVAL }\
      { atx_pll_ref_clk_div                           1               INTEGER    true      ref_clk_div                     true            false     false     NOVAL }\
      { atx_pll_l_counter                             1               INTEGER    true      l_counter                       true            false     false     NOVAL }\
      { atx_pll_dsm_fractional_division               1               INTEGER    true      k_counter                       true            false     false     NOVAL }\
      { atx_pll_hclk_divide                           1               INTEGER    true      hclk_divide                     true            false     false     NOVAL }\
      { atx_pll_tank_sel                              1               STRING     true      tank_sel                        true            false     false     NOVAL }\
      { atx_pll_tank_band                             1               STRING     true      tank_band                       true            false     false     NOVAL }\
      { pma_lc_refclk_select_mux_silicon_rev          1               STRING     true      silicon_rev_fnl                 true            false     false     NOVAL }\
      { pma_lc_refclk_select_mux_refclk_select        1               STRING     true      refclk_index                    true            false     false     {"0:ref_iqclk0" "1:ref_iqclk1" "2:ref_iqclk2" "3:ref_iqclk3" "4:ref_iqclk4"} }\
   }

set logical_parameters {\
      { NAME                    M_RCFG_REPORT   TYPE       DERIVED   M_MAPS_FROM                     HDL_PARAMETER   ENABLED   VISIBLE   M_MAP_VALUES }\
      { lc_refclk_select        1               INTEGER    true      refclk_index                    false           false     false     NOVAL }\
   }

# IMPORTANT NOTES
# 1) atx_pll_lc_mode default in atom is lccmu_pd, but lccmu_normal is used as default in IP and wrappers
set parameters_to_be_removed {\
      { NAME                                                               M_RCFG_REPORT   TYPE       DERIVED   HDL_PARAMETER   ENABLED   VISIBLE   DEFAULT_VALUE }\
      { atx_pll_lc_mode                                                    1               STRING     true      true            false     false     "lccmu_normal" }\
      { atx_pll_lc_atb                                                     1               STRING     true      true            false     false     "atb_selectdisable" }\
      { atx_pll_cp_compensation_enable                                     1               STRING     true      true            false     false     "true"}\
      { atx_pll_cp_current_setting                                         1               STRING     true      true            false     false     "cp_current_setting0" }\
      { atx_pll_cp_testmode                                                1               STRING     true      true            false     false     "cp_normal" }\
      { atx_pll_cp_lf_3rd_pole_freq                                        1               STRING     true      true            false     false     "lf_3rd_pole_setting0" }\
      { atx_pll_cp_lf_4th_pole_freq                                        1               STRING     true      true            false     false     "lf_4th_pole_setting0" }\
      { atx_pll_cp_lf_order                                                1               STRING     true      true            false     false     "lf_2nd_order" }\
      { atx_pll_lf_resistance                                              1               STRING     true      true            false     false     "lf_setting0" }\
      { atx_pll_lf_ripplecap                                               1               STRING     true      true            false     false     "lf_ripple_cap" }\
      { atx_pll_d2a_voltage                                                1               STRING     true      true            false     false     "d2a_disable" }\
      { atx_pll_dsm_out_sel                                                1               STRING     true      true            false     false     "pll_dsm_disable" }\
      { atx_pll_dsm_ecn_bypass                                             1               STRING     true      true            false     false     "false" }\
      { atx_pll_dsm_ecn_test_en                                            1               STRING     true      true            false     false     "false" }\
      { atx_pll_dsm_fractional_value_ready                                 1               STRING     true      true            false     false     "pll_k_ready" }\
      { atx_pll_vco_bypass_enable                                          1               STRING     true      true            false     false     "false" }\
      { atx_pll_cascadeclk_test                                            1               STRING     true      true            false     false     "cascadetest_off" }\
      { atx_pll_tank_voltage_coarse                                        1               STRING     true      true            false     false     "vreg_setting_coarse1" }\
      { atx_pll_tank_voltage_fine                                          1               STRING     true      true            false     false     "vreg_setting3" }\
      { atx_pll_output_regulator_supply                                    1               STRING     true      true            false     false     "vreg1v_setting1" }\
      { atx_pll_overrange_voltage                                          1               STRING     true      true            false     false     "over_setting3" }\
      { atx_pll_underrange_voltage                                         1               STRING     true      true            false     false     "under_setting3" }\
      { atx_pll_vreg0_output                                               1               STRING     true      true            false     false     "vccdreg_nominal" }\
      { atx_pll_vreg1_output                                               1               STRING     true      true            false     false     "vccdreg_nominal" }\
      { atx_pll_is_cascaded_pll                                            1               STRING     true      true            false     false     "false" }\
      { pma_lc_refclk_select_mux_inclk0_logical_to_physical_mapping        1               STRING     true      true            false     false     "ref_iqclk0" }\
      { pma_lc_refclk_select_mux_inclk1_logical_to_physical_mapping        1               STRING     true      true            false     false     "ref_iqclk1" }\
      { pma_lc_refclk_select_mux_inclk2_logical_to_physical_mapping        1               STRING     true      true            false     false     "ref_iqclk2" }\
      { pma_lc_refclk_select_mux_inclk3_logical_to_physical_mapping        1               STRING     true      true            false     false     "ref_iqclk3" }\
      { pma_lc_refclk_select_mux_inclk4_logical_to_physical_mapping        1               STRING     true      true            false     false     "ref_iqclk4" }\
   }

}

##################################################################################################################################################
#
##################################################################################################################################################
proc ::altera_xcvr_atx_pll_vi::parameters::declare_parameters { {device_family "Arria VI"} } {
   variable display_items_pll
   variable generation_display_items
   variable parameters
   variable parameters_allowed_range
   variable atom_parameters
   variable logical_parameters
   variable parameters_to_be_removed

   # Which parameters are included in reconfig reports is parameter dependent
   ip_add_user_property_type M_RCFG_REPORT integer

   ::alt_xcvr::utils::reconfiguration_arria10::declare_parameters
   ip_set "parameter.rcfg_file_prefix.DEFAULT_VALUE" "altera_xcvr_atx_pll_a10"

   ip_declare_parameters $parameters
   ip_declare_parameters $parameters_allowed_range
   ip_declare_parameters $atom_parameters
   ip_declare_parameters $logical_parameters
   ip_declare_parameters $parameters_to_be_removed

   ::mcgb_package_vi::mcgb::set_hip_cal_done_enable_maps_from enable_hip_cal_done_port
   ::mcgb_package_vi::mcgb::set_output_clock_frequency_maps_from output_clock_frequency
   ::mcgb_package_vi::mcgb::set_protocol_mode_maps_from prot_mode_fnl
   ::mcgb_package_vi::mcgb::set_silicon_rev_maps_from silicon_rev_fnl
   ::mcgb_package_vi::mcgb::declare_mcgb_parameters

   ip_declare_display_items $display_items_pll

   ::mcgb_package_vi::mcgb::set_mcgb_display_item_properties "" tab
   ::mcgb_package_vi::mcgb::declare_mcgb_display_items

   ::alt_xcvr::utils::reconfiguration_arria10::declare_display_items "" tab

   ip_declare_display_items $generation_display_items

   # Initialize device information (to allow sharing of this function across device families)
   ip_set "parameter.device_family.SYSTEM_INFO" DEVICE_FAMILY
   ip_set "parameter.device_family.DEFAULT_VALUE" $device_family
   ip_set "parameter.speed_grade.allowed_ranges" [::alt_xcvr::utils::device::get_device_speedgrades $device_family]

  # Grab Quartus INI's
  ip_set "parameter.enable_advanced_options.DEFAULT_VALUE" [get_quartus_ini altera_xcvr_atx_pll_10_advanced ENABLED]
  ip_set "parameter.enable_hip_options.DEFAULT_VALUE" [get_quartus_ini altera_xcvr_fpll_atx_pll_10_hip_options ENABLED]
  ip_set "parameter.enable_manual_configuration.DEFAULT_VALUE" [get_quartus_ini altera_xcvr_atx_pll_10_manual_configuration ENABLED]

}

proc ::altera_xcvr_atx_pll_vi::parameters::validate {} {
   ip_message warning "This IP core is in beta stage. IP ports and parameters are subject to change."
   ::alt_xcvr::ip_tcl::messages::set_auto_message_level [ip_get "parameter.message_level.value"]
   ip_validate_parameters
   ip_validate_display_items
}

proc ::altera_xcvr_atx_pll_vi::parameters::validate_support_mode { PROP_NAME PROP_VALUE message_level } {
  if {$PROP_VALUE == "engineering_mode"} {
    ip_message $message_level "Engineering support mode has been selected. Engineering mode is for internal use only. Altera does not officially support or guarantee IP configurations for this mode."
  }
}

##################################################################################################################################################
# functions: converting user parameters to their final form (appropriate for the hdl) 
##################################################################################################################################################

## \TODO some of these functions needs to be implemented as mapped parameters

proc ::altera_xcvr_atx_pll_vi::parameters::convert_speed_grade { speed_grade } {
   set temp "4"
   if {       [string compare -nocase $speed_grade 1_H2]==0 } {
      set temp "2"   
   } elseif { [string compare -nocase $speed_grade 1_H3]==0 } {
      set temp "3"
   } elseif { [string compare -nocase $speed_grade 1_H4]==0 } {
      set temp "4"
   } else {
      set temp "4"
      #ip_message warning "Unexpected speed_grade($speed_grade), setting to $temp"   
   }
   
   ip_set "parameter.speed_grade_fnl.value" $temp    
}

proc ::altera_xcvr_atx_pll_vi::parameters::convert_dsm_mode { enable_fractional } {
   set temp_dsm_mode "dsm_mode_integer"
   
   switch $enable_fractional {
      "true"   {set temp_dsm_mode "dsm_mode_phase"}
      "false"  {set temp_dsm_mode "dsm_mode_integer"}
      default  {set temp_dsm_mode "dsm_mode_integer"}
   }
   ip_set "parameter.dsm_mode.value" $temp_dsm_mode    
}

proc ::altera_xcvr_atx_pll_vi::parameters::convert_buffer_selection { primary_pll_buffer } {
   if {       [string compare -nocase $primary_pll_buffer 8G]==0 } {
      ip_set "parameter.enable_8G_buffer_fnl.value" "true"
      ip_set "parameter.enable_16G_buffer_fnl.value" "false"
   } elseif { [string compare -nocase $primary_pll_buffer 16G]==0 } { 
      ip_set "parameter.enable_8G_buffer_fnl.value" "false"
      ip_set "parameter.enable_16G_buffer_fnl.value" "true"    
   } else {
      ip_set "parameter.enable_8G_buffer_fnl.value" "true"
      ip_set "parameter.enable_16G_buffer_fnl.value" "false"    
      ip_message warning "Unexpected primary_pll_buffer($primary_pll_buffer), enabling 8G buffer only"              
   }
}

proc ::altera_xcvr_atx_pll_vi::parameters::update_enable_8G_buffer_fnl { primary_pll_buffer } {
   if {       [string compare -nocase $primary_pll_buffer "GX clock output buffer"]==0 } {
      ip_set "parameter.enable_8G_buffer_fnl.value" "true"
   } elseif { [string compare -nocase $primary_pll_buffer "GT clock output buffer"]==0 } { 
      ip_set "parameter.enable_8G_buffer_fnl.value" "false"
   } else {
      ip_set "parameter.enable_8G_buffer_fnl.value" "true"
      ip_message warning "Unexpected primary_pll_buffer($primary_pll_buffer), enabling 8G buffer"              
   }
}

proc ::altera_xcvr_atx_pll_vi::parameters::update_enable_16G_buffer_fnl { primary_pll_buffer } {
   if {       [string compare -nocase $primary_pll_buffer "GX clock output buffer"]==0 } {
      ip_set "parameter.enable_16G_buffer_fnl.value" "false"
   } elseif { [string compare -nocase $primary_pll_buffer "GT clock output buffer"]==0 } { 
      ip_set "parameter.enable_16G_buffer_fnl.value" "true"    
   } else {
      ip_set "parameter.enable_16G_buffer_fnl.value" "false"    
      ip_message warning "Unexpected primary_pll_buffer($primary_pll_buffer), disabling 16G buffer"              
   }
}

proc  ::altera_xcvr_atx_pll_vi::parameters::convert_fb_select { pma_cgb_master_cgb_enable_iqtxrxclk} {
   if { [string compare -nocase $pma_cgb_master_cgb_enable_iqtxrxclk enable_iqtxrxclk]==0 } {         
      ip_set "parameter.fb_select_fnl.value" "iqtxrxclk_fb"
   } elseif {  [string compare -nocase $pma_cgb_master_cgb_enable_iqtxrxclk disable_iqtxrxclk]==0} {
      ip_set "parameter.fb_select_fnl.value" "direct_fb"
   } else {
      ip_set "parameter.fb_select_fnl.value" "direct_fb"
      ip_message warning "Unexpected feedback mode selecting direct_fb"
   }
}  

proc ::altera_xcvr_atx_pll_vi::parameters::convert_prot_mode { prot_mode } {
   if {       [string compare -nocase $prot_mode Basic]==0 } {
      ip_set "parameter.prot_mode_fnl.value" "basic_tx"
   } elseif { [string compare -nocase $prot_mode "PCIe Gen 1"]==0 } {
      ip_set "parameter.prot_mode_fnl.value" "pcie_gen1_tx"
   } elseif { [string compare -nocase $prot_mode "PCIe Gen 2"]==0 } {
      ip_set "parameter.prot_mode_fnl.value" "pcie_gen2_tx"
   } elseif { [string compare -nocase $prot_mode "PCIe Gen 3"]==0 } {
      ip_set "parameter.prot_mode_fnl.value" "pcie_gen3_tx"
   } else {
      ip_set "parameter.prot_mode_fnl.value" "basic_tx"
      ip_message warning "Unexpected prot_mode($prot_mode), selecting basic_tx"
   }       
}    

proc ::altera_xcvr_atx_pll_vi::parameters::convert_silicon_rev { silicon_rev } {
   #ip_message warning "::altera_xcvr_atx_pll_vi::parameters::convert_silicon_rev NOTE TO IP DEVELOPER: THIS FUNCTION MUST CHANGE"
   if {       [string compare -nocase $silicon_rev true]==0 } {
      ip_set "parameter.silicon_rev_fnl.value" "reva"
   } elseif { [string compare -nocase $silicon_rev false]==0 } {
      ip_set "parameter.silicon_rev_fnl.value" "reva"
   } else {
      ip_set "parameter.silicon_rev_fnl.value" "reva"
      ip_message warning "Unexpected silicon_rev($silicon_rev), selecting reva"
   }   
}       

proc ::altera_xcvr_atx_pll_vi::parameters::update_refclk_index { refclk_cnt } { 
   # update refclk_index allowed range from 0 to refclk_cnt-1
   set new_range 0
   for {set N 1} {$N < $refclk_cnt} {incr N} {
      lappend new_range $N
   }
   ip_set "parameter.refclk_index.ALLOWED_RANGES" $new_range
}

proc ::altera_xcvr_atx_pll_vi::parameters::update_refclk_auto { select_manual_config auto_list } {
   if {!$select_manual_config} {#auto-config
      #get all frequencies
      set all_freqs [dict keys $auto_list]
      #update set_auto_reference_clock_frequency range
      ip_set "parameter.set_auto_reference_clock_frequency.allowed_ranges" $all_freqs 
   } else {#manual-config
      #setting allowed range to anything will prevent user getting meaningless range errors while working in manual mode
      ip_set "parameter.set_auto_reference_clock_frequency.allowed_ranges" ""
   }
}

##
# feedback_clock_frequency_fnl is the parameter used in calculations
# \todo enable_fb_comp_bonding is directly referenced BAD !!!
proc ::altera_xcvr_atx_pll_vi::parameters::update_fbclk_freq { PROP_NAME select_manual_config enable_fb_comp_bonding atx_pll_cgb_div atx_pll_pma_width set_output_clock_frequency } {
   if {$enable_fb_comp_bonding} {
      if { !$select_manual_config } {
         # this is feedback comp bonding mode, in auto configuration --> user cannot set feedback frequency it is calculated
         set temp [expr $set_output_clock_frequency/($atx_pll_cgb_div*($atx_pll_pma_width/2))]
         ip_set "parameter.${PROP_NAME}.value" $temp
      } else {
         # manual configuration does not implemented external feecback mode (as well as feedback compensation mode)
         #catched else where do not message
         #ip_message error "::altera_xcvr_atx_pll_vi::parameters::update_fbclk_freq:: (external feedback)/(feedback compensation bonding) not supported in manual configuration mode"
         # set to default anyways
         set value [ip_get "parameter.${PROP_NAME}.DEFAULT_VALUE"]
         ip_set "parameter.${PROP_NAME}.value" $value
      }
   } else {
      # irrelevant hence set to default anyways
      # neither set nor fnl feedback clock frequencies are shown to the user in non external feedback modes and the value itself is irrelevant to the pll calculations
      set value [ip_get "parameter.${PROP_NAME}.DEFAULT_VALUE"]
      ip_set "parameter.${PROP_NAME}.value" $value
   }
}

##################################################################################################################################################
# functions: making pll calculations
################################################################################################################################################## 

## If in auto-configuration mode, the procedure makes RBC call. 
# result is copied into parameter.auto_list   
proc ::altera_xcvr_atx_pll_vi::parameters::calculate_pll_auto { select_manual_config test_mode \
                                                                \
                                                                speed_grade_fnl enable_8G_buffer_fnl enable_16G_buffer_fnl enable_fb_comp_bonding prot_mode_fnl silicon_rev_fnl bw_sel \
                                                                \
                                                                enable_fractional set_output_clock_frequency  feedback_clock_frequency_fnl atx_pll_cgb_div atx_pll_pma_width } {
   #start with empty lists
   set legality_return ""
   ip_set "parameter.auto_list.value" ""
   if {$select_manual_config} {#manual-config
      ip_set "parameter.auto_list.value" ""
   } else {#auto-config
      #ip_message info "::altera_xcvr_atx_pll_vi::parameters::calculate_pll_auto"
      if {!$test_mode} {
         if { !$enable_fb_comp_bonding  } {
            ## \todo how about all these parameters
            #set legality_check_argument "$speed_grade_fnl   $enable_8G_buffer_fnl $enable_16G_buffer_fnl  $prot_mode_fnl  $silicon_rev_fnl $bw_sel \
            #                             $enable_fractional $set_output_clock_frequency MHz"
            #set legality_return [::altera_xcvr_atx_pll_vi::pll_calculations::legality_check_auto $set_output_clock_frequency 0]
            set temp_out_freq [expr $set_output_clock_frequency*1000000]; #convert from MHz to Hz
            set legality_return [legality_check_auto $temp_out_freq]
         } else {
            set temp_out_freq [expr $set_output_clock_frequency*1000000]; #convert from MHz to Hz
            set temp_fb_freq [expr $feedback_clock_frequency_fnl*1000000]; #convert from MHz to Hz
            set legality_return [legality_check_feedback_auto $temp_out_freq $temp_fb_freq $enable_fb_comp_bonding]
         }
      } else {
         if {!$enable_fb_comp_bonding} {
            set legality_check_argument "$speed_grade_fnl   $enable_8G_buffer_fnl $enable_16G_buffer_fnl  $ext_fb  $enable_fb_comp_bonding  $prot_mode_fnl  $silicon_rev_fnl $bw_sel \
                                         $enable_fractional $set_output_clock_frequency MHz"
            set legality_return [legality_check_auto_mockup $legality_check_argument]
         } else {
            ip_message error "::altera_xcvr_atx_pll_vi::parameters::calculate_pll_auto:: Test mode does not implement pll computations for feedback compensation bonding."
         }
      }
   
      set temp_size [dict size $legality_return]
      if { $temp_size==0 } {
         ip_message error "::altera_xcvr_atx_pll_vi::parameters::calculate_pll_auto:: No valid setting found for the specified output frequency."
      } else {
         set status_reported [dict get $legality_return status]
         if { $status_reported != "good" } {
            if {!$enable_fb_comp_bonding} {
               ip_message error "No valid setting found for the specified output frequency ($set_output_clock_frequency MHz)."
            } else {
               ip_message error "No valid setting found for the specified output frequency ($set_output_clock_frequency MHz), pma width($atx_pll_pma_width) and Master CGB division factor($atx_pll_cgb_div)"
            }
         } else {
            #remove first element - status
            set legality_return [dict remove $legality_return status]
            #update auto-list               
            ip_set "parameter.auto_list.value" $legality_return
         }
      }
   }
}

## If in manual-configuration mode, the procedure makes RBC call. 
# result is copied into parameter.manual_list
proc ::altera_xcvr_atx_pll_vi::parameters::calculate_pll_manual { select_manual_config test_mode \
                                                                  \
                                                                  speed_grade_fnl enable_8G_buffer_fnl enable_16G_buffer_fnl enable_fb_comp_bonding prot_mode_fnl silicon_rev_fnl bw_sel \
                                                                  \
                                                                  set_manual_reference_clock_frequency set_m_counter set_ref_clk_div set_l_counter set_k_counter feedback_clock_frequency_fnl} {
   #start with empty lists
   set legality_return ""
   ip_set "parameter.manual_list.value" ""
   if {!$select_manual_config} {#auto-config
      ip_set "parameter.manual_list.value" ""
   } else {#manual-config
      ip_message info "::altera_xcvr_atx_pll_vi::parameters::calculate_pll_manual"
      if {!$test_mode} {
         if      { !$enable_fb_comp_bonding  } {
            ## \todo how about all other related parameters
            set temp_ref_freq [expr $set_manual_reference_clock_frequency*1000000]; #convert from MHz to Hz         
            set legality_return [legality_check_manual $temp_ref_freq $set_l_counter $set_m_counter $set_ref_clk_div]
         } else {
            #set temp_ref_freq [expr $set_manual_reference_clock_frequency*1000000]; #convert from MHz to Hz      
            #set temp_fb_freq [expr $feedback_clock_frequency_fnl*1000000]; #convert from MHz to Hz   
            # n is inferred, m does not matter (only allow '1')
            #set legality_return [legality_check_feedback_manual $temp_ref_freq $temp_fb_freq $set_l_counter $enable_fb_comp_bonding]
            ip_message error "::altera_xcvr_atx_pll_vi::parameters::calculate_pll_manual:: feedback compensation bonding not supported in manual configuration mode"
         }
      } else {
         if {!$enable_fb_comp_bonding} {
            set legality_check_argument "$speed_grade_fnl                           $enable_8G_buffer_fnl  $enable_16G_buffer_fnl  $ext_fb         $enable_fb_comp_bonding        $prot_mode_fnl  $silicon_rev_fnl $bw_sel \
                                         $set_manual_reference_clock_frequency MHz  $set_m_counter         $set_ref_clk_div        $set_l_counter  $set_k_counter"
            set legality_return [legality_check_manual_mockup $legality_check_argument]
         } else {
            ip_message error "::altera_xcvr_atx_pll_vi::parameters::calculate_pll_manual:: test mode does not implement pll computations for feedback compensation bonding"
         }
      }
   
      set temp_size [dict size $legality_return]
      if { $temp_size==0 } {
         ip_message error "::altera_xcvr_atx_pll_vi::parameters::calculate_pll_manual:: argument size 0"
      } else {
         set status_reported [dict get $legality_return status]
         if { $status_reported != "good" } {
            ip_message error "::altera_xcvr_atx_pll_vi::parameters::calculate_pll_manual:: invalid calculation result  $status_reported"
         } else {
            #remove first element - status
            set legality_return [dict remove $legality_return status]
            #update manual-list
            ip_set "parameter.manual_list.value" $legality_return
         }
      }
   }
}

## Whether in manual-configuration or auto-configuration mode, the procedure creates one common pll_setting to be copied into hdl parameters. 
# depending on the configuration mode the logic pupulating pll_setting changes
proc ::altera_xcvr_atx_pll_vi::parameters::update_pll_setting { select_manual_config auto_list manual_list set_auto_reference_clock_frequency \
                                                                \
                                                                set_manual_reference_clock_frequency set_m_counter set_ref_clk_div set_l_counter set_k_counter \
                                                                \
                                                                set_output_clock_frequency } {
   # starting with an empty list	
   ip_set "parameter.pll_setting.value" ""
   
   # eventually temp will be copied into parameter.pll_setting
   set temp ""
   
   if {$select_manual_config} {#manual-config
      set manual_list_size [dict size $manual_list]
      if { $manual_list_size==0 } {
         ip_message error "::altera_xcvr_atx_pll_vi::parameters::update_pll_setting::  argument size 0"
      } else {
         # populate temp from user input
         # if we are in this point user input is already validated
         dict set temp refclk "$set_manual_reference_clock_frequency MHz"
         dict set temp m_cnt  $set_m_counter
         dict set temp n_cnt  $set_ref_clk_div
         dict set temp l_cnt  $set_l_counter
         dict set temp k_cnt  $set_k_counter
         
         # populate temp with output frequency information from calculation result 
         # with Mhz appended
         set valid_config [dict get $manual_list config]                     
         dict set temp outclk [dict get $valid_config out_freq]
         
         # populate other related calculation results
         dict set temp tank_sel [dict get $valid_config tank_sel]
         dict set temp tank_band [dict get $valid_config tank_band]
      }
   } else {#auto-config
      set auto_list_size [dict size $auto_list]
      if { $auto_list_size==0 } {
         # no need to print this has already been detected
         #ip_message error "::altera_xcvr_atx_pll_vi::parameters::update_pll_setting::  argument size 0"
      } else {
         set ref_clk_freq_formatted [format "%.6f" $set_auto_reference_clock_frequency]
         if { ![dict exists $auto_list $ref_clk_freq_formatted] } {
            ip_message error "Selected reference clock frequency ($set_auto_reference_clock_frequency MHz) is not valid."
         } else {
	        
	        # get the line in dictionary with slected frequency  
            set selected_item [dict get $auto_list $ref_clk_freq_formatted]
            
            # populate temp with info from calculation result 
            dict set temp refclk "$ref_clk_freq_formatted MHz"
            dict set temp m_cnt  [dict get $selected_item m]
            dict set temp n_cnt  [dict get $selected_item n]
            dict set temp l_cnt  [dict get $selected_item l]
            dict set temp k_cnt  [dict get $selected_item k]

            dict set temp tank_sel [dict get $selected_item tank_sel]
            dict set temp tank_band [dict get $selected_item tank_band]
            
            # populate temp with output frequency using user input 
            # if we are in this point user input is already validated
            # with Mhz appended
            set user_out_freq $set_output_clock_frequency
            dict set temp outclk "$user_out_freq MHz"
         }
      }
   }
   
   ip_set "parameter.pll_setting.value" $temp
}

## copy effective m from pll computation 
proc ::altera_xcvr_atx_pll_vi::parameters::update_effective_m_counter { PROP_NAME enable_fb_comp_bonding select_manual_config auto_list set_auto_reference_clock_frequency} {
   # set the value to default at the beginning, to prevent any unexpected outside the range errors 
   set value [ip_get "parameter.${PROP_NAME}.DEFAULT_VALUE"]
   ip_set "parameter.${PROP_NAME}.value" $value

   if {$enable_fb_comp_bonding} {#this is the only case we want this function to be executed, in other cases effective m does not matter
      if {$select_manual_config} {#manual-config
         #catched elsewhere
         #ip_message error "::altera_xcvr_atx_pll_vi::parameters::update_effective_m_counter:: (external feedback)/(feedback compensation bonding) not supported in manual configuration mode""
      } else {#auto-config
         set auto_list_size [dict size $auto_list]
         if { $auto_list_size==0 } {
            # no need to print this has already been detected
            #ip_message error "::altera_xcvr_atx_pll_vi::parameters::update_effective_m_counter::  argument size 0"
         } else {
            set ref_clk_freq_formatted [format "%.6f" $set_auto_reference_clock_frequency]
            if { ![dict exists $auto_list $ref_clk_freq_formatted] } {
               # no need to print this has already been detected
               # ip_message error "::altera_xcvr_atx_pll_vi::parameters::update_effective_m_counter:: no entry can be found in dictionary"
            } else {
               # get the line in dictionary with selected frequency  
               set selected_item [dict get $auto_list $ref_clk_freq_formatted]
               ip_set "parameter.${PROP_NAME}.value" [dict get $selected_item effective_m]
            }
         }
      }
   }
}

##################################################################################################################################################
# functions: copying calculated pll settings to corresponding hdl parameters 
################################################################################################################################################## 

proc ::altera_xcvr_atx_pll_vi::parameters::update_reflk_freq { pll_setting } {
   set pll_setting_size [dict size $pll_setting]
   if { $pll_setting_size!=0 } {      
      if { ![dict exists $pll_setting refclk] } {
         ip_message error "::altera_xcvr_atx_pll_vi::parameters::update_reflk_freq cannot find the entry"
      } else {
         ip_set "parameter.reference_clock_frequency_fnl.value" [dict get $pll_setting refclk]
      }
   }
}
                
proc ::altera_xcvr_atx_pll_vi::parameters::update_output_clock_frequency { pll_setting } {
   set pll_setting_size [dict size $pll_setting]
   if { $pll_setting_size!=0 } {
      if { ![dict exists $pll_setting outclk] } {
         ip_message error "::altera_xcvr_atx_pll_vi::parameters::update_output_clock_frequency cannot find the entry"
      } else {
         ip_set "parameter.output_clock_frequency.value" [dict get $pll_setting outclk]
      }
   }
}

proc ::altera_xcvr_atx_pll_vi::parameters::update_m_counter { pll_setting } {
   set pll_setting_size [dict size $pll_setting]
   if { $pll_setting_size!=0 } {
      if { ![dict exists $pll_setting m_cnt] } {
         ip_message error "::altera_xcvr_atx_pll_vi::parameters::update_m_counter cannot find the entry"
      } else {
         ip_set "parameter.m_counter.value" [dict get $pll_setting m_cnt]
      }
   }
}

proc ::altera_xcvr_atx_pll_vi::parameters::update_n_counter { pll_setting } {
   set pll_setting_size [dict size $pll_setting]
   if { $pll_setting_size!=0 } {
      if { ![dict exists $pll_setting n_cnt] } {
         ip_message error "::altera_xcvr_atx_pll_vi::parameters::update_n_counter cannot find the entry"
      } else {
         ip_set "parameter.ref_clk_div.value" [dict get $pll_setting n_cnt]
      }
   }
}

proc ::altera_xcvr_atx_pll_vi::parameters::update_l_counter { pll_setting } {
   set pll_setting_size [dict size $pll_setting]
   if { $pll_setting_size!=0 } {
      if { ![dict exists $pll_setting l_cnt] } {
         ip_message error "::altera_xcvr_atx_pll_vi::parameters::update_l_counter cannot find the entry"
      } else {
         ip_set "parameter.l_counter.value" [dict get $pll_setting l_cnt]
      }
   }
}
proc ::altera_xcvr_atx_pll_vi::parameters::update_k_counter { pll_setting } {
   set pll_setting_size [dict size $pll_setting]
   if { $pll_setting_size!=0 } {
      if { ![dict exists $pll_setting k_cnt] } {
         ip_message error "::altera_xcvr_atx_pll_vi::parameters::update_k_counter cannot find the entry"
      } else {
         ip_set "parameter.k_counter.value" [dict get $pll_setting k_cnt]
      }
   }
}

proc ::altera_xcvr_atx_pll_vi::parameters::update_tank_sel { pll_setting } {
   set pll_setting_size [dict size $pll_setting]
   if { $pll_setting_size!=0 } {
      if { ![dict exists $pll_setting tank_sel] } {
         ip_message error "::altera_xcvr_atx_pll_vi::parameters::update_tank_sel cannot find the entry"
      } else {
         ip_set "parameter.tank_sel.value" [dict get $pll_setting tank_sel]
      }
   }
}

proc ::altera_xcvr_atx_pll_vi::parameters::update_tank_band { pll_setting } {
   set pll_setting_size [dict size $pll_setting]
   if { $pll_setting_size!=0 } {
      if { ![dict exists $pll_setting tank_band] } {
         ip_message error "::altera_xcvr_atx_pll_vi::parameters::update_tank_band cannot find the entry"
      } else {
         ip_set "parameter.tank_band.value" [dict get $pll_setting tank_band]
      }
   }
}

##################################################################################################################################################
# functions: mocking rbc calls - these functions are temporary 
##################################################################################################################################################
proc ::altera_xcvr_atx_pll_vi::parameters::legality_check_auto_mockup { temp } {
   
   # example dictionary structure:	
   #      set ret { { status    good} \
   #                { "1" { {m 2} {n 3} {l 4} {k 6} {lf_resistance lf_setting0} }... }\
   #                { "2" { {m 1} {n 3} {l 4} {k 6} {lf_resistance lf_setting0} }... }\
   #              }
   
   set test_mode_lcl 1
   if { $test_mode_lcl==1 } {
      dict set ret status good
      
      set temp_set_output_clock_frequency    [ip_get "parameter.set_output_clock_frequency.value"]
      
      set refclk1 [expr  $temp_set_output_clock_frequency/10]
      set refclk1 [format "%.6f" $refclk1]
      set m_1 [expr int($refclk1/10)]
      set refclk1_str "$refclk1"
      dict set ret $refclk1_str m $m_1
      dict set ret $refclk1_str n [expr 2*$m_1]
      dict set ret $refclk1_str l [expr 3*$m_1]
      dict set ret $refclk1_str k [expr 4*$m_1]
      dict set ret $refclk1_str tank_sel "lctank0"
      dict set ret $refclk1_str tank_band "lc_band0"
      
      set refclk2 [expr  $temp_set_output_clock_frequency/5]
      set refclk2 [format "%.6f" $refclk2]
      set m_2 [expr int($refclk2/10)]
      set refclk2_str "$refclk2"
      dict set ret $refclk2_str m $m_2
      dict set ret $refclk2_str n [expr 2*$m_2]
      dict set ret $refclk2_str l [expr 3*$m_2]
      dict set ret $refclk2_str k [expr 4*$m_2]
      dict set ret $refclk2_str tank_sel "lctank1"
      dict set ret $refclk2_str tank_band "lc_band1"
   } else {
      dict set ret status bad
   }
   return $ret     
}
    
proc ::altera_xcvr_atx_pll_vi::parameters::legality_check_manual_mockup { temp } {
	
   # example dictionary structure:
   #      set ret { { status    good} \
   #                { config   { {out_freq 2520.0 MHz} {lf_resistance lf_setting0}... } } \
   #              }
	
   #   dict set ret status error

   set test_mode_lcl 1
   if { $test_mode_lcl==1 } {
              
      dict set ret status good
      
      set temp_reference_clock_frequency [ip_get "parameter.set_manual_reference_clock_frequency.value"]  
      set temp_set_m_counter             [ip_get "parameter.set_m_counter.value"]            
      set temp_set_ref_clk_div           [ip_get "parameter.set_ref_clk_div.value"]          
      set temp_set_l_counter             [ip_get "parameter.set_l_counter.value"]            
      set temp_set_k_counter             [ip_get "parameter.set_k_counter.value"]
      
      set k_factor "1.$temp_set_k_counter" 
      
      set out_freq [expr (($k_factor)*($temp_reference_clock_frequency)*($temp_set_m_counter))/(($temp_set_ref_clk_div)*($temp_set_l_counter))]
      
      dict set ret config out_freq "$out_freq MHz"
      dict set ret config tank_sel "lctank0"
      dict set ret config tank_band "lc_band0"
   } else {
      dict set ret status bad
   }
   return $ret     
} 

 
