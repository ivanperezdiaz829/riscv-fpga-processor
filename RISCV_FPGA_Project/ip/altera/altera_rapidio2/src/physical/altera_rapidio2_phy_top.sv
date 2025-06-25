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


import altera_rapidio2_phy_pkg::*;
// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on

module altera_rapidio2_phy_top
#( 
   parameter DEVICE_FAMILY = "Stratix V",
   parameter logic SUPPORT_2X = 1'd1,
   parameter logic SUPPORT_4X = 1'd1,
   parameter logic SUPPORT_1X = 1'd1,
   parameter logic [31:0]MAX_BAUD_RATE = 6250,
   parameter integer REF_CLK_PERIOD = 6400, // altera_rapidio2_crm
   parameter integer LSIZE = ( SUPPORT_4X ) ? 4 : (( SUPPORT_2X )? 2 : 1 ),
   parameter integer DSIZE = 32*LSIZE, // total parallel data size in all working lanes.
   parameter integer CSIZE = 4*LSIZE
 )
 (
   input  logic         rst_n,
   input  logic         clk,
   input  logic         tx_clk,
   input  logic         tx_clk_rst_n,
   input  logic         milisecond,
   input  logic         ten_microsecond,

   // Standard registers interfaces
   altera_rapidio2_avalon_mm_if.general_slave          av_mm_s,
   altera_rapidio2_lp_serial_registers        lp_serial,
   altera_rapidio2_lp_serial_lane_n_registers lp_serial_lane_0,
   altera_rapidio2_lp_serial_lane_n_registers lp_serial_lane_1,
   altera_rapidio2_lp_serial_lane_n_registers lp_serial_lane_2,
   altera_rapidio2_lp_serial_lane_n_registers lp_serial_lane_3,
   altera_rapidio2_error_management_registers error_management,
   // ---------------------------------------------------------------------
   // PHY-1 sublayer 
   // ---------------------------------------------------------------------

   // -------------------------------------------------------------------------
   // PHY-2 sublayer
   // -------------------------------------------------------------------------
   //Interface between RX_top and Transport layer
   output logic [1:0]   phy_rx_start_of_packet,
   output logic [1:0]   phy_rx_end_of_packet,
   output logic [1:0]   phy_rx_error,
   output logic [1:0]   phy_rx_empty,
   output logic [1:0]   phy_rx_valid,
   output logic [127:0] phy_rx_data,
   input  logic [3:0]   phy_rx_retry,
   // External interface from tx side, IOs from top level
   output logic         link_initialized,
   output logic         port_initialized,
   output logic         multicast_event_rx,
   input  logic         send_multicast_event,
   input  logic         send_link_request_reset_device,
   output logic         sent_multicast_event,
   output logic         sent_link_request_reset_device,
   output logic         sent_link_request_input_status,
   output logic         sent_restart_from_retry,
   output logic         link_req_reset_device_received,
   output logic         status_sent,
   output logic         sent_packet_accepted,
   output logic         sent_packet_retry,
   output logic         sent_packet_not_accepted,
   output logic         sent_link_response,
   output logic         sent_start_of_packet,
   output logic         packet_cancelled,
   output logic         packet_accepted_cs_received,  // need to connect,rx                   
   output logic         packet_retry_cs_received,  // need to connect,rx                  
   output logic         packet_not_accepted_cs_received,// need to connect,rx
   output logic         packet_crc_error,   // need to connect, rx                  
   output logic         control_symbol_error,   // need to connect,rx
   // -------------------------------------------------------------------------
   // PHY-3 sublayer
   // -------------------------------------------------------------------------
   //TX Transport interface 
   input  logic [127:0] phy_tx_data_in,
   input  logic         phy_tx_startofpacket,    
   input  logic         phy_tx_endofpacket,   
   input  logic [3:0]   phy_tx_empty,   
   input  logic [8:0]   phy_tx_pkt_size,  
   input  logic         phy_tx_data_valid,   
   output logic [3:0]   phy_tx_retry,
   // external interface
   output logic packet_dropped,
   // -------------------------------------------------------------------------
   // PHY IP
   // -------------------------------------------------------------------------
   input logic               tx_ready,// from external transceiver reset controller
   input logic               four_lanes_aligned,
   input logic               two_lanes_aligned,
   input logic [3:0]         rx_datak0,
   input logic [31:0]        rx_parallel_data0,
   input logic [3:0]         rx_datak1,
   input logic [31:0]        rx_parallel_data1,
   input logic [3:0]         rx_datak2,
   input logic [31:0]        rx_parallel_data2,
   input logic [3:0]         rx_datak3,
   input logic [31:0]        rx_parallel_data3,
   input logic  [LSIZE-1:0]  rx_syncstatus, //rx_clkout domain, from altera_rapidio2_soft_pcs module.
   input logic  [CSIZE-1:0]  rx_dataerr,
   output logic              port_error_out,
   output logic              port_ok_out, 
   output logic [3:0]        force_electrical_idle,
   output logic [3:0]        tx_datak0,
   output logic [31:0]       tx_parallel_data0,
   output logic [3:0]        tx_datak1,
   output logic [31:0]       tx_parallel_data1,
   output logic [3:0]        tx_datak2,
   output logic [31:0]       tx_parallel_data2,
   output logic [3:0]        tx_datak3,
   output logic [31:0]       tx_parallel_data3
  );

