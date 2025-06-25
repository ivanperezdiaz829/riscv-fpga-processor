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


// Copyright 2010 Altera Corporation. All rights reserved.  
// Altera products are protected under numerous U.S. and foreign patents, 
// maskwork rights, copyrights and other intellectual property laws.  
//
// This reference design file, and your use thereof, is subject to and governed
// by the terms and conditions of the applicable Altera Reference Design 
// License Agreement (either as signed by you or found at www.altera.com).  By
// using this reference design file, you indicate your acceptance of such terms
// and conditions between you and Altera Corporation.  In the event that you do
// not agree with such terms and conditions, you may not use the reference 
// design file and please promptly destroy any copies you have made.
//
// This reference design file is being provided on an "as-is" basis and as an 
// accommodation and therefore all warranties, representations or guarantees of 
// any kind (whether express, implied or statutory) including, without 
// limitation, warranties of merchantability, non-infringement, or fitness for
// a particular purpose, are specifically disclaimed.  By making this reference
// design file available, Altera expressly does not recommend, suggest or 
// require that this reference design file be used in combination with any 
// other product not provided by Altera.
/////////////////////////////////////////////////////////////////////////////

`timescale 1 ps / 1 ps
// baeckler - 12-17-2009
// lanny    - 11-11-2011: reorganize, add parameter
//
module alt_e100_phy_pma_sv #(
    parameter VARIANT = 3,                    // 1=>RX, 2=>TX, 3=> RX_AND_TX
	parameter en_synce_support = 0
)(
		input  wire          status_read,         //         status_read.export
		input  wire          status_write,        //        status_write.export
		input  wire [15:0]   status_addr,         //         status_addr.export
		input  wire [31:0]   status_writedata,    //    status_writedata.export
		output wire          reco_readdata_valid, // reco_readdata_valid.export
		output wire          phy_readdata_valid,  //  phy_readdata_valid.export
		output wire          clk_rx,              //              clk_rx.clk
		output wire          clk_tx,              //              clk_tx.clk
		input  wire          clk_ref,             //             clk_ref.clk
		input  wire          rx_clk_ref,
		input  wire          tx_clk_ref,
		input  wire [1:0]    err_inject,          //          err_inject.export
		output wire [2:0]    tx_pll_lock,         //         tx_pll_lock.export
		output wire [9:0]    rx_cdr_lock,         //         rx_cdr_lock.export
		input  wire          pma_arst,            //            pma_arst.reset
		input  wire          clk_status,          //          clk_status.clk
		output wire [31:0]   phy_readdata,        //        phy_readdata.export
		output wire          rx_ready,            //            rx_ready.export
		output wire          tx_ready,            //            tx_ready.export
		output wire [31:0]   reco_readdata,       //       reco_readdata.export
		output wire          busy,                //                busy.export
		input  wire [9:0]    rx_datain,           //           rx_datain.export
		output wire [399:0]  rx_dataout,          //          rx_dataout.export
		output wire [9:0]    tx_dataout,          //          tx_dataout.export
		input  wire [399:0]  tx_datain,           //           tx_datain.export
		output wire [919:0]  reconfig_from_xcvr,  //  reconfig_from_xcvr.reconfig_from_xcvr
		input  wire [1399:0] reconfig_to_xcvr     //    reconfig_to_xcvr.reconfig_to_xcvr
);

	wire          gx_rx_ready_export;                 // gx:rx_ready -> pma_bridge:rx_ready
	wire    [9:0] pma_bridge_rx_serial_data_export;   // pma_bridge:rx_serial_data -> gx:rx_serial_data
	wire  [399:0] gx_rx_parallel_data_export;         // gx:rx_parallel_data -> pma_bridge:rx_parallel_data
	wire    [9:0] gx_rx_is_lockedtoref_export;        // gx:rx_is_lockedtoref -> pma_bridge:rx_freqlocked
	wire    [9:0] gx_rx_is_lockedtodata_export;       // gx:rx_is_lockedtodata -> pma_bridge:rx_is_lockedtodata
	wire    [9:0] pma_bridge_rx_coreclk_export;       // pma_bridge:rx_coreclk -> gx:rx_coreclkin
	wire    [9:0] gx_rx_clkout_export;                // gx:rx_clkout -> pma_bridge:rx_clkout
	wire          gx_tx_ready_export;                 // gx:tx_ready -> pma_bridge:tx_ready
	wire    [9:0] gx_tx_serial_data_export;           // gx:tx_serial_data -> pma_bridge:tx_serial_data
	wire    [0:0] gx_pll_locked_export;               // gx:pll_locked -> pma_bridge:pll_locked
	wire    [9:0] pma_bridge_tx_coreclk_export;       // pma_bridge:tx_coreclk -> gx:tx_coreclkin
	wire    [9:0] gx_tx_clkout_export;                // gx:tx_clkout -> pma_bridge:tx_clkout
	wire  [399:0] pma_bridge_tx_parallel_data_export; // pma_bridge:tx_parallel_data -> gx:tx_parallel_data
	wire          pma_bridge_pll_inclk_clk;           // pma_bridge:pll_inclk -> gx:pll_ref_clk
	wire          pma_bridge_clk_status_gx_clk;       // pma_bridge:clk_status_gx -> gx:phy_mgmt_clk
	wire          pma_bridge_pma_arst_gx_reset;       // pma_bridge:pma_arst_gx -> gx:phy_mgmt_clk_reset
	wire          pma_bridge_phy_mgmt_waitrequest;    // gx:phy_mgmt_waitrequest -> pma_bridge:phy_mgmt_waitrequest
	wire   [31:0] pma_bridge_phy_mgmt_writedata;      // pma_bridge:phy_mgmt_writedata -> gx:phy_mgmt_writedata
	wire    [8:0] pma_bridge_phy_mgmt_address;        // pma_bridge:phy_mgmt_address -> gx:phy_mgmt_address
	wire          pma_bridge_phy_mgmt_write;          // pma_bridge:phy_mgmt_write -> gx:phy_mgmt_write
	wire          pma_bridge_phy_mgmt_read;           // pma_bridge:phy_mgmt_read -> gx:phy_mgmt_read
	wire   [31:0] pma_bridge_phy_mgmt_readdata;       // gx:phy_mgmt_readdata -> pma_bridge:phy_mgmt_readdata
    wire          cdr_ref_clk;
		
		
generate

	if (VARIANT == 3) begin : BLD_PMA_SV_FULLDUP
		alt_e100_pma_sv_bridge #(
			.FAKE_TX_SKEW (0),
			.VARIANT      (VARIANT),
			.en_synce_support(en_synce_support)
		) pma_bridge (
			.pma_arst                  (pma_arst),                             //            pma_arst.reset
			.clk_status                (clk_status),                           //          clk_status.clk
			.clk_ref                   (clk_ref),                              //             clk_ref.clk
			.rx_clk_ref                (rx_clk_ref),
			.tx_clk_ref                (tx_clk_ref),
			.tx_pll_lock               (tx_pll_lock),                          //         tx_pll_lock.export
			.rx_cdr_lock               (rx_cdr_lock),                          //         rx_cdr_lock.export
			.clk_tx                    (clk_tx),                               //              clk_tx.clk
			.err_inject                (err_inject),                           //          err_inject.export
			.clk_rx                    (clk_rx),                               //              clk_rx.clk
			.status_read               (status_read),                          //         status_read.export
			.status_write              (status_write),                         //        status_write.export
			.status_addr               (status_addr),                          //         status_addr.export
			.status_writedata          (status_writedata),                     //    status_writedata.export
			.reco_readdata_valid       (reco_readdata_valid),                  // reco_readdata_valid.export
			.phy_readdata_valid        (phy_readdata_valid),                   //  phy_readdata_valid.export
			.clk_status_gx             (pma_bridge_clk_status_gx_clk),         //       clk_status_gx.clk
			.pma_arst_gx               (pma_bridge_pma_arst_gx_reset),         //         pma_arst_gx.reset
			.phy_readdata              (phy_readdata),                         //        phy_readdata.export
			.phy_mgmt_address          (pma_bridge_phy_mgmt_address),          //            phy_mgmt.address
			.phy_mgmt_read             (pma_bridge_phy_mgmt_read),             //                    .read
			.phy_mgmt_readdata         (pma_bridge_phy_mgmt_readdata),         //                    .readdata
			.phy_mgmt_waitrequest      (pma_bridge_phy_mgmt_waitrequest),      //                    .waitrequest
			.phy_mgmt_write            (pma_bridge_phy_mgmt_write),            //                    .write
			.phy_mgmt_writedata        (pma_bridge_phy_mgmt_writedata),        //                    .writedata
			.pll_inclk                 (pma_bridge_pll_inclk_clk),             //           pll_inclk.clk
			.cdr_ref_clk               (cdr_ref_clk),
			.rx_freqlocked             (gx_rx_is_lockedtoref_export),          //       rx_freqlocked.export
			.rx_is_lockedtodata        (gx_rx_is_lockedtodata_export),         //  rx_is_lockedtodata.export
			.rx_coreclk                (pma_bridge_rx_coreclk_export),         //          rx_coreclk.export
			.rx_clkout                 (gx_rx_clkout_export),                  //           rx_clkout.export
			.pll_locked                (gx_pll_locked_export),                 //          pll_locked.export
			.tx_coreclk                (pma_bridge_tx_coreclk_export),         //          tx_coreclk.export
			.tx_clkout                 (gx_tx_clkout_export),                  //           tx_clkout.export
			.tx_datain                 (tx_datain),                            //           tx_datain.export
			.rx_dataout                (rx_dataout),                           //          rx_dataout.export
			.rx_datain                 (rx_datain),                            //           rx_datain.export
			.tx_dataout                (tx_dataout),                           //          tx_dataout.export
			.out_tx_ready              (tx_ready),                             //        out_tx_ready.export
			.out_rx_ready              (rx_ready),                             //        out_rx_ready.export
			.tx_parallel_data          (pma_bridge_tx_parallel_data_export),   //    tx_parallel_data.export
			.rx_parallel_data          (gx_rx_parallel_data_export),           //    rx_parallel_data.export
			.rx_serial_data            (pma_bridge_rx_serial_data_export),     //      rx_serial_data.export
			.tx_serial_data            (gx_tx_serial_data_export),             //      tx_serial_data.export
			.tx_ready                  (gx_tx_ready_export),                   //            tx_ready.export
			.rx_ready                  (gx_rx_ready_export),                   //            rx_ready.export
			.reco_readdata             (reco_readdata),                        //       reco_readdata.export
			.out_busy                  (busy),                                 //            out_busy.export
			.reconfig_busy             (1'b0),                                 //         (terminated)
			.clk_status_reco           (),                                     //         (terminated)
			.pma_arst_reco             (),                                     //         (terminated)
			.reconfig_mgmt_address     (),                                     //         (terminated)
			.reconfig_mgmt_read        (),                                     //         (terminated)
			.reconfig_mgmt_readdata    (32'b00000000000000000000000000000000), //         (terminated)
			.reconfig_mgmt_waitrequest (1'b0),                                 //         (terminated)
			.reconfig_mgmt_write       (),                                     //         (terminated)
			.reconfig_mgmt_writedata   ()                                      //         (terminated)
		);
		
	alt_e100_e10x10 sv_pma_full (
		.phy_mgmt_clk(pma_bridge_clk_status_gx_clk),         //       phy_mgmt_clk.clk
		.phy_mgmt_clk_reset(pma_bridge_pma_arst_gx_reset),   // phy_mgmt_clk_reset.reset
		.phy_mgmt_address(pma_bridge_phy_mgmt_address),     //           phy_mgmt.address
		.phy_mgmt_read(pma_bridge_phy_mgmt_read),        //                   .read
		.phy_mgmt_readdata(pma_bridge_phy_mgmt_readdata),    //                   .readdata
		.phy_mgmt_waitrequest(pma_bridge_phy_mgmt_waitrequest), //                   .waitrequest
		.phy_mgmt_write(pma_bridge_phy_mgmt_write),       //                   .write
		.phy_mgmt_writedata(pma_bridge_phy_mgmt_writedata),   //                   .writedata
		.tx_ready(gx_tx_ready_export),             //           tx_ready.export
		.rx_ready(gx_rx_ready_export),             //           rx_ready.export
		.pll_ref_clk(pma_bridge_pll_inclk_clk),          //        pll_ref_clk.clk
		.pll_locked(gx_pll_locked_export),           //         pll_locked.export
		.tx_serial_data(gx_tx_serial_data_export),       //     tx_serial_data.export
		.rx_serial_data(pma_bridge_rx_serial_data_export),       //     rx_serial_data.export
		.rx_is_lockedtoref(gx_rx_is_lockedtoref_export),    //  rx_is_lockedtoref.export
		.rx_is_lockedtodata(gx_rx_is_lockedtodata_export),   // rx_is_lockedtodata.export
		.tx_coreclkin(pma_bridge_tx_coreclk_export),         //       tx_coreclkin.export
		.rx_coreclkin(pma_bridge_rx_coreclk_export),         //       rx_coreclkin.export
		.tx_clkout(gx_tx_clkout_export),            //          tx_clkout.export
		.rx_clkout(gx_rx_clkout_export),            //          rx_clkout.export
		.cdr_ref_clk(cdr_ref_clk),          //        cdr_ref_clk.export
		.tx_parallel_data(pma_bridge_tx_parallel_data_export),     //   tx_parallel_data.export
		.rx_parallel_data(gx_rx_parallel_data_export),     //   rx_parallel_data.export
		.reconfig_from_xcvr(reconfig_from_xcvr),   // reconfig_from_xcvr.reconfig_from_xcvr
		.reconfig_to_xcvr(reconfig_to_xcvr)      //   reconfig_to_xcvr.reconfig_to_xcvr
	);	
	
	end
	else if (VARIANT == 1) begin  : BLD_PMA_SV_RXDUP
		alt_e100_pma_sv_bridge #(
			.FAKE_TX_SKEW (0),
			.VARIANT      (VARIANT),
			.en_synce_support(0)
		) pma_bridge (
			.pma_arst                  (pma_arst),                                                                                                                                                                                                                                                                                                                                                                                                              //            pma_arst.reset
			.clk_status                (clk_status),                                                                                                                                                                                                                                                                                                                                                                                                            //          clk_status.clk
			.clk_ref                   (clk_ref),                                                                                                                                                                                                                                                                                                                                                                                                               //             clk_ref.clk
			.tx_pll_lock               (tx_pll_lock),                                                                                                                                                                                                                                                                                                                                                                                                           //         tx_pll_lock.export
			.rx_cdr_lock               (rx_cdr_lock),                                                                                                                                                                                                                                                                                                                                                                                                           //         rx_cdr_lock.export
			.clk_tx                    (clk_tx),                                                                                                                                                                                                                                                                                                                                                                                                                //              clk_tx.clk
			.err_inject                (err_inject),                                                                                                                                                                                                                                                                                                                                                                                                            //          err_inject.export
			.clk_rx                    (clk_rx),                                                                                                                                                                                                                                                                                                                                                                                                                //              clk_rx.clk
			.status_read               (status_read),                                                                                                                                                                                                                                                                                                                                                                                                           //         status_read.export
			.status_write              (status_write),                                                                                                                                                                                                                                                                                                                                                                                                          //        status_write.export
			.status_addr               (status_addr),                                                                                                                                                                                                                                                                                                                                                                                                           //         status_addr.export
			.status_writedata          (status_writedata),                                                                                                                                                                                                                                                                                                                                                                                                      //    status_writedata.export
			.reco_readdata_valid       (reco_readdata_valid),                                                                                                                                                                                                                                                                                                                                                                                                   // reco_readdata_valid.export
			.phy_readdata_valid        (phy_readdata_valid),                                                                                                                                                                                                                                                                                                                                                                                                    //  phy_readdata_valid.export
			.clk_status_gx             (pma_bridge_clk_status_gx_clk),                                                                                                                                                                                                                                                                                                                                                                                          //       clk_status_gx.clk
			.pma_arst_gx               (pma_bridge_pma_arst_gx_reset),                                                                                                                                                                                                                                                                                                                                                                                          //         pma_arst_gx.reset
			.phy_readdata              (phy_readdata),                                                                                                                                                                                                                                                                                                                                                                                                          //        phy_readdata.export
			.phy_mgmt_address          (pma_bridge_phy_mgmt_address),                                                                                                                                                                                                                                                                                                                                                                                           //            phy_mgmt.address
			.phy_mgmt_read             (pma_bridge_phy_mgmt_read),                                                                                                                                                                                                                                                                                                                                                                                              //                    .read
			.phy_mgmt_readdata         (pma_bridge_phy_mgmt_readdata),                                                                                                                                                                                                                                                                                                                                                                                          //                    .readdata
			.phy_mgmt_waitrequest      (pma_bridge_phy_mgmt_waitrequest),                                                                                                                                                                                                                                                                                                                                                                                       //                    .waitrequest
			.phy_mgmt_write            (pma_bridge_phy_mgmt_write),                                                                                                                                                                                                                                                                                                                                                                                             //                    .write
			.phy_mgmt_writedata        (pma_bridge_phy_mgmt_writedata),                                                                                                                                                                                                                                                                                                                                                                                         //                    .writedata
			.pll_inclk                 (pma_bridge_pll_inclk_clk),                                                                                                                                                                                                                                                                                                                                                                                              //           pll_inclk.clk
			.cdr_ref_clk               (cdr_ref_clk),
			.rx_freqlocked             (gx_rx_is_lockedtoref_export),                                                                                                                                                                                                                                                                                                                                                                                           //       rx_freqlocked.export
			.rx_is_lockedtodata        (gx_rx_is_lockedtodata_export),                                                                                                                                                                                                                                                                                                                                                                                          //  rx_is_lockedtodata.export
			.rx_coreclk                (pma_bridge_rx_coreclk_export),                                                                                                                                                                                                                                                                                                                                                                                          //          rx_coreclk.export
			.rx_clkout                 (gx_rx_clkout_export),                                                                                                                                                                                                                                                                                                                                                                                                   //           rx_clkout.export
			.rx_dataout                (rx_dataout),                                                                                                                                                                                                                                                                                                                                                                                                            //          rx_dataout.export
			.rx_datain                 (rx_datain),                                                                                                                                                                                                                                                                                                                                                                                                             //           rx_datain.export
			.out_tx_ready              (tx_ready),                                                                                                                                                                                                                                                                                                                                                                                                              //        out_tx_ready.export
			.out_rx_ready              (rx_ready),                                                                                                                                                                                                                                                                                                                                                                                                              //        out_rx_ready.export
			.rx_parallel_data          (gx_rx_parallel_data_export),                                                                                                                                                                                                                                                                                                                                                                                            //    rx_parallel_data.export
			.rx_serial_data            (pma_bridge_rx_serial_data_export),                                                                                                                                                                                                                                                                                                                                                                                      //      rx_serial_data.export
			.rx_ready                  (gx_rx_ready_export),                                                                                                                                                                                                                                                                                                                                                                                                    //            rx_ready.export
			.reco_readdata             (reco_readdata),                                                                                                                                                                                                                                                                                                                                                                                                         //       reco_readdata.export
			.out_busy                  (busy),                                                                                                                                                                                                                                                                                                                                                                                                                  //            out_busy.export
			.pll_locked                (1'b0),                                                                                                                                                                                                                                                                                                                                                                                                                  //         (terminated)
			.tx_coreclk                (),                                                                                                                                                                                                                                                                                                                                                                                                                      //         (terminated)
			.tx_clkout                 (10'b0000000000),                                                                                                                                                                                                                                                                                                                                                                                                        //         (terminated)
			.tx_datain                 (400'b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000), //         (terminated)
			.tx_dataout                (),                                                                                                                                                                                                                                                                                                                                                                                                                      //         (terminated)
			.tx_parallel_data          (),                                                                                                                                                                                                                                                                                                                                                                                                                      //         (terminated)
			.tx_serial_data            (10'b0000000000),                                                                                                                                                                                                                                                                                                                                                                                                        //         (terminated)
			.tx_ready                  (1'b0),                                                                                                                                                                                                                                                                                                                                                                                                                  //         (terminated)
			.reconfig_busy             (1'b0),                                                                                                                                                                                                                                                                                                                                                                                                                  //         (terminated)
			.clk_status_reco           (),                                                                                                                                                                                                                                                                                                                                                                                                                      //         (terminated)
			.pma_arst_reco             (),                                                                                                                                                                                                                                                                                                                                                                                                                      //         (terminated)
			.reconfig_mgmt_address     (),                                                                                                                                                                                                                                                                                                                                                                                                                      //         (terminated)
			.reconfig_mgmt_read        (),                                                                                                                                                                                                                                                                                                                                                                                                                      //         (terminated)
			.reconfig_mgmt_readdata    (32'b00000000000000000000000000000000),                                                                                                                                                                                                                                                                                                                                                                                  //         (terminated)
			.reconfig_mgmt_waitrequest (1'b0),                                                                                                                                                                                                                                                                                                                                                                                                                  //         (terminated)
			.reconfig_mgmt_write       (),                                                                                                                                                                                                                                                                                                                                                                                                                      //         (terminated)
			.reconfig_mgmt_writedata   ()                                                                                                                                                                                                                                                                                                                                                                                                                       //         (terminated)
		);
		
	alt_e100_rx_e10x10 sv_pma_rx (
		.phy_mgmt_clk(pma_bridge_clk_status_gx_clk),         //       phy_mgmt_clk.clk
		.phy_mgmt_clk_reset(pma_bridge_pma_arst_gx_reset),   // phy_mgmt_clk_reset.reset
		.phy_mgmt_address(pma_bridge_phy_mgmt_address),     //           phy_mgmt.address
		.phy_mgmt_read(pma_bridge_phy_mgmt_read),        //                   .read
		.phy_mgmt_readdata(pma_bridge_phy_mgmt_readdata),    //                   .readdata
		.phy_mgmt_waitrequest(pma_bridge_phy_mgmt_waitrequest), //                   .waitrequest
		.phy_mgmt_write(pma_bridge_phy_mgmt_write),       //                   .write
		.phy_mgmt_writedata(pma_bridge_phy_mgmt_writedata),   //                   .writedata
		.rx_ready(gx_rx_ready_export),             //           rx_ready.export
		.pll_ref_clk(pma_bridge_pll_inclk_clk),          //        pll_ref_clk.clk
		.rx_serial_data(pma_bridge_rx_serial_data_export),       //     rx_serial_data.export
		.rx_is_lockedtoref(gx_rx_is_lockedtoref_export),    //  rx_is_lockedtoref.export
		.rx_is_lockedtodata(gx_rx_is_lockedtodata_export),   // rx_is_lockedtodata.export
		.rx_coreclkin(pma_bridge_rx_coreclk_export),         //       rx_coreclkin.export
		.rx_clkout(gx_rx_clkout_export),            //          rx_clkout.export
		.rx_parallel_data(gx_rx_parallel_data_export),     //   rx_parallel_data.export
		.reconfig_from_xcvr(reconfig_from_xcvr[459:0]),   // reconfig_from_xcvr.reconfig_from_xcvr
		.reconfig_to_xcvr(reconfig_to_xcvr[699:0])      //   reconfig_to_xcvr.reconfig_to_xcvr
	);
	
	
	assign reconfig_from_xcvr[919:460] = 460'b0;
	assign tx_dataout = 10'b0;
	
	end
	else begin : BLD_PMA_SV_TXDUP
		alt_e100_pma_sv_bridge #(
			.FAKE_TX_SKEW (0),
			.VARIANT      (VARIANT),
			.en_synce_support(0)
		) pma_bridge (
			.pma_arst                  (pma_arst),                                                                                                                                                                                                                                                                                                                                                                                                              //            pma_arst.reset
			.clk_status                (clk_status),                                                                                                                                                                                                                                                                                                                                                                                                            //          clk_status.clk
			.clk_ref                   (clk_ref),                                                                                                                                                                                                                                                                                                                                                                                                               //             clk_ref.clk
			.tx_pll_lock               (tx_pll_lock),                                                                                                                                                                                                                                                                                                                                                                                                           //         tx_pll_lock.export
			.rx_cdr_lock               (rx_cdr_lock),                                                                                                                                                                                                                                                                                                                                                                                                           //         rx_cdr_lock.export
			.clk_tx                    (clk_tx),                                                                                                                                                                                                                                                                                                                                                                                                                //              clk_tx.clk
			.err_inject                (err_inject),                                                                                                                                                                                                                                                                                                                                                                                                            //          err_inject.export
			.clk_rx                    (clk_rx),                                                                                                                                                                                                                                                                                                                                                                                                                //              clk_rx.clk
			.status_read               (status_read),                                                                                                                                                                                                                                                                                                                                                                                                           //         status_read.export
			.status_write              (status_write),                                                                                                                                                                                                                                                                                                                                                                                                          //        status_write.export
			.status_addr               (status_addr),                                                                                                                                                                                                                                                                                                                                                                                                           //         status_addr.export
			.status_writedata          (status_writedata),                                                                                                                                                                                                                                                                                                                                                                                                      //    status_writedata.export
			.reco_readdata_valid       (reco_readdata_valid),                                                                                                                                                                                                                                                                                                                                                                                                   // reco_readdata_valid.export
			.phy_readdata_valid        (phy_readdata_valid),                                                                                                                                                                                                                                                                                                                                                                                                    //  phy_readdata_valid.export
			.clk_status_gx             (pma_bridge_clk_status_gx_clk),                                                                                                                                                                                                                                                                                                                                                                                          //       clk_status_gx.clk
			.pma_arst_gx               (pma_bridge_pma_arst_gx_reset),                                                                                                                                                                                                                                                                                                                                                                                          //         pma_arst_gx.reset
			.phy_readdata              (phy_readdata),                                                                                                                                                                                                                                                                                                                                                                                                          //        phy_readdata.export
			.phy_mgmt_address          (pma_bridge_phy_mgmt_address),                                                                                                                                                                                                                                                                                                                                                                                           //            phy_mgmt.address
			.phy_mgmt_read             (pma_bridge_phy_mgmt_read),                                                                                                                                                                                                                                                                                                                                                                                              //                    .read
			.phy_mgmt_readdata         (pma_bridge_phy_mgmt_readdata),                                                                                                                                                                                                                                                                                                                                                                                          //                    .readdata
			.phy_mgmt_waitrequest      (pma_bridge_phy_mgmt_waitrequest),                                                                                                                                                                                                                                                                                                                                                                                       //                    .waitrequest
			.phy_mgmt_write            (pma_bridge_phy_mgmt_write),                                                                                                                                                                                                                                                                                                                                                                                             //                    .write
			.phy_mgmt_writedata        (pma_bridge_phy_mgmt_writedata),                                                                                                                                                                                                                                                                                                                                                                                         //                    .writedata
			.pll_inclk                 (pma_bridge_pll_inclk_clk),                                                                                                                                                                                                                                                                                                                                                                                              //           pll_inclk.clk
			.cdr_ref_clk               (cdr_ref_clk),
			.pll_locked                (gx_pll_locked_export),                                                                                                                                                                                                                                                                                                                                                                                                  //          pll_locked.export
			.tx_coreclk                (pma_bridge_tx_coreclk_export),                                                                                                                                                                                                                                                                                                                                                                                          //          tx_coreclk.export
			.tx_clkout                 (gx_tx_clkout_export),                                                                                                                                                                                                                                                                                                                                                                                                   //           tx_clkout.export
			.tx_datain                 (tx_datain),                                                                                                                                                                                                                                                                                                                                                                                                             //           tx_datain.export
			.tx_dataout                (tx_dataout),                                                                                                                                                                                                                                                                                                                                                                                                            //          tx_dataout.export
			.out_tx_ready              (tx_ready),                                                                                                                                                                                                                                                                                                                                                                                                              //        out_tx_ready.export
			.out_rx_ready              (rx_ready),                                                                                                                                                                                                                                                                                                                                                                                                              //        out_rx_ready.export
			.tx_parallel_data          (pma_bridge_tx_parallel_data_export),                                                                                                                                                                                                                                                                                                                                                                                    //    tx_parallel_data.export
			.tx_serial_data            (gx_tx_serial_data_export),                                                                                                                                                                                                                                                                                                                                                                                              //      tx_serial_data.export
			.tx_ready                  (gx_tx_ready_export),                                                                                                                                                                                                                                                                                                                                                                                                    //            tx_ready.export
			.reco_readdata             (reco_readdata),                                                                                                                                                                                                                                                                                                                                                                                                         //       reco_readdata.export
			.out_busy                  (busy),                                                                                                                                                                                                                                                                                                                                                                                                                  //            out_busy.export
			.rx_freqlocked             (10'b0000000000),                                                                                                                                                                                                                                                                                                                                                                                                        //         (terminated)
			.rx_is_lockedtodata        (10'b0000000000),                                                                                                                                                                                                                                                                                                                                                                                                        //         (terminated)
			.rx_coreclk                (),                                                                                                                                                                                                                                                                                                                                                                                                                      //         (terminated)
			.rx_clkout                 (10'b0000000000),                                                                                                                                                                                                                                                                                                                                                                                                        //         (terminated)
			.rx_dataout                (),                                                                                                                                                                                                                                                                                                                                                                                                                      //         (terminated)
			.rx_datain                 (10'b0000000000),                                                                                                                                                                                                                                                                                                                                                                                                        //         (terminated)
			.rx_parallel_data          (400'b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000), //         (terminated)
			.rx_serial_data            (),                                                                                                                                                                                                                                                                                                                                                                                                                      //         (terminated)
			.rx_ready                  (1'b0),                                                                                                                                                                                                                                                                                                                                                                                                                  //         (terminated)
			.reconfig_busy             (1'b0),                                                                                                                                                                                                                                                                                                                                                                                                                  //         (terminated)
			.clk_status_reco           (),                                                                                                                                                                                                                                                                                                                                                                                                                      //         (terminated)
			.pma_arst_reco             (),                                                                                                                                                                                                                                                                                                                                                                                                                      //         (terminated)
			.reconfig_mgmt_address     (),                                                                                                                                                                                                                                                                                                                                                                                                                      //         (terminated)
			.reconfig_mgmt_read        (),                                                                                                                                                                                                                                                                                                                                                                                                                      //         (terminated)
			.reconfig_mgmt_readdata    (32'b00000000000000000000000000000000),                                                                                                                                                                                                                                                                                                                                                                                  //         (terminated)
			.reconfig_mgmt_waitrequest (1'b0),                                                                                                                                                                                                                                                                                                                                                                                                                  //         (terminated)
			.reconfig_mgmt_write       (),                                                                                                                                                                                                                                                                                                                                                                                                                      //         (terminated)
			.reconfig_mgmt_writedata   ()                                                                                                                                                                                                                                                                                                                                                                                                                       //         (terminated)
		);
		
	alt_e100_tx_e10x10 sv_pma_txdup (
		.phy_mgmt_clk(pma_bridge_clk_status_gx_clk),         //       phy_mgmt_clk.clk
		.phy_mgmt_clk_reset(pma_bridge_pma_arst_gx_reset),   // phy_mgmt_clk_reset.reset
		.phy_mgmt_address(pma_bridge_phy_mgmt_address),     //           phy_mgmt.address
		.phy_mgmt_read(pma_bridge_phy_mgmt_read),        //                   .read
		.phy_mgmt_readdata(pma_bridge_phy_mgmt_readdata),    //                   .readdata
		.phy_mgmt_waitrequest(pma_bridge_phy_mgmt_waitrequest), //                   .waitrequest
		.phy_mgmt_write(pma_bridge_phy_mgmt_write),       //                   .write
		.phy_mgmt_writedata(pma_bridge_phy_mgmt_writedata),   //                   .writedata
		.tx_ready(gx_tx_ready_export),             //           tx_ready.export
		.pll_ref_clk(pma_bridge_pll_inclk_clk),          //        pll_ref_clk.clk
		.pll_locked(gx_pll_locked_export),           //         pll_locked.export
		.tx_serial_data(gx_tx_serial_data_export),       //     tx_serial_data.export
		.tx_coreclkin(pma_bridge_tx_coreclk_export),         //       tx_coreclkin.export
		.tx_clkout(gx_tx_clkout_export),            //          tx_clkout.export
		.tx_parallel_data(pma_bridge_tx_parallel_data_export),     //   tx_parallel_data.export
		.reconfig_from_xcvr(reconfig_from_xcvr),   // reconfig_from_xcvr.reconfig_from_xcvr
		.reconfig_to_xcvr(reconfig_to_xcvr)      //   reconfig_to_xcvr.reconfig_to_xcvr
	);	

	
	assign rx_dataout = 400'b0;
	
	end

endgenerate


endmodule
