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



module alt_e40_gearbox_64_66 (
	input arst,
	input clk,
	input slip_to_frame,  // look for the least significant 2 bits being opposite
	input [63:0] din,     // lsbit first
	output [65:0] dout,
	output reg dout_valid
);

initial dout_valid = 1'b0;
	
reg [5:0] gbstate = 0 /* synthesis preserve */;
reg [127:0] stor = 0 /* synthesis preserve */;
assign dout = stor[65:0];
reg [63:0] din_r = 0;
reg din_extra = 0;

// framing acquisition controls
reg odd = 1'b0 /* synthesis preserve */;	// select a 1 bit shift of the input data
reg drop64 = 1'b0 /* synthesis preserve */;	// slip by 1 input word

always @(posedge clk or posedge arst) begin
	if(arst)
		gbstate <= 0;
	else
		gbstate <= drop64 ? gbstate : (gbstate[5] ? 6'h0 : (gbstate + 1'b1));
end

always @(posedge clk) begin
	din_extra <= din[63];
	din_r <= odd ? {din[62:0],din_extra} : din[63:0];
	
	dout_valid <= 1'b0;
	   
	if (gbstate[5]) begin 
		stor[65:2] <= din_r[63:0]; stor[1:0] <= stor[67:66]; dout_valid <= 1'b1; 
	end    //  now holding 0
	else begin	
		case (gbstate[4:0])
			5'h0 : begin stor[63:0] <= din_r[63:0]; end     //  now holding 64
			5'h1 : begin stor[127:64] <= din_r[63:0]; dout_valid <= 1'b1; end    //  now holding 62
			5'h2 : begin stor[125:62] <= din_r[63:0]; stor[61:0] <= stor[127:66]; dout_valid <= 1'b1; end    //  now holding 60
			5'h3 : begin stor[123:60] <= din_r[63:0]; stor[59:0] <= stor[125:66]; dout_valid <= 1'b1; end    //  now holding 58
			5'h4 : begin stor[121:58] <= din_r[63:0]; stor[57:0] <= stor[123:66]; dout_valid <= 1'b1; end    //  now holding 56
			5'h5 : begin stor[119:56] <= din_r[63:0]; stor[55:0] <= stor[121:66]; dout_valid <= 1'b1; end    //  now holding 54
			5'h6 : begin stor[117:54] <= din_r[63:0]; stor[53:0] <= stor[119:66]; dout_valid <= 1'b1; end    //  now holding 52
			5'h7 : begin stor[115:52] <= din_r[63:0]; stor[51:0] <= stor[117:66]; dout_valid <= 1'b1; end    //  now holding 50
			5'h8 : begin stor[113:50] <= din_r[63:0]; stor[49:0] <= stor[115:66]; dout_valid <= 1'b1; end    //  now holding 48
			5'h9 : begin stor[111:48] <= din_r[63:0]; stor[47:0] <= stor[113:66]; dout_valid <= 1'b1; end    //  now holding 46
			5'ha : begin stor[109:46] <= din_r[63:0]; stor[45:0] <= stor[111:66]; dout_valid <= 1'b1; end    //  now holding 44
			5'hb : begin stor[107:44] <= din_r[63:0]; stor[43:0] <= stor[109:66]; dout_valid <= 1'b1; end    //  now holding 42
			5'hc : begin stor[105:42] <= din_r[63:0]; stor[41:0] <= stor[107:66]; dout_valid <= 1'b1; end    //  now holding 40
			5'hd : begin stor[103:40] <= din_r[63:0]; stor[39:0] <= stor[105:66]; dout_valid <= 1'b1; end    //  now holding 38
			5'he : begin stor[101:38] <= din_r[63:0]; stor[37:0] <= stor[103:66]; dout_valid <= 1'b1; end    //  now holding 36
			5'hf : begin stor[99:36]  <= din_r[63:0]; stor[35:0] <= stor[101:66]; dout_valid <= 1'b1; end    //  now holding 34
			5'h10 : begin stor[97:34] <= din_r[63:0]; stor[33:0] <= stor[99:66];  dout_valid <= 1'b1; end    //  now holding 32
			5'h11 : begin stor[95:32] <= din_r[63:0]; stor[31:0] <= stor[97:66];  dout_valid <= 1'b1; end    //  now holding 30
			5'h12 : begin stor[93:30] <= din_r[63:0]; stor[29:0] <= stor[95:66];  dout_valid <= 1'b1; end    //  now holding 28
			5'h13 : begin stor[91:28] <= din_r[63:0]; stor[27:0] <= stor[93:66];  dout_valid <= 1'b1; end    //  now holding 26
			5'h14 : begin stor[89:26] <= din_r[63:0]; stor[25:0] <= stor[91:66];  dout_valid <= 1'b1; end    //  now holding 24
			5'h15 : begin stor[87:24] <= din_r[63:0]; stor[23:0] <= stor[89:66];  dout_valid <= 1'b1; end    //  now holding 22
			5'h16 : begin stor[85:22] <= din_r[63:0]; stor[21:0] <= stor[87:66];  dout_valid <= 1'b1; end    //  now holding 20
			5'h17 : begin stor[83:20] <= din_r[63:0]; stor[19:0] <= stor[85:66];  dout_valid <= 1'b1; end    //  now holding 18
			5'h18 : begin stor[81:18] <= din_r[63:0]; stor[17:0] <= stor[83:66];  dout_valid <= 1'b1; end    //  now holding 16
			5'h19 : begin stor[79:16] <= din_r[63:0]; stor[15:0] <= stor[81:66];  dout_valid <= 1'b1; end    //  now holding 14
			5'h1a : begin stor[77:14] <= din_r[63:0]; stor[13:0] <= stor[79:66];  dout_valid <= 1'b1; end    //  now holding 12
			5'h1b : begin stor[75:12] <= din_r[63:0]; stor[11:0] <= stor[77:66];  dout_valid <= 1'b1; end    //  now holding 10
			5'h1c : begin stor[73:10] <= din_r[63:0]; stor[9:0]  <= stor[75:66];  dout_valid <= 1'b1; end    //  now holding 8
			5'h1d : begin stor[71:8]  <= din_r[63:0]; stor[7:0]  <= stor[73:66];  dout_valid <= 1'b1; end    //  now holding 6
			5'h1e : begin stor[69:6]  <= din_r[63:0]; stor[5:0]  <= stor[71:66];  dout_valid <= 1'b1; end    //  now holding 4
			5'h1f : begin stor[67:4]  <= din_r[63:0]; stor[3:0]  <= stor[69:66];  dout_valid <= 1'b1; end    //  now holding 2
		endcase
	end
end

/////////////////////////////////////////////
// handle the details of slipping

reg [3:0] grace = 0 /* synthesis preserve */;
wire bad_frame = ~^dout[1:0];

always @(posedge clk or posedge arst) begin
    if(arst) begin
    	drop64 <= 1'b0;
        odd <= 1'b0;
        grace <= 4'h0;
    end else begin
        drop64 <= 1'b0;
        
        if (slip_to_frame && bad_frame && !grace[3]) begin
            if (odd) begin
                odd <= 1'b0;
                drop64 <= 1'b1;
            end
            else begin
                odd <= 1'b1;
            end
            grace <= 4'b1111;
        end
        else begin
            grace <= {grace[2:0],1'b0};
        end
    end

end


endmodule
