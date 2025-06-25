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



///////////////////////////////////////////////////////////////////////////////
// Data/Strobe Group Tile of 20nm Phylite component.
//
///////////////////////////////////////////////////////////////////////////////
module phylite_group_tile_20 #(
	parameter string  CORE_RATE                     = "RATE_IN_QUARTER",
	parameter integer PLL_VCO_TO_MEM_CLK_FREQ_RATIO = 1                ,
	parameter integer PLL_VCO_FREQ_MHZ_INT          = 1067             ,
	parameter string  PIN_TYPE                      = "BIDIR"          ,
	parameter integer PIN_WIDTH                     = 9                ,
	parameter string  DDR_SDR_MODE                  = "DDR"            ,
	parameter integer USE_DIFF_STROBE               = 0                ,
	parameter [5:0]   READ_LATENCY                  = 4                ,
	parameter integer USE_INTERNAL_CAPTURE_STROBE   = 0                ,
	parameter integer CAPTURE_PHASE_SHIFT           = 90               ,
	parameter integer WRITE_LATENCY                 = 0                ,
	parameter integer USE_OUTPUT_STROBE             = 1                ,
	parameter integer OUTPUT_STROBE_PHASE           = 90
	) (
	// Clocks and Reset
	input       phy_clk    ,
	input [7:0] phy_clk_phs,
	input       pll_locked ,
	input       dll_ref_clk,
	input       reset_n    ,

	// Avalon Interface
	output [54:0] cal_avl_out         ,
	input  [31:0] cal_avl_readdata_in ,
	input  [54:0] cal_avl_in          ,
	output [31:0] cal_avl_readdata_out,

	// Core Interface
	input  [191:0] oe_from_core  ,
	input  [383:0] data_from_core,
	output [383:0] data_to_core  ,
	input    [3:0] rdata_en      ,
	output   [3:0] rdata_valid   ,

	// I/Os
	output [47:0] data_oe   ,
	output [47:0] data_out  ,
	input  [47:0] data_in   ,
	output [47:0] oct_enable,

	// Inter-Tile Daisy Chains
	input  broadcast_in_top ,
	output broadcast_out_top,
	input  broadcast_in_bot ,
	output broadcast_out_bot,

	input  [1:0] sync_top_in ,
	output [1:0] sync_top_out,
	input  [1:0] sync_bot_in ,
	output [1:0] sync_bot_out
	);

	////////////////////////////////////////////////////////////////////////////
	// Local Parameters
	////////////////////////////////////////////////////////////////////////////
	////Top Level Lane Params
	localparam MODE_DDR = (DDR_SDR_MODE == "DDR") ? "mode_ddr" : "mode_sdr";
	localparam IN_RATE  = (CORE_RATE == "RATE_IN_QUARTER") ? "in_rate_1_4" :
	                      (CORE_RATE == "RATE_IN_HALF")    ? "in_rate_1_2" :
	                                                         "in_rate_full";
	localparam OUT_RATE = (PLL_VCO_TO_MEM_CLK_FREQ_RATIO == 4) ? "out_rate_1_4" :
	                      (PLL_VCO_TO_MEM_CLK_FREQ_RATIO == 2) ? "out_rate_1_2" :
	                                                             "out_rate_full";
	////Lane write delay params
	localparam MIN_OFFSET = (OUT_RATE == "out_rate_full") ? ((IN_RATE == "in_rate_1_4")  ? 12'h180 :
	                                                         (IN_RATE == "in_rate_1_2")  ? 12'h280 :
	                                                                                       12'h080 ):
	                        (OUT_RATE == "out_rate_1_2")  ? ((IN_RATE == "in_rate_1_4")  ? 12'h3C0 :
	                                                         (IN_RATE == "in_rate_1_2")  ? 12'h180 :
	                                                                                       12'h200 ):
	                                                        ((IN_RATE == "in_rate_1_4")  ? 12'h100 :
	                                                         (IN_RATE == "in_rate_1_2")  ? 12'h000 :
	                                                                                       12'h080 );
	localparam [11:0] EXT_MEM_CLK_CYCLE_PHASE = (OUT_RATE == "out_rate_full") ? 12'h080 :
	                                            (OUT_RATE == "out_rate_1_2")  ? 12'h100 :
	                                                                            12'h200 ;
	localparam [11:0] OUTPUT_LATENCY_OFFSET = WRITE_LATENCY * EXT_MEM_CLK_CYCLE_PHASE;
	localparam [11:0] DATA_PHASE_OFFSET     = MIN_OFFSET + OUTPUT_LATENCY_OFFSET + 12'h020;
	localparam [11:0] STROBE_PHASE_OFFSET   = DATA_PHASE_OFFSET + (OUTPUT_STROBE_PHASE * (EXT_MEM_CLK_CYCLE_PHASE / 360.0));

	////Lane read/read valid delay params
	localparam DQS_ENABLE_PHASE_SHIFT = MIN_OFFSET + 12'h040; //assuming addr/cmd group always uses minimum output latency
	localparam [9:0] DQS_DELAY = CAPTURE_PHASE_SHIFT * (512.0 / 360.0);

	////Lane pin usage params
	localparam NUM_STROBES = (((PIN_TYPE == "OUTPUT") && (USE_OUTPUT_STROBE == 0)) || ((PIN_TYPE == "INPUT") && (USE_INTERNAL_CAPTURE_STROBE == 1))) ? 0 :
	                         (USE_DIFF_STROBE == 1) ? 2 : 1;
	localparam TOTAL_PIN_WIDTH = PIN_WIDTH + NUM_STROBES;

	////////////////////////////////////////////////////////////////////////////
	// Wire Declarations
	////////////////////////////////////////////////////////////////////////////
	// PHY Clocks
	wire [1:0] phy_clk_lane[0:3];
	wire [7:0] phy_clk_phs_lane[0:3];
	wire       dll_clk_out[0:3];

	// Avalon Bus
	wire [54:0] cal_avl      [0:5];
	wire [31:0] cal_avl_rdata[0:5];

	// DQS input
	wire [1:0] dqs_in_x8_0     ;
	wire [1:0] dqs_in_x18_0    ;
	wire [1:0] dqs_in_x36      ;
	wire [1:0] dqs_out_x8 [0:3];
	wire [1:0] dqs_out_x18[0:3];
	wire [1:0] dqs_out_x36[0:3];
	wire       dqs             ;

	// DQS Broadcast Daisy-Chain
	wire broadcast_dn[0:4];
	wire broadcast_up[0:4];

	// CPA Sync Daisy-Chain
	wire [1:0] sync_dn[0:5];
	wire [1:0] sync_up[0:5];

	// Read Data Valid from Lanes
	wire [3:0] rdata_valid_lane [0:3];

	////////////////////////////////////////////////////////////////////////////
	// Assignments and Tie-offs
	////////////////////////////////////////////////////////////////////////////
	// Avalon Bus
	assign cal_avl[0] = cal_avl_in;
	assign cal_avl_readdata_out = cal_avl_rdata[0];
	assign cal_avl_out = cal_avl[5];
	assign cal_avl_rdata[5] = cal_avl_readdata_in;

	// DQS input
	assign dqs = (USE_INTERNAL_CAPTURE_STROBE == 1) ? 1'b0 : data_in[0];
	assign dqs_in_x8_0  = (TOTAL_PIN_WIDTH <= 12)                               ? {1'b0,dqs} : 2'b00;
	assign dqs_in_x18_0 = ((TOTAL_PIN_WIDTH > 12) && ((TOTAL_PIN_WIDTH <= 24))) ? {1'b0,dqs} : 2'b00;
	assign dqs_in_x36   = (TOTAL_PIN_WIDTH > 24)                                ? {1'b0,dqs} : 2'b00;

	// DQS Broadcast Daisy-Chain
	assign broadcast_up[0]   = broadcast_in_bot;
	assign broadcast_out_top = broadcast_up[4];
	assign broadcast_dn[4]   = broadcast_in_top;
	assign broadcast_out_bot = broadcast_dn[0];

	// CPA Sync Daisy-Chain
	assign sync_up[0]   = sync_bot_in;
	assign sync_top_out = sync_up[5];
	assign sync_dn[5]   = sync_top_in;
	assign sync_bot_out = sync_dn[0];

	// All rdata valid outputs are aligned, so just use the first lane's
	assign rdata_valid = rdata_valid_lane[0];

	////////////////////////////////////////////////////////////////////////////
	// Tile Control Atom instantiation
	////////////////////////////////////////////////////////////////////////////
	twentynm_tile_ctrl #(
		.pa_exponent_0    (3'b0             ),
		.pa_exponent_1    (3'b0             ),
		.pa_mantissa_0    (5'b0             ),
		.pa_mantissa_1    (5'b0             ),
		.pa_sync_mode     ("no_sync"        ),
		.pa_sync_latency  (4'd2             ),
		.pa_track_speed   (5'b0             ),
		.pa_feedback_path ("feedback_path_0")
		) u_twentynm_tile_ctrl (
		// Reset
		.global_reset_n    (reset_n),
		
		// PLL Clocks
		.pll_locked_in     (pll_locked                            ),
		.pll_vco_in        (phy_clk_phs                           ),
		.phy_clk_in        ({1'b0,phy_clk}                        ),
		.phy_clk_out0      ({phy_clk_lane[0], phy_clk_phs_lane[0]}),
		.phy_clk_out1      ({phy_clk_lane[1], phy_clk_phs_lane[1]}),
		.phy_clk_out2      ({phy_clk_lane[2], phy_clk_phs_lane[2]}),
		.phy_clk_out3      ({phy_clk_lane[3], phy_clk_phs_lane[3]}),

		// DLL Clocks
		.dll_clk_in        (dll_ref_clk   ),
		.dll_clk_out0      (dll_clk_out[0]),
		.dll_clk_out1      (dll_clk_out[1]),
		.dll_clk_out2      (dll_clk_out[2]),
		.dll_clk_out3      (dll_clk_out[3]),
		
		// Avalon Bus
		.cal_avl_in        (cal_avl      [2]),
		.cal_avl_rdata_out (cal_avl_rdata[3]),
		.cal_avl_out       (cal_avl      [3]),
		.cal_avl_rdata_in  (cal_avl_rdata[2]),
		
		// Clock Phase Alignment Output
		.pa_core_clk_out     (),
		.pa_sync_data_bot_in (sync_up[2][0]),
		.pa_sync_data_top_in (sync_dn[3][0]),
		.pa_sync_clk_bot_in  (sync_up[2][1]),
		.pa_sync_clk_top_in  (sync_dn[3][1]),
		.pa_sync_data_bot_out(sync_dn[2][0]),
		.pa_sync_data_top_out(sync_up[3][0]),
		.pa_sync_clk_bot_out (sync_dn[2][1]),
		.pa_sync_clk_top_out (sync_up[3][1]),

		// DQS Clock Tree
		.dqs_in_x8_0       (dqs_in_x8_0   ),
		.dqs_in_x8_1       (2'b0          ),
		.dqs_in_x8_2       (2'b0          ),
		.dqs_in_x8_3       (2'b0          ),
		.dqs_in_x18_0      (dqs_in_x18_0  ),
		.dqs_in_x18_1      (2'b0          ),
		.dqs_in_x36        (dqs_in_x36    ),
		.dqs_out_x8_lane0  (dqs_out_x8 [0]),
		.dqs_out_x18_lane0 (dqs_out_x18[0]),
		.dqs_out_x36_lane0 (dqs_out_x36[0]),
		.dqs_out_x8_lane1  (dqs_out_x8 [1]),
		.dqs_out_x18_lane1 (dqs_out_x18[1]),
		.dqs_out_x36_lane1 (dqs_out_x36[1]),
		.dqs_out_x8_lane2  (dqs_out_x8 [2]),
		.dqs_out_x18_lane2 (dqs_out_x18[2]),
		.dqs_out_x36_lane2 (dqs_out_x36[2]),
		.dqs_out_x8_lane3  (dqs_out_x8 [3]),
		.dqs_out_x18_lane3 (dqs_out_x18[3]),
		.dqs_out_x36_lane3 (dqs_out_x36[3])
	);

	////////////////////////////////////////////////////////////////////////////
	// Lane instantiation generate loop - create all lanes regardles of usage
	////////////////////////////////////////////////////////////////////////////
	generate 
		genvar lane_num;
		for(lane_num = 0; lane_num < 4; lane_num = lane_num + 1) begin : lane_gen

			// Lane specific local parameters
			localparam PIN_0_IS_STROBE    = ((lane_num == 0) && (NUM_STROBES > 0))  ;
			localparam PIN_1_IS_STROBE    = ((lane_num == 0) && (NUM_STROBES == 2)) ;
			localparam PIN_0_PHASE_OFFSET = PIN_0_IS_STROBE ? STROBE_PHASE_OFFSET  : DATA_PHASE_OFFSET ;
			localparam PIN_1_PHASE_OFFSET = PIN_1_IS_STROBE ? STROBE_PHASE_OFFSET  : DATA_PHASE_OFFSET ;
			localparam PIN_0_DDR_MODE     = PIN_0_IS_STROBE ? "mode_ddr" : MODE_DDR ;
			localparam PIN_1_DDR_MODE     = PIN_1_IS_STROBE ? "mode_ddr" : MODE_DDR ;
			localparam PIN_0_DATA_IN_MODE = (PIN_0_IS_STROBE && PIN_1_IS_STROBE) ? "differential_in" : "sstl_in";
			localparam PIN_1_DATA_IN_MODE = (PIN_0_IS_STROBE && PIN_1_IS_STROBE) ? "differential_in" : "sstl_in";

			// Lane specific wires
			wire [1:0] dqs_in;

			// Lane specific assignments
			assign dqs_in = (TOTAL_PIN_WIDTH <= 12) ?                               dqs_out_x8 [lane_num] :
				        ((TOTAL_PIN_WIDTH > 12) && ((TOTAL_PIN_WIDTH <= 24))) ? dqs_out_x18[lane_num] :
			                                                                        dqs_out_x36[lane_num] ;
			twentynm_io_12_lane #(
				// Top level params
				.phy_clk_phs_freq (PLL_VCO_FREQ_MHZ_INT       ),
				.mode_rate_in     (IN_RATE                    ),
				.mode_rate_out    (OUT_RATE                   ),
				.pipe_latency     (8'd0                       ),
				.dqs_enable_delay (READ_LATENCY               ),
				.rd_valid_delay   ({1'b0,READ_LATENCY} + 7'd6 ),
				.phy_clk_sel      (0                          ),
				
				// PHY params
				.pin_0_initial_out    ("initial_out_z"   ),
				.pin_0_mode_ddr       (PIN_0_DDR_MODE    ),
				.pin_0_non_pvt_delay  (9'd0              ),
				.pin_0_output_phase   (PIN_0_PHASE_OFFSET),
				.pin_0_oct_enable     ("false"           ),
				.pin_0_data_in_mode   (PIN_0_DATA_IN_MODE),
				.pin_1_initial_out    ("initial_out_z"   ),
				.pin_1_mode_ddr       (PIN_1_DDR_MODE    ),
				.pin_1_non_pvt_delay  (9'd0              ),
				.pin_1_output_phase   (PIN_1_PHASE_OFFSET),
				.pin_1_oct_enable     ("false"           ),
				.pin_1_data_in_mode   (PIN_1_DATA_IN_MODE),
				.pin_2_initial_out    ("initial_out_z"   ),
				.pin_2_mode_ddr       (MODE_DDR          ),
				.pin_2_non_pvt_delay  (9'd0              ),
				.pin_2_output_phase   (DATA_PHASE_OFFSET ),
				.pin_2_oct_enable     ("false"           ),
				.pin_2_data_in_mode   ("sstl_in"         ),
				.pin_3_initial_out    ("initial_out_z"   ),
				.pin_3_mode_ddr       (MODE_DDR          ),
				.pin_3_non_pvt_delay  (9'd0              ),
				.pin_3_output_phase   (DATA_PHASE_OFFSET ),
				.pin_3_oct_enable     ("false"           ),
				.pin_3_data_in_mode   ("sstl_in"         ),
				.pin_4_initial_out    ("initial_out_z"   ),
				.pin_4_mode_ddr       (MODE_DDR          ),
				.pin_4_non_pvt_delay  (9'd0              ),
				.pin_4_output_phase   (DATA_PHASE_OFFSET ),
				.pin_4_oct_enable     ("false"           ),
				.pin_4_data_in_mode   ("sstl_in"         ),
				.pin_5_initial_out    ("initial_out_z"   ),
				.pin_5_mode_ddr       (MODE_DDR          ),
				.pin_5_non_pvt_delay  (9'd0              ),
				.pin_5_output_phase   (DATA_PHASE_OFFSET ),
				.pin_5_oct_enable     ("false"           ),
				.pin_5_data_in_mode   ("sstl_in"         ),
				.pin_6_initial_out    ("initial_out_z"   ),
				.pin_6_mode_ddr       (MODE_DDR          ),
				.pin_6_non_pvt_delay  (9'd0              ),
				.pin_6_output_phase   (DATA_PHASE_OFFSET ),
				.pin_6_oct_enable     ("false"           ),
				.pin_6_data_in_mode   ("sstl_in"         ),
				.pin_7_initial_out    ("initial_out_z"   ),
				.pin_7_mode_ddr       (MODE_DDR          ),
				.pin_7_non_pvt_delay  (9'd0              ),
				.pin_7_output_phase   (DATA_PHASE_OFFSET ),
				.pin_7_oct_enable     ("false"           ),
				.pin_7_data_in_mode   ("sstl_in"         ),
				.pin_8_initial_out    ("initial_out_z"   ),
				.pin_8_mode_ddr       (MODE_DDR          ),
				.pin_8_non_pvt_delay  (9'd0              ),
				.pin_8_output_phase   (DATA_PHASE_OFFSET ),
				.pin_8_oct_enable     ("false"           ),
				.pin_8_data_in_mode   ("sstl_in"         ),
				.pin_9_initial_out    ("initial_out_z"   ),
				.pin_9_mode_ddr       (MODE_DDR          ),
				.pin_9_non_pvt_delay  (9'd0              ),
				.pin_9_output_phase   (DATA_PHASE_OFFSET ),
				.pin_9_oct_enable     ("false"           ),
				.pin_9_data_in_mode   ("sstl_in"         ),
				.pin_10_initial_out   ("initial_out_z"   ),
				.pin_10_mode_ddr      (MODE_DDR          ),
				.pin_10_non_pvt_delay (9'd0              ),
				.pin_10_output_phase  (DATA_PHASE_OFFSET ),
				.pin_10_oct_enable     ("false"           ),
				.pin_10_data_in_mode   ("sstl_in"         ),
				.pin_11_initial_out   ("initial_out_z"   ),
				.pin_11_mode_ddr      (MODE_DDR          ),
				.pin_11_non_pvt_delay (9'd0              ),
				.pin_11_output_phase  (DATA_PHASE_OFFSET ),
				.pin_11_oct_enable     ("false"           ),
				.pin_11_data_in_mode   ("sstl_in"         ),
				
				// Avalon params
				.avl_base_addr (9'd0   ),
				.avl_ena       ("false"),
				
				// Data Buffer params
				.db_hmc_or_core         ("core"              ),
				.db_dbi_sel             ("dbi_dq0"           ),
				.db_dbi_en              ("dbi_disable"       ),
				.db_crc_dq0             (0                   ),
				.db_crc_dq1             (0                   ),
				.db_crc_dq2             (0                   ),
				.db_crc_dq3             (0                   ),
				.db_crc_dq4             (0                   ),
				.db_crc_dq5             (0                   ),
				.db_crc_dq6             (0                   ),
				.db_crc_dq7             (0                   ),
				.db_crc_dq8             (0                   ),
				.db_crc_x4_or_x8_or_x9  ("x8_mode"           ),
				.db_crc_en              ("crc_disable"       ),
				.db_rwlat_mode          ("csr_vlu"           ),
				.db_afi_wlat_vlu        (6'd0                ),
				.db_afi_rlat_vlu        (6'd0                ),
				.db_ptr_pipeline_depth  (0                   ),
				.db_preamble_mode       ("preamble_one_cycle"),
				.db_reset_auto_release  ("auto_release"      ),
				.db_data_alignment_mode ("align_disable"     ),
				.db_db2core_registered  ("not_registered"    ),
				.dbc_core_clk_sel       (0                   ),
				
				.db_pin_0_ac_hmc_data_override_ena ("false"  ),
				.db_pin_0_in_bypass                ("true"   ),
				.db_pin_0_mode                     ("dq_mode"),
				.db_pin_0_oe_bypass                ("true"   ),
				.db_pin_0_oe_invert                ("false"  ),
				.db_pin_0_out_bypass               ("true"   ),
				.db_pin_0_wr_invert                ("false"  ),
				.db_pin_1_ac_hmc_data_override_ena ("false"  ),
				.db_pin_1_in_bypass                ("true"   ),
				.db_pin_1_mode                     ("dq_mode"),
				.db_pin_1_oe_bypass                ("true"   ),
				.db_pin_1_oe_invert                ("false"  ),
				.db_pin_1_out_bypass               ("true"   ),
				.db_pin_1_wr_invert                ("false"  ),
				.db_pin_2_ac_hmc_data_override_ena ("false"  ),
				.db_pin_2_in_bypass                ("true"   ),
				.db_pin_2_mode                     ("dq_mode"),
				.db_pin_2_oe_bypass                ("true"   ),
				.db_pin_2_oe_invert                ("false"  ),
				.db_pin_2_out_bypass               ("true"   ),
				.db_pin_2_wr_invert                ("false"  ),
				.db_pin_3_ac_hmc_data_override_ena ("false"  ),
				.db_pin_3_in_bypass                ("true"   ),
				.db_pin_3_mode                     ("dq_mode"),
				.db_pin_3_oe_bypass                ("true"   ),
				.db_pin_3_oe_invert                ("false"  ),
				.db_pin_3_out_bypass               ("true"   ),
				.db_pin_3_wr_invert                ("false"  ),
				.db_pin_4_ac_hmc_data_override_ena ("false"  ),
				.db_pin_4_in_bypass                ("true"   ),
				.db_pin_4_mode                     ("dq_mode"),
				.db_pin_4_oe_bypass                ("true"   ),
				.db_pin_4_oe_invert                ("false"  ),
				.db_pin_4_out_bypass               ("true"   ),
				.db_pin_4_wr_invert                ("false"  ),
				.db_pin_5_ac_hmc_data_override_ena ("false"  ),
				.db_pin_5_in_bypass                ("true"   ),
				.db_pin_5_mode                     ("dq_mode"),
				.db_pin_5_oe_bypass                ("true"   ),
				.db_pin_5_oe_invert                ("false"  ),
				.db_pin_5_out_bypass               ("true"   ),
				.db_pin_5_wr_invert                ("false"  ),
				.db_pin_6_ac_hmc_data_override_ena ("false"  ),
				.db_pin_6_in_bypass                ("true"   ),
				.db_pin_6_mode                     ("dq_mode"),
				.db_pin_6_oe_bypass                ("true"   ),
				.db_pin_6_oe_invert                ("false"  ),
				.db_pin_6_out_bypass               ("true"   ),
				.db_pin_6_wr_invert                ("false"  ),
				.db_pin_7_ac_hmc_data_override_ena ("false"  ),
				.db_pin_7_in_bypass                ("true"   ),
				.db_pin_7_mode                     ("dq_mode"),
				.db_pin_7_oe_bypass                ("true"   ),
				.db_pin_7_oe_invert                ("false"  ),
				.db_pin_7_out_bypass               ("true"   ),
				.db_pin_7_wr_invert                ("false"  ),
				.db_pin_8_ac_hmc_data_override_ena ("false"  ),
				.db_pin_8_in_bypass                ("true"   ),
				.db_pin_8_mode                     ("dq_mode"),
				.db_pin_8_oe_bypass                ("true"   ),
				.db_pin_8_oe_invert                ("false"  ),
				.db_pin_8_out_bypass               ("true"   ),
				.db_pin_8_wr_invert                ("false"  ),
				.db_pin_9_ac_hmc_data_override_ena ("false"  ),
				.db_pin_9_in_bypass                ("true"   ),
				.db_pin_9_mode                     ("dq_mode"),
				.db_pin_9_oe_bypass                ("true"   ),
				.db_pin_9_oe_invert                ("false"  ),
				.db_pin_9_out_bypass               ("true"   ),
				.db_pin_9_wr_invert                ("false"  ),
				.db_pin_10_ac_hmc_data_override_ena("false"  ),
				.db_pin_10_in_bypass               ("true"   ),
				.db_pin_10_mode                    ("dq_mode"),
				.db_pin_10_oe_bypass               ("true"   ),
				.db_pin_10_oe_invert               ("false"  ),
				.db_pin_10_out_bypass              ("true"   ),
				.db_pin_10_wr_invert               ("false"  ),
				.db_pin_11_ac_hmc_data_override_ena("false"  ),
				.db_pin_11_in_bypass               ("true"   ),
				.db_pin_11_mode                    ("dq_mode"),
				.db_pin_11_oe_bypass               ("true"   ),
				.db_pin_11_oe_invert               ("false"  ),
				.db_pin_11_out_bypass              ("true"   ),
				.db_pin_11_wr_invert               ("false"  ),
				
				// DLL params
				.dll_rst_en      ("dll_rst_dis"  ),
				.dll_en          ("dll_en"       ),
				.dll_core_updnen ("core_updn_dis"),
				.dll_ctlsel      ("ctl_dynamic"  ),
				.dll_ctl_static  (10'd0          ),
				
				// DQS params
				.dqs_lgc_non_pvt_dqs_delay (10'd0                      ),
				.dqs_lgc_pvt_input_delay_a (DQS_DELAY                  ),
				.dqs_lgc_pvt_input_delay_b (DQS_DELAY                  ),
				.dqs_lgc_enable_toggler    ("preamble_track_dqs_enable"),
				.dqs_lgc_phase_shift_b     (DQS_ENABLE_PHASE_SHIFT     ),
				.dqs_lgc_phase_shift_a     (DQS_ENABLE_PHASE_SHIFT     ),
				.dqs_lgc_pack_mode         ("packed"                   ),
				.dqs_lgc_pst_preamble_mode ("ddr3_preamble"            ),
				.dqs_lgc_pst_en_shrink     ("shrink_0_1"               ),
				.dqs_lgc_broadcast_enable  ("disable_broadcast"        ),
				.dqs_lgc_burst_length      ("burst_length_2"           ),
				.dqs_lgc_ddr4_search       ("ddr3_search"              ),
				.dqs_lgc_count_threshold   (7'h73                      )

			) u_lane(
				// Clocks and Resets
				.reset_n    (reset_n                   ),
				.pll_locked (pll_locked                ),
				.phy_clk    (phy_clk_lane    [lane_num]),
				.phy_clk_phs(phy_clk_phs_lane[lane_num]),
				.dll_ref_clk(dll_clk_out     [lane_num]),
				    
				// Core interface
				.oe_from_core      (oe_from_core  [((lane_num + 1) * 48) - 1 : lane_num * 48]),
				.data_from_core    (data_from_core[((lane_num + 1) * 96) - 1 : lane_num * 96]),
				.data_to_core      (data_to_core  [((lane_num + 1) * 96) - 1 : lane_num * 96]),
				.rdata_en_full_core(rdata_en                                                 ),
				.mrnk_read_core    (16'd0                                                    ),
				.mrnk_write_core   (16'd0                                                    ),
				.rdata_valid_core  (rdata_valid_lane[lane_num]                               ),
				
				// DBC interface
				.core2dbc_rd_data_rdy  (1'b0 ),
				.core2dbc_wr_data_vld0 (1'b0 ),
				.core2dbc_wr_data_vld1 (1'b0 ),
				.core2dbc_wr_ecc_info  (12'b0),
				.dbc2core_rd_data_vld0 (),
				.dbc2core_rd_data_vld1 (),
				.dbc2core_wb_pointer   (),
				.dbc2core_wr_data_rdy  (),
				
				// HMC interface
				.ac_hmc       (96'b0),
				.afi_rlat_core(),
				.afi_wlat_core(),
				.cfg_dbc      (16'b0),
				.ctl2dbc0     (51'b0),
				.ctl2dbc1     (51'b0),
				.dbc2ctl      (),
				
				//Avalon interface
				.cal_avl_in          (cal_avl      [lane_num + (lane_num / 2)]    ),
				.cal_avl_readdata_out(cal_avl_rdata[lane_num + (lane_num / 2)]    ),
				.cal_avl_out         (cal_avl      [lane_num + (lane_num / 2) + 1]),
				.cal_avl_readdata_in (cal_avl_rdata[lane_num + (lane_num / 2) + 1]),
				
				// DQS interface
				.dqs_in           (dqs_in),
				.broadcast_in_bot (broadcast_up[lane_num    ]),
				.broadcast_out_bot(broadcast_dn[lane_num    ]),
				.broadcast_in_top (broadcast_dn[lane_num + 1]),
				.broadcast_out_top(broadcast_up[lane_num + 1]),
				
				// IO interface
				.data_oe   (data_oe   [((lane_num + 1) * 12) - 1 : lane_num * 12]),
				.data_out  (data_out  [((lane_num + 1) * 12) - 1 : lane_num * 12]),
				.data_in   (data_in   [((lane_num + 1) * 12) - 1 : lane_num * 12]),
				.oct_enable(oct_enable[((lane_num + 1) * 12) - 1 : lane_num * 12]),
				
				// DLL/PVT interface
				.core_dll(3'b000),
				.dll_core(),
				
				// Clock Phase Alignment daisy chain
				.sync_clk_bot_in  (sync_up[lane_num + (lane_num / 2)][1]    ),
				.sync_clk_bot_out (sync_dn[lane_num + (lane_num / 2)][1]    ),
				.sync_data_bot_in (sync_up[lane_num + (lane_num / 2)][0]    ),
				.sync_data_bot_out(sync_dn[lane_num + (lane_num / 2)][0]    ),
				.sync_clk_top_in  (sync_dn[lane_num + (lane_num / 2) + 1][1]),
				.sync_clk_top_out (sync_up[lane_num + (lane_num / 2) + 1][1]),
				.sync_data_top_in (sync_dn[lane_num + (lane_num / 2) + 1][0]),
				.sync_data_top_out(sync_up[lane_num + (lane_num / 2) + 1][0])
			);

		end 
	endgenerate

endmodule
