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


 
//===========================================================================
// This confidential and proprietary software may be used only as authorized
// by a licensing agreement from ALTERA
// copyright notice must be reproduced on all authorized copies.
//============================================================================

//============================================================================
// Reconfig PMA TX Equalization State Machine
// Generates data address and control signals to AVMM master SM
//============================================================================

`timescale 1 ps / 1 ps

module rcfg_dfe_ctrl
 (
  input  wire        clk,
  input  wire        reset,
     // PMA RX EQ reconfig requests
  input  wire            dfe_start_rc,  // start the TX EQ reconfig
  input  wire [1:0]      dfe_mode,      // DFE mode
  output reg             rc_busy,       // reconfig is busy
    //  HSSI
  input  wire       rcfg_wtrqst,        // AVMM wait request
    //  AVMM master State Machine
  output reg [9:0]    ctrl_addr,
  output reg [7:0]    ctrl_writedata,
  output wire         ctrl_write,
  input  wire         ctrl_busy
  );

//===========================================================================
// Define Wires and Variables
//===========================================================================

//  TEMPORARY Placeholder for handshaking - will update later
  reg [7:0] hndshk;   // shift register to set/delay the busy
  assign rc_busy  = hndshk[7];

  always_ff @(posedge clk or posedge reset) begin
   if (reset) hndshk <= 8'b0;
   else       hndshk <= {hndshk[6:2],dfe_start_rc, dfe_start_rc, dfe_start_rc};
   end  // always_ff
   
   assign ctrl_addr =0;
   assign ctrl_writedata =0;
   assign ctrl_write =0;
  //  TEMPORARY Placeholder above - will update later

  endmodule // rcfg_dfe_ctrl
