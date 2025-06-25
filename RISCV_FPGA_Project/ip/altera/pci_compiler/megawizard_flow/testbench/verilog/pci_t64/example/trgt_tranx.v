//------------------------------------------------------------------------------------
// Altera PCI testbench
// MODULE NAME: trgt_tranx

// FUNCTIONAL DESCRIPTION:
// This file simulates the Target agent on the PCI bus.
// You can modify the procedures or tasks to introduce different variations
// in the PCI transaction as desired by your application. 
// You can modify the memory range of trgtet transactor by changing 
// the ADDRESS_LINES constant value and mem_hit_range

// REVISION HISTORY:  
// Revision 1.1 Description: Fixed the address increment logic for 32 bit transfers
// Revision 1.0 Description: Initial Release.
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
 
module trgt_tranx (clk,                     // clock                                                            
                   rstn,                    // reset                                                            
                   ad,                      // Address                                                          
                   cben,                    // Command byte enable                                              
                   par,                     // Parity for lower dword                                           
                   par64,                   // Parity for higher dword                                          
                   idsel,                   // Idsel signal that is connected to Ad(29) in the top level file   
                   req64n,                  // request for 64 bit transfer                                      
                   framen,                  // framen                                                           
                   irdyn,                   // initiator ready                                                  
                   ack64n,                  // acknowledge for 64 bit transfer                                  
                   devseln,                 // device select                                                    
                   trdyn,                   // trgtet ready                                                     
                   stopn,                   // stopn                                                            
                   perrn,                   // parity error                                                     
                   serrn,                   // system error                                                     
                   trgt_tranx_disca,        // Disconnect trgtet transactor with type-A                         
                   trgt_tranx_discb,        // Disconnect trgtet transactor with type-B                         
                   trgt_tranx_retry);       // Retry the trgtet transaction.                                    


   input clk; 
   input rstn; 
   inout[63:0] ad; 
   wire[63:0] ad;
   reg[63:0] ad_out;
   input[7:0] cben; 
   inout par; 
   wire par;
   reg par_out;
   inout par64; 
   wire par64;
   reg par64_out;
   input idsel; 
   input req64n; 
   input framen; 
   input irdyn; 
   output ack64n; 
   reg ack64n;
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
 // You can modify the memory instantiated by trgtet transactor by changing                  
 // the "address_lines" value                                                                
 // You also need to change the mem_hit_range value to correspond to                         
 // the value specified by "address_lines"                                                   
 // for example if address_lines is defined as 1024, the trgtet transactor                   
 // is instantiating memory of size 1k.                                                      
 // that corresponds to memory hit range of 000-3FF in hex..                                 
 //---------------------------------------------------------------------------               
                                                                                             
    parameter address_lines = 1024;                                                          
    parameter[31:0] mem_hit_range = 32'h000003FF;                                            
    parameter[31:0] io_hit_range  = 32'h0000000F;                                            
 //*************************************************************                             


   
   reg[64:1] pci_mem[0:address_lines - 1];  //This is a memory array used by the trgtet transactor 
   reg we_32; 
   reg we_64; 
   integer addr;                           // signal used to address memory                                                       
   integer high_dword;                     // Used for 64 bit transactions                                                        
   reg tranx_64;                           // 64 bit transaction                                                                  
   reg mem_hit;                            // indicates this is memory BAR hit                                                    
   reg io_hit;                             // indicates this is IO BAR hit                                                        
   reg par_en;                             // enable the lower dword parity output                                                
   reg par_en_64;                          // enable the higher dword parity output                                               
   reg trdyn_watch;                                                                                                               
   reg[31:0] address;                                                                                                             
   parameter tdel = 0;                                                                                                            
                                                                                                                                  
   // Registers                                                                                                                   
   reg[31:0] io_reg_32;                    // io register                                                                         
   reg[31:0] trgt_tranx_bar0;              // BAR0 register of trgtet transactor                                                  
   reg[31:0] trgt_tranx_bar1;              // BAR1 register of trgtet transactor                                                  
   integer addr_boundary;                  //Used to determine the which bits of the address to use for memory read / writes      

   assign ad = ad_out;
   assign par = par_out;
   assign par64 = par64_out;

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
      reg result_reg_64; 
      if (clk)
      begin
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
            par_out <= 1'bZ ; 
         end 
      end 
   end 


   //parity generation for higher dword
   always @(posedge clk)// or ad or cben or par_en_64)
   //*****************************************
   begin : parity_gen_64
   //*****************************************
      reg result_reg_; 
      reg result_reg_64_; 
      if (clk)
      begin
         result_reg_64_ = ad[63] ^ ad[62] ^ ad[61] ^ ad[60] ^ 
                          ad[59] ^ ad[58] ^ ad[57] ^ ad[56] ^ 
                          ad[55] ^ ad[54] ^ ad[53] ^ ad[52] ^ 
                          ad[51] ^ ad[50] ^ ad[49] ^ ad[48] ^ 
                          ad[47] ^ ad[46] ^ ad[45] ^ ad[44] ^ 
                          ad[43] ^ ad[42] ^ ad[41] ^ ad[40] ^ 
                          ad[39] ^ ad[38] ^ ad[37] ^ ad[36] ^ 
                          ad[35] ^ ad[34] ^ ad[33] ^ ad[32] ^ 
                          cben[7] ^ cben[6] ^ cben[5] ^ cben[4]; 
         if (par_en_64)
         begin
            par64_out <= result_reg_64_ ; 
         end
         else
         begin
            par64_out <= 1'bZ ; 
         end 
      end 
   end 


