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

// submodules: sv_rx_pma_att, sv_tx_pma_att
module sv_pma_att #(
    parameter rx_enable =                        1,
    parameter tx_enable =                        1,
    parameter num_lanes =                        1,
// rx_pma_att parameters
    // pma_rx_att's wires
    parameter rx_enable_debug_info =             "false",  
    parameter rx_pdb =                           "power_down_rx",
    parameter rxterm_set =                       "rterm_9", 
    parameter eq0_dc_gain =                      "eq0_gain_max", 
    parameter eq1_dc_gain =                      "eq1_gain_max", 
    parameter eq2_dc_gain =                      "eq2_gain_set2", 
    parameter rx_vcm =                           "vtt_0p65v",  
    parameter rxterm_ctl =                       "rxterm_dis",    
    parameter offset_cancellation_ctrl =         "volt_0mv",    
    parameter eq_bias_adj =                      "i_eqbias_def", 
    parameter atb_sel =                          "atb_off",  
    parameter offset_correct =                   "eq1_pd_dcorr_en",   
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
    parameter cdr_reference_clock_frequency =    "250 MHz",   
    parameter pma_data_rate =                    "1250000000 bps", 
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
    parameter m_counter =                        "<auto>",    
    parameter pd_charge_pump_current_ctrl =      5,  
    parameter pd_l_counter =                     1, 
    parameter pfd_charge_pump_current_ctrl =     20,    
    parameter pfd_l_counter =                    1,    
    parameter ref_clk_div =                      "<auto>",  
    parameter regulator_volt_inc =               "30", 
    parameter replica_bias_ctrl =                "true",   
    parameter reverse_loopback =                 "reverse_lpbk_cdr",    
    parameter reverse_serial_lpbk =              "false",    
    parameter ripple_cap_ctrl =                  "none", 
    parameter rxpll_pd_bw_ctrl =                 320,   
    parameter rxpll_pfd_bw_ctrl =                3200,
    parameter ppm_lock_sel =                     "pcs_ppm_lock",	
	parameter ppmsel  =                          "ppmsel_100",
    // pma_deser_att parameter
    parameter deser_enable_debug_info =          "false",
