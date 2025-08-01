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
// File          : $RCSfile: auk_ts_packet_check.v,v $
// Last modified : $Date: 2013/08/11 $
// Author        : JT
//--------------------------------------------------------------------------------------------------
//
// Transport stream packet checker.
//
//--------------------------------------------------------------------------------------------------

module auk_ts_packet_check (
  clk,
  rst,
  ts_valid,
  ts_data,
  ts_start,
  ts_end,
  ts_lock,
  id,
  check_id,
  error
  );

input         clk;
input         rst;
input         ts_valid;
input   [7:0] ts_data;
input         ts_start;
input         ts_end;
input   [1:0] ts_lock;
input   [7:0] id;
input         check_id;
output        error;

reg format_error;
reg [7:0] count;
reg [7:0] ts_data_d;
reg ts_valid_d;

always @ (posedge clk or posedge rst)
begin
  if (rst) begin
    format_error <= 1'b0;
    count = 0;
    ts_data_d <= 8'h00;
    ts_valid_d <= 1'b0;
  end
  else begin
    format_error <= 1'b0;
    ts_valid_d <= ts_valid;
    ts_data_d <= ts_data;
    if (ts_valid) begin

      if (ts_start) begin
        format_error <= (count!=0);
        count <= 1;
      end
      else if (ts_end) begin
        format_error <= (ts_lock==2'b11 & count!=187) | (ts_lock==2'b01 & count!=203);
        count <= 0;
      end
      else begin
        if ((ts_lock==2'b11 & count==187) | (ts_lock==2'b01 & count==203)) begin
          format_error <= 1'b1;
          count <= 0;
        end
        else begin
          count <= count + 1;
        end
      end

    end
  end
end

reg data_error;
reg [23:0] packet_count;
reg [31:0] last_packet_count;
reg first_packet;
always @ (posedge clk or posedge rst)
begin
  if (rst) begin
    data_error <= 1'b0;
    first_packet <= 1'b1;
    packet_count <= 0;
    last_packet_count <= 0;
  end
  else begin
    data_error <= 1'b0;
    if (ts_valid_d) begin
    case (count)
      1 : data_error <= (ts_data_d!=8'h47);
      2 : data_error <= (ts_data_d!=8'h1F);
      3 : data_error <= (ts_data_d!=8'hFF);
      4 : data_error <= (ts_data_d!=8'h10);
      5 : data_error <= check_id & (ts_data_d!=id);
      6 : packet_count[7:0] <= ts_data_d;
      7 : packet_count[15:8] <= ts_data_d;
      8 : packet_count[23:16] <= ts_data_d;
      9 : begin
            data_error <= ~first_packet & ({ts_data_d, packet_count}!=last_packet_count+1);
            last_packet_count <= {ts_data_d, packet_count};
            first_packet <= 1'b0;
          end
      0 : data_error <= (ts_lock==2'b11 & ts_data_d!=178) | (ts_lock==2'b01 & ts_data_d!=194);
      default : data_error <= (ts_data_d!=count-10);
    endcase
    end
  end
end

assign error = data_error | format_error;

endmodule
