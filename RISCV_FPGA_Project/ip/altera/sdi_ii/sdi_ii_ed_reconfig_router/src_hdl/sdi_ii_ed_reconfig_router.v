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


`timescale 100 fs / 100 fs

module sdi_ii_ed_reconfig_router # (
  parameter NUM_CHS         = 2,
            NUM_INTERFACES  = 4,
            RX_EN_A2B_CONV  = 0,
            RX_EN_B2A_CONV  = 0,
            VIDEO_STANDARD  = "tr",
            DIRECTION       = "du",
            XCVR_TX_PLL_SEL = 0)
(
  // --------------------------------------------------------------------------
  // Reconfig from XCVR to/from Reconfig Controller
  // --------------------------------------------------------------------------
  output [NUM_INTERFACES*46-1:0]                reconfig_from_xcvr,
  input  [45:0]                                 reconfig_from_xcvr_rx_ch1,
  input  [select_width(XCVR_TX_PLL_SEL)*46-1:0] reconfig_from_xcvr_tx_ch1,
  input  [select_width(XCVR_TX_PLL_SEL)*46-1:0] reconfig_from_xcvr_du_ch1,
  input  [91:0]                                 reconfig_from_xcvr_du_ch0,
  // connection to Link B for HD DL
  input  [45:0]                                 reconfig_from_xcvr_rx_ch1_b,
  input  [select_width(XCVR_TX_PLL_SEL)*46-1:0] reconfig_from_xcvr_tx_ch1_b,
  input  [select_width(XCVR_TX_PLL_SEL)*46-1:0] reconfig_from_xcvr_du_ch1_b,
  input  [91:0]                                 reconfig_from_xcvr_du_ch0_b,
  // loopback a2b and b2a
  input  [45:0]                                 reconfig_from_xcvr_rx_smpte372,
  input  [91:0]                                 reconfig_from_xcvr_tx_smpte372,
  input  [45:0]                                 reconfig_from_xcvr_rx_smpte372_b,
  input  [91:0]                                 reconfig_from_xcvr_tx_smpte372_b,
  // --------------------------------------------------------------------------
  // Reconfig to XCVR to/from Reconfig Controller
  // --------------------------------------------------------------------------
  input  [NUM_INTERFACES*70-1:0]                reconfig_to_xcvr,
  output [69:0]                                 reconfig_to_xcvr_rx_ch1,
  output [select_width(XCVR_TX_PLL_SEL)*70-1:0] reconfig_to_xcvr_tx_ch1,
  output [select_width(XCVR_TX_PLL_SEL)*70-1:0] reconfig_to_xcvr_du_ch1,
  output [139:0]                                reconfig_to_xcvr_du_ch0,
  // connection to Link B for HD DL  
  output [69:0]                                 reconfig_to_xcvr_rx_ch1_b,
  output [select_width(XCVR_TX_PLL_SEL)*70-1:0] reconfig_to_xcvr_tx_ch1_b,
  output [select_width(XCVR_TX_PLL_SEL)*70-1:0] reconfig_to_xcvr_du_ch1_b,
  output [139:0]                                reconfig_to_xcvr_du_ch0_b,
  // loopback a2b and b2a
  output [69:0]                                 reconfig_to_xcvr_rx_smpte372,
  output [139:0]                                reconfig_to_xcvr_tx_smpte372,
  output [69:0]                                 reconfig_to_xcvr_rx_smpte372_b,
  output [139:0]                                reconfig_to_xcvr_tx_smpte372_b,
  // --------------------------------------------------------------------------
  // Reconfig request (start_reconfig) from core (Rx) and User (Tx) 
  // --------------------------------------------------------------------------
  input                                         sdi_rx_start_reconfig_rx_ch1,
  input                                         sdi_rx_start_reconfig_du_ch1,
  input                                         sdi_tx_start_reconfig_tx_ch1,
  input                                         sdi_tx_start_reconfig_du_ch1,
  input                                         sdi_rx_start_reconfig_du_ch0,  
  // --------------------------------------------------------------------------
  // Reconfig acknowledge (reconfig_done) to core (Rx) and User (Tx)
  // --------------------------------------------------------------------------
  output                                        sdi_rx_reconfig_done_rx_ch1,
  output                                        sdi_rx_reconfig_done_du_ch1,
  output                                        sdi_tx_reconfig_done_tx_ch1,
  output                                        sdi_tx_reconfig_done_du_ch1,
  output                                        sdi_rx_reconfig_done_du_ch0,
  // --------------------------------------------------------------------------
  // Reconfig control signal from core (Rx - rx_std) and User (Tx - tx_pll_sel)
  // --------------------------------------------------------------------------
  input  [1:0]                                  sdi_rx_std_rx_ch1,
  input  [1:0]                                  sdi_rx_std_du_ch1,
  input                                         sdi_tx_pll_sel_tx_ch1,
  input                                         sdi_tx_pll_sel_du_ch1,
  input  [1:0]                                  sdi_rx_std_du_ch0,
  // --------------------------------------------------------------------------
  // Reconfig request/acknowledge/control to/from Reconfig Mgmt
  // --------------------------------------------------------------------------
  input  [NUM_CHS-1:0]                          sdi_rx_reconfig_done_from_mgmt, 
  input  [NUM_CHS-1:0]                          sdi_tx_reconfig_done_from_mgmt, 
  output [NUM_CHS-1:0]                          sdi_rx_start_reconfig_to_mgmt,
  output [NUM_CHS*2-1:0]                        sdi_rx_std_to_mgmt,
  output [NUM_CHS-1:0]                          sdi_tx_start_reconfig_to_mgmt,
  output [NUM_CHS-1:0]                          sdi_tx_pll_sel_to_mgmt,
  
  output                                        sdi_tx_pll_sel_to_xcvr_ch1
  
  
  
);

  // These enable signals are essential to avoid any Out-of-boundary or reversed
  // bit assignment error during compilation in simulator Modelsim
  localparam en_a2b                  = RX_EN_A2B_CONV         ? 1 : 0;
  localparam en_b2a                  = RX_EN_B2A_CONV         ? 1 : 0;
  localparam en_dl                   = VIDEO_STANDARD == "dl" ? 1 : 0;
  localparam en_tx                   = DIRECTION == "du"      ? 0 : 1;
  localparam ch1_reconfig_interfaces = XCVR_TX_PLL_SEL        ? 3 : 2;
  
  // -------------------------------------------------------------------------
  // In this example design, the logical channel configuration for transceiver
  // reconfiguration interface is set as follows:
  //   If DIRECTION = du 
  //     CH 0 - CH 1 : SDI DU CH 0
  //     CH 2 - CH 3 : SDI DU 
  //
  //   If DIRECTION = du (for HD DL Standard)
  //     CH 0 - CH 1 : SDI DU CH 0
  //     CH 1 - CH 2 : SDI DU  
  //     CH 3 - CH 4 : SDI DU Link B
  //
  //
  //   If DIRECTION = tx/rx 
  //     CH 0 - CH 1 : SDI DU CH 0
  //     CH 2        : SDI RX
  //     CH 3 - CH 4 : SDI TX 
  //     CH 5        : SDI RX  SMPTE372        (if B2A)
  //     CH 6        : SDI Rx SMPTE372 Link B  (if B2A)
  //     CH 7 - CH 8 : SDI TX  SMPTE372        (if B2A)
  //     CH 9 - CH 10: SDI TX SMPTE372 Link B  (if B2A)
  //
  //   If DIRECTION = tx/rx (for HD DL Link)
  //     CH 0 - CH 1 : SDI DU CH 0
  //     CH 0        : SDI RX
  //     CH 1        : SDI Rx Link B
  //     CH 2 - CH 3 : SDI TX
  //     CH 4 - CH 5 : SDI TX Link B
  //     CH 6        : SDI RX SMPTE372  (if A2B)
  //     CH 7 - CH 8 : SDI TX SMPTE372  (if A2B)
  //     
  //---------------------------------------------------------------------------
  
  localparam [9:0]  INT_TO_0 = 10'd70;
  localparam [9:0]  INT_TO_1 = 10'd140;
  localparam [9:0]  INT_TO_2 = (NUM_INTERFACES > 2) ? 10'd210 : 10'd0;
  localparam [9:0]  INT_TO_3 = (NUM_INTERFACES > 3) ? 10'd280 : 10'd0;
  localparam [9:0]  INT_TO_4 = (NUM_INTERFACES > 4) ? 10'd350 : 10'd0;
  localparam [9:0]  INT_TO_5 = (NUM_INTERFACES > 5) ? 10'd420 : 10'd0;
  localparam [9:0]  INT_TO_6 = (NUM_INTERFACES > 6) ? 10'd490 : 10'd0;
  localparam [9:0]  INT_TO_7 = (NUM_INTERFACES > 7) ? 10'd560 : 10'd0;
  localparam [9:0]  INT_TO_8 = (NUM_INTERFACES > 8) ? 10'd630 : 10'd0;  
  localparam [9:0]  INT_TO_9 = (NUM_INTERFACES > 9) ? 10'd700 : 10'd0;
  localparam [9:0]  INT_TO_10 =(NUM_INTERFACES > 10) ? 10'd770 : 10'd0;
  localparam [9:0]  INT_TO_11 =(NUM_INTERFACES > 11) ? 10'd840 : 10'd0;
  localparam [9:0]  INT_TO_12 =(NUM_INTERFACES > 12) ? 10'd910 : 10'd0;
      
  // Channel 0 is fixed, no need to reassign  
  assign reconfig_to_xcvr_du_ch0   = reconfig_to_xcvr[INT_TO_1-1:0];
  
  assign reconfig_to_xcvr_du_ch0_b = VIDEO_STANDARD == "dl" ? reconfig_to_xcvr[INT_TO_3-1:INT_TO_1] 
                                                            : 140'd0;     


  assign reconfig_to_xcvr_du_ch1   = DIRECTION == "du"      ? VIDEO_STANDARD == "dl" ? reconfig_to_xcvr[en_dl*(ch1_reconfig_interfaces*70+INT_TO_3-1):en_dl*(INT_TO_3)]
                                                                                     : reconfig_to_xcvr[ch1_reconfig_interfaces*70+INT_TO_1-1:INT_TO_1]
                                                            : {(ch1_reconfig_interfaces*70){1'b0}};
 
  //assign reconfig_to_xcvr_du_ch1   = DIRECTION == "du"      ? XCVR_TX_PLL_SEL ? VIDEO_STANDARD == "dl" ? reconfig_to_xcvr[en_dl*(INT_TO_6-1):en_dl*INT_TO_3] 
  //                                                                                                     : reconfig_to_xcvr[(INT_TO_4-1):INT_TO_1]             
  //                                                                            : VIDEO_STANDARD == "dl" ? reconfig_to_xcvr[en_dl*(INT_TO_5-1):en_dl*INT_TO_3]  
  //                                                                                                     : reconfig_to_xcvr[(INT_TO_3-1):INT_TO_1]  
  //                                                          : 140'd0; 
                                                              
  assign reconfig_to_xcvr_du_ch1_b = DIRECTION == "du"      ? VIDEO_STANDARD == "dl" ? reconfig_to_xcvr[en_dl*(ch1_reconfig_interfaces*70*2+INT_TO_3-1)      :en_dl*(ch1_reconfig_interfaces*70+INT_TO_3)]
                                                                                     : reconfig_to_xcvr[en_dl*en_tx*(ch1_reconfig_interfaces*70*2+INT_TO_1-1):en_dl*en_tx*(ch1_reconfig_interfaces*70+INT_TO_1)]
                                                            : {(ch1_reconfig_interfaces*70){1'b0}};
  
  //assign reconfig_to_xcvr_du_ch1_b = DIRECTION == "du"      ? XCVR_TX_PLL_SEL ? VIDEO_STANDARD == "dl" ? reconfig_to_xcvr[en_dl*(INT_TO_8-1):en_dl*INT_TO_6] 
  //                                                                                                     : 210'd0;             
  //                                                                            : VIDEO_STANDARD == "dl" ? reconfig_to_xcvr[en_dl*(INT_TO_7-1):en_dl*INT_TO_5]  
  //                                                                                                     : 140'd0  
  //                                                          : 140'd0;   
                                                                                                                                               
  assign reconfig_to_xcvr_rx_ch1   = DIRECTION == "du"      ? 70'd0                                               
                                                            : VIDEO_STANDARD == "dl" ? reconfig_to_xcvr[en_dl*(INT_TO_4-1):en_dl*(INT_TO_3)] 
                                                                                     : reconfig_to_xcvr[INT_TO_2-1:INT_TO_1];
                                                                                        
  assign reconfig_to_xcvr_rx_ch1_b = VIDEO_STANDARD == "dl" ? (DIRECTION == "du" ? 70'd0 : reconfig_to_xcvr[en_dl*(INT_TO_5-1):en_dl*INT_TO_4])
                                                            : 70'd0;               
                                                                                                                                     
  
  assign reconfig_to_xcvr_tx_ch1   = DIRECTION == "du"      ? {(ch1_reconfig_interfaces*70){1'b0}}
                                                            : VIDEO_STANDARD == "dl" ? reconfig_to_xcvr[en_dl*en_tx*(ch1_reconfig_interfaces*70+INT_TO_5-1):en_dl*en_tx*(INT_TO_5)] 
                                                                                     : reconfig_to_xcvr[en_tx*(ch1_reconfig_interfaces*70+INT_TO_2-1):en_tx*(INT_TO_2)];
                                                            
  //assign reconfig_to_xcvr_tx_ch1   = DIRECTION == "du"      ? 210'd0 
  //                                                          : XCVR_TX_PLL_SEL        ? VIDEO_STANDARD == "dl" ? reconfig_to_xcvr[en_dl*(INT_TO_8-1):en_dl*INT_TO_5] :
  //                                                                                     reconfig_to_xcvr[en_tx*(INT_TO_5-1):en_tx*INT_TO_2] : 
  //                                                            VIDEO_STANDARD == "dl" ? reconfig_to_xcvr[en_dl*(INT_TO_7-1):en_dl*INT_TO_5] :
  //                                                                                     reconfig_to_xcvr[en_tx*(INT_TO_4-1):en_tx*INT_TO_2];
                                                                                                                                                   
  
  assign reconfig_to_xcvr_tx_ch1_b = DIRECTION == "du"      ? {(ch1_reconfig_interfaces*70){1'b0}}
                                                            : VIDEO_STANDARD == "dl" ? reconfig_to_xcvr[en_dl*en_tx*(ch1_reconfig_interfaces*70*2+INT_TO_5-1):en_dl*en_tx*(ch1_reconfig_interfaces*70+INT_TO_5)]  :
                                                                                       {(ch1_reconfig_interfaces*70){1'b0}};
  
  
  //assign reconfig_to_xcvr_tx_ch1_b = DIRECTION == "du"      ? 140'd0 :
  //                                   XCVR_TX_PLL_SEL        ? VIDEO_STANDARD == "dl" ? reconfig_to_xcvr[en_dl*(INT_TO_11-1):en_dl*INT_TO_8] :
  //                                                                                     reconfig_to_xcvr[en_tx*(INT_TO_8-1):en_tx*INT_TO_5]  : 
  //                                                            VIDEO_STANDARD == "dl" ? reconfig_to_xcvr[en_dl*(INT_TO_9-1):en_dl*INT_TO_7]  :
  //                                                                                     reconfig_to_xcvr[en_tx*(INT_TO_6-1):en_tx*INT_TO_4];

  // If a2b or b2a conv is enabled
  assign reconfig_to_xcvr_rx_smpte372   = RX_EN_A2B_CONV ? reconfig_to_xcvr[en_a2b*(INT_TO_10-1):en_a2b*(INT_TO_9)] 
                                                         : RX_EN_B2A_CONV ? reconfig_to_xcvr[en_b2a*(INT_TO_5-1):en_b2a*(INT_TO_4)] 
                                                                          : 70'd0;
                                                                          
  assign reconfig_to_xcvr_rx_smpte372_b = RX_EN_B2A_CONV ? reconfig_to_xcvr[en_b2a*(INT_TO_6-1):en_b2a*(INT_TO_5)] 
                                                         : 70'd0;
	
  assign reconfig_to_xcvr_tx_smpte372   = RX_EN_A2B_CONV ? reconfig_to_xcvr[en_a2b*(INT_TO_12-1):en_a2b*(INT_TO_10)] 
                                                         : RX_EN_B2A_CONV ? reconfig_to_xcvr[en_b2a*(INT_TO_8-1):en_b2a*(INT_TO_6)] 
                                                                          : 140'd0;	
                                                                               
  assign reconfig_to_xcvr_tx_smpte372_b = RX_EN_B2A_CONV ? reconfig_to_xcvr[en_b2a*(INT_TO_10-1):en_b2a*(INT_TO_8)] 
                                                         : 140'd0;
  
  assign reconfig_from_xcvr = VIDEO_STANDARD == "dl" ? DIRECTION == "du" ? {reconfig_from_xcvr_du_ch1_b, 
                                                                            reconfig_from_xcvr_du_ch1, 
                                                                            reconfig_from_xcvr_du_ch0_b, 
                                                                            reconfig_from_xcvr_du_ch0} 
                                                                         : ~RX_EN_A2B_CONV ? {reconfig_from_xcvr_tx_ch1_b, 
                                                                                              reconfig_from_xcvr_tx_ch1, 
                                                                                              reconfig_from_xcvr_rx_ch1_b, 
                                                                                              reconfig_from_xcvr_rx_ch1, 
                                                                                              reconfig_from_xcvr_du_ch0_b, 
                                                                                              reconfig_from_xcvr_du_ch0} 
                                                                                           : {reconfig_from_xcvr_tx_smpte372, 
                                                                                              reconfig_from_xcvr_rx_smpte372, 
                                                                                              reconfig_from_xcvr_tx_ch1_b, 
                                                                                              reconfig_from_xcvr_tx_ch1, 
                                                                                              reconfig_from_xcvr_rx_ch1_b, 
                                                                                              reconfig_from_xcvr_rx_ch1, 
                                                                                              reconfig_from_xcvr_du_ch0_b, 
                                                                                              reconfig_from_xcvr_du_ch0} 
                                                     : DIRECTION == "du" ? {reconfig_from_xcvr_du_ch1, 
                                                                            reconfig_from_xcvr_du_ch0} 
                                                                         : ~RX_EN_B2A_CONV ? {reconfig_from_xcvr_tx_ch1, 
                                                                                              reconfig_from_xcvr_rx_ch1, 
                                                                                              reconfig_from_xcvr_du_ch0} 
                                                                                           : {reconfig_from_xcvr_rx_smpte372_b, 
                                                                                              reconfig_from_xcvr_tx_smpte372, 
                                                                                              reconfig_from_xcvr_rx_smpte372_b, 
                                                                                              reconfig_from_xcvr_rx_smpte372, 
                                                                                              reconfig_from_xcvr_tx_ch1, 
                                                                                              reconfig_from_xcvr_rx_ch1, 
                                                                                              reconfig_from_xcvr_du_ch0};
  
  // Connection to reconfig_mgmt bloc (RX transceiver only)
  assign sdi_rx_start_reconfig_to_mgmt = DIRECTION == "du" ? {sdi_rx_start_reconfig_du_ch1, sdi_rx_start_reconfig_du_ch0} 
                                                           : {sdi_rx_start_reconfig_rx_ch1, sdi_rx_start_reconfig_du_ch0};
                                                           
  assign sdi_rx_std_to_mgmt            = DIRECTION == "du" ? {sdi_rx_std_du_ch1, sdi_rx_std_du_ch0} 
                                                           : {sdi_rx_std_rx_ch1, sdi_rx_std_du_ch0};
                                                          
  assign sdi_rx_reconfig_done_du_ch0   = sdi_rx_reconfig_done_from_mgmt[0];
  
  assign sdi_rx_reconfig_done_rx_ch1   = DIRECTION == "du" ? 1'b0 
                                                           : sdi_rx_reconfig_done_from_mgmt[1];  
                                                          
  assign sdi_rx_reconfig_done_du_ch1   = DIRECTION == "du" ? sdi_rx_reconfig_done_from_mgmt[1] 
                                                           : 1'b0;

  assign sdi_tx_start_reconfig_to_mgmt = DIRECTION == "du" ? {sdi_tx_start_reconfig_du_ch1, 1'b0}
                                                           : {sdi_tx_start_reconfig_tx_ch1, 1'b0};
                                                           
  assign sdi_tx_pll_sel_to_mgmt        = DIRECTION == "du" ? {sdi_tx_pll_sel_du_ch1, 1'b0}                                                        
                                                           : {sdi_tx_pll_sel_tx_ch1, 1'b0};
                                                           
  assign sdi_tx_reconfig_done_tx_ch1   = DIRECTION == "du" ? 1'b0 
                                                           : sdi_tx_reconfig_done_from_mgmt[1];                                                         
  
  assign sdi_tx_reconfig_done_du_ch1   = DIRECTION == "du" ? sdi_tx_reconfig_done_from_mgmt[1]
                                                           : 1'b0; 
                                                           
  assign sdi_tx_pll_sel_to_xcvr_ch1    = DIRECTION == "du" ? sdi_tx_pll_sel_du_ch1                                                        
                                                           : sdi_tx_pll_sel_tx_ch1;

                                                          
  function integer select_width;
  input integer XCVR_TX_PLL_SEL;
    begin
      select_width = XCVR_TX_PLL_SEL ? 3 : 2;
    end
  endfunction

endmodule



