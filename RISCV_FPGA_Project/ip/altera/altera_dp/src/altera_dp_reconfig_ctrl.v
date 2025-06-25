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


// *********************************************************************
//
// DisplayPort Reconfig Manager
// 
// Description:
// 
// This module manages the handshaking with the external transciever
// recofig controller. It will asynchronously detect a reconfig
// trigger and capture data for the reconfiguration. 
//
// It will then wait it's turn to request a reconfiguration and then 
// report it is ready once the reconfig controller has ack'ed its
// request. 
//
// Warning: this does not wait for the reconfig to complete before
// calling itself ready. The top-level design must synchronize the
// requests by watching the different reconfig busy signals
//
// *********************************************************************

`timescale 1 ps / 1 ps

module altera_dp_reconfig_ctrl # (
	parameter	WIDTH = 1
)(
	input wire clk,
	input wire reset,
	input wire trigger,
	input wire [WIDTH-1:0] din,
	output reg [WIDTH-1:0] dout,
	input wire ready,
	input wire ack,
	input wire busy,
	output reg req,
	output reg done
);

// State variables
localparam 	WAIT_FOR_TRIGGER	= 0,
			WAIT_FOR_READY		= 1,
			WAIT_FOR_ACK		= 2,
			WAIT_FOR_BUSY_LOW	= 3;

reg [1:0] state;

always @(posedge clk or posedge reset) begin
	if (reset)
	begin
		state	<= WAIT_FOR_TRIGGER;
		req		<= 1'b0;
		done	<= 1'b0;
		dout	<= {WIDTH{1'b0}};
	end
	else
	begin
		case (state)
		WAIT_FOR_TRIGGER:
			// If we see a trigger then latch the data get a reconfig
			// into the queue
			if (trigger)
			begin
				dout	<= din;
				done	<= 1'b0;
				state	<= WAIT_FOR_READY;
			end

		WAIT_FOR_READY:
			// When we get reconfig slot make a request
			if (ready)
			begin
				req		<= 1'b1;
				state	<= WAIT_FOR_ACK;
			end

		WAIT_FOR_ACK:
			// When be get ack'ed clear the req and wait for the busy
			// signal to clear
			if (ack)
			begin
				req		<= 1'b0;
				state	<= WAIT_FOR_BUSY_LOW;
			end

		WAIT_FOR_BUSY_LOW:
			// When busy de-asserts set done and go back to wait for
			// another trigger
			if (!busy)
			begin
				done	<= 1'b1;
				state	<= WAIT_FOR_TRIGGER;
			end
		endcase
	end
end



endmodule
