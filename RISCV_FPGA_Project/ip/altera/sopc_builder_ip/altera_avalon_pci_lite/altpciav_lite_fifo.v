////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//      Logic Core:  PCI/Avalon Bridge Megacore Function
//         Company:  Altera Corporation.
//                       www.altera.com 
//          Author:  IPBU SIO Group               
//
//     Description:  FIFO for use in the Altera PCI/Avalon Bridge (altpciav).
//                   The details are described below.
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
// $Id: altpciav_lite_fifo.v,v 1.1 2007/06/06 09:53:42 lfching Exp $
//
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
// This FIFO has the following attributes:
// 1) It operates in the "Legacy" mode as opposed to the "showahead" mode. The 
//    data outputs are not valid until the cycle after rdreq is asserted. The 
//    output data is then held until the cycle after the next rdreq is asserted.
// 2) The rdusedw is always a "guaranteed" value. IE if rdusedw is N in given 
//    cycle, you are guaranteed to be able to assert rdreq N times and get 
//    valid data each time. Note that a rdreq asserted in the first given 
//    cycle when rdusedw was N counts towards the N rdreq's. This is different 
//    behavior than the Altera "dcfifo" megafunction which sometimes outputs 
//    an overly optimistic rdreq value.
// 3) There is a rdvalid output that is asserted with the output data to 
//    unequivocally indicate if the data is valid or not. If a design can 
//    tolerate handling read data on any cycle, then rdreq can be set to '1'  
//    always and the rdvalid can be used to validate the data. 
//    Note that in this case if the writes to the FIFO occur at a very slow rate 
//    then rdempty will always be a '1' and rdusedw will always be '0'. But 
//    the data will be read out of the FIFO as soon as it is valid and validated 
//    by rdvalid.
// 4) Only 2 pipeline registers are used to synchronize grey coded read and 
//    write pointers between clock domains. This is different then the Altera 
//    "dcfifo" megafunction which has 3 pipeline registers.
// 5) The FIFO memory is implemented in an "altsyncram" component.
// 6) There is a "Common Clock" mode which can be used when the read and write
//    clocks are common. This eliminates the synchrnization logic between the
//    clock domains. This reduces both latency and LE size. Note that both the
//    rdclk and wrclk must still be provided (and connected to the same source).
//    UNVALDIATED BEHAVIOR:
//    Things may still work correctly if rdclk and wrclk are derived from the
//    same clock but different frequencies. As long as Quartus can determime
//    the proper relationships between the clocks for timing analysis this
//    should work, but this mode has NOT BEEN VALIDATED!!!!!!
// 7) There is a mode to use the RAM's built in output register. Otherwise a 
//    separate register is instantiate to hold the output data. Using the 
//    RAM's builtin output register saves LE's and also improves the data
//    path Fmax. However due to somepeculiarities with the altsyncram hardware
//    implementation, it significantly complicates the control logic and 
//    reduces the control logic Fmax. Overall for shallow FIFO's the
//    Fmax will probably be better if the RAM Output register is used. For
//    Deep FIFO's the Fmax will probably be better if the RAM Ouptut register
//    is not used.
// 8) The depth of the FIFO is programmable by setting the ADDR_WIDTH 
//    parameter. The FIFO will be 2**ADDR_WIDTH words deep. Note that the 
//    rdusedw and wrusedw outputs will be ADDR_WIDTH+1 bits wide to allow 
//    indication of the full range of 0 to 2**ADDR_WIDTH words used.
// 9) The width of the FIFO is programmable by setting the DATA_WIDTH 
//    parameter.      
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

