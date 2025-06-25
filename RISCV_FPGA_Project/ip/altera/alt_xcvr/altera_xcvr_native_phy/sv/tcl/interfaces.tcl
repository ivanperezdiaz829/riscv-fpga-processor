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


package provide altera_xcvr_native_sv::interfaces 13.1

package require alt_xcvr::ip_tcl::ip_module
package require alt_xcvr::ip_tcl::ip_interfaces
package require alt_xcvr::ip_tcl::messages

namespace eval ::altera_xcvr_native_sv::interfaces:: {
  namespace import ::alt_xcvr::ip_tcl::ip_module::*
  namespace import ::alt_xcvr::ip_tcl::ip_interfaces::*
  namespace import ::alt_xcvr::ip_tcl::messages::*

  namespace export \
    declare_interfaces \
    elaborate

  variable interfaces

  set interfaces {\
    {NAME                         DIRECTION UI_DIRECTION WIDTH_EXPR              ROLE                      TERMINATION                                                  TERMINATION_VALUE IFACE_NAME                  IFACE_TYPE  IFACE_DIRECTION DYNAMIC ELABORATION_CALLBACK }\
    {pll_powerdown                input     input        l_netlist_plls          pll_powerdown             !tx_enable                                                   NOVAL             pll_powerdown               conduit     end             false   NOVAL       }\
    {tx_analogreset               input     input        channels                tx_analogreset            !tx_enable                                                   NOVAL             tx_analogreset              conduit     end             false   NOVAL       }\
    {tx_digitalreset              input     input        channels                tx_digitalreset           !tx_enable                                                   NOVAL             tx_digitalreset             conduit     end             false   NOVAL       }\
    {tx_pll_refclk                input     input        pll_refclk_cnt          tx_pll_refclk             "!tx_enable || pll_external_enable"                          NOVAL             tx_pll_refclk               conduit     end             false   NOVAL       }\
    {tx_pma_clkout                output    output       channels                tx_pma_clkout             "!l_enable_tx_pma_direct"                                    NOVAL             tx_pma_clkout               conduit     end             false   NOVAL       }\
    {tx_pma_pclk                  output    output       channels                tx_pma_pclk               "!tx_enable || !enable_port_tx_pma_pclk"                     NOVAL             tx_pma_pclk                 conduit     end             false   NOVAL       }\
    {tx_serial_data               output    output       channels                tx_serial_data            !tx_enable                                                   NOVAL             tx_serial_data              conduit     end             false   NOVAL       }\
    {tx_pma_parallel_data         input     input        channels*80             tx_pma_parallel_data      !l_enable_tx_pma_direct                                      NOVAL             tx_pma_parallel_data        conduit     end             false   ::altera_xcvr_native_sv::interfaces::elaborate_tx_pma_parallel_data}\
    {unused_tx_pma_parallel_data  input     input        NOVAL                   NOVAL                     NOVAL                                                        NOVAL             NOVAL                       conduit     end             true    ::altera_xcvr_native_sv::interfaces::elaborate_unused_tx_pma_parallel_data}\
    {pll_locked                   output    output       l_netlist_plls          pll_locked                "!tx_enable || pll_external_enable"                          NOVAL             pll_locked                  conduit     end             false   NOVAL       }\
    {ext_pll_clk                  input     input        channels*plls           ext_pll_clk               "!tx_enable || !pll_external_enable"                         NOVAL             ext_pll_clk                 conduit     end             false   NOVAL       }\
    \
    {rx_analogreset               input     input        channels                rx_analogreset            !rx_enable                                                   NOVAL             rx_analogreset              conduit     end             false   NOVAL       }\
    {rx_digitalreset              input     input        channels                rx_digitalreset           !rx_enable                                                   NOVAL             rx_digitalreset             conduit     end             false   NOVAL       }\
    {rx_cdr_refclk                input     input        cdr_refclk_cnt          rx_cdr_refclk             !rx_enable                                                   NOVAL             rx_cdr_refclk               conduit     end             false   NOVAL       }\
    {rx_pma_clkout                output    output       channels                rx_pma_clkout             "!rx_enable || !enable_port_rx_pma_clkout"                   NOVAL             rx_pma_clkout               conduit     end             false   NOVAL       }\
    {rx_pma_pclk                  output    output       channels                rx_pma_pclk               "!rx_enable || !enable_port_rx_pma_pclk"                     NOVAL             rx_pma_pclk                 conduit     end             false   NOVAL       }\
    {rx_serial_data               input     input        channels                rx_serial_data            !rx_enable                                                   NOVAL             rx_serial_data              conduit     end             false   NOVAL       }\
    {rx_pma_parallel_data         output    output       channels*80             rx_pma_parallel_data      !l_enable_rx_pma_direct                                      NOVAL             rx_pma_parallel_data        conduit     end             false   ::altera_xcvr_native_sv::interfaces::elaborate_rx_pma_parallel_data}\
    {unused_rx_pma_parallel_data  input     input        NOVAL                   NOVAL                     NOVAL                                                        NOVAL             NOVAL                       conduit     end             true    ::altera_xcvr_native_sv::interfaces::elaborate_unused_rx_pma_parallel_data}\
    {rx_clkslip                   input     input        channels                rx_clkslip                "!rx_enable || !rx_clkslip_enable"                           NOVAL             rx_clkslip                  conduit     end             false   NOVAL       }\
    {rx_clklow                    output    output       channels                rx_clklow                 true                                                         NOVAL             rx_clklow                   conduit     end             false   NOVAL       }\
    {rx_fref                      output    output       channels                rx_fref                   true                                                         NOVAL             rx_fref                     conduit     end             false   NOVAL       }\
    {rx_set_locktodata            input     input        channels                rx_set_locktodata         "!rx_enable || !enable_ports_rx_manual_cdr_mode"             NOVAL             rx_set_locktodata           conduit     end             false   NOVAL       }\
    {rx_set_locktoref             input     input        channels                rx_set_locktoref          "!rx_enable || !enable_ports_rx_manual_cdr_mode"             NOVAL             rx_set_locktoref            conduit     end             false   NOVAL       }\
    {rx_is_lockedtoref            output    output       channels                rx_is_lockedtoref         "!rx_enable || !enable_port_rx_is_lockedtoref"               NOVAL             rx_is_lockedtoref           conduit     end             false   NOVAL       }\
    {rx_is_lockedtodata           output    output       channels                rx_is_lockedtodata        "!rx_enable || !enable_port_rx_is_lockedtodata"              NOVAL             rx_is_lockedtodata          conduit     end             false   NOVAL       }\
    {rx_seriallpbken              input     input        channels                rx_seriallpbken           "!tx_enable || !rx_enable || !enable_port_rx_seriallpbken"   NOVAL             rx_seriallpbken             conduit     end             false   NOVAL       }\
    {rx_signaldetect              output    output       channels                rx_signaldetect           "!rx_enable || !enable_port_rx_signaldetect"                 NOVAL             rx_signaldetect             conduit     end             false   NOVAL       }\
    {rx_pma_qpipulldn             input     input        channels                rx_pma_qpipulldn          "!rx_enable || !enable_port_rx_pma_qpipulldn"                NOVAL             rx_pma_qpipulldn            conduit     end             false   NOVAL       }\
    {tx_pma_qpipullup             input     input        channels                tx_pma_qpipullup          "!tx_enable || !enable_port_tx_pma_qpipullup"                NOVAL             tx_pma_qpipullup            conduit     end             false   NOVAL       }\
    {tx_pma_qpipulldn             input     input        channels                tx_pma_qpipulldn          "!tx_enable || !enable_port_tx_pma_qpipulldn"                NOVAL             tx_pma_qpipulldn            conduit     end             false   NOVAL       }\
    {tx_pma_txdetectrx            input     input        channels                tx_pma_txdetectrx         "!tx_enable || !enable_port_tx_pma_txdetectrx"               NOVAL             tx_pma_txdtectrx            conduit     end             false   NOVAL       }\
    {tx_pma_rxfound               output    output       channels                tx_pma_rxfound            "!tx_enable || !enable_port_tx_pma_rxfound"                  NOVAL             tx_pma_rxfound              conduit     end             false   NOVAL       }\
    \
    {tx_parallel_data             input     input        channels*64             tx_parallel_data          "!l_enable_tx_teng && !l_enable_tx_std"                      NOVAL             tx_parallel_data            conduit     end             false   ::altera_xcvr_native_sv::interfaces::elaborate_tx_parallel_data}\
    {tx_datak                     input     input        NOVAL                   NOVAL                     NOVAL                                                        NOVAL             NOVAL                       conduit     end             true    ::altera_xcvr_native_sv::interfaces::elaborate_tx_datak}\
    {tx_forcedisp                 input     input        NOVAL                   NOVAL                     NOVAL                                                        NOVAL             NOVAL                       conduit     end             true    ::altera_xcvr_native_sv::interfaces::elaborate_tx_forcedisp}\
    {tx_dispval                   input     input        NOVAL                   NOVAL                     NOVAL                                                        NOVAL             NOVAL                       conduit     end             true    ::altera_xcvr_native_sv::interfaces::elaborate_tx_dispval}\
    {unused_tx_parallel_data      input     input        NOVAL                   NOVAL                     NOVAL                                                        NOVAL             NOVAL                       conduit     end             true    ::altera_xcvr_native_sv::interfaces::elaborate_unused_tx_parallel_data}\
    {rx_parallel_data             output    output       channels*64             rx_parallel_data          "!l_enable_rx_teng && !l_enable_rx_std"                      NOVAL             rx_parallel_data            conduit     end             false   ::altera_xcvr_native_sv::interfaces::elaborate_rx_parallel_data}\
    {rx_datak                     output    output       NOVAL                   NOVAL                     NOVAL                                                        NOVAL             NOVAL                       conduit     end             true    ::altera_xcvr_native_sv::interfaces::elaborate_rx_datak}\
    {rx_errdetect                 output    output       NOVAL                   NOVAL                     NOVAL                                                        NOVAL             NOVAL                       conduit     end             true    ::altera_xcvr_native_sv::interfaces::elaborate_rx_errdetect}\
    {rx_disperr                   output    output       NOVAL                   NOVAL                     NOVAL                                                        NOVAL             NOVAL                       conduit     end             true    ::altera_xcvr_native_sv::interfaces::elaborate_rx_disperr}\
    {rx_runningdisp               output    output       NOVAL                   NOVAL                     NOVAL                                                        NOVAL             NOVAL                       conduit     end             true    ::altera_xcvr_native_sv::interfaces::elaborate_rx_runningdisp}\
    {rx_patterndetect             output    output       NOVAL                   NOVAL                     NOVAL                                                        NOVAL             NOVAL                       conduit     end             true    ::altera_xcvr_native_sv::interfaces::elaborate_rx_patterndetect}\
    {rx_syncstatus                output    output       NOVAL                   NOVAL                     NOVAL                                                        NOVAL             NOVAL                       conduit     end             true    ::altera_xcvr_native_sv::interfaces::elaborate_rx_syncstatus}\
    {rx_rmfifostatus              output    output       NOVAL                   NOVAL                     NOVAL                                                        NOVAL             NOVAL                       conduit     end             true    ::altera_xcvr_native_sv::interfaces::elaborate_rx_rmfifostatus}\
    {unused_rx_parallel_data      output    output       NOVAL                   NOVAL                     NOVAL                                                        NOVAL             NOVAL                       conduit     end             true    ::altera_xcvr_native_sv::interfaces::elaborate_unused_rx_parallel_data}\
    {tx_std_coreclkin             input     input        channels                tx_std_coreclkin          !l_enable_tx_std                                             NOVAL             tx_std_coreclkin            conduit     end             false   NOVAL       }\
    {rx_std_coreclkin             input     input        channels                rx_std_coreclkin          !l_enable_rx_std                                             NOVAL             rx_std_coreclkin            conduit     end             false   NOVAL       }\
    {tx_std_clkout                output    output       channels                tx_std_clkout             !l_enable_tx_std                                             NOVAL             tx_std_clkout               conduit     end             false   NOVAL       }\
    {rx_std_clkout                output    output       channels                rx_std_clkout             !l_enable_rx_std                                             NOVAL             rx_std_clkout               conduit     end             false   NOVAL       }\
    \
    {rx_std_prbs_done             output    output       channels                rx_std_prbs_done          "!l_enable_rx_std || !enable_port_rx_std_prbs_status"        NOVAL             rx_std_prbs_done            conduit     end             false   NOVAL       }\
    {rx_std_prbs_err              output    output       channels                rx_std_prbs_err           "!l_enable_rx_std || !enable_port_rx_std_prbs_status"        NOVAL             rx_std_prbs_err             conduit     end             false   NOVAL       }\
    \
    {tx_std_pcfifo_full           output    output       channels                tx_std_pcfifo_full        "!l_enable_tx_std || !enable_port_tx_std_pcfifo_full"        NOVAL             tx_std_pcfifo_full          conduit     end             false   NOVAL       }\
    {tx_std_pcfifo_empty          output    output       channels                tx_std_pcfifo_empty       "!l_enable_tx_std || !enable_port_tx_std_pcfifo_empty"       NOVAL             tx_std_pcfifo_empty         conduit     end             false   NOVAL       }\
    {rx_std_pcfifo_full           output    output       channels                rx_std_pcfifo_full        "!l_enable_rx_std || !enable_port_rx_std_pcfifo_full"        NOVAL             rx_std_pcfifo_full          conduit     end             false   NOVAL       }\
    {rx_std_pcfifo_empty          output    output       channels                rx_std_pcfifo_empty       "!l_enable_rx_std || !enable_port_rx_std_pcfifo_empty"       NOVAL             rx_std_pcfifo_empty         conduit     end             false   NOVAL       }\
    \
    {rx_std_byteorder_ena         input     input        channels                rx_std_byteorder_ena      "!l_enable_rx_std || !enable_port_rx_std_byteorder_ena"      NOVAL             rx_std_byteorder_ena        conduit     end             false   NOVAL       }\
    {rx_std_byteorder_flag        output    output       channels                rx_std_byteorder_flag     "!l_enable_rx_std || !enable_port_rx_std_byteorder_flag"     NOVAL             rx_std_byteorder_flag       conduit     end             false   NOVAL       }\
    \
    {rx_std_rmfifo_full           output    output       channels                rx_std_rmfifo_full        "!l_enable_rx_std || !enable_port_rx_std_rmfifo_full"        NOVAL             rx_std_rmfifo_full          conduit     end             false   NOVAL       }\
    {rx_std_rmfifo_empty          output    output       channels                rx_std_rmfifo_empty       "!l_enable_rx_std || !enable_port_rx_std_rmfifo_empty"       NOVAL             rx_std_rmfifo_empty         conduit     end             false   NOVAL       }\
    \
    {rx_std_wa_patternalign       input     input        channels                rx_std_wa_patternalign    "!l_enable_rx_std || !enable_port_rx_std_wa_patternalign"    NOVAL             rx_std_wa_patternalign      conduit     end             false   NOVAL       }\
    {rx_std_wa_a1a2size           input     input        channels                rx_std_wa_a1a2size        "!l_enable_rx_std || !enable_port_rx_std_wa_a1a2size"        NOVAL             rx_std_wa_a1a2size          conduit     end             false   NOVAL       }\
    {tx_std_bitslipboundarysel    input     input        channels*5              tx_std_bitslipboundarysel "!l_enable_tx_std || !enable_port_tx_std_bitslipboundarysel" NOVAL             tx_std_bitslipboundarysel   conduit     end             false   NOVAL       }\
    {rx_std_bitslipboundarysel    output    output       channels*5              rx_std_bitslipboundarysel "!l_enable_rx_std || !enable_port_rx_std_bitslipboundarysel" NOVAL             rx_std_bitslipboundarysel   conduit     end             false   NOVAL       }\
    {rx_std_bitslip               input     input        channels                rx_std_bitslip            "!l_enable_rx_std || !enable_port_rx_std_bitslip"            NOVAL             rx_std_bitslip              conduit     end             false   NOVAL       }\
    {rx_std_runlength_err         output    output       channels                rx_std_runlength_err      "!l_enable_rx_std || !enable_port_rx_std_runlength_err"      NOVAL             rx_std_runlength_err        conduit     end             false   NOVAL       }\
    \
    {rx_std_bitrev_ena            input     input        channels                rx_std_bitrev_ena         "!l_enable_rx_std || !enable_port_rx_std_bitrev_ena"         NOVAL             rx_std_bitrev_ena           conduit     end             false   NOVAL       }\
    {rx_std_byterev_ena           input     input        channels                rx_std_byterev_ena        "!l_enable_rx_std || !enable_port_rx_std_byterev_ena"        NOVAL             rx_std_byterev_ena          conduit     end             false   NOVAL       }\
    {tx_std_polinv                input     input        channels                tx_std_polinv             "!l_enable_tx_std || !enable_port_tx_std_polinv"             NOVAL             tx_std_polinv               conduit     end             false   NOVAL       }\
    {rx_std_polinv                input     input        channels                rx_std_polinv             "!l_enable_rx_std || !enable_port_rx_std_polinv"             NOVAL             rx_std_polinv               conduit     end             false   NOVAL       }\
    {tx_std_elecidle              input     input        channels                tx_std_elecidle           "!l_enable_tx_std || !enable_port_tx_std_elecidle"           NOVAL             tx_std_elecidle             conduit     end             false   NOVAL       }\
    {rx_std_signaldetect          output    output       channels                rx_std_signaldetect       "!l_enable_rx_std || !enable_port_rx_std_signaldetect"       NOVAL             rx_std_signaldetect         conduit     end             false   NOVAL       }\
    \
    {tx_10g_coreclkin             input     input        channels                tx_10g_coreclkin          !l_enable_tx_teng                                            NOVAL             tx_10g_coreclkin            conduit     end             false   NOVAL       }\
    {rx_10g_coreclkin             input     input        channels                rx_10g_coreclkin          !l_enable_rx_teng                                            NOVAL             rx_10g_coreclkin            conduit     end             false   NOVAL       }\
    {tx_10g_clkout                output    output       channels                tx_10g_clkout             !l_enable_tx_teng                                            NOVAL             tx_10g_clkout               conduit     end             false   NOVAL       }\
    {rx_10g_clkout                output    output       channels                rx_10g_clkout             !l_enable_rx_teng                                            NOVAL             rx_10g_clkout               conduit     end             false   NOVAL       }\
    {rx_10g_clk33out              output    output       channels                rx_10g_clk33out           "!l_enable_rx_teng || !enable_port_rx_10g_clk33out"          NOVAL             rx_10g_clk33out             conduit     end             false   NOVAL       }\
    \
    {rx_10g_prbs_err_clr          input     input        channels                rx_10g_prbs_err_clr       "!l_enable_rx_teng || !enable_port_rx_teng_prbs_status"      NOVAL             rx_10g_prbs_err_clr         conduit     end             false   NOVAL       }\
    {rx_10g_prbs_done             output    output       channels                rx_10g_prbs_done          "!l_enable_rx_teng || !enable_port_rx_teng_prbs_status"      NOVAL             rx_10g_prbs_done            conduit     end             false   NOVAL       }\
    {rx_10g_prbs_err              output    output       channels                rx_10g_prbs_err           "!l_enable_rx_teng || !enable_port_rx_teng_prbs_status"      NOVAL             rx_10g_prbs_err             conduit     end             false   NOVAL       }\
    \
    {tx_10g_control               input     input        channels*9              tx_10g_control            !l_enable_tx_teng                                            NOVAL             tx_10g_control              conduit     end             false   NOVAL       }\
    {rx_10g_control               output    output       channels*10             rx_10g_control            !l_enable_rx_teng                                            NOVAL             rx_10g_control              conduit     end             false   NOVAL       }\
    {tx_10g_data_valid            input     input        channels                tx_10g_data_valid         !l_enable_tx_teng                                            NOVAL             tx_10g_data_valid           conduit     end             false   NOVAL       }\
    {tx_10g_fifo_full             output    output       channels                tx_10g_fifo_full          "!l_enable_tx_teng || !enable_port_tx_10g_fifo_full"         NOVAL             tx_10g_fifo_full            conduit     end             false   NOVAL       }\
    {tx_10g_fifo_pfull            output    output       channels                tx_10g_fifo_pfull         "!l_enable_tx_teng || !enable_port_tx_10g_fifo_pfull"        NOVAL             tx_10g_fifo_pfull           conduit     end             false   NOVAL       }\
    {tx_10g_fifo_empty            output    output       channels                tx_10g_fifo_empty         "!l_enable_tx_teng || !enable_port_tx_10g_fifo_empty"        NOVAL             tx_10g_fifo_empty           conduit     end             false   NOVAL       }\
    {tx_10g_fifo_pempty           output    output       channels                tx_10g_fifo_pempty        "!l_enable_tx_teng || !enable_port_tx_10g_fifo_pempty"       NOVAL             tx_10g_fifo_pempty          conduit     end             false   NOVAL       }\
    {tx_10g_fifo_del              output    output       channels                tx_10g_fifo_del           "!l_enable_tx_teng || !enable_port_tx_10g_fifo_del"          NOVAL             tx_10g_fifo_del             conduit     end             false   NOVAL       }\
    {tx_10g_fifo_insert           output    output       channels                tx_10g_fifo_insert        "!l_enable_tx_teng || !enable_port_tx_10g_fifo_insert"       NOVAL             tx_10g_fifo_insert          conduit     end             false   NOVAL       }\
    {rx_10g_fifo_rd_en            input     input        channels                rx_10g_fifo_rd_en         "!l_enable_rx_teng || !enable_port_rx_10g_fifo_rd_en"        NOVAL             rx_10g_fifo_rd_en           conduit     end             false   NOVAL       }\
    {rx_10g_data_valid            output    output       channels                rx_10g_data_valid         "!l_enable_rx_teng || !enable_port_rx_10g_data_valid"        NOVAL             rx_10g_data_valid           conduit     end             false   NOVAL       }\
    {rx_10g_fifo_full             output    output       channels                rx_10g_fifo_full          "!l_enable_rx_teng || !enable_port_rx_10g_fifo_full"         NOVAL             rx_10g_fifo_full            conduit     end             false   NOVAL       }\
    {rx_10g_fifo_pfull            output    output       channels                rx_10g_fifo_pfull         "!l_enable_rx_teng || !enable_port_rx_10g_fifo_pfull"        NOVAL             rx_10g_fifo_pfull           conduit     end             false   NOVAL       }\
    {rx_10g_fifo_empty            output    output       channels                rx_10g_fifo_empty         "!l_enable_rx_teng || !enable_port_rx_10g_fifo_empty"        NOVAL             rx_10g_fifo_empty           conduit     end             false   NOVAL       }\
    {rx_10g_fifo_pempty           output    output       channels                rx_10g_fifo_pempty        "!l_enable_rx_teng || !enable_port_rx_10g_fifo_pempty"       NOVAL             rx_10g_fifo_pempty          conduit     end             false   NOVAL       }\
    {rx_10g_fifo_del              output    output       channels                rx_10g_fifo_del           "!l_enable_rx_teng || !enable_port_rx_10g_fifo_del"          NOVAL             rx_10g_fifo_del             conduit     end             false   NOVAL       }\
    {rx_10g_fifo_insert           output    output       channels                rx_10g_fifo_insert        "!l_enable_rx_teng || !enable_port_rx_10g_fifo_insert"       NOVAL             rx_10g_fifo_insert          conduit     end             false   NOVAL       }\
    {rx_10g_fifo_align_val        output    output       channels                rx_10g_fifo_align_val     "!l_enable_rx_teng || !enable_port_rx_10g_fifo_align_val"    NOVAL             rx_10g_fifo_align_val       conduit     end             false   NOVAL       }\
    {rx_10g_fifo_align_clr        input     input        channels                rx_10g_fifo_align_clr     "!l_enable_rx_teng || !enable_port_rx_10g_fifo_align_clr"    NOVAL             rx_10g_fifo_align_clr       conduit     end             false   NOVAL       }\
    {rx_10g_fifo_align_en         input     input        channels                rx_10g_fifo_align_en      "!l_enable_rx_teng || !enable_port_rx_10g_fifo_align_en"     NOVAL             rx_10g_fifo_align_en        conduit     end             false   NOVAL       }\
    \
    {tx_10g_frame                 output    output       channels                tx_10g_frame              "!l_enable_tx_teng || !enable_port_tx_10g_frame"             NOVAL             tx_10g_frame                conduit     end             false   NOVAL       }\
    {tx_10g_frame_diag_status     input     input        channels*2              tx_10g_frame_diag_status  "!l_enable_tx_teng || !enable_port_tx_10g_frame_diag_status" NOVAL             tx_10g_frame_diag_status    conduit     end             false   NOVAL       }\
    {tx_10g_frame_burst_en        input     input        channels                tx_10g_frame_burst_en     "!l_enable_tx_teng || !enable_port_tx_10g_frame_burst_en"    NOVAL             tx_10g_burst_en             conduit     end             false   NOVAL       }\
    {rx_10g_frame                 output    output       channels                rx_10g_frame              "!l_enable_rx_teng || !enable_port_rx_10g_frame"             NOVAL             rx_10g_frame                conduit     end             false   NOVAL       }\
    {rx_10g_frame_lock            output    output       channels                rx_10g_frame_lock         "!l_enable_rx_teng || !enable_port_rx_10g_frame_lock"        NOVAL             rx_10g_frame_lock           conduit     end             false   NOVAL       }\
    {rx_10g_frame_mfrm_err        output    output       channels                rx_10g_frame_mfrm_err     "!l_enable_rx_teng || !enable_port_rx_10g_frame_mfrm_err"    NOVAL             rx_10g_frame_mfrm_err       conduit     end             false   NOVAL       }\
    {rx_10g_frame_sync_err        output    output       channels                rx_10g_frame_sync_err     "!l_enable_rx_teng || !enable_port_rx_10g_frame_sync_err"    NOVAL             rx_10g_frame_sync_err       conduit     end             false   NOVAL       }\
    {rx_10g_frame_skip_ins        output    output       channels                rx_10g_frame_skip_ins     "!l_enable_rx_teng || !enable_port_rx_10g_frame_skip_ins"    NOVAL             rx_10g_frame_skip_ins       conduit     end             false   NOVAL       }\
    {rx_10g_frame_pyld_ins        output    output       channels                rx_10g_frame_pyld_ins     "!l_enable_rx_teng || !enable_port_rx_10g_frame_pyld_ins"    NOVAL             rx_10g_frame_pyld_ins       conduit     end             false   NOVAL       }\
    {rx_10g_frame_skip_err        output    output       channels                rx_10g_frame_skip_err     "!l_enable_rx_teng || !enable_port_rx_10g_frame_skip_err"    NOVAL             rx_10g_frame_skip_err       conduit     end             false   NOVAL       }\
    {rx_10g_frame_diag_err        output    output       channels                rx_10g_frame_diag_err     "!l_enable_rx_teng || !enable_port_rx_10g_frame_diag_err"    NOVAL             rx_10g_frame_diag_err       conduit     end             false   NOVAL       }\
    {rx_10g_frame_diag_status     output    output       channels*2              rx_10g_frame_diag_status  "!l_enable_rx_teng || !enable_port_rx_10g_frame_diag_status" NOVAL             rx_10g_frame_diag_status    conduit     end             false   NOVAL       }\
    \
    {rx_10g_crc32_err             output    output       channels                rx_10g_crc32err           "!l_enable_rx_teng || !enable_port_rx_10g_crc32_err"         NOVAL             rx_10g_crc32err             conduit     end             false   NOVAL       }\
    \
    {rx_10g_descram_err           output    output       channels                rx_10g_descram_err        "!l_enable_rx_teng || !enable_port_rx_10g_descram_err"       NOVAL             rx_10g_descram_err          conduit     end             false   NOVAL       }\
    \
    {rx_10g_blk_lock              output    output       channels                rx_10g_blk_lock           "!l_enable_rx_teng  || !enable_port_rx_10g_blk_lock"         NOVAL             rx_10g_blk_lock             conduit     end             false   NOVAL       }\
    {rx_10g_blk_sh_err            output    output       channels                rx_10g_blk_sh_err         "!l_enable_rx_teng  || !enable_port_rx_10g_blk_sh_err"       NOVAL             rx_10g_blk_sh_err           conduit     end             false   NOVAL       }\
    \
    {tx_10g_bitslip               input     input        channels*7              tx_10g_bitslip            "!l_enable_tx_teng || !enable_port_tx_10g_bitslip"           NOVAL             tx_10g_bitslip              conduit     end             false   NOVAL       }\
    {rx_10g_bitslip               input     input        channels                rx_10g_bitslip            "!l_enable_rx_teng || !enable_port_rx_10g_bitslip"           NOVAL             rx_10g_bitslip              conduit     end             false   NOVAL       }\
    \
    {rx_10g_highber               output    output       channels                rx_10g_highber            "!l_enable_rx_teng || !enable_port_rx_10g_highber"           NOVAL             rx_10g_highber              conduit     end             false   NOVAL       }\
    {rx_10g_highber_clr_cnt       input     input        channels                rx_10g_highber_clr_cnt    "!l_enable_rx_teng || !enable_port_rx_10g_highber_clr_cnt"   NOVAL             rx_10g_highber_clr_cnt      conduit     end             false   NOVAL       }\
    {rx_10g_clr_errblk_count      input     input        channels                rx_10g_clr_errblk_count   "!l_enable_rx_teng || !enable_port_rx_10g_clr_errblk_count"  NOVAL             rx_10g_clr_errblk_count     conduit     end             false   NOVAL       }\
    \
    {tx_cal_busy                  output    output       channels                tx_cal_busy               !tx_enable                                                   NOVAL             tx_cal_busy                 conduit     end             false   NOVAL       }\
    {rx_cal_busy                  output    output       channels                rx_cal_busy               !rx_enable                                                   NOVAL             rx_cal_busy                 conduit     end             false   NOVAL       }\
    {reconfig_to_xcvr             input     input        l_rcfg_to_xcvr_width    reconfig_to_xcvr          false                                                        NOVAL             reconfig_to_xcvr            conduit     end             false   NOVAL       }\
    {reconfig_from_xcvr           output    output       l_rcfg_from_xcvr_width  reconfig_from_xcvr        false                                                        NOVAL             reconfig_from_xcvr          conduit     end             false   NOVAL       }\
  }

}

