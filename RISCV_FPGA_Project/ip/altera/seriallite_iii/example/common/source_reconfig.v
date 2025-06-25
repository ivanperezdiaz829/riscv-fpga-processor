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


`timescale 1 ps / 1 ps

module source_reconfig #(
		parameter device_family                 = "Stratix V",
                parameter lanes                         = 2,
		parameter number_of_reconfig_interfaces = lanes*2,
		parameter enable_offset                 = 1,
		parameter enable_lc                     = 1,
		parameter enable_dcd                    = 0,
		parameter enable_dcd_power_up           = 1,
		parameter enable_analog                 = 1,
		parameter enable_eyemon                 = 0,
		parameter enable_ber                    = 0,
		parameter enable_dfe                    = 0,
		parameter enable_adce                   = 0,
		parameter enable_mif                    = 1,
		parameter enable_pll                    = 1
	) (
		output wire         reconfig_busy,             //      reconfig_busy.reconfig_busy
		input  wire         mgmt_clk_clk,              //       mgmt_clk_clk.clk
		input  wire         mgmt_rst_reset,            //     mgmt_rst_reset.reset
		input  wire [6:0]   reconfig_mgmt_address,     //      reconfig_mgmt.address
		input  wire         reconfig_mgmt_read,        //                   .read
		output wire [31:0]  reconfig_mgmt_readdata,    //                   .readdata
		output wire         reconfig_mgmt_waitrequest, //                   .waitrequest
		input  wire         reconfig_mgmt_write,       //                   .write
		input  wire [31:0]  reconfig_mgmt_writedata,   //                   .writedata
		output wire [31:0]  reconfig_mif_address,      //       reconfig_mif.address
		output wire         reconfig_mif_read,         //                   .read
		input  wire [15:0]  reconfig_mif_readdata,     //                   .readdata
		input  wire         reconfig_mif_waitrequest,  //                   .waitrequest
		output wire [139:0] reconfig_to_xcvr,          //   reconfig_to_xcvr.reconfig_to_xcvr
		input  wire [91:0]  reconfig_from_xcvr         // reconfig_from_xcvr.reconfig_from_xcvr
	);

	alt_xcvr_reconfig #(
		.device_family                 (device_family),
		.number_of_reconfig_interfaces (number_of_reconfig_interfaces),
		.enable_offset                 (enable_offset),
		.enable_lc                     (enable_lc),
		.enable_dcd                    (enable_dcd),
		.enable_dcd_power_up           (enable_dcd_power_up),
		.enable_analog                 (enable_analog),
		.enable_eyemon                 (enable_eyemon),
		.enable_ber                    (enable_ber),
		.enable_dfe                    (enable_dfe),
		.enable_adce                   (enable_adce),
		.enable_mif                    (enable_mif),
		.enable_pll                    (enable_pll)
	) reconfig_inst (
		.reconfig_busy             (reconfig_busy),             //      reconfig_busy.reconfig_busy
		.mgmt_clk_clk              (mgmt_clk_clk),              //       mgmt_clk_clk.clk
		.mgmt_rst_reset            (mgmt_rst_reset),            //     mgmt_rst_reset.reset
		.reconfig_mgmt_address     (reconfig_mgmt_address),     //      reconfig_mgmt.address
		.reconfig_mgmt_read        (reconfig_mgmt_read),        //                   .read
		.reconfig_mgmt_readdata    (reconfig_mgmt_readdata),    //                   .readdata
		.reconfig_mgmt_waitrequest (reconfig_mgmt_waitrequest), //                   .waitrequest
		.reconfig_mgmt_write       (reconfig_mgmt_write),       //                   .write
		.reconfig_mgmt_writedata   (reconfig_mgmt_writedata),   //                   .writedata
		.reconfig_mif_address      (reconfig_mif_address),      //       reconfig_mif.address
		.reconfig_mif_read         (reconfig_mif_read),         //                   .read
		.reconfig_mif_readdata     (reconfig_mif_readdata),     //                   .readdata
		.reconfig_mif_waitrequest  (reconfig_mif_waitrequest),  //                   .waitrequest
		.reconfig_to_xcvr          (reconfig_to_xcvr),          //   reconfig_to_xcvr.reconfig_to_xcvr
		.reconfig_from_xcvr        (reconfig_from_xcvr),        // reconfig_from_xcvr.reconfig_from_xcvr
		.tx_cal_busy               (),                          //        (terminated)
		.rx_cal_busy               (),                          //        (terminated)
		.cal_busy_in               (1'b0)                       //        (terminated)
	);

endmodule
