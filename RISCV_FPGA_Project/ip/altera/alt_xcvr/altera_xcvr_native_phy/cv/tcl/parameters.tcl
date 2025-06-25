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


package provide altera_xcvr_native_cv::parameters 13.1

package require alt_xcvr::ip_tcl::ip_module
package require alt_xcvr::ip_tcl::messages
package require alt_xcvr::gui::pll_reconfig
package require alt_xcvr::gui::messages
package require alt_xcvr::utils::device
package require alt_xcvr::utils::rbc
package require alt_xcvr::utils::common

namespace eval ::altera_xcvr_native_cv::parameters:: {
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

  set package_name "altera_xcvr_native_cv::parameters"

  set display_items {\
    {NAME                                     GROUP           TYPE  ARGS  }\
    {"General"                                ""              GROUP NOVAL }\
    {"Datapath Options"                       ""              GROUP NOVAL }\
    {"PMA"                                    ""              GROUP tab   }\
    {"PMA Direct Options"                     "PMA"           GROUP NOVAL }\
    {"TX PMA"                                 "PMA"           GROUP NOVAL }\
    {"RX PMA"                                 "PMA"           GROUP NOVAL }\
    {"Standard PCS"                           ""              GROUP tab   }\
    \
    {"Phase Compensation FIFO"                "Standard PCS"  GROUP NOVAL }\
    {"Byte Ordering"                          "Standard PCS"  GROUP NOVAL }\
    {"Byte Serializer and Deserializer"       "Standard PCS"  GROUP NOVAL }\
    {"8B/10B Encoder and Decoder"             "Standard PCS"  GROUP NOVAL }\
    {"Rate Match FIFO"                        "Standard PCS"  GROUP NOVAL }\
    {"Word Aligner and Bitslip"               "Standard PCS"  GROUP NOVAL }\
    {"Bit Reversal and Polarity Inversion"    "Standard PCS"  GROUP NOVAL }\
  }
    
