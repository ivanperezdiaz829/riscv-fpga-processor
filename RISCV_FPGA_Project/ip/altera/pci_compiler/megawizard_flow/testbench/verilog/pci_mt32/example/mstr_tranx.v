//---------------------------------------------------------------------------------------
//  Altera PCI testbench
//  MODULE NAME: mstr_tranx

//  FUNCTIONAL DESCRIPTION:
//  Master transactor initiates Master transaction on the PCI bus
//  This file is only for simulation.

//  REVISION HISTORY:  
//  Revision 1.2   Description: 
//                 Changed the configuration address and 
//                 configuration data to be `Define. 
//                 Added explanation for the master commands
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
 
module mstr_tranx (clk,                      // clock                                                    
                   rstn,                     // reset                                                   
                   ad,                       // Address                                                 
                   cben,                     // command byte enable                                     
                   par,                      // parity for low dword                                    
                   reqn,                     // Master transactor request
                   gntn,                     // Master transactor grant                                 
                   framen,                   // framen                                
                   irdyn,                    // irdyn  
                   devseln,                  // devseln                                                                                         
                   trdyn,                    // target ready signal                                                                             
                   stopn,                    // stopn                                                                                           
                   perrn,                    // parity error                                                                                    
                   serrn,                    // system error                                                                                    
                   busfree,                  // indicates that the bus is idle                                                                  
                   disengage_mstr,           // indicates to disengage the current transaction                                                  
                   tranx_success,            // transaction successful                                                                          
                   trgt_tranx_disca,         // target TRANSACTOR disconnect-A                                                                  
                   trgt_tranx_discb,         // target TRANSACTOR disconnect-B                                                                  
                   trgt_tranx_retry);        // target TRANSACTOR retry.                                                                        
                                                      
   input clk;                                         
   output rstn;                                       
   reg rstn;
   inout[31:0] ad; 
   wire[31:0] ad;
   reg[31:0] ad_out;
   inout[3:0] cben; 
   wire[3:0] cben;
   reg[3:0] cben_out;
   inout par; 
   wire par;
   reg par_out;
   output reqn; 
   wire reqn;
   input gntn; 
   inout framen; 
   wire framen;
   reg framen_out;
   inout irdyn; 
   wire irdyn;
   reg irdyn_out;
   input devseln; 
   input trdyn; 
   input stopn; 
   inout perrn; 
   wire perrn;
   reg perrn_out;
   inout serrn; 
   wire serrn;
   reg serrn_out;
   input busfree; 
   input disengage_mstr; 
   input tranx_success; 
   output trgt_tranx_disca; 
   reg trgt_tranx_disca;
   output trgt_tranx_discb; 
   reg trgt_tranx_discb;
   output trgt_tranx_retry; 
   reg trgt_tranx_retry;


   parameter tdel = 0; 
   reg par_en; 
   reg mstr_tranx_reqn; 
   wire mstr_tranx_gntn; 

   assign ad = ad_out;
   assign cben = cben_out;
   assign par = par_out;
   assign framen = framen_out;
   assign irdyn = irdyn_out;
   assign perrn = perrn_out;
   assign serrn = serrn_out;
   
   assign reqn = mstr_tranx_reqn;
   assign mstr_tranx_gntn = gntn;


