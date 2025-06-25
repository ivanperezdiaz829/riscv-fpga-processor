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
// The beat valid FIFO keeps track of which beats within a burst are addressed
// by the user.  When a 'do_command' is issued, a new burst is started and the
// corresponding beat is set.  When a 'merge_command" is issued, the addressed
// beat of the last burst is set.
//////////////////////////////////////////////////////////////////////////////

`timescale 1 ps / 1 ps

module memctl_beat_valid_fifo(
	clk,
	reset_n,
	do_command,
	merge_command,
	beat_addr,
	read_enable,
	beat_valid_out
);

//////////////////////////////////////////////////////////////////////////////
// BEGIN PARAMETER SECTION

// For a half rate controller (AFI_RATE_RATIO=2), the burst length in the controller - equals memory burst length / 4
// For a full rate controller (AFI_RATE_RATIO=1), the burst length in the controller - equals memory burst length / 2
parameter CTL_BURST_LENGTH		= 0;
// The number of beats required to store in the FIFO
parameter NUM_BEATS_REQUIRED	= 0;
// Register the beat_valid_out output
parameter REGISTER_OUTPUT		= 0;

// END PARAMETER SECTION
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// BEGIN LOCALPARAM SECTION

// The adjusted number of beats required to store in the FIFO
// The extra CTL_BURST_LENGTH bits are required because the 'do_command'
// will clear all bits of the burst which may still to be read
localparam NUM_BEATS_REQUIRED_ADJUSTED	= NUM_BEATS_REQUIRED + CTL_BURST_LENGTH;
localparam NUM_BURSTS_REQUIRED	= (NUM_BEATS_REQUIRED_ADJUSTED + CTL_BURST_LENGTH - 1) / CTL_BURST_LENGTH;

// The width of burst counter required to address all bursts in the FIFO
localparam BURST_COUNTER_WIDTH	= max(1, ceil_log2(NUM_BURSTS_REQUIRED));
localparam NUM_BURSTS			= 2 ** BURST_COUNTER_WIDTH;

// The width of beat counter required to address all beats in a burst
localparam BEAT_COUNTER_WIDTH	= max(1, ceil_log2(CTL_BURST_LENGTH));

// END LOCALPARAM SECTION
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// BEGIN PORT SECTION

// Clock and reset interface
input								clk;
input								reset_n;

// State machine command outputs
input								do_command;
input								merge_command;

// FIFO address and control signals
// Beat address is one-hot encoded
input	[CTL_BURST_LENGTH-1:0]		beat_addr;
input								read_enable;

// FIFO output
output								beat_valid_out;

// END PORT SECTION
//////////////////////////////////////////////////////////////////////////////

logic								beat_valid_out;
// The FIFO implemented using registers
reg		[CTL_BURST_LENGTH-1:0]		beat_valid [NUM_BURSTS];
reg									beat_valid_out_reg;
// FIFO write address
reg		[BURST_COUNTER_WIDTH-1:0]	write_burst_counter;
wire	[BURST_COUNTER_WIDTH-1:0]	next_write_burst_counter;
// FIFO read address.
reg		[BURST_COUNTER_WIDTH-1:0]	read_burst_counter;
reg		[BURST_COUNTER_WIDTH-1:0]	next_read_burst_counter;
// Beat counter points to the beat_valid register to be read out
reg		[BEAT_COUNTER_WIDTH-1:0]	read_beat_counter;
reg		[BEAT_COUNTER_WIDTH-1:0]	next_read_beat_counter;


assign next_write_burst_counter = write_burst_counter + 1'b1;


// FIFO logic and FIFO address registers
always_ff @(posedge clk or negedge reset_n)
begin
	if (!reset_n)
	begin
		for (int i = 0; i < NUM_BURSTS; i++)
			beat_valid[i] <= '0;
		beat_valid_out_reg <= 1'b0;
		write_burst_counter <= {BURST_COUNTER_WIDTH{1'b1}};
		read_burst_counter <= '0;
		read_beat_counter <= '0;
		next_read_burst_counter <= '0;
		if (CTL_BURST_LENGTH == 1)
			next_read_burst_counter[0] <= 1'b1;
		next_read_beat_counter <= '0;
		if (CTL_BURST_LENGTH > 1)
			next_read_beat_counter[0] <= 1'b1;
	end
	else
	begin
		if (do_command)
		begin
			// A 'do_command' is issued, so start a new burst
			beat_valid[next_write_burst_counter] <= beat_addr;
			write_burst_counter <= next_write_burst_counter;
		end
		else if (merge_command)
		begin
			// A 'merge_command' is issued, set the beat in the last burst
			beat_valid[write_burst_counter] <= beat_valid[write_burst_counter] | beat_addr;
		end

		if (read_enable)
		begin
			beat_valid_out_reg <= beat_valid[next_read_burst_counter][next_read_beat_counter];
			read_burst_counter <= next_read_burst_counter;
			read_beat_counter <= next_read_beat_counter;

			if (next_read_beat_counter == CTL_BURST_LENGTH[BEAT_COUNTER_WIDTH-1:0] - 1'b1)
			begin
				next_read_beat_counter <= '0;
				next_read_burst_counter <= next_read_burst_counter + 1'b1;
			end
			else
			begin
				next_read_beat_counter <= next_read_beat_counter + 1'b1;
			end
		end
		else
		begin
			beat_valid_out_reg <= beat_valid[read_burst_counter][read_beat_counter];
		end
	end
end


// FIFO output logic
always_comb
begin
	if (read_enable)
		beat_valid_out <= (REGISTER_OUTPUT == "ON") ? beat_valid_out_reg : beat_valid[read_burst_counter][read_beat_counter];
	else
		beat_valid_out <= 1'b0;
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
always @(posedge clk)
begin
	if (reset_n)
	begin
		if (CTL_BURST_LENGTH == 1)
			assert (~merge_command) else $error ("Cannot merge in burst length 1");
	end
end
// synthesis translate_on


endmodule

