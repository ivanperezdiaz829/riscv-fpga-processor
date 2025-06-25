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


package provide altera_xcvr_native_sv::parameters 13.1

package require alt_xcvr::ip_tcl::ip_module
package require alt_xcvr::ip_tcl::messages
package require alt_xcvr::gui::messages
package require alt_xcvr::utils::device
package require alt_xcvr::utils::rbc
package require alt_xcvr::utils::common

namespace eval ::altera_xcvr_native_sv::parameters:: {
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

  set package_name "altera_xcvr_native_sv::parameters"

  set display_items {\
    {NAME                                         GROUP             TYPE  ARGS  }\
    {"General"                                    ""                GROUP NOVAL }\
    {"Datapath Options"                           ""                GROUP NOVAL }\
    {"PMA"                                        ""                GROUP tab   }\
    {"PMA Direct Options"                         "PMA"             GROUP NOVAL }\
    {"TX PLL Options"                             "PMA"             GROUP NOVAL }\
    {"TX PLL 0"                                   "TX PLL Options"  GROUP tab   }\
    {"TX PLL 1"                                   "TX PLL Options"  GROUP tab   }\
    {"TX PLL 2"                                   "TX PLL Options"  GROUP tab   }\
    {"TX PLL 3"                                   "TX PLL Options"  GROUP tab   }\
    {"RX CDR Options"                             "PMA"             GROUP NOVAL }\
    {"PMA Optional Ports"                         "PMA"             GROUP NOVAL }\
    {"Standard PCS"                               ""                GROUP tab   }\
    {"10G PCS"                                    ""                GROUP tab   }\
    \
    {"Phase Compensation FIFO"                    "Standard PCS"    GROUP NOVAL }\
    {"Byte Ordering"                              "Standard PCS"    GROUP NOVAL }\
    {"Byte Serializer and Deserializer"           "Standard PCS"    GROUP NOVAL }\
    {"8B/10B Encoder and Decoder"                 "Standard PCS"    GROUP NOVAL }\
    {"Rate Match FIFO"                            "Standard PCS"    GROUP NOVAL }\
    {"Word Aligner and Bitslip"                   "Standard PCS"    GROUP NOVAL }\
    {"Bit Reversal and Polarity Inversion"        "Standard PCS"    GROUP NOVAL }\
    {"PRBS Verifier"                              "Standard PCS"    GROUP NOVAL }\
    \
    {"10G TX FIFO"                                "10G PCS"         GROUP NOVAL }\
    {"10G RX FIFO"                                "10G PCS"         GROUP NOVAL }\
    {"Interlaken Frame Generator"                 "10G PCS"         GROUP NOVAL }\
    {"Interlaken Frame Sync"                      "10G PCS"         GROUP NOVAL }\
    {"Interlaken CRC-32 Generator and Checker"    "10G PCS"         GROUP NOVAL }\
    {"10GBASE-R BER Checker"                      "10G PCS"         GROUP NOVAL }\
    {"64b/66b Encoder and Decoder"                "10G PCS"         GROUP NOVAL }\
    {"Scrambler and Descrambler"                  "10G PCS"         GROUP NOVAL }\
    {"Interlaken Disparity Generator and Checker" "10G PCS"         GROUP NOVAL }\
    {"Block Sync"                                 "10G PCS"         GROUP NOVAL }\
    {"Gearbox"                                    "10G PCS"         GROUP NOVAL }\
    {"10G PRBS Verifier"                          "10G PCS"         GROUP NOVAL }\
  }
    
