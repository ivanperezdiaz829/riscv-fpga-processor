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


// $File: //acds/rel/13.1/ip/sopc/components/verification/altera_avalon_interrupt_sink/altera_avalon_interrupt_sink_api_wrapper.sv $
// $Revision: #1 $
// $Date: 2013/08/11 $
// $Author: swbranch $
//------------------------------------------------------------------------------
// This wrapper transforms API method call and return streaming ports into
// cross module function/task call references in the actual BFM instance.

`timescale 1ns / 1ns

// synthesis translate_off
import verbosity_pkg::*;
// synthesis translate_on

module altera_avalon_interrupt_sink_api_wrapper (
					       	 api_clk, 
				       	     api_reset,  
				       	       
					       	 api_call_method,
					       	 api_call_data,
					       	 api_call_valid,
					       
					       	 api_return_method,
					       	 api_return_valid,
					       	 api_return_data,

					       	 av_clk,
                             av_reset,
				       
                             irq    
						 );
                         
   parameter AV_IRQ_W = 1;   
     
   // =head1 PINS

   // =head2 API Clock Interface    
   input               	  api_clk;
   input               	  api_reset;
   
   // =head2 API Call Streaming Interface
   input               	  api_call_method; // channel type
   input               	  api_call_data;   // not currently used
   input               	  api_call_valid;

   // =head2 API Return Streaming Interface   
   output              	  api_return_method;
   output [AV_IRQ_W-1:0]  api_return_data;            
   output              	  api_return_valid;
   
   // =head2 Clock Interface   
   input                   av_clk;
   input                   av_reset;	  

   // =head2 Avalon Interrupt Sink Interface   
   input [AV_IRQ_W-1:0]    irq;   

// synthesis translate_off
   import verbosity_pkg::*;
   
   typedef enum bit {IRQ_SINK_GET_IRQ   = 1'b0,
		     IRQ_SINK_CLEAR_IRQ = 1'b1
		     } MethodID;

   logic                 api_return_method;
   logic [AV_IRQ_W-1:0]  api_return_data;         
   logic                 api_return_valid;

   always @(posedge api_clk) begin
      if (api_reset) begin
	 api_return_valid  <= 1'b0;
	 api_return_data   <= 1'b0; 
	 api_return_method <= 1'b0;	       	    	 
      end else begin
	 api_return_valid <= api_call_valid;	 
	 if (api_call_valid) begin
	    case(api_call_method)
	      IRQ_SINK_GET_IRQ: begin
		 api_return_data <= sink.get_irq();
		 api_return_method <= api_call_method; 
	      end
	      IRQ_SINK_CLEAR_IRQ: begin
		 sink.clear_irq();
		 api_return_data <= 1'b1; 
		 api_return_method <= api_call_method; 
	      end
	      default: begin
		 api_return_data <= 1'bz; 
		 api_return_method <= 1'bz;
		 $sformat(message, "%m: invalid method call");
		 print(VERBOSITY_DEBUG, message);
	      end
	    endcase 
	 end else begin 
	    api_return_data <= 1'bz; 
	    api_return_method <= 1'bz;	    
	 end	 
      end
   end

   altera_avalon_interrupt_sink
   #(
     .AV_IRQ_W              (AV_IRQ_W)
     )      
   sink (
	.clk  		    (av_clk), 
	.reset		    (av_reset),
	.irq  		    (irq)
	);

// synthesis translate_on
endmodule 

