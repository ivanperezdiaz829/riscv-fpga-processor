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
	phy_mgmt_clk,
	phy_mgmt_clk_reset,
	phy_mgmt_csr_address,
	phy_mgmt_csr_read,
	phy_mgmt_csr_readdata,
	phy_mgmt_csr_waitrequest,
	phy_mgmt_csr_write,
	phy_mgmt_csr_writedata,
	tx_ready,
	rx_ready,
	rx_clkout,

	gmii_rx_d,
	gmii_rx_dv,
	gmii_rx_err,
	tx_clk,
	rx_clk,
	readdata,
	waitrequest,
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
	rx_runningdisp,
	rx_disperr,
	rx_errdetect,
	rx_patterndetect,
	rx_syncstatus,
	rx_rmfifodatainserted,
	rx_rmfifodatadeleted,
	rx_rlv,
	tx_clkout,
	rx_parallel_data,
	rx_datak,
	tx_parallel_data,
	tx_datak,		
	clk,
	reset
	);
	parameter STARTING_CHANNEL_NUMBER=0;
	parameter DEVICE_FAMILY="Arria V";

	output phy_mgmt_clk;
	output phy_mgmt_clk_reset;
	output [8:0]phy_mgmt_csr_address;
	output phy_mgmt_csr_read;
	input [31:0]phy_mgmt_csr_readdata;
	input phy_mgmt_csr_waitrequest;
	output phy_mgmt_csr_write;
	output [31:0]phy_mgmt_csr_writedata;
	input tx_ready;
	input rx_ready;
	input rx_clkout;

	output	[15:0]	gmii_rx_d;
	output		[1:0] gmii_rx_dv;
	output		[1:0] gmii_rx_err;
	output		tx_clk;
	output		rx_clk;
	output	[31:0]	readdata;
	output		waitrequest;
	output		led_an;
	output		[1:0] led_disp_err;
	output		[1:0] led_char_err;
	output		[1:0] led_link;
	output  [15:0] tx_parallel_data;
	output  [1:0] tx_datak;
	
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
	input  [1:0] rx_runningdisp;
	input  [1:0] rx_disperr;
	input  [1:0] rx_errdetect;
	input  [1:0] rx_patterndetect;
	input  [1:0] rx_syncstatus;
	input  [1:0] rx_rmfifodatainserted;
	input  [1:0] rx_rmfifodatadeleted;
	input  rx_rlv;
	input  tx_clkout;
	input  [15:0] rx_parallel_data;
	input  [1:0] rx_datak;


    wire [15:0] readdata_from_pcs;

    
	altera_tse_pcs_pma_gige_16b	altera_tse_pcs_pma_gige_inst(
		.gmii_rx_d(gmii_rx_d),
		.gmii_rx_dv(gmii_rx_dv),
		.gmii_rx_err(gmii_rx_err),
		.tx_clk(tx_clk),
		.rx_clk(rx_clk),
		.readdata(readdata_from_pcs),
		.waitrequest(waitrequest),
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
    	.rx_runningdisp(rx_runningdisp),
    	.rx_disp_err(rx_disperr),
    	.rx_char_err_gx(rx_errdetect),
    	.rx_patterndetect(rx_patterndetect),
    	.rx_syncstatus(rx_syncstatus),
    	.rx_rmfifodatainserted(rx_rmfifodatainserted),
    	.rx_rmfifodatadeleted(rx_rmfifodatadeleted),
    	.rx_runlengthviolation(rx_rlv),
    	.pcs_clk(tx_clkout),
    	.rx_frame(rx_parallel_data),
    	.rx_kchar(rx_datak),
    	.tx_frame(tx_parallel_data),
    	.tx_kchar(tx_datak),		
		.clk(clk),
		.reset(reset)
		);

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
    assign phy_mgmt_clk = clk;
	assign phy_mgmt_clk_reset = reset;
	assign phy_mgmt_csr_address = 'b0;
	assign phy_mgmt_csr_read = 'b0;
	assign phy_mgmt_csr_write = 'b0;
	assign phy_mgmt_csr_writedata = 'b0;

endmodule
