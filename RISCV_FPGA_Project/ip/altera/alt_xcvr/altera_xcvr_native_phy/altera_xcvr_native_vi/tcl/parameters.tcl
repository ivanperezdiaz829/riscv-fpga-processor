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


package provide altera_xcvr_native_vi::parameters 13.1

package require alt_xcvr::ip_tcl::ip_module
package require alt_xcvr::ip_tcl::messages
package require alt_xcvr::utils::device
#package require alt_xcvr::utils::rbc
package require alt_xcvr::utils::common
package require nf_xcvr_native::parameters
package require altera_xcvr_cdr_pll_vi::parameters

namespace eval ::altera_xcvr_native_vi::parameters:: {
  namespace import ::alt_xcvr::ip_tcl::ip_module::*
  namespace import ::alt_xcvr::ip_tcl::messages::*

  namespace export \
    get_variable \
    declare_parameters \
    validate

  variable package_name
  variable display_items
  variable parameters
  variable rcfg_parameters
  variable parameter_mappings
  variable parameter_overrides
  variable static_hdl_parameters

  set package_name "altera_xcvr_native_vi::parameters"

  set display_items {\
    {NAME                                         GROUP                       ENABLED                             VISIBLE                               TYPE    ARGS                                                          VALIDATION_CALLBACK }\
    {"General"                                    ""                          NOVAL                               NOVAL                                 GROUP   NOVAL                                                         NOVAL           }\
    {"Datapath Options"                           ""                          NOVAL                               NOVAL                                 GROUP   NOVAL                                                         NOVAL           }\
    \
    {"TX PMA"                                     ""                          NOVAL                               tx_enable                             GROUP   tab                                                           NOVAL           }\
    {"TX Bonding Options"                         "TX PMA"                    NOVAL                               NOVAL                                 GROUP   NOVAL                                                         NOVAL           }\
    {"TX PLL Options"                             "TX PMA"                    NOVAL                               NOVAL                                 GROUP   NOVAL                                                         NOVAL           }\
    {"TX PMA Optional Ports"                      "TX PMA"                    NOVAL                               NOVAL                                 GROUP   NOVAL                                                         NOVAL           }\
    {display_base_data_rate                       "TX PLL Options"            NOVAL                               tx_enable                             TEXT    {"Not validated"}                                             ::altera_xcvr_native_vi::parameters::validate_display_base_data_rate }\
    \
    {"RX PMA"                                     ""                          NOVAL                               rx_enable                             GROUP   tab                                                           NOVAL           }\
    {"RX CDR Options"                             "RX PMA"                    NOVAL                               NOVAL                                 GROUP   NOVAL                                                         NOVAL           }\
    {"Decision Feedback Equalization (DFE)"       "RX PMA"                    NOVAL                               NOVAL                                 GROUP   NOVAL                                                         NOVAL           }\
    {"RX PMA Optional Ports"                      "RX PMA"                    NOVAL                               NOVAL                                 GROUP   NOVAL                                                         NOVAL           }\
    \
    {"Standard PCS"                               ""                          NOVAL                               "enable_std || rcfg_iface_enable"     GROUP   tab                                                           NOVAL           }\
    {"Phase Compensation FIFO"                    "Standard PCS"              NOVAL                               NOVAL                                 GROUP   NOVAL                                                         NOVAL           }\
    {"Byte Serializer and Deserializer"           "Standard PCS"              NOVAL                               NOVAL                                 GROUP   NOVAL                                                         NOVAL           }\
    {"8B/10B Encoder and Decoder"                 "Standard PCS"              NOVAL                               NOVAL                                 GROUP   NOVAL                                                         NOVAL           }\
    {"Rate Match FIFO"                            "Standard PCS"              NOVAL                               NOVAL                                 GROUP   NOVAL                                                         NOVAL           }\
    {"Word Aligner and Bitslip"                   "Standard PCS"              NOVAL                               NOVAL                                 GROUP   NOVAL                                                         NOVAL           }\
    {"Bit Reversal and Polarity Inversion"        "Standard PCS"              NOVAL                               NOVAL                                 GROUP   NOVAL                                                         NOVAL           }\
    {"PCIe Ports"                                 "Standard PCS"              NOVAL                               NOVAL                                 GROUP   NOVAL                                                         NOVAL           }\
    \
    {"Enhanced PCS"                               ""                          NOVAL                               "enable_enh || rcfg_iface_enable"     GROUP   tab                                                           NOVAL           }\
    {"Enhanced PCS TX FIFO"                       "Enhanced PCS"              NOVAL                               NOVAL                                 GROUP   NOVAL                                                         NOVAL           }\
    {"Enhanced PCS RX FIFO"                       "Enhanced PCS"              NOVAL                               NOVAL                                 GROUP   NOVAL                                                         NOVAL           }\
    {"Interlaken Frame Generator"                 "Enhanced PCS"              NOVAL                               NOVAL                                 GROUP   NOVAL                                                         NOVAL           }\
    {"Interlaken Frame Sync"                      "Enhanced PCS"              NOVAL                               NOVAL                                 GROUP   NOVAL                                                         NOVAL           }\
    {"Interlaken CRC-32 Generator and Checker"    "Enhanced PCS"              NOVAL                               NOVAL                                 GROUP   NOVAL                                                         NOVAL           }\
    {"10GBASE-R BER Checker"                      "Enhanced PCS"              NOVAL                               NOVAL                                 GROUP   NOVAL                                                         NOVAL           }\
    {"64b/66b Encoder and Decoder"                "Enhanced PCS"              NOVAL                               NOVAL                                 GROUP   NOVAL                                                         NOVAL           }\
    {"Scrambler and Descrambler"                  "Enhanced PCS"              NOVAL                               NOVAL                                 GROUP   NOVAL                                                         NOVAL           }\
    {"Interlaken Disparity Generator and Checker" "Enhanced PCS"              NOVAL                               NOVAL                                 GROUP   NOVAL                                                         NOVAL           }\
    {"Block Sync"                                 "Enhanced PCS"              NOVAL                               NOVAL                                 GROUP   NOVAL                                                         NOVAL           }\
    {"Gearbox"                                    "Enhanced PCS"              NOVAL                               NOVAL                                 GROUP   NOVAL                                                         NOVAL           }\
    {"KR-FEC"                                     "Enhanced PCS"              NOVAL                               NOVAL                                 GROUP   NOVAL                                                         NOVAL           }\
    \
    {"PCS Direct Datapath"                        ""                          false                               false                                 GROUP   tab                                                           NOVAL           }\
    \
    {"Dynamic Reconfiguration"                    ""                          NOVAL                               NOVAL                                 GROUP   tab                                                           NOVAL           }\
    {"Configuration Files"                        "Dynamic Reconfiguration"   NOVAL                               NOVAL                                 GROUP   NOVAL                                                         NOVAL           }\
    {"Configuration Profiles"                     "Dynamic Reconfiguration"     NOVAL                               enable_advanced_options               GROUP   NOVAL                                                         NOVAL           }\
    {"Store configuration to selected profile"    "Configuration Profiles"    "rcfg_multi_enable && rcfg_enable"  NOVAL                                 action   ::altera_xcvr_native_vi::parameters::action_store_profile    NOVAL           }\
    {"Load configuration from selected profile"   "Configuration Profiles"    "rcfg_multi_enable && rcfg_enable"  NOVAL                                 action   ::altera_xcvr_native_vi::parameters::action_load_profile     NOVAL           }\
    {"Clear selected profile"                     "Configuration Profiles"    "rcfg_multi_enable && rcfg_enable"  NOVAL                                 action   ::altera_xcvr_native_vi::parameters::action_clear_profile    NOVAL           }\
    {"Clear all profiles"                         "Configuration Profiles"    "rcfg_multi_enable && rcfg_enable"  NOVAL                                 action   ::altera_xcvr_native_vi::parameters::action_clear_profiles   NOVAL           }\
    {"Refresh selected_profile"                   "Configuration Profiles"    "rcfg_multi_enable && rcfg_enable"  NOVAL                                 action   ::altera_xcvr_native_vi::parameters::action_refresh_profile  NOVAL           }\
    {"Refresh all profiles"                       "Configuration Profiles"    "rcfg_multi_enable && rcfg_enable"  false                                 action   ::altera_xcvr_native_vi::parameters::action_refresh_profiles NOVAL           }\
    {"Reconfiguration Parameters"                 "Configuration Profiles"    "rcfg_multi_enable && rcfg_enable"  NOVAL                                 GROUP   TABLE                                                         NOVAL           }\
    {"Transceiver Attributes"                     "Dynamic Reconfiguration"   NOVAL                               NOVAL                                 GROUP   NOVAL                                                         NOVAL           }\
    \
    {"Generation Options"                         ""                          NOVAL                               NOVAL                                 GROUP   tab                                                           NOVAL           }\
    \
    {"Debug"                                      ""                            NOVAL                               enable_debug_options                  GROUP   tab                                                           NOVAL           }\
    {"Parameter Validation Rules"                 "Debug"                       NOVAL                               enable_debug_options                  GROUP   NOVAL                                                         NOVAL           }\
    {"validation_rule_display"                    "Parameter Validation Rules"  NOVAL                               enable_debug_options                  TEXT    {"Select a parameter from the dropdown"}                      NOVAL           }\
}

