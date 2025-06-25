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
// File name: read_datapath.sv
// The read datapath is responsible for read data resynchronization from the memory clock domain to the AFI clock domain.
// It contains 1 FIFO per DQS group for read valid prediction and 1 FIFO per DQS group for read data synchronization.
// ******************************************************************************************************************************** 

`timescale 1 ps / 1 ps

(* altera_attribute = "-name AUTO_SHIFT_REGISTER_RECOGNITION OFF" *)

// altera message_off 10036 10030 10858
module read_datapath(
	reset_n_afi_clk,
	seq_read_fifo_reset,
`ifdef DDRX_LPDDRX
	reset_n_resync_clk,
	pll_dqs_ena_clk,
`else
	reset_n_read_capture_clk,
	seq_reset_mem_stable,
`endif
	read_capture_clk,
	ddio_phy_dq,
	pll_afi_clk,
`ifdef QUARTER_RATE
	pll_hr_clk,
	reset_n_hr_clk,
`endif
`ifdef CORE_PERIPHERY_DUAL_CLOCK
	pll_p2c_read_clk,
	reset_n_p2c_read_clk,
`endif
	seq_read_latency_counter,
	seq_read_increment_vfifo_fr,
	seq_read_increment_vfifo_hr,
	seq_read_increment_vfifo_qr,
	afi_rdata_en,
	afi_rdata_en_full,
	afi_rdata,
`ifdef USE_SHADOW_REGS
	afi_rrank_decoded,
	rrank_select_out,
`endif
`ifdef PINGPONGPHY_EN
	afi_rdata_en_1t,
	afi_rdata_en_full_1t,
	afi_rdata_valid_1t,
	mux_sel,
`endif
	phy_mux_read_fifo_q,
`ifdef DDRX_LPDDRX
	force_oct_off,
	dqs_enable_ctrl,
`endif
	afi_rdata_valid,
	seq_calib_init
);

// ********************************************************************************************************************************
// BEGIN PARAMETER SECTION
// All parameters default to "" will have their values passed in from higher level wrapper with the controller and driver

parameter DEVICE_FAMILY = "";

// PHY-Memory Interface
parameter MEM_ADDRESS_WIDTH     = "";
parameter MEM_DM_WIDTH          = "";
parameter MEM_CONTROL_WIDTH     = "";
parameter MEM_DQ_WIDTH          = "";
parameter MEM_READ_DQS_WIDTH    = "";
parameter MEM_WRITE_DQS_WIDTH   = "";

// PHY-Controller (AFI) Interface
parameter AFI_ADDRESS_WIDTH         = "";
parameter AFI_DATA_MASK_WIDTH       = "";
parameter AFI_CONTROL_WIDTH         = "";
parameter AFI_DATA_WIDTH            = "";
parameter AFI_DQS_WIDTH             = "";
parameter AFI_RATE_RATIO            = "";

// Read Datapath
parameter MAX_LATENCY_COUNT_WIDTH          = "";
parameter MAX_READ_LATENCY                 = "";
parameter READ_FIFO_READ_MEM_DEPTH         = "";
parameter READ_FIFO_READ_ADDR_WIDTH        = "";
parameter READ_FIFO_WRITE_MEM_DEPTH        = "";
parameter READ_FIFO_WRITE_ADDR_WIDTH       = "";
parameter READ_VALID_FIFO_SIZE             = "";
parameter READ_VALID_FIFO_READ_MEM_DEPTH   = "";
parameter READ_VALID_FIFO_READ_ADDR_WIDTH  = "";
parameter READ_VALID_FIFO_WRITE_MEM_DEPTH  = "";
parameter READ_VALID_FIFO_WRITE_ADDR_WIDTH = "";
parameter READ_VALID_FIFO_PER_DQS_WIDTH    = "";
parameter NUM_SUBGROUP_PER_READ_DQS        = "";
parameter MEM_T_RL                         = "";
parameter QVLD_EXTRA_FLOP_STAGES           = "";
parameter QVLD_WR_ADDRESS_OFFSET           = "";
parameter REGISTER_C2P                     = "";
`ifdef RLDRAM3
	`ifdef QUARTER_RATE
parameter VFIFO_C2P_PIPELINE_DEPTH         = 2;
	`else
parameter VFIFO_C2P_PIPELINE_DEPTH         = 1;
	`endif	
`else
parameter VFIFO_C2P_PIPELINE_DEPTH         = 1;
`endif

// Width of the calibration status register used to control calibration skipping.
parameter CALIB_REG_WIDTH                  = "";
parameter FAST_SIM_MODEL                   = "";

parameter EXTRA_VFIFO_SHIFT                = 0;

`ifdef MAKE_FIFOS_IN_ALTDQDQS
`ifdef QUARTER_RATE
// In Arria-V/Cyclone-V QR, need to offset the same delay in new_io_pads
localparam EXTRA_VFIFO_SHIFT_INT           = EXTRA_VFIFO_SHIFT + 1;
`else
localparam EXTRA_VFIFO_SHIFT_INT		   = EXTRA_VFIFO_SHIFT;
`endif
`else
localparam EXTRA_VFIFO_SHIFT_INT		   = EXTRA_VFIFO_SHIFT;
`endif

// Local parameters
`ifdef MAKE_FIFOS_IN_ALTDQDQS
localparam MAKE_FIFOS_IN_ALTDQDQS = "true";
`else
localparam MAKE_FIFOS_IN_ALTDQDQS = "false";
`endif

localparam DOUBLE_MEM_DQ_WIDTH = MEM_DQ_WIDTH * 2;
`ifdef MAKE_FIFOS_IN_ALTDQDQS
`ifdef QUARTER_RATE
localparam DDIO_PHY_DQ_WIDTH = AFI_DATA_WIDTH/2;
`else
localparam DDIO_PHY_DQ_WIDTH = AFI_DATA_WIDTH;
`endif
`else
localparam DDIO_PHY_DQ_WIDTH = DOUBLE_MEM_DQ_WIDTH;
`endif
localparam DQ_GROUP_WIDTH = MEM_DQ_WIDTH / MEM_READ_DQS_WIDTH;
localparam USE_NUM_SUBGROUP_PER_READ_DQS = FAST_SIM_MODEL ? 1 : NUM_SUBGROUP_PER_READ_DQS;
localparam AFI_DQ_GROUP_DATA_WIDTH = AFI_DATA_WIDTH / MEM_READ_DQS_WIDTH;
localparam DDIO_DQ_GROUP_DATA_WIDTH = DDIO_PHY_DQ_WIDTH / MEM_READ_DQS_WIDTH;
localparam DDIO_DQ_GROUP_DATA_WIDTH_SUBGROUP = DDIO_PHY_DQ_WIDTH / (MEM_READ_DQS_WIDTH * USE_NUM_SUBGROUP_PER_READ_DQS);
`ifdef VFIFO_AS_SHIFT_REG
localparam QVLD_SHIFTER_LENGTH = (2 ** READ_VALID_FIFO_WRITE_ADDR_WIDTH) + QVLD_EXTRA_FLOP_STAGES;
`endif

`ifdef USE_HARD_READ_FIFO
	`ifdef QUARTER_RATE
// Register the LFIFO outputs on a per-group basis to help setup
// from core to hard read fifos. These transfers are half-rate
// and so can run at 400MHz+ in quarter rate PHYs.
localparam REGISTER_LFIFO_OUTPUTS_PER_GROUP = "true";

// To help timing we ensure the launch and latch clock to be
// the same (same PLL, same clock network, etc to maximize common
// clock path). At quarter-rate this requires registering the
// read fifo output using the same half-rate clock as the launch
// clock, before transferring to the AFI domain.
localparam REGISTER_P2C = "true";
	`else
localparam REGISTER_LFIFO_OUTPUTS_PER_GROUP = "false";	
// Register P2C to close I/O to hard RAM block setup timing
localparam REGISTER_P2C = "true";
	`endif
`else
localparam REGISTER_LFIFO_OUTPUTS_PER_GROUP = "false";
localparam REGISTER_P2C = "false";
`endif

`ifdef VFIFO_FULL_RATE
localparam VFIFO_RATE_MULT = 1;
`endif
`ifdef VFIFO_HALF_RATE
localparam VFIFO_RATE_MULT = 2;
`endif
`ifdef VFIFO_QUARTER_RATE
localparam VFIFO_RATE_MULT = 4;
`endif

`ifdef FULL_RATE
localparam READ_FIFO_DQ_GROUP_OUTPUT_WIDTH = 2 * DQ_GROUP_WIDTH;
`else
localparam READ_FIFO_DQ_GROUP_OUTPUT_WIDTH = 4 * DQ_GROUP_WIDTH;
`endif

localparam RD_VALID_LFIFO_WIDTH = AFI_RATE_RATIO;
`ifdef QUARTER_RATE
localparam RD_ENABLE_LFIFO_WIDTH = 2;
`endif
`ifdef HALF_RATE
localparam RD_ENABLE_LFIFO_WIDTH = 1;
`endif
`ifdef FULL_RATE
localparam RD_ENABLE_LFIFO_WIDTH = 1;
`endif

`ifdef FULL_RATE
localparam OCT_ON_DELAY = MEM_T_RL - 3;
	`ifdef MEM_LEVELING
localparam OCT_OFF_DELAY = MEM_T_RL + 1;
	`else
localparam OCT_OFF_DELAY = MEM_T_RL + 2;
	`endif
`endif

`ifdef HALF_RATE
localparam OCT_ON_DELAY = (MEM_T_RL > 4) ? ((MEM_T_RL - 4) / 2) : 0;
localparam OCT_OFF_DELAY = (MEM_T_RL + 6) / 2;
`endif

`ifdef QUARTER_RATE
`ifdef MAKE_FIFOS_IN_ALTDQDQS
localparam OCT_ON_DELAY = (MEM_T_RL + 2) / 4;
localparam OCT_OFF_DELAY = (MEM_T_RL + 14) / 4;
`else
localparam OCT_ON_DELAY = (MEM_T_RL > 4) ? ((MEM_T_RL - 4) / 4) : 0;
localparam OCT_OFF_DELAY = (MEM_T_RL + 8) / 4;
`endif
`endif

// END PARAMETER SECTION
// ******************************************************************************************************************************** 