  set parameters {\
    {NAME                                   DERIVED HDL_PARAMETER TYPE      DEFAULT_VALUE                   ALLOWED_RANGES                                                            ENABLED                             VISIBLE                               DISPLAY_HINT  DISPLAY_UNITS DISPLAY_ITEM                                  DISPLAY_NAME                                            VALIDATION_CALLBACK                                                               M_CONTEXT DESCRIPTION }\
    {device_family                          false   false         STRING    "Stratix V"                     {"Stratix V"}                                                             true                                false                                 NOVAL         NOVAL         NOVAL                                         NOVAL                                                   NOVAL                                                                             NOVAL     NOVAL}\
    {show_advanced_features                 false   false         INTEGER   0                               NOVAL                                                                     false                               false                                 boolean       NOVAL         NOVAL                                         "Show advanced features"                                ::altera_xcvr_native_sv::parameters::validate_show_advanced_features              NOVAL     NOVAL}\
    \
    {device_speedgrade                      false   false         STRING    "fastest"                       NOVAL                                                                     true                                true                                  NOVAL         NOVAL         "General"                                     "Device speed grade"                                    NOVAL                                                                             NOVAL     "Specifies the desired device speedgrade. This information is used for data rate validation."}
    {message_level                          false   false         STRING    "error"                         {error warning}                                                           true                                true                                  NOVAL         NOVAL         "General"                                     "Message level for rule violations"                     NOVAL                                                                             NOVAL     "Specifies the messaging level to use for parameter rule violations. Selecting \"error\" will cause all rule violations to prevent IP generation. Selecting \"warning\" will display all rule violations as warnings and will allow IP generation in spite of violations."}\
    \
    {tx_enable                              false   true          INTEGER   1                               NOVAL                                                                     true                                true                                  boolean       NOVAL         "Datapath Options"                            "Enable TX datapath"                                    NOVAL                                                                             NOVAL     "When selected, the core includes the TX (transmit) datapath."}\
    {rx_enable                              false   true          INTEGER   1                               NOVAL                                                                     true                                true                                  boolean       NOVAL         "Datapath Options"                            "Enable RX datapath"                                    ::altera_xcvr_native_sv::parameters::validate_rx_enable                           NOVAL     "When selected, the core includes the RX (receive) datapath"}\
    {enable_std                             false   true          INTEGER   0                               NOVAL                                                                     true                                true                                  boolean       NOVAL         "Datapath Options"                            "Enable Standard PCS"                                   ::altera_xcvr_native_sv::parameters::validate_enable_std                          NOVAL     "Enables the 'Standard PCS' datapath. The transceiver contains two seperate PCS datapaths (Standard and 10G). This option must be enabled if you intend to statically use the 'Standard PCS' or if you intend to dynamically switch between the standard and 10G PCS. The 'pma_direct' datapath cannot be used when this option is enabled and dynamic reconfiguration between 'pma_direct' and PCS modes is not supported by the device. Refer to the device handbook for details on features supported by the 'Standard PCS'."}\
    {enable_teng                            false   true          INTEGER   0                               NOVAL                                                                     true                                true                                  boolean       NOVAL         "Datapath Options"                            "Enable 10G PCS"                                        ::altera_xcvr_native_sv::parameters::validate_enable_teng                         NOVAL     "Enables the 10G PCS datapath. The transceiver contains two seperate PCS datapaths (Standard and 10G). This option must be enabled if you intend to statically use the 10G PCS or if you intend to dynamically switch between the standard and 10G PCS. The 'pma_direct' datapath cannot be used when this option is enabled and dynamic reconfiguration between 'pma_direct' and PCS modes is not supported by the device. Refer to the device handbook for details on features supported by the 10G PCS."}\
    {set_data_path_select                   false   false         STRING    "standard"                      {standard 10G}                                                            "enable_std && enable_teng"         true                                  NOVAL         NOVAL         "Datapath Options"                            "Initial PCS datapath selection"                        NOVAL                                                                             NOVAL     "Specifies the initial datapath for this configuration of the core. When performing dynamic reconfiguration between multiple PCS paths, it is necessary to specify which datapath is initially selected for the current configuration.\n'standard':Selects the 'Standard PCS' as the initially selected datapath.\n'10G':Selects the 10G PCS as the initially selected datapath."}\
    {data_path_select                       true    true          STRING    "pma_direct"                    {pma_direct standard 10G}                                                 true                                false                                 NOVAL         NOVAL         "Datapath Options"                            NOVAL                                                   ::altera_xcvr_native_sv::parameters::validate_data_path_select                    NOVAL     NOVAL}\
    {channels                               false   true          INTEGER   1                               NOVAL                                                                     true                                true                                  NOVAL         NOVAL         "Datapath Options"                            "Number of data channels"                               NOVAL                                                                             NOVAL     "Specifies the total number of data channels."}\
    {bonded_mode                            false   true          STRING    "non_bonded"                    {"non_bonded:non_bonded" "xN:x6/xN" "fb_compensation:fb_compensation"}    tx_enable                           tx_enable                             NOVAL         NOVAL         "Datapath Options"                            "Bonding mode"                                          NOVAL                                                                             NOVAL     "Specifies the bonding mode to control channel-to-channel skew for the TX datapath. Refer to the device handbook for bonding details. 'non_bonded':TX channels will be not be bonded (no skew control). 'x6/xN':TX channels will be bonded using x6/xN bonding. 'fb_compensation': TX channels will be bonded using feedback compensation bonding."}\
    {enable_simple_interface                false   false         INTEGER   0                               NOVAL                                                                     true                                true                                  boolean       NOVAL         "Datapath Options"                            "Enable simplified data interface"                      ::altera_xcvr_native_sv::parameters::validate_enable_simple_interface             NOVAL     "When selected, the IP will present a simplified data and control interface between the FPGA and transceiver. When not selected, the IP will present the full raw data interface to the transceiver. You will need to understand the mapping of data and control signals within the interface. This option cannot be enabled if you want to perform dynamic interface reconfiguration as only a fixed subset of the data and control signals will be provided."}\
    \
    {set_data_rate                          false   false         STRING    "1250"                          NOVAL                                                                     true                                true                                  "columns:10"  Mbps          "PMA"                                         "Data rate"                                             ::altera_xcvr_native_sv::parameters::validate_set_data_rate                       NOVAL     "Specifies the transceiver data rate in units of Mbps (megabits per second)."}\
    {data_rate                              true    true          STRING    NOVAL                           NOVAL                                                                     true                                false                                 NOVAL         NOVAL         NOVAL                                         NOVAL                                                   ::altera_xcvr_native_sv::parameters::validate_data_rate                           NOVAL     NOVAL}\
    {pma_width                              true    true          INTEGER   80                              NOVAL                                                                     true                                false                                 NOVAL         NOVAL         "PMA"                                         "PCS / PMA interface width"                             ::altera_xcvr_native_sv::parameters::validate_pma_width                           NOVAL     NOVAL}\
    {pma_direct_width                       false   false         INTEGER   80                              {8 10 16 20 32 40 64 80}                                                  true                                true                                  NOVAL         NOVAL         "PMA Direct Options"                          "PMA direct interface width"                            ::altera_xcvr_native_sv::parameters::validate_pma_direct_width                    NOVAL     "Specifies the width of the datapath that connects the FPGA fabric to the PMA for 'pma_direct' mode."}\
    {tx_pma_clk_div                         false   true          INTEGER   1                               {1 2 4 8}                                                                 tx_enable                           tx_enable                             NOVAL         NOVAL         "PMA"                                         "TX local clock division factor"                        NOVAL                                                                             NOVAL     "Specifies the TX serial clock division factor. The transceiver has the ability to further divide the TX serial clock from the TX PLL before use. This parameter specifies the division factor to use. Example: A PLL data rate of \"10000 Mbps\" and a local division factor of 8 will result in a channel data rate of \"1250 Mbps\""}\
    {tx_pma_txdetectrx_ctrl                 true    true          INTEGER   0                               NOVAL                                                                     true                                false                                 boolean       NOVAL         "PMA"                                         "Enable QPI ports"                                      ::altera_xcvr_native_sv::parameters::validate_tx_pma_txdetectrx_ctrl              NOVAL     NOVAL}\
    {base_data_rate                         true    false         STRING    "1250"                          NOVAL                                                                     tx_enable                           tx_enable                             "columns:10"  Mbps          "PMA"                                         "TX PLL base data rate"                                 ::altera_xcvr_native_sv::parameters::validate_base_data_rate                      NOVAL     "The calculated PLL base data rate (Date rate * local clock division factor). The configured base data rate for the selected TX PLL must match this value."}\
    {pll_reconfig_enable                    false   true          INTEGER   0                               NOVAL                                                                     "tx_enable && !pll_external_enable" tx_enable                             boolean       NOVAL         "TX PLL Options"                              "Enable TX PLL dynamic reconfiguration"                 NOVAL                                                                             NOVAL     "Enabling this option has two effects: 1-The simulation model for the TX PLL will include support for dynamic reconfiguration. 2-Quartus will not merge the TX PLLs by default. Merging can be manually controlled through QSF assignments. Dynamic reconfiguration includes reference clock switching and data rate reconfiguration."}\
    {pll_external_enable                    false   true          INTEGER   0                               NOVAL                                                                     tx_enable                           tx_enable                             boolean       NOVAL         "TX PLL Options"                              "Use external TX PLL"                                   ::altera_xcvr_native_sv::parameters::validate_pll_external_enable                 NOVAL     "When selected, the IP core will not include the TX PLL(s). The IP core will instead expose the ext_pll_clk port for connection to an external TX PLL."}\
    {pll_data_rate                          true    true          STRING    "0 Mbps"                        NOVAL                                                                     true                                false                                 NOVAL         NOVAL         NOVAL                                         NOVAL                                                   ::altera_xcvr_native_sv::parameters::validate_pll_data_rate                       NOVAL     NOVAL}\
    {pll_type                               true    true          STRING    "CMU"                           NOVAL                                                                     true                                false                                 NOVAL         NOVAL         NOVAL                                         NOVAL                                                   ::altera_xcvr_native_sv::parameters::validate_pll_type                            NOVAL     NOVAL}\
    {pll_network_select                     true    true          STRING    "x1"                            NOVAL                                                                     true                                false                                 NOVAL         NOVAL         NOVAL                                         NOVAL                                                   ::altera_xcvr_native_sv::parameters::validate_pll_network_select                  NOVAL     NOVAL}\
    {plls                                   false   true          INTEGER   1                               {1 2 3 4}                                                                 tx_enable                           tx_enable                             NOVAL         NOVAL         "TX PLL Options"                              "Number of TX PLLs"                                     ::altera_xcvr_native_sv::parameters::validate_plls                                NOVAL     "Specifies the desired number of TX PLLs to use for dynamic PLL switching. The number of logical TX PLLs created in the netlist depends on the number of channels and selected TX bonding method."}\
    {pll_select                             false   true          INTEGER   0                               {0}                                                                       tx_enable                           tx_enable                             NOVAL         NOVAL         "TX PLL Options"                              "Main TX PLL logical index"                             ::altera_xcvr_native_sv::parameters::validate_pll_select                          NOVAL     "Specifies the initially selected TX PLL."}\
    {pll_refclk_cnt                         false   true          INTEGER   1                               {1 2 3 4 5}                                                               "tx_enable && !pll_external_enable" "tx_enable && !pll_external_enable"   NOVAL         NOVAL         "TX PLL Options"                              "Number of TX PLL reference clocks"                     NOVAL                                                                             NOVAL     "Specifies the number of input reference clocks for the TX PLLs. The same bus of reference clocks will feed all TX PLLs in the netlist."}\
    {pll_refclk_select                      true    true          STRING    "0"                             NOVAL                                                                     true                                false                                 NOVAL         NOVAL         NOVAL                                         NOVAL                                                   ::altera_xcvr_native_sv::parameters::validate_pll_refclk_select                   NOVAL     NOVAL}\
    {pll_refclk_freq                        true    true          STRING    "125.0 MHz"                     NOVAL                                                                     true                                false                                 NOVAL         NOVAL         NOVAL                                         NOVAL                                                   ::altera_xcvr_native_sv::parameters::validate_pll_refclk_freq                     NOVAL     NOVAL}\
    {pll_feedback_path                      true    true          STRING    "internal"                      {internal external}                                                       true                                false                                 NOVAL         NOVAL         "TX PLL Options"                              NOVAL                                                   NOVAL                                                                             NOVAL     NOVAL}\
    \
    {gui_pll_reconfig_pll0_pll_type         false   false         STRING    "CMU"                           {"CMU" "ATX"}                                                             true                                true                                  NOVAL         NOVAL         "TX PLL 0"                                    "PLL type"                                             ::altera_xcvr_native_sv::parameters::validate_gui_pll_reconfig_pll_pll_type        0         "Selects the type of this TX PLL."}\
    {gui_pll_reconfig_pll1_pll_type         false   false         STRING    "CMU"                           {"CMU" "ATX"}                                                             true                                true                                  NOVAL         NOVAL         "TX PLL 1"                                    "PLL type"                                             ::altera_xcvr_native_sv::parameters::validate_gui_pll_reconfig_pll_pll_type        1         "Selects the type of this TX PLL."}\
    {gui_pll_reconfig_pll2_pll_type         false   false         STRING    "CMU"                           {"CMU" "ATX"}                                                             true                                true                                  NOVAL         NOVAL         "TX PLL 2"                                    "PLL type"                                             ::altera_xcvr_native_sv::parameters::validate_gui_pll_reconfig_pll_pll_type        2         "Selects the type of this TX PLL."}\
    {gui_pll_reconfig_pll3_pll_type         false   false         STRING    "CMU"                           {"CMU" "ATX"}                                                             true                                true                                  NOVAL         NOVAL         "TX PLL 3"                                    "PLL type"                                             ::altera_xcvr_native_sv::parameters::validate_gui_pll_reconfig_pll_pll_type        3         "Selects the type of this TX PLL."}\
    \
    {gui_pll_reconfig_pll0_data_rate        false   false         STRING    "1250 Mbps"                     NOVAL                                                                     true                                true                                  NOVAL         NOVAL         "TX PLL 0"                                    "PLL base data rate"                                   ::altera_xcvr_native_sv::parameters::validate_gui_pll_reconfig_pll_data_rate       0         "Specifies the base data rate for this TX PLL. TX PLLs that require merging must share the same base data rate. A PLL's base data rate is the PLL output clock frequency multiplied by 2. The base data rate is specified in Mbps or Gbps."}\
    {gui_pll_reconfig_pll1_data_rate        false   false         STRING    "1250 Mbps"                     NOVAL                                                                     true                                true                                  NOVAL         NOVAL         "TX PLL 1"                                    "PLL base data rate"                                   ::altera_xcvr_native_sv::parameters::validate_gui_pll_reconfig_pll_data_rate       1         "Specifies the base data rate for this TX PLL. TX PLLs that require merging must share the same base data rate. A PLL's base data rate is the PLL output clock frequency multiplied by 2. The base data rate is specified in Mbps or Gbps."}\
    {gui_pll_reconfig_pll2_data_rate        false   false         STRING    "1250 Mbps"                     NOVAL                                                                     true                                true                                  NOVAL         NOVAL         "TX PLL 2"                                    "PLL base data rate"                                   ::altera_xcvr_native_sv::parameters::validate_gui_pll_reconfig_pll_data_rate       2         "Specifies the base data rate for this TX PLL. TX PLLs that require merging must share the same base data rate. A PLL's base data rate is the PLL output clock frequency multiplied by 2. The base data rate is specified in Mbps or Gbps."}\
    {gui_pll_reconfig_pll3_data_rate        false   false         STRING    "1250 Mbps"                     NOVAL                                                                     true                                true                                  NOVAL         NOVAL         "TX PLL 3"                                    "PLL base data rate"                                   ::altera_xcvr_native_sv::parameters::validate_gui_pll_reconfig_pll_data_rate       3         "Specifies the base data rate for this TX PLL. TX PLLs that require merging must share the same base data rate. A PLL's base data rate is the PLL output clock frequency multiplied by 2. The base data rate is specified in Mbps or Gbps."}\
    \
    {gui_pll_reconfig_pll0_data_rate_der    true    false         STRING    NOVAL                           NOVAL                                                                     true                                true                                  NOVAL         NOVAL         "TX PLL 0"                                    "PLL base data rate"                                   ::altera_xcvr_native_sv::parameters::validate_gui_pll_reconfig_pll_data_rate_der   0         "Specifies the base data rate for this TX PLL. TX PLLs that require merging must share the same base data rate. A PLL's base data rate is the PLL output clock frequency multiplied by 2. The base data rate is specified in Mbps or Gbps."}\
    {gui_pll_reconfig_pll1_data_rate_der    true    false         STRING    NOVAL                           NOVAL                                                                     true                                true                                  NOVAL         NOVAL         "TX PLL 1"                                    "PLL base data rate"                                   ::altera_xcvr_native_sv::parameters::validate_gui_pll_reconfig_pll_data_rate_der   1         "Specifies the base data rate for this TX PLL. TX PLLs that require merging must share the same base data rate. A PLL's base data rate is the PLL output clock frequency multiplied by 2. The base data rate is specified in Mbps or Gbps."}\
    {gui_pll_reconfig_pll2_data_rate_der    true    false         STRING    NOVAL                           NOVAL                                                                     true                                true                                  NOVAL         NOVAL         "TX PLL 2"                                    "PLL base data rate"                                   ::altera_xcvr_native_sv::parameters::validate_gui_pll_reconfig_pll_data_rate_der   2         "Specifies the base data rate for this TX PLL. TX PLLs that require merging must share the same base data rate. A PLL's base data rate is the PLL output clock frequency multiplied by 2. The base data rate is specified in Mbps or Gbps."}\
    {gui_pll_reconfig_pll3_data_rate_der    true    false         STRING    NOVAL                           NOVAL                                                                     true                                true                                  NOVAL         NOVAL         "TX PLL 3"                                    "PLL base data rate"                                   ::altera_xcvr_native_sv::parameters::validate_gui_pll_reconfig_pll_data_rate_der   3          "Specifies the base data rate for this TX PLL. TX PLLs that require merging must share the same base data rate. A PLL's base data rate is the PLL output clock frequency multiplied by 2. The base data rate is specified in Mbps or Gbps."}\
    \
    {gui_pll_reconfig_pll0_refclk_freq      false   false         STRING    "125.0 MHz"                     NOVAL                                                                     true                                true                                  NOVAL         NOVAL         "TX PLL 0"                                    "Reference clock frequency"                            ::altera_xcvr_native_sv::parameters::validate_gui_pll_reconfig_pll_refclk_freq     0         "Selects the input reference clock frequency for this TX PLL and selected reference clock index."}\
    {gui_pll_reconfig_pll1_refclk_freq      false   false         STRING    "125.0 MHz"                     NOVAL                                                                     true                                true                                  NOVAL         NOVAL         "TX PLL 1"                                    "Reference clock frequency"                            ::altera_xcvr_native_sv::parameters::validate_gui_pll_reconfig_pll_refclk_freq     1         "Selects the input reference clock frequency for this TX PLL and selected reference clock index."}\
    {gui_pll_reconfig_pll2_refclk_freq      false   false         STRING    "125.0 MHz"                     NOVAL                                                                     true                                true                                  NOVAL         NOVAL         "TX PLL 2"                                    "Reference clock frequency"                            ::altera_xcvr_native_sv::parameters::validate_gui_pll_reconfig_pll_refclk_freq     2         "Selects the input reference clock frequency for this TX PLL and selected reference clock index."}\
    {gui_pll_reconfig_pll3_refclk_freq      false   false         STRING    "125.0 MHz"                     NOVAL                                                                     true                                true                                  NOVAL         NOVAL         "TX PLL 3"                                    "Reference clock frequency"                            ::altera_xcvr_native_sv::parameters::validate_gui_pll_reconfig_pll_refclk_freq     3         "Selects the input reference clock frequency for this TX PLL and selected reference clock index."}\
    \
    {gui_pll_reconfig_pll0_refclk_sel       false   false         STRING    "0"                             NOVAL                                                                     true                                true                                  NOVAL         NOVAL         "TX PLL 0"                                    "Selected reference clock source"                      ::altera_xcvr_native_sv::parameters::validate_gui_pll_reconfig_pll_refclk_sel      0         "Selects the input reference clock index for this TX PLL."}\
    {gui_pll_reconfig_pll1_refclk_sel       false   false         STRING    "0"                             NOVAL                                                                     true                                true                                  NOVAL         NOVAL         "TX PLL 1"                                    "Selected reference clock source"                      ::altera_xcvr_native_sv::parameters::validate_gui_pll_reconfig_pll_refclk_sel      1         "Selects the input reference clock index for this TX PLL."}\
    {gui_pll_reconfig_pll2_refclk_sel       false   false         STRING    "0"                             NOVAL                                                                     true                                true                                  NOVAL         NOVAL         "TX PLL 2"                                    "Selected reference clock source"                      ::altera_xcvr_native_sv::parameters::validate_gui_pll_reconfig_pll_refclk_sel      2         "Selects the input reference clock index for this TX PLL."}\
    {gui_pll_reconfig_pll3_refclk_sel       false   false         STRING    "0"                             NOVAL                                                                     true                                true                                  NOVAL         NOVAL         "TX PLL 3"                                    "Selected reference clock source"                      ::altera_xcvr_native_sv::parameters::validate_gui_pll_reconfig_pll_refclk_sel      3         "Selects the input reference clock index for this TX PLL."}\
    \
    {gui_pll_reconfig_pll0_clk_network      false   false         STRING    "x1"                            {"x1" "xN"}                                                               true                                true                                  NOVAL         NOVAL         "TX PLL 0"                                    "Selected clock network"                               ::altera_xcvr_native_sv::parameters::validate_gui_pll_reconfig_pll_clk_network     0         "Selects the clock network for this TX PLL."}\
    {gui_pll_reconfig_pll1_clk_network      false   false         STRING    "x1"                            {"x1" "xN"}                                                               true                                true                                  NOVAL         NOVAL         "TX PLL 1"                                    "Selected clock network"                               ::altera_xcvr_native_sv::parameters::validate_gui_pll_reconfig_pll_clk_network     1         "Selects the clock network for this TX PLL."}\
    {gui_pll_reconfig_pll2_clk_network      false   false         STRING    "x1"                            {"x1" "xN"}                                                               true                                true                                  NOVAL         NOVAL         "TX PLL 2"                                    "Selected clock network"                               ::altera_xcvr_native_sv::parameters::validate_gui_pll_reconfig_pll_clk_network     2         "Selects the clock network for this TX PLL."}\
    {gui_pll_reconfig_pll3_clk_network      false   false         STRING    "x1"                            {"x1" "xN"}                                                               true                                true                                  NOVAL         NOVAL         "TX PLL 3"                                    "Selected clock network"                               ::altera_xcvr_native_sv::parameters::validate_gui_pll_reconfig_pll_clk_network     3         "Selects the clock network for this TX PLL."}\
    \
    {cdr_reconfig_enable                    false   true          INTEGER   0                               NOVAL                                                                     rx_enable                           rx_enable                             boolean       NOVAL         "RX CDR Options"                              "Enable CDR dynamic reconfiguration"                    NOVAL                                                                             NOVAL     "When selected, the simulation model for the RX CDR will support dynamic reconfiguration. Dynamic reconfiguration includes data rate reconfiguration. This option is not required to simulate CDR reference clock switching."}\
    {cdr_refclk_cnt                         false   true          INTEGER   1                               {1 2 3 4 5}                                                               rx_enable                           rx_enable                             NOVAL         NOVAL         "RX CDR Options"                              "Number of CDR reference clocks"                        NOVAL                                                                             NOVAL     "Specifies the number of input reference clocks for the RX CDRs. The same bus of reference clocks will feed all RX CDRs in the netlist."}\
    {cdr_refclk_select                      false   true          INTEGER   0                               {0}                                                                       rx_enable                           rx_enable                             NOVAL         NOVAL         "RX CDR Options"                              "Selected CDR reference clock"                          ::altera_xcvr_native_sv::parameters::validate_cdr_refclk_select                   NOVAL     "Specifies the initially selected reference clock input to the RX CDRs."}\
    {cdr_refclk_freq                        true    true          STRING    NOVAL                           NOVAL                                                                     rx_enable                           false                                 NOVAL         NOVAL         NOVAL                                         NOVAL                                                   ::altera_xcvr_native_sv::parameters::validate_cdr_refclk_freq                     NOVAL     NOVAL}\
    {set_cdr_refclk_freq                    false   false         STRING    "125.0 MHz"                     NOVAL                                                                     rx_enable                           rx_enable                             NOVAL         NOVAL         "RX CDR Options"                              "Selected CDR reference clock frequency"                ::altera_xcvr_native_sv::parameters::validate_set_cdr_refclk_freq                 NOVAL     "Specifies the frequency in Mbps of the selected reference clock input to the CDR."}\
    {rx_ppm_detect_threshold                false   true          STRING    "1000"                          {62 100 125 200 250 300 500 1000}                                         rx_enable                           rx_enable                             NOVAL         PPM           "RX CDR Options"                              "PPM detector threshold"                                NOVAL                                                                             NOVAL     "Specifies the tolerable different in PPM between the RX CDR reference clock and the recovered clock from the RX data input."}\
    {enable_port_tx_pma_qpipullup           false   false         INTEGER   0                               NOVAL                                                                     tx_enable                           tx_enable                             boolean       NOVAL         "PMA Optional Ports"                          "Enable tx_pma_qpipullup port (QPI)"                    NOVAL                                                                             NOVAL     "Enables the tx_pma_qpipullup control input port. This port is used only in QPI applications."}\
    {enable_port_tx_pma_qpipulldn           false   false         INTEGER   0                               NOVAL                                                                     tx_enable                           tx_enable                             boolean       NOVAL         "PMA Optional Ports"                          "Enable tx_pma_qpipulldn port (QPI)"                    NOVAL                                                                             NOVAL     "Enables the tx_pma_qpipulldn control input port. This port is used only in QPI applications."}\
    {enable_port_tx_pma_txdetectrx          false   false         INTEGER   0                               NOVAL                                                                     tx_enable                           tx_enable                             boolean       NOVAL         "PMA Optional Ports"                          "Enable tx_pma_txdetectrx port (QPI)"                   NOVAL                                                                             NOVAL     "Enables the tx_pma_txdetectrx control input port. This port is used only in QPI applications. The receiver detect block in TX PMA is used to detect the presence of a receiver at the other end of the channel, after receiving tx_pma_txdetectrx request the receiver detect block initiates the detection process. "}\
    {enable_port_tx_pma_rxfound             false   false         INTEGER   0                               NOVAL                                                                     tx_enable                           tx_enable                             boolean       NOVAL         "PMA Optional Ports"                          "Enable tx_pma_rxfound port (QPI)"                      NOVAL                                                                             NOVAL     "Enables the tx_rxfound status output port. This port is used only in QPI applications. The receiver detect block in TX PMA is used to detect the presence of a receiver at the other end by using tx_pma_txdetectrx input,detection of RX status is given on the tx_pma_rxfound port."}\
    {enable_port_tx_pma_pclk                false   false         INTEGER   0                               NOVAL                                                                     tx_enable                           tx_enable                             boolean       NOVAL         "PMA Optional Ports"                          "Enable tx_pma_pclk port"                               NOVAL                                                                             NOVAL     "Enables the tx_pma_pclk clock port. This is the muxed clock output from the Standard and 10G TX PCS blocks. This port is only needed if you are dynamically switching between the Standard and 10G TX PCS datapaths and need the clock for both PCS paths available on the PCLK network. The PCLK output source will switch between the 8G and 10G clock sources dynamically. This port is not needed if you are only using one PCS or if you are using regular core routing for the 8G and 10G PCS clock outputs and have no need for PCLK."}\
    {enable_port_rx_pma_qpipulldn           false   false         INTEGER   0                               NOVAL                                                                     rx_enable                           rx_enable                             boolean       NOVAL         "PMA Optional Ports"                          "Enable rx_pma_qpipulldn port (QPI)"                    NOVAL                                                                             NOVAL     "Enables the rx_pma_qpipulldn control input port. This port is used only in QPI applications."}\
    {enable_port_rx_pma_clkout              false   false         INTEGER   1                               NOVAL                                                                     rx_enable                           rx_enable                             boolean       NOVAL         "PMA Optional Ports"                          "Enable rx_pma_clkout port"                             NOVAL                                                                             NOVAL     "Enables the rx_pma_clkout clock port. This is the recovered RX parallel clock from the RX PMA. This clock is typically used to clock the RX datapath when the transceiver is configured for pma_direct mode."}\
    {enable_port_rx_pma_pclk                false   false         INTEGER   0                               NOVAL                                                                     rx_enable                           rx_enable                             boolean       NOVAL         "PMA Optional Ports"                          "Enable rx_pma_pclk port"                               NOVAL                                                                             NOVAL     "Enables the rx_pma_pclk clock port. This is the muxed clock output from the Standard and 10G RX PCS blocks. This port is only needed if you are dynamically switching between the Standard and 10G RX PCS datapaths and need the clock for both PCS paths available on the PCLK network. The PCLK output source will switch between the 8G and 10G clock sources dynamically. This port is not needed if you are only using one PCS or if you are using regular core routing for the 8G and 10G PCS clock outputs and have no need for PCLK."}\
    {enable_port_rx_is_lockedtodata         false   false         INTEGER   1                               NOVAL                                                                     rx_enable                           rx_enable                             boolean       NOVAL         "PMA Optional Ports"                          "Enable rx_is_lockedtodata port"                        NOVAL                                                                             NOVAL     "Enables the optional rx_is_lockedtodata status output port. This signal indicates that the RX CDR is currently in lock to data mode or is attempting to lock to the incoming data stream. This is an asynchronous output signal."}\
    {enable_port_rx_is_lockedtoref          false   false         INTEGER   1                               NOVAL                                                                     rx_enable                           rx_enable                             boolean       NOVAL         "PMA Optional Ports"                          "Enable rx_is_lockedtoref port"                         NOVAL                                                                             NOVAL     "Enables the optional rx_is_lockedtoref status output port. This signal indicates that the RX CDR is currently locked to the CDR reference clock. This is an asynchronous output signal."}\
    {enable_ports_rx_manual_cdr_mode        false   false         INTEGER   1                               NOVAL                                                                     rx_enable                           rx_enable                             boolean       NOVAL         "PMA Optional Ports"                          "Enable rx_set_locktodata and rx_set_locktoref ports"   NOVAL                                                                             NOVAL     "Enables the optional rx_set_locktodata and rx_set_locktoref control input ports. These ports are used to manually control the lock mode of the RX CDR. These are asynchonous input signals."}\
    {rx_clkslip_enable                      false   true          INTEGER   0                               NOVAL                                                                     rx_enable                           rx_enable                             boolean       NOVAL         "PMA Optional Ports"                          "Enable rx_pma_bitslip port"                            NOVAL                                                                             NOVAL     "Enables the optional rx_pma_bitslip control input port. The deserializer slips one clock edge each time this signal is asserted. This is an asynchronous input signal."}\
    {enable_port_rx_signaldetect            false   false         INTEGER   0                               NOVAL                                                                     rx_enable                           false                                 boolean       NOVAL         "PMA Optional Ports"                          "Enable rx_signaldetect port"                           NOVAL                                                                             NOVAL     "Enables the optional rx_signaldetect status output port. The assertion of this signal indicates detection of an input signal to the RX PMA. Refer to the device handbook for applications and limitations. This is an asynchronous output signal."}\
    {enable_port_rx_seriallpbken            false   false         INTEGER   0                               NOVAL                                                                     true                                true                                  boolean       NOVAL         "PMA Optional Ports"                          "Enable rx_seriallpbken port"                           ::altera_xcvr_native_sv::parameters::validate_enable_port_rx_seriallpbken         NOVAL     "Enables the optional rx_seriallpbken control input port. The assertion of this signal enables the TX to RX serial loopback path within the transceiver. This is an asynchronous input signal."}\
    \
    {std_protocol_hint                      false   true          STRING    "basic"                         {basic cpri cpri_rx_tx gige srio_2p1}                                     enable_std                          enable_std                            NOVAL         NOVAL         "Standard PCS"                                "Standard PCS protocol mode"                            NOVAL                                                                             NOVAL     "Specifies the protocol mode for the current'Standard PCS' configuration. The protocol mode is used to govern the legal settings for parameters within the 'Standard PCS' datapath. Refer to the user guide for guidelines on which protocol mode to use for specific HSSI protocols."}\
    {std_pcs_pma_width                      false   true          INTEGER   10                              {8 10 16 20}                                                              enable_std                          enable_std                            NOVAL         NOVAL         "Standard PCS"                                "Standard PCS / PMA interface width"                    ::altera_xcvr_native_sv::parameters::validate_std_pcs_pma_width                   NOVAL     "Specifies the data interface width between the 'Standard PCS' and the transceiver PMA."}\
    {std_tx_pld_pcs_width                   true    false         INTEGER   NOVAL                           NOVAL                                                                     l_enable_tx_std                     l_enable_tx_std                       NOVAL         NOVAL         "Standard PCS"                                "FPGA fabric / Standard TX PCS interface width"         ::altera_xcvr_native_sv::parameters::validate_std_tx_pld_pcs_width                NOVAL     "Indicates the data inerface width between the Standard TX PCS and the FPGA fabric. This value is determined by the current configuration of individual blocks within the Standard TX PCS."}\
    {std_rx_pld_pcs_width                   true    false         INTEGER   NOVAL                           NOVAL                                                                     l_enable_rx_std                     l_enable_rx_std                       NOVAL         NOVAL         "Standard PCS"                                "FPGA fabric / Standard RX PCS interface width"         ::altera_xcvr_native_sv::parameters::validate_std_rx_pld_pcs_width                NOVAL     "Indicates the data inerface width between the Standard RX PCS and the FPGA fabric. This value is determined by the current configuration of individual blocks within the Standard RX PCS."}\
    {std_low_latency_bypass_enable          false   true          INTEGER   0                               NOVAL                                                                     enable_std                          enable_std                            boolean       NOVAL         "Standard PCS"                                "Enable 'Standard PCS' low latency mode"                ::altera_xcvr_native_sv::parameters::validate_std_low_latency_bypass_enable       NOVAL     "Enables the low latency path for the 'Standard PCS'. Enabling this option will bypass the individual functional blocks within the 'Standard PCS' to provide the lowest latency datapath from the PMA through the 'Standard PCS'."}\
    \
    {std_tx_pcfifo_mode                     false   true          STRING    "low_latency"                   {low_latency register_fifo}                                               l_enable_tx_std                     l_enable_tx_std                       NOVAL         NOVAL         "Phase Compensation FIFO"                     "TX FIFO mode"                                          ::altera_xcvr_native_sv::parameters::validate_std_tx_pcfifo_mode                  NOVAL     "Specifies the mode for the 'Standard PCS' TX FIFO."}\
    {std_rx_pcfifo_mode                     false   true          STRING    "low_latency"                   {low_latency register_fifo}                                               l_enable_rx_std                     l_enable_rx_std                       NOVAL         NOVAL         "Phase Compensation FIFO"                     "RX FIFO mode"                                          ::altera_xcvr_native_sv::parameters::validate_std_rx_pcfifo_mode                  NOVAL     "Specifies the mode for the 'Standard PCS' RX FIFO."}\
    {enable_port_tx_std_pcfifo_full         false   false         INTEGER   0                               NOVAL                                                                     l_enable_tx_std                     l_enable_tx_std                       boolean       NOVAL         "Phase Compensation FIFO"                     "Enable tx_std_pcfifo_full port"                        NOVAL                                                                             NOVAL     "Enables the optional tx_std_pcfifo_full status output port. This signal indicates when the standard TX phase compensation FIFO has reached the full threshold. This signal is synchronous with 'tx_std_clkout'."}\
    {enable_port_tx_std_pcfifo_empty        false   false         INTEGER   0                               NOVAL                                                                     l_enable_tx_std                     l_enable_tx_std                       boolean       NOVAL         "Phase Compensation FIFO"                     "Enable tx_std_pcfifo_empty port"                       NOVAL                                                                             NOVAL     "Enables the optional tx_std_pcfifo_empty status output port. This signal indicates when the standard RX phase compensation FIFO has reached the empty threshold. This signal is synchronous with 'tx_std_clkout'."}\
    {enable_port_rx_std_pcfifo_full         false   false         INTEGER   0                               NOVAL                                                                     l_enable_rx_std                     l_enable_rx_std                       boolean       NOVAL         "Phase Compensation FIFO"                     "Enable rx_std_pcfifo_full port"                        NOVAL                                                                             NOVAL     "Enables the optional rx_std_pcfifo_full status output port. This signal indicates when the standard RX phase compensation FIFO has reached the full threshold. This signal is synchronous with 'rx_std_clkout'."}\
    {enable_port_rx_std_pcfifo_empty        false   false         INTEGER   0                               NOVAL                                                                     l_enable_rx_std                     l_enable_rx_std                       boolean       NOVAL         "Phase Compensation FIFO"                     "Enable rx_std_pcfifo_empty port"                       NOVAL                                                                             NOVAL     "Enables the optional rx_std_pcfifo_empty status output port. This signal indicates when the standard RX phase compensation FIFO has reached the full threshold. This signal is synchronous with 'rx_std_clkout'."}\
    \
    {std_rx_byte_order_enable               false   true          INTEGER   0                               NOVAL                                                                     l_enable_rx_std                     l_enable_rx_std                       boolean       NOVAL         "Byte Ordering"                               "Enable RX byte ordering"                               ::altera_xcvr_native_sv::parameters::validate_std_rx_byte_order_enable            NOVAL     "Enables the RX byte ordering block within the Standard RX PCS. The byte ordering block can optionally be engaged when the PCS byte deserializer is active. The byte ordering block can identify a specified symbol pattern in the data stream and move that data pattern to the lower LSB's of the output data interface."}\
    {std_rx_byte_order_mode                 false   true          STRING    "manual"                        {manual auto}                                                             std_rx_byte_order_enable            l_enable_rx_std                       NOVAL         NOVAL         "Byte Ordering"                               "Byte ordering control mode"                            ::altera_xcvr_native_sv::parameters::validate_std_rx_byte_order_mode              NOVAL     "Specifies the control mode for the RX byte ordering block. The byte ordering block can be controlled by the user or can be controlled automatically by the PCS word aligner block once word alignment is achieved."}\
    {std_rx_byte_order_width                true    true          INTEGER   10                              {8 9 10}                                                                  std_rx_byte_order_enable            l_enable_rx_std                       NOVAL         NOVAL         "Byte Ordering"                               "Byte ordering pattern width"                           ::altera_xcvr_native_sv::parameters::validate_std_rx_byte_order_width             NOVAL     "Specifies the byte order pattern symbol pattern width. This is the width of the data symbol pattern that the byte order block will search for."}\
    {std_rx_byte_order_symbol_count         false   true          INTEGER   1                               {1 2}                                                                     std_rx_byte_order_enable            l_enable_rx_std                       NOVAL         NOVAL         "Byte Ordering"                               "Byte ordering symbol count"                            ::altera_xcvr_native_sv::parameters::validate_std_rx_byte_order_symbol_count      NOVAL     "Specifies the number of symbols for the word aligner block to search for. When the PMA is configured for a width of 16 or 20 bits, the byte ordering block can optionally search for 1 or 2 symbols."}\
    {std_rx_byte_order_pattern              false   true          STRING    "0"                             NOVAL                                                                     std_rx_byte_order_enable            l_enable_rx_std                       NOVAL         NOVAL         "Byte Ordering"                               "Byte order pattern (hex)"                              ::altera_xcvr_native_sv::parameters::validate_std_rx_byte_order_pattern           NOVAL     "Specifies the search pattern for the byte ordering block."}\
    {std_rx_byte_order_pad                  false   true          STRING    "0"                             NOVAL                                                                     std_rx_byte_order_enable            l_enable_rx_std                       NOVAL         NOVAL         "Byte Ordering"                               "Byte order pad value (hex)"                            ::altera_xcvr_native_sv::parameters::validate_std_rx_byte_order_pad               NOVAL     "Specifies the pad value to be inserted by the byte order block. This is the data that will be inserted when the byte order pattern is recognized."}\
    {enable_port_rx_std_byteorder_ena       false   false         INTEGER   0                               NOVAL                                                                     l_enable_rx_std                     l_enable_rx_std                       boolean       NOVAL         "Byte Ordering"                               "Enable rx_std_byteorder_ena port"                      NOVAL                                                                             NOVAL     "Enables the optional rx_std_byteorder_ena control input port. The assertion of this signal will cause the byte ordering block to perform byte ordering when the is configured in 'manual' mode. Once byte ordering has occurred, this signal must be deasserted and reasserted to perform a subsequent byte ordering operation. This is an asynchronous input signal but must be asserted for at least one cycle of 'rx_std_clkout'"}\
    {enable_port_rx_std_byteorder_flag      false   false         INTEGER   0                               NOVAL                                                                     l_enable_rx_std                     l_enable_rx_std                       boolean       NOVAL         "Byte Ordering"                               "Enable rx_std_byteorder_flag port"                     NOVAL                                                                             NOVAL     "Enables the optional rx_std_byteorder_flag status output port. The assertion of this signal indicates that the byte ordering block performed a byte order operation. The signal is asserted on the clock cycle in which byte ordering occurred. This signal is synchronous with 'rx_std_clkout'."}\
    \
    {std_tx_byte_ser_enable                 false   true          INTEGER   0                               NOVAL                                                                     l_enable_tx_std                     l_enable_tx_std                       boolean       NOVAL         "Byte Serializer and Deserializer"            "Enable TX byte serializer"                             ::altera_xcvr_native_sv::parameters::validate_std_tx_byte_ser_enable              NOVAL     "Enables the TX byte serializer in the 'Standard PCS'. The transceiver architecture allows the 'Standard PCS' to operate at double the data width of the PMA serializer. This allows the PCS to run at a lower internal clock frequency and accommodate a wider range of FPGA interface widths."}\
    {std_rx_byte_deser_enable               false   true          INTEGER   0                               NOVAL                                                                     l_enable_rx_std                     l_enable_rx_std                       boolean       NOVAL         "Byte Serializer and Deserializer"            "Enable RX byte deserializer"                           ::altera_xcvr_native_sv::parameters::validate_std_rx_byte_deser_enable            NOVAL     "Enables the RX byte deserializer in the 'Standard PCS' The transceiver architecture allows the 'Standard PCS' to operate at double the data width of the PMA deserializer. This allows the PCS to run at a lower internal clock frequency and accommodate a wider range of FPGA interface widths."}\
    \
    {std_tx_8b10b_enable                    false   true          INTEGER   0                               NOVAL                                                                     l_enable_tx_std                     l_enable_tx_std                       boolean       NOVAL         "8B/10B Encoder and Decoder"                  "Enable TX 8B/10B encoder"                              ::altera_xcvr_native_sv::parameters::validate_std_tx_8b10b_enable                 NOVAL     "Enables the 8B/10B encoder in the 'Standard PCS'."}\
    {std_tx_8b10b_disp_ctrl_enable          false   true          INTEGER   0                               NOVAL                                                                     l_enable_tx_std                     l_enable_tx_std                       boolean       NOVAL         "8B/10B Encoder and Decoder"                  "Enable TX 8B/10B disparity control"                    ::altera_xcvr_native_sv::parameters::validate_std_tx_8b10b_disp_ctrl_enable       NOVAL     "Enables disparity control for the 8B/10B encoder. This allows you to force the disparity of the 8b10b encoder via the 'tx_forcedisp' control signal."}\
    {std_rx_8b10b_enable                    false   true          INTEGER   0                               NOVAL                                                                     l_enable_rx_std                     l_enable_rx_std                       boolean       NOVAL         "8B/10B Encoder and Decoder"                  "Enable RX 8B/10B decoder"                              ::altera_xcvr_native_sv::parameters::validate_std_rx_8b10b_enable                 NOVAL     "Enables the 8B/10B decoder in the 'Standard PCS'."}\
    \
    {std_rx_rmfifo_enable                   false   true          INTEGER   0                               NOVAL                                                                     l_enable_rx_std                     l_enable_rx_std                       boolean       NOVAL         "Rate Match FIFO"                             "Enable RX rate match FIFO"                             ::altera_xcvr_native_sv::parameters::validate_std_rx_rmfifo_enable                NOVAL     "Enables the RX rate match FIFO in the 'Standard PCS'."}\
    {std_rx_rmfifo_pattern_p                false   true          STRING    "00000"                         NOVAL                                                                     std_rx_rmfifo_enable                l_enable_rx_std                       NOVAL         NOVAL         "Rate Match FIFO"                             "RX rate match insert/delete +ve pattern (hex)"         ::altera_xcvr_native_sv::parameters::validate_std_rx_rmfifo_pattern_p             NOVAL     "Specifies the +ve (positive) disparity value for the RX rate match FIFO. The value is 20-bits and specified as a hexadecimal string."}\
    {std_rx_rmfifo_pattern_n                false   true          STRING    "00000"                         NOVAL                                                                     std_rx_rmfifo_enable                l_enable_rx_std                       NOVAL         NOVAL         "Rate Match FIFO"                             "RX rate match insert/delete -ve pattern (hex)"         ::altera_xcvr_native_sv::parameters::validate_std_rx_rmfifo_pattern_n             NOVAL     "Specifies the -ve (negative) disparity value for the RX rate match FIFO. The value is 20-bits and specified as a hexadecimal string."}\
    {enable_port_rx_std_rmfifo_full         false   false         INTEGER   0                               NOVAL                                                                     l_enable_rx_std                     l_enable_rx_std                       boolean       NOVAL         "Rate Match FIFO"                             "Enable rx_std_rmfifo_full port"                        NOVAL                                                                             NOVAL     "Enables the optional rx_std_rmfifo_full status output port. This signal indicates when the standard RX rate match FIFO has reached the full threshold."}\
    {enable_port_rx_std_rmfifo_empty        false   false         INTEGER   0                               NOVAL                                                                     l_enable_rx_std                     l_enable_rx_std                       boolean       NOVAL         "Rate Match FIFO"                             "Enable rx_std_rmfifo_empty port"                       NOVAL                                                                             NOVAL     "Enables the optional rx_std_rmfifo_empty status output port. This signal indicates when the standard RX rate match FIFO has reached the full threshold."}\
    \
    {std_tx_bitslip_enable                  false   true          INTEGER   0                               NOVAL                                                                     l_enable_tx_std                     l_enable_tx_std                       boolean       NOVAL         "Word Aligner and Bitslip"                    "Enable TX bitslip"                                     ::altera_xcvr_native_sv::parameters::validate_std_tx_bitslip_enable               NOVAL     "Enable TX bitslip support. When enabled, the outgoing transmit data can be slipped a specific number of bits as specified by the 'tx_bitslipboundarysel' control signal."}\
    {enable_port_tx_std_bitslipboundarysel  false   false         INTEGER   0                               NOVAL                                                                     l_enable_tx_std                     l_enable_tx_std                       boolean       NOVAL         "Word Aligner and Bitslip"                    "Enable tx_std_bitslipboundarysel port"                 NOVAL                                                                             NOVAL     "Enables the optional tx_std_bitslipboundarysel control input port."}\
    {std_rx_word_aligner_mode               false   true          STRING    "bit_slip"                      {bit_slip sync_sm manual}                                                 l_enable_rx_std                     l_enable_rx_std                       NOVAL         NOVAL         "Word Aligner and Bitslip"                    "RX word aligner mode"                                  ::altera_xcvr_native_sv::parameters::validate_std_rx_word_aligner_mode            NOVAL     "Specifies the RX word aligner mode for the 'Standard PCS'."}\
    {std_rx_word_aligner_pattern_len        false   true          INTEGER   7                               {7 8 10 16 20 32 40}                                                      l_enable_rx_std_word_aligner        l_enable_rx_std                       NOVAL         NOVAL         "Word Aligner and Bitslip"                    "RX word aligner pattern length"                        ::altera_xcvr_native_sv::parameters::validate_std_rx_word_aligner_pattern_len     NOVAL     "Specifies the RX word alignment pattern length."}\
    {std_rx_word_aligner_pattern            false   true          STRING    "0000000000"                    NOVAL                                                                     l_enable_rx_std_word_aligner        l_enable_rx_std                       NOVAL         NOVAL         "Word Aligner and Bitslip"                    "RX word aligner pattern (hex)"                         ::altera_xcvr_native_sv::parameters::validate_std_rx_word_aligner_pattern         NOVAL     "Specifies the RX word alignment pattern."}\
    {std_rx_word_aligner_rknumber           false   true          INTEGER   3                               "0:255"                                                                   l_enable_rx_std_word_aligner        l_enable_rx_std                       NOVAL         NOVAL         "Word Aligner and Bitslip"                    "Number of word alignment patterns to achieve sync"     ::altera_xcvr_native_sv::parameters::validate_std_rx_word_aligner_rknumber        NOVAL     "Specifies the number of valid word alignment patterns that must be received before the word aligner achieve sync lock."}\
    {std_rx_word_aligner_renumber           false   true          INTEGER   3                               "0:63"                                                                    l_enable_rx_std_word_aligner        l_enable_rx_std                       NOVAL         NOVAL         "Word Aligner and Bitslip"                    "Number of invalid data words to lose sync"             ::altera_xcvr_native_sv::parameters::validate_std_rx_word_aligner_renumber        NOVAL     "Specifies the number of invalid data codes or disparity errors that must be received before the word aligner loses sync lock."}\
    {std_rx_word_aligner_rgnumber           false   true          INTEGER   3                               "0:255"                                                                   l_enable_rx_std_word_aligner        l_enable_rx_std                       NOVAL         NOVAL         "Word Aligner and Bitslip"                    "Number of valid data words to decrement error count"   ::altera_xcvr_native_sv::parameters::validate_std_rx_word_aligner_rgnumber        NOVAL     "Specifies the number of valid data codes that must be received to decrement the error counter. If enough valid data codes are received to decrement the error count to zero, the word aligner will return to sync lock."}\
    {std_rx_run_length_val                  false   true          INTEGER   31                              "0:63"                                                                    l_enable_rx_std_word_aligner        l_enable_rx_std                       NOVAL         NOVAL         "Word Aligner and Bitslip"                    "Run length detector word count"                        ::altera_xcvr_native_sv::parameters::validate_std_rx_run_length_val               NOVAL     "Specifies the number of consecutive received words from the PMA containing no 1>0 or 0>1 transitions that will trigger a run length violation."}\
    {enable_port_rx_std_wa_patternalign     false   false         INTEGER   0                               NOVAL                                                                     l_enable_rx_std                     l_enable_rx_std                       boolean       NOVAL         "Word Aligner and Bitslip"                    "Enable rx_std_wa_patternalign port"                    NOVAL                                                                             NOVAL     "Enables the optional rx_std_wa_patternalign control input port. A rising edge on this signal will cause the word aligner to align to the next incoming word alignment pattern when the word aligner is configured in \"manual\" mode."}\
    {enable_port_rx_std_wa_a1a2size         false   false         INTEGER   0                               NOVAL                                                                     l_enable_rx_std                     l_enable_rx_std                       boolean       NOVAL         "Word Aligner and Bitslip"                    "Enable rx_std_wa_a1a2size port"                        NOVAL                                                                             NOVAL     "Enables the optional rx_std_a1a2size control input port."}\
    {enable_port_rx_std_bitslipboundarysel  false   false         INTEGER   0                               NOVAL                                                                     l_enable_rx_std                     l_enable_rx_std                       boolean       NOVAL         "Word Aligner and Bitslip"                    "Enable rx_std_bitslipboundarysel port"                 NOVAL                                                                             NOVAL     "Enables the optional rx_std_bitslipboundarysel status output port."}\
    {enable_port_rx_std_bitslip             false   false         INTEGER   0                               NOVAL                                                                     l_enable_rx_std                     l_enable_rx_std                       boolean       NOVAL         "Word Aligner and Bitslip"                    "Enable rx_std_bitslip port"                            ::altera_xcvr_native_sv::parameters::validate_enable_port_rx_std_bitslip          NOVAL     "Enables the optional rx_std_bitslip control input port. The rising-edge assertion of this port will cause a single bit slip in the received RX parallel data. The signal should be held high for at least three RX parallel clock cycles and must be deasserted before performing another bit slip. This signal has no effect when the PCS is configured in low latency mode."}\
    {enable_port_rx_std_runlength_err       false   false         INTEGER   0                               NOVAL                                                                     l_enable_rx_std                     l_enable_rx_std                       boolean       NOVAL         "Word Aligner and Bitslip"                    "Enable rx_std_runlength_err port"                      NOVAL                                                                             NOVAL     "Enables the optional rx_std_runlength_err control input port."}\
    \
    {std_tx_bitrev_enable                   false   true          INTEGER   0                               NOVAL                                                                     l_enable_tx_std                     l_enable_tx_std                       boolean       NOVAL         "Bit Reversal and Polarity Inversion"         "Enable TX bit reversal"                                ::altera_xcvr_native_sv::parameters::validate_std_tx_bitrev_enable                NOVAL     "Enables transmitter bit order reversal. When enabled the TX parallel data will be reversed before passing to the PMA for serialization. When bit reversal is activated, the transmitted TX data bit order flipped to MSB->LSB rather than the normal LSB->MSB. This is a static setting and can only be dynamically changed through dynamic reconfiguration."}\
    {std_rx_bitrev_enable                   false   true          INTEGER   0                               NOVAL                                                                     l_enable_rx_std                     l_enable_rx_std                       boolean       NOVAL         "Bit Reversal and Polarity Inversion"         "Enable RX bit reversal"                                ::altera_xcvr_native_sv::parameters::validate_std_rx_bitrev_enable                NOVAL     "Enables receiver bit order reversal. When enabled, the 'rx_std_bitrev_ena' control port controls bit reversal of the RX parallel data after passing from the PMA to the PCS. When bit reversal is activated, the received RX data bit order is flipped to MSB->LSB rather than the normal LSB->MSB"}\
    {std_tx_byterev_enable                  false   true          INTEGER   0                               NOVAL                                                                     l_enable_tx_std                     l_enable_tx_std                       boolean       NOVAL         "Bit Reversal and Polarity Inversion"         "Enable TX byte reversal"                               ::altera_xcvr_native_sv::parameters::validate_std_tx_byterev_enable               NOVAL     "Enables transmitter byte order reversal. When the PCS / PMA interface width is 16 or 20 bits, the PCS can swap the ordering of the individual 8- or 10-bit words. This option is not allowed under all protocol modes."}\
    {std_rx_byterev_enable                  false   true          INTEGER   0                               NOVAL                                                                     l_enable_rx_std                     l_enable_rx_std                       boolean       NOVAL         "Bit Reversal and Polarity Inversion"         "Enable RX byte reversal"                               ::altera_xcvr_native_sv::parameters::validate_std_rx_byterev_enable               NOVAL     "Enables receiver byte order reversal. When the PCS / PMA interface width is 16 or 20 bits, the PCS can swap the ordering of the individual 8- or 10-bit words. This option is not allowed under all protocol modes."}\
    {std_tx_polinv_enable                   false   true          INTEGER   0                               NOVAL                                                                     l_enable_tx_std                     l_enable_tx_std                       boolean       NOVAL         "Bit Reversal and Polarity Inversion"         "Enable TX polarity inversion"                          NOVAL                                                                             NOVAL     "Enables TX bit polarity inversion. When enabled, the 'tx_std_polinv' control port controls polarity inversion of the TX parallel data bits before passing to the PMA."}\
    {std_rx_polinv_enable                   false   true          INTEGER   0                               NOVAL                                                                     l_enable_rx_std                     l_enable_rx_std                       boolean       NOVAL         "Bit Reversal and Polarity Inversion"         "Enable RX polarity inversion"                          NOVAL                                                                             NOVAL     "Enables RX bit polarity inversion. When enabled, the 'rx_std_polinv' control port controls polarity inversion of the RX parallel data bits after passing from the PMA."}\
    {enable_port_rx_std_bitrev_ena          false   false         INTEGER   0                               NOVAL                                                                     l_enable_rx_std                     l_enable_rx_std                       boolean       NOVAL         "Bit Reversal and Polarity Inversion"         "Enable rx_std_bitrev_ena port"                         ::altera_xcvr_native_sv::parameters::validate_enable_port_rx_std_bitrev_ena       NOVAL     "Enables the optional rx_std_bitrev_ena control input port. When receiver bit order reversal is enabled, the assertion of this signal will cause the received RX data bit order to be flipped to MSB->LSB rather than the normal LSB->MSB. This is an asynchronous input signal."}\
    {enable_port_rx_std_byterev_ena         false   false         INTEGER   0                               NOVAL                                                                     l_enable_rx_std                     l_enable_rx_std                       boolean       NOVAL         "Bit Reversal and Polarity Inversion"         "Enable rx_std_byterev_ena port"                        ::altera_xcvr_native_sv::parameters::validate_enable_port_rx_std_byterev_ena      NOVAL     "Enables the optional rx_std_byterev_ena control input port. When receiver byte order reversal is enabled, the assertion of this signal will swap the order of individual 8- or 10-bit words received from the PMA."}\
    {enable_port_tx_std_polinv              false   false         INTEGER   0                               NOVAL                                                                     l_enable_tx_std                     l_enable_tx_std                       boolean       NOVAL         "Bit Reversal and Polarity Inversion"         "Enable tx_std_polinv port"                             ::altera_xcvr_native_sv::parameters::validate_enable_port_tx_std_polinv           NOVAL     "Enables the optional tx_std_polinv control input port. When TX bit polarity inversion is enabled, the assertion of this signal will cause the TX bit polarity to be inverted."}\
    {enable_port_rx_std_polinv              false   false         INTEGER   0                               NOVAL                                                                     l_enable_rx_std                     l_enable_rx_std                       boolean       NOVAL         "Bit Reversal and Polarity Inversion"         "Enable rx_std_polinv port"                             ::altera_xcvr_native_sv::parameters::validate_enable_port_rx_std_polinv           NOVAL     "Enables the optional rx_std_polinv control input port. When RX bit polarity inversion is enabled, the assertion of this signal will cause the RX bit polarity to be inverted."}\
    {enable_port_tx_std_elecidle            false   false         INTEGER   0                               NOVAL                                                                     l_enable_tx_std                     l_enable_tx_std                       boolean       NOVAL         "Bit Reversal and Polarity Inversion"         "Enable tx_std_elecidle port"                           NOVAL                                                                             NOVAL     "Enables the optional tx_std_elecidle control input port. The assertion of this signal will force the transmitter into an electrical idle condition."}\
    {enable_port_rx_std_signaldetect        false   false         INTEGER   0                               NOVAL                                                                     l_enable_rx_std                     l_enable_rx_std                       boolean       NOVAL         "Bit Reversal and Polarity Inversion"         "Enable rx_std_signaldetect port"                       NOVAL                                                                             NOVAL     "Enables the optional rx_std_signaldetect status output port. The assertion of this signal indicates that a signal has been detected on the receiver. The signal detect threshold can be specified through Quartus II QSF assignments."}\
    \
    {enable_port_rx_std_prbs_status         false   false         INTEGER   0                               NOVAL                                                                     l_enable_rx_std                     l_enable_rx_std                       boolean       NOVAL         "PRBS Verifier"                               "Enable rx_std_prbs ports"                              NOVAL                                                                             NOVAL     "Enables the optional rx_std_prbs_err and rx_std_prbs_done status ports. PRBS can only be enabled through Dynamic Reconfiguration.  rx_std_prbs_done will assert after correctly receiving PRBS patterns, but it does not imply the test is complete. rx_std_prbs_err will pulse for each mismatch in the PRBS verifier.  Refer to the user guide for more details."}\
    \
    {teng_protocol_hint                     false   true          STRING    "basic"                         {basic interlaken sfis teng_baser teng_1588 teng_sdi}                     enable_teng                         enable_teng                           NOVAL         NOVAL         "10G PCS"                                     "10G PCS protocol mode"                                 ::altera_xcvr_native_sv::parameters::validate_teng_protocol_hint                  NOVAL     "Specifies the protocol mode for the current 10G PCS configuration. The protocol mode is used to govern the legal settings for parameters within the 10G PCS datapath."}\
    {teng_pcs_pma_width                     false   true          INTEGER   40                              {32 40 64}                                                                enable_teng                         enable_teng                           NOVAL         NOVAL         "10G PCS"                                     "10G PCS / PMA interface width"                         ::altera_xcvr_native_sv::parameters::validate_teng_pcs_pma_width                  NOVAL     "Specifies the data interface width between the 10G PCS and the transceiver PMA."}\
    {teng_pld_pcs_width                     false   true          INTEGER   40                              {32 40 50 64 66 67}                                                       enable_teng                         enable_teng                           NOVAL         NOVAL         "10G PCS"                                     "FPGA fabric / 10G PCS interface width"                 ::altera_xcvr_native_sv::parameters::validate_teng_pld_pcs_width                  NOVAL     "Specifies the data inerface width between the 10G PCS and the FPGA fabric."}\
    \
    {teng_txfifo_mode                       false   true          STRING    "phase_comp"                    {interlaken phase_comp register}                                          l_enable_tx_teng                    l_enable_tx_teng                      NOVAL         NOVAL         "10G TX FIFO"                                 "TX FIFO mode"                                          ::altera_xcvr_native_sv::parameters::validate_teng_txfifo_mode                    NOVAL     "Specifies the mode for the 10G PCS TX FIFO."}\
    {teng_txfifo_full                       false   true          INTEGER   31                              "0:31"                                                                    l_enable_tx_teng                    l_enable_tx_teng                      NOVAL         NOVAL         "10G TX FIFO"                                 "TX FIFO full threshold"                                NOVAL                                                                             NOVAL     "Specifies the full threshold for the 10G PCS TX FIFO."}\
    {teng_txfifo_empty                      false   true          INTEGER   0                               "0:31"                                                                    l_enable_tx_teng                    l_enable_tx_teng                      NOVAL         NOVAL         "10G TX FIFO"                                 "TX FIFO empty threshold"                               NOVAL                                                                             NOVAL     "Specifies the empty threshold for the 10G PCS TX FIFO."}\
    {teng_txfifo_pfull                      false   true          INTEGER   23                              "0:31"                                                                    l_enable_tx_teng                    l_enable_tx_teng                      NOVAL         NOVAL         "10G TX FIFO"                                 "TX FIFO partially full threshold"                      ::altera_xcvr_native_sv::parameters::validate_teng_txfifo_pfull                   NOVAL     "Specifies the partially full threshold for the 10G PCS TX FIFO."}\
    {teng_txfifo_pempty                     false   true          INTEGER   2                               "0:31"                                                                    l_enable_tx_teng                    l_enable_tx_teng                      NOVAL         NOVAL         "10G TX FIFO"                                 "TX FIFO partially empty threshold"                     ::altera_xcvr_native_sv::parameters::validate_teng_txfifo_pempty                  NOVAL     "Specifies the partially empty threshold for the 10G PCS TX FIFO."}\
    {enable_port_tx_10g_fifo_full           false   false         INTEGER   0                               NOVAL                                                                     l_enable_tx_teng                    l_enable_tx_teng                      boolean       NOVAL         "10G TX FIFO"                                 "Enable tx_10g_fifo_full port"                          NOVAL                                                                             NOVAL     "Enables the optional tx_10g_fifo_full status output port. This signal indicates when the TX FIFO has reached the specified full threshold."}\
    {enable_port_tx_10g_fifo_pfull          false   false         INTEGER   0                               NOVAL                                                                     l_enable_tx_teng                    l_enable_tx_teng                      boolean       NOVAL         "10G TX FIFO"                                 "Enable tx_10g_fifo_pfull port"                         NOVAL                                                                             NOVAL     "Enables the optional tx_10g_fifo_pfull status output port. This signal indicates when the TX FIFO has reached the specified partially full threshold."}\
    {enable_port_tx_10g_fifo_empty          false   false         INTEGER   0                               NOVAL                                                                     l_enable_tx_teng                    l_enable_tx_teng                      boolean       NOVAL         "10G TX FIFO"                                 "Enable tx_10g_fifo_empty port"                         NOVAL                                                                             NOVAL     "Enables the optional tx_10g_fifo_empty status output port. This signal indicates when the TX FIFO has reached the speciifed empty threshold."}\
    {enable_port_tx_10g_fifo_pempty         false   false         INTEGER   0                               NOVAL                                                                     l_enable_tx_teng                    l_enable_tx_teng                      boolean       NOVAL         "10G TX FIFO"                                 "Enable tx_10g_fifo_pempty port"                        NOVAL                                                                             NOVAL     "Enables the optional tx_10g_fifo_pempty status output port. This signal indicates when the TX FIFO has reached the specified partially empty threshold."}\
    {enable_port_tx_10g_fifo_del            false   false         INTEGER   0                               NOVAL                                                                     l_enable_tx_teng                    l_enable_tx_teng                      boolean       NOVAL         "10G TX FIFO"                                 "Enable tx_10g_fifo_del port (10GBASE-R)"               NOVAL                                                                             NOVAL     "Enables the optional tx_10g_fifo_del status output port. This signal indicates when a word has been deleted from the rate-match FIFO. This signal is used in 10GBASE-R mode only."}\
    {enable_port_tx_10g_fifo_insert         false   false         INTEGER   0                               NOVAL                                                                     l_enable_tx_teng                    l_enable_tx_teng                      boolean       NOVAL         "10G TX FIFO"                                 "Enable tx_10g_fifo_insert port (10GBASE-R)"            NOVAL                                                                             NOVAL     "Enables the optional tx_10g_fifo_insert status output port. This signal indicates when a word has been inserted into the rate-match FIFO. This signal is used in 10GBASE-R mode only."}\
    \
    {teng_rxfifo_mode                       false   true          STRING    "phase_comp"                    {interlaken clk_comp phase_comp register}                                 l_enable_rx_teng                    l_enable_rx_teng                      NOVAL         NOVAL         "10G RX FIFO"                                 "RX FIFO mode"                                          ::altera_xcvr_native_sv::parameters::validate_teng_rxfifo_mode                    NOVAL     "Specifies the mode for the 10G PCS RX FIFO."}\
    {teng_rxfifo_full                       false   true          INTEGER   31                              "0:31"                                                                    l_enable_rx_teng                    l_enable_rx_teng                      NOVAL         NOVAL         "10G RX FIFO"                                 "RX FIFO full threshold"                                NOVAL                                                                             NOVAL     "Specifies the full threshold for the 10G PCS RX FIFO."}\
    {teng_rxfifo_empty                      false   true          INTEGER   0                               "0:31"                                                                    l_enable_rx_teng                    l_enable_rx_teng                      NOVAL         NOVAL         "10G RX FIFO"                                 "RX FIFO empty threshold"                               NOVAL                                                                             NOVAL     "Specifies the partially full threshold for the 10G PCS RX FIFO."}\
    {teng_rxfifo_pfull                      false   true          INTEGER   23                              "0:31"                                                                    l_enable_rx_teng                    l_enable_rx_teng                      NOVAL         NOVAL         "10G RX FIFO"                                 "RX FIFO partially full threshold"                      ::altera_xcvr_native_sv::parameters::validate_teng_rxfifo_pfull                   NOVAL     "Specifies the empty threshold for the 10G PCS RX FIFO."}\
    {teng_rxfifo_pempty                     false   true          INTEGER   2                               "0:31"                                                                    l_enable_rx_teng                    l_enable_rx_teng                      NOVAL         NOVAL         "10G RX FIFO"                                 "RX FIFO partially empty threshold"                     ::altera_xcvr_native_sv::parameters::validate_teng_rxfifo_pempty                  NOVAL     "Specifies the partially empty threshold for the 10G PCS RX FIFO."}\
    {teng_rxfifo_align_del                  false   true          INTEGER   0                               NOVAL                                                                     l_enable_rx_teng                    l_enable_rx_teng                      boolean       NOVAL         "10G RX FIFO"                                 "Enable RX FIFO alignment word deletion (Interlaken)"   ::altera_xcvr_native_sv::parameters::validate_teng_rxfifo_align_del               NOVAL     "Enables Interlaken alignment word (sync word) removal. When the 10G PCS RX FIFO is configured for interlaken mode, enabling this option will cause all alignment words (sync words) to be removed after frame synchronization has occurred. This includes the first sync word. Enabling this option requires that you also enable control word deletion."}\
    {teng_rxfifo_control_del                false   true          INTEGER   0                               NOVAL                                                                     l_enable_rx_teng                    l_enable_rx_teng                      boolean       NOVAL         "10G RX FIFO"                                 "Enable RX FIFO control word deletion (Interlaken)"     ::altera_xcvr_native_sv::parameters::validate_teng_rxfifo_control_del             NOVAL     "Enables Interlaken control word removal. When the 10G PCS RX FIFO is configured for interlaken mode, enabling this option will cause all control words to be removed after frame synchronization has occurred. Enabling this option requires that you also enable alignment word deletion."}\
    {enable_port_rx_10g_data_valid          false   false         INTEGER   0                               NOVAL                                                                     l_enable_rx_teng                    l_enable_rx_teng                      boolean       NOVAL         "10G RX FIFO"                                 "Enable rx_10g_fifo_data_valid port"                    NOVAL                                                                             NOVAL     "Enables the optional rx_10g_data_valid status output port. This signal indicates when RX data is valid."}\
    {enable_port_rx_10g_fifo_full           false   false         INTEGER   0                               NOVAL                                                                     l_enable_rx_teng                    l_enable_rx_teng                      boolean       NOVAL         "10G RX FIFO"                                 "Enable rx_10g_fifo_full port"                          NOVAL                                                                             NOVAL     "Enables the optional rx_10g_fifo_full status output port. This signal indicates when the RX FIFO has reached the specified full threshold."}\
    {enable_port_rx_10g_fifo_pfull          false   false         INTEGER   0                               NOVAL                                                                     l_enable_rx_teng                    l_enable_rx_teng                      boolean       NOVAL         "10G RX FIFO"                                 "Enable rx_10g_fifo_pfull port"                         NOVAL                                                                             NOVAL     "Enables the optional rx_10g_fifo_pfull status output port. This signal indicates when the RX FIFO has reached the specified partially full threshold."}\
    {enable_port_rx_10g_fifo_empty          false   false         INTEGER   0                               NOVAL                                                                     l_enable_rx_teng                    l_enable_rx_teng                      boolean       NOVAL         "10G RX FIFO"                                 "Enable rx_10g_fifo_empty port"                         NOVAL                                                                             NOVAL     "Enables the optional rx_10g_fifo_empty status output port. This signal indicates when the RX FIFO has reached the speciifed empty threshold."}\
    {enable_port_rx_10g_fifo_pempty         false   false         INTEGER   0                               NOVAL                                                                     l_enable_rx_teng                    l_enable_rx_teng                      boolean       NOVAL         "10G RX FIFO"                                 "Enable rx_10g_fifo_pempty port"                        NOVAL                                                                             NOVAL     "Enables the optional rx_10g_fifo_pempty status output port. This signal indicates when the RX FIFO has reached the specified partially empty threshold."}\
    {enable_port_rx_10g_fifo_del            false   false         INTEGER   0                               NOVAL                                                                     l_enable_rx_teng                    l_enable_rx_teng                      boolean       NOVAL         "10G RX FIFO"                                 "Enable rx_10g_fifo_del port (10GBASE-R)"               NOVAL                                                                             NOVAL     "Enables the optional rx_10g_fifo_del status output port. This signal indicates when a word has been deleted from the rate-match FIFO. This signal is used in 10GBASE-R mode only."}\
    {enable_port_rx_10g_fifo_insert         false   false         INTEGER   0                               NOVAL                                                                     l_enable_rx_teng                    l_enable_rx_teng                      boolean       NOVAL         "10G RX FIFO"                                 "Enable rx_10g_fifo_insert port (10GBASE-R)"            NOVAL                                                                             NOVAL     "Enables the optional rx_10g_fifo_insert status output port. This signal indicates when a word has been inserted into the rate-match FIFO. This signal is used in 10GBASE-R mode only."}\
    {enable_port_rx_10g_fifo_rd_en          false   false         INTEGER   0                               NOVAL                                                                     l_enable_rx_teng                    l_enable_rx_teng                      boolean       NOVAL         "10G RX FIFO"                                 "Enable rx_10g_fifo_rd_en port (Interlaken)"            NOVAL                                                                             NOVAL     "Enables the optional rx_10g_fifo_rd_en control input port. This port is used for Interlaken only. Asserting this signal will read a word from the RX FIFO."}\
    {enable_port_rx_10g_fifo_align_val      false   false         INTEGER   0                               NOVAL                                                                     l_enable_rx_teng                    l_enable_rx_teng                      boolean       NOVAL         "10G RX FIFO"                                 "Enable rx_10g_fifo_align_val port (Interlaken)"        NOVAL                                                                             NOVAL     "Enables the optional rx_10g_fifo_align_val status output port. This port is used for Interlaken only."}\
    {enable_port_rx_10g_fifo_align_clr      false   false         INTEGER   0                               NOVAL                                                                     l_enable_rx_teng                    l_enable_rx_teng                      boolean       NOVAL         "10G RX FIFO"                                 "Enable rx_10g_fifo_align_clr port (Interlaken)"        NOVAL                                                                             NOVAL     "Enables the optional rx_10g_fifo_align_clr control input port. This port is used for Interlaken mode only."}\
    {enable_port_rx_10g_fifo_align_en       false   false         INTEGER   0                               NOVAL                                                                     l_enable_rx_teng                    l_enable_rx_teng                      boolean       NOVAL         "10G RX FIFO"                                 "Enable rx_10g_fifo_align_en port  (Interlaken)"        NOVAL                                                                             NOVAL     "Enables the optional rx_10g_fifo_align_en control input port. This port is used for Interlaken mode only."}\
    {enable_port_rx_10g_clk33out            false   false         INTEGER   0                               NOVAL                                                                     l_enable_rx_teng                    l_enable_rx_teng                      boolean       NOVAL         "10G RX FIFO"                                 "Enable rx_10g_clk33out port"                           NOVAL                                                                             NOVAL     "Enables the optional rx_10g_clk33out clock port. This clock is typically used for configurations where the PLD/PCS interface width is set to a value of 66."}\
    \
    {teng_tx_frmgen_enable                  true    true          INTEGER   0                               NOVAL                                                                     l_enable_tx_teng                    l_enable_tx_teng                      boolean       NOVAL         "Interlaken Frame Generator"                  NOVAL                                                   ::altera_xcvr_native_sv::parameters::validate_teng_tx_frmgen_enable               NOVAL     "Enables the Interlaken frame generator in the 10G PCS."}\
    {teng_tx_frmgen_user_length             false   true          INTEGER   2048                            "0:8192"                                                                  teng_tx_frmgen_enable               teng_tx_frmgen_enable                 NOVAL         NOVAL         "Interlaken Frame Generator"                  NOVAL                                                   NOVAL                                                                             NOVAL     "Specifies the Interlaken metaframe length for the frame generator."}\
    {teng_tx_frmgen_burst_enable            false   true          INTEGER   0                               NOVAL                                                                     teng_tx_frmgen_enable               teng_tx_frmgen_enable                 boolean       NOVAL         "Interlaken Frame Generator"                  NOVAL                                                   NOVAL                                                                             NOVAL     "Enables burst functionality in the Interlaken frame generator. Refer to the user guide for more details."}\
    {enable_port_tx_10g_frame               false   false         INTEGER   0                               NOVAL                                                                     l_enable_tx_teng                    l_enable_tx_teng                      boolean       NOVAL         "Interlaken Frame Generator"                  "Enable tx_10g_frame port"                              NOVAL                                                                             NOVAL     "Enables the tx_10g_frame status output port. When the Interlaken frame generator is enabled, this signal indicates the beginning of a new metaframe."}\
    {enable_port_tx_10g_frame_diag_status   false   false         INTEGER   0                               NOVAL                                                                     l_enable_tx_teng                    l_enable_tx_teng                      boolean       NOVAL         "Interlaken Frame Generator"                  "Enable tx_10g_frame_diag_status port"                  NOVAL                                                                             NOVAL     "Enables the tx_10g_frame_diag_status control input port. When the Interlaken frame generator is enabled, the value of this signal contains the 'Status Message' from the framing layer 'Diagnostic Word'. Refer to the user guide for more details."}\
    {enable_port_tx_10g_frame_burst_en      false   false         INTEGER   0                               NOVAL                                                                     l_enable_tx_teng                    l_enable_tx_teng                      boolean       NOVAL         "Interlaken Frame Generator"                  "Enable tx_10g_frame_burst_en port"                     NOVAL                                                                             NOVAL     "Enables the tx_10g_frame_burst_en control input port. When burst functionality is enabled for the Interlaken frame generator, the assertion of this signal controls frame generator data reads from the TX FIFO. Refer to the user guide for more details."}\
    \
    {teng_rx_frmsync_enable                 true    true          INTEGER   0                               NOVAL                                                                     l_enable_rx_teng                    l_enable_rx_teng                      boolean       NOVAL         "Interlaken Frame Sync"                       NOVAL                                                   ::altera_xcvr_native_sv::parameters::validate_teng_rx_frmsync_enable              NOVAL     "Enables the Interlaken frame synchronizer in the 10G PCS."}\
    {teng_rx_frmsync_user_length            false   true          INTEGER   2048                            "0:8192"                                                                  teng_rx_frmsync_enable              teng_rx_frmsync_enable                NOVAL         NOVAL         "Interlaken Frame Sync"                       NOVAL                                                   NOVAL                                                                             NOVAL     "Specifies the Interlaken metaframe length for the frame synchronizer."}\
    {teng_frmgensync_diag_word              true    true          STRING    "6400000000000000"              NOVAL                                                                     false                               false                                 NOVAL         NOVAL         "Interlaken Frame Sync"                       NOVAL                                                   NOVAL                                                                             NOVAL     "Specifies the Interlaken frame generator/synchronizer diagnostic word."}\
    {teng_frmgensync_scrm_word              true    true          STRING    "2800000000000000"              NOVAL                                                                     false                               false                                 NOVAL         NOVAL         "Interlaken Frame Sync"                       NOVAL                                                   NOVAL                                                                             NOVAL     "Specifies the Interlaken frame generator/synchronizer scrambler word."}\
    {teng_frmgensync_skip_word              true    true          STRING    "1e1e1e1e1e1e1e1e"              NOVAL                                                                     false                               false                                 NOVAL         NOVAL         "Interlaken Frame Sync"                       NOVAL                                                   NOVAL                                                                             NOVAL     "Specifies the Interlaken frame generator/synchronizer skip word."}\
    {teng_frmgensync_sync_word              true    true          STRING    "78f678f678f678f6"              NOVAL                                                                     false                               false                                 NOVAL         NOVAL         "Interlaken Frame Sync"                       NOVAL                                                   NOVAL                                                                             NOVAL     "Specifies the Interlaken frame generator/synchronizer synchronization word."}\
    {enable_port_rx_10g_frame               false   false         INTEGER   0                               NOVAL                                                                     l_enable_rx_teng                    l_enable_rx_teng                      boolean       NOVAL         "Interlaken Frame Sync"                       "Enable rx_10g_frame port"                              NOVAL                                                                             NOVAL     "Enables the rx_10g_frame status output port. When the Interlaken frame synchronizer is enabled, this signal indicates the beginning of a new metaframe."}\
    {enable_port_rx_10g_frame_lock          false   false         INTEGER   0                               NOVAL                                                                     l_enable_rx_teng                    l_enable_rx_teng                      boolean       NOVAL         "Interlaken Frame Sync"                       "Enable rx_10g_frame_lock port"                         NOVAL                                                                             NOVAL     "Enables the rx_10g_frame_lock status output port. When the Interlaken frame synchronizer is enabled, the assertion of this signal indicates that the frame synchronizer has acheived metaframe delineation. This is an asynchronous output signal."}\
    {enable_port_rx_10g_frame_mfrm_err      false   false         INTEGER   0                               NOVAL                                                                     l_enable_rx_teng                    l_enable_rx_teng                      boolean       NOVAL         "Interlaken Frame Sync"                       "Enable rx_10g_frame_mfrm_err port"                     NOVAL                                                                             NOVAL     "Enables the rx_10g_frame_mfrm_err status output port. When the Interlaken frame synchronizer is enabled, the assertion of this signal indicates an error in the metaframe."}\
    {enable_port_rx_10g_frame_sync_err      false   false         INTEGER   0                               NOVAL                                                                     l_enable_rx_teng                    l_enable_rx_teng                      boolean       NOVAL         "Interlaken Frame Sync"                       "Enable rx_10g_frame_sync_err port"                     NOVAL                                                                             NOVAL     "Enables the rx_10g_frame_sync_err status output port. When the Interlaken frame synchronizer is enabled, the assertion of this signal indicates an error in the synchronization control word within the metaframe."}\
    {enable_port_rx_10g_frame_pyld_ins      false   false         INTEGER   0                               NOVAL                                                                     l_enable_rx_teng                    l_enable_rx_teng                      boolean       NOVAL         "Interlaken Frame Sync"                       "Enable rx_10g_frame_pyld_ins port"                     NOVAL                                                                             NOVAL     "Enables the rx_10g_frame_pyld_ins status output port. When the Interlaken frame synchronizer is enabled, the assertion of this signal indicates the detection of a non-skip word within a skip word within the metaframe."}\
    {enable_port_rx_10g_frame_skip_ins      false   false         INTEGER   0                               NOVAL                                                                     l_enable_rx_teng                    l_enable_rx_teng                      boolean       NOVAL         "Interlaken Frame Sync"                       "Enable rx_10g_frame_skip_ins port"                     NOVAL                                                                             NOVAL     "Enables the rx_10g_frame_skip_ins status output port. When the Interlaken frame synchronizer is enabled, the assertion of this signal indicates the detection of a skip word within a non-skip word within the metaframe."}\
    {enable_port_rx_10g_frame_skip_err      false   false         INTEGER   0                               NOVAL                                                                     l_enable_rx_teng                    l_enable_rx_teng                      boolean       NOVAL         "Interlaken Frame Sync"                       "Enable rx_10g_frame_skip_err port"                     NOVAL                                                                             NOVAL     "Enables the rx_10g_frame_skip_err status output port. When the Interlaken frame synchronizer is enabled, the assertion of this signal indicates the synchronizer has received an erroneous word during a skip control word within the metaframe."}\
    {enable_port_rx_10g_frame_diag_err      false   false         INTEGER   0                               NOVAL                                                                     l_enable_rx_teng                    l_enable_rx_teng                      boolean       NOVAL         "Interlaken Frame Sync"                       "Enable rx_10g_frame_diag_err port"                     NOVAL                                                                             NOVAL     "Enables the rx_10g_frame_diag_err status output port. When the Interlaken frame synchronizer is enabled, the assertion of this signal indicates an error in the received diagnostic control word within the metaframe."}\
    {enable_port_rx_10g_frame_diag_status   false   false         INTEGER   0                               NOVAL                                                                     l_enable_rx_teng                    l_enable_rx_teng                      boolean       NOVAL         "Interlaken Frame Sync"                       "Enable rx_10g_frame_diag_status port"                  NOVAL                                                                             NOVAL     "Enables the rx_10g_frame_diag_status status output port. When the Interlaken frame synchronizer is enabled, This two-bit per lane output signal contains the value of the framing layer diagnostic word (bits\[33:32\]). This signal is latched when a valid diagnostic word is received."}\
    \
    {teng_tx_sh_err                         false   true          INTEGER   0                               NOVAL                                                                     l_enable_tx_teng                    l_enable_tx_teng                      boolean       NOVAL         "64b/66b Encoder and Decoder"                 "Enable TX sync header error insertion"                 ::altera_xcvr_native_sv::parameters::validate_teng_tx_sh_err                      NOVAL     "Enables 64b/66b sync header error insertion for 10GBASE-R or Interlaken."}\
    \
    {teng_tx_crcgen_enable                  true    true          INTEGER   0                               NOVAL                                                                     l_enable_tx_teng                    l_enable_tx_teng                      boolean       NOVAL         "Interlaken CRC-32 Generator and Checker"     "Enable Interlaken TX CRC-32 generator"                 ::altera_xcvr_native_sv::parameters::validate_teng_tx_crcgen_enable               NOVAL     "Enables the Interlaken CRC-32 generator. This can be used as a dignostic tool. The CRC includes the entire metaframe including the diagnostic word."}\
    {teng_rx_crcchk_enable                  true    true          INTEGER   0                               NOVAL                                                                     l_enable_rx_teng                    l_enable_rx_teng                      boolean       NOVAL         "Interlaken CRC-32 Generator and Checker"     "Enable Interlaken RX CRC-32 checker"                   ::altera_xcvr_native_sv::parameters::validate_teng_rx_crcchk_enable               NOVAL     "Enables the Interlaken CRC-32 checker."}\
    {enable_port_rx_10g_crc32_err           false   false         INTEGER   0                               NOVAL                                                                     l_enable_rx_teng                    l_enable_rx_teng                      boolean       NOVAL         "Interlaken CRC-32 Generator and Checker"     "Enable rx_10g_crc32_err port"                          NOVAL                                                                             NOVAL     "Enables the optional enable_port_rx_10g_crc32_err status output port. When the Interlaken CRC-32 checker is enabled, the assertion of this signal indicates the detection of a CRC error in the metaframe."}\
    \
    {enable_port_rx_10g_highber             false   false         INTEGER   0                               NOVAL                                                                     l_enable_rx_teng                    l_enable_rx_teng                      boolean       NOVAL         "10GBASE-R BER Checker"                       "Enable rx_10g_highber port (10GBASE-R)"                NOVAL                                                                             NOVAL     "Enables the optional enable_port_rx_10g_highber status output port. In 10GBASE-R mode, the assertion of this signal indicates a bit-error rate higher then 10^-4. For the 10GBASE-R specification, this occurs when there are at least 16 errors within 125us."}\
    {enable_port_rx_10g_highber_clr_cnt     false   false         INTEGER   0                               NOVAL                                                                     l_enable_rx_teng                    l_enable_rx_teng                      boolean       NOVAL         "10GBASE-R BER Checker"                       "Enable rx_10g_highber_clr_cnt port (10GBASE-R)"        NOVAL                                                                             NOVAL     "Enables the optional enable_port_rx_10g_highber_clr_cnt control input port. In 10GBASE-R mode, the assertion of this signal will clear the internal counter for the number of times the BER state machine has entered the \"BER_BAD_SH\" state."}\
    {enable_port_rx_10g_clr_errblk_count    false   false         INTEGER   0                               NOVAL                                                                     l_enable_rx_teng                    l_enable_rx_teng                      boolean       NOVAL         "10GBASE-R BER Checker"                       "Enable rx_10g_clr_errblk_count port (10GBASE-R)"       NOVAL                                                                             NOVAL     "Enables the optional enable_port_rx_10g_clr_errblk_count control input port. In 10GBASE-R mode, the assertion of this signal will clear the internal counter for the number of times the RX state machine has entered the \"RX_E\" state."}\
    \
    {teng_tx_64b66b_enable                  true    true          INTEGER   0                               NOVAL                                                                     l_enable_tx_teng                    l_enable_tx_teng                      boolean       NOVAL         "64b/66b Encoder and Decoder"                 "Enable TX 64b/66b encoder"                             ::altera_xcvr_native_sv::parameters::validate_teng_tx_64b66b_enable               NOVAL     "Enables the 64b/66b encoder."}\
    {teng_rx_64b66b_enable                  true    true          INTEGER   0                               NOVAL                                                                     l_enable_rx_teng                    l_enable_rx_teng                      boolean       NOVAL         "64b/66b Encoder and Decoder"                 "Enable RX 64b/66b decoder"                             ::altera_xcvr_native_sv::parameters::validate_teng_rx_64b66b_enable               NOVAL     "Enables the 64b/66b decoder."}\
    \
    {teng_tx_scram_enable                   true    true          INTEGER   0                               NOVAL                                                                     l_enable_tx_teng                    l_enable_tx_teng                      boolean       NOVAL         "Scrambler and Descrambler"                   "Enable TX scrambler (10GBASE-R/Interlaken)"            ::altera_xcvr_native_sv::parameters::validate_teng_tx_scram_enable                NOVAL     "Enables the TX data scrambler for 10GBASE-R and Interlaken. Refer to the device handbook for further details."}\
    {teng_tx_scram_user_seed                false   true          STRING    "000000000000000"               NOVAL                                                                     teng_tx_scram_enable                teng_tx_scram_enable                  NOVAL         NOVAL         "Scrambler and Descrambler"                   "TX scrambler seed (10GBASE-R/Interlaken)"              ::altera_xcvr_native_sv::parameters::validate_teng_tx_scram_user_seed             NOVAL     "Specifies the initial seed for the 10GBASE-R / Interlaken scrambler."}\
    {teng_rx_descram_enable                 true    true          INTEGER   0                               NOVAL                                                                     l_enable_rx_teng                    l_enable_rx_teng                      boolean       NOVAL         "Scrambler and Descrambler"                   "Enable RX descrambler (10GBASE-R/Interlaken)"          ::altera_xcvr_native_sv::parameters::validate_teng_rx_descram_enable              NOVAL     "Enables the RX data descrambler for 10GBASE-R and Interlaken. Refer to the device handbook for further details."}\
    {enable_port_rx_10g_descram_err         false   false         INTEGER   0                               NOVAL                                                                     l_enable_rx_teng                    l_enable_rx_teng                      boolean       NOVAL         "Scrambler and Descrambler"                   "Enable rx_10g_descram_err port (Interlaken)"           NOVAL                                                                             NOVAL     "Enables the optional enable_port_rx_10g_descram_err status output port. In Interlaken mode, when the RX data descrambler is enabled, the assertion of this signal indicates an error in the received scrambler control word within the metaframe. This signal is used for Interlaken only."}\
    \
    {teng_tx_dispgen_enable                 true    true          INTEGER   0                               NOVAL                                                                     l_enable_tx_teng                    l_enable_tx_teng                      boolean       NOVAL         "Interlaken Disparity Generator and Checker"  "Enable Interlaken TX disparity generator"              ::altera_xcvr_native_sv::parameters::validate_teng_tx_dispgen_enable              NOVAL     "Enables the Interlaken disparity generator."}\
    {teng_rx_dispchk_enable                 true    true          INTEGER   0                               NOVAL                                                                     l_enable_rx_teng                    l_enable_rx_teng                      boolean       NOVAL         "Interlaken Disparity Generator and Checker"  "Enable Interlaken RX disparity checker"                ::altera_xcvr_native_sv::parameters::validate_teng_rx_dispchk_enable              NOVAL     "Enables the Interlaken disparity checker."}\
    \
    {teng_rx_blksync_enable                 true    true          INTEGER   0                               NOVAL                                                                     l_enable_rx_teng                    l_enable_rx_teng                      boolean       NOVAL         "Block Sync"                                  "Enable RX block synchronizer"                          ::altera_xcvr_native_sv::parameters::validate_teng_rx_blksync_enable              NOVAL     "Enables the block synchronizer for the 10G RX PCS. Primariliy used in Interlaken and 10GBASE-R modes."}\
    {enable_port_rx_10g_blk_lock            false   false         INTEGER   0                               NOVAL                                                                     l_enable_rx_teng                    l_enable_rx_teng                      boolean       NOVAL         "Block Sync"                                  "Enable rx_10g_blk_lock port"                           NOVAL                                                                             NOVAL     "Enables the optional enable_port_rx_10g_blk_lock status output port. When the block synchronizer is enabled, the assertion of this signal indicates that block delineation has been achieved. This is an asynchronous output signal."}\
    {enable_port_rx_10g_blk_sh_err          false   false         INTEGER   0                               NOVAL                                                                     l_enable_rx_teng                    l_enable_rx_teng                      boolean       NOVAL         "Block Sync"                                  "Enable rx_10g_blk_sh_err port"                         NOVAL                                                                             NOVAL     "Enables the optional enable_port_rx_10g_blk_sh_err status output port. When the block synchronizer is enabled, the assertion of this signal indicates that an invalid block synchronization header was received after block synchronization was previously obtained."}\
    \
    {teng_tx_polinv_enable                  false   true          INTEGER   0                               NOVAL                                                                     l_enable_tx_teng                    l_enable_tx_teng                      boolean       NOVAL         "Gearbox"                                     "Enable TX data polarity inversion"                     NOVAL                                                                             NOVAL     "Enables TX bit polarity inversion for the 10G PCS TX datapath. When enabled, the TX parallel data bits will be inverted before passing to the PMA."}\
    {teng_tx_bitslip_enable                 false   true          INTEGER   0                               NOVAL                                                                     l_enable_tx_teng                    l_enable_tx_teng                      boolean       NOVAL         "Gearbox"                                     "Enable TX data bitslip"                                ::altera_xcvr_native_sv::parameters::validate_teng_tx_bitslip_enable              NOVAL     "Enables TX bitslip support for the 10G PCS TX datapath. When enabled, the tx_10g_bitslip port controls the number of bit locations to slip the TX parallel data before passing to the PMA."}\
    {teng_rx_polinv_enable                  false   true          INTEGER   0                               NOVAL                                                                     l_enable_rx_teng                    l_enable_rx_teng                      boolean       NOVAL         "Gearbox"                                     "Enable RX data polarity inversion"                     NOVAL                                                                             NOVAL     "Enables RX bit polarity inversion for the 10G PCS RX datapath. When enabled, the RX parallel data bits will be inverted after passing from the PMA."}\
    {teng_rx_bitslip_enable                 false   true          INTEGER   0                               NOVAL                                                                     l_enable_rx_teng                    l_enable_rx_teng                      boolean       NOVAL         "Gearbox"                                     "Enable RX data bitslip"                                ::altera_xcvr_native_sv::parameters::validate_teng_rx_bitslip_enable              NOVAL     "Enables RX bitslip support for the 10G PCS RX datapath. When enabled, the rx_10g_bitslip port controls slipping of the RX parallel data after passing from the PMA."}\
    {enable_port_tx_10g_bitslip             false   false         INTEGER   0                               NOVAL                                                                     l_enable_tx_teng                    l_enable_tx_teng                      boolean       NOVAL         "Gearbox"                                     "Enable tx_10g_bitslip port"                            ::altera_xcvr_native_sv::parameters::validate_enable_port_tx_10g_bitslip          NOVAL     "Enables the optional enable_port_tx_10g_bitslip control input port. When TX bitslip support is enabled for the 10G PCS, the value of this signal controls the number bit locations to slip the TX parallel data before passing to the PMA."}\
    {enable_port_rx_10g_bitslip             false   false         INTEGER   0                               NOVAL                                                                     l_enable_rx_teng                    l_enable_rx_teng                      boolean       NOVAL         "Gearbox"                                     "Enable rx_10g_bitslip port"                            ::altera_xcvr_native_sv::parameters::validate_enable_port_rx_10g_bitslip          NOVAL     "Enables the optional enable_port_rx_10g_bitslip control input port. When RX bitslip support is enabled for the 10G PCS, a rising edge on this signal will cause the RX parallel data to be slipped by one bit location after passing from the PMA."}\
    \
    {enable_port_rx_teng_prbs_status        false   false         INTEGER   0                               NOVAL                                                                     l_enable_rx_teng                    l_enable_rx_teng                      boolean       NOVAL         "10G PRBS Verifier"                           "Enable rx_10g_prbs ports"                              NOVAL                                                                             NOVAL     "Enables the optional rx_10g_prbs_err, rx_10g_prbs_err_clr and rx_10g_prbs_done status and control signals. PRBS can only be enabled through Dynamic Reconfiguration.  rx_10g_prbs_done will assert after correctly receiving PRBS patterns, but it does not imply the test is complete.  rx_10g_prbs_err will pulse for each mismatch in the verifier, and rx_10g_prbs_err_clr will reset the PRBS verifier when asserted.  Refer to the user guide for more details."}\
    \
    {l_pll_settings                         true    false         INTEGER   0                               NOVAL                                                                     true                                false                                 NOVAL         NOVAL         NOVAL                                         NOVAL                                                   ::altera_xcvr_native_sv::parameters::validate_l_pll_settings                      NOVAL     NOVAL}\
    {l_enable_tx_pma_direct                 true    false         INTEGER   0                               NOVAL                                                                     true                                false                                 NOVAL         NOVAL         NOVAL                                         NOVAL                                                   ::altera_xcvr_native_sv::parameters::validate_l_enable_tx_pma_direct              NOVAL     NOVAL}\
    {l_enable_rx_pma_direct                 true    false         INTEGER   0                               NOVAL                                                                     true                                false                                 NOVAL         NOVAL         NOVAL                                         NOVAL                                                   ::altera_xcvr_native_sv::parameters::validate_l_enable_rx_pma_direct              NOVAL     NOVAL}\
    {l_enable_tx_std                        true    false         INTEGER   0                               NOVAL                                                                     true                                false                                 NOVAL         NOVAL         NOVAL                                         NOVAL                                                   ::altera_xcvr_native_sv::parameters::validate_l_enable_tx_std                     NOVAL     NOVAL}\
    {l_enable_rx_std                        true    false         INTEGER   0                               NOVAL                                                                     true                                false                                 NOVAL         NOVAL         NOVAL                                         NOVAL                                                   ::altera_xcvr_native_sv::parameters::validate_l_enable_rx_std                     NOVAL     NOVAL}\
    {l_enable_rx_std_word_aligner           true    false         INTEGER   0                               NOVAL                                                                     true                                false                                 NOVAL         NOVAL         NOVAL                                         NOVAL                                                   ::altera_xcvr_native_sv::parameters::validate_l_enable_rx_std_word_aligner        NOVAL     NOVAL}\
    {l_enable_tx_teng                       true    false         INTEGER   0                               NOVAL                                                                     true                                false                                 NOVAL         NOVAL         NOVAL                                         NOVAL                                                   ::altera_xcvr_native_sv::parameters::validate_l_enable_tx_teng                    NOVAL     NOVAL}\
    {l_enable_rx_teng                       true    false         INTEGER   0                               NOVAL                                                                     true                                false                                 NOVAL         NOVAL         NOVAL                                         NOVAL                                                   ::altera_xcvr_native_sv::parameters::validate_l_enable_rx_teng                    NOVAL     NOVAL}\
    {l_netlist_plls                         true    false         INTEGER   0                               NOVAL                                                                     true                                false                                 NOVAL         NOVAL         NOVAL                                         NOVAL                                                   ::altera_xcvr_native_sv::parameters::validate_l_netlist_plls                      NOVAL     NOVAL}\
    {l_rcfg_interfaces                      true    false         INTEGER   0                               NOVAL                                                                     true                                false                                 NOVAL         NOVAL         NOVAL                                         NOVAL                                                   ::altera_xcvr_native_sv::parameters::validate_l_rcfg_interfaces                   NOVAL     NOVAL}\
    {l_rcfg_to_xcvr_width                   true    false         INTEGER   0                               NOVAL                                                                     true                                false                                 NOVAL         NOVAL         NOVAL                                         NOVAL                                                   ::altera_xcvr_native_sv::parameters::validate_l_rcfg_to_xcvr_width                NOVAL     NOVAL}\
    {l_rcfg_from_xcvr_width                 true    false         INTEGER   0                               NOVAL                                                                     true                                false                                 NOVAL         NOVAL         NOVAL                                         NOVAL                                                   ::altera_xcvr_native_sv::parameters::validate_l_rcfg_from_xcvr_width              NOVAL     NOVAL}\
    {l_pma_direct_word_count                true    false         INTEGER   0                               NOVAL                                                                     true                                false                                 NOVAL         NOVAL         NOVAL                                         NOVAL                                                   ::altera_xcvr_native_sv::parameters::validate_l_pma_direct_word_count             NOVAL     NOVAL}\
    {l_pma_direct_word_width                true    false         INTEGER   0                               NOVAL                                                                     true                                false                                 NOVAL         NOVAL         NOVAL                                         NOVAL                                                   ::altera_xcvr_native_sv::parameters::validate_l_pma_direct_word_width             NOVAL     NOVAL}\
    {l_std_tx_word_count                    true    false         INTEGER   0                               NOVAL                                                                     true                                false                                 NOVAL         NOVAL         NOVAL                                         NOVAL                                                   ::altera_xcvr_native_sv::parameters::validate_l_std_tx_word_count                 NOVAL     NOVAL}\
    {l_std_tx_word_width                    true    false         INTEGER   0                               NOVAL                                                                     true                                false                                 NOVAL         NOVAL         NOVAL                                         NOVAL                                                   ::altera_xcvr_native_sv::parameters::validate_l_std_tx_word_width                 NOVAL     NOVAL}\
    {l_std_tx_field_width                   true    false         INTEGER   0                               NOVAL                                                                     true                                false                                 NOVAL         NOVAL         NOVAL                                         NOVAL                                                   ::altera_xcvr_native_sv::parameters::validate_l_std_tx_field_width                NOVAL     NOVAL}\
    {l_std_rx_word_count                    true    false         INTEGER   0                               NOVAL                                                                     true                                false                                 NOVAL         NOVAL         NOVAL                                         NOVAL                                                   ::altera_xcvr_native_sv::parameters::validate_l_std_rx_word_count                 NOVAL     NOVAL}\
    {l_std_rx_word_width                    true    false         INTEGER   0                               NOVAL                                                                     true                                false                                 NOVAL         NOVAL         NOVAL                                         NOVAL                                                   ::altera_xcvr_native_sv::parameters::validate_l_std_rx_word_width                 NOVAL     NOVAL}\
    {l_std_rx_field_width                   true    false         INTEGER   0                               NOVAL                                                                     true                                false                                 NOVAL         NOVAL         NOVAL                                         NOVAL                                                   ::altera_xcvr_native_sv::parameters::validate_l_std_rx_field_width                NOVAL     NOVAL}\
  }

