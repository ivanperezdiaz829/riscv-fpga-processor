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


// /**
//  * This Verilog HDL file is used for simulation and synthesis in
//  * the chaining DMA design example. It could be used by the software
//  * application (Root Port) to retrieve the DMA Performance counter values
//  * and performs single DWORD read and write to the Endpoint memory by
//  * bypassing the DMA engines.
//  */
// synthesis translate_off
`define PCIE_SIM         TRUE
//-----------------------------------------------------------------------------
// TLP Packet constant
`define TLP_FMT_4DW_W        2'b11    // TLP FMT field  -> 64 bits Write
`define TLP_FMT_3DW_W        2'b10    // TLP FMT field  -> 32 bits Write
`define TLP_FMT_4DW_R        2'b01    // TLP FMT field  -> 64 bits Read
`define TLP_FMT_3DW_R        2'b00    // TLP FMT field  -> 32 bits Read

`define TLP_FMT_CPL          2'b00    // TLP FMT field  -> Completion w/o data
`define TLP_FMT_CPLD         2'b10    // TLP FMT field  -> Completion with data

`define TLP_TYPE_WRITE       5'b00000 // TLP Type field -> write
`define TLP_TYPE_READ        5'b00000 // TLP Type field -> read
`define TLP_TYPE_READ_LOCKED 5'b00001 // TLP Type field -> read_lock
`define TLP_TYPE_CPLD        5'b01010 // TLP Type field -> Completion with data
`define TLP_TYPE_IO          5'b00010 // TLP Type field -> IO

`define TLP_TC_DEFAULT       3'b000   // Default TC of the TLP
`define TLP_TD_DEFAULT       1'b0     // Default TD of the TLP
`define TLP_EP_DEFAULT       1'b0     // Default EP of the TLP
`define TLP_ATTR_DEFAULT     2'b0     // Default EP of the TLP

`define RESERVED_1BIT        1'b0     // reserved bit on 1 bit
`define RESERVED_2BIT        2'b00    // reserved bit on 1 bit
`define RESERVED_3BIT        3'b000   // reserved bit on 1 bit
`define RESERVED_4BIT        4'b0000  // reserved bit on 1 bit

`define EP_ADDR_READ_OFFSET  16
`define TRANSACTION_ID       3'b000

`define ZERO_QWORD           64'h0000_0000_0000_0000
`define ZERO_DWORD           32'h0000_0000
`define ZERO_WORD            16'h0000
`define ZERO_BYTE            8'h00

`define ONE_QWORD            64'h0000_0000_0000_0001
`define ONE_DWORD            32'h0000_0001
`define ONE_WORD             16'h0001
`define ONE_BYTE             8'h01

`define MINUS_ONE_QWORD      64'hFFFF_FFFF_FFFF_FFFF
`define MINUS_ONE_DWORD      32'hFFFF_FFFF
`define MINUS_ONE_WORD       16'hFFFF
`define MINUS_ONE_BYTE       8'hFF

`define DIRECTION_WRITE      1
`define DIRECTION_READ       0


`timescale 1ns / 1ps
// synthesis translate_on
// synthesis verilog_input_version verilog_2001
// turn off superfluous verilog processor warnings
// altera message_level Level1
// altera message_off 10034 10035 10036 10037 10230 10240 10030
//


// packet header bits
`define FMT_BIT0      125
`define LENGTH        105:96
`define ADDR32_BIT2   98      // 34
`define ADDR64_BIT2   66      // 2
`define TD            111
`define TYPE_BIT0     120
`define PAYLD         126

