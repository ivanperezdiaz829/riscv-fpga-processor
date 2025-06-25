//--------------------------------------------------------------------------------------------------
// (c)2004 Altera Corporation. All rights reserved.
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
// File          : $RCSfile: asi_buffer.v,v $
// Last modified : $Date: 2013/08/11 $
// Export tag    : $Name:  $
//--------------------------------------------------------------------------------------------------

module asi_buffer (
  rx_clk,
  rx_rst,
  rx_lock,
  rx_dat,
  rx_ena,
  rx_sop,
  rx_eop,
  rx_err,

  pad_188,

  tx_clk,
  tx_lock,
  tx_dav,
  tx_dat,
  tx_ena,
  tx_sop,
  tx_eop
  );

input         rx_clk;
input         rx_rst;
input   [1:0] rx_lock;
input   [7:0] rx_dat;
input         rx_ena;
input         rx_sop;
input         rx_eop;
input         rx_err;

input         pad_188;

input         tx_clk;
output  [1:0] tx_lock;
input         tx_dav;
output  [7:0] tx_dat;
output        tx_ena;
output        tx_sop;
output        tx_eop;

//--------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------
reg rx_bank;
reg [7:0] rx_addr;

always @ (posedge rx_clk or posedge rx_rst)
begin
  if (rx_rst) begin
    rx_bank <= 1'b0;
    rx_addr <= 8'd0;
  end
  else if (rx_ena & rx_lock!=2'b00) begin
    // Errored packets are discarded
    if (rx_err) begin
      rx_addr <= 8'd0;
    end
    // Switch to other bank at end of packet
    else if (rx_eop) begin
      rx_bank <= ~rx_bank;
      rx_addr <= 8'd0;
    end
    // Start storing when SOP seen
    else if (rx_sop) begin
      rx_addr <= rx_addr + 8'd1;
    end
    // Store subsequent data at incrementing location
    else if (rx_addr>0) begin
      rx_addr <= rx_addr + 8'd1;
    end
  end
end

//--------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------

reg [1:0] rx_lock_d;
reg rx_lock_tgl;
always @ (posedge rx_clk or posedge rx_rst)
begin
  if (rx_rst) begin
    rx_lock_d <= 2'b00;
    rx_lock_tgl <= 1'b0;
  end
  else begin
    rx_lock_d <= rx_lock;
    if (rx_lock_d!=rx_lock)
      rx_lock_tgl <= ~rx_lock_tgl;
  end
end

reg tx_rst_d;
reg tx_rst;
reg rx_bank_d;
reg rx_bank_s;
reg rx_lock_tgl_d;
reg rx_lock_tgl_s;
reg [1:0] rx_lock_s;
always @ (posedge tx_clk)
begin
  tx_rst_d <= rx_rst;
  tx_rst   <= tx_rst_d;
  rx_bank_d <= rx_bank;
  rx_bank_s <= rx_bank_d;
  rx_lock_tgl_d <= rx_lock_tgl;
  rx_lock_tgl_s <= rx_lock_tgl_d;
  if (rx_lock_tgl_s!=rx_lock_tgl_d)
    rx_lock_s <= rx_lock;
end

//--------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------
reg tx_bank;
reg [7:0] tx_addr;
reg tx_read;
reg [1:0] tx_lock;
reg [7:0] tx_dat;
reg tx_ena;
reg rd_sop;
reg tx_sop;
reg tx_eop;
wire rd_eop;
wire [7:0] rd_dat;
reg tx_dav_d;
reg [7:0] t_rd_dat;
reg t_rd_eop;
reg [7:0] rd_dat_store;
reg rd_eop_store;

always @ (posedge tx_clk or posedge tx_rst)
begin
  if (tx_rst) begin
    tx_bank <= 1'b0;
    tx_addr <= 8'd0;
    tx_read <= 1'b0;
    tx_ena  <= 1'b0;
    rd_sop  <= 1'b0;
    tx_sop  <= 1'b0;
    tx_eop  <= 1'b0;
    tx_dav_d <= 1'b0;
    rd_dat_store <= 8'b0;
    rd_eop_store <= 1'b0;
  end
  else begin
    tx_dav_d <= tx_dav;
    rd_sop  <= 1'b0;
    tx_sop  <= 1'b0;
    tx_eop  <= 1'b0;
    tx_ena  <= 1'b0;
    tx_sop  <= rd_sop;

    t_rd_eop = (tx_read & tx_dav & ~tx_dav_d) ? rd_eop_store : (~tx_read | ~tx_dav) ? 1'b0 : rd_eop;
    t_rd_dat = (tx_read & tx_dav & ~tx_dav_d) ? rd_dat_store : (~tx_read | ~tx_dav) ? 8'b0 : rd_dat;

    tx_dat  <= t_rd_dat;

    if (tx_dav) begin

      // Start when Rx switches bank
      if (tx_addr==8'd0 & tx_bank!=rx_bank_s & ~tx_eop) begin
        tx_addr <= tx_addr + 8'd1;
        tx_read <= 1'b1;
        rd_sop  <= 1'b1;
      end
      // Catch end of 188-byte packet when padding to 204-bytes
      else if (t_rd_eop & tx_addr==8'd188 & pad_188) begin
        tx_addr <= tx_addr + 8'd1;
        tx_read <= 1'b0;
        tx_ena  <= 1'b1;
      end
      // End of packet
      else if ((tx_read & t_rd_eop) | tx_addr==8'd204) begin
        tx_bank <= ~tx_bank;
        tx_addr <= 8'd0;
        tx_read <= 1'b0;
        tx_ena  <= 1'b1;
        tx_eop  <= 1'b1;
      end
      // Fetch from incrementing location
      else if (tx_addr>0) begin
        tx_addr <= tx_addr + 8'd1;
        tx_ena  <= 1'b1;
      end

    end

    if (tx_dav_d & ~tx_dav & tx_read) begin
      rd_dat_store <= rd_dat;
      rd_eop_store <= rd_eop;
    end

    if (tx_addr==8'b0)
      tx_lock <= rx_lock_s;

  end
end

//--------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------
/*
asi_buffer_ram u_ram (
  .wrclock      (rx_clk),
  .wr_aclr      (rx_rst),
  .wren         (rx_ena),
  .wraddress    ({rx_bank, rx_addr}),
  .data         ({rx_eop, rx_dat}),
  .rdclock      (tx_clk),
  .rd_aclr      (tx_rst),
  .rdaddress    ({tx_bank, tx_addr}),
  .q            ({rd_eop, rd_dat})
  );
*/

reg [8:0] addr_out_reg;
reg [8:0] q;
reg [8:0] mem [511:0];

always @(posedge rx_clk)
begin
  if (rx_ena)
    mem[{rx_bank, rx_addr}] <= {rx_eop, rx_dat};
end

always @(posedge tx_clk)
begin
  q <= mem[addr_out_reg];
  addr_out_reg <= {tx_bank, tx_addr};
end

assign {rd_eop, rd_dat} = mem[addr_out_reg];


endmodule
