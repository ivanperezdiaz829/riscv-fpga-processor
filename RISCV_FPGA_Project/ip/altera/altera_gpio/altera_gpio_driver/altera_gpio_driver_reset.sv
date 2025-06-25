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

module altera_gpio_driver(
	ck,
	ck_in,
	ck_out,
	ck_fr,
	ck_fr_in,
	ck_fr_out,
	ck_hr,
	ck_hr_in,
	ck_hr_out,
	oe,
	din,
	dout,
	pad_io,
	pad_io_b,
	pad_in,
	pad_in_b,
	pad_out,
	pad_out_b,
	seriesterminationcontrol,
	parallelterminationcontrol,
	aclr,
	aset,
	sclr,
	sset,
	cke
);

	parameter PIN_TYPE = "output"; // input , output , bidir
	parameter BUFFER_TYPE = "single-ended"; // single-ended , differential
	parameter PSEUDO_DIFF = "false"; // false , true
	parameter REGISTER_MODE = "none"; // none , sdr , ddr
	parameter HALF_RATE = "false"; // true , false
	parameter SEPARATE_I_O_CLOCKS = "false"; // true , false
	parameter SIZE = 4;
	parameter ARESET_MODE = "none"; // none, clear, preset
	parameter SRESET_MODE = "none"; // none, clear, preset
	
	localparam OE_SIZE = (HALF_RATE == "true") ? 2 : 1;
	localparam DATA_SIZE = (REGISTER_MODE == "ddr") ? 
			(HALF_RATE == "true") ? 
				4 : 2
			: 1;
			
	localparam RATE = (REGISTER_MODE == "ddr") ? 
			(HALF_RATE == "true") ? 
				4 : 2
			: 1;
	localparam DUT_OE_SIZE = (RATE == 4) ? SIZE * 2 : SIZE;

	localparam DRIVER_WRITE_LATENCY = (REGISTER_MODE == "ddr") ? 
			(HALF_RATE == "true") ? 
				2 : 0
			: (REGISTER_MODE == "sdr") ?
				1 : 0;

	localparam DRIVER_READ_LATENCY = (REGISTER_MODE == "ddr") ? 
			(HALF_RATE == "true") ? 
				3 : 0
			: (REGISTER_MODE == "sdr") ?
				1 : 0;
	
	localparam EXT_DEVICE_DIFFERENTIAL_PAD = (BUFFER_TYPE == "differential") ? "true" : "false";

	localparam TREF = 5000;

	output ck;
	output ck_in;
	output ck_out;
	output ck_fr;
	output ck_fr_in;
	output ck_fr_out;
	output ck_hr;
	output ck_hr_in;
	output ck_hr_out;
	
	// Ports mirror the ALTERA_GPIO for common interface
	output [SIZE * OE_SIZE - 1:0] oe;
	// din to gpio (out from driver)
	output [SIZE * DATA_SIZE - 1:0] din;
	input [SIZE * DATA_SIZE - 1:0] dout;
	output [15:0] seriesterminationcontrol;
	output [15:0] parallelterminationcontrol;
	inout [SIZE - 1:0] pad_io;	
	inout [SIZE - 1:0] pad_io_b;
	output [SIZE - 1:0] pad_in;	
	output [SIZE - 1:0] pad_in_b;
	input [SIZE - 1:0] pad_out;	
	input [SIZE - 1:0] pad_out_b;
	output aclr;
	output aset;
	output sclr;
	output sset;
	output cke;
	
	reg reset_n;
	wire [DUT_OE_SIZE - 1 : 0] data_oe_out;
	wire [SIZE * RATE - 1 : 0] data_out;
	wire [SIZE * RATE - 1 : 0] data_in;
	
	reg ck_ref;
	reg [1:0] ck_counter;
	wire ck_fr_wire;
	wire ck_fr_shifted;
	wire ext_device_capture_ck;
	
	assign oe = data_oe_out;
	assign din = data_out;
	assign data_in = dout;
	assign ck_fr = ck_fr_shifted;
	assign ck_fr_in = ck_fr_shifted;
	assign ck_fr_out = ck_fr_shifted;
	assign ck_hr_in = ck_hr;
	assign ck_hr_out = ck_hr;
	assign ck = ck_fr_shifted;
	assign ck_in = ck_fr_shifted;
	assign ck_out = ck_fr_shifted;
	

	always begin
		#(TREF) ck_ref <= ~ck_ref;
	end

	always @(posedge ck_ref) begin
		ck_counter <= ck_counter - 1'b1;	
	end
	assign ck_fr_wire = ck_counter[0];
	assign ck_hr = ck_counter[1];

	generate
		if(REGISTER_MODE == "ddr") begin
			// In DDR mode, the ALTERA_GPIO FR clock needs to be shifted by 90 degrees
			// The External device capture clock must be shifted by 90 degrees with respect to that
			assign #(TREF / 4) ck_fr_shifted = ck_fr_wire;
			assign #(TREF / 2) ext_device_capture_ck = ck_fr_wire;
		end
		else begin
			assign ck_fr_shifted = ck_fr_wire;
			assign ext_device_capture_ck = ck_fr_wire;
		end
	endgenerate
	
	initial begin
		// $vcdpluson;
		ck_ref <= 0;
		ck_counter <= 0;
		reset_n <= 1;
		#(3*TREF) reset_n <= 0;
		#(3*TREF) reset_n <= 1;
	end

	wire [SIZE - 1 : 0] pad_io;
	generate
		if(PIN_TYPE == "input") begin
			assign pad_in = pad_io;
		end
		else if(PIN_TYPE == "output") begin
			assign pad_io = pad_out;
		end
	endgenerate
	
	driver_reset #(
		.SIZE(SIZE),
		.RATE(RATE),
		.TEST_MODE(PIN_TYPE),
		.TREF(TREF),
		.ARESET_MODE(ARESET_MODE),
		.SRESET_MODE(SRESET_MODE)
	) driver_i (
		.ck_fr(ck_fr_wire),
		.ck_hr(ck_hr),
		.reset_n(reset_n),
		.data_oe_out(data_oe_out),
		.data_out(data_out),
		.data_in(data_in),
		.pad(pad_io),
		.aclr(aclr),
		.aset(aset),
		.sclr(sclr),
		.sset(sset)
	);

endmodule