input	reset_n_afi_clk;
input	[MEM_READ_DQS_WIDTH-1:0] seq_read_fifo_reset; // reset from sequencer to read and write pointers of the data resynchronization FIFO
input	[MEM_READ_DQS_WIDTH-1:0] read_capture_clk;
`ifdef DDRX_LPDDRX
input	reset_n_resync_clk;
input	pll_dqs_ena_clk;
`else
input	[MEM_READ_DQS_WIDTH-1:0] reset_n_read_capture_clk;
input	seq_reset_mem_stable;
`endif
input	[DDIO_PHY_DQ_WIDTH-1:0] ddio_phy_dq;
input	pll_afi_clk;
`ifdef QUARTER_RATE
input	pll_hr_clk;
input	reset_n_hr_clk;
`endif
`ifdef CORE_PERIPHERY_DUAL_CLOCK
input	pll_p2c_read_clk;
input	reset_n_p2c_read_clk;
`endif
input	[MAX_LATENCY_COUNT_WIDTH-1:0] seq_read_latency_counter;
input	[MEM_READ_DQS_WIDTH-1:0] seq_read_increment_vfifo_fr;	// increment valid prediction FIFO write pointer by an extra full rate cycle
input	[MEM_READ_DQS_WIDTH-1:0] seq_read_increment_vfifo_hr;	// increment valid prediction FIFO write pointer by an extra half rate cycle
																// in full rate core, both will mean an extra full rate cycle
input	[MEM_READ_DQS_WIDTH-1:0] seq_read_increment_vfifo_qr;	// increment valid prediction FIFO write pointer by an extra quarter rate cycle.
																// not used in full/half rate core

input	[AFI_RATE_RATIO-1:0] afi_rdata_en;
input	[AFI_RATE_RATIO-1:0] afi_rdata_en_full;

`ifdef PINGPONGPHY_EN
input	[AFI_RATE_RATIO-1:0] 	afi_rdata_en_1t;
input	[AFI_RATE_RATIO-1:0]	afi_rdata_en_full_1t;
input				mux_sel;
output	[AFI_RATE_RATIO-1:0]	afi_rdata_valid_1t;
`endif

output	[AFI_DATA_WIDTH-1:0] afi_rdata;
output	[AFI_RATE_RATIO-1:0] afi_rdata_valid;

// read data (no reordering) for indepedently FIFO calibrations (multiple FIFOs for multiple DQS groups)
output	[AFI_DATA_WIDTH-1:0] phy_mux_read_fifo_q;

`ifdef DDRX_LPDDRX
output	[AFI_DQS_WIDTH-1:0] force_oct_off;
output  [MEM_READ_DQS_WIDTH*READ_VALID_FIFO_PER_DQS_WIDTH-1:0] dqs_enable_ctrl;
`endif


input	[CALIB_REG_WIDTH-1:0] seq_calib_init;

`ifdef USE_SHADOW_REGS
// Shadow Register support
input [MEM_READ_DQS_WIDTH*AFI_RATE_RATIO-1:0] afi_rrank_decoded;
output [MEM_READ_DQS_WIDTH-1:0] rrank_select_out;
`endif

// Mark the following register as a keeper because the pin_map.tcl
// script uses it as anchor for finding the AFI clock
reg		[AFI_RATE_RATIO-1:0] afi_rdata_valid /* synthesis dont_merge syn_noprune syn_preserve = 1 */;
`ifdef PINGPONGPHY_EN
reg		[AFI_RATE_RATIO-1:0] afi_rdata_valid_1t /* synthesis dont_merge syn_noprune syn_preserve = 1 */;
`endif

`ifdef FULL_RATE
wire [1:0] qvld_num_fr_cycle_shift [MEM_READ_DQS_WIDTH-1:0];
`else
reg [1:0] qvld_num_fr_cycle_shift [MEM_READ_DQS_WIDTH-1:0];
`endif

wire    [MEM_READ_DQS_WIDTH*READ_VALID_FIFO_PER_DQS_WIDTH-1:0] qvld;
wire	[MEM_READ_DQS_WIDTH-1:0] read_valid [RD_VALID_LFIFO_WIDTH-1:0];
wire	[MEM_READ_DQS_WIDTH-1:0] read_enable;
wire	[MEM_READ_DQS_WIDTH-1:0] valid_predict_clk;
wire	[MEM_READ_DQS_WIDTH-1:0] reset_n_valid_predict_clk;
reg		[MEM_READ_DQS_WIDTH-1:0] reset_n_fifo_write_side /* synthesis dont_merge syn_noprune syn_preserve = 1 */;
reg		[MEM_READ_DQS_WIDTH-1:0] reset_n_fifo_wraddress /* synthesis dont_merge syn_noprune syn_preserve = 1 */;

wire	[MEM_READ_DQS_WIDTH-1:0] read_capture_clk_pos;
`ifdef READ_FIFO_HALF_RATE
wire	[MEM_READ_DQS_WIDTH-1:0] read_capture_clk_neg;
reg		[MEM_READ_DQS_WIDTH-1:0] read_capture_clk_div2;
`endif

`ifdef DDRX_LPDDRX
`else
	`ifdef VFIFO_QUARTER_RATE
reg		[MEM_READ_DQS_WIDTH-1:0] read_capture_clk_div4;
wire	[MEM_READ_DQS_WIDTH-1:0] reset_n_read_capture_clk_div4;
	`endif
`endif

`ifdef QUARTER_RATE
wire	[(AFI_DATA_WIDTH/2)-1:0] read_fifo_output;
	`ifdef CORE_PERIPHERY_DUAL_CLOCK
wire	read_fifo_read_clk = pll_p2c_read_clk;	
wire	reset_n_read_fifo_read_clk = reset_n_p2c_read_clk;
	`else
wire	read_fifo_read_clk = pll_hr_clk;
wire	reset_n_read_fifo_read_clk = reset_n_hr_clk;
	`endif
`else
wire	[AFI_DATA_WIDTH-1:0] read_fifo_output;
wire	read_fifo_read_clk = pll_afi_clk;
wire	reset_n_read_fifo_read_clk = reset_n_afi_clk;
`endif

wire seq_calib_skip_vfifo = seq_calib_init[3];

wire [AFI_RATE_RATIO-1:0] afi_rdata_en_int;
wire [AFI_RATE_RATIO-1:0] afi_rdata_en_full_int;

generate
	genvar afi_phase;
	for (afi_phase=0; afi_phase<AFI_RATE_RATIO; ++afi_phase)
	begin : rdata_en
		wire curr_afi_rdata_en = afi_rdata_en[afi_phase];
		assign afi_rdata_en_full_int[afi_phase] = afi_rdata_en_full[afi_phase];

		if (EXTRA_VFIFO_SHIFT_INT >= 1) begin
			reg [EXTRA_VFIFO_SHIFT_INT-1:0] extra_vfifo_shift;
			wire [EXTRA_VFIFO_SHIFT_INT:0] 	extra_vfifo_shift_tmp = {extra_vfifo_shift, curr_afi_rdata_en};
			always @(posedge pll_afi_clk or negedge reset_n_afi_clk)
			begin
				if (~reset_n_afi_clk) begin
					extra_vfifo_shift <= {EXTRA_VFIFO_SHIFT_INT{1'b0}};
				end
				else begin
					extra_vfifo_shift <= extra_vfifo_shift_tmp[EXTRA_VFIFO_SHIFT_INT-1:0];
				end
			end
			assign afi_rdata_en_int[afi_phase] = extra_vfifo_shift[EXTRA_VFIFO_SHIFT_INT-1];
		end else begin
			assign afi_rdata_en_int[afi_phase] = curr_afi_rdata_en;
		end
	end
endgenerate

`ifdef PINGPONGPHY_EN
wire [AFI_RATE_RATIO-1:0] afi_rdata_en_int_1t;
wire [AFI_RATE_RATIO-1:0] afi_rdata_en_full_int_1t;
generate
	genvar afi_phase_pp;
	for (afi_phase_pp=0; afi_phase_pp<AFI_RATE_RATIO; ++afi_phase_pp)
	begin : rdata_en_1t
		wire curr_afi_rdata_en_1t = afi_rdata_en_1t[afi_phase_pp];
		assign afi_rdata_en_full_int_1t[afi_phase_pp] = afi_rdata_en_full_1t[afi_phase_pp];
		assign afi_rdata_en_int_1t[afi_phase_pp] = curr_afi_rdata_en_1t;
	end
endgenerate
`endif



`ifdef FULL_RATE
wire [AFI_RATE_RATIO-1:0] afi_rdata_en_full_vfifo_int = afi_rdata_en_full_int;
wire [RD_ENABLE_LFIFO_WIDTH-1:0] afi_rdata_en_full_lfifo_int = afi_rdata_en_full_int;
wire [RD_VALID_LFIFO_WIDTH-1:0] afi_rdata_en_lfifo_int = afi_rdata_en_int;
`else
  `ifdef DDRX_LPDDRX
wire [AFI_RATE_RATIO-1:0] afi_rdata_en_full_vfifo_int = afi_rdata_en_full_int;
    `ifdef QUARTER_RATE
    	`ifdef PINGPONGPHY_EN
wire [RD_ENABLE_LFIFO_WIDTH-1:0] afi_rdata_en_full_lfifo_int = {
	afi_rdata_en_full_int[0], 
	afi_rdata_en_full_int[0]
	};
wire [RD_VALID_LFIFO_WIDTH-1:0] afi_rdata_en_lfifo_int = {
	afi_rdata_en_int[0], 
	afi_rdata_en_int[0], 
	afi_rdata_en_int[0], 
	afi_rdata_en_int[0]
	};
		`else
wire [RD_ENABLE_LFIFO_WIDTH-1:0] afi_rdata_en_full_lfifo_int = {
	afi_rdata_en_full_int[2], 
	afi_rdata_en_full_int[0]
	};
wire [RD_VALID_LFIFO_WIDTH-1:0] afi_rdata_en_lfifo_int = {
	afi_rdata_en_int[2], 
	afi_rdata_en_int[2], 
	afi_rdata_en_int[0], 
	afi_rdata_en_int[0]
	};
		`endif 
    `endif
    `ifdef HALF_RATE
wire [RD_ENABLE_LFIFO_WIDTH-1:0] afi_rdata_en_full_lfifo_int = { afi_rdata_en_full_int[0] };
wire [RD_VALID_LFIFO_WIDTH-1:0] afi_rdata_en_lfifo_int = {
	afi_rdata_en_int[0], 
	afi_rdata_en_int[0]
	};
    `endif
  `else
wire [RD_VALID_LFIFO_WIDTH-1:0] afi_rdata_en_lfifo_int = afi_rdata_en_int;
    `ifdef QUARTER_RATE
wire [AFI_RATE_RATIO-1:0] afi_rdata_en_full_vfifo_int = {
	afi_rdata_en_full_int[3] | afi_rdata_en_full_int[2],
	afi_rdata_en_full_int[3] | afi_rdata_en_full_int[2],
	afi_rdata_en_full_int[1] | afi_rdata_en_full_int[0],
	afi_rdata_en_full_int[1] | afi_rdata_en_full_int[0] 
	};
wire [RD_ENABLE_LFIFO_WIDTH-1:0] afi_rdata_en_full_lfifo_int = {
	afi_rdata_en_full_int[3] | afi_rdata_en_full_int[2], 
	afi_rdata_en_full_int[1] | afi_rdata_en_full_int[0]
	};
    `endif
    `ifdef HALF_RATE
wire [AFI_RATE_RATIO-1:0] afi_rdata_en_full_vfifo_int = {
	afi_rdata_en_full_int[1] | afi_rdata_en_full_int[0],
	afi_rdata_en_full_int[1] | afi_rdata_en_full_int[0] 
	};
wire [RD_ENABLE_LFIFO_WIDTH-1:0] afi_rdata_en_full_lfifo_int = {
	afi_rdata_en_full_int[1] | afi_rdata_en_full_int[0]
	};
    `endif
  `endif
`endif  

`ifdef PINGPONGPHY_EN
reg [AFI_RATE_RATIO-1:0] afi_rdata_en_full_vfifo_int_1t;
reg [RD_ENABLE_LFIFO_WIDTH-1:0] afi_rdata_en_full_lfifo_int_1t;
reg [RD_VALID_LFIFO_WIDTH-1:0] afi_rdata_en_lfifo_int_1t;
always @ (*) begin
	if (mux_sel) begin
		afi_rdata_en_full_vfifo_int_1t = afi_rdata_en_full_int;
		afi_rdata_en_full_lfifo_int_1t = {
			afi_rdata_en_full_int[0], 
			afi_rdata_en_full_int[0]
			};
		afi_rdata_en_lfifo_int_1t = {
			afi_rdata_en_int[0], 
			afi_rdata_en_int[0], 
			afi_rdata_en_int[0], 
			afi_rdata_en_int[0]
			};
	end else begin
		afi_rdata_en_full_vfifo_int_1t = afi_rdata_en_full_int_1t;
		afi_rdata_en_full_lfifo_int_1t = {
			afi_rdata_en_full_int_1t[0], 
			afi_rdata_en_full_int_1t[0]
			};
		afi_rdata_en_lfifo_int_1t = {
			afi_rdata_en_int_1t[0], 
			afi_rdata_en_int_1t[0], 
			afi_rdata_en_int_1t[0], 
			afi_rdata_en_int_1t[0]
			};
	end
end

`endif


