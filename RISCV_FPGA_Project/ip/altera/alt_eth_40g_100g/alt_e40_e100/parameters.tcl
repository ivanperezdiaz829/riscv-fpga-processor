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


package provide alt_e40_e100::parameters 13.0

package require alt_xcvr::ip_tcl::ip_module
package require alt_xcvr::ip_tcl::messages
package require alt_xcvr::utils::common
package require alt_xcvr::utils::device


namespace eval ::alt_e40_e100::parameters:: {
  namespace import ::alt_xcvr::ip_tcl::ip_module::*
  namespace import ::alt_xcvr::ip_tcl::messages::*

  namespace export \
    declare_parameters \
    validate

  variable package_name
  variable val_prefix
  variable display_items
  variable parameters

  set package_name "alt_e40_e100::parameters"

  set display_items {\
    {NAME                        GROUP                                  TYPE                         ARGS                   VISIBLE      }\
    {"Main"                      ""                                     GROUP                        tab                     true     }\
    {"40GBASE-KR4"               ""                                     GROUP                        tab                     true     }\
    {"General Options"           "Main"                                 GROUP                        NOVAL                   true     }\
    {"PHY Configuration Options" "Main"                                 GROUP                        NOVAL                   true     }\
	{"Advanced Design Options"   "Main"                                 GROUP                        NOVAL                   true     }\
    {"KR4 General Options"       "40GBASE-KR4"                          GROUP                        NOVAL                   true     }\
    {"Auto-Negotiation"          "40GBASE-KR4"                          GROUP                        NOVAL                   true     }\
    {"Link Training"             "40GBASE-KR4"                          GROUP                        NOVAL                   true     }\
    {"FEC Options"               "40GBASE-KR4"                          GROUP                        NOVAL                   true     }\
    {"PMA parameters"            "Link Training"                        GROUP                        NOVAL                   true     }\
  }
    
