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

module IPTCL_WRAPPER_NAME (
`ifdef PIN_HAS_OUTPUT
	core_clock_in,
	reset_n_core_clock_in,
`endif
	fr_clock_in,
	hr_clock_in,
`ifdef USE_2X_FF
	dr_clock_in,
`endif
	write_strobe_clock_in,
`ifdef CONNECT_TO_HARD_PHY
	write_strobe,
`endif
`ifdef USE_DQS_ENABLE
	strobe_ena_hr_clock_in,
	`ifndef USE_HARD_FIFOS
	capture_strobe_ena,
	`endif
`endif
`ifdef USE_DQS_TRACKING
	capture_strobe_tracking,
`endif
`ifdef PIN_TYPE_BIDIR
	read_write_data_io,
`endif
`ifdef PIN_HAS_OUTPUT
	write_oe_in,
`endif
`ifdef PIN_TYPE_INPUT
	read_data_in,
`endif
`ifdef PIN_TYPE_OUTPUT
	write_data_out,
`endif
`ifdef USE_BIDIR_STROBE
	strobe_io,
	output_strobe_ena,
	`ifdef USE_STROBE_N
	strobe_n_io,
	`endif
`else
	`ifdef USE_OUTPUT_STROBE
	output_strobe_out,
		`ifdef USE_STROBE_N
	output_strobe_n_out,
		`endif
	`endif
	
	`ifdef PIN_HAS_INPUT
	capture_strobe_in,
		`ifdef USE_STROBE_N
	capture_strobe_n_in,
		`endif
	`endif
`endif
`ifdef USE_OCT_ENA_IN
	oct_ena_in,
`endif
`ifdef PIN_HAS_INPUT
	read_data_out,
	capture_strobe_out,
`endif
`ifdef PIN_HAS_OUTPUT
	write_data_in,
`endif	
`ifdef HAS_EXTRA_OUTPUT_IOS
	extra_write_data_in,
	extra_write_data_out,
`endif
`ifdef USE_TERMINATION_CONTROL
	parallelterminationcontrol_in,
	seriesterminationcontrol_in,
`endif
`ifdef USE_DYNAMIC_CONFIG
	config_data_in,
	config_update,
	config_dqs_ena,
	config_io_ena,
`ifdef HAS_EXTRA_OUTPUT_IOS
	config_extra_io_ena,
`endif
	config_dqs_io_ena,
	config_clock_in,
`endif
`ifdef USE_OFFSET_CTRL
	dll_offsetdelay_in,
`endif
`ifdef PIN_HAS_INPUT
`ifdef USE_HARD_FIFOS
	lfifo_rdata_en,
	lfifo_rdata_en_full,
	lfifo_rd_latency,
	lfifo_reset_n,
	lfifo_rdata_valid,
	vfifo_qvld,
	vfifo_inc_wr_ptr,
	vfifo_reset_n,
	rfifo_reset_n,
`endif
`endif
	dll_delayctrl_in
);


input [IPTCL_DLL_WIDTH-1:0] dll_delayctrl_in;
`ifdef USE_OFFSET_CTRL
input [IPTCL_DLL_WIDTH-1:0] dll_offsetdelay_in;
`endif

`ifdef PIN_HAS_OUTPUT
input core_clock_in;
input reset_n_core_clock_in;
`endif
input fr_clock_in;
input hr_clock_in;
`ifdef USE_2X_FF
input dr_clock_in;
`endif

input write_strobe_clock_in;
`ifdef CONNECT_TO_HARD_PHY
input [3:0] write_strobe;
`endif
`ifdef USE_DQS_ENABLE
input strobe_ena_hr_clock_in;
`ifndef USE_HARD_FIFOS
input [IPTCL_STROBE_ENA_WIDTH-1:0] capture_strobe_ena;
`endif
`endif
`ifdef USE_DQS_TRACKING
output capture_strobe_tracking;
`endif
`ifdef PIN_TYPE_BIDIR
inout [IPTCL_PIN_WIDTH-1:0] read_write_data_io;
`endif
`ifdef PIN_HAS_OUTPUT
input [IPTCL_OUTPUT_MULT*IPTCL_PIN_WIDTH-1:0] write_oe_in;
`endif
`ifdef PIN_TYPE_INPUT
input [IPTCL_PIN_WIDTH-1:0] read_data_in;
`endif
`ifdef PIN_TYPE_OUTPUT
output [IPTCL_PIN_WIDTH-1:0] write_data_out;
`endif
`ifdef USE_BIDIR_STROBE
inout strobe_io;
input [IPTCL_OUTPUT_MULT-1:0] output_strobe_ena;
	`ifdef USE_STROBE_N
inout strobe_n_io;
	`endif
`else
	`ifdef USE_OUTPUT_STROBE
output output_strobe_out;
		`ifdef USE_STROBE_N
output output_strobe_n_out;
		`endif
	`endif
	`ifdef PIN_HAS_INPUT
input capture_strobe_in;
		`ifdef USE_STROBE_N
input capture_strobe_n_in;
		`endif
	`endif
`endif
`ifdef USE_OCT_ENA_IN
input [IPTCL_OUTPUT_MULT-1:0] oct_ena_in;
`endif
`ifdef PIN_HAS_INPUT
output [2 * IPTCL_OUTPUT_MULT * IPTCL_PIN_WIDTH-1:0] read_data_out;
output capture_strobe_out;
`endif
`ifdef PIN_HAS_OUTPUT
input [2 * IPTCL_OUTPUT_MULT * IPTCL_PIN_WIDTH-1:0] write_data_in;
`endif
`ifdef HAS_EXTRA_OUTPUT_IOS
input [2 * IPTCL_OUTPUT_MULT * IPTCL_EXTRA_OUTPUT_WIDTH-1:0] extra_write_data_in;
output [IPTCL_EXTRA_OUTPUT_WIDTH-1:0] extra_write_data_out;
`endif
`ifdef USE_TERMINATION_CONTROL
input	[IPTCL_OCT_PARALLEL_TERM_CONTROL_WIDTH-1:0] parallelterminationcontrol_in;
input	[IPTCL_OCT_SERIES_TERM_CONTROL_WIDTH-1:0] seriesterminationcontrol_in;
`endif
`ifdef USE_DYNAMIC_CONFIG
input config_data_in;
input config_update;
input config_dqs_ena;
input [IPTCL_PIN_WIDTH-1:0] config_io_ena;
`ifdef HAS_EXTRA_OUTPUT_IOS
input [IPTCL_EXTRA_OUTPUT_WIDTH-1:0] config_extra_io_ena;
`endif
input config_dqs_io_ena;
input config_clock_in;
`endif

`ifdef PIN_HAS_INPUT
`ifdef USE_HARD_FIFOS
input [IPTCL_OUTPUT_MULT-1:0] lfifo_rdata_en;
input [IPTCL_OUTPUT_MULT-1:0] lfifo_rdata_en_full;
input [4:0] lfifo_rd_latency;
input lfifo_reset_n;
output lfifo_rdata_valid;
input [IPTCL_OUTPUT_MULT-1:0] vfifo_qvld;
input [IPTCL_OUTPUT_MULT-1:0] vfifo_inc_wr_ptr;
input vfifo_reset_n;
input rfifo_reset_n;
`endif
`endif

`ifdef DUAL_IMPLEMENTATIONS

`ifndef ALTERA_ALTDQ_DQS2_FAST_SIM_MODEL
  `define ALTERA_ALTDQ_DQS2_FAST_SIM_MODEL 1
`endif

parameter ALTERA_ALTDQ_DQS2_FAST_SIM_MODEL = `ALTERA_ALTDQ_DQS2_FAST_SIM_MODEL;
`else 
parameter ALTERA_ALTDQ_DQS2_FAST_SIM_MODEL = ""; 
`endif 



`ifdef DUAL_IMPLEMENTATIONS
generate
if (ALTERA_ALTDQ_DQS2_FAST_SIM_MODEL)
begin
`endif 

	IPTCL_DEFAULT_IMPLEMENTATION_NAME altdq_dqs2_inst (
`ifdef PIN_HAS_OUTPUT
		.core_clock_in( core_clock_in),
		.reset_n_core_clock_in (reset_n_core_clock_in),
`endif
		.fr_clock_in( fr_clock_in),
		.hr_clock_in( hr_clock_in),
`ifdef USE_2X_FF
		.dr_clock_in( dr_clock_in),
`endif
		.write_strobe_clock_in (write_strobe_clock_in),
`ifdef CONNECT_TO_HARD_PHY
		.write_strobe(write_strobe),
`endif
`ifdef USE_DQS_ENABLE
		.strobe_ena_hr_clock_in( strobe_ena_hr_clock_in),
`ifndef USE_HARD_FIFOS
		.capture_strobe_ena( capture_strobe_ena),
`endif
`endif
`ifdef USE_DQS_TRACKING
		.capture_strobe_tracking (capture_strobe_tracking),
`endif
`ifdef PIN_TYPE_BIDIR
		.read_write_data_io( read_write_data_io),
`endif
`ifdef PIN_HAS_OUTPUT
		.write_oe_in( write_oe_in),
`endif
`ifdef PIN_TYPE_INPUT
		.read_data_in(read_data_in ),
`endif
`ifdef PIN_TYPE_OUTPUT
		.write_data_out( write_data_out),
`endif
`ifdef USE_BIDIR_STROBE
		.strobe_io( strobe_io),
		.output_strobe_ena( output_strobe_ena),
	`ifdef USE_STROBE_N
		.strobe_n_io( strobe_n_io),
	`endif
`else
	`ifdef USE_OUTPUT_STROBE
		.output_strobe_out( output_strobe_out),
		`ifdef USE_STROBE_N
		.output_strobe_n_out( output_strobe_n_out),
		`endif
	`endif
	`ifdef PIN_HAS_INPUT
		.capture_strobe_in( capture_strobe_in),
		`ifdef USE_STROBE_N
		.capture_strobe_n_in( capture_strobe_n_in),
		`endif
	`endif
`endif
`ifdef USE_OCT_ENA_IN
		.oct_ena_in( oct_ena_in),
`endif
`ifdef PIN_HAS_INPUT
		.read_data_out( read_data_out),
		.capture_strobe_out( capture_strobe_out),
`endif
`ifdef PIN_HAS_OUTPUT
		.write_data_in( write_data_in),
`endif
`ifdef HAS_EXTRA_OUTPUT_IOS
		.extra_write_data_in( extra_write_data_in),
		.extra_write_data_out( extra_write_data_out),
`endif
`ifdef USE_TERMINATION_CONTROL
		.parallelterminationcontrol_in( parallelterminationcontrol_in),
		.seriesterminationcontrol_in( seriesterminationcontrol_in),
`endif
`ifdef USE_DYNAMIC_CONFIG
		.config_data_in( config_data_in),
		.config_update( config_update),
		.config_dqs_ena( config_dqs_ena),
		.config_io_ena( config_io_ena),
	`ifdef HAS_EXTRA_OUTPUT_IOS
		.config_extra_io_ena( config_extra_io_ena),
	`endif
		.config_dqs_io_ena( config_dqs_io_ena),
		.config_clock_in( config_clock_in),
`endif
`ifdef USE_OFFSET_CTRL
		.dll_offsetdelay_in (dll_offsetdelay_in),
`endif
`ifdef PIN_HAS_INPUT
`ifdef USE_HARD_FIFOS
		.lfifo_rdata_en(lfifo_rdata_en),
		.lfifo_rdata_en_full(lfifo_rdata_en_full),
		.lfifo_rd_latency(lfifo_rd_latency),
		.lfifo_reset_n(lfifo_reset_n),
		.lfifo_rdata_valid(lfifo_rdata_valid),
		.vfifo_qvld(vfifo_qvld),
		.vfifo_inc_wr_ptr(vfifo_inc_wr_ptr),
		.vfifo_reset_n(vfifo_reset_n),
		.rfifo_reset_n(rfifo_reset_n),
`endif
`endif
		.dll_delayctrl_in(dll_delayctrl_in)

	);
	defparam altdq_dqs2_inst.PIN_WIDTH = IPTCL_PIN_WIDTH;
	defparam altdq_dqs2_inst.PIN_TYPE = "IPTCL_PIN_TYPE";
	defparam altdq_dqs2_inst.USE_INPUT_PHASE_ALIGNMENT = "IPTCL_USE_INPUT_PHASE_ALIGNMENT";
	defparam altdq_dqs2_inst.USE_OUTPUT_PHASE_ALIGNMENT = "IPTCL_USE_OUTPUT_PHASE_ALIGNMENT";
	defparam altdq_dqs2_inst.USE_LDC_AS_LOW_SKEW_CLOCK = "IPTCL_USE_LDC_AS_LOW_SKEW_CLOCK";
	defparam altdq_dqs2_inst.USE_HALF_RATE_INPUT = "IPTCL_USE_HALF_RATE_INPUT";
	defparam altdq_dqs2_inst.USE_HALF_RATE_OUTPUT = "IPTCL_USE_HALF_RATE_OUTPUT";
	defparam altdq_dqs2_inst.DIFFERENTIAL_CAPTURE_STROBE = "IPTCL_DIFFERENTIAL_CAPTURE_STROBE";
	defparam altdq_dqs2_inst.SEPARATE_CAPTURE_STROBE = "IPTCL_SEPARATE_CAPTURE_STROBE";
	defparam altdq_dqs2_inst.INPUT_FREQ = IPTCL_INPUT_FREQ;
	defparam altdq_dqs2_inst.INPUT_FREQ_PS = "IPTCL_INPUT_FREQ_PS ps";
	defparam altdq_dqs2_inst.DELAY_CHAIN_BUFFER_MODE = "IPTCL_DELAY_CHAIN_BUFFER_MODE";
	defparam altdq_dqs2_inst.DQS_PHASE_SETTING = IPTCL_DQS_PHASE_SETTING;
	defparam altdq_dqs2_inst.DQS_PHASE_SHIFT = IPTCL_DQS_PHASE_SHIFT;
	defparam altdq_dqs2_inst.DQS_ENABLE_PHASE_SETTING = IPTCL_DQS_ENABLE_PHASE_SETTING;
	defparam altdq_dqs2_inst.USE_DYNAMIC_CONFIG = "IPTCL_USE_DYNAMIC_CONFIG";
	defparam altdq_dqs2_inst.INVERT_CAPTURE_STROBE = "IPTCL_INVERT_CAPTURE_STROBE";
	defparam altdq_dqs2_inst.SWAP_CAPTURE_STROBE_POLARITY = "IPTCL_SWAP_CAPTURE_STROBE_POLARITY";
	defparam altdq_dqs2_inst.USE_TERMINATION_CONTROL = "IPTCL_USE_TERMINATION_CONTROL";
	defparam altdq_dqs2_inst.USE_DQS_ENABLE = "IPTCL_USE_DQS_ENABLE";
	defparam altdq_dqs2_inst.USE_OUTPUT_STROBE = "IPTCL_USE_OUTPUT_STROBE";
	defparam altdq_dqs2_inst.USE_OUTPUT_STROBE_RESET = "IPTCL_USE_OUTPUT_STROBE_RESET";
	defparam altdq_dqs2_inst.DIFFERENTIAL_OUTPUT_STROBE = "IPTCL_DIFFERENTIAL_OUTPUT_STROBE";
	defparam altdq_dqs2_inst.USE_BIDIR_STROBE = "IPTCL_USE_BIDIR_STROBE";
	defparam altdq_dqs2_inst.REVERSE_READ_WORDS = "IPTCL_REVERSE_READ_WORDS";
	defparam altdq_dqs2_inst.EXTRA_OUTPUT_WIDTH = IPTCL_EXTRA_OUTPUT_WIDTH;
	defparam altdq_dqs2_inst.DYNAMIC_MODE = "IPTCL_DYNAMIC_MODE";
	defparam altdq_dqs2_inst.OCT_SERIES_TERM_CONTROL_WIDTH   = IPTCL_OCT_SERIES_TERM_CONTROL_WIDTH; 
	defparam altdq_dqs2_inst.OCT_PARALLEL_TERM_CONTROL_WIDTH = IPTCL_OCT_PARALLEL_TERM_CONTROL_WIDTH; 
	defparam altdq_dqs2_inst.DLL_WIDTH = IPTCL_DLL_WIDTH;
	defparam altdq_dqs2_inst.USE_DATA_OE_FOR_OCT = "IPTCL_USE_DATA_OE_FOR_OCT";
	defparam altdq_dqs2_inst.DQS_ENABLE_WIDTH = IPTCL_STROBE_ENA_WIDTH;
	defparam altdq_dqs2_inst.USE_OCT_ENA_IN_FOR_OCT = "IPTCL_USE_OCT_ENA_IN_FOR_OCT";
	defparam altdq_dqs2_inst.PREAMBLE_TYPE = "IPTCL_PREAMBLE_TYPE";
	defparam altdq_dqs2_inst.EMIF_UNALIGNED_PREAMBLE_SUPPORT = "IPTCL_EMIF_UNALIGNED_PREAMBLE_SUPPORT";
	defparam altdq_dqs2_inst.USE_OFFSET_CTRL = "IPTCL_USE_OFFSET_CTRL";
	defparam altdq_dqs2_inst.HR_DDIO_OUT_HAS_THREE_REGS = "IPTCL_HR_DDIO_OUT_HAS_THREE_REGS";
	defparam altdq_dqs2_inst.DQS_ENABLE_PHASECTRL = "IPTCL_USE_DYNAMIC_CONFIG";
	defparam altdq_dqs2_inst.USE_2X_FF = "IPTCL_USE_2X_FF";
	defparam altdq_dqs2_inst.DLL_USE_2X_CLK = "IPTCL_DLL_USE_2X_CLK";
	defparam altdq_dqs2_inst.USE_DQS_TRACKING = "IPTCL_USE_DQS_TRACKING";
	defparam altdq_dqs2_inst.USE_HARD_FIFOS = "IPTCL_USE_HARD_FIFOS";
	defparam altdq_dqs2_inst.USE_DQSIN_FOR_VFIFO_READ = "IPTCL_USE_DQSIN_FOR_VFIFO_READ";
	defparam altdq_dqs2_inst.CALIBRATION_SUPPORT = "IPTCL_CALIBRATION_SUPPORT";
	defparam altdq_dqs2_inst.NATURAL_ALIGNMENT = "IPTCL_NATURAL_ALIGNMENT";
	defparam altdq_dqs2_inst.SEPERATE_LDC_FOR_WRITE_STROBE = "IPTCL_SEPERATE_LDC_FOR_WRITE_STROBE";
	defparam altdq_dqs2_inst.HHP_HPS = "IPTCL_HHP_HPS";

   
