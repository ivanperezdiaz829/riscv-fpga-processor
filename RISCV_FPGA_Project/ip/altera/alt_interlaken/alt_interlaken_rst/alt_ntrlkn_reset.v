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

//This module combined all Quard of tranceivers' tx_digitalreset and rx_digitalreset
//To form a merged and syncd tx_lane_arst and rx_lane_arst. Duplicated signals also
//sent to tx or rx phase compensated fifo to clear the fifos. 
//7-07-2011 JZ

module alt_ntrlkn_reset #(
       parameter SIM_FAST_RESET = 0
        )
      (
      input  reset,                   //Soft or hard reset
      input  cal_blk_clk,             //Slow 50Mhz clock that the reset sequence run on
      input  common_tx_clk,
      input  common_rx_clk,
      input  tx_mac_clk,
      input  rx_mac_clk,

      output tx_mac_arst,             //Sync with tx_mac_clk
      output rx_mac_arst,             //Sync with rx_mac_clk
      output tx_lane_arst,            //Sync with common_tx_clk.

      input  hs0_reco_busy,
      input  hs0_rx_freqlocked_n,
      input  hs0_pll_locked_n,         //CMU or ATX PLL lock signals.
      output hs0_pll_powerdown,    
      output hs0_tx_digitalreset,      //Sync with cal_blk_clk
      output hs0_rx_digitalreset,      //Sync with cal_blk_clk
      output hs0_rx_analogreset,       //Sync with cal_blk_clk
      output hs0_tx_lane_arst_early,   //Sync with common_tx_clk one cycle earlier than tx_lane_arst.
      output hs0_rx_lane_arst_early,   //Sync with common_rx_clk one cycle earlier than rx_lane_arst.

      input  hs1_reco_busy,
      input  hs1_rx_freqlocked_n,
      input  hs1_pll_locked_n,
      output hs1_pll_powerdown,
      output hs1_tx_digitalreset,
      output hs1_rx_digitalreset,
      output hs1_rx_analogreset,
      output hs1_tx_lane_arst_early,
      output hs1_rx_lane_arst_early,

      input  hs2_reco_busy,
      input  hs2_rx_freqlocked_n,
      input  hs2_pll_locked_n,
      output hs2_pll_powerdown,
      output hs2_tx_digitalreset,
      output hs2_rx_digitalreset,
      output hs2_rx_analogreset,
      output hs2_tx_lane_arst_early,
      output hs2_rx_lane_arst_early,

      input  hs3_reco_busy,
      input  hs3_rx_freqlocked_n,
      input  hs3_pll_locked_n,
      output hs3_pll_powerdown,
      output hs3_tx_digitalreset,
      output hs3_rx_digitalreset,
      output hs3_rx_analogreset,
      output hs3_tx_lane_arst_early,
      output hs3_rx_lane_arst_early
      );

localparam CNTR_BITS = SIM_FAST_RESET ? 6 : 20;

wire  pll_powerdown;
wire  tx_digitalreset;
wire  rx_digitalreset;
wire  rx_analogreset;
wire  tx_lane_arst_early;
wire  rx_lane_arst_early;
wire  arst_rxmac_n;

wire  reco_busy = hs3_reco_busy | hs2_reco_busy | hs1_reco_busy | hs0_reco_busy;

wire  hs3_rx_freqlocked = ~ hs3_rx_freqlocked_n;
wire  hs2_rx_freqlocked = ~ hs2_rx_freqlocked_n;
wire  hs1_rx_freqlocked = ~ hs1_rx_freqlocked_n;
wire  hs0_rx_freqlocked = ~ hs0_rx_freqlocked_n;

wire  rx_freqlocked = hs3_rx_freqlocked & hs2_rx_freqlocked & hs1_rx_freqlocked & hs0_rx_freqlocked;

wire  hs3_pll_locked = ~hs3_pll_locked_n;
wire  hs2_pll_locked = ~hs2_pll_locked_n;
wire  hs1_pll_locked = ~hs1_pll_locked_n;
wire  hs0_pll_locked = ~hs0_pll_locked_n;

wire  pll_locked    = hs3_pll_locked & hs2_pll_locked & hs1_pll_locked & hs0_pll_locked;
assign hs3_pll_powerdown = pll_powerdown;  
assign hs2_pll_powerdown = pll_powerdown;  
assign hs1_pll_powerdown = pll_powerdown;  
assign hs0_pll_powerdown = pll_powerdown;  

