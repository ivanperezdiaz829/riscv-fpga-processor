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

// baeckler - 06-09-2010

module alt_e40_avalon_tb_packet_gen #(
	parameter WORDS = 4,
	parameter WIDTH = 64,
	parameter MORE_SPACING = 1'b1,
	parameter CNTR_PAYLOAD = 1'b0
)(
	input clk,
	input ena,
	input idle,
		
	output [WORDS-1:0] sop,
	output [WORDS*8-1:0] eop,
	output [WORDS*WIDTH-1:0] dout,
	
	output reg [WORDS*16-1:0] sernum
);

/////////////////////////////////////////////////
// build some semi reasonable random bits

reg [31:0] cntr = 0;
always @(posedge clk) begin
	if (ena) cntr <= cntr + 1'b1;
end

wire [31:0] poly0 = 32'h8000_0241;
reg [31:0] prand0 = 32'hffff_ffff;
always @(posedge clk) begin
	prand0 <= {prand0[30:0],1'b0} ^ ((prand0[31] ^ cntr[31]) ? poly0 : 32'h0);
end

wire [31:0] poly1 = 32'h8deadfb3;
reg [31:0] prand1 = 32'hffff_ffff;
always @(posedge clk) begin
	prand1 <= {prand1[30:0],1'b0} ^ ((prand1[31] ^ cntr[30]) ? poly1 : 32'h0);
end

reg [15:0] prand2 = 0;
always @(posedge clk) begin
	prand2 <= cntr[23:8] ^ prand0[15:0] ^ prand1[15:0];
end

// mostly 1
reg prand3 = 1'b0;
always @(posedge clk) begin
	prand3 <= |(prand0[17:16] ^ prand1[17:16] ^ cntr[25:24]);
end

/////////////////////////////////////////////////
// random sop and eop suggestions

reg [WORDS-1:0] sop0 = 0;
reg [WORDS*8-1:0] eop0 = 0;
reg [WORDS-1:0] nix0 = 0;

wire [WORDS-1:0] sop_prelim = (prand2[0] & prand2[11]) ? 4'h8 : 4'h0;
reg sop_ok;

always @(*) begin
	case (sop_prelim)
		4'h8 : sop_ok = 1;
	default  : sop_ok = 0;
	endcase	
end

always @(posedge clk) begin
	sop0 <= idle ? {WORDS{1'b0}} : (sop_ok ? sop_prelim : {WORDS{1'b0}});
	eop0 <= (eop0 << 8);
	eop0 [prand2[7:5]] <= 1'b1;	
	nix0 <= (nix0 << 3) | prand2[10:8];
end

/////////////////////////////////////////////////
// make the SOP / EOP more sparse

reg [WORDS-1:0] sop1 = 0;
reg [WORDS*8-1:0] eop1 = 0;

wire [WORDS-1:0] eop_blackout = prand3 ? {WORDS{1'b1}} : (sop0 | nix0);
wire [WORDS*8-1:0] exp_eop_blackout;
wire [WORDS-1:0] any_eop1_w;
reg [WORDS-1:0] any_eop1 = 0;

genvar i;
generate 
	for (i=0; i<WORDS; i=i+1) begin : bo
		assign exp_eop_blackout[(i+1)*8-1:i*8] = {8{eop_blackout[i]}};
		assign any_eop1_w[i] = |eop0[(i+1)*8-1:i*8];
	end
endgenerate

always @(posedge clk) begin
	if (ena) begin
		sop1 <= (MORE_SPACING && (|sop1)) ? {WORDS{1'b0}} : sop0 & ~nix0;
		eop1 <= eop0 & ~exp_eop_blackout;		
		any_eop1 <= any_eop1_w & ~eop_blackout;
	end
end

/////////////////////////////////////////////////
// fixup the start/stop alternating pattern

wire [WORDS+1-1:0] pending;
reg [WORDS-1:0] pending_r = 0;
reg [WORDS-1:0] sop2 = 0;
reg [WORDS*8-1:0] eop2 = 0;

reg pending_wrap = 0;
generate 
	for (i=0; i<WORDS; i=i+1) begin : pd
		assign pending[i] = pending[i+1] ? ~any_eop1[i] : sop1[i];
	end
endgenerate

assign pending[WORDS] = pending_wrap;
always @(posedge clk) begin
	if (ena) begin
		pending_wrap <= pending[0];
		pending_r <= pending[WORDS-1:0];
		sop2 <= sop1;
		eop2 <= eop1;
	end
end

reg [WORDS-1:0] sop3 = 0;
reg [WORDS*8-1:0] eop3 = 0;
reg prev_0 = 1'b0;
wire [WORDS-1:0] prev_pending = {prev_0,pending_r[WORDS-1:1]};
wire [WORDS*8-1:0] exp_prev_pending;

generate 
	for (i=0; i<WORDS; i=i+1) begin : pp
		assign exp_prev_pending[(i+1)*8-1:i*8] = {8{prev_pending[i]}};
	end
endgenerate

always @(posedge clk) begin
	if (ena) begin
		prev_0 <= pending_r[0];
		sop3 <= sop2 & ~prev_pending;
		eop3 <= eop2 & exp_prev_pending;
	end
end

/////////////////////////////////////////////////
// figure out the payload
// First word is 6 byte dest address, choice of 5, then 2 byte serial number
// for that address.   Last word is fixed.  Middle is random junk.

reg [WORDS-1:0] sop4 = 0;
reg [WORDS*8-1:0] eop4 = 0;

always @(posedge clk) begin
	if (ena) begin
		sop4 <= sop3;
		eop4 <= eop3;
	end
end

reg [WIDTH-1:0] rjunk = 0;
always @(posedge clk) begin
	rjunk <= (rjunk << 4'hf) ^ prand2;
end

//reg [WIDTH-1:0] pcntr = 0;	// LEDA
reg [WIDTH-1:0] pcntr[WORDS-1:0];	// LEDA
generate
	for (i=0; i<WORDS; i=i+1) begin : pcntr_init // LEDA
		initial pcntr[i] = 0;	// LEDA
	end	// LEDA
endgenerate	// LEDA

reg [WORDS*WIDTH-1:0] dout4 = 0;
initial sernum = 0;

// set of mac addresses to scatter through
wire [WORDS*6*8-1:0] mac_dest = {
	48'h0007ed_ff1234,
	48'hffffff_ffffff,
	48'h0007ed_ff0000,
	48'h123456_ff1234, 
	48'h00215a_bdde43	
};

generate 
	for (i=0; i<WORDS; i=i+1) begin : sy
		always @(posedge clk) begin
			if (ena) begin
				if (sop3[i]) begin
					dout4[(i+1)*WIDTH-1:i*WIDTH] <= {
						mac_dest[(i+1)*8*6-1:i*8*6],
						sernum[(i+1)*16-1:i*16]
					};						
					sernum[(i+1)*16-1:i*16] <= sernum[(i+1)*16-1:i*16] + 1'b1;					
				end
				else if (|eop3[(i+1)*8-1:i*8]) begin
					dout4[(i+1)*WIDTH-1:i*WIDTH] <= "caboose.";
				end
				else begin
					if (CNTR_PAYLOAD) begin
						dout4[(i+1)*WIDTH-1:i*WIDTH] <= pcntr[i];
						pcntr[i] <= pcntr[i]+1'b1;
					end	
					else begin
						dout4[(i+1)*WIDTH-1:i*WIDTH] <= rjunk;
					end					
				end								
			end
		end				
	end
endgenerate

assign sop = sop4;
assign eop = eop4;
assign dout = dout4;

endmodule
