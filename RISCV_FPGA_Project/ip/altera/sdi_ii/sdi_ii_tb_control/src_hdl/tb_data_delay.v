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

module tb_data_delay (
   // port list
   clk,
   rst,
   dly_cycle,
   data_in,
   data_in_b,
   dvalid_in,
   dvalid_in_b,
   trs_in,
   trs_in_b,
   data_out,
   data_out_b,
   dvalid_out,
   dvalid_out_b,
   trs_out,
   trs_out_b
);

   //--------------------------------------------------------------------------
   // port declaration
   //--------------------------------------------------------------------------
   input             clk            ;
   input             rst            ;
   input     [1:0]   dly_cycle      ; // 1 = 13.47 ns; 2 = 26.9 ns; 3 = 40.4 ns
   input    [19:0]   data_in        ;
   input    [19:0]   data_in_b      ;
   input             dvalid_in      ;
   input             dvalid_in_b    ;
   input             trs_in         ;
   input             trs_in_b       ;
   output   [19:0]   data_out       ;
   output   [19:0]   data_out_b     ;
   output            dvalid_out     ;
   output            dvalid_out_b   ;
   output            trs_out        ;
   output            trs_out_b      ;

   //--------------------------------------------------------------------------
   // Delay Block
   //--------------------------------------------------------------------------
   reg   [19:0]   data_out, dataout_dly, dataout_dly1        ;
   reg   [19:0]   data_out_b, dataout_b_dly, dataout_b_dly1  ;
   reg            dvalid_dly                                 ;
   reg            dvalid_b_dly                               ;
   reg            trs_out, trs_dly, trs_dly1                 ;
   reg            trs_out_b, trs_b_dly, trs_b_dly1           ;
   wire           dvalid_out, dvalid_out_b                   ;

   always @ (posedge clk or posedge rst)
   begin
      if (rst) begin
         data_out <= 20'd0;
         dataout_dly <= 20'd0;
         dataout_dly1 <= 20'd0;
         trs_out <= 1'b0;
         trs_dly <= 1'b0;
         trs_dly1 <= 1'b0;
         dvalid_dly <= 1'b0;
      end
      else if (dvalid_in) begin
         dataout_dly <= data_in;
         dataout_dly1 <= dataout_dly;  
         trs_dly <= trs_in;
         trs_dly1 <= trs_dly;
         dvalid_dly <= dvalid_in;

         case (dly_cycle)
            3'd1 : begin
               data_out <= data_in;
               trs_out <= trs_in;
            end

            3'd2 : begin
               data_out <= dataout_dly;
               trs_out <= trs_dly;
            end

            3'd3 : begin
               data_out <= dataout_dly1;
               trs_out <= trs_dly1;
            end
         endcase 
      end else begin
         dvalid_dly <= dvalid_in;
      end
   end   

   always @ (posedge clk or posedge rst)
   begin
      if (rst) begin
         data_out_b <= 20'd0;
         dataout_b_dly <= 20'd0;
         dataout_b_dly1 <= 20'd0;
         trs_out_b <= 1'b0;
         trs_b_dly <= 1'b0;
         trs_b_dly1 <= 1'b0;
         dvalid_b_dly <= 1'b0;
      end
      else if (dvalid_in_b) begin
         dataout_b_dly <= data_in_b;
         dataout_b_dly1 <= dataout_b_dly;  
         trs_b_dly <= trs_in_b;
         trs_b_dly1 <= trs_b_dly;
         dvalid_b_dly <= dvalid_in_b;

         case (dly_cycle)
            3'd1 : begin
               data_out_b <= data_in_b;
               trs_out_b <= trs_in_b;
            end

            3'd2 : begin
               data_out_b <= dataout_b_dly;
               trs_out_b <= trs_b_dly;
            end

            3'd3 : begin
               data_out_b <= dataout_b_dly1;
               trs_out_b <= trs_b_dly1;
            end
         endcase 
      end else begin
          dvalid_b_dly <= dvalid_in_b;
      end
   end
    
   assign dvalid_out = dvalid_dly;
   assign dvalid_out_b = dvalid_b_dly;
    
endmodule
