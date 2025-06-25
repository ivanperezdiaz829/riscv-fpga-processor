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


// $File: //acds/rel/13.1/ip/sopc/components/verification/altera_avalon_mm_slave_bfm/altera_avalon_mm_slave_bfm_api_wrapper.sv $
// $Revision: #1 $
// $Date: 2013/08/11 $
// $Author: swbranch $
//-----------------------------------------------------------------------------
// This wrapper transforms API method call and return streaming ports into
// cross module function/task call references in the actual BFM instance

`timescale 1ns / 1ns

module altera_avalon_mm_slave_bfm_api_wrapper (
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
                                                
                                                avs_clk,
                                                avs_reset,
                                                
                                                avs_clken,
                                                
                                                avs_waitrequest,
                                                avs_write,
                                                avs_read,
                                                avs_address,
                                                avs_byteenable,
                                                avs_burstcount,
                                                avs_beginbursttransfer,
                                                avs_begintransfer,
                                                avs_writedata,
                                                avs_readdata,
                                                avs_readdatavalid,
                                                avs_arbiterlock,
                                                avs_lock,
                                                avs_debugaccess,
                                                
                                                avs_transactionid,
                                                avs_readresponse,
                                                avs_readid,
                                                avs_writeresponserequest,
                                                avs_writeresponsevalid,
                                                avs_writeresponse,
                                                avs_writeid
                                               );
   
   parameter AV_ADDRESS_W             = 16; // Address width
   parameter AV_SYMBOL_W              = 8;  // Symbol width (default is byte)
   parameter AV_NUMSYMBOLS            = 4;  // Number of symbols per word
   parameter AV_BURSTCOUNT_W          = 3;  // Burst port width
   parameter AV_READRESPONSE_W        = 8;  // Read response port width
   parameter AV_WRITERESPONSE_W       = 8;  // Write response port width   

   parameter USE_READ                 = 1;  // Use read interface pin
   parameter USE_WRITE                = 1;  // Use write interface pin
   parameter USE_ADDRESS              = 1;  // Use address interface pinsp
   parameter USE_BYTE_ENABLE          = 1;  // Use byte_enable interface pins
   parameter USE_BURSTCOUNT           = 1;  // Use burstcount interface pin
   parameter USE_READ_DATA            = 1;  // Use readdata interface pin
   parameter USE_READ_DATA_VALID      = 1;  // Use readdatavalid interface pin
   parameter USE_WRITE_DATA           = 1;  // Use writedata interface pin
   parameter USE_BEGIN_TRANSFER       = 1;  // Use begintransfer interface pin
   parameter USE_BEGIN_BURST_TRANSFER = 1;  // Use beginbursttransfer interface pin    
   parameter USE_WAIT_REQUEST         = 1;  // Use waitrequest interface pin
   parameter USE_ARBITERLOCK          = 0;  // Use arbiterlock interface pin
   parameter USE_LOCK                 = 0;  // Use lock interface pin
   parameter USE_DEBUGACCESS          = 0;  // Use debugaccess interface pin
   parameter USE_TRANSACTIONID        = 0;  // Use transactionid interface pin
   parameter USE_WRITERESPONSE        = 0;  // Use write response interface pins
   parameter USE_READRESPONSE         = 0;  // Use read response interface pins 
   parameter USE_CLKEN                = 0;  // Use NTCM interface pins     

   parameter AV_FIX_READ_LATENCY      = 0;  // Fixed read latency (cycles)
   parameter AV_MAX_PENDING_READS     = 1;  // Max pending pipelined reads

   parameter AV_BURST_LINEWRAP        = 0;  // Line wrap bursts (y/n)
   parameter AV_BURST_BNDR_ONLY       = 0;  // Assert Addr alignment

   parameter AV_READ_WAIT_TIME        = 0;  // Fixed wait time cycles when
   parameter AV_WRITE_WAIT_TIME       = 0;  // USE_WAIT_REQUEST is 0
   parameter REGISTER_WAITREQUEST     = 0;  ///TODO-implementation pending
   parameter AV_REGISTERINCOMINGSIGNALS = 0;// Indicate that waitrequest is come from register 
   
   parameter API_CALL_DATA_W           = 64; // api_call_arg_max_width();
   parameter API_RETURN_DATA_W         = 64; // api_return_max_width();  
   
   localparam MAX_BURST_SIZE           = 2 ** (AV_BURSTCOUNT_W-1);   
   localparam AV_DATA_W                = AV_SYMBOL_W * AV_NUMSYMBOLS;

   localparam API_METHOD_W             = 8;
   localparam API_EVENT_DATA_W         = 8;    
   localparam AV_TRANSACTIONID_W       = 8; 
   
   // =cut
   // =head1 PINS

   // =head2 API Clock Interface 
   input               	  	  api_clk;
   input               	  	  api_reset;
   
   // =head2 API Call Streaming Interface
   input [API_METHOD_W-1:0]  	  api_call_method; // channel type
   input [API_CALL_DATA_W-1:0] 	  api_call_data;   // not currently used
   input               	  	  api_call_valid;

   // =head2 API Return Streaming Interface   
   output [API_METHOD_W-1:0]  	  api_return_method; // channel type   
   output [API_RETURN_DATA_W-1:0] api_return_data;         
   output              	  	  api_return_valid;

   // =head2 API Event Streaming Interface   
   output [API_EVENT_DATA_W-1:0]  api_event_data;         
   output              	  	  api_event_valid;
   
   // =head2 Clock Interface
   input                          avs_clk;
   input                          avs_reset;	     // active high

   // =head2 Avalon Master Interface
   output                                     avs_waitrequest;
   output                                     avs_readdatavalid;
   output [AV_DATA_W-1:0]                     avs_readdata;
   input                                      avs_write;
   input                                      avs_read;
   input  [AV_ADDRESS_W-1:0]                  avs_address;
   input  [AV_NUMSYMBOLS-1:0]                 avs_byteenable;
   input  [AV_BURSTCOUNT_W-1:0]               avs_burstcount;
   input                                      avs_beginbursttransfer;
   input                                      avs_begintransfer;   
   input  [AV_DATA_W-1:0]                     avs_writedata;
   input                                      avs_arbiterlock;
   input                                      avs_lock;
   input                                      avs_debugaccess;                  

   input  [AV_TRANSACTIONID_W-1: 0          ] avs_transactionid;
   output [AV_READRESPONSE_W-1: 0           ] avs_readresponse;
   output [AV_TRANSACTIONID_W-1: 0          ] avs_readid;
   input                                      avs_writeresponserequest;
   output                                     avs_writeresponsevalid;      
   output [AV_WRITERESPONSE_W-1: 0          ] avs_writeresponse;
   output [AV_TRANSACTIONID_W-1: 0          ] avs_writeid;
   
   input                                      avs_clken;

// synthesis translate_off
   import verbosity_pkg::*;
   import avalon_mm_pkg::*;   

   
   typedef enum byte {MM_SLV_SIGNAL_FATAL_ERROR                    = 0,
		      MM_SLV_SIGNAL_ERROR_EXCEED_MAX_PENDING_READS = 1, 
		      MM_SLV_SIGNAL_COMMAND_RECEIVED               = 2,
		      MM_SLV_SIGNAL_RESP_ISSUED                    = 3,
		      MM_SLV_SIGNAL_RESERVED_4        		   = 4, 
		      MM_SLV_SIGNAL_RESERVED_5        		   = 5,
		      MM_SLV_SIGNAL_RESERVED_6        		   = 6,
		      MM_SLV_SIGNAL_RESERVED_7        		   = 7	
		      } SignalID;

  
   typedef enum byte {MM_SLV_INIT                 = 0,
		      MM_SLV_SET_RESP_TIMEOUT     = 1,

		      MM_SLV_GET_CMD_QUEUE_SIZE   = 2,
		      MM_SLV_GET_RESP_QUEUE_SIZE  = 3,  
		      MM_SLV_PUSH_RESP            = 4,
		      MM_SLV_POP_CMD              = 5,
		      
		      MM_SLV_SET_RESP_DATA    	  = 6,
		      MM_SLV_SET_RESP_BURST_SIZE  = 7,
		      MM_SLV_SET_RESP_LATENCY     = 8,
		      
		      MM_SLV_SET_INTERFACE_WAIT_TIME    = 9,
		      MM_SLV_GET_CMD_REQUEST 	  = 10,		      
		      MM_SLV_GET_CMD_DATA    	  = 11,
		      MM_SLV_GET_CMD_ADDRESS      = 12, 
		      MM_SLV_GET_CMD_BYTE_ENABLE  = 13,
		      MM_SLV_GET_CMD_BURST_COUNT  = 14,
		      MM_SLV_GET_CMD_BURST_CYCLE  = 15
		     } MethodID;

   function int api_call_arg_max_width();
      static int arg_max_width = 0;
      int arg_widths[17];

      arg_widths[MM_SLV_INIT                 ] = 0; 
      arg_widths[MM_SLV_SET_RESP_TIMEOUT     ] = 32; 

      arg_widths[MM_SLV_GET_CMD_QUEUE_SIZE   ] = 0; 
      arg_widths[MM_SLV_GET_RESP_QUEUE_SIZE  ] = 0;   
      arg_widths[MM_SLV_PUSH_RESP            ] = 0; 
      arg_widths[MM_SLV_POP_CMD              ] = 0; 

      arg_widths[MM_SLV_SET_RESP_DATA        ] = AV_DATA_W + 32;
      arg_widths[MM_SLV_SET_RESP_BURST_SIZE  ] = 32; 
      arg_widths[MM_SLV_SET_RESP_LATENCY     ] = 32; 
      arg_widths[MM_SLV_SET_INTERFACE_WAIT_TIME] = 32; 

      arg_widths[MM_SLV_GET_CMD_REQUEST      ] = 0; 		      
      arg_widths[MM_SLV_GET_CMD_DATA         ] = 0; 
      arg_widths[MM_SLV_GET_CMD_ADDRESS      ] = 0;  
      arg_widths[MM_SLV_GET_CMD_BYTE_ENABLE  ] = 0; 
      arg_widths[MM_SLV_GET_CMD_BURST_COUNT  ] = 0; 
      arg_widths[MM_SLV_GET_CMD_BURST_CYCLE  ] = 0; 

      for (int i=0; i<23; i++) begin
	 arg_max_width = (arg_widths[i] > arg_max_width) ? 
			  arg_widths[i] : arg_max_width;
      end
      return arg_max_width;
   endfunction 

   function api_return_max_width();
      static int return_max_width = 0;
      int return_widths[17];

      return_widths[MM_SLV_INIT                 ] = 0; 
      return_widths[MM_SLV_SET_RESP_TIMEOUT     ] = 0; 

      return_widths[MM_SLV_GET_CMD_QUEUE_SIZE   ] = 32; 
      return_widths[MM_SLV_GET_RESP_QUEUE_SIZE  ] = 32;   
      return_widths[MM_SLV_PUSH_RESP            ] = 0; 
      return_widths[MM_SLV_POP_CMD              ] = 0; 

      return_widths[MM_SLV_SET_RESP_DATA        ] = 0;
      return_widths[MM_SLV_SET_RESP_BURST_SIZE  ] = 0;
      return_widths[MM_SLV_SET_RESP_LATENCY     ] = 32; 
      return_widths[MM_SLV_SET_INTERFACE_WAIT_TIME] = 32; 

      return_widths[MM_SLV_GET_CMD_REQUEST      ] = 32; 		      
      return_widths[MM_SLV_GET_CMD_DATA         ] = AV_DATA_W; 
      return_widths[MM_SLV_GET_CMD_ADDRESS      ] = AV_ADDRESS_W; 
      return_widths[MM_SLV_GET_CMD_BYTE_ENABLE  ] = AV_NUMSYMBOLS;
      return_widths[MM_SLV_GET_CMD_BURST_COUNT  ] = AV_BURSTCOUNT_W; 
      return_widths[MM_SLV_GET_CMD_BURST_CYCLE  ] = 32; 

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

   always @(slv.signal_fatal_error) 
      next_api_event_data[MM_SLV_SIGNAL_FATAL_ERROR]       <= 1;
      
   always @(slv.signal_error_exceed_max_pending_reads) 
      next_api_event_data[MM_SLV_SIGNAL_ERROR_EXCEED_MAX_PENDING_READS] <= 1;

   always @(slv.signal_command_received) 
      next_api_event_data[MM_SLV_SIGNAL_COMMAND_RECEIVED]    <= 1;

   always @(slv.signal_response_issued) 
      next_api_event_data[MM_SLV_SIGNAL_RESP_ISSUED] <= 1;

   // toggle api_event on a signal event

   always @(slv.signal_fatal_error or 
	    slv.signal_error_exceed_max_pending_reads or 
	    slv.signal_command_received or 
	    slv.signal_response_issued) begin
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
              MM_SLV_INIT                     : begin
  	         slv.init();					     
		 api_return_data <= 1;    
	      end      		 	      
	      MM_SLV_SET_RESP_TIMEOUT         : begin
                 slv.set_response_timeout(api_call_data[31:0]);	
		 api_return_data <= 1;
	      end
	      MM_SLV_GET_CMD_QUEUE_SIZE       : begin
		 api_return_data[31:0] <=    
                    slv.get_command_queue_size();
	      end      		 	      		 
	      MM_SLV_GET_RESP_QUEUE_SIZE      : begin
		 api_return_data[31:0] <=    		 
                    slv.get_response_queue_size();
	      end      		 	      		 
	      MM_SLV_PUSH_RESP                : begin
		 slv.push_response();
		 api_return_data[31:0] <= 1;
	      end      		 	      		 
	      MM_SLV_POP_CMD                  : begin
		 slv.pop_command();
		 api_return_data[31:0] <= 1;      
	      end      		 	      		 
	      
	      MM_SLV_SET_RESP_DATA    	      : begin
		 slv.set_response_data(api_call_data[AV_DATA_W-1:0],
				       api_call_data[AV_DATA_W+31:AV_DATA_W]);
		 api_return_data[31:0] <= 1;      		 
	      end      		 	      		 
	      MM_SLV_SET_RESP_BURST_SIZE      : begin
  	         slv.set_response_burst_size(api_call_data[AV_BURSTCOUNT_W-1:0]);

		 api_return_data[31:0] <= 1;      
	      end      		 	      		 
	      MM_SLV_SET_RESP_LATENCY         : begin
		 slv.set_response_latency(api_call_data[31:0],
					  api_call_data[63:32]);
		 api_return_data[31:0] <= 1;      
	      end      		 	      		 
	      MM_SLV_SET_INTERFACE_WAIT_TIME  : begin
		 slv.set_interface_wait_time(api_call_data[31:0],
					     api_call_data[63:32]);
		 api_return_data[31:0] <= 1;      		 
	      end      		 	      		 
      	      MM_SLV_GET_CMD_REQUEST 	      : begin
      	      	 case(slv.get_command_request()) 
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
      	      MM_SLV_GET_CMD_DATA         : begin
      	      	 api_return_data[AV_DATA_W-1:0] <= 
      	            slv.get_command_data(api_call_data[31:0]); 
      	      end
      	      MM_SLV_GET_CMD_ADDRESS      : begin
      	      	 api_return_data[AV_ADDRESS_W-1:0] <= 
      	            slv.get_command_address();
      	      end	 
      	      MM_SLV_GET_CMD_BYTE_ENABLE  : begin
      	      	 api_return_data[AV_NUMSYMBOLS-1:0] <= 
      	            slv.get_command_byte_enable(api_call_data[31:0]); 
      	      end
      	      MM_SLV_GET_CMD_BURST_COUNT      : begin
      	      	 api_return_data[AV_BURSTCOUNT_W-1:0] <= 
      	      	     slv.get_command_burst_count();
      	      end      		 	      		 
      	      MM_SLV_GET_CMD_BURST_CYCLE      : begin
      	      	 api_return_data[31:0] <=
      	             slv.get_command_burst_cycle(); 		 
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
	 
   altera_avalon_mm_slave_bfm
     #(
       .AV_ADDRESS_W               (AV_ADDRESS_W               ), 
       .AV_SYMBOL_W                (AV_SYMBOL_W                ), 
       .AV_NUMSYMBOLS              (AV_NUMSYMBOLS              ), 
       .AV_BURSTCOUNT_W            (AV_BURSTCOUNT_W            ),
       .AV_READRESPONSE_W          (AV_READRESPONSE_W          ),
       .AV_WRITERESPONSE_W         (AV_WRITERESPONSE_W         ),
                                                                
       .USE_READ                   (USE_READ                   ), 
       .USE_WRITE                  (USE_WRITE                  ), 
       .USE_ADDRESS                (USE_ADDRESS                ), 
       .USE_BYTE_ENABLE            (USE_BYTE_ENABLE            ), 
       .USE_BURSTCOUNT             (USE_BURSTCOUNT             ), 
       .USE_READ_DATA              (USE_READ_DATA              ), 
       .USE_READ_DATA_VALID        (USE_READ_DATA_VALID        ), 
       .USE_WRITE_DATA             (USE_WRITE_DATA             ), 
       .USE_BEGIN_TRANSFER         (USE_BEGIN_TRANSFER         ), 
       .USE_BEGIN_BURST_TRANSFER   (USE_BEGIN_BURST_TRANSFER   ), 
       .USE_WAIT_REQUEST           (USE_WAIT_REQUEST           ),
       .USE_TRANSACTIONID          (USE_TRANSACTIONID          ),
       .USE_WRITERESPONSE          (USE_WRITERESPONSE          ),
       .USE_READRESPONSE           (USE_READRESPONSE           ),
       .USE_CLKEN                  (USE_CLKEN                  ),
                                                                
       .AV_FIX_READ_LATENCY        (AV_FIX_READ_LATENCY        ), 
       .AV_MAX_PENDING_READS       (AV_MAX_PENDING_READS       ),
                                                                
       .AV_BURST_LINEWRAP          (AV_BURST_LINEWRAP          ), 
       .AV_BURST_BNDR_ONLY         (AV_BURST_BNDR_ONLY         ),
                                                               
       .AV_READ_WAIT_TIME          (AV_READ_WAIT_TIME          ),
       .AV_WRITE_WAIT_TIME          (AV_WRITE_WAIT_TIME        ),
                                                               
       .USE_ARBITERLOCK            (USE_ARBITERLOCK            ),
       .USE_LOCK                   (USE_LOCK                   ),
       .USE_DEBUGACCESS            (USE_DEBUGACCESS            ),
       .AV_REGISTERINCOMINGSIGNALS (AV_REGISTERINCOMINGSIGNALS ),
       .REGISTER_WAITREQUEST       (REGISTER_WAITREQUEST       )
      )
   slv (
         .clk                       (avs_clk                ), 
         .reset                     (avs_reset              ),     

         .avs_clken                (avs_clken               ),

         .avs_waitrequest          (avs_waitrequest         ),
         .avs_write                (avs_write               ),
         .avs_read                 (avs_read                ),
         .avs_address              (avs_address             ), 
         .avs_byteenable           (avs_byteenable          ),
         .avs_writedata            (avs_writedata           ),
         .avs_burstcount           (avs_burstcount          ),     
         .avs_beginbursttransfer   (avs_beginbursttransfer  ),
         .avs_begintransfer        (avs_begintransfer       ), 
         .avs_readdata             (avs_readdata            ),
         .avs_readdatavalid        (avs_readdatavalid       ),
         .avs_arbiterlock          (avs_arbiterlock         ),
         .avs_lock                 (avs_lock                ),
         .avs_debugaccess          (avs_debugaccess         ),

         .avs_transactionid        (avs_transactionid       ),  
         .avs_readresponse         (avs_readresponse        ),
         .avs_readid               (avs_readid              ),
         .avs_writeresponserequest (avs_writeresponserequest),
         .avs_writeresponsevalid   (avs_writeresponsevalid  ),
         .avs_writeresponse        (avs_writeresponse       ),
         .avs_writeid              (avs_writeid             ) 
      );
   
// synthesis translate_on
endmodule 

