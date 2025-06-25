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
`include "avalon_checker.v"
`include "avalon_gmii_converter.v"
`include "gmii_to_avalon_convertor.v"
`include "clock_divider.v"
`include "altera_tse_gmii_rx_aligner_16b.v"

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
    wire [4:0] avalon_mm_csr_address;
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
    
    wire [4:0] avalon_mm_csr_address_word_aligned;
    reg clk_reset; 
    
    
    assign avalon_mm_csr_address_word_aligned = avalon_mm_csr_address[4:2];
    
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
    
    initial begin
        clk_reset = 1'b0;
        #1 clk_reset = 1'b1;
        #1000 clk_reset= 1'b0;
    end
    
    
    
    // DUT specific signals
    wire [3:0] xaui_rx_data;
    wire [3:0] xaui_tx_data;
    wire clk_mac2;
    wire reconfig_busy;
    wire gxb_pwrdwn;   
    wire pll_pwrdwn;   
    // Loopback at Ethernet side
    assign xaui_rx_data = xaui_tx_data;
    assign gxb_pwrdwn = 1'b0;
    assign pll_pwrdwn = 1'b0;
    assign reconfig_busy = 1'b0;
    // Loopback at Transceiver Side
    wire txp_from_the_eth_2_5g_pcs_pma_0;
    wire eth_2_5g_pcs_pma_0_rx_clk_out;
    
    wire [15:0] tx_gmii_data;
    wire [ 1:0] tx_gmii_enable;
    wire [ 1:0] tx_gmii_error;
    wire serial_lane;
    
    wire [15:0] rx_gmii_data;
    wire [ 1:0] rx_gmii_enable;
    wire [ 1:0] rx_gmii_error;

    wire [15:0] rx_gmii_data_out;
    wire [ 1:0] rx_gmii_enable_out;
    wire [ 1:0] rx_gmii_error_out;

    wire tx_clk;
    wire rx_clk;
    wire [1:0] link_up;
    
    //Avalon to GMII convertor
    avalon_to_16bit_gmii_convertor U_avalon_to_16bit_gmii_convertor(
    
        .avalon_clk(avalon_st_tx_clk),
        .gmii_clk(tx_clk),
        .reset(reset),
        .avalon_sink_sop(avalon_st_tx_startofpacket),
        .avalon_sink_eop(avalon_st_tx_endofpacket),
        .avalon_sink_valid(avalon_st_tx_valid),
        .avalon_sink_empty(avalon_st_tx_empty),
        .avalon_sink_error(avalon_st_tx_error),
        .avalon_sink_data(avalon_st_tx_data),
        .avalon_sink_ready(avalon_st_tx_ready),
        .gmii_data(tx_gmii_data),
        .gmii_enable(tx_gmii_enable),
        .gmii_error(tx_gmii_error)
        
   );
    
   
   clock_divider U_tx_clk_divider(
   
        .clk_in(tx_clk),
        .reset(clk_reset),
        .clk_out(avalon_st_tx_clk)
        
    );
    
    clock_divider U_rx_clk_divider(
   
        .clk_in(rx_clk),
        .reset(clk_reset),
        .clk_out(avalon_st_rx_clk)
        
    );
    
    
    // DUT instantiation
    altera_eth_2_5GbE DUT(
	.gmii_rx_d(rx_gmii_data),        //     gmii_rx_data.data
	.gmii_rx_err(rx_gmii_error),      //                 .error
	.gmii_rx_dv(rx_gmii_enable),       //   gmii_rx_enable.data
	.readdata(avalon_mm_csr_readdata),         //    avalon_mm_csr.readdata
	.waitrequest(avalon_mm_csr_waitrequest),      //                 .waitrequest
	.address(avalon_mm_csr_address_word_aligned),          //                 .address
	.read(avalon_mm_csr_read),             //                 .read
	.writedata(avalon_mm_csr_writedata),        //                 .writedata
	.write(avalon_mm_csr_write),            //                 .write
	.gmii_tx_d(tx_gmii_data),        //     gmii_tx_data.data
	.gmii_tx_err(tx_gmii_error),      //                 .error
	.gmii_tx_en(tx_gmii_enable),       //   gmii_tx_enable.data
	.ref_clk(clk_125),          //          ref_clk.export
	.tx_clk(tx_clk),           //           tx_clk.clk
	.reset_tx_clk(1'b0),     //     tx_clk_reset.reset
	.rx_clk(rx_clk),           //           rx_clk.clk
	.reset_rx_clk(1'b0),     //     rx_clk_reset.reset
	.clk(clk_125),              //              clk.clk
	.reset(reset),            //        clk_reset.reset
	.gxb_cal_blk_clk(),  //  gxb_cal_blk_clk.export
	.pll_powerdown(1'b0),    //    pll_powerdown.export
	.gxb_pwrdn_in(1'b0),     //     gxb_pwrdn_in.export
	.reconfig_togxb(),   //   reconfig_togxb.export
	.reconfig_busy(),    //    reconfig_busy.export
	.reconfig_clk(),     //     reconfig_clk.export
	.rxp(serial_lane),              //              rxp.export
	.led_link(link_up),         //         led_link.export
	.led_char_err(),     //     led_char_err.export
	.led_disp_err(),     //     led_disp_err.export
	.led_an(),           //           led_an.export
	.tx_pll_locked(),    //    tx_pll_locked.export
	.reconfig_fromgxb(), // reconfig_fromgxb.export
	.txp(serial_lane)               //              txp.export
    );

     altera_tse_gmii_rx_aligner_16b U_altera_tse_gmii_rx_aligner_16b(

        .clk(rx_clk),
	.reset(reset),
	.gmii_data_in(rx_gmii_data),
	.gmii_enable_in(rx_gmii_enable),
	.gmii_error_in(rx_gmii_error),
	.gmii_data_out(rx_gmii_data_out),
	.gmii_enable_out(rx_gmii_enable_out),
	.gmii_error_out(rx_gmii_error_out)

     );
        
    gmii_to_avalon_convertor U_gmii_to_avalon_convertor(
    
        .avalon_clk(avalon_st_rx_clk),
        .gmii_clk(rx_clk),
        .reset(reset),
        .avalon_rx_data(avalon_st_rx_data),
        .avalon_rx_valid(avalon_st_rx_valid),
        .avalon_rx_sop(avalon_st_rx_startofpacket),
        .avalon_rx_eop(avalon_st_rx_endofpacket),
        .avalon_rx_error(avalon_st_rx_error),
        .avalon_rx_empty(avalon_st_rx_empty),
        .avalon_rx_ready(avalon_st_rx_ready),
        .gmii_enable(rx_gmii_enable_out),
        .gmii_error(rx_gmii_error_out),
        .gmii_data(rx_gmii_data_out)    
    
    ); 
    
    // Assign clock signals
    assign avalon_mm_csr_clk    = clk_122;
    
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
        
        
    //This is to check the Avalon Packet is similar betwen transmitted and received
    //
    avalon_checker U_avalon_checker(
        .avalon_clk(avalon_st_rx_clk),
        .avalon_reset(reset),
    
        .avalon_st_tx_sop(avalon_st_tx_startofpacket),
        .avalon_st_tx_eop(avalon_st_tx_endofpacket), 
        .avalon_st_tx_valid(avalon_st_tx_valid), 
        .avalon_st_tx_ready(avalon_st_tx_ready),
        .avalon_st_tx_empty(avalon_st_tx_empty), 
        .avalon_st_tx_error(avalon_st_tx_error), 
        .avalon_st_tx_data(avalon_st_tx_data), 
    
        .avalon_st_rx_sop(avalon_st_rx_startofpacket),
        .avalon_st_rx_eop(avalon_st_rx_endofpacket), 
        .avalon_st_rx_valid(avalon_st_rx_valid), 
        .avalon_st_rx_empty(avalon_st_rx_empty), 
        .avalon_st_rx_error(avalon_st_rx_error),
        .avalon_st_rx_data(avalon_st_rx_data) 

    );
    
    
    
    // Variable to store data read from CSR interface
    bit [31:0] readdata;
    
    // Control the testbench flow and driving signals by calling Avalon BFM Driver
    initial begin        
        
         U_AVALON_DRIVER.avalon_mm_csr_rd(PHY_STATUS_ADDR, readdata);
         readdata = readdata&32'h4;
        
        while (readdata != 32'h4) begin
            U_AVALON_DRIVER.avalon_mm_csr_rd(PHY_STATUS_ADDR, readdata);
            readdata = readdata&32'h4;
        end
        
        // Send Ethernet packet through Avalon-ST TX path
        U_AVALON_DRIVER.avalon_st_transmit_data_frame(UNICAST_ADDR, INVALID_ADDR, 64, INSERT_PAD, INSERT_CRC);
        U_AVALON_DRIVER.avalon_st_transmit_pause_frame(PAUSE_MULTICAST_ADDR, MAC_ADDR, PAUSE_QUANTA, INSERT_PAD, INSERT_CRC);
        U_AVALON_DRIVER.avalon_st_transmit_vlan_frame(MULTICAST_ADDR, MAC_ADDR, VLAN_INFO, 1518, INSERT_PAD, INSERT_CRC);
        U_AVALON_DRIVER.avalon_st_transmit_data_frame(MAC_ADDR, MAC_ADDR, 1518, INSERT_PAD, INSERT_CRC);
        U_AVALON_DRIVER.avalon_st_transmit_svlan_frame(BROADCAST_ADDR, MAC_ADDR, VLAN_INFO, SVLAN_INFO, 64, INSERT_PAD, INSERT_CRC);
        U_AVALON_DRIVER.avalon_st_transmit_vlan_frame(UNICAST_ADDR, MAC_ADDR, VLAN_INFO, 500, INSERT_PAD, INSERT_CRC);
        U_AVALON_DRIVER.avalon_st_transmit_pause_frame(MAC_ADDR, MAC_ADDR, PAUSE_QUANTA, INSERT_PAD, INSERT_CRC);
        U_AVALON_DRIVER.avalon_st_transmit_svlan_frame(MAC_ADDR, INVALID_ADDR, VLAN_INFO, SVLAN_INFO, 1518, INSERT_PAD, INSERT_CRC);
        
        
        
        // Wait 
        #20000;
        
        
        
        // Simulation ended
        $display("\n\nSimulation Ended\n");
        
        if(U_MON_TX.packet_count == U_MON_RX.packet_count) begin
            $display("\n\n------\n");
            $display("PASSED\n");
            $display("\n------\n");
        end else begin
            $display("\n\n------\n");
            $display("FAILED\n");
            $display("\n------\n");
        end
        $stop();
    end
    
    
endmodule

`endif
