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
// This file instantiates the DLL.
// ******************************************************************************************************************************** 

`timescale 1 ps / 1 ps

(* altera_attribute = "-name IP_TOOL_NAME altera_mem_if_dll; -name IP_TOOL_VERSION 13.1; -name FITTER_ADJUST_HC_SHORT_PATH_GUARDBAND 100; -name ALLOW_SYNCH_CTRL_USAGE OFF; -name AUTO_CLOCK_ENABLE_RECOGNITION OFF; -name AUTO_SHIFT_REGISTER_RECOGNITION OFF" *)


module altera_mem_if_dll_abst_real_cmp_hcx_compat_mode_stratixiii (
	clk,
	hc_dll_config_dll_offset_ctrl_addnsub,
	hc_dll_config_dll_offset_ctrl_offset,
	hc_dll_config_dll_offset_ctrl_offsetctrlout,
	hc_dll_config_dll_offset_ctrl_b_offsetctrlout,


    dll_pll_locked,
	dll_delayctrl
);


parameter DLL_DELAY_CTRL_WIDTH	= 0;
parameter DELAY_BUFFER_MODE = "";
parameter DELAY_CHAIN_LENGTH = 0;
parameter DLL_INPUT_FREQUENCY_PS_STR = "";
parameter DLL_OFFSET_CTRL_WIDTH = 0;


input                                clk;  // DLL input clock
input                                dll_pll_locked;
output  [DLL_DELAY_CTRL_WIDTH-1:0]   dll_delayctrl;
input                                hc_dll_config_dll_offset_ctrl_addnsub;
input   [DLL_OFFSET_CTRL_WIDTH-1:0]  hc_dll_config_dll_offset_ctrl_offset;
output  [DLL_OFFSET_CTRL_WIDTH-1:0]  hc_dll_config_dll_offset_ctrl_offsetctrlout;
output  [DLL_OFFSET_CTRL_WIDTH-1:0]  hc_dll_config_dll_offset_ctrl_b_offsetctrlout;


wire  wire_dll_wys_m_offsetdelayctrlclkout;
wire  [DLL_DELAY_CTRL_WIDTH-1:0]   wire_dll_wys_m_offsetdelayctrlout;
wire  dll_aload; 

assign dll_aload = ~dll_pll_locked; 

	assign dll_delayctrl = 'h0b; 


endmodule

