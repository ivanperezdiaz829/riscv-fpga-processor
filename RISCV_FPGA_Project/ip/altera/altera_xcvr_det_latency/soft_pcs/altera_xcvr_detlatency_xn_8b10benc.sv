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

module altera_xcvr_detlatency_xn_8b10benc #(
    parameter data_width=32,
    parameter ser_words_size=4
)(
    clk,
    rst,
    ser_words,
    kin_ena,          // Data in is a special code, not all are legal.      
    ein_dat,          // 8b data in
    eout_dat          // data out
);

localparam FULL_SER_WORDS = data_width/8;

input clk;
input rst;
input [ser_words_size-1:0] ser_words;
input [FULL_SER_WORDS-1:0] kin_ena;           
input [data_width-1: 0] ein_dat;
output [FULL_SER_WORDS*10-1: 0] eout_dat;

wire [FULL_SER_WORDS-1:0] eout_rdcomb;
wire [FULL_SER_WORDS-1:0] eout_rdreg;
wire [FULL_SER_WORDS-1:0] eout_val;         // not used, since ein_ena not used in cascaded version
wire [FULL_SER_WORDS-1:0] ein_rd;
wire [ser_words_size-1:0] sync_ser_words;
wire rdreg;

assign rdreg = (sync_ser_words==8)? eout_rdreg[7] : (sync_ser_words==4)? eout_rdreg[3] : 
               (sync_ser_words==2)? eout_rdreg[1] : (sync_ser_words==1)? eout_rdreg[0] : 1'b0;  
assign ein_rd = {eout_rdcomb[0 +: (FULL_SER_WORDS-1)], rdreg};

altera_xcvr_detlatency_synchronizer
#(
    .width (ser_words_size),
    .stages(2)
)sync_ser_words_xn_8b10benc_inst(
    .clk(clk),
    .rst(rst),
    .dat_in(ser_words),
    .dat_out(sync_ser_words)
);

genvar iblock;
generate
for (iblock=0;iblock<FULL_SER_WORDS;iblock=iblock+1)
begin : iblock_inst

    altera_xcvr_detlatency_8b10benc enc (
        .clk         (clk                           ),
        .rst         (rst                           ),
        .kin_ena     (kin_ena[iblock]         ),                       // Data in is a special code, not all are legal.      
        .ein_ena     (1'b1                          ),                       // Data (or code) input enable
        .ein_dat     (ein_dat[iblock*8 +: 8]  ),                       // 8b data in
        .ein_rd      (ein_rd[iblock]                ),                       // running disparity input
        .eout_val    (eout_val[iblock]              ),                       // data out is valid
        .eout_dat    (eout_dat[iblock*10 +: 10]     ),                       // data out
        .eout_rdcomb (eout_rdcomb[iblock]           ),                       // running disparity output (comb)
        .eout_rdreg  (eout_rdreg[iblock]            )                        // running disparity output (reg)
    );

end
endgenerate

endmodule
