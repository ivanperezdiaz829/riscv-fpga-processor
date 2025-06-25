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


// (C) 2001-2011 Altera Corporation. All rights reserved.
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


// -------------------------------------------------------------------------
// -------------------------------------------------------------------------
//
// Revision Control Information
//
// $RCSfile: altera_tse_pcs_pma_gige_16b.v,v $
// $Source: /ipbu/cvs/sio/projects/TriSpeedEthernet/src/RTL/Top_level_modules/altera_tse_pcs_pma_gige_16b.v,v $
//
// $Revision: #8 $
// $Date: 2009/06/28 $
// Check in by : $Author: apaniand $
// Author      : Azad Affif Ishak
//
// Project     : Triple Speed Ethernet
//
// Description : 
//
// Top level PCS + PMA module for Triple Speed Ethernet PCS + PMA

// 
// ALTERA Confidential and Proprietary
// Copyright 2006 (c) Altera Corporation
// All rights reserved
//
// -------------------------------------------------------------------------
// -------------------------------------------------------------------------

//Legal Notice: (C)2007 Altera Corporation. All rights reserved.  Your
//use of Altera Corporation's design tools, logic functions and other
//software and tools, and its AMPP partner logic functions, and any
//output files any of the foregoing (including device programming or
//simulation files), and any associated documentation or information are
//expressly subject to the terms and conditions of the Altera Program
//License Subscription Agreement or other applicable license agreement,
//including, without limitation, that your use is for the sole purpose
//of programming logic devices manufactured by Altera and sold by Altera
//or its authorized distributors.  Please refer to the applicable
//agreement for further details.
 
(*altera_attribute = {"-name SYNCHRONIZER_IDENTIFICATION OFF;SUPPRESS_DA_RULE_INTERNAL=\"R102,R105,D102,D101,D103\"" } *)
module altera_tse_pcs_pma_gige_16b /* synthesis ALTERA_ATTRIBUTE = "SUPPRESS_DA_RULE_INTERNAL=\"R102,R105,D102,D101,D103\"" */(
    // inputs:
    address,
    clk,
    gmii_tx_d,
    gmii_tx_en,
    gmii_tx_err,
    gxb_cal_blk_clk,
    gxb_pwrdn_in,
    pll_powerdown,
    mii_tx_d,
    mii_tx_en,
    mii_tx_err,
    read,
    reconfig_clk,
    reconfig_togxb,
	reconfig_busy,
    ref_clk,
    reset,
    reset_rx_clk,
    reset_tx_clk,
    rxp,
    write,
    writedata,

    // outputs:
    gmii_rx_d,
    gmii_rx_dv,
    gmii_rx_err,
    hd_ena,
    led_an,
    led_char_err,
    led_col,
    led_crs,
    led_disp_err,
    led_link,
    mii_col,
    mii_crs,
    mii_rx_d,
    mii_rx_dv,
    mii_rx_err,
    pcs_pwrdn_out,
    readdata,
    reconfig_fromgxb,
    rx_clk,
    set_10,
    set_100,
    set_1000,
    tx_clk,
    rx_recovclkout,
	tx_pll_locked,
	rx_clkena,
	tx_clkena,
    txp,
    waitrequest
);


//  Parameters to configure the core for different variations
//  ---------------------------------------------------------

parameter PHY_IDENTIFIER        = 32'h 00000000; //  PHY Identifier 
parameter DEV_VERSION           = 16'h 0001 ;    //  Customer Phy's Core Version
parameter ENABLE_SGMII          = 1;             //  Enable SGMII logic for synthesis
parameter EXPORT_PWRDN          = 1'b0;          //  Option to export the Alt2gxb powerdown signal
parameter TRANSCEIVER_OPTION    = 1'b0;          //  Option to select transceiver block for MAC PCS PMA Instantiation. 
                                                 //  Valid Values are 0 and 1:  0 - GXB (GIGE Mode) 1 - LVDS I/O.
