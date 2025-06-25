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


// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

module altpcietb_bfm_top_ep  # (
   parameter pll_refclk_freq_hwtcl       = "100 MHz",
   parameter gen123_lane_rate_mode_hwtcl = "gen1",
   parameter lane_mask_hwtcl             = "x4",
   parameter apps_type_hwtcl             = 1,// "1:Link training and configuration", "2:Link training, configuration and chaining DMA","3:Link training, configuration and target"
   parameter serial_sim_hwtcl            = 0
) (
   // Clock
   output                  refclk,
   output                  npor,
      // Reset signals
   output                 simu_mode_pipe,

   output  [31 : 0]       test_in,

   // Input PIPE simulation _ext for simulation only
   input [1:0]            sim_pipe_rate,
   input                  sim_pipe_pclk_in,
   input                  sim_pipe_clk250_out,
   input                  sim_pipe_clk500_out,
   input [4:0]            sim_ltssmstate,
   output                 phystatus0,
   output                 phystatus1,
   output                 phystatus2,
   output                 phystatus3,
   output                 phystatus4,
   output                 phystatus5,
   output                 phystatus6,
   output                 phystatus7,
   output  [7 : 0]        rxdata0,
   output  [7 : 0]        rxdata1,
   output  [7 : 0]        rxdata2,
   output  [7 : 0]        rxdata3,
   output  [7 : 0]        rxdata4,
   output  [7 : 0]        rxdata5,
   output  [7 : 0]        rxdata6,
   output  [7 : 0]        rxdata7,
   output                 rxdatak0,
   output                 rxdatak1,
   output                 rxdatak2,
   output                 rxdatak3,
   output                 rxdatak4,
   output                 rxdatak5,
   output                 rxdatak6,
   output                 rxdatak7,
   output                 rxelecidle0,
   output                 rxelecidle1,
   output                 rxelecidle2,
   output                 rxelecidle3,
   output                 rxelecidle4,
   output                 rxelecidle5,
   output                 rxelecidle6,
   output                 rxelecidle7,
   output                 rxfreqlocked0,
   output                 rxfreqlocked1,
   output                 rxfreqlocked2,
   output                 rxfreqlocked3,
   output                 rxfreqlocked4,
   output                 rxfreqlocked5,
   output                 rxfreqlocked6,
   output                 rxfreqlocked7,
   output  [2 : 0]        rxstatus0,
   output  [2 : 0]        rxstatus1,
   output  [2 : 0]        rxstatus2,
   output  [2 : 0]        rxstatus3,
   output  [2 : 0]        rxstatus4,
   output  [2 : 0]        rxstatus5,
   output  [2 : 0]        rxstatus6,
   output  [2 : 0]        rxstatus7,
   output                 rxdataskip0,
   output                 rxdataskip1,
   output                 rxdataskip2,
   output                 rxdataskip3,
   output                 rxdataskip4,
   output                 rxdataskip5,
   output                 rxdataskip6,
   output                 rxdataskip7,
   output                 rxblkst0,
   output                 rxblkst1,
   output                 rxblkst2,
   output                 rxblkst3,
   output                 rxblkst4,
   output                 rxblkst5,
   output                 rxblkst6,
   output                 rxblkst7,
   output  [1 : 0]        rxsynchd0,
   output  [1 : 0]        rxsynchd1,
   output  [1 : 0]        rxsynchd2,
   output  [1 : 0]        rxsynchd3,
   output  [1 : 0]        rxsynchd4,
   output  [1 : 0]        rxsynchd5,
   output  [1 : 0]        rxsynchd6,
   output  [1 : 0]        rxsynchd7,
   output                 rxvalid0,
   output                 rxvalid1,
   output                 rxvalid2,
   output                 rxvalid3,
   output                 rxvalid4,
   output                 rxvalid5,
   output                 rxvalid6,
   output                 rxvalid7,

   // Output Pipe interface
   input [2 : 0]        eidleinfersel0,
   input [2 : 0]        eidleinfersel1,
   input [2 : 0]        eidleinfersel2,
   input [2 : 0]        eidleinfersel3,
   input [2 : 0]        eidleinfersel4,
   input [2 : 0]        eidleinfersel5,
   input [2 : 0]        eidleinfersel6,
   input [2 : 0]        eidleinfersel7,
   input [1 : 0]        powerdown0,
   input [1 : 0]        powerdown1,
   input [1 : 0]        powerdown2,
   input [1 : 0]        powerdown3,
   input [1 : 0]        powerdown4,
   input [1 : 0]        powerdown5,
   input [1 : 0]        powerdown6,
   input [1 : 0]        powerdown7,
   input                rxpolarity0,
   input                rxpolarity1,
   input                rxpolarity2,
   input                rxpolarity3,
   input                rxpolarity4,
   input                rxpolarity5,
   input                rxpolarity6,
   input                rxpolarity7,
   input                txcompl0,
   input                txcompl1,
   input                txcompl2,
   input                txcompl3,
   input                txcompl4,
   input                txcompl5,
   input                txcompl6,
   input                txcompl7,
   input [7 : 0]        txdata0,
   input [7 : 0]        txdata1,
   input [7 : 0]        txdata2,
   input [7 : 0]        txdata3,
   input [7 : 0]        txdata4,
   input [7 : 0]        txdata5,
   input [7 : 0]        txdata6,
   input [7 : 0]        txdata7,
   input                txdatak0,
   input                txdatak1,
   input                txdatak2,
   input                txdatak3,
   input                txdatak4,
   input                txdatak5,
   input                txdatak6,
   input                txdatak7,
   input                txdetectrx0,
   input                txdetectrx1,
   input                txdetectrx2,
   input                txdetectrx3,
   input                txdetectrx4,
   input                txdetectrx5,
   input                txdetectrx6,
   input                txdetectrx7,
   input                txelecidle0,
   input                txelecidle1,
   input                txelecidle2,
   input                txelecidle3,
   input                txelecidle4,
   input                txelecidle5,
   input                txelecidle6,
   input                txelecidle7,
   input [2 : 0]        txmargin0,
   input [2 : 0]        txmargin1,
   input [2 : 0]        txmargin2,
   input [2 : 0]        txmargin3,
   input [2 : 0]        txmargin4,
   input [2 : 0]        txmargin5,
   input [2 : 0]        txmargin6,
   input [2 : 0]        txmargin7,
   input                txswing0,
   input                txswing1,
   input                txswing2,
   input                txswing3,
   input                txswing4,
   input                txswing5,
   input                txswing6,
   input                txswing7,
   input                txdeemph0,
   input                txdeemph1,
   input                txdeemph2,
   input                txdeemph3,
   input                txdeemph4,
   input                txdeemph5,
   input                txdeemph6,
   input                txdeemph7,
   input                txblkst0,
   input                txblkst1,
   input                txblkst2,
   input                txblkst3,
   input                txblkst4,
   input                txblkst5,
   input                txblkst6,
   input                txblkst7,
   input [1 : 0]        txsynchd0,
   input [1 : 0]        txsynchd1,
   input [1 : 0]        txsynchd2,
   input [1 : 0]        txsynchd3,
   input [1 : 0]        txsynchd4,
   input [1 : 0]        txsynchd5,
   input [1 : 0]        txsynchd6,
   input [1 : 0]        txsynchd7,
   input [17 : 0]       currentcoeff0,
   input [17 : 0]       currentcoeff1,
   input [17 : 0]       currentcoeff2,
   input [17 : 0]       currentcoeff3,
   input [17 : 0]       currentcoeff4,
   input [17 : 0]       currentcoeff5,
   input [17 : 0]       currentcoeff6,
   input [17 : 0]       currentcoeff7,
   input [2 : 0]        currentrxpreset0,
   input [2 : 0]        currentrxpreset1,
   input [2 : 0]        currentrxpreset2,
   input [2 : 0]        currentrxpreset3,
   input [2 : 0]        currentrxpreset4,
   input [2 : 0]        currentrxpreset5,
   input [2 : 0]        currentrxpreset6,
   input [2 : 0]        currentrxpreset7,


   // serial interface
   output    rx_in0,
   output    rx_in1,
   output    rx_in2,
   output    rx_in3,
   output    rx_in4,
   output    rx_in5,
   output    rx_in6,
   output    rx_in7,

   input     tx_out0,
   input     tx_out1,
   input     tx_out2,
   input     tx_out3,
   input     tx_out4,
   input     tx_out5,
   input     tx_out6,
   input     tx_out7

   );

