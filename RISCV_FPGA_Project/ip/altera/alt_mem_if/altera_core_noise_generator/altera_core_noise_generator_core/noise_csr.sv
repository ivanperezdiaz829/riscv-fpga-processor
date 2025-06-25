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

module noise_csr (
	avl_clk,
	avl_reset_n,

	// Input status settings
	noise_type,
	pll_locked,
	
	// Output registers effecting rest of design
	noise_gen_value,
	enable_noise,
	noise_clock_enable,

	// Avalon Interface
	avl_address,
	avl_write,
	avl_writedata,
	avl_read,
	avl_readdata,
	avl_waitrequest,
	avl_be
);

parameter NOISE_RESOLUTION_WIDTH = 4;
localparam MAX_NOISE_VALUE = 2**NOISE_RESOLUTION_WIDTH -1;

parameter NUM_BLOCKS = 4;

parameter NOISEGEN_VERSION = 16'd120;

parameter AVL_DATA_WIDTH = 32;
parameter AVL_ADDR_WIDTH = 13;
parameter AVL_NUM_SYMBOLS = 4;
parameter AVL_SYMBOL_WIDTH = 8;
localparam REGISTER_RDATA = 0;

localparam NUM_REGFILE_WORDS = 9;

input avl_clk;
input avl_reset_n;
input [AVL_ADDR_WIDTH - 1:0] avl_address;
input avl_write;
input [AVL_DATA_WIDTH - 1:0] avl_writedata;
input [AVL_NUM_SYMBOLS - 1:0] avl_be;
input avl_read;
output [AVL_DATA_WIDTH - 1:0] avl_readdata;
output avl_waitrequest;


input [31:0] noise_type;
input pll_locked;


output [NOISE_RESOLUTION_WIDTH-1:0] noise_gen_value;
output enable_noise;
output noise_clock_enable;

reg [AVL_ADDR_WIDTH-1 : 0] int_addr;
reg [AVL_NUM_SYMBOLS - 1 : 0] int_be;
reg [AVL_DATA_WIDTH - 1 : 0] int_rdata;
reg [AVL_DATA_WIDTH - 1 : 0] int_rdata_reg;
logic int_waitrequest;
reg [AVL_DATA_WIDTH - 1 : 0] int_wdata;
logic [AVL_DATA_WIDTH - 1 : 0] int_wdata_wire;

reg [AVL_DATA_WIDTH-1 : 0] reg_file [0 : NUM_REGFILE_WORDS-1] /* synthesis syn_ramstyle = "logic" */;

integer i, b;

typedef enum int unsigned {
	INIT,
	LOAD_DATA,
	IDLE,
	WRITE2,
	READ2,
	READ3,
	READ4
} avalon_state_t;

avalon_state_t state;

always_ff @ (posedge avl_clk or negedge avl_reset_n) begin
	if (~avl_reset_n)
		state <= INIT;
	else begin
		if (state == INIT)
			state <= LOAD_DATA;
		else if (state == READ2)
			state <= READ3;
		else if ((state == READ3) && (REGISTER_RDATA)) 
			state <= READ4;
		else if (state == IDLE) 
			if (avl_read)
				state <= READ2;
			else if (avl_write)
				state <= WRITE2;
			else
				state <= IDLE;
		else 
			state <= IDLE;
	end
end

assign int_waitrequest = (state == IDLE) || (state == WRITE2) || ((state == READ4) && (REGISTER_RDATA)) || ((state == READ3) && (REGISTER_RDATA == 0)) ? 1'b0 : 1'b1;

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

always_ff @ (posedge avl_clk or negedge avl_reset_n) begin
	if (~avl_reset_n) begin
		int_rdata <= 0;
	end
	else begin
		if (state == READ2) 
			if (int_addr < NUM_REGFILE_WORDS) begin
				int_rdata <= reg_file[int_addr];
			end
			else begin
				int_rdata <= 0;
			end
		else
			int_rdata <= 0;
	end
end
// synthesis translate_off

property p_illegal_read_addr;
	@(posedge avl_clk)
	disable iff (!avl_reset_n)
	(state == READ2) |-> (int_addr < NUM_REGFILE_WORDS);
endproperty

a_illegal_read_addr : assert property (p_illegal_read_addr);
// synthesis translate_on


always_comb begin
	int_wdata_wire <= reg_file[int_addr];
	for (b=0; b < AVL_NUM_SYMBOLS; b++)
		if (int_be[b])
			int_wdata_wire[(b+1)*AVL_SYMBOL_WIDTH-1-:AVL_SYMBOL_WIDTH] <= int_wdata[(b+1)*AVL_SYMBOL_WIDTH-1-:AVL_SYMBOL_WIDTH];
end

always_ff @ (posedge avl_clk or negedge avl_reset_n) begin
	if (~avl_reset_n) begin
		for (i=0; i < NUM_REGFILE_WORDS; i++)
			reg_file[i] <= 0;
	end
	else begin
		i = 0;

		reg_file[7][1] <= pll_locked;

		if (state == LOAD_DATA) begin

			reg_file[0]  <= 0;
	
			reg_file[1] <= 32'hdeadbeef;
			
			reg_file[2] <= {NOISEGEN_VERSION[15:0],16'h3};
		
			reg_file[3] <= noise_type;
		
			reg_file[4] <= MAX_NOISE_VALUE+1;
		
			reg_file[5] <= 0;
			
			reg_file[6] <= NUM_BLOCKS;
	
			reg_file[7] <= 0;
			reg_file[7][16] <= 1'b1;
	
			reg_file[8] <= 0;
			reg_file[8][0] <= 1'b1;
			
		end

		else if (state == WRITE2) begin
			case(int_addr)
				'h5 : begin
					if (int_wdata_wire > MAX_NOISE_VALUE)
						reg_file[5][NOISE_RESOLUTION_WIDTH-1:0] <= {NOISE_RESOLUTION_WIDTH{1'b1}};
					else
						reg_file[5][NOISE_RESOLUTION_WIDTH-1:0] <= int_wdata_wire[NOISE_RESOLUTION_WIDTH-1:0];
				end
				'h7 : begin
					if (int_be[2])
						reg_file[7][16] <= int_wdata_wire[16];
				end
				'h8 : begin
					if (int_be[0])
						reg_file[8][0] <= int_wdata_wire[0];
				end
				default : begin
				end
			endcase
		end
	end
end
// synthesis translate_off

property p_illegal_write_addr;
	@(posedge avl_clk)
	disable iff (!avl_reset_n)
	(state == WRITE2) |-> (int_addr < NUM_REGFILE_WORDS);
endproperty

a_illegal_write_addr : assert property (p_illegal_write_addr);
// synthesis translate_on

generate
	if (REGISTER_RDATA) begin
		
		always_ff @ (posedge avl_clk or negedge avl_reset_n) begin
			if (~avl_reset_n)
				int_rdata_reg <= 0;
			else
				int_rdata_reg <= int_rdata;
		end

		assign avl_readdata = int_rdata_reg;
	end
	else
		assign avl_readdata = int_rdata;
endgenerate

assign avl_waitrequest = ((state == IDLE) && ((avl_read == 1) || (avl_write == 1))) ? 1'b1 : int_waitrequest;

assign noise_gen_value = reg_file[5][NOISE_RESOLUTION_WIDTH-1:0];
assign enable_noise = reg_file[7][16];
assign noise_clock_enable = reg_file[8][0];

endmodule