module altpcierd_cdma_ecrc_gen_ctl_64   (clk, rstn, user_rd_req, user_sop, user_eop, user_data,
 user_valid, crc_empty, crc_sop, crc_eop, crc_data, crc_valid, tx_sop, tx_eop,
 tx_data, tx_valid, tx_crc_location, tx_shift, av_st_ready);

   input              clk;
   input              rstn;

   // user data (avalon-st formatted)
   output             user_rd_req;          // request for next user_data
   input              user_sop;             // means this cycle contains the start of a packet
   input[1:0]         user_eop;             // means this cycle contains the end of a packet
   input[127:0]       user_data;           // avalon streaming packet data
   input              user_valid;           // means user_sop, user_eop, user_data are valid

   // to CRC module (packed)
   output[3:0]        crc_empty;            // indicates which DWs in crc_data are valid (1'b0) -- indicates where end of pkt is
   output             crc_sop;              // means this cycle contains the start of a packet
   output             crc_eop;              // means this cycle contains the end of a packet
   output[127:0]      crc_data;             // packet data formatted for the CRC module
   output             crc_valid;            // means crc_sop, crc_eop, crc_data, crc_empty are valid

   // main datapath (avalon-st formatted)
   output             tx_sop;               // start of pkt flag for transmission
   output[1:0]        tx_eop;               // end of pkt flag for transmission
   output[127:0]      tx_data;              // avalon-ST packet data for transmission
   output             tx_valid;             // means tx_sop, tx_eop, tx_data are valid
   output             tx_shift;
   output[3:0]        tx_crc_location;        // indicates which DW to insert the CRC field

   input              av_st_ready;           // avalon-st ready input - throttles datapath

   reg             tx_sop;
   reg[1:0]        tx_eop;
   reg[127:0]      tx_data;
   reg             tx_valid;
   reg             tx_shift;
   reg             crc_sop;
   reg             crc_eop;
   reg             crc_valid;
   reg[3:0]        crc_empty;
   reg[3:0]        tx_crc_location;
   reg             tx_insert_crc_cyc;
   reg             send_to_crc_appended;    // send data to CRC with 1DW from next cycle inserted into last DW of this cycle
   reg             send_to_crc_as_is;       // send data to CRC unmodified
   reg             send_to_crc_shifted;     // send data to CRC with the 3DW's of this cycle shifted up 1DW, and 1DW from
   reg[9:0]        tx_rem_length;

   wire            user_rd_req;

   reg[2:0]        state;
   reg[127:0]      user_data_masked_del;
   wire[127:0]     user_data_masked;
   reg [9:0]       user_data_length;
   reg             need_insert_crc_cyc;
   wire[127:0]     user_data_masked_swizzled;
   reg[9:0]        crc_rem_length;
   reg             deferred_valid;
   reg             inhibit_read;

   reg             debug_is_aligned;
   reg             debug_is_3dw;
   reg             user_last_was_sop;
   reg             user_is_4dw;
   wire            user_is_3dW_nonaligned;
   reg             user_has_payld;
   wire            tx_digest;
   reg             tx_digest_reg;
   reg             insert_ecrc_in_hi;

   // assign user_data_length = user_data[`LENGTH];

   // state machine states
   localparam WAIT_SOP         = 3'h0;   // wait for the start of a pkt
   localparam WAIT_SOP2        = 3'h1;
   localparam SEND_PACKED_DATA = 3'h2;   // header and data DWs are noncontiguous (3DW Hdr Aligned, or 4DW Hdr NonAligned).. need to shift data
   localparam SEND_DATA        = 3'h3;   // header and data are noncontiguous -- send data thru as-is
   localparam EXTRA_CRC_CYC    = 3'h4;


          /*   ECRC asserts user_rd_req when it processes user_data.

               case[1] tx_st_ready_ecrc deasserts when tx_st_valid_int=1

                   ECRC Interface:
                                        ________     ________________
                       user_rd_req (ack)        |___|
                                             ________________________
                       user_valid       ____|
                                        ______________________________
                       user_data        ____|_0_|_1_____|_2_|_3_|_4_|_


               case[2] user_rd_req deasserts when tx_st_valid_int=0

                   ECRC Interface:
                                        ________     ________________
                       user_rd_req (ack)        |___|
                                             ___         ____________
                       user_valid       ____|   |_______|
                                        ______________________________
                       user_data        ____|_0_|_x_____|_1_|_2_|_3_|_
          */

   //////////////////////////////////////////////////////////////////////
   // Main Datapath
   //

   // Append digest to all packets except CFG0
   assign tx_digest = ((user_sop==1'b1) & (tx_insert_crc_cyc==1'b0)) ? (user_data[122:120]!=3'b100) : tx_digest_reg;

   always @ (posedge clk or negedge rstn) begin
       if (rstn==1'b0) begin
           tx_sop          <= 1'b0;
           tx_eop          <= 2'h0;
           tx_data         <= 128'h0;
           tx_valid        <= 1'b0;
           tx_shift        <= 1'b0;
           tx_digest_reg   <= 1'b0;
       end
       else begin
           tx_digest_reg <= tx_digest;
           if (tx_digest==1'b1) begin
               tx_sop             <= (tx_insert_crc_cyc==1'b1) ? 1'b0 : ((user_valid==1'b1) ? ((user_sop==1'b1) ? 1'b1 : 1'b0 ) : 1'b0);
               tx_eop             <= (tx_insert_crc_cyc==1'b1) ? 2'h0 : ((user_valid==1'b1) ? ((user_eop[1]==1'b1)? 1'b1 : 1'b0 ): 2'h0);
               tx_data[127:`TD+1] <= user_data[127:`TD+1];
               tx_data[`TD]       <= (user_sop==1'b1) ? 1'b1 : ((user_data[`TD]==1'b1) ? 1'b1 : 1'b0);  // set the digest bit
               tx_data[`TD-1:0]   <= user_data[`TD-1:0];
               tx_shift           <= (av_st_ready==1'b1);
               tx_valid           <= (av_st_ready==1'b1) & ((user_valid==1'b1) | (tx_insert_crc_cyc==1'b1));
           end
           else begin
               tx_sop             <= (user_valid==1'b1) ? ((user_sop==1'b1) ? 1'b1 : 1'b0) : 1'b0;
               tx_eop             <= (user_valid==1'b1) ? user_eop : tx_eop;
               tx_data            <= user_data;
               tx_shift           <= (av_st_ready==1'b1) ? 1'b1 : 1'b0;
               tx_valid           <= ((av_st_ready==1'b1) & (user_valid==1'b1))  ? 1'b1 : 1'b0;
           end
       end

   end




   //////////////////////////////////////////////////////////////////////
   // Input Data stream throttle control.
   //    Throttle when:
   //         - Avalon-ST throttles
   //         - Need to insert a cycle to account for CRC insertion

   assign user_rd_req = (av_st_ready==1'b1) & (inhibit_read ==1'b0);



   //////////////////////////////////////////////////////////////////////
   // CRC Data Mux
   // The user_data input stream can contain DW gaps depending
   // on the Header type (3DW/4DW), and the address alignment.
   // This mux reformats the data so that there are no gaps because
   // the CRC module requires contiguous DWs.
   //     This mux selects between:
   //         - Unmodified data format
   //         - Append DW from next data cycle, Without shifting current data
   //         - Append DW from next data cycle, And shift current data up 1DW


   assign user_data_masked[127:121] = user_data[127:121];
   assign user_data_masked[120]     = (user_sop==1'b1) ? 1'b1 : user_data[120];    // TYP[0]
   assign user_data_masked[119:112] = user_data[119:112];
   assign user_data_masked[111]     = (user_sop==1'b1) ? 1'b1 : user_data[111];    // TD
   assign user_data_masked[110]     = (user_sop==1'b1) ? 1'b1 : user_data[110];    // EP
   assign user_data_masked[109:0]   = user_data[109:0];

   assign user_is_3dW_nonaligned = (user_is_4dw==1'b0) &  (user_data[`ADDR32_BIT2]==1'b1);

   // reformat the data-phase portion of the input data to reverse the byte ordering.
   // left-most byte is first on line.
   assign user_data_masked_swizzled [127:64]=
              (user_sop==1'b1) ? user_data_masked[127:64] :                 // First 64 bits of descriptor phase
              ((user_last_was_sop==1'b1) & (user_is_3dW_nonaligned==1'b1) ) ? {user_data_masked[127:96], user_data_masked[71:64], user_data_masked[79:72], user_data_masked[87:80],user_data_masked[95:88]}: // 3DW Hdr Nonaligned - User data contains Header and Data phases
              (user_last_was_sop==1'b1) ? user_data_masked[127:64] :
                   {user_data_masked[103:96], user_data_masked[111:104], user_data_masked[119:112],user_data_masked[127:120],
                    user_data_masked[71:64], user_data_masked[79:72], user_data_masked[87:80],user_data_masked[95:88] }; // User data contains only Data phase

   assign user_data_masked_swizzled [63:0]= 64'h0;

   always @ (posedge clk) begin
       if (user_valid) begin
           user_data_masked_del <= user_data_masked_swizzled;
       end
   end

   assign crc_data[127:64] = (send_to_crc_appended==1'b1) ? {user_data_masked_del[127:96], user_data_masked_swizzled[127:96]} :
                             (send_to_crc_shifted==1'b1)  ? {user_data_masked_del[95:64], user_data_masked_swizzled[127:96]}   : user_data_masked_del[127:64] ;

   assign crc_data[63:0] = 64'h0;

   ////////////////////////////////////////////////
   // CRC Control
   // Generates
   //      - CRC Avalon-ST control signals
   //      - CRC Data Mux select controls

   always @ (posedge clk or negedge rstn) begin
       if (rstn==1'b0) begin
           state                <= WAIT_SOP;
           crc_sop              <= 1'b0;
           crc_eop              <= 1'b0;
           crc_valid            <= 1'b0;
           tx_insert_crc_cyc    <= 1'b0;
           send_to_crc_appended <= 1'b0;
           send_to_crc_as_is    <= 1'b0;
           send_to_crc_shifted  <= 1'b0;
           tx_rem_length        <= 10'h0;
           crc_rem_length       <= 10'h0;
           crc_empty            <= 4'h0;
           tx_crc_location      <= 4'b0000;
           insert_ecrc_in_hi    <= 1'b0;
           deferred_valid       <= 1'b0;
           inhibit_read         <= 1'b0;
           debug_is_aligned     <= 1'b0;
           debug_is_3dw         <= 1'b0;
           user_last_was_sop     <= 1'b0;
           user_is_4dw          <= 1'b0;
           user_data_length      <= 10'h0;
           user_has_payld         <= 1'b0;
       end
       else begin
           crc_valid         <= 1'b0;    // default

         if (av_st_ready==1'b1) begin
           user_last_was_sop <= (user_sop==1'b1) &  (user_valid==1'b1);
           crc_empty         <= 4'h0;    // default
           crc_eop           <= 1'b0;    // default
           crc_sop           <= 1'b0;    // default
           case (state)
               WAIT_SOP: begin
                   crc_valid         <= 1'b0;    // default
                   tx_crc_location   <= 4'b0000; // default
                   crc_empty         <= 4'h0;    // default
                   crc_eop           <= 1'b0;    // default
                   crc_sop           <= 1'b0;    // default
                   tx_insert_crc_cyc <= 1'b0;    // default
                   tx_crc_location   <= 4'b0000;
                   insert_ecrc_in_hi <= 1'b0;    // default
                   debug_is_3dw      <= (user_data[`FMT_BIT0]==1'b0);
                   if ((user_sop==1'b1) &  (user_valid==1'b1)) begin
                       crc_sop           <= 1'b1;
                       crc_valid         <= 1'b1;
                       deferred_valid    <= 1'b0;
                       user_is_4dw       <= (user_data[`FMT_BIT0]==1'b1);
                       user_data_length  <= user_data[`LENGTH];
                       user_has_payld    <= user_data[`PAYLD];
                       send_to_crc_as_is <= 1'b1;
                       send_to_crc_appended <= 1'b0;
                       send_to_crc_shifted  <= 1'b0;
                       state                <= WAIT_SOP2;
                   end
               end
               WAIT_SOP2: begin
                   if (user_valid==1'b1 ) begin

                       crc_valid        <= 1'b1;
                       debug_is_aligned <= (user_is_4dw==1'b0) ? (user_data[`ADDR32_BIT2]==1'b0) : (user_data[`ADDR64_BIT2]==1'b0);
                       if (user_is_4dw==1'b1) begin                                 // 4DW HEADER
                           crc_empty             <= 4'h0;
                           tx_crc_location       <= 4'b0000;
                           send_to_crc_as_is     <= 1'b1;
                           send_to_crc_appended  <= 1'b0;
                           send_to_crc_shifted   <= 1'b0;
                           if (user_eop[1]==1'b1) begin                             // this is a single-cycle pkt
                               tx_insert_crc_cyc <= 1'b1;
                               inhibit_read      <= 1'b1;
                               state             <= EXTRA_CRC_CYC;
                               crc_eop           <= 1'b1;
                               insert_ecrc_in_hi <= (user_data[`ADDR64_BIT2]==1'b1) ? 1'b1 : 1'b0;  // nonaligned/aligned addr
                           end
                           else begin                                                       // this is a multi-cycle pkt
                               if (user_data[`ADDR64_BIT2]==1'b1) begin                     // NonAligned Address -- will need to shift data phases
                                   need_insert_crc_cyc <= (user_data_length[3:2] == 2'h3);  // tx_data is 128bit aligned
                                   state               <= SEND_PACKED_DATA;
                                   tx_rem_length       <= user_data_length +1;            // account for empty DW from non-alignment
                                   crc_rem_length      <= user_data_length;
                               end
                               else begin                                                   // Aligned Address -- send data phases without shifting
                                   state          <= SEND_DATA;
                                   tx_rem_length  <= user_data_length;
                                   crc_rem_length <= user_data_length;
                               end
                           end
                       end
                       else if (user_is_4dw==1'b0) begin                             // 3DW HEADER
                           if (user_eop[1]==1'b1) begin                               // this is a single-cycle pkt
                              send_to_crc_as_is     <= 1'b1;
                              send_to_crc_appended  <= 1'b0;
                              send_to_crc_shifted   <= 1'b0;
                              crc_eop               <= 1'b1;
                              if  (user_has_payld==1'h0) begin                     // no payld
                                  if (user_data[`ADDR32_BIT2]==1'b1) begin            // non-aligned
                                      crc_empty          <= 4'h4;
                                      tx_crc_location    <= 4'b0010;
                                      tx_insert_crc_cyc  <= 1'b0;
                                      state              <= WAIT_SOP;
                                  end
                                  else begin                                         // Aligned address
                                      crc_empty          <= 4'h4;
                                      tx_crc_location    <= 4'b0000;
                                      tx_insert_crc_cyc  <= 1'b1;
                                      inhibit_read       <= 1'b1;
                                      state              <=  EXTRA_CRC_CYC;
                                  end
                              end
                              else begin                                              // 1DW payld, Non-Aligned
                                  crc_empty          <= 4'h0;
                                  tx_crc_location    <= 4'b0000;
                                  tx_insert_crc_cyc  <= 1'b1;
                                  inhibit_read       <= 1'b1;
                                  state              <=  EXTRA_CRC_CYC;
                              end
                           end
                           else begin                                                // this is a multi-cycle pkt
                              crc_empty  <= 4'h0;
                              tx_crc_location <= 4'b0000;
                              if (user_data[`ADDR32_BIT2]==1'b1) begin               // NonAligned address
                                 state                 <= SEND_DATA;
                                 send_to_crc_as_is     <= 1'b1;
                                 send_to_crc_appended  <= 1'b0;
                                 send_to_crc_shifted   <= 1'b0;
                                 tx_rem_length         <= user_data_length -1;
                                 crc_rem_length        <= user_data_length-1;
                              end
                              else begin                                             // Aligned address
                                 send_to_crc_as_is     <= 1'b0;
                                 send_to_crc_appended  <= 1'b1;
                                 send_to_crc_shifted   <= 1'b0;
                                 crc_eop               <= (user_data_length==10'h1);   // special case:  3DW header, 1DW payload .. This will be the last CRC cycle
                                 state                 <= SEND_PACKED_DATA;
                                 tx_rem_length         <= user_data_length;            // no data on this txdata cycle (3DW aligned)
                                 crc_rem_length        <= user_data_length-1;
                              end
                           end
                      end   // end 3DW Header
                  end  // end sop
               end
               SEND_PACKED_DATA: begin
                   send_to_crc_as_is     <= 1'b0;
                   send_to_crc_appended  <= 1'b0;
                   send_to_crc_shifted   <= 1'b1;
                   tx_crc_location       <= 4'b0000; // default
                   crc_empty             <= 4'h0;    // default
                   crc_valid             <= (user_valid==1'b1) & (crc_rem_length[9:0]!=10'h0);
                   if (user_valid==1'b1) begin
                       if (user_eop[1]==1'b0) begin
                           tx_rem_length   <= tx_rem_length - 10'h2;
                           crc_rem_length  <= crc_rem_length - 10'h2;
                           state           <= state;
                           crc_empty       <= 4'h0;
                           tx_crc_location <= 4'b0000;
                           crc_eop         <= (crc_rem_length < 10'h3);      // should separate the crc and tx equations.
                       end
                       else begin                                            // this is the last cycle
                           tx_insert_crc_cyc <= (tx_rem_length[2:0]==3'h2);
                           inhibit_read      <= (tx_rem_length[2:0]==3'h2);
                           state             <= (tx_rem_length[2:0]==3'h2) ? EXTRA_CRC_CYC : WAIT_SOP;
                           crc_eop           <= (crc_rem_length[2:0]!=3'h0);
                           case (crc_rem_length[2:0])
                               3'h2:     crc_empty <= 4'h0;
                               3'h1:     crc_empty <= 4'h4;
                               default:  crc_empty <= 4'h0;
                           endcase
                           case (tx_rem_length[2:0])
                               3'h2:    tx_crc_location <= 4'b0000;
                               3'h1:    tx_crc_location <= 4'b0010;
                               default: tx_crc_location <= 4'b0000;
                           endcase
                       end
                   end
               end
               SEND_DATA: begin
                   send_to_crc_as_is     <= 1'b1;
                   send_to_crc_appended  <= 1'b0;
                   send_to_crc_shifted   <= 1'b0;
                   tx_crc_location       <= 4'b0000; // default
                   crc_empty             <= 4'h0;    // default
                   crc_valid             <= (user_valid==1'b1) & (crc_rem_length[9:0]!=10'h0);
                   if (user_valid==1'b1) begin
                      if (user_eop[1]==1'b0) begin
                           tx_rem_length   <= tx_rem_length - 10'h2;
                           crc_rem_length  <= crc_rem_length - 10'h2;
                           state           <= state;
                           crc_empty       <= 4'h0;
                           tx_crc_location <= 4'b0000;
                           crc_eop         <= (crc_rem_length < 10'h3);    // should separate the crc and tx equations.
                       end
                       else begin                                                  // this is the last cycle
                           tx_insert_crc_cyc <= (tx_rem_length[2:0]==3'h2);
                           inhibit_read      <= (tx_rem_length[2:0]==3'h2);
                           state             <= (tx_rem_length[2:0]==3'h2) ? EXTRA_CRC_CYC : WAIT_SOP;
                           crc_eop           <= (crc_rem_length[2:0]!=3'h0);
                           case (crc_rem_length[2:0])
                               3'h2:     crc_empty <= 4'h0;
                               3'h1:     crc_empty <= 4'h4;
                               default:  crc_empty <= 4'h0;
                           endcase
                           case (tx_rem_length[2:0])
                               3'h2:    tx_crc_location <= 4'b0000;
                               3'h1:    tx_crc_location <= 4'b0010;
                               default: tx_crc_location <= 4'b0000;
                           endcase
                       end
                   end
               end
               EXTRA_CRC_CYC: begin
                   deferred_valid <= (user_valid==1'b1) ? 1'b1 : deferred_valid;
                   if (av_st_ready==1'b1) begin
                       inhibit_read      <= 1'b0;
                       tx_insert_crc_cyc <= 1'b0;
                       state             <= WAIT_SOP;
                       tx_crc_location   <= insert_ecrc_in_hi ? 4'b0010 : 4'b0001;
                   end
               end
               default: state <= WAIT_SOP;
           endcase
           end
       end
   end



endmodule
