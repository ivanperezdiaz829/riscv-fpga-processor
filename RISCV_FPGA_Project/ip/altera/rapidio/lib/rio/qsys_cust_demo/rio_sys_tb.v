/*
*******************************************************************************
# (C) 2001-2010 Altera Corporation. All rights reserved.
# Your use of Altera Corporation's design tools, logic functions and other 
# software and tools, and its AMPP partner logic functions, and any output 
# files any of the foregoing (including device programming or simulation 
# files), and any associated documentation or information are expressly subject 
# to the terms and conditions of the Altera Program License Subscription 
# Agreement, Altera MegaCore Function License Agreement, or other applicable 
# license agreement, including, without limitation, that your use is for the 
# sole purpose of programming logic devices manufactured by Altera and sold by 
# Altera or its authorized distributors.  Please refer to the applicable 
# agreement for further details.
*******************************************************************************
*/
//--------------------------------------------------------------------------
// rio_sys_tb.v 
// This test bench instantiates Altera RapidIO component with
// Altera Avalon-MM Master BFM and an On-Chip Memory.
// The test starts with maintenance transactions, followed by
// I/O read and write transactions. Lastly, read some registers
// in RapidIO.
//
// The test case is defined in the test_input.v file while the
// result checking rountine is defined in test_result.v file
//--------------------------------------------------------------------------

`define WATCHTIME 10000

//console messaging level
`define VERBOSITY VERBOSITY_INFO

//BFM and RapidIO hierachy
`define MSTR_BFM tb.DUT.master_bfm
`define MSTR_BFM_IO tb.DUT.master_bfm_io
`define RIO tb.DUT.rapidio_0

//test bench parameters
`define NUM_MNT_TRANS 12
`define NUM_IO_CONFIG_TRANS 24
`define NUM_IO_TRANS 2
`define NUM_READ_REG_TRANS 12
`define NUM_TRANS (`NUM_MNT_TRANS + `NUM_IO_CONFIG_TRANS + `NUM_READ_REG_TRANS + `NUM_IO_TRANS)  //number of transactions to be performed - include REQ_READ and REQ_WRITE
`define INDEX_ZERO 0

`include "test_bench.v"
//-----------------------------------------------------------------------------
// Test Top Level begins here
//-----------------------------------------------------------------------------
module rio_sys_tb();

//importing verbosity and avalon_mm packages
   import verbosity_pkg::*;
   import avalon_mm_pkg::*;
  
// instantiate RapidIO Qsys system module 
   test_bench tb();  
   
//local variables   
   Request_t command_request, response_request;
   //for 32-bit data width
   reg [31:0] command_addr, response_addr;
   reg [31:0] command_data, response_data;
   reg [31:0] master_scoreboard [$];
   reg [31:0] expected_data;    
   reg [31:0] idle;  
   reg [3:0] byte_enable;
   //for 64-bit data width
   reg [63:0] command_data_64b, response_data_64b;
   reg [63:0] master_scoreboard_64b [$];
   reg [63:0] expected_data_64b;   
   reg [63:0] idle_64b;   
   reg [5:0] response_burst_size;
   reg [7:0] byte_enable_64b;

   integer init_latency;
   integer failure = 0;
   integer checked = 0;
   integer burstcount;
   integer burstsize;
   integer io_burstcount = 0;

   event start_test;
   event go_check;
   event go_read_response; 
   event io_trans_config;
   event io_trans;
   event go_check_io; 
   event read_register;

