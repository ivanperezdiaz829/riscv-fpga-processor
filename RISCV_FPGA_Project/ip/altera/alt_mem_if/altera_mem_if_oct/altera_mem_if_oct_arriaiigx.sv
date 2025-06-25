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
// This file instantiates the OCT block.
// ******************************************************************************************************************************** 

`timescale 1 ps / 1 ps

(* altera_attribute = "-name IP_TOOL_NAME altera_mem_if_oct; -name IP_TOOL_VERSION 13.1; -name FITTER_ADJUST_HC_SHORT_PATH_GUARDBAND 100; -name ALLOW_SYNCH_CTRL_USAGE OFF; -name AUTO_CLOCK_ENABLE_RECOGNITION OFF; -name AUTO_SHIFT_REGISTER_RECOGNITION OFF" *)


module altera_mem_if_oct_arriaiigx (
	oct_rdn,
	oct_rup,
	terminationcontrol
);


parameter OCT_TERM_CONTROL_WIDTH = 0;


// These should be connected to reference resistance pins on the board, via OCT control block if instantiated by user
input oct_rdn;
input oct_rup;

// for OCT master, termination control signals will be available to top level
output [OCT_TERM_CONTROL_WIDTH-1:0] terminationcontrol;



	`ifndef ALTERA_RESERVED_QIS
	// synopsys translate_off
	`endif
	tri0  oct_rdn;
	tri0  oct_rup;
	`ifndef ALTERA_RESERVED_QIS
	// synopsys translate_on
	`endif

	wire  [0:0]   wire_sd1a_terminationclockout;
	wire  [0:0]   wire_sd1a_terminationdataout;
	wire  [0:0]   wire_sd1a_terminationselectout;

	arriaii_termination   sd1a_0
	( 
	.comparatorprobe(),
	.rdn(oct_rdn),
	.rup(oct_rup),
	.scanout(),
	.terminationclockout(wire_sd1a_terminationclockout[0:0]),
	.terminationcontrolprobe(),
	.terminationdataout(wire_sd1a_terminationdataout[0:0]),
	.terminationdone(),
	.terminationselectout(wire_sd1a_terminationselectout[0:0])
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_off
	`endif
	,
	.scanclock(1'b0),
	.scanin(1'b0),
	.scaninmux(1'b0),
	.scanshiftmux(1'b0),
	.terminationuserclear(1'b0),
	.terminationuserclock(1'b0)
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_on
	`endif
	);
	arriaii_termination_logic   sd2a_0
	( 
	.terminationclock(wire_sd1a_terminationclockout),
	.terminationcontrol(terminationcontrol),
	.terminationdata(wire_sd1a_terminationdataout),
	.terminationselect(wire_sd1a_terminationselectout));



endmodule

