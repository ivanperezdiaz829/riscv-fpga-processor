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


//Description: takes in command and response packets (from the tap component)
//and digests to Avalon MM format.
//
//This version of the xlate does not use the ID fields, and is agnostic
//regarding master-side/slave-side connection.
//
module altera_throughput_tap_xlate #(
   parameter
   ST_DATA_W        = 100,

   PKT_BYTE_CNT_H = 86,      //only care about burstcount, read, write in cmd pkt
   PKT_BYTE_CNT_L = 84,

   PKT_TRANS_WRITE  = 39,  
   PKT_TRANS_READ   = 38,

   // Derived parameters
   BURSTCOUNT_LSB   = 84,
   BC_W             = 3
   ) 
   (
   //clock & reset not actually used, but incluced so tcl can use them as 
   //associated clock & reset
   input                       if_clock, 
   input                       if_reset,

//command packet input
   input                       cp_valid,
   input   [ST_DATA_W -1:0]    cp_data,
   input                       cp_ready,

//response packet input
   input                       rp_valid,

//digested Av MM format outputs
   output                      if_read,
   output                      if_write,
   output      [BC_W-1:0]      if_burstcount,
   output                      if_waitrequest,
   output                      if_readdatavalid 
   );

assign if_read        = (cp_valid) ? cp_data[PKT_TRANS_READ]  : 1'b0;
assign if_write       = (cp_valid) ? cp_data[PKT_TRANS_WRITE] : 1'b0;
assign if_burstcount  = (cp_valid) ? cp_data[PKT_BYTE_CNT_H : BURSTCOUNT_LSB] : {BC_W{1'b0}};



assign if_waitrequest = !cp_ready;
assign if_readdatavalid = rp_valid;

endmodule
   
