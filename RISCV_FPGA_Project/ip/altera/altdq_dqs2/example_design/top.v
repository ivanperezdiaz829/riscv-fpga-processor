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


module top(
`ifdef PIN_HAS_OUTPUT
	reset_n_core_clock_in,
`endif
`ifdef CONNECT_TO_HARD_PHY
	write_strobe,
`endif
`ifdef USE_DQS_ENABLE
	`ifdef STRATIXV
	capture_strobe_ena,
	`else
		`ifdef ARRIAVGZ
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
`ifdef PIN_HAS_INPUT
	`ifdef USE_HARD_FIFOS
		`ifdef STRATIXV
	lfifo_rden,
	vfifo_qvld,
	rfifo_reset_n,
		`else
			`ifdef ARRIAVGZ
	lfifo_rden,
	vfifo_qvld,
	rfifo_reset_n,
			`else
	lfifo_rdata_en_full,
	lfifo_rd_latency,
	lfifo_reset_n,
	vfifo_inc_wr_ptr,
	vfifo_reset_n,
	rfifo_reset_n,
			`endif
		`endif
	`endif
`endif
`ifdef USE_DYNAMIC_CONFIG
	beginscan,
`endif
	core_clk_fr,
	core_clk_hr,
	refclk,
	reset_n,
	enable_driver,
	rzqin
);

`ifdef PIN_HAS_OUTPUT
input reset_n_core_clock_in;
`endif
`ifdef CONNECT_TO_HARD_PHY
input [3:0] write_strobe;
`endif
`ifdef USE_DQS_ENABLE
	`ifdef STRATIXV	
input [IPTCL_STROBE_ENA_WIDTH-1:0] capture_strobe_ena;
	`else
		`ifdef ARRIAVGZ
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

`ifdef PIN_HAS_INPUT
`ifdef USE_HARD_FIFOS
	`ifdef STRATIXV
		input lfifo_rden;
		input vfifo_qvld;
		input rfifo_reset_n;
	`else
		`ifdef ARRIAVGZ
		input lfifo_rden;
		input vfifo_qvld;
		input rfifo_reset_n;
		`else
		input [IPTCL_OUTPUT_MULT-1:0] lfifo_rdata_en_full;
		input [4:0] lfifo_rd_latency;
		input lfifo_reset_n;
		input [IPTCL_OUTPUT_MULT-1:0] vfifo_inc_wr_ptr;
		input vfifo_reset_n;
		input rfifo_reset_n;
		`endif
	`endif
`endif
`endif

`ifdef USE_DYNAMIC_CONFIG
input beginscan;
`endif

output core_clk_fr;
output core_clk_hr;

input refclk;
input reset_n;
output reg enable_driver;
input rzqin;

wire [IPTCL_OCT_PARALLEL_TERM_CONTROL_WIDTH-1:0] parallelterminationcontrol;
wire [IPTCL_OCT_SERIES_TERM_CONTROL_WIDTH-1:0] seriesterminationcontrol;
wire [IPTCL_DLL_WIDTH-1:0] dll_delayctrl;
`ifdef USE_OFFSET_CTRL 
wire [6:0] dll_offsetctrl;
`endif
wire pll_clk_2x;
wire pll_clk_dqs;
wire pll_clk_dq;
wire pll_clk_hr;
wire dll_clk;
wire config_clk;
wire core_clk_fr;
wire core_clk_hr;

octex oct_i(
	.rzqin(rzqin),
	.parallelterminationcontrol(parallelterminationcontrol),
	.seriesterminationcontrol(seriesterminationcontrol)
);

dllex dll_i(
	.dll_clk(dll_clk),
`ifdef USE_OFFSET_CTRL
        .dll_offsetctrlout(dll_offsetctrl),
`endif
	.dll_delayctrlout(dll_delayctrl)
);

