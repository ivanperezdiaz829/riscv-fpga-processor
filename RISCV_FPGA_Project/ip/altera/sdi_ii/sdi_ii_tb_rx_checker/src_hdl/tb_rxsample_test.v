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



`timescale 100 fs / 100 fs

module tb_rxsample_test (
  input  rx_clk,
  input  rst,
  input  enable,
  input  trs_locked,
  input  rxdata_valid,
  input  rx_eav,
  output reg rxsample_chk_error,
  output reg rxsample_chk_done
);

parameter [4:0] VALID_ERR_TO_CHECK = 5'd6;
parameter [4:0] EAV_TIMEOUT_COUNT = 5'd30;

reg  [4:0] cnt_valid;
reg  [4:0] prev_cnt;
reg        error_valid;
wire [4:0] expect_next_cnt = (prev_cnt == 5) ? 4 : 5;  

always @ (posedge rst or posedge rx_clk)
begin
   if (rst) begin
     cnt_valid <= 5'd0;
     error_valid <= 1'b0;
     prev_cnt <= 5'd0;
   end else if (enable) begin
      if (rxdata_valid) begin
         cnt_valid <= 5'd0;
         prev_cnt  <= cnt_valid;

         if (trs_locked && (prev_cnt == cnt_valid)) begin
           error_valid <= 1'b1;
           $display("Off-Key rx_dataout_valid signal detected --Expecting 1H%dL, but 1H%dL is detected!",expect_next_cnt,cnt_valid);
         end
      end else begin
         cnt_valid <= cnt_valid + 1;
      end
   end
end
   
reg [4:0] rx_eav_cnt;
reg [4:0] valid_err_cnt;
always @ (posedge rst or posedge rx_clk)
begin
   if (rst) begin
      rx_eav_cnt <= 5'd0;
      valid_err_cnt <= 5'd0;
   end else if (enable) begin
      if (rx_eav) begin
         rx_eav_cnt <= rx_eav_cnt + 1'b1;

         if (error_valid) begin
            valid_err_cnt <= valid_err_cnt + 1'b1;
         end
      end
   end
end

always @ (posedge rst or posedge rx_eav)
begin
   if (rst) begin
      rxsample_chk_error <= 1'b1;
      rxsample_chk_done <= 1'b0;
   end else if (enable) begin
      if (valid_err_cnt == VALID_ERR_TO_CHECK) begin
         rxsample_chk_done <= 1'b1;

         if (trs_locked) begin
            rxsample_chk_error <= 1'b0;
            $display("Trs_locked remains asserted after 5 lines...");
         end
      end else if (rx_eav_cnt == EAV_TIMEOUT_COUNT) begin
         rxsample_chk_done <= 1'b1;
         $display("Rx sample test Timeout.");
      end
   end
end
   
endmodule
