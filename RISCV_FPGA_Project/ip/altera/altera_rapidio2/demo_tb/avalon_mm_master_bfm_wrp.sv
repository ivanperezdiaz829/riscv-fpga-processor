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
module avalon_mm_master_bfm_wrp (
         clk , 
         rst_n , 
         m_waitrequest ,         
         m_write ,           
         m_read ,        
         m_address ,           
         m_byteenable ,          
         m_burstcount ,          
         m_writedata ,           
         m_readdata ,            
         m_readdatavalid ,       
         m_readresponse        
                     );

//parameters declarations

   parameter MM_ADDRESS_W              = 32; // Address width in bits
   parameter MM_SYMBOL_W               = 8;  // Data symbol width in bits
   parameter MM_NUMSYMBOLS             = 4;  // Number of symbols per word
   parameter MM_BURSTCOUNT_W           = 5;  // Burst port width in bits
   parameter MM_READRESPONSE_W         = 8;
   parameter MM_WRITERESPONSE_W        = 8;   
   parameter MM_BEGIN_TRANSFER         = 0;  // Use begintransfer pin on interface
   parameter MM_BEGIN_BURST_TRANSFER   = 1;  // Use beginbursttransfer pin on interface
   parameter MM_READRESPONSE           = 1;  // Use read response interface pins  
   parameter MM_USE_WRITERESPONSE      = 1;
   parameter MM_TRANSACTIONID_W        = 8;
   parameter MM_USE_BURSTCOUNT         = 1;

//port declarations
   input  logic                                        clk;
   input  logic                                        rst_n;   
   input  logic                                        m_waitrequest;   
   input  logic                                        m_readdatavalid; 
   output  logic [(MM_SYMBOL_W * MM_NUMSYMBOLS)-1:0 ]  m_writedata;
   input  logic  [(MM_SYMBOL_W * MM_NUMSYMBOLS)-1:0 ]  m_readdata;
   output logic                                        m_write;         
   output logic                                        m_read;
   output logic  [MM_ADDRESS_W-1:0                  ]  m_address;
   output logic  [MM_NUMSYMBOLS-1:0                 ]  m_byteenable;    
   output logic  [MM_BURSTCOUNT_W-1:0               ]  m_burstcount;
   input  logic  [MM_READRESPONSE_W-1:0             ]  m_readresponse;

  import avalon_utilities_pkg::*;
  import avalon_mm_pkg::*;
  import hutil_pkg::*;

  logic [1:0] avm_response;
  
altera_avalon_mm_master_bfm#(
     .AV_ADDRESS_W               (MM_ADDRESS_W),
     .AV_SYMBOL_W                (MM_SYMBOL_W ),           
     .AV_NUMSYMBOLS              (MM_NUMSYMBOLS),           
     .AV_BURSTCOUNT_W            (MM_BURSTCOUNT_W) ,
     .AV_READRESPONSE_W          (MM_READRESPONSE_W) ,
     .AV_WRITERESPONSE_W         (MM_WRITERESPONSE_W) ,    
     .USE_BEGIN_TRANSFER         (MM_BEGIN_TRANSFER) ,            
     .USE_BEGIN_BURST_TRANSFER   (MM_BEGIN_BURST_TRANSFER) ,             
     .USE_READRESPONSE           (MM_READRESPONSE),
     .USE_BURSTCOUNT             (MM_USE_BURSTCOUNT))

