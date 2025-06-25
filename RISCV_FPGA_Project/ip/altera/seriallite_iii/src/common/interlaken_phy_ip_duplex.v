// (C) 2001-2013 Altera Corporation. All rights reserved.
// Your use of Altera Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License Subscription 
// Agreement, Altera MegaCore Function License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


`timescale 1 ps / 1 ps

module interlaken_phy_ip_duplex #
(
   parameter                     lanes             = 4,
   parameter                     pll_ref_freq      = "103.125 MHz",
   parameter                     data_rate         = "10312.5 Mbps",
   parameter                     meta_frame_length = 8191,
   parameter			 pll_type          = "CMU",
   parameter                     ecc_enable        = 0
)
(
   // Clocks and reset
   input                         pll_ref_clk,
   input                         tx_coreclkin,
   output      [lanes-1:0]       tx_clkout,
   output                        tx_ready, 
   output                        pll_locked,
   input                         rx_coreclkin,
   output      [lanes-1:0]       rx_clkout,
   output                        rx_ready,

   // Transmit Data Interface
   output                        tx_sync_done,
   output      [lanes-1:0]       tx_serial_data,
   input       [lanes-1:0]       tx_datavalid,
   input       [lanes-1:0]       tx_ctrlin,
   input       [lanes-1:0]       tx_crcerr,
   input       [(lanes*64)-1:0]  tx_parallel_data,
   output      [lanes-1:0]       tx_datain_bp,

   input       [lanes-1:0]       rx_serial_data,
   output      [lanes-1:0]       rx_datavalid,
   output      [lanes-1:0]       rx_crc32err, 
   output      [lanes-1:0]       rx_frame_lock,
   output      [lanes-1:0]       rx_align_val,
   output      [lanes-1:0]       rx_ctrlout,
   output      [lanes-1:0]       rx_fifofull,
   output      [lanes-1:0]       rx_fifopfull,
   output      [lanes-1:0]       rx_fifopempty,
   output      [lanes-1:0]       rx_block_frame_lock,
   output      [(lanes*64)-1:0]  rx_parallel_data,
   input       [lanes-1:0]       rx_dataout_bp,
   input       [lanes-1:0]       rx_fifo_clr,


   // Management Interface
   input                         phy_mgmt_clk,
   input                         phy_mgmt_clk_reset,
   input       [8:0]             phy_mgmt_address,
   input                         phy_mgmt_read,
   output      [31:0]            phy_mgmt_readdata,
   input                         phy_mgmt_write,
   input       [31:0]            phy_mgmt_writedata,
   output                        phy_mgmt_waitrequest,

   // Reconfiguration Interafce
   input       [(lanes*140)-1:0] reconfig_to_xcvr,
   output      [(lanes*92)-1:0]  reconfig_from_xcvr
);

   altera_xcvr_interlaken #
   (
      .PLEX              ("DUPLEX"),
      .LINKWIDTH         (lanes),
      .METALEN           (meta_frame_length),
      .EXTRA_SIGS        (1),
      .PLL_REFCLK_CNT    (1),
      .PLL_REF_FREQ      (pll_ref_freq),
      .PLL_REFCLK_SELECT ("0"),
      .PLLS              (1),
      .PLL_TYPE          (pll_type),
      .PLL_SELECT        (0),
      .DATA_RATE         (data_rate),
      .BASE_DATA_RATE    (data_rate),
      .TX_USE_CORECLK    (1),
      .RX_USE_CORECLK    (1),
      .sys_clk_in_mhz    (150),
      .BONDED_GROUP_SIZE (1),
      .ECC_ENABLE        (ecc_enable)
   )
   interlaken_phy_ip_duplex_inst
   (
      .pll_ref_clk          (pll_ref_clk),
      .tx_coreclkin         (tx_coreclkin),
      .tx_clkout            (tx_clkout),
      .tx_ready             (tx_ready),
      .pll_locked           (pll_locked),
      .tx_sync_done         (tx_sync_done),
      .tx_serial_data       (tx_serial_data),
      .tx_datavalid         (tx_datavalid),
      .tx_ctrlin            (tx_ctrlin),
      .tx_crcerr            (tx_crcerr),
      .tx_parallel_data     (tx_parallel_data),
      .tx_datain_bp         (tx_datain_bp),

      .rx_coreclkin         (rx_coreclkin),
      .rx_clkout            (rx_clkout),
      .rx_ready             (rx_ready),
      .rx_serial_data       (rx_serial_data),
      .rx_crc32err          (rx_crc32err),
      .rx_frame_lock        (rx_frame_lock),
      .rx_align_val         (rx_align_val),
      .rx_fifopempty        (rx_fifopempty),
      .rx_fifofull          (rx_fifofull),
      .rx_fifopfull	    (rx_fifopfull),
      .rx_block_frame_lock  (rx_block_frame_lock),
      .rx_ctrlout           (rx_ctrlout),
      .rx_datavalid         (rx_datavalid),
      .rx_parallel_data     (rx_parallel_data),
      .rx_dataout_bp        (rx_dataout_bp),
      .rx_fifo_clr          (rx_fifo_clr),


      .phy_mgmt_clk         (phy_mgmt_clk),
      .phy_mgmt_clk_reset   (phy_mgmt_clk_reset),
      .phy_mgmt_address     (phy_mgmt_address),
      .phy_mgmt_read        (phy_mgmt_read),
      .phy_mgmt_readdata    (phy_mgmt_readdata),
      .phy_mgmt_write       (phy_mgmt_write),
      .phy_mgmt_writedata   (phy_mgmt_writedata),
      .phy_mgmt_waitrequest (phy_mgmt_waitrequest),
      .reconfig_to_xcvr     (reconfig_to_xcvr),
      .reconfig_from_xcvr   (reconfig_from_xcvr),
      .tx_user_clkout       (),
      .rx_user_clkout       ()

   );

endmodule