  set parameters {\
    {NAME                                    DERIVED HDL_PARAMETER TYPE     DEFAULT_VALUE            ALLOWED_RANGES                                          ENABLED         VISIBLE DISPLAY_HINT                DISPLAY_UNITS                           DISPLAY_ITEM                 DISPLAY_NAME                                VALIDATION_CALLBACK                                 UNITS                             DESCRIPTION }\
    
	{DEVICE_FAMILY                           false   true          STRING   NOVAL                    {"Stratix IV" "Stratix V" "Arria V GZ" "Arria 10"}      false           true    "Device Family"             NOVAL                                   "General Options"            "Device family"                             ::alt_e40_e100::parameters::validate_DEVICE_FAMILY  NOVAL                             "Only Stratix IV, Stratix V, Arria V GZ and Arria 10 devices are supported"}\
	{MAC_CONFIG                              false   false         STRING   "100 Gbe"                {"100 Gbe:100 GbE" "40 Gbe:40 GbE"}                     true            true    NOVAL                       NOVAL                                   "General Options"            "MAC configuration"                         ::alt_e40_e100::parameters::validate_MAC_CONFIG     NOVAL                             "Select MAC datapath width"}\
	{CORE_OPTION                             false   false         STRING   "MAC & PHY"              {"MAC & PHY:MAC & PHY" "PHY only:PHY" "MAC only:MAC"}   true            true    "Core Options"              NOVAL                                   "General Options"            "Core options"                              ::alt_e40_e100::parameters::validate_CORE_OPTION    NOVAL                             "Select core components, PHY or MAC or MAC & PHY"}\
	{PHY_CONFIG                              false   false         INTEGER  1                        {"1:100 Gbps (10x10)" "2:CAUI-4 (4x25)"}                true            true    NOVAL                       NOVAL                                   "General Options"            "PHY configuration"                         ::alt_e40_e100::parameters::validate_PHY_CONFIG     NOVAL                             "Select Ethernet speed and lane configuration. CAUI-4 requires a Stratix V GT Device"}\
	{INTERFACE                               false   false         STRING   "Avalon-ST Interface"    {"Avalon-ST Interface" "Custom-ST Interface"}           true            true    "MAC Client Interface"      NOVAL                                   "General Options"            "MAC client interface"                      ::alt_e40_e100::parameters::validate_INTERFACE      NOVAL                             "Choose Avalon-compiant or narrower custom MAC interface"}\
	{VARIANT                                 false   true          INTEGER  3                        {"3:Full Duplex" "1:RX" "2:TX" }                        true            true    "Duplex Mode"               NOVAL                                   "General Options"            "Duplex mode"                               ::alt_e40_e100::parameters::validate_VARIANT         NOVAL                             "Select datapath mode to generate: TX, RX or Full Duplex"}\
	
	
	{PHY_PLL                                 false   true          STRING   "ATX"                    {"ATX" "CMU"}                                           true            true    "PHY PLL TYPE"              NOVAL                                   "PHY Configuration Options"  "PHY PLL type"                             ::alt_e40_e100::parameters::validate_PHY_PLL                                                NOVAL                             "PHY PLL configuration"}\
	{PHY_REFCLK                              false   false         INTEGER  1                        {1:644.53125 2:322.265625}                              true            true    NOVAL                       NOVAL                                   "PHY Configuration Options"  "PHY reference frequency"                  ::alt_e40_e100::parameters::validate_PHY_REFCLK                                               Megahertz                         "PHY clk_ref reference frequency"}\
	{REF_CLK_FREQ                            true    true          STRING   "644.53125 MHz"          {"644.53125 MHz" "322.265625 MHz"}                      true            false   NOVAL                       NOVAL                                   "PHY Configuration Options"  "PHY reference frequency"                  ::alt_e40_e100::parameters::validate_PHY_REFCLK                                               Megahertz                         "PHY clk_ref reference frequency"}\
	{STATUS_CLK_KHZ_SIV                      false   false         FLOAT    50.0                     {37.5:50.0}                                             true            false   NOVAL                       "MHz (Accepted range: 37.5-50.0 MHz)"   "Advanced Design Options"    "Status clock rate"                         ::alt_e40_e100::parameters::validate_status_clk                                               NOVAL                             "Clock rate of clk_status in MHz"}\
	{STATUS_CLK_KHZ_SV                       false   false         FLOAT    100.0                    {100.0:125.0}                                           true            true    NOVAL                       "MHz (Accepted range: 100.0-125.0 MHz)" "Advanced Design Options"    "Status clock rate"                         ::alt_e40_e100::parameters::validate_status_clk                                               NOVAL                             "Clock rate of clk_status in MHz"}\
	{ENABLE_STATISTICS_CNTR                  false   true          INTEGER  1                        NOVAL                                                   true            true    BOOLEAN                      NOVAL                                   "Advanced Design Options"    "Statistics counters"                ::alt_e40_e100::parameters::validate_ENABLE_STATISTICS_CNTR                                               NOVAL                             "Enable or disable built-in statistics counters"}\
	{ENABLE_STATISTICS_CNTR_OFF              true    false         INTEGER  0                        NOVAL                                                   false           false   BOOLEAN                     NOVAL                                   "Advanced Design Options"    "Statistics counters"                ::alt_e40_e100::parameters::validate_ENABLE_STATISTICS_CNTR                                                NOVAL                             "Enable or disable built-in statistics counters"}\
	{en_synce_support                        false   true          INTEGER  0                        NOVAL                                                   true            true    BOOLEAN                     NOVAL                                   "Advanced Design Options"    "Enable SyncE support"                   ::alt_e40_e100::parameters::validate_ENABLE_SYNCE_SUPPORT                                               NOVAL                             "Enable or disable SyncE support"}\
	{en_synce_support_off                    true    false         INTEGER  0                        NOVAL                                                   false           false   BOOLEAN                     NOVAL                                   "Advanced Design Options"    "Enable SyncE support"                   ::alt_e40_e100::parameters::validate_ENABLE_SYNCE_SUPPORT                                               NOVAL                             "Enable or disable SyncE support"}\
	
	{HAS_ADAPTERS                            true    true          INTEGER  1                        NOVAL                                                   false           false   NOVAL                       NOVAL                                   NOVAL                        NOVAL                                       NOVAL                                               NOVAL                             NOVAL}\
	{MAC_ONLY_IF                             true    false         INTEGER  0                        NOVAL                                                   false           false   NOVAL                       NOVAL                                   NOVAL                        NOVAL                                       NOVAL                                               NOVAL                             NOVAL}\
	{PHY_ONLY_IF                             true    false         INTEGER  0                        NOVAL                                                   false           false   NOVAL                       NOVAL                                   NOVAL                        NOVAL                                       NOVAL                                               NOVAL                             NOVAL}\
	{RX_ONLY_IF                              true    false         INTEGER  0                        NOVAL                                                   false           false   NOVAL                       NOVAL                                   NOVAL                        NOVAL                                       NOVAL                                               NOVAL                             NOVAL}\
	{TX_ONLY_IF                              true    false         INTEGER  0                        NOVAL                                                   false           false   NOVAL                       NOVAL                                   NOVAL                        NOVAL                                       NOVAL                                               NOVAL                             NOVAL}\
	{FULL_DUP_IF                             true    false         INTEGER  0                        NOVAL                                                   false           false   NOVAL                       NOVAL                                   NOVAL                        NOVAL                                       NOVAL                                               NOVAL                             NOVAL}\
	{NIGHT_FURY_IF                           true    false         INTEGER  0                        NOVAL                                                   false           false   NOVAL                       NOVAL                                   NOVAL                        NOVAL                                       NOVAL                                               NOVAL                             NOVAL}\
	{IS_CAUI4                                true    true          INTEGER  0                        NOVAL                                                   false           false   NOVAL                       NOVAL                                   NOVAL                        NOVAL                                       NOVAL                                               NOVAL                             NOVAL}\
	{TO_XCVR_WIDTH                           true    true          INTEGER  1                        NOVAL                                                   false           false   NOVAL                       NOVAL                                   NOVAL                        NOVAL                                       NOVAL                                               NOVAL                             NOVAL}\
	{FROM_XCVR_WIDTH                           true    true          INTEGER  1                        NOVAL                                                   false           false   NOVAL                       NOVAL                                   NOVAL                        NOVAL                                       NOVAL                                               NOVAL                             NOVAL}\
	
	{IS_40G                                  true    false          INTEGER  0                        NOVAL                                                   false           false   NOVAL                       NOVAL                                   NOVAL                        NOVAL                                       NOVAL                                               NOVAL                             NOVAL}\
	
	{STRATIX_IV_IF                           true    false         INTEGER  0                        NOVAL                                                   false           false   NOVAL                       NOVAL                                   NOVAL                        NOVAL                                       NOVAL                                               NOVAL                             NOVAL}\
	{FAST_SIMULATION                         true    true          INTEGER  0                  NOVAL                                                   false           false   NOVAL                       NOVAL                                   NOVAL                        NOVAL                                       NOVAL                                               NOVAL                             NOVAL}\
	{STATUS_CLK_KHZ                          true    true          integer  100000                   NOVAL                                                   false           false   NOVAL                       NOVAL                                   NOVAL                        NOVAL                                       ::alt_e40_e100::parameters::validate_STATUS_CLK_KHZ                                               NOVAL                             NOVAL}\
	{HAS_MAC                                 true    true          INTEGER  0                        NOVAL                                                   false           false   NOVAL                       NOVAL                                   NOVAL                        NOVAL                                       NOVAL                                               NOVAL                             NOVAL}\
	{HAS_PHY                                 true    true          INTEGER  0                        NOVAL                                                   false           false   NOVAL                       NOVAL                                   NOVAL                        NOVAL                                       NOVAL                                               NOVAL                             NOVAL}\
	
	{ENA_KR4_gui                             false   false         INTEGER  0                       NOVAL                                                    false                       true    BOOLEAN                     NOVAL                                   "KR4 General Options"        "Enable KR4"                                             ::alt_e40_e100::parameters::validate_ENA_KR4                   NOVAL      "Enable 40GBASE-KR4 PMA, for AN, LT, FEC functionality"}\
	{ENA_KR4_OFF                             true    false         INTEGER  0                       NOVAL                                                    false                       false   BOOLEAN                     NOVAL                                   "KR4 General Options"        "Enable KR4"                                             ::alt_e40_e100::parameters::validate_ENA_KR4                   NOVAL      "Enable 40GBASE-KR4 PMA, for AN, LT, FEC functionality"}\
	{ENA_KR4                                 true    true          INTEGER  0                       NOVAL                                                    false                       false   BOOLEAN                     NOVAL                                   NOVAL                        NOVAL                                                    ::alt_e40_e100::parameters::validate_ENA_KR4                   NOVAL      NOVAL}\
	
	{SYNTH_SEQ                               false   true          INTEGER  1                       NOVAL                                                    "ENA_KR4"                   true    boolean                     NOVAL                                   "KR4 General Options"        "Enable KR4 Reconfiguration"                             NOVAL                                                          NOVAL      "This module controls the link-up sequence for reconfiguration into and out of the AN, LT and data modes of the 40GBASE-KR4 PHY IP Core. The interface to the Reconfiguration Design Example transmits reconfiguration requests."}\
	{SYNTH_FEC                               false   true          INTEGER  0                       NOVAL                                                    "ENA_KR4"                   true    boolean                     NOVAL                                   "FEC Options"                "Include FEC sublayer"                                   NOVAL                                                          NOVAL      "This will include FEC logic for Backplane -Clause 74 implementation. Applicable only for 10G in Backplane mode."}\
	{SYNTH_AN_gui                            false   false         INTEGER  1                       NOVAL                                                    "SYNTH_SEQ && ENA_KR4"      true    boolean                     NOVAL                                   "Auto-Negotiation"           "Enable Auto-Negotiation"                                NOVAL                                                          NOVAL      "This will include Auto-Negotiatiation for Backplane -Clause 73 implementation."}\
	{SYNTH_AN                                true    true          INTEGER  1                       NOVAL                                                    "SYNTH_SEQ && ENA_KR4"      false   boolean                     NOVAL                                   "Auto-Negotiation"           "Enable Auto-Negotiation"                                ::alt_e40_e100::parameters::validate_synth_an                  NOVAL      "This will include Auto-Negotiatiation for Backplane -Clause 73 implementation."}\
	{SYNTH_LT_gui                            false   false         INTEGER  1                       NOVAL                                                    "SYNTH_SEQ && ENA_KR4"      true    boolean                     NOVAL                                   "Link Training"              "Enable Link Training"                                   NOVAL                                                          NOVAL      "When you turn this option On, the core includes the link training module which allows the remote link-partner TX PMD for the lowest Bit Error Rate (BER). LT is defined in Clause 72 of IEEE Std 802.3ap-2007."}\
	{SYNTH_LT                                true    true          INTEGER  1                       NOVAL                                                    "SYNTH_SEQ && ENA_KR4"      false   boolean                     NOVAL                                   "Link Training"              "Enable Link Training"                                   ::alt_e40_e100::parameters::validate_synth_lt                  NOVAL      "When you turn this option On, the core includes the link training module which allows the remote link-partner TX PMD for the lowest Bit Error Rate (BER). LT is defined in Clause 72 of IEEE Std 802.3ap-2007."}\
	{LINK_TIMER_KR                           false   true          INTEGER  504                     NOVAL                                                    "SYNTH_SEQ && ENA_KR4"      true    "columns:10"                ms                                      "Auto-Negotiation"           "Link fail inhibit time for 40Gb Ethernet"               ::alt_e40_e100::parameters::validate_time_kr                   NOVAL      "Timer for qualifying a link_status=FAIL indication or a link_status=OK indication when a specific technology link is first being established."}\
	
	{OPTIONAL_UP                             false   false         INTEGER  0                       NOVAL                                                    "SYNTH_LT && ENA_KR4"       true    boolean                     NOVAL                                   "Link Training"              "Enable microprocessor interface"                        NOVAL                                                          NOVAL      "When you turn this option On, the core includes a microprocessor interface which enables the microprocessor mode for link training."}\
	{OPTIONAL_RXEQ                           false   true          INTEGER  0                       NOVAL                                                    "SYNTH_LT && ENA_KR4"       true    boolean                     NOVAL                                   "Link Training"              "Enable RX equalization"                                 NOVAL                                                          NOVAL      "Turning this option on, will allow the link training algorithm to adjust the RX Equalization via dfe_xxx and ctle_xxx ports on the PHY."}\
	{BERWIDTH_gui                            false   false         INTEGER  4095                    {15 31 63 127 255 511 1023 2047 4095 8191 16384}         "SYNTH_LT && ENA_KR4"       true    NOVAL                       NOVAL                                   "Link Training"              "Maximum bit error count"                                NOVAL                                                          NOVAL      "Specifies the expected number of bit errors for the error counter expected during each step of the link training. If the number of errors exceeds this number for each step, the core returns an error. The number of errors depends upon the amount of time for each step and the quality of the physical link media."}\
	{BERWIDTH                                true    true          INTEGER  9                       NOVAL                                                    "SYNTH_LT && ENA_KR4"       false   NOVAL                       NOVAL                                   "Link Training"              "Bit error counter width"                                ::alt_e40_e100::parameters::calc_ber_ctr_width                 NOVAL      NOVAL}\
	{TRNWTWIDTH_gui                          false   false         INTEGER  127                     {127 255}                                                "SYNTH_LT && ENA_KR4"       true    NOVAL                       NOVAL                                   "Link Training"              "Number of frames to send before sending actual data"    NOVAL                                                          NOVAL      "This timer is started when local receiver is trained and detects that the remote receiver is ready to receive data. The local PMD will deliver wait_timer additional training frames to ensure that the link partner correctly detects the local receiver state."}\
	{TRNWTWIDTH                              true    true          INTEGER  NOVAL                   NOVAL                                                    "SYNTH_LT && ENA_KR4"       false   NOVAL                       NOVAL                                   "Link Training"              NOVAL                                                    ::alt_e40_e100::parameters::calc_trn_ctr_width                 NOVAL      NOVAL}\
	{MAINTAPWIDTH                            false   true          INTEGER  6                       NOVAL                                                    "SYNTH_LT && ENA_KR4"       false   "columns:10"                NOVAL                                   "Link Training"              NOVAL                                                    NOVAL                                                          NOVAL      "Width of the Main Tap control."}\
	{POSTTAPWIDTH                            false   true          INTEGER  5                       NOVAL                                                    "SYNTH_LT && ENA_KR4"       false   "columns:10"                NOVAL                                   "Link Training"              NOVAL                                                    NOVAL                                                          NOVAL      "Width of the Post Tap control."}\
	{PRETAPWIDTH                             false   true          INTEGER  4                       NOVAL                                                    "SYNTH_LT && ENA_KR4"       false   "columns:10"                NOVAL                                   "PMA parameters"             NOVAL                                                    NOVAL                                                          NOVAL      "Width of the Pre Tap control."}\
	{VMAXRULE                                false   true          INTEGER  60                      NOVAL                                                    "SYNTH_LT && ENA_KR4"       true    "columns:10"                NOVAL                                   "PMA parameters"             NOVAL                                                    ::alt_e40_e100::parameters::validate_vmaxrule                  NOVAL      "Specifies the maximum VOD. The default value is 60 which represents 1200 mV."}\
	{VMINRULE                                false   true          INTEGER  9                       NOVAL                                                    "SYNTH_LT && ENA_KR4"       true    "columns:10"                NOVAL                                   "PMA parameters"             NOVAL                                                    ::alt_e40_e100::parameters::validate_vminrule                  NOVAL      "Specifies the minimum VOD. The default value is 9 which represents 165 mV."}\
	{VODMINRULE                              false   true          INTEGER  24                      NOVAL                                                    "SYNTH_LT && ENA_KR4"       true    "columns:10"                NOVAL                                   "PMA parameters"             NOVAL                                                    ::alt_e40_e100::parameters::validate_vodrule                   NOVAL      "Specifies the minimum VOD for the first tap. The default value is 22 which represents 440mV."}\
	{VPOSTRULE                               false   true          INTEGER  31                      NOVAL                                                    "SYNTH_LT && ENA_KR4"       true    "columns:10"                NOVAL                                   "PMA parameters"             NOVAL                                                    ::alt_e40_e100::parameters::validate_vpostrule                 NOVAL      "Specifies the maximum value that the internal algorithm for pre-emphasis will ever test in determining the optimum post-tap setting. The default value is 25."}\
	{VPRERULE                                false   true          INTEGER  15                      NOVAL                                                    "SYNTH_LT && ENA_KR4"       true    "columns:10"                NOVAL                                   "PMA parameters"             NOVAL                                                    ::alt_e40_e100::parameters::validate_vprerule                  NOVAL      "Specifies the maximum value that the internal algorithm for pre-emphasis will ever test in determining the optimum pre-tap setting. The default value is 15."}\
	{PREMAINVAL                              false   true          INTEGER  60                      NOVAL                                                    "SYNTH_LT && ENA_KR4"       true    "columns:10"                NOVAL                                   "PMA parameters"             NOVAL                                                    ::alt_e40_e100::parameters::validate_premainrule               NOVAL      "Specifies the Preset VOD Value. Set by the Preset command as defined in Clause 72.6.10.2.3.1 of the link training protocol. This is the value from which the algorithm starts. The default value is 60.Preset Main tap value."}\
	{PREPOSTVAL                              false   true          INTEGER  0                       NOVAL                                                    "SYNTH_LT && ENA_KR4"       true    "columns:10"                NOVAL                                   "PMA parameters"             NOVAL                                                    NOVAL                                                          NOVAL      "Specifies the preset Post-tap value. The default value is 0."}\
	{PREPREVAL                               false   true          INTEGER  0                       NOVAL                                                    "SYNTH_LT && ENA_KR4"       true    "columns:10"                NOVAL                                   "PMA parameters"             NOVAL                                                    ::alt_e40_e100::parameters::validate_prepostrule               NOVAL      "Specifies the preset Pre-tap Value. The default value is 0."}\
	{INITMAINVAL                             false   true          INTEGER  52                      NOVAL                                                    "SYNTH_LT && ENA_KR4"       true    "columns:10"                NOVAL                                   "PMA parameters"             NOVAL                                                    ::alt_e40_e100::parameters::validate_initmainrule              NOVAL      "Specifies the Initial VOD Value. Set by the Initialize command in Clause 72.6.10.2.3.2 of the link training protocol. The default value is 35."}\
	{INITPOSTVAL                             false   true          INTEGER  30                      NOVAL                                                    "SYNTH_LT && ENA_KR4"       true    "columns:10"                NOVAL                                   "PMA parameters"             NOVAL                                                    NOVAL                                                          NOVAL      "Specifies the initial t Post-tap value. The default value is 14."}\
	{INITPREVAL                              false   true          INTEGER  5                       NOVAL                                                    "SYNTH_LT && ENA_KR4"       true    "columns:10"                NOVAL                                   "PMA parameters"             NOVAL                                                    ::alt_e40_e100::parameters::validate_initprepostrule           NOVAL      "Specifies the Initial Pre-tap Value. The default value is 3."}\
	
	{AN_GIGE                                 false   false         INTEGER  0                       NOVAL                                                    "SYNTH_AN && ENA_KR4"       false   boolean                     NOVAL                                   "Auto-Negotiation"           "1000 BASE-KX Technology Ability"                        NOVAL                                                          NOVAL      "Pause ability, depends upon MAC.  "}\
	{AN_XAUI                                 false   false         INTEGER  0                       NOVAL                                                    "SYNTH_AN && ENA_KR4"       false   boolean                     NOVAL                                   "Auto-Negotiation"           "10GBASE-KX4 Technology Ability"                         NOVAL                                                          NOVAL      "Pause ability, depends upon MAC.  "}\
	{AN_BASER                                false   false         INTEGER  0                       NOVAL                                                    "SYNTH_AN && ENA_KR4"       false   boolean                     NOVAL                                   "Auto-Negotiation"           "10GBASE-KR Technology Ability"                          NOVAL                                                          NOVAL      "Pause ability, depends upon MAC.  "}\
	{AN_40GBP                                false   false         INTEGER  1                       NOVAL                                                    "SYNTH_AN && ENA_KR4"       false   boolean                     NOVAL                                   "Auto-Negotiation"           "40GBASE-KR44 Technology Ability"                        NOVAL                                                          NOVAL      "Pause ability, depends upon MAC.  "}\
	{AN_40GCR                                false   false         INTEGER  0                       NOVAL                                                    "SYNTH_AN && ENA_KR4"       false   boolean                     NOVAL                                   "Auto-Negotiation"           "40GBASE-CR4 Technology Ability"                         NOVAL                                                          NOVAL      "Pause ability, depends upon MAC.  "}\
	{AN_100G                                 false   false         INTEGER  0                       NOVAL                                                    "SYNTH_AN && ENA_KR4"       false   boolean                     NOVAL                                   "Auto-Negotiation"           "100GBASE-CR10 Technology Ability"                       NOVAL                                                          NOVAL      "Pause ability, depends upon MAC.  "}\
	{AN_CHAN                                 false   true          INTEGER  1                       {"1:Lane 0" "2:Lane 1" "4:Lane 2" "8:Lane 3"}            "SYNTH_AN && ENA_KR4"       true    NOVAL                       NOVAL                                   "Auto-Negotiation"           "Auto-Negotiation Master"                                NOVAL                                                          NOVAL      "Selects which lane to perform auto-negotiation function on by default"}\
	{AN_PAUSE                                true    true          INTEGER  0                       NOVAL                                                    "SYNTH_AN && ENA_KR4"       false   "columns:10"                NOVAL                                   "Auto-Negotiation"           "Pause ability"                                          ::alt_e40_e100::parameters::validate_an_pause                  NOVAL      "Pause (C1:C0) is encoded in bits D11:D10 of base link codeword as per IEEE802.3 - 73.3.6."}\
	{AN_PAUSE_C0                             false   false         INTEGER  1                       NOVAL                                                    "SYNTH_AN && ENA_KR4"       true    boolean                     NOVAL                                   "Auto-Negotiation"           "Pause ability-C0"                                       NOVAL                                                          NOVAL      "C0 is same as PAUSE as defined in Annex 28B."}\
	{AN_PAUSE_C1                             false   false         INTEGER  1                       NOVAL                                                    "SYNTH_AN && ENA_KR4"       true    boolean                     NOVAL                                   "Auto-Negotiation"           "Pause ability-C1"                                       NOVAL                                                          NOVAL      "C1 is same asa ASM_DIR as defined in Annex 28B."}\
	{AN_TECH                                 true    true          INTEGER  8                       NOVAL                                                    "SYNTH_AN && ENA_KR4"       false   "columns:10"                NOVAL                                   "Auto-Negotiation"           NOVAL                                                    ::alt_e40_e100::parameters::validate_an_tech                   NOVAL      "Tech ability, only KR valid now // bit-0 = GigE, bit-1 = XAUI // bit-2 = 10G , bit-3 = 40G BP // bit 4 = 40G-CR4, bit 5 = 100G-CR10."}\
	{AN_FEC                                  true    true          INTEGER  3                       NOVAL                                                    "SYNTH_AN && ENA_KR4"       false   "columns:10"                NOVAL                                   "Auto-Negotiation"           "FEC Capability"                                         ::alt_e40_e100::parameters::validate_an_fec                    NOVAL      "FEC, bit1=request, bit0=ability."}\
	{AN_SELECTOR                             false   false         INTEGER  1                       NOVAL                                                    "SYNTH_AN && ENA_KR4"       false   NOVAL                       NOVAL                                   "Auto-Negotiation"           "Selector field"                                         NOVAL                                                          NOVAL      "AN selector field 802.3 = 5'd1."}\
	
	{CAPABLE_FEC                             false   false         INTEGER  1                       NOVAL                                                    "SYNTH_FEC && ENA_KR4"      true    boolean                     NOVAL                                   "FEC Options"                "Set FEC_ability bit on power up/reset"                  NOVAL                                                          NOVAL      "FEC ability bit power on value. This bit is defined in IEEE802.3ae - 45.2.1.84 register bit 1.170.0. Also referred in IEEE802.3ae - 73.6.5- F0"}\
	{ENABLE_FEC                              false   false         INTEGER  1                       NOVAL                                                    "SYNTH_FEC && ENA_KR4"      true    boolean                     NOVAL                                   "FEC Options"                "Set FEC_Enable bit on power up/reset"                   NOVAL                                                          NOVAL      "FEC enable bit power on value. This bit is defined in IEEE802.3ae - 45.2.1.85 register bit 1.171.0. Also referred in IEEE802.3ae - 73.6.5 as FEC requested bit-F1"}\
	{ERR_INDICATION                          false   true          INTEGER  1                       NOVAL                                                    "SYNTH_FEC && ENA_KR4"      true    boolean                     NOVAL                                   "FEC Options"                "Set FEC_Error_Indication_ability bit on power up/reset" NOVAL                                                          NOVAL      "Error Indication bit power up value. This bit is defined in IEEE802.3ae - 45.2.1.84 register bit 1.170.1."}\
	{FEC_USE_M20K                            false   true          INTEGER  1                       NOVAL                                                    "SYNTH_FEC && ENA_KR4"      true    boolean                     NOVAL                                   "FEC Options"                "Use M20K for FEC Buffer (if available)"                 NOVAL                                                          NOVAL      "Allows Quartus to replace FEC buffer with M20K memory, saving resources"}\
	}
}


