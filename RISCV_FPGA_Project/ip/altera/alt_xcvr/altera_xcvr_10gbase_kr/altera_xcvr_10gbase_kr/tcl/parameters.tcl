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


package provide altera_xcvr_10gbase_kr::parameters 12.0

package require alt_xcvr::ip_tcl::ip_module
package require alt_xcvr::ip_tcl::messages
package require alt_xcvr::gui::pll_reconfig
package require alt_xcvr::gui::messages
package require alt_xcvr::utils::device
package require alt_xcvr::utils::rbc

namespace eval ::altera_xcvr_10gbase_kr::parameters:: {
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

  set package_name "altera_xcvr_10gbase_kr::parameters"

  set display_items {\
    {NAME                         GROUP                 TYPE  ARGS  }\
    {"Main"                       ""                    GROUP tab   }\
    {"Ethernet MegaCore Type"     ""                    GROUP NOVAL }\
    {"10GBASE-R"                  ""                    GROUP tab   }\
    {"1 Gb Ethernet"              ""                    GROUP tab   }\
    {"Speed Detection"            ""                    GROUP tab   }\
    {"Auto-Negotiation"           ""                    GROUP tab   }\
    {"Link Training"              ""                    GROUP tab   }\
    {"FEC Options"                "10GBASE-R"           GROUP NOVAL }\
    {"PMA parameters"             "Link Training"       GROUP NOVAL }\
  }
    
