//------------------------------------------------------------------
//  Altera PCI testbench
//  MODULE NAME: local_target

//******************************************************************************************************
//  FUNCTIONAL DESCRIPTION:
//  This file implements the local Target Design
//  The local target consists of a simple state machine that performs 32- or
//  64-bit memory read/write transactions with the LPM memory and 32-bit
//  single-cycle I/O read/write transactions with an I/O register defined in
//  the top_local. 
//
//  The local target uses prefetch logic for burst read
//  transactions and ignores byte enables for all memory and I/O
//  transactions. 

//--------------------------------------------------------------------------------------------------
// BAR2 Register Mapping
//--------------------------------------------------------------------------------------------------
// Address Space Range Reserved Mnemonic                Register Name
// BAR2          00h-03h        targ_termination_reg    Target termination register.
// BAR2          04h-07h        dma_sa[31:0]            DMA system address register
// BAR2          08h-0Bh        dma_bc_la[31:0]         DMA byte count and local address register
//
//  Depending on the value of the target termination register, the local target
//  performs the terminations 

//  targ_termination_reg Setting    Target Termination
//  xxxxxxx0                        Normal Termination
//  xxxxxxx1                        Target Retry
//  xxxxxxx2                        Disconnect
//******************************************************************************************************


//  REVISION HISTORY:
//  Revision 1.3 Description : Changed the code to make it synthesizable.
//  Revision 1.2 Description : No change.
//  Revision 1.1 Description : No change.
//  Revision 1.0 Description : Initial Release.
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
//  This reference design file is being provided on an 'as-is' basis and as an 
//  accommodation and therefore all warranties, representations or guarantees 
//  of any kind (whether express, implied or statutory) including, without limitation, 
//  warranties of merchantability, non-infringement, or fitness for a particular purpose, 
//  are specifically disclaimed.  By making this reference design file available, 
//  Altera expressly does not recommend, suggest or require that this reference design 
//  file be used in combination with any other product not provided by Altera.
//---------------------------------------------------------------------------------------
`timescale 1 ns / 1 ns

module local_target (     Clk,                 // Clock
                          Rstn,                // Reset

                          Pcil_dat_i,          // PCI local data out
                          Pcil_adr_i,          // PCI local SramAddr_o out
                          Pcil_ben_i,          // PCI local byte enable out
                          Pcil_cmd_i,          // PCI local command out
                          Pcildat_ack_n_i,     // PCI local lower data acknowledge
                          Pcihdat_ack_n_i,     // PCI local higher data acknowledge
                          Pcilt_abort_n_o,     // PCI local target abort
                          Pcilt_disc_n_o,      // PCI local target disconnect
                          Pcilt_rdy_n_o,       // PCI local target ready
                          Pcilt_frame_n_i,     // PCI local target frame
                          Pcilt_ack_n_i,       // PCI local target acknowledge
                          Pcilt_dxfr_n_i,      // PCI local target data transfer
                          Pcilt_tsr_i,         // PCI local target status register
                          Pcilirq_n_o,         // PCI local interrupt
                          PciAd_o,             // PCI data output from target

                          TrgtDataTx_o,        // Target successful data transfer
                          TrgtPrftchOn_o,      // Target prefetch on
                          PrftchReg_i,         // Target prefetch register
                          TrgtDone_o,          // Target done
                          Trgt64_tx_o,
                          
                          TrgtIOWren_o,       // Target IO Write Enable
                          
                          SramAddr_o,         // SramAddr_o to the memory
                          SramHighWrEn_o,     // Sram write enable of the high dword
                          SramLowWrEn_o,      // Sram write enable of the low dword
                          SramHighDw_i,       // Sram high dword out from the memory
                          SramLowDw_i,        // Sram low dword out from the memory
                          
                          IODat_i             // IO Data  
                          );


//------------------------------------------------------------------------------
//-----------------IO Declarations----------------------------------------------
//------------------------------------------------------------------------------

   input                Clk;
   input                Rstn;
   input   [63:0]       Pcil_dat_i;
   input   [63:0]       Pcil_adr_i;
   input   [7:0]        Pcil_ben_i;
   input   [3:0]        Pcil_cmd_i;
   input                Pcildat_ack_n_i;
   input                Pcihdat_ack_n_i;
   input                Pcilt_frame_n_i;
   input                Pcilt_ack_n_i;
   input                Pcilt_dxfr_n_i;
   input   [11:0]       Pcilt_tsr_i;
   input   [63:0]       PrftchReg_i;
   input   [31:0]       SramHighDw_i;
   input   [31:0]       SramLowDw_i;
   
   input   [31:0]       IODat_i;

   output               Pcilt_abort_n_o;
   output               Pcilt_disc_n_o;
   output               Pcilt_rdy_n_o;
   output               Pcilirq_n_o;
   output               TrgtDataTx_o;
   output               TrgtPrftchOn_o;
   output  [7:0]        SramAddr_o;
   output               SramHighWrEn_o;
   output               SramLowWrEn_o;
   output  [63:0]       PciAd_o;
   output               TrgtDone_o;
   output               TrgtIOWren_o;
   output               Trgt64_tx_o;
   
   reg                  Pcilt_disc_n_o;
   reg    [63:0]        PciAd_o;
   

   wire                 TrgtDataTx_o;
   wire                 TrgtPrftchOn_o;

//------------------------------------------------------------------------------
//-----------------Local Declarations-------------------------------------------
//------------------------------------------------------------------------------

   parameter   IDLE             = 5'b00000,  //state 0
               TRGT_WR          = 5'b00011,  //state 1
               TRGT_RD_PRFTCH   = 5'b00101,  //state 2
               TRGT_RD          = 5'b01001,  //state 3
               TRGT_TERM_DEMO   = 5'b10001;  //state 4
   
   
   reg  [4:0]   state;
   reg  [4:0]   nxt_state;
   
   reg  [7:0]   sram_addr;               // SRAM Address
   reg  [3:0]   trgt_term_demo_reg;      // Target Termination Demo Register
   wire [63:0]  ad_temp;
   wire         prftch_on;               //prefetch on
   wire         sx_data_tx;              //successful data transfer
   wire         tx64bit;                 //64 bit burst data transfer
   wire         mem_wr;                  //Memory Write Transaction 
   wire         mem_rd;                  //Memory Read Transaction 
   wire         io_wr;                   //IO Write Transaction    
   wire         io_rd;                   //IO Read Transaction
   wire         trgt_demo;                  
   wire         trgt_wr;
   wire         trgt_rd;
   wire         trgt_done;
   
   wire         addrinc_64pci64local;
   wire         addrinc_32pci64local;





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

//************************
//state_machine_controller:
//************************
always @(trgt_wr or trgt_rd or state or trgt_done or trgt_demo)
   begin : state_machine_controller
      case (state)
         IDLE :
                  begin
                    if (trgt_wr)
                        nxt_state = TRGT_WR ;
                     else if (trgt_rd)
                        nxt_state = TRGT_RD_PRFTCH ;
                     else if (trgt_demo)
                        nxt_state = TRGT_TERM_DEMO ;
                     else
                        nxt_state = IDLE ;
                  end

         //Target Write     
         TRGT_WR :
                  begin
                     if (trgt_done)
                        nxt_state = IDLE ;
                     else
                        nxt_state = TRGT_WR ;
                  end

         //Target Read Prefetch
         TRGT_RD_PRFTCH :
                    nxt_state = TRGT_RD ;
                             
         
         //Target Read
         TRGT_RD :
                  begin
                     if (trgt_done)
                        nxt_state = IDLE ;
                     else
                        nxt_state = TRGT_RD ;
                  end

         //Target Termination Demo state 
         //Based on the value that is written in the targ_demo register
         //The following transaction will perform
         //target retry or target disconnect.         
         TRGT_TERM_DEMO :
                  begin
                     if (trgt_done)
                        nxt_state = IDLE ;
                     else
                        nxt_state = TRGT_TERM_DEMO ;
                  end

         default :
                  begin
                     nxt_state = IDLE ;
                  end

      endcase
   end





//---------------------------------------------------------------------------------------
// Memory write transaction
// The command is memory write and Pcilt_tsr_i(0) is bar0 hit
//---------------------------------------------------------------------------------------
assign  mem_wr               = !Pcilt_frame_n_i & Pcil_cmd_i == 4'b0111 & Pcilt_tsr_i[0];


//---------------------------------------------------------------------------------------
// Memory read transaction
// The Command is memory read and Pcilt_tsr_i(0) is bar0 hit
//---------------------------------------------------------------------------------------
assign  mem_rd               = !Pcilt_frame_n_i & Pcil_cmd_i == 4'b0110 & Pcilt_tsr_i[0];


//---------------------------------------------------------------------------------------
// IO Write transaction
// The command is io write and Pcilt_tsr_i(1) is bar1 hit.
//---------------------------------------------------------------------------------------
assign  io_wr                = !Pcilt_frame_n_i & Pcil_cmd_i == 4'b0011 & Pcilt_tsr_i[1];


//---------------------------------------------------------------------------------------
// IO read transaction
// The command is io read and Pcilt_tsr_i(1) is bar1 hit.
//---------------------------------------------------------------------------------------
assign  io_rd                = !Pcilt_frame_n_i & Pcil_cmd_i == 4'b0010 & Pcilt_tsr_i[1]; 


//---------------------------------------------------------------------------------------
// This command register is for demonstartion purpose with the help of which
// retry and disconnect has been implemented
// command write and Pcilt_tsr_i(2) which is a bar2 hit

//Based on the value that is written in the targ_demo register
//The following transaction will perform the following
//  targ_termination_reg Setting    Target Termination
//  xxxxxxx0                        Normal Termination
//  xxxxxxx1                        Target Retry
//  xxxxxxx2                        Disconnect       
//---------------------------------------------------------------------------------------
assign  trgt_demo            = !Pcilt_frame_n_i & Pcil_cmd_i == 4'b0111 & Pcilt_tsr_i[2] & 
                               (Pcil_adr_i[3:0] == 4'b0000);
                             
//---------------------------------------------------------------------------------------
// Target write or Read indicator
//---------------------------------------------------------------------------------------
assign  trgt_wr              = mem_wr | io_wr;
assign  trgt_rd              = mem_rd | io_rd;


//---------------------------------------------------------------------------------------
//The current target transaction is done when lt_tsr[8] and lt_ackn are inactive
//---------------------------------------------------------------------------------------
assign  trgt_done            = ~Pcilt_tsr_i[8] & Pcilt_ack_n_i;


//---------------------------------------------------------------------------------------
//Prefetch the data from memory for Target Read transaction
//---------------------------------------------------------------------------------------
assign  prftch_on            = mem_rd & state[2];


//---------------------------------------------------------------------------------------
//A successful data transfer is assertion of lt_dxfrn and lt_ackn
//---------------------------------------------------------------------------------------
assign  sx_data_tx           = ~(Pcilt_dxfr_n_i) & ~(Pcilt_ack_n_i) ;   


//---------------------------------------------------------------------------------------
//64 bit transfer
//---------------------------------------------------------------------------------------
assign  tx64bit              = Pcilt_tsr_i[7];
                             
assign  Trgt64_tx_o          = tx64bit;


//---------------------------------------------------------------------------------------
//64 bit PCI Side and 64 bit local side
//---------------------------------------------------------------------------------------
assign  addrinc_64pci64local = sx_data_tx & !Pcihdat_ack_n_i & tx64bit;


//---------------------------------------------------------------------------------------
//32 bit PCI Side and 64 bit local side
//---------------------------------------------------------------------------------------
assign  addrinc_32pci64local = (state[1] & sx_data_tx & ~Pcihdat_ack_n_i & ~tx64bit) |
                                (state[3] & sx_data_tx);


//---------------------------------------------------------------------------------------
//Sram Low Write enable is asserted when the state is target write, 
//successful data transfer on the local side and
//ldata_ackn is asserted
//---------------------------------------------------------------------------------------
assign  SramLowWrEn_o        = state[1] & ~Pcildat_ack_n_i & sx_data_tx & mem_wr;


//---------------------------------------------------------------------------------------
//Sram High Write enable is asserted when the state is target write, 
//successful data transfer on the local side and
//hdata_ackn is asserted
//---------------------------------------------------------------------------------------
assign  SramHighWrEn_o       = state[1] & ~Pcihdat_ack_n_i & sx_data_tx & mem_wr;


//---------------------------------------------------------------------------------------
//Target is ready to write and read except when the target termination demo register
//is having a value that will make the target state machine go in a demo mode
//to assert lt_discn.
//---------------------------------------------------------------------------------------
assign  Pcilt_rdy_n_o        = ~(( (state[1] | state[3]) & (trgt_term_demo_reg == 4'b0010 | trgt_term_demo_reg == 4'b0000)) | 
                                    state[4]);
                                    

assign  TrgtDataTx_o         = addrinc_64pci64local |  addrinc_32pci64local ;                           
assign  TrgtPrftchOn_o       = prftch_on ;
assign  TrgtDone_o           = trgt_done  & (state[1] | state[3] | state[4]);
assign  Pcilirq_n_o          = 1'b1;   
assign  TrgtIOWren_o         = io_wr & state[1] & sx_data_tx;
assign  SramAddr_o           = sram_addr;
assign  Pcilt_abort_n_o      = 1'b1;  
assign  ad_temp             =  PrftchReg_i;

  

//************************************************************************************
// Address/Data
// Based on the trasaction
// If it is an IO transaction the data phase will have IO data(in this 
// referece design the IO data is coming from the top_local wherein the IO
// register is incorporated else
// it is target read transaction
// The data during target read transaction comes from
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

// Note that this design is assuming that there will be no wait states from target ir
// Master.
// If the design has to take target waits into consideration
// The below given logic will be different.

//************************************************************************************
always @(state or IODat_i or ad_temp or mem_wr or io_wr or mem_rd or io_rd)
begin
   if( state[3]  & io_rd)   //IO Data
           PciAd_o[31:0] = IODat_i; 
   else if( state[3] & mem_rd)  //SRAM Data 
          PciAd_o[63:0] = ad_temp;  
   else 
          PciAd_o[63:0] = 64'b0;
end 




//************************************************************************************
//Target Termination Demo Register
//--------------------------------------------------------------------------------------------------
// BAR2 Register Mapping
//--------------------------------------------------------------------------------------------------
// Address Space Range Reserved Mnemonic                Register Name
// BAR2          00h-03h        targ_termination_reg    Target termination register.
//  Depending on the value of the target termination register, the local target
//  performs the terminations 

//  targ_termination_reg Setting    Target Termination
//  xxxxxxx0                        Normal Termination
//  xxxxxxx1                        Target Retry
//  xxxxxxx2                        Disconnect
//************************************************************************************

always @(posedge Clk or negedge Rstn)
begin 
  if (!Rstn) 
     trgt_term_demo_reg <= 4'b0;
  else 
    begin
     if ( (state[1] | state[3]) & trgt_done)
        trgt_term_demo_reg <= 4'b0;
     else if (sx_data_tx & state[4] )
        trgt_term_demo_reg <= Pcil_dat_i[3:0];
    end 
end  


//************************************************************************************
// Target Disconnect signal
// Assert Target disconnect signal based on the value given in the
// target termination demo register(trgt_term_demo_reg)
//************************************************************************************
always @(posedge Clk or negedge Rstn)
begin 
  if (!Rstn) 
     Pcilt_disc_n_o <= 1'b1;
  else 
    begin
      if ( (state[1] | state[3]) & 
           (trgt_term_demo_reg == 4'b0010 | trgt_term_demo_reg == 4'b0001) )          
        Pcilt_disc_n_o <= 1'b0;
      else 
        Pcilt_disc_n_o <= 1'b1;
    end 
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
        sram_addr <= Pcil_adr_i[10:3] ;
     else if (addrinc_64pci64local | prftch_on | addrinc_32pci64local )
        sram_addr <= sram_addr + 8'b00000001 ; 
    end 
end  

  
   
endmodule