proc ::altera_xcvr_native_sv::interfaces::declare_interfaces {} {
  variable interfaces
  ip_declare_interfaces $interfaces
}

proc ::altera_xcvr_native_sv::interfaces::elaborate {} {
  ip_elaborate_interfaces
}


proc ::altera_xcvr_native_sv::interfaces::elaborate_tx_pma_parallel_data { enable_simple_interface l_enable_tx_pma_direct channels pma_direct_width l_pma_direct_word_count l_pma_direct_word_width} {
  if {$l_enable_tx_pma_direct} {
    create_fragmented_interface [expr $enable_simple_interface && $pma_direct_width < 80] "tx_pma_parallel_data" "tx_pma_parallel_data" input $channels 80 10 $l_pma_direct_word_count $l_pma_direct_word_width 0
  }
}


proc ::altera_xcvr_native_sv::interfaces::elaborate_unused_tx_pma_parallel_data { enable_simple_interface l_enable_tx_pma_direct channels pma_direct_width l_pma_direct_word_count l_pma_direct_word_width} {
  if {$l_enable_tx_pma_direct && $enable_simple_interface && $pma_direct_width < 80} {
    set unused_list [create_expanded_index_list $channels 80 10 $l_pma_direct_word_count $l_pma_direct_word_width 0 unused]
    create_fragmented_conduit "unused_tx_pma_parallel_data" [add_fragment_prefix $unused_list "tx_pma_parallel_data"] input input
  }
}