// ----------------------------------------------------------------------------
// Declarations
// ----------------------------------------------------------------------------
   logic [15:0] rx_disperr;//rx_dataerr
   logic [15:0] rx_detecterr;//rx_dataerr

   logic two_lanes_aligned_hard;//clk domain
   logic four_lanes_aligned_hard;//clk domain

   logic [LSIZE-1:0] rx_syncstatus_hard;//clk domain
   logic [3:0] rx_syncstatus_int;//clk domain
   logic [15:0] rx_dataerr_int;

   assign rx_syncstatus_int = { {4-LSIZE{1'b0}},rx_syncstatus_hard };
   assign rx_dataerr_int = {{16-CSIZE{1'b0}},rx_dataerr};

   assign port_error_out = lp_serial.port_0_error_and_status_csr.port_error;
   assign port_ok_out = lp_serial.port_0_error_and_status_csr.port_ok;

   logic             tx_ready_sys_clk;
   logic             tx_ready_tx_clk;

// ----------------------------------------------------------------------------
// Synchronizer
// ----------------------------------------------------------------------------
   // Signal tx_ready synchronizer to tx_clk domain
    altera_std_synchronizer tx_ready_meta_sync_2 (
        .clk(tx_clk), 
        .reset_n(tx_clk_rst_n), 
        .din(tx_ready), 
        .dout(tx_ready_tx_clk)
    );

   // Signal tx_ready synchronizer
    altera_std_synchronizer tx_ready_meta_sync_1 (
        .clk(clk), 
        .reset_n(rst_n), 
        .din(tx_ready), 
        .dout(tx_ready_sys_clk)
    );

   // Signal lane_sync synchronizer
    altera_std_synchronizer_bundle lanes_sync_meta_sync (
        .clk(clk), 
        .reset_n(rst_n), 
        .din(rx_syncstatus), 
        .dout(rx_syncstatus_hard)
    );
    defparam lanes_sync_meta_sync.width = LSIZE;

    // Signal two_lanes_aligned synchronizer
     altera_std_synchronizer two_lanes_aligned_meta_sync (
        .clk(clk), 
        .reset_n(rst_n), 
        .din(two_lanes_aligned), 
        .dout(two_lanes_aligned_hard)
    );
    
    // Signal four_lanes_aligned synchronizer
    altera_std_synchronizer four_lanes_aligned_meta_sync (
        .clk(clk), 
        .reset_n(rst_n), 
        .din(four_lanes_aligned), 
        .dout(four_lanes_aligned_hard)
    );
  // End of synchronizer instantiation

altera_rapidio2_physical_layer
  #( 
    .DEVICE_FAMILY(DEVICE_FAMILY),
    .SUPPORT_2X(SUPPORT_2X),
    .SUPPORT_4X(SUPPORT_4X),
    .SUPPORT_1X   (SUPPORT_1X),
    .MAX_BAUD_RATE(MAX_BAUD_RATE),
    .REF_CLK_PERIOD(REF_CLK_PERIOD),
    .LSIZE(LSIZE)) altera_rapidio2_physical_layer (
    .rst_n(rst_n),
    .clk(clk),
    .tx_clk(tx_clk),
    .milisecond(milisecond),
    .ten_microsecond(ten_microsecond),
    // Standard registers interfaces
    .av_mm_s(av_mm_s),
    .lp_serial(lp_serial),
    .lp_serial_lane_0(lp_serial_lane_0),
    .lp_serial_lane_1(lp_serial_lane_1),
    .lp_serial_lane_2(lp_serial_lane_2),
    .lp_serial_lane_3(lp_serial_lane_3),
    .error_management(error_management),
    // ---------------------------------------------------------------------
    // PHY-1 sublayer 
    // ---------------------------------------------------------------------
    // Interface from tx_dcfifo to PHY IP transceiver
    .tx_datak0(tx_datak0),
    .tx_parallel_data0(tx_parallel_data0),
    .tx_datak1(tx_datak1),
    .tx_parallel_data1(tx_parallel_data1),
    .tx_datak2(tx_datak2),
    .tx_parallel_data2(tx_parallel_data2),
    .tx_datak3(tx_datak3),
    .tx_parallel_data3(tx_parallel_data3),
    // Interface from transceiver to rx_dcfifo
    .xcvr_rst_n(tx_ready_tx_clk),//tx_clk domain
    .rx_datak0(rx_datak0),
    .rx_parallel_data0(rx_parallel_data0),
    .rx_datak1(rx_datak1),
    .rx_parallel_data1(rx_parallel_data1),
    .rx_datak2(rx_datak2),
    .rx_parallel_data2(rx_parallel_data2),
    .rx_datak3(rx_datak3),
    .rx_parallel_data3(rx_parallel_data3),
    .rx_disperr(rx_dataerr_int),
    .rx_detecterr(rx_dataerr_int),
    .rx_syncstatus(rx_syncstatus_int),//clk domain //rx_syncstatus[0] for lp_serial_lane_0, rx_syncstatus[1] for lane 1, etc. 
    .four_lanes_aligned(four_lanes_aligned_hard),//clk domain 
    .two_lanes_aligned(two_lanes_aligned_hard),//clk domain

    // -------------------------------------------------------------------------
    // PHY-2 sublayer
    // -------------------------------------------------------------------------
    //Interface between RX_top and Transport layer
    .phy_rx_start_of_packet(phy_rx_start_of_packet),
    .phy_rx_end_of_packet(phy_rx_end_of_packet),
    .phy_rx_error(phy_rx_error),
    .phy_rx_empty(phy_rx_empty),
    .phy_rx_valid(phy_rx_valid),
    .phy_rx_data(phy_rx_data),
    .phy_rx_retry(phy_rx_retry),
    // External interface from tx side, IOs from top level
    .link_initialized(link_initialized),
    .port_initialized(port_initialized),
    .multicast_event_rx(multicast_event_rx),
    .send_multicast_event(send_multicast_event),
    .send_link_request_reset_device(send_link_request_reset_device),
    .sent_multicast_event(sent_multicast_event),
    .sent_link_request_reset_device(sent_link_request_reset_device),
    .sent_link_request_input_status(sent_link_request_input_status),
    .sent_restart_from_retry(sent_restart_from_retry),
    .link_req_reset_device_received(link_req_reset_device_received),
    .status_sent(status_sent),
    .sent_packet_accepted(sent_packet_accepted),
    .sent_packet_retry(sent_packet_retry),
    .sent_packet_not_accepted(sent_packet_not_accepted),
    .sent_link_response(sent_link_response),
    .sent_start_of_packet(sent_start_of_packet),
    .packet_cancelled(packet_cancelled),
    .packet_accepted_cs_received(packet_accepted_cs_received),  // need to connect,rx                   
    .packet_retry_cs_received(packet_retry_cs_received),  // need to connect,rx                  
    .packet_not_accepted_cs_received(packet_not_accepted_cs_received),// need to connect,rx
    .packet_crc_error(packet_crc_error),   // need to connect, rx                  
    .control_symbol_error(control_symbol_error),   // need to connect,rx
    .xcvr_tx_ready(tx_ready_sys_clk),//clk domain
    // -------------------------------------------------------------------------
    // PHY-3 sublayer
    // -------------------------------------------------------------------------
    //TX Transport interface 
    .phy_tx_data_in(phy_tx_data_in),
    .phy_tx_startofpacket(phy_tx_startofpacket),    
    .phy_tx_endofpacket(phy_tx_endofpacket),   
    .phy_tx_empty(phy_tx_empty),   
    .phy_tx_pkt_size(phy_tx_pkt_size),  
    .phy_tx_data_valid(phy_tx_data_valid),   
    .phy_tx_retry(phy_tx_retry),
    // external interface
    .packet_dropped(packet_dropped),
    // -------------------------------------------------------------------------
    // XCVR Controller interface - to compute force_electrical_idle only
    // -------------------------------------------------------------------------
    .force_electrical_idle(force_electrical_idle)
    );

endmodule
