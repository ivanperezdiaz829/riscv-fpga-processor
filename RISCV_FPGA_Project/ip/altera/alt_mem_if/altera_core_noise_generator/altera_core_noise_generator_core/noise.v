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


`define NOISE_UNCORRELATED

(* altera_attribute = "-name AUTO_SHIFT_REGISTER_RECOGNITION OFF" *)
module noise (
	pll_locked,
	pll_clk,

	global_reset_n,
	
	soft_reset_n,
	
	csr_reset_n,
	csr_clk,
	csr_addr,
	csr_be,
	csr_write_req,
	csr_wdata,
	csr_read_req,
	csr_rdata,
	csr_waitrequest
);

localparam NUM_LFSR		= 4;
localparam NOISE_RESOLUTION_WIDTH = NUM_LFSR;

parameter AVL_DATA_WIDTH = 32;
parameter AVL_ADDR_WIDTH = 8;
parameter AVL_NUM_SYMBOLS = 4;
parameter AVL_SYMBOL_WIDTH = 8;

parameter NUM_BLOCKS			= 2;

parameter NOISEGEN_VERSION = 16'd110;

input pll_locked;

input pll_clk;

input global_reset_n;

input soft_reset_n;

output csr_clk;

output csr_reset_n;

input [AVL_ADDR_WIDTH - 1       : 0] csr_addr;
input [AVL_NUM_SYMBOLS - 1 : 0] csr_be;
input csr_write_req;
input [AVL_DATA_WIDTH - 1       : 0] csr_wdata;
input csr_read_req;
output [AVL_DATA_WIDTH - 1 : 0] csr_rdata;
output csr_waitrequest;


wire pll_csr_clk;

wire [3:0] lfsr_codeword;

reg toggle;


wire pll_locked;
wire [31:0] noise_type;

wire [NOISE_RESOLUTION_WIDTH-1:0] noise_gen_value;
wire enable_noise;
wire noise_clock_enable;
		

wire pll_noise_clk;

wire pll_reset;
wire resync_reset;
wire noise_clk;		

wire noise_clk_reset_n;
wire csr_clk_reset_n;

	assign resync_reset = (~pll_locked) || (~global_reset_n) || (~soft_reset_n);

	assign pll_noise_clk = pll_clk;
	assign pll_csr_clk = pll_clk;

	reset_sync noise_clk_resync (
		.reset_n(!resync_reset),
		.clk(noise_clk),
		.reset_n_sync(noise_clk_reset_n)
	);
	reset_sync ip_clk_resync (
		.reset_n(!resync_reset),
		.clk(pll_csr_clk),
		.reset_n_sync(csr_clk_reset_n)
	);
	assign csr_reset_n = csr_clk_reset_n;

	noise_clken noise_clk_buf (
		.ena(noise_clock_enable),
		.inclk(pll_noise_clk),
		.outclk(noise_clk)
	);

	assign csr_clk = pll_csr_clk;
	

	noise_csr #(
		.AVL_DATA_WIDTH(AVL_DATA_WIDTH),
		.AVL_ADDR_WIDTH(AVL_ADDR_WIDTH),
		.AVL_NUM_SYMBOLS(AVL_NUM_SYMBOLS),
		.AVL_SYMBOL_WIDTH(AVL_SYMBOL_WIDTH),
		
		.NOISEGEN_VERSION(NOISEGEN_VERSION),
		
		.NOISE_RESOLUTION_WIDTH(NOISE_RESOLUTION_WIDTH),
		.NUM_BLOCKS(NUM_BLOCKS)

	) noise_csr_inst (
		.avl_clk(pll_csr_clk),
		.avl_reset_n(csr_clk_reset_n),
		.avl_address(csr_addr),
		.avl_be(csr_be),
		.avl_write(csr_write_req),
		.avl_writedata(csr_wdata),
		.avl_read(csr_read_req),
		.avl_readdata(csr_rdata),
		.avl_waitrequest(csr_waitrequest),
		
		.noise_type(noise_type),
		.pll_locked(pll_locked),
		
		.noise_gen_value(noise_gen_value),
		.enable_noise(enable_noise),
		.noise_clock_enable(noise_clock_enable)
	);
	
	noise_lfsr noise_lfsr_insta (
		.clk (noise_clk),
		.reset_n(noise_clk_reset_n),
		.rbit (lfsr_codeword[0])
	);
	defparam noise_lfsr_insta.SEED = 15'h1;
	defparam noise_lfsr_insta.WIDTH = 15;
		
	noise_lfsr noise_lfsr_instb (
		.clk (noise_clk),
		.reset_n(noise_clk_reset_n),
		.rbit (lfsr_codeword[1])
	);
	defparam noise_lfsr_instb.SEED = 22'h3;
	defparam noise_lfsr_instb.WIDTH = 22;
	
	noise_lfsr noise_lfsr_instc (
		.clk (noise_clk),
		.reset_n(noise_clk_reset_n),
		.rbit (lfsr_codeword[2])
	);
	defparam noise_lfsr_instc.SEED = 60'h321;
	defparam noise_lfsr_instc.WIDTH = 60;
	
	noise_lfsr noise_lfsr_instd (
		.clk (noise_clk),
		.reset_n(noise_clk_reset_n),
		.rbit (lfsr_codeword[3])
	);
	defparam noise_lfsr_instd.SEED = 63'habcd;
	defparam noise_lfsr_instd.WIDTH = 63;
		
	
	always @ (posedge noise_clk or negedge noise_clk_reset_n)
		if (!noise_clk_reset_n)
			toggle <= 0;
		else
			if ((lfsr_codeword < noise_gen_value) && (enable_noise))
				toggle <= ~toggle;
		
		
`ifndef NOISE_CORRELATED
	assign noise_type = 32'b1;

	wire [NUM_BLOCKS:0] sr_in_out;
	
	assign sr_in_out[0] = toggle;

	generate
		genvar i;
		
		for (i = 0; i < NUM_BLOCKS; i = i + 1) begin: gen_loop
			noise_sr noise_sr_inst (
				.clk (noise_clk),
				.reset_n(noise_clk_reset_n),
				.ibit (sr_in_out[i]),
				.obit (sr_in_out[i + 1])
			);
		end		
	endgenerate
`else
	assign noise_type = 32'b2;

	generate
		genvar i;
		for (i = 0; i < NUM_BLOCKS; i = i + 1) begin: gen_loop
			noise_gray noise_gray_inst (
				.clk (toggle)
			);
		end		
	endgenerate	
`endif
	
	
endmodule