  set parameters {\
    {NAME                                   DERIVED HDL_PARAMETER TYPE      DEFAULT_VALUE                   ALLOWED_RANGES                                               ENABLED                                VISIBLE                     DISPLAY_HINT  DISPLAY_UNITS DISPLAY_ITEM                              DISPLAY_NAME                                            VALIDATION_CALLBACK                                                               DESCRIPTION }\
    {device_family                          false   false         STRING    "Cyclone V"                     {"Cyclone V"}                                                true                                   false                       NOVAL         NOVAL         NOVAL                                     NOVAL                                                   NOVAL                                                                             NOVAL}\
    {show_advanced_features                 false   false         INTEGER   0                               NOVAL                                                        false                                  false                       boolean       NOVAL         NOVAL                                     "Show advanced features"                                ::altera_xcvr_native_cv::parameters::validate_show_advanced_features              NOVAL}\
    \
    {device_speedgrade                      false   false         STRING    "fastest"                       NOVAL                                                        true                                   true                        NOVAL         NOVAL         "General"                                 "Device speedgrade"                                     NOVAL                                                                             "Specifies the desired device speedgrade. This information is used for data rate validation."}
    {message_level                          false   false         STRING    "error"                         {error warning}                                              true                                   true                        NOVAL         NOVAL         "General"                                 "Message level for rule violations"                     NOVAL                                                                             "Specifies the messaging level to use for parameter rule violations. Selecting \"error\" will cause all rule violations to prevent IP generation. Selecting \"warning\" will display all rule violations as warnings and will allow IP generation in spite of violations."}\
    \
    {tx_enable                              false   true          INTEGER   1                               NOVAL                                                        true                                   true                        boolean       NOVAL         "Datapath Options"                        "Enable TX datapath"                                   NOVAL                                                                             "When selected, the core includes the TX (transmit) datapath."}\
    {rx_enable                              false   true          INTEGER   1                               NOVAL                                                        true                                   true                        boolean       NOVAL         "Datapath Options"                        "Enable RX datapath"                                   ::altera_xcvr_native_cv::parameters::validate_rx_enable                           "When selected, the core includes the RX (receive) datapath"}\
    {enable_std                             false   true          INTEGER   1                               NOVAL                                                        true                                   false                        boolean       NOVAL         "Datapath Options"                        "Enable Standard PCS"                                   ::altera_xcvr_native_cv::parameters::validate_enable_std                          "Enables the 'Standard PCS' datapath. The transceiver contains two seperate PCS datapaths (Standard and 10G). This option must be enabled if you intend to statically use the 'Standard PCS' or if you intend to dynamically switch between the standard and 10G PCS. The 'pma_direct' datapath cannot be used when this option is enabled and dynamic reconfiguration between 'pma_direct' and PCS modes is not supported by the device. Refer to the device handbook for details on features supported by the 'Standard PCS'."}\
    {set_data_path_select                   false   false         STRING    "standard"                      {standard}                                                   enable_std                             true                        NOVAL         NOVAL         "Datapath Options"                        "Initial PCS datapath selection"                        NOVAL                                                                             "Specifies the initial datapath for this configuration of the core. \n'standard':Selects the 'Standard PCS' as the initially selected datapath."}\
    {data_path_select                       true    true          STRING    "standard"                      {standard}                                                   true                                   false                       NOVAL         NOVAL         "Datapath Options"                        NOVAL                                                   ::altera_xcvr_native_cv::parameters::validate_data_path_select                    NOVAL}\
    {channels                               false   true          INTEGER   1                               NOVAL                                                        true                                   true                        NOVAL         NOVAL         "Datapath Options"                        "Number of data channels"                               ::altera_xcvr_native_cv::parameters::validate_channels                            "Specifies the total number of data channels."}\
    {bonded_mode                            false   true          STRING    "non_bonded"                    {"non_bonded:x1" "xN:xN"}                                    tx_enable                              tx_enable                   NOVAL         NOVAL         "Datapath Options"                        "Bonding mode"                                          NOVAL                                                                             "Specifies the bonding mode to control channel-to-channel skew for the TX datapath. Refer to the device handbook for bonding details. 'x1':TX channels will be not be bonded (no skew control). 'xn':TX channels will be bonded using x6/xn bonding."}\
    {enable_simple_interface                false   false         INTEGER   0                               NOVAL                                                        true                                   true                        boolean       NOVAL         "Datapath Options"                        "Enable simplified data interface"                      ::altera_xcvr_native_cv::parameters::validate_enable_simple_interface             "When selected, the IP will present a simplified data and control interface between the FPGA and transceiver. When not selected, the IP will present the full raw data interface to the transceiver. You will need to understand the mapping of data and control signals within the interface. This option cannot be enabled if you want to perform dynamic interface reconfiguration as only a fixed subset of the data and control signals will be provided."}\
    \
    {set_data_rate                          false   false         STRING    "1250"                          NOVAL                                                        true                                   true                        "columns:10"  Mbps          "PMA"                                     "Data rate"                                             ::altera_xcvr_native_cv::parameters::validate_set_data_rate                       "Specifies the transceiver data rate in units of Mbps (megabits per second)."}\
    {data_rate                              true    true          STRING    NOVAL                           NOVAL                                                        true                                   false                       NOVAL         NOVAL         NOVAL                                     NOVAL                                                   ::altera_xcvr_native_cv::parameters::validate_data_rate                           NOVAL}\
    {pma_width                              true    true          INTEGER   10                              NOVAL                                                        true                                   false                       NOVAL         NOVAL         "PMA"                                     "PCS / PMA interface width"                             ::altera_xcvr_native_cv::parameters::validate_pma_width                           NOVAL}\
    {pma_direct_width                       false   false         INTEGER   80                              {8 10 16 20 64 80}                                           true                                   true                        NOVAL         NOVAL         "PMA"                                     "PMA direct interface width"                            ::altera_xcvr_native_cv::parameters::validate_pma_direct_width                    "Specifies the width of the datapath that connects the FPGA fabric to the PMA for 'pma_direct' mode."}\
    {tx_pma_clk_div                         false   true          INTEGER   1                               {1 2 4 8}                                                    tx_enable                              tx_enable                   NOVAL         NOVAL         "PMA"                                     "TX local clock division factor"                        NOVAL                                                                             "Specifies the TX serial clock division factor. The transceiver has the ability to further divide the TX serial clock from the TX PLL before use. This parameter specifies the division factor to use. Example: A PLL data rate of \"10000 Mbps\" and a local division factor of 8 will result in a channel data rate of \"1250 Mbps\""}\
    {base_data_rate                         true    false         STRING    "1250"                          NOVAL                                                        tx_enable                              tx_enable                   "columns:10"  Mbps          "PMA"                                     "TX PLL base data rate"                                 ::altera_xcvr_native_cv::parameters::validate_base_data_rate                      "The calculated PLL base data rate (Date rate * local clock division factor). The configured base data rate for the selected TX PLL must match this value."}\
    {pll_reconfig_enable                    false   true          INTEGER   0                               NOVAL                                                        tx_enable                              tx_enable                   boolean       NOVAL         "TX PMA"                                  "Enable TX PLL dynamic reconfiguration"                 ::altera_xcvr_native_cv::parameters::validate_pll_reconfig_enable                 "Enabling this option has two effects: 1-The simulation model for the TX PLL will include support for dynamic reconfiguration. 2-Quartus will not merge the TX PLLs by default. Merging can be manually controlled through QSF assignments. Dynamic reconfiguration includes reference clock switching and data rate reconfiguration. Dynamic reconfiguration of ATX PLLs is not supported in the current release."}\
    {pll_external_enable                    false   true          INTEGER   0                               NOVAL                                                        tx_enable                              tx_enable                   boolean       NOVAL         "TX PMA"                                  "Use external TX PLL"                                   NOVAL                                                                             "When selected, the IP core will not include the TX PLL(s). The IP core will instead expose the ext_pll_clk port for connection to an external TX PLL."}\
    {pll_data_rate                          true    true          STRING    "0 Mbps"                        NOVAL                                                        true                                   false                       NOVAL         NOVAL         NOVAL                                     NOVAL                                                   ::altera_xcvr_native_cv::parameters::validate_pll_data_rate                       NOVAL}\
    {pll_type                               true    true          STRING    "CMU"                           NOVAL                                                        true                                   false                       NOVAL         NOVAL         NOVAL                                     NOVAL                                                   ::altera_xcvr_native_cv::parameters::validate_pll_type                            NOVAL}\
    {pma_bonding_mode                       true    true          STRING    "x1"                            NOVAL                                                        true                                   false                       NOVAL         NOVAL         NOVAL                                     NOVAL                                                   ::altera_xcvr_native_cv::parameters::validate_pma_bonding_mode                    NOVAL       } \
    {plls                                   false   true          INTEGER   1                               {1 2 3 4}                                                    tx_enable                              tx_enable                   NOVAL         NOVAL         "TX PMA"                                  "Number of TX PLLs"                                     ::altera_xcvr_native_cv::parameters::validate_plls                                "Specifies the desired number of TX PLLs to use for dynamic PLL switching. The number of logical TX PLLs created in the netlist depends on the number of channels and selected TX bonding method."}\
    {pll_select                             false   true          INTEGER   0                               {0}                                                          tx_enable                              tx_enable                   NOVAL         NOVAL         "TX PMA"                                  "Main TX PLL logical index"                             ::altera_xcvr_native_cv::parameters::validate_pll_select                          "Specifies the initially selected TX PLL."}\
    {pll_refclk_cnt                         false   true          INTEGER   1                               {1 2 3 4 5}                                                  tx_enable                              tx_enable                   NOVAL         NOVAL         "TX PMA"                                  "Number of TX PLL reference clocks"                     ::altera_xcvr_native_cv::parameters::validate_pll_refclk_cnt                      "Specifies the number of input reference clocks for the TX PLLs. The same bus of reference clocks will feed all TX PLLs in the netlist."}\
    {pll_refclk_select                      true    true          STRING    "0"                             NOVAL                                                        true                                   false                       NOVAL         NOVAL         NOVAL                                     NOVAL                                                   ::altera_xcvr_native_cv::parameters::validate_pll_refclk_select                   NOVAL}\
    {pll_refclk_freq                        true    true          STRING    "125.0 MHz"                     NOVAL                                                        true                                   false                       NOVAL         NOVAL         NOVAL                                     NOVAL                                                   ::altera_xcvr_native_cv::parameters::validate_pll_refclk_freq                     NOVAL}\
    {pll_feedback_path                      true    true          STRING    "internal"                      {internal external}                                          true                                   false                       NOVAL         NOVAL         "TX PMA"                                  NOVAL                                                   NOVAL                                                                             NOVAL}\
    \
    {cdr_reconfig_enable                    false   true          INTEGER   0                               NOVAL                                                        rx_enable                              rx_enable                   boolean       NOVAL         "RX PMA"                                  "Enable CDR dynamic reconfiguration"                    NOVAL                                                                             "When selected, the simulation model for the RX CDR will support dynamic reconfiguration. Dynamic reconfiguration includes data rate reconfiguration. This option is not required to simulate CDR reference clock switching."}\
    {cdr_refclk_cnt                         false   true          INTEGER   1                               {1 2 3 4 5}                                                  rx_enable                              rx_enable                   NOVAL         NOVAL         "RX PMA"                                  "Number of CDR reference clocks"                        NOVAL                                                                             "Specifies the number of input reference clocks for the RX CDRs. The same bus of reference clocks will feed all RX CDRs in the netlist."}\
    {cdr_refclk_select                      false   true          INTEGER   0                               {0}                                                          rx_enable                              rx_enable                   NOVAL         NOVAL         "RX PMA"                                  "Selected CDR reference clock"                          ::altera_xcvr_native_cv::parameters::validate_cdr_refclk_select                   "Specifies the initially selected reference clock input to the RX CDRs."}\
    {cdr_refclk_freq                        true    true          STRING    NOVAL                           NOVAL                                                        rx_enable                              false                       NOVAL         NOVAL         NOVAL                                     NOVAL                                                   ::altera_xcvr_native_cv::parameters::validate_cdr_refclk_freq                     NOVAL}\
    {set_cdr_refclk_freq                    false   false         STRING    "125.0 MHz"                     NOVAL                                                        rx_enable                              rx_enable                   NOVAL         NOVAL         "RX PMA"                                  "Selected CDR reference clock frequency"                ::altera_xcvr_native_cv::parameters::validate_set_cdr_refclk_freq                 "Specifies the frequency in Mbps of the selected reference clock input to the CDR."}\
    {rx_ppm_detect_threshold                false   true          STRING    "1000"                          {62 100 125 200 250 300 500 1000}                            rx_enable                              rx_enable                   NOVAL         PPM           "RX PMA"                                  "PPM detector threshold"                                NOVAL                                                                             "Specifies the tolerable different in PPM between the RX CDR reference clock and the recovered clock from the RX data input."}\
    {enable_port_rx_pma_clkout              false   false         INTEGER   1                               NOVAL                                                        rx_enable                              rx_enable                   boolean       NOVAL         "RX PMA"                                  "Enable rx_pma_clkout port"                             NOVAL                                                                             "Enables the rx_pma_clkout clock port. This is the recovered RX parallel clock from the RX PMA. This clock is typically used to clock the RX datapath when the transceiver is configured for pma_direct mode."}\
    {enable_port_rx_is_lockedtodata         false   false         INTEGER   1                               NOVAL                                                        rx_enable                              rx_enable                   boolean       NOVAL         "RX PMA"                                  "Enable rx_is_lockedtodata port"                        NOVAL                                                                             "Enables the optional rx_is_lockedtodata status output port. This signal indicates that the RX CDR is currently in lock to data mode or is attempting to lock to the incoming data stream. This is an asynchronous output signal."}\
    {enable_port_rx_is_lockedtoref          false   false         INTEGER   1                               NOVAL                                                        rx_enable                              rx_enable                   boolean       NOVAL         "RX PMA"                                  "Enable rx_is_lockedtoref port"                         NOVAL                                                                             "Enables the optional rx_is_lockedtoref status output port. This signal indicates that the RX CDR is currently locked to the CDR reference clock. This is an asynchronous output signal."}\
    {enable_ports_rx_manual_cdr_mode        false   false         INTEGER   1                               NOVAL                                                        rx_enable                              rx_enable                   boolean       NOVAL         "RX PMA"                                  "Enable rx_set_locktodata and rx_set_locktoref ports"   NOVAL                                                                             "Enables the optional rx_set_locktodata and rx_set_locktoref control input ports. These ports are used to manually control the lock mode of the RX CDR. These are asynchonous input signals."}\
    {rx_clkslip_enable                      false   true          INTEGER   0                               NOVAL                                                        rx_enable                              rx_enable                   boolean       NOVAL         "RX PMA"                                  "Enable rx_pma_bitslip port"                            NOVAL                                                                             "Enables the optional rx_pma_bitslip control input port. The deserializer slips one clock edge each time this signal is asserted. This is an asynchronous input signal."}\
    {enable_port_rx_signaldetect            false   false         INTEGER   0                               NOVAL                                                        rx_enable                              false                       boolean       NOVAL         "RX PMA"                                  "Enable rx_signaldetect port"                           NOVAL                                                                             "Enables the optional rx_signaldetect status output port. The assertion of this signal indicates detection of an input signal to the RX PMA. Refer to the device handbook for applications and limitations. This is an asynchronous output signal."}\
    {enable_port_rx_seriallpbken            false   false         INTEGER   0                               NOVAL                                                        true                                   true                        boolean       NOVAL         "RX PMA"                                  "Enable rx_seriallpbken port"                           ::altera_xcvr_native_cv::parameters::validate_enable_port_rx_seriallpbken         "When you enable this option, the rx_seriallpbken port is provided as an input. This signal enables the TX to RX serial loopback path within the transceiver. This is an asynchronous input signal."}\
    \
    {std_protocol_hint                      false   true          STRING    "basic"                         {basic cpri cpri_rx_tx gige}                                 enable_std                             enable_std                  NOVAL         NOVAL         "Standard PCS"                            "Standard PCS protocol mode"                            NOVAL                                                                             "Specifies the protocol mode for the current'Standard PCS' configuration. The protocol mode is used to govern the legal settings for parameters within the 'Standard PCS' datapath. Refer to the user guide for guidelines on which protocol mode to use for specific HSSI protocols."}\
    {std_pcs_pma_width                      false   true          INTEGER   10                              {8 10 16 20}                                                 enable_std                             enable_std                  NOVAL         NOVAL         "Standard PCS"                            "Standard PCS / PMA interface width"                    ::altera_xcvr_native_cv::parameters::validate_std_pcs_pma_width                   "Specifies the data interface width between the 'Standard PCS' and the transceiver PMA."}\
    {std_tx_pld_pcs_width                   true    false         INTEGER   NOVAL                           NOVAL                                                        l_enable_tx_std                        l_enable_tx_std             NOVAL         NOVAL         "Standard PCS"                            "FPGA fabric / Standard TX PCS interface width"         ::altera_xcvr_native_cv::parameters::validate_std_tx_pld_pcs_width                "Indicates the data inerface width between the Standard TX PCS and the FPGA fabric. This value is determined by the current configuration of individual blocks within the Standard TX PCS."}\
    {std_rx_pld_pcs_width                   true    false         INTEGER   NOVAL                           NOVAL                                                        l_enable_rx_std                        l_enable_rx_std             NOVAL         NOVAL         "Standard PCS"                            "FPGA fabric / Standard RX PCS interface width"         ::altera_xcvr_native_cv::parameters::validate_std_rx_pld_pcs_width                "Indicates the data inerface width between the Standard RX PCS and the FPGA fabric. This value is determined by the current configuration of individual blocks within the Standard RX PCS."}\
    {std_low_latency_bypass_enable          false   true          INTEGER   0                               NOVAL                                                        enable_std                             enable_std                  boolean       NOVAL         "Standard PCS"                            "Enable 'Standard PCS' low latency mode"                ::altera_xcvr_native_cv::parameters::validate_std_low_latency_bypass_enable       "Enables the low latency path for the 'Standard PCS'. Enabling this option will bypass the individual functional blocks within the 'Standard PCS' to provide the lowest latency datapath from the PMA through the 'Standard PCS'."}\
    \
    {std_tx_pcfifo_mode                     false   true          STRING    "low_latency"                   {low_latency register_fifo}                                  l_enable_tx_std                        l_enable_tx_std             NOVAL         NOVAL         "Phase Compensation FIFO"                 "TX FIFO mode"                                          ::altera_xcvr_native_cv::parameters::validate_std_tx_pcfifo_mode                  "Specifies the mode for the 'Standard PCS' TX FIFO."}\
    {std_rx_pcfifo_mode                     false   true          STRING    "low_latency"                   {low_latency register_fifo}                                  l_enable_rx_std                        l_enable_rx_std             NOVAL         NOVAL         "Phase Compensation FIFO"                 "RX FIFO mode"                                          ::altera_xcvr_native_cv::parameters::validate_std_rx_pcfifo_mode                  "Specifies the mode for the 'Standard PCS' RX FIFO."}\
    {enable_port_tx_std_pcfifo_full         false   false         INTEGER   0                               NOVAL                                                        l_enable_tx_std                        l_enable_tx_std             boolean       NOVAL         "Phase Compensation FIFO"                 "Enable tx_std_pcfifo_full port"                        NOVAL                                                                             "Enables the optional tx_std_pcfifo_full status output port. This signal indicates when the standard TX phase compensation FIFO has reached the full threshold. This signal is synchronous with 'tx_std_clkout'."}\
    {enable_port_tx_std_pcfifo_empty        false   false         INTEGER   0                               NOVAL                                                        l_enable_tx_std                        l_enable_tx_std             boolean       NOVAL         "Phase Compensation FIFO"                 "Enable tx_std_pcfifo_empty port"                       NOVAL                                                                             "Enables the optional tx_std_pcfifo_empty status output port. This signal indicates when the standard RX phase compensation FIFO has reached the empty threshold. This signal is synchronous with 'tx_std_clkout'."}\
    {enable_port_rx_std_pcfifo_full         false   false         INTEGER   0                               NOVAL                                                        l_enable_rx_std                        l_enable_rx_std             boolean       NOVAL         "Phase Compensation FIFO"                 "Enable rx_std_pcfifo_full port"                        NOVAL                                                                             "Enables the optional rx_std_pcfifo_full status output port. This signal indicates when the standard RX phase compensation FIFO has reached the full threshold. This signal is synchronous with 'rx_std_clkout'."}\
    {enable_port_rx_std_pcfifo_empty        false   false         INTEGER   0                               NOVAL                                                        l_enable_rx_std                        l_enable_rx_std             boolean       NOVAL         "Phase Compensation FIFO"                 "Enable rx_std_pcfifo_empty port"                       NOVAL                                                                             "Enables the optional rx_std_pcfifo_empty status output port. This signal indicates when the standard RX phase compensation FIFO has reached the full threshold. This signal is synchronous with 'rx_std_clkout'."}\
    \
    {std_rx_byte_order_enable               false   true          INTEGER   0                               NOVAL                                                        l_enable_rx_std                        l_enable_rx_std             boolean       NOVAL         "Byte Ordering"                           "Enable RX byte ordering"                               ::altera_xcvr_native_cv::parameters::validate_std_rx_byte_order_enable            "Enables the RX byte ordering block within the Standard RX PCS. The byte ordering block can optionally be engaged when the PCS byte deserializer is active. The byte ordering block can identify a specified symbol pattern in the data stream and move that data pattern to the lower LSB's of the output data interface."}\
    {std_rx_byte_order_mode                 false   true          STRING    "manual"                        {manual auto}                                                std_rx_byte_order_enable               l_enable_rx_std             NOVAL         NOVAL         "Byte Ordering"                           "Byte ordering control mode"                            ::altera_xcvr_native_cv::parameters::validate_std_rx_byte_order_mode              "Specifies the control mode for the RX byte ordering block. The byte ordering block can be controlled by the user or can be controlled automatically by the PCS word aligner block once word alignment is achieved."}\
    {std_rx_byte_order_width                true    true          INTEGER   10                              {8 9 10}                                                     std_rx_byte_order_enable               l_enable_rx_std             NOVAL         NOVAL         "Byte Ordering"                           "Byte ordering pattern width"                           ::altera_xcvr_native_cv::parameters::validate_std_rx_byte_order_width             "Specifies the byte order pattern symbol pattern width. This is the width of the data symbol pattern that the byte order block will search for."}\
    {std_rx_byte_order_symbol_count         false   true          INTEGER   1                               {1 2}                                                        std_rx_byte_order_enable               l_enable_rx_std             NOVAL         NOVAL         "Byte Ordering"                           "Byte ordering symbol count"                            ::altera_xcvr_native_cv::parameters::validate_std_rx_byte_order_symbol_count      "Specifies the number of symbols for the word aligner block to search for. When the PMA is configured for a width of 16 or 20 bits, the byte ordering block can optionally search for 1 or 2 symbols."}\
    {std_rx_byte_order_pattern              false   true          STRING    "0"                             NOVAL                                                        std_rx_byte_order_enable               l_enable_rx_std             NOVAL         NOVAL         "Byte Ordering"                           "Byte order pattern (hex)"                              ::altera_xcvr_native_cv::parameters::validate_std_rx_byte_order_pattern           "Specifies the search pattern for the byte ordering block."}\
    {std_rx_byte_order_pad                  false   true          STRING    "0"                             NOVAL                                                        std_rx_byte_order_enable               l_enable_rx_std             NOVAL         NOVAL         "Byte Ordering"                           "Byte order pad value (hex)"                            ::altera_xcvr_native_cv::parameters::validate_std_rx_byte_order_pad               "Specifies the pad value to be inserted by the byte order block. This is the data that will be inserted when the byte order pattern is recognized."}\
    {enable_port_rx_std_byteorder_ena       false   false         INTEGER   0                               NOVAL                                                        l_enable_rx_std                        l_enable_rx_std             boolean       NOVAL         "Byte Ordering"                           "Enable rx_std_byteorder_ena port"                      NOVAL                                                                             "Enables the optional rx_std_byteorder_ena control input port. The assertion of this signal will cause the byte ordering block to perform byte ordering when the is configured in 'manual' mode. Once byte ordering has occurred, this signal must be deasserted and reasserted to perform a subsequent byte ordering operation. This is an asynchronous input signal but must be asserted for at least one cycle of 'rx_std_clkout'"}\
    {enable_port_rx_std_byteorder_flag      false   false         INTEGER   0                               NOVAL                                                        l_enable_rx_std                        l_enable_rx_std             boolean       NOVAL         "Byte Ordering"                           "Enable rx_std_byteorder_flag port"                     NOVAL                                                                             "Enables the optional rx_std_byteorder_flag status output port. The assertion of this signal indicates that the byte ordering block performed a byte order operation. The signal is asserted on the clock cycle in which byte ordering occurred. This signal is synchronous with 'rx_std_clkout'."}\
    \
    {std_tx_byte_ser_enable                 false   true          INTEGER   0                               NOVAL                                                        l_enable_tx_std                        l_enable_tx_std             boolean       NOVAL         "Byte Serializer and Deserializer"        "Enable TX byte serializer"                             ::altera_xcvr_native_cv::parameters::validate_std_tx_byte_ser_enable              "Enables the TX byte serializer in the 'Standard PCS'. The transceiver architecture allows the 'Standard PCS' to operate at double the data width of the PMA serializer. This allows the PCS to run at a lower internal clock frequency and accommodate a wider range of FPGA interface widths."}\
    {std_rx_byte_deser_enable               false   true          INTEGER   0                               NOVAL                                                        l_enable_rx_std                        l_enable_rx_std             boolean       NOVAL         "Byte Serializer and Deserializer"        "Enable RX byte deserializer"                           ::altera_xcvr_native_cv::parameters::validate_std_rx_byte_deser_enable            "Enables the RX byte deserializer in the 'Standard PCS' The transceiver architecture allows the 'Standard PCS' to operate at double the data width of the PMA deserializer. This allows the PCS to run at a lower internal clock frequency and accommodate a wider range of FPGA interface widths."}\
    \
    {std_tx_8b10b_enable                    false   true          INTEGER   0                               NOVAL                                                        l_enable_tx_std                        l_enable_tx_std             boolean       NOVAL         "8B/10B Encoder and Decoder"              "Enable TX 8b/10b encoder"                               ::altera_xcvr_native_cv::parameters::validate_std_tx_8b10b_enable                 "Enables the 8b10b encoder in the 'Standard PCS'."}\
    {std_tx_8b10b_disp_ctrl_enable          false   true          INTEGER   0                               NOVAL                                                        l_enable_tx_std                        l_enable_tx_std             boolean       NOVAL         "8B/10B Encoder and Decoder"              "Enable TX 8b/10b disparity control"                     ::altera_xcvr_native_cv::parameters::validate_std_tx_8b10b_disp_ctrl_enable       "Enables disparity control for the 8b/10b encoder. This allows you to force the disparity of the 8b/10b encoder via the 'tx_forcedisp' control signal."}\
    {std_rx_8b10b_enable                    false   true          INTEGER   0                               NOVAL                                                        l_enable_rx_std                        l_enable_rx_std             boolean       NOVAL         "8B/10B Encoder and Decoder"              "Enable RX 8b/10b decoder"                               ::altera_xcvr_native_cv::parameters::validate_std_rx_8b10b_enable                 "Enables the 8b10b decoder in the 'Standard PCS'."}\
    \
    {std_rx_rmfifo_enable                   false   true          INTEGER   0                               NOVAL                                                        l_enable_rx_std                        l_enable_rx_std             boolean       NOVAL         "Rate Match FIFO"                         "Enable RX rate match FIFO"                             ::altera_xcvr_native_cv::parameters::validate_std_rx_rmfifo_enable                "Enables the RX rate match FIFO in the 'Standard PCS'."}\
    {std_rx_rmfifo_pattern_p                false   true          STRING    "00000"                         NOVAL                                                        std_rx_rmfifo_enable                   l_enable_rx_std             NOVAL         NOVAL         "Rate Match FIFO"                         "RX rate match insert/delete +ve pattern (hex)"         ::altera_xcvr_native_cv::parameters::validate_std_rx_rmfifo_pattern_p             "Specifies the +ve (positive) disparity value for the RX rate match FIFO. The value is 20-bits and specified as a hexadecimal string."}\
    {std_rx_rmfifo_pattern_n                false   true          STRING    "00000"                         NOVAL                                                        std_rx_rmfifo_enable                   l_enable_rx_std             NOVAL         NOVAL         "Rate Match FIFO"                         "RX rate match insert/delete -ve pattern (hex)"         ::altera_xcvr_native_cv::parameters::validate_std_rx_rmfifo_pattern_n             "Specifies the -ve (negative) disparity value for the RX rate match FIFO. The value is 20-bits and specified as a hexadecimal string."}\
    {enable_port_rx_std_rmfifo_full         false   false         INTEGER   0                               NOVAL                                                        l_enable_rx_std                        l_enable_rx_std             boolean       NOVAL         "Rate Match FIFO"             		      "Enable rx_std_rmfifo_full port"                        NOVAL                                                                             "Enables the optional rx_std_rmfifo_full status output port. This signal indicates when the standard RX rate match FIFO has reached the full threshold."}\
    {enable_port_rx_std_rmfifo_empty        false   false         INTEGER   0                               NOVAL                                                        l_enable_rx_std                        l_enable_rx_std             boolean       NOVAL         "Rate Match FIFO"                         "Enable rx_std_rmfifo_empty port"                       NOVAL                                                                             "Enables the optional rx_std_rmfifo_empty status output port. This signal indicates when the standard RX rate match FIFO has reached the full threshold."}\
    \
    {std_tx_bitslip_enable                  false   true          INTEGER   0                               NOVAL                                                        l_enable_tx_std                        l_enable_tx_std             boolean       NOVAL         "Word Aligner and Bitslip"                "Enable TX bitslip"                                     ::altera_xcvr_native_cv::parameters::validate_std_tx_bitslip_enable               "Enable TX bitslip support. When enabled, the outgoing transmit data can be slipped a specific number of bits as specified by the 'tx_bitslipboundarysel' control signal."}\
    {enable_port_tx_std_bitslipboundarysel  false   false         INTEGER   0                               NOVAL                                                        l_enable_tx_std                        l_enable_tx_std             boolean       NOVAL         "Word Aligner and Bitslip"                "Enable tx_std_bitslipboundarysel port"                 NOVAL                                                                             "Enables the optional tx_std_bitslipboundarysel control input port."}\
    {std_rx_word_aligner_mode               false   true          STRING    "bit_slip"                      {bit_slip sync_sm manual}                                    l_enable_rx_std                        l_enable_rx_std             NOVAL         NOVAL         "Word Aligner and Bitslip"                "RX word aligner mode"                                  ::altera_xcvr_native_cv::parameters::validate_std_rx_word_aligner_mode            "Specifies the RX word aligner mode for the 'Standard PCS'."}\
    {std_rx_word_aligner_pattern_len        false   true          INTEGER   7                               {7 8 10 16 20 32 40}                                         l_enable_rx_std_word_aligner           l_enable_rx_std             NOVAL         NOVAL         "Word Aligner and Bitslip"                "RX word aligner pattern length"                        ::altera_xcvr_native_cv::parameters::validate_std_rx_word_aligner_pattern_len     "Specifies the RX word alignment pattern length."}\
    {std_rx_word_aligner_pattern            false   true          STRING    "0000000000"                    NOVAL                                                        l_enable_rx_std_word_aligner           l_enable_rx_std             NOVAL         NOVAL         "Word Aligner and Bitslip"                "RX word aligner pattern (hex)"                         ::altera_xcvr_native_cv::parameters::validate_std_rx_word_aligner_pattern         "Specifies the RX word alignment pattern."}\
    {std_rx_word_aligner_rknumber           false   true          INTEGER   3                               "0:255"                                                      l_enable_rx_std_word_aligner           l_enable_rx_std             NOVAL         NOVAL         "Word Aligner and Bitslip"                "Number of word alignment patterns to achieve sync."    ::altera_xcvr_native_cv::parameters::validate_std_rx_word_aligner_rknumber        "Specifies the number of valid word alignment patterns that must be received before the word aligner achieves sync lock."}\
    {std_rx_word_aligner_renumber           false   true          INTEGER   3                               "0:63"                                                       l_enable_rx_std_word_aligner           l_enable_rx_std             NOVAL         NOVAL         "Word Aligner and Bitslip"                "Number of invalid data words to lose sync."            ::altera_xcvr_native_cv::parameters::validate_std_rx_word_aligner_renumber        "Specifies the number of invalid data codes or disparity errors that must be received before the word aligner loses sync lock."}\
    {std_rx_word_aligner_rgnumber           false   true          INTEGER   3                               "0:255"                                                      l_enable_rx_std_word_aligner           l_enable_rx_std             NOVAL         NOVAL         "Word Aligner and Bitslip"                "Number of valid data words to decrement error count."  ::altera_xcvr_native_cv::parameters::validate_std_rx_word_aligner_rgnumber        "Specifies the number of valid data codes that must be received to decrement the error counter. If enough valid data codes are received to decrement the error count to zero, the word aligner will return to sync lock."}\
    {std_rx_run_length_val                  false   true          INTEGER   31                              "0:63"                                                       l_enable_rx_std_word_aligner           l_enable_rx_std             NOVAL         NOVAL         "Word Aligner and Bitslip"                "Run length detector word count"                        ::altera_xcvr_native_cv::parameters::validate_std_rx_run_length_val               "Specifies the number of consecutive received words from the PMA containing no 1>0 or 0>1 transitions that will trigger a run length violation."}\
    {enable_port_rx_std_wa_patternalign     false   false         INTEGER   0                               NOVAL                                                        l_enable_rx_std                        l_enable_rx_std             boolean       NOVAL         "Word Aligner and Bitslip"                "Enable rx_std_wa_patternalign port"                    NOVAL                                                                             "Enables the optional rx_std_wa_patternalign control input port. A rising edge on this signal will cause the word aligner to align to the next incoming word alignment pattern when the word aligner is configured in \"manual\" mode."}\
    {enable_port_rx_std_wa_a1a2size         false   false         INTEGER   0                               NOVAL                                                        l_enable_rx_std                        l_enable_rx_std             boolean       NOVAL         "Word Aligner and Bitslip"                "Enable rx_std_wa_a1a2size port"                        NOVAL                                                                             "Enables the optional rx_std_a1a2size control input port."}\
    {enable_port_rx_std_bitslipboundarysel  false   false         INTEGER   0                               NOVAL                                                        l_enable_rx_std                        l_enable_rx_std             boolean       NOVAL         "Word Aligner and Bitslip"                "Enable rx_std_bitslipboundarysel port"                 NOVAL                                                                             "Enables the optional rx_std_bitslipboundarysel status output port."}\
    {enable_port_rx_std_bitslip             false   false         INTEGER   0                               NOVAL                                                        l_enable_rx_std                        l_enable_rx_std             boolean       NOVAL         "Word Aligner and Bitslip"                "Enable rx_std_bitslip port"                            ::altera_xcvr_native_cv::parameters::validate_enable_port_rx_std_bitslip          "Enables the optional rx_std_bitslip control input port. The rising-edge assertion of this port will cause a single bit slip in the received RX parallel data. The signal should be held high for at least three RX parallel clock cycles and must be deasserted before performing another bit slip. This signal has no effect when the PCS is configured in low latency mode."}\
    {enable_port_rx_std_runlength_err       false   false         INTEGER   0                               NOVAL                                                        l_enable_rx_std                        l_enable_rx_std             boolean       NOVAL         "Word Aligner and Bitslip"                "Enable rx_std_runlength_err port"                      NOVAL                                                                             "Enables the optional rx_std_runlength_err control input port."}\
    \
    {std_tx_bitrev_enable                   false   true          INTEGER   0                               NOVAL                                                        l_enable_tx_std                        l_enable_tx_std             boolean       NOVAL         "Bit Reversal and Polarity Inversion"     "Enable TX bit reversal"                                ::altera_xcvr_native_cv::parameters::validate_std_tx_bitrev_enable                "Enables transmitter bit order reversal. When enabled the TX parallel data will be reversed before passing to the PMA for serialization. When bit reversal is activated, the transmitted TX data bit order flipped to MSB->LSB rather than the normal LSB->MSB. This is a static setting and can only be dynamically changed through dynamic reconfiguration."}\
    {std_rx_bitrev_enable                   false   true          INTEGER   0                               NOVAL                                                        l_enable_rx_std                        l_enable_rx_std             boolean       NOVAL         "Bit Reversal and Polarity Inversion"     "Enable RX bit reversal"                                ::altera_xcvr_native_cv::parameters::validate_std_rx_bitrev_enable                "Enables receiver bit order reversal. When enabled, the 'rx_std_bitrev_ena' control port controls bit reversal of the RX parallel data after passing from the PMA to the PCS. When bit reversal is activated, the received RX data bit order is flipped to MSB->LSB rather than the normal LSB->MSB"}\
    {std_tx_byterev_enable                  false   true          INTEGER   0                               NOVAL                                                        l_enable_tx_std                        l_enable_tx_std             boolean       NOVAL         "Bit Reversal and Polarity Inversion"     "Enable TX byte reversal"                               ::altera_xcvr_native_cv::parameters::validate_std_tx_byterev_enable               "Enables transmitter byte order reversal. When the PCS / PMA interface width is 16 or 20 bits, the PCS can swap the ordering of the individual 8- or 10-bit words. This option is not allowed under all protocol modes."}\
    {std_rx_byterev_enable                  false   true          INTEGER   0                               NOVAL                                                        l_enable_rx_std                        l_enable_rx_std             boolean       NOVAL         "Bit Reversal and Polarity Inversion"     "Enable RX byte reversal"                               ::altera_xcvr_native_cv::parameters::validate_std_rx_byterev_enable               "Enables receiver byte order reversal. When the PCS / PMA interface width is 16 or 20 bits, the PCS can swap the ordering of the individual 8 or 10 bit words. This option is not allowed under all protocol modes."}\
    {std_tx_polinv_enable                   false   true          INTEGER   0                               NOVAL                                                        l_enable_tx_std                        l_enable_tx_std             boolean       NOVAL         "Bit Reversal and Polarity Inversion"     "Enable TX polarity inversion"                          NOVAL                                                                             "Enables TX bit polarity inversion. When enabled, the 'tx_std_polinv' control port controls polarity inversion of the TX parallel data bits before passing to the PMA."}\
    {std_rx_polinv_enable                   false   true          INTEGER   0                               NOVAL                                                        l_enable_rx_std                        l_enable_rx_std             boolean       NOVAL         "Bit Reversal and Polarity Inversion"     "Enable RX polarity inversion"                          NOVAL                                                                             "Enables RX bit polarity inversion. When enabled, the 'rx_std_polinv' control port controls polarity inversion of the RX parallel data bits after passing from the PMA."}\
    {enable_port_rx_std_bitrev_ena          false   false         INTEGER   0                               NOVAL                                                        l_enable_rx_std                        l_enable_rx_std             boolean       NOVAL         "Bit Reversal and Polarity Inversion"     "Enable rx_std_bitrev_ena port"                         ::altera_xcvr_native_cv::parameters::validate_enable_port_rx_std_bitrev_ena       "Enables the optional rx_std_bitrev_ena control input port. When receiver bit order reversal is enabled, the assertion of this signal will cause the received RX data bit order to be flipped to MSB->LSB rather than the normal LSB->MSB. This is an asynchronous input signal."}\
    {enable_port_rx_std_byterev_ena         false   false         INTEGER   0                               NOVAL                                                        l_enable_rx_std                        l_enable_rx_std             boolean       NOVAL         "Bit Reversal and Polarity Inversion"     "Enable rx_std_byterev_ena port"                        ::altera_xcvr_native_cv::parameters::validate_enable_port_rx_std_byterev_ena      "Enables the optional rx_std_byterev_ena control input port. When receiver byte order reversal is enabled, the assertion of this signal will swap the order of individual 8- or 10-bit words received from the PMA."}\
    {enable_port_tx_std_polinv              false   false         INTEGER   0                               NOVAL                                                        l_enable_tx_std                        l_enable_tx_std             boolean       NOVAL         "Bit Reversal and Polarity Inversion"     "Enable tx_std_polinv port"                             ::altera_xcvr_native_cv::parameters::validate_enable_port_tx_std_polinv           "Enables the optional tx_std_polinv control input port. When TX bit polarity inversion is enabled, the assertion of this signal will cause the TX bit polarity to be inverted."}\
    {enable_port_rx_std_polinv              false   false         INTEGER   0                               NOVAL                                                        l_enable_rx_std                        l_enable_rx_std             boolean       NOVAL         "Bit Reversal and Polarity Inversion"     "Enable rx_std_polinv port"                             ::altera_xcvr_native_cv::parameters::validate_enable_port_rx_std_polinv           "Enables the optional rx_std_polinv control input port. When RX bit polarity inversion is enabled, the assertion of this signal will cause the RX bit polarity to be inverted."}\
    {enable_port_tx_std_elecidle            false   false         INTEGER   0                               NOVAL                                                        l_enable_tx_std                        l_enable_tx_std             boolean       NOVAL         "Bit Reversal and Polarity Inversion"     "Enable tx_std_elecidle port"                           NOVAL                                                                             "Enables the optional tx_std_elecidle control input port. The assertion of this signal will force the transmitter into an electrical idle condition."}\
    {enable_port_rx_std_signaldetect        false   false         INTEGER   0                               NOVAL                                                        l_enable_rx_std                        l_enable_rx_std             boolean       NOVAL         "Bit Reversal and Polarity Inversion"     "Enable rx_std_signaldetect port"                       NOVAL                                                                             "Enables the optional rx_std_signaldetect status output port. The assertion of this signal indicates that a signal has been detected on the receiver. The signal detect threshold can be specified through Quartus II QSF assignments."}\
    \
    {l_pll_settings                         true    false         INTEGER   0                               NOVAL                                                        true                                   false                       NOVAL         NOVAL         NOVAL                                     NOVAL                                                   ::altera_xcvr_native_cv::parameters::validate_l_pll_settings                      NOVAL}\
    {l_enable_tx_pma_direct                 true    false         INTEGER   0                               NOVAL                                                        true                                   false                       NOVAL         NOVAL         NOVAL                                     NOVAL                                                   ::altera_xcvr_native_cv::parameters::validate_l_enable_tx_pma_direct              NOVAL}\
    {l_enable_rx_pma_direct                 true    false         INTEGER   0                               NOVAL                                                        true                                   false                       NOVAL         NOVAL         NOVAL                                     NOVAL                                                   ::altera_xcvr_native_cv::parameters::validate_l_enable_rx_pma_direct              NOVAL}\
    {l_enable_tx_std                        true    false         INTEGER   0                               NOVAL                                                        true                                   false                       NOVAL         NOVAL         NOVAL                                     NOVAL                                                   ::altera_xcvr_native_cv::parameters::validate_l_enable_tx_std                     NOVAL}\
    {l_enable_rx_std                        true    false         INTEGER   0                               NOVAL                                                        true                                   false                       NOVAL         NOVAL         NOVAL                                     NOVAL                                                   ::altera_xcvr_native_cv::parameters::validate_l_enable_rx_std                     NOVAL}\
    {l_enable_rx_std_word_aligner           true    false         INTEGER   0                               NOVAL                                                        true                                   false                       NOVAL         NOVAL         NOVAL                                     NOVAL                                                   ::altera_xcvr_native_cv::parameters::validate_l_enable_rx_std_word_aligner        NOVAL}\
    {l_netlist_plls                         true    false         INTEGER   0                               NOVAL                                                        true                                   false                       NOVAL         NOVAL         NOVAL                                     NOVAL                                                   ::altera_xcvr_native_cv::parameters::validate_l_netlist_plls                      NOVAL}\
    {l_rcfg_interfaces                      true    false         INTEGER   0                               NOVAL                                                        true                                   false                       NOVAL         NOVAL         NOVAL                                     NOVAL                                                   ::altera_xcvr_native_cv::parameters::validate_l_rcfg_interfaces                   NOVAL}\
    {l_rcfg_to_xcvr_width                   true    false         INTEGER   0                               NOVAL                                                        true                                   false                       NOVAL         NOVAL         NOVAL                                     NOVAL                                                   ::altera_xcvr_native_cv::parameters::validate_l_rcfg_to_xcvr_width                NOVAL}\
    {l_rcfg_from_xcvr_width                 true    false         INTEGER   0                               NOVAL                                                        true                                   false                       NOVAL         NOVAL         NOVAL                                     NOVAL                                                   ::altera_xcvr_native_cv::parameters::validate_l_rcfg_from_xcvr_width              NOVAL}\
    {l_pma_direct_word_count                true    false         INTEGER   0                               NOVAL                                                        true                                   false                       NOVAL         NOVAL         NOVAL                                     NOVAL                                                   ::altera_xcvr_native_cv::parameters::validate_l_pma_direct_word_count             NOVAL}\
    {l_pma_direct_word_width                true    false         INTEGER   0                               NOVAL                                                        true                                   false                       NOVAL         NOVAL         NOVAL                                     NOVAL                                                   ::altera_xcvr_native_cv::parameters::validate_l_pma_direct_word_width             NOVAL}\
    {l_std_tx_word_count                    true    false         INTEGER   0                               NOVAL                                                        true                                   false                       NOVAL         NOVAL         NOVAL                                     NOVAL                                                   ::altera_xcvr_native_cv::parameters::validate_l_std_tx_word_count                 NOVAL}\
    {l_std_tx_word_width                    true    false         INTEGER   0                               NOVAL                                                        true                                   false                       NOVAL         NOVAL         NOVAL                                     NOVAL                                                   ::altera_xcvr_native_cv::parameters::validate_l_std_tx_word_width                 NOVAL}\
    {l_std_tx_field_width                   true    false         INTEGER   0                               NOVAL                                                        true                                   false                       NOVAL         NOVAL         NOVAL                                     NOVAL                                                   ::altera_xcvr_native_cv::parameters::validate_l_std_tx_field_width                NOVAL}\
    {l_std_rx_word_count                    true    false         INTEGER   0                               NOVAL                                                        true                                   false                       NOVAL         NOVAL         NOVAL                                     NOVAL                                                   ::altera_xcvr_native_cv::parameters::validate_l_std_rx_word_count                 NOVAL}\
    {l_std_rx_word_width                    true    false         INTEGER   0                               NOVAL                                                        true                                   false                       NOVAL         NOVAL         NOVAL                                     NOVAL                                                   ::altera_xcvr_native_cv::parameters::validate_l_std_rx_word_width                 NOVAL}\
    {l_std_rx_field_width                   true    false         INTEGER   0                               NOVAL                                                        true                                   false                       NOVAL         NOVAL         NOVAL                                     NOVAL                                                   ::altera_xcvr_native_cv::parameters::validate_l_std_rx_field_width                NOVAL}\
  }