// tx_pma_att parameters
    // pma_tx_att parameters
    parameter tx_enable_debug_info =             "false",  
    parameter tx_powerdown =                     "normal_tx_on",    
    parameter vcm_current_addl =                 "low_current", 
    parameter clock_monitor =                    "disable_clk_mon",    
    parameter main_tap_lowpass_filter_en_0 =     "enable_lp_main_0",    
    parameter main_tap_lowpass_filter_en_1 =     "enable_lp_main_1", 
    parameter pre_tap_lowpass_filter_en_0 =      "disable_lp_pre_0",  
    parameter pre_tap_lowpass_filter_en_1 =      "disable_lp_pre_1",  
    parameter post_tap_lowpass_filter_en_0 =     "enable_lp_post_0",    
    parameter post_tap_lowpass_filter_en_1 =     "enable_lp_post_1",    
    parameter main_driver_switch_en_0 =          "enable_main_switch_0", 
    parameter main_driver_switch_en_1 =          "enable_main_switch_1", 
    parameter main_driver_switch_en_2 =          "enable_main_switch_2", 
    parameter main_driver_switch_en_3 =          "disable_main_switch_3",    
    parameter pre_driver_switch_en_0 =           "disable_pre_switch_0",  
    parameter pre_driver_switch_en_1 =           "disable_pre_switch_1",  
    parameter post_driver_switch_en_0 =          "enable_post_switch_0",    
    parameter post_driver_switch_en_1 =          "enable_post_switch_1",    
    parameter common_mode_driver_sel =           "volt_0p50v",   
    parameter vod_ctrl_main_tap_level =          "vod_6ma",
    parameter pre_emp_ctrl_post_tap_level =      "fir_post_1p0ma",
    parameter term_sel =                         "r_setting_4",
    parameter high_vccehtx =                     "volt_1p5v", 
    parameter revlb_select =                     "sel_met_lb",  
    parameter rev_ser_lb_en =                    "disable_rev_ser_lb",
    parameter termination_en =                   "enable_termination",
    // pma_ser_att parameter
    parameter ser_enable_debug_info =            "false",
    parameter ser_pdb =                          "power_up",
    parameter ser_loopback =                     "loopback_disable" 
) (
// common interface that is shared by submodules
    input  wire [ num_lanes-1:0 ]     slpbk,
// rx_pma_att's input/output ports
    input  wire [ num_lanes*11-1:0 ]  rx_avmmaddress,
    input  wire [ num_lanes*2-1:0 ]   rx_avmmbyteen,
    input  wire [ num_lanes-1:0 ]     rx_avmmclk,
    input  wire [ num_lanes-1:0 ]     rx_avmmread,
    input  wire [ num_lanes-1:0 ]     rx_avmmrstn,
    input  wire [ num_lanes-1:0 ]     rx_avmmwrite,
    input  wire [ num_lanes*16-1:0 ]  rx_avmmwritedata,

    //pma aux calibration clock
    input wire  [ num_lanes-1:0 ]     rx_calclk,
    input wire  [ num_lanes-1:0 ]     tx_calclk,


    // pma_rx_att's wires
//    input  wire [ 0:0 ]     lpbkn,
//    input  wire [ 0:0 ]     lpbkp,
    input  wire [ num_lanes-1:0 ]     ocden,
    input  wire [ num_lanes-1:0 ]     rxnbidirin,
    input  wire [ num_lanes-1:0 ]     rxpbidirin,
    input  wire [ num_lanes-1:0 ]     rx_pma_rstn,
    output wire [ num_lanes*16-1:0 ]  rx_avmmreaddata,
    output wire [ num_lanes-1:0 ]     rx_blockselect,
//    output wire [ 0:0 ]     rdlpbkn,
//    output wire [ 0:0 ]     rdlpbkp,

    // cdr_att's input  wires
    input  wire [ num_lanes-1:0 ]     crurstb,
    input  wire [ num_lanes-1:0 ]     ltd,
    input  wire [ num_lanes-1:0 ]     ltr,
    input  wire [ num_lanes-1:0 ]     ppmlock,
    input  wire [ num_lanes-1:0 ]     refclk,
    input  wire [ num_lanes-1:0 ]     discdrreset,
//    input  wire [ 0:0 ]     rxp;                      // coming from rx_att module 
    output wire [ num_lanes-1:0 ]     ck0pd,
    output wire [ num_lanes-1:0 ]     ck180pd,
    output wire [ num_lanes-1:0 ]     ck270pd,
    output wire [ num_lanes-1:0 ]     ck90pd,
//    output wire [ 0:0 ]     clk270bout,
//    output wire [ 0:0 ]     clk90bout,
    output wire [ num_lanes-1:0 ]     clklow,
//    output wire [ 0:0 ]     devenout,
//    output wire [ 0:0 ]     doddout,
    output wire [ num_lanes-1:0 ]     fref,
    output wire [ num_lanes*4-1:0 ]   pdof,
    output wire [ num_lanes-1:0 ]     pfdmodelock,
    output wire [ num_lanes-1:0 ]     rxplllock,
//    output wire [ 0:0 ]     txrlpbk,

    // pma_deser_att's input  wires
    output wire [ num_lanes*16-1:0 ]    deser_avmmreaddata,
    output wire [ num_lanes-1:0 ]     deser_blockselect,
    output wire [ num_lanes-1:0 ]     clkdivrx,
    output wire [ num_lanes*128-1:0 ]   dataout,

// tx_pma_att's input/output ports
    input  wire [ num_lanes*11-1:0 ]    tx_avmmaddress,
    input  wire [ num_lanes*2-1:0 ]     tx_avmmbyteen,
    input  wire [ num_lanes-1:0 ]     tx_avmmclk,
    input  wire [ num_lanes-1:0 ]     tx_avmmread,
    input  wire [ num_lanes-1:0 ]     tx_avmmrstn,
    input  wire [ num_lanes-1:0 ]     tx_avmmwrite,
    input  wire [ num_lanes*16-1:0 ]    tx_avmmwritedata,
    // pma_tx_att's wires
//    input  wire [ 0:0 ]     clk270bout,
//    input  wire [ 0:0 ]     clk90bout,
//    input  wire [ 0:0 ]     devenbout,
//    input  wire [ 0:0 ]     devenout,
//    input  wire [ 0:0 ]     doddbout,
//    input  wire [ 0:0 ]     doddout,
//    input  wire [ 0:0 ]     rtxrlpbk,
//    input  wire [ 0:0 ]     rxrlpbkn,
//    input  wire [ 0:0 ]     rxrlpbkp,
    input  wire [ num_lanes-1:0 ]     tx_pma_rstn,
    input  wire [ num_lanes-1:0 ]     vonbidirin,
    input  wire [ num_lanes-1:0 ]     vopbidirin,
    output wire [ num_lanes*16-1:0 ]    tx_avmmreaddata,
    output wire [ num_lanes-1:0 ]     tx_blockselect,
    output wire [ num_lanes-1:0 ]     vonbidirout,
    output wire [ num_lanes-1:0 ]     vopbidirout,

    input  wire [ num_lanes-1:0 ]     atb_0_bidir_in,
    input  wire [ num_lanes-1:0 ]     atb_1_bidir_in,
    output  wire [ num_lanes-1:0 ]    atb_0_bidir_out,
    output  wire [ num_lanes-1:0 ]    atb_1_bidir_out,
    output  wire [ num_lanes-1:0 ]    atb_eye_att,

    // pma_ser_att's input  wires
    input  wire [ num_lanes-1:0 ]     clk0,
    input  wire [ num_lanes-1:0 ]     clk180,
    input  wire [ num_lanes*128-1:0 ]   datain,
    output wire [ num_lanes*16-1:0 ]    ser_avmmreaddata,
    output wire [ num_lanes-1:0 ]     ser_blockselect,
    output wire [ num_lanes-1:0 ]     clkdivtxtop 
//    output wire [ 0:0 ]     lbvon,
//    output wire [ 0:0 ]     lbvop 
);

