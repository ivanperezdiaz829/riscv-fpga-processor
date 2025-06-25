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
// CRC24 of evolved data 0 and 0..7 previous evolved data words
// the oldest previous word is a rolling CRC and gets special treatment

module alt_ntrlkn_20l_6g_crc24_multiple_upto8 (
	input clk,arst,ena,valid,
	input [3:0] covered,		// number of previous words covered
	input [23:0] evo_dat_0,
	input [23:0] evo_dat_n1,
	input [23:0] evo_dat_n2,
	input [23:0] evo_dat_n3,
	input [23:0] evo_dat_n4,
	input [23:0] evo_dat_n5,
	input [23:0] evo_dat_n6,
	input [23:0] evo_dat_n7,
	output reg [23:0] crc_out
);

/////////////////////////////////////
// compute evolutions of 24'hFFFFFF
//   these are all constants
wire [23:0] evo_ff, evox2_ff, evox3_ff, evox4_ff,
   evox5_ff, evox6_ff, evox7_ff, evox8_ff;
alt_ntrlkn_20l_6g_crc24_zer64_flat cf0 (.c(24'hffffff),.crc_out(evo_ff));
alt_ntrlkn_20l_6g_crc24_zer64x2_flat cf1 (.c(24'hffffff),.crc_out(evox2_ff));
alt_ntrlkn_20l_6g_crc24_zer64x3_flat cf2 (.c(24'hffffff),.crc_out(evox3_ff));
alt_ntrlkn_20l_6g_crc24_zer64x4_flat cf3 (.c(24'hffffff),.crc_out(evox4_ff));
alt_ntrlkn_20l_6g_crc24_zer64x5_flat cf4 (.c(24'hffffff),.crc_out(evox5_ff));
alt_ntrlkn_20l_6g_crc24_zer64x6_flat cf5 (.c(24'hffffff),.crc_out(evox6_ff));
alt_ntrlkn_20l_6g_crc24_zer64x7_flat cf6 (.c(24'hffffff),.crc_out(evox7_ff));
alt_ntrlkn_20l_6g_crc24_zer64x8_flat cf7 (.c(24'hffffff),.crc_out(evox8_ff));

/////////////////////////////////////
// compute evolutions of previous data to here
wire [23:0] evox2_dat_n1, evox3_dat_n2, evox4_dat_n3,
   evox5_dat_n4, evox6_dat_n5, evox7_dat_n6, evox8_dat_n7;

alt_ntrlkn_20l_6g_crc24_zer64_flat cd0 (.c(evo_dat_n1),.crc_out(evox2_dat_n1));
alt_ntrlkn_20l_6g_crc24_zer64x2_flat cd1 (.c(evo_dat_n2),.crc_out(evox3_dat_n2));
alt_ntrlkn_20l_6g_crc24_zer64x3_flat cd2 (.c(evo_dat_n3),.crc_out(evox4_dat_n3));
alt_ntrlkn_20l_6g_crc24_zer64x4_flat cd3 (.c(evo_dat_n4),.crc_out(evox5_dat_n4));
alt_ntrlkn_20l_6g_crc24_zer64x5_flat cd4 (.c(evo_dat_n5),.crc_out(evox6_dat_n5));
alt_ntrlkn_20l_6g_crc24_zer64x6_flat cd5 (.c(evo_dat_n6),.crc_out(evox7_dat_n6));
alt_ntrlkn_20l_6g_crc24_zer64x7_flat cd6 (.c(evo_dat_n7),.crc_out(evox8_dat_n7));

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
        4'h2 : crc_out_1w = evox3_ff;
        4'h3 : crc_out_1w = evox4_ff;
        4'h4 : crc_out_1w = evox5_ff;
        4'h5 : crc_out_1w = evox6_ff;
        4'h6 : crc_out_1w = evox7_ff;
        4'h7 : crc_out_1w = evox8_dat_n7; // Using the prev_crc rather than F
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
        4'h3 : include_evox2 = 1'b1;
        4'h4 : include_evox2 = 1'b1;
        4'h5 : include_evox2 = 1'b1;
        4'h6 : include_evox2 = 1'b1;
        4'h7 : include_evox2 = 1'b1;
        default : include_evox2 = 1'b0;
    endcase
end

reg [23:0] crc_out_2w;
always @(posedge clk or posedge arst) begin
    if (arst) crc_out_2w <= 24'h0;
    else if (ena) crc_out_2w <= include_evox2 ? evox2_dat_n1 : 24'h0;
end

// Build contribution from datn2
reg include_evox3 /* synthesis keep */;
always @(*) begin
    case (covered)
        4'h0 : include_evox3 = 1'b0;
        4'h1 : include_evox3 = 1'b0;
        4'h2 : include_evox3 = 1'b1;
        4'h3 : include_evox3 = 1'b1;
        4'h4 : include_evox3 = 1'b1;
        4'h5 : include_evox3 = 1'b1;
        4'h6 : include_evox3 = 1'b1;
        4'h7 : include_evox3 = 1'b1;
        default : include_evox3 = 1'b0;
    endcase
end

reg [23:0] crc_out_3w;
always @(posedge clk or posedge arst) begin
    if (arst) crc_out_3w <= 24'h0;
    else if (ena) crc_out_3w <= include_evox3 ? evox3_dat_n2 : 24'h0;
end

// Build contribution from datn3
reg include_evox4 /* synthesis keep */;
always @(*) begin
    case (covered)
        4'h0 : include_evox4 = 1'b0;
        4'h1 : include_evox4 = 1'b0;
        4'h2 : include_evox4 = 1'b0;
        4'h3 : include_evox4 = 1'b1;
        4'h4 : include_evox4 = 1'b1;
        4'h5 : include_evox4 = 1'b1;
        4'h6 : include_evox4 = 1'b1;
        4'h7 : include_evox4 = 1'b1;
        default : include_evox4 = 1'b0;
    endcase
end

reg [23:0] crc_out_4w;
always @(posedge clk or posedge arst) begin
    if (arst) crc_out_4w <= 0;
    else if (ena) crc_out_4w <= include_evox4 ? evox4_dat_n3 : 24'h0;
end

// Build contribution from datn4
reg include_evox5 /* synthesis keep */;
always @(*) begin
    case (covered)
        4'h0 : include_evox5 = 1'b0;
        4'h1 : include_evox5 = 1'b0;
        4'h2 : include_evox5 = 1'b0;
        4'h3 : include_evox5 = 1'b0;
        4'h4 : include_evox5 = 1'b1;
        4'h5 : include_evox5 = 1'b1;
        4'h6 : include_evox5 = 1'b1;
        4'h7 : include_evox5 = 1'b1;
        default : include_evox5 = 1'b0;
    endcase
end

reg [23:0] crc_out_5w;
always @(posedge clk or posedge arst) begin
    if (arst) crc_out_5w <= 24'h0;
    else if (ena) crc_out_5w <= include_evox5 ? evox5_dat_n4 : 24'h0;
end

// Build contribution from datn5
reg include_evox6 /* synthesis keep */;
always @(*) begin
    case (covered)
        4'h0 : include_evox6 = 1'b0;
        4'h1 : include_evox6 = 1'b0;
        4'h2 : include_evox6 = 1'b0;
        4'h3 : include_evox6 = 1'b0;
        4'h4 : include_evox6 = 1'b0;
        4'h5 : include_evox6 = 1'b1;
        4'h6 : include_evox6 = 1'b1;
        4'h7 : include_evox6 = 1'b1;
        default : include_evox6 = 1'b0;
    endcase
end

reg [23:0] crc_out_6w;
always @(posedge clk or posedge arst) begin
    if (arst) crc_out_6w <= 24'h0;
    else if (ena) crc_out_6w <= include_evox6 ? evox6_dat_n5 : 24'h0;
end

// Build contribution from datn6
reg include_evox7 /* synthesis keep */;
always @(*) begin
    case (covered)
        4'h0 : include_evox7 = 1'b0;
        4'h1 : include_evox7 = 1'b0;
        4'h2 : include_evox7 = 1'b0;
        4'h3 : include_evox7 = 1'b0;
        4'h4 : include_evox7 = 1'b0;
        4'h5 : include_evox7 = 1'b0;
        4'h6 : include_evox7 = 1'b1;
        4'h7 : include_evox7 = 1'b1;
        default : include_evox7 = 1'b0;
    endcase
end

reg [23:0] crc_out_7w;
always @(posedge clk or posedge arst) begin
    if (arst) crc_out_7w <= 24'h0;
    else if (ena) crc_out_7w <= include_evox7 ? evox7_dat_n6 : 24'h0;
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
        crc_out <= evo_dat_0_r  ^ crc_out_1w ^ crc_out_2w ^ crc_out_3w ^
           crc_out_4w ^ crc_out_5w ^ crc_out_6w ^ crc_out_7w;
	end
end

endmodule