proc ::alt_e40_e100::parameters::declare_parameters {} {
  variable display_items
  variable parameters
  ip_declare_display_items $display_items
  ip_declare_parameters $parameters
  set_parameter_property DEVICE_FAMILY SYSTEM_INFO DEVICE_FAMILY
  set_display_item_property "PMA parameters" DISPLAY_HINT COLLAPSED

}

proc ::alt_e40_e100::parameters::validate {} {
  ip_validate_parameters
}

##########################################################################
####################### Validation Callbacks #############################

proc ::alt_e40_e100::parameters::validate_STATUS_CLK_KHZ {DEVICE_FAMILY STATUS_CLK_KHZ_SV STATUS_CLK_KHZ_SIV } {
	if {$DEVICE_FAMILY == "Stratix IV"} {
		ip_set "parameter.STATUS_CLK_KHZ.value" [expr int($STATUS_CLK_KHZ_SIV * 1000.0)]
	} else {
		ip_set "parameter.STATUS_CLK_KHZ.value" [expr int($STATUS_CLK_KHZ_SV * 1000.0)]
	}
}

proc ::alt_e40_e100::parameters::validate_PHY_PLL {MAC_ONLY_IF NIGHT_FURY_IF DEVICE_FAMILY IS_CAUI4} {
	if {$NIGHT_FURY_IF == 1} {
		ip_set "parameter.PHY_PLL.visible" false
	}
	if {$MAC_ONLY_IF == 1} {
		ip_set "parameter.PHY_PLL.enabled" false
		ip_set "parameter.PHY_PLL.allowed_ranges" {"ATX:N/A" "CMU:N/A"}
	} else {
		ip_set "parameter.PHY_PLL.enabled" true
		ip_set "parameter.PHY_PLL.allowed_ranges" {"ATX" "CMU"}		
	}
	
	if {$DEVICE_FAMILY == "Stratix IV"} {
		ip_set "parameter.PHY_PLL.enabled" false
		ip_set "parameter.PHY_PLL.allowed_ranges" {"ATX:CMU" "CMU:CMU"} 
		if {$MAC_ONLY_IF == 1} {
			ip_set "parameter.PHY_PLL.allowed_ranges" {"ATX:N/A" "CMU:N/A"}
		}
	}
	
	if {$IS_CAUI4} {
		ip_set "parameter.PHY_PLL.enabled" false
		ip_set "parameter.PHY_PLL.allowed_ranges" {"ATX:ATX" "CMU:ATX"} 	
	}
	
}

