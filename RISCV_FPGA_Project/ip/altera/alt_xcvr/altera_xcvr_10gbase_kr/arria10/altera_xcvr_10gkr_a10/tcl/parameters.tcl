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


package provide altera_xcvr_10gkr_a10::parameters 13.1

package require alt_xcvr::ip_tcl::ip_module
package require alt_xcvr::ip_tcl::messages
package require alt_xcvr::gui::pll_reconfig
package require alt_xcvr::gui::messages
package require alt_xcvr::utils::device
package require alt_xcvr::utils::rbc

namespace eval ::altera_xcvr_10gkr_a10::parameters:: {
  namespace import ::alt_xcvr::ip_tcl::ip_module::*
  namespace import ::alt_xcvr::ip_tcl::messages::*

  namespace export \
    declare_parameters \
    validate \
    upgrade

  variable package_name
  variable val_prefix
  variable display_items
  variable parameters
  variable parameter_upgrade_map

  #TODO
  variable l_legal_params

  set package_name "altera_xcvr_10gkr_a10::parameters"

  set display_items {\
    {NAME                         GROUP                 TYPE  ARGS    DESCRIPTION  }\
    {"Main"                       ""                    GROUP tab     NOVAL        }\
    {"Ethernet MegaCore Type"     ""                    GROUP NOVAL   NOVAL        }\
    {"General options"            ""                    GROUP NOVAL   NOVAL        }\
    {"10GBASE-R"                  ""                    GROUP tab     "TESTING..." }\
    {"10M/100M/1Gb Ethernet"      ""                    GROUP tab     NOVAL        }\
    {"Speed Detection"            ""                    GROUP tab     NOVAL        }\
    {"Auto-Negotiation"           ""                    GROUP tab     NOVAL        }\
    {"Link Training"              ""                    GROUP tab     NOVAL        }\
    {"FEC Options"                "10GBASE-R"           GROUP NOVAL   NOVAL        }\
    {"PMA parameters"             "Link Training"       GROUP NOVAL   NOVAL        }\
  }
    