`ifdef USE_SHADOW_REGS
  `ifdef QUARTER_RATE
wire  [AFI_RATE_RATIO-1:0] afi_rrank_decoded_int = {
	afi_rrank_decoded[MEM_READ_DQS_WIDTH * 3],
	afi_rrank_decoded[MEM_READ_DQS_WIDTH * 2],
	afi_rrank_decoded[MEM_READ_DQS_WIDTH * 1],
	afi_rrank_decoded[MEM_READ_DQS_WIDTH * 0]
	};
		`ifdef PINGPONGPHY_EN
wire  [AFI_RATE_RATIO-1:0] afi_rrank_decoded_int_1t = {
	afi_rrank_decoded[MEM_READ_DQS_WIDTH * 3 + MEM_READ_DQS_WIDTH/2],
	afi_rrank_decoded[MEM_READ_DQS_WIDTH * 2 + MEM_READ_DQS_WIDTH/2],
	afi_rrank_decoded[MEM_READ_DQS_WIDTH * 1 + MEM_READ_DQS_WIDTH/2],
	afi_rrank_decoded[MEM_READ_DQS_WIDTH * 0 + MEM_READ_DQS_WIDTH/2]
	};
		`endif
  `endif
  `ifdef HALF_RATE
wire  [AFI_RATE_RATIO-1:0] afi_rrank_decoded_int = {
	afi_rrank_decoded[MEM_READ_DQS_WIDTH * 1],
	afi_rrank_decoded[MEM_READ_DQS_WIDTH * 0]
	};
  `endif
  `ifdef FULL_RATE
wire  [AFI_RATE_RATIO-1:0] afi_rrank_decoded_int = { afi_rrank_decoded[0] };
  `endif
`endif

// *******************************************************************************************************************
// VALID PREDICTION
// Read request (afi_rdata_en) is generated on the AFI clock domain (pll_afi_clk).
// Read data is captured on the read_capture_clk domain (output clock from I/O). 
// The purpose of valid prediction is to determine which read_capture_clk cycle valid data will be returned to the core
// after the request is issued on pll_afi_clk; this is essentially the latency between read request seen on 
// AFI interface and valid data available at the output of ALTDQ_DQS.
// The clock domain crossing between pll_afi_clk and read_capture_clk is handled by a FIFO (uread_valid_fifo).
// The pll_afi_clk controls the write side of the FIFO and the read_capture_clk controls the read side.
// The pll_afi_clk writes into the FIFO on every clock cycle.  When there is no read request, it writes a 0;
// when there is a read request, it writes a 1 (refer to as a token) into the FIFO.
// The read_capture_clk reads from the FIFO every clock cycle, whenever it reads a token, it means that valid data
// is available during that cycle.  Each token represents 1 cycle of valid data.
// In full rate, BL=2, 1 read results in 1 AFI cycle of valid data, controller asserts afi_rdata_en for 1 cycle
// In full rate, BL=4, 1 read results in 2 AFI cycles of valid data, controller asserts afi_rdata_en for 2 cycles
// In full rate, BL=8, 1 read results in 4 AFI cycles of valid data, controller asserts afi_rdata_en for 4 cycles
// In half rate, BL=2, not supported
// In half rate, BL=4, 1 read results in 1 AFI cycle of valid data, controller asserts afi_rdata_en for 1 cycle
// In half rate, BL=8, 1 read results in 2 AFI cycle of valid data, controller asserts afi_rdata_en for 2 cycles
// In full rate, 1 afi_rdata_en cycle = 1 token
// In half rate, 1 afi_rdata_en cycle = 2 tokens
//
// After reset is released, the relationship between the read and write pointers can be arbitrary.
// During calibration, the sequencer keeps incrementing the write pointer (both the sequencer and write pointer operates
// on pll_afi_clk) until the correct latency has been tuned.
// *******************************************************************************************************************

`ifdef DDRX_LPDDRX
assign valid_predict_clk = {MEM_READ_DQS_WIDTH{pll_dqs_ena_clk}};
assign reset_n_valid_predict_clk = {MEM_READ_DQS_WIDTH{reset_n_resync_clk}};
`else
	`ifdef USE_IO_CLOCK_DIVIDER

localparam CLOCK_DIVIDER_INVERT = "false";

// Divide read_capture_clk by 2 and use it to drive the VFIFO at HR
generate
genvar dqsgroup_i;
	for (dqsgroup_i=0; dqsgroup_i<MEM_READ_DQS_WIDTH; dqsgroup_i=dqsgroup_i+1)
	begin: clock_div2
		`ifdef STRATIXV
		stratixv_io_clock_divider uread_clock_divider(
		`endif
		`ifdef ARRIAVGZ
	        arriavgz_io_clock_divider uread_clock_divider(
		`endif
			.clk(read_capture_clk[dqsgroup_i]),
			.clkout(valid_predict_clk[dqsgroup_i])
		);
		defparam uread_clock_divider.power_up = "low";
		defparam uread_clock_divider.invert_phase = CLOCK_DIVIDER_INVERT;
		defparam uread_clock_divider.use_masterin = "false";
	end
endgenerate
assign reset_n_valid_predict_clk = reset_n_fifo_write_side;
	`else 
		`ifdef READ_FIFO_HALF_RATE
assign valid_predict_clk = read_capture_clk_neg;
		`else
assign valid_predict_clk = read_capture_clk_pos;
		`endif
assign reset_n_valid_predict_clk = reset_n_fifo_write_side;
	`endif 
	
	`ifdef QUARTER_RATE
generate
genvar dqsgroup_j;
	for (dqsgroup_j=0; dqsgroup_j<MEM_READ_DQS_WIDTH; dqsgroup_j=dqsgroup_j+1)
	begin: clock_div4
		always @(posedge valid_predict_clk[dqsgroup_j] or negedge reset_n_valid_predict_clk[dqsgroup_j])
		begin
			if (~reset_n_valid_predict_clk[dqsgroup_j])
				read_capture_clk_div4[dqsgroup_j] <= 1'b0;
			else
				read_capture_clk_div4[dqsgroup_j] <= ~read_capture_clk_div4[dqsgroup_j];
		end
	end
endgenerate

assign reset_n_read_capture_clk_div4 = reset_n_valid_predict_clk;
	`endif
`endif 

generate
if (MAKE_FIFOS_IN_ALTDQDQS != "true")
begin
genvar dqsgroup, vfifo_i;
	for (dqsgroup=0; dqsgroup<MEM_READ_DQS_WIDTH; dqsgroup=dqsgroup+1)
	begin: read_valid_predict
	
		wire [VFIFO_RATE_MULT-1:0] vfifo_out_per_dqs;
`ifdef USE_SHADOW_REGS
		wire [VFIFO_RATE_MULT-1:0] vfifo_rank_out_per_dqs;
`endif	
		reg [READ_VALID_FIFO_WRITE_ADDR_WIDTH-1:0] qvld_wr_address;
`ifdef VFIFO_AS_SHIFT_REG
`else
		reg [READ_VALID_FIFO_READ_ADDR_WIDTH-1:0] qvld_rd_address;
`endif

`ifndef SYNTH_FOR_SIM
 		// synthesis translate_off
`endif
		wire [ceil_log2(READ_VALID_FIFO_SIZE)-1:0] qvld_wr_address_offset;
`ifdef VFIFO_AS_SHIFT_REG
		assign qvld_wr_address_offset = QVLD_WR_ADDRESS_OFFSET;
`else
		assign qvld_wr_address_offset = qvld_rd_address + QVLD_WR_ADDRESS_OFFSET;
`endif
`ifndef SYNTH_FOR_SIM
 		// synthesis translate_on
`endif
		
`ifdef QUARTER_RATE		
		wire qvld_increment_wr_address = seq_read_increment_vfifo_qr[dqsgroup];
`else
		wire qvld_increment_wr_address = seq_read_increment_vfifo_hr[dqsgroup];
`endif		
		
`ifdef FULL_RATE
		assign qvld_num_fr_cycle_shift[dqsgroup] = 2'b00;
`else
		// In half rate, 1 afi_rdata_en_full cycle = 2 tokens, qvld_in[0] and qvld_in[1]
		// In 1/4 rate, 1 afi_rdata_en_full cycle = 4 tokens, qvld_in[0..3]
		// etc.
		// Tokens are written at AFI clock rate but read at full rate.
		// During calibration the latency needs to be tuned at full rate granularity.
		// For example, in half rate, in the base case, 1 afi_rdata_en_full will result
		// in two tokens in write address 0, that means read address 0 and read address 1
		// will both have tokens. If the sequencer request to increase the latency by
		// full rate cycle, the write side first writes 10 into write address 0, then
		// it writes 01 into write address 1; this means there are tokens in read
		// address 1 and read address 2.
		always @(posedge pll_afi_clk or negedge reset_n_afi_clk)
		begin
			if (~reset_n_afi_clk) begin
	`ifndef SYNTH_FOR_SIM
				// synthesis translate_off
	`endif
	`ifdef HALF_RATE
				qvld_num_fr_cycle_shift[dqsgroup] <= {1'b0, ((seq_calib_skip_vfifo) ? qvld_wr_address_offset[0] : 1'b0)};
	`endif
	`ifdef QUARTER_RATE
				qvld_num_fr_cycle_shift[dqsgroup] <= (seq_calib_skip_vfifo) ? qvld_wr_address_offset[1:0] : 2'b00;
	`endif
	`ifndef SYNTH_FOR_SIM
				// synthesis translate_on
				// synthesis read_comments_as_HDL on
				// qvld_num_fr_cycle_shift[dqsgroup] <= 2'b00;
				// synthesis read_comments_as_HDL off
	`endif
			end else begin
	`ifdef HALF_RATE
				if (seq_read_increment_vfifo_fr[dqsgroup]) begin
					qvld_num_fr_cycle_shift[dqsgroup] <= 2'b01;
				end else if (seq_read_increment_vfifo_hr[dqsgroup]) begin
					qvld_num_fr_cycle_shift[dqsgroup] <= 2'b00;
				end
	`endif
	`ifdef QUARTER_RATE
				if (seq_read_increment_vfifo_hr[dqsgroup] || seq_read_increment_vfifo_fr[dqsgroup]) begin
					qvld_num_fr_cycle_shift[dqsgroup] <= {seq_read_increment_vfifo_hr[dqsgroup], seq_read_increment_vfifo_fr[dqsgroup]};
				end else if (seq_read_increment_vfifo_qr[dqsgroup]) begin
					qvld_num_fr_cycle_shift[dqsgroup] <= 2'b00;
				end
	`endif
			end
		end	
`endif

		wire [AFI_RATE_RATIO-1:0] qvld_in;


`ifdef PINGPONGPHY_EN
	wire [AFI_RATE_RATIO-1:0] afi_rdata_en_full_vfifo_int_pp;
	assign afi_rdata_en_full_vfifo_int_pp = mux_sel ? afi_rdata_en_full_vfifo_int : ((dqsgroup < MEM_READ_DQS_WIDTH/2) ? afi_rdata_en_full_vfifo_int : afi_rdata_en_full_vfifo_int_1t);

	`ifdef USE_SHADOW_REGS
	wire [AFI_RATE_RATIO-1:0] afi_rrank_decoded_int_pp;
	assign afi_rrank_decoded_int_pp = mux_sel ? afi_rrank_decoded_int : ((dqsgroup < MEM_READ_DQS_WIDTH/2) ? afi_rrank_decoded_int : afi_rrank_decoded_int_1t);
	`endif

`endif

		fr_cycle_shifter uread_fr_cycle_shifter(
			.clk (pll_afi_clk),
			.reset_n (reset_n_afi_clk),
			.shift_by (qvld_num_fr_cycle_shift[dqsgroup]),
			`ifdef PINGPONGPHY_EN
			.datain (afi_rdata_en_full_vfifo_int_pp),
			`else
			.datain (afi_rdata_en_full_vfifo_int),
			`endif
			.dataout (qvld_in));
		defparam uread_fr_cycle_shifter.DATA_WIDTH = 1;

`ifdef USE_SHADOW_REGS
		wire [AFI_RATE_RATIO-1:0] rank_in;
		fr_cycle_shifter uread_fr_cycle_shifter_rank(
			.clk (pll_afi_clk),
			.reset_n (reset_n_afi_clk),
			.shift_by (qvld_num_fr_cycle_shift[dqsgroup]),
			`ifdef PINGPONGPHY_EN
			.datain (afi_rrank_decoded_int_pp),
			`else
			.datain (afi_rrank_decoded_int),
			`endif
			.dataout (rank_in));
		defparam uread_fr_cycle_shifter_rank.DATA_WIDTH = 1;
