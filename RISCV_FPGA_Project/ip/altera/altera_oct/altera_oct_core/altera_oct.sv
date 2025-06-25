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

module altera_oct(
	rzqin,
	series_termination_control,
	parallel_termination_control
);

parameter OCT_2X_CAL_MODE = "A_OCT_CAL_DDR4_DIS";
parameter OCT_DDR4_CAL_MODE = "A_OCT_CAL_DDR4_DIS";

input rzqin;
output [15:0] series_termination_control;
output [15:0] parallel_termination_control;

wire ser_data;

twentynm_termination #(
	.a_oct_cal_2x(OCT_2X_CAL_MODE),
	.a_oct_cal_ddr4(OCT_DDR4_CAL_MODE)
) sd1a_0
( 
	.rzqin(rzqin),
	.serdataout(ser_data)
);

	

twentynm_termination_logic   sd2a_0
( 
	.parallelterminationcontrol(parallel_termination_control),
	.serdata(ser_data),
	.seriesterminationcontrol(series_termination_control)
);	

endmodule
