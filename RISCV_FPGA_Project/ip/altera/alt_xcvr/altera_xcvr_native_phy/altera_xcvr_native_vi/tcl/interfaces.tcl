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


package provide altera_xcvr_native_vi::interfaces 13.1

package require alt_xcvr::ip_tcl::ip_module
package require alt_xcvr::ip_tcl::ip_interfaces
package require alt_xcvr::ip_tcl::messages

namespace eval ::altera_xcvr_native_vi::interfaces:: {
  namespace import ::alt_xcvr::ip_tcl::ip_module::*
  namespace import ::alt_xcvr::ip_tcl::ip_interfaces::*
  namespace import ::alt_xcvr::ip_tcl::messages::*

  namespace export \
    declare_interfaces \
    elaborate

  variable interfaces

  set interfaces {\
    {NAME                         DIRECTION UI_DIRECTION  WIDTH_EXPR                            ROLE                      TERMINATION                                                           TERMINATION_VALUE IFACE_NAME                  IFACE_TYPE        IFACE_DIRECTION DYNAMIC SPLIT                   SPLIT_WIDTH         SPLIT_COUNT   ELABORATION_CALLBACK }\
    {tx_analogreset               input     input         channels                              tx_analogreset            !tx_enable                                                            NOVAL             tx_analogreset              conduit           end             false   "NOVAL"                 1                   channels      NOVAL       }\
    {tx_digitalreset              input     input         channels                              tx_digitalreset           !tx_enable                                                            NOVAL             tx_digitalreset             conduit           end             false   "NOVAL"                 1                   channels      NOVAL       }\
    {rx_analogreset               input     input         channels                              rx_analogreset            !rx_enable                                                            NOVAL             rx_analogreset              conduit           end             false   "NOVAL"                 1                   channels      NOVAL       }\
    {rx_digitalreset              input     input         channels                              rx_digitalreset           !rx_enable                                                            NOVAL             rx_digitalreset             conduit           end             false   "NOVAL"                 1                   channels      NOVAL       }\
    \
    {tx_cal_busy                  output    output        channels                              tx_cal_busy               !tx_enable                                                            NOVAL             tx_cal_busy                 conduit           end             false   "NOVAL"                 1                   channels      NOVAL       }\
    {rx_cal_busy                  output    output        channels                              rx_cal_busy               !rx_enable                                                            NOVAL             rx_cal_busy                 conduit           end             false   "NOVAL"                 1                   channels      NOVAL       }\
    \
    {tx_serial_clk0               input     input         channels                              clk                       "!tx_enable || l_enable_pma_bonding || (plls < 1)"                    NOVAL             tx_serial_clk0              hssi_serial_clock end             false   "NOVAL"                 1                   channels      NOVAL       }\
    {tx_serial_clk1               input     input         channels                              clk                       "!tx_enable || l_enable_pma_bonding || (plls < 2)"                    NOVAL             tx_serial_clk1              hssi_serial_clock end             false   "NOVAL"                 1                   channels      NOVAL       }\
    {tx_serial_clk2               input     input         channels                              clk                       "!tx_enable || l_enable_pma_bonding || (plls < 3)"                    NOVAL             tx_serial_clk2              hssi_serial_clock end             false   "NOVAL"                 1                   channels      NOVAL       }\
    {tx_serial_clk3               input     input         channels                              clk                       "!tx_enable || l_enable_pma_bonding || (plls < 4)"                    NOVAL             tx_serial_clk3              hssi_serial_clock end             false   "NOVAL"                 1                   channels      NOVAL       }\
    \
    {tx_bonding_clocks            input     input         channels*6                            clk                       !l_enable_pma_bonding                                                 NOVAL             tx_bonding_clocks           hssi_bonded_clock end             false   "NOVAL"                 6                   channels      NOVAL       }\
    \
    {rx_cdr_refclk0               input     input         1                                     clk                       "!rx_enable || (cdr_refclk_cnt < 1)"                                  0                 rx_cdr_refclk0              clock             sink            false   NOVAL                   NOVAL               NOVAL         NOVAL       }\
    {rx_cdr_refclk1               input     input         1                                     clk                       "!rx_enable || (cdr_refclk_cnt < 2)"                                  0                 rx_cdr_refclk1              clock             sink            false   NOVAL                   NOVAL               NOVAL         NOVAL       }\
    {rx_cdr_refclk2               input     input         1                                     clk                       "!rx_enable || (cdr_refclk_cnt < 3)"                                  0                 rx_cdr_refclk2              clock             sink            false   NOVAL                   NOVAL               NOVAL         NOVAL       }\
    {rx_cdr_refclk3               input     input         1                                     clk                       "!rx_enable || (cdr_refclk_cnt < 4)"                                  0                 rx_cdr_refclk3              clock             sink            false   NOVAL                   NOVAL               NOVAL         NOVAL       }\
    {rx_cdr_refclk4               input     input         1                                     clk                       "!rx_enable || (cdr_refclk_cnt < 5)"                                  0                 rx_cdr_refclk4              clock             sink            false   NOVAL                   NOVAL               NOVAL         NOVAL       }\
    \
    {tx_serial_data               output    output        channels                              tx_serial_data            !tx_enable                                                            NOVAL             tx_serial_data              conduit           end             false   "NOVAL"                 1                   channels      NOVAL       }\
    {rx_serial_data               input     input         channels                              rx_serial_data            !rx_enable                                                            NOVAL             rx_serial_data              conduit           end             false   "NOVAL"                 1                   channels      NOVAL       }\
    \
    {rx_pma_clkslip               input     input         channels                              rx_pma_clkslip            "!rx_enable || !enable_port_rx_pma_clkslip"                           NOVAL             rx_pma_clkslip              conduit           end             false   "NOVAL"                 1                   channels      NOVAL       }\
    {rx_seriallpbken              input     input         channels                              rx_seriallpbken           "!tx_enable || !rx_enable || !enable_port_rx_seriallpbken"            NOVAL             rx_seriallpbken             conduit           end             false   "NOVAL"                 1                   channels      NOVAL       }\
    {rx_set_locktodata            input     input         channels                              rx_set_locktodata         "!rx_enable || !enable_ports_rx_manual_cdr_mode"                      NOVAL             rx_set_locktodata           conduit           end             false   "NOVAL"                 1                   channels      NOVAL       }\
    {rx_set_locktoref             input     input         channels                              rx_set_locktoref          "!rx_enable || !enable_ports_rx_manual_cdr_mode"                      NOVAL             rx_set_locktoref            conduit           end             false   "NOVAL"                 1                   channels      NOVAL       }\
    \
    {rx_is_lockedtoref            output    output        channels                              rx_is_lockedtoref         "!rx_enable || !enable_port_rx_is_lockedtoref"                        NOVAL             rx_is_lockedtoref           conduit           end             false   "NOVAL"                 1                   channels      NOVAL       }\
    {rx_is_lockedtodata           output    output        channels                              rx_is_lockedtodata        "!rx_enable || !enable_port_rx_is_lockedtodata"                       NOVAL             rx_is_lockedtodata          conduit           end             false   "NOVAL"                 1                   channels      NOVAL       }\
    \
    {rx_pma_qpipullup             input     input         channels                              rx_pma_qpipullup          "!rx_enable || !enable_port_rx_pma_qpipullup"                         NOVAL             rx_pma_qpipullup            conduit           end             false   "NOVAL"                 1                   channels      NOVAL       }\
    {tx_pma_qpipulldn             input     input         channels                              tx_pma_qpipulldn          "!tx_enable || !enable_port_tx_pma_qpipulldn"                         NOVAL             tx_pma_qpipulldn            conduit           end             false   "NOVAL"                 1                   channels      NOVAL       }\
    {tx_pma_qpipullup             input     input         channels                              tx_pma_qpipullup          "!tx_enable || !enable_port_tx_pma_qpipullup"                         NOVAL             tx_pma_qpipullup            conduit           end             false   "NOVAL"                 1                   channels      NOVAL       }\
    {tx_pma_txdetectrx            input     input         channels                              tx_pma_txdetectrx         "!tx_enable || !enable_port_tx_pma_txdetectrx"                        NOVAL             tx_pma_txdtectrx            conduit           end             false   "NOVAL"                 1                   channels      NOVAL       }\
    {tx_pma_elecidle              input     input         channels                              tx_pma_elecidle           "!tx_enable || !enable_port_tx_pma_elecidle"                          NOVAL             tx_pma_elecidle             conduit           end             false   "NOVAL"                 1                   channels      NOVAL       }\
    {tx_pma_rxfound               output    output        channels                              tx_pma_rxfound            "!tx_enable || !enable_port_tx_pma_rxfound"                           NOVAL             tx_pma_rxfound              conduit           end             false   "NOVAL"                 1                   channels      NOVAL       }\
    \
    {rx_clklow                    output    output        channels                              rx_clklow                 true                                                                  NOVAL             rx_clklow                   conduit           end             false   "NOVAL"                 1                   channels      NOVAL       }\
    {rx_fref                      output    output        channels                              rx_fref                   true                                                                  NOVAL             rx_fref                     conduit           end             false   "NOVAL"                 1                   channels      NOVAL       }\
    \
    {tx_coreclkin                 input     input         channels                              clk                       "!tx_enable || enable_hip"                                            NOVAL             tx_coreclkin                clock             sink            false   "NOVAL"                 1                   channels      NOVAL       }\
    {rx_coreclkin                 input     input         channels                              clk                       "!rx_enable || enable_hip"                                            NOVAL             rx_coreclkin                clock             sink            false   "NOVAL"                 1                   channels      NOVAL       }\
    {tx_clkout                    output    output        channels                              clk                       "!tx_enable || enable_hip"                                            NOVAL             tx_clkout                   clock             source          false   "NOVAL"                 1                   channels      NOVAL       }\
    {rx_clkout                    output    output        channels                              clk                       "!rx_enable || enable_hip"                                            NOVAL             rx_clkout                   clock             source          false   "NOVAL"                 1                   channels      NOVAL       }\
    {tx_pma_clkout                output    output        channels                              clk                       "!tx_enable || !enable_port_tx_pma_clkout"                            NOVAL             tx_pma_clkout               clock             source          false   "NOVAL"                 1                   channels      NOVAL       }\
    {tx_pma_div_clkout            output    output        channels                              clk                       "!tx_enable || !enable_port_tx_pma_div_clkout"                        NOVAL             tx_pma_div_clkout           clock             source          false   "NOVAL"                 1                   channels      NOVAL       }\
    {rx_pma_clkout                output    output        channels                              clk                       "!rx_enable || !enable_port_rx_pma_clkout"                            NOVAL             rx_pma_clkout               clock             source          false   "NOVAL"                 1                   channels      NOVAL       }\
    {rx_pma_div_clkout            output    output        channels                              clk                       "!rx_enable || !enable_port_rx_pma_div_clkout"                        NOVAL             rx_pma_div_clkout           clock             source          false   "NOVAL"                 1                   channels      NOVAL       }\
    \
    {tx_parallel_data             input     input         channels*128                          tx_parallel_data          "!tx_enable || enable_hip"                                            NOVAL             tx_parallel_data            conduit           end             false   NOVAL                   NOVAL               NOVAL         ::altera_xcvr_native_vi::interfaces::elaborate_tx_parallel_data}\
    {tx_control                   input     input         channels*18                           tx_control                !l_enable_tx_enh_iface                                                NOVAL             tx_control                  conduit           end             false   "NOVAL"                 18                  channels      ::altera_xcvr_native_vi::interfaces::elaborate_tx_control}\
    {tx_err_ins                   input     input         NOVAL                                 NOVAL                     NOVAL                                                                 NOVAL             NOVAL                       conduit           end             true    NOVAL                   NOVAL               NOVAL         ::altera_xcvr_native_vi::interfaces::elaborate_tx_err_ins}\
    {tx_datak                     input     input         NOVAL                                 NOVAL                     NOVAL                                                                 NOVAL             NOVAL                       conduit           end             true    NOVAL                   NOVAL               NOVAL         ::altera_xcvr_native_vi::interfaces::elaborate_tx_datak}\
    {tx_forcedisp                 input     input         NOVAL                                 NOVAL                     NOVAL                                                                 NOVAL             NOVAL                       conduit           end             true    NOVAL                   NOVAL               NOVAL         ::altera_xcvr_native_vi::interfaces::elaborate_tx_forcedisp}\
    {tx_dispval                   input     input         NOVAL                                 NOVAL                     NOVAL                                                                 NOVAL             NOVAL                       conduit           end             true    NOVAL                   NOVAL               NOVAL         ::altera_xcvr_native_vi::interfaces::elaborate_tx_dispval}\
    {tx_pipe_signals              input     input         NOVAL                                 NOVAL                     NOVAL                                                                 NOVAL             NOVAL                       conduit           end             true    NOVAL                   NOVAL               NOVAL         ::altera_xcvr_native_vi::interfaces::elaborate_tx_pipe_signals}\
    {unused_tx_parallel_data      input     input         NOVAL                                 NOVAL                     NOVAL                                                                 NOVAL             NOVAL                       conduit           end             true    NOVAL                   NOVAL               NOVAL         ::altera_xcvr_native_vi::interfaces::elaborate_unused_tx_parallel_data}\
    {unused_tx_control            input     input         NOVAL                                 NOVAL                     NOVAL                                                                 NOVAL             NOVAL                       conduit           end             true    NOVAL                   NOVAL               NOVAL         ::altera_xcvr_native_vi::interfaces::elaborate_unused_tx_control}\
    \
    {rx_parallel_data             output    output        channels*128                          rx_parallel_data          "!rx_enable || enable_hip"                                            NOVAL             rx_parallel_data            conduit           end             false   NOVAL                   NOVAL               NOVAL         ::altera_xcvr_native_vi::interfaces::elaborate_rx_parallel_data}\
    {rx_control                   output    output        channels*20                           rx_control                !l_enable_rx_enh_iface                                                NOVAL             rx_control                  conduit           end             false   "NOVAL"                 20                  channels      ::altera_xcvr_native_vi::interfaces::elaborate_rx_control}\
    {rx_datak                     output    output        NOVAL                                 NOVAL                     NOVAL                                                                 NOVAL             NOVAL                       conduit           end             true    NOVAL                   NOVAL               NOVAL         ::altera_xcvr_native_vi::interfaces::elaborate_rx_datak}\
    {rx_errdetect                 output    output        NOVAL                                 NOVAL                     NOVAL                                                                 NOVAL             NOVAL                       conduit           end             true    NOVAL                   NOVAL               NOVAL         ::altera_xcvr_native_vi::interfaces::elaborate_rx_errdetect}\
    {rx_disperr                   output    output        NOVAL                                 NOVAL                     NOVAL                                                                 NOVAL             NOVAL                       conduit           end             true    NOVAL                   NOVAL               NOVAL         ::altera_xcvr_native_vi::interfaces::elaborate_rx_disperr}\
    {rx_runningdisp               output    output        NOVAL                                 NOVAL                     NOVAL                                                                 NOVAL             NOVAL                       conduit           end             true    NOVAL                   NOVAL               NOVAL         ::altera_xcvr_native_vi::interfaces::elaborate_rx_runningdisp}\
    {rx_patterndetect             output    output        NOVAL                                 NOVAL                     NOVAL                                                                 NOVAL             NOVAL                       conduit           end             true    NOVAL                   NOVAL               NOVAL         ::altera_xcvr_native_vi::interfaces::elaborate_rx_patterndetect}\
    {rx_syncstatus                output    output        NOVAL                                 NOVAL                     NOVAL                                                                 NOVAL             NOVAL                       conduit           end             true    NOVAL                   NOVAL               NOVAL         ::altera_xcvr_native_vi::interfaces::elaborate_rx_syncstatus}\
    {rx_rmfifostatus              output    output        NOVAL                                 NOVAL                     NOVAL                                                                 NOVAL             NOVAL                       conduit           end             true    NOVAL                   NOVAL               NOVAL         ::altera_xcvr_native_vi::interfaces::elaborate_rx_rmfifostatus}\
    {rx_pipe_signals              input     input         NOVAL                                 NOVAL                     NOVAL                                                                 NOVAL             NOVAL                       conduit           end             true    NOVAL                   NOVAL               NOVAL         ::altera_xcvr_native_vi::interfaces::elaborate_rx_pipe_signals}\
    {unused_rx_parallel_data      output    output        NOVAL                                 NOVAL                     NOVAL                                                                 NOVAL             NOVAL                       conduit           end             true    NOVAL                   NOVAL               NOVAL         ::altera_xcvr_native_vi::interfaces::elaborate_unused_rx_parallel_data}\
    {unused_rx_control            output    output        NOVAL                                 NOVAL                     NOVAL                                                                 NOVAL             NOVAL                       conduit           end             true    NOVAL                   NOVAL               NOVAL         ::altera_xcvr_native_vi::interfaces::elaborate_unused_rx_control}\
    \
    {rx_bitslip                   input     input         channels                              rx_bitslip                NOVAL                                                                 NOVAL             rx_bitslip                  conduit           end             false   "NOVAL"                 1                   channels      ::altera_xcvr_native_vi::interfaces::elaborate_rx_bitslip}\
    \
    {rx_prbs_err_clr              input     input         channels                              rx_prbs_err_clr           "!rx_enable || !enable_ports_rx_prbs"                                 NOVAL             rx_prbs_err_clr             conduit           end             false   "NOVAL"                 1                   channels      NOVAL       }\
    {rx_prbs_done                 output    output        channels                              rx_prbs_done              "!rx_enable || !enable_ports_rx_prbs"                                 NOVAL             rx_prbs_done                conduit           end             false   "NOVAL"                 1                   channels      NOVAL       }\
    {rx_prbs_err                  output    output        channels                              rx_prbs_err               "!rx_enable || !enable_ports_rx_prbs"                                 NOVAL             rx_prbs_err                 conduit           end             false   "NOVAL"                 1                   channels      NOVAL       }\
    \
    {tx_uhsif_clk                 input     input         channels                              clk                       true                                                                  NOVAL             tx_uhsif_clk                clock             sink            false   "NOVAL"                 1                   channels      NOVAL       }\
    {tx_uhsif_clkout              output    output        channels                              clk                       true                                                                  NOVAL             tx_uhsif_clkout             clock             source          false   "NOVAL"                 1                   channels      NOVAL       }\
    {tx_uhsif_lock                output    output        channels                              tx_uhsif_lock             true                                                                  NOVAL             tx_uhsif_lock               conduit           end             false   "NOVAL"                 1                   channels      NOVAL       }\
    \
    {tx_std_pcfifo_full           output    output        channels                              tx_std_pcfifo_full        "!l_enable_tx_std_iface || !enable_port_tx_std_pcfifo_full"           NOVAL             tx_std_pcfifo_full          conduit           end             false   "NOVAL"                 1                   channels      NOVAL       }\
    {tx_std_pcfifo_empty          output    output        channels                              tx_std_pcfifo_empty       "!l_enable_tx_std_iface || !enable_port_tx_std_pcfifo_empty"          NOVAL             tx_std_pcfifo_empty         conduit           end             false   "NOVAL"                 1                   channels      NOVAL       }\
    {rx_std_pcfifo_full           output    output        channels                              rx_std_pcfifo_full        "!l_enable_rx_std_iface || !enable_port_rx_std_pcfifo_full"           NOVAL             rx_std_pcfifo_full          conduit           end             false   "NOVAL"                 1                   channels      NOVAL       }\
    {rx_std_pcfifo_empty          output    output        channels                              rx_std_pcfifo_empty       "!l_enable_rx_std_iface || !enable_port_rx_std_pcfifo_empty"          NOVAL             rx_std_pcfifo_empty         conduit           end             false   "NOVAL"                 1                   channels      NOVAL       }\
    \
    {rx_std_bitrev_ena            input     input         channels                              rx_std_bitrev_ena         "!l_enable_rx_std_iface || !enable_port_rx_std_bitrev_ena"            NOVAL             rx_std_bitrev_ena           conduit           end             false   "NOVAL"                 1                   channels      NOVAL       }\
    {rx_std_byterev_ena           input     input         channels                              rx_std_byterev_ena        "!l_enable_rx_std_iface || !enable_port_rx_std_byterev_ena"           NOVAL             rx_std_byterev_ena          conduit           end             false   "NOVAL"                 1                   channels      NOVAL       }\
    {tx_polinv                    input     input         channels                              tx_polinv                 "!l_enable_tx_std_iface || !enable_port_tx_polinv"                    NOVAL             tx_polinv                   conduit           end             false   "NOVAL"                 1                   channels      NOVAL       }\
    {rx_polinv                    input     input         channels                              rx_polinv                 "!l_enable_tx_std_iface || !enable_port_rx_polinv"                    NOVAL             rx_polinv                   conduit           end             false   "NOVAL"                 1                   channels      NOVAL       }\
    \
    {tx_std_bitslipboundarysel    input     input         channels*5                            tx_std_bitslipboundarysel "!l_enable_tx_std_iface || !enable_port_tx_std_bitslipboundarysel"    NOVAL             tx_std_bitslipboundarysel   conduit           end             false   "NOVAL"                 5                   channels      NOVAL       }\
    {rx_std_bitslipboundarysel    output    output        channels*5                            rx_std_bitslipboundarysel "!l_enable_rx_std_iface || !enable_port_rx_std_bitslipboundarysel"    NOVAL             rx_std_bitslipboundarysel   conduit           end             false   "NOVAL"                 5                   channels      NOVAL       }\
    \
    {rx_std_wa_patternalign       input     input         channels                              rx_std_wa_patternalign    "!l_enable_rx_std_iface || !enable_port_rx_std_wa_patternalign"       NOVAL             rx_std_wa_patternalign      conduit           end             false   "NOVAL"                 1                   channels      NOVAL       }\
    {rx_std_wa_a1a2size           input     input         channels                              rx_std_wa_a1a2size        "!l_enable_rx_std_iface || !enable_port_rx_std_wa_a1a2size"           NOVAL             rx_std_wa_a1a2size          conduit           end             false   "NOVAL"                 1                   channels      NOVAL       }\
    \
    {rx_std_rmfifo_full           output    output        channels                              rx_std_rmfifo_full        "!l_enable_rx_std_iface || !enable_port_rx_std_rmfifo_full"           NOVAL             rx_std_rmfifo_full          conduit           end             false   "NOVAL"                 1                   channels      NOVAL       }\
    {rx_std_rmfifo_empty          output    output        channels                              rx_std_rmfifo_empty       "!l_enable_rx_std_iface || !enable_port_rx_std_rmfifo_empty"          NOVAL             rx_std_rmfifo_empty         conduit           end             false   "NOVAL"                 1                   channels      NOVAL       }\
    \
    {rx_std_signaldetect          output    output        channels                              rx_std_signaldetect       "!l_enable_rx_std_iface || !enable_port_rx_std_signaldetect"          NOVAL             rx_std_signaldetect         conduit           end             false   "NOVAL"                 1                   channels      NOVAL       }\
    \
    {tx_enh_data_valid            input     input         channels                              tx_enh_data_valid         !l_enable_tx_enh_iface                                                NOVAL             tx_enh_data_valid           conduit           end             false   "NOVAL"                 1                   channels      NOVAL       }\
    {tx_enh_fifo_full             output    output        channels                              tx_enh_fifo_full          "!l_enable_tx_enh_iface || !enable_port_tx_enh_fifo_full"             NOVAL             tx_enh_fifo_full            conduit           end             false   "NOVAL"                 1                   channels      NOVAL       }\
    {tx_enh_fifo_pfull            output    output        channels                              tx_enh_fifo_pfull         "!l_enable_tx_enh_iface || !enable_port_tx_enh_fifo_pfull"            NOVAL             tx_enh_fifo_pfull           conduit           end             false   "NOVAL"                 1                   channels      NOVAL       }\
    {tx_enh_fifo_empty            output    output        channels                              tx_enh_fifo_empty         "!l_enable_tx_enh_iface || !enable_port_tx_enh_fifo_empty"            NOVAL             tx_enh_fifo_empty           conduit           end             false   "NOVAL"                 1                   channels      NOVAL       }\
    {tx_enh_fifo_pempty           output    output        channels                              tx_enh_fifo_pempty        "!l_enable_tx_enh_iface || !enable_port_tx_enh_fifo_pempty"           NOVAL             tx_enh_fifo_pempty          conduit           end             false   "NOVAL"                 1                   channels      NOVAL       }\
    {tx_enh_fifo_cnt              output    output        channels*4                            tx_enh_fifo_cnt           "!l_enable_tx_enh_iface || !enable_port_tx_enh_fifo_cnt"              NOVAL             tx_enh_fifo_cnt             conduit           end             false   "NOVAL"                 4                   channels      NOVAL       }\
    \
    {rx_enh_fifo_rd_en            input     input         channels                              rx_enh_fifo_rd_en         "!l_enable_rx_enh_iface || !enable_port_rx_enh_fifo_rd_en"            NOVAL             rx_enh_fifo_rd_en           conduit           end             false   "NOVAL"                 1                   channels      NOVAL       }\
    {rx_enh_data_valid            output    output        channels                              rx_enh_data_valid         "!l_enable_rx_enh_iface || !enable_port_rx_enh_data_valid"            NOVAL             rx_enh_data_valid           conduit           end             false   "NOVAL"                 1                   channels      NOVAL       }\
    {rx_enh_fifo_full             output    output        channels                              rx_enh_fifo_full          "!l_enable_rx_enh_iface || !enable_port_rx_enh_fifo_full"             NOVAL             rx_enh_fifo_full            conduit           end             false   "NOVAL"                 1                   channels      NOVAL       }\
    {rx_enh_fifo_pfull            output    output        channels                              rx_enh_fifo_pfull         "!l_enable_rx_enh_iface || !enable_port_rx_enh_fifo_pfull"            NOVAL             rx_enh_fifo_pfull           conduit           end             false   "NOVAL"                 1                   channels      NOVAL       }\
    {rx_enh_fifo_empty            output    output        channels                              rx_enh_fifo_empty         "!l_enable_rx_enh_iface || !enable_port_rx_enh_fifo_empty"            NOVAL             rx_enh_fifo_empty           conduit           end             false   "NOVAL"                 1                   channels      NOVAL       }\
    {rx_enh_fifo_pempty           output    output        channels                              rx_enh_fifo_pempty        "!l_enable_rx_enh_iface || !enable_port_rx_enh_fifo_pempty"           NOVAL             rx_enh_fifo_pempty          conduit           end             false   "NOVAL"                 1                   channels      NOVAL       }\
    {rx_enh_fifo_del              output    output        channels                              rx_enh_fifo_del           "!l_enable_rx_enh_iface || !enable_port_rx_enh_fifo_del"              NOVAL             rx_enh_fifo_del             conduit           end             false   "NOVAL"                 1                   channels      NOVAL       }\
    {rx_enh_fifo_insert           output    output        channels                              rx_enh_fifo_insert        "!l_enable_rx_enh_iface || !enable_port_rx_enh_fifo_insert"           NOVAL             rx_enh_fifo_insert          conduit           end             false   "NOVAL"                 1                   channels      NOVAL       }\
    {rx_enh_fifo_cnt              output    output        channels*5                            rx_enh_fifo_cnt           "!l_enable_tx_enh_iface || !enable_port_rx_enh_fifo_cnt"              NOVAL             rx_enh_fifo_cnt             conduit           end             false   "NOVAL"                 5                   channels      NOVAL       }\
    {rx_enh_fifo_align_val        output    output        channels                              rx_enh_fifo_align_val     "!l_enable_rx_enh_iface || !enable_port_rx_enh_fifo_align_val"        NOVAL             rx_enh_fifo_align_val       conduit           end             false   "NOVAL"                 1                   channels      NOVAL       }\
    {rx_enh_fifo_align_clr        input     input         channels                              rx_enh_fifo_align_clr     "!l_enable_rx_enh_iface || !enable_port_rx_enh_fifo_align_clr"        NOVAL             rx_enh_fifo_align_clr       conduit           end             false   "NOVAL"                 1                   channels      NOVAL       }\
    \
    {tx_enh_frame                 output    output        channels                              tx_enh_frame              "!l_enable_tx_enh_iface || !enable_port_tx_enh_frame"                 NOVAL             tx_enh_frame                conduit           end             false   "NOVAL"                 1                   channels      NOVAL       }\
    {tx_enh_frame_burst_en        input     input         channels                              tx_enh_frame_burst_en     "!l_enable_tx_enh_iface || !enable_port_tx_enh_frame_burst_en"        NOVAL             tx_enh_burst_en             conduit           end             false   "NOVAL"                 1                   channels      NOVAL       }\
    {tx_enh_frame_diag_status     input     input         channels*2                            tx_enh_frame_diag_status  "!l_enable_tx_enh_iface || !enable_port_tx_enh_frame_diag_status"     NOVAL             tx_enh_frame_diag_status    conduit           end             false   "NOVAL"                 2                   channels      NOVAL       }\
    \
    {rx_enh_frame                 output    output        channels                              rx_enh_frame              "!l_enable_rx_enh_iface || !enable_port_rx_enh_frame"                 NOVAL             rx_enh_frame                conduit           end             false   "NOVAL"                 1                   channels      NOVAL       }\
    {rx_enh_frame_lock            output    output        channels                              rx_enh_frame_lock         "!l_enable_rx_enh_iface || !enable_port_rx_enh_frame_lock"            NOVAL             rx_enh_frame_lock           conduit           end             false   "NOVAL"                 1                   channels      NOVAL       }\
    {rx_enh_frame_diag_status     output    output        channels*2                            rx_enh_frame_diag_status  "!l_enable_rx_enh_iface || !enable_port_rx_enh_frame_diag_status"     NOVAL             rx_enh_frame_diag_status    conduit           end             false   "NOVAL"                 2                   channels      NOVAL       }\
    \
    {rx_enh_crc32_err             output    output        channels                              rx_enh_crc32err           "!l_enable_rx_enh_iface || !enable_port_rx_enh_crc32_err"             NOVAL             rx_enh_crc32err             conduit           end             false   "NOVAL"                 1                   channels      NOVAL       }\
    \
    {rx_enh_highber               output    output        channels                              rx_enh_highber            "!l_enable_rx_enh_iface || !enable_port_rx_enh_highber"               NOVAL             rx_enh_highber              conduit           end             false   "NOVAL"                 1                   channels      NOVAL       }\
    {rx_enh_highber_clr_cnt       input     input         channels                              rx_enh_highber_clr_cnt    "!l_enable_rx_enh_iface || !enable_port_rx_enh_highber_clr_cnt"       NOVAL             rx_enh_highber_clr_cnt      conduit           end             false   "NOVAL"                 1                   channels      NOVAL       }\
    {rx_enh_clr_errblk_count      input     input         channels                              rx_enh_clr_errblk_count   "!l_enable_rx_enh_iface || !enable_port_rx_enh_clr_errblk_count"      NOVAL             rx_enh_clr_errblk_count     conduit           end             false   "NOVAL"                 1                   channels      NOVAL       }\
    \
    {rx_enh_blk_lock              output    output        channels                              rx_enh_blk_lock           "!l_enable_rx_enh_iface || !enable_port_rx_enh_blk_lock"              NOVAL             rx_enh_blk_lock             conduit           end             false   "NOVAL"                 1                   channels      NOVAL       }\
    \
    {tx_enh_bitslip               input     input         channels*7                            tx_enh_bitslip            "!l_enable_tx_enh_iface || !enable_port_tx_enh_bitslip"               NOVAL             tx_enh_bitslip              conduit           end             false   "NOVAL"                 7                   channels      NOVAL       }\
    \
    {tx_hip_data                  input     input         channels*64                           tx_hip_data               !enable_hip                                                           NOVAL             tx_hip_data                 conduit           end             false   "NOVAL"                 64                  channels      NOVAL       }\
    {rx_hip_data                  output    output        channels*51                           rx_hip_data               !enable_hip                                                           NOVAL             rx_hip_data                 conduit           end             false   "NOVAL"                 51                  channels      NOVAL       }\
    {hip_pipe_pclk                output    output        1                                     hip_pipe_pclk             !enable_hip                                                           NOVAL             hip_pipe_pclk               conduit           end             false   NOVAL                   NOVAL               NOVAL         NOVAL       }\
    {hip_fixedclk                 output    output        1                                     hip_fixedclk              !enable_hip                                                           NOVAL             hip_fixedclk                conduit           end             false   NOVAL                   NOVAL               NOVAL         NOVAL       }\
    {hip_frefclk                  output    output        channels                              hip_frefclk               !enable_hip                                                           NOVAL             hip_frefclk                 conduit           end             false   "NOVAL"                 1                   channels      NOVAL       }\
    {hip_ctrl                     output    output        channels*8                            hip_ctrl                  !enable_hip                                                           NOVAL             hip_ctrl                    conduit           end             false   "NOVAL"                 8                   channels      NOVAL       }\
    {hip_cal_done                 output    output        channels                              hip_cal_done              !enable_hip                                                           NOVAL             hip_cal_done                conduit           end             false   "NOVAL"                 1                   channels      NOVAL       }\
    \
    {pipe_rate                    input     input         2                                     pipe_rate                 "!l_enable_tx_std_iface || !enable_ports_pipe_sw"                     NOVAL             pipe_rate                   conduit           end             false   NOVAL                   NOVAL               NOVAL         ::altera_xcvr_native_vi::interfaces::elaborate_pipe_rate }\
    {pipe_sw_done                 input     input         2                                     pipe_sw_done              "!l_enable_tx_std_iface || !enable_ports_pipe_sw"                     NOVAL             pipe_sw_done                conduit           end             false   NOVAL                   NOVAL               NOVAL         NOVAL       }\
    {pipe_sw                      output    output        2                                     pipe_sw                   "!l_enable_tx_std_iface || !enable_ports_pipe_sw"                     NOVAL             pipe_sw                     conduit           end             false   NOVAL                   NOVAL               NOVAL         NOVAL       }\
    {pipe_hclk_in                 input     input         1                                     clk                       "!l_enable_tx_std_iface || !enable_ports_pipe_hclk"                   NOVAL             pipe_hclk_in                clock             sink            false   NOVAL                   NOVAL               NOVAL         NOVAL       }\
    {pipe_hclk_out                output    output        1                                     clk                       "!l_enable_tx_std_iface || !enable_ports_pipe_hclk || enable_hip"     NOVAL             pipe_hclk_out               clock             source          false   NOVAL                   NOVAL               NOVAL         NOVAL       }\
    {pipe_g3_txdeemph             input     input         channels*18                           pipe_g3_txdeemph          "!l_enable_tx_std_iface || !enable_ports_pipe_g3_analog"              NOVAL             pipe_g3_txdeemph            conduit           end             false   "NOVAL"                 18                  channels      NOVAL       }\
    {pipe_g3_rxpresethint         input     input         channels*3                            pipe_g3_rxpresethint      "!l_enable_tx_std_iface || !enable_ports_pipe_g3_analog"              NOVAL             pipe_g3_rxpresethint        conduit           end             false   "NOVAL"                 3                   channels      NOVAL       }\
    {pipe_rx_eidleinfersel        input     input         channels*3                            pipe_rx_eidleinfersel     "!l_enable_tx_std_iface || !enable_ports_pipe_rx_elecidle"            NOVAL             pipe_rx_eidleinfersel       conduit           end             false   "NOVAL"                 1                   channels      NOVAL       }\
    {pipe_rx_elecidle             output    output        channels                              pipe_rx_elecidle          "!l_enable_tx_std_iface || !enable_ports_pipe_rx_elecidle"            NOVAL             pipe_rx_elecidle            conduit           end             false   "NOVAL"                 1                   channels      NOVAL       }\
    {pipe_rx_polarity             input     input         channels                              pipe_rx_polarity          "!l_enable_tx_std_iface || !enable_port_pipe_rx_polarity"             NOVAL             pipe_rx_polarity            conduit           end             false   "NOVAL"                 1                   channels      NOVAL       }\
    \
    {reconfig_clk                 input     input         "l_rcfg_ifaces"                       clk                       !rcfg_enable                                                          NOVAL             reconfig_clk                clock             sink            false   "NOVAL"                 1                   l_rcfg_ifaces NOVAL       }\
    {reconfig_reset               input     input         "l_rcfg_ifaces"                       reset                     !rcfg_enable                                                          NOVAL             reconfig_reset              reset             sink            false   "NOVAL"                 1                   l_rcfg_ifaces ::altera_xcvr_native_vi::interfaces::elaborate_reconfig_reset  }\
    {reconfig_write               input     input         "l_rcfg_ifaces"                       write                     !rcfg_enable                                                          NOVAL             reconfig_avmm               avalon            slave           false   "NOVAL"                 1                   l_rcfg_ifaces ::altera_xcvr_native_vi::interfaces::elaborate_reconfig_avmm   }\
    {reconfig_read                input     input         "l_rcfg_ifaces"                       read                      !rcfg_enable                                                          NOVAL             reconfig_avmm               avalon            slave           false   "NOVAL"                 1                   l_rcfg_ifaces NOVAL       }\
    {reconfig_address             input     input         "l_rcfg_ifaces*l_rcfg_addr_bits"      address                   !rcfg_enable                                                          NOVAL             reconfig_avmm               avalon            slave           false   "NOVAL"                 l_rcfg_addr_bits    l_rcfg_ifaces NOVAL       }\
    {reconfig_writedata           input     input         "l_rcfg_ifaces*32"                    writedata                 !rcfg_enable                                                          NOVAL             reconfig_avmm               avalon            slave           false   "NOVAL"                 32                  l_rcfg_ifaces NOVAL       }\
    {reconfig_readdata            output    input         "l_rcfg_ifaces*32"                    readdata                  !rcfg_enable                                                          NOVAL             reconfig_avmm               avalon            slave           false   "NOVAL"                 32                  l_rcfg_ifaces NOVAL       }\
    {reconfig_waitrequest         output    input         "l_rcfg_ifaces"                       waitrequest               !rcfg_enable                                                          NOVAL             reconfig_avmm               avalon            slave           false   "NOVAL"                 1                   l_rcfg_ifaces NOVAL       }\
  }

}