parameter STARTING_CHANNEL_NUMBER = 0;           //  Starting Channel Number for Reconfig block
parameter ENABLE_ALT_RECONFIG   = 0;             //  Option to expose the alt_reconfig ports
parameter SYNCHRONIZER_DEPTH 	= 3;	  	 //  Number of synchronizer

  output  [15:0] gmii_rx_d;
  output  [1:0] gmii_rx_dv;
  output  [1:0] gmii_rx_err;
  output  hd_ena;
  output  led_an;
  output  [1:0] led_char_err;
  output  led_col;
  output  led_crs;
  output  [1:0] led_disp_err;
  output  [1:0] led_link;
  output  mii_col;
  output  mii_crs;
  output  [3:0] mii_rx_d;
  output  mii_rx_dv;
  output  mii_rx_err;
  output  pcs_pwrdn_out;
  output  [15:0] readdata;
  output  [16:0] reconfig_fromgxb;
  output  rx_clk;
  output  set_10;
  output  set_100;
  output  set_1000;
  output  tx_clk;
  output  wire tx_pll_locked;
  output  rx_clkena;
  output  tx_clkena;
  output  txp;
  output  waitrequest;
  output  [0:0] rx_recovclkout;        
  
  input   [4:0] address;
  input   clk;
  input   [15:0] gmii_tx_d;
  input   [1:0] gmii_tx_en;
  input   [1:0] gmii_tx_err;
  input   gxb_pwrdn_in;
  input   pll_powerdown;
  input   gxb_cal_blk_clk;
  input   [3:0] mii_tx_d;
  input   mii_tx_en;
  input   mii_tx_err;
  input   read;
  input   reconfig_clk;
  input   [3:0] reconfig_togxb;
  input   reconfig_busy;
  input   ref_clk;
  input   reset;
  input   reset_rx_clk;
  input   reset_tx_clk;
  input   rxp;
  input   write;
  input   [15:0] writedata;


  wire    PCS_rx_reset, rx_reset_in;
  wire    PCS_tx_reset, tx_reset_in;
  wire    PCS_reset;
  wire    gige_pma_reset;
  wire    [15:0] gmii_rx_d;
  wire    [1:0] gmii_rx_dv;
  wire    [1:0] gmii_rx_err;
  wire    hd_ena;
  wire    led_an;
  wire    [1:0] led_char_err;
  wire    [1:0] led_char_err_gx;
  wire    led_col;
  wire    led_crs;
  wire    [1:0] led_disp_err;
  wire    [1:0] led_link;
  wire    [1:0] link_status;
  wire    mii_col;
  wire    mii_crs;
  wire    [3:0] mii_rx_d;
  wire    mii_rx_dv;
  wire    mii_rx_err;
  wire    pcs_clk;
  wire    [15:0] pcs_rx_frame;
  wire    [1:0] pcs_rx_kchar;

  wire    [15:0] readdata;
  wire    [1:0] rx_char_err_gx;
  wire    rx_clk;
  wire    [1:0] rx_disp_err;
  wire    [15:0] rx_frame;
  wire    [1:0] rx_syncstatus;
  wire    [1:0] rx_kchar;
  wire    set_10;
  wire    set_100;
  wire    set_1000;
  wire    tx_clk;
  wire    rx_clkena;
  wire    tx_clkena;
  wire    [15:0] tx_frame;
  wire    [1:0] tx_kchar;
  wire    txp;
  wire    waitrequest;
  wire    sd_loopback;
  wire    pcs_pwrdn_out_sig;
  wire    gxb_pwrdn_in_sig;

  wire   rx_runlengthviolation;
  wire   [1:0] rx_patterndetect;
  wire   [0:0] rx_recovclkout;        
  wire   [1:0] rx_runningdisp;
  wire   [1:0] rx_rmfifodatadeleted;
  wire   [1:0] rx_rmfifodatainserted;
  wire   [1:0] pcs_rx_rmfifodatadeleted;
  wire   [1:0] pcs_rx_rmfifodatainserted;
    
  reg     pma_digital_rst0;
  reg     pma_digital_rst1;
  reg     pma_digital_rst2;
  reg     pma_digital_rst3;
  reg     pma_digital_rst4;


  wire    [16:0] reconfig_fromgxb;
  wire	  rx_freqlocked;
  wire   reset_rx_pcs_clk_int;
  wire   pll_powerdown_sqcnr,tx_digitalreset_sqcnr,rx_analogreset_sqcnr,rx_digitalreset_sqcnr,gxb_powerdown_sqcnr,pll_locked;
  wire   rx_digitalreset_sqcnr_rx_clk,tx_digitalreset_sqcnr_tx_clk,rx_digitalreset_sqcnr_clk;
  wire   pcs_rx_carrierdetected,locked_signal;
  
  
// Reset logic used to reset the PMA blocks
// ----------------------------------------
//  Assign the digital reset of the PMA to the PCS logic
//  --------------------------------------------------------
altera_tse_reset_synchronizer_16b reset_sync_2 (
        .clk(rx_clk),
        .reset_in(rx_digitalreset_sqcnr),
        .reset_out(rx_digitalreset_sqcnr_rx_clk)
        );
        
altera_tse_reset_synchronizer_16b reset_sync_3 (
        .clk(tx_clk),
        .reset_in(tx_reset_in/*tx_digitalreset_sqcnr*/),
        .reset_out(tx_digitalreset_sqcnr_tx_clk)
        ); 

