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

module alt_mem_if_common_rldram_mem_model_rldram3 (
	mem_a,
	mem_ba,
	mem_ck,
	mem_ck_n,
	mem_cs_n,
	mem_dk,
	mem_dk_n,
	mem_dm,
	mem_dq,
	mem_qk,
	mem_qk_n,
	mem_reset_n,
	mem_ref_n,
	mem_we_n
);

// ******************************************************************************************************************************** 
// BEGIN PARAMETER SECTION
// All parameters default to "" will have their values passed in from the toplevel testbench 

// Memory device specific parameters, they are set according to the memory spec.
parameter MEM_BANKADDR_WIDTH   = 4; 
parameter MEM_ADDR_WIDTH       = 20; 
parameter MEM_DM_WIDTH         = 2; 
parameter MEM_READ_DQS_WIDTH   = 4; 
parameter MEM_WRITE_DQS_WIDTH  = 2; 
parameter MEM_DQ_WIDTH         = 36; 
parameter MEM_IF_CS_WIDTH = 1;

parameter MEM_DQS_TO_CLK_CAPTURE_DELAY = 0;
parameter MEM_CLK_TO_DQS_CAPTURE_DELAY = 0;
parameter MEM_GUARANTEED_WRITE_INIT = 0;
parameter MEM_DEPTH_IDX = -1;
parameter MEM_WIDTH_IDX = -1;

parameter MEM_VERBOSE = 1;

input	[MEM_ADDR_WIDTH-1:0]	mem_a;   
input	[MEM_BANKADDR_WIDTH-1:0]	mem_ba; 
input	mem_ck; 
input	mem_ck_n; 
input	[MEM_IF_CS_WIDTH-1:0] mem_cs_n; 
input	[MEM_WRITE_DQS_WIDTH-1:0]	mem_dk; 
input	[MEM_WRITE_DQS_WIDTH-1:0]	mem_dk_n; 
input	[MEM_DM_WIDTH-1:0]	mem_dm; 
inout   [MEM_DQ_WIDTH-1:0]	mem_dq; 
output logic [MEM_READ_DQS_WIDTH-1:0]	mem_qk; 
output logic [MEM_READ_DQS_WIDTH-1:0]	mem_qk_n; 
input	mem_ref_n; 
input	mem_we_n; 
input	mem_reset_n; // asynchronous reset input

wire logic [MEM_READ_DQS_WIDTH-1:0] local_mem_qk [MEM_IF_CS_WIDTH-1:0]; 
wire logic [MEM_READ_DQS_WIDTH-1:0] local_mem_qk_n [MEM_IF_CS_WIDTH-1:0]; 
localparam NUMBER_OF_RANKS = MEM_IF_CS_WIDTH;

assign mem_qk = local_mem_qk[0] ; 
assign mem_qk_n = local_mem_qk_n[0] ; 

generate
genvar rank;
    for (rank = 0; rank < NUMBER_OF_RANKS; rank = rank + 1)
    begin : rank_gen
        mem_rank_model # (
				    .MEM_BANKADDR_WIDTH (MEM_BANKADDR_WIDTH),
					.MEM_ADDR_WIDTH (MEM_ADDR_WIDTH),
					.MEM_DM_WIDTH (MEM_DM_WIDTH),
					.MEM_READ_DQS_WIDTH (MEM_READ_DQS_WIDTH),
					.MEM_WRITE_DQS_WIDTH (MEM_WRITE_DQS_WIDTH),
					.MEM_DQ_WIDTH (MEM_DQ_WIDTH),
					.MEM_VERBOSE (MEM_VERBOSE),
					.MEM_DQS_TO_CLK_CAPTURE_DELAY(MEM_DQS_TO_CLK_CAPTURE_DELAY),
					.MEM_CLK_TO_DQS_CAPTURE_DELAY(MEM_CLK_TO_DQS_CAPTURE_DELAY),
					.MEM_DEPTH_IDX (MEM_DEPTH_IDX),
					.MEM_WIDTH_IDX (MEM_WIDTH_IDX),			   
					.MEM_GUARANTEED_WRITE_INIT (MEM_GUARANTEED_WRITE_INIT)
                        ) rank_inst (
						.mem_a		(mem_a),
						.mem_ba		(mem_ba),
						.mem_ck		(mem_ck),
						.mem_ck_n	(mem_ck_n),
						.mem_cs_n	(mem_cs_n[rank]),
						.mem_dk		(mem_dk),
						.mem_dk_n	(mem_dk_n),
						.mem_dm		(mem_dm),
						.mem_dq		(mem_dq),
						.mem_qk		(local_mem_qk[rank]),
						.mem_qk_n	(local_mem_qk_n[rank]),
						.mem_ref_n	(mem_ref_n),
						.mem_reset_n(mem_reset_n),
						.mem_we_n	(mem_we_n)
						
                    );
    end
endgenerate
endmodule

module mem_rank_model
	# (parameter 
		MEM_BANKADDR_WIDTH   = 4, 
		MEM_ADDR_WIDTH       = 20, 
		MEM_DM_WIDTH         = 2, 
		MEM_READ_DQS_WIDTH   = 4, 
		MEM_WRITE_DQS_WIDTH  = 2, 
		MEM_DQ_WIDTH         = 36, 

		MEM_DQS_TO_CLK_CAPTURE_DELAY = 0,
		MEM_CLK_TO_DQS_CAPTURE_DELAY = 0,
		MEM_GUARANTEED_WRITE_INIT = 0,
		MEM_DEPTH_IDX = -1,
		MEM_WIDTH_IDX = -1,

		MEM_VERBOSE = 1
	)
	(
		mem_a,
		mem_ba,
		mem_ck,
		mem_ck_n,
		mem_cs_n,
		mem_dk,
		mem_dk_n,
		mem_dm,
		mem_dq,
		mem_qk,
		mem_qk_n,
		mem_reset_n,
		mem_ref_n,
		mem_we_n
);
// ******************************************************************************************************************************** 
// BEGIN LOCALPARAMS SECTION