//initialize the Master BFM
   initial begin
      set_verbosity(`VERBOSITY);
      `MSTR_BFM.init();	
      `MSTR_BFM_IO.init();	
      //wait for reset to de-assert and trigger start_test event
      wait(`MSTR_BFM.reset == 0);
      $sformat(message, "Master BFM reset");
      print(VERBOSITY_INFO, message);
      //wait for reset to de-assert
      wait(`MSTR_BFM_IO.reset == 0);
      $sformat(message, "Master BFM I/O reset");
      print(VERBOSITY_INFO, message);
      //wait for reset to de-assert
      wait(`RIO.reset_n == 1);
      $sformat(message, "RapidIO reset");
      print(VERBOSITY_INFO, message);
      wait(`RIO.port_initialized == 1);
      print_info("RapidIO Port initialized");
      -> start_test;
   end
    
//check responses received by Master BFM
   always @(posedge tb.clk_0) begin    
      while (`MSTR_BFM.get_response_queue_size() > 0)
      if (checked < (`NUM_MNT_TRANS + `NUM_IO_CONFIG_TRANS)) begin
      //Verify value in Base Device ID offset 0x60, Port General Control 0x13c, 
      //Tx maintenance Window 0 Control 0x1010C and Tx Maintenance Window 0 Mask 0x10104.
         //pop out the response desriptor from queue when queue is not empty
         master_pop_and_get_response(response_request, response_addr, response_data);
         //trigger event to check the response with expected data
         -> go_check;
      end else begin
      //Read from registers but no verification
         //pop out the response desriptor from queue when queue is not empty
         master_pop_and_get_response(response_request, response_addr, response_data);
         //trigger event to read the response data but without verification
         -> go_read_response;
      end
   end

   always @(posedge tb.clk_0) begin    
      while (`MSTR_BFM_IO.get_response_queue_size() > 0)
      begin	     
         //pop out the response desriptor from queue when queue is not empty
         master_io_pop_and_get_response(response_request, response_addr, response_data_64b);
         //trigger event to check the response with expected data
         -> go_check_io;
      end
   end

//Simulation ends here
//Both write and read transactions do have response descriptors, 
//so NUM_TRANS is total number of REQ_READ and REQ_WRITE.
   initial begin
      while (checked != (`NUM_MNT_TRANS))
      @(tb.clk_0);
      -> io_trans_config;
      while (checked != (`NUM_MNT_TRANS + `NUM_IO_CONFIG_TRANS))
      @(tb.clk_0);
      -> io_trans;
      while (checked != (`NUM_MNT_TRANS + `NUM_IO_CONFIG_TRANS +`NUM_IO_TRANS))
      @(tb.clk_0);
      -> read_register;
      while (checked != (`NUM_TRANS))
      @(tb.clk_0);
      $sformat(message, "%m: Test has completed. %0d pass, %0d fail.", ((checked) - failure), failure);
      print(VERBOSITY_INFO, message);
      $stop;
   end

   initial begin
      # `WATCHTIME;
      $sformat(message, "%m: Watchdog timer expired. %0d pass, %0d fail, %0d incomplete.", ((checked) - failure), failure, (`NUM_TRANS - checked));
      print(VERBOSITY_ERROR, message);
      $stop;
   end

  `include "test_input.v"
  `include "test_result.v"
  
  //----------------------------------------------------------------------------------
  // tasks
  //----------------------------------------------------------------------------------
  
   //this task sets the command descriptor for Master BFM and push it to the queue
   task master_set_and_push_command;
      input Request_t request;
      input [31:0] addr;
      input [31:0] data;
      input [ 3:0] byte_enable;
      input [31:0] idle;
      input [31:0] init_latency;
    
      begin
         `MSTR_BFM.set_command_request(request);
         `MSTR_BFM.set_command_address(addr);    
         `MSTR_BFM.set_command_byte_enable(byte_enable,`INDEX_ZERO);
         `MSTR_BFM.set_command_idle(idle, `INDEX_ZERO);
         `MSTR_BFM.set_command_init_latency(init_latency);
         if (request == REQ_WRITE) begin
            `MSTR_BFM.set_command_data(data, `INDEX_ZERO);      
         end	
	 `MSTR_BFM.push_command();
      end
   endtask
  
   //this task pops the response received by master BFM from queue
   task master_pop_and_get_response;
      output Request_t request;
      output [31:0] addr;
      output [31:0] data;
 
      begin
         `MSTR_BFM.pop_response();
         request = Request_t' (`MSTR_BFM.get_response_request());
         addr = `MSTR_BFM.get_response_address();
         data = `MSTR_BFM.get_response_data(`INDEX_ZERO);	
      end
   endtask


   //this task sets the command descriptor for Master BFM I/O and push it to the queue
   task master_io_set_and_push_command;
      input Request_t request;
      input [31:0] addr;
      input [63:0] data;
      input [ 7:0] byte_enable;
      input [63:0] idle;
      input [31:0] init_latency;
      input [ 5:0] burstcount;
      input [ 2:0] burstsize;
    
      begin
         `MSTR_BFM_IO.set_command_request(request);
         `MSTR_BFM_IO.set_command_address(addr);    
         `MSTR_BFM_IO.set_command_byte_enable(8'hff,0);
         `MSTR_BFM_IO.set_command_idle(idle, `INDEX_ZERO);
         `MSTR_BFM_IO.set_command_init_latency(init_latency);
         `MSTR_BFM_IO.set_command_burst_count(burstcount);
         `MSTR_BFM_IO.set_command_burst_size(burstsize);
         if (request == REQ_WRITE) begin
            `MSTR_BFM_IO.set_command_data(data, `INDEX_ZERO);      
         end	
	 `MSTR_BFM_IO.push_command();
      end
   endtask
  
   //this task pops the response received by master BFM from queue
   task master_io_pop_and_get_response;
      output Request_t request;
      output [31:0] addr;
      output [63:0] data;

      begin
         `MSTR_BFM_IO.pop_response();
         request = Request_t' (`MSTR_BFM_IO.get_response_request());
         addr = `MSTR_BFM_IO.get_response_address();
         data = `MSTR_BFM_IO.get_response_data(`INDEX_ZERO);	
      end
   endtask

   //this task prints information
   task print_info;
      input string info;

      begin
         $sformat(message, info);
         print(VERBOSITY_INFO, message);
      end
   endtask

endmodule