  set parameters {\
    {NAME                                   DERIVED HDL_PARAMETER TYPE      DEFAULT_VALUE         ALLOWED_RANGES                                         ENABLED                   VISIBLE         DISPLAY_HINT  DISPLAY_UNITS   DISPLAY_ITEM                        DISPLAY_NAME                                                   VALIDATION_CALLBACK                                                       DESCRIPTION }\
    {DEVICE_FAMILY                          true    true          STRING    "Stratix V"           {"Stratix V" "Arria V GZ"}                             true                      false           NOVAL         NOVAL           NOVAL                               NOVAL                                                          NOVAL                                                                     NOVAL}\
    {UNHIDE_FEC                             true    false         STRING    "false"               NOVAL                                                  true                      false           NOVAL         NOVAL           NOVAL                               NOVAL                                                          ::altera_xcvr_10gbase_kr::parameters::chk_qii_ini                         NOVAL}\
    {sel_backplane_lineside                 false   false         STRING    "1Gb/10Gb Ethernet"   {"1Gb/10Gb Ethernet" "Backplane-KR"}                   true                      true            NOVAL         NOVAL           "Ethernet MegaCore Type"            "IP variant"                                                    NOVAL                                                                     "Select between Backplane KR or LineSide."}\
    {chk_backplane                          true    false         INTEGER   0                     NOVAL                                                  true                      false           NOVAL         NOVAL           NOVAL                               NOVAL                                                          ::altera_xcvr_10gbase_kr::parameters::validate_chk_backplane              NOVAL                                          }\
    \
    {SYNTH_FEC                              false   true          INTEGER   0                     NOVAL                                                  true                      "UNHIDE_FEC"    boolean       NOVAL           "FEC Options"                       "Include FEC sublayer"                                         ::altera_xcvr_10gbase_kr::parameters::validate_synth_fec                  "This will include FEC logic for Backplane -Clause 74 implementation. Applicable only for 10G in Backplane mode."}\
    {SYNTH_AN                               false   true          INTEGER   0                     NOVAL                                                  true                      true            boolean       NOVAL           "Auto-Negotiation"                  "Enable Auto-Negotiation"                                      NOVAL                                                                     "This will include Auto-Negotiatiation for Backplane -Clause 73 implementation."}\
    {SYNTH_LT                               false   true          INTEGER   0                     NOVAL                                                  true                      true            boolean       NOVAL           "Link Training"                     "Enable Link Training"                                         NOVAL                                                                     "When you turn this option On, the core includes the link training module which allows the remote link-partner TX PMD for the lowest Bit Error Rate (BER). LT is defined in Clause 72 of IEEE Std 802.3ap-2007."}\
    {SYNTH_SEQ                              false   true          INTEGER   1                     NOVAL                                                  true                      true            boolean       NOVAL           "Speed Detection"                   "Enable automatic speed detection"                             ::altera_xcvr_10gbase_kr::parameters::validate_synth_seq                  "This module controls the link-up sequence for reconfiguration into and out of the AN, LT and data modes of the 10GBASE-KR PHY IP Core. The interface to the Reconfiguration Design Example transmits reconfiguration requests."}\
    {SYNTH_GIGE                             false   true          INTEGER   1                     NOVAL                                                  true                      true            boolean       NOVAL           "1 Gb Ethernet"                     "Enable 1 Gb Ethernet protocol"                                NOVAL                                                                     "Enables GMII interface and related logic."}\
    {SYNTH_GMII_gui                         false   false         INTEGER   1                     NOVAL                                                  "SYNTH_GIGE"              false           boolean       NOVAL           "1 Gb Ethernet"                     "Enable GMII PCS"                                              NOVAL                                                                     "Synthesize/include the GMII PCS."}\
    {SYNTH_GMII                             true    true          INTEGER   1                     NOVAL                                                  true                      false           boolean       NOVAL           "1 Gb Ethernet"                     "Enable GMII PCS"                                              NOVAL                                                                     "Synthesize/include the GMII PCS."}\
    {SYNTH_SGMII                            false   true          INTEGER   1                     NOVAL                                                  "SYNTH_GIGE"              false           boolean       NOVAL           "1 Gb Ethernet"                     "Enable SGMII bridge logic"                                    ::altera_xcvr_10gbase_kr::parameters::validate_sgmii                      "Turn on this option to add the SGMII clock and rate-adaptation logic to the PCS block. If your application only requires 1000BASE-X PCS, turning off this option reduces resource usage."}\
    {SYNTH_MII                              false   false         INTEGER   0                     NOVAL                                                  "SYNTH_GIGE"              true            boolean       NOVAL           "1 Gb Ethernet"                     "Expose MII interface"                                         NOVAL                                                                     "Enables MII interface."}\
    {SYNTH_1588_1G                          false   true          INTEGER   0                     NOVAL                                                  "SYNTH_GIGE"              true            boolean       NOVAL           "1 Gb Ethernet"                     "Enable IEEE 1588 Precision Time Protocol"                     NOVAL                                                                     "Enable IEEE 1588 PTP logic."}\
    {HIGH_PRECISION_LATADJ                  false   true          INTEGER   1                     NOVAL                                                  true                      false           boolean       NOVAL           NOVAL                               "Enable High Precision IEEE 1588 latency measurement"          NOVAL                                                                     "Turn this off to eliminate extra representation bits introduced for latency_adj port."}\
    {LATADJ_WIDTH_1G_gui                    true    false         INTEGER   22                    NOVAL                                                  true                      false           NOVAL         NOVAL           NOVAL                               NOVAL                                                          ::altera_xcvr_10gbase_kr::parameters::calc_latadj_1g_width                "Latency adjustment port width (1G)."}\
    {LATADJ_WIDTH_10G_gui                   true    false         INTEGER   16                    NOVAL                                                  true                      false           NOVAL         NOVAL           NOVAL                               NOVAL                                                          ::altera_xcvr_10gbase_kr::parameters::calc_latadj_10g_width               "Latency adjustment port width (10G)."}\
    {PHY_IDENTIFIER                         false   true          INTEGER   0                     NOVAL                                                  "SYNTH_GIGE"              true            hexadecimal   NOVAL           "1 Gb Ethernet"                     "PHY ID (32 bits)"                                             NOVAL                                                                     "This is a 32-bit value, which may constitute a unique identifier for a particular type of PCS. The identifier is the concatenation of the following elements: the 3rd-24th bits of the Organizationally Unique Identifier (OUI) assigned to the device manufacturer by the IEEE, a 6-bit model number, and a 4-bit revision number. A PCS may return a value of zero in each of the 32 bits of the PCS device identifier."}\
    {DEV_VERSION                            false   true          INTEGER   0                     NOVAL                                                  "SYNTH_GIGE"              true            hexadecimal   NOVAL           "1 Gb Ethernet"                     "PHY core version (16 bits)"                                   ::altera_xcvr_10gbase_kr::parameters::validate_dev_rev_16bit              "This is a 32-bit value, which may constitute a unique identifier for a particular type of PCS. The identifier is the concatenation of the following elements: the 3rd-24th bits of the Organizationally Unique Identifier (OUI) assigned to the device manufacturer by the IEEE, a 6-bit model number, and a 4-bit revision number. A PCS may return a value of zero in each of the 32 bits of the PCS device identifier."}\
    {SYNTH_CL37ANEG                         true    true          INTEGER   1                     NOVAL                                                  "SYNTH_GIGE"              false           NOVAL         NOVAL           NOVAL                               NOVAL                                                          ::altera_xcvr_10gbase_kr::parameters::validate_cl37aneg                   NOVAL}\
    {REF_CLK_FREQ_1G                        false   true          STRING    "125.00 MHz"          {"125.00 MHz" "62.50 MHz"}                             "SYNTH_GIGE"              true            NOVAL         NOVAL           "1 Gb Ethernet"                     "Reference clock frequency"                                    NOVAL                                                                     "PLL Reference clock frequency for 1GbE PLL."}\
    {PLL_TYPE_1G                            false   true          STRING    "CMU"                 {"CMU" "ATX" "fPLL"}                                   "SYNTH_GIGE"              true            NOVAL         NOVAL           "1 Gb Ethernet"                     "PLL type"                                                     NOVAL                                                                     "Selects between CMU/ATX PLL or fPLL for 1GbE."}\
    \
    {phy_mgmt_clk_freq                      false   false         STRING    "125.00"              NOVAL                                                  "SYNTH_SEQ"               true            "columns:10"  NOVAL           "Speed Detection"                   "Avalon-MM clock frequency"                                    NOVAL                                                                     "Specifies the frequency of the Avalon-MM clock. The  range is 100-125 MHz. The link inhibit timer uses this frequency in calculating counter values."}\
    {phy_mgmt_clk_freq_valid                true    false         INTEGER   1                     NOVAL                                                  true                      false           NOVAL         NOVAL           NOVAL                               NOVAL                                                          ::altera_xcvr_10gbase_kr::parameters::validate_mgmt_clk_freq_valid        NOVAL}\
    {LINK_TIMER_KR_valid                    true    false         INTEGER   1                     NOVAL                                                  true                      false           NOVAL         NOVAL           NOVAL                               NOVAL                                                          NOVAL                                                                     NOVAL}\
    {LINK_TIMER_KR                          false   false         STRING    504.00                NOVAL                                                  "SYNTH_SEQ"               true            "columns:10"  ms              "Speed Detection"                   "Link fail inhibit time for 10Gb Ethernet"                     ::altera_xcvr_10gbase_kr::parameters::validate_time_kr                    "Timer for qualifying a link_status=FAIL indication or a link_status=OK indication when a specific technology link is first being established."}\
    {LINK_TIMER_KX_valid                    true    false         INTEGER   1                     NOVAL                                                  true                      false           NOVAL         NOVAL           NOVAL                               NOVAL                                                          NOVAL                                                                     NOVAL}\
    {LINK_TIMER_KX                          false   false         STRING    48.00                 NOVAL                                                  "SYNTH_SEQ"               true            "columns:10"  ms              "Speed Detection"                   "Link fail inhibit time for 1Gb Ethernet"                      ::altera_xcvr_10gbase_kr::parameters::validate_time_kx                    "Timer for qualifying a link_status=FAIL indication or a link_status=OK indication when a specific technology link is first being established."}\
    {LFT_R_MSB                              true    true          INTEGER   63                    NOVAL                                                  true                      false           NOVAL         NOVAL           "Speed Detection"                   NOVAL                                                          ::altera_xcvr_10gbase_kr::parameters::validate_lft_msb_kr                 "Link Fail Timer MSB for BASE-R PCS."}\
    {LFT_R_LSB                              true    true          INTEGER   0                     NOVAL                                                  true                      false           NOVAL         NOVAL           "Speed Detection"                   NOVAL                                                          ::altera_xcvr_10gbase_kr::parameters::validate_lft_lsb_kr                 "Link Fail Timer lsb for BASE-R PCS."}\
    {LFT_X_MSB                              true    true          INTEGER   6                     NOVAL                                                  true                      false           NOVAL         NOVAL           "Speed Detection"                   NOVAL                                                          ::altera_xcvr_10gbase_kr::parameters::validate_lft_msb_kx                 "Link Fail Timer MSB for BASE-X PCS."}\
    {LFT_X_LSB                              true    true          INTEGER   0                     NOVAL                                                  true                      false           NOVAL         NOVAL           "Speed Detection"                   NOVAL                                                          ::altera_xcvr_10gbase_kr::parameters::validate_lft_lsb_kx                 "Link Fail Timer lsb for BASE-X PCS."}\
    \
    {OPTIONAL_DM                            false   false         INTEGER   0                     NOVAL                                                  "SYNTH_LT"                true            boolean       NOVAL           "Link Training"                     "Enable daisy chain mode"                                      NOVAL                                                                     "When you turn this option On, the core includes software for non-standard link configurations where the TX and RX interfaces connect to different link partners. This mode overrides the TX adaptation algorithm."}\
    {OPTIONAL_UP                            false   false         INTEGER   0                     NOVAL                                                  "SYNTH_LT"                true            boolean       NOVAL           "Link Training"                     "Enable microprocessor interface"                              NOVAL                                                                     "When you turn this option On, the core includes a microprocessor interface which enables the microprocessor mode for link training."}\
    {OPTIONAL_RXEQ                          false   true          INTEGER   0                     NOVAL                                                  "SYNTH_LT"                true            boolean       NOVAL           "Link Training"                     "Enable RX equalization"                                       NOVAL                                                                     "Turning this option on, will allow the link training algorithm to adjust the RX Equalization via dfe_xxx and ctle_xxx ports on the PHY."}\
    {BERWIDTH_gui                           false   false         INTEGER   4095                  {15 31 63 127 255 511 1023 2047 4095 8191 16383}       "SYNTH_LT"                true            NOVAL         NOVAL           "Link Training"                     "Maximum bit error count"                                      NOVAL                                                                     "Specifies the expected number of bit errors for the error counter expected during each step of the link training. If the number of errors exceeds this number for each step, the core returns an error. The number of errors depends upon the amount of time for each step and the quality of the physical link media."}\
    {BERWIDTH                               true    true          INTEGER   12                    {4 5 6 7 8 9 10 11 12 13 14}                           "SYNTH_LT"                false           NOVAL         NOVAL           "Link Training"                     "Bit error counter width"                                      ::altera_xcvr_10gbase_kr::parameters::calc_ber_ctr_width                  NOVAL}\
    {TRNWTWIDTH_gui                         false   false         INTEGER   127                   {127 255}                                              "SYNTH_LT"                true            NOVAL         NOVAL           "Link Training"                     "Number of frames to send before sending actual data"          NOVAL                                                                     "This timer is started when local receiver is trained and detects that the remote receiver is ready to receive data. The local PMD will deliver wait_timer additional training frames to ensure that the link partner correctly detects the local receiver state."}\
    {TRNWTWIDTH                             true    true          INTEGER   NOVAL                 NOVAL                                                  "SYNTH_LT"                false           NOVAL         NOVAL           "Link Training"                     NOVAL                                                          ::altera_xcvr_10gbase_kr::parameters::calc_trn_ctr_width                  NOVAL}\
    {MAINTAPWIDTH                           true    true          INTEGER   6                     NOVAL                                                  "SYNTH_LT"                false           "columns:10"  NOVAL           "Link Training"                     NOVAL                                                          ::altera_xcvr_10gbase_kr::parameters::validate_main_tapwidth              "Width of the Main Tap control."}\
    {POSTTAPWIDTH                           true    true          INTEGER   5                     NOVAL                                                  "SYNTH_LT"                false           "columns:10"  NOVAL           "Link Training"                     NOVAL                                                          ::altera_xcvr_10gbase_kr::parameters::validate_post_tapwidth              "Width of the Post Tap control."}\
    {PRETAPWIDTH                            true    true          INTEGER   4                     NOVAL                                                  "SYNTH_LT"                false           "columns:10"  NOVAL           "PMA parameters"                    NOVAL                                                          ::altera_xcvr_10gbase_kr::parameters::validate_pre_tapwidth               "Width of the Pre Tap control."}\
    {VMAXRULE                               false   true          INTEGER   60                    NOVAL                                                  "SYNTH_LT"                true            "columns:10"  NOVAL           "PMA parameters"                    NOVAL                                                          ::altera_xcvr_10gbase_kr::parameters::validate_vmaxrule                   "Specifies the maximum VOD. The default value is 60 which represents 1200 mV."}\
    {VMINRULE                               false   true          INTEGER   9                     NOVAL                                                  "SYNTH_LT"                true            "columns:10"  NOVAL           "PMA parameters"                    NOVAL                                                          ::altera_xcvr_10gbase_kr::parameters::validate_vminrule                   "Specifies the minimum VOD. The default value is 9 which represents 165 mV."}\
    {VODMINRULE                             false   true          INTEGER   24                    NOVAL                                                  "SYNTH_LT"                true            "columns:10"  NOVAL           "PMA parameters"                    NOVAL                                                          ::altera_xcvr_10gbase_kr::parameters::validate_vodrule                    "Specifies the minimum VOD for the first tap. The default value is 22 which represents 440mV."}\
    {VPOSTRULE                              false   true          INTEGER   31                    NOVAL                                                  "SYNTH_LT"                true            "columns:10"  NOVAL           "PMA parameters"                    NOVAL                                                          ::altera_xcvr_10gbase_kr::parameters::validate_vpostrule                  "Specifies the maximum value that the internal algorithm for pre-emphasis will ever test in determining the optimum post-tap setting. The default value is 25."}\
    {VPRERULE                               false   true          INTEGER   15                    NOVAL                                                  "SYNTH_LT"                true            "columns:10"  NOVAL           "PMA parameters"                    NOVAL                                                          ::altera_xcvr_10gbase_kr::parameters::validate_vprerule                   "Specifies the maximum value that the internal algorithm for pre-emphasis will ever test in determining the optimum pre-tap setting. The default value is 15."}\
    {PREMAINVAL                             false   true          INTEGER   60                    NOVAL                                                  "SYNTH_LT"                true            "columns:10"  NOVAL           "PMA parameters"                    NOVAL                                                          ::altera_xcvr_10gbase_kr::parameters::validate_premainrule                "Specifies the Preset VOD Value. Set by the Preset command as defined in Clause 72.6.10.2.3.1 of the link training protocol. This is the value from which the algorithm starts. The default value is 60.Preset Main tap value."}\
    {PREPOSTVAL                             false   true          INTEGER   0                     NOVAL                                                  "SYNTH_LT"                true            "columns:10"  NOVAL           "PMA parameters"                    NOVAL                                                          NOVAL                                                                     "Specifies the preset Post-tap value. The default value is 0."}\
    {PREPREVAL                              false   true          INTEGER   0                     NOVAL                                                  "SYNTH_LT"                true            "columns:10"  NOVAL           "PMA parameters"                    NOVAL                                                          ::altera_xcvr_10gbase_kr::parameters::validate_prepostrule                "Specifies the preset Pre-tap Value. The default value is 0."}\
    {INITMAINVAL                            false   true          INTEGER   52                    NOVAL                                                  "SYNTH_LT"                true            "columns:10"  NOVAL           "PMA parameters"                    NOVAL                                                          ::altera_xcvr_10gbase_kr::parameters::validate_initmainrule               "Specifies the Initial VOD Value. Set by the Initialize command in Clause 72.6.10.2.3.2 of the link training protocol. The default value is 35."}\
    {INITPOSTVAL                            false   true          INTEGER   30                    NOVAL                                                  "SYNTH_LT"                true            "columns:10"  NOVAL           "PMA parameters"                    NOVAL                                                          NOVAL                                                                     "Specifies the initial t Post-tap value. The default value is 14."}\
    {INITPREVAL                             false   true          INTEGER   5                     NOVAL                                                  "SYNTH_LT"                true            "columns:10"  NOVAL           "PMA parameters"                    NOVAL                                                          ::altera_xcvr_10gbase_kr::parameters::validate_initprepostrule            "Specifies the Initial Pre-tap Value. The default value is 3."}\
    \
    {AN_GIGE                                true    false         INTEGER   0                     NOVAL                                                  "SYNTH_AN"                false           boolean       NOVAL           "Auto-Negotiation"                  "1000 BASE-KX Technology Ability"                              ::altera_xcvr_10gbase_kr::parameters::validate_an_gige                    "Pause ability, depends upon MAC.  "}\
    {AN_XAUI                                false   false         INTEGER   0                     NOVAL                                                  "SYNTH_AN"                false           boolean       NOVAL           "Auto-Negotiation"                  "10GBASE-KX4 Technology Ability"                               NOVAL                                                                     "Pause ability, depends upon MAC.  "}\
    {AN_BASER                               false   false         INTEGER   1                     NOVAL                                                  "SYNTH_AN"                false           boolean       NOVAL           "Auto-Negotiation"                  "10GBASE-KR Technology Ability"                                NOVAL                                                                     "Pause ability, depends upon MAC.  "}\
    {AN_40GBP                               false   false         INTEGER   0                     NOVAL                                                  "SYNTH_AN"                false           boolean       NOVAL           "Auto-Negotiation"                  "40GBASE-KR44 Technology Ability"                              NOVAL                                                                     "Pause ability, depends upon MAC.  "}\
    {AN_40GCR                               false   false         INTEGER   0                     NOVAL                                                  "SYNTH_AN"                false           boolean       NOVAL           "Auto-Negotiation"                  "40GBASE-CR4 Technology Ability"                               NOVAL                                                                     "Pause ability, depends upon MAC.  "}\
    {AN_100G                                false   false         INTEGER   0                     NOVAL                                                  "SYNTH_AN"                false           boolean       NOVAL           "Auto-Negotiation"                  "100GBASE-CR10 Technology Ability"                             NOVAL                                                                     "Pause ability, depends upon MAC.  "}\
    {AN_PAUSE                               true    true          INTEGER   0                     NOVAL                                                  "SYNTH_AN"                false           "columns:10"  NOVAL           "Auto-Negotiation"                  "Pause ability"                                                ::altera_xcvr_10gbase_kr::parameters::validate_an_pause                   "Pause (C1:C0) is encoded in bits D11:D10 of base link codeword as per IEEE802.3 - 73.3.6."}\
    {AN_PAUSE_C0                            false   false         INTEGER   1                     NOVAL                                                  "SYNTH_AN"                true            boolean       NOVAL           "Auto-Negotiation"                  "Pause ability-C0"                                             NOVAL                                                                     "C0 is same as PAUSE as defined in Annex 28B."}\
    {AN_PAUSE_C1                            false   false         INTEGER   1                     NOVAL                                                  "SYNTH_AN"                true            boolean       NOVAL           "Auto-Negotiation"                  "Pause ability-C1"                                             NOVAL                                                                     "C1 is same asa ASM_DIR as defined in Annex 28B."}\
    {AN_TECH                                true    true          INTEGER   4                     NOVAL                                                  true                      false           "columns:10"  NOVAL           "Auto-Negotiation"                  NOVAL                                                          ::altera_xcvr_10gbase_kr::parameters::validate_an_tech                    "Tech ability, only KR valid now // bit-0 = GigE, bit-1 = XAUI // bit-2 = 10G , bit-3 = 40G BP // bit 4 = 40G-CR4, bit 5 = 100G-CR10."}\
    {AN_FEC                                 false   false         INTEGER   0                     NOVAL                                                  "SYNTH_AN"                false           "columns:10"  NOVAL           "Auto-Negotiation"                  "FEC Capability"                                               NOVAL                                                                     "FEC, bit1=request, bit0=ability."}\
    {AN_SELECTOR                            false   false         INTEGER   1                     NOVAL                                                  "SYNTH_AN"                false           NOVAL         NOVAL           "Auto-Negotiation"                  "Selector field"                                               NOVAL                                                                     "AN selector field 802.3 = 5'd1."}\
    {PLL_CNT                                true    true          INTEGER   2                     NOVAL                                                  true                      false           NOVAL         NOVAL           NOVAL                               NOVAL                                                          ::altera_xcvr_10gbase_kr::parameters::validate_pll_cnt                    "This is needed as XCVR- to and from size will change with param."}\
    \
    \
    {SYNTH_1588_10G                         false   true          INTEGER   0                     NOVAL                                                  true                      NOVAL           boolean       NOVAL           "10GBASE-R"                         "Enable IEEE 1588 Precision Time Protocol"                     NOVAL                                                                     "Enable IEEE 1588 PTP logic."}\
    {REF_CLK_FREQ_10G                       false   true          STRING    "322.265625 MHz"      {"644.53125 MHz" "322.265625 MHz"}                     true                      true            NOVAL         MHz             "10GBASE-R"                         "Reference clock frequency"                                    NOVAL                                                                     "PLL Reference clock frequency for 10GbE PLL."}\
    {PLL_TYPE_10G                           false   true          STRING    "ATX"                 {"CMU" "ATX"}                                          true                      true            NOVAL         NOVAL           "10GBASE-R"                         "PLL type"                                                     ::altera_xcvr_10gbase_kr::parameters::validate_pll_type_10g               "Selects between CMU or ATX PLL for 10GbE."}\
    {EN_SYNC_E                              false   true          INTEGER   0                     NOVAL                                                  true                      true            boolean       NOVAL           "10GBASE-R"                         "Enable Sync-E support"                                        NOVAL                                                                     "Exposes seperate reference clock for CDR PLL and TX PLL."}\
    {OPTIONAL_10G                           false   false         INTEGER   1                     NOVAL                                                  true                      true            boolean       NOVAL           "10GBASE-R"                         "Enable additional control and status ports"                   NOVAL                                                                     "Enables rx_block_lock and rx_hi_ber ports."}\
    {OPTIONAL_10G_RCVD                      false   false         INTEGER   1                     NOVAL                                                  true                      true            boolean       NOVAL           "10GBASE-R"                         "Enable rx_recovered_clk port"                                 ::altera_xcvr_10gbase_kr::parameters::validate_rcvd_clk                   "Enables the rx_recovered_clk port."}\
    {OPTIONAL_PLL_LCK                       false   false         INTEGER   1                     NOVAL                                                  true                      true            boolean       NOVAL           "10GBASE-R"                         "Enable pll_locked status port"                                ::altera_xcvr_10gbase_kr::parameters::validate_pll_lck                    "Enables the pll_locked status  port."}\
    {CAPABLE_FEC                            false   true          INTEGER   1                     NOVAL                                                  "SYNTH_FEC"               "UNHIDE_FEC"    boolean       NOVAL           "FEC Options"                       "Set FEC_ability bit on power up/reset"                        NOVAL                                                                     "FEC ability bit power on value. This bit is defined in IEEE802.3ae - 45.2.1.84 register bit 1.170.0. Also referred in IEEE802.3ae - 73.6.5- F0"}\
    {ENABLE_FEC                             false   true          INTEGER   1                     NOVAL                                                  "SYNTH_FEC"               "UNHIDE_FEC"    boolean       NOVAL           "FEC Options"                       "Set FEC_Enable bit on power up/reset"                         NOVAL                                                                     "FEC enable bit power on value. This bit is defined in IEEE802.3ae - 45.2.1.85 register bit 1.171.0. Also referred in IEEE802.3ae - 73.6.5 as FEC requested bit-F1"}\
    {ERR_INDICATION                         false   true          INTEGER   1                     NOVAL                                                  "SYNTH_FEC"               "UNHIDE_FEC"    boolean       NOVAL           "FEC Options"                       "Set FEC_Error_Indication_ability bit on power up/reset"       NOVAL                                                                     "Error Indication bit power up value. This bit is defined in IEEE802.3ae - 45.2.1.84 register bit 1.170.1."}\
    {GOOD_PARITY                            false   true          INTEGER   4                     NOVAL                                                  "SYNTH_FEC"               "UNHIDE_FEC"    "columns:10"  NOVAL           "FEC Options"                       "Good parity counter threshold to achieve FEC block lock"      NOVAL                                                                     "Number of consecutive valid parity words to achieve FEC block lock. This should be 4 as per IEEE802.3ae - 74.10.2.1."}\
    {INVALD_PARITY                          false   true          INTEGER   8                     NOVAL                                                  "SYNTH_FEC"               "UNHIDE_FEC"    "columns:10"  NOVAL           "FEC Options"                       "Invalid parity counter threshold to lose FEC block lock"      NOVAL                                                                     "Number of consecutive invalid parity words to lose FEC block lock. This should be 8 as per IEEE802.3ae - 74.10.2.1."}\
    {OPTIONAL_FEC                           false   false         INTEGER   0                     NOVAL                                                  "SYNTH_FEC"               false           boolean       NOVAL           "FEC Options"                       "Enable FEC status ports"                                      NOVAL                                                                     "Enables FEC block lock, tx_alignment, rx_parity_good ports."}\
    {USE_M20K                               false   true          INTEGER   1                     NOVAL                                                  "SYNTH_FEC"               "UNHIDE_FEC"    boolean       NOVAL           "FEC Options"                       "Use M20K for FEC Buffer (if available)"                       NOVAL                                                                     "Allows Quartus to replace FEC buffer with M20K memory, saving resources"}\
    \
    {l_rcfg_interfaces                      true    false         INTEGER   0                     NOVAL                                                  true                      false           NOVAL         NOVAL           NOVAL               NOVAL          ::altera_xcvr_10gbase_kr::parameters::validate_l_rcfg_interfaces          NOVAL}\
    {l_rcfg_to_xcvr_width                   true    false         INTEGER   0                     NOVAL                                                  true                      false           NOVAL         NOVAL           NOVAL               NOVAL          ::altera_xcvr_10gbase_kr::parameters::validate_l_rcfg_to_xcvr_width       NOVAL}\
    {l_rcfg_from_xcvr_width                 true    false         INTEGER   0                     NOVAL                                                  true                      false           NOVAL         NOVAL           NOVAL               NOVAL          ::altera_xcvr_10gbase_kr::parameters::validate_l_rcfg_from_xcvr_width     NOVAL}\
  }

}

