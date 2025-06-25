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


# +---------------------------------------------------------------------------
# | This procedure adds all the common parameters for SIV and SV xcvr_generic
# |
# +---------------------------------------------------------------------------
proc add_common_parameters {} {
  #parameter protocol_hint
  #parameter bonded_group_size
  #parameter bonded_mode
  #parameter byte_order_mode
  #parameter byte_order_pad_pattern
  #parameter byte_order_pattern
  #parameter data_rate
  #parameter device_family
  #parameter lanes
  #parameter mgmt_clk_in_mhz
  #parameter operation_mode
  #parameter rate_match_pattern1
  #parameter rate_match_pattern2
  #parameter run_length_violation_checking
  #parameter rx_use_coreclk
  #parameter rx_use_cruclk	;# S4-only, not exposed
  #parameter ser_base_factor
  #parameter ser_words
  #parameter starting_channel_number INTEGER 0	# just leave out declaration
  #parameter tx_bitslip_enable
  #parameter tx_use_coreclk
  #parameter use_8b10b
  #parameter use_8b10b_manual_control
  #parameter use_double_data_mode
  #parameter use_rate_match_fifo
  #parameter word_align_pattern
  #parameter word_aligner_mode
  #parameter word_aligner_pattern_length
  #parameter word_aligner_state_machine_datacnt
  #parameter word_aligner_state_machine_errcnt
  #parameter word_aligner_state_machine_patterncnt
  #parameter pll_refclk_cnt
  #parameter pll_refclk_freq
  #parameter pll_refclk_select
  #parameter cdr_refclk_select
  #parameter plls
  #parameter pll_type
  #parameter pll_select
  
  #General Options
  # Adding all the parameter under General Options

  # adding GUI parameter to determine protocol mode
  add_parameter gui_parameter_rules STRING "Custom"
  set_parameter_property gui_parameter_rules DEFAULT_VALUE "Custom"
  set_parameter_property gui_parameter_rules DISPLAY_NAME "Parameter validation rules"
  set_parameter_property gui_parameter_rules ALLOWED_RANGES {Custom GIGE}
  set_parameter_property gui_parameter_rules HDL_PARAMETER false
  set_parameter_property gui_parameter_rules VISIBLE true
  set_parameter_property gui_parameter_rules DESCRIPTION "Selects the set of rules used to validate current parameter settings"
  add_display_item "Options" gui_parameter_rules parameter

  # adding parameter to determine protocol mode
  add_parameter protocol_hint STRING "basic"
  set_parameter_property protocol_hint DEFAULT_VALUE "basic"
  #set_parameter_property protocol_hint DISPLAY_NAME "Transceiver protocol"
  set_parameter_property protocol_hint ALLOWED_RANGES {basic gige}
  set_parameter_property protocol_hint HDL_PARAMETER true
  set_parameter_property protocol_hint VISIBLE false
  set_parameter_property protocol_hint DERIVED true
  #set_parameter_property protocol_hint DESCRIPTION "Transceiver protocol mode"
  #add_display_item "Options" protocol_hint parameter
  
  # adding parameter to determine the xcvr's operation mode
  add_parameter operation_mode STRING "Duplex"
  set_parameter_property operation_mode DEFAULT_VALUE "Duplex"
  set_parameter_property operation_mode DISPLAY_NAME "Mode of operation"
  set_parameter_property operation_mode ALLOWED_RANGES {Duplex RX TX}
  set_parameter_property operation_mode HDL_PARAMETER true
  set_parameter_property operation_mode DESCRIPTION "Select TX to transmit data, RX to receive data or Duplex to both receive and transmit"
  add_display_item "Options" operation_mode parameter
  
  #     # adding number of channels aka lanes
  add_parameter lanes INTEGER 1
  set_parameter_property lanes DEFAULT_VALUE 1
  set_parameter_property lanes DISPLAY_NAME "Number of lanes"
  set_parameter_property lanes HDL_PARAMETER true
  set_parameter_property lanes DESCRIPTION "Specifies the  total number of lanes in each direction. From 1-32 lanes are supported."
  add_display_item "Options" lanes parameter
  
  
  #     # adding bonded_group_size aka bonded mode type
  add_parameter gui_bonding_enable boolean false
  set_parameter_property gui_bonding_enable DEFAULT_VALUE false
  set_parameter_property gui_bonding_enable DISPLAY_NAME "Enable lane bonding"
  set_parameter_property gui_bonding_enable HDL_PARAMETER false
  set_parameter_property gui_bonding_enable DESCRIPTION "Bond all lanes when enabled"
  add_display_item "Options" gui_bonding_enable parameter
  
  add_parameter bonded_group_size INTEGER 1
  set_parameter_property bonded_group_size DEFAULT_VALUE 1
  set_parameter_property bonded_group_size VISIBLE false
  set_parameter_property bonded_group_size DERIVED true
  set_parameter_property bonded_group_size HDL_PARAMETER true

  add_parameter gui_bonded_mode STRING "xN"
  set_parameter_property gui_bonded_mode DEFAULT_VALUE "xN"
  set_parameter_property gui_bonded_mode ALLOWED_RANGES {"xN" "fb_compensation"}
  set_parameter_property gui_bonded_mode VISIBLE true
  set_parameter_property gui_bonded_mode DERIVED false
  set_parameter_property gui_bonded_mode HDL_PARAMETER false
  set_parameter_property gui_bonded_mode DISPLAY_NAME "Bonding mode"
  set_parameter_update_callback gui_bonded_mode validate_pma_bonding_mode
  add_display_item "Options" gui_bonded_mode parameter
  

  add_parameter bonded_mode STRING "xN"
  set_parameter_property bonded_mode DEFAULT_VALUE "xN"
  set_parameter_property bonded_mode VISIBLE false
  set_parameter_property bonded_mode DERIVED true
  set_parameter_property bonded_mode HDL_PARAMETER true
  
  add_parameter gui_pma_bonding_mode STRING "x1"
  set_parameter_property gui_pma_bonding_mode DEFAULT_VALUE "x1"
  set_parameter_property gui_pma_bonding_mode ALLOWED_RANGES {"x1" "xN"}
  set_parameter_property gui_pma_bonding_mode VISIBLE true
  set_parameter_property gui_pma_bonding_mode DERIVED false
  set_parameter_property gui_pma_bonding_mode HDL_PARAMETER false
  set_parameter_property gui_pma_bonding_mode DISPLAY_NAME "PMA bonding mode"
  set_parameter_property gui_pma_bonding_mode DESCRIPTION "Bond all TX PMA lanes when enabled"
  add_display_item "Options" gui_pma_bonding_mode parameter
  
  add_parameter pma_bonding_mode STRING "x1"
  set_parameter_property pma_bonding_mode DEFAULT_VALUE "x1"
  set_parameter_property pma_bonding_mode VISIBLE false
  set_parameter_property pma_bonding_mode DERIVED true
  set_parameter_property pma_bonding_mode HDL_PARAMETER true
    
  #     # adding deserialization factor
  add_parameter gui_deser_factor INTEGER 8
  set_parameter_property gui_deser_factor DEFAULT_VALUE 8
  set_parameter_property gui_deser_factor ALLOWED_RANGES {8 10 16 20 32 40}
  set_parameter_property gui_deser_factor DISPLAY_NAME "FPGA fabric transceiver interface width"
  set_parameter_property gui_deser_factor HDL_PARAMETER false
  set_parameter_property gui_deser_factor DESCRIPTION "Specifies the channel width"
  add_display_item "Options" gui_deser_factor parameter
  
  #     # PCS-PMA Interface Width
  add_parameter gui_pcs_pma_width STRING PARAM_DEFAULT
  set_parameter_property gui_pcs_pma_width DEFAULT_VALUE PARAM_DEFAULT
  set_parameter_property gui_pcs_pma_width DISPLAY_NAME "PCS-PMA Interface Width"
  set_parameter_property gui_pcs_pma_width HDL_PARAMETER false
  set_parameter_property gui_pcs_pma_width DESCRIPTION "Specifies the PCS-PMA Interface width"
  add_display_item "Options" gui_pcs_pma_width parameter
  
  add_parameter pcs_pma_width INTEGER 8
  set_parameter_property pcs_pma_width DEFAULT_VALUE 8
  set_parameter_property pcs_pma_width VISIBLE false
  set_parameter_property pcs_pma_width DERIVED true
  set_parameter_property pcs_pma_width HDL_PARAMETER true
  
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
  set_parameter_property gui_pll_type DESCRIPTION "Specifies the PLL type"
  add_display_item "Options" gui_pll_type parameter
  
  # adding data rate parameter
  add_parameter data_rate STRING "1250 Mbps"
  set_parameter_property data_rate DEFAULT_VALUE "1250 Mbps"
  set_parameter_property data_rate DISPLAY_NAME "Data rate"
  set_parameter_property data_rate DESCRIPTION "Specifies the data rate in Mbps."
  set_parameter_property data_rate HDL_PARAMETER true
  add_display_item "Options" data_rate parameter

  add_parameter gui_base_data_rate STRING "1250 Mbps"
  set_parameter_property gui_base_data_rate DEFAULT_VALUE "1250 Mbps"
  set_parameter_property gui_base_data_rate DISPLAY_NAME "Base data rate"
  set_parameter_property gui_base_data_rate HDL_PARAMETER false
  set_parameter_property gui_base_data_rate DESCRIPTION "Specifies the base data rate for the TX PLL. Channels that require TX PLL merging must share the same base data rate."
  add_display_item "Options" gui_base_data_rate parameter

  add_parameter base_data_rate STRING "1250 Mbps"
  set_parameter_property base_data_rate DEFAULT_VALUE "1250 Mbps"
  set_parameter_property base_data_rate HDL_PARAMETER true
  set_parameter_property base_data_rate DERIVED true
  set_parameter_property base_data_rate VISIBLE false
  
  # adding pll input clock aka pll_refclk_freq parameter - GUI param is symbolic only
  add_parameter gui_pll_refclk_freq STRING "62.5 MHz"
  set_parameter_property gui_pll_refclk_freq DEFAULT_VALUE "62.5 MHz"
  set_parameter_property gui_pll_refclk_freq DISPLAY_NAME "Input clock frequency"
  set_parameter_property gui_pll_refclk_freq UNITS None
  set_parameter_property gui_pll_refclk_freq DISPLAY_HINT "include frequency or period unit"
  set_parameter_property gui_pll_refclk_freq HDL_PARAMETER false
  set_parameter_property gui_pll_refclk_freq DESCRIPTION "Specifies the input clock frequency"
  add_display_item "Options" gui_pll_refclk_freq parameter
 
  # adding ref-clk port for CDR for SyncE support - hidden in GUI
  # this is only to facilitate TSE 
  set DESCRIPTION "Enables SyncE support - expose seperate TX PLL ref-clock and CDR ref-clock"
  add_parameter en_synce_support INTEGER 0
  set_parameter_property en_synce_support  DEFAULT_VALUE 0
  set_parameter_property en_synce_support  DISPLAY_NAME "Enable SyncE support"
  set_parameter_property en_synce_support  HDL_PARAMETER true
  set_parameter_property en_synce_support  DISPLAY_HINT BOOLEAN
  set_parameter_property en_synce_support  DESCRIPTION $DESCRIPTION
  set_parameter_property en_synce_support  VISIBLE false
  add_display_item "Options" en_synce_support  parameter
  


  
  # Additional Options
  
  set DESCRIPTION "Enables TX bitslip when selected, creates the following ports: tx_bitslipboundaryselect, rx_bitslipboundaryselectout"
  add_string_parameter_as_boolean tx_bitslip_enable "false" {TX} "Enable TX Bitslip" $DESCRIPTION "Additional Options"
  
  # adding use rx_use_coreclk parameter
  set DESCRIPTION "Optional clock to drive the coreclk port of the RX PCS"
  add_string_parameter_as_boolean rx_use_coreclk "false" {RX} "Create rx_coreclkin port" $DESCRIPTION "Additional Options"
  
  # adding use tx_use_coreclk parameter
  set DESCRIPTION "Optional clock to drive the coreclk port of the TX PCS"
  add_string_parameter_as_boolean tx_use_coreclk "false" {TX} "Create tx_coreclkin port" $DESCRIPTION "Additional Options"

  # adding use rx_recovered_clk parameter
  set DESCRIPTION {Creates the optional port rx_recovered_clk output. 
                    This is the CRU clock from the PMA. This clock is not to be used
                    to clock the RX datapath. Use rx_clkout or rx_coreclkin for RX datapath
                    clocking. This clock is provided for cases like GIGE where
                    the clock can be used as a reference to lock an external clock source.}
  add_parameter gui_rx_use_recovered_clk boolean 0
  set_parameter_property gui_rx_use_recovered_clk DEFAULT_VALUE 0
  set_parameter_property gui_rx_use_recovered_clk DISPLAY_NAME "Create rx_recovered_clk port"
  set_parameter_property gui_rx_use_recovered_clk HDL_PARAMETER false
  set_parameter_property gui_rx_use_recovered_clk DISPLAY_HINT "Optional recovered CRU clock from the PMA"
  set_parameter_property gui_rx_use_recovered_clk DESCRIPTION $DESCRIPTION
  add_display_item "Additional Options" gui_rx_use_recovered_clk parameter
  
  # adding parameter to use additional status ports like syncstatus, etc...
  common_add_parameter gui_use_status boolean 0 {RX}
  set_parameter_property gui_use_status DEFAULT_VALUE 0
  set_parameter_property gui_use_status DISPLAY_NAME "Create optional ports"
  set_parameter_property gui_use_status HDL_PARAMETER false
  set_parameter_property gui_use_status DESCRIPTION "Creates the following ports: tx_forceelecidle, rx_is_lockedtoref, rx_is_lockedtodata, rx_signaldetect"
  add_display_item "Additional Options" gui_use_status parameter
  
  #     # 8b10b
  #     # adding 8b10b related parameters
  
  # add use_8b10b parameter
  add_string_parameter_as_boolean use_8b10b "false" {NoTag} "Enable 8B/10B encoder/decoder" "" "8B/10B"
  
  #     # add parameter to create dispval port, etc... for manual disparity control
  add_string_parameter_as_boolean use_8b10b_manual_control "false" {USE8B10B} "Enable manual disparity control" "" "8B/10B"
  
  # adding parameter to use additional status ports like rx_errdetect, etc...
  common_add_parameter gui_use_8b10b_status boolean 0 {USE8B10B_RX}
  set_parameter_property gui_use_8b10b_status DISPLAY_NAME "Create optional 8B10B status ports"
  set_parameter_property gui_use_8b10b_status HDL_PARAMETER false
  set_parameter_property gui_use_8b10b_status DESCRIPTION "Creates the following ports: rx_errdetect, rx_disperr"
  add_display_item "8B/10B" gui_use_8b10b_status parameter
  
  #     # Phase Compensation FIFO
  #     # adding Phase Compensation FIFO related parameters
	common_add_parameter std_tx_pcfifo_mode string "low_latency" {RX}
  	common_add_parameter std_rx_pcfifo_mode string "low_latency" {RX}
	set_parameter_property std_tx_pcfifo_mode DEFAULT_VALUE "low_latency"
	set_parameter_property std_rx_pcfifo_mode DEFAULT_VALUE "low_latency"
	set_parameter_property std_tx_pcfifo_mode DISPLAY_NAME "TX phase compensation FIFO"
	set_parameter_property std_rx_pcfifo_mode DISPLAY_NAME "RX phase compensation FIFO"
	set_parameter_property std_tx_pcfifo_mode ALLOWED_RANGES {"low_latency:Low latency mode" "register_fifo:Registered FIFO mode"}
	set_parameter_property std_rx_pcfifo_mode ALLOWED_RANGES {"low_latency:Low latency mode" "register_fifo:Registered FIFO mode"}
	set_parameter_property std_tx_pcfifo_mode HDL_PARAMETER true
	set_parameter_property std_rx_pcfifo_mode HDL_PARAMETER true
	set_parameter_property std_tx_pcfifo_mode VISIBLE false 
	set_parameter_property std_rx_pcfifo_mode VISIBLE false
	set_parameter_property std_tx_pcfifo_mode DESCRIPTION "Select the type of TX phase compensation FIFO mode in low latency mode or registered FIFO mode"
	set_parameter_property std_rx_pcfifo_mode DESCRIPTION "Select the type of RX phase compensation FIFO mode in low latency mode or registered FIFO mode"
	add_display_item "Phase Compensation FIFO" std_tx_pcfifo_mode parameter
	add_display_item "Phase Compensation FIFO" std_rx_pcfifo_mode parameter
	
  #     # Word Aligner
  
  # adding parameter for manual word alignment
  common_add_parameter word_aligner_mode string "manual" {RX}
  set_parameter_property word_aligner_mode DEFAULT_VALUE "manual"
  set_parameter_property word_aligner_mode DISPLAY_NAME "Word alignment mode"
  set_parameter_property word_aligner_mode ALLOWED_RANGES {"manual:Manual" "bitslip:Bit slipping" "sync_state_machine:Automatic synchronization state machine"}
  set_parameter_property word_aligner_mode HDL_PARAMETER true
  set_parameter_property word_aligner_mode DESCRIPTION "Select the type of word alignment mode. Choose Manual mode to enable word alignment by asserting the rx_enapatternalign using Avalon MM inteface, choose Bit slipping mode to enable word alignment by asserting the rx_bitslip using Avalon MM interface or choose Automatic synchronization state machine to control the word alignment using the programmable state machine."
  add_display_item "Word Aligner" word_aligner_mode parameter
  
  # adding state_machine_datacnt parameter for word aligner
  common_add_parameter word_aligner_state_machine_datacnt integer 1 {WaAutoSm}
  set_parameter_property word_aligner_state_machine_datacnt ALLOWED_RANGES 1:256
  set_parameter_property word_aligner_state_machine_datacnt DISPLAY_NAME "Number of consecutive valid words before sync state is reached"
  set_parameter_property word_aligner_state_machine_datacnt HDL_PARAMETER true
  #set_parameter_property word_aligner_state_machine_datacnt DESCRIPTION "Number of consecutive valid words needed to reduce the built up error count by 1, valid values are 1-256"
  add_display_item "Word Aligner" word_aligner_state_machine_datacnt parameter
  
  # adding state_machine_errcnt parameter for word aligner
  common_add_parameter word_aligner_state_machine_errcnt integer 1 {WaAutoSm}
  set_parameter_property word_aligner_state_machine_errcnt ALLOWED_RANGES 1:256
  set_parameter_property word_aligner_state_machine_errcnt DISPLAY_NAME "Number of bad data words before loss of sync state"
  set_parameter_property word_aligner_state_machine_errcnt HDL_PARAMETER true
  #set_parameter_property word_aligner_state_machine_errcnt DESCRIPTION "Number of bad data words required for alignment state machine to enter loss of sync state, valid values are 1-256"
  add_display_item "Word Aligner" word_aligner_state_machine_errcnt parameter
  
  # adding state_machine_patterncnt for word aligner
  common_add_parameter word_aligner_state_machine_patterncnt integer 10 {WaAutoSm}
  set_parameter_property word_aligner_state_machine_patterncnt ALLOWED_RANGES 1:256
  set_parameter_property word_aligner_state_machine_patterncnt DISPLAY_NAME "Number of valid patterns before sync state is reached"
  set_parameter_property word_aligner_state_machine_patterncnt HDL_PARAMETER true
  #set_parameter_property word_aligner_state_machine_patterncnt DESCRIPTION "Number of consecutive patterns required to achieve synchronization, valid values are 1-256"
  add_display_item "Word Aligner" word_aligner_state_machine_patterncnt parameter
  
  
  #     # adding parameter for word aligner pattern
  
  # adding parameter to use additional status ports like syncstatus, etc...
  common_add_parameter gui_use_wa_status boolean 0 {RX}
  set_parameter_property gui_use_wa_status DISPLAY_NAME "Create optional word aligner status ports"
  set_parameter_property gui_use_wa_status HDL_PARAMETER false
  set_parameter_property gui_use_wa_status DESCRIPTION "Creates the following ports: rx_syncstatus, rx_patterndetect"
  add_display_item "Word Aligner" gui_use_wa_status parameter
  
  # adding word aligner pattern length parameter
  common_add_parameter word_aligner_pattern_length integer 16 {WaStatus}
  set_parameter_property word_aligner_pattern_length DEFAULT_VALUE 16
  set_parameter_property word_aligner_pattern_length DISPLAY_NAME "Word aligner pattern length"
  set_parameter_property word_aligner_pattern_length DESCRIPTION "Specifies the pattern length to be matched by the word aligner."
  set_parameter_property word_aligner_pattern_length HDL_PARAMETER true
  add_display_item "Word Aligner" word_aligner_pattern_length parameter
  
  common_add_parameter word_align_pattern STRING "1111100111111111" {WaStatus}
  set_parameter_property word_align_pattern DEFAULT_VALUE "1111100111111111"
  set_parameter_property word_align_pattern DISPLAY_NAME "Word alignment pattern"
  set_parameter_property word_align_pattern DESCRIPTION "Specifies the pattern to be matched by the word aligner. The pattern is LSbit to MSbit."
  set_parameter_property word_align_pattern HDL_PARAMETER true
  add_display_item "Word Aligner" word_align_pattern parameter
  
  #     # adding parameter for enable run_length checking
  common_add_parameter gui_enable_run_length boolean 0 {RX}
  set_parameter_property gui_enable_run_length DEFAULT_VALUE 0
  set_parameter_property gui_enable_run_length DISPLAY_NAME "Enable run length violation checking"
  set_parameter_property gui_enable_run_length HDL_PARAMETER false
  set_parameter_property gui_enable_run_length DESCRIPTION "Enables the rx_rlv status port which is asserted when the number of 1s or 0s in the data stream exceeds the programmed run length violation threshold"
  add_display_item "Word Aligner" gui_enable_run_length parameter
  
  add_parameter run_length_violation_checking INTEGER 40
  set_parameter_property run_length_violation_checking DEFAULT_VALUE 40
  set_parameter_property run_length_violation_checking DISPLAY_NAME "Run length"
  set_parameter_property run_length_violation_checking HDL_PARAMETER true
  set_parameter_property run_length_violation_checking DESCRIPTION "Specifies the threshold for a run-length violation"
  add_display_item "Word Aligner" run_length_violation_checking parameter
  
  #     # Rate Match FIFO
  
  # adding parameter to enable the use rate match fifo
  common_add_parameter use_rate_match_fifo integer 0 {RX}
  set_parameter_property use_rate_match_fifo DEFAULT_VALUE 0
  set_parameter_property use_rate_match_fifo DISPLAY_NAME "Enable rate match FIFO"
  set_parameter_property use_rate_match_fifo DISPLAY_HINT boolean
  set_parameter_property use_rate_match_fifo HDL_PARAMETER true
  add_display_item "Rate Match" use_rate_match_fifo parameter
  
  # adding parameter for pattern1 of rate match FIFO
  common_add_parameter rate_match_pattern1 STRING "11010000111010000011" {RmFIFO}
  set_parameter_property rate_match_pattern1 DEFAULT_VALUE "11010000111010000011"
  set_parameter_property rate_match_pattern1 DISPLAY_NAME "Rate match insertion/deletion +ve disparity pattern"
  set_parameter_property rate_match_pattern1 HDL_PARAMETER true
  set_parameter_property rate_match_pattern1 DESCRIPTION "Specifies a 10-bit skip pattern and a 10-bit control pattern"
  add_display_item "Rate Match" rate_match_pattern1 parameter
  
  # adding parameter for pattern2 of rate match FIFO
  common_add_parameter rate_match_pattern2 STRING "00101111000101111100" {RmFIFO}
  set_parameter_property rate_match_pattern2 DEFAULT_VALUE  "00101111000101111100"
  set_parameter_property rate_match_pattern2 DISPLAY_NAME "Rate match insertion/deletion -ve disparity pattern"
  set_parameter_property rate_match_pattern2 HDL_PARAMETER true
  set_parameter_property rate_match_pattern2 DESCRIPTION "Specifies a 10-bit skip pattern and a 10-bit control pattern"
  add_display_item "Rate Match" rate_match_pattern2 parameter
  
  # adding parameter to use additional status ports like rx_rmfifodatadeleted
  common_add_parameter gui_use_rmfifo_status boolean 0 RmFIFO
  set_parameter_property gui_use_rmfifo_status DISPLAY_NAME "Create optional Rate Match FIFO status ports"
  set_parameter_property gui_use_rmfifo_status HDL_PARAMETER false
  set_parameter_property gui_use_rmfifo_status DESCRIPTION "Creates the following ports: rx_rmfifodatainserted, rx_rmfifodatadeleted"
  add_display_item "Rate Match" gui_use_rmfifo_status parameter
  
  #     # Byte order
  #     # adding parameters to use byte-order mode
  
  add_parameter byte_order_mode STRING  "none"
  set_parameter_property byte_order_mode DEFAULT_VALUE "none"
  set_parameter_property byte_order_mode DERIVED true
  set_parameter_property byte_order_mode ALLOWED_RANGES {"none" "sync state machine" "PLD control"}
  set_parameter_property byte_order_mode VISIBLE false
  set_parameter_property byte_order_mode HDL_PARAMETER true
  
  # adding option to enable byte_order_block
  common_add_parameter gui_use_byte_order_block boolean 0 {RX}
  set_parameter_property gui_use_byte_order_block DEFAULT_VALUE 0
  set_parameter_property gui_use_byte_order_block DISPLAY_NAME "Enable byte ordering block"
  set_parameter_property gui_use_byte_order_block HDL_PARAMETER false
  set_parameter_property gui_use_byte_order_block DESCRIPTION "select this option if the byte deserializer is used"
  add_display_item "Byte Order" gui_use_byte_order_block parameter
  
  # adding option to enable pld_control_enable
  common_add_parameter gui_byte_order_pld_ctrl_enable boolean 0 {RX}
  set_parameter_property gui_byte_order_pld_ctrl_enable DEFAULT_VALUE 0
  set_parameter_property gui_byte_order_pld_ctrl_enable DISPLAY_NAME "Enable byte ordering block manual control"
  set_parameter_property gui_byte_order_pld_ctrl_enable HDL_PARAMETER false
  add_display_item "Byte Order" gui_byte_order_pld_ctrl_enable parameter
  
  # adding byte_order_pattern parameter
  common_add_parameter byte_order_pattern STRING "111111011" {ByteOrder}
  set_parameter_property byte_order_pattern DEFAULT_VALUE "111111011"
  set_parameter_property byte_order_pattern DISPLAY_NAME "Byte ordering pattern"
  set_parameter_property byte_order_pattern HDL_PARAMETER true
  set_parameter_property byte_order_pattern DESCRIPTION "Specifies the pattern that identifies the SOP"
  add_display_item "Byte Order" byte_order_pattern parameter
  
  # adding byte_order_pad_pattern parameter
  common_add_parameter byte_order_pad_pattern STRING "000000000" {ByteOrder}
  set_parameter_property byte_order_pad_pattern DEFAULT_VALUE "000000000"
  set_parameter_property byte_order_pad_pattern DISPLAY_NAME "Byte ordering pad pattern"
  set_parameter_property byte_order_pad_pattern HDL_PARAMETER true
  set_parameter_property byte_order_pad_pattern DESCRIPTION "Specifies the pad pattern that is inserted to align the SOP"
  add_display_item "Byte Order" byte_order_pad_pattern parameter
  
  # SW/DW path selection
  set description "The desired width of the data interface between the deserializer and the PCS. 'Single' for an 8 or 10 bits. 'Double' for a 16 or 20 bits."
  add_parameter use_double_data_mode string "DEPRECATED"
  set_parameter_property use_double_data_mode DEFAULT_VALUE "DEPRECATED"
  set_parameter_property use_double_data_mode DERIVED false
  set_parameter_property use_double_data_mode VISIBLE false
  set_parameter_property use_double_data_mode HDL_PARAMETER false
  set_parameter_property use_double_data_mode DESCRIPTION $description
  
  # Hidden parameter for 0ppm phfifo
  add_parameter coreclk_0ppm_enable string "false"
  set_parameter_property coreclk_0ppm_enable DEFAULT_VALUE "false"
  set_parameter_property coreclk_0ppm_enable VISIBLE false
  set_parameter_property coreclk_0ppm_enable ALLOWED_RANGES {"false" "true"}
  set_parameter_property coreclk_0ppm_enable HDL_PARAMETER true
  
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
  
  add_parameter pll_external_enable INTEGER
  set_parameter_property pll_external_enable VISIBLE false
  set_parameter_property pll_external_enable DEFAULT_VALUE 0
  set_parameter_property pll_external_enable HDL_PARAMETER true
  set_parameter_property pll_external_enable ENABLED true
}