pllex pll_i(
		.refclk(refclk),
		.rst(~reset_n),
		.outclk_0(pll_clk_2x),
		.outclk_1(pll_clk_dqs),
		.outclk_2(pll_clk_dq),
		.outclk_3(pll_clk_hr),
		.outclk_4(dll_clk),
		.outclk_5(core_clk_fr),
		.outclk_6(core_clk_hr),
		.outclk_7(config_clk)
	);
	
`ifdef USE_DYNAMIC_CONFIG
localparam NUM_IO_CONFIG = IPTCL_PIN_WIDTH + 1;

wire config_data_in;
wire config_update;
wire config_dqs_ena;
wire config_dqs_io_ena;
wire [IPTCL_PIN_WIDTH-1:0] config_io_ena;
`ifdef HAS_EXTRA_OUTPUT_IOS
wire [IPTCL_EXTRA_OUTPUT_WIDTH-1:0] config_extra_io_ena;
`endif
wire scandone;

`ifdef STRATIXV

config_controller cfg_controller_inst
(
	.padtoinputregisterdelaysetting({NUM_IO_CONFIG{6'b000000}}),
	.padtoinputregisterrisefalldelaysetting({NUM_IO_CONFIG{6'b000000}}),
	.outputdelaysetting1({NUM_IO_CONFIG{6'b000000}}),
	.outputdelaysetting2({NUM_IO_CONFIG{6'b000000}}),
	.inputclkndelaysetting({NUM_IO_CONFIG{2'b00}}),
	.inputclkdelaysetting({NUM_IO_CONFIG{2'b00}}),
	.dutycycledelaymode({NUM_IO_CONFIG{1'b0}}),
	.dutycycledelaysetting({NUM_IO_CONFIG{4'b0000}}),
	
	.dqsbusoutdelaysetting(6'b000000),
	.dqsbusoutdelaysetting2(6'b000000),
	.octdelaysetting1(6'b000000),
	.octdelaysetting2(6'b000000),
	.addrphasesetting(2'b00),
	.addrpowerdown(1'b0),
	.addrphaseinvert(1'b0),
	.dqsoutputphasesetting(2'b00),
	.dqsoutputpowerdown(1'b0),
	.dqsoutputphaseinvert(1'b0),
	.dqoutputphasesetting(2'b00),
	.dqoutputpowerdown(1'b0),
	.dqoutputphaseinvert(1'b0),
	.resyncinputphasesetting(2'b00),
	.resyncinputpowerdown(1'b0),
	.resyncinputphaseinvert(1'b0),
	.postamblephasesetting(2'b00),
	.postamblepowerdown(1'b0),
	.postamblephaseinvert(1'b0),
	.dqs2xoutputphasesetting(2'b00),
	.dqs2xoutputpowerdown(1'b0),
	.dqs2xoutputphaseinvert(1'b0),
	.dq2xoutputphasesetting(2'b00),
	.dq2xoutputpowerdown(1'b0),
	.dq2xoutputphaseinvert(1'b0),
	.ck2xoutputphasesetting(2'b00),
	.ck2xoutputpowerdown(1'b0),
	.ck2xoutputphaseinvert(1'b0),
	.dqoutputzerophasesetting(2'b00),
	.postamblezerophasesetting(2'b00),
	.postamblezeropowerdown(1'b0),
	.dividerioehratephaseinvert(1'b0),
	.dividerphaseinvert(1'b0),
	.enaoctcycledelaysetting(3'b000),
	.enaoctphasetransferreg(1'b0),
	.dqsdisablendelaysetting(8'b00000000),
	.dqsenabledelaysetting(8'b00000000),
	.enadqsenablephasetransferreg(1'b0),
	.dqsinputphasesetting(2'b01),
	.enadqsphasetransferreg(1'b0),
	.enaoutputphasetransferreg(1'b0),
	.enadqscycledelaysetting(3'b000),
	.enaoutputcycledelaysetting(3'b000),
	.enainputcycledelaysetting(1'b0),
	.enainputphasetransferreg(1'b0),
	
	.clk (config_clk),
	.reset_n (reset_n),
	.beginscan (beginscan),
	
	.config_data(config_data_in),
	.config_dqs_ena(config_dqs_ena),
	.config_dqs_io_ena(config_dqs_io_ena),
	.config_io_ena(config_io_ena),
	.config_update(config_update),
	
	.scandone (scandone)
);

`else
	`ifdef ARRIAVGZ

config_controller cfg_controller_inst
(
	.padtoinputregisterdelaysetting({NUM_IO_CONFIG{6'b000000}}),
	.padtoinputregisterrisefalldelaysetting({NUM_IO_CONFIG{6'b000000}}),
	.outputdelaysetting1({NUM_IO_CONFIG{6'b000000}}),
	.outputdelaysetting2({NUM_IO_CONFIG{6'b000000}}),
	.inputclkndelaysetting({NUM_IO_CONFIG{2'b00}}),
	.inputclkdelaysetting({NUM_IO_CONFIG{2'b00}}),
	.dutycycledelaymode({NUM_IO_CONFIG{1'b0}}),
	.dutycycledelaysetting({NUM_IO_CONFIG{4'b0000}}),
	
	.dqsbusoutdelaysetting(6'b000000),
	.dqsbusoutdelaysetting2(6'b000000),
	.octdelaysetting1(6'b000000),
	.octdelaysetting2(6'b000000),
	.addrphasesetting(2'b00),
	.addrpowerdown(1'b0),
	.addrphaseinvert(1'b0),
	.dqsoutputphasesetting(2'b00),
	.dqsoutputpowerdown(1'b0),
	.dqsoutputphaseinvert(1'b0),
	.dqoutputphasesetting(2'b00),
	.dqoutputpowerdown(1'b0),
	.dqoutputphaseinvert(1'b0),
	.resyncinputphasesetting(2'b00),
	.resyncinputpowerdown(1'b0),
	.resyncinputphaseinvert(1'b0),
	.postamblephasesetting(2'b00),
	.postamblepowerdown(1'b0),
	.postamblephaseinvert(1'b0),
	.dqs2xoutputphasesetting(2'b00),
	.dqs2xoutputpowerdown(1'b0),
	.dqs2xoutputphaseinvert(1'b0),
	.dq2xoutputphasesetting(2'b00),
	.dq2xoutputpowerdown(1'b0),
	.dq2xoutputphaseinvert(1'b0),
	.ck2xoutputphasesetting(2'b00),
	.ck2xoutputpowerdown(1'b0),
	.ck2xoutputphaseinvert(1'b0),
	.dqoutputzerophasesetting(2'b00),
	.postamblezerophasesetting(2'b00),
	.postamblezeropowerdown(1'b0),
	.dividerioehratephaseinvert(1'b0),
	.dividerphaseinvert(1'b0),
	.enaoctcycledelaysetting(3'b000),
	.enaoctphasetransferreg(1'b0),
	.dqsdisablendelaysetting(8'b00000000),
	.dqsenabledelaysetting(8'b00000000),
	.enadqsenablephasetransferreg(1'b0),
	.dqsinputphasesetting(2'b01),
	.enadqsphasetransferreg(1'b0),
	.enaoutputphasetransferreg(1'b0),
	.enadqscycledelaysetting(3'b000),
	.enaoutputcycledelaysetting(3'b000),
	.enainputcycledelaysetting(1'b0),
	.enainputphasetransferreg(1'b0),
	
	.clk (config_clk),
	.reset_n (reset_n),
	.beginscan (beginscan),
	
	.config_data(config_data_in),
	.config_dqs_ena(config_dqs_ena),
	.config_dqs_io_ena(config_dqs_io_ena),
	.config_io_ena(config_io_ena),
	.config_update(config_update),
	
	.scandone (scandone)
);

	`else


wire [1:0] readfiforeadclockselect = (IPTCL_OUTPUT_MULT == 2) ? 2'b10 : 2'b01;
wire [2:0] readfifomode = (IPTCL_OUTPUT_MULT == 2) ? 3'b000 : 3'b001;
config_controller_acv cfg_controller_inst
(
	.outputhalfratebypass({NUM_IO_CONFIG{1'b0}}),
	.readfiforeadclockselect({NUM_IO_CONFIG{readfiforeadclockselect}}),
	.readfifomode({NUM_IO_CONFIG{readfifomode}}),
	.outputregdelaysetting({NUM_IO_CONFIG{5'b00000}}),
	.outputenabledelaysetting({NUM_IO_CONFIG{5'b00000}}),
	.padtoinputregisterdelaysetting({NUM_IO_CONFIG{5'b00000}}),
	
	.postamblephasesetting(2'b00),
	.postamblephaseinvert(1'b0),
	.dqsbusoutdelaysetting(5'b00000),
	.dqshalfratebypass(1'b0),
	.octdelaysetting(5'b00000),
	.enadqsenablephasetransferreg(1'b0),
	.dqsenablegatingdelaysetting(5'b00000),
	.dqsenableungatingdelaysetting(5'b00000),
	
	.clk (config_clk),
	.reset_n (reset_n),
	.beginscan (beginscan),
	
	.config_data(config_data_in),
	.config_dqs_ena(config_dqs_ena),
	.config_dqs_io_ena(config_dqs_io_ena),
	.config_io_ena(config_io_ena),
	.config_update(config_update),
	
	.scandone (scandone)
);
`endif
`endif
defparam cfg_controller_inst.NUM_IO = IPTCL_PIN_WIDTH;
defparam cfg_controller_inst.NUM_DQS = 1;

always @(posedge config_clk or negedge reset_n)
begin
	if (~reset_n)
	begin
		enable_driver <= 1'b0;
	end
	else
	begin
		enable_driver <= enable_driver | scandone;
	end
end

`else

always @(posedge config_clk)
begin
	enable_driver <= 1'b1;
end

`endif

IPTCL_WRAPPER_NAME dut (
`ifdef PIN_HAS_OUTPUT
	.core_clock_in (core_clk_fr),
	.reset_n_core_clock_in (reset_n_core_clock_in),
`endif
`ifdef STRATIXV
	`ifdef PIN_HAS_OUTPUT
	.fr_clock_in (pll_clk_dq),
	`endif
	.hr_clock_in (pll_clk_hr),
`else
	`ifdef ARRIAVGZ
		`ifdef PIN_HAS_OUTPUT
	.fr_clock_in (pll_clk_dq),
		`endif
	.hr_clock_in (pll_clk_hr),
	`else
	.fr_clock_in (pll_clk_dq),
	.hr_clock_in (pll_clk_hr),
	`endif
`endif
`ifdef USE_2X_FF
	.dr_clock_in (pll_clk_2x),
`endif
`ifdef STRATIXV
	`ifdef USE_OUTPUT_STROBE
	.write_strobe_clock_in (pll_clk_dqs),
	`endif
`else
	`ifdef ARRIAVGZ
		`ifdef USE_OUTPUT_STROBE
	.write_strobe_clock_in (pll_clk_dqs),
		`endif
	`else
	.write_strobe_clock_in (pll_clk_dqs),
	`endif
`endif
`ifdef CONNECT_TO_HARD_PHY
	.write_strobe (write_strobe),
`endif
`ifdef USE_DQS_ENABLE
	.strobe_ena_hr_clock_in (core_clk_hr),
	`ifdef STRATIXV	
	.capture_strobe_ena(capture_strobe_ena),
	`else
		`ifdef ARRIAVGZ	
	.capture_strobe_ena(capture_strobe_ena),
		`else
			`ifndef USE_HARD_FIFOS
	.capture_strobe_ena(),
			`endif
		`endif
	`endif
`endif
`ifdef USE_DQS_TRACKING
	.capture_strobe_tracking (capture_strobe_tracking),
`endif
`ifdef PIN_TYPE_BIDIR
	.read_write_data_io (read_write_data_io),
`endif
`ifdef PIN_HAS_OUTPUT
	.write_oe_in (write_oe_in),
`endif
`ifdef PIN_TYPE_INPUT
	.read_data_in (read_data_in),
`endif
`ifdef PIN_TYPE_OUTPUT
	.write_data_out (write_data_out),
`endif
`ifdef USE_BIDIR_STROBE
	.strobe_io (strobe_io),
	.output_strobe_ena (output_strobe_ena),
	`ifdef USE_STROBE_N
	.strobe_n_io (strobe_n_io),
	`endif
`else
	`ifdef USE_OUTPUT_STROBE
	.output_strobe_out (output_strobe_out),
		`ifdef USE_STROBE_N
	.output_strobe_n_out (output_strobe_n_out),
		`endif
	`endif
	
	`ifdef PIN_HAS_INPUT
	.capture_strobe_in (capture_strobe_in),
		`ifdef USE_STROBE_N
	.capture_strobe_n_in (capture_strobe_n_in),
		`endif
	`endif
`endif

`ifdef USE_CAPTURE_REG_EXTERNAL_CLOCKING
		.external_ddio_capture_clock(external_ddio_capture_clock),
`endif
`ifdef USE_READ_FIFO_EXTERNAL_CLOCKING
		.external_fifo_capture_clock(external_fifo_capture_clock),
`endif

`ifdef USE_OCT_ENA_IN
	.oct_ena_in (oct_ena_in),
`endif
`ifdef PIN_HAS_INPUT
	.read_data_out (read_data_out),
	.capture_strobe_out (capture_strobe_out),
`endif
`ifdef PIN_HAS_OUTPUT
	.write_data_in (write_data_in),
`endif	
`ifdef HAS_EXTRA_OUTPUT_IOS
	.extra_write_data_in (extra_write_data_in),
	.extra_write_data_out (extra_write_data_out),
`endif
`ifdef USE_TERMINATION_CONTROL
	.parallelterminationcontrol_in (parallelterminationcontrol),
	.seriesterminationcontrol_in (seriesterminationcontrol),
`endif
`ifdef USE_DYNAMIC_CONFIG
	.config_data_in (config_data_in),
	.config_update (config_update),
	.config_dqs_ena (config_dqs_ena),
	.config_io_ena (config_io_ena),
`ifdef HAS_EXTRA_OUTPUT_IOS
	.config_extra_io_ena (config_extra_io_ena),
`endif
	.config_dqs_io_ena (config_dqs_io_ena),
	.config_clock_in (config_clk),
`endif
`ifdef PIN_HAS_INPUT
	`ifdef USE_HARD_FIFOS
		`ifdef STRATIXV
	.lfifo_rden (lfifo_rden),
	.vfifo_qvld (vfifo_qvld),
	.rfifo_reset_n (rfifo_reset_n),
		`else
			`ifdef ARRIAVGZ
	.lfifo_rden (lfifo_rden),
	.vfifo_qvld (vfifo_qvld),
	.rfifo_reset_n (rfifo_reset_n),
			`else
	.lfifo_rdata_en_full (lfifo_rdata_en_full),
	.lfifo_rd_latency (lfifo_rd_latency),
	.lfifo_reset_n (lfifo_reset_n),
	.vfifo_qvld (lfifo_rdata_en_full),
	.vfifo_inc_wr_ptr (vfifo_inc_wr_ptr),
	.vfifo_reset_n (vfifo_reset_n),
	.rfifo_reset_n (rfifo_reset_n),
			`endif
		`endif
	`endif
`endif
`ifdef USE_OFFSET_CTRL
        .dll_offsetdelay_in(dll_offsetctrl),
`endif
	.dll_delayctrl_in (dll_delayctrl)
);

endmodule
