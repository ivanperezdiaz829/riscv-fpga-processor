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
// The timers module keeps track of the states of each bank and the DQ bus,
// and outputs 'can_*' signals to the state machine to indicate whether each
// bank can be issued a refresh, write, or read command.
//////////////////////////////////////////////////////////////////////////////

`timescale 1 ps / 1 ps

module alt_rld_timers(
	clk,
	reset_n,
	do_access,
	do_aref,
	chip_bank_id,
	aref_bank_addr,
	can_access,
	can_aref
);

//////////////////////////////////////////////////////////////////////////////
// BEGIN PARAMETER SECTION

parameter CTL_CS_WIDTH			= 0;
parameter CTL_BANKADDR_WIDTH	= 0;
parameter CHIP_BANK_ID_WIDTH	= 0;
parameter NUM_BANKS				= 0;
parameter NUM_BANKS_PER_CHIP	= 0;
// tRC in controller cycles
parameter CTL_T_RC				= 0;

// END PARAMETER SECTION
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// BEGIN PORT SECTION

input								clk;
input								reset_n;

// Commands from main state machine
input								do_access;
input								do_aref;
input	[CHIP_BANK_ID_WIDTH-1:0]	chip_bank_id;
input	[CTL_BANKADDR_WIDTH-1:0]	aref_bank_addr;

// Timer outputs
output	[NUM_BANKS-1:0]				can_access;
output	[NUM_BANKS_PER_CHIP-1:0]	can_aref;

// END PORT SECTION
//////////////////////////////////////////////////////////////////////////////


logic	[NUM_BANKS-1:0]				bank_do_access;
wire	[NUM_BANKS-1:0]				bank_can_access;


// Generate output signals
assign can_access = bank_can_access;


// A refresh command refreshes the same bank in all chips
// can_aref is the logical AND of all chips' bank_can_access for each bank
generate
genvar bank;
genvar chip;
for (bank = 0; bank < NUM_BANKS_PER_CHIP; bank = bank + 1)
begin : can_aref_bank
	wire	[CTL_CS_WIDTH-1:0]	bank_can_aref;
	for (chip = 0; chip < CTL_CS_WIDTH; chip = chip + 1)
	begin : can_aref_chip
		assign bank_can_aref[chip] = bank_can_access[chip * NUM_BANKS_PER_CHIP + bank];
	end
	assign can_aref[bank] = &bank_can_aref;
end
endgenerate


// Decoder for 'bank_do_access' bus
always_comb
begin
	bank_do_access <= '0;

	if (do_access)
	begin
		bank_do_access[chip_bank_id] <= 1'b1;
	end
	if (do_aref)
	begin
		// do_aref refreshes all chips on the same bank
		for (int chip_num = 0; chip_num < CTL_CS_WIDTH; chip_num = chip_num + 1)
			bank_do_access[chip_num * NUM_BANKS_PER_CHIP + aref_bank_addr] <= 1'b1;
	end
end


// Instantiate a bank timer for each bank
generate
genvar bank_num;
for (bank_num = 0; bank_num < NUM_BANKS; bank_num = bank_num + 1)
begin : bank_timer_gen
	alt_rld_bank_timer timer_inst (
		.clk			(clk),
		.reset_n		(reset_n),
		.do_access		(bank_do_access[bank_num]),
		.can_access	(bank_can_access[bank_num]));
	defparam timer_inst.CTL_T_RC	= CTL_T_RC;
end
endgenerate


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
		if (do_access)
			assert (can_access[chip_bank_id]) else $error ("Write or read operation violates timing requirement");
		if (do_aref)
			assert (can_aref[aref_bank_addr]) else $error ("Refresh operation violates timing requirement");
	end
end
// synthesis translate_on


endmodule