  set parameters {\
    {NAME                                   DERIVED HDL_PARAMETER TYPE      DEFAULT_VALUE                   ALLOWED_RANGES                                                                                  ENABLED                                   VISIBLE                                 DISPLAY_HINT  DISPLAY_UNITS DISPLAY_ITEM                                  DISPLAY_NAME                                                                    M_USED_FOR_RCFG     M_SAME_FOR_RCFG     VALIDATION_CALLBACK                                                               DESCRIPTION }\
    {device_family                          false   false         STRING    "Stratix VI"                    NOVAL                                                                                           true                                      false                                   NOVAL         NOVAL         NOVAL                                         NOVAL                                                                           0                   0                   NOVAL                                                                             NOVAL}\
    \
    {device_speedgrade                      false   false         STRING    "fastest"                       NOVAL                                                                                           true                                      true                                    NOVAL         NOVAL         "General"                                     "Device speed grade"                                                            0                   0                   NOVAL                                                                             "Specifies the desired device speedgrade. This information is used for data rate validation."}
    {message_level                          false   false         STRING    "error"                         {error warning}                                                                                 true                                      true                                    NOVAL         NOVAL         "General"                                     "Message level for rule violations"                                             0                   0                   ::altera_xcvr_native_vi::parameters::validate_message_level                       "Specifies the messaging level to use for parameter rule violations. Selecting \"error\" will cause all rule violations to prevent IP generation. Selecting \"warning\" will display all rule violations as warnings and will allow IP generation in spite of violations."}\
    \
    {support_mode                           false   false         STRING    "user_mode"                     {"user_mode" "engineering_mode"}                                                                enable_advanced_options                   enable_advanced_options                 NOVAL         NOVAL         "Datapath Options"                            "Protocol support mode"                                                         1                   0                   ::altera_xcvr_native_vi::parameters::validate_support_mode                        "Selects the protocol support mode (user or engineering). Engineering mode options are not officially supported by Altera or Quartus II."}\
    {protocol_mode                          false   false         STRING    "basic_std"                     NOVAL                                                                                           true                                      true                                    NOVAL         NOVAL         "Datapath Options"                            "Transceiver configuration rules"                                               1                   0                   ::altera_xcvr_native_vi::parameters::validate_protocol_mode                       "Selects the protocol configuration rules the transceiver. This parameter is used to govern the rules for correct settings of individual parameters within the PMA and PCS. Certain features of the transceiver are available only for specific protocol configuration rules. This parameter is not a \"preset\". You must still correctly set all other parameters for your specific protocol and application needs."}\
    {duplex_mode                            false   true          STRING    "duplex"                        {"duplex:TX/RX Duplex" "tx:TX Simplex" "rx:RX Simplex"}                                         true                                      true                                    NOVAL         NOVAL         "Datapath Options"                            "Transceiver mode"                                                              1                   1                   NOVAL                                                                             "Selects the transceiver operation mode."}\
    {channels                               false   true          INTEGER   1                               NOVAL                                                                                           true                                      true                                    NOVAL         NOVAL         "Datapath Options"                            "Number of data channels"                                                       1                   1                   NOVAL                                                                             "Specifies the total number of data channels."}\
    {set_data_rate                          false   false         STRING    "1250"                          NOVAL                                                                                           true                                      true                                    "columns:10"  Mbps          "Datapath Options"                            "Data rate"                                                                     1                   0                   ::altera_xcvr_native_vi::parameters::validate_set_data_rate                       "Specifies the transceiver data rate in units of Mbps (megabits per second)."}\
    {data_rate                              true    true          STRING    NOVAL                           NOVAL                                                                                           true                                      false                                   NOVAL         NOVAL         NOVAL                                         NOVAL                                                                           0                   0                   ::altera_xcvr_native_vi::parameters::validate_data_rate                           NOVAL}\
    {rcfg_iface_enable                      false   false         INTEGER   0                               NOVAL                                                                                           true                                      true                                    boolean       NOVAL         "Datapath Options"                            "Enable reconfiguration between Standard and Enhanced PCS datapaths"            1                   1                   NOVAL                                                                             "Enables the ability to preconfigure and dynamically switch between transceiver datapaths." }\
    {enable_simple_interface                false   false         INTEGER   0                               NOVAL                                                                                           true                                      true                                    boolean       NOVAL         "Datapath Options"                            "Enable simplified data interface"                                              1                   1                   ::altera_xcvr_native_vi::parameters::validate_enable_simple_interface             "When selected the IP will present a simplified data and control interface between the FPGA and transceiver. When not selected the IP will present the full raw data interface to the transceiver. You will need to understand the mapping of data and control signals within the interface. This option cannot be enabled if you want to perform dynamic interface reconfiguration as only a fixed subset of the data and control signals will be provided."}\
    {enable_split_interface                 false   false         INTEGER   0                               NOVAL                                                                                           false                                     false                                   boolean       NOVAL         "Datapath Options"                            "Provide separate interface for each channel"                                   1                   1                   NOVAL                                                                             "When selected the IP will present separate data; reset; and clock interfaces for each channel rather than a wide bus. This option is typically needed for multi-channel configurations in QSys."}\
    \
    {bonded_mode                            false   true          STRING    not_bonded                      {"not_bonded:Not bonded" "pma_only:PMA bonding" "pma_pcs:PMA/PCS bonding"}                      tx_enable                                 tx_enable                               NOVAL         NOVAL         "TX Bonding Options"                          "TX channel bonding mode"                                                       1                   1                   ::altera_xcvr_native_vi::parameters::validate_bonded_mode                         "Specifies the transceiver TX channel bonding mode to control channel-to-channel skew for the TX datapath. Refer to the device handbook for bonding details. Options are no TX channel bonding; PMA only channel bonding; or PMA & PCS channel bonding."}\
    {set_pcs_bonding_master                 false   false         STRING    "Auto"                          {"Auto"}                                                                                        tx_enable                                 tx_enable                               NOVAL         NOVAL         "TX Bonding Options"                          "PCS TX channel bonding master"                                                 1                   1                   ::altera_xcvr_native_vi::parameters::validate_set_pcs_bonding_master              "Specifies the master PCS channel for PCS bonded configurations. Refer to the device handbook for bonding details. Selecting 'Auto' will allow the IP to automatically select a recommended channel."}\
    {pcs_bonding_master                     true    true          INTEGER   0                               NOVAL                                                                                           tx_enable                                 tx_enable                               NOVAL         NOVAL         "TX Bonding Options"                          "Actual PCS TX channel bonding master"                                          0                   0                   ::altera_xcvr_native_vi::parameters::validate_pcs_bonding_master                  "Indicates the selected master PCS channel for PCS bonded configurations."}\
    {tx_pma_clk_div                         false   false         INTEGER   1                               {1 2 4 8}                                                                                       !l_enable_pma_bonding                     tx_enable                               NOVAL         NOVAL         "TX PLL Options"                              "TX local clock division factor"                                                1                   0                   NOVAL                                                                             "Specifies the TX serial clock division factor. The transceiver has the ability to further divide the TX serial clock from the TX PLL before use. This parameter specifies the division factor to use. Example: A PLL data rate of \"10000 Mbps\" and a local division factor of 8 will result in a channel data rate of \"1250 Mbps\""}\
    {plls                                   false   false         INTEGER   1                               {1 2 3 4}                                                                                       !l_enable_pma_bonding                     tx_enable                               NOVAL         NOVAL         "TX PLL Options"                              "Number of TX PLL clock inputs per channel"                                     1                   1                   NOVAL                                                                             "Specifies the desired number of TX PLL clock inputs per channel. This used when you intend to dynamically switch between TX PLL clock sources. The IP will will present up to 4 clock inputs per channel to allow dynamically input clock switching."}\
    {pll_select                             false   false         INTEGER   0                               {0}                                                                                             !l_enable_pma_bonding                     tx_enable                               NOVAL         NOVAL         "TX PLL Options"                              "Initial TX PLL clock input selection"                                          1                   0                   ::altera_xcvr_native_vi::parameters::validate_pll_select                          "Specifies the initially selected TX PLL clock input. This is used to indicate the starting clock input selection used for this configuration when dynamically switching between multiple TX PLL clock inputs."}\
    {enable_port_tx_pma_clkout              false   false         INTEGER   0                               NOVAL                                                                                           tx_enable                                 tx_enable                               boolean       NOVAL         "TX PMA Optional Ports"                       "Enable tx_pma_clkout port"                                                     1                   1                   NOVAL                                                                             "Enables the optional tx_pma_clkout output clock. This is the parallel clock from the TX PMA."}\
    {enable_port_tx_pma_div_clkout          false   false         INTEGER   0                               NOVAL                                                                                           tx_enable                                 tx_enable                               boolean       NOVAL         "TX PMA Optional Ports"                       "Enable tx_pma_div_clkout port"                                                 1                   1                   NOVAL                                                                             "Enables the optional tx_pma_div_clkout output clock."}\
    {tx_pma_div_clkout_divider              false   false         INTEGER   "Disabled"                      {Disabled 1 2 33 40 66}                                                                         enable_port_tx_pma_div_clkout             tx_enable                               boolean       NOVAL         "TX PMA Optional Ports"                       "tx_pma_div_clkout division factor"                                             1                   0                   NOVAL                                                                             "Specifies the divider value for the tx_pma_div_clkout clock signal."}\
    {enable_port_tx_pma_elecidle            false   false         INTEGER   0                               NOVAL                                                                                           tx_enable                                 tx_enable                               boolean       NOVAL         "TX PMA Optional Ports"                       "Enable tx_pma_elecidle port"                                                   1                   1                   NOVAL                                                                             "Enables the optional tx_pma_elecidle control input port. The assertion of this signal will force the transmitter into an electrical idle condition. Note that this port has no effect when the transceiver is configured for PCI express modes."}\
    {enable_port_tx_pma_qpipullup           false   false         INTEGER   0                               NOVAL                                                                                           tx_enable                                 tx_enable                               boolean       NOVAL         "TX PMA Optional Ports"                       "Enable tx_pma_qpipullup port (QPI)"                                            1                   1                   NOVAL                                                                             "Enables the tx_pma_qpipullup control input port. This port is used only in QPI applications."}\
    {enable_port_tx_pma_qpipulldn           false   false         INTEGER   0                               NOVAL                                                                                           tx_enable                                 tx_enable                               boolean       NOVAL         "TX PMA Optional Ports"                       "Enable tx_pma_qpipulldn port (QPI)"                                            1                   1                   NOVAL                                                                             "Enables the tx_pma_qpipulldn control input port. This port is used only in QPI applications."}\
    {enable_port_tx_pma_txdetectrx          false   false         INTEGER   0                               NOVAL                                                                                           tx_enable                                 tx_enable                               boolean       NOVAL         "TX PMA Optional Ports"                       "Enable tx_pma_txdetectrx port (QPI)"                                           1                   1                   NOVAL                                                                             "Enables the tx_pma_txdetectrx control input port. This port is used only in QPI applications. The receiver detect block in TX PMA is used to detect the presence of a receiver at the other end of the channel. After receiving tx_pma_txdetectrx request the receiver detect block initiates the detection process. "}\
    {enable_port_tx_pma_rxfound             false   false         INTEGER   0                               NOVAL                                                                                           tx_enable                                 tx_enable                               boolean       NOVAL         "TX PMA Optional Ports"                       "Enable tx_pma_rxfound port (QPI)"                                              1                   1                   NOVAL                                                                             "Enables the tx_rxfound status output port. This port is used only in QPI applications. The receiver detect block in TX PMA is used to detect the presence of a receiver at the other end by using tx_pma_txdetectrx input. Detection of RX status is given on the tx_pma_rxfound port."}\
    \
    {cdr_refclk_cnt                         false   false         INTEGER   1                               {1 2 3 4 5}                                                                                     rx_enable                                 rx_enable                               NOVAL         NOVAL         "RX CDR Options"                              "Number of CDR reference clocks"                                                1                   1                   NOVAL                                                                             "Specifies the number of input reference clocks for the RX CDRs. The same bus of reference clocks will feed all RX CDRs in the netlist."}\
    {cdr_refclk_select                      false   false         INTEGER   0                               {0}                                                                                             rx_enable                                 rx_enable                               NOVAL         NOVAL         "RX CDR Options"                              "Selected CDR reference clock"                                                  1                   0                   ::altera_xcvr_native_vi::parameters::validate_cdr_refclk_select                   "Specifies the initially selected reference clock input to the RX CDRs."}\
    {set_cdr_refclk_freq                    false   false         STRING    "125.000"                       {"125.000"}                                                                                     rx_enable                                 rx_enable                               NOVAL         MHz           "RX CDR Options"                              "Selected CDR reference clock frequency"                                        1                   0                   ::altera_xcvr_native_vi::parameters::validate_set_cdr_refclk_freq                 "Specifies the frequency in Mbps of the selected reference clock input to the CDR."}\
    {rx_ppm_detect_threshold                false   false         STRING    "1000"                          {62.5 100 125 200 250 300 500 1000}                                                             rx_enable                                 rx_enable                               NOVAL         PPM           "RX CDR Options"                              "PPM detector threshold"                                                        1                   0                   NOVAL                                                                             "Specifies the tolerable difference in PPM (parts per million) between the RX CDR reference clock and the recovered clock from the RX data input."}\
    \
    {rx_pma_dfe_mode                        false   false         STRING    "Disabled"                      {"Disabled" "Fixed tap" "Floating tap"}                                                         tx_enable                                 tx_enable                               NOVAL         NOVAL         "Decision Feedback Equalization (DFE)"        "Decision feedback equalization mode"                                           1                   0                   NOVAL                                                                             "Specifies the operating mode for the decision feedback equalization (DFE) block in the RX PMA."}\
    \
    {enable_port_rx_pma_clkout              false   false         INTEGER   0                               NOVAL                                                                                           rx_enable                                 rx_enable                               boolean       NOVAL         "RX PMA Optional Ports"                       "Enable rx_pma_clkout port"                                                     1                   1                   NOVAL                                                                             "Enables the optional rx_pma_clkout output clock. This is the recovered parallel clock from the RX CDR"}\
    {enable_port_rx_pma_div_clkout          false   false         INTEGER   0                               NOVAL                                                                                           rx_enable                                 rx_enable                               boolean       NOVAL         "RX PMA Optional Ports"                       "Enable rx_pma_div_clkout port"                                                 1                   1                   NOVAL                                                                             "Enables the optional rx_pma_div_clkout output clock."}\
    {rx_pma_div_clkout_divider              false   false         INTEGER   "Disabled"                      {Disabled 1 2 33 40 50 66}                                                                      enable_port_rx_pma_div_clkout             rx_enable                               boolean       NOVAL         "RX PMA Optional Ports"                       "rx_pma_div_clkout division factor"                                             1                   0                   NOVAL                                                                             "Specifies the divider value for the rx_pma_div_clkout clock signal."}\
    {enable_port_rx_pma_clkslip             false   false         INTEGER   0                               NOVAL                                                                                           rx_enable                                 rx_enable                               boolean       NOVAL         "RX PMA Optional Ports"                       "Enable rx_pma_clkslip port"                                                    1                   1                   NOVAL                                                                             "Enables the optional rx_pma_clkslip control input port. A rising edge on this signal will cause the RX serializer to slip the serial data by one clock cycle (2 UI)."}\
    {enable_port_rx_pma_qpipullup           false   false         INTEGER   0                               NOVAL                                                                                           rx_enable                                 rx_enable                               boolean       NOVAL         "RX PMA Optional Ports"                       "Enable rx_pma_qpipulldn port (QPI)"                                            1                   1                   NOVAL                                                                             "Enables the rx_pma_qpipulldn control input port. This port is used only in QPI applications."}\
    {enable_port_rx_is_lockedtodata         false   false         INTEGER   1                               NOVAL                                                                                           rx_enable                                 rx_enable                               boolean       NOVAL         "RX PMA Optional Ports"                       "Enable rx_is_lockedtodata port"                                                1                   1                   NOVAL                                                                             "Enables the optional rx_is_lockedtodata status output port. This signal indicates that the RX CDR is currently in lock to data mode or is attempting to lock to the incoming data stream. This is an asynchronous output signal."}\
    {enable_port_rx_is_lockedtoref          false   false         INTEGER   1                               NOVAL                                                                                           rx_enable                                 rx_enable                               boolean       NOVAL         "RX PMA Optional Ports"                       "Enable rx_is_lockedtoref port"                                                 1                   1                   NOVAL                                                                             "Enables the optional rx_is_lockedtoref status output port. This signal indicates that the RX CDR is currently locked to the CDR reference clock. This is an asynchronous output signal."}\
    {enable_ports_rx_manual_cdr_mode        false   false         INTEGER   0                               NOVAL                                                                                           rx_enable                                 rx_enable                               boolean       NOVAL         "RX PMA Optional Ports"                       "Enable rx_set_locktodata and rx_set_locktoref ports"                           1                   1                   NOVAL                                                                             "Enables the optional rx_set_locktodata and rx_set_locktoref control input ports. These ports are used to manually control the lock mode of the RX CDR. These are asynchonous input signals."}\
    {enable_port_rx_signaldetect            false   false         INTEGER   0                               NOVAL                                                                                           rx_enable                                 false                                   boolean       NOVAL         "RX PMA Optional Ports"                       "Enable rx_signaldetect port"                                                   1                   1                   NOVAL                                                                             "Enables the optional rx_signaldetect status output port. The assertion of this signal indicates detection of an input signal to the RX PMA. Refer to the device handbook for applications and limitations. This is an asynchronous output signal."}\
    {enable_port_rx_seriallpbken            false   false         INTEGER   0                               NOVAL                                                                                           true                                      true                                    boolean       NOVAL         "RX PMA Optional Ports"                       "Enable rx_seriallpbken port"                                                   1                   1                   NOVAL                                                                             "Enables the optional rx_seriallpbken control input port. The assertion of this signal enables the TX to RX serial loopback path within the transceiver. This is an asynchronous input signal."}\
    {enable_ports_rx_prbs                   false   false         INTEGER   0                               NOVAL                                                                                           rx_enable                                 rx_enable                               boolean       NOVAL         "RX PMA Optional Ports"                       "Enable PRBS verifier control and status ports"                                 1                   1                   NOVAL                                                                             "Enables the optional rx_prbs_err rx_prbs_err_clr and rx_prbs_done ports. These ports are used to control and collect status from the internal PRBS verifier."}\
    \
    {std_pcs_pma_width                      false   false         INTEGER   10                              {8 10 16 20}                                                                                    enable_std                                enable_std                              NOVAL         NOVAL         "Standard PCS"                                "Standard PCS / PMA interface width"                                            1                   0                   NOVAL                                                                             "Specifies the data interface width between the 'Standard PCS' and the transceiver PMA."}\
    {std_tx_pld_pcs_width                   true    false         INTEGER   NOVAL                           NOVAL                                                                                           l_enable_tx_std                           l_enable_tx_std                         NOVAL         NOVAL         "Standard PCS"                                "FPGA fabric / Standard TX PCS interface width"                                 1                   0                   ::altera_xcvr_native_vi::parameters::validate_std_tx_pld_pcs_width                "Indicates the data inerface width between the Standard TX PCS datapath and the FPGA fabric. This value is determined by the current configuration of individual blocks within the Standard TX PCS datapath."}\
    {std_rx_pld_pcs_width                   true    false         INTEGER   NOVAL                           NOVAL                                                                                           l_enable_rx_std                           l_enable_rx_std                         NOVAL         NOVAL         "Standard PCS"                                "FPGA fabric / Standard RX PCS interface width"                                 1                   0                   ::altera_xcvr_native_vi::parameters::validate_std_rx_pld_pcs_width                "Indicates the data inerface width between the Standard RX PCS datapath and the FPGA fabric. This value is determined by the current configuration of individual blocks within the Standard RX PCS datapath."}\
    {std_low_latency_bypass_enable          false   false         INTEGER   0                               NOVAL                                                                                           enable_std                                enable_std                              boolean       NOVAL         "Standard PCS"                                "Enable 'Standard PCS' low latency mode"                                        1                   0                   NOVAL                                                                             "Enables the low latency path for the 'Standard PCS'. Enabling this option will bypass the individual functional blocks within the 'Standard PCS' to provide the lowest latency datapath from the PMA through the 'Standard PCS'."}\
    {enable_hip                             false   true          INTEGER   0                               NOVAL                                                                                           enable_std                                enable_advanced_options                 boolean       NOVAL         "Standard PCS"                                "Enable PCIe hard IP support"                                                   1                   0                   NOVAL                                                                             "INTERNAL USE ONLY. Enabling this parameter indicates that the IP variant will be connected to the PCIe hard IP core."}\
    {enable_hard_reset                      false   false         INTEGER   0                               NOVAL                                                                                           enable_std                                enable_advanced_options                 boolean       NOVAL         "Standard PCS"                                "Enable hard reset controller (HIP)"                                            1                   0                   NOVAL                                                                             "INTERNAL USE ONLY. Enabling this parameter enables the hard reset controller for use with PCIe HIP."}\
    \
    {std_tx_pcfifo_mode                     false   false         STRING    "low_latency"                   {low_latency register_fifo}                                                                     l_enable_tx_std                           l_enable_tx_std_iface                   NOVAL         NOVAL         "Phase Compensation FIFO"                     "TX FIFO mode"                                                                  1                   0                   NOVAL                                                                             "Specifies the mode for the 'Standard PCS' TX FIFO."}\
    {std_rx_pcfifo_mode                     false   false         STRING    "low_latency"                   {low_latency register_fifo}                                                                     l_enable_rx_std                           l_enable_rx_std_iface                   NOVAL         NOVAL         "Phase Compensation FIFO"                     "RX FIFO mode"                                                                  1                   0                   NOVAL                                                                             "Specifies the mode for the 'Standard PCS' RX FIFO."}\
    {enable_port_tx_std_pcfifo_full         false   false         INTEGER   0                               NOVAL                                                                                           l_enable_tx_std_iface                     l_enable_tx_std_iface                   boolean       NOVAL         "Phase Compensation FIFO"                     "Enable tx_std_pcfifo_full port"                                                1                   1                   NOVAL                                                                             "Enables the optional tx_std_pcfifo_full status output port. This signal indicates when the standard TX phase compensation FIFO has reached the full threshold. This signal is synchronous with 'tx_std_clkout'."}\
    {enable_port_tx_std_pcfifo_empty        false   false         INTEGER   0                               NOVAL                                                                                           l_enable_tx_std_iface                     l_enable_tx_std_iface                   boolean       NOVAL         "Phase Compensation FIFO"                     "Enable tx_std_pcfifo_empty port"                                               1                   1                   NOVAL                                                                             "Enables the optional tx_std_pcfifo_empty status output port. This signal indicates when the standard RX phase compensation FIFO has reached the empty threshold. This signal is synchronous with 'tx_std_clkout'."}\
    {enable_port_rx_std_pcfifo_full         false   false         INTEGER   0                               NOVAL                                                                                           l_enable_rx_std_iface                     l_enable_rx_std_iface                   boolean       NOVAL         "Phase Compensation FIFO"                     "Enable rx_std_pcfifo_full port"                                                1                   1                   NOVAL                                                                             "Enables the optional rx_std_pcfifo_full status output port. This signal indicates when the standard RX phase compensation FIFO has reached the full threshold. This signal is synchronous with 'rx_std_clkout'."}\
    {enable_port_rx_std_pcfifo_empty        false   false         INTEGER   0                               NOVAL                                                                                           l_enable_rx_std_iface                     l_enable_rx_std_iface                   boolean       NOVAL         "Phase Compensation FIFO"                     "Enable rx_std_pcfifo_empty port"                                               1                   1                   NOVAL                                                                             "Enables the optional rx_std_pcfifo_empty status output port. This signal indicates when the standard RX phase compensation FIFO has reached the full threshold. This signal is synchronous with 'rx_std_clkout'."}\
    \
    {std_tx_byte_ser_mode                   false   false         STRING    "Disabled"                      {"Disabled" "Serialize x2" "Serialize x4"}                                                      l_enable_tx_std                           l_enable_tx_std_iface                   NOVAL         NOVAL         "Byte Serializer and Deserializer"            "TX byte serializer mode"                                                       1                   0                   NOVAL                                                                             "Specifies the mode for the TX byte serializer in the 'Standard PCS'. The transceiver architecture allows the 'Standard PCS' to operate at double or quadruple the data width of the PMA serializer. This allows the PCS to run at a lower internal clock frequency and accommodate a wider range of FPGA interface widths. This option is limited by the target protocol mode."}\
    {std_rx_byte_deser_mode                 false   false         STRING    "Disabled"                      {"Disabled" "Deserialize x2" "Deserialize x4"}                                                  l_enable_rx_std                           l_enable_rx_std_iface                   NOVAL         NOVAL         "Byte Serializer and Deserializer"            "RX byte deserializer mode"                                                     1                   0                   NOVAL                                                                             "Specifies the mode for the RX byte deserializer in the 'Standard PCS' The transceiver architecture allows the 'Standard PCS' to operate at double or quadruple the data width of the PMA deserializer. This allows the PCS to run at a lower internal clock frequency and accommodate a wider range of FPGA interface widths. This option is limited by the target protocol mode."}\
    \
    {std_tx_8b10b_enable                    false   false         INTEGER   0                               NOVAL                                                                                           l_enable_tx_std                           l_enable_tx_std_iface                   boolean       NOVAL         "8B/10B Encoder and Decoder"                  "Enable TX 8B/10B encoder"                                                      1                   0                   NOVAL                                                                             "Enables the 8B/10B encoder in the 'Standard PCS'."}\
    {std_tx_8b10b_disp_ctrl_enable          false   false         INTEGER   0                               NOVAL                                                                                           l_enable_tx_std                           l_enable_tx_std_iface                   boolean       NOVAL         "8B/10B Encoder and Decoder"                  "Enable TX 8B/10B disparity control"                                            1                   0                   NOVAL                                                                             "Enables disparity control for the 8B/10B encoder. This allows you to force the disparity of the 8b10b encoder via the 'tx_forcedisp' control signal."}\
    {std_rx_8b10b_enable                    false   false         INTEGER   0                               NOVAL                                                                                           l_enable_rx_std                           l_enable_rx_std_iface                   boolean       NOVAL         "8B/10B Encoder and Decoder"                  "Enable RX 8B/10B decoder"                                                      1                   0                   NOVAL                                                                             "Enables the 8B/10B decoder in the 'Standard PCS'."}\
    \
    {std_rx_rmfifo_mode                     false   false         STRING    "disabled"                      {"disabled" "basic (single width)" "basic (double width)" "gige" "pipe" "pipe 0ppm"}            l_enable_rx_std                           l_enable_rx_std_iface                   NOVAL         NOVAL         "Rate Match FIFO"                             "RX rate match FIFO mode"                                                       1                   0                   NOVAL                                                                             "Specifies the operation mode of the RX rate match FIFO in the 'Standard PCS'."}\
    {std_rx_rmfifo_pattern_n                false   false         INTEGER   0                               NOVAL                                                                                           l_enable_rx_std                           l_enable_rx_std_iface                   hexadecimal   NOVAL         "Rate Match FIFO"                             "RX rate match insert/delete -ve pattern (hex)"                                 1                   0                   NOVAL                                                                             "Specifies the -ve (negative) disparity value for the RX rate match FIFO. The value is 20-bits and specified as a hexadecimal string."}\
    {std_rx_rmfifo_pattern_p                false   false         INTEGER   0                               NOVAL                                                                                           l_enable_rx_std                           l_enable_rx_std_iface                   hexadecimal   NOVAL         "Rate Match FIFO"                             "RX rate match insert/delete +ve pattern (hex)"                                 1                   0                   NOVAL                                                                             "Specifies the +ve (positive) disparity value for the RX rate match FIFO. The value is 20-bits and specified as a hexadecimal string."}\
    {enable_port_rx_std_rmfifo_full         false   false         INTEGER   0                               NOVAL                                                                                           l_enable_rx_std_iface                     l_enable_rx_std_iface                   boolean       NOVAL         "Rate Match FIFO"                             "Enable rx_std_rmfifo_full port"                                                1                   1                   NOVAL                                                                             "Enables the optional rx_std_rmfifo_full status output port. This signal indicates when the standard RX rate match FIFO has reached the full threshold."}\
    {enable_port_rx_std_rmfifo_empty        false   false         INTEGER   0                               NOVAL                                                                                           l_enable_rx_std_iface                     l_enable_rx_std_iface                   boolean       NOVAL         "Rate Match FIFO"                             "Enable rx_std_rmfifo_empty port"                                               1                   1                   NOVAL                                                                             "Enables the optional rx_std_rmfifo_empty status output port. This signal indicates when the standard RX rate match FIFO has reached the full threshold."}\
    {pcie_rate_match                        false   false         STRING    "Bypass"                        {"Bypass" "0 ppm" "600 ppm"}                                                                    l_enable_rx_std                           l_enable_rx_std_iface                   NOVAL         NOVAL         "Rate Match FIFO"                             "PCI Express Gen 3 rate match FIFO mode"                                        1                   0                   NOVAL                                                                             "Specifies the PPM tolerance mode of the PCI Express Gen 3 rate match FIFO."}\
    \
    {std_tx_bitslip_enable                  false   false         INTEGER   0                               NOVAL                                                                                           l_enable_tx_std                           l_enable_tx_std_iface                   boolean       NOVAL         "Word Aligner and Bitslip"                    "Enable TX bitslip"                                                             1                   0                   NOVAL                                                                             "Enable TX bitslip support. When enabled the outgoing transmit data can be slipped a specific number of bits as specified by the 'tx_bitslipboundarysel' control signal."}\
    {enable_port_tx_std_bitslipboundarysel  false   false         INTEGER   0                               NOVAL                                                                                           l_enable_tx_std                           l_enable_tx_std_iface                   boolean       NOVAL         "Word Aligner and Bitslip"                    "Enable tx_std_bitslipboundarysel port"                                         1                   0                   NOVAL                                                                             "Enables the optional tx_std_bitslipboundarysel control input port."}\
    {std_rx_word_aligner_mode               false   false         STRING    "bitslip"                       {"bitslip" "manual (PLD controlled)" "synchronous state machine" "deterministic latency"}       l_enable_rx_std                           l_enable_rx_std_iface                   NOVAL         NOVAL         "Word Aligner and Bitslip"                    "RX word aligner mode"                                                          1                   0                   NOVAL                                                                             "Specifies the RX word aligner mode for the 'Standard PCS'."}\
    {std_rx_word_aligner_pattern_len        false   false         INTEGER   7                               {7 8 10 16 20 32 40}                                                                            l_enable_rx_std                           l_enable_rx_std_iface                   NOVAL         NOVAL         "Word Aligner and Bitslip"                    "RX word aligner pattern length"                                                1                   0                   ::altera_xcvr_native_vi::parameters::validate_std_rx_word_aligner_pattern_len     "Specifies the RX word alignment pattern length."}\
    {std_rx_word_aligner_pattern            false   false         LONG      0                               NOVAL                                                                                           l_enable_rx_std                           l_enable_rx_std_iface                   hexadecimal   NOVAL         "Word Aligner and Bitslip"                    "RX word aligner pattern (hex)"                                                 1                   0                   NOVAL                                                                             "Specifies the RX word alignment pattern."}\
    {std_rx_word_aligner_rknumber           false   false         INTEGER   3                               "0:255"                                                                                         l_enable_rx_std                           l_enable_rx_std_iface                   NOVAL         NOVAL         "Word Aligner and Bitslip"                    "Number of word alignment patterns to achieve sync"                             1                   0                   NOVAL                                                                             "Specifies the number of valid word alignment patterns that must be received before the word aligner achieve sync lock."}\
    {std_rx_word_aligner_renumber           false   false         INTEGER   3                               "0:63"                                                                                          l_enable_rx_std                           l_enable_rx_std_iface                   NOVAL         NOVAL         "Word Aligner and Bitslip"                    "Number of invalid data words to lose sync"                                     1                   0                   NOVAL                                                                             "Specifies the number of invalid data codes or disparity errors that must be received before the word aligner loses sync lock."}\
    {std_rx_word_aligner_rgnumber           false   false         INTEGER   3                               "0:255"                                                                                         l_enable_rx_std                           l_enable_rx_std_iface                   NOVAL         NOVAL         "Word Aligner and Bitslip"                    "Number of valid data words to decrement error count"                           1                   0                   NOVAL                                                                             "Specifies the number of valid data codes that must be received to decrement the error counter. If enough valid data codes are received to decrement the error count to zero the word aligner will return to sync lock."}\
    {enable_port_rx_std_wa_patternalign     false   false         INTEGER   0                               NOVAL                                                                                           l_enable_rx_std_iface                     l_enable_rx_std_iface                   boolean       NOVAL         "Word Aligner and Bitslip"                    "Enable rx_std_wa_patternalign port"                                            1                   1                   NOVAL                                                                             "Enables the optional rx_std_wa_patternalign control input port. A rising edge on this signal will cause the word aligner to align to the next incoming word alignment pattern when the word aligner is configured in \"manual\" mode."}\
    {enable_port_rx_std_wa_a1a2size         false   false         INTEGER   0                               NOVAL                                                                                           l_enable_rx_std_iface                     l_enable_rx_std_iface                   boolean       NOVAL         "Word Aligner and Bitslip"                    "Enable rx_std_wa_a1a2size port"                                                1                   1                   NOVAL                                                                             "Enables the optional rx_std_a1a2size control input port."}\
    {enable_port_rx_std_bitslipboundarysel  false   false         INTEGER   0                               NOVAL                                                                                           l_enable_rx_std_iface                     l_enable_rx_std_iface                   boolean       NOVAL         "Word Aligner and Bitslip"                    "Enable rx_std_bitslipboundarysel port"                                         1                   1                   NOVAL                                                                             "Enables the optional rx_std_bitslipboundarysel status output port."}\
    {enable_port_rx_std_bitslip             false   false         INTEGER   0                               NOVAL                                                                                           l_enable_rx_std_iface                     l_enable_rx_std_iface                   boolean       NOVAL         "Word Aligner and Bitslip"                    "Enable rx_bitslip port"                                                        1                   1                   NOVAL                                                                             "Enables the optional rx_bitslip control input port. This is the shared RX bitslip control port for the Standard and Enhanced PCS datapaths."}\
    \
    {std_tx_bitrev_enable                   false   false         INTEGER   0                               NOVAL                                                                                           l_enable_tx_std                           l_enable_tx_std_iface                   boolean       NOVAL         "Bit Reversal and Polarity Inversion"         "Enable TX bit reversal"                                                        1                   0                   NOVAL                                                                             "Enables transmitter bit order reversal. When enabled the TX parallel data will be reversed before passing to the PMA for serialization. When bit reversal is activated the transmitted TX data bit order flipped to MSB->LSB rather than the normal LSB->MSB. This is a static setting and can only be dynamically changed through dynamic reconfiguration."}\
    {std_tx_byterev_enable                  false   false         INTEGER   0                               NOVAL                                                                                           l_enable_rx_std                           l_enable_rx_std_iface                   boolean       NOVAL         "Bit Reversal and Polarity Inversion"         "Enable TX byte reversal"                                                       1                   0                   NOVAL                                                                             "Enables transmitter byte order reversal. When the PCS / PMA interface width is 16 or 20 bits the PCS can swap the ordering of the individual 8-bit or 10-bit words. This option is not valid under all protocol modes."}\
    {std_tx_polinv_enable                   false   false         INTEGER   0                               NOVAL                                                                                           l_enable_tx_std                           l_enable_tx_std_iface                   boolean       NOVAL         "Bit Reversal and Polarity Inversion"         "Enable TX polarity inversion"                                                  1                   0                   NOVAL                                                                             "Enables TX bit polarity inversion. When enabled the 'tx_polinv' control port controls polarity inversion of the TX parallel data bits before passing to the PMA."}\
    {enable_port_tx_polinv                  false   false         INTEGER   0                               NOVAL                                                                                           l_enable_tx_std_iface                     l_enable_tx_std_iface                   boolean       NOVAL         "Bit Reversal and Polarity Inversion"         "Enable tx_polinv port"                                                         1                   1                   ::altera_xcvr_native_vi::parameters::validate_enable_port_tx_polinv               "Enables the optional tx_polinv control input port. When TX bit polarity inversion is enabled the assertion of this signal will cause the TX bit polarity to be inverted."}\
    {std_rx_bitrev_enable                   false   false         INTEGER   0                               NOVAL                                                                                           l_enable_rx_std                           l_enable_rx_std_iface                   boolean       NOVAL         "Bit Reversal and Polarity Inversion"         "Enable RX bit reversal"                                                        1                   0                   NOVAL                                                                             "Enables receiver bit order reversal. When enabled the 'rx_std_bitrev_ena' control port controls bit reversal of the RX parallel data after passing from the PMA to the PCS. When bit reversal is activated the received RX data bit order is flipped to MSB->LSB rather than the normal LSB->MSB"}\
    {enable_port_rx_std_bitrev_ena          false   false         INTEGER   0                               NOVAL                                                                                           l_enable_rx_std_iface                     l_enable_rx_std_iface                   boolean       NOVAL         "Bit Reversal and Polarity Inversion"         "Enable rx_std_bitrev_ena port"                                                 1                   1                   ::altera_xcvr_native_vi::parameters::validate_enable_port_rx_std_bitrev_ena       "Enables the optional rx_std_bitrev_ena control input port. When receiver bit order reversal is enabled the assertion of this signal will cause the received RX data bit order to be flipped to MSB->LSB rather than the normal LSB->MSB. This is an asynchronous input signal."}\
    {std_rx_byterev_enable                  false   false         INTEGER   0                               NOVAL                                                                                           l_enable_rx_std                           l_enable_rx_std_iface                   boolean       NOVAL         "Bit Reversal and Polarity Inversion"         "Enable RX byte reversal"                                                       1                   0                   NOVAL                                                                             "Enables receiver byte order reversal. When the PCS / PMA interface width is 16 or 20 bits the PCS can swap the ordering of the individual 8- or 10-bit words. When enabled the 'rx_std_byterev_ena' port controls byte swapping. This option is not valid under all protocol modes."}\
    {enable_port_rx_std_byterev_ena         false   false         INTEGER   0                               NOVAL                                                                                           l_enable_rx_std_iface                     l_enable_rx_std_iface                   boolean       NOVAL         "Bit Reversal and Polarity Inversion"         "Enable rx_std_byterev_ena port"                                                1                   1                   ::altera_xcvr_native_vi::parameters::validate_enable_port_rx_std_byterev_ena      "Enables the optional rx_std_byterev_ena control input port. When receiver byte order reversal is enabled the assertion of this signal will swap the order of individual 8- or 10-bit words received from the PMA."}\
    {std_rx_polinv_enable                   false   false         INTEGER   0                               NOVAL                                                                                           l_enable_rx_std                           l_enable_rx_std_iface                   boolean       NOVAL         "Bit Reversal and Polarity Inversion"         "Enable RX polarity inversion"                                                  1                   0                   NOVAL                                                                             "Enables RX bit polarity inversion. When enabled the 'rx_polinv' control port controls polarity inversion of the RX parallel data bits after passing from the PMA."}\
    {enable_port_rx_polinv                  false   false         INTEGER   0                               NOVAL                                                                                           l_enable_rx_std_iface                     l_enable_rx_std_iface                   boolean       NOVAL         "Bit Reversal and Polarity Inversion"         "Enable rx_polinv port"                                                         1                   1                   ::altera_xcvr_native_vi::parameters::validate_enable_port_rx_polinv               "Enables the optional rx_polinv control input port. When RX bit polarity inversion is enabled the assertion of this signal will cause the RX bit polarity to be inverted."}\
    {enable_port_rx_std_signaldetect        false   false         INTEGER   0                               NOVAL                                                                                           l_enable_rx_std_iface                     l_enable_rx_std_iface                   boolean       NOVAL         "Bit Reversal and Polarity Inversion"         "Enable rx_std_signaldetect port"                                               1                   1                   NOVAL                                                                             "Enables the optional rx_std_signaldetect status output port. The assertion of this signal indicates that a signal has been detected on the receiver. The signal detect threshold can be specified through Quartus II QSF assignments."}\
    \
    {enable_ports_pipe_sw                   false   false         INTEGER   0                               NOVAL                                                                                           l_enable_tx_std_iface                     l_enable_tx_std_iface                   boolean       NOVAL         "PCIe Ports"                                  "Enable PCIe dynamic datarate switch ports"                                     1                   1                   ::altera_xcvr_native_vi::parameters::validate_enable_ports_pipe_sw                "Enables the pipe_rate; pipe_sw; and pipe_sw_done ports. These ports must be connected to the PLL IP instance in multi-lane PCI Express Gen 2 and Gen 3 configurations. The 'pipe_sw' and 'pipe_sw_done' ports are only exposed for multi-lane bonded configurations."}\
    {enable_ports_pipe_hclk                 false   false         INTEGER   0                               NOVAL                                                                                           l_enable_tx_std_iface                     l_enable_tx_std_iface                   boolean       NOVAL         "PCIe Ports"                                  "Enable PCIe pipe_hclk_in and pipe_hclk_out ports"                              1                   1                   ::altera_xcvr_native_vi::parameters::validate_enable_ports_pipe_hclk              "Enables the pipe_hclk_in and pipe_hclk_out ports. These ports must be connected to the PLL IP instance in PCI Express configurations."}\
    {enable_ports_pipe_g3_analog            false   false         INTEGER   0                               NOVAL                                                                                           l_enable_tx_std_iface                     l_enable_tx_std_iface                   boolean       NOVAL         "PCIe Ports"                                  "Enable PCIe Gen 3 analog control ports"                                        1                   1                   ::altera_xcvr_native_vi::parameters::validate_enable_ports_pipe_g3_analog         "Enables the pipe_g3_txdeemph and pipe_g3_rxpresethint ports. These ports are used to control the PMA in PCI Express Gen 3 configurations."}\
    {enable_ports_pipe_rx_elecidle          false   false         INTEGER   0                               NOVAL                                                                                           l_enable_rx_std_iface                     l_enable_rx_std_iface                   boolean       NOVAL         "PCIe Ports"                                  "Enable PCIe electrical idle control and status ports"                          1                   1                   ::altera_xcvr_native_vi::parameters::validate_enable_ports_pipe_rx_elecidle       "Enables the pipe_rx_eidleinfersel and pipe_rx_elecidle ports. These ports are used for PCI Express configurations."}\
    {enable_port_pipe_rx_polarity           false   false         INTEGER   0                               NOVAL                                                                                           l_enable_rx_std_iface                     l_enable_rx_std_iface                   boolean       NOVAL         "PCIe Ports"                                  "Enable PCIe pipe_rx_polarity port"                                             1                   1                   ::altera_xcvr_native_vi::parameters::validate_enable_port_pipe_rx_polarity        "Enables the pipe_rx_polarity input control port. This port is used to control channel signal polarity for PCI Express configurations. When the 'Standard PCS datapath' is configured for PCIe protocol modes, the assertion of this signal will cause the TX bit polarity to be inverted. For other protocol modes the optional 'rx_polinv' port is used for TX bit polarity inversion."}\
    \
    {enh_pcs_pma_width                      false   false         INTEGER   40                              {32 40 64}                                                                                      enable_enh                                enable_enh                              NOVAL         NOVAL         "Enhanced PCS"                                "Enhanced PCS / PMA interface width"                                            1                   0                   NOVAL                                                                             "Specifies the data interface width between the Enhanced PCS and the transceiver PMA."}\
    {enh_pld_pcs_width                      false   false         INTEGER   40                              {32 40 50 64 66 67}                                                                             enable_enh                                enable_enh                              NOVAL         NOVAL         "Enhanced PCS"                                "FPGA fabric / Enhanced PCS interface width"                                    1                   0                   NOVAL                                                                             "Specifies the data inerface width between the Enhanced PCS and the FPGA fabric."}\
    {enh_rxtxfifo_double_width              false   false         INTEGER   0                               NOVAL                                                                                           enable_enh                                enable_enh                              boolean       NOVAL         "Enhanced PCS"                                "Enable RX/TX FIFO double width mode"                                           1                   0                   NOVAL                                                                             "Enables the double width mode for RX and TX FIFOs. Double width mode can be used to run the core at half clock speed."}\
    \
    {enh_txfifo_mode                        false   false         STRING    "Phase compensation"            {"Phase compensation" "Register" "Interlaken" "Basic"}                                          l_enable_tx_enh                           l_enable_tx_enh_iface                   NOVAL         NOVAL         "Enhanced PCS TX FIFO"                        "TX FIFO mode"                                                                  1                   0                   NOVAL                                                                             "Specifies the mode for the Enhanced PCS TX FIFO."}\
    {enh_txfifo_pfull                       false   false         INTEGER   11                              {0:15}                                                                                          l_enable_tx_enh                           l_enable_tx_enh_iface                   NOVAL         NOVAL         "Enhanced PCS TX FIFO"                        "TX FIFO partially full threshold"                                              1                   0                   NOVAL                                                                             "Specifies the partially full threshold for the Enhanced PCS TX FIFO."}\
    {enh_txfifo_pempty                      false   false         INTEGER   2                               {0:15}                                                                                          l_enable_tx_enh                           l_enable_tx_enh_iface                   NOVAL         NOVAL         "Enhanced PCS TX FIFO"                        "TX FIFO partially empty threshold"                                             1                   0                   NOVAL                                                                             "Specifies the partially empty threshold for the Enhanced PCS TX FIFO."}\
    {enable_port_tx_enh_fifo_full           false   false         INTEGER   0                               NOVAL                                                                                           l_enable_tx_enh_iface                     l_enable_tx_enh_iface                   boolean       NOVAL         "Enhanced PCS TX FIFO"                        "Enable tx_enh_fifo_full port"                                                  1                   1                   NOVAL                                                                             "Enables the optional tx_enh _fifo_full status output port. This signal indicates when the TX FIFO has reached the specified full threshold."}\
    {enable_port_tx_enh_fifo_pfull          false   false         INTEGER   0                               NOVAL                                                                                           l_enable_tx_enh_iface                     l_enable_tx_enh_iface                   boolean       NOVAL         "Enhanced PCS TX FIFO"                        "Enable tx_enh_fifo_pfull port"                                                 1                   1                   NOVAL                                                                             "Enables the optional tx_enh _fifo_pfull status output port. This signal indicates when the TX FIFO has reached the specified partially full threshold."}\
    {enable_port_tx_enh_fifo_empty          false   false         INTEGER   0                               NOVAL                                                                                           l_enable_tx_enh_iface                     l_enable_tx_enh_iface                   boolean       NOVAL         "Enhanced PCS TX FIFO"                        "Enable tx_enh_fifo_empty port"                                                 1                   1                   NOVAL                                                                             "Enables the optional tx_enh _fifo_empty status output port. This signal indicates when the TX FIFO has reached the speciifed empty threshold."}\
    {enable_port_tx_enh_fifo_pempty         false   false         INTEGER   0                               NOVAL                                                                                           l_enable_tx_enh_iface                     l_enable_tx_enh_iface                   boolean       NOVAL         "Enhanced PCS TX FIFO"                        "Enable tx_enh_fifo_pempty port"                                                1                   1                   NOVAL                                                                             "Enables the optional tx_enh _fifo_pempty status output port. This signal indicates when the TX FIFO has reached the specified partially empty threshold."}\
    {enable_port_tx_enh_fifo_cnt            false   false         INTEGER   0                               NOVAL                                                                                           l_enable_tx_enh_iface                     l_enable_tx_enh_iface                   boolean       NOVAL         "Enhanced PCS TX FIFO"                        "Enable tx_enh_fifo_cnt port"                                                   1                   1                   NOVAL                                                                             "Enables the optional tx_enh _fifo_cnt status output port. This signal indicates the current level of the TX FIFO."}\
    \
    {enh_rxfifo_mode                        false   false         STRING    "Phase compensation"            {"Phase compensation" "Register" "Interlaken" "10GBase-R" "Basic"}                              l_enable_rx_enh                           l_enable_rx_enh_iface                   NOVAL         NOVAL         "Enhanced PCS RX FIFO"                        "RX FIFO mode"                                                                  1                   0                   ::altera_xcvr_native_vi::parameters::validate_enh_rxfifo_mode                     "Specifies the mode for the Enhanced PCS RX FIFO."}\
    {enh_rxfifo_pfull                       false   false         INTEGER   23                              {0:31}                                                                                          l_enable_rx_enh                           l_enable_rx_enh_iface                   NOVAL         NOVAL         "Enhanced PCS RX FIFO"                        "RX FIFO partially full threshold"                                              1                   0                   NOVAL                                                                             "Specifies the empty threshold for the Enhanced PCS RX FIFO."}\
    {enh_rxfifo_pempty                      false   false         INTEGER   2                               {0:31}                                                                                          l_enable_rx_enh                           l_enable_rx_enh_iface                   NOVAL         NOVAL         "Enhanced PCS RX FIFO"                        "RX FIFO partially empty threshold"                                             1                   0                   NOVAL                                                                             "Specifies the partially empty threshold for the Enhanced PCS RX FIFO."}\
    {enh_rxfifo_align_del                   false   false         INTEGER   0                               NOVAL                                                                                           l_enable_rx_enh                           l_enable_rx_enh_iface                   boolean       NOVAL         "Enhanced PCS RX FIFO"                        "Enable RX FIFO alignment word deletion (Interlaken)"                           1                   0                   NOVAL                                                                             "Enables Interlaken alignment word (sync word) removal. When the Enhanced PCS RX FIFO is configured for interlaken mode enabling this option will cause all alignment words (sync words) to be removed after frame synchronization has occurred. This includes the first sync word. Enabling this option requires that you also enable control word deletion."}\
    {enh_rxfifo_control_del                 false   false         INTEGER   0                               NOVAL                                                                                           l_enable_rx_enh                           l_enable_rx_enh_iface                   boolean       NOVAL         "Enhanced PCS RX FIFO"                        "Enable RX FIFO control word deletion (Interlaken)"                             1                   0                   NOVAL                                                                             "Enables Interlaken control word removal. When the Enhanced PCS RX FIFO is configured for interlaken mode enabling this option will cause all control words to be removed after frame synchronization has occurred. Enabling this option requires that you also enable alignment word deletion."}\
    {enable_port_rx_enh_data_valid          false   false         INTEGER   0                               NOVAL                                                                                           l_enable_rx_enh_iface                     l_enable_rx_enh_iface                   boolean       NOVAL         "Enhanced PCS RX FIFO"                        "Enable rx_enh_data_valid port"                                                 1                   1                   NOVAL                                                                             "Enables the optional rx_enh_data_valid status output port. This signal indicates when RX data from the RX FIFO is valid."}\
    {enable_port_rx_enh_fifo_full           false   false         INTEGER   0                               NOVAL                                                                                           l_enable_rx_enh_iface                     l_enable_rx_enh_iface                   boolean       NOVAL         "Enhanced PCS RX FIFO"                        "Enable rx_enh_fifo_full port"                                                  1                   1                   NOVAL                                                                             "Enables the optional rx_enh_fifo_full status output port. This signal indicates when the RX FIFO has reached the specified full threshold."}\
    {enable_port_rx_enh_fifo_pfull          false   false         INTEGER   0                               NOVAL                                                                                           l_enable_rx_enh_iface                     l_enable_rx_enh_iface                   boolean       NOVAL         "Enhanced PCS RX FIFO"                        "Enable rx_enh_fifo_pfull port"                                                 1                   1                   NOVAL                                                                             "Enables the optional rx_enh_fifo_pfull status output port. This signal indicates when the RX FIFO has reached the specified partially full threshold."}\
    {enable_port_rx_enh_fifo_empty          false   false         INTEGER   0                               NOVAL                                                                                           l_enable_rx_enh_iface                     l_enable_rx_enh_iface                   boolean       NOVAL         "Enhanced PCS RX FIFO"                        "Enable rx_enh_fifo_empty port"                                                 1                   1                   NOVAL                                                                             "Enables the optional rx_enh_fifo_empty status output port. This signal indicates when the RX FIFO has reached the speciifed empty threshold."}\
    {enable_port_rx_enh_fifo_pempty         false   false         INTEGER   0                               NOVAL                                                                                           l_enable_rx_enh_iface                     l_enable_rx_enh_iface                   boolean       NOVAL         "Enhanced PCS RX FIFO"                        "Enable rx_enh_fifo_pempty port"                                                1                   1                   NOVAL                                                                             "Enables the optional rx_enh_fifo_pempty status output port. This signal indicates when the RX FIFO has reached the specified partially empty threshold."}\
    {enable_port_rx_enh_fifo_cnt            false   false         INTEGER   0                               NOVAL                                                                                           l_enable_rx_enh_iface                     l_enable_rx_enh_iface                   boolean       NOVAL         "Enhanced PCS RX FIFO"                        "Enable rx_enh_fifo_cnt port"                                                   1                   1                   NOVAL                                                                             "Enables the optional rx_enh_fifo_cnt status output port. This signal the indicates the current level of the RX FIFO."}\
    {enable_port_rx_enh_fifo_del            false   false         INTEGER   0                               NOVAL                                                                                           l_enable_rx_enh_iface                     l_enable_rx_enh_iface                   boolean       NOVAL         "Enhanced PCS RX FIFO"                        "Enable rx_enh_fifo_del port (10GBASE-R)"                                       1                   1                   NOVAL                                                                             "Enables the optional rx_enh_fifo_del status output port. This signal indicates when a word has been deleted from the rate-match FIFO. This signal is used in 10GBASE-R mode only."}\
    {enable_port_rx_enh_fifo_insert         false   false         INTEGER   0                               NOVAL                                                                                           l_enable_rx_enh_iface                     l_enable_rx_enh_iface                   boolean       NOVAL         "Enhanced PCS RX FIFO"                        "Enable rx_enh_fifo_insert port (10GBASE-R)"                                    1                   1                   NOVAL                                                                             "Enables the optional rx_enh_fifo_insert status output port. This signal indicates when a word has been inserted into the rate-match FIFO. This signal is used in 10GBASE-R mode only."}\
    {enable_port_rx_enh_fifo_rd_en          false   false         INTEGER   0                               NOVAL                                                                                           l_enable_rx_enh_iface                     l_enable_rx_enh_iface                   boolean       NOVAL         "Enhanced PCS RX FIFO"                        "Enable rx_enh_fifo_rd_en port (Interlaken)"                                    1                   1                   NOVAL                                                                             "Enables the optional rx_enh_fifo_rd_en control input port. This port is used for Interlaken only. Asserting this signal will read a word from the RX FIFO."}\
    {enable_port_rx_enh_fifo_align_val      false   false         INTEGER   0                               NOVAL                                                                                           l_enable_rx_enh_iface                     l_enable_rx_enh_iface                   boolean       NOVAL         "Enhanced PCS RX FIFO"                        "Enable rx_enh_fifo_align_val port (Interlaken)"                                1                   1                   NOVAL                                                                             "Enables the optional rx_enh_fifo_align_val status output port. This port is used for Interlaken only."}\
    {enable_port_rx_enh_fifo_align_clr      false   false         INTEGER   0                               NOVAL                                                                                           l_enable_rx_enh_iface                     l_enable_rx_enh_iface                   boolean       NOVAL         "Enhanced PCS RX FIFO"                        "Enable rx_enh_fifo_align_clr port (Interlaken)"                                1                   1                   NOVAL                                                                             "Enables the optional rx_enh_fifo_align_clr control input port. This port is used for Interlaken mode only."}\
    \
    {enh_tx_frmgen_enable                   false   false         INTEGER   0                               NOVAL                                                                                           l_enable_tx_enh                           l_enable_tx_enh_iface                   boolean       NOVAL         "Interlaken Frame Generator"                  "Enable Interlaken frame generator"                                             1                   0                   NOVAL                                                                             "Enables the Interlaken frame generator in the Enhanced PCS."}\
    {enh_tx_frmgen_mfrm_length              false   false         INTEGER   2048                            "0:8192"                                                                                        l_enable_tx_enh                           l_enable_tx_enh_iface                   NOVAL         NOVAL         "Interlaken Frame Generator"                  "Frame generator metaframe length"                                              1                   0                   NOVAL                                                                             "Specifies the Interlaken metaframe length for the frame generator."}\
    {enh_tx_frmgen_burst_enable             false   false         INTEGER   0                               NOVAL                                                                                           l_enable_tx_enh                           l_enable_tx_enh_iface                   boolean       NOVAL         "Interlaken Frame Generator"                  "Enable frame burst"                                                            1                   0                   NOVAL                                                                             "Enables burst functionality in the Interlaken frame generator. Refer to the user guide for more details."}\
    {enable_port_tx_enh_frame               false   false         INTEGER   0                               NOVAL                                                                                           l_enable_tx_enh_iface                     l_enable_tx_enh_iface                   boolean       NOVAL         "Interlaken Frame Generator"                  "Enable tx_enh_frame port"                                                      1                   1                   ::altera_xcvr_native_vi::parameters::validate_enable_port_tx_enh_frame            "Enables the tx_enh_frame status output port. When the Interlaken frame generator is enabled this signal indicates the beginning of a new metaframe."}\
    {enable_port_tx_enh_frame_diag_status   false   false         INTEGER   0                               NOVAL                                                                                           l_enable_tx_enh_iface                     l_enable_tx_enh_iface                   boolean       NOVAL         "Interlaken Frame Generator"                  "Enable tx_enh_frame_diag_status port"                                          1                   1                   NOVAL                                                                             "Enables the tx_enh_frame_diag_status control input port. When the Interlaken frame generator is enabled the value of this signal contains the 'Status Message' from the framing layer 'Diagnostic Word'. Refer to the user guide for more details."}\
    {enable_port_tx_enh_frame_burst_en      false   false         INTEGER   0                               NOVAL                                                                                           l_enable_tx_enh_iface                     l_enable_tx_enh_iface                   boolean       NOVAL         "Interlaken Frame Generator"                  "Enable tx_enh_frame_burst_en port"                                             1                   1                   ::altera_xcvr_native_vi::parameters::validate_enable_port_tx_enh_frame_burst_en   "Enables the tx_enh_frame_burst_en control input port. When burst functionality is enabled for the Interlaken frame generator the assertion of this signal controls frame generator data reads from the TX FIFO. Refer to the user guide for more details."}\
    \
    {enh_rx_frmsync_enable                  false   false         INTEGER   0                               NOVAL                                                                                           l_enable_rx_enh                           l_enable_rx_enh_iface                   boolean       NOVAL         "Interlaken Frame Sync"                       "Enable Interlaken frame synchronizer"                                          1                   0                   NOVAL                                                                             "Enables the Interlaken frame synchronizer in the Enhanced PCS."}\
    {enh_rx_frmsync_mfrm_length             false   false         INTEGER   2048                            "0:8192"                                                                                        l_enable_rx_enh                           l_enable_rx_enh_iface                   NOVAL         NOVAL         "Interlaken Frame Sync"                       "Frame synchronizer metaframe length"                                           1                   0                   NOVAL                                                                             "Specifies the Interlaken metaframe length for the frame synchronizer."}\
    {enable_port_rx_enh_frame               false   false         INTEGER   0                               NOVAL                                                                                           l_enable_rx_enh_iface                     l_enable_rx_enh_iface                   boolean       NOVAL         "Interlaken Frame Sync"                       "Enable rx_enh_frame port"                                                      1                   1                   NOVAL                                                                             "Enables the rx_enh_frame status output port. When the Interlaken frame synchronizer is enabled this signal indicates the beginning of a new metaframe."}\
    {enable_port_rx_enh_frame_lock          false   false         INTEGER   0                               NOVAL                                                                                           l_enable_rx_enh_iface                     l_enable_rx_enh_iface                   boolean       NOVAL         "Interlaken Frame Sync"                       "Enable rx_enh_frame_lock port"                                                 1                   1                   NOVAL                                                                             "Enables the rx_enh_frame_lock status output port. When the Interlaken frame synchronizer is enabled the assertion of this signal indicates that the frame synchronizer has acheived metaframe delineation. This is an asynchronous output signal."}\
    {enable_port_rx_enh_frame_diag_status   false   false         INTEGER   0                               NOVAL                                                                                           l_enable_rx_enh_iface                     l_enable_rx_enh_iface                   boolean       NOVAL         "Interlaken Frame Sync"                       "Enable rx_enh_frame_diag_status port"                                          1                   1                   NOVAL                                                                             "Enables the rx_enh_frame_diag_status status output port. When the Interlaken frame synchronizer is enabled This two-bit per lane output signal contains the value of the framing layer diagnostic word (bits\[33:32\]). This signal is latched when a valid diagnostic word is received."}\
    \
    {enh_tx_crcgen_enable                   false   false         INTEGER   0                               NOVAL                                                                                           l_enable_tx_enh                           l_enable_tx_enh_iface                   boolean       NOVAL         "Interlaken CRC-32 Generator and Checker"     "Enable Interlaken TX CRC-32 generator"                                         1                   0                   NOVAL                                                                             "Enables the Interlaken CRC-32 generator. This can be used as a dignostic tool. The CRC includes the entire metaframe including the diagnostic word."}\
    {enh_tx_crcerr_enable                   false   false         INTEGER   0                               NOVAL                                                                                           l_enable_tx_enh                           l_enable_tx_enh_iface                   boolean       NOVAL         "Interlaken CRC-32 Generator and Checker"     "Enable Interlaken TX CRC-32 generator error insertion"                         1                   0                   NOVAL                                                                             "Enables error insertion for the Interlaken CRC-32 generator. Error insertion is cycle-accurate. When enabled, the assertion of tx_control\[8\] will insert an error on that corresponding data word."}\
    {enh_rx_crcchk_enable                   false   false         INTEGER   0                               NOVAL                                                                                           l_enable_rx_enh                           l_enable_rx_enh_iface                   boolean       NOVAL         "Interlaken CRC-32 Generator and Checker"     "Enable Interlaken RX CRC-32 checker"                                           1                   0                   NOVAL                                                                             "Enables the Interlaken CRC-32 checker."}\
    {enable_port_rx_enh_crc32_err           false   false         INTEGER   0                               NOVAL                                                                                           l_enable_rx_enh_iface                     l_enable_rx_enh_iface                   boolean       NOVAL         "Interlaken CRC-32 Generator and Checker"     "Enable rx_enh_crc32_err port"                                                  1                   1                   NOVAL                                                                             "Enables the optional rx_enh_crc32_err status output port. When the Interlaken CRC-32 checker is enabled the assertion of this signal indicates the detection of a CRC error in the metaframe."}\
    \
    {enable_port_rx_enh_highber             false   false         INTEGER   0                               NOVAL                                                                                           l_enable_rx_enh_iface                     l_enable_rx_enh_iface                   boolean       NOVAL         "10GBASE-R BER Checker"                       "Enable rx_enh_highber port (10GBASE-R)"                                        1                   1                   NOVAL                                                                             "Enables the optional rx_enh_highber status output port. In 10GBASE-R mode the assertion of this signal indicates a bit-error rate higher then 10^-4. For the 10GBASE-R specification this occurs when there are at least 16 errors within 125us."}\
    {enable_port_rx_enh_highber_clr_cnt     false   false         INTEGER   0                               NOVAL                                                                                           l_enable_rx_enh_iface                     l_enable_rx_enh_iface                   boolean       NOVAL         "10GBASE-R BER Checker"                       "Enable rx_enh_highber_clr_cnt port (10GBASE-R)"                                1                   1                   NOVAL                                                                             "Enables the optional rx_enh_highber_clr_cnt control input port. In 10GBASE-R mode the assertion of this signal will clear the internal counter for the number of times the BER state machine has entered the \"BER_BAD_SH\" state."}\
    {enable_port_rx_enh_clr_errblk_count    false   false         INTEGER   0                               NOVAL                                                                                           l_enable_rx_enh_iface                     l_enable_rx_enh_iface                   boolean       NOVAL         "10GBASE-R BER Checker"                       "Enable rx_enh_clr_errblk_count port (10GBASE-R & FEC)"                         1                   1                   NOVAL                                                                             "Enables the optional rx_enh_clr_errblk_count control input port. In 10GBASE-R mode, the assertion of this signal will clear the internal counter for the number of times the RX state machine has entered the \"RX_E\" state. In modes where the FEC block is enabled, the assertion of this signal will reset the status counters within the RX FEC block."}\
    \
    {enh_tx_64b66b_enable                   false   false         INTEGER   0                               NOVAL                                                                                           l_enable_tx_enh                           l_enable_tx_enh_iface                   boolean       NOVAL         "64b/66b Encoder and Decoder"                 "Enable TX 64b/66b encoder"                                                     1                   0                   NOVAL                                                                             "Enables the 64b/66b encoder."}\
    {enh_rx_64b66b_enable                   false   false         INTEGER   0                               NOVAL                                                                                           l_enable_rx_enh                           l_enable_rx_enh_iface                   boolean       NOVAL         "64b/66b Encoder and Decoder"                 "Enable RX 64b/66b decoder"                                                     1                   0                   NOVAL                                                                             "Enables the 64b/66b decoder."}\
    {enh_tx_sh_err                          false   false         INTEGER   0                               NOVAL                                                                                           l_enable_tx_enh                           l_enable_tx_enh_iface                   boolean       NOVAL         "64b/66b Encoder and Decoder"                 "Enable TX sync header error insertion"                                         1                   0                   NOVAL                                                                             "Enables 64b/66b sync header error insertion for 10GBASE-R or Interlaken."}\
    \
    {enh_tx_scram_enable                    false   false         INTEGER   0                               NOVAL                                                                                           l_enable_tx_enh                           l_enable_tx_enh_iface                   boolean       NOVAL         "Scrambler and Descrambler"                   "Enable TX scrambler (10GBASE-R/Interlaken)"                                    1                   0                   NOVAL                                                                             "Enables the TX data scrambler for 10GBASE-R and Interlaken. Refer to the device handbook for further details."}\
    {enh_tx_scram_seed                      false   false         LONG      0                               NOVAL                                                                                           "l_enable_tx_enh && enh_tx_scram_enable"  l_enable_tx_enh_iface                   hexadecimal   NOVAL         "Scrambler and Descrambler"                   "TX scrambler seed (10GBASE-R/Interlaken)"                                      1                   0                   NOVAL                                                                             "Specifies the initial seed for the 10GBASE-R / Interlaken scrambler."}\
    {enh_rx_descram_enable                  false   false         INTEGER   0                               NOVAL                                                                                           l_enable_rx_enh                           l_enable_rx_enh_iface                   boolean       NOVAL         "Scrambler and Descrambler"                   "Enable RX descrambler (10GBASE-R/Interlaken)"                                  1                   0                   NOVAL                                                                             "Enables the RX data descrambler for 10GBASE-R and Interlaken. Refer to the device handbook for further details."}\
    \
    {enh_tx_dispgen_enable                  false   false         INTEGER   0                               NOVAL                                                                                           l_enable_tx_enh                           l_enable_tx_enh_iface                   boolean       NOVAL         "Interlaken Disparity Generator and Checker"  "Enable Interlaken TX disparity generator"                                      1                   0                   NOVAL                                                                             "Enables the Interlaken disparity generator."}\
    {enh_rx_dispchk_enable                  false   false         INTEGER   0                               NOVAL                                                                                           l_enable_rx_enh                           l_enable_rx_enh_iface                   boolean       NOVAL         "Interlaken Disparity Generator and Checker"  "Enable Interlaken RX disparity checker"                                        1                   0                   NOVAL                                                                             "Enables the Interlaken disparity checker."}\
    \
    {enh_rx_blksync_enable                  false   false         INTEGER   0                               NOVAL                                                                                           l_enable_rx_enh                           l_enable_rx_enh_iface                   boolean       NOVAL         "Block Sync"                                  "Enable RX block synchronizer"                                                  1                   0                   NOVAL                                                                             "Enables the block synchronizer for the 10G RX PCS. Primariliy used in Interlaken and 10GBASE-R modes."}\
    {enable_port_rx_enh_blk_lock            false   false         INTEGER   0                               NOVAL                                                                                           l_enable_rx_enh_iface                     l_enable_rx_enh_iface                   boolean       NOVAL         "Block Sync"                                  "Enable rx_enh_blk_lock port"                                                   1                   1                   NOVAL                                                                             "Enables the optional enable_port_rx_enh_blk_lock status output port. When the block synchronizer is enabled the assertion of this signal indicates that block delineation has been achieved. This is an asynchronous output signal."}\
    \
    {enh_tx_bitslip_enable                  false   false         INTEGER   0                               NOVAL                                                                                           l_enable_tx_enh                           l_enable_tx_enh_iface                   boolean       NOVAL         "Gearbox"                                     "Enable TX data bitslip"                                                        1                   0                   NOVAL                                                                             "Enables TX bitslip support for the Enhanced TX PCS datapath. When enabled the tx_enh_bitslip port controls the number of bit locations to slip the TX parallel data before passing to the PMA."}\
    {enh_tx_polinv_enable                   false   false         INTEGER   0                               NOVAL                                                                                           l_enable_tx_enh                           l_enable_tx_enh_iface                   boolean       NOVAL         "Gearbox"                                     "Enable TX data polarity inversion"                                             1                   0                   NOVAL                                                                             "Enables TX bit polarity inversion for the Enhanced TX PCS datapath. When enabled the TX parallel data bits will be inverted before passing to the PMA."}\
    {enh_rx_bitslip_enable                  false   false         INTEGER   0                               NOVAL                                                                                           l_enable_rx_enh                           l_enable_rx_enh_iface                   boolean       NOVAL         "Gearbox"                                     "Enable RX data bitslip"                                                        1                   0                   NOVAL                                                                             "Enables RX bitslip support for the Enhanced RX PCS datapath. When enabled the rising edge assertion of the rx_bitslip port causes the RX parallel data from the PMA to slip by one bit before passing to the PCS."}\
    {enh_rx_polinv_enable                   false   false         INTEGER   0                               NOVAL                                                                                           l_enable_rx_enh                           l_enable_rx_enh_iface                   boolean       NOVAL         "Gearbox"                                     "Enable RX data polarity inversion"                                             1                   0                   NOVAL                                                                             "Enables RX bit polarity inversion for the Enhanced RX PCS datapath. When enabled the RX parallel data bits will be inverted before passing from the PMA to the PCS."}\
    {enable_port_tx_enh_bitslip             false   false         INTEGER   0                               NOVAL                                                                                           l_enable_tx_enh_iface                     l_enable_tx_enh_iface                   boolean       NOVAL         "Gearbox"                                     "Enable tx_enh_bitslip port"                                                    1                   1                   ::altera_xcvr_native_vi::parameters::validate_enable_port_tx_enh_bitslip          "Enables the optional tx_enh_bitslip control input port. When TX bitslip support is enabled for the 10G PCS the value of this signal controls the number bit locations to slip the TX parallel data before passing to the PMA."}\
    {enable_port_rx_enh_bitslip             false   false         INTEGER   0                               NOVAL                                                                                           l_enable_rx_enh_iface                     l_enable_rx_enh_iface                   boolean       NOVAL         "Gearbox"                                     "Enable rx_bitslip port"                                                        1                   1                   ::altera_xcvr_native_vi::parameters::validate_enable_port_rx_enh_bitslip          "Enables the optional rx_bitslip control input port. When RX bitslip support is enabled for the 10G PCS; a rising edge on this signal will cause the RX parallel data to be slipped by one bit location after passing from the PMA. This is the shared RX bitslip control port for the Standard and Enhanced PCS datapaths."}\
    \
    {enh_rx_krfec_err_mark_enable           false   false         INTEGER   0                               NOVAL                                                                                           l_enable_rx_enh                           l_enable_rx_enh_iface                   boolean       NOVAL         "KR-FEC"                                      "Enable RX KR-FEC error marking"                                                1                   0                   NOVAL                                                                             "Enables the optional error marking feature of the KR-FEC decoder. When enabled, if an uncorrectable error is detected by the decoder, both sync data bits will be asserted (2'b11) to indicate the uncorrectable error. This feature increases latency through the KR-FEC decoder."}\
    \
    {pcs_direct_width                       false   false         INTEGER   8                               {8 10 16 20 32 40 64}                                                                           enable_pcs_dir                            enable_pcs_dir                          NOVAL         NOVAL         "PCS Direct Datapath"                         "PCS Direct interface width"                                                    1                   0                   NOVAL                                                                             "Specifies the data interface width between the Enhanced PCS and the transceiver PMA."}\
    \
    {generate_docs                          false   false         INTEGER   1                               NOVAL                                                                                           true                                      true                                    boolean       NOVAL         "Generation Options"                          "Generate parameter documentation file"                                         0                   0                   NOVAL                                                                             "When enabled, generation will produce a .CSV file with descriptions of the IP parameters."}\
    {generate_add_hdl_instance_example      false   false         INTEGER   0                               NOVAL                                                                                           enable_advanced_options                   enable_advanced_options                 boolean       NOVAL         "Generation Options"                          "Generate '_hw.tcl' 'add_hdl_instance' example file"                            0                   0                   NOVAL                                                                             "When enabled, generation will produce a file containing an example of how to use the '_hw.tcl' 'add_hdl_instance' API. The example will be correct for the current configuration of the IP."}\
    \
    {validation_rule_select                 false   false         STRING    NOVAL                           NOVAL                                                                                           enable_advanced_options                   enable_advanced_options                 NOVAL         NOVAL         "Parameter Validation Rules"                  "View validation rule for parameter"                                            0                   0                   NOVAL                                                                             "Allows you to view the validation rule for the selected transceiver atom parameter."}\
    \
    {enable_advanced_options                true    false         INTEGER   0                               NOVAL                                                                                           true                                      false                                   NOVAL         NOVAL         NOVAL                                         NOVAL                                                                           0                   0                   NOVAL                                                                             NOVAL}\
    {enable_debug_options                   true    false         INTEGER   0                               NOVAL                                                                                           true                                      false                                   NOVAL         NOVAL         NOVAL                                         NOVAL                                                                           0                   0                   NOVAL                                                                             NOVAL}\
    \
    {tx_enable                              true    false         INTEGER   1                               NOVAL                                                                                           true                                      false                                   NOVAL         NOVAL         NOVAL                                         NOVAL                                                                           0                   0                   ::altera_xcvr_native_vi::parameters::validate_tx_enable                           NOVAL}\
    {datapath_select                        true    false         STRING    NOVAL                           NOVAL                                                                                           true                                      false                                   NOVAL         NOVAL         NOVAL                                         NOVAL                                                                           0                   0                   NOVAL                                                                             NOVAL}\
    {rx_enable                              true    false         INTEGER   1                               NOVAL                                                                                           true                                      false                                   NOVAL         NOVAL         NOVAL                                         NOVAL                                                                           0                   0                   ::altera_xcvr_native_vi::parameters::validate_rx_enable                           NOVAL}\
    {l_pcs_pma_width                        true    false         INTEGER   1                               NOVAL                                                                                           true                                      false                                   NOVAL         NOVAL         NOVAL                                         NOVAL                                                                           0                   0                   ::altera_xcvr_native_vi::parameters::validate_l_pcs_pma_width                     NOVAL}\
    {l_pll_settings                         true    false         STRING    NOVAL                           NOVAL                                                                                           true                                      false                                   NOVAL         NOVAL         NOVAL                                         NOVAL                                                                           0                   0                   ::altera_xcvr_native_vi::parameters::validate_l_pll_settings                      NOVAL}\
    {l_pll_settings_key                     true    false         STRING    NOVAL                           NOVAL                                                                                           true                                      false                                   NOVAL         NOVAL         NOVAL                                         NOVAL                                                                           0                   0                   ::altera_xcvr_native_vi::parameters::validate_l_pll_settings_key                  NOVAL}\
    {l_enable_pma_bonding                   true    false         INTEGER   0                               NOVAL                                                                                           true                                      false                                   NOVAL         NOVAL         NOVAL                                         NOVAL                                                                           0                   0                   ::altera_xcvr_native_vi::parameters::validate_l_enable_pma_bonding                NOVAL}\
    \
    {enable_std                             true    false         INTEGER   1                               NOVAL                                                                                           true                                      false                                   NOVAL         NOVAL         NOVAL                                         NOVAL                                                                           0                   0                   ::altera_xcvr_native_vi::parameters::validate_enable_std                          NOVAL}\
    {l_enable_std_pipe                      true    false         INTEGER   0                               NOVAL                                                                                           true                                      false                                   NOVAL         NOVAL         NOVAL                                         NOVAL                                                                           0                   0                   ::altera_xcvr_native_vi::parameters::validate_l_enable_std_pipe                   NOVAL}\
    {l_enable_tx_std                        true    false         INTEGER   0                               NOVAL                                                                                           true                                      false                                   NOVAL         NOVAL         NOVAL                                         NOVAL                                                                           0                   0                   ::altera_xcvr_native_vi::parameters::validate_l_enable_tx_std                     NOVAL}\
    {l_enable_rx_std                        true    false         INTEGER   0                               NOVAL                                                                                           true                                      false                                   NOVAL         NOVAL         NOVAL                                         NOVAL                                                                           0                   0                   ::altera_xcvr_native_vi::parameters::validate_l_enable_rx_std                     NOVAL}\
    {l_enable_tx_std_iface                  true    false         INTEGER   0                               NOVAL                                                                                           true                                      false                                   NOVAL         NOVAL         NOVAL                                         NOVAL                                                                           0                   0                   ::altera_xcvr_native_vi::parameters::validate_l_enable_tx_std_iface               NOVAL}\
    {l_enable_rx_std_iface                  true    false         INTEGER   0                               NOVAL                                                                                           true                                      false                                   NOVAL         NOVAL         NOVAL                                         NOVAL                                                                           0                   0                   ::altera_xcvr_native_vi::parameters::validate_l_enable_rx_std_iface               NOVAL}\
    {l_std_tx_word_count                    true    false         INTEGER   0                               NOVAL                                                                                           true                                      false                                   NOVAL         NOVAL         NOVAL                                         NOVAL                                                                           0                   0                   ::altera_xcvr_native_vi::parameters::validate_l_std_tx_word_count                 NOVAL}\
    {l_std_tx_word_width                    true    false         INTEGER   0                               NOVAL                                                                                           true                                      false                                   NOVAL         NOVAL         NOVAL                                         NOVAL                                                                           0                   0                   ::altera_xcvr_native_vi::parameters::validate_l_std_tx_word_width                 NOVAL}\
    {l_std_tx_field_width                   true    false         INTEGER   0                               NOVAL                                                                                           true                                      false                                   NOVAL         NOVAL         NOVAL                                         NOVAL                                                                           0                   0                   ::altera_xcvr_native_vi::parameters::validate_l_std_tx_field_width                NOVAL}\
    {l_std_rx_word_count                    true    false         INTEGER   0                               NOVAL                                                                                           true                                      false                                   NOVAL         NOVAL         NOVAL                                         NOVAL                                                                           0                   0                   ::altera_xcvr_native_vi::parameters::validate_l_std_rx_word_count                 NOVAL}\
    {l_std_rx_word_width                    true    false         INTEGER   0                               NOVAL                                                                                           true                                      false                                   NOVAL         NOVAL         NOVAL                                         NOVAL                                                                           0                   0                   ::altera_xcvr_native_vi::parameters::validate_l_std_rx_word_width                 NOVAL}\
    {l_std_rx_field_width                   true    false         INTEGER   0                               NOVAL                                                                                           true                                      false                                   NOVAL         NOVAL         NOVAL                                         NOVAL                                                                           0                   0                   ::altera_xcvr_native_vi::parameters::validate_l_std_rx_field_width                NOVAL}\
    \
    {enable_enh                             true    false         INTEGER   0                               NOVAL                                                                                           true                                      false                                   NOVAL         NOVAL         NOVAL                                         NOVAL                                                                           0                   0                   ::altera_xcvr_native_vi::parameters::validate_enable_enh                          NOVAL}\
    {l_enable_tx_enh                        true    false         INTEGER   0                               NOVAL                                                                                           true                                      false                                   NOVAL         NOVAL         NOVAL                                         NOVAL                                                                           0                   0                   ::altera_xcvr_native_vi::parameters::validate_l_enable_tx_enh                     NOVAL}\
    {l_enable_rx_enh                        true    false         INTEGER   0                               NOVAL                                                                                           true                                      false                                   NOVAL         NOVAL         NOVAL                                         NOVAL                                                                           0                   0                   ::altera_xcvr_native_vi::parameters::validate_l_enable_rx_enh                     NOVAL}\
    {l_enable_tx_enh_iface                  true    false         INTEGER   0                               NOVAL                                                                                           true                                      false                                   NOVAL         NOVAL         NOVAL                                         NOVAL                                                                           0                   0                   ::altera_xcvr_native_vi::parameters::validate_l_enable_tx_enh_iface               NOVAL}\
    {l_enable_rx_enh_iface                  true    false         INTEGER   0                               NOVAL                                                                                           true                                      false                                   NOVAL         NOVAL         NOVAL                                         NOVAL                                                                           0                   0                   ::altera_xcvr_native_vi::parameters::validate_l_enable_rx_enh_iface               NOVAL}\
    \
    {enable_pcs_dir                         true    false         INTEGER   0                               NOVAL                                                                                           true                                      false                                   NOVAL         NOVAL         NOVAL                                         NOVAL                                                                           0                   0                   ::altera_xcvr_native_vi::parameters::validate_enable_pcs_dir                      NOVAL}\
    {l_enable_tx_pcs_dir                    true    false         INTEGER   0                               NOVAL                                                                                           true                                      false                                   NOVAL         NOVAL         NOVAL                                         NOVAL                                                                           0                   0                   ::altera_xcvr_native_vi::parameters::validate_l_enable_tx_pcs_dir                 NOVAL}\
    {l_enable_rx_pcs_dir                    true    false         INTEGER   0                               NOVAL                                                                                           true                                      false                                   NOVAL         NOVAL         NOVAL                                         NOVAL                                                                           0                   0                   ::altera_xcvr_native_vi::parameters::validate_l_enable_rx_pcs_dir                 NOVAL}\
    \
    {l_rcfg_ifaces                          true    false         INTEGER   1                               NOVAL                                                                                           true                                      false                                   NOVAL         NOVAL         NOVAL                                         NOVAL                                                                           0                   0                   ::altera_xcvr_native_vi::parameters::validate_l_rcfg_ifaces                       NOVAL}\
    {l_rcfg_addr_bits                       true    false         INTEGER   10                              NOVAL                                                                                           true                                      false                                   NOVAL         NOVAL         NOVAL                                         NOVAL                                                                           0                   0                   ::altera_xcvr_native_vi::parameters::validate_l_rcfg_addr_bits                    NOVAL}\
  }

