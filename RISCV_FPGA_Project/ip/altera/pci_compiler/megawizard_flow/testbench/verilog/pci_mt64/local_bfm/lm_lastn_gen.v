//------------------------------------------------------------------
//  Altera PCI testbench
//  MODULE NAME: last_gen
//
//****************************************************************************
//  FUNCTIONAL DESCRIPTION:
//  This file generates lm_lastn signal
//  Local master last. This signal is driven by the local side to request
//  that the pci_mt64 or pci_mt32 master interface ends the current
//  transaction. When the local side asserts this signal, the PCI
//  MegaCore function master interface deasserts framen as soon as
//  possible and asserts irdyn to indicate that the last data phase has
//  begun. The local side should assert this signal for one clock to initiate
//  completion of Master transaction.
//****************************************************************************
//
//  REVISION HISTORY:  
//  Revision 1.4 Description: Changed the code to make it modular and simple
//  Revision 1.3 Description: No change
//  Revision 1.1 Description: No change.
//  Revision 1.0 Description: Initial Release.
//
//  Copyright (C) 1991-2004 Altera Corporation, All rights reserved.  
//  Altera products are protected under numerous U.S. and foreign patents, 
//  maskwork rights, copyrights and other intellectual property laws. 
//  This reference design file, and your use thereof, is subject to and 
//  governed by the terms and conditions of the applicable Altera Reference 
//  Design License Agreement (either as signed by you or found at www.altera.com).  
//  By using this reference design file, you indicate your acceptance of such terms 
//  and conditions between you and Altera Corporation.  In the event that you do
//  not agree with such terms and conditions, you may not use the reference design 
//  file and please promptly destroy any copies you have made. 
//  This reference design file is being provided on an "as-is" basis and as an 
//  accommodation and therefore all warranties, representations or guarantees 
//  of any kind (whether express, implied or statutory) including, without limitation, 
//  warranties of merchantability, non-infringement, or fitness for a particular purpose, 
//  are specifically disclaimed.  By making this reference design file available, 
//  Altera expressly does not recommend, suggest or require that this reference design 
//  file be used in combination with any other product not provided by Altera.
//---------------------------------------------------------------------------------------


