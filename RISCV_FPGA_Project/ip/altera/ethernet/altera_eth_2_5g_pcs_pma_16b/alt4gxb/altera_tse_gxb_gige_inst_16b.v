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
// $RCSfile: altera_tse_gxb_gige_inst_16b.v,v $
// $Source: /ipbu/cvs/sio/projects/TriSpeedEthernet/src/RTL/Top_level_modules/altera_tse_gxb_gige_inst_16b.v,v $
//
// $Revision: #18 $
// $Date: 2009/11/05 $
// Check in by : $Author: aishak $
// Author      : Azad Affif Ishak
//
// Project     : Triple Speed Ethernet - 1000 BASE-X PCS
//
// Description : 
//
// Instantiation for Alt2gxb, Alt4gxb

// 
// ALTERA Confidential and Proprietary
// Copyright 2007 (c) Altera Corporation
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

module altera_tse_gxb_gige_inst_16b (
	cal_blk_clk,
	gxb_powerdown,
	pll_inclk,
	pll_powerdown,
	reconfig_clk,
	reconfig_togxb,	
	rx_analogreset,
	rx_cruclk,
	rx_datain,
	rx_digitalreset,
	rx_seriallpbken,
	tx_ctrlenable,
	tx_datain,
	tx_digitalreset,
	reconfig_fromgxb,
	rx_ctrldetect,
	rx_dataout,
	rx_disperr,
	rx_errdetect,
	rx_freqlocked,
	rx_patterndetect,
        rx_recovclkout,
	rx_rlv,
	rx_syncstatus,
	tx_clkout,
	tx_pll_locked,
	tx_dataout,
	rx_rmfifodatadeleted,
	rx_rmfifodatainserted,
	rx_runningdisp
);
parameter STARTING_CHANNEL_NUMBER = 0;
parameter ENABLE_ALT_RECONFIG     = 0;


	input	cal_blk_clk;
	input	gxb_powerdown;
	input	pll_inclk;
	input	pll_powerdown;
	input	reconfig_clk;
	input	[3:0]  reconfig_togxb;	
	input	rx_analogreset;
	input	rx_cruclk;
	input	rx_datain;
	input	rx_digitalreset;
	input	rx_seriallpbken;
	input	[1:0] tx_ctrlenable;
	input	[15:0]  tx_datain;
	input	tx_digitalreset;
	output	[16:0]  reconfig_fromgxb;	
	output	[1:0] rx_ctrldetect;
	output	[15:0]  rx_dataout;
	output	[1:0] rx_disperr;
	output	[1:0] rx_errdetect;
	output	rx_freqlocked;
	output	[1:0] rx_patterndetect;
	output  [0:0] rx_recovclkout;        
	output	rx_rlv;
	output	[1:0] rx_syncstatus;
	output	tx_clkout;
	output	tx_pll_locked;
	output	tx_dataout;
	output	[1:0] rx_rmfifodatadeleted;
	output	[1:0] rx_rmfifodatainserted;
	output	[1:0] rx_runningdisp;

	
	wire    [16:0] reconfig_fromgxb;
        wire    [2:0]  reconfig_togxb_alt2gxb;
        wire    reconfig_fromgxb_alt2gxb;
        wire    wire_reconfig_clk;
        wire    [3:0] wire_reconfig_togxb;
        wire    [0:0] rx_recovclkout;

        (* altera_attribute = "-name MESSAGE_DISABLE 10036" *) 
        wire    [16:0] wire_reconfig_fromgxb;


        generate if (ENABLE_ALT_RECONFIG == 0)
            begin
            
                assign wire_reconfig_clk = 1'b0;
                assign wire_reconfig_togxb = 4'b0010;
                assign reconfig_fromgxb = {17{1'b0}};        
    
            end
        else
            begin

                assign wire_reconfig_clk = reconfig_clk;
                assign wire_reconfig_togxb = reconfig_togxb;
                assign reconfig_fromgxb = wire_reconfig_fromgxb;
 
            end
        endgenerate

	
          altera_tse_alt4gxb_gige_16b the_altera_tse_alt4gxb_gige_16b
          (
            .cal_blk_clk (cal_blk_clk),
            .fixedclk(wire_reconfig_clk),
            .fixedclk_fast(6'b0),
            .gxb_powerdown (gxb_powerdown),            
            .pll_inclk (pll_inclk),
            .pll_powerdown(pll_powerdown),
            .reconfig_clk(wire_reconfig_clk),
            .reconfig_togxb(wire_reconfig_togxb),
            .reconfig_fromgxb(wire_reconfig_fromgxb),       
            .rx_analogreset (rx_analogreset),
            .rx_cruclk (rx_cruclk),
            .rx_ctrldetect (rx_ctrldetect),
            .rx_datain (rx_datain),
            .rx_dataout (rx_dataout),
            .rx_digitalreset (rx_digitalreset),
            .rx_disperr (rx_disperr),
            .rx_errdetect (rx_errdetect),
            .rx_freqlocked (rx_freqlocked),
            .rx_patterndetect (rx_patterndetect),
            .rx_recovclkout (rx_recovclkout),
            .rx_rlv (rx_rlv),
            .rx_seriallpbken (rx_seriallpbken),
            .rx_syncstatus (rx_syncstatus),
            .tx_clkout (tx_clkout),
            .tx_ctrlenable (tx_ctrlenable),
            .tx_datain (tx_datain),
            .tx_dataout (tx_dataout),
            .tx_digitalreset (tx_digitalreset),
			.pll_locked (tx_pll_locked),
            .rx_rmfifodatadeleted(rx_rmfifodatadeleted),
            .rx_rmfifodatainserted(rx_rmfifodatainserted),
            .rx_runningdisp(rx_runningdisp)
          );
          defparam
              the_altera_tse_alt4gxb_gige_16b.starting_channel_number = STARTING_CHANNEL_NUMBER;              
	
		
endmodule
