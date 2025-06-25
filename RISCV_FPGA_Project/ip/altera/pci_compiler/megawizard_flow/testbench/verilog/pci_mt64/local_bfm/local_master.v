//------------------------------------------------------------------
//  Altera PCI testbench
//  MODULE NAME: local_master

//*********************************************************************
//  FUNCTIONAL DESCRIPTION:
//  This file implements the local master design

//  The DMA engine triggers the local master. The local master can perform
//  32- and 64-bit memory read/write transactions with the LPM RAM block
//  and 32-bit single-cycle I/O read/write transactions with an I/O register
//  defined in the top local file. 
//  The local master uses prefetch logic for burst memory write transactions 
//  and uses the last_gen block to generate the  lm_lastn signal.
//  The local master ignores byte enables for all memory and I/O
//  transactions.
//  This Reference design will not retry the transaction for any target
//  initiated terminations

//*********************************************************************

//  REVISION HISTORY:
//  Revision 1.3 Description: Changed the code to make it synthesizable.
//  Revision 1.2 Description: Changed the address_inc logic.
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

module local_master (
          Clk,                 // Clk  
          Rstn,                // Reset
          
          PciData_i,           // PCI data out                            
          PciLDataAck_n_i,     // PCI low dword data acknowledge          
          PciHDataAck_n_i,     // PCI high dword data acknowledge         
          PciAdrAck_n_i,       // PCI master address acknoweledge         
          PciAck_n_i,          // PCI master acknoweledge                 
          PciDxfr_n_i,         // PCI master data transfer                
          PciLmTsr_i,          // PCI master status register                                         
          PciAd_o,             // PCI address Output                       
          PciCben_o,           // PCI command and byte enable             
          PciReq32_n_o,        // PCI master request for 32 bit transfer      
          PciReq64_n_o,        // PCI master request for 64 bit transfer      
          PciRdy_n_o,          // PCI master ready                            
          PciLastTx_n_o,       // PCI mater last dword Transfer                 
                                    
          DmaSa_i,             // DMA system address register input                 
          DmaBcLa_i,           // DMA byte count and local address reg. input  
          DmaStrtMstr_i,       // DMA start master input
          PrftchReg_i,         // Prefetch register
          DmaMstrDone_o,       // DMA master done                                      
          MstrDataTx_o,        // Data transfer master 
          MstrPrftchOn_o,      // Prefetch on
          MstrIOWren_o,
          IODat_i,
          
          SramAddr_o,          // SRAM Address_o to the memory                                    
          SramHighWrEn_o,      // SRAM wr enable to the high dword section of the mem     
          SramLowWrEn_o,       // SRAM wr enable to the low dword section of the mem
          SramHighDw_i,        // SRAM high dword output from the memory.                       
          SramLowDw_i);        // SRAM low dword output from the memory.                        



//------------------------------------------------------------------------------
//-----------------IO Declarations----------------------------------------------
//------------------------------------------------------------------------------


   input            Clk; 
   input            Rstn; 
   input   [31:0]   PciData_i; 
   input            PciLDataAck_n_i; 
   input            PciHDataAck_n_i; 
   input            PciAdrAck_n_i; 
   input            PciAck_n_i; 
   input            PciDxfr_n_i; 
   input    [9:0]   PciLmTsr_i; 
   input   [31:0]   DmaSa_i; 
   input   [31:0]   DmaBcLa_i; 
   input            DmaStrtMstr_i; 
   input   [63:0]   PrftchReg_i; 
   input   [31:0]   SramHighDw_i; 
   input   [31:0]   SramLowDw_i; 

   input   [31:0]   IODat_i;

   output  [63:0]   PciAd_o; 
   output   [7:0]   PciCben_o; 
   output           PciReq32_n_o; 
   output           PciReq64_n_o; 
   output           PciLastTx_n_o; 
   output           PciRdy_n_o; 
   output           DmaMstrDone_o; 
   output           MstrDataTx_o; 
   output           MstrPrftchOn_o; 
   output   [7:0]   SramAddr_o; 
   output           SramHighWrEn_o; 
   output           SramLowWrEn_o; 
   output           MstrIOWren_o;

   
   reg    [63:0]    PciAd_o;   
   reg    [7:0]     PciCben_o;
   reg[7:0]         sram_addr; 
   
   


   wire             PciLastTx_n_o;
   wire             MstrDataTx_o;
   wire             MstrPrftchOn_o;
   wire   [7:0]     SramAddr_o;

