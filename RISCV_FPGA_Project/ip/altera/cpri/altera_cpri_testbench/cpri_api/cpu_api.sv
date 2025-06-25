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


/* Module CPU_API
------------------------------
 Supported CPU Task Function:
------------------------------
1) display_wr ( )   ~ display the write header to indicate the write operation has started
2) display_rd ( )   ~ display the read header to indicate the read operation has started 
3) display_comp ( ) ~ display the check header to indicate the compare operation has started 
4) wr (addr,data)   ~ configure the CPRI register value with write operation
5) rd (addr)        ~ read the register value from CPRI
6) compare(addr)    ~ compare the read and write register value of the user
7) report(addr)     ~ report the round trip delay

Instructions:
- In order for the comparison to work, the following sequence is needed.
- 1st step: Do a 'wr' followed by a 'rd' command 
- 2nd step: Do a 'compare'

------------------------------
 Supported HDLC Task Function:
------------------------------
1) display_wr_hdlc ~ to display the HDLC write header [Optional]
2) display_rd_hdlc ~ to display the HDLC read header [Optional]
3) hdlc_start() ~ to disassert the hdlc_en and hdlc_check before the start of any transaction. This step is not needed if reset is executed prior this command.
4) hdlc_end ()  ~ to assert the hdlc_en. hdlc_en is useful to trigger the next instruction. [Optional]
5) hdlc_wr(addr,data,cnt)~ write the HDLC data into the HDLC address
6) hdlc_rd(addr,pool_en) ~ read the value in a register with/without message , pool_en=1 (with message),pool_en=0 (without message)
7) hdlc_compare(addr,data) ~ the HDLC data will be read based on the input register address and compare to the transmitted data

Instruction:
- 1st step : hdlc_start (applicable for second transaction of HDLC data since the reset is implemented at the start of simulation)
- 2nd step : hdlc_wr
- 3rd step : hdlc_compare (read and compare at the same time)

** Disclaimer: CPU Burst R/W is not supported. **
End */

`include "../models/cpri_pkg/timescale.sv"
`include "../models/cpri_pkg/reg_pkg.sv"

module cpu_api (
   clk,
   rst,
   adr,
   din,
   dout,
   en_wr,
   en_rd,
   ack,
   hdlc_check,
   hdlc_en,
   hdlc_err,
   cpu_err
);

// Parameters
parameter data_width = 32;
parameter adr_width  = 32;

// I/O
input                         clk,rst,ack;
input      [data_width-1 : 0] din;
output reg [data_width-1 : 0] dout;
output reg [adr_width-1  : 0] adr;
output reg cpu_err;
output reg en_wr;
output reg en_rd;
output reg hdlc_err;
output reg hdlc_check;
output reg hdlc_en;

// Internal Signals
reg [data_width-1 : 0] data_rd;
reg [adr_width-1:0] mem_wr [1023:0];
reg [adr_width-1:0] mem_rd [1023:0];
reg [data_width-1:0] cpu_err_tmp;
reg cpu_cw_en;

// HDLC Signals
reg [data_width-1:0] mem_hdlc [];
reg compare_hdlc,hdlc_cw_en;
reg temp,temp_hdlc;
reg [data_width-1:0] hdlc_err_tmp;
integer m;

// Signal Assignments
assign temp = (^cpu_err_tmp);
assign cpu_err = ~(temp^cpu_cw_en);

