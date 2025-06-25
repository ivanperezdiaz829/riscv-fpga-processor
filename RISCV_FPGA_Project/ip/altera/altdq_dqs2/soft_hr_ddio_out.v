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

module soft_hr_ddio_out (datainhi, datainlo, clk, dataout);
	input datainhi;
	input datainlo;
	input clk;
	output dataout;

	wire datainhi;
	wire datainlo;
	wire clk;
	wire dataout;
	
	reg datainhi_r;
	reg datainhi_rr;
	reg datainlo_r;
	
	always @(posedge clk)
	begin
		datainhi_r <= datainhi;
		datainlo_r <= datainlo;
	end
	
	always @(negedge clk)
		datainhi_rr <= datainhi_r;
	
	assign dataout = (clk ? datainhi_rr : datainlo_r);
endmodule

