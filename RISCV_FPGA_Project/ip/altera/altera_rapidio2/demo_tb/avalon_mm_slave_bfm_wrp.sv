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


`timescale 1ns / 1ns
module avalon_mm_slave_bfm_wrp (
            clk,   
            rst_n,
            
            s_waitrequest,
            s_write,
            s_read,
            s_address,
            s_byteenable,
            s_burstcount,
            s_writedata,
            s_readdata,
            s_readdatavalid,
            s_readresponse
            );

  import avalon_utilities_pkg::*;
  import avalon_mm_pkg::*;
  import hutil_pkg::*;
//parameters declarations

   parameter S_ADDRESS_W              = 34; // Address width in bits
   parameter S_SYMBOL_W               = 8;  // Data symbol width in bits
   parameter S_NUMSYMBOLS             = 16;  // Number of symbols per word
   parameter S_USE_BURSTCOUNT         = 1;
   parameter S_BURSTCOUNT_W           = 3;  // Burst port width in bits
   parameter S_READRESPONSE_W         = 1;
   parameter S_WRITERESPONSE_W        = 0;   
   parameter S_BEGIN_TRANSFER         = 0;  // Use begintransfer pin on interface
   parameter S_BEGIN_BURST_TRANSFER   = 0;  // Use beginbursttransfer pin on interface
   parameter S_READRESPONSE           = 1;  // Use read response interface pins  
   parameter S_TRANSACTIONID_W        = 8;

//ports declarations
   
   input  logic                                      clk;
   input  logic                                      rst_n;
   // Avalon Slave Interface
   output logic                                      s_waitrequest;
   output logic                                      s_readdatavalid;
   output logic  [(S_SYMBOL_W * S_NUMSYMBOLS)-1:0]   s_readdata;
   input  logic                                      s_write;
   input  logic                                      s_read;
   input  logic  [S_ADDRESS_W-1:0]                   s_address;
   input  logic  [S_NUMSYMBOLS-1:0]                  s_byteenable;
   input  logic  [S_BURSTCOUNT_W-1:0]                s_burstcount;
   input  logic  [(S_SYMBOL_W * S_NUMSYMBOLS)-1:0]   s_writedata;

   output logic  [S_READRESPONSE_W-1: 0           ]  s_readresponse;
   
   logic [1:0] avs_response;
   
//avalon mm slave bfm instantiation

altera_avalon_mm_slave_bfm#(  
                  
      .AV_ADDRESS_W               (S_ADDRESS_W),
      .AV_SYMBOL_W                (S_SYMBOL_W ),           
      .AV_NUMSYMBOLS              (S_NUMSYMBOLS),           
      .AV_BURSTCOUNT_W            (S_BURSTCOUNT_W) ,
      .AV_READRESPONSE_W          (S_READRESPONSE_W) ,
      .AV_WRITERESPONSE_W         (S_WRITERESPONSE_W) ,    
      .USE_BEGIN_TRANSFER         (S_BEGIN_TRANSFER) ,            
      .USE_BEGIN_BURST_TRANSFER   (S_BEGIN_BURST_TRANSFER) ,             
      .USE_READRESPONSE           (S_READRESPONSE),
      .USE_BURSTCOUNT             (S_USE_BURSTCOUNT))
u_avalon_mm_slave_bfm
   (
     .clk                         (clk                    ),            
     .reset                       (!rst_n                 ),       
     .avs_clken                   (1'b0),      
     .avs_waitrequest             (s_waitrequest          ),        
     .avs_write                   (s_write                ),           
     .avs_read                    (s_read                 ),           
     .avs_address                 (s_address              ),               
     .avs_byteenable              (s_byteenable           ),               
     .avs_burstcount              (s_burstcount           ),               
     .avs_beginbursttransfer      (1'b0),                  
     .avs_begintransfer           (1'b0),            
     .avs_writedata               (s_writedata            ),           
     .avs_readdata                (s_readdata             ),              
     .avs_readdatavalid           (s_readdatavalid        ),              
     .avs_arbiterlock             (1'b0),             
     .avs_lock                    (1'b0),           
     .avs_debugaccess             (1'b0),          
     .avs_transactionid           (8'b0),     
     .avs_readresponse            (),             
     .avs_readid                  (),        
     .avs_writeresponserequest    (1'b0),                
     .avs_writeresponsevalid      (),
     .avs_writeresponse           (),             
     .avs_writeid                 (),
     .avs_response (avs_response) ); 
     
     assign s_readresponse = avs_response[0] || avs_response[1];

//Task for reading the data written into the Slave BFM
task wait_for_write_cmd();
  static Request_t cmd;
  cmd = REQ_READ;
  //Wait for write to be completed
  while (cmd != REQ_WRITE) begin
    @u_avalon_mm_slave_bfm.signal_command_received;
    u_avalon_mm_slave_bfm.pop_command();
    cmd = u_avalon_mm_slave_bfm.get_command_request();
    $display("command recieved is %b", cmd);
  end
endtask

task wait_for_read_cmd;
  input int index;
  output bit [4 : 0] burst_count;
  output bit [15 : 0]byte_enable;
  static Request_t cmd = REQ_WRITE;
  //Wait for write to be completed
  while (cmd != REQ_READ) begin
    @u_avalon_mm_slave_bfm.signal_command_received;
    $display("%m %t read command received on SISTER DUT IOM side %d",$stime, index);
    u_avalon_mm_slave_bfm.pop_command();
    cmd = u_avalon_mm_slave_bfm.get_command_request();
    burst_count = u_avalon_mm_slave_bfm.get_command_burst_count();
    byte_enable = u_avalon_mm_slave_bfm.get_command_byte_enable(index);
  end
endtask

task read_write_data;
  input int index;
  output [S_ADDRESS_W-1:0] addr;
  output [S_BURSTCOUNT_W-1:0] burst_count;
  output [S_NUMSYMBOLS-1:0] byte_enable;
  output [(S_SYMBOL_W * S_NUMSYMBOLS)-1:0] data; 

  begin
    addr = u_avalon_mm_slave_bfm.get_command_address();
    $display("command address is ",addr);
    burst_count = u_avalon_mm_slave_bfm.get_command_burst_count();
    $display("command burstcount is ", burst_count);
    byte_enable = u_avalon_mm_slave_bfm.get_command_byte_enable(index);
    $display("command byte enable is ",byte_enable);
    data = u_avalon_mm_slave_bfm.get_command_data(index);
    $display("command data is ", data);
    u_avalon_mm_slave_bfm.set_interface_wait_time(0, index);
  end
endtask

task write_read_data;
  input  Request_t          rd_wr_req;
  input int index;
  input bit [S_BURSTCOUNT_W-1:0] burst_count;
  input bit [S_BURSTCOUNT_W-1:0] burst_size; 
  input [(S_SYMBOL_W * S_NUMSYMBOLS)-1:0] data; 
  static AvalonResponseStatus_t is_ok = AV_OKAY;

  begin
    if (index == 0)
    begin
       u_avalon_mm_slave_bfm.set_response_request(rd_wr_req);
       u_avalon_mm_slave_bfm.set_interface_wait_time(0, index);
       u_avalon_mm_slave_bfm.set_response_burst_size(burst_size);
    end
    u_avalon_mm_slave_bfm.set_read_response_status(is_ok, index);
    u_avalon_mm_slave_bfm.set_response_data(data,index);
    if (index == (burst_count - 1))
      u_avalon_mm_slave_bfm.push_response();
  end
endtask
    
endmodule              
                        

                        
