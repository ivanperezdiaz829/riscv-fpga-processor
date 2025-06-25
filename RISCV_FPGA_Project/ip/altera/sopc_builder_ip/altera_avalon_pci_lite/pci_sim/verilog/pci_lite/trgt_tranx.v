//------------------------------------------------------------------
//  Altera PCI testbench
//  MODULE NAME: target_tranx
//  COMPANY:  Altera Coporation.
//            www.altera.com    

//  FUNCTIONAL DESCRIPTION:
// This file simulates the Target agent on the PCI bus.                                          
// You can modify the procedures or tasks to introduce different variations                      
// in the PCI transaction as desired by your application.                                        
// You can modify the memory range of target transactor by changing                              
// the ADDRESS_LINES constant value and mem_hit_range                                            

//  This is the top level file of Altera PCI testbench

//  REVISION HISTORY:  
//  Revision 1.1 Description: Changed the address increment logic for 32 bits.
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
//  This reference design file is being provided on an �as-is� basis and as an 
//  accommodation and therefore all warranties, representations or guarantees 
//  of any kind (whether express, implied or statutory) including, without limitation, 
//  warranties of merchantability, non-infringement, or fitness for a particular purpose, 
//  are specifically disclaimed.  By making this reference design file available, 
//  Altera expressly does not recommend, suggest or require that this reference design 
//  file be used in combination with any other product not provided by Altera.
//---------------------------------------------------------------------------------------