genvar i;
localparam NLANES = (lane_mask_hwtcl == "x1")?1:(lane_mask_hwtcl == "x2")?2:(lane_mask_hwtcl == "x4")?4:8;
localparam CONNECTED_LANES = 8;

wire    [  4: 0] ep_ltssm;
wire    [  4: 0] rp_ltssm;
wire             ep_pclk_pipe;
wire             ep_phystatus0;
wire             ep_phystatus1;
wire             ep_phystatus2;
wire             ep_phystatus3;
wire             ep_phystatus4;
wire             ep_phystatus5;
wire             ep_phystatus6;
wire             ep_phystatus7;
wire    [  1: 0] ep_powerdown0;
wire    [  1: 0] ep_powerdown1;
wire    [  1: 0] ep_powerdown2;
wire    [  1: 0] ep_powerdown3;
wire    [  1: 0] ep_powerdown4;
wire    [  1: 0] ep_powerdown5;
wire    [  1: 0] ep_powerdown6;
wire    [  1: 0] ep_powerdown7;
wire             ep_rate;
wire             rp_rstn;
wire             rp_rx_in0;
wire             rp_rx_in1;
wire             rp_rx_in2;
wire             rp_rx_in3;
wire    [  7: 0] ep_rxdata0;
wire    [  7: 0] ep_rxdata1;
wire    [  7: 0] ep_rxdata2;
wire    [  7: 0] ep_rxdata3;
wire    [  7: 0] ep_rxdata4;
wire    [  7: 0] ep_rxdata5;
wire    [  7: 0] ep_rxdata6;
wire    [  7: 0] ep_rxdata7;
wire             ep_rxdatak0;
wire             ep_rxdatak1;
wire             ep_rxdatak2;
wire             ep_rxdatak3;
wire             ep_rxdatak4;
wire             ep_rxdatak5;
wire             ep_rxdatak6;
wire             ep_rxdatak7;
wire             ep_rxelecidle0;
wire             ep_rxelecidle1;
wire             ep_rxelecidle2;
wire             ep_rxelecidle3;
wire             ep_rxelecidle4;
wire             ep_rxelecidle5;
wire             ep_rxelecidle6;
wire             ep_rxelecidle7;
wire             ep_rxpolarity0;
wire             ep_rxpolarity1;
wire             ep_rxpolarity2;
wire             ep_rxpolarity3;
wire             ep_rxpolarity4;
wire             ep_rxpolarity5;
wire             ep_rxpolarity6;
wire             ep_rxpolarity7;
wire    [  2: 0] ep_rxstatus0;
wire    [  2: 0] ep_rxstatus1;
wire    [  2: 0] ep_rxstatus2;
wire    [  2: 0] ep_rxstatus3;
wire    [  2: 0] ep_rxstatus4;
wire    [  2: 0] ep_rxstatus5;
wire    [  2: 0] ep_rxstatus6;
wire    [  2: 0] ep_rxstatus7;
wire             ep_rxvalid0;
wire             ep_rxvalid1;
wire             ep_rxvalid2;
wire             ep_rxvalid3;
wire             ep_rxvalid4;
wire             ep_rxvalid5;
wire             ep_rxvalid6;
wire             ep_rxvalid7;
wire    [ 31: 0] ep_test_in;
wire    [8: 0]   ep_test_out;
wire             ep_core_clk_out;
wire             ep_tx_out0;
wire             ep_tx_out1;
wire             ep_tx_out2;
wire             ep_tx_out3;
wire             ep_tx_out4;
wire             ep_tx_out5;
wire             ep_tx_out6;
wire             ep_tx_out7;


