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


// baeckler - 01-31-2010
// buffer inbound SOP/EOP annotated data
// and regroup so that SOP appears in the first word

`timescale 1 ps / 1 ps

module alt_e100_wide_regroup_8 #(
	parameter WORD_WIDTH = 64,
	parameter ADDR_WIDTH = 11,
	parameter NUM_WORDS = 8, // do not override
	parameter DEVICE_FAMILY = "Stratix V"
)(	
	input clk, arst,
	input [3:0] din_num_valid,  // 0..8 valid, grouped toward left
	input [NUM_WORDS-1:0] din_sop,		// per input word
	input [4*NUM_WORDS-1:0] din_eopbits, // per input word	
	input [NUM_WORDS*WORD_WIDTH-1:0] din,  
		
	output reg [3:0] dout_num_valid, // 0..8 valid, grouped toward left
	output reg dout_sop,			// referring to the first valid word	
	output reg [3:0] dout_eopbits,	// referring to the last valid word
	output reg [NUM_WORDS*WORD_WIDTH-1:0] dout,
	output reg overflow	
);

// synthesis translate off
genvar j;
generate
for (j=0; j<NUM_WORDS*WORD_WIDTH; j=j+1) begin : chk 
	always @(posedge clk) begin
		if (din_num_valid != 0 && din[j] === 1'bx) begin
			$display ("Warning : Garbage data entering regrouper at time %d",$time);
		end
	end
end
endgenerate
// synthesis translate on

/////////////////////////////////////////////////
// write pointer
/////////////////////////////////////////////////

reg [ADDR_WIDTH-1:0] wraddr;
always @(posedge clk or posedge arst) begin
	if (arst) wraddr <= 0;
	else wraddr <= wraddr + din_num_valid;
end

/////////////////////////////////////////////////
// figure out SOP addresses
/////////////////////////////////////////////////

reg [3:0] sop_ofs, din_num_valid_r;

// SOP will occur 1 word after EOP
//  check EOP rather than SOP to facilitate flushing
always @(posedge clk or posedge arst) begin
	if (arst) begin
		sop_ofs <= 0;
		din_num_valid_r <= 0;		
	end
	else begin
		if (din_eopbits[7*4+3] | din_eopbits[7*4+0]) sop_ofs <= 4'd1;
		else if (din_eopbits[6*4+3] | din_eopbits[6*4+0]) sop_ofs <= 4'd2;
		else if (din_eopbits[5*4+3] | din_eopbits[5*4+0]) sop_ofs <= 4'd3;
		else if (din_eopbits[4*4+3] | din_eopbits[4*4+0]) sop_ofs <= 4'd4;
		else if (din_eopbits[3*4+3] | din_eopbits[3*4+0]) sop_ofs <= 4'd5;
		else if (din_eopbits[2*4+3] | din_eopbits[2*4+0]) sop_ofs <= 4'd6;
		else if (din_eopbits[1*4+3] | din_eopbits[1*4+0]) sop_ofs <= 4'd7;
		else if (din_eopbits[0*4+3] | din_eopbits[0*4+0]) sop_ofs <= 4'd8;
		else sop_ofs <= 3'd0;
								
		din_num_valid_r <= din_num_valid;
	end 
end

/////////////////////////////////////////////////
// Use the write info to build max width
// read schedule
/////////////////////////////////////////////////

wire brs_wr_overflow, brs_rd_overflow;
wire [3:0] rd_num_valid;

alt_e100_wide_buffered_read_scheduler brs 
(
	.clk_wr(clk),
	.aclr_wr(arst),
	.wr_num_valid(din_num_valid_r),    // max of 100..
	.wr_eop_position(sop_ofs), // 1 for MS word, 2,3... 8.   0 for no EOP
	.wr_overflow(brs_wr_overflow),
	
	.clk_mid(clk), // faster if desired, to compact any 0's in the read stream
	.aclr_mid(arst),
	.rd_overflow(brs_rd_overflow),
	
	.clk_rd(clk),
	.aclr_rd(arst),
	.rd_num_valid(rd_num_valid) // read max of 100.. when possible, hit SOP boundaries
);
defparam brs .VALID_WIDTH = 4;
defparam brs .DEVICE_FAMILY = DEVICE_FAMILY;
   
/////////////////////////////////////////////////
// manage the read address
/////////////////////////////////////////////////

reg [ADDR_WIDTH-1:0] rdaddr = 0;

reg [ADDR_WIDTH-1:0] holding;
always @(posedge clk or posedge arst) begin
	if (arst) holding <= 0;
	else holding <= wraddr - rdaddr;
end

// synthesis translate off
always @(posedge clk) begin
	if (holding[ADDR_WIDTH-1]) begin
		$display ("Warning : regroup holding count is impossibly high");
	end	
end
// synthesis translate on
		
// update the read address
reg rdena = 1'b0;
always @(posedge clk or posedge arst) begin
	if (arst) begin		
		rdaddr <= 0;
		rdena <= 1'b0;
	end
	else begin
		rdena <= |rd_num_valid;
		rdaddr <= rdaddr + rd_num_valid;		
	end
end

/////////////////////////////////////////////////
// pick out valid reads
/////////////////////////////////////////////////
reg [7:0] rdena_delay;

always @(posedge clk or posedge arst) begin
	if (arst) begin		
		rdena_delay <= 0;		
	end
	else begin
		rdena_delay <= {rdena_delay[6:0],rdena};
	end
end

/////////////////////////////////////////////////
// word addressable storage
/////////////////////////////////////////////////
localparam EXT_WORD_WIDTH = WORD_WIDTH + 4 + 1;
wire [EXT_WORD_WIDTH * NUM_WORDS-1:0] ext_din, ext_dout;

// embed SOP/EOP in data words
genvar i;
generate
for (i=0; i<NUM_WORDS; i=i+1) begin : pack_din
	assign ext_din[(i+1)*EXT_WORD_WIDTH-1:i*EXT_WORD_WIDTH] =
			{din_sop[i],	
			din_eopbits[(i+1)*4-1:i*4],	
			din[(i+1)*WORD_WIDTH-1:i*WORD_WIDTH]};
end	
endgenerate

alt_e100_wide_wide_word_ram_8 mem 
(
	.clk(clk),
	.arst(arst),
	.din(ext_din),
	.wr_addr(wraddr),		// addressing is in words
	.we(1'b1),
	.dout(ext_dout),
	.rd_addr(rdaddr)
);
defparam mem .WORD_WIDTH = EXT_WORD_WIDTH;
defparam mem .NUM_WORDS = 8;  // barrel shifter mod required to override
defparam mem .ADDR_WIDTH = ADDR_WIDTH;
defparam mem .DEVICE_FAMILY = DEVICE_FAMILY;

// separate SOP/EOP from readback data words
wire [NUM_WORDS-1:0] rd_sop;	
wire [NUM_WORDS-1:0] rd_eopbits3,rd_eopbits2,rd_eopbits1,rd_eopbits0;
wire [NUM_WORDS*WORD_WIDTH-1:0] rd_dout;
generate
for (i=0; i<NUM_WORDS; i=i+1) begin : unpack
		assign {rd_sop[i],
				rd_eopbits3[i],
				rd_eopbits2[i],
				rd_eopbits1[i],
				rd_eopbits0[i],
				rd_dout[(i+1)*WORD_WIDTH-1:i*WORD_WIDTH]} =
					ext_dout[(i+1)*EXT_WORD_WIDTH-1:i*EXT_WORD_WIDTH];
end	
endgenerate

always @(posedge clk or posedge arst) begin
	if (arst) begin		
		dout_sop <= 0;	
		dout <= 0;
		dout_eopbits <= 0;
		dout_num_valid <= 4'h0;								
	end
	else begin
		dout_sop <= rd_sop[NUM_WORDS-1];	
		dout <= rd_dout;
		
		if (rdena_delay[5]) begin
			if (rd_eopbits3[7] | rd_eopbits0[7]) begin
				dout_num_valid <= 4'h1;
				dout_eopbits <= {rd_eopbits3[7],rd_eopbits2[7],rd_eopbits1[7],rd_eopbits0[7]};
			end
			else if (rd_eopbits3[6] | rd_eopbits0[6]) begin
				dout_num_valid <= 4'h2;
				dout_eopbits <= {rd_eopbits3[6],rd_eopbits2[6],rd_eopbits1[6],rd_eopbits0[6]};
			end
			else if (rd_eopbits3[5] | rd_eopbits0[5]) begin
				dout_num_valid <= 4'h3;
				dout_eopbits <= {rd_eopbits3[5],rd_eopbits2[5],rd_eopbits1[5],rd_eopbits0[5]};
			end
			else if (rd_eopbits3[4] | rd_eopbits0[4]) begin
				dout_num_valid <= 4'h4;
				dout_eopbits <= {rd_eopbits3[4],rd_eopbits2[4],rd_eopbits1[4],rd_eopbits0[4]};
			end
			else if (rd_eopbits3[3] | rd_eopbits0[3]) begin
				dout_num_valid <= 4'h5;
				dout_eopbits <= {rd_eopbits3[3],rd_eopbits2[3],rd_eopbits1[3],rd_eopbits0[3]};
			end
			else if (rd_eopbits3[2] | rd_eopbits0[2]) begin
				dout_num_valid <= 4'h6;
				dout_eopbits <= {rd_eopbits3[2],rd_eopbits2[2],rd_eopbits1[2],rd_eopbits0[2]};
			end
			else if (rd_eopbits3[1] | rd_eopbits0[1]) begin
				dout_num_valid <= 4'h7;
				dout_eopbits <= {rd_eopbits3[1],rd_eopbits2[1],rd_eopbits1[1],rd_eopbits0[1]};
			end
			else begin
				dout_num_valid <= 4'h8;								
				dout_eopbits <= {rd_eopbits3[0],rd_eopbits2[0],rd_eopbits1[0],rd_eopbits0[0]};
			end
		end
		else begin
			dout <= 0;
			dout_sop <= 0;
			dout_eopbits <= 0;
			dout_num_valid <= 0;
		end
	end
end

initial overflow = 1'b0;
always @(posedge clk or posedge arst) begin
	if (arst) overflow <= 1'b0;
	else overflow <= brs_wr_overflow | brs_rd_overflow | (holding[ADDR_WIDTH-1]);
end

endmodule