proc ::alt_e40_e100::parameters::validate_VARIANT {VARIANT} {

	if {$VARIANT == 3} { # Full Duplex
		ip_set "parameter.FULL_DUP_IF.value" 1
		ip_set "parameter.RX_ONLY_IF.value"  0
		ip_set "parameter.TX_ONLY_IF.value"  0
	} elseif {$VARIANT == 2} { # TX only
		ip_set "parameter.FULL_DUP_IF.value" 0
		ip_set "parameter.RX_ONLY_IF.value"  0
		ip_set "parameter.TX_ONLY_IF.value"  1
	} elseif {$VARIANT == 1} { # RX only
		ip_set "parameter.FULL_DUP_IF.value" 0
		ip_set "parameter.RX_ONLY_IF.value"  1
		ip_set "parameter.TX_ONLY_IF.value"  0	
	}

}

proc ::alt_e40_e100::parameters::validate_status_clk {DEVICE_FAMILY} {

	if {$DEVICE_FAMILY == "Stratix IV"} {
		ip_set "parameter.STATUS_CLK_KHZ_SIV.visible" true
		ip_set "parameter.STATUS_CLK_KHZ_SV.visible" false
	} else {
		ip_set "parameter.STATUS_CLK_KHZ_SIV.visible" false
		ip_set "parameter.STATUS_CLK_KHZ_SV.visible" true
	}

}

