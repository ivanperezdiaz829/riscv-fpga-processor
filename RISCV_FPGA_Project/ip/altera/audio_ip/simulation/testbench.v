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


//--------------------------------------------------------------------------------------------------
// File          : $RCSfile: testbench.v $
// Last modified : $Date: 2010/08/19 16:51:39 $
// Export tag    : $Name: Altera Corporation $
//--------------------------------------------------------------------------------------------------
//
// Testbench to simulate the Audio Embed Component and the associated Audio Extract Component,
// the Clocked Audio Input Component and the associated Clocked Audio Output Component.
//
// The video standard of the video test source may be selected via the generic G_TEST_STD of the 
// testbench entity which can be set to 0, 1, 2 or 3 to select SD, HD, 3GA or 3GB respectively.
// 
// The audio test source is created using the 48kHz clock output from the Audio Embed Component. 
// The audio test sample comprises an increasing count which allows the testbench to check the 
// extracted audio at the far end of the processing chain.
//
// These video and audio test sources are fed into the Audio Embed Component to create a video 
// stream with embedded audio. The resulting stream is then fed into the Audio Extract Component
// to recover the embedded audio. This audio sequence can then be examined to ensure that the
// count pattern that was created is preserved.
// 
// Another Audio Embed Component with Avalon-ST interface (with embedded Clocked Audio Output 
// Component) and the associated Audio Extract Component with Avalon-ST interface (with embedded 
// Clocked Audio Input Component) could be instantiated in this testbench. This can be selected
// by selecting G_INCLUDE_AVALON_ST = 1.
//
//--------------------------------------------------------------------------------------------------