proc ::altera_xcvr_native_sv::interfaces::elaborate_rx_pma_parallel_data { enable_simple_interface l_enable_rx_pma_direct channels pma_direct_width l_pma_direct_word_count l_pma_direct_word_width} {
  if {$l_enable_rx_pma_direct} {
    create_fragmented_interface [expr $enable_simple_interface && $pma_direct_width < 80] "rx_pma_parallel_data" "rx_pma_parallel_data" output $channels 80 10 $l_pma_direct_word_count $l_pma_direct_word_width 0
  }
}


proc ::altera_xcvr_native_sv::interfaces::elaborate_unused_rx_pma_parallel_data { enable_simple_interface l_enable_rx_pma_direct channels pma_direct_width l_pma_direct_word_count l_pma_direct_word_width} {
  if {$l_enable_rx_pma_direct && $enable_simple_interface && $pma_direct_width < 80} {
    set unused_list [create_expanded_index_list $channels 80 10 $l_pma_direct_word_count $l_pma_direct_word_width 0 unused]
    create_fragmented_conduit "unused_rx_pma_parallel_data" [add_fragment_prefix $unused_list "rx_pma_parallel_data"] output output
  }
}
###############################################################################
########################## TX parallel data elaboration #######################
proc ::altera_xcvr_native_sv::interfaces::elaborate_tx_parallel_data { l_enable_tx_std l_enable_tx_teng data_path_select l_std_tx_word_width l_std_tx_word_count l_std_tx_field_width teng_pld_pcs_width channels enable_simple_interface } {
  if {$l_enable_tx_std && $data_path_select == "standard"} {
    create_fragmented_interface $enable_simple_interface "tx_parallel_data" "tx_parallel_data" input $channels 64 $l_std_tx_field_width $l_std_tx_word_count $l_std_tx_word_width 0
  } elseif {$l_enable_tx_teng && $data_path_select == "10G"} {
    if {$teng_pld_pcs_width <= 64} {
      create_fragmented_interface $enable_simple_interface "tx_parallel_data" "tx_parallel_data" input $channels 64 $teng_pld_pcs_width 1 $teng_pld_pcs_width 0
    } else {
      ip_message info "Refer to the IP user guide for tx_parallel_data and tx_10g_control data mapping when using the ${teng_pld_pcs_width}-bit FPGA fabric / 10G PCS interface width."
    }
  }
}


