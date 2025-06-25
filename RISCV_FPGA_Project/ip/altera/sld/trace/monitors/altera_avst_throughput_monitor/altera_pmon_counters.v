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


module altera_pmon_counters #(
   parameter 
   BC_W            = 5
   ) (
   input             if_clock,
   input             if_reset,
   input             if_read,
   input             if_write,
   input  [BC_W-1:0] if_burstcount,
   input             if_waitrequest,
   input             if_readdatavalid,

   input      [ 1:0] address,
   input             toglin,
   output reg        toglout,

   output reg [31:0] count_data
     );

reg  [31:0] read_xfrs;
reg  [31:0] read_cycles;
reg  [31:0] write_xfrs;
reg  [31:0] write_cycles;
reg  [31:0] selected_counter;
reg  [15:0] readcount;

wire        toglin_s;

altera_std_synchronizer #(
   .depth      (2)
   ) sync_toglin (
   .clk      (if_clock),
   .reset_n  (~if_reset),
   .din      (toglin),
   .dout     (toglin_s)
   );

always @(posedge if_clock or posedge if_reset) begin
   if (if_reset) begin
      toglout <= 0;
      count_data <= 32'h0;
   end
   else begin
      toglout <= toglin_s;
      if (toglout != toglin_s) count_data <= selected_counter;
   end
end

always @ (*) begin
   case (address)
      2'h0: selected_counter = read_xfrs;
      2'h1: selected_counter = read_cycles;
      2'h2: selected_counter = write_xfrs;
      2'h3: selected_counter = write_cycles;
   endcase
end

//read xfrs counter
always @(posedge if_clock or posedge if_reset) begin
   if (if_reset) read_xfrs <= 0;
   else if (if_readdatavalid) read_xfrs <= read_xfrs + 1'b1;
end

//readcount indicates how many readdatavalid cycles are to come
always @(posedge if_clock or posedge if_reset) begin
   if (if_reset) readcount <= 16'h0; //smaller???
   else if (if_read && ~if_waitrequest) begin
      if (if_readdatavalid) readcount <= readcount + if_burstcount - 1'b1;
      else                  readcount <= readcount + if_burstcount;
   end
   else if (if_readdatavalid) readcount <= readcount - 1'b1;
end

//read cycles counter
always @(posedge if_clock or posedge if_reset) begin
   if (if_reset) read_cycles <= 32'h0; 
   else if (if_read || (readcount > 16'h0)) read_cycles <= read_cycles + 1'b1;
end


//write xfrs counter
always @(posedge if_clock or posedge if_reset) begin
   if (if_reset) write_xfrs <= 0;
   else if (if_write && !if_waitrequest) write_xfrs <= write_xfrs + 1'b1;
end

//write burst state tracker
localparam WIDLE = 1'b0,
           WIP   = 1'b1;
reg        wstate, nx_wstate;
reg [10:0] wburstcnt;
reg        load, decr, write_in_progress;

always @(posedge if_clock or posedge if_reset) begin
   if (if_reset) begin
      wstate <= WIDLE;
      wburstcnt <= 11'h0;
   end
   else begin
      wstate <= nx_wstate;
      if (load) begin
         if (~if_waitrequest) wburstcnt <= if_burstcount - 1'b1;
         else                 wburstcnt <= if_burstcount;
      end
      else if (decr)          wburstcnt <= wburstcnt - 1'b1;
   end
end

wire newburst = (wburstcnt == 11'h0);

always @ (*) begin
   nx_wstate = wstate;
   decr      = 1'b0;
   load      = 1'b0;
   case (wstate)
   WIDLE: begin
      write_in_progress = 1'b0;
      if (if_write && newburst) begin
         load              = 1'b1;
         write_in_progress = 1'b1;
         if (if_waitrequest || (if_burstcount > {{BC_W-1{1'b0}}, 1'b1})) nx_wstate = WIP;
      end
   end
   WIP: begin //write in progress
      write_in_progress = 1'b1;
      if (if_write && ~if_waitrequest) begin //valid write cycle
         decr = 1'b1;
         if (wburstcnt == 11'h1) nx_wstate = WIDLE;
      end
   end
   endcase
end

//write cycles counter (cycles used in completing a write burst, from first
//write command, to last accepted write cycle of burst
always @(posedge if_clock or posedge if_reset) begin
   if (if_reset) write_cycles <= 32'h0;
   else if (write_in_progress) write_cycles <= write_cycles + 1'b1;
end



endmodule

