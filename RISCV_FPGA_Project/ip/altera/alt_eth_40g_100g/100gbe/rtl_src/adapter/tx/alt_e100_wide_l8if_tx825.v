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


///////////////////////////////////////////////////////////////////////////////
//
// Description: tx 8 lane to 5 lane conversion
//
///////////////////////////////////////////////////////////////////////////////
`timescale 1ps / 1ps

module alt_e100_wide_l8if_tx825 #(
    parameter WORD_WIDTH = 64,
    parameter NUM_WORDS = 8,
    parameter ADDR_WIDTH = 7 
)(
    arst, clk_txmac, tx8l_d, tx8l_sop, tx8l_eop, tx8l_eop_pos, tx8l_rdempty,
    tx8l_rdreq, tx5l_d, tx5l_sop, tx5l_eop_bm, tx5l_ack
); // module alt_e100_wide_l8if_tx825

//--- ports
input               arst;
input               clk_txmac;     // MAC + PCS clock - at least 312.5Mhz

input    [8*64-1:0] tx8l_d;        // 8 lane payload data
input               tx8l_sop;
input               tx8l_eop;
input         [5:0] tx8l_eop_pos;
input               tx8l_rdempty;
output              tx8l_rdreq;

output   [5*64-1:0] tx5l_d;        // 5 lane payload to send
output      [5-1:0] tx5l_sop;      // 5 lane start position
output    [5*8-1:0] tx5l_eop_bm;   // 5 lane end position, any byte, bit map
input               tx5l_ack;      // payload is accepted


//--- declare
wire            clk_txmac;
wire [8*64-1:0] tx8l_d;
wire            tx8l_sop;
wire            tx8l_eop;
wire [5:0]      tx8l_eop_pos;
wire            tx8l_rdreq;
wire [5*64-1:0] pre_tx5l_d;
wire [5-1:0]    pre_tx5l_sop;
wire [5*8-1:0]  pre_tx5l_eop_bm;
wire [5*64-1:0] tx5l_d;
wire [5-1:0]    tx5l_sop;
wire [5*8-1:0]  tx5l_eop_bm;
wire            tx5l_ack;
wire            tx5l_valid;
reg  [5*64-1:0] tx5l_d_2fifo;
reg  [5-1:0]    tx5l_sop_2fifo;
reg  [5*8-1:0]  tx5l_eop_bm_2fifo;
wire [4:0]      tx825fifo_usedw;

reg  [8*64-1:0] f0;     
reg             f0_sop_b7;
wire [7:0]      f0_sop; 
reg             f0_eop;
reg  [39:0]     f0_eop_pos;
wire [63:0]     f0_eop_bm;
reg  [63:0]     test_eopbits;
reg  [3:0]      num_wr;
//reg             in_packet;

//--- main

always @(posedge clk_txmac or posedge arst) begin
   if (arst) num_wr <= 0;
   else if (tx8l_rdreq && !tx8l_rdempty) num_wr <= tx8l_eop ? ((tx8l_eop_pos[5:3]==0) ? 4'h8 : (4'h8 - tx8l_eop_pos[5:3])) : 4'h8; // IPG
   else              num_wr <= 0;
end


always @(posedge clk_txmac) begin
      f0           <=  tx8l_d;
      f0_sop_b7    <=  !tx8l_rdempty & tx8l_sop;
      f0_eop       <=  !tx8l_rdempty & tx8l_eop;
      f0_eop_pos   <=  tx8l_eop_pos;
end

assign f0_sop = {f0_sop_b7, 7'h0};

genvar i;
generate
for (i=0; i<64; i=i+1) begin : eop_decode
   assign f0_eop_bm[i] = f0_eop && (f0_eop_pos == i);
end
endgenerate

/////////////////////////////////////////////////
// word addressable storage
/////////////////////////////////////////////////
localparam EXT_WORD_WIDTH = WORD_WIDTH + 8 + 1;
wire [EXT_WORD_WIDTH * NUM_WORDS-1:0] ext_din, ext_dout;
reg  [EXT_WORD_WIDTH * NUM_WORDS-1:0] ext_din_r;
reg [3:0] num_wr_r3 = 0, num_wr_r2 = 0, num_wr_r = 0;

reg [ADDR_WIDTH-1:0] rd_addr = 0;
reg [ADDR_WIDTH-1:0] holding = 0;
wire[ADDR_WIDTH:0]   holding_plus_num_wr = holding + num_wr_r3;
reg                  high_holding=0;
reg                  enable_read;
wire                 go_read = enable_read && (holding!=0) && (tx825fifo_usedw<=5'hf);

always @(posedge clk_txmac or posedge arst) begin
   if (arst)               enable_read <= 1'b0;
   else if (holding >= 10) enable_read <= 1'b1;
   else if (holding == 0)  enable_read <= 1'b0;
end

// embed SOP/EOP in data words
generate
for (i=0; i<NUM_WORDS; i=i+1) begin : pack_din
        assign ext_din[(i+1)*EXT_WORD_WIDTH-1:i*EXT_WORD_WIDTH] =
                        {f0_sop[i],
                         f0_eop_bm[(i+1)*8-1:i*8],
                         f0[(i+1)*WORD_WIDTH-1:i*WORD_WIDTH]};
end
endgenerate

generate
for (i=0; i<5; i=i+1) begin : pack_dout
        assign {pre_tx5l_sop[i],
                pre_tx5l_eop_bm[(i+1)*8-1:i*8],
                pre_tx5l_d[(i+1)*WORD_WIDTH-1:i*WORD_WIDTH]} = 
                         ext_dout[(i+3+1)*EXT_WORD_WIDTH-1:(i+3)*EXT_WORD_WIDTH];
end
endgenerate

reg [4:0] word_enable;
reg [4:0] word_enable_1;
reg [4:0] word_enable_2;
reg [4:0] word_enable_3;
reg [4:0] word_enable_4;
reg [4:0] word_enable_5;
reg [4:0] word_enable_6;
reg [4:0] word_enable_7;

wire ram_dout_valid;
always @(posedge clk_txmac or posedge arst) begin
   if (arst) begin
      tx5l_sop_2fifo <= 0;
      tx5l_eop_bm_2fifo <=0;
      tx5l_d_2fifo <= 0;
   end
   else if (ram_dout_valid) begin
      tx5l_sop_2fifo <= word_enable_7 & pre_tx5l_sop;
      tx5l_eop_bm_2fifo <=
                     {{8{word_enable_7[4]}} & pre_tx5l_eop_bm[39:32],
                      {8{word_enable_7[3]}} & pre_tx5l_eop_bm[31:24], 
                      {8{word_enable_7[2]}} & pre_tx5l_eop_bm[23:16], 
                      {8{word_enable_7[1]}} & pre_tx5l_eop_bm[15: 8], 
                      {8{word_enable_7[0]}} & pre_tx5l_eop_bm[ 7: 0]};
      tx5l_d_2fifo <= pre_tx5l_d;
   end
end

/*always @(posedge clk_txmac or posedge arst) begin
   if (arst)          in_packet <= 1'b0;
   else if (tx8l_eop) in_packet <= 0;
   else if (tx8l_sop) in_packet <= 1;
end*/

// pipeline the write again - showing some timing pressure here
reg [ADDR_WIDTH-1:0] wr_addr = 0, wr_addr_r = 0;

always @(posedge clk_txmac or posedge arst) begin
    if(arst) begin
        ext_din_r <= 0;
        wr_addr_r <= 0;
    end else begin
        ext_din_r <= ext_din;
        wr_addr_r <= wr_addr;
    end
end


//wire [ADDR_WIDTH-1:0] read_quant = 8'h5;
wire [ADDR_WIDTH-1:0] read_quant = (holding_plus_num_wr > 5) ? 7'h5 : holding_plus_num_wr[ADDR_WIDTH-1:0];
wire [ADDR_WIDTH-1:0] num_read = go_read ? read_quant : 7'h0;

always @(*) begin
	case (num_read)
        0 :      word_enable[4:0] = 5'b00000;
        1 :      word_enable[4:0] = 5'b10000;
        2 :      word_enable[4:0] = 5'b11000;
        3 :      word_enable[4:0] = 5'b11100;
        4 :      word_enable[4:0] = 5'b11110;
        5 :      word_enable[4:0] = 5'b11111;
        default: word_enable[4:0] = 5'b00000;
        endcase
end

always @(posedge clk_txmac or posedge arst) begin
   if (arst) begin
      word_enable_1 <= 0;
      word_enable_2 <= 0;
      word_enable_3 <= 0;
      word_enable_4 <= 0;
      word_enable_5 <= 0;
      word_enable_6 <= 0;
      word_enable_7 <= 0;
   end
   else begin
      word_enable_1 <= word_enable;
      word_enable_2 <= word_enable_1;
      word_enable_3 <= word_enable_2;
      word_enable_4 <= word_enable_3;
      word_enable_5 <= word_enable_4;
      word_enable_6 <= word_enable_5;
      word_enable_7 <= word_enable_6;
   end
end

// storage
alt_e100_wide_word_ram_8 wwr (
        .clk     (clk_txmac),
        .arst    (arst),
        .din     (ext_din_r),
        .wr_addr (wr_addr_r),            // addressing is in words
        .we      (1'b1),
        .dout    (ext_dout),
        .rd_addr (rd_addr)
);
defparam wwr .WORD_WIDTH = EXT_WORD_WIDTH;
defparam wwr .NUM_WORDS = NUM_WORDS;  // barrel shifter mod required to override
defparam wwr .ADDR_WIDTH = ADDR_WIDTH;

// RAM pointers
reg [7:0] rd_history = 0;
assign ram_dout_valid = rd_history[6];
//reg overflow_holding = 1'b0;

wire [7:0] holding_plus_num_wr_diff_num_read = holding_plus_num_wr - num_read;
always @(posedge clk_txmac or posedge arst) begin
        // delay for the write to settle
        if (arst) begin
                rd_history <= 8'b0;
                wr_addr <= 0;
                holding <= 0;
                rd_addr <= 0;
        end else begin
                rd_history <= {rd_history[6:0],go_read};
                wr_addr <= wr_addr + num_wr;
                holding <= (holding_plus_num_wr > num_read) ? holding_plus_num_wr_diff_num_read [6:0] : 7'b0;
                rd_addr <= rd_addr + num_read;
        end
end


always @(posedge clk_txmac or posedge arst) begin
    if(arst) begin
        num_wr_r <= 0;
        num_wr_r2 <= 0;
        num_wr_r3 <= 0;

        high_holding <= 0;
    end else begin
        // delay for the write to settle
        num_wr_r <= num_wr;
        num_wr_r2 <= num_wr_r;
        num_wr_r3 <= num_wr_r2;

        high_holding <= holding >= 60;
        //overflow_holding <= holding[ADDR_WIDTH-1];
    end
end

//assign tx8l_rdreq = !high_holding && !tx8l_rdempty;
assign tx8l_rdreq = !high_holding;

// output fifo
reg tx825fifo_wrreq;
wire x825fifo_rdreq;
wire tx825fifo_clock;
wire [5*EXT_WORD_WIDTH-1:0] tx825fifo_data, tx825fifo_q;

always @(posedge clk_txmac) tx825fifo_wrreq <= ram_dout_valid;

assign tx825fifo_data = {tx5l_sop_2fifo,
                        tx5l_eop_bm_2fifo,
                        tx5l_d_2fifo};

wire tx825fifo_rdreq;
wire tx825fifo_empty;
wire tx825fifo_full;
// if needed an output register can be added to this fifo
alt_e100_wide_l8if_tx825fifo alt_e100_wide_l8if_tx825fifo(
    .aclr         (arst),                     // i
    .clock        (clk_txmac),                // i
    .data         (tx825fifo_data),           // i
    .rdreq        (tx825fifo_rdreq),          // i
    .wrreq        (tx825fifo_wrreq),          // i
    .empty        (tx825fifo_empty),          // o
    .full         (tx825fifo_full),           // o
    .q            (tx825fifo_q),              // o
    .usedw        (tx825fifo_usedw)           // o
); // module alt_e100_wide_l8if_tx825fifo

assign tx825fifo_rdreq = tx5l_ack & !tx825fifo_empty;

assign tx5l_sop = {5{~tx825fifo_empty}} & tx825fifo_q[364:360];
assign tx5l_eop_bm = {40{~tx825fifo_empty}} & tx825fifo_q[359:320];
assign tx5l_d = tx825fifo_q[319:0];

/*
// synopsys translate off
wire [6:0] sum_eop;
wire [2:0] sum_sop;

assign sum_sop = tx5l_sop[0] + tx5l_sop[1] + tx5l_sop[2] + tx5l_sop[3] + tx5l_sop[4];
assign sum_eop = tx5l_eop_bm[ 0] + tx5l_eop_bm[ 1] + tx5l_eop_bm[ 2] + tx5l_eop_bm[ 3] + tx5l_eop_bm[ 4] +
                 tx5l_eop_bm[ 5] + tx5l_eop_bm[ 6] + tx5l_eop_bm[ 7] + tx5l_eop_bm[ 8] + tx5l_eop_bm[ 9] +
                 tx5l_eop_bm[10] + tx5l_eop_bm[11] + tx5l_eop_bm[12] + tx5l_eop_bm[13] + tx5l_eop_bm[14] +
                 tx5l_eop_bm[15] + tx5l_eop_bm[16] + tx5l_eop_bm[17] + tx5l_eop_bm[18] + tx5l_eop_bm[19] +
                 tx5l_eop_bm[20] + tx5l_eop_bm[21] + tx5l_eop_bm[22] + tx5l_eop_bm[23] + tx5l_eop_bm[24] +
                 tx5l_eop_bm[25] + tx5l_eop_bm[26] + tx5l_eop_bm[27] + tx5l_eop_bm[28] + tx5l_eop_bm[29] +
                 tx5l_eop_bm[30] + tx5l_eop_bm[31] + tx5l_eop_bm[32] + tx5l_eop_bm[33] + tx5l_eop_bm[34] +
                 tx5l_eop_bm[35] + tx5l_eop_bm[36] + tx5l_eop_bm[37] + tx5l_eop_bm[38] + tx5l_eop_bm[39];

always @(posedge clk_txmac) begin
   if (tx5l_ack) begin
      if (sum_eop != 0 && sum_eop!=1) $display("%t : More than 1 EOP %h", $time, tx5l_eop_bm);
      if (sum_sop != 0 && sum_sop!=1) $display("%t : More than 1 SOP %b", $time, tx5l_sop);
   end
end
// synopsys translate on
*/
endmodule
