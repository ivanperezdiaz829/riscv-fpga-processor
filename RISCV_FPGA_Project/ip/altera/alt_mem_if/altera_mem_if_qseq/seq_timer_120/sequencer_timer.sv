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


// (C) 2001-2012 Altera Corporation. All rights reserved.
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



//__ACDS_USER_COMMENT__ ******
//__ACDS_USER_COMMENT__ timer
//__ACDS_USER_COMMENT__ ******
//__ACDS_USER_COMMENT__
//__ACDS_USER_COMMENT__ Timer component
//__ACDS_USER_COMMENT__
//__ACDS_USER_COMMENT__ General Description
//__ACDS_USER_COMMENT__ -------------------
//__ACDS_USER_COMMENT__
//__ACDS_USER_COMMENT__ This component stores a timer which counts and returns the number
//__ACDS_USER_COMMENT__ of clock cycles.
//__ACDS_USER_COMMENT__
//__ACDS_USER_COMMENT__ Architecture
//__ACDS_USER_COMMENT__ ------------
//__ACDS_USER_COMMENT__
//__ACDS_USER_COMMENT__ The PHY Manager is organized as an 
//__ACDS_USER_COMMENT__    - Avalon Interface: it's a Memory-Mapped interface to the Avalon
//__ACDS_USER_COMMENT__      Bus.
//__ACDS_USER_COMMENT__    - Register File: The "register file" of read/write registers
//__ACDS_USER_COMMENT__

module sequencer_timer (
	//__ACDS_USER_COMMENT__ Avalon Interface
	avl_clk,
	avl_reset_n,
	avl_address,
	avl_write,
	avl_writedata,
	avl_read,
	avl_readdata,
	avl_waitrequest,
	avl_be
);

parameter AVL_DATA_WIDTH = 32;
parameter AVL_ADDR_WIDTH = 1;
parameter AVL_NUM_SYMBOLS = 4;
parameter AVL_SYMBOL_WIDTH = 8;

input avl_clk;
input avl_reset_n;
input [AVL_ADDR_WIDTH - 1:0] avl_address;
input avl_write;
input [AVL_DATA_WIDTH - 1:0] avl_writedata;
input [AVL_NUM_SYMBOLS - 1:0] avl_be;
input avl_read;
output [AVL_DATA_WIDTH - 1:0] avl_readdata;
output avl_waitrequest;

//Internal versions of request signals
reg [AVL_ADDR_WIDTH-1 : 0] int_addr;
reg [AVL_NUM_SYMBOLS - 1 : 0] int_be;
reg [AVL_DATA_WIDTH - 1 : 0] int_rdata;
logic int_waitrequest;
reg [AVL_DATA_WIDTH - 1 : 0] int_wdata;
logic [AVL_DATA_WIDTH - 1 : 0] int_wdata_wire;
reg [AVL_DATA_WIDTH-1:0] clk_cycles;

// Internal counters
integer b;

//State machine states
typedef enum int unsigned {
	INIT,
	IDLE,
	WRITE2,
	READ2,
	READ3
} avalon_state_t;

avalon_state_t state;

// Main state machine
always_ff @ (posedge avl_clk or negedge avl_reset_n) begin
	if (~avl_reset_n)
		state <= INIT;
	else begin
		if (state == READ2)
			state <= READ3;
		else if (state == IDLE) 
			if (avl_read)
				state <= READ2;
			else if (avl_write)
				state <= WRITE2;
			else
				state <= IDLE;
		else // INIT, READ3, WRITE2
			state <= IDLE;
	end
end

// Wait request generation
assign int_waitrequest = (state == IDLE) || (state == WRITE2) || (state == READ3) ? 1'b0 : 1'b1;

// The external wait request is the internal version but with wait request asserted
// in the idle state as soon as a new operation is detected.
assign avl_waitrequest = ((state == IDLE) && ((avl_read == 1) || (avl_write == 1))) ? 1'b1 : int_waitrequest;

// Avalon Interface: Register all inputs
always_ff @ (posedge avl_clk or negedge avl_reset_n) begin
	if (~avl_reset_n) begin
		int_addr <= 0;
		int_wdata <= 0;
		int_be <= 0;
	end
	else if (int_waitrequest == 0) begin
		int_addr  <= avl_address;
		int_wdata <= avl_writedata;
		int_be    <= avl_be;
	end

end

// Read Interface
always_ff @ (posedge avl_clk or negedge avl_reset_n) begin
	if (~avl_reset_n) begin
		int_rdata <= 0;
	end
	else begin
		// If read, then return the appropriate address
		if (state == READ2) 
			int_rdata <= clk_cycles;
		else
			// By default make rdata 0
			int_rdata <= 0;
	end
end

// Calculate the byte-enable masked version of int_wdata for writing to the
always_comb begin
	int_wdata_wire <= clk_cycles;
	for (b=0; b < AVL_NUM_SYMBOLS; b++)
		if (int_be[b])
			int_wdata_wire[(b+1)*AVL_SYMBOL_WIDTH-1-:AVL_SYMBOL_WIDTH] <= int_wdata[(b+1)*AVL_SYMBOL_WIDTH-1-:AVL_SYMBOL_WIDTH];

end

// Write Interface
always_ff @ (posedge avl_clk or negedge avl_reset_n) begin
	if (~avl_reset_n) begin
		clk_cycles <= {AVL_DATA_WIDTH{1'b1}};
	end
	else begin
		// If write then update signals as appropriate
		if (state == WRITE2) begin
			clk_cycles <= int_wdata_wire;
		end
		else begin
			if (&clk_cycles[AVL_DATA_WIDTH-1:0])
				clk_cycles <= clk_cycles;
			else
				clk_cycles <= clk_cycles + 1;
		end
	end
end

// Avalon Read Data
assign avl_readdata = int_rdata;

endmodule

