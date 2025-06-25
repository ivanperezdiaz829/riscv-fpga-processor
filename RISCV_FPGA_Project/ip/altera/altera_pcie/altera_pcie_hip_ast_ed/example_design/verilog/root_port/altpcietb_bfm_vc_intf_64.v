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


`timescale 1 ps / 1 ps
//-----------------------------------------------------------------------------
// Title         : PCI Express BFM Root Port Avalon-ST64 VC Interface
// Project       : PCI Express MegaCore function
//-----------------------------------------------------------------------------
// File          : altpcietb_bfm_vc_intf_64.v
// Author        : Altera Corporation
//-----------------------------------------------------------------------------
// Description :
// This entity interfaces between the root port transaction list processor
// and the root port module single VC interface. It handles the following basic
// functions:
// * Formating Tx Descriptors 
// * Retrieving Tx Data as needed from the shared memory
// * Decoding Rx Descriptors 
// * Storing Rx Data as needed to the shared memory
//-----------------------------------------------------------------------------
// Copyright (c) 2008 Altera Corporation. All rights reserved.  Altera products are
// protected under numerous U.S. and foreign patents, maskwork rights, copyrights and
// other intellectual property laws.  
//
// This reference design file, and your use thereof, is subject to and governed by
// the terms and conditions of the applicable Altera Reference Design License Agreement.
// By using this reference design file, you indicate your acceptance of such terms and
// conditions between you and Altera Corporation.  In the event that you do not agree with
// such terms and conditions, you may not use the reference design file. Please promptly
// destroy any copies you have made.
//
// This reference design file being provided on an "as-is" basis and as an accommodation 
// and therefore all warranties, representations or guarantees of any kind 
// (whether express, implied or statutory) including, without limitation, warranties of 
// merchantability, non-infringement, or fitness for a particular purpose, are 
// specifically disclaimed.  By making this reference design file available, Altera
// expressly does not recommend, suggest or require that this reference design file be
// used in combination with any other product not provided by Altera.
//-----------------------------------------------------------------------------
module altpcietb_bfm_vc_intf_64 (clk_in, rstn, rx_mask,  rx_be,  rx_st_sop, rx_st_eop, rx_st_empty, rx_st_data, rx_st_valid, rx_st_ready, rx_ecrc_err,
                                 tx_cred,  tx_err, 
                                 tx_st_ready, tx_st_sop, tx_st_eop, tx_st_empty, tx_st_valid, tx_st_data, tx_fifo_empty, cfg_io_bas, cfg_np_bas, cfg_pr_bas);

   parameter VC_NUM  = 0;
   parameter DISABLE_RX_BE_CHECK  = 1; 
   `include "altpcietb_bfm_constants.v"
   `include "altpcietb_bfm_log.v"
   `include "altpcietb_bfm_shmem.v"
   `include "altpcietb_bfm_req_intf.v"

   input clk_in; 
   input rstn;   
   output rx_mask; 
   reg rx_mask; 
   input[7:0] rx_be;  
   input[35:0] tx_cred;    
   output tx_err; 
   reg tx_err; 
   input[19:0] cfg_io_bas; 
   input[11:0] cfg_np_bas; 
   input[43:0] cfg_pr_bas; 
   input rx_st_sop;
   input rx_st_valid;
   output rx_st_ready;
   reg rx_st_ready;
   input rx_st_eop;
   input rx_st_empty;
   input[63:0] rx_st_data;
   input rx_ecrc_err;
   input tx_st_ready;
   output tx_st_sop;
   reg tx_st_sop;
   output tx_st_eop;
   reg tx_st_eop;
   output tx_st_empty;
   reg tx_st_empty;
   output tx_st_valid;
   reg tx_st_valid;
   output[63:0] tx_st_data;
   reg[63:0] tx_st_data;
   input tx_fifo_empty;

   parameter[2:0] RXST_IDLE = 0; 
   parameter[2:0] RXST_DESC_ACK = 1; 
   parameter[2:0] RXST_DATA_WRITE = 2; 
   parameter[2:0] RXST_DATA_NONP_WRITE = 3; 
   parameter[2:0] RXST_DATA_COMPL = 4; 
   parameter[2:0] RXST_NONP_REQ = 5; 
   parameter[1:0] TXST_IDLE = 0; 
   parameter[1:0] TXST_DESC = 1; 
   parameter[1:0] TXST_DATA = 2; 
   reg[2:0] rx_state; 
   reg[1:0] tx_state; 
   // Communication signals between main Tx State Machine and main Rx State Machine
   // to indicate when completions are expected
   integer exp_compl_tag; 
   integer exp_compl_bcount; 
   // Communication signals between Rx State Machine and Tx State Machine
   // for requesting completions
   reg rx_tx_req; 
   reg[127:0] rx_tx_desc; 
   integer rx_tx_shmem_addr; 
   integer rx_tx_bcount; 
   reg[7:0] rx_tx_byte_enb; 
   reg tx_rx_ack; 
   
   // Communication Signals for PErf Monitoring
   reg[10:0] tx_payld_length;  
   reg[10:0] rx_payld_length; 
   reg       rx_update_pkt_count;   
   reg       tx_update_pkt_count;   
   
   // support for streaming interface
   reg[135:0] rx_desc_int;
   wire[135:0] rx_desc_int_v; 
   reg         rx_st_sop_last;
   wire[63:0] rx_st_data_64;  
   
   
   
   ///////////////////////////////////////////////////
   // Common functions and tasks used in this module
   
   `include "altpcietb_bfm_vc_intf_ast_common.v"  
   
   
   
   ///////////////////////////////////////////////////
   // RX and TX processing
 
   assign rx_st_data_64 = rx_st_data; 
   assign rx_desc_int_v[127:64] = ((rx_st_sop==1'b1) & (rx_st_valid==1'b1)) ?  {rx_st_data_64[31:0], rx_st_data_64[63:32]} : rx_desc_int[127:64];   
   assign rx_desc_int_v[63:0]   = ((rx_st_sop_last==1'b1) & (rx_st_valid==1'b1)) ?  {rx_st_data_64[31:0], rx_st_data_64[63:32]} : rx_desc_int[63:0];   
  
   // behavioral
   always @(clk_in)
   begin : main_rx_state
      integer compl_received_v[0:EBFM_NUM_TAG - 1]; 
      integer compl_expected_v[0:EBFM_NUM_TAG - 1]; 
      reg[2:0] rx_state_v;            
      reg rx_st_ready_v;// pops data from RX FIFO (lookahead)  
      integer shmem_addr_v; 
      integer rx_compl_tag_v; 
      reg[SHMEM_ADDR_WIDTH - 1:0] rx_compl_baddr_v; 
      reg[2:0] rx_compl_sts_v; 
      reg[7:0] byte_enb_v; 
      integer bcount_v; 
      reg rx_tx_req_v; 
      reg[127:0] rx_tx_desc_v; 
      integer rx_tx_shmem_addr_v; 
      integer rx_tx_bcount_v; 
      reg[7:0] rx_tx_byte_enb_v;  
      reg[10:0]   rx_payld_length_v;
      reg         rx_update_pkt_count_v;
      reg      dummy ; 
      reg     rx_ecrc_err_reg;
      integer  shmem_addr0_debug;   
      reg[7:0] byte_en_debug;     
      reg[63:0] data_debug;
      
      integer      i ;
      if (clk_in == 1'b1)
      begin
         if (rstn != 1'b1)
         begin
            rx_state_v = RXST_IDLE;  
            rx_compl_tag_v = -1; 
            rx_compl_sts_v = {3{1'b1}}; 
            rx_tx_req_v = 1'b0; 
            rx_tx_desc_v = {128{1'b0}}; 
            rx_tx_shmem_addr_v = 0; 
            rx_tx_bcount_v = 0; 
            rx_tx_bcount_v = 0;  
            rx_payld_length_v = 11'h0;
            rx_ecrc_err_reg = 1'b0;
            for (i = 0 ; i < EBFM_NUM_TAG ; i = i + 1)
              begin
                 compl_expected_v[i] = -1; 
                 compl_received_v[i] = -1;
              end
         end
         else
         begin 
            // See if the Transmit side is transmitting a Non-Posted Request
            // that we need to expect a completion for and if so record it
            if (exp_compl_tag > -1)
            begin
               compl_expected_v[exp_compl_tag] = exp_compl_bcount; 
               compl_received_v[exp_compl_tag] = 0; 
            end 
            rx_state_v = rx_state;  
            rx_tx_req_v = 1'b0;   

            // for performance monitor
            rx_update_pkt_count_v = (rx_st_eop == 1'b1) & (rx_st_valid == 1'b1);
            if (rx_desc_int_v[126]==1'b1) begin
                if (rx_desc_int_v[105:96]==10'h0)
                    rx_payld_length_v <= 11'h400;   // 1024 DWs
                else
                    rx_payld_length_v <= {1'b0, rx_desc_int_v[105:96]};
            end 
            rx_ecrc_err_reg <= rx_ecrc_err;
            if ((rx_ecrc_err_reg == 0) & (rx_ecrc_err==1)) begin
               dummy = ebfm_display(EBFM_MSG_ERROR_CONTINUE, 
                         {"Root Port VC", dimage1(VC_NUM), 
                          " Detected ECRC Error  " }); 
            end
            
            case (rx_state)
               RXST_IDLE :
                        begin
                           rx_st_ready_v = 1'b1; 
                           // Note rx_mask will be controlled by tx_process
                           // process main_rx_state
                           if ((rx_st_sop == 1'b1) && (rx_st_valid==1'b1))
                           begin
                              rx_st_ready_v = 1'b1; 
                              rx_state_v = RXST_DESC_ACK;    
                           end
                           else
                           begin 
                              rx_state_v = RXST_IDLE; 
                           end 
                        end
               RXST_DESC_ACK, RXST_DATA_COMPL, RXST_DATA_WRITE, RXST_DATA_NONP_WRITE :
                        begin 
                           if (rx_state == RXST_DESC_ACK)
                           begin   
                              if (is_request(rx_desc_int_v))
                              begin
                                 // All of these states are handled together since they can all
                                 // involve data transfer and we need to share that code.
                                 //
                                 // If this is the cycle where the descriptor is being ack'ed we
                                 // need to complete the descriptor decode first so that we can
                                 // be prepared for the Data Transfer that might happen in the same
                                 // cycle. 
                                 if (is_non_posted(rx_desc_int_v))
                                 begin
                                    // Non-Posted Request
                                    rx_nonp_req_setup_compl(rx_desc_int_v, rx_tx_desc_v, rx_tx_shmem_addr_v, rx_tx_byte_enb_v, rx_tx_bcount_v); 
                                    // Request
                                    if (has_data(rx_desc_int_v))
                                    begin
                                       // Non-Posted Write Request
                                       rx_write_req_setup(rx_desc_int_v, shmem_addr_v, byte_enb_v, bcount_v); 
                                       rx_state_v = RXST_DATA_NONP_WRITE; 
                                       rx_st_ready_v = 1'b1;
                                    end
                                    else
                                    begin
                                       // Non-Posted Read Request
                                       rx_st_ready_v = 1'b0;
                                       rx_state_v = RXST_NONP_REQ; 
                                    end 
                                 end
                                 else
                                 begin
                                    // Posted Request
                                    rx_tx_desc_v = {128{1'b0}}; 
                                    rx_tx_shmem_addr_v = 0; 
                                    rx_tx_byte_enb_v = {8{1'b0}}; 
                                    rx_tx_bcount_v = 0; 
                                    // Begin Lengthy decode and checking of the Rx Descriptor
                                    // First Determine if it is a completion or a request
                                    if (has_data(rx_desc_int_v))
                                    begin
                                       // Posted Write Request
                                       rx_write_req_setup(rx_desc_int_v, shmem_addr_v, byte_enb_v, bcount_v); 
                                       rx_st_ready_v = 1'b1;
                                       rx_state_v = RXST_DATA_WRITE; 
                                    end
                                    else
                                    begin
                                       // Posted Message without Data
                                       // Not currently supported.
                                       rx_st_ready_v = 1'b1;
                                       rx_state_v = RXST_IDLE; 
                                    end 
                                 end 
                              end
                              else // is_request == 0
                              begin
                                 // Completion
                                 rx_compl_setup(rx_desc_int_v, shmem_addr_v, byte_enb_v, bcount_v, 
                                                rx_compl_tag_v, rx_compl_sts_v); 
                                 if (compl_expected_v[rx_compl_tag_v] < 0)
                                 begin
                                    dummy = ebfm_display(EBFM_MSG_ERROR_FATAL, 
                                                 {"Root Port VC", dimage1(VC_NUM), 
                                                  " Recevied unexpected completion TLP, Fmt/Type: ", 
                                                  himage2(rx_desc_int[127:120]), 
                                                  " Tag: ", himage2(rx_desc_int[47:40])}); 
                                 end 
                                 if (has_data(rx_desc_int_v))
                                 begin
                                    rx_st_ready_v = 1'b1;
                                    rx_state_v = RXST_DATA_COMPL; 
                                    // Increment for already received data phases
                                    shmem_addr_v = shmem_addr_v + compl_received_v[rx_compl_tag_v]; 
                                 end
                                 else
                                 begin
                                    rx_state_v = RXST_IDLE; 
                                    rx_st_ready_v = 1'b1;
                                    if ((compl_received_v[rx_compl_tag_v] < compl_expected_v[rx_compl_tag_v]) & 
                                        (rx_compl_sts_v == 3'b000))
                                    begin
                                       dummy = ebfm_display(EBFM_MSG_ERROR_CONTINUE, 
                                                    {"Root Port VC", dimage1(VC_NUM), 
                                                     " Did not receive all expected completion data. Expected: ", 
                                                     dimage4(compl_expected_v[rx_compl_tag_v]), 
                                                     " Received: ", dimage4(compl_received_v[rx_compl_tag_v])}); 
                                    end 
                                    // Report that it is complete to the Driver
                                    vc_intf_rpt_compl(rx_compl_tag_v, rx_compl_sts_v); 
                                    // Clear out that we expect anymore
                                    compl_received_v[rx_compl_tag_v] = -1; 
                                    compl_expected_v[rx_compl_tag_v] = -1; 
                                    rx_compl_tag_v = -1; 
                                 end 
                              end 
                           end 
                           // Collect Payload when
                           //    - in any state after the Descriptor phase or
                           //    - during descriptor phase, but only if it is a 3DW Header, Non-QWord aligned packet
                           if ((rx_st_valid == 1'b1) && (rx_desc_int_v[126]==1'b1) && ((rx_state!=RXST_DESC_ACK) || is_3dw_nonaligned(rx_desc_int_v) ) )    
                           begin
                              begin : xhdl_3
                                 integer i;
                                 for(i = 0; i <= 7; i = i + 1)
                                 begin 
                                    if (i==0) shmem_addr0_debug = shmem_addr_v;  
                                    byte_en_debug[i] = byte_enb_v[i]; 
                                    data_debug[(i * 8)+:8] = rx_st_data_64[(i * 8)+:8];
                                    
                                    if (((byte_enb_v[i]) == 1'b1) & (bcount_v > 0))
                                    begin
                                       shmem_write(shmem_addr_v, rx_st_data_64[(i * 8)+:8], 1); 
                                       shmem_addr_v = shmem_addr_v + 1; 
                                       bcount_v = bcount_v - 1; 
                                       // Byte Enables only valid on first data phase, bcount_v covers
                                       // the last data phase
                                       if ((bcount_v == 0) & (i < 7))
                                       begin
                                          begin : xhdl_4
                                             integer j;
                                             for(j = i + 1; j <= 7; j = j + 1)
                                             begin
                                                byte_enb_v[j] = 1'b0; 
                                             end
                                          end // j
                                       end 
                                       // Now Handle the case if we are receiving data in this cycle
                                       if (rx_state_v == RXST_DATA_COMPL)
                                       begin
                                          compl_received_v[rx_compl_tag_v] = compl_received_v[rx_compl_tag_v] + 1; 
                                       end 
                                       if (((rx_be[i]) != 1'b1) & (DISABLE_RX_BE_CHECK == 0))
                                       begin
                                          dummy = ebfm_display(EBFM_MSG_ERROR_FATAL, 
                                                       {"Root Port VC", dimage1(VC_NUM), 
                                                        " rx_be field: ", himage2(rx_be), 
                                                        " Mismatch. Expected: ", himage2(byte_enb_v)}); 
                                       end 
                                    end
                                    else
                                    begin
                                       if (((rx_be[i]) != 1'b0) & (DISABLE_RX_BE_CHECK == 0))
                                       begin
                                          dummy = ebfm_display(EBFM_MSG_ERROR_FATAL, 
                                                       {"Root Port VC", dimage1(VC_NUM), 
                                                        " rx_be field: ", himage2(rx_be), 
                                                        " Mismatch. Expected: ", himage2(byte_enb_v)}); 
                                       end 
                                    end 
                                 end
                              end // i
                              // Enable all bytes in subsequent data phases
                              byte_enb_v = {8{1'b1}}; 
                              // Last Packet phase
                              if ((rx_st_eop == 1'b1) && (rx_st_valid==1'b1))
                              begin   
                                 if (bcount_v > 0)
                                 begin
                                    dummy = ebfm_display(EBFM_MSG_ERROR_FATAL, 
                                                 {"Root Port VC", dimage1(VC_NUM), 
                                                  " Rx Byte Count did not go to zero in last data phase. Remaining Bytes: ", 
                                                  dimage4(bcount_v)}); 
                                 end 
                                 if (rx_state_v == RXST_DATA_COMPL)
                                 begin
                                    rx_state_v = RXST_IDLE; 
                                    rx_st_ready_v = 1'b1;
                                    // If we have received all of the data (or more) 
                                    if (compl_received_v[rx_compl_tag_v] >= compl_expected_v[rx_compl_tag_v])
                                    begin
                                       // Error if more than expected
                                       if (compl_received_v[rx_compl_tag_v] > compl_expected_v[rx_compl_tag_v])
                                       begin
                                          dummy = ebfm_display(EBFM_MSG_ERROR_FATAL, 
                                                       {"Root Port VC", dimage1(VC_NUM), 
                                                        " Received more completion data than expected. Expected: ", 
                                                        dimage4(compl_expected_v[rx_compl_tag_v]), 
                                                        " Received: ", dimage4(compl_received_v[rx_compl_tag_v])}); 
                                       end 
                                       // Report that it is complete to the Driver
                                       vc_intf_rpt_compl(rx_compl_tag_v, rx_compl_sts_v); 
                                       // Clear out that we expect anymore
                                       compl_received_v[rx_compl_tag_v] = -1; 
                                       compl_expected_v[rx_compl_tag_v] = -1; 
                                       rx_compl_tag_v = -1; 
                                    end
                                    else
                                    begin
                                       // Have not received all of the data yet, but if the
                                       // completion status is not Successful Completion then we
                                       // need to treat as done
                                       if (rx_compl_sts_v != 3'b000)
                                       begin
                                          // Report that it is complete to the Driver
                                          vc_intf_rpt_compl(rx_compl_tag_v, rx_compl_sts_v); 
                                          // Clear out that we expect anymore
                                          compl_received_v[rx_compl_tag_v] = -1; 
                                          compl_expected_v[rx_compl_tag_v] = -1; 
                                          rx_compl_tag_v = -1; 
                                       end 
                                    end
                                    // Otherwise keep going and wait for more data in another completion 
                                 end
                                 else 
                                 begin
                                    if (rx_state_v == RXST_DATA_NONP_WRITE)
                                    begin
                                       rx_st_ready_v = 1'b0;
                                       rx_state_v = RXST_NONP_REQ; 
                                    end
                                    else
                                    begin
                                       rx_state_v = RXST_IDLE; 
                                       rx_st_ready_v = 1'b1;
                                    end 
                                 end 
                              end
                              else
                              begin
                                 if (bcount_v == 0)
                                 begin
                                    dummy = ebfm_display(EBFM_MSG_ERROR_FATAL, 
                                                 {"Root Port VC", dimage1(VC_NUM), 
                                                  " Rx Byte Count went to zero before last data phase."}); 
                                 end 
                              end 
                           end 
                        end
               RXST_NONP_REQ :
                        begin
                           if (tx_rx_ack == 1'b1)
                           begin
                              rx_state_v = RXST_IDLE; 
                              rx_tx_req_v = 1'b0; 
                              rx_st_ready_v = 1'b1; 
                           end
                           else
                           begin
                              rx_tx_req_v = 1'b1; 
                              rx_state_v = RXST_NONP_REQ; 
                              rx_st_ready_v = 1'b0; 
                           end  
                        end
               default :
                        begin
                        end
            endcase 
         end 
         rx_state         <= rx_state_v ;   
         rx_tx_req        <= rx_tx_req_v ; 
         rx_tx_desc       <= rx_tx_desc_v ; 
         rx_tx_shmem_addr <= rx_tx_shmem_addr_v ; 
         rx_tx_bcount     <= rx_tx_bcount_v ; 
         rx_tx_byte_enb   <= rx_tx_byte_enb_v ; 
         rx_desc_int      <= rx_desc_int_v;
         rx_st_ready      <= rx_st_ready_v;
         rx_payld_length  <= rx_payld_length_v;
         rx_st_sop_last   <= rx_st_sop;
         rx_update_pkt_count <= rx_update_pkt_count_v;
         rx_payld_length     <= rx_payld_length_v;
      end 
   end 

   always @(clk_in)
     begin : main_tx_state
      reg[32767:0] data_pkt_v; 
      integer dphases_v; 
      integer dptr_v; 
      reg[1:0] tx_state_v; 
      reg rx_mask_v;  
      reg[127:0] tx_desc_v; 
      reg[127:0] tx_desc;
      reg[63:0] tx_st_data_v;  
      reg tx_err_v; 
      reg tx_rx_ack_v; 
      integer lcladdr_v; 
      reg req_ack_cleared_v; 
      reg[127:0] req_desc_v; 
      reg req_valid_v; 
      reg[31:0] imm_data_v; 
      reg imm_valid_v; 
      integer exp_compl_tag_v; 
      integer exp_compl_bcount_v; 
      reg tx_st_sop_v;
      reg tx_st_eop_v;
      reg tx_st_valid_v;  
      reg last_req_was_cfg0;
      reg[4:0] time_from_last_sop;
      reg okay_to_transmit;
      reg [9:0] tx_payld_length_v;  
      reg[11:0] tx_update_pkt_count_v;

      if (clk_in == 1'b1)
      begin
         // rising clock edge
         exp_compl_tag_v = -1; 
         exp_compl_bcount_v = 0; 
         if (rstn == 1'b0)
         begin
            // synchronous reset (active low)
            tx_state_v = TXST_IDLE; 
            rx_mask_v = 1'b1;  
            tx_desc_v = {128{1'b0}};  
            tx_st_data_v = {64{1'b0}};  
            tx_err_v = 1'b0; 
            tx_rx_ack_v = 1'b0;
            req_ack_cleared_v = 1'b1;
            tx_st_sop_v = 1'b0;
            tx_st_eop_v = 1'b0; 
            tx_st_valid_v = 1'b0;
            last_req_was_cfg0 = 1'b0;
            time_from_last_sop = 5'h0;
            okay_to_transmit = 1'b0;
            tx_payld_length_v = 11'h0; 
            tx_update_pkt_count_v = 1'b0;
         end
         else
         begin
            // for performance monitor
            tx_update_pkt_count_v = (tx_st_eop == 1'b1) & (tx_st_valid == 1'b1);
            if (tx_desc_v[126]==1'b1) begin
                if (tx_desc_v[105:96]==10'h0)
                    tx_payld_length_v <= 11'h400;   // 1024 DWs
                else
                    tx_payld_length_v <= {1'b0, tx_desc_v[105:96]};
            end 
            
            // Clear any previous acknowledgement if needed
            if (req_ack_cleared_v == 1'b0)
            begin
               req_ack_cleared_v = vc_intf_clr_ack(VC_NUM); 
            end 
             
            rx_mask_v = 1'b1; // This is on in most states 
            tx_rx_ack_v = 1'b0;  
            tx_st_valid_v = 1'b0;
            
            // keep track of the number of clk cycles
            // from the time an sop was transmitted.  
           
            if ((tx_st_sop==1'b1) & (tx_st_valid==1'b1)) 
                time_from_last_sop = 5'h0;
            else if (time_from_last_sop==5'h1F)
                time_from_last_sop = time_from_last_sop;
            else
                time_from_last_sop = time_from_last_sop + 1; 
            
            // after a CFG0 is transmitted, wait some time for
            // the tx_fifo_empty flag to respond.   
            okay_to_transmit=((last_req_was_cfg0==1'b0) | ((tx_fifo_empty==1'b1)& (time_from_last_sop > 5'd20)));
                
            case (tx_state_v)
               TXST_IDLE :
                        begin
                           if (tx_st_ready == 1'b1)
                           begin
                              tx_st_eop_v = 1'b0;
                              if  ((rx_tx_req == 1'b1) & (okay_to_transmit==1'b1) )
                              begin 
                                 rx_mask_v = 1'b0; 
                                 tx_state_v = TXST_DESC; 
                                 tx_desc_v = rx_tx_desc;  
                                 tx_st_sop_v   = 1'b1; 
                                 tx_st_valid_v = 1'b1;
                                 tx_rx_ack_v = 1'b1; 
                                 // Assumes we are getting infinite credits!!!!!
                                 if (rx_tx_bcount > 0)
                                 begin
                                    tx_setup_data(rx_tx_shmem_addr, rx_tx_bcount, rx_tx_byte_enb, data_pkt_v, 
                                                  dphases_v, 1'b0, 32'h00000000); 
                                    dptr_v = 0; 
                                    tx_st_data_v = {rx_tx_desc[95:64], rx_tx_desc[127:96]};  
                                 end
                                 else
                                 begin  
                                    dphases_v = 0; 
                                 end 
                              end 
                              else begin
                                 vc_intf_get_req(VC_NUM, req_valid_v, req_desc_v, lcladdr_v, imm_valid_v, imm_data_v); 
                                 // wait for enough credits for all requests. 
                                 // if the last request was a CFG0, then also wait for the tx_fifo to empty 
                                 // before sending the next request.  
                                 if ((tx_fc_check(req_desc_v, tx_cred)) & (req_valid_v == 1'b1) & (req_ack_cleared_v == 1'b1) & 
                                     (okay_to_transmit==1'b1) )
                                 begin
                                    last_req_was_cfg0 = (req_desc_v[124:120]==5'b00100);
                                    vc_intf_set_ack(VC_NUM); 
                                    req_ack_cleared_v = vc_intf_clr_ack(VC_NUM); 
                                    tx_setup_req(req_desc_v, lcladdr_v, imm_valid_v, imm_data_v, data_pkt_v, dphases_v); 
                                    tx_state_v = TXST_DESC; 
                                    tx_desc_v = req_desc_v; 
                                    tx_st_data_v = {req_desc_v[95:64], req_desc_v[127:96]};  
                                    tx_st_sop_v = 1'b1;
                                    tx_st_valid_v = 1'b1;
                                    if (dphases_v > 0)
                                       dptr_v = 0; 

                                    if (is_non_posted(req_desc_v))
                                    begin
                                       exp_compl_tag_v = req_desc_v[79:72]; 
                                       if (has_data(req_desc_v))
                                       begin
                                          exp_compl_bcount_v = 0; 
                                       end
                                       else
                                       begin
                                          exp_compl_bcount_v = calc_byte_count(req_desc_v); 
                                       end 
                                    end 
                                 end
                                 else
                                 begin
                                    tx_state_v = TXST_IDLE; 
                                    rx_mask_v = 1'b0; 
                                 end 
                              end 
                           end 
                        end 
               TXST_DESC: begin   
                        if (tx_st_ready == 1'b1) begin 
                             tx_st_sop_v = 1'b0;
                             tx_st_valid_v = 1'b1;
                             // Payload with 3DW header, NonQW aligned address, 
                             // pack the first cycle of data with the 2nd 
                             // descriptor cycle
                             if ((dphases_v > 0) & (is_3dw_nonaligned(tx_desc_v))) begin 
                                 tx_st_data_v = {data_pkt_v[63:32], tx_desc_v[63:32]};   
                                 if (dphases_v > 1) begin
                                     tx_state_v = TXST_DATA;
                                 end
                                 else begin
                                     tx_state_v = TXST_IDLE;
                                     tx_st_eop_v = 1'b1;
                                 end
                                 dphases_v = dphases_v - 1; 
                                 dptr_v    = dptr_v + 1;  
                             end
                             // Payload with 4DW header, or QW aligned address,
                             // no desc/data packing
                             else if (dphases_v > 0) begin
                                 tx_st_data_v  = {tx_desc[31:0], tx_desc[63:32]};
                                 tx_state_v = TXST_DATA;  
                             end 
                             // No payload
                             else begin
                                 tx_st_data_v   = {tx_desc[31:0], tx_desc[63:32]};
                                 tx_state_v  = TXST_IDLE;  
                                 tx_st_eop_v = 1'b1;
                             end 
                        end 
               end
               TXST_DATA :
                        begin 

                           // Handle the Tx Data Signals 
                           if (dphases_v > 0)
                           begin
                              tx_st_data_v   = data_pkt_v[(dptr_v*64)+:64];  
                              tx_state_v  = TXST_DATA; 
                              tx_st_eop_v = (dphases_v==1) ? 1'b1 : 1'b0;
                              tx_st_valid_v = (tx_st_ready == 1'b1) ? 1'b1 : 1'b0;
                           end
                           else
                           begin
                              tx_st_data_v  = {64{1'b0}};  
                              tx_state_v = TXST_IDLE;   
                              tx_st_eop_v = 1'b0;
                              tx_st_valid_v = 1'b0;
                           end  
                          
                           if (tx_st_ready == 1'b1) begin 
                               dphases_v = dphases_v - 1; 
                               dptr_v = dptr_v + 1; 
                           end 
                           
                        
                       end
               default :
                        begin 
                        end
            endcase 
         end 
         tx_state <= tx_state_v ; 
         rx_mask <= rx_mask_v ;   
         tx_desc <= tx_desc_v ;    
         tx_err <= tx_err_v ; 
         tx_rx_ack <= tx_rx_ack_v ; 
         exp_compl_tag <= exp_compl_tag_v ; 
         exp_compl_bcount <= exp_compl_bcount_v ; 
         tx_st_eop <= tx_st_eop_v;
         tx_st_sop <= tx_st_sop_v;
         tx_st_valid <= tx_st_valid_v;
         tx_st_data <= tx_st_data_v;
         tx_st_empty <= 1'b0;
         tx_payld_length <= tx_payld_length_v; 
         tx_update_pkt_count <= tx_update_pkt_count_v;
      end 
   end 

 
 
endmodule
