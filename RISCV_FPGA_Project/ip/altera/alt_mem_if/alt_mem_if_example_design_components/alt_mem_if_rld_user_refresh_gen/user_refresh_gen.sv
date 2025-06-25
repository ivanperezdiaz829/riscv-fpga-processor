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
// The user refresh generator issues user refresh request and generate bank
// address to be refresh. As to model the flexibility in issuing the refresh
// request, this module will not only exercise a normal (round robin) refresh
// but will also exercise random and geng refresh
// Note that this module is only provided as an example and is designed only
// to exercise User Refresh features of the UniPHY memory interface.
//////////////////////////////////////////////////////////////////////////////

`timescale 1 ps / 1 ps

module user_refresh_gen(
	clk,
	reset_n,
	ref_ack,
	ref_req,
	ref_ba
);

//////////////////////////////////////////////////////////////////////////////
// BEGIN PARAMETER SECTION

parameter CTL_BANKADDR_WIDTH	= "";
// Refresh period in controller cycles
parameter CTL_T_REFI			= "";

///// END PARAMETER SECTION
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// BEGIN LOCALPARAM SECTION

// It is possible that the controller might not acknowladge the request
// immedietly due to unfinished transaction that it is doing. To ensure we
// always issue refresh before tREFI exceed, internal tREFI value will be set
// as a minus 10 cyle of original contoller tREFI
localparam INTERNAL_T_REFI		= CTL_T_REFI - 10;

// To improve efficiency, eight AREF commands (one for each bank) can be
// posted to the RLDRAM at periodic intervals calulcated as per tREFC
localparam INTERNAL_T_REFC		= (CTL_T_REFI - 10 ) * 8;

localparam TREFI_TIMER_WIDTH	= ceil_log2(INTERNAL_T_REFI + 1);
localparam REFRESH_TIMER_WIDTH	= ceil_log2(INTERNAL_T_REFC + 1);
localparam NUM_BANKS_PER_CHIP	= 2 ** CTL_BANKADDR_WIDTH;

// Parameters below is for experimental purpose. Do not edit unless necessary

// Determine how many time all bank need to be hit before change to different stage
// Note that, increasing this might cause incomplete test due to simulation timeout
localparam HIT_ALL_BANK_COUNT	= 2;
localparam HIT_ALL_BANK_WIDTH	= ceil_log2(HIT_ALL_BANK_COUNT + 1);

// Determine whether to do refresh to particular bank only or to all
// Note that, refresh to same bank might cause refresh violation to other bank
localparam EN_FIXED_BANK		= 0;
localparam FIXED_BANK			= 6;

// END LOCALPARAM SECTION
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// BEGIN PORT SECTION

// Clock and reset signals
input							clk;
input							reset_n;

// Controller refresh acknowladge signal
input							ref_ack;

// Module output signals
output							ref_req;
output [CTL_BANKADDR_WIDTH-1:0]	ref_ba;

// END PORT SECTION
//////////////////////////////////////////////////////////////////////////////

// Test stages definition
typedef enum int unsigned {
	INIT,
	CONSISTENT,
	NORMAL_REFRESH,
	RANDOM_REFRESH,
	GENG_REFRESH
} test_stage_t;

// Test stages
test_stage_t					stage;

// Registered signals for the next_stage
reg								next_stage_reg;

// Registered signals for the refresh timer
reg	[REFRESH_TIMER_WIDTH-1:0]	timer;

// Registered signals for the output
reg 							ref_req;
reg	[CTL_BANKADDR_WIDTH-1:0]	ref_ba;

// Registered signals for bank tracking
reg [NUM_BANKS_PER_CHIP-1:0]	refreshed_bank_id;
reg [CTL_BANKADDR_WIDTH-1:0]	refreshed_dif_bank_count;
reg [CTL_BANKADDR_WIDTH-1:0]	refreshed_bank_for_interval_count;

// Registered signals for total times the refresh request hit all bank
reg	[HIT_ALL_BANK_WIDTH-1:0]	hit_all_bank_count;

// Reset value for refresh timer based on refresh pattern
wire [REFRESH_TIMER_WIDTH-1:0]	interval;

// Next value for the refresh target bank
wire [CTL_BANKADDR_WIDTH-1:0]	next_ref_ba;

// Next value for the refresh target bank
wire [TREFI_TIMER_WIDTH-1:0]	random_interval;
wire [CTL_BANKADDR_WIDTH-1:0] 	random_ref_ba;
wire [4-1:0] 					random_ba;

// LFSR enable signal
wire 							get_next_rand_interval;
wire							get_next_rand_bank;

// Indicate the simulation ready to move to next test stage
wire 							next_stage;

// Indicate ref_req should be assert
wire 							do_request;

// Refresh target indicator
wire 							ref_to_diff_bank;
wire 							all_bank_refreshed;

// Determine whether to use the value from LFSR (random), round robin or fixed
assign interval					= (stage == RANDOM_REFRESH) ? random_interval 	: ((stage == GENG_REFRESH) 		? INTERNAL_T_REFC[REFRESH_TIMER_WIDTH-1:0] : INTERNAL_T_REFI[REFRESH_TIMER_WIDTH-1:0]);
assign next_ref_ba 				= (stage == RANDOM_REFRESH) ? random_ref_ba 	: ((EN_FIXED_BANK == 1) 	? FIXED_BANK[CTL_BANKADDR_WIDTH-1:0] : ref_ba + 1'b1 ) ;

// Determine whether refresh request has been issued to all bank
assign all_bank_refreshed 		= (ref_ack && (!refreshed_bank_id[ref_ba]) && (refreshed_dif_bank_count == NUM_BANKS_PER_CHIP - 1) ) ? 1'b1 : 1'b0;

// Determine whether all bank has been refreshed for the required number of 
// time and ready to move to next test stage
assign next_stage				= ((hit_all_bank_count == HIT_ALL_BANK_COUNT- 1) && all_bank_refreshed)  ? 1'b1 : 1'b0;

// Determine if need to request another value in following case
// a) If LFSR give value grater than internal tREFI ...OR
// b) If LFSR give value smaller than the number of bank
//    Note that, due to minimum width of LFSR is 4, it is possible that LFSR
//    will give bank address that has been hit before. In worst case scenario
//    it might need 'NUM_BANKS_PER_CHIP' attempt/cycle to get the correct 
//    bank address that haven't being hit. So, the interval shouldn't be less
//    than that or the same bank will be issued in the next_ref_ba
assign get_next_rand_interval 	= ((random_interval > INTERNAL_T_REFI[REFRESH_TIMER_WIDTH-1:0]) || (random_interval < NUM_BANKS_PER_CHIP )) ? 1'b1 : 1'b0;

// Determine if need to request another value in following case
// a) If LFSR give bank adress which has been refreshed previously
//    Note that, due to minimum width of LFSR is 4, it is possible that LFSR
//    will give bank address that has been hit before
assign get_next_rand_bank		= (refreshed_bank_id[random_ref_ba]);

// Determine if refresh request should be assert untill all bank refreshed
// for the interval or only when it reach the time
assign do_request				= (stage == GENG_REFRESH) ? ~(&refreshed_bank_for_interval_count) : (timer == 0);

// Determine whether the current address bank has been refreshed before
assign ref_to_diff_bank 		= (ref_ack && (!refreshed_bank_id[ref_ba])) ? 1'b1 : 1'b0;

// Get only the required bit from the output of LFSR
assign random_ref_ba			= random_ba[CTL_BANKADDR_WIDTH-1:0];

// Test stages state machine
// To only do a pattern of refresh, change the reset value of the stage to
// CONSISTENT case and chenge the stage value for CONSISTENT to pefered pattern 
always_ff @(posedge clk or negedge reset_n)
begin
	if (!reset_n)
		stage <= INIT;
	else

		case (stage)

			INIT:
				stage <= NORMAL_REFRESH;

			// Issue consistent pattern of refresh
			CONSISTENT:
				stage <= NORMAL_REFRESH;

			// Issue refresh request with fix interval (internal tREFI) and with
			// incremental (round robin fashion) target bank address
			NORMAL_REFRESH:
				if(next_stage)
					stage <= GENG_REFRESH;
				else
					stage <= NORMAL_REFRESH;

			// Issue refresh request back to back with incremetal target bank
			// address
			GENG_REFRESH:
				if(next_stage)
					stage <= RANDOM_REFRESH;
				else
					stage <= GENG_REFRESH;

			// Issue refresh request with random (but constraint) interval and with
			// random (but constraint) target bank address
			RANDOM_REFRESH:
				if(next_stage)
					stage <= NORMAL_REFRESH;
				else
					stage <= RANDOM_REFRESH;

			default:
				stage <= stage;

		endcase
end

// Registered version of next stage signal
always_ff @(posedge clk or negedge reset_n)
begin
	if (!reset_n)
		next_stage_reg <= 1'b0;
	else
		next_stage_reg <= next_stage;
end

// Refresh timer
always_ff @(posedge clk or negedge reset_n)
begin
	if (!reset_n)
		timer <= '0;
	else

		if (ref_ack)
			timer 		<= interval;
		else if (next_stage_reg)
			timer 		<= interval;
		else if (timer > 0)
			timer 	<= timer - 1'b1;
		else
			timer 		<= timer;
end

// Issue refresh request
always_ff @(posedge clk or negedge reset_n)
begin
	if (!reset_n)
		ref_req <= 1'b1;
	else

		// Refresh request should be assert when timer expired or as long as
		// the geng refresh is asserted
		if (do_request)
			ref_req <= 1'b1;
		else if (ref_ack)
			ref_req <= 1'b0;
		else
			ref_req <= ref_req;

end

// Register the bank to be refresh
always_ff @(posedge clk or negedge reset_n)
begin
	if (!reset_n)
		ref_ba <= '0;
	else
		if (ref_ack)
			ref_ba <= next_ref_ba;
		else
			ref_ba <= ref_ba;
end

// Bank refreshed tracker
always_ff @(posedge clk or negedge reset_n)
begin
	if (!reset_n)
		refreshed_bank_id <= '0;
	else
		if (refreshed_bank_id == {NUM_BANKS_PER_CHIP{1'b1}})

			// In the case back to back refesh, only clear the others id
			if (ref_ack)
				for (int bank = 0; bank < NUM_BANKS_PER_CHIP; bank++)
				begin
					if (bank == ref_ba) 
						refreshed_bank_id[bank] <= 1'b1;
					else
						refreshed_bank_id[bank] <= 1'b0;
				end
			else
				refreshed_bank_id <= '0;
		else if (ref_ack)
			for (int bank = 0; bank < NUM_BANKS_PER_CHIP; bank++)
			begin
				if (bank == ref_ba) 
					refreshed_bank_id[bank] <= 1'b1;
				else
					refreshed_bank_id[bank] <= refreshed_bank_id[bank];
			end
		else
			refreshed_bank_id <=refreshed_bank_id;
end

// Refreshed to different bank counter
always_ff @(posedge clk or negedge reset_n)
begin
	if (!reset_n)
		refreshed_dif_bank_count <= '0;
	else
		if (ref_to_diff_bank)
			refreshed_dif_bank_count <= refreshed_dif_bank_count + 1'b1;
		else
			refreshed_dif_bank_count <= refreshed_dif_bank_count;
end

// Geng control
always_ff @(posedge clk or negedge reset_n)
begin
	if (!reset_n)
		refreshed_bank_for_interval_count <= '0;
	else
		if (ref_to_diff_bank && (refreshed_bank_for_interval_count < NUM_BANKS_PER_CHIP - 1) && (stage == GENG_REFRESH))
			refreshed_bank_for_interval_count <= refreshed_bank_for_interval_count + 1'b1;
		else if (timer < (NUM_BANKS_PER_CHIP - 1))
			refreshed_bank_for_interval_count <= '0;
		else
			refreshed_bank_for_interval_count <= refreshed_bank_for_interval_count;
end

// Count how many time all bank has been hit
always_ff @(posedge clk or negedge reset_n)
begin
	if (!reset_n)
		hit_all_bank_count <= '0;
	else
		if (next_stage)
			hit_all_bank_count <= '0;
		else if (all_bank_refreshed)
			hit_all_bank_count <= hit_all_bank_count + 1'b1;
		else
			hit_all_bank_count <= hit_all_bank_count;

end

// Random refresh interval generator
lfsr interval_inst (
	.clk		(clk),
	.reset_n	(reset_n),
	.enable		(ref_ack|get_next_rand_interval),
	.data		(random_interval));
defparam interval_inst.WIDTH	= TREFI_TIMER_WIDTH;
defparam interval_inst.SEED		= INTERNAL_T_REFI;

// Random bank generator
lfsr bank_inst (
	.clk		(clk),
	.reset_n	(reset_n),
	.enable		(ref_ack|get_next_rand_bank),
	.data		(random_ba));
defparam bank_inst.WIDTH	= 4;
defparam bank_inst.SEED		= 4'b0010;

// Calculate the ceiling of log_2 of the input value
function integer ceil_log2;
	input integer value;
	begin
		value = value - 1;
		for (ceil_log2 = 0; value > 0; ceil_log2 = ceil_log2 + 1)
			value = value >> 1;
	end
endfunction

endmodule