proc ::altera_xcvr_native_sv::interfaces::elaborate_tx_datak { l_enable_tx_std data_path_select l_std_tx_word_count l_std_tx_field_width enable_simple_interface channels std_tx_8b10b_enable } {
  if {$l_enable_tx_std && $data_path_select == "standard" && $std_tx_8b10b_enable} {
    create_fragmented_interface $enable_simple_interface "tx_datak" "tx_parallel_data" input $channels 64 $l_std_tx_field_width $l_std_tx_word_count 1 8
  }
}


proc ::altera_xcvr_native_sv::interfaces::elaborate_tx_forcedisp { l_enable_tx_std data_path_select l_std_tx_word_count l_std_tx_field_width enable_simple_interface channels std_tx_8b10b_enable std_tx_8b10b_disp_ctrl_enable } {
  if {$l_enable_tx_std && $data_path_select == "standard" && $std_tx_8b10b_enable && $std_tx_8b10b_disp_ctrl_enable} {
    create_fragmented_interface $enable_simple_interface "tx_forcedisp" "tx_parallel_data" input $channels 64 $l_std_tx_field_width $l_std_tx_word_count 1 9
  }
}


proc ::altera_xcvr_native_sv::interfaces::elaborate_tx_dispval { l_enable_tx_std data_path_select l_std_tx_word_count l_std_tx_field_width enable_simple_interface channels std_tx_8b10b_enable std_tx_8b10b_disp_ctrl_enable } {
  if {$l_enable_tx_std && $data_path_select == "standard" && $std_tx_8b10b_enable && $std_tx_8b10b_disp_ctrl_enable} {
    create_fragmented_interface $enable_simple_interface "tx_dispval" "tx_parallel_data" input $channels 64 $l_std_tx_field_width $l_std_tx_word_count 1 10
  }
}


