////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//      Logic Core:  PCI/Avalon Bridge Megacore Function
//         Company:  Altera Corporation.
//                       www.altera.com 
//          Author:  IPBU SIO Group               
//
//     Description:  Control Register Module  
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
// $Id: altpciav_control_register.v,v 1.1.1.1 2005/09/20 18:42:13 hhnguyen Exp $
//
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

// Note the CG_A2P_NUM_MAILBOX and CG_NUM_P2A_MAILBOX parameters were added 
// at the last minute to address an issue. They are redundant with the 
// cg_num_a2p_mailbox_i and cg_num_p2a_mailbox_i signals they should always be 
// the same but that is not verified here.

module altpciav_lite_control_register
  #(
    parameter INTENDED_DEVICE_FAMILY = "Stratix",
    parameter CG_NUM_A2P_MAILBOX = 8,
    parameter CG_NUM_P2A_MAILBOX = 8
    )
  (
   // Avalon Interface signals (all synchronous to CraClk_i)
   input             CraClk_i,           // Clock for register access port
   input             CraRstn_i,          // Reset signal  
   input             CraChipSelect_i,    // Chip Select signals
   input [13:2]      CraAddress_i,       // Register (DWORD) specific address
   input [3:0]       CraByteEnable_i,    // Register Byte Enables
   input             CraRead_i,          // Read indication
   output [31:0]     CraReadData_o,      // Read data lines
   input             CraWrite_i,         // Write indication 
   input [31:0]      CraWriteData_i,     // Write Data in 
   output wire            CraWaitRequest_o,   // Wait indication out 
   input             CraBeginTransfer_i, // Begin Transfer (Not Used)
   // PCI Bus, Status, Control and Error Signals
   // Most synchronous to PciClk_i (execpt async Rstn and Intan)
   input             PciClk_i,           // PCI Bus Clock
   input             PciRstn_i,          // PCI Bus Reset
   input             PciIntan_i,         // PCI Bus interrupt
   input [5:0]       PciComp_Stat_Reg_i, // PCI Compiler Stat_Reg
   //output            PciComp_lirqn_o,    // PCI Compiler IRQ 
   input             PciNonpDataDiscardErr_i, // NonPre Data Discarded
   input             PciMstrWriteFail_i, // PCI Master Write failed
   input             PciMstrReadFail_i,  // PCI Master Read failed
   input             PciMstrWritePndg_i, // PCI Master Write Pending
   input             PciComp_MstrEnb_i,  // PCI Master Enable
   // Avalon Interrupt Signals
   // All synchronous to CraClk_i
   //output            CraIrq_o,           // Interrupt Request out
   input             NpmIrq_i,           // NonP Master Interrupt in
   input             PmIrq_i,            // NonP Master Interrupt in
   // Modified Avalon signals to the Address Translation logic
   // All synchronous to CraClk_i
   output            AdTrWriteReqVld_o,  // Valid Write Cycle to AddrTrans  
   output            AdTrReadReqVld_o,   // Read Valid out to AddrTrans
   output [11:2]     AdTrAddress_o,      // Address to AddrTrans
   output [31:0]     AdTrWriteData_o,    // Write Data to AddrTrans
   output [3:0]      AdTrByteEnable_o,   // Write Byte Enables to AddrTrans
   input [31:0]      AdTrReadData_i,     // Read Data in from AddrTrans
   input             AdTrReadDataVld_i  // Read Valid in from AddrTrans
   ) ;

   // Internal connection wires 
   // Modified Avalon signals broadcast to internal modules
   wire   [13:2]     IcrAddress ;       // Address to Internal
   wire   [31:0]     IcrWriteData ;     // Write Data to Internal
   wire   [3:0]      IcrByteEnable ;    // Byte Enables to Internal
   // Modified Avalon signals to/from specific internal modules
   // Avalon to Pci Mailbox
   wire              A2PMbWriteReqVld ; // Valid Write Cycle 
   wire              A2PMbReadReqVld ;  // Read Valid out 
   wire  [31:0]      A2PMbReadData ;    // Read Data in 
   wire              A2PMbReadDataVld ; // Read Valid in 
   // Pci to Avalon Mailbox
   wire              P2AMbWriteReqVld ; // Valid Write Cycle 
   wire              P2AMbReadReqVld ;  // Read Valid out 
   wire  [31:0]      P2AMbReadData ;    // Read Data in 
   wire              P2AMbReadDataVld ; // Read Valid in 
   // Interrupt Module
   wire              RuptWriteReqVld ;  // Valid Write Cycle 
   wire              RuptReadReqVld ;   // Read Valid out 
   wire  [31:0]      RuptReadData ;     // Read Data in 
   wire              RuptReadDataVld ;  // Read Valid in 
   // RdBak Module
   wire              RdBakWriteReqVld ; // Valid Write Cycle 
   wire              RdBakReadReqVld ;  // Read Valid out 
   wire  [31:0]      RdBakReadData ;    // Read Data in 
   wire              RdBakReadDataVld ; // Read Valid in 
   // Mailbox Interrupt Requests
   wire [7:0]        A2PMbRuptReq ;     // Avalon to PCI Interrupt Request         
   wire [7:0]        P2AMbRuptReq ;     // PCI to Avalon Interrupt Request  

   altpciav_lite_cr_avalon i_avalon
   (
    .CraClk_i(CraClk_i),
    .CraRstn_i(CraRstn_i),
    .CraChipSelect_i(CraChipSelect_i),
    .CraAddress_i(CraAddress_i),
    .CraByteEnable_i(CraByteEnable_i),
    .CraRead_i(CraRead_i),
    .CraReadData_o(CraReadData_o),
    .CraWrite_i(CraWrite_i),
    .CraWriteData_i(CraWriteData_i),
    .CraWaitRequest_o(CraWaitRequest_o),
    .AdTrWriteReqVld_o(AdTrWriteReqVld_o),
    .AdTrReadReqVld_o(AdTrReadReqVld_o),
    .AdTrAddress_o(AdTrAddress_o),
    .AdTrByteEnable_o(AdTrByteEnable_o),
    .AdTrReadData_i(AdTrReadData_i),
    .AdTrWriteData_o(AdTrWriteData_o),
    .AdTrReadDataVld_i(AdTrReadDataVld_i)
   ) ;
  
endmodule // altpciav_control_register

     



  
