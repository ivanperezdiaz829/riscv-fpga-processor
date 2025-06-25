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

(* altera_attribute = "-name GLOBAL_SIGNAL OFF" *)
module reset(
	seq_reset_mem_stable, 
	pll_afi_clk,
	pll_addr_cmd_clk,
`ifdef QUARTER_RATE
	pll_hr_clk,
`endif
`ifdef CORE_PERIPHERY_DUAL_CLOCK
	pll_p2c_read_clk,
`endif	
`ifdef DDRX_LPDDRX
	pll_dqs_ena_clk,
`endif
	seq_clk,
`ifdef NIOS_SEQUENCER
	scc_clk,
	pll_avl_clk,
	reset_n_scc_clk,
	reset_n_avl_clk,
`endif
	read_capture_clk,
	pll_locked,
	global_reset_n,
	soft_reset_n,
	ctl_reset_n,
	ctl_reset_export_n,
	reset_n_afi_clk,
	reset_n_addr_cmd_clk,
`ifdef QUARTER_RATE
	reset_n_hr_clk,
`endif
`ifdef CORE_PERIPHERY_DUAL_CLOCK
	reset_n_p2c_read_clk,
`endif	
`ifdef DDRX_LPDDRX
	reset_n_resync_clk,
`endif
	reset_n_seq_clk,
	reset_n_read_capture_clk
);


parameter MEM_READ_DQS_WIDTH = ""; 

parameter NUM_AFI_RESET = 1;


input	seq_reset_mem_stable;

input	pll_afi_clk;
input	pll_addr_cmd_clk;
`ifdef QUARTER_RATE
input	pll_hr_clk;
`endif
`ifdef CORE_PERIPHERY_DUAL_CLOCK
input	pll_p2c_read_clk;
`endif	
`ifdef DDRX_LPDDRX
input	pll_dqs_ena_clk;
`endif
input	seq_clk;
`ifdef NIOS_SEQUENCER
input	scc_clk;
input	pll_avl_clk;
output	reset_n_scc_clk;
output	reset_n_avl_clk;
`endif
input	[MEM_READ_DQS_WIDTH-1:0] read_capture_clk;
input	pll_locked;
input	global_reset_n;
input	soft_reset_n;
output	ctl_reset_n;
output  ctl_reset_export_n;
output	[NUM_AFI_RESET-1:0] reset_n_afi_clk;
output	reset_n_addr_cmd_clk;
`ifdef QUARTER_RATE
output	reset_n_hr_clk;
`endif
`ifdef CORE_PERIPHERY_DUAL_CLOCK
output	reset_n_p2c_read_clk;
`endif	
`ifdef DDRX_LPDDRX
output	reset_n_resync_clk;
`endif
output	reset_n_seq_clk;
output	[MEM_READ_DQS_WIDTH-1:0] reset_n_read_capture_clk;

// Apply the synthesis keep attribute on the synchronized reset wires
// so that these names can be constrained using QSF settings to keep
// the resets on local routing.
wire	phy_reset_n /* synthesis keep = 1 */;
wire	phy_reset_mem_stable_n /* synthesis keep = 1*/;

wire	[MEM_READ_DQS_WIDTH-1:0] reset_n_read_capture;


	assign phy_reset_mem_stable_n = phy_reset_n & seq_reset_mem_stable;
	assign reset_n_read_capture_clk = reset_n_read_capture;

	assign phy_reset_n = pll_locked & global_reset_n & soft_reset_n;

	reset_sync	ureset_afi_clk(
		.reset_n		(phy_reset_n),
		.clk			(pll_afi_clk),
		.reset_n_sync	(reset_n_afi_clk)
	);
	defparam ureset_afi_clk.RESET_SYNC_STAGES = 15; 
	defparam ureset_afi_clk.NUM_RESET_OUTPUT = NUM_AFI_RESET;

	reset_sync	ureset_ctl_reset_clk(
		.reset_n		(phy_reset_n),
		.clk			(pll_afi_clk),
		.reset_n_sync	({ctl_reset_n, ctl_reset_export_n})
	);
	defparam ureset_ctl_reset_clk.RESET_SYNC_STAGES = 15;
	defparam ureset_ctl_reset_clk.NUM_RESET_OUTPUT = 2;

	reset_sync	ureset_addr_cmd_clk(
		.reset_n			(phy_reset_n),
		.clk				(pll_addr_cmd_clk),
		.reset_n_sync	(reset_n_addr_cmd_clk)
	);
	defparam ureset_addr_cmd_clk.RESET_SYNC_STAGES = 15; 
	defparam ureset_addr_cmd_clk.NUM_RESET_OUTPUT = 1;

`ifdef QUARTER_RATE	
	reset_sync	ureset_hr_clk(
		.reset_n			(phy_reset_n),
		.clk				(pll_hr_clk),
		.reset_n_sync	(reset_n_hr_clk)
	);
	defparam ureset_hr_clk.RESET_SYNC_STAGES = 15; 
	defparam ureset_hr_clk.NUM_RESET_OUTPUT = 1;
`endif

`ifdef CORE_PERIPHERY_DUAL_CLOCK
	`ifdef QUARTER_RATE
	reset_sync	ureset_p2c_read_clk(
		.reset_n			(phy_reset_n),
		.clk				(pll_p2c_read_clk),
		.reset_n_sync	(reset_n_p2c_read_clk)
	);
	defparam ureset_p2c_read_clk.RESET_SYNC_STAGES = 15; 
	defparam ureset_p2c_read_clk.NUM_RESET_OUTPUT = 1;
	 `else
	 assign reset_n_p2c_read_clk = 1'b0;
	 `endif
`endif

`ifdef DDRX_LPDDRX
	reset_sync	ureset_resync_clk(
		.reset_n		(phy_reset_n),
		.clk			(pll_dqs_ena_clk),
		.reset_n_sync	(reset_n_resync_clk)
	);
	defparam ureset_resync_clk.RESET_SYNC_STAGES = 15; 
	defparam ureset_resync_clk.NUM_RESET_OUTPUT = 1;
`endif

	reset_sync	ureset_seq_clk(
		.reset_n		(phy_reset_n),
		.clk			(seq_clk),
		.reset_n_sync	(reset_n_seq_clk)
	);
	defparam ureset_seq_clk.RESET_SYNC_STAGES = 15; 
	defparam ureset_seq_clk.NUM_RESET_OUTPUT = 1;

`ifdef NIOS_SEQUENCER
	reset_sync	ureset_scc_clk(
		.reset_n		(phy_reset_n),
		.clk			(scc_clk),
		.reset_n_sync	(reset_n_scc_clk)
	);
	defparam ureset_scc_clk.RESET_SYNC_STAGES = 15; 
	defparam ureset_scc_clk.NUM_RESET_OUTPUT = 1;

	reset_sync	ureset_avl_clk(
		.reset_n		(phy_reset_n),
		.clk			(pll_avl_clk),
		.reset_n_sync	(reset_n_avl_clk)
	);
	defparam ureset_avl_clk.RESET_SYNC_STAGES = 2; 
	defparam ureset_avl_clk.NUM_RESET_OUTPUT = 1;
`endif

generate
genvar i;
	for (i=0; i<MEM_READ_DQS_WIDTH; i=i+1)
	begin: read_capture_reset
		reset_sync #(
			.RESET_SYNC_STAGES(15),
			.NUM_RESET_OUTPUT(1)
		 )
		ureset_read_capture_clk(
			.reset_n			(phy_reset_mem_stable_n),
			.clk				(read_capture_clk[i]),
			.reset_n_sync	(reset_n_read_capture[i])
		);
	end
endgenerate

endmodule
