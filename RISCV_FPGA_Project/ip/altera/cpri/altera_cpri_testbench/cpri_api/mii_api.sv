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


/* Module MII_API
--------------------------
 Supported Task Function:
--------------------------
1) display( )                      ~ display the write header to indicate the write operation has started
2) wr_start
3) wr (delay,data,err)             ~ send the mii data with 'err' and 'delay' feature. [delay=0,data=0,err=0 by default]
4) wr_end ( )                      ~ reset back to normal if no further MII transactions is needed to be sent
5) compare(mii_data,mii_err)       ~ compare the input and output of all user specified MII data

Instructions:
- In order for the comparison to work, the following sequence is needed.
- 1st step: display() [This step is optional]
- 2nd step: execute wr_start()
- 3rd step: execute wr()
- 4td step: execute wr_end() if no further transaction needed.
- 5th step: execute compare() if needed
*/


`include "../models/cpri_pkg/timescale.sv"

module mii_api (
   rst,
   mii_txclk,         
   mii_txrd,
   mii_check,
   mii_en,
   mii_err,
   mii_txen,
   mii_txer,
   mii_txd
);

// Parameters
parameter mii_data_width = 4;
parameter data_width = 32;

// I/O
input             rst;
input             mii_txclk;
input             mii_txrd;
output reg        mii_txen;
output reg        mii_txer;
output reg [3:0]  mii_txd;
output reg        mii_check;
output reg        mii_en;
output reg        mii_err;

// Internal Signal
integer x;
reg compare_mii,mii_cw_en;
reg [mii_data_width-1:0] mem_mii[];
reg temp;
reg [data_width-1:0] mii_err_tmp;

// Global Reset
always @ (rst)
begin
   if (rst == 1) begin
      mii_txen = 1'b0;
      mii_txer = 1'b0;
      mii_txd = 4'h0;
      x = 0;
      compare_mii = 1'b0;
      mii_cw_en = 1'b0;
      mii_err_tmp= 32'h0;
      mii_check = 1'b0;
      mii_en = 1'b0;
   end
end

// Check ~ '0' = PASSED, '1' = FAILED
assign temp = (^mii_err_tmp);
assign mii_err = ~(temp^mii_cw_en);

// Use for checking purposes
initial $readmemh("../models/cpri_api/mii_data.txt",mem_mii); 

//------------------------------------------------------
//                    MII TASK 
//DO NOT MODIFIED THE TASK FUNCTION (IF YOU ARE UNSURE)
//------------------------------------------------------

//////////////
task display;
//////////////
begin
   $display ("Info: ===========================================================");  
   $display ("Info:                       MII WRITE                            ");
   $display ("Info: ===========================================================");
   $display ("Info: MII Write Started");
end
endtask

///////////////
task wr_start;
///////////////

begin
   @ (posedge mii_txrd)
   mii_txen = 1'b1;
   mii_en = 1'b0;
   mii_check = 1'b0;
   mii_cw_en = 1'b0;
end
endtask

///////////////
task wr;
//////////////

input delay;
integer delay;
input [3:0] data;
input err;
input data_cnt;
integer data_cnt;

begin
   // delay is used to control when to latch the data based on txd
   repeat(delay) @ (posedge mii_txrd); 
   mii_txer = err;
   mii_txd = data;
   
   @ (posedge mii_txrd)
   mii_txer = 1'b0;   
   $display ("%g MII Write ~ Data %0d : 4'h%h , Err_en : 1'h%h",$time,data_cnt,data,err);
end
endtask

////////////////////
task wr_end;
///////////////////

begin
    mii_txer = 1'b0;
    mii_txd = 4'h0;
    mii_txen = 1'b0;
    mii_en = 1'b1; //to stop the next transaction
    $display ("Info: MII Write Ended");
    $display ("");
end
endtask

//////////////////
task compare;
//////////////////

input [3:0] rx_data;
input rxer;

begin 
   //SOP detection
   if (rx_data == 4'h5)
   begin
      $display ("Info: ===========================================================");  
      $display ("Info:                       MII CHECK                            ");
      $display ("Info: ===========================================================");
      $display ("Info: Check Operation started                                    ");
      $display ("Control Word Detected : 4'h5");
      compare_mii = 1'b1;
      mii_cw_en = 1'b1;
      x = 0;
   end
   else if((compare_mii== 1'b1) && (x != mem_mii.size()))
      if (rxer == 1'b1) 
      begin
         if (rx_data == 4'hf)
         begin
            $display ("%g MII Check ~ Data %0d Transmitted  : %h",$time,x+1,mem_mii[x]);
            $display ("%g MII Check ~ Data %0d Received     : %h , Err_Enabled : %h",$time,x+1,rx_data,rxer);
            mii_err_tmp = mii_err_tmp;
            x++; 
         end
         else
         begin
            $display ("%g MII Check ~ Data %0d Transmitted  : %h",$time,x+1,mem_mii[x]);
            $display ("%g MII Check ~ Data %0d Received     : %h , Err_Enabled : %h",$time,x+1,rx_data,rxer);  
            mii_err_tmp = mii_err_tmp + 1'b1;
            x++;
         end
      end
      
      else 
      begin
         if (mem_mii[x] == rx_data) 
         begin
            $display ("%g MII Check ~ Data %0d Transmitted  : %h",$time,x+1,mem_mii[x]);
            $display ("%g MII Check ~ Data %0d Received     : %h",$time,x+1,rx_data); 
            mii_err_tmp = mii_err_tmp;
            x++;
         end
         
         else
         begin
            $display ("%g MII Check ~ Data %0d Transmitted  : %h",$time,x+1,mem_mii[x]);
            $display ("%g MII Check ~ Data %0d Received     : %h",$time,x+1,rx_data); 
            mii_err_tmp = mii_err_tmp + 1'b1;
            x++; 
         end
      end
   
   else if ((compare_mii == 1'b1) && (x == mem_mii.size())) 
   begin
      $display ("Info: MII Check Ended");
      $display ("");
      x = 0;
      compare_mii = 1'b0;
      mii_check = 1'b1; // to indicate check has completed.
      mem_mii.delete();
   end
end
endtask

endmodule
