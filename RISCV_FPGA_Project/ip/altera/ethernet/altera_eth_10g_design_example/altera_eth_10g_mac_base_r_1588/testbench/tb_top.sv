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
`include "avalon_if_params_pkg.sv"
`include "avalon_st_eth_packet_monitor.sv"
`include "default_test_params_pkg.sv"
`include "eth_mac_frame.sv"
`include "ptp_timestamp.sv"
`include "tb_testcase.sv"  


`timescale 1ps / 1ps

// Top level testbench
module tb_top;

    
    // Get the Avalon interface parameters definition from the package
    import avalon_if_params_pkt::*;
    
    // Get the register map definition from the package
    import eth_register_map_params_pkg::*;
    
	//Get test parameter from the package
	import default_test_params_pkt::*;    

    // Clock and Reset signals
    reg         ref_clk;
    reg         clk_50;
    reg         reset;    
    
    // Avalon-MM CSR signals
    wire [31:0] avalon_mm_csr_address;
    wire        avalon_mm_csr_read;
    wire [31:0] avalon_mm_csr_readdata;
    wire        avalon_mm_csr_write;
    wire [31:0] avalon_mm_csr_writedata;
    wire        avalon_mm_csr_waitrequest;
  
    // Avalon-ST TX signals
    wire        avalon_st_tx_startofpacket;
    wire        avalon_st_tx_endofpacket;
    wire        avalon_st_tx_valid;
    wire        avalon_st_tx_ready;
    wire [63:0] avalon_st_tx_data;
    wire [2:0]  avalon_st_tx_empty;
    wire        avalon_st_tx_error;
	wire        avalon_st_txstatus_valid;       
	wire [39:0] avalon_st_txstatus_data;          
	wire [6:0]  avalon_st_txstatus_error;       
        
    // Avalon-ST RX signals
    wire        avalon_st_rx_startofpacket;
    wire        avalon_st_rx_endofpacket;
    wire        avalon_st_rx_valid;
    wire        avalon_st_rx_ready;
    wire [63:0] avalon_st_rx_data;
    wire [2:0]  avalon_st_rx_empty;
    wire [5:0]  avalon_st_rx_error;
	wire        avalon_st_rxstatus_valid;
	wire [6:0]  avalon_st_rxstatus_error;
	wire [39:0] avalon_st_rxstatus_data;        

    
    // Timestamp request
    wire                                                                    tx_egress_timestamp_request_valid;
    wire      [TIMESTAMP_FINGERPRINT_WIDTH - 1:0]                           tx_egress_timestamp_request_fingerprint;
	
    // Timestamp correction
    wire                                                                    tx_ingress_timestamp_valid;
    wire       [TIMESTAMP_96B_WIDTH-1:0]               	                    tx_ingress_timestamp_96b_data;	
    wire       [TIMESTAMP_64B_WIDTH-1:0]               	                    tx_ingress_timestamp_64b_data;	
    wire                                               	                    tx_ingress_timestamp_format;	
	
    // TX timestamp and fingerprint
    wire                                                                    tx_egress_timestamp_96b_valid;
    wire      [TIMESTAMP_96B_WIDTH-1:0]                                     tx_egress_timestamp_96b_data;
    wire      [TIMESTAMP_FINGERPRINT_WIDTH-1:0]                             tx_egress_timestamp_96b_fingerprint;
    wire                                                                    tx_egress_timestamp_64b_valid;
    wire      [TIMESTAMP_64B_WIDTH-1:0]                                     tx_egress_timestamp_64b_data;
    wire      [TIMESTAMP_FINGERPRINT_WIDTH-1:0]                             tx_egress_timestamp_64b_fingerprint;

    // RX timestamp
    wire                                                					rx_ingress_timestamp_96b_valid;
    wire      [TIMESTAMP_96B_WIDTH-1:0]                                     rx_ingress_timestamp_96b_data;
    wire                                                                    rx_ingress_timestamp_64b_valid;
    wire      [TIMESTAMP_64B_WIDTH-1:0]                                     rx_ingress_timestamp_64b_data;
        
    wire [1:0]  link_fault_status_xgmii_rx_data;
	wire [1:0]  avalon_st_pause_data;
    wire rx_ready_export;
    wire tx_ready_export;
    wire rx_data_ready_export; 

    wire rx_serial_data;
    wire tx_serial_data;
    
    wire pps_10g_out;
 
 
  
    // Clock and reset generation
    initial ref_clk = 1'b0;
    always #776 ref_clk = ~ref_clk;
       
    initial clk_50 = 1'b0;
    always #10000 clk_50 = ~clk_50;
    
    initial begin
        reset = 1'b0;
        #1 reset = 1'b1;
        #40000 reset = 1'b0;
    end

    
    // To elimiate 'x' case (set to '0') when these signals are not driven
    bit tx_sop ;
    bit tx_eop ;
    bit tx_ts_req_valid ;
    bit tx_estamp_ins_ctrl_residence_time_update ;
    reg  [1:0]  clock_mode = ORDINARY_CLOCK;
    reg         pkt_with_crc = 1'b0;
    
    assign tx_sop = (avalon_st_tx_startofpacket & avalon_st_tx_valid)==1 ? avalon_st_tx_startofpacket : 1'b0;
    assign tx_eop = (avalon_st_tx_endofpacket & avalon_st_tx_valid)==1 ? avalon_st_tx_endofpacket : 1'b0;
    assign tx_ts_req_valid = (tx_egress_timestamp_request_valid & avalon_st_tx_valid)==1 ? tx_egress_timestamp_request_valid : 1'b0;
    assign tx_estamp_ins_ctrl_residence_time_update = (tx_ingress_timestamp_valid & avalon_st_tx_valid)==1 ? tx_ingress_timestamp_valid : 1'b0;
    assign rx_serial_data = tx_serial_data;
    
 
    altera_eth_10g_mac_base_r_1588_top DUT(
        // Clock and Reset
        .csr_clk_clk                       (clk_50),        
        .csr_reset_reset_n                 (~reset),              

        .ref_clk_clk                       (ref_clk),
        .ref_reset_reset_n                 (~reset),

        .xgmii_rx_clk_clk                   (xgmii_clk),
        
        // Avalon-MM CSR
        .csr_address                       (avalon_mm_csr_address),               
        .csr_waitrequest                   (avalon_mm_csr_waitrequest),         
        .csr_read                          (avalon_mm_csr_read),                      
        .csr_readdata                      (avalon_mm_csr_readdata),                  
        .csr_write                         (avalon_mm_csr_write),                        
        .csr_writedata                     (avalon_mm_csr_writedata),                  

        // Avalon-ST TX
        .avalon_st_tx_ready                         (avalon_st_tx_ready),             
        .avalon_st_tx_valid                         (avalon_st_tx_valid),             
        .avalon_st_tx_startofpacket                 (tx_sop),   
        .avalon_st_tx_endofpacket                   (tx_eop),          
        .avalon_st_tx_empty                         (avalon_st_tx_empty),               
        .avalon_st_tx_error                         (avalon_st_tx_error),              
        .avalon_st_tx_data                          (avalon_st_tx_data),        
        .avalon_st_txstatus_valid                   (avalon_st_txstatus_valid),        
        .avalon_st_txstatus_data                    (avalon_st_txstatus_data),          
        .avalon_st_txstatus_error                   (avalon_st_txstatus_error), 
        
        // Avalon-ST RX
        .avalon_st_rx_ready                         (avalon_st_rx_ready),             
        .avalon_st_rx_valid                         (avalon_st_rx_valid),             
        .avalon_st_rx_startofpacket                 (avalon_st_rx_startofpacket),   
        .avalon_st_rx_endofpacket                   (avalon_st_rx_endofpacket),          
        .avalon_st_rx_empty                         (avalon_st_rx_empty),               
        .avalon_st_rx_error                         (avalon_st_rx_error),              
        .avalon_st_rx_data                          (avalon_st_rx_data),   
        .avalon_st_rxstatus_valid                   (avalon_st_rxstatus_valid),       
        .avalon_st_rxstatus_error                   (avalon_st_rxstatus_error),         
        .avalon_st_rxstatus_data                    (avalon_st_rxstatus_data),   
          
        // Timestamp TX
        .tx_egress_timestamp_request_valid              (tx_ts_req_valid),
        .tx_egress_timestamp_request_fingerprint        (tx_egress_timestamp_request_fingerprint),  
        

        .tx_estamp_ins_ctrl_residence_time_update       (tx_estamp_ins_ctrl_residence_time_update),
        .tx_estamp_ins_ctrl_ingress_timestamp_96b       (tx_ingress_timestamp_96b_data),
        .tx_estamp_ins_ctrl_ingress_timestamp_64b       (tx_ingress_timestamp_64b_data),
        .tx_estamp_ins_ctrl_residence_time_calc_format  (tx_ingress_timestamp_format),
        .clock_operation_mode_mode                      (clock_mode),
        .pkt_with_crc_mode                              (pkt_with_crc),
        
        .tx_egress_timestamp_96b_valid                  (tx_egress_timestamp_96b_valid),
        .tx_egress_timestamp_96b_data                   (tx_egress_timestamp_96b_data),  
        .tx_egress_timestamp_96b_fingerprint            (tx_egress_timestamp_96b_fingerprint),  
        .tx_egress_timestamp_64b_valid                  (tx_egress_timestamp_64b_valid),
        .tx_egress_timestamp_64b_data                   (tx_egress_timestamp_64b_data),  
        .tx_egress_timestamp_64b_fingerprint            (tx_egress_timestamp_64b_fingerprint),  
        
        // Timestamp RX
        .rx_ingress_timestamp_96b_valid               (rx_ingress_timestamp_96b_valid),      
        .rx_ingress_timestamp_96b_data                (rx_ingress_timestamp_96b_data),    
        .rx_ingress_timestamp_64b_valid               (rx_ingress_timestamp_64b_valid),      
        .rx_ingress_timestamp_64b_data                (rx_ingress_timestamp_64b_data),   
        
        // 10GBASE-R
        .rx_serial_data_export                      (rx_serial_data),        
        .tx_serial_data_export                      (tx_serial_data),  
      
        .tx_ready_export                            (tx_ready_export),
        .rx_ready_export                            (rx_ready_export),
        .avalon_st_pause_data                       (2'b00),
        .link_fault_status_xgmii_rx_data            (link_fault_status_xgmii_rx_data),
        .pps_10g_out                                (pps_10g_out),
		
		//no TOD synchronization, set all to 0
		.eth_1588_tod_time_of_day_96b_load_data(96'h0), 
		.eth_1588_tod_time_of_day_96b_load_valid(1'h0),
		.eth_1588_tod_time_of_day_64b_load_data(64'h0), 
		.eth_1588_tod_time_of_day_64b_load_valid(1'h0)			
    );
    
    
    
    //Implement all the test case in tb_testcase.v
    tb_testcase TESTCASE (
		.clk(xgmii_clk),
        .reset(reset)
    );
    
    
    
    // Avalon-MM and Avalon-ST signals driver
    avalon_driver U_AVALON_DRIVER (
		.avalon_mm_csr_clk          (clk_50),
		.avalon_st_rx_clk           (xgmii_clk),
		.avalon_st_tx_clk           (xgmii_clk),
        
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
        .avalon_st_tx_error         (avalon_st_tx_error),
        
        .tx_egress_timestamp_request_valid          (tx_egress_timestamp_request_valid), 
        .tx_egress_timestamp_request_fingerprint    (tx_egress_timestamp_request_fingerprint),
        
        .tx_ingress_timestamp_valid                 (tx_ingress_timestamp_valid),
		.tx_ingress_timestamp_96b_data				(tx_ingress_timestamp_96b_data),
		.tx_ingress_timestamp_64b_data				(tx_ingress_timestamp_64b_data),
		.tx_ingress_timestamp_format                (tx_ingress_timestamp_format)
	);
    

    // Ethernet packet monitor on Avalon-ST RX path
    avalon_st_eth_packet_monitor #(
		.ST_ERROR_W                 (AVALON_ST_RX_ST_ERROR_W)
    ) U_MON_RX (
		.clk                        (xgmii_clk),
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
		.clk                        (xgmii_clk),
        .reset                      (reset),
        
        .startofpacket              (tx_sop),
        .endofpacket                (tx_eop),
        .valid                      (avalon_st_tx_valid),
        .ready                      (avalon_st_tx_ready),
        .data                       (avalon_st_tx_data),
        .empty                      (avalon_st_tx_empty),
        .error                      (avalon_st_tx_error)
    );

    


    
    //Stimulus

    bit [3:0]  period_nsecond;
    bit [15:0] period_fnsecond;
    bit [15:0] adjust_nsecond;
    bit [15:0] adjust_fnsecond;   
    
    
    
    // Data read from CSR
    bit [31:0]  readdata;
    
    // CSR Configuration
    task automatic configure_csr_basic();
        // TX CRC Inserter (0x4200)
        // Enable CRC insertion on TX
        U_AVALON_DRIVER.avalon_mm_csr_wr(TX_CRC_INSERT_CONTROL_ADDR, {1'b1, 1'b1});
        
        // TX Address Inserter (0x4800)
        // Enable source address insertion on TX
        U_AVALON_DRIVER.avalon_mm_csr_wr(TX_ADDRESS_INSERT_CONTROL_ADDR, 1);    
        
        // Configure unicast address for TX (0x4804, 0x4808)
        U_AVALON_DRIVER.avalon_mm_csr_wr(TX_ADDRESS_INSERT_UCAST_MAC_ADD_0_ADDR, MAC_ADDR[31:0]);
        U_AVALON_DRIVER.avalon_mm_csr_wr(TX_ADDRESS_INSERT_UCAST_MAC_ADD_1_ADDR, MAC_ADDR[47:32]);   

        // Configure frame address for RX (0x2008, 0x200c)
        U_AVALON_DRIVER.avalon_mm_csr_wr(RX_FRAME_0_ADDR, MAC_ADDR[31:0]);
        U_AVALON_DRIVER.avalon_mm_csr_wr(RX_FRAME_1_ADDR, MAC_ADDR[47:32]);   
   
    endtask
    
    
    task automatic configure_csr_1588(bit [1:0] clk_mode, bit [3:0] period_ns, bit [15:0] period_fns, bit [15:0] adjust_ns, bit [15:0] adjust_fns);
		clock_mode = clk_mode;
        period_nsecond = period_ns;
        period_fnsecond = period_fns;
        adjust_nsecond = adjust_ns;
        adjust_fnsecond = adjust_fns;
      
        // TX XGMII PTP Inserter (0x4480)
        // Configure Clock Mode
        U_AVALON_DRIVER.avalon_mm_csr_wr(TX_CLOCK_MODE_CONTROL_ADDR, clock_mode);
        
        // TX XGMII TSU (0x4440) & RX XGMII TSU (0x0440)
        // Configure Period and Adjustment
        U_AVALON_DRIVER.avalon_mm_csr_wr(RX_PERIOD_ADDR, (period_nsecond << TSU_PERIOD_NS_OFFSET) | (period_fnsecond << TSU_PERIOD_FNS_OFFSET));
        U_AVALON_DRIVER.avalon_mm_csr_wr(TX_PERIOD_ADDR, (period_nsecond << TSU_PERIOD_NS_OFFSET) | (period_fnsecond << TSU_PERIOD_FNS_OFFSET));
        U_AVALON_DRIVER.avalon_mm_csr_wr(RX_ADJUST_FNS_ADDR, (adjust_fnsecond << TSU_ADJUST_FNS_OFFSET));
        U_AVALON_DRIVER.avalon_mm_csr_wr(RX_ADJUST_NS_ADDR, (adjust_nsecond << TSU_ADJUST_NS_OFFSET));
        U_AVALON_DRIVER.avalon_mm_csr_wr(TX_ADJUST_FNS_ADDR, (adjust_fnsecond << TSU_ADJUST_FNS_OFFSET));
        U_AVALON_DRIVER.avalon_mm_csr_wr(TX_ADJUST_NS_ADDR, (adjust_nsecond << TSU_ADJUST_NS_OFFSET));
      
    endtask 
	
    
    task automatic configure_csr_tod();
		
		//configure TX TOD
		U_AVALON_DRIVER.avalon_mm_csr_wr(TOD_SECOND_H, {16'h0,16'h0});
		U_AVALON_DRIVER.avalon_mm_csr_wr(TOD_SECOND_L, 32'h00000000);
		U_AVALON_DRIVER.avalon_mm_csr_wr(TOD_NANOSECOND, {2'h0,30'h3B9A_C900});
     
    endtask 	
    
    


    // Queues
    ptp_timestamp tx_timestamp_q[$];
    ptp_timestamp rx_timestamp_q[$];    
    eth_mac_frame mac_frame_expected_q[$];

 	//Global handle
	ptp_timestamp tx_timestamp;
	ptp_timestamp rx_timestamp;
	
	//Source/Sink Packet Number
	integer unsigned source_num_frame; 
	integer unsigned sink_num_frame; 	

    // Capture TX Ingress Timestamp
    initial begin             

        forever begin
            @(posedge tx_sop);
               
                tx_timestamp = new();
                tx_timestamp.timestamp_req_valid = tx_egress_timestamp_request_valid;
                tx_timestamp.ingress_timestamp_valid = tx_ingress_timestamp_valid;
                tx_timestamp.ingress_timestamp_format = tx_ingress_timestamp_format;
                tx_timestamp.ingress_time_96b_second = tx_ingress_timestamp_96b_data[95:48];
                tx_timestamp.ingress_time_96b_nsecond = tx_ingress_timestamp_96b_data[47:16];
                tx_timestamp.ingress_time_96b_fnsecond = tx_ingress_timestamp_96b_data[15:0];
                tx_timestamp.ingress_time_64b_nsecond = tx_ingress_timestamp_64b_data[63:16];
                tx_timestamp.ingress_time_64b_fnsecond = tx_ingress_timestamp_64b_data[15:0];
                tx_timestamp.ingress_fingerprint   = tx_egress_timestamp_request_fingerprint;
                
                if (!tx_ts_req_valid) begin
                    
                    tx_timestamp.egress_timestamp_valid = 1'b0;
                    tx_timestamp.egress_time_96b_second = 48'h0;
                    tx_timestamp.egress_time_96b_nsecond = 32'h0;
                    tx_timestamp.egress_time_96b_fnsecond = 16'h0;
                    tx_timestamp.egress_time_64b_nsecond = 48'h0;
                    tx_timestamp.egress_time_64b_fnsecond = 16'h0;
                    tx_timestamp.egress_fingerprint = {TIMESTAMP_FINGERPRINT_WIDTH{1'b0}};
                    
                    tx_timestamp_q.push_back(tx_timestamp);
                end     
            
        end
    end
 


    // Capture TX Egress Timestamp
    initial begin

        
        forever begin
            @(posedge tx_egress_timestamp_96b_valid);
            
            // Store the timestamp generated by TX XGMII TSU
            tx_timestamp.egress_timestamp_valid = tx_egress_timestamp_96b_valid; // or tx_egress_timestamp_64b_valid, they are identical
            tx_timestamp.egress_time_96b_second = tx_egress_timestamp_96b_data[95:48];
            tx_timestamp.egress_time_96b_nsecond = tx_egress_timestamp_96b_data[47:16];
            tx_timestamp.egress_time_96b_fnsecond = tx_egress_timestamp_96b_data[15:0];
            tx_timestamp.egress_time_64b_nsecond = tx_egress_timestamp_64b_data[63:16];
            tx_timestamp.egress_time_64b_fnsecond = tx_egress_timestamp_64b_data[15:0];
            tx_timestamp.egress_fingerprint = tx_egress_timestamp_96b_fingerprint; // or tx_egress_timestamp_64b_fingerprint, they are identical
            
            tx_timestamp_q.push_back(tx_timestamp);
            
        end       
    end
 
    
    
    // Capture RX Egress Timestamp
    initial begin
 
        forever begin
            @(posedge rx_ingress_timestamp_96b_valid);

            
            // Store the timestamp generated by RX XGMII TSU
            rx_timestamp = new();
            
            rx_timestamp.egress_timestamp_valid = rx_ingress_timestamp_96b_valid; // or rx_ingress_timestamp_64b_valid, they are identical
            rx_timestamp.egress_time_96b_second = rx_ingress_timestamp_96b_data[95:48];
            rx_timestamp.egress_time_96b_nsecond = rx_ingress_timestamp_96b_data[47:16];
            rx_timestamp.egress_time_96b_fnsecond = rx_ingress_timestamp_96b_data[15:0];
            rx_timestamp.egress_time_64b_nsecond = rx_ingress_timestamp_64b_data[63:16];
            rx_timestamp.egress_time_64b_fnsecond = rx_ingress_timestamp_64b_data[15:0];
            
            rx_timestamp_q.push_back(rx_timestamp);

        end
    end
 
 

 
    //display timestamp and correction field data
    initial begin
        
        integer unsigned rx_num_timestamp;
        integer unsigned tx_num_timestamp;
        
        ptp_timestamp tx_timestamp_temp;
        ptp_timestamp rx_timestamp_temp;
        eth_mac_frame mac_frame_source;
        
        
        forever begin
            @(U_MON_RX.frame_complete);
            
            source_num_frame = U_MON_RX.mac_frame_q.size();
            sink_num_frame = U_MON_TX.mac_frame_q.size();
            mac_frame_source = U_MON_RX.mac_frame_q[source_num_frame-1];
            mac_frame_source.analyze_frame(clock_mode);
            
            tx_timestamp_temp = tx_timestamp_q[source_num_frame - 1];
            rx_timestamp_temp = rx_timestamp_q[source_num_frame - 1]; 
            
            // Display PTP info from packet
            $display("------------------------------");
            $display("PTP Info of This Packet");
            $display("------------------------------");
            if (mac_frame_source.ptp_ethernet) begin
                $display("Type                         : Basic PTP");
            end else if (mac_frame_source.ipv4_header) begin
                $display("Type                         : IPV4");
            end else if (mac_frame_source.ipv6_header) begin
                $display("Type                         : IPV6");
            end else begin
                $display("Type                         : Invalid PTP Packet Type!");
            end 
            
            if (mac_frame_source.vlan_tag == 0) begin
                $display("Transport Layer              : Untagged");
            end else if (mac_frame_source.vlan_tag == 1) begin
                $display("Transport Layer              : VLAN");
            end else if (mac_frame_source.vlan_tag == 2) begin
                $display("Transport Layer              : STACKED VLAN");
            end else begin
                $display("Transport Layer              : Invalid VLAN!");
            end 
            
            if (mac_frame_source.clock_mode == ORDINARY_CLOCK) begin
                $display("Clock Mode                   : Ordinary Clock");
            end else if (mac_frame_source.clock_mode == BOUNDARY_CLOCK) begin
                $display("Clock Mode                   : Boundary Clock");
            end else if (mac_frame_source.clock_mode == E2E_TRANSPARENT_CLOCK) begin
                $display("Clock Mode                   : End To End Transparent Clock");
            end else if (mac_frame_source.clock_mode == P2P_TRANSPARENT_CLOCK) begin
                $display("Clock Mode                   : Peer To Peer Transparent Clock");
            end else begin
                $display("Clock Mode                   : Invalid Clock Mode");
            end     

            if (mac_frame_source.ptp_message_type == MSG_SYNC) begin
                $display("PTP Message Type             : Sync");
            end else if (mac_frame_source.ptp_message_type == MSG_DELAY_REQ) begin
                $display("PTP Message Type             : Delay Request");
            end else if (mac_frame_source.ptp_message_type == MSG_PDELAY_REQ) begin
                $display("PTP Message Type             : Pdelay Request");
            end else if (mac_frame_source.ptp_message_type == MSG_PDELAY_RESP) begin
                $display("PTP Message Type             : Pdelay Response");
            end else begin
                $display("PTP Message Type             : Non Event Message");
            end     

            if (mac_frame_source.ptp_message_flag == 1'b0) begin
                $display("2-step Flag                  : 0");
            end else begin
                $display("2-step Flag                  : 1");
            end 
            
            if (tx_timestamp_temp.timestamp_req_valid == 1'b1) begin
                $display("Timestamp Request Valid      : Yes");
            end else begin
                $display("Timestamp Request Valid      : No");
            end
            
            if (tx_timestamp_temp.ingress_timestamp_valid == 1'b1) begin
                $display("TX Ingress Timestamp Valid   : Yes");
            end else begin
                $display("TX Ingress Timestamp Valid   : No");
            end
            
            $display("TX Fingerprint Valid         : 0x%X", tx_timestamp_temp.timestamp_req_valid);
            $display("TX Fingerprint Data          : 0x%X", tx_timestamp_temp.egress_fingerprint);
            
            $display("TX Ingress Timestamp Valid   : 0x%X", tx_timestamp_temp.ingress_timestamp_valid);
            $display("TX Ingress Timestamp Format  : %s", tx_timestamp_temp.ingress_timestamp_format ? "64-bits" : "96-bits");
            $display("TX Ingress Timestamp 96-bits : -");
            $display("                Second Field : 0x%X", tx_timestamp_temp.ingress_time_96b_second);
            $display("            Nanosecond Field : 0x%X", tx_timestamp_temp.ingress_time_96b_nsecond);
            $display(" Fractional Nanosecond Field : 0x%X", tx_timestamp_temp.ingress_time_96b_fnsecond);
            $display("TX Ingress Timestamp 64-bits : -");
            $display("            Nanosecond Field : 0x%X", tx_timestamp_temp.ingress_time_64b_nsecond);
            $display(" Fractional Nanosecond Field : 0x%X", tx_timestamp_temp.ingress_time_64b_fnsecond);
            
            $display("TX Egress Timestamp 96-bits  : -");
            $display("                Second Field : 0x%X", tx_timestamp_temp.egress_time_96b_second);
            $display("            Nanosecond Field : 0x%X", tx_timestamp_temp.egress_time_96b_nsecond);
            $display(" Fractional Nanosecond Field : 0x%X", tx_timestamp_temp.egress_time_96b_fnsecond);
            $display("TX Egress Timestamp 64-bits  : -");
            $display("            Nanosecond Field : 0x%X", tx_timestamp_temp.egress_time_64b_nsecond);
            $display(" Fractional Nanosecond Field : 0x%X", tx_timestamp_temp.egress_time_64b_fnsecond);
            
            $display("RX Ingress Timestamp 96-bits : -");
            $display("                Second Field : 0x%X", rx_timestamp_temp.egress_time_96b_second);
            $display("            Nanosecond Field : 0x%X", rx_timestamp_temp.egress_time_96b_nsecond);
            $display(" Fractional Nanosecond Field : 0x%X", rx_timestamp_temp.egress_time_96b_fnsecond);
            $display("RX Ingress Timestamp 64-bits : -");
            $display("            Nanosecond Field : 0x%X", rx_timestamp_temp.egress_time_64b_nsecond);
            $display(" Fractional Nanosecond Field : 0x%X", rx_timestamp_temp.egress_time_64b_fnsecond);
            
            $display("Correction Field             : 0x%X", mac_frame_source.ptp_correction_field);
            $display("TimeStamp Field              : 0x%X\n\n", mac_frame_source.ptp_timestamp);
            $display("\n\n\n\n");
        end
    end
    


 
 
 
 endmodule
  
`endif