proc ::alt_e40_e100::parameters::validate_ENABLE_STATISTICS_CNTR {PHY_ONLY_IF} {
	if {$PHY_ONLY_IF == 1} {
		ip_set "parameter.ENABLE_STATISTICS_CNTR.visible"     false
		ip_set "parameter.ENABLE_STATISTICS_CNTR_OFF.visible" true
	} else {
		ip_set "parameter.ENABLE_STATISTICS_CNTR.visible"     true
		ip_set "parameter.ENABLE_STATISTICS_CNTR_OFF.visible" false
	}
}

proc ::alt_e40_e100::parameters::validate_ENABLE_SYNCE_SUPPORT  {DEVICE_FAMILY MAC_ONLY_IF VARIANT} {
	if {$DEVICE_FAMILY == "Arria 10"} {
		ip_set "parameter.en_synce_support.visible" false
		ip_set "parameter.en_synce_support_off.visible" false 
	} elseif {$MAC_ONLY_IF == 1 || $VARIANT != 3} {
		ip_set "parameter.en_synce_support.visible" false
		ip_set "parameter.en_synce_support_off.visible" true 
	} else {
		ip_set "parameter.en_synce_support.visible" true
		ip_set "parameter.en_synce_support_off.visible" false 
	}
}

proc ::alt_e40_e100::parameters::validate_MAC_CONFIG {MAC_CONFIG} {

	if {$MAC_CONFIG == "40 Gbe"} {
		ip_set "parameter.IS_40G.value" 1
		set_fileset_property quartus_synth TOP_LEVEL alt_e40_top
		set_fileset_property sim_verilog   TOP_LEVEL alt_e40_top
		set_fileset_property sim_vhdl      TOP_LEVEL alt_e40_top
		set_fileset_property example       TOP_LEVEL alt_e40_top
		
		#parameters exposed only in e40 wrapper for KR4
		ip_set "parameter.PHY_PLL.HDL_PARAMETER" true
		ip_set "parameter.REF_CLK_FREQ.HDL_PARAMETER" true
		ip_set "parameter.ENA_KR4.HDL_PARAMETER" true
		ip_set "parameter.SYNTH_SEQ.HDL_PARAMETER" true
		ip_set "parameter.SYNTH_FEC.HDL_PARAMETER" true
		ip_set "parameter.SYNTH_AN.HDL_PARAMETER" true
		ip_set "parameter.SYNTH_LT.HDL_PARAMETER" true
		ip_set "parameter.LINK_TIMER_KR.HDL_PARAMETER" true
		ip_set "parameter.OPTIONAL_RXEQ.HDL_PARAMETER" true
		ip_set "parameter.BERWIDTH.HDL_PARAMETER" true
		ip_set "parameter.TRNWTWIDTH.HDL_PARAMETER" true
		ip_set "parameter.MAINTAPWIDTH.HDL_PARAMETER" true
		ip_set "parameter.POSTTAPWIDTH.HDL_PARAMETER" true
		ip_set "parameter.POSTTAPWIDTH.HDL_PARAMETER" true
		ip_set "parameter.PRETAPWIDTH.HDL_PARAMETER" true
		ip_set "parameter.VMAXRULE.HDL_PARAMETER" true
		ip_set "parameter.VMINRULE.HDL_PARAMETER" true
		ip_set "parameter.VODMINRULE.HDL_PARAMETER" true
		ip_set "parameter.VPOSTRULE.HDL_PARAMETER" true
		ip_set "parameter.VPRERULE.HDL_PARAMETER" true
		ip_set "parameter.PREMAINVAL.HDL_PARAMETER" true
		ip_set "parameter.PREPOSTVAL.HDL_PARAMETER" true
		ip_set "parameter.PREPREVAL.HDL_PARAMETER" true
		ip_set "parameter.INITMAINVAL.HDL_PARAMETER" true
		ip_set "parameter.INITPOSTVAL.HDL_PARAMETER" true
		ip_set "parameter.INITPREVAL.HDL_PARAMETER" true
		ip_set "parameter.AN_CHAN.HDL_PARAMETER" true
		ip_set "parameter.AN_PAUSE.HDL_PARAMETER" true
		ip_set "parameter.AN_TECH.HDL_PARAMETER" true
		ip_set "parameter.AN_FEC.HDL_PARAMETER" true
		ip_set "parameter.ERR_INDICATION.HDL_PARAMETER" true
		ip_set "parameter.FEC_USE_M20K.HDL_PARAMETER" true
	} else {
		ip_set "parameter.IS_40G.value" 0
		set_fileset_property quartus_synth TOP_LEVEL alt_e100_top
		set_fileset_property sim_verilog   TOP_LEVEL alt_e100_top
		set_fileset_property sim_vhdl      TOP_LEVEL alt_e100_top
		set_fileset_property example       TOP_LEVEL alt_e100_top
		
		#parameters exposed only in e40 wrapper for KR4
		ip_set "parameter.PHY_PLL.HDL_PARAMETER" false
		ip_set "parameter.REF_CLK_FREQ.HDL_PARAMETER" false
		ip_set "parameter.ENA_KR4.HDL_PARAMETER" false
		ip_set "parameter.SYNTH_SEQ.HDL_PARAMETER" false
		ip_set "parameter.SYNTH_FEC.HDL_PARAMETER" false
		ip_set "parameter.SYNTH_AN.HDL_PARAMETER" false
		ip_set "parameter.SYNTH_LT.HDL_PARAMETER" false
		ip_set "parameter.LINK_TIMER_KR.HDL_PARAMETER" false
		ip_set "parameter.OPTIONAL_RXEQ.HDL_PARAMETER" false
		ip_set "parameter.BERWIDTH.HDL_PARAMETER" false
		ip_set "parameter.TRNWTWIDTH.HDL_PARAMETER" false
		ip_set "parameter.MAINTAPWIDTH.HDL_PARAMETER" false
		ip_set "parameter.POSTTAPWIDTH.HDL_PARAMETER" false
		ip_set "parameter.POSTTAPWIDTH.HDL_PARAMETER" false
		ip_set "parameter.PRETAPWIDTH.HDL_PARAMETER" false
		ip_set "parameter.VMAXRULE.HDL_PARAMETER" false
		ip_set "parameter.VMINRULE.HDL_PARAMETER" false
		ip_set "parameter.VODMINRULE.HDL_PARAMETER" false
		ip_set "parameter.VPOSTRULE.HDL_PARAMETER" false
		ip_set "parameter.VPRERULE.HDL_PARAMETER" false
		ip_set "parameter.PREMAINVAL.HDL_PARAMETER" false
		ip_set "parameter.PREPOSTVAL.HDL_PARAMETER" false
		ip_set "parameter.PREPREVAL.HDL_PARAMETER" false
		ip_set "parameter.INITMAINVAL.HDL_PARAMETER" false
		ip_set "parameter.INITPOSTVAL.HDL_PARAMETER" false
		ip_set "parameter.INITPREVAL.HDL_PARAMETER" false
		ip_set "parameter.AN_CHAN.HDL_PARAMETER" false
		ip_set "parameter.AN_PAUSE.HDL_PARAMETER" false
		ip_set "parameter.AN_TECH.HDL_PARAMETER" false
		ip_set "parameter.AN_FEC.HDL_PARAMETER" false
		ip_set "parameter.ERR_INDICATION.HDL_PARAMETER" false
		ip_set "parameter.FEC_USE_M20K.HDL_PARAMETER" false
	}
}

