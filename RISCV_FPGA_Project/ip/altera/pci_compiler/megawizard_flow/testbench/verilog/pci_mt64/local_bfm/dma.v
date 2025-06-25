//------------------------------------------------------------------
//  Altera PCI testbench
//  MODULE NAME: dma
//
//******************************************************************************************************
//  FUNCTIONAL DESCRIPTION:
// This file describes the dma engine
// it has two 32 bit registers dma_sa and dma_bc_la.
// In order to initiate PCI transactions with Altera PCI MegaCore as Master, 
// you need to perform 32 bit single cycle write to dma_sa 
// followed by a 32 bit single cycle write to dma_bc_la. 
// On being triggered the master control unit will request for the bus 
// and execute the transaction as decoded by the dma_bc_la.
// dma_sa:  This  register defines the system address (sa). 
//         This address is driven on the address phase of the PCI transaction.
// dma_bc_la: This register defines the byte count(bc) ,local address(la), 
//            transaction width(32/64) and data direction
// dma_bc_la register definition
//               [31..28]        [27..16]     [15..8]        [7..0]
//       Transaction width       Reserved     Byte Count     Local Address
//        and data direction
// The following table describes the functions that can be performed 
// depending on the value of dma_bc_la[31:28]
// dma_bc_la[31:28]      Function
//          0000        32 bit Memory Read
//          0010        64 bit Memory Read
//          0100        32 bit IO Read
//          0110        32 bit IO write
//          1000        32 bit Memory write
//          1010        64 bit Memory write
//

// This design implements  BAR2 for the dma_sa and dma_bc_la registers
//-------------------------------------------------------------------------------------------------- 
// Memory Region  Mapping       Block size  Address Offset  Description
//--------------------------------------------------------------------------------------------------
// BAR2           Memory Mapped 1 Kbyte     000-3FF         Maps the trg_termination register and
//                                                          DMA engine registers. Only the lower 24
//                                                          Bytes of the address space are used.
//--------------------------------------------------------------------------------------------------
// BAR2 Register Mapping
//--------------------------------------------------------------------------------------------------
// Address Space Range Reserved Mnemonic                Register Name
// BAR2          00h-03h        targ_termination_reg    Target termination register.
// BAR2          04h-07h        dma_sa[31:0]            DMA system address register
// BAR2          08h-0Bh        dma_bc_la[31:0]         DMA byte count and local address register

//******************************************************************************************************
//  REVISION HISTORY:  
//  Revision 1.3 Description: Changed the code to make it synthesizable
//  Revision 1.2 Description: No change.
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

