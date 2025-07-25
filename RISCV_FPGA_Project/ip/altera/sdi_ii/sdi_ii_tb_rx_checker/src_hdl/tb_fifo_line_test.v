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


// megafunction wizard: %FIFO%
// GENERATION: STANDARD
// VERSION: WM1.0
// MODULE: dcfifo 

// ============================================================
// File Name: tb_fifo_line_test.v
// Megafunction Name(s):
// 			dcfifo
//
// Simulation Library Files(s):
// 			altera_mf
// ============================================================
// ************************************************************
// THIS IS A WIZARD-GENERATED FILE. DO NOT EDIT THIS FILE!
//
// 7.2 Build 151 09/26/2007 SJ Full Version
// ************************************************************


//Copyright (C) 1991-2007 Altera Corporation
//Your use of Altera Corporation's design tools, logic functions 
//and other software and tools, and its AMPP partner logic 
//functions, and any output files from any of the foregoing 
//(including device programming or simulation files), and any 
//associated documentation or information are expressly subject 
//to the terms and conditions of the Altera Program License 
//Subscription Agreement, Altera MegaCore Function License 
//Agreement, or other applicable license agreement, including, 
//without limitation, that your use is for the sole purpose of 
//programming logic devices manufactured by Altera and sold by 
//Altera or its authorized distributors.  Please refer to the 
//applicable agreement for further details.


// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on
module tb_fifo_line_test (
	aclr,
	data,
	rdclk,
	rdreq,
	wrclk,
	wrreq,
	q,
	rdusedw);

	input	  aclr;
	input	[19:0]  data;
	input	  rdclk;
	input	  rdreq;
	input	  wrclk;
	input	  wrreq;
	output	[19:0]  q;
	output	[14:0]  rdusedw;

	wire [19:0] sub_wire0;
	wire [14:0] sub_wire1;
	wire [19:0] q = sub_wire0[19:0];
	wire [14:0] rdusedw = sub_wire1[14:0];

	dcfifo	dcfifo_component (
				.wrclk (wrclk),
				.rdreq (rdreq),
				.aclr (aclr),
				.rdclk (rdclk),
				.wrreq (wrreq),
				.data (data),
				.q (sub_wire0),
				.rdusedw (sub_wire1)
				// synopsys translate_off
				,
				.rdempty (),
				.rdfull (),
				.wrempty (),
				.wrfull (),
				.wrusedw ()
				// synopsys translate_on
				);
	defparam
		dcfifo_component.add_ram_output_register = "OFF",
		dcfifo_component.clocks_are_synchronized = "FALSE",
		dcfifo_component.intended_device_family = "Stratix GX",
		dcfifo_component.lpm_numwords = 32768,
		dcfifo_component.lpm_showahead = "OFF",
		dcfifo_component.lpm_type = "dcfifo",
		dcfifo_component.lpm_width = 20,
		dcfifo_component.lpm_widthu = 15,
		dcfifo_component.overflow_checking = "OFF",
		dcfifo_component.underflow_checking = "OFF",
		dcfifo_component.use_eab = "ON";


endmodule