  set parameter_upgrade_map {
    {VERSION        OLD_PARAMETER               PARAMETER                   VAL_MAP }\
    {12.0           pma_width                   pma_direct_width            NOVAL   }\
    {12.0           set_rx_signaldetect_enable  enable_port_rx_signaldetect NOVAL   }\
    {12.0           set_rx_seriallpbken_enable  enable_port_rx_seriallpbken NOVAL   }\
    {12.0           teng_rx_scram_enable        teng_rx_descram_enable      NOVAL   }\
    {12.0           teng_txfifo_pempty          teng_txfifo_pempty          {7 2}   }\
  }
}

proc ::altera_xcvr_native_sv::parameters::declare_parameters { {device_family "Stratix V"} } {
  variable display_items
  variable parameters
  ip_declare_parameters $parameters
  ip_declare_display_items $display_items

  # Initialize device information (to allow sharing of this function across device families)
  ip_set "parameter.device_family.SYSTEM_INFO" DEVICE_FAMILY
  ip_set "parameter.device_family.DEFAULT_VALUE" $device_family
  ip_set "parameter.device_family.ALLOWED_RANGES" [list $device_family]
  ip_set "parameter.device_speedgrade.allowed_ranges" [::alt_xcvr::utils::device::get_device_speedgrades $device_family]

}