// The maximum refresh interval in ps.
localparam REFRESH_INTERVAL_PS = 36000000;

// The maximum latency possible for any configuration.
// This is used only to size command queues.
localparam MAX_LATENCY = 20;

// The maximum burst possible for any configuration.
// This is used to size burst counters.
localparam MAX_BURST = 8;

// The number of banks in the memory
localparam NUM_BANKS = 2**MEM_BANKADDR_WIDTH;

// Ignore incoming commands for the first IGNORE_CMDS_INIT_CYCLES cycles.
// Set to 5 because initially the PHY's I/O registers may not be properly
// flushed and may be sending out bogus command. The PHY is expected to
// subsequently perform device initialization.
localparam IGNORE_CMDS_INIT_CYCLES = 5;

// The maximum number of banks that can be refreshed with a single refresh
// command in Multibank AREF protocol mode
localparam MULTIBANK_AREF_MAX_BANKS = 4;

// END LOCALPARAMS SECTION
// ******************************************************************************************************************************** 


// ******************************************************************************************************************************** 
// BEGIN PORT SECTION
input	[MEM_ADDR_WIDTH-1:0]	mem_a;   // address
input	[MEM_BANKADDR_WIDTH-1:0]	mem_ba; // bank address
input	mem_ck; // memory clock
input	mem_ck_n; // memory clock. Differential version of mem_ck.
input	mem_cs_n; // memory chip select
input	[MEM_WRITE_DQS_WIDTH-1:0]	mem_dk; // memory data input clock
input	[MEM_WRITE_DQS_WIDTH-1:0]	mem_dk_n; // memory data input clock. Differential version of mem_dk
input	[MEM_DM_WIDTH-1:0]	mem_dm; // memory data mask.
inout   [MEM_DQ_WIDTH-1:0]	mem_dq; // memory data input/output
output logic [MEM_READ_DQS_WIDTH-1:0]	mem_qk; // memory echo clock
output logic [MEM_READ_DQS_WIDTH-1:0]	mem_qk_n; // memory echo clock. Differential version of mem_qk.
input	mem_ref_n; // refresh command input
input	mem_we_n; // write enable input
input	mem_reset_n; // asynchronous reset input

// END PORT SECTION
// ******************************************************************************************************************************** 

// synthesis translate_off

// Internal variables for memory parameters based on configuration
int tRC_cycles;
int tRL_cycles;
int tWL_cycles;
int burst_length;

int aref_protocol;
int write_protocol;

// Clock cycle counter
int clock_cycle;

// Bank counters structure. Used to model all aspects of bank accesses
// to ensure that proper delays are maintained.
typedef struct {
    int read_counter;
    int write_counter;
	int last_ref_cycle;
	int last_write_cycle;
	int last_read_cycle;
} bank_struct;

// create the one bank counter struct for each bank.
bank_struct banks [NUM_BANKS-1:0];

// The actual memory. Modeled as an associative array.
bit [MEM_DQ_WIDTH-1:0] mem_data[*];

// The address of the memory array (mem_data). We make this
// a packed struct so that it can be used directly as the
// index to mem_data. 
typedef struct packed {
	bit [MEM_ADDR_WIDTH+MEM_BANKADDR_WIDTH-1:0] address;
	bit [MAX_BURST-1:0] burst_num;
} address_burst_type;


// Command struct of possible memory commands
typedef enum {
	NOP_COMMAND,
	MRS_COMMAND,
	READ_COMMAND,
	WRITE_COMMAND,
	REF_COMMAND
} command_type;

// Structure of memory operations. This includes the memory command
// and the address/bank it operates on.
typedef struct {
	command_type command;
	int word_count;
	bit [MEM_ADDR_WIDTH-1:0] address;
	bit [MEM_BANKADDR_WIDTH-1:0] bank;
} command_struct;

// Create a variable for the current active command
command_struct active_command;

// Create a variable for the new command being created
command_struct new_command;


// Some simulators like NCsim don't yet support queues or arrays of structs
// as a result, unpack the command_struct. Once NCsim supports dynamic structures
// of structs this will be replaced by a queue of command_struct.
command_type command_queue[$];
int word_count_queue[$];
bit [MEM_ADDR_WIDTH-1:0] address_queue[$];
bit [MEM_BANKADDR_WIDTH-1:0] bank_queue[$];


// Command pipelines to ensure read/write latency is met
bit [2*MAX_LATENCY-1:0] read_command_pipeline;
bit [2*MAX_LATENCY-1:0] write_command_pipeline;
	
// Internal version of mem_qk;
wire mem_qk_int;

// Internal version of mem_dq
reg [MEM_DQ_WIDTH-1:0]	mem_dq_int;
bit mem_dq_en;

reg [MEM_DQ_WIDTH - 1:0]	mem_dq_captured;
reg [MEM_DM_WIDTH - 1:0]	mem_dm_captured;

time mem_ck_time;
time mem_dk_time[MEM_WRITE_DQS_WIDTH];


// Internal version of mem_ck is based on a pseudo differential clock
logic mem_ck_int;
always @(posedge mem_ck)   mem_ck_int <= mem_ck;
always @(posedge mem_ck_n) mem_ck_int <= ~mem_ck_n;

// Internal version of mem_ck is based on a pseudo differential clock
logic mem_dk_int;
always @(posedge mem_dk)   mem_dk_int <= mem_dk;
always @(posedge mem_dk_n) mem_dk_int <= ~mem_dk_n;

// capture dq and dm on internal dk