wire             ep_txcompl0;
wire             ep_txcompl1;
wire             ep_txcompl2;
wire             ep_txcompl3;
wire             ep_txcompl4;
wire             ep_txcompl5;
wire             ep_txcompl6;
wire             ep_txcompl7;
wire    [  7: 0] ep_txdata0;
wire    [  7: 0] ep_txdata1;
wire    [  7: 0] ep_txdata2;
wire    [  7: 0] ep_txdata3;
wire    [  7: 0] ep_txdata4;
wire    [  7: 0] ep_txdata5;
wire    [  7: 0] ep_txdata6;
wire    [  7: 0] ep_txdata7;
wire             ep_txdatak0;
wire             ep_txdatak1;
wire             ep_txdatak2;
wire             ep_txdatak3;
wire             ep_txdatak4;
wire             ep_txdatak5;
wire             ep_txdatak6;
wire             ep_txdatak7;
wire             ep_txdetectrx;
wire             ep_txdetectrx0;
wire             ep_txdetectrx1;
wire             ep_txdetectrx2;
wire             ep_txdetectrx3;
wire             ep_txdetectrx4;
wire             ep_txdetectrx5;
wire             ep_txdetectrx6;
wire             ep_txdetectrx7;
wire             ep_txelecidle0;
wire             ep_txelecidle1;
wire             ep_txelecidle2;
wire             ep_txelecidle3;
wire             ep_txelecidle4;
wire             ep_txelecidle5;
wire             ep_txelecidle6;
wire             ep_txelecidle7;
wire    [  5: 0] swdn_out;
wire [1:0] ep_rate_g3_ext;
wire [3:0] open_lane_width_code;
wire [1:0] ep_powerdown;

wire [7:0]     connected_bits;

wire [31:0] open_wire;
wire ep_sim_pipe_clk250_out;
wire ep_sim_pipe_clk500_out;
wire ltssm_dummy_out;
wire simu_mode;

