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


// (C) 2001-2010 Altera Corporation. All rights reserved.
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




`timescale 1 ns / 1 ps
//-----------------------------------------------------------------------------
// Project       : PCI Express MegaCore TL BFM
//-----------------------------------------------------------------------------
// File          : altpcietb_tlbfm_ltssm.v
// Author        : Altera Corporation
//-----------------------------------------------------------------------------
// Description :  Emulates DUT's LTSSM states
//-----------------------------------------------------------------------------
// Copyright © 2012 Altera Corporation. All rights reserved.  Altera products are
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
module altpcietb_tlbfm_ltssm # (
    parameter pcie_rate             = "Gen1 (2.5 Gbps)",
    parameter pcie_number_of_lanes  = "x8",
    parameter deemphasis_enable     = "false"
   ) (
   input            dut_clk,
   input            dut_rstn,
   input            dut_srst,
   input            dut_dlcm_sm_act,
   output reg[4:0]  dut_ltssm_state,
   output reg       dut_link_up,
   output reg       dut_current_deemp,
   output reg [1:0] dut_current_speed,
   output reg[3:0]  dut_lane_act,
   output reg       dut_link_train,
   output reg       dut_l0sstate,
   output reg       dut_l0state,
   output reg       dut_equlz_complete,
   output reg       dut_in_l0s_req,
   output reg       dut_in_l1_ok,
   output reg       dut_link_auto_bdw_status,
   output reg       dut_link_bdw_mng_status,
   output reg       dut_link_equlz_req,
   output reg       dut_phase_1_successful,
   output reg       dut_phase_2_successful,
   output reg       dut_phase_3_successful,
   output reg       dut_l2_exit ,
   output reg       dut_hotrst_exit,
   output reg       dut_dlup_exit,
   output reg       dut_rst_enter_comp_bit,
   output reg[1:0]  dut_err_phy,
   output reg       dut_rx_err_frame,
   output reg[7:0]  dut_lane_err,
   output reg       start_dlcmsm,
   output reg       vcintf_ena
);

   // LTSSM States
   localparam LTSSM_0_DETECT_QUIET        = 5'h0;
   localparam LTSSM_1_DETECT_ACTIVE       = 5'h1;
   localparam LTSSM_2_POLLING_ACTIVE      = 5'h2;
   localparam LTSSM_3_POLLING_CONFIG      = 5'h4;
   localparam LTSSM_6_CFG_LINKWIDTHSTART  = 5'h6;
   localparam LTSSM_7_CFG_LINKWIDTHACCEPT = 5'h7;
   localparam LTSSM_9_CFG_LANENUMWAIT     = 5'h9;
   localparam LTSSM_8_CFG_LANENUMACCEPT   = 5'h8;
   localparam LTSSM_A_CFG_COMPLETE        = 5'ha;
   localparam LTSSM_B_CFG_IDLE            = 5'hb;
   localparam LTSSM_F_L0                  = 5'hf;
   localparam LTSSM_19_RECOV_EQUAL        = 5'h19;
   localparam LTSSM_1A_RECOV_SPEED        = 5'h1a;
   localparam LTSSM_C_SPEED_RECOV_RCVR_LOCK = 5'hc;
   localparam LTSSM_D_SPEED_RECOV_RCVR_CFG  = 5'hd;
   localparam LTSSM_E_SPEED_RECOV_IDLE      = 5'he;
   reg[31:0]  counter;
   wire[1:0]  target_speed;
   assign target_speed = (pcie_rate == "Gen1 (2.5 Gbps)") ? 2'h1 :
                         (pcie_rate == "Gen2 (5.0 Gbps)") ? 2'h2 :
                         (pcie_rate == "Gen3 (8.0 Gbps)") ? 2'h3 : 2'h0;
   always @ (posedge dut_clk or negedge dut_rstn)  begin
       if (~dut_rstn) begin
           dut_ltssm_state   <= LTSSM_0_DETECT_QUIET;
           dut_link_up       <= 1'h0;
           dut_current_deemp <= 1'h0;
           dut_current_speed <= 2'h0;
           dut_lane_act      <= 4'h0;
           dut_link_train    <= 1'h0;
           dut_l0sstate      <= 1'h0;
           dut_l0state       <= 1'h0;
           start_dlcmsm      <= 1'b0;
           vcintf_ena        <= 1'b0;
           counter           <= 32'd10;
           dut_dlup_exit            <= 1'b1;
           dut_equlz_complete       <= 1'h0;
           dut_in_l0s_req           <= 1'h0;
           dut_in_l1_ok             <= 1'h0;
           dut_link_auto_bdw_status <= 1'h0;
           dut_link_bdw_mng_status  <= 1'h0;
           dut_link_equlz_req       <= 1'h0;
           dut_phase_1_successful   <= 1'h0;
           dut_phase_2_successful   <= 1'h0;
           dut_phase_3_successful   <= 1'h0;
           dut_l2_exit              <= 1'b1;
           dut_hotrst_exit          <= 1'b1;
           dut_rst_enter_comp_bit   <= 1'h0;
           dut_err_phy              <= 2'h0;
           dut_lane_err             <= 8'h0;
           dut_rx_err_frame         <= 1'h0;
       end
       else if (dut_srst) begin
           dut_ltssm_state   <= LTSSM_0_DETECT_QUIET;
           dut_link_up       <= 1'h0;
           dut_current_deemp <= 1'h0;
           dut_current_speed <= 2'h0;
           dut_lane_act      <= 4'h0;
           dut_link_train    <= 1'h0;
           dut_l0sstate      <= 1'h0;
           dut_l0state       <= 1'h0;
           start_dlcmsm      <= 1'b0;
           vcintf_ena        <= 1'b0;
           counter           <= 32'd10;
           dut_dlup_exit            <= 1'b1;
           dut_equlz_complete       <= 1'h0;
           dut_in_l0s_req           <= 1'h0;
           dut_in_l1_ok             <= 1'h0;
           dut_link_auto_bdw_status <= 1'h0;
           dut_link_bdw_mng_status  <= 1'h0;
           dut_link_equlz_req       <= 1'h0;
           dut_phase_1_successful   <= 1'h0;
           dut_phase_2_successful   <= 1'h0;
           dut_phase_3_successful   <= 1'h0;
           dut_l2_exit              <= 1'b1;
           dut_hotrst_exit          <= 1'b1;
           dut_rst_enter_comp_bit   <= 1'h0;
           dut_err_phy              <= 2'h0;
           dut_lane_err             <= 8'h0;
           dut_rx_err_frame         <= 1'h0;
       end
       else begin
           case (dut_ltssm_state)
               LTSSM_0_DETECT_QUIET: begin
                   // INIT to GEN1
                   dut_current_deemp      <= 1'h1;
                   dut_current_speed      <= 2'h1;
                   dut_link_up            <= 1'h0;
                   dut_equlz_complete     <= 1'h0;
                   dut_phase_1_successful <= 1'h0;
                   dut_phase_2_successful <= 1'h0;
                   dut_phase_3_successful <= 1'h0;
                   counter <= counter - 32'h1;
                   if (~|counter) begin
                       dut_ltssm_state <= LTSSM_1_DETECT_ACTIVE;   // rx elec idle exit
                       counter         <= 32'd10;
                   end
               end
               LTSSM_1_DETECT_ACTIVE: begin
                   counter <= counter - 32'h1;
                   if (~|counter) begin
                       dut_ltssm_state <= LTSSM_2_POLLING_ACTIVE;  // rcvrs detected on all unconfig lanes
                       counter <= 32'd500;
                   end
               end
               LTSSM_2_POLLING_ACTIVE: begin
                   counter <= counter - 32'h1;
                   if (~|counter) begin
                       dut_ltssm_state <= LTSSM_3_POLLING_CONFIG;  // sent 1024 TS1's, rcvd 8
                       counter <= 32'd350;
                   end
               end
               LTSSM_3_POLLING_CONFIG: begin
                   counter <= counter - 32'h1;
                   if (~|counter) begin
                        dut_link_train  <= 1'h1;
                        dut_ltssm_state <= LTSSM_6_CFG_LINKWIDTHSTART; // received 8 TS2's, sent 16
                        counter         <= 32'd200;
                   end
               end
               LTSSM_6_CFG_LINKWIDTHSTART: begin
                    dut_lane_act = (pcie_number_of_lanes=="x1") ? 4'h1 :
                                   (pcie_number_of_lanes=="x2") ? 4'h2 :
                                   (pcie_number_of_lanes=="x4") ? 4'h4 :
                                   (pcie_number_of_lanes=="x8") ? 4'h8 : 4'h0;   // negotiated link width
                    counter <= counter - 32'h1;
                    if (~|counter) begin
                        dut_ltssm_state <= LTSSM_7_CFG_LINKWIDTHACCEPT;   // got 2 non-PAD TS1s
                        counter  <= 32'd100;
                    end
               end
               LTSSM_7_CFG_LINKWIDTHACCEPT: begin
                    counter <= counter - 32'h1;
                    if (~|counter) begin
                        dut_ltssm_state <= LTSSM_9_CFG_LANENUMWAIT;   // got 2 Link# TS1's
                        counter <= 32'd200;
                    end
               end
               LTSSM_9_CFG_LANENUMWAIT: begin
                    counter <= counter - 32'h1;
                    if (~|counter) begin
                        dut_ltssm_state <= LTSSM_8_CFG_LANENUMACCEPT;  // got 2 Link&Lane # TS1's
                        counter <= 32'd50;
                    end
               end
               LTSSM_8_CFG_LANENUMACCEPT: begin
                   counter <= counter - 32'h1;
                   if (~|counter) begin
                       dut_ltssm_state <= LTSSM_A_CFG_COMPLETE;   // got 2 Link & Lane # TS1's
                       counter <= 32'd200;
                   end
               end
               LTSSM_A_CFG_COMPLETE: begin
                   counter <= counter - 32'h1;
                   if (~|counter) begin
                       dut_ltssm_state <= LTSSM_B_CFG_IDLE;   // sent 16 TS2's, rcvd 8
                       counter <= 32'h2;
                   end
               end
               LTSSM_B_CFG_IDLE: begin
                   dut_link_up  <= 1'h1;                  // link up
                   counter <= counter - 32'h1;
                   if (~|counter) begin
                       dut_ltssm_state <= LTSSM_F_L0;    // rcvd 8 idle symbol times, sent 16
                   end
               end
               LTSSM_F_L0: begin
                   start_dlcmsm   <= 1'b1;                 // kick off DLCMSM
                   dut_link_train <= 1'b0;
                   dut_l0sstate   <= 1'h1;
                   dut_l0state    <= 1'h1;
                   if (dut_dlcm_sm_act & (target_speed==dut_current_speed)) begin  // already at target speed
                       vcintf_ena      <= 1'b1;
                       dut_ltssm_state <= dut_ltssm_state;
                   end
                   else if (dut_dlcm_sm_act) begin
                       vcintf_ena      <= 1'b0;
                       dut_link_train  <= 1'b1;
                       dut_ltssm_state <= LTSSM_C_SPEED_RECOV_RCVR_LOCK;     // directed to change speed
                       counter         <= 32'd450;
                   end
               end
               LTSSM_19_RECOV_EQUAL: begin
                   counter <= counter - 32'h1;
                   if (~|counter) begin
                       dut_equlz_complete     <= 1'h1;
                       dut_phase_1_successful <= 1'h1;
                       dut_phase_2_successful <= 1'h1;
                       dut_phase_3_successful <= 1'h1;
                       dut_current_speed      <= 2'h3;        // at Gen3 speed
                       dut_ltssm_state        <= LTSSM_C_SPEED_RECOV_RCVR_LOCK;
                       counter                <= 32'd450;
                   end
               end
               LTSSM_1A_RECOV_SPEED: begin
                   counter <= counter - 32'h1;
                   if (~|counter) begin
                       dut_ltssm_state <= LTSSM_C_SPEED_RECOV_RCVR_LOCK;
                       counter         <= 32'd125;
                       dut_current_speed <= target_speed;
                       dut_current_deemp <= (deemphasis_enable=="true") ? 1'b1 : 1'b0;  // k_conf[360]
                   end
               end
               LTSSM_C_SPEED_RECOV_RCVR_LOCK: begin
                   counter <= counter - 32'h1;
                   if (~|counter) begin
                       if ((target_speed==2'h3) & (dut_current_speed!=2'h3)) begin   // Do Gen 3 Equalization
                           dut_ltssm_state <= LTSSM_19_RECOV_EQUAL;
                           counter         <= 32'd10;
                       end
                       else begin
                           dut_ltssm_state <= LTSSM_D_SPEED_RECOV_RCVR_CFG;    // got 8 TS1/2
                           counter         <= (target_speed!=dut_current_speed) ? 32'd500 : 32'd150;
                       end
                   end
               end
               LTSSM_D_SPEED_RECOV_RCVR_CFG: begin
                   counter <= counter - 32'h1;
                   if (~|counter) begin
                       if (target_speed!=dut_current_speed) begin
                           dut_ltssm_state <= LTSSM_1A_RECOV_SPEED;
                           counter         <= 32'd250;
                       end
                       else begin
                           dut_ltssm_state <= LTSSM_E_SPEED_RECOV_IDLE;
                           counter         <= 32'd25;
                       end
                   end
               end
               LTSSM_E_SPEED_RECOV_IDLE: begin
                   counter <= counter - 32'h1;
                   if (~|counter) begin
                       dut_current_speed <= target_speed;
                       dut_ltssm_state   <= LTSSM_F_L0;
                   end
               end
           endcase
       end
   end

endmodule


//-----------------------------------------------------------------------------
// Project       : PCI Express MegaCore TL BFM
//-----------------------------------------------------------------------------
// File          : altpcietb_tlbfm_payld_swizzle.v
// Author        : Altera Corporation
//-----------------------------------------------------------------------------
// Description : Reverses the bytes within each DW of payload
//-----------------------------------------------------------------------------
// Copyright ©  2012 Altera Corporation. All rights reserved.  Altera products are
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
module altpcietb_tlbfm_payld_swizzle (
   input           avst64_clk,            // avst64 clock
   input           avst64_rstn,           // avst64 reset
   input           vcintf64_st_sop,       // 64bit interface From VC Intf
   input           vcintf64_st_valid,
   input [63:0]    vcintf64_st_data,

   output [63:0]   vcintf64_st_data_swizz    // bytes reversed within each payld DW, desc DWs unchanged
   );

   reg         is_4dw_hdr;
   reg         last_was_sop;
   wire [63:0] byte_swizz;

   assign byte_swizz = {vcintf64_st_data[39:32], vcintf64_st_data[47:40], vcintf64_st_data[55:48], vcintf64_st_data[63:56],    // swizzle bytes within upper DW
                        vcintf64_st_data[7:0],   vcintf64_st_data[15:8],  vcintf64_st_data[23:16], vcintf64_st_data[31:24]};   // swizzle bytes within lower DW

   always @ (posedge avst64_clk or negedge avst64_rstn) begin
       if (~avst64_rstn) begin
           is_4dw_hdr   <= 1'b0;
           last_was_sop <= 1'b0;
       end
       else begin
           is_4dw_hdr  <= (vcintf64_st_sop & vcintf64_st_valid) ? vcintf64_st_data[29] : is_4dw_hdr;
           last_was_sop <= vcintf64_st_valid ? vcintf64_st_sop : last_was_sop;
       end
   end

   assign vcintf64_st_data_swizz = (vcintf64_st_sop & vcintf64_st_valid)            ? vcintf64_st_data :    // desc phase 1 -- no swizzle
                                   (last_was_sop & vcintf64_st_valid & is_4dw_hdr)  ? vcintf64_st_data :    // desc phase 2 (4DW header) -- no swizzle
                                   (last_was_sop & vcintf64_st_valid & ~is_4dw_hdr) ? {byte_swizz[63:32], vcintf64_st_data[31:0]} :  byte_swizz;  // desc phase 2 (3DW header) -- swizzle 1st DW of payld


endmodule

//-----------------------------------------------------------------------------
// Project       : PCI Express MegaCore TL BFM
//-----------------------------------------------------------------------------
// File          : altpcietb_tlbfm_rxbuf_cred.v
// Author        : Altera Corporation
//-----------------------------------------------------------------------------
// Description : Tracks PCIE credits for the BFM Receive Buffer
//-----------------------------------------------------------------------------
// Copyright © 2012 Altera Corporation. All rights reserved.  Altera products are
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

module altpcietb_tlbfm_rxbuf_cred #(
    parameter CNTR_TYP = 3'b100,
    parameter BFM_FC_LIMIT_H = 8'h10,
    parameter BFM_FC_LIMIT_D = 12'h10
    )(
    input         clk,
    input         rstn,
    input         avst64_rx_st_valid,
    input         avst64_rx_st_sop,
    input         avst64_rx_st_eop,
    input [63:0]  avst64_rx_st_data,
    input         avst64_rx_malformed,
    input         bfm_rx_st_valid,
    input         bfm_rx_st_sop,
    input         bfm_rx_st_eop,
    input [63:0]  bfm_rx_st_data,
    input         bfm_rx_malformed,
    output reg [7:0]  credh_limit,
    output reg [7:0]  credh_consumed,
    output reg [11:0] credd_limit,
    output reg [11:0] credd_consumed
    );

   // one-hot encodings for TLP types
   localparam  TLP_NP = 3'b100;
   localparam  TLP_P  = 3'b010;
   localparam  TLP_CPL= 3'b001;

   // PciE Fmt_Type codes
   localparam  TYPE_MRD3   = 7'b00_00000;  // NP
   localparam  TYPE_MRD4   = 7'b01_00000;  // NP
   localparam  TYPE_MRDLK3 = 7'b00_00001;  // NP
   localparam  TYPE_MRDLK4 = 7'b01_00001;  // NP
   localparam  TYPE_MWR3   = 7'b10_00000;  // POSTED
   localparam  TYPE_MWR4   = 7'b11_00000;  // POSTED
   localparam  TYPE_IORD   = 7'b00_00010;  // NP
   localparam  TYPE_IOWR   = 7'b10_00010;  // NP
   localparam  TYPE_CFGRD0 = 7'b00_00100;  // NP
   localparam  TYPE_CFGWR0 = 7'b10_00100;  // NP
   localparam  TYPE_CFGRD1 = 7'b00_00101;  // NP
   localparam  TYPE_CFGWR1 = 7'b10_00101;  // NP
   localparam  TYPE_MSG    = 4'b01_10;     // POSTED
   localparam  TYPE_MSGD   = 4'b11_10;     // POSTED
   localparam  TYPE_CPL    = 7'b00_01010;  // CPL
   localparam  TYPE_CPLD   = 7'b10_01010;  // CPL
   localparam  TYPE_CPLLK  = 7'b00_01011;  // CPL
   localparam  TYPE_CPLDLK = 7'b10_01011;  // CPL

   wire[2:0]  bfm_typ;            // NP=3'b100, P=3'b010, CPL=3'b001
   wire       bfm_typ_match;
   reg        bfm_typ_match_reg;

   wire[2:0]  avst64_typ;         // NP=3'b100, P=3'b010, CPL=3'b001
   wire       avst64_typ_match;
   reg        avst64_typ_match_reg;

   wire[9:0]  avst64_length;
   reg[9:0]   avst64_length_reg;
   wire[9:0]  bfm_length;
   reg[9:0]   bfm_length_reg;


   assign avst64_length = (avst64_rx_st_sop & avst64_rx_st_valid & ~avst64_rx_st_data[30]) ? 10'h0 :   // no payload
                          (avst64_rx_st_sop & avst64_rx_st_valid)  ? avst64_rx_st_data[9:0] : avst64_length_reg;

   assign bfm_length = (bfm_rx_st_sop & bfm_rx_st_valid & ~bfm_rx_st_data[30])  ?  10'h0 :         // no payload
                       (bfm_rx_st_sop & bfm_rx_st_valid) ? bfm_rx_st_data[9:0] : bfm_length_reg;

   // Detect TLP type:  NP/P/CPL
   //------------------------------------------------------

   assign avst64_typ = ((avst64_rx_st_data[30:24]== TYPE_CPL)    ||
                        (avst64_rx_st_data[30:24]== TYPE_CPLD)   ||
                        (avst64_rx_st_data[30:24]== TYPE_CPLLK)  ||
                        (avst64_rx_st_data[30:24]== TYPE_CPLDLK)) ?  TLP_CPL :
                       ((avst64_rx_st_data[30:24]== TYPE_MWR3)    ||
                        (avst64_rx_st_data[30:24]== TYPE_MWR4)    ||
                        (avst64_rx_st_data[30:27]== TYPE_MSG)    ||
                        (avst64_rx_st_data[30:27]== TYPE_MSGD))   ?  TLP_P   : TLP_NP;

   assign bfm_typ = ((bfm_rx_st_data[30:24]== TYPE_CPL)    ||
                     (bfm_rx_st_data[30:24]== TYPE_CPLD)   ||
                     (bfm_rx_st_data[30:24]== TYPE_CPLLK)  ||
                     (bfm_rx_st_data[30:24]== TYPE_CPLDLK)) ?  TLP_CPL :
                    ((bfm_rx_st_data[30:24]== TYPE_MWR3)    ||
                     (bfm_rx_st_data[30:24]== TYPE_MWR4)    ||
                     (bfm_rx_st_data[30:27]== TYPE_MSG)    ||
                     (bfm_rx_st_data[30:27]== TYPE_MSGD))   ?  TLP_P   : TLP_NP;

   assign avst64_typ_match = (avst64_rx_st_sop & avst64_rx_st_valid) ? (avst64_typ == CNTR_TYP) : avst64_typ_match_reg;
   assign bfm_typ_match = (bfm_rx_st_sop & bfm_rx_st_valid) ? (bfm_typ == CNTR_TYP) : bfm_typ_match_reg;

   // Credit Counters
   //----------------------------------------------------
   always @ (posedge clk or negedge rstn) begin
       if (~rstn) begin
           credh_consumed   <= 8'h0;
           credd_consumed   <= 12'h0;
           credh_limit      <= BFM_FC_LIMIT_H;
           credd_limit      <= BFM_FC_LIMIT_D;
           avst64_typ_match_reg <= 1'b0;
           bfm_typ_match_reg    <= 1'b0;
           avst64_length_reg    <= 10'h0;
           bfm_length_reg       <= 10'h0;
       end
       else begin
           avst64_typ_match_reg <= avst64_typ_match;
           bfm_typ_match_reg    <= bfm_typ_match;
           avst64_length_reg    <= avst64_length;
           bfm_length_reg       <= bfm_length;

           // Consumed Counters
           //-----------------------------------------------------

           // update credit counter at end of tlp (- do not update if malformed)
           if (avst64_rx_st_valid & avst64_rx_st_eop & avst64_typ_match & ~avst64_rx_malformed) begin
               credh_consumed <= credh_consumed + 8'h1;
               credd_consumed <= (avst64_length==10'h0)  ? credd_consumed :    // no payload
                                 |avst64_rx_st_data[1:0] ? credd_consumed + avst64_length[9:2] + 12'h1 :  credd_consumed + avst64_length[9:2];
           end

           // Limit Counters
           //------------------------------------------------------

           // update credit counter at end of tlp (- do not update if malformed)
           if (bfm_rx_st_valid & bfm_rx_st_eop & bfm_typ_match & ~bfm_rx_malformed) begin
               credh_limit <= credh_limit + 8'h1;
               credd_limit <= (bfm_length==10'h0)  ? credd_limit :    // no payld
                              |bfm_rx_st_data[1:0] ? credd_limit + bfm_length[9:2] + 12'h1 : credd_limit + bfm_length[9:2];
           end
      end
   end

endmodule

//-----------------------------------------------------------------------------
// Project       : PCI Express MegaCore TL BFM
//-----------------------------------------------------------------------------
// File          : altpcietb_tlbfm_rxbuf.v
// Author        : Altera Corporation
//-----------------------------------------------------------------------------
// Description :  BFM's receive Buffer
//-----------------------------------------------------------------------------
// Copyright © 2012 Altera Corporation. All rights reserved.  Altera products are
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
module altpcietb_tlbfm_rxbuf  # (
      parameter BFM_FC_LIMIT_NPH  = 8'h10,
      parameter BFM_FC_LIMIT_NPD  = 12'h10,
      parameter BFM_FC_LIMIT_PH   = 8'h10,
      parameter BFM_FC_LIMIT_PD   = 12'h10,
      parameter BFM_FC_LIMIT_CPLH = 8'h00,
      parameter BFM_FC_LIMIT_CPLD = 12'h00
)(
   input           clk,                 // BFM clock
   input           rstn,                // BFM reset
   input           avst64_rx_st_sop,
   input           avst64_rx_st_valid,
   input           avst64_rx_st_eop,
   input           avst64_rx_st_empty,
   input [63:0]    avst64_rx_st_data,
   input           avst64_rx_malformed,
   input           bfm_rx_st_ready,
   output          bfm_rx_st_sop,
   output          bfm_rx_st_valid,
   output          bfm_rx_st_eop,
   output          bfm_rx_st_empty,
   output [63:0]   bfm_rx_st_data,
   output          bfm_rx_malformed,
   output[11:0]    cred_lim_pd,
   output[7:0]     cred_lim_ph,
   output[11:0]    cred_lim_npd,
   output[7:0]     cred_lim_nph,
   output[11:0]    cred_lim_cpld,
   output[7:0]     cred_lim_cplh
   );
   wire[11:0]      cred_cons_pd;    // for internal Error checking
   wire[7:0]       cred_cons_ph;
   wire[11:0]      cred_cons_npd;
   wire[7:0]       cred_cons_nph;
   wire[11:0]      cred_cons_cpld;
   wire[7:0]       cred_cons_cplh;
   wire            rxbuf_empty;
   wire            rxbuf_rden;
   wire            rxbuf_full;
   // Credit Counters
   //--------------------------------------------------
   altpcietb_tlbfm_rxbuf_cred  #(
      .CNTR_TYP (3'b100),
      .BFM_FC_LIMIT_H (BFM_FC_LIMIT_NPH),
      .BFM_FC_LIMIT_D (BFM_FC_LIMIT_NPD)
    ) rxbuf_np_cred ( .clk (clk), .rstn (rstn),
       .avst64_rx_st_valid (avst64_rx_st_valid), .avst64_rx_st_sop (avst64_rx_st_sop),
       .avst64_rx_st_eop (avst64_rx_st_eop), .avst64_rx_st_data (avst64_rx_st_data), .avst64_rx_malformed (avst64_rx_malformed),
       .bfm_rx_st_valid (bfm_rx_st_valid), .bfm_rx_st_sop (bfm_rx_st_sop),
       .bfm_rx_st_eop (bfm_rx_st_eop), .bfm_rx_st_data (bfm_rx_st_data), .bfm_rx_malformed (bfm_rx_malformed),
       .credh_limit (cred_lim_nph), .credh_consumed (cred_cons_nph),
       .credd_limit (cred_lim_npd), .credd_consumed (cred_cons_npd)
   );
   altpcietb_tlbfm_rxbuf_cred  #(
      .CNTR_TYP (3'b010),
      .BFM_FC_LIMIT_H (BFM_FC_LIMIT_PH),
      .BFM_FC_LIMIT_D (BFM_FC_LIMIT_PD)
    ) rxbuf_p_cred ( .clk (clk), .rstn (rstn),
       .avst64_rx_st_valid (avst64_rx_st_valid), .avst64_rx_st_sop (avst64_rx_st_sop),
       .avst64_rx_st_eop (avst64_rx_st_eop),  .avst64_rx_st_data (avst64_rx_st_data), .avst64_rx_malformed (avst64_rx_malformed),
       .bfm_rx_st_valid (bfm_rx_st_valid), .bfm_rx_st_sop (bfm_rx_st_sop),
       .bfm_rx_st_eop (bfm_rx_st_eop), .bfm_rx_st_data (bfm_rx_st_data), .bfm_rx_malformed (bfm_rx_malformed),
       .credh_limit (cred_lim_ph), .credh_consumed (cred_cons_ph),
       .credd_limit (cred_lim_pd), .credd_consumed (cred_cons_pd)
   );
   altpcietb_tlbfm_rxbuf_cred  #(
      .CNTR_TYP (3'b001),
      .BFM_FC_LIMIT_H (BFM_FC_LIMIT_CPLH),
      .BFM_FC_LIMIT_D (BFM_FC_LIMIT_CPLD)
    ) rxbuf_cpl_cred ( .clk (clk), .rstn (rstn),
       .avst64_rx_st_valid (avst64_rx_st_valid), .avst64_rx_st_sop (avst64_rx_st_sop),
       .avst64_rx_st_eop (avst64_rx_st_eop),  .avst64_rx_st_data (avst64_rx_st_data), .avst64_rx_malformed (avst64_rx_malformed),
       .bfm_rx_st_valid (bfm_rx_st_valid), .bfm_rx_st_sop (bfm_rx_st_sop),
       .bfm_rx_st_eop (bfm_rx_st_eop), .bfm_rx_st_data (bfm_rx_st_data), .bfm_rx_malformed (bfm_rx_malformed),
       .credh_limit (cred_lim_cplh), .credh_consumed (cred_cons_cplh),
       .credd_limit (cred_lim_cpld), .credd_consumed (cred_cons_cpld)
   );

   // RXBuffer
   //------------------------------------------
   scfifo  rxbuf (
                .clock        (clk),
                .sclr         (1'b0),
                .wrreq        (avst64_rx_st_valid),
                .aclr         (~rstn),
                .data         ({avst64_rx_malformed, avst64_rx_st_empty, avst64_rx_st_eop, avst64_rx_st_sop, avst64_rx_st_data}),
                .rdreq        (rxbuf_rden),
                .empty        (rxbuf_empty),
                .full         (rxbuf_full),
                .q            ({bfm_rx_malformed, bfm_rx_st_empty, bfm_rx_st_eop, bfm_rx_st_sop, bfm_rx_st_data}),
                .almost_full  (),
                .almost_empty (),
                .usedw        ());
    defparam
        rxbuf.add_ram_output_register = "OFF",
        rxbuf.almost_full_value       = 256,
        rxbuf.intended_device_family  = "Stratix V",
        rxbuf.lpm_numwords            = 2048,
        rxbuf.lpm_showahead           = "ON",
        rxbuf.lpm_type                = "scfifo",
        rxbuf.lpm_width               = 68,
        rxbuf.lpm_widthu              = 11,
        rxbuf.overflow_checking       = "ON",
        rxbuf.underflow_checking      = "ON",
        rxbuf.use_eab                 = "OFF";
  assign rxbuf_rden = bfm_rx_st_ready & ~rxbuf_empty;
  assign bfm_rx_st_valid = rxbuf_rden;
endmodule

`timescale 1 ns / 1 ps
//-----------------------------------------------------------------------------
// Project       : PCI Express MegaCore TL BFM
//-----------------------------------------------------------------------------
// File          : altpcietb_tlbfm_s5gasket.v
// Author        : Altera Corporation
//-----------------------------------------------------------------------------
// Description :  Glues the S5 DUT Transaction Layer signals to the
//                VCIntf signals.  Emulates the DUT's DL/PL layers + BFM's
//                PCIE core.
//-----------------------------------------------------------------------------
// Copyright © 2012 Altera Corporation. All rights reserved.  Altera products are
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
module altpcietb_tlbfm_s5gasket # (
    parameter pll_refclk_freq_hwtcl = "100 MHz",   // ref clk for DUT
    parameter pcie_rate             = "Gen2",
    parameter pcie_number_of_lanes  = "x8",
    parameter deemphasis_enable     = "false",
    parameter NUMCLKS_1us           = 32'hFA,     // # of DUT clocks in 1us
    parameter NUMCLKS_128ns         = 32'h20      // # of DUT clocks in 128ns
   ) (
   input            dut_clk,
   input            dut_rstn,
   input            dut_srst,
   input            dut_crst,
   input            avst64_clk,
   input            avst64_rstn,
   output           vcintf_ena,
   output           dut_refclk,
   output           dut_npor,
   output           dut_pin_perst,
   output[31:0]     dut_test_in,
   // datapath
   input [55:0]     dut_k_vc0,
   input [3:0]      dut_txdl_st_sop,     // From DUT
   input [3:0]      dut_txdl_st_valid,
   output           dut_txdl_st_ready,
   input [3:0]      dut_txdl_st_eop,
   input [3:0]      dut_txdl_st_empty,
   input [255:0]    dut_txdl_st_data,
   input            dut_rxdl_st_ready,    // To DUT
   output [3:0]     dut_rxdl_st_sop,
   output [3:0]     dut_rxdl_st_eop,
   output [3:0]     dut_rxdl_st_empty,
   output           dut_rxdl_st_valid,
   output [3:0]     dut_rxdl_st_tlp_check,
   output[255:0]    dut_rxdl_st_data,
   output [31:0]    dut_rxdl_st_parity,
   output [3:0]     dut_rxdl_err_attr3,
   output [3:0]     dut_rxdl_err_attr2,
   output [3:0]     dut_rxdl_err_attr1,
   output [3:0]     dut_rxdl_err_attr0,
   // flow control
   output           dut_ack_upfc,
   input            dut_req_upfc,
   input            dut_snd_upfc,
   input  [1:0]     dut_typ_upfc,
   input  [2:0]     dut_vcid_upfc,
   input  [7:0]     dut_hdr_upfc,
   input  [11:0]    dut_data_upfc,
   input            dut_val_upfc,
   output  [3:0]    dut_rxdl_val_fc,
   output  [15:0]   dut_rxdl_typ_fc,
   output  [31:0]   dut_rxdl_hdr_fc,
   output  [47:0]   dut_rxdl_data_fc,
   output  [11:0]   dut_rxdl_vcid_fc,
   // dl
   output [7:0]     dut_vc_status,
   output[3:0]      dut_rx_typ_pm,
   output           dut_rx_val_pm,
   output           dut_rpbuf_emp,
   output[11:0]     dut_max_credit_replay_buffer,
   output[5:0]      dut_max_credit_replay_fifo,
   output           dut_clr_rxpath,
   output           dut_dlup,
   output[4:0]      dut_err_dll,
   output[4:0]      dut_ltssm_state,
   output           dut_l2_exit ,
   output           dut_hotrst_exit,
   output           dut_dlup_exit,
   output reg       dut_ev1us,
   output reg       dut_ev128ns,
   output           dut_dlcm_sm_act,
   // pl
   output           dut_equlz_complete,
   output           dut_in_l0s_req,
   output           dut_in_l1_ok,

   output           dut_link_auto_bdw_status,
   output           dut_link_bdw_mng_status,
   output           dut_link_equlz_req,
   output           dut_phase_1_successful,
   output           dut_phase_2_successful,
   output           dut_phase_3_successful,
   output           dut_rst_enter_comp_bit,
   output[1:0]      dut_err_phy,
   output           dut_rx_err_frame,
   output[7:0]      dut_lane_err,
   output           dut_current_deemp,
   output [1:0]     dut_current_speed,
   output [3:0]     dut_lane_act,
   output           dut_link_train,
   output           dut_link_up,
   output           dut_l0sstate,
   output           dut_l0state ,
   output             vcintf64_rx_st_ready,
   output             vcintf64_rx_st_sop,
   output             vcintf64_rx_st_valid,
   output             vcintf64_rx_st_eop,
   output             vcintf64_rx_st_empty,
   output [63:0]      vcintf64_rx_st_data,
   output [7:0]       vcintf64_rxbuf_st_be,
   output             vcintf64_tx_st_sop,
   output             vcintf64_tx_st_valid,
   output             vcintf64_tx_st_eop,
   output             vcintf64_tx_st_empty,
   output [63:0]      vcintf64_tx_st_data,
   output [35:0]      vcintf64_tx_st_cred
);
   // BFM RXBuf cred settings:  balanced
   localparam BFM_FC_LIMIT_NPH  =  8'd56;
   localparam BFM_FC_LIMIT_NPD  = 12'd00;
   localparam BFM_FC_LIMIT_PH   =  8'd50;
   localparam BFM_FC_LIMIT_PD   = 12'd342;
   localparam BFM_FC_LIMIT_CPLH =  8'd00;
   localparam BFM_FC_LIMIT_CPLD = 12'd00;
   wire             avst64_rx_st_sop;
   wire             avst64_rx_st_valid;
   wire             avst64_rx_st_eop;
   wire             avst64_rx_st_empty;
   wire [63:0]      avst64_rx_st_data;
   wire             avst64_rx_malformed;
   wire             avst64_rxbuf_malformed;
   wire[11:0]       rxdl_cred_lim_pd;
   wire[7:0]        rxdl_cred_lim_ph;
   wire[11:0]       rxdl_cred_lim_npd;
   wire[7:0]        rxdl_cred_lim_nph;
   wire[11:0]       rxdl_cred_lim_cpld;
   wire[7:0]        rxdl_cred_lim_cplh;
   wire[11:0]       txdl_cred_lim_pd;
   wire[7:0]        txdl_cred_lim_ph;
   wire[11:0]       txdl_cred_lim_npd;
   wire[7:0]        txdl_cred_lim_nph;
   wire[11:0]       txdl_cred_lim_cpld;
   wire[7:0]        txdl_cred_lim_cplh;
   wire             txdl_cred_infinite_nph;
   wire             txdl_cred_infinite_npd;
   wire             txdl_cred_infinite_ph;
   wire             txdl_cred_infinite_pd;
   wire             txdl_cred_infinite_cplh;
   wire             txdl_cred_infinite_cpld;
   wire             start_dlcmsm;
   reg [31:0]       ev1us_count;
   reg [31:0]       ev128ns_count;
   // tl - unsupported
   assign dut_rxdl_err_attr3 = 4'h0;
   assign dut_rxdl_err_attr2 = 4'h0;
   assign dut_rxdl_err_attr1 = 4'h0;
   assign dut_rxdl_err_attr0 = 4'h0;
   // dl sideband
   assign dut_rxvcid_fc                = 3'h0;
   assign dut_rx_typ_pm                = 4'h0;
   assign dut_rx_val_pm                = 1'h0;
   assign dut_rpbuf_emp                = 1'h1;
   assign dut_max_credit_replay_buffer = 12'hFFF;   // tie to param
   assign dut_max_credit_replay_fifo   = 6'h3F;      // tie to param
   assign dut_clr_rxpath               = 1'h0;
   assign dut_err_dll                  = 5'h0;
   /*************************************
     HouseKeeping
   **************************************/
   initial begin
       dut_ev1us         = 1'b0;
       dut_ev128ns       = 1'h0;
   end

   always @ (posedge dut_clk or negedge dut_rstn) begin
       if (~dut_rstn) begin
           dut_ev1us     <= 1'b0;
           dut_ev128ns   <= 1'b0;
           ev1us_count   <= 32'h0;
           ev128ns_count <= 32'h0;
       end
       else begin
           dut_ev1us     <= (ev1us_count == NUMCLKS_1us-1);
           ev1us_count   <= (ev1us_count == NUMCLKS_1us-1) ? 32'h0 : ev1us_count + 32'h1;

           dut_ev128ns   <= (ev128ns_count == NUMCLKS_128ns-1);
           ev128ns_count <= (ev128ns_count == NUMCLKS_128ns-1) ? 32'h0 : ev128ns_count + 32'h1;
       end
   end
   /************************************************
      LTSSM Link Status Emulation
   *************************************************/
   altpcietb_tlbfm_ltssm  # (
       .pcie_rate            (pcie_rate),
       .pcie_number_of_lanes (pcie_number_of_lanes),
       .deemphasis_enable    (deemphasis_enable)
   ) ltssm (
       .dut_clk                  (dut_clk),
       .dut_rstn                 (dut_rstn),
       .dut_srst                 (dut_srst),
       .dut_dlcm_sm_act          (dut_dlcm_sm_act),
       .dut_ltssm_state          (dut_ltssm_state),
       .dut_link_up              (dut_link_up),
       .dut_current_deemp        (dut_current_deemp),
       .dut_current_speed        (dut_current_speed),
       .dut_lane_act             (dut_lane_act),
       .dut_link_train           (dut_link_train),
       .dut_l0sstate             (dut_l0sstate),
       .dut_l0state              (dut_l0state),
       .dut_dlup_exit            (dut_dlup_exit),
       .dut_equlz_complete       (dut_equlz_complete),
       .dut_in_l0s_req           (dut_in_l0s_req),
       .dut_in_l1_ok             (dut_in_l1_ok),
       .dut_link_auto_bdw_status (dut_link_auto_bdw_status),
       .dut_link_bdw_mng_status  (dut_link_bdw_mng_status),
       .dut_link_equlz_req       (dut_link_equlz_req),
       .dut_phase_1_successful   (dut_phase_1_successful),
       .dut_phase_2_successful   (dut_phase_2_successful),
       .dut_phase_3_successful   (dut_phase_3_successful),
       .dut_l2_exit              (dut_l2_exit),
       .dut_hotrst_exit          (dut_hotrst_exit),
       .dut_rst_enter_comp_bit   (dut_rst_enter_comp_bit),
       .dut_err_phy              (dut_err_phy),
       .dut_lane_err             (dut_lane_err),
       .dut_rx_err_frame         (dut_rx_err_frame),
       .start_dlcmsm             (start_dlcmsm),
       .vcintf_ena               (vcintf_ena)
   );
   /*******************************************************
      BFM-DUT Gaskets:
      Converts DUT signals to vc_intf 64bit AVST signals
   ********************************************************/

   altpcietb_tlbfm_s5txdl_datapath s5txdl_datapath (
       .avst64_clk         (avst64_clk),
       .avst64_rstn        (avst64_rstn),
       .dut_txdl_st_sop    (dut_txdl_st_sop),
       .dut_txdl_st_valid  (dut_txdl_st_valid),
       .dut_txdl_st_eop    (dut_txdl_st_eop),
       .dut_txdl_st_empty  (dut_txdl_st_empty),
       .dut_txdl_st_data   (dut_txdl_st_data),
       .dut_txdl_st_ready  (dut_txdl_st_ready),
       .avst64_rx_st_sop   (avst64_rx_st_sop),
       .avst64_rx_st_valid (avst64_rx_st_valid),
       .avst64_rx_st_eop   (avst64_rx_st_eop),
       .avst64_rx_st_empty (avst64_rx_st_empty),
       .avst64_rx_st_data  (avst64_rx_st_data)
   );
   altpcietb_tlbfm_s5rxdl_fc_intf  #(
         .BFM_FC_LIMIT_NPH  (BFM_FC_LIMIT_NPH),
         .BFM_FC_LIMIT_NPD  (BFM_FC_LIMIT_NPD),
         .BFM_FC_LIMIT_PH   (BFM_FC_LIMIT_PH),
         .BFM_FC_LIMIT_PD   (BFM_FC_LIMIT_PD),
         .BFM_FC_LIMIT_CPLH (BFM_FC_LIMIT_CPLH),
         .BFM_FC_LIMIT_CPLD (BFM_FC_LIMIT_CPLD)
  )s5rxdl_fc_intf (
       .dut_clk           (dut_clk),
       .dut_rstn          (dut_rstn),
       .start_dlcmsm      (start_dlcmsm),
       .dut_dl_up         (dut_dlup),
       .dut_vc_status     (dut_vc_status),
       .dut_dlcm_sm_act   (dut_dlcm_sm_act),
       .dut_ev1us         (dut_ev1us),
       .cred_lim_nph      (rxdl_cred_lim_nph),
       .cred_lim_npd      (rxdl_cred_lim_npd),
       .cred_lim_ph       (rxdl_cred_lim_ph),
       .cred_lim_pd       (rxdl_cred_lim_pd),
       .cred_lim_cplh     (rxdl_cred_lim_cplh),
       .cred_lim_cpld     (rxdl_cred_lim_cpld),
       .dut_rxdl_val_fc   (dut_rxdl_val_fc),
       .dut_rxdl_vcid_fc  (dut_rxdl_vcid_fc),
       .dut_rxdl_typ_fc   (dut_rxdl_typ_fc),
       .dut_rxdl_hdr_fc   (dut_rxdl_hdr_fc),
       .dut_rxdl_data_fc  (dut_rxdl_data_fc)
   );
   altpcietb_tlbfm_s5rxdl_datapath s5rxdl_datapath (
       .avst64_clk         (avst64_clk),
       .avst64_rstn        (avst64_rstn),
       .dut_clk            (dut_clk),
       .dut_rxdl_st_sop    (dut_rxdl_st_sop),
       .dut_rxdl_st_valid  (dut_rxdl_st_valid),
       .dut_rxdl_st_eop    (dut_rxdl_st_eop),
       .dut_rxdl_st_empty  (dut_rxdl_st_empty),
       .dut_rxdl_st_data   (dut_rxdl_st_data),
       .dut_rxdl_st_parity (dut_rxdl_st_parity),
       .dut_rxdl_st_tlp_check (dut_rxdl_st_tlp_check),
       .avst64_tx_st_sop   (vcintf64_tx_st_sop),
       .avst64_tx_st_valid (vcintf64_tx_st_valid),
       .avst64_tx_st_eop   (vcintf64_tx_st_eop),
       .avst64_tx_st_empty (vcintf64_tx_st_empty),
       .avst64_tx_st_data  (vcintf64_tx_st_data)
   );
   altpcietb_tlbfm_s5txdl_fc_intf s5txdl_fc_intf (
       .avst64_clk        (avst64_clk),
       .avst64_rstn       (avst64_rstn),
       .dut_k_vc0         (dut_k_vc0),
       .dut_dlup          (dut_dlup),
       .dut_ack_upfc      (dut_ack_upfc),
       .dut_req_upfc      (dut_req_upfc),
       .dut_snd_upfc      (dut_snd_upfc),
       .dut_typ_upfc      (dut_typ_upfc),
       .dut_vcid_upfc     (dut_vcid_upfc),
       .dut_hdr_upfc      (dut_hdr_upfc),
       .dut_data_upfc     (dut_data_upfc),
       .dut_val_upfc      (dut_val_upfc),
       .cred_lim_nph      (txdl_cred_lim_nph),
       .cred_lim_npd      (txdl_cred_lim_npd),
       .cred_lim_ph       (txdl_cred_lim_ph),
       .cred_lim_pd       (txdl_cred_lim_pd),
       .cred_lim_cplh     (txdl_cred_lim_cplh),
       .cred_lim_cpld     (txdl_cred_lim_cpld),
       .cred_infinite_nph  (txdl_cred_infinite_nph),
       .cred_infinite_npd  (txdl_cred_infinite_npd),
       .cred_infinite_ph   (txdl_cred_infinite_ph),
       .cred_infinite_pd   (txdl_cred_infinite_pd),
       .cred_infinite_cplh (txdl_cred_infinite_cplh),
       .cred_infinite_cpld (txdl_cred_infinite_cpld)
   );

   /*******************************************************
      BFM RX Buffer
   *******************************************************/
   assign avst64_rx_malformed = 1'b0;
   altpcietb_tlbfm_rxbuf  #(
         .BFM_FC_LIMIT_NPH  (BFM_FC_LIMIT_NPH),
         .BFM_FC_LIMIT_NPD  (BFM_FC_LIMIT_NPD),
         .BFM_FC_LIMIT_PH   (BFM_FC_LIMIT_PH),
         .BFM_FC_LIMIT_PD   (BFM_FC_LIMIT_PD),
         .BFM_FC_LIMIT_CPLH (BFM_FC_LIMIT_CPLH),
         .BFM_FC_LIMIT_CPLD (BFM_FC_LIMIT_CPLD)
   ) rxbuf(
       .clk                 (avst64_clk),
       .rstn                (avst64_rstn),
       .avst64_rx_st_sop    (avst64_rx_st_sop),
       .avst64_rx_st_valid  (avst64_rx_st_valid),
       .avst64_rx_st_eop    (avst64_rx_st_eop),
       .avst64_rx_st_empty  (avst64_rx_st_empty),
       .avst64_rx_st_data   (avst64_rx_st_data),
       .avst64_rx_malformed (avst64_rx_malformed),
       .bfm_rx_st_ready     (vcintf64_rx_st_ready),
       .bfm_rx_st_sop       (vcintf64_rx_st_sop),
       .bfm_rx_st_valid     (vcintf64_rx_st_valid),
       .bfm_rx_st_eop       (vcintf64_rx_st_eop),
       .bfm_rx_st_empty     (vcintf64_rx_st_empty),
       .bfm_rx_st_data      (vcintf64_rx_st_data),
       .bfm_rx_malformed    (avst64_rxbuf_malformed),
       .cred_lim_nph        (rxdl_cred_lim_nph),
       .cred_lim_npd        (rxdl_cred_lim_npd),
       .cred_lim_ph         (rxdl_cred_lim_ph),
       .cred_lim_pd         (rxdl_cred_lim_pd),
       .cred_lim_cplh       (rxdl_cred_lim_cplh),
       .cred_lim_cpld       (rxdl_cred_lim_cpld)
   );
   /*******************************************************
      BFM TX Cred Calc
   ********************************************************/
   altpcietb_tlbfm_txcred vcintf_txcred (
       .avst64_clk        (avst64_clk),
       .avst64_rstn       (avst64_rstn),
       .dut_dlup          (dut_dlup),
       .avst64_tx_st_sop   (vcintf64_tx_st_sop),    // TLPs being sent to DUT
       .avst64_tx_st_valid (vcintf64_tx_st_valid),
       .avst64_tx_st_eop   (vcintf64_tx_st_eop),
       .avst64_tx_st_data  (vcintf64_tx_st_data),
       .cred_lim_nph      (txdl_cred_lim_nph),    // Credit limit from DUT
       .cred_lim_npd      (txdl_cred_lim_npd),
       .cred_lim_ph       (txdl_cred_lim_ph),
       .cred_lim_pd       (txdl_cred_lim_pd),
       .cred_lim_cplh     (txdl_cred_lim_cplh),
       .cred_lim_cpld     (txdl_cred_lim_cpld),
       .cred_infinite_nph  (txdl_cred_infinite_nph),
       .cred_infinite_npd  (txdl_cred_infinite_npd),
       .cred_infinite_ph   (txdl_cred_infinite_ph),
       .cred_infinite_pd   (txdl_cred_infinite_pd),
       .cred_infinite_cplh (txdl_cred_infinite_cplh),
       .cred_infinite_cpld (txdl_cred_infinite_cpld),
       .tx_cred_avail     (vcintf64_tx_st_cred)     // net avail credit for BFM
   );

