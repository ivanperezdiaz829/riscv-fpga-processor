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

module driver_reset(
	ck_fr,
	ck_hr,
	reset_n,
	data_oe_out,
	data_out,
	data_in,
	pad,
	aclr,
	aset,
	sclr,
	sset
);
	parameter SIZE = 4;
	parameter RATE = 1;
	parameter TEST_MODE = "output";
	parameter TREF = 5000;
	parameter ARESET_MODE = "none"; // none, clear, preset
	parameter SRESET_MODE = "none"; // none, clear, preset

	localparam DUT_DATA_SIZE = SIZE * RATE;
	localparam DUT_OE_SIZE = (RATE == 4) ? SIZE * 2 : SIZE;

	localparam ACLR_ACTIVE_VALUE = 1'b1;
	localparam SCLR_ACTIVE_VALUE = 1'b1;

	localparam ARESET_VALUE = (ARESET_MODE == "preset") ? 1'b1 : 1'b0;
	localparam SRESET_VALUE = (SRESET_MODE == "preset") ? 1'b1 : 1'b0;

	localparam CHECK_DATA = 1'b0;
	localparam CHECK_PAD = 1'b1;

	// Clock / Reset interface
	input ck_fr;
	input ck_hr;
	input reset_n;

	// Dut interface
	output reg [DUT_OE_SIZE - 1 : 0] data_oe_out;
	output reg [DUT_DATA_SIZE - 1 : 0] data_out;
	input [DUT_DATA_SIZE - 1 : 0] data_in;

	inout [SIZE - 1:0] pad;	

	output reg aclr;
	output reg aset;
	output reg sclr;
	output reg sset;

	reg [SIZE - 1 : 0] pad_internal;
	reg drive_pad;

	assign pad = (drive_pad) ? pad_internal : {SIZE{1'bz}};

	reg data_write_int;

	wire ck_dut = (RATE == 1 || RATE == 2) ? ck_fr : ck_hr;

	reg [7:0] data_correct;
	reg [7:0] data_wrong;

	// Main Operation Sequence
	initial begin: test_main
		data_correct <= 0;
		data_wrong <= 0;
		data_oe_out <= 0;
		data_out <= 0;
		data_write_int <= 0;
		aclr <= ~ACLR_ACTIVE_VALUE;
		aset <= ~ACLR_ACTIVE_VALUE;
		sclr <= ~SCLR_ACTIVE_VALUE;
		sset <= ~SCLR_ACTIVE_VALUE;
		drive_pad <= 0;
		pad_internal <= 0;

		if(TEST_MODE == "output" || TEST_MODE == "bidir") begin
			release_pad_control();

			// Check areset
			if(ARESET_MODE == "clear" || ARESET_MODE == "preset") begin
				set_data_value(~ARESET_VALUE);
				sleep(20);
				assert_aclr_and_check(CHECK_PAD, ARESET_VALUE);
				sleep(20);
			end

			// Check sreset
			if(SRESET_MODE == "clear" || SRESET_MODE == "preset") begin
				set_data_value(~SRESET_VALUE);
				sleep(20);
				assert_sclr_and_check(CHECK_PAD, SRESET_VALUE);
			end
		end

		sleep(20);

		if(TEST_MODE == "input" || TEST_MODE == "bidir") begin
			take_pad_control();

			// Check areset
			if(ARESET_MODE == "clear" || ARESET_MODE == "preset") begin
				set_pad_value(~ARESET_VALUE);
				sleep(20);
				assert_aclr_and_check(CHECK_DATA, ARESET_VALUE);
				sleep(20);
			end

			// Check sreset
			if(SRESET_MODE == "clear" || SRESET_MODE == "preset") begin
				set_pad_value(~SRESET_VALUE);
				sleep(20);
				assert_sclr_and_check(CHECK_DATA, SRESET_VALUE);
			end
		end

		// Let it run a bit longer to avoid chopping any interesting waveform
		sleep(20);
	
		print_report_and_finish;
	end

	// Check Process

	// TASK: sleep
	task sleep(reg [7:0] cycles);
		repeat(cycles) begin
			@(posedge ck_fr);
		end
	endtask

	// TASK: take_pad_control
	task take_pad_control;
			data_oe_out <= {DUT_OE_SIZE{1'b0}};
			drive_pad <= 1;
	endtask

	// TASK: release_pad_control
	task release_pad_control;
			data_oe_out <= {DUT_OE_SIZE{1'b1}};
			drive_pad <= 0;
	endtask

	// TASK: set_data_value
	task set_data_value(reg value);
		@(posedge ck_dut);
			data_out <= {DUT_DATA_SIZE{value}};
	endtask

	task set_pad_value(reg value);
		@(posedge ck_dut);
			pad_internal <= {SIZE{value}};
	endtask

	// TASK: assert_aclr_and_check
	task assert_aclr_and_check(reg check_what, reg value);
		@(posedge ck_dut);
			// Make this "asynchronous"
			#(TREF * 0.123)
				aclr <= ACLR_ACTIVE_VALUE;
				aset <= ACLR_ACTIVE_VALUE;
		fork 
			begin
				// This is an asynchronous reset: check right away (give it
				// some time to settle in case the sim model has some delay)
				#(TREF * 0.1)
					check(check_what, ARESET_VALUE);
			end
			begin
				repeat(3)
					@(posedge ck_dut);
				// Make this "asynchronous"
				#(TREF * 0.123)
					aclr <= ~ACLR_ACTIVE_VALUE;
					aset <= ~ACLR_ACTIVE_VALUE;
			end
		join
	endtask
	
	// TASK: assert_sclr_and_check
	task assert_sclr_and_check(reg check_what, reg value);
		@(posedge ck_dut);
			sclr <= SCLR_ACTIVE_VALUE;
			sset <= SCLR_ACTIVE_VALUE;
		fork
			begin
				repeat(3)
					@(posedge ck_dut);
				sclr <= ~SCLR_ACTIVE_VALUE;
				sset <= ~SCLR_ACTIVE_VALUE;
			end
			begin
				// This is a synchronous reset: wait for a couple clocks to
				// give it time to propagate to the output in all cases plus
				// some time to settle in case the sim model has some delay)
				repeat(2)
					@(posedge ck_dut);
				#(TREF * 0.1)
					check(check_what, SRESET_VALUE);
			end
		join
	endtask

	task check(reg check_what, reg value);
		reg [SIZE - 1 : 0] expected_value;
		if(check_what == CHECK_DATA) begin
			expected_value = data_in;
		end
		else begin
			expected_value = pad;
		end
		if(expected_value == {SIZE{value}}) begin
			data_correct <= data_correct + 1;
		end
		else begin
			$display("Error @ %t ", $time);
			$display("   Expected: %h ", expected_value);
			$display("   Detected: %h ", {SIZE{value}});
			data_wrong <= data_wrong + 1;
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