import altera_xcvr_functions::*;  // Useful functions (primarily for rule-checking)

// Internal parameters
localparam  INT_DATA_RATE             = altera_xcvr_functions::str2hz(pma_data_rate);  // TODO - may fail due to 32-bit param
localparam  INT_CDR_OUT_CLOCK_FREQ    = INT_DATA_RATE / 2;
localparam  INT_CDR_OUT_CLOCK_FREQ_STR= altera_xcvr_functions::hz2str(INT_CDR_OUT_CLOCK_FREQ);
localparam  INT_RX_PDB                = (rx_enable == 1) ? "normal_rx_on" : "power_down_rx";
localparam  INT_RXTERM_CTL            = (rx_enable == 1) ? "rxterm_en" : "rxterm_dis";

// internal wires
    // wires from sv_tx_pma_att to sv_rx_pma_att
    wire [ num_lanes-1:0 ]     lbvon;
    wire [ num_lanes-1:0 ]     lbvop;
    //  wires from sv_rx_pma_att to sv_tx_pma_att
    wire [ num_lanes-1:0 ]     rdlpbkn;
    wire [ num_lanes-1:0 ]     rdlpbkp;
    wire [ num_lanes-1:0 ]     clk270bout;
    wire [ num_lanes-1:0 ]     clk90bout;
    wire [ num_lanes-1:0 ]     devenout;
    wire [ num_lanes-1:0 ]     doddout;
    wire [ num_lanes-1:0 ]     txrlpbk;
    wire [ num_lanes-1:0 ]     slpbk_n;
