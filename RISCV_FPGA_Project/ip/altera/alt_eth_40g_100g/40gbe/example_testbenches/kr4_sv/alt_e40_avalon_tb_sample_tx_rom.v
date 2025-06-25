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
// Copyright 2010 Altera Corporation. All rights reserved.  
// Altera products are protected under numerous U.S. and foreign patents, 
// maskwork rights, copyrights and other intellectual property laws.  
//
// This reference design file, and your use thereof, is subject to and governed
// by the terms and conditions of the applicable Altera Reference Design 
// License Agreement (either as signed by you or found at www.altera.com).  By
// using this reference design file, you indicate your acceptance of such terms
// and conditions between you and Altera Corporation.  In the event that you do
// not agree with such terms and conditions, you may not use the reference 
// design file and please promptly destroy any copies you have made.
//
// This reference design file is being provided on an "as-is" basis and as an 
// accommodation and therefore all warranties, representations or guarantees of 
// any kind (whether express, implied or statutory) including, without 
// limitation, warranties of merchantability, non-infringement, or fitness for
// a particular purpose, are specifically disclaimed.  By making this reference
// design file available, Altera expressly does not recommend, suggest or 
// require that this reference design file be used in combination with any 
// other product not provided by Altera.
/////////////////////////////////////////////////////////////////////////////

// baeckler - 03-14-2010

module alt_e40_avalon_tb_sample_tx_rom #(
    parameter WORDS = 2,
    parameter WIDTH = 64,
    parameter DEVICE_FAMILY = "Stratix V"
)(
    input clk, ena,
    input idle,
    
    output reg [WORDS-1:0]       dout_start,
    output reg [WORDS*8-1:0]     dout_endpos,
    output reg [WIDTH*WORDS-1:0] dout   
);

localparam RAM_BLK_TYPE = (DEVICE_FAMILY == "Stratix V") ? "M20K" : "M9K";

wire [2-1:0] dout_start_w;
wire [2*8-1:0] dout_endpos_w;
wire [64*2-1:0] dout_w;	

initial dout_start = 0;
initial dout_endpos = 0;
initial dout = 0;

reg [7:0] addr = 0;

always @(posedge clk) begin
    if (ena) begin
        if (idle && addr == 8'h0) addr <= 0;
        else addr <= addr + 1'b1;
    end
end

// temp solution - widen to 8 lanes
always @(posedge clk) begin
    if (ena) begin
        dout_start  <= {{(WORDS-2){1'b0}},         dout_start_w};
        dout_endpos <= {{(8*(WORDS-2)){1'b0}},     dout_endpos_w};
        dout        <= {{(WIDTH*(WORDS-2)){1'b0}}, dout_w};
    end
end

// some unused surplus bits to make the byte count even
wire [5:0] discard;

altsyncram	altsyncram_component (
			.clocken0 (ena),
			.clock0 (clk),
			.address_a (addr),
			.q_a ({discard,dout_start_w,dout_endpos_w,dout_w}),
			.aclr0 (1'b0),
			.aclr1 (1'b0),
			.address_b (1'b1),
			.addressstall_a (1'b0),
			.addressstall_b (1'b0),
			.byteena_a (1'b1),
			.byteena_b (1'b1),
			.clock1 (1'b1),
			.clocken1 (1'b1),
			.clocken2 (1'b1),
			.clocken3 (1'b1),
			.data_a ({152{1'b1}}),
			.data_b (1'b1),
			.eccstatus (),
			.q_b (),
			.rden_a (1'b1),
			.rden_b (1'b1),
			.wren_a (1'b0),
			.wren_b (1'b0));
defparam
	altsyncram_component.address_aclr_a = "NONE",
	altsyncram_component.clock_enable_input_a = "NORMAL",
	altsyncram_component.clock_enable_output_a = "NORMAL",
	altsyncram_component.init_file = "alt_e40_avalon_tb_sample_tx_rom.hex",
	altsyncram_component.intended_device_family = DEVICE_FAMILY,
	altsyncram_component.lpm_hint = "ENABLE_RUNTIME_MOD=NO",
	altsyncram_component.lpm_type = "altsyncram",
	altsyncram_component.numwords_a = 256,
	altsyncram_component.operation_mode = "ROM",
	altsyncram_component.outdata_aclr_a = "NONE",
	altsyncram_component.outdata_reg_a = "CLOCK0",
	altsyncram_component.ram_block_type = RAM_BLK_TYPE,
	altsyncram_component.widthad_a = 8,
	altsyncram_component.width_a = 152,
	altsyncram_component.width_byteena_a = 1;

endmodule
