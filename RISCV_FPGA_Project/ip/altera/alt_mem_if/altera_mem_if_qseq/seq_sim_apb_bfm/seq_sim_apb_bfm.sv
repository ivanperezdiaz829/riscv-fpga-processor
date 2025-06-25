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


module seq_sim_apb_bfm #(
	parameter DWIDTH = 32,              
	parameter AWIDTH = 10               
) (
	pclk,
	sp_reset_n,

	paddr,
	psel,
	penable,
	pwrite,
	pwdata,
	pready,
	prdata,
	pslverr
);

	input pclk;
	input sp_reset_n;

	input pslverr;
	input pready;
	input [DWIDTH-1:0] prdata;

	output reg [DWIDTH-1:0] pwdata;
	output reg [AWIDTH-1:0] paddr;
	output reg psel;
	output reg penable;
	output reg pwrite;


task APB_write (input [AWIDTH:0] address, input [DWIDTH:0] data);

	integer waitcycle;

	begin
		paddr = address;
		pwdata = data;
		pwrite = 1'b1;
		psel = 1'b1;
		$display ("APB Write    - address=%2h, data=%2h", paddr, pwdata);
		
		waitcycle = -1;
		@(posedge pclk)
			penable = 1'b1;
		while (~pready) begin
			@(posedge pclk)
				waitcycle = waitcycle + 1;
		end
		
		$display ("Write completed, wait cycles = %2d", waitcycle);
		$display ("=============================================");
		penable = 1'b0;
		pwdata  = 'x;
	end
endtask

task APB_read (reg [AWIDTH:0] address, output reg [DWIDTH:0] data);

	integer waitcycle;

	begin
		paddr = address;
		pwrite = 1'b0;
		$display ("APB Read    - address=%2h", paddr);

		waitcycle = -1;
		@(posedge pclk)
			penable = 1'b1;
		while (~pready) begin
			@(posedge pclk)
				waitcycle = waitcycle + 1;
		end
		
		$display ("Read data = %2h", prdata);
		$display ("Read completed, wait cycles = %2d", waitcycle);
		$display ("=============================================");
		
		data = prdata;

		penable = 1'b0;
	end
endtask




endmodule
