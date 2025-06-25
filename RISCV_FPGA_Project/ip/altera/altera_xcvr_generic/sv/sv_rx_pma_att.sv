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

// submodules: pma_rx_att, pma_cdr_att and pma_deser_att 
module sv_rx_pma_att #(
    parameter num_lanes =                        1,
// pma_rx_att parameters
    parameter rx_enable_debug_info =             "false",  
    parameter rx_pdb =                           "power_down_rx", 
    parameter rxterm_set =                       "def_rterm",
    parameter eq0_dc_gain =                      "eq0_gain_min", 
    parameter eq1_dc_gain =                      "eq1_gain_min", 
    parameter eq2_dc_gain =                      "eq2_gain_min", 
    parameter rx_vcm =                           "vtt_0p7v",  
    parameter rxterm_ctl =                       "rxterm_dis",    
    parameter offset_cancellation_ctrl =         "volt_0mv",    
    parameter eq_bias_adj =                      "i_eqbias_def", 
    parameter atb_sel =                          "atb_off",  
    parameter offset_correct =                   "offcorr_dis",   
    parameter var_bulk0 =                        "eq0_var_bulk0", 
    parameter var_gate0 =                        "eq0_var_gate0",  
    parameter var_bulk1 =                        "eq1_var_bulk0",  
    parameter var_gate1 =                        "eq1_var_gate0",  
    parameter var_bulk2 =                        "eq2_var_bulk0",  
    parameter var_gate2 =                        "eq2_var_gate0",  
    parameter off_filter_cap =                   "off_filt_cap0", 
    parameter off_filter_res =                   "off_filt_res0", 
    parameter offcomp_cmref =                    "off_comp_vcm0",  
    parameter offcomp_igain =                    "off_comp_ig0",   
    parameter diag_loopbk_bias =                 "dlb_bw0", 
    parameter rload_shunt =                      "rld000",   
    parameter rzero_shunt =                      "rz0",  
    parameter eqz3_pd =                          "eqz3shrt_dis", 
    parameter vcm_pdnb =                         "lsb_lo_vcm_current",  
    parameter rx_diag_rev_lpbk =                 "no_diag_rev_loopback",
// pma_cdr_att parameters
    parameter cdr_enable_debug_info =            "false",  
    parameter reference_clock_frequency =        "250 MHz",   
    parameter output_clock_frequency =           "5000 MHz",  
    parameter bbpd_salatch_offset_ctrl_clk0 =    "offset_0mv", 
    parameter bbpd_salatch_offset_ctrl_clk180 =  "offset_0mv",   
    parameter bbpd_salatch_offset_ctrl_clk270 =  "offset_0mv",   
    parameter bbpd_salatch_offset_ctrl_clk90 =   "offset_0mv",    
    parameter bbpd_salatch_sel =                 "normal",  
    parameter bypass_cp_rgla =                   "false", 
    parameter cdr_atb_select =                   "atb_disable",   
    parameter charge_pump_current_test =         "enable_ch_pump_normal",   
    parameter clklow_fref_to_ppm_div_sel =       4,   
    parameter cdr_diag_rev_lpbk =                "false",  
    parameter fast_lock_mode =                   "false", 
    parameter fb_sel =                           "vcoclk",    
    parameter force_vco_const =                  "v1p39",   
    parameter hs_levshift_power_supply_setting = 1, 
    parameter ignore_phslock =                   "false", 
    parameter m_counter =                        4,    
    parameter pd_charge_pump_current_ctrl =      5,  
    parameter pd_l_counter =                     1, 
    parameter pfd_charge_pump_current_ctrl =     20,    
    parameter pfd_l_counter =                    1,    
    parameter ref_clk_div =                      1,  
    parameter regulator_volt_inc =               "0", 
    parameter replica_bias_ctrl =                "true",   
    parameter reverse_loopback =                 "reverse_lpbk_cdr",    
    parameter reverse_serial_lpbk =              "false",    
    parameter ripple_cap_ctrl =                  "none", 
    parameter rxpll_pd_bw_ctrl =                 320,   
    parameter rxpll_pfd_bw_ctrl =                3200,
    parameter ppm_lock_sel =                     "pcs_ppm_lock",	
	parameter ppmsel  =                          "ppmsel_100",