proc ::altera_xcvr_native_sv::parameters::validate {} {
  ::alt_xcvr::ip_tcl::messages::set_auto_message_level [ip_get "parameter.message_level.value"]
  ip_validate_parameters
}

proc ::altera_xcvr_native_sv::parameters::upgrade {ip_name version old_params} {
  variable parameter_upgrade_map
  ip_upgrade $ip_name $version $old_params $parameter_upgrade_map
}

#******************************************************************************
#************************ Validation Callbacks ********************************

proc ::altera_xcvr_native_sv::parameters::validate_show_advanced_features { show_advanced_features } {
#  set visible false
#  if { $show_advanced_features } {
#    set visible true
#  }
#  ip_set "parameter.show_advanced_features.visible" $visible
}


proc ::altera_xcvr_native_sv::parameters::validate_rx_enable { tx_enable rx_enable } {
  if {!$tx_enable && !$rx_enable} {
    ip_message error "Either the TX or RX datapath must be enabled"
  }
}


proc ::altera_xcvr_native_sv::parameters::validate_enable_simple_interface { enable_simple_interface enable_teng enable_std teng_pld_pcs_width } {
  set legal_values [expr {$enable_teng && $enable_std ? {0}
    : $enable_teng && ($teng_pld_pcs_width > 64) ? {0}
      : {0 1} }]

  if {$enable_simple_interface} {
    ip_message info "Simplified data interface has been enabled. The IP core will present the data/control interface for the current configuration only. Dynamic reconfiguration of the data interface cannot be supported."
  }
  auto_invalid_value_message error enable_simple_interface $enable_simple_interface $legal_values { enable_std enable_teng teng_pld_pcs_width }
}


