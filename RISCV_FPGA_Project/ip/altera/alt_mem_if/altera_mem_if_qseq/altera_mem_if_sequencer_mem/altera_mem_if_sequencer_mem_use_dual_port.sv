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

// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 

module altera_mem_if_sequencer_mem_use_dual_port (
	clk1,
	reset1,
	clken1,
	s1_address,
	s1_be,
	s1_chipselect,
	s1_write,
	s1_writedata,
	s1_readdata
	,
	clk2,
	reset2,
	s2_address,
	s2_be,
	s2_chipselect,
	s2_clken,
	s2_write,
	s2_writedata,
	s2_readdata
);

parameter AVL_ADDR_WIDTH = 0;
parameter AVL_DATA_WIDTH = 0;
parameter AVL_SYMBOL_WIDTH = 0;
parameter AVL_NUM_SYMBOLS = 0;
parameter MEM_SIZE = 0;
parameter INIT_FILE = "";
parameter RAM_BLOCK_TYPE = "";

localparam NUM_WORDS = MEM_SIZE / AVL_NUM_SYMBOLS;

input                            clk1;
input                            reset1;
input                            clken1;
input   [AVL_ADDR_WIDTH - 1:0]   s1_address;
input   [AVL_NUM_SYMBOLS - 1:0]  s1_be;
input                            s1_chipselect;
input                            s1_write;
input   [AVL_DATA_WIDTH - 1:0]   s1_writedata;
output  [AVL_DATA_WIDTH - 1:0]   s1_readdata;
input                            clk2;
input                            reset2;
input   [AVL_ADDR_WIDTH - 1:0]   s2_address;
input   [AVL_NUM_SYMBOLS - 1:0]  s2_be;
input                            s2_chipselect;
input                            s2_clken;
input                            s2_write;
input   [AVL_DATA_WIDTH - 1:0]   s2_writedata;
output  [AVL_DATA_WIDTH - 1:0]   s2_readdata;

wire             wren;
assign wren = s1_chipselect & s1_write;
wire             wren2;
assign wren2 = s2_chipselect & s2_write;

	altsyncram the_altsyncram
	(
		.address_a (s1_address),
		.byteena_a (s1_be),
		.clock0 (clk1),
		.clocken0 (clken1),
		.data_a (s1_writedata),
		.q_a (s1_readdata),
		.wren_a (wren),
		.rden_a(),
		.rden_b(),
		.clocken2(),
		.clocken3(),
		.aclr0(),
		.aclr1(),
		.addressstall_a(),
		.addressstall_b(),
		.eccstatus(),
		.address_b (s2_address),
		.byteena_b (s2_be),
		.clock1 (clk2),
		.clocken1 (s2_clken),
		.data_b (s2_writedata),
		.q_b (s2_readdata),
		.wren_b (wren2)
	);
	defparam the_altsyncram.byte_size = AVL_SYMBOL_WIDTH;
	defparam the_altsyncram.lpm_type = "altsyncram";
	defparam the_altsyncram.maximum_depth = NUM_WORDS;
	defparam the_altsyncram.numwords_a = NUM_WORDS;
	defparam the_altsyncram.outdata_reg_a = "UNREGISTERED";
	defparam the_altsyncram.ram_block_type = RAM_BLOCK_TYPE;
	defparam the_altsyncram.read_during_write_mode_mixed_ports = "DONT_CARE";
	defparam the_altsyncram.width_a = AVL_DATA_WIDTH;
	defparam the_altsyncram.width_byteena_a = AVL_NUM_SYMBOLS;
	defparam the_altsyncram.widthad_a = AVL_ADDR_WIDTH;
	defparam the_altsyncram.address_reg_b = "CLOCK1";
	defparam the_altsyncram.byteena_reg_b = "CLOCK1";
	defparam the_altsyncram.indata_reg_b = "CLOCK1";
	defparam the_altsyncram.wrcontrol_wraddress_reg_b = "CLOCK1";
	defparam the_altsyncram.init_file = "UNUSED";
	defparam the_altsyncram.numwords_b = NUM_WORDS;
	defparam the_altsyncram.outdata_reg_b = "UNREGISTERED";
	defparam the_altsyncram.width_b = AVL_DATA_WIDTH;
	defparam the_altsyncram.width_byteena_b = AVL_NUM_SYMBOLS;
	defparam the_altsyncram.widthad_b = AVL_ADDR_WIDTH;
	defparam the_altsyncram.operation_mode = "BIDIR_DUAL_PORT";


endmodule