proc ::altera_xcvr_native_sv::interfaces::elaborate_unused_tx_parallel_data { l_enable_tx_std l_enable_tx_teng data_path_select l_std_tx_word_width l_std_tx_word_count l_std_tx_field_width enable_simple_interface channels std_tx_8b10b_enable std_tx_8b10b_disp_ctrl_enable teng_pld_pcs_width} {
  if {$l_enable_tx_std && $data_path_select == "standard" && $enable_simple_interface} {
    set width $l_std_tx_word_width
    if {$std_tx_8b10b_enable} {
      set width 9
      if {$std_tx_8b10b_disp_ctrl_enable} {
        set width 11
      }
    }
    set unused_list [create_expanded_index_list $channels 64 $l_std_tx_field_width $l_std_tx_word_count $width 0 unused]
    create_fragmented_conduit "unused_tx_parallel_data" [add_fragment_prefix $unused_list "tx_parallel_data"] input input
  } elseif {$l_enable_tx_teng && $data_path_select == "10G" && $enable_simple_interface} {
    if {$teng_pld_pcs_width < 64} {
      set unused_list [create_expanded_index_list $channels 64 64 1 $teng_pld_pcs_width 0 unused]
      create_fragmented_conduit "unused_tx_parallel_data" [add_fragment_prefix $unused_list "tx_parallel_data"] input input
    }
  }
}
######################## End TX parallel data elaboration #####################
###############################################################################


