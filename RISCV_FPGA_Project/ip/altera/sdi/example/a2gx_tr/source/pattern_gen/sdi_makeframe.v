//--------------------------------------------------------------------------------------------------
// (c)2007 Altera Corporation. All rights reserved.
//
// Altera products are protected under numerous U.S. and foreign patents,
// maskwork rights, copyrights and other intellectual property laws.
//
// This reference design file, and your use thereof, is subject to and governed
// by the terms and conditions of the applicable Altera Reference Design License
// Agreement (either as signed by you or found at www.altera.com).  By using
// this reference design file, you indicate your acceptance of such terms and
// conditions between you and Altera Corporation.  In the event that you do not
// agree with such terms and conditions, you may not use the reference design
// file and please promptly destroy any copies you have made.
//
// This reference design file is being provided on an �as-is� basis and as an
// accommodation and therefore all warranties, representations or guarantees of
// any kind (whether express, implied or statutory) including, without
// limitation, warranties of merchantability, non-infringement, or fitness for
// a particular purpose, are specifically disclaimed.  By making this reference
// design file available, Altera expressly does not recommend, suggest or
// require that this reference design file be used in combination with any
// other product not provided by Altera.
//--------------------------------------------------------------------------------------------------
// File          : $RCSfile: sdi_makeframe.v,v $
// Last modified : $Date: 2008/11/28 $
// Export tag    : $Name:  $
//--------------------------------------------------------------------------------------------------
//
// State machine to format a video frame.
//
//--------------------------------------------------------------------------------------------------
module sdi_makeframe (
  hd_sdn,

  clk,
  rst,
  enable,
  din_req,
  ln,
  field_line,
  word_count,
  din_y,
  din_c,
  dout,
  trs,

  lines_per_frame,
  words_per_active_line,
  words_per_total_line,
  f_rise_line,
  v_fall_line_1,
  v_rise_line_1,
  v_fall_line_2,
  v_rise_line_2
  );

parameter DATA_DELAY = 1;      // Clocks from din_req assertion to din being valid
parameter SD_10BIT = 1'b0;

parameter [9:0] Y_BLANKING_DATA = 10'h040;
parameter [9:0] C_BLANKING_DATA = 10'h200;

input         hd_sdn;          // 0 : SDI, 1 : HD-SDI
input         clk;             // Parallel rate clock
input         rst;             // Active high reset
input         enable;          // Active high enable. Assert to start frame generation
output        din_req;         // Data request to pattern generator
output [10:0] ln;              // Frame line number output to accompany din_req
output [10:0] field_line;      // Line number within the current field
output [12:0] word_count;      // Word count for requested pixel data
input   [9:0] din_c;           // Chroma input
input   [9:0] din_y;           // Luma input
output [19:0] dout;            // Output - interleaved chroma/luma on [9:0] for SDI
output        trs;

input [10:0] lines_per_frame;        // Total lines per frame
input [12:0] words_per_active_line;  // Total words in active part of line
input [12:0] words_per_total_line;   // Total words per line
input [10:0] f_rise_line;            // Line number when F flag goes high (relative to F going low on line 1)
input [10:0] v_fall_line_1;          // Line number when V falls for first field
input [10:0] v_rise_line_1;          // Line number when V rises for first field
input [10:0] v_fall_line_2;          // Line number when V falls for second field (use 0 for progressive frame)
input [10:0] v_rise_line_2;          // Line number when V rises for second field (use 0 for progressive frame)

// State values
parameter [3:0] GEN_IDLE   = 4'b0000;
parameter [3:0] GEN_EAV_1  = 4'b0001;
parameter [3:0] GEN_EAV_2  = 4'b0010;
parameter [3:0] GEN_EAV_3  = 4'b0011;
parameter [3:0] GEN_EAV_4  = 4'b0100;
parameter [3:0] GEN_HANC   = 4'b0101;
parameter [3:0] GEN_HANC_Y = 4'b0110;
parameter [3:0] GEN_SAV_1  = 4'b0111;
parameter [3:0] GEN_SAV_2  = 4'b1000;
parameter [3:0] GEN_SAV_3  = 4'b1001;
parameter [3:0] GEN_SAV_4  = 4'b1010;
parameter [3:0] GEN_AP     = 4'b1011;
parameter [3:0] GEN_AP_Y   = 4'b1100;



