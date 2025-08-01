// (C) 2001-2011 Altera Corporation. All rights reserved.
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


// Common Read Modify Write module for Analog reconfig
//
// $Header$

`timescale 1 ns / 1 ps
module alt_xreconf_analog_rmw 
#(
  parameter   DATA_WIDTH=32		
  ) (
    input wire clk,
    input wire reset,
    input wire pretap_f,
    input wire posttap2_f,
    input wire pretap_inv,
    input wire posttap2_inv,
    input wire eqctrl_f,
    input wire [4:0] offset,
    input wire [4:0] length,
    input wire 	     waitrequest_from_base,
    input wire [2:0] uif_mode,
    input wire [DATA_WIDTH-1:0] writedata, 
    input wire [DATA_WIDTH-1:0] readdata,
    output reg [DATA_WIDTH-1:0] outdata
     );
   
   reg [31:0] 			mask_wd_reg = 32'h00000000;
   reg [31:0] 			mask_wd_reg_2 = 32'h00000000;
   wire [31:0] 			shifted_mask_wd;
   wire [31:0] 			shifted_mask_wd2;
   wire [31:0] 			inv_shifted_mask_wd2;
   wire [31:0] 			wd_and_rd;
   wire [31:0] 			result_data;
   reg [31:0] 			final_data = 32'h00000000;   
   
   
   integer 	      i;

   // mask write data
   // decode length, if i < = length then mask that bit and put it as it is
   // if i >= length then write 0 to those bits
   // e.g. say length is 6 bits then writedata[5:0] = 6'b101101
   // mask_wd_reg = 16'b0, 6'6'b101101
   
   always @(*)
     begin
	for (i = 0; i< 32; i=i+1)
	  begin
	     if (i>=length)  // 
	       begin
		  mask_wd_reg[i] = writedata[i] & 1'b0;
		  mask_wd_reg_2[i] = writedata[i] & 1'b0;
	       end
	     else
	       begin
		  mask_wd_reg[i] = writedata[i] & 1'b1;
		  mask_wd_reg_2[i] = 1'b1;
	       end
	  end
     end // always @ (*)

   // shift the masked bits with offset 2 times
   assign shifted_mask_wd = mask_wd_reg << offset;
   assign shifted_mask_wd2 = mask_wd_reg_2 << offset;

   // Assemble the result_data based on masked writedata and readdata (from basic)
   //   assign inv_shifted_mask_wd = ~shifted_mask_wd;
   assign inv_shifted_mask_wd2 = ~shifted_mask_wd2;   
   assign wd_and_rd = readdata & inv_shifted_mask_wd2;
   assign result_data = wd_and_rd | shifted_mask_wd;

   // pretap_inv offset is 1
   // posttap_inv offset is 0
   // if pretap then need to insert pretap_inv bit at bit[1] position
   // if posttap2 then need to insert posttap2_inv bit at bit[0] position    

   always @(*)
     begin
	// assign pretap_inv value to proper place in case of pretap
	if (pretap_f)
	  final_data = {result_data[31:2], pretap_inv, result_data[0]};
	// assign posttap2_inv value to proper place in case of posttap2	
	else if (posttap2_f)
	  final_data = {result_data[31:1], posttap2_inv};
	// If eqctrl_f then don't need to do shifting and all as all except bit 0, all are assigned it to
	// eqa, eqb, eqc, eqd and eqf directly from ch_reg_18
	else if (eqctrl_f)
	  begin
	     final_data[0] = readdata[0];
	     final_data[15:1] = writedata[15:1];
	     final_data[31:16] = readdata[31:16];
	  end
	else
	  final_data = result_data;
     end
   
	  
       
// Assemble writedata till reconfig basic gives back the readata
   always @(posedge clk or posedge reset)
     begin
	if (reset)
	  begin
	     outdata <= 32'h00000000;
	  end
	else
	  begin
	     if (!waitrequest_from_base & uif_mode == 3'b001)
	       outdata <= final_data;
	  end
     end // always (posedge clk or posedge reset)
   
endmodule // top_data



