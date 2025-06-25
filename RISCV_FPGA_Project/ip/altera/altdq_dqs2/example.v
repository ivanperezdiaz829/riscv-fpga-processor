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


module example (
`ifdef USE_DQS_ENABLE
	strobe_ena_hr_clock_in,
	strobe_ena_clock_in,
	capture_strobe_ena,
`endif
`ifdef PIN_TYPE_BIDIR
	read_write_data_io,
	write_oe_in,
`else
	read_data_in,
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
	capture_strobe_in,
		`ifdef USE_STROBE_N
	output_strobe_n_out,
	capture_strobe_n_in,
		`endif
	`endif
`endif
	read_data_out,
	write_data_in,
	capture_strobe_out,
`ifdef HAS_EXTRA_OUTPUT_IOS
	extra_write_data_in,
	extra_write_data_out,
`endif
`ifdef USE_TERMINATION_CONTROL
`ifdef STRATIXV
	rzqin,
`else
`ifdef ARRIAVGZ
	rzqin,
`else
	rup,
	rdn,
`endif
`endif
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
	fr_clock_in,
	hr_clock_in
);


wire [IPTCL_DLL_WIDTH-1:0] dll_delayctrl_in;
`ifdef USE_TERMINATION_CONTROL
`ifdef STRATIXV
input rzqin;
`else
`ifdef ARRIAVGZ
input rzqin;
`else
input rup;
input rdn;
`endif
`endif

input fr_clock_in;
input hr_clock_in;
`ifdef USE_DQS_ENABLE
input strobe_ena_hr_clock_in;
input strobe_ena_clock_in;
input capture_strobe_ena;
`endif
`ifdef PIN_TYPE_BIDIR
inout [IPTCL_PIN_WIDTH-1:0] read_write_data_io;
input [IPTCL_OUTPUT_MULT*IPTCL_PIN_WIDTH-1:0] write_oe_in;
`else
input [IPTCL_PIN_WIDTH-1:0] read_data_in;
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
input capture_strobe_in;
		`ifdef USE_STROBE_N
output output_strobe_n_out;
input capture_strobe_n_in;
		`endif
	`endif
`endif
output [2 * IPTCL_INPUT_MULT * IPTCL_PIN_WIDTH-1:0] read_data_out;
input [2 * IPTCL_OUTPUT_MULT * IPTCL_PIN_WIDTH-1:0] write_data_in;
output capture_strobe_out;
`ifdef HAS_EXTRA_OUTPUT_IOS
input [extra_fpga_width_out-1:0] extra_write_data_in;
output [IPTCL_EXTRA_OUTPUT_WIDTH-1:0] extra_write_data_out;
`endif
`ifdef USE_TERMINATION_CONTROL
wire	[IPTCL_OCT_PARALLEL_TERM_CONTROL_WIDTH-1:0] parallelterminationcontrol_in;
wire	[IPTCL_OCT_SERIES_TERM_CONTROL_WIDTH-1:0] seriesterminationcontrol_in;
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

oct_control	uoct_control(
`ifdef STRATIXV
	.rzqin 				(rzqin),
`else
`ifdef ARRIAVGZ
	.rzqin 				(rzqin),
`else
	.rdn                            (rdn), 
	.rup                           	(rup), 
`endif
`endif
      .parallelterminationcontrol     (parallelterminationcontrol_in),
      .seriesterminationcontrol       (seriesterminationcontrol_in));


`ifdef STRATIXV
stratixv_dll the_dll (
`else
`ifdef ARRIAVGZ
arriavgz_dll the_dll (
`else
stratixiii_dll the_dll (
`endif
`endif
	.clk (fr_clock_in),
	.delayctrlout (dll_delayctrl_in)
);
defparam
	the_dll.delay_buffer_mode="high",
	the_dll.input_frequency = "2857 ps",
	the_dll.delay_chain_length = 8,
	the_dll.jitter_reduction = "true",
	the_dll.static_delay_ctrl = 8;


IPTCL_wrapper_name altdq_dqs2_example_inst (
	.fr_clock_in( fr_clock_in),
	.hr_clock_in( hr_clock_in),
`ifdef USE_DQS_ENABLE
	.strobe_ena_hr_clock_in( strobe_ena_hr_clock_in),
	.strobe_ena_clock_in( strobe_ena_clock_in),
	.capture_strobe_ena( capture_strobe_ena),
`endif
`ifdef PIN_TYPE_BIDIR
	.read_write_data_io( read_write_data_io),
	.write_oe_in( write_oe_in),
`else
	.read_data_in(read_data_in ),
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
	.capture_strobe_in( capture_strobe_in),
		`ifdef USE_STROBE_N
	.output_strobe_n_out( output_strobe_n_out),
	.capture_strobe_n_in( capture_strobe_n_in),
		`endif
	`endif
`endif
	.read_data_out( read_data_out),
	.write_data_in( write_data_in),
	.capture_strobe_out( capture_strobe_out),
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
	.dll_delayctrl_in(dll_delayctrl_in)

);

endmodule