  set parameters {\
    {NAME                                   DERIVED HDL_PARAMETER TYPE      DEFAULT_VALUE         ALLOWED_RANGES                            ENABLED                   VISIBLE         DISPLAY_HINT  DISPLAY_UNITS   DISPLAY_ITEM                        DISPLAY_NAME                                                   VALIDATION_CALLBACK                                                       DESCRIPTION }\
    {DEVICE_FAMILY                          true    true          STRING    "Arria 10"            NOVAL                                     true                      false           NOVAL         NOVAL           NOVAL                               NOVAL                                                          NOVAL                                                                     NOVAL}\
    {UNHIDE_ADV                             true    false         STRING    "false"               NOVAL                                     true                      false           NOVAL         NOVAL           NOVAL                               NOVAL                                                          ::altera_xcvr_10gkr_a10::parameters::chk_qii_ini                          NOVAL}\
    {sel_backplane_lineside                 false   false         STRING    "1Gb/10Gb Ethernet"   {"1Gb/10Gb Ethernet" "Backplane-KR"}      true                      true            NOVAL         NOVAL           "Ethernet MegaCore Type"            "IP variant"                                                    NOVAL                                                                    "Select between Backplane KR or LineSide."}\
    {chk_backplane                          true    false         INTEGER   0                     NOVAL                                     true                      false           NOVAL         NOVAL           NOVAL                               NOVAL                                                          ::altera_xcvr_10gkr_a10::parameters::validate_chk_backplane               NOVAL                                          }\
    \
    {SYNTH_FEC                              false   true          INTEGER   0                     NOVAL                                     true                      true            boolean       NOVAL           "FEC Options"                       "Include FEC sublayer"                                         NOVAL                                                                    "This will include FEC logic -Clause 74 implementation. Applicable only for 10G mode."}\
    {SYNTH_AN                               false   true          INTEGER   0                     NOVAL                                     true                      true            boolean       NOVAL           "Auto-Negotiation"                  "Enable Auto-Negotiation"                                      NOVAL                                                                    "This will include Auto-Negotiatiation for Backplane -Clause 73 implementation."}\
    {SYNTH_LT                               false   true          INTEGER   0                     NOVAL                                     true                      true            boolean       NOVAL           "Link Training"                     "Enable Link Training"                                         NOVAL                                                                    "When you turn this option On, the core includes the link training module which allows the remote link-partner TX PMD for the lowest Bit Error Rate (BER). LT is defined in Clause 72 of IEEE Std 802.3ap-2007."}\
    {SYNTH_SEQ                              false   true          INTEGER   1                     NOVAL                                     true                      true            boolean       NOVAL           "Speed Detection"                   "Enable automatic speed detection"                             ::altera_xcvr_10gkr_a10::parameters::validate_synth_seq                  "This module controls the link-up sequence for reconfiguration into and out of the AN, LT and data modes of the 10GBASE-KR PHY IP Core. The interface to the Reconfiguration Design Example transmits reconfiguration requests."}\
    {SYNTH_GIGE                             false   true          INTEGER   1                     NOVAL                                     true                      true            boolean       NOVAL           "10M/100M/1Gb Ethernet"             "Enable 1Gb Ethernet protocol"                                 NOVAL                                                                    "Enables GMII interface and related logic."}\
    {SYNTH_GMII_gui                         false   false         INTEGER   1                     NOVAL                                     "SYNTH_GIGE"              false           boolean       NOVAL           "10M/100M/1Gb Ethernet"             "Enable GMII PCS"                                              NOVAL                                                                    "Synthesize/include the GMII PCS."}\
    {SYNTH_GMII                             true    true          INTEGER   1                     NOVAL                                     true                      false           boolean       NOVAL           "10M/100M/1Gb Ethernet"             "Enable GMII PCS"                                              NOVAL                                                                    "Synthesize/include the GMII PCS."}\
    {SYNTH_SGMII                            false   true          INTEGER   1                     NOVAL                                     "SYNTH_GIGE"              false           boolean       NOVAL           "10M/100M/1Gb Ethernet"             "Enable SGMII bridge logic"                                    ::altera_xcvr_10gkr_a10::parameters::validate_sgmii                      "Turn on this option to add the SGMII clock and rate-adaptation logic to the PCS block. If your application only requires 1000BASE-X PCS, turning off this option reduces resource usage."}\
    {SYNTH_MII                              false   false         INTEGER   0                     NOVAL                                     "SYNTH_GIGE"              true            boolean       NOVAL           "10M/100M/1Gb Ethernet"             "Enable 10Mb/100Mb Ethernet functionality"                     NOVAL                                                                    "Enables 10Mb/100Mb functionality and also exposes MII interface."}\
    {SYNTH_1588_1G                          true    true          INTEGER   0                     NOVAL                                     "SYNTH_GIGE"              false           boolean       NOVAL           "10M/100M/1Gb Ethernet"             "Enable IEEE 1588 Precision Time Protocol"                     NOVAL                                                                    "Enable IEEE 1588 PTP logic."}\
    {PHY_IDENTIFIER                         false   true          INTEGER   0                     NOVAL                                     "SYNTH_GIGE"              true            hexadecimal   NOVAL           "10M/100M/1Gb Ethernet"             "PHY ID (32 bits)"                                             NOVAL                                                                    "This is a 32-bit value, which may constitute a unique identifier for a particular type of PCS. The identifier is the concatenation of the following elements: the 3rd-24th bits of the Organizationally Unique Identifier (OUI) assigned to the device manufacturer by the IEEE, a 6-bit model number, and a 4-bit revision number. A PCS may return a value of zero in each of the 32 bits of the PCS device identifier."}\
    {DEV_VERSION                            false   true          INTEGER   0                     NOVAL                                     "SYNTH_GIGE"              true            hexadecimal   NOVAL           "10M/100M/1Gb Ethernet"             "PHY core version (16 bits)"                                   ::altera_xcvr_10gkr_a10::parameters::validate_dev_rev_16bit              "This is a 32-bit value, which may constitute a unique identifier for a particular type of PCS. The identifier is the concatenation of the following elements: the 3rd-24th bits of the Organizationally Unique Identifier (OUI) assigned to the device manufacturer by the IEEE, a 6-bit model number, and a 4-bit revision number. A PCS may return a value of zero in each of the 32 bits of the PCS device identifier."}\
    {SYNTH_CL37ANEG                         true    true          INTEGER   1                     NOVAL                                     "SYNTH_GIGE"              false           NOVAL         NOVAL           NOVAL                               NOVAL                                                          ::altera_xcvr_10gkr_a10::parameters::validate_cl37aneg                   NOVAL}\
    {REF_CLK_FREQ_1G                        false   false         STRING    "125.00 MHz"          {"125.00 MHz" "62.50 MHz"}                "SYNTH_GIGE"              false           NOVAL         NOVAL           "10M/100M/1Gb Ethernet"             "Reference clock frequency"                                    NOVAL                                                                    "PLL Reference clock frequency for 1GbE PLL."}\
    {EN_CORECLK_1G                          false   false         INTEGER   0                     NOVAL                                     "SYNTH_GIGE"              false           boolean       NOVAL           "10M/100M/1Gb Ethernet"             "Expose coreclock inputs"                                      NOVAL                                                                    "Expose coreclock inputs."}\
    \
    {phy_mgmt_clk_freq                      false   false         STRING    "125.00"              NOVAL                                     "SYNTH_SEQ"               true            "columns:10"  MHz             "Speed Detection"                   "Avalon-MM clock frequency"                                    NOVAL                                                                    "Specifies the frequency of the Avalon-MM clock. The  range is 100-125 MHz. The link inhibit timer uses this frequency in calculating counter values."}\
    {phy_mgmt_clk_freq_valid                true    false         INTEGER   1                     NOVAL                                     true                      false           NOVAL         NOVAL           NOVAL                               NOVAL                                                          ::altera_xcvr_10gkr_a10::parameters::validate_mgmt_clk_freq_valid        NOVAL}\
    {LINK_TIMER_KR_valid                    true    false         INTEGER   1                     NOVAL                                     true                      false           NOVAL         NOVAL           NOVAL                               NOVAL                                                          NOVAL                                                                    NOVAL}\
    {LINK_TIMER_KR                          false   false         STRING    504.00                NOVAL                                     "SYNTH_SEQ"               true            "columns:10"  ms              "Speed Detection"                   "Link fail inhibit time for 10Gb Ethernet"                     ::altera_xcvr_10gkr_a10::parameters::validate_time_kr                    "Timer for qualifying a link_status=FAIL indication or a link_status=OK indication when a specific technology link is first being established."}\
    {LINK_TIMER_KX_valid                    true    false         INTEGER   1                     NOVAL                                     true                      false           NOVAL         NOVAL           NOVAL                               NOVAL                                                          NOVAL                                                                    NOVAL}\
    {LINK_TIMER_KX                          false   false         STRING    48.00                 NOVAL                                     "SYNTH_SEQ"               true            "columns:10"  ms              "Speed Detection"                   "Link fail inhibit time for 1Gb Ethernet"                      ::altera_xcvr_10gkr_a10::parameters::validate_time_kx                    "Timer for qualifying a link_status=FAIL indication or a link_status=OK indication when a specific technology link is first being established."}\
    {LFT_R_MSB                              true    true          INTEGER   63                    NOVAL                                     true                      false           NOVAL         NOVAL           "Speed Detection"                   NOVAL                                                          ::altera_xcvr_10gkr_a10::parameters::validate_lft_msb_kr                 "Link Fail Timer MSB for BASE-R PCS."}\
    {LFT_R_LSB                              true    true          INTEGER   0                     NOVAL                                     true                      false           NOVAL         NOVAL           "Speed Detection"                   NOVAL                                                          ::altera_xcvr_10gkr_a10::parameters::validate_lft_lsb_kr                 "Link Fail Timer lsb for BASE-R PCS."}\
    {LFT_X_MSB                              true    true          INTEGER   6                     NOVAL                                     true                      false           NOVAL         NOVAL           "Speed Detection"                   NOVAL                                                          ::altera_xcvr_10gkr_a10::parameters::validate_lft_msb_kx                 "Link Fail Timer MSB for BASE-X PCS."}\
    {LFT_X_LSB                              true    true          INTEGER   0                     NOVAL                                     true                      false           NOVAL         NOVAL           "Speed Detection"                   NOVAL                                                          ::altera_xcvr_10gkr_a10::parameters::validate_lft_lsb_kx                 "Link Fail Timer lsb for BASE-X PCS."}\
    \
    {OPTIONAL_DM                            false   false         INTEGER   0                     NOVAL                                     "SYNTH_LT"                true            boolean       NOVAL           "Link Training"                     "Enable daisy chain mode"                                      NOVAL                                                                    "When you turn this option On, the core includes software for non-standard link configurations where the TX and RX interfaces connect to different link partners. This mode overrides the TX adaptation algorithm."}\
    {OPTIONAL_UP                            false   false         INTEGER   0                     NOVAL                                     "SYNTH_LT"                true            boolean       NOVAL           "Link Training"                     "Enable microprocessor interface"                              NOVAL                                                                    "When you turn this option On, the core includes a microprocessor interface which enables the microprocessor mode for link training."}\
    {BERWIDTH_gui                           false   false         INTEGER   511                   {15 31 63 127 255 511 1023}               "SYNTH_LT"                true            NOVAL         NOVAL           "Link Training"                     "Maximum bit error count"                                      NOVAL                                                                    "Specifies the expected number of bit errors for the error counter expected during each step of the link training. If the number of errors exceeds this number for each step, the core returns an error. The number of errors depends upon the amount of time for each step and the quality of the physical link media."}\
    {BERWIDTH                               true    true          INTEGER   9                     {4 5 6 7 8 9 10}                          "SYNTH_LT"                false           NOVAL         NOVAL           "Link Training"                     "Bit error counter width"                                      ::altera_xcvr_10gkr_a10::parameters::calc_ber_ctr_width                  NOVAL}\
    {TRNWTWIDTH_gui                         false   false         INTEGER   127                   {127 255}                                 "SYNTH_LT"                true            NOVAL         NOVAL           "Link Training"                     "Number of frames to send before sending actual data"          NOVAL                                                                     "This timer is started when local receiver is trained and detects that the remote receiver is ready to receive data. The local PMD will deliver wait_timer additional training frames to ensure that the link partner correctly detects the local receiver state."}\
    {TRNWTWIDTH                             true    true          INTEGER   NOVAL                 NOVAL                                     "SYNTH_LT"                false           NOVAL         NOVAL           "Link Training"                     NOVAL                                                          ::altera_xcvr_10gkr_a10::parameters::calc_trn_ctr_width                   NOVAL}\
    {MAINTAPWIDTH                           true    true          INTEGER   6                     NOVAL                                     "SYNTH_LT"                false           "columns:10"  NOVAL           "Link Training"                     NOVAL                                                          ::altera_xcvr_10gkr_a10::parameters::validate_main_tapwidth               "Width of the Main Tap control."}\
    {POSTTAPWIDTH                           true    true          INTEGER   6                     NOVAL                                     "SYNTH_LT"                false           "columns:10"  NOVAL           "Link Training"                     NOVAL                                                          ::altera_xcvr_10gkr_a10::parameters::validate_post_tapwidth               "Width of the Post Tap control."}\
    {PRETAPWIDTH                            true    true          INTEGER   5                     NOVAL                                     "SYNTH_LT"                false           "columns:10"  NOVAL           "PMA parameters"                    NOVAL                                                          ::altera_xcvr_10gkr_a10::parameters::validate_pre_tapwidth                "Width of the Pre Tap control."}\
    {VMAXRULE                               false   true          INTEGER   60                    NOVAL                                     "SYNTH_LT"                true            "columns:10"  NOVAL           "PMA parameters"                    NOVAL                                                          ::altera_xcvr_10gkr_a10::parameters::validate_vmaxrule                    "Specifies the maximum VOD. The default value is 60 which represents 1200 mV."}\
    {VMINRULE                               false   true          INTEGER   9                     NOVAL                                     "SYNTH_LT"                true            "columns:10"  NOVAL           "PMA parameters"                    NOVAL                                                          ::altera_xcvr_10gkr_a10::parameters::validate_vminrule                    "Specifies the minimum VOD. The default value is 9 which represents 165 mV."}\
    {VODMINRULE                             false   true          INTEGER   30                    NOVAL                                     "SYNTH_LT"                true            "columns:10"  NOVAL           "PMA parameters"                    NOVAL                                                          ::altera_xcvr_10gkr_a10::parameters::validate_vodrule                     "Specifies the minimum VOD for the first tap. The default value is 22 which represents 440mV."}\
    {VPOSTRULE                              false   true          INTEGER   31                    NOVAL                                     "SYNTH_LT"                true            "columns:10"  NOVAL           "PMA parameters"                    NOVAL                                                          ::altera_xcvr_10gkr_a10::parameters::validate_vpostrule                   "Specifies the maximum value that the internal algorithm for pre-emphasis will ever test in determining the optimum post-tap setting. The default value is 25."}\
    {VPRERULE                               false   true          INTEGER   15                    NOVAL                                     "SYNTH_LT"                true            "columns:10"  NOVAL           "PMA parameters"                    NOVAL                                                          ::altera_xcvr_10gkr_a10::parameters::validate_vprerule                    "Specifies the maximum value that the internal algorithm for pre-emphasis will ever test in determining the optimum pre-tap setting. The default value is 15."}\
    {PREMAINVAL                             false   true          INTEGER   60                    NOVAL                                     "SYNTH_LT"                true            "columns:10"  NOVAL           "PMA parameters"                    NOVAL                                                          ::altera_xcvr_10gkr_a10::parameters::validate_premainrule                 "Specifies the Preset VOD Value. Set by the Preset command as defined in Clause 72.6.10.2.3.1 of the link training protocol. This is the value from which the algorithm starts. The default value is 60.Preset Main tap value."}\
    {PREPOSTVAL                             false   true          INTEGER   0                     NOVAL                                     "SYNTH_LT"                true            "columns:10"  NOVAL           "PMA parameters"                    NOVAL                                                          NOVAL                                                                     "Specifies the preset Post-tap value. The default value is 0."}\
    {PREPREVAL                              false   true          INTEGER   0                     NOVAL                                     "SYNTH_LT"                true            "columns:10"  NOVAL           "PMA parameters"                    NOVAL                                                          ::altera_xcvr_10gkr_a10::parameters::validate_prepostrule                 "Specifies the preset Pre-tap Value. The default value is 0."}\
    {INITMAINVAL                            false   true          INTEGER   52                    NOVAL                                     "SYNTH_LT"                true            "columns:10"  NOVAL           "PMA parameters"                    NOVAL                                                          ::altera_xcvr_10gkr_a10::parameters::validate_initmainrule                "Specifies the Initial VOD Value. Set by the Initialize command in Clause 72.6.10.2.3.2 of the link training protocol. The default value is 35."}\
    {INITPOSTVAL                            false   true          INTEGER   30                    NOVAL                                     "SYNTH_LT"                true            "columns:10"  NOVAL           "PMA parameters"                    NOVAL                                                          NOVAL                                                                     "Specifies the initial t Post-tap value. The default value is 14."}\
    {INITPREVAL                             false   true          INTEGER   5                     NOVAL                                     "SYNTH_LT"                true            "columns:10"  NOVAL           "PMA parameters"                    NOVAL                                                          ::altera_xcvr_10gkr_a10::parameters::validate_initprepostrule             "Specifies the Initial Pre-tap Value. The default value is 3."}\
    \
    {AN_GIGE                                true    false         INTEGER   0                     NOVAL                                     "SYNTH_AN"                false           boolean       NOVAL           "Auto-Negotiation"                  "1000 BASE-KX Technology Ability"                              ::altera_xcvr_10gkr_a10::parameters::validate_an_gige                     "Pause ability, depends upon MAC.  "}\
    {AN_XAUI                                false   false         INTEGER   0                     NOVAL                                     "SYNTH_AN"                false           boolean       NOVAL           "Auto-Negotiation"                  "10GBASE-KX4 Technology Ability"                               NOVAL                                                                     "Pause ability, depends upon MAC.  "}\
    {AN_BASER                               false   false         INTEGER   1                     NOVAL                                     "SYNTH_AN"                false           boolean       NOVAL           "Auto-Negotiation"                  "10GBASE-KR Technology Ability"                                NOVAL                                                                     "Pause ability, depends upon MAC.  "}\
    {AN_40GBP                               false   false         INTEGER   0                     NOVAL                                     "SYNTH_AN"                false           boolean       NOVAL           "Auto-Negotiation"                  "40GBASE-KR44 Technology Ability"                              NOVAL                                                                     "Pause ability, depends upon MAC.  "}\
    {AN_40GCR                               false   false         INTEGER   0                     NOVAL                                     "SYNTH_AN"                false           boolean       NOVAL           "Auto-Negotiation"                  "40GBASE-CR4 Technology Ability"                               NOVAL                                                                     "Pause ability, depends upon MAC.  "}\
    {AN_100G                                false   false         INTEGER   0                     NOVAL                                     "SYNTH_AN"                false           boolean       NOVAL           "Auto-Negotiation"                  "100GBASE-CR10 Technology Ability"                             NOVAL                                                                     "Pause ability, depends upon MAC.  "}\
    {AN_PAUSE                               true    true          INTEGER   0                     NOVAL                                     "SYNTH_AN"                false           "columns:10"  NOVAL           "Auto-Negotiation"                  "Pause ability"                                                ::altera_xcvr_10gkr_a10::parameters::validate_an_pause                    "Pause (C1:C0) is encoded in bits D11:D10 of base link codeword as per IEEE802.3 - 73.3.6."}\
    {AN_PAUSE_C0                            false   false         INTEGER   1                     NOVAL                                     "SYNTH_AN"                true            boolean       NOVAL           "Auto-Negotiation"                  "Pause ability-C0"                                             NOVAL                                                                     "C0 is same as PAUSE as defined in Annex 28B."}\
    {AN_PAUSE_C1                            false   false         INTEGER   1                     NOVAL                                     "SYNTH_AN"                true            boolean       NOVAL           "Auto-Negotiation"                  "Pause ability-C1"                                             NOVAL                                                                     "C1 is same asa ASM_DIR as defined in Annex 28B."}\
    {AN_TECH                                true    true          INTEGER   4                     NOVAL                                     true                      false           "columns:10"  NOVAL           "Auto-Negotiation"                  NOVAL                                                          ::altera_xcvr_10gkr_a10::parameters::validate_an_tech                     "Tech ability, only KR valid now // bit-0 = GigE, bit-1 = XAUI // bit-2 = 10G , bit-3 = 40G BP // bit 4 = 40G-CR4, bit 5 = 100G-CR10."}\
    {AN_FEC                                 false   false         INTEGER   0                     NOVAL                                     "SYNTH_AN"                false           "columns:10"  NOVAL           "Auto-Negotiation"                  "FEC Capability"                                               NOVAL                                                                     "FEC, bit1=request, bit0=ability."}\
    {AN_SELECTOR                            false   false         INTEGER   1                     NOVAL                                     "SYNTH_AN"                false           NOVAL         NOVAL           "Auto-Negotiation"                  "Selector field"                                               NOVAL                                                                     "AN selector field 802.3 = 5'd1."}\
    \
    \
    {SYNTH_1588_10G                         true    true          INTEGER   0                     NOVAL                                     true                      false           boolean       NOVAL           "10GBASE-R"                         "Enable IEEE 1588 Precision Time Protocol"                     NOVAL                                                                     "Enable IEEE 1588 PTP logic."}\
    {REF_CLK_FREQ_10G                       false   true          STRING    "644.53125"           {"644.53125" "322.265625"}                true                      true            NOVAL         MHz             "10GBASE-R"                         "Reference clock frequency"                                    NOVAL                                                                     "PLL Reference clock frequency for 10GbE PLL."}\
    {XGMII_32BIT_MODE                       false   true          INTEGER   0                     NOVAL                                     true                      false           boolean       NOVAL           "10GBASE-R"                         "Enable the 32-bit mode for the XGMII interface"               NOVAL                                                                     "Enable the 32-bit mode for the XGMII interface."}\
    {OPTIONAL_10G                           false   false         INTEGER   1                     NOVAL                                     true                      true            boolean       NOVAL           "10GBASE-R"                         "Enable additional control and status ports"                   NOVAL                                                                     "Enables rx_block_lock and rx_hi_ber ports."}\
    {INI_DATAPATH                           false   true          STRING    "10G"                 {"10G" "1G"}                              true                      true            NOVAL         NOVAL           "General options"                   "Initial datapath"                                             ::altera_xcvr_10gkr_a10::parameters::validate_ini_dpath                   "This is initial or reset mode of the PHY. 1G data mode is only valid in \"1Gb/10Gb Ethernet\" IP variant."}\
    {SYNTH_RCFG                             false   true          INTEGER   1                     NOVAL                                     true                      true            boolean       NOVAL           "General options"                   "Enable internal PCS reconfiguration logic"                    ::altera_xcvr_10gkr_a10::parameters::validate_rcfg                        "Enable internal PCS reconfiguration logic."}\
    {SYNTH_1588_ALL                         false   false         INTEGER   0                     NOVAL                                     true                      true            boolean       NOVAL           "General options"                   "Enable IEEE 1588 Precision Time Protocol"                     ::altera_xcvr_10gkr_a10::parameters::validate_1588                        "Enable IEEE 1588 PTP logic."}\
    {OPTIONAL_TXPMA_CLK                     false   false         INTEGER   0                     NOVAL                                     true                      true            boolean       NOVAL           "General options"                   "Enable tx_pma_clkout port"                                    NOVAL                                                                     "Enables the tx_pma_clkout port. This clock port is common for 1GbE and 10GbE mode. Disabling it for 10GBASE-R will also affect 1GbE mode."}\
    {OPTIONAL_RXPMA_CLK                     false   false         INTEGER   0                     NOVAL                                     true                      true            boolean       NOVAL           "General options"                   "Enable rx_pma_clkout port"                                    NOVAL                                                                     "Enables the rx_pma_clkout port. This clock port is common for 1GbE and 10GbE mode. Disabling it for 10GBASE-R will also affect 1GbE mode."}\
    {OPTIONAL_TX_DIV33CLK                   false   false         INTEGER   0                     NOVAL                                     true                      true            boolean       NOVAL           "General options"                   "Enable tx_divclk port"                                        NOVAL                                                                     "Enables the tx_div33clk port. Recovered clock port is common for 1GbE and 10GbE mode. Disabling it for 10GBASE-R will also affect 1GbE mode."}\
    {OPTIONAL_RX_DIV33CLK                   false   false         INTEGER   0                     NOVAL                                     true                      true            boolean       NOVAL           "General options"                   "Enable rx_divclk port"                                        NOVAL                                                                     "Enables the rx_div33clk port. Recovered clock port is common for 1GbE and 10GbE mode. Disabling it for 10GBASE-R will also affect 1GbE mode."}\
    {OPTIONAL_TX_CLKOUT                     false   false         INTEGER   0                     NOVAL                                     true                      true            boolean       NOVAL           "General options"                   "Enable tx_clkout port"                                        NOVAL                                                                     "Enables the tx_clkout port. Recovered clock port is common for 1GbE and 10GbE mode. Disabling it for 10GBASE-R will also affect 1GbE mode. This will be 125 MHz in 1G mode and ~257 MHz in 10G mode."}\
    {OPTIONAL_RX_CLKOUT                     false   false         INTEGER   0                     NOVAL                                     true                      true            boolean       NOVAL           "General options"                   "Enable rx_clkout port"                                        NOVAL                                                                     "Enables the rx_clkout port. Recovered clock port is common for 1GbE and 10GbE mode. Disabling it for 10GBASE-R will also affect 1GbE mode. This will be 125 MHz in 1G mode and ~257 MHz in 10G mode."}\
    {CAPABLE_FEC                            false   true          INTEGER   1                     NOVAL                                     "SYNTH_FEC"               true            boolean       NOVAL           "FEC Options"                       "Set FEC_ability bit on power up or reset"                     NOVAL                                                                     "FEC ability bit power on value. This bit is defined in IEEE802.3ae - 45.2.1.84 register bit 1.170.0. Also referred in IEEE802.3ae - 73.6.5- F0"}\
    {ENABLE_FEC                             false   true          INTEGER   1                     NOVAL                                     "SYNTH_FEC"               true            boolean       NOVAL           "FEC Options"                       "Set FEC_Enable bit on power up or reset"                      NOVAL                                                                     "FEC enable bit power on value. This bit is defined in IEEE802.3ae - 45.2.1.85 register bit 1.171.0. Also referred in IEEE802.3ae - 73.6.5 as FEC requested bit-F1"}\
    {ERR_INDICATION                         false   true          INTEGER   1                     NOVAL                                     "SYNTH_FEC"               true            boolean       NOVAL           "FEC Options"                       "Set FEC_Error_Indication_ability bit on power up or reset"    NOVAL                                                                     "Error Indication bit power up value. This bit is defined in IEEE802.3ae - 45.2.1.84 register bit 1.170.1."}\
    {GOOD_PARITY                            false   true          INTEGER   4                     NOVAL                                     "SYNTH_FEC"               true            "columns:10"  NOVAL           "FEC Options"                       "Good parity counter threshold to achieve FEC block lock"      NOVAL                                                                     "Number of consecutive valid parity words to achieve FEC block lock. This should be 4 as per IEEE802.3ae - 74.10.2.1."}\
    {INVALD_PARITY                          false   true          INTEGER   8                     NOVAL                                     "SYNTH_FEC"               true            "columns:10"  NOVAL           "FEC Options"                       "Invalid parity counter threshold to lose FEC block lock"      NOVAL                                                                     "Number of consecutive invalid parity words to lose FEC block lock. This should be 8 as per IEEE802.3ae - 74.10.2.1."}\
    {OPTIONAL_FEC                           false   false         INTEGER   0                     NOVAL                                     "SYNTH_FEC"               false           boolean       NOVAL           "FEC Options"                       "Enable FEC status ports"                                      NOVAL                                                                     "Enables FEC block lock, tx_alignment, rx_parity_good ports."}\
  }

}