//------------------------------------------------------------------------------
//-----------------Local Declarations-------------------------------------------
//------------------------------------------------------------------------------

parameter IDLE    = 8'b00000000,  //Idle
          REQ_BUS = 8'b00000011,  //Request Bus          
          RD_ADDR = 8'b00000101,  //Read Address phase
          RD_CHK  = 8'b00001001,  //Read Check Phase
          RD_DATA = 8'b00010001,  //Read data phase          
          WR_ADDR = 8'b00100001,  //Write Address phase
          WR_CHK  = 8'b01000001,  //Write Check phase
          WR_DATA = 8'b10000001;  //Write Data phase


   reg  [7:0]   state; 
   reg  [7:0]   nxt_state; 
   wire         sram_high_addr_en; 
   wire         sram_low_addr_en; 
   reg  [31:0]  dma_sa_cnt; 
   reg          mem_rd_reg;
   reg          mem_wr_reg;
   reg          io_rd_reg;
   reg          io_wr_reg;
   reg  [3:0]   cben;
   reg  [63:0]  ad_temp;


   wire         wr_rdn; 
   wire         lm_req32n; 
   wire         lm_req64n;
   wire         sram_addr_inc;    
   wire         sx_data_tx;
   wire [7:0]   pci_bcr;
   wire [63:0]  sram_data; 
   wire         mstr_done;
   wire         mstr_disengage;
   wire         abnormal_term;
   wire         prftch_on; 
   wire         dmabcala_temp;
   wire         mem_tx;
   wire         addrinc_64pci64local;
   wire         addrinc_32pci64local;



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
      state <= nxt_state; 
end 

//***************************************************
//state_machine_controller:
//****************************************************

   always @(state or DmaStrtMstr_i or DmaBcLa_i or 
            PciLmTsr_i or PciAdrAck_n_i or mstr_done or mstr_disengage
            or PciAck_n_i)
   
   begin : state_machine_cntrl
      
      case (state)
         IDLE :
                  begin
                     // Signal from DMA engine to start the Master Transaction
                     if (DmaStrtMstr_i)
                        nxt_state = REQ_BUS; 
                     else
                        nxt_state = IDLE; 
                  end

         REQ_BUS :
                        // dma_bc_la[31:28]      Function
                        //          0000        32 bit Memory Read
                        //          0010        64 bit Memory Read
                        //          0100        32 bit IO Read
                        //          0110        32 bit IO write
                        //          1000        32 bit Memory write
                        //          1010        64 bit Memory write
                  begin
                     if ((DmaBcLa_i[31:30] == 2'b00) | (DmaBcLa_i[31:29] == 3'b010))
                        nxt_state = RD_ADDR; 
                     else if ((DmaBcLa_i[31:30] == 2'b10) | (DmaBcLa_i[31:29] == 3'b011))
                        nxt_state = WR_ADDR; 
                     else
                        nxt_state = IDLE; 
                  end

//*****************************************************************
// Read 
// The following three states implement Master read operation
//######
// During RD_ADDR state, Address and command is placed on the local side of the PCI bus
// Transition to RD_CHK state** when lm_tsr(1) and lm_adr_ackn is valid
//######
// In Rd_chk state it is important to check for lm_tsr(2) state.
// This state is required because in order to start the transaction Arbiter has to 
// keep the gntn asserted for three clocks, if the gntn is deasserted in less than three clocks
// Master will initiate the transaction, in such cases the Read state machine should go back to 
// RD_ADDR state and assert Address and command on the local side.
// This explanation is also given in "Note to Table 3-10" in Master Local-side signals
// This state is needed only if you are implementing the application for open systems
// where you do not have control on how many clocks arbiter asserts gntn

