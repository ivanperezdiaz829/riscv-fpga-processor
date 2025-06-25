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
// File name: alt_mem_if_qdrii_mem_model.sv
// This is the generic QDR II/II+ memory model for use with the UniPHY memory interface
// Note that this model is only provided as an example and is designed only
// to demonstrate the features of the UniPHY memory interface.
// ******************************************************************************************************************************** 

`timescale 1 ps / 1 ps

module alt_mem_if_qdrii_mem_model (
	mem_a,
	mem_bws_n,
	mem_cq,
	mem_cqn,
	mem_d,
	mem_k,
	mem_k_n,
	mem_q,
	mem_rps_n,
	mem_wps_n,
	mem_doff_n
);

// ******************************************************************************************************************************** 
// BEGIN PARAMETER SECTION
// All parameters default to "" will have their values passed in from the toplevel testbench 

// Memory device specific parameters, they are set according to the memory spec.
parameter MEM_ADDR_WIDTH       = ""; 
parameter MEM_DM_WIDTH         = ""; 
parameter MEM_READ_DQS_WIDTH   = ""; 
parameter MEM_WRITE_DQS_WIDTH  = ""; 
parameter MEM_DQ_WIDTH            = ""; 
parameter MEM_T_RL                = ""; 
parameter MEM_T_WL                = ""; 
parameter MEM_BURST_LENGTH        = ""; 

parameter MEM_GUARANTEED_WRITE_INIT = 0;
parameter MEM_DEPTH_IDX = -1;
parameter MEM_WIDTH_IDX = -1;

parameter MEM_SUPPRESS_CMD_TIMING_ERROR = 0;

parameter MEM_VERBOSE = 1;

// END PARAMETER SECTION
// ******************************************************************************************************************************** 

// ******************************************************************************************************************************** 
// BEGIN LOCALPARAM SECTION

// The maximum latency possible for any configuration.
// This is used only to size command queues.
localparam MAX_LATENCY = 10;

// The maximum burst possible for any configuration.
// This is used to size burst counters.
localparam MAX_BURST = 8;

// The maximum number of byte selects. 
// This is used to size byte enable counters.
localparam MAX_BYTE_SEL = 4;

// The size of each memory byte. This is the memory width
// divided by the number of byte enables
localparam MEM_BYTE_WIDTH = MEM_DQ_WIDTH/MEM_DM_WIDTH;


// END LOCALPARAM SECTION
// ******************************************************************************************************************************** 

// ******************************************************************************************************************************** 
// BEGIN PORT SECTION

input	[MEM_ADDR_WIDTH-1:0]	mem_a;   // Memory address
input	[MEM_DM_WIDTH-1:0]	mem_bws_n;   // Memory byte write select
output	logic [MEM_READ_DQS_WIDTH-1:0]	mem_cq; // Memory echo clock.
output	logic [MEM_READ_DQS_WIDTH-1:0]	mem_cqn; // Memory echo clock. Pseudo differential version of mem_cq.
input	[MEM_DQ_WIDTH-1:0]	mem_d;  // Memory data input
input	[MEM_WRITE_DQS_WIDTH-1:0]	mem_k;  // Memory input clock.
input	[MEM_WRITE_DQS_WIDTH-1:0]	mem_k_n;  // Memory input clock. Pseudo differential version of mem_k.
output	logic [MEM_DQ_WIDTH-1:0]	mem_q; // Memory data output
input	mem_rps_n; // Memory read port select
input	mem_wps_n;  // Memory write port select
input	mem_doff_n;	// Memory DLL-off 

// END PORT SECTION
// ******************************************************************************************************************************** 


//synthesis translate_off

// Memory parameters based on configuration.
// These are passed in as strings from the _hw.tcl wrapper to translate them
// into real strings so atoreal can be used to convert them to reals.
string MEM_T_RL_STR = string'(MEM_T_RL);
int tRL_cycles;
int tWL_cycles;

// pipelined version of commands, data and clocks. Used by some configurations
logic last_mem_wps_n;
logic [MEM_DQ_WIDTH-1:0] last_mem_d;
logic [MEM_DM_WIDTH-1:0]	last_mem_bws_n;

// The clock cycle counter
int clock_cycle;

// The last clock cycle when a read occurred
int last_read_cycle;

// The last clock cycle when a write occurred
int last_write_cycle;

// The address of the memory array (mem_data). We make this
// a packed struct so that it can be used directly as the
// index to mem_data. 
typedef struct packed {
	bit [MEM_ADDR_WIDTH-1:0] address;
	bit [MAX_BURST-1:0] burst_num;
	bit [MAX_BYTE_SEL-1:0] byte_num;
} address_burst_type;

// The actual memory. Modeled as an associative array.
bit [MEM_BYTE_WIDTH-1:0] mem_data[address_burst_type];

// Command struct of possible memory commands
typedef enum {
	NOP_COMMAND,
	READ_COMMAND,
	WRITE_COMMAND
} command_type;

// Define the type address_type for quick 
// reference
typedef bit [MEM_ADDR_WIDTH-1:0]	address_type;

// Structure of memory operations. This includes the memory command
// and the address it operates on.
typedef struct {
	command_type command;
	int word_count;
	address_type address;
} command_struct;


// Some simulators like NCsim don't yet support queues or arrays of structs
// as a result, unpack the command_struct. Once NCsim supports dynamic structures
// of structs this will be replaced by a queue of command_struct.
command_type read_command_queue[$];
int read_word_count_queue[$];
address_type read_address_queue[$];

command_type write_command_queue[$];
int write_word_count_queue[$];
address_type write_address_queue[$];

// Create a variable for the current active command. There is one for read and write.
command_struct active_read_command;
command_struct active_write_command;

// Create a variable for the current new command. There is one for read and write.
command_struct new_read_command;
command_struct new_write_command;

// Command pipelines to ensure read/write latency is met
bit [2*MAX_LATENCY-1:0] read_command_pipeline;
bit [2*MAX_LATENCY-1:0] write_command_pipeline;
	
// Internal version of the mem_cq clock
wire mem_cq_int;

// Internal version of mem_k based on differential clock
logic mem_k_int;
always @(posedge mem_k)   mem_k_int <= mem_k;
always @(posedge mem_k_n) mem_k_int <= ~mem_k_n;

`ifdef ENABLE_UNIPHY_SIM_SVA

