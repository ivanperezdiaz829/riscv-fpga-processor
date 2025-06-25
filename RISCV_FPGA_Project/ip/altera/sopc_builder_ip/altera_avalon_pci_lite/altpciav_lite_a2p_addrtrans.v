////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//      Logic Core:  PCI/Avalon Bridge Megacore Function
//         Company:  Altera Corporation.
//                       www.altera.com 
//          Author:  IPBU SIO Group               
//
//     Description:  Avalon to PCI Address Translation Module   
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
// $Id: altpciav_lite_a2p_addrtrans.v,v 1.1 2007/06/06 09:53:42 lfching Exp $
//
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

module altpciav_lite_a2p_addrtrans 
  #(
    parameter CB_A2P_ADDR_MAP_IS_FIXED = 0 ,
    parameter CB_A2P_ADDR_MAP_NUM_ENTRIES = 16 ,
    parameter CB_A2P_ADDR_MAP_PASS_THRU_BITS = 12 , 
    parameter CG_AVALON_S_ADDR_WIDTH = 32 ,
    parameter CG_PCI_ADDR_WIDTH = 32 ,
    parameter CG_PCI_DATA_WIDTH = 32 ,
    parameter [1023:0] CB_A2P_ADDR_MAP_FIXED_TABLE = 0
    ) 
  (
   input                              PbaClk_i,        // Clock For Avalon to PCI Trans
   input                              PbaRstn_i,       // Reset signal  
   input [CG_AVALON_S_ADDR_WIDTH-1: 0] PbaAddress_i,    // Must be a byte specific address
   input [(CG_PCI_DATA_WIDTH/8)-1:0]  PbaByteEnable_i, // ByteEnables 
   input                              PbaAddrVld_i,    // Valid indication in 
   output [CG_PCI_ADDR_WIDTH-1:0]     PciAddr_o,       // Is a byte specific address
   output [1:0]                       PciAddrSpace_o,  // DAC Needed 
   output                             PciAddrVld_o,    // Valid indication out (piped)
   input                              CraClk_i,        // Clock for register access port
   input                              CraRstn_i,       // Reset signal  
   input [11:2]                       AdTrAddress_i,   // Register (DWORD) specific address
   input [3:0]                        AdTrByteEnable_i,// Register Byte Enables
   input                              AdTrWriteVld_i,  // Valid Write Cycle in  
   input [31:0]                       AdTrWriteData_i, // Write Data in 
   input                              AdTrReadVld_i,   // Read Valid in
   output     [31:0]                  AdTrReadData_o,  // Read Data out
   output                             AdTrReadVld_o    // Read Valid out (piped) 
   ) ;

   // Address space definitions
   localparam [1:0] ADSP_CONFIG = 2'b11 ;
   localparam [1:0] ADSP_IO =     2'b10 ;
   localparam [1:0] ADSP_MEM64 =  2'b01 ;
   localparam [1:0] ADSP_MEM32 =  2'b00 ;

   // Address that has been specifically indexed down to first enabled byte
   wire [CG_AVALON_S_ADDR_WIDTH-1:0]       ByteAddr ;
   
   // Address directly from the translation tables before being manipulated for 
   // I/O and Config space specifics
   wire [CG_PCI_ADDR_WIDTH-1:0]       RawAddr ;

   // Function to create the byte specific address
   function [CG_AVALON_S_ADDR_WIDTH-1:0] ModifyByteAddr ;
      input [CG_PCI_ADDR_WIDTH-1:0] PbaAddress ;
      input [(CG_PCI_DATA_WIDTH/8)-1:0] PbaByteEnable ;
      reg [7:0] FullBE ;
      begin
         ModifyByteAddr[CG_AVALON_S_ADDR_WIDTH-1:3] = PbaAddress[CG_AVALON_S_ADDR_WIDTH-1:3] ;
         if (CG_PCI_DATA_WIDTH == 64)
           FullBE = PbaByteEnable ;
         else
           FullBE = {4'b0000,PbaByteEnable} ;
         casez (FullBE)
           8'b???????1 :
             ModifyByteAddr[2:0] = {PbaAddress[2],2'b00} ;
           8'b??????10 :
             ModifyByteAddr[2:0] = {PbaAddress[2],2'b01} ;
           8'b?????100 :
             ModifyByteAddr[2:0] = {PbaAddress[2],2'b10} ;
           8'b????1000 :
             ModifyByteAddr[2:0] = {PbaAddress[2],2'b11} ;
           8'b???10000 :
             ModifyByteAddr[2:0] = 3'b100 ;
           8'b??100000 :
             ModifyByteAddr[2:0] = 3'b101 ;
           8'b?1000000 :
             ModifyByteAddr[2:0] = 3'b110 ;
           8'b10000000 :
             ModifyByteAddr[2:0] = 3'b111 ;
           default :
             ModifyByteAddr[2:0] = PbaAddress[2:0] ;
         endcase // casez(FullBE)
      end
   endfunction // ModifyByteAddr
   
   
   // Function to modify the address as needed for Config and I/O Space
   function [CG_PCI_ADDR_WIDTH-1:0] ModifyCfgIO ;
      input [CG_PCI_ADDR_WIDTH-1:0] RawAddr ;
      input [1:0] AddrSpace ;
      begin
         ModifyCfgIO = {CG_PCI_ADDR_WIDTH{1'b0}} ;
         case (AddrSpace)
           ADSP_CONFIG :
             begin
                // For Config Space we need to determine if it is type 0 or type 1
                // If the bus number is 0, assume type 0, else type 1
                if (RawAddr[23:16] == 8'h00)
                  begin
                     // Type 0 - Pass through Function Number and Register Number
                     // Downstream logic only wants a QWORD address in 64-bit mode
                     // otherwise DWORD address in 32-bit mode
                     if (CG_PCI_DATA_WIDTH == 64)
                       ModifyCfgIO[10:3] = RawAddr[10:3] ;
                     else
                       ModifyCfgIO[10:2] = RawAddr[10:2] ;
                     // Type 0 - One Hot Encode Device Number 
                     if (RawAddr[15:11] < 21)
                       begin
                          ModifyCfgIO[RawAddr[15:11]+11] = 1'b1 ;
                       end
                     else
                       begin
                          // synthesis translate_off
                          $display("ERROR: Attempt to issue a Type 0 Cfg transaction to a device number that can't be One-Hot encoded in bits 31:11") ;
                          $stop ;
                          // synthesis translate_on
                       end // else: !if(RawAddr[15:11] < 20)
                  end // if (RawAddr[23:16] == 8'h00)
                else
                  begin
                     // Type 1 - Set Type 1 bit
                     ModifyCfgIO[0] = 1'b1 ;
                     // Type 1 - Pass Through Bus Num, Device Num, Func Num, and Reg Num
                     // Downstream logic only wants a QWORD address in 64-bit mode
                     // otherwise DWORD address in 32-bit mode
                     if (CG_PCI_DATA_WIDTH == 64)
                       ModifyCfgIO[23:3] = RawAddr[23:3] ;
                     else
                       ModifyCfgIO[23:2] = RawAddr[23:2] ;
                  end // else: !if(RawAddr[23:16] == 8'h00)
             end // case: ADSP_CONFIG
           ADSP_IO :
             begin
                // The Byte enables have already been encoded pass them through
                ModifyCfgIO = RawAddr ;
             end
           default :
             begin
                // Memory Space, Pass the address through, but clear the byte specific
                // In 64-bit mode the memory space address should only be a QWORD
                // address, in 32-bit mode it should be a DWORD address
                if (CG_PCI_DATA_WIDTH == 64)
                  ModifyCfgIO[CG_PCI_ADDR_WIDTH-1:3] = RawAddr[CG_PCI_ADDR_WIDTH-1:3] ;
                else
                  ModifyCfgIO[CG_PCI_ADDR_WIDTH-1:2] = RawAddr[CG_PCI_ADDR_WIDTH-1:2] ;
             end
         endcase // case(AddrSpace)
      end
   endfunction
         
   assign ByteAddr = ModifyByteAddr(PbaAddress_i,PbaByteEnable_i) ;
             
          altpciav_lite_a2p_vartrans  
            #(.CB_A2P_ADDR_MAP_NUM_ENTRIES(CB_A2P_ADDR_MAP_NUM_ENTRIES),
              .CB_A2P_ADDR_MAP_PASS_THRU_BITS(CB_A2P_ADDR_MAP_PASS_THRU_BITS),
              .CG_AVALON_S_ADDR_WIDTH(CG_AVALON_S_ADDR_WIDTH),
              .CG_PCI_ADDR_WIDTH(CG_PCI_ADDR_WIDTH)
              )
              vartrans
              (
               .PbaClk_i(PbaClk_i),
               .PbaRstn_i(PbaRstn_i),
               .PbaAddress_i(ByteAddr),
               .PbaAddrVld_i(PbaAddrVld_i),
               .PciAddr_o(RawAddr),
               .PciAddrSpace_o(PciAddrSpace_o),
               .PciAddrVld_o(PciAddrVld_o),
               .CraClk_i(CraClk_i),
               .CraRstn_i(CraRstn_i),
               .AdTrAddress_i(AdTrAddress_i),
               .AdTrByteEnable_i(AdTrByteEnable_i),
               .AdTrWriteVld_i(AdTrWriteVld_i),
               .AdTrWriteData_i(AdTrWriteData_i),
               .AdTrReadVld_i(AdTrReadVld_i),
               .AdTrReadData_o(AdTrReadData_o),
               .AdTrReadVld_o(AdTrReadVld_o)
               ) ;   

   assign PciAddr_o = ModifyCfgIO(RawAddr,PciAddrSpace_o) ;
   
endmodule // altpciav_lite_a2p_addrtrans