proc ::alt_e40_e100::parameters::validate_PHY_REFCLK {PHY_REFCLK MAC_ONLY_IF DEVICE_FAMILY PHY_CONFIG MAC_CONFIG IS_CAUI4} {
	if {$MAC_ONLY_IF == 1} {
		ip_set "parameter.PHY_REFCLK.enabled" false
		ip_set "parameter.PHY_REFCLK.allowed_ranges" {1:N/A 2:N/A}  
	} else {
		ip_set "parameter.PHY_REFCLK.enabled" true
		ip_set "parameter.PHY_REFCLK.allowed_ranges" {1:644.53125 2:322.265625}  
		if {$DEVICE_FAMILY != "Arria 10" && $MAC_CONFIG == "40 Gbe" && $PHY_CONFIG == 2} {
			ip_set "parameter.PHY_REFCLK.allowed_ranges" {1:390.625 2:195.3125}  
		}
	}
	
	if {$IS_CAUI4} {
		ip_set "parameter.PHY_REFCLK.enabled" false
		ip_set "parameter.PHY_REFCLK.allowed_ranges" {1:644.53125 2:644.53125}  
	}
	
	#for KR4
	if { $PHY_REFCLK == 1 } {
		ip_set "parameter.REF_CLK_FREQ.value" "644.53125 MHz"
	} else {
		ip_set "parameter.REF_CLK_FREQ.value" "322.265625 MHz"
	}

}

proc ::alt_e40_e100::parameters::validate_INTERFACE {INTERFACE PHY_ONLY_IF} {

	if {$INTERFACE == "Avalon-ST Interface"} {
		ip_set "parameter.HAS_ADAPTERS.value" 1
	} elseif {$INTERFACE == "Custom-ST Interface"} {
		ip_set "parameter.HAS_ADAPTERS.value" 0
	}
	
	
	if {$PHY_ONLY_IF == 1} {
		ip_set "parameter.INTERFACE.enabled" false
		ip_set "parameter.INTERFACE.allowed_ranges" {"Avalon-ST Interface:N/A" "Custom-ST Interface:N/A"} 
	} else {
		ip_set "parameter.INTERFACE.allowed_ranges" {"Avalon-ST Interface" "Custom-ST Interface"} 
	}
	
}

proc ::alt_e40_e100::parameters::validate_PHY_CONFIG {PHY_CONFIG MAC_ONLY_IF DEVICE_FAMILY MAC_CONFIG} {
	if {$PHY_CONFIG == 1} {
		ip_set "parameter.IS_CAUI4.value" 0
	} elseif {$PHY_CONFIG == 2} {
		if {$MAC_CONFIG == "40 Gbe"} {
			# 24.24G when in 40G mode
			ip_set "parameter.IS_CAUI4.value" 0
		} else {
			ip_set "parameter.IS_CAUI4.value" 1
		}
	}
	
	if {$MAC_ONLY_IF == 1} {
		ip_set "parameter.PHY_CONFIG.enabled" false
		ip_set "parameter.PHY_CONFIG.allowed_ranges" {"1:N/A" "2:N/A"} 
	} else {
	
		if {$MAC_CONFIG == "100 Gbe"} {
		
			if {$DEVICE_FAMILY == "Stratix IV" || $DEVICE_FAMILY == "Arria 10"} {
				ip_set "parameter.PHY_CONFIG.enabled" false
				ip_set "parameter.PHY_CONFIG.allowed_ranges" {"1:100 Gbps (10x10)" "2:100 Gbps (10x10)"}
			} else {
				ip_set "parameter.PHY_CONFIG.enabled" true
				ip_set "parameter.PHY_CONFIG.allowed_ranges" {"1:100 Gbps (10x10)" "2:CAUI-4 (4x25)"} 
			}
		
		} else {
			if {$DEVICE_FAMILY == "Arria 10"} {
				ip_set "parameter.PHY_CONFIG.enabled" false
				ip_set "parameter.PHY_CONFIG.allowed_ranges" {"1:40 Gbps (4x10)" "2:40 Gbps (4x10)"} 
			} else {
				ip_set "parameter.PHY_CONFIG.enabled" true
				ip_set "parameter.PHY_CONFIG.allowed_ranges" {"1:40 Gbps (4x10)" "2:24.24 Gbps (4x6.25)"} 
			}
		}
	
		
	}

}

