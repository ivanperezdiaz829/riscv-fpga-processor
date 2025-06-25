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

module driver(
	ck_fr,
	ck_hr,
	reset_n,
	data_oe_out,
	data_out,
	data_in,
	data_write,
	data_read,
	side_out,
	side_in,
	side_write,
	side_read
);
	parameter SIZE = 4;
	parameter RATE = 1;
	parameter WRITE_LATENCY = 0;
	parameter READ_LATENCY = 0;
	parameter TEST_MODE = "output";
	parameter BUS_WIDTH = 0;
	parameter USE_GND_VCC = "FALSE";
	parameter [SIZE*RATE-1:0] GND_VCC_BUS = 0;

	localparam DUT_DATA_SIZE = SIZE * RATE;
	localparam DUT_OE_SIZE = (RATE == 4) ? SIZE * 2 : SIZE;
	localparam BUFFER_ADDRESS_SIZE = 5;

	// Clock / Reset interface
	input ck_fr;
	input ck_hr;
	input reset_n;

	// Dut interface
	output reg [DUT_OE_SIZE - 1 : 0] data_oe_out;
	output reg [DUT_DATA_SIZE - 1 : 0] data_out;
	input [DUT_DATA_SIZE - 1 : 0] data_in;
	output data_write;
	output reg data_read;

	// Side interface
	output reg [DUT_DATA_SIZE - 1 : 0] side_out;
	input [DUT_DATA_SIZE - 1 : 0] side_in;
	output reg side_write;
	output reg side_read;

	reg data_write_int;

	reg [DUT_DATA_SIZE - 1 : 0] data;

	reg [DUT_DATA_SIZE - 1 : 0] buffer [0:(1 << BUFFER_ADDRESS_SIZE)];
	reg [BUFFER_ADDRESS_SIZE - 1 : 0] buffer_read_address;
	reg [BUFFER_ADDRESS_SIZE - 1 : 0] buffer_write_address;

	reg [DUT_DATA_SIZE - 1 : 0] random_data;

	wire ck_dut = (RATE == 1 || RATE == 2) ? ck_fr : ck_hr;
	wire ck_side = ck_fr;

	wire [DUT_DATA_SIZE-1:0] gnd_mask;
	wire [DUT_DATA_SIZE-1:0] vcc_mask;
	// Assign "random" gnds and vccs
	genvar i;
	generate
		for (i = 0; i < DUT_DATA_SIZE; i++) begin : gnd_vcc_loop
			if (USE_GND_VCC == "TRUE" && GND_VCC_BUS[i] == 1) begin
				assign gnd_mask[i] = (i%2);
				assign vcc_mask[i] = (i%2);
			end else begin
				assign gnd_mask[i] = 1;
				assign vcc_mask[i] = 0;
			end
		end
	endgenerate

	// Main Operation Sequence
	generate
		initial begin: test_main
			data <= 0;
			data_oe_out <= 0;
			data_out <= 0;
			data_write_int <= 0;
			data_read <= 0;
			side_out <= 0;
			side_write <= 0;
			side_read <= 0;
			buffer_write_address <= 0;

			if(TEST_MODE == "output") begin
				sleep(5);
				write_burst_to_dut(4);
				sleep(5);
				read_burst_from_side(4);
				sleep(5);
				write_burst_to_side(2);
				sleep(5);
				read_burst_from_side(2);
			end
			else if(TEST_MODE == "input") begin
				sleep(5);
				write_burst_to_side(8);
				sleep(5);
				read_burst_from_dut(3);
				sleep(5);
				read_burst_from_side(2);
			end
			else begin // TEST_MODE == "bidir"
				sleep(5);
				write_burst_to_dut(4);
				sleep(5);
				read_burst_from_dut(3);
				sleep(5);
				write_burst_to_dut(3);
				sleep(5);
				read_burst_from_dut(4);
			end
	
			// Make sure you give any transient enough time to complete
			sleep(20);
	
			print_report_and_finish;
	end
	endgenerate

	// Data Read Latency
	wire data_read_int;
	latency_block #(
		.LATENCY(READ_LATENCY)
	) latency_block_data_read (
		.clk(ck_fr),
		.reset_n(reset_n),
		.D(data_read),
		.Y(data_read_int)
	);

	// Data Write Latency
	latency_block #(
		.LATENCY(WRITE_LATENCY)
	) latency_block_data_write (
		.clk(ck_fr),
		.reset_n(reset_n),
		.D(data_write_int),
		.Y(data_write)
	);

	// Random data generation
	always @(posedge ck_fr) begin
		random_data <= $random;
	end

	// Check Process
	wire read_enable = (side_read | data_read_int);
	reg [DUT_DATA_SIZE - 1 : 0] data_received;
	reg [DUT_DATA_SIZE - 1 : 0] data_expected;
	reg perform_read_check;
	always @(posedge ck_fr or negedge reset_n) begin
		if(~reset_n) begin
			perform_read_check <= 1'b0;
			buffer_read_address <= 0;
		end
		else begin
			if(read_enable) begin
				data_received <= (side_read) ? side_in : data_in;
				data_expected <= buffer[buffer_read_address];
				perform_read_check <= 1'b1;
				// In HR during DUT read, we need to increment the address
				// only half the time
				if(data_read_int && (RATE == 4)) begin
					if(~ck_hr) begin
						buffer_read_address <= buffer_read_address + 1;
					end
				end
				else begin
					buffer_read_address <= buffer_read_address + 1;
				end
			end
			else begin
				perform_read_check <= 1'b0;
			end
		end
	end

	reg [31:0] data_correct;
	reg [31:0] data_wrong;
	always @(posedge ck_fr or negedge reset_n) begin
		if(~reset_n) begin
			data_correct <= 0;
			data_wrong <= 0;
		end
		else begin
			if(perform_read_check) begin
				if(data_received == data_expected) begin
					data_correct <= data_correct + 1;
				end
				else begin
					data_wrong <= data_wrong + 1;
				end
			end
		end
	end

	// TASK: sleep
	task sleep(reg [7:0] cycles);
		repeat(cycles) begin
			@(posedge ck_fr);
		end
	endtask
	
	// TASK: write_burst_to_dut
	task write_burst_to_dut(reg [7:0] burst_size);
		repeat(burst_size) begin
			@(posedge ck_dut) begin
				// This can be randomized later on
				data_oe_out <= {DUT_OE_SIZE{1'b1}};
				data_out <= random_data;
				data_write_int <= 1'b1;
				buffer[buffer_write_address] <= ((random_data & gnd_mask) | vcc_mask);
				buffer_write_address <= buffer_write_address + 1;
			end
		end
		@(posedge ck_dut) begin
			data_write_int <= 1'b0;
			data_oe_out <= {DUT_OE_SIZE{1'b0}};
		end
    endtask

	// TASK: read_burst_from_dut
	task read_burst_from_dut(reg [7:0] burst_size);
		repeat(burst_size) begin
			@(posedge ck_dut) begin
				data_read <= 1'b1;
			end
		end
		@(posedge ck_dut) begin
			data_read <= 1'b0;
		end
    endtask

	// TASK: write_burst_to_side
	task write_burst_to_side(reg [7:0] burst_size);
		repeat(burst_size) begin
			@(posedge ck_side) begin
				side_out <= random_data;
				side_write <= 1'b1;
				buffer[buffer_write_address] <= random_data;
				buffer_write_address <= buffer_write_address + 1;
			end
		end
		@(posedge ck_side) begin
			side_write <= 1'b0;
		end
    endtask

	// TASK: read_burst_from_side
	task read_burst_from_side(reg [7:0] burst_size);
		repeat(burst_size) begin
			@(posedge ck_side) begin
				side_read <= 1'b1;
			end
		end
		@(posedge ck_side) begin
			side_read <= 1'b0;
		end
    endtask

	// TASK: print_report_and_finish
	task print_report_and_finish;
		if((data_correct > 0) && (data_wrong == 0)) begin
			$display("");
			$display("SIMULATION COMPLETED: SUCCESS ! ! !");
			$display("");
		end
		else begin
			$display("");
			$display("SIMULATION COMPLETED: FAILED ! ! !");
			$display("");
		end
		$display("Stats:");
		$display("   Correct Data: %d", data_correct);
		$display("   Wrong Data: %d", data_wrong);

		$finish;
	endtask

endmodule

module latency_block(
	clk,
	reset_n,
	D,
	Y
);

	input clk;
	input reset_n;
	input D;
	output Y;

	parameter LATENCY = 0;

	genvar i;
	generate
		begin
			if(LATENCY == 0) begin
				assign Y = D;
			end
			else if(LATENCY == 1) begin
				reg stage;
				always @(posedge clk or negedge reset_n) begin
					if(~reset_n) begin
						stage <= 1'b0;
					end
					else begin
						stage <= D;		
					end
				end
				assign Y = stage;
			end
			else begin
				reg stages[LATENCY - 1 : 0];
				for(i = 0; i < LATENCY - 1; i = i + 1) 
				begin : latency_loop
					always @(posedge clk or negedge reset_n) begin
						if(~reset_n) begin
							stages[i] <= 1'b0;
						end
						else begin
							stages[i] <= stages[i + 1];
						end
					end
				end
				always @(posedge clk or negedge reset_n) begin
					if(~reset_n) begin
						stages[LATENCY - 1] <= 1'b0;
					end
					else begin
						stages[LATENCY - 1] <= D;
					end
				end
				assign Y = stages[0];
			end
		end
	endgenerate

endmodule