# +---------------------------------------------------------------------------
# | Parameters that appear in levels with a management interface
# | 
proc add_mgmt_parameters {} {

	add_parameter mgmt_clk_in_mhz INTEGER
	set_parameter_property mgmt_clk_in_mhz DERIVED true
	set_parameter_property mgmt_clk_in_mhz DEFAULT_VALUE 250
	set_parameter_property mgmt_clk_in_mhz VISIBLE false
	set_parameter_property mgmt_clk_in_mhz HDL_PARAMETER true

	add_parameter gui_mgmt_clk_in_hz LONG 250000000
	set_parameter_property gui_mgmt_clk_in_hz SYSTEM_INFO {CLOCK_RATE mgmt_clk}
	set_parameter_property gui_mgmt_clk_in_hz VISIBLE false
	set_parameter_property gui_mgmt_clk_in_hz HDL_PARAMETER false

	# data streams and recovered clock buses can be split into multiple interfaces
	# or left as a wide bus for direct-HDL use
	add_parameter gui_split_interfaces INTEGER
	set_parameter_property gui_split_interfaces DEFAULT_VALUE 0
	set_parameter_property gui_split_interfaces DISPLAY_NAME "Enable avalon data interfaces and bit reversal"
	set_parameter_property gui_split_interfaces VISIBLE true	;# normally disabled
	set_parameter_property gui_split_interfaces DISPLAY_HINT "boolean"
	set_parameter_property gui_split_interfaces DESCRIPTION "When enabled, the parallel data interfaces to the PHY will be split by channel and will be created as Avalon-ST interfaces as opposed to conduit interfaces. This option also causes the bits within each parallel interface to be presented in reverse order."
	set_parameter_property gui_split_interfaces HDL_PARAMETER false
	add_display_item "Additional Options" gui_split_interfaces parameter


  # UI parameter for enabling / disabling embedded reset controller
  set DESCRIPTION "Enables the embedded reset controller. When disabled, the reset control ports (pll_powerdown, tx_digitalreset, rx_analogreset, and rx_digitalreset) will be exposed \
                    for manual control."
  add_parameter gui_embedded_reset INTEGER 1
  set_parameter_property gui_embedded_reset DEFAULT_VALUE 1
  set_parameter_property gui_embedded_reset VISIBLE true
  set_parameter_property gui_embedded_reset HDL_PARAMETER false
  set_parameter_property gui_embedded_reset DESCRIPTION $DESCRIPTION
  set_parameter_property gui_embedded_reset DISPLAY_NAME "Enabled embedded reset controller"
  set_parameter_property gui_embedded_reset DISPLAY_HINT BOOLEAN
	add_display_item "Additional Options" gui_embedded_reset parameter

  # Derived HDL parameter for enabling / disabling embedded reset controller
  add_parameter embedded_reset INTEGER 1
  set_parameter_property embedded_reset DEFAULT_VALUE 1
  set_parameter_property embedded_reset VISIBLE false
  set_parameter_property embedded_reset HDL_PARAMETER true
  set_parameter_property embedded_reset DERIVED true
	add_display_item "Additional Options" embedded_reset parameter
	
  # Derived HDL parameter for enabling / disabling embedded reset controller
  add_parameter channel_interface INTEGER 0
  set_parameter_property channel_interface DEFAULT_VALUE 0
  set_parameter_property channel_interface DISPLAY_NAME "Enable Channel Interface"
  set_parameter_property channel_interface DISPLAY_HINT boolean
  set_parameter_property channel_interface HDL_PARAMETER true
  set_parameter_property channel_interface DESCRIPTION "Enables channel interface reconfiguration."
  add_display_item "Channel Interface" channel_interface parameter
  
  add_parameter manual_reset STRING "DEPRECATED"
  set_parameter_property manual_reset DEFAULT_VALUE "DEPRECATED"
  set_parameter_property manual_reset VISIBLE false
	set_parameter_property manual_reset HDL_PARAMETER false
	set_parameter_property manual_reset DERIVED true
	set_parameter_property manual_reset DESCRIPTION "This parameter has been deprecated."
}