proc ::altera_xcvr_native_sv::parameters::validate_set_data_rate { set_data_rate device_family device_speedgrade tx_enable rx_enable message_level data_path_select \
    pma_width \
    std_protocol_hint std_pcs_pma_width std_tx_pcfifo_mode std_rx_pcfifo_mode std_low_latency_bypass_enable std_tx_byte_ser_enable std_rx_byte_deser_enable \
    teng_protocol_hint teng_pld_pcs_width teng_pcs_pma_width } {

  # TODO - temporary
  variable l_legal_params
  #set l_legal_params 0

  if {![string is double $set_data_rate]} {
    ip_message error "[ip_get "parameter.set_data_rate.display_name"] is improperly formatted. Should be ###.##."
    return
  } 

  # Temporary warning message for PMA direct interface running above 300MHz.
  if { $data_path_select == "pma_direct" } {
    set interface_rate [expr $set_data_rate / $pma_width]
    if { [expr $interface_rate > 300] } {
      ip_message warning "The current PMA direct mode PLD<->PMA interface speed exceeds 300MHz. This is expected to have difficulty closing timing. Final timing analysis and closure will be performed by Quartus."
    }
  } else {
    # 8G or 10G PCS data rate validation
    set device [::alt_xcvr::utils::device::get_typical_device $device_family $device_speedgrade]
    set pcs_datapath [expr { $data_path_select == "standard" ? "EIGHT_G_PCS" : "TEN_G_PCS" }]
    # 8G PCS parameters
    set pcs8g_pma_dw [expr {$std_pcs_pma_width == "8" ? "eight_bit"
      : $std_pcs_pma_width == "10" ? "ten_bit"
        : $std_pcs_pma_width == "16" ? "sixteen_bit"
          : $std_pcs_pma_width == "20" ? "twenty_bit"
            : "twenty_bit" }]
      
    set pcs8g_pcs_bypass [expr {$std_low_latency_bypass_enable ? "en_pcs_bypass" : "dis_pcs_bypass" }]
    set pcs8g_tx_byte_serializer [expr {$std_tx_byte_ser_enable ? "en_bs_by_2" : "dis_bs"}]
    set pcs8g_rx_byte_deserializer [expr {$std_rx_byte_deser_enable ? "en_bds_by_2" : "dis_bds"}]
    # TODO - temporary
    set teng_protocol_hint "basic"

    if {$tx_enable} {
      # Required arguments (12.1.79)
      #part
      #this stratixv_hssi_pma_tx_cgb data_rate
      #txpcspmaif stratixv_hssi_tx_pcs_pma_interface selectpcs
      #txpma stratixv_hssi_pma_tx_ser mode
      #txpcs8g stratixv_hssi_8g_tx_pcs prot_mode
      #txpcs8g stratixv_hssi_8g_tx_pcs pma_dw
      #txpcs8g stratixv_hssi_8g_tx_pcs pcs_bypass
      #txpcs8g stratixv_hssi_8g_tx_pcs byte_serializer
      #txpcs8g stratixv_hssi_8g_tx_pcs phase_compensation_fifo
      #txpcs10g stratixv_hssi_10g_tx_pcs prot_mode
      #txpcs10g stratixv_hssi_10g_tx_pcs gb_tx_idwidth
      #txpcs10g stratixv_hssi_10g_tx_pcs gb_tx_odwidth
      set arglist [list $device \
          $set_data_rate \
          $pcs_datapath \
          $pma_width \
          \
          $std_protocol_hint \
          $pcs8g_pma_dw \
          $pcs8g_pcs_bypass \
          $pcs8g_tx_byte_serializer \
          $std_tx_pcfifo_mode \
          \
          "${teng_protocol_hint}_mode" \
          "width_${teng_pld_pcs_width}" \
          "width_${teng_pcs_pma_width}"]

      set cmd "quartus::advanced_hssi_legality::get_advanced_hssi_legality_legal_values -flow_type MEGAWIZARD -configuration_name STRATIXV_HSSI_CONFIG  -rule_name \
        STRATIXV_HSSI_TX_PCS_DATA_RATE -param_args \{$arglist\}"

      #puts "calling $cmd"
      set return_value_PCS [eval $cmd]
    } else {
      # Required arguments (12.1.79)
      #part
      #this stratixv_channel_pll output_clock_frequency
      #rxpcspmaif stratixv_hssi_rx_pcs_pma_interface selectpcs
      #rxpma stratixv_hssi_pma_rx_deser mode
      #rxpcs8g stratixv_hssi_8g_rx_pcs prot_mode
      #rxpcs8g stratixv_hssi_8g_rx_pcs pma_dw
      #rxpcs8g stratixv_hssi_8g_rx_pcs pcs_bypass
      #rxpcs8g stratixv_hssi_8g_rx_pcs byte_deserializer
      #rxpcs8g stratixv_hssi_8g_rx_pcs phase_compensation_fifo
      #rxpcs10g stratixv_hssi_10g_rx_pcs prot_mode
      #rxpcs10g stratixv_hssi_10g_rx_pcs gb_rx_idwidth
      #rxpcs10g stratixv_hssi_10g_rx_pcs gb_rx_odwidth
        set arglist [list $device \
          [expr $set_data_rate / 2.0] \
          $pcs_datapath \
          $pma_width \
          \
          $std_protocol_hint \
          $pcs8g_pma_dw \
          $pcs8g_pcs_bypass \
          $pcs8g_rx_byte_deserializer \
          $std_rx_pcfifo_mode \
          \
          "${teng_protocol_hint}_mode" \
          "width_${teng_pcs_pma_width}" \
          "width_${teng_pld_pcs_width}"]
      
      set cmd "quartus::advanced_hssi_legality::get_advanced_hssi_legality_legal_values -flow_type MEGAWIZARD -configuration_name STRATIXV_HSSI_CONFIG  -rule_name \
        STRATIXV_HSSI_RX_PCS_DATA_RATE -param_args \{$arglist\}"

      #puts "calling $cmd"
      set return_value_PCS [eval $cmd]
    }
    
    #strip off {{ and }} from RBC
    set return_value_PCS [alt_xcvr::utils::rbc::rbc_values_cleanup $return_value_PCS]

    # Make sure we got something back to avoid TCL crash
    if { [expr {![info exists return_value_PCS]}] } {
      ::alt_xcvr::gui::messages::internal_error_message "PCS data rate check returned unexpected value $return_value_PCS"
      return
    }

    # Extract rate fields
    regexp -nocase {([0-9.]+).([a-z]+)\.+([0-9.]+).([a-z]+)} $return_value_PCS match min_rate unit_min max_rate unit_max

    # Check legality
    if { [expr {![info exists min_rate]} || {![info exists max_rate]} ] } {
      ip_message warning "PCS data rate check was not performed. The current configuration may not be legal when compiled in Quartus."
      ::alt_xcvr::gui::messages::internal_error_message "PCS data rate check returned unexpected value $return_value_PCS"
      return
    }
    
    # STRATIXV_HSSI_RX_PCS_DATA_RATE returns output clock frequency rather than data rate
    if {!$tx_enable} {
      set max_rate [expr $max_rate*2]
      set min_rate [expr $min_rate*2]
    }  

    if { $set_data_rate < $min_rate || $set_data_rate > $max_rate} {
      set message [get_invalid_current_value_string set_data_rate $set_data_rate]
      set message "${message} The value must be between $min_rate Mbps and $max_rate Mbps for the current configuration."
      set antecedents [expr {$data_path_select == "standard" && $tx_enable == "1" ? {device_speedgrade data_path_select std_protocol_hint std_pcs_pma_width std_tx_pcfifo_mode}
        : $data_path_select == "standard" && $rx_enable == "1" ? {device_speedgrade data_path_select std_protocol_hint std_pcs_pma_width std_rx_pcfifo_mode}
          : $data_path_select == "10G" ? {device_speedgrade data_path_select teng_protocol_hint teng_pld_pcs_width teng_pcs_pma_width}
            : {device_speedgrade data_path_select} }]
      set message "${message} [get_invalid_antecedents_string $antecedents]"
      ip_message $message_level $message
    }
  }
  # End PCS data rate check

}


proc ::altera_xcvr_native_sv::parameters::validate_data_rate { set_data_rate } {
  ip_set "parameter.data_rate.value" "${set_data_rate} Mbps"
}


proc ::altera_xcvr_native_sv::parameters::validate_pma_width { data_path_select pma_direct_width std_pcs_pma_width teng_pcs_pma_width } {
  set value [expr { $data_path_select == "standard" ? $std_pcs_pma_width
      : $data_path_select == "10G" ? $teng_pcs_pma_width
        : $pma_direct_width }]

  ip_set "parameter.pma_width.value" $value
# ip_set "parameter.pma_width.visible" [expr {$data_path_select != "pma_direct"}]
}


proc ::altera_xcvr_native_sv::parameters::validate_pma_direct_width { data_path_select } {
  ip_set "parameter.pma_direct_width.visible" [expr {$data_path_select == "pma_direct"}]
}


proc ::altera_xcvr_native_sv::parameters::validate_tx_pma_txdetectrx_ctrl { tx_enable enable_port_tx_pma_txdetectrx } {
  set value [expr { $tx_enable && $enable_port_tx_pma_txdetectrx ? 1 
      : 0 }]

  ip_set "parameter.tx_pma_txdetectrx_ctrl.value" $value
}


proc ::altera_xcvr_native_sv::parameters::validate_base_data_rate { set_data_rate tx_pma_clk_div } {
  if {[string is double $set_data_rate]} {
    ip_set "parameter.base_data_rate.value" [expr $set_data_rate * $tx_pma_clk_div]
  }
}


