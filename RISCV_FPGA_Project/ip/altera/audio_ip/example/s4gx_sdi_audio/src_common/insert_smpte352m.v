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

module insert_smpte352m (
  vid_clk,
  vid_reset,

  // control inputs
  enable_anc,
  vid_std,

  // video input
  vid_en,
  vid_data,

  // video output
  vid_out_en,
  vid_out_data,
  
  trs,
  ln);

  `include "src_common/include_smpte352m.v"

  input vid_clk;
  input vid_reset;

  // control inputs
  input enable_anc;
  input [31:0] vid_std;

  // video input
  input vid_en;
  input [19:0] vid_data;

  // video output
  output vid_out_en;
  reg vid_out_en;
  output [19:0] vid_out_data;
  reg [19:0] vid_out_data;
  
  // BH
  output trs;
  output [10:0] ln;
  reg [10:0] ln;

  wire vid_ones;
  wire vid_zero;
  reg [2:0] trs_count;
  wire vid_trs;
  reg vid_ync;
  reg [2:0] vid_fvh;
  reg vid_3gb_early;
  reg vid_3gb;
  reg [3:0] eav_count;
  reg hd_eav_end;
  reg [10:0] vid_line_reset;
  reg [10:0] vid_line_limit;
  reg vid_line_limit_found;
  reg [10:0] vid_line;
  wire progressive;
  reg anc_line;
  reg [3:0] anc_count;
  reg anc_insert;
  reg anc_parity_en;
  reg anc_checksum_en;
  reg [9:0] anc_data;
  wire anc_parity;
  reg [8:0] anc_checksum;
  
  reg vid_ones_d1;
  
  // BH
  assign trs = vid_ones_d1;
  
//------------------------------------------------------------------------------
//MODULE BODY
//------------------------------------------------------------------------------

  //---------------------------------------------------------------------------
  // Find TRS Sequence
  //---------------------------------------------------------------------------
  assign vid_ones = (vid_data[9:0] == 10'b1111111111) ? 1'b1 : 1'b0;
  assign vid_zero = (vid_data[9:0] == 10'b0000000000) ? 1'b1 : 1'b0;

  always @(posedge vid_clk)
  begin
    begin
      if (vid_en == 1'b1) begin
		  
		  vid_ones_d1 <= vid_ones; 
		  ln <= vid_line;
		  
        if (vid_ones == 1'b1) begin
          if (trs_count == 3'b111) begin
            trs_count <= trs_count - 3'd1;
          end else begin
            trs_count <= 3'b111;
          end
        end else if (vid_zero == 1'b1 && trs_count != 3'b000) begin
          if (trs_count == 3'b111) begin
            trs_count <= 3'b011;
          end else begin
            trs_count <= trs_count - 3'd1;
          end
          if (trs_count == 3'b101) begin
            vid_3gb_early <= 1'b1;
          end
        end else begin
          trs_count <= 3'b000;
          vid_3gb_early <= 1'b0;
        end
      end
    end
  end

  assign vid_trs = (trs_count == 3'b010) ? 1'b1 : 1'b0;

  always @(posedge vid_clk)
  begin
    begin
      if (vid_en == 1'b1) begin
        if (vid_trs == 1'b1) begin
          vid_3gb <= vid_3gb_early;
        end
      end
    end
  end

  always @(posedge vid_clk)
  begin
    begin
      if (vid_reset == 1'b1) begin
        vid_ync <= 1'b0;
        vid_fvh <= {3{1'b0}};
      end else if (vid_en == 1'b1) begin
        if (vid_trs == 1'b1) begin
          vid_ync <= 1'b1;
        end else begin
          vid_ync <= ~ vid_ync;
        end
        if (vid_trs == 1'b1 && vid_data[6] == 1'b1) begin //EAV
          vid_fvh <= vid_data[8:6];
        end
      end

    end
  end

  always @(posedge vid_clk)
  begin
    begin
      if (vid_reset == 1'b1) begin
        eav_count <= {4{1'b0}};
      end else if (vid_en == 1'b1) begin
        if (vid_trs == 1'b1 && vid_data[6] == 1'b1) begin
          eav_count <= {4{1'b0}};
        end else if (eav_count[3] == 1'b0) begin
          eav_count <= eav_count + 4'd1;
        end
      end

    end
  end

  always @(posedge vid_clk)
  begin
    begin
      if (vid_reset == 1'b1) begin
        hd_eav_end <= 1'b0;
      end else if (vid_en == 1'b1) begin
        if (vid_3gb == 1'b1 && eav_count[2:1] == 2'b11) begin
          hd_eav_end <= 1'b1;
        end else if (vid_3gb == 1'b0 && eav_count[2:0] == 3'b010) begin
          hd_eav_end <= 1'b1;
        end else begin
          hd_eav_end <= 1'b0;
        end
      end

    end
  end

  //---------------------------------------------------------------------------
  // Count line number
  //---------------------------------------------------------------------------
  always @(posedge vid_clk)
  begin
    begin
      if (vid_std[27:24] == `C_INTERFACE_720_1G5 || vid_std[27:24] == `C_INTERFACE_720_3G) begin
        vid_line_reset <= 11'b01011101010;
        vid_line_limit <= 11'b01011101110;
      end else if ((vid_std[27:24] == `C_INTERFACE_1080_1G5 || vid_std[27:24] == `C_INTERFACE_1080_3G || vid_std[27:24] == `C_INTERFACE_DL_3G) && vid_std[23] == `C_INTERLACE) begin
        vid_line_reset <= 11'b01000110001;
        vid_line_limit <= 11'b10001100101;
      end else if ((vid_std[27:24] == `C_INTERFACE_1080_1G5 || vid_std[27:24] == `C_INTERFACE_1080_3G || vid_std[27:24] == `C_INTERFACE_DL_3G)) begin
        vid_line_reset <= 11'b10001100010;
        vid_line_limit <= 11'b10001100101;
      end else if (vid_std[27:24] == `C_INTERFACE_SD_270 && vid_std[19:16] == `C_PICTURE_RATE_29) begin
        vid_line_reset <= 11'b00100001000;
        vid_line_limit <= 11'b01000001101;
      end else begin
        vid_line_reset <= 11'b00100110111;
        vid_line_limit <= 11'b01001110001;
      end
    end
  end

  always @(posedge vid_clk)
  begin
    begin
      if (vid_reset == 1'b1) begin
        vid_line <= {11{1'b0}};
      end else if (vid_en == 1'b1) begin
        if (vid_trs == 1'b1 && vid_data[6] == 1'b1) begin //EAV
          if (vid_line_limit_found == 1'b1) begin
            vid_line <= 11'b00000000001;
          end else if (vid_data[8] == 1'b0 && vid_fvh[1] == 1'b0 && vid_data[7] == 1'b1) begin
            vid_line <= vid_line_reset;
          end else begin
            vid_line <= vid_line + 11'd1;
          end
        end
      end

    end
  end

  always @(posedge vid_clk)
  begin
    begin
      if (vid_line == vid_line_limit) begin
        vid_line_limit_found <= 1'b1;
      end else begin
        vid_line_limit_found <= 1'b0;
      end

    end
  end

  //---------------------------------------------------------------------------
  // Create ANC Packet
  //---------------------------------------------------------------------------
  assign progressive = ((vid_std[27:24] == `C_INTERFACE_1080_1G5 || 
                         vid_std[27:24] == `C_INTERFACE_1080_1G5_DL ||
                         vid_std[27:24] == `C_INTERFACE_1080_3G ||
                         vid_std[27:24] == `C_INTERFACE_DL_3G ||                                           
                         vid_std[27:24] == `C_INTERFACE_1080_3G_DS ||                                           
                         vid_std[27:24] == `C_INTERFACE_IPT)) ? vid_std[23] : vid_std[22];

  always @(posedge vid_clk)
  begin
    begin
      if (vid_std[27:24] == `C_INTERFACE_SD_270 && vid_std[19:16] == `C_PICTURE_RATE_29 && (vid_line == 13 || vid_line == 276)) begin
        anc_line <= 1'b1;
      end else if (vid_std[27:24] == `C_INTERFACE_SD_270 && vid_std[19:16] == `C_PICTURE_RATE_25 && (vid_line == 9 || vid_line == 322)) begin
        anc_line <= 1'b1;
      end else if ((vid_std[27:24] == `C_INTERFACE_720_1G5 || vid_std[27:24] == `C_INTERFACE_1080_1G5 || vid_std[27:24] == `C_INTERFACE_1080_3G || 
      vid_std[27:24] == `C_INTERFACE_DL_3G) && (vid_line == 10 || (progressive == 1'b0 && vid_line == 572))) begin
        anc_line <= 1'b1;
      end else begin
        anc_line <= 1'b0;
      end
    end
  end

  always @(posedge vid_clk)
  begin
    begin
      if (vid_reset == 1'b1) begin
        anc_count <= {4{1'b0}};
        anc_insert <= 1'b0;
      end else if (vid_en == 1'b1 && (vid_3gb == 1'b0 || vid_ync == 1'b1)) begin
        if (hd_eav_end == 1'b1 && anc_line == 1'b1) begin
          anc_count <= {4{1'b0}};
          anc_insert <= 1'b1;
        end else if (anc_count == 4'b1010) begin
          anc_insert <= 1'b0;
        end else begin
          anc_count <= anc_count + 4'd1;
        end
      end
    end
  end

  always @(posedge vid_clk)
  begin
    begin
      if (vid_en == 1'b1 && (vid_3gb == 1'b0 || vid_ync == 1'b1)) begin
        if (hd_eav_end == 1'b1 && anc_line == 1'b1) begin
          anc_parity_en <= 1'b0;
          anc_checksum_en <= 1'b0;
          anc_data <= {10{1'b0}};
        end else if (|(anc_count) == 1'b0) begin
          anc_parity_en <= 1'b0;
          anc_checksum_en <= 1'b0;
          anc_data <= {10{1'b1}};
        end else if (anc_count == 1) begin
          anc_parity_en <= 1'b0;
          anc_checksum_en <= 1'b0;
          anc_data <= {10{1'b1}};
        end else if (anc_count == 2) begin
          anc_parity_en <= 1'b0;
          anc_checksum_en <= 1'b0;
          anc_data <= 10'b1001000001; //DID = 0x241
        end else if (anc_count == 3) begin
          anc_parity_en <= 1'b0;
          anc_checksum_en <= 1'b0;
          anc_data <= 10'b0100000001; //SDID = 0x101
        end else if (anc_count == 4) begin
          anc_parity_en <= 1'b0;
          anc_checksum_en <= 1'b0;
          anc_data <= 10'b0100000100; //DC = 0x104
        end else if (anc_count == 5) begin
          anc_parity_en <= 1'b1;
          anc_checksum_en <= 1'b0;
          anc_data <= {2'b00 , vid_std[31:24]};
        end else if (anc_count == 6) begin
          anc_parity_en <= 1'b1;
          anc_checksum_en <= 1'b0;
          anc_data <= {2'b00 , vid_std[23:16]};
        end else if (anc_count == 7) begin
          anc_parity_en <= 1'b1;
          anc_checksum_en <= 1'b0;
          anc_data <= {2'b00 , vid_std[15:8]};
        end else if (anc_count == 8) begin
          anc_parity_en <= 1'b1;
          anc_checksum_en <= 1'b0;
          anc_data <= {2'b00 , vid_std[7:0]};
        end else begin
          anc_parity_en <= 1'b0;
          anc_checksum_en <= 1'b1;
          anc_data <= {10{1'b0}};
        end
      end
    end
  end

  assign anc_parity = anc_data[7] ^ anc_data[6] ^ anc_data[5] ^ anc_data[4] ^ anc_data[3] ^ anc_data[2] ^ anc_data[1] ^ anc_data[0];

  always @(posedge vid_clk)
  begin
    begin
      if (vid_en == 1'b1 && (vid_3gb == 1'b0 || vid_ync == 1'b1)) begin
        if (anc_count == 3) begin
          anc_checksum <= {anc_parity , anc_data[7:0]};
        end else begin
          anc_checksum <= anc_checksum + {anc_parity , anc_data[7:0]};
        end
      end
    end
  end

  //---------------------------------------------------------------------------
  // Output Corrected Video
  //---------------------------------------------------------------------------
  always @(posedge vid_clk)
  begin
    begin
      vid_out_en <= vid_en;
      if (vid_en == 1'b1) begin
        if (enable_anc == 1'b1 && anc_insert == 1'b1 && (vid_3gb == 1'b0 || vid_ync == 1'b1) && vid_std[27:24] != `C_INTERFACE_SD_270) begin
          if (anc_checksum_en == 1'b1) begin
            vid_out_data[19:10] <= {(~ anc_checksum[8]) , anc_checksum};
          end else if (anc_parity_en == 1'b1) begin
            vid_out_data[19:10] <= {(~ anc_parity) , anc_parity , anc_data[7:0]};
          end else begin
            vid_out_data[19:10] <= anc_data;
          end
          if (vid_std[27:24] == `C_INTERFACE_720_3G || vid_std[27:24] == `C_INTERFACE_1080_3G || vid_std[27:24] == `C_INTERFACE_DL_3G) begin
            if (anc_checksum_en == 1'b1) begin
              vid_out_data[9:0] <= {(~ anc_checksum[8]) , anc_checksum};
            end else if (anc_parity_en == 1'b1) begin
              vid_out_data[9:0] <= {(~ anc_parity) , anc_parity , anc_data[7:0]};
            end else begin
              vid_out_data[9:0] <= anc_data;
            end
          end else begin
            vid_out_data[9:0] <= vid_data[9:0];
          end
        end else begin
          vid_out_data <= vid_data;
        end
      end

    end
  end

endmodule
