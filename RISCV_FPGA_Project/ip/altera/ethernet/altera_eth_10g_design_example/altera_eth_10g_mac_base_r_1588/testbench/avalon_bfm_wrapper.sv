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


`ifndef AVALON_BFM_WRAPPER__SV
`define AVALON_BFM_WRAPPER__SV

`include "avalon_if_params_pkg.sv"

`timescale 1ns / 1ns

// Wrapper for Avalon-MM and Avalon-ST BFMs
module avalon_bfm_wrapper(
    avalon_mm_csr_clk,
    avalon_st_rx_clk,
    avalon_st_tx_clk,
    
    reset,
    
    avalon_mm_csr_address,
    avalon_mm_csr_read,
    avalon_mm_csr_readdata,
    avalon_mm_csr_write,
    avalon_mm_csr_writedata,
    avalon_mm_csr_waitrequest,
    avalon_mm_csr_readdatavalid,
    avalon_mm_csr_burstcount,
    avalon_mm_csr_byteenable,
    
    avalon_st_rx_startofpacket,
    avalon_st_rx_endofpacket,
    avalon_st_rx_valid,
    avalon_st_rx_ready,
    avalon_st_rx_data,
    avalon_st_rx_empty,
    avalon_st_rx_error,
    
    avalon_st_tx_startofpacket,
    avalon_st_tx_endofpacket,
    avalon_st_tx_valid,
    avalon_st_tx_ready,
    avalon_st_tx_data,
    avalon_st_tx_empty,
    avalon_st_tx_error,
	
	tx_egress_timestamp_request_valid,
	tx_egress_timestamp_request_fingerprint,
    
	tx_ingress_timestamp_valid,
	tx_ingress_timestamp_96b_data,
	tx_ingress_timestamp_64b_data,
	tx_ingress_timestamp_format	
);
    // Get the Avalon interface parameters definition from the package
    import avalon_if_params_pkt::*;
    
    input  wire                                     avalon_mm_csr_clk;
    input  wire                                     avalon_st_rx_clk;
    input  wire                                     avalon_st_tx_clk;
    
    input  wire                                     reset;
    
    output wire [AVALON_MM_CSR_AV_ADDRESS_W - 1:0]  avalon_mm_csr_address;
    output wire                                     avalon_mm_csr_read;
    input  wire [AVALON_MM_CSR_AV_DATA_W - 1:0]     avalon_mm_csr_readdata;
    output wire                                     avalon_mm_csr_write;
    output wire [AVALON_MM_CSR_AV_DATA_W - 1:0]     avalon_mm_csr_writedata;
    input  wire                                     avalon_mm_csr_waitrequest;
    input  wire                                     avalon_mm_csr_readdatavalid;
    input  wire [2:0]                               avalon_mm_csr_burstcount;
    input  wire [3:0]                               avalon_mm_csr_byteenable;
    
    input  wire                                     avalon_st_rx_startofpacket;
    input  wire                                     avalon_st_rx_endofpacket;
    input  wire                                     avalon_st_rx_valid;
    output wire                                     avalon_st_rx_ready;
    input  wire [AVALON_ST_RX_ST_DATA_W - 1:0]      avalon_st_rx_data;
    input  wire [AVALON_ST_RX_ST_EMPTY_W - 1:0]     avalon_st_rx_empty;
    input  wire [AVALON_ST_RX_ST_ERROR_W - 1:0]     avalon_st_rx_error;
    
    output wire                                     avalon_st_tx_startofpacket;
    output wire                                     avalon_st_tx_endofpacket;
    output wire                                     avalon_st_tx_valid;
    input  wire                                     avalon_st_tx_ready;
    output wire [AVALON_ST_TX_ST_DATA_W - 1:0]      avalon_st_tx_data;
    output wire [AVALON_ST_TX_ST_EMPTY_W - 1:0]     avalon_st_tx_empty;
    output wire [AVALON_ST_TX_ST_ERROR_W - 1:0]     avalon_st_tx_error;
	
    output wire                                     tx_egress_timestamp_request_valid;
    output wire [TIMESTAMP_FINGERPRINT_WIDTH-1:0]   tx_egress_timestamp_request_fingerprint;
    
    output wire                                     tx_ingress_timestamp_valid;
    output wire [TIMESTAMP_96B_WIDTH-1:0]           tx_ingress_timestamp_96b_data;
    output wire [TIMESTAMP_64B_WIDTH-1:0]           tx_ingress_timestamp_64b_data;
    output wire                                     tx_ingress_timestamp_format;
    
    
    
    // ******************************************************************************************
    // Avalon-MM CSR Interface
    // ******************************************************************************************
	
	logic tx_egress_timestamp_request_valid_int;
	logic tx_ingress_timestamp_valid_int;

	assign tx_egress_timestamp_request_valid = tx_egress_timestamp_request_valid_int & avalon_st_tx_startofpacket;
	assign tx_ingress_timestamp_valid = tx_ingress_timestamp_valid_int & avalon_st_tx_startofpacket;
    
    altera_avalon_mm_master_bfm #(

        .AV_ADDRESS_W               (AVALON_MM_CSR_AV_ADDRESS_W),
        .AV_SYMBOL_W                (AVALON_MM_CSR_AV_SYMBOL_W),
        .AV_NUMSYMBOLS              (AVALON_MM_CSR_AV_NUMSYMBOLS),
        .AV_BURSTCOUNT_W            (AVALON_MM_CSR_AV_BURSTCOUNT_W),
        
        .USE_READ                   (AVALON_MM_CSR_USE_READ),
        .USE_WRITE                  (AVALON_MM_CSR_USE_WRITE),
        .USE_ADDRESS                (AVALON_MM_CSR_USE_ADDRESS),
        .USE_BYTE_ENABLE            (AVALON_MM_CSR_USE_BYTE_ENABLE),
        .USE_BURSTCOUNT             (AVALON_MM_CSR_USE_BURSTCOUNT),
        .USE_READ_DATA              (AVALON_MM_CSR_USE_READ_DATA),
        .USE_READ_DATA_VALID        (AVALON_MM_CSR_USE_READ_DATA_VALID),
        .USE_WRITE_DATA             (AVALON_MM_CSR_USE_WRITE_DATA),
        .USE_BEGIN_TRANSFER         (AVALON_MM_CSR_USE_BEGIN_TRANSFER),
        .USE_BEGIN_BURST_TRANSFER   (AVALON_MM_CSR_USE_BEGIN_BURST_TRANSFER),
        .USE_WAIT_REQUEST           (AVALON_MM_CSR_USE_WAIT_REQUEST),

        .AV_FIX_READ_LATENCY        (AVALON_MM_CSR_AV_FIX_READ_LATENCY),
        .AV_MAX_PENDING_READS       (AVALON_MM_CSR_AV_MAX_PENDING_READS),
        
        .AV_BURST_LINEWRAP          (AVALON_MM_CSR_AV_BURST_LINEWRAP),
        .AV_BURST_BNDR_ONLY         (AVALON_MM_CSR_AV_BURST_BNDR_ONLY)
    )
    avalon_mm_csr_bfm (
	    .clk                        (avalon_mm_csr_clk), 
		.reset                      (reset),
        .avm_waitrequest            (avalon_mm_csr_waitrequest),
        .avm_write                  (avalon_mm_csr_write),
        .avm_read                   (avalon_mm_csr_read),
        .avm_address                (avalon_mm_csr_address),
        .avm_byteenable             (avalon_mm_csr_byteenable),
        .avm_burstcount             (avalon_mm_csr_burstcount),
        .avm_writedata              (avalon_mm_csr_writedata),
        .avm_beginbursttransfer     (),
        .avm_begintransfer          (), 
        .avm_readdata               (avalon_mm_csr_readdata),
        .avm_readdatavalid          (avalon_mm_csr_readdatavalid),
        .avm_arbiterlock            (),
        .avm_debugaccess            (),
        .avm_transactionid          (),
        .avm_readresponse           (),
        .avm_readid                 (),
        .avm_writeresponserequest   (),
        .avm_writeresponsevalid     (),
        .avm_writeresponse          (),
        .avm_writeid                ()
    );
    
    
    
    // ******************************************************************************************
    // Avalon-ST RX Interface
    // ******************************************************************************************
    
    altera_avalon_st_sink_bfm #(
        .ST_SYMBOL_W            (AVALON_ST_RX_ST_SYMBOL_W),
        .ST_NUMSYMBOLS          (AVALON_ST_RX_ST_NUMSYMBOLS),
        .ST_CHANNEL_W           (AVALON_ST_RX_ST_CHANNEL_W),
        .ST_ERROR_W             (AVALON_ST_RX_ST_ERROR_W),
        .ST_EMPTY_W             (AVALON_ST_RX_ST_EMPTY_W),
        
        .ST_READY_LATENCY       (AVALON_ST_RX_ST_READY_LATENCY),
        .ST_MAX_CHANNELS        (AVALON_ST_RX_ST_MAX_CHANNELS),
        
        .USE_PACKET             (AVALON_ST_RX_USE_PACKET),
        .USE_CHANNEL            (AVALON_ST_RX_USE_CHANNEL), 
        .USE_ERROR              (AVALON_ST_RX_USE_ERROR),
        .USE_READY              (AVALON_ST_RX_USE_READY),
        .USE_VALID              (AVALON_ST_RX_USE_VALID),
        .USE_EMPTY              (AVALON_ST_RX_USE_EMPTY)
    )
    avalon_st_rx_bfm (
        .clk                    (avalon_st_rx_clk),
        .reset                  (reset),
        
        .sink_data              (avalon_st_rx_data),
        .sink_channel           (),
        .sink_valid             (avalon_st_rx_valid),
        .sink_startofpacket     (avalon_st_rx_startofpacket),
        .sink_endofpacket       (avalon_st_rx_endofpacket),
        .sink_error             (avalon_st_rx_error),
        .sink_empty             (avalon_st_rx_empty),
        .sink_ready             (avalon_st_rx_ready)
    );
    
 
	// ******************************************************************************************
    // Avalon-ST TX Interface
    // ******************************************************************************************
    
    altera_avalon_st_source_bfm #(
        .ST_SYMBOL_W            (AVALON_ST_TX_ST_SYMBOL_W),
        .ST_NUMSYMBOLS          (AVALON_ST_TX_ST_NUMSYMBOLS),
        .ST_CHANNEL_W           (AVALON_ST_TX_ST_CHANNEL_W),
        .ST_ERROR_W             (AVALON_ST_TX_ST_ERROR_W),
        .ST_EMPTY_W             (AVALON_ST_TX_ST_EMPTY_W),
        
        .ST_READY_LATENCY       (AVALON_ST_TX_ST_READY_LATENCY),
        .ST_MAX_CHANNELS        (AVALON_ST_TX_ST_MAX_CHANNELS),
        
        .USE_PACKET             (AVALON_ST_TX_USE_PACKET),
        .USE_CHANNEL            (AVALON_ST_TX_USE_CHANNEL), 
        .USE_ERROR              (AVALON_ST_TX_USE_ERROR),
        .USE_READY              (AVALON_ST_TX_USE_READY),
        .USE_VALID              (AVALON_ST_TX_USE_VALID),
        .USE_EMPTY              (AVALON_ST_TX_USE_EMPTY)
    )
    avalon_st_tx_bfm (
        .clk                    (avalon_st_tx_clk),
        .reset                  (reset),
        
        .src_data               (avalon_st_tx_data),
        .src_channel            (),
        .src_valid              (avalon_st_tx_valid),
        .src_startofpacket      (avalon_st_tx_startofpacket),
        .src_endofpacket        (avalon_st_tx_endofpacket),
        .src_error              (avalon_st_tx_error),
        .src_empty              (avalon_st_tx_empty),
        .src_ready              (avalon_st_tx_ready)
    ); 
    
    // ******************************************************************************************
    // TX Timestamp Request Interface
    // ******************************************************************************************
    
    altera_avalon_st_source_bfm #(
        .ST_SYMBOL_W            (TX_EGRESS_TIMESTAMP_REQUEST_ST_SYMBOL_W),
        .ST_NUMSYMBOLS          (TX_EGRESS_TIMESTAMP_REQUEST_ST_NUMSYMBOLS),
        .ST_CHANNEL_W           (TX_EGRESS_TIMESTAMP_REQUEST_ST_CHANNEL_W),
        .ST_ERROR_W             (TX_EGRESS_TIMESTAMP_REQUEST_ST_ERROR_W),
        .ST_EMPTY_W             (TX_EGRESS_TIMESTAMP_REQUEST_ST_EMPTY_W),
        
        .ST_READY_LATENCY       (TX_EGRESS_TIMESTAMP_REQUEST_ST_READY_LATENCY),
        .ST_MAX_CHANNELS        (TX_EGRESS_TIMESTAMP_REQUEST_ST_MAX_CHANNELS),
        
        .USE_PACKET             (TX_EGRESS_TIMESTAMP_REQUEST_USE_PACKET),
        .USE_CHANNEL            (TX_EGRESS_TIMESTAMP_REQUEST_USE_CHANNEL), 
        .USE_ERROR              (TX_EGRESS_TIMESTAMP_REQUEST_USE_ERROR),
        .USE_READY              (TX_EGRESS_TIMESTAMP_REQUEST_USE_READY),
        .USE_VALID              (TX_EGRESS_TIMESTAMP_REQUEST_USE_VALID),
        .USE_EMPTY              (TX_EGRESS_TIMESTAMP_REQUEST_USE_EMPTY)
    )
    avalon_st_tx_tstamp_req_bfm (
        .clk                    (avalon_st_tx_clk),
        .reset                  (reset),
        
        .src_data               ({tx_egress_timestamp_request_valid_int,tx_egress_timestamp_request_fingerprint}),
        .src_channel            (),
        .src_valid              (),
        .src_startofpacket      (),
        .src_endofpacket        (),
        .src_error              (),
        .src_empty              (),
        .src_ready              (avalon_st_tx_ready)
    );


    // ******************************************************************************************
    // TX Ingress Timestamp Interface
    // ******************************************************************************************
    
    altera_avalon_st_source_bfm #(
        .ST_SYMBOL_W            (TX_INGRESS_TIMESTAMP_ST_SYMBOL_W),
        .ST_NUMSYMBOLS          (TX_INGRESS_TIMESTAMP_ST_NUMSYMBOLS),
        .ST_CHANNEL_W           (TX_INGRESS_TIMESTAMP_ST_CHANNEL_W),
        .ST_ERROR_W             (TX_INGRESS_TIMESTAMP_ST_ERROR_W),
        .ST_EMPTY_W             (TX_INGRESS_TIMESTAMP_ST_EMPTY_W),
        
        .ST_READY_LATENCY       (TX_INGRESS_TIMESTAMP_ST_READY_LATENCY),
        .ST_MAX_CHANNELS        (TX_INGRESS_TIMESTAMP_ST_MAX_CHANNELS),
        
        .USE_PACKET             (TX_INGRESS_TIMESTAMP_USE_PACKET),
        .USE_CHANNEL            (TX_INGRESS_TIMESTAMP_USE_CHANNEL), 
        .USE_ERROR              (TX_INGRESS_TIMESTAMP_USE_ERROR),
        .USE_READY              (TX_INGRESS_TIMESTAMP_USE_READY),
        .USE_VALID              (TX_INGRESS_TIMESTAMP_USE_VALID),
        .USE_EMPTY              (TX_INGRESS_TIMESTAMP_USE_EMPTY)
    )
    avalon_st_tx_tstamp_bfm (
        .clk                    (avalon_st_tx_clk),
        .reset                  (reset),
        
        .src_data               ({tx_ingress_timestamp_valid_int,tx_ingress_timestamp_96b_data,tx_ingress_timestamp_64b_data,tx_ingress_timestamp_format}),
        .src_channel            (),
        .src_valid              (),
        .src_startofpacket      (),
        .src_endofpacket        (),
        .src_error              (),
        .src_empty              (),
        .src_ready              (avalon_st_tx_ready)
    );

endmodule

`endif