reg [10:0] line_count;       // Variable
reg [10:0] ln;               // Current line number
reg [12:0] word_count;       // Current word number
reg [10:0] field_line;       // Line number within field
reg [12:0] field_word;       // Word number within field
reg  [3:0] state;
reg        F;
reg        V;
reg        din_req;


always @ (posedge clk or posedge rst)
begin
  if (rst) begin
    state      <= GEN_IDLE;
    F          <= 1'b0;
    V          <= 1'b1;
    ln         <= 0;
    field_line <= 0;
    word_count <= 0;
    field_word <= 0;
    din_req    <= 1'b0;
  end
  // SAV of first active line of first field is the first word generated
  else if (~enable) begin
    ln         <= v_fall_line_1;
    field_line <= 1;
    field_word <= 0;
    F          <= 1'b0;
    V          <= 1'b0;
    state      <= GEN_SAV_1;
  end
  else begin

    case (state)

      GEN_IDLE    : begin
                      state <= GEN_EAV_1;
                    end

      GEN_EAV_1   : begin
                      state <= GEN_EAV_2;

                      // Temp variable assignment
                      line_count = ln;

                      // Reset line count at end of frame
                      if (line_count==lines_per_frame) begin
                        line_count = 1;
                        F <= 1'b0;
                      end
                      // else just increment on every line
                      else
                        line_count = line_count + 11'd1;

                      // Line number within field may be useful to pattern generator
                      if (field_line>0)
                        field_line <= field_line + 11'd1;

                      // Determine V and F from line number
                      if (line_count==v_fall_line_1 | line_count==v_fall_line_2) begin
                        V <= 1'b0;
                        field_line <= 1;
                      end

                      if (line_count==v_rise_line_1 | line_count==v_rise_line_2) begin
                        V <= 1'b1;
                        field_line <= 0;
                      end

                      if (line_count==f_rise_line)
                        F <= 1'b1;

                      // Assign temp variable back to register
                      ln <= line_count;

                    end

      GEN_EAV_2   : begin
                      state <= GEN_EAV_3;
                    end

      GEN_EAV_3   : begin
                      state <= GEN_EAV_4;
                    end

      GEN_EAV_4   : begin
                      state <= GEN_HANC;
                      word_count <= 1;
                    end

      GEN_HANC    : begin
                      if (hd_sdn) begin
                        if (word_count>=words_per_total_line-words_per_active_line-8) begin
                          state <= GEN_SAV_1;
                          word_count <= 0;
                        end
                        else begin
                          word_count <= word_count + 13'd1;
                          state <= GEN_HANC;
                        end
                      end
                      else
                        state <= GEN_HANC_Y;
                    end

      GEN_HANC_Y  : begin
                      if (word_count>=words_per_total_line-words_per_active_line-4) begin
                        state <= GEN_SAV_1;
                        word_count <= 0;
                      end
                      else begin
                        word_count <= word_count + 13'd1;
                        state <= GEN_HANC;
                      end
                    end

      GEN_SAV_1   : begin
                      state <= GEN_SAV_2;
                    end

      GEN_SAV_2   : begin
                      state <= GEN_SAV_3;
                    end

      GEN_SAV_3   : begin
                      state <= GEN_SAV_4;
                    end

      GEN_SAV_4   : begin
                      state <= GEN_AP;
                      word_count <= 1;
                      din_req <= ~V;
                    end

      GEN_AP      : begin
                      if (hd_sdn) begin
                        if (word_count>=words_per_active_line) begin
                          state <= GEN_EAV_1;
                          word_count <= 0;
                          din_req <= 1'b0;
                        end
                        else begin
                          state <= GEN_AP;
                          word_count <= word_count + 13'd1;
                          din_req <= ~V;
                        end
                        field_word <= field_word + 13'd1;
                      end

                      else begin

                        state <= GEN_AP_Y;
                        field_word <= field_word + 13'd1;
                        din_req <= ~V & SD_10BIT;
                      end

                    end

      GEN_AP_Y    : begin
                      if (word_count>=words_per_active_line) begin
                        din_req <= 1'b0;
                        state <= GEN_EAV_1;
                        word_count <= 0;
                        field_word <= 0;
                      end
                      else begin
                        din_req <= ~V;           // Request data
                        state <= GEN_AP;
                        word_count <= word_count + 13'd1;
                      end
                    end

     endcase
  end
end

