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


// megafunction wizard: %Transceiver PHY Reset Controller v12.1%
// GENERATION: XML
// rst_controller_tx.v

// Generated using ACDS version 12.1 7 at 2012.02.22.16:20:28

`timescale 1 ps / 1 ps
module rst_controller_tx (
		input  wire       clock,           //           clock.clk
		input  wire       reset,           //           reset.reset
		output wire [0:0] pll_powerdown,   //   pll_powerdown.pll_powerdown
		output wire [0:0] tx_analogreset,  //  tx_analogreset.tx_analogreset
		output wire [0:0] tx_digitalreset, // tx_digitalreset.tx_digitalreset
		output wire [0:0] tx_ready,        //        tx_ready.tx_ready
		input  wire [0:0] pll_locked,      //      pll_locked.pll_locked
		input  wire [0:0] pll_select,      //      pll_select.pll_select
		input  wire [0:0] tx_cal_busy      //     tx_cal_busy.tx_cal_busy
	);

	altera_xcvr_reset_control #(
		.CHANNELS              (1),
		.PLLS                  (1),
		.SYS_CLK_IN_MHZ        (250),
		.SYNCHRONIZE_RESET     (1),
		.REDUCED_SIM_TIME      (1),
		.TX_PLL_ENABLE         (1),
		.T_PLL_POWERDOWN       (1000),
		.SYNCHRONIZE_PLL_RESET (0),
		.TX_ENABLE             (1),
		.TX_PER_CHANNEL        (0),
		.T_TX_DIGITALRESET     (20),
		.T_PLL_LOCK_HYST       (0),
		.RX_ENABLE             (0),
		.RX_PER_CHANNEL        (0),
		.T_RX_ANALOGRESET      (40),
		.T_RX_DIGITALRESET     (4000)
	) rst_controller_tx_inst (
		.clock              (clock),           //           clock.clk
		.reset              (reset),           //           reset.reset
		.pll_powerdown      (pll_powerdown),   //   pll_powerdown.pll_powerdown
		.tx_analogreset     (tx_analogreset),  //  tx_analogreset.tx_analogreset
		.tx_digitalreset    (tx_digitalreset), // tx_digitalreset.tx_digitalreset
		.tx_ready           (tx_ready),        //        tx_ready.tx_ready
		.pll_locked         (pll_locked),      //      pll_locked.pll_locked
		.pll_select         (pll_select),      //      pll_select.pll_select
		.tx_cal_busy        (tx_cal_busy),     //     tx_cal_busy.tx_cal_busy
		.tx_manual          (1'b1),            //     (terminated)
		.rx_analogreset     (),                //     (terminated)
		.rx_digitalreset    (),                //     (terminated)
		.rx_ready           (),                //     (terminated)
		.rx_is_lockedtodata (1'b0),            //     (terminated)
		.rx_cal_busy        (1'b0),            //     (terminated)
		.rx_manual          (1'b0),            //     (terminated)
		.tx_digitalreset_or (1'b0),            //     (terminated)
		.rx_digitalreset_or (1'b0)             //     (terminated)
	);

endmodule
// Retrieval info: <?xml version="1.0"?>
//<!--
//	Generated by Altera MegaWizard Launcher Utility version 1.0
//	************************************************************
//	THIS IS A WIZARD-GENERATED FILE. DO NOT EDIT THIS FILE!
//	************************************************************
//	Copyright (C) 1991-2012 Altera Corporation
//	Any megafunction design, and related net list (encrypted or decrypted),
//	support information, device programming or simulation file, and any other
//	associated documentation or information provided by Altera or a partner
//	under Altera's Megafunction Partnership Program may be used only to
//	program PLD devices (but not masked PLD devices) from Altera.  Any other
//	use of such megafunction design, net list, support information, device
//	programming or simulation file, or any other related documentation or
//	information is prohibited for any other purpose, including, but not
//	limited to modification, reverse engineering, de-compiling, or use with
//	any other silicon devices, unless such use is explicitly licensed under
//	a separate agreement with Altera or a megafunction partner.  Title to
//	the intellectual property, including patents, copyrights, trademarks,
//	trade secrets, or maskworks, embodied in any such megafunction design,
//	net list, support information, device programming or simulation file, or
//	any other related documentation or information provided by Altera or a
//	megafunction partner, remains with Altera, the megafunction partner, or
//	their respective licensors.  No other licenses, including any licenses
//	needed under any third party's intellectual property, are provided herein.
//-->
// Retrieval info: <instance entity-name="altera_xcvr_reset_control" version="12.1" >
// Retrieval info: 	<generic name="CHANNELS" value="1" />
// Retrieval info: 	<generic name="PLLS" value="1" />
// Retrieval info: 	<generic name="SYS_CLK_IN_MHZ" value="250" />
// Retrieval info: 	<generic name="SYNCHRONIZE_RESET" value="1" />
// Retrieval info: 	<generic name="REDUCED_SIM_TIME" value="1" />
// Retrieval info: 	<generic name="gui_split_interfaces" value="0" />
// Retrieval info: 	<generic name="TX_PLL_ENABLE" value="1" />
// Retrieval info: 	<generic name="T_PLL_POWERDOWN" value="1000" />
// Retrieval info: 	<generic name="SYNCHRONIZE_PLL_RESET" value="0" />
// Retrieval info: 	<generic name="TX_ENABLE" value="1" />
// Retrieval info: 	<generic name="TX_PER_CHANNEL" value="0" />
// Retrieval info: 	<generic name="gui_tx_auto_reset" value="1" />
// Retrieval info: 	<generic name="T_TX_DIGITALRESET" value="20" />
// Retrieval info: 	<generic name="T_PLL_LOCK_HYST" value="0" />
// Retrieval info: 	<generic name="RX_ENABLE" value="0" />
// Retrieval info: 	<generic name="RX_PER_CHANNEL" value="0" />
// Retrieval info: 	<generic name="gui_rx_auto_reset" value="0" />
// Retrieval info: 	<generic name="T_RX_ANALOGRESET" value="40" />
// Retrieval info: 	<generic name="T_RX_DIGITALRESET" value="4000" />
// Retrieval info: 	<generic name="AUTO_CLOCK_CLOCK_RATE" value="-1" />
// Retrieval info: </instance>
// IPFS_FILES : rst_controller_tx.vo
// RELATED_FILES: rst_controller_tx.v, altera_xcvr_functions.sv, alt_xcvr_resync.sv, altera_xcvr_reset_control.sv, alt_xcvr_reset_counter.sv