// pma_deser_att parameter
    parameter deser_enable_debug_info =          "false"
) ( 
// pma_rx_att's wires
    input  wire [ num_lanes*11 - 1:0 ]avmmaddress,
    input  wire [ num_lanes*2-1:0 ]   avmmbyteen,
    input  wire [ num_lanes-1:0 ]     avmmclk,
    input  wire [ num_lanes-1:0 ]     avmmread,
    input  wire [ num_lanes-1:0 ]     avmmrstn,
    input  wire [ num_lanes-1:0 ]     avmmwrite,
    input  wire [ num_lanes*16-1:0 ]  avmmwritedata,
    input  wire [ num_lanes-1:0 ]     lpbkn,
    input  wire [ num_lanes-1:0 ]     lpbkp,
    input  wire [ num_lanes-1:0 ]     ocden,
    input  wire [ num_lanes-1:0 ]     rxnbidirin,
    input  wire [ num_lanes-1:0 ]     rxpbidirin,
    input  wire [ num_lanes-1:0 ]     slpbk,
    output wire [ num_lanes*16-1:0 ]  rx_avmmreaddata,
    output wire [ num_lanes-1:0 ]     rx_blockselect,
//    output wire [ 0:0 ]     outnbidirout,
//    output wire [ 0:0 ]     outpbidirout,
    output wire [ num_lanes-1:0 ]     rdlpbkn,
    output wire [ num_lanes-1:0 ]     rdlpbkp,

    //pma aux calibration clock
    input wire  [ num_lanes-1:0 ]     calclk,

// cdr_att's input  wires
    input  wire [ num_lanes-1:0 ]     crurstb,
    input  wire [ num_lanes-1:0 ]     ltd,
    input  wire [ num_lanes-1:0 ]     ltr,
    input  wire [ num_lanes-1:0 ]     ppmlock,
    input  wire [ num_lanes-1:0 ]     refclk,
    input  wire [ num_lanes-1:0 ]     rstn,
    input  wire [ num_lanes-1:0 ]     atb_0_bidir_in,
    input  wire [ num_lanes-1:0 ]     atb_1_bidir_in,
    output  wire [ num_lanes-1:0 ]    atb_0_bidir_out,
    output  wire [ num_lanes-1:0 ]    atb_1_bidir_out,
    output  wire [ num_lanes-1:0 ]    atb_eye_att,
    input  wire [ num_lanes-1:0 ]     discdrreset,
//    input  wire [ 0:0 ]     rxp;                      // coming from rx_att module 
    output wire [ num_lanes-1:0 ]     ck0pd,
    output wire [ num_lanes-1:0 ]     ck180pd,
    output wire [ num_lanes-1:0 ]     ck270pd,
    output wire [ num_lanes-1:0 ]     ck90pd,
    output wire [ num_lanes-1:0 ]     clk270bout,
    output wire [ num_lanes-1:0 ]     clk90bout,
    output wire [ num_lanes-1:0 ]     clklow,
//    output wire [ 0:0 ]     devenadiv2p,
//    output wire [ 0:0 ]     devenbdiv2p,
    output wire [ num_lanes-1:0 ]     devenout,
//    output wire [ 0:0 ]     div2270,
//    output wire [ 0:0 ]     doddadiv2p,
//    output wire [ 0:0 ]     doddbdiv2p,
    output wire [ num_lanes-1:0 ]     doddout,
    output wire [ num_lanes-1:0 ]     fref,
    output wire [ num_lanes*4-1:0 ]   pdof,
    output wire [ num_lanes-1:0 ]     pfdmodelock,
    output wire [ num_lanes-1:0 ]     rxplllock,
    output wire [ num_lanes-1:0 ]     txrlpbk,

// pma_deser_att's input  wires
//    input  wire [ 10:0 ]    avmmaddress,
//    input  wire [ 1:0 ]     avmmbyteen,
//    input  wire [ 0:0 ]     avmmclk,
//    input  wire [ 0:0 ]     avmmread,
//    input  wire [ 0:0 ]     avmmrstn,
//    input  wire [ 0:0 ]     avmmwirte,
//    input  wire [ 15:0 ]    avmmwritedata,
//    input  wire [ 0:0 ]     devenadiv2n,
//    input  wire [ 0:0 ]     devenbdiv2n,
//    input  wire [ 0:0 ]     devenadiv2p,
//    input  wire [ 0:0 ]     devenbdiv2p,
//    input  wire [ 0:0 ]     div2270,
//    input  wire [ 0:0 ]     div2270n,
//    input  wire [ 0:0 ]     doddadiv2n,
//    input  wire [ 0:0 ]     doddadiv2p,
//    input  wire [ 0:0 ]     doddbdiv2n,
//    input  wire [ 0:0 ]     doddbdiv2p,
//    input  wire [ 0:0 ]     rstn,
    output wire [ num_lanes*16-1:0 ]  deser_avmmreaddata,
    output wire [ num_lanes-1:0 ]     deser_blockselect,
    output wire [ num_lanes-1:0 ]     clkdivrx,
    output wire [ num_lanes*128-1:0 ] dataout 
);

    localparam cal_clk_sel = "pm_aux_iqclk_cal_clk_sel_cal_clk";

    genvar i;
    generate
    for( i=0; i < num_lanes; i=i+1 )
    begin : rx_ch