proc ::altera_xcvr_native_vi::interfaces::declare_interfaces {} {
  variable interfaces
  ip_declare_interfaces $interfaces
}

proc ::altera_xcvr_native_vi::interfaces::elaborate {} {
  ip_elaborate_interfaces
}

###############################################################################
########################## TX parallel data elaboration #######################
proc ::altera_xcvr_native_vi::interfaces::elaborate_tx_parallel_data { l_enable_tx_std l_enable_tx_enh l_enable_tx_pcs_dir enable_hip l_std_tx_word_width l_std_tx_word_count l_std_tx_field_width channels enable_simple_interface enh_pld_pcs_width pcs_direct_width enh_rxtxfifo_double_width } {
  if {$l_enable_tx_std && !$enable_hip} {
    create_fragmented_interface $enable_simple_interface "tx_parallel_data" "tx_parallel_data" input $channels 128 $l_std_tx_field_width $l_std_tx_word_count $l_std_tx_word_width 0
  } elseif {$l_enable_tx_enh} {
    if {!$enh_rxtxfifo_double_width} {
       set width $enh_pld_pcs_width
       if { $enh_pld_pcs_width > 64 } {
         set width 64
       }
       create_fragmented_interface $enable_simple_interface "tx_parallel_data" "tx_parallel_data" input $channels 128 $width 1 $width 0
    } else {
        ip_message info "Follow user manual to determine proper connections for \"tx_parallel_data port\" in double width fifo mode."
    }
  } elseif {$l_enable_tx_pcs_dir} {
    create_fragmented_interface $enable_simple_interface "tx_parallel_data" "tx_parallel_data" input $channels 128 $pcs_direct_width 1 $pcs_direct_width 0
  }
}


