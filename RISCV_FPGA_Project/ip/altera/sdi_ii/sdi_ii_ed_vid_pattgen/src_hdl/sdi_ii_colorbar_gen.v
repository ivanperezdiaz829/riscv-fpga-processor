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
// Colorbar pattern generator. This function is only intended for test purposes, and for simple
// demonstrations. It only applies basic shaping to the transitions between colors. It is also not
// an optimal implementation (ROM could be used to store the colorbar values to save area).
//
//--------------------------------------------------------------------------------------------------

module sdi_ii_colorbar_gen (
  clk,
  rst,
  hd_sdn,
  bar_100_75n,
  req,
  wn,
  words_per_active_line,
  yout,
  cout
  );

input clk;
input rst;
input hd_sdn;
input bar_100_75n;
input req;
input [12:0] wn;
input [12:0] words_per_active_line;
output [9:0] yout;
output [9:0] cout;

parameter [3:0] NUMBER_OF_BARS = 4'd8;
parameter [9:0] Y_BLANKING_DATA = 10'h040;
parameter [9:0] C_BLANKING_DATA = 10'h200;

//--------------------------------------------------------------------------------------------------
// Define colorbars - default values are 75% colorbar
//--------------------------------------------------------------------------------------------------
reg  [29:0] ROM [0:31];
wire [4:0]  ADDRA = 5'b00000;
wire        WEA   = 1'b0;
wire [29:0] DATAA = 30'd0;
wire [4:0]  RADDR;

