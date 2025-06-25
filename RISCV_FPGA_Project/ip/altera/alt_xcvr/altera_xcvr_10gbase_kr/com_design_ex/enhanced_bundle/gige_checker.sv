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


//============================================================================
// This confidential and proprietary software may be used only as authorized
// by a licensing agreement from ALTERA 
// copyright notice must be reproduced on all authorized copies.
//============================================================================
//
// Description :  This generates GMII test data - once start pulse is
// received. the sequence is - 7 PREAMBLE/SFD/DATA/IPG
// this keeps going on unless start is de-asserted
//****************************************************************************
//****************************************************************************

`timescale 1ps/1ps
module gige_pattern_chk #(
parameter PREAMBLE_VAL = 8'h55,
parameter SFD_VAL      = 8'hD5,
parameter PREAMBLE_REPEAT = 7,
parameter DATA_BYTES   = 256 ,
parameter IPG_BYTES   = 16 ,
parameter PACKETS   = 16  /// from 1 to 256
) ( 
input wire gmii_rx_clk,
input wire phy_mgmt_clk_reset,
input wire gmii_start,
input  wire [7:0] gmii_rx_d,
input  wire       gmii_rx_dv,
output reg        packet_complete, 
output reg        rx_mismatch 
);

localparam IDLE     =  6'b00_0001;
localparam PREAMBLE =  6'b00_0010;
localparam SFD      =  6'b00_0100;
localparam DATA     =  6'b00_1000;
localparam IPG      =  6'b01_0000;
localparam DONE     =  6'b10_0000;

reg [5:0] current_state, next_state;

reg preamble_cnt_rst,data_cnt_rst,ipg_cnt_rst,preamble_cnt_en,data_cnt_en,ipg_cnt_en,packet_cnt_en,packet_cnt_rst;

reg [5 :0] preamble_cnt ;
reg [12:0] data_cnt ;
reg [7 :0] ipg_cnt ;
reg [7:0] packet_cnt ;

always_ff @ (posedge gmii_rx_clk or posedge phy_mgmt_clk_reset)
begin
if (phy_mgmt_clk_reset)
current_state <= IDLE ;
else
current_state <= next_state; 
end


always_comb 
begin
next_state = IDLE ;

case (current_state)
IDLE     : if ((gmii_start==1) && (gmii_rx_d== PREAMBLE_VAL) && (gmii_rx_dv==1)) next_state = PREAMBLE ; else next_state = IDLE ;
PREAMBLE : if ((gmii_rx_d== PREAMBLE_VAL) && (gmii_rx_dv==1))  next_state = SFD ; 
           else next_state = IDLE ;
SFD      : if ((gmii_rx_d== SFD_VAL) && (gmii_rx_dv==1))next_state = DATA ; 
           else if ((gmii_rx_d== PREAMBLE_VAL) && (gmii_rx_dv==1))next_state = SFD ; else next_state = IDLE ;
DATA     : if (data_cnt== DATA_BYTES-1) next_state = IPG ; else next_state = DATA ;
IPG      : if (packet_cnt==PACKETS) next_state = DONE ;
           else if (gmii_rx_d== 8'h00)  next_state = IPG ;
           else if ((gmii_rx_d== PREAMBLE_VAL) && (gmii_rx_dv==1)) next_state = PREAMBLE ; 
           else next_state = IDLE ;
DONE     : next_state = IDLE ;
default  : next_state = IDLE ; 
endcase
end

always_comb 
begin
preamble_cnt_rst=0;
data_cnt_rst=0;
ipg_cnt_rst=0;
preamble_cnt_en =0;
data_cnt_en=0;
ipg_cnt_en=0;
packet_cnt_en=0;
packet_cnt_rst=0;
case (current_state)
IDLE     : begin preamble_cnt_rst=1; data_cnt_rst=1;ipg_cnt_rst=1;packet_cnt_rst=1; end
PREAMBLE : begin preamble_cnt_en =1; packet_cnt_en=1; end
SFD      : begin preamble_cnt_rst=1; data_cnt_rst=1; ipg_cnt_rst=1; end
DATA     : data_cnt_en=1;
IPG      : ipg_cnt_en=1;
DONE     : begin preamble_cnt_rst=1; data_cnt_rst=1;ipg_cnt_rst=1; end
default  : begin
           preamble_cnt_rst=0;
           data_cnt_rst=0;
           ipg_cnt_rst=0;
           preamble_cnt_en =0;
           data_cnt_en=0;
           ipg_cnt_en=0;
           packet_cnt_en=0;
           packet_cnt_rst=0;
           end
endcase             
end

always_ff @ (posedge gmii_rx_clk or posedge phy_mgmt_clk_reset)
begin
if (phy_mgmt_clk_reset)
packet_complete <= 0 ;
else if (current_state==DONE)
packet_complete <= 1 ;
end

always_ff @ (posedge gmii_rx_clk or posedge phy_mgmt_clk_reset)
begin
if (phy_mgmt_clk_reset)
preamble_cnt <= 0 ;
else if (preamble_cnt_rst)
preamble_cnt <= 0 ;
else if (preamble_cnt_en)
preamble_cnt <= preamble_cnt+1;
end

always_ff @ (posedge gmii_rx_clk or posedge phy_mgmt_clk_reset)
begin
if (phy_mgmt_clk_reset)
data_cnt <= 0 ;
else if (data_cnt_rst)
data_cnt <= 0 ;
else if (data_cnt_en)
data_cnt <= data_cnt+1;
end

always_ff @ (posedge gmii_rx_clk or posedge phy_mgmt_clk_reset)
begin
if (phy_mgmt_clk_reset)
ipg_cnt <= 0 ;
else if (ipg_cnt_rst)
ipg_cnt <= 0 ;
else if (ipg_cnt_en)
ipg_cnt <= ipg_cnt+1;
end

always_ff @ (posedge gmii_rx_clk or posedge phy_mgmt_clk_reset)
begin
if (phy_mgmt_clk_reset)
packet_cnt<= 0 ;
else if (packet_cnt_rst)
packet_cnt<= 0 ;
else if (packet_cnt_en)
packet_cnt<= packet_cnt+1;
end
/// RX DATA CHECK
//
assign rx_mismatch_pulse = ((gmii_rx_d!=data_cnt) && (!gmii_rx_dv) && (current_state==DATA)) ? 1'b1 : 1'b0 ;

always_ff @ (posedge gmii_rx_clk or posedge phy_mgmt_clk_reset)
begin
if (phy_mgmt_clk_reset)
rx_mismatch <= 0 ;
else if ((current_state==DATA) && rx_mismatch_pulse )
rx_mismatch <= 1'b1 ;
end


endmodule