  set rcfg_parameters {
    {NAME                                   DERIVED HDL_PARAMETER TYPE        DEFAULT_VALUE             ALLOWED_RANGES      ENABLED                 VISIBLE     DISPLAY_HINT  DISPLAY_ITEM                  DISPLAY_NAME                                M_CONTEXT VALIDATION_CALLBACK                                               DESCRIPTION }\
    {rcfg_enable                            false   true          INTEGER     0                         NOVAL               true                    true        boolean       "Dynamic Reconfiguration"     "Enable dynamic reconfiguration"            NOVAL     NOVAL                                                             "Enables the dynamic reconfiguration interface." }\
    {rcfg_shared                            false   true          INTEGER     0                         NOVAL               rcfg_enable             true        boolean       "Dynamic Reconfiguration"     "Share reconfiguration interface"           NOVAL     ::altera_xcvr_native_vi::parameters::validate_rcfg_shared         "When enabled the IP will present a single AVMM interface for dynamic reconfiguration of all channels. In this configuration the upper \[n:9\] address bits of the \"reconfig_address\" port are used to address the desired channel. Address bits \[8:0\] provide the register offset address within the channels reconfiguration space."}\
    {rcfg_jtag_enable                       false   true          INTEGER     0                         NOVAL               rcfg_enable             true        boolean       "Dynamic Reconfiguration"     "Enable embedded JTAG AVMM master"          NOVAL     ::altera_xcvr_native_vi::parameters::validate_rcfg_jtag_enable    "When enabled the IP will include an embedded JTAG AVMM master connected to the dynamic reconfiguration interface. This will allow you to access the transceiver's reconfiguration space and perform certain test and debug functions via JTAG using Altera's System Console appliation. This option requires that you enable the \"Share reconfiguration interface\" option."}\
    \
    {rcfg_file_prefix                       false   false         STRING      "altera_xcvr_native_a10"  NOVAL               rcfg_enable             true        NOVAL         "Configuration Files"         "Configuration file prefix"                 NOVAL     NOVAL                                                             "Specifies the file prefix to use for generated configuration files when enabled. Each variant of the IP should use a unique prefix for configuration files."}\
    {rcfg_sv_file_enable                    false   false         INTEGER     0                         NOVAL               rcfg_enable             true        boolean       "Configuration Files"         "Generate SystemVerilog package file"       NOVAL     NOVAL                                                             "When enabled The IP will generate a SystemVerilog package file named \"<rcfg_file_prefix>_reconfig_parameters.sv\" containing parameters defined with the attribute values needed for reconfiguration."}\
    {rcfg_h_file_enable                     false   false         INTEGER     0                         NOVAL               rcfg_enable             true        boolean       "Configuration Files"         "Generate C header file"                    NOVAL     NOVAL                                                             "When enabled The IP will generate a C header file named \"<rcfg_file_prefix>_reconfig_parameters.h\" containing macros defined with the attribute values needed for reconfiguration."}\
    {rcfg_mif_file_enable                   false   false         INTEGER     0                         NOVAL               rcfg_enable             true        boolean       "Configuration Files"         "Generate MIF (Memory Initialize File)"     NOVAL     NOVAL                                                             "When enabled The IP will generate an Altera MIF (Memory Initialization File) named \"<rcfg_file_prefix>_reconfig_parameters.mif\". The MIF file contains the attribute values needed for reconfiguration in a data format."}\
    \
    {rcfg_multi_enable                      false   false         INTEGER     0                         NOVAL               enable_advanced_options true        boolean       "Configuration Profiles"      "Enable multiple reconfiguration profiles"  NOVAL     NOVAL                                                             "When enabled you can use the GUI to store multiple configurations. The IP will generate reconfiguration files for all of the stored profiles. The IP will also check your multiple reconfiguration profiles for consistency to ensure you can reconfigure between them. Among other things this checks that you have exposed the same ports for each configuration."}\
    {rcfg_reduced_files_enable              false   false         INTEGER     0                         NOVAL               rcfg_multi_enable       true        boolean       "Configuration Profiles"      "Generate reduced reconfiguration files"    NOVAL     NOVAL                                                             "When enabled The IP will generate reconfiguration report files containing only the attributes or RAM data that are different between the multiple configured profiles."}\
    {rcfg_profile_cnt                       false   false         INTEGER     2                         {1 2 3 4 5 6 7 8}   rcfg_multi_enable       true        NOVAL         "Configuration Profiles"      "Number of reconfiguration profiles"        NOVAL     NOVAL                                                             "Specifies the number of reconfiguration profiles to support when multiple reconfiguration profiles are enabled."}\
    {rcfg_profile_select                    false   false         INTEGER     1                         {1}                 rcfg_multi_enable       true        NOVAL         "Configuration Profiles"      "Selected reconfiguration profile"          NOVAL     ::altera_xcvr_native_vi::parameters::validate_rcfg_profile_select "Selects which reconfiguration profile to store when clicking the \"Store profile\" button."}\
    {rcfg_profile_data0                     false   false         STRING      ""                        NOVAL               true                    false       NOVAL         NOVAL                         NOVAL                                       NOVAL     NOVAL                                                             NOVAL}\
    {rcfg_profile_data1                     false   false         STRING      ""                        NOVAL               true                    false       NOVAL         NOVAL                         NOVAL                                       NOVAL     NOVAL                                                             NOVAL}\
    {rcfg_profile_data2                     false   false         STRING      ""                        NOVAL               true                    false       NOVAL         NOVAL                         NOVAL                                       NOVAL     NOVAL                                                             NOVAL}\
    {rcfg_profile_data3                     false   false         STRING      ""                        NOVAL               true                    false       NOVAL         NOVAL                         NOVAL                                       NOVAL     NOVAL                                                             NOVAL}\
    {rcfg_profile_data4                     false   false         STRING      ""                        NOVAL               true                    false       NOVAL         NOVAL                         NOVAL                                       NOVAL     NOVAL                                                             NOVAL}\
    {rcfg_profile_data5                     false   false         STRING      ""                        NOVAL               true                    false       NOVAL         NOVAL                         NOVAL                                       NOVAL     NOVAL                                                             NOVAL}\
    {rcfg_profile_data6                     false   false         STRING      ""                        NOVAL               true                    false       NOVAL         NOVAL                         NOVAL                                       NOVAL     NOVAL                                                             NOVAL}\
    {rcfg_profile_data7                     false   false         STRING      ""                        NOVAL               true                    false       NOVAL         NOVAL                         NOVAL                                       NOVAL     NOVAL                                                             NOVAL}\
    \
    {rcfg_params                            true    false         STRING_LIST NOVAL                     NOVAL               false                   false       fixed_size    NOVAL                         NOVAL                                       NOVAL     NOVAL                                                             NOVAL}\
    {rcfg_param_labels                      true    false         STRING_LIST NOVAL                     NOVAL               false                   false       fixed_size    "Reconfiguration Parameters"  "IP Parameters"                             NOVAL     NOVAL                                                             NOVAL}\
    {rcfg_param_vals0                       true    false         STRING_LIST NOVAL                     NOVAL               false                   false       fixed_size    "Reconfiguration Parameters"  "Profile 0"                                 0         ::altera_xcvr_native_vi::parameters::validate_rcfg_param_vals     NOVAL}\
    {rcfg_param_vals1                       true    false         STRING_LIST NOVAL                     NOVAL               false                   false       fixed_size    "Reconfiguration Parameters"  "Profile 1"                                 1         ::altera_xcvr_native_vi::parameters::validate_rcfg_param_vals     NOVAL}\
    {rcfg_param_vals2                       true    false         STRING_LIST NOVAL                     NOVAL               false                   false       fixed_size    "Reconfiguration Parameters"  "Profile 2"                                 2         ::altera_xcvr_native_vi::parameters::validate_rcfg_param_vals     NOVAL}\
    {rcfg_param_vals3                       true    false         STRING_LIST NOVAL                     NOVAL               false                   false       fixed_size    "Reconfiguration Parameters"  "Profile 3"                                 3         ::altera_xcvr_native_vi::parameters::validate_rcfg_param_vals     NOVAL}\
    {rcfg_param_vals4                       true    false         STRING_LIST NOVAL                     NOVAL               false                   false       fixed_size    "Reconfiguration Parameters"  "Profile 4"                                 4         ::altera_xcvr_native_vi::parameters::validate_rcfg_param_vals     NOVAL}\
    {rcfg_param_vals5                       true    false         STRING_LIST NOVAL                     NOVAL               false                   false       fixed_size    "Reconfiguration Parameters"  "Profile 5"                                 5         ::altera_xcvr_native_vi::parameters::validate_rcfg_param_vals     NOVAL}\
    {rcfg_param_vals6                       true    false         STRING_LIST NOVAL                     NOVAL               false                   false       fixed_size    "Reconfiguration Parameters"  "Profile 6"                                 6         ::altera_xcvr_native_vi::parameters::validate_rcfg_param_vals     NOVAL}\
    {rcfg_param_vals7                       true    false         STRING_LIST NOVAL                     NOVAL               false                   false       fixed_size    "Reconfiguration Parameters"  "Profile 7"                                 7         ::altera_xcvr_native_vi::parameters::validate_rcfg_param_vals     NOVAL}\
  }