###############################################################################
########################## RX parallel data elaboration #######################
proc ::altera_xcvr_native_sv::interfaces::elaborate_rx_parallel_data { l_enable_rx_std l_enable_rx_teng data_path_select l_std_rx_word_width l_std_rx_word_count l_std_rx_field_width teng_pld_pcs_width channels enable_simple_interface } {
  if {$l_enable_rx_std && $data_path_select == "standard"} {
    create_fragmented_interface $enable_simple_interface "rx_parallel_data" "rx_parallel_data" output $channels 64 $l_std_rx_field_width $l_std_rx_word_count $l_std_rx_word_width 0
  } elseif {$l_enable_rx_teng && $data_path_select == "10G"} {
    if {$teng_pld_pcs_width <= 64} {
      create_fragmented_interface $enable_simple_interface "rx_parallel_data" "rx_parallel_data" output $channels 64 $teng_pld_pcs_width 1 $teng_pld_pcs_width 0
    } else {
      ip_message info "Refer to the IP user guide for rx_parallel_data and rx_10g_control data mapping when using the ${teng_pld_pcs_width}-bit FPGA fabric / 10G PCS interface width."
    }
  }
}


proc ::altera_xcvr_native_sv::interfaces::elaborate_rx_datak { l_enable_rx_std data_path_select l_std_rx_word_count l_std_rx_field_width enable_simple_interface channels std_rx_8b10b_enable } {
  if {$l_enable_rx_std && $data_path_select == "standard" && $std_rx_8b10b_enable} {
    create_fragmented_interface $enable_simple_interface "rx_datak" "rx_parallel_data" output $channels 64 $l_std_rx_field_width $l_std_rx_word_count 1 8
  }
}