proc ::alt_e40_e100::parameters::validate_CORE_OPTION {CORE_OPTION ENABLE_STATISTICS_CNTR} {
  if {$CORE_OPTION == "MAC & PHY"} {
		set_parameter_property ENABLE_STATISTICS_CNTR ENABLED true
		ip_set "parameter.MAC_ONLY_IF.value" 0
		ip_set "parameter.PHY_ONLY_IF.value" 0
		ip_set "parameter.HAS_MAC.value" 1
		ip_set "parameter.HAS_PHY.value" 1
		
	} elseif {$CORE_OPTION == "MAC only"} {
		set_parameter_property ENABLE_STATISTICS_CNTR ENABLED true
		ip_set "parameter.MAC_ONLY_IF.value" 1
		ip_set "parameter.PHY_ONLY_IF.value" 0
		ip_set "parameter.HAS_MAC.value" 1
		ip_set "parameter.HAS_PHY.value" 0
	} else {
        set_parameter_property ENABLE_STATISTICS_CNTR ENABLED false
		ip_set "parameter.MAC_ONLY_IF.value" 0
		ip_set "parameter.PHY_ONLY_IF.value" 1
		ip_set "parameter.HAS_MAC.value" 0
		ip_set "parameter.HAS_PHY.value" 1
  }

}

proc ::alt_e40_e100::parameters::validate_DEVICE_FAMILY {DEVICE_FAMILY RX_ONLY_IF MAC_ONLY_IF} {
  if {$DEVICE_FAMILY == "Arria 10"} {  
		ip_set "parameter.NIGHT_FURY_IF.value" 1
	} else {
        ip_set "parameter.NIGHT_FURY_IF.value" 0
  }
  if {$DEVICE_FAMILY == "Stratix IV"} {
	ip_set "parameter.STRATIX_IV_IF.value" 1
  } else {
	ip_set "parameter.STRATIX_IV_IF.value" 0
  }
  
  set message "<html><font color=\"blue\">Note - </font>The external Arria 10 ATX or CMU TX PLL IP must be configured with an output clock frequency of <b>5156.25 MHz.</b></html>"
  if {!$RX_ONLY_IF && !$MAC_ONLY_IF && ($DEVICE_FAMILY == "Arria 10")} {
    ip_message info $message
  }
  
    
}

proc ::alt_e40_e100::parameters::validate_ENA_KR4 {ENA_KR4_gui DEVICE_FAMILY MAC_CONFIG CORE_OPTION PHY_CONFIG VARIANT} {
  if {[::alt_xcvr::utils::device::has_s5_style_hssi $DEVICE_FAMILY] &&
      $MAC_CONFIG == "40 Gbe" &&
      $CORE_OPTION != "MAC only" &&
      $PHY_CONFIG == 1 &&
      $VARIANT == 3
      } {  
        set_parameter_property ENA_KR4_gui ENABLED true
        ip_set "parameter.ENA_KR4_gui.visible"     true
        ip_set "parameter.ENA_KR4_OFF.visible" false
        ip_set "parameter.ENA_KR4.value" $ENA_KR4_gui
    } else {
        set_parameter_property ENA_KR4_gui ENABLED false
        ip_set "parameter.ENA_KR4_gui.visible"     false
        ip_set "parameter.ENA_KR4_OFF.visible" true
        ip_set "parameter.ENA_KR4.value" 0
    }
}

proc ::alt_e40_e100::parameters::calc_ber_ctr_width { BERWIDTH_gui }  {
if {$BERWIDTH_gui==15} {
 ip_set "parameter.BERWIDTH.value" 4
 } elseif {$BERWIDTH_gui==31} {
 ip_set "parameter.BERWIDTH.value" 5
 } elseif {$BERWIDTH_gui==63} {
 ip_set "parameter.BERWIDTH.value" 6
 } elseif {$BERWIDTH_gui==127} {
 ip_set "parameter.BERWIDTH.value" 7
 } elseif {$BERWIDTH_gui==255} {
 ip_set "parameter.BERWIDTH.value" 8
 } elseif {$BERWIDTH_gui==511} {
 ip_set "parameter.BERWIDTH.value" 9
 } elseif {$BERWIDTH_gui==1023} {
 ip_set "parameter.BERWIDTH.value" 10
 } elseif {$BERWIDTH_gui==2047} {
 ip_set "parameter.BERWIDTH.value" 11
 } elseif {$BERWIDTH_gui==4095} {
 ip_set "parameter.BERWIDTH.value" 12
 } elseif {$BERWIDTH_gui==8191} {
 ip_set "parameter.BERWIDTH.value" 13
 } else {
 ip_set "parameter.BERWIDTH.value" 14
 }            
}      

proc ::alt_e40_e100::parameters::calc_trn_ctr_width { TRNWTWIDTH_gui }  {
if {$TRNWTWIDTH_gui==127} {
 ip_set "parameter.TRNWTWIDTH.value" 7
} else {
 ip_set "parameter.TRNWTWIDTH.value" 8
}            
}

proc ::alt_e40_e100::parameters::validate_an_pause { AN_PAUSE_C0 AN_PAUSE_C1 } {
ip_set "parameter.AN_PAUSE.value" [expr $AN_PAUSE_C1*2+ $AN_PAUSE_C0*1  ]
}

proc ::alt_e40_e100::parameters::validate_an_tech  { AN_GIGE AN_XAUI AN_BASER AN_40GBP AN_40GCR AN_100G } {
ip_set "parameter.AN_TECH.value" [expr $AN_100G*32+ $AN_40GCR*16+ $AN_40GBP*8+ $AN_BASER*4+ $AN_XAUI*2+ $AN_GIGE*1  ]
}

proc ::alt_e40_e100::parameters::validate_an_fec { CAPABLE_FEC ENABLE_FEC SYNTH_FEC } {
 if {$SYNTH_FEC} {
  ip_set "parameter.AN_FEC.value" [expr $ENABLE_FEC*2+ $CAPABLE_FEC*1  ]
 } else { 
  ip_set "parameter.AN_FEC.value" 0
 }
}

proc ::alt_e40_e100::parameters::validate_synth_an {SYNTH_SEQ SYNTH_AN_gui } {
 if {$SYNTH_SEQ} {
  ip_set "parameter.SYNTH_AN.value" $SYNTH_AN_gui
 } else { 
  ip_set "parameter.SYNTH_AN.value" 0
 }
}

proc ::alt_e40_e100::parameters::validate_synth_lt {SYNTH_SEQ SYNTH_LT_gui } {
 if {$SYNTH_SEQ} {
  ip_set "parameter.SYNTH_LT.value" $SYNTH_LT_gui
 } else { 
  ip_set "parameter.SYNTH_LT.value" 0
 }
}