proc ::altera_xcvr_10gkr_a10::parameters::declare_parameters { {device_family "Arria 10"} } {
  variable display_items
  variable parameters
  ip_declare_parameters $parameters
  ip_declare_display_items $display_items
  
  set fams [::alt_xcvr::utils::device::list_s5_style_hssi_families]

  # Initialize device information (to allow sharing of this function across device families)
  ip_set "parameter.DEVICE_FAMILY.SYSTEM_INFO" DEVICE_FAMILY
  ip_set "parameter.DEVICE_FAMILY.DEFAULT_VALUE" $device_family
#  ip_set "parameter.DEVICE_FAMILY.ALLOWED_RANGES" $fams
  
}

proc ::altera_xcvr_10gkr_a10::parameters::validate {} {
  ip_validate_parameters
}


#******************************************************************************
#************************ Validation Callbacks ********************************


proc ::altera_xcvr_10gkr_a10::parameters::validate_synth_gmii {SYNTH_GMII_gui SYNTH_GIGE } {
if {[expr $SYNTH_GMII_gui & !$SYNTH_GIGE] } {
  ip_message warning "GMII mode cannot be turned on without turning on GIGE mode."
 }
  ip_set "parameter.SYNTH_GMII.value" [expr $SYNTH_GMII_gui & $SYNTH_GIGE] 
}