`ifdef DUAL_IMPLEMENTATIONS
end
else 
begin


	IPTCL_SECOND_IMPLEMENTATION_NAME altdq_dqs2_inst (
`ifdef PIN_HAS_OUTPUT
		.reset_n_core_clock_in(reset_n_core_clock_in),
		.core_clock_in( core_clock_in),
		.fr_clock_in( fr_clock_in),
		.hr_clock_in( hr_clock_in),
`endif
`ifdef USE_2X_FF
		.dr_clock_in( dr_clock_in),
`endif
		.write_strobe_clock_in (write_strobe_clock_in),
`ifdef CONNECT_TO_HARD_PHY
		.write_strobe(write_strobe),
`endif
`ifdef USE_DQS_ENABLE
		.strobe_ena_hr_clock_in( strobe_ena_hr_clock_in),
	`ifndef USE_HARD_FIFOS
		.capture_strobe_ena( capture_strobe_ena),
	`endif
`endif
`ifdef USE_DQS_TRACKING
		.capture_strobe_tracking (capture_strobe_tracking),
`endif
`ifdef PIN_TYPE_BIDIR
		.read_write_data_io( read_write_data_io),
`endif
`ifdef PIN_HAS_OUTPUT
		.write_oe_in( write_oe_in),
`endif
`ifdef PIN_TYPE_INPUT
		.read_data_in(read_data_in ),
