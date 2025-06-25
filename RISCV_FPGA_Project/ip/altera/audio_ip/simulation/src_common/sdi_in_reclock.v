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



`timescale 1 ps / 1 ps

module sdi_in_reclock (
  vid_in_clk,
  vid_in_en,
  vid_in_data,
  vid_out_clk,
  vid_out_en,
  vid_out_data);

  parameter G_DATA_WIDTH = 10;

  input vid_in_clk;
  input vid_in_en;
  input [G_DATA_WIDTH-1:0] vid_in_data;
  input vid_out_clk;
  output vid_out_en;
  reg vid_out_en;
  output [G_DATA_WIDTH-1:0] vid_out_data;
  reg [G_DATA_WIDTH-1:0] vid_out_data;

  reg [2:0] write_addr = "000";
  reg [G_DATA_WIDTH-1:0] sync_buffer [7:0];
  reg [2:0] write_addr_meta;
  reg [2:0] write_addr_sync;
  reg read_en;
  reg [2:0] read_addr = "100";
  reg [G_DATA_WIDTH-1:0] read_word;

  function [31:0] bin_2_gray;
    input [31:0] bin;
    input len;
    integer len;

    reg [31:0] gray;
    integer I;
  begin
    gray = {32{1'b0}};
    gray[len - 1] = bin[len - 1];
    for (I = (len - 2); I >= 0; I = I - 1) begin
      gray[I] = bin[I + 1] ^ bin[I];
    end
    bin_2_gray = (gray);
  end
  endfunction

  function [31:0] gray_2_bin;
    input [31:0] gray;
    input len;
    integer len;

    reg [31:0] bin;
    integer I;
  begin
    bin = {32{1'b0}};
    bin[len - 1] = gray[len - 1];
    for (I = (len - 2); I >= 0; I = I - 1) begin
      bin[I] = bin[I + 1] ^ gray[I];
    end
    gray_2_bin = (bin);
  end
  endfunction

//------------------------------------------------------------------------------
//MODULE BODY
//------------------------------------------------------------------------------

  //---------------------------------------------------------------------------
  // Use a small FIFO to pass data cleanly across the clock domains
  //---------------------------------------------------------------------------
  always @(posedge vid_in_clk)
  begin
    begin
      if (vid_in_en == 1'b1) begin
        write_addr <= bin_2_gray(gray_2_bin(write_addr,3) + 1,3);
      end

    end
  end

  always @(posedge vid_in_clk)
  begin
    begin
      if (vid_in_en == 1'b1) begin
        sync_buffer[write_addr] <= vid_in_data;
      end

    end
  end

  //---------------------------------------------------------------------------
  // Read Side
  //---------------------------------------------------------------------------
  always @(posedge vid_out_clk)
  begin
    begin
      write_addr_meta <= write_addr;
      write_addr_sync <= write_addr_meta;

    end
  end

  always @(posedge vid_out_clk)
  begin
    begin
      if (read_addr != write_addr_sync) begin
        read_en <= 1'b1;
        read_addr <= bin_2_gray(gray_2_bin(read_addr,3) + 1,3);
      end else begin
        read_en <= 1'b0;
      end

    end
  end

  always @(posedge vid_out_clk)
  begin
    begin
      read_word <= sync_buffer[read_addr];

    end
  end

  always @(posedge vid_out_clk)
  begin
    begin
      vid_out_en <= read_en;
      if (read_en == 1'b1) begin
        vid_out_data <= read_word;
      end

    end
  end

endmodule
