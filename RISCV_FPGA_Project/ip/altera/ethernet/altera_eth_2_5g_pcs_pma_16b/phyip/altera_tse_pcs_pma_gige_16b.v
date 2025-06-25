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
    mii_tx_d,
    mii_tx_en,
    mii_tx_err,
    read,
    reset,
    reset_rx_clk,
    reset_tx_clk,
    write,
    writedata,
    rx_runningdisp,
    rx_disp_err,
    rx_char_err_gx,
    rx_patterndetect,
    rx_syncstatus,
    rx_rmfifodatainserted,
    rx_rmfifodatadeleted,
    rx_runlengthviolation,
    pcs_clk,
    rx_frame,
    rx_kchar,
		
    // outputs:
    tx_frame,
    tx_kchar,
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
    readdata,
    rx_clk,
    set_10,
    set_100,
    set_1000,
    tx_clk,
	rx_clkena,
	tx_clkena,
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
  output  [15:0] readdata;
  output  rx_clk;
  output  set_10;
  output  set_100;
  output  set_1000;
  output  tx_clk;
  output  rx_clkena;
  output  tx_clkena;
  output  waitrequest;
  output  [15:0] tx_frame;
  output  [1:0] tx_kchar;

  input   [4:0] address;
  input   clk;
  input   [15:0] gmii_tx_d;
  input   [1:0] gmii_tx_en;
  input   [1:0] gmii_tx_err;
  input   [3:0] mii_tx_d;
  input   mii_tx_en;
  input   mii_tx_err;
  input   read;
  input   reset;
  input   reset_rx_clk;
  input   reset_tx_clk;
  input   write;
  input   [15:0] writedata;
  input  [1:0] rx_runningdisp;
  input  [1:0] rx_disp_err;
  input  [1:0] rx_char_err_gx;
  input  [1:0] rx_patterndetect;
  input  [1:0] rx_syncstatus;
  input  [1:0] rx_rmfifodatainserted;
  input  [1:0] rx_rmfifodatadeleted;
  input  rx_runlengthviolation;
  input  pcs_clk;
  input  [15:0] rx_frame;
  input  [1:0] rx_kchar;

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
  wire    [15:0] pcs_rx_frame;
  wire    [1:0] pcs_rx_kchar;

  wire    [15:0] readdata;
  wire    rx_clk;
  wire    set_10;
  wire    set_100;
  wire    set_1000;
  wire    tx_clk;
  wire    rx_clkena;
  wire    tx_clkena;
  wire    [15:0] tx_frame;
  wire    [1:0] tx_kchar;
  wire    waitrequest;
  wire    sd_loopback;
  wire    gxb_pwrdn_in_sig;

  wire   [1:0] pcs_rx_rmfifodatadeleted;
  wire   [1:0] pcs_rx_rmfifodatainserted;
    
  reg     pma_digital_rst0;
  reg     pma_digital_rst1;
  reg     pma_digital_rst2;
  reg     pma_digital_rst3;
  reg     pma_digital_rst4;


  wire   reset_rx_pcs_clk_int;
  wire   reset_reset_rx_clk;
  wire   reset_reset_tx_clk;  
  wire   pcs_rx_carrierdetected,locked_signal;

// Reset logic used to reset the PMA blocks
// ----------------------------------------
//  Assign the digital reset of the PMA to the PCS logic
//  --------------------------------------------------------
altera_tse_reset_synchronizer_16b reset_sync_2 (
        .clk(rx_clk),
        .reset_in(reset_reset_rx_clk),
        .reset_out(PCS_rx_reset)
        );
        
altera_tse_reset_synchronizer_16b reset_sync_3 (
        .clk(tx_clk),
        .reset_in(reset_reset_tx_clk),
        .reset_out(PCS_tx_reset)
        ); 


assign reset_reset_rx_clk = reset_rx_clk | reset;
assign reset_reset_tx_clk = reset_tx_clk | reset;
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
        .powerdown (),
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
        .tx_frame ({tx_frame[7:0],tx_frame[15:8]}),
        .tx_kchar ({tx_kchar[0],tx_kchar[1]})

    );    
    defparam
        altera_tse_top_1000_base_x_strx_gx_16b_inst.PHY_IDENTIFIER = PHY_IDENTIFIER,
        altera_tse_top_1000_base_x_strx_gx_16b_inst.DEV_VERSION = DEV_VERSION,
        altera_tse_top_1000_base_x_strx_gx_16b_inst.ENABLE_SGMII = ENABLE_SGMII;


// Instantiation of Phy IP
// ----------------------------------------------------------------------------------- 
	altera_tse_reset_synchronizer_16b ch_0_reset_sync_0 (
        .clk(pcs_clk),
        .reset_in(reset),
        .reset_out(reset_rx_pcs_clk_int)
        );

    // Aligned Rx_sync from gxb
    // -------------------------------
    altera_tse_gxb_aligned_rxsync_16b the_altera_tse_gxb_aligned_rxsync_16b
      (
        .clk(pcs_clk),
        .reset(reset_rx_pcs_clk_int),
        //input (from transceiver)
        .alt_dataout({rx_frame[7:0],rx_frame[15:8]}),
        .alt_sync(rx_syncstatus),
        .alt_disperr(rx_disp_err),
        .alt_ctrldetect({rx_kchar[0],rx_kchar[1]}),
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
       //defparam
           //the_altera_tse_gxb_aligned_rxsync_16b.DEVICE_FAMILY = DEVICE_FAMILY;		


endmodule

