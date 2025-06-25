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


`ifndef TB__SV
`define TB__SV

`include "eth_register_map_params_pkg.sv"
`include "avalon_driver.sv"
`include "avalon_st_eth_packet_monitor.sv"

`timescale 1ps / 1ps

// Top level testbench
module tb;
    
    // Parameter definition for MAC configuration and packet generation
    parameter UNICAST_ADDR          = 48'h22_44_66_88_AA_CC;
    parameter MULTICAST_ADDR        = 48'h21_44_66_88_AA_CC;
    parameter BROADCAST_ADDR        = 48'hFF_FF_FF_FF_FF_FF;
    parameter PAUSE_MULTICAST_ADDR  = 48'h01_80_C2_00_00_01;
    parameter INVALID_ADDR          = 48'h00_00_00_00_00_00;
    
    parameter MAC_ADDR              = 48'hEE_CC_88_CC_AA_EE;
    
    parameter VLAN_INFO             = 16'h0123;
    parameter SVLAN_INFO            = 16'h4567;
    
    parameter INSERT_PAD            = 1;
    parameter INSERT_CRC            = 0;
    parameter PAUSE_QUANTA          = 16'h0025;
    
    // Parameter definition for FIFO configuration
    parameter RX_FIFO_DROP_ON_ERROR = 1;
    
    
    // Get the Avalon interface parameters definition from the package
    import avalon_if_params_pkt::*;
    
    // Get the register map definition from the package
    import eth_register_map_params_pkg::*;
    
    
    
    // Clock and Reset signals
    reg         clk_156p25;
    reg         clk_125;
    reg         clk_122;
    wire        clk_gmii = clk_156p25;
    reg         clk_mac;
    reg         clk_50;
    reg         reset;
    
    wire        avalon_mm_csr_clk;
    wire        avalon_st_rx_clk;
    wire        avalon_st_tx_clk;
    
    // Avalon-MM CSR signals
    wire [18:0] avalon_mm_csr_address;
    wire        avalon_mm_csr_read;
    wire [31:0] avalon_mm_csr_readdata;
    wire        avalon_mm_csr_write;
    wire [31:0] avalon_mm_csr_writedata;
    wire        avalon_mm_csr_waitrequest;
    
    // Avalon-ST RX signals
    wire        avalon_st_rx_startofpacket;
    wire        avalon_st_rx_endofpacket;
    wire        avalon_st_rx_valid;
    wire        avalon_st_rx_ready;
    wire [63:0] avalon_st_rx_data;
    wire [2:0]  avalon_st_rx_empty;
    wire [5:0]  avalon_st_rx_error;
    
    // Avalon-ST TX signals
    wire        avalon_st_tx_startofpacket;
    wire        avalon_st_tx_endofpacket;
    wire        avalon_st_tx_valid;
    wire        avalon_st_tx_ready;
    wire [63:0] avalon_st_tx_data;
    wire [2:0]  avalon_st_tx_empty;
    wire        avalon_st_tx_error;
    
    
    
    // Clock and reset generation
    initial clk_156p25 = 1'b0;
    always #3200 clk_156p25 = ~clk_156p25;
    
    initial clk_125 = 1'b0;
    always #4000 clk_125 = ~clk_125;
    
    initial clk_122 = 1'b0;
    always #4098 clk_122 = ~clk_122;
    
    initial clk_50 = 1'b0;
    always #10000 clk_50 = ~clk_50;
    
    initial clk_mac = 1'b0;
    always #12800 clk_mac = ~clk_mac;

    initial begin
        reset = 1'b0;
        #1 reset = 1'b1;
        #400000 reset = 1'b0;
    end
    
    
    
    // DUT specific signals
    wire [3:0] xaui_rx_data;
    wire [3:0] xaui_tx_data;
    wire clk_mac2;
    //wire reconfig_busy;
    //wire gxb_pwrdwn;   
    //wire pll_pwrdwn;   
    // Loopback at Ethernet side
    assign xaui_rx_data = xaui_tx_data;
    //assign gxb_pwrdwn = 1'b0;
    //assign pll_pwrdwn = 1'b0;
    //assign reconfig_busy = 1'b0;
    // Loopback at Transceiver Side
    wire txp_from_the_eth_2_5g_pcs_pma_0;
    wire eth_2_5g_pcs_pma_0_rx_clk_out;
    wire [91:0] reconfig_fromgxb_from_the_eth_2_5g_pcs_pma_0;
    
    
    // DUT instantiation
    altera_eth_2_5GbE DUT(
        // Clock and Reset
        .clk_39                                          (clk_mac),
        .clk_122                                         (clk_122),
        .ref_clk                                         (clk_125),
        .reset_n                                         (~reset),
        .eth_2_5g_phy_tx_clk_out                   (eth_2_5g_pcs_pma_0_tx_clk_out),
        .eth_2_5g_phy_tx_pll_locked                   (eth_2_5g_phy_tx_pll_locked),
        //.gxb_cal_blk_clk       (clk_50),
        //.gxb_pwrdwn       (gxb_pwrdwn),
        //.pll_pwrdwn       (pll_pwrdwn),    
        // Reconfig
        //.reconfig_clk          (clk_50),
        .reconfig_fromgxb    (reconfig_fromgxb_from_the_eth_2_5g_pcs_pma_0),
        .reconfig_togxb        (140'd2),
       //.reconfig_busy        (reconfig_busy),
       // Avalon-MM CSR
        .avalon_mm_csr_address			            (avalon_mm_csr_address),
        .avalon_mm_csr_read                         (avalon_mm_csr_read),
        .avalon_mm_csr_readdata                   (avalon_mm_csr_readdata),
        .avalon_mm_csr_waitrequest                (avalon_mm_csr_waitrequest),
        .avalon_mm_csr_write                        (avalon_mm_csr_write),
        .avalon_mm_csr_writedata                    (avalon_mm_csr_writedata),
        // Avalon-ST RX
        .avalon_st_rx_data  (avalon_st_rx_data),
        .avalon_st_rx_empty (avalon_st_rx_empty),
        .avalon_st_rx_eop   (avalon_st_rx_endofpacket),
        .avalon_st_rx_error (avalon_st_rx_error),
        .avalon_st_rx_ready   (avalon_st_rx_ready),
        .avalon_st_rx_sop   (avalon_st_rx_startofpacket),
        .avalon_st_rx_valid (avalon_st_rx_valid),
        // Avalon-ST TX
        .avalon_st_tx_data    (avalon_st_tx_data),
        .avalon_st_tx_empty   (avalon_st_tx_empty),
        .avalon_st_tx_eop     (avalon_st_tx_endofpacket),
        .avalon_st_tx_error   (avalon_st_tx_error),
        .avalon_st_tx_ready (avalon_st_tx_ready),
        .avalon_st_tx_sop     (avalon_st_tx_startofpacket),
        .avalon_st_tx_valid   (avalon_st_tx_valid),
        // Transceiver
        .rxp                   (txp_from_the_eth_2_5g_pcs_pma_0),
        .txp                 (txp_from_the_eth_2_5g_pcs_pma_0)
        
    );
        
    
    
    // Assign clock signals
    assign avalon_mm_csr_clk    = clk_122;
    assign avalon_st_tx_clk     = clk_122;
    assign avalon_st_rx_clk     = clk_122;
    
    // Avalon-MM and Avalon-ST signals driver
    avalon_driver U_AVALON_DRIVER (
		.avalon_mm_csr_clk          (avalon_mm_csr_clk),
		.avalon_st_rx_clk           (avalon_st_rx_clk),
		.avalon_st_tx_clk           (avalon_st_tx_clk),
		
        .reset                      (reset),
		
        .avalon_mm_csr_address      (avalon_mm_csr_address),
		.avalon_mm_csr_read         (avalon_mm_csr_read),
		.avalon_mm_csr_readdata     (avalon_mm_csr_readdata),
		.avalon_mm_csr_write        (avalon_mm_csr_write),
		.avalon_mm_csr_writedata    (avalon_mm_csr_writedata),
		.avalon_mm_csr_waitrequest  (avalon_mm_csr_waitrequest),
        
        .avalon_st_rx_startofpacket (avalon_st_rx_startofpacket),
		.avalon_st_rx_endofpacket   (avalon_st_rx_endofpacket),
		.avalon_st_rx_valid         (avalon_st_rx_valid),
		.avalon_st_rx_ready         (avalon_st_rx_ready),
		.avalon_st_rx_data          (avalon_st_rx_data),
		.avalon_st_rx_empty         (avalon_st_rx_empty),
		.avalon_st_rx_error         (avalon_st_rx_error),
		
        .avalon_st_tx_startofpacket (avalon_st_tx_startofpacket),
		.avalon_st_tx_endofpacket   (avalon_st_tx_endofpacket),
		.avalon_st_tx_valid         (avalon_st_tx_valid),
		.avalon_st_tx_ready         (avalon_st_tx_ready),
		.avalon_st_tx_data          (avalon_st_tx_data),
		.avalon_st_tx_empty         (avalon_st_tx_empty),
		.avalon_st_tx_error         (avalon_st_tx_error)
	);
    
    
    
    // Ethernet packet monitor on Avalon-ST RX path
    avalon_st_eth_packet_monitor #(
		.ST_ERROR_W                 (AVALON_ST_RX_ST_ERROR_W)
    ) U_MON_RX (
		.clk                        (avalon_st_rx_clk),
        .reset                      (reset),
		
        .startofpacket              (avalon_st_rx_startofpacket),
		.endofpacket                (avalon_st_rx_endofpacket),
		.valid                      (avalon_st_rx_valid),
		.ready                      (avalon_st_rx_ready),
		.data                       (avalon_st_rx_data),
		.empty                      (avalon_st_rx_empty),
		.error                      (avalon_st_rx_error)
	);
    
    
    
    // Ethernet packet monitor on Avalon-ST TX path
    avalon_st_eth_packet_monitor #(
		.ST_ERROR_W (AVALON_ST_TX_ST_ERROR_W)
    ) U_MON_TX (
		.clk                        (avalon_st_tx_clk),
        .reset                      (reset),
		
        .startofpacket              (avalon_st_tx_startofpacket),
		.endofpacket                (avalon_st_tx_endofpacket),
		.valid                      (avalon_st_tx_valid),
		.ready                      (avalon_st_tx_ready),
		.data                       (avalon_st_tx_data),
		.empty                      (avalon_st_tx_empty),
		.error                      (avalon_st_tx_error)
	);
    
    
    
    // Variable to store data read from CSR interface
    bit [31:0] readdata;
    
    // Control the testbench flow and driving signals by calling Avalon BFM Driver
    initial begin
        // Configure the MAC
        // Enable source address insertion on TX
        U_AVALON_DRIVER.avalon_mm_csr_wr(TX_ADDRESS_INSERT_CONTROL_ADDR, 1);
        
        // Configure unicast address for TX
        U_AVALON_DRIVER.avalon_mm_csr_wr(TX_ADDRESS_INSERT_UCAST_MAC_ADD_0_ADDR, MAC_ADDR[31:0]);
        U_AVALON_DRIVER.avalon_mm_csr_wr(TX_ADDRESS_INSERT_UCAST_MAC_ADD_1_ADDR, MAC_ADDR[47:32]);
        
        // Read the configured registers
        U_AVALON_DRIVER.avalon_mm_csr_rd(TX_ADDRESS_INSERT_CONTROL_ADDR, readdata);
        $display("TX Source Address Insert Enable   = %0d", readdata[0]);
        
        U_AVALON_DRIVER.avalon_mm_csr_rd(TX_ADDRESS_INSERT_UCAST_MAC_ADD_1_ADDR, readdata);
        $display("TX Source Address [47:32]         = 0x%x", readdata[15:0]);
        
        U_AVALON_DRIVER.avalon_mm_csr_rd(TX_ADDRESS_INSERT_UCAST_MAC_ADD_0_ADDR, readdata);
        $display("TX Source Address [31:0]          = 0x%x", readdata[31:0]);
        
        // Send Ethernet packet through Avalon-ST TX path
        U_AVALON_DRIVER.avalon_st_transmit_data_frame(UNICAST_ADDR, INVALID_ADDR, 64, INSERT_PAD, INSERT_CRC);
        U_AVALON_DRIVER.avalon_st_transmit_pause_frame(PAUSE_MULTICAST_ADDR, MAC_ADDR, PAUSE_QUANTA, INSERT_PAD, INSERT_CRC);
        U_AVALON_DRIVER.avalon_st_transmit_vlan_frame(MULTICAST_ADDR, MAC_ADDR, VLAN_INFO, 1518, INSERT_PAD, INSERT_CRC);
        U_AVALON_DRIVER.avalon_st_transmit_data_frame(MAC_ADDR, MAC_ADDR, 1518, INSERT_PAD, INSERT_CRC);
        U_AVALON_DRIVER.avalon_st_transmit_svlan_frame(BROADCAST_ADDR, MAC_ADDR, VLAN_INFO, SVLAN_INFO, 64, INSERT_PAD, INSERT_CRC);
        U_AVALON_DRIVER.avalon_st_transmit_vlan_frame(UNICAST_ADDR, MAC_ADDR, VLAN_INFO, 500, INSERT_PAD, INSERT_CRC);
        U_AVALON_DRIVER.avalon_st_transmit_pause_frame(MAC_ADDR, MAC_ADDR, PAUSE_QUANTA, INSERT_PAD, INSERT_CRC);
        U_AVALON_DRIVER.avalon_st_transmit_svlan_frame(MAC_ADDR, INVALID_ADDR, VLAN_INFO, SVLAN_INFO, 1518, INSERT_PAD, INSERT_CRC);
        
        
        
        // Wait until packet loopback on Avalon-ST RX path
        repeat(3500) @(posedge clk_156p25);
         
        
        
        // Display the collected statistics of the MAC
        $display("\n-------------");
        $display("TX Statistics");
        $display("-------------");
        U_AVALON_DRIVER.display_eth_statistics(TX_STATISTICS_ADDR);
        
        $display("\n-------------");
        $display("RX Statistics");
        $display("-------------");
        U_AVALON_DRIVER.display_eth_statistics(RX_STATISTICS_ADDR);
        
        
        
        // Simulation ended
        $display("\n\nSimulation Ended\n");
        $stop();
    end
    
    
endmodule

`endif
