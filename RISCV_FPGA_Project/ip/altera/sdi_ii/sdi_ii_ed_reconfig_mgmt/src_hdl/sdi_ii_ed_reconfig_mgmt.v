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

module sdi_ii_ed_reconfig_mgmt # (
    parameter NUM_CHS = 2,
              FAMILY  = "Stratix V",
              VIDEO_STANDARD = "tr",
              XCVR_TX_PLL_SEL = 1,
              DIRECTION = "tx" 
  )
  (
   input                 reconfig_clk,
   input                 rst,
   input [NUM_CHS-1:0]   sdi_tx_start_reconfig,
   input [NUM_CHS-1:0]   sdi_tx_pll_sel,
   output [NUM_CHS-1:0]  sdi_tx_reconfig_done,
   input [NUM_CHS-1:0]   sdi_rx_start_reconfig,
   input [NUM_CHS*2-1:0] sdi_rx_std,
   output [NUM_CHS-1:0]  sdi_rx_reconfig_done,

   //Reconfiguration connections
   input         reconfig_busy,
   output [8:0]  reconfig_mgmt_address,     // reconfig_mgmt.address
   output        reconfig_mgmt_read,        //              .read
   input  [31:0] reconfig_mgmt_readdata,    //              .readdata
   input         reconfig_mgmt_waitrequest, //              .waitrequest
   output        reconfig_mgmt_write,       //              .write
   output [31:0] reconfig_mgmt_writedata,   //              .writedata
   
   input  [31:0] reconfig_mif_address,      // reconfig_mif .address
   input         reconfig_mif_read,         //              .read
   output [15:0] reconfig_mif_readdata,     //              .readdata
   output        reconfig_mif_waitrequest   //              .waitrequest
  );

  //===========================================================================
  // Only generate the reconfig logic when necessary
  // -> When video_std = triple rate or dual standard or Tx PLL sel is enabled
  //===========================================================================
  generate if ( VIDEO_STANDARD == "tr" | VIDEO_STANDARD == "ds" | XCVR_TX_PLL_SEL) 
    begin: reconfig_logic_gen
      sdi_ii_reconfig_logic #(
         .FAMILY  (FAMILY),
         .NUM_CHS (NUM_CHS),
         .DIRECTION (DIRECTION),
         .VIDEO_STANDARD(VIDEO_STANDARD)
      ) u_reconfig_logic (
         .reconfig_clk              (reconfig_clk),           
         .rst                       (rst),
         .sdi_tx_start_reconfig     (sdi_tx_start_reconfig), 
         .sdi_tx_pll_sel            (sdi_tx_pll_sel),         
         .sdi_tx_reconfig_done      (sdi_tx_reconfig_done),                   
         .sdi_rx_start_reconfig     (sdi_rx_start_reconfig), 
         .sdi_rx_std                (sdi_rx_std),         
         .sdi_rx_reconfig_done      (sdi_rx_reconfig_done),           
         .reconfig_busy             (reconfig_busy),             
         .reconfig_mgmt_address     (reconfig_mgmt_address),               
         .reconfig_mgmt_read        (reconfig_mgmt_read),                 
         .reconfig_mgmt_readdata    (reconfig_mgmt_readdata),              
         .reconfig_mgmt_waitrequest (reconfig_mgmt_waitrequest),           
         .reconfig_mgmt_write       (reconfig_mgmt_write),                
         .reconfig_mgmt_writedata   (reconfig_mgmt_writedata)      
      );

      // Drive unused alt_xcvr_reconfig reconfig_mif interface to GND	
      assign reconfig_mif_readdata    = 16'd0;
      assign reconfig_mif_waitrequest = 1'b0;      

    end else begin
       
      // If Single Rate SD/HD/3G/DL, drive unused alt_xcvr_reconfig reconfig_mgmt interface to GND
      assign reconfig_mgmt_address   = 9'd0;
      assign reconfig_mgmt_write     = 1'b0;
      assign reconfig_mgmt_writedata = 32'd0;
      assign reconfig_mgmt_read      = 1'b0;
       
    end     
  endgenerate 

endmodule