//--------------------------------------------------------------------------------------------------
// Delay state to match data request pipeline
//--------------------------------------------------------------------------------------------------
reg [DATA_DELAY:1] state3_pipeline;
reg [DATA_DELAY:1] state2_pipeline;
reg [DATA_DELAY:1] state1_pipeline;
reg [DATA_DELAY:1] state0_pipeline;
reg [DATA_DELAY:1] F_pipeline;
reg [DATA_DELAY:1] V_pipeline;
always @ (posedge clk or posedge rst)
begin
  if (rst) begin
    state0_pipeline <= 0;
    state1_pipeline <= 0;
    state2_pipeline <= 0;
    state3_pipeline <= 0;
  end
  else begin
    // Shift values in to pipeline
    state0_pipeline <= {state0_pipeline, state[0]};
    state1_pipeline <= {state1_pipeline, state[1]};
    state2_pipeline <= {state2_pipeline, state[2]};
    state3_pipeline <= {state3_pipeline, state[3]};
    F_pipeline <= {F_pipeline, F};
    V_pipeline <= {V_pipeline, V};
  end
end
wire [3:0] state_matched = {state3_pipeline[DATA_DELAY], state2_pipeline[DATA_DELAY], state1_pipeline[DATA_DELAY], state0_pipeline[DATA_DELAY]};
wire F_matched = F_pipeline[DATA_DELAY];
wire V_matched = V_pipeline[DATA_DELAY];

//--------------------------------------------------------------------------------------------------
// Function to calculate TRS XYZ word from F, V and H
//--------------------------------------------------------------------------------------------------
function [9:0] calc_xyz;
  input [2:0] FVH;
  case (FVH)
    3'b000 : calc_xyz = 10'h200;
    3'b001 : calc_xyz = 10'h274;
    3'b010 : calc_xyz = 10'h2ac;
    3'b011 : calc_xyz = 10'h2d8;
    3'b100 : calc_xyz = 10'h31c;
    3'b101 : calc_xyz = 10'h368;
    3'b110 : calc_xyz = 10'h3b0;
    3'b111 : calc_xyz = 10'h3c4;
  endcase
endfunction

//--------------------------------------------------------------------------------------------------
// Generate appropriate data
//--------------------------------------------------------------------------------------------------
reg [19:0] data;
reg trs;
always @ (posedge clk or posedge rst)
begin
  if (rst) begin
    data <= 20'b0;
    trs <= 1'b0;
  end
  else begin
    // Default
    data <= 20'b0;
    trs <= 1'b0;

    case (state_matched)

        GEN_EAV_1   : begin
                        data <= {10'h3ff, 10'h3ff};
                        trs <= 1'b1;
                      end

        GEN_EAV_2   : begin
                        data <= {10'h000, 10'h000};
                      end

        GEN_EAV_3   : begin
                        data <= {10'h000, 10'h000};
                      end

        GEN_EAV_4   : begin
                        data[9:0]   <= calc_xyz({F_matched, V_matched, 1'b1});
                        data[19:10] <= calc_xyz({F_matched, V_matched, 1'b1});
                      end

        GEN_HANC    : begin
                        data[9:0]   <= C_BLANKING_DATA;
                        data[19:10] <= Y_BLANKING_DATA;
                      end

        GEN_HANC_Y  : begin
                        data[9:0] <= Y_BLANKING_DATA;
                      end

        GEN_SAV_1   : begin
                        data <= {10'h3ff, 10'h3ff};
                        trs <= 1'b1;
                      end

        GEN_SAV_2   : begin
                        data <= {10'h000, 10'h000};
                      end

        GEN_SAV_3   : begin
                        data <= {10'h000, 10'h000};
                      end

        GEN_SAV_4   : begin
                        data[9:0]   <= calc_xyz({F_matched, V_matched, 1'b0});
                        data[19:10] <= calc_xyz({F_matched, V_matched, 1'b0});
                      end

        GEN_AP      : begin
                        if (V_matched) begin
                          data[9:0]   <= C_BLANKING_DATA;
                          data[19:10] <= Y_BLANKING_DATA;
                        end
                        else begin
                          data[9:0]   <= din_c;
                          data[19:10] <= din_y;
                        end
                      end

        GEN_AP_Y    : begin
                        if (V_matched)
                          data[9:0] <= Y_BLANKING_DATA;
                        else
                          data[9:0] <= din_y;
                      end
    endcase

  end
end

assign dout = data;

endmodule