proc ::altera_xcvr_native_sv::parameters::validate_pll_data_rate { plls  \
  gui_pll_reconfig_pll0_data_rate_der gui_pll_reconfig_pll1_data_rate_der gui_pll_reconfig_pll2_data_rate_der gui_pll_reconfig_pll3_data_rate_der } {

  set vals {}
  for {set x 0} {$x < $plls} {incr x} {
    lappend vals [set "gui_pll_reconfig_pll${x}_data_rate_der"]
  }
  
  ip_set "parameter.pll_data_rate.value" [::alt_xcvr::utils::common::convert_list_to_csv_string $vals $plls]
}


proc ::altera_xcvr_native_sv::parameters::validate_pll_type { plls \
  gui_pll_reconfig_pll0_pll_type gui_pll_reconfig_pll1_pll_type gui_pll_reconfig_pll2_pll_type gui_pll_reconfig_pll3_pll_type } {

  set vals {}
  for {set x 0} {$x < $plls} {incr x} {
    lappend vals [set "gui_pll_reconfig_pll${x}_pll_type"]
  }
  
  ip_set "parameter.pll_type.value" [::alt_xcvr::utils::common::convert_list_to_csv_string $vals $plls]
}


proc ::altera_xcvr_native_sv::parameters::validate_pll_network_select { plls bonded_mode \
  gui_pll_reconfig_pll0_clk_network gui_pll_reconfig_pll1_clk_network gui_pll_reconfig_pll2_clk_network gui_pll_reconfig_pll3_clk_network } {

  set vals {}
  for {set x 0} {$x < $plls} {incr x} {
    set val [expr {$bonded_mode == "non_bonded" ? [set "gui_pll_reconfig_pll${x}_clk_network"] : "x1" }]
    lappend vals $val
  }
  
  ip_set "parameter.pll_network_select.value" [::alt_xcvr::utils::common::convert_list_to_csv_string $vals $plls]
}


proc ::altera_xcvr_native_sv::parameters::validate_plls { tx_enable bonded_mode plls } {
  if {$tx_enable && $bonded_mode != "non_bonded" && $plls > 1} {
    ip_message error "[ip_get "parameter.plls.display_name"] cannot exceed 1 when using TX channel bonding"
  }
}


###
# Validation for the pll_select parameter
#
# @param plls - Resolved value of the plls parameter
proc ::altera_xcvr_native_sv::parameters::validate_pll_select { tx_enable plls pll_select } {
  set allowed_ranges {}
  if {!$tx_enable} {
    set allowed_ranges [list $pll_select]
  } else {
    for {set i 0} {$i < $plls} {incr i} {
      lappend allowed_ranges $i
    }
  }

  ip_set "parameter.pll_select.allowed_ranges" $allowed_ranges
}


proc ::altera_xcvr_native_sv::parameters::validate_pll_external_enable { tx_enable pll_external_enable bonded_mode base_data_rate pll_select} {
  set legal_values [expr {!$tx_enable ? $pll_external_enable
    : $bonded_mode == "fb_compensation" && $pll_external_enable ? 0
      : {0 1} }]

  auto_invalid_value_message auto pll_external_enable $pll_external_enable $legal_values {bonded_mode}

  if {$pll_external_enable && $tx_enable && [lindex $legal_values 1] != -1} {
    ip_message info "External PLL base data rate for PLL ${pll_select} must be set to ${base_data_rate} Mbps \([expr $base_data_rate / 2] MHz\)." 
  }
}


###
# Validation for the pll_refclk_select parameter
#
proc ::altera_xcvr_native_sv::parameters::validate_pll_refclk_select { plls \
  gui_pll_reconfig_pll0_refclk_sel gui_pll_reconfig_pll1_refclk_sel gui_pll_reconfig_pll2_refclk_sel gui_pll_reconfig_pll3_refclk_sel } {

  set vals {}
  for {set x 0} {$x < $plls} {incr x} {
    lappend vals [set "gui_pll_reconfig_pll${x}_refclk_sel"]
  }
  
  ip_set "parameter.pll_refclk_select.value" [::alt_xcvr::utils::common::convert_list_to_csv_string $vals $plls]
}


###
# Validation for the pll_refclk_freq parameter
# Performs two functions:
# 1 - Set value of "pll_refclk_freq" - Aggregate individual refclk frequency parameter values to single comma-separated string
# 2 - Cross check individual refclk frequencies for consistency. Issue warning if inconsistent
proc ::altera_xcvr_native_sv::parameters::validate_pll_refclk_freq { plls pll_refclk_cnt \
  gui_pll_reconfig_pll0_refclk_sel gui_pll_reconfig_pll1_refclk_sel gui_pll_reconfig_pll2_refclk_sel gui_pll_reconfig_pll3_refclk_sel \
  gui_pll_reconfig_pll0_refclk_freq gui_pll_reconfig_pll1_refclk_freq gui_pll_reconfig_pll2_refclk_freq gui_pll_reconfig_pll3_refclk_freq } {

  set vals {}
  for {set x 0} {$x < $pll_refclk_cnt} {incr x} {
    lappend vals "unused"
  }

  for {set x 0} {$x < $plls} {incr x} {
    set this_refclk_sel [set "gui_pll_reconfig_pll${x}_refclk_sel"]
    set this_refclk_freq [set "gui_pll_reconfig_pll${x}_refclk_freq"]

    if {$this_refclk_sel < $pll_refclk_cnt} { 
      set vals [lreplace $vals $this_refclk_sel $this_refclk_sel $this_refclk_freq]
    }
  }

  ip_set "parameter.pll_refclk_freq.value" [::alt_xcvr::utils::common::convert_list_to_csv_string $vals $pll_refclk_cnt]

  # Cross-check PLL reference clock frequencies for consistency. Issue 
  # warning if inconsistent (can't assume user isn't doing it intentionally)
  for {set x 0} {$x < $plls} {incr x} {
    set this_refclk_sel [set "gui_pll_reconfig_pll${x}_refclk_sel"]
    set this_refclk_freq [set "gui_pll_reconfig_pll${x}_refclk_freq"]

    for {set y [expr {$x + 1}]} {$y < $plls} {incr y} {
      set that_refclk_sel [set "gui_pll_reconfig_pll${y}_refclk_sel"]
      if { $this_refclk_sel == $that_refclk_sel } {
        set that_refclk_freq [set "gui_pll_reconfig_pll${y}_refclk_freq"]
        if { $this_refclk_freq  != $that_refclk_freq } {
          ip_message warning "Logical PLL ${x} and Logical PLL ${y} specify the same logical input clock (${this_refclk_sel}) with different frequencies."
        }
      }
    }
  }
  
}


proc ::altera_xcvr_native_sv::parameters::validate_gui_pll_reconfig_pll_pll_type {PROP_NAME PROP_M_CONTEXT tx_enable pll_external_enable plls} {
  set enabled [expr {$tx_enable && !$pll_external_enable && ($PROP_M_CONTEXT < $plls) ? "true" : "false" }]

  ip_set "parameter.${PROP_NAME}.enabled" $enabled
  ip_set "parameter.${PROP_NAME}.visible" $enabled

}


proc ::altera_xcvr_native_sv::parameters::validate_gui_pll_reconfig_pll_data_rate {PROP_NAME PROP_VALUE PROP_M_CONTEXT \
  tx_enable pll_external_enable plls pll_select } {

  set enabled [expr {$tx_enable && !$pll_external_enable && ($PROP_M_CONTEXT < $plls) && ($PROP_M_CONTEXT != $pll_select)? "true" : "false" }]

  ip_set "parameter.${PROP_NAME}.enabled" $enabled
  ip_set "parameter.${PROP_NAME}.visible" $enabled

  if {$enabled == "true"} {
    if { ![::alt_xcvr::utils::common::validate_data_rate_string $PROP_VALUE] } {
      ip_message error "The specified data rate for TX PLL $PROP_M_CONTEXT is improperly formatted"
      ::alt_xcvr::gui::messages::data_rate_format_error
    }
  }

}


proc ::altera_xcvr_native_sv::parameters::validate_gui_pll_reconfig_pll_data_rate_der {PROP_NAME PROP_M_CONTEXT \
  tx_enable pll_external_enable plls pll_select base_data_rate \
  gui_pll_reconfig_pll0_data_rate gui_pll_reconfig_pll1_data_rate gui_pll_reconfig_pll2_data_rate gui_pll_reconfig_pll3_data_rate} {

  set enabled [expr {$tx_enable && !$pll_external_enable && ($PROP_M_CONTEXT < $plls) && ($PROP_M_CONTEXT == $pll_select)? "true" : "false" }]

  ip_set "parameter.${PROP_NAME}.enabled" $enabled
  ip_set "parameter.${PROP_NAME}.visible" $enabled

  if {$PROP_M_CONTEXT == $pll_select} {
    ip_set "parameter.${PROP_NAME}.value" "$base_data_rate Mbps"
  } else {
    ip_set "parameter.${PROP_NAME}.value" [set "gui_pll_reconfig_pll${PROP_M_CONTEXT}_data_rate"]
  }

}


proc ::altera_xcvr_native_sv::parameters::validate_gui_pll_reconfig_pll_refclk_freq {PROP_NAME PROP_VALUE PROP_M_CONTEXT \
  tx_enable pll_external_enable plls pll_select base_data_rate device_family bonded_mode pma_width data_rate\
  gui_pll_reconfig_pll0_pll_type gui_pll_reconfig_pll1_pll_type gui_pll_reconfig_pll2_pll_type gui_pll_reconfig_pll3_pll_type \
  gui_pll_reconfig_pll0_data_rate gui_pll_reconfig_pll1_data_rate gui_pll_reconfig_pll2_data_rate gui_pll_reconfig_pll3_data_rate } {

  set enabled [expr {$tx_enable && !$pll_external_enable && ($PROP_M_CONTEXT < $plls) ? "true" : "false" }]

  ip_set "parameter.${PROP_NAME}.enabled" $enabled
  ip_set "parameter.${PROP_NAME}.visible" $enabled

  set result {}
  if {$enabled == "true"} {
    if {$PROP_M_CONTEXT == $pll_select} {
      set pll_feedback [expr { $bonded_mode == "fb_compensation" ? "PMA" : "internal" }]

      set result \
        [::alt_xcvr::utils::rbc::get_valid_refclks  $device_family \
                                                      "$base_data_rate Mbps" \
                                                      [set "gui_pll_reconfig_pll${PROP_M_CONTEXT}_pll_type"] \
                                                      "false" \
                                                      $pll_feedback \
                                                      $pma_width \
                                                      $data_rate \
                                                      "disabled"]
    
    } else {
      set result \
        [::alt_xcvr::utils::rbc::get_valid_refclks  $device_family \
                                                      [set "gui_pll_reconfig_pll${PROP_M_CONTEXT}_data_rate"] \
                                                      [set "gui_pll_reconfig_pll${PROP_M_CONTEXT}_pll_type"]] 
    }

    # Issue error message if no valid reference clock frequencies could be found for this data rate
    if {$result == "N/A"} {
      ip_message error "The selected data rate \"[set "gui_pll_reconfig_pll${PROP_M_CONTEXT}_data_rate"]\" for TX PLL $PROP_M_CONTEXT cannot be achieved for the selected PLL type and channel configuration."
      set result {}
    }
    # Issue message if current selected reference clock value is illegal
    if {[lsearch $result $PROP_VALUE] == -1} {
      ip_message error "The selected reference clock frequency \"${PROP_VALUE}\" for TX PLL ${PROP_M_CONTEXT} is invalid. Please select a valid PLL reference clock frequency or choose a different data rate."
      lappend result $PROP_VALUE
    }
  } else {
    set result [list $PROP_VALUE]
  }
  ip_set "parameter.${PROP_NAME}.allowed_ranges" $result
}


proc ::altera_xcvr_native_sv::parameters::validate_gui_pll_reconfig_pll_refclk_sel  {PROP_NAME PROP_VALUE PROP_M_CONTEXT \
  tx_enable pll_external_enable plls pll_refclk_cnt } {

  set enabled [expr {$tx_enable && !$pll_external_enable && ($PROP_M_CONTEXT < $plls) ? "true" : "false" }]

  ip_set "parameter.${PROP_NAME}.enabled" $enabled
  ip_set "parameter.${PROP_NAME}.visible" $enabled

  set range {}
  if {$enabled == "true"} {
    for {set x 0} {$x < $pll_refclk_cnt} {incr x} {
      lappend range $x
    }
  } else {
    set range [list $PROP_VALUE]
  }

  ip_set "parameter.${PROP_NAME}.allowed_ranges" $range
}


proc ::altera_xcvr_native_sv::parameters::validate_gui_pll_reconfig_pll_clk_network {PROP_NAME PROP_M_CONTEXT \
  tx_enable pll_external_enable plls bonded_mode} {

  set enabled [expr {$tx_enable && ($bonded_mode == "non_bonded") && ($PROP_M_CONTEXT < $plls) ? "true" : "false" }]

  ip_set "parameter.${PROP_NAME}.enabled" $enabled
  ip_set "parameter.${PROP_NAME}.visible" $enabled
}


###
# Validation for the cdr_refclk_select parameter
#
# @param cdr_refclk_cnt - Resolved value of the cdr_refclk_cnt parameter
proc ::altera_xcvr_native_sv::parameters::validate_cdr_refclk_select { cdr_refclk_cnt } {
  set allowed_ranges {}
  for {set i 0} {$i < $cdr_refclk_cnt} {incr i} {
    lappend allowed_ranges $i
  }

  ip_set "parameter.cdr_refclk_select.allowed_ranges" $allowed_ranges
}


###
# Validation for cdr_refclk_freq parameter.
#
# @param cdr_refclk_cnt - Resolved value of cdr_refclk_cnt parameter
# @param cdr_refclk_select - Resolved value of cdr_refclk_select parameter
proc ::altera_xcvr_native_sv::parameters::validate_cdr_refclk_freq { cdr_refclk_cnt cdr_refclk_select set_cdr_refclk_freq } {
  set value ""
  for {set i 0} {$i < $cdr_refclk_cnt} {incr i} {
    if { $i != 0 } {
      set value "${value},"
    }
    # Use the specified reference clock frequency
    if {$i == $cdr_refclk_select} {
      set value "${value}$set_cdr_refclk_freq"
    } else {
      set value "${value}0"
    }
  }

  ip_set "parameter.cdr_refclk_freq.value" $value
}


###
# Validation for the set_cdr_refclk_freq parameter
#
# @param device_family - Resolved value of the device_family parameter
# @param data_rate - Resolved value of the data_rate parameter
proc ::altera_xcvr_native_sv::parameters::validate_set_cdr_refclk_freq { set_cdr_refclk_freq rx_enable device_family device_speedgrade data_rate } {
  set allowed_ranges {}
  if {$rx_enable} {
    # Retreive legal reference clock frequencies from RBC
    set allowed_ranges [::alt_xcvr::utils::rbc::get_valid_refclks $device_family $data_rate [::alt_xcvr::utils::device::get_cmu_pll_name]]
    if {$allowed_ranges == "N/A"} {
      ip_message error "The selected data rate for RX CDR cannot be achieved."
    }

    # Issue message if current selected value is illegal
    if {[lsearch $allowed_ranges $set_cdr_refclk_freq] == -1} {
      ip_message error "The selected CDR reference clock frequency \"$set_cdr_refclk_freq\" is invalid. Please select a valid CDR reference clock frequency or choose a different data rate."
      lappend allowed_ranges $set_cdr_refclk_freq
    }

  } else {
      lappend allowed_ranges $set_cdr_refclk_freq
  }

  ip_set "parameter.set_cdr_refclk_freq.allowed_ranges" $allowed_ranges

}


###
# Validation for the set_rx_seriallpbken_enable parameter
#
# @param tx_enable - Resolved value of the tx_enable parameter
# @param rx_enable - Resolved value of the rx_enable parameter
proc ::altera_xcvr_native_sv::parameters::validate_enable_port_rx_seriallpbken { tx_enable rx_enable } {
  set enabled false
  if {$tx_enable && $rx_enable} {
    set enabled true    
  }
  ip_set "parameter.enable_port_rx_seriallpbken.enabled" $enabled
}

###
# Validation for l_pll_settings parameter. Used to run configuration
# and validation of the pll_reconfig package.
#
# @param device_family - Resolved value of device_family parameter
# @param tx_enable - Resolved value of tx_enable parameter
proc ::altera_xcvr_native_sv::parameters::validate_l_pll_settings { tx_enable plls pll_external_enable bonded_mode } {
  for {set x 0} {$x < 4} {incr x} {
    set visible [expr { $tx_enable && ($x < $plls) && (!$pll_external_enable || $bonded_mode == "non_bonded") ? "true"
      : "false" }]

    ip_set "display_item.TX PLL ${x}.visible" $visible
  }
}


proc ::altera_xcvr_native_sv::parameters::validate_l_enable_tx_pma_direct { tx_enable data_path_select } {
  ip_set "parameter.l_enable_tx_pma_direct.value" [expr {$tx_enable && $data_path_select == "pma_direct"}]
}


proc ::altera_xcvr_native_sv::parameters::validate_l_enable_rx_pma_direct { rx_enable data_path_select } {
  ip_set "parameter.l_enable_rx_pma_direct.value" [expr {$rx_enable && $data_path_select == "pma_direct"}]
}

###
# Validation for l_enable_tx_std parameter. Used to determine
# when Standard TX PCS is enabled.
#
# @param tx_enable - Resolved value of the tx_enable parameter
# @param enable_std - Resolved value of the enable_std parameter
proc ::altera_xcvr_native_sv::parameters::validate_l_enable_tx_std { tx_enable enable_std } {
  ip_set "parameter.l_enable_tx_std.value" [expr $tx_enable && $enable_std]
}


###
# Validation for l_enable_rx_std parameter. Used to determine
# when Standard RX PCS is enabled.
#
# @param rx_enable - Resolved value of the rx_enable parameter
# @param enable_std - Resolved value of the enable_std parameter
proc ::altera_xcvr_native_sv::parameters::validate_l_enable_rx_std { rx_enable enable_std } {
  ip_set "parameter.l_enable_rx_std.value" [expr $rx_enable && $enable_std]
}


proc ::altera_xcvr_native_sv::parameters::validate_l_enable_rx_std_word_aligner { l_enable_rx_std std_rx_word_aligner_mode } {
  ip_set "parameter.l_enable_rx_std_word_aligner.value" [expr {$l_enable_rx_std && ($std_rx_word_aligner_mode != "bit_slip")}]
}


###
# Validation for l_enable_tx_teng parameter. Used to determine
# when 10G TX PCS is enabled.
#
# @param tx_enable - Resolved value of the tx_enable parameter
# @param enable_teng - Resolved value of the enable_teng parameter
proc ::altera_xcvr_native_sv::parameters::validate_l_enable_tx_teng { tx_enable enable_teng } {
  ip_set "parameter.l_enable_tx_teng.value" [expr $tx_enable && $enable_teng]
}


###
# Validation for l_enable_rx_teng parameter. Used to determine
# when 10G RX PCS is enabled.
#
# @param rx_enable - Resolved value of the rx_enable parameter
# @param enable_teng - Resolved value of the enable_teng parameter
proc ::altera_xcvr_native_sv::parameters::validate_l_enable_rx_teng { rx_enable enable_teng } {
  ip_set "parameter.l_enable_rx_teng.value" [expr $rx_enable && $enable_teng]
}


###
#
proc ::altera_xcvr_native_sv::parameters::validate_l_netlist_plls { bonded_mode plls channels } {
  if { $bonded_mode == "xN" } {
    ip_set "parameter.l_netlist_plls.value" $plls
  } elseif { $bonded_mode == "non_bonded" || $bonded_mode == "fb_compensation"} {
    ip_set "parameter.l_netlist_plls.value" [expr {$plls * $channels}]
  }
}

###
#
proc ::altera_xcvr_native_sv::parameters::validate_l_rcfg_interfaces { device_family tx_enable pll_external_enable l_netlist_plls channels } {
  if {!$tx_enable || $pll_external_enable} {
    set l_netlist_plls 0
  }
  ip_set "parameter.l_rcfg_interfaces.value" [::alt_xcvr::utils::device::get_reconfig_interface_count $device_family $channels $l_netlist_plls]
  ::alt_xcvr::gui::messages::reconfig_interface_message $device_family $channels $l_netlist_plls
}

###
# 
proc ::altera_xcvr_native_sv::parameters::validate_l_rcfg_to_xcvr_width { device_family l_rcfg_interfaces } {
   ip_set "parameter.l_rcfg_to_xcvr_width.value" [::alt_xcvr::utils::device::get_reconfig_to_xcvr_total_width $device_family $l_rcfg_interfaces]
}


proc ::altera_xcvr_native_sv::parameters::validate_l_rcfg_from_xcvr_width { device_family l_rcfg_interfaces } {
  ip_set "parameter.l_rcfg_from_xcvr_width.value" [::alt_xcvr::utils::device::get_reconfig_from_xcvr_total_width $device_family $l_rcfg_interfaces]
}


proc ::altera_xcvr_native_sv::parameters::validate_l_pma_direct_word_count { pma_direct_width } {
  ip_set "parameter.l_pma_direct_word_count.value" [expr {
        $pma_direct_width == "8" || $pma_direct_width == "10" ? 1
      : $pma_direct_width == "16" || $pma_direct_width == "20" ? 2
      : $pma_direct_width == "32" || $pma_direct_width == "40" ? 4
      : 8 }]
}


proc ::altera_xcvr_native_sv::parameters::validate_l_pma_direct_word_width { pma_direct_width } {
  ip_set "parameter.l_pma_direct_word_width.value" [expr {$pma_direct_width == "8" || $pma_direct_width == "16" || $pma_direct_width == "32" || $pma_direct_width == "64" ? 8 : 10 }]
}


proc ::altera_xcvr_native_sv::parameters::validate_l_std_tx_word_count { std_pcs_pma_width std_tx_byte_ser_enable } {
  set count [expr $std_pcs_pma_width <= 10 ? 1 : 2]
  if {$std_tx_byte_ser_enable} {
    set count [expr $count * 2]
  }
  ip_set "parameter.l_std_tx_word_count.value" $count
}


proc ::altera_xcvr_native_sv::parameters::validate_l_std_tx_word_width { std_tx_pld_pcs_width l_std_tx_word_count } {
  ip_set "parameter.l_std_tx_word_width.value" [expr $std_tx_pld_pcs_width / $l_std_tx_word_count]
}


proc ::altera_xcvr_native_sv::parameters::validate_l_std_tx_field_width { std_pcs_pma_width std_tx_byte_ser_enable } {
  set width 11
  if {$std_tx_byte_ser_enable && $std_pcs_pma_width <= 10} {
    set width [expr $width * 2]
  }
  ip_set "parameter.l_std_tx_field_width.value" $width

}


proc ::altera_xcvr_native_sv::parameters::validate_l_std_rx_word_count { std_pcs_pma_width std_rx_byte_deser_enable } {
  set count [expr $std_pcs_pma_width <= 10 ? 1 : 2]
  if {$std_rx_byte_deser_enable} {
    set count [expr $count * 2]
  }
  ip_set "parameter.l_std_rx_word_count.value" $count
}


proc ::altera_xcvr_native_sv::parameters::validate_l_std_rx_word_width { std_rx_pld_pcs_width l_std_rx_word_count } {
  ip_set "parameter.l_std_rx_word_width.value" [expr $std_rx_pld_pcs_width / $l_std_rx_word_count]
}


proc ::altera_xcvr_native_sv::parameters::validate_l_std_rx_field_width { std_pcs_pma_width std_rx_byte_deser_enable } {
  set width 16
  if {$std_rx_byte_deser_enable && $std_pcs_pma_width <= 10} {
    set width [expr $width * 2]
  }
  ip_set "parameter.l_std_rx_field_width.value" $width

}


