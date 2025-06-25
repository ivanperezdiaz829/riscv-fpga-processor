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
// File          : $RCSfile: gen_colorbar_new.v,v $
// Last modified : $Date: 2008/11/28 $
// Export tag    : $Name:  $
//--------------------------------------------------------------------------------------------------
//
// Colorbar pattern generator. This function is only intended for test purposes, and for simple
// demonstrations. It only applies basic shaping to the transitions between colors. It is also not
// an optimal implementation (ROM could be used to store the colorbar values to save area).
//
//--------------------------------------------------------------------------------------------------

module gen_colorbar_new (
  clk,
  rst,
  hd_sdn,
  bar_75_100n,
  req,
  wn,
  words_per_active_line,
  yout,
  cout
  );

input clk;
input rst;
input hd_sdn;
input bar_75_100n;
input req;
input [12:0] wn;
input [12:0] words_per_active_line;
output [9:0] yout;
output [9:0] cout;

//--------------------------------------------------------------------------------------------------
// Define colorbars - default values are 75% colorbar
//--------------------------------------------------------------------------------------------------
parameter NUMBER_OF_BARS = 8;

wire [9:0]  Y_COLOR0 = 10'd940;      // 75% White
wire [9:0] CB_COLOR0 = 10'd512;
wire [9:0] CR_COLOR0 = 10'd512;

wire [9:0]  Y_COLOR1 = hd_sdn ? (bar_75_100n ? 10'd674 : 10'd877) : (bar_75_100n ? 10'd646 : 10'd840);      // Yellow
wire [9:0] CB_COLOR1 = hd_sdn ? (bar_75_100n ? 10'd176 : 10'd64)  : (bar_75_100n ? 10'd176 : 10'd64);
wire [9:0] CR_COLOR1 = hd_sdn ? (bar_75_100n ? 10'd543 : 10'd553) : (bar_75_100n ? 10'd567 : 10'd586);

wire [9:0]  Y_COLOR2 = hd_sdn ? (bar_75_100n ? 10'd581 : 10'd754) : (bar_75_100n ? 10'd525 : 10'd678);      // Cyan
wire [9:0] CB_COLOR2 = hd_sdn ? (bar_75_100n ? 10'd589 : 10'd615) : (bar_75_100n ? 10'd626 : 10'd664);
wire [9:0] CR_COLOR2 = hd_sdn ? (bar_75_100n ? 10'd176 : 10'd64)  : (bar_75_100n ? 10'd176 : 10'd64);

wire [9:0]  Y_COLOR3 = hd_sdn ? (bar_75_100n ? 10'd534 : 10'd691) : (bar_75_100n ? 10'd450 : 10'd578);      // Green
wire [9:0] CB_COLOR3 = hd_sdn ? (bar_75_100n ? 10'd253 : 10'd167) : (bar_75_100n ? 10'd290 : 10'd215);
wire [9:0] CR_COLOR3 = hd_sdn ? (bar_75_100n ? 10'd207 : 10'd105) : (bar_75_100n ? 10'd231 : 10'd137);

wire [9:0]  Y_COLOR4 = hd_sdn ? (bar_75_100n ? 10'd251 : 10'd313) : (bar_75_100n ? 10'd335 : 10'd426);      // Magenta
wire [9:0] CB_COLOR4 = hd_sdn ? (bar_75_100n ? 10'd771 : 10'd857) : (bar_75_100n ? 10'd735 : 10'd809);
wire [9:0] CR_COLOR4 = hd_sdn ? (bar_75_100n ? 10'd817 : 10'd919) : (bar_75_100n ? 10'd793 : 10'd888);

wire [9:0]  Y_COLOR5 = hd_sdn ? (bar_75_100n ? 10'd204 : 10'd250) : (bar_75_100n ? 10'd260 : 10'd326);      // Red
wire [9:0] CB_COLOR5 = hd_sdn ? (bar_75_100n ? 10'd435 : 10'd409) : (bar_75_100n ? 10'd399 : 10'd361);
wire [9:0] CR_COLOR5 = hd_sdn ? (bar_75_100n ? 10'd848 : 10'd960) : (bar_75_100n ? 10'd848 : 10'd960);

wire [9:0]  Y_COLOR6 = hd_sdn ? (bar_75_100n ? 10'd111 : 10'd127) : (bar_75_100n ? 10'd139 : 10'd164);      // Blue
wire [9:0] CB_COLOR6 = hd_sdn ? (bar_75_100n ? 10'd848 : 10'd960) : (bar_75_100n ? 10'd848 : 10'd960);
wire [9:0] CR_COLOR6 = hd_sdn ? (bar_75_100n ? 10'd481 : 10'd471) : (bar_75_100n ? 10'd457 : 10'd438);

wire [9:0]  Y_COLOR7 = 10'd64;       // Black
wire [9:0] CB_COLOR7 = 10'd512;
wire [9:0] CR_COLOR7 = 10'd512;

parameter [9:0] Y_BLANKING_DATA = 10'h040;
parameter [9:0] C_BLANKING_DATA = 10'h200;


reg [9:0] y_bar;
reg [9:0] cr_bar;
reg [9:0] cout;
reg [9:0] yout;
//reg [9:0] y_d1;
reg [9:0] cb_bar;   
//reg [9:0] cb_d1;
//reg [9:0] cr_d1;
//reg [9:0] y_d2;
//reg [9:0] cb_d2;
//reg [9:0] cr_d2;

