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
// Title         : PCI Express BFM Root Port Driver 
// Project       : PCI Express MegaCore function
//-----------------------------------------------------------------------------
// File          : altpcietb_bfm_driver.v
// Author        : Altera Corporation
//-----------------------------------------------------------------------------
// Description :
// This module is driver for the Root Port BFM. It processes the list of
// functions to perform and passes them off to the VC specific interfaces
//-----------------------------------------------------------------------------
// Copyright (c) 2010 Altera Corporation. All rights reserved.  Altera products are
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
module altpcietb_bfm_driver (clk_in, rstn, INTA, INTB, INTC, INTD, dummy_out);

parameter RUN_TGT_MEM_TST = 1;
parameter RUN_DMA_MEM_TST = 1;
parameter AVALON_MM_LITE = 0;
parameter MEM_OFFSET = 32'h0020_0000;
parameter DMA_BASE   = 32'h0000_4000; 
parameter CRA_BASE   = 32'h0000_0000; 


   // TEST_LEVEL is a parameter passed in from the top level test bench that
   // could control the amount of testing done. It is not currently used. 
   parameter TEST_LEVEL  = 1;

// mk_inc altpcietb_bfm_constants.v
   //-----------------------------------------------------------------------------
   // Title         : PCI Express BFM Root Constants Package
   // Project       : PCI Express MegaCore function
   //-----------------------------------------------------------------------------
   // File          : altpcie_bfm_constants.v
   // Author        : Altera Corporation
   //-----------------------------------------------------------------------------
   // Description :
   // This entity provides the BFM with global constants 
   //-----------------------------------------------------------------------------
   // Copyright (c) 2005 Altera Corporation. All rights reserved.  Altera products are
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

   // Root Port Primary Side Bus Number and Device Number
   parameter [7:0] RP_PRI_BUS_NUM = 8'h00 ; 
   parameter [4:0] RP_PRI_DEV_NUM = 5'b00000 ; 
   // Root Port Requester ID
   parameter[15:0] RP_REQ_ID = {RP_PRI_BUS_NUM, RP_PRI_DEV_NUM , 3'b000}; // used in the Requests sent out
   // 2MB of memory
   parameter SHMEM_ADDR_WIDTH = 21; 
   // The first section of the PCI Express I/O Space will be reserved for
   // addressing the Root Port's Shared Memory. PCI Express I/O Initiators
   // would use an I/O address in this range to access the shared memory.
   // Likewise the first section of the PCI Express Memory Space will be
   // reserved for accessing the Root Port's Shared Memory. PCI Express
   // Memory Initiators will use this range to access this memory.
   // These values here set the range that can be used to assign the
   // EP BARs to. 
   parameter[31:0] EBFM_BAR_IO_MIN = 32'b1 << SHMEM_ADDR_WIDTH ; 
   parameter[31:0] EBFM_BAR_IO_MAX = {32{1'b1}}; 
   parameter[31:0] EBFM_BAR_M32_MIN = 32'b1 << SHMEM_ADDR_WIDTH ; 
   parameter[31:0] EBFM_BAR_M32_MAX = {32{1'b1}}; 
   parameter[63:0] EBFM_BAR_M64_MIN = 64'h0000000100000000 ; 
   parameter[63:0] EBFM_BAR_M64_MAX = {64{1'b1}}; 
   parameter EBFM_NUM_VC = 4; // Number of VC's implemented in the Root Port BFM
   parameter EBFM_NUM_TAG = 32; // Number of TAG's used by Root Port BFM
 
// mk_inc altpcietb_bfm_log.v
   //-----------------------------------------------------------------------------
   // Title         : PCI Express BFM Message Logging Include File  
   // Project       : PCI Express MegaCore function
   //-----------------------------------------------------------------------------
   // File          : altpcietb_bfm_log.v
   // Author        : Altera Corporation
   //-----------------------------------------------------------------------------
   // Description :
   // output 
   //-----------------------------------------------------------------------------
   // Copyright (c) 2005 Altera Corporation. All rights reserved.  Altera products are
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

   // Constants for the logging package 
   parameter EBFM_MSG_DEBUG = 0; 
   parameter EBFM_MSG_INFO = 1; 
   parameter EBFM_MSG_WARNING = 2; 
   parameter EBFM_MSG_ERROR_INFO = 3; // Preliminary Error Info Message 
   parameter EBFM_MSG_ERROR_CONTINUE = 4; 
   // Fatal Error Messages always stop the simulation
   parameter EBFM_MSG_ERROR_FATAL = 101; 
   parameter EBFM_MSG_ERROR_FATAL_TB_ERR = 102; 

   // Maximum Message Length in characters 
   parameter EBFM_MSG_MAX_LEN = 100 ;

   // purpose: sets the suppressed_msg_mask
   task ebfm_log_set_suppressed_msg_mask;
      input [EBFM_MSG_ERROR_CONTINUE:EBFM_MSG_DEBUG] msg_mask; 

      begin
         // ebfm_log_set_suppressed_msg_mask
         bfm_log_common.suppressed_msg_mask = msg_mask; 
      end
   endtask

   // purpose: sets the stop_on_msg_mask
   task ebfm_log_set_stop_on_msg_mask;
      input [EBFM_MSG_ERROR_CONTINUE:EBFM_MSG_DEBUG] msg_mask; 

      begin
         // ebfm_log_set_stop_on_msg_mask
         bfm_log_common.stop_on_msg_mask = msg_mask; 
      end
   endtask

   // purpose: Opens the Log File with the specified name
   task ebfm_log_open;
      input [200*8:1] fn; // Log File Name

      begin
         bfm_log_common.log_file = $fopen(fn);
      end
   endtask

   // purpose: Opens the Log File with the specified name
   task ebfm_log_close;

      begin
         // ebfm_log_close
         $fclose(bfm_log_common.log_file); 
         bfm_log_common.log_file = 0; 
      end
   endtask

   // purpose: stops the simulation, with flag to indicate success or not
   function ebfm_log_stop_sim;
      input success; 
      integer success;

      begin
         if (success == 1)
         begin
            $display("SUCCESS: Simulation stopped due to successful completion!");
            `ifdef VCS
            $finish;
            `else
            $stop ;
            `endif
         end
         else
         begin
            $display("FAILURE: Simulation stopped due to error!");
            `ifdef VCS
            $finish;
            `else
            $stop ;
            `endif
         end 
         ebfm_log_stop_sim = 1'b0 ;
      end
   endfunction

   // purpose: This displays a message of the specified type
   function ebfm_display;
      input msg_type; 
      integer msg_type;
      input [EBFM_MSG_MAX_LEN*8:1] message; 

      reg [9*8:1]  prefix ; 
      reg [80*8:1] amsg; 
      reg sup; 
      reg stp; 
      reg dummy ;
      integer i ;
      time ctime ;
      integer itime ; 
      
      begin
         for (i = 0 ; i < EBFM_MSG_MAX_LEN ; i = i + 1) 
           begin : msg_shift 
              if (message[(EBFM_MSG_MAX_LEN*8)-:8] != 8'h00)
                begin
                   disable msg_shift ;
                end
              message = message << 8 ;
           end
         if (msg_type > EBFM_MSG_ERROR_CONTINUE)
           begin
              sup = 1'b0; 
              stp = 1'b1; 
              case (msg_type)
                EBFM_MSG_ERROR_FATAL :
                  begin
                     amsg   = "FAILURE: Simulation stopped due to Fatal error!" ; 
                     prefix = "FATAL:   "; 
                  end
                EBFM_MSG_ERROR_FATAL_TB_ERR :
                  begin
                     amsg   = "FAILURE: Simulation stopped due error in Testbench/BFM design!"; 
                     prefix = "FATAL:   "; 
                  end
                default :
                  begin
                     amsg   = "FAILURE: Simulation stopped due to unknown message type!"; 
                     prefix = "FATAL:   "; 
                  end
              endcase 
           end
         else
           begin
              sup = bfm_log_common.suppressed_msg_mask[msg_type]; 
              stp = bfm_log_common.stop_on_msg_mask[msg_type]; 
              if (stp == 1'b1)
                begin
                   amsg   = "FAILURE: Simulation stopped due to enabled error!"; 
                end
              if (msg_type < EBFM_MSG_INFO)
                begin
                     prefix = "DEBUG:   ";
                end
              else
                begin
                   if (msg_type < EBFM_MSG_WARNING)
                     begin
                        prefix = "INFO:    ";
                     end
                   else
                     begin
                        if (msg_type > EBFM_MSG_WARNING)
                          begin
                             prefix = "ERROR:   "; 
                          end
                        else
                          begin
                             prefix = "WARNING: "; 
                          end 
                     end 
                end 
           end // else: !if(msg_type > EBFM_MSG_ERROR_CONTINUE)
         itime = ($time/1000) ;
         // Display the message if not suppressed
         if (sup != 1'b1)
           begin
              if (bfm_log_common.log_file != 0)
                begin
                   $fdisplay(bfm_log_common.log_file,"%s %d %s %s",prefix,itime,"ns",message); 
                end 
              $display("%s %d %s %s",prefix,itime,"ns",message);
           end 
         // Stop if requested
         if (stp == 1'b1)
           begin
              if (bfm_log_common.log_file != 0)
                begin
                   $fdisplay(bfm_log_common.log_file, "%s", amsg); 
                end 
              $display("%s",amsg); 
              dummy = ebfm_log_stop_sim(0); 
           end 
         // Dummy function return so we can call from other functions
         ebfm_display = 1'b0 ;
      end
   endfunction

   // purpose: produce 1-digit hexadecimal string from a vector 
   function [8:1] himage1;
      input [3:0] vec; 

      begin
         case (vec)
           4'h0 : himage1 = "0" ;
           4'h1 : himage1 = "1" ;
           4'h2 : himage1 = "2" ;
           4'h3 : himage1 = "3" ;
           4'h4 : himage1 = "4" ;
           4'h5 : himage1 = "5" ;
           4'h6 : himage1 = "6" ;
           4'h7 : himage1 = "7" ;
           4'h8 : himage1 = "8" ;
           4'h9 : himage1 = "9" ;
           4'hA : himage1 = "A" ;
           4'hB : himage1 = "B" ;
           4'hC : himage1 = "C" ;
           4'hD : himage1 = "D" ;
           4'hE : himage1 = "E" ;
           4'hF : himage1 = "F" ;
           4'bzzzz : himage1 = "Z" ;
           default : himage1 = "X" ;          
         endcase
      end
   endfunction // himage1

   // purpose: produce 2-digit hexadecimal string from a vector 
   function [16:1] himage2 ;
      input [7:0] vec;
      begin
         himage2 = {himage1(vec[7:4]),himage1(vec[3:0])} ;
      end
   endfunction // himage2

   // purpose: produce 4-digit hexadecimal string from a vector 
   function [32:1] himage4 ;
      input [15:0] vec;
      begin
         himage4 = {himage2(vec[15:8]),himage2(vec[7:0])} ;
      end
   endfunction // himage4

   // purpose: produce 8-digit hexadecimal string from a vector 
   function [64:1] himage8 ;
      input [31:0] vec;
      begin
         himage8 = {himage4(vec[31:16]),himage4(vec[15:0])} ;
      end
   endfunction // himage8

   // purpose: produce 16-digit hexadecimal string from a vector 
   function [128:1] himage16 ;
      input [63:0] vec;
      begin
         himage16 = {himage8(vec[63:32]),himage8(vec[31:0])} ;
      end
   endfunction // himage16

   // purpose: produce 1-digit decimal string from an integer
   function [8:1] dimage1 ;
      input [31:0] num ;
      begin
         case (num) 
           0 : dimage1 = "0" ;
           1 : dimage1 = "1" ;
           2 : dimage1 = "2" ;
           3 : dimage1 = "3" ;
           4 : dimage1 = "4" ;
           5 : dimage1 = "5" ;
           6 : dimage1 = "6" ;
           7 : dimage1 = "7" ;
           8 : dimage1 = "8" ;
           9 : dimage1 = "9" ;
           default : dimage1 = "U" ;
         endcase // case(num)
      end
   endfunction // dimage1

   // purpose: produce 2-digit decimal string from an integer
   function [16:1] dimage2 ;
      input [31:0] num ;
      begin
         dimage2 = {dimage1(num/10),dimage1(num % 10)} ;
      end
   endfunction // dimage2

   // purpose: produce 3-digit decimal string from an integer
   function [24:1] dimage3 ;
      input [31:0] num ;
      begin
         dimage3 = {dimage1(num/100),dimage2(num % 100)} ;
      end
   endfunction // dimage3

   // purpose: produce 4-digit decimal string from an integer
   function [32:1] dimage4 ;
      input [31:0] num ;
      begin
         dimage4 = {dimage1(num/1000),dimage3(num % 1000)} ;
      end
   endfunction // dimage4

   // purpose: produce 5-digit decimal string from an integer
   function [40:1] dimage5 ;
      input [31:0] num ;
      begin
         dimage5 = {dimage1(num/10000),dimage4(num % 10000)} ;
      end
   endfunction // dimage5

   // purpose: produce 6-digit decimal string from an integer
   function [48:1] dimage6 ;
      input [31:0] num ;
      begin
         dimage6 = {dimage1(num/100000),dimage5(num % 100000)} ;
      end
   endfunction // dimage6

   // purpose: produce 7-digit decimal string from an integer
   function [56:1] dimage7 ;
      input [31:0] num ;
      begin
         dimage7 = {dimage1(num/1000000),dimage6(num % 1000000)} ;
      end
   endfunction // dimage7

  // purpose: select the correct dimage call for ascii conversion
  function  [800:1] image ;
     input  [800:1] msg ;
     input  [32:1]  num ;
     begin
        if (num <= 10)
        begin
           image = {msg, dimage1(num)};
        end
        else if (num <= 100)
        begin
           image = {msg, dimage2(num)};
        end
        else if (num <= 1000)
        begin
           image = {msg, dimage3(num)};
        end
        else if (num <= 10000)
        begin
           image = {msg, dimage4(num)};
        end
        else if (num <= 100000)
        begin
           image = {msg, dimage5(num)};
        end
        else if (num <= 1000000)
        begin
           image = {msg, dimage6(num)};
        end
        else image = {msg, dimage7(num)};
     end
   endfunction
  
// mk_inc altpcietb_bfm_shmem.v
   //-----------------------------------------------------------------------------
   // Title         : PCI Express BFM Root Shared Memory Package
   // Project       : PCI Express MegaCore function
   //-----------------------------------------------------------------------------
   // File          : altpcie_bfm_shmem.v
   // Author        : Altera Corporation
   //-----------------------------------------------------------------------------
   // Description :
   // This entity provides the Root Port BFM shared memory which can be used for
   // the following functions
   // * Source of data for transmitted write operations
   // * Source of data for received read operations
   // * Receipient of data for received write operations
   // * Receipient of data for received completions
   //-----------------------------------------------------------------------------
   // Copyright (c) 2005 Altera Corporation. All rights reserved.  Altera products are
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

   parameter SHMEM_FILL_ZERO = 0; 
   parameter SHMEM_FILL_BYTE_INC = 1; 
   parameter SHMEM_FILL_WORD_INC = 2; 
   parameter SHMEM_FILL_DWORD_INC = 4; 
   parameter SHMEM_FILL_QWORD_INC = 8; 
   parameter SHMEM_FILL_ONE = 15; 
   parameter SHMEM_SIZE = 2 ** SHMEM_ADDR_WIDTH; 
   parameter BAR_TABLE_SIZE = 64;
   parameter BAR_TABLE_POINTER = SHMEM_SIZE - BAR_TABLE_SIZE;
   parameter SCR_SIZE = 64;
   parameter CFG_SCRATCH_SPACE = SHMEM_SIZE - BAR_TABLE_SIZE - SCR_SIZE;

   task shmem_write;
      input addr; 
      integer addr;
      input [63:0] data; 
      input leng; 
      integer leng;

      integer rleng; 
      integer i ;

      reg dummy ;
      
      begin
         if (leng > 8)
           begin
              dummy = ebfm_display(EBFM_MSG_ERROR_FATAL,"Task SHMEM_WRITE only accepts write lengths up to 8") ;
              rleng = 8 ;
           end
         else if ( addr < BAR_TABLE_POINTER + BAR_TABLE_SIZE & addr >= CFG_SCRATCH_SPACE & bfm_shmem_common.protect_bfm_shmem )
            begin
              dummy = ebfm_display(EBFM_MSG_ERROR_INFO,"Task SHMEM_WRITE attempted to overwrite the write protected area of the shared memory") ;
              dummy = ebfm_display(EBFM_MSG_ERROR_INFO,"This protected area contains the following data critical to the operation of the BFM:") ;
              dummy = ebfm_display(EBFM_MSG_ERROR_INFO,{"The BFM internal memory area, 64B located at ", himage8(CFG_SCRATCH_SPACE)}) ;
              dummy = ebfm_display(EBFM_MSG_ERROR_INFO,{"The BAR Table, 64B located at ", himage8(BAR_TABLE_POINTER)}) ;
              dummy = ebfm_display(EBFM_MSG_ERROR_INFO,{"All other locations in the shared memory are available from 0 to ", himage8(CFG_SCRATCH_SPACE - 1)}) ;
              dummy = ebfm_display(EBFM_MSG_ERROR_INFO,"Please change your SHMEM_WRITE call to a different memory location") ;
              dummy = ebfm_display(EBFM_MSG_ERROR_FATAL,"Halting Simulation") ;
            end
         else
           begin
              rleng = leng ;
           end
         for(i = 0; i <= (rleng - 1); i = i + 1)
           begin
              bfm_shmem_common.shmem[addr + i] = data[(i*8)+:8]; 
           end
      end
   endtask

   function [63:0] shmem_read;
      input addr; 
      integer addr;
      input leng; 
      integer leng;

      reg[63:0] rdata; 
      integer rleng ;
      integer i ;

      reg dummy ;
      
      begin
         rdata = {64{1'b0}} ;
         if (leng > 8)
           begin
              dummy = ebfm_display(EBFM_MSG_ERROR_FATAL,"Task SHMEM_READ only accepts read lengths up to 8") ;
              rleng = 8 ;
           end
         else
           begin
              rleng = leng ;
           end
         for(i = 0; i <= (rleng - 1); i = i + 1)
           begin
              rdata[(i * 8)+:8] = bfm_shmem_common.shmem[addr + i]; 
           end
         shmem_read = rdata; 
      end
   endfunction

   // purpose: display shared memory data
   function shmem_display;
      input addr; 
      integer addr;
      input leng; 
      integer leng;
      input word_size; 
      integer word_size;
      input flag_addr; 
      integer flag_addr;
      input msg_type; 
      integer msg_type;

      integer iaddr; 
      reg [60*8:1] oneline ;
      reg [128:1] data_str[0:15] ;
      reg [8*5:1] flag ;   
      integer i ;

      reg dummy ;
      
      begin
         // shmem_display
         iaddr = addr ;
         // Backup address to beginning of word if needed
         if (iaddr % word_size > 0)
           begin
              iaddr = iaddr - (iaddr % word_size); 
           end 
         dummy = ebfm_display(msg_type, ""); 
         dummy = ebfm_display(msg_type, "Shared Memory Data Display:"); 
         dummy = ebfm_display(msg_type, "Address  Data"); 
         dummy = ebfm_display(msg_type, "-------  ----"); 
         while (iaddr < (addr + leng))
           begin
              for (i = 0; i < 16 ; i = i + word_size)
                begin : one_line
                   if ( (iaddr + i) > (addr + leng) )
                     begin
                        data_str[i] = "        " ;
                     end
                   else
                     begin
                        case (word_size)
                          8       : data_str[i] = himage16(shmem_read(iaddr + i,8)) ;
                          4       : data_str[i] = {"            ",himage8(shmem_read(iaddr + i,4))} ;
                          2       : data_str[i] = {"                ",himage4(shmem_read(iaddr + i,2))} ;
                          default : data_str[i] = {"                  ",himage2(shmem_read(iaddr + i,1))} ;
                        endcase // case(word_size)
                     end
                end // block: one_line
              if ((flag_addr >= iaddr) & (flag_addr < (iaddr + 16)))
                begin
                   flag = " <===" ; 
                end
              else
                begin
                   flag = "     " ; 
                end 
              // Now compile the whole line
              oneline = {480{1'b0}} ;
              case (word_size)
                8 : oneline = {himage8(iaddr),
                               " ",data_str[0]," ",data_str[8],flag} ;
                4 : oneline = {himage8(iaddr),
                               " ",data_str[0][64:1]," ",data_str[4][64:1],
                               " ",data_str[8][64:1]," ",data_str[12][64:1],
                               flag} ;
                2 : oneline = {himage8(iaddr),
                               " ",data_str[0][32:1]," ",data_str[2][32:1],
                               " ",data_str[4][32:1]," ",data_str[6][32:1],
                               " ",data_str[8][32:1]," ",data_str[10][32:1],
                               " ",data_str[12][32:1]," ",data_str[14][32:1],
                               flag} ;
                default : oneline = {himage8(iaddr),
                               " ",data_str[0][16:1]," ",data_str[1][16:1],
                               " ",data_str[2][16:1]," ",data_str[3][16:1],
                               " ",data_str[4][16:1]," ",data_str[5][16:1],
                               " ",data_str[6][16:1]," ",data_str[7][16:1],
                               " ",data_str[8][16:1]," ",data_str[9][16:1],
                               " ",data_str[10][16:1]," ",data_str[11][16:1],
                               " ",data_str[12][16:1]," ",data_str[13][16:1],
                               " ",data_str[14][16:1]," ",data_str[15][16:1],
                               flag} ;
              endcase
              dummy = ebfm_display(msg_type, oneline); 
              iaddr = iaddr + 16;
           end // while (iaddr < (addr + leng))
         // Dummy return so we can call from other functions
         shmem_display = 1'b0 ;
      end
   endfunction

   task shmem_fill;
      input addr; 
      integer addr;
      input mode; 
      integer mode;
      input leng; // Length to fill in bytes
      integer leng;
      input[63:0] init; 

      integer rembytes; 
      reg[63:0] data; 
      integer uaddr; 
      parameter[7:0] ZDATA = {8{1'b0}}; 
      parameter[7:0] ODATA = {8{1'b1}}; 

      begin
         rembytes = leng ;
         data = init ;
         uaddr = addr ;
         while (rembytes > 0)
         begin
            case (mode)
               SHMEM_FILL_ZERO :
                        begin
                           shmem_write(uaddr, ZDATA,1); 
                           rembytes = rembytes - 1; 
                           uaddr = uaddr + 1; 
                        end
               SHMEM_FILL_BYTE_INC :
                        begin
                           shmem_write(uaddr, data, 1); 
                           data[7:0] = data[7:0] + 1; 
                           rembytes = rembytes - 1; 
                           uaddr = uaddr + 1; 
                        end
               SHMEM_FILL_WORD_INC :
                        begin
                           begin : xhdl_3
                              integer i;
                              for(i = 0; i <= 1; i = i + 1)
                              begin
                                 if (rembytes > 0)
                                 begin
                                    shmem_write(uaddr, data[(i*8)+:8], 1); 
                                    rembytes = rembytes - 1; 
                                    uaddr = uaddr + 1; 
                                 end 
                              end
                           end // i
                           data[15:0] = data[15:0] + 1; 
                        end
               SHMEM_FILL_DWORD_INC :
                        begin
                           begin : xhdl_4
                              integer i;
                              for(i = 0; i <= 3; i = i + 1)
                              begin
                                 if (rembytes > 0)
                                 begin
                                    shmem_write(uaddr, data[(i*8)+:8], 1); 
                                    rembytes = rembytes - 1; 
                                    uaddr = uaddr + 1; 
                                 end 
                              end
                           end // i
                           data[31:0] = data[31:0] + 1 ; 
                        end
               SHMEM_FILL_QWORD_INC :
                        begin
                           begin : xhdl_5
                              integer i;
                              for(i = 0; i <= 7; i = i + 1)
                              begin
                                 if (rembytes > 0)
                                 begin
                                    shmem_write(uaddr, data[(i*8)+:8], 1); 
                                    rembytes = rembytes - 1; 
                                    uaddr = uaddr + 1; 
                                 end 
                              end
                           end // i
                           data[63:0] = data[63:0] + 1; 
                        end
               SHMEM_FILL_ONE :
                        begin
                           shmem_write(uaddr, ODATA, 1); 
                           rembytes = rembytes - 1; 
                           uaddr = uaddr + 1; 
                        end
               default :
                        begin
                        end
            endcase 
         end 
      end
   endtask

   // Returns 1 if okay
   function [0:0] shmem_chk_ok;
      input addr; 
      integer addr;
      input mode; 
      integer mode;
      input leng; // Length to fill in bytes
      integer leng;
      input[63:0] init; 
      input display_error; 
      integer display_error;

      reg dummy ;
       
      integer rembytes; 
      reg[63:0] data; 
      reg[63:0] actual; 
      integer uaddr; 
      integer daddr; 
      integer dlen; 
      integer incr_count; 
      parameter[7:0] ZDATA = {8{1'b0}}; 
      parameter[7:0] ODATA = {8{1'b1}}; 
      reg [36*8:1] actline; 
      reg [36*8:1] expline; 
      integer word_size; 

      begin
         rembytes = leng ;
         uaddr = addr ;
         data = init ;
         actual = init ;
         incr_count = 0 ;
         case (mode)
            SHMEM_FILL_WORD_INC :
                     begin
                        word_size = 2; 
                     end
            SHMEM_FILL_DWORD_INC :
                     begin
                        word_size = 4; 
                     end
            SHMEM_FILL_QWORD_INC :
                     begin
                        word_size = 8; 
                     end
            default :
                     begin
                        word_size = 1; 
                     end
         endcase // case(mode)
         begin : compare_loop
         while (rembytes > 0)
         begin 
            case (mode)
               SHMEM_FILL_ZERO :
                 begin
                    actual[7:0] = shmem_read(uaddr, 1); 
                    if (actual[7:0] != ZDATA)
                      begin
                         expline = {"    Expected Data: ", himage2(ZDATA[7:0]), "              "};
                         actline = {"      Actual Data: ", himage2(actual[7:0]), "              "}; 
                         disable compare_loop; 
                      end 
                    rembytes = rembytes - 1; 
                    uaddr = uaddr + 1; 
                 end
               SHMEM_FILL_BYTE_INC :
                 begin
                    actual[7:0] = shmem_read(uaddr, 1); 
                    if (actual[7:0] != data[7:0])
                      begin
                         expline = {"    Expected Data: ", himage2(data[7:0]), "              "};
                         actline = {"      Actual Data: ", himage2(actual[7:0]), "              "}; 
                         disable compare_loop; 
                      end 
                    data[7:0] = data[7:0] + 1; 
                    rembytes = rembytes - 1; 
                    uaddr = uaddr + 1; 
                 end
               SHMEM_FILL_WORD_INC :
                 begin
                    actual[7:0] = shmem_read(uaddr, 1); 
                    if (actual[7:0] != data[(incr_count * 8)+:8])
                      begin
                         expline = {"    Expected Data: ", himage2(data[((incr_count * 8) + 7)+:8]), "              "};
                         actline = {"      Actual Data: ", himage2(actual[7:0]), "              "}; 
                         disable compare_loop; 
                      end 
                    if (incr_count == 1)
                      begin
                         data[15:0] = data[15:0] + 1 ;
                         incr_count = 0; 
                      end
                    else
                      begin
                         incr_count = incr_count + 1; 
                      end 
                    rembytes = rembytes - 1; 
                    uaddr = uaddr + 1; 
                 end
               SHMEM_FILL_DWORD_INC :
                 begin
                    actual[7:0] = shmem_read(uaddr, 1); 
                    if (actual[7:0] != data[(incr_count * 8)+:8])
                      begin
                         expline = {"    Expected Data: ", himage2(data[((incr_count * 8) + 7)+:8]), "              "};
                         actline = {"      Actual Data: ", himage2(actual[7:0]), "              "}; 
                         disable compare_loop; 
                      end 
                    if (incr_count == 3)
                      begin
                         data[31:0] = data[31:0] + 1; 
                         incr_count = 0; 
                      end
                    else
                      begin
                         incr_count = incr_count + 1; 
                      end 
                    rembytes = rembytes - 1; 
                    uaddr = uaddr + 1; 
                 end
               SHMEM_FILL_QWORD_INC :
                 begin
                    actual[7:0] = shmem_read(uaddr, 1); 
                    if (actual[7:0] != data[(incr_count * 8)+:8])
                      begin
                         expline = {"    Expected Data: ", himage2(data[((incr_count * 8) + 7)+:8]), "              "};
                         actline = {"      Actual Data: ", himage2(actual[7:0]), "              "}; 
                         disable compare_loop; 
                      end 
                    if (incr_count == 7)
                      begin
                         data[63:0] = data[63:0] + 1; 
                         incr_count = 0; 
                      end
                    else
                      begin
                         incr_count = incr_count + 1; 
                      end 
                    rembytes = rembytes - 1; 
                    uaddr = uaddr + 1; 
                 end
               SHMEM_FILL_ONE :
                 begin
                    actual[7:0] = shmem_read(uaddr, 1); 
                    if (actual[7:0] != ODATA)
                      begin
                         expline = {"    Expected Data: ", himage2(ODATA[7:0]), "              "};
                         actline = {"      Actual Data: ", himage2(actual[7:0]), "              "}; 
                         disable compare_loop; 
                      end 
                    rembytes = rembytes - 1; 
                    uaddr = uaddr + 1; 
                 end
               default :
                 begin
                 end
            endcase 
         end 
         end // block: compare_loop         
         if (rembytes > 0)
         begin
            if (display_error == 1)
            begin
               dummy = ebfm_display(EBFM_MSG_ERROR_INFO, ""); 
               dummy = ebfm_display(EBFM_MSG_ERROR_INFO, {"Shared memory data miscompare at address: ", himage8(uaddr)}); 
               dummy = ebfm_display(EBFM_MSG_ERROR_INFO, expline); 
               dummy = ebfm_display(EBFM_MSG_ERROR_INFO, actline); 
               // Backup and display a little before the miscompare
               // Figure amount to backup
               daddr = uaddr % 32; // Back up no more than 32 bytes
               // There was a miscompare, display an error message
               if (daddr < 16)
               begin
                  // But at least 16
                  daddr = daddr + 16; 
               end 
               // Backed up display address 
               daddr = uaddr - daddr; 
               // Don't backup more than start of compare 
               if (daddr < addr)
               begin
                  daddr = addr; 
               end 
               // Try to display 64 bytes 
               dlen = 64; 
               // But don't display beyond the end of the compare
               if (daddr + dlen > addr + leng)
               begin
                  dlen = (addr + leng) - daddr; 
               end 
               dummy = shmem_display(daddr, dlen, word_size, uaddr, EBFM_MSG_ERROR_INFO); 
            end 
            shmem_chk_ok = 0; 
         end
         else
         begin
            shmem_chk_ok = 1; 
         end 
      end
   endfunction
//`endif 
// mk_inc altpcietb_bfm_rdwr.v
   //-----------------------------------------------------------------------------
   // Title         : PCI Express BFM Package of Read/Write Routines
   // Project       : PCI Express MegaCore function
   //-----------------------------------------------------------------------------
   // File          : altpcietb_bfm_rdwr.v
   // Author        : Altera Corporation
   //-----------------------------------------------------------------------------
   // Description :
   // This package provides all of the PCI Express BFM Read, Write and Utility
   // Routines.
   //-----------------------------------------------------------------------------
   // Copyright © 2005 Altera Corporation. All rights reserved.  Altera products are
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

// mk_inc altpcietb_bfm_req_intf.v
//-----------------------------------------------------------------------------
// Title         : PCI Express BFM Package for Request Interface 
// Project       : PCI Express MegaCore function
//-----------------------------------------------------------------------------
// File          : altpcietb_bfm_req_intf.v
// Author        : Altera Corporation
//-----------------------------------------------------------------------------
// Description :
// This package provides the interface for passing the requests between the
// Read/Write Request package and ultimately the user's driver and the VC
// Interface Entitites
//-----------------------------------------------------------------------------
// Copyright (c) 2005 Altera Corporation. All rights reserved.  Altera products are
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


//`ifdef __ALTPCIETB_BFM_REQ_INTF__
//`else
// `define __ALTPCIETB_BFM_REQ_INTF__
// `include "altpcietb_bfm_constants.v" 
// `include "altpcietb_bfm_log.v" 
   // This constant defines how long to wait whenever waiting for some external event...
   parameter NUM_PS_TO_WAIT = 8000 ;

   // purpose: Sets the Max Payload size variables
   task req_intf_set_max_payload;
      input max_payload_size; 
      integer max_payload_size;
      input ep_max_rd_req; // 0 means use max_payload_size    
      integer ep_max_rd_req;
      input rp_max_rd_req; 
      integer rp_max_rd_req;

      begin
         // 0 means use max_payload_size    
         // set_max_payload
         bfm_req_intf_common.bfm_max_payload_size = max_payload_size; 
         if (ep_max_rd_req > 0)
         begin
            bfm_req_intf_common.bfm_ep_max_rd_req = ep_max_rd_req; 
         end
         else
         begin
            bfm_req_intf_common.bfm_ep_max_rd_req = max_payload_size; 
         end 
         if (rp_max_rd_req > 0)
         begin
            bfm_req_intf_common.bfm_rp_max_rd_req = rp_max_rd_req; 
         end
         else
         begin
            bfm_req_intf_common.bfm_rp_max_rd_req = max_payload_size; 
         end 
      end
   endtask

   // purpose: Returns the stored max payload size
   function integer req_intf_max_payload_size;
   input dummy;
      begin
         req_intf_max_payload_size = bfm_req_intf_common.bfm_max_payload_size; 
      end
   endfunction

   // purpose: Returns the stored end point max read request size
   function integer req_intf_ep_max_rd_req_size;
   input dummy;
      begin
         req_intf_ep_max_rd_req_size = bfm_req_intf_common.bfm_ep_max_rd_req; 
      end
   endfunction

   // purpose: Returns the stored root port max read request size
   function integer req_intf_rp_max_rd_req_size;
   input dummy;
      begin
         req_intf_rp_max_rd_req_size = bfm_req_intf_common.bfm_rp_max_rd_req; 
      end
   endfunction

   // purpose: procedure to wait until the root port is done being reset
   task req_intf_wait_reset_end;

      begin
         while (bfm_req_intf_common.reset_in_progress == 1'b1)
         begin
            #NUM_PS_TO_WAIT; 
         end 
      end
   endtask

   // purpose: procedure to get a free tag from the pool. Waits for one
   // to be free if none available initially
   task req_intf_get_tag;
      output tag; 
      integer tag;
      input need_handle; 
      input lcl_addr; 
      integer lcl_addr;

      integer tag_v; 

      begin
         tag_v = EBFM_NUM_TAG ;
         while ((tag_v > EBFM_NUM_TAG - 1) & (bfm_req_intf_common.reset_in_progress == 1'b0))
         begin : main_tloop
            // req_intf_get_tag
            // Find a tag to use
            begin : xhdl_0
               integer i;
               for(i = 0; i <= EBFM_NUM_TAG - 1; i = i + 1)
               begin : sub_tloop
                  if (((bfm_req_intf_common.tag_busy[i]) == 1'b0) & 
                      ((bfm_req_intf_common.hnd_busy[i]) == 1'b0))
                  begin
                     bfm_req_intf_common.tag_busy[i] = 1'b1; 
                     bfm_req_intf_common.hnd_busy[i] = need_handle; 
                     bfm_req_intf_common.tag_lcl_addr[i] = lcl_addr; 
                     tag_v = i; 
                     disable main_tloop; 
                  end 
               end
            end // i
            #(NUM_PS_TO_WAIT); 
         end 
         if (bfm_req_intf_common.reset_in_progress == 1'b1)
         begin
            tag = EBFM_NUM_TAG; 
         end
         else
         begin
            tag = tag_v; 
         end 
      end
   endtask

   // purpose: makes a request pending for the appropriate VC interface
   task req_intf_vc_req;
      input[192:0] info_v; 

      integer vcnum; 

      reg dummy ;
      
      begin
         // Get the Virtual Channel Number from the Traffic Class Number
         vcnum = bfm_req_intf_common.tc2vc_map[info_v[118:116]]; 
         if (vcnum >= EBFM_NUM_VC)
         begin
            dummy = ebfm_display(EBFM_MSG_ERROR_FATAL, 
                         {"Attempt to transmit Packet with TC mapped to unsupported VC.", 
                          "TC: ", dimage1(info_v[118:116]),
                          ", VC: ", dimage1(vcnum)}); 
         end 
         // Make sure the ACK from any previous requests are cleared
         while (((bfm_req_intf_common.req_info_ack[vcnum]) == 1'b1) & 
                (bfm_req_intf_common.reset_in_progress == 1'b0))
         begin
            #(NUM_PS_TO_WAIT); 
         end 
         if (bfm_req_intf_common.reset_in_progress == 1'b1)
           begin
              // Exit
              disable req_intf_vc_req ; 
           end 
         // Make the Request
         bfm_req_intf_common.req_info[vcnum] = info_v; 
         bfm_req_intf_common.req_info_valid[vcnum] = 1'b1; 
         // Now wait for it to be acknowledged
         while ((bfm_req_intf_common.req_info_ack[vcnum] == 1'b0) & 
                (bfm_req_intf_common.reset_in_progress == 1'b0))
         begin
            #(NUM_PS_TO_WAIT); 
         end 
         // Clear the request
         bfm_req_intf_common.req_info[vcnum] = {193{1'b0}}; 
         bfm_req_intf_common.req_info_valid[vcnum] = 1'b0; 
      end
   endtask

   // purpose: Releases a reserved handle
   task req_intf_release_handle;
      input handle; 
      integer handle;

      reg dummy ;
      
      begin
         // req_intf_release_handle
         if ((bfm_req_intf_common.hnd_busy[handle]) != 1'b1)
         begin
            dummy = ebfm_display(EBFM_MSG_ERROR_FATAL, 
                         {"Attempt to release Handle ", 
                          dimage4(handle), 
                          " that is not reserved."}); 
         end 
         bfm_req_intf_common.hnd_busy[handle] = 1'b0; 
      end
   endtask

   // purpose: Wait for completion on the specified handle
   task req_intf_wait_compl;
      input handle; 
      integer handle;
      output[2:0] compl_status; 
      input keep_handle; 

      reg dummy ;
      
      begin
         if ((bfm_req_intf_common.hnd_busy[handle]) != 1'b1)
         begin
            dummy = ebfm_display(EBFM_MSG_ERROR_FATAL, 
                         {"Attempt to wait for completion on Handle ", 
                          dimage4(handle), 
                          " that is not reserved."}); 
         end 
         while ((bfm_req_intf_common.reset_in_progress == 1'b0) & 
                (bfm_req_intf_common.tag_busy[handle] == 1'b1))
         begin
            #(NUM_PS_TO_WAIT); 
         end 
         if ((bfm_req_intf_common.tag_busy[handle]) == 1'b0)
         begin
            compl_status = bfm_req_intf_common.tag_status[handle]; 
         end
         else
         begin
            compl_status = "UUU"; 
         end 
         if (keep_handle != 1'b1)
         begin
            req_intf_release_handle(handle); 
         end 
      end
   endtask

   // purpose: This gets the pending request (if any) for the specified VC
   task vc_intf_get_req;
      input vc_num; 
      integer vc_num;
      output req_valid; 
      output[127:0] req_desc; 
      output lcladdr; 
      integer lcladdr;
      output imm_valid; 
      output[31:0] imm_data; 

      begin
         // vc_intf_get_req
         req_desc  = bfm_req_intf_common.req_info[vc_num][127:0]; 
         lcladdr   = bfm_req_intf_common.req_info[vc_num][159:128]; 
         imm_data  = bfm_req_intf_common.req_info[vc_num][191:160]; 
         imm_valid = bfm_req_intf_common.req_info[vc_num][192]; 
         req_valid = bfm_req_intf_common.req_info_valid[vc_num]; 
      end
   endtask

   // purpose: This sets the acknowledgement for a pending request
   task vc_intf_set_ack;
      input vc_num; 
      integer vc_num;

      reg dummy ;
      
      begin
         if (bfm_req_intf_common.req_info_valid[vc_num] != 1'b1)
         begin
            dummy = ebfm_display(EBFM_MSG_ERROR_FATAL, 
                         {"VC Interface ", 
                          dimage1(vc_num), 
                          " tried to ACK a request that is not there."}); 
         end 
         if (bfm_req_intf_common.req_info_ack[vc_num] != 1'b0)
         begin
            dummy = ebfm_display(EBFM_MSG_ERROR_FATAL, 
                         {"VC Interface ", 
                          dimage1(vc_num), 
                          " tried to ACK a request second time."}); 
         end 
         bfm_req_intf_common.req_info_ack[vc_num] = 1'b1; 
      end
   endtask

   // purpose: This conditionally clears the acknowledgement for a pending request
   //          It only clears the ack if the req valid has been cleared.
   //          Returns '1' if the Ack was cleared, else returns '0'.
   function [0:0] vc_intf_clr_ack;
      input vc_num; 
      integer vc_num;

      begin
         if ((bfm_req_intf_common.req_info_valid[vc_num]) == 1'b0)
         begin
            bfm_req_intf_common.req_info_ack[vc_num] = 1'b0; 
            vc_intf_clr_ack = 1'b1; 
         end
         else
         begin
            vc_intf_clr_ack = 1'b0; 
         end 
      end
   endfunction

   // purpose: This routine is to record the completion of a previous non-posted request
   task vc_intf_rpt_compl;
      input tag; 
      integer tag;
      input[2:0] status; 

      reg dummy ;
      
      begin
         // vc_intf_rpt_compl
         bfm_req_intf_common.tag_status[tag] = status; 
         if ((bfm_req_intf_common.tag_busy[tag]) != 1'b1)
         begin
            dummy = ebfm_display(EBFM_MSG_ERROR_FATAL, 
                         {"Tried to clear a tag that was not busy. Tag: ", 
                          dimage4(tag)}); 
         end 
         bfm_req_intf_common.tag_busy[tag] = 1'b0; 
      end
   endtask

   task vc_intf_reset_flag;
      input rstn; 

      begin
         bfm_req_intf_common.reset_in_progress = ~rstn; 
      end
   endtask

   function integer vc_intf_get_lcl_addr;
      input tag; 
      integer tag;

      begin
         // vc_intf_get_lcl_addr
         if ((bfm_req_intf_common.tag_lcl_addr[tag] != -1) & 
             ((bfm_req_intf_common.tag_busy[tag] == 1'b1) | 
              (bfm_req_intf_common.hnd_busy[tag] == 1'b1)))
         begin
            vc_intf_get_lcl_addr = bfm_req_intf_common.tag_lcl_addr[tag]; 
         end
         else
         begin
            vc_intf_get_lcl_addr = -1 ; 
         end 
      end
   endfunction

   function integer vc_intf_sample_perf;
      input vc_num;
      integer vc_num;
      begin
         vc_intf_sample_perf = bfm_req_intf_common.perf_req[vc_num];
      end
   endfunction

  task vc_intf_set_perf; 
  input [31:0] vc_num;
  input [31:0] tx_pkts;
  input [31:0] tx_qwords;
  input [31:0] rx_pkts;
  input [31:0] rx_qwords;
  begin
     bfm_req_intf_common.perf_tx_pkts[vc_num]   = tx_pkts ;
     bfm_req_intf_common.perf_tx_qwords[vc_num] = tx_qwords ;
     bfm_req_intf_common.perf_rx_pkts[vc_num]   = rx_pkts ;
     bfm_req_intf_common.perf_rx_qwords[vc_num] = rx_qwords ;
     bfm_req_intf_common.perf_ack[vc_num]       = 1'b1 ;
  end
  endtask

   task vc_intf_clr_perf;
      input vc_num;
      integer vc_num;
      begin
         bfm_req_intf_common.perf_ack[vc_num] = 1'b0;
      end
   endtask

   task req_intf_start_perf_sample;
   integer i;
   begin
      bfm_req_intf_common.perf_req = {EBFM_NUM_VC{1'b1}};
      bfm_req_intf_common.last_perf_timestamp = $time;
      while (bfm_req_intf_common.perf_req != {EBFM_NUM_VC{1'b0}})
      begin
         #NUM_PS_TO_WAIT;
	 for (i = 1'b0 ; i < EBFM_NUM_VC ; i = i +1)
	 begin
	    if (bfm_req_intf_common.perf_ack[i] == 1'b1)
	    begin
	       bfm_req_intf_common.perf_req[i] = 1'b0;
	    end
	 end
      end
   end
   endtask

   task req_intf_disp_perf_sample;
   integer total_tx_qwords;
   integer total_tx_pkts;
   integer total_rx_qwords;
   integer total_rx_pkts;
   integer tx_mbyte_ps;
   integer rx_mbyte_ps;
   output  tx_mbit_ps;
   integer tx_mbit_ps;
   output  rx_mbit_ps;
   integer rx_mbit_ps;
   integer delta_time;
   integer delta_ns;
   output  bytes_transmitted;
   integer bytes_transmitted;
   reg   [EBFM_MSG_MAX_LEN*8:1] message;
   integer i;
   integer dummy;
   begin
      total_tx_qwords = 0;
      total_tx_pkts   = 0;
      total_rx_qwords = 0;
      total_rx_pkts   = 0;
      delta_time = $time - bfm_req_intf_common.last_perf_timestamp;
      delta_ns = delta_time / 1000;
      req_intf_start_perf_sample ;
      for (i = 0; i < EBFM_NUM_VC; i = i + 1)
      begin
         total_tx_qwords = total_tx_qwords + bfm_req_intf_common.perf_tx_qwords[i] ;
         total_tx_pkts   = total_tx_pkts   + bfm_req_intf_common.perf_tx_pkts[i];
         total_rx_qwords = total_rx_qwords + bfm_req_intf_common.perf_rx_qwords[i];
         total_rx_pkts   = total_rx_pkts   + bfm_req_intf_common.perf_rx_pkts[i];
      end
      tx_mbyte_ps = (total_tx_qwords * 8) / (delta_ns / 1000);
      rx_mbyte_ps = (total_rx_qwords * 8) / (delta_ns / 1000);
      tx_mbit_ps  = tx_mbyte_ps * 8;
      rx_mbit_ps  = rx_mbyte_ps * 8;
      bytes_transmitted = total_tx_qwords*8;
      
      dummy = ebfm_display(EBFM_MSG_INFO, {image("PERF: Sample Duration: ", delta_ns)," ns"});
      dummy = ebfm_display(EBFM_MSG_INFO, {image("PERF:      Tx Packets: ", total_tx_pkts)});
      dummy = ebfm_display(EBFM_MSG_INFO, {image("PERF:        Tx Bytes: ", total_tx_qwords*8)});
      dummy = ebfm_display(EBFM_MSG_INFO, {image("PERF:    Tx MByte/sec: ", tx_mbyte_ps)});
      dummy = ebfm_display(EBFM_MSG_INFO, {image("PERF:     Tx Mbit/sec: ", tx_mbit_ps)});
      dummy = ebfm_display(EBFM_MSG_INFO, {image("PERF:      Rx Packets: ", total_rx_pkts)});
      dummy = ebfm_display(EBFM_MSG_INFO, {image("PERF:        Rx Bytes: ", total_rx_qwords*8)});
      dummy = ebfm_display(EBFM_MSG_INFO, {image("PERF:    Rx MByte/sec: ", rx_mbyte_ps)});
      dummy = ebfm_display(EBFM_MSG_INFO, {image("PERF:     Rx Mbit/sec: ", rx_mbit_ps)});
   end
   endtask

//`endif 

   function [3:0] ebfm_calc_firstbe;
      input byte_address;
      integer byte_address;
      input byte_length;
      integer byte_length;

      begin
         case (byte_address % 4)
            0 :
                     begin
                        case (byte_length)
                           0 : ebfm_calc_firstbe = 4'b0000;
                           1 : ebfm_calc_firstbe = 4'b0001;
                           2 : ebfm_calc_firstbe = 4'b0011;
                           3 : ebfm_calc_firstbe = 4'b0111;
                           default : ebfm_calc_firstbe = 4'b1111;
                        endcase
                     end
            1 :
                     begin
                        case (byte_length)
                           0 : ebfm_calc_firstbe = 4'b0000;
                           1 : ebfm_calc_firstbe = 4'b0010;
                           2 : ebfm_calc_firstbe = 4'b0110;
                           default : ebfm_calc_firstbe = 4'b1110;
                        endcase
                     end
            2 :
                     begin
                        case (byte_length)
                           0 : ebfm_calc_firstbe = 4'b0000;
                           1 : ebfm_calc_firstbe = 4'b0100;
                           default : ebfm_calc_firstbe = 4'b1100;
                        endcase
                     end
            3 :
                     begin
                        case (byte_length)
                           0 : ebfm_calc_firstbe = 4'b0000;
                           default : ebfm_calc_firstbe = 4'b1000;
                        endcase
                     end
            default :
                     begin
                        ebfm_calc_firstbe = 4'b0000;
                     end
         endcase
      end
   endfunction

   function [3:0] ebfm_calc_lastbe;
      input byte_address;
      integer byte_address;
      input byte_length;
      integer byte_length;

      begin
         if ((byte_address % 4) + byte_length > 4)
         begin
            case ((byte_address + byte_length) % 4)
               0 : ebfm_calc_lastbe = 4'b1111;
               3 : ebfm_calc_lastbe = 4'b0111;
               2 : ebfm_calc_lastbe = 4'b0011;
               1 : ebfm_calc_lastbe = 4'b0001;
               default : ebfm_calc_lastbe = 4'bXXXX;
            endcase
         end
         else
         begin
            ebfm_calc_lastbe = 4'b0000;
         end
      end
   endfunction

   // purpose: This is the full featured configuration read that has all
   // optional behavior via the arguments
   task ebfm_cfgrd;
      input bus_num;
      integer bus_num;
      input dev_num;
      integer dev_num;
      input fnc_num;
      integer fnc_num;
      input regb_ad;
      integer regb_ad;
      input regb_ln;
      integer regb_ln;
      input lcladdr;
      integer lcladdr;
      input compl_wait;
      input need_handle;
      output[2:0] compl_status;
      output handle;
      integer handle;

      reg[192:0] info_v;
      integer tag_v;
      reg i_need_handle;

      begin
         info_v = {193{1'b0}} ;
         // Get a TAG
         i_need_handle = compl_wait | need_handle;
         req_intf_get_tag(tag_v, i_need_handle, lcladdr);
         // Assemble the request
         if ((bus_num == RP_PRI_BUS_NUM) & (dev_num == RP_PRI_DEV_NUM))
         begin
            info_v[127:120] = 8'h04; // CfgRd0
         end
         else
         begin
            info_v[127:120] = 8'h05; // CfgRd1
         end
         info_v[119:112] = 8'h00; // R, TC, RRRR fields all 0
         info_v[111:104] = 8'h00; // TD, EP, Attr, RR, LL all 0
         info_v[103:96] = 8'h01; // Length 1 DW
         info_v[95:80] = RP_REQ_ID; // Requester ID
         info_v[79:72] = tag_v ;
         info_v[71:68] = 4'h0; // Last DW BE
         info_v[67:64] = ebfm_calc_firstbe(regb_ad, regb_ln);
         info_v[63:56] = bus_num[7:0] ;
         info_v[55:51] = dev_num[4:0] ;
         info_v[50:48] = fnc_num[2:0] ;
         info_v[47:44] = 4'h0; // RRRR
         info_v[43:34] = (regb_ad / 4) ;
         info_v[33:32] = 2'b00; // RR
         // Make the request
         req_intf_vc_req(info_v);
         // Wait for completion if specified to do so
         if (compl_wait == 1'b1)
         begin
            req_intf_wait_compl(tag_v, compl_status, need_handle);
         end
         else
         begin
            compl_status = "UUU";
         end
         // Return the handle
         if (need_handle == 1'b0)
         begin
            handle = -1;
         end
         else
         begin
            handle = tag_v;
         end
      end
   endtask

   // purpose: Configuration Read that waits for completion automatically
   task ebfm_cfgrd_wait;
      input bus_num;
      integer bus_num;
      input dev_num;
      integer dev_num;
      input fnc_num;
      integer fnc_num;
      input regb_ad;
      integer regb_ad;
      input regb_ln;
      integer regb_ln;
      input lcladdr;
      integer lcladdr;
      output[2:0] compl_status;

      integer dum_hnd;

      begin
         ebfm_cfgrd(bus_num, dev_num, fnc_num, regb_ad, regb_ln, lcladdr,
         1'b1, 1'b0, compl_status, dum_hnd);
      end
   endtask

   // purpose: Configuration Read that does not wait, does not return handle
   //          Need to assume completes okay and is known to be done by the
   //          time a subsequent read completes.
   task ebfm_cfgrd_nowt;
      input bus_num;
      integer bus_num;
      input dev_num;
      integer dev_num;
      input fnc_num;
      integer fnc_num;
      input regb_ad;
      integer regb_ad;
      input regb_ln;
      integer regb_ln;
      input lcladdr;
      integer lcladdr;

      integer dum_hnd;
      reg[2:0] dum_sts;

      begin
         ebfm_cfgrd(bus_num, dev_num, fnc_num, regb_ad, regb_ln, lcladdr,
         1'b0, 1'b0, dum_sts, dum_hnd);
      end
   endtask

   // purpose: This is the full featured configuration write that has all
   // optional behavior via the arguments
   task ebfm_cfgwr;
      input bus_num;
      integer bus_num;
      input dev_num;
      integer dev_num;
      input fnc_num;
      integer fnc_num;
      input regb_ad;
      integer regb_ad;
      input regb_ln;
      integer regb_ln;
      input lcladdr;
      integer lcladdr;
      input imm_valid;
      input[31:0] imm_data;
      input compl_wait;
      input need_handle;
      output[2:0] compl_status;
      output handle;
      integer handle;

      reg[192:0] info_v;
      integer tag_v;
      reg i_need_handle;

      begin
         info_v = {193{1'b0}} ;
         // Get a TAG
         i_need_handle = compl_wait | need_handle;
         req_intf_get_tag(tag_v, i_need_handle, -1);
         // Assemble the request
         info_v[192] = imm_valid;
         info_v[191:160] = imm_data;
         info_v[159:128] = lcladdr;
         if ((bus_num == RP_PRI_BUS_NUM) & (dev_num == RP_PRI_DEV_NUM))
         begin
            info_v[127:120] = 8'h44; // CfgWr0
         end
         else
         begin
            info_v[127:120] = 8'h45; // CfgWr1
         end
         info_v[119:112] = 8'h00; // R, TC, RRRR fields all 0
         info_v[111:104] = 8'h00; // TD, EP, Attr, RR, LL all 0
         info_v[103:96] = 8'h01; // Length 1 DW
         info_v[95:80] = RP_REQ_ID; // Requester ID
         info_v[79:72] = tag_v ;
         info_v[71:68] = 4'h0; // Last DW BE
         info_v[67:64] = ebfm_calc_firstbe(regb_ad, regb_ln);
         info_v[63:56] = bus_num[7:0] ;
         info_v[55:51] = dev_num[4:0] ;
         info_v[50:48] = fnc_num[2:0] ;
         info_v[47:44] = 4'h0; // RRRR
         info_v[43:34] = (regb_ad / 4) ;
         info_v[33:32] = 2'b00; // RR
         // Make the request
         req_intf_vc_req(info_v);
         // Wait for completion if specified to do so
         if (compl_wait == 1'b1)
         begin
            req_intf_wait_compl(tag_v, compl_status, need_handle);
         end
         else
         begin
            compl_status = "UUU";
         end
         // Return the handle
         if (need_handle == 1'b0)
         begin
            handle = -1;
         end
         else
         begin
            handle = tag_v;
         end
      end
   endtask

   // purpose: Configuration Write, Immediate Data, that waits for completion automatically
   task ebfm_cfgwr_imm_wait;
      input bus_num;
      integer bus_num;
      input dev_num;
      integer dev_num;
      input fnc_num;
      integer fnc_num;
      input regb_ad;
      integer regb_ad;
      input regb_ln;
      integer regb_ln;
      input[31:0] imm_data;
      output[2:0] compl_status;

      integer dum_hnd;

      begin
         ebfm_cfgwr(bus_num, dev_num, fnc_num, regb_ad, regb_ln, 0, 1'b1,
         imm_data, 1'b1, 1'b0, compl_status, dum_hnd);
      end
   endtask

   // purpose: Configuration Write, Immediate Data, no wait, no handle
   task ebfm_cfgwr_imm_nowt;
      input bus_num;
      integer bus_num;
      input dev_num;
      integer dev_num;
      input fnc_num;
      integer fnc_num;
      input regb_ad;
      integer regb_ad;
      input regb_ln;
      integer regb_ln;
      input[31:0] imm_data;

      reg[2:0] dum_sts;
      integer dum_hnd;

      begin
         ebfm_cfgwr(bus_num, dev_num, fnc_num, regb_ad, regb_ln, 0, 1'b1,
         imm_data, 1'b0, 1'b0, dum_sts, dum_hnd);
      end
   endtask

   function [9:0] calc_dw_len;
      input byte_adr;
      integer byte_adr;
      input byte_len;
      integer byte_len;

      integer adr_len;
      reg[9:0] dw_len;

      begin
         // calc_dw_len
         adr_len = byte_len + (byte_adr % 4);
         if (adr_len % 4 == 0)
         begin
            dw_len = (adr_len / 4);
         end
         else
         begin
            dw_len = ((adr_len / 4) + 1);
         end
         calc_dw_len = dw_len;
      end
   endfunction

   task ebfm_memwr;
      input[63:0] pcie_addr;
      input lcladdr;
      integer lcladdr;
      input byte_len;
      integer byte_len;
      input tclass;
      integer tclass;

      reg[192:0] info_v;
      integer baddr_v;

      begin
         info_v = {193{1'b0}} ;
         // ebfm_memwr
         baddr_v = pcie_addr[11:0] ;
         // Assemble the request
         info_v[159:128] = lcladdr ;
         if (pcie_addr[63:32] == 32'h00000000)
         begin
            info_v[127:120] = 8'h40; // 3DW Header w/Data MemWr
            info_v[63:34] = pcie_addr[31:2];
            info_v[31:0] = {32{1'b0}};
         end
         else
         begin
            info_v[127:120] = 8'h60; // 4DW Header w/Data MemWr
            info_v[63:2] = pcie_addr[63:2];
         end
         info_v[119] = 1'b0; // Reserved bit
         info_v[118:116] = tclass;
         info_v[115:112] = 4'h0; // Reserved bits all 0
         info_v[111:106] = 6'b000000; // TD, EP, Attr, RR all 0
         info_v[105:96] = calc_dw_len(baddr_v, byte_len);
         info_v[95:80] = RP_REQ_ID; // Requester ID
         info_v[79:72] = 8'h00;
         info_v[71:68] = ebfm_calc_lastbe(baddr_v, byte_len);
         info_v[67:64] = ebfm_calc_firstbe(baddr_v, byte_len);
         // Make the request
         req_intf_vc_req(info_v);
      end
   endtask

   task ebfm_memwr_imm;
      input[63:0] pcie_addr;
      input[31:0] imm_data;
      input byte_len;
      integer byte_len;
      input tclass;
      integer tclass;

      reg[192:0] info_v;
      integer baddr_v;

      begin
         info_v = {193{1'b0}} ;
         // ebfm_memwr_imm
         baddr_v = pcie_addr[11:0];
         // Assemble the request
         info_v[192] = 1'b1;
         info_v[191:160] = imm_data ;
         if (pcie_addr[63:32] == 32'h00000000)
         begin
            info_v[127:120] = 8'h40; // 3DW Header w/Data MemWr
            info_v[63:34] = pcie_addr[31:2];
            info_v[31:0] = {32{1'b0}};
         end
         else
         begin
            info_v[127:120] = 8'h60; // 4DW Header w/Data MemWr
            info_v[63:2] = pcie_addr[63:2];
         end
         info_v[119] = 1'b0; // Reserved bit
         info_v[118:116] = tclass ;
         info_v[115:112] = 4'h0; // Reserved bits all 0
         info_v[111:106] = 6'b000000; // TD, EP, Attr, RR all 0
         info_v[105:96] = calc_dw_len(baddr_v, byte_len);
         info_v[95:80] = RP_REQ_ID; // Requester ID
         info_v[79:72] = 8'h00 ;
         info_v[71:68] = ebfm_calc_lastbe(baddr_v, byte_len);
         info_v[67:64] = ebfm_calc_firstbe(baddr_v, byte_len);
         // Make the request
         req_intf_vc_req(info_v);
      end
   endtask

   // purpose: This is the full featured memory read that has all
   // optional behavior via the arguments
   task ebfm_memrd;
      input[63:0] pcie_addr;
      input lcladdr;
      integer lcladdr;
      input byte_len;
      integer byte_len;
      input tclass;
      integer tclass;
      input compl_wait;
      input need_handle;
      output[2:0] compl_status;
      output handle;
      integer handle;

      reg[192:0] info_v;
      integer tag_v;
      reg i_need_handle;
      integer baddr_v;

      begin
         info_v = {193{1'b0}} ;
         // Get a TAG
         i_need_handle = compl_wait | need_handle;
         req_intf_get_tag(tag_v, i_need_handle, lcladdr);
         baddr_v = pcie_addr[11:0];
         // Assemble the request
         info_v[159:128] = lcladdr ;
         if (pcie_addr[63:32] == 32'h00000000)
         begin
            info_v[127:120] = 8'h00; // 3DW Header w/o Data MemWr
            info_v[63:34] = pcie_addr[31:2];
            info_v[31:0] = {32{1'b0}};
         end
         else
         begin
            info_v[127:120] = 8'h20; // 4DW Header w/o Data MemWr
            info_v[63:2] = pcie_addr[63:2];
         end
         info_v[119] = 1'b0; // Reserved bit
         info_v[118:116] = tclass ;
         info_v[115:112] = 4'h0; // Reserved bits all 0
         info_v[111:106] = 6'b000000; // TD, EP, Attr, RR all 0
         info_v[105:96] = calc_dw_len(baddr_v, byte_len);
         info_v[95:80] = RP_REQ_ID; // Requester ID
         info_v[79:72] = tag_v ;
         info_v[71:68] = ebfm_calc_lastbe(baddr_v, byte_len);
         info_v[67:64] = ebfm_calc_firstbe(baddr_v, byte_len);
         // Make the request
         req_intf_vc_req(info_v);
         // Wait for completion if specified to do so
         if (compl_wait == 1'b1)
         begin
            req_intf_wait_compl(tag_v, compl_status, need_handle);
         end
         else
         begin
            compl_status = "UUU";
         end
         // Return the handle
         if (need_handle == 1'b0)
         begin
            handle = -1;
         end
         else
         begin
            handle = tag_v;
         end
      end
   endtask

   task ebfm_barwr;
      input bar_table;
      integer bar_table;
      input bar_num;
      integer bar_num;
      input pcie_offset;
      integer pcie_offset;
      input lcladdr;
      integer lcladdr;
      input byte_len;
      integer byte_len;
      input tclass;
      integer tclass;

      reg[63:0] cbar;
      integer rem_len;
      integer offset;
      integer cur_len;
      reg[63:0] paddr;

      reg dummy ;

      begin
         rem_len = byte_len ;
         offset = 0 ;
         cbar = shmem_read(bar_table + (bar_num * 4), 8);
         if (((cbar[0]) == 1'b1) | ((cbar[2]) == 1'b0))
         begin
            cbar[63:32] = {32{1'b0}};
         end
         paddr = ({cbar[63:4], 4'b0000}) + pcie_offset;
         while (rem_len > 0)
         begin
            if ((cbar[0]) == 1'b1)
            begin
               dummy = ebfm_display(EBFM_MSG_ERROR_FATAL, "Accessing I/O or Expansion ROM BAR is unsupported");
            end
            else
            begin
               cur_len = req_intf_max_payload_size(1'b0) - paddr[1:0];
               if (cur_len > rem_len)
               begin
                  cur_len = rem_len;
               end
               if (((paddr % 4096) + cur_len) > 4096)
               begin
                  cur_len = 4096 - (paddr % 4096);
               end
               ebfm_memwr( paddr, lcladdr + offset, cur_len, tclass);
            end
            offset = offset + cur_len;
            rem_len = rem_len - cur_len;
            paddr = paddr + cur_len;
         end
      end
   endtask

   task ebfm_barwr_imm;
      input bar_table;
      integer bar_table;
      input bar_num;
      integer bar_num;
      input pcie_offset;
      integer pcie_offset;
      input[31:0] imm_data;
      input byte_len;
      integer byte_len;
      input tclass;
      integer tclass;

      reg[63:0] cbar;

      reg dummy ;

      begin
         cbar = shmem_read(bar_table + (bar_num * 4), 8);
         if (((cbar[0]) == 1'b1) | ((cbar[2]) == 1'b0))
         begin
            cbar[63:32] = {32{1'b0}};
         end
         if ((cbar[0]) == 1'b1)
         begin
            dummy = ebfm_display(EBFM_MSG_ERROR_FATAL, "Accessing I/O or Expansion ROM BAR is unsupported");
         end
         else
         begin
            cbar[3:0] = 4'b0000;
            cbar = cbar + pcie_offset;
            ebfm_memwr_imm(cbar, imm_data, byte_len,
            tclass);
         end
      end
   endtask

   task ebfm_barrd;
      input bar_table;
      integer bar_table;
      input bar_num;
      integer bar_num;
      input pcie_offset;
      integer pcie_offset;
      input lcladdr;
      integer lcladdr;
      input byte_len;
      integer byte_len;
      input tclass;
      integer tclass;
      input compl_wait;
      input need_handle;
      output[2:0] compl_status;
      output handle;
      integer handle;

      reg[2:0] dum_status;
      integer dum_handle;
      reg[63:0] cbar;
      integer rem_len;
      integer offset;
      integer cur_len;
      reg[63:0] paddr;

      reg dummy ;

      begin
         rem_len = byte_len ;
         offset = 0 ;
         // ebfm_barrd
         cbar = shmem_read(bar_table + (bar_num * 4), 8);
         if (((cbar[0]) == 1'b1) | ((cbar[2]) == 1'b0))
         begin
            cbar[63:32] = {32{1'b0}};
         end
         paddr = ({cbar[63:4], 4'b0000}) + pcie_offset;
         while (rem_len > 0)
         begin
            if ((cbar[0]) == 1'b1)
            begin
               dummy = ebfm_display(EBFM_MSG_ERROR_FATAL, "Accessing I/O or Expansion ROM BAR is unsupported");
            end
            else
            begin
               // Need to make sure we don't cross a DW boundary
               cur_len = req_intf_rp_max_rd_req_size(1'b0) - paddr[1:0];
               if (cur_len > rem_len)
               begin
                  cur_len = rem_len;
               end
               if (((paddr % 4096) + cur_len) > 4096)
               begin
                  cur_len = 4096 - (paddr % 4096);
               end
               if (rem_len == cur_len)
               begin
                  // If it is the last one use the passed in compl/handle parms
                  ebfm_memrd(paddr, lcladdr + offset,
                             cur_len, tclass, compl_wait, need_handle, compl_status,
                             handle);
               end
               else
               begin
                  // Otherwise no wait, assume it all completes and the final one
                  // pushes ahead
                  ebfm_memrd(paddr, lcladdr + offset,
                             cur_len, tclass, 1'b0, 1'b0, dum_status, dum_handle);
               end
            end
            offset = offset + cur_len;
            rem_len = rem_len - cur_len;
            paddr = paddr + cur_len;
         end
      end
   endtask

   task ebfm_barrd_wait;
      input bar_table;
      integer bar_table;
      input bar_num;
      integer bar_num;
      input pcie_offset;
      integer pcie_offset;
      input lcladdr;
      integer lcladdr;
      input byte_len;
      integer byte_len;
      input tclass;
      integer tclass;

      reg[2:0] dum_status;
      integer dum_handle;

      begin
         // ebfm_barrd_wait
         ebfm_barrd(bar_table, bar_num, pcie_offset, lcladdr, byte_len,
         tclass, 1'b1, 1'b0, dum_status, dum_handle);
      end
   endtask

   task ebfm_barrd_nowt;
      input bar_table;
      integer bar_table;
      input bar_num;
      integer bar_num;
      input pcie_offset;
      integer pcie_offset;
      input lcladdr;
      integer lcladdr;
      input byte_len;
      integer byte_len;
      input tclass;
      integer tclass;

      reg[2:0] dum_status;
      integer dum_handle;

      begin
         // ebfm_barrd_nowt
         ebfm_barrd(bar_table, bar_num, pcie_offset, lcladdr, byte_len,
         tclass, 1'b0, 1'b0, dum_status, dum_handle);
      end
   endtask

   task rdwr_start_perf_sample;
   begin
        req_intf_start_perf_sample;
   end
   endtask

   task rdwr_disp_perf_sample;
   output tx_mbit_ps;
   integer tx_mbit_ps;
   output rx_mbit_ps;
   integer rx_mbit_ps;
   output bytes_transmitted;
   integer bytes_transmitted;
   begin
        req_intf_disp_perf_sample(tx_mbit_ps, rx_mbit_ps, bytes_transmitted);
   end
   endtask

// mk_inc altpcietb_bfm_configure.v
   //-----------------------------------------------------------------------------
   // Title         : PCI Express BFM Package of Configuration Routines
   // Project       : PCI Express MegaCore function
   //-----------------------------------------------------------------------------
   // File          : altpcietb_bfm_configure.v
   // Author        : Altera Corporation
   //-----------------------------------------------------------------------------
   // Description :
   // This package provides routines to setup the configuration spaces of the
   // Root Port and End Point sections of the testbench.
   //-----------------------------------------------------------------------------
   // Copyright © 2009 Altera Corporation. All rights reserved.  Altera products are
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

   // This is where the PCI Express Capability is for the MegaCore Function
   parameter PCIE_CAP_PTR = 128;

   task cfg_wr_bars;
      input bnm;
      integer bnm;
      input dev;
      integer dev;
      input fnc;
      integer fnc;
      input bar_base;
      integer bar_base;
      input typ1;

      integer maxbar;
      integer rombar;
      reg[2:0] compl_status;

      begin
         if (typ1 == 1'b1)
           begin
              maxbar = 5;
              rombar = 14;
           end
         else
           begin
              maxbar = 9;
              rombar = 12;
           end
         begin : xhdl_0
            integer i;
            for(i = 4; i <= maxbar; i = i + 1)
            begin
               ebfm_cfgwr_imm_nowt(bnm, dev, fnc, (i * 4), 4,
               shmem_read(bar_base + ((i - 4) * 4), 4));
            end
         end // i
         ebfm_cfgwr_imm_wait(bnm, dev, fnc, (rombar * 4), 4,
         shmem_read(bar_base + 24, 4), compl_status);
      end
   endtask

   task cfg_rd_bars;
      input bnm;
      integer bnm;
      input dev;
      integer dev;
      input fnc;
      integer fnc;
      input bar_base;
      integer bar_base;
      input typ1;

      integer maxbar;
      integer rombar;
      reg[2:0] compl_status;

      begin
         if (typ1 == 1'b1)
           begin
              maxbar = 5;
              rombar = 14;
           end
         else
           begin
              maxbar = 9;
              rombar = 12;
           end
         begin : xhdl_1
            integer i;
            for(i = 4; i <= maxbar; i = i + 1)
            begin
               ebfm_cfgrd_nowt(bnm, dev, fnc, (i * 4), 4, bar_base + ((i - 4) * 4));
            end
         end // i
         ebfm_cfgrd_wait(bnm, dev, fnc, (rombar * 4), 4, bar_base + 24, compl_status);
      end
   endtask

   // purpose: Configures the Address Window Registers in the Root Port
   task ebfm_cfg_rp_addr;
      // Prefetchable Base and Limits  must be supplied
      input[63:0] pci_pref_base;
      input[63:0] pci_pref_limit;
      // Non-Prefetchable Space Base and Limits are optional
      input[31:0] pci_nonp_base;
      input[31:0] pci_nonp_limit;
      // IO Space Base and Limits are optional
      input[31:0] pci_io_base;
      input[31:0] pci_io_limit;

      parameter bnm = RP_PRI_BUS_NUM;
      parameter dev = RP_PRI_DEV_NUM;

      begin  // ebfm_cfg_rp_addr
         // Configure the I/O Base and Limit Registers
         ebfm_cfgwr_imm_nowt(bnm, dev, 0, 28, 4,
                             {16'h0000,
                              pci_io_limit[15:12], 4'h0,
                              pci_io_base[15:12], 4'h0});
         // Configure the Non-Prefetchable Base & Limit Registers
         ebfm_cfgwr_imm_nowt(bnm, dev, 0, 32, 4,
                             {pci_nonp_limit[31:20], 4'h0,
                              pci_nonp_base[31:20], 4'h0});
         // Configure the Prefetchable Base & Limit Registers
         ebfm_cfgwr_imm_nowt(bnm, dev, 0, 36, 4,
                             {pci_pref_limit[31:20], 4'h0,
                              pci_pref_base[31:20], 4'h0});
         // Configure the Upper Prefetchable Base Register
         ebfm_cfgwr_imm_nowt(bnm, dev, 0, 40, 4,
                             pci_pref_base[63:32]);
         // Configure the Upper Prefetchable Limit Register
         ebfm_cfgwr_imm_nowt(bnm, dev, 0, 44, 4,
                             pci_pref_limit[63:32]);
         // Configure the Upper I/O Base and Limit Registers
         ebfm_cfgwr_imm_nowt(bnm, dev, 0, 48, 4,
                             {pci_io_limit[31:16],
                              pci_io_base[31:16]});

      end
   endtask

   task ebfm_cfg_rp_basic;
      // The Secondary Side Bus Number Defaults to 1 more than the Primary
      input sec_bnm_offset; // Secondary Side Bus Number
                            // Offset from Primary
      // The number of subordinate busses defaults to 1
      integer sec_bnm_offset; // Number of Subordinate Busses
      input num_sub_bus;
      integer num_sub_bus;

      reg[31:0] tmp_slv;
      parameter bnm = RP_PRI_BUS_NUM;
      parameter dev = RP_PRI_DEV_NUM;

      begin  // ebfm_cfg_rp_basic
         // Configure the command register
         ebfm_cfgwr_imm_nowt(bnm, dev, 0, 4, 4, 32'h00000006);
         // Configure the Bus number Registers
         // Primary BUS
         tmp_slv[7:0] = bnm ;
         // Secondary BUS (primary + offset)
         tmp_slv[15:8] = (bnm + sec_bnm_offset);
         // Maximum Subordinate BUS (primary + offset + num - 1)
         tmp_slv[23:16] = (bnm + sec_bnm_offset + num_sub_bus - 1);
         tmp_slv[31:24] = 8'h0;
         ebfm_cfgwr_imm_nowt(bnm, dev, 0, 24, 4, tmp_slv);

      end
   endtask

   task assign_bar;
      inout[63:0] bar;
      inout[63:0] amin; // amin = address minimum
      input[63:0] amax; // amax = address maximum

      reg[63:0] tbar;   // tbar = temporary bar
      reg[63:0] bsiz;   // bsiz = bar size

      begin
         tbar = {bar[63:4], 4'b0000};
         bsiz = (~tbar) + 1;
         // See if amin already on the boundary
         if ((amin & ~tbar) == 0)
         begin
            tbar = tbar & amin; // Lowest assignment
         end
         else
         begin
            // The lower bits were not 0, then we have to round up to the
            // next boundary
            tbar = (amin + bsiz) & tbar ;
         end
         if ((tbar + bsiz - 1) > amax)
         begin
            // We cant make the assignement
            bar[63:4] = {60{1'bx}};
         end
         else
         begin
            bar[63:4] = tbar[63:4];
            amin = tbar + bsiz;
         end
      end
   endtask

   task assign_bar_from_top;
      inout[63:0] bar;
      input[63:0] amin; // amin = address minimum
      inout[63:0] amax; // amax = address maximum

      reg[63:0] tbar;   // tbar = temporary bar
      reg[63:0] bsiz;   // bsiz = bar size

      begin
         bsiz = (~{bar[63:4], 4'b0000}) + 1;
         tbar = amax - bsiz + 1;  // Highest Assignment
         tbar = tbar & bar[63:0]; // Round Down
         if (tbar < amin)
         begin
            // We cant make the assignment
            bar[63:4] = {60{1'bx}};
         end
         else
         begin
            bar[63:4] = tbar[63:4];
            amax = tbar - 1;
         end
      end
   endtask

   // purpose: Describes the attributes of the BAR and the assigned address
   task describe_bar;
      input bar_num;
      integer bar_num;
      input bar_lsb;
      integer bar_lsb;
      input[63:0] bar;
      input       addr_unused ;

      reg[(6)*8:1] bar_num_str;
      reg[(10)*8:1] bar_size_str;
      reg[(16)*8:1] bar_type_str;
      reg bar_enabled;
      reg[(17)*8:1] addr_str;

      reg dummy ;

      begin  // describe_bar
         bar_enabled  = 1'b1 ;
         case (bar_lsb)
            4  : bar_size_str = " 16 Bytes ";
            5  : bar_size_str = " 32 Bytes ";
            6  : bar_size_str = " 64 Bytes ";
            7  : bar_size_str = "128 Bytes ";
            8  : bar_size_str = "256 Bytes ";
            9  : bar_size_str = "512 Bytes ";
            10 : bar_size_str = "  1 KBytes";
            11 : bar_size_str = "  2 KBytes";
            12 : bar_size_str = "  4 KBytes";
            13 : bar_size_str = "  8 KBytes";
            14 : bar_size_str = " 16 KBytes";
            15 : bar_size_str = " 32 KBytes";
            16 : bar_size_str = " 64 KBytes";
            17 : bar_size_str = "128 KBytes";
            18 : bar_size_str = "256 KBytes";
            19 : bar_size_str = "512 KBytes";
            20 : bar_size_str = "  1 MBytes";
            21 : bar_size_str = "  2 MBytes";
            22 : bar_size_str = "  4 MBytes";
            23 : bar_size_str = "  8 MBytes";
            24 : bar_size_str = " 16 MBytes";
            25 : bar_size_str = " 32 MBytes";
            26 : bar_size_str = " 64 MBytes";
            27 : bar_size_str = "128 MBytes";
            28 : bar_size_str = "256 MBytes";
            29 : bar_size_str = "512 MBytes";
            30 : bar_size_str = "  1 GBytes";
            31 : bar_size_str = "  2 GBytes";
            32 : bar_size_str = "  4 GBytes";
            33 : bar_size_str = "  8 GBytes";
            34 : bar_size_str = " 16 GBytes";
            35 : bar_size_str = " 32 GBytes";
            36 : bar_size_str = " 64 GBytes";
            37 : bar_size_str = "128 GBytes";
            38 : bar_size_str = "256 GBytes";
            39 : bar_size_str = "512 GBytes";
            40 : bar_size_str = "  1 TBytes";
            41 : bar_size_str = "  2 TBytes";
            42 : bar_size_str = "  4 TBytes";
            43 : bar_size_str = "  8 TBytes";
            44 : bar_size_str = " 16 TBytes";
            45 : bar_size_str = " 32 TBytes";
            46 : bar_size_str = " 64 TBytes";
            47 : bar_size_str = "128 TBytes";
            48 : bar_size_str = "256 TBytes";
            49 : bar_size_str = "512 TBytes";
            50 : bar_size_str = "  1 PBytes";
            51 : bar_size_str = "  2 PBytes";
            52 : bar_size_str = "  4 PBytes";
            53 : bar_size_str = "  8 PBytes";
            54 : bar_size_str = " 16 PBytes";
            55 : bar_size_str = " 32 PBytes";
            56 : bar_size_str = " 64 PBytes";
            57 : bar_size_str = "128 PBytes";
            58 : bar_size_str = "256 PBytes";
            59 : bar_size_str = "512 PBytes";
            60 : bar_size_str = "  1 EBytes";
            61 : bar_size_str = "  2 EBytes";
            62 : bar_size_str = "  4 EBytes";
            63 : bar_size_str = "  8 EBytes";
            default :
                     begin
                        bar_size_str = "Disabled  ";
                        bar_enabled = 0;
                     end
         endcase
         if (bar_num == 6)
         begin
            bar_num_str = "ExpROM";
         end
         else
         begin
            bar_num_str = {"BAR", dimage1(bar_num), "  "};
         end
         if (bar_enabled)
         begin
            if ((bar[2]) == 1'b1)
            begin
               bar_num_str = {"BAR", dimage1(bar_num+1), ":", dimage1(bar_num)};
            end
            if (addr_unused == 1'b1 )
              begin
                 addr_str = "Not used in RP   ";
              end
            else
              begin
                 if ( (bar[32] == 1'b0) | (bar[32] == 1'b1) )
                   begin
                      if ((bar[2]) == 1'b1)
                        begin
                           addr_str[136:73] = himage8(bar[63:32]);
                        end
                      else
                        begin
                           addr_str[136:73] = "        ";
                        end
                      addr_str[72:65] = " ";
                      addr_str[64:1] = himage8({bar[31:4], 4'b0000});
                   end
                 else
                   begin
                      addr_str = "Unassigned!!!    ";
                   end // else: !if( (bar[32] == 1'b0) | (bar[32] == 1'b1) )
              end // else: !if(addr_unused == 1'b1 )
            if ((bar[0]) == 1'b1)
              begin
                 bar_type_str = "IO Space        ";
              end
            else
            begin
               if ((bar[3]) == 1'b1)
               begin
                  bar_type_str = "Prefetchable    ";
               end
               else
               begin
                  bar_type_str = "Non-Prefetchable";
               end
            end
            dummy = ebfm_display(EBFM_MSG_INFO, {bar_num_str, " ", bar_size_str,
            " ", addr_str, " ", bar_type_str});
         end
         else
         begin
            dummy = ebfm_display(EBFM_MSG_INFO, {bar_num_str, " ", bar_size_str});
         end
      end
   endtask

   // purpose: configure a set of bars
   task ebfm_cfg_bars;
      input bnm;         // Bus Number
      integer bnm;
      input dev;         // Device Number
      integer dev;
      input fnc;         // Function Number
      integer fnc;
      input bar_table;   // Base Address in Shared Memory to
      integer bar_table; // store programmed value of BARs
      output bar_ok;
      inout[31:0] io_min;
      inout[31:0] io_max;
      inout[63:0] m32min;
      inout[63:0] m32max;
      inout[63:0] m64min;
      inout[63:0] m64max;
      input display;
      integer display;
      input addr_map_4GB_limit;

      reg[63:0] io_min_v;
      reg[63:0] io_max_v;
      reg[63:0] m32min_v;
      reg[63:0] m32max_v;
      reg[63:0] m64min_v;
      reg[63:0] m64max_v;
      reg typ1;
      reg[2:0] compl_status;
      integer nbar;
      reg[63:0] bars[0:6];
      integer sm_bar[0:6];
      integer bar_lsb[0:6];

      reg [7:0] htype ;

      reg dummy ;

      reg [63:0] bars_xhdl ;

      begin  // ebfm_cfg_bars
         io_min_v = {32'h00000000,io_min} ;
         io_max_v = {32'h00000000,io_max} ;
         m32min_v = m32min ;
         m32max_v = m32max ;
         m64min_v = m64min ;
         m64max_v = m64max ;
         sm_bar[0] = 0 ;
         sm_bar[1] = 1 ;
         sm_bar[2] = 2 ;
         sm_bar[3] = 3 ;
         sm_bar[4] = 4 ;
         sm_bar[5] = 5 ;
         sm_bar[6] = 6 ;

         bar_ok = 1'b1;
         shmem_fill(bar_table, SHMEM_FILL_ONE, 32, {64{1'b0}});
         // Clear the last bit of the ROMBAR which is the enable bit...
         shmem_write(bar_table + 24, 8'hFE, 1) ;
         // Read Header Type Field into last DWORD
         ebfm_cfgrd_wait(bnm, dev, fnc, 12, 4, bar_table + 28, compl_status);
         htype = shmem_read(bar_table + 30, 1) ;
         if (htype[6:0] == 7'b0000001)
         begin
            typ1 = 1'b1;
         end
         else
         begin
            typ1 = 1'b0;
         end
         cfg_wr_bars(bnm, dev, fnc, bar_table, typ1);
         shmem_fill(bar_table, SHMEM_FILL_ZERO, 28, {64{1'b0}});
         shmem_fill(bar_table + 32, SHMEM_FILL_ZERO, 32, {64{1'b0}});
         cfg_rd_bars(bnm, dev, fnc, bar_table + 32, typ1);
         // Load each BAR into the local BAR array
         // Find the Least Significant Writable bit in each BAR
         nbar = 0;
         while (nbar < 7)
           begin
              bars[nbar] = shmem_read((bar_table + 32 + (nbar * 4)), 8);
              bars_xhdl = bars[nbar];
              if ((bars_xhdl[2]) == 1'b0)
                begin
                   // 32 bit
                   if ((bars_xhdl[31]) == 1'b1)
                     begin
                        // if valid
                        bars_xhdl[63:32] = {32{1'b1}};
                     end
                   else
                     begin
                        // if not valid
                        bars_xhdl[63:32] = {32{1'b0}};
                     end
                end
              else
                begin
                   // 64-bit BAR, mark the next one invalid
                   bar_lsb[nbar + 1] = 64;
                end

              bars[nbar] = bars_xhdl ;
              if (bars_xhdl[63:4] == 0)
                begin
                   bar_lsb[nbar] = 64;
                end
              else
                begin
                   begin : xhdl_3
                      integer j;
                      for(j = 4; j <= 63; j = j + 1)
                        begin : lsb_loop
                           if ((bars_xhdl[j]) == 1'b1)
                             begin
                                bar_lsb[nbar] = j;
                                disable xhdl_3 ;
                             end
                        end
                   end // j
                end

              // Increment 1 for 32bit BARs or 2 for 64bit BARs.
              bars_xhdl = bars[nbar];
              if ((bars_xhdl[2]) == 1'b0)
                begin
                   nbar = nbar + 1;
                end
              else
                begin
                   nbar = nbar + 2;
                end
           end // i

         begin : xhdl_4
            integer i;
            for(i = 0; i <= 5; i = i + 1)
              begin
                 // Sort the BARs in order smallest to largest
                 begin : xhdl_5
                    integer j;
                    for(j = i + 1; j <= 6; j = j + 1)
                      begin
                         if (bar_lsb[sm_bar[j]] < bar_lsb[sm_bar[i]])
                           begin
                              nbar = sm_bar[i];
                              sm_bar[i] = sm_bar[j];
                              sm_bar[j] = nbar;
                           end
                      end
                 end // j
              end
         end // i

         // Fill all of the I/O BARs First, Smallest to Largest
         begin : xhdl_6
            integer i;
            for(i = 0; i <= 6; i = i + 1)
            begin
               if (bar_lsb[sm_bar[i]] < 64)
                 begin
                  bars_xhdl = bars[sm_bar[i]];
                    if ((bars_xhdl[0]) == 1'b1)
                      begin
                         assign_bar(bars[sm_bar[i]], io_min_v, io_max_v);
                      end
                 end
            end
         end // i
         // Now fill all of the 32-bit Non-Prefetchable BARs, Smallest to Largest
         begin : xhdl_7
            integer i;
            for(i = 0; i <= 6; i = i + 1)
              begin
                 if (bar_lsb[sm_bar[i]] < 64)
                   begin
                      bars_xhdl = bars[sm_bar[i]];
                      if (bars_xhdl[3:0] == 4'b0000)
                        begin
                           assign_bar(bars[sm_bar[i]], m32min_v, m32max_v);
                        end
                   end
              end
         end // i
         // Now fill all of the 32-bit Prefetchable BARs (and 64-bit Prefetchable BARs if addr_map_4GB_limit is set),
         // Largest to Smallest. From the top of memory.
         begin : xhdl_8
            integer i;
            for(i = 6; i >= 0; i = i - 1)
              begin
                 if (bar_lsb[sm_bar[i]] < 64)
                   begin
                      bars_xhdl = bars[sm_bar[i]];
                      if (bars_xhdl[3:0] == 4'b1000 ||
                         (addr_map_4GB_limit && bars_xhdl[3:0] == 4'b1100))
                        begin
                           assign_bar_from_top(bars[sm_bar[i]], m32min_v, m32max_v);
                        end
                   end
              end
         end // i
         // Now fill all of the 64-bit Prefetchable BARs, Smallest to Largest, if addr_map_4GB_limit is not set.
         if (addr_map_4GB_limit == 1'b0)
         begin : xhdl_9
            integer i;
            for(i = 0; i <= 6; i = i + 1)
            begin
               if (bar_lsb[sm_bar[i]] < 64)
                 begin
                    bars_xhdl = bars[sm_bar[i]];
                    if (bars_xhdl[3:0] == 4'b1100)
                      begin
                         assign_bar(bars[sm_bar[i]], m64min_v, m64max_v);
                      end
                 end
            end
         end // i
         // Now put all of the BARs back in memory
         nbar = 0;
         if (display == 1)
           begin
              dummy = ebfm_display(EBFM_MSG_INFO, "");
              dummy = ebfm_display(EBFM_MSG_INFO, "BAR Address Assignments:");
              dummy = ebfm_display(EBFM_MSG_INFO, {"BAR   ", " ", "Size      ", " ", "Assigned Address ", " ", "Type"});
              dummy = ebfm_display(EBFM_MSG_INFO, {"---   ", " ", "----      ", " ", "---------------- ", " "});
           end
         while (nbar < 7)
           begin
              if (display == 1)
                begin
                   // Show the user what we have done
                   describe_bar(nbar, bar_lsb[nbar], bars[nbar],1'b0) ;
                end
              bars_xhdl = bars[nbar];
              // Check and see if the BAR was unabled to be assigned!!
              if (bars_xhdl[32] === 1'bx)
                begin
                   bar_ok = 1'b0;
                   // Clean up the X's...
                   bars[nbar] = {{60{1'b0}},bars[nbar][3:0]} ;
                end
              bars_xhdl = bars[nbar];
              if ((bars_xhdl[2]) != 1'b1)
                begin
                   shmem_write(bar_table + (nbar * 4), bars_xhdl[31:0], 4);
                   nbar = nbar + 1;
                end
            else
              begin
                 shmem_write(bar_table + (nbar * 4), bars_xhdl[63:0], 8);
                 nbar = nbar + 2;
              end
           end
         // Temporarily turn on the lowest bit of the ExpROM BAR so it is enabled
         shmem_write(bar_table + 24, 8'h01, 1) ;
         cfg_wr_bars(bnm, dev, fnc, bar_table, typ1);
         // Turn off the lowest bit of the ExpROM BAR so rest of the BFM knows it is a memory BAR
         shmem_write(bar_table + 24, 8'h00, 1) ;
         if (display == 1)
           begin
              dummy = ebfm_display(EBFM_MSG_INFO, "");
           end
         m64max = m64max_v;
         m64min = m64min_v;
         m32max = m32max_v;
         m32min = m32min_v;
         io_max = io_max_v[31:0];
         io_min = io_min_v[31:0];
      end
   endtask

   task ebfm_display_link_status_reg;
      input root_port;
      input bnm;
      integer bnm;
      input dev;
      integer dev;
      input fnc;
      integer fnc;
      input CFG_SCRATCH_SPACE;
      integer CFG_SCRATCH_SPACE;

      reg[2:0] compl_status;
      reg[15:0] link_sts;
      reg[15:0] link_ctrl;
      reg[15:0] link_cap;

      reg dummy ;

      begin
         ebfm_cfgrd_wait(bnm, dev, fnc, PCIE_CAP_PTR + 16, 4, CFG_SCRATCH_SPACE, compl_status);
         link_sts  = shmem_read(CFG_SCRATCH_SPACE + 2, 2);
         link_ctrl = shmem_read(CFG_SCRATCH_SPACE,2);
         ebfm_cfgrd_wait(bnm, dev, fnc, PCIE_CAP_PTR + 12, 4, CFG_SCRATCH_SPACE, compl_status);
         link_cap = shmem_read(CFG_SCRATCH_SPACE ,2);
         if (root_port==1)
             dummy = ebfm_display(EBFM_MSG_INFO, {"  RP PCI Express Link Status Register (", himage4(link_sts), "):"});
         else
             dummy = ebfm_display(EBFM_MSG_INFO, {"  EP PCI Express Link Status Register (", himage4(link_sts), "):"});

         dummy = ebfm_display(EBFM_MSG_INFO, {"    Negotiated Link Width: x", dimage1(link_sts[9:4])}) ;

         if ((link_sts[12]) == 1'b1)
         begin
            dummy = ebfm_display(EBFM_MSG_INFO, "        Slot Clock Config: System Reference Clock Used");
        // Setting common clk cfg bit
        link_ctrl = 16'h0040 | link_ctrl;
        ebfm_cfgwr_imm_wait(bnm,dev,fnc,144,2, {16'h0000, link_ctrl}, compl_status);
       // retrain the link
       ebfm_cfgwr_imm_wait(RP_PRI_BUS_NUM,RP_PRI_DEV_NUM,fnc,144,2, 32'h0000_0060, compl_status);
         end
         else
         begin
            dummy = ebfm_display(EBFM_MSG_INFO, "        Slot Clock Config: Local Clock Used");
         end

         if (root_port==1) // dummy read to wait for link to come up
           ebfm_cfgrd_wait(1, 1, fnc, PCIE_CAP_PTR + 16, 4, CFG_SCRATCH_SPACE, compl_status);

         // check link speed
         ebfm_cfgrd_wait(bnm, dev, fnc, PCIE_CAP_PTR + 16, 4, CFG_SCRATCH_SPACE, compl_status);
         link_sts  = shmem_read(CFG_SCRATCH_SPACE + 2, 2);
         if (link_sts[3:0] == 4'h1)
           dummy = ebfm_display(EBFM_MSG_INFO, {"       Current Link Speed: 2.5GT/s"}) ;
         else if (link_sts[3:0] == 4'h2)
           dummy = ebfm_display(EBFM_MSG_INFO, {"       Current Link Speed: 5.0GT/s"}) ;
         else
           dummy = ebfm_display(EBFM_MSG_ERROR_FATAL, {"       Current Link Speed is Unsupported"}) ;

         if (link_sts[3:0] != link_cap[3:0]) // link is not at its full speed
       begin
       ebfm_cfgwr_imm_wait(RP_PRI_BUS_NUM,RP_PRI_DEV_NUM,fnc,144,2, 32'h0000_0020, compl_status);
           ebfm_cfgrd_wait(bnm, dev, fnc, PCIE_CAP_PTR + 16, 4, CFG_SCRATCH_SPACE, compl_status);

         if (root_port==1) // dummy read to wait for link to come up
           ebfm_cfgrd_wait(1, 1, fnc, PCIE_CAP_PTR + 16, 4, CFG_SCRATCH_SPACE, compl_status);
       // Make sure the config Rd is not sent before the retraining starts
           ebfm_cfgrd_wait(bnm, dev, fnc, PCIE_CAP_PTR + 16, 4, CFG_SCRATCH_SPACE, compl_status);
           link_sts  = shmem_read(CFG_SCRATCH_SPACE + 2, 2);
           if (link_sts[3:0] == 4'h1)
             dummy = ebfm_display(EBFM_MSG_INFO, {"           New Link Speed: 2.5GT/s"}) ;
           else if (link_sts[3:0] == 4'h2)
             dummy = ebfm_display(EBFM_MSG_INFO, {"           New Link Speed: 5.0GT/s"}) ;
       else
             dummy = ebfm_display(EBFM_MSG_ERROR_FATAL, {"       New Link Speed is Unsupported"}) ;

       end

         if (link_sts[3:0] != link_cap[3:0])
           dummy = ebfm_display(EBFM_MSG_INFO, "           Link fails to operate at Maximum Rate") ;




     dummy = ebfm_display(EBFM_MSG_INFO,"");


      end
   endtask

   task ebfm_display_link_control_reg;
      input root_port;
      input bnm;
      integer bnm;
      input dev;
      integer dev;
      input fnc;
      integer fnc;
      input CFG_SCRATCH_SPACE;
      integer CFG_SCRATCH_SPACE;
      reg[2:0] compl_status;
      reg[15:0] link_ctrl;
      reg dummy;
      begin
         ebfm_cfgrd_wait(bnm,dev,fnc,PCIE_CAP_PTR+16,4,CFG_SCRATCH_SPACE,compl_status);
     link_ctrl = shmem_read(CFG_SCRATCH_SPACE,2);
     if (root_port==1)
         dummy = ebfm_display(EBFM_MSG_INFO,{"  RP PCI Express Link Control Register (", himage4(link_ctrl), "):"} );
     else
         dummy = ebfm_display(EBFM_MSG_INFO,{"  EP PCI Express Link Control Register (", himage4(link_ctrl), "):"} );

     if (link_ctrl[6] == 1'b1)
     begin
        dummy = ebfm_display(EBFM_MSG_INFO,"      Common Clock Config: System Reference Clock Used") ;
     end
     else
     begin
        dummy = ebfm_display(EBFM_MSG_INFO,"      Common Clock Config: Local Clock Used") ;
     end
     dummy = ebfm_display(EBFM_MSG_INFO,"");
      end
   endtask

   task ebfm_display_dev_control_status_reg;
      input root_port;
      input bnm;
      integer bnm;
      input dev;
      integer dev;
      input fnc;
      integer fnc;
      input CFG_SCRATCH_SPACE;
      integer CFG_SCRATCH_SPACE;

      reg[2:0] compl_status;
      reg[31:0] dev_cs;

      reg dummy ;

      begin
         ebfm_cfgrd_wait(bnm, dev, fnc, PCIE_CAP_PTR + 8, 4,
         CFG_SCRATCH_SPACE, compl_status);
         dev_cs = shmem_read(CFG_SCRATCH_SPACE, 4);
         dummy = ebfm_display(EBFM_MSG_INFO, "");
         if (root_port==1)
             dummy = ebfm_display(EBFM_MSG_INFO, {"  RP PCI Express Device Control Register (",
                                                  himage4(dev_cs[15:0]), "):"});
         else
             dummy = ebfm_display(EBFM_MSG_INFO, {"  EP PCI Express Device Control Register (",
                                                  himage4(dev_cs[15:0]), "):"});

         dummy = ebfm_display(EBFM_MSG_INFO, {"  Error Reporting Enables: ",
                                              himage1(dev_cs[3:0])});
         if ((dev_cs[4]) == 1'b1)
         begin
            dummy = ebfm_display(EBFM_MSG_INFO, "         Relaxed Ordering: Enabled");
         end
         else
         begin
            dummy = ebfm_display(EBFM_MSG_INFO, "         Relaxed Ordering: Disabled");
         end
         case (dev_cs[7:5])
            3'b000 : dummy = ebfm_display(EBFM_MSG_INFO, "              Max Payload: 128 Bytes");
            3'b001 : dummy = ebfm_display(EBFM_MSG_INFO, "              Max Payload: 256 Bytes");
            3'b010 : dummy = ebfm_display(EBFM_MSG_INFO, "              Max Payload: 512 Bytes");
            3'b011 : dummy = ebfm_display(EBFM_MSG_INFO, "              Max Payload: 1KBytes");
            3'b100 : dummy = ebfm_display(EBFM_MSG_INFO, "              Max Payload: 2KBytes");
            3'b101 : dummy = ebfm_display(EBFM_MSG_INFO, "              Max Payload: 4KBytes");
            default :
                     begin
                        dummy = ebfm_display(EBFM_MSG_INFO,
                                             {"              Max Payload: Unknown",
                                              himage1(dev_cs[2:0])});
                     end
         endcase
         if ((dev_cs[8]) == 1'b1)
         begin
            dummy = ebfm_display(EBFM_MSG_INFO, "             Extended Tag: Enabled");
         end
         else
         begin
            dummy = ebfm_display(EBFM_MSG_INFO, "             Extended Tag: Disabled");
         end
         case (dev_cs[14:12])
            3'b000 : dummy = ebfm_display(EBFM_MSG_INFO, "         Max Read Request: 128 Bytes");
            3'b001 : dummy = ebfm_display(EBFM_MSG_INFO, "         Max Read Request: 256 Bytes");
            3'b010 : dummy = ebfm_display(EBFM_MSG_INFO, "         Max Read Request: 512 Bytes");
            3'b011 : dummy = ebfm_display(EBFM_MSG_INFO, "         Max Read Request: 1KBytes");
            3'b100 : dummy = ebfm_display(EBFM_MSG_INFO, "         Max Read Request: 2KBytes");
            3'b101 : dummy = ebfm_display(EBFM_MSG_INFO, "         Max Read Request: 4KBytes");
            default :
                     begin
                        dummy = ebfm_display(EBFM_MSG_INFO, {"         Max Read Request: Unknown",
                                                             himage1(dev_cs[2:0])});
                     end
         endcase
         dummy = ebfm_display(EBFM_MSG_INFO, "");
         if (root_port==1)
             dummy = ebfm_display(EBFM_MSG_INFO, {"  RP PCI Express Device Status Register (",
                                                  himage4(dev_cs[31:16]), "):"});
         else
             dummy = ebfm_display(EBFM_MSG_INFO, {"  EP PCI Express Device Status Register (",
                                                  himage4(dev_cs[31:16]), "):"});
         dummy = ebfm_display(EBFM_MSG_INFO, "");
      end
   endtask

   // purpose: display PCI Express Capability Info
   task display_pcie_cap;
      input       root_port;
      input[31:0] pcie_cap;
      input[31:0] dev_cap;
      input[31:0] link_cap;
      input[31:0] dev_cap2;

      integer pwr_limit;
      reg l;

      reg dummy ;




      begin
         // display_pcie_cap
         dummy = ebfm_display(EBFM_MSG_INFO, "");
         if (root_port==1)
             dummy = ebfm_display(EBFM_MSG_INFO, {"  RP PCI Express Capabilities Register (",
                                                  himage4(pcie_cap[31:16]), "):"});
         else
             dummy = ebfm_display(EBFM_MSG_INFO, {"  EP PCI Express Capabilities Register (",
                                                  himage4(pcie_cap[31:16]), "):"});

         dummy = ebfm_display(EBFM_MSG_INFO, {"       Capability Version: ",
                                              himage1(pcie_cap[19:16])});
         case (pcie_cap[23:20])
            4'b0000 : dummy = ebfm_display(EBFM_MSG_INFO, "                Port Type: Native Endpoint");
            4'b0001 : dummy = ebfm_display(EBFM_MSG_INFO, "                Port Type: Legacy Endpoint");
            4'b0100 : dummy = ebfm_display(EBFM_MSG_INFO, "                Port Type: Root Port");
            4'b0101 : dummy = ebfm_display(EBFM_MSG_INFO, "                Port Type: Switch Upstream port");
            4'b0110 : dummy = ebfm_display(EBFM_MSG_INFO, "                Port Type: Switch Downstream port");
            4'b0111 : dummy = ebfm_display(EBFM_MSG_INFO, "                Port Type: Express-to-PCI bridge");
            4'b1000 : dummy = ebfm_display(EBFM_MSG_INFO, "                Port Type: PCI-to-Express bridge");
            default : dummy = ebfm_display(EBFM_MSG_INFO, {"                Port Type: UNKNOWN", himage1(pcie_cap[23:20])});
         endcase
         dummy = ebfm_display(EBFM_MSG_INFO, "");
         if (root_port==1)
             dummy = ebfm_display(EBFM_MSG_INFO, {"  RP PCI Express Device Capabilities Register (",
                                                  himage8(dev_cap), "):"});
         else
             dummy = ebfm_display(EBFM_MSG_INFO, {"  EP PCI Express Device Capabilities Register (",
                                                  himage8(dev_cap), "):"});

         case (dev_cap[2:0])
            3'b000 : dummy = ebfm_display(EBFM_MSG_INFO, "    Max Payload Supported: 128 Bytes");
            3'b001 : dummy = ebfm_display(EBFM_MSG_INFO, "    Max Payload Supported: 256 Bytes");
            3'b010 : dummy = ebfm_display(EBFM_MSG_INFO, "    Max Payload Supported: 512 Bytes");
            3'b011 : dummy = ebfm_display(EBFM_MSG_INFO, "    Max Payload Supported: 1KBytes");
            3'b100 : dummy = ebfm_display(EBFM_MSG_INFO, "    Max Payload Supported: 2KBytes");
            3'b101 : dummy = ebfm_display(EBFM_MSG_INFO, "    Max Payload Supported: 4KBytes");
            default : dummy = ebfm_display(EBFM_MSG_INFO, {"    Max Payload Supported: Unknown", himage1(dev_cap[2:0])});
         endcase
         if ((dev_cap[5]) == 1'b1)
         begin
            dummy = ebfm_display(EBFM_MSG_INFO, "             Extended Tag: Supported");
         end
         else
         begin
            dummy = ebfm_display(EBFM_MSG_INFO, "             Extended Tag: Not Supported");
         end
         case (dev_cap[8:6])
            3'b000 : dummy = ebfm_display(EBFM_MSG_INFO, "   Acceptable L0s Latency: Less Than 64 ns");
            3'b001 : dummy = ebfm_display(EBFM_MSG_INFO, "   Acceptable L0s Latency: 64 ns to 128 ns");
            3'b010 : dummy = ebfm_display(EBFM_MSG_INFO, "   Acceptable L0s Latency: 128 ns to 256 ns");
            3'b011 : dummy = ebfm_display(EBFM_MSG_INFO, "   Acceptable L0s Latency: 256 ns to 512 ns");
            3'b100 : dummy = ebfm_display(EBFM_MSG_INFO, "   Acceptable L0s Latency: 512 ns to 1 us");
            3'b101 : dummy = ebfm_display(EBFM_MSG_INFO, "   Acceptable L0s Latency: 1 us to 2 us");
            3'b110 : dummy = ebfm_display(EBFM_MSG_INFO, "   Acceptable L0s Latency: 2 us to 4 us");
            3'b111 : dummy = ebfm_display(EBFM_MSG_INFO, "   Acceptable L0s Latency: More than 4 us");
            default :
                     begin
                     end
         endcase
         case (dev_cap[11:9])
            3'b000 : dummy = ebfm_display(EBFM_MSG_INFO, "   Acceptable L1  Latency: Less Than 1 us");
            3'b001 : dummy = ebfm_display(EBFM_MSG_INFO, "   Acceptable L1  Latency: 1 us to 2 us");
            3'b010 : dummy = ebfm_display(EBFM_MSG_INFO, "   Acceptable L1  Latency: 2 us to 4 us");
            3'b011 : dummy = ebfm_display(EBFM_MSG_INFO, "   Acceptable L1  Latency: 4 us to 8 us");
            3'b100 : dummy = ebfm_display(EBFM_MSG_INFO, "   Acceptable L1  Latency: 8 us to 16 us");
            3'b101 : dummy = ebfm_display(EBFM_MSG_INFO, "   Acceptable L1  Latency: 16 us to 32 us");
            3'b110 : dummy = ebfm_display(EBFM_MSG_INFO, "   Acceptable L1  Latency: 32 us to 64 us");
            3'b111 : dummy = ebfm_display(EBFM_MSG_INFO, "   Acceptable L1  Latency: More than 64 us");
            default :
                     begin
                     end
         endcase
         if ((dev_cap[12]) == 1'b1)
         begin
            dummy = ebfm_display(EBFM_MSG_INFO, "         Attention Button: Present");
         end
         else
         begin
            dummy = ebfm_display(EBFM_MSG_INFO, "         Attention Button: Not Present");
         end
         if ((dev_cap[13]) == 1'b1)
         begin
            dummy = ebfm_display(EBFM_MSG_INFO, "      Attention Indicator: Present");
         end
         else
         begin
            dummy = ebfm_display(EBFM_MSG_INFO, "      Attention Indicator: Not Present");
         end
         if ((dev_cap[14]) == 1'b1)
         begin
            dummy = ebfm_display(EBFM_MSG_INFO, "          Power Indicator: Present");
         end
         else
         begin
            dummy = ebfm_display(EBFM_MSG_INFO, "          Power Indicator: Not Present");
         end
         dummy = ebfm_display(EBFM_MSG_INFO, "");

         if (root_port==1)
             dummy = ebfm_display(EBFM_MSG_INFO, {"  RP PCI Express Link Capabilities Register (",
                                                  himage8(link_cap), "):"});
         else
             dummy = ebfm_display(EBFM_MSG_INFO, {"  EP PCI Express Link Capabilities Register (",
                                                  himage8(link_cap), "):"});

         dummy = ebfm_display(EBFM_MSG_INFO, {"       Maximum Link Width: x",
                                              dimage1(link_cap[9:4])}) ;

         if (link_cap[3:0] == 4'h1)
           dummy = ebfm_display(EBFM_MSG_INFO, {"     Supported Link Speed: 2.5GT/s"}) ;
         else if (link_cap[3:0] == 4'h2)
           dummy = ebfm_display(EBFM_MSG_INFO, {"     Supported Link Speed: 5.0GT/s or 2.5GT/s"}) ;
         else
           dummy = ebfm_display(EBFM_MSG_ERROR_FATAL, {"     Supported Link Speed: Undefined"}) ;

         if ((link_cap[10]) == 1'b1)
         begin
            dummy = ebfm_display(EBFM_MSG_INFO, "                L0s Entry: Supported");
         end
         else
         begin
            dummy = ebfm_display(EBFM_MSG_INFO, "                L0s Entry: Not Supported");
         end
         if ((link_cap[11]) == 1'b1)
         begin
            dummy = ebfm_display(EBFM_MSG_INFO, "                L1  Entry: Supported");
         end
         else
         begin
            dummy = ebfm_display(EBFM_MSG_INFO, "                L1  Entry: Not Supported");
         end
         case (link_cap[14:12])
            3'b000 : dummy = ebfm_display(EBFM_MSG_INFO, "         L0s Exit Latency: Less Than 64 ns");
            3'b001 : dummy = ebfm_display(EBFM_MSG_INFO, "         L0s Exit Latency: 64 ns to 128 ns");
            3'b010 : dummy = ebfm_display(EBFM_MSG_INFO, "         L0s Exit Latency: 128 ns to 256 ns");
            3'b011 : dummy = ebfm_display(EBFM_MSG_INFO, "         L0s Exit Latency: 256 ns to 512 ns");
            3'b100 : dummy = ebfm_display(EBFM_MSG_INFO, "         L0s Exit Latency: 512 ns to 1 us");
            3'b101 : dummy = ebfm_display(EBFM_MSG_INFO, "         L0s Exit Latency: 1 us to 2 us");
            3'b110 : dummy = ebfm_display(EBFM_MSG_INFO, "         L0s Exit Latency: 2 us to 4 us");
            3'b111 : dummy = ebfm_display(EBFM_MSG_INFO, "         L0s Exit Latency: More than 4 us");
            default :
                     begin
                     end
         endcase
         case (link_cap[17:15])
            3'b000 : dummy = ebfm_display(EBFM_MSG_INFO, "         L1  Exit Latency: Less Than 1 us");
            3'b001 : dummy = ebfm_display(EBFM_MSG_INFO, "         L1  Exit Latency: 1 us to 2 us");
            3'b010 : dummy = ebfm_display(EBFM_MSG_INFO, "         L1  Exit Latency: 2 us to 4 us");
            3'b011 : dummy = ebfm_display(EBFM_MSG_INFO, "         L1  Exit Latency: 4 us to 8 us");
            3'b100 : dummy = ebfm_display(EBFM_MSG_INFO, "         L1  Exit Latency: 8 us to 16 us");
            3'b101 : dummy = ebfm_display(EBFM_MSG_INFO, "         L1  Exit Latency: 16 us to 32 us");
            3'b110 : dummy = ebfm_display(EBFM_MSG_INFO, "         L1  Exit Latency: 32 us to 64 us");
            3'b111 : dummy = ebfm_display(EBFM_MSG_INFO, "         L1  Exit Latency: More than 64 us");
            default :
                     begin
                     end
         endcase
         dummy = ebfm_display(EBFM_MSG_INFO, {"              Port Number: ", himage2(link_cap[31:24])});


       if (link_cap[19] == 1'b1)
             dummy = ebfm_display(EBFM_MSG_INFO, "  Surprise Dwn Err Report: Supported");
       else
             dummy = ebfm_display(EBFM_MSG_INFO, "  Surprise Dwn Err Report: Not Supported");

       if (link_cap[20] == 1'b1)
             dummy = ebfm_display(EBFM_MSG_INFO, "   DLL Link Active Report: Supported");
       else
             dummy = ebfm_display(EBFM_MSG_INFO, "   DLL Link Active Report: Not Supported");


           dummy = ebfm_display(EBFM_MSG_INFO, "");


         // Spec 2.0 Caps
         if (pcie_cap[19:16] == 4'h2)
       begin

       if (root_port==1)
           dummy = ebfm_display(EBFM_MSG_INFO, {"  RP PCI Express Device Capabilities 2 Register (",
                            himage8(dev_cap2), "):"});
       else
           dummy = ebfm_display(EBFM_MSG_INFO, {"  EP PCI Express Device Capabilities 2 Register (",
                            himage8(dev_cap2), "):"});

       if (dev_cap2[4] == 1'b1)
         case (dev_cap2[3:0])
         4'h0: dummy = ebfm_display(EBFM_MSG_INFO, "  Completion Timeout Rnge: Not Supported");
         4'h1: dummy = ebfm_display(EBFM_MSG_INFO, "  Completion Timeout Rnge: A (50us to 10ms)");
         4'h2: dummy = ebfm_display(EBFM_MSG_INFO, "  Completion Timeout Rnge: B (10ms to 250ms)");
         4'h3: dummy = ebfm_display(EBFM_MSG_INFO, "  Completion Timeout Rnge: AB (50us to 250ms)");
         4'h6: dummy = ebfm_display(EBFM_MSG_INFO, "  Completion Timeout Rnge: BC (10ms to 4s)");
         4'h7: dummy = ebfm_display(EBFM_MSG_INFO, "  Completion Timeout Rnge: ABC (50us to 4s)");
         4'hE: dummy = ebfm_display(EBFM_MSG_INFO, "  Completion Timeout Rnge: BCD (10ms to 64s)");
         4'hF: dummy = ebfm_display(EBFM_MSG_INFO, "  Completion Timeout Rnge: ABCD (50us to 64s)");
         default: dummy = ebfm_display(EBFM_MSG_INFO, "  Completion Timeout Rnge: Reserved");
         endcase
       else
         dummy = ebfm_display(EBFM_MSG_INFO, "  Completion Timeout Rnge: Not Supported");

       end






      end
   endtask



   // purpose: configure the PCI Express Capabilities
   task ebfm_cfg_pcie_cap;
      input bnm;
      integer bnm;
      input dev;
      integer dev;
      input fnc;
      integer fnc;
      input CFG_SCRATCH_SPACE;
      integer CFG_SCRATCH_SPACE;
      input rp_max_rd_req_size;
      integer rp_max_rd_req_size;
      input display;
      integer display;
      input display_rp_config;
      integer display_rp_config;


      reg[2:0] compl_status;
      integer EP_PCIE_CAP ;
      integer EP_DEV_CAP ;
      integer EP_DEV_CAP2 ;
      integer EP_DEV_CTRL2 ;
      integer EP_LINK_CTRL2 ;
      integer EP_LINK_CAP ;
      integer RP_PCIE_CAP ;
      integer RP_DEV_CAP ;
      integer RP_DEV_CS;
      integer RP_LINK_CTRL;
      integer RP_DEV_CAP2;
      integer RP_LINK_CAP;
      reg[31:0] ep_pcie_cap_r;
      reg[31:0] rp_pcie_cap_r;
      reg[31:0] ep_dev_cap_r;
      reg[31:0] rp_dev_cap_r;
      reg[15:0] ep_dev_control;
      reg[15:0] rp_dev_control;
      reg[15:0] rp_dev_cs;
      integer max_size;

      reg dummy ;

      begin // ebfm_cfg_pcie_cap
         ep_dev_control = {16{1'b0}} ;
         rp_dev_control = {16{1'b0}} ;
         EP_PCIE_CAP = CFG_SCRATCH_SPACE + 0;
         EP_DEV_CAP  = CFG_SCRATCH_SPACE + 4;
         EP_LINK_CAP = CFG_SCRATCH_SPACE + 8;
         RP_PCIE_CAP = CFG_SCRATCH_SPACE + 16;
         RP_DEV_CAP  = CFG_SCRATCH_SPACE + 20;
         EP_DEV_CAP2  = CFG_SCRATCH_SPACE + 24;
         RP_DEV_CS   = CFG_SCRATCH_SPACE + 36;
         RP_LINK_CTRL = CFG_SCRATCH_SPACE + 40;
         RP_DEV_CAP2  = CFG_SCRATCH_SPACE + 44;
         RP_LINK_CAP  = CFG_SCRATCH_SPACE + 48;
         // Read the EP PCI Express Capabilities (at a known address in the MegaCore
         // function)
         if (display == 1)
         begin
            ebfm_display_link_status_reg(0, bnm,dev,fnc,CFG_SCRATCH_SPACE+32);
            ebfm_display_link_control_reg(0, bnm,dev,fnc,CFG_SCRATCH_SPACE+32);
         end
         if (display_rp_config==1) begin
            ebfm_display_link_status_reg(1, RP_PRI_BUS_NUM, RP_PRI_DEV_NUM, 0, RP_LINK_CTRL);
            ebfm_display_link_control_reg(1, RP_PRI_BUS_NUM, RP_PRI_DEV_NUM, 0, RP_LINK_CTRL);
         end



         ebfm_cfgrd_nowt(bnm, dev, fnc, PCIE_CAP_PTR, 4, EP_PCIE_CAP);
         ebfm_cfgrd_nowt(bnm, dev, fnc, PCIE_CAP_PTR + 4, 4, EP_DEV_CAP);
         ebfm_cfgrd_nowt(bnm, dev, fnc, PCIE_CAP_PTR + 36, 4, EP_DEV_CAP2);
         ebfm_cfgrd_wait(bnm, dev, fnc, PCIE_CAP_PTR + 12, 4, EP_LINK_CAP, compl_status);
         ebfm_cfgrd_nowt(RP_PRI_BUS_NUM, RP_PRI_DEV_NUM, 0, 128, 4, RP_PCIE_CAP);
       //  ebfm_cfgrd_nowt(RP_PRI_BUS_NUM, RP_PRI_DEV_NUM, 0, 128, 4, RP_DEV_CS);
         ebfm_cfgrd_nowt(RP_PRI_BUS_NUM, RP_PRI_DEV_NUM, 0, 128 + 36, 4, RP_DEV_CAP2);
         ebfm_cfgrd_nowt(RP_PRI_BUS_NUM, RP_PRI_DEV_NUM, 0, 128 + 12, 4, RP_LINK_CAP);
         ebfm_cfgrd_wait(RP_PRI_BUS_NUM, RP_PRI_DEV_NUM, 0, 132 , 4, RP_DEV_CAP, compl_status);
         ep_pcie_cap_r = shmem_read(EP_PCIE_CAP, 4);
         rp_pcie_cap_r = shmem_read(RP_PCIE_CAP, 4);
         ep_dev_cap_r = shmem_read(EP_DEV_CAP, 4);
         rp_dev_cap_r = shmem_read(RP_DEV_CAP, 4);
         if (ep_pcie_cap_r[7:0] != 8'h10)
         begin
            dummy = ebfm_display(EBFM_MSG_ERROR_FATAL, "PCI Express Capabilities not at expected Endpoint config address");
         end
         if (rp_pcie_cap_r[7:0] != 8'h10)
         begin
            dummy = ebfm_display(EBFM_MSG_ERROR_FATAL_TB_ERR, "PCI Express Capabilities not at expected Root Port config address");
         end
         if (display == 1)
         begin
            display_pcie_cap(
                 0,
                 ep_pcie_cap_r,
                 ep_dev_cap_r,
                 shmem_read(EP_LINK_CAP, 4),
                 shmem_read(EP_DEV_CAP2, 4)
                 );
          end
          if (display_rp_config==1) begin
                display_pcie_cap(
                     1,
                     rp_pcie_cap_r,
                     rp_dev_cap_r,
                     shmem_read(RP_LINK_CAP, 4),
                     shmem_read(RP_DEV_CAP2, 4)
                 );
          end


         // Error Reporting Enables (RP BFM does not handle for now)
         ep_dev_control[3:0] = {4{1'b0}};
         rp_dev_control[3:0] = {4{1'b0}};
         // Enable Relaxed Ordering
         ep_dev_control[4] = 1'b1;
         rp_dev_control[4] = 1'b1;
         // Enable Extended Tag if requested for EP
         ep_dev_control[8] = ep_dev_cap_r[5];
         if (EBFM_NUM_TAG > 32)
         begin
            rp_dev_control[8] = 1'b1;
         end
         else
         begin
            rp_dev_control[8] = 1'b0;
         end
         // Disable Phantom Functions
         ep_dev_control[9] = 1'b0;
         rp_dev_control[9] = 1'b0;
         // Disable Aux Power PM Enable
         ep_dev_control[10] = 1'b0;
         rp_dev_control[10] = 1'b0;
         // Disable No Snoop
         ep_dev_control[11] = 1'b0;
         rp_dev_control[11] = 1'b0;
         if (ep_dev_cap_r[2:0] < rp_dev_cap_r[2:0])
         begin
            // Max Payload Size
            ep_dev_control[7:5] = ep_dev_cap_r[2:0];
            rp_dev_control[7:5] = ep_dev_cap_r[2:0];
            // Max Read Request Size
            // Note the reference design can break up the read requests into smaller
            // completion packets, so we can go for the full 4096 bytes. But the
            // root port BFM can't create multiple completions, so tell the endpoint
            // to be restricted to the max payload size
            ep_dev_control[14:12] = ep_dev_cap_r[2:0];
            rp_dev_control[14:12] = 3'b101;
         end
         else
         begin
            // Max Payload Size
            ep_dev_control[7:5] = rp_dev_cap_r[2:0];
            rp_dev_control[7:5] = rp_dev_cap_r[2:0];
            // Max Read Request Size
            // Note the reference design can break up the read requests into smaller
            // completion packets, so we can go for the full 4096 bytes. But the
            // root port BFM can't create multiple completions, so tell the endpoint
            // to be restricted to the max payload size
            ep_dev_control[14:12] = rp_dev_cap_r[2:0];
            rp_dev_control[14:12] = 3'b101;
         end
         case (ep_dev_control[7:5])
            3'b000 : max_size = 128;
            3'b001 : max_size = 256;
            3'b010 : max_size = 512;
            3'b011 : max_size = 1024;
            3'b100 : max_size = 2048;
            3'b101 : max_size = 4096;
            default : max_size = 128;
         endcase
         // Tell the BFM what the limits are...
         req_intf_set_max_payload(max_size, max_size, rp_max_rd_req_size);
         ebfm_cfgwr_imm_nowt(bnm, dev, fnc, PCIE_CAP_PTR + 8, 4, {16'h0000, ep_dev_control});
         ebfm_cfgwr_imm_nowt(RP_PRI_BUS_NUM, RP_PRI_DEV_NUM, 0, PCIE_CAP_PTR + 8, 4, {16'h0000, rp_dev_control});

         if (display == 1)
         begin
             ebfm_display_dev_control_status_reg(0, bnm, dev, fnc, CFG_SCRATCH_SPACE + 32);
             ebfm_display_vc(0, bnm,dev,fnc,CFG_SCRATCH_SPACE + 32) ;
         end
         if (display_rp_config==1) begin
             ebfm_display_dev_control_status_reg(1, RP_PRI_BUS_NUM, RP_PRI_DEV_NUM, 0, RP_LINK_CTRL);
             ebfm_display_vc(1, RP_PRI_BUS_NUM, RP_PRI_DEV_NUM, 0, RP_LINK_CTRL) ;
         end

      end
   endtask

   // purpose: Display the "critical" BARs
   task ebfm_display_read_only;
      input root_port;
      input bnm;
      integer bnm;
      input dev;
      integer dev;
      input fnc;
      integer fnc;
      input CFG_SCRATCH_SPACE;
      integer CFG_SCRATCH_SPACE;

      reg[2:0] compl_status;

      reg dummy ;

      begin



         // ebfm_display_read_only
         ebfm_cfgrd_nowt(bnm, dev, fnc, 0, 4, CFG_SCRATCH_SPACE);
         ebfm_cfgrd_nowt(bnm, dev, fnc, 8, 4, CFG_SCRATCH_SPACE + 8);
         ebfm_cfgrd_nowt(bnm, dev, fnc, 44, 4, CFG_SCRATCH_SPACE + 4);
         ebfm_cfgrd_nowt(bnm, dev, fnc, 60, 4, CFG_SCRATCH_SPACE + 16);
         ebfm_cfgrd_wait(bnm, dev, fnc, 12, 4, CFG_SCRATCH_SPACE + 12, compl_status);
         dummy = ebfm_display(EBFM_MSG_INFO, "");
         dummy = ebfm_display(EBFM_MSG_INFO, {"Configuring Bus ", dimage3(bnm),
                                              ", Device ", dimage3(dev),
                                              ", Function ", dimage2(fnc)});

         if (root_port==1)
             dummy = ebfm_display(EBFM_MSG_INFO, "  RP Read Only Configuration Registers:");
         else
             dummy = ebfm_display(EBFM_MSG_INFO, "  EP Read Only Configuration Registers:");

         dummy = ebfm_display(EBFM_MSG_INFO, {"                Vendor ID: ",
         himage4(shmem_read(CFG_SCRATCH_SPACE, 2))});
         dummy = ebfm_display(EBFM_MSG_INFO, {"                Device ID: ",
         himage4(shmem_read(CFG_SCRATCH_SPACE + 2, 2))});
         dummy = ebfm_display(EBFM_MSG_INFO, {"              Revision ID: ",
         himage2(shmem_read(CFG_SCRATCH_SPACE + 8, 1))});
         dummy = ebfm_display(EBFM_MSG_INFO, {"               Class Code: ",
                                              himage2(shmem_read(CFG_SCRATCH_SPACE + 11, 1)),
                                              himage4(shmem_read(CFG_SCRATCH_SPACE + 9, 2))});
         if (shmem_read(CFG_SCRATCH_SPACE + 14, 1) == 8'h00)
         begin
            dummy = ebfm_display(EBFM_MSG_INFO, {"      Subsystem Vendor ID: ",
                                                 himage4(shmem_read(CFG_SCRATCH_SPACE + 4, 2))});
            dummy = ebfm_display(EBFM_MSG_INFO, {"             Subsystem ID: ",
                                                 himage4(shmem_read(CFG_SCRATCH_SPACE + 6, 2))});
         end
         case (shmem_read(CFG_SCRATCH_SPACE + 17,1))
            8'h00 : dummy = ebfm_display(EBFM_MSG_INFO,"            Interrupt Pin: No INTx# pin used");
            8'h01 : dummy = ebfm_display(EBFM_MSG_INFO,"            Interrupt Pin: INTA# used");
            8'h02 : dummy = ebfm_display(EBFM_MSG_INFO,"            Interrupt Pin: INTB# used");
            8'h03 : dummy = ebfm_display(EBFM_MSG_INFO,"            Interrupt Pin: INTC# used");
            8'h04 : dummy = ebfm_display(EBFM_MSG_INFO,"            Interrupt Pin: INTD# used");
            default: dummy = ebfm_display(EBFM_MSG_ERROR_FATAL,"            Interrupt Pin: Interrupt Pin Register has Illegal Value.");
         endcase
         dummy = ebfm_display(EBFM_MSG_INFO, "");
      end
   endtask

   // purpose: Display the root port BARs
   task ebfm_display_rp_bar;
      input bnm;
      integer bnm;
      input dev;
      integer dev;
      input fnc;
      integer fnc;
      input CFG_SCRATCH_SPACE;
      integer CFG_SCRATCH_SPACE;

      reg[2:0] compl_status;

      reg dummy ;
      reg [63:0] bar;
      integer i,j,k,bar_lsb;

      begin

         // find bar size
         ebfm_cfgwr_imm_wait(bnm,dev,fnc,16,4, 32'hFFFF_FFFF, compl_status);
         ebfm_cfgwr_imm_wait(bnm,dev,fnc,20,4, 32'hFFFF_FFFF, compl_status);
         // don't enable expansion ROM BAR
         ebfm_cfgwr_imm_wait(bnm,dev,fnc,56,4, 32'hFFFF_FFFE, compl_status);
         // I/O base and limit
         ebfm_cfgwr_imm_wait(bnm,dev,fnc,28,2, 16'hFFFF, compl_status);
         // Prefet base and limit
         ebfm_cfgwr_imm_wait(bnm,dev,fnc,36,4, 32'hFFFF_FFFF, compl_status);

         ebfm_cfgrd_wait(bnm, dev, fnc, 16, 4, CFG_SCRATCH_SPACE, compl_status);
         ebfm_cfgrd_wait(bnm, dev, fnc, 20, 4, CFG_SCRATCH_SPACE + 4, compl_status);
         ebfm_cfgrd_wait(bnm, dev, fnc, 56, 4, CFG_SCRATCH_SPACE + 8, compl_status);
         ebfm_cfgrd_wait(bnm, dev, fnc, 28, 4, CFG_SCRATCH_SPACE + 12, compl_status);
         ebfm_cfgrd_wait(bnm, dev, fnc, 36, 4, CFG_SCRATCH_SPACE + 16, compl_status);

         dummy = ebfm_display(EBFM_MSG_INFO, "  RP Base Address Registers:");

         dummy = ebfm_display(EBFM_MSG_INFO, "");
         dummy = ebfm_display(EBFM_MSG_INFO, "BAR Address Assignments:");
         dummy = ebfm_display(EBFM_MSG_INFO, {"BAR   ", " ", "Size      ", " ", "Assigned Address ", " ", "Type"});
         dummy = ebfm_display(EBFM_MSG_INFO, {"---   ", " ", "----      ", " ", "---------------- ", " "});
         bar = shmem_read(CFG_SCRATCH_SPACE, 8);

         for (i = 0; i < 2; i = i + 1)
           begin
              bar_lsb = 64;
              
              if (bar[2] == 1'b1) // extend the end limit for 64 bit BAR
                k = 1;
              else
                k = 0;
              
              // find first one
              begin : find_first
                 for(j = 4; j <= k*32 + 31; j = j + 1)
                   begin : lsb_loop
                      if ((bar[j]) == 1'b1)
                        begin
                           bar_lsb = j ;
                           disable find_first ;
                        end
                   end
              end
              
              describe_bar(i,bar_lsb,bar,1'b1);
              if (bar[2] == 1'b1)  // Found 64 bit BAR 
                i = i + 1;
              else
                // Move the second BAR to first position for second time around
                bar[31:0] = bar[63:32] ;
                           
           end // for (i = 0; i < 2; i = i + 1)

         // expansion rom
         bar = 0;
         bar = shmem_read(CFG_SCRATCH_SPACE + 8, 4);
         bar_lsb = 64;
         
         begin : ff_eeprom
            for(j = 4 ; j <= 31; j = j + 1)
              begin : loop_eeprom
                 if ((bar[j]) == 1'b1)
                   begin
                      bar_lsb = j;
                      disable ff_eeprom ;
                   end
              end
         end
         describe_bar(6,bar_lsb,bar,1'b1);
         dummy = ebfm_display(EBFM_MSG_INFO, "");
         
         // check IO base/limit
         bar = 0;
         bar = shmem_read(CFG_SCRATCH_SPACE +12, 2);
         if (bar[31:0] == 0)
           dummy = ebfm_display(EBFM_MSG_INFO,"   I/O Base and Limit Register: Disable ");
         else if (bar[0] == 0)
           dummy = ebfm_display(EBFM_MSG_INFO,"   I/O Base and Limit Register: 16Bit ");
         else if (bar[0] == 1)
           dummy = ebfm_display(EBFM_MSG_INFO,"   I/O Base and Limit Register: 32Bit ");
         else
           dummy = ebfm_display(EBFM_MSG_INFO,"   I/O Base and Limit Register: Reserved ");
         
         // check Prefetchable Memory base/limit
         bar = 0;
         bar = shmem_read(CFG_SCRATCH_SPACE + 16, 4);
         if (bar[31:0] == 0)
           dummy = ebfm_display(EBFM_MSG_INFO,"   Prefetchable Base and Limit Register: Disable ");
         else if (bar[3:0] == 0) //
           dummy = ebfm_display(EBFM_MSG_INFO,"   Prefetchable Base and Limit Register: 32Bit ");
         else if (bar[3:0] == 1)
           dummy = ebfm_display(EBFM_MSG_INFO,"   Prefetchable Base and Limit Register: 64Bit ");
         else
           dummy = ebfm_display(EBFM_MSG_INFO,"   Prefetchable Base and Limit Register: Reserved ");
         
         dummy = ebfm_display(EBFM_MSG_INFO, "");
         

      end
   endtask


   // purpose: Display the MSI Information
   task ebfm_display_msi;
       input bnm;
       integer bnm;
       input dev;
       integer dev;
       input fnc;
       integer fnc;
       input CFG_SCRATCH_SPACE;
       integer CFG_SCRATCH_SPACE;

       reg [2:0] compl_status;
       reg[15:0] message_control_r;

       reg dummy ;

       begin
          ebfm_cfgrd_wait(bnm, dev, fnc, 80, 4, CFG_SCRATCH_SPACE, compl_status);
          dummy = ebfm_display(EBFM_MSG_INFO,"  PCI MSI Capability Register:") ;
          message_control_r = shmem_read(CFG_SCRATCH_SPACE+2,2) ;
          if (message_control_r[7] == 1'b1)
             dummy = ebfm_display(EBFM_MSG_INFO,"   64-Bit Address Capable: Supported");
          else
             dummy = ebfm_display(EBFM_MSG_INFO,"   64-Bit Address Capable: Not Supported");
          case (message_control_r[3:1])
             3'b000 : dummy = ebfm_display(EBFM_MSG_INFO,"       Messages Requested:  1") ;
             3'b001 : dummy = ebfm_display(EBFM_MSG_INFO,"       Messages Requested:  2") ;
             3'b010 : dummy = ebfm_display(EBFM_MSG_INFO,"       Messages Requested:  4") ;
             3'b011 : dummy = ebfm_display(EBFM_MSG_INFO,"       Messages Requested:  8") ;
             3'b100 : dummy = ebfm_display(EBFM_MSG_INFO,"       Messages Requested: 16") ;
             3'b101 : dummy = ebfm_display(EBFM_MSG_INFO,"       Messages Requested: 32") ;
             default: dummy = ebfm_display(EBFM_MSG_INFO,"       Messages Requested: Reserved") ;
          endcase
       dummy = ebfm_display(EBFM_MSG_INFO,"") ;
       end
   endtask

   // purpose: Display the MSI-X Information
   task ebfm_display_msix;
       input bnm;
       integer bnm;
       input dev;
       integer dev;
       input fnc;
       integer fnc;
       input CFG_SCRATCH_SPACE;
       integer CFG_SCRATCH_SPACE;

       reg [2:0] compl_status;
       reg [31:0] dword;

       reg dummy ;

       begin
          ebfm_cfgwr_imm_wait(bnm,dev,fnc,104,4, 32'h8000_0000, compl_status);
          ebfm_cfgrd_wait(bnm, dev, fnc, 104, 4, CFG_SCRATCH_SPACE, compl_status);
          dword = shmem_read(CFG_SCRATCH_SPACE,4) ;
          if (dword[31] == 1'b1) // check for implementation
        begin
            dummy = ebfm_display(EBFM_MSG_INFO,"  PCI MSI-X Capability Register:") ;
            dummy = ebfm_display(EBFM_MSG_INFO, {"               Table Size: ", himage4(dword[26:16])});

            ebfm_cfgrd_wait(bnm, dev, fnc, 108, 4, CFG_SCRATCH_SPACE, compl_status);
            dword = shmem_read(CFG_SCRATCH_SPACE,4) ;
            dummy = ebfm_display(EBFM_MSG_INFO, {"                Table BIR: ", himage1(dword[2:0])});
            dummy = ebfm_display(EBFM_MSG_INFO, {"             Table Offset: ", himage8(dword[31:3])});

            ebfm_cfgrd_wait(bnm, dev, fnc, 112, 4, CFG_SCRATCH_SPACE, compl_status);
            dword = shmem_read(CFG_SCRATCH_SPACE,4) ;
            dummy = ebfm_display(EBFM_MSG_INFO, {"                  PBA BIR: ", himage1(dword[2:0])});
            dummy = ebfm_display(EBFM_MSG_INFO, {"               PBA Offset: ", himage8(dword[31:3])});

        dummy = ebfm_display(EBFM_MSG_INFO,"") ;

        // Disable MSIX
            ebfm_cfgwr_imm_wait(bnm,dev,fnc,104,4, 32'h0000_0000, compl_status);
        end
       end
    endtask

   // purpose: Display the Advance Error Reporting Information
   task ebfm_display_aer;
       input root_port;
       input bnm;
       integer bnm;
       input dev;
       integer dev;
       input fnc;
       integer fnc;
       input CFG_SCRATCH_SPACE;
       integer CFG_SCRATCH_SPACE;

       reg [2:0] compl_status;
       reg [31:0] dword;

       reg dummy ;

       begin
          ebfm_cfgrd_wait(bnm, dev, fnc, 2048, 4, CFG_SCRATCH_SPACE, compl_status);
          dword = shmem_read(CFG_SCRATCH_SPACE,4) ;
          if (dword[15:0] == 16'h0001) // check for implementation
        begin
            if (root_port==1)
                dummy = ebfm_display(EBFM_MSG_INFO,"  RP PCI Express AER Capability Register:") ;
            else
                dummy = ebfm_display(EBFM_MSG_INFO,"  EP PCI Express AER Capability Register:") ;

        // turn on check and gen on root port
        ebfm_cfgwr_imm_wait(RP_PRI_BUS_NUM,RP_PRI_DEV_NUM,fnc,2072,2, 16'h0140, compl_status);

            ebfm_cfgrd_wait(bnm, dev, fnc, 2072, 4, CFG_SCRATCH_SPACE, compl_status);
            dword = shmem_read(CFG_SCRATCH_SPACE,4) ;

        ebfm_cfgwr_imm_wait(bnm,dev,fnc,2072,2, {dword[14:0],1'b0}, compl_status);
        if (dword[7] == 1'b1)
              dummy = ebfm_display(EBFM_MSG_INFO, {"       ECRC Check Capable: Supported"});
        else
              dummy = ebfm_display(EBFM_MSG_INFO, {"       ECRC Check Capable: Not Supported"});

        if (dword[5] == 1'b1)
              dummy = ebfm_display(EBFM_MSG_INFO, {"  ECRC Generation Capable: Supported"});
        else
              dummy = ebfm_display(EBFM_MSG_INFO, {"  ECRC Generation Capable: Not Supported"});

        dummy = ebfm_display(EBFM_MSG_INFO,"") ;
        end

       end
    endtask


   // purpose: Display the Advance Error Reporting Information
   task ebfm_display_slot_cap;
       input root_port;
       input bnm;
       integer bnm;
       input dev;
       integer dev;
       input fnc;
       integer fnc;
       input CFG_SCRATCH_SPACE;
       integer CFG_SCRATCH_SPACE;

       reg [2:0] compl_status;
       reg [31:0] dword;

       reg dummy ;

       begin
          // read the Slot Capability Register
          ebfm_cfgrd_wait(bnm, dev, fnc, PCIE_CAP_PTR + 20, 4, CFG_SCRATCH_SPACE, compl_status);
          dword = shmem_read(CFG_SCRATCH_SPACE,4) ;


        if (root_port==1)
            dummy = ebfm_display(EBFM_MSG_INFO,{"   RP PCI Express Slot Capability Register (", himage8(dword), "):"});
        else
            dummy = ebfm_display(EBFM_MSG_INFO,{"   EP PCI Express Slot Capability Register (", himage8(dword), "):"});


        if (dword[0] == 1'b1)
              dummy = ebfm_display(EBFM_MSG_INFO, {"       Attention Button: Present"});
        else
              dummy = ebfm_display(EBFM_MSG_INFO, {"       Attention Button: Not Present"});


        if (dword[1] == 1'b1)
              dummy = ebfm_display(EBFM_MSG_INFO, {"       Power Controller: Present"});
        else
              dummy = ebfm_display(EBFM_MSG_INFO, {"       Power Controller: Not Present"});


        if (dword[2] == 1'b1)
              dummy = ebfm_display(EBFM_MSG_INFO, {"             MRL Sensor: Present"});
        else
              dummy = ebfm_display(EBFM_MSG_INFO, {"             MRL Sensor: Not Present"});


        if (dword[3] == 1'b1)
              dummy = ebfm_display(EBFM_MSG_INFO, {"    Attention Indicator: Present"});
        else
              dummy = ebfm_display(EBFM_MSG_INFO, {"    Attention Indicator: Not Present"});

        if (dword[4] == 1'b1)
              dummy = ebfm_display(EBFM_MSG_INFO, {"        Power Indicator: Present"});
        else
              dummy = ebfm_display(EBFM_MSG_INFO, {"        Power Indicator: Not Present"});

        if (dword[5] == 1'b1)
              dummy = ebfm_display(EBFM_MSG_INFO, {"      Hot-Plug Surprise: Supported"});
        else
              dummy = ebfm_display(EBFM_MSG_INFO, {"      Hot-Plug Surprise: Not Supported"});

        if (dword[6] == 1'b1)
              dummy = ebfm_display(EBFM_MSG_INFO, {"       Hot-Plug Capable: Supported"});
        else
              dummy = ebfm_display(EBFM_MSG_INFO, {"       Hot-Plug Capable: Not Supported"});


        dummy = ebfm_display(EBFM_MSG_INFO,{"        Slot Power Limit Value: ", himage1(dword[14:7])}) ;

        dummy = ebfm_display(EBFM_MSG_INFO,{"        Slot Power Limit Scale: ", himage1(dword[16:15])}) ;

        dummy = ebfm_display(EBFM_MSG_INFO,{"          Physical Slot Number: ", himage1(dword[31:19])}) ;

        dummy = ebfm_display(EBFM_MSG_INFO,"") ;


       end
    endtask


    // purpose: Display the Virtual Channel Capabilities
   task ebfm_display_vc;
      input root_port;
      input bnm;
      integer bnm;
      input dev;
      integer dev;
      input fnc;
      integer fnc;
      input CFG_SCRATCH_SPACE;
      integer CFG_SCRATCH_SPACE;

      reg [2:0] compl_status;
      reg[15:0] port_vc_cap_r;
      reg [2:0] low_vc;

      reg dummy ;

      begin  // ebfm_display_vc
        ebfm_cfgrd_wait(bnm,dev,fnc,260,4,CFG_SCRATCH_SPACE, compl_status);

        port_vc_cap_r = shmem_read(CFG_SCRATCH_SPACE,2) ;
        // Low priority VC = 0 means there is no Low priority VC
        // Low priority VC = 1 means there are 2 Low priority VCs etc
    if (port_vc_cap_r[6:4] == 3'b000)
    begin
        low_vc = 3'b000;
    end
    else
    begin
        low_vc = port_vc_cap_r[6:4] + 1;
    end
        if (root_port==1)
            dummy = ebfm_display(EBFM_MSG_INFO,"  RP PCI Express Virtual Channel Capability:") ;
        else
            dummy = ebfm_display(EBFM_MSG_INFO,"  EP PCI Express Virtual Channel Capability:") ;

        dummy = ebfm_display(EBFM_MSG_INFO,{"         Virtual Channel: ", himage1({1'b0,port_vc_cap_r[2:0]} +1)}) ;
        dummy = ebfm_display(EBFM_MSG_INFO,{"         Low Priority VC: ", himage1({1'b0,low_vc})}) ;
        dummy = ebfm_display(EBFM_MSG_INFO,"") ;
    end
  endtask

   // purpose: Performs all of the steps neccesary to configure the
   // root port and the endpoint on the link
   task ebfm_cfg_rp_ep_main;
      input bar_table;
      integer bar_table;
      // Constant Display the Config Spaces of the EP after config setup
      input ep_bus_num;
      integer ep_bus_num;
      input ep_dev_num;
      integer ep_dev_num;
      input rp_max_rd_req_size;
      integer rp_max_rd_req_size;
      input display_ep_config;    // 1 to display
      integer display_ep_config;
      input display_rp_config;    // 1 to display
      integer display_rp_config;
      input addr_map_4GB_limit;


      reg[31:0] io_min_v;
      reg[31:0] io_max_v;
      reg[63:0] m32min_v;
      reg[63:0] m32max_v;
      reg[63:0] m64min_v;
      reg[63:0] m64max_v;
      reg[2:0] compl_status;
      reg bar_ok;

      reg dummy ;

      integer i ;

      begin  // ebfm_cfg_rp_ep_main
         io_min_v = EBFM_BAR_IO_MIN ;
         io_max_v = EBFM_BAR_IO_MAX ;
         m32min_v = {32'h00000000,EBFM_BAR_M32_MIN};
         m32max_v = {32'h00000000,EBFM_BAR_M32_MAX};
         m64min_v = EBFM_BAR_M64_MIN;
         m64max_v = EBFM_BAR_M64_MAX;
         if  (display_rp_config == 1'b1) // Limit the BAR allocation to less than 4GB
      begin
           m32max_v[31:0] = m32max_v[31:0] & 32'h7fff_ffff;
           m64min_v = 64'h0000_0000_8000_0000;
      end

         // Wait until the Root Port is done being reset before proceeding further
         #10;

         req_intf_wait_reset_end;

         // Unlock the bfm shared memory for initialization
         bfm_shmem_common.protect_bfm_shmem = 1'b0;

         // Perform the basic configuration of the Root Port
         ebfm_cfg_rp_basic((ep_bus_num - RP_PRI_BUS_NUM), 1);

         if ((display_ep_config == 1) | (display_rp_config == 1)) begin
            dummy = ebfm_display(EBFM_MSG_INFO, "Completed initial configuration of Root Port.");
         end

         if (display_ep_config == 1)
         begin
            ebfm_display_read_only(0, (ep_bus_num - RP_PRI_BUS_NUM), 1, 0, CFG_SCRATCH_SPACE);
            ebfm_display_msi(ep_bus_num,1,0,CFG_SCRATCH_SPACE) ;
            ebfm_display_msix(ep_bus_num,1,0,CFG_SCRATCH_SPACE) ;
            ebfm_display_aer(0, ep_bus_num,1,0,CFG_SCRATCH_SPACE) ;
         end

         if (display_rp_config == 1) begin
             // dummy write to ensure link is at L0
             ebfm_cfgwr_imm_wait(ep_bus_num, ep_dev_num, 0, 4, 4, 32'h00000007, compl_status);

             ebfm_display_read_only(1, RP_PRI_BUS_NUM, RP_PRI_DEV_NUM, 0, CFG_SCRATCH_SPACE);
             ebfm_display_rp_bar(RP_PRI_BUS_NUM, RP_PRI_DEV_NUM, 0, CFG_SCRATCH_SPACE);
             ebfm_display_msi(RP_PRI_BUS_NUM,RP_PRI_DEV_NUM,0,CFG_SCRATCH_SPACE) ;
             ebfm_display_aer(1, RP_PRI_BUS_NUM, RP_PRI_DEV_NUM, 0, CFG_SCRATCH_SPACE) ;
             ebfm_display_slot_cap (1, RP_PRI_BUS_NUM, RP_PRI_DEV_NUM, 0, CFG_SCRATCH_SPACE) ;
         end

         ebfm_cfg_pcie_cap((ep_bus_num - RP_PRI_BUS_NUM), 1, 0, CFG_SCRATCH_SPACE, rp_max_rd_req_size, display_ep_config, display_rp_config);

         // Configure BARs (Throw away the updated min/max addresses)
         ebfm_cfg_bars(ep_bus_num, ep_dev_num, 0, bar_table, bar_ok,
                       io_min_v, io_max_v, m32min_v, m32max_v, m64min_v, m64max_v,
                       display_ep_config, addr_map_4GB_limit);
         if (bar_ok == 1'b1)
         begin
            if ((display_ep_config == 1) | (display_rp_config == 1))
            begin
               dummy = ebfm_display(EBFM_MSG_INFO, "Completed configuration of Endpoint BARs.");
            end
         end
         else
         begin
            dummy = ebfm_display(EBFM_MSG_ERROR_FATAL, "Unable to assign all of the Endpoint BARs.");
         end

         // Configure Root Port Address Windows
         ebfm_cfg_rp_addr(
         (m32max_v + 1),    // Pref32 grew down
         (m64min_v - 1),    // Pref64 grew up
         (EBFM_BAR_M32_MIN),    // NonP started here
         (m32min_v[31:0] - 1),  // NonP ended here
         (EBFM_BAR_IO_MIN), // I/O Started Here
         (io_min_v - 1));   // I/O ended Here

         ebfm_cfgwr_imm_wait(ep_bus_num, ep_dev_num, 0, 4, 4, 32'h00000007, compl_status);

         // Protect the critical BFM data from being accidentally overwritten.
         bfm_shmem_common.protect_bfm_shmem = 1'b1;

      end
   endtask

   task ebfm_cfg_rp_ep;   // Wrapper task called by End Point
      input bar_table;
      integer bar_table;
      // Constant Display the Config Spaces of the EP after config setup
      input ep_bus_num;
      integer ep_bus_num;
      input ep_dev_num;
      integer ep_dev_num;
      input rp_max_rd_req_size;
      integer rp_max_rd_req_size;
      input display_ep_config;    // 1 to display
      integer display_ep_config;
      input addr_map_4GB_limit;

      ebfm_cfg_rp_ep_main (bar_table, ep_bus_num, ep_dev_num, rp_max_rd_req_size, display_ep_config, 0, addr_map_4GB_limit);

   endtask


   task ebfm_cfg_rp_ep_rootport;   // Wrapper task called by Root Port
      input bar_table;
      integer bar_table;
      // Constant Display the Config Spaces of the EP after config setup
      input ep_bus_num;
      integer ep_bus_num;
      input ep_dev_num;
      integer ep_dev_num;
      input rp_max_rd_req_size;
      integer rp_max_rd_req_size;
      input display_ep_config;    // 1 to display
      integer display_ep_config;
      input display_rp_config;    // 1 to display
      integer display_rp_config;
      input addr_map_4GB_limit;

      ebfm_cfg_rp_ep_main (bar_table, ep_bus_num, ep_dev_num, rp_max_rd_req_size, display_ep_config, display_rp_config, addr_map_4GB_limit);

   endtask


   // purpose: returns whether specified BAR is memory or I/O and the size
   task ebfm_cfg_decode_bar;
      input bar_table;   // Pointer to BAR info
      integer bar_table;
      input bar_num;     // bar number to check
      integer bar_num;
      output log2_size;  // Log base 2 of the Size
      integer log2_size;
      output is_mem;     // Is memory (not I/O)
      output is_pref;    // Is prefetchable
      output is_64b;     // Is 64bit

      reg[63:0] bar64;
      parameter[31:0] ZERO32 = {32{1'b0}};
      integer maxlsb;

      begin
         bar64 = shmem_read((bar_table + 32 + (bar_num * 4)), 8);
         // Check if BAR is unassigned
         if (bar64[31:0] == ZERO32)
         begin
            log2_size = 0;
            is_mem = 1'b0;
            is_pref = 1'b0;
            is_64b = 1'b0;
         end
         else
         begin
            is_mem = ~bar64[0];
            is_pref = (~bar64[0]) & bar64[3];
            is_64b = (~bar64[0]) & bar64[2];
            if (((bar64[0]) == 1'b1) | ((bar64[2]) == 1'b0))
            begin
               maxlsb = 31;
            end
            else
            begin
               maxlsb = 63;
            end
            begin : xhdl_10
               integer i;
               for(i = 4; i <= maxlsb; i = i + 1)
               begin : check_loop
                  if ((bar64[i]) == 1'b1)
                  begin
                     log2_size = i;
                     disable xhdl_10 ;
                  end
               end
            end // i in 4 to maxlsb
         end
      end
   endtask

   // The clk_in and rstn signals are provided for possible use in controlling
   // the transactions issued, they are not currently used.
   input clk_in; 
   input rstn;
   input INTA;
   input INTB;
   input INTC;
   input INTD;
   output dummy_out; 

   // purpose: Use Reads and Writes to test the target memory
   //          The starting offset in the target memory and the
   //          length can be specified
   task target_mem_test;
      input bar_table;      // Pointer to the BAR sizing and
      integer bar_table;    // address information set up by
                            // the configuration routine
      input tgt_bar;        // BAR to use to access the target
      integer tgt_bar;      // memory
      input start_offset;   // Starting offset in the target
      integer start_offset; // memory to use
      input tgt_data_len;   // Length of data to test
      integer tgt_data_len;

      parameter TGT_WR_DATA_ADDR = 1 * (2 ** 16); 
      integer tgt_rd_data_addr; 
      integer err_addr; 

      reg unused_result ;
      
      begin  // target_mem_test
         unused_result = ebfm_display(EBFM_MSG_INFO, "Starting Target Write/Read Test."); 
         unused_result = ebfm_display(EBFM_MSG_INFO, {"  Target BAR = ", dimage1(tgt_bar)}); 
         unused_result = ebfm_display(EBFM_MSG_INFO, {"  Length = ", dimage6(tgt_data_len), ", Start Offset = ", dimage6(start_offset)}); 
         // Setup some data to write to the Target
         shmem_fill(TGT_WR_DATA_ADDR, SHMEM_FILL_DWORD_INC, tgt_data_len, {64{1'b0}}); 
         // Setup an address for the data to read back from the Target
         tgt_rd_data_addr = TGT_WR_DATA_ADDR + (2 * tgt_data_len); 
         // Clear the target data area
         shmem_fill(tgt_rd_data_addr, SHMEM_FILL_ZERO, tgt_data_len, {64{1'b0}}); 
         //
         // Now write the data to the target with this BFM call
         //
         ebfm_barwr(bar_table, tgt_bar, start_offset, TGT_WR_DATA_ADDR, tgt_data_len, 0); 
         //
         // Read the data back from the target in one burst, wait for the read to
         // be complete
         // 
         ebfm_barrd_wait(bar_table, tgt_bar, start_offset, tgt_rd_data_addr, tgt_data_len, 0); 
         // Check the data
         if (shmem_chk_ok(tgt_rd_data_addr, SHMEM_FILL_DWORD_INC, tgt_data_len, {64{1'b0}}, 1'b1))
         begin
            unused_result = ebfm_display(EBFM_MSG_INFO, "  Target Write and Read compared okay!"); 
         end
         else
         begin
            unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, "  Stopping simulation due to miscompare"); 
         end 
      end
   endtask

  task target_mem_test_lite;
      input bar_table;      // Pointer to the BAR sizing and
      integer bar_table;    // address information set up by
                            // the configuration routine
      input tgt_bar;        // BAR to use to access the target
      integer tgt_bar;      // memory
      input start_offset;   // Starting offset in the target
      integer start_offset; // memory to use
      input tgt_data_len;   // Length of data to test
      integer tgt_data_len;

      parameter TGT_WR_DATA_ADDR = 1 * (2 ** 16); 
      integer tgt_rd_data_addr; 
      integer err_addr; 

      reg unused_result ;
      
      begin  // target_mem_test_lite (single DW)
         unused_result = ebfm_display(EBFM_MSG_INFO, "Starting Target Write/Read Test."); 
         unused_result = ebfm_display(EBFM_MSG_INFO, {"  Target BAR = ", dimage1(tgt_bar)}); 
         unused_result = ebfm_display(EBFM_MSG_INFO, {"  Length = ", dimage6(tgt_data_len), ", Start Offset = ", dimage6(start_offset)}); 
         // Setup some data to write to the Target
         shmem_fill(TGT_WR_DATA_ADDR, SHMEM_FILL_DWORD_INC, 32, {64{1'b0}});  /// 32 bytes
         // Setup an address for the data to read back from the Target
         tgt_rd_data_addr = TGT_WR_DATA_ADDR + (2 * 32);              // 32-bytes
         // Clear the target data area
         shmem_fill(tgt_rd_data_addr, SHMEM_FILL_ZERO, 32, {64{1'b0}}); 
         //
         // Now write the data to the target with this BFM call
         //
         ebfm_barwr(bar_table, tgt_bar, start_offset, TGT_WR_DATA_ADDR, 4, 0); 
         //
         // Read the data back from the target in one burst, wait for the read to
         // be complete
         // 
         ebfm_barrd_wait(bar_table, tgt_bar, start_offset, tgt_rd_data_addr, 4, 0); 
         // Check the data
         if (shmem_chk_ok(tgt_rd_data_addr, SHMEM_FILL_DWORD_INC, 4, {64{1'b0}}, 1'b1))
         begin
            unused_result = ebfm_display(EBFM_MSG_INFO, "  Target Write and Read compared okay!"); 
         end
         else
         begin
            unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, "  Stopping simulation due to miscompare"); 
         end 
      end
   endtask



   // purpose: This procedure polls the DMA engine until it is done
  task dma_wait_done;
      input bar_table; 
      integer bar_table;
      input setup_bar; 
      integer setup_bar;
      input msi_mem; 
      integer msi_mem;
      

      reg [31:0] dma_sts ;
      reg unused_result;
      begin
         // dma_wait_done
         shmem_fill(msi_mem, SHMEM_FILL_ZERO, 4, {64{1'b0}});
         dma_sts = 32'h00000000 ;
         while (dma_sts != 32'h0000abcd)
         begin
            #10
            dma_sts = shmem_read(msi_mem,4) ;
         end 
         
         unused_result = ebfm_display(EBFM_MSG_INFO, "MSI recieved!");
        // ebfm_barwr_imm(bar_table, setup_bar, 16'h1000,  32'h00000000, 4, 0);  // clear done bit in status reg  
        // unused_result = ebfm_display(EBFM_MSG_INFO, "  Clear interrupt !");
         
         
      end

   endtask

   // purpose: Use the reference design's DMA engine to move data from the BFM's
   // shared memory to the reference design's master memory and then back
    task dma_mem_test;
      input bar_table;      // Pointer to the BAR sizing and
      integer bar_table;    // address information set up by
                            // the configuration routine
      input setup_bar;      // BAR to be used for setting up
      integer setup_bar;    // the DMA operation and checking
                            // the status 
      input start_offset;   // Starting offset in the master
      integer start_offset; // memory 
      input dma_data_len;   // Length of DMA operations 
      integer dma_data_len;

      parameter SCR_MEM = (2 ** 17) - 4; 
      integer dma_rd_data_addr; 
      integer dma_wr_data_addr; 
      integer err_addr; 
      reg [2:0] compl_status;
      reg [2:0]  multi_message_enable;
      reg        msi_enable;
      reg [31:0] msi_capabilities ;
      reg [15:0] msi_data;
      reg [31:0] msi_address;
integer passthru_msk;

      reg dummy ;
      
      begin
      dummy = ebfm_display(EBFM_MSG_INFO, "Starting DMA Read/Write Test."); 
         dummy = ebfm_display(EBFM_MSG_INFO, {"  Setup BAR = ", dimage1(setup_bar)}); 
         dummy = ebfm_display(EBFM_MSG_INFO, {"  Length = ", dimage6(dma_data_len), 
                                      ", Start Offset = ", dimage6(start_offset)}); 
         dma_rd_data_addr = SCR_MEM + 4 + start_offset; 
         // Setup some data for the DMA to read
         shmem_fill(dma_rd_data_addr, SHMEM_FILL_DWORD_INC, dma_data_len, {64{1'b0}}); 
         
         
         // MSI capabilities
          msi_capabilities = 32'h50;
          msi_address = SCR_MEM;
          msi_data = 16'habcd;
          msi_enable = 1'b0;
          multi_message_enable = 3'b000;
          
         // Program the DMA to Read Data from Shared Memory

      // check the # of passthru bits
         ebfm_barwr_imm(bar_table, setup_bar, CRA_BASE+16'h1000,  32'hffffffff, 4, 0);
         ebfm_barrd_wait(bar_table, setup_bar,CRA_BASE+16'h1000, SCR_MEM, 4, 0); /// read the status reg
       passthru_msk = shmem_read(SCR_MEM,4) & 32'hffff_fffc;

      // Set PCI Express Interrupt enable (bit 0) in the PCIe-Avalon-MM bridge at address Avalon_Base_Address + 0x50
         ebfm_barwr_imm(bar_table, setup_bar, CRA_BASE+16'h0050,  32'h00000001, 4, 0);


      // To program DMA and translation, take the portion of the DMA address that
      // is below passthru bits and program them to DMA. The remaining portion goes
      // to address translation table

      // program address translation table
         ebfm_barwr_imm(bar_table, setup_bar, CRA_BASE+16'h1000,  dma_rd_data_addr & passthru_msk, 4, 0);
         ebfm_barwr_imm(bar_table, setup_bar, CRA_BASE+16'h1004,  32'h00000000, 4, 0);

         ebfm_barwr_imm(bar_table, setup_bar, DMA_BASE+16'h0004,  dma_rd_data_addr & ~passthru_msk, 4, 0);  // reg 1 (read address)   
         ebfm_barwr_imm(bar_table, setup_bar, DMA_BASE+16'h0008, MEM_OFFSET, 4, 0);  // reg 2 (write address)  
         ebfm_barwr_imm(bar_table, setup_bar, DMA_BASE+16'h000C, dma_data_len, 4, 0);  // reg 3 (dma length)     
         ebfm_barwr_imm(bar_table, setup_bar, DMA_BASE+16'h0018, 32'h00000498, 4, 0); //  reg 6 (control)  

          #10
         wait(INTA);
         // check for INTA deassertion
         
         dummy = ebfm_display(EBFM_MSG_INFO, "Clear Interrupt INTA "); 
         ebfm_barwr_imm(bar_table, setup_bar, DMA_BASE+16'h0000,  32'h00000000, 4, 0);  // clear done bit in status reg
         
         #10
         wait(!INTA);
         
         //enable MSI enable
         msi_enable = 1'b1;
         ebfm_cfgwr_imm_wait(1, 0, 0, msi_capabilities, 4, {8'h00, 1'b0, multi_message_enable, 3'b000, msi_enable, 16'h0000}, compl_status);
         ebfm_cfgwr_imm_wait(1, 0, 0, msi_capabilities + 4'h4, 4, msi_address, compl_status);
         ebfm_cfgwr_imm_wait(1, 0, 0, msi_capabilities + 4'hC, 4, msi_data,    compl_status);

        // Setup an area for DMA to write back to
         // Currently DMA Engine Uses lower address bits for it's MRAM and PCIE
         // Addresses. So use the same address we started with
         dma_wr_data_addr = dma_rd_data_addr; 
         shmem_fill(dma_wr_data_addr, SHMEM_FILL_ZERO, dma_data_len, {64{1'b0}}); 
         
         // Program the DMA to Write Data Back to Shared Memory
         ebfm_barwr_imm(bar_table, setup_bar, DMA_BASE+16'h0004, MEM_OFFSET , 4, 0);  // reg 1 (read address)   
         ebfm_barwr_imm(bar_table, setup_bar, DMA_BASE+16'h0008, dma_wr_data_addr & ~passthru_msk, 4, 0);  // reg 2 (write address)  
         ebfm_barwr_imm(bar_table, setup_bar, DMA_BASE+16'h000c, dma_data_len, 4, 0);  // reg 3 (dma length)     
         ebfm_barwr_imm(bar_table, setup_bar, DMA_BASE+16'h0018, 32'h00000498, 4, 0); //  reg 6 (control)  
         
          // Wait Until the DMA is done via MSI
         dma_wait_done(bar_table, setup_bar, SCR_MEM);
             
         // Check the data
         if (shmem_chk_ok(dma_rd_data_addr, SHMEM_FILL_DWORD_INC, dma_data_len, {64{1'b0}}, 1'b1))
         begin
            dummy = ebfm_display(EBFM_MSG_INFO, "  DMA Read and Write compared okay!"); 
         end
         else
         begin
            dummy = ebfm_display(EBFM_MSG_ERROR_FATAL, "  Stopping simulation due to miscompare"); 
         end 

      end
   endtask

   // purpose: Examine the DUT's BAR setup and pick a reasonable BAR to use
   task find_mem_bar;
      input bar_table; 
      integer bar_table;
      input[5:0] allowed_bars; 
      input min_log2_size; 
      integer min_log2_size;
      output sel_bar;
      integer sel_bar;
       
      integer cur_bar; 
      reg[31:0] bar32; 
      integer log2_size; 
      reg is_mem; 
      reg is_pref; 
      reg is_64b; 

      begin  // find_mem_bar
         cur_bar = 0;
         begin : sel_bar_loop
            while (cur_bar < 6)
            begin
               ebfm_cfg_decode_bar(bar_table, cur_bar, log2_size, is_mem, is_pref, is_64b); 
               if ((is_mem == 1'b1) & (log2_size >= min_log2_size) & ((allowed_bars[cur_bar]) == 1'b1))
               begin
                  sel_bar = cur_bar;
                  disable sel_bar_loop ;
               end 
               if (is_64b == 1'b1)
               begin
                  cur_bar = cur_bar + 2; 
               end
               else
               begin
                  cur_bar = cur_bar + 1; 
               end 
            end 
            sel_bar = 7 ; // Invalid BAR if we get this far...
         end
      end
   endtask

   reg activity_toggle; 
   reg timer_toggle ;
   time time_stamp ;
   localparam TIMEOUT = 200000000 ; // 200 us

   initial
     begin
        time_stamp = $time ;
        activity_toggle = 1'b0;
        timer_toggle    = 1'b0;
   end

   always 
   begin : main  // behavioral

      // If you want to relocate the bar_table, modify the BAR_TABLE_POINTER in altpcietb_bfm_shmem.
      // Directly modifying the bar_table at this location may disable overwrite protection for the bar_table
      // If the bar_table is overwritten incorrectly, this will break the testbench functionality.

      // This constant defines where we save the sizes and programmed addresses
      // of the Endpoint Device Under Test BARs 
      parameter bar_table = BAR_TABLE_POINTER; // Default BAR_TABLE_SIZE is 64 bytes

      // tgt_bar indicates which bar to use for testing the target memory of the
      // reference design.
      integer tgt_bar; 
      integer dma_bar;
      reg     addr_map_4GB_limit;
      reg     unused_result ;
      integer i;
      

      // Setup the Root Port and Endpoint Configuration Spaces
      addr_map_4GB_limit = 1'b0;
      ebfm_cfg_rp_ep(
                     bar_table,         // BAR Size/Address info for Endpoint       
                     1,                 // Bus Number for Endpoint Under Test
                     1,                 // Device Number for Endpoint Under Test
                     512,               // Maximum Read Request Size for Root Port
                     1,                 // Display EP Config Space after setup
                     addr_map_4GB_limit // Limit the BAR assignments to 4GB address map
                     ); 
      activity_toggle <= ~activity_toggle ; 

      // Find a memory BAR to use to test the target memory
      // The reference design implements the target memory on BARs 0,1, 4 or 5
      // We need one at least 4 KB big
   if(AVALON_MM_LITE == 0)
      find_mem_bar(bar_table, 6'b110011, 12, tgt_bar); 
   else
       find_mem_bar(bar_table, 6'b110011, 4, tgt_bar); 
      // Test the reference design's target memory
      
  if(AVALON_MM_LITE == 0)
    begin
      if (RUN_TGT_MEM_TST == 0)
	begin
         unused_result = ebfm_display(EBFM_MSG_WARNING, "Skipping target test."); 
	end
      else if (tgt_bar < 6)
	begin

         target_mem_test(
                         bar_table, // BAR Size/Address info for Endpoint
                         tgt_bar,   // BAR to access target memory with
                         32'h0000,         // Starting offset from BAR
                         512       // Length of memory to test
                         );

      end
      else
        begin
         unused_result = ebfm_display(EBFM_MSG_WARNING, "Unable to find a 4 KB BAR to test Target Memory, skipping target test."); 
        end 
     end
   
  else  // is avalon lite
    begin
      if (RUN_TGT_MEM_TST == 0)
	begin
         unused_result = ebfm_display(EBFM_MSG_WARNING, "Skipping target test."); 
	end
      else 
	begin
    for(i=0; i < 4 ; i=i+1)
      begin
         target_mem_test_lite(
                         bar_table, // BAR Size/Address info for Endpoint
                         tgt_bar,   // BAR to access target memory with
                         i*4,         // Starting offset from BAR
                         4       // Length of memory to test
                         );
       end

      end
     end
    
        
        
        
      activity_toggle <= ~activity_toggle ; 
      // Find a memory BAR to use to setup the DMA channel
      // The reference design implements the DMA channel registers on BAR 2 or 3
      // We need one at least 0x7FFF (CRA 0x4000 + DMA 0x8)
      find_mem_bar(bar_table, 6'b001100, 15, dma_bar); 
      // Test the reference design's DMA channel and master memory
      if (RUN_DMA_MEM_TST == 0)
	begin
         unused_result = ebfm_display(EBFM_MSG_WARNING, "Skipping DMA test."); 
	end
   else if (dma_bar < 6)
      begin
         dma_mem_test(
                      bar_table, // BAR Size/Address info for Endpoint
                      dma_bar,   // BAR to access DMA control registers
                      0,         // Starting offset of DMA memory
                      512       // Length of memory to test
                      );
 
      end
      else
      begin
         unused_result = ebfm_display(EBFM_MSG_WARNING, "Unable to find a 128B BAR to test setup DMA channel, skipping DMA test."); 
      end 

      // Stop the simulator and indicate successful completion
      unused_result = ebfm_log_stop_sim(1); 
      forever #100000; 
   end 

   always
     begin
        #(TIMEOUT)
          timer_toggle <= ! timer_toggle ;
     end
   
   reg unused_result ;
   // purpose: this is a watchdog timer, if it sees no activity on the activity
   // toggle signal for 200 us it ends the simulation
   always @(activity_toggle or timer_toggle)
     begin : watchdog
        
        if ( ($time - time_stamp) >= TIMEOUT)
          begin
             unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, "Simulation stopped due to inactivity!"); 
          end
        time_stamp <= $time ;
     end

   always @(INTA)
      begin
         if (INTA)
           unused_result = ebfm_display(EBFM_MSG_INFO, "Interrupt Monitor: Interrupt INTA Asserted");
           else
           unused_result = ebfm_display(EBFM_MSG_INFO, "Interrupt Monitor: Interrupt INTA Deasserted");
      end

endmodule
// synthesis translate_off
