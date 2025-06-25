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
// File name: data_corrupter.sv
// This is an add-ons feature for RLDRAM II memory model for use with the UniPHY memory interface
// Note that this model is only provided as an example and is designed only
// to exercise Error Detection Parity features of the UniPHY memory interface.
// ******************************************************************************************************************************** 

`timescale 1 ps / 1 ps

module data_corrupter(
	clk,
	reset_n,
	enable_corruption,
	mem_cs_n,
	mem_we_n,
	mem_ref_n,
	ctrl_data,
	mem_data,
	corrupted_burst,
	corrupted_bits,
	do_compare,
	expected_pbe
);

//////////////////////////////////////////////////////////////////////////////
// BEGIN PARAMETER SECTION

// Based on user selected memory interface configuration
parameter MEM_READ_DQS_WIDTH		= "";
parameter MEM_CONTROL_WIDTH			= "";
parameter MEM_IF_CS_WIDTH			= "";
parameter MEM_IF_DWIDTH				= "";
parameter AVL_DWIDTH				= "";
parameter MEM_T_RL					= "";
parameter MEM_BURST_LENGTH			= "";
parameter RATE						= "";

// Injection setting
parameter ERR_INJECT_READS_PER_ERR	= "";
parameter ERR_INJECT_BITS			= "";

// END PARAMETER SECTION
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// BEGIN LOCALPARAM SECTION

localparam AVL_NUM_BYTES					= AVL_DWIDTH / 8;
localparam MEM_NUM_BYTES					= MEM_IF_DWIDTH / 9;
localparam MEM_BURST_PER_AVL_LENGTH			= AVL_DWIDTH / 8 * 9 / MEM_IF_DWIDTH;
localparam MEM_BURST_PER_AVL_WIDTH			= ceil_log2(MEM_BURST_PER_AVL_LENGTH);
localparam MEM_BURST_WIDTH					= ceil_log2(MEM_BURST_LENGTH);
localparam ERR_INJECT_READS_PER_ERR_WIDTH	= ceil_log2(ERR_INJECT_READS_PER_ERR);
localparam READ_CMD_TO_LAST_MEM_BURST_DELAY	= (MEM_BURST_LENGTH / 2) + MEM_T_RL;
// Parameter below is fix and subject to the PHY changes
localparam PHY_READ_DELAY					= 7;

// END LOCALPARAM SECTION
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// BEGIN PORT SECTION

// Clock and reset signals
input [MEM_READ_DQS_WIDTH-1:0]	clk;
input							reset_n;

// Module control signal
input							enable_corruption;

// Memory commands signals
input [MEM_IF_CS_WIDTH-1:0]		mem_cs_n;
input [MEM_CONTROL_WIDTH-1:0]	mem_we_n;
input [MEM_CONTROL_WIDTH-1:0]	mem_ref_n;

// Data bus signals
inout [MEM_IF_DWIDTH-1:0]		ctrl_data;
inout [MEM_IF_DWIDTH-1:0]		mem_data;

// Output signals
output [MEM_BURST_WIDTH-1:0]	corrupted_burst;
output [MEM_IF_DWIDTH-1:0]		corrupted_bits;
output 							do_compare;
output [AVL_NUM_BYTES-1:0] 		expected_pbe;

// END PORT SECTION
//////////////////////////////////////////////////////////////////////////////

// Test stages definition
typedef enum int unsigned {
	INIT,
	PER_BIT_CORRUPTION,
	PER_BYTE_CORRUPTION,
	PER_BIT_ALL_BURST_CORRUPTION,
	PER_BYTE_ALL_BURST_CORRUPTION,
	DONE
} test_stage_t;

// Internal version of data bus signals
reg [MEM_IF_DWIDTH-1:0]						write_to_ctrl;
reg [MEM_IF_DWIDTH-1:0]						write_to_mem;

// Simplified version of memory read command
wire										read_cmd_to_mem;

// Internal version of read data valid
wire										mem_rdata_valid;

// Injection control
wire										do_injection;

// Signals use for generating output signal
wire [MEM_IF_DWIDTH-1:0]					valid_corrupted_bits;
wire [MEM_NUM_BYTES-1:0]					partial_expected_pbe;
wire [AVL_NUM_BYTES-1:0]					full_expected_pbe;
wire 										valid_expected_pbe;

// Indicate current test stage has reached the last injection pattern
wire										last_combination;

// Current signals for current clock cycle.
test_stage_t								stage;
logic [MEM_IF_DWIDTH-1:0]					target_bits;
logic [MEM_BURST_WIDTH-1:0]					target_burst;
logic [ERR_INJECT_READS_PER_ERR_WIDTH-1:0]	reads_counter;
logic [MEM_BURST_WIDTH-1:0]					mem_burst_counter;
logic [MEM_BURST_PER_AVL_WIDTH-1:0] 		mem_burst_per_avl_counter;
logic [AVL_NUM_BYTES-1:0] 					delayed_expected_pbe [PHY_READ_DELAY - 1 : 0];
logic										delayed_valid_expected_pbe [PHY_READ_DELAY - 1 : 0];
logic [MEM_IF_DWIDTH-1:0]					delayed_target_bits [PHY_READ_DELAY - 1 : 0];
logic [MEM_BURST_WIDTH-1:0] 				delayed_target_burst [PHY_READ_DELAY - 1 : 0];
logic [AVL_NUM_BYTES-1:0]					partial_expected_pbe_reg;

// Registered signals for positive clock cycle
test_stage_t								stage_pos;
reg [READ_CMD_TO_LAST_MEM_BURST_DELAY:0] 	delayed_cmd;
reg	[MEM_IF_DWIDTH-1:0]						target_bits_pos;
reg	[MEM_BURST_WIDTH-1:0]					target_burst_pos;
reg [ERR_INJECT_READS_PER_ERR_WIDTH-1:0]	reads_counter_pos;
reg [MEM_BURST_WIDTH-1:0]					mem_burst_counter_pos;
reg [MEM_BURST_PER_AVL_WIDTH-1:0] 			mem_burst_per_avl_counter_pos;
reg [AVL_NUM_BYTES-1:0] 					delayed_expected_pbe_pos [PHY_READ_DELAY - 1 : 0];
reg											delayed_valid_expected_pbe_pos [PHY_READ_DELAY - 1 : 0];
reg [MEM_IF_DWIDTH-1:0]						delayed_target_bits_pos [PHY_READ_DELAY - 1 : 0];
reg [MEM_BURST_WIDTH-1:0] 					delayed_target_burst_pos [PHY_READ_DELAY - 1 : 0];
reg	[AVL_NUM_BYTES-1:0]						partial_expected_pbe_reg_pos;

// Registered signals for negative clock cycle
test_stage_t								stage_neg;
reg	[MEM_IF_DWIDTH-1:0]						target_bits_neg;
reg	[MEM_BURST_WIDTH-1:0]					target_burst_neg;
reg [ERR_INJECT_READS_PER_ERR_WIDTH-1:0]	reads_counter_neg;
reg [MEM_BURST_WIDTH-1:0]					mem_burst_counter_neg;
reg [MEM_BURST_PER_AVL_WIDTH-1:0] 			mem_burst_per_avl_counter_neg;
reg [AVL_NUM_BYTES-1:0] 					delayed_expected_pbe_neg [PHY_READ_DELAY - 1 : 0];
reg											delayed_valid_expected_pbe_neg [PHY_READ_DELAY - 1 : 0];
reg [MEM_IF_DWIDTH-1:0]						delayed_target_bits_neg [PHY_READ_DELAY - 1 : 0];
reg [MEM_BURST_WIDTH-1:0] 					delayed_target_burst_neg [PHY_READ_DELAY - 1 : 0];
reg	[AVL_NUM_BYTES-1:0]						partial_expected_pbe_reg_neg;

// Generate simpliefied version of read command
assign read_cmd_to_mem		= (mem_we_n && !mem_cs_n && mem_ref_n);

// Generate internal version of read data valid based on delayed read command
// and number of memory burst. Not all read data indicate by this signals is
// to be read back to local as it will be mask again by afi/avl_rdata_valid
assign mem_rdata_valid		= |(delayed_cmd[READ_CMD_TO_LAST_MEM_BURST_DELAY - 1: MEM_T_RL]);

// Determine whether controller or memory get the data on the data bus
assign ctrl_data 			= (!mem_rdata_valid) ? 'Z : write_to_ctrl;
assign mem_data 			= (mem_rdata_valid) ? 'Z : write_to_mem;

// Generate injection's control signal
assign do_injection 		= (mem_rdata_valid && enable_corruption && (target_burst == mem_burst_counter) && (reads_counter == ERR_INJECT_READS_PER_ERR - 1));

// Generate valid signals to capture the correct and complete injection signals
assign valid_corrupted_bits = (target_bits & {MEM_IF_DWIDTH{do_injection}});
assign valid_expected_pbe	= (mem_rdata_valid && enable_corruption && (mem_burst_per_avl_counter == (MEM_BURST_PER_AVL_LENGTH - 1)));

// Generate the module output
assign expected_pbe			= delayed_expected_pbe[PHY_READ_DELAY - 1];
assign do_compare			= delayed_valid_expected_pbe[PHY_READ_DELAY - 1];
assign corrupted_bits		= delayed_target_bits[PHY_READ_DELAY - 1];
assign corrupted_burst 		= delayed_target_burst[PHY_READ_DELAY - 1];

// Determine test completion
assign last_combination 	= ((target_burst == (MEM_BURST_LENGTH - 1)) && (target_bits[MEM_IF_DWIDTH - 1]));

// Test stages state machine
task automatic identify_test_stage;

	output  test_stage_t							stage_task;

	if (!reset_n)
		stage_task = INIT;
	else
		case (stage)

			INIT:
				// Start test immediately after enable_corruption is asserted
				if (enable_corruption)
					stage_task = PER_BIT_CORRUPTION;
				else
					stage_task = INIT;

			PER_BIT_CORRUPTION:
				// Perform per bit corruption for every read process
				if (last_combination)
					stage_task = PER_BYTE_CORRUPTION;
				else
					stage_task = PER_BIT_CORRUPTION;

			PER_BYTE_CORRUPTION:
				// Perform per byte corruption for every read process
				if (last_combination)
					stage_task = PER_BIT_ALL_BURST_CORRUPTION;
				else
					stage_task = PER_BYTE_CORRUPTION;

			PER_BIT_ALL_BURST_CORRUPTION:
				// Perform per bit corruption on each memory burst for every read process
				if (last_combination)
					stage_task = PER_BYTE_ALL_BURST_CORRUPTION;
				else
					stage_task = PER_BIT_ALL_BURST_CORRUPTION;

			PER_BYTE_ALL_BURST_CORRUPTION:
				// Perform per byte corruption on each memory burst for every read process
				if (last_combination)
					stage_task = DONE;
				else
					stage_task = PER_BYTE_ALL_BURST_CORRUPTION;

			default:
				stage_task = DONE;

		endcase

endtask

// Determine which bit should be corrupted based on the current test stage
task automatic identify_bit_to_corrupt;

	output [MEM_IF_DWIDTH-1:0]						target_bits_task;

	reg	[MEM_IF_DWIDTH-1:0]							target_bits_task;

	if (!reset_n)
		target_bits_task = '0;
	else
		case (stage)
			INIT:
				target_bits_task = target_bits;

			PER_BIT_CORRUPTION:
				// Example of generated target_bit for this stage with
				// memory burst length = 2 dwidth = 18
				// target_bits 	: [0000000000000001][0000000000000000]
				if (last_combination)
					target_bits_task = '0;
				else if ((target_bits == 0) || (target_bits[MEM_IF_DWIDTH - 1]))
					target_bits_task = {target_bits[MEM_IF_DWIDTH-ERR_INJECT_BITS - 1 : 0],{ERR_INJECT_BITS{1'b1}}};
				else if (do_injection && !(target_bits[MEM_IF_DWIDTH - 1]))
					target_bits_task = {target_bits[MEM_IF_DWIDTH - 2:0],1'b0};
				else
					target_bits_task = target_bits;

			PER_BYTE_CORRUPTION:
				// Example of generated target_bit for this stage with
				// memory burst length = 2 dwidth = 18
				// target_bits 	: [0000000100000001][0000000000000000]
				if (last_combination)
					target_bits_task = '0;
				else if (target_bits == 0)
				begin
					target_bits_task = target_bits;
					for (int byte_id = 0; byte_id < MEM_NUM_BYTES; byte_id++)
					begin
						for (int bit_id = 0; bit_id < ERR_INJECT_BITS; bit_id++)
						begin
							target_bits_task[(byte_id * 9 + bit_id)] = 1'b1;
						end
					end
				end
				else if ((target_bits == 0) || (target_bits[MEM_IF_DWIDTH - 1]))
					target_bits_task = '0;
				else if (do_injection && !(target_bits[MEM_IF_DWIDTH-1]))
					target_bits_task = {target_bits[MEM_IF_DWIDTH - 2 : 0],1'b0};
				else
					target_bits_task = target_bits;

			PER_BIT_ALL_BURST_CORRUPTION:
				// Example of generated target_bit for this stage with
				// memory burst length = 2 dwidth = 18
				// target_bits 	: [0000000000000001][0000000000000001]
				if (last_combination)
					target_bits_task = '0;
				else if ((target_bits == 0) || ((target_bits[MEM_IF_DWIDTH - 1]) && (target_burst == (MEM_BURST_LENGTH - 1))))
					target_bits_task = {target_bits[MEM_IF_DWIDTH-ERR_INJECT_BITS - 1 : 0],{ERR_INJECT_BITS{1'b1}}};
				else if (do_injection && !(target_bits[MEM_IF_DWIDTH - 1]) && (target_burst == (MEM_BURST_LENGTH - 1)))
					target_bits_task = {target_bits[MEM_IF_DWIDTH - 2 : 0],1'b0};
				else
					target_bits_task = target_bits;

			PER_BYTE_ALL_BURST_CORRUPTION:
				// Example of generated target_bit for this stage with
				// memory burst length = 2 dwidth = 18
				// target_bits 	: [0000000100000001][0000000100000001]
				if (last_combination)
					target_bits_task = '0;
				else if (target_bits == 0)
				begin
					target_bits_task = target_bits;
					for (int byte_id = 0; byte_id < MEM_NUM_BYTES; byte_id++)
					begin
						for (int bit_id = 0; bit_id < ERR_INJECT_BITS; bit_id++)
						begin
							target_bits_task[(byte_id * 9 + bit_id)] = 1'b1;
						end
					end
				end
				else if ((target_bits == 0) || ((target_bits[MEM_IF_DWIDTH - 1]) && (target_burst == (MEM_BURST_LENGTH - 1))))
					target_bits_task = '0;
				else if (do_injection && !(target_bits[MEM_IF_DWIDTH-1]) && (target_burst == (MEM_BURST_LENGTH - 1)))
					target_bits_task = {target_bits[MEM_IF_DWIDTH - 2 : 0],1'b0};
				else
					target_bits_task = target_bits;

			DONE:
				target_bits_task = '0;

			default:
				target_bits_task = '0;

		endcase

endtask

// Determine which memory burst should be corrupted based on the current test stage
task automatic identify_burst_to_corrupt;

	output [MEM_BURST_WIDTH-1:0]					target_burst_task;

	reg	[MEM_BURST_WIDTH-1:0]						target_burst_task;

	if (!reset_n)
		target_burst_task = '0;
	else
		case (stage)
			INIT:
				target_burst_task = '0;

			PER_BIT_CORRUPTION:
				// Transition to the next burst only happen when MSB bits of
				// the DQ has been corrupted
				if (target_bits[MEM_IF_DWIDTH - 1])
					target_burst_task = target_burst + 1'b1;
				else
					target_burst_task = target_burst;

			PER_BYTE_CORRUPTION:
				// Transition to the next burst only happen when MSB bits of
				// the DQ has been corrupted
				if (target_bits[MEM_IF_DWIDTH - 1])
					target_burst_task = target_burst + 1'b1;
				else
					target_burst_task = target_burst;

			PER_BIT_ALL_BURST_CORRUPTION:
				// Transition to the next burst happen in every half memory
				// clock cycle
				if (mem_rdata_valid)
					target_burst_task = mem_burst_counter + 1'b1;
				else
					target_burst_task = target_burst;

			PER_BYTE_ALL_BURST_CORRUPTION:
				// Transition to the next burst happen in every half memory
				// clock cycle
				if (mem_rdata_valid)
					target_burst_task = mem_burst_counter + 1'b1;
				else
					target_burst_task = target_burst;

			DONE:
				target_burst_task = '0;

			default:
				target_burst_task = '0;

		endcase
endtask

// Count read transaction
task automatic count_reads;

	output [ERR_INJECT_READS_PER_ERR_WIDTH-1:0]		reads_counter_task;

	reg [ERR_INJECT_READS_PER_ERR_WIDTH-1:0]		reads_counter_task;

	if (!reset_n)
		reads_counter_task = '0;
	else
		if (mem_rdata_valid && (mem_burst_counter == (MEM_BURST_LENGTH - 1)) && enable_corruption)
			if (reads_counter == (ERR_INJECT_READS_PER_ERR -1))
				reads_counter_task = '0;
			else
				reads_counter_task = reads_counter + 1'b1;
		else
			reads_counter_task = reads_counter;

endtask

// Count memory burst
task automatic count_mem_burst;

	output [MEM_BURST_WIDTH-1:0]					mem_burst_counter_task;
	output [MEM_BURST_PER_AVL_WIDTH-1:0] 			mem_burst_per_avl_counter_task;

	reg [MEM_BURST_WIDTH-1:0]						mem_burst_counter_task;
	reg [MEM_BURST_PER_AVL_WIDTH-1:0] 				mem_burst_per_avl_counter_task;

	if (!reset_n)
	begin
		mem_burst_counter_task = '0;
		mem_burst_per_avl_counter_task = '0;
	end
	else

		if (mem_rdata_valid)
		begin
			if (mem_burst_counter == (MEM_BURST_LENGTH - 1))
				mem_burst_counter_task = '0;
			else
				mem_burst_counter_task = mem_burst_counter + 1'b1;
    	
			if (mem_burst_per_avl_counter == (MEM_BURST_PER_AVL_LENGTH - 1)) 
				mem_burst_per_avl_counter_task = 0;
			else 
				mem_burst_per_avl_counter_task = mem_burst_per_avl_counter + 1'b1;
		end
		else
		begin
			mem_burst_counter_task = mem_burst_counter;
			mem_burst_per_avl_counter_task = mem_burst_per_avl_counter;
		end

endtask

// Delay the read command to memory by tRL
task automatic delay_read_cmd;

	if (!reset_n)
		delayed_cmd = '0;
	else
	if (read_cmd_to_mem)
		delayed_cmd = {delayed_cmd[READ_CMD_TO_LAST_MEM_BURST_DELAY - 1 : 0],1'b1};
	else
		delayed_cmd = {delayed_cmd[READ_CMD_TO_LAST_MEM_BURST_DELAY - 1 : 0],1'b0};

endtask

// Delay the expected per byte error to match with contoller's parity_error signal
task automatic delay_expected_sig;

	output [AVL_NUM_BYTES-1:0] 						delayed_expected_pbe_task [PHY_READ_DELAY - 1 : 0];
	output											delayed_valid_expected_pbe_task [PHY_READ_DELAY - 1 : 0];
	output [MEM_IF_DWIDTH-1:0]						delayed_target_bits_task [PHY_READ_DELAY - 1 : 0];
	output [MEM_BURST_WIDTH-1:0] 					delayed_target_burst_task [PHY_READ_DELAY - 1 : 0];

	reg [AVL_NUM_BYTES-1:0] 						delayed_expected_pbe_task [PHY_READ_DELAY - 1 : 0];
	reg												delayed_valid_expected_pbe_task [PHY_READ_DELAY - 1 : 0];
	reg [MEM_IF_DWIDTH-1:0]							delayed_target_bits_task [PHY_READ_DELAY - 1 : 0];
	reg [MEM_BURST_WIDTH-1:0] 						delayed_target_burst_task [PHY_READ_DELAY - 1 : 0];

	if (!reset_n)
		for(int count = 0; count < PHY_READ_DELAY; count++)
		begin
			delayed_expected_pbe_task[count] = '0;
			delayed_valid_expected_pbe_task[count] = '0;
			delayed_target_bits_task[count] = '0;
			delayed_target_burst_task[count] = '0;
		end
	else
	begin
		for(int count = 0; count < PHY_READ_DELAY - 1; count++)
		begin
			delayed_expected_pbe_task[count + 1] = delayed_expected_pbe[count];
			delayed_valid_expected_pbe_task[count + 1] = delayed_valid_expected_pbe[count];
			delayed_target_bits_task[count + 1] = delayed_target_bits[count];
			delayed_target_burst_task[count + 1] = delayed_target_burst[count];
		end

		if (valid_expected_pbe)
		begin
			delayed_expected_pbe_task[0] = full_expected_pbe;
			delayed_valid_expected_pbe_task[0] = 1'b1;
		end
		else
		begin
			delayed_expected_pbe_task[0] = '0;
			delayed_valid_expected_pbe_task[0] = '0;
		end

		if (do_injection)
		begin
			delayed_target_bits_task[0] = valid_corrupted_bits;
			delayed_target_burst_task[0] = target_burst;
		end
		else
		begin
			delayed_target_bits_task[0] = delayed_target_bits[0];
			delayed_target_burst_task[0] = delayed_target_burst[0];
		end
	end

endtask

// Register the partial expected per byte error so it can be use to generate
// full expected per byte error latter
task automatic store_partial_expected_sig;

	output [AVL_NUM_BYTES-1:0]						partial_expected_pbe_reg_task;

	reg	[AVL_NUM_BYTES-1:0]							partial_expected_pbe_reg_task;

	if (!reset_n)
		partial_expected_pbe_reg_task = '0;
	else
	begin
		partial_expected_pbe_reg_task = partial_expected_pbe_reg;

		// The arrangement of partial_expected_pbe in the register is based
		// on which burst they're representing to
		// [MSB : Last corrupted burst]<-->[LSB : First corrupted burst]
		// [D3 D2 D1 D0][C3 C2 C1 C0][B3 B2 B1 B0][A3 A2 A1 A0]
		// where A,B,C,D = current partial_expected_pbe
		for (int byte_id = 0; byte_id < MEM_NUM_BYTES ; byte_id++)
		begin
			partial_expected_pbe_reg_task[byte_id + (mem_burst_per_avl_counter * MEM_NUM_BYTES)] = partial_expected_pbe[byte_id];
		end

	end

endtask

// Generate (partial) expected per byte error based on the corrupted_bits
// for current memory burst
genvar mem_byte_id;
generate
begin
	for (mem_byte_id = 0; mem_byte_id < MEM_NUM_BYTES; mem_byte_id++)
	begin : partial_pbe
		assign partial_expected_pbe[mem_byte_id] = |(valid_corrupted_bits[(mem_byte_id + 1) * 9 - 1 : (mem_byte_id * 9)]);
	end
end
endgenerate

// Generate (complete) expected per byte error based on previous and current
// burst
genvar avl_byte_id;
generate
begin
	for (avl_byte_id = 0; avl_byte_id < AVL_NUM_BYTES; avl_byte_id++)
	begin : full_pbe
		// Needs to remaps according ALTDQ_DQS scheme
		if (RATE == "HALF")
		begin
			// [MSB : Last corrupted burst]<-->[LSB : First corrupted burst]
			// [current partial_expected_pbe][C3 C2 C1 C0][B3 B2 B1 B0][A3 A2 A1 A0]
			if (avl_byte_id > (AVL_NUM_BYTES - MEM_NUM_BYTES - 1))
				assign full_expected_pbe[avl_byte_id] = partial_expected_pbe[avl_byte_id - (AVL_NUM_BYTES - MEM_NUM_BYTES)];
			else
				assign full_expected_pbe[avl_byte_id] = partial_expected_pbe_reg[avl_byte_id];
		end
		else
		begin
			// [MSB : Third corrupted burst]<-->[LSB : Last corrupted burst]
			// [C3 C2 C1 C0][B3 B2 B1 B0][A3 A2 A1 A0][current partial_expected_pbe]
			if (avl_byte_id > (MEM_NUM_BYTES - 1))
				assign full_expected_pbe[avl_byte_id] = partial_expected_pbe_reg[avl_byte_id - MEM_NUM_BYTES]; 
			else
				assign full_expected_pbe[avl_byte_id] = partial_expected_pbe[avl_byte_id];
		end
	end
end
endgenerate

// Corrupt the read data according to the target_bits
always_comb
begin
	write_to_mem <= '0;
	write_to_ctrl <= '0;
	if (mem_rdata_valid)
		if (do_injection)
			for (int bit_id = 0; bit_id < MEM_IF_DWIDTH; bit_id++)
			begin
				// Corrupt / Flip the bit only if targeted.
				if (target_bits[bit_id])
					write_to_ctrl[bit_id] <= ~mem_data[bit_id];
				else
					write_to_ctrl[bit_id] <= mem_data[bit_id];
			end
		else
			write_to_ctrl <= mem_data;
	else
		write_to_mem	<= ctrl_data;
end

// Get the current signals from multiplex result of posetive edge based and 
// negetive edge register
always_comb
begin
	case(clk[0])
		1'b1:
		begin
			stage <= stage_pos;
			target_bits <= target_bits_pos;
			target_burst <= target_burst_pos;
			reads_counter <= reads_counter_pos;
			mem_burst_counter <= mem_burst_counter_pos;
			mem_burst_per_avl_counter <= mem_burst_per_avl_counter_pos;
			delayed_expected_pbe <= delayed_expected_pbe_pos;
			delayed_valid_expected_pbe <= delayed_valid_expected_pbe_pos;
			delayed_target_bits <= delayed_target_bits_pos;
			delayed_target_burst <= delayed_target_burst_pos;
			partial_expected_pbe_reg <= partial_expected_pbe_reg_pos;
		end

		1'b0:
		begin
			stage <= stage_neg;
			target_bits <= target_bits_neg;
			target_burst <= target_burst_neg;
			reads_counter <= reads_counter_neg;
			mem_burst_counter <= mem_burst_counter_neg;
			mem_burst_per_avl_counter <= mem_burst_per_avl_counter_neg;
			delayed_expected_pbe <= delayed_expected_pbe_neg;
			delayed_valid_expected_pbe <= delayed_valid_expected_pbe_neg;
			delayed_target_bits <= delayed_target_bits_neg;
			delayed_target_burst <= delayed_target_burst_neg;
			partial_expected_pbe_reg <= partial_expected_pbe_reg_neg;
		end

	endcase
end

// Execute each task on each clock edge as the data transmited as double data rate
always_ff @(posedge clk[0] or negedge reset_n)
begin

	identify_test_stage(stage_pos);
	identify_bit_to_corrupt(target_bits_pos);
	identify_burst_to_corrupt(target_burst_pos);
	count_reads(reads_counter_pos);
	count_mem_burst(mem_burst_counter_pos,mem_burst_per_avl_counter_pos);
	delay_read_cmd();
	delay_expected_sig(delayed_expected_pbe_pos,delayed_valid_expected_pbe_pos,delayed_target_bits_pos,delayed_target_burst_pos);
	store_partial_expected_sig(partial_expected_pbe_reg_pos);

end

always_ff @(negedge clk[0] or negedge reset_n)
begin

	identify_test_stage(stage_neg);
	identify_bit_to_corrupt(target_bits_neg);
	identify_burst_to_corrupt(target_burst_neg);
	count_reads(reads_counter_neg);
	count_mem_burst(mem_burst_counter_neg,mem_burst_per_avl_counter_neg);
	delay_expected_sig(delayed_expected_pbe_neg,delayed_valid_expected_pbe_neg,delayed_target_bits_neg,delayed_target_burst_neg);
	store_partial_expected_sig(partial_expected_pbe_reg_neg);

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

endmodule
