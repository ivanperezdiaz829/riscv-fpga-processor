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
`ifdef DUAL_WRITE_CLOCK
	fr_data_clock_in,
	fr_strobe_clock_in,
`else
	fr_clock_in,
`endif
`endif
	hr_clock_in,
`ifdef USE_2X_FF
	dr_clock_in,
`endif
`ifdef USE_OUTPUT_STROBE
	write_strobe_clock_in,
`endif	
`ifdef USE_DQS_ENABLE
	strobe_ena_hr_clock_in,
	`ifdef ARRIAV
	`else
		`ifdef CYCLONEV
		`else	
	strobe_ena_clock_in,
		`endif
	`endif
	`ifdef ARRIAVGZ
		capture_strobe_ena,
	`else
	`ifdef STRATIXV
	capture_strobe_ena,
	`else
		`ifndef USE_HARD_FIFOS
			capture_strobe_ena,
		`endif
		
	`endif
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

`ifdef USE_CAPTURE_REG_EXTERNAL_CLOCKING
	external_ddio_capture_clock,
`endif
`ifdef USE_READ_FIFO_EXTERNAL_CLOCKING
	external_fifo_capture_clock,
`endif

`ifdef USE_SHADOW_REGS
	corerankselectwritein,
	corerankselectreadin,
	coredqsenabledelayctrlin,
	coredqsdisablendelayctrlin,
	coremultirankdelayctrlin,
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
`ifndef ARRIAIIGX
	parallelterminationcontrol_in,
`endif
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

`ifdef USE_HARD_FIFOS
	lfifo_rden,
	vfifo_qvld,
	rfifo_reset_n,
`endif

`ifdef ARRIAV
	pll_afi_clk_out,
	pll_addr_cmd_clk_out,
	pll_avl_clk_out,
`endif
`ifdef CYCLONEV
	pll_afi_clk_out,
	pll_addr_cmd_clk_out,
	pll_avl_clk_out,
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
`ifdef DUAL_WRITE_CLOCK
input fr_data_clock_in;
input fr_strobe_clock_in;
`else
input fr_clock_in;
`endif
`endif
input hr_clock_in;
`ifdef USE_2X_FF
input dr_clock_in;
`endif

`ifdef USE_OUTPUT_STROBE
input write_strobe_clock_in;
`endif
`ifdef USE_DQS_ENABLE
input strobe_ena_hr_clock_in;
	`ifdef ARRIAV
	`else
		`ifdef CYCLONEV
		`else
input strobe_ena_clock_in;
		`endif
	`endif
	`ifdef ARRIAVGZ
	input [IPTCL_STROBE_ENA_WIDTH-1:0] capture_strobe_ena;
	`else
	`ifdef STRATIXV
	input [IPTCL_STROBE_ENA_WIDTH-1:0] capture_strobe_ena;
	`else

		`ifndef USE_HARD_FIFOS
input [IPTCL_STROBE_ENA_WIDTH-1:0] capture_strobe_ena;
		`endif
	`endif
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
`ifdef USE_CAPTURE_REG_EXTERNAL_CLOCKING
input external_ddio_capture_clock;
`endif
`ifdef USE_READ_FIFO_EXTERNAL_CLOCKING
input external_fifo_capture_clock;
`endif
`ifdef USE_SHADOW_REGS
input [1:0] corerankselectwritein;
input corerankselectreadin;
input [IPTCL_DELAY_CHAIN_WIDTH-1:0] coredqsenabledelayctrlin;
input [IPTCL_DELAY_CHAIN_WIDTH-1:0] coredqsdisablendelayctrlin;
input [IPTCL_DELAY_CHAIN_WIDTH-1:0] coremultirankdelayctrlin;
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
`ifndef ARRIAIIGX
input	[IPTCL_OCT_PARALLEL_TERM_CONTROL_WIDTH-1:0] parallelterminationcontrol_in;
`endif
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

`ifdef USE_HARD_FIFOS
input lfifo_rden;
input vfifo_qvld;
input rfifo_reset_n;
`endif

`ifdef ARRIAV
output pll_afi_clk_out;
output pll_addr_cmd_clk_out;
output pll_avl_clk_out;
`endif

`ifdef CYCLONEV
output pll_afi_clk_out;
output pll_addr_cmd_clk_out;
output pll_avl_clk_out;
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
`ifdef DUAL_WRITE_CLOCK
		.fr_data_clock_in (fr_data_clock_in),
		.fr_strobe_clock_in (fr_strobe_clock_in),
		.fr_clock_in( ),
`else
		.fr_data_clock_in (),
		.fr_strobe_clock_in (),
		.fr_clock_in( fr_clock_in),
