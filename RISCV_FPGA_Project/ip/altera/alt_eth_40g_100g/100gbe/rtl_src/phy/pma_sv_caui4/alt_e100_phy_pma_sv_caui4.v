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
module alt_e100_phy_pma_sv_caui4 #(
	parameter en_synce_support = 0
)(
		output wire         phy_readdata_valid0_export, // phy_readdata_valid0.export
		output wire [31:0]  phy_readdata0_export,       //       phy_readdata0.export
		output wire [137:0] reconfig_from_xcvr0,        // reconfig_from_xcvr0.reconfig_from_xcvr
		input  wire [209:0] reconfig_to_xcvr0,          //   reconfig_to_xcvr0.reconfig_to_xcvr
		output wire         phy_readdata_valid1_export, // phy_readdata_valid1.export
		output wire [31:0]  phy_readdata1_export,       //       phy_readdata1.export
		output wire [137:0] reconfig_from_xcvr1,        // reconfig_from_xcvr1.reconfig_from_xcvr
		input  wire [209:0] reconfig_to_xcvr1,          //   reconfig_to_xcvr1.reconfig_to_xcvr
		output wire         phy_readdata_valid2_export, // phy_readdata_valid2.export
		output wire [31:0]  phy_readdata2_export,       //       phy_readdata2.export
		output wire [137:0] reconfig_from_xcvr2,        // reconfig_from_xcvr2.reconfig_from_xcvr
		input  wire [209:0] reconfig_to_xcvr2,          //   reconfig_to_xcvr2.reconfig_to_xcvr
		output wire         phy_readdata_valid3_export, // phy_readdata_valid3.export
		output wire [31:0]  phy_readdata3_export,       //       phy_readdata3.export
		output wire [137:0] reconfig_from_xcvr3,        // reconfig_from_xcvr3.reconfig_from_xcvr
		input  wire [209:0] reconfig_to_xcvr3,          //   reconfig_to_xcvr3.reconfig_to_xcvr
		input  wire [3:0]   rx_datain,                  //           rx_datain.export
		output wire [511:0] rx_dataout,                 //          rx_dataout.export
		output wire [3:0]   tx_dataout,                 //          tx_dataout.export
		input  wire [511:0] tx_datain,                  //           tx_datain.export
		input  wire         status_read,                //         status_read.export
		input  wire         status_write,               //        status_write.export
		input  wire [15:0]  status_addr,                //         status_addr.export
		input  wire [31:0]  status_writedata,           //    status_writedata.export
		output wire         reco_readdata_valid,        // reco_readdata_valid.export
		output wire         clk_rx,                     //              clk_rx.clk
		output wire         clk_tx,                     //              clk_tx.clk
		input  wire         clk_ref,                    //             clk_ref.clk
		input  wire         rx_clk_ref,
		input  wire         tx_clk_ref,
		input  wire [1:0]   err_inject,                 //          err_inject.export
		output wire [3:0]   tx_pll_lock,                //         tx_pll_lock.export
		output wire [3:0]   rx_cdr_lock,                //         rx_cdr_lock.export
		input  wire         pma_arst,                   //            pma_arst.reset
		input  wire         clk_status,                 //          clk_status.clk
		output wire         rx_ready,                   //            rx_ready.export
		output wire         tx_ready,                   //            tx_ready.export
		output wire [31:0]  reco_readdata,              //       reco_readdata.export
		output wire         busy                        //                busy.export
	);

	wire          gx_0_rx_ready_export;                 // gx_0:rx_ready -> pma_bridge:rx_ready_0
	wire          pma_bridge_rx_serial_data_0_export;   // pma_bridge:rx_serial_data_0 -> gx_0:rx_serial_data
	wire  [127:0] gx_0_rx_parallel_data_export;         // gx_0:rx_parallel_data -> pma_bridge:rx_parallel_data_0
	wire    [0:0] gx_0_rx_is_lockedtoref_export;        // gx_0:rx_is_lockedtoref -> pma_bridge:rx_freqlocked_0
	wire    [0:0] gx_0_rx_is_lockedtodata_export;       // gx_0:rx_is_lockedtodata -> pma_bridge:rx_is_lockedtodata_0
	wire    [0:0] gx_0_rx_clkout_export;                // gx_0:rx_clkout -> pma_bridge:rx_clkout_0
	wire          gx_0_tx_ready_export;                 // gx_0:tx_ready -> pma_bridge:tx_ready_0
	wire    [0:0] gx_0_tx_serial_data_export;           // gx_0:tx_serial_data -> pma_bridge:tx_serial_data_0
	wire    [0:0] gx_0_pll_locked_export;               // gx_0:pll_locked -> pma_bridge:pll_locked_0
	wire    [0:0] gx_0_tx_clkout_export;                // gx_0:tx_clkout -> pma_bridge:tx_clkout_0
	wire  [127:0] pma_bridge_tx_parallel_data_0_export; // pma_bridge:tx_parallel_data_0 -> gx_0:tx_parallel_data
	wire          pma_bridge_pll_inclk_0_clk;           // pma_bridge:pll_inclk_0 -> gx_0:pll_ref_clk
	wire          cdr_ref_0_clk;
	wire          pma_bridge_clk_status_gx_0_clk;       // pma_bridge:clk_status_gx_0 -> gx_0:phy_mgmt_clk
	wire          pma_bridge_pma_arst_gx_0_reset;       // pma_bridge:pma_arst_gx_0 -> gx_0:phy_mgmt_clk_reset
	wire          pma_bridge_phy_mgmt_0_waitrequest;    // gx_0:phy_mgmt_waitrequest -> pma_bridge:phy_mgmt_0_waitrequest
	wire   [31:0] pma_bridge_phy_mgmt_0_writedata;      // pma_bridge:phy_mgmt_0_writedata -> gx_0:phy_mgmt_writedata
	wire    [8:0] pma_bridge_phy_mgmt_0_address;        // pma_bridge:phy_mgmt_0_address -> gx_0:phy_mgmt_address
	wire          pma_bridge_phy_mgmt_0_write;          // pma_bridge:phy_mgmt_0_write -> gx_0:phy_mgmt_write
	wire          pma_bridge_phy_mgmt_0_read;           // pma_bridge:phy_mgmt_0_read -> gx_0:phy_mgmt_read
	wire   [31:0] pma_bridge_phy_mgmt_0_readdata;       // gx_0:phy_mgmt_readdata -> pma_bridge:phy_mgmt_0_readdata
	wire          gx_1_rx_ready_export;                 // gx_1:rx_ready -> pma_bridge:rx_ready_1
	wire          pma_bridge_rx_serial_data_1_export;   // pma_bridge:rx_serial_data_1 -> gx_1:rx_serial_data
	wire  [127:0] gx_1_rx_parallel_data_export;         // gx_1:rx_parallel_data -> pma_bridge:rx_parallel_data_1
	wire    [0:0] gx_1_rx_is_lockedtoref_export;        // gx_1:rx_is_lockedtoref -> pma_bridge:rx_freqlocked_1
	wire    [0:0] gx_1_rx_is_lockedtodata_export;       // gx_1:rx_is_lockedtodata -> pma_bridge:rx_is_lockedtodata_1
	wire    [0:0] gx_1_rx_clkout_export;                // gx_1:rx_clkout -> pma_bridge:rx_clkout_1
	wire          gx_1_tx_ready_export;                 // gx_1:tx_ready -> pma_bridge:tx_ready_1
	wire    [0:0] gx_1_tx_serial_data_export;           // gx_1:tx_serial_data -> pma_bridge:tx_serial_data_1
	wire    [0:0] gx_1_pll_locked_export;               // gx_1:pll_locked -> pma_bridge:pll_locked_1
	wire    [0:0] gx_1_tx_clkout_export;                // gx_1:tx_clkout -> pma_bridge:tx_clkout_1
	wire  [127:0] pma_bridge_tx_parallel_data_1_export; // pma_bridge:tx_parallel_data_1 -> gx_1:tx_parallel_data
	wire          pma_bridge_pll_inclk_1_clk;           // pma_bridge:pll_inclk_1 -> gx_1:pll_ref_clk
	wire          cdr_ref_1_clk;
	wire          pma_bridge_clk_status_gx_1_clk;       // pma_bridge:clk_status_gx_1 -> gx_1:phy_mgmt_clk
	wire          pma_bridge_pma_arst_gx_1_reset;       // pma_bridge:pma_arst_gx_1 -> gx_1:phy_mgmt_clk_reset
	wire          pma_bridge_phy_mgmt_1_waitrequest;    // gx_1:phy_mgmt_waitrequest -> pma_bridge:phy_mgmt_1_waitrequest
	wire   [31:0] pma_bridge_phy_mgmt_1_writedata;      // pma_bridge:phy_mgmt_1_writedata -> gx_1:phy_mgmt_writedata
	wire    [8:0] pma_bridge_phy_mgmt_1_address;        // pma_bridge:phy_mgmt_1_address -> gx_1:phy_mgmt_address
	wire          pma_bridge_phy_mgmt_1_write;          // pma_bridge:phy_mgmt_1_write -> gx_1:phy_mgmt_write
	wire          pma_bridge_phy_mgmt_1_read;           // pma_bridge:phy_mgmt_1_read -> gx_1:phy_mgmt_read
	wire   [31:0] pma_bridge_phy_mgmt_1_readdata;       // gx_1:phy_mgmt_readdata -> pma_bridge:phy_mgmt_1_readdata
	wire          gx_2_rx_ready_export;                 // gx_2:rx_ready -> pma_bridge:rx_ready_2
	wire          pma_bridge_rx_serial_data_2_export;   // pma_bridge:rx_serial_data_2 -> gx_2:rx_serial_data
	wire  [127:0] gx_2_rx_parallel_data_export;         // gx_2:rx_parallel_data -> pma_bridge:rx_parallel_data_2
	wire    [0:0] gx_2_rx_is_lockedtoref_export;        // gx_2:rx_is_lockedtoref -> pma_bridge:rx_freqlocked_2
	wire    [0:0] gx_2_rx_is_lockedtodata_export;       // gx_2:rx_is_lockedtodata -> pma_bridge:rx_is_lockedtodata_2
	wire    [0:0] gx_2_rx_clkout_export;                // gx_2:rx_clkout -> pma_bridge:rx_clkout_2
	wire          gx_2_tx_ready_export;                 // gx_2:tx_ready -> pma_bridge:tx_ready_2
	wire    [0:0] gx_2_tx_serial_data_export;           // gx_2:tx_serial_data -> pma_bridge:tx_serial_data_2
	wire    [0:0] gx_2_pll_locked_export;               // gx_2:pll_locked -> pma_bridge:pll_locked_2
	wire    [0:0] gx_2_tx_clkout_export;                // gx_2:tx_clkout -> pma_bridge:tx_clkout_2
	wire  [127:0] pma_bridge_tx_parallel_data_2_export; // pma_bridge:tx_parallel_data_2 -> gx_2:tx_parallel_data
	wire          pma_bridge_pll_inclk_2_clk;           // pma_bridge:pll_inclk_2 -> gx_2:pll_ref_clk
	wire          cdr_ref_2_clk;
	wire          pma_bridge_clk_status_gx_2_clk;       // pma_bridge:clk_status_gx_2 -> gx_2:phy_mgmt_clk
	wire          pma_bridge_pma_arst_gx_2_reset;       // pma_bridge:pma_arst_gx_2 -> gx_2:phy_mgmt_clk_reset
	wire          pma_bridge_phy_mgmt_2_waitrequest;    // gx_2:phy_mgmt_waitrequest -> pma_bridge:phy_mgmt_2_waitrequest
	wire   [31:0] pma_bridge_phy_mgmt_2_writedata;      // pma_bridge:phy_mgmt_2_writedata -> gx_2:phy_mgmt_writedata
	wire    [8:0] pma_bridge_phy_mgmt_2_address;        // pma_bridge:phy_mgmt_2_address -> gx_2:phy_mgmt_address
	wire          pma_bridge_phy_mgmt_2_write;          // pma_bridge:phy_mgmt_2_write -> gx_2:phy_mgmt_write
	wire          pma_bridge_phy_mgmt_2_read;           // pma_bridge:phy_mgmt_2_read -> gx_2:phy_mgmt_read
	wire   [31:0] pma_bridge_phy_mgmt_2_readdata;       // gx_2:phy_mgmt_readdata -> pma_bridge:phy_mgmt_2_readdata
	wire          gx_3_rx_ready_export;                 // gx_3:rx_ready -> pma_bridge:rx_ready_3
	wire          pma_bridge_rx_serial_data_3_export;   // pma_bridge:rx_serial_data_3 -> gx_3:rx_serial_data
	wire  [127:0] gx_3_rx_parallel_data_export;         // gx_3:rx_parallel_data -> pma_bridge:rx_parallel_data_3
	wire    [0:0] gx_3_rx_is_lockedtoref_export;        // gx_3:rx_is_lockedtoref -> pma_bridge:rx_freqlocked_3
	wire    [0:0] gx_3_rx_is_lockedtodata_export;       // gx_3:rx_is_lockedtodata -> pma_bridge:rx_is_lockedtodata_3
	wire    [0:0] gx_3_rx_clkout_export;                // gx_3:rx_clkout -> pma_bridge:rx_clkout_3
	wire          gx_3_tx_ready_export;                 // gx_3:tx_ready -> pma_bridge:tx_ready_3
	wire    [0:0] gx_3_tx_serial_data_export;           // gx_3:tx_serial_data -> pma_bridge:tx_serial_data_3
	wire    [0:0] gx_3_pll_locked_export;               // gx_3:pll_locked -> pma_bridge:pll_locked_3
	wire    [0:0] gx_3_tx_clkout_export;                // gx_3:tx_clkout -> pma_bridge:tx_clkout_3
	wire  [127:0] pma_bridge_tx_parallel_data_3_export; // pma_bridge:tx_parallel_data_3 -> gx_3:tx_parallel_data
	wire          pma_bridge_pll_inclk_3_clk;           // pma_bridge:pll_inclk_3 -> gx_3:pll_ref_clk
	wire          cdr_ref_3_clk;
	wire          pma_bridge_clk_status_gx_3_clk;       // pma_bridge:clk_status_gx_3 -> gx_3:phy_mgmt_clk
	wire          pma_bridge_pma_arst_gx_3_reset;       // pma_bridge:pma_arst_gx_3 -> gx_3:phy_mgmt_clk_reset
	wire          pma_bridge_phy_mgmt_3_waitrequest;    // gx_3:phy_mgmt_waitrequest -> pma_bridge:phy_mgmt_3_waitrequest
	wire   [31:0] pma_bridge_phy_mgmt_3_writedata;      // pma_bridge:phy_mgmt_3_writedata -> gx_3:phy_mgmt_writedata
	wire    [8:0] pma_bridge_phy_mgmt_3_address;        // pma_bridge:phy_mgmt_3_address -> gx_3:phy_mgmt_address
	wire          pma_bridge_phy_mgmt_3_write;          // pma_bridge:phy_mgmt_3_write -> gx_3:phy_mgmt_write
	wire          pma_bridge_phy_mgmt_3_read;           // pma_bridge:phy_mgmt_3_read -> gx_3:phy_mgmt_read
	wire   [31:0] pma_bridge_phy_mgmt_3_readdata;       // gx_3:phy_mgmt_readdata -> pma_bridge:phy_mgmt_3_readdata

	alt_e100_pma_sv_bridge_caui4 #(
		.FAKE_TX_SKEW (0),
		.VARIANT      (3),
		.en_synce_support(en_synce_support)
	) pma_bridge (
		.pma_arst               (pma_arst),                             //             pma_arst.reset
		.clk_status             (clk_status),                           //           clk_status.clk
		.clk_ref                (clk_ref),                              //              clk_ref.clk
		.rx_clk_ref             (rx_clk_ref),
		.tx_clk_ref             (tx_clk_ref),
		.tx_pll_lock            (tx_pll_lock),                          //          tx_pll_lock.export
		.rx_cdr_lock            (rx_cdr_lock),                          //          rx_cdr_lock.export
		.clk_tx                 (clk_tx),                               //               clk_tx.clk
		.err_inject             (err_inject),                           //           err_inject.export
		.clk_rx                 (clk_rx),                               //               clk_rx.clk
		.status_read            (status_read),                          //          status_read.export
		.status_write           (status_write),                         //         status_write.export
		.status_addr            (status_addr),                          //          status_addr.export
		.status_writedata       (status_writedata),                     //     status_writedata.export
		.tx_datain              (tx_datain),                            //            tx_datain.export
		.rx_dataout             (rx_dataout),                           //           rx_dataout.export
		.rx_datain              (rx_datain),                            //            rx_datain.export
		.tx_dataout             (tx_dataout),                           //           tx_dataout.export
		.tx_ready               (tx_ready),                             //             tx_ready.export
		.rx_ready               (rx_ready),                             //             rx_ready.export
		.phy_readdata0          (phy_readdata0_export),                 //        phy_readdata0.export
		.phy_readdata_valid0    (phy_readdata_valid0_export),           //  phy_readdata_valid0.export
		.phy_readdata1          (phy_readdata1_export),                 //        phy_readdata1.export
		.phy_readdata_valid1    (phy_readdata_valid1_export),           //  phy_readdata_valid1.export
		.phy_readdata2          (phy_readdata2_export),                 //        phy_readdata2.export
		.phy_readdata_valid2    (phy_readdata_valid2_export),           //  phy_readdata_valid2.export
		.phy_readdata3          (phy_readdata3_export),                 //        phy_readdata3.export
		.phy_readdata_valid3    (phy_readdata_valid3_export),           //  phy_readdata_valid3.export
		.clk_status_gx_0        (pma_bridge_clk_status_gx_0_clk),       //      clk_status_gx_0.clk
		.pma_arst_gx_0          (pma_bridge_pma_arst_gx_0_reset),       //        pma_arst_gx_0.reset
		.phy_mgmt_0_address     (pma_bridge_phy_mgmt_0_address),        //           phy_mgmt_0.address
		.phy_mgmt_0_read        (pma_bridge_phy_mgmt_0_read),           //                     .read
		.phy_mgmt_0_readdata    (pma_bridge_phy_mgmt_0_readdata),       //                     .readdata
		.phy_mgmt_0_waitrequest (pma_bridge_phy_mgmt_0_waitrequest),    //                     .waitrequest
		.phy_mgmt_0_write       (pma_bridge_phy_mgmt_0_write),          //                     .write
		.phy_mgmt_0_writedata   (pma_bridge_phy_mgmt_0_writedata),      //                     .writedata
		.pll_inclk_0            (pma_bridge_pll_inclk_0_clk),           //          pll_inclk_0.clk
		.cdr_ref_0_clk          (cdr_ref_0_clk),
		.rx_freqlocked_0        (gx_0_rx_is_lockedtoref_export),        //      rx_freqlocked_0.export
		.rx_is_lockedtodata_0   (gx_0_rx_is_lockedtodata_export),       // rx_is_lockedtodata_0.export
		.rx_clkout_0            (gx_0_rx_clkout_export),                //          rx_clkout_0.export
		.pll_locked_0           (gx_0_pll_locked_export),               //         pll_locked_0.export
		.tx_clkout_0            (gx_0_tx_clkout_export),                //          tx_clkout_0.export
		.tx_ready_0             (gx_0_tx_ready_export),                 //           tx_ready_0.export
		.rx_ready_0             (gx_0_rx_ready_export),                 //           rx_ready_0.export
		.tx_parallel_data_0     (pma_bridge_tx_parallel_data_0_export), //   tx_parallel_data_0.export
		.rx_parallel_data_0     (gx_0_rx_parallel_data_export),         //   rx_parallel_data_0.export
		.rx_serial_data_0       (pma_bridge_rx_serial_data_0_export),   //     rx_serial_data_0.export
		.tx_serial_data_0       (gx_0_tx_serial_data_export),           //     tx_serial_data_0.export
		.clk_status_gx_1        (pma_bridge_clk_status_gx_1_clk),       //      clk_status_gx_1.clk
		.pma_arst_gx_1          (pma_bridge_pma_arst_gx_1_reset),       //        pma_arst_gx_1.reset
		.phy_mgmt_1_address     (pma_bridge_phy_mgmt_1_address),        //           phy_mgmt_1.address
		.phy_mgmt_1_read        (pma_bridge_phy_mgmt_1_read),           //                     .read
		.phy_mgmt_1_readdata    (pma_bridge_phy_mgmt_1_readdata),       //                     .readdata
		.phy_mgmt_1_waitrequest (pma_bridge_phy_mgmt_1_waitrequest),    //                     .waitrequest
		.phy_mgmt_1_write       (pma_bridge_phy_mgmt_1_write),          //                     .write
		.phy_mgmt_1_writedata   (pma_bridge_phy_mgmt_1_writedata),      //                     .writedata
		.pll_inclk_1            (pma_bridge_pll_inclk_1_clk),           //          pll_inclk_1.clk
		.cdr_ref_1_clk          (cdr_ref_1_clk),
		.rx_freqlocked_1        (gx_1_rx_is_lockedtoref_export),        //      rx_freqlocked_1.export
		.rx_is_lockedtodata_1   (gx_1_rx_is_lockedtodata_export),       // rx_is_lockedtodata_1.export
		.rx_clkout_1            (gx_1_rx_clkout_export),                //          rx_clkout_1.export
		.pll_locked_1           (gx_1_pll_locked_export),               //         pll_locked_1.export
		.tx_clkout_1            (gx_1_tx_clkout_export),                //          tx_clkout_1.export
		.tx_ready_1             (gx_1_tx_ready_export),                 //           tx_ready_1.export
		.rx_ready_1             (gx_1_rx_ready_export),                 //           rx_ready_1.export
		.tx_parallel_data_1     (pma_bridge_tx_parallel_data_1_export), //   tx_parallel_data_1.export
		.rx_parallel_data_1     (gx_1_rx_parallel_data_export),         //   rx_parallel_data_1.export
		.rx_serial_data_1       (pma_bridge_rx_serial_data_1_export),   //     rx_serial_data_1.export
		.tx_serial_data_1       (gx_1_tx_serial_data_export),           //     tx_serial_data_1.export
		.clk_status_gx_2        (pma_bridge_clk_status_gx_2_clk),       //      clk_status_gx_2.clk
		.pma_arst_gx_2          (pma_bridge_pma_arst_gx_2_reset),       //        pma_arst_gx_2.reset
		.phy_mgmt_2_address     (pma_bridge_phy_mgmt_2_address),        //           phy_mgmt_2.address
		.phy_mgmt_2_read        (pma_bridge_phy_mgmt_2_read),           //                     .read
		.phy_mgmt_2_readdata    (pma_bridge_phy_mgmt_2_readdata),       //                     .readdata
		.phy_mgmt_2_waitrequest (pma_bridge_phy_mgmt_2_waitrequest),    //                     .waitrequest
		.phy_mgmt_2_write       (pma_bridge_phy_mgmt_2_write),          //                     .write
		.phy_mgmt_2_writedata   (pma_bridge_phy_mgmt_2_writedata),      //                     .writedata
		.pll_inclk_2            (pma_bridge_pll_inclk_2_clk),           //          pll_inclk_2.clk
		.cdr_ref_2_clk          (cdr_ref_2_clk),
		.rx_freqlocked_2        (gx_2_rx_is_lockedtoref_export),        //      rx_freqlocked_2.export
		.rx_is_lockedtodata_2   (gx_2_rx_is_lockedtodata_export),       // rx_is_lockedtodata_2.export
		.rx_clkout_2            (gx_2_rx_clkout_export),                //          rx_clkout_2.export
		.pll_locked_2           (gx_2_pll_locked_export),               //         pll_locked_2.export
		.tx_clkout_2            (gx_2_tx_clkout_export),                //          tx_clkout_2.export
		.tx_ready_2             (gx_2_tx_ready_export),                 //           tx_ready_2.export
		.rx_ready_2             (gx_2_rx_ready_export),                 //           rx_ready_2.export
		.tx_parallel_data_2     (pma_bridge_tx_parallel_data_2_export), //   tx_parallel_data_2.export
		.rx_parallel_data_2     (gx_2_rx_parallel_data_export),         //   rx_parallel_data_2.export
		.rx_serial_data_2       (pma_bridge_rx_serial_data_2_export),   //     rx_serial_data_2.export
		.tx_serial_data_2       (gx_2_tx_serial_data_export),           //     tx_serial_data_2.export
		.clk_status_gx_3        (pma_bridge_clk_status_gx_3_clk),       //      clk_status_gx_3.clk
		.pma_arst_gx_3          (pma_bridge_pma_arst_gx_3_reset),       //        pma_arst_gx_3.reset
		.phy_mgmt_3_address     (pma_bridge_phy_mgmt_3_address),        //           phy_mgmt_3.address
		.phy_mgmt_3_read        (pma_bridge_phy_mgmt_3_read),           //                     .read
		.phy_mgmt_3_readdata    (pma_bridge_phy_mgmt_3_readdata),       //                     .readdata
		.phy_mgmt_3_waitrequest (pma_bridge_phy_mgmt_3_waitrequest),    //                     .waitrequest
		.phy_mgmt_3_write       (pma_bridge_phy_mgmt_3_write),          //                     .write
		.phy_mgmt_3_writedata   (pma_bridge_phy_mgmt_3_writedata),      //                     .writedata
		.pll_inclk_3            (pma_bridge_pll_inclk_3_clk),           //          pll_inclk_3.clk
		.cdr_ref_3_clk          (cdr_ref_3_clk),
		.rx_freqlocked_3        (gx_3_rx_is_lockedtoref_export),        //      rx_freqlocked_3.export
		.rx_is_lockedtodata_3   (gx_3_rx_is_lockedtodata_export),       // rx_is_lockedtodata_3.export
		.rx_clkout_3            (gx_3_rx_clkout_export),                //          rx_clkout_3.export
		.pll_locked_3           (gx_3_pll_locked_export),               //         pll_locked_3.export
		.tx_clkout_3            (gx_3_tx_clkout_export),                //          tx_clkout_3.export
		.tx_ready_3             (gx_3_tx_ready_export),                 //           tx_ready_3.export
		.rx_ready_3             (gx_3_rx_ready_export),                 //           rx_ready_3.export
		.tx_parallel_data_3     (pma_bridge_tx_parallel_data_3_export), //   tx_parallel_data_3.export
		.rx_parallel_data_3     (gx_3_rx_parallel_data_export),         //   rx_parallel_data_3.export
		.rx_serial_data_3       (pma_bridge_rx_serial_data_3_export),   //     rx_serial_data_3.export
		.tx_serial_data_3       (gx_3_tx_serial_data_export),           //     tx_serial_data_3.export
		.reco_readdata          (reco_readdata),                        //        reco_readdata.export
		.out_busy               (busy),                                 //             out_busy.export
		.reco_readdata_valid    (reco_readdata_valid)                   //  reco_readdata_valid.export
	);
	
	alt_e100_e1x25 gx_0 (
		.phy_mgmt_clk(pma_bridge_clk_status_gx_0_clk),         //       phy_mgmt_clk.clk
		.phy_mgmt_clk_reset(pma_bridge_pma_arst_gx_0_reset),   // phy_mgmt_clk_reset.reset
		.phy_mgmt_address(pma_bridge_phy_mgmt_0_address),     //           phy_mgmt.address
		.phy_mgmt_read(pma_bridge_phy_mgmt_0_read),        //                   .read
		.phy_mgmt_readdata(pma_bridge_phy_mgmt_0_readdata),    //                   .readdata
		.phy_mgmt_waitrequest(pma_bridge_phy_mgmt_0_waitrequest), //                   .waitrequest
		.phy_mgmt_write(pma_bridge_phy_mgmt_0_write),       //                   .write
		.phy_mgmt_writedata(pma_bridge_phy_mgmt_0_writedata),   //                   .writedata
		.tx_ready(gx_0_tx_ready_export),             //           tx_ready.export
		.rx_ready(gx_0_rx_ready_export),             //           rx_ready.export
		.pll_ref_clk(pma_bridge_pll_inclk_0_clk),          //        pll_ref_clk.clk
		.pll_locked(gx_0_pll_locked_export),           //         pll_locked.export
		.tx_serial_data(gx_0_tx_serial_data_export),       //     tx_serial_data.export
		.rx_serial_data(pma_bridge_rx_serial_data_0_export),       //     rx_serial_data.export
		.rx_is_lockedtoref(gx_0_rx_is_lockedtoref_export),    //  rx_is_lockedtoref.export
		.rx_is_lockedtodata(gx_0_rx_is_lockedtodata_export),   // rx_is_lockedtodata.export
		.tx_clkout(gx_0_tx_clkout_export),            //          tx_clkout.export
		.rx_clkout(gx_0_rx_clkout_export),            //          rx_clkout.export
		.cdr_ref_clk          (cdr_ref_0_clk),          //        cdr_ref_clk.export
		.tx_parallel_data(pma_bridge_tx_parallel_data_0_export),     //   tx_parallel_data.export
		.rx_parallel_data(gx_0_rx_parallel_data_export),     //   rx_parallel_data.export
		.reconfig_from_xcvr(reconfig_from_xcvr0),   // reconfig_from_xcvr.reconfig_from_xcvr
		.reconfig_to_xcvr(reconfig_to_xcvr0)      //   reconfig_to_xcvr.reconfig_to_xcvr
	);
	
		alt_e100_e1x25 gx_1 (
		.phy_mgmt_clk(pma_bridge_clk_status_gx_1_clk),         //       phy_mgmt_clk.clk
		.phy_mgmt_clk_reset(pma_bridge_pma_arst_gx_1_reset),   // phy_mgmt_clk_reset.reset
		.phy_mgmt_address(pma_bridge_phy_mgmt_1_address),     //           phy_mgmt.address
		.phy_mgmt_read(pma_bridge_phy_mgmt_1_read),        //                   .read
		.phy_mgmt_readdata(pma_bridge_phy_mgmt_1_readdata),    //                   .readdata
		.phy_mgmt_waitrequest(pma_bridge_phy_mgmt_1_waitrequest), //                   .waitrequest
		.phy_mgmt_write(pma_bridge_phy_mgmt_1_write),       //                   .write
		.phy_mgmt_writedata(pma_bridge_phy_mgmt_1_writedata),   //                   .writedata
		.tx_ready(gx_1_tx_ready_export),             //           tx_ready.export
		.rx_ready(gx_1_rx_ready_export),             //           rx_ready.export
		.pll_ref_clk(pma_bridge_pll_inclk_1_clk),          //        pll_ref_clk.clk
		.pll_locked(gx_1_pll_locked_export),           //         pll_locked.export
		.tx_serial_data(gx_1_tx_serial_data_export),       //     tx_serial_data.export
		.rx_serial_data(pma_bridge_rx_serial_data_1_export),       //     rx_serial_data.export
		.rx_is_lockedtoref(gx_1_rx_is_lockedtoref_export),    //  rx_is_lockedtoref.export
		.rx_is_lockedtodata(gx_1_rx_is_lockedtodata_export),   // rx_is_lockedtodata.export
		.tx_clkout(gx_1_tx_clkout_export),            //          tx_clkout.export
		.rx_clkout(gx_1_rx_clkout_export),            //          rx_clkout.export
		.cdr_ref_clk          (cdr_ref_1_clk),          //        cdr_ref_clk.export
		.tx_parallel_data(pma_bridge_tx_parallel_data_1_export),     //   tx_parallel_data.export
		.rx_parallel_data(gx_1_rx_parallel_data_export),     //   rx_parallel_data.export
		.reconfig_from_xcvr(reconfig_from_xcvr1),   // reconfig_from_xcvr.reconfig_from_xcvr
		.reconfig_to_xcvr(reconfig_to_xcvr1)      //   reconfig_to_xcvr.reconfig_to_xcvr
	);
	
		alt_e100_e1x25 gx_2 (
		.phy_mgmt_clk(pma_bridge_clk_status_gx_2_clk),         //       phy_mgmt_clk.clk
		.phy_mgmt_clk_reset(pma_bridge_pma_arst_gx_2_reset),   // phy_mgmt_clk_reset.reset
		.phy_mgmt_address(pma_bridge_phy_mgmt_2_address),     //           phy_mgmt.address
		.phy_mgmt_read(pma_bridge_phy_mgmt_2_read),        //                   .readw
		.phy_mgmt_readdata(pma_bridge_phy_mgmt_2_readdata),    //                   .readdata
		.phy_mgmt_waitrequest(pma_bridge_phy_mgmt_2_waitrequest), //                   .waitrequest
		.phy_mgmt_write(pma_bridge_phy_mgmt_2_write),       //                   .write
		.phy_mgmt_writedata(pma_bridge_phy_mgmt_2_writedata),   //                   .writedata
		.tx_ready(gx_2_tx_ready_export),             //           tx_ready.export
		.rx_ready(gx_2_rx_ready_export),             //           rx_ready.export
		.pll_ref_clk(pma_bridge_pll_inclk_2_clk),          //        pll_ref_clk.clk
		.pll_locked(gx_2_pll_locked_export),           //         pll_locked.export
		.tx_serial_data(gx_2_tx_serial_data_export),       //     tx_serial_data.export
		.rx_serial_data(pma_bridge_rx_serial_data_2_export),       //     rx_serial_data.export
		.rx_is_lockedtoref(gx_2_rx_is_lockedtoref_export),    //  rx_is_lockedtoref.export
		.rx_is_lockedtodata(gx_2_rx_is_lockedtodata_export),   // rx_is_lockedtodata.export
		.tx_clkout(gx_2_tx_clkout_export),            //          tx_clkout.export
		.rx_clkout(gx_2_rx_clkout_export),            //          rx_clkout.export
		.cdr_ref_clk(cdr_ref_2_clk),          //        cdr_ref_clk.export
		.tx_parallel_data(pma_bridge_tx_parallel_data_2_export),     //   tx_parallel_data.export
		.rx_parallel_data(gx_2_rx_parallel_data_export),     //   rx_parallel_data.export
		.reconfig_from_xcvr(reconfig_from_xcvr2),   // reconfig_from_xcvr.reconfig_from_xcvr
		.reconfig_to_xcvr(reconfig_to_xcvr2)      //   reconfig_to_xcvr.reconfig_to_xcvr
	);
	
		alt_e100_e1x25 gx_3 (
		.phy_mgmt_clk(pma_bridge_clk_status_gx_3_clk),         //       phy_mgmt_clk.clk
		.phy_mgmt_clk_reset(pma_bridge_pma_arst_gx_3_reset),   // phy_mgmt_clk_reset.reset
		.phy_mgmt_address(pma_bridge_phy_mgmt_3_address),     //           phy_mgmt.address
		.phy_mgmt_read(pma_bridge_phy_mgmt_3_read),        //                   .read
		.phy_mgmt_readdata(pma_bridge_phy_mgmt_3_readdata),    //                   .readdata
		.phy_mgmt_waitrequest(pma_bridge_phy_mgmt_3_waitrequest), //                   .waitrequest
		.phy_mgmt_write(pma_bridge_phy_mgmt_3_write),       //                   .write
		.phy_mgmt_writedata(pma_bridge_phy_mgmt_3_writedata),   //                   .writedata
		.tx_ready(gx_3_tx_ready_export),             //           tx_ready.export
		.rx_ready(gx_3_rx_ready_export),             //           rx_ready.export
		.pll_ref_clk(pma_bridge_pll_inclk_3_clk),          //        pll_ref_clk.clk
		.pll_locked(gx_3_pll_locked_export),           //         pll_locked.export
		.tx_serial_data(gx_3_tx_serial_data_export),       //     tx_serial_data.export
		.rx_serial_data(pma_bridge_rx_serial_data_3_export),       //     rx_serial_data.export
		.rx_is_lockedtoref(gx_3_rx_is_lockedtoref_export),    //  rx_is_lockedtoref.export
		.rx_is_lockedtodata(gx_3_rx_is_lockedtodata_export),   // rx_is_lockedtodata.export
		.tx_clkout(gx_3_tx_clkout_export),            //          tx_clkout.export
		.rx_clkout(gx_3_rx_clkout_export),            //          rx_clkout.export
		.cdr_ref_clk(cdr_ref_3_clk),          //        cdr_ref_clk.export
		.tx_parallel_data(pma_bridge_tx_parallel_data_3_export),     //   tx_parallel_data.export
		.rx_parallel_data(gx_3_rx_parallel_data_export),     //   rx_parallel_data.export
		.reconfig_from_xcvr(reconfig_from_xcvr3),   // reconfig_from_xcvr.reconfig_from_xcvr
		.reconfig_to_xcvr(reconfig_to_xcvr3)      //   reconfig_to_xcvr.reconfig_to_xcvr
	);

	

endmodule
