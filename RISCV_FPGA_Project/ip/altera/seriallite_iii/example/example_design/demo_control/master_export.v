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


// master_export.v


`timescale 1 ps / 1 ps
module master_export #(
		parameter address_width         = 9,
		parameter data_width            = 32,
		parameter AUTO_CLOCK_CLOCK_RATE = "-1"
	) (
		input  wire        clk,             //  clock.clk
		input  wire        reset,           //  reset.reset
		output wire [8:0]  avm_address,     // master.address
		output wire        avm_read,        //       .read
		input  wire        avm_waitrequest, //       .waitrequest
		input  wire [31:0] avm_readdata,    //       .readdata
		output wire        avm_write,       //       .write
		output wire [31:0] avm_writedata,   //       .writedata
		input  wire [8:0]  avs_address,     //  slave.address
		input  wire        avs_read,        //       .read
		output wire [31:0] avs_readdata,    //       .readdata
		input  wire        avs_write,       //       .write
		output wire        avs_waitrequest, //       .waitrequest
		input  wire [31:0] avs_writedata    //       .writedata
	);


	assign avm_writedata = avs_writedata;

	assign avm_address = avs_address;

	assign avm_write = avs_write;

	assign avm_read = avs_read;

	assign avs_waitrequest = avm_waitrequest;

	assign avs_readdata = avm_readdata;

endmodule
