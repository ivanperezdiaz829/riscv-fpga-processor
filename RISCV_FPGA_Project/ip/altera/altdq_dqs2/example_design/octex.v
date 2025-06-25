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


//synthesis_resources = arriav_termination 1 arriav_termination_logic 1 
//synopsys translate_off
`timescale 1 ps / 1 ps
//synopsys translate_on
module  octex_alt_oct_power_mtd
	( 
	parallelterminationcontrol,
	rzqin,
	seriesterminationcontrol) ;
	output   [15:0]  parallelterminationcontrol;
	input   [0:0]  rzqin;
	output   [15:0]  seriesterminationcontrol;
// synopsys translate_off
	tri0   [0:0]  rzqin;
// synopsys translate_on

	wire  [0:0]   wire_sd1a_serdataout;
	wire  [15:0]   wire_sd2a_parallelterminationcontrol;
	wire  [15:0]   wire_sd2a_seriesterminationcontrol;

`ifdef ARRIAV
	arriav_termination   sd1a_0
`endif
`ifdef CYCLONEV
	cyclonev_termination   sd1a_0
`endif
`ifdef STRATIXV
	stratixv_termination   sd1a_0
`endif
`ifdef ARRIAVGZ
	arriavgz_termination   sd1a_0
`endif
	( 
	.clkusrdftout(),
	.compoutrdn(),
	.compoutrup(),
	.enserout(),
	.rzqin(rzqin),
	.scanout(),
	.serdataout(wire_sd1a_serdataout[0:0]),
	.serdatatocore()
	// synopsys translate_off
	,
	.clkenusr(1'b0),
	.clkusr(1'b0),
	.enserusr(1'b0),
	.nclrusr(1'b0),
	.otherenser({10{1'b0}}),
	.scanclk(1'b0),
	.scanen(1'b0),
	.scanin(1'b0),
	.serdatafromcore(1'b0),
	.serdatain(1'b0)
	// synopsys translate_on
	);
`ifdef ARRIAV
	arriav_termination_logic   sd2a_0
`endif
`ifdef CYCLONEV
	cyclonev_termination_logic   sd2a_0
`endif
`ifdef STRATIXV
	stratixv_termination_logic   sd2a_0
`endif
`ifdef ARRIAVGZ
	arriavgz_termination_logic   sd2a_0
`endif
	( 
	.parallelterminationcontrol(wire_sd2a_parallelterminationcontrol[15:0]),
	.serdata(wire_sd1a_serdataout),
	.seriesterminationcontrol(wire_sd2a_seriesterminationcontrol[15:0])
	// synopsys translate_off
	,
	.enser(1'b0),
	.s2pload(1'b0),
	.scanclk(1'b0),
	.scanenable(1'b0)
	// synopsys translate_on
	);
	assign
		parallelterminationcontrol = wire_sd2a_parallelterminationcontrol,
		seriesterminationcontrol = wire_sd2a_seriesterminationcontrol;
endmodule //octex_alt_oct_power_mtd
//VALID FILE


// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on
module octex (
	rzqin,
	parallelterminationcontrol,
	seriesterminationcontrol);

	input	[0:0]  rzqin;
	output	[15:0]  parallelterminationcontrol;
	output	[15:0]  seriesterminationcontrol;

	wire [15:0] sub_wire0;
	wire [15:0] sub_wire1;
	wire [15:0] parallelterminationcontrol = sub_wire0[15:0];
	wire [15:0] seriesterminationcontrol = sub_wire1[15:0];

	octex_alt_oct_power_mtd	octex_alt_oct_power_mtd_component (
				.rzqin (rzqin),
				.parallelterminationcontrol (sub_wire0),
				.seriesterminationcontrol (sub_wire1));

endmodule