// -------------------------------------------------------------------------------------------------------------------------------------
// Turn on Analysis & Synthesis settings -> "Allow any ROM size for recognition' to infer any size ROM for the logic below. Default:OFF
// Turn off Fitter Settings -> "Auto RAM to MLAB conversion" to not use LAB locations to implement memory. Default:ON
// -------------------------------------------------------------------------------------------------------------------------------------
// Y, Cr, Cb
initial begin
	ROM[0]  <= {10'd940, 10'd512, 10'd512}; // YCrCb SD 75% Bar 1
	ROM[1]  <= {10'd646, 10'd567, 10'd176}; // YCrCb SD 75% Bar 2
	ROM[2]  <= {10'd525, 10'd176, 10'd626}; // YCrCb SD 75% Bar 3
	ROM[3]  <= {10'd450, 10'd231, 10'd290}; // YCrCb SD 75% Bar 4
	ROM[4]  <= {10'd335, 10'd793, 10'd735}; // YCrCb SD 75% Bar 5
	ROM[5]  <= {10'd260, 10'd848, 10'd399}; // YCrCb SD 75% Bar 6
	ROM[6]  <= {10'd139, 10'd457, 10'd848}; // YCrCb SD 75% Bar 7
	ROM[7]  <= {10'd64,  10'd512, 10'd512}; // YCrCb SD 75% Bar 8
	ROM[8]  <= {10'd940, 10'd512, 10'd512}; // YCrCb SD 100% Bar 1
	ROM[9]  <= {10'd840, 10'd586, 10'd64};  // YCrCb SD 100% Bar 2
	ROM[10] <= {10'd678, 10'd64,  10'd664}; // YCrCb SD 100% Bar 3
	ROM[11] <= {10'd578, 10'd137, 10'd215}; // YCrCb SD 100% Bar 4
	ROM[12] <= {10'd426, 10'd888, 10'd809}; // YCrCb SD 100% Bar 5
	ROM[13] <= {10'd326, 10'd960, 10'd361}; // YCrCb SD 100% Bar 6
	ROM[14] <= {10'd164, 10'd438, 10'd960}; // YCrCb SD 100% Bar 7
	ROM[15] <= {10'd64,  10'd512, 10'd512}; // YCrCb SD 100% Bar 8
	ROM[16] <= {10'd940, 10'd512, 10'd512}; // YCrCb HD 75% Bar 1
	ROM[17] <= {10'd674, 10'd543, 10'd176}; // YCrCb HD 75% Bar 2
	ROM[18] <= {10'd581, 10'd176, 10'd589}; // YCrCb HD 75% Bar 3
	ROM[19] <= {10'd534, 10'd207, 10'd253}; // YCrCb HD 75% Bar 4
	ROM[20] <= {10'd251, 10'd817, 10'd771}; // YCrCb HD 75% Bar 5
	ROM[21] <= {10'd204, 10'd848, 10'd435}; // YCrCb HD 75% Bar 6
	ROM[22] <= {10'd111, 10'd481, 10'd848}; // YCrCb HD 75% Bar 7
	ROM[23] <= {10'd64,  10'd512, 10'd512}; // YCrCb HD 75% Bar 8
	ROM[24] <= {10'd940, 10'd512, 10'd512}; // YCrCb HD 100% Bar 1
	ROM[25] <= {10'd877, 10'd553, 10'd64};  // YCrCb HD 100% Bar 2
	ROM[26] <= {10'd754, 10'd64,  10'd615}; // YCrCb HD 100% Bar 3
	ROM[27] <= {10'd691, 10'd105, 10'd167}; // YCrCb HD 100% Bar 4
	ROM[28] <= {10'd313, 10'd919, 10'd857}; // YCrCb HD 100% Bar 5
	ROM[29] <= {10'd250, 10'd960, 10'd409}; // YCrCb HD 100% Bar 6
	ROM[30] <= {10'd127, 10'd471, 10'd960}; // YCrCb HD 100% Bar 7
	ROM[31] <= {10'd64,  10'd512, 10'd512}; // YCrCb HD 100% Bar 8
end

always @ (posedge clk)
begin
  if (WEA) begin
    ROM[ADDRA] <= DATAA;
  end
end

reg [2:0] bar_region;
//wire [2:0] bar_region;
//assign bar_region = (wn * NUMBER_OF_BARS) / words_per_active_line;
assign RADDR = {hd_sdn, bar_100_75n, bar_region};

reg [29:0] RDATA;
always @ (posedge clk)
begin
  RDATA <= ROM[RADDR];
end

wire [9:0] y_bar;
wire [9:0] cr_bar;
wire [9:0] cb_bar;
assign y_bar  = RDATA[29:20];
assign cr_bar = RDATA[19:10];
assign cb_bar = RDATA[9:0];

reg [11:0] bar_1;
reg [11:0] bar_2;
reg [11:0] bar_3;
reg [11:0] bar_4;
reg [11:0] bar_5;
reg [11:0] bar_6;
reg [11:0] bar_7;
always @ (posedge clk or posedge rst)
begin
  if (rst) begin
    bar_1 <= 12'd240;
    bar_2 <= 12'd480;
    bar_3 <= 12'd720;
    bar_4 <= 12'd960;
    bar_5 <= 12'd1200;
    bar_6 <= 12'd1440;
    bar_7 <= 12'd1680;
  end else if (req) begin
    bar_1 <= {2'b00, words_per_active_line[12:3]};          // /8 * 1 = /8
    bar_2 <= {1'b0, words_per_active_line[12:2]};           // /8 * 2 = /4
    bar_3 <= {2'b00, words_per_active_line[12:3]} * 12'd3;  // /8 * 3
    bar_4 <= words_per_active_line[12:1];                   // /8 * 4 = /2
    bar_5 <= {2'b00, words_per_active_line[12:3]} * 12'd5;  // /8 * 5
    bar_6 <= {1'b0, words_per_active_line[12:2]} * 12'd3;   // /8 * 6 = /4 * 3
    bar_7 <= {2'b00, words_per_active_line[12:3]} * 12'd7;  // /8 * 7
  end
end

always @ (posedge clk or posedge rst)
begin
  if (rst) begin
    bar_region <= 3'b000;
  end else if (req) begin
    if (wn<=bar_1) begin
      bar_region <= 3'b000;
    end else if (wn<=bar_2) begin
      bar_region <= 3'b001;
    end else if (wn<=bar_3) begin
      bar_region <= 3'b010;
    end else if (wn<=bar_4) begin
      bar_region <= 3'b011;
    end else if (wn<=bar_5) begin
      bar_region <= 3'b100;
    end else if (wn<=bar_6) begin
      bar_region <= 3'b101;
    end else if (wn<=bar_7) begin
      bar_region <= 3'b110;
    end else begin
      bar_region <= 3'b111;
    end
  end
end

reg [11:0] y_sum2;
reg [11:0] cb_sum2;
reg [11:0] cr_sum2;

reg [9:0]  y_d1n; 
reg [9:0]  cb_d1n; 
reg [9:0]  cr_d1n;

reg [11:0] y_dly;   
reg [11:0] cb_dly;
reg [11:0] cr_dly;

reg [9:0]  cout;
reg [9:0]  yout;

always @ (posedge clk or posedge rst)
begin
  if (rst) begin
    // rst statements
    y_d1n   <= Y_BLANKING_DATA;
    cb_d1n  <= C_BLANKING_DATA;
    cr_d1n  <= C_BLANKING_DATA;
	 
    y_sum2  <= 12'd0;
    cb_sum2 <= 12'd0;
    cr_sum2 <= 12'd0;
	 
    y_dly   <= {2'b00, Y_BLANKING_DATA};     
    cb_dly  <= {2'b00, C_BLANKING_DATA};
    cr_dly  <= {2'b00, C_BLANKING_DATA}; 
	 
    yout    <= Y_BLANKING_DATA;
    cout    <= C_BLANKING_DATA;
  end 
  else if (req) begin
     y_d1n  <= y_bar;
     y_sum2 <= ((10'd2)*y_bar + y_d1n);
     y_dly  <= ({2'b00, y_bar} + y_sum2) / (12'd4);
     yout   <= y_dly[9:0];
     
     if (wn[0]) begin  
       cb_d1n  <= cb_bar;
       cb_sum2 <= ((10'd2)*cb_bar + cb_d1n);      
       cb_dly  <= ({2'b00, cb_bar} + cb_sum2)/(12'd4);
       cout    <= cb_dly[9:0];
     end
     else begin
       cr_d1n  <= cr_bar;
       cr_sum2 <= ((10'd2)*cr_bar + cr_d1n);
       cr_dly  <= ({2'b00, cr_bar} + cr_sum2)/(12'd4);            
       cout    <= cr_dly[9:0]; 
     end // else: !if(wn[0])
   end // if (req)
end // always @ (posedge clk or posedge rst)
   
   

   
endmodule
