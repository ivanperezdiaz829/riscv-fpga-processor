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
// Video pattern generator.
//
//--------------------------------------------------------------------------------------------------

module sdi_ii_ed_vid_pattgen 
(
  clk,
  rst,
  bar_100_75n,
  enable,
  patho,
  blank,
  no_color,
  sgmt_frame,

  dout,
  dout_valid,
  trs,
  ln,
  
  dout_b,
  dout_valid_b,
  trs_b,
  ln_b,
  
  tx_std,
  tx_format,
  dl_mapping,
  ntsc_paln,
  
  vpid_byte1,
  vpid_byte2,
  vpid_byte3,
  vpid_byte4,
  vpid_byte1_b,
  vpid_byte2_b,
  vpid_byte3_b,
  vpid_byte4_b,
  line_f0,
  line_f1
  );

input         clk;
input         rst;
input         bar_100_75n;
input         enable;
input         patho;
input         blank;
input         no_color;
input         sgmt_frame; //To differentiate between 1080i50, 1080i60 and 1080sF25, 1080sF30 in tx_format == 4, 5.

output [19:0] dout;
output        dout_valid;
output [19:0] dout_b;
output        dout_valid_b;
output        trs;
output        trs_b;
output [10:0] ln;
output [10:0] ln_b;

input  [1:0]  tx_std;
input  [3:0]  tx_format;
input         dl_mapping;
input         ntsc_paln;

output [7:0]  vpid_byte1;
output [7:0]  vpid_byte2;
output [7:0]  vpid_byte3;
output [7:0]  vpid_byte4;
output [7:0]  vpid_byte1_b;
output [7:0]  vpid_byte2_b;
output [7:0]  vpid_byte3_b;
output [7:0]  vpid_byte4_b;
output [10:0] line_f0;
output [10:0] line_f1;

parameter       TEST_GEN_ANC        = 1'b0;
parameter       TEST_GEN_VPID       = 1'b0;
parameter [1:0] TEST_VPID_PKT_COUNT = 2'd1;
parameter       TEST_ERR_VPID       = 1'b0;
parameter       TEST_VPID_OVERWRITE = 1'b1;
parameter       IS_RTL_SIM          = 1'b0;
parameter       SD_BIT_WIDTH        = 10;
localparam      EN_SD_20BITS        = (SD_BIT_WIDTH == 20);

wire [7:0]  int_sd_hanc_y_word;
wire [11:0] int_hd_hanc_word;
wire [10:0] int_lines_per_frame;
wire [12:0] int_words_per_active_line;
wire [12:0] int_words_per_total_line;
wire [10:0] int_f_rise_line;
wire [10:0] int_f_fall_line;
wire [10:0] int_v_fall_line_1;
wire [10:0] int_v_rise_line_1;
wire [10:0] int_v_fall_line_2;
wire [10:0] int_v_rise_line_2;
wire [10:0] int_patho_change_line_1;
wire [10:0] int_patho_change_line_2;
wire [7:0]  int_vpid_byte1;
wire [7:0]  int_vpid_byte2_a;
wire [7:0]  int_vpid_byte2;
wire [7:0]  int_vpid_byte3;
wire [7:0]  int_vpid_byte4;
wire [10:0] int_line_f0;
wire [10:0] int_line_f1;

wire hd_sdn;
assign hd_sdn = tx_std[1] ? 1'b1 : (tx_std[0] ? 1'b1 : 1'b0);

////////////////////
wire       int_sd_en;
wire       int_sd_20_en;
reg [19:0] t_dout_int_i;
reg [19:0] dout_int_i;
wire [19:0] dout_i;
wire        dout_valid_i;
wire        trs_20;