generate
	genvar i, j;

	for (i = 0; i < MEM_WRITE_DQS_WIDTH; i++)
	begin
		always @(posedge mem_dk[i] or posedge mem_dk_n[i])
		begin
			mem_dk_time[i] <= $time;
			mem_dm_captured[i] <= mem_dm[i];
		end
	
		for (j = 0; j < (MEM_DQ_WIDTH / MEM_WRITE_DQS_WIDTH / 9); j++)
		begin
			always @(posedge mem_dk[i] or posedge mem_dk_n[i])
			begin
				mem_dq_captured[(i+j*2+1)*9-1 : (i+j*2)*9] <= mem_dq[(i+j*2+1)*9-1 : (i+j*2)*9];
			end
		end
	end
endgenerate
	
`ifdef ENABLE_UNIPHY_SIM_SVA

parameter MAX_CYCLES_BETWEEN_ACTIVITY = 1000000;

generate
if (MAX_CYCLES_BETWEEN_ACTIVITY > 0)
begin
	reg startup_active = 0;

	initial 
	begin
		@(posedge mem_ck);
		startup_active <= 1;
		@(posedge mem_ck);
		startup_active <= 0;
	end
	
	mem_hang: assert property(memory_active)
		else $fatal(0, "No activity in %0d cycles", MAX_CYCLES_BETWEEN_ACTIVITY);
	
	property memory_active;
		@(posedge mem_ck)
			(~mem_cs_n | startup_active) |-> ##[1:MAX_CYCLES_BETWEEN_ACTIVITY] (~mem_cs_n);
	endproperty
end
endgenerate

`endif 

// ******************************************************************************************************************************** 
// BEGIN TASKS AND FUNCTIONS SECTION

// Task: set_configuration
// Parameters:
//   mode  : The configuration mode to use. This mode is the binary
//           representation of the mode register bits.
// Description: Sets the memory parameters based on the given memory
//      configuration. Each time the configuration is changed the 
//      command queue and memory array are cleared.

task automatic set_configuration (input bit [7:0] mode);

	// Look up the data latency mode
	if (mode[7:4] >= 14) begin
		$display("Reserved data latency mode %0d specified!", mode[7:4]);
		$finish(1);
	end else begin
		tRL_cycles <= mode[7:4] + 3;
		tWL_cycles <= mode[7:4] + 4;
		
		if (MEM_VERBOSE) 
			$display("[%0t] [DW=%0d%0d]: Setting RL=%0d WL=%0d", $time, MEM_DEPTH_IDX, MEM_WIDTH_IDX, mode[7:4] + 3, mode[7:4] + 4);
	end
	
	// Look up the tRC mode
	if (mode[3:0] >= 11) begin
		$display("Reserved tRC mode %0d specified!", mode[3:0]);
		$finish(1);
	end else begin
		tRC_cycles <= mode[3:0] + 2;
		
		if (MEM_VERBOSE) 
			$display("[%0t] [DW=%0d%0d]: Setting tRC=%0d", $time, MEM_DEPTH_IDX, MEM_WIDTH_IDX, mode[3:0] + 2);
	end
		
	// Delete the existing command queue by iterating through the queue
	while (command_queue.size() > 0)
		command_queue.delete(0);
	while (word_count_queue.size() > 0)
		word_count_queue.delete(0);
	while (address_queue.size() > 0)
		address_queue.delete(0);
	while (bank_queue.size() > 0)
		bank_queue.delete(0);

	// Delete the memory (unless need to preserve for guaranteed write pre-init)
	if (!MEM_GUARANTEED_WRITE_INIT)
	begin
		mem_data.delete();
	end
	
endtask

// Task: set_burst_len
// Parameters:
//     burst_mode : The burst mode to use. This mode is based on the 
//                  binary representation of the burst mode in the mode register
// Description: Sets the memory model parameters based on the given burst length
task automatic set_burst_len (input bit [1:0] burst_mode);
	case (burst_mode)
		2'b00 : begin
				burst_length <= 2;
				end
		2'b01 : begin
				burst_length <= 4;
				end
		2'b10 : begin
				burst_length <= 8;
				if (MEM_DQ_WIDTH == 36) begin
					$display("Burst length 8 is not supported by x36 RLDRAM3 devices");
					$finish(1);
				end
				end
		default : begin
			$display("Invalid burst length mode %0d specified!", burst_mode);
			$finish(1);
			end
	endcase

	if (MEM_VERBOSE) 
		$display("[%0t] [DW=%0d%0d]: Setting burst length %0d", $time, MEM_DEPTH_IDX, MEM_WIDTH_IDX, (2 << burst_mode));
endtask

// Task: set_aref_protocol
// Parameters:
//     aref_protocol_setting : The AREF protocol to use. This is based on the 
//                  binary representation of the AREF protocol in the mode register
// Description: Sets the AREF protocol based on the given write protocol setting