proc ::altera_xcvr_10gbase_kr::parameters::declare_parameters { {device_family "Stratix V"} } {
  variable display_items
  variable parameters
  ip_declare_parameters $parameters
  ip_declare_display_items $display_items
  
  set fams [::alt_xcvr::utils::device::list_s5_style_hssi_families]

  # Initialize device information (to allow sharing of this function across device families)
  ip_set "parameter.DEVICE_FAMILY.SYSTEM_INFO" DEVICE_FAMILY
  ip_set "parameter.DEVICE_FAMILY.DEFAULT_VALUE" $device_family
  ip_set "parameter.DEVICE_FAMILY.ALLOWED_RANGES" $fams
  
}

proc ::altera_xcvr_10gbase_kr::parameters::validate {} {
  ip_validate_parameters
}


#******************************************************************************
#************************ Validation Callbacks ********************************

proc ::altera_xcvr_10gbase_kr::parameters::validate_pll_cnt { SYNTH_GIGE } {
  set pll_cnt        1
  if {$SYNTH_GIGE} {
    incr pll_cnt
  }
  ip_set "parameter.PLL_CNT.value" $pll_cnt
}

proc ::altera_xcvr_10gbase_kr::parameters::validate_l_rcfg_interfaces { DEVICE_FAMILY PLL_CNT } {
  set l_netlist_plls 1
  if {$PLL_CNT == 2} {
    incr l_netlist_plls
  }
  ip_set "parameter.l_rcfg_interfaces.value" [::alt_xcvr::utils::device::get_reconfig_interface_count $DEVICE_FAMILY 1 $l_netlist_plls]
  ::alt_xcvr::gui::messages::reconfig_interface_message $DEVICE_FAMILY 1 $l_netlist_plls
}


