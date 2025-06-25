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

module aes_input (
  aes_data,
  aud_clk,
  aud_de,
  aud_ws,
  aud_data);

  input aes_data;
  input aud_clk;
  output aud_de;
  reg aud_de;
  output aud_ws;
  reg aud_ws;
  output aud_data;
  reg aud_data;

  reg aes_data_meta;
  reg aes_data_sync;
  reg aes_data_sync_d1;
  reg aes_edge;
  reg [5:0] flywheel;
  reg [5:0] flywheel_length;
  wire flywheel_match;
  reg aes_edge_d1;
  reg aes_edge_d2;
  reg flywheel_match_d1;
  reg flywheel_match_d2;
  reg flywheel_match_d3;
  reg last_match_toggle;
  wire aes_window;
  wire flywheel_window;
  reg [2:0] confidence;
  reg bpm_phase;
  reg mask_prime;
  reg [1:0] mask_count;
  reg [5:0] bpm_sample_count;
  wire sample_point;
  reg [8:0] bpm_shift;
  wire [7:0] preamble_data;
  reg [31:0] aud_shift;

//------------------------------------------------------------------------------
//MODULE BODY
//------------------------------------------------------------------------------

  //---------------------------------------------------------------------------
  // Find Sample Point
  //---------------------------------------------------------------------------
  always @(posedge aud_clk)
  begin
    begin
      aes_data_meta <= aes_data;
      aes_data_sync <= aes_data_meta;
      aes_data_sync_d1 <= aes_data_sync;
    end
  end

  always @(posedge aud_clk)
  begin
    begin
      if (aes_data_sync != aes_data_sync_d1) begin
        aes_edge <= 1'b1;
      end else begin
        aes_edge <= 1'b0;
      end
    end
  end

  always @(posedge aud_clk)
  begin
    begin
      if (aes_edge == 1'b1) begin
        flywheel <= {6{1'b0}};
        if (|(confidence) == 1'b0) begin
          flywheel_length <= flywheel - 6'd1;
        end
      end else if (flywheel_match_d1 == 1'b1 && |(confidence) != 1'b0) begin
        flywheel <= {6{1'b0}};
      end else begin
        flywheel <= flywheel + 6'd1;
      end
    end
  end

  assign flywheel_match = (flywheel == flywheel_length) ? 1'b1 : 1'b0;

  always @(posedge aud_clk)
  begin
    begin
      aes_edge_d1 <= aes_edge;
      aes_edge_d2 <= aes_edge_d1;
      flywheel_match_d1 <= flywheel_match;
      flywheel_match_d2 <= flywheel_match_d1;
      flywheel_match_d3 <= flywheel_match_d2;
    end
  end

  assign aes_window = aes_edge | aes_edge_d1 | aes_edge_d2;
  assign flywheel_window = flywheel_match_d1 | flywheel_match_d2 | flywheel_match_d3;

  always @(posedge aud_clk)
  begin
    begin
      if (flywheel_match_d2 == 1'b1) begin
        last_match_toggle <= aes_window;
      end
    end
  end

  always @(posedge aud_clk)
  begin
    begin
      if (aes_edge_d1 == 1'b1) begin
        if (flywheel_window == 1'b1 && confidence != 3'b111) begin
          confidence <= confidence + 3'd1;
        end else if (flywheel_window == 1'b0 && confidence != 3'b000) begin
          confidence <= confidence - 3'd1;
        end
      end else if (flywheel_match_d2 == 1'b1) begin
        if (aes_window == 1'b1 && confidence != 3'b111) begin
          confidence <= confidence + 3'd1;
        end else if (aes_window == 1'b0 && last_match_toggle == 1'b0 && confidence != 3'b000) begin
          confidence <= confidence - 3'd1;
        end
      end
    end
  end

  always @(posedge aud_clk)
  begin
    begin
      if (flywheel_match_d2 == 1'b1 && aes_window == 1'b0) begin
        mask_prime <= 1'b1;
        if (|(mask_count) != 1'b0) begin
          mask_count <= mask_count - 2'd1;
          bpm_phase <= ~ bpm_phase;
        end else if (mask_prime == 1'b1) begin
          mask_count <= 2'b10;
          bpm_phase <= ~ bpm_phase;
        end else begin
          bpm_phase <= 1'b1;
        end
      end else if (flywheel_match_d2 == 1'b1) begin
        mask_prime <= 1'b0;
        bpm_phase <= ~ bpm_phase;
      end
    end
  end

  always @(posedge aud_clk)
  begin
    begin
      if (aes_edge == 1'b1 || bpm_sample_count == (flywheel_length + 6'd1)) begin
        bpm_sample_count <= {6{1'b0}};
      end else begin
        bpm_sample_count <= bpm_sample_count + 6'd1;
      end
    end
  end

  assign sample_point = (bpm_sample_count == {1'b0 , flywheel_length[5:1]}) ? 1'b1 : 1'b0;

  //---------------------------------------------------------------------------
  // BPM Decode
  //---------------------------------------------------------------------------
  always @(posedge aud_clk)
  begin
    begin
      if (sample_point == 1'b1) begin
        bpm_shift <= {bpm_shift[7:0] , aes_data_sync_d1};

        if (preamble_data == 8'b11100010 || preamble_data == 8'b00011101) begin //X = 0000b
          bpm_shift <= 9'b011001100;
        end else if (preamble_data == 8'b11100100 || preamble_data == 8'b00011011) begin //Y = 1000b
          bpm_shift <= 9'b010110011;
        end else if (preamble_data == 8'b11101000 || preamble_data == 8'b00010111) begin //Z = 0100b
          bpm_shift <= 9'b011010011;
        end

      end
    end
  end

  assign preamble_data = {bpm_shift[6:0] , aes_data_sync_d1};

  always @(posedge aud_clk)
  begin
    begin
      if (sample_point == 1'b1 && bpm_phase == 1'b1) begin
        aud_de <= 1'b1;
        if (preamble_data == 8'b11100010 || preamble_data == 8'b00011101 || preamble_data == 8'b11101000 || preamble_data == 8'b00010111) begin
          aud_ws <= 1'b0;
        end else if (preamble_data == 8'b11100100 || preamble_data == 8'b00011011) begin
          aud_ws <= 1'b1;
        end
        if (bpm_shift[8] != bpm_shift[7]) begin
          aud_data <= 1'b1;
          aud_shift <= {1'b1 , aud_shift[31:1]};
        end else begin
          aud_data <= 1'b0;
          aud_shift <= {1'b0 , aud_shift[31:1]};
        end
      end else begin
        aud_de <= 1'b0;
      end
    end
  end

endmodule