proc ::altera_xcvr_native_vi::interfaces::elaborate_tx_control { l_enable_tx_enh channels enable_simple_interface enh_pld_pcs_width protocol_mode } {
  if {$l_enable_tx_enh && $enable_simple_interface} {
    if {$enh_pld_pcs_width <= 64} {
      ip_set "port.tx_control.termination" 1
    } else {
      # Default to "8" bits of tx_control (10GBase-R mode)
      set width 8
      if {$protocol_mode == "basic_enh" || $protocol_mode == "interlaken_mode" } {
        set width [expr {$enh_pld_pcs_width - 64}]
      } elseif {$protocol_mode == "interlaken_mode"} {
        set width 3
      } elseif {$protocol_mode == "teng_baser_mode" || $protocol_mode == "teng_1588_mode"} {
        set width 8
      }
      create_fragmented_interface $enable_simple_interface "tx_control" "tx_control" input $channels 18 $width 1 $width 0
    }
  }
}
proc ::altera_xcvr_native_vi::interfaces::elaborate_tx_err_ins { l_enable_tx_enh channels enable_simple_interface enh_pld_pcs_width protocol_mode } {
   if {$l_enable_tx_enh && $enable_simple_interface && $enh_pld_pcs_width > 64 && ($protocol_mode == "teng_baser_mode"  || $protocol_mode == "teng_1588_mode" || $protocol_mode == "interlaken_mode")} {
      create_fragmented_interface $enable_simple_interface "tx_err_ins" "tx_control" input $channels 18 18 1 1 8
   }
}