proc ::altera_xcvr_10gbase_kr::parameters::validate_l_rcfg_to_xcvr_width { DEVICE_FAMILY l_rcfg_interfaces } {
   ip_set "parameter.l_rcfg_to_xcvr_width.value" [::alt_xcvr::utils::device::get_reconfig_to_xcvr_total_width $DEVICE_FAMILY $l_rcfg_interfaces]
}


proc ::altera_xcvr_10gbase_kr::parameters::validate_l_rcfg_from_xcvr_width { DEVICE_FAMILY l_rcfg_interfaces } {
  ip_set "parameter.l_rcfg_from_xcvr_width.value" [::alt_xcvr::utils::device::get_reconfig_from_xcvr_total_width $DEVICE_FAMILY $l_rcfg_interfaces]
}
 
proc ::altera_xcvr_10gbase_kr::parameters::validate_synth_gmii {SYNTH_GMII_gui SYNTH_GIGE } {
if {[expr $SYNTH_GMII_gui & !$SYNTH_GIGE] } {
  ip_message warning "GMII mode cannot be turned on without turning on GIGE mode."
 }
  ip_set "parameter.SYNTH_GMII.value" [expr $SYNTH_GMII_gui & $SYNTH_GIGE] 
}

proc ::altera_xcvr_10gbase_kr::parameters::validate_synth_seq {SYNTH_SEQ SYNTH_AN SYNTH_LT } {

set legal_values [expr {$SYNTH_AN == 1 ? {1}
    : $SYNTH_LT == 1 ? {1}
    : {0 1} } ]

  auto_invalid_value_message error SYNTH_SEQ $SYNTH_SEQ $legal_values { SYNTH_SEQ }

}

