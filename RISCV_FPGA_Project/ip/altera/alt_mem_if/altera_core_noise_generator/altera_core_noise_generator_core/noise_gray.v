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


module gray_plus_one (
	q,
	q_plus
);

parameter WIDTH = 8;

input [WIDTH-1:0] q;
output [WIDTH-1:0] q_plus;

	wire [WIDTH-1:0] q_to_bin;
	assign q_to_bin[WIDTH-1] = q[WIDTH-1];
	genvar i;
	generate
	for (i=WIDTH-2; i>=0; i=i-1)
	  begin: gry_to_bin
		assign q_to_bin[i] = q_to_bin[i+1] ^ q[i];
	  end
	endgenerate

	wire [WIDTH-1:0] inc_q;
	wire [WIDTH-1:0] inc_q_cout;
	assign inc_q[0] = !q_to_bin[0];
	assign inc_q_cout[0] = q_to_bin[0];
	generate
	for (i=1; i<WIDTH; i=i+1)
	  begin: plus_one
		assign inc_q[i] = inc_q_cout[i-1] ^ q_to_bin[i];
		assign inc_q_cout[i] = inc_q_cout[i-1] & q_to_bin[i];
	  end
	endgenerate

	assign q_plus = inc_q ^ (inc_q >> 1);

endmodule

module gray_cntr (
	clk,
	q
);

parameter WIDTH = 8;

input clk;
output [WIDTH-1:0] q;

	reg [WIDTH-1:0] q /* synthesis syn_noprune syn_preserve = 1 */;
	wire [WIDTH-1:0] q_plus;

	gray_plus_one gp (.q(q),.q_plus(q_plus));
	defparam gp.WIDTH = WIDTH;

	always @(posedge clk) begin
		q <= q_plus;
	end
endmodule

module noise_gray (
	clk
);

parameter NUM_GRAY = 125;

input clk;

	generate
		genvar i;
		
		for (i = 0; i < NUM_GRAY; i = i + 1) begin: gen_loop
			gray_cntr gray_cntr_inst (
				.clk (clk),
				.q ()
			);
		end		
	endgenerate

endmodule