proc ::altera_xcvr_native_sv::interfaces::elaborate_rx_errdetect { l_enable_rx_std data_path_select l_std_rx_word_count l_std_rx_field_width enable_simple_interface channels std_rx_8b10b_enable } {
  if {$l_enable_rx_std && $data_path_select == "standard" && $std_rx_8b10b_enable} {
    create_fragmented_interface $enable_simple_interface "rx_errdetect" "rx_parallel_data" output $channels 64 $l_std_rx_field_width $l_std_rx_word_count 1 9
  }
}


proc ::altera_xcvr_native_sv::interfaces::elaborate_rx_disperr { l_enable_rx_std data_path_select l_std_rx_word_count l_std_rx_field_width enable_simple_interface channels std_rx_8b10b_enable } {
  if {$l_enable_rx_std && $data_path_select == "standard" && $std_rx_8b10b_enable} {
    create_fragmented_interface $enable_simple_interface "rx_disperr" "rx_parallel_data" output $channels 64 $l_std_rx_field_width $l_std_rx_word_count 1 11
  }
}


proc ::altera_xcvr_native_sv::interfaces::elaborate_rx_runningdisp { l_enable_rx_std data_path_select l_std_rx_word_count l_std_rx_field_width enable_simple_interface channels std_rx_8b10b_enable } {
  if {$l_enable_rx_std && $data_path_select == "standard" && $std_rx_8b10b_enable} {
    create_fragmented_interface $enable_simple_interface "rx_runningdisp" "rx_parallel_data" output $channels 64 $l_std_rx_field_width $l_std_rx_word_count 1 15
  }
}