//######
// RD_DATA  state is the data phase
// The Master transaction is completed for any one of the following
// 1. Completed the intended number of dword transfers, indicated by mstr_done and PciAck_n_i
// 2. There was target termination. indicated by mstr_disengage
// mstr_done and mstr_disengage are derived from lm_tsr bits
//*****************************************************************
 
         RD_ADDR  :
                  begin
                     if (!PciAdrAck_n_i & PciLmTsr_i[1])
                        nxt_state = RD_CHK ; 
                     else
                        nxt_state = RD_ADDR  ; 
                  end

         RD_CHK :
                  begin
                    if (PciLmTsr_i[2])
                        nxt_state = RD_DATA ; 
                     else
                        nxt_state = RD_ADDR  ;                     
                  end

         RD_DATA :
                  begin
                     if ((mstr_done | mstr_disengage) & PciAck_n_i)
                        nxt_state = IDLE ; 
                     else
                        nxt_state = RD_DATA ; 
                  end

//*****************************************************************
// Write
// The following three states implement Master read operation
//######
// During WR_ADDR state, Address and command is placed on the local side of the PCI bus
// Transition to WR_CHK state** when lm_tsr(1) and lm_adr_ackn is valid
//######
// In WR_CHK state it is important to check for lm_tsr(2) state.
// This state is required because in order to start the transaction Arbiter has to 
// keep the gntn asserted for three clocks, if the gntn is deasserted in less than three clocks
// Master will initiate the transaction, in such cases the Write state machine should go back to 
// WR_ADDR state and assert Address and command on the local side.
// This explanation is also given in "Note to Table 3-10" in Master Local-side signals
// This state is needed only if you are implementing the application for open systems
// where you do not have control on how many clocks arbiter asserts gntn

//######
// WR_DATA  state is the data phase
// The Master transaction is completed for any one of the following
// 1. Completed the intended number of dword transfers, indicated by mstr_done and PciAck_n_i
// 2. There was target termination. indicated by mstr_disengage
// mstr_done and mstr_disengage are derived from lm_tsr bits
//*****************************************************************
 

         WR_ADDR:
                  begin
                     if (!PciAdrAck_n_i & PciLmTsr_i[1])
                        nxt_state = WR_CHK ; 
                     else
                        nxt_state = WR_ADDR; 
                  end

         WR_CHK:
                  begin
                    if (PciLmTsr_i[2])
                        nxt_state = WR_DATA ; 
                     else
                        nxt_state = WR_ADDR  ;                     
                  end
               
         WR_DATA :
                  begin
                     if ((mstr_done | mstr_disengage) & PciAck_n_i)
                        nxt_state = IDLE ; 
                     else
                        nxt_state = WR_DATA ; 
                  end
                  
//*****************************************************************
 
         default :
                  begin
                     nxt_state = IDLE ; 
                  end
      
      endcase 
   end 

 