//****************************************************************************************
//FILE IO
//****************************************************************************************

   //This process initializes the memory by reading in the data file
   //and also performs all memory writes.
   always @(negedge rstn or we_32 or we_64 or irdyn or posedge clk  )//or high_dword)
   //*****************************************
   begin : memory_initialization_and_writes
   //*****************************************
      reg[64:1] temp_bit_array[0:address_lines - 1]; 
      reg[4:1] tmpbit; 
      reg[64:1] vector_64; 
      #1;
      if (!rstn & irdyn & !we_32 & !we_64)
      begin
         begin : xhdl_3
            integer i;
            for(i = 0; i <= address_lines - 1; i = i + 1)
            begin
               temp_bit_array[i] = 64'h0000000000000000; 
            end
         end 
        
         begin : xhdl_4
            $readmemh("trgt_tranx_mem_init.dat",temp_bit_array);
         end 
        
         begin : xhdl_5
            integer k;
            for(k = 0; k <= address_lines - 1; k = k + 1)
            begin
               pci_mem[k] <= temp_bit_array[k] ; 
            end
         end 
      end
      else if (we_32 & clk & !irdyn & !trdyn_watch)
      begin
         vector_64 = pci_mem[addr]; 
         if (high_dword == 1)
         begin
            vector_64[64:33] = ad[31:0]; 
         end
         else
         begin
            vector_64[32:1] = ad[31:0]; 
         end 
         pci_mem[addr] <= vector_64 ; 
      end
      else if (we_64 & clk & !irdyn & !trdyn_watch)
      begin
         pci_mem[addr] <= ad ; 
      end
      else
      begin
      end 
   end 

   //This process determines if there is a memory hit
   always @(ad or trgt_tranx_bar0)
   //********************************************
   begin : check_memory_hit
   //********************************************
      if ((trgt_tranx_bar0 <= ad[31:0]) & 
          (ad[31:0] < trgt_tranx_bar0 + mem_hit_range)& 
          (cben[3:0] == 4'b0110 | cben[3:0] == 4'b0111))
      begin
         mem_hit <= 1'b1 ; 
      end
      else
      begin
         mem_hit <= 1'b0 ; 
      end 
   end 


   //io register address space is defined and checked here
   always @(ad or trgt_tranx_bar1)
   //********************************************
   begin : check_io_hit
   //********************************************
      if ((trgt_tranx_bar1 - 'h01 <= ad[31:0]) & 
           (ad[31:0] < trgt_tranx_bar1 + io_hit_range) &
           (cben[3:0] == 4'b0010 | cben[3:0] == 4'b0011))
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
   //tranx_64 High when a 64 bit transaction is detected
   //high_dword High when the 32 bit data represents the high dword of the quad word data
   always @(negedge framen or posedge clk or irdyn)
   //********************************************
   begin : addr_increment
   //********************************************
      reg[31:0] capture_addr_reg; 
      integer left_shift; 
      integer right_shift; 
      if (!rstn)
      begin
        tranx_64 <= 1'b0;
        high_dword <= 0;
        addr <= 0;
      end
      //Capture the address at the begining of an address
      else if (!framen & irdyn & (cben[3:0] == 6 | cben[3:0] == 7) )
      begin
         capture_addr_reg = ad[31:0]; 
         left_shift = 31 - (2 + addr_boundary); 
         right_shift = left_shift + 3; 
         addr <= (capture_addr_reg << left_shift) >> right_shift ; 
         if (!req64n & mem_hit)
         begin
            tranx_64 <= 1'b1 ; 
         end
         else
         begin
            tranx_64 <= 1'b0 ; 
         end 
         if ((ad[2]))
         begin
            high_dword <= 1 ; 
         end
         else
         begin
            high_dword <= 0 ; 
         end 
      end
      //During the transaction increment address when applicable
      else if (clk)
      begin
         if (!framen & !trgt_tranx_retry & !trdyn_watch & !irdyn)
         begin
            if (!tranx_64)
            begin
               if (high_dword == 1)
               begin
                  high_dword <= 0 ; 
                  capture_addr_reg = capture_addr_reg + 8; 
                  addr <= (capture_addr_reg << left_shift) >> right_shift ; 
               end
               else
               begin
                  high_dword <= 1 ; 
               end 
            end
            else
            begin
               capture_addr_reg = capture_addr_reg + 8; 
               addr <= (capture_addr_reg << left_shift) >> right_shift ; 
               high_dword <= 0 ; 
            end 
         end
         //last data transaction
         else if (!irdyn)
         begin
            if (!trdyn_watch)
            begin
               if (!tranx_64)
               begin
                  if (high_dword == 1)
                  begin
                     capture_addr_reg = capture_addr_reg + 8; 
                     addr <= (capture_addr_reg << left_shift) >> right_shift ; 
                  end
                  else
                  begin
                     high_dword <= 1 ; 
                  end 
               end
               else
               begin
                  capture_addr_reg = capture_addr_reg + 8; 
                  high_dword <= 0 ; 
               end 
            end 
         end 
      end 
   end 

   //Here is where the trgtet transactor determines what kind of pci transaction 
   //is being attempted
   always 
   //********************************************
   begin : main
   //********************************************

      ad_out <= {64{1'bz}} ; 
      par_out <= 1'bZ ; 
      par64_out <= 1'bZ ; 
      trdyn <= 1'bZ ; 
      devseln <= 1'bZ ; 
      stopn <= 1'bZ ; 
      ack64n <= 1'bZ; 
      perrn <= 1'bZ ; 
      serrn <= 1'bZ ; 
      we_32 <= 1'b0 ; 
      we_64 <= 1'b0 ; 
      par_en <= 1'b0 ; 
      par_en_64 <= 1'b0 ; 
      trdyn_watch <= 1'b1 ; 

//-----------------------------------------------------------
      
      if (!framen & cben[3:0] == 4'b0111 & mem_hit)
      begin
         #tdel; 
         mem_wr; 
      end

//-----------------------------------------------------------
      else if (!framen & cben[3:0] == 4'b0110 & mem_hit)
      begin
         #tdel; 
         mem_rd; 
      end
//-----------------------------------------------------------

      else if (!framen & cben[3:0] == 4'b0011 & io_hit)
      begin
         #tdel; 
         io_wr; 
      end
//-----------------------------------------------------------

      else if (!framen & cben[3:0] == 4'b0010 & io_hit)
      begin
         #tdel; 
         io_rd; 
      end

//-----------------------------------------------------------
      else if (!framen & cben[3:0] == 4'b1011 & idsel &(ad[7:0] == 'h10 | ad[7:0] == 'h14))
      begin
         address <= ad[31:0] ; 
         #tdel; 
         cfg_wr; 
      end
//-----------------------------------------------------------

      else if (!framen & cben[3:0] == 4'b1010 & idsel & (ad[7:0] == 'h10 | ad[7:0] == 'h14))
      begin
         address <= ad[31:0] ; 
         #tdel; 
         cfg_rd; 
      end 
//-----------------------------------------------------------

      @(posedge clk); 
   end

//********************************************************************************************************
//TASKS
//*********************************************************************************************************

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
         
         //check for 64 bit transaction
         if (tranx_64)
         begin
            we_64 <= 1'b1 ; 
            ack64n <= 1'b0 ; 
         end
         else
         begin
            we_32 <= 1'b1 ; 
            ack64n <= 1'b1 ; 
         end 
         
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
         
         while (!irdyn)
         begin
            @(posedge irdyn);
         end 
         
         ad_out <= {64{1'bz}} ; 
         devseln <= 1'b1 ; 
         stopn <= 1'b1 ; 
         trdyn <= 1'b1 ; 
         trdyn_watch <= 1'b1 ; 
         ack64n <= 1'b1 ; 
         we_32 <= 1'b0 ; 
         we_64 <= 1'b0 ; 
         par_en <= 1'b0 ; 
         par_en_64 <= 1'b0 ; 
      end
   endtask


   //******************
   task mem_rd;
   //******************

      reg[64:1] vector_64; 

      begin
         @(posedge clk); 
         #tdel; 
         trdyn_watch <= 1'b1 ; 
         devseln <= 1'b0 ; 
         stopn <= 1'b1 ; 
         ack64n <= 1'b1 ; 
         ad_out <= 64'h0000000000000000 ; 
         par_en <= 1'b1 ; 
         if (tranx_64)
         begin
            ack64n <= 1'b0 ; 
            par_en_64 <= 1'b1 ; 
         end 
         @(posedge clk); 
         #tdel; 
         //If a trgtet retry is seen
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
    //if trgtet disconnect A is seen
         if (trgt_tranx_disca)
         begin
            stopn <= #tdel 1'b0 ; 
         end 
         
         //Waiting for IRDYN to be high (initiator ready)
         while (irdyn)
         begin
        @(posedge clk);
         end 

    //If this is a 64 bit transaction
         if (tranx_64)
         begin
            //Place data from memory to PCI bus
            ad_out <= pci_mem[addr] ; 
         end
         else
         //If this is a 32 bit transaction place first data onto PCI bus
         begin
            vector_64 = pci_mem[addr]; 
            ad_out <= 'h00000000 ; 
            if (high_dword == 1)
            begin
            //Place data from memory to PCI bus            
               ad_out <= vector_64[64:33] ; 
            end
            else
            begin
            //Place data from memory to PCI bus
            ad_out <= vector_64[32:1] ; 
            end 
         end 

     //wait for clk = 1

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
            if (tranx_64)
            begin
                //Place 64 bit data onto PCI bus
            #1   ad_out <= pci_mem[addr] ; 
            end
            else
            begin
              //Place 32 bit data onto PCI bus
               #1    vector_64 = pci_mem[addr]; 
               ad_out <= 'h00000000 ; 
               if (high_dword == 1)
               begin
                  ad_out <= vector_64[64:33] ; 
               end
               else
               begin
                  ad_out <= vector_64[32:1] ; 
               end 
            end 
            @(posedge clk);
            
         
         end 
         
         if (!irdyn)
         begin
            if (!trdyn_watch)
            begin
               if (tranx_64)
               begin
                  ad_out <= pci_mem[addr] ; 
               end
               else
               begin
                  ad_out <= 'h00000000 ; 
                  if (high_dword == 1)
                  begin
                     ad_out <= vector_64[64:33] ; 
                  end
                  else
                  begin
                     ad_out <= vector_64[32:1] ; 
                  end 
               end 
            end 
            @(posedge irdyn); 
          
         end 
         devseln <= 1'b1 ; 
         stopn <= 1'b1 ; 
         trdyn <= 1'b1 ; 
         trdyn_watch <= 1'b1 ; 
         ack64n <= 1'b1 ; 
         ad_out <= {64{1'bz}} ; 
         we_32 <= 1'b0 ; 
         we_64 <= 1'b0 ; 
         par_en <= 1'b0 ; 
         par_en_64 <= 1'b0 ; 
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
         
         while (irdyn)
         begin
            @(posedge clk); 
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
         ack64n <= 1'b1 ; 
         ad_out <= {64{1'bz}} ; 
         we_32 <= 1'b0 ; 
         we_64 <= 1'b0 ; 
         par_en <= 1'b0 ; 
         par_en_64 <= 1'b0 ; 
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
         ack64n <= 1'b1 ; 
         par_en <= 1'b1 ; 
         ad_out <= 64'h0000000000000000 ; 
         
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
         ack64n <= 1'b1 ; 
         ad_out <= {64{1'bz}} ; 
         we_32 <= 1'b0 ; 
         we_64 <= 1'b0 ; 
         par_en <= 1'b0 ; 
         par_en_64 <= 1'b0 ; 
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
         ack64n <= 1'b1 ; 
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
         ack64n <= 1'b1 ; 
         ad_out <= {64{1'bz}} ; 
         we_32 <= 1'b0 ; 
         we_64 <= 1'b0 ; 
         par_en <= 1'b0 ; 
         par_en_64 <= 1'b0 ; 
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
         ack64n <= 1'b1 ; 
         par_en <= 1'b1 ; 
         ad_out <= 64'h0000000000000000 ; 
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
         ack64n <= 1'b1 ; 
         ad_out <= {64{1'bz}} ; 
         we_32 <= 1'b0 ; 
         we_64 <= 1'b0 ; 
         par_en <= 1'b0 ; 
         par_en_64 <= 1'b0 ; 
      end
   endtask 
endmodule
