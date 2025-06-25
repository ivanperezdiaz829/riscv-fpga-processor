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
// only depends on address, actual type of requests (read or write) is not considered
//////////////////////////////////////////////////////////////////////////////

`timescale 1 ps / 1 ps

module memctl_burst_adapter(
	clk,
	reset_n,
	do_command,
	merge_command,
	cmd0_addr,
	cmd1_addr,
	write_latency,
	can_merge_cmd0,
	can_merge_cmd1
);

//////////////////////////////////////////////////////////////////////////////
// BEGIN PARAMETER SECTION

parameter BURST_LENGTH			= 0;
parameter ADDR_WIDTH			= 0;
parameter BEATADDR_WIDTH		= 0;
parameter WRITE_LATENCY_WIDTH	= 0;
parameter MAX_WRITE_LATENCY		= 0;

// END PARAMETER SECTION
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// BEGIN LOCALPARAM SECTION

localparam TIMER_WIDTH = max(WRITE_LATENCY_WIDTH, ceil_log2(MAX_WRITE_LATENCY + BURST_LENGTH));
localparam WDATA_FIFO_LATENCY = 1;

// END LOCALPARAM SECTION
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// BEGIN PORT SECTION

// Clock and reset interface
input									clk;
input									reset_n;

// State machine command outputs
input									do_command;
input									merge_command;

input	[ADDR_WIDTH-1:0]				cmd0_addr;
input	[ADDR_WIDTH-1:0]				cmd1_addr;
input	[WRITE_LATENCY_WIDTH-1:0]		write_latency;
output									can_merge_cmd0;
output									can_merge_cmd1;

// END PORT SECTION
//////////////////////////////////////////////////////////////////////////////

// The timer stores the number of elapsed cycles since the last do_command
reg		[TIMER_WIDTH-1:0]				timer;

// last_addr_reg stores the address of the last issued command
reg		[ADDR_WIDTH-1:0]				last_addr_reg;

// last_burst_addr is the address stored in last_addr_reg with the beat addrress masked out
// last_beat_addr is the beat address of the last issued command
wire	[ADDR_WIDTH-BEATADDR_WIDTH-1:0]	last_burst_addr;
wire	[BEATADDR_WIDTH-1:0]			last_beat_addr;

// burst_addr is the address of the current pending command with the beat addrress masked out
// beat_addr is the beat address of the current pending command
wire	[ADDR_WIDTH-BEATADDR_WIDTH-1:0]	cmd0_burst_addr;
wire	[BEATADDR_WIDTH-1:0]			cmd0_beat_addr;
wire	[ADDR_WIDTH-BEATADDR_WIDTH-1:0]	cmd1_burst_addr;
wire	[BEATADDR_WIDTH-1:0]			cmd1_beat_addr;


assign last_burst_addr = last_addr_reg[ADDR_WIDTH-1:BEATADDR_WIDTH];
assign last_beat_addr = last_addr_reg[BEATADDR_WIDTH-1:0];
assign cmd0_burst_addr = cmd0_addr[ADDR_WIDTH-1:BEATADDR_WIDTH];
assign cmd0_beat_addr = cmd0_addr[BEATADDR_WIDTH-1:0];
assign cmd1_burst_addr = cmd1_addr[ADDR_WIDTH-1:BEATADDR_WIDTH];
assign cmd1_beat_addr = cmd1_addr[BEATADDR_WIDTH-1:0];


// The request can be merged only if all the following conditions are true
// 1. The address points to the same memory burst as the last command
// 2. The beat number is greater than that of the last command (in-order access)
// 3. The elapsed time since the last command (offset by the beat number)
//    is less than the write latency
assign can_merge_cmd0 = (cmd0_burst_addr == last_burst_addr) &
						(cmd0_beat_addr > last_beat_addr) &
						(timer < (write_latency - WDATA_FIFO_LATENCY + cmd0_beat_addr));
assign can_merge_cmd1 = (cmd1_burst_addr == last_burst_addr) &
						(cmd1_beat_addr > last_beat_addr) &
						(timer < (write_latency - WDATA_FIFO_LATENCY + cmd1_beat_addr));


always_ff @(posedge clk or negedge reset_n)
begin
	if (!reset_n)
	begin
		timer <= '0;

		// Reset to the highest address so that the first
		// request cannot be merged regardless of its address
		last_addr_reg <= {ADDR_WIDTH{1'b1}};
	end
	else
	begin
		// Reset timer if a new command is issued, otherwise increment the timer
		if (do_command)
			timer <= '0;
		else
			timer <= timer + 1'b1;

		// Save the address of the last request
		if (do_command || merge_command)
			last_addr_reg <= cmd0_addr;
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
always_ff @(posedge clk)
begin
	if (reset_n)
	begin
		if (!can_merge_cmd0)
		begin
			assert (!merge_command)
				else $error ("Merge command cannot be issued");
		end
		if (merge_command)
		begin
			assert (cmd0_burst_addr == last_burst_addr)
				else $error ("Merging requests to different bursts");
			assert (cmd0_beat_addr > last_beat_addr)
				else $error ("Merging should not cause data re-ordering");
		end
	end
end
// synthesis translate_on


endmodule