  set parameter_upgrade_map {
    {VERSION        OLD_PARAMETER               PARAMETER                   VAL_MAP }\
    {12.0           pma_width                   pma_direct_width            NOVAL   }\
    {12.0           set_rx_signaldetect_enable  enable_port_rx_signaldetect NOVAL   }\
    {12.0           set_rx_seriallpbken_enable  enable_port_rx_seriallpbken NOVAL   }\
  }
}

proc ::altera_xcvr_native_cv::parameters::declare_parameters { {device_family "Cyclone V"} } {
  variable display_items
  variable parameters
  ip_declare_parameters $parameters
  ip_declare_display_items $display_items

  # Initialize device information (to allow sharing of this function across device families)
  ip_set "parameter.device_family.SYSTEM_INFO" DEVICE_FAMILY
  ip_set "parameter.device_family.DEFAULT_VALUE" $device_family
  ip_set "parameter.device_family.ALLOWED_RANGES" [list $device_family]
  ip_set "parameter.device_speedgrade.allowed_ranges" [::alt_xcvr::utils::device::get_device_speedgrades $device_family]
  # Initialize pll_reconfig gui package
  ::alt_xcvr::gui::pll_reconfig::init_pll_defaults "1250 Mbps" "125.0 MHz"
  ::alt_xcvr::gui::pll_reconfig::init_pushdown_main_pll 0
  ::alt_xcvr::gui::pll_reconfig::init_pushdown_tx_pll_counts 1
  ::alt_xcvr::gui::pll_reconfig::init_support_pll_reconfig 0
  ::alt_xcvr::gui::pll_reconfig::init_mapping 0
  ::alt_xcvr::gui::pll_reconfig::initialize "TX PMA" 4 5 0 1 1
  ::alt_xcvr::gui::pll_reconfig::set_config_refclk_count 5
  ::alt_xcvr::gui::pll_reconfig::set_config_allowed_pll_types [::alt_xcvr::utils::device::get_hssi_pll_types $device_family]
  ::alt_xcvr::gui::pll_reconfig::set_config_enable_cdr_refclk_select 0
  ::alt_xcvr::gui::pll_reconfig::set_config_enable_pll_reconfig 0
}