//------------------------------------------------------------------ ---------------
// Assert prefetch in REQUEST state and the transaction is Master write transaction.
// This signal is asserted for one clock to the Prefetch file
// Explanation of Prefetch is given in the prefetch file.           
//----------------------------------------------------------------------------------                                               
assign prftch_on =       (DmaBcLa_i[31:30] == 2'b10) & state[1];
assign MstrPrftchOn_o = prftch_on ; 

//Master done signal to DMA Engine
assign DmaMstrDone_o = (mstr_done | mstr_disengage) & (state[4] | state[7]);

//Indication of Read or Write Transaction
assign wr_rdn =  (state[5] | state[6] | state[7]);

// This signal feeds lm_rdy signal of the PCI core
// This reference design indicates that it is always ready to
// accept data or always ready with the data when the state machine is in the following states.
assign PciRdy_n_o = ~(state[3] | state[4] |  state[6] | state[7]);
                      
// 32-bit or 64-bit request based on the command inthe dmabcala register from the DMA engine.
assign lm_req64n = ~(state[1] & (DmaBcLa_i[31:29] == 3'b001 | DmaBcLa_i[31:29] == 3'b101));
assign lm_req32n = ~(state[1] & ~(DmaBcLa_i[31:29] == 3'b001 | DmaBcLa_i[31:29] == 3'b101));
assign PciReq64_n_o = lm_req64n;
assign PciReq32_n_o = lm_req32n;

// Master done signal 
assign mstr_done = ~(PciLmTsr_i[3] | PciLmTsr_i[8]);
// Master disengage signal.
assign mstr_disengage = (PciLmTsr_i[4] | PciLmTsr_i[5] | PciLmTsr_i[6] | PciLmTsr_i[7]);
assign abnormal_term = mstr_disengage & (state[4] | state[7]);

// Successful data transfer on the local side.
assign sx_data_tx = ~(PciDxfr_n_i) & ~(PciAck_n_i);    

// Byte Counter 
assign pci_bcr = DmaBcLa_i[15:8] ;    

// Sram Data.
assign sram_data[31:0] = SramLowDw_i ;   
assign sram_data[63:32] = SramHighDw_i ;    

// Reference
// dma_bc_la[31:28]      Function
//          0000        32 bit Memory Read
//          0010        64 bit Memory Read
//          0100        32 bit IO Read
//          0110        32 bit IO write
//          1000        32 bit Memory write
//          1010        64 bit Memory write


// Prefetch is required during Master Write transaction 
// This signal indicates a successful data transfer to the Prefetch file
// For 64-bit transfer it is same as sx_data_tx
// For 32-bit transactions it is sram_high_addr_en and sx_data_tx.
// sram_high_addr_en is required because we are fetching
// 64 bits of data at a time from SRAM

assign MstrDataTx_o = (sx_data_tx & DmaBcLa_i[31:29] == 3'b101) |
                       (sx_data_tx & sram_high_addr_en & DmaBcLa_i[31:29] == 3'b100); 
                       

// Enable for IO reg in the top_local if it is an IO transaction   
assign MstrIOWren_o = state[4] & sx_data_tx & io_rd_reg;

// Memory transaction indicator
assign mem_tx = state[0] & (mem_rd_reg | mem_wr_reg);

//-------------------------------------------------------------------------------------------------------------------------
// SRAM Write Enable 
assign dmabcala_temp = ( DmaBcLa_i[31:29] == 3'b001 | DmaBcLa_i[31:29] == 3'b101);

assign SramLowWrEn_o = ( (state[4] & mem_rd_reg & dmabcala_temp & ~PciLDataAck_n_i & sx_data_tx) |
                         (state[4] & mem_rd_reg & ~dmabcala_temp & sram_low_addr_en & sx_data_tx)  );                     

assign SramHighWrEn_o = ( (state[4] & mem_rd_reg & dmabcala_temp & ~PciHDataAck_n_i & sx_data_tx) |
                        (state[4] & mem_rd_reg & ~dmabcala_temp & sram_high_addr_en & sx_data_tx) );                     

// Address for SRAM
assign SramAddr_o = (DmaStrtMstr_i) ? sram_addr : 'h00 ; 


// SRAM Address Incrementing logic.
assign sram_addr_inc  = (~PciHDataAck_n_i & sx_data_tx & state[7]);

assign sram_low_addr_en = (state[0] & mem_tx & ~(dma_sa_cnt[3:0] == 4'b0100 | dma_sa_cnt[3:0] == 4'b1100)) ;      
assign sram_high_addr_en = (state[0] & mem_tx & (dma_sa_cnt[3:0] == 4'b0100 | dma_sa_cnt[3:0] == 4'b1100));         

assign addrinc_64pci64local = sx_data_tx & !PciHDataAck_n_i & (DmaBcLa_i[31:29] == 3'b101 |  DmaBcLa_i[31:29] == 3'b001);
assign addrinc_32pci64local = sx_data_tx & sram_high_addr_en & (DmaBcLa_i[31:29] == 3'b100 |  DmaBcLa_i[31:29] == 3'b000);

//---------------------------------------------------------------------------------------------------------------------------
   

//********************************************
//Cben Output to the Core
//********************************************
always @(state or cben)
begin
   if (state[2] | state[5])         
   begin
           PciCben_o[7:4] = 0;           
           PciCben_o[3:0] = cben;                     
   end        
   else           
          PciCben_o[7:0] = 0;           
       
end 



//*******************************************************************
// Address/Data
// Based on the trasaction
// The first phase on PciAd_o is always DmaSa_i(Sytem Address) that will
// be the address phase on the PCI bus.
// If it is an IO transaction the data phase will have IO data(in this 
// referece design the IO data is coming from the top_local wherein the IO
// register is incorporated else
// it is memory write transaction
//*******************************************************************
always @(state or DmaSa_i or  
         io_wr_reg or ad_temp or mem_wr_reg or PciAd_o or 
         IODat_i)
begin
   if (state[2] | state[5])        //Address Phase      
    begin
           PciAd_o[63:32] = 0;
           PciAd_o[31:0] = DmaSa_i;
    end       
   else if((state[6] | state[7]) & io_wr_reg)   //IO Data
    begin
           PciAd_o[63:32] = 0;
           PciAd_o[31:0] = IODat_i; 
    end       
   else if((state[6] | state[7]) & mem_wr_reg)  //SRAM Data 
          PciAd_o[63:0] = ad_temp;  
   else 
          PciAd_o[63:0] = 0;
end 

//*******************************************************************
// Based on the kind of transaction on the PCI bus

// 64 Bit PCI and 64 Bit Local side.
// 

// Prefetch Register:
// Prefetch register is required in this kind of design because
// inputs to the SRAM are registered, hence there will be a delay of one
// clock to get the valid data for the give address for example
// if address(1) is provided in clock x. the SRAM will give the data corresponding
// to address(1) in clock x+1
// Hence if there is a successful data transfer on the local side we need to provide the
// next data immediately.
// If we fetch data directly from SRAM we cannot provide data immediately because of the
// registered inputs. hence this design performs the following
// 1. We prefetch the data and increment the SRAM address
// 2. Provide the Prefetch data as the first data.
// 3. Switch to SRAM data as soon as prefetch data is transferred

// 32 Bit PCI and 64 Bit Local side.
// For this kind of transaction we can always get the valid data from the prefetch register.

// Note that this design is assuming that there will be no wait states from target.
// The below given logic will be different If the design has to take target waits 
// into consideration The below given logic will be different.

//*******************************************************************
always @(DmaBcLa_i or sram_high_addr_en or sram_low_addr_en or
         PrftchReg_i or SramHighDw_i or SramLowDw_i or PciLmTsr_i)
begin
           
           //---------------------------------
           //64 Bit PCI and 64 Bit Local side.
           //---------------------------------
           if (DmaBcLa_i[31:29] == 3'b101 & ~PciLmTsr_i[8])
           begin
              ad_temp[63:32] = PrftchReg_i[63:32] ; 
              ad_temp[31:0] = PrftchReg_i[31:0] ; 
           end
           
           else if (DmaBcLa_i[31:29] == 3'b101 & PciLmTsr_i[8])
           begin
              ad_temp[63:32] = SramHighDw_i; 
              ad_temp[31:0]  = SramLowDw_i; 
           end
           
           ///-----------------------------------
           //32 Bit PCI and 64 Bit Local side.
           //------------------------------------
           else if (DmaBcLa_i[31:29] == 3'b100 & sram_high_addr_en)
           begin
              ad_temp[63:32] = 32'b0 ; 
              ad_temp[31:0] = PrftchReg_i[63:32]; 
           end
           else if (DmaBcLa_i[31:29] == 3'b100 & sram_low_addr_en)
           begin
              ad_temp[63:32] = 32'b0; 
              ad_temp[31:0] = PrftchReg_i[31:0];                  
           end 
           else
              ad_temp = 0;       

end 


//********************************************
//Memory Read Register
//********************************************
always @(posedge Clk or negedge Rstn)
begin
   if (!Rstn)
     mem_rd_reg <= 1'b0;
   else 
      mem_rd_reg <= (state[0] &  (DmaBcLa_i[31:30] == 2'b00));
end 
   
//********************************************
//Memory Write Register
//********************************************
always @(posedge Clk or negedge Rstn)
begin
   if (!Rstn)
     mem_wr_reg <= 1'b0;
   else 
      mem_wr_reg <= (state[0] &  (DmaBcLa_i[31:30] == 2'b10));
end 

   
//********************************************
//IO Read Register
//********************************************
always @(posedge Clk or negedge Rstn)
begin
   if (!Rstn)
     io_rd_reg <= 1'b0;
   else 
      io_rd_reg <= (state[0] &  (DmaBcLa_i[31:29] == 3'b010));
end 
   
   
//********************************************
//IO Write Register
//********************************************
always @(posedge Clk or negedge Rstn)
begin
   if (!Rstn)
     io_wr_reg <= 1'b0;
   else 
     io_wr_reg <= (state[0] &  (DmaBcLa_i[31:29] == 3'b011));
end 

//********************************************
//Cben Logic
//********************************************
always @ (cben or mem_rd_reg or mem_wr_reg or io_rd_reg or io_wr_reg)
begin           
     case ({mem_rd_reg, mem_wr_reg, io_rd_reg, io_wr_reg})           
        4'b1000 : cben = 4'b0110;
        4'b0100 : cben = 4'b0111;
        4'b0010 : cben = 4'b0010;
        4'b0001 : cben = 4'b0011;
        default : cben = 4'b0000;                       
     endcase
end



//********************************
//SramAddr_o incrementer
//********************************  
always @(posedge Clk or negedge Rstn)
begin 
  if (!Rstn) 
     sram_addr <= 0;
  else 
    begin
     if (~state[0])
        sram_addr <= DmaBcLa_i[7:0] ; 
     else if (addrinc_64pci64local | prftch_on | addrinc_32pci64local )
        sram_addr <= sram_addr + 8'b00000001 ; 
    end 
end  


//********************************
//Counter for DMA System Address
//********************************
always @(posedge Clk or negedge Rstn)
begin   
   if (!Rstn) 
       dma_sa_cnt <= 0; 
   else 
     begin        
        if (~state[0])                  
            dma_sa_cnt <= DmaSa_i ; 
        else if ( sx_data_tx & mem_tx)  
             dma_sa_cnt <= dma_sa_cnt + 4 ; 
     end        
end 
    
// lm_last generator
lm_lastn_gen last_gen0 (
                    .clk(Clk), 
                    .rstn(Rstn), 
                    .wr_rdn(wr_rdn), 
                    .lm_req32n(lm_req32n), 
                    .lm_req64n(lm_req64n), 
                    .lm_dxfrn(PciDxfr_n_i), 
                    .l_hdat_ackn(PciHDataAck_n_i), 
                    .l_ldat_ackn(PciLDataAck_n_i), 
                    .lm_tsr(PciLmTsr_i), 
                    .xfr_length(pci_bcr), 
                    .abnormal_term(abnormal_term),
                    .lm_lastn(PciLastTx_n_o));


endmodule