//********************************************************************
//Include Master Package
//The mstr_pkg file consists description of the following tasks
//  cfg_wr(Address, Data, Byte_Enable) 
//  cfg_rd(Address)
//  mem_wr_32(Address, Data, Number of Dwords)     
//  mem_rd_32(Address, Number of Dwords)        
//  io_wr(Address, Data)     
//  io_rd(Address)
//  drive_z
//  sys_rst      
//***********************************************************************

   `include "../tb_src/mstr_pkg.v"       

//*************************************
//Main
//**************************************

   always 
   begin : main
      
      @(posedge clk); 
      trgt_tranx_disca <= 1'b0 ; 
      trgt_tranx_discb <= 1'b0 ; 
      trgt_tranx_retry <= 1'b0 ; 
      par_en <= 1'b0 ; 
      mstr_tranx_reqn <= 1'b1 ; 
      perrn_out <= 1'bz ; 
      serrn_out <= 1'bz ; 
      drive_z; 
         
      
      //*************************************************************************
      // Configuration Address Space    
      //*************************************************************************
      
      // idsel of PCI MegaCore function is tied to ad[28]
      `define DeviceVendorIDAddress     32'h10000000  
      `define StatusCommandRegAddress   32'h10000004
                                        
      `define bar0_address              32'h10000010
      `define bar1_address              32'h10000014
      `define bar2_address              32'h10000018
                                        
      
      // idsel of Target Transactor is tied to ad[29]
      `define trgt_tranx_bar0_address   32'h20000010  
      `define trgt_tranx_bar1_address   32'h20000014
      
           
      //*************************************************************************
      // Defines the data to be written in the Configuration Space
      //*************************************************************************
      `define CommandRegister_Data      32'h00000147  // Command Register Data
                                        
      `define bar0_data                 32'h10000000  //  PCI Bar0 data
      `define bar1_data                 32'hfffff3C0  //  PCI Bar1 data
      `define bar2_data                 32'h55000000  //  PCI Bar2 data
                                        
      `define trgt_tranx_bar0_data      32'h20000000  //  Target Transactor Bar0 data
      `define trgt_tranx_bar1_data      32'hfffff2C0  //  Target Transactor Bar1 data

        
      `define EnableAll                 4'h0          // Byte Enables


//**********************************
//INITIALIZATION
//**********************************

       // System Reset
       sys_rst (10,3);                                
      
//************************************
//USER COMMANDS
//*************************************
          
//--------------------------------------------------
// Configuration Writes( Address, Data, Byte_Enables) 
// cfg_wr(32'h10000004, 32'h00000147, 4'b0000);
//--------------------------------------------------
      cfg_wr(`StatusCommandRegAddress, `CommandRegister_Data, `EnableAll);      //config write to command register    
      cfg_wr(`bar0_address, `bar0_data, `EnableAll);                            //config write to command register    
      cfg_wr(`bar1_address, `bar1_data, `EnableAll);                            //config write to command register    
      cfg_wr(`bar2_address, `bar2_data, `EnableAll);                            //config write to command register        
      cfg_wr(`trgt_tranx_bar0_address, `trgt_tranx_bar0_data, `EnableAll);      //config write to bar0 of Target Transactor  
      cfg_wr(`trgt_tranx_bar1_address, `trgt_tranx_bar1_data, `EnableAll);      //config write to bar0 of Target Transactor  
      
//-----------------------------------------------------
// Configuration Read(Address)
// cfg_rd(32'h10000004); 
//-----------------------------------------------------         
      cfg_rd(`StatusCommandRegAddress);                //config read of command register            
      cfg_rd(`bar0_address);                           //config read of bar0 of Altera PCI MegaCore
      cfg_rd(`bar1_address);                           //config read of bar1 of Altera PCI MegaCore
      cfg_rd(`bar2_address);                           //config read of `bar2_data of Altera PCI MegaCore
      cfg_rd(`trgt_tranx_bar0_address);                //config read of target transactor Bar0
      cfg_rd(`trgt_tranx_bar1_address);                //config read of target transactor Bar1
            
//---------------------------------------------------      
// 32 bit memory write(Address, Data, Number of Dwords)   
// mem_wr_32(32'h10000000, 32'h00000001, 1);   
//---------------------------------------------------    
      
      //Write to the Reference design in the backend  
      
      mem_wr_32(`bar0_data, 32'h00000001, 1); 
      mem_wr_32(`bar0_data, 32'h00000001, 2); 
      mem_wr_32(`bar0_data, 32'h00000001, 3); 
      mem_wr_32(`bar0_data, 32'h00000001, 4); 
      mem_wr_32(`bar0_data, 32'h00000001, 5); 

    
    //Write to the target transactor
    
      mem_wr_32(`trgt_tranx_bar0_data, 32'h00000001, 1); 
      mem_wr_32(`trgt_tranx_bar0_data, 32'h00000001, 2); 
      mem_wr_32(`trgt_tranx_bar0_data, 32'h00000001, 3); 
      mem_wr_32(`trgt_tranx_bar0_data, 32'h00000001, 4); 
      mem_wr_32(`trgt_tranx_bar0_data, 32'h00000001, 5); 


//--------------------------------------------------
// 32 bit memory read(Address, Number of Dwords)
// mem_rd_32(32'h10000000, 1); 
//---------------------------------------------------          
     
     //Read to the Reference design in the backend  
   
      mem_rd_32(`bar0_data, 1); 
      mem_rd_32(`bar0_data, 2); 
      mem_rd_32(`bar0_data, 3); 
      mem_rd_32(`bar0_data, 4); 
      mem_rd_32(`bar0_data, 5); 
   
     //Read to the target transactor
      mem_rd_32(`trgt_tranx_bar0_data, 1); 
      mem_rd_32(`trgt_tranx_bar0_data, 2); 
      mem_rd_32(`trgt_tranx_bar0_data, 3); 
      mem_rd_32(`trgt_tranx_bar0_data, 4); 
      mem_rd_32(`trgt_tranx_bar0_data, 5); 

//-----------------------------------------
// io write transaction(Address, Data)  
// io_wr(32'hfffff3c0, 32'h00000111);   
//-----------------------------------------      

      //Write to the Reference design in the backend       
      io_wr(`bar1_data, 32'h00000111); 
      
      //Write to the target transactor
      io_wr(`trgt_tranx_bar1_data, 32'h00000222); 
      

//-----------------------------------------------
// io read transaction(Address) 
// io_rd(32'hfffff2c0);      
//-----------------------------------------------         
    
      //Read to the Reference design in the backend    
      io_rd(`bar1_data); 
  
     //Read to the target transactor
     io_rd(`trgt_tranx_bar1_data); 
  
//----------------------------------------------------------------------------
//Target termination examples with Reference desgin and Altera PCI Megacore 
//as the PCI interface
//----------------------------------------------------------------------------

//The following command will configure the register in the local target reference design
//that will make the following 64 bit transaction to disconnect.     
  
      mem_wr_32(`bar2_data, 32'h00000002, 1);   //Target disconnect
      mem_wr_32(`bar0_data, 32'h00000001, 5); 
    

//Note: The local target will not do a disconnect on memory read.    
  
//The following command will configure the register in the local target reference design
//that will make the next transaction to retry.     
  
      mem_wr_32(`bar2_data, 32'h00000001, 1); //Target Retry
      mem_wr_32(`bar0_data, 32'h00000001, 5); 
    
      mem_wr_32(`bar2_data, 32'h00000001, 1); //Target Retry
      mem_rd_32(`bar0_data, 5); 
  
//-----------------------------------------------------------------------         
//Target termination examples  with TARGET TRANSACTOR(target-tranx)
//-----------------------------------------------------------------------     

//Target retry 
  
      trgt_tranx_retry <= 1'b1 ; 
      mem_wr_32(`trgt_tranx_bar0_data, 32'h00000001, 5); 
      trgt_tranx_retry <= 1'b0 ; 
  
      trgt_tranx_retry <= 1'b1 ; 
      mem_rd_32(`trgt_tranx_bar0_data, 1); 
      trgt_tranx_retry <= 1'b0 ; 
     
//Disconnect-A ( disconnect with data)    

      trgt_tranx_disca <= 1'b1 ; 
      mem_wr_32(`trgt_tranx_bar0_data, 32'h00000001, 5); 
      trgt_tranx_disca <= 1'b0 ; 
  
      trgt_tranx_disca <= 1'b1 ; 
      mem_rd_32(`trgt_tranx_bar0_data, 5); 
      trgt_tranx_disca <= 1'b0 ; 

//Disconnect-B( disconnect without data)
  
      trgt_tranx_discb <= 1'b1 ; 
      mem_wr_32(`trgt_tranx_bar0_data, 32'h00000001, 5); 
      trgt_tranx_discb <= 1'b0 ; 
  
  
      trgt_tranx_discb <= 1'b1 ; 
      mem_rd_32(`trgt_tranx_bar0_data, 5); 
      trgt_tranx_discb <= 1'b0 ; 
  
//----------------------------------------------------------------------------     
//----------------------------------------------------------------------------

//In order to initiate PCI transactions with Altera PCI MegaCore as Master, 
//you need to perform 32 bit single cycle write to dma_sa 
//followed by a 32 bit single cycle write to dma_bc_la. 
//On being triggered the master control unit will request for the bus 
//and execute the transaction as decoded by the dma_bc_la.


//dma_sa:  This  register defines the system address (sa). 
//         This address is driven on the address phase of the PCI transaction.

//dma_bc_la: This register defines the byte count(bc) ,local address(la), 
//            transaction width(32/64) and data direction

//dma_bc_la register definition
//               [31..28]        [27..16]     [15..8]        [7..0]
//       Transaction width       Reserved     Byte Count     Local Address
//        and data direction


//The following table describes the functions that can be performed 
//depending on the value of dma_bc_la[31:28]
//dma_bc_la[31:28]      Function
//          0000        32 bit Memory Read
//          0100        32 bit IO Read
//          0110        32 bit IO write
//          1000        32 bit Memory write


//Refer to the PCI testbench documentation for more details.
     
//----------------------------------------------------------
//Tranasaction with Altera PCI MegaCore function as master
//-----------------------------------------------------------   
                                                                                        
//--------------------------------------------------------------
//memory read transaction(system_address, local_address, no. of dwords)    
//32 bit    
                                                                                        
      mem_wr_32(`bar2_data + 32'h00000004, `trgt_tranx_bar0_data, 1);                                      
      mem_wr_32(`bar2_data + 32'h00000008, 32'h00000100, 1);  //single cycle read                                    
      @(negedge busfree);                                                               
      @(posedge busfree);                                                               
   
      mem_wr_32(`bar2_data + 32'h00000004, `trgt_tranx_bar0_data, 1);                                      
      mem_wr_32(`bar2_data + 32'h00000008, 32'h00000200, 1); //burst of  2                                   
      @(negedge busfree);                                                               
      @(posedge busfree);                                                               
   
      mem_wr_32(`bar2_data + 32'h00000004, `trgt_tranx_bar0_data, 1); 
      mem_wr_32(`bar2_data + 32'h00000008, 32'h00000300, 1); //burst of  3                                   
      @(negedge busfree); 
      @(posedge busfree); 
   
      mem_wr_32(`bar2_data + 32'h00000004, `trgt_tranx_bar0_data, 1); 
      mem_wr_32(`bar2_data + 32'h00000008, 32'h00000400, 1); //burst of  4                                   
      @(negedge busfree); 
      @(posedge busfree); 
   
      mem_wr_32(`bar2_data + 32'h00000004, `trgt_tranx_bar0_data, 1); 
      mem_wr_32(`bar2_data + 32'h00000008, 32'h00000500, 1); //burst of  5                                   
      @(negedge busfree); 
      @(posedge busfree); 
      
//----------------------------------------------------------------------
  
//----------------------------------------------------------------------     
     
//memory write transaction(system_address, local_address, no. of dwords)         
//32 bit     
  
      mem_wr_32(`bar2_data + 32'h00000004, `trgt_tranx_bar0_data, 1); 
      mem_wr_32(`bar2_data + 32'h00000008, 32'h80000100, 1);  // single cycle read
      @(negedge busfree);                                               
      @(posedge busfree);                                               
                                                                      
      mem_wr_32(`bar2_data + 32'h00000004, `trgt_tranx_bar0_data, 1);                      
      mem_wr_32(`bar2_data + 32'h00000008, 32'h80000200, 1);  // burst of 2       
      @(negedge busfree);                                               
      @(posedge busfree);                                               
                                                                      
      mem_wr_32(`bar2_data + 32'h00000004, `trgt_tranx_bar0_data, 1);                      
      mem_wr_32(`bar2_data + 32'h00000008, 32'h80000300, 1);  // burst of 3       
      @(negedge busfree);                                               
      @(posedge busfree);                                               
                                                                      
      mem_wr_32(`bar2_data + 32'h00000004, `trgt_tranx_bar0_data, 1); 
      mem_wr_32(`bar2_data + 32'h00000008, 32'h80000400, 1);  // burst of 4                            
      @(negedge busfree);                                               
      @(posedge busfree);                                               
                                                 
      mem_wr_32(`bar2_data + 32'h00000004, `trgt_tranx_bar0_data, 1);  
      mem_wr_32(`bar2_data + 32'h00000008, 32'h80000500, 1);  // burst of 5        
      @(negedge busfree);                           
      @(posedge busfree);                           
     
//-------------------------------------------------------------------------
    
//io write transaction(system_address)             
      mem_wr_32(`bar2_data + 32'h00000004, 32'hFFFFF2C0, 1); 
      mem_wr_32(`bar2_data + 32'h00000008, 32'h60000100, 1); 
      @(negedge busfree); 
      @(posedge busfree); 
  
//----------------------------------------------------------------------
//io read transaction(system_address)             
      mem_wr_32(`bar2_data + 32'h00000004, 32'hFFFFF2C0, 1); 
      mem_wr_32(`bar2_data + 32'h00000008, 32'h40000100, 1); 
      @(negedge busfree); 
      @(posedge busfree); 

      $display("End of Transactions");
      $stop;

   end

//*************************************************************************
//*******End of User Commands
//*************************************************************************


//***************************
//parity gen for lower dword
//***************************
always @(posedge clk)
begin : parity_gen

   reg result_reg; 
   result_reg = ad[31] ^ ad[30] ^ ad[29] ^ ad[28] ^ 
                ad[27] ^ ad[26] ^ ad[25] ^ ad[24] ^ 
                ad[23] ^ ad[22] ^ ad[21] ^ ad[20] ^ 
                ad[19] ^ ad[18] ^ ad[17] ^ ad[16] ^ 
                ad[15] ^ ad[14] ^ ad[13] ^ ad[12] ^ 
                ad[11] ^ ad[10] ^ ad[9] ^ ad[8] ^ 
                ad[7] ^ ad[6] ^ ad[5] ^ ad[4] ^ 
                ad[3] ^ ad[2] ^ ad[1] ^ ad[0] ^ 
                cben[3] ^ cben[2] ^ cben[1] ^ cben[0]; 
   if (par_en)
   begin
      par_out <= #tdel result_reg ; 
      
   end
   else
   begin
      par_out <= #tdel 1'bz ; 
   end  
end 


 
endmodule
