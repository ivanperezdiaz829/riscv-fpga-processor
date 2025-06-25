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

module frb_timing_gen (
  vid_clk,
  vid_clk_en,
  vid_reset,

  // control interface
  timing_std,
  h_limit,
  h_sav,
  v_limit,
  v1_start,
  v1_end,
  v2_start,
  v2_end,
  f1_start,
  f2_start,

  // test video out
  vid_tim_en,
  vid_tim_ync,
  vid_tim_trs,
  vid_tim_fvh,
  vid_tim_pic,
  vid_tim_data);

  `include "src_common/frb_include_smpte352m.v"

  input vid_clk;
  input vid_clk_en;
  input vid_reset;

  // control interface
  input [31:0] timing_std;
  input [14:0] h_limit;
  input [14:0] h_sav;
  input [10:0] v_limit;
  input [10:0] v1_start;
  input [10:0] v1_end;
  input [10:0] v2_start;
  input [10:0] v2_end;
  input [10:0] f1_start;
  input [10:0] f2_start;

  // test video out
  output vid_tim_en;
  reg vid_tim_en;
  output [1:0] vid_tim_ync;
  wire [1:0] vid_tim_ync;
  output vid_tim_trs;
  reg vid_tim_trs;
  output [2:0] vid_tim_fvh;
  wire [2:0] vid_tim_fvh;
  output vid_tim_pic;
  reg vid_tim_pic;
  output [19:0] vid_tim_data;
  reg [19:0] vid_tim_data;

  reg [2:0] s_limit;
  reg ntsc;
  wire [14:0] h_limit_adj;
  wire [14:0] h_sav_adj;
  reg [2:0] s_counter;
  reg s_en;
  reg [14:0] h_counter;
  reg [10:0] v_counter;
  reg eav_insert;
  reg sav_insert;
  reg h_max;
  reg v_max;
  reg [4:0] trs_count;
  reg [4:0] trs_count_d1;
  reg eav_insert_d1;
  reg eav_insert_d2;
  reg sav_insert_d1;
  reg v1_start_match;
  reg v1_end_match;
  reg v2_start_match;
  reg v2_end_match;
  reg early_pic;
  reg early_f;
  reg f1_start_match;
  reg f2_start_match;
  reg early_v;
  reg ntsc_v;
  reg early_h;
  reg early_trs;
  reg last_v;
  reg [10:0] early_line;
  reg [19:0] early_data;
  reg [2:0] delay_h_count;
  reg delay_h;
  reg vid_tim_ync_int;
  reg [2:0] vid_tim_fvh_int;
  reg vid_sd;
  reg vid_3gb;
  wire [9:0] early_data_array [7:0];

//------------------------------------------------------------------------------
//MODULE BODY
//------------------------------------------------------------------------------

  //---------------------------------------------------------------------------
  // Select the stream to be made
  //---------------------------------------------------------------------------
  always @(posedge vid_clk)
  begin
    begin
      if (timing_std[27:24] == `C_INTERFACE_SD_270) begin
        vid_sd <= 1'b1;
        vid_3gb <= 1'b0;
        s_limit <= {3{1'b0}};
      end else if (timing_std[27:24] == `C_INTERFACE_720_1G5 || timing_std[27:24] == `C_INTERFACE_720_3G) begin
        vid_sd <= 1'b0;
        vid_3gb <= 1'b0;
        s_limit <= {3{1'b0}};
      end else if (timing_std[27:24] == `C_INTERFACE_DL_3G || timing_std[27:24] == `C_INTERFACE_720_3G_DS || timing_std[27:24] == `C_INTERFACE_1080_3G_DS) begin
        vid_sd <= 1'b0;
        vid_3gb <= 1'b1;
        s_limit <= 3'b001;
      end else begin
        vid_sd <= 1'b0;
        vid_3gb <= 1'b0;
        s_limit <= {3{1'b0}};
      end

    end
  end

  //---------------------------------------------------------------------------
  // Standard Decode
  //---------------------------------------------------------------------------
  always @(posedge vid_clk)
  begin
    begin
      if (timing_std[27:24] == `C_INTERFACE_SD_270 && timing_std[19:16] == `C_PICTURE_RATE_29) begin
        ntsc <= 1'b1;
      end else begin
        ntsc <= 1'b0;
      end

    end
  end

  //---------------------------------------------------------------------------
  // Create Test Counters
  //---------------------------------------------------------------------------
  always @(posedge vid_clk)
  begin
    begin
      if (vid_clk_en == 1'b1) begin
        if (vid_reset == 1'b1) begin
          s_counter <= {3{1'b0}};
          s_en <= 1'b0;
        end else begin
          if (s_counter == s_limit) begin
            s_counter <= {3{1'b0}};
            s_en <= 1'b1;
          end else begin
            s_counter <= s_counter + 3'd1;
            s_en <= 1'b0;
          end
        end
      end

    end
  end

  assign h_limit_adj = (vid_sd == 1'b1) ? h_limit : {1'b0 , h_limit[14:1]};
  assign h_sav_adj = (vid_sd == 1'b1) ? h_sav : {1'b0 , h_sav[14:1]};

  always @(posedge vid_clk)
  begin
    begin
      if (vid_clk_en == 1'b1) begin
        if (vid_reset == 1'b1) begin
          h_counter <= 1;
          v_counter <= 2040;
          eav_insert <= 1'b0;
          sav_insert <= 1'b0;
        end else begin
          if (s_en == 1'b1) begin
            if (h_max == 1'b1) begin
              h_counter <= 15'b000000000000001;
              if (v_max == 1'b1) begin
                v_counter <= 11'b00000000001;
              end else begin
                v_counter <= v_counter + 11'd1;
              end
              eav_insert <= 1'b1;
              sav_insert <= 1'b0;
            end else if (h_counter == h_sav_adj) begin
              h_counter <= h_counter + 15'd1;
              eav_insert <= 1'b0;
              sav_insert <= 1'b1;
            end else begin
              h_counter <= h_counter + 15'd1;
              eav_insert <= 1'b0;
              sav_insert <= 1'b0;
            end
          end
        end
      end

    end
  end

  always @(posedge vid_clk)
  begin
    begin
      if (vid_clk_en == 1'b1) begin
        if (vid_reset == 1'b1) begin
          h_max <= 1'b0;
          v_max <= 1'b0;
        end else begin
          if (s_en == 1'b1) begin
            if (h_counter == h_limit_adj) begin
              h_max <= 1'b1;
            end else begin
              h_max <= 1'b0;
            end
            if (v_counter == v_limit) begin
              v_max <= 1'b1;
            end else begin
              v_max <= 1'b0;
            end
          end
        end
      end

    end
  end

  //---------------------------------------------------------------------------
  // Create Test Video Stream
  //---------------------------------------------------------------------------
  always @(posedge vid_clk)
  begin
    begin
      if (vid_clk_en == 1'b1) begin
        if (vid_reset == 1'b1) begin
          trs_count <= {5{1'b1}};
          eav_insert_d1 <= 1'b0;
          eav_insert_d2 <= 1'b0;
          sav_insert_d1 <= 1'b0;
        end else begin
          if (s_en == 1'b1) begin
            eav_insert_d1 <= eav_insert;
            eav_insert_d2 <= eav_insert_d1;
            sav_insert_d1 <= sav_insert;
            if (eav_insert == 1'b1 || sav_insert == 1'b1) begin
              trs_count <= {5{1'b0}};
            end else if (trs_count[4] == 1'b0) begin
              if (vid_sd == 1'b0) begin
                if (h_counter[8] == 1'b1 && trs_count == 5'b00110) begin // if SAV then do not insert LN & CRC
                  trs_count <= 5'b10000;
                end else begin
                  trs_count <= trs_count + 5'd2;
                end
              end else begin
                if (trs_count == 5'b00110) begin
                  trs_count <= 5'b10000;
                end else begin
                  trs_count <= trs_count + 5'd2;
                end
              end
            end
          end
        end
      end
    end
  end

  always @(posedge vid_clk)
  begin
    begin
      if (vid_clk_en == 1'b1) begin
        if (v_counter == v1_start) begin          v1_start_match <= 1'b1;        end else begin          v1_start_match <= 1'b0;        end
        if (v_counter == v2_start) begin          v2_start_match <= 1'b1;        end else begin          v2_start_match <= 1'b0;        end
        if (v_counter == v1_end) begin          v1_end_match <= 1'b1;        end else begin          v1_end_match <= 1'b0;        end
        if (v_counter == v2_end) begin          v2_end_match <= 1'b1;        end else begin          v2_end_match <= 1'b0;        end
        if (v_counter == f1_start) begin          f1_start_match <= 1'b1;        end else begin          f1_start_match <= 1'b0;        end
        if (v_counter == f2_start) begin          f2_start_match <= 1'b1;        end else begin          f2_start_match <= 1'b0;        end
      end
    end
  end

  always @(posedge vid_clk)
  begin
    begin
      if (vid_clk_en == 1'b1) begin
        if (vid_reset == 1'b1) begin
          early_pic <= 1'b0;
          early_h <= 1'b1;
          early_v <= 1'b1;
          ntsc_v <= 1'b1;
          early_f <= 1'b1;
          last_v <= 1'b1;
        end else begin
          if (s_en == 1'b1) begin
            if (eav_insert_d1 == 1'b1) begin
              if (v_counter == 1) begin
                early_pic <= ~ early_pic;
              end
              early_h <= 1'b1;
              if (v1_end_match == 1'b1 || v2_end_match == 1'b1) begin
                early_v <= 1'b1;
              end else if (v1_start_match == 1'b1 || v2_start_match == 1'b1) begin
                early_v <= 1'b0;
              end
              if (v1_start_match == 1'b1 && ntsc == 1'b1) begin
                ntsc_v <= 1'b1;
              end else begin
                ntsc_v <= 1'b0;
              end
              if (f2_start_match == 1'b1) begin
                early_f <= 1'b1;
              end else if (f1_start_match == 1'b1) begin
                early_f <= 1'b0;
              end
              last_v <= early_v;
            end else if (sav_insert_d1 == 1'b1) begin
              early_h <= 1'b0;
            end
          end
        end
      end

    end
  end

  always @(posedge vid_clk)
  begin
    begin
      if (vid_clk_en == 1'b1) begin
        if (s_en == 1'b1) begin
          if (eav_insert_d2 == 1'b1) begin
            if (early_v == 1'b1) begin
              early_line <= {11{1'b0}};
            end else if (last_v == 1'b1) begin
              if (early_f == 1'b0) begin
                early_line <= 1;
              end else begin
                early_line <= 2;
              end
            end else begin
              if (timing_std[23] == `C_INTERLACE) begin
                early_line <= early_line + 11'd2;
              end else begin
                early_line <= early_line + 11'd1;
              end
            end
          end
        end
      end

    end
  end

  // For The TRS Structure, so the trs generator can cherry pick what it needs.
  assign early_data_array[0] = {10{1'b1}};
  assign early_data_array[1] = {10{1'b0}};
  assign early_data_array[2] = {10{1'b0}};
  assign early_data_array[3] = {1'b1 , early_f , early_v , early_h , (early_v ^ early_h) , (early_f ^ early_h) , (early_f ^ early_v) , (early_f ^ early_v ^ early_h) , 2'b00};
  assign early_data_array[4] = {(~ v_counter[6]) , v_counter[6:0] , 2'b00};
  assign early_data_array[5] = {4'b1000 , v_counter[10:7] , 2'b00};
  assign early_data_array[6] = {(~ early_line[6]) , early_line[6:0] , 2'b00};
  assign early_data_array[7] = {4'b1000 , early_line[10:7] , 2'b00};

  always @(posedge vid_clk)
  begin
    begin
      if (vid_clk_en == 1'b1) begin
        trs_count_d1 <= trs_count;
      end
    end
  end

  always @(posedge vid_clk)
  begin
    begin
      if (vid_clk_en == 1'b1) begin
        if (vid_reset == 1'b1) begin
          early_trs <= 1'b0;
          early_data <= {20{1'b0}};
        end else begin
          //----------------------- 10 Bit Data Path -----------------------
          if (vid_sd == 1'b1) begin
            if (trs_count[4] == 1'b0) begin
              early_data <= {10'b0000000000 , early_data_array[trs_count[3:1]]};
              if (trs_count[3:1] == 3'b000) begin
                early_trs <= 1'b1;
              end else begin
                early_trs <= 1'b0;
              end
            end else if (h_counter[0] == 1'b0) begin
              early_trs <= 1'b0;
              early_data <= {10'b0000000000 , 10'b1000000000};
            end else begin
              early_trs <= 1'b0;
              early_data <= {10'b0000000000 , 10'b0001000000};
            end
          end else if (vid_3gb == 1'b1) begin
          //----------------------- 20 Bit Data Path -----------------------
            if (trs_count_d1[4] == 1'b0) begin
              if (trs_count_d1[3:1] == 3'b000) begin
                early_trs <= 1'b1;
              end else begin
                early_trs <= 1'b0;
              end
              early_data <= {early_data_array[trs_count_d1[3:1]] , early_data_array[trs_count_d1[3:1]]};
            end else begin
              early_trs <= 1'b0;
              if (s_en == 1'b0) begin
                early_data <= {10'b0001000000 , 10'b0001000000}; // Luma
              end else begin
                early_data <= {10'b1000000000 , 10'b1000000000}; // Chroma
              end
            end
          end else begin
          //----------------------- 20 Bit Data Path -----------------------
            if (trs_count[4] == 1'b0) begin
              if (trs_count[3:1] == 3'b000) begin
                early_trs <= 1'b1;
              end else begin
                early_trs <= 1'b0;
              end
              early_data <= {early_data_array[trs_count[3:1]] , early_data_array[trs_count[3:1]]};
            end else begin
              early_trs <= 1'b0;
              if (timing_std[11:8] == `C_STRUCTURE_444_RGB ||
                 timing_std[11:8] == `C_STRUCTURE_4444_RGBA ||
                 timing_std[11:8] == `C_STRUCTURE_4444_RGBD) begin
                early_data <= {10'b0001000000 , 10'b0001000000}; // RGB-Black.
              end else begin
                early_data <= {10'b0001000000 , 10'b1000000000}; // YUV-Black.
              end
            end
          end
        end
      end

    end
  end

  always @(posedge vid_clk)
  begin
    begin
      if (vid_clk_en == 1'b1) begin
        if (vid_reset == 1'b1) begin
          delay_h_count <= {3{1'b0}};
          delay_h <= 1'b0;
        end else begin
          if (s_en == 1'b1) begin
            if (early_h == 1'b1) begin
              delay_h_count <= {3{1'b0}};
              delay_h <= 1'b1;
            end else if (timing_std[27:24] == `C_INTERFACE_SD_270 && delay_h_count != 3'b011) begin
              delay_h_count <= delay_h_count + 3'd1;
              delay_h <= 1'b1;
            end else if (timing_std[27:24] != `C_INTERFACE_SD_270 && delay_h_count != 3'b011) begin
              delay_h_count <= delay_h_count + 3'd1;
              delay_h <= 1'b1;
            end else begin
              delay_h <= 1'b0;
            end
          end
        end
      end

    end
  end

  //---------------------------------------------------------------------------
  // Register Output
  //---------------------------------------------------------------------------
  always @(posedge vid_clk)
  begin
    begin
      if (vid_clk_en == 1'b1) begin
        if (vid_reset == 1'b1) begin
          vid_tim_en <= 1'b0;
          vid_tim_ync_int <= 1'b0;
          vid_tim_trs <= 1'b0;
          vid_tim_fvh_int <= {3{1'b0}};
          vid_tim_pic <= 1'b0;
          vid_tim_data <= {20{1'b0}};
        end else begin
          vid_tim_en <= 1'b1;
          //if (s_en == 1'b1) begin
          if (vid_sd == 1'b0 && vid_3gb == 1'b0) begin
            vid_tim_ync_int <= 1'b1;
          end else if (vid_3gb == 1'b1) begin
            vid_tim_ync_int <= s_en;
          end else begin
            vid_tim_ync_int <= ~ h_counter[0];
          end
          vid_tim_trs <= early_trs;
          vid_tim_fvh_int[2] <= early_f;
          vid_tim_fvh_int[1] <= early_v | ntsc_v;
          vid_tim_fvh_int[0] <= early_h | delay_h;
          vid_tim_pic <= early_pic;
          vid_tim_data <= early_data;
          //end
        end
      end else begin
        vid_tim_en <= 1'b0;
      end

    end
  end
  assign vid_tim_ync = {s_en , vid_tim_ync_int};
  assign vid_tim_fvh = vid_tim_fvh_int;

endmodule