proc ::altera_xcvr_10gkr_a10::parameters::validate_synth_seq {SYNTH_SEQ SYNTH_AN SYNTH_LT } {

set legal_values [expr {$SYNTH_AN == 1 ? {1}
    : $SYNTH_LT == 1 ? {1}
    : {0 1} } ]

  auto_invalid_value_message error SYNTH_SEQ $SYNTH_SEQ $legal_values { SYNTH_SEQ }

}

proc ::altera_xcvr_10gkr_a10::parameters::validate_sgmii {SYNTH_GIGE SYNTH_1588_1G SYNTH_SGMII} {
if {[expr $SYNTH_GIGE & $SYNTH_1588_1G & !$SYNTH_SGMII]} {
  ip_message error "SGMII must be enabled when using IEEE 1588 Precision Time Protocol."
}
}

proc ::altera_xcvr_10gkr_a10::parameters::validate_rcfg { SYNTH_SEQ SYNTH_RCFG } {
if {[expr $SYNTH_SEQ & !$SYNTH_RCFG]} { 
  ip_message error "Internal PCS reconfiguration logic must be enabled when using Automatic Speed Detection."
 }	
}	


proc ::altera_xcvr_10gkr_a10::parameters::validate_ini_dpath { INI_DATAPATH SYNTH_SEQ SYNTH_RCFG SYNTH_GIGE} {

set allow_init_1g_seq [get_quartus_ini "altera_xcvr_10gbase_kr_arria10_init_1g_seq"]
if {$allow_init_1g_seq} {
} else {
   set path_1g [expr {$INI_DATAPATH == "1G" ? 1 : 0} ]
   
   if {[expr $path_1g & ($SYNTH_SEQ | $SYNTH_RCFG )]} {
    ip_message error "\"Automatic Speed Detection\" and \"Internal PCS reconfiguration logic\" must be turned off when using \"1G\" as initial data path."
   }	
   
   if {[expr $path_1g & !$SYNTH_GIGE]} {
    ip_message error "\"10M/100M/1Gb Ethernet protocol\" must be turned on when using \"1G\" as initial data path."
   }	
}   

}	
proc ::altera_xcvr_10gkr_a10::parameters::validate_1588 { SYNTH_1588_ALL } {
ip_set "parameter.SYNTH_1588_1G.value" $SYNTH_1588_ALL
ip_set "parameter.SYNTH_1588_10G.value" $SYNTH_1588_ALL

if { $SYNTH_1588_ALL} {
  ip_message info "1588 is turned on for both 1G and 10G mode."
 }
}

