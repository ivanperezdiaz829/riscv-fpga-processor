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


//////////////////////////////////////////////////////////////////////////////
// The bank timer module keeps track of the bank cycle time (tRC) requirement
// for a single bank.  The timer is reset when 'do_access' is asserted.
// 'can_access' goes high when the timer is expired.
//////////////////////////////////////////////////////////////////////////////

`timescale 1 ps / 1 ps

module alt_rld_bank_timer(
	clk,
	reset_n,
	do_access,
	can_access
);

//////////////////////////////////////////////////////////////////////////////
// BEGIN PARAMETER SECTION

// tRC in controller cycles
parameter CTL_T_RC	= 0;

// END PARAMETER SECTION
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// BEGIN LOCALPARAM SECTION

// tRC timer reset value
// Subtract two cycles to compensate for latency with the FSM
localparam TIMER_RESET_VALUE	= CTL_T_RC - 2;
// The width of the tRC timer
localparam TIMER_WIDTH			= max(1, ceil_log2(TIMER_RESET_VALUE + 1));

// END LOCALPARAM SECTION
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// BEGIN PORT SECTION

input	clk;
input	reset_n;
input	do_access;
output	can_access;

// END PORT SECTION
//////////////////////////////////////////////////////////////////////////////

reg	[TIMER_WIDTH-1:0]	timer;
reg can_access;

// Timer logic
always_ff @(posedge clk or negedge reset_n)
begin
	if (!reset_n) begin
		timer <= TIMER_RESET_VALUE[TIMER_WIDTH-1:0];
		can_access <= (TIMER_RESET_VALUE[TIMER_WIDTH-1:0] == 0);
	end else begin
		if (do_access) begin
			timer <= TIMER_RESET_VALUE[TIMER_WIDTH-1:0];
			can_access <= (TIMER_RESET_VALUE[TIMER_WIDTH-1:0] == 0);
		end else if (timer != 0) begin
			timer <= timer - 1'b1;
			can_access <= (timer == 1);
		end else begin
			can_access <= (timer == 0);
		end
	end
end


// Returns the maximum of two numbers
function integer max;
	input integer a;
	input integer b;
	begin
		max = (a > b) ? a : b;
	end
endfunction


// Calculate the ceiling of log_2 of the input value
function integer ceil_log2;
	input integer value;
	begin
		value = value - 1;
		for (ceil_log2 = 0; value > 0; ceil_log2 = ceil_log2 + 1)
			value = value >> 1;
	end
endfunction


// Simulation assertions
// synthesis translate_off
initial
begin
	assert (CTL_T_RC > 0) else $error ("Invalid tRC");
end

always_ff @(posedge clk)
begin
	if (reset_n)
	begin
		if (!can_access)
			assert (!do_access) else $error ("tRC requirement violation");
	end
end
// synthesis translate_on


endmodule