`timescale 1 ns / 1 ns

module dma (Clk,                // Clk  
            Rstn,               // Reset
            
            
            Pcil_dat_i,         // PCI Data Input
            Pcil_adr_i,         // PCI Address
            Pcil_cmd_i,         // PCI Command
            
            
            Pcilt_rdy_n_o,      // PCI local Trdyn
            Pcilt_frame_n_i,    // PCI Local framen
            Pcilt_ack_n_i,      // PCI local ackowledgement
            Pcilt_dxfr_n_i,     // PCI local data transfer
            Pcilt_tsr_i,        // PCI local status register
            
            Mstr_done_i,        // Master Done Input
            Mstr_strt_o,        // Master Start Ouput
            Mstr_dma_sa_o,      // Master dma and system address
            Mstr_dma_bc_la_o);  // Master dma, byte_count, and local address

//------------------------------------------------------------------------------
//-----------------IO Declarations----------------------------------------------
//------------------------------------------------------------------------------

   input               Clk; 
   input               Rstn; 
   input    [63:0]     Pcil_dat_i; 
   input    [63:0]     Pcil_adr_i; 
   input    [3:0]      Pcil_cmd_i;  
   input               Pcilt_frame_n_i; 
   input               Pcilt_ack_n_i; 
   input               Pcilt_dxfr_n_i; 
   input    [11:0]     Pcilt_tsr_i; 
   input               Mstr_done_i; 
                       
   output              Pcilt_rdy_n_o;   
   output              Mstr_strt_o; 
   output   [31:0]     Mstr_dma_sa_o; 
   output   [31:0]     Mstr_dma_bc_la_o; 
                       
   wire     [31:0]     Mstr_dma_sa_o;   
   wire     [31:0]     Mstr_dma_bc_la_o;
                       

//------------------------------------------------------------------------------
//-----------------Local Declarations-------------------------------------------
//------------------------------------------------------------------------------


   parameter        IDLE        = 4'b0000; 
   parameter        LD_SA       = 4'b0011; 
   parameter        LD_BC_LA    = 4'b0101; 
   parameter        MSTR_ACTIVE = 4'b1001; 
   
   reg  [3:0]       state; 
   reg  [3:0]       nxstate; 
   reg  [31:0]      dma_sect_addr; 
   reg  [31:0]      dma_bytecnt_locaddr; 
   
   reg              Mstr_strt_o;
   wire             sx_data_tx; 


//------------------------------------------------------------------
//-----------------Logic--------------------------------------------
//------------------------------------------------------------------

//********************************************
//nxt_state_generator:
//********************************************
always @(posedge Clk or negedge Rstn)
begin : nxt_state_gen
   if (!Rstn)
      state <= IDLE ; 
   else
      state <= nxstate; 
end 


//***************************************************
//state_machine_controller:
//****************************************************


always @(Pcilt_frame_n_i or Pcil_cmd_i or state or Pcilt_tsr_i 
            or Mstr_done_i or Pcil_adr_i or sx_data_tx)

begin : state_machine_controller
   case (state)
      IDLE :
               begin
                  
                  // lt_framen is active, command is target write
                  // lt_tsr(2) indicates it is a BAR2 hit
                  // and address is 04h
                  if (!Pcilt_frame_n_i & Pcil_cmd_i == 4'b0111 & 
                       Pcilt_tsr_i[2] & Pcil_adr_i[3:0] == 4'b0100)
                     nxstate = LD_SA ; 
                  else
                     nxstate = IDLE ; 
               end

      // Load System Address
      LD_SA :
               begin
                  if (sx_data_tx)
                     nxstate = LD_BC_LA ; 
                  else
                     nxstate = LD_SA ; 
               end
      // Load Command, Byte Count and Local address
      LD_BC_LA :
               begin
                  if (sx_data_tx)
                     nxstate = MSTR_ACTIVE ; 
                  else
                     nxstate = LD_BC_LA ; 
               end

      // Remain in Master active state till Master Controller finishes the transaction
      // Described in dma_bytecnt_locaddr
      MSTR_ACTIVE :
               begin
                  if (Mstr_done_i)
                     nxstate = IDLE ; 
                  else
                     nxstate = MSTR_ACTIVE ; 
               end

      default :
               begin
                  nxstate = IDLE ; 
               end

   endcase 
end 
   


assign  Mstr_dma_sa_o     = dma_sect_addr ;          // load system address                 
assign  Mstr_dma_bc_la_o  = dma_bytecnt_locaddr ;    // load byte count and local address 
assign  sx_data_tx        = ~(Pcilt_dxfr_n_i) & ~(Pcilt_ack_n_i);//successful data transfer  

// lt_rdyn signal is driven to indicate that DMA engine is ready to accpt data
// to load dma_sa and dma_bc_la
assign  Pcilt_rdy_n_o     = (state[1] | state[2]) ? 1'b0 : 1'b1 ; 

//************************************************
//DMA System Address
//During Master Read or Write this address will
//be put on PCI bus during address phase
//************************************************

always @(posedge Clk or negedge Rstn)
begin   
   if (!Rstn) 
       dma_sect_addr <= 32'b0; 
   else 
     begin        
        if (~state[0])                   
            dma_sect_addr <= 32'b0; 
        else if ( state[1] & sx_data_tx & Pcil_adr_i[3:0] == 4'b0100)   
             dma_sect_addr <= Pcil_dat_i[31:0] ; 
     end        
end 


//**************************************************************************
//DMA Command Byte Count and Local Address
//This register indicates the Master state machine regarding the following
//What operation to perfrom
// dma_bc_la[31:28]      Function
//          0000        32 bit Memory Read
//          0010        64 bit Memory Read
//          0100        32 bit IO Read
//          0110        32 bit IO write
//          1000        32 bit Memory write
//          1010        64 bit Memory write
//What is the bytes to transfer.
//And what is the local side SRAM Memory address.
//*************************************************************************
always @(posedge Clk or negedge Rstn)
begin   
   if (!Rstn) 
       dma_bytecnt_locaddr <= 32'b0; 
   else 
     begin        
        if (~state[0])                   
            dma_bytecnt_locaddr <= 32'b0; 
        else if ( state[2] & sx_data_tx & Pcil_adr_i[3:0] == 4'b1000)   
             dma_bytecnt_locaddr <= Pcil_dat_i[31:0] ; 
     end        
end 

//***********************************************************************
//Master Start Register
//This signal will trigger Master State machine in local_master
//***********************************************************************
always @(posedge Clk or negedge Rstn)
begin   
   if (!Rstn) 
       Mstr_strt_o <= 1'b0; 
   else 
     if(Mstr_done_i)
      Mstr_strt_o <= 1'b0; 
     else
      Mstr_strt_o <= state[3];
end 




endmodule
