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
// Pathological "checkfield" pattern generator. Refer to RP178(NTSC, PAL) and RP198 for details.
//
//--------------------------------------------------------------------------------------------------

module sdi_ii_patho_gen (
  hd_sdn,
  clk,
  rst,
  req,
  ln,
  wn,
  yout,
  cout,

  field1_start_ln,
  field1_pattern_change_ln,
  field2_start_ln,
  field2_pattern_change_ln,
  pal_nstcn
  );

input hd_sdn;
input clk;
input rst;
input req;
input [10:0] ln;
input [12:0] wn;
output [9:0] yout;
output [9:0] cout;
input [10:0] field1_start_ln;
input [10:0] field1_pattern_change_ln;
input [10:0] field2_start_ln;
input [10:0] field2_pattern_change_ln;
input pal_nstcn;

parameter [9:0] Y_BLANKING_DATA = 10'h040;
parameter [9:0] C_BLANKING_DATA = 10'h200;

reg [9:0] cout;
reg [9:0] yout;
reg odd;

always @ (posedge clk or posedge rst)
begin
  if (rst) begin
    yout <= Y_BLANKING_DATA;
    cout <= C_BLANKING_DATA;
    odd  <= 1'b0;
  end
  else if (req) begin
    if (hd_sdn & ln==field1_start_ln & wn==1) begin
      odd <= ~odd;
      if (~odd) begin
        yout <= 10'h198;
      end else begin
        yout <= 10'h190;
      end
      cout <= 10'h300;
    end
    else if (~hd_sdn & ln==field1_start_ln & ((wn==864 & pal_nstcn) | (wn==858 & ~pal_nstcn))) begin
      yout <= 10'h080;
      cout <= 10'h300;
    end
    else if (ln<field1_pattern_change_ln) begin
      yout <= 10'h198;
      cout <= 10'h300;
    end
    else if (ln<field2_start_ln) begin
      yout <= 10'h110;
      cout <= 10'h200;
    end
    else if (ln<field2_pattern_change_ln) begin
      yout <= 10'h198;
      cout <= 10'h300;
    end
    else begin
      yout <= 10'h110;
      cout <= 10'h200;
    end
  end
end

endmodule
