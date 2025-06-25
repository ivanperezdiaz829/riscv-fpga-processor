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


`timescale 1ps/1ps
import altera_xcvr_functions::*;

// submodules: sv_pma_att, 2 sv_xcvr_avmm for ATT rx and tx 
module sv_xcvr_att_native #(
    parameter rx_enable =                        1,
    parameter tx_enable =                        1,
    parameter num_lanes =                        1,
    parameter cdr_reference_clock_frequency =    "250 MHz",   
    parameter pma_data_rate =                    "1250000000 bps",
    parameter ppm_lock_sel =                     "pcs_ppm_lock",	
	parameter ppmsel  =                          "ppmsel_100",
    parameter att_data_path_width =              128
) (
  // TX/RX ports
  input   wire  [num_lanes - 1: 0]           seriallpbken,                   // 1 = enable serial loopback
  // RX ports
  input   wire  [num_lanes - 1 : 0]          rx_crurstn,                     // CDR analog reset (active low)
  input   wire  [num_lanes - 1 : 0]          rx_datain,                      // RX serial data input
  input   wire  [num_lanes - 1 : 0]          rx_cdr_ref_clk,                 // Reference clock for CDR
  input   wire  [num_lanes - 1 : 0]          rx_ltd,                         // Force lock-to-data stream
  input   wire  [num_lanes - 1 : 0]          rx_ltr,                         // Force lock-to-data stream
  input   wire  [num_lanes - 1 : 0]          rx_ppmlock,
  input   wire  [num_lanes - 1 : 0]          rx_discdrreset,                 // New port to disable CDR reset 
  output  wire  [num_lanes - 1 : 0]          rx_clklow,                      // RX low frequency recovered clock 
  output  wire  [num_lanes - 1 : 0]          rx_fref,                        // RX PFD reference clock (rx_cdr_refclk after divider)
  output  wire  [num_lanes - 1 : 0]          rx_clkdivrx,                    // RX parallel clock output
  output  wire  [num_lanes - 1 : 0]          rx_is_lockedtodata,             // Indicates lock to incoming data rate
  output  wire  [num_lanes - 1 : 0]          rx_is_lockedtoref,              // Indicates lock to reference clock
  output  wire  [num_lanes*att_data_path_width-1: 0]         rx_dataout,                 // 
  // TX ports
  //input port for buf
  input   wire                               tx_rxdetclk,                    // Clock for detection of downstream receiver (125MHz ?)
  //output port for att tx buf
  output  wire  [num_lanes - 1 : 0]          tx_dataout,                     // TX serial data output
  //input ports for ser
  input   wire                               tx_rstn,                        // TODO - Examine resets
  input   wire  [num_lanes*att_data_path_width - 1 : 0]      tx_datain,                      // TX parallel data output
  input   wire  [num_lanes -1 : 0]           tx_ser_clk,                    // High-speed serial clock(s) from PLL
  //output ports for ser
  output   wire  [num_lanes -1 : 0]          tx_clkdivtx,                    // High-speed serial clock(s) from PLL

  // sv_xcvr_avmm ports
  // Reconfiguration signal bundles
  input   wire  [(tx_enable+rx_enable)*num_lanes*W_S5_RECONFIG_BUNDLE_TO_XCVR  -1:0]  reconfig_to_xcvr,
  output  wire  [(tx_enable+rx_enable)*num_lanes*W_S5_RECONFIG_BUNDLE_FROM_XCVR-1:0]  reconfig_from_xcvr

);

// internal wires
    wire [ num_lanes-1:0 ]     rxplllock;
    // rx_pma_att's input/output ports
    wire [ num_lanes*11-1:0 ]  rx_avmmaddress;
    wire [ num_lanes*2-1:0 ]   rx_avmmbyteen;
    wire [ num_lanes-1:0 ]     rx_avmmclk;
    wire [ num_lanes-1:0 ]     rx_avmmread;
    wire [ num_lanes-1:0 ]     rx_avmmrstn;
    wire [ num_lanes-1:0 ]     rx_avmmwrite;
    wire [ num_lanes*16-1:0 ]  rx_avmmwritedata;
    wire [ 0:0 ]               rx_calclk;     // Calibration clock driven from reconfig clock to aux block
    wire [ num_lanes*16-1:0 ]  rx_avmmreaddata;
    wire [ num_lanes*16-1:0 ]  deser_avmmreaddata;
    wire [ num_lanes-1:0 ]     rx_blockselect;
    wire [ num_lanes-1:0 ]     deser_blockselect;

    wire [ num_lanes*W_S5_RECONFIG_BUNDLE_TO_XCVR  -1:0] tx_reconfig_to_xcvr;
    wire [ num_lanes*W_S5_RECONFIG_BUNDLE_TO_XCVR  -1:0] rx_reconfig_to_xcvr;
    wire [ num_lanes*W_S5_RECONFIG_BUNDLE_FROM_XCVR-1:0] tx_reconfig_from_xcvr;
    wire [ num_lanes*W_S5_RECONFIG_BUNDLE_FROM_XCVR-1:0] rx_reconfig_from_xcvr;


    // tx_pma_att's input/output ports
    wire [ num_lanes*11-1:0 ]  tx_avmmaddress;
    wire [ num_lanes*2-1:0 ]   tx_avmmbyteen;
    wire [ num_lanes-1:0 ]     tx_avmmclk;
    wire [ num_lanes-1:0 ]     tx_avmmread;
    wire [ num_lanes-1:0 ]     tx_avmmrstn;
    wire [ num_lanes-1:0 ]     tx_avmmwrite;
    wire [ num_lanes*16-1:0 ]  tx_avmmwritedata;
    wire [ 0:0 ]               tx_calclk;     // Calibration clock driven from reconfig clock to aux block
    wire [ num_lanes*16-1:0 ]  tx_avmmreaddata;
    wire [ num_lanes*16-1:0 ]  ser_avmmreaddata;
    wire [ num_lanes-1:0 ]     tx_blockselect;
    wire [ num_lanes-1:0 ]     ser_blockselect;
    wire [ num_lanes-1:0 ]     pfdmodelock;
    wire [ num_lanes-1:0 ]     rx_crurstb;

    assign rx_is_lockedtoref  = pfdmodelock;
    assign rx_is_lockedtodata = rxplllock;
    assign rx_crurstb         = {num_lanes{rx_discdrreset}}| rx_crurstn; //CDR reset
   // assign ppmlock            = {num_lanes{1'b1}};
     //assign rx_is_lockedtoref  = rx_ltr & rxplllock;
    //assign rx_is_lockedtodata = rx_ltd & rxplllock;
    
    assign reconfig_from_xcvr = (rx_enable == 1 && tx_enable == 0) ? rx_reconfig_from_xcvr :                          // 1 AVMM interface
                                (rx_enable == 0 && tx_enable == 1) ? tx_reconfig_from_xcvr :
                                                                     {tx_reconfig_from_xcvr,rx_reconfig_from_xcvr};

                      
sv_pma_att #(
    .rx_enable (                                          rx_enable ),
    .tx_enable (                                          tx_enable ),
    .cdr_reference_clock_frequency (  cdr_reference_clock_frequency ),   
    .pma_data_rate  (                                 pma_data_rate ),
    .ppm_lock_sel (                                    ppm_lock_sel ),
    .ppmsel (                                                ppmsel ),
    .num_lanes (                                          num_lanes )
) sv_pma_att_inst (
// common interface that is shared by submodules
     .slpbk (                 seriallpbken ),    // input [ num_lanes-1:0 ]
// rx_pma_att's input/output ports
     .rx_avmmaddress (      rx_avmmaddress ),    // input [ num_lanes*11-1:0 ]
     .rx_avmmbyteen (        rx_avmmbyteen ),    // input [ num_lanes*2-1:0 ]
     .rx_avmmclk (              rx_avmmclk ),    // input [ num_lanes-1:0 ]
     .rx_avmmread (            rx_avmmread ),    // input [ num_lanes-1:0 ]
     .rx_avmmrstn (            rx_avmmrstn ),    // input [ num_lanes-1:0 ]
     .rx_avmmwrite (          rx_avmmwrite ),    // input [ num_lanes-1:0 ]
     .rx_avmmwritedata (  rx_avmmwritedata ),    // input [ num_lanes*16-1:0 ]

    //pma aux calibration clocks
     .rx_calclk (   {num_lanes{rx_calclk}} ),
     .tx_calclk (   {num_lanes{tx_calclk}} ),

    // pma_rx_att's wires
     .ocden (                        1'b0  ),    // input [ num_lanes-1:0 ]
     .rxnbidirin (                   1'b0  ),    // input [ num_lanes-1:0 ]
     .rxpbidirin (               rx_datain ),    // input [ num_lanes-1:0 ]
     .rx_pma_rstn (             rx_crurstn ),    // input [ num_lanes-1:0 ]
     .rx_avmmreaddata (    rx_avmmreaddata ),    // output [ num_lanes*16-1:0 ]
     .rx_blockselect (      rx_blockselect ),    // output [ num_lanes-1:0 ]

    // cdr_att's input  wires
     .crurstb (                 rx_crurstb ),    // input [ num_lanes-1:0 ]
     .ltd (                         rx_ltd ),    // input [ num_lanes-1:0 ]
     .ltr (                         rx_ltr ),    // input [ num_lanes-1:0 ]
     .ppmlock (                 rx_ppmlock ),    // input [ num_lanes-1:0 ]
     .refclk (              rx_cdr_ref_clk ),    // input [ num_lanes-1:0 ]
     .discdrreset (         rx_discdrreset ),
     .ck0pd (                    /*ck0pd*/ ),    // output [ num_lanes-1:0 ]
     .ck180pd (                /*ck180pd*/ ),    // output [ num_lanes-1:0 ]
     .ck270pd (                /*ck270pd*/ ),    // output [ num_lanes-1:0 ]
     .ck90pd (                  /*ck90pd*/ ),    // output [ num_lanes-1:0 ]
     .clklow (                   rx_clklow ),    // output [ num_lanes-1:0 ]
     .fref (                       rx_fref ),    // output [ num_lanes-1:0 ]
     .pdof (                      /*pdof*/ ),    // output [ num_lanes*4-1:0 ]
     .pfdmodelock (            pfdmodelock ),    // output [ num_lanes-1:0 ]
     .rxplllock (                rxplllock ),    // output [ num_lanes-1:0 ]
    
    // pma_deser_att's input  wires
     .deser_avmmreaddata ( deser_avmmreaddata ), // output [ num_lanes*16-1:0 ]
     .deser_blockselect ( deser_blockselect ),   // output [ num_lanes-1:0 ]
     .clkdivrx (               rx_clkdivrx ),    // output [ num_lanes-1:0 ]
     .dataout (                 rx_dataout ),    // output [ num_lanes*att_data_path_width-1:0 ]

// tx_pma_att's input/output ports
     .tx_avmmaddress (      tx_avmmaddress ),    // input [ num_lanes*11-1:0 ]
     .tx_avmmbyteen (        tx_avmmbyteen ),    // input [ num_lanes*2-1:0 ]
     .tx_avmmclk (              tx_avmmclk ),    // input [ num_lanes-1:0 ]
     .tx_avmmread (            tx_avmmread ),    // input [ num_lanes-1:0 ]
     .tx_avmmrstn (            tx_avmmrstn ),    // input [ num_lanes-1:0 ]
     .tx_avmmwrite (          tx_avmmwrite ),    // input [ num_lanes-1:0 ]
     .tx_avmmwritedata (  tx_avmmwritedata ),    // input [ num_lanes*16-1:0 ]
    // pma_tx_att's wire
     .tx_pma_rstn (                tx_rstn ),    // input [ num_lanes-1:0 ]
     .vonbidirin (                    1'bZ ),    // input [ num_lanes-1:0 ]
     .vopbidirin (                    1'bZ ),    // input [ num_lanes-1:0 ]
     .tx_avmmreaddata (    tx_avmmreaddata ),    // output [ num_lanes*16-1:0 ]
     .tx_blockselect (      tx_blockselect ),    // output [ num_lanes-1:0 ]
     .vonbidirout (        /*vonbidirout*/ ),    // output [ num_lanes-1:0 ]
     .vopbidirout (             tx_dataout ),    // output [ num_lanes-1:0 ]

    // pma_ser_att's input  wires
     .clk0 (                    tx_ser_clk ),    // input [ num_lanes-1:0 ]
     .clk180 (                      1'b0   ),    // input [ num_lanes-1:0 ]
     .datain (                   tx_datain ),    // input [ num_lanes*att_data_path_width-1:0 ]
     .ser_avmmreaddata (  ser_avmmreaddata ),    // output [ num_lanes*16-1:0 ]
     .ser_blockselect (    ser_blockselect ),    // output [ num_lanes-1:0 ]
     .clkdivtxtop (            tx_clkdivtx )     // output [ num_lanes-1:0 ]
);

//********************** End of ATT PMA ****************************
//*********************************************************************
generate if( rx_enable == 1 ) begin

assign rx_reconfig_to_xcvr = reconfig_to_xcvr[num_lanes*W_S5_RECONFIG_BUNDLE_TO_XCVR  -1:0];

  // AVMM for ATT RX
  sv_xcvr_avmm #(
      .bonded_lanes                  (num_lanes     ), // Number of lanes
      .bonding_master_ch             (0             ), // Indicates which channel is master
      .att_enable                    (1             ),
      .rx_enable                     (rx_enable     ),
      .tx_enable                     (0             ),
      .request_adce_cont             (0             ), // ensure that all service requests are '0' - there are no cal IPs for ATT
      .request_adce_single           (0             ),
      .request_adce_cancel           (0             ),
      .request_dcd                   (0             ), 
      .request_dfe                   (0             ),
      .request_vrc                   (0             ),
      .request_offset                (0             )
      //.bonding_master_only           ("false"           )  // Indicates bonding_master_channel is MASTER_ONLY
    ) sv_xcvr_avmm_4rx_inst (
      // Reconfiguration signal bundles
      .reconfig_to_xcvr              (rx_reconfig_to_xcvr[num_lanes*W_S5_RECONFIG_BUNDLE_TO_XCVR  -1:0]              ),
      .reconfig_from_xcvr            (rx_reconfig_from_xcvr[num_lanes*W_S5_RECONFIG_BUNDLE_FROM_XCVR  -1:0]            ),
      // Calibration clocks
      .calclk                        (rx_calclk                         ), // Calibration clock driven from reconfig clock to aux block
      // Testbus signals
      .pma_adaptdone                 (1'b0                              ),
      .pma_hardoccaldone             (1'b0                              ),
      .pma_eyemonitor                (/*pma_eyemonitor*/                ),
      .pma_hardoccalen               (/*pma_hardoccalen*/               ),
      .pma_adcecapture               (/*pma_adcecapture*/               ),
      .pma_adcestandby               (/*pma_adcestandby*/               ),
      //PCS resets - currently not used for ATT
      .in_pld_8g_txurstpcs_n         (1'b0            ), // 8g PCS TX reset
      .in_pld_8g_rxurstpcs_n         (1'b0            ), // 8g PCS RX reset
      .in_pld_10g_tx_rst_n           (1'b0            ), // 10g PCS TX reset
      .in_pld_10g_rx_rst_n           (1'b0            ), // 10g PCS RX reset
      .out_pld_8g_txurstpcs_n        (                ), // 8g PCS TX reset
      .out_pld_8g_rxurstpcs_n        (                ), // 8g PCS RX reset
      .out_pld_10g_tx_rst_n          (                ), // 10g PCS TX reset
      .out_pld_10g_rx_rst_n          (                ), // 10g PCS RX reset
      //PMA resets
      .rx_crurstn                    (1'b0            ), // CDR analog reset (active low)
      .in_pld_rxpma_rstb_in          (1'b0            ),
      .out_rx_crurstn                (                ), // CDR analog reset (active low)
      .out_pld_rxpma_rstb_in         (                ),

      // Channel AVMM interface signals
      .chnl_avmm_clk                 ( rx_avmmclk                 ),
      .chnl_avmm_rstn                ( rx_avmmrstn                ),
      .chnl_avmm_writedata           ( rx_avmmwritedata           ),
      .chnl_avmm_address             ( rx_avmmaddress             ),
      .chnl_avmm_write               ( rx_avmmwrite               ),
      .chnl_avmm_read                ( rx_avmmread                ),
      .chnl_avmm_byteen              ( rx_avmmbyteen              ),
      // PMA AVMM signals
      .pma_avmmreaddata_tx_cgb       ( 16'b0       ), // TX AVMM CGB readdata (16 for each lane)
      .pma_avmmreaddata_tx_ser       ( 16'b0       ), // TX AVMM SER readdata (16 for each lane)
      .pma_avmmreaddata_tx_buf       ( 16'b0       ), // TX AVMM BUF readdata (16 for each lane)
      .pma_avmmreaddata_att_tx_ser   ( 16'd0       ), // TX AVMM SER readdata (16 for each lane)
      .pma_avmmreaddata_att_tx_buf   ( 16'd0       ), // TX AVMM BUF readdata (16 for each lane)
      .pma_avmmreaddata_rx_ser       ( 16'b0       ), // RX AVMM DESER readdata (16 for each lane)
      .pma_avmmreaddata_rx_buf       ( 16'b0       ), // RX AVMM BUF readdata (16 for each lane)
      .pma_avmmreaddata_rx_cdr       ( 16'b0       ), // RX AVMM CDR readdata (16 for each lane)
      .pma_avmmreaddata_rx_mux       ( 16'b0       ), // RX AVMM CDR MUX readdata (16 for each lane)
      .pma_avmmreaddata_att_rx_ser   ( deser_avmmreaddata ), // RX AVMM DESER readdata (16 for each lane)
      .pma_avmmreaddata_att_rx_buf   ( rx_avmmreaddata ), // RX AVMM BUF readdata (16 for each lane)
      .pma_blockselect_tx_cgb        ( 1'b0        ), // TX AVMM CGB blockselect (1 for each lane)
      .pma_blockselect_tx_ser        ( 1'b0        ), // TX AVMM SER blockselect (1 for each lane)
      .pma_blockselect_tx_buf        ( 1'b0        ), // TX AVMM BUF blockselect (1 for each lane)
      .pma_blockselect_att_tx_ser    ( 1'b0        ), // TX AVMM SER blockselect (1 for each lane)
      .pma_blockselect_att_tx_buf    ( 1'b0        ), // TX AVMM BUF blockselect (1 for each lane)
      .pma_blockselect_rx_ser        ( 1'b0        ), // RX AVMM DESER blockselect (1 for each lane)
      .pma_blockselect_rx_buf        ( 1'b0        ), // RX AVMM BUF blockselect (1 for each lane)
      .pma_blockselect_rx_cdr        ( 1'b0        ), // RX AVMM CDR readdata (16 for each lane)
      .pma_blockselect_rx_mux        ( 1'b0        ), // RX AVMM CDR MUX readdata (16 for each lane)
      .pma_blockselect_att_rx_ser    ( deser_blockselect ), // RX AVMM DESER blockselect (1 for each lane)
      .pma_blockselect_att_rx_buf    ( rx_blockselect ), // RX AVMM BUF blockselect (1 for each lane)
      // PCS AVMM signals
      .avmmreaddata_com_pcs_pma_if   ( 16'b0 ),
      .avmmreaddata_com_pld_pcs_if   ( 16'b0 ),
      .avmmreaddata_pcs10g_rx        ( 16'b0 ),
      .avmmreaddata_pcs10g_tx        ( 16'b0 ),
      .avmmreaddata_pcs8g_rx         ( 16'b0 ),
      .avmmreaddata_pcs8g_tx         ( 16'b0 ),
      .avmmreaddata_pcs_g3_rx        ( 16'b0 ),
      .avmmreaddata_pcs_g3_tx        ( 16'b0 ),
      .avmmreaddata_pipe12           ( 16'b0 ),
      .avmmreaddata_pipe3            ( 16'b0 ),
      .avmmreaddata_rx_pcs_pma_if    ( 16'b0 ),
      .avmmreaddata_rx_pld_pcs_if    ( 16'b0 ),
      .avmmreaddata_tx_pcs_pma_if    ( 16'b0 ),
      .avmmreaddata_tx_pld_pcs_if    ( 16'b0 ),
      .blockselect_com_pcs_pma_if    ( 1'b0 ),
      .blockselect_com_pld_pcs_if    ( 1'b0 ),
      .blockselect_pcs10g_rx         ( 1'b0 ),
      .blockselect_pcs10g_tx         ( 1'b0 ),
      .blockselect_pcs8g_rx          ( 1'b0 ),
      .blockselect_pcs8g_tx          ( 1'b0 ),
      .blockselect_pcs_g3_rx         ( 1'b0 ),
      .blockselect_pcs_g3_tx         ( 1'b0 ),
      .blockselect_pipe12            ( 1'b0 ),
      .blockselect_pipe3             ( 1'b0 ),
      .blockselect_rx_pcs_pma_if     ( 1'b0 ),
      .blockselect_rx_pld_pcs_if     ( 1'b0 ),
      .blockselect_tx_pcs_pma_if     ( 1'b0 ),
      .blockselect_tx_pld_pcs_if     ( 1'b0 )
);
end
else begin //rx_enable==0
  assign rx_avmmclk         = {num_lanes{1'b0}};          
  assign rx_avmmrstn        = {num_lanes{1'b0}};        
  assign rx_avmmwritedata   = {num_lanes{16'd0}};        
  assign rx_avmmaddress     = {num_lanes{12'd0}};        
  assign rx_avmmwrite       = {num_lanes{1'b0}};       
  assign rx_avmmread        = {num_lanes{1'b0}};       
  assign rx_avmmbyteen      = {num_lanes{1'b0}};
end
endgenerate

generate if( rx_enable == 1 && tx_enable == 1) begin
    assign tx_reconfig_to_xcvr = reconfig_to_xcvr[num_lanes*W_S5_RECONFIG_BUNDLE_TO_XCVR  +: num_lanes*W_S5_RECONFIG_BUNDLE_TO_XCVR ]; 
  end else begin
    assign tx_reconfig_to_xcvr = reconfig_to_xcvr[num_lanes*W_S5_RECONFIG_BUNDLE_TO_XCVR  -1:0]; 
  end
endgenerate

generate if( tx_enable == 1 ) begin

//if there is an Rx AVMM interface, then the Tx uses the upper portion of the
//bus or else is uses the lower portion

  // AVMM for ATT TX
  sv_xcvr_avmm #(
      .bonded_lanes                  (num_lanes                  ), // Number of lanes
      .bonding_master_ch             (0             ), // Indicates which channel is master
      .att_enable                    (1             ),
      .rx_enable                     (0             ),
      .tx_enable                     (tx_enable     ),
      .request_adce_cont             (0             ), // ensure that all service requests are '0' - there are no cal IPs for ATT
      .request_adce_single           (0             ),
      .request_adce_cancel           (0             ),
      .request_dcd                   (0             ), 
      .request_dfe                   (0             ),
      .request_vrc                   (0             ),
      .request_offset                (0             )
     // .bonding_master_only           ("false"           )  // Indicates bonding_master_channel is MASTER_ONLY
    ) sv_xcvr_avmm_4tx_inst (
      // Reconfiguration signal bundles
      .reconfig_to_xcvr              (tx_reconfig_to_xcvr[num_lanes*W_S5_RECONFIG_BUNDLE_TO_XCVR  -1:0] ),
      .reconfig_from_xcvr            (tx_reconfig_from_xcvr[num_lanes*W_S5_RECONFIG_BUNDLE_FROM_XCVR  -1:0] ),
      // Calibration clocks
      .calclk                        (tx_calclk                     ), // Calibration clock driven from reconfig clock to aux block
      // Testbus signals
      .pma_adaptdone                 (1'b0                          ),
      .pma_hardoccaldone             (1'b0                          ),
      .pma_eyemonitor                (/*pma_eyemonitor*/            ),
      .pma_hardoccalen               (/*pma_hardoccalen*/           ),
      .pma_adcecapture               (/*pma_adcecapture*/           ),
      .pma_adcestandby               (/*pma_adcestandby*/           ),
      .pcs_8g_prbs_done              (/*unused*/                    ),
      .pcs_8g_prbs_err               (/*unused*/                    ),
      .pcs_10g_prbs_done             (/*unused*/                    ),
      .pcs_10g_prbs_err              (/*unused*/                    ),
      // Control inputs from PLD
      .in_pld_10g_rx_prbs_err_clr    ( 1'b0         ),
      .seriallpbken                  ( 1'b0         ), // 1 = enable serial loopback
      // PCS resets
      .in_pld_8g_txurstpcs_n         ( 1'b1         ), // 8g PCS TX reset
      .in_pld_8g_rxurstpcs_n         ( 1'b1         ), // 8g PCS RX reset
      .in_pld_10g_tx_rst_n           ( 1'b1         ), // 10g PCS TX reset
      .in_pld_10g_rx_rst_n           ( 1'b1         ), // 10g PCS RX reset
      .out_pld_8g_txurstpcs_n        (              ), // 8g PCS TX reset
      .out_pld_8g_rxurstpcs_n        (              ), // 8g PCS RX reset
      .out_pld_10g_tx_rst_n          (              ), // 10g PCS TX reset
      .out_pld_10g_rx_rst_n          (              ), // 10g PCS RX reset
      // PMA resets
      .rx_crurstn                    ( 1'b1         ), // CDR analog reset (active low)
      .in_pld_rxpma_rstb_in          ( 1'b1         ),
      .out_rx_crurstn                (              ), // CDR analog reset (active low)
      .out_pld_rxpma_rstb_in         (              ),
      // Channel AVMM interface signals
      .chnl_avmm_clk                 ( tx_avmmclk                 ),
      .chnl_avmm_rstn                ( tx_avmmrstn                ),
      .chnl_avmm_writedata           ( tx_avmmwritedata           ),
      .chnl_avmm_address             ( tx_avmmaddress             ),
      .chnl_avmm_write               ( tx_avmmwrite               ),
      .chnl_avmm_read                ( tx_avmmread                ),
      .chnl_avmm_byteen              ( tx_avmmbyteen              ),
      // PMA AVMM signals
      .pma_avmmreaddata_tx_cgb       ( 16'b0       ), // TX AVMM CGB readdata (16 for each lane)
      .pma_avmmreaddata_tx_ser       ( 16'b0       ), // TX AVMM SER readdata (16 for each lane)
      .pma_avmmreaddata_tx_buf       ( 16'b0       ), // TX AVMM BUF readdata (16 for each lane)
      .pma_avmmreaddata_att_tx_ser   ( ser_avmmreaddata       ), // TX AVMM SER readdata (16 for each lane)
      .pma_avmmreaddata_att_tx_buf   ( tx_avmmreaddata       ), // TX AVMM BUF readdata (16 for each lane)
      .pma_avmmreaddata_rx_ser       ( 16'b0       ), // RX AVMM DESER readdata (16 for each lane)
      .pma_avmmreaddata_rx_buf       ( 16'b0       ), // RX AVMM BUF readdata (16 for each lane)
      .pma_avmmreaddata_rx_cdr       ( 16'b0       ), // RX AVMM CDR readdata (16 for each lane)
      .pma_avmmreaddata_rx_mux       ( 16'b0       ), // RX AVMM CDR MUX readdata (16 for each lane)
      .pma_avmmreaddata_att_rx_ser   ( 16'd0       ), // RX AVMM DESER readdata (16 for each lane)
      .pma_avmmreaddata_att_rx_buf   ( 16'd0       ), // RX AVMM BUF readdata (16 for each lane)
      .pma_blockselect_tx_cgb        ( 1'b0        ), // TX AVMM CGB blockselect (1 for each lane)
      .pma_blockselect_tx_ser        ( 1'b0        ), // TX AVMM SER blockselect (1 for each lane)
      .pma_blockselect_tx_buf        ( 1'b0        ), // TX AVMM BUF blockselect (1 for each lane)
      .pma_blockselect_att_tx_ser    ( ser_blockselect ), // TX AVMM SER blockselect (1 for each lane)
      .pma_blockselect_att_tx_buf    ( tx_blockselect    ), // TX AVMM BUF blockselect (1 for each lane)
      .pma_blockselect_rx_ser        ( 1'b0        ), // RX AVMM SER blockselect (1 for each lane)
      .pma_blockselect_rx_buf        ( 1'b0        ), // RX AVMM BUF blockselect (1 for each lane)
      .pma_blockselect_rx_cdr        ( 1'b0        ), // RX AVMM CDR readdata (16 for each lane)
      .pma_blockselect_rx_mux        ( 1'b0        ), // RX AVMM CDR MUX readdata (16 for each lane)
      .pma_blockselect_att_rx_ser    ( 1'b0        ), // RX AVMM DESER blockselect (1 for each lane)
      .pma_blockselect_att_rx_buf    ( 1'b0        ), // RX AVMM BUF blockselect (1 for each lane)
      // PCS AVMM signals
      .avmmreaddata_com_pcs_pma_if   ( 16'b0 ),
      .avmmreaddata_com_pld_pcs_if   ( 16'b0 ),
      .avmmreaddata_pcs10g_rx        ( 16'b0 ),
      .avmmreaddata_pcs10g_tx        ( 16'b0 ),
      .avmmreaddata_pcs8g_rx         ( 16'b0 ),
      .avmmreaddata_pcs8g_tx         ( 16'b0 ),
      .avmmreaddata_pcs_g3_rx        ( 16'b0 ),
      .avmmreaddata_pcs_g3_tx        ( 16'b0 ),
      .avmmreaddata_pipe12           ( 16'b0 ),
      .avmmreaddata_pipe3            ( 16'b0 ),
      .avmmreaddata_rx_pcs_pma_if    ( 16'b0 ),
      .avmmreaddata_rx_pld_pcs_if    ( 16'b0 ),
      .avmmreaddata_tx_pcs_pma_if    ( 16'b0 ),
      .avmmreaddata_tx_pld_pcs_if    ( 16'b0 ),
      .blockselect_com_pcs_pma_if    ( 1'b0 ),
      .blockselect_com_pld_pcs_if    ( 1'b0 ),
      .blockselect_pcs10g_rx         ( 1'b0 ),
      .blockselect_pcs10g_tx         ( 1'b0 ),
      .blockselect_pcs8g_rx          ( 1'b0 ),
      .blockselect_pcs8g_tx          ( 1'b0 ),
      .blockselect_pcs_g3_rx         ( 1'b0 ),
      .blockselect_pcs_g3_tx         ( 1'b0 ),
      .blockselect_pipe12            ( 1'b0 ),
      .blockselect_pipe3             ( 1'b0 ),
      .blockselect_rx_pcs_pma_if     ( 1'b0 ),
      .blockselect_rx_pld_pcs_if     ( 1'b0 ),
      .blockselect_tx_pcs_pma_if     ( 1'b0 ),
      .blockselect_tx_pld_pcs_if     ( 1'b0 )
);
end
else begin //tx_enable==0
  assign tx_avmmclk         = {num_lanes{1'b0}};          
  assign tx_avmmrstn        = {num_lanes{1'b0}};        
  assign tx_avmmwritedata   = {num_lanes{16'd0}};        
  assign tx_avmmaddress     = {num_lanes{12'd0}};        
  assign tx_avmmwrite       = {num_lanes{1'b0}};       
  assign tx_avmmread        = {num_lanes{1'b0}};       
  assign tx_avmmbyteen      = {num_lanes{1'b0}};
end
endgenerate

endmodule