proc ::altera_xcvr_native_vi::interfaces::elaborate_tx_datak { l_enable_tx_std enable_hip l_std_tx_word_count l_std_tx_field_width enable_simple_interface channels std_tx_8b10b_enable } {
  if {$l_enable_tx_std && !$enable_hip && $std_tx_8b10b_enable} {
    create_fragmented_interface $enable_simple_interface "tx_datak" "tx_parallel_data" input $channels 128 $l_std_tx_field_width $l_std_tx_word_count 1 8
  }
}


proc ::altera_xcvr_native_vi::interfaces::elaborate_tx_forcedisp { l_enable_tx_std enable_hip l_enable_std_pipe l_std_tx_word_count l_std_tx_field_width enable_simple_interface channels std_tx_8b10b_enable std_tx_8b10b_disp_ctrl_enable } {
  if {$l_enable_tx_std && !$enable_hip && !$l_enable_std_pipe && $std_tx_8b10b_enable && $std_tx_8b10b_disp_ctrl_enable} {
    create_fragmented_interface $enable_simple_interface "tx_forcedisp" "tx_parallel_data" input $channels 128 $l_std_tx_field_width $l_std_tx_word_count 1 9
  }
}


proc ::altera_xcvr_native_vi::interfaces::elaborate_tx_dispval { l_enable_tx_std enable_hip l_enable_std_pipe l_std_tx_word_count l_std_tx_field_width enable_simple_interface channels std_tx_8b10b_enable std_tx_8b10b_disp_ctrl_enable } {
  if {$l_enable_tx_std && !$enable_hip && !$l_enable_std_pipe && $std_tx_8b10b_enable && $std_tx_8b10b_disp_ctrl_enable} {
    create_fragmented_interface $enable_simple_interface "tx_dispval" "tx_parallel_data" input $channels 128 $l_std_tx_field_width $l_std_tx_word_count 1 10
  }
}