`else
		wire [AFI_RATE_RATIO-1:0] rank_in = '0;
`endif

`ifdef VFIFO_AS_SHIFT_REG
`else
	`ifdef VFIFO_QUARTER_RATE
		wire vfifo_read_clk = read_capture_clk_div4[dqsgroup];
		wire vfifo_read_clk_reset_n = reset_n_read_capture_clk_div4[dqsgroup];
	`else
		wire vfifo_read_clk = valid_predict_clk[dqsgroup];
		wire vfifo_read_clk_reset_n = reset_n_valid_predict_clk[dqsgroup];
	`endif
`endif

		always @(posedge pll_afi_clk)
		begin
`ifndef SYNTH_FOR_SIM
			// synthesis translate_off
`endif
`ifdef DDRX_LPDDRX
			if (~reset_n_afi_clk) begin
`else
			// In skip calibration simulation, the reset of qvld_wr_address must be removed
			// after the removal of the qvld_rd_address reset in order for the addresses to
			// lock at the specified offset.  So we use the same reset for both in simulation.
			if (~vfifo_read_clk_reset_n) begin
`endif
				qvld_wr_address <= (seq_calib_skip_vfifo) ? (qvld_wr_address_offset >> ceil_log2(AFI_RATE_RATIO)) : {READ_VALID_FIFO_WRITE_ADDR_WIDTH{1'b0}};
`ifndef SYNTH_FOR_SIM
			// synthesis translate_on
			// synthesis read_comments_as_HDL on
			// if (~reset_n_afi_clk) begin
			// 	qvld_wr_address <= {READ_VALID_FIFO_WRITE_ADDR_WIDTH{1'b0}};
			// synthesis read_comments_as_HDL off
