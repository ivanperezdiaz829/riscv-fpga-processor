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


// -------------------------------------------------------------------------
// -------------------------------------------------------------------------
//
// Revision Control Information
//
// $RCSfile: altera_tse_timing_adapter_fifo8.v,v $
// $Source: /ipbu/cvs/sio/projects/TriSpeedEthernet/src/RTL/MAC/mac/timing_adapter/altera_tse_timing_adapter_fifo8.v,v $
//
// $Revision: #1 $
// $Date: 2013/08/11 $
// Check in by : $Author: swbranch $
// Author      : SKNg
//
// Project     : Triple Speed Ethernet - 10/100/1000 MAC
//
// Description : SIMULATION ONLY
//
// simple atlantic fifo FOR 8BIT IMPLEMENTATION

// 
// ALTERA Confidential and Proprietary
// Copyright 2006 (c) Altera Corporation
// All rights reserved
//
// -------------------------------------------------------------------------
// -------------------------------------------------------------------------

module loopback_adapter_fifo (
   output reg  [11: 0] fill_level ,  //OUTPUT : 'TIMING ADAPTER' FIFO FILL LEVEL
    
   // Interface: clock
   input              clk,           //INPUT  : CLK
   input              reset,         //INPUT  : Asynchronous ACTIVE LOW Reset
   // Interface: data_in
   output reg         in_ready,      //OUTPUT : 'TIMING ADAPTER' READYNESS TO ACCEPT DATA FROM 'MAC'
   input              in_valid,      //INPUT  : 'MAC TO TIMING ADAPTER' DATA VALID
   input      [10: 0] in_data,       //INPUT  : 'MAC TO TIMING ADAPTER' DATA
   // Interface: data_out
   input              out_ready,     //INPUT  : 'APPLICATION' READYNESS TO ACCEPT DATA FROM 'TIMING ADAPTER'
   output reg         out_valid,     //OUTPUT : 'TIMING ADAPTER TO APPLICATION' DATA VALID
   output reg [10: 0] out_data       //OUTPUT : 'TIMING ADAPTER TO APPLICATION' DATA
);

   // ---------------------------------------------------------------------
   //| Internal Parameters
   // ---------------------------------------------------------------------
   parameter DEPTH = 2048;
   parameter DATA_WIDTH = 11;
   parameter ADDR_WIDTH = 11;
           
   // ---------------------------------------------------------------------
   //| Signals
   // ---------------------------------------------------------------------
   reg [ADDR_WIDTH-1:0] wr_addr;
   reg [ADDR_WIDTH-1:0] rd_addr;
   reg [ADDR_WIDTH-1:0] next_wr_addr;
   reg [ADDR_WIDTH-1:0] next_rd_addr;
   reg [ADDR_WIDTH-1:0] mem_rd_addr;
   reg [DATA_WIDTH-1:0] mem[DEPTH-1:0];
   reg          empty;
   reg          full;
   reg out_ready_vector;
   integer j;
   reg enable_reading;

   // ---------------------------------------------------------------------
   //| FIFO Status
   // ---------------------------------------------------------------------
   always @(out_ready or wr_addr or rd_addr or full) 
   begin
//      out_valid = !empty;
      out_ready_vector = out_ready;
      in_ready  = !full;
      next_wr_addr = wr_addr + 1;
      next_rd_addr = rd_addr + 1;
        fill_level[ADDR_WIDTH-1:0] = wr_addr - rd_addr;
        fill_level[ADDR_WIDTH] = 0;

        if (full)
           fill_level = DEPTH;

   end
   
   // ---------------------------------------------------------------------
   //| Manage Pointers
   // ---------------------------------------------------------------------
   always @ (posedge reset or posedge clk)
   begin
	  if (reset)
	   begin
		 enable_reading <= 1'b0;
       end
	  else
	   begin
		 if (empty)
		  begin
			enable_reading <= 1'b0;
          end
         else
		  begin
          if (in_data[1] & in_valid)
           enable_reading <= 1'b1;
          end    
       end
   end


   always @ (posedge reset or posedge clk) 
   begin
      if (reset) 
        begin
         wr_addr  <= 0;
         rd_addr  <= 0;
         empty    <= 1;
         rd_addr  <= 0;
         full     <= 0;
         out_valid<= 0;
        end 
    else 
      begin
         out_valid <= enable_reading;  

         if (in_ready && in_valid) 
          begin
            wr_addr <= next_wr_addr;
            empty   <= 0;
          if (next_wr_addr == rd_addr)
            full <= 1;
          end
     
         if (out_ready_vector && out_valid) 
          begin
           rd_addr <= next_rd_addr;
           full    <= 0;
               if (next_rd_addr == wr_addr) 
                begin
                 empty <= 1;
                 out_valid <= 0;
                end
          end
     
         if (out_ready_vector && out_valid && in_ready && in_valid) 
          begin
           full  <= full;
           empty <= empty;
          end
      end
   end // always @ (posedge reset, posedge clk)
   

   always @ (rd_addr or out_ready or out_valid or next_rd_addr) 
   begin
      mem_rd_addr = rd_addr;
      if (out_ready && out_valid) 
      begin
        mem_rd_addr = next_rd_addr;
      end
   end
   

   // ---------------------------------------------------------------------
   //| Infer Memory
   // ---------------------------------------------------------------------
   always @ (posedge reset or posedge clk) 
   begin
      if (reset)
	   begin

		   for (j = 0; j < DEPTH; j=j+1)
		    begin
		     mem[j] <= 11'h0;
			end
	   end
      else
       begin 
         if (in_ready && in_valid)
           mem[wr_addr] <= in_data;
       end
       
       out_data = mem[mem_rd_addr];
   end
   
endmodule // loopback_adapter_fifo