proc add_device_parameters {} {

	#adding device_family from SYSTEM INFO
	add_parameter device_family STRING 
	set_parameter_property device_family SYSTEM_INFO {DEVICE_FAMILY}
	set_parameter_property device_family DISPLAY_NAME "Device family"
	set_parameter_property device_family ENABLED false
	set_parameter_property device_family DESCRIPTION "Specifies the Altera FPGA device family."
	set_parameter_property device_family HDL_PARAMETER true
	add_display_item "Options" device_family parameter
	
	set fams [::alt_xcvr::utils::device::list_s4_style_hssi_families]
	set fams [concat $fams [::alt_xcvr::utils::device::list_s5_style_hssi_families] ]
	set fams [concat $fams [::alt_xcvr::utils::device::list_a5_style_hssi_families] ]
	set fams [concat $fams [::alt_xcvr::utils::device::list_c5_style_hssi_families] ]
	send_message info "set_parameter_property device_family ALLOWED_RANGES $fams"

#add_parameter device_type STRING "GX"
#set_parameter_property device_type DEFAULT_VALUE "GX"
#set_parameter_property device_type DISPLAY_NAME "Which device variation will you be using?"
#set_parameter_property device_type ALLOWED_RANGES {"GX" "GT"}
#set_parameter_property device_type HDL_PARAMETER false
#add_display_item "Options" device_type parameter 
}

proc add_pll_reconfig_parameters {group} {
  set max_plls 4
  set max_refclks 5

  if { [::alt_xcvr::gui::pll_reconfig::initialize $group $max_plls $max_refclks 1] == 0} {
    puts "Error, could not initialize pll_reconfig package"
  }
}

