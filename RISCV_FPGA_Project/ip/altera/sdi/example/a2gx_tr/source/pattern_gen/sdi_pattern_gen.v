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
// This reference design file is being provided on an "as-is" basis and as an
// accommodation and therefore all warranties, representations or guarantees of
// any kind (whether express, implied or statutory) including, without
// limitation, warranties of merchantability, non-infringement, or fitness for
// a particular purpose, are specifically disclaimed.  By making this reference
// design file available, Altera expressly does not recommend, suggest or
// require that this reference design file be used in combination with any
// other product not provided by Altera.
//--------------------------------------------------------------------------------------------------
// File          : $RCSfile: sdi_pattern_gen.v,v $
// Last modified : $Date: 2008/08/08 $
// Export tag    : $Name:  $
//--------------------------------------------------------------------------------------------------
//
// Video pattern generator.
//
//--------------------------------------------------------------------------------------------------

module sdi_pattern_gen 
(
  clk,
  rst,
  hd_sdn,
  bar_75_100n,
  enable,
  patho,
  blank,
  no_color,

  dout,
  trs,
  ln,

  select_std

  );

input         clk;
input         rst;
input         hd_sdn;
input         bar_75_100n;
input         enable;
input         patho;
input         blank;
input         no_color;

output [19:0] dout;
output        trs;
output [10:0] ln;

input  [1:0]  select_std;

reg [10:0] int_lines_per_frame;
reg [12:0] int_words_per_active_line;
reg [12:0] int_words_per_total_line;
reg [10:0] int_f_rise_line;
reg [10:0] int_v_fall_line_1;
reg [10:0] int_v_rise_line_1;
reg [10:0] int_v_fall_line_2;
reg [10:0] int_v_rise_line_2;
reg [10:0] int_patho_change_line_1;
reg [10:0] int_patho_change_line_2;

   

//--------------------------------------------------------------------------------------------------
// Colorbar generator
//--------------------------------------------------------------------------------------------------
wire req;                               // Data request from frame generator to pattern generator
wire [12:0] wn;                         // Word number to accompany request
wire [9:0] y_gen;
wire [9:0] c_gen;
gen_colorbar_new u_colorbar (
  .clk                      (clk),
  .rst                      (rst),
  .hd_sdn                   (hd_sdn),
  .bar_75_100n              (bar_75_100n),
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
gen_patho u_patho (
  .hd_sdn                   (hd_sdn),
  .clk                      (clk),
  .rst                      (rst),
  .req                      (req),
  .ln                       (ln),
  .wn                       (wn),
  .yout                     (y_patho),
  .cout                     (c_patho),
  .field1_start_ln          (int_v_fall_line_1),
  .field1_pattern_change_ln (int_patho_change_line_1),
  .field2_start_ln          (int_v_fall_line_2),
  .field2_pattern_change_ln (int_patho_change_line_2)
  );

//--------------------------------------------------------------------------------------------------
// Select data for output pattern - blank, pathological or colorbar
//--------------------------------------------------------------------------------------------------

wire [9:0] y_make = patho ? y_patho : blank ? 10'h040 : y_gen;
wire [9:0] c_make = patho ? c_patho : (no_color | blank) ? 10'h200 : c_gen;


//--------------------------------------------------------------------------------------------------
// Create output frame - 1080i used for this demo
//--------------------------------------------------------------------------------------------------







sdi_makeframe u_makeframe (
  .hd_sdn                   (hd_sdn),

  .clk                      (clk),
  .rst                      (rst),
  .enable                   (enable),
  .din_req                  (req),
  .ln                       (ln),
  .field_line               (),
  .word_count               (wn),
  .din_y                    (y_make),
  .din_c                    (c_make),
  .dout                     (dout),
  .trs                      (trs),

  .lines_per_frame          (int_lines_per_frame),
  .words_per_active_line    (int_words_per_active_line),
  .words_per_total_line     (int_words_per_total_line),
  .f_rise_line              (int_f_rise_line),
  .v_fall_line_1            (int_v_fall_line_1),
  .v_rise_line_1            (int_v_rise_line_1),
  .v_fall_line_2            (int_v_fall_line_2),
  .v_rise_line_2            (int_v_rise_line_2)
  );

//--------------------------------------------------------------------------------------------------
// Mux between various standards.
//--------------------------------------------------------------------------------------------------

   always @ (select_std)
     begin
      if (select_std == 2'b01) begin
         // 1080i
         int_lines_per_frame          <= 11'd1125;
         int_words_per_active_line    <= 13'd1920;
         int_words_per_total_line     <= 13'd2200;
         int_f_rise_line              <= 11'd564;
         int_v_fall_line_1            <= 11'd21;
         int_v_rise_line_1            <= 11'd561;
         int_v_fall_line_2            <= 11'd584;
         int_v_rise_line_2            <= 11'd1124;
         int_patho_change_line_1      <= 11'd290;
         int_patho_change_line_2      <= 11'd853;

         
         
         
      end
      else if (select_std == 2'b10) begin
         // ntsc
         int_lines_per_frame          <= 11'd525;
         int_words_per_active_line    <= 13'd720;
         int_words_per_total_line     <= 13'd858;
         int_f_rise_line              <= 11'd263;
         int_v_fall_line_1            <= 11'd17;
         int_v_rise_line_1            <= 11'd261;
         int_v_fall_line_2            <= 11'd280;
         int_v_rise_line_2            <= 11'd523;
         int_patho_change_line_1      <= 11'd140;
         int_patho_change_line_2      <= 11'd400;
      end   
      else if (select_std == 2'b11) begin
         // pal     
         int_lines_per_frame          <= 11'd625;
         int_words_per_active_line    <= 13'd720;
         int_words_per_total_line     <= 13'd864;
         int_f_rise_line              <= 11'd313;
         int_v_fall_line_1            <= 11'd23;
         int_v_rise_line_1            <= 11'd311;
         int_v_fall_line_2            <= 11'd336;
         int_v_rise_line_2            <= 11'd624;
         int_patho_change_line_1      <= 11'd164;
         int_patho_change_line_2      <= 11'd474;
      end
      else begin
                  
         // 1080p only for 3G modes.
         int_lines_per_frame          <= 11'd1125;
         int_words_per_active_line    <= 13'd1920;
         int_words_per_total_line     <= 13'd2200;
         //int_f_rise_line              <= 11'd1;
         int_f_rise_line              <= 11'd1126;
         int_v_fall_line_1            <= 11'd42;
         int_v_rise_line_1            <= 11'd1122;
         int_v_fall_line_2            <= 11'd0;
         int_v_rise_line_2            <= 11'd0;
         // patho change lines unchanged from 1080i
         int_patho_change_line_1      <= 11'd290;
         int_patho_change_line_2      <= 11'd853;
         
         
      end  
    end
 
endmodule