// Global Reset 
always @ (rst)
begin
   if (rst ==1) begin
      //reset all the cpu signal
      en_rd = 1'b0;
      en_wr = 1'b0;
      adr = {adr_width{1'b0}}; 
      dout = {data_width{1'b0}};
      cpu_err_tmp ={data_width{1'b0}};
      cpu_cw_en = 1'b0;
      data_rd  = din;
      hdlc_err_tmp = 32'h0;
      m= 0;
      hdlc_cw_en = 1'b0;
      compare_hdlc = 1'b0;
      hdlc_en = 1'b0;
      hdlc_check = 1'b0;
   end
end

// Check ~ '0' = PASSED, '1' = FAILED
always @ (posedge clk)
begin
   if (cpu_err_tmp > 1'b1)
      cpu_cw_en = 1'b0;   
   else
      cpu_cw_en = 1'b1;
end

// Check ~ '0' = PASSED, '1' = FAILED
assign temp_hdlc = (^hdlc_err_tmp);
assign hdlc_err = ~(temp_hdlc^hdlc_cw_en);

// Use for checking purposes
initial $readmemh("../models/cpri_api/hdlc_data.txt",mem_hdlc); 

//------------------------------------------------------
//                    CPU TASK 
//DO NOT MODIFIED THE TASK FUNCTION (IF YOU ARE UNSURE)
//------------------------------------------------------

/////////////////
task display_wr;
/////////////////
$display ("Info: ===========================================================");
$display ("Info:                      CPU WRITE                             ");
$display ("Info: ===========================================================");
$display ("Info: Write Operation started                                    "); 
endtask

/////////////////
task display_rd;
/////////////////
$display ("Info: ==========================================================");
$display ("Info:                      CPU READ                             ");
$display ("Info: ==========================================================");
$display ("Info: Read Operation started                                    "); 
endtask

/////////////////
task display_comp;
/////////////////
$display ("Info: =========================================================");
$display ("Info:                      CPU CHECK                           ");
$display ("Info: =========================================================");
$display ("Info: Check Operation started                                  ");
endtask

/////////////////////
task display_wr_hdlc;
/////////////////////
$display ("Info: ===========================================================");
$display ("Info:                      HDLC WRITE                            ");
$display ("Info: ===========================================================");
$display ("Info: Ready to transfer                                          "); 
endtask

/////////////////////
task display_rd_hdlc;
/////////////////////
$display ("Info: ==========================================================");
$display ("Info:                      HDLC READ                            ");
$display ("Info: ==========================================================");
$display ("Info: Ready to receive                                          "); 
endtask

/////////////////
task wr;
/////////////////

input [adr_width-1:0] address;
input [data_width-1:0] data;

begin
   //wait initial delay
   @ (posedge clk);
   $display ("%g  CPU Write ~ Register Addr : 14'h%h , Value : 32'h%h", $time,address,data);
   
   @ (posedge clk);
   adr = address;
   en_wr = 1;
   dout = data;

while(ack) @(posedge clk);
repeat(11) @ (posedge clk); //8 cycles of '1', then deasserted
adr = 0;
en_wr = 0;

end
endtask

//////////////
task rd;
//////////////

input [adr_width-1:0] address;

begin   
   @ (posedge clk);
   adr = address;
   en_rd = 1;
  
   while(ack) @(posedge clk);
   repeat(11) @ (posedge clk); //11 cycles of '1', then deasserted
   adr = 0;
   en_rd = 0;
   data_rd = din;
   
   $display ("%g CPU Read ~ Register Addr : 14'h%h , Value : 32'h%h",$time,address,data_rd);
end
endtask

//////////////
task report;
//////////////

//input [adr_width-1:0] address;

begin   
   @ (posedge clk);
   adr = REG_CPRI_ROUND_DELAY;
   en_rd = 1;
  
   while(ack) @(posedge clk);
   repeat(11) @ (posedge clk); //11 cycles of '1', then deasserted
   adr = 0;
   en_rd = 0;
   data_rd = din;
   
   $display (" Info: Total Round Trip Delay: %0d",data_rd);
end
endtask


//////////////////
task compare;
//////////////////

input [adr_width-1:0] address;
  
begin
   if (mem_rd[address] != mem_wr [address])
      cpu_err_tmp = cpu_err_tmp + 1'b1;

   if (mem_rd[address] == mem_wr [address])
      $display ("%g CPU Check ~ Register Addr : 14'h%h , Value : 32'h%h",$time,address,mem_wr[address]);
   end
endtask

///////////////////////////////////////////////
// latch the data into an array
// assume customer R/W is in the same sequence
///////////////////////////////////////////////
always @ (posedge clk)
begin
   if (en_wr)
      if (!ack)
      mem_wr[adr] <= dout;
end

always @ (posedge clk)
begin
   if (en_rd)
      if (!ack)
      mem_rd[adr] <= din;
end

/////////////////
task hdlc_start;
/////////////////
begin
   @ (posedge clk);
   hdlc_en = 1'b0;
   hdlc_check = 1'b0;
end
endtask

////////////////////
task hdlc_end;
////////////////////
begin
   @ (posedge clk);
   dout = {data_width{1'b0}}; 
   hdlc_en = 1'b1;
   $display ("Info: HDLC Write Ended");
   $display ("");
end
endtask

/////////////////
task hdlc_wr;
/////////////////

input [adr_width-1:0] address;
input [data_width-1:0] data;
input hdlc_cnt;
integer hdlc_cnt;

begin
   //wait initial delay
   @ (posedge clk);
   $display ("%g HDLC Write ~ Data %0d : 32'h%h",$time,hdlc_cnt+1,data);
   
   @ (posedge clk);
   adr = address;
   en_wr = 1;
   dout = data;

while(ack) @(posedge clk);
repeat(11) @ (posedge clk); //8 cycles of '1', then deasserted
adr = 0;
en_wr = 0;

end
endtask

/////////////////
task hdlc_rd;
/////////////////

input [adr_width-1:0] address;
input pool_en;
integer pool_en;

begin
   
   @ (posedge clk);
   adr = address;
   en_rd = 1;

   while(ack) @(posedge clk);
   repeat(11) @ (posedge clk); //11 cycles of '1', then deasserted
   adr = 0;
   en_rd = 0;
   data_rd = din;
  
   if (pool_en == 1)
   begin
      //$display ("Pooling the status of register addr : %h",address);
   end
   else
      $display ("%g HDLC Read ~ Register Addr : 14'h%h , Data: 32'h%h",$time,address,data_rd);
end
endtask

///////////////////
task hdlc_compare;
///////////////////
input [adr_width-1:0] address;
input [31:0] data;

// Pooling the data
hdlc_rd(address,1);

if (data == mem_hdlc[0])
begin  
   $display ("Info: ===========================================================");
   $display ("Info:                HDLC CHECK                                  ");
   $display ("Info: ==========================================================="); 
   $display ("%g HDLC Check ~ Data %0d Transmitted : 32'h%h",$time,m+1,mem_hdlc[0]);
   $display ("%g HDLC Check ~ Data %0d Received    : 32'h%h",$time,m+1,data);
   compare_hdlc = 1'b1;
   hdlc_cw_en = 1'b1;
   m++;
end
else if ((compare_hdlc== 1'b1) && (m != mem_hdlc.size()))  
   if (mem_hdlc[m] == data)
   begin
      $display ("%g HDLC Check ~ Data %0d Transmitted : 32'h%h",$time,m+1,mem_hdlc[m]);
      $display ("%g HDLC Check ~ Data %0d Received    : 32'h%h",$time,m+1,data); 
      hdlc_err_tmp = hdlc_err_tmp;
      m++;
   end
   else
   begin
      $display ("%g HDLC Check ~ Data %0d Transmitted : 32'h%h",$time,m+1,mem_hdlc[m]);
      $display ("%g HDLC Check ~ Data %0d Received    : 32'h%h",$time,m+1,data); 
      hdlc_err_tmp = hdlc_err_tmp + 1'b1;
      m++;
   end

else if ((compare_hdlc == 1'b1) && (m == mem_hdlc.size())) 
   begin
      $display ("Info: HDLC Check Ended");
      $display (" ");
      m = 0;
      compare_hdlc = 1'b0;
      hdlc_check = 1'b1;
      mem_hdlc.delete();
   end
endtask

endmodule