proc ::altera_xcvr_native_cv::parameters::validate {} {
  ::alt_xcvr::ip_tcl::messages::set_auto_message_level [ip_get "parameter.message_level.value"]
  ip_validate_parameters
}


proc ::altera_xcvr_native_cv::parameters::upgrade {ip_name version old_params} {
  variable parameter_upgrade_map
  ip_upgrade $ip_name $version $old_params $parameter_upgrade_map
}


##########################################################################
####################### Validation Callbacks #############################

proc ::altera_xcvr_native_cv::parameters::validate_show_advanced_features { show_advanced_features } {
#  set visible false
#  if { $show_advanced_features } {
#    set visible true
#  }
#  ip_set "parameter.show_advanced_features.visible" $visible
}


proc ::altera_xcvr_native_cv::parameters::validate_channels { device_family channels tx_enable bonded_mode pll_external_enable l_pll_settings pll_select } {
  set main_pll_type [::alt_xcvr::gui::pll_reconfig::get_pll_type $pll_select]
}


proc ::altera_xcvr_native_cv::parameters::validate_rx_enable { tx_enable rx_enable } {
  if {!$tx_enable && !$rx_enable} {
    ip_message error "Either the TX or RX datapath must be enabled"
  }
}


proc ::altera_xcvr_native_cv::parameters::validate_enable_simple_interface { enable_simple_interface enable_std } {
  set legal_values [expr {{0 1}}]

  if {$enable_simple_interface} {
    ip_message info "Simplified data interface has been enabled. The IP core will present the data/control interface for the current configuration only. Dynamic reconfiguration of the data interface cannot be supported."
  }
  auto_invalid_value_message error enable_simple_interface $enable_simple_interface $legal_values { enable_std }
}