proc ::alt_e40_e100::parameters::validate_time_kr  {LINK_TIMER_KR  STATUS_CLK_KHZ SYNTH_SEQ ENA_KR4 }  {
if {$SYNTH_SEQ && $ENA_KR4} {
 set min_val [expr 1000*1000.0/$STATUS_CLK_KHZ]
 set max_val [expr 1000*1000.0/$STATUS_CLK_KHZ*64]
 out_of_range_message $min_val $max_val $LINK_TIMER_KR error "Link Fail Time for KR" 0 ""
 out_of_range_message 500 510 $LINK_TIMER_KR warning "Link Fail Time for KR" 1 "The current Link Fail Timer for KR  value does not meet IEEE802.3ba specification. IEEE802.3ba specifies this timer value to be between 500mS and 510mS" 
}
}

proc ::alt_e40_e100::parameters::validate_vmaxrule { VMAXRULE SYNTH_LT ENA_KR4 }  {
if {$SYNTH_LT && $ENA_KR4} {
out_of_range_message  0 63 $VMAXRULE  error  "VMAXRULE" 1 "Current value of VMAXRULE is not valid. 0 &lt; VMAXRULE &lt; 63."  
out_of_range_message  0 60 $VMAXRULE  warning "VMAXRULE" 1 "Recommended VMAXRULE values is 60 to meet IEEE specification of 1200 mV."  
}
}    

proc ::alt_e40_e100::parameters::validate_vminrule { VMAXRULE VMINRULE SYNTH_LT ENA_KR4 }  {
if {$SYNTH_LT && $ENA_KR4} {
out_of_range_message  0   $VMAXRULE $VMINRULE  error  "VMINRULE" 1 "Current value of VMINRULE is not valid. 0 &lt; VMINRULE &lt; VMAXRULE &lt; 63."  
}
}    

proc ::alt_e40_e100::parameters::validate_vodrule { VMAXRULE VMINRULE VODMINRULE SYNTH_LT ENA_KR4 }  {
if {$SYNTH_LT && $ENA_KR4} {
out_of_range_message  $VMINRULE $VMAXRULE $VODMINRULE  error  "VODMINRULE" 1 "Current value of VODMINRULE is not valid. VMINRULE &lt; VODMINRULE &lt; VMAXRULE."  
out_of_range_message  22 63 $VODMINRULE  warning "VODMINRULE" 1 "Recommended VODMINRULE values is 22 or greater to meet IEEE specification of 440 mV."  
}    
}

proc ::alt_e40_e100::parameters::validate_vpostrule { VPOSTRULE SYNTH_LT ENA_KR4 }  {
if {$SYNTH_LT && $ENA_KR4} {
out_of_range_message 0 31 $VPOSTRULE  error  "VPOSTRULE" 0 ""  
}    
}

proc ::alt_e40_e100::parameters::validate_vprerule { VPRERULE SYNTH_LT ENA_KR4 }  {
if {$SYNTH_LT && $ENA_KR4} {
out_of_range_message 0 15 $VPRERULE  error  "VPRERULE" 0 ""  
}    
}

proc ::alt_e40_e100::parameters::validate_premainrule { VMAXRULE VODMINRULE PREMAINVAL SYNTH_LT ENA_KR4 }  {
if {$SYNTH_LT && $ENA_KR4} {
out_of_range_message $VODMINRULE $VMAXRULE $PREMAINVAL  error  "PREMAINVAL" 1 "Current value of PREMAINVAL is not valid. VODMIN &lt; PREMAINVAL &lt; VMAXRULE."  
}    
}

proc ::alt_e40_e100::parameters::validate_prepostrule { VMINRULE PREMAINVAL PREPOSTVAL PREPREVAL SYNTH_LT ENA_KR4 }  {
if {$SYNTH_LT && $ENA_KR4} {
set invalid1  [expr { $PREMAINVAL + [expr {0.25 * $PREPOSTVAL}] + [expr {0.25 * $PREPREVAL}] <= 70 ? {0} : {1} } ]
set invalid2  [expr { $PREMAINVAL - $PREPOSTVAL - $PREPREVAL >= $VMINRULE ? {0} : {1} } ]
if { [expr $invalid1 || $invalid2 ] } {
ip_message error "Current values for  PREMAINVAL, PREPOSTVAL, PREPREVAL are not correct. Follow \n  PREMAINVAL + 0.25*PREPOSTVAL + 0.25*PREPREVAL &lt;= 70 \n PREMAINVAL - PREPOSTVAL - PREPREVAL >= VMINRULE."
 } 
if { [expr  $PREPOSTVAL ||  $PREPREVAL ] } {
   ip_message warning "Recommended IEEE values for PREPOSTVAL, and PREPREVAL are zero."
   }
}    
}

proc ::alt_e40_e100::parameters::validate_initmainrule { VMAXRULE VODMINRULE INITMAINVAL SYNTH_LT ENA_KR4 }  {
if {$SYNTH_LT && $ENA_KR4} {
out_of_range_message $VODMINRULE $VMAXRULE $INITMAINVAL  error  "INITMAINVAL" 1 "Current value of INITMAINVAL is not valid. VODMIN &lt; INITMAINVAL &lt; VMAXRULE."  
}   
}

proc ::alt_e40_e100::parameters::validate_initprepostrule { VMINRULE VPOSTRULE INITMAINVAL INITPOSTVAL INITPREVAL SYNTH_LT ENA_KR4 }  {
if {$SYNTH_LT && $ENA_KR4} {
out_of_range_message  0 $VPOSTRULE $INITPOSTVAL  error  "INITPOSTVAL" 1 "Current value of INITPOSTVAL is not valid. 0 &lt; INITPOSTVAL &lt; VPOSTRULE."  
set invalid1  [expr { $INITMAINVAL + [expr {0.25 *  $INITPOSTVAL}] + [expr {0.25 * $INITPREVAL}] <= 70 ? {0} : {1} } ]
set invalid2  [expr { $INITMAINVAL - $INITPOSTVAL - $INITPREVAL >= $VMINRULE ? {0} : {1} } ]
if { [expr $invalid1 || $invalid2] } {
ip_message error "Current values for  INITMAINVAL, INITPOSTVAL, INITPREVAL are not correct. Follow \n  INITMAINVAL + 0.25*INITPOSTVAL + 0.25*INITPREVAL &lt; 70 \n INITMAINVAL - INITPOSTVAL - INITPREVAL > VMINRULE."
 } 
if { $INITPOSTVAL != 30 } {
   ip_message warning "Recommended IEEE value for INITPOSTVAL is 30."
  }
if { $INITPREVAL != 5 } {
   ip_message warning "Recommended IEEE value for INITPREVAL is 5."
  }
}   
}

####################### Validation Callbacks #############################
##########################################################################

#******************************************************************************
#************************* Internal messaging procedures **********************

proc ::alt_e40_e100::parameters::out_of_range_message {min_val max_val current_val severity field customized c_message} {

set illegal [expr {$current_val < $min_val ? {1}
    : $current_val > $max_val ? {1}
    : {0}  }  ]

if {[expr $illegal & !$customized]} {
ip_message $severity "The selected ${field} is not supported. Valid ${field} range is ${min_val} to ${max_val}."
}
if {[expr $illegal & $customized]} {
ip_message $severity "$c_message"
}

}

#*********************** End internal messaging procedures ********************
#******************************************************************************
