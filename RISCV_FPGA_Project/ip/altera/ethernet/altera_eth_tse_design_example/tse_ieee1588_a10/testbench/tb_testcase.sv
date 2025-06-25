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


`ifndef TB_TESTCASE_SV
`define TB_TESTCASE_SV

`include "default_test_params_pkg.sv"
`include "eth_mac_frame.sv"
`include "avalon_if_params_pkg.sv"

`timescale 1ps / 1ps

    
// Test case specific testbench
module tb_testcase(
    input clk,
    input reset
    );
    
    
    
	parameter TX_INGRESS_TIMESTAMP_96B_DATA     = 96'h000000000000_00000000_0012;
	parameter TX_INGRESS_TIMESTAMP_64B_DATA     = 64'h000000000000_0034;


    // Parameter for test flow
    parameter PCS_READY_DELAY_CYCLE = 10000;	
	
	
	// Get the register map definition from the package
    import eth_register_map_params_pkg::*;
	
	//Get test parameter from the package
	import default_test_params_pkt::*;

    // Get the Avalon interface parameters definition from the package
    import avalon_if_params_pkt::*;
    
    
    
    initial begin
        
        // Configure DUT
        tb_top.configure_csr_basic;
        tb_top.configure_tod;
        
        // Configure to Ordinary Clock Mode
		tb_top.configure_csr_1588(ORDINARY_CLOCK,4'h8,16'h0,16'h0,16'h0,16'h0,16'h0);
		        
        // Add delay before sending packets, wait until PCS is ready
        repeat (PCS_READY_DELAY_CYCLE) @ (posedge clk);        
        
        
        
        // Send Ethernet packet through Avalon-ST TX path
        // Packet Type:
        //      - No VLAN
        //      - PTP over Ethernet
        //      - PTP Sync Message
        //      - 1-step PTP Packet
        // 2-step Operation:
        //      - Request egress timestamp
        // 1-step Operation:
        //      - No correction field update
        // Expected Result:
        //      - Return egress timestamp
        //      - Timestamp inserted into timestamp field
        //      - Correction field inserted with fractional nanosecond of egress timestamp
        tb_top.U_AVALON_DRIVER.avalon_st_transmit_ptp_frame_universal(
            .dest_addr                              (MAC_ADDR),
            .src_addr                               (MAC_ADDR),
            .vlan_tag                               (NO_VLAN),
            .length_type                            (LENGTH_TYPE_PTP),
            .ip_protocol                            (PROTOCOL_UDP),
            .udp_port                               (UDP_PORT_PTP_EVENT),
            .ptp_message_type                       (MSG_SYNC), 
            .ptp_two_step_flag                      (PTP_ONE_STEP),
            .insert_pad                             (INSERT_PAD),
            .insert_crc                             (INSERT_CRC),
            .egress_timestamp_request_valid         (1'b1),
            .egress_timestamp_request_fingerprint   (0),
            .ingress_timestamp_valid                (1'b0),
            .ingress_timestamp_96b                  (TX_INGRESS_TIMESTAMP_96B_DATA),
            .ingress_timestamp_64b                  (TX_INGRESS_TIMESTAMP_64B_DATA),
            .ingress_timestamp_format               (PTP_TIMESTAMP_FORMAT_96B)
        );
        
        repeat (200) @ (posedge clk);
        
        
        
        // Packet Type:
        //      - VLAN
        //      - PTP over UDP/IPv4
        //      - PTP Sync Message
        //      - 1-step PTP Packet
        // 2-step Operation:
        //      - Request egress timestamp
        // 1-step Operation:
        //      - No correction field update
        // Expected Result:
        //      - Return egress timestamp
        //      - Timestamp inserted into timestamp field
        //      - Correction field inserted with fractional nanosecond of egress timestamp
        tb_top.U_AVALON_DRIVER.avalon_st_transmit_ptp_frame_universal(
            .dest_addr                              (MAC_ADDR),
            .src_addr                               (MAC_ADDR),
            .vlan_tag                               (VLAN),
            .length_type                            (LENGTH_TYPE_IPV4),
            .ip_protocol                            (PROTOCOL_UDP),
            .udp_port                               (UDP_PORT_PTP_EVENT),
            .ptp_message_type                       (MSG_SYNC), 
            .ptp_two_step_flag                      (PTP_ONE_STEP),
            .insert_pad                             (INSERT_PAD),
            .insert_crc                             (INSERT_CRC),
            .egress_timestamp_request_valid         (1'b1),
            .egress_timestamp_request_fingerprint   (1),
            .ingress_timestamp_valid                (1'b0),
            .ingress_timestamp_96b                  (TX_INGRESS_TIMESTAMP_96B_DATA),
            .ingress_timestamp_64b                  (TX_INGRESS_TIMESTAMP_64B_DATA),
            .ingress_timestamp_format               (PTP_TIMESTAMP_FORMAT_96B)
        );
        
        repeat (200) @ (posedge clk);	
        
        
        
        // Packet Type:
        //      - Stacked VLAN
        //      - PTP over UDP/IPv6
        //      - PTP Sync Message
        //      - 2-step PTP Packet
        // 2-step Operation:
        //      - Request egress timestamp
        // 1-step Operation:
        //      - No correction field update
        // Expected Result:
        //      - Return egress timestamp
        //      - No change to timestamp field
        //      - No change to correction field
        tb_top.U_AVALON_DRIVER.avalon_st_transmit_ptp_frame_universal(
            .dest_addr                              (MAC_ADDR),
            .src_addr                               (MAC_ADDR),
            .vlan_tag                               (STACK_VLAN),
            .length_type                            (LENGTH_TYPE_IPV6),
            .ip_protocol                            (PROTOCOL_UDP),
            .udp_port                               (UDP_PORT_PTP_EVENT),
            .ptp_message_type                       (MSG_SYNC), 
            .ptp_two_step_flag                      (PTP_TWO_STEP),
            .insert_pad                             (INSERT_PAD),
            .insert_crc                             (INSERT_CRC),
            .egress_timestamp_request_valid         (1'b1),
            .egress_timestamp_request_fingerprint   (2),
            .ingress_timestamp_valid                (1'b0),
            .ingress_timestamp_96b                  (TX_INGRESS_TIMESTAMP_96B_DATA),
            .ingress_timestamp_64b                  (TX_INGRESS_TIMESTAMP_64B_DATA),
            .ingress_timestamp_format               (PTP_TIMESTAMP_FORMAT_96B)
        );
        
        repeat (400) @ (posedge clk);		
        
        
        
        // Configure to End-to-end Transparent Clock Mode
		tb_top.configure_csr_1588(E2E_TRANSPARENT_CLOCK,4'h8,16'h0,16'h0,16'h0,16'h0,16'h0);	
        
        // Add delay before sending packets, wait until PCS is ready
        repeat (200) @ (posedge clk);        
        
        // Send Ethernet packet through Avalon-ST TX path
        // Packet Type:
        //      - No VLAN
        //      - PTP over Ethernet
        //      - PTP Sync Message
        //      - 1-step PTP Packet
        // 2-step Operation:
        //      - No request egress timestamp
        // 1-step Operation:
        //      - Correction field update (96-bits)
        // Expected Result:
        //      - No return egress timestamp
        //      - No change to timestamp field
        //      - Correction field updated with residence time
        tb_top.U_AVALON_DRIVER.avalon_st_transmit_ptp_frame_universal(
            .dest_addr                              (MAC_ADDR),
            .src_addr                               (MAC_ADDR),
            .vlan_tag                               (NO_VLAN),
            .length_type                            (LENGTH_TYPE_PTP),
            .ip_protocol                            (PROTOCOL_UDP),
            .udp_port                               (UDP_PORT_PTP_EVENT),
            .ptp_message_type                       (MSG_SYNC), 
            .ptp_two_step_flag                      (PTP_ONE_STEP),
            .insert_pad                             (INSERT_PAD),
            .insert_crc                             (INSERT_CRC),
            .egress_timestamp_request_valid         (1'b0),
            .egress_timestamp_request_fingerprint   (3),
            .ingress_timestamp_valid                (1'b1),
            .ingress_timestamp_96b                  (TX_INGRESS_TIMESTAMP_96B_DATA),
            .ingress_timestamp_64b                  (TX_INGRESS_TIMESTAMP_64B_DATA),
            .ingress_timestamp_format               (PTP_TIMESTAMP_FORMAT_96B)
        );
        
        repeat (200) @ (posedge clk);
        
        
        
        // Packet Type:
        //      - VLAN
        //      - PTP over UDP/IPv4
        //      - PTP Sync Message
        //      - 2-step PTP Packet
        // 2-step Operation:
        //      - Request egress timestamp
        // 1-step Operation:
        //      - Correction field update (96-bits)
        // Expected Result:
        //      - Return egress timestamp
        //      - No change to timestamp field
        //      - Correction field updated with residence time
        tb_top.U_AVALON_DRIVER.avalon_st_transmit_ptp_frame_universal(
            .dest_addr                              (MAC_ADDR),
            .src_addr                               (MAC_ADDR),
            .vlan_tag                               (VLAN),
            .length_type                            (LENGTH_TYPE_IPV4),
            .ip_protocol                            (PROTOCOL_UDP),
            .udp_port                               (UDP_PORT_PTP_EVENT),
            .ptp_message_type                       (MSG_SYNC), 
            .ptp_two_step_flag                      (PTP_TWO_STEP),
            .insert_pad                             (INSERT_PAD),
            .insert_crc                             (INSERT_CRC),
            .egress_timestamp_request_valid         (1'b1),
            .egress_timestamp_request_fingerprint   (4),
            .ingress_timestamp_valid                (1'b1),
            .ingress_timestamp_96b                  (TX_INGRESS_TIMESTAMP_96B_DATA),
            .ingress_timestamp_64b                  (TX_INGRESS_TIMESTAMP_64B_DATA),
            .ingress_timestamp_format               (PTP_TIMESTAMP_FORMAT_96B)
        );
        
        repeat (200) @ (posedge clk);	
        
        
        
        // Packet Type:
        //      - Stacked VLAN
        //      - PTP over UDP/IPv6
        //      - PTP Sync Message
        //      - 1-step PTP Packet
        // 2-step Operation:
        //      - Request egress timestamp
        // 1-step Operation:
        //      - Correction field update (64-bits)
        // Expected Result:
        //      - Return egress timestamp
        //      - No change to timestamp field
        //      - Correction field updated with residence time
        tb_top.U_AVALON_DRIVER.avalon_st_transmit_ptp_frame_universal(
            .dest_addr                              (MAC_ADDR),
            .src_addr                               (MAC_ADDR),
            .vlan_tag                               (STACK_VLAN),
            .length_type                            (LENGTH_TYPE_IPV6),
            .ip_protocol                            (PROTOCOL_UDP),
            .udp_port                               (UDP_PORT_PTP_EVENT),
            .ptp_message_type                       (MSG_SYNC), 
            .ptp_two_step_flag                      (PTP_ONE_STEP),
            .insert_pad                             (INSERT_PAD),
            .insert_crc                             (INSERT_CRC),
            .egress_timestamp_request_valid         (1'b1),
            .egress_timestamp_request_fingerprint   (5),
            .ingress_timestamp_valid                (1'b0),
            .ingress_timestamp_96b                  (TX_INGRESS_TIMESTAMP_96B_DATA),
            .ingress_timestamp_64b                  (TX_INGRESS_TIMESTAMP_64B_DATA),
            .ingress_timestamp_format               (PTP_TIMESTAMP_FORMAT_64B)
        );
        
        repeat (200) @ (posedge clk);
        
        
        
        // Add delay before sending packets, wait until PCS is ready
        repeat(1000) @(posedge clk);
        
        if (tb_top.source_num_frame == tb_top.sink_num_frame) begin
            $display("\n\nSimulation PASSED\n");
        end else begin
            $display("\n\nSimulation FAILED\n");
        end
        
        
        $finish();
    end    
    
endmodule

`endif
