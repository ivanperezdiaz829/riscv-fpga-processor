////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//      Logic Core:  PCI/Avalon Bridge Megacore Function
//         Company:  Altera Corporation.
//                       www.altera.com 
//          Author:  IPBU SIO Group               
//
//     Description:  Control Register Avalon Interface Module  
// 
// Copyright (c) 2004 Altera Corporation. All rights reserved.  This source code
// is highly confidential and proprietary information of Altera and is being
// provided in accordance with and subject to the protections of a
// Non-Disclosure Agreement which governs its use and disclosure.  Altera
// products and services are protected under numerous U.S. and foreign patents,
// maskwork rights, copyrights and other intellectual property laws.  Altera
// assumes no responsibility or liability arising out of the application or use
// of this source code.
// 
// For Best Viewing Set tab stops to 4 spaces.
// 
// $Id: altpciav_cr_avalon.v,v 1.1.1.1 2005/09/20 18:42:13 hhnguyen Exp $
//
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//
// This sub module of the PCI/Avalon Bridge Control Register module handles the
// handshaking between the Avalon Switch Fabric and the other sub-modules that 
// actually implement the registers.
//
// A rough block diagram of this module is:
// 
// Avalon                                          Write Data, Byte Enables
// Write Data, >---------------------------------> Broadcast to
// Byte Enables    No registers on Write Data,     Sub-Modules
//                 Byte Enables or Address since
// Avalon          they are static (WaitReq)       Address
// Address >-+-----------------------------------> Broadcast to
//           |                                     Sub-Modules
//           |               
//           | +------+ +--+
//           +-|Decode|-|  |--+----------+
//             +------+ |> |  |          |
//                      +--+  |        +---+       Individual 
//                            |        |DE |       Read, Write 
//                 +----------+      +-|MUX|-----> Valids to each  
//                 |                 | +---+       Sub-Module 
//               +---+  +--+         |         
// Sub-Module    |MUX|--|  |---------)-----------> Read Data 
// Read Data >---|   |  |> |         |             to Avalon
//               +---+  +--+         |
//                 |                 |
// Sub-Module    +---+               |
// Read Data     |MUX|--+ (Selected  | 
// Valids >------|   |  |  Read      |
//               +---+  |  Valid)    |
//                      |            |
//           +----------+            |
//           |                       |
// Avalon    |  +-----+ +--+  State  | +------+   
// Write,    +--|Next |-|  |--+------+-|Decode|--> Wait Request
// Read, >------|State| |> |  |        +------+    to Avalon
// Chip-     +--|     | +--+  |
// Select    |  +-----+       |
//           |                |
//           +----------------+
//
// The register sub-module abbreviations and definitions are:
//   AdTr   - Address Translation (Actually external to Control Register)
//   A2PMb  - Avalon to PCI Mailbox registers
//   P2AMb  - PCI to Avalon Mailbox registers
//   Rupt   - Interrupt Status and Enable registers
//   RdBak  - Parameter ReadBack registers
//   Icr    - Not a sub-module but Abbreviation for:
//              "Internal Control Register broadcast"
//     
module altpciav_lite_cr_avalon
  (
   // Avalon Interface signals (all synchronous to CraClk_i)
   input             CraClk_i,           // Clock for register access port
   input             CraRstn_i,          // Reset signal  
   input             CraChipSelect_i,    // Chip Select signals
   input [13:2]      CraAddress_i,       // Register (DWORD) specific address
   input [3:0]       CraByteEnable_i,    // Register Byte Enables
   input             CraRead_i,          // Read indication
   output reg [31:0] CraReadData_o,      // Read data lines
   input             CraWrite_i,         // Write indication 
   input [31:0]      CraWriteData_i,     // Write Data in 
   output reg        CraWaitRequest_o,   // Wait indication out 
   input             CraBeginTransfer_i, // Start of Transfer (not used)
   // Modified Avalon signals to the Address Translation logic
   // All synchronous to CraClk_i
   output reg        AdTrWriteReqVld_o,  // Valid Write Cycle to AddrTrans  
   output reg        AdTrReadReqVld_o,   // Read Valid out to AddrTrans
   output [11:2]     AdTrAddress_o,      // Register (DWORD) specific address
   output [3:0]      AdTrByteEnable_o,   // Register Byte Enables
   input [31:0]      AdTrReadData_i,     // Read Data in from AddrTrans
   output [31:0]     AdTrWriteData_o,    // Write Data out to AddrTrans
   input             AdTrReadDataVld_i  // Read Valid in from AddrTrans
   // Modified Avalon signals broadcast to internal modules
   // Modified Avalon signals to/from specific internal modules
   ) ;

   // Registered versions of Avalon Inputs

   reg [13:2] IcrAddress_o;       // Address to Internal
   reg [31:0] IcrWriteData_o;     // Write Data to Internal
   reg [3:0]  IcrByteEnable_o;    // Byte Enables to Internal
   reg               sel_read_vld ;
   reg [31:0]        sel_read_data ;
   
   // State Machine for control the state of the interface
   localparam [4:0]   CRA_IDLE       = 5'b00000 ;
   localparam [4:0]   CRA_WRITE_ACK  = 5'b00011 ;
   localparam [4:0]   CRA_READ_FIRST = 5'b00101 ;
   localparam [4:0]   CRA_READ_WAIT  = 5'b01001 ;
   localparam [4:0]   CRA_READ_ACK   = 5'b10001 ;
   reg [4:0]         avalon_state_reg ;

   // Decoded Address Register 
   localparam CRA_NONE_SEL      = 0 ;
   localparam CRA_A2P_MB_SEL    = 1 ;
   localparam CRA_P2A_MB_SEL    = 2 ;
   localparam CRA_RUPT_SEL      = 3 ;
   localparam CRA_RDBAK_SEL     = 4 ;
   localparam CRA_ADDRTRANS_SEL = 5 ;
   reg [CRA_ADDRTRANS_SEL:CRA_NONE_SEL] addr_decode_reg ;
   
   // Address Decode Function
   // Encapsulate in a function to make the mainline code
   // streamlined and avoid need for another signal if we
   // were to do it in a separate combinational always block
   function [CRA_ADDRTRANS_SEL:CRA_NONE_SEL] address_decode ;
      input [13:8] Address_i ;
      begin
         address_decode = 0 ;
         casez (Address_i)
           6'b000000, 6'b110000 :
             address_decode[CRA_RUPT_SEL] = 1'b1 ;
         6'b01????:
             address_decode[CRA_ADDRTRANS_SEL] = 1'b1 ;
           default
             address_decode[CRA_NONE_SEL] = 1'b1 ;
         endcase
     end
   endfunction // address_decode
   
   // Address, Data, Control and Address Decode Register
   always @(posedge CraClk_i or negedge CraRstn_i)
     begin
        if (CraRstn_i == 1'b0)
          begin
             addr_decode_reg <= 6'b000000 ;
          end
        else
          begin
             if (avalon_state_reg == CRA_IDLE)
               addr_decode_reg <= address_decode(CraAddress_i[13:8]) ;
             else
               addr_decode_reg <= addr_decode_reg ;          
             CraReadData_o  <= sel_read_data ;
          end
     end // always @ (posedge CraClk_i or negedge CraRstn_i)

   // Drive these signals straight through for now they are stable for
   // multiple cycles
   always @(CraWriteData_i or CraByteEnable_i or CraAddress_i)
     begin
        IcrAddress_o    = CraAddress_i ;
        IcrByteEnable_o = CraByteEnable_i ;
        IcrWriteData_o  = CraWriteData_i ;
     end

   // Provide Copies of these signals so hookup is straightforward at next 
   // level up
   assign AdTrWriteData_o  = IcrWriteData_o ;
   assign AdTrAddress_o    = IcrAddress_o[11:2] ;
   assign AdTrByteEnable_o = IcrByteEnable_o ;

   // Main state machine
   always @(posedge CraClk_i or negedge CraRstn_i)
     begin
        if (CraRstn_i == 1'b0)
          avalon_state_reg <= CRA_IDLE ;
        else
          case (avalon_state_reg)
            CRA_IDLE :
              begin
                 if (CraChipSelect_i == 1'b1)
                   begin
                      if (CraRead_i == 1'b1)
                        begin
                           avalon_state_reg <= CRA_READ_FIRST ;
                        end
                      else
                        begin
                           avalon_state_reg <= CRA_WRITE_ACK ;
                           // synthesis translate_off
                           if (CraWrite_i != 1'b1)
                           begin
                              $display("ERROR: CRA Slave received ChipSelect without Read or Write") ;
                              $stop ;
                           end
                           // synthesis translate_on
                        end // else: !if(CraRead_i == 1'b1)
                   end // if (CraChipSelect_i == 1'b1)
                 else
                   begin
                      avalon_state_reg <= CRA_IDLE ;
                   end // else: !if(CraChipSelect_i == 1'b1)
              end // case: CRA_IDLE
            CRA_READ_FIRST, CRA_READ_WAIT :
              begin
                 if (sel_read_vld == 1'b1)
                   begin
                      avalon_state_reg <= CRA_READ_ACK ;
                   end
                 else
                   begin
                      avalon_state_reg <= CRA_READ_WAIT ;
                   end
              end // case: CRA_READ_FIRST, CRA_READ_WAIT
            CRA_READ_ACK, CRA_WRITE_ACK :
              begin
                 avalon_state_reg <= CRA_IDLE ;
              end // case: CRA_READ_ACK, CRA_WRITE_ACK
          endcase // case(avalon_state_reg)
     end // always @ (posedge CraClk_i or negedge CraRstn_i)
   
   // Generate the Output Controls
   always @(avalon_state_reg or addr_decode_reg)
     begin
        if (avalon_state_reg == CRA_READ_FIRST)
          begin
             AdTrReadReqVld_o   = addr_decode_reg[CRA_ADDRTRANS_SEL] ;
          end
        else
          begin
             AdTrReadReqVld_o   = 1'b0 ;
          end
        if (avalon_state_reg == CRA_WRITE_ACK)
          begin
             AdTrWriteReqVld_o  = addr_decode_reg[CRA_ADDRTRANS_SEL] ;
          end
        else
          begin
             AdTrWriteReqVld_o  = 1'b0 ;
          end // else: !if(avalon_state_reg == CRA_WRITE_ACK)
        if ( (avalon_state_reg == CRA_WRITE_ACK) || 
             (avalon_state_reg == CRA_READ_ACK) )
          CraWaitRequest_o = 1'b0 ;
        else
          CraWaitRequest_o = 1'b1 ;
     end // always @ (avalon_state_reg or addr_decode_reg)

   always @(addr_decode_reg or AdTrReadData_i or AdTrReadDataVld_i)
     begin
        sel_read_vld  = 1'b0 ;
        sel_read_data = 1'b0 ;
        if (addr_decode_reg[CRA_ADDRTRANS_SEL] == 1'b1)
          begin
             sel_read_vld  = sel_read_vld  | AdTrReadDataVld_i ;
             sel_read_data = sel_read_data | AdTrReadData_i ;
          end
        if (addr_decode_reg[CRA_NONE_SEL] == 1'b1)
          begin
             sel_read_vld  = 1'b1 ;
          end
     end
   
endmodule // altpciav_cr_avalon