`timescale 1 ns / 1 ns

module trgt_tranx (clk,                       // clock                                                                    
                   rstn,                      // reset                                                                    
                   ad,                        // Address                                                                  
                   cben,                      // Command byte enable                                                      
                   par,                       // Parity for lower dword                                                   
                   idsel,                     // Idsel signal that is connected to Ad(29) in the top level file           
                   framen,                    // framen         
                   irdyn,                     // initiator ready
                   devseln,                   // device select                                                                                                                      
                   trdyn,                     // target ready                                                                                                                       
                   stopn,                     // stopn                                                                    
                   perrn,                     // parity error                                                             
                   serrn,                     // system error                                                             
                   trgt_tranx_disca,          // Disconnect target transactor with type-A                                 
                   trgt_tranx_discb,          // Disconnect target transactor with type-B                                 
                   trgt_tranx_retry);         // Retry the target transaction.                                            
                                              
   input clk;                                 
   input rstn;                                
   inout[31:0] ad;                                                                                                        
   wire[31:0] ad;
   reg[31:0] ad_out;
   input[3:0] cben; 
   inout par; 
   wire par;
   reg par_out;
   input idsel; 
   input framen; 
   input irdyn; 
   output devseln; 
   reg devseln;
   output trdyn; 
   reg trdyn;
   output stopn; 
   reg stopn;
   output perrn; 
   reg perrn;
   output serrn; 
   reg serrn;
   input trgt_tranx_disca; 
   input trgt_tranx_discb; 
   input trgt_tranx_retry; 


 //---------------------------------------------------------------------------              
 // ADDRESS LINE                                                                            
 // You can modify the memory instantiated by target transactor by changing                 
 // the "address_lines" value                                                               
 // You also need to change the mem_hit_range value to correspond to                        
 // the value specified by "address_lines"                                                  
 // for example if address_lines is defined as 1024, the target transactor                  
 // is instantiating memory of size 1k.                                                     
 // that corresponds to memory hit range of 000-3FF in hex..                                
 //---------------------------------------------------------------------------              
                                                                                            
    parameter address_lines = 1024;                                                         
    parameter[31:0] mem_hit_range = 32'h000003FF;                                           
    parameter[31:0] io_hit_range  = 32'h0000000F;                                           
 //*************************************************************                            
                                                                     
   
                                                                     
   reg[32:1] pci_mem[0:address_lines - 1];  //This is a memory array used by the target transactor                          
   reg we_32;                                                        
   integer addr;                            // signal used to address memory                                                            
   reg mem_hit;                             // indicates this is memory BAR hit                                                 
   reg io_hit;                              // indicates this is IO BAR hit                                                     
   reg par_en;                              // enable the lower dword parity output                                             
   reg trdyn_watch;              
   reg[31:0] address;            
   parameter tdel = 0;           

   //Registers
   reg[31:0] io_reg_32;           // io register                                                                         
   reg[31:0] trgt_tranx_bar0;     // BAR0 register of target transactor                                                  
   reg[31:0] trgt_tranx_bar1;     // BAR1 register of target transactor                                                  
   integer addr_boundary;         //Used to determine the which bits of the address to use for memory read / writes      

   reg[31:0]addr_reg;		// Used to Store the Address of the PCI transaction during Address Phase
   reg[3:0]cmd_reg;		// Used to Store the command of the PCI transaction during Address Phase
	
   assign ad = ad_out;
   assign par = par_out;

   initial
   begin
      address <= 32'h00000000;
      io_reg_32 <= 32'h00000000;
      trgt_tranx_bar0 <= 32'h00000000;
      trgt_tranx_bar1 <= 32'h00000001;
   end

   //parity generation for lower dword
   always @(posedge clk)// or ad or cben or par_en)
   //*****************************************
   begin : parity_gen
   //*****************************************
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
         par_out <= result_reg ; 
      end
      else
      begin
         par_out <= 1'bz ; 
      end  
   end 

//*****************************************************************
//FILE IO
//*****************************************************************

   //This process initializes the memory by reading in the data file
   //and also performs all memory writes.
   always @(negedge rstn or we_32 or irdyn or posedge clk)
   //*****************************************
   begin : memory_initialization_and_writes
   //*****************************************

      reg[32:1] temp_bit_array[0:address_lines - 1]; 
      reg[4:1] tmpbit; 

      if (!rstn & irdyn & !we_32)
      begin
         begin : xhdl_2
            integer i;
             for(i = 0; i <= address_lines - 1; i = i + 1)
            begin
               temp_bit_array[i] = 32'h00000000; 
            end
         end 
        
         begin : xhdl_3
               $readmemh("trgt_tranx_mem_init.dat",temp_bit_array);
         end 
        
         begin : xhdl_4
            integer k;
            for(k = 0; k <= address_lines - 1; k = k + 1)
            begin
               pci_mem[k] <= temp_bit_array[k] ; 
            end
         end 
      end
      else if (we_32 & clk & !irdyn & !trdyn_watch)
      begin
         pci_mem[addr] <= ad ; 
      end 
   end 

//**********************************************************
//MEM_HIT
//***********************************************************
   //to detect the falling edge of framen
   reg framen_reg;
   wire framen_assert;
   assign framen_assert = !framen & framen_reg;
   always @( posedge clk)
   begin
     framen_reg <= framen;
   end
   

   //This process determines if there is a memory hit
   always @(posedge clk or negedge rstn)
   //********************************************
   begin : check_memory_hit
   //********************************************
      if(~rstn)
	begin
 	   addr_reg<=0;
	   cmd_reg<=0;
	   mem_hit<=0;
	end
      if (framen_assert & (trgt_tranx_bar0 <= ad[31:0]) & (ad[31:0] < trgt_tranx_bar0 + mem_hit_range) & 
	  (cben[3:0] == 4'b0110 | cben[3:0] == 4'b0111 | 
	   cben[3:0] == 4'b1110 | cben[3:0] == 4'b1111 | cben[3:0] == 4'b1100))
      begin
         mem_hit <= 1'b1 ;
	 addr_reg <= ad;
   	 cmd_reg <= cben; 
      end
      else
      begin
         mem_hit <= 1'b0 ; 
      end 
   end 

  //io register address space is defined and checked here
  always @(ad or cben or trgt_tranx_bar1)
   //********************************************
   begin : check_io_hit
   //********************************************

      if (((trgt_tranx_bar1[31:0] - 'h01) <= ad[31:0]) & 
         ((ad[31:0] < trgt_tranx_bar1 + io_hit_range)) & (cben[3:0] == 4'b0010 | cben[3:0] == 4'b0011))
      begin
         io_hit <= 1'b1 ; 
      end
      else
      begin
         io_hit <= 1'b0 ; 
      end 
   end 

   //This process will determine which bit slice of the address is used to for memory reads / writes
   always @(rstn)
   //********************************************
   begin : addr_determ
   //********************************************
      integer temp; 
      integer counter; 
      if (!rstn)
      begin
         temp = address_lines; 
         counter = 0; 
      end 
      //i.e. if there were 8 address lines in memory
      //since 8 != 1,  addr_boundary = 1
      //since 4 != 1,  addr_boundary = 2
      //since 2 != 1,  addr_boundary = 3
      //since 1 == 1,  exit loop
      //
      //Therefore it will take 3 bits to represent the address space
      //In this applications the bit slice that will be used will then be AD (5 downto 3)
    if (rstn)
    begin
         while (temp != 1)
         begin
            temp = temp / 2; 
            counter = counter + 1; 
          end  
    end
      addr_boundary <= counter ; 
   end 
 
   //This process will increment the address when necessary and assert the following control signals
   always @(posedge clk)
   //********************************************
   begin : addr_increment
   //********************************************
   reg[31:0] capture_addr_reg; 
   integer left_shift; 
   integer right_shift; 

     if (!rstn)
     begin
      addr <= 0;
     end

     //capture the address phase at the address/data bus.
     else if (framen_assert)
     begin
       capture_addr_reg = ad[31:0]; 
       left_shift = 31 - (1 + addr_boundary); 
       right_shift = left_shift + 2; 
       addr <= (capture_addr_reg << left_shift) >> right_shift ; 
     end

     //During the transaction increment address when applicable
     else if (!framen & !trgt_tranx_retry & !trdyn_watch & !irdyn)
     begin
       capture_addr_reg = capture_addr_reg + 4; 
       addr <= (capture_addr_reg << left_shift) >> right_shift ; 
     end
   end 

   //Here is where the target transactor determines what kind of pci transaction 
   //is being attempted
   always 
   //********************************************
   begin : main
   //********************************************
      ad_out <= {32{1'bz}} ; 
      par_out <= 1'bz ; 
      trdyn <= 1'bz ; 
      devseln <= 1'bz ; 
      stopn <= 1'bz ; 
      perrn <= 1'bz ; 
      serrn <= 1'bz ; 
      we_32 <= 1'b0 ; 
      par_en <= 1'b0 ; 
      trdyn_watch <= 1'b1 ; 

//-----------------------------------------------------------------------------------
      if ((cmd_reg == 4'b0111 | cmd_reg == 4'b1111) & mem_hit)
      begin
         #tdel; 
         mem_wr; 
      end

//-----------------------------------------------------------------------------------
      else if ((cmd_reg == 4'b0110 | cmd_reg == 4'b1110 | cmd_reg == 4'b1100) & mem_hit)
      begin
         #tdel; 
         mem_rd; 
      end

//-----------------------------------------------------------------------------------
      else if (!framen & cben[3:0] == 4'b0011 & io_hit)
      begin
         #tdel; 
         io_wr; 
      end

//-----------------------------------------------------------------------------------
      else if (!framen & cben[3:0] == 4'b0010 & io_hit)
      begin
         #tdel; 
         io_rd; 
      end
//-----------------------------------------------------------------------------------

      else if (!framen & cben[3:0] == 4'b1011 & idsel & (ad[7:0] == 'h10 | ad[7:0] == 'h14))
      begin
         address <= ad[31:0] ; 
         #tdel; 
         cfg_wr; 
      end

//-----------------------------------------------------------------------------------
      else if (!framen & cben[3:0] == 4'b1010 & idsel & (ad[7:0] == 'h10 | ad[7:0] == 'h14))
      begin
         address <= ad[31:0] ; 
         #tdel; 
         cfg_rd; 
      end 
      @(posedge clk); 
   end

//***********************************************************************************************
//TASKS
//***********************************************************************************************

   //******************
   task mem_wr;
   //******************

      begin
         @(posedge clk); 
         #tdel; 
         devseln <= 1'b0 ; 
         perrn <= 1'b1 ; 
         serrn <= 1'b1 ; 
         stopn <= 1'b1 ; 
         trdyn <= 1'b1 ; 
         trdyn_watch <= 1'b1 ; 
         we_32 <= 1'b1 ; 
         @(posedge clk); 
         #tdel; 
         if (trgt_tranx_retry)
         begin
            trdyn <= 1'b1 ; 
            stopn <= 1'b0 ; 
         end
         else
         begin
            trdyn <= 1'b0 ; 
            trdyn_watch <= 1'b0 ; 
         end 
         while (irdyn)
         begin
            @(posedge clk); 
         end 
         if (trgt_tranx_disca)
         begin
            stopn <= 1'b0 ; 
         end 
         @(posedge clk); 
         #tdel; 
         if (trgt_tranx_discb)
         begin
            stopn <= 1'b0 ; 
            trdyn <= 1'b1 ;
            trdyn_watch <= 1'b1 ; 
         end 
         while (!framen & !trgt_tranx_retry & !trgt_tranx_disca & !trgt_tranx_discb)
         begin
            @(posedge clk); 
         end 
         if (!irdyn)
         begin
            @(posedge irdyn); 
         end 
         ad_out <= {32{1'bz}} ; 
         devseln <= 1'b1 ; 
         stopn <= 1'b1 ; 
         trdyn <= 1'b1 ; 
         trdyn_watch <= 1'b1 ; 
         we_32 <= 1'b0 ; 
         par_en <= 1'b0 ; 
      end
   endtask

   //******************
   task mem_rd;
   //******************

      reg[32:1] vector_32; 

      begin
         @(posedge clk); 
         #tdel; 
         trdyn_watch <= 1'b1 ; 
         devseln <= 1'b0 ; 
         stopn <= 1'b1 ; 
         ad_out <= 32'h00000000 ; 
         par_en <= 1'b1 ; 
         @(posedge clk); 
         #tdel; 
         if (trgt_tranx_retry)
         begin
            trdyn <= 1'b1 ; 
            stopn <= 1'b0 ; 
         end
         else
         begin
            trdyn <= 1'b0 ; 
            trdyn_watch <= 1'b0 ; 
         end 
       //if target disconnect A is seen
         if (trgt_tranx_disca)
         begin
            stopn <= #tdel 1'b0 ; 
         end 
         //Waiting for IRDYN to be high (initiator ready)
         while (irdyn)
         begin
        @(posedge clk);
         end 
         //If this is a 32 bit transaction place first data onto PCI bus
         vector_32 = pci_mem[addr]; 
         ad_out <= vector_32[32:1] ; 

       //Wiat for next clk pos edge
         @(posedge clk); 
         #tdel; 

         if (trgt_tranx_discb)
         begin
            trdyn <= 1'b1 ; 
            trdyn_watch <= 1'b1 ; 
            stopn <= 1'b0 ; 
         end 
         #tdel; 

         //Data Burst Read
         while (!framen & !trgt_tranx_retry)
         begin
        #1 vector_32 = pci_mem[addr]; 
            ad_out <= vector_32[32:1] ; 
            @(posedge clk); 
         end 
         if (!irdyn)
          begin

            if (!trdyn_watch)
            begin
               vector_32 = pci_mem[addr]; 
               ad_out <= vector_32[32:1] ; 
            end 
            @(posedge irdyn); 
         end 
         devseln <= 1'b1 ; 
         stopn <= 1'b1 ; 
         trdyn <= 1'b1 ; 
         trdyn_watch <= 1'b1 ; 
         ad_out <= {32{1'bz}} ; 
         we_32 <= 1'b0 ; 
         par_en <= 1'b0 ; 
      end
   endtask

   //******************
   task io_wr;
   //******************

      begin
         devseln <= 1'b0 ; 
         stopn <= 1'b1 ; 
         trdyn <= 1'b1 ; 
         trdyn_watch <= 1'b1 ; 
         @(posedge clk); 
         #tdel; 
         trdyn <= 1'b0 ; 
         trdyn_watch <= 1'b0 ; 
         if (irdyn)
         begin
            @(negedge irdyn); 
         end 
         @(posedge clk); 
         if (!irdyn & !trdyn_watch)
         begin
            io_reg_32 <= ad[31:0] ; 
         end 
         devseln <= 1'b1 ; 
         stopn <= 1'b1 ; 
         trdyn <= 1'b1 ; 
         trdyn_watch <= 1'b1 ; 
         ad_out <= {32{1'bz}} ; 
         we_32 <= 1'b0 ; 
         par_en <= 1'b0 ; 
      end
   endtask

   //******************
   task io_rd;
   //******************

      begin
         @(posedge clk); 
         #tdel; 
         devseln <= 1'b0 ; 
         stopn <= 1'b1 ; 
         trdyn <= 1'b1 ; 
         par_en <= 1'b1 ; 
         ad_out <= 'h00000000 ; 
         @(posedge clk); 
         trdyn <= 1'b0 ; 
         ad_out <= io_reg_32 ; 
         while (irdyn)
         begin
            @(posedge clk); 
         end 
         @(posedge clk); 
         devseln <= 1'b1 ; 
         stopn <= 1'b1 ; 
         trdyn <= 1'b1 ; 
         ad_out <= {32{1'bz}} ; 
         we_32 <= 1'b0 ; 
         par_en <= 1'b0 ; 
      end
   endtask

   //******************
   task cfg_wr;
   //******************

      begin
         devseln <= 1'b0 ; 
         stopn <= 1'b1 ; 
         trdyn <= 1'b1 ; 
         trdyn_watch <= 1'b1 ; 
         @(posedge clk); 
         #tdel; 
         trdyn <= 1'b0 ; 
         trdyn_watch <= 1'b0 ; 
         while (irdyn)
         begin
            @(posedge clk); 
         end 
         @(posedge clk); 
         if (!irdyn & !trdyn_watch & address[7:0] == 'h10)
         begin
            trgt_tranx_bar0 <= ad[31:0] ; 
         end
         else if (!irdyn & !trdyn_watch & address[7:0] == 'h14)
         begin
            trgt_tranx_bar1[31:1] <= ad[31:1] ; 
         end 
         devseln <= 1'b1 ; 
         stopn <= 1'b1 ; 
         trdyn <= 1'b1 ; 
         trdyn_watch <= 1'b1 ; 
         ad_out <= {32{1'bz}} ; 
         we_32 <= 1'b0 ; 
         par_en <= 1'b0 ; 
      end
   endtask

   //******************
   task cfg_rd;
   //******************

      begin
         @(posedge clk); 
         #tdel; 
         devseln <= 1'b0 ; 
         stopn <= 1'b1 ; 
         trdyn <= 1'b1 ; 
         par_en <= 1'b1 ; 
         ad_out <= 'h00000000 ; 
         @(posedge clk); 
         #tdel; 
         trdyn <= 1'b0 ; 
         if (address[7:0] == 'h10)
         begin
            ad_out <= trgt_tranx_bar0 ; 
         end
         else if (address[7:0] == 'h14)
         begin
            ad_out <= trgt_tranx_bar1 ; 
         end 
         while (irdyn)
         begin
            @(posedge clk); 
         end 
         @(posedge clk); 
         #tdel; 
         devseln <= 1'b1 ; 
         stopn <= 1'b1 ; 
         trdyn <= 1'b1 ; 
         ad_out <= {32{1'bz}} ; 
         we_32 <= 1'b0 ; 
         par_en <= 1'b0 ; 
      end
   endtask 
endmodule
