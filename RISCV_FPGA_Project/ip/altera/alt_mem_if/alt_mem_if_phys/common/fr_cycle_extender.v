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

module fr_cycle_extender(
	clk,
	reset_n,
	extend_by,
	datain,
	dataout
);

// ******************************************************************************************************************************** 
// BEGIN PARAMETER SECTION
// All parameters default to "" will have their values passed in from higher level wrapper with the controller and driver 

parameter DATA_WIDTH = ""; 
parameter REG_POST_RESET_HIGH = "false";

`ifdef FULL_RATE
localparam RATE_MULT = 1;
localparam REG_STAGES = 3;
`endif
`ifdef HALF_RATE
localparam RATE_MULT = 2;
localparam REG_STAGES = 2;
`endif
`ifdef QUARTER_RATE
localparam RATE_MULT = 4;
localparam REG_STAGES = 1;
`endif
localparam FULL_DATA_WIDTH = DATA_WIDTH*RATE_MULT;

// END PARAMETER SECTION
// ******************************************************************************************************************************** 

input	clk;
input	reset_n;
input	[1:0] extend_by; 
input	[FULL_DATA_WIDTH-1:0] datain;
output	[FULL_DATA_WIDTH-1:0] dataout;


reg [FULL_DATA_WIDTH-1:0] datain_r [REG_STAGES-1:0] /* synthesis dont_merge */;

generate
	genvar stage;
	for (stage = 0; stage < REG_STAGES; stage = stage + 1)
	begin : stage_gen
		always @(posedge clk or negedge reset_n)
		begin
			if (~reset_n) 
				if (REG_POST_RESET_HIGH == "true") 
					datain_r[stage] <= {FULL_DATA_WIDTH{1'b1}};
				else
					datain_r[stage] <= {FULL_DATA_WIDTH{1'b0}};
			else 
				datain_r[stage] <= (stage == 0) ? datain : datain_r[stage-1];
		end
	end
endgenerate

`ifdef FULL_RATE
assign dataout = (extend_by == 2'b01) ? datain | datain_r[0] : (
                 (extend_by == 2'b10) ? datain | datain_r[0] | datain_r[1] : (
                 (extend_by == 2'b11) ? datain | datain_r[0] | datain_r[1] | datain_r[2] : (
                                        datain )));
`endif

`ifdef HALF_RATE
wire [DATA_WIDTH-1:0] datain_t0 = datain[(DATA_WIDTH*1)-1:(DATA_WIDTH*0)];
wire [DATA_WIDTH-1:0] datain_t1 = datain[(DATA_WIDTH*2)-1:(DATA_WIDTH*1)];
wire [DATA_WIDTH-1:0] datain_r_t0 = datain_r[0][(DATA_WIDTH*1)-1:(DATA_WIDTH*0)];
wire [DATA_WIDTH-1:0] datain_r_t1 = datain_r[0][(DATA_WIDTH*2)-1:(DATA_WIDTH*1)];
wire [DATA_WIDTH-1:0] datain_rr_t1 = datain_r[1][(DATA_WIDTH*2)-1:(DATA_WIDTH*1)];

assign dataout = (extend_by == 2'b01) ? {datain_t1 | datain_t0, 
                                         datain_t0 | datain_r_t1} : (
                 (extend_by == 2'b10) ? {datain_t1 | datain_t0   | datain_r_t1, 
				                         datain_t0 | datain_r_t1 | datain_r_t0} : (
                 (extend_by == 2'b11) ? {datain_t1 | datain_t0   | datain_r_t1 | datain_r_t0, 
				                         datain_t0 | datain_r_t1 | datain_r_t0 | datain_rr_t1} : (
                                        {datain_t1, datain_t0} )));
`endif
	
`ifdef QUARTER_RATE
wire [DATA_WIDTH-1:0] datain_t0 = datain[(DATA_WIDTH*1)-1:(DATA_WIDTH*0)];
wire [DATA_WIDTH-1:0] datain_t1 = datain[(DATA_WIDTH*2)-1:(DATA_WIDTH*1)];
wire [DATA_WIDTH-1:0] datain_t2 = datain[(DATA_WIDTH*3)-1:(DATA_WIDTH*2)];
wire [DATA_WIDTH-1:0] datain_t3 = datain[(DATA_WIDTH*4)-1:(DATA_WIDTH*3)];

wire [DATA_WIDTH-1:0] datain_r_t1 = datain_r[0][(DATA_WIDTH*2)-1:(DATA_WIDTH*1)];
wire [DATA_WIDTH-1:0] datain_r_t2 = datain_r[0][(DATA_WIDTH*3)-1:(DATA_WIDTH*2)];
wire [DATA_WIDTH-1:0] datain_r_t3 = datain_r[0][(DATA_WIDTH*4)-1:(DATA_WIDTH*3)];

assign dataout = (extend_by == 2'b01) ? {datain_t3 | datain_t2, 
                                         datain_t2 | datain_t1, 
										 datain_t1 | datain_t0, 
										 datain_t0 | datain_r_t3} : (
                 (extend_by == 2'b10) ? {datain_t3 | datain_t2   | datain_t1, 
				                         datain_t2 | datain_t1   | datain_t0,
										 datain_t1 | datain_t0   | datain_r_t3,
										 datain_t0 | datain_r_t3 | datain_r_t2} : (
                 (extend_by == 2'b11) ? {datain_t3 | datain_t2   | datain_t1   | datain_t0, 
				                         datain_t2 | datain_t1   | datain_t0   | datain_r_t3,
										 datain_t1 | datain_t0   | datain_r_t3 | datain_r_t2,
										 datain_t0 | datain_r_t3 | datain_r_t2 | datain_r_t1} : (
                                        {datain_t3, datain_t2, datain_t1, datain_t0} )));
`endif

endmodule