proc ::altera_xcvr_native_vi::interfaces::elaborate_tx_pipe_signals { l_enable_tx_std enable_hip l_enable_std_pipe protocol_mode l_std_tx_word_count l_std_tx_field_width enable_simple_interface channels } {
  if {$l_enable_tx_std && !$enable_hip && $l_enable_std_pipe} {
    create_fragmented_interface $enable_simple_interface "pipe_tx_compliance" "tx_parallel_data" input $channels 128 $l_std_tx_field_width $l_std_tx_word_count 1 9
    create_fragmented_interface $enable_simple_interface "pipe_tx_elecidle" "tx_parallel_data" input $channels 128 $l_std_tx_field_width $l_std_tx_word_count 1 10
    create_fragmented_interface $enable_simple_interface "pipe_tx_detectrx_loopback" "tx_parallel_data" input $channels 128 128 1 1 46
    create_fragmented_interface $enable_simple_interface "pipe_powerdown" "tx_parallel_data" input $channels 128 128 1 2 47
    create_fragmented_interface $enable_simple_interface "pipe_tx_margin" "tx_parallel_data" input $channels 128 128 1 3 49
    if {$protocol_mode == "pipe_g2"} {
      create_fragmented_interface $enable_simple_interface "pipe_tx_deemph" "tx_parallel_data" input $channels 128 128 1 1 52
    }
    create_fragmented_interface $enable_simple_interface "pipe_tx_swing" "tx_parallel_data" input $channels 128 128 1 1 53
    if {$protocol_mode == "pipe_g3"} {
      create_fragmented_interface $enable_simple_interface "pipe_tx_sync_hdr" "tx_parallel_data" input $channels 128 128 1 2 54
      create_fragmented_interface $enable_simple_interface "pipe_tx_blk_start" "tx_parallel_data" input $channels 128 128 1 1 56
      create_fragmented_interface $enable_simple_interface "pipe_tx_data_valid" "tx_parallel_data" input $channels 128 128 1 1 60
    }
  }
}