`endif
			end else begin
`ifdef VFIFO_AS_SHIFT_REG
				qvld_wr_address <= qvld_increment_wr_address ? (qvld_wr_address + 2'd1) : qvld_wr_address;
`else
				qvld_wr_address <= qvld_increment_wr_address ? (qvld_wr_address + 2'd2) : (qvld_wr_address + 2'd1);
`endif
			end
		end

`ifdef VFIFO_AS_SHIFT_REG
		// The valid-prediction FIFO is implemented as a shift-register
		for (vfifo_i=0; vfifo_i<VFIFO_RATE_MULT; vfifo_i=vfifo_i+1)
		begin: qvld_shifter_gen
			reg [QVLD_SHIFTER_LENGTH-1:0] qvld_shifter;
`ifdef USE_SHADOW_REGS
			reg [QVLD_SHIFTER_LENGTH-1:0] rank_shifter;
`endif			

			always @(posedge pll_afi_clk or negedge reset_n_afi_clk)
			begin
				if (~reset_n_afi_clk) begin
					qvld_shifter <= {QVLD_SHIFTER_LENGTH{1'b0}};
`ifdef USE_SHADOW_REGS
					rank_shifter <= {QVLD_SHIFTER_LENGTH{1'b0}};
`endif
				end	else begin
					qvld_shifter <= {1'b0, qvld_shifter[QVLD_SHIFTER_LENGTH-1:1]};
					qvld_shifter[qvld_wr_address + QVLD_EXTRA_FLOP_STAGES] <= qvld_in[vfifo_i];
`ifdef USE_SHADOW_REGS
					rank_shifter <= {1'b0, rank_shifter[QVLD_SHIFTER_LENGTH-1:1]};
					rank_shifter[qvld_wr_address + QVLD_EXTRA_FLOP_STAGES] <= rank_in[vfifo_i];				
`endif
				end
		 	end
			
			assign vfifo_out_per_dqs[vfifo_i] = qvld_shifter[0];
`ifdef USE_SHADOW_REGS
			assign vfifo_rank_out_per_dqs[vfifo_i] = rank_shifter[0];
`endif
		end
`else
		always @(posedge vfifo_read_clk or negedge vfifo_read_clk_reset_n)
		begin
			if (~vfifo_read_clk_reset_n)
				qvld_rd_address <= {READ_VALID_FIFO_READ_ADDR_WIDTH{1'b0}};
			else
				qvld_rd_address <= qvld_rd_address + 1'b1;
		end

		wire [VFIFO_RATE_MULT-1:0] vfifo_out_per_dqs_tmp;
		
		flop_mem	uread_valid_fifo(
			.wr_reset_n (reset_n_afi_clk),
			.wr_clk	    (pll_afi_clk),
			.wr_en      (1'b1),
			.wr_addr    (qvld_wr_address),
			.wr_data    (qvld_in),
			.rd_reset_n	(vfifo_read_clk_reset_n),
			.rd_clk     (vfifo_read_clk),
			.rd_en      (1'b1),
			.rd_addr    (qvld_rd_address),
			.rd_data    (vfifo_out_per_dqs_tmp)
		);
		defparam uread_valid_fifo.WRITE_MEM_DEPTH = READ_VALID_FIFO_WRITE_MEM_DEPTH;
		defparam uread_valid_fifo.WRITE_ADDR_WIDTH = READ_VALID_FIFO_WRITE_ADDR_WIDTH;
		defparam uread_valid_fifo.WRITE_DATA_WIDTH = AFI_RATE_RATIO;
		defparam uread_valid_fifo.READ_MEM_DEPTH = READ_VALID_FIFO_READ_MEM_DEPTH;
		defparam uread_valid_fifo.READ_ADDR_WIDTH = READ_VALID_FIFO_READ_ADDR_WIDTH;
		defparam uread_valid_fifo.READ_DATA_WIDTH = VFIFO_RATE_MULT;

	`ifdef DDRX_LPDDRX		
		// These extra flop stages are added to the output of the VFIFO
		// These adds delay without expanding the VFIFO size
		// Expanding the VFIFO size (also means bigger address counters) to 32 causes timing failures
		for (vfifo_i=0; vfifo_i<VFIFO_RATE_MULT; vfifo_i=vfifo_i+1)
		begin: qvld_extra_flop
			reg [QVLD_EXTRA_FLOP_STAGES-1:0] vfifo_out_per_dqs_r;
		
			always @(posedge vfifo_read_clk or negedge vfifo_read_clk_reset_n)
			begin
				if (~vfifo_read_clk_reset_n) begin
					vfifo_out_per_dqs_r <= '0;
				end else begin
					vfifo_out_per_dqs_r <= {vfifo_out_per_dqs_r[QVLD_EXTRA_FLOP_STAGES-2:0], vfifo_out_per_dqs_tmp[vfifo_i]};
				end
			end
			
			assign vfifo_out_per_dqs[vfifo_i] = vfifo_out_per_dqs_r[QVLD_EXTRA_FLOP_STAGES-1];
		end
	`else
		assign vfifo_out_per_dqs = vfifo_out_per_dqs_tmp;
	`endif
`endif

`ifdef VFIFO_QUARTER_RATE
		// Convert QR valid-prediction signal into HR using soft logic
		wire [READ_VALID_FIFO_PER_DQS_WIDTH-1:0] qvld_per_dqs;
	`ifdef USE_SHADOW_REGS
		wire [READ_VALID_FIFO_PER_DQS_WIDTH-1:0] rank_hr_per_dqs;
	`endif
		
	`ifdef VFIFO_AS_SHIFT_REG
		wire vfifo_out_qr_to_hr_clk = pll_afi_clk;
		wire vfifo_out_qr_to_hr_reset_n = reset_n_afi_clk;
		wire vfifo_out_qr_to_hr_dr_clk = pll_hr_clk;
		wire vfifo_out_qr_to_hr_dr_reset_n = reset_n_hr_clk;
	`else
		wire vfifo_out_qr_to_hr_clk = read_capture_clk_div4[dqsgroup];
		wire vfifo_out_qr_to_hr_reset_n = reset_n_read_capture_clk_div4[dqsgroup];
		wire vfifo_out_qr_to_hr_dr_clk = valid_predict_clk[dqsgroup];
		wire vfifo_out_qr_to_hr_dr_reset_n = reset_n_valid_predict_clk[dqsgroup];
	`endif
		
		simple_ddio_out	vfifo_out_qr_to_hr(
			.reset_n    (vfifo_out_qr_to_hr_reset_n),
			.clk        (vfifo_out_qr_to_hr_clk),
			.dr_clk     (vfifo_out_qr_to_hr_dr_clk),
			.dr_reset_n (vfifo_out_qr_to_hr_dr_reset_n),
			.datain     (vfifo_out_per_dqs),
			.dataout    (qvld_per_dqs)
			);
		defparam
			vfifo_out_qr_to_hr.REGISTER_OUTPUT = REGISTER_C2P,
			vfifo_out_qr_to_hr.OUTPUT_REGISTER_STAGES = VFIFO_C2P_PIPELINE_DEPTH,
			vfifo_out_qr_to_hr.DATA_WIDTH = 1,
			vfifo_out_qr_to_hr.OUTPUT_FULL_DATA_WIDTH = 2,
			vfifo_out_qr_to_hr.USE_CORE_LOGIC = "true",
			vfifo_out_qr_to_hr.REG_POST_RESET_HIGH = "false";		

	`ifdef USE_SHADOW_REGS
		simple_ddio_out vfifo_rank_out_qr_to_hr(
			.reset_n    (vfifo_out_qr_to_hr_reset_n),
			.clk        (vfifo_out_qr_to_hr_clk),
			.dr_clk     (vfifo_out_qr_to_hr_dr_clk),
			.dr_reset_n (vfifo_out_qr_to_hr_dr_reset_n),
			.datain     (vfifo_rank_out_per_dqs),
			.dataout    (rank_hr_per_dqs)
		);
		defparam
			vfifo_rank_out_qr_to_hr.REGISTER_OUTPUT = REGISTER_C2P,
			vfifo_rank_out_qr_to_hr.DATA_WIDTH = 1,
			vfifo_rank_out_qr_to_hr.OUTPUT_FULL_DATA_WIDTH = 2,
			vfifo_rank_out_qr_to_hr.USE_CORE_LOGIC = "true",
			vfifo_rank_out_qr_to_hr.REG_POST_RESET_HIGH = "false";
			
		assign rrank_select_out[dqsgroup] = rank_hr_per_dqs[READ_VALID_FIFO_PER_DQS_WIDTH-1];
	`endif
`else
	`ifdef VFIFO_AS_SHIFT_REG
		wire [READ_VALID_FIFO_PER_DQS_WIDTH-1:0] qvld_per_dqs;
		
		if (REGISTER_C2P == "true") begin
			reg [READ_VALID_FIFO_PER_DQS_WIDTH-1:0] vfifo_out_per_dqs_r;
			always @(posedge pll_afi_clk or negedge reset_n_afi_clk) begin
				if (~reset_n_afi_clk) 
					vfifo_out_per_dqs_r <= '0;
				else
					vfifo_out_per_dqs_r <= vfifo_out_per_dqs;
			end
			assign qvld_per_dqs = vfifo_out_per_dqs_r;
		end else begin
			assign qvld_per_dqs = vfifo_out_per_dqs;
		end
		
		`ifdef USE_SHADOW_REGS
		if (REGISTER_C2P == "true") begin
			reg rrank_select_out_r;
			always @(posedge pll_afi_clk or negedge reset_n_afi_clk) begin
				if (~reset_n_afi_clk)
					rrank_select_out_r <= '0;
				else
					rrank_select_out_r <= vfifo_rank_out_per_dqs[VFIFO_RATE_MULT-1];
			end
			assign rrank_select_out[dqsgroup] = rrank_select_out_r;
			
		end else begin
			assign rrank_select_out[dqsgroup] = vfifo_rank_out_per_dqs[VFIFO_RATE_MULT-1];
		end
		`endif
	`else
		wire [READ_VALID_FIFO_PER_DQS_WIDTH-1:0] qvld_per_dqs = vfifo_out_per_dqs;
	`endif
`endif
		
		// Map per-dqs vfifo output bus to the per-interface vfifo output bus.
		for (vfifo_i=0; vfifo_i<READ_VALID_FIFO_PER_DQS_WIDTH; vfifo_i=vfifo_i+1)
		begin: map_qvld_per_dqs_to_qvld
			assign qvld[dqsgroup+(vfifo_i*MEM_READ_DQS_WIDTH)] = qvld_per_dqs[vfifo_i];
		end
	end
end
endgenerate

`ifdef DDRX_LPDDRX
assign dqs_enable_ctrl = qvld;
`endif

reg [MAX_READ_LATENCY-1:0] latency_shifter [RD_VALID_LFIFO_WIDTH-1:0];
reg [MAX_READ_LATENCY-1:0] full_latency_shifter [RD_ENABLE_LFIFO_WIDTH-1:0];
`ifdef PINGPONGPHY_EN
reg [MAX_READ_LATENCY-1:0] latency_shifter_1t [RD_VALID_LFIFO_WIDTH-1:0];
reg [MAX_READ_LATENCY-1:0] full_latency_shifter_1t [RD_ENABLE_LFIFO_WIDTH-1:0];
`endif

generate
genvar rd_valid_lfifo_i, rd_enable_lfifo_i;
	for (rd_valid_lfifo_i=0; rd_valid_lfifo_i<RD_VALID_LFIFO_WIDTH; ++rd_valid_lfifo_i)
	begin : rd_valid_lfifo_gen
		always @(posedge pll_afi_clk or negedge reset_n_afi_clk)
		begin

			if (~reset_n_afi_clk) begin
				latency_shifter[rd_valid_lfifo_i] <= {MAX_READ_LATENCY{1'b0}};
				`ifdef PINGPONGPHY_EN 
				latency_shifter_1t[rd_valid_lfifo_i] <= {MAX_READ_LATENCY{1'b0}};
				`endif
			
			end
			else begin
				latency_shifter[rd_valid_lfifo_i] <= {
					latency_shifter[rd_valid_lfifo_i][MAX_READ_LATENCY-2:0], 
					afi_rdata_en_lfifo_int[rd_valid_lfifo_i]};
				`ifdef PINGPONGPHY_EN 
				latency_shifter_1t[rd_valid_lfifo_i] <= {
					latency_shifter_1t[rd_valid_lfifo_i][MAX_READ_LATENCY-2:0], 
					afi_rdata_en_lfifo_int_1t[rd_valid_lfifo_i]};
				`endif
			end
		end
	end
	
	for (rd_enable_lfifo_i=0; rd_enable_lfifo_i<RD_ENABLE_LFIFO_WIDTH; ++rd_enable_lfifo_i)
	begin : rd_enable_lfifo_gen
		always @(posedge pll_afi_clk or negedge reset_n_afi_clk)
		begin

			if (~reset_n_afi_clk) begin
				full_latency_shifter[rd_enable_lfifo_i] <= {MAX_READ_LATENCY{1'b0}};
				`ifdef PINGPONGPHY_EN 
				full_latency_shifter_1t[rd_enable_lfifo_i] <= {MAX_READ_LATENCY{1'b0}};
				`endif
			end
			else begin
				full_latency_shifter[rd_enable_lfifo_i] <= {
					full_latency_shifter[rd_enable_lfifo_i][MAX_READ_LATENCY-2:0], 
					afi_rdata_en_full_lfifo_int[rd_enable_lfifo_i]};
				`ifdef PINGPONGPHY_EN 
				full_latency_shifter_1t[rd_enable_lfifo_i] <= {
					full_latency_shifter_1t[rd_enable_lfifo_i][MAX_READ_LATENCY-2:0], 
					afi_rdata_en_full_lfifo_int_1t[rd_enable_lfifo_i]};
				`endif
			end
		end

	end
endgenerate

generate
if (MAKE_FIFOS_IN_ALTDQDQS != "true")
begin
	genvar dqs_count, subgroup, dq_count, timeslot, rd_valid_sel_count, rd_enable_sel_count;
	
	for (dqs_count=0; dqs_count<MEM_READ_DQS_WIDTH; dqs_count=dqs_count+1)
	begin: read_buffering

`ifdef USE_HARD_READ_FIFO
	`ifdef DDRX_LPDDRX
	`else
		`ifdef FULL_RATE
		wire [0:0] wren;
		`else
		wire [1:0] wren;
		`endif
	`endif
`else
	`ifdef DDRX_LPDDRX
		wire	[USE_NUM_SUBGROUP_PER_READ_DQS-1:0] wren;
		`ifdef READ_FIFO_HALF_RATE
		wire	[USE_NUM_SUBGROUP_PER_READ_DQS-1:0] wren_neg;
		`endif
	`else
		reg		[USE_NUM_SUBGROUP_PER_READ_DQS-1:0] wren /* synthesis dont_merge */;
		`ifdef READ_FIFO_HALF_RATE
		reg		[USE_NUM_SUBGROUP_PER_READ_DQS-1:0] wren_neg /* synthesis dont_merge */;
		`endif
	`endif
`endif

		always @(posedge pll_afi_clk or negedge reset_n_afi_clk)
		begin
			if (~reset_n_afi_clk) begin
				reset_n_fifo_write_side[dqs_count] <= 1'b0;
				reset_n_fifo_wraddress[dqs_count] <= 1'b0;
			end
			else begin
`ifdef DDRX_LPDDRX
				reset_n_fifo_write_side[dqs_count] <= ~seq_read_fifo_reset[dqs_count];
				reset_n_fifo_wraddress[dqs_count] <= ~seq_read_fifo_reset[dqs_count];
`else
				reset_n_fifo_write_side[dqs_count] <= seq_reset_mem_stable;
				reset_n_fifo_wraddress[dqs_count] <= seq_reset_mem_stable & ~seq_read_fifo_reset[dqs_count];
`endif
			end
		end

		wire [RD_ENABLE_LFIFO_WIDTH-1:0] read_enable_from_lfifo;
		wire [READ_FIFO_DQ_GROUP_OUTPUT_WIDTH-1:0] read_fifo_output_per_dqs;
		
		// Perform read data mapping from ddio_phy_dq to ddio_phy_dq_per_dqs.
		//
		// The ddio_phy_dq bus is the read data coming out of the DDIO, and so
		// is 2x the interface data width. The bus is ordered by DQS group
		// and sub-ordered by time slot:
		// 
		// D1_T1, D1_T0, D0_T1, D0_T0
		//
		// The ddio_phy_dq_per_dqs bus is a subset of the ddio_phy_dq bus that
		// is specific to the current DQS group. Like ddio_phy_dq, it's ordered
		// by time slot:
		//
		// D0_T1, D0_T0
		wire	[DDIO_DQ_GROUP_DATA_WIDTH-1:0] ddio_phy_dq_per_dqs;
		assign ddio_phy_dq_per_dqs = ddio_phy_dq[(DDIO_DQ_GROUP_DATA_WIDTH*(dqs_count+1)-1) : (DDIO_DQ_GROUP_DATA_WIDTH*dqs_count)];
		
		`ifdef PINGPONGPHY_EN
		reg [MAX_READ_LATENCY-1:0] latency_shifter_pp [RD_VALID_LFIFO_WIDTH-1:0];
		reg [MAX_READ_LATENCY-1:0] full_latency_shifter_pp [RD_ENABLE_LFIFO_WIDTH-1:0];
		assign latency_shifter_pp = (dqs_count < (MEM_READ_DQS_WIDTH/2)) ? latency_shifter : latency_shifter_1t;
		assign full_latency_shifter_pp = (dqs_count < (MEM_READ_DQS_WIDTH/2)) ? full_latency_shifter : full_latency_shifter_1t;
		`endif

		for (rd_valid_sel_count=0; rd_valid_sel_count<RD_VALID_LFIFO_WIDTH; ++rd_valid_sel_count)
		begin : rd_valid_lfifo_sel
			wire read_valid_from_lfifo;
			read_valid_selector uread_valid_selector(
				.reset_n		(reset_n_afi_clk),
				.pll_afi_clk		(pll_afi_clk),
				
				`ifdef PINGPONGPHY_EN
				.latency_shifter	(latency_shifter_pp[rd_valid_sel_count]),
				`else
				.latency_shifter	(latency_shifter[rd_valid_sel_count]),
				`endif
				.latency_counter	(seq_read_latency_counter),
				.read_enable		(),
				.read_valid		(read_valid_from_lfifo)
			);
			defparam uread_valid_selector.MAX_LATENCY_COUNT_WIDTH = MAX_LATENCY_COUNT_WIDTH;
			
			if (REGISTER_LFIFO_OUTPUTS_PER_GROUP == "true") begin
				if (RD_ENABLE_LFIFO_WIDTH == 1) begin
					reg read_valid_r /* synthesis dont_merge syn_noprune syn_preserve = 1 */;
					
					always @(posedge pll_afi_clk or negedge reset_n_afi_clk)
					begin
						if (~reset_n_afi_clk)
							read_valid_r <= '0;
						else
							read_valid_r <= read_valid_from_lfifo;
					end
					assign read_valid[rd_valid_sel_count][dqs_count] = read_valid_r;
					
				end else begin
					
					reg read_valid_r /* synthesis dont_merge syn_noprune syn_preserve = 1 */;
					reg read_valid_rr /* synthesis dont_merge syn_noprune syn_preserve = 1 */;
					
					always @(posedge pll_afi_clk or negedge reset_n_afi_clk)
					begin
						if (~reset_n_afi_clk) begin
							read_valid_r <= '0;
							read_valid_rr <= '0;
						end else begin
							read_valid_r <= read_valid_from_lfifo;
							read_valid_rr <= read_valid_r;
						end
					end
					assign read_valid[rd_valid_sel_count][dqs_count] = read_valid_rr;
				end
			end else begin
				assign read_valid[rd_valid_sel_count][dqs_count] = read_valid_from_lfifo;
			end			
		end
		
		for (rd_enable_sel_count=0; rd_enable_sel_count<RD_ENABLE_LFIFO_WIDTH; ++rd_enable_sel_count)
		begin : rd_enable_lfifo_sel
			read_valid_selector uread_valid_full_selector(
				.reset_n		(reset_n_afi_clk),
				.pll_afi_clk		(pll_afi_clk),
				`ifdef PINGPONGPHY_EN
				.latency_shifter	(full_latency_shifter_pp[rd_enable_sel_count]),
				`else
				.latency_shifter	(full_latency_shifter[rd_enable_sel_count]),
				`endif
				.latency_counter	(seq_read_latency_counter),
				.read_enable		(read_enable_from_lfifo[rd_enable_sel_count]),
				.read_valid		()
			);
			defparam uread_valid_full_selector.MAX_LATENCY_COUNT_WIDTH = MAX_LATENCY_COUNT_WIDTH;
		end
		
		wire read_enable_one_bit;
		
		if (RD_ENABLE_LFIFO_WIDTH == 1) begin
			assign read_enable_one_bit = read_enable_from_lfifo[0];

		end else if (RD_ENABLE_LFIFO_WIDTH == 2) begin
			simple_ddio_out	read_enable_from_lfifo_qr_to_hr(
				.reset_n    (reset_n_afi_clk),
				.clk        (pll_afi_clk),
				.dr_clk     (1'b1),
				.dr_reset_n (1'b1),
				.datain     (read_enable_from_lfifo),
				.dataout    (read_enable_one_bit)
				);
			defparam
				read_enable_from_lfifo_qr_to_hr.REGISTER_OUTPUT = "false",
				read_enable_from_lfifo_qr_to_hr.DATA_WIDTH = 1,
				read_enable_from_lfifo_qr_to_hr.OUTPUT_FULL_DATA_WIDTH = 1,
				read_enable_from_lfifo_qr_to_hr.USE_CORE_LOGIC = "true",
				read_enable_from_lfifo_qr_to_hr.REG_POST_RESET_HIGH = "false";		
		end

		if (REGISTER_LFIFO_OUTPUTS_PER_GROUP == "true") begin
			reg read_enable_rr /* synthesis dont_merge syn_noprune syn_preserve = 1 */;
			reg read_enable_r /* synthesis dont_merge syn_noprune syn_preserve = 1 */;
		
			always @(posedge read_fifo_read_clk or negedge reset_n_read_fifo_read_clk)
			begin
				if (~reset_n_read_fifo_read_clk) begin
					read_enable_r <= '0;
					read_enable_rr <= '0;
				end else begin
					read_enable_r <= read_enable_one_bit;
					read_enable_rr <= read_enable_r;
				end
			end
		
			assign read_enable[dqs_count] = read_enable_rr;
		end else begin
			assign read_enable[dqs_count] = read_enable_one_bit;
		end

`ifdef USE_HARD_READ_FIFO
		wire [READ_FIFO_DQ_GROUP_OUTPUT_WIDTH-1:0] read_fifo_output_per_dqs_pr;

		assign read_capture_clk_pos[dqs_count] = read_capture_clk[dqs_count];
	
	`ifdef DDRX_LPDDRX
	`else
		`ifdef FULL_RATE
		assign wren = {qvld[dqs_count]};
		`else
		assign wren = {qvld[dqs_count+MEM_READ_DQS_WIDTH], qvld[dqs_count]};
		`endif
	`endif

if (FAST_SIM_MODEL)
begin
`ifdef DDRX_LPDDRX
	`ifdef FULL_RATE
		read_fifo_hard_abstract_ddrx_lpddrx_full_rate uread_read_fifo_hard (
	`else
		read_fifo_hard_abstract_ddrx_lpddrx uread_read_fifo_hard (
	`endif
`else
	`ifdef FULL_RATE
		read_fifo_hard_abstract_full_rate uread_read_fifo_hard (
	`else
		read_fifo_hard_abstract_no_ifdef_params uread_read_fifo_hard (
	`endif
`endif
			.write_clk (~read_capture_clk_pos[dqs_count]),
	`ifdef DDRX_LPDDRX
	`else
			.write_enable(wren),
			.write_enable_clk(valid_predict_clk[dqs_count]),
			.reset_n_write_enable_clk(reset_n_fifo_wraddress[dqs_count]),
	`endif
			.read_clk(read_fifo_read_clk),
			.read_enable(read_enable[dqs_count]),
			.reset_n(reset_n_fifo_wraddress[dqs_count]),
			.datain(ddio_phy_dq_per_dqs),
			.dataout(read_fifo_output_per_dqs_pr)
		);
		defparam uread_read_fifo_hard.DQ_GROUP_WIDTH = DQ_GROUP_WIDTH;
end
else
begin
		read_fifo_hard uread_read_fifo_hard (
			.write_clk (~read_capture_clk_pos[dqs_count]),
	`ifdef DDRX_LPDDRX
	`else
			.write_enable(wren),
			.write_enable_clk(valid_predict_clk[dqs_count]),
			.reset_n_write_enable_clk(reset_n_fifo_wraddress[dqs_count]),
	`endif
			.read_clk(read_fifo_read_clk),
			.read_enable(read_enable[dqs_count]),
			.reset_n(reset_n_fifo_wraddress[dqs_count]),
			.datain(ddio_phy_dq_per_dqs),
			.dataout(read_fifo_output_per_dqs_pr)
		);
		defparam uread_read_fifo_hard.DQ_GROUP_WIDTH = DQ_GROUP_WIDTH;
end

	if (REGISTER_P2C == "true") begin
		reg [READ_FIFO_DQ_GROUP_OUTPUT_WIDTH-1:0] read_fifo_output_per_dqs_r;
		always @(posedge read_fifo_read_clk) begin
			read_fifo_output_per_dqs_r <= read_fifo_output_per_dqs_pr;
		end
		assign read_fifo_output_per_dqs = read_fifo_output_per_dqs_r;
	end else begin
		assign read_fifo_output_per_dqs = read_fifo_output_per_dqs_pr;
	end
`else
		wire	[READ_FIFO_DQ_GROUP_OUTPUT_WIDTH-1:0] read_fifo_output_per_dqs_tmp;

	`ifdef READ_FIFO_HALF_RATE
		always @(posedge read_capture_clk[dqs_count] or negedge reset_n_fifo_write_side[dqs_count])
		begin
			if (~reset_n_fifo_write_side[dqs_count])
				read_capture_clk_div2[dqs_count] <= 1'b0;
			else
				read_capture_clk_div2[dqs_count] <= ~read_capture_clk_div2[dqs_count];
		end

		`ifndef SIMGEN
		assign #10 read_capture_clk_pos[dqs_count] = read_capture_clk_div2[dqs_count];
		`else
		sim_delay #(
				.delay(10)
			)
			sim_delay_inst(
				.o(read_capture_clk_pos[dqs_count]),
				.i(read_capture_clk_div2[dqs_count])
			);
		`endif
		assign read_capture_clk_neg[dqs_count] = ~read_capture_clk_pos[dqs_count];
	`else
		`ifndef SIMGEN
		assign #10 read_capture_clk_pos[dqs_count] = read_capture_clk[dqs_count];
		`else
		sim_delay #(
				.delay(10)
			)
			sim_delay_inst(
				.o(read_capture_clk_pos[dqs_count]),
				.i(read_capture_clk[dqs_count])
			);
		`endif
	`endif

		for (subgroup=0; subgroup<USE_NUM_SUBGROUP_PER_READ_DQS; subgroup=subgroup+1)
		begin: read_subgroup

	`ifdef DDRX_LPDDRX
 			assign wren[subgroup] = 1'b1;
		`ifdef READ_FIFO_HALF_RATE
 			assign wren_neg[subgroup] = 1'b1;
		`endif
	`else
 			always @(posedge read_capture_clk_pos[dqs_count] or negedge reset_n_fifo_wraddress[dqs_count])
  			begin
  				if (~reset_n_fifo_wraddress[dqs_count])
  			   		wren[subgroup] <= 1'b0;
  				else
  					wren[subgroup] <= qvld[dqs_count];
  			end

		`ifdef READ_FIFO_HALF_RATE
 			always @(posedge read_capture_clk_neg[dqs_count] or negedge reset_n_fifo_wraddress[dqs_count])
  			begin
  				if (~reset_n_fifo_wraddress[dqs_count])
  			   		wren_neg[subgroup] <= 1'b0;
  				else
  					wren_neg[subgroup] <= qvld[dqs_count+MEM_READ_DQS_WIDTH];
  			end
		`endif
	`endif

			reg	[READ_FIFO_WRITE_ADDR_WIDTH-1:0] wraddress /* synthesis dont_merge */;
	`ifdef READ_FIFO_HALF_RATE
			reg	[READ_FIFO_WRITE_ADDR_WIDTH-1:0] wraddress_neg /* synthesis dont_merge */;
	`endif

			// The clock is read_capture_clk while reset_n_fifo_wraddress is a signal synchronous to
			// the AFI clk domain but asynchronous to read_capture_clk. reset_n_fifo_wraddress goes
			// '0' when either the system is reset, or when the sequencer asserts seq_read_fifo_reset.
			// By design we ensure that wren has been '0' for at least one cycle when reset_n_fifo_wraddress
			// is deasserted (i.e. '0' -> '1'). When wren is '0', the input and output of the
			// wraddress registers are both '0', so there's no risk of metastability due to reset
			// recovery.
			always @(posedge read_capture_clk_pos[dqs_count] or negedge reset_n_fifo_wraddress[dqs_count])
			begin
				if (~reset_n_fifo_wraddress[dqs_count])
					wraddress <= {READ_FIFO_WRITE_ADDR_WIDTH{1'b0}};
				else if (wren[subgroup])
				begin
					if (READ_FIFO_WRITE_MEM_DEPTH == 2 ** READ_FIFO_WRITE_ADDR_WIDTH)
						wraddress <= wraddress + 1'b1;
					else
						wraddress <= (wraddress == READ_FIFO_WRITE_MEM_DEPTH - 1) ? {READ_FIFO_WRITE_ADDR_WIDTH{1'b0}} : wraddress + 1'b1;
				end
			end

	`ifdef READ_FIFO_HALF_RATE
			always @(posedge read_capture_clk_neg[dqs_count] or negedge reset_n_fifo_wraddress[dqs_count])
			begin
				if (~reset_n_fifo_wraddress[dqs_count])
					wraddress_neg <= {READ_FIFO_WRITE_ADDR_WIDTH{1'b0}};
				else if (wren_neg[subgroup])
				begin
					if (READ_FIFO_WRITE_MEM_DEPTH == 2 ** READ_FIFO_WRITE_ADDR_WIDTH)
						wraddress_neg <= wraddress_neg + 1'b1;
					else
						wraddress_neg <= (wraddress_neg == READ_FIFO_WRITE_MEM_DEPTH - 1) ? {READ_FIFO_WRITE_ADDR_WIDTH{1'b0}} : wraddress_neg + 1'b1;
				end
			end
	`endif

			reg	[READ_FIFO_READ_ADDR_WIDTH-1:0] rdaddress /* synthesis dont_merge */;

			always @(posedge read_fifo_read_clk)
			begin
				if (seq_read_fifo_reset[dqs_count])
					rdaddress <= {READ_FIFO_READ_ADDR_WIDTH{1'b0}};
				else if (read_enable[dqs_count])
				begin
					if (READ_FIFO_READ_MEM_DEPTH == 2 ** READ_FIFO_READ_ADDR_WIDTH)
						rdaddress <= rdaddress + 1'b1;
					else
						rdaddress <= (rdaddress == READ_FIFO_READ_MEM_DEPTH - 1) ? {READ_FIFO_READ_ADDR_WIDTH{1'b0}} : rdaddress + 1'b1;
				end
			end

			flop_mem	uread_fifo(
				.wr_reset_n (1'b1),
				.wr_clk     (read_capture_clk_pos[dqs_count]),
				.wr_en		(wren[subgroup]),
				.wr_addr	(wraddress),
				.wr_data	(ddio_phy_dq_per_dqs[(DDIO_DQ_GROUP_DATA_WIDTH_SUBGROUP*(subgroup+1)-1) : 
							 (DDIO_DQ_GROUP_DATA_WIDTH_SUBGROUP*subgroup)]),
				.rd_reset_n (1'b1),
				.rd_clk		(read_fifo_read_clk),
				.rd_en		(read_enable[dqs_count]),
				.rd_addr	(rdaddress),
	`ifdef FULL_RATE
				.rd_data	(read_fifo_output_per_dqs_tmp[(DDIO_DQ_GROUP_DATA_WIDTH_SUBGROUP*(subgroup+1)-1) : 
							 (DDIO_DQ_GROUP_DATA_WIDTH_SUBGROUP*subgroup)])
	`else
		`ifdef READ_FIFO_HALF_RATE
				.rd_data	(read_fifo_output_per_dqs_tmp[(DDIO_DQ_GROUP_DATA_WIDTH_SUBGROUP*(subgroup+1)-1) :
							 (DDIO_DQ_GROUP_DATA_WIDTH_SUBGROUP*subgroup)])		
		`else
				.rd_data	({read_fifo_output_per_dqs_tmp[(DDIO_DQ_GROUP_DATA_WIDTH_SUBGROUP*(subgroup+1)-1+DDIO_DQ_GROUP_DATA_WIDTH) : 
							 (DDIO_DQ_GROUP_DATA_WIDTH_SUBGROUP*subgroup+DDIO_DQ_GROUP_DATA_WIDTH)]
							 ,read_fifo_output_per_dqs_tmp[(DDIO_DQ_GROUP_DATA_WIDTH_SUBGROUP*(subgroup+1)-1) : 
							 (DDIO_DQ_GROUP_DATA_WIDTH_SUBGROUP*subgroup)]})
		`endif
	`endif
			);
			defparam uread_fifo.WRITE_MEM_DEPTH = READ_FIFO_WRITE_MEM_DEPTH;
			defparam uread_fifo.WRITE_ADDR_WIDTH = READ_FIFO_WRITE_ADDR_WIDTH;
			defparam uread_fifo.WRITE_DATA_WIDTH = DDIO_DQ_GROUP_DATA_WIDTH_SUBGROUP;
			defparam uread_fifo.READ_MEM_DEPTH = READ_FIFO_READ_MEM_DEPTH;
			defparam uread_fifo.READ_ADDR_WIDTH = READ_FIFO_READ_ADDR_WIDTH;
	`ifdef READ_FIFO_HALF_RATE
			defparam uread_fifo.READ_DATA_WIDTH = READ_FIFO_DQ_GROUP_OUTPUT_WIDTH / (USE_NUM_SUBGROUP_PER_READ_DQS * 2);
	`else
			defparam uread_fifo.READ_DATA_WIDTH = READ_FIFO_DQ_GROUP_OUTPUT_WIDTH / USE_NUM_SUBGROUP_PER_READ_DQS;
	`endif

	`ifdef READ_FIFO_HALF_RATE	
			flop_mem	uread_fifo_neg(
				.wr_reset_n (1'b1),
				.wr_clk		(read_capture_clk_neg[dqs_count]),
				.wr_en		(wren_neg[subgroup]),
				.wr_addr	(wraddress_neg),
				.wr_data	(ddio_phy_dq_per_dqs[(DDIO_DQ_GROUP_DATA_WIDTH_SUBGROUP*(subgroup+1)-1) : 
							 (DDIO_DQ_GROUP_DATA_WIDTH_SUBGROUP*subgroup)]),
				.rd_reset_n (1'b1),
				.rd_clk		(read_fifo_read_clk),
				.rd_en		(read_enable[dqs_count]),
				.rd_addr	(rdaddress),
				.rd_data	(read_fifo_output_per_dqs_tmp[(DDIO_DQ_GROUP_DATA_WIDTH_SUBGROUP*(subgroup+1)-1+DDIO_DQ_GROUP_DATA_WIDTH) :
							 (DDIO_DQ_GROUP_DATA_WIDTH_SUBGROUP*subgroup+DDIO_DQ_GROUP_DATA_WIDTH)])
			);
			defparam uread_fifo_neg.WRITE_MEM_DEPTH = READ_FIFO_WRITE_MEM_DEPTH;
			defparam uread_fifo_neg.WRITE_ADDR_WIDTH = READ_FIFO_WRITE_ADDR_WIDTH;
			defparam uread_fifo_neg.WRITE_DATA_WIDTH = DDIO_DQ_GROUP_DATA_WIDTH_SUBGROUP;
			defparam uread_fifo_neg.READ_MEM_DEPTH = READ_FIFO_READ_MEM_DEPTH;
			defparam uread_fifo_neg.READ_ADDR_WIDTH = READ_FIFO_READ_ADDR_WIDTH;
			defparam uread_fifo_neg.READ_DATA_WIDTH = READ_FIFO_DQ_GROUP_OUTPUT_WIDTH / (USE_NUM_SUBGROUP_PER_READ_DQS * 2);
	`endif
		end

	`ifdef DDRX_LPDDRX
		assign read_fifo_output_per_dqs = read_fifo_output_per_dqs_tmp;
	`else
		`ifdef READ_FIFO_HALF_RATE
		// Correct ordering of read_fifo_output_per_dqs_tmp.
		//
		// We want the read_fifo_output_per_dqs bus to be ordered by time slot:
		//
		// D0_T3, D0_T2, D0_T1, D0_T0  (half rate)
		//
		// The protocol has a free-running read_capture_clk. We don't know whether
		// the first rising-edge of the read_capture_clk corresponds to the first rising
		// edge of the pos or neg version of the half rate read capture clk 
		// until after calibration. To resolve this, the half-rate VFIFO is constructed
		// such that when qvld_num_fr_cycle_shift is '1', the 1st bit of wren comes out from
		// the wren_neg register, which means that the first data item (i.e. T0 and T1)
		// is captured by the "neg" read fifo. In such case read_fifo_output_per_dqs_tmp is
		// actually ordered as follows, which requires correction:
		//
		// D0_T1, D0_T0, D0_T3, D0_T2  (half rate)
		// 
		// When qvld_num_fr_cycle_shift is '0', the 1st bit of wren comes out from
		// the wren_pos register. No correction is required in such case.
		assign read_fifo_output_per_dqs = qvld_num_fr_cycle_shift[dqs_count][0] ? 
			{
				read_fifo_output_per_dqs_tmp[READ_FIFO_DQ_GROUP_OUTPUT_WIDTH/2-1 : 0], 
				read_fifo_output_per_dqs_tmp[READ_FIFO_DQ_GROUP_OUTPUT_WIDTH-1 : READ_FIFO_DQ_GROUP_OUTPUT_WIDTH/2]
			} :
			read_fifo_output_per_dqs_tmp;
		`else
		assign read_fifo_output_per_dqs = read_fifo_output_per_dqs_tmp;
		`endif
	`endif
`endif

		// Perform mapping from read_fifo_output_per_dqs to read_fifo_output
		//
		// The read_fifo_output_per_dqs bus is the read data coming out of the read FIFO.
		// It has the read data for the current dqs group. In FR, it has 2x the
		// width of a dqs group on the interface. In HR, it has 4x the width of
		// a dqs group on the interface. The bus is ordered by time slot:
		//
		// FR: D0_T1, D0_T0
		// HR: D0_T3, D0_T2, D0_T1, D0_T0
		//
		// The read_fifo_output bus is the read data from read fifo. In FR, it has
		// the same width as ddio_phy_dq (i.e. 2x interface width). In HR, it has
		// 4x the interface width. The bus is ordered by time slot and
		// sub-ordered by DQS group:
		//
		// FR: D1_T1, D0_T1, D1_T0, D0_T0
		// HR: D1_T3, D0_T3, D1_T2, D0_T2, D1_T1, D0_T1, D1_T0, D0_T0
		//
`ifdef FULL_RATE		
		for (timeslot=0; timeslot<2; timeslot=timeslot+1)
`else
		for (timeslot=0; timeslot<4; timeslot=timeslot+1)
`endif
		begin: read_mapping_timeslot
			wire [DQ_GROUP_WIDTH-1:0] rdata = read_fifo_output_per_dqs[DQ_GROUP_WIDTH * (timeslot + 1) - 1 : DQ_GROUP_WIDTH * timeslot];
			assign read_fifo_output[DQ_GROUP_WIDTH * (dqs_count + 1) + MEM_DQ_WIDTH * timeslot - 1 : DQ_GROUP_WIDTH * dqs_count + MEM_DQ_WIDTH * timeslot] = rdata;
		end
	end
	end else begin
	// Read FIFOS are instantiated in ALTDQDQS. Just pass through to afi_rdata.
		genvar dqs_count, timeslot, vsel_count;
		for (dqs_count=0; dqs_count<MEM_READ_DQS_WIDTH; dqs_count=dqs_count+1)
		begin: read_mapping_dqsgroup
			wire [DDIO_DQ_GROUP_DATA_WIDTH-1:0] ddio_phy_dq_per_dqs;
			assign ddio_phy_dq_per_dqs = ddio_phy_dq[(DDIO_DQ_GROUP_DATA_WIDTH*(dqs_count+1)-1) : (DDIO_DQ_GROUP_DATA_WIDTH*dqs_count)];
`ifdef FULL_RATE		
			for (timeslot=0; timeslot<2; timeslot=timeslot+1)
`else
			for (timeslot=0; timeslot<4; timeslot=timeslot+1)
`endif
			begin: read_mapping_timeslot
				wire [DQ_GROUP_WIDTH-1:0] rdata = ddio_phy_dq_per_dqs[DQ_GROUP_WIDTH * (timeslot + 1) - 1 : DQ_GROUP_WIDTH * timeslot];
				assign read_fifo_output[MEM_DQ_WIDTH * timeslot + DQ_GROUP_WIDTH * (dqs_count + 1) - 1 : MEM_DQ_WIDTH * timeslot + DQ_GROUP_WIDTH * dqs_count] = rdata;
			end
		end
		
		for (vsel_count=0; vsel_count < RD_VALID_LFIFO_WIDTH; ++vsel_count)
		begin: vsel_gen
			for (dqs_count=0; dqs_count<MEM_READ_DQS_WIDTH; dqs_count=dqs_count+1)
				begin: read_buffering
					read_valid_selector uread_valid_selector(
						.reset_n		(reset_n_afi_clk),
						.pll_afi_clk		(pll_afi_clk),
						.latency_shifter	(latency_shifter[vsel_count]),
						.latency_counter	(seq_read_latency_counter),
						.read_enable		(),
						.read_valid		(read_valid[vsel_count][dqs_count])
					);
					defparam uread_valid_selector.MAX_LATENCY_COUNT_WIDTH = MAX_LATENCY_COUNT_WIDTH;
			end
		end
	end
endgenerate

`ifdef QUARTER_RATE
// Perform HR-SDR to QR-SDR conversion using soft logic. The QR-SDR data is
// synchronous to the AFI clock and is sent directly to the afi_rdata bus.
// No need to reset the flops since data validity is communicated via the
// signal.

reg [(AFI_DATA_WIDTH/2)-1:0] read_fifo_output_h_r;
reg [(AFI_DATA_WIDTH/2)-1:0] read_fifo_output_l_r;
reg [(AFI_DATA_WIDTH/2)-1:0] read_fifo_output_l_rr;

always @(posedge pll_afi_clk) 
begin
	read_fifo_output_h_r <= read_fifo_output;
	read_fifo_output_l_rr <= read_fifo_output_l_r;
end

always @(negedge pll_afi_clk)
begin
	read_fifo_output_l_r <= read_fifo_output;
end

assign afi_rdata = {read_fifo_output_h_r, read_fifo_output_l_rr};


`else
// Data from read-fifo is synchronous to the AFI clock and so can be sent
// directly to the afi_rdata bus. 
assign afi_rdata = read_fifo_output;
`endif

// Perform data re-mapping from afi_rdata to phy_mux_read_fifo_q
//
// The afi_rdata bus is the read data going out to the AFI. In FR, it has
// the same width as ddio_phy_dq (i.e. 2x interface width). In HR, it has
// 4x the interface width. The bus is ordered by time slot and
// sub-ordered by DQS group:
//
// FR: D1_T1, D0_T1, D1_T0, D0_T0
// HR: D1_T3, D0_T3, D1_T2, D0_T2, D1_T1, D0_T1, D1_T0, D0_T0
//
// The phy_mux_read_fifo_q bus is the read data going into the sequencer
// for calibration. It has the same width as afi_rdata. The bus is ordered
// by DQS group, and sub-ordered by time slot:
//
// FR: D1_T1, D1_T0, D0_T1, D0_T0
// HR: D1_T3, D1_T2, D1_T1, D1_T0, D0_T3, D0_T2, D0_T1, D0_T0
//
//As of Nov 1 2010, the NIOS sequencer doesn't use the phy_mux_read_fifo_q signal.
generate 
genvar k, t;
	for (k=0; k<MEM_READ_DQS_WIDTH; k=k+1)
	begin: read_mapping_for_seq
		wire [AFI_DQ_GROUP_DATA_WIDTH-1:0] rdata_per_dqs_group;

		for (t=0; t<AFI_RATE_RATIO*2; t=t+1)
		begin: build_rdata_per_dqs_group
			wire [DQ_GROUP_WIDTH-1:0] rdata_t = afi_rdata[DQ_GROUP_WIDTH * (k+1) + MEM_DQ_WIDTH * t - 1 : DQ_GROUP_WIDTH * k + MEM_DQ_WIDTH * t];
			assign rdata_per_dqs_group[(t+1)*DQ_GROUP_WIDTH-1:t*DQ_GROUP_WIDTH] = rdata_t;
		end
		assign phy_mux_read_fifo_q[(k+1)*AFI_DQ_GROUP_DATA_WIDTH-1 : k*AFI_DQ_GROUP_DATA_WIDTH] = rdata_per_dqs_group;
	end
endgenerate

// Generate an AFI read valid signal from all the read valid signals from all FIFOs

`ifdef PINGPONGPHY_EN
generate
	genvar afi_phase_i;
	for (afi_phase_i = 0; afi_phase_i < AFI_RATE_RATIO; ++afi_phase_i)
	begin : afi_rdata_valid_gen
		wire read_valid_lhs_groups = &(read_valid[afi_phase_i][MEM_READ_DQS_WIDTH/2-1 : 0]);
		wire read_valid_rhs_groups = &(read_valid[afi_phase_i][MEM_READ_DQS_WIDTH-1 : MEM_READ_DQS_WIDTH/2]);
		wire read_valid_all_groups = &(read_valid[afi_phase_i]);
		if (REGISTER_P2C == "true") begin
			reg rdata_valid_lhs_r, rdata_valid_rhs_r, rdata_valid_r;
			always @(posedge pll_afi_clk or negedge reset_n_afi_clk)
			begin
				if (~reset_n_afi_clk) begin
					rdata_valid_lhs_r<= 0;
					rdata_valid_rhs_r<= 0;
					rdata_valid_r<= 0;
					afi_rdata_valid[afi_phase_i] <= 1'b0;
					afi_rdata_valid_1t[afi_phase_i] <= 1'b0;
				end else begin
					rdata_valid_lhs_r<= read_valid_lhs_groups;
					rdata_valid_rhs_r<=read_valid_rhs_groups;
					rdata_valid_r<=read_valid_all_groups ;
					afi_rdata_valid[afi_phase_i] <= mux_sel ?rdata_valid_r : rdata_valid_lhs_r;
					afi_rdata_valid_1t[afi_phase_i] <= mux_sel ? 1'b0 : rdata_valid_rhs_r;
				end
			end
		end else begin
			always @(posedge pll_afi_clk or negedge reset_n_afi_clk)
			begin
				if (~reset_n_afi_clk) begin
					afi_rdata_valid[afi_phase_i] <= 1'b0;
					afi_rdata_valid_1t[afi_phase_i] <= 1'b0;
				end else begin
					afi_rdata_valid[afi_phase_i] <= mux_sel ? read_valid_all_groups : read_valid_lhs_groups;
					afi_rdata_valid_1t[afi_phase_i] <= mux_sel ? 1'b0 : read_valid_rhs_groups;
				end
			end
		end
	end
endgenerate

`else
generate
	genvar afi_phase_i;
	for (afi_phase_i = 0; afi_phase_i < AFI_RATE_RATIO; ++afi_phase_i)
	begin : afi_rdata_valid_gen
		wire read_valid_all_groups = &(read_valid[afi_phase_i]);
		
		if (REGISTER_P2C == "true") begin
			reg rdata_valid_r;
			always @(posedge pll_afi_clk or negedge reset_n_afi_clk)
			begin
				if (~reset_n_afi_clk) begin
					rdata_valid_r <= 1'b0;
					afi_rdata_valid[afi_phase_i] <= 1'b0;
				end else begin
					rdata_valid_r <= read_valid_all_groups;
					afi_rdata_valid[afi_phase_i] <= rdata_valid_r;
				end
			end
		end else begin
			always @(posedge pll_afi_clk or negedge reset_n_afi_clk)
			begin
				if (~reset_n_afi_clk) begin
					afi_rdata_valid[afi_phase_i] <= 1'b0;
				end else begin
					afi_rdata_valid[afi_phase_i] <= read_valid_all_groups;
				end
			end
		end
	end
endgenerate
`endif 

`ifdef DDRX_LPDDRX
reg		[AFI_DQS_WIDTH-1:0] force_oct_off;

	`ifdef PINGPONGPHY_EN
localparam MEM_IF_DQS_WIDTH_PER_SIDE = AFI_DQS_WIDTH/2/AFI_RATE_RATIO;
generate
genvar beat;
for (beat = 0; beat < AFI_RATE_RATIO; beat=beat+1)
begin : oct_gen_lhs
	reg		[OCT_OFF_DELAY-1:0] rdata_en_r_lhs /* synthesis dont_merge */;
	reg		[OCT_OFF_DELAY-1:0] rdata_en_r_rhs /* synthesis dont_merge */;
	wire [OCT_OFF_DELAY:0] rdata_en_shifter_lhs;
	wire [OCT_OFF_DELAY:0] rdata_en_shifter_rhs;

	assign rdata_en_shifter_lhs = {rdata_en_r_lhs,|afi_rdata_en_full_lfifo_int};
	always @(posedge pll_afi_clk or negedge reset_n_afi_clk)
	begin
		if (~reset_n_afi_clk)
		begin
			rdata_en_r_lhs <= {OCT_OFF_DELAY{1'b0}};
			force_oct_off[ (2 * MEM_IF_DQS_WIDTH_PER_SIDE * beat) +: MEM_IF_DQS_WIDTH_PER_SIDE ] <= 0;
		end
		else
		begin
			rdata_en_r_lhs <= {rdata_en_r_lhs[OCT_OFF_DELAY-2:0],|afi_rdata_en_full_lfifo_int};
			force_oct_off[ (2 * MEM_IF_DQS_WIDTH_PER_SIDE * beat) +: MEM_IF_DQS_WIDTH_PER_SIDE ]
					   <= {MEM_IF_DQS_WIDTH_PER_SIDE{ ~(|rdata_en_shifter_lhs[OCT_OFF_DELAY:OCT_ON_DELAY]) }};
		end
	end

	assign rdata_en_shifter_rhs = {rdata_en_r_rhs,|afi_rdata_en_full_lfifo_int_1t};
	always @(posedge pll_afi_clk or negedge reset_n_afi_clk)
	begin
		if (~reset_n_afi_clk)
		begin
			rdata_en_r_rhs <= {OCT_OFF_DELAY{1'b0}};
			force_oct_off[ (2 * MEM_IF_DQS_WIDTH_PER_SIDE * beat) + MEM_IF_DQS_WIDTH_PER_SIDE +: MEM_IF_DQS_WIDTH_PER_SIDE ] <= 0;
		end
		else
		begin
			rdata_en_r_rhs <= {rdata_en_r_rhs[OCT_OFF_DELAY-2:0],|afi_rdata_en_full_lfifo_int_1t};
			force_oct_off[ (2 * MEM_IF_DQS_WIDTH_PER_SIDE * beat) + MEM_IF_DQS_WIDTH_PER_SIDE +: MEM_IF_DQS_WIDTH_PER_SIDE ]
					   <= {MEM_IF_DQS_WIDTH_PER_SIDE{ ~(|rdata_en_shifter_rhs[OCT_OFF_DELAY:OCT_ON_DELAY]) }};
		end
	end
end
endgenerate

	`else 
generate
genvar oct_num;
for (oct_num = 0; oct_num < AFI_DQS_WIDTH; oct_num = oct_num + 1)
begin : oct_gen
	reg		[OCT_OFF_DELAY-1:0] rdata_en_r /* synthesis dont_merge */;
	wire [OCT_OFF_DELAY:0] rdata_en_shifter;

	assign rdata_en_shifter = {rdata_en_r,|afi_rdata_en_full_lfifo_int};
	always @(posedge pll_afi_clk or negedge reset_n_afi_clk)
	begin
		if (~reset_n_afi_clk)
		begin
			rdata_en_r <= {OCT_OFF_DELAY{1'b0}};
			force_oct_off[oct_num] <= 1'b0;
		end
		else
		begin
			rdata_en_r <= {rdata_en_r[OCT_OFF_DELAY-2:0],|afi_rdata_en_full_lfifo_int};
			force_oct_off[oct_num] <= ~(|rdata_en_shifter[OCT_OFF_DELAY:OCT_ON_DELAY]);
		end
	end
end
endgenerate
	`endif 
`endif


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