proc ::altera_xcvr_10gkr_a10::parameters::validate_synth_fec { SYNTH_FEC SYNTH_SEQ } {
 if {[expr $SYNTH_FEC & !$SYNTH_SEQ]} {
 ip_message error "Automatic speed detection must be enabled when using FEC."
 }

}


proc ::altera_xcvr_10gkr_a10::parameters::validate_mgmt_clk {SYNTH_SEQ SYNTH_AN SYNTH_LT } {

set legal_values [expr {$SYNTH_AN == 1 ? {1}
    : $SYNTH_LT == 1 ? {1}
    : {0 1} } ]
 [expr $AN_100G*32+ $AN_40GCR*16+ $AN_40GBP*8+ $AN_BASER*4+ $AN_XAUI*2+ $AN_GIGE*1  ]

  auto_invalid_value_message error SYNTH_SEQ $SYNTH_SEQ $legal_values { SYNTH_SEQ }

}
      
proc ::altera_xcvr_10gkr_a10::parameters::validate_dev_rev_16bit  {DEV_VERSION } {
 if { [expr $DEV_VERSION > 65535 ]} {
  ip_message error "DEV REVISION can range from 0x0000 to 0xFFFF."
  }
}
                   
proc ::altera_xcvr_10gkr_a10::parameters::validate_cl37aneg  {SYNTH_AN SYNTH_GIGE} {
set cl_37an true  
if {$SYNTH_AN} {
 set cl_37an false 
  }
ip_set "parameter.SYNTH_CL37ANEG.value" $cl_37an

if { [expr $SYNTH_AN && $SYNTH_GIGE] } {
ip_message info "When Auto-Negotiation is enabled, Clause-37 autonegotiation in gigabit ethernet will be disabled."
  }
}

