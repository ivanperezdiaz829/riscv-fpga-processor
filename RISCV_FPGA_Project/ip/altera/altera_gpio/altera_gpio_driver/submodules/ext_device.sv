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

module ext_device(
	ck_fr,
	ddr_capture_ck,
	reset_n,
	data_pad,
	data_pad_b,
	data_write,
	data_read,
	side_out,
	side_in,
	side_write,
	side_read
);
	parameter RATE = 1;
	parameter SIZE = 4;
	parameter DDR_MODE = "false";
	parameter DATA_READ_LATENCY_CYCLE = "false";
	parameter USE_DIFFERENTIAL_PAD = "false";

	localparam BUFFER_ADDRESS_SIZE = 5;
	localparam BUFFER_DATA_ADDRESS_INCREMENT = (DDR_MODE == "true") ? 2 : 1;
	
	localparam SIDE_DATA_SIZE = RATE * SIZE;

	// Clock / Reset interface
	input ck_fr;
	input ddr_capture_ck;
	input reset_n;

	// Dut interface
	inout [SIZE - 1 : 0] data_pad;
	inout [SIZE - 1 : 0] data_pad_b;
	input data_write;
	input data_read;

	// Side interface
	output [SIDE_DATA_SIZE - 1 : 0] side_out;
	input [SIZE * 4 - 1 : 0] side_in;
	input side_write;
	input side_read;

	reg [SIZE - 1 : 0] buffer [0:(1 << BUFFER_ADDRESS_SIZE)];
	reg [BUFFER_ADDRESS_SIZE - 1 : 0] buffer_read_address;
	reg [BUFFER_ADDRESS_SIZE - 1 : 0] buffer_write_address;

	reg [SIZE - 1 : 0] ddr_capture_l_data;
	reg [SIZE - 1 : 0] ddr_capture_h_data;

	// Differential input
	wire [SIZE - 1 : 0] data_pad_int;
	generate
		begin
			if(USE_DIFFERENTIAL_PAD == "true") begin
				// Force 'z' when differential data is inconsistent
				assign data_pad_int = (data_pad == ~data_pad_b) ? data_pad : {SIZE{1'bz}};
			end
			else begin
				assign data_pad_int = data_pad;
			end
		end
	endgenerate

	// Optional latency on data_read
	// May be required to align to HR reads
	wire data_read_i;
	reg data_read_r;
	generate
		begin : data_read_cycle
			if(DATA_READ_LATENCY_CYCLE) begin
				always @(posedge ck_fr) begin
					data_read_r <= data_read;
				end
				assign data_read_i = data_read_r;
			end
			else begin
				assign data_read_i = data_read;
			end
		end
	endgenerate

	// Buffer R/W Address
	always @(posedge ck_fr or negedge reset_n) begin
		if(~reset_n) begin
			buffer_read_address <= 0;
			buffer_write_address <= 0;
		end
		else begin
			if(data_read_i) begin
				buffer_read_address <= buffer_read_address + BUFFER_DATA_ADDRESS_INCREMENT;
			end
			else if(side_read) begin
				buffer_read_address <= buffer_read_address + RATE;
			end

			if(data_write) begin
				buffer_write_address <= buffer_write_address + BUFFER_DATA_ADDRESS_INCREMENT;
			end
			else if(side_write) begin
				buffer_write_address <= buffer_write_address + RATE;
			end
		end
	end

	// Buffer Write
	generate
		always @(posedge ck_fr) begin
			if(data_write) begin
				if(DDR_MODE == "true") begin
					buffer[buffer_write_address] = ddr_capture_l_data;
					buffer[buffer_write_address + 1] = ddr_capture_h_data;
				end
				else begin
					buffer[buffer_write_address] = data_pad_int;
				end
			end
			else if(side_write) begin
				if(RATE == 4) begin
					buffer[buffer_write_address] = side_in[SIZE - 1 : 0];
					buffer[buffer_write_address + 1] = side_in[2 * SIZE - 1 : SIZE];
					buffer[buffer_write_address + 2] = side_in[3 * SIZE - 1 : 2 * SIZE];
					buffer[buffer_write_address + 3] = side_in[4 * SIZE - 1 : 3 * SIZE];
				end
				else if(RATE == 2) begin
					buffer[buffer_write_address] = side_in[SIZE - 1 : 0];
					buffer[buffer_write_address + 1] = side_in[2 * SIZE - 1 : SIZE];
				end
				else begin
					buffer[buffer_write_address] = side_in;
				end
			end
		end
	endgenerate

	// Buffer Write
	wire [SIZE - 1 : 0] data_out;
	generate
		begin : buffer_write
			reg [SIZE - 1 : 0] data_out_reg;
			if(DDR_MODE == "true") begin
				assign data_out = ck_fr ? buffer[buffer_read_address] : buffer[buffer_read_address + 1];
			end
			else begin
				assign data_out = buffer[buffer_read_address];
			end
		end
	endgenerate

	generate
		begin : side_out_gen
			if(RATE == 1) begin
				assign side_out = buffer[buffer_read_address];
			end
			else if(RATE == 2) begin
				assign side_out = {
					buffer[buffer_read_address + 1],
					buffer[buffer_read_address]
				};
			end
			else begin // RATE == 4
				assign side_out = {
					buffer[buffer_read_address + 3],
					buffer[buffer_read_address + 2],
					buffer[buffer_read_address + 1],
					buffer[buffer_read_address]
				};
			end
		end
	endgenerate
	assign data_pad = data_read_i ? data_out : {SIZE{1'bz}};
	generate
		if(USE_DIFFERENTIAL_PAD == "true") begin
			assign data_pad_b = data_read_i ? ~data_out : {SIZE{1'bz}};
		end
		else begin
			assign data_pad_b = {SIZE{1'bz}};
		end
	endgenerate

	// DDR capture
	always @(posedge ddr_capture_ck or negedge ddr_capture_ck) begin
		if(ddr_capture_ck) begin
			ddr_capture_l_data = data_pad_int;
		end
		else begin
			ddr_capture_h_data = data_pad_int;
		end
	end

endmodule