#******************************************************************************
#******************* Standard PCS validation callbacks ************************
#
proc ::altera_xcvr_native_sv::parameters::validate_enable_std { enable_std } {
  ip_set "display_item.Standard PCS.visible" [expr {$enable_std ? "true" : "false" }]
}


proc ::altera_xcvr_native_sv::parameters::validate_enable_teng { enable_teng } {
  ip_set "display_item.10G PCS.visible" [expr { $enable_teng ? "true" : "false" }]
}


proc ::altera_xcvr_native_sv::parameters::validate_data_path_select { set_data_path_select enable_std enable_teng } {
  set legal_values [expr {$enable_std && $enable_teng ? $set_data_path_select
    : $enable_std ? "standard"
      : $enable_teng ? "10G"
        : "pma_direct" }]

  ip_set "parameter.data_path_select.value" $legal_values
}

proc ::altera_xcvr_native_sv::parameters::validate_std_pcs_pma_width { std_pcs_pma_width enable_std std_protocol_hint } {
  set legal_values [expr { !$enable_std ? $std_pcs_pma_width
    : ( $std_protocol_hint == "srio_2p1" ) ? {20}
      : ( $std_protocol_hint == "basic" ) ? {8 10 16 20}
        : ( ( $std_protocol_hint == "cpri")  ||  ($std_protocol_hint == "cpri_rx_tx")) ? {10 20}
          : {10} }]
  
  auto_invalid_value_message auto std_pcs_pma_width $std_pcs_pma_width $legal_values {std_protocol_hint}
}


proc ::altera_xcvr_native_sv::parameters::validate_std_tx_pld_pcs_width { std_pcs_pma_width std_tx_byte_ser_enable std_tx_8b10b_enable } {
  set legal_value [expr { $std_tx_byte_ser_enable ? [expr $std_pcs_pma_width * 2]
    : $std_pcs_pma_width }]
  set legal_value [expr { $std_tx_8b10b_enable ? [expr {$legal_value * 4} / 5]
    : $legal_value }]

  ip_set "parameter.std_tx_pld_pcs_width.value" $legal_value
}


proc ::altera_xcvr_native_sv::parameters::validate_std_rx_pld_pcs_width { std_pcs_pma_width std_rx_byte_deser_enable std_rx_8b10b_enable } {
  set legal_value [expr { $std_rx_byte_deser_enable ? [expr $std_pcs_pma_width * 2]
    : $std_pcs_pma_width }]
  set legal_value [expr { $std_rx_8b10b_enable ? [expr {$legal_value * 4} / 5]
    : $legal_value }]

  ip_set "parameter.std_rx_pld_pcs_width.value" $legal_value
}


proc ::altera_xcvr_native_sv::parameters::validate_std_low_latency_bypass_enable { std_low_latency_bypass_enable enable_std std_protocol_hint } {
  set legal_values [expr { !$enable_std ? $std_low_latency_bypass_enable 
    : (($std_protocol_hint == "basic") ||  ($std_protocol_hint == "cpri_rx_tx")) ? {0 1}
      : {0} }]

  auto_invalid_value_message auto std_low_latency_bypass_enable $std_low_latency_bypass_enable $legal_values {std_protocol_hint}
}


proc ::altera_xcvr_native_sv::parameters::validate_std_tx_pcfifo_mode { std_tx_pcfifo_mode l_enable_tx_std std_protocol_hint } {
  set legal_values [expr { !$l_enable_tx_std ? $std_tx_pcfifo_mode
    : ($std_protocol_hint == "cpri" || $std_protocol_hint == "cpri_rx_tx") ? {"register_fifo"}
      : ($std_protocol_hint == "basic"  || $std_protocol_hint == "gige") ? {"low_latency" "register_fifo"}
        : {"low_latency"} }]
  
  auto_invalid_value_message auto std_tx_pcfifo_mode $std_tx_pcfifo_mode $legal_values {std_protocol_hint}
}


proc ::altera_xcvr_native_sv::parameters::validate_std_rx_pcfifo_mode {std_rx_pcfifo_mode l_enable_rx_std std_protocol_hint } {
  set legal_values [expr { !$l_enable_rx_std ? $std_rx_pcfifo_mode
    : ($std_protocol_hint == "cpri" || $std_protocol_hint == "cpri_rx_tx") ? {register_fifo}
      : ($std_protocol_hint == "basic"  || $std_protocol_hint == "gige") ? {low_latency register_fifo}
        : {low_latency} }]
  
  auto_invalid_value_message auto std_rx_pcfifo_mode $std_rx_pcfifo_mode $legal_values {std_protocol_hint}
}


proc ::altera_xcvr_native_sv::parameters::validate_std_tx_8b10b_enable { std_tx_8b10b_enable l_enable_tx_std std_pcs_pma_width std_low_latency_bypass_enable std_protocol_hint } {
  set legal_values [expr { !$l_enable_tx_std ? $std_tx_8b10b_enable
    : ($std_pcs_pma_width == "8")  || ($std_pcs_pma_width == "16") || ($std_low_latency_bypass_enable == "1") ? {0}
      : ($std_protocol_hint == "basic" ) &&  ($std_low_latency_bypass_enable == "0") ? {0 1}
        : {1} }]
    
  auto_invalid_value_message auto std_tx_8b10b_enable $std_tx_8b10b_enable $legal_values {std_protocol_hint std_pcs_pma_width std_low_latency_bypass_enable}
}


proc ::altera_xcvr_native_sv::parameters::validate_std_tx_8b10b_disp_ctrl_enable { std_tx_8b10b_disp_ctrl_enable l_enable_tx_std std_protocol_hint } {
  set legal_values [expr { !$l_enable_tx_std ? $std_tx_8b10b_disp_ctrl_enable
    : ( $std_protocol_hint == "basic") ? {0 1}
      : {0} }]

  auto_invalid_value_message auto std_tx_8b10b_disp_ctrl_enable $std_tx_8b10b_disp_ctrl_enable $legal_values { std_protocol_hint }
}


proc ::altera_xcvr_native_sv::parameters::validate_std_rx_8b10b_enable { std_rx_8b10b_enable l_enable_rx_std std_pcs_pma_width std_low_latency_bypass_enable std_protocol_hint } {
  set legal_values [expr { !$l_enable_rx_std ? $std_rx_8b10b_enable
    : ($std_pcs_pma_width == "8")  || ($std_pcs_pma_width == "16") || ($std_low_latency_bypass_enable == "1") ? {0}
      : ($std_protocol_hint == "basic") &&  ($std_low_latency_bypass_enable == "0") ? {0 1}
        : {1} }]
    
  auto_invalid_value_message auto std_rx_8b10b_enable $std_rx_8b10b_enable $legal_values {std_protocol_hint std_pcs_pma_width std_low_latency_bypass_enable}
}


proc ::altera_xcvr_native_sv::parameters::validate_std_rx_rmfifo_enable {std_rx_rmfifo_enable l_enable_rx_std std_protocol_hint std_pcs_pma_width std_rx_word_aligner_mode std_low_latency_bypass_enable} {
  set legal_values [expr { !$l_enable_rx_std ? $std_rx_rmfifo_enable
    : ($std_protocol_hint == "gige") ? {0 1}
      : ($std_protocol_hint == "xaui") ? {1}
        : ($std_protocol_hint == "srio_2p1") ? {1}
          : ( ($std_protocol_hint == "basic") && ($std_pcs_pma_width == "10") && ($std_rx_word_aligner_mode == "sync_sm") && ($std_low_latency_bypass_enable == "0") ) ? {0 1}
            : ( ($std_protocol_hint == "basic") && ($std_pcs_pma_width == "20")  && ($std_rx_word_aligner_mode == "manual") && ($std_low_latency_bypass_enable == "0")  ) ? {0 1}
              : {0} }]

  auto_invalid_value_message auto std_rx_rmfifo_enable $std_rx_rmfifo_enable $legal_values {std_protocol_hint std_pcs_pma_width std_rx_word_aligner_mode std_low_latency_bypass_enable}
}


proc ::altera_xcvr_native_sv::parameters::validate_std_rx_rmfifo_pattern_p {std_rx_rmfifo_pattern_p l_enable_rx_std std_protocol_hint std_rx_rmfifo_enable std_rx_word_aligner_mode} {
  if {!$l_enable_rx_std || !$std_rx_rmfifo_enable} { set legal_values $std_rx_rmfifo_pattern_p
  } elseif {$std_protocol_hint == "xaui"} { set legal_values "00343"
  } elseif {$std_protocol_hint == "gige"} { set legal_values "A257C"
  } elseif {$std_protocol_hint == "srio_2p1"} { set legal_values "E8A83"
  } else { set legal_values $std_rx_rmfifo_pattern_p }
  
  auto_invalid_value_message auto std_rx_rmfifo_pattern_p $std_rx_rmfifo_pattern_p $legal_values {std_protocol_hint std_rx_rmfifo_enable}
  auto_invalid_string_number_format_message auto std_rx_rmfifo_pattern_p $std_rx_rmfifo_pattern_p hex 20
}


proc ::altera_xcvr_native_sv::parameters::validate_std_rx_rmfifo_pattern_n {std_rx_rmfifo_pattern_n l_enable_rx_std std_protocol_hint std_rx_rmfifo_enable std_rx_word_aligner_mode} {
  if {!$l_enable_rx_std || !$std_rx_rmfifo_enable} { set legal_values $std_rx_rmfifo_pattern_n
  } elseif {$std_protocol_hint == "xaui"} { set legal_values "000BC"
  } elseif {$std_protocol_hint == "gige"} { set legal_values "AB683"
  } elseif {$std_protocol_hint == "srio_2p1"} { set legal_values "1757C"
  } else { set legal_values $std_rx_rmfifo_pattern_n }
  
  auto_invalid_value_message auto std_rx_rmfifo_pattern_n $std_rx_rmfifo_pattern_n $legal_values {std_protocol_hint std_rx_rmfifo_enable}
  auto_invalid_string_number_format_message auto std_rx_rmfifo_pattern_n $std_rx_rmfifo_pattern_n hex 20
}


proc ::altera_xcvr_native_sv::parameters::validate_std_rx_byte_order_enable {std_rx_byte_order_enable l_enable_rx_std std_rx_byte_deser_enable std_low_latency_bypass_enable std_protocol_hint } {
  set legal_values [expr { !$l_enable_rx_std ? $std_rx_byte_order_enable
    : $std_rx_byte_deser_enable && !$std_low_latency_bypass_enable && $std_protocol_hint == "basic" ? {0 1}
      : {0} }]
  
  auto_invalid_value_message auto std_rx_byte_order_enable $std_rx_byte_order_enable $legal_values {std_rx_byte_deser_enable std_low_latency_bypass_enable std_protocol_hint}
}


proc ::altera_xcvr_native_sv::parameters::validate_std_rx_byte_order_mode {std_rx_byte_order_mode l_enable_rx_std std_rx_byte_order_enable std_rx_word_aligner_mode} {
  set legal_values [expr { !$l_enable_rx_std || !$std_rx_byte_order_enable ? $std_rx_byte_order_mode
    : ($std_rx_word_aligner_mode == "bit_slip") ? {manual} : {manual auto} }]
  
  auto_invalid_value_message auto std_rx_byte_order_mode $std_rx_byte_order_mode $legal_values {std_rx_word_aligner_mode}
}


proc ::altera_xcvr_native_sv::parameters::validate_std_rx_byte_order_width {std_pcs_pma_width std_rx_8b10b_enable} {
  set legal_values [expr { $std_pcs_pma_width == "8" || $std_pcs_pma_width == "16" ? {8}
    : $std_rx_8b10b_enable == "1" ? {9}
      : {10} }]
  
  ip_set "parameter.std_rx_byte_order_width.value" [lindex $legal_values 0]
}


proc ::altera_xcvr_native_sv::parameters::validate_std_rx_byte_order_symbol_count {std_rx_byte_order_symbol_count l_enable_rx_std std_rx_byte_order_enable std_pcs_pma_width} {
  set legal_values [expr {!$l_enable_rx_std || !$std_rx_byte_order_enable ? $std_rx_byte_order_symbol_count
    : [expr $std_pcs_pma_width > 10] ? {1 2}
      : {1} }]
    
  auto_invalid_value_message auto std_rx_byte_order_symbol_count $std_rx_byte_order_symbol_count $legal_values {std_pcs_pma_width}
}


proc ::altera_xcvr_native_sv::parameters::validate_std_rx_byte_order_pattern {std_rx_byte_order_pattern l_enable_rx_std std_rx_byte_order_enable std_rx_byte_order_width std_rx_byte_order_symbol_count} {
  if {$l_enable_rx_std && $std_rx_byte_order_enable} {
    auto_invalid_string_number_format_message auto std_rx_byte_order_pattern $std_rx_byte_order_pattern hex [expr $std_rx_byte_order_width * $std_rx_byte_order_symbol_count] {std_rx_byte_order_enable std_rx_byte_order_width std_byte_order_symbol_count}
  }
}


proc ::altera_xcvr_native_sv::parameters::validate_std_rx_byte_order_pad {std_rx_byte_order_pad l_enable_rx_std std_rx_byte_order_enable std_rx_byte_order_width} {
  if {$l_enable_rx_std && $std_rx_byte_order_enable} {
    auto_invalid_string_number_format_message auto std_rx_byte_order_pad $std_rx_byte_order_pad hex $std_rx_byte_order_width {std_rx_byte_order_width}
  }
}


proc ::altera_xcvr_native_sv::parameters::validate_std_tx_byte_ser_enable { std_tx_byte_ser_enable l_enable_tx_std std_low_latency_bypass_enable std_pcs_pma_width } {
  # While there is an RBC rule for this parameter, it is irrelevant as it only imposes a restriction for protocol modes that we do not
  # currently support in Native PHY (PIPE, XAUI, PRBS, etc). For the modes currently supported all values are legal.
  set legal_values {0 1}

  auto_invalid_value_message auto std_tx_byte_ser_enable $std_tx_byte_ser_enable $legal_values {std_low_latency_bypass_enable std_pcs_pma_width}
}


proc ::altera_xcvr_native_sv::parameters::validate_std_rx_byte_deser_enable { std_rx_byte_deser_enable l_enable_rx_std std_low_latency_bypass_enable std_pcs_pma_width } {
  # While there is an RBC rule for this parameter, it is irrelevant as it only imposes a restriction for protocol modes that we do not
  # currently support in Native PHY (PIPE, XAUI, PRBS, etc). For the modes currently supported all values are legal.
  set legal_values {0 1}

  auto_invalid_value_message auto std_rx_byte_deser_enable $std_rx_byte_deser_enable $legal_values {std_low_latency_bypass_enable std_pcs_pma_width}
}


proc ::altera_xcvr_native_sv::parameters::validate_std_tx_bitslip_enable {std_tx_bitslip_enable l_enable_tx_std std_protocol_hint} {
  set legal_values [expr { !$l_enable_tx_std ? $std_tx_bitslip_enable
    : ($std_protocol_hint == "cpri_rx_tx") ? {1}
      : ($std_protocol_hint == "pipe_g1" || $std_protocol_hint == "pipe_g2" || $std_protocol_hint == "pipe_g3"  || $std_protocol_hint == "gige" || $std_protocol_hint == "xaui" || $std_protocol_hint == "test") ? {0}
        : ( ($std_protocol_hint == "basic") || ($std_protocol_hint == "srio_2p1") || ($std_protocol_hint == "cpri") ) ? {0 1}
          : {0} }]

  auto_invalid_value_message auto std_tx_bitslip_enable $std_tx_bitslip_enable $legal_values {std_protocol_hint}
}

proc altera_xcvr_native_sv::parameters::validate_std_rx_word_aligner_mode {std_rx_word_aligner_mode l_enable_rx_std std_low_latency_bypass_enable std_pcs_pma_width std_protocol_hint} {
  set legal_values [expr { !$l_enable_rx_std ? $std_rx_word_aligner_mode
    : (($std_low_latency_bypass_enable == "0") && ($std_pcs_pma_width == "8"  || $std_pcs_pma_width == "16") && ($std_protocol_hint == "basic") ) ? {"bit_slip" "manual"}
      : (($std_low_latency_bypass_enable == "0") && ($std_protocol_hint == "basic") ) ? {"bit_slip" "sync_sm" "manual"}
        : ($std_low_latency_bypass_enable == "1") ? {"bit_slip"}
          : ($std_protocol_hint == "cpri") ? {"sync_sm"}
            : ($std_protocol_hint == "cpri_rx_tx") ? {"manual"}
              : {"sync_sm"} }]


  auto_invalid_value_message auto std_rx_word_aligner_mode $std_rx_word_aligner_mode $legal_values {std_low_latency_bypass_enable std_pcs_pma_width std_protocol_hint}
}


proc ::altera_xcvr_native_sv::parameters::validate_std_rx_word_aligner_pattern_len {std_rx_word_aligner_pattern_len l_enable_rx_std std_protocol_hint std_pcs_pma_width std_rx_word_aligner_mode} {
  set legal_values [expr { !$l_enable_rx_std ? $std_rx_word_aligner_pattern_len
    : ( $std_rx_word_aligner_mode != "bit_slip" ) ?
      (
        ($std_protocol_hint == "gige" || $std_protocol_hint == "xaui" || $std_protocol_hint == "srio_2p1" ) ? {7 10}
        : ( $std_protocol_hint == "basic"  ) ?
          (
            ($std_pcs_pma_width == "8") ? {8 16}
            : ($std_pcs_pma_width == "10") ? {7 10}
              : ($std_pcs_pma_width == "16") ? {8 16 32}
                : ( $std_rx_word_aligner_mode != "sync_sm" ) ? {7 10 20 40} : {7 10 20}
          )
          : {10}
      )
      : $std_rx_word_aligner_pattern_len }]
  
  auto_invalid_value_message auto std_rx_word_aligner_pattern_len $std_rx_word_aligner_pattern_len $legal_values {std_protocol_hint std_pcs_pma_width std_rx_word_aligner_mode}
}


proc ::altera_xcvr_native_sv::parameters::validate_std_rx_word_aligner_pattern {std_rx_word_aligner_pattern l_enable_rx_std std_rx_word_aligner_mode std_rx_word_aligner_pattern_len} {
  if { $l_enable_rx_std && $std_rx_word_aligner_mode != "bit_slip" } {
    auto_invalid_string_number_format_message auto std_rx_word_aligner_pattern $std_rx_word_aligner_pattern "hex" $std_rx_word_aligner_pattern_len {std_rx_word_aligner_mode std_rx_word_aligner_pattern_len}
  }
}


proc ::altera_xcvr_native_sv::parameters::validate_std_rx_word_aligner_rknumber {std_rx_word_aligner_rknumber l_enable_rx_std std_rx_word_aligner_mode std_protocol_hint} {
  set legal_values [expr { !$l_enable_rx_std || $std_rx_word_aligner_mode == "bit_slip" ? $std_rx_word_aligner_rknumber
    : ($std_protocol_hint == "gige") ? {3}
    : ($std_protocol_hint == "xaui") ? {3}
    : ($std_protocol_hint == "srio_2p1") ? {126}
    : $std_rx_word_aligner_rknumber }]
  
  auto_invalid_value_message auto std_rx_word_aligner_rknumber $std_rx_word_aligner_rknumber $legal_values {std_rx_word_aligner_mode std_protocol_hint}
}


proc ::altera_xcvr_native_sv::parameters::validate_std_rx_word_aligner_renumber {std_rx_word_aligner_renumber l_enable_rx_std std_rx_word_aligner_mode std_protocol_hint} {
  set legal_values [expr { !$l_enable_rx_std || $std_rx_word_aligner_mode == "bit_slip" ? $std_rx_word_aligner_renumber
    : ($std_protocol_hint == "gige") ? {3}
    : ($std_protocol_hint == "xaui") ? {3}
    : $std_rx_word_aligner_renumber }]
  
  auto_invalid_value_message auto std_rx_word_aligner_renumber $std_rx_word_aligner_renumber $legal_values {std_rx_word_aligner_mode std_protocol_hint}
}


proc ::altera_xcvr_native_sv::parameters::validate_std_rx_word_aligner_rgnumber {std_rx_word_aligner_rgnumber l_enable_rx_std std_rx_word_aligner_mode std_protocol_hint} {
  set legal_values [expr { !$l_enable_rx_std || $std_rx_word_aligner_mode == "bit_slip" ? $std_rx_word_aligner_rgnumber
    : ($std_protocol_hint == "gige") ? {3}
    : ($std_protocol_hint == "xaui") ? {3}
    : ($std_protocol_hint == "srio_2p1") ? {254}
    : $std_rx_word_aligner_rgnumber }]
  
  auto_invalid_value_message auto std_rx_word_aligner_rgnumber $std_rx_word_aligner_rgnumber $legal_values {std_rx_word_aligner_mode std_protocol_hint}
}


proc ::altera_xcvr_native_sv::parameters::validate_std_rx_run_length_val {std_rx_run_length_val l_enable_rx_std std_pcs_pma_width} {
  set max_value [expr {$std_pcs_pma_width == "8" || $std_pcs_pma_width == "10" ? 31 : 63}]

  if { $l_enable_rx_std } {
    auto_invalid_string_number_format_message auto std_rx_run_length_val $std_rx_run_length_val "dec" $max_value {std_pcs_pma_width}
  }
}


proc ::altera_xcvr_native_sv::parameters::validate_enable_port_rx_std_bitslip { l_enable_rx_std enable_port_rx_std_bitslip std_low_latency_bypass_enable } {
  if {$l_enable_rx_std && $std_low_latency_bypass_enable && $enable_port_rx_std_bitslip} {
    ip_message warning "Asserting the 'rx_std_bitslip' port has no effect when parameter \"std_low_latency_bypass_enable\" ([ip_get "parameter.std_low_latency_bypass_enable.display_name"]) is enabled."
  }
}

proc ::altera_xcvr_native_sv::parameters::validate_std_tx_bitrev_enable { std_tx_bitrev_enable l_enable_tx_std std_protocol_hint } {
  set legal_values [expr { !$l_enable_tx_std ? $std_tx_bitrev_enable
    : $std_protocol_hint == "basic" ? {0 1}
      : 0 }]

  auto_invalid_value_message auto std_tx_bitrev_enable $std_tx_bitrev_enable $legal_values {std_protocol_hint}
}


proc ::altera_xcvr_native_sv::parameters::validate_std_rx_bitrev_enable { std_rx_bitrev_enable l_enable_rx_std std_protocol_hint } {
  set legal_values [expr { !$l_enable_rx_std ? $std_rx_bitrev_enable
    : $std_protocol_hint == "basic" ? {0 1}
      : 0 }]

  auto_invalid_value_message auto std_rx_bitrev_enable $std_rx_bitrev_enable $legal_values {std_protocol_hint}
}


proc ::altera_xcvr_native_sv::parameters::validate_std_tx_byterev_enable { std_tx_byterev_enable l_enable_tx_std std_protocol_hint std_pcs_pma_width } {
  set legal_values [expr { !$l_enable_tx_std ? $std_tx_byterev_enable
    : $std_protocol_hint == "basic" && ($std_pcs_pma_width == 16 || $std_pcs_pma_width == 20) ? {0 1}
      : 0 }]

  auto_invalid_value_message auto std_tx_byterev_enable $std_tx_byterev_enable $legal_values {std_protocol_hint std_pcs_pma_width}
}


proc ::altera_xcvr_native_sv::parameters::validate_std_rx_byterev_enable { std_rx_byterev_enable l_enable_rx_std std_protocol_hint std_pcs_pma_width } {
  set legal_values [expr { !$l_enable_rx_std ? $std_rx_byterev_enable
    : $std_protocol_hint == "basic" && ($std_pcs_pma_width == 16 || $std_pcs_pma_width == 20) ? {0 1}
      : 0 }]

  auto_invalid_value_message auto std_rx_byterev_enable $std_rx_byterev_enable $legal_values {std_protocol_hint std_pcs_pma_width}
}


