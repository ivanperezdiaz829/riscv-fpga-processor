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
// File          : $RCSfile: auk_ts_packet_gen.v,v $
// Last modified : $Date: 2013/08/11 $
// Author        : JT
//--------------------------------------------------------------------------------------------------
//
// Transport stream packet generator.
//
//--------------------------------------------------------------------------------------------------

module auk_ts_packet_gen (
  clk,
  rst,
  enable,
  id,
  len_188_204n,
  gap,
  ts_data,
  ts_valid,
  ts_start,
  ts_end
  );

input         clk;
input         rst;
input         enable;
input   [7:0] id;
input         len_188_204n;
input  [15:0] gap;
output  [7:0] ts_data;
output        ts_valid;
output        ts_start;
output        ts_end;

reg enable_d;
reg enable_s;
always @ (posedge clk or posedge rst)
begin
  if (rst) begin
    enable_d <= 1'b0;
    enable_s <= 1'b0;
  end
  else begin
    enable_d <= enable;
    enable_s <= enable_d;
  end
end

reg  [7:0] ts_data;
reg        ts_valid;
reg        ts_start;
reg        ts_end;
reg [15:0] gap_count;
reg  [9:0] tx_count;
reg [31:0] tx_packet_count;

always @ (posedge clk or posedge rst)
begin
  if (rst) begin
    gap_count <= 0;
    tx_count <= 0;
    tx_packet_count <= 0;

  end
  else if (enable_s) begin
    // End of packet, start interpacket gap
    if ((~len_188_204n & tx_count==204) | (len_188_204n & tx_count==188)) begin
      tx_count  <= 0;
      gap_count <= gap;
    end
    // Count through bytes of packet
    else if (tx_count>0) begin
      tx_count <= tx_count + 1;
    end
    // End of interpacket gap so start new packet
    else if (gap_count==0) begin
      tx_count <= 1;
      tx_packet_count <= tx_packet_count + 1;
    end
    // Count through interpacket gap
    else begin
      gap_count <= gap_count - 1;
    end
  end
end

//--------------------------------------------------------------------------------------------------
// Generated packet content. Packet starts with NULL 47 1F FF 10 header, then byte indicating
// channel id, then 4 bytes for the packet count. Rest of packet is filled with values from an
// incrementing counter.
//--------------------------------------------------------------------------------------------------
reg [7:0] count;
always @ (posedge clk or posedge rst)
begin
  if (rst) begin
    ts_data  <= 8'b0;
    ts_valid <= 1'b0;
    ts_start <= 1'b0;
    ts_end   <= 1'b0;
    count    <= 0;
  end
  else begin
    ts_valid <= (tx_count>0);
    ts_start <= (tx_count==1);
    ts_end   <= (~len_188_204n & tx_count==204) | (len_188_204n & tx_count==188);
    case (tx_count)
      10'd0 : begin
            ts_data <= 8'h00;
            count   <= 0;
          end
      10'd1 : ts_data <= 8'h47;
      10'd2 : ts_data <= 8'h1F;
      10'd3 : ts_data <= 8'hFF;
      10'd4 : ts_data <= 8'h10;
      10'd5 : ts_data <= id;
      10'd6 : ts_data <= tx_packet_count[7:0];
      10'd7 : ts_data <= tx_packet_count[15:8];
      10'd8 : ts_data <= tx_packet_count[23:16];
      10'd9 : ts_data <= tx_packet_count[31:24];
      default : begin
                  ts_data <= count;
                  count   <= count + 1;
                end
    endcase
  end
end



endmodule
