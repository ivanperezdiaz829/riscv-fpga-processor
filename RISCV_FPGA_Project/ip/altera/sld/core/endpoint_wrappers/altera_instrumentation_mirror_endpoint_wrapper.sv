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


// altera_instrumentation_mirror_endpoint.sv

`timescale 1 ns / 1 ns

module altera_instrumentation_mirror_endpoint_wrapper #(
    parameter COUNT          = 1,
    parameter WIDTH          = 8,
    parameter NODES          = "",
    parameter CLOCKS         = ""
) (
    input  [nonzero(WIDTH)-1:0] mirror_send,
    output [nonzero(WIDTH)-1:0] mirror_receive
);

function integer nonzero;
input value;
begin
	nonzero = (value > 0) ? value : 1;
end
endfunction

	altera_instrumentation_mirror_endpoint #(
        .COUNT          (COUNT),
        .WIDTH          (WIDTH),
        .NODES          (NODES),
        .CLOCKS         (CLOCKS)
) inst (
        .mirror_send    (mirror_send),
        .mirror_receive (mirror_receive)
	
	);

endmodule
