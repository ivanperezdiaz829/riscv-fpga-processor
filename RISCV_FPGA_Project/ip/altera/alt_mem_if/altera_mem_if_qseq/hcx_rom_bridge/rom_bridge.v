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


module rom_bridge (
	write_clock,
	soft_reset_n,

	rom_address,
	rom_data,
	rom_rden,
	init,
	rom_data_ready,
	init_busy,

	avlm_address,
	avlm_writedata,
	avlm_wren,
	avlm_waitrequest
	);

parameter AVL_DATA_WIDTH = 32;
parameter AVL_ADDR_WIDTH = 14;
parameter ROM_SIZE = 0;

input          write_clock;
input          soft_reset_n;

output   [AVL_ADDR_WIDTH-1:0] rom_address;
input   [AVL_DATA_WIDTH-1:0] rom_data;
output         rom_rden;
input          init;
input          rom_data_ready;
output         init_busy;

output  [AVL_ADDR_WIDTH+2-1:0] avlm_address;
output  [AVL_DATA_WIDTH-1:0] avlm_writedata;
output         avlm_wren;
input          avlm_waitrequest;


wire [AVL_ADDR_WIDTH-1:0] actual_raminit_address;

assign avlm_address = {actual_raminit_address,2'b0};

sequencer_raminit raminit (
    .clock(write_clock),    
    .datain(rom_data),
    .init(init),
    .rom_data_ready(rom_data_ready),
    .dataout(avlm_writedata),
    .init_busy(init_busy),
    .ram_address(actual_raminit_address),
    .ram_wren(avlm_wren),
    .rom_address(rom_address),
    .rom_rden(rom_rden));
defparam raminit.MEM_SIZE = ROM_SIZE;

endmodule
