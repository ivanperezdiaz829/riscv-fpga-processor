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


module altera_avalon_passthru_core(
	avalon_clock,
	avalon_address,
	avalon_read,
	avalon_readdata,
	avalon_write,
	avalon_writedata,
	avalon_byteenable,
	avalon_waitrequest,
	avalon_arbiterlock,
	avalon_readdatavalid,
	avalon_flush,
	avalon_burstcount,
	avalon_resetrequest,

	export_clock,
	export_address,
    export_read,
    export_readdata,
    export_write,
    export_writedata,
    export_byteenable,
    export_waitrequest,
  	export_arbiterlock,
    export_readdatavalid,
	export_flush,
	export_burstcount,
    export_resetrequest
);
	parameter WORD_SIZE = 8;
	parameter DATA_WIDTH = 32;
    parameter AVL_ADDRESS_WIDTH = 34;
    localparam BYTEENABLE_WIDTH = DATA_WIDTH/WORD_SIZE;
	parameter BURSTCOUNT_WIDTH = 1;

	output avalon_clock;
	input export_clock;
	//assign export_clock = avalon_clock;
	assign avalon_clock = export_clock;

    output [AVL_ADDRESS_WIDTH-1:0] avalon_address;
    input [AVL_ADDRESS_WIDTH-1:0] export_address;
	assign avalon_address = export_address;
	
	output avalon_read;
	input export_read;
	assign avalon_read = export_read;

	input [DATA_WIDTH-1:0] avalon_readdata;
	output [DATA_WIDTH-1:0] export_readdata;
	assign export_readdata = avalon_readdata;
    
   	output avalon_write;
	input export_write;
	assign avalon_write = export_write;

	output [DATA_WIDTH-1:0] avalon_writedata;
	input [DATA_WIDTH-1:0] export_writedata;
	assign avalon_writedata = export_writedata;

	output [BYTEENABLE_WIDTH-1:0] avalon_byteenable;
	input [BYTEENABLE_WIDTH-1:0] export_byteenable;
	assign avalon_byteenable = export_byteenable;    

    input avalon_waitrequest;
    output export_waitrequest;
	assign export_waitrequest = avalon_waitrequest;

	output avalon_arbiterlock;
	input export_arbiterlock;
	assign avalon_arbiterlock = export_arbiterlock;

	input avalon_readdatavalid;
    output export_readdatavalid;
	assign export_readdatavalid = avalon_readdatavalid;

	output avalon_flush;
	input export_flush;
	assign avalon_flush = export_flush;

   	output  [BURSTCOUNT_WIDTH-1:0] avalon_burstcount;
   	input  [BURSTCOUNT_WIDTH-1:0] export_burstcount;
	assign avalon_burstcount = export_burstcount;

    output avalon_resetrequest;
    input export_resetrequest;
	assign avalon_resetrequest = export_resetrequest;

endmodule	
