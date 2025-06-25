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


// baeckler - 01-30-2010
//
// Read regroup scheduler with FIFO input and output buffers.
// Note that data can enter faster than it can leave.  Mid and
// read clocks should be faster than write, or write traffic
// should be restricted.
//
// dshih may 26, 2011; add arst to DCFIFO

`timescale 1 ps / 1 ps

module alt_ntrlkn_20l_6g_buffered_read_scheduler_8 #(
	parameter VALID_WIDTH = 4,
	parameter RAM_DEPTH = 1024
)(
	input clk_wr,
	input aclr_wr,
	input [VALID_WIDTH-1:0] wr_num_valid,    // max of 100..
	input [VALID_WIDTH-1:0] wr_eop_position, // 1 for MS word, 2,3... 8.   0 for no EOP
	output wr_overflow,

	input clk_mid, // faster if desired, to compact any 0's in the read stream
	input aclr_mid,
	output rd_overflow,

	input clk_rd,
	input aclr_rd,
	output reg [VALID_WIDTH-1:0] rd_num_valid = {VALID_WIDTH{1'b0}}// read max of 100.. when possible, hit SOP boundaries
);

// NOTE: this is not a rigorous mathematical definition of LOG2(v).
// This function computes the number of bits required to represent "v".
// So log2(256) will be  9 rather than 8 (256 = 9'b1_0000_0000).

function integer log2;
  input integer val;
  begin
	 log2 = 0;
	 while (val > 0) begin
	    val = val >> 1;
		log2 = log2 + 1;
	 end
  end
endfunction

/////////////////////////////////////////////////////////
// write side FIFO buffer
/////////////////////////////////////////////////////////

// input registers
reg [VALID_WIDTH-1:0] wr_num_valid_r = {VALID_WIDTH{1'b0}};
reg [VALID_WIDTH-1:0] wr_eop_position_r = {VALID_WIDTH{1'b0}};
always @(posedge clk_wr or posedge aclr_wr) begin
	if (aclr_wr) begin
		wr_num_valid_r <= 0;
		wr_eop_position_r <= 0;
	end
	else begin
		wr_num_valid_r <= wr_num_valid;
		wr_eop_position_r <= wr_eop_position;
	end
end

wire wrfifo_empty, wrfifo_full, wrfifo_ack;
wire [2*VALID_WIDTH-1:0] wrfifo_q;
reg wrfifo_q_valid = 1'b0;
assign wr_overflow = wrfifo_full;
wire wrfifo_rdreq = !wrfifo_empty & (!wrfifo_q_valid | wrfifo_ack);

always @(posedge clk_mid or posedge aclr_mid) begin
	if (aclr_mid) begin
		wrfifo_q_valid <= 1'b0;
	end
	else begin
		if (wrfifo_rdreq) 
			wrfifo_q_valid <= 1'b1;
		else if (wrfifo_ack) 
			wrfifo_q_valid <= 1'b0;
		else
			wrfifo_q_valid <= wrfifo_q_valid;
	end
end

wire [log2(RAM_DEPTH)-2:0] wrfifo_used;

dcfifo	wffo (
			.wrclk (clk_wr),
			.wrreq (|wr_num_valid_r),
			.data ({wr_num_valid_r,wr_eop_position_r}),
			.wrfull (wrfifo_full),

			.rdclk (clk_mid),
			.rdreq (wrfifo_rdreq),
			.rdempty (wrfifo_empty),
			.q (wrfifo_q),

			.aclr (aclr_wr),
			.rdfull (),
			.rdusedw (wrfifo_used),
			.wrempty (),
			.wrusedw ()
);
defparam
	wffo.intended_device_family = "Stratix IV",
	wffo.lpm_hint = "RAM_BLOCK_TYPE=M9K",
	wffo.lpm_numwords = RAM_DEPTH,
	wffo.lpm_showahead = "OFF",
	wffo.lpm_type = "dcfifo",
	wffo.lpm_width = 2*VALID_WIDTH,
	wffo.lpm_widthu = log2(RAM_DEPTH)-1,
	wffo.overflow_checking = "ON",
	wffo.rdsync_delaypipe = 5,
	wffo.underflow_checking = "ON",
	wffo.use_eab = "ON",
	wffo.write_aclr_synch = "ON",
	wffo.wrsync_delaypipe = 5;

wire [VALID_WIDTH-1:0] buf_num_valid, buf_eop_position;
assign {buf_num_valid,buf_eop_position} = wrfifo_q & {(2*VALID_WIDTH){wrfifo_q_valid}};

/////////////////////////////////////////////////////////
// regrouper
/////////////////////////////////////////////////////////

wire [VALID_WIDTH-1:0] sched_num_valid;
wire sched_wait;
assign wrfifo_ack = ~sched_wait;

alt_ntrlkn_20l_6g_read_scheduler_8 rs (
	.clk(clk_mid),
	.arst(aclr_mid),
	.wr_wait(sched_wait),
	.wr_num_valid(buf_num_valid),
	.wr_eop_position(buf_eop_position), // 1 for MS word, 2,3... 8.   0 for no EOP

	.rd_num_valid(sched_num_valid)
);
defparam rs .VALID_WIDTH = VALID_WIDTH;

/////////////////////////////////////////////////////////
// read side FIFO buffer
/////////////////////////////////////////////////////////

wire rdfifo_empty, rdfifo_full;
wire [VALID_WIDTH-1:0] rdfifo_q;
reg rdfifo_q_valid = 1'b0;
assign rd_overflow = rdfifo_full;

always @(posedge clk_rd or posedge aclr_rd) begin
	if (aclr_rd) begin
		rdfifo_q_valid <= 1'b0;
	end
	else begin
		rdfifo_q_valid <= !rdfifo_empty;
	end
end

wire [log2(RAM_DEPTH)-2:0] rdfifo_used;

dcfifo	rffo (
			.wrclk (clk_mid),
			.wrreq (|sched_num_valid),
			.data (sched_num_valid),
			.wrfull (rdfifo_full),

			.rdclk (clk_rd),
			.rdreq (!rdfifo_empty),
			.rdempty (rdfifo_empty),
			.q (rdfifo_q),

			.aclr (aclr_mid),
			.rdfull (),
			.rdusedw (rdfifo_used),
			.wrempty (),
			.wrusedw ()
);
defparam
	rffo.intended_device_family = "Stratix IV",
	rffo.lpm_hint = "RAM_BLOCK_TYPE=M9K",
	rffo.lpm_numwords = RAM_DEPTH,
	rffo.lpm_showahead = "OFF",
	rffo.lpm_type = "dcfifo",
	rffo.lpm_width = VALID_WIDTH,
	rffo.lpm_widthu = log2(RAM_DEPTH)-1,
	rffo.overflow_checking = "ON",
	rffo.rdsync_delaypipe = 5,
	rffo.underflow_checking = "ON",
	rffo.use_eab = "ON",
	rffo.write_aclr_synch = "ON",
	rffo.wrsync_delaypipe = 5;

//reg rd_num_valid = 1'b0;
always @(posedge clk_rd or posedge aclr_rd) begin
	if (aclr_rd) 
		rd_num_valid <= 0;
	else 
		rd_num_valid <= {VALID_WIDTH{rdfifo_q_valid}} & rdfifo_q;
end

endmodule
