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

module alt_e100_user_mode_det (
    input ref_clk,
    output user_mode_sync);

    reg user_mode = 1'b0/* synthesis preserve */; 

	always @(posedge ref_clk)
    begin
       user_mode <= 1'b1;
    end

    reg [7:0] user_mode_counter = 8'h00/* synthesis preserve */; 
	always @(posedge ref_clk)
    begin
       if (user_mode && ! user_mode_counter[7]) 
       	user_mode_counter <= user_mode_counter + 1'b1;
    end
    assign user_mode_sync = user_mode_counter[7];

endmodule