// We only drive seriallpbken in duplex mode.
    assign  slpbk_n = ((rx_enable == 1) && (tx_enable == 1)) ? ~slpbk : {num_lanes{1'b1}};

generate if( rx_enable == 1 ) begin
     sv_rx_pma_att #(
        // pma_rx_att parameters
        .num_lanes  (                                              num_lanes ), 
        .rx_enable_debug_info (                         rx_enable_debug_info ),
        .rx_pdb (                                                 INT_RX_PDB ),
        .rxterm_set (                                             rxterm_set ),
        .eq0_dc_gain (                                           eq0_dc_gain ),
        .eq1_dc_gain (                                           eq1_dc_gain ),
        .eq2_dc_gain (                                           eq2_dc_gain ),
        .rx_vcm (                                                     rx_vcm ),
        .rxterm_ctl (                                         INT_RXTERM_CTL ),
        .offset_cancellation_ctrl (                 offset_cancellation_ctrl ),
        .eq_bias_adj (                                           eq_bias_adj ),
        .atb_sel (                                                   atb_sel ),
        .offset_correct (                                     offset_correct ),
        .var_bulk0 (                                               var_bulk0 ),
        .var_gate0 (                                               var_gate0 ),
        .var_bulk1 (                                               var_bulk1 ),
        .var_gate1 (                                               var_gate1 ),
        .var_bulk2 (                                               var_bulk2 ),
        .var_gate2 (                                               var_gate2 ),
        .off_filter_cap (                                     off_filter_cap ),
        .off_filter_res (                                     off_filter_res ),
        .offcomp_cmref (                                       offcomp_cmref ),
        .offcomp_igain (                                       offcomp_igain ),
        .diag_loopbk_bias (                                 diag_loopbk_bias ),
        .rload_shunt (                                           rload_shunt ),
        .rzero_shunt (                                           rzero_shunt ),
        .eqz3_pd (                                                   eqz3_pd ),
        .vcm_pdnb (                                                 vcm_pdnb ),
        .rx_diag_rev_lpbk (                                 rx_diag_rev_lpbk ),
        // pma_cdr_att parameters
        .cdr_enable_debug_info (                       cdr_enable_debug_info ),
        .reference_clock_frequency (           cdr_reference_clock_frequency ),
        .output_clock_frequency (                 INT_CDR_OUT_CLOCK_FREQ_STR ),
        .bbpd_salatch_offset_ctrl_clk0 (       bbpd_salatch_offset_ctrl_clk0 ),
        .bbpd_salatch_offset_ctrl_clk180 (   bbpd_salatch_offset_ctrl_clk180 ),
        .bbpd_salatch_offset_ctrl_clk270 (   bbpd_salatch_offset_ctrl_clk270 ),
        .bbpd_salatch_offset_ctrl_clk90 (     bbpd_salatch_offset_ctrl_clk90 ),
        .bbpd_salatch_sel (                                 bbpd_salatch_sel ),
        .bypass_cp_rgla (                                     bypass_cp_rgla ),
        .cdr_atb_select (                                     cdr_atb_select ),
        .charge_pump_current_test (                 charge_pump_current_test ),
        .clklow_fref_to_ppm_div_sel (             clklow_fref_to_ppm_div_sel ),
        .cdr_diag_rev_lpbk (                               cdr_diag_rev_lpbk ),
        .fast_lock_mode (                                     fast_lock_mode ),
        .fb_sel (                                                     fb_sel ),
        .force_vco_const (                                   force_vco_const ),
        .hs_levshift_power_supply_setting ( hs_levshift_power_supply_setting ),
        .ignore_phslock (                                     ignore_phslock ),
        .ppm_lock_sel (                                         ppm_lock_sel ),
        .ppmsel (                                                     ppmsel ),
    //    .m_counter (                                               m_counter ),
        .pd_charge_pump_current_ctrl (           pd_charge_pump_current_ctrl ),
    //    .pd_l_counter (                                         pd_l_counter ),
        .pfd_charge_pump_current_ctrl (         pfd_charge_pump_current_ctrl ),
    //    .pfd_l_counter (                                       pfd_l_counter ),
    //    .ref_clk_div (                                           ref_clk_div ),
        .regulator_volt_inc (                             regulator_volt_inc ),
        .replica_bias_ctrl (                               replica_bias_ctrl ),
        .reverse_loopback (                                 reverse_loopback ),
        .reverse_serial_lpbk (                           reverse_serial_lpbk ),
        .ripple_cap_ctrl (                                   ripple_cap_ctrl ),
    //    .rxpll_pd_bw_ctrl (                                 rxpll_pd_bw_ctrl ),
    //    .rxpll_pfd_bw_ctrl (                               rxpll_pfd_bw_ctrl ),
         // pma_deser_att parameter
        .deser_enable_debug_info (                   deser_enable_debug_info )
     ) sv_rx_pma_att_inst ( 
        .avmmaddress (             rx_avmmaddress ),
        .avmmbyteen (               rx_avmmbyteen ),
        .avmmclk (                     rx_avmmclk ),
        .avmmread (                   rx_avmmread ),
        .avmmrstn (                   rx_avmmrstn ),
        .avmmwrite (                 rx_avmmwrite ),
        .avmmwritedata (         rx_avmmwritedata ),
        .rstn (                       rx_pma_rstn ),
        // pma_rx_att's wires
        .lpbkn (                            lbvon ),
        .lpbkp (                            lbvop ),
        .ocden (                            ocden ),
        .rxnbidirin (                  rxnbidirin ),
        .rxpbidirin (                  rxpbidirin ),
        .slpbk (                          slpbk_n ),
        .rx_avmmreaddata (        rx_avmmreaddata ),
        .rx_blockselect (          rx_blockselect ),
        .rdlpbkn (                        rdlpbkn ),
        .rdlpbkp (                        rdlpbkp ),
        .atb_0_bidir_in (          atb_0_bidir_in ),
        .atb_1_bidir_in (          atb_0_bidir_in ),
        .atb_0_bidir_out (        atb_0_bidir_out ),
        .atb_1_bidir_out (        atb_0_bidir_out ),
        .atb_eye_att (                atb_eye_att ),
        // cdr_att's in/output  wires
        .crurstb (                        crurstb ),
        .ltd (                                ltd ),
        .ltr (                                ltr ),
        .ppmlock (                        ppmlock ),
        .refclk (                          refclk ),
        .discdrreset (                discdrreset ),
        .ck0pd (                            ck0pd ),
        .ck180pd (                        ck180pd ),
        .ck270pd (                        ck270pd ),
        .ck90pd (                          ck90pd ),
        .clk270bout (                  clk270bout ),
        .clk90bout (                    clk90bout ),
        .clklow (                          clklow ),
        .devenout (                      devenout ),
        .doddout (                        doddout ),
        .fref (                              fref ),
        .pdof (                              pdof ),
        .pfdmodelock (                pfdmodelock ),
        .rxplllock (                    rxplllock ),
        .txrlpbk (                        txrlpbk ),
        // pma aux
        .calclk   (                     rx_calclk ),
        // pma_deser_att's in/output  wires
        .deser_avmmreaddata (  deser_avmmreaddata ),
        .deser_blockselect (    deser_blockselect ),
        .clkdivrx (                      clkdivrx ),
        .dataout (                        dataout )
     );
end else begin
       assign rx_avmmreaddata =    { num_lanes*16{1'b0}};
       assign rx_blockselect =     { num_lanes{1'b0}};
       assign ck0pd =              { num_lanes{1'b0}};
       assign ck180pd =            { num_lanes{1'b0}};
       assign ck270pd =            { num_lanes{1'b0}};
       assign ck90pd =             { num_lanes{1'b0}};
       assign clklow =             { num_lanes{1'b0}};
       assign fref =               { num_lanes{1'b0}};
       assign pdof =               { num_lanes*4{1'b0}};
       assign pfdmodelock =        { num_lanes{1'b0}};
       assign rxplllock =          { num_lanes{1'b0}};
       assign deser_avmmreaddata = { num_lanes*16{1'b0}};
       assign deser_blockselect =  { num_lanes{1'b0}};
       assign clkdivrx =           { num_lanes{1'b0}};
       assign dataout =            { num_lanes*128{1'b0}};

       assign rdlpbkn =            { num_lanes{1'b0}};
       assign rdlpbkp =            { num_lanes{1'b0}};
       assign clk270bout =         { num_lanes{1'b0}};
       assign clk90bout =          { num_lanes{1'b0}};
       assign devenout =           { num_lanes{1'b0}};
       assign doddout =            { num_lanes{1'b0}};
       assign txrlpbk =            { num_lanes{1'b0}};

end
endgenerate
//********************** End of ATT RX PMA ****************************
//*********************************************************************

generate if( tx_enable == 1 ) begin
     sv_tx_pma_att #(
        // pma_tx_att parameters
        .num_lanes  (                                      num_lanes ),
        .tx_enable_debug_info (                 tx_enable_debug_info ),
        .tx_powerdown (                                 tx_powerdown ),
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
        .rev_ser_lb_en (                               rev_ser_lb_en ),
        .vod_ctrl_main_tap_level(            vod_ctrl_main_tap_level ),	
	    .pre_emp_ctrl_post_tap_level (   pre_emp_ctrl_post_tap_level ),
        .term_sel (                                         term_sel ),
        .high_vccehtx (                                 high_vccehtx ),
        .termination_en (                             termination_en ),
        // pma_ser_att parameters
        .ser_enable_debug_info (               ser_enable_debug_info ),
        .ser_pdb (                                           ser_pdb ),
        .ser_loopback (                                 ser_loopback )
     ) sv_tx_pma_att_inst ( 
        .avmmaddress (             tx_avmmaddress ),
        .avmmbyteen (               tx_avmmbyteen ),
        .avmmclk (                     tx_avmmclk ),
        .avmmread (                   tx_avmmread ),
        .avmmrstn (                   tx_avmmrstn ),
        .avmmwrite (                 tx_avmmwrite ),
        .avmmwritedata (         tx_avmmwritedata ),
        .rstn (                       tx_pma_rstn ),
        // pma_tx_att's wires
        .clk270bout (                  clk270bout ),
        .clk90bout (                    clk90bout ),
        .devenbout (                    1'b0 ),
        .devenout (                      devenout ),
        .doddbout (                      1'b0 ),
        .doddout (                        doddout ),
        .rtxrlpbk (                       txrlpbk ),
        .rxrlpbkn (                       rdlpbkn ),
        .rxrlpbkp (                       rdlpbkp ),
        .vonbidirin (                  vonbidirin ),
        .vopbidirin (                  vopbidirin ),
        .tx_avmmreaddata (        tx_avmmreaddata ),
        .tx_blockselect (          tx_blockselect ),
        .vonbidirout (                vonbidirout ),
        .vopbidirout (                vopbidirout ),
        // pma aux
        .calclk   (                     tx_calclk ),
        // pma_ser_att's in/output  wires
        .clk0 (                              clk0 ),
        .clk180 (                          clk180 ),
        .datain (                          datain ),
        .slpbk (                          slpbk_n ),
        .ser_avmmreaddata (      ser_avmmreaddata ),
        .ser_blockselect (        ser_blockselect ),
        .clkdivtxtop (                clkdivtxtop ),
        .lbvon (                            lbvon ),
        .lbvop (                            lbvop )
     );
end else begin
       assign tx_avmmreaddata =  { num_lanes*16{1'b0}};
       assign tx_blockselect =   { num_lanes{1'b0}};
       assign vonbidirout =      { num_lanes{1'b0}};
       assign vopbidirout =      { num_lanes{1'b0}};
       assign ser_avmmreaddata = { num_lanes*16{1'b0}};
       assign ser_blockselect =  { num_lanes{1'b0}};
       assign clkdivtxtop =      { num_lanes*16{1'b0}}; 

       assign lbvon =            { num_lanes{1'b0}};
       assign lbvop =            { num_lanes{1'b0}};
end
endgenerate
//********************** End of ATT TX PMA ****************************
//*********************************************************************


endmodule
