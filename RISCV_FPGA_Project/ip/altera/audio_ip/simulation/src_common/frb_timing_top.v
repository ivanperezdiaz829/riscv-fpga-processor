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

module frb_timing_top (
  trn_clk,
  trn_reset,
  vid_clk,
  vid_reset,
  timing_lut_addr,
  timing_lut_we,
  timing_lut_data_in,
  timing_lut_data_out,
  timing_std,
  timing_trs,
  timing_data);

  parameter G_SIMULATION = 0;
  parameter G_FRB_NUM_VIDEO = 4;

  `include "src_common/frb_include_smpte352m.v"

  input trn_clk;
  input trn_reset;
  input [G_FRB_NUM_VIDEO-1:0] vid_clk;
  input vid_reset;
  input [9:0] timing_lut_addr;
  input timing_lut_we;
  input [31:0] timing_lut_data_in;
  output [31:0] timing_lut_data_out;
  wire [31:0] timing_lut_data_out;
  input [(G_FRB_NUM_VIDEO*32)-1:0] timing_std;
  output [G_FRB_NUM_VIDEO-1:0] timing_trs;
  wire [G_FRB_NUM_VIDEO-1:0] timing_trs;
  output [(G_FRB_NUM_VIDEO*20)-1:0] timing_data;
  wire [(G_FRB_NUM_VIDEO*20)-1:0] timing_data;

  wire [(G_FRB_NUM_VIDEO*32)-1:0] timing_lut_data_out_all;

//------------------------------------------------------------------------------
//MODULE BODY
//------------------------------------------------------------------------------

  assign timing_lut_data_out = timing_lut_data_out_all[31:0];

  //---------------------------------------------------------------------------
  // Generate Timebase
  //---------------------------------------------------------------------------
  generate
  genvar I;
  for (I = 0; I <= G_FRB_NUM_VIDEO-1; I = I + 1) begin : g_chan

    wire [14:0] h_limit;
    wire [14:0] h_sav;
    wire [10:0] v_limit;
    wire [10:0] v1_start;
    wire [10:0] v1_end;
    wire [10:0] v2_start;
    wire [10:0] v2_end;
    wire [10:0] f1_start;
    wire [10:0] f2_start;
    wire vid_tim_en;
    wire [1:0] vid_tim_ync;
    wire vid_tim_trs;
    wire [2:0] vid_tim_fvh;
    wire vid_tim_pic;
    wire [19:0] vid_tim_data;
    wire vid_pat_trs;
    wire [19:0] vid_pat_data;





    frb_timing_lut #(
      .G_SIMULATION            (G_SIMULATION))
    u_frb_timing_lut(
      .trn_clk                 (trn_clk),
      .trn_reset               (trn_reset),
  
      // control interface
      .timing_std              (timing_std[(32*I)+31:(32*I)]),
  
      .timing_lut_addr         (timing_lut_addr),
      .timing_lut_we           (timing_lut_we),
      .timing_lut_data_in      (timing_lut_data_in),
      .timing_lut_data_out     (timing_lut_data_out_all[(32*I)+31:(32*I)]),
  
      // video parameters out
      .h_limit                 (h_limit),
      .h_sav                   (h_sav),
      .v_limit                 (v_limit),
      .v1_start                (v1_start),
      .v1_end                  (v1_end),
      .v2_start                (v2_start),
      .v2_end                  (v2_end),
      .f1_start                (f1_start),
      .f2_start                (f2_start));

    frb_timing_gen u_frb_timing_gen(
      .vid_clk                 (vid_clk[I]),
      .vid_clk_en              (1'b1),
      .vid_reset               (vid_reset),

      // control interface
      .timing_std              (timing_std[(32*I)+31:(32*I)]),

      .h_limit                 (h_limit),
      .h_sav                   (h_sav),
      .v_limit                 (v_limit),
      .v1_start                (v1_start),
      .v1_end                  (v1_end),
      .v2_start                (v2_start),
      .v2_end                  (v2_end),
      .f1_start                (f1_start),
      .f2_start                (f2_start),

      // test video out
      .vid_tim_en              (vid_tim_en),
      .vid_tim_ync             (vid_tim_ync),
      .vid_tim_trs             (vid_tim_trs),
      .vid_tim_fvh             (vid_tim_fvh),
      .vid_tim_pic             (vid_tim_pic),
      .vid_tim_data            (vid_tim_data));

    frb_timing_pattern u_frb_timing_pattern(
      .vid_clk                 (vid_clk[I]),
      .vid_clk_en              (1'b1),
      .vid_reset               (vid_reset),

      // control interface
      .timing_std              (timing_std[(32*I)+31:(32*I)]),

      // test video in
      .vid_tim_en              (vid_tim_en),
      .vid_tim_ync             (vid_tim_ync),
      .vid_tim_trs             (vid_tim_trs),
      .vid_tim_fvh             (vid_tim_fvh),
      .vid_tim_pic             (vid_tim_pic),
      .vid_tim_data            (vid_tim_data),

      .vid_pat_en              (),
      .vid_pat_ync             (),
      .vid_pat_trs             (vid_pat_trs),
      .vid_pat_fvh             (),
      .vid_pat_pic             (),
      .vid_pat_data            (vid_pat_data));

    assign timing_trs[I] = vid_pat_trs;
    assign timing_data[(20*I)+19:(20*I)] = vid_pat_data;

  end
  endgenerate

endmodule
