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

module altera_eth_10g_mac_base_r_1588_top (
		input  wire        csr_clk_clk,             //csr_clk.clk
		input  wire        csr_reset_reset_n,       //csr_reset.reset_n
		input  wire        ref_clk_clk,             //ref_clk.clk
		input  wire        ref_reset_reset_n,       //ref_reset.reset_n
		output wire        xgmii_rx_clk_clk,        //xgmii_rx_clk.clk
		input  wire [31:0] csr_address,           //csr.address
		output wire        csr_waitrequest,      //    .waitrequest
		input  wire        csr_read,              //   .read
		output wire [31:0] csr_readdata,          //   .readdata
		input  wire        csr_write,             //   .write
		input  wire [31:0] csr_writedata,          //  .writedata
        input  wire        avalon_st_tx_startofpacket,                                //avalon_st_tx.startofpacket
		input  wire        avalon_st_tx_endofpacket,                                  //            .endofpacket
		input  wire        avalon_st_tx_valid,                                        //            .valid
		output wire        avalon_st_tx_ready,                                        //            .ready
		input  wire [63:0] avalon_st_tx_data,                                         //            .data
		input  wire [2:0]  avalon_st_tx_empty,                                        //            .empty
		input  wire        avalon_st_tx_error,                                        //            .error
		output wire        avalon_st_txstatus_valid,                                  //avalon_st_txstatus.valid
		output wire [39:0] avalon_st_txstatus_data,                                   //                  .data
		output wire [6:0]  avalon_st_txstatus_error,                                  //                  .error
		output wire        avalon_st_rx_valid,                                        //avalon_st_rx.valid
		output wire [63:0] avalon_st_rx_data,                                         //            .data
		input  wire        avalon_st_rx_ready,                                        //            .ready
		output wire        avalon_st_rx_startofpacket,                                //            .startofpacket
		output wire        avalon_st_rx_endofpacket,                                  //            .endofpacket
		output wire [2:0]  avalon_st_rx_empty,                                        //            .empty
		output wire [5:0]  avalon_st_rx_error,                                        //            .error
		output wire        avalon_st_rxstatus_valid,                                  //avalon_st_rxstatus.valid
		output wire [6:0]  avalon_st_rxstatus_error,                                  //                  .error
		output wire [39:0] avalon_st_rxstatus_data,                                   //                  .data
		output wire [0:0]  tx_serial_data_export,                                     //tx_serial_data.export
		input  wire        rx_serial_data_export,                                     //rx_serial_data.export
		output wire        tx_ready_export,                                           //tx_ready.export
		output wire        rx_ready_export,                                           //rx_ready.export
		output wire [0:0]  rx_data_ready_export,                                      //rx_data_ready.export
		input  wire [1:0]  clock_operation_mode_mode,                                 //clock_operation_mode.mode
		input  wire        pkt_with_crc_mode,                                         //pkt_with_crc.mode
		input  wire        tx_egress_timestamp_request_valid,                         //egress_timestamp_request.valid
		input  wire [3:0]  tx_egress_timestamp_request_fingerprint,                  //                         .fingerprint
		input  wire        tx_estamp_ins_ctrl_residence_time_update,      // egress_timestamp_insertcontrol.residence_time_update
		input  wire [95:0] tx_estamp_ins_ctrl_ingress_timestamp_96b,      //                               .ingress_timestamp_96b
		input  wire [63:0] tx_estamp_ins_ctrl_ingress_timestamp_64b,      //                               .ingress_timestamp_64b
		input  wire        tx_estamp_ins_ctrl_residence_time_calc_format, //                               .residence_time_calc_format
		output wire        tx_egress_timestamp_96b_valid,                             //tx_egress_timestamp_96b.valid
		output wire [95:0] tx_egress_timestamp_96b_data,                              //                       .data
		output wire [3:0]  tx_egress_timestamp_96b_fingerprint,                       //                       .fingerprint
		output wire        tx_egress_timestamp_64b_valid,                             //tx_egress_timestamp_64b.valid
		output wire [63:0] tx_egress_timestamp_64b_data,                              //                       .data
		output wire [3:0]  tx_egress_timestamp_64b_fingerprint,                       //                       .fingerprint
		output wire        rx_ingress_timestamp_96b_valid,                            //rx_ingress_timestamp_96b.valid
		output wire [95:0] rx_ingress_timestamp_96b_data,                             //                        .data
		output wire        rx_ingress_timestamp_64b_valid,                            //rx_ingress_timestamp_64b.valid
		output wire [63:0] rx_ingress_timestamp_64b_data,                             //                        .data
		output wire [1:0]  link_fault_status_xgmii_rx_data,                           //link_fault_status_xgmii_rx.data
		input wire [1:0]   avalon_st_pause_data,                                      //avalon_st_pause.data
        output wire        pps_10g_out,
		//Port to do TOD synchronization
		input  wire [95:0] eth_1588_tod_time_of_day_96b_load_data, 
		input  wire        eth_1588_tod_time_of_day_96b_load_valid,
		input  wire [63:0] eth_1588_tod_time_of_day_64b_load_data, 
		input  wire        eth_1588_tod_time_of_day_64b_load_valid	
);

	wire            tx_clk_10g_clk;
	wire            rx_clk_10g_clk;
    wire            pps_clk;
	wire            tx_reset_10g_reset_n;
	wire            rx_reset_10g_reset_n;            
	wire            snyc_rstn;            
    wire            pps_reset;
	wire [95:0]     time_of_day_96b_data;           // From Time of Day
	wire [63:0]     time_of_day_64b_data;           // From Time of Day
	wire [95:0]     tx_time_of_day_96b_10g_data;    // To MAC
	wire [95:0]     rx_time_of_day_96b_10g_data;    // To MAC
	wire [63:0]     tx_time_of_day_64b_10g_data;    // To MAC
	wire [63:0]     rx_time_of_day_64b_10g_data;    // To MAC

    
    // Clock and reset
    altera_reset_synchronizer
    #(
        .DEPTH      (2),
        .ASYNC_RESET(1)
    )
    alt_eth_rst_sync
    (
        .clk        (xgmii_rx_clk_clk),
        .reset_in   (~ref_reset_reset_n),
        .reset_out  (snyc_rstn)
    );

    assign tx_clk_10g_clk = xgmii_rx_clk_clk;
    assign rx_clk_10g_clk = xgmii_rx_clk_clk;
    assign pps_clk        = xgmii_rx_clk_clk;
    assign tx_reset_10g_reset_n = ~snyc_rstn;
    assign rx_reset_10g_reset_n = ~snyc_rstn;   
    assign pps_reset            =  snyc_rstn;
    
    
    // Time of Day
    assign tx_time_of_day_96b_10g_data = time_of_day_96b_data;
    assign rx_time_of_day_96b_10g_data = time_of_day_96b_data;
    assign tx_time_of_day_64b_10g_data = time_of_day_64b_data;
    assign rx_time_of_day_64b_10g_data = time_of_day_64b_data;


    altera_eth_10g_mac_base_r_1588 eth_10g_mac_base_r_1588(
    .csr_clk_clk                        (csr_clk_clk),
    .ref_clk_clk                        (ref_clk_clk),
    .ref_reset_reset_n                  (ref_reset_reset_n),
    .tx_clk_10g_clk                     (tx_clk_10g_clk),
    .tx_reset_10g_reset_n               (tx_reset_10g_reset_n),
    .rx_clk_10g_clk                     (rx_clk_10g_clk),
    .rx_reset_10g_reset_n               (rx_reset_10g_reset_n),
    .xgmii_rx_clk_clk                   (xgmii_rx_clk_clk),
    .csr_reset_reset_n                  (csr_reset_reset_n),
    .csr_address                        (csr_address),
    .csr_waitrequest                    (csr_waitrequest),
    .csr_read                           (csr_read),
    .csr_readdata                       (csr_readdata),
    .csr_write                          (csr_write),
    .csr_writedata                      (csr_writedata),
    .avalon_st_tx_startofpacket         (avalon_st_tx_startofpacket),
    .avalon_st_tx_endofpacket           (avalon_st_tx_endofpacket),
    .avalon_st_tx_valid                 (avalon_st_tx_valid),
    .avalon_st_tx_ready                 (avalon_st_tx_ready),
    .avalon_st_tx_data                  (avalon_st_tx_data),
    .avalon_st_tx_empty                 (avalon_st_tx_empty),
    .avalon_st_tx_error                 (avalon_st_tx_error),
    .avalon_st_rx_valid                 (avalon_st_rx_valid),
    .avalon_st_rx_data                  (avalon_st_rx_data),
    .avalon_st_rx_ready                 (avalon_st_rx_ready),
    .avalon_st_txstatus_valid           (avalon_st_txstatus_valid),
    .avalon_st_txstatus_data            (avalon_st_txstatus_data),
    .avalon_st_txstatus_error           (avalon_st_txstatus_error),
    .avalon_st_rx_startofpacket         (avalon_st_rx_startofpacket),
    .avalon_st_rx_endofpacket           (avalon_st_rx_endofpacket),
    .avalon_st_rx_empty                 (avalon_st_rx_empty),
    .avalon_st_rx_error                 (avalon_st_rx_error),
    .avalon_st_rxstatus_valid           (avalon_st_rxstatus_valid),
    .avalon_st_rxstatus_error           (avalon_st_rxstatus_error),
    .avalon_st_rxstatus_data            (avalon_st_rxstatus_data),
    .tx_serial_data_export              (tx_serial_data_export),
    .rx_serial_data_export              (rx_serial_data_export),
    .tx_ready_export                    (tx_ready_export),
    .rx_ready_export                    (rx_ready_export),
    .rx_data_ready_export               (rx_data_ready_export),
    .time_of_day_96b_data               (time_of_day_96b_data),
    .time_of_day_64b_data               (time_of_day_64b_data),
    .tx_time_of_day_96b_10g_data        (tx_time_of_day_96b_10g_data),
    .tx_time_of_day_64b_10g_data        (tx_time_of_day_64b_10g_data),
    .rx_time_of_day_96b_10g_data        (rx_time_of_day_96b_10g_data),
    .rx_time_of_day_64b_10g_data        (rx_time_of_day_64b_10g_data),
	.eth_1588_tod_time_of_day_96b_load_data(eth_1588_tod_time_of_day_96b_load_data), 
	.eth_1588_tod_time_of_day_96b_load_valid(eth_1588_tod_time_of_day_96b_load_valid),
	.eth_1588_tod_time_of_day_64b_load_data(eth_1588_tod_time_of_day_64b_load_data), 
	.eth_1588_tod_time_of_day_64b_load_valid(eth_1588_tod_time_of_day_64b_load_valid),	
    .clock_operation_mode_mode                                      (clock_operation_mode_mode),
    .pkt_with_crc_mode                                              (pkt_with_crc_mode),
    .tx_egress_timestamp_request_valid                              (tx_egress_timestamp_request_valid),
    .tx_egress_timestamp_request_fingerprint                        (tx_egress_timestamp_request_fingerprint),
    .tx_etstamp_ins_ctrl_residence_time_update                      (tx_estamp_ins_ctrl_residence_time_update),
    .tx_etstamp_ins_ctrl_ingress_timestamp_96b                      (tx_estamp_ins_ctrl_ingress_timestamp_96b),
    .tx_etstamp_ins_ctrl_ingress_timestamp_64b                      (tx_estamp_ins_ctrl_ingress_timestamp_64b),
    .tx_etstamp_ins_ctrl_residence_time_calc_format                 (tx_estamp_ins_ctrl_residence_time_calc_format),
    .tx_egress_timestamp_96b_valid                                  (tx_egress_timestamp_96b_valid),
    .tx_egress_timestamp_96b_data                                   (tx_egress_timestamp_96b_data),
    .tx_egress_timestamp_96b_fingerprint                            (tx_egress_timestamp_96b_fingerprint),
    .tx_egress_timestamp_64b_valid                                  (tx_egress_timestamp_64b_valid),
    .tx_egress_timestamp_64b_data                                   (tx_egress_timestamp_64b_data),
    .tx_egress_timestamp_64b_fingerprint                            (tx_egress_timestamp_64b_fingerprint),
    .rx_ingress_timestamp_96b_valid                                 (rx_ingress_timestamp_96b_valid),
    .rx_ingress_timestamp_96b_data                                  (rx_ingress_timestamp_96b_data),
    .rx_ingress_timestamp_64b_valid                                 (rx_ingress_timestamp_64b_valid),
    .rx_ingress_timestamp_64b_data                                  (rx_ingress_timestamp_64b_data),
    .link_fault_status_xgmii_rx_data                                (link_fault_status_xgmii_rx_data),
    .avalon_st_pause_data                                           (avalon_st_pause_data)
);

    // 10ms requires  1562500 cycles for 156.25 MHz
    altera_eth_1588_pps #(
        .PULSE_CYCLE (1562500)
    ) pps_10g (
        .clk                (pps_clk),
        .reset              (pps_reset),
        .time_of_day_96b    (time_of_day_96b_data),
        .pulse_per_second   (pps_10g_out)
    );
    
endmodule
