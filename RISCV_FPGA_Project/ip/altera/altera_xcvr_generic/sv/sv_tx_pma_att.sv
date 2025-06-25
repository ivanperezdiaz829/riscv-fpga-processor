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


`timescale 1ps/1ps

// submodules: pma_tx_att and pma_ser_att 
module sv_tx_pma_att #(
    parameter num_lanes =                        1,
// pma_tx_att parameters
    parameter tx_enable_debug_info =             "false",  
    parameter tx_powerdown =                     "normal_tx_on",    
    parameter vcm_current_addl =                 "low_current", 
    parameter vod_ctrl_main_tap_level =          "vod_0ma",
    parameter pre_emp_ctrl_post_tap_level =      "fir_post_disabled",
    parameter term_sel =                         "r_setting_7",
    parameter high_vccehtx =                     "volt_1p5v",
    parameter clock_monitor =                    "disable_clk_mon",    
    parameter main_tap_lowpass_filter_en_0 =     "enable_lp_main_0",    
    parameter main_tap_lowpass_filter_en_1 =     "enable_lp_main_1", 
    parameter pre_tap_lowpass_filter_en_0 =      "enable_lp_pre_0",  
    parameter pre_tap_lowpass_filter_en_1 =      "enable_lp_pre_1",  
    parameter post_tap_lowpass_filter_en_0 =     "enable_lp_post_0",    
    parameter post_tap_lowpass_filter_en_1 =     "enable_lp_post_1",    
    parameter main_driver_switch_en_0 =          "enable_main_switch_0", 
    parameter main_driver_switch_en_1 =          "enable_main_switch_1", 
    parameter main_driver_switch_en_2 =          "enable_main_switch_2", 
    parameter main_driver_switch_en_3 =          "disable_main_switch_3",    
    parameter pre_driver_switch_en_0 =           "disable_pre_switch_0",  
    parameter pre_driver_switch_en_1 =           "disable_pre_switch_1",  
    parameter post_driver_switch_en_0 =          "disable_post_switch_0",    
    parameter post_driver_switch_en_1 =          "disable_post_switch_1",    
    parameter common_mode_driver_sel =           "volt_0p65v",    
    parameter revlb_select =                     "sel_met_lb",  
    parameter rev_ser_lb_en =                    "disable_rev_ser_lb",
    parameter termination_en =                   "enable_termination",
// pma_ser_att parameter
    parameter ser_enable_debug_info =            "false",
    parameter ser_pdb =                          "power_up",
    parameter ser_loopback =                     "loopback_disable" 
) ( 
// pma_tx_att's wires
    input  wire [ num_lanes*11-1:0 ]    avmmaddress,
    input  wire [ num_lanes*2-1:0 ]     avmmbyteen,
    input  wire [ num_lanes-1:0 ]     avmmclk,
    input  wire [ num_lanes-1:0 ]     avmmread,
    input  wire [ num_lanes-1:0 ]     avmmrstn,
    input  wire [ num_lanes-1:0 ]     avmmwrite,
    input  wire [ num_lanes*16-1:0 ]  avmmwritedata,
    input  wire [ num_lanes-1:0 ]     clk270bout,
    input  wire [ num_lanes-1:0 ]     clk90bout,
    input  wire [ num_lanes-1:0 ]     devenbout,
    input  wire [ num_lanes-1:0 ]     devenout,
    input  wire [ num_lanes-1:0 ]     doddbout,
    input  wire [ num_lanes-1:0 ]     doddout,

    //pma aux calibration clock
    input wire  [ num_lanes-1:0 ]     calclk,

//    input  wire [ 0:0 ]     oe,
//    input  wire [ 0:0 ]     oeb,
//    input  wire [ 0:0 ]     oo,
//    input  wire [ 0:0 ]     oob,
    input  wire [ num_lanes-1:0 ]     rstn,
    input  wire [ num_lanes-1:0 ]     rtxrlpbk,
    input  wire [ num_lanes-1:0 ]     rxrlpbkn,
    input  wire [ num_lanes-1:0 ]     rxrlpbkp,
    input  wire [ num_lanes-1:0 ]     vonbidirin,
    input  wire [ num_lanes-1:0 ]     vopbidirin,
    output wire [ num_lanes*16-1:0 ]  tx_avmmreaddata,
    output wire [ num_lanes-1:0 ]     tx_blockselect,
    output wire [ num_lanes-1:0 ]     vonbidirout,
    output wire [ num_lanes-1:0 ]     vopbidirout,

// pma_ser_att's input  wires
//    input  wire [ 10:0 ]    avmmaddress,
//    input  wire [ 1:0 ]     avmmbyteen,
//    input  wire [ 0:0 ]     avmmclk,
//    input  wire [ 0:0 ]     avmmread,
//    input  wire [ 0:0 ]     avmmrstn,
//    input  wire [ 0:0 ]     avmmwrite,
//    input  wire [ 15:0 ]    avmmwritedata,
    input  wire [ num_lanes-1:0 ]     clk0,
    input  wire [ num_lanes-1:0 ]     clk180,
    input  wire [ num_lanes*128-1:0 ]   datain,
//    input  wire [ 0:0 ]     rstn,
    input  wire [ num_lanes-1:0 ]     slpbk,
    output wire [ num_lanes*16-1:0 ]    ser_avmmreaddata,
    output wire [ num_lanes-1:0 ]     ser_blockselect,
    output wire [ num_lanes-1:0 ]     clkdivtxtop,
    output wire [ num_lanes-1:0 ]     lbvon,
    output wire [ num_lanes-1:0 ]     lbvop 
//    output wire [ 0:0 ]     oe,
//    output wire [ 0:0 ]     oeb,
//    output wire [ 0:0 ]     oo,
//    output wire [ 0:0 ]     oob

);

    localparam cal_clk_sel = "pm_aux_iqclk_cal_clk_sel_cal_clk";

    genvar i;
    generate
    for( i=0; i < num_lanes; i=i+1 )
    begin : tx_ch

// internal wires
    wire [ 0:0 ]     oe;
    wire [ 0:0 ]     oeb;
    wire [ 0:0 ]     oo;
    wire [ 0:0 ]     oob;
    wire [ 0:0 ]     nonuserfrompmaux;
    wire [10:0]      int_refiqclk;

    //Tie off IQCLK connection to allow merging with non-CVP mode regular
   //channels
   assign int_refiqclk = {11{1'b0}};

      stratixv_hssi_pma_tx_att #(
        .enable_debug_info (                    tx_enable_debug_info ),
        .tx_powerdown (                                 tx_powerdown ),
        .vod_ctrl_main_tap_level(            vod_ctrl_main_tap_level ),	
	    .pre_emp_ctrl_post_tap_level (   pre_emp_ctrl_post_tap_level ),
        .term_sel (                                         term_sel ),
        .high_vccehtx (                                 high_vccehtx ),
        .vcm_current_addl (                         vcm_current_addl ),
        .clock_monitor (                               clock_monitor ),
        .main_tap_lowpass_filter_en_0 ( main_tap_lowpass_filter_en_0 ),
        .main_tap_lowpass_filter_en_1 ( main_tap_lowpass_filter_en_1 ),
        .pre_tap_lowpass_filter_en_0 (   pre_tap_lowpass_filter_en_0 ),
        .pre_tap_lowpass_filter_en_1 (   pre_tap_lowpass_filter_en_1 ),
        .post_tap_lowpass_filter_en_0 ( post_tap_lowpass_filter_en_0 ),
        .post_tap_lowpass_filter_en_1 ( post_tap_lowpass_filter_en_1 ),
        .main_driver_switch_en_0 (           main_driver_switch_en_0 ),
        .main_driver_switch_en_1 (           main_driver_switch_en_1 ),
        .main_driver_switch_en_2 (           main_driver_switch_en_2 ),
        .main_driver_switch_en_3 (           main_driver_switch_en_3 ),
        .pre_driver_switch_en_0 (             pre_driver_switch_en_0 ),
        .pre_driver_switch_en_1 (             pre_driver_switch_en_1 ),
        .post_driver_switch_en_0 (           post_driver_switch_en_0 ),
        .post_driver_switch_en_1 (           post_driver_switch_en_1 ),
        .common_mode_driver_sel (             common_mode_driver_sel ),
        .revlb_select (                                 revlb_select ),
        .rev_ser_lb_en (                               rev_ser_lb_en )
      ) stratixv_hssi_pma_tx_att_inst (
        .avmmaddress (              avmmaddress[i*11+:11] ),
        .avmmbyteen (                avmmbyteen[i*2+:2] ),
        .avmmclk (                      avmmclk[i] ),
        .avmmread (                    avmmread[i] ),
        .avmmrstn (                    avmmrstn[i] ),
        .avmmwrite (                  avmmwrite[i] ),
        .avmmwritedata (          avmmwritedata[i*16+:16] ),
        .clk270bout (                clk270bout[i] ),
        .clk90bout (                  clk90bout[i] ),
        .devenbout (                  devenbout[i] ),
        .devenout (                    devenout[i] ),
        .doddbout (                    doddbout[i] ),
        .nonuserfrompmaux (    nonuserfrompmaux[i] ),
        .doddout (                      doddout[i] ),
        .oe (                                oe ),
        .oeb (                              oeb ),
        .oo (                                oo ),
        .oob (                              oob ),
        .rstn (                            rstn[i] ),
        .rtxrlpbk (                    rtxrlpbk[i] ),
        .rxrlpbkn (                    rxrlpbkn[i] ),
        .rxrlpbkp (                    rxrlpbkp[i] ),
        .vonbidirin (                vonbidirin[i] ),
        .vopbidirin (                vopbidirin[i] ),
        .avmmreaddata (         tx_avmmreaddata[i*16+:16] ),
        .blockselect (           tx_blockselect[i] ),
        .vonbidirout (              vonbidirout[i] ),
        .vopbidirout (              vopbidirout[i] )
      );

      stratixv_hssi_pma_aux #(
         .cal_clk_sel  (cal_clk_sel),
         .continuous_calibration ("true"),
         .rx_imp("cal_imp_52_ohm"),
         .tx_imp("cal_imp_52_ohm")
      )
        tx_pma_att_aux (
        .calpdb       (1'b1                 ),
        .calclk       (calclk[i]            ),
        .testcntl     (/*unused*/           ),
        .refiqclk     (int_refiqclk         ),
        .nonusertoio  (nonuserfrompmaux[i]  ),
        .zrxtx50      (/*unused*/           )
      ); 


      stratixv_hssi_pma_ser_att #(
        .enable_debug_info ( ser_enable_debug_info ),
        .ser_pdb (                         ser_pdb ),
        .ser_loopback (               ser_loopback )
      ) stratixv_hssi_pma_ser_att_inst (
        .avmmaddress (                   avmmaddress[i*11+:11] ),
        .avmmbyteen (                     avmmbyteen[i*2+:2] ),
        .avmmclk (                           avmmclk[i] ),
        .avmmread (                         avmmread[i] ),
        .avmmrstn (                         avmmrstn[i] ),
        .avmmwrite (                       avmmwrite[i] ),
        .avmmwritedata (               avmmwritedata[i*16+:16] ),
        .clk0 (                                 clk0[i] ),
        .clk180 (                             clk180[i] ),
        .datain (                             datain[i*128+:128] ),
        .rstn (                                 rstn[i] ),
        .slpbk (                               slpbk[i] ),
        .avmmreaddata (             ser_avmmreaddata[i*16+:16] ),
        .blockselect (               ser_blockselect[i] ),
        .clkdivtxtop (                   clkdivtxtop[i] ),
        .lbvon (                               lbvon[i] ),
        .lbvop (                               lbvop[i] ),
        .observableintclk   (                        ),
        .observablesyncdatain (                      ),
        .observableasyncdatain (                     ),
        .oe (                                     oe ),
        .oeb (                                   oeb ),
        .oo (                                     oo ),
        .oob (                                   oob )
      );
  end
  endgenerate
endmodule 