proc ::altera_xcvr_native_sv::interfaces::elaborate_rx_syncstatus { l_enable_rx_std data_path_select l_std_rx_word_count l_std_rx_field_width enable_simple_interface channels std_rx_word_aligner_mode } {
  if {$l_enable_rx_std && $data_path_select == "standard" && $std_rx_word_aligner_mode != "bit_slip" } {
    create_fragmented_interface $enable_simple_interface "rx_syncstatus" "rx_parallel_data" output $channels 64 $l_std_rx_field_width $l_std_rx_word_count 1 10
  }
}


proc ::altera_xcvr_native_sv::interfaces::elaborate_rx_patterndetect { l_enable_rx_std data_path_select l_std_rx_word_count l_std_rx_field_width enable_simple_interface channels std_rx_word_aligner_mode } {
  if {$l_enable_rx_std && $data_path_select == "standard" && $std_rx_word_aligner_mode != "bit_slip" } {
    create_fragmented_interface $enable_simple_interface "rx_patterndetect" "rx_parallel_data" output $channels 64 $l_std_rx_field_width $l_std_rx_word_count 1 12
  }
}


proc ::altera_xcvr_native_sv::interfaces::elaborate_rx_rmfifostatus { l_enable_rx_std data_path_select l_std_rx_word_count l_std_rx_field_width enable_simple_interface channels std_rx_rmfifo_enable } {
  if {$l_enable_rx_std && $data_path_select == "standard" && $std_rx_rmfifo_enable } {
    create_fragmented_interface $enable_simple_interface "rx_rmfifostatus" "rx_parallel_data" output $channels 64 $l_std_rx_field_width $l_std_rx_word_count 2 13 
  }
}


proc ::altera_xcvr_native_sv::interfaces::elaborate_unused_rx_parallel_data { l_enable_rx_std l_enable_rx_teng data_path_select l_std_rx_word_width l_std_rx_word_count l_std_rx_field_width enable_simple_interface channels std_rx_8b10b_enable std_rx_word_aligner_mode std_rx_rmfifo_enable teng_pld_pcs_width} {
  if {$l_enable_rx_std && $data_path_select == "standard" && $enable_simple_interface} {
    set unused_list [create_expanded_index_list $channels 64 $l_std_rx_field_width $l_std_rx_word_count $l_std_rx_word_width 0 unused]
    if {$std_rx_8b10b_enable} {
      set unused_list [::alt_xcvr::utils::common::intersect $unused_list [create_expanded_index_list $channels 64 $l_std_rx_field_width $l_std_rx_word_count 2 8 unused]]
      set unused_list [::alt_xcvr::utils::common::intersect $unused_list [create_expanded_index_list $channels 64 $l_std_rx_field_width $l_std_rx_word_count 1 11 unused]]
      set unused_list [::alt_xcvr::utils::common::intersect $unused_list [create_expanded_index_list $channels 64 $l_std_rx_field_width $l_std_rx_word_count 1 15 unused]]
    }
    if {$std_rx_word_aligner_mode != "bit_slip"} {
      set unused_list [::alt_xcvr::utils::common::intersect $unused_list [create_expanded_index_list $channels 64 $l_std_rx_field_width $l_std_rx_word_count 1 10 unused]]
      set unused_list [::alt_xcvr::utils::common::intersect $unused_list [create_expanded_index_list $channels 64 $l_std_rx_field_width $l_std_rx_word_count 1 12 unused]]
    }
    if {$std_rx_rmfifo_enable} {
      set unused_list [::alt_xcvr::utils::common::intersect $unused_list [create_expanded_index_list $channels 64 $l_std_rx_field_width $l_std_rx_word_count 2 13 unused]]
    }
    
    create_fragmented_conduit "unused_rx_parallel_data" [add_fragment_prefix $unused_list "rx_parallel_data"] output output
  } elseif {$l_enable_rx_teng && $data_path_select == "10G" && $enable_simple_interface} {
    if {$teng_pld_pcs_width < 64} {
      set unused_list [create_expanded_index_list $channels 64 64 1 $teng_pld_pcs_width 0 unused]
      create_fragmented_conduit "unused_rx_parallel_data" [add_fragment_prefix $unused_list "rx_parallel_data"] output output
    }
  }
}

######################## End RX parallel data elaboration #####################
###############################################################################