`timescale 1ns/1ns

module lm_lastn_gen (/*AUTOARG*/
   // Outputs
   lm_lastn, 
   // Inputs
   clk, 
   rstn, 
   wr_rdn, 
   lm_req32n, 
   lm_req64n, 
   lm_dxfrn, 
   l_hdat_ackn, 
   l_ldat_ackn, 
   lm_tsr, 
   xfr_length, 
   abnormal_term
   );
   parameter width = 7;            // width of the xfr_length
   
   input             clk;           // clock
   input             rstn;          // Active low reset
   input             wr_rdn;        // write = 1, read = 0
   input             lm_req32n;     // 32-bit request
   input             lm_req64n;     // 64-bit request
   input             lm_dxfrn;      // local master data transfer
   input             l_hdat_ackn;   // Local high data acknowledge
   input             l_ldat_ackn;   // Local low data acknowledge
   input [9:0]       lm_tsr;        // local master transaction status register
   input [width:0]   xfr_length;    // # of transfers required
   input             abnormal_term; // Active high signal indicating
   // an abnoraml termination occured. This signal should indicate
   // that one of the following conditions occured
   // Latency timeout
   // Target Disconnect (with and with out data)
   // Target Retry
   // Target abort
   // Master abort

   output            lm_lastn;
   // reqn indicates that a local side request is active and is used for 
   // loading the xfr_length into the local_xfr_cnt and also for setting 
   // the following "xfr_......" registers
   wire              reqn = lm_req64n & lm_req32n;
   // Decodes of xfr_length for 1 word, 2 words and 3 words
   reg               xfr_one_word_reg;     // transfer 1 word
   reg               xfr_two_words_reg;    // 2 words
   reg               xfr_three_words_reg;  // 3 words
   // Keep track of whether a 64-bit access was requested
   reg               xfr_64bit_reg ;
   always @ (posedge clk or negedge rstn)
     if (!rstn) begin
        xfr_one_word_reg    <= 1'b0;
        xfr_two_words_reg   <= 1'b0;
        xfr_three_words_reg <= 1'b0;
        xfr_64bit_reg       <= 1'b0;
     end else begin
        if (abnormal_term) begin
           xfr_one_word_reg    <= 1'b0;
           xfr_two_words_reg   <= 1'b0;
           xfr_three_words_reg <= 1'b0;
           xfr_64bit_reg       <= 1'b0;
        end else if (!reqn) begin
           xfr_one_word_reg    <= (xfr_length == 'h1) ? 1'b1 : 1'b0;
           xfr_two_words_reg   <= (xfr_length == 'h2) ? 1'b1 : 1'b0;
           xfr_three_words_reg <= (xfr_length == 'h3) ? 1'b1 : 1'b0;
           xfr_64bit_reg <= !lm_req64n;
        end
     end // else: !if(!rstn)
   // local transfer counter
   wire cnten = !lm_dxfrn & 
                (wr_rdn | // writes
                 (!wr_rdn & // reads
                  (!xfr_64bit_reg | // 32-bit 
                   (xfr_64bit_reg & lm_tsr[9]) | // 64-bit request and 64-bit response
                   (xfr_64bit_reg & !lm_tsr[9] & !l_hdat_ackn)))); // 64-bit req 32bit resp


   reg [width:0]     local_xfr_cnt ;

   always  @ (posedge clk or negedge rstn) begin
      if (!rstn) 
        local_xfr_cnt <= 0;
      else  begin
         if ( abnormal_term) // sync clear
           local_xfr_cnt <= 0;
         else if (!reqn)  // sync load
           local_xfr_cnt <= xfr_length;
         else if (cnten) // count enable
           local_xfr_cnt <= local_xfr_cnt - 1'b1;
      end
   end // always  @ (posedge clk or negedge rstn)
   
   /**************************************************
    lm last for writes is generated as shown below
    which is a pipelined version of 
     !((local_xfr_cnt == 1) & !lm_dxfrn);
    *************************************************/

   // wr_done_reg indicates that local_xfr_cnt = '1' for writes 
   // and is held active until local_xfr_cnt = 1 & lm_dxfrn = '0'   
   reg  wr_done_reg; 
                    
   always @ (posedge clk or negedge rstn)
     if (!rstn) 
       wr_done_reg <= 1'b0;
     else begin
        if (!wr_done_reg) 
          wr_done_reg <= ( (local_xfr_cnt == 'h2) & !lm_dxfrn & wr_rdn) ;
        else if (local_xfr_cnt == 'h1 & (xfr_one_word_reg | !lm_dxfrn))
          wr_done_reg <= 1'b0;
     end

   /**************************************************
    lm last for reads needs to consider 4 different cases
    1) Signle transfer = !(xfr_one_word_reg & !lm_dxfrn)
    2) 2 WORD transfer = !(xfr_two_words_reg & rising edge of lm_tsr[3])
    3) Greater than 2 WORD Transfer = !((local_xfr_cnt == 'h3) &
    !lm_dxfrn);
    4) For 64-bit->32bit read transfers we need to consider the following
    expression
    !(!l_hdat_ackn & !lm_tsr[9] & !lm_dxfrn)&
                      (local_xfr_cnt == 'h2));
    *************************************************/

   // Generate rising edge of lm_tsr[3]   
   reg  pci_data_phase_q; // delayed version of pci_data_phase lm_tsr[3]
   always @ (posedge clk or negedge rstn) begin
      if (!rstn) 
        pci_data_phase_q <= 1'b0;
      else
        pci_data_phase_q <= lm_tsr[3];
   end
   // detect rising edge of pci_data_phase
   wire pci_data_phase_rising =  lm_tsr[3] & !pci_data_phase_q;
   
   // First 2 cases i.e. Single transfer and  2 WORD transfer is 
   // generated using the register rd_done1_reg 
   reg  rd_done1_reg ; 
                     
   always @ (posedge clk or negedge rstn) 
     if (!rstn) 
       rd_done1_reg <= 1'b0;
     else
       rd_done1_reg <= (( xfr_one_word_reg & lm_tsr[1] ) | // single transfer
                                                           // for both reads/writes
                       (!wr_rdn & xfr_two_words_reg & pci_data_phase_rising)) ; // 2 word reads
   
   // Transfer for greater than 2 words is generated using a 
   // pipelined version of !((local_xfr_cnt == 'h3) & !lm_dxfrn) and
   //    !(!l_hdat_ackn & !lm_tsr[9] & !lm_dxfrn)&
   //     (local_xfr_cnt == 'h2));

   reg  rd_done2_reg; // temporary variable for read lm last generation
   // This register is set when either term1 or term2 are active and
   // is held active until term3 or term4 is asserted

   
   // 32-bit request and transfer or  64-bit request and transfer
   // Set rd_done2_reg when local_xfr_cnt == 4 or when
   // xfr_three_words_reg is active
   wire term1 = (!xfr_64bit_reg | (xfr_64bit_reg & lm_tsr[9]) ) & 
                  ( (local_xfr_cnt == 'h4 & !lm_dxfrn) | 
                    (local_xfr_cnt == 'h3 & xfr_three_words_reg)) ;
   
   // 64-bit request and 32-bit transfer
   // Set rd_done2_reg wgen local_xfr_cnt == 2 and
   // l_ldat_ackn is active
   wire term2 = (xfr_64bit_reg & !lm_tsr[9]) &
                  (local_xfr_cnt == 'h2 & !l_ldat_ackn & !lm_dxfrn);
   
   // Reset for term1
   wire term3 = ((!xfr_64bit_reg | (xfr_64bit_reg & lm_tsr[9]) ) & local_xfr_cnt == 'h3 & !lm_dxfrn);
   
   // Reset for term2
   wire term4 = (xfr_64bit_reg & !lm_tsr[9] & local_xfr_cnt == 'h2 & !lm_dxfrn & !l_hdat_ackn) ;

   always @ (posedge clk or negedge rstn)
     if (!rstn)
       rd_done2_reg <= 1'b0;
     else begin
        if (!rd_done2_reg)
          rd_done2_reg <= !wr_rdn & (term1 | term2);
        else if (term3 | term4)
          rd_done2_reg <= 1'b0;
     end
   
   wire lm_lastn = ! (rd_done1_reg | (!lm_dxfrn & (wr_done_reg | rd_done2_reg)));
   
endmodule // lm_last