endmodule


//-----------------------------------------------------------------------------
// Project       : PCI Express MegaCore TL BFM
//-----------------------------------------------------------------------------
// File          : altpcietb_tlbfm_s5rxdl_datapath.v
// Author        : Altera Corporation
//-----------------------------------------------------------------------------
// Description : Receives 64-bit Datapath signalling from VCIntf, and
//               converts it to 256-bit interface to DUT's RXTL.
//-----------------------------------------------------------------------------
// Copyright ©  2012 Altera Corporation. All rights reserved.  Altera products are
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
module altpcietb_tlbfm_s5rxdl_datapath (
   input            avst64_clk,            // avst64 clock
   input            avst64_rstn,           // avst64 reset
   input            dut_clk,               // DUT clock (4x slower than AVST64)
   input            avst64_tx_st_sop,      // 64bit interface From VC Intf
   input            avst64_tx_st_valid,
   input            avst64_tx_st_eop,
   input            avst64_tx_st_empty,
   input [63:0]     avst64_tx_st_data,
   output reg [3:0]     dut_rxdl_st_sop,         // 256bit interface To DUT
   output reg           dut_rxdl_st_valid,
   output reg [3:0]     dut_rxdl_st_eop,
   output reg [3:0]     dut_rxdl_st_empty,
   output reg [255:0]   dut_rxdl_st_data,
   output reg [31:0]    dut_rxdl_st_parity,
   output reg [3:0]     dut_rxdl_st_tlp_check
   );
   reg[1:0]      dut_clk_phase;             // number of BFM (fast) clocks
   reg[1:0]      dut_clk_phase_reg;
   reg           dut_clk_phase_enabled;
   reg           dut_clk_del;
   reg           dut_clk_del2;
   reg [3:0]     int_tx_st_sop;         // 256bit interface To DUT
   reg [3:0]     int_tx_st_valid;
   reg [3:0]     int_tx_st_eop;
   reg [3:0]     int_tx_st_empty;
   reg [255:0]   int_tx_st_data;
   reg [31:0]    int_tx_st_parity;
   reg [3:0]     int_tx_st_tlp_check;
   reg           dut_clk_phase_enabled_reg;
   wire [63:0]   avst64_tx_st_data_swizz;
   wire [31:0]   avst64_tx_st_parity;

   // Swizzle the Payload bytes within each DW -
   // VCIntf data comes in as DW3, DW2, DW1, DW0, with first
   // byte of each payload DW being right-most byte.
   // S5 RXTL expects first byte of each Payload DW left-most byte.
   //-----------------------------------------------------------------------
   altpcietb_tlbfm_payld_swizzle payld_swizzle(
      .avst64_clk             (avst64_clk) ,
      .avst64_rstn            (avst64_rstn),
      .vcintf64_st_sop        (avst64_tx_st_sop),
      .vcintf64_st_valid      (avst64_tx_st_valid),
      .vcintf64_st_data       (avst64_tx_st_data),
      .vcintf64_st_data_swizz (avst64_tx_st_data_swizz)
   );
   // Add odd parity
   //-------------------
   altpcietb_tlbfm_pargen8  parity_byte7(.data_i(avst64_tx_st_data_swizz[63:56]), .parity_o(avst64_tx_st_parity[7]));
   altpcietb_tlbfm_pargen8  parity_byte6(.data_i(avst64_tx_st_data_swizz[55:48]), .parity_o(avst64_tx_st_parity[6]));
   altpcietb_tlbfm_pargen8  parity_byte5(.data_i(avst64_tx_st_data_swizz[47:40]), .parity_o(avst64_tx_st_parity[5]));
   altpcietb_tlbfm_pargen8  parity_byte4(.data_i(avst64_tx_st_data_swizz[39:32]), .parity_o(avst64_tx_st_parity[4]));
   altpcietb_tlbfm_pargen8  parity_byte3(.data_i(avst64_tx_st_data_swizz[31:24]), .parity_o(avst64_tx_st_parity[3]));
   altpcietb_tlbfm_pargen8  parity_byte2(.data_i(avst64_tx_st_data_swizz[23:16]), .parity_o(avst64_tx_st_parity[2]));
   altpcietb_tlbfm_pargen8  parity_byte1(.data_i(avst64_tx_st_data_swizz[15:8]),  .parity_o(avst64_tx_st_parity[1]));
   altpcietb_tlbfm_pargen8  parity_byte0(.data_i(avst64_tx_st_data_swizz[7:0]),   .parity_o(avst64_tx_st_parity[0]));

   // convert 64 bit BFM datapath to 256 bit DUT datapath
   //---------------------------------------------------------
   always @ (posedge avst64_clk or negedge avst64_rstn) begin
       if (~avst64_rstn) begin
           dut_rxdl_st_sop   <= 4'h0;
           dut_rxdl_st_valid <= 1'h0;
           dut_rxdl_st_eop   <= 4'h0;
           dut_rxdl_st_empty <= 4'h0;
           dut_rxdl_st_data  <= 64'h0;
           dut_rxdl_st_tlp_check <= 4'h0;
           dut_clk_del       <= 1'b0;
           dut_clk_del2      <= 1'b0;
           int_tx_st_sop     <= 4'h0;
           int_tx_st_valid   <= 4'h0;
           int_tx_st_eop     <= 4'h0;
           int_tx_st_empty   <= 4'h0;
           int_tx_st_data    <= 256'h0;
           int_tx_st_parity  <= 32'hFFFFFFFF;
           int_tx_st_tlp_check <= 4'h0;
           dut_clk_phase_reg   <= 2'h0;
           dut_clk_phase_enabled_reg <= 1'b0;
           dut_clk_phase         <= 2'h0;
           dut_clk_phase_enabled <= 1'b0;
       end
       else begin
           dut_clk_del <= dut_clk;
           dut_clk_del2 <= dut_clk_del;
           dut_clk_phase_reg   <= dut_clk_phase;
           dut_clk_phase_enabled_reg <= dut_clk_phase_enabled;
           // Collect 4 clock cycles worth of data from VCIntf
           //--------------------------------------------------
           if (~dut_clk & ~dut_clk_del & ~dut_clk_del2 & ~dut_clk_phase_enabled) begin    // synchronize phase count to dut clock
               dut_clk_phase <= 2'h1;
               dut_clk_phase_enabled <= 1'b1;
           end
           else begin
               dut_clk_phase <= dut_clk_phase + 2'h1;
               dut_clk_phase_enabled <= 1'b1;
           end

           // Convert AVST256 from TL to AVST64 for BFM
           //-------------------------------------------
           // left-most QW holds 1st 64-bit cycle,
           // right-most QW holds 4th QW
           if (dut_clk_phase==2'h0) begin
               int_tx_st_sop[3]        <= avst64_tx_st_sop;
               int_tx_st_valid[3]      <= avst64_tx_st_valid;
               int_tx_st_eop[3]        <= avst64_tx_st_eop;
               int_tx_st_empty[3]      <= avst64_tx_st_empty;
               int_tx_st_data[255:192] <= {avst64_tx_st_data_swizz[31:0], avst64_tx_st_data_swizz[63:32]};  // swap DWs so that first-on-line is left-most
               int_tx_st_tlp_check[3]  <= avst64_tx_st_eop;
               int_tx_st_parity[31:24] <= {avst64_tx_st_parity[3:0], avst64_tx_st_parity[7:4]};
           end
           // hold 2nd 64-bit cycle
           if (dut_clk_phase==2'h1) begin
               int_tx_st_sop[2]        <= avst64_tx_st_sop;
               int_tx_st_valid[2]      <= avst64_tx_st_valid;
               int_tx_st_eop[2]        <= avst64_tx_st_eop;
               int_tx_st_empty[2]      <= avst64_tx_st_empty;
               int_tx_st_data[191:128] <= {avst64_tx_st_data_swizz[31:0], avst64_tx_st_data_swizz[63:32]};
               int_tx_st_tlp_check[2]  <= avst64_tx_st_eop;
               int_tx_st_parity[23:16] <= {avst64_tx_st_parity[3:0], avst64_tx_st_parity[7:4]};
           end
           // hold 3rd 64-bit cycle
           if (dut_clk_phase==2'h2) begin
               int_tx_st_sop[1]       <= avst64_tx_st_sop;
               int_tx_st_valid[1]     <= avst64_tx_st_valid;
               int_tx_st_eop[1]       <= avst64_tx_st_eop;
               int_tx_st_empty[1]     <= avst64_tx_st_empty;
               int_tx_st_data[127:64] <= {avst64_tx_st_data_swizz[31:0], avst64_tx_st_data_swizz[63:32]};
               int_tx_st_tlp_check[1] <= avst64_tx_st_eop;
               int_tx_st_parity[15:8] <= {avst64_tx_st_parity[3:0], avst64_tx_st_parity[7:4]};
           end
           // transfer all data to DUT on 4th clock phase
           if (dut_clk_phase==2'h3) begin
               dut_rxdl_st_sop[3:1]       <= int_tx_st_sop[3:1];
               dut_rxdl_st_eop[3:1]       <= int_tx_st_eop[3:1];
               dut_rxdl_st_empty[3:1]     <= int_tx_st_empty[3:1];
               dut_rxdl_st_data[255:64]   <= int_tx_st_data[255:64];
               dut_rxdl_st_tlp_check[3:1] <= int_tx_st_tlp_check[3:1];
               dut_rxdl_st_parity[31:8]   <= int_tx_st_parity[31:8];
               dut_rxdl_st_sop[0]        <= avst64_tx_st_sop ;
               dut_rxdl_st_valid         <= avst64_tx_st_valid | (|int_tx_st_valid[3:1]);
               dut_rxdl_st_eop[0]        <= avst64_tx_st_eop;
               dut_rxdl_st_empty[0]      <= avst64_tx_st_empty;
               dut_rxdl_st_data[63:0]    <= {avst64_tx_st_data_swizz[31:0], avst64_tx_st_data_swizz[63:32]};
               dut_rxdl_st_tlp_check[0]  <= avst64_tx_st_eop;
               dut_rxdl_st_parity[7:0]   <= {avst64_tx_st_parity[3:0], avst64_tx_st_parity[7:4]};
           end
       end
   end
endmodule
/*********************************************************
    Module:  altpcietb_tlbfm_pargen8
    Description:  Generates odd byte parity
**********************************************************/
module altpcietb_tlbfm_pargen8  (
   input[7:0]        data_i,
   output            parity_o
  );
  wire   par01;
  wire   par23;
  wire   par45;
  wire   par67;
  wire   par0123;
  wire   par4567;
  assign  par01 = data_i[0] ^ data_i[1];
  assign  par23 = data_i[2] ^ data_i[3];
  assign  par45 = data_i[4] ^ data_i[5];
  assign  par67 = data_i[6] ^ data_i[7];
  assign  par0123 =  par01 ^ par23;
  assign  par4567 =  par45 ^ par67;
  assign parity_o = ~(par0123 ^ par4567);

endmodule

//-----------------------------------------------------------------------------
// Project       : PCI Express MegaCore TL BFM
//-----------------------------------------------------------------------------
// File          : altpcietb_tlbfm_s5rxdl_fc_intf.v
// Author        : Altera Corporation
//-----------------------------------------------------------------------------
// Description :  Receives credit limit information from BFM, and converts
//                it to Flow Control signalling to DUT's RX.
//-----------------------------------------------------------------------------
// Copyright © 2012 Altera Corporation. All rights reserved.  Altera products are
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
  module altpcietb_tlbfm_s5rxdl_fc_intf #(
      parameter BFM_FC_LIMIT_NPH  = 8'h10,
      parameter BFM_FC_LIMIT_NPD  = 12'h10,
      parameter BFM_FC_LIMIT_PH   = 8'h10,
      parameter BFM_FC_LIMIT_PD   = 12'h10,
      parameter BFM_FC_LIMIT_CPLH = 8'h00,
      parameter BFM_FC_LIMIT_CPLD = 12'h00,
      parameter UPDATE_INTERVAL_US = 32'd30   // FC Update interval timer in us
  )(
      input              dut_clk,
      input              dut_rstn,
      input              start_dlcmsm,
      input [7:0]        cred_lim_nph,     // From BFM
      input [11:0]       cred_lim_npd,
      input [7:0]        cred_lim_ph,
      input [11:0]       cred_lim_pd,
      input [7:0]        cred_lim_cplh,
      input [11:0]       cred_lim_cpld,
      input              dut_ev1us,
      output reg         dut_dl_up,
      output reg         dut_dlcm_sm_act,
      output reg [7:0]   dut_vc_status,
      output reg [3:0]   dut_rxdl_val_fc,  // send FCUpdate to DUT
      output [11:0]      dut_rxdl_vcid_fc,
      output reg [15:0]  dut_rxdl_typ_fc,
      output reg [31:0]  dut_rxdl_hdr_fc,
      output reg [47:0]  dut_rxdl_data_fc
   );
   // FC DLLP Type field
   localparam FC_INIT1   = 2'b01;
   localparam FC_INIT2   = 2'b11;
   localparam FC_UPDATE  = 2'b10;
   localparam FC_TYP_NP  = 2'b01;
   localparam FC_TYP_P   = 2'b00;
   localparam FC_TYP_CPL = 2'b10;
   // state machine states
   localparam   FCSM_LINK_DOWN = 3'h0;
   localparam   FCSM_INIT1  = 3'h1;
   localparam   FCSM_INIT2  = 3'h2;
   localparam   FCSM_UPDATE = 3'h3;
   // timers
   localparam  FCINIT_CLKS = 32'h20;
   reg [7:0]   cred_lim_nph_lastvalue;
   reg [11:0]  cred_lim_npd_lastvalue;
   reg [7:0]   cred_lim_ph_lastvalue;
   reg [11:0]  cred_lim_pd_lastvalue;
   reg [7:0]   cred_lim_cplh_lastvalue;
   reg [11:0]  cred_lim_cpld_lastvalue;
   wire        cred_change_np;
   wire        cred_change_p;
   wire        cred_change_cpl;
   reg [2:0]   flowcontrol_sm;
   reg [31:0]  fcinit_count;
   reg[31:0]   update_timer_np;    // 30us timer for update FC
   reg[31:0]   update_timer_p;
   reg[31:0]   update_timer_cpl;
   wire        update_timer_expired_np;
   wire        update_timer_expired_p;
   wire        update_timer_expired_cpl;
   // only support VC0
   assign dut_rxdl_vcid_fc = 12'h0;
   // update timers expiration
   assign  update_timer_expired_np  = (update_timer_np  == UPDATE_INTERVAL_US);
   assign  update_timer_expired_p   = (update_timer_p   == UPDATE_INTERVAL_US);
   assign  update_timer_expired_cpl = (update_timer_cpl == UPDATE_INTERVAL_US);
   // indicate when credit limit values have changed
   // -- to schedule an update FC
   //-----------------------------------------------
   assign cred_change_np = (cred_lim_nph != cred_lim_nph_lastvalue) |
                           (cred_lim_npd != cred_lim_npd_lastvalue)  ;
   assign cred_change_p  = (cred_lim_ph != cred_lim_ph_lastvalue) |
                           (cred_lim_pd != cred_lim_pd_lastvalue) ;
   assign cred_change_cpl = (cred_lim_cplh != cred_lim_cplh_lastvalue) |
                            (cred_lim_cpld != cred_lim_cpld_lastvalue) ;
   always @ (posedge dut_clk or dut_rstn) begin
       if (~dut_rstn) begin
           dut_rxdl_val_fc         <= 4'h0;
           dut_rxdl_typ_fc         <= 16'h0;
           dut_rxdl_hdr_fc         <= 32'h0;
           dut_rxdl_data_fc        <= 48'h0;
           dut_dlcm_sm_act         <= 1'b0;
           dut_dl_up               <= 1'b0;
           dut_vc_status           <= 8'h00;
           cred_lim_nph_lastvalue  <= BFM_FC_LIMIT_NPH;
           cred_lim_npd_lastvalue  <= BFM_FC_LIMIT_NPD;
           cred_lim_ph_lastvalue   <= BFM_FC_LIMIT_PH;
           cred_lim_pd_lastvalue   <= BFM_FC_LIMIT_PD;
           cred_lim_cplh_lastvalue <= BFM_FC_LIMIT_CPLH;
           cred_lim_cpld_lastvalue <= BFM_FC_LIMIT_CPLD;
           fcinit_count            <= 32'h0;
           flowcontrol_sm          <= FCSM_LINK_DOWN;
           update_timer_np         <= 32'h0;
           update_timer_p          <= 32'h0;
           update_timer_cpl        <= 32'h0;
       end
       else begin
           case (flowcontrol_sm)
               FCSM_LINK_DOWN: begin
                   dut_dlcm_sm_act <= 1'b0;
                   dut_dl_up       <= 1'b0;
                   if (start_dlcmsm) begin   // wait for L0
                       flowcontrol_sm <= FCSM_INIT1;
                       fcinit_count   <= 32'h0;
                   end
               end
               FCSM_INIT1: begin
                   if (fcinit_count == FCINIT_CLKS) begin
                       flowcontrol_sm <= FCSM_INIT2;
                       fcinit_count   <= 32'h0;
                   end
                   else begin
                       flowcontrol_sm <= FCSM_INIT1;
                       fcinit_count   <= fcinit_count + 8'h1;
                   end
                   dut_rxdl_val_fc  <= 4'b0111;
                   dut_rxdl_typ_fc  <= {4'h0, FC_INIT1, FC_TYP_P, FC_INIT1, FC_TYP_NP, FC_INIT1, FC_TYP_CPL};
                   dut_rxdl_hdr_fc  <= {8'h0, BFM_FC_LIMIT_PH, BFM_FC_LIMIT_NPH, BFM_FC_LIMIT_CPLH};
                   dut_rxdl_data_fc <= {12'h0, BFM_FC_LIMIT_PD, BFM_FC_LIMIT_NPD, BFM_FC_LIMIT_CPLD};
               end
               FCSM_INIT2: begin
                   dut_dl_up     <= 1'b1;
                   dut_vc_status <= 8'h1;                   // only VC0 supported
                   if (fcinit_count == FCINIT_CLKS) begin
                       flowcontrol_sm <= FCSM_UPDATE;
                       fcinit_count   <= 32'h0;
                   end
                   else begin
                       flowcontrol_sm <= FCSM_INIT2;
                       fcinit_count   <= fcinit_count + 8'h1;
                   end
                   dut_rxdl_val_fc  <= 4'b0111;
                   dut_rxdl_typ_fc  <= {4'h0, FC_INIT2, FC_TYP_P, FC_INIT2, FC_TYP_NP, FC_INIT2, FC_TYP_CPL};
                   dut_rxdl_hdr_fc  <= {8'h0, BFM_FC_LIMIT_PH, BFM_FC_LIMIT_NPH, BFM_FC_LIMIT_CPLH};
                   dut_rxdl_data_fc <= {12'h0, BFM_FC_LIMIT_PD, BFM_FC_LIMIT_NPD, BFM_FC_LIMIT_CPLD};
               end
               FCSM_UPDATE: begin
                   dut_dlcm_sm_act <= 1'b1;
                   //  FC Update timers
                   //--------------------------------------------------------
                   // NP timer
                   if ((BFM_FC_LIMIT_NPH == 8'h0) & (BFM_FC_LIMIT_NPD == 12'h0)) begin // infinite creds
                       update_timer_cpl <= 32'h0;
                   end
                   else if (dut_rxdl_val_fc[0]) begin
                       update_timer_np <= 32'h0;
                   end
                   else if (update_timer_expired_np) begin
                       update_timer_np <= 32'h0;
                   end
                   else if (dut_ev1us) begin
                       update_timer_np <= update_timer_np + 32'h1;
                   end
                   // P timer
                   if ((BFM_FC_LIMIT_PH == 8'h0) & (BFM_FC_LIMIT_PD == 12'h0)) begin // infinite creds
                       update_timer_cpl <= 32'h0;
                   end
                   else if (dut_rxdl_val_fc[1]) begin
                       update_timer_p <= 32'h0;
                   end
                   else if (update_timer_expired_p) begin
                       update_timer_p <= 32'h0;
                   end
                   else if (dut_ev1us) begin
                       update_timer_p <= update_timer_p + 32'h1;
                   end
                   // CPL timer
                   if ((BFM_FC_LIMIT_CPLH == 8'h0) & (BFM_FC_LIMIT_CPLD == 12'h0)) begin // infinite creds
                       update_timer_cpl <= 32'h0;
                   end
                   else if (dut_rxdl_val_fc[2]) begin
                       update_timer_cpl <= 32'h0;
                   end
                   else if (update_timer_expired_cpl) begin
                       update_timer_cpl <= 32'h0;
                   end
                   else if (dut_ev1us) begin
                       update_timer_cpl <= update_timer_cpl + 32'h1;
                   end
                   // Send Update FC whenever a credit limit changes values
                   // OR when FCUpdate timer expires
                   // - arbitrarily assign the P/NP/CPL FCUpdates to specific
                   //   Quads on the RXDL interface
                   //---------------------------------------------------------
                   if (cred_change_np | update_timer_expired_np) begin    // send NP FCupdate
                       dut_rxdl_val_fc[0]     <= (BFM_FC_LIMIT_NPH != 8'h0) | (BFM_FC_LIMIT_NPD != 12'h0);
                       dut_rxdl_typ_fc[3:0]   <= {FC_UPDATE, FC_TYP_NP};
                       dut_rxdl_hdr_fc[7:0]   <= (BFM_FC_LIMIT_NPH == 8'h0)  ? 8'h0  : cred_lim_nph;
                       dut_rxdl_data_fc[11:0] <= (BFM_FC_LIMIT_NPD == 12'h0) ? 12'h0 : cred_lim_npd;
                       cred_lim_nph_lastvalue <= cred_lim_nph;
                       cred_lim_npd_lastvalue <= cred_lim_npd;
                   end
                   else begin
                       dut_rxdl_val_fc[0] <= 1'b0;
                   end
                   if (cred_change_p | update_timer_expired_p) begin    // send Posted FCupdate
                       dut_rxdl_val_fc[1]      <= (BFM_FC_LIMIT_PH != 8'h0) | (BFM_FC_LIMIT_PD != 12'h0);
                       dut_rxdl_typ_fc[7:4]    <= {FC_UPDATE, FC_TYP_P};
                       dut_rxdl_hdr_fc[15:8]   <= (BFM_FC_LIMIT_PH == 8'h0)  ? 8'h0  : cred_lim_ph;
                       dut_rxdl_data_fc[23:12] <= (BFM_FC_LIMIT_PD == 12'h0) ? 12'h0 : cred_lim_pd;
                       cred_lim_ph_lastvalue   <= cred_lim_ph;
                       cred_lim_pd_lastvalue   <= cred_lim_pd;
                   end
                   else begin
                       dut_rxdl_val_fc[1] <= 1'b0;
                   end
                   if (cred_change_cpl | update_timer_expired_cpl) begin  // send CPL FCupdate
                       dut_rxdl_val_fc[2]      <= (BFM_FC_LIMIT_CPLH != 8'h0) | (BFM_FC_LIMIT_CPLD != 12'h0);
                       dut_rxdl_typ_fc[11:8]   <= {FC_UPDATE, FC_TYP_CPL};
                       dut_rxdl_hdr_fc[23:16]  <= (BFM_FC_LIMIT_CPLH == 8'h0)  ? 8'h0  : cred_lim_cplh;
                       dut_rxdl_data_fc[35:24] <= (BFM_FC_LIMIT_CPLD == 12'h0) ? 12'h0 : cred_lim_cpld;
                       cred_lim_cplh_lastvalue <= cred_lim_cplh;
                       cred_lim_cpld_lastvalue <= cred_lim_cpld;
                   end
                   else begin
                       dut_rxdl_val_fc[2] <= 1'b0;
                   end
                   // last Quad
                   dut_rxdl_val_fc[3]      <= 1'b0;
                   dut_rxdl_typ_fc[15:12]  <= 4'h0;
                   dut_rxdl_hdr_fc[31:24]  <= 8'h0;
                   dut_rxdl_data_fc[47:36] <= 12'h0;
               end
           endcase
       end
   end
endmodule


//-----------------------------------------------------------------------------
// Project       : PCI Express MegaCore TL BFM
//-----------------------------------------------------------------------------
// File          : altpcietb_tlbfm_s5txdl_datapath.v
// Author        : Altera Corporation
//-----------------------------------------------------------------------------
// Description :   Receives 256-bit Datapath signalling from DUT's TXTL, and
//                 converts it to 64-bit interface to VCIntf.
//-----------------------------------------------------------------------------
// Copyright © 2012 Altera Corporation. All rights reserved.  Altera products are
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
module altpcietb_tlbfm_s5txdl_datapath (
   input            avst64_clk,           // avst64 clock
   input            avst64_rstn,          // avst64 reset

   input [3:0]      dut_txdl_st_sop,      // From DUT
   input [3:0]      dut_txdl_st_valid,    // not used.  valid is implied by sop/eop.
   input [3:0]      dut_txdl_st_eop,
   input [3:0]      dut_txdl_st_empty,
   input [255:0]    dut_txdl_st_data,
   output           dut_txdl_st_ready,

   output reg          avst64_rx_st_sop,    // Toward VC Intf
   output reg          avst64_rx_st_valid,
   output reg          avst64_rx_st_eop,
   output reg          avst64_rx_st_empty,
   output [63:0]       avst64_rx_st_data
   );

   reg[1:0]         clk_count;           // number of BFM (fast) clocks
   reg              qw0_is_mid_tlp ;     // means first QW of this cycle continues a TLP from last cycle
   reg              qw0_is_mid_tlp_n;
   reg[63:0]        avst64_rx_st_data_int;

   assign dut_txdl_st_ready = 1'b1;


   // Before sending 64-bit data to BFM, swizzle the payload bytes
   // within each DW -
   // S5 TXDL data comes in as DW3, DW2, DW1, DW0, with first
   // byte of each DW being left-most byte. BFM expects first byte of
   // each DW to be right-most byte.
   //-----------------------------------------------------------------------
   altpcietb_tlbfm_payld_swizzle payld_swizzle(
      .avst64_clk             (avst64_clk) ,
      .avst64_rstn            (avst64_rstn),
      .vcintf64_st_sop        (avst64_rx_st_sop),
      .vcintf64_st_valid      (avst64_rx_st_valid),
      .vcintf64_st_data       (avst64_rx_st_data_int),
      .vcintf64_st_data_swizz (avst64_rx_st_data)
   );


   // convert 256 bit DUT datapath to 64 bit BFM datapath
   //---------------------------------------------------------

   always @ (posedge avst64_clk or negedge avst64_rstn) begin
       if (~avst64_rstn) begin
           avst64_rx_st_sop   <= 1'h0;
           avst64_rx_st_valid <= 1'h0;
           avst64_rx_st_eop   <= 1'h0;
           avst64_rx_st_empty <= 1'h0;
           avst64_rx_st_data_int  <= 64'h0;
           clk_count          <= 2'h0;
           qw0_is_mid_tlp     <= 1'b0;
       end
       else if (|dut_txdl_st_valid) begin
           // Divide DUT's AVST256 "Valid" signal into 4 cycles
           //--------------------------------------------------------------
           if (|dut_txdl_st_sop | |dut_txdl_st_eop | qw0_is_mid_tlp) begin
               clk_count <= clk_count + 2'h1;
           end

           // Convert AVST256 from TL to AVST64 for BFM
           //-------------------------------------------
           if (clk_count==2'h0) begin
               avst64_rx_st_sop   <= dut_txdl_st_sop[0];
               avst64_rx_st_valid <= qw0_is_mid_tlp | dut_txdl_st_sop[0];      // TLP continues, or starts in qw0
               avst64_rx_st_eop   <= dut_txdl_st_eop[0];
               avst64_rx_st_empty <= dut_txdl_st_empty[0];
               avst64_rx_st_data_int  <= dut_txdl_st_data[63:0];
           end
           else if (clk_count==2'h1) begin
               avst64_rx_st_sop   <= dut_txdl_st_sop[1];
               avst64_rx_st_valid <= (qw0_is_mid_tlp & ~dut_txdl_st_eop[0]) |   // TLP continues, and not ended in qw0
                                      dut_txdl_st_sop[0] |                      // TLP started in qw0
                                      dut_txdl_st_sop[1];                       // TLP started in qw1
               avst64_rx_st_eop   <= dut_txdl_st_eop[1];
               avst64_rx_st_empty <= dut_txdl_st_empty[1];
               avst64_rx_st_data_int  <= dut_txdl_st_data[127:64];
           end
           else if (clk_count==2'h2) begin
               avst64_rx_st_sop   <= dut_txdl_st_sop[2];
               avst64_rx_st_valid <= (qw0_is_mid_tlp & ~|dut_txdl_st_eop[1:0]) |   // TLP continues, and not ended in qw1/qw0
                                     (dut_txdl_st_sop[0] & ~dut_txdl_st_eop[1]) |  // TLP started in qw0 and not ended in qw1
                                      dut_txdl_st_sop[1] |                         // TLP started in qw1
                                      dut_txdl_st_sop[2];                          // TLP started in qw2
               avst64_rx_st_eop   <= dut_txdl_st_eop[2];
               avst64_rx_st_empty <= dut_txdl_st_empty[2];
               avst64_rx_st_data_int  <= dut_txdl_st_data[191:128];
           end
           else if (clk_count==2'h3) begin
               avst64_rx_st_sop   <= dut_txdl_st_sop[3];
               avst64_rx_st_valid <= (qw0_is_mid_tlp & ~|dut_txdl_st_eop[2:0]) |     // TLP continues, and not ended in qw2/qw1/qw0
                                     (dut_txdl_st_sop[0] & ~dut_txdl_st_eop[2:1]) |  // TLP started in qw0 and not ended in qw2/qw1
                                     (dut_txdl_st_sop[1] & ~dut_txdl_st_eop[2]) |    // TLP started in qw1 and not ended in qw2
                                      dut_txdl_st_sop[2] |                           // TLP started in qw2
                                      dut_txdl_st_sop[3];                            // TLP started in qw3
               avst64_rx_st_eop   <= dut_txdl_st_eop[3];
               avst64_rx_st_empty <= dut_txdl_st_empty[3];
               avst64_rx_st_data_int  <= dut_txdl_st_data[255:192];
               qw0_is_mid_tlp     <= qw0_is_mid_tlp_n;              // carry over the continuation flag into next cycle
           end
       end
       else begin
           avst64_rx_st_valid <= 1'b0;
       end

   end

   always @ (*) begin
       // determine if current TLP continues into next cycle
       //----------------------------------------------------
       // Deassert qw0_is_mid_TLP when end of TLP (and no
       // start) is detected in the clock cycle
       //-----------------------------------------------------
       if (dut_txdl_st_eop[3]  |                                   // eop in QW3
           (dut_txdl_st_eop[2] & ~dut_txdl_st_sop[3]) |            // eop in QW2, no sop in QW3
           (dut_txdl_st_eop[1] & ~|dut_txdl_st_sop[3:2]) |         // eop in QW1, no sop in QW3/QW2
           (dut_txdl_st_eop[0] & ~|dut_txdl_st_sop[3:1]) ) begin   // eop in QW0, no sop in QW3/QW2/QW1

           qw0_is_mid_tlp_n <= 1'b0;
       end
       // Assert qw0_is_mid_TLP when start of TLP (and no
       // end) is detected in the clock cycle
       //-----------------------------------------------------
       else if ( dut_txdl_st_sop[3]  |                                   // sop in QW3
                (dut_txdl_st_sop[2] & ~dut_txdl_st_eop[3]) |             // sop in QW2, no eop in QW3
                (dut_txdl_st_sop[1] & ~|dut_txdl_st_eop[3:2]) |          // sop in QW1, no eop in QW3/QW2
                (dut_txdl_st_sop[0] & ~|dut_txdl_st_eop[3:1]) ) begin    // sop in QW0, no eop in QW3/QW2/QW1

           qw0_is_mid_tlp_n <= 1'b1;
       end
       else begin
           qw0_is_mid_tlp_n <= qw0_is_mid_tlp;
       end
   end


endmodule


//-----------------------------------------------------------------------------
// Project       : PCI Express MegaCore TL BFM
//-----------------------------------------------------------------------------
// File          : altpcietb_tlbfm_s5txdl_fc_intf.v
// Author        : Altera Corporation
//------------------------------------------------------------------------------------
// Description : Receives Flow Control signalling from DUT's TXTL, and converts
//               it to credit limit information for BFM.
//------------------------------------------------------------------------------------
// Copyright © 2012 Altera Corporation. All rights reserved.  Altera products are
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
  module altpcietb_tlbfm_s5txdl_fc_intf (
      input              avst64_clk,
      input              avst64_rstn,

      input [55:0]       dut_k_vc0,

      input              dut_dlup,
      input              dut_req_upfc,
      input              dut_snd_upfc,
      input  [1:0]       dut_typ_upfc,
      input  [2:0]       dut_vcid_upfc,        // removed, support one VC
      input  [7:0]       dut_hdr_upfc,
      input  [11:0]      dut_data_upfc,
      input              dut_val_upfc,
      output reg         dut_ack_upfc,
      output reg [7:0]   cred_lim_nph,         // To BFM
      output reg [11:0]  cred_lim_npd,
      output reg [7:0]   cred_lim_ph,
      output reg [11:0]  cred_lim_pd,
      output reg [7:0]   cred_lim_cplh,
      output reg [11:0]  cred_lim_cpld,
      output reg         cred_infinite_nph,
      output reg         cred_infinite_npd,
      output reg         cred_infinite_ph,
      output reg         cred_infinite_pd,
      output reg         cred_infinite_cplh,
      output reg         cred_infinite_cpld
   );

   // txdl_cred_sm states
   localparam DL_DOWN         = 3'h0;    // Credits are uninitialized
   localparam FC_INIT_DELAY   = 3'h1;
   localparam FC_INIT         = 3'h2;    // Process FC INIT1/2
   localparam FC_UPDATE       = 3'h3;    // Process FC Updates
   localparam FC_UPDATE_DELAY = 3'h4;    // Process FC Updates

    // timers
    localparam FC_INIT_DELAY_COUNT = 32'h10;
    localparam FC_UPDATE_DELAY_COUNT = 32'h10;

   reg[2:0]  txdl_cred_sm;
   reg[31:0] delay_count;

   always @ (posedge avst64_clk or negedge avst64_rstn) begin
       if (~avst64_rstn) begin
           cred_lim_nph       <= 8'h0;
           cred_lim_npd       <= 12'h0;
           cred_lim_ph        <= 8'h0;
           cred_lim_pd        <= 12'h0;
           cred_lim_cplh      <= 8'h0;
           cred_lim_cpld      <= 12'h0;
           cred_infinite_nph  <= 1'b0;
           cred_infinite_npd  <= 1'b0;
           cred_infinite_ph   <= 1'b0;
           cred_infinite_pd   <= 1'b0;
           cred_infinite_cplh <= 1'b0;
           cred_infinite_cpld <= 1'b0;
           dut_ack_upfc       <= 1'b0;
           txdl_cred_sm       <= DL_DOWN;
           delay_count        <= 32'h0;
       end
       else begin
           case (txdl_cred_sm)
               DL_DOWN: begin
                   // wait for dut_dlup (or ltssm?) before initializing credits
                   //----------------------------------------------------------
                   cred_lim_nph  <= 8'h0;
                   cred_lim_npd  <= 12'h0;
                   cred_lim_ph   <= 8'h0;
                   cred_lim_pd   <= 12'h0;
                   cred_lim_cplh <= 8'h0;
                   cred_lim_cpld <= 12'h0;
                   cred_infinite_nph  <= 1'b0;
                   cred_infinite_npd  <= 1'b0;
                   cred_infinite_ph   <= 1'b0;
                   cred_infinite_pd   <= 1'b0;
                   cred_infinite_cplh <= 1'b0;
                   cred_infinite_cpld <= 1'b0;

                   dut_ack_upfc  <= 1'b0;
                   delay_count   <= 32'h0;

                   if (dut_dlup) begin
                       txdl_cred_sm <= FC_INIT_DELAY;
                   end
                   else begin
                       txdl_cred_sm <= txdl_cred_sm;
                   end
               end
               FC_INIT_DELAY: begin
                   // wait some time to mimic FC INIT transport delays
                   //---------------------------------------------------
                   if (delay_count == FC_INIT_DELAY_COUNT) begin
                       txdl_cred_sm <= FC_INIT;
                       delay_count  <= 32'h0;
                   end
                   else begin
                       txdl_cred_sm <= txdl_cred_sm;
                       delay_count <= delay_count + 32'h1;
                   end
               end
               FC_INIT: begin
                   // Mimic FC init phase since dlcmsm in DUT is bypassed
                   //-----------------------------------------------------
                   cred_lim_ph   <= dut_k_vc0[7:0];
                   cred_lim_pd   <= dut_k_vc0[19:8];
                   cred_lim_nph  <= dut_k_vc0[27:20];
                   cred_lim_npd  <= dut_k_vc0[35:28];
                   cred_lim_cplh <= dut_k_vc0[43:36];
                   cred_lim_cpld <= dut_k_vc0[55:44];
                   cred_infinite_ph   <= (dut_k_vc0[7:0]   == 8'h0)  ? 1'b1 : 1'b0;
                   cred_infinite_pd   <= (dut_k_vc0[19:8]  == 12'h0) ? 1'b1 : 1'b0;
                   cred_infinite_nph  <= (dut_k_vc0[27:20] == 8'h0)  ? 1'b1 : 1'b0;
                   cred_infinite_npd  <= (dut_k_vc0[35:28] == 12'h0) ? 1'b1 : 1'b0;
                   cred_infinite_cplh <= (dut_k_vc0[43:36] == 8'h0)  ? 1'b1 : 1'b0;
                   cred_infinite_cpld <= (dut_k_vc0[55:44] == 12'h0) ? 1'b1 : 1'b0;

                   dut_ack_upfc  <= 1'b0;
                   if (~dut_dlup) begin
                       txdl_cred_sm  <= DL_DOWN;
                   end
                   else begin
                       txdl_cred_sm  <= FC_UPDATE;
                   end
               end
               FC_UPDATE: begin
                  // implement transport delay
                  delay_count   <= 32'h0;
                  dut_ack_upfc <= 1'b0;
                  if (dut_req_upfc | dut_snd_upfc) begin
                      txdl_cred_sm  <= FC_UPDATE_DELAY;
                  end
               end
               FC_UPDATE_DELAY: begin
                   // wait some time to mimic FC UPDATE transport delays
                   //---------------------------------------------------
                   if (delay_count == FC_UPDATE_DELAY_COUNT) begin
                       txdl_cred_sm <= FC_UPDATE;
                       delay_count  <= 32'h0;

                       // acknowledge the DUT RXTL request
                       // and update BFM cred limits
                       //--------------------------------------
                       dut_ack_upfc <= (dut_req_upfc | dut_snd_upfc);

                       if (dut_typ_upfc == 2'b00) begin              // Posted UPFC
                           cred_lim_ph <= dut_hdr_upfc;
                           cred_lim_pd <= dut_data_upfc;
                       end
                       else if (dut_typ_upfc == 2'b01) begin         // NonPosted UPFC
                           cred_lim_nph <= dut_hdr_upfc;
                           cred_lim_npd <= dut_data_upfc;
                       end
                       else if (dut_typ_upfc == 2'b10) begin         // CPL UPFC
                           cred_lim_cplh <= dut_hdr_upfc;
                           cred_lim_cpld <= dut_data_upfc;
                       end
                       else begin
                           $display ("S5_TXDL_CRED_GASKET:  RCVD ILLEGAL FCUPDATE TYPE IN FCUPDATE");
                       end
                   end
                   else begin
                       txdl_cred_sm  <= txdl_cred_sm;
                       delay_count   <= delay_count + 32'h1;
                       dut_ack_upfc  <= 1'b0;
                       cred_lim_ph   <= cred_lim_ph;
                       cred_lim_pd   <= cred_lim_pd;
                       cred_lim_nph  <= cred_lim_nph;
                       cred_lim_npd  <= cred_lim_npd;
                       cred_lim_cplh <= cred_lim_cplh;
                       cred_lim_cpld <= cred_lim_cpld;
                   end
               end
           endcase
       end
   end

endmodule


//-----------------------------------------------------------------------------
// Project       : PCI Express MegaCore TL BFM
//-----------------------------------------------------------------------------
// File          : altpcietb_tlbfm_txcred.v
// Author        : Altera Corporation
//-----------------------------------------------------------------------------
// Description :  Tracks available credits for VCIntf TX.
//-----------------------------------------------------------------------------
// Copyright © 2012 Altera Corporation. All rights reserved.  Altera products are
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
  module altpcietb_tlbfm_txcred (
      input         avst64_clk,
      input         avst64_rstn,
      input         dut_dlup,
      input [7:0]   cred_lim_nph,    // from DUT RXBuf
      input [11:0]  cred_lim_npd,
      input [7:0]   cred_lim_ph,
      input [11:0]  cred_lim_pd,
      input [7:0]   cred_lim_cplh,
      input [11:0]  cred_lim_cpld,
      input         cred_infinite_nph,
      input         cred_infinite_npd,
      input         cred_infinite_ph,
      input         cred_infinite_pd,
      input         cred_infinite_cplh,
      input         cred_infinite_cpld,
      input         avst64_tx_st_sop,      // 64bit interface From VC Intf
      input         avst64_tx_st_valid,
      input         avst64_tx_st_eop,
      input [63:0]  avst64_tx_st_data,

      output[35:0]  tx_cred_avail
   );

 wire [7:0]   cred_avail_nph;
 wire [11:0]  cred_avail_npd;
 wire [7:0]   cred_avail_ph;
 wire [11:0]  cred_avail_pd;
 wire [7:0]   cred_avail_cplh;
 wire [11:0]  cred_avail_cpld;


 wire[2:0]  tx_cred_nph;
 wire[2:0]  tx_cred_npd;
 wire[2:0]  tx_cred_ph;
 wire[11:0] tx_cred_pd;
 wire[2:0]  tx_cred_cplh;
 wire[11:0] tx_cred_cpld;

 //--------------------------------
 // calculate avaialable credits
 //--------------------------------

 altpcietb_bfm_txcred_count #(
     .CNTR_TYP (3'b100)
    ) txcred_counter_np (
       .clk             (avst64_clk),
       .rstn            (avst64_rstn),
       .bfm_tx_st_valid (avst64_tx_st_valid),
       .bfm_tx_st_sop   (avst64_tx_st_sop),
       .bfm_tx_st_eop   (avst64_tx_st_eop),
       .bfm_tx_st_data  (avst64_tx_st_data),
       .credh_limit     (cred_lim_nph),
       .credd_limit     (cred_lim_npd),
       .credh_infinite  (cred_infinite_nph),
       .credd_infinite  (cred_infinite_npd),
       .credh_avail     (cred_avail_nph),
       .credd_avail     (cred_avail_npd)
    );

 altpcietb_bfm_txcred_count #(
     .CNTR_TYP (3'b010)
    ) txcred_counter_p (
       .clk             (avst64_clk),
       .rstn            (avst64_rstn),
       .bfm_tx_st_valid (avst64_tx_st_valid),
       .bfm_tx_st_sop   (avst64_tx_st_sop),
       .bfm_tx_st_eop   (avst64_tx_st_eop),
       .bfm_tx_st_data  (avst64_tx_st_data),
       .credh_limit     (cred_lim_ph),
       .credd_limit     (cred_lim_pd),
       .credh_infinite  (cred_infinite_ph),
       .credd_infinite  (cred_infinite_pd),
       .credh_avail     (cred_avail_ph),
       .credd_avail     (cred_avail_pd)
    );

 altpcietb_bfm_txcred_count #(
     .CNTR_TYP (3'b001)
    ) txcred_counter_cpl (
       .clk             (avst64_clk),
       .rstn            (avst64_rstn),
       .bfm_tx_st_valid (avst64_tx_st_valid),
       .bfm_tx_st_sop   (avst64_tx_st_sop),
       .bfm_tx_st_eop   (avst64_tx_st_eop),
       .bfm_tx_st_data  (avst64_tx_st_data),
       .credh_limit     (cred_lim_cplh),
       .credd_limit     (cred_lim_cpld),
       .credh_infinite  (cred_infinite_cplh),
       .credd_infinite  (cred_infinite_cpld),
       .credh_avail     (cred_avail_cplh),
       .credd_avail     (cred_avail_cpld)
    );
 //------------------------------------------
 // convert avail creds to tx_cred format
 //------------------------------------------

 assign tx_cred_avail = {tx_cred_cpld, tx_cred_cplh, tx_cred_npd, tx_cred_nph, tx_cred_pd, tx_cred_ph};

 // saturate nph at 3'h7
 assign tx_cred_nph = (cred_avail_nph < 8'h7) ? cred_avail_nph[2:0] : 3'h7;

 // saturate npd at 3'h7
 assign tx_cred_npd = (cred_avail_npd < 8'h7) ? cred_avail_npd[2:0] : 3'h7;
 // saturate ph at 3'h7
 assign tx_cred_ph = (cred_avail_ph < 8'h7) ? cred_avail_ph[2:0] : 3'h7;

 // no conversion for pd creds
 assign tx_cred_pd = cred_avail_pd[11:0];

 // saturate cplh at 3'h7
 assign tx_cred_cplh = (cred_avail_cplh < 8'h7) ? cred_avail_cplh[2:0] : 3'h7;

 // no conversion for cpld creds
 assign tx_cred_cpld = cred_avail_cpld[11:0];

endmodule

/************************************************************************
 Module      : altpcietb_bfm_txcredcalc
 Description : Calculates Available credits for BFM TX
*************************************************************************/

module altpcietb_bfm_txcred_count #(
    parameter CNTR_TYP = 3'b100
    )(
    input             clk,
    input             rstn,
    input             bfm_tx_st_valid,
    input             bfm_tx_st_sop,
    input             bfm_tx_st_eop,
    input [63:0]      bfm_tx_st_data,
    input [7:0]       credh_limit,
    input [11:0]      credd_limit,
    input             credh_infinite,
    input             credd_infinite,
    output [7:0]      credh_avail,
    output [11:0]     credd_avail
    );
   // one-hot encodings for TLP types
   localparam  TLP_NP = 3'b100;
   localparam  TLP_P  = 3'b010;
   localparam  TLP_CPL= 3'b001;

   // PciE Fmt_Type codes
   localparam  TYPE_MRD3   = 7'b00_00000;  // NP
   localparam  TYPE_MRD4   = 7'b01_00000;  // NP
   localparam  TYPE_MRDLK3 = 7'b00_00001;  // NP
   localparam  TYPE_MRDLK4 = 7'b01_00001;  // NP
   localparam  TYPE_MWR3   = 7'b10_00000;  // POSTED
   localparam  TYPE_MWR4   = 7'b11_00000;  // POSTED
   localparam  TYPE_IORD   = 7'b00_00010;  // NP
   localparam  TYPE_IOWR   = 7'b10_00010;  // NP
   localparam  TYPE_CFGRD0 = 7'b00_00100;  // NP
   localparam  TYPE_CFGWR0 = 7'b10_00100;  // NP
   localparam  TYPE_CFGRD1 = 7'b00_00101;  // NP
   localparam  TYPE_CFGWR1 = 7'b10_00101;  // NP
   localparam  TYPE_MSG    = 4'b01_10;     // POSTED
   localparam  TYPE_MSGD   = 4'b11_10;     // POSTED
   localparam  TYPE_CPL    = 7'b00_01010;  // CPL
   localparam  TYPE_CPLD   = 7'b10_01010;  // CPL
   localparam  TYPE_CPLLK  = 7'b00_01011;  // CPL
   localparam  TYPE_CPLDLK = 7'b10_01011;  // CPL

   wire[2:0]  bfm_typ;            // NP=3'b100, P=3'b010, CPL=3'b001
   wire       bfm_typ_match;
   reg        bfm_typ_match_reg;
   reg [7:0]  credh_consumed;
   reg [11:0] credd_consumed;

   // Detect TLP type:  NP/P/CPL
   //-----------------------------

   assign bfm_typ = ((bfm_tx_st_data[30:24]== TYPE_CPL)    ||
                     (bfm_tx_st_data[30:24]== TYPE_CPLD)   ||
                     (bfm_tx_st_data[30:24]== TYPE_CPLLK)  ||
                     (bfm_tx_st_data[30:24]== TYPE_CPLDLK)) ?  TLP_CPL :
                    ((bfm_tx_st_data[30:24]== TYPE_MWR3)    ||
                     (bfm_tx_st_data[30:24]== TYPE_MWR4)    ||
                     (bfm_tx_st_data[30:27]== TYPE_MSG)    ||
                     (bfm_tx_st_data[30:27]== TYPE_MSGD))   ?  TLP_P   : TLP_NP;

   assign bfm_typ_match = bfm_tx_st_sop ? (bfm_typ == CNTR_TYP) : bfm_typ_match_reg;

   // Credit Counters
   //----------------------------------------------------
   always @ (posedge clk or negedge rstn) begin
       if (~rstn) begin
           credh_consumed   <= 8'h0;
           credd_consumed   <= 12'h0;
           bfm_typ_match_reg <= 1'b0;
       end
       else begin
           bfm_typ_match_reg <= bfm_typ_match;
           // Consumed Counters
           //-----------------------------------------------------

           // update credit counter at end of tlp (- do not update if malformed)
           if (bfm_tx_st_valid & bfm_tx_st_sop & bfm_typ_match) begin
               credh_consumed <= credh_consumed + 8'h1;
               credd_consumed <=  ~bfm_tx_st_data[30] ? credd_consumed :   // no payload
                                  |bfm_tx_st_data[1:0] ? credd_consumed + bfm_tx_st_data[10:2] + 12'h1 :  credd_consumed + bfm_tx_st_data[10:2];
           end

      end
   end

   // Calculate net creds avail
   //---------------------------
   assign credh_avail =  credh_infinite ? 8'hFF   : credh_limit - credh_consumed;
   assign credd_avail =  credd_infinite ? 12'hFFF : credd_limit - credd_consumed;

endmodule

`timescale 1 ns / 1 ps
//-----------------------------------------------------------------------------
// Project       : PCI Express MegaCore TL BFM
//-----------------------------------------------------------------------------
// File          : altpcietb_tlbfm_intf.v
// Author        : Altera Corporation
//-----------------------------------------------------------------------------
// Description :  Contains the DUT-BFM gasket.  It provides the datapath
//                delays.  And rolls the DUT interface signals into the
//                tlbfm_in/out conduits.
//-----------------------------------------------------------------------------
// Copyright © 2012 Altera Corporation. All rights reserved.  Altera products are
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

module altpcietb_tlbfm_intf # (
    parameter pll_refclk_freq_hwtcl = "100 MHz",   // ref clk for DUT
    parameter pcie_rate             = "Gen2",
    parameter pcie_number_of_lanes  = "x8",
    parameter deemphasis_enable     = "false",
    parameter bfm_pcie_delay        = 32'd200,    // Delay (in ns) to add to the BFM's fc/datapaths
    parameter NUMCLKS_1us           = 32'hFA,     // # of DUT clocks in 1us
    parameter NUMCLKS_128ns         = 32'h20      // # of DUT clocks in 128ns

   ) (

   input            avst64_clk,
   input            avst64_rstn,

   input  [1000:0]  tlbfm_in,
   output [1000:0]  tlbfm_out,
   output           dut_clk,
   output           dut_rstn,

   output           vcintf_ena,
   output           vcintf64_rx_st_ready,
   output           vcintf64_rx_st_sop,
   output           vcintf64_rx_st_valid,
   output           vcintf64_rx_st_eop,
   output           vcintf64_rx_st_empty,
   output [63:0]    vcintf64_rx_st_data,
   output [7:0]     vcintf64_rxbuf_st_be,
   output           vcintf64_tx_st_sop,
   output           vcintf64_tx_st_valid,
   output           vcintf64_tx_st_eop,
   output           vcintf64_tx_st_empty,
   output [63:0]    vcintf64_tx_st_data,
   output [35:0]    vcintf64_tx_st_cred
);



   reg [3:0]     dut_txdl_st_sop_int;
   reg [3:0]     dut_txdl_st_valid_int;
   reg [3:0]     dut_txdl_st_eop_int;
   reg [3:0]     dut_txdl_st_empty_int;
   reg [255:0]   dut_txdl_st_data_int;
   reg           dut_req_upfc_int;
   reg           dut_snd_upfc_int;
   reg  [1:0]    dut_typ_upfc_int;
   reg  [2:0]    dut_vcid_upfc_int;
   reg  [7:0]    dut_hdr_upfc_int;
   reg  [11:0]   dut_data_upfc_int;
   reg           dut_val_upfc_int;

   wire [55:0]    dut_k_vc0;
   wire[3:0]     dut_rx_typ_pm_int;
   wire          dut_rx_val_pm_int;
   wire  [3:0]   dut_rxdl_val_fc_int;
   wire  [15:0]  dut_rxdl_typ_fc_int;
   wire  [31:0]  dut_rxdl_hdr_fc_int;
   wire  [47:0]  dut_rxdl_data_fc_int;
   wire  [11:0]   dut_rxdl_vcid_fc_int;
   wire [3:0]    dut_rxdl_st_sop_int;
   wire [3:0]    dut_rxdl_st_eop_int;
   wire [3:0]    dut_rxdl_st_empty_int;
   wire          dut_rxdl_st_valid_int;
   wire [3:0]    dut_rxdl_st_tlp_check_int;
   wire[255:0]   dut_rxdl_st_data_int;
   wire [31:0]   dut_rxdl_st_parity_int;
   wire [3:0]    dut_rxdl_err_attr3_int;
   wire [3:0]    dut_rxdl_err_attr2_int;
   wire [3:0]    dut_rxdl_err_attr1_int;
   wire [3:0]    dut_rxdl_err_attr0_int;


   wire           dut_srst;
   wire           dut_crst;

   wire [3:0]     dut_txdl_st_sop;
   wire [3:0]     dut_txdl_st_valid;
   wire           dut_txdl_st_ready;
   wire [3:0]     dut_txdl_st_eop;
   wire [3:0]     dut_txdl_st_empty;
   wire [255:0]   dut_txdl_st_data;
   wire           dut_rxdl_st_ready;
   reg [3:0]     dut_rxdl_st_sop;
   reg [3:0]     dut_rxdl_st_eop;
   reg [3:0]     dut_rxdl_st_empty;
   reg           dut_rxdl_st_valid;
   reg [3:0]     dut_rxdl_st_tlp_check;
   reg[255:0]    dut_rxdl_st_data;
   reg [31:0]    dut_rxdl_st_parity;
   reg [3:0]     dut_rxdl_err_attr3;
   reg [3:0]     dut_rxdl_err_attr2;
   reg [3:0]     dut_rxdl_err_attr1;
   reg [3:0]     dut_rxdl_err_attr0;
   wire           dut_ack_upfc;
   wire           dut_req_upfc;
   wire           dut_snd_upfc;
   wire  [1:0]    dut_typ_upfc;
   wire  [2:0]    dut_vcid_upfc;
   wire  [7:0]    dut_hdr_upfc;
   wire  [11:0]   dut_data_upfc;
   wire           dut_val_upfc;
   reg  [3:0]     dut_rxdl_val_fc;
   reg  [15:0]    dut_rxdl_typ_fc;
   reg  [31:0]    dut_rxdl_hdr_fc;
   reg  [47:0]    dut_rxdl_data_fc;
   reg  [11:0]     dut_rxdl_vcid_fc;
   wire [7:0]     dut_vc_status;
   reg [3:0]      dut_rx_typ_pm;
   reg            dut_rx_val_pm;
   wire           dut_rpbuf_emp;
   wire[11:0]     dut_max_credit_replay_buffer;
   wire[5:0]      dut_max_credit_replay_fifo;
   wire           dut_clr_rxpath;
   wire           dut_dlup;
   wire[4:0]      dut_err_dll;
   wire[4:0]      dut_ltssm_state;
   wire           dut_l2_exit ;
   wire           dut_hotrst_exit;
   wire           dut_dlup_exit;
   wire           dut_ev1us;
   wire           dut_ev128ns;
   wire           dut_dlcm_sm_act;
   wire           dut_equlz_complete;
   wire           dut_in_l0s_req;
   wire           dut_in_l1_ok;
   wire           dut_link_auto_bdw_status;
   wire           dut_link_bdw_mng_status;
   wire           dut_link_equlz_req;
   wire           dut_phase_1_successful;
   wire           dut_phase_2_successful;
   wire           dut_phase_3_successful;
   wire           dut_rst_enter_comp_bit;
   wire[1:0]      dut_err_phy;
   wire           dut_rx_err_frame;
   wire[7:0]      dut_lane_err;
   wire           dut_current_deemp;
   wire  [1:0]    dut_current_speed;
   wire [3:0]     dut_lane_act;
   wire           dut_link_train;
   wire           dut_link_up;
   wire           dut_l0sstate;
   wire           dut_l0state ;

   altpcietb_tlbfm_s5gasket # (
       .pll_refclk_freq_hwtcl (pll_refclk_freq_hwtcl),   // ref clk for DUT
       .pcie_rate             (pcie_rate),
       .pcie_number_of_lanes  (pcie_number_of_lanes),
       .deemphasis_enable     (deemphasis_enable),
       .NUMCLKS_1us           (NUMCLKS_1us),
       .NUMCLKS_128ns         (NUMCLKS_128ns)            // # of DUT clocks in 128ns
   ) s5gasket (
     .dut_clk                  (dut_clk                ),
     .dut_rstn                 (dut_rstn               ),
     .dut_srst                 (dut_srst               ),
     .dut_crst                 (dut_crst               ),
     .avst64_clk               (avst64_clk             ),
     .avst64_rstn              (avst64_rstn            ),
     .vcintf_ena               (vcintf_ena             ),
     .dut_refclk               (dut_refclk             ),
     .dut_npor                 (dut_npor               ),
     .dut_pin_perst            (dut_pin_perst          ),
     .dut_test_in              (dut_test_in            ),
     .dut_k_vc0                (dut_k_vc0              ),
     .dut_txdl_st_sop          (dut_txdl_st_sop_int        ),
     .dut_txdl_st_valid        (dut_txdl_st_valid_int      ),
     .dut_txdl_st_ready        (dut_txdl_st_ready      ),
     .dut_txdl_st_eop          (dut_txdl_st_eop_int        ),
     .dut_txdl_st_empty        (dut_txdl_st_empty_int      ),
     .dut_txdl_st_data         (dut_txdl_st_data_int       ),
     .dut_rxdl_st_ready        (dut_rxdl_st_ready      ),
     .dut_rxdl_st_sop          (dut_rxdl_st_sop_int        ),
     .dut_rxdl_st_eop          (dut_rxdl_st_eop_int        ),
     .dut_rxdl_st_empty        (dut_rxdl_st_empty_int      ),
     .dut_rxdl_st_valid        (dut_rxdl_st_valid_int      ),
     .dut_rxdl_st_tlp_check    (dut_rxdl_st_tlp_check_int  ),
     .dut_rxdl_st_data         (dut_rxdl_st_data_int       ),
     .dut_rxdl_st_parity       (dut_rxdl_st_parity_int     ),
     .dut_rxdl_err_attr3       (dut_rxdl_err_attr3_int     ),
     .dut_rxdl_err_attr2       (dut_rxdl_err_attr2_int     ),
     .dut_rxdl_err_attr1       (dut_rxdl_err_attr1_int     ),
     .dut_rxdl_err_attr0       (dut_rxdl_err_attr0_int     ),
     .dut_ack_upfc             (dut_ack_upfc           ),
     .dut_req_upfc             (dut_req_upfc_int           ),
     .dut_snd_upfc             (dut_snd_upfc_int           ),
     .dut_typ_upfc             (dut_typ_upfc_int           ),
     .dut_vcid_upfc            (dut_vcid_upfc_int          ),
     .dut_hdr_upfc             (dut_hdr_upfc_int           ),
     .dut_data_upfc            (dut_data_upfc_int          ),
     .dut_val_upfc             (dut_val_upfc_int           ),
     .dut_rxdl_val_fc          (dut_rxdl_val_fc_int        ),
     .dut_rxdl_typ_fc          (dut_rxdl_typ_fc_int        ),
     .dut_rxdl_hdr_fc          (dut_rxdl_hdr_fc_int        ),
     .dut_rxdl_data_fc         (dut_rxdl_data_fc_int       ),
     .dut_rxdl_vcid_fc         (dut_rxdl_vcid_fc_int       ),
     .dut_vc_status            (dut_vc_status          ),
     .dut_rx_typ_pm            (dut_rx_typ_pm_int      ),
     .dut_rx_val_pm            (dut_rx_val_pm_int      ),
     .dut_rpbuf_emp            (dut_rpbuf_emp          ),
     .dut_max_credit_replay_buffer (dut_max_credit_replay_buffer),
     .dut_max_credit_replay_fifo   (dut_max_credit_replay_fifo  ),
     .dut_clr_rxpath           (dut_clr_rxpath          ),
     .dut_dlup                 (dut_dlup                ),
     .dut_err_dll              (dut_err_dll             ),
     .dut_ltssm_state          (dut_ltssm_state         ),
     .dut_l2_exit              (dut_l2_exit             ),
     .dut_hotrst_exit          (dut_hotrst_exit         ),
     .dut_dlup_exit            (dut_dlup_exit           ),
     .dut_ev1us                (dut_ev1us               ),
     .dut_ev128ns              (dut_ev128ns             ),
     .dut_dlcm_sm_act          (dut_dlcm_sm_act         ),
     .dut_equlz_complete       (dut_equlz_complete      ),
     .dut_in_l0s_req           (dut_in_l0s_req          ),
     .dut_in_l1_ok             (dut_in_l1_ok            ),
     .dut_link_auto_bdw_status (dut_link_auto_bdw_status),
     .dut_link_bdw_mng_status  (dut_link_bdw_mng_status ),
     .dut_link_equlz_req       (dut_link_equlz_req      ),
     .dut_phase_1_successful   (dut_phase_1_successful  ),
     .dut_phase_2_successful   (dut_phase_2_successful  ),
     .dut_phase_3_successful   (dut_phase_3_successful  ),
     .dut_rst_enter_comp_bit   (dut_rst_enter_comp_bit  ),
     .dut_err_phy              (dut_err_phy             ),
     .dut_rx_err_frame         (dut_rx_err_frame        ),
     .dut_lane_err             (dut_lane_err            ),
     .dut_current_deemp        (dut_current_deemp       ),
     .dut_current_speed        (dut_current_speed       ),
     .dut_lane_act             (dut_lane_act            ),
     .dut_link_train           (dut_link_train          ),
     .dut_link_up              (dut_link_up             ),
     .dut_l0sstate             (dut_l0sstate            ),
     .dut_l0state              (dut_l0state             ),
     .vcintf64_rx_st_ready     (vcintf64_rx_st_ready    ),
     .vcintf64_rx_st_sop       (vcintf64_rx_st_sop      ),
     .vcintf64_rx_st_valid     (vcintf64_rx_st_valid    ),
     .vcintf64_rx_st_eop       (vcintf64_rx_st_eop      ),
     .vcintf64_rx_st_empty     (vcintf64_rx_st_empty    ),
     .vcintf64_rx_st_data      (vcintf64_rx_st_data     ),
     .vcintf64_rxbuf_st_be     (vcintf64_rxbuf_st_be    ),
     .vcintf64_tx_st_sop       (vcintf64_tx_st_sop      ),
     .vcintf64_tx_st_valid     (vcintf64_tx_st_valid    ),
     .vcintf64_tx_st_eop       (vcintf64_tx_st_eop      ),
     .vcintf64_tx_st_empty     (vcintf64_tx_st_empty    ),
     .vcintf64_tx_st_data      (vcintf64_tx_st_data     ),
     .vcintf64_tx_st_cred      (vcintf64_tx_st_cred     )
  );

   /**************************************************
      INSERT PCIE TRANSPORT DELAYS (bfm_pcie_delay)
   ***************************************************/

   always @ (posedge dut_clk or negedge dut_rstn) begin
       if (~dut_rstn) begin
           // Inputs
           dut_txdl_st_sop_int    <= 4'h0;
           dut_txdl_st_valid_int  <= 1'h0;
           dut_txdl_st_eop_int    <= 4'h0;
           dut_txdl_st_empty_int  <= 4'h0;
           dut_txdl_st_data_int   <= 256'h0;
           dut_req_upfc_int       <= 1'h0;
           dut_snd_upfc_int       <= 1'h0;
           dut_typ_upfc_int       <= 2'h0;
           dut_vcid_upfc_int      <= 3'h0;
           dut_hdr_upfc_int       <= 8'h0;
           dut_data_upfc_int      <= 12'h0;
           dut_val_upfc_int       <= 1'h0;
           // outputs
           dut_rxdl_val_fc        <= 4'h0;
           dut_rxdl_typ_fc        <= 16'h0;
           dut_rxdl_hdr_fc        <= 32'h0;
           dut_rxdl_data_fc       <= 48'h0;
           dut_rxdl_vcid_fc       <= 12'h0;
           dut_rxdl_st_sop        <= 4'h0;
           dut_rxdl_st_eop        <= 4'h0;
           dut_rxdl_st_empty      <= 4'h0;
           dut_rxdl_st_valid      <= 1'h0;
           dut_rxdl_st_tlp_check  <= 4'h0;
           dut_rxdl_st_data       <= 256'h0;
           dut_rxdl_st_parity     <= 32'h0;
           dut_rxdl_err_attr3     <= 4'h0;
           dut_rxdl_err_attr2     <= 4'h0;
           dut_rxdl_err_attr1     <= 4'h0;
           dut_rxdl_err_attr0     <= 4'h0;
           dut_rx_typ_pm          <= 4'h0;
           dut_rx_val_pm          <= 1'h0;
       end
       else begin
           dut_txdl_st_sop_int    <= #bfm_pcie_delay dut_txdl_st_sop;
           dut_txdl_st_valid_int  <= #bfm_pcie_delay dut_txdl_st_valid;
           dut_txdl_st_eop_int    <= #bfm_pcie_delay dut_txdl_st_eop;
           dut_txdl_st_empty_int  <= #bfm_pcie_delay dut_txdl_st_empty;
           dut_txdl_st_data_int   <= #bfm_pcie_delay dut_txdl_st_data ;
           dut_req_upfc_int       <= #bfm_pcie_delay dut_req_upfc;
           dut_snd_upfc_int       <= #bfm_pcie_delay dut_snd_upfc;
           dut_typ_upfc_int       <= #bfm_pcie_delay dut_typ_upfc;
           dut_vcid_upfc_int      <= #bfm_pcie_delay dut_vcid_upfc;
           dut_hdr_upfc_int       <= #bfm_pcie_delay dut_hdr_upfc;
           dut_data_upfc_int      <= #bfm_pcie_delay dut_data_upfc;
           dut_val_upfc_int       <= #bfm_pcie_delay dut_val_upfc;
           // outputs
           dut_rxdl_val_fc        <= #bfm_pcie_delay dut_rxdl_val_fc_int;
           dut_rxdl_typ_fc        <= #bfm_pcie_delay dut_rxdl_typ_fc_int;
           dut_rxdl_hdr_fc        <= #bfm_pcie_delay dut_rxdl_hdr_fc_int;
           dut_rxdl_data_fc       <= #bfm_pcie_delay dut_rxdl_data_fc_int;
           dut_rxdl_vcid_fc       <= #bfm_pcie_delay dut_rxdl_vcid_fc_int;
           dut_rxdl_st_sop        <= #bfm_pcie_delay dut_rxdl_st_sop_int;
           dut_rxdl_st_eop        <= #bfm_pcie_delay dut_rxdl_st_eop_int;
           dut_rxdl_st_empty      <= #bfm_pcie_delay dut_rxdl_st_empty_int;
           dut_rxdl_st_valid      <= #bfm_pcie_delay dut_rxdl_st_valid_int;
           dut_rxdl_st_tlp_check  <= #bfm_pcie_delay dut_rxdl_st_tlp_check_int;
           dut_rxdl_st_data       <= #bfm_pcie_delay dut_rxdl_st_data_int;
           dut_rxdl_st_parity     <= #bfm_pcie_delay dut_rxdl_st_parity_int;
           dut_rxdl_err_attr3     <= #bfm_pcie_delay dut_rxdl_err_attr3_int;
           dut_rxdl_err_attr2     <= #bfm_pcie_delay dut_rxdl_err_attr2_int;
           dut_rxdl_err_attr1     <= #bfm_pcie_delay dut_rxdl_err_attr1_int;
           dut_rxdl_err_attr0     <= #bfm_pcie_delay dut_rxdl_err_attr0_int;
           dut_rx_typ_pm          <= #bfm_pcie_delay dut_rx_typ_pm_int;
           dut_rx_val_pm          <= #bfm_pcie_delay dut_rx_val_pm_int;
       end
   end

    /*******************************************************************
      Map DUT interface signals to TL BFM ports
    *******************************************************************/

    // tl_bfm_in bit positions

    localparam TLBFM_IN_DUT_CLK          = 1;
    localparam TLBFM_IN_RSTN             = 2;
    localparam TLBFM_IN_SRST             = 3;
    localparam TLBFM_IN_CRST             = 4;
    localparam TLBFM_IN_TXDL_ST_SOP_0    = 5;
    localparam TLBFM_IN_TXDL_ST_SOP_3    = 8;
    localparam TLBFM_IN_TXDL_ST_VALID_0  = 9;
    localparam TLBFM_IN_TXDL_ST_VALID_3  = 12;
    localparam TLBFM_IN_TXDL_ST_EOP_0    = 13;
    localparam TLBFM_IN_TXDL_ST_EOP_3    = 16;
    localparam TLBFM_IN_TXDL_ST_EMPTY_0  = 17;
    localparam TLBFM_IN_TXDL_ST_EMPTY_3  = 20;
    localparam TLBFM_IN_TXDL_ST_DATA_0   = 21;
    localparam TLBFM_IN_TXDL_ST_DATA_255 = 276;
    localparam TLBFM_IN_TX_CRED_0        = 277;
    localparam TLBFM_IN_TX_CRED_35       = 312;
    localparam TLBFM_IN_RXDL_ST_READY    = 313;
    localparam TLBFM_IN_REQ_UPFC         = 314;
    localparam TLBFM_IN_SND_UPFC         = 315;
    localparam TLBFM_IN_TYP_UPFC_0       = 316;
    localparam TLBFM_IN_TYP_UPFC_1       = 317;
    localparam TLBFM_IN_VCID_UPFC_0      = 318;
    localparam TLBFM_IN_VCID_UPFC_2      = 320;
    localparam TLBFM_IN_HDR_UPFC_0       = 321;
    localparam TLBFM_IN_HDR_UPFC_7       = 328;
    localparam TLBFM_IN_DATA_UPFC_0      = 329;
    localparam TLBFM_IN_DATA_UPFC_11     = 340;
    localparam TLBFM_IN_VAL_UPFC         = 341;
    localparam TLBFM_IN_K_VC_0           = 342;
    localparam TLBFM_IN_K_VC_55          = 397;
 //   localparam TLBFM_IN_VCID_UPFC_0      = 398;
 //   localparam TLBFM_IN_VCID_UPFC_11     = 409;

    // tl_bfm_out bit positions
    localparam TLBFM_OUT_RXDL_VALID_0     = 0;
    localparam TLBFM_OUT_RXDL_VALID_3     = 3;
    localparam TLBFM_OUT_RXDL_DATA_0      = 4;
    localparam TLBFM_OUT_RXDL_DATA_255    = 259;
    localparam TLBFM_OUT_RXDL_PARITY_0    = 260;
    localparam TLBFM_OUT_RXDL_PARITY_31   = 291;
    localparam TLBFM_OUT_RXDL_TLP_CHECK_0 = 292;
    localparam TLBFM_OUT_RXDL_TLP_CHECK_3 = 295;
    localparam TLBFM_OUT_RXDL_SOP_0       = 296;
    localparam TLBFM_OUT_RXDL_SOP_3       = 299;
    localparam TLBFM_OUT_RXDL_EOP_0       = 300;
    localparam TLBFM_OUT_RXDL_EOP_3       = 303;
    localparam TLBFM_OUT_rxdl_ERR_ATTR3_0 = 304;
    localparam TLBFM_OUT_rxdl_ERR_ATTR3_3 = 307;
    localparam TLBFM_OUT_rxdl_ERR_ATTR2_0 = 308;
    localparam TLBFM_OUT_rxdl_ERR_ATTR2_3 = 311;
    localparam TLBFM_OUT_rxdl_ERR_ATTR1_0 = 312;
    localparam TLBFM_OUT_rxdl_ERR_ATTR1_3 = 315;
    localparam TLBFM_OUT_rxdl_ERR_ATTR0_0 = 316;
    localparam TLBFM_OUT_rxdl_ERR_ATTR0_3 = 319;
    localparam TLBFM_OUT_TXDL_ST_READY    = 320;
    localparam TLBFM_OUT_RX_VAL_PM        = 321;
    localparam TLBFM_OUT_RX_TYP_PM_0      = 322;
    localparam TLBFM_OUT_RX_TYP_PM_3      = 325;
    localparam TLBFM_OUT_RXDL_VAL_FC_0    = 326;
    localparam TLBFM_OUT_RXDL_VAL_FC_3    = 329;
    localparam TLBFM_OUT_RXDL_TYP_FC_0    = 330;
    localparam TLBFM_OUT_RXDL_TYP_FC_15   = 345;
//    localparam TLBFM_OUT_RXDL_VCID_FC_0   = 346;
//    localparam TLBFM_OUT_RXDL_VCID_FC_2   = 347;
    localparam TLBFM_OUT_RXDL_HDR_FC_0    = 348;
    localparam TLBFM_OUT_RXDL_HDR_FC_31   = 380;
    localparam TLBFM_OUT_RXDL_DATA_FC_0   = 381;
    localparam TLBFM_OUT_RXDL_DATA_FC_47  = 428;
    localparam TLBFM_OUT_ACK_UPFC         = 429;
    localparam TLBFM_OUT_VC_STATUS_0      = 430;
    localparam TLBFM_OUT_VC_STATUS_7      = 437;

    localparam TLBFM_OUT_RPBUF_EMP                   = 442;
    localparam TLBFM_OUT_MAX_CREDIT_REPLAY_BUFFER_0  = 443;
    localparam TLBFM_OUT_MAX_CREDIT_REPLAY_BUFFER_11 = 454;
    localparam TLBFM_OUT_MAX_CREDIT_REPLAY_FIFO_0    = 455;
    localparam TLBFM_OUT_MAX_CREDIT_REPLAY_FIFO_5    = 460;
    localparam TLBFM_OUT_CLR_RXPATH                  = 461;
    localparam TLBFM_OUT_DLUP                        = 462;
    localparam TLBFM_OUT_ERR_DLL                     = 463;
    localparam TLBFM_OUT_DLCM_SM_ACT                 = 464;
    localparam TLBFM_OUT_RX_ERR_FRAME                = 465;

    localparam TLBFM_OUT_EQULZ_COMPLETE              = 466;
    localparam TLBFM_OUT_IN_L0S_REQ                  = 467;
    localparam TLBFM_OUT_IN_L1_OK                    = 468;
    localparam TLBFM_OUT_L0SSTATE                    = 469;
    localparam TLBFM_OUT_L0STATE                     = 470;
    localparam TLBFM_OUT_LANE_ACT_0                  = 471;
    localparam TLBFM_OUT_LANE_ACT_3                  = 474;
    localparam TLBFM_OUT_LINK_AUTO_BDW_STATUS        = 475;
    localparam TLBFM_OUT_LINK_BDW_MNG_STATUS         = 476;
    localparam TLBFM_OUT_LINK_EQULZ_REQ              = 477;
    localparam TLBFM_OUT_LINK_TRAIN                  = 478;
    localparam TLBFM_OUT_LINK_UP                     = 479;
    localparam TLBFM_OUT_PHASE_1_SUCCESSFUL          = 480;
    localparam TLBFM_OUT_PHASE_2_SUCCESSFUL          = 481;
    localparam TLBFM_OUT_PHASE_3_SUCCESSFUL          = 482;
    localparam TLBFM_OUT_RST_ENTER_COMP_BIT          = 483;
    localparam TLBFM_OUT_ERR_PHY_0                   = 484;
    localparam TLBFM_OUT_ERR_PHY_1                   = 485;
    localparam TLBFM_OUT_LANE_ERR_0                  = 486;
    localparam TLBFM_OUT_LANE_ERR_7                  = 493;
    localparam TLBFM_OUT_LTSSM_STATE_0               = 494;
    localparam TLBFM_OUT_LTSSM_STATE_4               = 498;
    localparam TLBFM_OUT_L2_EXIT                     = 499;
    localparam TLBFM_OUT_HOTRST_EXIT                 = 500;
    localparam TLBFM_OUT_DLUP_EXIT                   = 501;
    localparam TLBFM_OUT_EV1US                       = 502;
    localparam TLBFM_OUT_EV128NS                     = 503;
    localparam TLBFM_OUT_CURRENT_SPEED_0             = 504;
    localparam TLBFM_OUT_CURRENT_SPEED_1             = 505;
    localparam TLBFM_OUT_CURRENT_DEEMP               = 506;
    localparam TLBFM_OUT_ACK_PHYPM_0                 = 507;
    localparam TLBFM_OUT_ACK_PHYPM_3                 = 510;
    localparam TLBFM_OUT_RX_TXPRESET_0               = 511;
    localparam TLBFM_OUT_RX_TXPRESET_31              = 542;
    localparam TLBFM_OUT_RX_RXPRESET_0               = 543;
    localparam TLBFM_OUT_RX_RXPRESET_23              = 566;
    localparam TLBFM_OUT_RX_TS_0                     = 567;
    localparam TLBFM_OUT_RX_TS_7                     = 574;
    localparam TLBFM_OUT_TX_PAR_ERR                  = 575;
    localparam TLBFM_OUT_TX_ACK_PM                   = 576;
    localparam TLBFM_OUT_PL_CURRENT_SPEED_0          = 577;
    localparam TLBFM_OUT_PL_CURRENT_SPEED_1          = 578;
    localparam TLBFM_OUT_DL_CURRENT_DEEMP            = 579;
    localparam TLBFM_OUT_DLL_REQ                     = 580;
    localparam TLBFM_OUT_RXDL_VCID_FC_0              = 581;
    localparam TLBFM_OUT_RXDL_VCID_FC_11             = 592;

    // To TL_BFM
    //--------------
    assign dut_clk   = tlbfm_in[TLBFM_IN_DUT_CLK] ;
    assign dut_rstn  = tlbfm_in[TLBFM_IN_RSTN]    ;
    assign dut_srst  = tlbfm_in[TLBFM_IN_SRST]    ;
    assign dut_crst  = tlbfm_in[TLBFM_IN_CRST]    ;

    assign dut_txdl_st_sop   = tlbfm_in[TLBFM_IN_TXDL_ST_SOP_3:TLBFM_IN_TXDL_ST_SOP_0];
    assign dut_txdl_st_valid = tlbfm_in[TLBFM_IN_TXDL_ST_VALID_3:TLBFM_IN_TXDL_ST_VALID_0];
    assign dut_txdl_st_eop   = tlbfm_in[TLBFM_IN_TXDL_ST_EOP_3:TLBFM_IN_TXDL_ST_EOP_0];
    assign dut_txdl_st_empty = tlbfm_in[TLBFM_IN_TXDL_ST_EMPTY_3:TLBFM_IN_TXDL_ST_EMPTY_0];
    assign dut_txdl_st_data  = tlbfm_in[TLBFM_IN_TXDL_ST_DATA_255:TLBFM_IN_TXDL_ST_DATA_0];

    assign dut_rxdl_st_ready = 1'b1;

    assign dut_req_upfc  = tlbfm_in[TLBFM_IN_REQ_UPFC];
    assign dut_snd_upfc  = tlbfm_in[TLBFM_IN_SND_UPFC];
    assign dut_typ_upfc  = tlbfm_in[TLBFM_IN_TYP_UPFC_1:TLBFM_IN_TYP_UPFC_0];
    assign dut_vcid_upfc = tlbfm_in[TLBFM_IN_VCID_UPFC_2:TLBFM_IN_VCID_UPFC_0];
    assign dut_hdr_upfc  = tlbfm_in[TLBFM_IN_HDR_UPFC_7:TLBFM_IN_HDR_UPFC_0];
    assign dut_data_upfc = tlbfm_in[TLBFM_IN_DATA_UPFC_11:TLBFM_IN_DATA_UPFC_0];
    assign dut_val_upfc  = tlbfm_in[TLBFM_IN_VAL_UPFC];
    assign dut_k_vc0     = tlbfm_in[TLBFM_IN_K_VC_55:TLBFM_IN_K_VC_0];


    // from RXDL bfm
    //---------------
    assign  tlbfm_out[TLBFM_OUT_RXDL_VALID_0]                                 = dut_rxdl_st_valid;
    assign  tlbfm_out[TLBFM_OUT_RXDL_DATA_255:TLBFM_OUT_RXDL_DATA_0]          = dut_rxdl_st_data;
    assign  tlbfm_out[TLBFM_OUT_RXDL_PARITY_31:TLBFM_OUT_RXDL_PARITY_0]       = dut_rxdl_st_parity;
    assign  tlbfm_out[TLBFM_OUT_RXDL_TLP_CHECK_3:TLBFM_OUT_RXDL_TLP_CHECK_0]  = dut_rxdl_st_tlp_check;
    assign  tlbfm_out[TLBFM_OUT_RXDL_SOP_3:TLBFM_OUT_RXDL_SOP_0]              = dut_rxdl_st_sop;
    assign  tlbfm_out[TLBFM_OUT_RXDL_EOP_3:TLBFM_OUT_RXDL_EOP_0]              = dut_rxdl_st_eop;
    assign  tlbfm_out[TLBFM_OUT_rxdl_ERR_ATTR3_3:TLBFM_OUT_rxdl_ERR_ATTR3_0]  = dut_rxdl_err_attr3;
    assign  tlbfm_out[TLBFM_OUT_rxdl_ERR_ATTR2_3:TLBFM_OUT_rxdl_ERR_ATTR2_0]  = dut_rxdl_err_attr2;
    assign  tlbfm_out[TLBFM_OUT_rxdl_ERR_ATTR1_3:TLBFM_OUT_rxdl_ERR_ATTR1_0]  = dut_rxdl_err_attr1;
    assign  tlbfm_out[TLBFM_OUT_rxdl_ERR_ATTR0_3:TLBFM_OUT_rxdl_ERR_ATTR0_0]  = dut_rxdl_err_attr0;

    // from TXDL bfm
    //---------------
    assign  tlbfm_out[TLBFM_OUT_TXDL_ST_READY] = dut_txdl_st_ready ;

    // from RXDL bfm
    //-----------------
    assign tlbfm_out[TLBFM_OUT_RX_VAL_PM]                                = dut_rx_val_pm;
    assign tlbfm_out[TLBFM_OUT_RX_TYP_PM_3:TLBFM_OUT_RX_TYP_PM_0]        = dut_rx_typ_pm;
    assign tlbfm_out[TLBFM_OUT_RXDL_VAL_FC_3:TLBFM_OUT_RXDL_VAL_FC_0]    = dut_rxdl_val_fc;
    assign tlbfm_out[TLBFM_OUT_RXDL_TYP_FC_15:TLBFM_OUT_RXDL_TYP_FC_0]   = dut_rxdl_typ_fc;
    assign tlbfm_out[TLBFM_OUT_RXDL_VCID_FC_11:TLBFM_OUT_RXDL_VCID_FC_0]  = dut_rxdl_vcid_fc;
    assign tlbfm_out[TLBFM_OUT_RXDL_HDR_FC_31:TLBFM_OUT_RXDL_HDR_FC_0]   = dut_rxdl_hdr_fc;
    assign tlbfm_out[TLBFM_OUT_RXDL_DATA_FC_47:TLBFM_OUT_RXDL_DATA_FC_0] = dut_rxdl_data_fc;


    // DL Sideband signals
    //---------------------
    assign tlbfm_out[TLBFM_OUT_ACK_UPFC]                            = dut_ack_upfc;
    assign tlbfm_out[TLBFM_OUT_VC_STATUS_7:TLBFM_OUT_VC_STATUS_0]   = dut_vc_status;
    assign tlbfm_out[TLBFM_OUT_RPBUF_EMP]                           = dut_rpbuf_emp;
    assign tlbfm_out[TLBFM_OUT_MAX_CREDIT_REPLAY_BUFFER_11:
                     TLBFM_OUT_MAX_CREDIT_REPLAY_BUFFER_0]          = dut_max_credit_replay_buffer;
    assign tlbfm_out[TLBFM_OUT_MAX_CREDIT_REPLAY_FIFO_5:
                     TLBFM_OUT_MAX_CREDIT_REPLAY_FIFO_0]            = dut_max_credit_replay_fifo;
    assign tlbfm_out[TLBFM_OUT_CLR_RXPATH]                          = dut_clr_rxpath;
    assign tlbfm_out[TLBFM_OUT_DLUP]                                = dut_dlup;
    assign tlbfm_out[TLBFM_OUT_ERR_DLL]                             = dut_err_dll;
    assign tlbfm_out[TLBFM_OUT_DLCM_SM_ACT]                         = dut_dlcm_sm_act;
    assign tlbfm_out[TLBFM_OUT_RX_ERR_FRAME]                        = dut_rx_err_frame;
    assign tlbfm_out[TLBFM_OUT_ACK_PHYPM_3 : TLBFM_OUT_ACK_PHYPM_0] = 4'h0;               // PM not supported
    assign tlbfm_out[TLBFM_OUT_TX_PAR_ERR]                          = 1'h0;               // errors not supported
    assign tlbfm_out[TLBFM_OUT_TX_ACK_PM]                           = 1'b0;               // PM not supported
    assign tlbfm_out[TLBFM_OUT_DLL_REQ]                             = 1'b0;               // PM not supported

    // PL Sideband signals
    //-----------------------
    assign  tlbfm_out[TLBFM_OUT_EQULZ_COMPLETE]       = dut_equlz_complete;
    assign  tlbfm_out[TLBFM_OUT_IN_L0S_REQ]           = dut_in_l0s_req;
    assign  tlbfm_out[TLBFM_OUT_IN_L1_OK]             = dut_in_l1_ok;
    assign  tlbfm_out[TLBFM_OUT_L0SSTATE]             = dut_l0sstate;
    assign  tlbfm_out[TLBFM_OUT_L0STATE]              = dut_l0state;
    assign  tlbfm_out[TLBFM_OUT_LANE_ACT_3:
                      TLBFM_OUT_LANE_ACT_0]           = dut_lane_act;
    assign  tlbfm_out[TLBFM_OUT_LINK_AUTO_BDW_STATUS] = dut_link_auto_bdw_status;
    assign  tlbfm_out[TLBFM_OUT_LINK_BDW_MNG_STATUS]  = dut_link_bdw_mng_status;
    assign  tlbfm_out[TLBFM_OUT_LINK_EQULZ_REQ]       = dut_link_equlz_req;
    assign  tlbfm_out[TLBFM_OUT_LINK_TRAIN]           = dut_link_train;
    assign  tlbfm_out[TLBFM_OUT_LINK_UP]              = dut_link_up;
    assign  tlbfm_out[TLBFM_OUT_PHASE_1_SUCCESSFUL]   = dut_phase_1_successful;
    assign  tlbfm_out[TLBFM_OUT_PHASE_2_SUCCESSFUL]   = dut_phase_2_successful;
    assign  tlbfm_out[TLBFM_OUT_PHASE_3_SUCCESSFUL]   = dut_phase_3_successful;
    assign  tlbfm_out[TLBFM_OUT_RST_ENTER_COMP_BIT]   = dut_rst_enter_comp_bit;
    assign  tlbfm_out[TLBFM_OUT_ERR_PHY_1:
                      TLBFM_OUT_ERR_PHY_0]            = dut_err_phy;
    assign  tlbfm_out[TLBFM_OUT_LANE_ERR_7:
                      TLBFM_OUT_LANE_ERR_0]           = dut_lane_err;
    assign  tlbfm_out[TLBFM_OUT_LTSSM_STATE_4:
                      TLBFM_OUT_LTSSM_STATE_0]        = dut_ltssm_state;
    assign  tlbfm_out[TLBFM_OUT_L2_EXIT]              = dut_l2_exit;
    assign  tlbfm_out[TLBFM_OUT_HOTRST_EXIT]          = dut_hotrst_exit;
    assign  tlbfm_out[TLBFM_OUT_DLUP_EXIT]            = dut_dlup_exit;
    assign  tlbfm_out[TLBFM_OUT_EV1US]                = dut_ev1us;
    assign  tlbfm_out[TLBFM_OUT_EV128NS]              = dut_ev128ns;
    assign  tlbfm_out[TLBFM_OUT_CURRENT_SPEED_1:
                      TLBFM_OUT_CURRENT_SPEED_0]      = dut_current_speed;
    assign  tlbfm_out[TLBFM_OUT_CURRENT_DEEMP]        = dut_current_deemp;
    assign  tlbfm_out[TLBFM_OUT_RX_TXPRESET_31:
                      TLBFM_OUT_RX_TXPRESET_0]        = 32'h0;              // gen3 Equaliz not supported
    assign  tlbfm_out[TLBFM_OUT_RX_RXPRESET_23:
                      TLBFM_OUT_RX_RXPRESET_0]        = 24'h0;              // gen3 Equaliz not supported
    assign  tlbfm_out[TLBFM_OUT_RX_TS_7:
                      TLBFM_OUT_RX_TS_0]              = 8'h0;               // gen3 Equaliz not supported
    assign  tlbfm_out[TLBFM_OUT_PL_CURRENT_SPEED_1:
                      TLBFM_OUT_PL_CURRENT_SPEED_0]   = dut_current_speed;  // TBD
    assign  tlbfm_out[TLBFM_OUT_DL_CURRENT_DEEMP]     = dut_current_deemp;  // TBD


endmodule