module altpciav_lite_fifo 
  #(
    parameter COMMON_CLOCK = 0 ,  // Common Clock Mode if equal to a '1' 
    parameter ADDR_WIDTH = 8 ,    // FIFO depth is 2**ADDR_WIDTH
    parameter DATA_WIDTH = 32 ,   // FIFO width 
    parameter USE_RAM_OUTPUT_REGISTER = 0  // Use RAM Built in register 
    )
    (
     input rdclk ,  // Read side clock    
     input wrclk ,  // Write side clock
     input aclr ,   // Asynchronous clear
     input wrreq ,  // Write Request 
     input rdreq ,  // Read Request 
     input [DATA_WIDTH-1 : 0] data ,  // Input Data 
     output reg rdempty ,             // Read side Empty flag
     output reg wrfull ,              // Write side Full flag 
     output reg rdvalid ,             // Read Data Valid 
     output reg [ADDR_WIDTH : 0] rdusedw ,  // Read Used Words
     output reg [ADDR_WIDTH : 0] wrusedw ,  // Write Used Words
     output [DATA_WIDTH-1 : 0] q      // Output data     
     ) ;

   // Internal parameter to indicate to altsyncram if the RAM output register 
   // is used or not.   
   localparam                   OUTDATA_REG_B = (USE_RAM_OUTPUT_REGISTER == 1) ? 
                               "CLOCK1" : "UNREGISTERED" ;
   
   // Pointers are an extra bit wide to differentiate the full case and empty cases
   reg [ADDR_WIDTH:0]          wrptr_b_wr_next ; // Write Pointer Next Value, Binary coded, Write clk 
   reg [ADDR_WIDTH:0]          wrptr_b_wr ;      // Write Pointer, Binary coded, Write clk 
   reg [ADDR_WIDTH:0]          wrptr_g_wr ;      // Write Pointer, Gray coded, Write clk
   reg [ADDR_WIDTH:0]          wrptr_g_rd1 ;     // Write Pointer, Gray coded, Read clk 1st synch register
   reg [ADDR_WIDTH:0]          wrptr_g_rd2 ;     // Write Pointer, Gray coded, Read clk 2nd synch register
   reg [ADDR_WIDTH:0]          wrptr_b_rd_next ; // Write Pointer Next Value, Binary coded, Read Clock
   reg [ADDR_WIDTH:0]          wrptr_b_rd ;      // Write Pointer, Binary coded, Read Clock
   
   reg [ADDR_WIDTH:0]          rdptr_b_rd_next ; // Read Pointer Next Value, Binary coded, Read clk 
   reg [ADDR_WIDTH:0]          rdptr_b_rd ;      // Read Pointer, Binary coded, Read clk 
   reg [ADDR_WIDTH:0]          rdptr_g_rd ;      // Read Pointer, Gray coded, Read clk
   reg [ADDR_WIDTH:0]          rdptr_g_wr1 ;     // Read Pointer, Gray coded, Write clk 1st synch register
   reg [ADDR_WIDTH:0]          rdptr_g_wr2 ;     // Read Pointer, Gray coded, Write clk 2nd synch register
   reg [ADDR_WIDTH:0]          rdptr_b_wr ;      // Read Pointer, Binary coded, Write clk

   reg                         wrreq_allow ;     // Write Request "allowed" ie not full
   reg                         rdvalid_next ;    // Read valid next value

   reg                         rdclocken ;       // Altsyncram read clock enable  
   reg [ADDR_WIDTH-1:0]        rdaddress ;       // Altsyncram read address 
   
   wire [DATA_WIDTH-1:0]       q_ram ;           // Altsyncram data output 
   reg  [DATA_WIDTH-1:0]       q_reg ;           // Alternative output register
   
   //wire [DATA_WIDTH-1:0]       zero_data ;       // constant zero data  

   reg                         ra_held ;         // Read address being held in RAM 
   reg                         ra_held_next ;    // Read address being held in RAM next value

   // Gray coded to Binary coded conversion function 
   function [ADDR_WIDTH:0] gray2bin
     ( input [ADDR_WIDTH:0] gray ) ;
      reg [ADDR_WIDTH:0] temp ;
      integer i ;
      begin
         temp[ADDR_WIDTH] = gray[ADDR_WIDTH] ;
         for (i = (ADDR_WIDTH-1); i >= 0 ; i = i - 1)
           begin
              temp[i] = temp[i+1] ^ gray[i] ;
           end
         gray2bin = temp ;
      end
   endfunction // gray2bin
   
   // Binary coded to Gray coded conversion function 
   function [ADDR_WIDTH:0] bin2gray
     (input [ADDR_WIDTH:0] bin ) ;
      integer i ;
      begin
         bin2gray[ADDR_WIDTH] = bin[ADDR_WIDTH] ;
         for (i = 0 ; i < (ADDR_WIDTH) ; i = i + 1)
           begin
              bin2gray[i] = bin[i+1] ^ bin[i] ;
           end
      end
   endfunction // bin2gray

   //assign                      zero_data = {DATA_WIDTH{1'b0}} ;

   // Determine if it is okay to allow a read and calculate the
   // next values of the rd pointer as needed
   always @(rdptr_b_rd,wrptr_b_rd,rdreq,ra_held)
     begin
        // Read allowed if it is being requested, we are not empty and
        // the read address has not been held
        if ( (rdreq == 1'b1) && (rdptr_b_rd != wrptr_b_rd) && (ra_held == 1'b0) )
          begin
             // Read allowed
             rdptr_b_rd_next = rdptr_b_rd + 1'b1 ;
             rdvalid_next = 1'b1 ;
          end
        else
          begin
             // Read NOT requested or NOT allowed
             rdptr_b_rd_next = rdptr_b_rd ;
             rdvalid_next = 1'b0 ;
          end // else: !if( (rdreq == 1'b1) && (rdptr_b_rd != wrptr_b_rd) && (ra_held == 1'b0) )
     end // always @ (rdptr_b_rd,wrptr_b_rd,rdreq,ra_held)

   // Compute the next value of the wrptr, in binary, in the
   // read domain...
   always @(wrptr_b_wr,wrptr_g_rd2)
     begin
        if (COMMON_CLOCK == 1)
          begin
             // Common clock it is just the same value, but we still need a delay
             // cycle so we can account for the flow through time of the RAM.
             wrptr_b_rd_next  = wrptr_b_wr ;
          end
        else
          begin
             wrptr_b_rd_next = gray2bin(wrptr_g_rd2) ;
          end
     end // always @ (wrptr_b_wr,wrptr_g_rd2)
           
   // Manage all of the pointers in the read clock domain
   always @(posedge rdclk or posedge aclr)
     begin
        if (aclr)
          begin
             rdptr_b_rd  <= {ADDR_WIDTH{1'b0}} ;
             rdptr_g_rd  <= {ADDR_WIDTH{1'b0}} ;
             wrptr_g_rd1 <= {ADDR_WIDTH{1'b0}} ;
             wrptr_g_rd2 <= {ADDR_WIDTH{1'b0}} ;
             wrptr_b_rd  <= {ADDR_WIDTH{1'b0}} ;
             rdusedw     <= {ADDR_WIDTH{1'b0}} ;
             rdempty     <= 1'b1 ;
             rdvalid     <= 1'b0 ;
          end // if (aclr)
        else
          begin
             rdptr_b_rd <= rdptr_b_rd_next ;

             if (COMMON_CLOCK == 1)
               begin
                  // Eliminate all of these registers if using a common clock
                  rdptr_g_rd  <= {ADDR_WIDTH{1'b0}} ;
                  wrptr_g_rd1 <= {ADDR_WIDTH{1'b0}} ;
                  wrptr_g_rd2 <= {ADDR_WIDTH{1'b0}} ;
               end
             else
               begin
                  rdptr_g_rd <= bin2gray(rdptr_b_rd) ;
                  wrptr_b_rd <= gray2bin(wrptr_g_rd2) ;
                  wrptr_g_rd2 <= wrptr_g_rd1 ;
                  wrptr_g_rd1 <= wrptr_g_wr ;
               end // else: !if(COMMON_CLOCK == 1)

             // Register the calculated value
             wrptr_b_rd <= wrptr_b_rd_next ;

             // If the Read Address is being held at the last read value then
             // we must be empty by definition. Make sure the usedw and empty flag
             // reflect that
             if (ra_held == 1'b1)
               rdusedw <= {(ADDR_WIDTH+1){1'b0}} ;
             else
               rdusedw <= wrptr_b_rd[ADDR_WIDTH:0] - rdptr_b_rd_next[ADDR_WIDTH:0] ;

             if (wrptr_b_rd == rdptr_b_rd_next)
               rdempty <= 1'b1 ;
             else
               rdempty <= ra_held ;

             rdvalid <= rdvalid_next ;

          end // else: !if(aclr)
     end // always @ (posedge rdclk or posedge aclr)
   
   // Determine if it is okay to allow a write and calculate the
   // next values of the wr pointer as needed
   always @(rdptr_b_wr,rdptr_b_rd,wrptr_b_wr,wrreq)
     begin
        if (COMMON_CLOCK == 0)
          begin
             if ( (wrreq == 1'b1) && 
                  ( (rdptr_b_wr[ADDR_WIDTH-1:0] != wrptr_b_wr[ADDR_WIDTH-1:0]) ||
                    (rdptr_b_wr[ADDR_WIDTH]     == wrptr_b_wr[ADDR_WIDTH]) ) )
               begin
                  // Write Allowed
                  wrptr_b_wr_next = wrptr_b_wr + 1'b1 ;
                  wrreq_allow = 1'b1 ;
               end
             else
               begin
                  // Write NOT requested or NOT allowed
                  wrptr_b_wr_next = wrptr_b_wr ;
                  wrreq_allow = 1'b0 ;
               end // else: !if( (wrreq == 1'b1) &&...
          end // if (COMMON_CLOCK == 0)
        else
          begin
             // In COMMON_CLOCK mode use the rdptr_b_rd directly to speed 
             // things up and save a register  
             if ( (wrreq == 1'b1) && 
                  ( (rdptr_b_rd[ADDR_WIDTH-1:0] != wrptr_b_wr[ADDR_WIDTH-1:0]) ||
                    (rdptr_b_rd[ADDR_WIDTH]     == wrptr_b_wr[ADDR_WIDTH]) ) )
               begin
                  // Write Allowed
                  wrptr_b_wr_next = wrptr_b_wr + 1'b1 ;
                  wrreq_allow = 1'b1 ;
               end
             else
               begin
                  // Write NOT requested or NOT allowed
                  wrptr_b_wr_next = wrptr_b_wr ;
                  wrreq_allow = 1'b0 ;
               end // else: !if( (wrreq == 1'b1) &&...
          end // else: !if(COMMON_CLOCK == 0)
     end // always @ (rdptr_b_wr,rdptr_b_rd,wrptr_b_wr,wrreq)

   // Manage all of the pointers in the write clock domain
   always @(posedge wrclk or posedge aclr)
     begin
        if (aclr)
          begin
             wrptr_b_wr  <= {ADDR_WIDTH{1'b0}} ;
             wrptr_g_wr  <= {ADDR_WIDTH{1'b0}} ;
             rdptr_g_wr1 <= {ADDR_WIDTH{1'b0}} ;
             rdptr_g_wr2 <= {ADDR_WIDTH{1'b0}} ;
             rdptr_b_wr  <= {ADDR_WIDTH{1'b0}} ;
             wrusedw     <= {ADDR_WIDTH{1'b0}} ;
             wrfull      <= 1'b0 ;
          end
        else
          begin
             wrptr_b_wr <= wrptr_b_wr_next ;

             if (COMMON_CLOCK == 1)
               begin
                  // Zero all of these out so they are
                  // sure to be optimized
                  wrptr_g_wr  <= {ADDR_WIDTH{1'b0}} ;
                  rdptr_g_wr1 <= {ADDR_WIDTH{1'b0}} ;
                  rdptr_g_wr2 <= {ADDR_WIDTH{1'b0}} ;
                  rdptr_b_wr  <= {ADDR_WIDTH{1'b0}} ;

                  // Use the same rdptr_b_rd so we know as quickly as possible when
                  // the space is free and save the register
                  wrusedw <= wrptr_b_wr_next[ADDR_WIDTH:0] - rdptr_b_rd[ADDR_WIDTH:0] ;

                  // Determine if we will be full next cycle 
                  if ( (rdptr_b_rd[ADDR_WIDTH-1:0] == wrptr_b_wr_next[ADDR_WIDTH-1:0]) &&
                       (rdptr_b_rd[ADDR_WIDTH] != wrptr_b_wr_next[ADDR_WIDTH]) )
                    wrfull <= 1'b1 ;
                  else
                    wrfull <= 1'b0 ;
               end // if (COMMON_CLOCK == 1)
             else
               begin
                  wrptr_g_wr  <= bin2gray(wrptr_b_wr) ;
                  rdptr_b_wr  <= gray2bin(rdptr_g_wr2) ;
                  rdptr_g_wr2 <= rdptr_g_wr1 ;
                  rdptr_g_wr1 <= rdptr_g_rd ;
 
                  
                  wrusedw <= wrptr_b_wr_next[ADDR_WIDTH:0] - rdptr_b_wr[ADDR_WIDTH:0] ;

                  // Determine if we will be full next cycle 
                  if ( (rdptr_b_wr[ADDR_WIDTH-1:0] == wrptr_b_wr_next[ADDR_WIDTH-1:0]) &&
                       (rdptr_b_wr[ADDR_WIDTH] != wrptr_b_wr_next[ADDR_WIDTH]) )
                    wrfull <= 1'b1 ;
                  else
                    wrfull <= 1'b0 ;
               end // else: !if(COMMON_CLOCK == 1)
             
          end // else: !if(aclr)
     end // always @ (posedge wrclk or posedge aclr)

   // This is a manually instantiated output register that is only used if we are not
   // using the built-in RAM Output Register.
   always @(posedge rdclk)
     begin
        if (rdvalid_next)
          q_reg <= q_ram ;
        else
          q_reg <= q_reg ;
     end // always @ (posedge rdclk or posedge aclr)

   // Decide which registered output to use.
   assign q = (USE_RAM_OUTPUT_REGISTER == 1) ? q_ram : q_reg ;

   // The altsyncram implementation has this annoying little feature of a
   // latch on the output of the SRAM array that is controlled by the
   // read clock enable line. This prevents us from simply controlling the
   // read clock enable via the allowed rdreq signal.
   // Consider the following case where we read data from location 10 in
   // the RAM which is the last word in the FIFO. Much later data is
   // written to location 11. Much later after that a RDREQ is done.
   // The values held in various locations are
   //
   // Control Signals       RAM     RAM LOC  RAM OUT  Ram Out  
   // WRREQ RDREQ RDCLOCKEN RDADDR  '11'     Latch    Register 
   //   0     1       1      10     D11Old   D10      D9
   //   0     0       0      11     D11Old   D11Old   D10  
   //   0     0       0      11     D11Old   D11Old   D10  
   //   0     0       0      11     D11Old   D11Old   D10  
   //   0     0       0      11     D11Old   D11Old   D10
   //   1     0       0      11     D11Old   D11Old   D10
   //   0     0       0      11     D11New   D11Old   D10
   //   0     0       0      11     D11New   D11Old   D10
   //   0     0       0      11     D11New   D11Old   D10
   //   0     0       0      11     D11New   D11Old   D10
   //   0     1       1      11     D11New   D11Old   D10
   //   0     0       0      12     D11New   D12      D11Old << Bad
   //
   // If that annoying latch was not there or always enabled then the
   // D11New would flow to the output register making this work very
   // simply.
   //
   // Instead what we need to do is the following...
   //
   // Control Signals       RAM     RAM LOC  RAM OUT  Ram Out    
   // WRREQ RDREQ RDCLOCKEN RDADDR  '11'     Latch    Register  RA Held 
   //   0     1       1      10     D11Old   D10      D9           0
   //   0     0       0      10     D11Old   D10      D10          1   (Hold because going to be empty)
   //   0     0       0      10     D11Old   D10      D10          1
   //   0     0       0      10     D11Old   D10      D10          1
   //   0     0       0      10     D11Old   D10      D10          1
   //   1     0       0      10     D11Old   D10      D10          1
   //   0     0       0      10     D11New   D10      D10          1
   //   0     0       0      10     D11New   D10      D10          0   (Un-hold because going to be non-empty)
   //   0     0       0      11     D11New   D11New   D10          0
   //   0     0       0      11     D11New   D11New   D10          0
   //   0     1       1      11     D11New   D11New   D10          0
   //   0     0       0      ??     D11New   ???      D11New       ?   (Values depend on empty or not)
   //
 
   // Read Address Held Register 
   always @(posedge rdclk or posedge aclr)
     begin
        if (aclr)
          ra_held <= 1'b1 ;
        else
          ra_held <= ra_held_next ;
     end
   
   // Calculate the values of the RAM rdaddress input, Ram Address Held next
   // and the rdclocken input 
   always @(wrptr_b_rd,rdptr_b_rd,rdptr_b_rd_next,rdvalid_next,ra_held)
     begin
        if (USE_RAM_OUTPUT_REGISTER == 1)
          begin
             // Using the RAM Output register, first determine if we are reading
             // this cycle or not...
             if (rdvalid_next == 1'b1)
               begin
                  // We are reading this cycle determine if a read is possible
                  // next cycle or not and set address appropriately
                  if (wrptr_b_rd == rdptr_b_rd_next)
                    begin
                       // No way to read next cycle, have to hold the address
                       rdaddress = rdptr_b_rd[ADDR_WIDTH-1:0] ;
                       ra_held_next = 1'b1 ;
                    end
                  else
                    begin
                       // Possible to read next cycle let in the new address
                       rdaddress = rdptr_b_rd_next[ADDR_WIDTH-1:0] ;
                       ra_held_next = 1'b0 ;
                    end // else: !if(wrptr_b_rd == rdptr_b_rd_next)
                  // Reading, so we need to clockenable the RAM 
                  rdclocken = 1'b1 ;
               end // if (rdvalid_next == 1'b1)
             else
               begin
                  // We are not reading this cycle..
                  // Determine if the FIFO has been written to recently and if we
                  // have been holding the old address or not.
                  if ( (wrptr_b_rd != rdptr_b_rd) &&
                       (ra_held == 1'b1) )
                    begin
                       // We were holding the old address and now the wrptr is moving
                       // up so we need to clock in the new rdptr address
                       // The current address in the RAM Address Register, so we
                       // can clock enable things knowing we will get the same data
                       // back into the output register again
                       ra_held_next = 1'b0 ;
                       rdaddress = rdptr_b_rd_next[ADDR_WIDTH-1:0] ;
                       rdclocken = 1'b1 ;
                    end // if ( (wrptr_b_rd != rdptr_b_rd) &&...
                  else
                    begin
                       // Otherwise keep things as they are
                       ra_held_next = ra_held ;
                       rdaddress = rdptr_b_rd_next[ADDR_WIDTH-1:0] ;
                       rdclocken = 1'b0 ;
                    end // else: !if( (wrptr_b_rd != rdptr_b_rd) &&...
               end // else: !if(rdvalid_next == 1'b1)
          end // if (USE_RAM_OUTPUT_REGISTER == 1)
        else
          begin
             // Not using the RAM output register, life is much simpler...
             // Always use the new address and clock enable the RAM.
             // We control the clock enable on the output register directly
             rdaddress    = rdptr_b_rd_next[ADDR_WIDTH-1:0] ;
             rdclocken    = 1'b1 ;
             ra_held_next = 1'b0 ;
          end // else: !if(USE_RAM_OUTPUT_REGISTER == 1)
     end // always @ (wrptr_b_rd,rdptr_b_rd,rdptr_b_rd_next,rdvalid_next,ra_held)

   // This is the actual RAM storage for the FIFO
   altsyncram fifo_ram 
     (
	  .wren_a(wrreq_allow),
      .wren_b(1'b0),
      .rden_b(1'b1),
      .data_a(data),
      .data_b(),
      .address_a(wrptr_b_wr[ADDR_WIDTH-1:0]),
      .address_b(rdaddress),
	  .clock0 (wrclk),
	  .clock1 (rdclk),
      .clocken0(1'b1),
      .clocken1(rdclocken),
      .aclr0(),
      .aclr1(),
      .addressstall_a(),
      .addressstall_b(),
      .byteena_a(),
      .byteena_b(),
      .q_a(),
	  .q_b(q_ram)
      );
	defparam
		fifo_ram.intended_device_family = "Stratix",
		fifo_ram.operation_mode = "DUAL_PORT",
		fifo_ram.width_a = DATA_WIDTH,
		fifo_ram.widthad_a = ADDR_WIDTH,
		fifo_ram.numwords_a = (1<<ADDR_WIDTH),
		fifo_ram.width_b = DATA_WIDTH,
		fifo_ram.widthad_b = ADDR_WIDTH,
		fifo_ram.numwords_b = (1<<ADDR_WIDTH),
		fifo_ram.lpm_type = "altsyncram",
		fifo_ram.width_byteena_a = 1,
		fifo_ram.outdata_reg_b = OUTDATA_REG_B,
		fifo_ram.indata_aclr_a = "NONE",
		fifo_ram.wrcontrol_aclr_a = "NONE",
		fifo_ram.address_aclr_a = "NONE",
		fifo_ram.address_reg_b = "CLOCK1",
		fifo_ram.address_aclr_b = "NONE",
		fifo_ram.outdata_aclr_b = "NONE",
		fifo_ram.ram_block_type = "AUTO";
   

endmodule // altpciav_lite_fifo

     