altera_tse_reset_synchronizer_16b reset_sync_4 (
        .clk(clk),
        .reset_in(rx_reset_in/*rx_digitalreset_sqcnr*/),
        .reset_out(rx_digitalreset_sqcnr_clk)
        );        

assign rx_reset_in = reset_rx_clk | rx_digitalreset_sqcnr;
assign tx_reset_in = reset_tx_clk | tx_digitalreset_sqcnr;

assign PCS_rx_reset = /*reset_rx_clk |*/ rx_digitalreset_sqcnr_rx_clk;
assign PCS_tx_reset = /*reset_tx_clk |*/ tx_digitalreset_sqcnr_tx_clk;
assign PCS_reset = reset;



//  Assign the character error and link status to top level leds
//  ------------------------------------------------------------
assign led_char_err = led_char_err_gx;
assign led_link = link_status;



// Instantiation of the PCS core that connects to a PMA
// --------------------------------------------------------
  altera_tse_top_1000_base_x_strx_gx_16b altera_tse_top_1000_base_x_strx_gx_16b_inst
    (
        .rx_carrierdetected(pcs_rx_carrierdetected),
        .rx_rmfifodatadeleted(pcs_rx_rmfifodatadeleted),
        .rx_rmfifodatainserted(pcs_rx_rmfifodatainserted),
        .gmii_rx_d (gmii_rx_d),
        .gmii_rx_dv (gmii_rx_dv),
        .gmii_rx_err (gmii_rx_err),
        .gmii_tx_d (gmii_tx_d),
        .gmii_tx_en (gmii_tx_en),
        .gmii_tx_err (gmii_tx_err),
        .hd_ena (hd_ena),
        .led_an (led_an),
        .led_char_err (led_char_err_gx),
        .led_col (led_col),
        .led_crs (led_crs),
        .led_link (link_status),
        .mii_col (mii_col),
        .mii_crs (mii_crs),
        .mii_rx_d (mii_rx_d),
        .mii_rx_dv (mii_rx_dv),
        .mii_rx_err (mii_rx_err),
        .mii_tx_d (mii_tx_d),
        .mii_tx_en (mii_tx_en),
        .mii_tx_err (mii_tx_err),
        .powerdown (pcs_pwrdn_out_sig),
        .reg_addr (address),
        .reg_busy (waitrequest),
        .reg_clk (clk),
        .reg_data_in (writedata),
        .reg_data_out (readdata),
        .reg_rd (read),
        .reg_wr (write),
        .reset_reg_clk (PCS_reset),
        .reset_rx_clk (PCS_rx_reset),
        .reset_tx_clk (PCS_tx_reset),
        .rx_clk (rx_clk),
        .rx_clkout (pcs_clk),
        .rx_frame (pcs_rx_frame),
        .rx_kchar (pcs_rx_kchar),
        .sd_loopback (sd_loopback),
        .set_10 (set_10),
        .set_100 (set_100),
        .set_1000 (set_1000),
        .tx_clk (tx_clk),
        .rx_clkena(rx_clkena),
        .tx_clkena(tx_clkena),
        .ref_clk(1'b0),
        .tx_clkout (pcs_clk),
        .tx_frame (tx_frame),
        .tx_kchar (tx_kchar)

    );    
    defparam
        altera_tse_top_1000_base_x_strx_gx_16b_inst.PHY_IDENTIFIER = PHY_IDENTIFIER,
        altera_tse_top_1000_base_x_strx_gx_16b_inst.DEV_VERSION = DEV_VERSION,
        altera_tse_top_1000_base_x_strx_gx_16b_inst.ENABLE_SGMII = ENABLE_SGMII;



// Export powerdown signal or wire it internally
// ---------------------------------------------
generate if (EXPORT_PWRDN == 1)
    begin          
	wire gxb_pwrdn_in_sig_ref_clk;
        assign gxb_pwrdn_in_sig = gxb_pwrdn_in;
        assign pcs_pwrdn_out = pcs_pwrdn_out_sig;
    end
else
    begin
        assign gxb_pwrdn_in_sig = pcs_pwrdn_out_sig;
	assign pcs_pwrdn_out = 1'b0;
		
    end      
endgenerate
        
// Reset logic used to reset the PMA blocks
// ----------------------------------------  
//  ALTGX Reset Sequencer
        altera_tse_reset_sequencer_16b altera_tse_reset_sequencer_inst(
            // User inputs and outputs
            .clock(clk),
            .reset_all(reset),
            //.reset_tx_digital(reset_ref_clk),
            //.reset_rx_digital(reset_ref_clk),
            .powerdown_all(),    
            .tx_ready(), // output
            .rx_ready(), // output
            // I/O transceiver and status
            .pll_powerdown(pll_powerdown_sqcnr),// output
            .tx_digitalreset(tx_digitalreset_sqcnr),// output
            .rx_analogreset(rx_analogreset_sqcnr),// output
            .rx_digitalreset(rx_digitalreset_sqcnr),// output
            .gxb_powerdown(gxb_powerdown_sqcnr),// output
            //.pll_is_locked(tx_pll_locked),
            .pll_is_locked(locked_signal),
            .rx_is_lockedtodata(rx_freqlocked),
            .manual_mode(1'b0),
            .rx_oc_busy(reconfig_busy)
        );
         defparam
            altera_tse_reset_sequencer_inst.sys_clk_in_mhz = 125;

    assign locked_signal = (reset? 1'b0: tx_pll_locked);



// Instantiation of the Alt2gxb block as the PMA for Stratix_II_GX and ArriaGX devices
// ----------------------------------------------------------------------------------- 
	altera_tse_reset_synchronizer_16b ch_0_reset_sync_0 (
        .clk(pcs_clk),
        .reset_in(rx_digitalreset_sqcnr),
        .reset_out(reset_rx_pcs_clk_int)
        );

    // Aligned Rx_sync from gxb
    // -------------------------------
    altera_tse_gxb_aligned_rxsync_16b the_altera_tse_gxb_aligned_rxsync_16b
      (
        .clk(pcs_clk),
        .reset(reset_rx_pcs_clk_int),
        //input (from alt2gxb)
        .alt_dataout(rx_frame),
        .alt_sync(rx_syncstatus),
        .alt_disperr(rx_disp_err),
        .alt_ctrldetect(rx_kchar),
        .alt_errdetect(rx_char_err_gx),
        .alt_rmfifodatadeleted(rx_rmfifodatadeleted),
        .alt_rmfifodatainserted(rx_rmfifodatainserted),
        .alt_runlengthviolation(rx_runlengthviolation),
        .alt_patterndetect(rx_patterndetect),
        .alt_runningdisp(rx_runningdisp),

        //output (to PCS)
        .altpcs_dataout(pcs_rx_frame),
        .altpcs_sync(link_status),
        .altpcs_disperr(led_disp_err),
        .altpcs_ctrldetect(pcs_rx_kchar),
        .altpcs_errdetect(led_char_err_gx),
        .altpcs_rmfifodatadeleted(pcs_rx_rmfifodatadeleted),
        .altpcs_rmfifodatainserted(pcs_rx_rmfifodatainserted),
        .altpcs_carrierdetect(pcs_rx_carrierdetected)

       ) ;



    // Altgxb in GIGE mode
    // --------------------
    altera_tse_gxb_gige_inst_16b the_altera_tse_gxb_gige_inst_16b
      (
        .cal_blk_clk (gxb_cal_blk_clk),
        .gxb_powerdown (gxb_pwrdn_in_sig),
        .pll_inclk (ref_clk),
        .pll_powerdown (pll_powerdown),
        .reconfig_clk(reconfig_clk),
        .reconfig_togxb(reconfig_togxb),
        .reconfig_fromgxb(reconfig_fromgxb),
        .rx_analogreset (rx_analogreset_sqcnr),
        .rx_cruclk (ref_clk),
        .rx_ctrldetect ({rx_kchar[0],rx_kchar[1]}),
        .rx_datain (rxp),
        .rx_dataout ({rx_frame[7:0],rx_frame[15:8]}),
        .rx_digitalreset (rx_digitalreset_sqcnr),
        .rx_disperr (rx_disp_err),
        .rx_errdetect (rx_char_err_gx),
	.rx_freqlocked (rx_freqlocked),
        .rx_patterndetect (rx_patterndetect),
        .rx_recovclkout (rx_recovclkout),
        .rx_rlv (rx_runlengthviolation),
        .rx_seriallpbken (sd_loopback),
        .rx_syncstatus (rx_syncstatus),
        .tx_clkout (pcs_clk),
	.tx_pll_locked (tx_pll_locked),
        .tx_ctrlenable ({tx_kchar[0],tx_kchar[1]}),
        .tx_datain ({tx_frame[7:0],tx_frame[15:8]}),
        .tx_dataout (txp),
        .tx_digitalreset (tx_digitalreset_sqcnr),
        .rx_rmfifodatadeleted(rx_rmfifodatadeleted),
        .rx_rmfifodatainserted(rx_rmfifodatainserted),
        .rx_runningdisp(rx_runningdisp)

      );
      defparam
          the_altera_tse_gxb_gige_inst_16b.ENABLE_ALT_RECONFIG = ENABLE_ALT_RECONFIG,
          the_altera_tse_gxb_gige_inst_16b.STARTING_CHANNEL_NUMBER = STARTING_CHANNEL_NUMBER;




endmodule

