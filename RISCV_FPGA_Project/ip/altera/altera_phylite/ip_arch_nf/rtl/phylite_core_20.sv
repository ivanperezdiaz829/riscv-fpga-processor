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
// Top-level wrapper of 20nm Phylite component.
//
///////////////////////////////////////////////////////////////////////////////
module phylite_core_20 #(
	// Top Level parameters
	parameter PHYLITE_NUM_GROUPS                      = 1,
	parameter PHYLITE_RATE_ENUM                       = "RATE_IN_QUARTER",
	parameter PHYLITE_USE_DYNAMIC_RECONFIGURATION     = 0,

	// PLL parameters
	parameter PLL_REF_CLK_FREQ_PS_STR                 = "0 ps",
	parameter PLL_VCO_FREQ_PS_STR                     = "0 ps",
	parameter PLL_VCO_FREQ_MHZ_INT                    = 0,
	parameter PLL_VCO_TO_MEM_CLK_FREQ_RATIO           = 1,
	parameter PLL_MEM_CLK_FREQ_PS_STR                 = "0 ps",
	parameter PLL_M_COUNTER_BYPASS_EN                 = "true",
	parameter PLL_M_COUNTER_EVEN_DUTY_EN              = "false",
	parameter PLL_M_COUNTER_HIGH                      = 256,
	parameter PLL_M_COUNTER_LOW                       = 256,
	parameter PLL_PHYCLK_0_FREQ_PS_STR                = "0 ps",
	parameter PLL_PHYCLK_0_BYPASS_EN                  = "true",
	parameter PLL_PHYCLK_0_HIGH                       = 256,
	parameter PLL_PHYCLK_0_LOW                        = 256,
	parameter PLL_PHYCLK_1_FREQ_PS_STR                = "0 ps",
	parameter PLL_PHYCLK_1_BYPASS_EN                  = "true",
	parameter PLL_PHYCLK_1_HIGH                       = 256,
	parameter PLL_PHYCLK_1_LOW                        = 256,
	parameter PLL_PHYCLK_FB_FREQ_PS_STR               = "0 ps",
	parameter PLL_PHYCLK_FB_BYPASS_EN                 = "true",
	parameter PLL_PHYCLK_FB_HIGH                      = 256,
	parameter PLL_PHYCLK_FB_LOW                       = 256,

	// Group Parameters
	parameter GROUP_0_PIN_TYPE                        = "BIDIR",
	parameter GROUP_0_PIN_WIDTH                       = 9,
	parameter GROUP_0_DDR_SDR_MODE                    = "DDR",
	parameter GROUP_0_USE_DIFF_STROBE                 = 0,
	parameter GROUP_0_READ_LATENCY                    = 4,
	parameter GROUP_0_CAPTURE_PHASE_SHIFT             = 90,
	parameter GROUP_0_USE_INTERNAL_CAPTURE_STROBE     = 0,
	parameter GROUP_0_WRITE_LATENCY                   = 0,
	parameter GROUP_0_USE_OUTPUT_STROBE               = 1,
	parameter GROUP_0_OUTPUT_STROBE_PHASE             = 90,
	parameter GROUP_1_PIN_TYPE                        = "BIDIR",
	parameter GROUP_1_PIN_WIDTH                       = 9,
	parameter GROUP_1_DDR_SDR_MODE                    = "DDR",
	parameter GROUP_1_USE_DIFF_STROBE                 = 0,
	parameter GROUP_1_READ_LATENCY                    = 4,
	parameter GROUP_1_CAPTURE_PHASE_SHIFT             = 90,
	parameter GROUP_1_USE_INTERNAL_CAPTURE_STROBE     = 0,
	parameter GROUP_1_WRITE_LATENCY                   = 0,
	parameter GROUP_1_USE_OUTPUT_STROBE               = 1,
	parameter GROUP_1_OUTPUT_STROBE_PHASE             = 90,
	parameter GROUP_2_PIN_TYPE                        = "BIDIR",
	parameter GROUP_2_PIN_WIDTH                       = 9,
	parameter GROUP_2_DDR_SDR_MODE                    = "DDR",
	parameter GROUP_2_USE_DIFF_STROBE                 = 0,
	parameter GROUP_2_READ_LATENCY                    = 4,
	parameter GROUP_2_CAPTURE_PHASE_SHIFT             = 90,
	parameter GROUP_2_USE_INTERNAL_CAPTURE_STROBE     = 0,
	parameter GROUP_2_WRITE_LATENCY                   = 0,
	parameter GROUP_2_USE_OUTPUT_STROBE               = 1,
	parameter GROUP_2_OUTPUT_STROBE_PHASE             = 90,
	parameter GROUP_3_PIN_TYPE                        = "BIDIR",
	parameter GROUP_3_PIN_WIDTH                       = 9,
	parameter GROUP_3_DDR_SDR_MODE                    = "DDR",
	parameter GROUP_3_USE_DIFF_STROBE                 = 0,
	parameter GROUP_3_READ_LATENCY                    = 4,
	parameter GROUP_3_CAPTURE_PHASE_SHIFT             = 90,
	parameter GROUP_3_USE_INTERNAL_CAPTURE_STROBE     = 0,
	parameter GROUP_3_WRITE_LATENCY                   = 0,
	parameter GROUP_3_USE_OUTPUT_STROBE               = 1,
	parameter GROUP_3_OUTPUT_STROBE_PHASE             = 90,
	parameter GROUP_4_PIN_TYPE                        = "BIDIR",
	parameter GROUP_4_PIN_WIDTH                       = 9,
	parameter GROUP_4_DDR_SDR_MODE                    = "DDR",
	parameter GROUP_4_USE_DIFF_STROBE                 = 0,
	parameter GROUP_4_READ_LATENCY                    = 4,
	parameter GROUP_4_CAPTURE_PHASE_SHIFT             = 90,
	parameter GROUP_4_USE_INTERNAL_CAPTURE_STROBE     = 0,
	parameter GROUP_4_WRITE_LATENCY                   = 0,
	parameter GROUP_4_USE_OUTPUT_STROBE               = 1,
	parameter GROUP_4_OUTPUT_STROBE_PHASE             = 90,
	parameter GROUP_5_PIN_TYPE                        = "BIDIR",
	parameter GROUP_5_PIN_WIDTH                       = 9,
	parameter GROUP_5_DDR_SDR_MODE                    = "DDR",
	parameter GROUP_5_USE_DIFF_STROBE                 = 0,
	parameter GROUP_5_READ_LATENCY                    = 4,
	parameter GROUP_5_CAPTURE_PHASE_SHIFT             = 90,
	parameter GROUP_5_USE_INTERNAL_CAPTURE_STROBE     = 0,
	parameter GROUP_5_WRITE_LATENCY                   = 0,
	parameter GROUP_5_USE_OUTPUT_STROBE               = 1,
	parameter GROUP_5_OUTPUT_STROBE_PHASE             = 90,
	parameter GROUP_6_PIN_TYPE                        = "BIDIR",
	parameter GROUP_6_PIN_WIDTH                       = 9,
	parameter GROUP_6_DDR_SDR_MODE                    = "DDR",
	parameter GROUP_6_USE_DIFF_STROBE                 = 0,
	parameter GROUP_6_READ_LATENCY                    = 4,
	parameter GROUP_6_CAPTURE_PHASE_SHIFT             = 90,
	parameter GROUP_6_USE_INTERNAL_CAPTURE_STROBE     = 0,
	parameter GROUP_6_WRITE_LATENCY                   = 0,
	parameter GROUP_6_USE_OUTPUT_STROBE               = 1,
	parameter GROUP_6_OUTPUT_STROBE_PHASE             = 90,
	parameter GROUP_7_PIN_TYPE                        = "BIDIR",
	parameter GROUP_7_PIN_WIDTH                       = 9,
	parameter GROUP_7_DDR_SDR_MODE                    = "DDR",
	parameter GROUP_7_USE_DIFF_STROBE                 = 0,
	parameter GROUP_7_READ_LATENCY                    = 4,
	parameter GROUP_7_CAPTURE_PHASE_SHIFT             = 90,
	parameter GROUP_7_USE_INTERNAL_CAPTURE_STROBE     = 0,
	parameter GROUP_7_WRITE_LATENCY                   = 0,
	parameter GROUP_7_USE_OUTPUT_STROBE               = 1,
	parameter GROUP_7_OUTPUT_STROBE_PHASE             = 90,
	parameter GROUP_8_PIN_TYPE                        = "BIDIR",
	parameter GROUP_8_PIN_WIDTH                       = 9,
	parameter GROUP_8_DDR_SDR_MODE                    = "DDR",
	parameter GROUP_8_USE_DIFF_STROBE                 = 0,
	parameter GROUP_8_READ_LATENCY                    = 4,
	parameter GROUP_8_CAPTURE_PHASE_SHIFT             = 90,
	parameter GROUP_8_USE_INTERNAL_CAPTURE_STROBE     = 0,
	parameter GROUP_8_WRITE_LATENCY                   = 0,
	parameter GROUP_8_USE_OUTPUT_STROBE               = 1,
	parameter GROUP_8_OUTPUT_STROBE_PHASE             = 90,
	parameter GROUP_9_PIN_TYPE                        = "BIDIR",
	parameter GROUP_9_PIN_WIDTH                       = 9,
	parameter GROUP_9_DDR_SDR_MODE                    = "DDR",
	parameter GROUP_9_USE_DIFF_STROBE                 = 0,
	parameter GROUP_9_READ_LATENCY                    = 4,
	parameter GROUP_9_CAPTURE_PHASE_SHIFT             = 90,
	parameter GROUP_9_USE_INTERNAL_CAPTURE_STROBE     = 0,
	parameter GROUP_9_WRITE_LATENCY                   = 0,
	parameter GROUP_9_USE_OUTPUT_STROBE               = 1,
	parameter GROUP_9_OUTPUT_STROBE_PHASE             = 90,
	parameter GROUP_10_PIN_TYPE                       = "BIDIR",
	parameter GROUP_10_PIN_WIDTH                      = 9,
	parameter GROUP_10_DDR_SDR_MODE                   = "DDR",
	parameter GROUP_10_USE_DIFF_STROBE                = 0,
	parameter GROUP_10_READ_LATENCY                   = 4,
	parameter GROUP_10_CAPTURE_PHASE_SHIFT            = 90,
	parameter GROUP_10_USE_INTERNAL_CAPTURE_STROBE    = 0,
	parameter GROUP_10_WRITE_LATENCY                  = 0,
	parameter GROUP_10_USE_OUTPUT_STROBE              = 1,
	parameter GROUP_10_OUTPUT_STROBE_PHASE            = 90,
	parameter GROUP_11_PIN_TYPE                       = "BIDIR",
	parameter GROUP_11_PIN_WIDTH                      = 9,
	parameter GROUP_11_DDR_SDR_MODE                   = "DDR",
	parameter GROUP_11_USE_DIFF_STROBE                = 0,
	parameter GROUP_11_READ_LATENCY                   = 4,
	parameter GROUP_11_CAPTURE_PHASE_SHIFT            = 90,
	parameter GROUP_11_USE_INTERNAL_CAPTURE_STROBE    = 0,
	parameter GROUP_11_WRITE_LATENCY                  = 0,
	parameter GROUP_11_USE_OUTPUT_STROBE              = 1,
	parameter GROUP_11_OUTPUT_STROBE_PHASE            = 90
	) (
	// Clock and Reset Ports
	ref_clk     ,
	reset_n     ,
	pll_locked  ,
	core_clk_out,

	// Avalon Ports
	avl_clk       ,
	avl_read      ,
	avl_write     ,
	avl_writedata ,
	avl_address   ,
	avl_readdata  ,

	// Core Interface
	group_0_oe_from_core     ,
	group_0_data_from_core   ,
	group_0_data_to_core     ,
	group_0_rdata_en         ,
	group_0_rdata_valid      ,
	group_0_strobe_out_in    ,
	group_0_strobe_out_en    ,
	
	group_1_oe_from_core     ,
	group_1_data_from_core   ,
	group_1_data_to_core     ,
	group_1_rdata_en         ,
	group_1_rdata_valid      ,
	group_1_strobe_out_in    ,
	group_1_strobe_out_en    ,
	
	group_2_oe_from_core     ,
	group_2_data_from_core   ,
	group_2_data_to_core     ,
	group_2_rdata_en         ,
	group_2_rdata_valid      ,
	group_2_strobe_out_in    ,
	group_2_strobe_out_en    ,
	
	group_3_oe_from_core     ,
	group_3_data_from_core   ,
	group_3_data_to_core     ,
	group_3_rdata_en         ,
	group_3_rdata_valid      ,
	group_3_strobe_out_in    ,
	group_3_strobe_out_en    ,
	
	group_4_oe_from_core     ,
	group_4_data_from_core   ,
	group_4_data_to_core     ,
	group_4_rdata_en         ,
	group_4_rdata_valid      ,
	group_4_strobe_out_in    ,
	group_4_strobe_out_en    ,
	
	group_5_oe_from_core     ,
	group_5_data_from_core   ,
	group_5_data_to_core     ,
	group_5_rdata_en         ,
	group_5_rdata_valid      ,
	group_5_strobe_out_in    ,
	group_5_strobe_out_en    ,
	
	group_6_oe_from_core     ,
	group_6_data_from_core   ,
	group_6_data_to_core     ,
	group_6_rdata_en         ,
	group_6_rdata_valid      ,
	group_6_strobe_out_in    ,
	group_6_strobe_out_en    ,
	
	group_7_oe_from_core     ,
	group_7_data_from_core   ,
	group_7_data_to_core     ,
	group_7_rdata_en         ,
	group_7_rdata_valid      ,
	group_7_strobe_out_in    ,
	group_7_strobe_out_en    ,
	
	group_8_oe_from_core     ,
	group_8_data_from_core   ,
	group_8_data_to_core     ,
	group_8_rdata_en         ,
	group_8_rdata_valid      ,
	group_8_strobe_out_in    ,
	group_8_strobe_out_en    ,
	
	group_9_oe_from_core     ,
	group_9_data_from_core   ,
	group_9_data_to_core     ,
	group_9_rdata_en         ,
	group_9_rdata_valid      ,
	group_9_strobe_out_in    ,
	group_9_strobe_out_en    ,
	
	group_10_oe_from_core    ,
	group_10_data_from_core  ,
	group_10_data_to_core    ,
	group_10_rdata_en        ,
	group_10_rdata_valid     ,
	group_10_strobe_out_in   ,
	group_10_strobe_out_en   ,
	
	group_11_oe_from_core    ,
	group_11_data_from_core  ,
	group_11_data_to_core    ,
	group_11_rdata_en        ,
	group_11_rdata_valid     ,
	group_11_strobe_out_in   ,
	group_11_strobe_out_en   ,
	
	// I/Os
	group_0_data_out     ,
	group_0_data_in      ,
	group_0_data_io      ,
	group_0_strobe_out   ,
	group_0_strobe_out_n ,
	group_0_strobe_in    ,
	group_0_strobe_in_n  ,
	group_0_strobe_io    ,
	group_0_strobe_io_n  ,

	group_1_data_out     ,
	group_1_data_in      ,
	group_1_data_io      ,
	group_1_strobe_out   ,
	group_1_strobe_out_n ,
	group_1_strobe_in    ,
	group_1_strobe_in_n  ,
	group_1_strobe_io    ,
	group_1_strobe_io_n  ,

	group_2_data_out     ,
	group_2_data_in      ,
	group_2_data_io      ,
	group_2_strobe_out   ,
	group_2_strobe_out_n ,
	group_2_strobe_in    ,
	group_2_strobe_in_n  ,
	group_2_strobe_io    ,
	group_2_strobe_io_n  ,

	group_3_data_out     ,
	group_3_data_in      ,
	group_3_data_io      ,
	group_3_strobe_out   ,
	group_3_strobe_out_n ,
	group_3_strobe_in    ,
	group_3_strobe_in_n  ,
	group_3_strobe_io    ,
	group_3_strobe_io_n  ,

	group_4_data_out     ,
	group_4_data_in      ,
	group_4_data_io      ,
	group_4_strobe_out   ,
	group_4_strobe_out_n ,
	group_4_strobe_in    ,
	group_4_strobe_in_n  ,
	group_4_strobe_io    ,
	group_4_strobe_io_n  ,

	group_5_data_out     ,
	group_5_data_in      ,
	group_5_data_io      ,
	group_5_strobe_out   ,
	group_5_strobe_out_n ,
	group_5_strobe_in    ,
	group_5_strobe_in_n  ,
	group_5_strobe_io    ,
	group_5_strobe_io_n  ,

	group_6_data_out     ,
	group_6_data_in      ,
	group_6_data_io      ,
	group_6_strobe_out   ,
	group_6_strobe_out_n ,
	group_6_strobe_in    ,
	group_6_strobe_in_n  ,
	group_6_strobe_io    ,
	group_6_strobe_io_n  ,

	group_7_data_out     ,
	group_7_data_in      ,
	group_7_data_io      ,
	group_7_strobe_out   ,
	group_7_strobe_out_n ,
	group_7_strobe_in    ,
	group_7_strobe_in_n  ,
	group_7_strobe_io    ,
	group_7_strobe_io_n  ,

	group_8_data_out     ,
	group_8_data_in      ,
	group_8_data_io      ,
	group_8_strobe_out   ,
	group_8_strobe_out_n ,
	group_8_strobe_in    ,
	group_8_strobe_in_n  ,
	group_8_strobe_io    ,
	group_8_strobe_io_n  ,

	group_9_data_out     ,
	group_9_data_in      ,
	group_9_data_io      ,
	group_9_strobe_out   ,
	group_9_strobe_out_n ,
	group_9_strobe_in    ,
	group_9_strobe_in_n  ,
	group_9_strobe_io    ,
	group_9_strobe_io_n  ,

	group_10_data_out     ,
	group_10_data_in      ,
	group_10_data_io      ,
	group_10_strobe_out   ,
	group_10_strobe_out_n ,
	group_10_strobe_in    ,
	group_10_strobe_in_n  ,
	group_10_strobe_io    ,
	group_10_strobe_io_n  ,

	group_11_data_out     ,
	group_11_data_in      ,
	group_11_data_io      ,
	group_11_strobe_out   ,
	group_11_strobe_out_n ,
	group_11_strobe_in    ,
	group_11_strobe_in_n  ,
	group_11_strobe_io    ,
	group_11_strobe_io_n 
	);

	////////////////////////////////////////////////////////////////////////////
	// Local Parameters
	////////////////////////////////////////////////////////////////////////////
	localparam string GROUP_PIN_TYPE             [0:11] = '{ GROUP_0_PIN_TYPE            ,
	                                                         GROUP_1_PIN_TYPE            ,
	                                                         GROUP_2_PIN_TYPE            ,
	                                                         GROUP_3_PIN_TYPE            ,
	                                                         GROUP_4_PIN_TYPE            ,
	                                                         GROUP_5_PIN_TYPE            ,
	                                                         GROUP_6_PIN_TYPE            ,
	                                                         GROUP_7_PIN_TYPE            ,
	                                                         GROUP_8_PIN_TYPE            ,
	                                                         GROUP_9_PIN_TYPE            ,
	                                                         GROUP_10_PIN_TYPE           ,
	                                                         GROUP_11_PIN_TYPE           };
	localparam integer GROUP_PIN_WIDTH           [0:11] = '{ GROUP_0_PIN_WIDTH           ,
	                                                         GROUP_1_PIN_WIDTH           ,
	                                                         GROUP_2_PIN_WIDTH           ,
	                                                         GROUP_3_PIN_WIDTH           ,
	                                                         GROUP_4_PIN_WIDTH           ,
	                                                         GROUP_5_PIN_WIDTH           ,
	                                                         GROUP_6_PIN_WIDTH           ,
	                                                         GROUP_7_PIN_WIDTH           ,
	                                                         GROUP_8_PIN_WIDTH           ,
	                                                         GROUP_9_PIN_WIDTH           ,
	                                                         GROUP_10_PIN_WIDTH          ,
	                                                         GROUP_11_PIN_WIDTH          };
	localparam string GROUP_DDR_SDR_MODE         [0:11] = '{ GROUP_0_DDR_SDR_MODE        ,
	                                                         GROUP_1_DDR_SDR_MODE        ,
	                                                         GROUP_2_DDR_SDR_MODE        ,
	                                                         GROUP_3_DDR_SDR_MODE        ,
	                                                         GROUP_4_DDR_SDR_MODE        ,
	                                                         GROUP_5_DDR_SDR_MODE        ,
	                                                         GROUP_6_DDR_SDR_MODE        ,
	                                                         GROUP_7_DDR_SDR_MODE        ,
	                                                         GROUP_8_DDR_SDR_MODE        ,
	                                                         GROUP_9_DDR_SDR_MODE        ,
	                                                         GROUP_10_DDR_SDR_MODE       ,
	                                                         GROUP_11_DDR_SDR_MODE       };
	localparam integer GROUP_USE_DIFF_STROBE     [0:11] = '{ GROUP_0_USE_DIFF_STROBE     ,
	                                                         GROUP_1_USE_DIFF_STROBE     ,
	                                                         GROUP_2_USE_DIFF_STROBE     ,
	                                                         GROUP_3_USE_DIFF_STROBE     ,
	                                                         GROUP_4_USE_DIFF_STROBE     ,
	                                                         GROUP_5_USE_DIFF_STROBE     ,
	                                                         GROUP_6_USE_DIFF_STROBE     ,
	                                                         GROUP_7_USE_DIFF_STROBE     ,
	                                                         GROUP_8_USE_DIFF_STROBE     ,
	                                                         GROUP_9_USE_DIFF_STROBE     ,
	                                                         GROUP_10_USE_DIFF_STROBE    ,
	                                                         GROUP_11_USE_DIFF_STROBE    };
	localparam integer GROUP_READ_LATENCY        [0:11] = '{ GROUP_0_READ_LATENCY        ,
	                                                         GROUP_1_READ_LATENCY        ,
	                                                         GROUP_2_READ_LATENCY        ,
	                                                         GROUP_3_READ_LATENCY        ,
	                                                         GROUP_4_READ_LATENCY        ,
	                                                         GROUP_5_READ_LATENCY        ,
	                                                         GROUP_6_READ_LATENCY        ,
	                                                         GROUP_7_READ_LATENCY        ,
	                                                         GROUP_8_READ_LATENCY        ,
	                                                         GROUP_9_READ_LATENCY        ,
	                                                         GROUP_10_READ_LATENCY       ,
	                                                         GROUP_11_READ_LATENCY       };
	localparam integer GROUP_USE_INTERNAL_CAPTURE_STROBE [0:11] = '{ GROUP_0_USE_INTERNAL_CAPTURE_STROBE ,
	                                                                 GROUP_1_USE_INTERNAL_CAPTURE_STROBE ,
	                                                                 GROUP_2_USE_INTERNAL_CAPTURE_STROBE ,
	                                                                 GROUP_3_USE_INTERNAL_CAPTURE_STROBE ,
	                                                                 GROUP_4_USE_INTERNAL_CAPTURE_STROBE ,
	                                                                 GROUP_5_USE_INTERNAL_CAPTURE_STROBE ,
	                                                                 GROUP_6_USE_INTERNAL_CAPTURE_STROBE ,
	                                                                 GROUP_7_USE_INTERNAL_CAPTURE_STROBE ,
	                                                                 GROUP_8_USE_INTERNAL_CAPTURE_STROBE ,
	                                                                 GROUP_9_USE_INTERNAL_CAPTURE_STROBE ,
	                                                                 GROUP_10_USE_INTERNAL_CAPTURE_STROBE,
	                                                                 GROUP_11_USE_INTERNAL_CAPTURE_STROBE};
	localparam integer GROUP_CAPTURE_PHASE_SHIFT [0:11] = '{ GROUP_0_CAPTURE_PHASE_SHIFT ,
	                                                         GROUP_1_CAPTURE_PHASE_SHIFT ,
	                                                         GROUP_2_CAPTURE_PHASE_SHIFT ,
	                                                         GROUP_3_CAPTURE_PHASE_SHIFT ,
	                                                         GROUP_4_CAPTURE_PHASE_SHIFT ,
	                                                         GROUP_5_CAPTURE_PHASE_SHIFT ,
	                                                         GROUP_6_CAPTURE_PHASE_SHIFT ,
	                                                         GROUP_7_CAPTURE_PHASE_SHIFT ,
	                                                         GROUP_8_CAPTURE_PHASE_SHIFT ,
	                                                         GROUP_9_CAPTURE_PHASE_SHIFT ,
	                                                         GROUP_10_CAPTURE_PHASE_SHIFT,
	                                                         GROUP_11_CAPTURE_PHASE_SHIFT};
	localparam integer GROUP_WRITE_LATENCY       [0:11] = '{ GROUP_0_WRITE_LATENCY       ,
	                                                         GROUP_1_WRITE_LATENCY       ,
	                                                         GROUP_2_WRITE_LATENCY       ,
	                                                         GROUP_3_WRITE_LATENCY       ,
	                                                         GROUP_4_WRITE_LATENCY       ,
	                                                         GROUP_5_WRITE_LATENCY       ,
	                                                         GROUP_6_WRITE_LATENCY       ,
	                                                         GROUP_7_WRITE_LATENCY       ,
	                                                         GROUP_8_WRITE_LATENCY       ,
	                                                         GROUP_9_WRITE_LATENCY       ,
	                                                         GROUP_10_WRITE_LATENCY      ,
	                                                         GROUP_11_WRITE_LATENCY      };
	localparam integer GROUP_USE_OUTPUT_STROBE   [0:11] = '{ GROUP_0_USE_OUTPUT_STROBE   ,
	                                                         GROUP_1_USE_OUTPUT_STROBE   ,
	                                                         GROUP_2_USE_OUTPUT_STROBE   ,
	                                                         GROUP_3_USE_OUTPUT_STROBE   ,
	                                                         GROUP_4_USE_OUTPUT_STROBE   ,
	                                                         GROUP_5_USE_OUTPUT_STROBE   ,
	                                                         GROUP_6_USE_OUTPUT_STROBE   ,
	                                                         GROUP_7_USE_OUTPUT_STROBE   ,
	                                                         GROUP_8_USE_OUTPUT_STROBE   ,
	                                                         GROUP_9_USE_OUTPUT_STROBE   ,
	                                                         GROUP_10_USE_OUTPUT_STROBE  ,
	                                                         GROUP_11_USE_OUTPUT_STROBE  };
	localparam integer GROUP_OUTPUT_STROBE_PHASE [0:11] = '{ GROUP_0_OUTPUT_STROBE_PHASE ,
	                                                         GROUP_1_OUTPUT_STROBE_PHASE ,
	                                                         GROUP_2_OUTPUT_STROBE_PHASE ,
	                                                         GROUP_3_OUTPUT_STROBE_PHASE ,
	                                                         GROUP_4_OUTPUT_STROBE_PHASE ,
	                                                         GROUP_5_OUTPUT_STROBE_PHASE ,
	                                                         GROUP_6_OUTPUT_STROBE_PHASE ,
	                                                         GROUP_7_OUTPUT_STROBE_PHASE ,
	                                                         GROUP_8_OUTPUT_STROBE_PHASE ,
	                                                         GROUP_9_OUTPUT_STROBE_PHASE ,
	                                                         GROUP_10_OUTPUT_STROBE_PHASE,
	                                                         GROUP_11_OUTPUT_STROBE_PHASE};
	// Core Interface Widths
	localparam integer RATE_MULT =  (PHYLITE_RATE_ENUM == "RATE_IN_QUARTER") ? 4 :
	                                (PHYLITE_RATE_ENUM == "RATE_IN_HALF")    ? 2 :
	                                                                           1 ;

	localparam integer GROUP_DDR_MULT [0:11] = '{ (GROUP_0_DDR_SDR_MODE == "DDR")  ? 2 : 1,
	                                              (GROUP_1_DDR_SDR_MODE == "DDR")  ? 2 : 1,
	                                              (GROUP_2_DDR_SDR_MODE == "DDR")  ? 2 : 1,
	                                              (GROUP_3_DDR_SDR_MODE == "DDR")  ? 2 : 1,
	                                              (GROUP_4_DDR_SDR_MODE == "DDR")  ? 2 : 1,
	                                              (GROUP_5_DDR_SDR_MODE == "DDR")  ? 2 : 1,
	                                              (GROUP_6_DDR_SDR_MODE == "DDR")  ? 2 : 1,
	                                              (GROUP_7_DDR_SDR_MODE == "DDR")  ? 2 : 1,
	                                              (GROUP_8_DDR_SDR_MODE == "DDR")  ? 2 : 1,
	                                              (GROUP_9_DDR_SDR_MODE == "DDR")  ? 2 : 1,
	                                              (GROUP_10_DDR_SDR_MODE == "DDR") ? 2 : 1,
	                                              (GROUP_11_DDR_SDR_MODE == "DDR") ? 2 : 1 };

	localparam integer GROUP_PIN_DATA_WIDTH [0:11] = '{ RATE_MULT * GROUP_DDR_MULT[0],
	                                                    RATE_MULT * GROUP_DDR_MULT[1],
	                                                    RATE_MULT * GROUP_DDR_MULT[2],
	                                                    RATE_MULT * GROUP_DDR_MULT[3],
	                                                    RATE_MULT * GROUP_DDR_MULT[4],
	                                                    RATE_MULT * GROUP_DDR_MULT[5],
	                                                    RATE_MULT * GROUP_DDR_MULT[6],
	                                                    RATE_MULT * GROUP_DDR_MULT[7],
	                                                    RATE_MULT * GROUP_DDR_MULT[8],
	                                                    RATE_MULT * GROUP_DDR_MULT[9],
	                                                    RATE_MULT * GROUP_DDR_MULT[10],
	                                                    RATE_MULT * GROUP_DDR_MULT[11] };

	localparam integer GROUP_DATA_WIDTH [0:11] = '{ GROUP_0_PIN_WIDTH  * GROUP_PIN_DATA_WIDTH[0],
	                                                GROUP_1_PIN_WIDTH  * GROUP_PIN_DATA_WIDTH[1],
	                                                GROUP_2_PIN_WIDTH  * GROUP_PIN_DATA_WIDTH[2],
	                                                GROUP_3_PIN_WIDTH  * GROUP_PIN_DATA_WIDTH[3],
	                                                GROUP_4_PIN_WIDTH  * GROUP_PIN_DATA_WIDTH[4],
	                                                GROUP_5_PIN_WIDTH  * GROUP_PIN_DATA_WIDTH[5],
	                                                GROUP_6_PIN_WIDTH  * GROUP_PIN_DATA_WIDTH[6],
	                                                GROUP_7_PIN_WIDTH  * GROUP_PIN_DATA_WIDTH[7],
	                                                GROUP_8_PIN_WIDTH  * GROUP_PIN_DATA_WIDTH[8],
	                                                GROUP_9_PIN_WIDTH  * GROUP_PIN_DATA_WIDTH[9],
	                                                GROUP_10_PIN_WIDTH * GROUP_PIN_DATA_WIDTH[10],
	                                                GROUP_11_PIN_WIDTH * GROUP_PIN_DATA_WIDTH[11] };

	localparam integer GROUP_PIN_OE_WIDTH [0:11] = '{ RATE_MULT,
	                                                  RATE_MULT,
	                                                  RATE_MULT,
	                                                  RATE_MULT,
	                                                  RATE_MULT,
	                                                  RATE_MULT,
	                                                  RATE_MULT,
	                                                  RATE_MULT,
	                                                  RATE_MULT,
	                                                  RATE_MULT,
	                                                  RATE_MULT,
	                                                  RATE_MULT };

	localparam integer GROUP_OE_WIDTH [0:11] =  '{ GROUP_0_PIN_WIDTH  * GROUP_PIN_OE_WIDTH[0],
	                                               GROUP_1_PIN_WIDTH  * GROUP_PIN_OE_WIDTH[1],
	                                               GROUP_2_PIN_WIDTH  * GROUP_PIN_OE_WIDTH[2],
	                                               GROUP_3_PIN_WIDTH  * GROUP_PIN_OE_WIDTH[3],
	                                               GROUP_4_PIN_WIDTH  * GROUP_PIN_OE_WIDTH[4],
	                                               GROUP_5_PIN_WIDTH  * GROUP_PIN_OE_WIDTH[5],
	                                               GROUP_6_PIN_WIDTH  * GROUP_PIN_OE_WIDTH[6],
	                                               GROUP_7_PIN_WIDTH  * GROUP_PIN_OE_WIDTH[7],
	                                               GROUP_8_PIN_WIDTH  * GROUP_PIN_OE_WIDTH[8],
	                                               GROUP_9_PIN_WIDTH  * GROUP_PIN_OE_WIDTH[9],
	                                               GROUP_10_PIN_WIDTH * GROUP_PIN_OE_WIDTH[10],
	                                               GROUP_11_PIN_WIDTH * GROUP_PIN_OE_WIDTH[11] };

	localparam integer GROUP_STROBE_PIN_DATA_WIDTH [0:11] = '{ 2 * RATE_MULT,
	                                                           2 * RATE_MULT,
	                                                           2 * RATE_MULT,
	                                                           2 * RATE_MULT,
	                                                           2 * RATE_MULT,
	                                                           2 * RATE_MULT,
	                                                           2 * RATE_MULT,
	                                                           2 * RATE_MULT,
	                                                           2 * RATE_MULT,
	                                                           2 * RATE_MULT,
	                                                           2 * RATE_MULT,
	                                                           2 * RATE_MULT };

	localparam integer GROUP_OUTPUT_STROBE_DATA_WIDTH [0:11] = '{ GROUP_STROBE_PIN_DATA_WIDTH[0],
	                                                              GROUP_STROBE_PIN_DATA_WIDTH[1],
	                                                              GROUP_STROBE_PIN_DATA_WIDTH[2],
	                                                              GROUP_STROBE_PIN_DATA_WIDTH[3],
	                                                              GROUP_STROBE_PIN_DATA_WIDTH[4],
	                                                              GROUP_STROBE_PIN_DATA_WIDTH[5],
	                                                              GROUP_STROBE_PIN_DATA_WIDTH[6],
	                                                              GROUP_STROBE_PIN_DATA_WIDTH[7],
	                                                              GROUP_STROBE_PIN_DATA_WIDTH[8],
	                                                              GROUP_STROBE_PIN_DATA_WIDTH[9],
	                                                              GROUP_STROBE_PIN_DATA_WIDTH[10],
	                                                              GROUP_STROBE_PIN_DATA_WIDTH[11] };

	localparam integer GROUP_STROBE_PIN_OE_WIDTH [0:11] = '{ RATE_MULT,
	                                                         RATE_MULT,
	                                                         RATE_MULT,
	                                                         RATE_MULT,
	                                                         RATE_MULT,
	                                                         RATE_MULT,
	                                                         RATE_MULT,
	                                                         RATE_MULT,
	                                                         RATE_MULT,
	                                                         RATE_MULT,
	                                                         RATE_MULT,
	                                                         RATE_MULT };

	localparam integer GROUP_OUTPUT_STROBE_OE_WIDTH [0:11] = '{ GROUP_STROBE_PIN_OE_WIDTH[0],
	                                                            GROUP_STROBE_PIN_OE_WIDTH[1],
	                                                            GROUP_STROBE_PIN_OE_WIDTH[2],
	                                                            GROUP_STROBE_PIN_OE_WIDTH[3],
	                                                            GROUP_STROBE_PIN_OE_WIDTH[4],
	                                                            GROUP_STROBE_PIN_OE_WIDTH[5],
	                                                            GROUP_STROBE_PIN_OE_WIDTH[6],
	                                                            GROUP_STROBE_PIN_OE_WIDTH[7],
	                                                            GROUP_STROBE_PIN_OE_WIDTH[8],
	                                                            GROUP_STROBE_PIN_OE_WIDTH[9],
	                                                            GROUP_STROBE_PIN_OE_WIDTH[10],
	                                                            GROUP_STROBE_PIN_OE_WIDTH[11] };


	////////////////////////////////////////////////////////////////////////////
	// Port Declarations
	////////////////////////////////////////////////////////////////////////////
	// Clock and Reset Ports
	input  ref_clk      ;
	input  reset_n      ;
	output pll_locked   ;
	output core_clk_out ;

	// Avalon Ports
	input         avl_clk       ;
	input         avl_read      ;
	input         avl_write     ;
	input  [31:0] avl_writedata ;
	input  [19:0] avl_address   ;
	output [31:0] avl_readdata  ;

	// Core Interface
	input                  [GROUP_OE_WIDTH[0] - 1 : 0] group_0_oe_from_core     ;
	input                [GROUP_DATA_WIDTH[0] - 1 : 0] group_0_data_from_core   ;
	output               [GROUP_DATA_WIDTH[0] - 1 : 0] group_0_data_to_core     ;
	input                          [RATE_MULT - 1 : 0] group_0_rdata_en         ;
	output                         [RATE_MULT - 1 : 0] group_0_rdata_valid      ;
	input  [GROUP_OUTPUT_STROBE_DATA_WIDTH[0] - 1 : 0] group_0_strobe_out_in    ;
	input    [GROUP_OUTPUT_STROBE_OE_WIDTH[0] - 1 : 0] group_0_strobe_out_en    ;
	
	input                  [GROUP_OE_WIDTH[1] - 1 : 0] group_1_oe_from_core     ;
	input                [GROUP_DATA_WIDTH[1] - 1 : 0] group_1_data_from_core   ;
	output               [GROUP_DATA_WIDTH[1] - 1 : 0] group_1_data_to_core     ;
	input                          [RATE_MULT - 1 : 0] group_1_rdata_en         ;
	output                         [RATE_MULT - 1 : 0] group_1_rdata_valid      ;
	input  [GROUP_OUTPUT_STROBE_DATA_WIDTH[1] - 1 : 0] group_1_strobe_out_in    ;
	input    [GROUP_OUTPUT_STROBE_OE_WIDTH[1] - 1 : 0] group_1_strobe_out_en    ;
	
	input                  [GROUP_OE_WIDTH[2] - 1 : 0] group_2_oe_from_core     ;
	input                [GROUP_DATA_WIDTH[2] - 1 : 0] group_2_data_from_core   ;
	output               [GROUP_DATA_WIDTH[2] - 1 : 0] group_2_data_to_core     ;
	input                          [RATE_MULT - 1 : 0] group_2_rdata_en         ;
	output                         [RATE_MULT - 1 : 0] group_2_rdata_valid      ;
	input  [GROUP_OUTPUT_STROBE_DATA_WIDTH[2] - 1 : 0] group_2_strobe_out_in    ;
	input    [GROUP_OUTPUT_STROBE_OE_WIDTH[2] - 1 : 0] group_2_strobe_out_en    ;
	
	input                  [GROUP_OE_WIDTH[3] - 1 : 0] group_3_oe_from_core     ;
	input                [GROUP_DATA_WIDTH[3] - 1 : 0] group_3_data_from_core   ;
	output               [GROUP_DATA_WIDTH[3] - 1 : 0] group_3_data_to_core     ;
	input                          [RATE_MULT - 1 : 0] group_3_rdata_en         ;
	output                         [RATE_MULT - 1 : 0] group_3_rdata_valid      ;
	input  [GROUP_OUTPUT_STROBE_DATA_WIDTH[3] - 1 : 0] group_3_strobe_out_in    ;
	input    [GROUP_OUTPUT_STROBE_OE_WIDTH[3] - 1 : 0] group_3_strobe_out_en    ;
	
	input                  [GROUP_OE_WIDTH[4] - 1 : 0] group_4_oe_from_core     ;
	input                [GROUP_DATA_WIDTH[4] - 1 : 0] group_4_data_from_core   ;
	output               [GROUP_DATA_WIDTH[4] - 1 : 0] group_4_data_to_core     ;
	input                          [RATE_MULT - 1 : 0] group_4_rdata_en         ;
	output                         [RATE_MULT - 1 : 0] group_4_rdata_valid      ;
	input  [GROUP_OUTPUT_STROBE_DATA_WIDTH[4] - 1 : 0] group_4_strobe_out_in    ;
	input    [GROUP_OUTPUT_STROBE_OE_WIDTH[4] - 1 : 0] group_4_strobe_out_en    ;
	
	input                  [GROUP_OE_WIDTH[5] - 1 : 0] group_5_oe_from_core     ;
	input                [GROUP_DATA_WIDTH[5] - 1 : 0] group_5_data_from_core   ;
	output               [GROUP_DATA_WIDTH[5] - 1 : 0] group_5_data_to_core     ;
	input                          [RATE_MULT - 1 : 0] group_5_rdata_en         ;
	output                         [RATE_MULT - 1 : 0] group_5_rdata_valid      ;
	input  [GROUP_OUTPUT_STROBE_DATA_WIDTH[5] - 1 : 0] group_5_strobe_out_in    ;
	input    [GROUP_OUTPUT_STROBE_OE_WIDTH[5] - 1 : 0] group_5_strobe_out_en    ;
	
	input                  [GROUP_OE_WIDTH[6] - 1 : 0] group_6_oe_from_core     ;
	input                [GROUP_DATA_WIDTH[6] - 1 : 0] group_6_data_from_core   ;
	output               [GROUP_DATA_WIDTH[6] - 1 : 0] group_6_data_to_core     ;
	input                          [RATE_MULT - 1 : 0] group_6_rdata_en         ;
	output                         [RATE_MULT - 1 : 0] group_6_rdata_valid      ;
	input  [GROUP_OUTPUT_STROBE_DATA_WIDTH[6] - 1 : 0] group_6_strobe_out_in    ;
	input    [GROUP_OUTPUT_STROBE_OE_WIDTH[6] - 1 : 0] group_6_strobe_out_en    ;
	
	input                  [GROUP_OE_WIDTH[7] - 1 : 0] group_7_oe_from_core     ;
	input                [GROUP_DATA_WIDTH[7] - 1 : 0] group_7_data_from_core   ;
	output               [GROUP_DATA_WIDTH[7] - 1 : 0] group_7_data_to_core     ;
	input                          [RATE_MULT - 1 : 0] group_7_rdata_en         ;
	output                         [RATE_MULT - 1 : 0] group_7_rdata_valid      ;
	input  [GROUP_OUTPUT_STROBE_DATA_WIDTH[7] - 1 : 0] group_7_strobe_out_in    ;
	input    [GROUP_OUTPUT_STROBE_OE_WIDTH[7] - 1 : 0] group_7_strobe_out_en    ;
	
	input                  [GROUP_OE_WIDTH[8] - 1 : 0] group_8_oe_from_core     ;
	input                [GROUP_DATA_WIDTH[8] - 1 : 0] group_8_data_from_core   ;
	output               [GROUP_DATA_WIDTH[8] - 1 : 0] group_8_data_to_core     ;
	input                          [RATE_MULT - 1 : 0] group_8_rdata_en         ;
	output                         [RATE_MULT - 1 : 0] group_8_rdata_valid      ;
	input  [GROUP_OUTPUT_STROBE_DATA_WIDTH[8] - 1 : 0] group_8_strobe_out_in    ;
	input    [GROUP_OUTPUT_STROBE_OE_WIDTH[8] - 1 : 0] group_8_strobe_out_en    ;
	
	input                  [GROUP_OE_WIDTH[9] - 1 : 0] group_9_oe_from_core     ;
	input                [GROUP_DATA_WIDTH[9] - 1 : 0] group_9_data_from_core   ;
	output               [GROUP_DATA_WIDTH[9] - 1 : 0] group_9_data_to_core     ;
	input                          [RATE_MULT - 1 : 0] group_9_rdata_en         ;
	output                         [RATE_MULT - 1 : 0] group_9_rdata_valid      ;
	input  [GROUP_OUTPUT_STROBE_DATA_WIDTH[9] - 1 : 0] group_9_strobe_out_in    ;
	input    [GROUP_OUTPUT_STROBE_OE_WIDTH[9] - 1 : 0] group_9_strobe_out_en    ;
	
	input                  [GROUP_OE_WIDTH[10] - 1 : 0] group_10_oe_from_core     ;
	input                [GROUP_DATA_WIDTH[10] - 1 : 0] group_10_data_from_core   ;
	output               [GROUP_DATA_WIDTH[10] - 1 : 0] group_10_data_to_core     ;
	input                           [RATE_MULT - 1 : 0] group_10_rdata_en         ;
	output                          [RATE_MULT - 1 : 0] group_10_rdata_valid      ;
	input  [GROUP_OUTPUT_STROBE_DATA_WIDTH[10] - 1 : 0] group_10_strobe_out_in    ;
	input    [GROUP_OUTPUT_STROBE_OE_WIDTH[10] - 1 : 0] group_10_strobe_out_en    ;
	
	input                  [GROUP_OE_WIDTH[11] - 1 : 0] group_11_oe_from_core     ;
	input                [GROUP_DATA_WIDTH[11] - 1 : 0] group_11_data_from_core   ;
	output               [GROUP_DATA_WIDTH[11] - 1 : 0] group_11_data_to_core     ;
	input                           [RATE_MULT - 1 : 0] group_11_rdata_en         ;
	output                          [RATE_MULT - 1 : 0] group_11_rdata_valid      ;
	input  [GROUP_OUTPUT_STROBE_DATA_WIDTH[11] - 1 : 0] group_11_strobe_out_in    ;
	input    [GROUP_OUTPUT_STROBE_OE_WIDTH[11] - 1 : 0] group_11_strobe_out_en    ;
	
	// I/Os
	output [GROUP_0_PIN_WIDTH - 1 : 0] group_0_data_out     ;
	input  [GROUP_0_PIN_WIDTH - 1 : 0] group_0_data_in      ;
	inout  [GROUP_0_PIN_WIDTH - 1 : 0] group_0_data_io      ;
	output                             group_0_strobe_out   ;
	output                             group_0_strobe_out_n ;
	input                              group_0_strobe_in    ;
	input                              group_0_strobe_in_n  ;
	inout                              group_0_strobe_io    ;
	inout                              group_0_strobe_io_n  ;

	output [GROUP_1_PIN_WIDTH - 1 : 0] group_1_data_out     ;
	input  [GROUP_1_PIN_WIDTH - 1 : 0] group_1_data_in      ;
	inout  [GROUP_1_PIN_WIDTH - 1 : 0] group_1_data_io      ;
	output                             group_1_strobe_out   ;
	output                             group_1_strobe_out_n ;
	input                              group_1_strobe_in    ;
	input                              group_1_strobe_in_n  ;
	inout                              group_1_strobe_io    ;
	inout                              group_1_strobe_io_n  ;

	output [GROUP_2_PIN_WIDTH - 1 : 0] group_2_data_out     ;
	input  [GROUP_2_PIN_WIDTH - 1 : 0] group_2_data_in      ;
	inout  [GROUP_2_PIN_WIDTH - 1 : 0] group_2_data_io      ;
	output                             group_2_strobe_out   ;
	output                             group_2_strobe_out_n ;
	input                              group_2_strobe_in    ;
	input                              group_2_strobe_in_n  ;
	inout                              group_2_strobe_io    ;
	inout                              group_2_strobe_io_n  ;

	output [GROUP_3_PIN_WIDTH - 1 : 0] group_3_data_out     ;
	input  [GROUP_3_PIN_WIDTH - 1 : 0] group_3_data_in      ;
	inout  [GROUP_3_PIN_WIDTH - 1 : 0] group_3_data_io      ;
	output                             group_3_strobe_out   ;
	output                             group_3_strobe_out_n ;
	input                              group_3_strobe_in    ;
	input                              group_3_strobe_in_n  ;
	inout                              group_3_strobe_io    ;
	inout                              group_3_strobe_io_n  ;

	output [GROUP_4_PIN_WIDTH - 1 : 0] group_4_data_out     ;
	input  [GROUP_4_PIN_WIDTH - 1 : 0] group_4_data_in      ;
	inout  [GROUP_4_PIN_WIDTH - 1 : 0] group_4_data_io      ;
	output                             group_4_strobe_out   ;
	output                             group_4_strobe_out_n ;
	input                              group_4_strobe_in    ;
	input                              group_4_strobe_in_n  ;
	inout                              group_4_strobe_io    ;
	inout                              group_4_strobe_io_n  ;

	output [GROUP_5_PIN_WIDTH - 1 : 0] group_5_data_out     ;
	input  [GROUP_5_PIN_WIDTH - 1 : 0] group_5_data_in      ;
	inout  [GROUP_5_PIN_WIDTH - 1 : 0] group_5_data_io      ;
	output                             group_5_strobe_out   ;
	output                             group_5_strobe_out_n ;
	input                              group_5_strobe_in    ;
	input                              group_5_strobe_in_n  ;
	inout                              group_5_strobe_io    ;
	inout                              group_5_strobe_io_n  ;

	output [GROUP_6_PIN_WIDTH - 1 : 0] group_6_data_out     ;
	input  [GROUP_6_PIN_WIDTH - 1 : 0] group_6_data_in      ;
	inout  [GROUP_6_PIN_WIDTH - 1 : 0] group_6_data_io      ;
	output                             group_6_strobe_out   ;
	output                             group_6_strobe_out_n ;
	input                              group_6_strobe_in    ;
	input                              group_6_strobe_in_n  ;
	inout                              group_6_strobe_io    ;
	inout                              group_6_strobe_io_n  ;

	output [GROUP_7_PIN_WIDTH - 1 : 0] group_7_data_out     ;
	input  [GROUP_7_PIN_WIDTH - 1 : 0] group_7_data_in      ;
	inout  [GROUP_7_PIN_WIDTH - 1 : 0] group_7_data_io      ;
	output                             group_7_strobe_out   ;
	output                             group_7_strobe_out_n ;
	input                              group_7_strobe_in    ;
	input                              group_7_strobe_in_n  ;
	inout                              group_7_strobe_io    ;
	inout                              group_7_strobe_io_n  ;

	output [GROUP_8_PIN_WIDTH - 1 : 0] group_8_data_out     ;
	input  [GROUP_8_PIN_WIDTH - 1 : 0] group_8_data_in      ;
	inout  [GROUP_8_PIN_WIDTH - 1 : 0] group_8_data_io      ;
	output                             group_8_strobe_out   ;
	output                             group_8_strobe_out_n ;
	input                              group_8_strobe_in    ;
	input                              group_8_strobe_in_n  ;
	inout                              group_8_strobe_io    ;
	inout                              group_8_strobe_io_n  ;

	output [GROUP_9_PIN_WIDTH - 1 : 0] group_9_data_out     ;
	input  [GROUP_9_PIN_WIDTH - 1 : 0] group_9_data_in      ;
	inout  [GROUP_9_PIN_WIDTH - 1 : 0] group_9_data_io      ;
	output                             group_9_strobe_out   ;
	output                             group_9_strobe_out_n ;
	input                              group_9_strobe_in    ;
	input                              group_9_strobe_in_n  ;
	inout                              group_9_strobe_io    ;
	inout                              group_9_strobe_io_n  ;

	output [GROUP_10_PIN_WIDTH - 1 : 0] group_10_data_out     ;
	input  [GROUP_10_PIN_WIDTH - 1 : 0] group_10_data_in      ;
	inout  [GROUP_10_PIN_WIDTH - 1 : 0] group_10_data_io      ;
	output                              group_10_strobe_out   ;
	output                              group_10_strobe_out_n ;
	input                               group_10_strobe_in    ;
	input                               group_10_strobe_in_n  ;
	inout                               group_10_strobe_io    ;
	inout                               group_10_strobe_io_n  ;

	output [GROUP_11_PIN_WIDTH - 1 : 0] group_11_data_out     ;
	input  [GROUP_11_PIN_WIDTH - 1 : 0] group_11_data_in      ;
	inout  [GROUP_11_PIN_WIDTH - 1 : 0] group_11_data_io      ;
	output                              group_11_strobe_out   ;
	output                              group_11_strobe_out_n ;
	input                               group_11_strobe_in    ;
	input                               group_11_strobe_in_n  ;
	inout                               group_11_strobe_io    ;
	inout                               group_11_strobe_io_n  ;

	////////////////////////////////////////////////////////////////////////////
	// Wire Declarations
	////////////////////////////////////////////////////////////////////////////
	// PLL
	wire [1:0] phy_clk     ;
	wire [7:0] phy_clk_phs ;
	wire       dll_ref_clk ;
	
	// IO_AUX
	wire [54:0] cal_avl          [0:PHYLITE_NUM_GROUPS];
	wire [31:0] cal_avl_readdata [0:PHYLITE_NUM_GROUPS];

	// Inter-Tile Daisy Chains
	wire       broadcast_up   [0:PHYLITE_NUM_GROUPS];
	wire       broadcast_dn   [0:PHYLITE_NUM_GROUPS];
	wire [1:0] sync_up        [0:PHYLITE_NUM_GROUPS];
	wire [1:0] sync_dn        [0:PHYLITE_NUM_GROUPS];

	// Core Interface
	wire [191:0] oe_from_core   [0:PHYLITE_NUM_GROUPS-1];
	wire [383:0] data_from_core [0:PHYLITE_NUM_GROUPS-1];
	wire [383:0] data_to_core   [0:PHYLITE_NUM_GROUPS-1];
	wire   [3:0] rdata_en       [0:PHYLITE_NUM_GROUPS-1];
	wire   [3:0] rdata_valid    [0:PHYLITE_NUM_GROUPS-1];
	
	// I/Os
	wire [47:0] data_oe    [0:PHYLITE_NUM_GROUPS-1];
	wire [47:0] data_out   [0:PHYLITE_NUM_GROUPS-1];
	wire [47:0] data_in    [0:PHYLITE_NUM_GROUPS-1];
	wire [47:0] oct_enable [0:PHYLITE_NUM_GROUPS-1];

	// PLL FB
	wire phy_fb_clk_to_tile;
	wire phy_fb_clk_to_pll ;

	////////////////////////////////////////////////////////////////////////////
	// Tie-offs
	////////////////////////////////////////////////////////////////////////////
	// Tie-off Top of Daisy Chains
	assign cal_avl_readdata[PHYLITE_NUM_GROUPS] = 32'd0;
	assign broadcast_dn    [PHYLITE_NUM_GROUPS] = 1'b0;
	assign sync_dn         [PHYLITE_NUM_GROUPS] = 2'b0;

	// Tie-off Bottom of Daisy Chains
	assign broadcast_up[0] = 1'b0;
	assign sync_up     [0] = 2'b0;

	// PLL FB
	assign phy_fb_clk_to_pll = phy_fb_clk_to_tile;

	////////////////////////////////////////////////////////////////////////////
	// PLL instance
	////////////////////////////////////////////////////////////////////////////
	pll # (
		.PLL_REF_CLK_FREQ_PS_STR             (PLL_REF_CLK_FREQ_PS_STR),
		.PLL_VCO_FREQ_PS_STR                 (PLL_VCO_FREQ_PS_STR),
		.PLL_M_COUNTER_BYPASS_EN             (PLL_M_COUNTER_BYPASS_EN),
		.PLL_M_COUNTER_EVEN_DUTY_EN          (PLL_M_COUNTER_EVEN_DUTY_EN),
		.PLL_M_COUNTER_HIGH                  (PLL_M_COUNTER_HIGH),
		.PLL_M_COUNTER_LOW                   (PLL_M_COUNTER_LOW),
		.PLL_PHYCLK_0_FREQ_PS_STR            (PLL_PHYCLK_0_FREQ_PS_STR),
		.PLL_PHYCLK_0_BYPASS_EN              (PLL_PHYCLK_0_BYPASS_EN),
		.PLL_PHYCLK_0_HIGH                   (PLL_PHYCLK_0_HIGH),
		.PLL_PHYCLK_0_LOW                    (PLL_PHYCLK_0_LOW),
		.PLL_PHYCLK_1_FREQ_PS_STR            (PLL_PHYCLK_1_FREQ_PS_STR),
		.PLL_PHYCLK_1_BYPASS_EN              (PLL_PHYCLK_1_BYPASS_EN),
		.PLL_PHYCLK_1_HIGH                   (PLL_PHYCLK_1_HIGH),
		.PLL_PHYCLK_1_LOW                    (PLL_PHYCLK_1_LOW),
		.PLL_PHYCLK_FB_FREQ_PS_STR           (PLL_PHYCLK_FB_FREQ_PS_STR),
		.PLL_PHYCLK_FB_BYPASS_EN             (PLL_PHYCLK_FB_BYPASS_EN),
		.PLL_PHYCLK_FB_HIGH                  (PLL_PHYCLK_FB_HIGH),
		.PLL_PHYCLK_FB_LOW                   (PLL_PHYCLK_FB_LOW)
	) pll_inst (
		.global_reset_n_int (reset_n            ),     
		.pll_ref_clk_int    (ref_clk            ),     
		.pll_lock           (pll_locked         ),     
		.pll_dll_clk        (dll_ref_clk        ),     
		.phy_clk_phs        (phy_clk_phs        ),     
		.phy_clk            (phy_clk            ),     
		.phy_fb_clk_to_tile (phy_fb_clk_to_tile ),     
		.phy_fb_clk_to_pll  (phy_fb_clk_to_pll  ),     
		.hmc_clk            (                   ),     
		.core_clk_out       (core_clk_out       )

	);

	////////////////////////////////////////////////////////////////////////////
	// IO_AUX instance
	////////////////////////////////////////////////////////////////////////////
	generate
		if (PHYLITE_USE_DYNAMIC_RECONFIGURATION == 1) begin : io_aux_ctrl                                                                                                      
			twentynm_io_aux u_io_aux (
				.soft_nios_clk               (avl_clk      ),
				.soft_nios_read              (avl_read     ),
				.soft_nios_write             (avl_write    ),
				.soft_nios_write_data        (avl_writedata),
				.soft_nios_addr              (avl_address  ),
				.soft_nios_read_data         (avl_readdata ),
				.soft_nios_ctl_sig_bidir_in  (9'd0         ),
				.soft_nios_ctl_sig_bidir_out (             ),
				
				.uc_av_bus_clk        (cal_avl[0][54]      ),
				.uc_read              (cal_avl[0][53]      ),
				.uc_write             (cal_avl[0][52]      ),
				.uc_write_data        (cal_avl[0][51:20]   ),
				.uc_address           (cal_avl[0][19:0]    ),
				.uc_read_data         (cal_avl_readdata[0] )
			);
		end
		else begin
			assign cal_avl[0]   = 55'd0;
			assign avl_readdata = 32'd0;
		end
	endgenerate


	////////////////////////////////////////////////////////////////////////////
	// Generate Loop for data/strobe group instances
	////////////////////////////////////////////////////////////////////////////
	generate
		genvar grp_num;
		for(grp_num = 0; grp_num < PHYLITE_NUM_GROUPS; grp_num = grp_num + 1) begin : group_gen
			phylite_group_tile_20 #(
				.CORE_RATE                    (PHYLITE_RATE_ENUM                         ),
				.PLL_VCO_TO_MEM_CLK_FREQ_RATIO(PLL_VCO_TO_MEM_CLK_FREQ_RATIO             ),
				.PLL_VCO_FREQ_MHZ_INT         (PLL_VCO_FREQ_MHZ_INT                      ),
				.PIN_TYPE                     (GROUP_PIN_TYPE                   [grp_num]),
				.PIN_WIDTH                    (GROUP_PIN_WIDTH                  [grp_num]),
				.DDR_SDR_MODE                 (GROUP_DDR_SDR_MODE               [grp_num]),
				.USE_DIFF_STROBE              (GROUP_USE_DIFF_STROBE            [grp_num]),
				.READ_LATENCY                 (GROUP_READ_LATENCY               [grp_num]),
				.USE_INTERNAL_CAPTURE_STROBE  (GROUP_USE_INTERNAL_CAPTURE_STROBE[grp_num]),
				.CAPTURE_PHASE_SHIFT          (GROUP_CAPTURE_PHASE_SHIFT        [grp_num]),
				.WRITE_LATENCY                (GROUP_WRITE_LATENCY              [grp_num]),
				.USE_OUTPUT_STROBE            (GROUP_USE_OUTPUT_STROBE          [grp_num]),
				.OUTPUT_STROBE_PHASE          (GROUP_OUTPUT_STROBE_PHASE        [grp_num])
			) u_phylite_group_tile_20 (
				// Clocks and Reset
				.phy_clk              (phy_clk[0] ),
				.phy_clk_phs          (phy_clk_phs),
				.dll_ref_clk          (dll_ref_clk),
				.pll_locked           (pll_locked ),
				.reset_n              (reset_n    ),

				// Avalon Interface
				.cal_avl_out          (cal_avl         [grp_num + 1]),
				.cal_avl_readdata_in  (cal_avl_readdata[grp_num + 1]),
				.cal_avl_in           (cal_avl         [grp_num]    ),
				.cal_avl_readdata_out (cal_avl_readdata[grp_num]    ),

				// Core Interface
				.oe_from_core         (oe_from_core  [grp_num]),
				.data_from_core       (data_from_core[grp_num]),
				.data_to_core         (data_to_core  [grp_num]),
				.rdata_en             (rdata_en      [grp_num]),
				.rdata_valid          (rdata_valid   [grp_num]),
				
				// I/Os
				.data_oe              (data_oe   [grp_num]),
				.data_out             (data_out  [grp_num]),
				.data_in              (data_in   [grp_num]),
				.oct_enable           (oct_enable[grp_num]),

				// Inter-Tile Daisy Chains
				.broadcast_in_top      (broadcast_dn[grp_num + 1]),
				.broadcast_out_top     (broadcast_up[grp_num + 1]),
				.broadcast_in_bot      (broadcast_up[grp_num]    ),
				.broadcast_out_bot     (broadcast_dn[grp_num]    ),

				.sync_top_in           (sync_dn[grp_num + 1]     ),
				.sync_top_out          (sync_up[grp_num + 1]     ),
				.sync_bot_in           (sync_up[grp_num]         ),
				.sync_bot_out          (sync_dn[grp_num]         )
			);
		end 
	endgenerate

	////////////////////////////////////////////////////////////////////////////
	// Group Core/Periphery Connections instances
	////////////////////////////////////////////////////////////////////////////
	phylite_c2p_conns #(
		.NUM_GROUPS                    (PHYLITE_NUM_GROUPS            ),
		.RATE_MULT                     (RATE_MULT                     ),
		.GROUP_PIN_TYPE                (GROUP_PIN_TYPE                ),
		.GROUP_DDR_SDR_MODE            (GROUP_DDR_SDR_MODE            ),
		.GROUP_PIN_WIDTH               (GROUP_PIN_WIDTH               ),
		.GROUP_USE_OUTPUT_STROBE       (GROUP_USE_OUTPUT_STROBE       ),
		.GROUP_USE_DIFF_STROBE         (GROUP_USE_DIFF_STROBE         ),
		.GROUP_PIN_OE_WIDTH            (GROUP_PIN_OE_WIDTH            ),
		.GROUP_PIN_DATA_WIDTH          (GROUP_PIN_DATA_WIDTH          ),
		.GROUP_STROBE_PIN_OE_WIDTH     (GROUP_STROBE_PIN_OE_WIDTH     ),
		.GROUP_STROBE_PIN_DATA_WIDTH   (GROUP_STROBE_PIN_DATA_WIDTH   ),
		.GROUP_OE_WIDTH                (GROUP_OE_WIDTH                ),
		.GROUP_DATA_WIDTH              (GROUP_DATA_WIDTH              ),
		.GROUP_OUTPUT_STROBE_OE_WIDTH  (GROUP_OUTPUT_STROBE_OE_WIDTH  ),
		.GROUP_OUTPUT_STROBE_DATA_WIDTH(GROUP_OUTPUT_STROBE_DATA_WIDTH)
	) u_phylite_c2p_conns (
		.group_0_oe_from_core   (group_0_oe_from_core  ),
		.group_0_data_from_core (group_0_data_from_core),
		.group_0_data_to_core   (group_0_data_to_core  ),
		.group_0_rdata_en       (group_0_rdata_en      ),
		.group_0_rdata_valid    (group_0_rdata_valid   ),
		.group_0_strobe_out_in  (group_0_strobe_out_in ),
		.group_0_strobe_out_en  (group_0_strobe_out_en ),
                                                                     
		.group_1_oe_from_core   (group_1_oe_from_core  ),
		.group_1_data_from_core (group_1_data_from_core),
		.group_1_data_to_core   (group_1_data_to_core  ),
		.group_1_rdata_en       (group_1_rdata_en      ),
		.group_1_rdata_valid    (group_1_rdata_valid   ),
		.group_1_strobe_out_in  (group_1_strobe_out_in ),
		.group_1_strobe_out_en  (group_1_strobe_out_en ),
                                                                     
		.group_2_oe_from_core   (group_2_oe_from_core  ),
		.group_2_data_from_core (group_2_data_from_core),
		.group_2_data_to_core   (group_2_data_to_core  ),
		.group_2_rdata_en       (group_2_rdata_en      ),
		.group_2_rdata_valid    (group_2_rdata_valid   ),
		.group_2_strobe_out_in  (group_2_strobe_out_in ),
		.group_2_strobe_out_en  (group_2_strobe_out_en ),
                                                                     
		.group_3_oe_from_core   (group_3_oe_from_core  ),
		.group_3_data_from_core (group_3_data_from_core),
		.group_3_data_to_core   (group_3_data_to_core  ),
		.group_3_rdata_en       (group_3_rdata_en      ),
		.group_3_rdata_valid    (group_3_rdata_valid   ),
		.group_3_strobe_out_in  (group_3_strobe_out_in ),
		.group_3_strobe_out_en  (group_3_strobe_out_en ),
                                                                     
		.group_4_oe_from_core   (group_4_oe_from_core  ),
		.group_4_data_from_core (group_4_data_from_core),
		.group_4_data_to_core   (group_4_data_to_core  ),
		.group_4_rdata_en       (group_4_rdata_en      ),
		.group_4_rdata_valid    (group_4_rdata_valid   ),
		.group_4_strobe_out_in  (group_4_strobe_out_in ),
		.group_4_strobe_out_en  (group_4_strobe_out_en ),
                                                                     
		.group_5_oe_from_core   (group_5_oe_from_core  ),
		.group_5_data_from_core (group_5_data_from_core),
		.group_5_data_to_core   (group_5_data_to_core  ),
		.group_5_rdata_en       (group_5_rdata_en      ),
		.group_5_rdata_valid    (group_5_rdata_valid   ),
		.group_5_strobe_out_in  (group_5_strobe_out_in ),
		.group_5_strobe_out_en  (group_5_strobe_out_en ),
                                                                     
		.group_6_oe_from_core   (group_6_oe_from_core  ),
		.group_6_data_from_core (group_6_data_from_core),
		.group_6_data_to_core   (group_6_data_to_core  ),
		.group_6_rdata_en       (group_6_rdata_en      ),
		.group_6_rdata_valid    (group_6_rdata_valid   ),
		.group_6_strobe_out_in  (group_6_strobe_out_in ),
		.group_6_strobe_out_en  (group_6_strobe_out_en ),
                                                                     
		.group_7_oe_from_core   (group_7_oe_from_core  ),
		.group_7_data_from_core (group_7_data_from_core),
		.group_7_data_to_core   (group_7_data_to_core  ),
		.group_7_rdata_en       (group_7_rdata_en      ),
		.group_7_rdata_valid    (group_7_rdata_valid   ),
		.group_7_strobe_out_in  (group_7_strobe_out_in ),
		.group_7_strobe_out_en  (group_7_strobe_out_en ),
                                                                     
		.group_8_oe_from_core   (group_8_oe_from_core  ),
		.group_8_data_from_core (group_8_data_from_core),
		.group_8_data_to_core   (group_8_data_to_core  ),
		.group_8_rdata_en       (group_8_rdata_en      ),
		.group_8_rdata_valid    (group_8_rdata_valid   ),
		.group_8_strobe_out_in  (group_8_strobe_out_in ),
		.group_8_strobe_out_en  (group_8_strobe_out_en ),
                                                                     
		.group_9_oe_from_core   (group_9_oe_from_core  ),
		.group_9_data_from_core (group_9_data_from_core),
		.group_9_data_to_core   (group_9_data_to_core  ),
		.group_9_rdata_en       (group_9_rdata_en      ),
		.group_9_rdata_valid    (group_9_rdata_valid   ),
		.group_9_strobe_out_in  (group_9_strobe_out_in ),
		.group_9_strobe_out_en  (group_9_strobe_out_en ),
                                                                     
		.group_10_oe_from_core  (group_10_oe_from_core  ),
		.group_10_data_from_core(group_10_data_from_core),
		.group_10_data_to_core  (group_10_data_to_core  ),
		.group_10_rdata_en      (group_10_rdata_en      ),
		.group_10_rdata_valid   (group_10_rdata_valid   ),
		.group_10_strobe_out_in (group_10_strobe_out_in ),
		.group_10_strobe_out_en (group_10_strobe_out_en ),
                                                                     
		.group_11_oe_from_core  (group_11_oe_from_core  ),
		.group_11_data_from_core(group_11_data_from_core),
		.group_11_data_to_core  (group_11_data_to_core  ),
		.group_11_rdata_en      (group_11_rdata_en      ),
		.group_11_rdata_valid   (group_11_rdata_valid   ),
		.group_11_strobe_out_in (group_11_strobe_out_in ),
		.group_11_strobe_out_en (group_11_strobe_out_en ),

		.oe_from_core   (oe_from_core   ),
		.data_from_core (data_from_core ),
		.data_to_core   (data_to_core   ),
		.rdata_en       (rdata_en       ),
		.rdata_valid    (rdata_valid    )
	);

	////////////////////////////////////////////////////////////////////////////
	// Group I/O Buffer instances
	////////////////////////////////////////////////////////////////////////////
	phylite_io_bufs #(
		.NUM_GROUPS              (PHYLITE_NUM_GROUPS     ),
		.GROUP_PIN_TYPE          (GROUP_PIN_TYPE         ),
		.GROUP_PIN_WIDTH         (GROUP_PIN_WIDTH        ),
		.GROUP_USE_OUTPUT_STROBE (GROUP_USE_OUTPUT_STROBE),
		.GROUP_USE_DIFF_STROBE   (GROUP_USE_DIFF_STROBE  )
	) u_phylite_io_bufs (
		.data_oe       (data_oe       ),
		.data_out      (data_out      ),
		.data_in       (data_in       ),
		.oct_enable    (oct_enable    ),

		.group_0_data_out      (group_0_data_out      ),
		.group_0_data_in       (group_0_data_in       ),
		.group_0_data_io       (group_0_data_io       ),
		.group_0_strobe_out    (group_0_strobe_out    ),
		.group_0_strobe_out_n  (group_0_strobe_out_n  ),
		.group_0_strobe_in     (group_0_strobe_in     ),
		.group_0_strobe_in_n   (group_0_strobe_in_n   ),
		.group_0_strobe_io     (group_0_strobe_io     ),
		.group_0_strobe_io_n   (group_0_strobe_io_n   ),
                                                                    
		.group_1_data_out      (group_1_data_out      ),
		.group_1_data_in       (group_1_data_in       ),
		.group_1_data_io       (group_1_data_io       ),
		.group_1_strobe_out    (group_1_strobe_out    ),
		.group_1_strobe_out_n  (group_1_strobe_out_n  ),
		.group_1_strobe_in     (group_1_strobe_in     ),
		.group_1_strobe_in_n   (group_1_strobe_in_n   ),
		.group_1_strobe_io     (group_1_strobe_io     ),
		.group_1_strobe_io_n   (group_1_strobe_io_n   ),
                                                                    
		.group_2_data_out      (group_2_data_out      ),
		.group_2_data_in       (group_2_data_in       ),
		.group_2_data_io       (group_2_data_io       ),
		.group_2_strobe_out    (group_2_strobe_out    ),
		.group_2_strobe_out_n  (group_2_strobe_out_n  ),
		.group_2_strobe_in     (group_2_strobe_in     ),
		.group_2_strobe_in_n   (group_2_strobe_in_n   ),
		.group_2_strobe_io     (group_2_strobe_io     ),
		.group_2_strobe_io_n   (group_2_strobe_io_n   ),
                                                                    
		.group_3_data_out      (group_3_data_out      ),
		.group_3_data_in       (group_3_data_in       ),
		.group_3_data_io       (group_3_data_io       ),
		.group_3_strobe_out    (group_3_strobe_out    ),
		.group_3_strobe_out_n  (group_3_strobe_out_n  ),
		.group_3_strobe_in     (group_3_strobe_in     ),
		.group_3_strobe_in_n   (group_3_strobe_in_n   ),
		.group_3_strobe_io     (group_3_strobe_io     ),
		.group_3_strobe_io_n   (group_3_strobe_io_n   ),
                                                                    
		.group_4_data_out      (group_4_data_out      ),
		.group_4_data_in       (group_4_data_in       ),
		.group_4_data_io       (group_4_data_io       ),
		.group_4_strobe_out    (group_4_strobe_out    ),
		.group_4_strobe_out_n  (group_4_strobe_out_n  ),
		.group_4_strobe_in     (group_4_strobe_in     ),
		.group_4_strobe_in_n   (group_4_strobe_in_n   ),
		.group_4_strobe_io     (group_4_strobe_io     ),
		.group_4_strobe_io_n   (group_4_strobe_io_n   ),
                                                                    
		.group_5_data_out      (group_5_data_out      ),
		.group_5_data_in       (group_5_data_in       ),
		.group_5_data_io       (group_5_data_io       ),
		.group_5_strobe_out    (group_5_strobe_out    ),
		.group_5_strobe_out_n  (group_5_strobe_out_n  ),
		.group_5_strobe_in     (group_5_strobe_in     ),
		.group_5_strobe_in_n   (group_5_strobe_in_n   ),
		.group_5_strobe_io     (group_5_strobe_io     ),
		.group_5_strobe_io_n   (group_5_strobe_io_n   ),
                                                                    
		.group_6_data_out      (group_6_data_out      ),
		.group_6_data_in       (group_6_data_in       ),
		.group_6_data_io       (group_6_data_io       ),
		.group_6_strobe_out    (group_6_strobe_out    ),
		.group_6_strobe_out_n  (group_6_strobe_out_n  ),
		.group_6_strobe_in     (group_6_strobe_in     ),
		.group_6_strobe_in_n   (group_6_strobe_in_n   ),
		.group_6_strobe_io     (group_6_strobe_io     ),
		.group_6_strobe_io_n   (group_6_strobe_io_n   ),
                                                                    
		.group_7_data_out      (group_7_data_out      ),
		.group_7_data_in       (group_7_data_in       ),
		.group_7_data_io       (group_7_data_io       ),
		.group_7_strobe_out    (group_7_strobe_out    ),
		.group_7_strobe_out_n  (group_7_strobe_out_n  ),
		.group_7_strobe_in     (group_7_strobe_in     ),
		.group_7_strobe_in_n   (group_7_strobe_in_n   ),
		.group_7_strobe_io     (group_7_strobe_io     ),
		.group_7_strobe_io_n   (group_7_strobe_io_n   ),
                                                                    
		.group_8_data_out      (group_8_data_out      ),
		.group_8_data_in       (group_8_data_in       ),
		.group_8_data_io       (group_8_data_io       ),
		.group_8_strobe_out    (group_8_strobe_out    ),
		.group_8_strobe_out_n  (group_8_strobe_out_n  ),
		.group_8_strobe_in     (group_8_strobe_in     ),
		.group_8_strobe_in_n   (group_8_strobe_in_n   ),
		.group_8_strobe_io     (group_8_strobe_io     ),
		.group_8_strobe_io_n   (group_8_strobe_io_n   ),
                                                                    
		.group_9_data_out      (group_9_data_out      ),
		.group_9_data_in       (group_9_data_in       ),
		.group_9_data_io       (group_9_data_io       ),
		.group_9_strobe_out    (group_9_strobe_out    ),
		.group_9_strobe_out_n  (group_9_strobe_out_n  ),
		.group_9_strobe_in     (group_9_strobe_in     ),
		.group_9_strobe_in_n   (group_9_strobe_in_n   ),
		.group_9_strobe_io     (group_9_strobe_io     ),
		.group_9_strobe_io_n   (group_9_strobe_io_n   ),
                                                                    
		.group_10_data_out     (group_10_data_out     ),
		.group_10_data_in      (group_10_data_in      ),
		.group_10_data_io      (group_10_data_io      ),
		.group_10_strobe_out   (group_10_strobe_out   ),
		.group_10_strobe_out_n (group_10_strobe_out_n ),
		.group_10_strobe_in    (group_10_strobe_in    ),
		.group_10_strobe_in_n  (group_10_strobe_in_n  ),
		.group_10_strobe_io    (group_10_strobe_io    ),
		.group_10_strobe_io_n  (group_10_strobe_io_n  ),
                                                                    
		.group_11_data_out     (group_11_data_out     ),
		.group_11_data_in      (group_11_data_in      ),
		.group_11_data_io      (group_11_data_io      ),
		.group_11_strobe_out   (group_11_strobe_out   ),
		.group_11_strobe_out_n (group_11_strobe_out_n ),
		.group_11_strobe_in    (group_11_strobe_in    ),
		.group_11_strobe_in_n  (group_11_strobe_in_n  ),
		.group_11_strobe_io    (group_11_strobe_io    ),
		.group_11_strobe_io_n  (group_11_strobe_io_n  )
	);
endmodule