assign ep_sim_pipe_clk250_out=sim_pipe_clk250_out;
assign ep_sim_pipe_clk500_out=sim_pipe_clk500_out;

   assign simu_mode        = 1'b1;
   assign simu_mode_pipe   =  (serial_sim_hwtcl==1)?1'b0:1'b1;

   assign local_rstn       = 1'b1;

   assign test_in[31 : 8] = 0;
   assign test_in[6] = 0;
   assign test_in[4] = 0;
   assign test_in[2 : 1] = 0;
   //Bit 0: Speed up the simulation but making counters faster than normal
   assign test_in[0] = 1'b1;
   //Bit 3: Forces all lanes to detect the receiver
   //For Stratix GX we must force but can use Rx Detect for
   //the generic PIPE interface
   assign test_in[3] = ~simu_mode_pipe;
   //Bit 5: Disable polling.compliance
   assign test_in[5] = 1;
   //Bit 7: Disable any entrance to low power link states (for Stratix GX)
   //For Stratix GX we must disable but can use Low Power for
   //the generic PIPE interface
   assign test_in[7] = ~simu_mode_pipe;
   assign rp_ltssm   = sim_ltssmstate;

   assign connected_bits = (CONNECTED_LANES==8)?8'hFF:(CONNECTED_LANES==4)?8'h0F:(CONNECTED_LANES==2)?8'h03:8'h1;
   ///////////////////////////////////////////////////////////////////////////////////
   //
   // Reset and monitors
   //
   wire pcie_rstn;
   altpcietb_rst_clk # (
         .REFCLK_HALF_PERIOD((pll_refclk_freq_hwtcl== "125 MHz")?4000:5000)
        ) rst_clk_gen (
       .pcie_rstn          (npor),
       .ref_clk_out        (refclk),
       .rp_rstn            (pcie_rstn));
   ///////////////////////////////////////////////////////////////////////////////////
   //
   // End point BFM
   //

   assign ep_test_in[2 : 1]   = 2'h0;
   assign ep_test_in[8 : 4]   = 5'h0;
   assign ep_test_in[9]       = 1'b11;
   assign ep_test_in[31 : 10] = 0;
   assign ep_test_in[3]       = 0;
   assign ep_test_in[0]       = simu_mode;
   assign ep_ltssm            = ep_test_out[4 : 0];

   altpcietb_bfm_ep_example_chaining_pipen1b ep (
      .clk250_out          (ep_sim_pipe_clk250_out),
      .clk500_out          (ep_sim_pipe_clk500_out),
      .core_clk_out        (ep_core_clk_out),
      .lane_width_code     (open_lane_width_code),
      .local_rstn          (local_rstn),
      .pcie_rstn           (pcie_rstn),
      .pclk_in             (ep_pclk_pipe),
      .phystatus_ext       (ep_phystatus0),
      .pipe_mode           (simu_mode_pipe),
      .pld_clk             (ep_core_clk_out),
      .test_in             (ep_test_in),
      .test_out_icm        (ep_test_out),

      .powerdown_ext    (ep_powerdown),
      .rate_ext         (ep_rate_g3_ext),
      .ref_clk_sel_code (ref_clk_sel_code),
      .refclk          (refclk),
      .rx_in0          (ep_rx_in0),
      .rx_in1          (ep_rx_in1),
      .rx_in2          (ep_rx_in2),
      .rx_in3          (ep_rx_in3),
      .rx_in4          (ep_rx_in4),
      .rx_in5          (ep_rx_in5),
      .rx_in6          (ep_rx_in6),
      .rx_in7          (ep_rx_in7),
      .rxdata0_ext     (ep_rxdata0),
      .rxdata1_ext     (ep_rxdata1),
      .rxdata2_ext     (ep_rxdata2),
      .rxdata3_ext     (ep_rxdata3),
      .rxdata4_ext     (ep_rxdata4),
      .rxdata5_ext     (ep_rxdata5),
      .rxdata6_ext     (ep_rxdata6),
      .rxdata7_ext     (ep_rxdata7),
      .rxdatak0_ext    (ep_rxdatak0),
      .rxdatak1_ext    (ep_rxdatak1),
      .rxdatak2_ext    (ep_rxdatak2),
      .rxdatak3_ext    (ep_rxdatak3),
      .rxdatak4_ext    (ep_rxdatak4),
      .rxdatak5_ext    (ep_rxdatak5),
      .rxdatak6_ext    (ep_rxdatak6),
      .rxdatak7_ext    (ep_rxdatak7),
      .rxelecidle0_ext (ep_rxelecidle0),
      .rxelecidle1_ext (ep_rxelecidle1),
      .rxelecidle2_ext (ep_rxelecidle2),
      .rxelecidle3_ext (ep_rxelecidle3),
      .rxelecidle4_ext (ep_rxelecidle4),
      .rxelecidle5_ext (ep_rxelecidle5),
      .rxelecidle6_ext (ep_rxelecidle6),
      .rxelecidle7_ext (ep_rxelecidle7),
      .rxpolarity0_ext (ep_rxpolarity0),
      .rxpolarity1_ext (ep_rxpolarity1),
      .rxpolarity2_ext (ep_rxpolarity2),
      .rxpolarity3_ext (ep_rxpolarity3),
      .rxpolarity4_ext (ep_rxpolarity4),
      .rxpolarity5_ext (ep_rxpolarity5),
      .rxpolarity6_ext (ep_rxpolarity6),
      .rxpolarity7_ext (ep_rxpolarity7),
      .rxstatus0_ext   (ep_rxstatus0),
      .rxstatus1_ext   (ep_rxstatus1),
      .rxstatus2_ext   (ep_rxstatus2),
      .rxstatus3_ext   (ep_rxstatus3),
      .rxstatus4_ext   (ep_rxstatus4),
      .rxstatus5_ext   (ep_rxstatus5),
      .rxstatus6_ext   (ep_rxstatus6),
      .rxstatus7_ext   (ep_rxstatus7),
      .rxvalid0_ext    (ep_rxvalid0),
      .rxvalid1_ext    (ep_rxvalid1),
      .rxvalid2_ext    (ep_rxvalid2),
      .rxvalid3_ext    (ep_rxvalid3),
      .rxvalid4_ext    (ep_rxvalid4),
      .rxvalid5_ext    (ep_rxvalid5),
      .rxvalid6_ext    (ep_rxvalid6),
      .rxvalid7_ext    (ep_rxvalid7),
      .tx_out0         (ep_tx_out0),
      .tx_out1         (ep_tx_out1),
      .tx_out2         (ep_tx_out2),
      .tx_out3         (ep_tx_out3),
      .tx_out4         (ep_tx_out4),
      .tx_out5         (ep_tx_out5),
      .tx_out6         (ep_tx_out6),
      .tx_out7         (ep_tx_out7),
      .txcompl0_ext    (ep_txcompl0),
      .txcompl1_ext    (ep_txcompl1),
      .txcompl2_ext    (ep_txcompl2),
      .txcompl3_ext    (ep_txcompl3),
      .txcompl4_ext    (ep_txcompl4),
      .txcompl5_ext    (ep_txcompl5),
      .txcompl6_ext    (ep_txcompl6),
      .txcompl7_ext    (ep_txcompl7),
      .txdata0_ext     (ep_txdata0),
      .txdata1_ext     (ep_txdata1),
      .txdata2_ext     (ep_txdata2),
      .txdata3_ext     (ep_txdata3),
      .txdata4_ext     (ep_txdata4),
      .txdata5_ext     (ep_txdata5),
      .txdata6_ext     (ep_txdata6),
      .txdata7_ext     (ep_txdata7),
      .txdatak0_ext    (ep_txdatak0),
      .txdatak1_ext    (ep_txdatak1),
      .txdatak2_ext    (ep_txdatak2),
      .txdatak3_ext    (ep_txdatak3),
      .txdatak4_ext    (ep_txdatak4),
      .txdatak5_ext    (ep_txdatak5),
      .txdatak6_ext    (ep_txdatak6),
      .txdatak7_ext    (ep_txdatak7),
      .txdetectrx_ext  (ep_txdetectrx),
      .txelecidle0_ext (ep_txelecidle0),
      .txelecidle1_ext (ep_txelecidle1),
      .txelecidle2_ext (ep_txelecidle2),
      .txelecidle3_ext (ep_txelecidle3),
      .txelecidle4_ext (ep_txelecidle4),
      .txelecidle5_ext (ep_txelecidle5),
      .txelecidle6_ext (ep_txelecidle6),
      .txelecidle7_ext (ep_txelecidle7)
    );

   assign ep_powerdown0 = ep_powerdown;
   assign ep_powerdown1 = ep_powerdown;
   assign ep_powerdown2 = ep_powerdown;
   assign ep_powerdown3 = ep_powerdown;
   assign ep_powerdown4 = ep_powerdown;
   assign ep_powerdown5 = ep_powerdown;
   assign ep_powerdown6 = ep_powerdown;
   assign ep_powerdown7 = ep_powerdown;

   assign ep_txdetectrx0 = ep_txdetectrx;
   assign ep_txdetectrx1 = ep_txdetectrx;
   assign ep_txdetectrx2 = ep_txdetectrx;
   assign ep_txdetectrx3 = ep_txdetectrx;
   assign ep_txdetectrx4 = ep_txdetectrx;
   assign ep_txdetectrx5 = ep_txdetectrx;
   assign ep_txdetectrx6 = ep_txdetectrx;
   assign ep_txdetectrx7 = ep_txdetectrx;
   ///////////////////////////////////////////////////////////////////////////////////
   //
   // Serial Interface
   //

   assign rx_in7    = (NLANES<2)?1'b1: (NLANES<4)?1'b1:(NLANES<8)?1'b1:(connected_bits[7] == 1'b1) ?  ep_tx_out7 : 1'b1;
   assign rx_in6    = (NLANES<2)?1'b1: (NLANES<4)?1'b1:(NLANES<8)?1'b1:(connected_bits[6] == 1'b1) ?  ep_tx_out6 : 1'b1;
   assign rx_in5    = (NLANES<2)?1'b1: (NLANES<4)?1'b1:(NLANES<8)?1'b1:(connected_bits[5] == 1'b1) ?  ep_tx_out5 : 1'b1;
   assign rx_in4    = (NLANES<2)?1'b1: (NLANES<4)?1'b1:(NLANES<8)?1'b1:(connected_bits[4] == 1'b1) ?  ep_tx_out4 : 1'b1;
   assign rx_in3    = (NLANES<2)?1'b1: (NLANES<4)?1'b1:                (connected_bits[3] == 1'b1) ?  ep_tx_out3 : 1'b1;
   assign rx_in2    = (NLANES<2)?1'b1: (NLANES<4)?1'b1:                (connected_bits[2] == 1'b1) ?  ep_tx_out2 : 1'b1;
   assign rx_in1    = (NLANES<2)?1'b1:                                 (connected_bits[1] == 1'b1) ?  ep_tx_out1 : 1'b1;
   assign rx_in0    =                                                  (connected_bits[0] == 1'b1) ?  ep_tx_out0 : 1'b1;

   assign ep_rx_in7 = (NLANES<2)?1'b1: (NLANES<4)?1'b1:(NLANES<8)?1'b1:tx_out7;
   assign ep_rx_in6 = (NLANES<2)?1'b1: (NLANES<4)?1'b1:(NLANES<8)?1'b1:tx_out6;
   assign ep_rx_in5 = (NLANES<2)?1'b1: (NLANES<4)?1'b1:(NLANES<8)?1'b1:tx_out5;
   assign ep_rx_in4 = (NLANES<2)?1'b1: (NLANES<4)?1'b1:(NLANES<8)?1'b1:tx_out4;
   assign ep_rx_in3 = (NLANES<2)?1'b1: (NLANES<4)?1'b1:                tx_out3;
   assign ep_rx_in2 = (NLANES<2)?1'b1: (NLANES<4)?1'b1:                tx_out2;
   assign ep_rx_in1 = (NLANES<2)?1'b1:                                 tx_out1;
   assign ep_rx_in0 =                                                  tx_out0;

   ///////////////////////////////////////////////////////////////////////////////////
   //
   // PIPE Simulation Interface
   //
   //generate

      altpcietb_pipe_phy # (
            .APIPE_WIDTH            ( 8),
            .BPIPE_WIDTH            ( 8),
            .LANE_NUM               ( 0)
                  ) lane0 (
            .A_lane_conn            (connected_bits[0] ),
            .A_rate                 (sim_pipe_rate[0]  ),
            .pclk_a                 (sim_pipe_pclk_in),
            .A_phystatus            (phystatus0        ),
            .A_rxdata               (rxdata0           ),
            .A_rxdatak              (rxdatak0          ),
            .A_rxelecidle           (rxelecidle0       ),
            .A_rxpolarity           (rxpolarity0       ),
            .A_rxstatus             (rxstatus0         ),
            .A_rxvalid              (rxvalid0          ),
            .A_powerdown            (powerdown0        ),
            .A_txcompl              (txcompl0          ),
            .A_txdata               (txdata0           ),
            .A_txdatak              (txdatak0          ),
            .A_txdetectrx           (txdetectrx0       ),
            .A_txelecidle           (txelecidle0       ),

            .B_phystatus            (ep_phystatus0 ),
            .B_rxdata               (ep_rxdata0    ),
            .B_rxdatak              (ep_rxdatak0   ),
            .B_rxelecidle           (ep_rxelecidle0),
            .B_rxpolarity           (ep_rxpolarity0),
            .B_rxstatus             (ep_rxstatus0  ),
            .B_rxvalid              (ep_rxvalid0   ),
            .B_powerdown            (ep_powerdown0 ),
            .B_txcompl              (ep_txcompl0   ),
            .B_txdata               (ep_txdata0    ),
            .B_txdatak              (ep_txdatak0   ),
            .B_txdetectrx           (ep_txdetectrx0),
            .B_txelecidle           (ep_txelecidle0),
            .B_lane_conn            (1'b1),
            .B_rate                 (ep_rate            ),
            .pclk_b                 (ep_pclk_pipe),
            .pipe_mode              (simu_mode_pipe),
            .resetn                 (npor)
             );

      wire       iphystatus1 ;
      wire [7:0] irxdata1    ;
      wire       irxdatak1   ;
      wire       irxelecidle1;
      wire [2:0] irxstatus1  ;
      wire       irxvalid1   ;

      assign phystatus1 = (NLANES>1)?iphystatus1 :open_wire[0];
      assign rxdata1    = (NLANES>1)?irxdata1    :open_wire[7:0];
      assign rxdatak1   = (NLANES>1)?irxdatak1   :open_wire[0];
      assign rxelecidle1= (NLANES>1)?irxelecidle1:open_wire[0];
      assign rxstatus1  = (NLANES>1)?irxstatus1  :open_wire[2:0];
      assign rxvalid1   = (NLANES>1)?irxvalid1   :open_wire[0];

      altpcietb_pipe_phy # (
            .APIPE_WIDTH            ( 8),
            .BPIPE_WIDTH            ( 8),
            .LANE_NUM               ( 1)
                  ) lane1 (
            .A_rate                 (sim_pipe_rate[0]  ),
            .pclk_a                 (sim_pipe_pclk_in),
            .A_lane_conn            ((NLANES>1)?connected_bits[1] : 1'b0),

            .A_phystatus            (iphystatus1 ),
            .A_rxdata               (irxdata1    ),
            .A_rxdatak              (irxdatak1   ),
            .A_rxelecidle           (irxelecidle1),
            .A_rxstatus             (irxstatus1  ),
            .A_rxvalid              (irxvalid1   ),
            .A_rxpolarity           ((NLANES>1)?rxpolarity1:1'b0),
            .A_powerdown            ((NLANES>1)?powerdown1 :2'h0),
            .A_txcompl              ((NLANES>1)?txcompl1   :1'b0),
            .A_txdata               ((NLANES>1)?txdata1    :8'h0),
            .A_txdatak              ((NLANES>1)?txdatak1   :1'b0),
            .A_txdetectrx           ((NLANES>1)?txdetectrx1:1'b0),
            .A_txelecidle           ((NLANES>1)?txelecidle1:1'b0),

            .B_phystatus            (ep_phystatus1 ),
            .B_rxdata               (ep_rxdata1    ),
            .B_rxdatak              (ep_rxdatak1   ),
            .B_rxelecidle           (ep_rxelecidle1),
            .B_rxpolarity           (ep_rxpolarity1),
            .B_rxstatus             (ep_rxstatus1  ),
            .B_rxvalid              (ep_rxvalid1   ),
            .B_powerdown            (ep_powerdown1 ),
            .B_txcompl              (ep_txcompl1   ),
            .B_txdata               (ep_txdata1    ),
            .B_txdatak              (ep_txdatak1   ),
            .B_txdetectrx           (ep_txdetectrx1),
            .B_txelecidle           (ep_txelecidle1),
            .B_lane_conn            (1'b1),
            .B_rate                 (ep_rate            ),
            .pclk_b                 (ep_pclk_pipe),
            .pipe_mode              (simu_mode_pipe),
            .resetn                 (npor)
             );

      wire       iphystatus2 ;
      wire [7:0] irxdata2    ;
      wire       irxdatak2   ;
      wire       irxelecidle2;
      wire [2:0] irxstatus2  ;
      wire       irxvalid2   ;

      assign phystatus2 = (NLANES>3)?iphystatus2 :open_wire[0];
      assign rxdata2    = (NLANES>3)?irxdata2    :open_wire[7:0];
      assign rxdatak2   = (NLANES>3)?irxdatak2   :open_wire[0];
      assign rxelecidle2= (NLANES>3)?irxelecidle2:open_wire[0];
      assign rxstatus2  = (NLANES>3)?irxstatus2  :open_wire[2:0];
      assign rxvalid2   = (NLANES>3)?irxvalid2   :open_wire[0];

      altpcietb_pipe_phy # (
            .APIPE_WIDTH            ( 8),
            .BPIPE_WIDTH            ( 8),
            .LANE_NUM               ( 2)
                  ) lane2 (
            .A_rate                 (sim_pipe_rate[0]  ),
            .pclk_a                 (sim_pipe_pclk_in),
            .A_lane_conn            ((NLANES>3)?connected_bits[2] :1'b0),
            .A_phystatus            (iphystatus2 ),
            .A_rxdata               (irxdata2    ),
            .A_rxdatak              (irxdatak2   ),
            .A_rxelecidle           (irxelecidle2),
            .A_rxstatus             (irxstatus2  ),
            .A_rxvalid              (irxvalid2   ),
            .A_rxpolarity           ((NLANES>3)?rxpolarity2:1'b0),
            .A_powerdown            ((NLANES>3)?powerdown2 :2'h0),
            .A_txcompl              ((NLANES>3)?txcompl2   :1'b0),
            .A_txdata               ((NLANES>3)?txdata2    :8'h0),
            .A_txdatak              ((NLANES>3)?txdatak2   :1'b0),
            .A_txdetectrx           ((NLANES>3)?txdetectrx2:1'b0),
            .A_txelecidle           ((NLANES>3)?txelecidle2:1'b0),

            .B_phystatus            (ep_phystatus2 ),
            .B_rxdata               (ep_rxdata2    ),
            .B_rxdatak              (ep_rxdatak2   ),
            .B_rxelecidle           (ep_rxelecidle2),
            .B_rxpolarity           (ep_rxpolarity2),
            .B_rxstatus             (ep_rxstatus2  ),
            .B_rxvalid              (ep_rxvalid2   ),
            .B_powerdown            (ep_powerdown2 ),
            .B_txcompl              (ep_txcompl2   ),
            .B_txdata               (ep_txdata2    ),
            .B_txdatak              (ep_txdatak2   ),
            .B_txdetectrx           (ep_txdetectrx2),
            .B_txelecidle           (ep_txelecidle2),
            .B_lane_conn            (1'b1),
            .B_rate                 (ep_rate            ),
            .pclk_b                 (ep_pclk_pipe),
            .pipe_mode              (simu_mode_pipe),
            .resetn                 (npor)
             );


      wire       iphystatus3 ;
      wire [7:0] irxdata3    ;
      wire       irxdatak3   ;
      wire       irxelecidle3;
      wire [2:0] irxstatus3  ;
      wire       irxvalid3   ;

      assign phystatus3 = (NLANES>3)?iphystatus3 :open_wire[0];
      assign rxdata3    = (NLANES>3)?irxdata3    :open_wire[7:0];
      assign rxdatak3   = (NLANES>3)?irxdatak3   :open_wire[0];
      assign rxelecidle3= (NLANES>3)?irxelecidle3:open_wire[0];
      assign rxstatus3  = (NLANES>3)?irxstatus3  :open_wire[2:0];
      assign rxvalid3   = (NLANES>3)?irxvalid3   :open_wire[0];

      altpcietb_pipe_phy # (
            .APIPE_WIDTH            ( 8),
            .BPIPE_WIDTH            ( 8),
            .LANE_NUM               ( 3)
                  ) lane3 (
            .A_rate                 (sim_pipe_rate[0]  ),
            .pclk_a                 (sim_pipe_pclk_in),
            .A_lane_conn            ((NLANES>3)?connected_bits[3] :1'b0),
            .A_phystatus            (iphystatus3 ),
            .A_rxdata               (irxdata3    ),
            .A_rxdatak              (irxdatak3   ),
            .A_rxelecidle           (irxelecidle3),
            .A_rxstatus             (irxstatus3  ),
            .A_rxvalid              (irxvalid3   ),
            .A_rxpolarity           ((NLANES>3)?rxpolarity3:1'b0),
            .A_powerdown            ((NLANES>3)?powerdown3 :2'h0),
            .A_txcompl              ((NLANES>3)?txcompl3   :1'b0),
            .A_txdata               ((NLANES>3)?txdata3    :8'h0),
            .A_txdatak              ((NLANES>3)?txdatak3   :1'b0),
            .A_txdetectrx           ((NLANES>3)?txdetectrx3:1'b0),
            .A_txelecidle           ((NLANES>3)?txelecidle3:1'b0),

            .B_phystatus            (ep_phystatus3 ),
            .B_rxdata               (ep_rxdata3    ),
            .B_rxdatak              (ep_rxdatak3   ),
            .B_rxelecidle           (ep_rxelecidle3),
            .B_rxpolarity           (ep_rxpolarity3),
            .B_rxstatus             (ep_rxstatus3  ),
            .B_rxvalid              (ep_rxvalid3   ),
            .B_powerdown            (ep_powerdown3 ),
            .B_txcompl              (ep_txcompl3   ),
            .B_txdata               (ep_txdata3    ),
            .B_txdatak              (ep_txdatak3   ),
            .B_txdetectrx           (ep_txdetectrx3),
            .B_txelecidle           (ep_txelecidle3),
            .B_lane_conn            (1'b1),
            .B_rate                 (ep_rate            ),
            .pclk_b                 (ep_pclk_pipe),
            .pipe_mode              (simu_mode_pipe),
            .resetn                 (npor)
             );

      wire       iphystatus4 ;
      wire [7:0] irxdata4    ;
      wire       irxdatak4   ;
      wire       irxelecidle4;
      wire [2:0] irxstatus4  ;
      wire       irxvalid4   ;

      assign phystatus4 = (NLANES>7)?iphystatus4 :open_wire[0];
      assign rxdata4    = (NLANES>7)?irxdata4    :open_wire[7:0];
      assign rxdatak4   = (NLANES>7)?irxdatak4   :open_wire[0];
      assign rxelecidle4= (NLANES>7)?irxelecidle4:open_wire[0];
      assign rxstatus4  = (NLANES>7)?irxstatus4  :open_wire[2:0];
      assign rxvalid4   = (NLANES>7)?irxvalid4   :open_wire[0];

      altpcietb_pipe_phy # (
            .APIPE_WIDTH            ( 8),
            .BPIPE_WIDTH            ( 8),
            .LANE_NUM               ( 4)
                  ) lane4 (
            .A_rate                 (sim_pipe_rate[0]  ),
            .pclk_a                 (sim_pipe_pclk_in),
            .A_lane_conn            ((NLANES>7)?connected_bits[4]:1'b0),
            .A_phystatus            (iphystatus4 ),
            .A_rxdata               (irxdata4    ),
            .A_rxdatak              (irxdatak4   ),
            .A_rxelecidle           (irxelecidle4),
            .A_rxstatus             (irxstatus4  ),
            .A_rxvalid              (irxvalid4   ),
            .A_rxpolarity           ((NLANES>7)?rxpolarity4:1'b0),
            .A_powerdown            ((NLANES>7)?powerdown4 :2'h0),
            .A_txcompl              ((NLANES>7)?txcompl4   :1'b0),
            .A_txdata               ((NLANES>7)?txdata4    :8'h0),
            .A_txdatak              ((NLANES>7)?txdatak4   :1'b0),
            .A_txdetectrx           ((NLANES>7)?txdetectrx4:1'b0),
            .A_txelecidle           ((NLANES>7)?txelecidle4:1'b0),

            .B_phystatus            (ep_phystatus4 ),
            .B_rxdata               (ep_rxdata4    ),
            .B_rxdatak              (ep_rxdatak4   ),
            .B_rxelecidle           (ep_rxelecidle4),
            .B_rxpolarity           (ep_rxpolarity4),
            .B_rxstatus             (ep_rxstatus4  ),
            .B_rxvalid              (ep_rxvalid4   ),
            .B_powerdown            (ep_powerdown4 ),
            .B_txcompl              (ep_txcompl4   ),
            .B_txdata               (ep_txdata4    ),
            .B_txdatak              (ep_txdatak4   ),
            .B_txdetectrx           (ep_txdetectrx4),
            .B_txelecidle           (ep_txelecidle4),
            .B_lane_conn            (1'b1),
            .B_rate                 (ep_rate            ),
            .pclk_b                 (ep_pclk_pipe),
            .pipe_mode              (simu_mode_pipe),
            .resetn                 (npor)
             );



      wire       iphystatus5 ;
      wire [7:0] irxdata5    ;
      wire       irxdatak5   ;
      wire       irxelecidle5;
      wire [2:0] irxstatus5  ;
      wire       irxvalid5   ;

      assign phystatus5 = (NLANES>7)?iphystatus5 :open_wire[0];
      assign rxdata5    = (NLANES>7)?irxdata5    :open_wire[7:0];
      assign rxdatak5   = (NLANES>7)?irxdatak5   :open_wire[0];
      assign rxelecidle5= (NLANES>7)?irxelecidle5:open_wire[0];
      assign rxstatus5  = (NLANES>7)?irxstatus5  :open_wire[2:0];
      assign rxvalid5   = (NLANES>7)?irxvalid5   :open_wire[0];


      altpcietb_pipe_phy # (
            .APIPE_WIDTH            ( 8),
            .BPIPE_WIDTH            ( 8),
            .LANE_NUM               ( 5)
                  ) lane5 (
            .A_rate                 (sim_pipe_rate[0]  ),
            .pclk_a                 (sim_pipe_pclk_in),
            .A_lane_conn            ((NLANES>7)?connected_bits[5]:1'b0),
            .A_phystatus            (iphystatus5 ),
            .A_rxdata               (irxdata5    ),
            .A_rxdatak              (irxdatak5   ),
            .A_rxelecidle           (irxelecidle5),
            .A_rxstatus             (irxstatus5  ),
            .A_rxvalid              (irxvalid5   ),
            .A_rxpolarity           ((NLANES>7)?rxpolarity5:1'b0),
            .A_powerdown            ((NLANES>7)?powerdown5 :2'h0),
            .A_txcompl              ((NLANES>7)?txcompl5   :1'b0),
            .A_txdata               ((NLANES>7)?txdata5    :8'h0),
            .A_txdatak              ((NLANES>7)?txdatak5   :1'b0),
            .A_txdetectrx           ((NLANES>7)?txdetectrx5:1'b0),
            .A_txelecidle           ((NLANES>7)?txelecidle5:1'b0),

            .B_phystatus            (ep_phystatus5 ),
            .B_rxdata               (ep_rxdata5    ),
            .B_rxdatak              (ep_rxdatak5   ),
            .B_rxelecidle           (ep_rxelecidle5),
            .B_rxpolarity           (ep_rxpolarity5),
            .B_rxstatus             (ep_rxstatus5  ),
            .B_rxvalid              (ep_rxvalid5   ),
            .B_powerdown            (ep_powerdown5 ),
            .B_txcompl              (ep_txcompl5   ),
            .B_txdata               (ep_txdata5    ),
            .B_txdatak              (ep_txdatak5   ),
            .B_txdetectrx           (ep_txdetectrx5),
            .B_txelecidle           (ep_txelecidle5),
            .B_lane_conn            (1'b1),
            .B_rate                 (ep_rate            ),
            .pclk_b                 (ep_pclk_pipe),
            .pipe_mode              (simu_mode_pipe),
            .resetn                 (npor)
             );


      wire       iphystatus6 ;
      wire [7:0] irxdata6    ;
      wire       irxdatak6   ;
      wire       irxelecidle6;
      wire [2:0] irxstatus6  ;
      wire       irxvalid6   ;

      assign phystatus6 = (NLANES>7)?iphystatus6 :open_wire[0];
      assign rxdata6    = (NLANES>7)?irxdata6    :open_wire[7:0];
      assign rxdatak6   = (NLANES>7)?irxdatak6   :open_wire[0];
      assign rxelecidle6= (NLANES>7)?irxelecidle6:open_wire[0];
      assign rxstatus6  = (NLANES>7)?irxstatus6  :open_wire[2:0];
      assign rxvalid6   = (NLANES>7)?irxvalid6   :open_wire[0];

      altpcietb_pipe_phy # (
            .APIPE_WIDTH            ( 8),
            .BPIPE_WIDTH            ( 8),
            .LANE_NUM               ( 6)
                  ) lane6 (
            .A_rate                 (sim_pipe_rate[0]  ),
            .pclk_a                 (sim_pipe_pclk_in),
            .A_lane_conn            ((NLANES>7)?connected_bits[6]:1'b0),
            .A_phystatus            (iphystatus6 ),
            .A_rxdata               (irxdata6    ),
            .A_rxdatak              (irxdatak6   ),
            .A_rxelecidle           (irxelecidle6),
            .A_rxstatus             (irxstatus6  ),
            .A_rxvalid              (irxvalid6   ),
            .A_rxpolarity           ((NLANES>7)?rxpolarity6:1'b0),
            .A_powerdown            ((NLANES>7)?powerdown6 :2'h0),
            .A_txcompl              ((NLANES>7)?txcompl6   :1'b0),
            .A_txdata               ((NLANES>7)?txdata6    :8'h0),
            .A_txdatak              ((NLANES>7)?txdatak6   :1'b0),
            .A_txdetectrx           ((NLANES>7)?txdetectrx6:1'b0),
            .A_txelecidle           ((NLANES>7)?txelecidle6:1'b0),

            .B_phystatus            (ep_phystatus6 ),
            .B_rxdata               (ep_rxdata6    ),
            .B_rxdatak              (ep_rxdatak6   ),
            .B_rxelecidle           (ep_rxelecidle6),
            .B_rxpolarity           (ep_rxpolarity6),
            .B_rxstatus             (ep_rxstatus6  ),
            .B_rxvalid              (ep_rxvalid6   ),
            .B_powerdown            (ep_powerdown6 ),
            .B_txcompl              (ep_txcompl6   ),
            .B_txdata               (ep_txdata6    ),
            .B_txdatak              (ep_txdatak6   ),
            .B_txdetectrx           (ep_txdetectrx6),
            .B_txelecidle           (ep_txelecidle6),
            .B_lane_conn            (1'b1),
            .B_rate                 (ep_rate            ),
            .pclk_b                 (ep_pclk_pipe),
            .pipe_mode              (simu_mode_pipe),
            .resetn                 (npor)
             );


      wire       iphystatus7 ;
      wire [7:0] irxdata7    ;
      wire       irxdatak7   ;
      wire       irxelecidle7;
      wire [2:0] irxstatus7  ;
      wire       irxvalid7   ;

      assign phystatus7 = (NLANES>7)?iphystatus7 :open_wire[0];
      assign rxdata7    = (NLANES>7)?irxdata7    :open_wire[7:0];
      assign rxdatak7   = (NLANES>7)?irxdatak7   :open_wire[0];
      assign rxelecidle7= (NLANES>7)?irxelecidle7:open_wire[0];
      assign rxstatus7  = (NLANES>7)?irxstatus7  :open_wire[2:0];
      assign rxvalid7   = (NLANES>7)?irxvalid7   :open_wire[0];

      altpcietb_pipe_phy # (
            .APIPE_WIDTH            ( 8),
            .BPIPE_WIDTH            ( 8),
            .LANE_NUM               ( 7)
                  ) lane7 (
            .A_rate                 (sim_pipe_rate[0]  ),
            .pclk_a                 (sim_pipe_pclk_in),
            .A_lane_conn            ((NLANES>7)?connected_bits[7] : 1'b0),
            .A_phystatus            (iphystatus7 ),
            .A_rxdata               (irxdata7    ),
            .A_rxdatak              (irxdatak7   ),
            .A_rxelecidle           (irxelecidle7),
            .A_rxstatus             (irxstatus7  ),
            .A_rxvalid              (irxvalid7   ),
            .A_rxpolarity           ((NLANES>7)?rxpolarity7:1'b0),
            .A_powerdown            ((NLANES>7)?powerdown7 :2'h0),
            .A_txcompl              ((NLANES>7)?txcompl7   :1'b0),
            .A_txdata               ((NLANES>7)?txdata7    :8'h0),
            .A_txdatak              ((NLANES>7)?txdatak7   :1'b0),
            .A_txdetectrx           ((NLANES>7)?txdetectrx7:1'b0),
            .A_txelecidle           ((NLANES>7)?txelecidle7:1'b0),

            .B_phystatus            (ep_phystatus7 ),
            .B_rxdata               (ep_rxdata7    ),
            .B_rxdatak              (ep_rxdatak7   ),
            .B_rxelecidle           (ep_rxelecidle7),
            .B_rxpolarity           (ep_rxpolarity7),
            .B_rxstatus             (ep_rxstatus7  ),
            .B_rxvalid              (ep_rxvalid7   ),
            .B_powerdown            (ep_powerdown7 ),
            .B_txcompl              (ep_txcompl7   ),
            .B_txdata               (ep_txdata7    ),
            .B_txdatak              (ep_txdatak7   ),
            .B_txdetectrx           (ep_txdetectrx7),
            .B_txelecidle           (ep_txelecidle7),
            .B_lane_conn            (1'b1),
            .B_rate                 (ep_rate            ),
            .pclk_b                 (ep_pclk_pipe),
            .pipe_mode              (simu_mode_pipe),
            .resetn                 (npor)
             );

   assign ep_rate            = ep_rate_g3_ext[0];
   assign ep_pclk_pipe       = (ep_rate == 1'b1 ) ?  ep_sim_pipe_clk500_out : ep_sim_pipe_clk250_out;

endmodule
