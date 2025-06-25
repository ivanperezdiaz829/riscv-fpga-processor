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


module altpcied_tgt_mux

#(
   parameter AVALON_WADDR          = 20,  // Claim 2MB of memory space per function 
   parameter CB_RXM_DATA_WIDTH     = 32
)
  ( 
   // clock, reset inputs
   input          Clk_i,
   input          Rstn_i,
   
   // Input from target
   input                                tgt_RxmWaitRequest_0_i,
   input  [CB_RXM_DATA_WIDTH-1:0]       tgt_RxmReadData_0_i,          
   input                                tgt_RxmReadDataValid_0_i,     

   // Input from mailbox registers
   input                                mbox_RxmWaitRequest_0_i,
   input  [CB_RXM_DATA_WIDTH-1:0]       mbox_RxmReadData_0_i,          
   input                                mbox_RxmReadDataValid_0_i,     
   
   output                                RxmWaitRequest_0_o,
   output  [CB_RXM_DATA_WIDTH-1:0]       RxmReadData_0_o,          
   output                                RxmReadDataValid_0_o,     

   // Selector from the controller
   input                                mbox_sel_i            // Select mailbox registers
  );


//=========================
// Read data 
//=========================
  assign RxmWaitRequest_0_o     = mbox_sel_i ? mbox_RxmWaitRequest_0_i   : tgt_RxmWaitRequest_0_i;
  assign RxmReadData_0_o        = mbox_sel_i ? mbox_RxmReadData_0_i      : tgt_RxmReadData_0_i;
  assign RxmReadDataValid_0_o   = mbox_sel_i ? mbox_RxmReadDataValid_0_i : tgt_RxmReadDataValid_0_i;

endmodule