proc ::altera_xcvr_10gkr_a10::parameters::validate_mgmt_clk_freq_valid {phy_mgmt_clk_freq } {
 set phy_mgmt_clk_freq_valid [check_if_double "phy_mgmt_clk_freq" $phy_mgmt_clk_freq "phy_mgmt_clk_freq_valid"]
 if {$phy_mgmt_clk_freq_valid} {
 set max_value  125 
 set min_value  100 
 set current_val $phy_mgmt_clk_freq
 set severity error 
 set field "phy-mgmt-clk"
 #out_of_range_message  $min_value $max_value $current_val $severity $field
 out_of_range_message  100 125 $current_val error  "phy-mgmt-clk" 0 ""
  }
}

proc ::altera_xcvr_10gkr_a10::parameters::validate_time_kr_valid {LINK_TIMER_KR } {
#check_if_double "LINK_TIMER_KR" $LINK_TIMER_KR "LINK_TIMER_KR_valid"
}

proc ::altera_xcvr_10gkr_a10::parameters::validate_time_kx_valid {LINK_TIMER_KX } {
#check_if_double "LINK_TIMER_KX" $LINK_TIMER_KX "LINK_TIMER_KX_valid"
}


proc ::altera_xcvr_10gkr_a10::parameters::validate_an_gige  { SYNTH_GIGE SYNTH_AN} {
ip_set "parameter.AN_GIGE.value" $SYNTH_GIGE
}

proc ::altera_xcvr_10gkr_a10::parameters::validate_an_tech  { AN_GIGE AN_XAUI AN_BASER AN_40GBP AN_40GCR AN_100G } {
ip_set "parameter.AN_TECH.value" [expr $AN_100G*32+ $AN_40GCR*16+ $AN_40GBP*8+ $AN_BASER*4+ $AN_XAUI*2+ $AN_GIGE*1  ]
}

proc ::altera_xcvr_10gkr_a10::parameters::validate_an_pause { AN_PAUSE_C0 AN_PAUSE_C1 } {
ip_set "parameter.AN_PAUSE.value" [expr $AN_PAUSE_C1*2+ $AN_PAUSE_C0*1  ]
}

proc ::altera_xcvr_10gkr_a10::parameters::validate_time_kr  {LINK_TIMER_KR phy_mgmt_clk_freq phy_mgmt_clk_freq_valid LINK_TIMER_KR_valid }  {
 set phy_mgmt_clk_freq_valid [check_if_double "phy_mgmt_clk_freq" $phy_mgmt_clk_freq "phy_mgmt_clk_freq_valid"]
 set LINK_TIMER_KR_valid [check_if_double "LINK_TIMER_KR" $LINK_TIMER_KR "LINK_TIMER_KR_valid"]
 if {[expr $phy_mgmt_clk_freq_valid && $LINK_TIMER_KR_valid]} {
 set min_val [expr 1000/$phy_mgmt_clk_freq]
 set max_val [expr 1000/$phy_mgmt_clk_freq*64]
 out_of_range_message $min_val $max_val $LINK_TIMER_KR error "Link Fail Time for KR" 0 ""
 out_of_range_message 500 510 $LINK_TIMER_KR warning "Link Fail Time for KR" 1 "The current Link Fail Timer for KR  value does not meet IEEE802.3ba specification. IEEE802.3ba specifies this timer value to be between 500mS and 510mS" 
 }
}

