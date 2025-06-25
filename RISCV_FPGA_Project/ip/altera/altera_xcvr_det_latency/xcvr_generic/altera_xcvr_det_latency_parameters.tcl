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


# +--------------------------------------------------------------------------------
# | Tcl library of Custom PHY parameter definition functions
# +----------------------------------------------------------------------------------
source ../../altera_xcvr_8g_custom/xcvr_generic/xcvr_custom_phy_parameters.tcl


# +---------------------------------------------------------------------------
# | This procedure adds all the common parameters for SIV and SV xcvr_generic
# |
# +---------------------------------------------------------------------------
proc detlat_add_common_parameters {} {
  #parameter operation_mode
  #parameter ser_base_factor
  #parameter ser_words
  #parameter data_rate
  #parameter tx_bitslip_enable
  #parameter use_8b10b
  #parameter word_aligner_mode
  #parameter run_length_violation_checking
  #parameter use_double_data_mode
  #parameter coreclk_0ppm_enable
  #parameter pll_refclk_cnt
  #parameter pll_refclk_freq
  #parameter pll_refclk_select
  #parameter cdr_refclk_select
  #parameter plls
  #parameter pll_type
  #parameter pll_select
  #parameter mgmt_clk_in_mhz
  #parameter manual_reset
  #parameter starting_channel_number
  #parameter rx_use_cruclk
    
  #General Options
  # Adding all the parameter under General Options

  # adding parameter to determine the xcvr's operation mode
  add_parameter operation_mode STRING "Duplex"
  set_parameter_property operation_mode DEFAULT_VALUE "Duplex"
  set_parameter_property operation_mode DISPLAY_NAME "Mode of operation"
  set_parameter_property operation_mode ALLOWED_RANGES {Duplex RX TX}
  set_parameter_property operation_mode HDL_PARAMETER true
  set_parameter_property operation_mode DESCRIPTION "Select TX to transmit data, RX to receive data or Duplex to both receive and transmit."
  add_display_item "General" operation_mode parameter

  # adding number of channels aka lanes
  add_parameter lanes INTEGER 1
  set_parameter_property lanes DEFAULT_VALUE 1
  set_parameter_property lanes DISPLAY_NAME "Number of lanes"
  set_parameter_property lanes HDL_PARAMETER true
  set_parameter_property lanes DESCRIPTION "Number of channels in the transceiver."
  add_display_item "General" lanes parameter
  
  # adding deserialization factor
  add_parameter gui_deser_factor INTEGER 8
  set_parameter_property gui_deser_factor DEFAULT_VALUE 8
  set_parameter_property gui_deser_factor ALLOWED_RANGES {8 10 16 20 32 40}
  set_parameter_property gui_deser_factor DISPLAY_NAME "FPGA fabric transceiver interface width"
  set_parameter_property gui_deser_factor HDL_PARAMETER false
  set_parameter_property gui_deser_factor DESCRIPTION "Specifies the word size between the FPGA fabric and PCS."
  add_display_item "General" gui_deser_factor parameter

  add_parameter ser_base_factor INTEGER 8
  set_parameter_property ser_base_factor DEFAULT_VALUE 8
  set_parameter_property ser_base_factor VISIBLE false
  set_parameter_property ser_base_factor DERIVED true
  set_parameter_property ser_base_factor HDL_PARAMETER true
  
  add_parameter ser_words INTEGER 1
  set_parameter_property ser_words DEFAULT_VALUE 1
  set_parameter_property ser_words VISIBLE false
  set_parameter_property ser_words DERIVED true
  set_parameter_property ser_words HDL_PARAMETER true

  #     # PCS-PMA Interface Width
  add_parameter gui_pcs_pma_width STRING PARAM_DEFAULT
  set_parameter_property gui_pcs_pma_width DEFAULT_VALUE PARAM_DEFAULT
  set_parameter_property gui_pcs_pma_width DISPLAY_NAME "PCS-PMA interface width"
  set_parameter_property gui_pcs_pma_width HDL_PARAMETER false
  set_parameter_property gui_pcs_pma_width DESCRIPTION "Specifes the datapath width between the transceiver PCS and PMA."
  add_display_item "General" gui_pcs_pma_width parameter
  
  add_parameter pcs_pma_width INTEGER 8
  set_parameter_property pcs_pma_width DEFAULT_VALUE 8
  set_parameter_property pcs_pma_width VISIBLE false
  set_parameter_property pcs_pma_width DERIVED true
  set_parameter_property pcs_pma_width HDL_PARAMETER true
  
  # adding pll type parameter - GUI param is symbolic only
  add_parameter gui_pll_type STRING "CMU"
  set_parameter_property gui_pll_type DEFAULT_VALUE "CMU"
  set_parameter_property gui_pll_type ALLOWED_RANGES {"CMU" "ATX"}
  set_parameter_property gui_pll_type DISPLAY_NAME "PLL type"
  set_parameter_property gui_pll_type UNITS None
  set_parameter_property gui_pll_type ENABLED true
  set_parameter_property gui_pll_type VISIBLE true
  set_parameter_property gui_pll_type DISPLAY_HINT ""
  set_parameter_property gui_pll_type HDL_PARAMETER false
  set_parameter_property gui_pll_type DESCRIPTION "Specifies either a CMU or ATX PLL. The CMU PLL has a larger frequency range than the ATX PLL. The ATX PLL is designed to improve jitter performance and achieves lower channel-to-channel skew; however, it supports a narrower range of data rates and reference clock frequencies. Another advantage of the ATX PLL is that it does not use a transceiver channel, while the CMU PLL does. Because the CMU PLL is more versatile, it is specified as the default setting."
  add_display_item "General" gui_pll_type parameter

  # adding data rate parameter
  add_parameter data_rate STRING "614.4 Mbps"
  set_parameter_property data_rate DEFAULT_VALUE "614.4 Mbps"
  set_parameter_property data_rate DISPLAY_NAME "Data rate"
  set_parameter_property data_rate HDL_PARAMETER true
  set_parameter_property data_rate DESCRIPTION "Specifies the data rate."
  add_display_item "General" data_rate parameter

  add_parameter gui_base_data_rate STRING "1228.8 Mbps"
  set_parameter_property gui_base_data_rate DEFAULT_VALUE "1228.8 Mbps"
  set_parameter_property gui_base_data_rate DISPLAY_NAME "Base data rate"
  set_parameter_property gui_base_data_rate HDL_PARAMETER false
  set_parameter_property gui_base_data_rate DESCRIPTION "For systems that transmit and receive data at more than one data rate, select a base data rate that minimizes the number of PLLs required to generate the clocks for data transmission. The available options are dynamically computed based on the data rate you specified as long as those base data rates are within the frequency range of the PLL."
  add_display_item "General" gui_base_data_rate parameter

  add_parameter base_data_rate STRING "1228.8 Mbps"
  set_parameter_property base_data_rate DEFAULT_VALUE "1228.8 Mbps"
  set_parameter_property base_data_rate HDL_PARAMETER true
  set_parameter_property base_data_rate DERIVED true
  set_parameter_property base_data_rate VISIBLE false
  
  # adding pll input clock aka pll_refclk_freq parameter - GUI param is symbolic only
  add_parameter gui_pll_refclk_freq STRING "30.72 MHz"
  set_parameter_property gui_pll_refclk_freq DEFAULT_VALUE "30.72 MHz"
#  set_parameter_property gui_pll_refclk_freq ALLOWED_RANGES {"30.72 MHz" "61.44 MHz" "76.80 MHz" "122.88 MHz" "153.60 MHz" "245.76 MHz" "307.20 MHz" "491.52 MHz" "614.40 MHz"}
  set_parameter_property gui_pll_refclk_freq DISPLAY_NAME "Input clock frequency"
  set_parameter_property gui_pll_refclk_freq UNITS None
  set_parameter_property gui_pll_refclk_freq DISPLAY_HINT "include frequency or period unit"
  set_parameter_property gui_pll_refclk_freq HDL_PARAMETER false
  set_parameter_property gui_pll_refclk_freq DESCRIPTION "Specifies the input clock frequency."
  add_display_item "General" gui_pll_refclk_freq parameter

  # adding ref-clk port for CDR - hidden in GUI
  set DESCRIPTION "Enables CDR refclk support - expose seperate TX PLL ref-clock and CDR ref-clock"
  add_parameter en_cdrref_support INTEGER 0
  set_parameter_property en_cdrref_support  DEFAULT_VALUE 0
  set_parameter_property en_cdrref_support  DISPLAY_NAME "Enable CDR refclk support"
  set_parameter_property en_cdrref_support  HDL_PARAMETER true
  set_parameter_property en_cdrref_support  DISPLAY_HINT BOOLEAN
  set_parameter_property en_cdrref_support  DESCRIPTION $DESCRIPTION
  set_parameter_property en_cdrref_support  VISIBLE false
  add_display_item "Options" en_cdrref_support  parameter
  
  common_add_parameter gui_pll_feedback_path boolean 0 {PLLFEEDBACK}
  set_parameter_property gui_pll_feedback_path DEFAULT_VALUE 0
  set_parameter_property gui_pll_feedback_path HDL_PARAMETER false
  set_parameter_property gui_pll_feedback_path DISPLAY_NAME "Enable tx_clkout feedback path for TX PLL"
  set_parameter_property gui_pll_feedback_path DESCRIPTION "Compensate latency uncertainty in Tx dataout and Tx clockout paths relative to the reference clock."
  add_display_item "General" gui_pll_feedback_path parameter

  add_parameter pll_feedback_path STRING "no_compensation"
  set_parameter_property pll_feedback_path DEFAULT_VALUE "no_compensation"
  set_parameter_property pll_feedback_path ALLOWED_RANGES {"no_compensation:No compensation" "tx_clkout:Tx clockout"}
  set_parameter_property pll_feedback_path HDL_PARAMETER true
  set_parameter_property pll_feedback_path DERIVED true
  set_parameter_property pll_feedback_path VISIBLE false
  
  # SW/DW path selection
  set description "The desired width of the data interface between the deserializer and the PCS. 'Single' for an 8 or 10 bits. 'Double' for a 16 or 20 bits."
  add_parameter use_double_data_mode string "DEPRECATED"
  set_parameter_property use_double_data_mode DEFAULT_VALUE "DEPRECATED"
  set_parameter_property use_double_data_mode DERIVED false
  set_parameter_property use_double_data_mode VISIBLE false
  set_parameter_property use_double_data_mode HDL_PARAMETER false
  set_parameter_property use_double_data_mode DESCRIPTION $description

  
  #     # Word Aligner
  # adding parameter for manual word alignment
  common_add_parameter word_aligner_mode string "deterministic_latency" {RX}
  set_parameter_property word_aligner_mode DEFAULT_VALUE "deterministic_latency"
  set_parameter_property word_aligner_mode DISPLAY_NAME "Word alignment mode"
  set_parameter_property word_aligner_mode ALLOWED_RANGES {"deterministic_latency:Deterministic latency state machine" "manual:Manual"}
  set_parameter_property word_aligner_mode DISPLAY_HINT "radio"
  set_parameter_property word_aligner_mode HDL_PARAMETER true
#  set_parameter_property word_aligner_mode DESCRIPTION "Select the type of word alignment mode. Choose Deterministic latency state machine to enable word alignment with deterministic latency in the RX path without reliance on compensation in TX path. Choose manual mode to use bit position reporting of RX word aligner output to compensate for latency variation on the TX; backward compatible with Stratix IV and Arria II GX features."
  set_parameter_property word_aligner_mode DESCRIPTION "Choose Deterministic latency state machine to enable word alignment with deterministic latency in the RX path without reliance on compensation in TX path WHILE manual mode to compensate for latency variation on the TX; backward compatible with Stratix IV and Arria II GX features. It creates the following option ports: rx_syncstatus and rx_patterndetect."
  add_display_item "Additional Options" word_aligner_mode parameter
  
  # Additional Options
  #set DESCRIPTION "Enables TX bitslip when selected, creates the following ports: tx_bitslipboundaryselect, rx_bitslipboundaryselectout"
  #add_string_parameter_as_boolean tx_bitslip_enable "false" {TX} "Enable TX Bitslip" $DESCRIPTION "Protocol Setting"
  common_add_parameter gui_tx_bitslip_enable boolean 0 {TX}
  set_parameter_property gui_tx_bitslip_enable DEFAULT_VALUE 0
  set_parameter_property gui_tx_bitslip_enable HDL_PARAMETER false
  set_parameter_property gui_tx_bitslip_enable DISPLAY_NAME "TX bitslip"
  set_parameter_property gui_tx_bitslip_enable DESCRIPTION "Enables TX bitslip to compensate for latency variation on RX, it uses the value of bitslipboundaryselect to compensate for bits slipped on the RX datapath to achieve deterministic latency. Tt creates the following port: tx_bitslipboundaryselect."
  add_display_item "Additional Options" gui_tx_bitslip_enable parameter

  add_parameter tx_bitslip_enable STRING "false"
  set_parameter_property tx_bitslip_enable DEFAULT_VALUE "false"
  set_parameter_property tx_bitslip_enable ALLOWED_RANGES {"true:Enable" "false:Disable"}
  set_parameter_property tx_bitslip_enable HDL_PARAMETER true
  set_parameter_property tx_bitslip_enable DERIVED true
  set_parameter_property tx_bitslip_enable VISIBLE false

  # adding parameter for enable run_length checking
  common_add_parameter gui_enable_run_length boolean 0 {RX}
  set_parameter_property gui_enable_run_length VISIBLE true
  set_parameter_property gui_enable_run_length DEFAULT_VALUE 0
  set_parameter_property gui_enable_run_length DISPLAY_NAME "Enable run length violation checking"
  set_parameter_property gui_enable_run_length HDL_PARAMETER false
  set_parameter_property gui_enable_run_length DESCRIPTION "Enables the rx_rlv status port which is asserted when the number of 1s or 0s in the data stream exceeds the programmed run length violation threshold."
  add_display_item "Additional Options" gui_enable_run_length parameter
  
  add_parameter run_length_violation_checking INTEGER 40
  set_parameter_property run_length_violation_checking DEFAULT_VALUE 40
  set_parameter_property run_length_violation_checking VISIBLE true
  set_parameter_property run_length_violation_checking DISPLAY_NAME "Run length"
  set_parameter_property run_length_violation_checking HDL_PARAMETER true
  set_parameter_property run_length_violation_checking DESCRIPTION "Specifies the threshold for a run-length violation."
  add_display_item "Additional Options" run_length_violation_checking parameter
    
  # adding parameter to use additional status ports like syncstatus, etc...
  common_add_parameter gui_use_wa_status boolean 0 {RX}
  set_parameter_property gui_use_wa_status DISPLAY_NAME "Create optional word aligner status ports"
  set_parameter_property gui_use_wa_status HDL_PARAMETER false
  set_parameter_property gui_use_wa_status DESCRIPTION "Creates the following ports: rx_syncstatus, rx_patterndetect."
  add_display_item "Additional Options" gui_use_wa_status parameter
   
  # add use_8b10b parameter
#  add_string_parameter_as_boolean use_8b10b "false" {NoTag} "Enable 8B/10B encoder/decoder" "" "Protocol Setting"
  
  # adding parameter to use additional status ports like rx_errdetect, etc...
  common_add_parameter gui_use_8b10b_status boolean 0 {USE8B10B_RX}
  set_parameter_property gui_use_8b10b_status DISPLAY_NAME "Create optional 8B/10B control and status ports"
  set_parameter_property gui_use_8b10b_status HDL_PARAMETER false
  set_parameter_property gui_use_8b10b_status DESCRIPTION "Creates the following ports: rx_runningdisp, rx_errdetect, rx_disperr."
  add_display_item "Additional Options" gui_use_8b10b_status parameter

  # adding parameter to use additional status ports like syncstatus, etc...
  add_parameter gui_use_status boolean 0
  set_parameter_property gui_use_status DEFAULT_VALUE 0
  set_parameter_property gui_use_status DISPLAY_NAME "Create PMA optional status ports"
  set_parameter_property gui_use_status HDL_PARAMETER false
  set_parameter_property gui_use_status DESCRIPTION "Creates the following ports: rx_is_lockedtoref, rx_is_lockedtodata, rx_signaldetect."
  add_display_item "Additional Options" gui_use_status parameter

  # initially enable all TX and RX options
  common_set_parameter_group {TX RX} ENABLED true


  # add pll_refclk_cnt parameter
  add_parameter pll_refclk_cnt INTEGER
  set_parameter_property pll_refclk_cnt VISIBLE false
  set_parameter_property pll_refclk_cnt DEFAULT_VALUE 1
  set_parameter_property pll_refclk_cnt HDL_PARAMETER true
  set_parameter_property pll_refclk_cnt DERIVED true
  set_parameter_property pll_refclk_cnt ENABLED true
  
  # add pll_refclk_freq parameter (GUI parameter is declared uner Options tab)
  add_parameter pll_refclk_freq STRING "62.5 MHz"
  set_parameter_property pll_refclk_freq DEFAULT_VALUE "62.5 MHz"
  set_parameter_property pll_refclk_freq VISIBLE false
  set_parameter_property pll_refclk_freq DERIVED true
  set_parameter_property pll_refclk_freq HDL_PARAMETER true

  # add pll_refclk_select parameter
  add_parameter pll_refclk_select STRING "0"
  set_parameter_property pll_refclk_select DEFAULT_VALUE "0"
  set_parameter_property pll_refclk_select VISIBLE false
  set_parameter_property pll_refclk_select DERIVED true
  set_parameter_property pll_refclk_select HDL_PARAMETER true

  # add cdr_refclk_select parameter
  add_parameter cdr_refclk_select INTEGER 0
  set_parameter_property cdr_refclk_select DEFAULT_VALUE 0
  set_parameter_property cdr_refclk_select VISIBLE false
  set_parameter_property cdr_refclk_select DERIVED true
  set_parameter_property cdr_refclk_select HDL_PARAMETER true

  # add plls parameter
  add_parameter plls INTEGER
  set_parameter_property plls VISIBLE false
  set_parameter_property plls DEFAULT_VALUE 1
  set_parameter_property plls HDL_PARAMETER true
  set_parameter_property plls ENABLED true
  set_parameter_property plls DERIVED true

  add_parameter pll_type STRING
  set_parameter_property pll_type VISIBLE false
  set_parameter_property pll_type DEFAULT_VALUE "AUTO"
  set_parameter_property pll_type HDL_PARAMETER true
  set_parameter_property pll_type ENABLED true
  set_parameter_property pll_type DERIVED true

  add_parameter pll_select INTEGER
  set_parameter_property pll_select VISIBLE false
  set_parameter_property pll_select DEFAULT_VALUE 0
  set_parameter_property pll_select HDL_PARAMETER true
  set_parameter_property pll_select ENABLED true
  set_parameter_property pll_select DERIVED true

  add_parameter pll_reconfig INTEGER
  set_parameter_property pll_reconfig VISIBLE false
  set_parameter_property pll_reconfig DEFAULT_VALUE 0
  set_parameter_property pll_reconfig HDL_PARAMETER true
  set_parameter_property pll_reconfig ENABLED true
  set_parameter_property pll_reconfig DERIVED true

}


proc detlat_add_device_parameters {} {

	add_parameter device_family STRING 
	set_parameter_property device_family SYSTEM_INFO {DEVICE_FAMILY}
	set_parameter_property device_family DISPLAY_NAME "Device family"
	set_parameter_property device_family ENABLED false
	set_parameter_property device_family HDL_PARAMETER true
  set_parameter_property device_family DESCRIPTION "Arria V and Stratix V devices are supported."
	add_display_item "General" device_family parameter
	
#	set fams [::alt_xcvr::utils::device::list_s4_style_hssi_families]
	set fams [::alt_xcvr::utils::device::list_s5_style_hssi_families]
	set fams [concat $fams [::alt_xcvr::utils::device::list_a5_style_hssi_families] ]
	set fams [concat $fams [::alt_xcvr::utils::device::list_c5_style_hssi_families] ]
}