// ============================================================
// CNX file retrieval info
// ============================================================
// Retrieval info: PRIVATE: AlmostEmpty NUMERIC "0"
// Retrieval info: PRIVATE: AlmostEmptyThr NUMERIC "-1"
// Retrieval info: PRIVATE: AlmostFull NUMERIC "0"
// Retrieval info: PRIVATE: AlmostFullThr NUMERIC "-1"
// Retrieval info: PRIVATE: CLOCKS_ARE_SYNCHRONIZED NUMERIC "0"
// Retrieval info: PRIVATE: Clock NUMERIC "4"
// Retrieval info: PRIVATE: Depth NUMERIC "32768"
// Retrieval info: PRIVATE: Empty NUMERIC "1"
// Retrieval info: PRIVATE: Full NUMERIC "1"
// Retrieval info: PRIVATE: INTENDED_DEVICE_FAMILY STRING "Stratix GX"
// Retrieval info: PRIVATE: LE_BasedFIFO NUMERIC "0"
// Retrieval info: PRIVATE: LegacyRREQ NUMERIC "1"
// Retrieval info: PRIVATE: MAX_DEPTH_BY_9 NUMERIC "0"
// Retrieval info: PRIVATE: OVERFLOW_CHECKING NUMERIC "1"
// Retrieval info: PRIVATE: Optimize NUMERIC "2"
// Retrieval info: PRIVATE: RAM_BLOCK_TYPE NUMERIC "0"
// Retrieval info: PRIVATE: SYNTH_WRAPPER_GEN_POSTFIX STRING "0"
// Retrieval info: PRIVATE: UNDERFLOW_CHECKING NUMERIC "1"
// Retrieval info: PRIVATE: UsedW NUMERIC "1"
// Retrieval info: PRIVATE: Width NUMERIC "20"
// Retrieval info: PRIVATE: dc_aclr NUMERIC "1"
// Retrieval info: PRIVATE: diff_widths NUMERIC "0"
// Retrieval info: PRIVATE: msb_usedw NUMERIC "0"
// Retrieval info: PRIVATE: output_width NUMERIC "20"
// Retrieval info: PRIVATE: rsEmpty NUMERIC "0"
// Retrieval info: PRIVATE: rsFull NUMERIC "0"
// Retrieval info: PRIVATE: rsUsedW NUMERIC "1"
// Retrieval info: PRIVATE: sc_aclr NUMERIC "0"
// Retrieval info: PRIVATE: sc_sclr NUMERIC "0"
// Retrieval info: PRIVATE: wsEmpty NUMERIC "0"
// Retrieval info: PRIVATE: wsFull NUMERIC "0"
// Retrieval info: PRIVATE: wsUsedW NUMERIC "0"
// Retrieval info: CONSTANT: ADD_RAM_OUTPUT_REGISTER STRING "OFF"
// Retrieval info: CONSTANT: CLOCKS_ARE_SYNCHRONIZED STRING "FALSE"
// Retrieval info: CONSTANT: INTENDED_DEVICE_FAMILY STRING "Stratix GX"
// Retrieval info: CONSTANT: LPM_NUMWORDS NUMERIC "32768"
// Retrieval info: CONSTANT: LPM_SHOWAHEAD STRING "OFF"
// Retrieval info: CONSTANT: LPM_TYPE STRING "dcfifo"
// Retrieval info: CONSTANT: LPM_WIDTH NUMERIC "20"
// Retrieval info: CONSTANT: LPM_WIDTHU NUMERIC "15"
// Retrieval info: CONSTANT: OVERFLOW_CHECKING STRING "OFF"
// Retrieval info: CONSTANT: UNDERFLOW_CHECKING STRING "OFF"
// Retrieval info: CONSTANT: USE_EAB STRING "ON"
// Retrieval info: USED_PORT: aclr 0 0 0 0 INPUT GND aclr
// Retrieval info: USED_PORT: data 0 0 20 0 INPUT NODEFVAL data[19..0]
// Retrieval info: USED_PORT: q 0 0 20 0 OUTPUT NODEFVAL q[19..0]
// Retrieval info: USED_PORT: rdclk 0 0 0 0 INPUT NODEFVAL rdclk
// Retrieval info: USED_PORT: rdreq 0 0 0 0 INPUT NODEFVAL rdreq
// Retrieval info: USED_PORT: rdusedw 0 0 15 0 OUTPUT NODEFVAL rdusedw[14..0]
// Retrieval info: USED_PORT: wrclk 0 0 0 0 INPUT NODEFVAL wrclk
// Retrieval info: USED_PORT: wrreq 0 0 0 0 INPUT NODEFVAL wrreq
// Retrieval info: CONNECT: @data 0 0 20 0 data 0 0 20 0
// Retrieval info: CONNECT: q 0 0 20 0 @q 0 0 20 0
// Retrieval info: CONNECT: @wrreq 0 0 0 0 wrreq 0 0 0 0
// Retrieval info: CONNECT: @rdreq 0 0 0 0 rdreq 0 0 0 0
// Retrieval info: CONNECT: @rdclk 0 0 0 0 rdclk 0 0 0 0
// Retrieval info: CONNECT: @wrclk 0 0 0 0 wrclk 0 0 0 0
// Retrieval info: CONNECT: rdusedw 0 0 15 0 @rdusedw 0 0 15 0
// Retrieval info: CONNECT: @aclr 0 0 0 0 aclr 0 0 0 0
// Retrieval info: LIBRARY: altera_mf altera_mf.altera_mf_components.all
// Retrieval info: GEN_FILE: TYPE_NORMAL tb_fifo_line_test.v TRUE
// Retrieval info: GEN_FILE: TYPE_NORMAL tb_fifo_line_test.inc FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL tb_fifo_line_test.cmp FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL tb_fifo_line_test.bsf FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL tb_fifo_line_test_inst.v FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL tb_fifo_line_test_bb.v FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL tb_fifo_line_test_waveforms.html FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL tb_fifo_line_test_wave*.jpg FALSE
// Retrieval info: LIB_FILE: altera_mf
