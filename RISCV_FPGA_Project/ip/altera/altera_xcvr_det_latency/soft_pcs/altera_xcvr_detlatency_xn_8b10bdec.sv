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

module altera_xcvr_detlatency_xn_8b10bdec #(
  parameter data_width=32,  //refer to data width from core
  parameter ser_words_size=4
) (
    clk,
    rst,
    ser_words,
    din_dat,         // 10b data input
    dout_dat,        // data out
    dout_k,          // special code
    dout_kerr,       // coding mistake detected
    dout_rderr,      // running disparity mistake detected
    dout_rdcomb,     // running dispartiy output (comb)
    dout_rdreg       // running disparity output (reg)
);

localparam FULL_SER_WORDS = data_width/8;

input clk;
input rst;
input [ser_words_size-1:0] ser_words;
input [FULL_SER_WORDS*10-1:0] din_dat;      // 10b data input
output [FULL_SER_WORDS*8-1:0] dout_dat;     // data out
output [FULL_SER_WORDS-1:0] dout_k;         // special code
output [FULL_SER_WORDS-1:0] dout_kerr;      // coding mistake detected
output [FULL_SER_WORDS-1:0] dout_rderr;     // running disparity mistake detected
output [FULL_SER_WORDS-1:0] dout_rdcomb;    // running dispartiy output (comb)
output [FULL_SER_WORDS-1:0] dout_rdreg;     // running disparity output (reg)

wire [ser_words_size-1:0] sync_ser_words;
wire [FULL_SER_WORDS-1:0] din_rd;
wire rdreg;

assign rdreg = (sync_ser_words==8)? dout_rdreg[7] : (sync_ser_words==4)? dout_rdreg[3] : 
               (sync_ser_words==2)? dout_rdreg[1] : (sync_ser_words==1)? dout_rdreg[0] : 1'b0;  
assign din_rd = {dout_rdcomb[0 +: (FULL_SER_WORDS-1)], rdreg};

altera_xcvr_detlatency_synchronizer
#(
    .width(ser_words_size),
    .stages(2)
)sync_ser_words_xn_8b10bdec_inst(
    .clk(clk),
    .rst(rst),
    .dat_in(ser_words),
    .dat_out(sync_ser_words)
);

genvar iblock;
generate
for (iblock=0;iblock<FULL_SER_WORDS;iblock=iblock+1)
begin : iblock_inst

  altera_xcvr_detlatency_8b10bdec dec (
      .clk         (clk                             ),
      .rst         (rst                             ),
      .din_ena     (1'b1                            ),                        // Data (or code) input enable
      .din_dat     (din_dat[iblock*10 +: 10]  ),                        // 10b data in
      .din_rd      (din_rd[iblock]                  ),                        // running disparity input
      .dout_val    (/*not_used*/                    ),
      .dout_kerr   (dout_kerr[iblock]               ),
      .dout_dat    (dout_dat[iblock*8 +: 8]         ),                        // data out
      .dout_k      (dout_k[iblock]                  ),
      .dout_rderr  (dout_rderr[iblock]              ),
      .dout_rdcomb (dout_rdcomb[iblock]             ),                        // running disparity output (comb)
      .dout_rdreg  (dout_rdreg[iblock]              )                         // running disparity output (reg)
  );

end
endgenerate

endmodule
