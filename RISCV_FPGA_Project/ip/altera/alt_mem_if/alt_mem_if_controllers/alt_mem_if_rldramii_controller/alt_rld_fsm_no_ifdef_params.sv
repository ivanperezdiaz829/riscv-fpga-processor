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
// This is the main state machine of the RLDRAM II Memory Controller.  It
// accepts user requests from the Avalon interface and refresh requests from
// the refresh module, and issues memory commands while satisfying timing
// requirements.
//////////////////////////////////////////////////////////////////////////////

`timescale 1 ps / 1 ps

module alt_rld_fsm_no_ifdef_params (
	clk,
	reset_n,
	init_complete,
	init_fail,
	cmd0_read_req,
	cmd0_write_req,
	cmd0_avl_addr,
	cmd0_addr_can_merge,
	cmd0_chip_bank_id,
	cmd1_read_req,
	cmd1_write_req,
	cmd1_avl_addr,
	cmd1_addr_can_merge,
	cmd1_chip_bank_id,
	aref_req,
	aref_req_bank_addr,
	bank_can_access,
	bank_can_aref,
	do_write,
	do_read,
	do_aref,
	merge_write,
	merge_read,
	aref_bank_addr
);

//////////////////////////////////////////////////////////////////////////////
// BEGIN PARAMETER SECTION

parameter CTL_BURST_LENGTH						= 0;
parameter CTL_BANKADDR_WIDTH					= 0;
parameter CHIP_BANK_ID_WIDTH					= 0;
parameter NUM_BANKS								= 0;
parameter NUM_BANKS_PER_CHIP					= 0;
// DQ bus turnaround time
parameter MEM_BUS_TURNAROUND_CYCLES_RD_TO_WR	= 0;
parameter MEM_BUS_TURNAROUND_CYCLES_WR_TO_RD	= 0;

parameter ADDR_WIDTH							= 0;
parameter BEATADDR_WIDTH						= 0;
parameter MAX_WRITE_LATENCY						= 0;
parameter CTL_CS_WIDTH							= 0;
parameter CTL_T_WL								= 0;
parameter AFI_RATE_RATIO						= 0;

// Write data FIFO setting
parameter WDATA_FIFO_LATENCY                    = 0;

// END PARAMETER SECTION
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// BEGIN LOCALPARAM SECTION

// One-cycle difference in write and read latencies (T_WL = T_RL + 1)
localparam WRITE_READ_LATENCIES_DIFFERENCE = 1;

// Minimum read and write commands separation in controller cycles
//******************************
localparam RD_TO_RD	= CTL_BURST_LENGTH;
localparam WR_TO_WR	= CTL_BURST_LENGTH;
localparam RD_TO_WR	= (AFI_RATE_RATIO == 2) ? CTL_BURST_LENGTH + ((MEM_BUS_TURNAROUND_CYCLES_RD_TO_WR - WRITE_READ_LATENCIES_DIFFERENCE + 1) / 2) : CTL_BURST_LENGTH + MEM_BUS_TURNAROUND_CYCLES_RD_TO_WR - WRITE_READ_LATENCIES_DIFFERENCE;
localparam WR_TO_RD	= (AFI_RATE_RATIO == 2) ? CTL_BURST_LENGTH + ((MEM_BUS_TURNAROUND_CYCLES_WR_TO_RD + WRITE_READ_LATENCIES_DIFFERENCE + 1) / 2) : CTL_BURST_LENGTH + MEM_BUS_TURNAROUND_CYCLES_WR_TO_RD + WRITE_READ_LATENCIES_DIFFERENCE;

localparam MAX_DELAY_BETWEEN_ACCESS	= max(max(RD_TO_RD, WR_TO_WR), max(RD_TO_WR, WR_TO_RD));
localparam MAX_MERGE_TIMER_VALUE	= MAX_WRITE_LATENCY + CTL_BURST_LENGTH - WDATA_FIFO_LATENCY;
localparam LAST_ACCESS_TIMER_WIDTH	= log2(max(MAX_DELAY_BETWEEN_ACCESS, MAX_MERGE_TIMER_VALUE)) + 1;

// END LOCALPARAM SECTION
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// BEGIN PORT SECTION

// Clock and reset interface
input									clk;
input									reset_n;

// PHY initialization and calibration status
input									init_complete;
input									init_fail;

// User memory requests
input									cmd0_read_req;
input									cmd0_write_req;
input	[ADDR_WIDTH-1:0]				cmd0_avl_addr;
input									cmd0_addr_can_merge;
input	[CHIP_BANK_ID_WIDTH-1:0]		cmd0_chip_bank_id;
input									cmd1_read_req;
input									cmd1_write_req;
input	[ADDR_WIDTH-1:0]				cmd1_avl_addr;
input									cmd1_addr_can_merge;
input	[CHIP_BANK_ID_WIDTH-1:0]		cmd1_chip_bank_id;

// Refresh module signals
input									aref_req;
input	[CTL_BANKADDR_WIDTH-1:0]		aref_req_bank_addr;

// Timer outputs
input	[NUM_BANKS-1:0]					bank_can_access;
input	[NUM_BANKS_PER_CHIP-1:0]		bank_can_aref;

// State machine command outputs
output									do_write;
output									do_read;
output									do_aref;
output									merge_write;
output									merge_read;
output	[CTL_BANKADDR_WIDTH-1:0]		aref_bank_addr;

// END PORT SECTION
//////////////////////////////////////////////////////////////////////////////

// FSM states
enum int unsigned {
	INIT,
	INIT_COMPLETE,
	INIT_FAIL
} state;

enum int unsigned {
	WRITE,
	READ
} last_cmd_type;

enum int unsigned {
	CMD0,
	CMD1
} next_cmd;


reg										do_write;
reg										do_read;
reg										do_aref;
reg										merge_write;
reg										merge_read;
reg		[CTL_BANKADDR_WIDTH-1:0]		aref_bank_addr;

reg		[LAST_ACCESS_TIMER_WIDTH-1:0]	num_cycles_since_last_access;

wire									can_merge_cmd0;
wire									can_merge_cmd1;

wire									dq_ready_for_write;
wire									dq_ready_for_read;
wire									chip_bank_id_conflicts_with_last_cmd;
wire									aref_bank_addr_conflicts_with_last_cmd;

logic									write_req;
logic									read_req;
logic	[CHIP_BANK_ID_WIDTH-1:0]		chip_bank_id;
logic									can_merge;

wire	[NUM_BANKS-1:0]					can_do_write;
wire	[NUM_BANKS-1:0]					can_do_read;
wire	[NUM_BANKS_PER_CHIP-1:0]		can_do_aref;

wire	[BEATADDR_WIDTH-1:0]			cmd0_beat_addr;
wire	[BEATADDR_WIDTH-1:0]			cmd1_beat_addr;


assign cmd0_beat_addr = cmd0_avl_addr[BEATADDR_WIDTH-1:0];
assign cmd1_beat_addr = cmd1_avl_addr[BEATADDR_WIDTH-1:0];

// The request can be merged only if all the following conditions are true
// 1. The address points to the same memory burst as the last command
// 2. The beat number is greater than that of the last command (in-order access)
// 3. The elapsed time since the last command (offset by the beat number)
//    is less than the write latency
assign can_merge_cmd0 = cmd0_addr_can_merge &
                        (num_cycles_since_last_access < (CTL_T_WL + cmd0_beat_addr - WDATA_FIFO_LATENCY));
assign can_merge_cmd1 = cmd1_addr_can_merge &
                        (num_cycles_since_last_access < (CTL_T_WL + cmd1_beat_addr - WDATA_FIFO_LATENCY));

assign dq_ready_for_write = ((last_cmd_type == WRITE) & (num_cycles_since_last_access >= WR_TO_WR)) |
							((last_cmd_type == READ) & (num_cycles_since_last_access >= RD_TO_WR));
assign dq_ready_for_read = 	((last_cmd_type == WRITE) & (num_cycles_since_last_access >= WR_TO_RD)) |
							((last_cmd_type == READ) & (num_cycles_since_last_access >= RD_TO_RD));
assign chip_bank_id_conflicts_with_last_cmd =
	(do_aref & (aref_bank_addr == chip_bank_id[CTL_BANKADDR_WIDTH-1:0])) |
	((do_write | do_read) & (cmd0_chip_bank_id == cmd1_chip_bank_id));
assign aref_bank_addr_conflicts_with_last_cmd =
	(do_aref & (aref_bank_addr == aref_req_bank_addr)) |
	((do_write | do_read) & (cmd0_chip_bank_id[CTL_BANKADDR_WIDTH-1:0] == aref_req_bank_addr));
assign can_do_write = bank_can_access &
					{NUM_BANKS{~chip_bank_id_conflicts_with_last_cmd}} &
					{NUM_BANKS{dq_ready_for_write}};
assign can_do_read = bank_can_access &
					{NUM_BANKS{~chip_bank_id_conflicts_with_last_cmd}} &
					{NUM_BANKS{dq_ready_for_read}};
assign can_do_aref = bank_can_aref & ~{NUM_BANKS_PER_CHIP{aref_bank_addr_conflicts_with_last_cmd}};


// cmd0/1 mux
always_comb
begin
	case (next_cmd)
		CMD0:
		begin
			write_req <= cmd0_write_req & ~cmd0_read_req;
			read_req <= cmd0_read_req & ~cmd0_write_req;
			chip_bank_id <= cmd0_chip_bank_id;
			can_merge <= can_merge_cmd0;
		end
		CMD1:
		begin
			write_req <= cmd1_write_req & ~cmd1_read_req;
			read_req <= cmd1_read_req & ~cmd1_write_req;
			chip_bank_id <= cmd1_chip_bank_id;
			can_merge <= can_merge_cmd1;
		end
	endcase
end


// Command issuing state machine
//FIXME add 2T addr/cmd
always_ff @(posedge clk, negedge reset_n)
begin
	if (!reset_n)
	begin
		do_write <= 1'b0;
		do_read <= 1'b0;
		do_aref <= 1'b0;
		merge_write <= 1'b0;
		merge_read <= 1'b0;
		next_cmd <= CMD1;
		aref_bank_addr <= '0;
		num_cycles_since_last_access <= {LAST_ACCESS_TIMER_WIDTH{1'b1}};
		state <= INIT;
		last_cmd_type <= WRITE;
	end
	else
	begin
		do_write <= 1'b0;
		do_read <= 1'b0;
		do_aref <= 1'b0;
		merge_write <= 1'b0;
		merge_read <= 1'b0;

		if (cmd1_read_req ^ cmd1_write_req)
			next_cmd <= CMD0;

		if (num_cycles_since_last_access < {LAST_ACCESS_TIMER_WIDTH{1'b1}})
			num_cycles_since_last_access <= num_cycles_since_last_access + 1'b1;

		case (state)
			INIT:
			begin
				// PHY is doing initialization and calibration
				if (init_complete)
					state <= INIT_COMPLETE;
				else if (init_fail)
					state <= INIT_FAIL;
			end

			INIT_COMPLETE:
			begin
				// Refresh request has the highest priority
				//, except when the
				if (aref_req && can_do_aref[aref_req_bank_addr])
				begin
					do_aref <= 1'b1;
					aref_bank_addr <= aref_req_bank_addr;

					// Write or read merge may occur in the same cycle as a refresh
					// A request can be merged if the request type is the same as the last
					// one ('state') and the address falls in the same burst ('can_merge')
					if (write_req && can_merge)
					begin
						merge_write <= 1'b1;
						next_cmd <= CMD1;
					end
					if (read_req && can_merge)
					begin
						merge_read <= 1'b1;
						next_cmd <= CMD1;
					end
				end
				else
				begin
					if (write_req)
					begin
						// Merge the write if possible, otherwise issue a new write
						// command if there is no refresh request to the same bank
						if (can_merge)
						begin
							merge_write <= 1'b1;
							next_cmd <= CMD1;
						end
						else if (can_do_write[chip_bank_id] &&
								!(CTL_CS_WIDTH > 1 && aref_req && aref_req_bank_addr == chip_bank_id[CTL_BANKADDR_WIDTH-1:0]))
						begin
							do_write <= 1'b1;
							num_cycles_since_last_access <= 1;
							last_cmd_type <= WRITE;
							next_cmd <= CMD1;
						end
					end
					
					if (read_req)
					begin
						// Merge the read if possible, otherwise issue a new read
						// command if there is no refresh request to the same bank
						if (can_merge)
						begin
							merge_read <= 1'b1;
							next_cmd <= CMD1;
						end
						else if (can_do_read[chip_bank_id] &&
								!(CTL_CS_WIDTH > 1 && aref_req && aref_req_bank_addr == chip_bank_id[CTL_BANKADDR_WIDTH-1:0]))
						begin
							do_read <= 1'b1;
							num_cycles_since_last_access <= 1;
							last_cmd_type <= READ;
							next_cmd <= CMD1;
						end
					end
				end
			end

			INIT_FAIL:
			begin
				// Initialization and calibration fails
				state <= INIT_FAIL;
			end

		endcase
	end
end


// Returns the maximum of two numbers
function automatic integer max;
	input integer a;
	input integer b;
	begin
		max = (a > b) ? a : b;
	end
endfunction


// Calculate the ceiling of log_2 of the input value
function automatic integer log2;
	input integer value;
	begin
		value = value >> 1;
		for (log2 = 0; value > 0; log2 = log2 + 1)
			value = value >> 1;
	end
endfunction


// Simulation assertions
// synthesis translate_off
initial
begin
	assert (CTL_BURST_LENGTH > 0) else $error ("Invalid burst length");
	assert (RD_TO_RD > 0) else $error ("Invalid read-to-read separation");
	assert (RD_TO_WR > 0) else $error ("Invalid read-to-write separation");
	assert (WR_TO_RD > 0) else $error ("Invalid write-to-read separation");
	assert (WR_TO_WR > 0) else $error ("Invalid write-to-write separation");
end

always_ff @(posedge clk)
begin
	if (reset_n)
	begin
		assert (!(write_req && read_req)) else $error ("User request conflict");
		assert ((CTL_T_WL - WDATA_FIFO_LATENCY) > 0)
			else $error ("Invalid write data FIFO operation mode");
	end
end
// synthesis translate_on


endmodule