proc ::altera_xcvr_native_cv::parameters::validate_pma_bonding_mode { l_pll_settings } {
  ip_set "parameter.pma_bonding_mode.value" [::alt_xcvr::gui::pll_reconfig::get_clk_network_sel_string]
}


proc ::altera_xcvr_native_cv::parameters::validate_set_data_rate { set_data_rate device_family device_speedgrade tx_enable rx_enable message_level data_path_select \
    pma_width \
    std_protocol_hint std_pcs_pma_width std_tx_pcfifo_mode std_rx_pcfifo_mode std_low_latency_bypass_enable std_tx_byte_ser_enable std_rx_byte_deser_enable } {

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
    # 8G PCS data rate validation
    set device [::alt_xcvr::utils::device::get_typical_device $device_family $device_speedgrade]
    set pcs_datapath "EIGHT_G_PCS"
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
    if {$tx_enable} {
      # Required arguments
      #part 
      #txpcspmaif arriav_hssi_tx_pcs_pma_interface selectpcs 
      #txpma arriav_hssi_pma_tx_ser mode 
      #txpma arriav_hssi_pma_tx_ser pma_direct
      #txpcs8g arriav_hssi_8g_tx_pcs prot_mode 
      #txpcs8g arriav_hssi_8g_tx_pcs test_mode
      #txpcs8g arriav_hssi_8g_tx_pcs pma_dw 
      #txpcs8g arriav_hssi_8g_tx_pcs pcs_bypass
      #txpcs8g arriav_hssi_8g_tx_pcs phase_compensation_fifo
      #txpcs8g arriav_hssi_8g_tx_pcs byte_serializer 
      #txpcs8g arriav_hssi_8g_tx_pcs hip_mode
      set arglist [list $device $pcs_datapath $pma_width "false" $std_protocol_hint "dont_care_test" $pcs8g_pma_dw $pcs8g_pcs_bypass $std_tx_pcfifo_mode $pcs8g_tx_byte_serializer "dis_hip"]
         
      set cmd "quartus::advanced_hssi_legality::get_advanced_hssi_legality_legal_values -flow_type MEGAWIZARD -configuration_name ARRIAV_HSSI_CONFIG  -rule_name \
        ARRIAV_HSSI_TX_PCS_DATA_RATE -param_args \{$arglist\}"
      set return_value_PCS [eval $cmd]
      
    } else {
      # Required arguments
      #part 
      #rxpcspmaif arriav_hssi_rx_pcs_pma_interface selectpcs 
      #rxpma arriav_hssi_pma_rx_deser mode 
      #rxpma arriav_hssi_pma_rx_deser pma_direct 
      #rxpcs8g arriav_hssi_8g_rx_pcs prot_mode 
      #rxpcs8g arriav_hssi_8g_rx_pcs test_mode 
      #rxpcs8g arriav_hssi_8g_rx_pcs pma_dw 
      #rxpcs8g arriav_hssi_8g_rx_pcs pcs_bypass 
      #rxpcs8g arriav_hssi_8g_rx_pcs phase_compensation_fifo 
      #rxpcs8g arriav_hssi_8g_rx_pcs byte_deserializer 
      #rxpcs8g arriav_hssi_8g_rx_pcs hip_mode
      set arglist [list $device $pcs_datapath $pma_width "false" $std_protocol_hint "dont_care_test" $pcs8g_pma_dw $pcs8g_pcs_bypass $std_rx_pcfifo_mode $pcs8g_rx_byte_deserializer "dis_hip"] 
      
      set cmd "quartus::advanced_hssi_legality::get_advanced_hssi_legality_legal_values -flow_type MEGAWIZARD -configuration_name ARRIAV_HSSI_CONFIG  -rule_name \
        ARRIAV_HSSI_RX_PCS_DATA_RATE -param_args \{$arglist\}"
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
    regexp -nocase {([0-9.]+).([a-z]+)\.+([0-9.]+).([a-z]+)(.*)} $return_value_PCS match min_rate unit_min max_rate unit_max second_range

    # Check legality
    if { [expr {![info exists min_rate]} || {![info exists max_rate]} ] } {
      ip_message warning "PCS data rate check was not performed. The current configuration may not be legal when compiled in Quartus."
      ::alt_xcvr::gui::messages::internal_error_message "PCS data rate check returned unexpected value $return_value_PCS"
      return
    }

    if { $set_data_rate < $min_rate || $set_data_rate > $max_rate} {
      set range_str "${min_rate} Mbps to ${max_rate} Mbps"
      # parse remaining string for a second range
      set second_range [string replace $second_range 0 0]
      regexp -nocase {([0-9.]+).([a-z]+)\.+([0-9.]+).([a-z]+)} $second_range match min_rate2 unit_min max_rate2 unit_max third_range
      if { [expr {[info exists min_rate2] && [info exists max_rate2] } ] } {
        if {($set_data_rate >= $min_rate2 && $set_data_rate <= $max_rate2)} {
          # Don't issue a message if the value is in the second set of ranges
          return
        } else {
          set range_str "${range_str} and ${min_rate2} Mbps to ${max_rate2} Mbps"
        }
      }
      set message [get_invalid_current_value_string set_data_rate $set_data_rate]
      set message "${message} The value must be in the range of ${range_str} for the current configuration."
      set antecedents [expr {$data_path_select == "standard" && $tx_enable == "1" ? {device_speedgrade data_path_select std_protocol_hint std_pcs_pma_width std_tx_pcfifo_mode}
        : $data_path_select == "standard" && $rx_enable == "1" ? {device_speedgrade data_path_select std_protocol_hint std_pcs_pma_width std_rx_pcfifo_mode}
            : {device_speedgrade data_path_select} }]
      set message "${message} [get_invalid_antecedents_string $antecedents]"
      ip_message $message_level $message
    }
  }
  # End PCS data rate check

}


proc ::altera_xcvr_native_cv::parameters::validate_data_rate { set_data_rate } {
  ip_set "parameter.data_rate.value" "${set_data_rate} Mbps"
}


proc ::altera_xcvr_native_cv::parameters::validate_pma_width { data_path_select pma_direct_width std_pcs_pma_width } {
  set value [expr { $data_path_select == "standard" ? $std_pcs_pma_width
      : $pma_direct_width }]

  ip_set "parameter.pma_width.value" $value
}


proc ::altera_xcvr_native_cv::parameters::validate_pma_direct_width { data_path_select } {
  ip_set "parameter.pma_direct_width.visible" [expr {$data_path_select == "pma_direct"}]
}


proc ::altera_xcvr_native_cv::parameters::validate_base_data_rate { set_data_rate tx_pma_clk_div } {
  if {[string is double $set_data_rate]} {
    ip_set "parameter.base_data_rate.value" [expr $set_data_rate * $tx_pma_clk_div]
  }
}


proc ::altera_xcvr_native_cv::parameters::validate_pll_data_rate { l_pll_settings } {
  ip_set "parameter.pll_data_rate.value" [::alt_xcvr::gui::pll_reconfig::get_pll_data_rate_string]
}


proc ::altera_xcvr_native_cv::parameters::validate_pll_type { l_pll_settings } {
  ip_set "parameter.pll_type.value" [::alt_xcvr::gui::pll_reconfig::get_pll_type_string]
}