//avalon mm master bfm instantiation
u_avalon_mm_master_bfm (
         . clk                          (clk), 
         . reset                        (!rst_n), 
         . avm_clken                    (),                        
         . avm_waitrequest              (m_waitrequest),       
         . avm_write                    (m_write),           
         . avm_read                     (m_read),        
         . avm_address                  (m_address),           
         . avm_byteenable               (m_byteenable),              
         . avm_burstcount               (m_burstcount),              
         . avm_beginbursttransfer       (),               
         . avm_begintransfer            (),                 
         . avm_writedata                (m_writedata),                
         . avm_readdata                 (m_readdata),             
         . avm_readdatavalid            (m_readdatavalid),                
         . avm_arbiterlock              (),                 
         . avm_lock                     (),               
         . avm_debugaccess              (),                      
         . avm_transactionid            (),                       
         . avm_readresponse             (),                  
         . avm_readid                   (8'b0),
         . avm_writeresponserequest     (),                 
         . avm_writeresponsevalid       (1'b0),                
         . avm_writeresponse            (1'b0),    
         . avm_writeid                  (8'b0),
         . avm_response                 (avm_response)
         );
         
  assign avm_response[0] = 1'b0;
  assign avm_response[1] = m_readresponse;

//Task used to initiate a Write or a Read Burst transaction
//For a write transaction it also takes in the Write Data
//For a read transaction it waits till the read burst is completed
task read_write_cmd;
  //local parameters declarations
  input  Request_t                                rd_wr_req;           
  input  [MM_ADDRESS_W- 1 : 0]                    rd_wr_addr;
  input  [MM_NUMSYMBOLS - 1 : 0]                  rd_wr_byte_en;
  input  bit [MM_BURSTCOUNT_W-1:0]                rd_wr_burstcnt;
  input  int                                      rd_wr_index;
  input  [(MM_SYMBOL_W * MM_NUMSYMBOLS) - 1 : 0 ] wr_data;
   
  begin
    if (rd_wr_index == 0) begin
      u_avalon_mm_master_bfm.set_command_request(rd_wr_req);
      $display("%m %d %t request is ",rd_wr_req, $stime);
      u_avalon_mm_master_bfm.set_command_address(rd_wr_addr);
      $display("%m %d %t address ",rd_wr_addr, $stime);
      if (MM_USE_BURSTCOUNT)begin
        u_avalon_mm_master_bfm.set_command_burst_count(rd_wr_burstcnt);
        $display("%m %d %t burstcount" , rd_wr_burstcnt, $stime);
        u_avalon_mm_master_bfm.set_command_burst_size(rd_wr_burstcnt);
        $display("%m %d %t burstsize" , rd_wr_burstcnt, $stime);
      end
      else 
        u_avalon_mm_master_bfm.set_command_burst_count(1);
        $display("%m %d %t burstcount",rd_wr_burstcnt, $stime);
    end
    u_avalon_mm_master_bfm.set_command_byte_enable(rd_wr_byte_en,rd_wr_index);
    $display("byteenable is %h" ,rd_wr_byte_en);
    if (rd_wr_req == REQ_WRITE) 
      u_avalon_mm_master_bfm.set_command_data(wr_data,rd_wr_index);
      $display("%m %h %t packet data ",wr_data, $stime);
      $display("%m %d %t index ",rd_wr_index, $stime);
    if (rd_wr_index == (rd_wr_burstcnt - 1) | (rd_wr_req == REQ_READ)) begin
      u_avalon_mm_master_bfm.push_command();
      $display("command is pushed into descriptor ");
      @u_avalon_mm_master_bfm.signal_command_issued;
      $display("signal_command_issued ");
      if ((rd_wr_req == REQ_WRITE)) begin
        @u_avalon_mm_master_bfm.signal_write_response_complete
        u_avalon_mm_master_bfm.pop_response();
        $display("in write response loop");
      end 
      if (rd_wr_req == REQ_READ) begin
        @u_avalon_mm_master_bfm.signal_read_response_complete;
        u_avalon_mm_master_bfm.pop_response();
        $display("in read response loop");
      end
    end
  end 
endtask 


//Task that reads the previously completed Read Transaction data
//Assumes that the read response is already received 
task read_data;
  //local parameters declarations
  input  int                                      rd_index;
  output [(MM_SYMBOL_W * MM_NUMSYMBOLS) - 1 : 0 ] rd_data;
  output [MM_READRESPONSE_W-1:0             ]     rd_resp;
   
  rd_data = u_avalon_mm_master_bfm.get_response_data(rd_index);
  rd_resp = u_avalon_mm_master_bfm.get_response_read_response(rd_index);
endtask
endmodule
