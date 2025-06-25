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


module em_protocol_fsm (
  ctl_reset_n,  
  av_clk,       
  av_rst_n,     

  av_burstcount,
  av_beginbursttransfer,
  av_write,
  av_read,
  av_readvalid,
  av_waitrequest,

  av_address,
  av_byteenable,
  av_writedata,

  illegal_cmd_reg_rst,  

  illegal_cmd_reg
);

parameter EMPC_AV_BURSTCOUNT_WIDTH = 4;
parameter EMPC_AV_DATA_WIDTH = 64;
parameter EMPC_AV_ADDRESS_WIDTH = 10;
parameter EMPC_AV_BE_WIDTH = 8;

input                                   ctl_reset_n;
input                                   av_clk;
input                                   av_rst_n;
input   [EMPC_AV_BURSTCOUNT_WIDTH-1:0]  av_burstcount;
input                                   av_beginbursttransfer;
input                                   av_write;
input                                   av_read;
input                                   av_readvalid;
input                                   av_waitrequest;
input      [EMPC_AV_ADDRESS_WIDTH-1:0]  av_address;
input           [EMPC_AV_BE_WIDTH-1:0]  av_byteenable;
input         [EMPC_AV_DATA_WIDTH-1:0]  av_writedata;
input                                   illegal_cmd_reg_rst;
output                           [7:0]  illegal_cmd_reg; 

wire                                  av_clk;
wire                                  av_rst_n;
wire  [EMPC_AV_BURSTCOUNT_WIDTH-1:0]  av_burstcount;
wire                                  av_beginbursttransfer;
wire                                  av_write;
wire                                  av_read;
wire                                  av_readvalid;
wire                                  av_waitrequest;

reg                            [7:0]  illegal_cmd_reg;
reg                                   cmd_wait_reg;
reg   [EMPC_AV_BURSTCOUNT_WIDTH-1:0]  av_burstcount_r;
reg      [EMPC_AV_ADDRESS_WIDTH-1:0]  av_address_r;
reg           [EMPC_AV_BE_WIDTH-1:0]  av_byteenable_r;
reg         [EMPC_AV_DATA_WIDTH-1:0]  av_writedata_r;
reg                                   av_beginbursttransfer_r;
reg                                   av_write_r;
reg                                   av_read_r;

reg   [EMPC_AV_BURSTCOUNT_WIDTH-1:0]  wrburst_counter;

localparam PERR_CMD_DURING_RST = 0;
localparam PERR_SIMULT_RD_WR = 1;
localparam PERR_BEGINBURSTTRANSFER_TOO_LONG = 2;
localparam PERR_MULT_BEGINBURSTTRANSFER_WAITRQ = 3;
localparam PERR_BEGINBURSTTRANSFER_NO_CMD = 4;
localparam PERR_INCORRECT_NUM_WRBURST_DATA = 5;
localparam PERR_CMD_CHANGE_WAITRQ = 6;
localparam PERR_BURSTCNT_CHANGE_WRBURST = 7;


always @(posedge av_clk or negedge ctl_reset_n) begin
  if (~ctl_reset_n) begin
    av_burstcount_r <= 0;
    av_beginbursttransfer_r <= 0;
    av_write_r <= 0;
    av_read_r <= 0;
    av_address_r <= 0;
    av_byteenable_r <= 0;
    av_writedata_r <= 0;
  end else begin
    av_burstcount_r <= av_burstcount;
    av_beginbursttransfer_r <= av_beginbursttransfer;
    av_write_r <= av_write;
    av_read_r <= av_read;
    av_address_r <= av_address;
    av_byteenable_r <= av_byteenable;
    av_writedata_r <= av_writedata;
  end
end


always @(posedge av_clk or negedge ctl_reset_n) begin
  if (~ctl_reset_n) begin
    wrburst_counter <= 0;
    cmd_wait_reg <= 1'b0;
  end else begin
    if (av_write == 1'b1 & av_beginbursttransfer == 1'b1 & av_burstcount > 0) begin  
      wrburst_counter <= av_burstcount - (!av_waitrequest);
    end else if (av_write == 1'b1 & av_waitrequest == 1'b0 & av_burstcount > 0) begin  
      wrburst_counter <= wrburst_counter - 1'b1;
    end else begin
      wrburst_counter <= wrburst_counter;
    end

    cmd_wait_reg <= (av_waitrequest & av_beginbursttransfer) ? 1'b1 : 1'b0; 

    if (av_waitrequest) begin
      cmd_wait_reg <= (cmd_wait_reg | av_beginbursttransfer);
    end else begin
      cmd_wait_reg <= 1'b0;
    end
  end
end


always @(posedge av_clk or negedge ctl_reset_n) begin
  if (~ctl_reset_n) begin
    illegal_cmd_reg <= 8'b0;
  end else begin
    if (illegal_cmd_reg_rst) begin
      illegal_cmd_reg <= 8'b0;
    end else begin
      if ( (~av_rst_n & (av_read | av_write)) ) begin
        illegal_cmd_reg[PERR_CMD_DURING_RST] <= 1'b1;
      end

      if ( (av_read & av_write) ) begin
        illegal_cmd_reg[PERR_SIMULT_RD_WR] <= 1'b1;
      end

      if ( (av_write_r & av_beginbursttransfer_r & (av_burstcount_r > 1) & av_beginbursttransfer) ) begin
        illegal_cmd_reg[PERR_BEGINBURSTTRANSFER_TOO_LONG] <= 1'b1;
      end

      if ( (cmd_wait_reg & av_beginbursttransfer) ) begin
        illegal_cmd_reg[PERR_MULT_BEGINBURSTTRANSFER_WAITRQ] <= 1'b1;
      end

      if ( (av_beginbursttransfer & (~av_read & ~av_write)) ) begin
        illegal_cmd_reg[PERR_BEGINBURSTTRANSFER_NO_CMD] <= 1'b1;
      end

      if ( (av_beginbursttransfer & (wrburst_counter > 0)) ) begin
        illegal_cmd_reg[PERR_INCORRECT_NUM_WRBURST_DATA] <= 1'b1;
      end

      if ( (cmd_wait_reg & ((av_write != av_write_r) |
                            (av_read != av_read_r) |
                            (av_writedata != av_writedata_r) |
                            (av_address != av_address_r) |
                            (av_byteenable != av_byteenable_r) |
                            (av_burstcount != av_burstcount_r))) ) begin
        illegal_cmd_reg[PERR_CMD_CHANGE_WAITRQ] <= 1'b1;
      end

		/*Case:48052 Ignore this check because it is only valid if constantBurstBehavior is
			set on the interface.  The controller has this parameter set to FALSE.
		if ( ((av_burstcount != av_burstcount_r) & (wrburst_counter > 0)) ) begin
        	illegal_cmd_reg[PERR_BURSTCNT_CHANGE_WRBURST] <= 1'b1;
      	end*/

    end
  end
end

endmodule