proc ::altera_xcvr_10gkr_a10::parameters::validate_lft_msb_kr  {LINK_TIMER_KR phy_mgmt_clk_freq phy_mgmt_clk_freq_valid LINK_TIMER_KR_valid }  {
 set phy_mgmt_clk_freq_valid [check_if_double "phy_mgmt_clk_freq" $phy_mgmt_clk_freq "phy_mgmt_clk_freq_valid"]
 set LINK_TIMER_KR_valid [check_if_double "LINK_TIMER_KR" $LINK_TIMER_KR "LINK_TIMER_KR_valid"]
 if {[expr $phy_mgmt_clk_freq_valid && $LINK_TIMER_KR_valid]} {
 set timer_calc [expr $LINK_TIMER_KR*$phy_mgmt_clk_freq/1000]
 set link_kr_round_off [expr {double(round(1000*$timer_calc))/1000}]
 set kr_link_msb [expr int($timer_calc) ]
 ip_set "parameter.LFT_R_MSB.value" $kr_link_msb
 }
}

proc ::altera_xcvr_10gkr_a10::parameters::validate_lft_lsb_kr  {LINK_TIMER_KR phy_mgmt_clk_freq phy_mgmt_clk_freq_valid LINK_TIMER_KR_valid }  {
 set phy_mgmt_clk_freq_valid [check_if_double "phy_mgmt_clk_freq" $phy_mgmt_clk_freq "phy_mgmt_clk_freq_valid"]
 set LINK_TIMER_KR_valid [check_if_double "LINK_TIMER_KR" $LINK_TIMER_KR "LINK_TIMER_KR_valid"]
 if {[expr $phy_mgmt_clk_freq_valid && $LINK_TIMER_KR_valid]} {
 set timer_calc [expr $LINK_TIMER_KR*$phy_mgmt_clk_freq/1000]
 set link_kr_round_off [expr {double(round(1000*$timer_calc))/1000}]
 set kr_link_msb [expr int($timer_calc) ]
 set kr_link_lsb [expr ($link_kr_round_off-$kr_link_msb)*1000 ]
ip_set "parameter.LFT_R_LSB.value" $kr_link_lsb
 }
}

proc ::altera_xcvr_10gkr_a10::parameters::validate_time_kx  {LINK_TIMER_KX phy_mgmt_clk_freq phy_mgmt_clk_freq_valid LINK_TIMER_KX_valid }  {
 set phy_mgmt_clk_freq_valid [check_if_double "phy_mgmt_clk_freq" $phy_mgmt_clk_freq "phy_mgmt_clk_freq_valid"]
 set LINK_TIMER_KX_valid [check_if_double "LINK_TIMER_KX" $LINK_TIMER_KX "LINK_TIMER_KX_valid"]
 if {[expr $phy_mgmt_clk_freq_valid && $LINK_TIMER_KX_valid]} {
 set min_val [expr 1000/$phy_mgmt_clk_freq]
 set max_val [expr 1000/$phy_mgmt_clk_freq*64]
 out_of_range_message $min_val $max_val $LINK_TIMER_KX error "Link Fail Time for KX" 0 ""
 out_of_range_message 40 50 $LINK_TIMER_KX warning "Link Fail Time for KX" 1 "The current Link Fail Timer for KX  value does not meet IEEE802.3ba specification. IEEE802.3ba specifies this timer value to be between 40ms and 50ms" 
 }
}

proc ::altera_xcvr_10gkr_a10::parameters::validate_lft_msb_kx  {LINK_TIMER_KX phy_mgmt_clk_freq phy_mgmt_clk_freq_valid LINK_TIMER_KX_valid }  {
 set phy_mgmt_clk_freq_valid [check_if_double "phy_mgmt_clk_freq" $phy_mgmt_clk_freq "phy_mgmt_clk_freq_valid"]
 set LINK_TIMER_KX_valid [check_if_double "LINK_TIMER_KX" $LINK_TIMER_KX "LINK_TIMER_KX_valid"]
 if {[expr $phy_mgmt_clk_freq_valid && $LINK_TIMER_KX_valid]} {
 set timer_calc [expr $LINK_TIMER_KX*$phy_mgmt_clk_freq/1000]
 set link_kx_round_off [expr {double(round(1000*$timer_calc))/1000}]
 set kx_link_msb [expr int($timer_calc) ]
 ip_set "parameter.LFT_X_MSB.value" $kx_link_msb
 }
}

proc ::altera_xcvr_10gkr_a10::parameters::validate_lft_lsb_kx  {LINK_TIMER_KX phy_mgmt_clk_freq phy_mgmt_clk_freq_valid LINK_TIMER_KX_valid }  {
 set phy_mgmt_clk_freq_valid [check_if_double "phy_mgmt_clk_freq" $phy_mgmt_clk_freq "phy_mgmt_clk_freq_valid"]
 set LINK_TIMER_KX_valid [check_if_double "LINK_TIMER_KX" $LINK_TIMER_KX "LINK_TIMER_KX_valid"]
 if {[expr $phy_mgmt_clk_freq_valid && $LINK_TIMER_KX_valid]} {
 set timer_calc [expr $LINK_TIMER_KX*$phy_mgmt_clk_freq/1000]
 set link_kx_round_off [expr {double(round(1000*$timer_calc))/1000}]
 set kx_link_msb [expr int($timer_calc) ]
 set kx_link_lsb [expr ($link_kx_round_off-$kx_link_msb)*1000 ]
 ip_set "parameter.LFT_X_LSB.value" $kx_link_lsb
 }
}

proc ::altera_xcvr_10gkr_a10::parameters::validate_ref_clk_freq  {REF_CLK_FREQ_1G REF_CLK_FREQ_10G SYNTH_GIGE}  {
if {!$SYNTH_GIGE} {
  set ref_clk [concat $REF_CLK_FREQ_10G "MHz" ] 

 } else {
 set ref_clk [concat  $REF_CLK_FREQ_1G "MHz," $REF_CLK_FREQ_10G "MHz" ]
 } 
ip_set "parameter.ref_clk_freq.value" $ref_clk
}



proc ::altera_xcvr_10gkr_a10::parameters::chk_qii_ini { }  {
set unhide_val [get_quartus_ini "altera_xcvr_10gbase_kr_arria10_advanced"]
  if {$unhide_val} {
  ip_set "parameter.UNHIDE_ADV.value" "true"          
  } else {
  ip_set "parameter.UNHIDE_ADV.value" "false"         
  }	  
}

