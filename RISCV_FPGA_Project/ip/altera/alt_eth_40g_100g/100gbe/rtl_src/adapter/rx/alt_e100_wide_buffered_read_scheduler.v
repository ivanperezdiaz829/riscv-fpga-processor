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


// baeckler - 06-01-2011
//
// The read_scheduler accumulate wr_num_valid and write to buffer 16 word at a time. 
// Each EOP will be written to buffer which has 1 to (15+8) word. On the buffer
// read side, it tick out 8 word at a time. For regular 16 word, it takes 2 ticks. 
// For EOP, it takes 1~3 ticks. For minimum 64 byte back to back, it will take 1 tick
// For each cycles.

`timescale 1 ps / 1 ps

module alt_e100_wide_buffered_read_scheduler #(
	parameter VALID_WIDTH = 4,
	parameter RAM_DEPTH = 1024,
	parameter DEVICE_FAMILY = "Stratix V"
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
	output reg [VALID_WIDTH-1:0] rd_num_valid // read max of 100.. when possible, hit SOP boundaries
);

localparam RAM_BLK_TYPE = (DEVICE_FAMILY == "Stratix V" || DEVICE_FAMILY == "Arria V GZ" || DEVICE_FAMILY == "Arria 10") ? "RAM_BLOCK_TYPE=M20K"
                            : ((DEVICE_FAMILY == "Stratix IV") ? "RAM_BLOCK_TYPE=M9K" : "UNKNOWN");
// State Machine States:
localparam IDLE = 2'b00,
          TICK1 = 2'b01,
          TICK2 = 2'b10,
          TICK3 = 2'b11;
/////////////////////////////////////////////////////////
// write side FIFO buffer
/////////////////////////////////////////////////////////

// helper function to compute LOG base 2
//
// NOTE - This is a somewhat abusive definition of LOG2(v) as the
//   number of bits required to represent "v".  So alt_log2(256) will be
//   9 rather than 8 (256 = 9'b1_0000_0000).  I apologize for any
//   confusion this may cause.
//

function integer alt_log2;
  input integer val;
  begin
	 alt_log2 = 0;
	 while (val > 0) begin
	    val = val >> 1;
		alt_log2 = alt_log2 + 1;
	 end
  end
endfunction

// input registers
reg [VALID_WIDTH-1:0] wr_num_valid_r = 0;
reg [VALID_WIDTH-1:0] wr_eop_position_r = 0;
reg [VALID_WIDTH-1:0] wr_eop_position_r2 = 0;
reg [VALID_WIDTH:0]   eop_cnt = 0;
reg [VALID_WIDTH:0]   accum_cnt =0;

always @(posedge clk_wr or posedge aclr_wr) begin
	if (aclr_wr) begin
		wr_num_valid_r     <= 0;
		wr_eop_position_r  <= 0;
		wr_eop_position_r2 <= 0;
      eop_cnt            <= 0;
      accum_cnt          <= 0;
	end
	else begin
		wr_num_valid_r     <= wr_num_valid;
		wr_eop_position_r  <= wr_eop_position;	
		wr_eop_position_r2 <= wr_eop_position_r;	
      eop_cnt            <= (|wr_eop_position_r) ? accum_cnt[VALID_WIDTH-1:0] + wr_eop_position_r : { (VALID_WIDTH+1) {1'b0} };
      accum_cnt          <= (|wr_eop_position_r) ? wr_num_valid_r - wr_eop_position_r : accum_cnt[VALID_WIDTH-1:0] + wr_num_valid_r;
	end
end


wire [VALID_WIDTH:0]  chunk_wrdcnt = (|wr_eop_position_r2) ? eop_cnt : 5'd16; 

wire wrfifo_empty, wrfifo_full;
wire [2*VALID_WIDTH-1:0] wrfifo_q;
reg wrfifo_q_valid = 1'b0;
assign wr_overflow = wrfifo_full;
assign rd_overflow = 1'b0;
reg    wrfifo_rdreq;

wire [alt_log2(RAM_DEPTH)-2:0] wrfifo_used;

wire wrfifo_wrreq = accum_cnt[VALID_WIDTH] | (|wr_eop_position_r2);

dcfifo	wffo (
			.wrclk (clk_wr),
			.wrreq (wrfifo_wrreq),
			.data ({(|wr_eop_position_r2), 2'b00, chunk_wrdcnt}),
			.wrfull (wrfifo_full),

			.rdclk (clk_rd),
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
	wffo.intended_device_family = DEVICE_FAMILY,
	wffo.lpm_hint = RAM_BLK_TYPE,
	wffo.lpm_numwords = RAM_DEPTH,
	wffo.lpm_showahead = "OFF",
	wffo.lpm_type = "dcfifo",
	wffo.lpm_width = 2*VALID_WIDTH,
	wffo.lpm_widthu = alt_log2(RAM_DEPTH)-1,
	wffo.overflow_checking = "ON",
	wffo.rdsync_delaypipe = 5,
	wffo.underflow_checking = "ON",
	wffo.use_eab = "ON",
	wffo.write_aclr_synch = "ON",
	wffo.wrsync_delaypipe = 5;

wire [VALID_WIDTH:0] buf_chunk_cnt; 
wire buf_eop_flag;
assign buf_chunk_cnt =  wrfifo_q[VALID_WIDTH:0] & {(VALID_WIDTH+1){wrfifo_q_valid}};
assign buf_eop_flag = wrfifo_q[2*VALID_WIDTH-1] & wrfifo_q_valid;

/////////////////////////////////////////////////////////
// Read Fifo state machine 
/////////////////////////////////////////////////////////
reg  [1:0]             next_rd_state=0;
reg  [1:0]             rd_state=0;
reg  [VALID_WIDTH-1:0] next_rd_num_valid=0;
reg  [VALID_WIDTH:0]   next_wd_cnt_left=0;
reg  [VALID_WIDTH:0]   wd_cnt_left=0;
reg                    next_last_read=0;
reg                    last_read=0;

always @(posedge clk_rd or posedge aclr_rd) begin
        if (aclr_rd) begin
                rd_state       <= 0;
                last_read      <= 1'b0;
                rd_num_valid   <= 0;
                wrfifo_q_valid <= 1'b0;
                wd_cnt_left    <= 0;
        end
        else begin
                rd_state       <= next_rd_state;
                last_read      <= next_last_read;
                rd_num_valid   <= next_rd_num_valid;
                wrfifo_q_valid <= wrfifo_rdreq; 
                wd_cnt_left    <= next_wd_cnt_left;
        end
end


always @*
begin
      next_rd_state     = rd_state;
      next_last_read    = 1'b0;
      wrfifo_rdreq      = 1'b0;
      next_rd_num_valid = 0;
      next_wd_cnt_left  = 0;
      case (rd_state)
      IDLE:  begin
               if (!wrfifo_empty) wrfifo_rdreq    = 1'b1; 
               if (!wrfifo_empty) next_rd_state  = TICK1;
      end
      TICK1: begin
               next_wd_cnt_left  = buf_chunk_cnt - {{(VALID_WIDTH-3) {1'b0}},4'd8};
               next_rd_num_valid = 8;
               if (buf_eop_flag) begin    //EOP can have 1~3 ticks
                 if (buf_chunk_cnt[VALID_WIDTH] & (|buf_chunk_cnt[VALID_WIDTH-1:0])) begin   //It needs three ticks
                   next_rd_state     = TICK2;
                 end else if (buf_chunk_cnt[VALID_WIDTH] | (buf_chunk_cnt[VALID_WIDTH-1] & |buf_chunk_cnt[VALID_WIDTH-2:0]) ) begin   //Total two ticks EOP
                   next_rd_state     = TICK2;
                   next_last_read    = 1'b1;
                 end else begin     //one tick EOP
                   next_rd_num_valid = buf_chunk_cnt[VALID_WIDTH-1:0];
                   if (!wrfifo_empty) wrfifo_rdreq   = 1'b1;
                   if (!wrfifo_empty) next_rd_state = TICK1;
                   else               next_rd_state = IDLE;
                 end
               end else begin             //only one more tick needed for 16 word read.
                 next_rd_state     = TICK2; 
                 next_last_read    = 1'b1;
               end
      end
      TICK2: begin
               if (last_read) begin           //Either EOP or regular tick2
                 next_rd_num_valid = wd_cnt_left[VALID_WIDTH-1:0];
                 if (!wrfifo_empty) wrfifo_rdreq   = 1'b1;
                 if (!wrfifo_empty) next_rd_state = TICK1;
                 else               next_rd_state = IDLE;
               end else begin                //One more tick for EOP
                 next_rd_num_valid = 8;
                 next_wd_cnt_left  = wd_cnt_left - {{(VALID_WIDTH-3){1'b0}},4'd8};
                 next_rd_state     = TICK3;
               end
      end
      TICK3: begin                           //Only EOP last tick
               next_rd_num_valid = wd_cnt_left[VALID_WIDTH-1:0];
               if (!wrfifo_empty) wrfifo_rdreq   = 1'b1;
               if (!wrfifo_empty) next_rd_state = TICK1;
               else               next_rd_state = IDLE;
      end
      endcase
end

endmodule
