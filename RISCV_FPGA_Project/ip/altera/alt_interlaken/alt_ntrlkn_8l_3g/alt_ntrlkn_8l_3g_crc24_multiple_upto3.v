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

// baeckler - 10-02-2008
// CRC24 of evolved data 0 and 0..2 previous evolved data words
// the oldest previous word is a rolling CRC and gets special treatment

module alt_ntrlkn_8l_3g_crc24_multiple_upto3 (
	input clk,arst,ena,valid,
	input [3:0] covered,		// number of previous words covered
	input [23:0] evo_dat_0,
	input [23:0] evo_dat_n1,
	input [23:0] evo_dat_n2,
	output reg [23:0] crc_out
);

/////////////////////////////////////
// compute evolutions of 24'hFFFFFF
//   these are all constants
wire [23:0] evo_ff,
    evox2_ff, evox3_ff;
alt_ntrlkn_8l_3g_crc24_zer64_flat cf0 (.c(24'hffffff),.crc_out(evo_ff));
alt_ntrlkn_8l_3g_crc24_zer64x2_flat cf1 (.c(24'hffffff),.crc_out(evox2_ff));
alt_ntrlkn_8l_3g_crc24_zer64x3_flat cf2 (.c(24'hffffff),.crc_out(evox3_ff));

/////////////////////////////////////
// compute evolutions of previous data to here
wire [23:0] evox2_dat_n1, evox3_dat_n2;

alt_ntrlkn_8l_3g_crc24_zer64_flat cd0 (.c(evo_dat_n1),.crc_out(evox2_dat_n1));
alt_ntrlkn_8l_3g_crc24_zer64x2_flat cd1 (.c(evo_dat_n2),.crc_out(evox3_dat_n2));

//////////////////////////////////////////////
// Build component words for CRC out

// This chunk selects the appro evolved FFFFFF or evolved prev CRC
// it has different latency from the other paths
reg [3:0] last_covered;
always @(posedge clk or posedge arst) begin
  if (arst) last_covered <= 4'h0;
  else if (ena) last_covered <= covered;
end

reg [23:0] crc_out_1w;
always @(*) begin
    case (last_covered)
        4'h0 : crc_out_1w = evo_ff;
        4'h1 : crc_out_1w = evox2_ff;
        4'h2 : crc_out_1w = evox3_dat_n2 /* Using the prev_crc rather than F */ ;
        default : crc_out_1w = 24'h0;
    endcase
end

// Build contribution from datn1
reg include_evox2 /* synthesis keep */;
always @(*) begin
    case (covered)
        4'h0 : include_evox2 = 1'b0;
        4'h1 : include_evox2 = 1'b1;
        4'h2 : include_evox2 = 1'b1;
        default : include_evox2 = 1'b0;
    endcase
end

reg [23:0] crc_out_2w;
always @(posedge clk or posedge arst) begin
    if (arst) crc_out_2w <= 24'h0;
    else if (ena) crc_out_2w <= include_evox2 ? evox2_dat_n1 : 24'h0;
end

//////////////////////////////////////////////
// dat 0 (self) is always included.  Match latency
reg[23:0] evo_dat_0_r;
always @(posedge clk or posedge arst) begin
	if (arst) evo_dat_0_r <= 24'h0;
	else if (ena) evo_dat_0_r <= evo_dat_0;
end

//////////////////////////////////////////////
reg last_valid;
always @(posedge clk or posedge arst) begin
	if (arst) begin
        last_valid <= 1'b0;
    end
    else if (ena) begin
        last_valid <= valid;
    end
end

//////////////////////////////////////////////
// combine words to form final result
always @(posedge clk or posedge arst) begin
	if (arst) crc_out <= 24'hffffff;
	else if (ena & last_valid) begin
        crc_out <= evo_dat_0_r  ^ crc_out_1w ^ crc_out_2w;
	end
end

endmodule
