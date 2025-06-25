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
// Core to Periphery connections of 20nm Phylite component.
//
///////////////////////////////////////////////////////////////////////////////
module phylite_c2p_conns #(
	parameter integer NUM_GROUPS                            = 1,
	parameter integer RATE_MULT                             = 4,
	parameter string  GROUP_PIN_TYPE                 [0:11] = '{"BIDIR", "BIDIR", "BIDIR", "BIDIR", "BIDIR", "BIDIR", "BIDIR", "BIDIR", "BIDIR", "BIDIR", "BIDIR", "BIDIR"},
	parameter string  GROUP_DDR_SDR_MODE             [0:11] = '{"DDR", "DDR", "DDR", "DDR", "DDR", "DDR", "DDR", "DDR", "DDR", "DDR", "DDR", "DDR"},
	parameter integer GROUP_PIN_WIDTH                [0:11] = '{9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9},
	parameter integer GROUP_USE_OUTPUT_STROBE        [0:11] = '{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
	parameter integer GROUP_USE_DIFF_STROBE          [0:11] = '{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	parameter integer GROUP_PIN_OE_WIDTH             [0:11] = '{4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4},
	parameter integer GROUP_PIN_DATA_WIDTH           [0:11] = '{8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8},
	parameter integer GROUP_STROBE_PIN_OE_WIDTH      [0:11] = '{4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4},
	parameter integer GROUP_STROBE_PIN_DATA_WIDTH    [0:11] = '{8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8},
	parameter integer GROUP_OE_WIDTH                 [0:11] = '{36, 36, 36, 36, 36, 36, 36, 36, 36, 36, 36, 36},
	parameter integer GROUP_DATA_WIDTH               [0:11] = '{72, 72, 72, 72, 72, 72, 72, 72, 72, 72, 72, 72},
	parameter integer GROUP_OUTPUT_STROBE_OE_WIDTH   [0:11] = '{4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4},
	parameter integer GROUP_OUTPUT_STROBE_DATA_WIDTH [0:11] = '{8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8}
	) (
	input                  [GROUP_OE_WIDTH[0] - 1 : 0] group_0_oe_from_core     ,
	input                [GROUP_DATA_WIDTH[0] - 1 : 0] group_0_data_from_core   ,
	output               [GROUP_DATA_WIDTH[0] - 1 : 0] group_0_data_to_core     ,
	input                          [RATE_MULT - 1 : 0] group_0_rdata_en         ,
	output                         [RATE_MULT - 1 : 0] group_0_rdata_valid      ,
	input  [GROUP_OUTPUT_STROBE_DATA_WIDTH[0] - 1 : 0] group_0_strobe_out_in    ,
	input    [GROUP_OUTPUT_STROBE_OE_WIDTH[0] - 1 : 0] group_0_strobe_out_en    ,
	
	input                  [GROUP_OE_WIDTH[1] - 1 : 0] group_1_oe_from_core     ,
	input                [GROUP_DATA_WIDTH[1] - 1 : 0] group_1_data_from_core   ,
	output               [GROUP_DATA_WIDTH[1] - 1 : 0] group_1_data_to_core     ,
	input                          [RATE_MULT - 1 : 0] group_1_rdata_en         ,
	output                         [RATE_MULT - 1 : 0] group_1_rdata_valid      ,
	input  [GROUP_OUTPUT_STROBE_DATA_WIDTH[1] - 1 : 0] group_1_strobe_out_in    ,
	input    [GROUP_OUTPUT_STROBE_OE_WIDTH[1] - 1 : 0] group_1_strobe_out_en    ,
	
	input                  [GROUP_OE_WIDTH[2] - 1 : 0] group_2_oe_from_core     ,
	input                [GROUP_DATA_WIDTH[2] - 1 : 0] group_2_data_from_core   ,
	output               [GROUP_DATA_WIDTH[2] - 1 : 0] group_2_data_to_core     ,
	input                          [RATE_MULT - 1 : 0] group_2_rdata_en         ,
	output                         [RATE_MULT - 1 : 0] group_2_rdata_valid      ,
	input  [GROUP_OUTPUT_STROBE_DATA_WIDTH[2] - 1 : 0] group_2_strobe_out_in    ,
	input    [GROUP_OUTPUT_STROBE_OE_WIDTH[2] - 1 : 0] group_2_strobe_out_en    ,
	
	input                  [GROUP_OE_WIDTH[3] - 1 : 0] group_3_oe_from_core     ,
	input                [GROUP_DATA_WIDTH[3] - 1 : 0] group_3_data_from_core   ,
	output               [GROUP_DATA_WIDTH[3] - 1 : 0] group_3_data_to_core     ,
	input                          [RATE_MULT - 1 : 0] group_3_rdata_en         ,
	output                         [RATE_MULT - 1 : 0] group_3_rdata_valid      ,
	input  [GROUP_OUTPUT_STROBE_DATA_WIDTH[3] - 1 : 0] group_3_strobe_out_in    ,
	input    [GROUP_OUTPUT_STROBE_OE_WIDTH[3] - 1 : 0] group_3_strobe_out_en    ,
	
	input                  [GROUP_OE_WIDTH[4] - 1 : 0] group_4_oe_from_core     ,
	input                [GROUP_DATA_WIDTH[4] - 1 : 0] group_4_data_from_core   ,
	output               [GROUP_DATA_WIDTH[4] - 1 : 0] group_4_data_to_core     ,
	input                          [RATE_MULT - 1 : 0] group_4_rdata_en         ,
	output                         [RATE_MULT - 1 : 0] group_4_rdata_valid      ,
	input  [GROUP_OUTPUT_STROBE_DATA_WIDTH[4] - 1 : 0] group_4_strobe_out_in    ,
	input    [GROUP_OUTPUT_STROBE_OE_WIDTH[4] - 1 : 0] group_4_strobe_out_en    ,
	
	input                  [GROUP_OE_WIDTH[5] - 1 : 0] group_5_oe_from_core     ,
	input                [GROUP_DATA_WIDTH[5] - 1 : 0] group_5_data_from_core   ,
	output               [GROUP_DATA_WIDTH[5] - 1 : 0] group_5_data_to_core     ,
	input                          [RATE_MULT - 1 : 0] group_5_rdata_en         ,
	output                         [RATE_MULT - 1 : 0] group_5_rdata_valid      ,
	input  [GROUP_OUTPUT_STROBE_DATA_WIDTH[5] - 1 : 0] group_5_strobe_out_in    ,
	input    [GROUP_OUTPUT_STROBE_OE_WIDTH[5] - 1 : 0] group_5_strobe_out_en    ,
	
	input                  [GROUP_OE_WIDTH[6] - 1 : 0] group_6_oe_from_core     ,
	input                [GROUP_DATA_WIDTH[6] - 1 : 0] group_6_data_from_core   ,
	output               [GROUP_DATA_WIDTH[6] - 1 : 0] group_6_data_to_core     ,
	input                          [RATE_MULT - 1 : 0] group_6_rdata_en         ,
	output                         [RATE_MULT - 1 : 0] group_6_rdata_valid      ,
	input  [GROUP_OUTPUT_STROBE_DATA_WIDTH[6] - 1 : 0] group_6_strobe_out_in    ,
	input    [GROUP_OUTPUT_STROBE_OE_WIDTH[6] - 1 : 0] group_6_strobe_out_en    ,
	
	input                  [GROUP_OE_WIDTH[7] - 1 : 0] group_7_oe_from_core     ,
	input                [GROUP_DATA_WIDTH[7] - 1 : 0] group_7_data_from_core   ,
	output               [GROUP_DATA_WIDTH[7] - 1 : 0] group_7_data_to_core     ,
	input                          [RATE_MULT - 1 : 0] group_7_rdata_en         ,
	output                         [RATE_MULT - 1 : 0] group_7_rdata_valid      ,
	input  [GROUP_OUTPUT_STROBE_DATA_WIDTH[7] - 1 : 0] group_7_strobe_out_in    ,
	input    [GROUP_OUTPUT_STROBE_OE_WIDTH[7] - 1 : 0] group_7_strobe_out_en    ,
	
	input                  [GROUP_OE_WIDTH[8] - 1 : 0] group_8_oe_from_core     ,
	input                [GROUP_DATA_WIDTH[8] - 1 : 0] group_8_data_from_core   ,
	output               [GROUP_DATA_WIDTH[8] - 1 : 0] group_8_data_to_core     ,
	input                          [RATE_MULT - 1 : 0] group_8_rdata_en         ,
	output                         [RATE_MULT - 1 : 0] group_8_rdata_valid      ,
	input  [GROUP_OUTPUT_STROBE_DATA_WIDTH[8] - 1 : 0] group_8_strobe_out_in    ,
	input    [GROUP_OUTPUT_STROBE_OE_WIDTH[8] - 1 : 0] group_8_strobe_out_en    ,
	
	input                  [GROUP_OE_WIDTH[9] - 1 : 0] group_9_oe_from_core     ,
	input                [GROUP_DATA_WIDTH[9] - 1 : 0] group_9_data_from_core   ,
	output               [GROUP_DATA_WIDTH[9] - 1 : 0] group_9_data_to_core     ,
	input                          [RATE_MULT - 1 : 0] group_9_rdata_en         ,
	output                         [RATE_MULT - 1 : 0] group_9_rdata_valid      ,
	input  [GROUP_OUTPUT_STROBE_DATA_WIDTH[9] - 1 : 0] group_9_strobe_out_in    ,
	input    [GROUP_OUTPUT_STROBE_OE_WIDTH[9] - 1 : 0] group_9_strobe_out_en    ,
	
	input                  [GROUP_OE_WIDTH[10] - 1 : 0] group_10_oe_from_core   ,
	input                [GROUP_DATA_WIDTH[10] - 1 : 0] group_10_data_from_core ,
	output               [GROUP_DATA_WIDTH[10] - 1 : 0] group_10_data_to_core   ,
	input                           [RATE_MULT - 1 : 0] group_10_rdata_en       ,
	output                          [RATE_MULT - 1 : 0] group_10_rdata_valid    ,
	input  [GROUP_OUTPUT_STROBE_DATA_WIDTH[10] - 1 : 0] group_10_strobe_out_in  ,
	input    [GROUP_OUTPUT_STROBE_OE_WIDTH[10] - 1 : 0] group_10_strobe_out_en  ,
	
	input                  [GROUP_OE_WIDTH[11] - 1 : 0] group_11_oe_from_core   ,
	input                [GROUP_DATA_WIDTH[11] - 1 : 0] group_11_data_from_core ,
	output               [GROUP_DATA_WIDTH[11] - 1 : 0] group_11_data_to_core   ,
	input                           [RATE_MULT - 1 : 0] group_11_rdata_en       ,
	output                          [RATE_MULT - 1 : 0] group_11_rdata_valid    ,
	input  [GROUP_OUTPUT_STROBE_DATA_WIDTH[11] - 1 : 0] group_11_strobe_out_in  ,
	input    [GROUP_OUTPUT_STROBE_OE_WIDTH[11] - 1 : 0] group_11_strobe_out_en  ,

	output [191:0] oe_from_core   [0:NUM_GROUPS-1],
	output [383:0] data_from_core [0:NUM_GROUPS-1],
	input  [383:0] data_to_core   [0:NUM_GROUPS-1],
	output   [3:0] rdata_en       [0:NUM_GROUPS-1],
	input    [3:0] rdata_valid    [0:NUM_GROUPS-1]
	);

	////////////////////////////////////////////////////////////////////////////
	// Wire Declarations
	////////////////////////////////////////////////////////////////////////////
	wire [191:0] group_oe_from_core  [0:11];
	wire [383:0] group_data_from_core[0:11];
	wire [383:0] group_data_to_core  [0:11];
	wire   [3:0] group_rdata_en      [0:11];
	wire   [3:0] group_rdata_valid   [0:11];
	wire  [15:0] group_strobe_out_in [0:11];
	wire   [7:0] group_strobe_out_en [0:11];

	////////////////////////////////////////////////////////////////////////////
	// Assign core ports to internal arrays
	////////////////////////////////////////////////////////////////////////////
	assign group_oe_from_core  [0][GROUP_OE_WIDTH                [0] - 1 : 0]  = group_0_oe_from_core  ;
	assign group_data_from_core[0][GROUP_DATA_WIDTH              [0] - 1 : 0]  = group_0_data_from_core;
	assign group_strobe_out_in [0][GROUP_OUTPUT_STROBE_DATA_WIDTH[0] - 1 : 0]  = group_0_strobe_out_in ;
	assign group_strobe_out_en [0][GROUP_OUTPUT_STROBE_OE_WIDTH  [0] - 1 : 0]  = group_0_strobe_out_en ;
	assign group_rdata_en      [0][RATE_MULT - 1 : 0] = group_0_rdata_en;
	assign group_0_data_to_core = group_data_to_core[0][GROUP_DATA_WIDTH[0] - 1 : 0];
	assign group_0_rdata_valid  = group_rdata_valid [0][RATE_MULT - 1 : 0];

	assign group_oe_from_core  [1][GROUP_OE_WIDTH                [1] - 1 : 0]  = group_1_oe_from_core  ;
	assign group_data_from_core[1][GROUP_DATA_WIDTH              [1] - 1 : 0]  = group_1_data_from_core;
	assign group_strobe_out_in [1][GROUP_OUTPUT_STROBE_DATA_WIDTH[1] - 1 : 0]  = group_1_strobe_out_in ;
	assign group_strobe_out_en [1][GROUP_OUTPUT_STROBE_OE_WIDTH  [1] - 1 : 0]  = group_1_strobe_out_en ;
	assign group_rdata_en      [1][RATE_MULT - 1 : 0] = group_1_rdata_en;
	assign group_1_data_to_core = group_data_to_core[1][GROUP_DATA_WIDTH[1] - 1 : 0];
	assign group_1_rdata_valid  = group_rdata_valid [1][RATE_MULT - 1 : 0];

	assign group_oe_from_core  [2][GROUP_OE_WIDTH                [2] - 1 : 0]  = group_2_oe_from_core  ;
	assign group_data_from_core[2][GROUP_DATA_WIDTH              [2] - 1 : 0]  = group_2_data_from_core;
	assign group_strobe_out_in [2][GROUP_OUTPUT_STROBE_DATA_WIDTH[2] - 1 : 0]  = group_2_strobe_out_in ;
	assign group_strobe_out_en [2][GROUP_OUTPUT_STROBE_OE_WIDTH  [2] - 1 : 0]  = group_2_strobe_out_en ;
	assign group_rdata_en      [2][RATE_MULT - 1 : 0] = group_2_rdata_en;
	assign group_2_data_to_core = group_data_to_core[2][GROUP_DATA_WIDTH[2] - 1 : 0];
	assign group_2_rdata_valid  = group_rdata_valid [2][RATE_MULT - 1 : 0];

	assign group_oe_from_core  [3][GROUP_OE_WIDTH                [3] - 1 : 0]  = group_3_oe_from_core  ;
	assign group_data_from_core[3][GROUP_DATA_WIDTH              [3] - 1 : 0]  = group_3_data_from_core;
	assign group_strobe_out_in [3][GROUP_OUTPUT_STROBE_DATA_WIDTH[3] - 1 : 0]  = group_3_strobe_out_in ;
	assign group_strobe_out_en [3][GROUP_OUTPUT_STROBE_OE_WIDTH  [3] - 1 : 0]  = group_3_strobe_out_en ;
	assign group_rdata_en      [3][RATE_MULT - 1 : 0] = group_3_rdata_en;
	assign group_3_data_to_core = group_data_to_core[3][GROUP_DATA_WIDTH[3] - 1 : 0];
	assign group_3_rdata_valid  = group_rdata_valid [3][RATE_MULT - 1 : 0];

	assign group_oe_from_core  [4][GROUP_OE_WIDTH                [4] - 1 : 0]  = group_4_oe_from_core  ;
	assign group_data_from_core[4][GROUP_DATA_WIDTH              [4] - 1 : 0]  = group_4_data_from_core;
	assign group_strobe_out_in [4][GROUP_OUTPUT_STROBE_DATA_WIDTH[4] - 1 : 0]  = group_4_strobe_out_in ;
	assign group_strobe_out_en [4][GROUP_OUTPUT_STROBE_OE_WIDTH  [4] - 1 : 0]  = group_4_strobe_out_en ;
	assign group_rdata_en      [4][RATE_MULT - 1 : 0] = group_4_rdata_en;
	assign group_4_data_to_core = group_data_to_core[4][GROUP_DATA_WIDTH[4] - 1 : 0];
	assign group_4_rdata_valid  = group_rdata_valid [4][RATE_MULT - 1 : 0];

	assign group_oe_from_core  [5][GROUP_OE_WIDTH                [5] - 1 : 0]  = group_5_oe_from_core  ;
	assign group_data_from_core[5][GROUP_DATA_WIDTH              [5] - 1 : 0]  = group_5_data_from_core;
	assign group_strobe_out_in [5][GROUP_OUTPUT_STROBE_DATA_WIDTH[5] - 1 : 0]  = group_5_strobe_out_in ;
	assign group_strobe_out_en [5][GROUP_OUTPUT_STROBE_OE_WIDTH  [5] - 1 : 0]  = group_5_strobe_out_en ;
	assign group_rdata_en      [5][RATE_MULT - 1 : 0] = group_5_rdata_en;
	assign group_5_data_to_core = group_data_to_core[5][GROUP_DATA_WIDTH[5] - 1 : 0];
	assign group_5_rdata_valid  = group_rdata_valid [5][RATE_MULT - 1 : 0];

	assign group_oe_from_core  [6][GROUP_OE_WIDTH                [6] - 1 : 0]  = group_6_oe_from_core  ;
	assign group_data_from_core[6][GROUP_DATA_WIDTH              [6] - 1 : 0]  = group_6_data_from_core;
	assign group_strobe_out_in [6][GROUP_OUTPUT_STROBE_DATA_WIDTH[6] - 1 : 0]  = group_6_strobe_out_in ;
	assign group_strobe_out_en [6][GROUP_OUTPUT_STROBE_OE_WIDTH  [6] - 1 : 0]  = group_6_strobe_out_en ;
	assign group_rdata_en      [6][RATE_MULT - 1 : 0] = group_6_rdata_en;
	assign group_6_data_to_core = group_data_to_core[6][GROUP_DATA_WIDTH[6] - 1 : 0];
	assign group_6_rdata_valid  = group_rdata_valid [6][RATE_MULT - 1 : 0];

	assign group_oe_from_core  [7][GROUP_OE_WIDTH                [7] - 1 : 0]  = group_7_oe_from_core  ;
	assign group_data_from_core[7][GROUP_DATA_WIDTH              [7] - 1 : 0]  = group_7_data_from_core;
	assign group_strobe_out_in [7][GROUP_OUTPUT_STROBE_DATA_WIDTH[7] - 1 : 0]  = group_7_strobe_out_in ;
	assign group_strobe_out_en [7][GROUP_OUTPUT_STROBE_OE_WIDTH  [7] - 1 : 0]  = group_7_strobe_out_en ;
	assign group_rdata_en      [7][RATE_MULT - 1 : 0] = group_7_rdata_en;
	assign group_7_data_to_core = group_data_to_core[7][GROUP_DATA_WIDTH[7] - 1 : 0];
	assign group_7_rdata_valid  = group_rdata_valid [7][RATE_MULT - 1 : 0];

	assign group_oe_from_core  [8][GROUP_OE_WIDTH                [8] - 1 : 0]  = group_8_oe_from_core  ;
	assign group_data_from_core[8][GROUP_DATA_WIDTH              [8] - 1 : 0]  = group_8_data_from_core;
	assign group_strobe_out_in [8][GROUP_OUTPUT_STROBE_DATA_WIDTH[8] - 1 : 0]  = group_8_strobe_out_in ;
	assign group_strobe_out_en [8][GROUP_OUTPUT_STROBE_OE_WIDTH  [8] - 1 : 0]  = group_8_strobe_out_en ;
	assign group_rdata_en      [8][RATE_MULT - 1 : 0] = group_8_rdata_en;
	assign group_8_data_to_core = group_data_to_core[8][GROUP_DATA_WIDTH[8] - 1 : 0];
	assign group_8_rdata_valid  = group_rdata_valid [8][RATE_MULT - 1 : 0];

	assign group_oe_from_core  [9][GROUP_OE_WIDTH                [9] - 1 : 0]  = group_9_oe_from_core  ;
	assign group_data_from_core[9][GROUP_DATA_WIDTH              [9] - 1 : 0]  = group_9_data_from_core;
	assign group_strobe_out_in [9][GROUP_OUTPUT_STROBE_DATA_WIDTH[9] - 1 : 0]  = group_9_strobe_out_in ;
	assign group_strobe_out_en [9][GROUP_OUTPUT_STROBE_OE_WIDTH  [9] - 1 : 0]  = group_9_strobe_out_en ;
	assign group_rdata_en      [9][RATE_MULT - 1 : 0] = group_9_rdata_en;
	assign group_9_data_to_core = group_data_to_core[9][GROUP_DATA_WIDTH[9] - 1 : 0];
	assign group_9_rdata_valid  = group_rdata_valid [9][RATE_MULT - 1 : 0];

	assign group_oe_from_core  [10][GROUP_OE_WIDTH                [10] - 1 : 0]  = group_10_oe_from_core  ;
	assign group_data_from_core[10][GROUP_DATA_WIDTH              [10] - 1 : 0]  = group_10_data_from_core;
	assign group_strobe_out_in [10][GROUP_OUTPUT_STROBE_DATA_WIDTH[10] - 1 : 0]  = group_10_strobe_out_in ;
	assign group_strobe_out_en [10][GROUP_OUTPUT_STROBE_OE_WIDTH  [10] - 1 : 0]  = group_10_strobe_out_en ;
	assign group_rdata_en      [10][RATE_MULT - 1 : 0] = group_10_rdata_en;
	assign group_10_data_to_core = group_data_to_core[10][GROUP_DATA_WIDTH[10] - 1 : 0];
	assign group_10_rdata_valid  = group_rdata_valid [10][RATE_MULT - 1 : 0];

	assign group_oe_from_core  [11][GROUP_OE_WIDTH                [11] - 1 : 0]  = group_11_oe_from_core  ;
	assign group_data_from_core[11][GROUP_DATA_WIDTH              [11] - 1 : 0]  = group_11_data_from_core;
	assign group_strobe_out_in [11][GROUP_OUTPUT_STROBE_DATA_WIDTH[11] - 1 : 0]  = group_11_strobe_out_in ;
	assign group_strobe_out_en [11][GROUP_OUTPUT_STROBE_OE_WIDTH  [11] - 1 : 0]  = group_11_strobe_out_en ;
	assign group_rdata_en      [11][RATE_MULT - 1 : 0] = group_11_rdata_en;
	assign group_11_data_to_core = group_data_to_core[11][GROUP_DATA_WIDTH[11] - 1 : 0];
	assign group_11_rdata_valid  = group_rdata_valid [11][RATE_MULT - 1 : 0];

	////////////////////////////////////////////////////////////////////////////
	// Map core signals to periphery inputs
	////////////////////////////////////////////////////////////////////////////
	generate
		genvar grp_num, pin_idx, bit_idx;

		for (grp_num = 0; grp_num < 12; grp_num = grp_num + 1) begin : gen_grp_c2p_conns
			if (grp_num < NUM_GROUPS) begin
				localparam DATA_OFFSET = ((GROUP_PIN_TYPE[grp_num] == "OUTPUT") && (GROUP_USE_OUTPUT_STROBE[grp_num] == 0)) ? 0 :
				                          (GROUP_USE_DIFF_STROBE[grp_num] == 1) ? 2 : 1;
				if (GROUP_PIN_TYPE[grp_num] == "OUTPUT" || GROUP_PIN_TYPE[grp_num] == "BIDIR") begin
					if (DATA_OFFSET == 2) begin
						assign oe_from_core  [grp_num][7:0]  = {2{{(4 - GROUP_STROBE_PIN_OE_WIDTH  [grp_num]){1'b0}}, group_strobe_out_en[grp_num][(GROUP_STROBE_PIN_OE_WIDTH  [grp_num]) - 1 : 0]}};
						assign data_from_core[grp_num][15:0] = {{(8 - GROUP_STROBE_PIN_DATA_WIDTH[grp_num]){1'b0}}, ~group_strobe_out_in[grp_num][(GROUP_STROBE_PIN_DATA_WIDTH[grp_num]) - 1 : 0], {(8 - GROUP_STROBE_PIN_DATA_WIDTH[grp_num]){1'b0}}, group_strobe_out_in[grp_num][(GROUP_STROBE_PIN_DATA_WIDTH[grp_num]) - 1 : 0]};
					end else if (DATA_OFFSET == 1) begin
						assign oe_from_core  [grp_num][3:0] = {{(4 - GROUP_STROBE_PIN_OE_WIDTH  [grp_num]){1'b0}}, group_strobe_out_en[grp_num][GROUP_STROBE_PIN_OE_WIDTH  [grp_num] - 1 : 0]};
						assign data_from_core[grp_num][7:0] = {{(8 - GROUP_STROBE_PIN_DATA_WIDTH[grp_num]){1'b0}}, group_strobe_out_in[grp_num][GROUP_STROBE_PIN_DATA_WIDTH[grp_num] - 1 : 0]};
					end

					for (pin_idx = 0; pin_idx < 48; pin_idx = pin_idx + 1) begin : gen_grp_pin_c2p_conns
						if (pin_idx < GROUP_PIN_WIDTH[grp_num]) begin
							localparam OFFSET_PIN_IDX = pin_idx + DATA_OFFSET;
							assign oe_from_core  [grp_num][((OFFSET_PIN_IDX + 1) * 4) - 1 : (OFFSET_PIN_IDX * 4)] = {{(4 - GROUP_PIN_OE_WIDTH  [grp_num]){1'b0}}, group_oe_from_core  [grp_num][((pin_idx + 1) * GROUP_PIN_OE_WIDTH  [grp_num]) - 1 : (pin_idx * GROUP_PIN_OE_WIDTH  [grp_num])]};
							assign data_from_core[grp_num][((OFFSET_PIN_IDX + 1) * 8) - 1 : (OFFSET_PIN_IDX * 8)] = {{(8 - GROUP_PIN_DATA_WIDTH[grp_num]){1'b0}}, group_data_from_core[grp_num][((pin_idx + 1) * GROUP_PIN_DATA_WIDTH[grp_num]) - 1 : (pin_idx * GROUP_PIN_DATA_WIDTH[grp_num])]};
						end else if (pin_idx >= (GROUP_PIN_WIDTH[grp_num] + DATA_OFFSET)) begin
							assign oe_from_core  [grp_num][((pin_idx + 1) * 4) - 1 : (pin_idx * 4)] = 4'h0;
							assign data_from_core[grp_num][((pin_idx + 1) * 8) - 1 : (pin_idx * 8)] = 8'h00;
						end
					end 
				end else begin
					assign oe_from_core[grp_num]   = {192{1'b0}};
					assign data_from_core[grp_num] = {384{1'b0}};
				end

				if (GROUP_PIN_TYPE[grp_num] == "INPUT" || GROUP_PIN_TYPE[grp_num] == "BIDIR") begin
					for (pin_idx = 0; pin_idx < GROUP_PIN_WIDTH[grp_num]; pin_idx = pin_idx + 1) begin : gen_grp_pin_c2p_conns
						localparam OFFSET_PIN_IDX = pin_idx + DATA_OFFSET;
						if (GROUP_DDR_SDR_MODE[grp_num] == "DDR") begin
							assign group_data_to_core[grp_num][((pin_idx + 1) * GROUP_PIN_DATA_WIDTH[grp_num]) - 1 : (pin_idx * GROUP_PIN_DATA_WIDTH[grp_num])] = data_to_core[grp_num][((OFFSET_PIN_IDX * 8) + GROUP_PIN_DATA_WIDTH[grp_num]) - 1 : (OFFSET_PIN_IDX * 8)];
						end else begin
							for (bit_idx = 0; bit_idx < GROUP_PIN_DATA_WIDTH[grp_num]; bit_idx = bit_idx + 1) begin : gen_grp_pin_c2p_conns_sdr_rdata
								assign group_data_to_core[grp_num][(pin_idx * GROUP_PIN_DATA_WIDTH[grp_num]) + bit_idx] = data_to_core[grp_num][(OFFSET_PIN_IDX * 8) + (bit_idx * 2)]; // SDR data to core is on every other bit
							end //gen_grp_pin_c2p_conns_sdr_rdata
						end
					end 

					assign rdata_en[grp_num][RATE_MULT - 1 : 0] = {{(4 - RATE_MULT){1'b0}}, group_rdata_en[grp_num][RATE_MULT - 1 : 0]};
					assign group_rdata_valid[grp_num][RATE_MULT - 1 : 0] = rdata_valid[grp_num][RATE_MULT - 1 : 0];
				end
			end else begin
				assign group_data_to_core[grp_num][GROUP_DATA_WIDTH[grp_num] - 1 : 0] = {GROUP_DATA_WIDTH[grp_num] {1'b0}};
				assign group_rdata_valid [grp_num][RATE_MULT - 1 : 0] = {RATE_MULT{1'b0}};
			end
		end 
	endgenerate

endmodule