parameter MAX_CYCLES_BETWEEN_ACTIVITY = 1000000;

generate
if (MAX_CYCLES_BETWEEN_ACTIVITY > 0)
begin
	reg startup_active = 0;

	initial 
	begin
		@(posedge mem_k);
		startup_active <= 1;
		@(posedge mem_k);
		startup_active <= 0;
	end

	mem_hang: assert property(memory_active)
		else $fatal(0, "No activity in %0d cycles", MAX_CYCLES_BETWEEN_ACTIVITY);
	
	property memory_active;
		@(posedge mem_k)
			(~(mem_rps_n & mem_wps_n) | startup_active) |-> ##[1:MAX_CYCLES_BETWEEN_ACTIVITY] ~(mem_rps_n & mem_wps_n);
	endproperty
end
endgenerate

`endif 


// ******************************************************************************************************************************** 
// BEGIN TASKS AND FUNCTIONS SECTION

// Task: nop_command
// Description: Executes any model commands required when a NOP is received
task automatic nop_command;
endtask

// Task: read_command
// Description: Executes any model commands required when a read command is received.
//     This includes creating the new command and pushing it in the queue.
task automatic read_command;
	
	if ((clock_cycle - last_read_cycle) >= MEM_BURST_LENGTH/2) begin
		if (MEM_VERBOSE)
			$display("[%0t] [DW=%0d%0d]: READ Command to address %0h ", $time, MEM_DEPTH_IDX, MEM_WIDTH_IDX, mem_a);
		new_read_command.word_count = 0;
	
		// Create the command and push it on the command queus
		read_command_queue.push_back(new_read_command.command);
		read_word_count_queue.push_back(new_read_command.word_count);
		read_address_queue.push_back(new_read_command.address);
	
		// Update the read pipeline so the read will become active at the correct
		// clock cycle
		read_command_pipeline[tRL_cycles-1] <= 1;
		
		last_read_cycle = clock_cycle;
	end
		
endtask

// Task: write_command
// Description: Executes any model commands required when a write command is received.
//     This includes creating the new command and pushing it in the queue.
task automatic write_command;
	
	if (MEM_BURST_LENGTH == 2) begin
		// In burst length 2, there is 0 write latency
		// so we already have all the data

		if (MEM_VERBOSE)
			$display("[%0t] [DW=%0d%0d]: Write Command to address %0h", $time, MEM_DEPTH_IDX, MEM_WIDTH_IDX, mem_a);
		write_memory(mem_a, 0, last_mem_d, last_mem_bws_n);
		write_memory(mem_a, 1, mem_d, mem_bws_n);
	end
	else begin
		if ((clock_cycle - last_write_cycle) >= MEM_BURST_LENGTH/2) begin
			if (MEM_VERBOSE)
				$display("[%0t] [DW=%0d%0d]: Write Command to address %0h", $time, MEM_DEPTH_IDX, MEM_WIDTH_IDX, mem_a);
		
			new_write_command.word_count = 0;
		
			// Create the command and push it on the command queue
			write_command_queue.push_back(new_write_command.command);
			write_word_count_queue.push_back(new_write_command.word_count);
			write_address_queue.push_back(new_write_command.address);
		
			// Update the write pipeline so the command will be active at the correct
			// clock cycle.
			write_command_pipeline[tWL_cycles-1] <= 1;
		
			last_write_cycle = clock_cycle;
		end
	end
	

endtask

task init_guaranteed_write;
	
	int i;

	bit [MEM_ADDR_WIDTH-1:0] addr;
	bit [MEM_DQ_WIDTH-1:0] data;
	
	$display("Pre-initializing memory for guaranteed write");

	addr = 0;
	data = 72'hAAD56AB55AAD56AB55;	
	for (i = 0; i < MEM_BURST_LENGTH; i++)
	begin
		write_memory(addr, i, {(MEM_DQ_WIDTH/9){9'b101010101}}, '0);
	end

	addr = 1;
	data = 72'h552A954AA552A954AA;	
	for (i = 0; i < MEM_BURST_LENGTH; i++)
	begin
		write_memory(addr, i, {(MEM_DQ_WIDTH/9){9'b010101010}}, '0);
	end

endtask

// Task: check_read_violations
// Description: Checks to make sure there are no violations based on the new read command
task automatic check_read_violations;
		
	if (new_read_command.command != NOP_COMMAND) begin
		// Check READ->READ. Make sure that command is 1/2 burst length after previous command
		// to avoid collision on D BUS.
		if (new_read_command.command == READ_COMMAND)
			if ((clock_cycle - last_read_cycle) < MEM_BURST_LENGTH/2) begin
				if (MEM_SUPPRESS_CMD_TIMING_ERROR == 1) begin
					if (MEM_VERBOSE)
						$display("[%0t] [DW=%0d%0d]: WARNING: Burst length read violated", $time, MEM_DEPTH_IDX, MEM_WIDTH_IDX);
				end
				else begin
					$display("[%0t] [DW=%0d%0d]: ERROR: Burst length read violated", $time, MEM_DEPTH_IDX, MEM_WIDTH_IDX);
					$finish(1);
				end
			end
	end	
endtask

// Task: check_write_violations
// Description: Checks to make sure there are no violations based on the new write command
task automatic check_write_violations;
		
	if (new_write_command.command != NOP_COMMAND) begin
		// Check WRITE->WRITE. Make sure that command 1/2 burst
		// length after previous command to avoid collision on Q BUS.
		if (new_write_command.command == WRITE_COMMAND)
			if ((clock_cycle - last_write_cycle) < MEM_BURST_LENGTH/2) begin
				if (MEM_SUPPRESS_CMD_TIMING_ERROR == 1) begin
					if (MEM_VERBOSE)
						$display("[%0t] [DW=%0d%0d]: WARNING: Burst length write violated", $time, MEM_DEPTH_IDX, MEM_WIDTH_IDX);
				end
				else begin
					$display("[%0t] [DW=%0d%0d]: ERROR: Burst length write violated", $time, MEM_DEPTH_IDX, MEM_WIDTH_IDX);
					$finish(1);
				end
			end
	end	
endtask

// Task: check_doff_n_violations
// Description: Checks to make sure doff_n is HIGH 
task automatic check_doff_n_is_high;
	if (mem_doff_n != 1'b1) begin
		if (MEM_SUPPRESS_CMD_TIMING_ERROR == 1) begin
			if (MEM_VERBOSE)
				$display("[%0t] [DW=%0d%0d]: WARNING: mem_doff_n must be high after clock stabilizes", $time, MEM_DEPTH_IDX, MEM_WIDTH_IDX);
		end
		else begin
			$display("[%0t] [DW=%0d%0d]: ERROR: mem_doff_n must be high after clock stabilizes", $time, MEM_DEPTH_IDX, MEM_WIDTH_IDX);
			$finish(1);
		end
	end
endtask


// Task: write_memory
// Parameters:
//      mem_address  : The address to write to
//      burst_num    : The burst number of this write
//      write_data   : The data to write
//      mem_dm       : The data mask for this burst
// Description: Writes the given data to the memory array
task write_memory(
	input [MEM_ADDR_WIDTH-1:0] mem_address, 
	input int burst_num,
	input [MEM_DQ_WIDTH-1:0] write_data,
	input [MEM_DM_WIDTH-1:0] mem_dm);
	address_burst_type address_burst;
	int i;
	
	if (MEM_VERBOSE)
		$display("[%0t] [DW=%0d%0d]: Writing data %h to address %0h burst %0d", $time, MEM_DEPTH_IDX, MEM_WIDTH_IDX, write_data, mem_address, burst_num);

	for (i = 0; i < MEM_DM_WIDTH; i++) begin
		
		// Create the address structure
		address_burst.address = mem_address;
		address_burst.burst_num = burst_num;
		address_burst.byte_num = i;
		
		if (MEM_VERBOSE)
			$display("[%0t] [DW=%0d%0d]: Writing data %h to address %0h burst %0d byte %0d", $time, MEM_DEPTH_IDX, MEM_WIDTH_IDX, write_data, mem_address, burst_num, i);
		if (mem_dm[i] === 1'b1)  begin
			if (MEM_VERBOSE)
				$display("[%0t] [DW=%0d%0d]: Data mask enabled. No data written for byte %0d.", $time, MEM_DEPTH_IDX, MEM_WIDTH_IDX, i);
		end
		else if (mem_dm[i] === 1'b0) 
			// Write to the actual memory
			case (i)
				0: mem_data[address_burst] = write_data[MEM_BYTE_WIDTH-1:0];
				1: mem_data[address_burst] = write_data[2*MEM_BYTE_WIDTH-1:1*MEM_BYTE_WIDTH];
				2: mem_data[address_burst] = write_data[3*MEM_BYTE_WIDTH-1:2*MEM_BYTE_WIDTH];
				3: mem_data[address_burst] = write_data[4*MEM_BYTE_WIDTH-1:3*MEM_BYTE_WIDTH];
				default : begin
					$display("[%0t] [DW=%0d%0d]: Internal Error: Unexpected byte mask %0d!", $time, MEM_DEPTH_IDX, MEM_WIDTH_IDX, i);
					$finish(1);
				end
			endcase
		else begin
			$display("[%0t] [DW=%0d%0d]: ERROR: Invalid byte mask %0h!", $time, MEM_DEPTH_IDX, MEM_WIDTH_IDX, mem_dm[i]);
			mem_data[address_burst] = 'x;
		end
	end
	
endtask

// Task: read_memory
// Parameters:
//      mem_address  : The address to read from
//      burst_num    : The burst number of this write
// Description: Reads the memory array for the given address/burst
task read_memory(
	input [MEM_ADDR_WIDTH-1:0] mem_address,
	input int burst_num,
	output [MEM_DQ_WIDTH-1:0] data_read);
	address_burst_type address_burst;
	int i;
	
	for (i = 0; i < MEM_DM_WIDTH; i++) begin
		// Create the address structure
		address_burst.address = mem_address;
		address_burst.burst_num = burst_num;
		address_burst.byte_num = i;
		

		if (mem_data.exists(address_burst)) begin
			// If the memory address exists then read from it. 
			if (MEM_VERBOSE)
				$display("[%0t] [DW=%0d%0d]: Reading data %h from address %0h burst %0d byte %0d", 
					 $time, MEM_DEPTH_IDX, MEM_WIDTH_IDX, mem_data[address_burst], mem_address, burst_num, i);
			case (i)
				0: data_read[MEM_BYTE_WIDTH-1:0] = mem_data[address_burst];
				1: data_read[2*MEM_BYTE_WIDTH-1:1*MEM_BYTE_WIDTH] = mem_data[address_burst];
				2: data_read[3*MEM_BYTE_WIDTH-1:2*MEM_BYTE_WIDTH] = mem_data[address_burst];
				3: data_read[4*MEM_BYTE_WIDTH-1:3*MEM_BYTE_WIDTH] = mem_data[address_burst];
				default : begin
					$display("[%0t] [DW=%0d%0d]: Internal Error: Unexpected byte mask %0d!", $time, MEM_DEPTH_IDX, MEM_WIDTH_IDX, i);
					$finish(1);
				end
			endcase
		end
		else begin
			// If the memory address does not exists then write out X
			if (MEM_VERBOSE)
				$display("[%0t] [DW=%0d%0d]: WARNING: Attempting to read from uninitialized address %0h burst %0d byte %0d", 
					 $time, MEM_DEPTH_IDX, MEM_WIDTH_IDX, mem_address, burst_num, i);
			case (i)
				0: data_read[MEM_BYTE_WIDTH-1:0] = 'X;
				1: data_read[2*MEM_BYTE_WIDTH-1:1*MEM_BYTE_WIDTH] = 'X;
				2: data_read[3*MEM_BYTE_WIDTH-1:2*MEM_BYTE_WIDTH] = 'X;
				3: data_read[4*MEM_BYTE_WIDTH-1:3*MEM_BYTE_WIDTH] = 'X;
				default : begin
					$display("[%0t] [DW=%0d%0d]: Internal Error: Unexpected byte mask %0d!", $time, MEM_DEPTH_IDX, MEM_WIDTH_IDX, i);
					$finish(1);
				end
			endcase
		end
	end
	if (MEM_VERBOSE)
		$display("[%0t] [DW=%0d%0d]: Reading data %h from address %0h burst %0d", $time, MEM_DEPTH_IDX, MEM_WIDTH_IDX, data_read, mem_address, burst_num);
endtask

// END TASKS AND FUNCTIONS SECTION
// ******************************************************************************************************************************** 

// Initialize the cycle counters based on the memory parameters
initial begin
	MEM_T_RL_STR = string'(MEM_T_RL);
	tRL_cycles = (2*MEM_T_RL_STR.atoreal());
	tWL_cycles = (2*MEM_T_WL);
end

// Initialize variable and queues
initial begin
	int i;
	
	$display("[%0t] [DW=%0d%0d]: Altera Generic QDR II/II+ Memory Model", $time, MEM_DEPTH_IDX, MEM_WIDTH_IDX);
	
	// Clear the clock cycle counter
	clock_cycle = 0;
	
	last_read_cycle = 0;
	last_write_cycle = 0;

	// Delete the memory
	mem_data.delete();
	
	// Delete the existing command queues by iterating through the queues
	while (read_command_queue.size() > 0)
		read_command_queue.delete(0);

	while (read_word_count_queue.size() > 0)
		read_word_count_queue.delete(0);

	while (read_address_queue.size() > 0)
		read_address_queue.delete(0);

	while (write_command_queue.size() > 0)
		write_command_queue.delete(0);

	while (write_word_count_queue.size() > 0)
		write_word_count_queue.delete(0);

	while (write_address_queue.size() > 0)
		write_address_queue.delete(0);

	// Make the active command a NOP
	active_read_command.command <= NOP_COMMAND;
	active_write_command.command <= NOP_COMMAND;
	
	// Clear the command pipelines
	for (i = 0; i < 2*MAX_LATENCY; i++) begin
		read_command_pipeline[i] = 0;
		write_command_pipeline[i] = 0;
	end
	
	if (MEM_GUARANTEED_WRITE_INIT)
	begin
		init_guaranteed_write();
	end

end

// Generate the mem_cq clock from the mem_k clock;
assign mem_cq_int = mem_k;

// Update the clock cycle counter
always @ (posedge mem_k_int)
	clock_cycle <= clock_cycle+1;

// Generate the outputs. Assume 0 skew
always @ (mem_cq_int) begin
	mem_cq <= {MEM_READ_DQS_WIDTH{mem_cq_int}};
	mem_cqn <= ~{MEM_READ_DQS_WIDTH{mem_cq_int}};
end

// Assert that mem_doff_n is LOW at startup. It'll become HIGH later.
always @ (posedge mem_k_int)
	if (clock_cycle == 0 && mem_doff_n != 1'b0) begin
		$display("[%0t] [DW=%0d%0d]: Internal Error: mem_doff_n must be LOW during power-up when clock may not be stable!", $time, MEM_DEPTH_IDX, MEM_WIDTH_IDX);
		$finish(1);
	end

// Main process for read port commands
always @ (mem_k_int) begin
	
	// Shift the command pipelines
	read_command_pipeline <= {1'b0, read_command_pipeline[2*MAX_LATENCY-1:1]};
	
	// Operate on the positive edge of the clock
	if (mem_k_int) begin
		// Process the new commands on the pins
		new_read_command.address = mem_a;
		new_read_command.word_count = 0;
		if (mem_rps_n == 1'b0) begin
			new_read_command.command = READ_COMMAND;
			// Check for violations based on this command
			check_read_violations();
			
			// When doing a read, we assume clock is stable.
			// Assert that doff_n is HIGH at this point.
			check_doff_n_is_high();
		end
		else 
			new_read_command.command = NOP_COMMAND;
		
		// Run the appropriate tasks based on the new command
		case (new_read_command.command)
			NOP_COMMAND : nop_command();
			READ_COMMAND : read_command();
		endcase
	end
	
	if (read_command_pipeline[0])
		if (read_command_queue.size() == 0) begin
			$display("[%0t] [DW=%0d%0d]: Internal Error: Command queue empty but read commands expected!", $time, MEM_DEPTH_IDX, MEM_WIDTH_IDX);
			$finish(1);
		end

	// Determine if any active command is finished
	if (active_read_command.command != NOP_COMMAND)
		if (active_read_command.word_count == MEM_BURST_LENGTH)
			active_read_command.command = NOP_COMMAND;
	

	// Is there an active read on this cycle?
	// For a new command to be active, there must be no active command
	// and the read command pipeline must have a 1 in position 0
	// indicating that the appropriate number of clock cycles have passed since
	// the command was issued
	if (active_read_command.command == NOP_COMMAND) begin
		if (read_command_pipeline[0]) begin
			active_read_command.command = read_command_queue.pop_front();
			active_read_command.word_count = read_word_count_queue.pop_front();
			active_read_command.address = read_address_queue.pop_front();

			if (active_read_command.command != READ_COMMAND) begin
				$display("[%0t] [DW=%0d%0d]: Internal Error: Expected READ command not in queue!", $time, MEM_DEPTH_IDX, MEM_WIDTH_IDX);
				$finish(1);
			end
			
		end
	end
	else begin
		// Make sure no other command is trying to be active
		if (read_command_pipeline[0]) begin
			$display("[%0t] [DW=%0d%0d]: Internal Error: Active command but read pipeline also active!", $time, MEM_DEPTH_IDX, MEM_WIDTH_IDX);
			$finish(1);
		end
	end

	// Process any active command
	if (active_read_command.command != NOP_COMMAND) begin
		if (active_read_command.command == READ_COMMAND) begin
			// Read from the memory and update the word count for the operation
			read_memory(active_read_command.address, active_read_command.word_count, mem_q);
			active_read_command.word_count = active_read_command.word_count+1;
		end
	end
	else begin
		// Put mem_q on high-z when not doing a read
		mem_q = 'z;
	end
end


// Main process for write port commands
always @ (mem_k_int) begin
	
	// Shift the command pipelines
	write_command_pipeline <= {1'b0, write_command_pipeline[2*MAX_LATENCY-1:1]};
	
	if (mem_k_int) begin
		last_mem_wps_n <= mem_wps_n;
		last_mem_d <= mem_d;
		last_mem_bws_n <= mem_bws_n;
	end

	// For burst length 2, the address are on the negative edge.
	// Otherwise on the positive edge
	if (MEM_BURST_LENGTH == 2) begin
		if (mem_k_int == 0) begin
			// Process the new commands on the pins
			// If mem_wps_n is 0 then it's a write, but the address
			// comes on the next cycle
			if (last_mem_wps_n == 0) begin
				new_write_command.address = mem_a;
				new_write_command.word_count = 0;
				new_write_command.command = WRITE_COMMAND;
				
				// Check for violations based on this command
				check_write_violations();
				
				// When doing a write, we assume clock is stable.
				// Assert that doff_n is HIGH at this point.
				check_doff_n_is_high();
			end
			else
				new_write_command.command = NOP_COMMAND;
	
			// Run the appropriate tasks to for the given command
			case (new_write_command.command)
				NOP_COMMAND : nop_command();
				WRITE_COMMAND : write_command();
			endcase
		end

	end
	else
		if (mem_k_int) begin
			if (mem_wps_n == 0) begin
				new_write_command.address = mem_a;
				new_write_command.word_count = 0;
				if ((mem_rps_n == 1'b1) && (mem_wps_n == 1'b0)) begin
					new_write_command.command = WRITE_COMMAND;
					
					// Check for violations based on this command
					check_write_violations();

					// When doing a write, we assume clock is stable.
					// Assert that doff_n is HIGH at this point.
					check_doff_n_is_high();
				end
				else begin
					new_write_command.command = NOP_COMMAND;
				end
			end
			else
				new_write_command.command = NOP_COMMAND;
	
			// Run the appropriate tasks to for the given command
			case (new_write_command.command)
				NOP_COMMAND : nop_command();
				WRITE_COMMAND : write_command();
			endcase
		end
		
	
	if (write_command_pipeline[0])
		if (write_command_queue.size() == 0) begin
			$display("[%0t] [DW=%0d%0d]: Internal Error: Command queue empty but commands expected!", $time, MEM_DEPTH_IDX, MEM_WIDTH_IDX);
			$finish(1);
		end

	// Determine if any active command is finished
	if (active_write_command.command != NOP_COMMAND)
		if (active_write_command.word_count == MEM_BURST_LENGTH)
			// Command complete
			active_write_command.command = NOP_COMMAND;
	

	// Is there an active write on this cycle?
	// For a new command to be active, there must be no active command
	// and the write command pipeline must have a 1 in position 0
	// indicating that the appropriate number of clock cycles have passed since
	// the command was issued
	if (active_write_command.command == NOP_COMMAND) begin
		if (write_command_pipeline[0]) begin
			active_write_command.command = write_command_queue.pop_front();
			active_write_command.word_count = write_word_count_queue.pop_front();
			active_write_command.address = write_address_queue.pop_front();
			if (active_write_command.command != WRITE_COMMAND) begin
				$display("[%0t] [DW=%0d%0d]: Internal Error: Expected WRITE command not in queue!", $time, MEM_DEPTH_IDX, MEM_WIDTH_IDX);
				$finish(1);
			end
			
		end
	end
	else begin
		// Make sure no other command is trying to be active
		if (write_command_pipeline[0]) begin
			$display("[%0t] [DW=%0d%0d]: Internal Error: Active command but write pipeline also active!", $time, MEM_DEPTH_IDX, MEM_WIDTH_IDX);
			$finish(1);
		end
	end

	// Process any active command
	if (active_write_command.command != NOP_COMMAND) begin
		if (active_write_command.command == WRITE_COMMAND) begin
			// Write to the memory array and update the word count for the operation
			write_memory(active_write_command.address, active_write_command.word_count, mem_d, mem_bws_n);
			active_write_command.word_count = active_write_command.word_count+1;
		end
	end
end


`ifdef ENABLE_UNIPHY_FCOV

covergroup uniphy_cg_qdrii_write;
	command: coverpoint new_write_command.command {
		bins write = {WRITE_COMMAND};
	}

  option.per_instance = 1;
endgroup

covergroup uniphy_cg_qdrii_read;
	command: coverpoint new_read_command.command {
		bins read = {READ_COMMAND};
	}

  option.per_instance = 1;
endgroup

uniphy_cg_qdrii_write uniphy_cg_qdrii_write_cg;
uniphy_cg_qdrii_read uniphy_cg_qdrii_read_cg;

initial begin
	uniphy_cg_qdrii_write_cg = new();
	uniphy_cg_qdrii_read_cg = new();
end

always @ (mem_k_int) begin

	// For burst length 2, the address are on the negative edge.
	// Otherwise on the positive edge
	if (MEM_BURST_LENGTH == 2) begin
		if (mem_k_int == 0) begin
			#1 uniphy_cg_qdrii_write_cg.sample();
			#1 uniphy_cg_qdrii_read_cg.sample();
		end
	end
	else begin
		if (mem_k_int == 1) begin
			#1 uniphy_cg_qdrii_write_cg.sample();
			#1 uniphy_cg_qdrii_read_cg.sample();
		end
	end
end


`endif


//synthesis translate_on

endmodule
