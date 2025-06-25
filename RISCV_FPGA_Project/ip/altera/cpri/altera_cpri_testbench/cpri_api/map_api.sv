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


/* Module MAP_API
--------------------------
 Supported Task Function:
--------------------------
1) display( )             ~ display the write header to indicate the write operation has started
2) wr (seed,data)         ~ send the prbs 32 bits MAP data with different seed with tx_valid asserted.
3) wr_start ( )           ~ disassert the map_en and map_check to 1'b0. [Optional: useful for tb control]
4) wr_end ( )             ~ reset back to normal if no further MAP transactions is needed to be sent with tx_valid deasserted.
5) rd_start ()            ~ assert rx_ready
6) rd_end ()              ~ deassert rx_ready 
7) compare(rx_data)       ~ compare the input and output of all user specified map data

Instructions:
- In order for the comparison to work, the following sequence is needed.
- 1st step: execute the wr()
- 2nd step: display() [Optional]
- 3rd step: execute wr_end() if no further transaction needed.
- 4th step: execute rd_start() 
- 5th step: execute compare() [Optional]

** Disclaimer : Only BASIC FIFO mode is supported **
*/

`include "../models/cpri_pkg/timescale.sv"

module map_api (
   rst,
   map_err,
   map_en,
   map_check,
   tx_clk,
   tx_rst,
   tx_resync,
   tx_valid,
   tx_data,
   rx_clk,
   rx_rst,
   rx_resync,
   rx_ready
);

// Parameters
parameter map_data_width = 32;
parameter channel_en = 1;

// I/O
input              tx_clk,tx_rst,rst;
input              rx_clk,rx_rst;
output reg [1:0] map_err;
output reg tx_valid;
output reg [map_data_width-1:0] tx_data;            
output reg rx_ready,map_check,map_en;
output reg tx_resync,rx_resync;

// Internal Signala
integer cnt,i,m;
reg compare_map,map_cw_en;
reg temp;
reg [map_data_width-1:0] map_err_tmp;
reg [map_data_width-1:0] mem_map [];

// Tx Reset
always @ (tx_rst)
begin
   if (tx_rst == 1'b1) begin
      tx_resync =1'b0;
      tx_valid = 1'b0;
      tx_data = 32'h0;
   end
end

// Rx Reset
always @ (rx_rst)
begin
   if (rx_rst == 1'b1) begin
      rx_resync = 1'b0;
      rx_ready = 1'b0;
   end
end

// Global reset
always @ (rst)
begin
   // TX
   //tx_resync =1'b0;
   //tx_valid = 1'b0;
   //tx_data = 32'h0;
   // RX
   //rx_resync = 1'b0;
   //rx_ready = 1'b0;
   // MISC
   m =0;
   cnt = 0;
   i = 0;
   map_en = 1'b0;
   map_check = 1'b0;
   map_err_tmp = 32'h0;
   map_cw_en = 1'b0;
   compare_map = 1'b0;
end

// Check ~ '0' = PASSED, '1' = FAILED
assign temp = (^map_err_tmp);
assign map_err ={channel_en, ~(temp^map_cw_en)};

//------------------------------------------------------
//                    MAP TASK 
//DO NOT MODIFIED THE TASK FUNCTION (IF YOU ARE UNSURE)
//------------------------------------------------------

//----------------
// FIFO mode
//----------------
/////////////
task wr_start;
/////////////
begin
   map_en = 1'b0;
   map_check = 1'b0;
end
endtask

//////////
task wr;
//////////

input seed;
input num_data;

integer seed;
integer num_data;

begin
   mem_map = new[num_data];
   for(cnt = 0; cnt <= num_data; cnt=cnt+1)
         begin
            @ (posedge tx_clk)
            tx_data = { $random(seed) }; 
            mem_map[cnt] = tx_data; 
            tx_valid = 1'b1;
         end
         $display(" ");
end
endtask

/////////////
task wr_end;
/////////////

begin
   tx_data = 32'h0;
   tx_valid = 1'b0;
   $display ("Info: MAP Write Ended");
   $display ("");
end
endtask

///////////////
task rd_start;
///////////////

input delay;
integer delay;

begin
   repeat(delay) @ (posedge rx_clk); 
   rx_ready = 1'b1;
end
endtask

///////////////
task rd_end;
///////////////

begin
   rx_ready = 1'b0;
end
endtask

//////////////
task display;
//////////////

input channel;
integer channel;

  $display ("Info: ===========================================================");
  $display ("Info:                CHANNEL %d                                  ",channel);
  $display ("Info:                MAP WRITE                                   ");
  $display ("Info: ==========================================================="); 
  $display ("Info: MAP Write Started");
  $display ("Info: Total of MAP Data: %0d", mem_map.size);
  for (i = 0; i < mem_map.size; i=i+1)
  begin
     $display ("%g MAP Write ~ Data %0d : 32'h%h",$time,i+1,mem_map[i]);
  end
endtask

//////////////
task compare;
//////////////

input [31:0] data;
input channel;
integer channel;

if (data == mem_map[0])
begin  
   $display ("Info: ===========================================================");
   $display ("Info:                CHANNEL %d                                  ",channel);
   $display ("Info:                MAP CHECK                                   ");
   $display ("Info: ==========================================================="); 
   $display ("%g MAP CHN %0d Check ~ Data %0d Transmitted  : 32;h%h",$time,channel,m+1,mem_map[m]);
   $display ("%g MAP CHN %0d Check ~ Data %0d Received     : 32'h%h",$time,channel,m+1,data);
   $display ("%g 1st Data CHN  %0d ~ Received successfully. Continue...", $time, channel);
   $display ("");
   compare_map = 1'b1;
   map_cw_en = 1'b1;
   m++;
end
else if ((compare_map== 1'b1) && (m != mem_map.size()))  
   if (mem_map[m] == data)
   begin
      $display ("%g MAP CHN %0d Check ~ Data %0d Transmitted  : 32'h%h",$time,channel,m+1,mem_map[m]);
      $display ("%g MAP CHN %0d Check ~ Data %0d Received     : 32'h%h",$time,channel,m+1,data); 
      map_err_tmp = map_err_tmp;
      m++;
   end
   else
   begin
      $display ("%g MAP CHN %0d Check ~ Data %0d Transmitted  : 32'h%h",$time,channel,m+1,mem_map[m]);
      $display ("%g MAP CHN %0d Check ~ Data %0d Received     : 32'h%h",$time,channel,m+1,data); 
      map_err_tmp = map_err_tmp + 1'b1;
      m++;
   end

else if ((compare_map == 1'b1) && (m == mem_map.size())) 
   begin
      //$display ("Info            MAP%d Check Ended",channel); 
      //$display ("");
      m = 0;
      compare_map = 1'b0;
      rd_end();
      map_check = 1'b1;
      mem_map.delete();
   end

endtask

endmodule