  set parameter_mappings {
    {NAME                                                     M_AUTOSET                                   M_AUTOWARN          M_MAPS_FROM                                                 M_MAP_DEFAULT             M_MAP_VALUES  } \
    {datapath_select                                          NOVAL                                       NOVAL               protocol_mode                                               NOVAL                     {"basic_std:Standard" "basic_std_rm:Standard" "cpri:Standard" "cpri_rx_tx:Standard" "gige:Standard" "gige_1588:Standard" "pipe_g1:Standard" "pipe_g2:Standard" "pipe_g3:Standard" "basic_enh:Enhanced" "interlaken_mode:Enhanced" "sfis_mode:Enhanced" "teng_baser_mode:Enhanced" "teng_1588_mode:Enhanced" "teng_sdi_mode:Enhanced" "teng_baser_krfec_mode:Enhanced" "basic_krfec_mode:Enhanced" "test_prp_mode:Enhanced" "teng_1588_krfec_mode:Enhanced"}} \
    {cdr_pll_datarate                                         false                                       false               data_rate                                                   NOVAL                     NOVAL} \
    {cdr_pll_pma_width                                        false                                       false               l_pcs_pma_width                                             NOVAL                     NOVAL} \
    {hssi_10g_tx_pcs_gb_tx_idwidth                            !l_enable_tx_enh                            false               enh_pld_pcs_width                                           NOVAL                     {"32:width_32" "40:width_40" "50:width_50" "64:width_64" "66:width_66" "67:width_67"}} \
    {hssi_10g_rx_pcs_gb_rx_odwidth                            !l_enable_rx_enh                            false               enh_pld_pcs_width                                           NOVAL                     {"32:width_32" "40:width_40" "50:width_50" "64:width_64" "66:width_66" "67:width_67"}} \
    {hssi_10g_tx_pcs_txfifo_mode                              !l_enable_tx_enh                            false               enh_txfifo_mode                                             NOVAL                     {"Phase compensation:phase_comp" "Register:register_mode" "Interlaken:interlaken_generic" "Basic:basic_generic"}} \
    {hssi_10g_tx_pcs_txfifo_pfull                             !l_enable_tx_enh                            false               enh_txfifo_pfull                                            NOVAL                     NOVAL} \
    {hssi_10g_tx_pcs_txfifo_pempty                            !l_enable_rx_enh                            false               enh_txfifo_pempty                                           NOVAL                     NOVAL} \
    {hssi_10g_rx_pcs_rxfifo_mode                              !l_enable_rx_enh                            false               enh_rxfifo_mode                                             NOVAL                     {"Phase compensation:phase_comp" "Register:register_mode" "Interlaken:generic_interlaken" "10GBase-R:clk_comp_10g" "Basic:generic_basic" "Phase compensation (data_valid):phase_comp_dv"}} \
    {hssi_10g_rx_pcs_rxfifo_pfull                             !l_enable_rx_enh                            false               enh_rxfifo_pfull                                            NOVAL                     NOVAL} \
    {hssi_10g_rx_pcs_rxfifo_pempty                            !l_enable_rx_enh                            false               enh_rxfifo_pempty                                           NOVAL                     NOVAL} \
    {hssi_10g_rx_pcs_align_del                                !l_enable_rx_enh                            false               enh_rxfifo_align_del                                        NOVAL                     {"0:align_del_dis" "1:align_del_en"}}\
    {hssi_10g_rx_pcs_control_del                              !l_enable_rx_enh                            false               enh_rxfifo_control_del                                      NOVAL                     {"0:control_del_none" "1:control_del_all"}}\
    {hssi_10g_tx_pcs_frmgen_bypass                            !l_enable_tx_enh                            false               enh_tx_frmgen_enable                                        NOVAL                     {"0:frmgen_bypass_en" "1:frmgen_bypass_dis"}}\
    {hssi_10g_tx_pcs_frmgen_mfrm_length                       !l_enable_tx_enh                            false               enh_tx_frmgen_mfrm_length                                   NOVAL                     NOVAL} \
    {hssi_10g_tx_pcs_frmgen_burst                             !l_enable_tx_enh                            false               enh_tx_frmgen_burst_enable                                  NOVAL                     {"0:frmgen_burst_dis" "1:frmgen_burst_en"}}\
    {hssi_10g_rx_pcs_frmsync_bypass                           !l_enable_rx_enh                            false               enh_rx_frmsync_enable                                       NOVAL                     {"0:frmsync_bypass_en" "1:frmsync_bypass_dis"}}\
    {hssi_10g_rx_pcs_frmsync_mfrm_length                      !l_enable_rx_enh                            false               enh_rx_frmsync_mfrm_length                                  NOVAL                     NOVAL} \
    {hssi_10g_tx_pcs_sh_err                                   !l_enable_tx_enh                            false               enh_tx_sh_err                                               NOVAL                     {"0:sh_err_dis" "1:sh_err_en"}}\
    {hssi_10g_tx_pcs_crcgen_bypass                            !l_enable_tx_enh                            false               enh_tx_crcgen_enable                                        NOVAL                     {"0:crcgen_bypass_en" "1:crcgen_bypass_dis"}}\
    {hssi_10g_tx_pcs_crcgen_err                               !l_enable_tx_enh                            false               enh_tx_crcerr_enable                                        NOVAL                     {"0:crcgen_err_dis" "1:crcgen_err_en"}}\
    {hssi_10g_rx_pcs_crcchk_bypass                            !l_enable_rx_enh                            false               enh_rx_crcchk_enable                                        NOVAL                     {"0:crcchk_bypass_en" "1:crcchk_bypass_dis"}}\
    {hssi_10g_tx_pcs_enc_64b66b_txsm_bypass                   !l_enable_tx_enh                            false               enh_tx_64b66b_enable                                        NOVAL                     {"0:enc_64b66b_txsm_bypass_en" "1:enc_64b66b_txsm_bypass_dis"}}\
    {hssi_10g_rx_pcs_dec_64b66b_rxsm_bypass                   !l_enable_rx_enh                            false               enh_rx_64b66b_enable                                        NOVAL                     {"0:dec_64b66b_rxsm_bypass_en" "1:dec_64b66b_rxsm_bypass_dis"}}\
    {hssi_10g_tx_pcs_scrm_bypass                              !l_enable_tx_enh                            false               enh_tx_scram_enable                                         NOVAL                     {"0:scrm_bypass_en" "1:scrm_bypass_dis"}}\
    {hssi_10g_rx_pcs_descrm_bypass                            !l_enable_rx_enh                            false               enh_rx_descram_enable                                       NOVAL                     {"0:descrm_bypass_en" "1:descrm_bypass_dis"}}\
    {hssi_10g_tx_pcs_pseudo_seed_a                            "!l_enable_tx_enh || !enh_tx_scram_enable"  false               enh_tx_scram_seed                                           NOVAL                     NOVAL} \
    {hssi_10g_tx_pcs_dispgen_bypass                           !l_enable_tx_enh                            false               enh_tx_dispgen_enable                                       NOVAL                     {"0:dispgen_bypass_en" "1:dispgen_bypass_dis"}}\
    {hssi_10g_rx_pcs_dispchk_bypass                           !l_enable_rx_enh                            false               enh_rx_dispchk_enable                                       NOVAL                     {"0:dispchk_bypass_en" "1:dispchk_bypass_dis"}}\
    {hssi_10g_rx_pcs_blksync_bypass                           !l_enable_rx_enh                            false               enh_rx_blksync_enable                                       NOVAL                     {"0:blksync_bypass_en" "1:blksync_bypass_dis"}}\
    {hssi_10g_tx_pcs_bitslip_en                               !l_enable_tx_enh                            false               enh_tx_bitslip_enable                                       NOVAL                     {"0:bitslip_dis" "1:bitslip_en"}}\
    {hssi_10g_rx_pcs_bitslip_mode                             !l_enable_rx_enh                            false               enh_rx_bitslip_enable                                       NOVAL                     {"0:bitslip_dis" "1:bitslip_en"}}\
    {hssi_10g_rx_pcs_fifo_stop_rd                             !l_enable_rx_enh                            false               enh_rxfifo_mode                                             "n_rd_empty"              {"Phase Compensation:rd_empty"}} \
    {hssi_8g_tx_pcs_pcs_bypass                                !l_enable_tx_std                            false               std_low_latency_bypass_enable                               NOVAL                     {"0:dis_pcs_bypass" "1:en_pcs_bypass"}} \
    {hssi_8g_rx_pcs_pcs_bypass                                !l_enable_rx_std                            false               std_low_latency_bypass_enable                               NOVAL                     {"0:dis_pcs_bypass" "1:en_pcs_bypass"}} \
    {hssi_8g_tx_pcs_byte_serializer                           !l_enable_tx_std                            false               std_tx_byte_ser_mode                                        NOVAL                     {"Disabled:dis_bs" "Serialize x2:en_bs_by_2" "Serialize x4:en_bs_by_4"}} \
    {hssi_8g_rx_pcs_byte_deserializer                         !l_enable_rx_std                            false               std_rx_byte_deser_mode                                      NOVAL                     {"Disabled:dis_bds" "Deserialize x2:en_bds_by_2" "Deserialize x4:en_bds_by_4"}} \
    {hssi_8g_tx_pcs_eightb_tenb_encoder                       !l_enable_tx_std                            false               std_tx_8b10b_enable                                         NOVAL                     {"0:dis_8b10b" "1:en_8b10b_ibm"}} \
    {hssi_8g_rx_pcs_eightb_tenb_decoder                       !l_enable_rx_std                            false               std_rx_8b10b_enable                                         NOVAL                     {"0:dis_8b10b" "1:en_8b10b_ibm"}} \
    {hssi_8g_tx_pcs_eightb_tenb_disp_ctrl                     !l_enable_tx_std                            false               std_tx_8b10b_disp_ctrl_enable                               NOVAL                     {"0:dis_disp_ctrl" "1:en_disp_ctrl"}} \
    {hssi_8g_rx_pcs_rate_match                                !l_enable_rx_std                            false               std_rx_rmfifo_mode                                          NOVAL                     {"disabled:dis_rm" "basic (single width):sw_basic_rm" "basic (double width):dw_basic_rm" "gige:gige_rm" "pipe:pipe_rm" "pipe 0ppm:pipe_rm_0ppm"}} \
    {hssi_8g_rx_pcs_clkcmp_pattern_p                          !l_enable_rx_std                            false               std_rx_rmfifo_pattern_p                                     NOVAL                     NOVAL} \
    {hssi_8g_rx_pcs_clkcmp_pattern_n                          !l_enable_rx_std                            false               std_rx_rmfifo_pattern_n                                     NOVAL                     NOVAL} \
    {hssi_8g_tx_pcs_tx_bitslip                                !l_enable_tx_std                            false               std_tx_bitslip_enable                                       NOVAL                     {"0:dis_tx_bitslip" "1:en_tx_bitslip"}} \
    {hssi_8g_rx_pcs_wa_boundary_lock_ctrl                     !l_enable_rx_std                            false               std_rx_word_aligner_mode                                    NOVAL                     {"bitslip:bit_slip" "manual (PLD controlled):auto_align_pld_ctrl" "synchronous state machine:sync_sm" "deterministic latency:deterministic_latency"}} \
    {hssi_8g_rx_pcs_wa_det_latency_sync_status_beh            !l_enable_rx_std                            false               protocol_mode                                               "dont_care_assert_sync"   {"cpri:assert_sync_status_non_imm"}} \
    {hssi_8g_rx_pcs_wa_pd_data                                !l_enable_rx_std                            false               std_rx_word_aligner_pattern                                 NOVAL                     NOVAL} \
    {hssi_8g_rx_pcs_wa_rknumber_data                          !l_enable_rx_std                            false               std_rx_word_aligner_rknumber                                NOVAL                     NOVAL} \
    {hssi_8g_rx_pcs_wa_renumber_data                          !l_enable_rx_std                            false               std_rx_word_aligner_renumber                                NOVAL                     NOVAL} \
    {hssi_8g_rx_pcs_wa_rgnumber_data                          !l_enable_rx_std                            false               std_rx_word_aligner_rgnumber                                NOVAL                     NOVAL} \
    {hssi_8g_rx_pcs_wa_rosnumber_data                         !l_enable_rx_std                            false               hssi_8g_rx_pcs_wa_sync_sm_ctrl                              1                         {"pipe_sync_sm:0"}} \
    {hssi_8g_rx_pcs_wa_disp_err_flag                          !l_enable_rx_std                            false               std_rx_8b10b_enable                                         NOVAL                     {"0:dis_disp_err_flag" "1:en_disp_err_flag"}} \
    {hssi_8g_tx_pcs_bit_reversal                              !l_enable_tx_std                            false               std_tx_bitrev_enable                                        NOVAL                     {"0:dis_bit_reversal" "1:en_bit_reversal"}} \
    {hssi_8g_tx_pcs_symbol_swap                               !l_enable_tx_std                            false               std_tx_byterev_enable                                       NOVAL                     {"0:dis_symbol_swap" "1:en_symbol_swap"}} \
    {hssi_8g_rx_pcs_bit_reversal                              !l_enable_rx_std                            false               std_rx_bitrev_enable                                        NOVAL                     {"0:dis_bit_reversal" "1:en_bit_reversal"}} \
    {hssi_8g_rx_pcs_symbol_swap                               !l_enable_rx_std                            false               std_rx_byterev_enable                                       NOVAL                     {"0:dis_symbol_swap" "1:en_symbol_swap"}} \
    {hssi_8g_rx_pcs_auto_error_replacement                    !l_enable_rx_std                            false               hssi_8g_rx_pcs_prot_mode                                    dis_err_replace           {"pipe_g1:en_err_replace" "pipe_g2:en_err_replace" "pipe_g3:en_err_replace"}} \
    {hssi_8g_rx_pcs_auto_error_replacement                    !l_enable_rx_std                            false               hssi_8g_rx_pcs_prot_mode                                    dis_err_replace           {"pipe_g1:en_err_replace" "pipe_g2:en_err_replace" "pipe_g3:en_err_replace"}} \
    {hssi_common_pcs_pma_interface_ppmsel                     false                                       false               rx_ppm_detect_threshold                                     NOVAL                     {"62.5:ppmsel_62p5" "100:ppmsel_100" "125:ppmsel_125" "200:ppmsel_200" "250:ppmsel_250" "300:ppmsel_300" "500:ppmsel_500" "1000:ppmsel_1000"}} \
    {hssi_gen3_rx_pcs_rate_match_fifo                         !l_enable_rx_std                            false               pcie_rate_match                                             NOVAL                     {"Bypass:bypass_rm_fifo" "0 ppm:enable_rm_fifo_0ppm" "600 ppm:enable_rm_fifo_600ppm"}} \
    {hssi_krfec_rx_pcs_error_marking_en                       !l_enable_rx_enh                            false               enh_rx_krfec_err_mark_enable                                NOVAL                     {"0:err_mark_dis" "1:err_mark_en"}} \
    {hssi_rx_pcs_pma_interface_rx_dyn_polarity_inversion      !l_enable_rx_std                            false               std_rx_polinv_enable                                        NOVAL                     {"0:rx_dyn_polinv_dis" "1:rx_dyn_polinv_en"}} \
    {hssi_rx_pcs_pma_interface_rx_static_polarity_inversion   !l_enable_rx_enh                            false               enh_rx_polinv_enable                                        NOVAL                     {"0:rx_stat_polinv_dis" "1:rx_stat_polinv_en"}} \
    {hssi_tx_pcs_pma_interface_tx_dyn_polarity_inversion      !l_enable_tx_std                            false               std_tx_polinv_enable                                        NOVAL                     {"0:tx_dyn_polinv_dis" "1:tx_dyn_polinv_en"}} \
    {hssi_tx_pcs_pma_interface_tx_static_polarity_inversion   !l_enable_tx_enh                            false               enh_tx_polinv_enable                                        NOVAL                     {"0:tx_stat_polinv_dis" "1:tx_stat_polinv_en"}} \
    {hssi_tx_pld_pcs_interface_hd_chnl_hip_en                 false                                       false               enable_hip                                                  NOVAL                     {"0:disable" "1:enable"}} \
    {hssi_tx_pld_pcs_interface_hd_chnl_hrdrstctl_en           false                                       false               enable_hard_reset                                           NOVAL                     {"0:disable" "1:enable"}} \
    {hssi_tx_pld_pcs_interface_hd_10g_low_latency_en_tx       NOVAL                                       false               NOVAL                                                       NOVAL                     NOVAL} \
    {hssi_rx_pld_pcs_interface_hd_10g_low_latency_en_rx       NOVAL                                       false               NOVAL                                                       NOVAL                     NOVAL} \
    {hssi_tx_pld_pcs_interface_hd_chnl_low_latency_en_tx      NOVAL                                       false               NOVAL                                                       NOVAL                     NOVAL} \
    {hssi_rx_pld_pcs_interface_hd_chnl_low_latency_en_rx      NOVAL                                       false               NOVAL                                                       NOVAL                     NOVAL} \
    {hssi_tx_pld_pcs_interface_hd_pmaif_pma_dw_tx             false                                       false               hssi_tx_pld_pcs_interface_hd_chnl_pma_dw_tx                 NOVAL                     NOVAL} \
    {hssi_rx_pld_pcs_interface_hd_pmaif_pma_dw_rx             false                                       false               hssi_rx_pld_pcs_interface_hd_chnl_pma_dw_rx                 NOVAL                     NOVAL} \
    {hssi_tx_pld_pcs_interface_hd_10g_pma_dw_tx               !l_enable_tx_enh                            false               enh_pcs_pma_width                                           NOVAL                     {"32:pma_32b_tx" "40:pma_40b_tx" "64:pma_64b_tx"}} \
    {hssi_rx_pld_pcs_interface_hd_10g_pma_dw_rx               !l_enable_rx_enh                            false               enh_pcs_pma_width                                           NOVAL                     {"32:pma_32b_rx" "40:pma_40b_rx" "64:pma_64b_rx"}} \
    {hssi_10g_tx_pcs_gb_tx_odwidth                            !l_enable_tx_enh                            false               enh_pcs_pma_width                                           NOVAL                     {"32:width_32" "40:width_40" "64:width_64"}} \
    {hssi_10g_rx_pcs_gb_rx_idwidth                            !l_enable_rx_enh                            false               enh_pcs_pma_width                                           NOVAL                     {"32:width_32" "40:width_40" "64:width_64"}} \
    {hssi_tx_pld_pcs_interface_hd_8g_pma_dw_tx                !l_enable_tx_std                            false               std_pcs_pma_width                                           NOVAL                     {"8:pma_8b_tx" "10:pma_10b_tx" "16:pma_16b_tx" "20:pma_20b_tx"}} \
    {hssi_rx_pld_pcs_interface_hd_8g_pma_dw_rx                !l_enable_rx_std                            false               std_pcs_pma_width                                           NOVAL                     {"8:pma_8b_rx" "10:pma_10b_rx" "16:pma_16b_rx" "20:pma_20b_rx"}} \
    {hssi_8g_tx_pcs_pma_dw                                    !l_enable_tx_std                            false               std_pcs_pma_width                                           NOVAL                     {"8:eight_bit" "10:ten_bit" "16:sixteen_bit" "20:twenty_bit"}} \
    {hssi_8g_rx_pcs_pma_dw                                    !l_enable_rx_std                            false               std_pcs_pma_width                                           NOVAL                     {"8:eight_bit" "10:ten_bit" "16:sixteen_bit" "20:twenty_bit"}} \
    {hssi_tx_pld_pcs_interface_hd_8g_fifo_mode_tx             !l_enable_tx_std                            false               std_tx_pcfifo_mode                                          NOVAL                     {"low_latency:fifo_tx" "register_fifo:reg_tx" "fast_register:fastreg_tx"}} \
    {hssi_rx_pld_pcs_interface_hd_8g_fifo_mode_rx             !l_enable_rx_std                            false               std_rx_pcfifo_mode                                          NOVAL                     {"low_latency:fifo_rx" "register_fifo:reg_rx"}} \
    {hssi_tx_pld_pcs_interface_hd_10g_fifo_mode_tx            !l_enable_tx_enh                            false               enh_txfifo_mode                                             NOVAL                     {"Phase compensation:fifo_tx" "Register:reg_tx" "Interlaken:fifo_tx" "Basic:fifo_tx"}} \
    {hssi_rx_pld_pcs_interface_hd_10g_fifo_mode_rx            !l_enable_rx_enh                            false               enh_rxfifo_mode                                             NOVAL                     {"Phase compensation:fifo_rx" "Register:reg_rx" "Interlaken:fifo_rx" "10GBase-R:fifo_rx" "Basic:fifo_rx"}} \
    {hssi_tx_pld_pcs_interface_hd_chnl_shared_fifo_width_tx   !l_enable_tx_enh                            false               enh_rxtxfifo_double_width                                   NOVAL                     {"0:single_tx" "1:single_tx"}} \
    {hssi_rx_pld_pcs_interface_hd_chnl_shared_fifo_width_rx   !l_enable_rx_enh                            false               enh_rxtxfifo_double_width                                   NOVAL                     {"0:single_rx" "1:double_rx"}} \
    {hssi_rx_pld_pcs_interface_hd_krfec_test_bus_mode         true                                        false               NOVAL                                                       NOVAL                     NOVAL} \
    {hssi_rx_pld_pcs_interface_hd_10g_test_bus_mode           true                                        false               NOVAL                                                       NOVAL                     NOVAL} \
    {pma_cdr_refclk_refclk_select                             false                                       false               cdr_refclk_select                                           NOVAL                     {"0:ref_iqclk0" "1:ref_iqclk1" "2:ref_iqclk2" "3:ref_iqclk3" "4:ref_iqclk4"}} \
    {pma_cgb_datarate                                         false                                       false               data_rate                                                   NOVAL                     NOVAL} \
    {pma_cgb_x1_div_m_sel                                     false                                       false               tx_pma_clk_div                                              NOVAL                     {"1:divbypass" "2:divby2" "4:divby4" "8:divby8"}} \
    {pma_cgb_input_select_xn                                  false                                       false               bonded_mode                                                 NOVAL                     {"not_bonded:unused" "pma_only:sel_x6_dn" "pma_pcs:sel_x6_dn"}} \
    {pma_cgb_ser_mode                                         false                                       false               l_pcs_pma_width                                             NOVAL                     {"8:eight_bit" "10:ten_bit" "16:sixteen_bit" "20:twenty_bit" "32:thirty_two_bit" "40:forty_bit" "64:sixty_four_bit"}} \
    {pma_rx_deser_deser_factor                                false                                       false               l_pcs_pma_width                                             NOVAL                     NOVAL} \
    {pma_rx_dfe_pdb                                           false                                       false               rx_pma_dfe_mode                                             dfe_enable                {"Disabled:dfe_powerdown"}} \
    {pma_rx_dfe_pdb_fixedtap                                  false                                       false               rx_pma_dfe_mode                                             fixtap_dfe_powerdown      {"Fixed tap:fixtap_dfe_enable"}} \
    {pma_rx_dfe_pdb_floattap                                  false                                       false               rx_pma_dfe_mode                                             floattap_dfe_powerdown    {"Floating tap:floattap_dfe_enable"}} \
    \
    {pma_cgb_bonding_mode                                     false                                       false               bonded_mode                                                 NOVAL                     {"not_bonded:x1_non_bonded" "pma_only:x6_mcgb_bonded" "pma_pcs:x6_mcgb_bonded"}} \
    {hssi_tx_pld_pcs_interface_hd_chnl_ctrl_plane_bonding_tx  false                                       false               bonded_mode                                                 NOVAL                     {"not_bonded:individual_tx" "pma_only:individual_tx" "pma_pcs:ctrl_master_tx"}}\
    {hssi_tx_pld_pcs_interface_hd_10g_ctrl_plane_bonding_tx   false                                       false               bonded_mode                                                 NOVAL                     {"not_bonded:individual_tx" "pma_only:individual_tx" "pma_pcs:ctrl_master_tx"}}\
    {hssi_tx_pld_pcs_interface_hd_pmaif_ctrl_plane_bonding    false                                       false               bonded_mode                                                 NOVAL                     {"not_bonded:individual" "pma_only:individual" "pma_pcs:ctrl_master"}}\
    {hssi_tx_pld_pcs_interface_hd_8g_ctrl_plane_bonding_tx    false                                       false               bonded_mode                                                 NOVAL                     {"not_bonded:individual_tx" "pma_only:individual_tx" "pma_pcs:ctrl_master_tx"}}\
    {hssi_rx_pld_pcs_interface_hd_chnl_channel_operation_mode false                                       false               duplex_mode                                                 NOVAL                     {"rx:tx_rx_independent" "tx:tx_rx_independent" "duplex:tx_rx_pair_enabled"}} \
    {hssi_tx_pld_pcs_interface_hd_chnl_channel_operation_mode false                                       false               duplex_mode                                                 NOVAL                     {"rx:tx_rx_independent" "tx:tx_rx_independent" "duplex:tx_rx_pair_enabled"}} \
    {hssi_tx_pld_pcs_interface_hd_chnl_prot_mode_tx           false                                       false               protocol_mode                                               NOVAL                     {"disabled:disabled_prot_mode_tx" "basic_std:basic_8gpcs_tx"            "basic_std_rm:basic_8gpcs_tx"           "cpri:cpri_8b10b_tx" "cpri_rx_tx:cpri_8b10b_tx" "gige:gige_tx" "gige_1588:gige_1588_tx" "pipe_g1:pcie_g1_capable_tx" "pipe_g2:pcie_g2_capable_tx" "pipe_g3:pcie_g3_capable_tx" "basic_enh:basic_10gpcs_tx" "interlaken_mode:interlaken_tx" "sfis_mode:sfis_tx" "teng_sdi_mode:teng_sdi_tx" "teng_baser_mode:teng_baser_tx" "teng_1588_mode:teng_1588_baser_tx" "teng_baser_krfec_mode:teng_basekr_krfec_tx" "basic_krfec_mode:basic_10gpcs_krfec_tx" "teng_1588_krfec_mode:teng_1588_basekr_krfec_tx" "fortyg_basekr_krfec_mode:fortyg_basekr_krfec_tx" "prp_krfec_mode:prp_krfec_tx" "prp_mode:prp_tx" "pcs_direct:pcs_direct_tx" "prbs:prbs_tx" "sqwave:sqwave_tx" "uhsif:uhsif_tx"}} \
    {hssi_rx_pld_pcs_interface_hd_chnl_prot_mode_rx           false                                       false               protocol_mode                                               NOVAL                     {"disabled:disabled_prot_mode_rx" "basic_std:basic_8gpcs_rm_disable_rx" "basic_std_rm:basic_8gpcs_rm_enable_rx" "cpri:cpri_8b10b_rx" "cpri_rx_tx:cpri_8b10b_rx" "gige:gige_rx" "gige_1588:gige_1588_rx" "pipe_g1:pcie_g1_capable_rx" "pipe_g2:pcie_g2_capable_rx" "pipe_g3:pcie_g3_capable_rx" "basic_enh:basic_10gpcs_rx" "interlaken_mode:interlaken_rx" "sfis_mode:sfis_rx" "teng_sdi_mode:teng_sdi_rx" "teng_baser_mode:teng_baser_rx" "teng_1588_mode:teng_1588_baser_rx" "teng_baser_krfec_mode:teng_basekr_krfec_rx" "basic_krfec_mode:basic_10gpcs_krfec_rx" "teng_1588_krfec_mode:teng_1588_basekr_krfec_rx" "fortyg_basekr_krfec_mode:fortyg_basekr_krfec_rx" "prp_krfec_mode:prp_krfec_rx" "prp_mode:prp_rx" "pcs_direct:pcs_direct_rx" "prbs:prbs_rx"}} \
    {hssi_tx_pld_pcs_interface_hd_8g_prot_mode_tx             false                                       false               protocol_mode                                               disabled_prot_mode_tx     {"disabled:disabled_prot_mode_tx" "basic_std:basic_tx"            "basic_std_rm:basic_tx"           "cpri:cpri_tx" "cpri_rx_tx:cpri_rx_tx_tx" "gige:gige_tx" "gige_1588:gige_1588_tx" "pipe_g1:pipe_g1_tx" "pipe_g2:pipe_g2_tx" "pipe_g3:pipe_g3_tx"}} \
    {hssi_rx_pld_pcs_interface_hd_8g_prot_mode_rx             false                                       false               protocol_mode                                               disabled_prot_mode_rx     {"disabled:disabled_prot_mode_rx" "basic_std:basic_rm_disable_rx" "basic_std_rm:basic_rm_enable_rx" "cpri:cpri_rx" "cpri_rx_tx:cpri_rx_tx_rx" "gige:gige_rx" "gige_1588:gige_1588_rx" "pipe_g1:pipe_g1_rx" "pipe_g2:pipe_g2_rx" "pipe_g3:pipe_g3_rx"}} \
    {hssi_8g_tx_pcs_prot_mode                                 false                                       false               protocol_mode                                               disabled_prot_mode        {"disabled:disabled_prot_mode" "basic_std:basic"            "basic_std_rm:basic"           "cpri:cpri" "cpri_rx_tx:cpri_rx_tx" "gige:gige" "gige_1588:gige_1588" "pipe_g1:pipe_g1" "pipe_g2:pipe_g2" "pipe_g3:pipe_g3"}} \
    {hssi_8g_rx_pcs_prot_mode                                 false                                       false               protocol_mode                                               disabled_prot_mode        {"disabled:disabled_prot_mode" "basic_std:basic_rm_disable" "basic_std_rm:basic_rm_enable" "cpri:cpri" "cpri_rx_tx:cpri_rx_tx" "gige:gige" "gige_1588:gige_1588" "pipe_g1:pipe_g1" "pipe_g2:pipe_g2" "pipe_g3:pipe_g3"}} \
    {hssi_tx_pld_pcs_interface_hd_chnl_sup_mode               false                                       false               support_mode                                                NOVAL                     NOVAL} \
    {hssi_rx_pld_pcs_interface_hd_chnl_sup_mode               false                                       false               support_mode                                                NOVAL                     NOVAL} \
  }