proc ::altera_xcvr_10gbase_kr::parameters::validate_sgmii {SYNTH_GIGE SYNTH_1588_1G SYNTH_SGMII} {
if {[expr $SYNTH_GIGE & $SYNTH_1588_1G & !$SYNTH_SGMII]} {
  ip_message error "SGMII must be enabled when using IEEE 1588 Precision Time Protocol."
}

}

proc ::altera_xcvr_10gbase_kr::parameters::validate_synth_fec { SYNTH_FEC SYNTH_SEQ SYNTH_1588_10G} {
 if {[expr $SYNTH_FEC & !$SYNTH_SEQ]} {
 ip_message error "Automatic speed detection must be enabled when using FEC."
 }
 if {[expr $SYNTH_FEC & $SYNTH_1588_10G]} {
 ip_message error "FEC with 1588 protocol is not supported. Disabled one of the function."
 }

}


proc ::altera_xcvr_10gbase_kr::parameters::validate_mgmt_clk {SYNTH_SEQ SYNTH_AN SYNTH_LT } {

set legal_values [expr {$SYNTH_AN == 1 ? {1}
    : $SYNTH_LT == 1 ? {1}
    : {0 1} } ]
 [expr $AN_100G*32+ $AN_40GCR*16+ $AN_40GBP*8+ $AN_BASER*4+ $AN_XAUI*2+ $AN_GIGE*1  ]

  auto_invalid_value_message error SYNTH_SEQ $SYNTH_SEQ $legal_values { SYNTH_SEQ }

}
      
