/*
*******************************************************************************
# (C) 2001-2010 Altera Corporation. All rights reserved.
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
*******************************************************************************
*/

//synthesis translate_off

`timescale 1ns / 1ps

module test_bench 
;
   reg         clk_0;
   reg         refclk;
   reg         reset_n;
   wire        rapidio_0_clk_clk;
   wire        clk_clk;
   wire        reset_reset_n;
   wire        rapidio_0_exported_connections_io_m_rd_readerror;
   wire        rapidio_0_exported_connections_master_enable;
   wire [16:0] rapidio_0_exported_connections_reconfig_fromgxb;
   wire        rapidio_0_exported_connections_packet_transmitted;
   wire        rapidio_0_exported_connections_packet_cancelled;
   wire        rapidio_0_exported_connections_port_initialized;
   wire        rapidio_0_exported_connections_packet_crc_error;
   wire [3:0]  rapidio_0_exported_connections_td;
   wire        rapidio_0_exported_connections_symbol_error;
   wire [6:0]  rapidio_0_exported_connections_atxwlevel;
   wire        rapidio_0_exported_connections_packet_retry;
   wire        rapidio_0_exported_connections_buf_av3;
   wire        rapidio_0_exported_connections_txclk;
   wire        rapidio_0_exported_connections_buf_av1;
   wire        rapidio_0_exported_connections_gxb_powerdown;
   wire        rapidio_0_exported_connections_rxclk;
   wire        rapidio_0_exported_connections_packet_not_accepted;
   wire [15:0] rapidio_0_exported_connections_ef_ptr;
   wire        rapidio_0_exported_connections_char_err;
   wire [3:0]  rapidio_0_exported_connections_rd;
   wire [6:0]  rapidio_0_exported_connections_arxwlevel;
   wire        rapidio_0_exported_connections_io_s_rd_readerror;
   wire        rapidio_0_exported_connections_gxbpll_locked;
   wire        rapidio_0_exported_connections_port_error;
   wire        rapidio_0_exported_connections_atxovf;
   wire        rapidio_0_exported_connections_reconfig_clk;
   wire        rapidio_0_exported_connections_buf_av2;
   wire [7:0]  rapidio_0_exported_connections_rx_errdetect;
   wire        rapidio_0_exported_connections_rxgxbclk;
   wire [3:0]  rapidio_0_exported_connections_reconfig_togxb;
   wire        rapidio_0_exported_connections_rx_packet_dropped;
   wire        rapidio_0_exported_connections_packet_accepted;
   wire        rapidio_0_exported_connections_multicast_event_tx;
   wire        rapidio_0_exported_connections_multicast_event_rx;
   wire        rapidio_0_exported_connections_buf_av0;
   wire        rapidio_0_exported_connections_mnt_s_readerror;    

   //Set up the Dut
   rio_sys DUT
   (
      .clk_clk                                            (clk_0), //system clock
      .rapidio_0_clk_clk                                  (refclk), //reference clock
      .reset_reset_n                                      (reset_n), //active low reset
      .rapidio_0_exported_connections_io_m_rd_readerror   (1'b0),
      .rapidio_0_exported_connections_master_enable       (rapidio_0_exported_connections_master_enable),
      .rapidio_0_exported_connections_reconfig_fromgxb    (rapidio_0_exported_connections_reconfig_fromgxb),
      .rapidio_0_exported_connections_packet_transmitted  (rapidio_0_exported_connections_packet_transmitted),
      .rapidio_0_exported_connections_packet_cancelled    (rapidio_0_exported_connections_packet_cancelled),
      .rapidio_0_exported_connections_port_initialized    (rapidio_0_exported_connections_port_initialized),
      .rapidio_0_exported_connections_packet_crc_error    (rapidio_0_exported_connections_packet_crc_error),
      .rapidio_0_exported_connections_td                  (rapidio_0_exported_connections_td),
      .rapidio_0_exported_connections_symbol_error        (rapidio_0_exported_connections_symbol_error),
      .rapidio_0_exported_connections_atxwlevel           (rapidio_0_exported_connections_atxwlevel),
      .rapidio_0_exported_connections_packet_retry        (rapidio_0_exported_connections_packet_retry),
      .rapidio_0_exported_connections_buf_av3             (rapidio_0_exported_connections_buf_av3),
      .rapidio_0_exported_connections_txclk               (rapidio_0_exported_connections_txclk),
      .rapidio_0_exported_connections_buf_av1             (rapidio_0_exported_connections_buf_av1),
      .rapidio_0_exported_connections_gxb_powerdown       (1'b0),
      .rapidio_0_exported_connections_rxclk               (rapidio_0_exported_connections_rxclk),
      .rapidio_0_exported_connections_packet_not_accepted (rapidio_0_exported_connections_packet_not_accepted),
      .rapidio_0_exported_connections_ef_ptr              (16'd0),
      .rapidio_0_exported_connections_char_err            (rapidio_0_exported_connections_char_err),
      .rapidio_0_exported_connections_rd                  (rapidio_0_exported_connections_rd),
      .rapidio_0_exported_connections_arxwlevel           (rapidio_0_exported_connections_arxwlevel),
      .rapidio_0_exported_connections_io_s_rd_readerror   (rapidio_0_exported_connections_io_s_rd_readerror),
      .rapidio_0_exported_connections_gxbpll_locked       (rapidio_0_exported_connections_gxbpll_locked),
      .rapidio_0_exported_connections_port_error          (rapidio_0_exported_connections_port_error),
      .rapidio_0_exported_connections_atxovf              (rapidio_0_exported_connections_atxovf),
      .rapidio_0_exported_connections_reconfig_clk        (1'b0),
      .rapidio_0_exported_connections_buf_av2             (rapidio_0_exported_connections_buf_av2),
      .rapidio_0_exported_connections_rx_errdetect        (rapidio_0_exported_connections_rx_errdetect),
      .rapidio_0_exported_connections_rxgxbclk            (rapidio_0_exported_connections_rxgxbclk),
      .rapidio_0_exported_connections_reconfig_togxb      (4'b010),
      .rapidio_0_exported_connections_rx_packet_dropped   (rapidio_0_exported_connections_rx_packet_dropped),
      .rapidio_0_exported_connections_packet_accepted     (rapidio_0_exported_connections_packet_accepted),
      .rapidio_0_exported_connections_multicast_event_tx  (1'b0),
      .rapidio_0_exported_connections_multicast_event_rx  (rapidio_0_exported_connections_multicast_event_rx),
      .rapidio_0_exported_connections_buf_av0             (rapidio_0_exported_connections_buf_av0),
      .rapidio_0_exported_connections_mnt_s_readerror     (rapidio_0_exported_connections_mnt_s_readerror)
   );

   initial
      clk_0 = 1'b0;
      always
      #4 clk_0 <= ~clk_0;
   initial
      refclk = 1'b0;
      always
      #4 refclk <= ~refclk;
   initial begin
      reset_n <= 0;
      #200 reset_n <= 1;
   end

   assign rapidio_0_exported_connections_rd = rapidio_0_exported_connections_td;

endmodule

//synthesis translate_on