`endif
`ifdef PIN_TYPE_OUTPUT
		.write_data_out( write_data_out),
`endif
`ifdef USE_BIDIR_STROBE
		.strobe_io( strobe_io),
		.output_strobe_ena( output_strobe_ena),
	`ifdef USE_STROBE_N
		.strobe_n_io( strobe_n_io),
	`endif
`else
	`ifdef USE_OUTPUT_STROBE
		.output_strobe_out( output_strobe_out),
		`ifdef USE_STROBE_N
		.output_strobe_n_out( output_strobe_n_out),
		`endif
	`endif
	`ifdef PIN_HAS_INPUT
		.capture_strobe_in( capture_strobe_in),
		`ifdef USE_STROBE_N
		.capture_strobe_n_in( capture_strobe_n_in),
		`endif
	`endif
`endif
`ifdef USE_OCT_ENA_IN
		.oct_ena_in( oct_ena_in),
`endif
`ifdef PIN_HAS_INPUT
		.read_data_out( read_data_out),
		.capture_strobe_out( capture_strobe_out),
`endif
`ifdef PIN_HAS_OUTPUT
		.write_data_in( write_data_in),
`endif
`ifdef HAS_EXTRA_OUTPUT_IOS
		.extra_write_data_in( extra_write_data_in),
		.extra_write_data_out( extra_write_data_out),
`endif
`ifdef USE_TERMINATION_CONTROL
		.parallelterminationcontrol_in( parallelterminationcontrol_in),
		.seriesterminationcontrol_in( seriesterminationcontrol_in),
`endif
`ifdef USE_DYNAMIC_CONFIG
		.config_data_in( config_data_in),
		.config_update( config_update),
		.config_dqs_ena( config_dqs_ena),
		.config_io_ena( config_io_ena),
	`ifdef HAS_EXTRA_OUTPUT_IOS
		.config_extra_io_ena( config_extra_io_ena),
	`endif
		.config_dqs_io_ena( config_dqs_io_ena),
		.config_clock_in( config_clock_in),
`endif
`ifdef USE_OFFSET_CTRL
		.dll_offsetdelay_in (dll_offsetdelay_in),
`endif
		.dll_delayctrl_in(dll_delayctrl_in)

	);
	defparam altdq_dqs2_inst.PIN_WIDTH = IPTCL_PIN_WIDTH;
	defparam altdq_dqs2_inst.PIN_TYPE = "IPTCL_PIN_TYPE";
	defparam altdq_dqs2_inst.USE_INPUT_PHASE_ALIGNMENT = "IPTCL_USE_INPUT_PHASE_ALIGNMENT";
	defparam altdq_dqs2_inst.USE_OUTPUT_PHASE_ALIGNMENT = "IPTCL_USE_OUTPUT_PHASE_ALIGNMENT";
	defparam altdq_dqs2_inst.USE_LDC_AS_LOW_SKEW_CLOCK = "IPTCL_USE_LDC_AS_LOW_SKEW_CLOCK";
	defparam altdq_dqs2_inst.USE_HALF_RATE_INPUT = "IPTCL_USE_HALF_RATE_INPUT";
	defparam altdq_dqs2_inst.USE_HALF_RATE_OUTPUT = "IPTCL_USE_HALF_RATE_OUTPUT";
	defparam altdq_dqs2_inst.DIFFERENTIAL_CAPTURE_STROBE = "IPTCL_DIFFERENTIAL_CAPTURE_STROBE";
	defparam altdq_dqs2_inst.SEPARATE_CAPTURE_STROBE = "IPTCL_SEPARATE_CAPTURE_STROBE";
	defparam altdq_dqs2_inst.INPUT_FREQ = IPTCL_INPUT_FREQ;
	defparam altdq_dqs2_inst.INPUT_FREQ_PS = "IPTCL_INPUT_FREQ_PS ps";
	defparam altdq_dqs2_inst.DELAY_CHAIN_BUFFER_MODE = "IPTCL_DELAY_CHAIN_BUFFER_MODE";
	defparam altdq_dqs2_inst.DQS_PHASE_SETTING = IPTCL_DQS_PHASE_SETTING;
	defparam altdq_dqs2_inst.DQS_PHASE_SHIFT = IPTCL_DQS_PHASE_SHIFT;
	defparam altdq_dqs2_inst.DQS_ENABLE_PHASE_SETTING = IPTCL_DQS_ENABLE_PHASE_SETTING;
	defparam altdq_dqs2_inst.USE_DYNAMIC_CONFIG = "IPTCL_USE_DYNAMIC_CONFIG";
	defparam altdq_dqs2_inst.INVERT_CAPTURE_STROBE = "IPTCL_INVERT_CAPTURE_STROBE";
	defparam altdq_dqs2_inst.SWAP_CAPTURE_STROBE_POLARITY = "IPTCL_SWAP_CAPTURE_STROBE_POLARITY";
	defparam altdq_dqs2_inst.USE_TERMINATION_CONTROL = "IPTCL_USE_TERMINATION_CONTROL";
	defparam altdq_dqs2_inst.USE_DQS_ENABLE = "IPTCL_USE_DQS_ENABLE";
	defparam altdq_dqs2_inst.USE_OUTPUT_STROBE = "IPTCL_USE_OUTPUT_STROBE";
	defparam altdq_dqs2_inst.USE_OUTPUT_STROBE_RESET = "IPTCL_USE_OUTPUT_STROBE_RESET";
	defparam altdq_dqs2_inst.DIFFERENTIAL_OUTPUT_STROBE = "IPTCL_DIFFERENTIAL_OUTPUT_STROBE";
	defparam altdq_dqs2_inst.USE_BIDIR_STROBE = "IPTCL_USE_BIDIR_STROBE";
	defparam altdq_dqs2_inst.REVERSE_READ_WORDS = "IPTCL_REVERSE_READ_WORDS";
	defparam altdq_dqs2_inst.EXTRA_OUTPUT_WIDTH = IPTCL_EXTRA_OUTPUT_WIDTH;
	defparam altdq_dqs2_inst.DYNAMIC_MODE = "IPTCL_DYNAMIC_MODE";
	defparam altdq_dqs2_inst.OCT_SERIES_TERM_CONTROL_WIDTH   = IPTCL_OCT_SERIES_TERM_CONTROL_WIDTH; 
	defparam altdq_dqs2_inst.OCT_PARALLEL_TERM_CONTROL_WIDTH = IPTCL_OCT_PARALLEL_TERM_CONTROL_WIDTH; 
	defparam altdq_dqs2_inst.DLL_WIDTH = IPTCL_DLL_WIDTH;
	defparam altdq_dqs2_inst.USE_DATA_OE_FOR_OCT = "IPTCL_USE_DATA_OE_FOR_OCT";
	defparam altdq_dqs2_inst.DQS_ENABLE_WIDTH = IPTCL_STROBE_ENA_WIDTH;
	defparam altdq_dqs2_inst.USE_OCT_ENA_IN_FOR_OCT = "IPTCL_USE_OCT_ENA_IN_FOR_OCT";
	defparam altdq_dqs2_inst.PREAMBLE_TYPE = "IPTCL_PREAMBLE_TYPE";
	defparam altdq_dqs2_inst.EMIF_UNALIGNED_PREAMBLE_SUPPORT = "IPTCL_EMIF_UNALIGNED_PREAMBLE_SUPPORT";
	defparam altdq_dqs2_inst.USE_OFFSET_CTRL = "IPTCL_USE_OFFSET_CTRL";
	defparam altdq_dqs2_inst.HR_DDIO_OUT_HAS_THREE_REGS = "IPTCL_HR_DDIO_OUT_HAS_THREE_REGS";
	defparam altdq_dqs2_inst.REGULAR_WRITE_BUS_ORDERING = "IPTCL_REGULAR_WRITE_BUS_ORDERING";
	defparam altdq_dqs2_inst.DQS_ENABLE_PHASECTRL = "IPTCL_USE_DYNAMIC_CONFIG";
	defparam altdq_dqs2_inst.USE_2X_FF = "IPTCL_USE_2X_FF";
	defparam altdq_dqs2_inst.DLL_USE_2X_CLK = "IPTCL_DLL_USE_2X_CLK";
	defparam altdq_dqs2_inst.USE_DQS_TRACKING = "IPTCL_USE_DQS_TRACKING";
	defparam altdq_dqs2_inst.CALIBRATION_SUPPORT = "IPTCL_CALIBRATION_SUPPORT";
	defparam altdq_dqs2_inst.NATURAL_ALIGNMENT = "IPTCL_NATURAL_ALIGNMENT";
	defparam altdq_dqs2_inst.SEPERATE_LDC_FOR_WRITE_STROBE = "IPTCL_SEPERATE_LDC_FOR_WRITE_STROBE";
	defparam altdq_dqs2_inst.HHP_HPS = "IPTCL_HHP_HPS";

end
endgenerate
`endif 

endmodule
