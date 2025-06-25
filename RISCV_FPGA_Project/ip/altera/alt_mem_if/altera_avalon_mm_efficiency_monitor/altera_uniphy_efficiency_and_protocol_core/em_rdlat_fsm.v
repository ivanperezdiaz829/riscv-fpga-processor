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


module em_rdlat_fsm (
  ctl_reset_n,  
  clr,          
  enable,
  av_clk,       

  av_burstcount,

  av_read,
  av_readvalid,
  av_waitrequest,
  cycle_count,
  rdlat_total,
  rdlat_min,
  rdlat_max
);

parameter EMPC_AV_BURSTCOUNT_WIDTH = 8;
parameter EMPC_COUNT_WIDTH = 32;

input                                  ctl_reset_n;
input                                  clr;  
input                                  enable;
input                                  av_clk;
input  [EMPC_AV_BURSTCOUNT_WIDTH-1:0]  av_burstcount;
input                                  av_read;
input                                  av_readvalid;
input                                  av_waitrequest;
input          [EMPC_COUNT_WIDTH-1:0]  cycle_count;

output reg [(EMPC_COUNT_WIDTH*2)-1:0]  rdlat_total;
output reg     [EMPC_COUNT_WIDTH-1:0]  rdlat_min;
output reg     [EMPC_COUNT_WIDTH-1:0]  rdlat_max;


reg                           rdlat_ena_1q;
reg   [EMPC_COUNT_WIDTH-1:0]  rdlat_1q;
reg                           rdlat_ena_2q;
reg   [EMPC_COUNT_WIDTH-1:0]  rdlat_2q;
reg                           rdlat_lt_min;
reg                           rdlat_gt_max;

reg   [EMPC_AV_BURSTCOUNT_WIDTH-1:0] rdburst_counter;
reg   fifo_rd;
wire  fifo_wr;
wire  [EMPC_AV_BURSTCOUNT_WIDTH+EMPC_COUNT_WIDTH-1:0] fifo_wdata, fifo_rdata;
reg   burst_of_one;

assign fifo_wr    = ((av_read & ~av_waitrequest) ? 1'b1 : 1'b0);
assign fifo_wdata = {av_burstcount, cycle_count};

always @(posedge av_clk or negedge ctl_reset_n) begin
  if (~ctl_reset_n)  
  begin
    fifo_rd <= 1'b0; 
    rdburst_counter <= 0;
  end else begin
    if (av_readvalid & (rdburst_counter != 0)) begin  
      fifo_rd <= 1'b0;
      rdburst_counter <= rdburst_counter - 1'b1;
    end else if (av_readvalid & (rdburst_counter == 0)) begin  
      if (burst_of_one) begin
        fifo_rd <= 1'b0;
      end else begin
        fifo_rd <= 1'b1;
      end

      if (burst_of_one) begin
        rdburst_counter <= fifo_rdata[(EMPC_AV_BURSTCOUNT_WIDTH+EMPC_COUNT_WIDTH-1):EMPC_COUNT_WIDTH] - 2;
      end else begin
        rdburst_counter <= fifo_rdata[(EMPC_AV_BURSTCOUNT_WIDTH+EMPC_COUNT_WIDTH-1):EMPC_COUNT_WIDTH] - 1'b1;
      end

    end else begin
      fifo_rd <= 1'b0;
      rdburst_counter <= rdburst_counter;
    end
  end
end  


always @(posedge av_clk or negedge ctl_reset_n) begin
  if (~ctl_reset_n) begin
    burst_of_one <= 0;
  end else begin
    if (av_readvalid & fifo_rd & (fifo_rdata[(EMPC_AV_BURSTCOUNT_WIDTH+EMPC_COUNT_WIDTH-1):EMPC_COUNT_WIDTH]) < 2) begin
      burst_of_one <= 1'b1;
    end else begin
      burst_of_one <= 1'b0;
    end
  end
end


always @(posedge av_clk or negedge ctl_reset_n) begin
  if (~ctl_reset_n) 
  begin
    rdlat_1q <= 0;
    rdlat_ena_1q <= 1'b0;
    rdlat_2q <= 0;
    rdlat_ena_2q <= 1'b0;
    rdlat_lt_min <= 1'b0;
    rdlat_gt_max <= 1'b0;
  end else begin
    rdlat_1q <= cycle_count - fifo_rdata[EMPC_COUNT_WIDTH-1:0] - 1'b1; 
    rdlat_ena_1q <= fifo_rd;

    if (rdlat_ena_1q & (rdlat_1q < rdlat_min)) begin
      rdlat_lt_min <= 1'b1;
    end else begin
      rdlat_lt_min <= 1'b0;
    end

    if (rdlat_ena_1q & (rdlat_1q > rdlat_max) & (rdlat_1q > rdlat_2q)) begin
      rdlat_gt_max <= 1'b1;
    end else begin
      rdlat_gt_max <= 1'b0;
    end

    rdlat_2q <= rdlat_1q;
    rdlat_ena_2q <= rdlat_ena_1q;
  end
end


always @(posedge av_clk or negedge ctl_reset_n) begin
  if (~ctl_reset_n) begin
    rdlat_min <= {EMPC_COUNT_WIDTH{1'b1}};
    rdlat_max <= {EMPC_COUNT_WIDTH{1'b0}};
    rdlat_total <= {(EMPC_COUNT_WIDTH*2){1'b0}};
  end else begin
    if (clr) begin
      rdlat_min <= {EMPC_COUNT_WIDTH{1'b1}};
      rdlat_max <= {EMPC_COUNT_WIDTH{1'b0}};
      rdlat_total <= {(EMPC_COUNT_WIDTH*2){1'b0}};
    end else if (enable) begin
      if (rdlat_ena_2q) begin
        if (rdlat_lt_min) begin
          rdlat_min <= rdlat_2q;
        end else begin
          rdlat_min <= rdlat_min;
        end

        if (rdlat_gt_max) begin
          rdlat_max <= rdlat_2q;
        end else begin
          rdlat_max <= rdlat_max;
        end

        rdlat_total <= rdlat_total + rdlat_2q;
      end
    end
  end
end


scfifo rdlat_scfifo (
  .rdreq        (fifo_rd),
  .sclr         (~ctl_reset_n),
  .clock        (av_clk),
  .wrreq        (fifo_wr),
  .data         (fifo_wdata),
  .q            (fifo_rdata),
  .full         ()
  // synopsys translate_off
                  ,
  .aclr         (),
  .almost_empty (),
  .almost_full  (),
  .empty        (),
  .usedw        ()
  // synopsys translate_on
);

defparam
  rdlat_scfifo.add_ram_output_register = "OFF",
  rdlat_scfifo.intended_device_family = "UNUSED",
  rdlat_scfifo.lpm_numwords = 48,  
  rdlat_scfifo.lpm_showahead = "ON", 
  rdlat_scfifo.lpm_type = "scfifo",
  rdlat_scfifo.lpm_width = (EMPC_AV_BURSTCOUNT_WIDTH+EMPC_COUNT_WIDTH),
  rdlat_scfifo.lpm_widthu = 6,
  rdlat_scfifo.overflow_checking = "OFF",
  rdlat_scfifo.underflow_checking = "OFF",
  rdlat_scfifo.use_eab = "OFF";


endmodule


