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

    // Coding for link fault status
    parameter IDLE = 2'b00;  
    
    
    // Get the Avalon interface parameters definition from the package
    import avalon_if_params_pkt::*;
    
    // Get the register map definition from the package
    import eth_register_map_params_pkg::*;
    
    
    
    // Clock and Reset signals
    reg         clk_156p25;
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
    wire        avalon_mm_csr_readdatavalid;
    wire [2:0]  avalon_mm_csr_burstcount;    
    wire [3:0]  avalon_mm_csr_byteenable;  

   wire rx_data_ready;
    
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
    
    initial clk_50 = 1'b0;
    always #10000 clk_50 = ~clk_50;
    
    initial begin
        reset = 1'b0;
        #1 reset = 1'b1;
        #40000 reset = 1'b0;
    end
    
    
    
    // DUT specific signals
    wire [3:0] xaui_rx_data;
    wire [3:0] xaui_tx_data;
    
    wire xgmii_clk;
    wire rx_pma_ready;
    wire tx_pma_ready;   

    wire [1:0] link_fault_status_xgmii_rx_data;
    wire link_fault_status;
    wire datapath_ready; 
    
    // Loopback at Ethernet side
    assign xaui_rx_data = xaui_tx_data;
    
    
    // DUT instantiation
    altera_eth_10g_mac_xaui DUT(
        // Clock and Reset
        
        .mm_clk_clk                                             (clk_50),
        .mm_reset_reset_n                                       (~reset),
        
        .rx_ready_export                                   	    (rx_pma_ready),
        .tx_ready_export                                        (tx_pma_ready),
              
        .ref_clk_clk                                            (clk_156p25),
        .ref_reset_reset_n                                      (~reset),
        
        .xgmii_rx_clk_clk                                       (xgmii_clk),
        .tx_clk_clk                                             (xgmii_clk),
        .tx_reset_reset_n                                       (~reset),
        
        // Avalon-MM CSR
        .mm_pipeline_bridge_address                             (avalon_mm_csr_address),
        .mm_pipeline_bridge_read                                (avalon_mm_csr_read),
        .mm_pipeline_bridge_readdata                            (avalon_mm_csr_readdata),
        .mm_pipeline_bridge_waitrequest                         (avalon_mm_csr_waitrequest),
        .mm_pipeline_bridge_write                               (avalon_mm_csr_write),
        .mm_pipeline_bridge_writedata                           (avalon_mm_csr_writedata),
        
        // Avalon-ST RX
        .rx_sc_fifo_out_data                                    (avalon_st_rx_data),
        .rx_sc_fifo_out_empty                                   (avalon_st_rx_empty),
        .rx_sc_fifo_out_endofpacket                             (avalon_st_rx_endofpacket),
        .rx_sc_fifo_out_error                                   (avalon_st_rx_error),
        .rx_sc_fifo_out_ready                                   (avalon_st_rx_ready),
        .rx_sc_fifo_out_startofpacket                           (avalon_st_rx_startofpacket),
        .rx_sc_fifo_out_valid                                   (avalon_st_rx_valid),
        
        // Avalon-ST TX
        .tx_sc_fifo_in_data                                     (avalon_st_tx_data),
        .tx_sc_fifo_in_empty                                    (avalon_st_tx_empty),
        .tx_sc_fifo_in_endofpacket                              (avalon_st_tx_endofpacket),
        .tx_sc_fifo_in_error                                    (avalon_st_tx_error),
        .tx_sc_fifo_in_ready                                    (avalon_st_tx_ready),
        .tx_sc_fifo_in_startofpacket                            (avalon_st_tx_startofpacket),
        .tx_sc_fifo_in_valid                                    (avalon_st_tx_valid & rx_pma_ready & tx_pma_ready),
        
        // XAUI
        .rx_serial_data_export                             (xaui_rx_data),
        .tx_serial_data_export                             (xaui_tx_data),
	
	 // Status
        .link_fault_status_xgmii_rx_data                        (link_fault_status_xgmii_rx_data)
    );
    
    
    // Assign clock signals
    assign avalon_mm_csr_clk    = clk_50;
    assign avalon_st_tx_clk     = xgmii_clk;
    assign avalon_st_rx_clk     = xgmii_clk;

    // Decode link fault status
    assign link_fault_status = (link_fault_status_xgmii_rx_data == IDLE)? 1'b0:1'b1; 

    // To indicate PHY and MAC is ready
    // Avalon ST driver will only start driving signals when PHY and MAC is ready to sent data.     
    assign datapath_ready = rx_pma_ready & tx_pma_ready & rx_data_ready & !link_fault_status;
    
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
		.avalon_st_tx_ready         (avalon_st_tx_ready & rx_pma_ready & tx_pma_ready),
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
        // Configure GXB Powerdown of XAUI PCS
        // This configuration is needed for simulation to work
        U_AVALON_DRIVER.avalon_mm_csr_wr(ETH_PCS_XAUI_POWERDOWN_ADDR, (1 << ETH_PCS_XAUI_GXB_POWERDOWN_OFFSET));
        U_AVALON_DRIVER.avalon_mm_csr_wr(ETH_PCS_XAUI_POWERDOWN_ADDR, (0 << ETH_PCS_XAUI_GXB_POWERDOWN_OFFSET));
        
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
        
        
        
        // Configure the RX FIFO
        U_AVALON_DRIVER.avalon_mm_csr_wr(RX_FIFO_DROP_ON_ERROR_ADDR, RX_FIFO_DROP_ON_ERROR);
        
        // Read the configured registers
        U_AVALON_DRIVER.avalon_mm_csr_rd(RX_FIFO_DROP_ON_ERROR_ADDR, readdata);
        $display("RX FIFO Drop on Error Enable      = %0d", readdata[0]);
        

	// Wait until PHY + MAC datapath is ready
        while (!datapath_ready) @(posedge xgmii_clk);
        

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
        repeat(1000) @(posedge clk_156p25);
        
        
        
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
        $finish();
    end
    
    
endmodule

`endif
