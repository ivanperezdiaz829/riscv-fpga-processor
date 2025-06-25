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



`timescale 1ps/1ps


module em_count_fsm (
  ctl_reset_n,  
  av_clk,       

  av_burstcount,
  av_beginbursttransfer,
  av_write,
  av_read,
  av_readvalid,
  av_waitrequest,

  transfer_count, 
  write_count, 
  read_count,
  NTC_wait_count, 
  NTC_noreaddv_count, 
  NTC_masterwridle_count,
  NTC_masteridle_count
);

parameter EMPC_AV_BURSTCOUNT_WIDTH = 4;

input  ctl_reset_n;
input  av_clk;
input  [EMPC_AV_BURSTCOUNT_WIDTH-1:0] av_burstcount;
input  av_beginbursttransfer;
input  av_write;
input  av_read;
input  av_readvalid;
input  av_waitrequest;

output transfer_count; 
output write_count; 
output read_count; 
output NTC_wait_count; 
output NTC_noreaddv_count; 
output NTC_masterwridle_count; 
output NTC_masteridle_count; 

wire av_clk;
wire [EMPC_AV_BURSTCOUNT_WIDTH-1:0] av_burstcount;
wire av_beginbursttransfer;
wire av_write;
wire av_read;
wire av_readvalid;
wire av_waitrequest;

reg  transfer_count; 
reg  write_count; 
reg  read_count; 
reg  NTC_wait_count; 
reg  NTC_noreaddv_count; 
reg  NTC_masterwridle_count; 
reg  NTC_masteridle_count; 

reg  [EMPC_AV_BURSTCOUNT_WIDTH-1:0]  wrburst_counter;
reg                          [25:0]  rdburst_counter;

always @(posedge av_clk or negedge ctl_reset_n)
begin
  if (~ctl_reset_n) 
  begin
    transfer_count <= 1'b0; 
    write_count <= 1'b0; 
    read_count <= 1'b0; 
    NTC_wait_count <= 1'b0; 
    NTC_noreaddv_count <= 1'b0; 
    NTC_masterwridle_count <= 1'b0;
    NTC_masteridle_count <= 1'b0;
    wrburst_counter <= 0;
    rdburst_counter <= 0;
  end else begin
    if ((av_write & ~av_waitrequest) | av_readvalid) begin
      transfer_count <= 1'b1;
    end else begin
      transfer_count <= 0;
    end

    if (av_read & ~av_write) begin
      read_count <= ~av_waitrequest;
    end else begin
      read_count <= 0;
    end

    if (av_write & ~av_read) begin
      write_count <= ~av_waitrequest;
    end else begin
      write_count <= 0;
    end

    NTC_wait_count <= ((av_read | av_write) & av_waitrequest) ? 1'b1 : 1'b0;  

    if (av_read == 1'b1 & av_waitrequest == 1'b0 & av_readvalid == 1'b0) begin  
      rdburst_counter <= rdburst_counter + av_burstcount;
    end else if (av_read == 1'b1 & av_waitrequest == 1'b0 & av_readvalid == 1'b1) begin  
      rdburst_counter <= rdburst_counter + av_burstcount - 1'b1;
    end else if (av_readvalid == 1'b1) begin  
      rdburst_counter <= rdburst_counter - 1'b1;
    end else begin
      rdburst_counter <= rdburst_counter;
    end

    if (av_readvalid == 1'b0 & rdburst_counter > 0) begin  
      NTC_noreaddv_count <= 1'b1;
    end else begin
      NTC_noreaddv_count <= 1'b0;
    end	

    if (av_write == 1'b1 & av_beginbursttransfer == 1'b1 & av_burstcount > 0) begin  

      if (av_waitrequest) begin
        wrburst_counter <= av_burstcount;
      end else begin
        wrburst_counter <= av_burstcount - 1'b1;
      end

      NTC_masterwridle_count <= 1'b0;
    end else if (av_write == 1'b1 & av_waitrequest == 1'b0 & wrburst_counter > 0) begin  
      wrburst_counter <= wrburst_counter - 1'b1;
      NTC_masterwridle_count <= 1'b0;
    end else if (av_write == 1'b0 & wrburst_counter > 0) begin  
      wrburst_counter <= wrburst_counter;
      NTC_masterwridle_count <= 1'b1;
    end else begin
      wrburst_counter <= wrburst_counter; 
      NTC_masterwridle_count <= 1'b0;
    end

    if (~av_read & ~av_write) begin
      NTC_masteridle_count <= 1'b1;
    end else begin
      NTC_masteridle_count <= 1'b0;
    end

  end
end  

endmodule

