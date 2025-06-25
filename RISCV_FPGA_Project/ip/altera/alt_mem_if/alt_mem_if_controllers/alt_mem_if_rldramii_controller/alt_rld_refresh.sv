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
// The periodic refresh module issues refresh requests to each bank in a round
// robin fashion.  The refresh interval is specified by CTL_T_REFI.
//////////////////////////////////////////////////////////////////////////////

`timescale 1 ps / 1 ps

module alt_rld_refresh(
	clk,
	reset_n,
	do_aref,
	aref_req,
	aref_req_bank_addr
);

//////////////////////////////////////////////////////////////////////////////
// BEGIN PARAMETER SECTION

parameter CTL_BANKADDR_WIDTH	= 0;
// Refresh period in controller cycles
parameter CTL_T_REFI			= 0;
parameter CTL_T_RC				= 0;

// END PARAMETER SECTION
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// BEGIN LOCALPARAM SECTION

localparam REFRESH_TIMER_WIDTH	= ceil_log2(CTL_T_REFI);

// END LOCALPARAM SECTION
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// BEGIN PORT SECTION

// Clock and reset interface
input							clk;
input							reset_n;

// State machine command outputs
input							do_aref;

// Refresh module output
output							aref_req;
output [CTL_BANKADDR_WIDTH-1:0]	aref_req_bank_addr;

// END PORT SECTION
//////////////////////////////////////////////////////////////////////////////

reg		[CTL_BANKADDR_WIDTH-1:0]	aref_req_bank_addr_reg;
wire	[CTL_BANKADDR_WIDTH-1:0]	next_aref_req_bank_addr;

reg		[CTL_BANKADDR_WIDTH-1:0]	num_pending_refresh;
reg		[REFRESH_TIMER_WIDTH-1:0]	timer;


assign aref_req = (num_pending_refresh > 1) | (~do_aref & (num_pending_refresh == 1));
assign aref_req_bank_addr = do_aref ? next_aref_req_bank_addr : aref_req_bank_addr_reg;
assign next_aref_req_bank_addr = aref_req_bank_addr_reg + 1'b1;


// Refresh timer
always_ff @(posedge clk or negedge reset_n)
begin
	if (!reset_n)
	begin
		timer <= CTL_T_REFI[REFRESH_TIMER_WIDTH-1:0] - 1'b1;
	end
	else
	begin
		if (timer == 0)
			timer <= CTL_T_REFI[REFRESH_TIMER_WIDTH-1:0] - 1'b1;
		else
			timer <= timer - 1'b1;
	end
end


always_ff @(posedge clk or negedge reset_n)
begin
	if (!reset_n)
	begin
		aref_req_bank_addr_reg <= '0;
		num_pending_refresh <= '0;
	end
	else
	begin
		if (timer == 0 && !do_aref)
		begin
			if (num_pending_refresh != {CTL_BANKADDR_WIDTH{1'b1}})
				num_pending_refresh <= num_pending_refresh + 1'b1;
		end
		else if (timer != 0 && do_aref)
		begin
			num_pending_refresh <= num_pending_refresh - 1'b1;
		end

		if (do_aref)
		begin
			aref_req_bank_addr_reg <= next_aref_req_bank_addr;
		end
	end
end


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
	// The refresh interval should be longer than the maximum refresh wait time
	// (bank cycle time), otherwise this module will not function as expected
	assert (CTL_T_REFI > CTL_T_RC) else $error ("Refresh interval too short");
end

always_ff @(posedge clk)
begin
	if (reset_n)
	begin
		if (do_aref)
		begin
			assert (num_pending_refresh > 0)
				else $error ("Controller issued a refresh but there is no pending refresh");
		end
	end
end
// synthesis translate_on


endmodule

