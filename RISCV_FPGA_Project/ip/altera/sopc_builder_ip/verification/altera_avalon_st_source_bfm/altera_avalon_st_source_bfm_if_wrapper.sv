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


// $Id: //acds/rel/13.1/ip/sopc/components/verification/altera_avalon_st_source_bfm/altera_avalon_st_source_bfm_if_wrapper.sv#1 $
// $Revision: #1 $
// $Date: 2013/08/11 $
// $Author: swbranch $
//-----------------------------------------------------------------------------

`timescale 1ns / 1ns

module altera_avalon_st_source_bfm_if_wrapper (
 					       input 		   clk,
					       input 		   reset,  
					       altera_avalon_st_if avsrc
					       );
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
   
   altera_avalon_st_source_bfm #(
        .ST_SYMBOL_W     (ST_SYMBOL_W     ),
        .ST_NUMSYMBOLS   (ST_NUMSYMBOLS   ),
        .ST_CHANNEL_W    (ST_CHANNEL_W	  ),
        .ST_ERROR_W      (ST_ERROR_W  	  ),
        .ST_EMPTY_W      (ST_EMPTY_W  	  ),
	.ST_MAX_CHANNELS (ST_MAX_CHANNELS ),
	.ST_READY_LATENCY(ST_READY_LATENCY),
        .USE_PACKET      (USE_PACKET 	  ),   
	.USE_CHANNEL     (USE_CHANNEL	  ), 
	.USE_ERROR       (USE_ERROR  	  ),   
	.USE_READY       (USE_READY  	  ),   
	.USE_VALID       (USE_VALID  	  ),   
	.USE_EMPTY       (USE_EMPTY  	  )   
    ) 
    bfm (
         .clk               (clk       	  	),
         .reset             (reset     	  	),   
         .src_data          (avsrc.data	  	), 
         .src_channel       (avsrc.channel	),    
         .src_error         (avsrc.error	),
         .src_empty         (avsrc.empty	),	    
         .src_valid         (avsrc.valid	),      
         .src_startofpacket (avsrc.startofpacket),
         .src_endofpacket   (avsrc.endofpacket	),
         .src_ready         (avsrc.ready      	)
    );

endmodule






