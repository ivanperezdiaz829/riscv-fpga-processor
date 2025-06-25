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
//
// State machine to format a video frame.
//
//--------------------------------------------------------------------------------------------------

`define SYNTHESIS

module sdi_ii_makeframe (
  hd_sdn,

  clk,
  rst,
  enable,
  tx_std,
  dl_mapping,
  din_req,
  ln,
  lnB,
  dl_ln,
  //field_line,
  word_count,
  din_y,
  din_c,
  dout,
  dout_valid,
  trs,
  anc,

  sd_hanc_y_word,
  hd_hanc_word,
  lines_per_frame,
  words_per_active_line,
  words_per_total_line,
  f_rise_line,
  f_fall_line,
  v_fall_line_1,
  v_rise_line_1,
  v_fall_line_2,
  v_rise_line_2,
  vpid_byte1,
  vpid_byte2,
  vpid_byte3,
  vpid_byte4,
  line_f0,
  line_f1,
  vpid_byte1_b,
  vpid_byte2_b,
  vpid_byte3_b,
  vpid_byte4_b
  );

parameter       DATA_DELAY          = 1;      // Clocks from din_req assertion to din being valid
parameter       SD_10BIT            = 1'b0;
parameter       TEST_GEN_ANC        = 1'b0;
parameter       TEST_GEN_VPID       = 1'b0;
parameter [1:0] TEST_VPID_PKT_COUNT = 2'd1;
parameter       TEST_ERR_VPID       = 1'b0;
parameter       TEST_VPID_OVERWRITE = 1'b1;

parameter [9:0] Y_BLANKING_DATA = 10'h040;
parameter [9:0] C_BLANKING_DATA = 10'h200;

input         hd_sdn;          // 0 : SDI, 1 : HD-SDI
input         clk;             // Parallel rate clock
input         rst;             // Active high reset
input         enable;          // Active high enable. Assert to start frame generation
input [1:0]   tx_std;
input 	      dl_mapping;
output        din_req;         // Data request to pattern generator
output [10:0] ln;              // Frame line number output to accompany din_req
output [10:0] lnB;
output [10:0] dl_ln;             
//output [10:0] field_line;    // Line number within the current field
output [12:0] word_count;      // Word count for requested pixel data
input   [9:0] din_c;           // Chroma input
input   [9:0] din_y;           // Luma input
output [19:0] dout;            // Output - interleaved chroma/luma on [9:0] for SDI
output        dout_valid;
output        trs;
output        anc;

input [7:0]  sd_hanc_y_word;
input [11:0] hd_hanc_word;
input [10:0] lines_per_frame;        // Total lines per frame
input [12:0] words_per_active_line;  // Total words in active part of line
input [12:0] words_per_total_line;   // Total words per line
input [10:0] f_rise_line;            // Line number when F flag goes high (relative to F going low on line 1)
input [10:0] f_fall_line;            // Line number when F flag goes high (relative to F going low on line 1)
input [10:0] v_fall_line_1;          // Line number when V falls for first field
input [10:0] v_rise_line_1;          // Line number when V rises for first field
input [10:0] v_fall_line_2;          // Line number when V falls for second field (use 0 for progressive frame)
input [10:0] v_rise_line_2;          // Line number when V rises for second field (use 0 for progressive frame)
input [7:0]  vpid_byte1;
input [7:0]  vpid_byte2;
input [7:0]  vpid_byte3;
input [7:0]  vpid_byte4;
input [10:0] line_f0;
input [10:0] line_f1;
input [7:0]  vpid_byte1_b;
input [7:0]  vpid_byte2_b;
input [7:0]  vpid_byte3_b;
input [7:0]  vpid_byte4_b;

// State values
parameter [4:0] GEN_IDLE   = 5'b00000;
parameter [4:0] GEN_EAV_1  = 5'b00001;
parameter [4:0] GEN_EAV_2  = 5'b00010;
parameter [4:0] GEN_EAV_3  = 5'b00011;
parameter [4:0] GEN_EAV_4  = 5'b00100;
parameter [4:0] GEN_HANC   = 5'b00101;
parameter [4:0] GEN_HANC_Y = 5'b00110;
parameter [4:0] GEN_SAV_1  = 5'b00111;
parameter [4:0] GEN_SAV_2  = 5'b01000;
parameter [4:0] GEN_SAV_3  = 5'b01001;
parameter [4:0] GEN_SAV_4  = 5'b01010;
parameter [4:0] GEN_AP     = 5'b01011;
parameter [4:0] GEN_AP_Y   = 5'b01100;
parameter [4:0] GEN_ADF0   = 5'b01101;
parameter [4:0] GEN_ADF1   = 5'b01110;
parameter [4:0] GEN_ADF2   = 5'b01111;
parameter [4:0] GEN_DID    = 5'b10000;
parameter [4:0] GEN_SDID   = 5'b10001;
parameter [4:0] GEN_DC     = 5'b10010;
parameter [4:0] GEN_UDW1   = 5'b10011;
parameter [4:0] GEN_UDW2   = 5'b10100;
parameter [4:0] GEN_UDW3   = 5'b10101;
parameter [4:0] GEN_UDW4   = 5'b10110;
parameter [4:0] GEN_CS     = 5'b10111;
parameter [4:0] GEN_LN_CRC = 5'b11000;

localparam gen_wrong_vpid_did = !(TEST_VPID_OVERWRITE | TEST_ERR_VPID);

reg [10:0] line_count;       // Variable
reg [10:0] line;             // Current line number
reg [10:0] lineB;   
reg [12:0] word_count;       // Current word number
//reg [10:0] field_line;     // Line number within field
//reg [12:0] field_word;       // Word number within field
reg  [4:0] state;
reg        F;
reg        V;
reg        din_req;
reg        end_of_frame;
reg  [1:0] vpid_pkt_count;
reg        checksum_en1;
reg        checksum_en2;
reg        insert_cs;

wire [9:0] vpid_did = TEST_GEN_VPID ? (gen_wrong_vpid_did ? 10'h341 : 10'h241) : 10'h242;
wire [10:0] interface_ln = (dl_mapping & tx_std == 2'b01) ? dl_ln : ln;

reg [11:0] int_hd_hanc_word;
reg [7:0]  int_sd_hanc_y_word;
always @ (posedge clk or posedge rst)
begin
   if (rst) begin
      int_hd_hanc_word <= 12'd268;
      int_sd_hanc_y_word <= 8'd134;
   end else if (enable) begin
      if (TEST_GEN_ANC & (interface_ln==line_f0 | interface_ln==line_f1)) begin
         int_hd_hanc_word <= hd_hanc_word - TEST_VPID_PKT_COUNT * 12'd11;
         int_sd_hanc_y_word <= sd_hanc_y_word - (TEST_VPID_PKT_COUNT * 8'd11) / 8'd2;
      end else begin
         int_hd_hanc_word <= hd_hanc_word;
         int_sd_hanc_y_word <= sd_hanc_y_word;
      end
   end
end
     
always @ (posedge clk or posedge rst)
begin
  if (rst) begin
    state          <= GEN_IDLE;
    F              <= 1'b0;
    V              <= 1'b1;
    //ln           <= 0;
    //field_line   <= 0;
    word_count     <= 13'd0;
    //field_word     <= 13'd0;
    din_req        <= 1'b0;
    line_count     <= 11'd0;
    end_of_frame   <= 1'b0;
    vpid_pkt_count <= TEST_VPID_PKT_COUNT;
    checksum_en1   <= 1'b0;
    checksum_en2   <= 1'b0;
    insert_cs      <= 1'b0;
  end
  else if (enable) begin
    checksum_en1   <= 1'b0;
    checksum_en2   <= 1'b0;
    insert_cs      <= 1'b0;
	 
    case (state)

      GEN_IDLE    : begin
                      state <= GEN_EAV_1;
                      line_count <= 11'd1;
                    end

      GEN_EAV_1   : begin
                      state <= GEN_EAV_2;
	 
                      //if (dl_mapping & ((tx_std==2'b01) | (tx_std==2'b10))) begin
                      if (dl_mapping) begin
                        if (tx_std==2'b01) begin
                          if (line_count == 11'd2) begin
                            F <= 1'b0;
                          end else if (line_count == 11'd3) begin
                            F <= 1'b1;
                          end

                          if (line_count == v_fall_line_1 | line_count == (v_fall_line_1 + 11'd1)) begin
                            V <= 1'b0;
                          end
 
                          if (line_count == v_rise_line_1 | line_count == (v_rise_line_1 + 11'd1)) begin
                            V <= 1'b1;
                          end
                        end else if (tx_std==2'b10) begin
                          if (line_count==11'd564) begin
                            F <= 1'b1;
                          end

                          if (line_count==11'd1) begin
                            F <= 1'b0;
                          end

                          if (line_count==11'd21 | line_count==11'd584) begin
                            V <= 1'b0;
                          end

                          if (line_count==11'd561 | line_count==11'd1124) begin
                            V <= 1'b1;
                          end
                        end
                      end else begin
                        // Line number within field may be useful to pattern generator
                        //if (field_line>0)
                        //  field_line <= field_line + 11'd1;`

                        // Determine V and F from line number
                        if (line_count==v_fall_line_1 | line_count==v_fall_line_2) begin
                          V <= 1'b0;
                          //field_line <= 1;
                        end

                        if (line_count==v_rise_line_1 | line_count==v_rise_line_2) begin
                          V <= 1'b1;
                          //field_line <= 0;
                        end

                        if (line_count==f_rise_line) begin
                          F <= 1'b1;
                        end

                        if (line_count==f_fall_line) begin
                          F <= 1'b0;
                        end
                      end
                    end

      GEN_EAV_2   : begin
                      state <= GEN_EAV_3;
                    end

      GEN_EAV_3   : begin
                      state <= GEN_EAV_4;
                    end

      GEN_EAV_4   : begin
                      if (hd_sdn) begin
                        state <= GEN_LN_CRC;
                      end else begin
                        if (TEST_GEN_ANC & (line_count==line_f0 | line_count==line_f1)) begin
                          vpid_pkt_count <= TEST_VPID_PKT_COUNT;
                          state <= GEN_ADF0;
                        end else begin
                          vpid_pkt_count <= 2'd0;
                          state <= GEN_HANC;
                        end
                      end
                      word_count <= 13'd1;
                    end
      
      GEN_LN_CRC  : begin
                      if (word_count>=13'd4) begin
                        word_count <= 13'd1;
                        if (TEST_GEN_ANC & (interface_ln==line_f0 | interface_ln==line_f1)) begin
                          vpid_pkt_count <= TEST_VPID_PKT_COUNT;
                          state <= GEN_ADF0;
                        end else begin
                          vpid_pkt_count <= 2'd0;
                          state <= GEN_HANC;
                        end
                      end else begin
                        word_count <= word_count + 13'd1;
                      end
                    end
      
      GEN_ADF0    : begin
                      vpid_pkt_count <= vpid_pkt_count - 2'd1;
                      state <= GEN_ADF1;
                    end
                    
      GEN_ADF1    : begin
                      state <= GEN_ADF2;
                    end
                    
      GEN_ADF2    : begin
                      state <= GEN_DID;
                    end
      
      GEN_DID     : begin
                      checksum_en1 <= 1'b1;
                      state <= GEN_SDID;
                    end
                  
      GEN_SDID    : begin
                      checksum_en2 <= 1'b1;
                      state <= GEN_DC;
                    end
                    
      GEN_DC      : begin
                      checksum_en2 <= 1'b1;
                      state <= GEN_UDW1;
                    end
                    
      GEN_UDW1    : begin
                      checksum_en2 <= 1'b1;
                      state <= GEN_UDW2;
                    end
                    
      GEN_UDW2    : begin
                      checksum_en2 <= 1'b1;
                      state <= GEN_UDW3;
                    end
                    
      GEN_UDW3    : begin
                      checksum_en2 <= 1'b1;
                      state <= GEN_UDW4;
                    end
                  
      GEN_UDW4    : begin
                      checksum_en2 <= 1'b1;
                      state <= GEN_CS;
                    end
                               
      GEN_CS      : begin
                      insert_cs <= 1'b1;
							 
                      if (vpid_pkt_count == 0) begin
                        vpid_pkt_count <= TEST_VPID_PKT_COUNT;
                        if (hd_sdn) begin
                          state <= GEN_HANC;
                        end else begin
                          if (TEST_VPID_PKT_COUNT % 2 == 0) begin
                            state <= GEN_HANC;
                          end else begin   
                            state <= GEN_HANC_Y;
                          end
                        end
                      end else begin
                        state <= GEN_ADF0;
                      end
                    end

      GEN_HANC    : begin
                      if (hd_sdn) begin
                        if (word_count >= int_hd_hanc_word) begin
                          state <= GEN_SAV_1;
                          word_count <= 13'd0;
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
                      if (word_count >= int_sd_hanc_y_word) begin
                        state <= GEN_SAV_1;
                        word_count <= 13'd0;
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
                      word_count <= 13'd1;
                      din_req <= ~V;
                    end

      GEN_AP      : begin
                      if (hd_sdn) begin
                        if (word_count>=words_per_active_line) begin
                          state 	<= GEN_EAV_1;
                          word_count 	<= 13'd0;
                          din_req 	<= 1'b0;
								  
                          //if (dl_mapping & ((tx_std==2'b01) | (tx_std==2'b10))) begin
                          if (dl_mapping & (tx_std==2'b01)) begin
                            if (line_count==lines_per_frame-2) begin // 1123
                              end_of_frame <= 1'b1;
                            end else begin
                              end_of_frame <= 1'b0;
                            end
									 
                            if (line_count==lines_per_frame-1) begin // 1124
                              line_count <= 11'd1;
                            end else if (line_count==lines_per_frame) begin // 1125
                              line_count <= 11'd2;
                            end else begin 
                              line_count <= line_count + 11'd2;
                            end
                          end else begin
                            if (line_count==lines_per_frame) begin
                              line_count <= 11'd1;
                              //F <= 1'b0;
                            end
                            // else just increment on every line
                            else begin
                              line_count <= line_count + 11'd1;
                            end
                          end
                        end
                        else begin
                          state       <= GEN_AP;
                          word_count 	<= word_count + 13'd1;
                          din_req     <= ~V;
                        end
                        //field_word 	<= field_word + 13'd1;
                      end else begin
                        state 		    <= GEN_AP_Y;
                        //field_word 	<= field_word + 13'd1;
                        din_req     <= ~V & SD_10BIT;
                      end
                    end

      GEN_AP_Y    : begin
                      if (word_count>=words_per_active_line) begin
                        din_req    <= 1'b0;
                        state      <= GEN_EAV_1;
                        word_count <= 13'd0;
                        //field_word <= 13'd0;

                        if (line_count==lines_per_frame) begin
                          line_count <= 11'd1;
                          F <= 1'b0;
                        end
                        // else just increment on every line
                        else begin
                          line_count <= line_count + 11'd1;
                        end
                      end
                      else begin
                        din_req    <= ~V;           // Request data
                        state      <= GEN_AP;
                        word_count <= word_count + 13'd1;
                      end
                    end
                    
        default     : begin 
                        state         <= GEN_IDLE;
                        F             <= 1'b0;
                        V             <= 1'b1;
                        word_count    <= 13'd0;
                        //field_word    <= 13'd0;
                        din_req       <= 1'b0;
                        line_count    <= 11'd0;
                        end_of_frame  <= 1'b0;
                      end
     endcase
  end
end

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
// Delay state to match data request pipeline
//--------------------------------------------------------------------------------------------------
reg       state4_dly;
reg       state3_dly;
reg       state2_dly;
reg       state1_dly;
reg       state0_dly;
reg       enable_dly;
reg       F_dly;
reg       V_dly;
reg       checksum_en1_dly;
reg       checksum_en2_dly;
reg [1:0] insert_cs_dly;
always @ (posedge clk or posedge rst)
begin
  if (rst) begin
    state0_dly       <= 1'b0;
    state1_dly       <= 1'b0;
    state2_dly       <= 1'b0;
    state3_dly       <= 1'b0;
    state4_dly       <= 1'b0;
    enable_dly       <= 1'b0;
    F_dly            <= 1'b0;
    V_dly            <= 1'b0;	 
    checksum_en1_dly <= 1'b0;
    checksum_en2_dly <= 1'b0;
    insert_cs_dly    <= 2'b00;
  end
  else begin
    state0_dly       <= state[0];
    state1_dly       <= state[1];
    state2_dly       <= state[2];
    state3_dly       <= state[3];
    state4_dly       <= state[4];
    enable_dly       <= enable;
    F_dly            <= F;
    V_dly            <= V;
    checksum_en1_dly <= checksum_en1;
    checksum_en2_dly <= checksum_en2;
    insert_cs_dly    <= {insert_cs_dly[0], insert_cs};
  end
end
wire [4:0] state_matched = {state4_dly, state3_dly, state2_dly, state1_dly, state0_dly};
wire F_matched = F_dly;
wire V_matched = V_dly;

//--------------------------------------------------------------------------------------------------
// Generate appropriate data
//--------------------------------------------------------------------------------------------------
reg [19:0] data;
reg        data_valid;
reg        trs_strobe;
reg        anc_pkt;
wire       anc_parity_msb;
wire       anc_parity_lsb;
wire       vpid_byte1_parity;
wire       vpid_byte2_parity;
wire       vpid_byte3_parity;
wire       vpid_byte4_parity;
//wire       vpid_byte1_b_parity;
//wire       vpid_byte2_b_parity;
//wire       vpid_byte3_b_parity;
//wire       vpid_byte4_b_parity;
assign anc_parity_msb     = data[17] ^ data[16] ^ data[15] ^ data[14] ^ data[13] ^ data[12] ^ data[11] ^ data[10];
assign anc_parity_lsb     = data[7]  ^ data[6]  ^ data[5]  ^ data[4]  ^ data[3]  ^ data[2]  ^ data[1]  ^ data[0];
assign vpid_byte1_parity  = vpid_byte1[7]  ^ vpid_byte1[6]  ^ vpid_byte1[5]  ^ vpid_byte1[4]  ^ vpid_byte1[3]  ^ vpid_byte1[2]  ^ vpid_byte1[1]  ^ vpid_byte1[0];
assign vpid_byte2_parity  = vpid_byte2[7]  ^ vpid_byte2[6]  ^ vpid_byte2[5]  ^ vpid_byte2[4]  ^ vpid_byte2[3]  ^ vpid_byte2[2]  ^ vpid_byte2[1]  ^ vpid_byte2[0];
assign vpid_byte3_parity  = vpid_byte3[7]  ^ vpid_byte3[6]  ^ vpid_byte3[5]  ^ vpid_byte3[4]  ^ vpid_byte3[3]  ^ vpid_byte3[2]  ^ vpid_byte3[1]  ^ vpid_byte3[0];
assign vpid_byte4_parity  = vpid_byte4[7]  ^ vpid_byte4[6]  ^ vpid_byte4[5]  ^ vpid_byte4[4]  ^ vpid_byte4[3]  ^ vpid_byte4[2]  ^ vpid_byte4[1]  ^ vpid_byte4[0];
//assign vpid_byte1_b_parity = vpid_byte1_b[7] ^ vpid_byte1_b[6] ^ vpid_byte1_b[5] ^ vpid_byte1_b[4] ^ vpid_byte1_b[3] ^ vpid_byte1_b[2] ^ vpid_byte1_b[1] ^ vpid_byte1_b[0];
//assign vpid_byte2_b_parity = vpid_byte2_b[7] ^ vpid_byte2_b[6] ^ vpid_byte2_b[5] ^ vpid_byte2_b[4] ^ vpid_byte2_b[3] ^ vpid_byte2_b[2] ^ vpid_byte2_b[1] ^ vpid_byte2_b[0];
//assign vpid_byte3_b_parity = vpid_byte3_b[7] ^ vpid_byte3_b[6] ^ vpid_byte3_b[5] ^ vpid_byte3_b[4] ^ vpid_byte3_b[3] ^ vpid_byte3_b[2] ^ vpid_byte3_b[1] ^ vpid_byte3_b[0];
//assign vpid_byte4_b_parity = vpid_byte4_b[7] ^ vpid_byte4_b[6] ^ vpid_byte4_b[5] ^ vpid_byte4_b[4] ^ vpid_byte4_b[3] ^ vpid_byte4_b[2] ^ vpid_byte4_b[1] ^ vpid_byte4_b[0];

// ----------------------------------------------
// Calculate checksum on the generated anc data
//
reg [8:0] anc_checksum_msb;
reg [8:0] anc_checksum_lsb;
always @ (posedge clk or posedge rst)
begin
  if (rst) begin
    anc_checksum_msb <= 9'd0;
    anc_checksum_lsb <= 9'd0;
  end else if (data_valid) begin
    if (checksum_en1_dly) begin
      anc_checksum_msb <= {anc_parity_msb, data[17:10]};
      anc_checksum_lsb <= {anc_parity_lsb, data[7:0]};
    end else if (checksum_en2_dly) begin
      anc_checksum_msb <= anc_checksum_msb + {anc_parity_msb, data[17:10]};
      anc_checksum_lsb <= anc_checksum_lsb + {anc_parity_lsb, data[7:0]};
    end
  end
end

reg no_anc;
reg line_change;
always @ (posedge clk or posedge rst)
begin
  if (rst) begin
    data[19:10] <= Y_BLANKING_DATA;
    data[9:0]   <= C_BLANKING_DATA;
    data_valid  <= 1'b0;
    trs_strobe  <= 1'b0;
    line        <= 11'd0;
    lineB       <= 11'd0; 
    anc_pkt     <= 1'b0;
    line_change <= 1'b0;
  end
  else begin
    // Default
    data[19:10] <= Y_BLANKING_DATA;
    data[9:0]   <= C_BLANKING_DATA;
    data_valid  <= enable_dly;
    trs_strobe  <= 1'b0;
    anc_pkt     <= 1'b0;
    line_change <= 1'b0;

    case (state_matched)

        GEN_EAV_1   : begin
                        data <= {10'h3ff, 10'h3ff};
                        trs_strobe <= 1'b1;
                        line_change <= 1'b1;
                        line <= line_count;
                        lineB <= (dl_mapping & tx_std==2'b01) ? (end_of_frame ? 11'd1 : line_count + 11'd1) : ((tx_std == 2'b10) ? line_count : 11'd0);
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
        
        GEN_LN_CRC  : begin
		        data[19:10] <= Y_BLANKING_DATA;
                        data[9:0]   <= C_BLANKING_DATA;
                      end
          
        GEN_ADF0    : begin
                        anc_pkt <= 1'b1;
                        if (tx_std==2'b00) begin
                          data[9:0] <= 10'h000;
                        end else if (tx_std[1]) begin
                          data[19:10] <= 10'h000;
                          data[9:0] <= 10'h000;
                        end else begin
                          data[19:10] <= 10'h000;
                        end
                      end

        GEN_ADF1    : begin
                        anc_pkt <= 1'b1;    
                        if (tx_std==2'b00) begin
                          data[9:0] <= no_anc ? 10'h3FE : 10'h3FF;
                        end else if (tx_std[1]) begin
                          data[19:10] <= no_anc ? 10'h3FE : 10'h3FF;
                          data[9:0] <= no_anc ? 10'h3FE : 10'h3FF;
                        end else begin
                          data[19:10] <= no_anc ? 10'h3FE : 10'h3FF;
                        end
                      end
                      
        GEN_ADF2    : begin
                        anc_pkt <= 1'b1;
                        if (tx_std==2'b00) begin
                          data[9:0] <= 10'h3FF;
                        end else if (tx_std[1]) begin
                          data[19:10] <= 10'h3FF;
                          data[9:0] <= 10'h3FF;
                        end else begin
                          data[19:10] <= 10'h3FF;
                        end 
                      end
                    
        GEN_DID     : begin
                        anc_pkt <= 1'b1;
                        if (tx_std==2'b00) begin
                          data[9:0] <= vpid_did;
                        end else if (tx_std[1]) begin
                          data[19:10] <= vpid_did;
                          data[9:0] <= vpid_did;
                        end else begin
                          data[19:10] <= vpid_did;
                        end
                      end
                      
        GEN_SDID    : begin
                        anc_pkt <= 1'b1;
                        if (tx_std==2'b00) begin
                          data[9:0] <= 10'h101;
                        end else if (tx_std[1]) begin
                          data[19:10] <= 10'h101;
                          data[9:0] <= 10'h101;
                        end else begin
                          data[19:10] <= 10'h101;
                        end 
                      end
                      
        GEN_DC      : begin
                        anc_pkt <= 1'b1;
                        if (tx_std==2'b00) begin
                          data[9:0] <= 10'h104;
                        end else if (tx_std[1]) begin
                          data[19:10] <= 10'h104;
                          data[9:0] <= 10'h104;
                        end else begin
                          data[19:10] <= 10'h104;
                        end
                      end
                      
        GEN_UDW1    : begin
                        anc_pkt <= 1'b1;
                        if (tx_std==2'b00) begin
                          data[9:0] <= {~vpid_byte1_parity, vpid_byte1_parity, vpid_byte1};
                        end else if (tx_std[1]) begin
                          data[19:10] <= {~vpid_byte1_parity, vpid_byte1_parity, vpid_byte1};
                          data[9:0] <= {~vpid_byte1_parity, vpid_byte1_parity, vpid_byte1};
                        end else begin 
                          data[19:10] <= {~vpid_byte1_parity, vpid_byte1_parity, vpid_byte1};
                        end
                      end
                      
        GEN_UDW2    : begin
                        anc_pkt <= 1'b1;
                        if (tx_std==2'b00)begin
                          data[9:0] <= {~vpid_byte2_parity, vpid_byte2_parity, vpid_byte2};
                        end else if (tx_std[1]) begin
                          data[19:10] <= {~vpid_byte2_parity, vpid_byte2_parity, vpid_byte2};
                          data[9:0] <= {~vpid_byte2_parity, vpid_byte2_parity, vpid_byte2};
                        end else begin 
                          data[19:10] <= {~vpid_byte2_parity, vpid_byte2_parity, vpid_byte2};
                        end
                      end
                      
        GEN_UDW3    : begin 
                        anc_pkt <= 1'b1;
                        if (tx_std==2'b00) begin
                          data[9:0] <= {~vpid_byte3_parity, vpid_byte3_parity, vpid_byte3};
                        end else if (tx_std[1]) begin
                          data[19:10] <= {~vpid_byte3_parity, vpid_byte3_parity, vpid_byte3};
                          data[9:0] <= {~vpid_byte3_parity, vpid_byte3_parity, vpid_byte3};
                        end else begin
                          data[19:10] <= {~vpid_byte3_parity, vpid_byte3_parity, vpid_byte3};
                        end
                      end
                      
        GEN_UDW4    : begin
                        anc_pkt <= 1'b1;
                        if (tx_std==2'b00) begin
                          data[9:0] <= {~vpid_byte4_parity, vpid_byte4_parity, vpid_byte4};
                        end else if (tx_std[1]) begin
                          data[19:10] <= {~vpid_byte4_parity, vpid_byte4_parity, vpid_byte4};
                          data[9:0] <= {~vpid_byte4_parity, vpid_byte4_parity, vpid_byte4};
                        end else begin
                          data[19:10] <= {~vpid_byte4_parity, vpid_byte4_parity, vpid_byte4};
                        end
                      end
                      
        GEN_CS      : begin
                        anc_pkt <= 1'b1;
                      end

        GEN_HANC    : begin
                        data[9:0]   <= C_BLANKING_DATA;
                        data[19:10] <= Y_BLANKING_DATA;
                      end

        GEN_HANC_Y  : begin
                        data[9:0]   <= Y_BLANKING_DATA;
                        data[19:10] <= Y_BLANKING_DATA; // redundant to avoid 10'h000
                      end

        GEN_SAV_1   : begin
                        data <= {10'h3ff, 10'h3ff};
                        trs_strobe <= 1'b1;
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
                        if (V_matched) begin
                          data[9:0]   <= Y_BLANKING_DATA;
                          data[19:10] <= Y_BLANKING_DATA; // redundant to avoid 10'h000
                        end else begin
                          data[9:0]   <= din_y;
                          data[19:10] <= Y_BLANKING_DATA; // redundant to avoid 10'h000
                        end
                      end
                       
        default : begin
                      line <= 11'd0;
                      lineB <= 11'd0;
                  end
    endcase

  end
end

// ----------------------------
// Insert checksum
//  
reg [19:0] data_dly;
reg        data_valid_dly;
reg [10:0] ln_dly;
reg [10:0] lnB_dly;
reg        trs_dly;
reg        anc_dly;
reg        err_cs;
reg  [3:0] vpid_count;   
wire       insert_checksum = (tx_std==2'b10) ? insert_cs : insert_cs_dly[0];
wire       err_cs_int = TEST_ERR_VPID ? 1'b1 : 1'b0;

always @ (posedge clk or posedge rst)
begin
    if (rst) begin
       err_cs <= err_cs_int;
       vpid_count <= 4'b0000;
       no_anc <= 1'b0;
    end else begin
      if (TEST_ERR_VPID) begin
         if (insert_cs_dly == 2'b10) begin
            vpid_count <= vpid_count + 1'b1;
            if (~tx_std[1] && ~dl_mapping) begin
               if (vpid_count == 4'd2) begin
                  err_cs <= 1'b0;
               end else if (vpid_count > 4'd3) begin
                  no_anc <= 1'b1;
               end
            end else if (tx_std == 2'b01 && dl_mapping) begin
               if (vpid_count == 4'd0) begin
                  err_cs <= 1'b0;
               end else if (vpid_count > 4'd1) begin
                  no_anc <= 1'b1;
               end
            end else begin
               if (vpid_count == 4'd1) begin
                  err_cs <= 1'b0;
               end else if (vpid_count > 4'd1) begin
                  no_anc <= 1'b1;
               end
            end
         end
      end else begin
        err_cs <= 1'b0;
        vpid_count <= 4'b0000;
        no_anc <= 1'b0;
     end
   end
end   
  
always @ (posedge clk or posedge rst)
begin
  if (rst) begin
    data_dly       <= 20'd0;
    data_valid_dly <= 1'b0;
    ln_dly         <= 11'd0;
    lnB_dly        <= 11'd0;
    trs_dly        <= 1'b0;
    anc_dly        <= 1'b0;
  end else begin
    if (insert_checksum) begin
      if (tx_std==2'b00) begin
        data_dly <= {Y_BLANKING_DATA, (err_cs ? anc_checksum_lsb[8] : ~anc_checksum_lsb[8]), anc_checksum_lsb};
      end else if (tx_std[1]) begin
        data_dly[19:10] <= {(err_cs ? anc_checksum_msb[8] : ~anc_checksum_msb[8]), anc_checksum_msb};
        data_dly[9:0] <= {(err_cs ? anc_checksum_msb[8] : ~anc_checksum_msb[8]), anc_checksum_msb};
      end else begin
        data_dly <= {(err_cs ? anc_checksum_msb[8] : ~anc_checksum_msb[8]), anc_checksum_msb, C_BLANKING_DATA};
      end
    end else begin
      data_dly <= data;
    end
     
    data_valid_dly <= data_valid;
    ln_dly <= line;
    lnB_dly <= lineB;
    trs_dly <= trs_strobe;
    anc_dly <= anc_pkt;
  end
end

reg prev_F;
reg rise_edge_F;
reg fall_edge_F;
always @ (posedge clk or posedge rst) // frequency of 148.5MHz 
begin
   if (rst) begin
      rise_edge_F <= 1'b0;
      fall_edge_F <= 1'b0;
      prev_F      <= 1'b0;
   end else begin
      if (dl_mapping) begin
         prev_F <= F;
         
         if (~prev_F & F) begin
            rise_edge_F <= 1'b1;
         end else if (prev_F & ~F) begin
            fall_edge_F <= 1'b1;
         end else begin
            rise_edge_F <= 1'b0;
            fall_edge_F <= 1'b0;
         end
         
      end else begin
         rise_edge_F <= 1'b0;
         fall_edge_F <= 1'b0;
      end
   end
end

reg [10:0] dl_line;
always @ (posedge clk or posedge rst) // frequency of 148.5MHz 
begin
   if (rst) begin
      dl_line <= 11'd0;
   end else begin
      if (dl_mapping) begin
         if (rise_edge_F) begin
           dl_line <= lines_per_frame/2 + 2;
         end else if (fall_edge_F) begin
           dl_line <= 11'b1;
         end else if (line_change) begin
           dl_line <= dl_line + 1'b1;
         end
      end else begin
         dl_line <= 11'd0;
      end
   end
end

assign dout       = data_dly;
assign dout_valid = data_valid_dly;
assign trs        = trs_dly;
assign ln         = ln_dly;
assign lnB        = lnB_dly;
assign dl_ln      = dl_line;
assign anc        = anc_dly;

`ifndef SYNTHESIS
reg [79:0] statename;
 always @* begin
   case (1)
      state[GEN_IDLE]:  statename = "GEN_IDLE" ;
      state[GEN_EAV_1]: statename = "GEN_EAV_1";
      state[GEN_EAV_2]: statename = "GEN_EAV_2";
      state[GEN_EAV_3]: statename = "GEN_EAV_3";
      state[GEN_EAV_4]: statename = "GEN_EAV_4";
      state[GEN_HANC]:  statename = "GEN_HANC" ;
      state[GEN_HANC_Y]:statename = "GEN_HANC_Y";
      state[GEN_SAV_1]: statename = "GEN_SAV_1";
      state[GEN_SAV_2]: statename = "GEN_SAV_2";
      state[GEN_SAV_3]: statename = "GEN_SAV_3";
      state[GEN_SAV_4]: statename = "GEN_SAV_4";
      state[GEN_AP]:    statename = "GEN_AP";
      state[GEN_AP_Y]:  statename = "GEN_AP_Y";
      state[GEN_ADF0]:  statename = "GEN_ADF0";
      state[GEN_ADF1]:  statename = "GEN_ADF1";
      state[GEN_ADF2]:  statename = "GEN_ADF2";
      state[GEN_DID]:   statename = "GEN_DID";
      state[GEN_SDID]:  statename = "GEN_SDID";
      state[GEN_DC]:    statename = "GEN_DC";
      state[GEN_UDW1]:  statename = "GEN_UDW1";
      state[GEN_UDW2]:  statename = "GEN_UDW2";
      state[GEN_UDW3]:  statename = "GEN_UDW3";
      state[GEN_UDW4]:  statename = "GEN_UDW4";
      state[GEN_CS]:    statename = "GEN_CS";
      state[GEN_LN_CRC]: statename = "GEN_LN_CRC";
      default:          statename = "GEN_IDLE";
    endcase
  end
`endif

endmodule