`endif
`endif
		.hr_clock_in( hr_clock_in),
`ifdef USE_2X_FF
		.dr_clock_in( dr_clock_in),
`else
		.dr_clock_in( ),
`endif
`ifdef USE_OUTPUT_STROBE	
		.write_strobe_clock_in (write_strobe_clock_in),
`endif
`ifdef USE_DQS_ENABLE
		.strobe_ena_hr_clock_in( strobe_ena_hr_clock_in),
	`ifdef ARRIAV
	`else
		`ifdef CYCLONEV
		`else
		.strobe_ena_clock_in( strobe_ena_clock_in),
		`endif
	`endif
	`ifdef ARRIAVGZ
		.capture_strobe_ena( capture_strobe_ena),
	`else
	`ifdef STRATIXV
		.capture_strobe_ena( capture_strobe_ena),
	`else
		`ifndef USE_HARD_FIFOS
		.capture_strobe_ena( capture_strobe_ena),
		`endif
	`endif
	`endif
`endif
`ifdef USE_DQS_TRACKING
		.capture_strobe_tracking (capture_strobe_tracking),
`else
		.capture_strobe_tracking (),
`endif
`ifdef PIN_TYPE_BIDIR
		.read_write_data_io( read_write_data_io),
`endif
`ifdef PIN_HAS_OUTPUT
		.write_oe_in( write_oe_in),
`endif
`ifdef PIN_TYPE_INPUT
		.read_data_in(read_data_in ),
`else
		.read_data_in( ),
`endif
`ifdef PIN_TYPE_OUTPUT
		.write_data_out( write_data_out),
`else
		.write_data_out( ),
`endif
`ifdef USE_BIDIR_STROBE
		.strobe_io( strobe_io),
		.output_strobe_ena( output_strobe_ena),
    .output_strobe_out(),
    .output_strobe_n_out(),
    .capture_strobe_in(),
    .capture_strobe_n_in(),
	`ifdef USE_STROBE_N
		.strobe_n_io( strobe_n_io),
  `else
		.strobe_n_io( ),
	`endif
`else
	`ifdef USE_OUTPUT_STROBE
		.output_strobe_out( output_strobe_out),
		`ifdef USE_STROBE_N
		.output_strobe_n_out( output_strobe_n_out),
    `else
		.output_strobe_n_out(),
		`endif
  `else
		.output_strobe_out( ),
	`endif
	`ifdef PIN_HAS_INPUT
		.capture_strobe_in( capture_strobe_in),
		`ifdef USE_STROBE_N
		.capture_strobe_n_in( capture_strobe_n_in),
    `else
		.capture_strobe_n_in( ),
		`endif
  `else
		.capture_strobe_in( ),
	`endif
`endif

`ifdef USE_CAPTURE_REG_EXTERNAL_CLOCKING
		.external_ddio_capture_clock(external_ddio_capture_clock),
`endif
`ifdef USE_READ_FIFO_EXTERNAL_CLOCKING
		.external_fifo_capture_clock(external_fifo_capture_clock),
`endif

`ifdef USE_SHADOW_REGS
		.corerankselectwritein(corerankselectwritein),
		.corerankselectreadin(corerankselectreadin),
		.coredqsenabledelayctrlin(coredqsenabledelayctrlin),
		.coredqsdisablendelayctrlin(coredqsdisablendelayctrlin),
		.coremultirankdelayctrlin(coremultirankdelayctrlin),
`else
		.corerankselectwritein(),
		.corerankselectreadin(),
		.coredqsenabledelayctrlin(),
		.coredqsdisablendelayctrlin(),
		.coremultirankdelayctrlin(),
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
`ifndef ARRIAIIGX
		.parallelterminationcontrol_in( parallelterminationcontrol_in),
`endif
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
`else
		.dll_offsetdelay_in (),
`endif

