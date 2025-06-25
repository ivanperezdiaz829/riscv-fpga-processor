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
// Title         : PCI Express BFM Message Logging Common Variable File
// Project       : PCI Express MegaCore function
//-----------------------------------------------------------------------------
// File          : altpcietb_bfm_log_common.v
// Author        : Altera Corporation
//-----------------------------------------------------------------------------
// Description :
// This module is not intended to be instantiated by rather referenced by an
// absolute path from the altpcietb_bfm_log.v include file. This allows all
// users of altpcietb_bfm_log.v to see a common set of values.
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

module altpcietb_bfm_log_common(dummy_out) ;
output dummy_out;

   // Constants for the logging package
   localparam EBFM_MSG_DEBUG = 0;
   localparam EBFM_MSG_INFO = 1;
   localparam EBFM_MSG_WARNING = 2;
   localparam EBFM_MSG_ERROR_INFO = 3; // Preliminary Error Info Message
   localparam EBFM_MSG_ERROR_CONTINUE = 4;
   // Fatal Error Messages always stop the simulation
   localparam EBFM_MSG_ERROR_FATAL = 101;
   localparam EBFM_MSG_ERROR_FATAL_TB_ERR = 102;

   // Maximum Message Length in characters
   localparam EBFM_MSG_MAX_LEN = 100 ;

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


   integer log_file ;

   reg [EBFM_MSG_ERROR_CONTINUE:EBFM_MSG_DEBUG] suppressed_msg_mask ;

   reg [EBFM_MSG_ERROR_CONTINUE:EBFM_MSG_DEBUG] stop_on_msg_mask ;

   initial
     begin
        suppressed_msg_mask = {EBFM_MSG_ERROR_CONTINUE-EBFM_MSG_DEBUG+1{1'b0}} ;
        suppressed_msg_mask[EBFM_MSG_DEBUG] = 1'b1 ;
        stop_on_msg_mask    = {EBFM_MSG_ERROR_CONTINUE-EBFM_MSG_DEBUG+1{1'b0}} ;
     end
endmodule // altpcietb_bfm_log_common
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//      Logic Core:  PCI Express Megacore Function
//         Company:  Altera Corporation.
//                       www.altera.com
//          Author:  IPBU SIO Group
//
//     Description:  Altera PCI Express MegaCore function clk phase alignment
//                   module for S4GX ES silicon
//
// Copyright 2009 Altera Corporation. All rights reserved.  This source code
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
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

`timescale 1 ps / 1 ps
module altpcie_pclk_align
(
rst,
clock,
offset,
onestep,
onestep_dir,
PCLK_Master,
PCLK_Slave,
PhaseUpDown,
PhaseStep,
PhaseDone,
AlignLock,
pcie_sw_in,
pcie_sw_out

);


input rst;
input clock;
input [7:0] offset;
input       onestep;
input       onestep_dir;
input PCLK_Master;
input PCLK_Slave;
input PhaseDone;
output PhaseUpDown;
output PhaseStep;
output AlignLock;
input  pcie_sw_in;
output pcie_sw_out;

reg    PhaseUpDown;
reg    PhaseStep;
reg    AlignLock;


localparam DREG_SIZE = 16;
localparam BIAS_ONE = 1;


reg [3:0] align_sm;
localparam INIT = 0;
localparam EVAL = 1;
localparam ADVC = 2;
localparam DELY = 3;
localparam BACK = 4;
localparam ERR = 5;
localparam DONE = 6;
localparam MNUL = 7;
// debug txt
reg [4 * 8 -1 :0] align_sm_txt;
always@(align_sm)
  case(align_sm)
  INIT: align_sm_txt = "init";
  EVAL: align_sm_txt = "eval";
  ADVC: align_sm_txt = "advc";
  DELY: align_sm_txt = "dely";
  BACK: align_sm_txt = "back";
  ERR: align_sm_txt = "err";
  DONE: align_sm_txt = "done";
  MNUL: align_sm_txt = "mnul";
  endcase


reg [DREG_SIZE-1: 0] delay_reg;
integer              i;
reg                  all_zero;
reg                  all_one;
reg                  chk_req;
wire                 chk_ack;
reg [4:0]            chk_cnt;
reg                  chk_ack_r;
reg                  chk_ack_rr;
reg                  chk_ok;

// controls
reg                  found_zero; // found all zeros
reg                  found_meta; // found metastable region
reg                  found_one; // found all ones
reg [7:0]            window_cnt; // count the number of taps between all zero and all ones
reg                  clr_window_cnt;
reg                  inc_window_cnt;
reg                  dec_window_cnt;
reg                  half_window_cnt;
reg [1:0]            retrain_cnt;
reg                  pcie_sw_r;
reg                  pcie_sw_rr;
reg                  pcie_sw_out;

assign               chk_ack = chk_cnt[4];

always @ (posedge PCLK_Master or posedge rst)
  begin
  if (rst)
    begin
    delay_reg <= {DREG_SIZE{1'b0}};
    all_zero <= 1'b1;
    all_one <= 1'b0;
    chk_cnt <= 0;
    end

  else
    begin
    delay_reg[0] <= PCLK_Slave;
    for (i = 1; i < DREG_SIZE; i = i + 1)
      delay_reg[i] <= delay_reg[i-1];

    // discount the first two flops which are sync flops
    if (chk_cnt == 5'h10)
      begin
      all_zero <= ~|delay_reg[DREG_SIZE-1:2];
      all_one <= &delay_reg[DREG_SIZE-1:2];
      end


    // handshake with slow clock
    if (chk_req & (chk_cnt == 5'h1f))
      chk_cnt <= 0;
    else if (chk_cnt == 5'h1f)
      chk_cnt <= chk_cnt;
    else
      chk_cnt <= chk_cnt + 1;

    end
  end


always @ (posedge clock or posedge rst)
  begin
  if (rst)
    begin
    align_sm <= INIT;
    chk_req <= 0;
    chk_ack_r <= 0;
    chk_ack_rr <= 0;
    chk_ok <= 0;
    found_zero <= 0;
    found_meta <= 0;
    found_one <= 0;
    PhaseUpDown <= 0;
    PhaseStep <= 0;
    window_cnt <= 8'h00;
    clr_window_cnt <= 0;
    inc_window_cnt <= 0;
    dec_window_cnt <= 0;
    half_window_cnt <= 0;
    AlignLock <= 0;
    retrain_cnt <= 0;
    end
  else
    begin

    chk_ack_r <= chk_ack;
    chk_ack_rr <= chk_ack_r;

    if ((chk_ack_rr == 0) & (chk_ack_r == 1))
      chk_ok <= 1;
    else
      chk_ok <= 0;

    if (align_sm == DONE)
      AlignLock <= 1'b1;

    if (clr_window_cnt)
      window_cnt <= offset;
    else if (window_cnt == 8'hff)
      window_cnt <= window_cnt;
    else if (inc_window_cnt)
      window_cnt <=  window_cnt + 1;
    else if (dec_window_cnt & (window_cnt > 0))
      window_cnt <=  window_cnt - 1;
    else if (half_window_cnt)
      window_cnt <= {1'b0,window_cnt[7:1]};

    // limit the number of retrains
    if (retrain_cnt == 2'b11)
      retrain_cnt <= retrain_cnt;
    else if (align_sm == ERR)
      retrain_cnt <= retrain_cnt + 1;

    case (align_sm)

    INIT:
      begin
      chk_req <= 1;
      align_sm <= EVAL;
      clr_window_cnt <= 1;
      end

    EVAL:
      if (chk_ok)
        begin
        chk_req <= 0;
        clr_window_cnt <= 0;
        casex ({found_zero,found_meta,found_one})
        3'b000 : // init case
          begin
          if (all_zero)
            begin
            found_zero <= 1;
            PhaseUpDown <= 0;
            PhaseStep <= 1;
            align_sm <= ADVC;
            end
          else if (all_one)
            begin
            found_one <= 1;
            PhaseUpDown <= 1;
            PhaseStep <= 1;
            align_sm <= DELY;
            end
          else
            begin
            found_meta <= 1;
            PhaseUpDown <= 0;
            PhaseStep <= 1;
            align_sm <= ADVC;
            end
          end

        3'b010 : // metasable, delay till get all zero
          begin
          if (all_zero)
            begin
            found_zero <= 1;
            PhaseUpDown <= 0;
            PhaseStep <= 1;
            align_sm <= ADVC;
            inc_window_cnt <= 1;
            end
          else
            begin
            PhaseUpDown <= 1;
            PhaseStep <= 1;
            align_sm <= DELY;
            end
          end

        3'b110 : // look for all one and compute window
          begin
          if (all_one)
            begin
            found_one <= 1;
            PhaseStep <= 1;
            align_sm <= BACK;
            if (BIAS_ONE)
              begin
              clr_window_cnt <= 1;
              PhaseUpDown <= 0;
              end
            else
              begin
              PhaseUpDown <= 1;
              half_window_cnt <= 1;
              end
            end
          else
            begin
            PhaseUpDown <= 0;
            PhaseStep <= 1;
            align_sm <= ADVC;
            inc_window_cnt <= 1;
            end
          end

        3'b100 : // keep advancing to look for metasable phase
          begin
          PhaseUpDown <= 0;
          PhaseStep <= 1;
          align_sm <= ADVC;
          if (all_zero == 0) // got either metsable or ones and found the window edge
            begin
            found_meta <= 1;
            inc_window_cnt <= 1;
            end
          end

        3'b001 : // keep delaying to look for metasable phase
          begin
          PhaseUpDown <= 1;
          PhaseStep <= 1;
          align_sm <= DELY;
          if (all_one == 0) // got either metsable or ones and found the window edge
            begin
            found_meta <= 1;
            inc_window_cnt <= 1;
            end
          end


        3'b011 : // look for all zero and compute window
          begin
          if (all_zero)
            begin
            found_zero <= 1;
            PhaseStep <= 1;
            PhaseUpDown <= 0;
            align_sm <= BACK;
            if (BIAS_ONE == 0) // if bias to one, go back all the way
              half_window_cnt <= 1;
            else
              inc_window_cnt <= 1;
            end
          else
            begin
            PhaseUpDown <= 1;
            PhaseStep <= 1;
            align_sm <= DELY;
            inc_window_cnt <= 1;
            end
          end

        3'b111 : // middling the setup hold window
          begin
          if (window_cnt > 0)
            begin
            PhaseStep <= 1;
            align_sm <= BACK;
            dec_window_cnt <= 1;
            end
          else
            align_sm <= DONE;

          end

        3'b101 : // error case should never happen
          begin
          align_sm <= ERR;
          clr_window_cnt <= 1;
          found_zero <= 0;
          found_one <= 0;
          found_meta <= 0;
          end

        endcase
        end

    ADVC:
      begin
      inc_window_cnt <= 0;
      if (PhaseDone == 0)
        begin
        PhaseStep <= 0;
        chk_req <= 1;
        align_sm <= EVAL;
        end
      end

    DELY:
      begin
      inc_window_cnt <= 0;
      if (PhaseDone == 0)
        begin
        PhaseStep <= 0;
        chk_req <= 1;
        align_sm <= EVAL;
        end
      end


    BACK:
      begin
      half_window_cnt <= 0;
      dec_window_cnt <= 0;
      inc_window_cnt <= 0;
      clr_window_cnt <= 0;
      if (PhaseDone == 0)
        begin
        PhaseStep <= 0;
        chk_req <= 1;
        align_sm <= EVAL;
        end
      end

    DONE:
      begin
      if (onestep) // manual adjust
        begin
        align_sm <= MNUL;
        PhaseStep <= 1;
        PhaseUpDown <= onestep_dir;
        end
      end

    MNUL:
      if (PhaseDone == 0)
        begin
        PhaseStep <= 0;
        align_sm <= DONE;
        end

    ERR:
      begin
      clr_window_cnt <= 0;
      align_sm <= INIT;
      end

    default:
      align_sm <= INIT;

    endcase
    end
  end

// synchronization for pcie_sw
always @ (posedge PCLK_Master or posedge rst)
  begin
  if (rst)
    begin
    pcie_sw_r <= 0;
    pcie_sw_rr <= 0;
    pcie_sw_out <= 0;
    end
  else
    begin
    pcie_sw_r <= pcie_sw_in;
    pcie_sw_rr <= pcie_sw_r;
    pcie_sw_out <= pcie_sw_rr;
    end
  end
endmodule
`timescale 1 ps / 1 ps
//-----------------------------------------------------------------------------
// Title         : PCI Express BFM Message Logging Common Variable File
// Project       : PCI Express MegaCore function
//-----------------------------------------------------------------------------
// File          : altpcietb_bfm_log_common.v
// Author        : Altera Corporation
//-----------------------------------------------------------------------------
// Description :
// This module is not intended to be instantiated by rather referenced by an
// absolute path from the altpcietb_bfm_log.v include file. This allows all
// users of altpcietb_bfm_log.v to see a common set of values.
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

module altpcietb_bfm_log_common(dummy_out) ;
output dummy_out;

   // Constants for the logging package
   localparam EBFM_MSG_DEBUG = 0;
   localparam EBFM_MSG_INFO = 1;
   localparam EBFM_MSG_WARNING = 2;
   localparam EBFM_MSG_ERROR_INFO = 3; // Preliminary Error Info Message
   localparam EBFM_MSG_ERROR_CONTINUE = 4;
   // Fatal Error Messages always stop the simulation
   localparam EBFM_MSG_ERROR_FATAL = 101;
   localparam EBFM_MSG_ERROR_FATAL_TB_ERR = 102;

   // Maximum Message Length in characters
   localparam EBFM_MSG_MAX_LEN = 100 ;

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


   integer log_file ;

   reg [EBFM_MSG_ERROR_CONTINUE:EBFM_MSG_DEBUG] suppressed_msg_mask ;

   reg [EBFM_MSG_ERROR_CONTINUE:EBFM_MSG_DEBUG] stop_on_msg_mask ;

   initial
     begin
        suppressed_msg_mask = {EBFM_MSG_ERROR_CONTINUE-EBFM_MSG_DEBUG+1{1'b0}} ;
        suppressed_msg_mask[EBFM_MSG_DEBUG] = 1'b1 ;
        stop_on_msg_mask    = {EBFM_MSG_ERROR_CONTINUE-EBFM_MSG_DEBUG+1{1'b0}} ;
     end
endmodule // altpcietb_bfm_log_common
`timescale 1 ps / 1 ps
//-----------------------------------------------------------------------------
// Title         : PCI Express BFM Request Interface Common Variables
// Project       : PCI Express MegaCore function
//-----------------------------------------------------------------------------
// File          : altpcietb_bfm_req_intf_common.v
// Author        : Altera Corporation
//-----------------------------------------------------------------------------
// Description :
// This module provides the common variables for passing the requests between the
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

module altpcietb_bfm_req_intf_common(dummy_out) ;

   // Root Port Primary Side Bus Number and Device Number
   localparam [7:0] RP_PRI_BUS_NUM = 8'h00 ;
   localparam [4:0] RP_PRI_DEV_NUM = 5'b00000 ;
   // Root Port Requester ID
   localparam[15:0] RP_REQ_ID = {RP_PRI_BUS_NUM, RP_PRI_DEV_NUM , 3'b000}; // used in the Requests sent out
   // 2MB of memory
   localparam SHMEM_ADDR_WIDTH = 21;
   // The first section of the PCI Express I/O Space will be reserved for
   // addressing the Root Port's Shared Memory. PCI Express I/O Initiators
   // would use an I/O address in this range to access the shared memory.
   // Likewise the first section of the PCI Express Memory Space will be
   // reserved for accessing the Root Port's Shared Memory. PCI Express
   // Memory Initiators will use this range to access this memory.
   // These values here set the range that can be used to assign the
   // EP BARs to.
   localparam[31:0] EBFM_BAR_IO_MIN = 32'b1 << SHMEM_ADDR_WIDTH ;
   localparam[31:0] EBFM_BAR_IO_MAX = {32{1'b1}};
   localparam[31:0] EBFM_BAR_M32_MIN = 32'b1 << SHMEM_ADDR_WIDTH ;
   localparam[31:0] EBFM_BAR_M32_MAX = {32{1'b1}};
   localparam[63:0] EBFM_BAR_M64_MIN = 64'h0000000100000000 ;
   localparam[63:0] EBFM_BAR_M64_MAX = {64{1'b1}};
   localparam EBFM_NUM_VC = 4; // Number of VC's implemented in the Root Port BFM
   localparam EBFM_NUM_TAG = 32; // Number of TAG's used by Root Port BFM

   // Constants for the logging package
   localparam EBFM_MSG_DEBUG = 0;
   localparam EBFM_MSG_INFO = 1;
   localparam EBFM_MSG_WARNING = 2;
   localparam EBFM_MSG_ERROR_INFO = 3; // Preliminary Error Info Message
   localparam EBFM_MSG_ERROR_CONTINUE = 4;
   // Fatal Error Messages always stop the simulation
   localparam EBFM_MSG_ERROR_FATAL = 101;
   localparam EBFM_MSG_ERROR_FATAL_TB_ERR = 102;

   // Maximum Message Length in characters
   localparam EBFM_MSG_MAX_LEN = 100 ;

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

   // This constant defines how long to wait whenever waiting for some external event...
   localparam NUM_PS_TO_WAIT = 8000 ;

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

   output      dummy_out;

// Contains the performance measurement information
   reg         [0:EBFM_NUM_VC-1] perf_req;
   reg         [0:EBFM_NUM_VC-1] perf_ack;
   integer     perf_tx_pkts[0:EBFM_NUM_VC-1];
   integer     perf_tx_qwords[0:EBFM_NUM_VC-1];
   integer     perf_rx_pkts[0:EBFM_NUM_VC-1];
   integer     perf_rx_qwords[0:EBFM_NUM_VC-1];
   integer     last_perf_timestamp;

   reg [192:0] req_info[0:EBFM_NUM_VC-1] ;
   reg         req_info_valid[0:EBFM_NUM_VC-1] ;
   reg         req_info_ack[0:EBFM_NUM_VC-1] ;

   reg         tag_busy[0:EBFM_NUM_TAG-1] ;
   reg [2:0]   tag_status[0:EBFM_NUM_TAG-1] ;
   reg         hnd_busy[0:EBFM_NUM_TAG-1] ;
   integer     tag_lcl_addr[0:EBFM_NUM_TAG-1] ;

   reg reset_in_progress ;
   integer bfm_max_payload_size ;
   integer bfm_ep_max_rd_req ;
   integer bfm_rp_max_rd_req ;
   // This variable holds the TC to VC mapping
   reg [23:0] tc2vc_map;

   integer    i ;

   initial
     begin
        for (i = 0; i < EBFM_NUM_VC; i = i + 1 )
          begin
             req_info[i]       = {193{1'b0}} ;
             req_info_valid[i] = 1'b0 ;
             req_info_ack[i]   = 1'b0 ;
             perf_req[i]       = 1'b0 ;
             perf_ack[i]       = 1'b0 ;
             perf_tx_pkts[i]   = 0 ;
             perf_tx_qwords[i] = 0 ;
             perf_rx_pkts[i]   = 0 ;
             perf_rx_qwords[i] = 0 ;
             last_perf_timestamp[i] = 0 ;
          end
        for (i = 0; i < EBFM_NUM_TAG; i = i + 1)
          begin
             tag_busy[i]     = 1'b0 ;
             tag_status[i]   = 3'b000 ;
             hnd_busy[i]     = 1'b0 ;
             tag_lcl_addr[i] = 0 ;
          end
        reset_in_progress    = 1'b0 ;
        bfm_max_payload_size = 128 ;
        bfm_ep_max_rd_req    = 128 ;
        bfm_rp_max_rd_req    = 128 ;
        tc2vc_map            = 24'h000000 ;
     end
endmodule // altpcietb_bfm_req_intf_common
`timescale 1 ps / 1 ps
//-----------------------------------------------------------------------------
// Title         : PCI Express BFM Shmem Module
// Project       : PCI Express MegaCore function
//-----------------------------------------------------------------------------
// File          : altpcietb_bfm_shmem_common.v
// Author        : Altera Corporation
//-----------------------------------------------------------------------------
// Description :
// Implements the common shared memory array
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
module altpcietb_bfm_shmem_common(dummy_out) ;

   // Root Port Primary Side Bus Number and Device Number
   localparam [7:0] RP_PRI_BUS_NUM = 8'h00 ;
   localparam [4:0] RP_PRI_DEV_NUM = 5'b00000 ;
   // Root Port Requester ID
   localparam[15:0] RP_REQ_ID = {RP_PRI_BUS_NUM, RP_PRI_DEV_NUM , 3'b000}; // used in the Requests sent out
   // 2MB of memory
   localparam SHMEM_ADDR_WIDTH = 21;
   // The first section of the PCI Express I/O Space will be reserved for
   // addressing the Root Port's Shared Memory. PCI Express I/O Initiators
   // would use an I/O address in this range to access the shared memory.
   // Likewise the first section of the PCI Express Memory Space will be
   // reserved for accessing the Root Port's Shared Memory. PCI Express
   // Memory Initiators will use this range to access this memory.
   // These values here set the range that can be used to assign the
   // EP BARs to.
   localparam[31:0] EBFM_BAR_IO_MIN = 32'b1 << SHMEM_ADDR_WIDTH ;
   localparam[31:0] EBFM_BAR_IO_MAX = {32{1'b1}};
   localparam[31:0] EBFM_BAR_M32_MIN = 32'b1 << SHMEM_ADDR_WIDTH ;
   localparam[31:0] EBFM_BAR_M32_MAX = {32{1'b1}};
   localparam[63:0] EBFM_BAR_M64_MIN = 64'h0000000100000000 ;
   localparam[63:0] EBFM_BAR_M64_MAX = {64{1'b1}};
   localparam EBFM_NUM_VC = 4; // Number of VC's implemented in the Root Port BFM
   localparam EBFM_NUM_TAG = 32; // Number of TAG's used by Root Port BFM

   // Constants for the logging package
   localparam EBFM_MSG_DEBUG = 0;
   localparam EBFM_MSG_INFO = 1;
   localparam EBFM_MSG_WARNING = 2;
   localparam EBFM_MSG_ERROR_INFO = 3; // Preliminary Error Info Message
   localparam EBFM_MSG_ERROR_CONTINUE = 4;
   // Fatal Error Messages always stop the simulation
   localparam EBFM_MSG_ERROR_FATAL = 101;
   localparam EBFM_MSG_ERROR_FATAL_TB_ERR = 102;

   // Maximum Message Length in characters
   localparam EBFM_MSG_MAX_LEN = 100 ;

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
                         expline = {"    Expected Data: ", himage2(data[(incr_count * 8)+:8]), "              "};
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
                         expline = {"    Expected Data: ", himage2(data[(incr_count * 8)+:8]), "              "};
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
                         expline = {"    Expected Data: ", himage2(data[(incr_count * 8)+:8]), "              "};
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
output dummy_out;
   reg [7:0] shmem[0:SHMEM_SIZE-1] ;

   // Protection Bit for the Shared Memory
   // This bit protects critical data in Shared Memory from being overwritten.
   // Critical data includes things like the BAR table that maps BAR numbers to addresses.
   // Deassert this bit to REMOVE protection of the CRITICAL data.
   reg protect_bfm_shmem;

   initial
     begin
        shmem_fill(0,SHMEM_FILL_ZERO,SHMEM_SIZE,{64{1'b0}}) ;
        protect_bfm_shmem = 1'b1;
     end

endmodule // altpcietb_bfm_shmem_common
`timescale 1 ps / 1 ps
//-----------------------------------------------------------------------------
// Title         : PCI Express BFM Root Port VC Interface
// Project       : PCI Express MegaCore function
//-----------------------------------------------------------------------------
// File          : altpcietb_bfm_vc_intf.v
// Author        : Altera Corporation
//-----------------------------------------------------------------------------
// Description :
// This entity interfaces between the root port transaction list processor
// and the root port module single VC interface. It handles the following basic
// functions:
// * Formating Tx Descriptors
// * Retrieving Tx Data as needed from the shared memory
// * Decoding Rx Descriptors
// * Storing Rx Data as needed to the shared memory
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
module altpcietb_bfm_vc_intf (clk_in, rstn, rx_req, rx_ack, rx_abort, rx_retry, rx_mask, rx_desc, rx_ws, rx_data, rx_be, rx_dv, rx_dfr, tx_cred, tx_req, tx_desc, tx_ack, tx_dfr, tx_data, tx_dv, tx_err, tx_ws, cfg_io_bas, cfg_np_bas, cfg_pr_bas);

   parameter VC_NUM  = 0;
   parameter DISABLE_RX_BE_CHECK  = 1;
   // Root Port Primary Side Bus Number and Device Number
   localparam [7:0] RP_PRI_BUS_NUM = 8'h00 ;
   localparam [4:0] RP_PRI_DEV_NUM = 5'b00000 ;
   // Root Port Requester ID
   localparam[15:0] RP_REQ_ID = {RP_PRI_BUS_NUM, RP_PRI_DEV_NUM , 3'b000}; // used in the Requests sent out
   // 2MB of memory
   localparam SHMEM_ADDR_WIDTH = 21;
   // The first section of the PCI Express I/O Space will be reserved for
   // addressing the Root Port's Shared Memory. PCI Express I/O Initiators
   // would use an I/O address in this range to access the shared memory.
   // Likewise the first section of the PCI Express Memory Space will be
   // reserved for accessing the Root Port's Shared Memory. PCI Express
   // Memory Initiators will use this range to access this memory.
   // These values here set the range that can be used to assign the
   // EP BARs to.
   localparam[31:0] EBFM_BAR_IO_MIN = 32'b1 << SHMEM_ADDR_WIDTH ;
   localparam[31:0] EBFM_BAR_IO_MAX = {32{1'b1}};
   localparam[31:0] EBFM_BAR_M32_MIN = 32'b1 << SHMEM_ADDR_WIDTH ;
   localparam[31:0] EBFM_BAR_M32_MAX = {32{1'b1}};
   localparam[63:0] EBFM_BAR_M64_MIN = 64'h0000000100000000 ;
   localparam[63:0] EBFM_BAR_M64_MAX = {64{1'b1}};
   localparam EBFM_NUM_VC = 4; // Number of VC's implemented in the Root Port BFM
   localparam EBFM_NUM_TAG = 32; // Number of TAG's used by Root Port BFM

   // Constants for the logging package
   localparam EBFM_MSG_DEBUG = 0;
   localparam EBFM_MSG_INFO = 1;
   localparam EBFM_MSG_WARNING = 2;
   localparam EBFM_MSG_ERROR_INFO = 3; // Preliminary Error Info Message
   localparam EBFM_MSG_ERROR_CONTINUE = 4;
   // Fatal Error Messages always stop the simulation
   localparam EBFM_MSG_ERROR_FATAL = 101;
   localparam EBFM_MSG_ERROR_FATAL_TB_ERR = 102;

   // Maximum Message Length in characters
   localparam EBFM_MSG_MAX_LEN = 100 ;

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
                         expline = {"    Expected Data: ", himage2(data[(incr_count * 8)+:8]), "              "};
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
                         expline = {"    Expected Data: ", himage2(data[(incr_count * 8)+:8]), "              "};
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
                         expline = {"    Expected Data: ", himage2(data[(incr_count * 8)+:8]), "              "};
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
   // This constant defines how long to wait whenever waiting for some external event...
   localparam NUM_PS_TO_WAIT = 8000 ;

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

   input clk_in;
   input rstn;
   input rx_req;
   output rx_ack;
   reg rx_ack;
   output rx_abort;
   reg rx_abort;
   output rx_retry;
   reg rx_retry;
   output rx_mask;
   reg rx_mask;
   input[135:0] rx_desc;
   output rx_ws;
   reg rx_ws;
   input[63:0] rx_data;
   input[7:0] rx_be;
   input rx_dv;
   input rx_dfr;
   input[21:0] tx_cred;
   output tx_req;
   reg tx_req;
   output[127:0] tx_desc;
   reg[127:0] tx_desc;
   input tx_ack;
   output tx_dfr;
   reg tx_dfr;
   output[63:0] tx_data;
   reg[63:0] tx_data;
   output tx_dv;
   reg tx_dv;
   output tx_err;
   reg tx_err;
   input tx_ws;
   input[19:0] cfg_io_bas;
   input[11:0] cfg_np_bas;
   input[43:0] cfg_pr_bas;

   parameter[2:0] RXST_IDLE = 0;
   parameter[2:0] RXST_DESC_ACK = 1;
   parameter[2:0] RXST_DATA_WRITE = 2;
   parameter[2:0] RXST_DATA_NONP_WRITE = 3;
   parameter[2:0] RXST_DATA_COMPL = 4;
   parameter[2:0] RXST_NONP_REQ = 5;
   parameter[1:0] TXST_IDLE = 0;
   parameter[1:0] TXST_DESC = 1;
   parameter[1:0] TXST_DATA = 2;
   reg[2:0] rx_state;
   reg[1:0] tx_state;
   // Communication signals between main Tx State Machine and main Rx State Machine
   // to indicate when completions are expected
   integer exp_compl_tag;
   integer exp_compl_bcount;
   // Communication signals between Rx State Machine and Tx State Machine
   // for requesting completions
   reg rx_tx_req;
   reg[127:0] rx_tx_desc;
   integer rx_tx_shmem_addr;
   integer rx_tx_bcount;
   reg[7:0] rx_tx_byte_enb;
   reg tx_rx_ack;

   // Communication Signals for PErf Monitoring
   reg tx_dv_last;
   reg tx_req_int;
   reg rx_ws_int;
   reg rx_ack_int;

   function [0:0] is_request;
      input[135:0] rx_desc;

      reg dummy ;

      begin
         case (rx_desc[124:120])
            5'b00000 :
                     begin
                        is_request = 1'b1; // Memory Read or Write
                     end
            5'b00010 :
                     begin
                        is_request = 1'b1; // I/O Read or Write
                     end
            5'b01010 :
                     begin
                        is_request = 1'b0; // Completion
                     end
            default :
                     begin
                        // "00001" Memory Read Locked
                        // "00100" Config Type 0 Read or Write
                        // "00101" Config Type 1 Read or Write
                        // "10rrr" Message (w/Data)
                        // "01011" Completion Locked
                        dummy = ebfm_display(EBFM_MSG_ERROR_FATAL,
                                     {"Root Port VC", dimage1(VC_NUM),
                                      " Recevied unsupported TLP, Fmt/Type: ", himage2(rx_desc[127:120])});
                        is_request = 1'b0;
                     end
         endcase
      end
   endfunction

   function [0:0] is_non_posted;
      input[127:0] desc;

      begin
         case (desc[124:120])
            5'b00000 :
                     begin
                        // Memory Read or Write
                        if ((desc[126]) == 1'b0)
                        begin
                           // No Data, Must be non-posted read
                           is_non_posted = 1'b1;
                        end
                        else
                        begin
                           is_non_posted = 1'b0;
                        end
                     end
            5'b00100 :
                     begin
                        is_non_posted = 1'b1; // Config Type 0 Read or Write
                     end
            5'b00101 :
                     begin
                        is_non_posted = 1'b1; // Config Type 1 Read or Write
                     end
            5'b00010 :
                     begin
                        is_non_posted = 1'b1; // I/O Read or Write
                     end
            5'b01010 :
                     begin
                        is_non_posted = 1'b0; // Completion
                     end
            default :
                     begin
                        // "00001" Memory Read Locked
                        // "10rrr" Message (w/Data)
                        // "01011" Completion Locked
                        is_non_posted = 1'b0;
                     end
         endcase
      end
   endfunction

   function [0:0] has_data;
      input[127:0] desc;

      begin
         if ((desc[126]) == 1'b1)
         begin
            has_data = 1'b1;
         end
         else
         begin
            has_data = 1'b0;
         end
      end
   endfunction

   function integer calc_byte_count;
      input[127:0] desc;

      integer bcount;

      begin
         // Number of DWords * 4 gives bytes
         bcount = desc[105:96] * 4;
         if (bcount > 4)
         begin
            if ((desc[71]) == 1'b0)
            begin
               bcount = bcount - 1;
               if ((desc[70]) == 1'b0)
               begin
                  bcount = bcount - 1;
                  // If more than 1 DW
                  if ((desc[69]) == 1'b0)
                  begin
                     bcount = bcount - 1;
                     // Adjust if the last Dword is not full
                     if ((desc[68]) == 1'b0)
                     begin
                        // Handle the case of no bytes in last DW
                        bcount = bcount - 1;
                     end
                  end
               end
            end
            if ((desc[64]) == 1'b0)
            begin
               bcount = bcount - 1;
               if ((desc[65]) == 1'b0)
               begin
                  bcount = bcount - 1;
                  if ((desc[66]) == 1'b0)
                  begin
                     bcount = bcount - 1;
                     // Now adjust if the first Dword is not full
                     if ((desc[67]) == 1'b0)
                     begin
                        // Handle the case of no bytes in first DW
                        bcount = bcount - 1;
                     end
                  end
               end
            end
         end
         else
         begin
            // Only one DW, need to adjust based on
            // First Byte Enables could be any subset
            if ((desc[64]) == 1'b0)
            begin
               bcount = bcount - 1;
            end
            if ((desc[65]) == 1'b0)
            begin
               bcount = bcount - 1;
            end
            if ((desc[66]) == 1'b0)
            begin
               bcount = bcount - 1;
            end
            if ((desc[67]) == 1'b0)
            begin
               bcount = bcount - 1;
            end
         end
         calc_byte_count = bcount;
      end
   endfunction

   function [7:0] calc_first_byte_enb;
      input[127:0] desc;

      reg[7:0] byte_enb;

      begin
         // calc_first_byte_enb
         if ((((desc[125]) == 1'b1) & ((desc[2]) == 1'b1)) | (((desc[125]) == 1'b0) & ((desc[34]) == 1'b1)))
         begin
            byte_enb = {desc[67:64], 4'b0000};
         end
         else
         begin
            byte_enb = {4'b1111, desc[67:64]};
         end
         calc_first_byte_enb = byte_enb;
      end
   endfunction

   function integer calc_lcl_addr;
      input[135:0] rx_desc;

      reg[63:0] req_addr;

      begin
         // We just use the lower bits of the address to for the memory address
         if ((rx_desc[125]) == 1'b1)
         begin
            // 4 DW Header
            req_addr[63:2] = rx_desc[63:2];
         end
         else
         begin
            // 3 DW Header
            req_addr[31:2] = rx_desc[63:34];
         end
         if ((rx_desc[64]) == 1'b1)
         begin
            req_addr[1:0] = 2'b00;
         end
         else
         begin
            if ((rx_desc[65]) == 1'b1)
            begin
               req_addr[1:0] = 2'b01;
            end
            else
            begin
               // Calculate Byte Address from Byte Enables
               if ((rx_desc[66]) == 1'b1)
               begin
                  req_addr[1:0] = 2'b10;
               end
               else
               begin
                  // Last Byte should be enabled (or we are not accessing anything so
                  // it is a don't care)
                  req_addr[1:0] = 2'b11;
               end
            end
         end
         calc_lcl_addr = req_addr[SHMEM_ADDR_WIDTH - 1:0];
      end
   endfunction

   task rx_write_req_setup;
      input[135:0] rx_desc;
      output addr;
      integer addr;
      output[7:0] byte_enb;
      output bcount;
      integer bcount;

      begin
         addr = calc_lcl_addr(rx_desc);
         byte_enb = calc_first_byte_enb(rx_desc[127:0]);
         bcount = calc_byte_count(rx_desc[127:0]);
      end
   endtask

   task rx_compl_setup;
      input[135:0] rx_desc;
      output base_addr;
      integer base_addr;
      output[7:0] byte_enb;
      output bcount;
      integer bcount;
      output tag;
      integer tag;
      output[2:0] status;

      integer tagi;
      integer bcounti;

      begin
         // lcl_compl_addr
         tagi = rx_desc[47:40];
         if ((rx_desc[126]) == 1'b1)
         begin
            base_addr = vc_intf_get_lcl_addr(tagi);
         end
         else
         begin
            base_addr = 2 ** SHMEM_ADDR_WIDTH;
         end
         tag = tagi;
         // Calculate the byte-count from Length field
         bcounti = rx_desc[105:96] * 4;
         // Calculate the byte-enables from the Lower Address field
         // Also modify the byte count
         case (rx_desc[34:32])
            3'b111 :
                     begin
                        byte_enb = 8'b10000000;
                        bcounti = bcounti - 3;
                     end
            3'b110 :
                     begin
                        byte_enb = 8'b11000000;
                        bcounti = bcounti - 2;
                     end
            3'b101 :
                     begin
                        byte_enb = 8'b11100000;
                        bcounti = bcounti - 1;
                     end
            3'b100 :
                     begin
                        byte_enb = 8'b11110000;
                        bcounti = bcounti - 0;
                     end
            3'b011 :
                     begin
                        byte_enb = 8'b11111000;
                        bcounti = bcounti - 3;
                     end
            3'b010 :
                     begin
                        byte_enb = 8'b11111100;
                        bcounti = bcounti - 2;
                     end
            3'b001 :
                     begin
                        byte_enb = 8'b11111110;
                        bcounti = bcounti - 1;
                     end
            default :
                     begin
                        byte_enb = {8{1'b1}};
                        bcounti = bcounti - 0;
                     end
         endcase
         // Now if the remaining byte-count from the header is less than that
         // calculated above, that means there are some last data phase
         // byte enables that are not on, update bcounti to reflect that
         if (rx_desc[75:64] < bcounti)
         begin
            bcounti = rx_desc[75:64];
         end
         bcount = bcounti;
         status = rx_desc[79:77];
      end
   endtask


   // Setup the Completion Info for the received request
   task rx_nonp_req_setup_compl;
      input[135:0] rx_desc;
      output[127:0] rx_tx_desc;
      output rx_tx_shmem_addr;
      integer rx_tx_shmem_addr;
      output[7:0] rx_tx_byte_enb;
      output rx_tx_bcount;
      integer rx_tx_bcount;

      integer temp_bcount;
      integer temp_shmem_addr;

      begin
         temp_shmem_addr = calc_lcl_addr(rx_desc[135:0]);
         rx_tx_shmem_addr = temp_shmem_addr;
         rx_tx_byte_enb = calc_first_byte_enb(rx_desc[127:0]);
         temp_bcount = calc_byte_count(rx_desc[127:0]);
         rx_tx_bcount = temp_bcount;
         rx_tx_desc = {128{1'b0}};
         rx_tx_desc[126] = ~rx_desc[126]; // Completion Data is opposite of Request
         rx_tx_desc[125] = 1'b0; // FMT bit 0 always 0
         rx_tx_desc[124:120] = 5'b01010; // Completion
         // TC,TD,EP,Attr,Length (and reserved bits) same as request:
         rx_tx_desc[119:96] = rx_desc[119:96];
         rx_tx_desc[95:80] = RP_REQ_ID; // Completer ID
         rx_tx_desc[79:77] = 3'b000; // Completion Status
         rx_tx_desc[76] = 1'b0; // Byte Count Modified
         rx_tx_desc[75:64] = temp_bcount;
         rx_tx_desc[63:48] = rx_desc[95:80]; // Requester ID
         rx_tx_desc[47:40] = rx_desc[79:72]; // Tag
         // Lower Address:
         rx_tx_desc[38:32] = temp_shmem_addr;
      end
   endtask

   function [0:0] tx_fc_check;
      input[127:0] desc;
      input[21:0] cred;

      integer data_cred;

      begin
         // tx_fc_check
         case (desc[126:120])
            7'b1000100, 7'b0000100 :
                     begin
                        // Config Write Type 0
                        // Config Read Type 0
                        // Type 0 Config issued to RP get handled internally,
                        // so we can issue even if no Credits
                        tx_fc_check = 1'b1;
                     end
            7'b0000000, 7'b0100000, 7'b0000010, 7'b0000101 :
                     begin
                        // Memory Read (3DW, 4DW)
                        // IO Read
                        // Config Read Type 1
                        // Non-Posted Request without Data
                        if ((cred[10]) == 1'b1)
                        begin
                           tx_fc_check = 1'b1;
                        end
                        else
                        begin
                           tx_fc_check = 1'b0;
                        end
                     end
            7'b1000010, 7'b1000101 :
                     begin
                        // IO Write
                        // Config Write Type 1
                        // Non-Posted Request with Data
                        if (((cred[10]) == 1'b1) & ((cred[11]) == 1'b1))
                        begin
                           tx_fc_check = 1'b1;
                        end
                        else
                        begin
                           tx_fc_check = 1'b0;
                        end
                     end
            7'b1000000, 7'b1100000 :
                     begin
                        if ((cred[0]) == 1'b1)
                        begin
                           data_cred = desc[105:98];
                           // Memory Read (3DW, 4DW)
                           // Posted Request with Data
                           if (desc[97:96] != 2'b00)
                           begin
                              data_cred = data_cred + 1;
                           end
                           if (data_cred <= cred[9:1])
                           begin
                              tx_fc_check = 1'b1;
                           end
                           else
                           begin
                              tx_fc_check = 1'b0;
                           end
                        end
                        else
                        begin
                           tx_fc_check = 1'b0;
                        end
                     end
            default :
                     begin
                        tx_fc_check = 1'b0;
                     end
         endcase
      end
   endfunction

   task tx_setup_data;
      input lcl_addr;
      integer lcl_addr;
      input bcount;
      integer bcount;
      input[7:0] byte_enb;
      output[32767:0] data_pkt;
      output dphases;
      integer dphases;
      input imm_valid;
      input[31:0] imm_data;

      reg [63:0] data_pkt_xhdl ;

      integer dphasesi;
      integer bcount_v;
      integer lcl_addr_v;
      integer nb;
      integer fb;

      integer i ;

      begin
         dphasesi = 0 ;
         // tx_setup_data
         if (imm_valid == 1'b1)
           begin
              lcl_addr_v = 0 ;
           end
         else
           begin
              lcl_addr_v = lcl_addr;
           end
         bcount_v = bcount;
         // Setup the first data phase, find the first byte
         begin : xhdl_0
            integer i;
            for(i = 0; i <= 7; i = i + 1)
            begin : byte_loop
               if ((byte_enb[i]) == 1'b1)
               begin
                  fb = i;
                  disable xhdl_0 ;
               end
            end
         end
         // first data phase figure out number of bytes
         nb = 8 - fb;
         if (nb > bcount_v)
         begin
            nb = bcount_v;
         end
         // first data phase get bytes
         data_pkt_xhdl = {64{1'b0}};
         for (i = 0 ; i < nb ; i = i + 1)
           begin
              if (imm_valid == 1'b1)
                begin
                   data_pkt_xhdl[((fb+i) * 8)+:8] = imm_data[(i*8)+:8];
                end
              else
                begin
                   data_pkt_xhdl[((fb+i) * 8)+:8] = shmem_read((lcl_addr_v+i), 1);
                end
           end
         data_pkt[(dphasesi*64)+:64] = data_pkt_xhdl;
         bcount_v = bcount_v - nb;
         lcl_addr_v = lcl_addr_v + nb;
         dphasesi = dphasesi + 1;
         // Setup the remaining data phases
         while (bcount_v > 0)
         begin
            data_pkt_xhdl = {64{1'b0}};
            if (bcount_v < 8)
            begin
               nb = bcount_v;
            end
            else
            begin
               nb = 8;
            end
            for (i = 0 ; i < nb ; i = i + 1 )
              begin
                 if (imm_valid == 1'b1)
                   begin
                      // Offset into remaining immediate data
                      data_pkt_xhdl[(i*8)+:8] = imm_data[(lcl_addr_v + (i*8))+:8];
                   end
                 else
                   begin
                      data_pkt_xhdl[(i*8)+:8] = shmem_read(lcl_addr_v + i, 1);
                   end
              end
            data_pkt[(dphasesi*64)+:64] = data_pkt_xhdl;
            bcount_v = bcount_v - nb;
            lcl_addr_v = lcl_addr_v + nb;
            dphasesi = dphasesi + 1;
         end
         dphases = dphasesi;
      end
   endtask

   task tx_setup_req;
      input[127:0] req_desc;
      input lcl_addr;
      integer lcl_addr;
      input imm_valid;
      input[31:0] imm_data;
      output[32767:0] data_pkt;
      output dphases;
      integer dphases;

      integer bcount_v;
      reg[7:0] byte_enb_v;

      begin
         // tx_setup_req
         if (has_data(req_desc))
         begin
            bcount_v = calc_byte_count(req_desc);
            byte_enb_v = calc_first_byte_enb(req_desc);
            tx_setup_data(lcl_addr, bcount_v, byte_enb_v, data_pkt, dphases, imm_valid, imm_data);
         end
         else
         begin
            dphases = 0;
         end
      end
   endtask

   // behavioral
   always @(clk_in)
   begin : main_rx_state
      integer compl_received_v[0:EBFM_NUM_TAG - 1];
      integer compl_expected_v[0:EBFM_NUM_TAG - 1];
      reg[2:0] rx_state_v;
      reg rx_ack_v;
      reg rx_ws_v;
      reg rx_abort_v;
      reg rx_retry_v;
      integer shmem_addr_v;
      integer rx_compl_tag_v;
      reg[SHMEM_ADDR_WIDTH - 1:0] rx_compl_baddr_v;
      reg[2:0] rx_compl_sts_v;
      reg[7:0] byte_enb_v;
      integer bcount_v;
      reg rx_tx_req_v;
      reg[127:0] rx_tx_desc_v;
      integer rx_tx_shmem_addr_v;
      integer rx_tx_bcount_v;
      reg[7:0] rx_tx_byte_enb_v;
      reg      dummy ;
      integer      i ;
      if (clk_in == 1'b1)
      begin
         if (rstn != 1'b1)
         begin
            rx_state_v = RXST_IDLE;
            rx_ack_v = 1'b0;
            rx_ws_v = 1'b0;
            rx_abort_v = 1'b0;
            rx_retry_v = 1'b0;
            rx_compl_tag_v = -1;
            rx_compl_sts_v = {3{1'b1}};
            rx_tx_req_v = 1'b0;
            rx_tx_desc_v = {128{1'b0}};
            rx_tx_shmem_addr_v = 0;
            rx_tx_bcount_v = 0;
            rx_tx_bcount_v = 0;
            for (i = 0 ; i < EBFM_NUM_TAG ; i = i + 1)
              begin
                 compl_expected_v[i] = -1;
                 compl_received_v[i] = -1;
              end
         end
         else
         begin
            // See if the Transmit side is transmitting a Non-Posted Request
            // that we need to expect a completion for and if so record it
            if (exp_compl_tag > -1)
            begin
               compl_expected_v[exp_compl_tag] = exp_compl_bcount;
               compl_received_v[exp_compl_tag] = 0;
            end
            rx_state_v = rx_state;
            rx_ack_v = 1'b0;
            rx_ws_v = 1'b0;
            rx_abort_v = 1'b0;
            rx_retry_v = 1'b0;
            rx_tx_req_v = 1'b0;
            case (rx_state)
               RXST_IDLE :
                        begin
                           // Note rx_mask will be controlled by tx_process
                           // process main_rx_state
                           if (rx_req == 1'b1)
                           begin
                              rx_ack_v = 1'b1;
                              rx_state_v = RXST_DESC_ACK;
                           end
                           else
                           begin
                              rx_ack_v = 1'b0;
                              rx_state_v = RXST_IDLE;
                           end
                        end
               RXST_DESC_ACK, RXST_DATA_COMPL, RXST_DATA_WRITE, RXST_DATA_NONP_WRITE :
                        begin
                           if (rx_state == RXST_DESC_ACK)
                           begin
                              if (is_request(rx_desc))
                              begin
                                 // All of these states are handled together since they can all
                                 // involve data transfer and we need to share that code.
                                 //
                                 // If this is the cycle where the descriptor is being ack'ed we
                                 // need to complete the descriptor decode first so that we can
                                 // be prepared for the Data Transfer that might happen in the same
                                 // cycle.
                                 if (is_non_posted(rx_desc[127:0]))
                                 begin
                                    // Non-Posted Request
                                    rx_nonp_req_setup_compl(rx_desc, rx_tx_desc_v, rx_tx_shmem_addr_v, rx_tx_byte_enb_v, rx_tx_bcount_v);
                                    // Request
                                    if (has_data(rx_desc[127:0]))
                                    begin
                                       // Non-Posted Write Request
                                       rx_write_req_setup(rx_desc, shmem_addr_v, byte_enb_v, bcount_v);
                                       rx_state_v = RXST_DATA_NONP_WRITE;
                                    end
                                    else
                                    begin
                                       // Non-Posted Read Request
                                       rx_state_v = RXST_NONP_REQ;
                                    end
                                 end
                                 else
                                 begin
                                    // Posted Request
                                    rx_tx_desc_v = {128{1'b0}};
                                    rx_tx_shmem_addr_v = 0;
                                    rx_tx_byte_enb_v = {8{1'b0}};
                                    rx_tx_bcount_v = 0;
                                    // Begin Lengthy decode and checking of the Rx Descriptor
                                    // First Determine if it is a completion or a request
                                    if (has_data(rx_desc[127:0]))
                                    begin
                                       // Posted Write Request
                                       rx_write_req_setup(rx_desc, shmem_addr_v, byte_enb_v, bcount_v);
                                       rx_state_v = RXST_DATA_WRITE;
                                    end
                                    else
                                    begin
                                       // Posted Message without Data
                                       // Not currently supported.
                                       rx_state_v = RXST_IDLE;
                                    end
                                 end
                              end
                              else // is_request == 0
                              begin
                                 // Completion
                                 rx_compl_setup(rx_desc, shmem_addr_v, byte_enb_v, bcount_v,
                                                rx_compl_tag_v, rx_compl_sts_v);
                                 if (compl_expected_v[rx_compl_tag_v] < 0)
                                 begin
                                    dummy = ebfm_display(EBFM_MSG_ERROR_FATAL,
                                                 {"Root Port VC", dimage1(VC_NUM),
                                                  " Recevied unexpected completion TLP, Fmt/Type: ",
                                                  himage2(rx_desc[127:120]),
                                                  " Tag: ", himage2(rx_desc[47:40])});
                                 end
                                 if (has_data(rx_desc[127:0]))
                                 begin
                                    rx_state_v = RXST_DATA_COMPL;
                                    // Increment for already received data phases
                                    shmem_addr_v = shmem_addr_v + compl_received_v[rx_compl_tag_v];
                                 end
                                 else
                                 begin
                                    rx_state_v = RXST_IDLE;
                                    if ((compl_received_v[rx_compl_tag_v] < compl_expected_v[rx_compl_tag_v]) &
                                        (rx_compl_sts_v == 3'b000))
                                    begin
                                       dummy = ebfm_display(EBFM_MSG_ERROR_CONTINUE,
                                                    {"Root Port VC", dimage1(VC_NUM),
                                                     " Did not receive all expected completion data. Expected: ",
                                                     dimage4(compl_expected_v[rx_compl_tag_v]),
                                                     " Received: ", dimage4(compl_received_v[rx_compl_tag_v])});
                                    end
                                    // Report that it is complete to the Driver
                                    vc_intf_rpt_compl(rx_compl_tag_v, rx_compl_sts_v);
                                    // Clear out that we expect anymore
                                    compl_received_v[rx_compl_tag_v] = -1;
                                    compl_expected_v[rx_compl_tag_v] = -1;
                                    rx_compl_tag_v = -1;
                                 end
                              end
                           end
                           if (rx_dv == 1'b1)
                           begin
                              begin : xhdl_3
                                 integer i;
                                 for(i = 0; i <= 7; i = i + 1)
                                 begin
                                    if (((byte_enb_v[i]) == 1'b1) & (bcount_v > 0))
                                    begin
                                       shmem_write(shmem_addr_v, rx_data[(i * 8)+:8], 1);
                                       shmem_addr_v = shmem_addr_v + 1;
                                       bcount_v = bcount_v - 1;
                                       // Byte Enables only valid on first data phase, bcount_v covers
                                       // the last data phase
                                       if ((bcount_v == 0) & (i < 7))
                                       begin
                                          begin : xhdl_4
                                             integer j;
                                             for(j = i + 1; j <= 7; j = j + 1)
                                             begin
                                                byte_enb_v[j] = 1'b0;
                                             end
                                          end // j
                                       end
                                       // Now Handle the case if we are receiving data in this cycle
                                       if (rx_state_v == RXST_DATA_COMPL)
                                       begin
                                          compl_received_v[rx_compl_tag_v] = compl_received_v[rx_compl_tag_v] + 1;
                                       end
                                       if (((rx_be[i]) != 1'b1) & (DISABLE_RX_BE_CHECK == 0))
                                       begin
                                          dummy = ebfm_display(EBFM_MSG_ERROR_FATAL,
                                                       {"Root Port VC", dimage1(VC_NUM),
                                                        " rx_be field: ", himage2(rx_be),
                                                        " Mismatch. Expected: ", himage2(byte_enb_v)});
                                       end
                                    end
                                    else
                                    begin
                                       if (((rx_be[i]) != 1'b0) & (DISABLE_RX_BE_CHECK == 0))
                                       begin
                                          dummy = ebfm_display(EBFM_MSG_ERROR_FATAL,
                                                       {"Root Port VC", dimage1(VC_NUM),
                                                        " rx_be field: ", himage2(rx_be),
                                                        " Mismatch. Expected: ", himage2(byte_enb_v)});
                                       end
                                    end
                                 end
                              end // i
                              // Enable all bytes in subsequent data phases
                              byte_enb_v = {8{1'b1}};
                              if (rx_dfr == 1'b0)
                              begin
                                 if (bcount_v > 0)
                                 begin
                                    dummy = ebfm_display(EBFM_MSG_ERROR_FATAL,
                                                 {"Root Port VC", dimage1(VC_NUM),
                                                  " Rx Byte Count did not go to zero in last data phase. Remaining Bytes: ",
                                                  dimage4(bcount_v)});
                                 end
                                 if (rx_state_v == RXST_DATA_COMPL)
                                 begin
                                    rx_state_v = RXST_IDLE;
                                    // If we have received all of the data (or more)
                                    if (compl_received_v[rx_compl_tag_v] >= compl_expected_v[rx_compl_tag_v])
                                    begin
                                       // Error if more than expected
                                       if (compl_received_v[rx_compl_tag_v] > compl_expected_v[rx_compl_tag_v])
                                       begin
                                          dummy = ebfm_display(EBFM_MSG_ERROR_FATAL,
                                                       {"Root Port VC", dimage1(VC_NUM),
                                                        " Received more completion data than expected. Expected: ",
                                                        dimage4(compl_expected_v[rx_compl_tag_v]),
                                                        " Received: ", dimage4(compl_received_v[rx_compl_tag_v])});
                                       end
                                       // Report that it is complete to the Driver
                                       vc_intf_rpt_compl(rx_compl_tag_v, rx_compl_sts_v);
                                       // Clear out that we expect anymore
                                       compl_received_v[rx_compl_tag_v] = -1;
                                       compl_expected_v[rx_compl_tag_v] = -1;
                                       rx_compl_tag_v = -1;
                                    end
                                    else
                                    begin
                                       // Have not received all of the data yet, but if the
                                       // completion status is not Successful Completion then we
                                       // need to treat as done
                                       if (rx_compl_sts_v != 3'b000)
                                       begin
                                          // Report that it is complete to the Driver
                                          vc_intf_rpt_compl(rx_compl_tag_v, rx_compl_sts_v);
                                          // Clear out that we expect anymore
                                          compl_received_v[rx_compl_tag_v] = -1;
                                          compl_expected_v[rx_compl_tag_v] = -1;
                                          rx_compl_tag_v = -1;
                                       end
                                    end
                                    // Otherwise keep going and wait for more data in another completion
                                 end
                                 else
                                 begin
                                    if (rx_state_v == RXST_DATA_NONP_WRITE)
                                    begin
                                       rx_state_v = RXST_NONP_REQ;
                                    end
                                    else
                                    begin
                                       rx_state_v = RXST_IDLE;
                                    end
                                 end
                              end
                              else
                              begin
                                 if (bcount_v == 0)
                                 begin
                                    dummy = ebfm_display(EBFM_MSG_ERROR_FATAL,
                                                 {"Root Port VC", dimage1(VC_NUM),
                                                  " Rx Byte Count went to zero before last data phase."});
                                 end
                              end
                           end
                        end
               RXST_NONP_REQ :
                        begin
                           if (tx_rx_ack == 1'b1)
                           begin
                              rx_state_v = RXST_IDLE;
                              rx_tx_req_v = 1'b0;
                           end
                           else
                           begin
                              rx_tx_req_v = 1'b1;
                              rx_state_v = RXST_NONP_REQ;
                           end
                           rx_ws_v = 1'b1;
                        end
               default :
                        begin
                        end
            endcase
         end
         rx_state         <= rx_state_v ;
         rx_ack           <= rx_ack_v ;
         rx_ack_int       <= rx_ack_v ;
         rx_ws            <= rx_ws_v ;
         rx_ws_int        <= rx_ws_v ;
         rx_abort         <= rx_abort_v ;
         rx_retry         <= rx_retry_v ;
         rx_tx_req        <= rx_tx_req_v ;
         rx_tx_desc       <= rx_tx_desc_v ;
         rx_tx_shmem_addr <= rx_tx_shmem_addr_v ;
         rx_tx_bcount     <= rx_tx_bcount_v ;
         rx_tx_byte_enb   <= rx_tx_byte_enb_v ;
      end
   end

   always @(clk_in)
     begin : main_tx_state
      reg[32767:0] data_pkt_v;
      integer dphases_v;
      integer dptr_v;
      reg[1:0] tx_state_v;
      reg rx_mask_v;
      reg tx_req_v;
      reg[127:0] tx_desc_v;
      reg tx_dfr_v;
      reg[63:0] tx_data_v;
      reg tx_dv_v;
      reg tx_dv_last_v;
      reg tx_err_v;
      reg tx_rx_ack_v;
      integer lcladdr_v;
      reg req_ack_cleared_v;
      reg[127:0] req_desc_v;
      reg req_valid_v;
      reg[31:0] imm_data_v;
      reg imm_valid_v;
      integer exp_compl_tag_v;
      integer exp_compl_bcount_v;

      if (clk_in == 1'b1)
      begin
         // rising clock edge
         exp_compl_tag_v = -1;
         exp_compl_bcount_v = 0;
         if (rstn == 1'b0)
         begin
            // synchronous reset (active low)
            tx_state_v = TXST_IDLE;
            rx_mask_v = 1'b1;
            tx_req_v = 1'b0;
            tx_desc_v = {128{1'b0}};
            tx_dfr_v = 1'b0;
            tx_data_v = {64{1'b0}};
            tx_dv_v = 1'b0;
            tx_dv_last_v = 1'b0;
            tx_err_v = 1'b0;
            tx_rx_ack_v = 1'b0;
            req_ack_cleared_v = 1'b1;
         end
         else
         begin
            // Clear any previous acknowledgement if needed
            if (req_ack_cleared_v == 1'b0)
            begin
               req_ack_cleared_v = vc_intf_clr_ack(VC_NUM);
            end
            tx_state_v = tx_state;
            rx_mask_v = 1'b1; // This is on in most states
            tx_req_v = 1'b0;
            tx_dfr_v = 1'b0;
            tx_dv_last_v = tx_dv_v;
            tx_dv_v = 1'b0;
            tx_rx_ack_v = 1'b0;
            case (tx_state_v)
               TXST_IDLE :
                        begin
                           if (tx_ws == 1'b0)
                           begin
                              if (rx_tx_req == 1'b1)
                              begin
                                 rx_mask_v = 1'b0;
                                 tx_state_v = TXST_DESC;
                                 tx_desc_v = rx_tx_desc;
                                 tx_req_v = 1'b1;
                                 tx_rx_ack_v = 1'b1;
                                 // Assumes we are getting infinite credits!!!!!
                                 if (rx_tx_bcount > 0)
                                 begin
                                    tx_setup_data(rx_tx_shmem_addr, rx_tx_bcount, rx_tx_byte_enb, data_pkt_v,
                                                  dphases_v, 1'b0, 32'h00000000);
                                    dptr_v = 0;
                                    tx_data_v = {64{1'b0}};
                                    tx_dv_v = 1'b0;
                                    tx_dfr_v = 1'b1;
                                 end
                                 else
                                 begin
                                    tx_dv_v = 1'b0;
                                    tx_dfr_v = 1'b0;
                                    dphases_v = 0;
                                 end
                              end
                              else
                              begin
                                 vc_intf_get_req(VC_NUM, req_valid_v, req_desc_v, lcladdr_v, imm_valid_v, imm_data_v);
                                 if ((tx_fc_check(req_desc_v, tx_cred)) & (req_valid_v == 1'b1) & (req_ack_cleared_v == 1'b1))
                                 begin
                                    vc_intf_set_ack(VC_NUM);
                                    req_ack_cleared_v = vc_intf_clr_ack(VC_NUM);
                                    tx_setup_req(req_desc_v, lcladdr_v, imm_valid_v, imm_data_v, data_pkt_v, dphases_v);
                                    tx_state_v = TXST_DESC;
                                    tx_desc_v = req_desc_v;
                                    tx_req_v = 1'b1;
                                    // process main_tx_state
                                    if (dphases_v > 0)
                                    begin
                                       dptr_v = 0;
                                       tx_data_v = {64{1'b0}};
                                       tx_dv_v = 1'b0;
                                       tx_dfr_v = 1'b1;
                                    end
                                    else
                                    begin
                                       tx_dv_v = 1'b0;
                                       tx_dfr_v = 1'b0;
                                    end
                                    if (is_non_posted(req_desc_v))
                                    begin
                                       exp_compl_tag_v = req_desc_v[79:72];
                                       if (has_data(req_desc_v))
                                       begin
                                          exp_compl_bcount_v = 0;
                                       end
                                       else
                                       begin
                                          exp_compl_bcount_v = calc_byte_count(req_desc_v);
                                       end
                                    end
                                 end
                                 else
                                 begin
                                    tx_state_v = TXST_IDLE;
                                    rx_mask_v = 1'b0;
                                 end
                              end
                           end
                        end
               TXST_DESC, TXST_DATA :
                        begin
                           // Handle the Tx Data Signals
                           if ((dphases_v > 0) & (tx_ws == 1'b0) & (tx_dv_last_v == 1'b1))
                           begin
                              dphases_v = dphases_v - 1;
                              dptr_v = dptr_v + 1;
                           end
                           if (dphases_v > 0)
                           begin
                              tx_data_v = data_pkt_v[(dptr_v*64)+:64];
                              tx_dv_v = 1'b1;
                              if (dphases_v > 1)
                              begin
                                 tx_dfr_v = 1'b1;
                              end
                              else
                              begin
                                 tx_dfr_v = 1'b0;
                              end
                           end
                           else
                           begin
                              tx_data_v = {64{1'b0}};
                              tx_dv_v = 1'b0;
                              tx_dfr_v = 1'b0;
                           end
                           if (tx_state_v == TXST_DESC)
                           begin
                              if (tx_ack == 1'b1)
                              begin
                                 tx_req_v = 1'b0;
                                 tx_desc_v = {128{1'b0}};
                                 if (dphases_v > 0)
                                 begin
                                    tx_state_v = TXST_DATA;
                                 end
                                 else
                                 begin
                                    tx_state_v = TXST_IDLE;
                                 end
                              end
                              else
                              begin
                                 tx_req_v = 1'b1;
                                 tx_state_v = TXST_DESC;
                              end
                           end
                           else
                           begin
                              if (dphases_v > 0)
                              begin
                                 tx_state_v = TXST_DATA;
                              end
                              else
                              begin
                                 tx_state_v = TXST_IDLE;
                              end
                           end
                        end
               default :
                        begin
                        end
            endcase
         end
         tx_state <= tx_state_v ;
         rx_mask <= rx_mask_v ;
         tx_req <= tx_req_v ;
         tx_req_int <= tx_req_v ;
         tx_desc <= tx_desc_v ;
         tx_dfr <= tx_dfr_v ;
         tx_data <= tx_data_v ;
         tx_dv <= tx_dv_v ;
         tx_dv_last <= tx_dv_last_v ;
         tx_err <= tx_err_v ;
         tx_rx_ack <= tx_rx_ack_v ;
         exp_compl_tag <= exp_compl_tag_v ;
         exp_compl_bcount <= exp_compl_bcount_v ;
      end
   end

   // purpose: This reflects the reset value in shared variables
   always
   begin : reset_flag
      // process reset_flag
      if (VC_NUM > 0)
      begin
         forever #100000; // Only one VC needs to do this
      end
      else
      begin
         vc_intf_reset_flag(rstn);
      end
      @(rstn);
   end

  integer tx_pkts ;
  integer tx_qwords ;
  integer rx_pkts ;
  integer rx_qwords ;
  integer rx_dv_last ;
  reg clr_pndg ;

  initial
  begin
    clr_pndg = 0;
  end

  always@(posedge clk_in)
  begin
     if (vc_intf_sample_perf(VC_NUM) == 1'b1)
     begin
        if (clr_pndg == 1'b0)
        begin
           vc_intf_set_perf(VC_NUM,tx_pkts,tx_qwords,rx_pkts,rx_qwords);
           tx_pkts   = 0 ;
           tx_qwords = 0 ;
           rx_pkts   = 0 ;
           rx_qwords = 0 ;
           clr_pndg  = 1'b1 ;
        end
     end
     else
     begin
        if (clr_pndg == 1'b1)
           begin
              vc_intf_clr_perf(VC_NUM) ;
              clr_pndg = 1'b0 ;
           end
     end
     if (tx_dv_last == 1'b1 && tx_ws == 1'b0)
     begin
        tx_qwords = tx_qwords + 1;
     end
     if (tx_req_int == 1'b1 && tx_ack == 1'b1)
     begin
        tx_pkts = tx_pkts + 1;
     end
     if (rx_dv_last == 1'b1 && rx_ws_int == 1'b0)
     begin
        rx_qwords = rx_qwords + 1;
     end
     if (rx_req == 1'b1 && rx_ack_int == 1'b1)
     begin
        rx_pkts = rx_pkts + 1;
     end
     rx_dv_last = rx_dv ;
  end

endmodule
`timescale 1 ps / 1 ps
//-----------------------------------------------------------------------------
// Title         : PCI Express BFM with Root Port
// Project       : PCI Express MegaCore function
//-----------------------------------------------------------------------------
// File          : altpcietb_bfm_rp_top_x8_pipen1b.vhd
// Author        : Altera Corporation
//-----------------------------------------------------------------------------
// Description :
// This entity is the entire PCI Ecpress Root Port BFM
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
module altpcietb_bfm_rp_top_x8_pipen1b (clk250_in, clk500_in, local_rstn, pcie_rstn, swdn_out, rx_in0, tx_out0, rx_in1, tx_out1, rx_in2, tx_out2, rx_in3, tx_out3, rx_in4, tx_out4, rx_in5, tx_out5, rx_in6, tx_out6, rx_in7, tx_out7, pipe_mode, test_in, test_out, txdata0_ext, txdatak0_ext, txdetectrx0_ext, txelecidle0_ext, txcompl0_ext, rxpolarity0_ext, powerdown0_ext, rxdata0_ext, rxdatak0_ext, rxvalid0_ext, phystatus0_ext, rxelecidle0_ext, rxstatus0_ext, txdata1_ext, txdatak1_ext, txdetectrx1_ext, txelecidle1_ext, txcompl1_ext, rxpolarity1_ext, powerdown1_ext, rxdata1_ext, rxdatak1_ext, rxvalid1_ext, phystatus1_ext, rxelecidle1_ext, rxstatus1_ext, txdata2_ext, txdatak2_ext, txdetectrx2_ext, txelecidle2_ext, txcompl2_ext, rxpolarity2_ext, powerdown2_ext, rxdata2_ext, rxdatak2_ext, rxvalid2_ext, phystatus2_ext, rxelecidle2_ext, rxstatus2_ext, txdata3_ext, txdatak3_ext, txdetectrx3_ext, txelecidle3_ext, txcompl3_ext, rxpolarity3_ext, powerdown3_ext, rxdata3_ext, rxdatak3_ext, rxvalid3_ext, phystatus3_ext, rxelecidle3_ext, rxstatus3_ext, txdata4_ext, txdatak4_ext, txdetectrx4_ext, txelecidle4_ext, txcompl4_ext, rxpolarity4_ext, powerdown4_ext, rxdata4_ext, rxdatak4_ext, rxvalid4_ext, phystatus4_ext, rxelecidle4_ext, rxstatus4_ext, txdata5_ext, txdatak5_ext, txdetectrx5_ext, txelecidle5_ext, txcompl5_ext, rxpolarity5_ext, powerdown5_ext, rxdata5_ext, rxdatak5_ext, rxvalid5_ext, phystatus5_ext, rxelecidle5_ext, rxstatus5_ext, txdata6_ext, txdatak6_ext, txdetectrx6_ext, txelecidle6_ext, txcompl6_ext, rxpolarity6_ext, powerdown6_ext, rxdata6_ext, rxdatak6_ext, rxvalid6_ext, phystatus6_ext, rxelecidle6_ext, rxstatus6_ext, txdata7_ext, txdatak7_ext, txdetectrx7_ext, txelecidle7_ext, txcompl7_ext, rxpolarity7_ext, powerdown7_ext, rxdata7_ext, rxdatak7_ext, rxvalid7_ext, phystatus7_ext, rxelecidle7_ext, rxstatus7_ext,rate_ext);

   // Root Port Primary Side Bus Number and Device Number
   localparam [7:0] RP_PRI_BUS_NUM = 8'h00 ;
   localparam [4:0] RP_PRI_DEV_NUM = 5'b00000 ;
   // Root Port Requester ID
   localparam[15:0] RP_REQ_ID = {RP_PRI_BUS_NUM, RP_PRI_DEV_NUM , 3'b000}; // used in the Requests sent out
   // 2MB of memory
   localparam SHMEM_ADDR_WIDTH = 21;
   // The first section of the PCI Express I/O Space will be reserved for
   // addressing the Root Port's Shared Memory. PCI Express I/O Initiators
   // would use an I/O address in this range to access the shared memory.
   // Likewise the first section of the PCI Express Memory Space will be
   // reserved for accessing the Root Port's Shared Memory. PCI Express
   // Memory Initiators will use this range to access this memory.
   // These values here set the range that can be used to assign the
   // EP BARs to.
   localparam[31:0] EBFM_BAR_IO_MIN = 32'b1 << SHMEM_ADDR_WIDTH ;
   localparam[31:0] EBFM_BAR_IO_MAX = {32{1'b1}};
   localparam[31:0] EBFM_BAR_M32_MIN = 32'b1 << SHMEM_ADDR_WIDTH ;
   localparam[31:0] EBFM_BAR_M32_MAX = {32{1'b1}};
   localparam[63:0] EBFM_BAR_M64_MIN = 64'h0000000100000000 ;
   localparam[63:0] EBFM_BAR_M64_MAX = {64{1'b1}};
   localparam EBFM_NUM_VC = 4; // Number of VC's implemented in the Root Port BFM
   localparam EBFM_NUM_TAG = 32; // Number of TAG's used by Root Port BFM

   // Constants for the logging package
   localparam EBFM_MSG_DEBUG = 0;
   localparam EBFM_MSG_INFO = 1;
   localparam EBFM_MSG_WARNING = 2;
   localparam EBFM_MSG_ERROR_INFO = 3; // Preliminary Error Info Message
   localparam EBFM_MSG_ERROR_CONTINUE = 4;
   // Fatal Error Messages always stop the simulation
   localparam EBFM_MSG_ERROR_FATAL = 101;
   localparam EBFM_MSG_ERROR_FATAL_TB_ERR = 102;

   // Maximum Message Length in characters
   localparam EBFM_MSG_MAX_LEN = 100 ;

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
                         expline = {"    Expected Data: ", himage2(data[(incr_count * 8)+:8]), "              "};
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
                         expline = {"    Expected Data: ", himage2(data[(incr_count * 8)+:8]), "              "};
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
                         expline = {"    Expected Data: ", himage2(data[(incr_count * 8)+:8]), "              "};
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

   input clk250_in;
   input clk500_in;
   input local_rstn;
   input pcie_rstn;
   output [5:0] swdn_out;
   input rx_in0;
   output tx_out0;
   wire tx_out0;
   input rx_in1;
   output tx_out1;
   wire tx_out1;
   input rx_in2;
   output tx_out2;
   wire tx_out2;
   input rx_in3;
   output tx_out3;
   wire tx_out3;
   input rx_in4;
   output tx_out4;
   wire tx_out4;
   input rx_in5;
   output tx_out5;
   wire tx_out5;
   input rx_in6;
   output tx_out6;
   wire tx_out6;
   input rx_in7;
   output tx_out7;
   wire tx_out7;
   input pipe_mode;
   input[31:0] test_in;
   output[511:0] test_out;
   wire[511:0] test_out;
   output[7:0] txdata0_ext;
   wire[7:0] txdata0_ext;
   output txdatak0_ext;
   wire txdatak0_ext;
   output txdetectrx0_ext;
   wire txdetectrx0_ext;
output rate_ext;
   output txelecidle0_ext;
   wire txelecidle0_ext;
   output txcompl0_ext;
   wire txcompl0_ext;
   output rxpolarity0_ext;
   wire rxpolarity0_ext;
   output[1:0] powerdown0_ext;
   wire[1:0] powerdown0_ext;
   input[7:0] rxdata0_ext;
   input rxdatak0_ext;
   input rxvalid0_ext;
   input phystatus0_ext;
   input rxelecidle0_ext;
   input[2:0] rxstatus0_ext;
   output[7:0] txdata1_ext;
   wire[7:0] txdata1_ext;
   output txdatak1_ext;
   wire txdatak1_ext;
   output txdetectrx1_ext;
   wire txdetectrx1_ext;
   output txelecidle1_ext;
   wire txelecidle1_ext;
   output txcompl1_ext;
   wire txcompl1_ext;
   output rxpolarity1_ext;
   wire rxpolarity1_ext;
   output[1:0] powerdown1_ext;
   wire[1:0] powerdown1_ext;
   input[7:0] rxdata1_ext;
   input rxdatak1_ext;
   input rxvalid1_ext;
   input phystatus1_ext;
   input rxelecidle1_ext;
   input[2:0] rxstatus1_ext;
   output[7:0] txdata2_ext;
   wire[7:0] txdata2_ext;
   output txdatak2_ext;
   wire txdatak2_ext;
   output txdetectrx2_ext;
   wire txdetectrx2_ext;
   output txelecidle2_ext;
   wire txelecidle2_ext;
   output txcompl2_ext;
   wire txcompl2_ext;
   output rxpolarity2_ext;
   wire rxpolarity2_ext;
   output[1:0] powerdown2_ext;
   wire[1:0] powerdown2_ext;
   input[7:0] rxdata2_ext;
   input rxdatak2_ext;
   input rxvalid2_ext;
   input phystatus2_ext;
   input rxelecidle2_ext;
   input[2:0] rxstatus2_ext;
   output[7:0] txdata3_ext;
   wire[7:0] txdata3_ext;
   output txdatak3_ext;
   wire txdatak3_ext;
   output txdetectrx3_ext;
   wire txdetectrx3_ext;
   output txelecidle3_ext;
   wire txelecidle3_ext;
   output txcompl3_ext;
   wire txcompl3_ext;
   output rxpolarity3_ext;
   wire rxpolarity3_ext;
   output[1:0] powerdown3_ext;
   wire[1:0] powerdown3_ext;
   input[7:0] rxdata3_ext;
   input rxdatak3_ext;
   input rxvalid3_ext;
   input phystatus3_ext;
   input rxelecidle3_ext;
   input[2:0] rxstatus3_ext;
   output[7:0] txdata4_ext;
   wire[7:0] txdata4_ext;
   output txdatak4_ext;
   wire txdatak4_ext;
   output txdetectrx4_ext;
   wire txdetectrx4_ext;
   output txelecidle4_ext;
   wire txelecidle4_ext;
   output txcompl4_ext;
   wire txcompl4_ext;
   output rxpolarity4_ext;
   wire rxpolarity4_ext;
   output[1:0] powerdown4_ext;
   wire[1:0] powerdown4_ext;
   input[7:0] rxdata4_ext;
   input rxdatak4_ext;
   input rxvalid4_ext;
   input phystatus4_ext;
   input rxelecidle4_ext;
   input[2:0] rxstatus4_ext;
   output[7:0] txdata5_ext;
   wire[7:0] txdata5_ext;
   output txdatak5_ext;
   wire txdatak5_ext;
   output txdetectrx5_ext;
   wire txdetectrx5_ext;
   output txelecidle5_ext;
   wire txelecidle5_ext;
   output txcompl5_ext;
   wire txcompl5_ext;
   output rxpolarity5_ext;
   wire rxpolarity5_ext;
   output[1:0] powerdown5_ext;
   wire[1:0] powerdown5_ext;
   input[7:0] rxdata5_ext;
   input rxdatak5_ext;
   input rxvalid5_ext;
   input phystatus5_ext;
   input rxelecidle5_ext;
   input[2:0] rxstatus5_ext;
   output[7:0] txdata6_ext;
   wire[7:0] txdata6_ext;
   output txdatak6_ext;
   wire txdatak6_ext;
   output txdetectrx6_ext;
   wire txdetectrx6_ext;
   output txelecidle6_ext;
   wire txelecidle6_ext;
   output txcompl6_ext;
   wire txcompl6_ext;
   output rxpolarity6_ext;
   wire rxpolarity6_ext;
   output[1:0] powerdown6_ext;
   wire[1:0] powerdown6_ext;
   input[7:0] rxdata6_ext;
   input rxdatak6_ext;
   input rxvalid6_ext;
   input phystatus6_ext;
   input rxelecidle6_ext;
   input[2:0] rxstatus6_ext;
   output[7:0] txdata7_ext;
   wire[7:0] txdata7_ext;
   output txdatak7_ext;
   wire txdatak7_ext;
   output txdetectrx7_ext;
   wire txdetectrx7_ext;
   output txelecidle7_ext;
   wire txelecidle7_ext;
   output txcompl7_ext;
   wire txcompl7_ext;
   output rxpolarity7_ext;
   wire rxpolarity7_ext;
   output[1:0] powerdown7_ext;
   wire[1:0] powerdown7_ext;
   input[7:0] rxdata7_ext;
   input rxdatak7_ext;
   input rxvalid7_ext;
   input phystatus7_ext;
   input rxelecidle7_ext;
   input[2:0] rxstatus7_ext;

   wire[127:0] GND_BUS;
   wire l2_exit;
   wire hotrst_exit;
   wire dlup_exit;
   wire cpl_pending;
   wire[2:0] cpl_err;
   wire pme_to_cr;
   wire pme_to_sr;
   wire pm_auxpwr;
   wire[6:0] slotcap_in;
   wire[12:0] slotnum_in;
   wire serr_out;
   wire app_int_sts;
   wire app_msi_req;
   wire app_msi_ack;
   wire[2:0] app_msi_tc;
   wire[12:0] cfg_busdev;
   wire[31:0] cfg_prmcsr;
   wire[31:0] cfg_pmcsr;
   wire[15:0] cfg_msicsr;
   wire[31:0] cfg_devcsr;
   wire[31:0] cfg_linkcsr;
   wire[31:0] cfg_slotcsr;
   wire[31:0] cfg_rootcsr;
   wire[31:0] cfg_seccsr;
   wire[7:0] cfg_secbus;
   wire[7:0] cfg_subbus;
   wire[19:0] cfg_io_bas;
   wire[19:0] cfg_io_lim;
   wire[11:0] cfg_np_bas;
   wire[11:0] cfg_np_lim;
   wire[43:0] cfg_pr_bas;
   wire[43:0] cfg_pr_lim;
   wire[23:0] cfg_tcvcmap;
   wire[21:0] tx_cred0;
   wire[21:0] tx_cred1;
   wire[21:0] tx_cred2;
   wire[21:0] tx_cred3;
   wire rx_req0;
   wire rx_ack0;
   wire rx_abort0;
   wire rx_retry0;
   wire rx_mask0;
   wire[135:0] rx_desc0;
   wire rx_ws0;
   wire[63:0] rx_data0;
   wire[7:0] rx_be0;
   wire rx_dv0;
   wire rx_dfr0;
   wire tx_req0;
   wire[127:0] tx_desc0;
   wire tx_ack0;
   wire tx_dfr0;
   wire[63:0] tx_data0;
   wire tx_dv0;
   wire tx_err0;
   wire tx_ws0;
   wire rx_req1;
   wire rx_ack1;
   wire rx_abort1;
   wire rx_retry1;
   wire rx_mask1;
   wire[135:0] rx_desc1;
   wire rx_ws1;
   wire[63:0] rx_data1;
   wire[7:0] rx_be1;
   wire rx_dv1;
   wire rx_dfr1;
   wire tx_req1;
   wire[127:0] tx_desc1;
   wire tx_ack1;
   wire tx_dfr1;
   wire[63:0] tx_data1;
   wire tx_dv1;
   wire tx_err1;
   wire tx_ws1;
   wire rx_req2;
   wire rx_ack2;
   wire rx_abort2;
   wire rx_retry2;
   wire rx_mask2;
   wire[135:0] rx_desc2;
   wire rx_ws2;
   wire[63:0] rx_data2;
   wire[7:0] rx_be2;
   wire rx_dv2;
   wire rx_dfr2;
   wire tx_req2;
   wire[127:0] tx_desc2;
   wire tx_ack2;
   wire tx_dfr2;
   wire[63:0] tx_data2;
   wire tx_dv2;
   wire tx_err2;
   wire tx_ws2;
   wire rx_req3;
   wire rx_ack3;
   wire rx_abort3;
   wire rx_retry3;
   wire rx_mask3;
   wire[135:0] rx_desc3;
   wire rx_ws3;
   wire[63:0] rx_data3;
   wire[7:0] rx_be3;
   wire rx_dv3;
   wire rx_dfr3;
   wire tx_req3;
   wire[127:0] tx_desc3;
   wire tx_ack3;
   wire tx_dfr3;
   wire[63:0] tx_data3;
   wire tx_dv3;
   wire tx_err3;
   wire tx_ws3;
   reg[24:0] rsnt_cnt;
   reg rstn;
   wire npor;
   wire crst;
   wire srst;
   wire coreclk_out;
wire    clk_in = (pipe_mode == 0) ? coreclk_out :  ( rate_ext == 1) ? clk500_in : clk250_in;


   assign GND_BUS = {128{1'b0}} ;

   always @(posedge clk250_in or negedge pcie_rstn)
   begin
      if (pcie_rstn == 1'b0)
      begin
         rsnt_cnt <= {25{1'b0}} ;
         rstn <= 1'b0 ;
      end
      else
      begin
         if (rsnt_cnt != 25'b1110111001101011001010000)
         begin
            rsnt_cnt <= rsnt_cnt + 1 ;
         end
         if (local_rstn == 1'b0 | l2_exit == 1'b0 | hotrst_exit == 1'b0 | dlup_exit == 1'b0)
         begin
            rstn <= 1'b0 ;
         end
         else if ((test_in[0]) == 1'b1 & rsnt_cnt == 25'b0000000000000000000100000)
         begin
            rstn <= 1'b1 ;
         end
         else if (rsnt_cnt == 25'b1110111001101011001010000)
         begin
            rstn <= 1'b1 ;
         end
      end
   end
   assign npor = pcie_rstn & local_rstn ;
   assign srst = ~(hotrst_exit & l2_exit & dlup_exit & rstn) ;
   assign crst = ~(hotrst_exit & l2_exit & rstn) ;
   assign cpl_pending = 1'b0 ;
   assign cpl_err = 3'b000 ;
   assign pm_auxpwr = 1'b0 ;
   assign slotcap_in = 7'b0000000 ;
   assign slotnum_in = 13'b0000000000000 ;
   assign app_int_sts = 1'b0 ;
   assign app_msi_req = 1'b0 ;
   assign app_msi_tc = 3'b000 ;
   altpcietb_bfm_rpvar_64b_x8_pipen1b rp (
      .pclk_in(clk_in),
      .ep_clk250_in(clk250_in),
      .coreclk_out(coreclk_out),
      .npor(npor),
      .crst(crst),
      .srst(srst),
      .rx_in0(rx_in0),
      .tx_out0(tx_out0),
      .rx_in1(rx_in1),
      .tx_out1(tx_out1),
      .rx_in2(rx_in2),
      .tx_out2(tx_out2),
      .rx_in3(rx_in3),
      .tx_out3(tx_out3),
      .rx_in4(rx_in4),
      .tx_out4(tx_out4),
      .rx_in5(rx_in5),
      .tx_out5(tx_out5),
      .rx_in6(rx_in6),
      .tx_out6(tx_out6),
      .rx_in7(rx_in7),
      .tx_out7(tx_out7),
      .pipe_mode(pipe_mode),
      .rate_ext(rate_ext),
      .txdata0_ext(txdata0_ext),
      .txdatak0_ext(txdatak0_ext),
      .txdetectrx0_ext(txdetectrx0_ext),
      .txelecidle0_ext(txelecidle0_ext),
      .txcompl0_ext(txcompl0_ext),
      .rxpolarity0_ext(rxpolarity0_ext),
      .powerdown0_ext(powerdown0_ext),
      .rxdata0_ext(rxdata0_ext),
      .rxdatak0_ext(rxdatak0_ext),
      .rxvalid0_ext(rxvalid0_ext),
      .phystatus0_ext(phystatus0_ext),
      .rxelecidle0_ext(rxelecidle0_ext),
      .rxstatus0_ext(rxstatus0_ext),
      .txdata1_ext(txdata1_ext),
      .txdatak1_ext(txdatak1_ext),
      .txdetectrx1_ext(txdetectrx1_ext),
      .txelecidle1_ext(txelecidle1_ext),
      .txcompl1_ext(txcompl1_ext),
      .rxpolarity1_ext(rxpolarity1_ext),
      .powerdown1_ext(powerdown1_ext),
      .rxdata1_ext(rxdata1_ext),
      .rxdatak1_ext(rxdatak1_ext),
      .rxvalid1_ext(rxvalid1_ext),
      .phystatus1_ext(phystatus1_ext),
      .rxelecidle1_ext(rxelecidle1_ext),
      .rxstatus1_ext(rxstatus1_ext),
      .txdata2_ext(txdata2_ext),
      .txdatak2_ext(txdatak2_ext),
      .txdetectrx2_ext(txdetectrx2_ext),
      .txelecidle2_ext(txelecidle2_ext),
      .txcompl2_ext(txcompl2_ext),
      .rxpolarity2_ext(rxpolarity2_ext),
      .powerdown2_ext(powerdown2_ext),
      .rxdata2_ext(rxdata2_ext),
      .rxdatak2_ext(rxdatak2_ext),
      .rxvalid2_ext(rxvalid2_ext),
      .phystatus2_ext(phystatus2_ext),
      .rxelecidle2_ext(rxelecidle2_ext),
      .rxstatus2_ext(rxstatus2_ext),
      .txdata3_ext(txdata3_ext),
      .txdatak3_ext(txdatak3_ext),
      .txdetectrx3_ext(txdetectrx3_ext),
      .txelecidle3_ext(txelecidle3_ext),
      .txcompl3_ext(txcompl3_ext),
      .rxpolarity3_ext(rxpolarity3_ext),
      .powerdown3_ext(powerdown3_ext),
      .rxdata3_ext(rxdata3_ext),
      .rxdatak3_ext(rxdatak3_ext),
      .rxvalid3_ext(rxvalid3_ext),
      .phystatus3_ext(phystatus3_ext),
      .rxelecidle3_ext(rxelecidle3_ext),
      .rxstatus3_ext(rxstatus3_ext),
      .txdata4_ext(txdata4_ext),
      .txdatak4_ext(txdatak4_ext),
      .txdetectrx4_ext(txdetectrx4_ext),
      .txelecidle4_ext(txelecidle4_ext),
      .txcompl4_ext(txcompl4_ext),
      .rxpolarity4_ext(rxpolarity4_ext),
      .powerdown4_ext(powerdown4_ext),
      .rxdata4_ext(rxdata4_ext),
      .rxdatak4_ext(rxdatak4_ext),
      .rxvalid4_ext(rxvalid4_ext),
      .phystatus4_ext(phystatus4_ext),
      .rxelecidle4_ext(rxelecidle4_ext),
      .rxstatus4_ext(rxstatus4_ext),
      .txdata5_ext(txdata5_ext),
      .txdatak5_ext(txdatak5_ext),
      .txdetectrx5_ext(txdetectrx5_ext),
      .txelecidle5_ext(txelecidle5_ext),
      .txcompl5_ext(txcompl5_ext),
      .rxpolarity5_ext(rxpolarity5_ext),
      .powerdown5_ext(powerdown5_ext),
      .rxdata5_ext(rxdata5_ext),
      .rxdatak5_ext(rxdatak5_ext),
      .rxvalid5_ext(rxvalid5_ext),
      .phystatus5_ext(phystatus5_ext),
      .rxelecidle5_ext(rxelecidle5_ext),
      .rxstatus5_ext(rxstatus5_ext),
      .txdata6_ext(txdata6_ext),
      .txdatak6_ext(txdatak6_ext),
      .txdetectrx6_ext(txdetectrx6_ext),
      .txelecidle6_ext(txelecidle6_ext),
      .txcompl6_ext(txcompl6_ext),
      .rxpolarity6_ext(rxpolarity6_ext),
      .powerdown6_ext(powerdown6_ext),
      .rxdata6_ext(rxdata6_ext),
      .rxdatak6_ext(rxdatak6_ext),
      .rxvalid6_ext(rxvalid6_ext),
      .phystatus6_ext(phystatus6_ext),
      .rxelecidle6_ext(rxelecidle6_ext),
      .rxstatus6_ext(rxstatus6_ext),
      .txdata7_ext(txdata7_ext),
      .txdatak7_ext(txdatak7_ext),
      .txdetectrx7_ext(txdetectrx7_ext),
      .txelecidle7_ext(txelecidle7_ext),
      .txcompl7_ext(txcompl7_ext),
      .rxpolarity7_ext(rxpolarity7_ext),
      .powerdown7_ext(powerdown7_ext),
      .rxdata7_ext(rxdata7_ext),
      .rxdatak7_ext(rxdatak7_ext),
      .rxvalid7_ext(rxvalid7_ext),
      .phystatus7_ext(phystatus7_ext),
      .rxelecidle7_ext(rxelecidle7_ext),
      .rxstatus7_ext(rxstatus7_ext),
      .test_in(test_in),
      .test_out(test_out),
      .l2_exit(l2_exit),
      .hotrst_exit(hotrst_exit),
      .dlup_exit(dlup_exit),
      .cpl_pending(cpl_pending),
      .cpl_err(cpl_err),
      .pme_to_cr(pme_to_cr),
      .pme_to_sr(pme_to_cr),
      .pm_auxpwr(pm_auxpwr),
      .slotcap_in(slotcap_in),
      .slotnum_in(slotnum_in),
      .serr_out(serr_out),
      .swdn_out(swdn_out),
      .app_int_sts(app_int_sts),
      .app_msi_req(app_msi_req),
      .app_msi_ack(app_msi_ack),
      .app_msi_tc(app_msi_tc),
      .cfg_busdev(cfg_busdev),
      .cfg_prmcsr(cfg_prmcsr),
      .cfg_pmcsr(cfg_pmcsr),
      .cfg_msicsr(cfg_msicsr),
      .cfg_devcsr(cfg_devcsr),
      .cfg_linkcsr(cfg_linkcsr),
      .cfg_slotcsr(cfg_slotcsr),
      .cfg_rootcsr(cfg_rootcsr),
      .cfg_seccsr(cfg_seccsr),
      .cfg_secbus(cfg_secbus),
      .cfg_subbus(cfg_subbus),
      .cfg_io_bas(cfg_io_bas),
      .cfg_io_lim(cfg_io_lim),
      .cfg_np_bas(cfg_np_bas),
      .cfg_np_lim(cfg_np_lim),
      .cfg_pr_bas(cfg_pr_bas),
      .cfg_pr_lim(cfg_pr_lim),
      .cfg_tcvcmap(cfg_tcvcmap),
      .tx_cred0(tx_cred0),
      .tx_cred1(tx_cred1),
      .tx_cred2(tx_cred2),
      .tx_cred3(tx_cred3),
      .rx_req0(rx_req0),
      .rx_ack0(rx_ack0),
      .rx_abort0(rx_abort0),
      .rx_retry0(rx_retry0),
      .rx_mask0(rx_mask0),
      .rx_desc0(rx_desc0),
      .rx_ws0(rx_ws0),
      .rx_data0(rx_data0),
      .rx_be0(rx_be0),
      .rx_dv0(rx_dv0),
      .rx_dfr0(rx_dfr0),
      .tx_req0(tx_req0),
      .tx_desc0(tx_desc0),
      .tx_ack0(tx_ack0),
      .tx_dfr0(tx_dfr0),
      .tx_data0(tx_data0),
      .tx_dv0(tx_dv0),
      .tx_err0(tx_err0),
      .tx_ws0(tx_ws0),
      .rx_req1(rx_req1),
      .rx_ack1(rx_ack1),
      .rx_abort1(rx_abort1),
      .rx_retry1(rx_retry1),
      .rx_mask1(rx_mask1),
      .rx_desc1(rx_desc1),
      .rx_ws1(rx_ws1),
      .rx_data1(rx_data1),
      .rx_be1(rx_be1),
      .rx_dv1(rx_dv1),
      .rx_dfr1(rx_dfr1),
      .tx_req1(tx_req1),
      .tx_desc1(tx_desc1),
      .tx_ack1(tx_ack1),
      .tx_dfr1(tx_dfr1),
      .tx_data1(tx_data1),
      .tx_dv1(tx_dv1),
      .tx_err1(tx_err1),
      .tx_ws1(tx_ws1),
      .rx_req2(rx_req2),
      .rx_ack2(rx_ack2),
      .rx_abort2(rx_abort2),
      .rx_retry2(rx_retry2),
      .rx_mask2(rx_mask2),
      .rx_desc2(rx_desc2),
      .rx_ws2(rx_ws2),
      .rx_data2(rx_data2),
      .rx_be2(rx_be2),
      .rx_dv2(rx_dv2),
      .rx_dfr2(rx_dfr2),
      .tx_req2(tx_req2),
      .tx_desc2(tx_desc2),
      .tx_ack2(tx_ack2),
      .tx_dfr2(tx_dfr2),
      .tx_data2(tx_data2),
      .tx_dv2(tx_dv2),
      .tx_err2(tx_err2),
      .tx_ws2(tx_ws2),
      .rx_req3(rx_req3),
      .rx_ack3(rx_ack3),
      .rx_abort3(rx_abort3),
      .rx_retry3(rx_retry3),
      .rx_mask3(rx_mask3),
      .rx_desc3(rx_desc3),
      .rx_ws3(rx_ws3),
      .rx_data3(rx_data3),
      .rx_be3(rx_be3),
      .rx_dv3(rx_dv3),
      .rx_dfr3(rx_dfr3),
      .tx_req3(tx_req3),
      .tx_desc3(tx_desc3),
      .tx_ack3(tx_ack3),
      .tx_dfr3(tx_dfr3),
      .tx_data3(tx_data3),
      .tx_dv3(tx_dv3),
      .tx_err3(tx_err3),
      .tx_ws3(tx_ws3)
   );

   altpcietb_bfm_vc_intf #(0) vc0(
      .clk_in(clk_in),
      .rstn(rstn),
      .rx_req(rx_req0),
      .rx_ack(rx_ack0),
      .rx_abort(rx_abort0),
      .rx_retry(rx_retry0),
      .rx_mask(rx_mask0),
      .rx_desc(rx_desc0),
      .rx_ws(rx_ws0),
      .rx_data(rx_data0),
      .rx_be(rx_be0),
      .rx_dv(rx_dv0),
      .rx_dfr(rx_dfr0),
      .tx_cred(tx_cred0),
      .tx_req(tx_req0),
      .tx_desc(tx_desc0),
      .tx_ack(tx_ack0),
      .tx_dfr(tx_dfr0),
      .tx_data(tx_data0),
      .tx_dv(tx_dv0),
      .tx_err(tx_err0),
      .tx_ws(tx_ws0),
      .cfg_io_bas(cfg_io_bas),
      .cfg_np_bas(cfg_np_bas),
      .cfg_pr_bas(cfg_pr_bas)
   );

   altpcietb_bfm_vc_intf #(1) vc1(
      .clk_in(clk_in),
      .rstn(rstn),
      .rx_req(rx_req1),
      .rx_ack(rx_ack1),
      .rx_abort(rx_abort1),
      .rx_retry(rx_retry1),
      .rx_mask(rx_mask1),
      .rx_desc(rx_desc1),
      .rx_ws(rx_ws1),
      .rx_data(rx_data1),
      .rx_be(rx_be1),
      .rx_dv(rx_dv1),
      .rx_dfr(rx_dfr1),
      .tx_cred(tx_cred1),
      .tx_req(tx_req1),
      .tx_desc(tx_desc1),
      .tx_ack(tx_ack1),
      .tx_dfr(tx_dfr1),
      .tx_data(tx_data1),
      .tx_dv(tx_dv1),
      .tx_err(tx_err1),
      .tx_ws(tx_ws1),
      .cfg_io_bas(cfg_io_bas),
      .cfg_np_bas(cfg_np_bas),
      .cfg_pr_bas(cfg_pr_bas)
   );

   altpcietb_bfm_vc_intf #(2) vc2(
      .clk_in(clk_in),
      .rstn(rstn),
      .rx_req(rx_req2),
      .rx_ack(rx_ack2),
      .rx_abort(rx_abort2),
      .rx_retry(rx_retry2),
      .rx_mask(rx_mask2),
      .rx_desc(rx_desc2),
      .rx_ws(rx_ws2),
      .rx_data(rx_data2),
      .rx_be(rx_be2),
      .rx_dv(rx_dv2),
      .rx_dfr(rx_dfr2),
      .tx_cred(tx_cred2),
      .tx_req(tx_req2),
      .tx_desc(tx_desc2),
      .tx_ack(tx_ack2),
      .tx_dfr(tx_dfr2),
      .tx_data(tx_data2),
      .tx_dv(tx_dv2),
      .tx_err(tx_err2),
      .tx_ws(tx_ws2),
      .cfg_io_bas(cfg_io_bas),
      .cfg_np_bas(cfg_np_bas),
      .cfg_pr_bas(cfg_pr_bas)
   );

   altpcietb_bfm_vc_intf #(3) vc3(
      .clk_in(clk_in),
      .rstn(rstn),
      .rx_req(rx_req3),
      .rx_ack(rx_ack3),
      .rx_abort(rx_abort3),
      .rx_retry(rx_retry3),
      .rx_mask(rx_mask3),
      .rx_desc(rx_desc3),
      .rx_ws(rx_ws3),
      .rx_data(rx_data3),
      .rx_be(rx_be3),
      .rx_dv(rx_dv3),
      .rx_dfr(rx_dfr3),
      .tx_cred(tx_cred3),
      .tx_req(tx_req3),
      .tx_desc(tx_desc3),
      .tx_ack(tx_ack3),
      .tx_dfr(tx_dfr3),
      .tx_data(tx_data3),
      .tx_dv(tx_dv3),
      .tx_err(tx_err3),
      .tx_ws(tx_ws3),
      .cfg_io_bas(cfg_io_bas),
      .cfg_np_bas(cfg_np_bas),
      .cfg_pr_bas(cfg_pr_bas)
   );

endmodule
//IP Functional Simulation Model
//VERSION_BEGIN 9.0 cbx_mgl 2009:01:29:16:12:07:SJ cbx_simgen 2008:08:06:16:30:59:SJ  VERSION_END
// synthesis VERILOG_INPUT_VERSION VERILOG_2001
// altera message_off 10463



// Legal Notice: (c) 2003 Altera Corporation. All rights reserved.
// You may only use these  simulation  model  output files for simulation
// purposes and expressly not for synthesis or any other purposes (in which
// event  Altera disclaims all warranties of any kind). Your use of  Altera
// Corporation's design tools, logic functions and other software and tools,
// and its AMPP partner logic functions, and any output files any of the
// foregoing (including device programming or simulation files), and any
// associated documentation or information  are expressly subject to the
// terms and conditions of the  Altera Program License Subscription Agreement
// or other applicable license agreement, including, without limitation, that
// your use is for the sole purpose of programming logic devices manufactured
// by Altera and sold by Altera or its authorized distributors.  Please refer
// to the applicable agreement for further details.


//synopsys translate_off

//synthesis_resources = altpll 1 altsyncram 16 lut 11567 mux21 51088 oper_add 423 oper_decoder 2 oper_less_than 195 oper_mux 15 oper_selector 357 stratixiigx_hssi_calibration_block 1 stratixiigx_hssi_central_management_unit 2 stratixiigx_hssi_cmu_clock_divider 2 stratixiigx_hssi_cmu_pll 1 stratixiigx_hssi_receiver 8 stratixiigx_hssi_refclk_divider 9 stratixiigx_hssi_transmitter 8
`timescale 1 ps / 1 ps
module  altpcietb_bfm_rpvar_64b_x8_pipen1b
        (
        app_int_sts,
        app_msi_ack,
        app_msi_req,
        app_msi_tc,
        cfg_busdev,
        cfg_devcsr,
        cfg_io_bas,
        cfg_io_lim,
        cfg_linkcsr,
        cfg_msicsr,
        cfg_np_bas,
        cfg_np_lim,
        cfg_pmcsr,
        cfg_pr_bas,
        cfg_pr_lim,
        cfg_prmcsr,
        cfg_rootcsr,
        cfg_secbus,
        cfg_seccsr,
        cfg_slotcsr,
        cfg_subbus,
        cfg_tcvcmap,
        coreclk_out,
        cpl_err,
        cpl_pending,
        crst,
        dlup_exit,
        ep_clk250_in,
        hotrst_exit,
        l2_exit,
        npor,
        pclk_in,
        phystatus0_ext,
        phystatus1_ext,
        phystatus2_ext,
        phystatus3_ext,
        phystatus4_ext,
        phystatus5_ext,
        phystatus6_ext,
        phystatus7_ext,
        pipe_mode,
        pm_auxpwr,
        pme_to_cr,
        pme_to_sr,
        powerdown0_ext,
        powerdown1_ext,
        powerdown2_ext,
        powerdown3_ext,
        powerdown4_ext,
        powerdown5_ext,
        powerdown6_ext,
        powerdown7_ext,
        rate_ext,
        rx_abort0,
        rx_abort1,
        rx_abort2,
        rx_abort3,
        rx_ack0,
        rx_ack1,
        rx_ack2,
        rx_ack3,
        rx_be0,
        rx_be1,
        rx_be2,
        rx_be3,
        rx_data0,
        rx_data1,
        rx_data2,
        rx_data3,
        rx_desc0,
        rx_desc1,
        rx_desc2,
        rx_desc3,
        rx_dfr0,
        rx_dfr1,
        rx_dfr2,
        rx_dfr3,
        rx_dv0,
        rx_dv1,
        rx_dv2,
        rx_dv3,
        rx_in0,
        rx_in1,
        rx_in2,
        rx_in3,
        rx_in4,
        rx_in5,
        rx_in6,
        rx_in7,
        rx_mask0,
        rx_mask1,
        rx_mask2,
        rx_mask3,
        rx_req0,
        rx_req1,
        rx_req2,
        rx_req3,
        rx_retry0,
        rx_retry1,
        rx_retry2,
        rx_retry3,
        rx_ws0,
        rx_ws1,
        rx_ws2,
        rx_ws3,
        rxdata0_ext,
        rxdata1_ext,
        rxdata2_ext,
        rxdata3_ext,
        rxdata4_ext,
        rxdata5_ext,
        rxdata6_ext,
        rxdata7_ext,
        rxdatak0_ext,
        rxdatak1_ext,
        rxdatak2_ext,
        rxdatak3_ext,
        rxdatak4_ext,
        rxdatak5_ext,
        rxdatak6_ext,
        rxdatak7_ext,
        rxelecidle0_ext,
        rxelecidle1_ext,
        rxelecidle2_ext,
        rxelecidle3_ext,
        rxelecidle4_ext,
        rxelecidle5_ext,
        rxelecidle6_ext,
        rxelecidle7_ext,
        rxpolarity0_ext,
        rxpolarity1_ext,
        rxpolarity2_ext,
        rxpolarity3_ext,
        rxpolarity4_ext,
        rxpolarity5_ext,
        rxpolarity6_ext,
        rxpolarity7_ext,
        rxstatus0_ext,
        rxstatus1_ext,
        rxstatus2_ext,
        rxstatus3_ext,
        rxstatus4_ext,
        rxstatus5_ext,
        rxstatus6_ext,
        rxstatus7_ext,
        rxvalid0_ext,
        rxvalid1_ext,
        rxvalid2_ext,
        rxvalid3_ext,
        rxvalid4_ext,
        rxvalid5_ext,
        rxvalid6_ext,
        rxvalid7_ext,
        serr_out,
        slotcap_in,
        slotnum_in,
        srst,
        swdn_out,
        test_in,
        test_out,
        tx_ack0,
        tx_ack1,
        tx_ack2,
        tx_ack3,
        tx_cred0,
        tx_cred1,
        tx_cred2,
        tx_cred3,
        tx_data0,
        tx_data1,
        tx_data2,
        tx_data3,
        tx_desc0,
        tx_desc1,
        tx_desc2,
        tx_desc3,
        tx_dfr0,
        tx_dfr1,
        tx_dfr2,
        tx_dfr3,
        tx_dv0,
        tx_dv1,
        tx_dv2,
        tx_dv3,
        tx_err0,
        tx_err1,
        tx_err2,
        tx_err3,
        tx_out0,
        tx_out1,
        tx_out2,
        tx_out3,
        tx_out4,
        tx_out5,
        tx_out6,
        tx_out7,
        tx_req0,
        tx_req1,
        tx_req2,
        tx_req3,
        tx_ws0,
        tx_ws1,
        tx_ws2,
        tx_ws3,
        txcompl0_ext,
        txcompl1_ext,
        txcompl2_ext,
        txcompl3_ext,
        txcompl4_ext,
        txcompl5_ext,
        txcompl6_ext,
        txcompl7_ext,
        txdata0_ext,
        txdata1_ext,
        txdata2_ext,
        txdata3_ext,
        txdata4_ext,
        txdata5_ext,
        txdata6_ext,
        txdata7_ext,
        txdatak0_ext,
        txdatak1_ext,
        txdatak2_ext,
        txdatak3_ext,
        txdatak4_ext,
        txdatak5_ext,
        txdatak6_ext,
        txdatak7_ext,
        txdetectrx0_ext,
        txdetectrx1_ext,
        txdetectrx2_ext,
        txdetectrx3_ext,
        txdetectrx4_ext,
        txdetectrx5_ext,
        txdetectrx6_ext,
        txdetectrx7_ext,
        txelecidle0_ext,
        txelecidle1_ext,
        txelecidle2_ext,
        txelecidle3_ext,
        txelecidle4_ext,
        txelecidle5_ext,
        txelecidle6_ext,
        txelecidle7_ext) /* synthesis synthesis_clearbox=1 */;
        input   app_int_sts;
        output   app_msi_ack;
        input   app_msi_req;
        input   [2:0]  app_msi_tc;
        output   [12:0]  cfg_busdev;
        output   [31:0]  cfg_devcsr;
        output   [19:0]  cfg_io_bas;
        output   [19:0]  cfg_io_lim;
        output   [31:0]  cfg_linkcsr;
        output   [15:0]  cfg_msicsr;
        output   [11:0]  cfg_np_bas;
        output   [11:0]  cfg_np_lim;
        output   [31:0]  cfg_pmcsr;
        output   [43:0]  cfg_pr_bas;
        output   [43:0]  cfg_pr_lim;
        output   [31:0]  cfg_prmcsr;
        output   [31:0]  cfg_rootcsr;
        output   [7:0]  cfg_secbus;
        output   [31:0]  cfg_seccsr;
        output   [31:0]  cfg_slotcsr;
        output   [7:0]  cfg_subbus;
        output   [23:0]  cfg_tcvcmap;
        output   coreclk_out;
        input   [2:0]  cpl_err;
        input   cpl_pending;
        input   crst;
        output   dlup_exit;
        input   ep_clk250_in;
        output   hotrst_exit;
        output   l2_exit;
        input   npor;
        input   pclk_in;
        input   phystatus0_ext;
        input   phystatus1_ext;
        input   phystatus2_ext;
        input   phystatus3_ext;
        input   phystatus4_ext;
        input   phystatus5_ext;
        input   phystatus6_ext;
        input   phystatus7_ext;
        input   pipe_mode;
        input   pm_auxpwr;
        input   pme_to_cr;
        output   pme_to_sr;
        output   [1:0]  powerdown0_ext;
        output   [1:0]  powerdown1_ext;
        output   [1:0]  powerdown2_ext;
        output   [1:0]  powerdown3_ext;
        output   [1:0]  powerdown4_ext;
        output   [1:0]  powerdown5_ext;
        output   [1:0]  powerdown6_ext;
        output   [1:0]  powerdown7_ext;
        output   rate_ext;
        input   rx_abort0;
        input   rx_abort1;
        input   rx_abort2;
        input   rx_abort3;
        input   rx_ack0;
        input   rx_ack1;
        input   rx_ack2;
        input   rx_ack3;
        output   [7:0]  rx_be0;
        output   [7:0]  rx_be1;
        output   [7:0]  rx_be2;
        output   [7:0]  rx_be3;
        output   [63:0]  rx_data0;
        output   [63:0]  rx_data1;
        output   [63:0]  rx_data2;
        output   [63:0]  rx_data3;
        output   [135:0]  rx_desc0;
        output   [135:0]  rx_desc1;
        output   [135:0]  rx_desc2;
        output   [135:0]  rx_desc3;
        output   rx_dfr0;
        output   rx_dfr1;
        output   rx_dfr2;
        output   rx_dfr3;
        output   rx_dv0;
        output   rx_dv1;
        output   rx_dv2;
        output   rx_dv3;
        input   rx_in0;
        input   rx_in1;
        input   rx_in2;
        input   rx_in3;
        input   rx_in4;
        input   rx_in5;
        input   rx_in6;
        input   rx_in7;
        input   rx_mask0;
        input   rx_mask1;
        input   rx_mask2;
        input   rx_mask3;
        output   rx_req0;
        output   rx_req1;
        output   rx_req2;
        output   rx_req3;
        input   rx_retry0;
        input   rx_retry1;
        input   rx_retry2;
        input   rx_retry3;
        input   rx_ws0;
        input   rx_ws1;
        input   rx_ws2;
        input   rx_ws3;
        input   [7:0]  rxdata0_ext;
        input   [7:0]  rxdata1_ext;
        input   [7:0]  rxdata2_ext;
        input   [7:0]  rxdata3_ext;
        input   [7:0]  rxdata4_ext;
        input   [7:0]  rxdata5_ext;
        input   [7:0]  rxdata6_ext;
        input   [7:0]  rxdata7_ext;
        input   rxdatak0_ext;
        input   rxdatak1_ext;
        input   rxdatak2_ext;
        input   rxdatak3_ext;
        input   rxdatak4_ext;
        input   rxdatak5_ext;
        input   rxdatak6_ext;
        input   rxdatak7_ext;
        input   rxelecidle0_ext;
        input   rxelecidle1_ext;
        input   rxelecidle2_ext;
        input   rxelecidle3_ext;
        input   rxelecidle4_ext;
        input   rxelecidle5_ext;
        input   rxelecidle6_ext;
        input   rxelecidle7_ext;
        output   rxpolarity0_ext;
        output   rxpolarity1_ext;
        output   rxpolarity2_ext;
        output   rxpolarity3_ext;
        output   rxpolarity4_ext;
        output   rxpolarity5_ext;
        output   rxpolarity6_ext;
        output   rxpolarity7_ext;
        input   [2:0]  rxstatus0_ext;
        input   [2:0]  rxstatus1_ext;
        input   [2:0]  rxstatus2_ext;
        input   [2:0]  rxstatus3_ext;
        input   [2:0]  rxstatus4_ext;
        input   [2:0]  rxstatus5_ext;
        input   [2:0]  rxstatus6_ext;
        input   [2:0]  rxstatus7_ext;
        input   rxvalid0_ext;
        input   rxvalid1_ext;
        input   rxvalid2_ext;
        input   rxvalid3_ext;
        input   rxvalid4_ext;
        input   rxvalid5_ext;
        input   rxvalid6_ext;
        input   rxvalid7_ext;
        output   serr_out;
        input   [6:0]  slotcap_in;
        input   [12:0]  slotnum_in;
        input   srst;
        output   [5:0]  swdn_out;
        input   [31:0]  test_in;
        output   [511:0]  test_out;
        output   tx_ack0;
        output   tx_ack1;
        output   tx_ack2;
        output   tx_ack3;
        output   [21:0]  tx_cred0;
        output   [21:0]  tx_cred1;
        output   [21:0]  tx_cred2;
        output   [21:0]  tx_cred3;
        input   [63:0]  tx_data0;
        input   [63:0]  tx_data1;
        input   [63:0]  tx_data2;
        input   [63:0]  tx_data3;
        input   [127:0]  tx_desc0;
        input   [127:0]  tx_desc1;
        input   [127:0]  tx_desc2;
        input   [127:0]  tx_desc3;
        input   tx_dfr0;
        input   tx_dfr1;
        input   tx_dfr2;
        input   tx_dfr3;
        input   tx_dv0;
        input   tx_dv1;
        input   tx_dv2;
        input   tx_dv3;
        input   tx_err0;
        input   tx_err1;
        input   tx_err2;
        input   tx_err3;
        output   tx_out0;
        output   tx_out1;
        output   tx_out2;
        output   tx_out3;
        output   tx_out4;
        output   tx_out5;
        output   tx_out6;
        output   tx_out7;
        input   tx_req0;
        input   tx_req1;
        input   tx_req2;
        input   tx_req3;
        output   tx_ws0;
        output   tx_ws1;
        output   tx_ws2;
        output   tx_ws3;
        output   txcompl0_ext;
        output   txcompl1_ext;
        output   txcompl2_ext;
        output   txcompl3_ext;
        output   txcompl4_ext;
        output   txcompl5_ext;
        output   txcompl6_ext;
        output   txcompl7_ext;
        output   [7:0]  txdata0_ext;
        output   [7:0]  txdata1_ext;
        output   [7:0]  txdata2_ext;
        output   [7:0]  txdata3_ext;
        output   [7:0]  txdata4_ext;
        output   [7:0]  txdata5_ext;
        output   [7:0]  txdata6_ext;
        output   [7:0]  txdata7_ext;
        output   txdatak0_ext;
        output   txdatak1_ext;
        output   txdatak2_ext;
        output   txdatak3_ext;
        output   txdatak4_ext;
        output   txdatak5_ext;
        output   txdatak6_ext;
        output   txdatak7_ext;
        output   txdetectrx0_ext;
        output   txdetectrx1_ext;
        output   txdetectrx2_ext;
        output   txdetectrx3_ext;
        output   txdetectrx4_ext;
        output   txdetectrx5_ext;
        output   txdetectrx6_ext;
        output   txdetectrx7_ext;
        output   txelecidle0_ext;
        output   txelecidle1_ext;
        output   txelecidle2_ext;
        output   txelecidle3_ext;
        output   txelecidle4_ext;
        output   txelecidle5_ext;
        output   txelecidle6_ext;
        output   txelecidle7_ext;

initial begin
   $display("SUCCESS: BFM model not available");
   `ifdef VCS
   $finish;
   `else
   $stop ;
   `endif
end

always begin
   $display("SUCCESS: BFM model not available");
   `ifdef VCS
   $finish;
   `else
   $stop ;
   `endif
end

endmodule //altpcietb_bfm_rpvar_64b_x8_pipen1b
//synopsys translate_on
//VALID FILE
`timescale 1 ps / 1 ps
//-----------------------------------------------------------------------------
// Title         : PCI Express PIPE PHY connector
// Project       : PCI Express MegaCore function
//-----------------------------------------------------------------------------
// File          : altpcietb_pipe_phy.v
// Author        : Altera Corporation
//-----------------------------------------------------------------------------
// Description :
// This function interconnects two PIPE MAC interfaces for a single lane.
// For now this uses a common PCLK for both interfaces, an enhancement woudl be
// to support separate PCLK's for each interface with the requisite elastic
// buffer.
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
module altpcietb_rst_clk # ( parameter REFCLK_HALF_PERIOD = 5000) (
   output reg ref_clk_out,
   output reg pcie_rstn,
   output reg rp_rstn
);

  always
    #REFCLK_HALF_PERIOD  ref_clk_out <= ~ref_clk_out;

  initial
    begin
      pcie_rstn         = 1'b1;
      rp_rstn           = 1'b0;
      ref_clk_out       = 1'b0;
      #1000
      pcie_rstn         = 1'b0;
      rp_rstn           = 1'b1;
      #1000
      rp_rstn           = 1'b0;
      #1000
      rp_rstn           = 1'b1;
      #1000
      rp_rstn           = 1'b0;
      #200000 pcie_rstn = 1'b1;
      #100000 rp_rstn   = 1'b1;
    end

endmodule

