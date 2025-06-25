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


//
// prbs8:  g(x) = x^8 + x^4 + x^3 + x^2 + 1
//
//output as bytes, lsb = d0
//
module altera_usb_debug_prbs8(
    input  wire [7:0] in_prbs,
    output wire [7:0] out_prbs
);

//x^8 + x[4] + x[3] + x[2] + x[0]
assign  out_prbs = {in_prbs[6] ^ in_prbs[5] ^ in_prbs[4] ^ in_prbs[0], in_prbs[7:1]};

endmodule
