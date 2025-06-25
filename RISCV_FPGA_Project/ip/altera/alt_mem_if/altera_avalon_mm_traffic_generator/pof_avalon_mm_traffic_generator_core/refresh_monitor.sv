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


// ******************************************************************************************************************************** 
// File name: refresh_monitor.sv
// This is an add-ons feature for RLDRAM II memory model for use with the UniPHY memory interface
// Note that this model is only provided as an example and is designed only
// to exercise User Refresh features of the UniPHY memory interface.
// ATTENTION :
// Please take note that tREFI and tREFC is not a hard requiremnet for RLDRAM II
// Thus, the violation signals provided here is just an aid in constraining
// the provided user refresh driver
// ******************************************************************************************************************************** 

`timescale 1 ps / 1 ps

module refresh_monitor(
	clk,
	reset_n,
	afi_cal_success,
	mem_cs_n,
	mem_we_n,
	mem_ref_n,
	mem_ba,
	trefi_violated,
	trefc_violated,
	tref_violated,
	test_complete
);

//////////////////////////////////////////////////////////////////////////////
// BEGIN PARAMETER SECTION

parameter MEM_IF_BANKADDR_WIDTH	= "";
parameter MEM_T_REFI			= "";
parameter MEM_T_REF				= "";
parameter NUM_OF_ROWS_PER_BANK	= "";
parameter EXTEND_SIM_TIME		= "";

// END PARAMETER SECTION
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// BEGIN LOCALPARAM SECTION

// To improve efficiency, eight AREF commands (one for each bank) can be
// posted to the RLDRAM at periodic intervals calulcated as per tREFC
localparam INTERNAL_T_REFC		= MEM_T_REFI * 8;

localparam NUM_BANKS_PER_CHIP	= 2 ** MEM_IF_BANKADDR_WIDTH;
localparam TREFI_TIMER_WIDTH	= ceil_log2(MEM_T_REFI + 1);
localparam TREFC_TIMER_WIDTH	= ceil_log2(INTERNAL_T_REFC + 1);
localparam TREF_TIMER_WIDTH		= ceil_log2(MEM_T_REF + 1);
localparam ROW_PER_BANK_WIDTH	= ceil_log2(NUM_OF_ROWS_PER_BANK + 1);

// Parameters below is for experimental purpose. Do not edit unless necessary

// Determine whether refresh to different bank are required to reset the 
// refresh timer
localparam MUST_REF_DIFF_BANK	= 1;
localparam EXTEND_SIM_WIDTH		= ceil_log2(EXTEND_SIM_TIME + 1);

// END LOCALPARAM SECTION
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// BEGIN PORT SECTION

// Clock and reset interface
input								clk;
input								reset_n;

input								afi_cal_success;
// Memory commands
input								mem_cs_n;
input								mem_we_n;
input								mem_ref_n;
input [MEM_IF_BANKADDR_WIDTH-1:0]	mem_ba;

// Refresh monitor output
output								trefi_violated;
output								trefc_violated;
output								tref_violated;
output								test_complete;

// END PORT SECTION
//////////////////////////////////////////////////////////////////////////////

// Timer
reg [TREFI_TIMER_WIDTH-1:0] 	trefi_timer;
reg [TREFC_TIMER_WIDTH-1:0] 	trefc_timer;
reg [TREF_TIMER_WIDTH-1:0] 		tref_timer;
reg [EXTEND_SIM_WIDTH-1:0] 		extend_sim_timer;

// Registered version of refresh timing violation
reg 							trefi_violated_reg;
reg 							trefc_violated_reg;
reg 							tref_violated_reg;

// Permenent version of refresh timing violation
reg								trefi_violated;
reg								trefc_violated;
reg								tref_violated;

// Bank tracker
reg [NUM_BANKS_PER_CHIP-1:0]	accessed_bank;
reg [NUM_BANKS_PER_CHIP-1:0]	refreshed_bank_id;
reg [MEM_IF_BANKADDR_WIDTH-1:0]	refreshed_any_bank_count;
reg [MEM_IF_BANKADDR_WIDTH-1:0]	refreshed_dif_bank_count;

// Refresh target indicator
wire 							ref_to_diff_bank;
wire 							all_bank_refreshed;

// Memory command signals
wire 							write_cmd;
wire 							refresh_cmd;

// Timer reset signal
wire 							reset_trefi_timer;
wire 							reset_trefc_timer;

wire [NUM_BANKS_PER_CHIP-1:0]	tref_violated_per_bank;

// Simplified version of write and refresh command to memmory
assign write_cmd 			= (!mem_cs_n && !mem_we_n && mem_ref_n);
assign refresh_cmd			= (!mem_cs_n && mem_we_n && !mem_ref_n);

// Determine whether the current address bank has been refreshed before
assign ref_to_diff_bank 	= (refresh_cmd && (!refreshed_bank_id[mem_ba])) ? 1'b1 : 1'b0;

// Determine whether (including current refresh command) all bank has been refreshed
assign all_bank_refreshed 	= (refresh_cmd && (!refreshed_bank_id[mem_ba]) && (refreshed_dif_bank_count == NUM_BANKS_PER_CHIP - 2) ) ? 1'b1 : 1'b0;

// Determine how timer should be reset (need to be different target bank or not)
assign reset_trefi_timer 	= (MUST_REF_DIFF_BANK == 1) ? (ref_to_diff_bank) : refresh_cmd;
assign reset_trefc_timer 	= (MUST_REF_DIFF_BANK == 1) ? (all_bank_refreshed) : (refreshed_any_bank_count == {MEM_IF_BANKADDR_WIDTH{1'b1}});

// Determine whether simulation has exceed the extended timing
assign test_complete 		= (extend_sim_timer == 0 );

// tREFI timer
always_ff @(posedge clk or negedge reset_n)
begin
	if (!reset_n)
		trefi_timer <= MEM_T_REFI[TREFI_TIMER_WIDTH-1:0];
	else
		if (afi_cal_success && reset_trefi_timer)
			trefi_timer <= MEM_T_REFI[TREFI_TIMER_WIDTH-1:0];
		else if (afi_cal_success && (trefi_timer > 0))
			trefi_timer <= trefi_timer - 1'b1;
		else
			trefi_timer <= trefi_timer;
end

// tREFC timer
always_ff @(posedge clk or negedge reset_n)
begin
	if (!reset_n)
		trefc_timer <= INTERNAL_T_REFC[TREFC_TIMER_WIDTH-1:0];
	else
		if (afi_cal_success && reset_trefc_timer)
			trefc_timer <= INTERNAL_T_REFC[TREFC_TIMER_WIDTH-1:0];
		else if (afi_cal_success && (trefc_timer > 0))
			trefc_timer <= trefc_timer - 1'b1;
		else
			trefc_timer <= trefc_timer;
end

// tREF timer
always_ff @(posedge clk or negedge reset_n)
begin
	if (!reset_n)
		tref_timer <= MEM_T_REF[TREF_TIMER_WIDTH-1:0];
	else
		if (afi_cal_success && (tref_timer == 0))
			tref_timer <= MEM_T_REF[TREF_TIMER_WIDTH-1:0] - 1'b1;
		else if (afi_cal_success && (tref_timer > 0))
			tref_timer <= tref_timer - 1'b1;
		else
			tref_timer <= tref_timer;
end

// Test complete timer
always_ff @(posedge clk or negedge reset_n)
begin
	if (!reset_n)
		extend_sim_timer <= EXTEND_SIM_TIME[EXTEND_SIM_WIDTH-1:0] - 1'b1;
	else
		if ((tref_timer == 0) && (extend_sim_timer > 0))
			extend_sim_timer <= extend_sim_timer - 1'b1;
		else
			extend_sim_timer <= extend_sim_timer;
end

// Bank accessed tracker
always_ff @(posedge clk or negedge reset_n)
begin
	if (!reset_n)
		accessed_bank <= '0;
	else
		if (afi_cal_success && write_cmd)
			for (int bank = 0; bank < NUM_BANKS_PER_CHIP; bank++)
			begin
				if (bank == mem_ba) 
					accessed_bank[bank] <= 1'b1;
				else
					accessed_bank[bank] <= accessed_bank[bank];
			end
		else
			accessed_bank <= accessed_bank;
end

// Bank refreshed tracker
always_ff @(posedge clk or negedge reset_n)
begin
	if (!reset_n)
		refreshed_bank_id <= '0;
	else
		if (refreshed_bank_id == {NUM_BANKS_PER_CHIP{1'b1}})

			// In the case back to back refesh, only clear the others id
			if (afi_cal_success && refresh_cmd)
				for (int bank = 0; bank < NUM_BANKS_PER_CHIP; bank++)
				begin
					if (bank == mem_ba) 
						refreshed_bank_id[bank] <= 1'b1;
					else
						refreshed_bank_id[bank] <= 1'b0;
				end
			else
				refreshed_bank_id <= '0;
		else if (afi_cal_success && refresh_cmd)
			for (int bank = 0; bank < NUM_BANKS_PER_CHIP; bank++)
			begin
				if (bank == mem_ba) 
					refreshed_bank_id[bank] <= 1'b1;
				else
					refreshed_bank_id[bank] <= refreshed_bank_id[bank];
			end
		else
			refreshed_bank_id <=refreshed_bank_id;
end

// Refreshed counter
always_ff @(posedge clk or negedge reset_n)
begin
	if (!reset_n)
		refreshed_any_bank_count <= '0;
	else
		if (afi_cal_success && refresh_cmd)
			refreshed_any_bank_count <= refreshed_any_bank_count + 1'b1;
		else
			refreshed_any_bank_count <= refreshed_any_bank_count;
end

// Refreshed to different bank counter
always_ff @(posedge clk or negedge reset_n)
begin
	if (!reset_n)
		refreshed_dif_bank_count <= '0;
	else
		if (afi_cal_success && ref_to_diff_bank)
			refreshed_dif_bank_count <= refreshed_dif_bank_count + 1'b1;
		else
			refreshed_dif_bank_count <= refreshed_dif_bank_count;
end

// Rows refreshed per bank tracker
generate
genvar bank;
for (bank = 0; bank < NUM_BANKS_PER_CHIP; bank = bank + 1)
begin : num_of_ref_cmd_for_bank

	reg [ROW_PER_BANK_WIDTH-1:0] 	refreshed_row_count;

	// Assert tref violation only for accessed bank that having insufficient refresh
	assign tref_violated_per_bank[bank] = ((refreshed_row_count > 0) && (tref_timer == 0) && (accessed_bank[bank])) ;

	always_ff @(posedge clk or negedge reset_n)
	begin
		if (!reset_n)
			refreshed_row_count <= NUM_OF_ROWS_PER_BANK[ROW_PER_BANK_WIDTH-1:0] - 1'b1;
		else
			if (afi_cal_success && (tref_timer == 0))
				refreshed_row_count <= NUM_OF_ROWS_PER_BANK[ROW_PER_BANK_WIDTH-1:0] - 1'b1;
			else if (afi_cal_success && refresh_cmd && (mem_ba == bank) && (refreshed_row_count > 0))
				refreshed_row_count <= refreshed_row_count - 1'b1;
			else
				refreshed_row_count <= refreshed_row_count;
	end

end
endgenerate

// Registered version of violated signal
always_ff @(posedge clk or negedge reset_n)
begin
	if (!reset_n)
	begin
		trefi_violated_reg <= 1'b0;
		trefc_violated_reg <= 1'b0;
		tref_violated_reg <= 1'b0;
	end
	else
	begin
		if (trefi_timer == 0)
			trefi_violated_reg <= 1'b1;
		else
			trefi_violated_reg <= 1'b0;

		if (trefc_timer == 0)
			trefc_violated_reg <= 1'b1;
		else
			trefc_violated_reg <= 1'b0;

		if (|tref_violated_per_bank)
			tref_violated_reg <= 1'b1;
		else
			tref_violated_reg <= 1'b0;
	end
end

// Permenent version of violated signal
always_ff @(posedge clk or negedge reset_n)
begin
	if (!reset_n)
	begin
		trefi_violated <= 1'b0;
		trefc_violated <= 1'b0;
		tref_violated <= 1'b0;
	end
	else
	begin
		if (trefi_timer == 0)
			trefi_violated <= 1'b1;
		else
			trefi_violated <= trefi_violated;

		if (trefc_timer == 0)
			trefc_violated <= 1'b1;
		else
			trefc_violated <= trefc_violated;

		if (|tref_violated_per_bank)
			tref_violated <= 1'b1;
		else
			tref_violated <= tref_violated;

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
`ifdef PRINT_OUT_STATUS
always_ff @(posedge trefi_violated_reg)
	$display("REFRESH MONITOR WARNING : tREFI violation occured at %t",$time);
always_ff @(posedge trefc_violated_reg)
	$display("REFRESH MONITOR WARNING : tREFC violation occured at %t",$time);
always_ff @(posedge tref_violated_reg)
	$display("REFRESH MONITOR WARNING : tREF violation occured at %t",$time);
`endif
// synthesis translate_on

endmodule
