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



module alt_e40_gearbox_66_64 (
	input arst,
	input clk,
	input sclr,			// fixes the state, not the data for min fanout
	input [65:0] din,     // lsbit first
	output reg din_ack,  // 3 cycles early
	output [63:0] dout	
);

reg [5:0] gbstate = 0 /* synthesis preserve */;
reg [127:0] stor = 0 /* synthesis preserve */;
assign dout = stor[63:0];

always @(posedge clk or posedge arst) begin
	if(arst)
		gbstate <= 0;
	else
        gbstate <= (sclr | gbstate[5]) ? 6'h0 : (gbstate + 1'b1);
end

always @(posedge clk) begin
	   
	if (gbstate[5]) begin 
		stor <= {64'h0,stor[127:64]};    // holding 0	
	end    
	else begin	
		case (gbstate[4:0])
			5'h0 : begin stor[65:0] <= din[65:0];  end   // holding 2
			5'h1 : begin stor[67:2] <= din[65:0]; stor[1:0] <= stor[65:64];   end   // holding 4
			5'h2 : begin stor[69:4] <= din[65:0]; stor[3:0] <= stor[67:64];   end   // holding 6
			5'h3 : begin stor[71:6] <= din[65:0]; stor[5:0] <= stor[69:64];   end   // holding 8
			5'h4 : begin stor[73:8] <= din[65:0]; stor[7:0] <= stor[71:64];   end   // holding 10
			5'h5 : begin stor[75:10] <= din[65:0]; stor[9:0] <= stor[73:64];   end   // holding 12
			5'h6 : begin stor[77:12] <= din[65:0]; stor[11:0] <= stor[75:64];   end   // holding 14
			5'h7 : begin stor[79:14] <= din[65:0]; stor[13:0] <= stor[77:64];   end   // holding 16
			5'h8 : begin stor[81:16] <= din[65:0]; stor[15:0] <= stor[79:64];   end   // holding 18
			5'h9 : begin stor[83:18] <= din[65:0]; stor[17:0] <= stor[81:64];   end   // holding 20
			5'ha : begin stor[85:20] <= din[65:0]; stor[19:0] <= stor[83:64];   end   // holding 22
			5'hb : begin stor[87:22] <= din[65:0]; stor[21:0] <= stor[85:64];   end   // holding 24
			5'hc : begin stor[89:24] <= din[65:0]; stor[23:0] <= stor[87:64];   end   // holding 26
			5'hd : begin stor[91:26] <= din[65:0]; stor[25:0] <= stor[89:64];   end   // holding 28
			5'he : begin stor[93:28] <= din[65:0]; stor[27:0] <= stor[91:64];   end   // holding 30
			5'hf : begin stor[95:30] <= din[65:0]; stor[29:0] <= stor[93:64];   end   // holding 32
			5'h10 : begin stor[97:32] <= din[65:0]; stor[31:0] <= stor[95:64];   end   // holding 34
			5'h11 : begin stor[99:34] <= din[65:0]; stor[33:0] <= stor[97:64];   end   // holding 36
			5'h12 : begin stor[101:36] <= din[65:0]; stor[35:0] <= stor[99:64];   end   // holding 38
			5'h13 : begin stor[103:38] <= din[65:0]; stor[37:0] <= stor[101:64];   end   // holding 40
			5'h14 : begin stor[105:40] <= din[65:0]; stor[39:0] <= stor[103:64];   end   // holding 42
			5'h15 : begin stor[107:42] <= din[65:0]; stor[41:0] <= stor[105:64];   end   // holding 44
			5'h16 : begin stor[109:44] <= din[65:0]; stor[43:0] <= stor[107:64];   end   // holding 46
			5'h17 : begin stor[111:46] <= din[65:0]; stor[45:0] <= stor[109:64];   end   // holding 48
			5'h18 : begin stor[113:48] <= din[65:0]; stor[47:0] <= stor[111:64];   end   // holding 50
			5'h19 : begin stor[115:50] <= din[65:0]; stor[49:0] <= stor[113:64];   end   // holding 52
			5'h1a : begin stor[117:52] <= din[65:0]; stor[51:0] <= stor[115:64];   end   // holding 54
			5'h1b : begin stor[119:54] <= din[65:0]; stor[53:0] <= stor[117:64];   end   // holding 56
			5'h1c : begin stor[121:56] <= din[65:0]; stor[55:0] <= stor[119:64];   end   // holding 58
			5'h1d : begin stor[123:58] <= din[65:0]; stor[57:0] <= stor[121:64];   end   // holding 60
			5'h1e : begin stor[125:60] <= din[65:0]; stor[59:0] <= stor[123:64];   end   // holding 62
			5'h1f : begin stor[127:62] <= din[65:0]; stor[61:0] <= stor[125:64];   end   // holding 64
		endcase
	end
end

// this is the pattern as corresponding to the states
// wire [32:0] in_pattern = 33'b011111111111111111111111111111111;

// this is adjusted for latency
wire [32:0] in_pattern = 33'b111011111111111111111111111111111;
wire [32:0] in_pattern_shift;

assign in_pattern_shift = in_pattern >> gbstate;

always @(posedge clk) begin
	if (sclr) din_ack <= 1'b0;
	else din_ack <= in_pattern_shift[0];
end


endmodule