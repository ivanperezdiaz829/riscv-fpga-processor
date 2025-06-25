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


module clock_divider(
    clk_in,
    reset,
    clk_out

);

input clk_in;
output reg clk_out;
input reset;

reg ctr;


always@(posedge clk_in or posedge reset)
begin
    if(reset) begin
        ctr <= 1'b0;
        clk_out <= 1'b0;
    end else begin
        ctr <= ctr +1'b1;
        if (ctr == 1'b1) begin
            clk_out <= ~clk_out;
        end 
    end

end

endmodule