// internal wires 
    // from rx_att to cdr_att
    wire [ 0:0 ]     outnbidirout;
    wire [ 0:0 ]     outpbidirout;
    // from cdr_att to deser_att
    wire [ 0:0 ]     devenadiv2p;
    wire [ 0:0 ]     devenbdiv2p;
    wire [ 0:0 ]     div2270;
    wire [ 0:0 ]     doddadiv2p;
    wire [ 0:0 ]     doddbdiv2p;
   // wire [ 0:0 ]     ppmlock_int;
    wire [ 0:0 ]     nonuserfrompmaux;
    wire [10:0]     int_refiqclk;

   //Tie off IQCLK connection to allow merging with non-CVP mode regular
   //channels
   assign int_refiqclk = {11{1'b0}}; 
     
      stratixv_hssi_pma_rx_att #(
        .enable_debug_info (            rx_enable_debug_info ),
        .rx_pdb (                                     rx_pdb ),
        .rxterm_set (                             rxterm_set ),
        .eq0_dc_gain (                           eq0_dc_gain ),
        .eq1_dc_gain (                           eq1_dc_gain ),
        .eq2_dc_gain (                           eq2_dc_gain ),
        .rx_vcm (                                     rx_vcm ),
        .rxterm_ctl (                             rxterm_ctl ),
        .offset_cancellation_ctrl ( offset_cancellation_ctrl ),
        .eq_bias_adj (                           eq_bias_adj ),
        .atb_sel (                                   atb_sel ),
        .offset_correct (                     offset_correct ),
        .var_bulk0 (                               var_bulk0 ),
        .var_gate0 (                               var_gate0 ),
        .var_bulk1 (                               var_bulk1 ),
        .var_gate1 (                               var_gate1 ),
        .var_bulk2 (                               var_bulk2 ),
        .var_gate2 (                               var_gate2 ),
        .off_filter_cap (                     off_filter_cap ),
        .off_filter_res (                     off_filter_res ),
        .offcomp_cmref (                       offcomp_cmref ),
        .offcomp_igain (                       offcomp_igain ),
        .diag_loopbk_bias (                 diag_loopbk_bias ),
        .rload_shunt (                           rload_shunt ),
        .rzero_shunt (                           rzero_shunt ),
        .eqz3_pd (                                   eqz3_pd ),
        .vcm_pdnb (                                 vcm_pdnb ),
        .diag_rev_lpbk (                    rx_diag_rev_lpbk )    
      ) stratixv_hssi_pma_rx_att_inst (
        .avmmaddress (              avmmaddress[i*11+:11] ),
        .avmmbyteen (                avmmbyteen[i*2+:2] ),
        .avmmclk (                      avmmclk[i] ),
        .avmmread (                    avmmread[i] ),
        .avmmrstn (                    avmmrstn[i] ),
        .avmmwrite (                  avmmwrite[i] ),
        .avmmwritedata (          avmmwritedata[i*16+:16] ),
        .lpbkn (                          lpbkn[i] ),
        .lpbkp (                          lpbkp[i] ),
        .ocden (                          ocden[i] ),
        .rxnbidirin (                rxnbidirin[i] ),
        .rxpbidirin (                rxpbidirin[i] ),
        .slpbk (                          slpbk[i] ),
        .avmmreaddata (         rx_avmmreaddata[i*16+:16] ),
        .blockselect (           rx_blockselect[i] ),
        .outnbidirout (            outnbidirout    ),
        .outpbidirout (            outpbidirout    ),
        .nonuserfrompmaux (    nonuserfrompmaux[i] ),
        .rdlpbkn (                      rdlpbkn[i] ),
        .rdlpbkp (                      rdlpbkp[i] )
      ); 

      stratixv_hssi_pma_aux #(
        .cal_clk_sel  (cal_clk_sel),
        .continuous_calibration ("true"),
        .rx_imp("cal_imp_52_ohm"),
        .tx_imp("cal_imp_52_ohm")
      )
      rx_pma_att_aux (
        .calpdb       (1'b1                 ),
        .calclk       (calclk[i]            ),
        .testcntl     (/*unused*/           ),
        .refiqclk     (int_refiqclk         ),
        .nonusertoio  (nonuserfrompmaux[i]  ),
        .zrxtx50      (/*unused*/           )
      );

      stratixv_hssi_pma_cdr_att #(
				  
        .enable_debug_info (                           cdr_enable_debug_info ),
        .reference_clock_frequency (               reference_clock_frequency ),
        .output_clock_frequency (                     output_clock_frequency ),
        .fb_sel (                                                     fb_sel ),
        .ppm_lock_sel (                                         ppm_lock_sel ),
        .ppmsel (                                                     ppmsel ),
        .regulator_volt_inc (                             regulator_volt_inc ),
	    .charge_pump_current_test ( "disable_ch_pump_curr_test"),
        .replica_bias_ctrl ( "false" )
				  
      ) stratixv_hssi_pma_cdr_att_inst (
        .crurstb (                                  crurstb[i] ),
        .ltd (                                         ~ltd[i] ),
        .ltr (                                          ltr[i] ),
        .ppmlock (                                  ppmlock[i] ),
        .refclk (                                    refclk[i] ),
        .rstn (                                        rstn[i] ),
`ifdef ALTERA_RESERVED_QIS_ES
        .discdrreset (                                         ), //float connection for ES as this is a production only signal
`else
        .discdrreset (                          discdrreset[i] ),
`endif
        .rxp (                                 outpbidirout[i] ),
        .ck0pd (                                      ck0pd[i] ),
        .ck180pd (                                  ck180pd[i] ),
        .ck270pd (                                  ck270pd[i] ),
        .ck90pd (                                    ck90pd[i] ),
        .clk270bout (                            clk270bout[i] ),
        .clk90bout (                              clk90bout[i] ),
        .clklow (                                    clklow[i] ),
        .devenadiv2p (                          devenadiv2p ),
        .devenbdiv2p (                          devenbdiv2p ),
        .devenout (                                devenout[i] ),
        .div2270 (                                  div2270 ),
        .doddadiv2p (                            doddadiv2p ),
        .doddbdiv2p (                            doddbdiv2p ),
        .doddout (                                  doddout[i] ),
        .fref (                                        fref[i] ),
        .pdof (                                        pdof[i*4+:4] ),
        .pfdmodelock (                          pfdmodelock[i] ),
        .rxplllock (                              rxplllock[i] ),
        .txrlpbk (                                  txrlpbk[i] ) 
      );

      stratixv_hssi_pma_deser_att #(
        .enable_debug_info ( deser_enable_debug_info )
      ) stratixv_hssi_pma_deser_att_inst (
        .avmmaddress (                   avmmaddress[i*11+:11] ),
        .avmmbyteen (                     avmmbyteen[i*2+:2] ),
        .avmmclk (                           avmmclk[i] ),
        .avmmread (                         avmmread[i] ),
        .avmmrstn (                         avmmrstn[i] ),
        .avmmwrite (                       avmmwrite[i] ),
        .avmmwritedata (               avmmwritedata[i*16+:16] ),
        .devenadiv2n (                   1'b0 ),
        .devenadiv2p (                   devenadiv2p ),
        .devenbdiv2n (                   1'b0 ),
        .devenbdiv2p (                   devenbdiv2p ),
        .div2270 (                           div2270 ),
        .div2270n (                         1'b0 ),
        .doddadiv2n (                     1'b0 ),
        .doddadiv2p (                     doddadiv2p ),
        .doddbdiv2n (                     1'b0 ),
        .doddbdiv2p (                     doddbdiv2p ),
        .rstn (                                 rstn[i] ),
        .avmmreaddata (           deser_avmmreaddata[i*16+:16] ),
        .blockselect (             deser_blockselect[i] ),
        .clkdivrx (                         clkdivrx[i] ),
        .dataout (                           dataout[i*128+:128] )
      );

   end
   endgenerate
endmodule 