proc ::altera_xcvr_native_vi::interfaces::elaborate_unused_tx_parallel_data { l_enable_tx_std l_enable_tx_enh l_enable_tx_pcs_dir enable_hip l_enable_std_pipe protocol_mode l_std_tx_word_width l_std_tx_word_count l_std_tx_field_width enable_simple_interface channels std_tx_8b10b_enable std_tx_8b10b_disp_ctrl_enable enh_pld_pcs_width pcs_direct_width } {
  if {$enable_simple_interface} {
    set unused_list {}
    if {$l_enable_tx_std && !$enable_hip } {
      set width $l_std_tx_word_width
      if {$std_tx_8b10b_enable || $l_enable_std_pipe } {
        set width 9
        if {$std_tx_8b10b_disp_ctrl_enable || $l_enable_std_pipe} {
          set width 11
        }
      }
      set unused_list [create_expanded_index_list $channels 128 $l_std_tx_field_width $l_std_tx_word_count $width 0 unused]
      if {$l_enable_std_pipe} {
        set unused_list [::alt_xcvr::utils::common::intersect $unused_list [create_expanded_index_list $channels 128 $l_std_tx_field_width $l_std_tx_word_count 1 9 unused]]
        set unused_list [::alt_xcvr::utils::common::intersect $unused_list [create_expanded_index_list $channels 128 $l_std_tx_field_width $l_std_tx_word_count 1 10 unused]]
        set unused_list [::alt_xcvr::utils::common::intersect $unused_list [create_expanded_index_list $channels 128 128 1 1 46 unused]]
        set unused_list [::alt_xcvr::utils::common::intersect $unused_list [create_expanded_index_list $channels 128 128 1 2 47 unused]]
        set unused_list [::alt_xcvr::utils::common::intersect $unused_list [create_expanded_index_list $channels 128 128 1 3 49 unused]]
        if {$protocol_mode == "pipe_g2"} {
          set unused_list [::alt_xcvr::utils::common::intersect $unused_list [create_expanded_index_list $channels 128 128 1 1 52 unused]]
        }
        set unused_list [::alt_xcvr::utils::common::intersect $unused_list [create_expanded_index_list $channels 128 128 1 1 53 unused]]
        if {$protocol_mode == "pipe_g3"} {
          set unused_list [::alt_xcvr::utils::common::intersect $unused_list [create_expanded_index_list $channels 128 128 1 2 54 unused]]
          set unused_list [::alt_xcvr::utils::common::intersect $unused_list [create_expanded_index_list $channels 128 128 1 1 56 unused]]
          set unused_list [::alt_xcvr::utils::common::intersect $unused_list [create_expanded_index_list $channels 128 128 1 1 60 unused]]
        }
      }
    } elseif {$l_enable_tx_enh && $enable_simple_interface} {
      set width $enh_pld_pcs_width
      if {$enh_pld_pcs_width > 64} {
        set width 64
      }
      set unused_list [create_expanded_index_list $channels 128 128 1 $width 0 unused]
    } elseif {$l_enable_tx_pcs_dir} {
      set unused_list [create_expanded_index_list $channels 128 128 1 $pcs_direct_width 0 unused]
    }
    if {[llength $unused_list] > 0} {
      create_fragmented_conduit "unused_tx_parallel_data" [add_fragment_prefix $unused_list "tx_parallel_data"] input input
    }
  }
}


