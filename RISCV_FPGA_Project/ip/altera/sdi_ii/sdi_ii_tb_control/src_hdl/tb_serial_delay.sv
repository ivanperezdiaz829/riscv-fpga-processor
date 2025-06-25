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


`timescale 100 fs / 100 fs
`define tdisplay(MYSTRING) $display("%t:%s \n", $time,  MYSTRING)

module tb_serial_delay
(
    //--------------------------------------------------------------------------
    // port list
    //--------------------------------------------------------------------------
    sdi_serial,
    serial_delayed
);

    input sdi_serial;
    output reg serial_delayed;

    parameter dl_synctest = 1'b0;
    parameter serial_dlytest = 1'b0;

    integer i;
    reg enable=1'b0;
    wire tx_serial;
	
    assign tx_serial = sdi_serial;
		
    always @ (*)
    begin
      enable <= 1'b1;
      serial_delayed <= #i tx_serial; 
    end
	
    always @ (enable)
    begin
      if (dl_synctest || serial_dlytest) begin
	i = $urandom_range(50000,50000);
      end
      else begin
	i = $urandom_range(200000,50000);
      end
	$display("Simulation will use TX with serial delay of :%d",i);
    end

endmodule
 