proc ::altera_xcvr_10gbase_kr::parameters::validate_dev_rev_16bit  {DEV_VERSION } {
 if { [expr $DEV_VERSION > 65535 ]} {
  ip_message error "DEV REVISION can range from 0x0000 to 0xFFFF."
  }
}
                   
proc ::altera_xcvr_10gbase_kr::parameters::validate_cl37aneg  {SYNTH_AN SYNTH_GIGE} {
set cl_37an true  
if {$SYNTH_AN} {
 set cl_37an false 
  }
ip_set "parameter.SYNTH_CL37ANEG.value" $cl_37an

if { [expr $SYNTH_AN && $SYNTH_GIGE] } {
ip_message info "When Auto-Negotiation is enabled, Clause-37 autonegotiation in gigabit ethernet will be disabled."
  }
}

proc ::altera_xcvr_10gbase_kr::parameters::validate_mgmt_clk_freq_valid {phy_mgmt_clk_freq } {
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

proc ::altera_xcvr_10gbase_kr::parameters::validate_time_kr_valid {LINK_TIMER_KR } {
#check_if_double "LINK_TIMER_KR" $LINK_TIMER_KR "LINK_TIMER_KR_valid"
}

proc ::altera_xcvr_10gbase_kr::parameters::validate_time_kx_valid {LINK_TIMER_KX } {
#check_if_double "LINK_TIMER_KX" $LINK_TIMER_KX "LINK_TIMER_KX_valid"
}


proc ::altera_xcvr_10gbase_kr::parameters::validate_an_gige  { SYNTH_GIGE SYNTH_AN} {
ip_set "parameter.AN_GIGE.value" $SYNTH_GIGE
}

proc ::altera_xcvr_10gbase_kr::parameters::validate_an_tech  { AN_GIGE AN_XAUI AN_BASER AN_40GBP AN_40GCR AN_100G } {
ip_set "parameter.AN_TECH.value" [expr $AN_100G*32+ $AN_40GCR*16+ $AN_40GBP*8+ $AN_BASER*4+ $AN_XAUI*2+ $AN_GIGE*1  ]
}

proc ::altera_xcvr_10gbase_kr::parameters::validate_an_pause { AN_PAUSE_C0 AN_PAUSE_C1 } {
ip_set "parameter.AN_PAUSE.value" [expr $AN_PAUSE_C1*2+ $AN_PAUSE_C0*1  ]
}

proc ::altera_xcvr_10gbase_kr::parameters::validate_time_kr  {LINK_TIMER_KR phy_mgmt_clk_freq phy_mgmt_clk_freq_valid LINK_TIMER_KR_valid }  {
 set phy_mgmt_clk_freq_valid [check_if_double "phy_mgmt_clk_freq" $phy_mgmt_clk_freq "phy_mgmt_clk_freq_valid"]
 set LINK_TIMER_KR_valid [check_if_double "LINK_TIMER_KR" $LINK_TIMER_KR "LINK_TIMER_KR_valid"]
 if {[expr $phy_mgmt_clk_freq_valid && $LINK_TIMER_KR_valid]} {
 set min_val [expr 1000/$phy_mgmt_clk_freq]
 set max_val [expr 1000/$phy_mgmt_clk_freq*64]
 out_of_range_message $min_val $max_val $LINK_TIMER_KR error "Link Fail Time for KR" 0 ""
 out_of_range_message 500 510 $LINK_TIMER_KR warning "Link Fail Time for KR" 1 "The current Link Fail Timer for KR  value does not meet IEEE802.3ba specification. IEEE802.3ba specifies this timer value to be between 500mS and 510mS" 
 }
}

proc ::altera_xcvr_10gbase_kr::parameters::validate_lft_msb_kr  {LINK_TIMER_KR phy_mgmt_clk_freq phy_mgmt_clk_freq_valid LINK_TIMER_KR_valid }  {
 set phy_mgmt_clk_freq_valid [check_if_double "phy_mgmt_clk_freq" $phy_mgmt_clk_freq "phy_mgmt_clk_freq_valid"]
 set LINK_TIMER_KR_valid [check_if_double "LINK_TIMER_KR" $LINK_TIMER_KR "LINK_TIMER_KR_valid"]
 if {[expr $phy_mgmt_clk_freq_valid && $LINK_TIMER_KR_valid]} {
 set timer_calc [expr $LINK_TIMER_KR*$phy_mgmt_clk_freq/1000]
 set link_kr_round_off [expr {double(round(1000*$timer_calc))/1000}]
 set kr_link_msb [expr int($timer_calc) ]
 ip_set "parameter.LFT_R_MSB.value" $kr_link_msb
 }
}

proc ::altera_xcvr_10gbase_kr::parameters::validate_lft_lsb_kr  {LINK_TIMER_KR phy_mgmt_clk_freq phy_mgmt_clk_freq_valid LINK_TIMER_KR_valid }  {
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

proc ::altera_xcvr_10gbase_kr::parameters::validate_time_kx  {LINK_TIMER_KX phy_mgmt_clk_freq phy_mgmt_clk_freq_valid LINK_TIMER_KX_valid }  {
 set phy_mgmt_clk_freq_valid [check_if_double "phy_mgmt_clk_freq" $phy_mgmt_clk_freq "phy_mgmt_clk_freq_valid"]
 set LINK_TIMER_KX_valid [check_if_double "LINK_TIMER_KX" $LINK_TIMER_KX "LINK_TIMER_KX_valid"]
 if {[expr $phy_mgmt_clk_freq_valid && $LINK_TIMER_KX_valid]} {
 set min_val [expr 1000/$phy_mgmt_clk_freq]
 set max_val [expr 1000/$phy_mgmt_clk_freq*64]
 out_of_range_message $min_val $max_val $LINK_TIMER_KX error "Link Fail Time for KX" 0 ""
 out_of_range_message 40 50 $LINK_TIMER_KX warning "Link Fail Time for KX" 1 "The current Link Fail Timer for KX  value does not meet IEEE802.3ba specification. IEEE802.3ba specifies this timer value to be between 40ms and 50ms" 
 }
}

proc ::altera_xcvr_10gbase_kr::parameters::validate_lft_msb_kx  {LINK_TIMER_KX phy_mgmt_clk_freq phy_mgmt_clk_freq_valid LINK_TIMER_KX_valid }  {
 set phy_mgmt_clk_freq_valid [check_if_double "phy_mgmt_clk_freq" $phy_mgmt_clk_freq "phy_mgmt_clk_freq_valid"]
 set LINK_TIMER_KX_valid [check_if_double "LINK_TIMER_KX" $LINK_TIMER_KX "LINK_TIMER_KX_valid"]
 if {[expr $phy_mgmt_clk_freq_valid && $LINK_TIMER_KX_valid]} {
 set timer_calc [expr $LINK_TIMER_KX*$phy_mgmt_clk_freq/1000]
 set link_kx_round_off [expr {double(round(1000*$timer_calc))/1000}]
 set kx_link_msb [expr int($timer_calc) ]
 ip_set "parameter.LFT_X_MSB.value" $kx_link_msb
 }
}

proc ::altera_xcvr_10gbase_kr::parameters::validate_lft_lsb_kx  {LINK_TIMER_KX phy_mgmt_clk_freq phy_mgmt_clk_freq_valid LINK_TIMER_KX_valid }  {
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

proc ::altera_xcvr_10gbase_kr::parameters::validate_ref_clk_freq  {REF_CLK_FREQ_1G REF_CLK_FREQ_10G SYNTH_GIGE}  {
if {!$SYNTH_GIGE} {
  set ref_clk [concat $REF_CLK_FREQ_10G "MHz" ] 

 } else {
 set ref_clk [concat  $REF_CLK_FREQ_1G "MHz," $REF_CLK_FREQ_10G "MHz" ]
 } 
ip_set "parameter.ref_clk_freq.value" $ref_clk
}


proc ::altera_xcvr_10gbase_kr::parameters::validate_pll_type {PLL_TYPE_10G PLL_TYPE_1G SYNTH_GIGE}  {
if {!$SYNTH_GIGE} {
  set set_pll_type $PLL_TYPE_10G 

 } else {
 set set_pll_type [concat  $PLL_TYPE_1G,$PLL_TYPE_10G ]
 }
ip_set "parameter.pll_type.value" $set_pll_type
}

proc ::altera_xcvr_10gbase_kr::parameters::chk_qii_ini { }  {
set unhide_val [get_quartus_ini "altera_xcvr_10gbase_kr_support_fec_feature"]
  if {$unhide_val} {
  ip_set "parameter.UNHIDE_FEC.value" "true"          
  } else {
  ip_set "parameter.UNHIDE_FEC.value" "true"         
  }	  
}



proc ::altera_xcvr_10gbase_kr::parameters::validate_chk_backplane {sel_backplane_lineside}  {
if {$sel_backplane_lineside == "Backplane-KR"} {
  set sel_backplane_lineside_en "true"  
 } else {
  set sel_backplane_lineside_en "false"  
 }
ip_set "display_item.Auto-Negotiation.visible" $sel_backplane_lineside_en
ip_set "display_item.Link Training.visible" $sel_backplane_lineside_en
ip_set "display_item.FEC Options.visible" $sel_backplane_lineside_en
ip_set "display_item.Main.visible" "false"

}

proc ::altera_xcvr_10gbase_kr::parameters::validate_main_tapwidth { DEVICE_FAMILY }  {
ip_set "parameter.MAINTAPWIDTH.value" [expr { [::alt_xcvr::utils::device::has_s5_style_hssi $DEVICE_FAMILY] ? {6}
                                                                : {0} } ]
}

proc ::altera_xcvr_10gbase_kr::parameters::validate_post_tapwidth { DEVICE_FAMILY }  {
ip_set "parameter.POSTTAPWIDTH.value" [expr { [::alt_xcvr::utils::device::has_s5_style_hssi $DEVICE_FAMILY] ? {5}
                                                                : {0} } ]
}

proc ::altera_xcvr_10gbase_kr::parameters::validate_pre_tapwidth { DEVICE_FAMILY }  {
ip_set "parameter.PRETAPWIDTH.value" [expr { [::alt_xcvr::utils::device::has_s5_style_hssi $DEVICE_FAMILY] ? {4}
                                                                : {0} } ]
}

proc ::altera_xcvr_10gbase_kr::parameters::validate_pll_lck { OPTIONAL_PLL_LCK }  {
if {!$OPTIONAL_PLL_LCK} {
ip_message info "PLL lock port is common for 1GbE and 10GbE mode. Disabling it for 10GBASE-R will also affect 1GbE mode."
 }
}

proc ::altera_xcvr_10gbase_kr::parameters::validate_pll_type_10g { PLL_TYPE_10G }  {
if {$PLL_TYPE_10G == "CMU" } {
ip_message warning "It is recommended to use ATX PLL for 10GbE application as it is designed to improve jitter performance and achieves lower channel-to-channel skew."
 }
}
                          
proc ::altera_xcvr_10gbase_kr::parameters::validate_rcvd_clk { OPTIONAL_10G_RCVD }  {
if {!$OPTIONAL_10G_RCVD } {
ip_message info "Recovered clock port is common for 1GbE and 10GbE mode. Disabling it for 10GBASE-R will also affect 1GbE mode. This clock is used internally when Precision Time Protocol is enabled."
 }
}
                          
proc ::altera_xcvr_10gbase_kr::parameters::calc_trn_ctr_width { TRNWTWIDTH_gui }  {
if {$TRNWTWIDTH_gui==127} {
 ip_set "parameter.TRNWTWIDTH.value" 7
} else {
 ip_set "parameter.TRNWTWIDTH.value" 8
}            
}
                          
proc ::altera_xcvr_10gbase_kr::parameters::calc_ber_ctr_width { BERWIDTH_gui }  {
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

proc ::altera_xcvr_10gbase_kr::parameters::calc_latadj_10g_width { HIGH_PRECISION_LATADJ }  {
if {$HIGH_PRECISION_LATADJ} {
 ip_set "parameter.LATADJ_WIDTH_10G_gui.value" 16
 } else {
 ip_set "parameter.LATADJ_WIDTH_10G_gui.value" 12
 }            
}

proc ::altera_xcvr_10gbase_kr::parameters::calc_latadj_1g_width { HIGH_PRECISION_LATADJ }  {
if {$HIGH_PRECISION_LATADJ} {
 ip_set "parameter.LATADJ_WIDTH_1G_gui.value" 22
 } else {
 ip_set "parameter.LATADJ_WIDTH_1G_gui.value" 18
 }            
}

proc ::altera_xcvr_10gbase_kr::parameters::validate_vmaxrule { VMAXRULE }  {
out_of_range_message  0 63 $VMAXRULE  error  "VMAXRULE" 1 "Current value of VMAXRULE is not valid. 0 &lt; VMAXRULE &lt; 63."  
out_of_range_message  0 60 $VMAXRULE  warning "VMAXRULE" 1 "Recommended VMAXRULE values is 60 to meet IEEE specification of 1200 mV."  
}    

proc ::altera_xcvr_10gbase_kr::parameters::validate_vminrule { VMAXRULE VMINRULE }  {
out_of_range_message  0   $VMAXRULE $VMINRULE  error  "VMINRULE" 1 "Current value of VMINRULE is not valid. 0 &lt; VMINRULE &lt; VMAXRULE &lt; 63."  
}    

proc ::altera_xcvr_10gbase_kr::parameters::validate_vodrule { VMAXRULE VMINRULE VODMINRULE }  {
out_of_range_message  $VMINRULE $VMAXRULE $VODMINRULE  error  "VODMINRULE" 1 "Current value of VODMINRULE is not valid. VMINRULE &lt; VODMINRULE &lt; VMAXRULE."  
out_of_range_message  22 63 $VODMINRULE  warning "VODMINRULE" 1 "Recommended VODMINRULE values is 22 or greater to meet IEEE specification of 440 mV."  
}    

proc ::altera_xcvr_10gbase_kr::parameters::validate_vpostrule { VPOSTRULE }  {
out_of_range_message 0 31 $VPOSTRULE  error  "VPOSTRULE" 0 ""  
}    

proc ::altera_xcvr_10gbase_kr::parameters::validate_vprerule { VPRERULE }  {
out_of_range_message 0 15 $VPRERULE  error  "VPRERULE" 0 ""  
}    

proc ::altera_xcvr_10gbase_kr::parameters::validate_premainrule { VMAXRULE VODMINRULE PREMAINVAL }  {
out_of_range_message $VODMINRULE $VMAXRULE $PREMAINVAL  error  "PREMAINVAL" 1 "Current value of PREMAINVAL is not valid. VODMIN &lt; PREMAINVAL &lt; VMAXRULE."  
}    

proc ::altera_xcvr_10gbase_kr::parameters::validate_prepostrule { VMINRULE PREMAINVAL PREPOSTVAL PREPREVAL }  {
set invalid1  [expr { $PREMAINVAL + [expr {0.25 * $PREPOSTVAL}] + [expr {0.25 * $PREPREVAL}] <= 70 ? {0} : {1} } ]
set invalid2  [expr { $PREMAINVAL - $PREPOSTVAL - $PREPREVAL >= $VMINRULE ? {0} : {1} } ]
if { [expr $invalid1 || $invalid2 ] } {
ip_message error "Current values for  PREMAINVAL, PREPOSTVAL, PREPREVAL are not correct. Follow \n  PREMAINVAL + 0.25*PREPOSTVAL + 0.25*PREPREVAL &lt;= 70 \n PREMAINVAL - PREPOSTVAL - PREPREVAL >= VMINRULE."
 } 
if { [expr  $PREPOSTVAL ||  $PREPREVAL ] } {
   ip_message warning "Recommended IEEE values for PREPOSTVAL, and PREPREVAL are zero."
   }
}    

proc ::altera_xcvr_10gbase_kr::parameters::validate_initmainrule { VMAXRULE VODMINRULE INITMAINVAL }  {
out_of_range_message $VODMINRULE $VMAXRULE $INITMAINVAL  error  "INITMAINVAL" 1 "Current value of INITMAINVAL is not valid. VODMIN &lt; INITMAINVAL &lt; VMAXRULE."  
}   

proc ::altera_xcvr_10gbase_kr::parameters::validate_initprepostrule { VMINRULE VPOSTRULE INITMAINVAL INITPOSTVAL INITPREVAL }  {
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

proc ::altera_xcvr_10gbase_kr::parameters::out_of_range_message {min_val max_val current_val severity field customized c_message} {

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


proc ::altera_xcvr_10gbase_kr::parameters::check_if_double {to_check_name to_check_val to_set} {
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