  set static_hdl_parameters {
    {NAME                                                     M_IS_STATIC_HDL_PARAMETER M_AUTOSET } \
    {pma_cdr_refclk_inclk0_logical_to_physical_mapping        true                      false     } \
    {pma_cdr_refclk_inclk1_logical_to_physical_mapping        true                      false     } \
    {pma_cdr_refclk_inclk2_logical_to_physical_mapping        true                      false     } \
    {pma_cdr_refclk_inclk3_logical_to_physical_mapping        true                      false     } \
    {pma_cdr_refclk_inclk4_logical_to_physical_mapping        true                      false     } \
    {pma_cgb_scratch0_x1_clock_src                            true                      false     } \
    {pma_cgb_scratch1_x1_clock_src                            true                      false     } \
    {pma_cgb_scratch2_x1_clock_src                            true                      false     } \
    {pma_cgb_scratch3_x1_clock_src                            true                      false     } \
    {hssi_tx_pld_pcs_interface_hd_10g_ctrl_plane_bonding_tx   true                      NOVAL     } \
    {hssi_rx_pld_pcs_interface_hd_10g_ctrl_plane_bonding_rx   true                      NOVAL     } \
    {hssi_tx_pld_pcs_interface_hd_8g_ctrl_plane_bonding_tx    true                      NOVAL     } \
    {hssi_rx_pld_pcs_interface_hd_8g_ctrl_plane_bonding_rx    true                      NOVAL     } \
    {hssi_tx_pld_pcs_interface_hd_pmaif_ctrl_plane_bonding    true                      NOVAL     } \
    {hssi_common_pcs_pma_interface_ctrl_plane_bonding         true                      NOVAL     } \
    {hssi_common_pcs_pma_interface_cp_cons_sel                true                      NOVAL     } \
    {hssi_common_pcs_pma_interface_cp_dwn_mstr                true                      NOVAL     } \
    {hssi_common_pcs_pma_interface_cp_up_mstr                 true                      NOVAL     } \
    {hssi_10g_tx_pcs_ctrl_plane_bonding                       true                      NOVAL     } \
    {hssi_10g_tx_pcs_comp_cnt                                 true                      false     } \
    {hssi_10g_tx_pcs_compin_sel                               true                      NOVAL     } \
    {hssi_10g_tx_pcs_distdwn_bypass_pipeln                    true                      NOVAL     } \
    {hssi_10g_tx_pcs_distdwn_master                           true                      NOVAL     } \
    {hssi_10g_tx_pcs_distup_bypass_pipeln                     true                      NOVAL     } \
    {hssi_10g_tx_pcs_distup_master                            true                      NOVAL     } \
    {hssi_8g_tx_pcs_ctrl_plane_bonding_consumption            true                      NOVAL     } \
    {hssi_8g_tx_pcs_ctrl_plane_bonding_compensation           true                      NOVAL     } \
    {hssi_8g_tx_pcs_ctrl_plane_bonding_distribution           true                      NOVAL     } \
    {hssi_8g_rx_pcs_ctrl_plane_bonding_consumption            true                      NOVAL     } \
    {hssi_8g_rx_pcs_ctrl_plane_bonding_compensation           true                      NOVAL     } \
    {hssi_8g_rx_pcs_ctrl_plane_bonding_distribution           true                      NOVAL     } \
  }


