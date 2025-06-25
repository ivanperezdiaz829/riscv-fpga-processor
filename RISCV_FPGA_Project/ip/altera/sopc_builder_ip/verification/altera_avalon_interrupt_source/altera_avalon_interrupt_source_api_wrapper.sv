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


// $File: //acds/rel/13.1/ip/sopc/components/verification/altera_avalon_interrupt_source/altera_avalon_interrupt_source_api_wrapper.sv $
// $Revision: #1 $
// $Date: 2013/08/11 $
// $Author: swbranch $
//------------------------------------------------------------------------------
// This wrapper transforms API method call and return streaming ports into
// cross module function/task call references in the actual BFM instance

module altera_avalon_interrupt_source_api_wrapper (
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
   
   // =head1 PINS
   // =head1 PARAMETERS
   parameter ASYNCHRONOUS_INTERRUPT = 0;  // asynchronous irq signal to its associated clock
   parameter AV_IRQ_W               = 1;  // width of the interrupt signal
   
   localparam API_CALL_DATA_W       = 5;
   localparam API_RETURN_DATA_W     = 5;
   
   // =head2 API Clock Interface 
   input               	            api_clk;
   input               	            api_reset;
   
   // =head2 API Call Streaming Interface
   input               	            api_call_method; // channel type
   input [API_CALL_DATA_W-1:0]      api_call_data;   // set which irq bit
   input                            api_call_valid;

   // =head2 API Return Streaming Interface   
   output              	            api_return_method;
   output [API_RETURN_DATA_W-1:0]   api_return_data;         
   output              	            api_return_valid;
   
   // =head2 Avalon Clock Interface   
   input                            av_clk;
   input                            av_reset;

   // =head2 Avalon Interrupt Source Interface   
   output [AV_IRQ_W-1:0]            irq; 

// synthesis translate_off
   import verbosity_pkg::*;   

   typedef enum bit {IRQ_SRC_SET_IRQ   = 1'b0,
		     IRQ_SRC_CLEAR_IRQ = 1'b1
		     } MethodID;

   logic                            api_return_method;
   logic [API_RETURN_DATA_W-1:0]    api_return_data;         
   logic                            api_return_valid;

   always @(posedge api_clk) begin
      if (api_reset) begin
	 api_return_valid  <= 0;
	 api_return_data   <= 0; 
	 api_return_method <= 0;	       	    	 
      end else begin
	 api_return_valid <= api_call_valid;	 
	 if (api_call_valid) begin
	    case(api_call_method)
	      IRQ_SRC_SET_IRQ: begin
		 src.set_irq(api_call_data);
		 api_return_data <= 1; 			 
		 api_return_method <= api_call_method; 	 
	      end
	      IRQ_SRC_CLEAR_IRQ: begin
		 src.clear_irq(api_call_data);
		 api_return_data <= 1;
		 api_return_method <= api_call_method; 	 
	      end
	      default: begin
		 api_return_data <= 'z; 
		 api_return_method <= 'z;
		 $sformat(message, "%m: invalid method call");
		 print(VERBOSITY_DEBUG, message);	      		 
	      end
	    endcase 
	 end else begin 
	    api_return_data <= 'z; 
	    api_return_method <= 'z;	    
	 end
      end
   end
   
   altera_avalon_interrupt_source #(
   .ASYNCHRONOUS_INTERRUPT    (ASYNCHRONOUS_INTERRUPT),
   .AV_IRQ_W           (AV_IRQ_W)
   )
   src (
	.clk  		    (av_clk), 
	.reset		    (av_reset),
	.irq  		    (irq)
	);

// synthesis translate_on
endmodule 

