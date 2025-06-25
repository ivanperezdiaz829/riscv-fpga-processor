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


module altera_pmon_count_csr (
   input             avs_clock,
   input             avs_reset,
   input             avs_read,
   input       [3:2] avs_address,
   output reg        avs_waitrequest,
   output reg [31:0] avs_readdata,
   output reg        toglout,
   output reg  [1:0] address,
   input             toglin,
   input      [31:0] count_data
   );
reg togl;
wire toglin_s;
reg  toglin_sa;

always @(posedge avs_clock or posedge avs_reset) begin
   if (avs_reset) begin
      toglout  <= 1'b0;
      address  <= 2'h0;
   end
   else begin
      if (togl) begin
         toglout <= !toglout;
         address <= avs_address;
      end
   end
end
altera_std_synchronizer #(
   .depth      (2)
   ) sync_toglin (
   .clk      (avs_clock),
   .reset_n  (~avs_reset),
   .din      (toglin),
   .dout     (toglin_s)
   );

localparam IDLE = 1'b0,
           RIP  = 1'b1;

reg state, nxstate;

always @(posedge avs_clock or posedge avs_reset) begin
   if (avs_reset) begin
      state           <= IDLE;
      avs_waitrequest <= 1'b1;
      toglin_sa       <= 1'b0;
   end 
   else begin
      state           <= nxstate;
      toglin_sa       <= toglin_s;
      if (toglin_s != toglin_sa) avs_waitrequest <= 1'b0;
      else avs_waitrequest <= 1'b1;
   end
end

always @(*) begin
   nxstate      = state;
   togl         = 1'b0;
   avs_readdata = 32'h0;
   case (state)
      IDLE: begin
         if (avs_read) begin
            nxstate = RIP;
            togl    = 1'b1;
         end
      end
      RIP: begin//read in progress
         avs_readdata = count_data;
         if (~avs_waitrequest) nxstate = IDLE;
      end
   endcase
end
         
endmodule