  set parameter_overrides {
    {NAME                                                     DEFAULT_VALUE               M_RCFG_RPT  M_AUTOSET VALIDATION_CALLBACK                                                                               } \
    {cdr_pll_cdr_cmu_mode                                     "cdr_mode"                  NOVAL       false     NOVAL                                                                                             } \
    {cdr_pll_fb_select                                        "direct_fb"                 NOVAL       false     NOVAL                                                                                             } \
    {cdr_pll_loopback_mode                                    "loopback_disabled"         NOVAL       false     NOVAL                                                                                             } \
    {cdr_pll_m_counter                                        1                           NOVAL       false     ::altera_xcvr_native_vi::parameters::validate_cdr_pll_m_counter                                   } \
    {cdr_pll_n_counter                                        1                           NOVAL       false     ::altera_xcvr_native_vi::parameters::validate_cdr_pll_n_counter                                   } \
    {cdr_pll_op_mode                                          "enabled"                   NOVAL       false     NOVAL                                                                                             } \
    {cdr_pll_output_clock_frequency                           ""                          NOVAL       false     ::altera_xcvr_native_vi::parameters::validate_cdr_pll_output_clock_frequency                      } \
    {cdr_pll_pcie_gen                                         NOVAL                       NOVAL       false     ::altera_xcvr_native_vi::parameters::validate_cdr_pll_pcie_gen                                    } \
    {cdr_pll_pd_l_counter                                     1                           NOVAL       false     ::altera_xcvr_native_vi::parameters::validate_cdr_pll_pd_l_counter                                } \
    {cdr_pll_pfd_l_counter                                    1                           NOVAL       false     ::altera_xcvr_native_vi::parameters::validate_cdr_pll_pfd_l_counter                               } \
    {cdr_pll_reference_clock_frequency                        ""                          NOVAL       false     ::altera_xcvr_native_vi::parameters::validate_cdr_pll_reference_clock_frequency                   } \
    {hssi_10g_tx_pcs_dv_bond                                  NOVAL                       NOVAL       false     ::altera_xcvr_native_vi::parameters::validate_hssi_10g_tx_pcs_dv_bond                             } \
    {hssi_10g_tx_pcs_gb_pipeln_bypass                         "disable"                   NOVAL       false     NOVAL                                                                                             } \
    {hssi_10g_tx_pcs_tx_testbus_sel                           "tx_fifo_testbus1"          NOVAL       false     NOVAL                                                                                             } \
    {hssi_10g_rx_pcs_clr_errblk_cnt_en                        "disable"                   NOVAL       false     NOVAL                                                                                             } \
    {hssi_10g_rx_pcs_rx_true_b2b                              "b2b"                       NOVAL       false     NOVAL                                                                                             } \
    {hssi_10g_rx_pcs_dis_signal_ok                            "dis_signal_ok_en"          NOVAL       false     NOVAL                                                                                             } \
    {hssi_10g_rx_pcs_rx_testbus_sel                           "rx_fifo_testbus1"          NOVAL       false     NOVAL                                                                                             } \
    {hssi_8g_rx_pcs_wa_pd                                     NOVAL                       NOVAL       false     ::altera_xcvr_native_vi::parameters::validate_hssi_8g_rx_pcs_wa_pd                                } \
    {hssi_8g_rx_pcs_err_flags_sel                             "err_flags_wa"              NOVAL       false     NOVAL                                                                                             } \
    {hssi_8g_rx_pcs_phase_comp_rdptr                          "disable_rdptr"             NOVAL       false     NOVAL                                                                                             } \
    {hssi_8g_tx_pcs_phase_comp_rdptr                          "disable_rdptr"             NOVAL       false     NOVAL                                                                                             } \
    {hssi_8g_rx_pcs_eidle_entry_eios                          "dis_eidle_eios"            NOVAL       false     NOVAL                                                                                             } \
    {hssi_8g_rx_pcs_eidle_entry_iei                           "dis_eidle_iei"             NOVAL       false     NOVAL                                                                                             } \
    {hssi_8g_rx_pcs_invalid_code_flag_only                    "dis_invalid_code_only"     NOVAL       false     NOVAL                                                                                             } \
    {hssi_common_pld_pcs_interface_pcs_testbus_block_sel      "pma_if"                    NOVAL       false     NOVAL                                                                                             } \
    {hssi_common_pcs_pma_interface_force_freqdet              "force_freqdet_dis"         NOVAL       false     NOVAL                                                                                             } \
    {hssi_common_pcs_pma_interface_ppm_post_eidle_delay       "cnt_200_cycles"            NOVAL       false     NOVAL                                                                                             } \
    {hssi_common_pcs_pma_interface_testout_sel                "ppm_det_test"              NOVAL       false     NOVAL                                                                                             } \
    {hssi_krfec_rx_pcs_rx_testbus_sel                         "overall"                   NOVAL       false     NOVAL                                                                                             } \
    {hssi_krfec_tx_pcs_burst_err                              "burst_err_dis"             NOVAL       false     NOVAL                                                                                             } \
    {hssi_krfec_tx_pcs_tx_testbus_sel                         "overall"                   NOVAL       false     NOVAL                                                                                             } \
    {hssi_pipe_gen1_2_ind_error_reporting                     "dis_ind_error_reporting"   NOVAL       false     NOVAL                                                                                             } \
    {hssi_pipe_gen1_2_phystatus_delay_val                     0                           NOVAL       false     NOVAL                                                                                             } \
    {hssi_pipe_gen1_2_rxdetect_bypass                         "dis_rxdetect_bypass"       NOVAL       false     NOVAL                                                                                             } \
    {hssi_pipe_gen1_2_txswing                                 "dis_txswing"               NOVAL       false     ::altera_xcvr_native_vi::parameters::validate_hssi_pipe_gen1_2_txswing                            } \
    {hssi_pipe_gen3_ind_error_reporting                       "dis_ind_error_reporting"   NOVAL       false     NOVAL                                                                                             } \
    {hssi_pipe_gen3_phystatus_rst_toggle_g12                  NOVAL                       NOVAL       true      ::altera_xcvr_native_vi::parameters::validate_hssi_pipe_gen3_phystatus_rst_toggle_g12             } \
    {hssi_pipe_gen3_rate_match_pad_insertion                  NOVAL                       NOVAL       true      ::altera_xcvr_native_vi::parameters::validate_hssi_pipe_gen3_rate_match_pad_insertion             } \
    {hssi_tx_pld_pcs_interface_pcs_tx_delay1_clk_sel          "pcs_tx_clk"                NOVAL       false     NOVAL                                                                                             } \
    {hssi_tx_pld_pcs_interface_pcs_tx_delay1_data_sel         "no_delay"                  NOVAL       false     NOVAL                                                                                             } \
    {hssi_tx_pld_pcs_interface_pcs_tx_delay2_ctrl             "delay2_path0"              NOVAL       false     NOVAL                                                                                             } \
    \
    {hssi_tx_pld_pcs_interface_hd_chnl_pma_dw_tx              NOVAL                       NOVAL       false     ::altera_xcvr_native_vi::parameters::validate_hssi_tx_pld_pcs_interface_hd_chnl_pma_dw_tx         } \
    {hssi_rx_pld_pcs_interface_hd_chnl_pma_dw_rx              NOVAL                       NOVAL       false     ::altera_xcvr_native_vi::parameters::validate_hssi_rx_pld_pcs_interface_hd_chnl_pma_dw_rx         } \
    {hssi_tx_pld_pcs_interface_hd_chnl_pld_fifo_mode_tx       NOVAL                       NOVAL       false     ::altera_xcvr_native_vi::parameters::validate_hssi_tx_pld_pcs_interface_hd_chnl_pld_fifo_mode_tx  } \
    {hssi_rx_pld_pcs_interface_hd_chnl_pld_fifo_mode_rx       NOVAL                       NOVAL       false     ::altera_xcvr_native_vi::parameters::validate_hssi_rx_pld_pcs_interface_hd_chnl_pld_fifo_mode_rx  } \
    \
    {pma_cdr_refclk_receiver_detect_src                       "iqclk_src"                 NOVAL       false     NOVAL                                                                                             } \
    {pma_cdr_refclk_xmux_refclk_src                           "refclk_iqclk"              NOVAL       false     NOVAL                                                                                             } \
    {pma_cdr_refclk_xpm_iqref_mux_iqclk_sel                   "power_down"                NOVAL       false     NOVAL                                                                                             } \
    {pma_cgb_bonding_reset_enable                             "disallow_bonding_reset"    NOVAL       false     NOVAL                                                                                             } \
    {pma_cgb_cgb_power_down                                   "normal_cgb"                NOVAL       false     NOVAL                                                                                             } \
    {pma_cgb_input_select_gen3                                "unused"                    NOVAL       false     ::altera_xcvr_native_vi::parameters::validate_pma_cgb_input_select_gen3                           } \
    {pma_cgb_input_select_x1                                  "fpll_bot"                  NOVAL       false     ::altera_xcvr_native_vi::parameters::validate_pma_cgb_input_select_x1                             } \
    {pma_cgb_op_mode                                          "enabled"                   NOVAL       false     NOVAL                                                                                             } \
    {pma_cgb_ser_powerdown                                    "normal_poweron_ser"        NOVAL       false     NOVAL                                                                                             } \
    {pma_rx_deser_clkdiv_source                               "clklow_to_clkdivrx"        NOVAL       false     NOVAL                                                                                             } \
    {pma_rx_deser_clkdivrx_user_mode                          NOVAL                       NOVAL       false     ::altera_xcvr_native_vi::parameters::validate_pma_rx_deser_clkdivrx_user_mode                     } \
    {pma_rx_deser_deser_powerdown                             "deser_power_up"            NOVAL       false     NOVAL                                                                                             } \
    {pma_rx_deser_op_mode                                     "enabled"                   NOVAL       false     NOVAL                                                                                             } \
    {pma_rx_deser_pcie_gen                                    NOVAL                       NOVAL       false     ::altera_xcvr_native_vi::parameters::validate_cdr_pll_pcie_gen                                    } \
    {pma_rx_deser_sdclk_enable                                "true"                      NOVAL       false     NOVAL                                                                                             } \
    {pma_rx_buf_cdrclk_to_cgb                                 "cdrclk_2cgb_dis"           0           false     NOVAL                                                                                             } \
    {pma_rx_buf_diag_lp_en                                    "dlp_off"                   NOVAL       false     NOVAL                                                                                             } \
    {pma_rx_buf_op_mode                                       "enabled"                   NOVAL       false     NOVAL                                                                                             } \
    {pma_rx_buf_pdb_rx                                        "normal_rx_on"              NOVAL       false     NOVAL                                                                                             } \
    {pma_rx_sd_sd_pdb                                         "sd_on"                     NOVAL       false     NOVAL                                                                                             } \
    {pma_rx_sd_sd_output_on                                   15                          NOVAL       false     ::altera_xcvr_native_vi::parameters::validate_pma_rx_sd_sd_output_on                              } \
    {pma_tx_buf_dft_sel                                       "dft_disabled"              NOVAL       false     NOVAL                                                                                             } \
    {pma_tx_buf_lst                                           "atb_disabled"              NOVAL       false     NOVAL                                                                                             } \
    {pma_tx_buf_rx_det                                        "mode_1"                    NOVAL       false     NOVAL                                                                                             } \
    {pma_tx_buf_rx_det_output_sel                             "rx_det_qpi_out"            NOVAL       false     ::altera_xcvr_native_vi::parameters::validate_pma_tx_buf_rx_det_output_sel                        } \
    {pma_tx_buf_rx_det_pdb                                    "rx_det_off"                NOVAL       false     ::altera_xcvr_native_vi::parameters::validate_pma_tx_buf_rx_det_pdb                               } \
    {pma_tx_buf_tx_powerdown                                  "normal_tx_on"              NOVAL       false     NOVAL                                                                                             } \
    {pma_tx_ser_ser_powerdown                                 "normal_poweron_ser"        NOVAL       false     NOVAL                                                                                             } \
    {pma_tx_ser_ser_clk_divtx_user_sel                        NOVAL                       NOVAL       false     ::altera_xcvr_native_vi::parameters::validate_pma_tx_ser_ser_clk_divtx_user_sel                   } \
    \
    {hssi_rx_pld_pcs_interface_hd_chnl_func_mode              "enable"                    NOVAL       false     NOVAL                                                                                             } \
    {hssi_tx_pld_pcs_interface_hd_chnl_func_mode              "enable"                    NOVAL       false     NOVAL                                                                                             } \
    {hssi_tx_pld_pcs_interface_hd_chnl_lpbk_en                "disable"                   NOVAL       false     NOVAL                                                                                             } \
    {hssi_rx_pld_pcs_interface_hd_chnl_lpbk_en                "disable"                   NOVAL       false     NOVAL                                                                                             } \
    {hssi_tx_pld_pcs_interface_hd_chnl_frequency_rules_en     "disable"                   NOVAL       false     NOVAL                                                                                             } \
    {hssi_tx_pld_pcs_interface_hd_chnl_speed_grade            "e2"                        NOVAL       false     NOVAL                                                                                             } \
    \
    {cdr_pll_prot_mode                                        "basic_rx"                  NOVAL       false     NOVAL                                                                                             } \
    {pma_cgb_prot_mode                                        NOVAL                       NOVAL       false     ::altera_xcvr_native_vi::parameters::validate_pma_cgb_prot_mode                                   } \
    \
    {hssi_gen3_rx_pcs_silicon_rev                             "es"                        NOVAL       false     NOVAL                                                                                             } \
    {hssi_gen3_tx_pcs_silicon_rev                             "es"                        NOVAL       false     NOVAL                                                                                             } \
    {hssi_krfec_rx_pcs_silicon_rev                            "es"                        NOVAL       false     NOVAL                                                                                             } \
    {hssi_krfec_tx_pcs_silicon_rev                            "es"                        NOVAL       false     NOVAL                                                                                             } \
    {hssi_10g_rx_pcs_silicon_rev                              "es"                        NOVAL       false     NOVAL                                                                                             } \
    {hssi_10g_tx_pcs_silicon_rev                              "es"                        NOVAL       false     NOVAL                                                                                             } \
    {hssi_8g_rx_pcs_silicon_rev                               "es"                        NOVAL       false     NOVAL                                                                                             } \
    {hssi_8g_tx_pcs_silicon_rev                               "es"                        NOVAL       false     NOVAL                                                                                             } \
    {hssi_tx_pld_pcs_interface_silicon_rev                    "es"                        NOVAL       false     NOVAL                                                                                             } \
    {hssi_rx_pld_pcs_interface_silicon_rev                    "es"                        NOVAL       false     NOVAL                                                                                             } \
    {hssi_common_pld_pcs_interface_silicon_rev                "es"                        NOVAL       false     NOVAL                                                                                             } \
    {hssi_rx_pcs_pma_interface_silicon_rev                    "es"                        NOVAL       false     NOVAL                                                                                             } \
    {hssi_tx_pcs_pma_interface_silicon_rev                    "es"                        NOVAL       false     NOVAL                                                                                             } \
    {hssi_common_pcs_pma_interface_silicon_rev                "es"                        NOVAL       false     NOVAL                                                                                             } \
    {hssi_fifo_rx_pcs_silicon_rev                             "es"                        NOVAL       false     NOVAL                                                                                             } \
    {hssi_fifo_tx_pcs_silicon_rev                             "es"                        NOVAL       false     NOVAL                                                                                             } \
    {hssi_pipe_gen3_silicon_rev                               "es"                        NOVAL       false     NOVAL                                                                                             } \
    {hssi_pipe_gen1_2_silicon_rev                             "es"                        NOVAL       false     NOVAL                                                                                             } \
    {cdr_pll_silicon_rev                                      "reva"                      NOVAL       false     NOVAL                                                                                             } \
    {pma_cdr_refclk_silicon_rev                               "reva"                      NOVAL       false     NOVAL                                                                                             } \
    {pma_cgb_silicon_rev                                      "reva"                      NOVAL       false     NOVAL                                                                                             } \
    {pma_rx_deser_silicon_rev                                 "reva"                      NOVAL       false     NOVAL                                                                                             } \
    {pma_rx_dfe_silicon_rev                                   "reva"                      NOVAL       false     NOVAL                                                                                             } \
    {pma_rx_odi_silicon_rev                                   "reva"                      NOVAL       false     NOVAL                                                                                             } \
    {pma_rx_buf_silicon_rev                                   "reva"                      NOVAL       false     NOVAL                                                                                             } \
    {pma_rx_sd_silicon_rev                                    "reva"                      NOVAL       false     NOVAL                                                                                             } \
    {pma_tx_ser_silicon_rev                                   "reva"                      NOVAL       false     NOVAL                                                                                             } \
    {pma_tx_buf_silicon_rev                                   "reva"                      NOVAL       false     NOVAL                                                                                             } \
  }


}


proc ::altera_xcvr_native_vi::parameters::get_variable { var } {
  variable display_items
  variable parameters
  variable rcfg_parameters
  variable parameter_mappings
  variable parameter_overrides
  variable static_hdl_parameters

  return [set $var]

}


# IP upgrade callback
proc ::altera_xcvr_native_vi::parameters::upgrade {ip_name version old_params} {
  
  set new_params [get_upgraded_parameters $ip_name $version $old_params]

  # Special handling for multi-profile reconfiguration
  for {set i 0} {$i < 8} {incr i} {
    if {[dict exists $new_params "rcfg_profile_data${i}"]} {
      #puts "rcfg_profile_data${i} : [dict get $new_params "rcfg_profile_data${i}"]"
      dict set new_params "rcfg_profile_data${i}" [get_upgraded_parameters $ip_name $version [dict get $new_params "rcfg_profile_data${i}"]]
    }
  }

  # Set parameter values
  set declared_params [get_parameters]
  foreach {param value} $new_params {
    if { [lsearch $declared_params $param] != -1 } {
      ip_set "parameter.${param}.value" $value
    }
  }
}


proc ::altera_xcvr_native_vi::parameters::get_upgraded_parameters {ip_name version old_params} {
  set new_params $old_params
  
  # Early versions of 13.1 had a different parameter set
  if { [lsearch $new_params "datapath_select"] != -1 } {
    # Need to map datapath_select, std_protocol_mode and enh_protocol_mode to protocol_mode
    set datapath_select [dict get $new_params datapath_select]
    set std_protocol_mode [dict get $new_params std_protocol_mode]
    set enh_protocol_mode [dict get $new_params enh_protocol_mode]
    # Get the protocol mode
    set protocol_mode [expr {$datapath_select == "Standard" ? $std_protocol_mode : $enh_protocol_mode}]
    # Accomodate name changes
    set protocol_mode [expr { $protocol_mode == "basic" ? "basic_std"
                              : $protocol_mode == "basic_rm" ? "basic_std_rm"
                                : $protocol_mode == "basic_mode" ? "basic_enh"
                                  : $protocol_mode }]
    puts "Upgraded datapath_select:${datapath_select},std_protocol_mode:${std_protocol_mode},enh_protocol_mode:${enh_protocol_mode} to protocol_mode:${protocol_mode}"
    # Remove old params
    set new_params [dict remove $new_params "datapath_select"]
    set new_params [dict remove $new_params "std_protocol_mode"]
    set new_params [dict remove $new_params "enh_protocol_mode"]
    # Set new param
    dict set new_params protocol_mode $protocol_mode
  }

  return $new_params
}


proc ::altera_xcvr_native_vi::parameters::declare_parameters { {device_family "Arria 10"} } {
  variable display_items
  variable parameters
  variable rcfg_parameters
  variable parameter_mappings
  variable parameter_overrides
  variable static_hdl_parameters

# ip_parse_csv "parameters.csv" "altera_xcvr_native_vi"
# set display_items [ip_get_csv_variable "altera_xcvr_native_vi" "display_items"]
# set parameters [ip_get_csv_variable "altera_xcvr_native_vi" "parameters"]
  ip_declare_parameters $parameters
  

  # Which parameters are included in reconfig reports is parameter dependent
  ip_add_user_property_type M_RCFG_REPORT integer
  # Tag abstract parameters for inclusion in reconfiguration report files
  ip_set "parameter.pll_select.M_RCFG_REPORT" tx_enable
  ip_set "parameter.cdr_refclk_select.M_RCFG_REPORT" rx_enable

  # Add Native PHY parameters
  ip_declare_parameters [::nf_xcvr_native::parameters::get_parameters]

  # Add M_AUTOSET attribute to all native phy parameters
  set nf_xcvr_native_parameters [ip_get_matching_parameters [dict set criteria M_IP_CORE nf_xcvr_native]]
  foreach param $nf_xcvr_native_parameters {
    ip_set "parameter.${param}.M_AUTOSET" 1
    ip_set "parameter.${param}.DISPLAY_ITEM" "Transceiver Attributes"
    ip_set "parameter.${param}.VISIBLE" 0
  }

  # Provide parameter mappings from IP parameters to native transceiver parameters
  ip_declare_parameters $parameter_mappings
  ip_declare_parameters $parameter_overrides
  ip_declare_parameters $static_hdl_parameters

  # Mark which parameters are HDL parameters and should be included in the dynamic reconfiguration report
  foreach param $nf_xcvr_native_parameters {
    if {[ip_get "parameter.${param}.M_IS_STATIC_HDL_PARAMETER"] == "false"} {
      ip_set "parameter.${param}.HDL_PARAMETER" 1
      # Selectively include parameters for inclusion in reconfiguration report files
      ip_set "parameter.${param}.M_RCFG_REPORT" 1
      if { [regexp {rx_buf|rx_deser|cdr_refclk|rx_dfe|rx_sd|rx_odi|cdr_|fifo_rx|rx_pcs_pma|common_pcs_pma|common_pld_pcs|rx_pld_pcs} $param] } {
        ip_set "parameter.${param}.M_RCFG_REPORT" rx_enable
      } elseif { [regexp {8g_rx|pipe_gen1_2|gen3_rx} $param] } {
        ip_set "parameter.${param}.M_RCFG_REPORT" l_enable_rx_std
      } elseif { [regexp {10g_rx|krfec_rx} $param] } {
        ip_set "parameter.${param}.M_RCFG_REPORT" l_enable_rx_enh
      } elseif { [regexp {tx_buf|tx_ser|tx_cgb|fifo_tx|tx_pcs_pma|tx_pld_pcs} $param] } {
        ip_set "parameter.${param}.M_RCFG_REPORT" tx_enable
      } elseif { [regexp {8g_tx|pipe_gen3|gen3_tx} $param] } {
        ip_set "parameter.${param}.M_RCFG_REPORT" l_enable_tx_std
      } elseif { [regexp {10g_tx|krfec_tx} $param] } {
        ip_set "parameter.${param}.M_RCFG_REPORT" l_enable_tx_enh
      }
    } else {
      # Disable validation callbacks for static HDL parameters
      ip_set "parameter.${param}.VALIDATION_CALLBACK" "NOVAL"
    }
  }
  
  # We have to add these last so that (they are order dependent - Blatant violation of IP_TCL principles)
  ip_declare_parameters $rcfg_parameters

  # Add display items
  ip_declare_display_items $display_items

  # Initialize some tables row headers:
  # set criteria [dict create M_USED_FOR_RCFG 1 DERIVED 0]
  # set params [ip_get_matching_parameters $criteria]
  # ip_set "parameter.rcfg_params.default_value" $params

  # Initialize device information (to allow sharing of this function across device families)
  ip_set "parameter.device_family.SYSTEM_INFO" DEVICE_FAMILY
  ip_set "parameter.device_family.DEFAULT_VALUE" $device_family
  ip_set "parameter.device_speedgrade.allowed_ranges" [::alt_xcvr::utils::device::get_device_speedgrades $device_family]

  # Initialize reconfiguration profile header
  set criteria [dict create M_USED_FOR_RCFG 1 DERIVED 0]
  set params [ip_get_matching_parameters $criteria]
  ip_set "parameter.rcfg_params.default_value" $params
  set labels {}
  foreach param $params {
    lappend labels [ip_get "parameter.${param}.display_name"]
  }
  ip_set "parameter.rcfg_param_labels.default_value" $labels

  # Grab Quartus INI's
  ip_set "parameter.enable_advanced_options.DEFAULT_VALUE" [get_quartus_ini altera_xcvr_native_a10_advanced ENABLED]
  ip_set "parameter.enable_debug_options.DEFAULT_VALUE" [get_quartus_ini altera_xcvr_native_a10_debug ENABLED]

  # Enable parameter mapping in the messaging package
  ::alt_xcvr::ip_tcl::messages::set_mapping_enabled 1
  ::alt_xcvr::ip_tcl::messages::set_message_filter_criteria {}
  ::alt_xcvr::ip_tcl::messages::set_deferred_messaging 1

  # TODO ... temporary code to disable validation callbacks for these parameters:
  set disable_callback_params { cdr_pll_atb_select_control cdr_pll_bbpd_data_pattern_filter_select cdr_pll_cdr_odi_select cdr_pll_chgpmp_current_pd cdr_pll_chgpmp_current_pfd cdr_pll_chgpmp_replicate cdr_pll_chgpmp_testmode cdr_pll_clklow_mux_select cdr_pll_diag_loopback_enable cdr_pll_disable_up_dn cdr_pll_fref_clklow_div cdr_pll_fref_mux_select cdr_pll_gpon_lck2ref_control cdr_pll_lck2ref_delay_control cdr_pll_lf_resistor_pd cdr_pll_lf_resistor_pfd cdr_pll_lf_ripple_cap cdr_pll_loop_filter_bias_select cdr_pll_ltd_ltr_micro_controller_select cdr_pll_pd_fastlock_mode cdr_pll_reverse_serial_loopback cdr_pll_set_cdr_v2i_enable cdr_pll_set_cdr_vco_reset cdr_pll_set_cdr_vco_speed cdr_pll_set_cdr_vco_speed_pciegen3 cdr_pll_txpll_hclk_driver_enable cdr_pll_vco_overrange_voltage cdr_pll_vco_underrange_voltage cdr_pll_iqclk_mux_sel pma_cgb_pcie_gen3_bitwidth pma_cgb_select_done_master_or_slave pma_cgb_tx_ucontrol_reset_pcie pma_rx_buf_bypass_eqz_stages_234 pma_rx_buf_qpi_enable pma_rx_sd_sd_output_off pma_rx_sd_sd_threshold pma_tx_buf_user_fir_coeff_ctrl_sel }
  foreach param $disable_callback_params {
    ip_set "parameter.${param}.VALIDATION_CALLBACK" NOVAL
  }
  # TODO - temporary
  #check_for_unset_parameters 

  # For some variables we will obtain the M_AUTOSET attribute from a variable
  ::alt_xcvr::ip_tcl::ip_module::ip_add_user_property_type M_AUTOSET boolean


  # Set mapping values for datapath select
  declare_validation_rule_select 
}


proc ::altera_xcvr_native_vi::parameters::check_for_unset_parameters {} {
  # Find all atom parameters that need setting
  dict set criteria VALIDATION_CALLBACK NOVAL
  dict set criteria M_IS_STATIC_HDL_PARAMETER false
  dict set criteria M_AUTOSET 1
  set params [ip_get_matching_parameters $criteria]
  foreach param $params {
    set allowed_ranges [ip_get "parameter.${param}.allowed_ranges"]
    if {[llength $allowed_ranges] > 1} {
      puts "${param} must be set! Options $allowed_ranges"
    }
  }
}
 
proc ::altera_xcvr_native_vi::parameters::declare_validation_rule_select {} {
  set ini [get_quartus_ini altera_xcvr_native_a10_debug ENABLED]
  if { $ini == "true" || $ini == 1 } {
    set params [ip_get_matching_parameters {M_IP_CORE nf_xcvr_native}]
    set validation_rule_list {}
    foreach param $params {
      if {[ip_get "parameter.${param}.VALIDATION_CALLBACK"] != "NOVAL"} {
        lappend validation_rule_list $param
      }
    }
    ip_set "parameter.validation_rule_select.allowed_ranges" $validation_rule_list
    ip_set "parameter.validation_rule_select.default_value" [lindex $validation_rule_list 0]
    set_parameter_update_callback validation_rule_select ::altera_xcvr_native_vi::parameters::validation_rule_select_callback 
  }
}
 

proc ::altera_xcvr_native_vi::parameters::validation_rule_select_callback { context } {
  set param [ip_get "parameter.validation_rule_select.value"]
  set callback [ip_get "parameter.${param}.VALIDATION_CALLBACK"]
  # Get the callback proc body
  set body [info body $callback]
  # Remove the non-rule stuff
  set index [string first "if \{ \$PROP_M_AUTOSET" $body]
  set body [string replace $body $index [string length $body]]
  set body [string trim $body]
  # Convert to HTML for multi-line
  set body "Rule for <b>${param}</b>:\n\n$body"
  set body [string map {"\n" "<br>"} $body]
  set body "<html>${body}</html>"
  ip_set "display_item.validation_rule_display.TEXT" $body
}


proc ::altera_xcvr_native_vi::parameters::validate {} {
  ip_message warning "This IP core is in beta stage. IP ports and parameters are subject to change."
  ip_validate_parameters
  ip_validate_display_items
  ::alt_xcvr::ip_tcl::messages::issue_deferred_messages
}


proc ::altera_xcvr_native_vi::parameters::dummy_callback {} {

}

#******************************************************************************
#************************ Validation Callbacks ********************************

proc ::altera_xcvr_native_vi::parameters::validate_message_level { message_level } {
  ::alt_xcvr::ip_tcl::messages::set_auto_message_level [ip_get "parameter.message_level.value"]
}

proc ::altera_xcvr_native_vi::parameters::validate_enable_simple_interface { PROP_NAME PROP_VALUE datapath_select rcfg_iface_enable enable_hip protocol_mode enh_pld_pcs_width enh_rxtxfifo_double_width } {
  set legal_values [expr {$rcfg_iface_enable ? {0}
    : $datapath_select == "PCS Direct" ? {0 1}
    : $datapath_select == "Standard" && !$enable_hip ? {0 1}
    : $datapath_select == "Enhanced" && !$enh_rxtxfifo_double_width && ( ($protocol_mode == "basic_mode" || $protocol_mode == "interlaken_mode" || $protocol_mode == "teng_baser_mode"|| $protocol_mode == "teng_1588_mode") || $enh_pld_pcs_width <= 64) ? {0 1}
    : { 0 } }]

  if {$PROP_VALUE} {
    ip_message info "Simplified data interface has been enabled. The IP core will present the data/control interface for the current configuration only. Dynamic reconfiguration of the data interface cannot be supported."
  }
  auto_invalid_value_message error $PROP_NAME $PROP_VALUE $legal_values { datapath_select rcfg_iface_enable enh_rxtxfifo_double_width}
}


proc ::altera_xcvr_native_vi::parameters::validate_support_mode { PROP_NAME PROP_VALUE message_level } {
  if {$PROP_VALUE == "engineering_mode"} {
    ip_message $message_level "Engineering support mode has been selected. Engineering mode is for internal use only. Altera does not officially support or guarantee IP configurations for this mode."
  }
}


proc ::altera_xcvr_native_vi::parameters::validate_set_data_rate { set_data_rate device_family device_speedgrade duplex_mode message_level } {

  if {![string is double $set_data_rate]} {
    ip_message error "[ip_get "parameter.set_data_rate.display_name"] \"$set_data_rate\" is improperly formatted. Should be ###.##."
    return
  }

}


