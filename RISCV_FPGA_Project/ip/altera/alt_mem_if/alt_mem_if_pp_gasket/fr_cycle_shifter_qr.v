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

module fr_cycle_shifter_qr(
	clk,
	reset_n,
	shift_by,
	datain,
	dataout
);


parameter DATA_WIDTH = ""; 
parameter REG_POST_RESET_HIGH = "false";

localparam RATE_MULT = 4; 
localparam FULL_DATA_WIDTH = DATA_WIDTH*RATE_MULT;


input	clk;
input	reset_n;
input	[1:0] shift_by; 
input	[FULL_DATA_WIDTH-1:0] datain;
output	[FULL_DATA_WIDTH-1:0] dataout;


reg [FULL_DATA_WIDTH-1:0] datain_r;
always @(posedge clk or negedge reset_n)
begin
	if (~reset_n) begin
		if (REG_POST_RESET_HIGH == "true")
			datain_r <= {FULL_DATA_WIDTH{1'b1}};
		else
			datain_r <= {FULL_DATA_WIDTH{1'b0}};
	end else begin
		datain_r <= datain;
	end
end

wire [DATA_WIDTH-1:0] datain_t0 = datain[(DATA_WIDTH*1)-1:(DATA_WIDTH*0)];
wire [DATA_WIDTH-1:0] datain_t1 = datain[(DATA_WIDTH*2)-1:(DATA_WIDTH*1)];
wire [DATA_WIDTH-1:0] datain_t2 = datain[(DATA_WIDTH*3)-1:(DATA_WIDTH*2)];
wire [DATA_WIDTH-1:0] datain_t3 = datain[(DATA_WIDTH*4)-1:(DATA_WIDTH*3)];

wire [DATA_WIDTH-1:0] datain_r_t1 = datain_r[(DATA_WIDTH*2)-1:(DATA_WIDTH*1)];
wire [DATA_WIDTH-1:0] datain_r_t2 = datain_r[(DATA_WIDTH*3)-1:(DATA_WIDTH*2)];
wire [DATA_WIDTH-1:0] datain_r_t3 = datain_r[(DATA_WIDTH*4)-1:(DATA_WIDTH*3)];

assign dataout = (shift_by == 2'b01) ? {datain_t2, datain_t1, datain_t0, datain_r_t3} : (
                 (shift_by == 2'b10) ? {datain_t1, datain_t0, datain_r_t3, datain_r_t2} : (
                 (shift_by == 2'b11) ? {datain_t0, datain_r_t3, datain_r_t2, datain_r_t1} :
                                        {datain_t3, datain_t2, datain_t1, datain_t0} ));

endmodule