task automatic set_aref_protocol (input bit aref_protocol_setting);
		if (aref_protocol_setting == 1'b0) begin
			if (MEM_VERBOSE)
				$display("      AREF Protocol mode is set to Bank Address Control");
		end else begin
			if (MEM_VERBOSE)
				$display("      AREF Protocol mode is set to Multibank");
		end
		
		aref_protocol <= aref_protocol_setting;

	if (MEM_VERBOSE) 
		$display("[%0t] [DW=%0d%0d]: Setting AREF protocol %0d", $time, MEM_DEPTH_IDX, MEM_WIDTH_IDX, aref_protocol_setting);
endtask

// Task: set_write_protocol
// Parameters:
//     write_protocol_setting : The write protocol to use. This is based on the 
//                  binary representation of the write protocol in the mode register
// Description: Sets the write protocol based on the given write protocol setting

task automatic set_write_protocol (input bit [1:0] write_protocol_setting);
		case (write_protocol_setting)
			2'b00 : begin
				if (MEM_VERBOSE)
					$display("      Write Protocol mode is set to Single Bank");
			end
			2'b01 : begin
				if (MEM_VERBOSE)
					$display("      Write Protocol mode is set to Dual Bank");
			end				
			2'b10 : begin
				if (MEM_VERBOSE)
					$display("      Write Protocol mode is set to Quad Bank");
			end
			default : begin
				$display("[%0t] [DW=%0d%0d]: ERROR: Write Protocol mode %0d is reserved and is not supported!", $time, MEM_DEPTH_IDX, MEM_WIDTH_IDX, write_protocol_setting);
				$finish(1);
			end
		endcase
		
		write_protocol <= write_protocol_setting;

	if (MEM_VERBOSE) 
		$display("[%0t] [DW=%0d%0d]: Setting write protocol %0d", $time, MEM_DEPTH_IDX, MEM_WIDTH_IDX, write_protocol_setting);
endtask

// Task: nop_command
// Description: Executes any model commands required when a NOP is received
task automatic nop_command;
endtask

// Task: mrs_command
// Description: Executes any model commands required when a MRS command is received
task automatic mrs_command;
	if (MEM_VERBOSE) 
		$display("[%0t] [DW=%0d%0d]: MRS Command - MRS [ %0d ] -> %0h", $time, MEM_DEPTH_IDX, MEM_WIDTH_IDX, mem_ba[1:0], mem_a[17:0]);
		
	case(mem_ba[1:0])
		2'b00 : begin
			if (MEM_VERBOSE)
				$display("   MRS - 0");
			
			// Set the data latency and tRC mode
			set_configuration(mem_a[7:0]);
						
			// Catch invalid modes not supported by the model
			if (mem_a[9] == 1) begin
				$display("[%0t] [DW=%0d%0d]: ERROR: Multiplexed address mode not supported!", $time, MEM_DEPTH_IDX, MEM_WIDTH_IDX);
				$finish(1);
			end
		end

		2'b01 : begin
			if (MEM_VERBOSE)
				$display("   MRS - 1");
				
			// Set the burst length
			set_burst_len(mem_a[10:9]);
			
			// Set the AREF protocol
			set_aref_protocol(mem_a[8]);
			
			// Catch invalid ODT modes
			case (mem_a[4:2])
				3'b000 : begin
					if (MEM_VERBOSE)
						$display("      ODT mode is set to OFF");
				end
				3'b001 : begin
					if (MEM_VERBOSE)
						$display("      ODT mode is set to RZQ/6 (40 Ohms)");
				end
				3'b010 : begin
					if (MEM_VERBOSE)
						$display("      ODT mode is set to RZQ/4 (60 Ohms)");
				end
				3'b010 : begin
					if (MEM_VERBOSE)
						$display("      ODT mode is set to RZQ/2 (120 Ohms)");
				end
				default : begin
					$display("[%0t] [DW=%0d%0d]: ERROR: ODT mode %0d is reserved and is not supported!", $time, MEM_DEPTH_IDX, MEM_WIDTH_IDX, mem_a[4:2]);
					$finish(1);
				end
			endcase
			
			// Catch invalid Output Drive modes
			case (mem_a[1:0])
				2'b00 : begin
					if (MEM_VERBOSE)
						$display("      Output Drive mode is set to RZQ/6 (40 Ohms)");
				end
				2'b01 : begin
					if (MEM_VERBOSE)
						$display("      Output Drive mode is set to RZQ/4 (60 Ohms)");
				end
				default : begin
					$display("[%0t] [DW=%0d%0d]: ERROR: Output Drive mode %0d is reserved and is not supported!", $time, MEM_DEPTH_IDX, MEM_WIDTH_IDX, mem_a[1:0]);
					$finish(1);
				end
			endcase
		end

		2'b10 : begin
			if (MEM_VERBOSE)
				$display("   MRS - 2");
			
			// Set the Write Protocol (e.g. multibank writes)
			set_write_protocol(mem_a[4:3]);
			
			// Catch invalid modes not supported by the model
			if (mem_a[2] == 1'b1) begin
				$display("[%0t] [DW=%0d%0d]: ERROR: Read training not supported by this model", $time, MEM_DEPTH_IDX, MEM_WIDTH_IDX);
				$finish(1);
			end
		end

		default : begin
			$display("Error: MRS Invalid Bank Address: %0d", mem_ba[1:0]);
			$stop(1);
		end
	endcase
endtask

// Task: read_command
// Description: Executes any model commands required when a read command is received.
//     This includes creating the new command and pushing it in the queue.
task automatic read_command;
	if (MEM_VERBOSE) 
		$display("[%0t] [DW=%0d%0d]: READ Command to location %0h bank %3h", $time, MEM_DEPTH_IDX, MEM_WIDTH_IDX, mem_a, mem_ba);
	
	new_command.word_count = 0;
	
	// push the new_command variable into the appropriate queues
	command_queue.push_back(new_command.command);
	word_count_queue.push_back(new_command.word_count);
	address_queue.push_back(new_command.address);
	bank_queue.push_back(new_command.bank);

	// Update the read command pipeline so the actual memory array operation
	// will occur after the correct number of cycles.
	read_command_pipeline[2*tRL_cycles-1] <= 1;
	
	// Update the bank parameters for this bank
	banks[mem_ba].last_read_cycle = clock_cycle;
	banks[mem_ba].read_counter = banks[mem_ba].read_counter+1;

	// Reads also count as a refresh
	refresh_bank(mem_ba);
		
endtask

// Task: write_command
// Description: Executes any model commands required when a write command is received.
//     This includes creating the new command and pushing it in the queue.
task automatic write_command;
	
	// Support multibank write protocol.
	bit [MEM_BANKADDR_WIDTH-1:0] mem_ba_stripped;
	
	int num_banks_to_write;
	int bank_count;
	bit [MEM_BANKADDR_WIDTH-1:0] bank_offset;
	
	if (write_protocol == 0)
		mem_ba_stripped = mem_ba;
	else if (write_protocol == 1)
		mem_ba_stripped = {1'b0, mem_ba[MEM_BANKADDR_WIDTH-2:0]};
	else
		mem_ba_stripped = {2'b00, mem_ba[MEM_BANKADDR_WIDTH-3:0]};
		
	num_banks_to_write = 1 << write_protocol;
	
	if (MEM_VERBOSE) 
		$display("[%0t] [DW=%0d%0d]: Write Command to location %0h bank %3h", $time, MEM_DEPTH_IDX, MEM_WIDTH_IDX, mem_a, mem_ba);
	
	new_command.word_count = 0;
	
	// push the new_command variable into the appropriate queues
	command_queue.push_back(new_command.command);
	word_count_queue.push_back(new_command.word_count);
	address_queue.push_back(new_command.address);
	bank_queue.push_back(new_command.bank);
	
	// Update the write command pipeline so the actual memory array operation
	// will occur after the correct number of cycles.
	write_command_pipeline[2*tWL_cycles-1] <= 1;
	
	// Update the bank parameters for this bank
	for (bank_count = 0; bank_count < num_banks_to_write; bank_count++)
	begin
		bank_offset = (NUM_BANKS / num_banks_to_write) * bank_count;
		banks[mem_ba_stripped+bank_offset].last_write_cycle = clock_cycle;
		banks[mem_ba_stripped+bank_offset].write_counter = banks[mem_ba_stripped+bank_offset].write_counter+1;
	end
	
endtask

// Task: refresh_command
// Description: Executes any model commands required when a refresh command is received.
task automatic refresh_command;
	int i;
	int bank_count;
	
	if (aref_protocol == 0) begin
		if (MEM_VERBOSE) 
			$display("[%0t] [DW=%0d%0d]: Refresh Command to bank %0h", $time, MEM_DEPTH_IDX, MEM_WIDTH_IDX, mem_ba);
		refresh_bank(mem_ba);
	end
	else if (aref_protocol == 1) begin
		if (MEM_VERBOSE) 
			$display("[%0t] [DW=%0d%0d]: Refresh Command (multibank) to banks specified by %0h", $time, MEM_DEPTH_IDX, MEM_WIDTH_IDX, mem_a);
		bank_count = 0;
		for (i = 0; i < NUM_BANKS; i++) begin
			if (mem_a[i] == 1) begin
				if (bank_count >= MULTIBANK_AREF_MAX_BANKS) begin
					$display("[%0t] [DW=%0d%0d]: ERROR: Multibank AREF command cannot refresh more than %0d banks at a time", $time, MEM_DEPTH_IDX, MEM_WIDTH_IDX, MULTIBANK_AREF_MAX_BANKS);
					$finish(1);
				end
				
				refresh_bank(i);
				bank_count++;
			end
		end
	end
endtask

// Task: refresh_bank
// Parameters:
//      bank_num : The bank number to refresh
// Description: Update the bank parameters for the given bank when a refresh occurs.
task automatic refresh_bank(input int bank_num);
	if (MEM_VERBOSE)
		$display("[%0t] [DW=%0d%0d]: Refreshing bank %0h", $time, MEM_DEPTH_IDX, MEM_WIDTH_IDX, bank_num);
	banks[bank_num].last_ref_cycle = clock_cycle;
endtask

// Task: init_banks
// Description: Initialize the bank parameters of all banks.
task automatic init_banks;
	int i;
	for (i = 0; i < NUM_BANKS; i++) begin
		if (MEM_VERBOSE)
			$display("[%0t] [DW=%0d%0d]: Initializing bank %0d", $time, MEM_DEPTH_IDX, MEM_WIDTH_IDX, i);
		banks[i].read_counter = 0;
		banks[i].write_counter = 0;
		banks[i].last_ref_cycle = 0;
		banks[i].last_read_cycle = 0;
		banks[i].last_write_cycle = 0;
	end
		
endtask

task init_guaranteed_write;
	
	// to support bypassing guaranteed-write step in calibration, we pre-initialize
	// memory with the correct contents:
	// 0x55 at A/B 8/0 and 0/7
	// 0xAA at A/B 8/7 and 0/0

	static int burst_length = 8;
	static int other_bank = 7;
	bit [MEM_ADDR_WIDTH-1:0] addr;
	bit [MEM_BANKADDR_WIDTH-1:0] bank;
	
	int i;

	$display("Pre-initializing memory for guaranteed write");


	addr = burst_length;
	bank = 0;
	for (i = 0; i < burst_length; i++)
	begin
		write_memory({addr, bank}, i, {(MEM_DQ_WIDTH/9){9'b101010101}}, '0);
	end

	addr = 0;
	bank = other_bank;
	for (i = 0; i < burst_length; i++)
	begin
		write_memory({addr, bank}, i, {(MEM_DQ_WIDTH/9){9'b101010101}}, '0);
	end

	addr = burst_length;
	bank = other_bank;
	for (i = 0; i < burst_length; i++)
	begin
		write_memory({addr, bank}, i, {(MEM_DQ_WIDTH/9){9'b010101010}}, '0);
	end

	addr = 0;
	bank = 0;
	for (i = 0; i < burst_length; i++)
	begin
		write_memory({addr, bank}, i, {(MEM_DQ_WIDTH/9){9'b010101010}}, '0);
	end

endtask

// Task: check_violations
// Description: Checks to make sure no bank counter or access has been violated by
//     the current new command.
task automatic check_violations;
	int i;

	if (new_command.command != NOP_COMMAND) begin
		// Check tRC for the command's bank.
		if ((clock_cycle - banks[new_command.bank].last_ref_cycle) < tRC_cycles) begin
			$display("[%0t] [DW=%0d%0d]: ERROR: Bank %0d tRC violated against last refresh command", $time, MEM_DEPTH_IDX, MEM_WIDTH_IDX, new_command.bank);
			$finish(1);
		end
		if ((clock_cycle - banks[new_command.bank].last_write_cycle) < tRC_cycles) begin
			$display("[%0t] [DW=%0d%0d]: ERROR: Bank %0d tRC violated against last write command", $time, MEM_DEPTH_IDX, MEM_WIDTH_IDX, new_command.bank);
			$finish(1);
		end
		if ((clock_cycle - banks[new_command.bank].last_read_cycle) < tRC_cycles) begin
			$display("[%0t] [DW=%0d%0d]: ERROR: Bank %0d tRC violated against last read command", $time, MEM_DEPTH_IDX, MEM_WIDTH_IDX, new_command.bank);
			$finish(1);
		end
	end

	for (i = 0; i < NUM_BANKS; i++) begin

		if (new_command.command != NOP_COMMAND) begin
		
			// Check READ->WRITE or WRITE->WRITE. Make sure that command 1/2 burst
			// length after previous command to avoid collision on DQ BUS.
			if (new_command.command == WRITE_COMMAND)
				if ((clock_cycle - banks[i].last_write_cycle) < burst_length/2) begin
					$display("[%0t] [DW=%0d%0d]: ERROR: Bank %0d burst length write violated", $time, MEM_DEPTH_IDX, MEM_WIDTH_IDX, i);
					$finish(1);
				end
			// Check READ->READ. Make sure that command is 1/2 burst length after previous command
			// to avoid collision on DQ BUS.
			if (new_command.command == READ_COMMAND)
				if ((clock_cycle - banks[i].last_read_cycle) < burst_length/2) begin
					$display("[%0t] [DW=%0d%0d]: ERROR: Bank %0d burst length read violated", $time, MEM_DEPTH_IDX, MEM_WIDTH_IDX, i);
					$finish(1);
				end

			// Check WRITE->READ. Make sure that command is 1/2 burst length + 1 NOP after
			// previous command to avoid collision on DQ BUS.
			if (new_command.command == READ_COMMAND)
				if ((clock_cycle - banks[i].last_write_cycle) < (burst_length/2 + 1)) begin
					$display("[%0t] [DW=%0d%0d]: ERROR: Bank %0d burst length write->read violated", $time, MEM_DEPTH_IDX, MEM_WIDTH_IDX, i);
					$finish(1);
				end

		end
	end	
endtask

// Task: write_memory
// Parameters:
//      mem_address  : The address to write to
//      burst_num    : The burst number of this write
//      write_data   : The data to write
//      data_mask    : The data mask for this burst
// Description: Writes the given data to the memory array
task write_memory(
	input [MEM_ADDR_WIDTH+MEM_BANKADDR_WIDTH-1:0] mem_address, 
	input int burst_num,
	input [MEM_DQ_WIDTH-1:0] write_data,
	input [MEM_DM_WIDTH-1:0] data_mask);
	
	address_burst_type address_burst;
	bit [MEM_DQ_WIDTH - 1:0] masked_data;
	bit [MEM_DQ_WIDTH - 1:0] orig_data;
	int i;
	int j;
	int k;
	int num_banks_to_write;
	int bank_count;
	bit [MEM_BANKADDR_WIDTH-1:0] bank_offset;
	bit [MEM_BANKADDR_WIDTH-1:0] mem_bank;
	
	// Construct the actual address structure for the operation
	address_burst.address = mem_address;
	address_burst.burst_num = burst_num;
	
	if (data_mask == '0) begin
		masked_data = write_data;
	end else begin
		if (mem_data.exists(address_burst)) begin
			orig_data = mem_data[address_burst];
		end else begin
			orig_data = 'x;
		end

		for (i = 0; i < MEM_DM_WIDTH; i++)
		begin
			for (j = 0; j < (MEM_DQ_WIDTH / MEM_DM_WIDTH / 9); j++)
			begin
				if (data_mask[i] == 1'b1) begin
					if (MEM_VERBOSE) 
						$display("[%0t] [DW=%0d%0d]: Data mask enabled. Data ignored for write to address %0h byte %0d.", $time, MEM_DEPTH_IDX, MEM_WIDTH_IDX, mem_address, (i+j*2));
				end else if (data_mask[i] != 1'b0) begin
					$display("[%0t] [DW=%0d%0d]: ERROR: Invalid byte mask %h. X written to address %0h byte %0d.", $time, MEM_DEPTH_IDX, MEM_WIDTH_IDX, data_mask[i], mem_address, (i+j*2));
				end
			
				for (k = (i+j*2)*9; k < (i+j*2+1)*9; k++)
				begin
					if (data_mask[i] == 1'b1) begin
						masked_data[k] = orig_data[k];
					end else if (data_mask[i] == 1'b0) begin
						masked_data[k] = write_data[k];
					end else begin
						masked_data[k] = 'x;
					end
				end
			end
		end	
	end
	
	// Write to possibly multiple banks, depending on the currently-set Write Protocol mode
	num_banks_to_write = 1 << write_protocol;
	
	if (num_banks_to_write == 1)
		mem_bank = mem_address[MEM_BANKADDR_WIDTH-1:0];
	else if (num_banks_to_write == 2)
		mem_bank = {1'b0, mem_address[MEM_BANKADDR_WIDTH-2:0]};
	else if (num_banks_to_write == 4)
		mem_bank = {2'b00, mem_address[MEM_BANKADDR_WIDTH-3:0]};
	
	for (bank_count = 0; bank_count < num_banks_to_write; bank_count++)
	begin
		bank_offset = (NUM_BANKS / num_banks_to_write) * bank_count;
		address_burst.address = {mem_address[MEM_ADDR_WIDTH+MEM_BANKADDR_WIDTH-1:MEM_BANKADDR_WIDTH], mem_bank+bank_offset};
		
		if (MEM_VERBOSE)
			$display("[%0t] [DW=%0d%0d]: Writing data %h to address %0h burst %0d", $time, MEM_DEPTH_IDX, MEM_WIDTH_IDX, masked_data, address_burst.address, burst_num);
			
		mem_data[address_burst] = masked_data;
	end
endtask

// Task: read_memory
// Parameters:
//      mem_address  : The address to read from
//      burst_num    : The burst number of this write
// Description: Reads the memory array for the given address/burst
task read_memory(
	input [MEM_ADDR_WIDTH+MEM_BANKADDR_WIDTH-1:0] mem_address,
	int burst_num,
	output [MEM_DQ_WIDTH-1:0] data_read);

	address_burst_type address_burst;
	
	// Construct the actual address structure for the operation
	address_burst.address = mem_address;
	address_burst.burst_num = burst_num;
	
	if (mem_data.exists(address_burst)) begin
		// Read from the memory array
		data_read = mem_data[address_burst];
		if (MEM_VERBOSE) 
			$display("[%0t] [DW=%0d%0d]: Reading data %h from address %0h burst %0d", $time, MEM_DEPTH_IDX, MEM_WIDTH_IDX, data_read, mem_address, burst_num);
	end
	else begin
		// if the array location does not exist then output X
		if (MEM_VERBOSE) 
			$display("[%0t] [DW=%0d%0d]: WARNING: Attempting to read from uninitialized address %0h burst %0d", $time, MEM_DEPTH_IDX, MEM_WIDTH_IDX, mem_address, burst_num);
		data_read = 'X;
	end
endtask

// END TASKS AND FUNCTIONS SECTION
// ******************************************************************************************************************************** 

// Initialize variable and define a default configuration
initial begin
	int i;

	$display("[%0t] [DW=%0d%0d]: Altera Generic RLDRAM 3 Memory Model", $time, MEM_DEPTH_IDX, MEM_WIDTH_IDX);
	if (MEM_VERBOSE) begin
		$display("[%0t] [DW=%0d%0d]: Max refresh interval of %0d ps", $time, MEM_DEPTH_IDX, MEM_WIDTH_IDX, REFRESH_INTERVAL_PS);
	end
	
	// Clear the clock cycle counter
	clock_cycle = 0;
	
	// On startup set the configuration mode
	set_configuration('0);
	set_burst_len('0);

	// Reset all banks
	init_banks();
	
	// Delete the memory
	mem_data.delete();
	
	if (MEM_GUARANTEED_WRITE_INIT)
	begin
		init_guaranteed_write();
	end

	// Make the active command a NOP
	active_command.command <= NOP_COMMAND;
	
	// Clear the command pipelines
	for (i = 0; i < 2*MAX_LATENCY; i++) begin
		read_command_pipeline[i] = 0;
		write_command_pipeline[i] = 0;
	end
	
	
end

// Generate the mem_qk clock from the mem_ck clock;
assign mem_qk_int = mem_ck;

// Update the clock cycle counter
// The model assumes that CK and DK are identical signals
// coming from the controller. We use mem_dk_int in this always
// block to ensure that DK is toggling
always @ (posedge mem_dk_int)
	clock_cycle <= clock_cycle+1;

// Generate the outputs. Assume 0 skew
always @ (mem_qk_int) begin
	mem_qk <= {MEM_READ_DQS_WIDTH{mem_qk_int}};
	mem_qk_n <= ~{MEM_READ_DQS_WIDTH{mem_qk_int}};
end


// Main function of memory model
always @ (mem_ck_int) begin
	
	mem_ck_time = $time;
	
	// Shift the command pipelines
	read_command_pipeline <= {1'b0, read_command_pipeline[2*MAX_LATENCY-1:1]};
	write_command_pipeline <= {1'b0, write_command_pipeline[2*MAX_LATENCY-1:1]};
	
	// Operate on the positive edge of the clock
	if (mem_ck_int) begin
		// Process the new commands on the pins
		new_command.address = mem_a;
		new_command.bank = mem_ba;
		new_command.word_count = 0;
		if (mem_cs_n == 1'b1)
			new_command.command = NOP_COMMAND;
		else if (mem_reset_n !== 1'b1)
			new_command.command = NOP_COMMAND;
		else if (clock_cycle < IGNORE_CMDS_INIT_CYCLES) begin
			new_command.command = NOP_COMMAND;
			$display("[%0t] : Ignoring incoming command for the first %0d cycles. Current cycle is %0d", $time, IGNORE_CMDS_INIT_CYCLES, clock_cycle);
		end
		else begin
			
			case ({mem_we_n, mem_ref_n})
				2'b00 : new_command.command = MRS_COMMAND;
				2'b11 : new_command.command = READ_COMMAND;
				2'b01 : new_command.command = WRITE_COMMAND;
				2'b10 : new_command.command = REF_COMMAND;
			endcase
		
			// Check for violations based on this command
			check_violations();
	
		end
		
		// Run the appropriate task based on the command
		case (new_command.command)
			NOP_COMMAND : nop_command();
			MRS_COMMAND : mrs_command();
			READ_COMMAND : read_command();
			WRITE_COMMAND : write_command();
			REF_COMMAND : refresh_command();
		endcase
	end
	
	// There should be a command available. Otherwise assert.
	if (read_command_pipeline[0] || write_command_pipeline[0])
		if (command_queue.size() == 0) begin
			$display("[%0t] [DW=%0d%0d]: Internal Error: Command queue empty but commands expected!", $time, MEM_DEPTH_IDX, MEM_WIDTH_IDX);
			$finish(1);
		end

	// Determine if any active command is finished. Some commands like read/write
	// take more than one clock cycle to complete.
	if (active_command.command != NOP_COMMAND)
		if (active_command.word_count == burst_length)
			// Mark the command as NOP_COMMAND to signal that the active command is complete
			active_command.command = NOP_COMMAND;
	

	// Is there an active read/write on this cycle?
	// For a new command to be active, there must be no active command
	// and the read or write command pipeline must have a 1 in position 0
	// indicating that the appropriate number of clock cycles have passed since
	// the command was issued
	if (active_command.command == NOP_COMMAND) begin
		if (read_command_pipeline[0]) begin

			// Update the active_command variable to point to the next command in the
			// queue.
			active_command.command = command_queue.pop_front();
			active_command.word_count = word_count_queue.pop_front();
			active_command.address = address_queue.pop_front();
			active_command.bank = bank_queue.pop_front();

			if (active_command.command != READ_COMMAND) begin
				$display("[%0t] [DW=%0d%0d]: Internal Error: Expected READ command not in queue!", $time, MEM_DEPTH_IDX, MEM_WIDTH_IDX);
				$finish(1);
			end
			
		end
		else if (write_command_pipeline[0]) begin

			// Update the active_command variable to point to the next command in the
			// queue.
			active_command.command = command_queue.pop_front();
			active_command.word_count = word_count_queue.pop_front();
			active_command.address = address_queue.pop_front();
			active_command.bank = bank_queue.pop_front();

			if (active_command.command != WRITE_COMMAND) begin
				$display("[%0t] [DW=%0d%0d]: Internal Error: Expected WRITE command not in queue!", $time, MEM_DEPTH_IDX, MEM_WIDTH_IDX);
				$finish(1);
			end
			
		end
	end
	else begin
		// Make sure no other command is trying to be active. Otherwise assert.
		if (read_command_pipeline[0] || write_command_pipeline[0]) begin
			$display("[%0t] [DW=%0d%0d]: Internal Error: Active command but read/write pipeline also active!", $time, MEM_DEPTH_IDX, MEM_WIDTH_IDX);
			$finish(1);
		end
	end

	// Process any active command
	mem_dq_en <= 1'b0;
	if (active_command.command != NOP_COMMAND) begin
		if (active_command.command == WRITE_COMMAND) begin
			// The active command is a write, so write to the memory array

			// Check the ck/dk time delta to make sure it's valid
			integer mem_ck_dk_diff;
			integer i;
			integer error;

			error = 0;
			if (MEM_DQS_TO_CLK_CAPTURE_DELAY > 0) begin

				#(MEM_DQS_TO_CLK_CAPTURE_DELAY);

				for (i = 0; i < MEM_WRITE_DQS_WIDTH; i++) begin
					if (mem_ck_time > mem_dk_time[i]) begin
						mem_ck_dk_diff = -(mem_ck_time - mem_dk_time[i]);
					end 
					else begin
						mem_ck_dk_diff = mem_dk_time[i] - mem_ck_time;
					end
					if (mem_ck_dk_diff < -(MEM_CLK_TO_DQS_CAPTURE_DELAY)) begin
						error = 1;
						$display("[%0t] [DW=%0d%0d]: BAD Write: mem_ck=%0t mem_dk[%0d]=%0t delta=%0d min=%0d", 
							 $time, MEM_DEPTH_IDX, MEM_WIDTH_IDX, 
							 mem_ck_time, i, mem_dk_time[i], mem_ck_dk_diff, -(MEM_CLK_TO_DQS_CAPTURE_DELAY));
					end else if (active_command.word_count == 0 && mem_dk[i] == 1'b0) begin
						error = 1;
						$display("[%0t] [DW=%0d%0d]: BAD Write: first write on dk=0: mem_ck=%0t mem_dk[%0d]=%0t delta=%0d min=%0d", 
							 $time, MEM_DEPTH_IDX, MEM_WIDTH_IDX, 
							 mem_ck_time, i, mem_dk_time[i], mem_ck_dk_diff, -(MEM_CLK_TO_DQS_CAPTURE_DELAY));
					end
				end
				if (error) begin
					write_memory({active_command.address, active_command.bank}, active_command.word_count, 'x, 'x);
				end
				else begin
					write_memory({active_command.address, active_command.bank}, active_command.word_count, mem_dq_captured, mem_dm_captured);
				end
			end
			else begin
					write_memory({active_command.address, active_command.bank}, active_command.word_count, mem_dq, mem_dm);
			end
			// Update the word count for this command
			active_command.word_count = active_command.word_count+1;
		end
		if (active_command.command == READ_COMMAND) begin
			// The active command is a read so read from the memory array
			read_memory({active_command.address, active_command.bank}, active_command.word_count, mem_dq_int);
			// Enable the mem_dq to output data
			mem_dq_en <= 1'b1;
			// Update the word count for this command
			active_command.word_count = active_command.word_count+1;
		end
	end
end

// Output onto mem_dq if trying to write back.
assign mem_dq = (mem_dq_en) ? mem_dq_int : 'Z;



`ifdef ENABLE_UNIPHY_FCOV

covergroup uniphy_cg_rldram_read_write_ref_banks;
	bank: coverpoint new_command.bank {
		bins bank[] = {[0:NUM_BANKS-1]};
	}
	command: coverpoint new_command.command {
		bins read = {READ_COMMAND};
		bins write = {WRITE_COMMAND};
		bins refresh = {REF_COMMAND};
	}
	cross bank, command;

  option.per_instance = 1;
endgroup

uniphy_cg_rldram_read_write_ref_banks uniphy_cg_rldram_read_write_ref_banks_cg;

initial begin
	uniphy_cg_rldram_read_write_ref_banks_cg = new();
end

always @ (mem_ck_int) begin
	if (mem_ck_int) begin
		#1 uniphy_cg_rldram_read_write_ref_banks_cg.sample();
	end
end

`endif



// synthesis translate_on
endmodule