proc ::altera_xcvr_native_vi::parameters::validate_bonded_mode { bonded_mode tx_enable channels} {
  set legal_values [expr { !$tx_enable ? $bonded_mode
    : $channels < 2 ? "not_bonded"
      : {"not_bonded" "pma_only" "pma_pcs"} }]

  auto_invalid_value_message auto bonded_mode $bonded_mode $legal_values { channels }
}


proc ::altera_xcvr_native_vi::parameters::validate_set_pcs_bonding_master { set_pcs_bonding_master tx_enable channels bonded_mode } {
  set range {"Auto"}
  for {set x 0} {$x < $channels} {incr x} {
    lappend range $x
  }

  set enabled [expr { $tx_enable && ($bonded_mode == "pma_pcs") }]

  set legal_values [expr { !$enabled ? $set_pcs_bonding_master
    : $range }]

  auto_invalid_value_message error set_pcs_bonding_master $set_pcs_bonding_master $legal_values { channels bonded_mode }

  if { [lsearch $range $set_pcs_bonding_master] == -1 } {
    lappend range $set_pcs_bonding_master
  }

  ip_set "parameter.set_pcs_bonding_master.allowed_ranges" $range
  ip_set "parameter.set_pcs_bonding_master.enabled" $enabled
}


proc ::altera_xcvr_native_vi::parameters::validate_pcs_bonding_master { tx_enable channels bonded_mode set_pcs_bonding_master enable_hip } {
  set value [expr { !$tx_enable || ($bonded_mode != "pma_pcs") ? 0
    : $set_pcs_bonding_master == "Auto" ?  ($enable_hip && ($channels < 4)) ? 0
        : ($enable_hip) ? 3
      : ($channels / 2)
    : $set_pcs_bonding_master }]

  ip_set "parameter.pcs_bonding_master.value" $value
}


proc ::altera_xcvr_native_vi::parameters::validate_data_rate { set_data_rate } {
  ip_set "parameter.data_rate.value" "${set_data_rate} Mbps"
}


proc ::altera_xcvr_native_vi::parameters::validate_display_base_data_rate { set_data_rate tx_pma_clk_div tx_enable } {
  set pll_clk_frequency [expr {double($set_data_rate * $tx_pma_clk_div) / 2}]

  set message "<html><font color=\"blue\">Note - </font>The external TX PLL IP must be configured with an output clock frequency of <b>${pll_clk_frequency} MHz.</b></html>"
  ip_set "display_item.display_base_data_rate.text" $message
  if {$tx_enable} {
    ip_message info $message
  }
}

