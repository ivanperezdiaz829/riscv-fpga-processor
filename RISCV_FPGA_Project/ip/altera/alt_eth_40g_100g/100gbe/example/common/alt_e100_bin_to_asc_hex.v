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

// baeckler - 04-26-2006
// convert a variable length binary word to hex.

//module alt_e100_bin_to_asc_hex (in,out);	// LEDA
module alt_e100_bin_to_asc_hex (bin_in,asc_out);

parameter METHOD = 1;
parameter WIDTH = 16;

localparam PAD_BITS = (WIDTH % 4) == 0 ? 0 : (4-(WIDTH%4));
localparam PADDED_WIDTH = WIDTH + PAD_BITS;
localparam NYBBLES = PADDED_WIDTH >> 2;

//input [WIDTH-1:0] in;	// LEDA	
//output [8*NYBBLES-1:0] out;	// KEDA
input [WIDTH-1:0] bin_in;	
output [8*NYBBLES-1:0] asc_out;

//wire [PADDED_WIDTH-1:0] padded_in = {{PAD_BITS {1'b0}},in};	// LEDA
wire [PADDED_WIDTH-1:0] padded_in = {{PAD_BITS {1'b0}},bin_in};

genvar i;
generate
	for (i=0; i<NYBBLES; i=i+1)
	begin : h
		wire [3:0] tmp_in = padded_in [4*(i+1)-1:4*i];
	
		if (METHOD == 0) begin
			// C style comparison.
			wire [7:0] tmp_out;
			assign tmp_out = (tmp_in < 10) ? ("0" | tmp_in) : ("A" + tmp_in - 10);
			//assign out [8*(i+1)-1:8*i] = tmp_out;	// LEDA
			assign asc_out [8*(i+1)-1:8*i] = tmp_out;
		end
		else begin
			/////////////////////////////////////
			// METHOD = 1 is an equivalent case 
			//   statement, to make the minimizations 
			//   more obvious.
			/////////////////////////////////////
			reg [7:0] tmp_out;
			always @(tmp_in) begin
				case (tmp_in)
				   4'h0 : tmp_out = 8'b00110000;
				   4'h1 : tmp_out = 8'b00110001;
				   4'h2 : tmp_out = 8'b00110010;
				   4'h3 : tmp_out = 8'b00110011;
				   4'h4 : tmp_out = 8'b00110100;
				   4'h5 : tmp_out = 8'b00110101;
				   4'h6 : tmp_out = 8'b00110110;
				   4'h7 : tmp_out = 8'b00110111;
				   4'h8 : tmp_out = 8'b00111000;
				   4'h9 : tmp_out = 8'b00111001;
				   4'ha : tmp_out = 8'b01000001;
				   4'hb : tmp_out = 8'b01000010;
				   4'hc : tmp_out = 8'b01000011;
				   4'hd : tmp_out = 8'b01000100;
				   4'he : tmp_out = 8'b01000101;
				   4'hf : tmp_out = 8'b01000110;
				   default : tmp_out = 8'b00000000;	// LEDA
				endcase
			end
			//assign out [8*(i+1)-1:8*i] = tmp_out;	// LEDA
			assign asc_out [8*(i+1)-1:8*i] = tmp_out;
		end					
	end
endgenerate

endmodule

/////////////////////////////////
// quick sanity check
/////////////////////////////////
/*
module bin_to_asc_hex_tb ();

parameter WIDTH = 16;
parameter OUT_WIDTH = 4; // Number of nybbles in WIDTH

reg [WIDTH-1:0] in;
wire [8*OUT_WIDTH-1:0] oa,ob;

alt_e100_bin_to_asc_hex a (.bin_in(in),.asc_out(oa));
alt_e100_bin_to_asc_hex b (.bin_in(in),.asc_out(ob));

initial begin
	#100000 $stop();
end

always begin
	#100 in = $random;
	#100 if (oa !== ob) $display ("Disagreement at time %d",$time);
end	

endmodule
*/