proc ::altera_xcvr_native_vi::interfaces::elaborate_unused_tx_control { l_enable_tx_enh channels enable_simple_interface enh_pld_pcs_width protocol_mode } {
  if {$l_enable_tx_enh && $enable_simple_interface} {
    if {$enh_pld_pcs_width > 64} {
      # Default to "8" bits of tx_control (10GBase-R mode)
      set width 8
      if {$protocol_mode == "basic_enh" || $protocol_mode == "interlaken_mode" } {
        set width [expr {$enh_pld_pcs_width - 64}]
        set unused_list [create_expanded_index_list $channels 18 18 1 $width 0 unused]
      } elseif {$protocol_mode == "teng_baser_mode"  || $protocol_mode == "teng_1588_mode"} {
        set width 9
        set unused_list [create_expanded_index_list $channels 18 18 1 $width 0 unused]
      } elseif {$protocol_mode == "interlaken_mode" } {
        set unused_list [create_expanded_index_list $channels 18 3 1 3 0 unused]
        set unused_list [::alt_xcvr::utils::common::intersect $unused_list [create_expanded_index_list $channels 18 18 1 1 8 unused]]
      }
      create_fragmented_conduit "unused_tx_control" [add_fragment_prefix $unused_list "tx_control"] input input
    }
  }
}
######################## End TX parallel data elaboration #####################
###############################################################################


###############################################################################
########################## RX parallel data elaboration #######################
proc ::altera_xcvr_native_vi::interfaces::elaborate_rx_parallel_data { l_enable_rx_std l_enable_rx_enh l_enable_rx_pcs_dir enable_hip l_std_rx_word_width l_std_rx_word_count l_std_rx_field_width channels enable_simple_interface enh_pld_pcs_width pcs_direct_width enh_rxtxfifo_double_width } {
  if {$l_enable_rx_std && !$enable_hip} {
    create_fragmented_interface $enable_simple_interface "rx_parallel_data" "rx_parallel_data" output $channels 128 $l_std_rx_field_width $l_std_rx_word_count $l_std_rx_word_width 0
  } elseif {$l_enable_rx_enh} {
    if {!$enh_rxtxfifo_double_width} {
       set width $enh_pld_pcs_width
       if { $enh_pld_pcs_width > 64 } {
         set width 64
       }
       create_fragmented_interface $enable_simple_interface "rx_parallel_data" "rx_parallel_data" output $channels 128 $width 1 $width 0
    } else {
        ip_message info "Follow user manual to determine proper connections for \"rx_parallel_data port\" in double width fifo mode."
    }
  } elseif {$l_enable_rx_pcs_dir} {
    create_fragmented_interface $enable_simple_interface "rx_parallel_data" "tx_parallel_data" output $channels 128 $pcs_direct_width 1 $pcs_direct_width 0
  }
}


proc ::altera_xcvr_native_vi::interfaces::elaborate_rx_control { l_enable_rx_enh channels enable_simple_interface enh_pld_pcs_width protocol_mode } {
  if {$l_enable_rx_enh && $enable_simple_interface} {
    if {$enh_pld_pcs_width <= 64} {
      ip_set "port.rx_control.termination" 1
    } else {
      # Default to 10 bits for Interlaken
      set width 10
      if {$protocol_mode == "basic_enh"} {
        set width [expr {$enh_pld_pcs_width - 64}]
      } elseif {$protocol_mode == "teng_baser_mode" || $protocol_mode == "teng_1588_mode"} {
        set width 8 
      }
      create_fragmented_interface $enable_simple_interface "rx_control" "rx_control" output $channels 20 $width 1 $width 0
    }
  }
}


proc ::altera_xcvr_native_vi::interfaces::elaborate_rx_datak { l_enable_rx_std enable_hip l_std_rx_word_count l_std_rx_field_width enable_simple_interface channels std_rx_8b10b_enable } {
  if {$l_enable_rx_std && !$enable_hip && $std_rx_8b10b_enable} {
    create_fragmented_interface $enable_simple_interface "rx_datak" "rx_parallel_data" output $channels 128 $l_std_rx_field_width $l_std_rx_word_count 1 8
  }
}


proc ::altera_xcvr_native_vi::interfaces::elaborate_rx_errdetect { l_enable_rx_std enable_hip l_enable_std_pipe l_std_rx_word_count l_std_rx_field_width enable_simple_interface channels std_rx_8b10b_enable } {
  if {$l_enable_rx_std && !$enable_hip && !$l_enable_std_pipe && $std_rx_8b10b_enable} {
    create_fragmented_interface $enable_simple_interface "rx_errdetect" "rx_parallel_data" output $channels 128 $l_std_rx_field_width $l_std_rx_word_count 1 9
  }
}


proc ::altera_xcvr_native_vi::interfaces::elaborate_rx_disperr { l_enable_rx_std enable_hip l_enable_std_pipe l_std_rx_word_count l_std_rx_field_width enable_simple_interface channels std_rx_8b10b_enable } {
  if {$l_enable_rx_std && !$enable_hip && !$l_enable_std_pipe && $std_rx_8b10b_enable} {
    create_fragmented_interface $enable_simple_interface "rx_disperr" "rx_parallel_data" output $channels 128 $l_std_rx_field_width $l_std_rx_word_count 1 11
  }
}


proc ::altera_xcvr_native_vi::interfaces::elaborate_rx_runningdisp { l_enable_rx_std enable_hip l_enable_std_pipe l_std_rx_word_count l_std_rx_field_width enable_simple_interface channels std_rx_8b10b_enable } {
  if {$l_enable_rx_std && !$enable_hip && !$l_enable_std_pipe && $std_rx_8b10b_enable} {
    create_fragmented_interface $enable_simple_interface "rx_runningdisp" "rx_parallel_data" output $channels 128 $l_std_rx_field_width $l_std_rx_word_count 1 15
  }
}


proc ::altera_xcvr_native_vi::interfaces::elaborate_rx_syncstatus { l_enable_rx_std enable_hip l_std_rx_word_count l_std_rx_field_width enable_simple_interface channels std_rx_word_aligner_mode } {
  if {$l_enable_rx_std && !$enable_hip && $std_rx_word_aligner_mode != "bitslip" } {
    create_fragmented_interface $enable_simple_interface "rx_syncstatus" "rx_parallel_data" output $channels 128 $l_std_rx_field_width $l_std_rx_word_count 1 10
  }
}


proc ::altera_xcvr_native_vi::interfaces::elaborate_rx_patterndetect { l_enable_rx_std enable_hip l_enable_std_pipe l_std_rx_word_count l_std_rx_field_width enable_simple_interface channels std_rx_word_aligner_mode } {
  if {$l_enable_rx_std && !$enable_hip && !$l_enable_std_pipe && $std_rx_word_aligner_mode != "bitslip" } {
    create_fragmented_interface $enable_simple_interface "rx_patterndetect" "rx_parallel_data" output $channels 128 $l_std_rx_field_width $l_std_rx_word_count 1 12
  }
}