proc ::altera_xcvr_native_sv::parameters::validate_enable_port_rx_std_bitrev_ena { l_enable_rx_std enable_port_rx_std_bitrev_ena std_rx_bitrev_enable } {
  set legal_values [expr { !$l_enable_rx_std ? $enable_port_rx_std_bitrev_ena
    : $std_rx_bitrev_enable ? 1
      : {0 1} }]

  auto_invalid_value_message auto enable_port_rx_std_bitrev_ena $enable_port_rx_std_bitrev_ena $legal_values {std_rx_bitrev_enable}
}


proc ::altera_xcvr_native_sv::parameters::validate_enable_port_rx_std_byterev_ena { l_enable_rx_std enable_port_rx_std_byterev_ena std_rx_byterev_enable } {
  set legal_values [expr { !$l_enable_rx_std ? $enable_port_rx_std_byterev_ena
    : $std_rx_byterev_enable ? 1
      : {0 1} }]

  auto_invalid_value_message auto enable_port_rx_std_byterev_ena $enable_port_rx_std_byterev_ena $legal_values {std_rx_byterev_enable}
}


proc ::altera_xcvr_native_sv::parameters::validate_enable_port_tx_std_polinv { l_enable_tx_std enable_port_tx_std_polinv std_tx_polinv_enable } {
  set legal_values [expr { !$l_enable_tx_std ? $enable_port_tx_std_polinv
    : $std_tx_polinv_enable ? 1
      : {0 1} }]

  auto_invalid_value_message auto enable_port_tx_std_polinv $enable_port_tx_std_polinv $legal_values {std_tx_polinv_enable}
}


proc ::altera_xcvr_native_sv::parameters::validate_enable_port_rx_std_polinv { l_enable_rx_std enable_port_rx_std_polinv std_rx_polinv_enable } {
  set legal_values [expr { !$l_enable_rx_std ? $enable_port_rx_std_polinv
    : $std_rx_polinv_enable ? 1
      : {0 1} }]

  auto_invalid_value_message auto enable_port_rx_std_polinv $enable_port_rx_std_polinv $legal_values {std_rx_polinv_enable}
}

#******************* Standard PCS validation callbacks ************************
#******************************************************************************

#******************************************************************************
#********************** 10G PCS validation callbacks **************************

proc ::altera_xcvr_native_sv::parameters::validate_teng_protocol_hint { l_enable_tx_teng teng_protocol_hint bonded_mode } {
  set legal_values [expr { !$l_enable_tx_teng ? $teng_protocol_hint
    : ($bonded_mode == "xN" || $bonded_mode == "fb_compensation") ? {basic sfis teng_baser teng_sdi}
      : {basic interlaken sfis teng_baser teng_1588 teng_sdi} }]

  auto_invalid_value_message auto teng_protocol_hint $teng_protocol_hint $legal_values {bonded_mode}
}


proc ::altera_xcvr_native_sv::parameters::validate_teng_pcs_pma_width { teng_pcs_pma_width enable_teng teng_protocol_hint } {
  set legal_values [expr { !$enable_teng ? $teng_pcs_pma_width
    : ($teng_protocol_hint == "teng_baser") || ($teng_protocol_hint == "teng_1588") || ($teng_protocol_hint == "test_prp") ? {32 40}
      : $teng_protocol_hint == "interlaken" ? {32 40}
        : $teng_protocol_hint == "sfis" ? {32 40 64}
          : $teng_protocol_hint == "teng_sdi" ? {40}
            : $teng_protocol_hint == "basic" ? {32 40 64}
              : $teng_protocol_hint == "test_prbs" ? {32 40 64}
                : {32} }]

  auto_invalid_value_message auto teng_pcs_pma_width $teng_pcs_pma_width $legal_values {teng_protocol_hint}
  #auto_set_allowed_ranges teng_pcs_pma_width $teng_pcs_pma_width $legal_values
}


proc ::altera_xcvr_native_sv::parameters::validate_teng_pld_pcs_width { teng_pld_pcs_width enable_teng teng_protocol_hint teng_pcs_pma_width } {
  set legal_values [expr { !$enable_teng ? $teng_pld_pcs_width
    : ($teng_protocol_hint == "teng_baser") || ($teng_protocol_hint == "teng_1588") || ($teng_protocol_hint == "test_prp") ? {66}
      : $teng_protocol_hint == "interlaken" ? {67}
        : $teng_protocol_hint == "sfis" ? $teng_pcs_pma_width == "32" ? {32 64}
                                   : $teng_pcs_pma_width == "40" ? {40}
                                   : "64"
          : $teng_protocol_hint == "teng_sdi" ? {50}
            : $teng_protocol_hint == "basic" ? $teng_pcs_pma_width == "32" ? {32 64}
                                             : $teng_pcs_pma_width == "40" ? {40 66}
                                             : {64}
              : $teng_pcs_pma_width == "32" ? {32}
                : $teng_pcs_pma_width == "40" ? {40} 
                  : {64} }]

  auto_invalid_value_message auto teng_pld_pcs_width $teng_pld_pcs_width $legal_values {teng_protocol_hint teng_pcs_pma_width }
  #auto_set_allowed_ranges teng_pld_pcs_width $teng_pld_pcs_width $legal_values
}



proc ::altera_xcvr_native_sv::parameters::validate_teng_txfifo_mode { teng_txfifo_mode l_enable_tx_teng teng_protocol_hint teng_pcs_pma_width teng_pld_pcs_width bonded_mode } {
  set legal_values [expr { !$l_enable_tx_teng ? [list $teng_txfifo_mode]
    : $teng_protocol_hint == "interlaken" ? {interlaken}
      :  $teng_protocol_hint == "teng_baser" ?  {phase_comp}
        :  $teng_protocol_hint == "teng_sdi" ?  {phase_comp}
          : $teng_protocol_hint == "basic" ?   ($teng_pcs_pma_width == $teng_pld_pcs_width) && $bonded_mode == "non_bonded" ? {register phase_comp} : {phase_comp}
            : $teng_protocol_hint == "teng_1588" ? {register} 
              : {phase_comp} } ]
  
  auto_invalid_value_message auto teng_txfifo_mode $teng_txfifo_mode $legal_values {teng_protocol_hint teng_pld_pcs_width teng_pcs_pma_width bonded_mode }
  #auto_set_allowed_ranges teng_txfifo_mode $teng_txfifo_mode $legal_values
}


proc ::altera_xcvr_native_sv::parameters::validate_teng_txfifo_pfull { teng_txfifo_pfull l_enable_tx_teng } {
  set legal_values [expr { !$l_enable_tx_teng ? [list $teng_txfifo_pfull]
      : {23} }]

  auto_invalid_value_message auto teng_txfifo_pfull $teng_txfifo_pfull $legal_values { }
  #auto_set_allowed_ranges teng_txfifo_pfull $teng_txfifo_pfull $legal_values
}


proc ::altera_xcvr_native_sv::parameters::validate_teng_txfifo_pempty { teng_txfifo_pempty l_enable_tx_teng teng_txfifo_mode } {
  set legal_values [expr { !$l_enable_tx_teng ? [list $teng_txfifo_pempty]
    : $teng_txfifo_mode == "interlaken" ? {2 3 4 5 6 7 8 9 10}
      : 2 }]

  auto_invalid_value_message auto teng_txfifo_pempty $teng_txfifo_pempty $legal_values {teng_txfifo_mode }
  #auto_set_allowed_ranges teng_txfifo_pempty $teng_txfifo_pempty $legal_values
}


proc ::altera_xcvr_native_sv::parameters::validate_teng_rxfifo_mode { teng_rxfifo_mode l_enable_rx_teng teng_protocol_hint teng_pcs_pma_width teng_pld_pcs_width } {
  set legal_values [expr { !$l_enable_rx_teng ? [list $teng_rxfifo_mode]
    : $teng_protocol_hint == "interlaken" ? {interlaken}
      :  $teng_protocol_hint == "teng_baser" ?  {clk_comp}
        :  $teng_protocol_hint == "teng_sdi" ?  {phase_comp}
          : $teng_protocol_hint == "basic" ?   ($teng_pcs_pma_width == $teng_pld_pcs_width) ? {register phase_comp} : {phase_comp}
            : $teng_protocol_hint == "teng_1588" ? {register} 
              : {phase_comp} } ]
  
  auto_invalid_value_message auto teng_rxfifo_mode $teng_rxfifo_mode $legal_values {teng_protocol_hint teng_pld_pcs_width teng_pcs_pma_width }
  #auto_set_allowed_ranges teng_rxfifo_mode $teng_rxfifo_mode $legal_values
}


proc ::altera_xcvr_native_sv::parameters::validate_teng_rxfifo_pfull { teng_rxfifo_pfull l_enable_tx_teng } {
  set legal_values [expr { !$l_enable_tx_teng ? [list $teng_rxfifo_pfull]
      : {23} }]

  auto_invalid_value_message auto teng_rxfifo_pfull $teng_rxfifo_pfull $legal_values { }
  #auto_set_allowed_ranges teng_rxfifo_pfull $teng_rxfifo_pfull $legal_values
}


proc ::altera_xcvr_native_sv::parameters::validate_teng_rxfifo_pempty { teng_rxfifo_pempty l_enable_rx_teng teng_rxfifo_mode } {
  set legal_values [expr { !$l_enable_rx_teng ? [list $teng_rxfifo_pempty]
    : $teng_rxfifo_mode == "interlaken" ? {2 3 4 5 6 7 8 9 10}
      : $teng_rxfifo_mode == "clk_comp" ? {7}
      : 2 }]

  auto_invalid_value_message auto teng_rxfifo_pempty $teng_rxfifo_pempty $legal_values {teng_rxfifo_mode}
  #auto_set_allowed_ranges teng_txfifo_pempty $teng_txfifo_pempty $legal_values
}


proc ::altera_xcvr_native_sv::parameters::validate_teng_rxfifo_align_del { teng_rxfifo_align_del l_enable_rx_teng teng_protocol_hint } {
  set legal_values [expr { !$l_enable_rx_teng ? $teng_rxfifo_align_del
    : $teng_protocol_hint == "interlaken" ? {0 1}
      : {0} }]

  auto_invalid_value_message auto teng_rxfifo_align_del $teng_rxfifo_align_del $legal_values {teng_protocol_hint}
}


proc ::altera_xcvr_native_sv::parameters::validate_teng_rxfifo_control_del { teng_rxfifo_control_del teng_rxfifo_align_del l_enable_rx_teng teng_protocol_hint } {
  set legal_values [expr { !$l_enable_rx_teng ? $teng_rxfifo_control_del
    : $teng_protocol_hint == "interlaken" ? $teng_rxfifo_align_del ? {1} : {0}
      : {0} }]

  auto_invalid_value_message auto teng_rxfifo_control_del $teng_rxfifo_control_del $legal_values {teng_protocol_hint}
}


proc ::altera_xcvr_native_sv::parameters::validate_teng_tx_frmgen_enable { l_enable_tx_teng teng_protocol_hint } {
  set legal_values [expr { !$l_enable_tx_teng ? {0}
    : ($teng_protocol_hint == "teng_baser" || $teng_protocol_hint == "test_prp" || $teng_protocol_hint == "teng_1588") ? {0}
      : ($teng_protocol_hint == "interlaken") ? {1}
        : ($teng_protocol_hint == "sfis" || $teng_protocol_hint == "teng_sdi") ? {0}
          : ($teng_protocol_hint == "basic") ? {0}
            : ($teng_protocol_hint == "test_prbs" || $teng_protocol_hint == "test_rpg") ? {0}
              : {0} }]

  ip_set "parameter.teng_tx_frmgen_enable.value" [lindex $legal_values 0]
  #auto_invalid_value_message auto teng_tx_frmgen_enable $teng_tx_frmgen_enable $legal_values {teng_protocol_hint}
}


proc ::altera_xcvr_native_sv::parameters::validate_teng_rx_frmsync_enable { l_enable_rx_teng teng_protocol_hint } {
  set legal_values [expr { !$l_enable_rx_teng ? {0}
    : ($teng_protocol_hint == "teng_baser" || $teng_protocol_hint == "test_prp" || $teng_protocol_hint == "teng_1588") ? {0}
      : ($teng_protocol_hint == "interlaken") ? {1}
        : (($teng_protocol_hint == "sfis" || $teng_protocol_hint == "teng_sdi")) ? {0}
          : ($teng_protocol_hint == "basic") ? {0}
            : ($teng_protocol_hint == "test_prbs") ? {0}
              : {0} }]

  ip_set "parameter.teng_rx_frmsync_enable.value" [lindex $legal_values 0]
}


proc ::altera_xcvr_native_sv::parameters::validate_teng_tx_sh_err { teng_tx_sh_err l_enable_tx_teng teng_protocol_hint } {
  set legal_values [expr { !$l_enable_tx_teng ? $teng_tx_sh_err
    : ($teng_protocol_hint == "interlaken" || $teng_protocol_hint == "teng_baser" || $teng_protocol_hint == "teng_1588") ? {0 1}
      : {0} }]

  auto_invalid_value_message auto teng_tx_sh_err $teng_tx_sh_err $legal_values {teng_protocol_hint}
}


proc ::altera_xcvr_native_sv::parameters::validate_teng_tx_crcgen_enable { l_enable_tx_teng teng_protocol_hint } {
  set legal_values [expr { !$l_enable_tx_teng ? {0}
    : ($teng_protocol_hint == "teng_baser" || $teng_protocol_hint == "test_prp" || $teng_protocol_hint == "teng_1588") ? {0}
      : ($teng_protocol_hint == "interlaken") ? {1}
        : ($teng_protocol_hint == "sfis" || $teng_protocol_hint == "teng_sdi") ? {0}
          : ($teng_protocol_hint == "basic") ? {0}
            : ($teng_protocol_hint == "test_prbs" || $teng_protocol_hint == "test_rpg") ? {0}
              : {0} }]
  
  ip_set "parameter.teng_tx_crcgen_enable.value" [lindex $legal_values 0]
}


proc ::altera_xcvr_native_sv::parameters::validate_teng_rx_crcchk_enable { l_enable_rx_teng teng_protocol_hint } {
  set legal_values [expr { !$l_enable_rx_teng ? {0}
    : ($teng_protocol_hint == "teng_baser" || $teng_protocol_hint == "test_prp" || $teng_protocol_hint == "teng_1588") ? {0}
      : ($teng_protocol_hint == "interlaken") ? {1}
        : (($teng_protocol_hint == "sfis" || $teng_protocol_hint == "teng_sdi")) ? {0}
          : ($teng_protocol_hint == "basic") ? {0}
            : ($teng_protocol_hint == "test_prbs") ? {0}
              : {0} }]
  
  ip_set "parameter.teng_rx_crcchk_enable.value" [lindex $legal_values 0]
}


proc ::altera_xcvr_native_sv::parameters::validate_teng_tx_64b66b_enable { l_enable_tx_teng teng_protocol_hint } {
  set legal_values [expr { !$l_enable_tx_teng ? {0}
    : ($teng_protocol_hint == "teng_baser" || $teng_protocol_hint == "test_prp" || $teng_protocol_hint == "teng_1588") ? {1}
      : ($teng_protocol_hint == "interlaken") ? {0}
        : ($teng_protocol_hint == "sfis" || $teng_protocol_hint == "teng_sdi") ? {0}
          : ($teng_protocol_hint == "basic") ? {0}
            : ($teng_protocol_hint == "test_prbs" || $teng_protocol_hint == "test_rpg") ? {0}
              : {0} }]

  ip_set "parameter.teng_tx_64b66b_enable.value" [lindex $legal_values 0]
}


proc ::altera_xcvr_native_sv::parameters::validate_teng_rx_64b66b_enable { l_enable_rx_teng teng_protocol_hint } {
  set legal_values [expr { !$l_enable_rx_teng ? {0}
    : (($teng_protocol_hint == "teng_baser" || $teng_protocol_hint == "test_prp" || $teng_protocol_hint == "teng_1588")) ? {1}
      : ($teng_protocol_hint == "interlaken") ? {0}
        : (($teng_protocol_hint == "sfis" || $teng_protocol_hint == "teng_sdi")) ? {0}
          : ($teng_protocol_hint == "basic") ? {0}
            : ($teng_protocol_hint == "test_prbs") ? {0}
              : {0} }]
              
  ip_set "parameter.teng_rx_64b66b_enable.value" [lindex $legal_values 0]
}


proc ::altera_xcvr_native_sv::parameters::validate_teng_tx_scram_enable { l_enable_tx_teng teng_protocol_hint } {
  set legal_values [expr { !$l_enable_tx_teng ? {0}
    :($teng_protocol_hint == "teng_baser" || $teng_protocol_hint == "test_prp" || $teng_protocol_hint == "teng_1588") ? {1}
      : ($teng_protocol_hint == "interlaken") ? {1}
        : ($teng_protocol_hint == "sfis" || $teng_protocol_hint == "teng_sdi") ? {0}
          : ($teng_protocol_hint == "basic") ? {0}
            : ($teng_protocol_hint == "test_prbs" || $teng_protocol_hint == "test_rpg") ? {0}
              : {0} }]

  ip_set "parameter.teng_tx_scram_enable.value" [lindex $legal_values 0]
}
 

proc ::altera_xcvr_native_sv::parameters::validate_teng_tx_scram_user_seed { teng_tx_scram_user_seed l_enable_tx_teng teng_tx_scram_enable } {
  if {$l_enable_tx_teng && $teng_tx_scram_enable} {
    auto_invalid_string_number_format_message auto teng_tx_scram_user_seed $teng_tx_scram_user_seed "hex" 58
  }
}


proc ::altera_xcvr_native_sv::parameters::validate_teng_rx_descram_enable { l_enable_rx_teng teng_protocol_hint } {
  set legal_values [expr { !$l_enable_rx_teng ? {0}
    : (($teng_protocol_hint == "teng_baser" || $teng_protocol_hint == "test_prp" || $teng_protocol_hint == "teng_1588")) ? {1}
      : ($teng_protocol_hint == "interlaken") ? {1}
        : (($teng_protocol_hint == "sfis" || $teng_protocol_hint == "teng_sdi")) ? {0}
          : ($teng_protocol_hint == "basic") ? {0}
            : ($teng_protocol_hint == "test_prbs") ? {0}
              : {0} }]
    
  ip_set "parameter.teng_rx_descram_enable.value" [lindex $legal_values 0]
}


proc ::altera_xcvr_native_sv::parameters::validate_teng_tx_dispgen_enable { l_enable_tx_teng teng_protocol_hint } {
  set legal_values [expr { !$l_enable_tx_teng ? {0}
    : $teng_protocol_hint == "interlaken" ? {1}
      : {0} }]

  ip_set "parameter.teng_tx_dispgen_enable.value" [lindex $legal_values 0]
}


proc ::altera_xcvr_native_sv::parameters::validate_teng_rx_dispchk_enable { l_enable_rx_teng teng_protocol_hint } {
  set legal_values [expr { !$l_enable_rx_teng ? {0}
    : $teng_protocol_hint == "interlaken" ? {1}
      : {0} }]

  ip_set "parameter.teng_rx_dispchk_enable.value" [lindex $legal_values 0]
}


proc ::altera_xcvr_native_sv::parameters::validate_teng_rx_blksync_enable { teng_rx_blksync_enable l_enable_rx_teng teng_protocol_hint } {
  set legal_values [expr { !$l_enable_rx_teng ? {0}
    : ($teng_protocol_hint == "teng_baser" || $teng_protocol_hint == "test_prp" || $teng_protocol_hint == "teng_1588") ? {1}
      : ($teng_protocol_hint == "interlaken") ? {1}
        : (($teng_protocol_hint == "sfis" || $teng_protocol_hint == "teng_sdi")) ? {0}
          : ($teng_protocol_hint == "basic") ? {0} 
            : ($teng_protocol_hint == "test_prbs") ? {0}
              : {0} }]

  ip_set "parameter.teng_rx_blksync_enable.value" [lindex $legal_values 0]
  #auto_invalid_value_message auto teng_rx_blksync_enable $teng_rx_blksync_enable $legal_values {teng_protocol_hint}
}


proc ::altera_xcvr_native_sv::parameters::validate_teng_tx_bitslip_enable { teng_tx_bitslip_enable l_enable_tx_teng teng_protocol_hint } {
  set legal_values [expr { !$l_enable_tx_teng ? [list $teng_tx_bitslip_enable]
    : ($teng_protocol_hint == "interlaken") ?  {0}
      : ($teng_protocol_hint == "sfis" || $teng_protocol_hint == "basic") ? {0 1}
        : {0} }]
  
  auto_invalid_value_message auto teng_tx_bitslip_enable $teng_tx_bitslip_enable $legal_values {teng_protocol_hint }
}


proc ::altera_xcvr_native_sv::parameters::validate_teng_rx_bitslip_enable { teng_rx_bitslip_enable l_enable_rx_teng teng_protocol_hint teng_pld_pcs_width teng_pcs_pma_width teng_rx_blksync_enable } {
  set legal_values [expr { !$l_enable_rx_teng ? [list $teng_rx_bitslip_enable]
    : ($teng_protocol_hint == "teng_sdi") ? {0}
      : ($teng_protocol_hint == "sfis") ?  $teng_pld_pcs_width == $teng_pcs_pma_width ? {0 1} : {0} 
        : ($teng_protocol_hint == "basic" && $teng_rx_blksync_enable == "0") ?
             (($teng_pld_pcs_width == "32" && $teng_pcs_pma_width == "32") ||
              ($teng_pld_pcs_width == "40" && $teng_pcs_pma_width == "40") ||
              ($teng_pld_pcs_width == "66" && $teng_pcs_pma_width == "40") ||
              ($teng_pld_pcs_width == "64" && $teng_pcs_pma_width == "64")) ? {0 1} : {0}
          : {0} }]

  auto_invalid_value_message auto teng_rx_bitslip_enable $teng_rx_bitslip_enable $legal_values {teng_protocol_hint teng_pld_pcs_width teng_pcs_pma_width teng_rx_blksync_enable}
}


proc ::altera_xcvr_native_sv::parameters::validate_enable_port_tx_10g_bitslip { enable_port_tx_10g_bitslip l_enable_tx_teng teng_tx_bitslip_enable } {
  set legal_values [expr { !$l_enable_tx_teng ? [list $enable_port_tx_10g_bitslip]
    : $teng_tx_bitslip_enable == "1" ? {1}
      : {0 1} }]

  auto_invalid_value_message warning enable_port_tx_10g_bitslip $enable_port_tx_10g_bitslip $legal_values {teng_tx_bitslip_enable}
}


proc ::altera_xcvr_native_sv::parameters::validate_enable_port_rx_10g_bitslip { enable_port_rx_10g_bitslip l_enable_rx_teng teng_rx_bitslip_enable } {
  set legal_values [expr { !$l_enable_rx_teng ? [list $enable_port_rx_10g_bitslip]
    : $teng_rx_bitslip_enable == "1" ? {1}
      : {0 1} }]

  auto_invalid_value_message warning enable_port_rx_10g_bitslip $enable_port_rx_10g_bitslip $legal_values {teng_rx_bitslip_enable}
}

#******************** End 10G PCS validation callbacks ************************
#******************************************************************************


proc ::altera_xcvr_native_sv::parameters::auto_set_allowed_ranges { param_name param_value param_allowed_ranges } {
  if { [lsearch $param_allowed_ranges $param_value] == -1 } {
    lappend param_allowed_ranges $param_value
  }
  ip_set "parameter.${param_name}.allowed_ranges" $param_allowed_ranges
}
#********************** End Validation Callbacks ******************************
#******************************************************************************


