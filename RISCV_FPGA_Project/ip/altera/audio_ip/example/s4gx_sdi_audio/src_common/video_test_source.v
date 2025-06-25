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

module video_test_source (
  sim_reset,
  vid_clk,
  vid_std,
  vid_datavalid,
  vid_data,
  vid_locked);

  parameter G_TEST_STD = 0;

  //local parameters
  parameter C_HD_VID_QCLOCK_A = 3370;  //3;
  parameter C_HD_VID_QCLOCK_B = 3370;  //4;
  parameter C_SD_VID_QCLOCK_A = 9260;
  parameter C_SD_VID_QCLOCK_B = 9260;

  input sim_reset;
  output vid_clk;
  wire vid_clk;
  output [1:0] vid_std;
  wire [1:0] vid_std;
  output vid_datavalid;
  wire vid_datavalid;
  output [19:0] vid_data;
  wire [19:0] vid_data;
  output vid_locked;
  wire vid_locked;

  wire logic0;
  wire logic1;
  wire [9:0] vector10_0;
  wire [31:0] vector32_0;
  reg video_hd_clk;
  reg video_hd_clk2x;
  reg video_sd_clk;
  reg video_sd_clk2x;
  wire [0:0] src_vid_clock;
  wire [31:0] src_vid_std;
  wire sim_vid_clk;
  wire timing_datavalid;
  wire [19:0] timing_data;
  wire vid_embed_datavalid;
  wire [19:0] vid_embed_data;
  wire vid_reclock_datavalid;
  wire [19:0] vid_reclock_data;

//------------------------------------------------------------------------------
//MODULE BODY
//------------------------------------------------------------------------------

  assign logic0 = 1'b0;
  assign logic1 = 1'b1;
  assign vector10_0 = {10{1'b0}};
  assign vector32_0 = {32{1'b0}};

  //---------------------------------------------------------------------------
  // BASE CLOCKS
  //---------------------------------------------------------------------------
  always
  begin
    video_hd_clk <= 1'b0;
    video_hd_clk2x <= 1'b0;
    #(C_HD_VID_QCLOCK_A);
    video_hd_clk2x <= 1'b1;
    #(C_HD_VID_QCLOCK_B);
    video_hd_clk <= 1'b1;
    video_hd_clk2x <= 1'b0;
    #(C_HD_VID_QCLOCK_A);
    video_hd_clk2x <= 1'b1;
    #(C_HD_VID_QCLOCK_B);
  end

  always
  begin
    video_sd_clk <= 1'b0;
    video_sd_clk2x <= 1'b0;
    #(C_SD_VID_QCLOCK_A);
    video_sd_clk2x <= 1'b1;
    #(C_SD_VID_QCLOCK_B);
    video_sd_clk <= 1'b1;
    video_sd_clk2x <= 1'b0;
    #(C_SD_VID_QCLOCK_A);
    video_sd_clk2x <= 1'b1;
    #(C_SD_VID_QCLOCK_B);
  end

  //---------------------------------------------------------------------------
  // TB VIDEO SOURCE
  //---------------------------------------------------------------------------
  generate
  if (G_TEST_STD == 0 ) begin : G_SD_TEST


    assign src_vid_std = {8'b10000001 , 8'b00000110 , 8'b00000000 , 8'b00000000};
    assign src_vid_clock[0] = video_sd_clk;
    assign sim_vid_clk = video_hd_clk2x;
    assign vid_clk = video_hd_clk2x;
    assign vid_std = 2'b00;

  end
  endgenerate

  generate
  if (G_TEST_STD == 1 ) begin : G_HD_TEST


    assign src_vid_std = {8'b10000101 , 8'b00000110 , 8'b10000000 , 8'b00000000};
    assign src_vid_clock[0] = video_hd_clk;
    assign sim_vid_clk = video_hd_clk2x;
    assign vid_clk = video_hd_clk;
    assign vid_std = 2'b01;

  end
  endgenerate

  generate
  if (G_TEST_STD == 2 ) begin : G_3GA_TEST


    assign src_vid_std = {8'b10001001 , 8'b11001011 , 8'b10000000 , 8'b00000000};
    assign src_vid_clock[0] = video_hd_clk2x;
    assign sim_vid_clk = video_hd_clk2x;
    assign vid_clk = video_hd_clk2x;
    assign vid_std = 2'b11;

  end
  endgenerate

  generate
  if (G_TEST_STD == 3 ) begin : G_3GB_TEST


    assign src_vid_std = {8'b10001010 , 8'b00000110 , 8'b10000001 , 8'b00000000};
    assign src_vid_clock[0] = video_hd_clk2x;
    assign sim_vid_clk = video_hd_clk2x;
    assign vid_clk = video_hd_clk2x;
    assign vid_std = 2'b10;

  end
  endgenerate

  assign vid_locked = ~ sim_reset;

  //---------------------------------------------------------------------------
  // Video Source
  //---------------------------------------------------------------------------

  frb_timing_top #(
    .G_SIMULATION            (1),
    .G_FRB_NUM_VIDEO         (1))
  u_frb_timing_top(
    .trn_clk                 (src_vid_clock[0]),
    .trn_reset               (sim_reset),
    .vid_clk                 (src_vid_clock),
    .vid_reset               (sim_reset),

    .timing_lut_addr         (vector10_0),
    .timing_lut_we           (1'b0),
    .timing_lut_data_in      (vector32_0),
    .timing_lut_data_out     (),

    .timing_std              (src_vid_std),
    .timing_trs              (),
    .timing_data             (timing_data));

  assign timing_datavalid = 1'b1;

  insert_smpte352m u_insert_smpte352m(
    .vid_clk                 (src_vid_clock[0]),
    .vid_reset               (sim_reset),

    // control inputs
    .enable_anc              (1'b1),
    .vid_std                 (src_vid_std),

    // video input
    .vid_en                  (timing_datavalid),
    .vid_data                (timing_data),

    // video output
    .vid_out_en              (vid_embed_datavalid),
    .vid_out_data            (vid_embed_data));

  //vid_embed_datavalid <= timing_datavalid;
  //vid_embed_data <= timing_data;

  sdi_in_reclock #(
    .G_DATA_WIDTH            (20))
  u_sdi_in_reclock(
    .vid_in_clk              (src_vid_clock[0]),
    .vid_in_en               (vid_embed_datavalid),
    .vid_in_data             (vid_embed_data),

    .vid_out_clk             (sim_vid_clk),
    .vid_out_en              (vid_reclock_datavalid),
    .vid_out_data            (vid_reclock_data));

  //vid_reclock_datavalid <= vid_embed_datavalid;
  //vid_reclock_data <= vid_embed_data;

  assign vid_datavalid = vid_reclock_datavalid;
  assign vid_data = vid_reclock_data;

endmodule
