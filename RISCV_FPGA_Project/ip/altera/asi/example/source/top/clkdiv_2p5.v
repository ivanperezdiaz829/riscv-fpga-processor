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
// This reference design file is being provided on an "as-is" basis and as an
// accommodation and therefore all warranties, representations or guarantees of
// any kind (whether express, implied or statutory) including, without
// limitation, warranties of merchantability, non-infringement, or fitness for
// a particular purpose, are specifically disclaimed.  By making this reference
// design file available, Altera expressly does not recommend, suggest or
// require that this reference design file be used in combination with any
// other product not provided by Altera.
//--------------------------------------------------------------------------------------------------
// File          : $RCSfile: clkdiv_2p5.v,v $
// Last modified : $Date: 2013/08/11 $
// Export tag    : $Name:  $
//--------------------------------------------------------------------------------------------------
//
// Frequency translator.
// Output clock is 2.5 times slower than input clock
//
//--------------------------------------------------------------------------------------------------

module clkdiv_2p5 (
	rst,
	sclk,
	sclk90,
	clkdiv
	);

input	rst;
input	sclk;
input	sclk90;
output	clkdiv;



reg  [2:0] count;
reg  [2:0] count90;
reg  [2:0] count180;
reg  [2:0] count270;

reg	flag;
reg	flag90;
reg	flag180;
reg	flag270;


always @(posedge sclk or posedge rst)
if (rst)
begin
  count <= 3'b000;
  flag <= 1;
end
else
begin
  if (count==3'd4) count <= 0;
  else count <= count + 3'd1;
  if (count==3'd0) flag <= 1;
  if (count==3'd2) flag <= 0;
end

always @(negedge sclk or posedge rst)
if (rst)
begin
  count180 <= 3'b000;
  flag180 <= 0;
end
else
begin
  if (count180==3'd4) count180 <= 0;
  else count180 <= count180 + 3'd1;
  if (count180==3'd0) flag180 <= 1;
  if (count180==3'd2) flag180 <= 0;
end

always @(posedge sclk90 or posedge rst)
if (rst)
begin
  count90 = 3'b000;
  flag90 <= 0;
end
else
begin
  if (count90==3'd4) count90 <= 0;
  else count90 <= count90 + 3'd1;
  if (count90==3'd1) flag90 <= 1;
  if (count90==3'd3) flag90 <= 0;
end

always @(negedge sclk90 or posedge rst)
if (rst)
begin
  count270 <= 3'b000;
  flag270 <= 0;
end
else
begin
  if (count270==3'd4) count270 <= 0;
  else count270 <= count270 + 3'd1;
  if (count270==3'd1) flag270 <= 1;
  if (count270==3'd3) flag270 <= 0;
end



wire	clkdiv = ((flag | flag180) ^ (flag90 | flag270)) /* synthesis keep = 1 */;

endmodule
