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


`timescale 1ps/1ps

module hc_rom_reconfig_gen (hc_rom_config_clock, hc_rom_config_datain, hc_rom_config_rom_data_ready, hc_rom_config_init, hc_rom_config_init_busy, hc_rom_config_rom_rden, hc_rom_config_rom_address, soft_reset_n);

	parameter INIT_FILE = "";
	parameter ROM_ADDRESS_WIDTH = 13;

	output reg hc_rom_config_clock;
	output [31:0] hc_rom_config_datain;
	output hc_rom_config_rom_data_ready;
	output reg hc_rom_config_init;
	input hc_rom_config_init_busy;
	input hc_rom_config_rom_rden;
	input [ROM_ADDRESS_WIDTH-1:0] hc_rom_config_rom_address;
	output reg soft_reset_n;

	//synthesis translate_off

	initial
	begin
		hc_rom_config_clock <= 1'b0;
	end
	
	always #(250/2) hc_rom_config_clock <= ~hc_rom_config_clock;
	
	
	// Instantiate the sequencer_mem as if it was an external ROM

  altsyncram hc_rom
    (
      .address_a (hc_rom_config_rom_address),
      .byteena_a (4'b1),
      .clock0 (hc_rom_config_clock),
      .clocken0 (1'b1),
      .data_a (),
      .q_a (hc_rom_config_datain),
      .wren_a (1'b0)
    );

  defparam hc_rom.byte_size = 8,
           hc_rom.init_file = INIT_FILE,
           hc_rom.lpm_type = "altsyncram",
           hc_rom.maximum_depth = (1<<ROM_ADDRESS_WIDTH),
           hc_rom.operation_mode = "SINGLE_PORT",
           hc_rom.outdata_reg_a = "UNREGISTERED",
           hc_rom.ram_block_type = "AUTO",
           hc_rom.read_during_write_mode_mixed_ports = "DONT_CARE",
           hc_rom.width_a = 32,
           hc_rom.width_byteena_a = 4,
           hc_rom.widthad_a = ROM_ADDRESS_WIDTH; 



	
	// Wait for the PLL to lock then program the NIOS ROM
	initial begin
		soft_reset_n <= 1'b0;
		hc_rom_config_init <= 1'b0;
		repeat (100) @hc_rom_config_clock;
		$display("[%0t] %m: Starting NIOS ROM configuration",$time);
		hc_rom_config_init <= 1'b1;
		repeat (2) @hc_rom_config_clock;
		hc_rom_config_init <= 1'b0;
		repeat (2) @hc_rom_config_clock;
		wait (!hc_rom_config_init_busy);
		$display("[%0t] %m: NIOS ROM configuration complete",$time);
		repeat (2) @hc_rom_config_clock;
		soft_reset_n <= 1'b1;
	end
	
		assign hc_rom_config_rom_data_ready = 1'b1;


	//synthesis translate_on

endmodule

