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

module unidir_delay
#(
	parameter NAME = "",
	parameter IDX  = -1
)
(
	input wire in, 				
	output wire out, 			
 	input wire [31:0] base_delay, 		
	input wire [31:0] delay,			
 	input wire [31:0] bad	 		
);


wire [31:0] base_delay_in;
wire [31:0] delay_in;
wire [31:0] bad_in;

assign base_delay_in = (base_delay === 'x || base_delay === 'z) ? '0 : base_delay;
assign bad_in = (bad === 'x || bad === 'z) ? '0 : bad;
assign delay_in = (delay === 'x || delay === 'z) ? '0 : delay;

always @(base_delay_in, delay_in, bad_in)
begin
	if (base_delay_in + delay_in < bad_in/2)
	begin
		$display("%m: ERROR: base_delay(%0d) + delay_in(%0d must be >= bad(%0d)/2", 
			 base_delay_in, delay_in, bad_in);
	end
end
		
always @(base_delay_in, bad_in, delay_in)
begin
        $display("%0d [%m] base_delay=%0d bad=%0d delay=%0d", $time, base_delay_in, bad_in, delay_in);
end

reg out_dly = 1'bz;

always @(in)
begin
	if (bad_in > 0)
		out_dly <= #(base_delay_in - bad_in/2 + delay_in) 1'bx;
	out_dly <= #(base_delay_in + bad_in/2 + delay_in) in;
end

assign out = out_dly;

endmodule
