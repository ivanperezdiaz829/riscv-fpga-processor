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


// $Id: //acds/rel/13.1/ip/sopc/components/verification/altera_avalon_mm_master_bfm/altera_avalon_mm_master_bfm_if_wrapper.sv#1 $
// $Revision: #1 $
// $Date: 2013/08/11 $
// $Author: swbranch $
//-----------------------------------------------------------------------------

`timescale 1ns / 1ns

module altera_avalon_mm_master_bfm_if_wrapper (
   input 		               clk,
   input 		               reset,  
   altera_avalon_mm_if.general_master  avm
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
   parameter AV_MAX_PENDING_WRITES     = 0;
   parameter AV_CONSTANT_BURST_BEHAVIOR = 1;
   parameter AV_BURST_LINEWRAP         = 0;  
   parameter AV_BURST_BNDR_ONLY        = 0;  
   parameter REGISTER_WAITREQUEST      = 0;
   parameter AV_REGISTERINCOMINGSIGNALS = 0;
   parameter AV_READ_WAIT_TIME         = 0; 
   parameter AV_WRITE_WAIT_TIME        = 0;
   
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
       .AV_MAX_PENDING_WRITES       (AV_MAX_PENDING_WRITES      ),
       .AV_READ_WAIT_TIME           (AV_READ_WAIT_TIME          ),
       .AV_WRITE_WAIT_TIME          (AV_WRITE_WAIT_TIME         ),
                                                               
       .AV_CONSTANT_BURST_BEHAVIOR  (AV_CONSTANT_BURST_BEHAVIOR ), 
       .AV_BURST_LINEWRAP           (AV_BURST_LINEWRAP          ), 
       .AV_BURST_BNDR_ONLY          (AV_BURST_BNDR_ONLY         ), 
       .USE_DEBUGACCESS             (USE_DEBUGACCESS            ),
       .AV_REGISTERINCOMINGSIGNALS  (AV_REGISTERINCOMINGSIGNALS ),
       .REGISTER_WAITREQUEST        (REGISTER_WAITREQUEST       )
      ) 
     bfm (
          .clk                      (clk                     ),
          .reset                    (reset                   ),       
          
          .avm_clken                (avm.clken               ),

          .avm_waitrequest          (avm.waitrequest         ),
          .avm_write                (avm.write               ),
          .avm_read                 (avm.read                ),
          .avm_address              (avm.address             ), 
          .avm_byteenable           (avm.byteenable          ),
          .avm_writedata            (avm.writedata           ),
          .avm_burstcount           (avm.burstcount          ),     
          .avm_beginbursttransfer   (avm.beginbursttransfer  ),
          .avm_begintransfer        (avm.begintransfer       ),
          .avm_readdata             (avm.readdata            ),
          .avm_readdatavalid        (avm.readdatavalid       ),
          .avm_arbiterlock          (avm.arbiterlock         ),
          .avm_lock                 (avm.lock                ),
          .avm_debugaccess          (avm.debugaccess         ),  

          .avm_transactionid        (avm.transactionid       ),  
          .avm_readresponse         (avm.readresponse        ),
          .avm_readid               (avm.readid              ),
          .avm_writeresponserequest (avm.writeresponserequest),
          .avm_writeresponsevalid   (avm.writeresponsevalid  ),
          .avm_writeresponse        (avm.writeresponse       ),
          .avm_writeid              (avm.writeid             ),
          .avm_response             (avm.response            )
          );

endmodule