###
# Validation for the pll_select parameter
#
# @param plls - Resolved value of the plls parameter
proc ::altera_xcvr_native_vi::parameters::validate_pll_select { tx_enable plls pll_select } {
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



###
# Validation for the cdr_refclk_select parameter
#
# @param cdr_refclk_cnt - Resolved value of the cdr_refclk_cnt parameter
proc ::altera_xcvr_native_vi::parameters::validate_cdr_refclk_select { cdr_refclk_cnt } {
  set allowed_ranges {}
  for {set i 0} {$i < $cdr_refclk_cnt} {incr i} {
    lappend allowed_ranges $i
  }

  ip_set "parameter.cdr_refclk_select.allowed_ranges" $allowed_ranges
}


proc ::altera_xcvr_native_vi::parameters::validate_l_pll_settings { rx_enable set_data_rate l_enable_std_pipe } {

  if {$rx_enable && [string is double $set_data_rate]} {
    set l_pll_settings [dict create]

    set allowed_ranges {}
    set pcie_mode [expr {$l_enable_std_pipe ? "pcie_mode" : "non_pcie"}]
    set values [::altera_xcvr_cdr_pll_vi::parameters::compute_pll_settings [expr double($set_data_rate) / 2] "CDR" $pcie_mode]

    dict for {key value} $values {
      set refclk [dict get $value "refclk"]
                
      if {[lsearch $allowed_ranges $refclk] == -1} {
        lappend allowed_ranges $refclk
        dict set l_pll_settings $refclk [dict get $value]
      }
    }

    set allowed_ranges [lsort -real -unique $allowed_ranges] 
    dict set l_pll_settings "allowed_ranges" $allowed_ranges

    ip_set "parameter.l_pll_settings.value" $l_pll_settings
  } else {
    ip_set "parameter.l_pll_settings.value" "NOVAL"
  }
}


proc ::altera_xcvr_native_vi::parameters::validate_l_pll_settings_key { set_cdr_refclk_freq l_pll_settings } {
  set l_pll_settings_key "NOVAL"

  if {$l_pll_settings != "NOVAL"} {
    set allowed_ranges [dict get $l_pll_settings "allowed_ranges"]
    set idx [lsearch -real -sorted $allowed_ranges $set_cdr_refclk_freq]
    if {$idx != -1} {
      set l_pll_settings_key [lindex $allowed_ranges $idx]
    }
  }

  ip_set "parameter.l_pll_settings_key.value" $l_pll_settings_key
}


proc ::altera_xcvr_native_vi::parameters::validate_l_enable_pma_bonding { tx_enable bonded_mode } {
  set value [expr { !$tx_enable || ($bonded_mode == "not_bonded") ? 0
    : 1 }]

  ip_set "parameter.l_enable_pma_bonding.value" $value
}


###
# Validation for the set_cdr_refclk_freq parameter
#
# @param device_family - Resolved value of the device_family parameter
# @param data_rate - Resolved value of the data_rate parameter
proc ::altera_xcvr_native_vi::parameters::validate_set_cdr_refclk_freq { set_cdr_refclk_freq l_pll_settings device_family device_speedgrade } {
  set allowed_ranges {}
 
  if {$l_pll_settings != "NOVAL"} {
 
    set allowed_ranges [dict get $l_pll_settings "allowed_ranges"]
 
    # Issue message if current selected value is illegal
    set idx [lsearch -real -sorted $allowed_ranges $set_cdr_refclk_freq]
    if {$idx == -1} {
      ip_message error "The selected CDR reference clock frequency \"$set_cdr_refclk_freq\" is invalid. Please select a valid CDR reference clock frequency or choose a different data rate."
      lappend allowed_ranges $set_cdr_refclk_freq
    } elseif { [string compare [lindex $allowed_ranges $idx] $set_cdr_refclk_freq] != 0 } {
      lappend allowed_ranges $set_cdr_refclk_freq
    }
  } else {
      lappend allowed_ranges $set_cdr_refclk_freq
  }
 
  ip_set "parameter.set_cdr_refclk_freq.allowed_ranges" $allowed_ranges
}


proc ::altera_xcvr_native_vi::parameters::validate_tx_enable { duplex_mode } {
  set tx_enable 0
  if {$duplex_mode != "rx"} {
    set tx_enable 1
  }

  ip_set "parameter.tx_enable.value" $tx_enable
}


#############################################################################
#################### Local block enable parameters ##########################
proc ::altera_xcvr_native_vi::parameters::validate_l_pcs_pma_width { datapath_select std_pcs_pma_width enh_pcs_pma_width pcs_direct_width} {
  set value [ expr { $datapath_select == "Standard" ? $std_pcs_pma_width
    : $datapath_select == "Enhanced" ? $enh_pcs_pma_width
    : $pcs_direct_width } ]

  ip_set "parameter.l_pcs_pma_width.value" $value
}


proc ::altera_xcvr_native_vi::parameters::validate_rx_enable { duplex_mode } {
  set rx_enable 0
  if {$duplex_mode != "tx"} {
    set rx_enable 1
  }

  ip_set "parameter.rx_enable.value" $rx_enable
}

###
# Validation for l_enable_tx_std parameter. Used to determine
# when Standard TX datapath is enabled.
#
# @param tx_enable - Resolved value of the tx_enable parameter
# @param enable_std - Resolved value of the enable_std parameter
proc ::altera_xcvr_native_vi::parameters::validate_l_enable_tx_std { tx_enable enable_std } {
  ip_set "parameter.l_enable_tx_std.value" [expr $tx_enable && $enable_std]
}


###
# Validation for l_enable_rx_std parameter. Used to determine
# when Standard RX datapath is enabled.
#
# @param rx_enable - Resolved value of the rx_enable parameter
# @param enable_std - Resolved value of the enable_std parameter
proc ::altera_xcvr_native_vi::parameters::validate_l_enable_rx_std { rx_enable enable_std } {
  ip_set "parameter.l_enable_rx_std.value" [expr $rx_enable && $enable_std]
}


proc ::altera_xcvr_native_vi::parameters::validate_l_enable_tx_std_iface { PROP_NAME tx_enable l_enable_tx_std rcfg_iface_enable } {
# ip_set "parameter.${PROP_NAME}.value" [expr $l_enable_tx_std || ($rcfg_iface_enable && $tx_enable)]
  ip_set "parameter.${PROP_NAME}.value" $l_enable_tx_std
}


proc ::altera_xcvr_native_vi::parameters::validate_l_enable_rx_std_iface { PROP_NAME rx_enable l_enable_rx_std rcfg_iface_enable } {
# ip_set "parameter.${PROP_NAME}.value" [expr $l_enable_rx_std || ($rcfg_iface_enable && $rx_enable)]
  ip_set "parameter.${PROP_NAME}.value" $l_enable_rx_std
}


###
# Validation for l_enable_tx_enh parameter. Used to determine
# when 10G TX PCS is enabled.
#
# @param tx_enable - Resolved value of the tx_enable parameter
# @param enable_enh  - Resolved value of the enable_enh  parameter
proc ::altera_xcvr_native_vi::parameters::validate_l_enable_tx_enh { tx_enable enable_enh  } {
  ip_set "parameter.l_enable_tx_enh.value" [expr $tx_enable && $enable_enh ]
}


proc ::altera_xcvr_native_vi::parameters::validate_l_enable_tx_enh_iface { PROP_NAME tx_enable l_enable_tx_enh rcfg_iface_enable } {
# ip_set "parameter.${PROP_NAME}.value" [expr $l_enable_tx_enh || ($rcfg_iface_enable && $tx_enable)]
  ip_set "parameter.${PROP_NAME}.value" $l_enable_tx_enh
}


proc ::altera_xcvr_native_vi::parameters::validate_l_enable_rx_enh_iface { PROP_NAME rx_enable l_enable_rx_enh rcfg_iface_enable } {
# ip_set "parameter.${PROP_NAME}.value" [expr $l_enable_rx_enh || ($rcfg_iface_enable && $rx_enable)]
  ip_set "parameter.${PROP_NAME}.value" $l_enable_rx_enh
}


###
# Validation for l_enable_rx_enh parameter. Used to determine
# when 10G RX PCS is enabled.
#
# @param rx_enable - Resolved value of the rx_enable parameter
# @param enable_enh  - Resolved value of the enable_enh  parameter
proc ::altera_xcvr_native_vi::parameters::validate_l_enable_rx_enh { rx_enable enable_enh  } {
  ip_set "parameter.l_enable_rx_enh.value" [expr $rx_enable && $enable_enh ]
}


proc ::altera_xcvr_native_vi::parameters::validate_l_enable_tx_pcs_dir { tx_enable enable_pcs_dir } {
  ip_set "parameter.l_enable_tx_pcs_dir.value" [expr $tx_enable && $enable_pcs_dir ]
}


proc ::altera_xcvr_native_vi::parameters::validate_l_enable_rx_pcs_dir { rx_enable enable_pcs_dir } {
  ip_set "parameter.l_enable_rx_pcs_dir.value" [expr $rx_enable && $enable_pcs_dir ]
}


################## End local block enable parameters ########################
#############################################################################


proc ::altera_xcvr_native_vi::parameters::validate_l_rcfg_ifaces { rcfg_shared channels } {
  ip_set "parameter.l_rcfg_ifaces.value" [expr { $rcfg_shared ? 1 : $channels }]
}


proc ::altera_xcvr_native_vi::parameters::validate_l_rcfg_addr_bits { rcfg_shared channels } {
  set channels [expr {$channels-1}]
  set mux_bits [::alt_xcvr::utils::common::clogb2 $channels]
  ip_set "parameter.l_rcfg_addr_bits.value" [expr { $rcfg_shared ? 10+$mux_bits : 10 }]
}


proc ::altera_xcvr_native_vi::parameters::validate_enable_std { datapath_select rcfg_iface_enable } {
  set value [expr {$datapath_select == "Standard" || $rcfg_iface_enable }]

  ip_set "parameter.enable_std.value" $value
}


proc ::altera_xcvr_native_vi::parameters::validate_enable_enh  { datapath_select rcfg_iface_enable } {
  set enable_enh [expr {$datapath_select == "Enhanced" || $rcfg_iface_enable }]

  ip_set "parameter.enable_enh.value" $enable_enh
}


proc ::altera_xcvr_native_vi::parameters::validate_enable_pcs_dir  { datapath_select rcfg_iface_enable } {
  set enable_pcs_dir [expr {$datapath_select == "PCS Direct" || $rcfg_iface_enable }]

  ip_set "parameter.enable_pcs_dir.value" $enable_pcs_dir
}

#******************************************************************************
#******************* Standard PCS validation callbacks ************************
#

proc ::altera_xcvr_native_vi::parameters::validate_l_enable_std_pipe { protocol_mode } {
  set value [expr {$protocol_mode == "pipe_g1" || $protocol_mode == "pipe_g2" || $protocol_mode == "pipe_g3" }]

  ip_set "parameter.l_enable_std_pipe.value" $value
}


proc ::altera_xcvr_native_vi::parameters::validate_std_tx_pld_pcs_width { std_pcs_pma_width std_tx_byte_ser_mode std_tx_8b10b_enable } {
  set legal_value [expr { $std_tx_byte_ser_mode == "Serialize x2" ? [expr $std_pcs_pma_width * 2]
    : $std_tx_byte_ser_mode == "Serialize x4" && $std_pcs_pma_width <= 10 ? $std_pcs_pma_width * 4
    : $std_pcs_pma_width }]

  set legal_value [expr { $std_tx_8b10b_enable ? [expr {$legal_value * 4} / 5]
    : $legal_value }]

  ip_set "parameter.std_tx_pld_pcs_width.value" $legal_value
}


proc ::altera_xcvr_native_vi::parameters::validate_std_rx_pld_pcs_width { std_pcs_pma_width std_rx_byte_deser_mode std_rx_8b10b_enable } {
  set legal_value [expr { $std_rx_byte_deser_mode == "Deserialize x2" ? [expr $std_pcs_pma_width * 2]
    : $std_rx_byte_deser_mode == "Deserialize x4" && $std_pcs_pma_width <= 10 ? [expr $std_pcs_pma_width * 4]
    : $std_pcs_pma_width }]
  set legal_value [expr { $std_rx_8b10b_enable ? [expr {$legal_value * 4} / 5]
    : $legal_value }]

  ip_set "parameter.std_rx_pld_pcs_width.value" $legal_value
}


proc ::altera_xcvr_native_vi::parameters::validate_enable_port_rx_std_bitrev_ena { PROP_NAME PROP_VALUE std_rx_bitrev_enable } {
  set legal_values [expr { $std_rx_bitrev_enable ? {1}
    : {0 1} }]

  auto_invalid_value_message auto $PROP_NAME $PROP_VALUE $legal_values {std_rx_bitrev_enable}
}


proc ::altera_xcvr_native_vi::parameters::validate_enable_port_rx_std_byterev_ena { PROP_NAME PROP_VALUE std_rx_byterev_enable } {
  set legal_values [expr { $std_rx_byterev_enable ? {1}
    : {0 1} }]

  auto_invalid_value_message auto $PROP_NAME $PROP_VALUE $legal_values {std_rx_byterev_enable}
}


proc ::altera_xcvr_native_vi::parameters::validate_enable_port_tx_polinv { PROP_NAME PROP_VALUE l_enable_tx_std_iface std_tx_polinv_enable } {
  set legal_values [expr {$std_tx_polinv_enable && $l_enable_tx_std_iface ? 1
      : {0 1} }]

  auto_invalid_value_message auto $PROP_NAME $PROP_VALUE $legal_values {std_tx_polinv_enable}
}


proc ::altera_xcvr_native_vi::parameters::validate_enable_port_rx_polinv { PROP_NAME PROP_VALUE l_enable_rx_std_iface std_rx_polinv_enable } {
  set legal_values [expr {$std_rx_polinv_enable && $l_enable_rx_std_iface ? 1
      : {0 1} }]

  auto_invalid_value_message auto $PROP_NAME $PROP_VALUE $legal_values {std_rx_polinv_enable}
}


proc ::altera_xcvr_native_vi::parameters::validate_enable_ports_pipe_sw { PROP_NAME PROP_VALUE protocol_mode } {
  set legal_values [expr {$protocol_mode == "pipe_g2" || $protocol_mode == "pipe_g3" ? 1
    : {0 1} }]

  auto_invalid_value_message auto $PROP_NAME $PROP_VALUE $legal_values {protocol_mode}
}


proc ::altera_xcvr_native_vi::parameters::validate_enable_ports_pipe_hclk { PROP_NAME PROP_VALUE l_enable_std_pipe protocol_mode } {
  set legal_values [expr {$l_enable_std_pipe ? 1
    : {0 1} }]

  auto_invalid_value_message auto $PROP_NAME $PROP_VALUE $legal_values {protocol_mode}
}


proc ::altera_xcvr_native_vi::parameters::validate_enable_ports_pipe_g3_analog { PROP_NAME PROP_VALUE protocol_mode } {
  set legal_values [expr {$protocol_mode == "pipe_g3" ? 1
    : {0 1} }]

  auto_invalid_value_message auto $PROP_NAME $PROP_VALUE $legal_values {protocol_mode}
}


proc ::altera_xcvr_native_vi::parameters::validate_enable_ports_pipe_rx_elecidle { PROP_NAME PROP_VALUE l_enable_std_pipe enable_hip protocol_mode } {
  set legal_values [expr {$l_enable_std_pipe && !$enable_hip ? 1
    : {0 1} }]

  auto_invalid_value_message auto $PROP_NAME $PROP_VALUE $legal_values {protocol_mode}
}


proc ::altera_xcvr_native_vi::parameters::validate_enable_port_pipe_rx_polarity { PROP_NAME PROP_VALUE l_enable_std_pipe protocol_mode } {
  set legal_values [expr {$l_enable_std_pipe ? 1
    : {0 1} }]

  auto_invalid_value_message auto $PROP_NAME $PROP_VALUE $legal_values {protocol_mode}
}


proc ::altera_xcvr_native_vi::parameters::validate_l_std_tx_word_count { std_pcs_pma_width std_tx_byte_ser_mode } {
  set value [expr {$std_pcs_pma_width > 10 && $std_tx_byte_ser_mode == "Disabled" ? 2
    : $std_pcs_pma_width > 10 && $std_tx_byte_ser_mode == "Serialize x2" ? 4
    : $std_tx_byte_ser_mode == "Serialize x2" ? 2
    : $std_tx_byte_ser_mode == "Serialize x4" ? 4
    : 1 }]

  ip_set "parameter.l_std_tx_word_count.value" $value
}


proc ::altera_xcvr_native_vi::parameters::validate_l_std_tx_word_width { std_tx_pld_pcs_width l_std_tx_word_count } {
  ip_set "parameter.l_std_tx_word_width.value" [expr $std_tx_pld_pcs_width / $l_std_tx_word_count]
}


proc ::altera_xcvr_native_vi::parameters::validate_l_std_tx_field_width { std_pcs_pma_width std_tx_byte_ser_mode } {
  set value [expr {$std_pcs_pma_width <= 10 && $std_tx_byte_ser_mode == "Serialize x2" ? 22
        : 11 }]

  ip_set "parameter.l_std_tx_field_width.value" $value
}


proc ::altera_xcvr_native_vi::parameters::validate_l_std_rx_word_count { std_pcs_pma_width std_rx_byte_deser_mode } {
  set value [expr {$std_pcs_pma_width > 10 && $std_rx_byte_deser_mode == "Disabled" ? 2
    : $std_pcs_pma_width > 10 && $std_rx_byte_deser_mode == "Deserialize x2" ? 4
    : $std_rx_byte_deser_mode == "Deserialize x2" ? 2
    : $std_rx_byte_deser_mode == "Deserialize x4" ? 4
    : 1 }]

  ip_set "parameter.l_std_rx_word_count.value" $value
}


proc ::altera_xcvr_native_vi::parameters::validate_l_std_rx_word_width { std_rx_pld_pcs_width l_std_rx_word_count } {
  ip_set "parameter.l_std_rx_word_width.value" [expr $std_rx_pld_pcs_width / $l_std_rx_word_count]
}


proc ::altera_xcvr_native_vi::parameters::validate_l_std_rx_field_width { std_pcs_pma_width std_rx_byte_deser_mode } {
  set value [expr {$std_pcs_pma_width <= 10 && $std_rx_byte_deser_mode == "Deserialize x2" ? 32
        : 16 }]

  ip_set "parameter.l_std_rx_field_width.value" $value
}


#******************* Standard PCS validation callbacks ************************
#******************************************************************************

#******************************************************************************
#***************** Enhanced PCS validation callbacks *********************

proc ::altera_xcvr_native_vi::parameters::validate_protocol_mode { support_mode } {
  set std_ranges {"basic_std:Basic/Custom (Standard PCS)" \
                  "basic_std_rm:Basic/Custom w/Rate Match (Standard PCS)" \
                  "cpri:CPRI (Auto)" \
                  "cpri_rx_tx:CPRI (Manual)" \
                  "gige:GbE" \
                  "gige_1588:GbE 1588" \
                  "pipe_g1:Gen 1 PIPE" \
                  "pipe_g2:Gen 2 PIPE" \
                  "pipe_g3:Gen 3 PIPE" }

  set enh_ranges {"basic_enh:Basic (Enhanced PCS)" \
                  "interlaken_mode:Interlaken" \
                  "sfis_mode:SFIS" \
                  "teng_sdi_mode:10G SDI" \
                  "teng_baser_mode:10GBASE-R" \
                  "teng_1588_mode:10GBASE-R 1588" \
                  "teng_baser_krfec_mode:10GBASE-R w/KR FEC" \
                  "basic_krfec_mode:Basic w/KR FEC" }
                  

  set allowed_ranges [concat $std_ranges $enh_ranges]
  if {$support_mode == "engineering_mode"} {
    set allowed_ranges [concat $allowed_ranges {"teng_1588_krfec_mode:10GBASE-R 1588 w/KR FEC"}]
  }
 
  ip_set "parameter.protocol_mode.allowed_ranges" $allowed_ranges
}


proc ::altera_xcvr_native_vi::parameters::validate_enh_rxfifo_mode { PROP_NAME support_mode } {
  set allowed_ranges {"Phase compensation" "Register" "Interlaken" "10GBase-R" "Basic"}
  if {$support_mode == "engineering_mode"} {
    set allowed_ranges [concat $allowed_ranges {"Phase compensation (data_valid)"}]
  }
  
  ip_set "parameter.${PROP_NAME}.allowed_ranges" $allowed_ranges
}


proc ::altera_xcvr_native_vi::parameters::validate_enable_port_tx_enh_frame { PROP_NAME PROP_VALUE enh_tx_frmgen_enable } {
  set legal_values [expr { $enh_tx_frmgen_enable ? {1}
    : {0 1} }]

  auto_invalid_value_message auto $PROP_NAME $PROP_VALUE $legal_values {enh_tx_frmgen_enable}
}


proc ::altera_xcvr_native_vi::parameters::validate_enable_port_tx_enh_frame_burst_en { PROP_NAME PROP_VALUE enh_tx_frmgen_burst_enable } {
  set legal_values [expr { $enh_tx_frmgen_burst_enable ? {1}
    : {0 1} }]

  auto_invalid_value_message auto $PROP_NAME $PROP_VALUE $legal_values {enh_tx_frmgen_burst_enable}
}


proc ::altera_xcvr_native_vi::parameters::validate_enable_port_tx_enh_bitslip { PROP_NAME PROP_VALUE l_enable_tx_enh enh_tx_bitslip_enable } {
  set legal_values [expr { !$l_enable_tx_enh ? [list $PROP_VALUE]
    : $enh_tx_bitslip_enable == "1" ? {1}
      : {0 1} }]

  auto_invalid_value_message warning $PROP_NAME $PROP_VALUE $legal_values {enh_tx_bitslip_enable}
}


proc ::altera_xcvr_native_vi::parameters::validate_enable_port_rx_enh_bitslip { enable_port_rx_enh_bitslip l_enable_rx_enh enh_rx_bitslip_enable } {
  set legal_values [expr { !$l_enable_rx_enh ? [list $enable_port_rx_enh_bitslip]
    : $enh_rx_bitslip_enable == "1" ? {1}
      : {0 1} }]

  auto_invalid_value_message warning enable_port_rx_enh_bitslip $enable_port_rx_enh_bitslip $legal_values {enh_rx_bitslip_enable}
}


#***************** End Enhanced PCS validation callbacks *****************
#******************************************************************************


#******************************************************************************
#*************** Dynamic reconfiguration validation callbacks *****************

proc ::altera_xcvr_native_vi::parameters::validate_rcfg_shared { PROP_NAME PROP_VALUE rcfg_enable channels } {
  set legal_values [expr { !$rcfg_enable ? $PROP_VALUE
    : $channels > 1 ? {0 1}
      : 0 }]
 
  auto_invalid_value_message auto $PROP_NAME $PROP_VALUE $legal_values { channels }
}


proc ::altera_xcvr_native_vi::parameters::validate_rcfg_jtag_enable { PROP_NAME PROP_VALUE rcfg_enable rcfg_shared } {
  set legal_values [expr { !$rcfg_enable ? $PROP_VALUE
    : $rcfg_shared ? {0 1}
      : 0 }]
 
  auto_invalid_value_message auto $PROP_NAME $PROP_VALUE $legal_values { rcfg_shared }
}


proc ::altera_xcvr_native_vi::parameters::validate_rcfg_profile_select { PROP_NAME rcfg_profile_cnt } {
  set legal_values {}
  for {set x 0} {$x < $rcfg_profile_cnt} {incr x} {
    lappend legal_values $x
  }
  
  ip_set "parameter.${PROP_NAME}.allowed_ranges" $legal_values
}


proc ::altera_xcvr_native_vi::parameters::validate_rcfg_param_vals { PROP_NAME PROP_M_CONTEXT \
  rcfg_enable rcfg_multi_enable rcfg_profile_cnt rcfg_params \
  message_level } {

  # Initialize the result list
  set rcfg_param_vals ""

  # For each profile we make sure the settings are consistent with the current profile.
  if {$rcfg_enable && $rcfg_multi_enable && ($PROP_M_CONTEXT < $rcfg_profile_cnt)} {
    # Grab profile data (except for current config)
    set rcfg_profile_data ""
    set use_current_config 1

    set rcfg_profile_data [ip_get "parameter.rcfg_profile_data${PROP_M_CONTEXT}.value"]
    # If the profile data is empty, issue a warning and use the current configuration
    if {$rcfg_profile_data == ""} {
      ip_message warning "Multiple reconfiguration profile $PROP_M_CONTEXT is empty. The IP will use the current configuration for profile $PROP_M_CONTEXT"
    } else {
      set use_current_config 0
    }

    set same_as_current 1

    # Iterate over the necessary parameters and set the value appropriately
    foreach param $rcfg_params {
      set cur_val [ip_get "parameter.${param}.value"]
      set this_val ""
      # If we're using the current config just grab the value
      if {$use_current_config} {
        set this_val $cur_val
      } else {
        # The remaining profiles we pull from stored data
        # Use the stored value if it was found
        if {[dict exist $rcfg_profile_data $param]} {
          set this_val [dict get $rcfg_profile_data $param]
        } else {
          # Use the default parameter value if the value is not contained in the stored data
          # This would occur if the IP were upgraded with new parameters
          set this_val [ip_get "parameter.${param}.default_value"]
          ip_message warning "Reconfiguration profile $PROP_M_CONTEXT is missing a value for parameter [ip_get "parameter.${param}.display_name"] (${param}). Altera recommends that you refresh the profile."
        }
      }

      # For parameters that must be the same across configurations; check the current value against the stored value
      if {$cur_val != $this_val} {
        set same_as_current 0
        if {[ip_get "parameter.${param}.M_SAME_FOR_RCFG"] } {
          ip_message $message_level "Parameter \"${param}\" ([ip_get "parameter.${param}.display_name"]) must be consistent for all reconfiguration profiles. Current value:${cur_val}; Profile${PROP_M_CONTEXT} value:${this_val}."
        }
      }

      # Add the value to the list
      lappend rcfg_param_vals $this_val
    }
    # Finished iterating over params

    # If the current configuration matches the stored configuration, issue a message
    if {$same_as_current} {
      ip_message info "Current IP configuration matches reconfiguration profile $PROP_M_CONTEXT"
    }
    
  }

  ip_set "parameter.${PROP_NAME}.value" $rcfg_param_vals
}


proc ::altera_xcvr_native_vi::parameters::action_store_profile { {profile NOVAL} } {
  if {$profile == "NOVAL"} {
    set profile [ip_get "parameter.rcfg_profile_select.value"]
  }
  set rcfg_profile_cnt [ip_get "parameter.rcfg_profile_cnt.value"]

  puts "Constructing profile ${profile}"
  if {$profile < $rcfg_profile_cnt} {
    set rcfg_params [ip_get "parameter.rcfg_params.value"]
    set rcfg_profile_data [dict create]
    # Iterate over necessary parameters and store value
    foreach param $rcfg_params {
      dict set rcfg_profile_data $param [ip_get "parameter.${param}.value"]
    }
    ip_set "Storing profile ${profile} $rcfg_profile_data"
    puts "Storing profile ${profile} $rcfg_profile_data"
    ip_set "parameter.rcfg_profile_data${profile}.value" $rcfg_profile_data
  }
}


proc ::altera_xcvr_native_vi::parameters::action_load_profile { {profile NOVAL} } {
  if {$profile == "NOVAL"} {
    set profile [ip_get "parameter.rcfg_profile_select.value"]
  }
  set rcfg_profile_cnt [ip_get "parameter.rcfg_profile_cnt.value"]

  if {$profile < $rcfg_profile_cnt} {
    set rcfg_params [ip_get "parameter.rcfg_params.value"]
    set rcfg_param_vals [ip_get "parameter.rcfg_param_vals${profile}.value"]
    # Iterate over each parameter and set the value from the stored profile
    for {set i 0} {$i < [llength $rcfg_params]} {incr i} {
      set param [lindex $rcfg_params $i]
      set param_val [lindex $rcfg_param_vals $i]
      ip_set "parameter.${param}.value" $param_val
    }
  }
}


proc ::altera_xcvr_native_vi::parameters::action_clear_profile { {profile NOVAL} } {
  if {$profile == "NOVAL"} {
    set profile [ip_get "parameter.rcfg_profile_select.value"]
  }

  ip_set "parameter.rcfg_profile_data${profile}.value" ""
}


proc ::altera_xcvr_native_vi::parameters::action_clear_profiles {} {
  for {set i 0} {$i < 8} {incr i} {
    action_clear_profile $i
  }
}


proc ::altera_xcvr_native_vi::parameters::action_refresh_profile { {profile NOVAL} } {
  if {$profile == "NOVAL"} {
    set profile [ip_get "parameter.rcfg_profile_select.value"]
  }

  # Store current configuration data
  set rcfg_params [ip_get "parameter.rcfg_params.value"]
  set current_param_vals {}
  foreach param $rcfg_params {
    lappend current_param_vals [ip_get "parameter.${param}.value"]
  }

  # Refresh = load->store
  action_load_profile $profile
  action_store_profile $profile

  # Restore current values
  for {set i 0} {$i < [llength $rcfg_params]} {incr i} {
    set param [lindex $rcfg_params $i]
    set value [lindex $current_param_vals $i]
    ip_set "parameter.${param}.value" $value
  }

}

proc ::altera_xcvr_native_vi::parameters::action_refresh_profiles {} {
  #First we have to store the current profile so we can restore it when done
  set rcfg_profile_cnt [ip_get "parameter.rcfg_profile_cnt.value"] 
  for {set profile 0} {$profile < $rcfg_profile_cnt} {incr profile} {
    action_refresh_profile $profile
  }
}

#************* End dynamic reconfiguration validation callbacks ***************
#******************************************************************************


#******************************************************************************
#********************** RBC Validation Override Callbacks *********************

proc ::altera_xcvr_native_vi::parameters::validate_std_rx_word_aligner_pattern_len { PROP_M_AUTOSET std_rx_word_aligner_pattern_len hssi_8g_rx_pcs_prot_mode hssi_8g_rx_pcs_wa_boundary_lock_ctrl hssi_8g_rx_pcs_pma_dw l_enable_rx_std } {

   set legal_values {7 10 8 16 20 32 40}

   if [expr { ($hssi_8g_rx_pcs_wa_boundary_lock_ctrl!="bit_slip") }] {
      if [expr { (($hssi_8g_rx_pcs_prot_mode=="gige")||($hssi_8g_rx_pcs_prot_mode=="gige_1588")) }] {
         set legal_values {7 10}
      } else {
         if [expr { (($hssi_8g_rx_pcs_prot_mode=="basic_rm_disable")||($hssi_8g_rx_pcs_prot_mode=="basic_rm_enable")) }] {
            if [expr { ($hssi_8g_rx_pcs_pma_dw=="eight_bit") }] {
               set legal_values {8 16}
            } else {
               if [expr { ($hssi_8g_rx_pcs_pma_dw=="ten_bit") }] {
                  set legal_values {7 10}
               } else {
                  if [expr { ($hssi_8g_rx_pcs_pma_dw=="sixteen_bit") }] {
                     set legal_values {8 16 32}
                  } else {
                     if [expr { ($hssi_8g_rx_pcs_wa_boundary_lock_ctrl!="sync_sm") }] {
                        set legal_values {7 10 20 40}
                     } else {
                        set legal_values {7 10 20}
                     }
                  }
               }
            }
         } else {
            set legal_values {10}
         }
      }
   } else {
      if [expr { ($hssi_8g_rx_pcs_pma_dw=="sixteen_bit") }] {
         set legal_values {16}
      } else {
         set legal_values {7}
      }
   }

   if {$l_enable_rx_std} {
   auto_invalid_value_message auto std_rx_word_aligner_pattern_len $std_rx_word_aligner_pattern_len $legal_values { hssi_8g_rx_pcs_prot_mode hssi_8g_rx_pcs_wa_boundary_lock_ctrl hssi_8g_rx_pcs_pma_dw }
}
}


proc ::altera_xcvr_native_vi::parameters::validate_hssi_8g_rx_pcs_wa_pd { PROP_NAME std_rx_word_aligner_pattern_len 
                                                                          hssi_8g_rx_pcs_prot_mode hssi_8g_rx_pcs_wa_boundary_lock_ctrl hssi_8g_rx_pcs_pma_dw} {
  set legal_values [ expr { \
      $hssi_8g_rx_pcs_wa_boundary_lock_ctrl == "bit_slip" && $std_rx_word_aligner_pattern_len == "16" ? "wa_pd_16_sw"
    : $hssi_8g_rx_pcs_wa_boundary_lock_ctrl == "bit_slip" && $std_rx_word_aligner_pattern_len != "16" ? "wa_pd_7"
    : ($hssi_8g_rx_pcs_prot_mode == "gige" || $hssi_8g_rx_pcs_prot_mode == "gige_1588") && $std_rx_word_aligner_pattern_len == "7" ? "wa_pd_7"
    : ($hssi_8g_rx_pcs_prot_mode == "gige" || $hssi_8g_rx_pcs_prot_mode == "gige_1588") && $std_rx_word_aligner_pattern_len == "10" ? "wa_pd_10"
    : ($hssi_8g_rx_pcs_prot_mode == "basic_rm_disable" || $hssi_8g_rx_pcs_prot_mode == "basic_rm_enable") && $hssi_8g_rx_pcs_pma_dw == "eight_bit" && $std_rx_word_aligner_pattern_len == "8" ? "wa_pd_8_sw"
    : ($hssi_8g_rx_pcs_prot_mode == "basic_rm_disable" || $hssi_8g_rx_pcs_prot_mode == "basic_rm_enable") && $hssi_8g_rx_pcs_pma_dw == "eight_bit" && $std_rx_word_aligner_pattern_len == "16" ? "wa_pd_16_sw"
    : ($hssi_8g_rx_pcs_prot_mode == "basic_rm_disable" || $hssi_8g_rx_pcs_prot_mode == "basic_rm_enable") && $hssi_8g_rx_pcs_pma_dw == "ten_bit" && $std_rx_word_aligner_pattern_len == "7" ? "wa_pd_7"
    : ($hssi_8g_rx_pcs_prot_mode == "basic_rm_disable" || $hssi_8g_rx_pcs_prot_mode == "basic_rm_enable") && $hssi_8g_rx_pcs_pma_dw == "ten_bit" && $std_rx_word_aligner_pattern_len == "10" ? "wa_pd_10"
    : ($hssi_8g_rx_pcs_prot_mode == "basic_rm_disable" || $hssi_8g_rx_pcs_prot_mode == "basic_rm_enable") && $hssi_8g_rx_pcs_pma_dw == "sixteen_bit" && $std_rx_word_aligner_pattern_len == "8" ? "wa_pd_8_sw"
    : ($hssi_8g_rx_pcs_prot_mode == "basic_rm_disable" || $hssi_8g_rx_pcs_prot_mode == "basic_rm_enable") && $hssi_8g_rx_pcs_pma_dw == "sixteen_bit" && $std_rx_word_aligner_pattern_len == "16" ? "wa_pd_16_sw"
    : ($hssi_8g_rx_pcs_prot_mode == "basic_rm_disable" || $hssi_8g_rx_pcs_prot_mode == "basic_rm_enable") && $hssi_8g_rx_pcs_pma_dw == "sixteen_bit" && $std_rx_word_aligner_pattern_len == "32" ? "wa_pd_32"
    : ($hssi_8g_rx_pcs_prot_mode == "basic_rm_disable" || $hssi_8g_rx_pcs_prot_mode == "basic_rm_enable") && $hssi_8g_rx_pcs_wa_boundary_lock_ctrl == "sync_sm" && $std_rx_word_aligner_pattern_len == "40" ? "wa_pd_40"
    : ($hssi_8g_rx_pcs_prot_mode == "basic_rm_disable" || $hssi_8g_rx_pcs_prot_mode == "basic_rm_enable") && $std_rx_word_aligner_pattern_len == "7" ? "wa_pd_7"
    : ($hssi_8g_rx_pcs_prot_mode == "basic_rm_disable" || $hssi_8g_rx_pcs_prot_mode == "basic_rm_enable") && $std_rx_word_aligner_pattern_len == "10" ? "wa_pd_10"
    : ($hssi_8g_rx_pcs_prot_mode == "basic_rm_disable" || $hssi_8g_rx_pcs_prot_mode == "basic_rm_enable") && $std_rx_word_aligner_pattern_len == "20" ? "wa_pd_20"
    : "wa_pd_10" }]

  ip_set "parameter.${PROP_NAME}.value" $legal_values
  #::alt_xcvr::ip_tcl::ip_module::call_callback $PROP_NAME $legal_values "::nf_xcvr_native::parameters::validate_${PROP_NAME}"
}


proc ::altera_xcvr_native_vi::parameters::validate_hssi_tx_pld_pcs_interface_hd_chnl_pma_dw_tx { protocol_mode l_pcs_pma_width } {
  set value [ expr { $protocol_mode == "pipe_g3" ? "pcie_g3_dyn_dw_tx"
    : "pma_${l_pcs_pma_width}b_tx" }]

  ip_set "parameter.hssi_tx_pld_pcs_interface_hd_chnl_pma_dw_tx.value" $value
}


proc ::altera_xcvr_native_vi::parameters::validate_hssi_rx_pld_pcs_interface_hd_chnl_pma_dw_rx { protocol_mode l_pcs_pma_width } {
  set value [ expr { $protocol_mode == "pipe_g3" ? "pcie_g3_dyn_dw_rx"
    : "pma_${l_pcs_pma_width}b_rx" }]

  ip_set "parameter.hssi_rx_pld_pcs_interface_hd_chnl_pma_dw_rx.value" $value
}


proc ::altera_xcvr_native_vi::parameters::validate_hssi_tx_pld_pcs_interface_hd_chnl_pld_fifo_mode_tx { datapath_select hssi_tx_pld_pcs_interface_hd_8g_fifo_mode_tx hssi_tx_pld_pcs_interface_hd_10g_fifo_mode_tx } {
  set value [expr {$datapath_select == "Enhanced" ? $hssi_tx_pld_pcs_interface_hd_10g_fifo_mode_tx 
    : $hssi_tx_pld_pcs_interface_hd_10g_fifo_mode_tx }]

  ip_set "parameter.hssi_tx_pld_pcs_interface_hd_chnl_pld_fifo_mode_tx.value" $value
}


proc ::altera_xcvr_native_vi::parameters::validate_hssi_rx_pld_pcs_interface_hd_chnl_pld_fifo_mode_rx { datapath_select hssi_rx_pld_pcs_interface_hd_8g_fifo_mode_rx hssi_rx_pld_pcs_interface_hd_10g_fifo_mode_rx } {
  set value [expr {$datapath_select == "Enhanced" ? $hssi_rx_pld_pcs_interface_hd_10g_fifo_mode_rx 
    : $hssi_rx_pld_pcs_interface_hd_8g_fifo_mode_rx }]

  ip_set "parameter.hssi_rx_pld_pcs_interface_hd_chnl_pld_fifo_mode_rx.value" $value
}


proc ::altera_xcvr_native_vi::parameters::validate_pma_cgb_input_select_x1 { bonded_mode pll_select } {
  set value [ expr { $bonded_mode != "not_bonded" ? "unused"
    : $pll_select == "0" ? "fpll_bot"
    : $pll_select == "1" ? "lcpll_bot"
    : $pll_select == "2" ? "fpll_top"   
    : $pll_select == "3" ? "lcpll_top"
      : "fpll_bot" }]

  ip_set "parameter.pma_cgb_input_select_x1.value" $value
}


proc ::altera_xcvr_native_vi::parameters::validate_pma_cgb_input_select_gen3 { bonded_mode l_enable_std_pipe protocol_mode } {
  set value [ expr { ($bonded_mode == "not_bonded") && $l_enable_std_pipe && ($protocol_mode == "pipe_g3") ? "lcpll_bot"
      : "unused" }]

  ip_set "parameter.pma_cgb_input_select_gen3.value" $value
}


proc ::altera_xcvr_native_vi::parameters::validate_pma_cgb_prot_mode { l_enable_std_pipe protocol_mode } {
  set value [ expr { $l_enable_std_pipe && $protocol_mode == "pipe_g1" ? "pcie_gen1_tx"
   : $l_enable_std_pipe && $protocol_mode == "pipe_g2" ? "pcie_gen2_tx" 
    : $l_enable_std_pipe && $protocol_mode == "pipe_g3" ? "pcie_gen3_tx" 
      : "basic_tx" }]

  ip_set "parameter.pma_cgb_prot_mode.value" $value
}


proc ::altera_xcvr_native_vi::parameters::validate_pma_rx_deser_clkdivrx_user_mode { rx_enable enable_port_rx_pma_div_clkout rx_pma_div_clkout_divider } {
  set value [expr {!$rx_enable || !$enable_port_rx_pma_div_clkout ? "clkdivrx_user_disabled"
    : $rx_pma_div_clkout_divider == "1" ? "clkdivrx_user_clkdiv"
    : $rx_pma_div_clkout_divider == "2" ? "clkdivrx_user_clkdiv_div2"
    : $rx_pma_div_clkout_divider == "33" ? "clkdivrx_user_div33"
    : $rx_pma_div_clkout_divider == "40" ? "clkdivrx_user_div40"
    : $rx_pma_div_clkout_divider == "50" ? "clkdivrx_user_div50"
    : $rx_pma_div_clkout_divider == "66" ? "clkdivrx_user_div66"
    : "clkdivrx_user_disabled" }]


  ip_set "parameter.pma_rx_deser_clkdivrx_user_mode.value" $value
}

### FIXIT GW Add rule to set signal detect block for PCIe only design. Need to include SATA later###
proc ::altera_xcvr_native_vi::parameters::validate_pma_rx_sd_sd_output_on { l_enable_std_pipe } {
  set value [expr {$l_enable_std_pipe ? 1
    : 15 }]

  ip_set "parameter.pma_rx_sd_sd_output_on.value" $value
}

proc ::altera_xcvr_native_vi::parameters::validate_pma_tx_buf_rx_det_output_sel { l_enable_std_pipe } {
  set value [expr {$l_enable_std_pipe ? "rx_det_pcie_out"
    : "rx_det_qpi_out" }]

  ip_set "parameter.pma_tx_buf_rx_det_output_sel.value" $value
}


proc ::altera_xcvr_native_vi::parameters::validate_pma_tx_buf_rx_det_pdb { l_enable_std_pipe enable_port_tx_pma_txdetectrx } {
  set value [expr {$l_enable_std_pipe || $enable_port_tx_pma_txdetectrx ? "rx_det_on"
    : "rx_det_off" }]

  ip_set "parameter.pma_tx_buf_rx_det_pdb.value" $value
}


proc ::altera_xcvr_native_vi::parameters::validate_pma_tx_ser_ser_clk_divtx_user_sel { tx_enable enable_port_tx_pma_div_clkout tx_pma_div_clkout_divider } {
  set value [expr {!$tx_enable || !$enable_port_tx_pma_div_clkout ? "divtx_user_off"
    : $tx_pma_div_clkout_divider == "1" ? "divtx_user_1"
    : $tx_pma_div_clkout_divider == "2" ? "divtx_user_2"
    : $tx_pma_div_clkout_divider == "33" ? "divtx_user_33"
    : $tx_pma_div_clkout_divider == "40" ? "divtx_user_40"
    : $tx_pma_div_clkout_divider == "66" ? "divtx_user_66"
    : "divtx_user_off" }]

  ip_set "parameter.pma_tx_ser_ser_clk_divtx_user_sel.value" $value
}


proc ::altera_xcvr_native_vi::parameters::validate_hssi_pipe_gen1_2_txswing { protocol_mode enable_hip } {
  set value [ expr { !$enable_hip && ($protocol_mode == "pipe_g1" || $protocol_mode == "pipe_g2") ? "en_txswing"
    : "dis_txswing" }]

  ip_set "parameter.hssi_pipe_gen1_2_txswing.value" $value
}


proc ::altera_xcvr_native_vi::parameters::validate_hssi_pipe_gen3_phystatus_rst_toggle_g12 { PROP_M_AUTOSET PROP_M_AUTOWARN hssi_pipe_gen3_phystatus_rst_toggle_g12 hssi_pipe_gen3_sup_mode hssi_pipe_gen3_mode } {
 
   set legal_values [list "dis_phystatus_rst_toggle" "en_phystatus_rst_toggle"]
 
   if [expr { ($hssi_pipe_gen3_sup_mode=="user_mode") }] {
      if [expr { (($hssi_pipe_gen3_mode=="pipe_g1")||($hssi_pipe_gen3_mode=="pipe_g2")) }] {
         set legal_values [list "en_phystatus_rst_toggle"]
      } else {
         if [expr { ($hssi_pipe_gen3_mode=="pipe_g3") }] {
            set legal_values [list "en_phystatus_rst_toggle"]
         } else {
            if [expr { ($hssi_pipe_gen3_mode=="disable_pcs") }] {
              set legal_values [list "dis_phystatus_rst_toggle"]
            }
         }
      }
   }
 
   if { $PROP_M_AUTOSET } {
      set len [llength $legal_values]
      if { $len > 0 } {
         ip_set "parameter.hssi_pipe_gen3_phystatus_rst_toggle_g12.value" [lindex $legal_values 0]
      }
      if { $len != 1 && $PROP_M_AUTOWARN} {
         ip_message warning "The value of parameter hssi_pipe_gen3_phystatus_rst_toggle_g12 cannot be automatically resolved. Valid values are: ${legal_values}."
      }
   } else {
      auto_invalid_value_message auto hssi_pipe_gen3_phystatus_rst_toggle_g12 $hssi_pipe_gen3_phystatus_rst_toggle_g12 $legal_values { hssi_pipe_gen3_sup_mode hssi_pipe_gen3_mode }
   }
}


proc ::altera_xcvr_native_vi::parameters::validate_hssi_pipe_gen3_rate_match_pad_insertion { PROP_M_AUTOSET PROP_M_AUTOWARN hssi_pipe_gen3_rate_match_pad_insertion hssi_pipe_gen3_sup_mode hssi_pipe_gen3_mode } {
 
   set legal_values [list "dis_rm_fifo_pad_ins" "en_rm_fifo_pad_ins"]
 
   if [expr { ($hssi_pipe_gen3_sup_mode=="user_mode") }] {
      if [expr { ((($hssi_pipe_gen3_mode=="pipe_g1")||($hssi_pipe_gen3_mode=="pipe_g2"))||($hssi_pipe_gen3_mode=="pipe_g3")) }] {
         set legal_values [list "en_rm_fifo_pad_ins"]
      } else {
         if [expr { ($hssi_pipe_gen3_mode=="disable_pcs") }] {
            set legal_values [list "dis_rm_fifo_pad_ins"]
         }
      }
   }
 
   if { $PROP_M_AUTOSET } {
      set len [llength $legal_values]
      if { $len > 0 } {
         ip_set "parameter.hssi_pipe_gen3_rate_match_pad_insertion.value" [lindex $legal_values 0]
      }
      if { $len != 1 && $PROP_M_AUTOWARN} {
         ip_message warning "The value of parameter hssi_pipe_gen3_rate_match_pad_insertion cannot be automatically resolved. Valid values are: ${legal_values}."
      }
   } else {
      auto_invalid_value_message auto hssi_pipe_gen3_rate_match_pad_insertion $hssi_pipe_gen3_rate_match_pad_insertion $legal_values { hssi_pipe_gen3_sup_mode hssi_pipe_gen3_mode }
   }
}


proc ::altera_xcvr_native_vi::parameters::validate_cdr_pll_m_counter { l_pll_settings l_pll_settings_key } {
  if {$l_pll_settings != "NOVAL" && $l_pll_settings_key != "NOVAL"} {
    ip_set "parameter.cdr_pll_m_counter.value" [dict get $l_pll_settings $l_pll_settings_key m]
  }
}

proc ::altera_xcvr_native_vi::parameters::validate_cdr_pll_n_counter { l_pll_settings l_pll_settings_key } {
  if {$l_pll_settings != "NOVAL" && $l_pll_settings_key != "NOVAL"} {
    ip_set "parameter.cdr_pll_n_counter.value" [dict get $l_pll_settings $l_pll_settings_key n]
  }
}

proc ::altera_xcvr_native_vi::parameters::validate_cdr_pll_pd_l_counter { l_pll_settings l_pll_settings_key } {
  if {$l_pll_settings != "NOVAL" && $l_pll_settings_key != "NOVAL"} {
    ip_set "parameter.cdr_pll_pd_l_counter.value" [dict get $l_pll_settings $l_pll_settings_key lpd]
  }
}

proc ::altera_xcvr_native_vi::parameters::validate_cdr_pll_pfd_l_counter { l_pll_settings l_pll_settings_key } {
  if {$l_pll_settings != "NOVAL" && $l_pll_settings_key != "NOVAL"} {
    ip_set "parameter.cdr_pll_pfd_l_counter.value" [dict get $l_pll_settings $l_pll_settings_key lpfd]
  }
}

proc ::altera_xcvr_native_vi::parameters::validate_cdr_pll_reference_clock_frequency {set_cdr_refclk_freq} {
  ip_set "parameter.cdr_pll_reference_clock_frequency.value" "${set_cdr_refclk_freq} MHz"
}


proc ::altera_xcvr_native_vi::parameters::validate_cdr_pll_output_clock_frequency {set_data_rate} {
  ip_set "parameter.cdr_pll_output_clock_frequency.value" "[expr {$set_data_rate / 2}] MHz"
}


proc ::altera_xcvr_native_vi::parameters::validate_cdr_pll_pcie_gen { PROP_NAME set_cdr_refclk_freq l_enable_std_pipe protocol_mode } {
  # possible values {non_pcie pcie_gen1_100mhzref pcie_gen1_125mhzref pcie_gen2_100mhzref pcie_gen2_125mhzref pcie_gen3_100mhzref pcie_gen3_125mhzref}
  set value "non_pcie"
  if {$l_enable_std_pipe} {
    set pcie_str [expr {$protocol_mode == "pipe_g1" ? "pcie_gen1"
      : $protocol_mode == "pipe_g2" ? "pcie_gen2"
      : "pcie_gen3"}]
    set refclk_str [expr { [regexp {125\.} $set_cdr_refclk_freq] ? "125mhzref" : "100mhzref" }]
    set value "${pcie_str}_${refclk_str}"
  }

  ip_set "parameter.${PROP_NAME}.value" $value
}

proc ::altera_xcvr_native_vi::parameters::validate_hssi_10g_tx_pcs_dv_bond { PROP_M_AUTOSET PROP_M_AUTOWARN hssi_10g_tx_pcs_dv_bond hssi_10g_tx_pcs_prot_mode hssi_10g_tx_pcs_indv } {

   set legal_values [list "dv_bond_dis" "dv_bond_en"]

   if [expr { (($hssi_10g_tx_pcs_prot_mode=="interlaken_mode")&&($hssi_10g_tx_pcs_indv=="indv_en")) }] {
      #set legal_values [intersect $legal_values [list "dv_bond_en" "dv_bond_dis"]]
      set legal_values {"dv_bond_dis"}
   } else {
      if [expr { ($hssi_10g_tx_pcs_indv=="indv_dis") }] {
         set legal_values {"dv_bond_en"}
      } else {
         set legal_values {"dv_bond_dis"}
      }
   }

   if { $PROP_M_AUTOSET } {
      set len [llength $legal_values]
      if { $len > 0 } {
         ip_set "parameter.hssi_10g_tx_pcs_dv_bond.value" [lindex $legal_values 0]
      }
      if { $len != 1 && $PROP_M_AUTOWARN} {
         ip_message warning "The value of parameter hssi_10g_tx_pcs_dv_bond cannot be automatically resolved. Valid values are: ${legal_values}."
      }
   } else {
      auto_invalid_value_message auto hssi_10g_tx_pcs_dv_bond $hssi_10g_tx_pcs_dv_bond $legal_values { hssi_10g_tx_pcs_prot_mode hssi_10g_tx_pcs_indv }
   }
}

#******************** End RBC Validation Override Callbacks *******************
#******************************************************************************


proc ::altera_xcvr_native_vi::parameters::auto_set_allowed_ranges { param_name param_value param_allowed_ranges } {
  if { [lsearch $param_allowed_ranges $param_value] == -1 } {
    lappend param_allowed_ranges $param_value
  }
  ip_set "parameter.${param_name}.allowed_ranges" $param_allowed_ranges
}
#********************** End Validation Callbacks ******************************
#******************************************************************************


