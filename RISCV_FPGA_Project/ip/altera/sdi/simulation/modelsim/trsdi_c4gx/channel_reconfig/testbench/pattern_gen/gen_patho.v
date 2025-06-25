//--------------------------------------------------------------------------------------------------
// (c)2003 Altera Corporation. All rights reserved.
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
// This reference design file is being provided on an ?as-is? basis and as an
// accommodation and therefore all warranties, representations or guarantees of
// any kind (whether express, implied or statutory) including, without
// limitation, warranties of merchantability, non-infringement, or fitness for
// a particular purpose, are specifically disclaimed.  By making this reference
// design file available, Altera expressly does not recommend, suggest or
// require that this reference design file be used in combination with any
// other product not provided by Altera.
//--------------------------------------------------------------------------------------------------
// File          : $RCSfile: gen_patho.v,v $
// Last modified : $Date: 2007/10/01 16:13:37 $
// Export tag    : $Name:  $
//--------------------------------------------------------------------------------------------------
//
// Pathological "checkfield" pattern generator. Refer to RP198 for details.
//
//--------------------------------------------------------------------------------------------------

module gen_patho (
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
  field2_pattern_change_ln
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
    odd = 1'b0;
  end
  else if (req) begin

    if (hd_sdn & ln==field1_start_ln & wn==1) begin
      odd = ~odd;
      if (odd)
        yout <= 10'h198;
      else
        yout <= 10'h190;
      cout <= 10'h300;
    end
    else if (~hd_sdn & ln==field1_start_ln & wn==858) begin
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
