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


// $File: //acds/rel/13.1/ip/sopc/components/verification/altera_avalon_mm_master_bfm/altera_avalon_mm_master_bfm_api_wrapper.sv $
// $Revision: #1 $
// $Date: 2013/08/11 $
// $Author: swbranch $
//-----------------------------------------------------------------------------
// This wrapper transforms API method call and return streaming ports into
// cross module function/task call references in the actual BFM instance

`timescale 1ns / 1ns

module altera_avalon_mm_master_bfm_api_wrapper (
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
                                                
                                                avm_clk,
                                                avm_reset,
                              
                                                avm_clken,
                                                
                                                avm_waitrequest,    
                                                avm_write,          
                                                avm_read,
                                                avm_address,
                                                avm_byteenable,     
                                                avm_burstcount,
                                                avm_beginbursttransfer,
                                                avm_begintransfer,
                                                avm_writedata,
                                                avm_readdata,
                                                avm_readdatavalid,
                                                avm_arbiterlock,
                                                avm_lock,
                                                avm_debugaccess,
                                                
                                                avm_transactionid,
                                                avm_readresponse,
                                                avm_readid,
                                                avm_writeresponserequest,
                                                avm_writeresponsevalid,
                                                avm_writeresponse,
                                                avm_writeid
                                               );
   
   parameter AV_ADDRESS_W              = 32; 
   parameter AV_SYMBOL_W               = 8;  
   parameter AV_NUMSYMBOLS             = 4;  
   parameter AV_BURSTCOUNT_W           = 3;  
   parameter AV_READRESPONSE_W         = 8;
   parameter AV_WRITERESPONSE_W        = 8;

   parameter USE_READ                  = 1;  
   parameter USE_WRITE                 = 1;  
   parameter USE_ADDRESS               = 1;  
   parameter USE_BYTE_ENABLE           = 1;  
   parameter USE_BURSTCOUNT            = 0;  
   parameter USE_READ_DATA             = 1;  
   parameter USE_READ_DATA_VALID       = 1;  
   parameter USE_WRITE_DATA            = 1;  
   parameter USE_BEGIN_TRANSFER        = 0;  
   parameter USE_BEGIN_BURST_TRANSFER  = 0;  
   parameter USE_WAIT_REQUEST          = 1;  
   parameter USE_ARBITERLOCK           = 0;
   parameter USE_LOCK                  = 0;
   parameter USE_DEBUGACCESS           = 0;   
   parameter USE_TRANSACTIONID         = 0; 
   parameter USE_WRITERESPONSE         = 0; 
   parameter USE_READRESPONSE          = 0; 
   parameter USE_CLKEN                 = 0;
   
   parameter AV_FIX_READ_LATENCY       = 0;  
   parameter AV_MAX_PENDING_READS      = 0;
   parameter AV_CONSTANT_BURST_BEHAVIOR = 1;
   parameter AV_BURST_LINEWRAP         = 0;  
   parameter AV_BURST_BNDR_ONLY        = 0;  
   parameter REGISTER_WAITREQUEST      = 0;
   parameter AV_REGISTERINCOMINGSIGNALS = 0;
   parameter AV_READ_WAIT_TIME         = 0; 
   parameter AV_WRITE_WAIT_TIME        = 0;

   parameter API_CALL_DATA_W           = 64; // api_call_arg_max_width()
   parameter API_RETURN_DATA_W         = 64; // api_return_max_width()
   
   localparam MAX_BURST_SIZE           = 2 ** (AV_BURSTCOUNT_W-1);   
   localparam AV_DATA_W                = AV_SYMBOL_W * AV_NUMSYMBOLS;
   localparam AV_TRANSACTIONID_W       = 8;
   localparam API_METHOD_W             = 8;
   localparam API_EVENT_DATA_W         = 8;    
   
   // =cut
   // =head1 PINS

   // =head2 API Clock Interface 
   input                            api_clk;
   input                            api_reset;
   
   // =head2 API Call Streaming Interface
   input [API_METHOD_W-1:0]         api_call_method; 
   input [API_CALL_DATA_W-1:0]      api_call_data;   
   input                            api_call_valid;

   // =head2 API Return Streaming Interface   
   output [API_METHOD_W-1:0]        api_return_method; 
   output [API_RETURN_DATA_W-1:0]   api_return_data;         
   output                           api_return_valid;

   // =head2 API Event Streaming Interface   
   output [API_EVENT_DATA_W-1:0]    api_event_data;         
   output                           api_event_valid;
   
   // =head2 Clock Interface
   input                          avm_clk;
   input                          avm_reset;

   // =head2 Avalon Master Interface
   input                            avm_waitrequest;   
   input                            avm_readdatavalid; 
   input  [AV_DATA_W-1:0         ]  avm_readdata;
   output                           avm_write;         
   output                           avm_read;
   output [AV_ADDRESS_W-1:0      ]  avm_address;
   output [AV_NUMSYMBOLS-1:0     ]  avm_byteenable;    
   output [AV_BURSTCOUNT_W-1:0   ]  avm_burstcount;
   output                           avm_beginbursttransfer;
   output                           avm_begintransfer;   
   output [AV_DATA_W-1:0         ]  avm_writedata;
   output                           avm_arbiterlock;
   output                           avm_lock;
   output                           avm_debugaccess;   

   output [AV_TRANSACTIONID_W-1:0]  avm_transactionid;
   input  [AV_READRESPONSE_W-1:0 ]  avm_readresponse;
   input  [AV_TRANSACTIONID_W-1:0]  avm_readid;
   output                           avm_writeresponserequest;
   input                            avm_writeresponsevalid;
   input  [AV_WRITERESPONSE_W-1:0]  avm_writeresponse;
   input  [AV_TRANSACTIONID_W-1:0]  avm_writeid;
   
   output                           avm_clken;

// synthesis translate_off
   import verbosity_pkg::*;
   import avalon_mm_pkg::*;   

   typedef enum byte {MM_MSTR_SIGNAL_FATAL_ERROR       	= 0,
		      MM_MSTR_SIGNAL_RESPONSE_COMPLETE 	= 1, 
		      MM_MSTR_SIGNAL_COMMAND_ISSUED    	= 2,
		      MM_MSTR_SIGNAL_ALL_TRANS_COMPLETE = 3,
		      MM_MSTR_SIGNAL_RESERVED_4        	= 4,
		      MM_MSTR_SIGNAL_RESERVED_5        	= 5,
		      MM_MSTR_SIGNAL_RESERVED_6        	= 6,
		      MM_MSTR_SIGNAL_RESERVED_7        	= 7		      
		      } SignalID;


   typedef enum byte {MM_MSTR_INIT                     = 0,
		      MM_MSTR_SET_RESP_TIMEOUT         = 1,
		      MM_MSTR_SET_CMD_TIMEOUT          = 2,

		      MM_MSTR_ALL_TRANS_COMPLETE       = 3,
		      MM_MSTR_GET_CMD_ISSUE_QUEUE_SIZE = 4,
		      MM_MSTR_GET_CMD_PEND_QUEUE_SIZE  = 5,	   
		      MM_MSTR_GET_RESP_QUEUE_SIZE      = 6,  
		      MM_MSTR_PUSH_CMD                 = 7,
		      MM_MSTR_POP_RESP                 = 8,
		      
		      MM_MSTR_SET_CMD_DATA    	       = 9,
		      MM_MSTR_SET_CMD_ADDRESS 	       = 10,		      
		      MM_MSTR_SET_CMD_BYTE_ENABLE      = 11,
		      MM_MSTR_SET_CMD_BURST_COUNT      = 12,
		      MM_MSTR_SET_CMD_IDLE   	       = 13,
		      MM_MSTR_SET_CMD_REQUEST  	       = 14,
		      MM_MSTR_SET_CMD_RESERVED_1       = 15,

		      MM_MSTR_GET_RESP_REQUEST 	       = 16,		      
		      MM_MSTR_GET_RESP_DATA    	       = 17,
		      MM_MSTR_GET_RESP_ADDRESS         = 18, 
		      MM_MSTR_GET_RESP_BYTE_ENABLE     = 19,
		      MM_MSTR_GET_RESP_BURST_SIZE      = 20,  		      
		      MM_MSTR_GET_RESP_LATENCY         = 21,
		      MM_MSTR_GET_RESP_WAIT_TIME       = 22,

                      MM_MSTR_SET_CMD_INIT_LATENCY     = 23,
		      MM_MSTR_SET_CMD_BURST_SIZE       = 24
		     } MethodID;

   function int api_call_arg_max_width();
      static int arg_max_width = 0;
      int arg_widths[23];

      arg_widths[MM_MSTR_INIT                     ] = 0;
      arg_widths[MM_MSTR_SET_RESP_TIMEOUT         ] = 32;
      arg_widths[MM_MSTR_SET_CMD_TIMEOUT          ] = 32;

      arg_widths[MM_MSTR_ALL_TRANS_COMPLETE       ] = 0;
      arg_widths[MM_MSTR_GET_CMD_ISSUE_QUEUE_SIZE ] = 0;
      arg_widths[MM_MSTR_GET_CMD_PEND_QUEUE_SIZE  ] = 0;	   
      arg_widths[MM_MSTR_GET_RESP_QUEUE_SIZE      ] = 0;  
      arg_widths[MM_MSTR_PUSH_CMD                 ] = 0;
      arg_widths[MM_MSTR_POP_RESP                 ] = 0;
 
      arg_widths[MM_MSTR_SET_CMD_DATA    	  ] = AV_DATA_W + 32;
      arg_widths[MM_MSTR_SET_CMD_ADDRESS 	  ] = AV_ADDRESS_W;
      arg_widths[MM_MSTR_SET_CMD_BYTE_ENABLE      ] = AV_NUMSYMBOLS + 32;
      arg_widths[MM_MSTR_SET_CMD_BURST_COUNT      ] = AV_BURSTCOUNT_W;
      arg_widths[MM_MSTR_SET_CMD_IDLE   	  ] = 32 + 32;
      arg_widths[MM_MSTR_SET_CMD_REQUEST       	  ] = 32;

      arg_widths[MM_MSTR_GET_RESP_REQUEST 	  ] = 32;		      
      arg_widths[MM_MSTR_GET_RESP_DATA    	  ] = 32;
      arg_widths[MM_MSTR_GET_RESP_ADDRESS    	  ] = 0; 
      arg_widths[MM_MSTR_GET_RESP_BYTE_ENABLE     ] = 32;
      arg_widths[MM_MSTR_GET_RESP_BURST_SIZE      ] = 0;  		      
      arg_widths[MM_MSTR_GET_RESP_LATENCY         ] = 32;
      arg_widths[MM_MSTR_GET_RESP_WAIT_TIME       ] = 32;

      arg_widths[MM_MSTR_SET_CMD_INIT_LATENCY     ] = 32;
      arg_widths[MM_MSTR_SET_CMD_BURST_SIZE       ] = 32;

      for (int i=0; i<23; i++) begin
	 arg_max_width = (arg_widths[i] > arg_max_width) ? 
			  arg_widths[i] : arg_max_width;
      end
      return arg_max_width;
   endfunction 

   function api_return_max_width();
      static int return_max_width = 0;
      int return_widths[23];

      return_widths[MM_MSTR_INIT                     ] = 0;
      return_widths[MM_MSTR_SET_RESP_TIMEOUT         ] = 0;
      return_widths[MM_MSTR_SET_CMD_TIMEOUT          ] = 0;

      return_widths[MM_MSTR_ALL_TRANS_COMPLETE       ] = 1;
      return_widths[MM_MSTR_GET_CMD_ISSUE_QUEUE_SIZE ] = 32;
      return_widths[MM_MSTR_GET_CMD_PEND_QUEUE_SIZE  ] = 32;	   
      return_widths[MM_MSTR_GET_RESP_QUEUE_SIZE      ] = 32;  
      return_widths[MM_MSTR_PUSH_CMD                 ] = 0;
      return_widths[MM_MSTR_POP_RESP                 ] = 0;
 
      return_widths[MM_MSTR_SET_CMD_DATA    	     ] = 0;
      return_widths[MM_MSTR_SET_CMD_ADDRESS 	     ] = 0;
      return_widths[MM_MSTR_SET_CMD_BYTE_ENABLE      ] = 0;
      return_widths[MM_MSTR_SET_CMD_BURST_COUNT      ] = 0;
      return_widths[MM_MSTR_SET_CMD_IDLE   	     ] = 0;
      return_widths[MM_MSTR_SET_CMD_REQUEST    	     ] = 0;
 
      return_widths[MM_MSTR_GET_RESP_REQUEST 	     ] = 32;		      
      return_widths[MM_MSTR_GET_RESP_DATA    	     ] = AV_DATA_W;
      return_widths[MM_MSTR_GET_RESP_ADDRESS         ] = AV_ADDRESS_W; 
      return_widths[MM_MSTR_GET_RESP_BYTE_ENABLE     ] = AV_NUMSYMBOLS;
      return_widths[MM_MSTR_GET_RESP_BURST_SIZE      ] = AV_BURSTCOUNT_W; 
      return_widths[MM_MSTR_GET_RESP_LATENCY         ] = 32;
      return_widths[MM_MSTR_GET_RESP_WAIT_TIME       ] = 32;    

      return_widths[MM_MSTR_SET_CMD_INIT_LATENCY     ] = 0;
      return_widths[MM_MSTR_SET_CMD_BURST_SIZE       ] = 0;      
      for (int i=0; i<23; i++) begin
	 return_max_width = (return_widths[i] > return_max_width) ? 
			  return_widths[i] : return_max_width;
      end
      return return_max_width;      
   endfunction
   
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

   always @(mstr.signal_fatal_error) 
      next_api_event_data[MM_MSTR_SIGNAL_FATAL_ERROR]       <= 1;
      
   always @(mstr.signal_response_complete) 
      next_api_event_data[MM_MSTR_SIGNAL_RESPONSE_COMPLETE] <= 1;

   always @(mstr.signal_command_issued) 
      next_api_event_data[MM_MSTR_SIGNAL_COMMAND_ISSUED]    <= 1;

   always @(mstr.signal_all_transactions_complete) 
      next_api_event_data[MM_MSTR_SIGNAL_ALL_TRANS_COMPLETE] <= 1;

   // toggle api_event on a signal event
   always @(mstr.signal_fatal_error or
	    mstr.signal_response_complete or
	    mstr.signal_command_issued or
	    mstr.signal_all_transactions_complete) begin
      next_api_event_valid <= 1;
   end
   
   always @(posedge api_clk or posedge api_reset) begin
      if (api_reset) begin
	 api_event_valid      <= 0;
	 api_event_data       <= 'z;
	 next_api_event_data  <= 'z;
	 next_api_event_valid <= 'z;	 	 
      end else begin
	 api_event_valid      <= next_api_event_valid;
	 api_event_data       <= next_api_event_data;
	 
	 next_api_event_data  <= 0;
	 next_api_event_valid <= 0;	 
      end
   end

   always @(posedge api_clk or posedge api_reset) begin
      if (api_reset) begin
	 api_return_valid  <= 0;
	 api_return_data   <= 'z; 
	 api_return_method <= 'z;	       	    	 
      end else begin
	 api_return_valid <= api_call_valid;	 

	 if (api_call_valid) begin
	    api_return_method <= api_call_method;	    

	    case(api_call_method)
              MM_MSTR_INIT                     : begin
  	         mstr.init();					     
		 api_return_data <= 1;    
	      end      		 
	      MM_MSTR_SET_RESP_TIMEOUT         : begin
		 mstr.set_response_timeout((api_call_data[31:0]));
		 api_return_data <= api_call_data[31:0];
	      end					     
	      MM_MSTR_SET_CMD_TIMEOUT          : begin 
		 mstr.set_response_timeout((api_call_data[31:0]));
		 api_return_data <= api_call_data[31:0];
	      end
	      MM_MSTR_ALL_TRANS_COMPLETE       : begin
  	         api_return_data <= mstr.all_transactions_complete();
	      end
	      MM_MSTR_GET_CMD_ISSUE_QUEUE_SIZE : begin
  	         api_return_data <= mstr.get_command_issued_queue_size();
	      end 
	      MM_MSTR_GET_CMD_PEND_QUEUE_SIZE  : begin
  	         api_return_data <= mstr.get_command_pending_queue_size();
	      end    					     
	      MM_MSTR_GET_RESP_QUEUE_SIZE      : begin
  	         api_return_data <= mstr.get_response_queue_size();
	      end 					     
	      MM_MSTR_PUSH_CMD                 : begin
 	         mstr.push_command();		
		 api_return_data <= 1;    			     
	      end      					     
	      MM_MSTR_POP_RESP                 : begin 
 	         mstr.pop_response();
		 api_return_data <= 1;    		 
	      end      			
	      MM_MSTR_SET_CMD_DATA    	       : begin
                 mstr.set_command_data(
                         (api_call_data[AV_DATA_W-1:0]),
		         (api_call_data[AV_DATA_W+31:AV_DATA_W]));
  	         api_return_data <= 1; 
	      end  					     
	      MM_MSTR_SET_CMD_ADDRESS 	       : begin
                 mstr.set_command_address(
                         (api_call_data[AV_ADDRESS_W-1:0]));
  	         api_return_data <= 1; 
	      end  
	      MM_MSTR_SET_CMD_BYTE_ENABLE      : begin
                 mstr.set_command_byte_enable(
                         (api_call_data[AV_DATA_W-1:0]),
		         (api_call_data[AV_DATA_W+31:AV_DATA_W]));
  	         api_return_data <= 1; 
	      end  					     
	      MM_MSTR_SET_CMD_BURST_COUNT      : begin
                 mstr.set_command_burst_count(
                         (api_call_data[AV_BURSTCOUNT_W-1:0]));
  	         api_return_data <= 1; 
	      end  					     
	      MM_MSTR_SET_CMD_IDLE   	       : begin
                 mstr.set_command_idle(
                         (api_call_data[31:0]),
		         (api_call_data[63:32]));
  	         api_return_data <= 1; 
	      end
	      MM_MSTR_SET_CMD_BURST_SIZE       : begin
                 mstr.set_command_burst_size((api_call_data[31:0]));
  	         api_return_data <= 1; 
	      end
	      MM_MSTR_SET_CMD_REQUEST  	       : begin
		 case(api_call_data[1:0]) 
		   2'b00: begin
                      mstr.set_command_request((REQ_READ));
  	              api_return_data <= 1; 		      
		   end
		   2'b01: begin
                      mstr.set_command_request((REQ_WRITE));
  	              api_return_data <= 1; 		      
		   end		   
		   default:  begin
		      $sformat(message, "%m: invalid transaction request");
  	              api_return_data <= 0; 		    
		   end
		 endcase
	      end  					     
	      MM_MSTR_GET_RESP_REQUEST 	       : begin
		 case(mstr.get_response_request()) 
		   REQ_READ: begin
  	              api_return_data <= 0; 			      
		   end
		   REQ_WRITE: begin
  	              api_return_data <= 1; 			      
		   end		   
		   default:  begin
		      $sformat(message, "%m: invalid transaction request");
		   end
		 endcase		 
	      end      					     
	      MM_MSTR_GET_RESP_DATA    	       : begin
  	         api_return_data[AV_DATA_W-1:0] <=  
		    mstr.get_response_data(api_call_data[31:0]); 
	      end      					     
	      MM_MSTR_GET_RESP_ADDRESS 	       : begin
  	         api_return_data[AV_ADDRESS_W-1:0] <= 
                    mstr.get_response_address(); 
	      end      					     
	      MM_MSTR_GET_RESP_BYTE_ENABLE     : begin
  	         api_return_data[AV_NUMSYMBOLS-1:0] <= 
                    mstr.get_response_byte_enable(api_call_data[31:0]); 
	      end      					     
	      MM_MSTR_GET_RESP_BURST_SIZE     : begin
  	         api_return_data[31:0] <= 
                    mstr.get_response_burst_size();
	      end      				
	      MM_MSTR_GET_RESP_LATENCY         : begin
  	         api_return_data <= 
                    mstr.get_response_latency(
                            (api_call_data[31:0])); 
	      end      					     
	      MM_MSTR_GET_RESP_WAIT_TIME      : begin
                 api_return_data <= 
                    mstr.get_response_wait_time(
                            (api_call_data[31:0]));
	      end
              MM_MSTR_SET_CMD_INIT_LATENCY     : begin
                 mstr.set_command_init_latency((api_call_data[31:0]));
  	         api_return_data <= 1; 
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
	 
   altera_avalon_mm_master_bfm
     #(
       .AV_ADDRESS_W                (AV_ADDRESS_W               ), 
       .AV_SYMBOL_W                 (AV_SYMBOL_W                ), 
       .AV_NUMSYMBOLS               (AV_NUMSYMBOLS              ), 
       .AV_BURSTCOUNT_W             (AV_BURSTCOUNT_W            ),
       .AV_READRESPONSE_W           (AV_READRESPONSE_W          ),
       .AV_WRITERESPONSE_W          (AV_WRITERESPONSE_W         ),
                                                               
       .USE_READ                    (USE_READ                   ), 
       .USE_WRITE                   (USE_WRITE                  ), 
       .USE_ADDRESS                 (USE_ADDRESS                ), 
       .USE_BYTE_ENABLE             (USE_BYTE_ENABLE            ), 
       .USE_BURSTCOUNT              (USE_BURSTCOUNT             ), 
       .USE_READ_DATA               (USE_READ_DATA              ), 
       .USE_READ_DATA_VALID         (USE_READ_DATA_VALID        ), 
       .USE_WRITE_DATA              (USE_WRITE_DATA             ), 
       .USE_BEGIN_TRANSFER          (USE_BEGIN_TRANSFER         ), 
       .USE_BEGIN_BURST_TRANSFER    (USE_BEGIN_BURST_TRANSFER   ), 
       .USE_WAIT_REQUEST            (USE_WAIT_REQUEST           ), 
       .USE_ARBITERLOCK             (USE_ARBITERLOCK            ),
       .USE_LOCK                    (USE_LOCK                   ),
       .USE_TRANSACTIONID           (USE_TRANSACTIONID          ),
       .USE_WRITERESPONSE           (USE_WRITERESPONSE          ),
       .USE_READRESPONSE            (USE_READRESPONSE           ),
       .USE_CLKEN                   (USE_CLKEN                  ),
                                                              
       .AV_FIX_READ_LATENCY         (AV_FIX_READ_LATENCY        ), 
       .AV_MAX_PENDING_READS        (AV_MAX_PENDING_READS       ),
       .AV_READ_WAIT_TIME           (AV_READ_WAIT_TIME          ),
       .AV_WRITE_WAIT_TIME          (AV_WRITE_WAIT_TIME         ),
                                                               
       .AV_CONSTANT_BURST_BEHAVIOR  (AV_CONSTANT_BURST_BEHAVIOR ), 
       .AV_BURST_LINEWRAP           (AV_BURST_LINEWRAP          ), 
       .AV_BURST_BNDR_ONLY          (AV_BURST_BNDR_ONLY         ), 
       .USE_DEBUGACCESS             (USE_DEBUGACCESS            ),
       .AV_REGISTERINCOMINGSIGNALS  (AV_REGISTERINCOMINGSIGNALS ),
       .REGISTER_WAITREQUEST        (REGISTER_WAITREQUEST       )
      )
   mstr (
          .clk                      (avm_clk                 ),
          .reset                    (avm_reset               ),    
          .avm_clken                (avm_clken               ),

          .avm_waitrequest          (avm_waitrequest         ),
          .avm_write                (avm_write               ),
          .avm_read                 (avm_read                ),
          .avm_address              (avm_address             ), 
          .avm_byteenable           (avm_byteenable          ),
          .avm_writedata            (avm_writedata           ),
          .avm_burstcount           (avm_burstcount          ),     
          .avm_beginbursttransfer   (avm_beginbursttransfer  ),
          .avm_begintransfer        (avm_begintransfer       ),
          .avm_readdata             (avm_readdata            ),
          .avm_readdatavalid        (avm_readdatavalid       ),
          .avm_arbiterlock          (avm_arbiterlock         ),
          .avm_lock                 (avm_lock                ),
          .avm_debugaccess          (avm_debugaccess         ),  

          .avm_transactionid        (avm_transactionid       ),  
          .avm_readresponse         (avm_readresponse        ),
          .avm_readid               (avm_readid              ),
          .avm_writeresponserequest (avm_writeresponserequest),
          .avm_writeresponsevalid   (avm_writeresponsevalid  ),
          .avm_writeresponse        (avm_writeresponse       ),
          .avm_writeid              (avm_writeid             )
          );
   
// synthesis translate_on
endmodule 

