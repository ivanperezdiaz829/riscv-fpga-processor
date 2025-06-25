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


// $File: //acds/rel/13.1/ip/sopc/components/verification/altera_avalon_st_source_bfm/altera_avalon_st_source_bfm_api_wrapper.sv $
// $Revision: #1 $
// $Date: 2013/08/11 $
// $Author: swbranch $
//------------------------------------------------------------------------------
// This wrapper transforms API method call and return streaming ports into
// cross module function/task call references in the actual BFM instance
`timescale 1ns / 1ns

module altera_avalon_st_source_bfm_api_wrapper (
					    api_clk,
				       api_reset,
				       	    
					    api_call_method,
					    api_call_data,
					    api_call_valid,
					    
					    api_return_method,
					    api_return_valid,
					    api_return_data,

					    api_event_valid,
					    api_event_data,

					    av_clk,
					    av_reset,

			     	    	    src_data,
			     	    	    src_channel,
			     	    	    src_valid,
			     	    	    src_startofpacket,
			     	    	    src_endofpacket,
			     	    	    src_error,
			     	    	    src_empty,
			     	    	    src_ready
					    );

   // =head1 PARAMETERS    
   parameter ST_SYMBOL_W       = 8;   
   parameter ST_NUMSYMBOLS     = 4;   
   parameter ST_CHANNEL_W      = 0;   
   parameter ST_ERROR_W        = 0;   
   parameter ST_EMPTY_W        = 0;

   parameter ST_READY_LATENCY  = 0;   
   parameter ST_MAX_CHANNELS   = 1;
   
   parameter USE_PACKET        = 0;   
   parameter USE_CHANNEL       = 0;   
   parameter USE_ERROR         = 0;   
   parameter USE_READY         = 1;   
   parameter USE_VALID         = 1;       
   parameter USE_EMPTY         = 0;    

   parameter API_CALL_DATA_W   = 32;
   parameter API_RETURN_DATA_W = 32; 
   
   localparam ST_DATA_W         = ST_SYMBOL_W * ST_NUMSYMBOLS;   
   localparam API_METHOD_W      = 8;
   localparam API_EVENT_DATA_W  = 8;    
   
   // =head1 PINS

   // =head2 API Clock Interface 
   input               	  	    api_clk;
   input               	  	    api_reset;
   
   // =head2 API Call Streaming Interface
   input [API_METHOD_W-1:0]  	    api_call_method; // channel type
   input [API_CALL_DATA_W-1:0] 	    api_call_data;   // not currently used
   input               	  	    api_call_valid;

   // =head2 API Return Streaming Interface   
   output [API_METHOD_W-1:0]  	    api_return_method; // channel type   
   output [API_RETURN_DATA_W-1:0]   api_return_data;         
   output              	  	    api_return_valid;

   // =head2 API Event Streaming Interface   
   output [API_EVENT_DATA_W-1:0]    api_event_data;         
   output              	  	    api_event_valid;
   
   // =head2 Avalon Clock Interface   
   input                  	    av_clk;
   input                  	    av_reset;

   // =head2 Avalon Streaming Source Interface
   output [lindex(ST_DATA_W)   : 0] src_data;
   output [lindex(ST_CHANNEL_W): 0] src_channel;
   output                           src_valid;
   output                      	    src_startofpacket;
   output                      	    src_endofpacket;
   output [lindex(ST_ERROR_W)   :0] src_error;
   output [lindex(ST_EMPTY_W)   :0] src_empty;    
   input                            src_ready;
   
   function int lindex;
      // returns the left index for a vector having a declared width 
      // when width is 0, then the left index is set to 0 rather than -1
      input int width;
      lindex = (width > 0) ? (width-1) : 0;
   endfunction 

// synthesis translate_off
   import verbosity_pkg::*;   

   typedef enum byte {ST_SRC_SIGNAL_READY     	     = 0,
		      ST_SRC_SIGNAL_NOT_READY 	     = 1, 
		      ST_SRC_SIGNAL_TRANS_COMPLETE   = 2,
		      ST_SRC_SIGNAL_DRIVING_TRANS    = 3,
		      ST_SRC_SIGNAL_RESERVED_4       = 4,
		      ST_SRC_SIGNAL_RESERVED_5       = 5,
		      ST_SRC_SIGNAL_RESERVED_6       = 6,
		      ST_SRC_SIGNAL_RESERVED_7       = 7		      
		      } SignalID;
   
   typedef enum byte {ST_SRC_INIT                    = 0,
		      ST_SRC_SET_RESP_TIMEOUT        = 1,		      
		      ST_SRC_PUSH_TRANS              = 2,
		      ST_SRC_GET_TRANS_QUEUE_SIZE    = 3,		      
		      ST_SRC_GET_RESP_QUEUE_SIZE     = 4, 		      
		      ST_SRC_SET_TRANS_DATA    	     = 5,
		      ST_SRC_SET_TRANS_CHANNEL 	     = 6,		      
		      ST_SRC_SET_TRANS_IDLES   	     = 7,   
		      ST_SRC_SET_TRANS_SOP     	     = 8,
		      ST_SRC_SET_TRANS_EOP     	     = 9,		      
		      ST_SRC_SET_TRANS_ERROR   	     = 10,		      
		      ST_SRC_SET_TRANS_EMPTY   	     = 11,
		      ST_SRC_POP_RESP          	     = 12,
		      ST_SRC_GET_RESP_LATENCY  	     = 13,   		      
		      ST_SRC_GET_SRC_READY           = 14,
		      ST_SRC_GET_SRC_TRANS_COMPLETE  = 15
		     } MethodID;


   logic [API_METHOD_W-1:0]  	   api_return_method;
   logic [API_RETURN_DATA_W-1:0]   api_return_data;         
   logic              	  	   api_return_valid;

   logic [API_EVENT_DATA_W-1:0]    api_event_data;         
   logic              	  	   api_event_valid;
   logic [API_EVENT_DATA_W-1:0]    next_api_event_data;   
   logic 			   next_api_event_valid;

   // The BFM component only generates public event signals
   // on the posedge of clk.
   // We detect sucy events as they occur and set a '1'
   // in the assigned bit slot of the api_event_data 
   // vector. 
   // The client examines the api_event_data bus when
   // api_event_valid is high. Any bit which has changed
   // value from 0 to 1 or vice versa from the previous
   // valid cycle indicates a corresponding event.

   always @(src.signal_src_ready) 
      next_api_event_data[ST_SRC_SIGNAL_READY]     <= 1;
      
   always @(src.signal_src_not_ready) 
      next_api_event_data[ST_SRC_SIGNAL_NOT_READY] <= 1;

   always @(src.signal_src_transaction_complete) 
      next_api_event_data[ST_SRC_SIGNAL_TRANS_COMPLETE] <= 1;

   always @(src.signal_src_driving_transaction) 
      next_api_event_data[ST_SRC_SIGNAL_DRIVING_TRANS]  <= 1;

   // toggle api_event on a signal event
   always @(src.signal_src_ready or
	    src.signal_src_not_ready or
	    src.signal_src_transaction_complete or
	    src.signal_src_driving_transaction) begin
      next_api_event_valid <= 1;
   end
   
   always @(posedge api_clk) begin
      if (api_reset) begin
	 api_event_valid      <= 0;
	 api_event_data       <= 0;
	 next_api_event_data  <= 0;
	 next_api_event_valid <= 0;	 	 
      end else begin
	 api_event_valid      <= next_api_event_valid;
	 api_event_data       <= next_api_event_data;
	 
	 next_api_event_data  <= 0;
	 next_api_event_valid <= 0;	 
      end
   end

   always @(posedge api_clk) begin
      if (api_reset) begin
	 api_return_valid  <= 0;
	 api_return_data   <= 0; 
	 api_return_method <= 0;	       	    	 
      end else begin
	 api_return_valid <= api_call_valid;	 

	 if (api_call_valid) begin
	    api_return_method <= api_call_method;	    

	    case(api_call_method)
	      ST_SRC_GET_SRC_READY: begin
		 api_return_data[0] <= src.get_src_ready();    
	      end      
	      ST_SRC_GET_SRC_TRANS_COMPLETE: begin
		 api_return_data[0] <= src.get_src_transaction_complete();
	      end      		 
	      ST_SRC_SET_RESP_TIMEOUT: begin
		 src.set_response_timeout(api_call_data[31:0]);
		 api_return_data <= 1'b1; 		 
 	      end      
	      ST_SRC_INIT: begin
		 src.init();
		 api_return_data <= 1'b1;  
	      end      		 
	      ST_SRC_PUSH_TRANS: begin
		 src.push_transaction();
		 api_return_data <= 1'b1;  		 
	      end      		 
	      ST_SRC_GET_TRANS_QUEUE_SIZE: begin
		 api_return_data[31:0] <= src.get_transaction_queue_size();
	      end      		 
	      ST_SRC_GET_RESP_QUEUE_SIZE: begin
		 api_return_data[31:0] <= src.get_response_queue_size();  
	      end      		 
	      ST_SRC_SET_TRANS_DATA: begin
		 src.set_transaction_data(api_call_data[ST_DATA_W-1:0]);
		 api_return_data <= 1'b1;  		 
	      end      		 
	      ST_SRC_SET_TRANS_CHANNEL: begin
		 if (USE_CHANNEL) begin
		    if (ST_CHANNEL_W > 0) begin
		       src.set_transaction_channel(api_call_data[ST_CHANNEL_W-1:0]);
		       api_return_data <= 1'b1;   		
		    end else begin
		       $sformat(message, 
		        "%m: invalid call: set_transaction_channel. ST_CHANNEL_W=0");
		    print(VERBOSITY_WARNING, message);
		    src.set_transaction_channel(0);
		    api_return_data <= 1'b0;				       
		    end
		 end else begin
		    $sformat(message, 
                      "%m: invalid call: set_transaction_channel. USE_CHANNEL=0");
		    print(VERBOSITY_WARNING, message);
		    src.set_transaction_channel('x);
		    api_return_data <= 1'b0;		    		    
		 end
	      end      		 
	      ST_SRC_SET_TRANS_IDLES: begin
		 src.set_transaction_idles(api_call_data[31:0]);
		 api_return_data <= 1'b1;   		 		 
	      end      		 
	      ST_SRC_SET_TRANS_SOP: begin
		 if (USE_PACKET) begin		 
		    src.set_transaction_sop(api_call_data[0]);
		    api_return_data <= 1'b1;
		 end else begin
		    $sformat(message, 
                      "%m: invalid call: set_transaction_sop. USE_PACKET=0");
		    print(VERBOSITY_WARNING, message);
		    src.set_transaction_sop('x);
		    api_return_data <= 1'b0;		    		    
		 end
	      end      		 
	      ST_SRC_SET_TRANS_EOP: begin
		 if (USE_PACKET) begin		 		 
		    src.set_transaction_eop(api_call_data[0]);
		    api_return_data <= 1'b1;
		 end else begin
		    $sformat(message, 
                      "%m: invalid call: set_transaction_eop. USE_PACKET=0");
		    print(VERBOSITY_WARNING, message);
		    src.set_transaction_eop('x);
		    api_return_data <= 1'b0;		    		    
		 end
	      end      		 
	      ST_SRC_SET_TRANS_ERROR: begin
		 if (USE_ERROR) begin
		    if (ST_ERROR_W > 0) begin
		       src.set_transaction_error(api_call_data[ST_ERROR_W-1:0]);
		       api_return_data <= 1'b1;   		
		    end else begin
		       $sformat(message, 
			 "%m: invalid call: set_transaction_error. ST_ERROR_W=0");
		    print(VERBOSITY_WARNING, message);
		    src.set_transaction_error(0);
		    api_return_data <= 1'b0;				       
		    end
		 end else begin
		    $sformat(message, 
                      "%m: invalid call: set_transaction_error. USE_ERROR=0");
		    print(VERBOSITY_WARNING, message);
		    src.set_transaction_error('x);
		    api_return_data <= 1'b0;		    		    
		 end
	      end      		 
	      ST_SRC_SET_TRANS_EMPTY: begin
		 if (USE_EMPTY) begin
		    if (ST_EMPTY_W > 0) begin
		       src.set_transaction_empty(api_call_data[ST_EMPTY_W-1:0]);
		       api_return_data <= 1'b1;   		
		    end else begin
		       $sformat(message, 
			 "%m: invalid call: set_transaction_empty. ST_EMPTY_W=0");
		    print(VERBOSITY_WARNING, message);
		    src.set_transaction_empty(0);
		    api_return_data <= 1'b0;				       
		    end
		 end else begin
		    $sformat(message, 
                      "%m: invalid call: set_transaction_empty. USE_EMPTY=0");
		    print(VERBOSITY_WARNING, message);
		    src.set_transaction_empty('x);
		    api_return_data <= 1'b0;		    		    
		 end
	      end      		 
	      ST_SRC_POP_RESP: begin
		 src.pop_response();
		 api_return_data <= 1'b1;
	      end      		 
	      ST_SRC_GET_RESP_LATENCY: begin
		 api_return_data[31:0] <= src.get_response_latency();
	      end      		 
	      default: begin
		 api_return_data <= 1'b0; 
		 $sformat(message, "%m: invalid call: undefined method"); 
		 print(VERBOSITY_DEBUG, message);	      		 
	      end
	    endcase 
	 end else begin 
	    api_return_data <= 1'bz; 
	    api_return_method <= 1'bz;	    
	 end
      end
   end

  altera_avalon_st_source_bfm 
  # (
     .ST_SYMBOL_W       (ST_SYMBOL_W       ),
     .ST_NUMSYMBOLS     (ST_NUMSYMBOLS     ),
     .ST_CHANNEL_W      (ST_CHANNEL_W      ),
     .ST_ERROR_W        (ST_ERROR_W        ),
     .ST_EMPTY_W        (ST_EMPTY_W        ),
     								
     .ST_READY_LATENCY  (ST_READY_LATENCY  ),
     .ST_MAX_CHANNELS   (ST_MAX_CHANNELS   ),
     								
     .USE_PACKET        (USE_PACKET        ),
     .USE_CHANNEL       (USE_CHANNEL       ),
     .USE_ERROR         (USE_ERROR         ),
     .USE_READY         (USE_READY         ),
     .USE_VALID         (USE_VALID         ),
     .USE_EMPTY         (USE_EMPTY         )
     )
   src (
	.clk  		    (av_clk           ), 
	.reset		    (av_reset         ),

        .src_data	    (src_data         ),	     
	.src_channel        (src_channel      ),      
	.src_valid	    (src_valid        ), 	     
	.src_startofpacket  (src_startofpacket),
	.src_endofpacket    (src_endofpacket  ),  
	.src_error	    (src_error	      ),    	     
	.src_empty	    (src_empty	      ),	     
	.src_ready          (src_ready	      )
	);
       
// synthesis translate_on
endmodule 

