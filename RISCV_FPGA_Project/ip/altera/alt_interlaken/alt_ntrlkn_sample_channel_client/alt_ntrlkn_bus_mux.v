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
// baeckler - 10-28-2006

/////////////////////////////////////////////////////

module alt_ntrlkn_bus_mux (din,sel,dout);

parameter DAT_WIDTH = 16;
parameter SEL_WIDTH = 3;
parameter TOTAL_DAT = DAT_WIDTH << SEL_WIDTH;
parameter NUM_WORDS = (1 << SEL_WIDTH);

input [TOTAL_DAT-1 : 0] din;
input [SEL_WIDTH-1:0] sel;
output [DAT_WIDTH-1:0] dout;

genvar i,k;
generate
	for (k=0;k<DAT_WIDTH;k=k+1)
	begin : out
		wire [NUM_WORDS-1:0] tmp;
		for (i=0;i<NUM_WORDS;i=i+1)
		begin : mx
			assign tmp [i] = din[k+i*DAT_WIDTH];
		end
		assign dout[k] = tmp[sel];
	end
endgenerate
endmodule