`timescale 1 ps / 1 ps

module testbench ();

  //parameter G_TEST_MODE = 0;
  parameter G_TEST_STD = 1;
  parameter G_INCLUDE_AVALON_ST = 0;

  //local parameters
  parameter C_AUDEMB_NUM_GROUPS = 4;
  parameter C_50M_HCLOCK = 10000;
  parameter C_200M_HCLOCKA = 2000;
  parameter C_200M_HCLOCKB = 3000;
  parameter C_AUD_HCLOCK = 162760;
  parameter C_AES_HCLOCK = 5086;

  wire logic0;
  wire logic1;
  wire [9:0] vector10_0;
  wire [31:0] vector32_0;
  reg end_simulation = 1'b0;
  reg simulation_reset;
  reg sim_checker_enable;
  reg aes_avalon_sim_checker_enable;
  reg [7:0] sim_errors = {8{1'b0}};
  reg [7:0] aes_avalon_sim_errors = {8{1'b0}};
  reg aud_clk;
  reg fix_clk;
  reg reg_clk;
  reg [5:0] reg_base_addr;
  reg [5:0] reg_burstcount;
  reg [7:0] reg_writedata;
  reg [7:0] read_data;
  wire reg_waitrequest_extract;
  wire reg_waitrequest_embed;
  wire reg_waitrequest_cai;
  wire reg_waitrequest_cao;
  reg reg_write_extract;
  reg reg_write_embed;
  reg reg_write_cai;
  reg reg_write_cao;
  reg reg_read_extract;
  reg reg_read_embed;
  reg reg_read_cai;
  reg reg_read_cao;
  wire reg_readdatavalid_extract;
  wire reg_readdatavalid_embed;
  wire reg_readdatavalid_cai;
  wire reg_readdatavalid_cao;
  wire [7:0] reg_readdata_extract;
  wire [7:0] reg_readdata_embed;
  wire [7:0] reg_readdata_cai;
  wire [7:0] reg_readdata_cao;
  wire sim_vid_clk;
  wire [1:0] sim_std;
  wire sim_vid_datavalid;
  wire [19:0] sim_vid_data;
  wire sim_vid_locked;
  wire aud_embed_clk48;
  wire aud_source_de;
  wire aud_source_ws;
  wire aud_source_data;
  reg [(2*C_AUDEMB_NUM_GROUPS)-1:0] aud_embed_clk;
  reg [(2*C_AUDEMB_NUM_GROUPS)-1:0] aud_embed_de;
  reg [(2*C_AUDEMB_NUM_GROUPS)-1:0] aud_embed_ws;
  reg [(2*C_AUDEMB_NUM_GROUPS)-1:0] aud_embed_data;
  wire vid_embed_out_datavalid;
  wire vid_embed_out_trs;
  wire [10:0] vid_embed_out_ln;
  wire [19:0] vid_embed_out;
  wire aud_extract_clk_out;
  wire aud_extract_de;
  wire aud_extract_ws;
  wire [0:0] aud_extract_data;
  wire aes_avalon_ws;
  wire aes_avalon_data;
  reg aes_avalon_ws_d1;
  reg [31:0] aes_avalon_shift;
  reg aes_avalon_valid;
  reg [31:0] aes_avalon_sample = {32{1'b0}};
  reg [31:0] aes_avalon_last_sample = {32{1'b0}};
  reg aud_extract_ws_d1;
  reg [31:0] aud_extract_shift;
  reg aud_extract_valid;
  reg [31:0] aud_extract_sample = {32{1'b0}};
  reg [31:0] aud_extract_last_sample = {32{1'b0}};
  wire aes_data;
  wire [2:0] avalon_aud_ready_count = {3{1'b0}};
  
  //generate
  //if (G_INCLUDE_AVALON_ST == 1) begin
  wire [2*C_AUDEMB_NUM_GROUPS-1:0] avalon_emb_aud_ready;
  wire [2*C_AUDEMB_NUM_GROUPS-1:0] avalon_emb_aud_valid;
  wire [2*C_AUDEMB_NUM_GROUPS-1:0] avalon_emb_aud_sop;
  wire [2*C_AUDEMB_NUM_GROUPS-1:0] avalon_emb_aud_eop;
  wire [(2*C_AUDEMB_NUM_GROUPS*8)-1:0] avalon_emb_aud_channel;
  wire [(2*C_AUDEMB_NUM_GROUPS*24)-1:0] avalon_emb_aud_data;
    
  wire vid_avalon_embed_out_datavalid;
  wire vid_avalon_embed_out_trs;
  wire [10:0] vid_avalon_embed_out_ln;
  wire [19:0] vid_avalon_embed_out;
  wire aud_avalon_extract_clk_out;
      
  wire avalon_ext_aud_ready;
  wire avalon_ext_aud_valid;
  wire avalon_ext_aud_sop;
  wire avalon_ext_aud_eop;
  wire [7:0] avalon_ext_aud_channel;
  wire [23:0] avalon_ext_aud_data;
    
  wire reg_readdatavalid_extract_avalon;
  wire [7:0] reg_readdata_extract_avalon;
  reg [7:0] read_data_avalon;
  //end 
  //else begin
  wire avalon_aud_ready;
  wire avalon_aud_valid;
  wire avalon_aud_sop;
  wire avalon_aud_eop;
  wire [7:0] avalon_aud_channel;
  wire [23:0] avalon_aud_data;
  //end
  //endgenerate

  `include "func_cpu.v"

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
    if (end_simulation == 1'b1) begin
      forever #100000;
    end else begin
      aud_clk <= 1'b0;
      #(C_AUD_HCLOCK);
      aud_clk <= 1'b1;
      #(C_AUD_HCLOCK);
    end
  end

  always
  begin
    if (end_simulation == 1'b1) begin
      forever #100000;
    end else begin
      reg_clk <= 1'b0;
      #(C_50M_HCLOCK);
      reg_clk <= 1'b1;
      #(C_50M_HCLOCK);
    end
  end

  always
  begin
    if (end_simulation == 1'b1) begin
      forever #100000;
    end else begin
      fix_clk <= 1'b0;
      #(C_200M_HCLOCKA);
      fix_clk <= 1'b1;
      #(C_200M_HCLOCKB);
    end
  end

  //---------------------------------------------------------------------------
  // TEST SOURCES
  //---------------------------------------------------------------------------
  video_test_source #(
    .G_TEST_STD              (G_TEST_STD))
  u_video_test_source(
    .sim_reset               (simulation_reset),

    .vid_clk                 (sim_vid_clk),
    .vid_std                 (sim_std),
    .vid_datavalid           (sim_vid_datavalid),
    .vid_data                (sim_vid_data),
    .vid_locked              (sim_vid_locked));

  audio_test_source u_audio_test_source(
    .aud_clk                 (reg_clk),
    .aud_clk48               (aud_embed_clk48),
    .aud_reset               (simulation_reset),

    .aud_de                  (aud_source_de),
    .aud_ws                  (aud_source_ws),
    .aud_data                (aud_source_data));

  //---------------------------------------------------------------------------
  // EMBED
  //---------------------------------------------------------------------------
  always @(reg_clk,aud_source_de,aud_source_ws,aud_source_data)
  begin : vhdl2v_16
  integer I;
  
    for (I = 0; I <= (2*C_AUDEMB_NUM_GROUPS)-1; I = I + 1) begin
      aud_embed_clk[I] = reg_clk;
      aud_embed_de[I] = aud_source_de;
      aud_embed_ws[I] = aud_source_ws;
      aud_embed_data[I] = aud_source_data;
    end
  end  
  
  audio_embed_top u_audio_embed_0(
    .fix_clk                 (reg_clk),
    .reg_clk                 (reg_clk),
    .reg_reset               (simulation_reset),
    .reset                   (simulation_reset),

    //Register interface (Avalon-MM Slave)
    .reg_base_addr           (reg_base_addr),
    .reg_burstcount          (reg_burstcount),
    .reg_waitrequest         (reg_waitrequest_embed),

    .reg_write               (reg_write_embed),
    .reg_writedata           (reg_writedata),
    .reg_read                (reg_read_embed),
    .reg_readdatavalid       (reg_readdatavalid_embed),
    .reg_readdata            (reg_readdata_embed),

    //Video input interface
    .vid_clk                 (sim_vid_clk),
    .vid_std                 (sim_std),
    .vid_datavalid           (sim_vid_datavalid),
    .vid_data                (sim_vid_data),

    .vid_std_rate            (1'b0),

    .vid_clk48               (aud_embed_clk48),

    //Audio input interface
    .aud_clk                 (aud_embed_clk),
    .aud_de                  (aud_embed_de),
    .aud_ws                  (aud_embed_ws),
    .aud_data                (aud_embed_data),

    //Video output interface
    .vid_out_datavalid       (vid_embed_out_datavalid),
    .vid_out_trs             (vid_embed_out_trs),
    .vid_out_ln              (vid_embed_out_ln),
    .vid_out_data            (vid_embed_out));
  
  //---------------------------------------------------------------------------
  // EXTRACT
  //---------------------------------------------------------------------------
  audio_extract_top u_audio_extract_0(
    .reg_clk                 (reg_clk),
    .reg_reset               (simulation_reset),
    .reset                   (simulation_reset),

    //Register interface (Avalon-MM Slave)
    .reg_base_addr           (reg_base_addr),
    .reg_burstcount          (reg_burstcount),
    .reg_waitrequest         (reg_waitrequest_extract),

    .reg_write               (reg_write_extract),
    .reg_writedata           (reg_writedata),
    .reg_read                (reg_read_extract),
    .reg_readdatavalid       (reg_readdatavalid_extract),
    .reg_readdata            (reg_readdata_extract),

    //Video input interface
    .vid_clk                 (sim_vid_clk),
    .vid_std                 (sim_std),
    .vid_datavalid           (vid_embed_out_datavalid),
    .vid_data                (vid_embed_out),
    .vid_locked              (sim_vid_locked),

    //Audio clocks output interface
    .fix_clk                 (fix_clk),
    .aud_clk_out             (aud_extract_clk_out),
    .aud_clk48_out           (),

    //Audio output interface
    .aud_clk                 (aud_extract_clk_out),
    .aud_ws_in               (1'b0),
    .aud_de                  (aud_extract_de),
    .aud_ws                  (aud_extract_ws),
    .aud_z                   (),
    .aud_data                (aud_extract_data));
  
  generate 
  if (G_INCLUDE_AVALON_ST == 1) begin : g_cai_source 
    genvar I;
    for (I = 0; I <= (2*C_AUDEMB_NUM_GROUPS)-1; I = I + 1) begin
      clocked_audio_input_top u_clocked_audio_input_0(
        .reg_clk                 (reg_clk),
        .reg_reset               (simulation_reset),
        .reset                   (simulation_reset),
    
        //Register interface (Avalon-MM Slave)
        .reg_base_addr           (reg_base_addr[2:0]),
        .reg_burstcount          (reg_burstcount[2:0]),
        .reg_waitrequest         (reg_waitrequest_cai),
    
        .reg_write               (reg_write_cai),
        .reg_writedata           (reg_writedata),
        .reg_read                (reg_read_cai),
        .reg_readdatavalid       (reg_readdatavalid_cai),
        .reg_readdata            (reg_readdata_cai),
    
        //Audio input interface
        .aes_clk                 (aud_extract_clk_out),
        .aes_de                  (aud_extract_de),
        .aes_ws                  (aud_extract_ws),
        .aes_data                (aud_extract_data),
    
        //Audio output interface
        .aud_clk                 (aud_extract_clk_out),
        .aud_ready               (avalon_emb_aud_ready[I]),
        .aud_valid               (avalon_emb_aud_valid[I]),
        .aud_sop                 (avalon_emb_aud_sop[I]),
        .aud_eop                 (avalon_emb_aud_eop[I]),
        .aud_channel             (avalon_emb_aud_channel[(I*8)+7:(I*8)]),
        .aud_data                (avalon_emb_aud_data[(I*24)+23:(I*24)]));
    end
  end else begin : g_cai
    clocked_audio_input_top u_clocked_audio_input_0(
      .reg_clk                 (reg_clk),
      .reg_reset               (simulation_reset),
      .reset                   (simulation_reset),

      //Register interface (Avalon-MM Slave)
      .reg_base_addr           (reg_base_addr[2:0]),
      .reg_burstcount          (reg_burstcount[2:0]),
      .reg_waitrequest         (reg_waitrequest_cai),
  
      .reg_write               (reg_write_cai),
      .reg_writedata           (reg_writedata),
      .reg_read                (reg_read_cai),
      .reg_readdatavalid       (reg_readdatavalid_cai),
      .reg_readdata            (reg_readdata_cai),
  
      //Audio input interface
      .aes_clk                 (aud_extract_clk_out),
      .aes_de                  (aud_extract_de),
      .aes_ws                  (aud_extract_ws),
      .aes_data                (aud_extract_data),
  
      //Audio output interface
      .aud_clk                 (reg_clk),
      .aud_ready               (avalon_aud_ready),
      .aud_valid               (avalon_aud_valid),
      .aud_sop                 (avalon_aud_sop),
      .aud_eop                 (avalon_aud_eop),
      .aud_channel             (avalon_aud_channel),
      .aud_data                (avalon_aud_data));  
  end
  endgenerate
  
  generate
  if (G_INCLUDE_AVALON_ST == 1) begin : u_audemb_avalon
    audio_embed_avalon_top u_audio_embed_avalon_1(
      .fix_clk                 (reg_clk),
      .reg_clk                 (reg_clk),
      .reg_reset               (simulation_reset),
      .reset                   (simulation_reset),
  
      //Register interface (Avalon-MM Slave)
      .reg_base_addr           (reg_base_addr),
      .reg_burstcount          (reg_burstcount),
      .reg_waitrequest         (reg_waitrequest_embed),
  
      .reg_write               (reg_write_embed),
      .reg_writedata           (reg_writedata),
      .reg_read                (reg_read_embed),
      .reg_readdatavalid       (reg_readdatavalid_embed),
      .reg_readdata            (reg_readdata_embed),
  
      //Video input interface
      .vid_clk                 (sim_vid_clk),
      .vid_std                 (sim_std),
      .vid_datavalid           (sim_vid_datavalid),
      .vid_data                (sim_vid_data),
  
      .vid_std_rate            (1'b0),
  
      .vid_clk48               (aud_embed_clk48),
  
      //Avalon Audio input interface
      .aud0_clk                (aud_extract_clk_out),
      .aud0_ready              (avalon_emb_aud_ready[0]),
      .aud0_valid              (avalon_emb_aud_valid[0]),
      .aud0_sop                (avalon_emb_aud_sop[0]),
      .aud0_eop                (avalon_emb_aud_eop[0]),
      .aud0_channel            (avalon_emb_aud_channel[7:0]),
      .aud0_data               (avalon_emb_aud_data[23:0]),
      .aud1_clk                (aud_extract_clk_out),
      .aud1_ready              (avalon_emb_aud_ready[1]),
      .aud1_valid              (avalon_emb_aud_valid[1]),
      .aud1_sop                (avalon_emb_aud_sop[1]),
      .aud1_eop                (avalon_emb_aud_eop[1]),
      .aud1_channel            (avalon_emb_aud_channel[15:8]),
      .aud1_data               (avalon_emb_aud_data[47:24]),
      .aud2_clk                (aud_extract_clk_out),
      .aud2_ready              (avalon_emb_aud_ready[2]),
      .aud2_valid              (avalon_emb_aud_valid[2]),
      .aud2_sop                (avalon_emb_aud_sop[2]),
      .aud2_eop                (avalon_emb_aud_eop[2]),
      .aud2_channel            (avalon_emb_aud_channel[23:16]),
      .aud2_data               (avalon_emb_aud_data[71:48]), 
      .aud3_clk                (aud_extract_clk_out),
      .aud3_ready              (avalon_emb_aud_ready[3]),
      .aud3_valid              (avalon_emb_aud_valid[3]),
      .aud3_sop                (avalon_emb_aud_sop[3]),
      .aud3_eop                (avalon_emb_aud_eop[3]),
      .aud3_channel            (avalon_emb_aud_channel[31:24]),
      .aud3_data               (avalon_emb_aud_data[95:72]),
      .aud4_clk                (aud_extract_clk_out),
      .aud4_ready              (avalon_emb_aud_ready[4]),
      .aud4_valid              (avalon_emb_aud_valid[4]),
      .aud4_sop                (avalon_emb_aud_sop[4]),
      .aud4_eop                (avalon_emb_aud_eop[4]),
      .aud4_channel            (avalon_emb_aud_channel[39:32]),
      .aud4_data               (avalon_emb_aud_data[119:96]),
      .aud5_clk                (aud_extract_clk_out),
      .aud5_ready              (avalon_emb_aud_ready[5]),
      .aud5_valid              (avalon_emb_aud_valid[5]),
      .aud5_sop                (avalon_emb_aud_sop[5]),
      .aud5_eop                (avalon_emb_aud_eop[5]),
      .aud5_channel            (avalon_emb_aud_channel[47:40]),
      .aud5_data               (avalon_emb_aud_data[143:120]), 
      .aud6_clk                (aud_extract_clk_out),
      .aud6_ready              (avalon_emb_aud_ready[6]),
      .aud6_valid              (avalon_emb_aud_valid[6]),
      .aud6_sop                (avalon_emb_aud_sop[6]),
      .aud6_eop                (avalon_emb_aud_eop[6]),
      .aud6_channel            (avalon_emb_aud_channel[55:48]),
      .aud6_data               (avalon_emb_aud_data[167:144]), 
      .aud7_clk                (aud_extract_clk_out),
      .aud7_ready              (avalon_emb_aud_ready[7]),
      .aud7_valid              (avalon_emb_aud_valid[7]),
      .aud7_sop                (avalon_emb_aud_sop[7]),
      .aud7_eop                (avalon_emb_aud_eop[7]),
      .aud7_channel            (avalon_emb_aud_channel[63:56]),
      .aud7_data               (avalon_emb_aud_data[191:168]),         

      //Video output interface
      .vid_out_datavalid       (vid_avalon_embed_out_datavalid),
      .vid_out_trs             (vid_avalon_embed_out_trs),
      .vid_out_ln              (vid_avalon_embed_out_ln),
      .vid_out_data            (vid_avalon_embed_out));
  end
  endgenerate

  //---------------------------------------------------------------------------
  // EXTRACT
  //---------------------------------------------------------------------------
  
  generate
  if (G_INCLUDE_AVALON_ST == 1) begin : g_audext_avalon
    audio_extract_avalon_top u_audio_extract_avalon_1(
      .reg_clk                 (reg_clk),
      .reg_reset               (simulation_reset),
      .reset                   (simulation_reset),
    
      //Register interface (Avalon-MM Slave)
      .reg_base_addr           (reg_base_addr),
      .reg_burstcount          (reg_burstcount),
      .reg_waitrequest         (reg_waitrequest_extract),
    
      .reg_write               (reg_write_extract),
      .reg_writedata           (reg_writedata),
      .reg_read                (reg_read_extract),
      .reg_readdatavalid       (reg_readdatavalid_extract_avalon),
      .reg_readdata            (reg_readdata_extract_avalon),
    
      //Video input interface
      .vid_clk                 (sim_vid_clk),
      .vid_std                 (sim_std),
      .vid_datavalid           (vid_avalon_embed_out_datavalid),
      .vid_data                (vid_avalon_embed_out),
      .vid_locked              (sim_vid_locked),
    
      //Audio clocks output interface
      .fix_clk                 (fix_clk),
      .aud_clk_out             (aud_avalon_extract_clk_out),
      .aud_clk48_out           (),
    
      //Avalon Audio output interface
      .aud_clk                 (aud_avalon_extract_clk_out),
      .aud_ready               (avalon_ext_aud_ready),
      .aud_valid               (avalon_ext_aud_valid),
      .aud_sop                 (avalon_ext_aud_sop),
      .aud_eop                 (avalon_ext_aud_eop),
      .aud_channel             (avalon_ext_aud_channel),
      .aud_data                (avalon_ext_aud_data));
  end
  endgenerate
  
  generate 
  if (G_INCLUDE_AVALON_ST == 1) begin : g_cao_sink
    clocked_audio_output_top u_clocked_audio_output_0(
      .reg_clk                 (reg_clk),
      .reg_reset               (simulation_reset),
      .reset                   (simulation_reset),

      //Register interface (Avalon-MM Slave)
      .reg_base_addr           (reg_base_addr[2:0]),
      .reg_burstcount          (reg_burstcount[2:0]),
      .reg_waitrequest         (reg_waitrequest_cao),
  
      .reg_write               (reg_write_cao),
      .reg_writedata           (reg_writedata),
      .reg_read                (reg_read_cao),
      .reg_readdatavalid       (reg_readdatavalid_cao),
      .reg_readdata            (reg_readdata_cao),
  
      //Audio Input interface (Avalon-ST Audio)
      .aud_clk                 (aud_avalon_extract_clk_out),
      .aud_ready               (avalon_ext_aud_ready),
      .aud_valid               (avalon_ext_aud_valid),
      .aud_sop                 (avalon_ext_aud_sop),
      .aud_eop                 (avalon_ext_aud_eop),
      .aud_channel             (avalon_ext_aud_channel),
      .aud_data                (avalon_ext_aud_data),
  
      //Audio output interface
      .aes_clk                 (aud_avalon_extract_clk_out),
      .aes_de                  (),
      .aes_ws                  (aes_avalon_ws),
      .aes_data                (aes_avalon_data));
  end else begin : g_cao
    clocked_audio_output_top u_clocked_audio_output_0(
      .reg_clk                 (reg_clk),
      .reg_reset               (simulation_reset),
      .reset                   (simulation_reset),

      //Register interface (Avalon-MM Slave)
      .reg_base_addr           (reg_base_addr[2:0]),
      .reg_burstcount          (reg_burstcount[2:0]),
      .reg_waitrequest         (reg_waitrequest_cao),
  
      .reg_write               (reg_write_cao),
      .reg_writedata           (reg_writedata),
      .reg_read                (reg_read_cao),
      .reg_readdatavalid       (reg_readdatavalid_cao),
      .reg_readdata            (reg_readdata_cao),
  
      //Audio Input interface (Avalon-ST Audio)
      .aud_clk                 (reg_clk),
      .aud_ready               (avalon_aud_ready),
      .aud_valid               (avalon_aud_valid),
      .aud_sop                 (avalon_aud_sop),
      .aud_eop                 (avalon_aud_eop),
      .aud_channel             (avalon_aud_channel),
      .aud_data                (avalon_aud_data),
  
      //Audio output interface
      .aes_clk                 (aud_extract_clk_out),
      .aes_de                  (),
      .aes_ws                  (aes_avalon_ws),
      .aes_data                (aes_avalon_data));
  end
  endgenerate
  
  wire aud_clk_out;
  assign aud_clk_out = (G_INCLUDE_AVALON_ST == 1) ? aud_avalon_extract_clk_out : aud_extract_clk_out;
  
  //---------------------------------------------------------------------------
  // SERIAL TO PARALLEL (for AES Avalon)
  //---------------------------------------------------------------------------
  //always @(posedge aud_avalon_extract_clk_out)
  always @(posedge aud_clk_out)
  begin
    begin
      aes_avalon_ws_d1 <= aes_avalon_ws;
      aes_avalon_shift <= {aes_avalon_data , aes_avalon_shift[31:1]};
      if (aes_avalon_ws != aes_avalon_ws_d1) begin
        aes_avalon_valid <= 1'b1;
        aes_avalon_last_sample <= aes_avalon_sample;
        aes_avalon_sample <= {aes_avalon_data , aes_avalon_shift[31:1]};
      end else begin
        aes_avalon_valid <= 1'b0;
      end
    end
  end
  
  //reg [2:0] duplicate_count_av = 0;
  //always @(posedge aud_avalon_extract_clk_out)
  always @(posedge aud_clk_out)
  begin : vhdl2v_17
    reg [18:0] aes_avalon_last_sample_p1;
    reg aes_avalon_odd_count_error;
    reg aes_avalon_even_count_error;
    
    begin
      aes_avalon_last_sample_p1 = aes_avalon_last_sample[26:8] + 1;
      if (aes_avalon_valid == 1'b1 && aes_avalon_sim_checker_enable == 1'b1) begin
        if (aes_avalon_sample[0] == 1'b0 && |(aes_avalon_last_sample) != 1'b0 && aes_avalon_sample[26:8] != aes_avalon_last_sample_p1) begin
          //if (aes_avalon_sample[26:8] == aes_avalon_last_sample[26:8]) begin
            //duplicate_count_av <= duplicate_count_av + 1;
            //if (duplicate_count_av <= 2)
            //  aes_avalon_even_count_error = 1'b0;
            //else
            //  aes_avalon_even_count_error = 1'b1;
          //end else begin
            aes_avalon_even_count_error = 1'b1;
          //end
        end else begin
          //duplicate_count_av <= 0;
          aes_avalon_even_count_error = 1'b0;
        end
        
        if (aes_avalon_sample[0] == 1'b1 && |(aes_avalon_last_sample) != 1'b0 && aes_avalon_sample[26:4] != aes_avalon_last_sample[26:4]) begin
          aes_avalon_odd_count_error = 1'b1;
        end else begin
          aes_avalon_odd_count_error = 1'b0;
        end
      end

      if (aes_avalon_valid == 1'b1) begin
        $display("Received Audio Sample [0x%X] (Avalon)", aes_avalon_sample);
      end

      if (aes_avalon_valid == 1'b1 && aes_avalon_sim_checker_enable == 1'b1) begin
        if (aes_avalon_last_sample[0] == aes_avalon_sample[0] || aes_avalon_sample[0] != aes_avalon_sample[27] || aes_avalon_odd_count_error == 1'b1 || aes_avalon_even_count_error == 1'b1) begin
          if (&(aes_avalon_sim_errors) != 1'b1) begin
            $display("Audio Error (Avalon)");
            aes_avalon_sim_errors <= aes_avalon_sim_errors + 1;
          end
        end
      end
    end
  end
  
  generate
  if (G_INCLUDE_AVALON_ST == 1) begin : g_check_aes_avalon   
    // Main thread
    initial
      begin : vhdl2v_18
      integer I;
  
      aes_avalon_sim_checker_enable <= 1'b0;
      simulation_reset <= 1'b1;
      #(1000000);
      simulation_reset <= 1'b0;
      #(1000000);
      
      // Write the Audio Embed (Avalon) as well
      $display("Write Embed Control Register");
      avalon_write_embed(8'h00, 8'h03);
      $display("Write CS Control Register");
      avalon_write_embed(8'h04, 8'h55);
      
      // Write the Audio Extract (Avalon) as well
      $display("Write Extract Control Register");
      avalon_write_extract(8'h00, 8'h01);
      
      $display("Read Extract Status Register (Avalon)");
      avalon_read_extract_avalon(8'h01, read_data_avalon);
      $display("Read value = [0x%X]", read_data_avalon);
  
      // CAI SOURCE
      $display("Write Clocked Audio Input Registers");
      avalon_write_cai(8'h00, 8'h01);
      avalon_write_cai(8'h01, 8'h02);
        
      // CAO SINK
      $display("Write Clocked Audio Output Registers");
      avalon_write_cao(8'h00, 8'h01);
      avalon_write_cao(8'h01, 8'h02);
         
      #(400000000);
            
      #(2000000000); //2 ms
      #(2000000000);
      #(2000000000);
      #(2000000000);
      #(2000000000);    
      #(2000000000);
      #(2000000000);
      #(2000000000);
      
      $display(" ");
      $display("Starting Error Checking");
      $display("-----------------------");
      aes_avalon_sim_checker_enable <= 1'b1;
      $display("Reset Error Status Register");
      avalon_write_extract(8'h04, 8'hFF);
            
      #(2000000000);
      #(2000000000);
      #(2000000000);
      #(2000000000);
      #(2000000000);
      
      $display(" ");
      $display("Read Extract Channel Status RAM");
      for (I = 0; I <= 23; I = I + 1) begin
        avalon_read_extract_avalon((8'h10 + I), read_data_avalon);
        $display("Read value [0x%X]", I, " = [0x%X]", read_data_avalon);
      end
  
      $display(" ");
      $display("Read Extract Error Status Register");
      avalon_read_extract_avalon(8'h04, read_data_avalon);
      $display("Read value = [0x%X]", read_data_avalon);
      
      $display(" ");
      $display("Finishing Checks");
      $display("----------------");
      
      $display(" ");
      $display("--------");
      $display("Avalon Errors = [0x%X]" , aes_avalon_sim_errors);
      $display("--------");
            
      //end_simulation <= 1'b1;
      $display("--------");
      if (read_data_avalon == 0 && aes_avalon_sim_errors == 0) begin
        $display("Test Pass");
      end else begin
        $display("Test Fail");
      end
      $display("--------");
      $display("Finished");
      $finish(0);
    end
  end else begin : g_check_aes
    //---------------------------------------------------------------------------
    // SERIAL TO PARALLEL (for AES)
    //---------------------------------------------------------------------------
    always @(posedge aud_extract_clk_out)
    begin
      begin
        aud_extract_ws_d1 <= aud_extract_ws;
        aud_extract_shift <= {aud_extract_data[0] , aud_extract_shift[31:1]};
        if (aud_extract_ws != aud_extract_ws_d1) begin
          aud_extract_valid <= 1'b1;
          aud_extract_last_sample <= aud_extract_sample;
          aud_extract_sample <= {aud_extract_data[0] , aud_extract_shift[31:1]};
        end else begin
          aud_extract_valid <= 1'b0;
        end
      end
    end
  
    //reg [2:0] duplicate_count = 0;
    always @(posedge aud_extract_clk_out)
    begin : vhdl2v_19
      reg [18:0] aud_extract_last_sample_p1;
      reg odd_count_error;
      reg even_count_error;

      begin
        aud_extract_last_sample_p1 = aud_extract_last_sample[26:8] + 1;
        if (aud_extract_valid == 1'b1 && sim_checker_enable == 1'b1) begin
          if (aud_extract_sample[0] == 1'b0 && |(aud_extract_last_sample) != 1'b0 && aud_extract_sample[26:8] != aud_extract_last_sample_p1) begin
            //if (aud_extract_sample[26:8] == aud_extract_last_sample[26:8]) begin
            //  duplicate_count <= duplicate_count + 1;
            //  if (duplicate_count <= 2)
            //    even_count_error = 1'b0;
            //  else
            //    even_count_error = 1'b1;
            //end else begin
              even_count_error = 1'b1;
            //end
          end else begin
            //duplicate_count <= 0;
            even_count_error = 1'b0;
          end
          
          if (aud_extract_sample[0] == 1'b1 && |(aud_extract_last_sample) != 1'b0 && aud_extract_sample[26:4] != aud_extract_last_sample[26:4]) begin
            odd_count_error = 1'b1;
          end else begin
            odd_count_error = 1'b0;
          end
        end
      
        if (aud_extract_valid == 1'b1) begin
          $display("Received Audio Sample [0x%X]", aud_extract_sample);
        end
  
        if (aud_extract_valid == 1'b1 && sim_checker_enable == 1'b1) begin
          if (aud_extract_last_sample[0] == aud_extract_sample[0] || aud_extract_sample[0] != aud_extract_sample[27] || odd_count_error == 1'b1 || even_count_error == 1'b1) begin
            if (&(sim_errors) != 1'b1) begin
              $display("Audio Error");
              sim_errors <= sim_errors + 1;
            end
          end
        end
      end
    end
    
    /*
    // Verify the audio outputs from CAO is matching with the audio outputs from Extract
    reg [31:0] aud_extract_sample_dly = {32{1'b0}};
    reg [31:0] aud_extract_sample_dly1 = {32{1'b0}};
    reg [31:0] aud_extract_sample_dly2 = {32{1'b0}};
    reg [31:0] aud_extract_sample_dly3 = {32{1'b0}};
    reg [31:0] aud_extract_sample_dly4 = {32{1'b0}};
    reg [31:0] aud_extract_sample_dly5 = {32{1'b0}};
    reg [31:0] aud_extract_sample_dly6 = {32{1'b0}};
    always @ (posedge aud_extract_clk_out)
    begin
      if (aud_extract_valid) begin
        aud_extract_sample_dly  <= aud_extract_sample;
        aud_extract_sample_dly1 <= aud_extract_sample_dly;
        aud_extract_sample_dly2 <= aud_extract_sample_dly1;
        aud_extract_sample_dly3 <= aud_extract_sample_dly2;
        aud_extract_sample_dly4 <= aud_extract_sample_dly3;
        aud_extract_sample_dly5 <= aud_extract_sample_dly4;
        aud_extract_sample_dly6 <= aud_extract_sample_dly5;
      end
    end
        
    reg [7:0] mismatch = {8{1'b0}};
    always @ (posedge aud_extract_clk_out)
    begin
      if (aes_avalon_sim_checker_enable && aes_avalon_valid && (aud_extract_sample_dly6 != aes_avalon_sample)) begin
        mismatch <= mismatch + 1;
      end
    end
    */
    
    // Main thread
    initial
    begin : vhdl2v_20
    integer I;
  
      sim_checker_enable <= 1'b0;
      aes_avalon_sim_checker_enable <= 1'b0;
      simulation_reset <= 1'b1;
      #(1000000);
      simulation_reset <= 1'b0;
      #(1000000);
  
      $display("Write Embed Control Register");
      avalon_write_embed(8'h00, 8'h03);
      $display("Write CS Control Register");
      avalon_write_embed(8'h04, 8'h55);
      
      $display("Write Extract Control Register");
      avalon_write_extract(8'h00, 8'h01);
      $display("Read Extract Status Register");
      avalon_read_extract(8'h01, read_data);
      $display("Read value = [0x%X]", read_data);
  
      $display("Write Clocked Audio Input Registers");
      avalon_write_cai(8'h00, 8'h01);
      avalon_write_cai(8'h01, 8'h02);
          
      $display("Write Clocked Audio Output Registers");
      avalon_write_cao(8'h00, 8'h01);
      avalon_write_cao(8'h01, 8'h02);
         
      #(400000000);
      $display(" ");
      $display("Starting Error Checking");
      $display("-----------------------");
      sim_checker_enable <= 1'b1;
      $display("Reset Error Status Register");
      avalon_write_extract(8'h04, 8'hFF);      
  
      #(2000000000); //2 ms
      #(2000000000);
      $display(" ");
      $display("Finishing Checks");
      $display("----------------");
  
      $display(" ");
      $display("Read Extract Channel Status RAM");
      for (I = 0; I <= 23; I = I + 1) begin
        avalon_read_extract((8'h10 + I), read_data);
        $display("Read value [0x%X]", I, " = [0x%X]", read_data);
      end
  
      $display(" ");
      $display("Read Extract Error Status Register");
      avalon_read_extract(8'h04, read_data);
      $display("Read value = [0x%X]", read_data);
  
      $display(" ");
      $display("--------");
      $display("Errors = [0x%X]" , sim_errors);
      $display("--------");
  
      //$finish(0);  
      
      #(2000000000);
      #(2000000000);
      
      aes_avalon_sim_checker_enable <= 1'b1;
      
      #(2000000000);
      #(2000000000);       
      #(2000000000);
      #(2000000000);
      #(2000000000);
      #(2000000000);
      #(2000000000);
      #(2000000000);
      #(2000000000);
      
      $display(" ");
      $display("Read Extract Channel Status RAM");
      for (I = 0; I <= 23; I = I + 1) begin
        avalon_read_extract((8'h10 + I), read_data);
        $display("Read value [0x%X]", I, " = [0x%X]", read_data);
      end
            
      $display("");
      $display("Read Extract Error Status Register");
      avalon_read_extract(8'h04, read_data);
      $display("Read value = [0x%X]", read_data);
      $display("");
      
      //end_simulation <= 1'b1;
      $display("--------");
      $display("Errors = [0x%X]" , sim_errors);
      $display("Avalon Errors = [0x%X]" , aes_avalon_sim_errors);
      //if (read_data == 0 && sim_errors == 0 && aes_avalon_sim_errors == 0 && mismatch == 0) begin
      if (read_data == 0 && sim_errors == 0 && aes_avalon_sim_errors == 0) begin
        $display("Test Pass");
      end else begin
        $display("Test Fail");
      end
      $display("--------");
      $display("Finished");
      $finish(0);
    end
  end
  endgenerate
  
endmodule
