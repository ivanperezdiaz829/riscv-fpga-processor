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


`ifndef AVALON_DRIVER__SV
`define AVALON_DRIVER__SV

`include "avalon_if_params_pkg.sv"
`include "avalon_bfm_wrapper.sv"
`include "eth_mac_frame.sv"

// Path to the Avalon-MM and Avalon-ST BFMs
`define AVALON_MM_CSR_BFM   U_BFM_WRAPPER.avalon_mm_csr_bfm
`define AVALON_ST_TX_BFM    U_BFM_WRAPPER.avalon_st_tx_bfm
`define AVALON_ST_RX_BFM    U_BFM_WRAPPER.avalon_st_rx_bfm

`timescale 1ns / 1ns

// Module to drive Avalon-MM and Avalon-ST signals
module avalon_driver(
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
    avalon_st_tx_error
);
    // Get the Avalon interface parameters definition from the package
    import avalon_if_params_pkt::*;
    
    // Get the register map definition from the package
    import eth_register_map_params_pkg::*;
    
    // Get the Avalon-MM enum definition from the package
    import avalon_mm_pkg::*;
    
    
    
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
    
    
    
    // Instantiate the Avalon BFM wrapper module, which drives respective signals to output port of this driver module
    avalon_bfm_wrapper U_BFM_WRAPPER (
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
    
    // To indicate the DUT is ready
    logic dut_ready = 0;
    
    
    
    initial begin
        // Initialize all BFMs
        `AVALON_MM_CSR_BFM.init();
        `AVALON_ST_TX_BFM.init();
        `AVALON_ST_TX_BFM.set_response_timeout(30000);
        `AVALON_ST_TX_BFM.set_max_transaction_queue_size(30000);
        `AVALON_ST_RX_BFM.init();
        
        // Wait until exit from reset stage
        @(posedge `AVALON_ST_TX_BFM.clk);
        @(negedge reset);
        
        // Add delay to ensure the DUT has been reset properly
        repeat(2) @(posedge `AVALON_ST_TX_BFM.clk);
        
        // Avalon-ST RX side always receive data
        `AVALON_ST_RX_BFM.set_ready(1);
        
        // BFM is ready to start
        assign dut_ready = 1;
    end
    
    
    
    // Avalon-MM Write function to configure the DUT
    task automatic avalon_mm_csr_wr(bit [31:0] address, bit [31:0] writedata);
        
        // Wait until DUT is ready
        while(!dut_ready) begin
            @(posedge avalon_mm_csr_clk);
        end
        
        // Configure Avalon-MM transaction send to the BFM
        `AVALON_MM_CSR_BFM.set_command_request(REQ_WRITE);
        `AVALON_MM_CSR_BFM.set_command_address(address);
        `AVALON_MM_CSR_BFM.set_command_init_latency(3);
        `AVALON_MM_CSR_BFM.set_command_data(writedata, 0);
        `AVALON_MM_CSR_BFM.set_command_idle(0,0);
        `AVALON_MM_CSR_BFM.push_command();
        
        // Wait until command responded and get the responded transaction
        while(`AVALON_MM_CSR_BFM.get_response_queue_size() == 0) begin
            @(posedge avalon_mm_csr_clk);
        end
        `AVALON_MM_CSR_BFM.pop_response();
    endtask
    
    
    
    // Avalon-MM Read function to read from the DUT
    task automatic avalon_mm_csr_rd(bit [31:0] address, ref bit [31:0] readdata);
        
        // Wait until DUT is ready
        while(!dut_ready) begin
            @(posedge avalon_mm_csr_clk);
        end
        
        // Configure Avalon-MM transaction send to the BFM
        `AVALON_MM_CSR_BFM.set_command_request(REQ_READ);
        `AVALON_MM_CSR_BFM.set_command_address(address);
        `AVALON_MM_CSR_BFM.set_command_init_latency(3);
        `AVALON_MM_CSR_BFM.set_command_idle(0,0);
        `AVALON_MM_CSR_BFM.push_command();
        
        // Wait until command responded and get the responded transaction
        while(`AVALON_MM_CSR_BFM.get_response_queue_size() == 0) begin
            @(posedge avalon_mm_csr_clk);
        end
        `AVALON_MM_CSR_BFM.pop_response();
        readdata = `AVALON_MM_CSR_BFM.get_response_data(0);
    endtask
    
    
    
    // Avalon-MM Read function to read consecutive regsiters from the DUT
    task automatic avalon_mm_csr_rd64(bit [31:0] address, ref bit [63:0] readdata);
        bit [31:0] lower;
        bit [31:0] upper;
        
        avalon_mm_csr_rd(address, lower);
        avalon_mm_csr_rd(address + 4, upper);
        readdata = upper << 31 | lower;
    endtask
    
    
    
    // Display the statitics registers
    task automatic display_eth_statistics(bit [31:0] address);
        bit [63:0] stat;
        
        bit [63:0] framesOK;
        bit [63:0] framesErr;
        bit [63:0] framesCRCErr;
        bit [63:0] octetsOK;
        bit [63:0] pauseMACCtrlFrames;
        bit [63:0] ifErrors;
        bit [63:0] unicastFramesOK;
        bit [63:0] unicastFramesErr;
        bit [63:0] multicastFramesOK;
        bit [63:0] multicastFramesErr;
        bit [63:0] broadcastFramesOK;
        bit [63:0] broadcastFramesErr;
        bit [63:0] etherStatsOctets;
        bit [63:0] etherStatsPkts;
        bit [63:0] etherStatsUndersizePkts;
        bit [63:0] etherStatsOversizePkts;
        bit [63:0] etherStatsPkts64Octets;
        bit [63:0] etherStatsPkts65to127Octets;
        bit [63:0] etherStatsPkts128to255Octets;
        bit [63:0] etherStatsPkts256to511Octet;
        bit [63:0] etherStatsPkts512to1023Octets;
        bit [63:0] etherStatsPkts1024to1518Octets;
        bit [63:0] etherStatsPkts1519OtoXOctets;
        bit [63:0] etherStatsFragments;
        bit [63:0] etherStatsJabbers;
        bit [63:0] etherStatsCRCErr;
        bit [63:0] unicastMACCtrlFrames;
        bit [63:0] multicastMACCtrlFrames;
        bit [63:0] broadcastMACCtrlFrames;
        
        avalon_mm_csr_rd64(address + STATISTICS_framesOK_OFFSET, framesOK);
        avalon_mm_csr_rd64(address + STATISTICS_framesErr_OFFSET, framesErr);
        avalon_mm_csr_rd64(address + STATISTICS_framesCRCErr_OFFSET, framesCRCErr);
        avalon_mm_csr_rd64(address + STATISTICS_octetsOK_OFFSET, octetsOK);
        avalon_mm_csr_rd64(address + STATISTICS_pauseMACCtrlFrames_OFFSET, pauseMACCtrlFrames);
        avalon_mm_csr_rd64(address + STATISTICS_ifErrors_OFFSET, ifErrors);
        avalon_mm_csr_rd64(address + STATISTICS_unicastFramesOK_OFFSET, unicastFramesOK);
        avalon_mm_csr_rd64(address + STATISTICS_unicastFramesErr_OFFSET, unicastFramesErr);
        avalon_mm_csr_rd64(address + STATISTICS_multicastFramesOK_OFFSET, multicastFramesOK);
        avalon_mm_csr_rd64(address + STATISTICS_multicastFramesErr_OFFSET, multicastFramesErr);
        avalon_mm_csr_rd64(address + STATISTICS_broadcastFramesOK_OFFSET, broadcastFramesOK);
        avalon_mm_csr_rd64(address + STATISTICS_broadcastFramesErr_OFFSET, broadcastFramesErr);
        avalon_mm_csr_rd64(address + STATISTICS_etherStatsOctets_OFFSET, etherStatsOctets);
        avalon_mm_csr_rd64(address + STATISTICS_etherStatsPkts_OFFSET, etherStatsPkts);
        avalon_mm_csr_rd64(address + STATISTICS_etherStatsUndersizePkts_OFFSET, etherStatsUndersizePkts);
        avalon_mm_csr_rd64(address + STATISTICS_etherStatsOversizePkts_OFFSET, etherStatsOversizePkts);
        avalon_mm_csr_rd64(address + STATISTICS_etherStatsPkts64Octets_OFFSET, etherStatsPkts64Octets);
        avalon_mm_csr_rd64(address + STATISTICS_etherStatsPkts65to127Octets_OFFSET, etherStatsPkts65to127Octets);
        avalon_mm_csr_rd64(address + STATISTICS_etherStatsPkts128to255Octets_OFFSET, etherStatsPkts128to255Octets);
        avalon_mm_csr_rd64(address + STATISTICS_etherStatsPkts256to511Octets_OFFSET, etherStatsPkts256to511Octet);
        avalon_mm_csr_rd64(address + STATISTICS_etherStatsPkts512to1023Octets_OFFSET, etherStatsPkts512to1023Octets);
        avalon_mm_csr_rd64(address + STATISTICS_etherStatPkts1024to1518Octets_OFFSET, etherStatsPkts1024to1518Octets);
        avalon_mm_csr_rd64(address + STATISTICS_etherStatsPkts1519toXOctets_OFFSET, etherStatsPkts1519OtoXOctets);
        avalon_mm_csr_rd64(address + STATISTICS_etherStatsFragments_OFFSET, etherStatsFragments);
        avalon_mm_csr_rd64(address + STATISTICS_etherStatsJabbers_OFFSET, etherStatsJabbers);
        avalon_mm_csr_rd64(address + STATISTICS_etherStatsCRCErr_OFFSET, etherStatsCRCErr);
        avalon_mm_csr_rd64(address + STATISTICS_unicastMACCtrlFrames_OFFSET, unicastMACCtrlFrames);
        avalon_mm_csr_rd64(address + STATISTICS_multicastMACCtrlFrames_OFFSET, multicastMACCtrlFrames);
        avalon_mm_csr_rd64(address + STATISTICS_broadcastMACCtrlFrames_OFFSET, broadcastMACCtrlFrames);
        
        $display("\tframesOK                          = %0d", framesOK);
        $display("\tframesErr                         = %0d", framesErr);
        $display("\tframesCRCErr                      = %0d", framesCRCErr);
        $display("\toctetsOK                          = %0d", octetsOK);
        $display("\tpauseMACCtrlFrames                = %0d", pauseMACCtrlFrames);
        $display("\tifErrors                          = %0d", ifErrors);
        $display("\tunicastFramesOK                   = %0d", unicastFramesOK);
        $display("\tunicastFramesErr                  = %0d", unicastFramesErr);
        $display("\tmulticastFramesOK                 = %0d", multicastFramesOK);
        $display("\tmulticastFramesErr                = %0d", multicastFramesErr);
        $display("\tbroadcastFramesOK                 = %0d", broadcastFramesOK);
        $display("\tbroadcastFramesErr                = %0d", broadcastFramesErr);
        $display("\tetherStatsOctets                  = %0d", etherStatsOctets);
        $display("\tetherStatsPkts                    = %0d", etherStatsPkts);
        $display("\tetherStatsUndersizePkts           = %0d", etherStatsUndersizePkts);
        $display("\tetherStatsOversizePkts            = %0d", etherStatsOversizePkts);
        $display("\tetherStatsPkts64Octets            = %0d", etherStatsPkts64Octets);
        $display("\tetherStatsPkts65to127Octets       = %0d", etherStatsPkts65to127Octets);
        $display("\tetherStatsPkts128to255Octets      = %0d", etherStatsPkts128to255Octets);
        $display("\tetherStatsPkts256to511Octet       = %0d", etherStatsPkts256to511Octet);
        $display("\tetherStatsPkts512to1023Octets     = %0d", etherStatsPkts512to1023Octets);
        $display("\tetherStatsPkts1024to1518Octets    = %0d", etherStatsPkts1024to1518Octets);
        $display("\tetherStatsPkts1519OtoXOctets      = %0d", etherStatsPkts1519OtoXOctets);
        $display("\tetherStatsFragments               = %0d", etherStatsFragments);
        $display("\tetherStatsJabbers                 = %0d", etherStatsJabbers);
        $display("\tetherStatsCRCErr                  = %0d", etherStatsCRCErr);
        $display("\tunicastMACCtrlFrames              = %0d", unicastMACCtrlFrames);
        $display("\tmulticastMACCtrlFrames            = %0d", multicastMACCtrlFrames);
        $display("\tbroadcastMACCtrlFrames            = %0d", broadcastMACCtrlFrames);
    endtask
    
    
    
    // Transmit untagged data frame on Avalon-ST TX side
    task automatic avalon_st_transmit_data_frame(
            bit [47:0] dest_addr,
            bit [47:0] src_addr,
            int unsigned frame_length,
            bit insert_pad,
            bit insert_crc
        );
        
        int unsigned i;
        bit [15:0] payload_length;
        
        bit [7:0] payload_data[];
        
        // Payload length is exclusive of Destination Address, Source Address, Length/Type Field, and CRC
        payload_length = frame_length - 18;
        payload_data = new[payload_length];
        
        // Payload content are incremented for every byte
        for(i = 0; i < payload_length; i++) begin
            payload_data[i] = i;
        end
        
        avalon_st_transmit_frame_universal(
            dest_addr, src_addr,
            0, 16'h0000,
            0, 16'h0000, 16'h0000,
            payload_data,
            insert_pad,
            insert_crc
        );
    endtask
    
    
    
    // Transmit VLAN tagged data frame on Avalon-ST TX side
    task automatic avalon_st_transmit_vlan_frame(
            bit [47:0] dest_addr,
            bit [47:0] src_addr,
            bit [15:0] vlan_info,
            int unsigned frame_length,
            bit insert_pad,
            bit insert_crc
        );
        
        int unsigned i;
        bit [15:0] payload_length;
        
        bit [7:0] payload_data[];
        
        // Payload length is exclusive of Destination Address, Source Address, VLAN Tag, VLAN Info, Length/Type Field, and CRC
        payload_length = frame_length - 22;
        payload_data = new[payload_length];
        
        // Payload content are incremented for every byte
        for(i = 0; i < payload_length; i++) begin
            payload_data[i] = i;
        end
        
        avalon_st_transmit_frame_universal(
            dest_addr, src_addr,
            0, 16'h0000,
            1, vlan_info, 16'h0000,
            payload_data,
            insert_pad,
            insert_crc
        );
    endtask
    
    
    
    // Transmit Stacked VLAN tagged data frame on Avalon-ST TX side
    task automatic avalon_st_transmit_svlan_frame(
            bit [47:0] dest_addr,
            bit [47:0] src_addr,
            bit [15:0] vlan_info,
            bit [15:0] svlan_info,
            int unsigned frame_length,
            bit insert_pad,
            bit insert_crc
        );
        
        int unsigned i;
        bit [15:0] payload_length;
        
        bit [7:0] payload_data[];
        
        // Payload length is exclusive of Destination Address, Source Address, VLAN Tags, VLAN Info, Length/Type Field, and CRC
        payload_length = frame_length - 26;
        payload_data = new[payload_length];
        
        // Payload content are incremented for every byte
        for(i = 0; i < payload_length; i++) begin
            payload_data[i] = i;
        end
        
        avalon_st_transmit_frame_universal(
            dest_addr, src_addr,
            0, 16'h0000,
            2, vlan_info, svlan_info,
            payload_data,
            insert_pad,
            insert_crc
        );
    endtask
    
    
    
    // Transmit pause frame on Avalon-ST TX side
    task automatic avalon_st_transmit_pause_frame(
            bit [47:0]      dest_addr,
            bit [47:0]      src_addr,
            bit [15:0]      pause_quanta,
            bit             insert_pad,
            bit             insert_crc
        );
        
        bit [7:0] payload_data[];
        
        payload_data = new[2];
        
        payload_data[0] = pause_quanta[15:8];
        payload_data[1] = pause_quanta[7:0];
        
        avalon_st_transmit_control_frame(
            dest_addr, src_addr,
            16'h0001,
            payload_data,
            insert_pad,
            insert_crc
        );
    endtask
    
    
    
    // Transmit control frame on Avalon-ST TX side
    task automatic avalon_st_transmit_control_frame(
            bit [47:0]      dest_addr,
            bit [47:0]      src_addr,
            bit [15:0]      control_opcode,
            bit [7:0]       payload_data[],
            bit             insert_pad,
            bit             insert_crc
        );
        
        avalon_st_transmit_frame_universal(
            dest_addr, src_addr,
            1, control_opcode,
            0, 16'h0000, 16'h0000,
            payload_data,
            insert_pad,
            insert_crc
        );
    endtask
    
    
    
    // Transmit frame on Avalon-ST TX side
    task automatic avalon_st_transmit_frame_universal(
            bit [47:0]      dest_addr,
            bit [47:0]      src_addr,
            bit             control_frame,  // 0 = Data Frame, 1 = Control Frame
            bit [15:0]      control_opcode,
            int unsigned    vlan_tag,       // 0 = Untagged, 1 = VLAN Tagged, 2 = Stacked VLAN Tagged
            bit [15:0]      vlan_info,
            bit [15:0]      svlan_info,
            bit [7:0]       payload_data[],
            bit             insert_pad,     // 0 = Do not insert pad, 1 = Insert Pad
            bit             insert_crc      // 0 = Do not insert CRC, 1 = Insert CRC
        );
        
        int unsigned frame_data_size;
        bit [15:0] payload_length;
        eth_mac_frame mac_frame;
        
        bit [31:0] crc;
        bit [7:0] frame_data[];
        mac_frame = new();
        
        // Determine payload length
        if(control_frame) begin
            payload_length = 60;
        end
        else begin
            payload_length = payload_data.size();
        end
        
        // Insert destination address and source address
        mac_frame.insert_dest_addr(frame_data, dest_addr);
        mac_frame.insert_src_addr(frame_data, src_addr);
        
        // Insert Length/Type, Control Opcode, and VLAN Tag accordingly
        if(control_frame) begin
            mac_frame.insert_length_type(frame_data, 16'h8808);
            mac_frame.insert_control_opcode(frame_data, control_opcode);
        end
        else begin
            if(vlan_tag >= 1) begin
                mac_frame.insert_vlan_tag(frame_data, vlan_info);
            end
            if(vlan_tag >= 2) begin
                mac_frame.insert_vlan_tag(frame_data, svlan_info);
            end
            
            mac_frame.insert_length_type(frame_data, payload_length);
        end
        
        // Insert payload content
        mac_frame.insert_payload(frame_data, payload_data);
        
        // Insert pad if the frame is undersized and the option is ON
        if(insert_pad) begin
            frame_data_size = frame_data.size();
            if(frame_data_size < 60) begin
                frame_data = new[60](frame_data);
                
                while(frame_data_size < 60) begin
                    frame_data[frame_data_size] = 8'h00;
                    frame_data_size++;
                end
            end
        end
        
        // Calculate and insert CRC if the option is ON
        if(insert_crc) begin
            crc = mac_frame.calculate_crc(frame_data);
            mac_frame.insert_crc(frame_data, crc);
        end
        
        // Instruct Avalon-ST BFM to transmit the packet
        avalon_st_tx_bfm_transmit(frame_data);
    endtask
    
    
    
    // Convert the packet content to Avalon-ST transaction
    // and
    // transmit the converted transction through Avalon-ST BFM on TX path
    task automatic avalon_st_tx_bfm_transmit(bit [7:0] frame_data[]);
        int unsigned i, j;
        int unsigned num_of_st_trans;
        
        // Converted Avalon-ST transaction signals
        bit avalon_st_sop[];
        bit avalon_st_eop[];
        bit [64:0] avalon_st_data[];
        bit [2:0] avalon_st_empty[];
        bit [0:0] avalon_st_error[];
        
        int unsigned frame_length;
        
        int unsigned bytes_remain;
        int unsigned empty_value;
        
        // Calculate the empty value at the last Avalon-ST packet transaction
        frame_length = frame_data.size();
        bytes_remain = frame_length % 8;
        empty_value = 8 - bytes_remain;
        
        // Calculate number of Avalon-ST transactions required for the packet
        num_of_st_trans = frame_length / 8;
        if(bytes_remain != 0) begin
            num_of_st_trans++;
        end
        
        // Allocate space to store the transaction contents
        avalon_st_sop = new[num_of_st_trans];
        avalon_st_eop = new[num_of_st_trans];
        avalon_st_data = new[num_of_st_trans];
        avalon_st_empty = new[num_of_st_trans];
        avalon_st_error = new[num_of_st_trans];
        
        // Packet content to Avalon-ST transaction conversion
        for(i = 0; i < num_of_st_trans; i++) begin
            
            // startofpacket
            if(i == 0) begin
                avalon_st_sop[i] = 1'b1;
            end
            else begin
                avalon_st_sop[i] = 1'b0;
            end
            
            // endofpacket
            if(i == num_of_st_trans - 1) begin
                avalon_st_eop[i] = 1'b1;
            end
            else begin
                avalon_st_eop[i] = 1'b0;
            end
            
            // empty
            if(i == num_of_st_trans - 1) begin
                avalon_st_empty[i] = empty_value;
            end
            else begin
                avalon_st_empty[i] = 0;
            end
            
            // error
            // no error injection
            avalon_st_error[i] = 1'b0;
            
            // data
            avalon_st_data[i] = 64'h00;
            for(j = 0; j < 8; j++) begin
                if(i * 8 + j < frame_length) begin
                    avalon_st_data[i] = avalon_st_data[i] << 8;
                    avalon_st_data[i] = avalon_st_data[i] | frame_data[i * 8 + j];
                end
                else begin
                    avalon_st_data[i] = avalon_st_data[i] << 8;
                    avalon_st_data[i] = avalon_st_data[i] | 8'h00;
                end
            end
            
        end
        
        // Wait until DUT is ready for transaction
        while(!dut_ready) begin
            @(posedge avalon_st_tx_clk);
        end
        
        // Call Avalon-ST Source BFM
        for(i = 0; i < num_of_st_trans; i++) begin
            @(posedge avalon_st_tx_clk);
            `AVALON_ST_TX_BFM.set_transaction_channel('x);
            
            `AVALON_ST_TX_BFM.set_transaction_error(avalon_st_error[i]);
            `AVALON_ST_TX_BFM.set_transaction_empty(avalon_st_empty[i]);
            
            `AVALON_ST_TX_BFM.set_transaction_sop(avalon_st_sop[i]);
            `AVALON_ST_TX_BFM.set_transaction_eop(avalon_st_eop[i]);
            
            `AVALON_ST_TX_BFM.set_transaction_data(avalon_st_data[i]);
            
            `AVALON_ST_TX_BFM.set_transaction_idles(0);
            
            `AVALON_ST_TX_BFM.push_transaction();
            
            
        end
        
    endtask
    
endmodule

`endif
