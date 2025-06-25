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


//-----------------------------------------------------------------------------
//
// Description: hxaui - instantiates hard xaui and shim layer
//
// Authors:     ishimony    14-Jan-2009
//
//              Copyright (c) Altera Corporation 1997 - 2009
//              All rights reserved.
//
// //
//-----------------------------------------------------------------------------

`timescale 1 ps / 1 ps

module hxaui(
    xgmii_tx_clk, refclk, xgmii_tx_dc, xgmii_rx_clk, xgmii_rx_dc, xaui_rx_serial, 
    xaui_tx_serial, rx_analogreset, rx_digitalreset, 
    tx_digitalreset, rx_channelaligned, rx_invpolarity, rx_set_locktodata, 
    rx_set_locktoref, rx_seriallpbken, tx_invpolarity, rx_is_lockedtodata, 
    rx_phase_comp_fifo_error, rx_is_lockedtoref, rx_rlv, rx_rmfifoempty, 
    rx_rmfifofull, tx_phase_comp_fifo_error, rx_disperr, rx_errdetect, 
    rx_patterndetect, rx_rmfifodatadeleted, rx_rmfifodatainserted, rx_recovered_clk,
    rx_runningdisp, rx_syncstatus, reconfig_togxb, reconfig_fromgxb, 
    reconfig_clk, cal_blk_clk, cal_blk_powerdown, 
    gxb_powerdown, pll_powerdown, pll_locked, r_cal_blk_powerdown, 
    r_gxb_powerdown, r_pll_powerdown, r_rx_set_locktodata, r_rx_set_locktoref, 
    r_rx_seriallpbken, r_rx_analogreset, r_rx_digitalreset, r_tx_digitalreset, 
    r_rx_invpolarity, r_tx_invpolarity
); // module hxaui

// parameters --------------------------------------------------------------
parameter     starting_channel_number        = 0;
parameter     xaui_pll_type                  = "CMU";  // values: CMU/LCTANK
parameter     use_control_and_status_ports   = 1    ;
parameter     device_family		     = "Stratix IV";
parameter     external_pma_ctrl_reconf       = 1     ;

       //analog parameters
parameter     tx_termination = "OCT_100_OHMS"; //Valid values for SIV/AII - OCT_85_OHMS,OCT_100_OHMS,OCT_120_OHMS,OCT_150_OHMS
					       //Valid values for CIV     - OCT_100_OHMS,OCT_150_OHMS
parameter     rx_termination = "OCT_100_OHMS"; //Valid values for SIV/AII - OCT_85_OHMS,OCT_100_OHMS,OCT_120_OHMS,OCT_150_OHMS
					       //Valid values for CIV     - OCT_100_OHMS,OCT_150_OHMS
parameter     rx_common_mode = "0.82v";

parameter     tx_preemp_pretap = 0;//0-7
parameter     tx_preemp_pretap_inv = "FALSE";//TRUE or FALSE. 
parameter     tx_preemp_tap_1 = 5; //Valid values for SIV/AII - 0-15
				   //Valid values for CIV     - 0-31
parameter     tx_preemp_tap_2 = 0; //0-7
parameter     tx_preemp_tap_2_inv = "FALSE";//TRUE or FALSE.
parameter     tx_vod_selection = 1;//0-7

parameter     rx_eq_dc_gain = 0; //Valid values for SIV/AII - 0-4
				 //Valid values for CIV     - 0-3
parameter     rx_eq_ctrl = 14;//0-16


localparam rx_term = ((rx_termination == "OCT_85_OHMS") ? "OCT 85 OHMS" : ((rx_termination == "OCT_100_OHMS") ? "OCT 100 OHMS" : 
                     ((rx_termination == "OCT_120_OHMS") ? "OCT 120 OHMS" : ((rx_termination == "OCT_150_OHMS") ? "OCT 150 OHMS" : "NONE"))));
localparam tx_term = ((tx_termination == "OCT_85_OHMS") ? "OCT 85 OHMS" : ((tx_termination == "OCT_100_OHMS") ? "OCT 100 OHMS" : 
                     ((tx_termination == "OCT_120_OHMS") ? "OCT 120 OHMS" : ((tx_termination == "OCT_150_OHMS") ? "OCT 150 OHMS" : "NONE"))));
localparam tx_preemp_ptinv = (tx_preemp_pretap_inv == 1) ? "TRUE" : "FALSE";
localparam tx_preemp_t2inv = (tx_preemp_tap_2_inv == 1) ? "TRUE" : "FALSE";

/*Equalization settings*/
/*Deepak - Found an SPR (287703) that says there is a difference in legality check between SIV and AII. Arria II has a restricted equalization and preemphasis setting. In the case of equalization, EQA, B,C, D and V  can all be 0 or 1 whereas on TGX they can all be 0 to 7. Recheck with Brian on whether the following code is the correct way to change it*/

// Arria II GZ uses SIV EQ settings, so don't add it to this if statement
localparam rx_eqa_ctrl = (device_family=="Arria II GX") ? ((rx_eq_ctrl >10)? 1 :0) : ((rx_eq_ctrl >10)? 7 :0);
localparam rx_eqb_ctrl = (device_family=="Arria II GX") ? ((rx_eq_ctrl >6) ? 1 :0) : ((rx_eq_ctrl >6) ? 7 :0);
localparam rx_eqc_ctrl = (device_family=="Arria II GX") ? ((rx_eq_ctrl >3) ? 1 :0) : ((rx_eq_ctrl >3) ? 7 :0);
localparam rx_eqd_ctrl = (device_family=="Arria II GX") ? ((rx_eq_ctrl >0) ? 1 :0) : ((rx_eq_ctrl >0) ? 7 :0);
localparam rx_eqv_ctrl = (device_family=="Arria II GX") ? (((rx_eq_ctrl==2 | rx_eq_ctrl==5 | rx_eq_ctrl==8 | rx_eq_ctrl==13)? 1 :
						           ((rx_eq_ctrl==3 | rx_eq_ctrl==6 | rx_eq_ctrl==10 | rx_eq_ctrl==15)? 1 :
					  	           ((rx_eq_ctrl==9 | rx_eq_ctrl==14 )? 1 :
							   (rx_eq_ctrl==12)? 1 : 0)))):
							   (((rx_eq_ctrl==2 | rx_eq_ctrl==5 | rx_eq_ctrl==8 | rx_eq_ctrl==13)? 4 :
						           ((rx_eq_ctrl==3 | rx_eq_ctrl==6 | rx_eq_ctrl==10 | rx_eq_ctrl==15)? 7 :
							   ((rx_eq_ctrl==9 | rx_eq_ctrl==14 )? 5 :
						           (rx_eq_ctrl==12)? 3 : 0))));

//Deepak:Cyclone IV GX reconfig_fromgxb_width = 4. But we keep it as 16 for backward compatibility with Stratix IV
localparam    RECONFIG_FROMGXB_WIDTH         = 16; 

// ports -------------------------------------------------------------------

// xgmii
input                  xgmii_tx_clk;
input                  refclk;
input           [71:0] xgmii_tx_dc;
output                 xgmii_rx_clk;
output          [71:0] xgmii_rx_dc;

// xaui
input            [3:0] xaui_rx_serial;
output           [3:0] xaui_tx_serial;

// clock_reset
input                  rx_analogreset;
input            [3:0] rx_digitalreset; //SPR 346070
input            [3:0] tx_digitalreset; //SPR 346070

// ctrl_stat: control and status
output                 rx_channelaligned;
input            [3:0] rx_invpolarity;
input            [3:0] rx_set_locktodata;       // should be [3:0]
input            [3:0] rx_set_locktoref;        // should be [3:0]
input            [3:0] rx_seriallpbken;         // should be [3:0]
input            [3:0] tx_invpolarity;
output           [3:0] rx_is_lockedtodata;      // should be [3:0]
output           [3:0] rx_phase_comp_fifo_error;
output           [3:0] rx_is_lockedtoref;       // should be [3:0]
output           [3:0] rx_rlv;
output           [3:0] rx_rmfifoempty;
output           [3:0] rx_rmfifofull;
output           [3:0] tx_phase_comp_fifo_error;
output           [7:0] rx_disperr;
output           [7:0] rx_errdetect;
output           [7:0] rx_patterndetect;
output           [7:0] rx_rmfifodatadeleted;
output           [7:0] rx_rmfifodatainserted;
output           [7:0] rx_runningdisp;
output           [7:0] rx_syncstatus;
output           [3:0] rx_recovered_clk;

// reconfig
input            [3:0] reconfig_togxb;
output          [RECONFIG_FROMGXB_WIDTH:0] reconfig_fromgxb;		
input                  reconfig_clk;

// pma control
input                  cal_blk_clk;
input                  gxb_powerdown;
input                  cal_blk_powerdown;
input                  pll_powerdown;
output                 pll_locked;

input                  r_gxb_powerdown;
input                  r_cal_blk_powerdown;
input                  r_pll_powerdown;
input            [3:0] r_rx_set_locktodata;     // should be [3:0]
input            [3:0] r_rx_set_locktoref;      // should be [3:0]
input            [3:0] r_rx_seriallpbken;       // should be [3:0]
input            [3:0] r_rx_analogreset;        // should be width 1
input                  r_rx_digitalreset;
input                  r_tx_digitalreset;
input            [3:0] r_rx_invpolarity;
input            [3:0] r_tx_invpolarity;


`ifndef ALTERA_RESERVED_QIS
// synopsys translate_off
`endif

// ports -------------------------------------------------------------------

wire                   xgmii_tx_clk;
wire            [71:0] xgmii_tx_dc;
wire                   xgmii_rx_clk;
wire            [71:0] xgmii_rx_dc;
wire             [3:0] xaui_rx_serial;
wire             [3:0] xaui_tx_serial;
wire             [3:0] rx_cruclk;
wire                   rx_analogreset;
wire             [3:0] rx_digitalreset; //SPR 346070
wire             [3:0] tx_digitalreset; //SPR 346070
wire                   rx_channelaligned;
wire             [3:0] rx_invpolarity;
wire             [3:0] rx_set_locktodata;
wire             [3:0] rx_set_locktoref;
wire             [3:0] rx_seriallpbken;
wire             [3:0] tx_invpolarity;
wire             [3:0] rx_is_lockedtodata;
wire             [3:0] rx_phase_comp_fifo_error;
wire             [3:0] rx_is_lockedtoref;
wire             [3:0] rx_rlv;
wire             [3:0] rx_rmfifoempty;
wire             [3:0] rx_rmfifofull;
wire             [3:0] tx_phase_comp_fifo_error;
wire             [7:0] rx_disperr;
wire             [7:0] rx_errdetect;
wire             [7:0] rx_patterndetect;
wire             [7:0] rx_rmfifodatadeleted;
wire             [7:0] rx_rmfifodatainserted;
wire             [7:0] rx_runningdisp;
wire             [7:0] rx_syncstatus;
wire             [3:0] reconfig_togxb;
wire             [RECONFIG_FROMGXB_WIDTH:0] reconfig_fromgxb;
wire                   reconfig_clk;
wire                   cal_blk_clk;
wire                   cal_blk_powerdown;
wire                   gxb_powerdown;
wire                   pll_powerdown;
wire                   pll_locked;


// locals ------------------------------------------------------------------
wire             [7:0] xgmii_tx_c;
wire            [63:0] xgmii_tx_d;
wire             [7:0] xgmii_rx_c;
wire            [63:0] xgmii_rx_d;

// local version
wire                   l_cal_blk_powerdown;
wire                   l_gxb_powerdown;
wire                   l_rx_analogreset;
wire                   l_rx_digitalreset;
wire                   l_tx_digitalreset;
wire                   l_pll_powerdown;
wire             [3:0] l_rx_invpolarity;
wire             [3:0] l_rx_set_locktodata;
wire             [3:0] l_rx_set_locktoref;
wire             [3:0] l_rx_seriallpbken;
wire             [3:0] l_tx_invpolarity;

// register file version
wire                   r_gxb_powerdown;
wire                   r_cal_blk_powerdown;
wire             [3:0] r_rx_analogreset;
wire                   r_rx_digitalreset;
wire                   r_tx_digitalreset;
wire                   r_pll_powerdown;
wire             [3:0] r_rx_invpolarity;
wire             [3:0] r_rx_set_locktodata;
wire             [3:0] r_rx_set_locktoref;
wire             [3:0] r_rx_seriallpbken;
wire             [3:0] r_tx_invpolarity;


// hard xaui signals -------------------------------------------------------
wire                   coreclkout;
wire                   pll_inclk;
wire             [7:0] tx_ctrlenable;
wire            [63:0] tx_datain;
wire             [7:0] rx_ctrldetect;
wire            [63:0] rx_dataout;
wire             [3:0] rx_datain;
wire             [3:0] tx_dataout;
wire             [3:0] tx_coreclk;

// body --------------------------------------------------------------------

// Convert to/from Avalon Streaming Interface single bus to data + control
genvar         g;
generate
    for (g = 0; g < 8; g = g + 1) begin : st_to_dc_b
        assign xgmii_tx_d [g*8 +: 8] = xgmii_tx_dc[g*9 +: 8];
        assign xgmii_tx_c [g]        = xgmii_tx_dc[g*9 + 8];
        assign xgmii_rx_dc[g*9 +: 8] = xgmii_rx_d [g*8 +: 8];
        assign xgmii_rx_dc[g*9 + 8]  = xgmii_rx_c [g];
    end
endgenerate

// Default values in case ports are not and without control/status registers
generate
    if (use_control_and_status_ports == 1      & external_pma_ctrl_reconf == 0       ) begin: use_cs_ports_true
        assign l_cal_blk_powerdown = cal_blk_powerdown | r_cal_blk_powerdown;
        assign l_gxb_powerdown     = gxb_powerdown     | r_gxb_powerdown;
        assign l_pll_powerdown     = pll_powerdown     | r_pll_powerdown;
        assign l_rx_analogreset    = rx_analogreset    | r_rx_analogreset[0];
        assign l_rx_digitalreset   = |rx_digitalreset  | r_rx_digitalreset; //SPR 346070
        assign l_rx_invpolarity    = rx_invpolarity    | r_rx_invpolarity;
        assign l_rx_set_locktodata     = rx_set_locktodata[3:0] | 
                                     r_rx_set_locktodata[3:0];
        assign l_rx_set_locktoref   = rx_set_locktoref[3:0] | 
                                     r_rx_set_locktoref[3:0];
        assign l_rx_seriallpbken   = rx_seriallpbken[3:0] | 
                                          r_rx_seriallpbken[3:0];
        assign l_tx_digitalreset   = |tx_digitalreset  | r_tx_digitalreset; //SPR 346070
        assign l_tx_invpolarity    = tx_invpolarity    | r_tx_invpolarity;
    end 
    else if (external_pma_ctrl_reconf == 1      ) begin: use_extern_ctrl_true
        assign l_cal_blk_powerdown = cal_blk_powerdown | r_cal_blk_powerdown ;
        assign l_gxb_powerdown     = gxb_powerdown     | r_gxb_powerdown     ;
        assign l_pll_powerdown     = pll_powerdown     | r_pll_powerdown     ;
        assign l_rx_analogreset    = rx_analogreset    | r_rx_analogreset[0];
        assign l_rx_digitalreset   = |rx_digitalreset  | r_rx_digitalreset; //SPR 346070
        assign l_rx_invpolarity    = rx_invpolarity    | r_rx_invpolarity;
        assign l_rx_set_locktodata     = rx_set_locktodata[3:0] | 
                                     r_rx_set_locktodata[3:0];
        assign l_rx_set_locktoref   = rx_set_locktoref[3:0] | 
                                     r_rx_set_locktoref[3:0];
        assign l_rx_seriallpbken   = rx_seriallpbken[3:0] | 
                                          r_rx_seriallpbken[3:0];
        assign l_tx_digitalreset   = |tx_digitalreset  | r_tx_digitalreset; //SPR 346070
        assign l_tx_invpolarity    = tx_invpolarity    | r_tx_invpolarity;
    end 
	 else begin: use_cs_ports_false
        assign l_cal_blk_powerdown = r_cal_blk_powerdown;
        assign l_gxb_powerdown     = r_gxb_powerdown;
        assign l_pll_powerdown     = r_pll_powerdown;
        assign l_rx_analogreset    = r_rx_analogreset[0];
        assign l_rx_digitalreset   = r_rx_digitalreset | |rx_digitalreset;
        assign l_rx_invpolarity    = r_rx_invpolarity;
        assign l_rx_set_locktodata     = r_rx_set_locktodata[3:0];
        assign l_rx_set_locktoref   = r_rx_set_locktoref[3:0];
        assign l_rx_seriallpbken   = r_rx_seriallpbken[3:0];
        assign l_tx_digitalreset   = r_tx_digitalreset | |tx_digitalreset;
        assign l_tx_invpolarity    = r_tx_invpolarity;
    end
endgenerate

// hard xaui --------------------------------------------------------------

// interleave shim
assign tx_datain[ 0 +: 8] = xgmii_tx_d[ 0 +: 8];
assign tx_datain[ 8 +: 8] = xgmii_tx_d[32 +: 8];
assign tx_datain[16 +: 8] = xgmii_tx_d[ 8 +: 8];
assign tx_datain[24 +: 8] = xgmii_tx_d[40 +: 8];
assign tx_datain[32 +: 8] = xgmii_tx_d[16 +: 8];
assign tx_datain[40 +: 8] = xgmii_tx_d[48 +: 8];
assign tx_datain[48 +: 8] = xgmii_tx_d[24 +: 8];
assign tx_datain[56 +: 8] = xgmii_tx_d[56 +: 8];

assign tx_ctrlenable[0]    = xgmii_tx_c[0];
assign tx_ctrlenable[1]    = xgmii_tx_c[4];
assign tx_ctrlenable[2]    = xgmii_tx_c[1];
assign tx_ctrlenable[3]    = xgmii_tx_c[5];
assign tx_ctrlenable[4]    = xgmii_tx_c[2];
assign tx_ctrlenable[5]    = xgmii_tx_c[6];
assign tx_ctrlenable[6]    = xgmii_tx_c[3];
assign tx_ctrlenable[7]    = xgmii_tx_c[7];

assign xgmii_rx_d[ 0 +: 8] = rx_dataout[ 0 +: 8];
assign xgmii_rx_d[ 8 +: 8] = rx_dataout[16 +: 8];
assign xgmii_rx_d[16 +: 8] = rx_dataout[32 +: 8];
assign xgmii_rx_d[24 +: 8] = rx_dataout[48 +: 8];
assign xgmii_rx_d[32 +: 8] = rx_dataout[ 8 +: 8];
assign xgmii_rx_d[40 +: 8] = rx_dataout[24 +: 8];
assign xgmii_rx_d[48 +: 8] = rx_dataout[40 +: 8];
assign xgmii_rx_d[56 +: 8] = rx_dataout[56 +: 8];

assign xgmii_rx_c[0]       = rx_ctrldetect[0];
assign xgmii_rx_c[1]       = rx_ctrldetect[2];
assign xgmii_rx_c[2]       = rx_ctrldetect[4];
assign xgmii_rx_c[3]       = rx_ctrldetect[6];
assign xgmii_rx_c[4]       = rx_ctrldetect[1];
assign xgmii_rx_c[5]       = rx_ctrldetect[3];
assign xgmii_rx_c[6]       = rx_ctrldetect[5];
assign xgmii_rx_c[7]       = rx_ctrldetect[7];

// translate signal names
assign pll_inclk           = refclk;
assign xgmii_rx_clk        = coreclkout;
assign rx_datain           = xaui_rx_serial;
assign xaui_tx_serial      = tx_dataout;
assign rx_cruclk           = {4{refclk}};
assign tx_coreclk          = {4{xgmii_tx_clk}};

// hard pcs instantiation
generate
if((device_family=="Stratix IV") || (device_family=="HardCopy IV") || (device_family=="Arria II GX") || (device_family=="Arria II GZ")) begin: use_device_family_siv_sv
hxaui_alt4gxb #(
    .starting_channel_number(starting_channel_number),
    .receiver_termination(rx_term),
    .transmitter_termination(tx_term),
    .preemphasis_ctrl_pretap_setting(tx_preemp_pretap),
    .preemphasis_ctrl_pretap_inv_setting(tx_preemp_ptinv),
    .preemphasis_ctrl_1stposttap_setting(tx_preemp_tap_1),
    .preemphasis_ctrl_2ndposttap_setting(tx_preemp_tap_2),
    .preemphasis_ctrl_2ndposttap_inv_setting(tx_preemp_t2inv),
    .vod_ctrl_setting(tx_vod_selection),
    .rx_common_mode(rx_common_mode),
    .equalizer_ctrl_a_setting(rx_eqa_ctrl),
    .equalizer_ctrl_b_setting(rx_eqb_ctrl),
    .equalizer_ctrl_c_setting(rx_eqc_ctrl),
    .equalizer_ctrl_d_setting(rx_eqd_ctrl),
    .equalizer_ctrl_v_setting(rx_eqv_ctrl),
    .equalizer_dcgain_setting(rx_eq_dc_gain)
)hxaui_alt4gxb(
    .cal_blk_clk              (cal_blk_clk),               // i
    .cal_blk_powerdown        (l_cal_blk_powerdown),       // i
    .gxb_powerdown            (l_gxb_powerdown),           // i
    .pll_inclk                (pll_inclk),                 // i
    .pll_powerdown            (l_pll_powerdown),           // i
    .reconfig_clk             (reconfig_clk),              // i
    .reconfig_togxb           (reconfig_togxb),            // i
    .rx_analogreset           (l_rx_analogreset),          // i
    .rx_cruclk                (rx_cruclk),
    .rx_datain                (rx_datain),                 // i
    .rx_digitalreset          (l_rx_digitalreset),         // i
    .rx_invpolarity           (l_rx_invpolarity),          // i
    .rx_locktodata            (l_rx_set_locktodata),           // i
    .rx_locktorefclk          (l_rx_set_locktoref),         // i
    .rx_seriallpbken          (l_rx_seriallpbken),         // i
    .tx_coreclk               (tx_coreclk),                // i - user should tie this to xgmii_rx_clk at top level, if not used
    .tx_ctrlenable            (tx_ctrlenable),
    .tx_datain                (tx_datain),                 // i
    .tx_digitalreset          (l_tx_digitalreset),         // i
    .tx_invpolarity           (l_tx_invpolarity),          // i
    .coreclkout               (coreclkout),                // o
    .pll_locked               (pll_locked),                // o
    .reconfig_fromgxb         (reconfig_fromgxb),          // o
    .rx_channelaligned        (rx_channelaligned),         // o
    .rx_ctrldetect            (rx_ctrldetect),             // o
    .rx_dataout               (rx_dataout),                // o
    .rx_disperr               (rx_disperr),                // o
    .rx_errdetect             (rx_errdetect),              // o
    .rx_freqlocked            (rx_is_lockedtodata[3:0]),   // o
    .rx_patterndetect         (rx_patterndetect),          // o
    .rx_phase_comp_fifo_error (rx_phase_comp_fifo_error),  // o
    .rx_pll_locked            (rx_is_lockedtoref[3:0]),    // o
    .rx_rlv                   (rx_rlv),                    // o
    .rx_rmfifodatadeleted     (rx_rmfifodatadeleted),      // o
    .rx_rmfifodatainserted    (rx_rmfifodatainserted),     // o
    .rx_rmfifoempty           (rx_rmfifoempty),            // o
    .rx_rmfifofull            (rx_rmfifofull),             // o
    .rx_runningdisp           (rx_runningdisp),            // o
    .rx_recovered_clk         (rx_recovered_clk),          // o
    .rx_syncstatus            (rx_syncstatus),             // o
    .tx_dataout               (tx_dataout),                // o
    .tx_phase_comp_fifo_error (tx_phase_comp_fifo_error)   // o
);
defparam
    hxaui_alt4gxb.starting_channel_number = starting_channel_number;
end

if((device_family=="Cyclone IV GX")) begin: use_device_family_civ

//Deepak : from Mei Yin Tan, PN
//Cyclone IV GX:
//if you are using duplex design, both the tx and rx is sharing the same ALTPLL, so the pll_locked will determine whether the pll is locked.
//assign rx_is_lockedtoref[3:0] = {4{pll_locked}};    
assign rx_is_lockedtoref[3:0] = rx_is_lockedtodata[3:0];    


hxaui_alt_c3gxb #(
    .starting_channel_number(starting_channel_number),
    .receiver_termination(rx_term),
    .transmitter_termination(tx_term),
    .preemphasis_ctrl_1stposttap_setting(tx_preemp_tap_1),
    .vod_ctrl_setting(tx_vod_selection),
    .rx_common_mode(rx_common_mode),
    .equalizer_dcgain_setting(rx_eq_dc_gain)
)hxaui_alt_c3gxb (
    
    .cal_blk_clk              (cal_blk_clk),               // i
    .cal_blk_powerdown        (l_cal_blk_powerdown),       // i
    .gxb_powerdown            (l_gxb_powerdown),           // i
    .pll_inclk                (pll_inclk),                 // i
    .pll_powerdown            (l_pll_powerdown),           // i
    .reconfig_clk             (reconfig_clk),              // i
    .reconfig_togxb           (reconfig_togxb),            // i
    .rx_analogreset           (l_rx_analogreset),          // i
    .rx_datain                (rx_datain),                 // i
    .rx_digitalreset          (l_rx_digitalreset),         // i
    .rx_invpolarity           (l_rx_invpolarity),          // i
    .rx_locktodata            (l_rx_set_locktodata),       // i
    .rx_locktorefclk          (l_rx_set_locktoref),        // i
	
    .tx_coreclk               (tx_coreclk),                // i - user should tie this to xgmii_rx_clk at top level, if not used
    .tx_ctrlenable            (tx_ctrlenable),
    .tx_datain                (tx_datain),                 // i
    .tx_digitalreset          (l_tx_digitalreset),         // i
    .tx_invpolarity           (l_tx_invpolarity),          // i
    .coreclkout               (coreclkout),                // o
    .pll_locked               (pll_locked),                // o
    .reconfig_fromgxb         (reconfig_fromgxb[4:0]),     // o - alt3gxb uses only lower 5 bits of 17 bits from Stratix IV
    .rx_channelaligned        (rx_channelaligned),         // o
    .rx_ctrldetect            (rx_ctrldetect),             // o
    .rx_dataout               (rx_dataout),                // o
    .rx_disperr               (rx_disperr),                // o
    .rx_errdetect             (rx_errdetect),              // o
    .rx_freqlocked            (rx_is_lockedtodata[3:0]),   // o
    .rx_patterndetect         (rx_patterndetect),          // o
    .rx_phase_comp_fifo_error (rx_phase_comp_fifo_error),  // o
    .rx_rlv                   (rx_rlv),                    // o
    .rx_rmfifodatadeleted     (rx_rmfifodatadeleted),      // o
    .rx_rmfifodatainserted    (rx_rmfifodatainserted),     // o
    .rx_rmfifoempty           (rx_rmfifoempty),            // o
    .rx_rmfifofull            (rx_rmfifofull),             // o
    .rx_recovered_clk         (rx_recovered_clk),          // o
    .rx_runningdisp           (rx_runningdisp),            // o
    .rx_syncstatus            (rx_syncstatus),             // o
    .tx_dataout               (tx_dataout),                // o
    .tx_phase_comp_fifo_error (tx_phase_comp_fifo_error)   // o
);
defparam
    hxaui_alt_c3gxb.starting_channel_number = starting_channel_number;

assign reconfig_fromgxb[16:5] = 12'b0;
end
endgenerate

endmodule // alt_xaui