generate if ( EN_SD_20BITS ) 
begin: sd_10bit_ce_gen

  reg [3:0] sdcnt;
  always @ (posedge clk or posedge rst)
  begin
    if (rst) begin
      sdcnt <= 4'd0;
    end else begin
      if (tx_std == 2'b00) begin
        if (sdcnt != 4'd11) begin
          sdcnt <= sdcnt + 4'd1;
        end else begin
          sdcnt <= 4'd1;
        end  
      end else begin
        sdcnt <= 4'd0;
      end
      
     end
  end
  assign int_sd_en = (sdcnt == 4'd1 | sdcnt == 4'd6);
  
  always @ (posedge clk or posedge rst)
  begin
    if (rst) begin
      t_dout_int_i <= 20'd0;
      dout_int_i <= 20'd0;
    end else begin
      if (dout_valid_i) begin
        t_dout_int_i <= {dout_i[9:0], t_dout_int_i[19:10]};
      end

      if (enable) begin
        dout_int_i <= t_dout_int_i;
      end
    end
  end
  
  assign trs_20 = (dout_int_i == 20'h003ff);

  
end else begin

  assign int_sd_en = 1'b0;
  assign int_sd_20_en = 1'b0;
  assign trs_20 = 1'b0;

end
endgenerate

//////////////

// ---------------------
// Clock enable for 3GB
// ---------------------
reg ce_3gb;
always @ (posedge clk or posedge rst)
begin
  if (rst) ce_3gb <= 1'b0;
   else     ce_3gb <= ~ce_3gb;
end

wire ce_i;
assign ce_i = (tx_std==2'b10) ? ce_3gb : ((tx_std != 2'b00) ? enable : (EN_SD_20BITS ? int_sd_en : enable));

//--------------------------------------------------------------------------------------------------
// Colorbar generator
//--------------------------------------------------------------------------------------------------
wire req;                               // Data request from frame generator to pattern generator
wire [12:0] wn;                         // Word number to accompany request
wire [9:0] y_gen;
wire [9:0] c_gen;
sdi_ii_colorbar_gen u_colorbar (
  .clk                      (clk),
  .rst                      (rst),
  .hd_sdn                   (hd_sdn),
  .bar_100_75n              (bar_100_75n),
  .req                      (req),
  .wn                       (wn),
  .words_per_active_line    (int_words_per_active_line),
  .yout                     (y_gen),
  .cout                     (c_gen)
  );

//--------------------------------------------------------------------------------------------------
// Pathological pattern generator
//--------------------------------------------------------------------------------------------------
wire [9:0] y_patho;
wire [9:0] c_patho;
wire [10:0] ln_i;
sdi_ii_patho_gen u_patho (
  .hd_sdn                   (hd_sdn),
  .clk                      (clk),
  .rst                      (rst),
  .req                      (req),
  .ln                       (ln_i),
  .wn                       (wn),
  .yout                     (y_patho),
  .cout                     (c_patho),
  .field1_start_ln          (tx_std==2'b10 & dl_mapping ? 11'd21 : int_v_fall_line_1),
  .field1_pattern_change_ln (tx_std==2'b10 & dl_mapping ? 11'd290 : int_patho_change_line_1),
  .field2_start_ln          (tx_std==2'b10 & dl_mapping ? 11'd584 : int_v_fall_line_2),
  .field2_pattern_change_ln (tx_std==2'b10 & dl_mapping ? 11'd853 : int_patho_change_line_2),
  .pal_nstcn                (tx_format[0])
  );

//--------------------------------------------------------------------------------------------------
// Select data for output pattern - blank, pathological or colorbar
//--------------------------------------------------------------------------------------------------

wire [9:0] y_make = patho ? y_patho : blank ? 10'h040 : y_gen;
wire [9:0] c_make = patho ? c_patho : (no_color | blank) ? 10'h200 : c_gen;


//--------------------------------------------------------------------------------------------------
// Create output frame - 1080i used for this demo
//--------------------------------------------------------------------------------------------------
wire [10:0] lnb_i;
wire [10:0] dl_ln;
wire        trs_i;
//wire        anc_i;

sdi_ii_makeframe u_makeframe (
  .hd_sdn                   (hd_sdn),

  .clk                      (clk),
  .rst                      (rst),
  .enable                   (ce_i),
  .din_req                  (req),
  .ln                       (ln_i),
  .lnB                      (lnb_i),
  .dl_ln                    (dl_ln),  
  .tx_std                   (tx_std),
  .dl_mapping               (dl_mapping),
  //.field_line             (),
  .word_count               (wn),
  .din_y                    (y_make),
  .din_c                    (c_make),
  .dout                     (dout_i),
  .dout_valid               (dout_valid_i),
  .trs                      (trs_i),
  .anc                      (),
  
  .sd_hanc_y_word           (int_sd_hanc_y_word),
  .hd_hanc_word             (int_hd_hanc_word),
  .lines_per_frame          (int_lines_per_frame),
  .words_per_active_line    (int_words_per_active_line),
  .words_per_total_line     (int_words_per_total_line),
  .f_rise_line              (int_f_rise_line),
  .f_fall_line              (int_f_fall_line),
  .v_fall_line_1            (int_v_fall_line_1),
  .v_rise_line_1            (int_v_rise_line_1),
  .v_fall_line_2            (int_v_fall_line_2),
  .v_rise_line_2            (int_v_rise_line_2),
  .vpid_byte1               (int_vpid_byte1),
  .vpid_byte2               (int_vpid_byte2),
  .vpid_byte3               (int_vpid_byte3),
  .vpid_byte4               (int_vpid_byte4),
  .line_f0                  (int_line_f0),
  .line_f1                  (int_line_f1),
  .vpid_byte1_b              (vpid_byte1_b),
  .vpid_byte2_b              (vpid_byte2_b),
  .vpid_byte3_b              (vpid_byte3_b),
  .vpid_byte4_b              (vpid_byte4_b)
  );
  defparam u_makeframe.TEST_GEN_ANC        = TEST_GEN_ANC;
  defparam u_makeframe.TEST_GEN_VPID       = TEST_GEN_VPID;
  defparam u_makeframe.TEST_VPID_PKT_COUNT = TEST_VPID_PKT_COUNT;
  defparam u_makeframe.TEST_ERR_VPID       = TEST_ERR_VPID;
  defparam u_makeframe.TEST_VPID_OVERWRITE = TEST_VPID_OVERWRITE;

// ------------------------------------------------------------------------------
// Turn on "Allow any ROM size for recognition' to infer ROM for the logic below
// ------------------------------------------------------------------------------
//reg  [124:0] ROM [0:11];
reg  [186:0] ROM [0:15];
wire [3:0]   ADDRA = 4'b0000;
wire         WEA   = 1'b0;
wire [186:0] DATAA = 187'd0;
wire [3:0]   RADDR;
//assign RADDR = tx_std[1] ? {select_std[4], 4'b1111} : (~tx_std[0] ? {4'b0000, select_std[0]} : {1'b0, select_std[3:0]});
assign RADDR = tx_format;
                                                                                                                                                                                   // FORMAT                   SUPPORTED INTERFACE 
initial begin                                                                                                                         //HD,   3GA,  3GB,  byte2  line_f0 line_f1   // --------------------------------------------------------
   ROM[0]   <= {8'd134, 12'd   0, 11'd525,   13'd720,  13'd858,  11'd263, 11'd1, 11'd17, 11'd261,  11'd280, 11'd523,  11'd140, 11'd400, 4'h1, 4'h0, 4'h0, 8'h06, 11'd13, 11'd276}; // NTSC                     259M SD
   ROM[1]   <= {8'd140, 12'd   0, 11'd625,   13'd720,  13'd864,  11'd313, 11'd1, 11'd23, 11'd311,  11'd336, 11'd624,  11'd163, 11'd473, 4'h1, 4'h0, 4'h0, 8'h05, 11'd9,  11'd322}; // PAL                      259M SD
   ROM[2]   <= {8'd  0, 12'd 268, 11'd1125,  13'd1920, 13'd2200, 11'd564, 11'd1, 11'd41, 11'd1121, 11'd603, 11'd558,  11'd298, 11'd861, 4'h5, 4'h9, 4'hC, 8'h07, 11'd10, 11'd572}; // 1035i                    260M HD,3GB-2x1080-line                                    
   ROM[3]   <= {8'd  0, 12'd 444, 11'd1250,  13'd1920, 13'd2376, 11'd626, 11'd1, 11'd81, 11'd621,  11'd706, 11'd1246, 11'd350, 11'd975, 4'h5, 4'h9, 4'hC, 8'h05, 11'd10, 11'd572}; // 1080i50                  295M HD,3GB-2x1080-line   WFM700/7120 can't recognize this
   ROM[4]   <= {8'd  0, 12'd 268, 11'd1125,  13'd1920, 13'd2200, 11'd564, 11'd1, 11'd21, 11'd561,  11'd584, 11'd1124, 11'd290, 11'd853, 4'h5, 4'h9, 4'hC, 8'h07, 11'd10, 11'd572}; // 1080i60/59.94            274M HD,3GB-2x1080-line
   ROM[5]   <= {8'd  0, 12'd 708, 11'd1125,  13'd1920, 13'd2640, 11'd564, 11'd1, 11'd21, 11'd561,  11'd584, 11'd1124, 11'd290, 11'd853, 4'h5, 4'h9, 4'hC, 8'h05, 11'd10, 11'd572}; // 1080i50                  274M HD,3GB-2x1080-line
   ROM[6]   <= {8'd  0, 12'd 818, 11'd1125,  13'd1920, 13'd2750, 11'd0,   11'd0, 11'd42, 11'd1122, 11'd0,   11'd0,    11'd581, 11'd0,   4'h5, 4'h9, 4'hC, 8'hC3, 11'd10, 11'd0};   // 1080p24/23.98            274M HD,3GB-2x1080-line
   ROM[7]   <= {8'd  0, 12'd 358, 11'd750,   13'd1280, 13'd1650, 11'd0,   11'd0, 11'd26, 11'd746,  11'd0,   11'd0,    11'd385, 11'd0,   4'h4, 4'h8, 4'hB, 8'h4B, 11'd10, 11'd0};   // 720p60/59.94             296M HD,3GB-2x720-line
   ROM[8]   <= {8'd  0, 12'd 688, 11'd750,   13'd1280, 13'd1980, 11'd0,   11'd0, 11'd26, 11'd746,  11'd0,   11'd0,    11'd385, 11'd0,   4'h4, 4'h8, 4'hB, 8'h49, 11'd10, 11'd0};   // 720p50                   296M HD,3GB-2x720-line
   ROM[9]   <= {8'd  0, 12'd2008, 11'd750,   13'd1280, 13'd3300, 11'd0,   11'd0, 11'd26, 11'd746,  11'd0,   11'd0,    11'd385, 11'd0,   4'h4, 4'h8, 4'hB, 8'h47, 11'd10, 11'd0};   // 720p30/29.97             296M HD,3GB-2x720-line
   ROM[10]  <= {8'd  0, 12'd2668, 11'd750,   13'd1280, 13'd3960, 11'd0,   11'd0, 11'd26, 11'd746,  11'd0,   11'd0,    11'd385, 11'd0,   4'h4, 4'h8, 4'hB, 8'h45, 11'd10, 11'd0};   // 720p25                   296M HD,3GB-2x720-line
   ROM[11]  <= {8'd  0, 12'd2833, 11'd750,   13'd1280, 13'd4125, 11'd0,   11'd0, 11'd26, 11'd746,  11'd0,   11'd0,    11'd385, 11'd0,   4'h4, 4'h8, 4'hB, 8'h43, 11'd10, 11'd0};   // 720p24/23.98             296M HD,3GB-2x720-line
   ROM[12]  <= {8'd  0, 12'd 268, 11'd1125,  13'd1920, 13'd2200, 11'd0,   11'd0, 11'd42, 11'd1122, 11'd0,   11'd0,    11'd581, 11'd0,   4'h5, 4'h9, 4'hC, 8'hC7, 11'd10, 11'd0};   // 1080p30/29.97,60/59.94   274M HD(30/29.97),,HD-DL(60/59.94),3GA(60/59.94),3GB-DL(60/59.94)
   ROM[13]  <= {8'd  0, 12'd 708, 11'd1125,  13'd1920, 13'd2640, 11'd0,   11'd0, 11'd42, 11'd1122, 11'd0,   11'd0,    11'd581, 11'd0,   4'h5, 4'h9, 4'hC, 8'hC5, 11'd10, 11'd0};   // 1080p25,50               274M HD(25),HD-DL(50),3GA(50),3GB-DL(50)
   ROM[14]  <= {8'd  0, 12'd 818, 11'd1125,  13'd1920, 13'd2750, 11'd564, 11'd1, 11'd21,  11'd561, 11'd584, 11'd1124, 11'd290, 11'd853, 4'h5, 4'h9, 4'hC, 8'h43, 11'd10, 11'd572}; // 1080sF24/23.98           274M HD,3GB-2x1080-line
   ROM[15]  <= {8'd0, 12'd0, 11'd0, 13'd0, 13'd0, 11'd0, 11'd0, 11'd0, 11'd0, 11'd0, 11'd0, 11'd0, 11'd0, 4'h0, 4'h0, 4'h0, 8'h00, 11'd10, 11'd0};    // Reserved
end


// Format          Interface      tx_std    tx_format   dl_mapping(line numbers alternate between link A and link B)  
// -----------------------------------------------------------------------------------------------------------------
// 1035i           HD             2'b01     4'b0010     1'b0			
// 1035ix2         HD-DL          2'b01     4'b0010     1'b0			
// 1035ix2         3GB-2x1080     2'b10     4'b0010     1'b0

// 1080i60/59.94   HD             2'b01     4'b0100     1'b0
// 1080i60/59.94x2 HD-DL          2'b01     4'b0100     1'b0		
// 1080i60/59.94x2 3GB-2x1080     2'b10     4'b0100     1'b0

// 1080p30/29.97   HD  	          2'b01     4'b1100     1'b0
// 1080p30/29.97x2 HD-DL          2'b01     4'b1100     1'b0
// 1080p60/59.94   HD-DL          2'b01     4'b1100     1'b1
// 1080p60/59.94   3GA            2'b11     4'b1100     1'b0
// 1080p60/59.94   3GB-DL         2'b10     4'b1100     1'b1

always @ (posedge clk)
begin
  if (WEA) begin
    ROM[ADDRA] <= DATAA;
  end
end

reg [186:0] RDATA;
always @ (posedge clk)
begin
  RDATA <= ROM[RADDR];
end

wire [3:0] rdata1;
assign rdata1 = tx_std[1] ? (tx_std[0] ? RDATA[37:34] : (dl_mapping ? 4'hA : RDATA[33:30])) : (tx_std[0] ? (dl_mapping ? 4'h7 : RDATA[41:38]) : RDATA[41:38]);

localparam [4:0] WORD_DIVIDER = (IS_RTL_SIM == 1'b1) ? 5'd20 : 5'd1;
localparam [2:0] HANC_DIVIDER = (IS_RTL_SIM == 1'b1) ? 3'd5 : 3'd1;

assign int_sd_hanc_y_word        = RDATA[186:179]/HANC_DIVIDER; // words_per_total_line - words_per_active_line - 4
assign int_hd_hanc_word          = RDATA[178:167]/HANC_DIVIDER; // words_per_total_line - words_per_active_line - 8 - 4
assign int_lines_per_frame       = RDATA[166:156];
assign int_words_per_active_line = RDATA[155:143]/WORD_DIVIDER;
assign int_words_per_total_line  = RDATA[142:130]/WORD_DIVIDER;
assign int_f_rise_line           = RDATA[129:119];
assign int_f_fall_line           = RDATA[118:108];
assign int_v_fall_line_1         = RDATA[107:97];
assign int_v_rise_line_1         = RDATA[96:86];
assign int_v_fall_line_2         = RDATA[85:75];
assign int_v_rise_line_2         = RDATA[74:64];
assign int_patho_change_line_1   = RDATA[63:53];
assign int_patho_change_line_2   = RDATA[52:42];
assign int_vpid_byte1            = {4'b1000, rdata1};
assign int_vpid_byte2_a          = (tx_std==2'b11 | dl_mapping) ? {4'b0100, (tx_format==4'd12 ? 4'hB : (tx_format==4'd13 ? 4'h9 : RDATA[25:22]))} : // Picture rate is doubled for 3G and HD Dual Link interfaces
                                   (tx_format == 4'd4 | tx_format == 4'd5) ? {1'b0, sgmt_frame, RDATA[27:22]} :
                                                                             RDATA[29:22]; 
assign int_vpid_byte2            = (ntsc_paln & int_vpid_byte2_a[3:0] == 4'h3) ? {int_vpid_byte2_a[7:4], 4'h2} :
                                   (ntsc_paln & int_vpid_byte2_a[3:0] == 4'h7) ? {int_vpid_byte2_a[7:4], 4'h6} :
                                   (ntsc_paln & int_vpid_byte2_a[3:0] == 4'hB) ? {int_vpid_byte2_a[7:4], 4'hA} :
                                                                                 int_vpid_byte2_a;
assign int_vpid_byte3            = 8'b00000000; // Sampling structure = YCrCb 422
assign int_vpid_byte4            = 8'b00000001; // Bit depth = 10
assign int_line_f0               = RDATA[21:11];
assign int_line_f1               = RDATA[10:0];

// ----------------------
// Interleave 3GB output
// ----------------------
reg [19:0] dout_3gb, dout_3gb_dly;
reg [1:0]  trs_dly;
reg        ce_i_dly;
always @ (posedge clk or posedge rst) // frequency of 148.5MHz 
begin
  if (rst) begin
    trs_dly      <= 2'b00;
    dout_3gb     <= 20'd0;
    dout_3gb_dly <= 20'd0;
    ce_i_dly     <= 1'b0;
  end else begin
    trs_dly[0]   <= trs_i;
    trs_dly[1]   <= trs_dly[0];
    dout_3gb_dly <= dout_3gb;
    ce_i_dly     <= ce_i;

    if (ce_i_dly) begin // frequency of 74.25MHz
      dout_3gb[19:10] <= dout_i[19:10];
      dout_3gb[9:0]   <= dout_i[19:10];
    end else begin
      dout_3gb[19:10] <= dout_i[9:0];
      dout_3gb[9:0]   <= dout_i[9:0];
    end
  end
end

assign dout  = (tx_std == 2'b10) ? dout_3gb_dly : ((tx_std != 2'b00) ? dout_i : (EN_SD_20BITS ? dout_int_i : dout_i));
assign dout_b = dout_i;
assign dout_valid = tx_std[1] ? enable : (tx_std[0] ? dout_valid_i : (EN_SD_20BITS ? enable : dout_valid_i));
assign dout_valid_b = dout_valid_i;
assign trs   = (tx_std == 2'b10) ? trs_dly[1] : ((tx_std != 2'b00) ? trs_i : (EN_SD_20BITS ? trs_20 : trs_i));
assign trs_b  = trs_i;
assign ln    = (dl_mapping & tx_std == 2'b01) ? dl_ln : ln_i;
assign ln_b  = (dl_mapping & tx_std == 2'b01) ? dl_ln : lnb_i;
assign vpid_byte1 = int_vpid_byte1;
assign vpid_byte2 = int_vpid_byte2;
assign vpid_byte3 = int_vpid_byte3;
assign vpid_byte4 = int_vpid_byte4;
assign vpid_byte1_b = int_vpid_byte1;
assign vpid_byte2_b = int_vpid_byte2;
assign vpid_byte3_b = int_vpid_byte3;
assign vpid_byte4_b = {int_vpid_byte4[7], (((tx_std==2'b10) | (tx_std==2'b01 & dl_mapping)) ? 1'b1 : 1'b0), int_vpid_byte4[5:0]}; // Channel assignment: 1-link A, 2-linkB
assign line_f0    = int_line_f0;
assign line_f1    = int_line_f1;

endmodule