reg [11:0] y_sum2;

reg [9:0]  y_d1n; 

reg [11:0] cr_sum2;
reg [9:0]  cr_d1n;
reg [9:0]  cr_dly;
reg [9:0]  y_dly;   
 

reg [11:0] cb_sum2;
reg [9:0]  cb_d1n; 
  
   
   
always @ (posedge clk or posedge rst)
begin
  if (rst) begin
    /* 
    yout <= Y_BLANKING_DATA;
    cout <= C_BLANKING_DATA;
    y_d1  = Y_BLANKING_DATA;
    cb_d1 = C_BLANKING_DATA;
    cr_d1 = C_BLANKING_DATA;
    y_d2  = Y_BLANKING_DATA;
    cb_d2 = C_BLANKING_DATA;
    cr_d2 = C_BLANKING_DATA;
    
    y_sum2 = Y_BLANKING_DATA;
    y_d1n = Y_BLANKING_DATA;
     
    cb_sum2 = C_BLANKING_DATA;
    cb_d1n = C_BLANKING_DATA;

    cr_sum2 = C_BLANKING_DATA;
    cr_d1n = C_BLANKING_DATA;
*/
   
     
  end
  else if (req) begin

    if (wn==0) begin
      y_bar  = 10'd64;
      cb_bar = 10'd512;
      cr_bar = 10'd512;
      //y_d1  = 10'd64;
      //cb_d1 = 10'd512;
      //cr_d1 = 10'd512;
      //y_d2  = 10'd64;
      //cb_d2 = 10'd512;
      //cr_d2 = 10'd512;
  

       
    end
    else if (wn<=(words_per_active_line/NUMBER_OF_BARS)*1) begin
      y_bar  =  Y_COLOR0;
      cb_bar = CB_COLOR0;
      cr_bar = CR_COLOR0;
    end
    else if (wn<=(words_per_active_line/NUMBER_OF_BARS)*2) begin
      y_bar  =  Y_COLOR1;
      cb_bar = CB_COLOR1;
      cr_bar = CR_COLOR1;
    end
    else if (wn<=(words_per_active_line/NUMBER_OF_BARS)*3) begin
      y_bar  =  Y_COLOR2;
      cb_bar = CB_COLOR2;
      cr_bar = CR_COLOR2;
    end
    else if (wn<=(words_per_active_line/NUMBER_OF_BARS)*4) begin
      y_bar  =  Y_COLOR3;
      cb_bar = CB_COLOR3;
      cr_bar = CR_COLOR3;
    end
    else if (wn<=(words_per_active_line/NUMBER_OF_BARS)*5) begin
      y_bar  =  Y_COLOR4;
      cb_bar = CB_COLOR4;
      cr_bar = CR_COLOR4;
    end
    else if (wn<=(words_per_active_line/NUMBER_OF_BARS)*6) begin
      y_bar  =  Y_COLOR5;
      cb_bar = CB_COLOR5;
      cr_bar = CR_COLOR5;
    end
    else if (wn<=(words_per_active_line/NUMBER_OF_BARS)*7) begin
      y_bar  =  Y_COLOR6;
      cb_bar = CB_COLOR6;
      cr_bar = CR_COLOR6;
    end
    else begin
      y_bar  =  Y_COLOR7;
      cb_bar = CB_COLOR7;
      cr_bar = CR_COLOR7;
    end

     
    //y_d2 = y_d1;
    //y_d1 = y_bar;

   
  end
end


always @ (posedge clk or posedge rst)
begin
  if (rst) begin
  // rst statements
   yout <= Y_BLANKING_DATA;
    cout <= C_BLANKING_DATA;

    
    y_sum2 = Y_BLANKING_DATA;

    y_d1n = Y_BLANKING_DATA;
    y_dly = Y_BLANKING_DATA;     
     
    cb_sum2 = C_BLANKING_DATA;
    cb_d1n = C_BLANKING_DATA;

    cr_sum2 = C_BLANKING_DATA;
    cr_d1n = C_BLANKING_DATA;
    cr_dly = C_BLANKING_DATA;
 
     
   
  end
   
  else if (req) begin
 
    
     yout = y_dly;
     y_dly = (y_bar + y_sum2)/ (10'd4);
     y_sum2 = ((10'd2)*y_bar + y_d1n);      
     y_d1n = y_bar;

    if (wn[0]) begin
      
      //cb_d2 = cb_d1;
      //cb_d1 = cb_bar;

     cout = (cb_bar + cb_sum2)/(10'd4);
     cb_sum2 = ((10'd2)*cb_bar + cb_d1n);      
     cb_d1n = cb_bar;
  
    end
    else begin

      //cr_d2 = cr_d1;
      //cr_d1 = cr_bar;
      cout = cr_dly;
      cr_dly = (cr_bar + cr_sum2)/(10'd4);
       

     cr_sum2 = ((10'd2)*cr_bar + cr_d1n);      
     cr_d1n = cr_bar;


       
    end // else: !if(wn[0])
  end // if (req)
end // always @ (posedge clk or posedge rst)
   
   

   
endmodule