proc ::altera_xcvr_10gkr_a10::parameters::validate_chk_backplane {sel_backplane_lineside}  {
if {$sel_backplane_lineside == "Backplane-KR"} {
  set sel_backplane_lineside_en "true"  
 } else {
  set sel_backplane_lineside_en "false"  
 }
ip_set "display_item.Auto-Negotiation.visible" $sel_backplane_lineside_en
ip_set "display_item.Link Training.visible" $sel_backplane_lineside_en
#ip_set "display_item.FEC Options.visible" $sel_backplane_lineside_en
ip_set "display_item.Main.visible" "false"

}

proc ::altera_xcvr_10gkr_a10::parameters::validate_main_tapwidth { DEVICE_FAMILY }  {
ip_set "parameter.MAINTAPWIDTH.value" 6
}

proc ::altera_xcvr_10gkr_a10::parameters::validate_post_tapwidth { DEVICE_FAMILY }  {
ip_set "parameter.POSTTAPWIDTH.value" 6
}

proc ::altera_xcvr_10gkr_a10::parameters::validate_pre_tapwidth { DEVICE_FAMILY }  {
ip_set "parameter.PRETAPWIDTH.value" 5
}

proc ::altera_xcvr_10gkr_a10::parameters::validate_pll_lck { OPTIONAL_PLL_LCK }  {
if {!$OPTIONAL_PLL_LCK} {
ip_message info "PLL lock port is common for 1GbE and 10GbE mode. Disabling it for 10GBASE-R will also affect 1GbE mode."
 }
}

                          
proc ::altera_xcvr_10gkr_a10::parameters::calc_trn_ctr_width { TRNWTWIDTH_gui }  {
if {$TRNWTWIDTH_gui==127} {
 ip_set "parameter.TRNWTWIDTH.value" 7
} else {
 ip_set "parameter.TRNWTWIDTH.value" 8
}            
}
                          
proc ::altera_xcvr_10gkr_a10::parameters::calc_ber_ctr_width { BERWIDTH_gui }  {
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
 } else {
 ip_set "parameter.BERWIDTH.value" 10
 }            
}        

proc ::altera_xcvr_10gkr_a10::parameters::validate_vmaxrule { VMAXRULE }  {
out_of_range_message  0 63 $VMAXRULE  error  "VMAXRULE" 1 "Current value of VMAXRULE is not valid. 0 &lt; VMAXRULE &lt; 63."  
out_of_range_message  0 60 $VMAXRULE  warning "VMAXRULE" 1 "Recommended VMAXRULE values is 60 to meet IEEE specification of 1200 mV."  
}    

proc ::altera_xcvr_10gkr_a10::parameters::validate_vminrule { VMAXRULE VMINRULE }  {
out_of_range_message  0   $VMAXRULE $VMINRULE  error  "VMINRULE" 1 "Current value of VMINRULE is not valid. 0 &lt; VMINRULE &lt; VMAXRULE &lt; 63."  
}    

proc ::altera_xcvr_10gkr_a10::parameters::validate_vodrule { VMAXRULE VMINRULE VODMINRULE }  {
out_of_range_message  $VMINRULE $VMAXRULE $VODMINRULE  error  "VODMINRULE" 1 "Current value of VODMINRULE is not valid. VMINRULE &lt; VODMINRULE &lt; VMAXRULE."  
out_of_range_message  22 63 $VODMINRULE  warning "VODMINRULE" 1 "Recommended VODMINRULE values is 22 or greater to meet IEEE specification of 440 mV."  
}    

proc ::altera_xcvr_10gkr_a10::parameters::validate_vpostrule { VPOSTRULE }  {
out_of_range_message 0 31 $VPOSTRULE  error  "VPOSTRULE" 0 ""  
}    

proc ::altera_xcvr_10gkr_a10::parameters::validate_vprerule { VPRERULE }  {
out_of_range_message 0 15 $VPRERULE  error  "VPRERULE" 0 ""  
}    

proc ::altera_xcvr_10gkr_a10::parameters::validate_premainrule { VMAXRULE VODMINRULE PREMAINVAL }  {
out_of_range_message $VODMINRULE $VMAXRULE $PREMAINVAL  error  "PREMAINVAL" 1 "Current value of PREMAINVAL is not valid. VODMIN &lt; PREMAINVAL &lt; VMAXRULE."  
}    

proc ::altera_xcvr_10gkr_a10::parameters::validate_prepostrule { VMINRULE PREMAINVAL PREPOSTVAL PREPREVAL }  {
set invalid1  [expr { $PREMAINVAL + [expr {0.25 * $PREPOSTVAL}] + [expr {0.25 * $PREPREVAL}] <= 70 ? {0} : {1} } ]
set invalid2  [expr { $PREMAINVAL - $PREPOSTVAL - $PREPREVAL >= $VMINRULE ? {0} : {1} } ]
if { [expr $invalid1 || $invalid2 ] } {
ip_message error "Current values for  PREMAINVAL, PREPOSTVAL, PREPREVAL are not correct. Follow \n  PREMAINVAL + 0.25*PREPOSTVAL + 0.25*PREPREVAL &lt;= 70 \n PREMAINVAL - PREPOSTVAL - PREPREVAL >= VMINRULE."
 } 
if { [expr  $PREPOSTVAL ||  $PREPREVAL ] } {
   ip_message warning "Recommended IEEE values for PREPOSTVAL, and PREPREVAL are zero."
   }
}    

proc ::altera_xcvr_10gkr_a10::parameters::validate_initmainrule { VMAXRULE VODMINRULE INITMAINVAL }  {
out_of_range_message $VODMINRULE $VMAXRULE $INITMAINVAL  error  "INITMAINVAL" 1 "Current value of INITMAINVAL is not valid. VODMIN &lt; INITMAINVAL &lt; VMAXRULE."  
}   

proc ::altera_xcvr_10gkr_a10::parameters::validate_initprepostrule { VMINRULE VPOSTRULE INITMAINVAL INITPOSTVAL INITPREVAL }  {
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
#************************ Validation Callbacks ********************************
#******************************************************************************



#******************************************************************************
#************************* Internal messaging procedures **********************

proc ::altera_xcvr_10gkr_a10::parameters::out_of_range_message {min_val max_val current_val severity field customized c_message} {

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


proc ::altera_xcvr_10gkr_a10::parameters::check_if_double {to_check_name to_check_val to_set} {
set is_valid 1
  if {![string is double $to_check_val]} {
    ip_message error "[ip_get "parameter.$to_check_name.display_name"] is improperly formatted. Should be ###.##."
    set is_valid 0
  }
  #ip_set "parameter.$to_set.value" $is_valid
  return  $is_valid
}
#*********************** End internal messaging procedures ********************
#******************************************************************************




