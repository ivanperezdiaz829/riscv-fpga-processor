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


/* Module AUX_API
--------------------------
 Supported Task Function:
--------------------------
1) display( )             ~ display the write header to indicate the write operation has started
2) wr_start( )            ~ diassert the aux_en and aux_check.These signals are useful to control the next sequence of the transaction. [Optional] 
3) wr (sync,data,mask)    ~ send the aux data with 'mask' and 'sync' feature. [Mask=32'h0,Sync=1'b0 by default]
4) wr_end ( )             ~ reset back to normal if no further AUX transactions is needed to be sent
5) compare(rx_data)       ~ compare the input and output of all user specified aux data

Instructions:
- In order for the comparison to work, the following sequence is needed.
- 1st step: execute wr_start() [Optional]
- 2nd step: display() [Optional]
- 3rd step: execute the wr()
- 4th step: execute wr_end() if no further transaction needed.
- 5th step: execute compare() [Optional]
*/

`include "../models/cpri_pkg/timescale.sv"
 
module aux_api (
   clk,
   rst,
   valid,
   addr_aux_rx,
   addr_aux_tx,
   addr_rx,
   addr_tx,
   aux_en,
   aux_check,
   aux_err,
   dout
);

// Parameters
parameter data_width = 65;
parameter adr_width = 8;
parameter aux_data_width = 32;

// I/O
input clk,rst;
input  [75:0] addr_aux_rx;
input  [43:0] addr_aux_tx;
output reg [data_width-1:0] dout;
output reg [27:0] addr_rx;
output reg [27:0] addr_tx;
output reg aux_en;
output reg aux_check;
output reg aux_err;
output reg valid;

// Internal Signals
reg [aux_data_width-1:0] mem_aux [];
reg [27:0] mem_addr [0:100];
reg compare_aux,aux_cw_en;
reg temp;
reg [aux_data_width-1:0] aux_err_tmp;
integer m;
integer n;

// Signal Assignments
assign addr_rx = {addr_aux_rx[72:61],addr_aux_rx[60:53],addr_aux_rx[52:45]}; //{BFN,HFN,cnt_x} 
assign addr_tx ={addr_aux_tx[14:3],addr_aux_tx[22:15],addr_aux_tx[30:23]};   //{BFN,HFN,cnt_x}

// Global Reset
always @ (rst)
begin
   if (rst ==1) begin
   dout = {data_width{1'b0}}; 
   valid = 1'b0;
   aux_err_tmp = 32'h0;
   m= 0;
   n= 0;
   aux_cw_en = 1'b0;
   compare_aux = 1'b0;
   aux_en = 1'b0;
   aux_check = 1'b0;
   end
end

// Check ~ '0' = PASSED, '1' = FAILED
assign temp = (^aux_err_tmp);
assign aux_err = ~(temp^aux_cw_en);

// Use for checking purposes
initial $readmemh("../models/cpri_api/aux_data.txt",mem_aux); 

//------------------------------------------------------
//                    AUX TASK 
//DO NOT MODIFIED THE TASK FUNCTION (IF YOU ARE UNSURE)
//------------------------------------------------------

//////////////
task display;
//////////////
begin
  $display ("Info: ===========================================================");
  $display ("Info:                       AUX WRITE                            ");
  $display ("Info: ===========================================================");
  $display ("Info: Aux Write Started");
end
endtask

/////////////////
task wr_start;
/////////////////
begin
   @ (posedge clk);
   aux_en = 1'b0;
   aux_check = 1'b0;
   n = 0;
end
endtask

////////////////
task wr;
////////////////

input sync;
input [31:0] data;
input [31:0] mask;
input [23:0] addr;

begin
   $display ("%g AUX Write ~ Data %0d : 32'h%h  , Mask : 32'h%h , BFN : %h , HFN : %h , CNT_X : %h",$time, n+1,data,mask,addr[23:16],addr[15:8],addr[7:0]);
   @ (posedge clk);
   dout={sync,data,mask};
   mem_addr[n] = addr;
   n++;
   valid = 1'b1;
end
endtask

////////////////////
task wr_end;
////////////////////

begin
   @ (posedge clk);
   dout = {data_width{1'b0}}; 
   valid = 1'b0;
   aux_en = 1'b1;
   $display ("Info: Aux Write Ended");
   $display ("");
end
endtask

//////////////////
task compare;
//////////////////

   input [aux_data_width-1:0] data;
   input [27:0] addr;

   if ((data == mem_aux[0]) && (addr == mem_addr[0]))
   begin
      $display ("Info: ===========================================================");  
      $display ("Info:                      AUX CHECK                             ");
      $display ("Info: ===========================================================");
      $display ("Info: Check Operation started                                    ");
      $display ("%g Control Word Detected : 32'h%h",$time,mem_aux[0]);
      aux_cw_en = 1'b1;
      compare_aux = 1'b1;
      m++;
   end  
   else if ((compare_aux== 1'b1) && (m != mem_aux.size())) 
      if (mem_aux[m] == data) 
      begin
         $display ("%g Aux Check ~ Data %0d Transmitted  : 32'h%h",$time,m+1,mem_aux[m]);
         $display ("%g Aux Check ~ Data %0d Received     : 32'h%h",$time,m+1,data); 
         aux_err_tmp = aux_err_tmp;
         m++;
      end      
      else
      begin
         $display ("%g Aux Check ~ Data %0d Transmitted  : 32'h%h",$time,m+1,mem_aux[m]);
         $display ("%g Aux Check ~ Data %0d Received     : 32'h%h",$time,m+1,data); 
         aux_err_tmp = aux_err_tmp + 1'b1;
         m++;
      end
      
   else if ((compare_aux == 1'b1) && (m == mem_aux.size())) 
   begin
      $display ("Info: Aux Check Ended");
      $display ("");
      m = 0;
      compare_aux = 1'b0;
      aux_check = 1'b1; //to indicate check has completed.
      mem_aux.delete();
   end
endtask

endmodule
