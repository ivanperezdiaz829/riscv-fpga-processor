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


// $Id: //acds/rel/13.1/ip/sopc/components/verification/altera_avalon_mm_monitor_bfm/altera_avalon_mm_monitor_if_wrapper.sv#1 $
// $Revision: #1 $
// $Date: 2013/08/11 $
// $Author: swbranch $
//-----------------------------------------------------------------------------
// The macro ALTERA_AVALON_SIM_SVA must be defined to enable SVA processing
//-----------------------------------------------------------------------------

`timescale 1ns / 1ns

module altera_avalon_mm_monitor_if_wrapper(
                                          input               clk,       
                                          input               reset,
                                          altera_avalon_mm_if avs,
                                          altera_avalon_mm_if avm
                                          );
   
   // =head1 PARAMETERS
   parameter AV_ADDRESS_W               = 32;   
   parameter AV_SYMBOL_W                = 8;    
   parameter AV_NUMSYMBOLS              = 4;    
   parameter AV_BURSTCOUNT_W            = 3;  
   parameter AV_READRESPONSE_W          = 8;
   parameter AV_WRITERESPONSE_W         = 8;
   
   parameter AV_CONSTANT_BURST_BEHAVIOR = 1;
   parameter AV_BURST_LINEWRAP          = 0;    
   parameter AV_BURST_BNDR_ONLY         = 0;  
   parameter REGISTER_WAITREQUEST       = 0; 
   parameter AV_MAX_PENDING_READS       = 1;    
   parameter AV_MAX_PENDING_WRITES      = 0;    
   parameter AV_FIX_READ_LATENCY        = 0;    

   parameter USE_READ                   = 1;    
   parameter USE_WRITE                  = 1;    
   parameter USE_ADDRESS                = 1;    
   parameter USE_BYTE_ENABLE            = 1;    
   parameter USE_BURSTCOUNT             = 0;    
   parameter USE_READ_DATA              = 1;    
   parameter USE_READ_DATA_VALID        = 1;    
   parameter USE_WRITE_DATA             = 1;    
   parameter USE_BEGIN_TRANSFER         = 0;    
   parameter USE_BEGIN_BURST_TRANSFER   = 0;    
   parameter USE_WAIT_REQUEST           = 1;    

   parameter AV_READ_TIMEOUT            = 100;  
   parameter AV_WRITE_TIMEOUT           = 100;  
   parameter AV_WAITREQUEST_TIMEOUT     = 1024; 
   parameter AV_MAX_READ_LATENCY        = 100;  
   parameter AV_MAX_WAITREQUESTED_READ  = 100;  
   parameter AV_MAX_WAITREQUESTED_WRITE = 100;  
   parameter AV_MAX_CONTINUOUS_READ          = 5;
   parameter AV_MAX_CONTINUOUS_WRITE         = 5;
   parameter AV_MAX_CONTINUOUS_WAITREQUEST   = 5;
   parameter AV_MAX_CONTINUOUS_READDATAVALID = 5;

   parameter USE_ARBITERLOCK            = 0;    // Use arbiterlock pin on interface
   parameter USE_LOCK                   = 0;    // Use lock pin on interface
   parameter USE_DEBUGACCESS            = 0;    // Use debugaccess pin on interface 
   parameter USE_TRANSACTIONID          = 0;    // Use transactionid interface pin
   parameter USE_WRITERESPONSE          = 0;    // Use write response interface pins
   parameter USE_READRESPONSE           = 0;    // Use read response interface pins
   parameter USE_CLKEN                  = 0;    // Use NTCM interface pins  
   parameter AV_REGISTERINCOMINGSIGNALS = 0;    // Indicate that waitrequest is come from register 

   parameter AV_READ_WAIT_TIME         = 0;     // Fixed wait time cycles when
   parameter AV_WRITE_WAIT_TIME        = 0;     // USE_WAIT_REQUEST is 0

   parameter SLAVE_ADDRESS_TYPE = "SYMBOLS";   // Set slave interface address type, {SYMBOLS, WORDS}
   parameter MASTER_ADDRESS_TYPE = "SYMBOLS";  // Set master interface address type, {SYMBOLS, WORDS}
   
   altera_avalon_mm_monitor
     #(
       .AV_ADDRESS_W                      (AV_ADDRESS_W               ),   
       .AV_SYMBOL_W                       (AV_SYMBOL_W                ),    
       .AV_NUMSYMBOLS                     (AV_NUMSYMBOLS              ),    
       .AV_BURSTCOUNT_W                   (AV_BURSTCOUNT_W            ),    
       .AV_CONSTANT_BURST_BEHAVIOR        (AV_CONSTANT_BURST_BEHAVIOR ),
       .AV_BURST_LINEWRAP                 (AV_BURST_LINEWRAP          ),    
       .AV_BURST_BNDR_ONLY                (AV_BURST_BNDR_ONLY         ),    
       .AV_MAX_PENDING_READS              (AV_MAX_PENDING_READS       ),    
       .AV_MAX_PENDING_WRITES             (AV_MAX_PENDING_WRITES      ),    
       .AV_FIX_READ_LATENCY               (AV_FIX_READ_LATENCY        ),  

       .REGISTER_WAITREQUEST              (REGISTER_WAITREQUEST       ),
       .AV_READRESPONSE_W                 (AV_READRESPONSE_W          ),
       .AV_WRITERESPONSE_W                (AV_WRITERESPONSE_W         ),       
   
       .USE_READ                          (USE_READ                   ),    
       .USE_WRITE                         (USE_WRITE                  ),    
       .USE_ADDRESS                       (USE_ADDRESS                ),    
       .USE_BYTE_ENABLE                   (USE_BYTE_ENABLE            ),    
       .USE_BURSTCOUNT                    (USE_BURSTCOUNT             ),    
       .USE_READ_DATA                     (USE_READ_DATA              ),    
       .USE_READ_DATA_VALID               (USE_READ_DATA_VALID        ),    
       .USE_WRITE_DATA                    (USE_WRITE_DATA             ),    
       .USE_BEGIN_TRANSFER                (USE_BEGIN_TRANSFER         ),    
       .USE_BEGIN_BURST_TRANSFER          (USE_BEGIN_BURST_TRANSFER   ),    
       .USE_WAIT_REQUEST                  (USE_WAIT_REQUEST           ),    
       .USE_ARBITERLOCK                   (USE_ARBITERLOCK            ),
       .USE_LOCK                          (USE_LOCK                   ),
       .USE_DEBUGACCESS                   (USE_DEBUGACCESS            ),
       .USE_TRANSACTIONID                 (USE_TRANSACTIONID          ),
       .USE_WRITERESPONSE                 (USE_WRITERESPONSE          ),
       .USE_READRESPONSE                  (USE_READRESPONSE           ),
       .USE_CLKEN                         (USE_CLKEN                  ),
       .AV_REGISTERINCOMINGSIGNALS        (AV_REGISTERINCOMINGSIGNALS ),
       
       .AV_READ_WAIT_TIME                 (AV_READ_WAIT_TIME          ),
       .AV_WRITE_WAIT_TIME                (AV_WRITE_WAIT_TIME         ),
   
       .AV_READ_TIMEOUT                   (AV_READ_TIMEOUT            ),  
       .AV_WRITE_TIMEOUT                  (AV_WRITE_TIMEOUT           ),  
       .AV_WAITREQUEST_TIMEOUT            (AV_WAITREQUEST_TIMEOUT     ), 
       .AV_MAX_READ_LATENCY               (AV_MAX_READ_LATENCY        ),  
       .AV_MAX_WAITREQUESTED_READ         (AV_MAX_WAITREQUESTED_READ  ),  
       .AV_MAX_WAITREQUESTED_WRITE        (AV_MAX_WAITREQUESTED_WRITE ),
       .AV_MAX_CONTINUOUS_READ            (AV_MAX_CONTINUOUS_READ     ),
       .AV_MAX_CONTINUOUS_WRITE           (AV_MAX_CONTINUOUS_WRITE    ),
       .AV_MAX_CONTINUOUS_WAITREQUEST     (AV_MAX_CONTINUOUS_WAITREQUEST),
       .AV_MAX_CONTINUOUS_READDATAVALID   (AV_MAX_CONTINUOUS_READDATAVALID),
       .SLAVE_ADDRESS_TYPE                (SLAVE_ADDRESS_TYPE         ),
       .MASTER_ADDRESS_TYPE               (MASTER_ADDRESS_TYPE        )
     )

        bfm (
            .clk                       (clk                       ),
            .reset                     (reset                     ),
            
            .avm_clken                 (avm.clken                 ),
            .avs_clken                 (avs.clken                 ),

            .avs_waitrequest           (avm.waitrequest           ),
            .avs_write                 (avs.write                 ),
            .avs_read                  (avs.read                  ),
            .avs_address               (avs.address               ), 
            .avs_byteenable            (avs.byteenable            ),
            .avs_writedata             (avs.writedata             ),
            .avs_burstcount            (avs.burstcount            ),
            .avs_beginbursttransfer    (avs.beginbursttransfer    ),
            .avs_begintransfer         (avs.begintransfer         ),
            .avs_readdata              (avm.readdata              ),
            .avs_readdatavalid         (avm.readdatavalid         ),
            .avs_arbiterlock           (avs.arbiterlock           ),
            .avs_lock                  (avs.lock                  ),
            .avs_debugaccess           (avs.debugaccess           ),
            .avs_transactionid         (avs.transactionid         ),
            .avs_readresponse          (avm.readresponse          ),
            .avs_readid                (avm.readid                ),
            .avs_writeresponserequest  (avs.writeresponserequest  ),
            .avs_writeresponsevalid    (avm.writeresponsevalid    ),
            .avs_writeresponse         (avm.writeresponse         ),
            .avs_writeid               (avm.writeid               ),
            .avs_response              (avm.response              ),

            .avm_waitrequest           (avs.waitrequest           ),
            .avm_write                 (avm.write                 ),
            .avm_read                  (avm.read                  ),
            .avm_address               (avm.address               ), 
            .avm_byteenable            (avm.byteenable            ),
            .avm_writedata             (avm.writedata             ),
            .avm_burstcount            (avm.burstcount            ),
            .avm_beginbursttransfer    (avm.beginbursttransfer    ),
            .avm_begintransfer         (avm.begintransfer         ),
            .avm_readdata              (avs.readdata              ),
            .avm_readdatavalid         (avs.readdatavalid         ),
            .avm_arbiterlock           (avm.arbiterlock           ),
            .avm_lock                  (avm.lock                ),
            .avm_debugaccess           (avm.debugaccess           ),
            .avm_transactionid         (avm.transactionid         ),
            .avm_readresponse          (avs.readresponse          ),
            .avm_readid                (avs.readid                ),
            .avm_writeresponserequest  (avm.writeresponserequest  ),
            .avm_writeresponsevalid    (avs.writeresponsevalid    ),
            .avm_writeresponse         (avs.writeresponse         ),
            .avm_writeid               (avs.writeid               ),
            .avm_response              (avs.response              )
            );

endmodule