`ifdef USE_HARD_FIFOS
		.lfifo_rden(lfifo_rden),
		.vfifo_qvld(vfifo_qvld),
		.rfifo_reset_n(rfifo_reset_n),
`else
		.lfifo_rden(1'b0),
		.vfifo_qvld(1'b0),
		.rfifo_reset_n(1'b0),
`endif

`ifdef ARRIAV
		.pll_afi_clk_out (pll_afi_clk_out),
		.pll_addr_cmd_clk_out (pll_addr_cmd_clk_out),
		.pll_avl_clk_out (pll_avl_clk_out),
`endif
`ifdef CYCLONEV
		.pll_afi_clk_out (pll_afi_clk_out),
		.pll_addr_cmd_clk_out (pll_addr_cmd_clk_out),
		.pll_avl_clk_out (pll_avl_clk_out),
`endif
		.dll_delayctrl_in(dll_delayctrl_in)

	);
	defparam altdq_dqs2_inst.PIN_WIDTH = IPTCL_PIN_WIDTH;
	defparam altdq_dqs2_inst.PIN_TYPE = "IPTCL_PIN_TYPE";
	defparam altdq_dqs2_inst.USE_INPUT_PHASE_ALIGNMENT = "IPTCL_USE_INPUT_PHASE_ALIGNMENT";
	defparam altdq_dqs2_inst.USE_OUTPUT_PHASE_ALIGNMENT = "IPTCL_USE_OUTPUT_PHASE_ALIGNMENT";
	defparam altdq_dqs2_inst.USE_LDC_AS_LOW_SKEW_CLOCK = "IPTCL_USE_LDC_AS_LOW_SKEW_CLOCK";
	defparam altdq_dqs2_inst.OUTPUT_DQS_PHASE_SETTING = IPTCL_OUTPUT_DQS_PHASE_SETTING;
	defparam altdq_dqs2_inst.OUTPUT_DQ_PHASE_SETTING = IPTCL_OUTPUT_DQ_PHASE_SETTING;
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
	defparam altdq_dqs2_inst.EXTRA_OUTPUTS_USE_SEPARATE_GROUP = "IPTCL_EXTRA_OUTPUTS_USE_SEPARATE_GROUP";
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
	defparam altdq_dqs2_inst.CALIBRATION_SUPPORT = "IPTCL_CALIBRATION_SUPPORT";
	defparam altdq_dqs2_inst.DQS_ENABLE_AFTER_T7 = "IPTCL_DQS_ENABLE_AFTER_T7";
	defparam altdq_dqs2_inst.DELAY_CHAIN_WIDTH = IPTCL_DELAY_CHAIN_WIDTH;	 
`ifdef USE_CAPTURE_REG_EXTERNAL_CLOCKING
	defparam altdq_dqs2_inst.USE_CAPTURE_REG_EXTERNAL_CLOCKING = "true";
`endif
`ifdef USE_READ_FIFO_EXTERNAL_CLOCKING
	defparam altdq_dqs2_inst.USE_READ_FIFO_EXTERNAL_CLOCKING = "true";
`endif
`ifdef ARRIAVGZ
	defparam altdq_dqs2_inst.USE_SHADOW_REGS = "IPTCL_USE_SHADOW_REGS";
`else
`ifdef STRATIXV
	defparam altdq_dqs2_inst.USE_SHADOW_REGS = "IPTCL_USE_SHADOW_REGS";
`endif
`endif
`ifdef DUAL_WRITE_CLOCK
	defparam altdq_dqs2_inst.DUAL_WRITE_CLOCK = "true";
`endif	
`ifdef ARRIAV
	defparam altdq_dqs2_inst.NATURAL_ALIGNMENT = "IPTCL_NATURAL_ALIGNMENT";
	defparam altdq_dqs2_inst.USE_DQSIN_FOR_VFIFO_READ = "IPTCL_USE_DQSIN_FOR_VFIFO_READ";
`endif
`ifdef CYCLONEV
	defparam altdq_dqs2_inst.NATURAL_ALIGNMENT = "IPTCL_NATURAL_ALIGNMENT";
	defparam altdq_dqs2_inst.USE_DQSIN_FOR_VFIFO_READ = "IPTCL_USE_DQSIN_FOR_VFIFO_READ";
`endif

   
`ifdef DUAL_IMPLEMENTATIONS
end
else 
begin


	IPTCL_SECOND_IMPLEMENTATION_NAME altdq_dqs2_inst (
`ifdef PIN_HAS_OUTPUT
		.reset_n_core_clock_in(reset_n_core_clock_in),
		.core_clock_in( core_clock_in),
`ifdef DUAL_WRITE_CLOCK
		.fr_data_clock_in (fr_data_clock_in),
		.fr_strobe_clock_in (fr_strobe_clock_in),
		.fr_clock_in( ),
`else
		.fr_data_clock_in (),
		.fr_strobe_clock_in (),
		.fr_clock_in( fr_clock_in),
`endif
`endif
		.hr_clock_in( hr_clock_in),
`ifdef USE_2X_FF
		.dr_clock_in( dr_clock_in),
`else
		.dr_clock_in( ),
`endif
`ifdef USE_OUTPUT_STROBE	
		.write_strobe_clock_in (write_strobe_clock_in),
`endif
`ifdef USE_DQS_ENABLE
		.strobe_ena_hr_clock_in( strobe_ena_hr_clock_in),
	`ifdef ARRIAV
	`else
		`ifdef CYCLONEV
		`else
		.strobe_ena_clock_in( strobe_ena_clock_in),
		`endif
	`endif
	`ifdef ARRIAVGZ
		.capture_strobe_ena( capture_strobe_ena),
	`else
	`ifdef STRATIXV
		.capture_strobe_ena( capture_strobe_ena),
	`else
		`ifndef USE_HARD_FIFOS
		.capture_strobe_ena( capture_strobe_ena),
		`endif
	`endif
	`endif
`endif
`ifdef USE_DQS_TRACKING
		.capture_strobe_tracking (capture_strobe_tracking),
`else
		.capture_strobe_tracking (),
`endif
`ifdef PIN_TYPE_BIDIR
		.read_write_data_io( read_write_data_io),
`endif
`ifdef PIN_HAS_OUTPUT
		.write_oe_in( write_oe_in),
`endif
`ifdef PIN_TYPE_INPUT
		.read_data_in(read_data_in ),
`else
		.read_data_in( ),
`endif
`ifdef PIN_TYPE_OUTPUT
		.write_data_out( write_data_out),
`else
		.write_data_out( ),
`endif
`ifdef USE_BIDIR_STROBE
		.strobe_io( strobe_io),
		.output_strobe_ena( output_strobe_ena),
    .output_strobe_out(),
    .output_strobe_n_out(),
    .capture_strobe_in(),
    .capture_strobe_n_in(),
	`ifdef USE_STROBE_N
		.strobe_n_io( strobe_n_io),
  `else
		.strobe_n_io( ),
	`endif
`else
	`ifdef USE_OUTPUT_STROBE
		.output_strobe_out( output_strobe_out),
		`ifdef USE_STROBE_N
		.output_strobe_n_out( output_strobe_n_out),
    `else
    .output_strobe_n_out(),
		`endif
  `else
    .output_strobe_out(),
	`endif
	`ifdef PIN_HAS_INPUT
		.capture_strobe_in( capture_strobe_in),
		`ifdef USE_STROBE_N
		.capture_strobe_n_in( capture_strobe_n_in),
    `else
    .capture_strobe_n_in(),
		`endif
  `else
		.capture_strobe_in(),
	`endif
`endif

`ifdef USE_CAPTURE_REG_EXTERNAL_CLOCKING
		.external_ddio_capture_clock(external_ddio_capture_clock),
`endif
`ifdef USE_READ_FIFO_EXTERNAL_CLOCKING
		.external_fifo_capture_clock(external_fifo_capture_clock),
`endif

`ifdef USE_SHADOW_REGS
		.corerankselectwritein(corerankselectwritein),
		.corerankselectreadin(corerankselectreadin),
		.coredqsenabledelayctrlin(coredqsenabledelayctrlin),
		.coredqsdisablendelayctrlin(coredqsdisablendelayctrlin),
		.coremultirankdelayctrlin(coremultirankdelayctrlin),
`else
		.corerankselectwritein(),
		.corerankselectreadin(),
		.coredqsenabledelayctrlin(),
		.coredqsdisablendelayctrlin(),
		.coremultirankdelayctrlin(),
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
`ifndef ARRIAIIGX
		.parallelterminationcontrol_in( parallelterminationcontrol_in),
`endif
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
`else
		.dll_offsetdelay_in (),
`endif

`ifdef USE_HARD_FIFOS
		.lfifo_rden(lfifo_rden),
		.vfifo_qvld(vfifo_qvld),
		.rfifo_reset_n(rfifo_reset_n),
`else
		.lfifo_rden(1'b0),
		.vfifo_qvld(1'b0),
		.rfifo_reset_n(1'b0),
`endif

`ifdef ARRIAV
		.pll_afi_clk_out (pll_afi_clk_out),
		.pll_addr_cmd_clk_out (pll_addr_cmd_clk_out),
		.pll_avl_clk_out (pll_avl_clk_out),
`endif
`ifdef CYCLONEV
		.pll_afi_clk_out (pll_afi_clk_out),
		.pll_addr_cmd_clk_out (pll_addr_cmd_clk_out),
		.pll_avl_clk_out (pll_avl_clk_out),
`endif
		.dll_delayctrl_in(dll_delayctrl_in)

	);
	defparam altdq_dqs2_inst.PIN_WIDTH = IPTCL_PIN_WIDTH;
	defparam altdq_dqs2_inst.PIN_TYPE = "IPTCL_PIN_TYPE";
	defparam altdq_dqs2_inst.USE_INPUT_PHASE_ALIGNMENT = "IPTCL_USE_INPUT_PHASE_ALIGNMENT";
	defparam altdq_dqs2_inst.USE_OUTPUT_PHASE_ALIGNMENT = "IPTCL_USE_OUTPUT_PHASE_ALIGNMENT";
	defparam altdq_dqs2_inst.USE_LDC_AS_LOW_SKEW_CLOCK = "IPTCL_USE_LDC_AS_LOW_SKEW_CLOCK";
	defparam altdq_dqs2_inst.OUTPUT_DQS_PHASE_SETTING = IPTCL_OUTPUT_DQS_PHASE_SETTING;
	defparam altdq_dqs2_inst.OUTPUT_DQ_PHASE_SETTING = IPTCL_OUTPUT_DQ_PHASE_SETTING;
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
	defparam altdq_dqs2_inst.EXTRA_OUTPUTS_USE_SEPARATE_GROUP = "IPTCL_EXTRA_OUTPUTS_USE_SEPARATE_GROUP";
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
	defparam altdq_dqs2_inst.DQS_ENABLE_AFTER_T7 = "IPTCL_DQS_ENABLE_AFTER_T7";
	defparam altdq_dqs2_inst.DELAY_CHAIN_WIDTH = IPTCL_DELAY_CHAIN_WIDTH;	 
	defparam altdq_dqs2_inst.USE_HARD_FIFOS = "IPTCL_USE_HARD_FIFOS";
`ifdef USE_CAPTURE_REG_EXTERNAL_CLOCKING
	defparam altdq_dqs2_inst.USE_CAPTURE_REG_EXTERNAL_CLOCKING = "true";
`endif
`ifdef USE_READ_FIFO_EXTERNAL_CLOCKING
	defparam altdq_dqs2_inst.USE_READ_FIFO_EXTERNAL_CLOCKING = "true";
`endif
`ifdef ARRIAVGZ
	defparam altdq_dqs2_inst.USE_SHADOW_REGS = "IPTCL_USE_SHADOW_REGS";
`else
`ifdef STRATIXV
	defparam altdq_dqs2_inst.USE_SHADOW_REGS = "IPTCL_USE_SHADOW_REGS";
`endif
`endif
`ifdef DUAL_WRITE_CLOCK
	defparam altdq_dqs2_inst.DUAL_WRITE_CLOCK = "true";
`endif	
`ifdef ARRIAV
	defparam altdq_dqs2_inst.NATURAL_ALIGNMENT = "IPTCL_NATURAL_ALIGNMENT";
`endif
`ifdef CYCLONEV
	defparam altdq_dqs2_inst.NATURAL_ALIGNMENT = "IPTCL_NATURAL_ALIGNMENT";
`endif

end
endgenerate
`endif 


endmodule