proc ::altera_xcvr_native_cv::parameters::validate_plls { tx_enable pll_external_enable bonded_mode plls } {
  if {$tx_enable && $bonded_mode != "non_bonded" && $plls > 1} {
    ip_message error "[ip_get "parameter.plls.display_name"] cannot exceed 1 when using TX channel bonding"
  }
}


###
# Validation for the pll_select parameter
#
# @param plls - Resolved value of the plls parameter
proc ::altera_xcvr_native_cv::parameters::validate_pll_select { tx_enable plls pll_select } {
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
# Validation for the pll_reconfig_enable parameter
#
# @param plls - Resolved value of the pll_reconfig_enable parameter
proc ::altera_xcvr_native_cv::parameters::validate_pll_reconfig_enable { pll_external_enable } {
  set enable true
  if {$pll_external_enable} {
     set enable false
  }
  
  ip_set "parameter.pll_reconfig_enable.enabled" $enable
}

###
# Validation for the pll_refclk_cnt parameter
#
# @param plls - Resolved value of the pll_refclk_cnt parameter
proc ::altera_xcvr_native_cv::parameters::validate_pll_refclk_cnt { pll_external_enable } {
  set visible true
  if {$pll_external_enable} {
     set visible false
  }
  
  ip_set "parameter.pll_refclk_cnt.visible" $visible
}

###
# Validation for the pll_refclk_select parameter
#
# @param l_pll_settings - Placed here merely to force validation of l_pll_settings before this
proc ::altera_xcvr_native_cv::parameters::validate_pll_refclk_select { l_pll_settings } {
  ip_set "parameter.pll_refclk_select.value" [::alt_xcvr::gui::pll_reconfig::get_refclk_sel_string] 
}


###
# Validation for the pll_refclk_freq parameter
#
# @param l_pll_settings - Placed here merely to force validation of l_pll_settings before this
proc ::altera_xcvr_native_cv::parameters::validate_pll_refclk_freq { l_pll_settings } {
  ip_set "parameter.pll_refclk_freq.value" [::alt_xcvr::gui::pll_reconfig::get_refclk_freq_string]
}


###
# Validation for the cdr_refclk_select parameter
#
# @param cdr_refclk_cnt - Resolved value of the cdr_refclk_cnt parameter
proc ::altera_xcvr_native_cv::parameters::validate_cdr_refclk_select { cdr_refclk_cnt } {
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
proc ::altera_xcvr_native_cv::parameters::validate_cdr_refclk_freq { cdr_refclk_cnt cdr_refclk_select set_cdr_refclk_freq } {
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
proc ::altera_xcvr_native_cv::parameters::validate_set_cdr_refclk_freq { set_cdr_refclk_freq rx_enable device_family device_speedgrade data_rate } {
  set allowed_ranges {}
  if {$rx_enable} {
    # Retreive legal reference clock frequencies from RBC
    set allowed_ranges [::alt_xcvr::utils::rbc::get_valid_refclks $device_family $data_rate [::alt_xcvr::utils::device::get_cmu_pll_name]]
    if {$allowed_ranges == "N/A"} {
      ip_message error "The selected data rate for RX CDR cannot be achieved."
    }

    # Issue message if current selected value is illegal
    if {[lsearch $allowed_ranges $set_cdr_refclk_freq] == -1} {
      ip_message error "The selected CDR reference clock frequency \"$set_cdr_refclk_freq\" is invalid. Please change the CDR reference clock frequency or choose a different data rate."
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
proc ::altera_xcvr_native_cv::parameters::validate_enable_port_rx_seriallpbken { tx_enable rx_enable } {
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
proc ::altera_xcvr_native_cv::parameters::validate_l_pll_settings { device_family device_speedgrade tx_enable base_data_rate plls pll_external_enable pll_select pll_refclk_cnt bonded_mode} {
  if { $tx_enable } {
    set max_plls 4
  } else {
    set max_plls 0
	set plls 0
  }

  set base_data_rate "$base_data_rate Mbps"
  set clk_network_ranges [expr {$tx_enable && $bonded_mode != "non_bonded" ? {"xN:xN"} : {"x1:x1" "xN:xN"} }]

  ::alt_xcvr::gui::pll_reconfig::set_config $device_family $max_plls 5 [::alt_xcvr::utils::device::get_hssi_pll_types $device_family] 0 0 $clk_network_ranges $pll_external_enable; # 4 PLLs, 5 refclks, types, enable rx refclk sel, enable PLL reconfig
  ::alt_xcvr::gui::pll_reconfig::set_main_pll_settings "unused" $base_data_rate "unused"
  ::alt_xcvr::gui::pll_reconfig::set_tx_pll_counts $plls $pll_refclk_cnt $pll_select
  ::alt_xcvr::gui::pll_reconfig::validate
}


proc ::altera_xcvr_native_cv::parameters::validate_l_enable_tx_pma_direct { tx_enable data_path_select } {
  ip_set "parameter.l_enable_tx_pma_direct.value" [expr {$tx_enable && $data_path_select == "pma_direct"}]
}


proc ::altera_xcvr_native_cv::parameters::validate_l_enable_rx_pma_direct { rx_enable data_path_select } {
  ip_set "parameter.l_enable_rx_pma_direct.value" [expr {$rx_enable && $data_path_select == "pma_direct"}]
}

###
# Validation for l_enable_tx_std parameter. Used to determine
# when Standard TX PCS is enabled.
#
# @param tx_enable - Resolved value of the tx_enable parameter
# @param enable_std - Resolved value of the enable_std parameter
proc ::altera_xcvr_native_cv::parameters::validate_l_enable_tx_std { tx_enable enable_std } {
  ip_set "parameter.l_enable_tx_std.value" [expr $tx_enable && $enable_std]
}


###
# Validation for l_enable_rx_std parameter. Used to determine
# when Standard RX PCS is enabled.
#
# @param rx_enable - Resolved value of the rx_enable parameter
# @param enable_std - Resolved value of the enable_std parameter
proc ::altera_xcvr_native_cv::parameters::validate_l_enable_rx_std { rx_enable enable_std } {
  ip_set "parameter.l_enable_rx_std.value" [expr $rx_enable && $enable_std]
}


proc ::altera_xcvr_native_cv::parameters::validate_l_enable_rx_std_word_aligner { l_enable_rx_std std_rx_word_aligner_mode } {
  ip_set "parameter.l_enable_rx_std_word_aligner.value" [expr {$l_enable_rx_std && ($std_rx_word_aligner_mode != "bit_slip")}]
}

###
#
proc ::altera_xcvr_native_cv::parameters::validate_l_netlist_plls { bonded_mode plls channels } {
  if { $bonded_mode == "xN" } {
    ip_set "parameter.l_netlist_plls.value" $plls
  } elseif { $bonded_mode == "non_bonded"} {
    ip_set "parameter.l_netlist_plls.value" [expr {$plls * $channels}]
  }
}

###
#
proc ::altera_xcvr_native_cv::parameters::validate_l_rcfg_interfaces { device_family tx_enable pll_external_enable l_netlist_plls channels } {
  if {!$tx_enable || $pll_external_enable} {
    set l_netlist_plls 0
  }
  ip_set "parameter.l_rcfg_interfaces.value" [::alt_xcvr::utils::device::get_reconfig_interface_count $device_family $channels $l_netlist_plls]
  ::alt_xcvr::gui::messages::reconfig_interface_message $device_family $channels $l_netlist_plls
}

###
# 
proc ::altera_xcvr_native_cv::parameters::validate_l_rcfg_to_xcvr_width { device_family l_rcfg_interfaces } {
   ip_set "parameter.l_rcfg_to_xcvr_width.value" [::alt_xcvr::utils::device::get_reconfig_to_xcvr_total_width $device_family $l_rcfg_interfaces]
}


proc ::altera_xcvr_native_cv::parameters::validate_l_rcfg_from_xcvr_width { device_family l_rcfg_interfaces } {
  ip_set "parameter.l_rcfg_from_xcvr_width.value" [::alt_xcvr::utils::device::get_reconfig_from_xcvr_total_width $device_family $l_rcfg_interfaces]
}


proc ::altera_xcvr_native_cv::parameters::validate_l_pma_direct_word_count { pma_direct_width } {
  ip_set "parameter.l_pma_direct_word_count.value" [expr {
        $pma_direct_width == "8" || $pma_direct_width == "10" ? 1
      : $pma_direct_width == "16" || $pma_direct_width == "20" ? 2
      : 8 }]
}


proc ::altera_xcvr_native_cv::parameters::validate_l_pma_direct_word_width { pma_direct_width } {
  ip_set "parameter.l_pma_direct_word_width.value" [expr {$pma_direct_width == "8" || $pma_direct_width == "16" || $pma_direct_width == "32" || $pma_direct_width == "64" ? 8 : 10 }]
}


proc ::altera_xcvr_native_cv::parameters::validate_l_std_tx_word_count { std_pcs_pma_width std_tx_byte_ser_enable } {
  set count [expr $std_pcs_pma_width <= 10 ? 1 : 2]
  if {$std_tx_byte_ser_enable} {
    set count [expr $count * 2]
  }
  ip_set "parameter.l_std_tx_word_count.value" $count
}


proc ::altera_xcvr_native_cv::parameters::validate_l_std_tx_word_width { std_tx_pld_pcs_width l_std_tx_word_count } {
  ip_set "parameter.l_std_tx_word_width.value" [expr $std_tx_pld_pcs_width / $l_std_tx_word_count]
}


proc ::altera_xcvr_native_cv::parameters::validate_l_std_tx_field_width { std_pcs_pma_width std_tx_byte_ser_enable } {
  set width 11
  if {$std_tx_byte_ser_enable && $std_pcs_pma_width <= 10} {
    set width [expr $width * 2]
  }
  ip_set "parameter.l_std_tx_field_width.value" $width

}


proc ::altera_xcvr_native_cv::parameters::validate_l_std_rx_word_count { std_pcs_pma_width std_rx_byte_deser_enable } {
  set count [expr $std_pcs_pma_width <= 10 ? 1 : 2]
  if {$std_rx_byte_deser_enable} {
    set count [expr $count * 2]
  }
  ip_set "parameter.l_std_rx_word_count.value" $count
}


proc ::altera_xcvr_native_cv::parameters::validate_l_std_rx_word_width { std_rx_pld_pcs_width l_std_rx_word_count } {
  ip_set "parameter.l_std_rx_word_width.value" [expr $std_rx_pld_pcs_width / $l_std_rx_word_count]
}


proc ::altera_xcvr_native_cv::parameters::validate_l_std_rx_field_width { std_pcs_pma_width std_rx_byte_deser_enable } {
  set width 16
  if {$std_rx_byte_deser_enable && $std_pcs_pma_width <= 10} {
    set width [expr $width * 2]
  }
  ip_set "parameter.l_std_rx_field_width.value" $width

}


#******************************************************************************
#******************* Standard PCS validation callbacks ************************
#
proc ::altera_xcvr_native_cv::parameters::validate_enable_std { enable_std } {
  ip_set "display_item.Standard PCS.visible" [expr {$enable_std ? "true" : "false" }]
}


proc ::altera_xcvr_native_cv::parameters::validate_data_path_select { set_data_path_select enable_std } {
  set legal_values [expr { $enable_std ? "standard"
        : "pma_direct" }]

  ip_set "parameter.data_path_select.value" $legal_values
}


proc ::altera_xcvr_native_cv::parameters::validate_std_pcs_pma_width { std_pcs_pma_width enable_std std_protocol_hint } {
  set legal_values [expr { !$enable_std ? $std_pcs_pma_width
    : ( $std_protocol_hint == "srio_2p1" ) ? {20}
      : ( $std_protocol_hint == "basic" ) ? {8 10 16 20}
        : ( ( $std_protocol_hint == "cpri")  ||  ($std_protocol_hint == "cpri_rx_tx")) ? {10 20}
          : {10} }]
  
  auto_invalid_value_message auto std_pcs_pma_width $std_pcs_pma_width $legal_values {std_protocol_hint}
}


proc ::altera_xcvr_native_cv::parameters::validate_std_tx_pld_pcs_width { std_pcs_pma_width std_tx_byte_ser_enable std_tx_8b10b_enable } {
  set legal_value [expr { $std_tx_byte_ser_enable ? [expr $std_pcs_pma_width * 2]
    : $std_pcs_pma_width }]
  set legal_value [expr { $std_tx_8b10b_enable ? [expr {$legal_value * 4} / 5]
    : $legal_value }]

  ip_set "parameter.std_tx_pld_pcs_width.value" $legal_value
}


proc ::altera_xcvr_native_cv::parameters::validate_std_rx_pld_pcs_width { std_pcs_pma_width std_rx_byte_deser_enable std_rx_8b10b_enable } {
  set legal_value [expr { $std_rx_byte_deser_enable ? [expr $std_pcs_pma_width * 2]
    : $std_pcs_pma_width }]
  set legal_value [expr { $std_rx_8b10b_enable ? [expr {$legal_value * 4} / 5]
    : $legal_value }]

  ip_set "parameter.std_rx_pld_pcs_width.value" $legal_value
}


proc ::altera_xcvr_native_cv::parameters::validate_std_low_latency_bypass_enable { std_low_latency_bypass_enable enable_std std_protocol_hint } {
  set legal_values [expr { !$enable_std ? $std_low_latency_bypass_enable 
    : (($std_protocol_hint == "basic") ||  ($std_protocol_hint == "cpri_rx_tx")) ? {0 1}
      : {0} }]

  auto_invalid_value_message auto std_low_latency_bypass_enable $std_low_latency_bypass_enable $legal_values {std_protocol_hint}
}


proc ::altera_xcvr_native_cv::parameters::validate_std_tx_pcfifo_mode { std_tx_pcfifo_mode l_enable_tx_std std_protocol_hint } {
  set legal_values [expr { !$l_enable_tx_std ? $std_tx_pcfifo_mode
    : ($std_protocol_hint == "cpri" || $std_protocol_hint == "cpri_rx_tx") ? {"register_fifo"}
      : ($std_protocol_hint == "basic"  || $std_protocol_hint == "gige") ? {"low_latency" "register_fifo"}
        : {"low_latency"} }]
  
  auto_invalid_value_message auto std_tx_pcfifo_mode $std_tx_pcfifo_mode $legal_values {std_protocol_hint}
}


proc ::altera_xcvr_native_cv::parameters::validate_std_rx_pcfifo_mode {std_rx_pcfifo_mode l_enable_rx_std std_protocol_hint } {
  set legal_values [expr { !$l_enable_rx_std ? $std_rx_pcfifo_mode
    : ($std_protocol_hint == "cpri" || $std_protocol_hint == "cpri_rx_tx") ? {register_fifo}
      : ($std_protocol_hint == "basic"  || $std_protocol_hint == "gige") ? {low_latency register_fifo}
        : {low_latency} }]
  
  auto_invalid_value_message auto std_rx_pcfifo_mode $std_rx_pcfifo_mode $legal_values {std_protocol_hint}
}


proc ::altera_xcvr_native_cv::parameters::validate_std_tx_8b10b_enable { std_tx_8b10b_enable l_enable_tx_std std_pcs_pma_width std_low_latency_bypass_enable std_protocol_hint } {
  set legal_values [expr { !$l_enable_tx_std ? $std_tx_8b10b_enable
    : ($std_pcs_pma_width == "8")  || ($std_pcs_pma_width == "16") || ($std_low_latency_bypass_enable == "1") ? {0}
      : ($std_protocol_hint == "basic" ) &&  ($std_low_latency_bypass_enable == "0") ? {0 1}
        : {1} }]
    
  auto_invalid_value_message auto std_tx_8b10b_enable $std_tx_8b10b_enable $legal_values {std_protocol_hint std_pcs_pma_width std_low_latency_bypass_enable}
}


proc ::altera_xcvr_native_cv::parameters::validate_std_tx_8b10b_disp_ctrl_enable { std_tx_8b10b_disp_ctrl_enable l_enable_tx_std std_protocol_hint } {
  set legal_values [expr { !$l_enable_tx_std ? $std_tx_8b10b_disp_ctrl_enable
    : ( $std_protocol_hint == "basic") ? {0 1}
      : {0} }]

  auto_invalid_value_message auto std_tx_8b10b_disp_ctrl_enable $std_tx_8b10b_disp_ctrl_enable $legal_values { std_protocol_hint }
}


proc ::altera_xcvr_native_cv::parameters::validate_std_rx_8b10b_enable { std_rx_8b10b_enable l_enable_rx_std std_pcs_pma_width std_low_latency_bypass_enable std_protocol_hint } {
  set legal_values [expr { !$l_enable_rx_std ? $std_rx_8b10b_enable
    : ($std_pcs_pma_width == "8")  || ($std_pcs_pma_width == "16") || ($std_low_latency_bypass_enable == "1") ? {0}
      : ($std_protocol_hint == "basic") &&  ($std_low_latency_bypass_enable == "0") ? {0 1}
        : {1} }]
    
  auto_invalid_value_message auto std_rx_8b10b_enable $std_rx_8b10b_enable $legal_values {std_protocol_hint std_pcs_pma_width std_low_latency_bypass_enable}
}


proc ::altera_xcvr_native_cv::parameters::validate_std_rx_rmfifo_enable {std_rx_rmfifo_enable l_enable_rx_std std_protocol_hint std_pcs_pma_width std_rx_word_aligner_mode std_low_latency_bypass_enable} {
  set legal_values [expr { !$l_enable_rx_std ? $std_rx_rmfifo_enable
    : ($std_protocol_hint == "gige") ? {0 1}
      : ($std_protocol_hint == "xaui") ? {1}
        : ($std_protocol_hint == "srio_2p1") ? {1}
          : ( ($std_protocol_hint == "basic") && ($std_pcs_pma_width == "10") && ($std_rx_word_aligner_mode == "sync_sm") && ($std_low_latency_bypass_enable == "0") ) ? {0 1}
            : ( ($std_protocol_hint == "basic") && ($std_pcs_pma_width == "20")  && ($std_rx_word_aligner_mode == "manual") && ($std_low_latency_bypass_enable == "0")  ) ? {0 1}
              : {0} }]

  auto_invalid_value_message auto std_rx_rmfifo_enable $std_rx_rmfifo_enable $legal_values {std_protocol_hint std_pcs_pma_width std_rx_word_aligner_mode std_low_latency_bypass_enable}
}


proc ::altera_xcvr_native_cv::parameters::validate_std_rx_rmfifo_pattern_p {std_rx_rmfifo_pattern_p l_enable_rx_std std_protocol_hint std_rx_rmfifo_enable std_rx_word_aligner_mode} {
  if {!$l_enable_rx_std || !$std_rx_rmfifo_enable} { set legal_values $std_rx_rmfifo_pattern_p
  } elseif {$std_protocol_hint == "xaui"} { set legal_values "00343"
  } elseif {$std_protocol_hint == "gige"} { set legal_values "A257C"
  } elseif {$std_protocol_hint == "srio_2p1"} { set legal_values "E8A83"
  } else { set legal_values $std_rx_rmfifo_pattern_p }
  
  auto_invalid_value_message auto std_rx_rmfifo_pattern_p $std_rx_rmfifo_pattern_p $legal_values {std_protocol_hint std_rx_rmfifo_enable}
  auto_invalid_string_number_format_message auto std_rx_rmfifo_pattern_p $std_rx_rmfifo_pattern_p hex 20
}


proc ::altera_xcvr_native_cv::parameters::validate_std_rx_rmfifo_pattern_n {std_rx_rmfifo_pattern_n l_enable_rx_std std_protocol_hint std_rx_rmfifo_enable std_rx_word_aligner_mode} {
  if {!$l_enable_rx_std || !$std_rx_rmfifo_enable} { set legal_values $std_rx_rmfifo_pattern_n
  } elseif {$std_protocol_hint == "xaui"} { set legal_values "000BC"
  } elseif {$std_protocol_hint == "gige"} { set legal_values "AB683"
  } elseif {$std_protocol_hint == "srio_2p1"} { set legal_values "1757C"
  } else { set legal_values $std_rx_rmfifo_pattern_n }
  
  auto_invalid_value_message auto std_rx_rmfifo_pattern_n $std_rx_rmfifo_pattern_n $legal_values {std_protocol_hint std_rx_rmfifo_enable}
  auto_invalid_string_number_format_message auto std_rx_rmfifo_pattern_n $std_rx_rmfifo_pattern_n hex 20
}


proc ::altera_xcvr_native_cv::parameters::validate_std_rx_byte_order_enable {std_rx_byte_order_enable l_enable_rx_std std_rx_byte_deser_enable std_low_latency_bypass_enable std_protocol_hint } {
  set legal_values [expr { !$l_enable_rx_std ? $std_rx_byte_order_enable
    : $std_rx_byte_deser_enable && !$std_low_latency_bypass_enable && $std_protocol_hint == "basic" ? {0 1}
      : {0} }]
  
  auto_invalid_value_message auto std_rx_byte_order_enable $std_rx_byte_order_enable $legal_values {std_rx_byte_deser_enable std_low_latency_bypass_enable std_protocol_hint}
}


proc ::altera_xcvr_native_cv::parameters::validate_std_rx_byte_order_mode {std_rx_byte_order_mode l_enable_rx_std std_rx_byte_order_enable std_rx_word_aligner_mode} {
  set legal_values [expr { !$l_enable_rx_std || !$std_rx_byte_order_enable ? $std_rx_byte_order_mode
    : ($std_rx_word_aligner_mode == "bit_slip") ? {manual} : {manual auto} }]
  
  auto_invalid_value_message auto std_rx_byte_order_mode $std_rx_byte_order_mode $legal_values {std_rx_word_aligner_mode}
}


proc ::altera_xcvr_native_cv::parameters::validate_std_rx_byte_order_width {std_pcs_pma_width std_rx_8b10b_enable} {
  set legal_values [expr { $std_pcs_pma_width == "8" || $std_pcs_pma_width == "16" ? {8}
    : $std_rx_8b10b_enable == "1" ? {9}
      : {10} }]
  
  ip_set "parameter.std_rx_byte_order_width.value" [lindex $legal_values 0]
}


proc ::altera_xcvr_native_cv::parameters::validate_std_rx_byte_order_symbol_count {std_rx_byte_order_symbol_count l_enable_rx_std std_rx_byte_order_enable std_pcs_pma_width} {
  set legal_values [expr {!$l_enable_rx_std || !$std_rx_byte_order_enable ? $std_rx_byte_order_symbol_count
    : [expr $std_pcs_pma_width > 10] ? {1 2}
      : {1} }]
    
  auto_invalid_value_message auto std_rx_byte_order_symbol_count $std_rx_byte_order_symbol_count $legal_values {std_pcs_pma_width}
}


proc ::altera_xcvr_native_cv::parameters::validate_std_rx_byte_order_pattern {std_rx_byte_order_pattern l_enable_rx_std std_rx_byte_order_enable std_rx_byte_order_width std_rx_byte_order_symbol_count} {
  if {$l_enable_rx_std && $std_rx_byte_order_enable} {
    auto_invalid_string_number_format_message auto std_rx_byte_order_pattern $std_rx_byte_order_pattern hex [expr $std_rx_byte_order_width * $std_rx_byte_order_symbol_count] {std_rx_byte_order_enable std_rx_byte_order_width std_byte_order_symbol_count}
  }
}


proc ::altera_xcvr_native_cv::parameters::validate_std_rx_byte_order_pad {std_rx_byte_order_pad l_enable_rx_std std_rx_byte_order_enable std_rx_byte_order_width} {
  if {$l_enable_rx_std && $std_rx_byte_order_enable} {
    auto_invalid_string_number_format_message auto std_rx_byte_order_pad $std_rx_byte_order_pad hex $std_rx_byte_order_width {std_rx_byte_order_width}
  }
}


proc ::altera_xcvr_native_cv::parameters::validate_std_tx_byte_ser_enable { std_tx_byte_ser_enable l_enable_tx_std std_low_latency_bypass_enable std_pcs_pma_width } {
 # While there is an RBC rule for this parameter, it is irrelevant as it only imposes a restriction for protocol modes that we do not
  # currently support in Native PHY (PIPE, XAUI, PRBS, etc). For the modes currently supported all values are legal.
  set legal_values {0 1}

  auto_invalid_value_message auto std_tx_byte_ser_enable $std_tx_byte_ser_enable $legal_values {std_low_latency_bypass_enable std_pcs_pma_width}
} 


proc ::altera_xcvr_native_cv::parameters::validate_std_rx_byte_deser_enable { std_rx_byte_deser_enable l_enable_rx_std std_low_latency_bypass_enable std_pcs_pma_width } {
  # While there is an RBC rule for this parameter, it is irrelevant as it only imposes a restriction for protocol modes that we do not
  # currently support in Native PHY (PIPE, XAUI, PRBS, etc). For the modes currently supported all values are legal.
  set legal_values {0 1}

  auto_invalid_value_message auto std_rx_byte_deser_enable $std_rx_byte_deser_enable $legal_values {std_low_latency_bypass_enable std_pcs_pma_width}
} 


proc ::altera_xcvr_native_cv::parameters::validate_std_tx_bitslip_enable {std_tx_bitslip_enable l_enable_tx_std std_protocol_hint} {
  set legal_values [expr { !$l_enable_tx_std ? $std_tx_bitslip_enable
    : ($std_protocol_hint == "cpri_rx_tx") ? {1}
      : ($std_protocol_hint == "pipe_g1" || $std_protocol_hint == "pipe_g2" || $std_protocol_hint == "pipe_g3"  || $std_protocol_hint == "gige" || $std_protocol_hint == "xaui" || $std_protocol_hint == "test") ? {0}
        : ( ($std_protocol_hint == "basic") || ($std_protocol_hint == "srio_2p1") || ($std_protocol_hint == "cpri") ) ? {0 1}
          : {0} }]

  auto_invalid_value_message auto std_tx_bitslip_enable $std_tx_bitslip_enable $legal_values {std_protocol_hint}
}

proc altera_xcvr_native_cv::parameters::validate_std_rx_word_aligner_mode {std_rx_word_aligner_mode l_enable_rx_std std_low_latency_bypass_enable std_pcs_pma_width std_protocol_hint std_rx_byte_deser_enable std_rx_pld_pcs_width} {
  set legal_values [expr { !$l_enable_rx_std ? $std_rx_word_aligner_mode
    : (($std_low_latency_bypass_enable == "0") && ($std_pcs_pma_width == "8"  || $std_pcs_pma_width == "16") && ($std_protocol_hint == "basic") ) ? {"bit_slip" "manual"}
    : (($std_low_latency_bypass_enable == "0") && ($std_rx_pld_pcs_width == "32"  || $std_rx_pld_pcs_width == "40" || (($std_rx_pld_pcs_width == "16" || $std_rx_pld_pcs_width == "20") && !$std_rx_byte_deser_enable)) && ($std_protocol_hint == "basic") ) ? {"bit_slip" "manual"}
      : (($std_low_latency_bypass_enable == "0") && ($std_protocol_hint == "basic") ) ? {"bit_slip" "sync_sm" "manual"}
        : ($std_low_latency_bypass_enable == "1") ? {"bit_slip"}
          : ($std_protocol_hint == "cpri") ? {"sync_sm"}
            : ($std_protocol_hint == "cpri_rx_tx") ? {"manual"}
              : {"sync_sm"} }]


  auto_invalid_value_message auto std_rx_word_aligner_mode $std_rx_word_aligner_mode $legal_values {std_low_latency_bypass_enable std_pcs_pma_width std_protocol_hint std_rx_byte_deser_enable std_rx_pld_pcs_width}
}


proc ::altera_xcvr_native_cv::parameters::validate_std_rx_word_aligner_pattern_len {std_rx_word_aligner_pattern_len l_enable_rx_std std_protocol_hint std_pcs_pma_width std_rx_word_aligner_mode} {
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


proc ::altera_xcvr_native_cv::parameters::validate_std_rx_word_aligner_pattern {std_rx_word_aligner_pattern l_enable_rx_std std_rx_word_aligner_mode std_rx_word_aligner_pattern_len} {
  if { $l_enable_rx_std && $std_rx_word_aligner_mode != "bit_slip" } {
    auto_invalid_string_number_format_message auto std_rx_word_aligner_pattern $std_rx_word_aligner_pattern "hex" $std_rx_word_aligner_pattern_len {std_rx_word_aligner_mode std_rx_word_aligner_pattern_len}
  }
}


proc ::altera_xcvr_native_cv::parameters::validate_std_rx_word_aligner_rknumber {std_rx_word_aligner_rknumber l_enable_rx_std std_rx_word_aligner_mode std_protocol_hint} {
  set legal_values [expr { !$l_enable_rx_std || $std_rx_word_aligner_mode == "bit_slip" ? $std_rx_word_aligner_rknumber
    : ($std_protocol_hint == "gige") ? {3}
    : ($std_protocol_hint == "xaui") ? {3}
    : ($std_protocol_hint == "srio_2p1") ? {126}
    : $std_rx_word_aligner_rknumber }]
  
  auto_invalid_value_message auto std_rx_word_aligner_rknumber $std_rx_word_aligner_rknumber $legal_values {std_rx_word_aligner_mode std_protocol_hint}
}


proc ::altera_xcvr_native_cv::parameters::validate_std_rx_word_aligner_renumber {std_rx_word_aligner_renumber l_enable_rx_std std_rx_word_aligner_mode std_protocol_hint} {
  set legal_values [expr { !$l_enable_rx_std || $std_rx_word_aligner_mode == "bit_slip" ? $std_rx_word_aligner_renumber
    : ($std_protocol_hint == "gige") ? {3}
    : ($std_protocol_hint == "xaui") ? {3}
    : $std_rx_word_aligner_renumber }]
  
  auto_invalid_value_message auto std_rx_word_aligner_renumber $std_rx_word_aligner_renumber $legal_values {std_rx_word_aligner_mode std_protocol_hint}
}


proc ::altera_xcvr_native_cv::parameters::validate_std_rx_word_aligner_rgnumber {std_rx_word_aligner_rgnumber l_enable_rx_std std_rx_word_aligner_mode std_protocol_hint} {
  set legal_values [expr { !$l_enable_rx_std || $std_rx_word_aligner_mode == "bit_slip" ? $std_rx_word_aligner_rgnumber
    : ($std_protocol_hint == "gige") ? {3}
    : ($std_protocol_hint == "xaui") ? {3}
    : ($std_protocol_hint == "srio_2p1") ? {254}
    : $std_rx_word_aligner_rgnumber }]
  
  auto_invalid_value_message auto std_rx_word_aligner_rgnumber $std_rx_word_aligner_rgnumber $legal_values {std_rx_word_aligner_mode std_protocol_hint}
}


proc ::altera_xcvr_native_cv::parameters::validate_std_rx_run_length_val {std_rx_run_length_val l_enable_rx_std std_pcs_pma_width} {
  set max_value [expr {$std_pcs_pma_width == "8" || $std_pcs_pma_width == "10" ? 31 : 63}]

  if { $l_enable_rx_std } {
    auto_invalid_string_number_format_message auto std_rx_run_length_val $std_rx_run_length_val "dec" $max_value {std_pcs_pma_width}
  }
}


proc ::altera_xcvr_native_cv::parameters::validate_enable_port_rx_std_bitslip { l_enable_rx_std enable_port_rx_std_bitslip std_low_latency_bypass_enable } {
  if {$l_enable_rx_std && $std_low_latency_bypass_enable && $enable_port_rx_std_bitslip} {
    ip_message warning "Asserting the 'rx_std_bitslip' port has no effect when parameter \"std_low_latency_bypass_enable\" ([ip_get "parameter.std_low_latency_bypass_enable.display_name"]) is enabled."
  }
}


proc ::altera_xcvr_native_cv::parameters::validate_std_tx_bitrev_enable { std_tx_bitrev_enable l_enable_tx_std std_protocol_hint } {
  set legal_values [expr { !$l_enable_tx_std ? $std_tx_bitrev_enable
    : $std_protocol_hint == "basic" ? {0 1}
      : 0 }]

  auto_invalid_value_message auto std_tx_bitrev_enable $std_tx_bitrev_enable $legal_values {std_protocol_hint}
}


proc ::altera_xcvr_native_cv::parameters::validate_std_rx_bitrev_enable { std_rx_bitrev_enable l_enable_rx_std std_protocol_hint } {
  set legal_values [expr { !$l_enable_rx_std ? $std_rx_bitrev_enable
    : $std_protocol_hint == "basic" ? {0 1}
      : 0 }]

  auto_invalid_value_message auto std_rx_bitrev_enable $std_rx_bitrev_enable $legal_values {std_protocol_hint}
}


proc ::altera_xcvr_native_cv::parameters::validate_std_tx_byterev_enable { std_tx_byterev_enable l_enable_tx_std std_protocol_hint std_pcs_pma_width } {
  set legal_values [expr { !$l_enable_tx_std ? $std_tx_byterev_enable
    : $std_protocol_hint == "basic" && ($std_pcs_pma_width == 16 || $std_pcs_pma_width == 20) ? {0 1}
      : 0 }]

  auto_invalid_value_message auto std_tx_byterev_enable $std_tx_byterev_enable $legal_values {std_protocol_hint std_pcs_pma_width}
}


proc ::altera_xcvr_native_cv::parameters::validate_std_rx_byterev_enable { std_rx_byterev_enable l_enable_rx_std std_protocol_hint std_pcs_pma_width } {
  set legal_values [expr { !$l_enable_rx_std ? $std_rx_byterev_enable
    : $std_protocol_hint == "basic" && ($std_pcs_pma_width == 16 || $std_pcs_pma_width == 20) ? {0 1}
      : 0 }]

  auto_invalid_value_message auto std_rx_byterev_enable $std_rx_byterev_enable $legal_values {std_protocol_hint std_pcs_pma_width}
}


proc ::altera_xcvr_native_cv::parameters::validate_enable_port_rx_std_bitrev_ena { l_enable_rx_std enable_port_rx_std_bitrev_ena std_rx_bitrev_enable } {
  set legal_values [expr { !$l_enable_rx_std ? $enable_port_rx_std_bitrev_ena
    : $std_rx_bitrev_enable ? 1
      : {0 1} }]

  auto_invalid_value_message auto enable_port_rx_std_bitrev_ena $enable_port_rx_std_bitrev_ena $legal_values {std_rx_bitrev_enable}
}


proc ::altera_xcvr_native_cv::parameters::validate_enable_port_rx_std_byterev_ena { l_enable_rx_std enable_port_rx_std_byterev_ena std_rx_byterev_enable } {
  set legal_values [expr { !$l_enable_rx_std ? $enable_port_rx_std_byterev_ena
    : $std_rx_byterev_enable ? 1
      : {0 1} }]

  auto_invalid_value_message auto enable_port_rx_std_byterev_ena $enable_port_rx_std_byterev_ena $legal_values {std_rx_byterev_enable}
}


proc ::altera_xcvr_native_cv::parameters::validate_enable_port_tx_std_polinv { l_enable_tx_std enable_port_tx_std_polinv std_tx_polinv_enable } {
  set legal_values [expr { !$l_enable_tx_std ? $enable_port_tx_std_polinv
    : $std_tx_polinv_enable ? 1
      : {0 1} }]

  auto_invalid_value_message auto enable_port_tx_std_polinv $enable_port_tx_std_polinv $legal_values {std_tx_polinv_enable}
}


proc ::altera_xcvr_native_cv::parameters::validate_enable_port_rx_std_polinv { l_enable_rx_std enable_port_rx_std_polinv std_rx_polinv_enable } {
  set legal_values [expr { !$l_enable_rx_std ? $enable_port_rx_std_polinv
    : $std_rx_polinv_enable ? 1
      : {0 1} }]

  auto_invalid_value_message auto enable_port_rx_std_polinv $enable_port_rx_std_polinv $legal_values {std_rx_polinv_enable}
}
#******************* Standard PCS validation callbacks ************************
#******************************************************************************
