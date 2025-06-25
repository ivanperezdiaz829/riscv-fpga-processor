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

module altera_eth_2_5g_pcs_pma_16b (
	gmii_rx_d,
	gmii_rx_dv,
	gmii_rx_err,
	tx_clk,
	tx_pll_locked,
	rx_clk,
        rx_recovered_clk,
	readdata,
	waitrequest,
	txp,
	reconfig_fromgxb,
	led_an,
	led_disp_err,
	led_char_err,
	led_link,
	gmii_tx_d,
	gmii_tx_en,
	gmii_tx_err,
	reset_tx_clk,
	reset_rx_clk,
	address,
	read,
	writedata,
	write,
	clk,
	reset,
	rxp,
	ref_clk,
	reconfig_clk,
	reconfig_togxb,
	reconfig_busy,
        gxb_pwrdn_in,
        pll_powerdown,
	gxb_cal_blk_clk);
	parameter STARTING_CHANNEL_NUMBER=0;
	parameter DEVICE_FAMILY = "Stratix IV";

	output	[15:0]	gmii_rx_d;
	output		[1:0] gmii_rx_dv;
	output		[1:0] gmii_rx_err;
	output		tx_clk;
	output		tx_pll_locked;
	output		rx_clk;
	output		rx_recovered_clk;
	output	[31:0]	readdata;
	output		waitrequest;
	output		txp;
	output	[16:0]	reconfig_fromgxb;
	output		led_an;
	output		[1:0] led_disp_err;
	output		[1:0] led_char_err;
	output		[1:0] led_link;
	input	[15:0]	gmii_tx_d;
	input		[1:0] gmii_tx_en;
	input		[1:0] gmii_tx_err;
	input		reset_tx_clk;
	input		reset_rx_clk;
	input	[4:0]	address;
	input		read;
	input	[31:0]	writedata;
	input		write;
	input		clk;
	input		reset;
	input		rxp;
	input		ref_clk;
	input		reconfig_clk;
	input	[3:0]	reconfig_togxb;
	input       reconfig_busy;
	input       gxb_pwrdn_in;
	input       pll_powerdown;
    input		gxb_cal_blk_clk;    

    wire [15:0] readdata_from_pcs;

    
	altera_tse_pcs_pma_gige_16b	altera_tse_pcs_pma_gige_inst(
		.gmii_rx_d(gmii_rx_d),
		.gmii_rx_dv(gmii_rx_dv),
		.gmii_rx_err(gmii_rx_err),
		.tx_clk(tx_clk),
		.rx_clk(rx_clk),
                .rx_recovclkout(rx_recovered_clk),
		.tx_pll_locked(tx_pll_locked),
		.readdata(readdata_from_pcs),
		.waitrequest(waitrequest),
		.txp(txp),
		.reconfig_fromgxb(reconfig_fromgxb),
		.led_an(led_an),
		.led_disp_err(led_disp_err),
		.led_char_err(led_char_err),
		.led_link(led_link),
		.gmii_tx_d(gmii_tx_d),
		.gmii_tx_en(gmii_tx_en),
		.gmii_tx_err(gmii_tx_err),
		.reset_tx_clk(reset_tx_clk),
		.reset_rx_clk(reset_rx_clk),
		.address(address),
		.read(read),
		.writedata(writedata[15:0]),
		.write(write),
		.clk(clk),
		.reset(reset),
		.rxp(rxp),
		.ref_clk(ref_clk),
		.reconfig_clk(reconfig_clk),
		.reconfig_togxb(reconfig_togxb),
		.reconfig_busy(reconfig_busy),
        .gxb_pwrdn_in(gxb_pwrdn_in),
        .pll_powerdown(pll_powerdown),
		.gxb_cal_blk_clk(gxb_cal_blk_clk));

	defparam
		altera_tse_pcs_pma_gige_inst.PHY_IDENTIFIER = 32'h00000000,
		altera_tse_pcs_pma_gige_inst.DEV_VERSION = 16'h0901,
		altera_tse_pcs_pma_gige_inst.ENABLE_SGMII = 0,
		altera_tse_pcs_pma_gige_inst.SYNCHRONIZER_DEPTH = 4,
		altera_tse_pcs_pma_gige_inst.EXPORT_PWRDN = 1,
		altera_tse_pcs_pma_gige_inst.TRANSCEIVER_OPTION = 0,
		altera_tse_pcs_pma_gige_inst.STARTING_CHANNEL_NUMBER = STARTING_CHANNEL_NUMBER,
		altera_tse_pcs_pma_gige_inst.ENABLE_ALT_RECONFIG = 1;
        
        
    assign readdata ={16'h0000,readdata_from_pcs};    
endmodule