assign hs3_tx_digitalreset = tx_digitalreset;
assign hs2_tx_digitalreset = tx_digitalreset;
assign hs1_tx_digitalreset = tx_digitalreset;
assign hs0_tx_digitalreset = tx_digitalreset;

assign hs3_rx_digitalreset = rx_digitalreset;
assign hs2_rx_digitalreset = rx_digitalreset;
assign hs1_rx_digitalreset = rx_digitalreset;
assign hs0_rx_digitalreset = rx_digitalreset;

assign hs3_rx_analogreset = rx_analogreset;
assign hs2_rx_analogreset = rx_analogreset;
assign hs1_rx_analogreset = rx_analogreset;
assign hs0_rx_analogreset = rx_analogreset;

assign hs3_tx_lane_arst_early = tx_lane_arst_early;
assign hs2_tx_lane_arst_early = tx_lane_arst_early;
assign hs1_tx_lane_arst_early = tx_lane_arst_early;
assign hs0_tx_lane_arst_early = tx_lane_arst_early;

assign hs3_rx_lane_arst_early = rx_lane_arst_early;
assign hs2_rx_lane_arst_early = rx_lane_arst_early;
assign hs1_rx_lane_arst_early = rx_lane_arst_early;
assign hs0_rx_lane_arst_early = rx_lane_arst_early;

//Power up sequence generator. All the outputs sync with cal_blk_clk.
//The inputs to this block can be async signals. 
alt_ntrlkn_gxb_reset gxb_reset (
       .reset_n         (!reset),
       .cal_blk_clk     (cal_blk_clk),
       .reco_busy       (reco_busy),
       .rx_freqlocked   (rx_freqlocked),
       .pll_locked      (pll_locked),
       .pll_powerdown   (pll_powerdown),
       .tx_digitalreset (tx_digitalreset),
       .rx_analogreset  (rx_analogreset),
       .rx_digitalreset (rx_digitalreset)
       );

defparam gxb_reset.CNTR_BITS = CNTR_BITS;



// TX is ready now - move to common_tx_clk domain
reg [3:0] tx_drst_sync_n = 0 /* synthesis preserve */
/* synthesis ALTERA_ATTRIBUTE = "-name SDC_STATEMENT \"set_false_path -to [get_keepers *tx_drst_sync_n\[0\]]\" " */;

assign tx_lane_arst       = ~tx_drst_sync_n[3];
assign tx_lane_arst_early = ~tx_drst_sync_n[2];
always @(posedge common_tx_clk or posedge tx_digitalreset) begin
        if (tx_digitalreset) tx_drst_sync_n <= 0;
        else tx_drst_sync_n <= {tx_drst_sync_n[2:0], 1'b1};
end

// TX is ready now - move to common_rx_clk domain
reg [3:0] rx_drst_sync_n = 0 /* synthesis preserve */
/* synthesis ALTERA_ATTRIBUTE = "-name SDC_STATEMENT \"set_false_path -to [get_keepers *rx_drst_sync_n\[0\]]\" " */;

//assign rx_lane_arst          = ~rx_drst_sync_n[3];  Currently not used.
assign rx_lane_arst_early    = ~rx_drst_sync_n[2];
always @(posedge common_rx_clk or posedge rx_digitalreset) begin
        if (rx_digitalreset) rx_drst_sync_n <= 0;
        else rx_drst_sync_n <= {rx_drst_sync_n[2:0],1'b1};
end

//Extra cycles used to flush out interlaken mac Fifo's and Pipelines.
//The output sync with common_tx_clk or common_rx_clk
wire arst_txmac_n;
alt_ntrlkn_reset_delay mac_rst_td0 (
        .clk(tx_mac_clk),
        .ready_in(tx_drst_sync_n[1]),
        .ready_out(arst_txmac_n)
);
defparam mac_rst_td0 .CNTR_BITS = CNTR_BITS;

assign tx_mac_arst = ~arst_txmac_n;

alt_ntrlkn_reset_delay mac_rst_rd0 (
        .clk(rx_mac_clk),
        .ready_in(rx_drst_sync_n[1]),
        .ready_out(arst_rxmac_n)
);
defparam mac_rst_rd0 .CNTR_BITS = CNTR_BITS;
assign rx_mac_arst = ~arst_rxmac_n;

endmodule