proc ::altera_xcvr_native_vi::interfaces::elaborate_rx_rmfifostatus { l_enable_rx_std enable_hip l_enable_std_pipe l_std_rx_word_count l_std_rx_field_width enable_simple_interface channels std_rx_rmfifo_mode } {
  if {$l_enable_rx_std && !$enable_hip && !$l_enable_std_pipe && $std_rx_rmfifo_mode != "disabled" } {
    create_fragmented_interface $enable_simple_interface "rx_rmfifostatus" "rx_parallel_data" output $channels 128 $l_std_rx_field_width $l_std_rx_word_count 2 13 
  }
}


proc ::altera_xcvr_native_vi::interfaces::elaborate_rx_pipe_signals { l_enable_rx_std enable_hip l_enable_std_pipe protocol_mode l_std_rx_word_count l_std_rx_field_width enable_simple_interface channels } {
  if {$l_enable_rx_std && !$enable_hip && $l_enable_std_pipe} {
    create_fragmented_interface $enable_simple_interface "pipe_phy_status" "rx_parallel_data" output $channels 128 128 1 1 65
    create_fragmented_interface $enable_simple_interface "pipe_rx_valid" "rx_parallel_data" output $channels 128 128 1 1 66
    create_fragmented_interface $enable_simple_interface "pipe_rx_status" "rx_parallel_data" output $channels 128 128 1 3 67
    if {$protocol_mode == "pipe_g3"} {
      create_fragmented_interface $enable_simple_interface "pipe_rx_sync_hdr" "rx_parallel_data" output $channels 128 128 1 2 70
      create_fragmented_interface $enable_simple_interface "pipe_rx_blk_start" "rx_parallel_data" output $channels 128 128 1 1 72
      create_fragmented_interface $enable_simple_interface "pipe_rx_data_valid" "rx_parallel_data" output $channels 128 128 1 1 76
    }
  }
}


proc ::altera_xcvr_native_vi::interfaces::elaborate_unused_rx_parallel_data { l_enable_rx_std l_enable_rx_enh l_enable_rx_pcs_dir enable_hip l_enable_std_pipe protocol_mode l_std_rx_word_width l_std_rx_word_count l_std_rx_field_width enable_simple_interface channels std_rx_8b10b_enable std_rx_word_aligner_mode std_rx_rmfifo_mode enh_pld_pcs_width pcs_direct_width } {
  if {$enable_simple_interface} {
    set unused_list {}
    if {$l_enable_rx_std && !$enable_hip} {
      set unused_list [create_expanded_index_list $channels 128 $l_std_rx_field_width $l_std_rx_word_count $l_std_rx_word_width 0 unused]
      if {$std_rx_8b10b_enable} {
        set unused_list [::alt_xcvr::utils::common::intersect $unused_list [create_expanded_index_list $channels 128 $l_std_rx_field_width $l_std_rx_word_count 1 8 unused]]
        if {!$l_enable_std_pipe} {
          set unused_list [::alt_xcvr::utils::common::intersect $unused_list [create_expanded_index_list $channels 128 $l_std_rx_field_width $l_std_rx_word_count 1 9 unused]]
          set unused_list [::alt_xcvr::utils::common::intersect $unused_list [create_expanded_index_list $channels 128 $l_std_rx_field_width $l_std_rx_word_count 1 11 unused]]
          set unused_list [::alt_xcvr::utils::common::intersect $unused_list [create_expanded_index_list $channels 128 $l_std_rx_field_width $l_std_rx_word_count 1 15 unused]]
        }
      }
      if {$std_rx_word_aligner_mode != "bitslip"} {
        if {!$l_enable_std_pipe} {
          set unused_list [::alt_xcvr::utils::common::intersect $unused_list [create_expanded_index_list $channels 128 $l_std_rx_field_width $l_std_rx_word_count 1 10 unused]]
          set unused_list [::alt_xcvr::utils::common::intersect $unused_list [create_expanded_index_list $channels 128 $l_std_rx_field_width $l_std_rx_word_count 1 12 unused]]
        }
      }
      if {$std_rx_rmfifo_mode != "disabled" && !$l_enable_std_pipe} {
        set unused_list [::alt_xcvr::utils::common::intersect $unused_list [create_expanded_index_list $channels 128 $l_std_rx_field_width $l_std_rx_word_count 2 13 unused]]
      }

      if {$l_enable_std_pipe} {
        set unused_list [::alt_xcvr::utils::common::intersect $unused_list [create_expanded_index_list $channels 128 128 1 1 65 unused]]
        set unused_list [::alt_xcvr::utils::common::intersect $unused_list [create_expanded_index_list $channels 128 128 1 1 66 unused]]
        set unused_list [::alt_xcvr::utils::common::intersect $unused_list [create_expanded_index_list $channels 128 128 1 3 67 unused]]
        if {$protocol_mode == "pipe_g3"} {
          set unused_list [::alt_xcvr::utils::common::intersect $unused_list [create_expanded_index_list $channels 128 128 1 2 70 unused]]
          set unused_list [::alt_xcvr::utils::common::intersect $unused_list [create_expanded_index_list $channels 128 128 1 1 72 unused]]
          set unused_list [::alt_xcvr::utils::common::intersect $unused_list [create_expanded_index_list $channels 128 128 1 1 76 unused]]
        }
      }
      
    } elseif {$l_enable_rx_enh} {
      set width $enh_pld_pcs_width
      if {$enh_pld_pcs_width > 64} {
        set width 64
      }
      set unused_list [create_expanded_index_list $channels 128 128 1 $width 0 unused]
    } elseif {$l_enable_rx_pcs_dir} {
      set unused_list [create_expanded_index_list $channels 128 128 1 $pcs_direct_width 0 unused]
    }
    if {[llength $unused_list] > 0} {
      create_fragmented_conduit "unused_rx_parallel_data" [add_fragment_prefix $unused_list "rx_parallel_data"] output output
    }
  }
}


proc ::altera_xcvr_native_vi::interfaces::elaborate_unused_rx_control { l_enable_rx_enh channels enable_simple_interface enh_pld_pcs_width protocol_mode } {
  if {$l_enable_rx_enh && $enable_simple_interface} {
    if {$enh_pld_pcs_width > 64} {
      # Default to "10" bits of rx_control (Interlaken)
      set width 10
      if {$protocol_mode == "basic_enh"} {
        set width [expr {$enh_pld_pcs_width - 64}]
      } elseif {$protocol_mode == "teng_baser_mode" || $protocol_mode == "teng_1588_mode"} {
        set width 8
      }
      set unused_list [create_expanded_index_list $channels 20 20 1 $width 0 unused]
      create_fragmented_conduit "unused_rx_control" [add_fragment_prefix $unused_list "rx_control"] output output
    }
  }
}

proc ::altera_xcvr_native_vi::interfaces::elaborate_rx_bitslip { l_enable_rx_std_iface enable_port_rx_std_bitslip l_enable_rx_enh_iface enable_port_rx_enh_bitslip } {
  ip_set "port.rx_bitslip.TERMINATION" [expr {(!$l_enable_rx_std_iface||!$enable_port_rx_std_bitslip)&&(!$l_enable_rx_enh_iface||!$enable_port_rx_enh_bitslip)}]
}

######################## End RX parallel data elaboration #####################
###############################################################################

proc ::altera_xcvr_native_vi::interfaces::elaborate_pipe_rate { enable_hip channels } {
  set width [expr {$enable_hip ? ($channels * 2) : 2}] 
  ip_set "port.pipe_rate.WIDTH_EXPR" $width
}


proc ::altera_xcvr_native_vi::interfaces::elaborate_reconfig_reset { } {
  ip_set "interface.reconfig_reset.associatedclock" reconfig_clk
}

proc ::altera_xcvr_native_vi::interfaces::elaborate_reconfig_avmm { PROP_IFACE_NAME } {
  ip_set "interface.${PROP_IFACE_NAME}.associatedclock" reconfig_clk
#  ip_set "interface.${PROP_IFACE_NAME}.associatedreset" reconfig_reset
}
