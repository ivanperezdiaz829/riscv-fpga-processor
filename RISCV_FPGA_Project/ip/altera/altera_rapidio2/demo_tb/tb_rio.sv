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



`timescale 10ps/1ps
`define SMALL 2'b00
`define LARGE 2'b01


module tb_rio;

 import altera_rapidio2_tb_var_functions::*;
 import altera_xcvr_functions::*; // for get_custom_reconfig_width functions.

 
//------------------------------------------------------------
//Transport and Logical Layer Registers
//------------------------------------------------------------
//------------------------------------------------------------
//Capability Registers (CARs)
//------------------------------------------------------------
`define DEVICE_ID_CAR                        32'h00000000
`define DEVICE_INFO_CAR                      32'h00000004
`define ASSY_ID_CAR                          32'h00000008
`define ASSY_INFO_CAR                        32'h0000000c
`define PROC_ELEMENT_FEATURE_CAR             32'h00000010
`define SWITCH_PORT_INFO_CAR                 32'h00000014
`define SOURCE_OPER_CAR                      32'h00000018
`define DEST_OPER_CAR                        32'h0000001c
//------------------------------------------------------------
//Command and Status Registers (CSRs)
//------------------------------------------------------------
`define PROC_ELEMENT_LOGIC_CNTRL_CSR       32'h0000004c
`define LOCAL_CONFIG_SPACE_BASE_ADDR0_CSR  32'h00000058
`define LOCAL_CONFIG_SPACE_BASE_ADDR1_CSR  32'h0000005c
`define BASE_DEVICE_ID_CSR                 32'h00000060
`define HOST_BASED_DEVICE_ID_LOCK_CSR      32'h00000068
`define COMP_TAG_CSR                       32'h0000006c
//------------------------------------------------------------
//Maintenance Interrupt Control Registers
//------------------------------------------------------------ 

`define MAINTENANCE_INTERRUPT             32'h00010080
`define MAINTENANCE_INTERRUPT_ENABLE      32'h00010084
`define TX_MAINTENANCE_WINDOW_0_BASE      32'h00010100
`define TX_MAINTENANCE_WINDOW_0_MASK      32'h00010104
`define TX_MAINTENANCE_WINDOW_0_OFFSET    32'h00010108
`define TX_MAINTENANCE_WINDOW_0_CONTROL   32'h0001010C
`define TX_PORT_WRITE_CONTROL             32'h00010200
`define TX_PORT_WRITE_BUFFER              32'h00010210
`define RX_PORT_WRITE_CONTROL             32'h00010250
`define RX_PORT_WRITE_STATUS              32'h00010254
`define RX_PORT_WRITE_BUFFER              32'h00010260
//--------------------------------------------------------
//
//-------------------------------------------------------
`define IO_MASTER_MAP_WINDOW_0_BASE       32'h00010300
`define IO_MASTER_MAP_WINDOW_0_MASK       32'h00010304
`define IO_MASTER_MAP_WINDOW_0_OFFSET     32'h00010308
`define IO_SLAVE_MAP_WINDOW_0_BASE        32'h00010400
`define IO_SLAVE_MAP_WINDOW_0_MASK        32'h00010404
`define IO_SLAVE_MAP_WINDOW_0_OFFSET      32'h00010408
`define IO_SLAVE_MAP_WINDOW_0_CONTROL     32'h0001040C
`define IO_SLAVE_INTERRUPT                32'h00010500
`define IO_SLAVE_INTERRUPT_ENABLE         32'h00010504
`define IO_SLAVE_PENDING_NWRITE_R_TRANS   32'h00010508
`define IO_SLAVE_AVALON_MM_WRITE          32'h0001050C
`define IO_SLAVE_RIO_REQ_WRITE            32'h00010510
//-------------------------------------------------------------
//Transport Layer Feature Register
//-------------------------------------------------------------
`define RX_TRANSPORT_CONTROL              32'h00010600
//-------------------------------------------------------------
//Doorbell Message Registers
//-------------------------------------------------------------
`define DRBELL_RX_DOORBELL                 4'b0000
`define PORT_GEN_CTRL_CSR                 32'h0000013c
`define TX_DRBL_CNTRL                     32'h00000008
`define TX_DRBL_STATUS                    32'h00000010

`define DRBL_RX_STATUS                     4'b0001
`define DRBELL_TX_CNTRL                    4'b0010
`define DRBELL_TX_DOORBELL                 4'b0011
`define DRBL_TX_STATUS                     4'b0100
`define DRBELL_TX_COMPLETION               4'b0101
`define DRBELL_TX_COMPLETION_STATUS        4'b0110
`define DRBELL_TX_STATUS_CNTRL             4'b0111
`define DRBELL_INTR_ENABLE                 4'b1000
`define DRBELL_INTR_STATUS                 4'b1001


`define GENERAL_CONTROL                   32'h0000013C
`define PORT_STATUS                       32'h00000158
`define PORT_CONTROL                      32'h0000015C
`define PORT_0_TIMEOUT_CSR                32'h00000124 // temporary reg

//---------------------------------------------------------------
//---------------------------------------------------------------
//
//---------------------------------------------------------------
//
//---------------------------------------------------------------
`define READ    1'b0
`define WRITE   1'b1

//io slave macro definations
`define NWRITE     2'b00
`define NWRITE_R   2'b01
`define SWRITE     2'b10
`define NREAD      2'b11 //?? 

// Interrupts bits
`define NWRITE_RS_COMPLETED 4
//------------------------------------------------------------------
// End of register default value setting
//------------------------------------------------------------------

//------------------------------------------------------------------
// TB Hookup
//------------------------------------------------------------------
//----------------------------
  // Control Signal Declarations
  //----------------------------
  reg sys_clk;
  reg rst_n;
  reg sister_rst_n;
 
  //----------------------------
  //------- CAR Inputs ---------
  //----------------------------
  logic [15:0]   car_device_id;
  logic [15:0]   car_device_vendor_id;
  logic [31:0]   car_device_revision_id;
  logic [15:0]   car_assey_id;
  logic [15:0]   car_assey_vendor_id;
  logic [15:0]   car_revision_id;
  logic          car_bridge;
  logic          car_memory; 
  logic          car_processor;
  logic          car_switch;
  logic [7:0]    car_num_of_ports;
  logic [7:0]    car_port_num;
  logic          car_extended_route_table;
  logic          car_standard_route_table;
  logic          car_flow_arbitration;
  logic          car_flow_control;
  logic [15:0]   car_max_pdu_size;
  logic [15:0]   car_segmentation_contexts;
  logic [15:0]   car_max_destid;
  logic [31:0]   car_source_operations;
  logic [31:0]   car_destination_operations;
 
  //----------------------------
  //------- CSR Inputs ---------
  //----------------------------
  
  logic [3:0]    csr_tm_types_reset_value; 
  logic [3:0]    csr_tm_mode_reset_value;
  logic [7:0]    csr_mtu_reset_value;
  logic          csr_external_tm_mode_wr;
  logic          csr_external_mtu_wr;
  logic [3:0]    csr_external_tm_mode_in;
  logic [7:0]    csr_external_mtu_in;
  
  //----------------------------
  //-- Error Management Inputs -
  //----------------------------
  
  logic          message_error_response_set;
  logic          gsm_error_response_set;
  logic          message_format_error_response_set;
  logic          external_illegal_transaction_decode_set;
  logic          external_message_request_timeout_set;
  logic          external_slave_packet_response_timeout_set;
  logic          external_unsolicited_response_set;
  logic          external_unsupported_transaction_set;
  logic          external_illegal_transaction_target_error_set;
  logic          external_missing_data_streaming_context_set;
  logic          external_open_existing_data_streaming_context_set;
  logic          external_long_data_streaming_segment_set;
  logic          external_short_data_streaming_segment_set;
  logic          external_data_streaming_pdu_length_error_set;
  logic          external_capture_destinationID_wr;
  logic   [15:0] external_capture_destinationID_in;
  logic          external_capture_sourceID_wr;
  logic   [15:0] external_capture_sourceID_in;
  logic          external_capture_ftype_wr;
  logic   [3:0]  external_capture_ftype_in; 
  logic          external_capture_ttype_wr;
  logic   [3:0]  external_capture_ttype_in;
  logic          external_letter_wr;
  logic   [1:0]  external_letter_in;
  logic          external_mbox_wr;
  logic   [1:0]  external_mbox_in;
  logic          external_msgseg_wr;
  logic   [3:0]  external_msgseg_in;
  logic          external_xmbox_wr;
  logic   [3:0]  external_xmbox_in;

  //--------------------------------------
  // CAR; CSR and Error Management Outputs
  //--------------------------------------
  
  logic  [7:0]   base_device_id;
  logic  [15:0]  large_base_device_id;
  logic  [3:0]   tm_types;
  logic  [3:0]   tm_mode;
  logic  [7:0]   mtu;
  logic          port_degraded;
  logic          port_failed;
  logic          al_transport_error;
  logic  [15:0]  time_to_live;

  //------------------------------------------------------------
  // Physical Layer Register (Lp-Serial & Lp-Serial Lane) Inputs
  //------------------------------------------------------------
  logic          host_reset_value;  
  logic          master_enable_reset_value;
  logic          discovered_reset_value;
  logic          flow_control_participant_reset_value;
  logic          enumeration_boundary_reset_value;
  logic          flow_arbitration_participant_reset_value;
  logic          disable_destination_id_checking_reset_value;
  logic          transmitter_type_reset_value;
  logic   [1:0]  receiver_type_reset_value;
 
  //--------------------------------------
  // Extended Features Block Inputs
  //--------------------------------------
  logic [15:0]   ef_ptr_reset_value;

  //------------------------------
  // SRIO User visible Interfaces DUT 
  //------------------------------
  //----------------------------------------------------------
  // Maintenance Module User visible Avalon-MM Slave Interface
  //----------------------------------------------------------
   logic [25:0]  mnt_s_address;
   logic         mnt_s_write;                          
   logic [31:0]  mnt_s_writedata;
   logic         mnt_s_read;
   logic         mnt_s_waitrequest;                   
   logic         mnt_s_readdatavalid;
   logic [31:0]  mnt_s_readdata;                   
   logic         mnt_s_readerror;                    

  
  //-----------------------------------------------------------------------
  // IO Master User visible Avalon-MM Slave Interface Read-Write Interface
  // for 128 bit module
  //-----------------------------------------------------------------------
   logic         iom_rd_wr_readdatavalid;
   logic         iom_rd_wr_readresponse;
   logic [127:0] iom_rd_wr_readdata;
   logic         iom_rd_wr_waitrequest;
   logic         iom_rd_wr_read;      
   logic         iom_rd_wr_write;     
   logic [127:0] iom_rd_wr_writedata;                   
   logic [4:0]   iom_rd_wr_burstcount;
   logic [15:0]  iom_rd_wr_byteenable;
   logic [IO_MASTER_ADDRESS_WIDTH -1:0]  iom_rd_wr_address;                    

  //----------------------------------------------------------------------
  // IO Slave User visible Avalon-MM Slave Interface Read-Write Interface
  // for 128 bit module
  //----------------------------------------------------------------------
   logic [IO_SLAVE_ADDRESS_WIDTH -1:0] ios_rd_wr_address;                
   logic         ios_rd_wr_write;                  
   logic         ios_rd_wr_read;          
   logic [127:0] ios_rd_wr_writedata;              
   logic [4:0]   ios_rd_wr_burstcount;             
   logic [15:0]  ios_rd_wr_byteenable;             
   logic         ios_rd_wr_waitrequest;  
   logic [127:0] ios_rd_wr_readdata;                
   logic         ios_rd_wr_readresponse;               
   logic         ios_rd_wr_readdatavalid;
  
  //-----------------------------------------------------------------
  // IO Slave User visible Avalon-MM Slave Interface Write Interface
  // for 128 bit module
  //-----------------------------------------------------------------
   logic [IO_SLAVE_ADDRESS_WIDTH -1:0]  ios_wr_address;                
   logic         ios_wr_write;                  
   logic [127:0] ios_wr_writedata;              
   logic [15:0]  ios_wr_byteenable;             
   logic [4:0]   ios_wr_burstcount;             
   logic         ios_wr_waitrequest;
  
  //----------------------------------------------------------------
  // IO Slave User visible Avalon-MM Slave Interface Read Interface
  // for 128 bit module
  //----------------------------------------------------------------
   logic [IO_SLAVE_ADDRESS_WIDTH -1:0]  ios_rd_address;               
   logic         ios_rd_read;          
   logic [4:0]   ios_rd_burstcount;             
   logic [15:0]  ios_rd_byteenable;             
   logic         ios_rd_waitrequest;            
   logic [127:0] ios_rd_readdata;                  
   logic         ios_rd_readdatavalid;
   logic         ios_rd_readresponse;               

  //-------------------------------------------------
  // Doorbell User visible Avalon-MM Slave Interface
  //-------------------------------------------------
   logic         drbell_s_read;
   logic         drbell_s_write;
   logic [5:2]   drbell_s_address;
   logic [31:0]  drbell_s_writedata;
   logic         drbell_s_waitrequest;
   logic [31:0]  drbell_s_readdata;
  //-------------------------------------------------
  // Pass-through Avalon Payload and Header interface
  //-------------------------------------------------
  logic          gen_rx_pd_ready; 
  logic  [127:0] gen_rx_pd_data;
  logic          gen_rx_pd_valid;
  logic          gen_rx_pd_startofpacket;
  logic          gen_rx_pd_endofpacket;
  logic  [3:0]   gen_rx_pd_empty;

  logic          gen_rx_hd_ready; 
  logic  [114:0] gen_rx_hd_data;
  logic          gen_rx_hd_valid;

  logic          transport_rx_packet_dropped;        
 
  //--------------------------------------------------
  // Transmit Side of Avalon-ST Pass-Through Interface
  //--------------------------------------------------
  logic  [127:0] gen_tx_data;    
  logic          gen_tx_valid;
  logic          gen_tx_startofpacket;
  logic          gen_tx_endofpacket;
  logic  [3:0]   gen_tx_empty;
  logic          gen_tx_ready;
  logic  [8:0]   ext_tx_packet_size; 
  
  //------------------------------------------------------
  // Maintenance Bridge External Avalon-MM Slave Interface
  //------------------------------------------------------
  logic  [31:0]  ext_mnt_address;
  logic          ext_mnt_write;
  logic          ext_mnt_read;
  logic  [31:0]  ext_mnt_writedata; 
  logic          ext_mnt_waitrequest; 
  logic  [31:0]  ext_mnt_readdata;
  logic          ext_mnt_readdatavalid;
  logic          ext_mnt_readresponse;
  logic          ext_mnt_writeresponse;

  //---------------------------------------------------------------------
  // User Logic Avalon-MM Master interface Maintenance Register Interface 
  //---------------------------------------------------------------------
   logic         usr_mnt_waitrequest; 
   logic [31:0]  usr_mnt_readdata;
   logic         usr_mnt_readdatavalid;
   logic [31:0]  usr_mnt_address; 
   logic         usr_mnt_write; 
   logic         usr_mnt_read;
   logic [31:0]  usr_mnt_writedata;

  //------------------------
  // PHY IP reg and wire
  //------------------------
  logic [LSIZE - 1:0] rx_serial_data;               
  reg             pll_ref_clk;                               
  logic             send_multicast_event;
  logic             send_link_request_reset_device; 
  
  logic             sent_link_request_reset_device;
  logic             multicast_event_rx;
  logic             link_req_reset_device_received; 
  logic             sent_multicast_event;
      
  logic [LSIZE-1:0] tx_serial_data;               
  logic             port_initialized;                     
  logic             link_initialized;    
  logic             port_ok;                     
  logic             port_error;                     
  logic             packet_transmitted;                     
  logic             packet_cancelled;                     
  logic             packet_accepted_cs_sent;                     
  logic             packet_retry_cs_sent;                     
  logic             packet_not_accepted_cs_sent;                     
  logic             packet_accepted_cs_received;                     
  logic             packet_retry_cs_received;                    
  logic             packet_not_accepted_cs_received;
  logic             packet_crc_error;                     
  logic             control_symbol_error;                    
  logic  [LSIZE-1:0] rx_syncstatus;                
  logic  [LSIZE-1:0]            tx_ready;                    
  logic  [LSIZE-1:0]            rx_ready;                    
  logic  [0:0]           pll_locked;                    
                  
  logic  [LSIZE-1:0] rx_is_lockedtoref;                    
  logic  [LSIZE-1:0] rx_is_lockedtodata;                    
  logic  [LSIZE-1:0] rx_signaldetect;
  logic              rx_clkout;                         
  logic              tx_clkout;   
  localparam  number_of_reconfig_interfaces   = ( SUPPORT_4X ) ? 5 : (( SUPPORT_2X )? 3 : 2 );
  logic  [altera_xcvr_functions::get_reconfig_to_width(DEVICE_FAMILY,number_of_reconfig_interfaces)-1:0] reconfig_to_xcvr_input;  
  // SYS_CLK_PERIOD is in ps and since the timescale is based on 10ps/1ps, we are dividing the SYS_CLK_PERIOD with 20 instead of 2 for half clock cycle's period value
  localparam SYS_CLK_HALF_CYCLE_PERIOD = SYS_CLK_PERIOD / 20;
  localparam REF_CLK_HALF_CYCLE_PERIOD = REF_CLK_PERIOD / 20;
  localparam DIFF_32_IO_SLAVE_ADDRESS_WIDTH = 32 - IO_SLAVE_ADDRESS_WIDTH;
    
  logic [31:0] mnt_s_address_bfm;  
                                
  logic [28:0] tb_rio_address = 29'b1110_1010_1101_1011_1110_1110_1111_0;  

          
  
 //------------------
 // Interrupt Signals
 //------------------
  logic  std_reg_mnt_irq ;            
  logic  mnt_mnt_s_irq   ;            
  logic  io_m_mnt_irq    ;            
  logic  io_s_mnt_irq    ;            
  logic  drbell_s_irq    ; 
  logic  master_enable   ;
//---------------------------------------------------------------------------
// Internal signals declarations
//----------------------------------------------------------------------------

  logic [7:0]   i_device_id_high; 
  logic [7:0]   i_device_id_low;
  logic [15:0]  i_device_vendor_id;
  logic [31:0]  i_device_revision_id;

  logic [15:0]  i_assey_id;
  logic [15:0]  i_assey_vendor_id;
  logic [15:0]  i_revision_id;
  logic [15:0]  i_ef_ptr;
  logic         i_bridge;
  logic         i_memory; 
  logic         i_processor;
  logic         i_switch;
  logic [7:0]   i_num_of_ports;
  logic [7:0]   i_port_num;
  logic         i_extended_route_table;
  logic         i_standard_route_table;
  logic         i_flow_arregration;
  logic         i_flow_control;
  logic [15:0]  i_max_pdu_size;
  logic [15:0]  i_segmentation_contexts;
  logic [15:0]  i_max_destid;
  logic [31:0]  i_source_operations;
  logic [31:0]  i_destination_operations;
  logic         i_flow_arbitration;
    
  logic [3:0]   i_csr_tm_types_reset_value; 
  logic [3:0]   i_csr_tm_mode_reset_value;
  logic [7:0]   i_csr_mtu_reset_value;
  logic         i_csr_external_tm_mode_wr;
  logic         i_csr_external_mtu_wr;
  logic [3:0]   i_csr_external_tm_mode_in;
  logic [7:0]   i_csr_external_mtu_in;
  
  logic         i_message_error_response_set;
  logic         i_gsm_error_response_set;
  logic         i_message_format_error_response_set;
  logic         i_external_illegal_transaction_decode_set;
  logic         i_external_message_request_timeout_set;
  logic         i_external_slave_packet_response_timeout_set;
  logic         i_external_unsolicited_response_set;
  logic         i_external_unsupported_transaction_set;
  logic         i_external_missing_data_streaming_context_set;
  logic         i_external_open_existing_data_streaming_context_set;
  logic         i_external_long_data_streaming_segment_set;
  logic         i_external_short_data_streaming_segment_set;
  logic         i_external_data_streaming_pdu_length_error_set;
  logic         i_external_capture_destinationID_wr;
  logic [15:0]  i_external_capture_destinationID_in;
  logic         i_external_capture_sourceID_wr;
  logic [15:0]  i_external_capture_sourceID_in;
  logic         i_external_capture_ftype_wr;
  logic [3:0]   i_external_capture_ftype_in; 
  logic         i_external_capture_ttype_wr;
  logic [3:0]   i_external_capture_ttype_in;
  logic         i_external_letter_wr;
  logic [1:0]   i_external_letter_in;
  logic         i_external_mbox_wr;
  logic [1:0]   i_external_mbox_in;
  logic         i_external_msgseg_wr;
  logic [3:0]   i_external_msgseg_in;
  logic         i_external_xmbox_wr;
  logic [3:0]   i_external_xmbox_in;
  
  
  logic         i_host_reset_value;  
  logic         i_master_enable_reset_value;
  logic         i_discovered_reset_value;
  logic         i_flow_control_participant_reset_value;
  logic         i_enumeration_boundary_reset_value;
  logic         i_flow_arbitration_participant_reset_value;
  logic         i_disable_destination_id_checking_reset_value;
  logic         i_transmitter_type_reset_value;
  logic [1:0]   i_receiver_type_reset_value;

//----------------------------------------------------------------------------
//
//----------------------------------------------------------------------------

  initial begin
    i_device_id_low = $random;
    i_device_id_high  = $random;
    i_device_vendor_id = $random ;
    i_device_revision_id = $random;

    i_assey_id = $random;
    i_assey_vendor_id  = $random;
    i_revision_id  = $random;
    i_ef_ptr = 16'h0100;
    i_bridge = 1'b0;
    i_memory = 1'b0; 
    i_processor = 1'b0;
    i_switch = 1'b0;
    i_num_of_ports = 1;
    i_port_num = 1 ;
    i_extended_route_table = 0 ;
    i_standard_route_table  = 0 ;
    i_flow_arregration  = 0 ;
    i_flow_control  = 0 ;
    i_max_pdu_size  = 0 ;
    i_segmentation_contexts  = 0 ;
    i_max_destid = 0 ;
    i_source_operations  = 0 ;
    i_destination_operations  = 0 ;
    i_flow_arbitration = 1'b0;
    
    i_csr_tm_types_reset_value  = 0 ; 
    i_csr_tm_mode_reset_value  = 0 ;
    i_csr_mtu_reset_value  = 0 ;
    i_csr_external_tm_mode_wr  = 0 ;
    i_csr_external_mtu_wr  = 0 ;
    i_csr_external_tm_mode_in  = 0 ;
    i_csr_external_mtu_in  = 0 ;
   
    i_message_error_response_set = 0 ;
    i_gsm_error_response_set = 0;
    i_message_format_error_response_set = 0;
    i_external_illegal_transaction_decode_set = 0;
    i_external_message_request_timeout_set = 0;
    i_external_slave_packet_response_timeout_set = 0 ;
    i_external_unsolicited_response_set = 0 ;
    i_external_unsupported_transaction_set = 0 ;
    i_external_missing_data_streaming_context_set = 0 ;
    i_external_open_existing_data_streaming_context_set = 0 ;
    i_external_long_data_streaming_segment_set = 0 ;
    i_external_short_data_streaming_segment_set = 0 ;
    i_external_data_streaming_pdu_length_error_set = 0 ;
    i_external_capture_destinationID_wr = 0 ;
    i_external_capture_destinationID_in = 0 ;
    i_external_capture_sourceID_wr = 0 ;
    i_external_capture_sourceID_in = 0 ;
    i_external_capture_ftype_wr = 0 ;
    i_external_capture_ftype_in = 0 ; 
    i_external_capture_ttype_wr = 0 ;
    i_external_capture_ttype_in = 0 ;
    i_external_letter_wr = 0 ;
    i_external_letter_in = 0 ;
    i_external_mbox_wr = 0 ;
    i_external_mbox_in = 0 ;
    i_external_msgseg_wr = 0 ;
    i_external_msgseg_in = 0 ;
    i_external_xmbox_wr = 0 ;
    i_external_xmbox_in = 0 ;
   
   
    i_host_reset_value = 1'b1;  
    i_master_enable_reset_value  = 1'b1;
    i_discovered_reset_value  = 1'b1;
    i_flow_control_participant_reset_value  = 1'b1;
    i_enumeration_boundary_reset_value  = 1'b1;
    i_flow_arbitration_participant_reset_value = 1'b1 ;
    i_disable_destination_id_checking_reset_value = 1'b1 ;
    i_transmitter_type_reset_value  = 1'b1;
    i_receiver_type_reset_value =  2'b10;
  end // initial begin


//----------------------------------------------------------------------------
//
//----------------------------------------------------------------------------  

  assign  car_device_id [15:8] = i_device_id_high;
  assign  car_device_id [7:0] = i_device_id_low;
  assign  car_device_vendor_id = i_device_vendor_id;
  assign  car_device_revision_id = i_device_revision_id;
  assign  car_assey_id = i_assey_id;
  assign  car_assey_vendor_id = i_assey_vendor_id;
  assign  car_revision_id = i_revision_id;
  assign  car_bridge = i_bridge;
  assign  car_memory = i_memory; 
  assign  car_processor = i_processor;
  assign  car_switch = i_switch;
  assign  car_num_of_ports = i_num_of_ports;
  assign  car_port_num = i_port_num;
  assign  car_extended_route_table = i_extended_route_table;
  assign  car_standard_route_table = i_standard_route_table;
  assign  car_flow_arregration = i_flow_arregration;
  assign  car_flow_control =  i_flow_control;
  assign  car_max_pdu_size = i_max_pdu_size;
  assign  car_segmentation_contexts = i_segmentation_contexts;
  assign  car_max_destid = i_max_destid;
  assign  car_source_operations = i_source_operations;
  assign  car_destination_operations = i_destination_operations;
  assign  car_flow_arbitration = i_flow_arbitration;
    
  assign  csr_tm_types_reset_value =  i_csr_tm_types_reset_value; 
  assign  csr_tm_mode_reset_value = i_csr_tm_mode_reset_value;
  assign  csr_mtu_reset_value = i_csr_mtu_reset_value;
  assign  csr_external_tm_mode_wr = i_csr_external_tm_mode_wr;
  assign  csr_external_mtu_wr = i_csr_external_mtu_wr;
  assign  csr_external_tm_mode_in = i_csr_external_tm_mode_in;
  assign  csr_external_mtu_in = i_csr_external_mtu_in;
  
  assign  message_error_response_set = i_message_error_response_set;
  assign  gsm_error_response_set = i_gsm_error_response_set;
  assign  message_format_error_response_set = i_message_format_error_response_set;
  assign  external_illegal_transaction_decode_set =  i_external_illegal_transaction_decode_set;
  assign  external_message_request_timeout_set = i_external_message_request_timeout_set;
  assign  external_slave_packet_response_timeout_set = i_external_slave_packet_response_timeout_set;
  assign  external_unsolicited_response_set = i_external_unsolicited_response_set;
  assign  external_unsupported_transaction_set = i_external_unsupported_transaction_set;
  assign  external_missing_data_streaming_context_set = i_external_missing_data_streaming_context_set;
  
  assign  external_open_existing_data_streaming_context_set = i_external_open_existing_data_streaming_context_set;
  assign  external_long_data_streaming_segment_set = i_external_long_data_streaming_segment_set;
  assign  external_short_data_streaming_segment_set = i_external_short_data_streaming_segment_set;
  assign  external_data_streaming_pdu_length_error_set = i_external_data_streaming_pdu_length_error_set;
  assign  external_capture_destinationID_wr = i_external_capture_destinationID_wr;
  assign  external_capture_destinationID_in = i_external_capture_destinationID_in;
  assign  external_capture_sourceID_wr = i_external_capture_sourceID_wr;
  assign  external_capture_sourceID_in = i_external_capture_sourceID_in;
  assign  external_capture_ftype_wr = i_external_capture_ftype_wr;
  assign  external_capture_ftype_in = i_external_capture_ftype_in; 
  assign  external_capture_ttype_wr = i_external_capture_ttype_wr;
  assign  external_capture_ttype_in = i_external_capture_ttype_in;
  assign  external_letter_wr = i_external_letter_wr;
  assign  external_letter_in = i_external_letter_in;
  assign  external_mbox_wr = i_external_mbox_wr;
  assign  external_mbox_in = i_external_mbox_in;
  assign  external_msgseg_wr = i_external_msgseg_wr;
  assign  external_msgseg_in = i_external_msgseg_in;
  assign  external_xmbox_wr = i_external_xmbox_wr;
  assign  external_xmbox_in = i_external_xmbox_in;
  
  
  assign  host_reset_value = i_host_reset_value;  
  assign  master_enable_reset_value = i_master_enable_reset_value;
  assign  discovered_reset_value = i_discovered_reset_value;
  assign  flow_control_participant_reset_value = i_flow_control_participant_reset_value;
  assign  enumeration_boundary_reset_value = i_enumeration_boundary_reset_value;
  assign  flow_arbitration_participant_reset_value = i_flow_arbitration_participant_reset_value;
  assign  disable_destination_id_checking_reset_value = i_disable_destination_id_checking_reset_value;
  assign  transmitter_type_reset_value = i_transmitter_type_reset_value;
  assign  receiver_type_reset_value = i_receiver_type_reset_value;
  assign  ef_ptr_reset_value = i_ef_ptr;

  // For Hardware, the reconfig_to_xcvr input port is driven by the transceiver reconfiguration controller
  assign  reconfig_to_xcvr_input = {altera_xcvr_functions::get_reconfig_to_width(DEVICE_FAMILY,number_of_reconfig_interfaces){1'b0}};

  //---------------------------------------------------------------------   
  // DUT top  instantiation
  //---------------------------------------------------------------------
  
  //Physical + Transport Layer
  //Logical Layer modules disabled, No Err Mgmt Extn
  //Pass Through enabled
  //Small Transport System
  altera_rapidio2_top_with_reset_ctrl 
  #( //Parameters passed in from tb_hookup.sv (from parameters.v)
    .DEVICE_FAMILY (DEVICE_FAMILY) 
   ,.SUPPORT_4X (SUPPORT_4X)
   ,.SUPPORT_2X (SUPPORT_2X)
   ,.SUPPORT_1X (SUPPORT_1X)
   ,.ENABLE_TRANSPORT_LAYER(ENABLE_TRANSPORT_LAYER)
   ,.MAINTENANCE_SLAVE(MAINTENANCE_SLAVE)
   ,.MAINTENANCE_MASTER(MAINTENANCE_MASTER)
   ,.IO_SLAVE(IO_SLAVE)
    ,.IO_MASTER(IO_SLAVE)
    ,.DOORBELL(DOORBELL)
    ,.SYS_CLK_FREQ(SYS_CLK_FREQ)
	,.ERROR_MANAGEMENT_EXTENSION(ERROR_MANAGEMENT_EXTENSION)
     //----------------------------------------------------
     //------------ PHYSICAL LAYER PARAMETERS -------------
     //----------------------------------------------------
     ,.MAX_BAUD_RATE(MAX_BAUD_RATE)
     ,.REF_CLK_PERIOD(REF_CLK_PERIOD)
     ,.SYS_CLK_PERIOD(SYS_CLK_PERIOD)
     //----------------------------------------------------
     //----------- TRANSPORT LAYER PARAMETERS -------------
     //----------------------------------------------------
     ,.TRANSPORT_LARGE(TRANSPORT_LARGE)
     ,.PASS_THROUGH(PASS_THROUGH)
     ,.PROMISCUOUS(PROMISCUOUS)
     //----------------------------------------------------
     //------------ MAINTENANCE PARAMETERS ----------------
     //----------------------------------------------------
     ,.MAINTENANCE_ADDRESS_WIDTH(MAINTENANCE_ADDRESS_WIDTH)
     ,.PORT_WRITE_TX(PORT_WRITE_TX)
	 ,.PORT_WRITE_RX(PORT_WRITE_RX)
     //----------------------------------------------------
     //--------------- DOORBELL PARAMETERS ----------------  
     //----------------------------------------------------
     ,.DOORBELL_TX_ENABLE(DOORBELL_TX_ENABLE)     
     ,.DOORBELL_RX_ENABLE(DOORBELL_RX_ENABLE)
     ,.IO_SLAVE_DOORBELL_WRITES_ORDER_PRESERVATION(IO_SLAVE_DOORBELL_WRITES_ORDER_PRESERVATION)
     //----------------------------------------------------
     //--------------- IO MASTER PARAMETERS ---------------
     //----------------------------------------------------
     ,.IO_MASTER_WINDOWS(IO_MASTER_WINDOWS)         
      //----------------------------------------------------
     //---------------- IO SLAVE PARAMETERS ---------------
     //----------------------------------------------------
     ,.IO_SLAVE_WINDOWS(IO_SLAVE_WINDOWS)
     ,.IO_MASTER_ADDRESS_WIDTH(IO_MASTER_ADDRESS_WIDTH)
     ,.IO_SLAVE_ADDRESS_WIDTH(IO_SLAVE_ADDRESS_WIDTH)
     //----------------------------------------------------
     //---------------- PHY IP PARAMETERS ---------------
     //----------------------------------------------------	  
     ,.MAX_BAUD_RATE_WITH_UNIT(MAX_BAUD_RATE_WITH_UNIT)
     ,.REF_CLK_FREQ_WITH_UNIT(REF_CLK_FREQ_WITH_UNIT)
  ) rio_inst 
  (
  
     //----------------------------
     // Control Signal Declarations
     //----------------------------
     .sys_clk                             (sys_clk),
     .rst_n                               (rst_n),
   
     //----------------------------
     //------- CAR Inputs ---------
     //----------------------------
     
      .car_device_id                            (car_device_id),
      .car_device_vendor_id                     (car_device_vendor_id),
      .car_device_revision_id                   (car_device_revision_id),
      .car_assey_id                             (car_assey_id),
      .car_assey_vendor_id                      (car_assey_vendor_id),
      .car_revision_id                          (car_revision_id),
      .car_bridge                               (car_bridge),
      .car_memory                               (car_memory), 
      .car_processor                            (car_processor),
      .car_switch                               (car_switch),
      .car_num_of_ports                         (car_num_of_ports),
      .car_port_num                             (car_port_num),
      .car_extended_route_table                 (car_extended_route_table),
      .car_standard_route_table                 (car_standard_route_table),
      .car_flow_arbitration                     (car_flow_arbitration),
      .car_flow_control                         (car_flow_control),
      .car_max_pdu_size                         (car_max_pdu_size),
      .car_segmentation_contexts                (car_segmentation_contexts),
      .car_max_destid                           (car_max_destid),
      .car_source_operations                    (car_source_operations),
      .car_destination_operations               (car_destination_operations),
   
     //----------------------------
     //------- CSR Inputs ---------
     //----------------------------
     
       .csr_tm_types_reset_value                (csr_tm_types_reset_value), 
       .csr_tm_mode_reset_value                 (csr_tm_mode_reset_value),
       .csr_mtu_reset_value                     (csr_mtu_reset_value),
       .csr_external_tm_mode_wr                 (csr_external_tm_mode_wr),
       .csr_external_mtu_wr                     (csr_external_mtu_wr),
       .csr_external_tm_mode_in                 (csr_external_tm_mode_in),
       .csr_external_mtu_in                     (csr_external_mtu_in),
     
     //----------------------------
     //-- Error Management Inputs -
     //----------------------------
     
      .message_error_response_set                          (message_error_response_set),
      .gsm_error_response_set                              (gsm_error_response_set),
      .message_format_error_response_set                   (message_format_error_response_set),
      .external_illegal_transaction_decode_set             (external_illegal_transaction_decode_set),
      .external_message_request_timeout_set                (external_message_request_timeout_set),
      .external_slave_packet_response_timeout_set          (external_slave_packet_response_timeout_set),
      .external_unsolicited_response_set                   (external_unsolicited_response_set),
      .external_unsupported_transaction_set                (external_unsupported_transaction_set),
      .external_illegal_transaction_target_error_set       (external_illegal_transaction_target_error_set),
      .external_missing_data_streaming_context_set         (external_missing_data_streaming_context_set),
      .external_open_existing_data_streaming_context_set   (external_open_existing_data_streaming_context_set),
      .external_long_data_streaming_segment_set            (external_long_data_streaming_segment_set),
      .external_short_data_streaming_segment_set           (external_short_data_streaming_segment_set),
      .external_data_streaming_pdu_length_error_set        (external_data_streaming_pdu_length_error_set),
      .external_capture_destinationID_wr                   (external_capture_destinationID_wr),
      .external_capture_destinationID_in                   (external_capture_destinationID_in),
      .external_capture_sourceID_wr                        (external_capture_sourceID_wr),
      .external_capture_sourceID_in                        (external_capture_sourceID_in),
      .external_capture_ftype_wr                           (external_capture_ftype_wr),
      .external_capture_ftype_in                           (external_capture_ftype_in), 
      .external_capture_ttype_wr                           (external_capture_ttype_wr),
      .external_capture_ttype_in                           (external_capture_ttype_in),
      .external_letter_wr                                  (external_letter_wr),
      .external_letter_in                                  (external_letter_in),
      .external_mbox_wr                                    (external_mbox_wr),
      .external_mbox_in                                    (external_mbox_in),
      .external_msgseg_wr                                  (external_msgseg_wr),
      .external_msgseg_in                                  (external_msgseg_in),
      .external_xmbox_wr                                   (external_xmbox_wr),
      .external_xmbox_in                                   (external_xmbox_in),
  
     //--------------------------------------
     // CAR, CSR and Error Management Outputs
     //--------------------------------------
     
      .base_device_id                  (base_device_id),
      .large_base_device_id            (large_base_device_id),
      .tm_types                        (tm_types),
      .tm_mode                         (tm_mode),
      .mtu                             (mtu),
      .port_degraded                   (port_degraded),
      .port_failed                     (port_failed),
      .logical_transport_error         (logical_transport_error),
      .time_to_live                    (time_to_live),
   
     //------------------------------------------------------------
     // Physical Layer Register (Lp-Serial & Lp-Serial Lane) Inputs
     //------------------------------------------------------------
      .host_reset_value                             (host_reset_value),  
      .master_enable_reset_value                    (master_enable_reset_value),
      .discovered_reset_value                       (discovered_reset_value),
      .flow_control_participant_reset_value         (flow_control_participant_reset_value),
      .enumeration_boundary_reset_value             (enumeration_boundary_reset_value),
      .flow_arbitration_participant_reset_value     (flow_arbitration_participant_reset_value),
      .disable_destination_id_checking_reset_value  (disable_destination_id_checking_reset_value),
      .transmitter_type_reset_value                 (transmitter_type_reset_value),
      .receiver_type_reset_value                    (receiver_type_reset_value),
      .ef_ptr_reset_value                           (ef_ptr_reset_value),

  //------------------------------
  // SRIO User visible Interfaces
  //------------------------------
  // Maintenance Module User visible Avalon-MM Slave Interface
      
      .mnt_s_address          (mnt_s_address[25:2]),
      .mnt_s_write            (mnt_s_write),                      
      .mnt_s_writedata        (mnt_s_writedata),
      .mnt_s_read             (mnt_s_read),
      .mnt_s_waitrequest      (mnt_s_waitrequest),               
      .mnt_s_readdatavalid    (mnt_s_readdatavalid),
      .mnt_s_readdata         (mnt_s_readdata),               
      .mnt_s_readerror        (mnt_s_readerror),                
  
    
   
    //-----------------------------------------------------------------------
    // IO Master User visible Avalon-MM Slave Interface Read-Write Interface
    // for 128 bit module
    //-----------------------------------------------------------------------
     
      .iom_rd_wr_readdatavalid (iom_rd_wr_readdatavalid),
      .iom_rd_wr_readresponse  (iom_rd_wr_readresponse),       
      .iom_rd_wr_readdata      (iom_rd_wr_readdata),
      .iom_rd_wr_waitrequest   (iom_rd_wr_waitrequest),
      .iom_rd_wr_read          (iom_rd_wr_read),      
      .iom_rd_wr_write         (iom_rd_wr_write),     
      .iom_rd_wr_writedata     (iom_rd_wr_writedata),                   
      .iom_rd_wr_burstcount    (iom_rd_wr_burstcount),
      .iom_rd_wr_byteenable    (iom_rd_wr_byteenable),
      .iom_rd_wr_address       (iom_rd_wr_address),                    
  
    //----------------------------------------------------------------------
    // IO Slave User visible Avalon-MM Slave Interface Read-Write Interface
    // for 128 bit module
    //----------------------------------------------------------------------
     
      .ios_rd_wr_address       (ios_rd_wr_address[IO_SLAVE_ADDRESS_WIDTH -1:4]),                
      .ios_rd_wr_write         (ios_rd_wr_write),                  
      .ios_rd_wr_read          (ios_rd_wr_read),          
      .ios_rd_wr_writedata     (ios_rd_wr_writedata),              
      .ios_rd_wr_burstcount    (ios_rd_wr_burstcount),             
      .ios_rd_wr_byteenable    (ios_rd_wr_byteenable),             
      .ios_rd_wr_waitrequest   (ios_rd_wr_waitrequest),  
      .ios_rd_wr_readdata      (ios_rd_wr_readdata),                
      .ios_rd_wr_readresponse  (ios_rd_wr_readresponse),               
      .ios_rd_wr_readdatavalid (ios_rd_wr_readdatavalid),
    
    //-----------------------------------------------------------------
    // IO Slave User visible Avalon-MM Slave Interface Write Interface
    // for 128 bit module
    //-----------------------------------------------------------------
     
      .ios_wr_address          (ios_wr_address[IO_SLAVE_ADDRESS_WIDTH -1:4]),                 
      .ios_wr_write            (ios_wr_write),            
      .ios_wr_writedata        (ios_wr_writedata),        
      .ios_wr_byteenable       (ios_wr_byteenable),       
      .ios_wr_burstcount       (ios_wr_burstcount),       
      .ios_wr_waitrequest      (ios_wr_waitrequest),
    
    //----------------------------------------------------------------
    // IO Slave User visible Avalon-MM Slave Interface Read Interface
    // for 128 bit module
    //----------------------------------------------------------------
      
      .ios_rd_address           (ios_rd_address[IO_SLAVE_ADDRESS_WIDTH -1:4]),              
      .ios_rd_read              (ios_rd_read),          
      .ios_rd_burstcount        (ios_rd_burstcount),
      .ios_rd_byteenable        (ios_rd_byteenable),             
      .ios_rd_waitrequest       (ios_rd_waitrequest),            
      .ios_rd_readdata          (ios_rd_readdata),
      .ios_rd_readresponse      (ios_rd_readresponse),           
      .ios_rd_readdatavalid     (ios_rd_readdatavalid),
  
    
  
    //-------------------------------------------------
    // Doorbell User visible Avalon-MM Slave Interface
    //-------------------------------------------------
     
     .drbell_s_read            (drbell_s_read),
     .drbell_s_write           (drbell_s_write),
     .drbell_s_address         (drbell_s_address),
     .drbell_s_writedata       (drbell_s_writedata),
     .drbell_s_waitrequest     (drbell_s_waitrequest),
     .drbell_s_readdata        (drbell_s_readdata),
  
    //-------------------------------------------------
    // Pass-through Avalon Payload and Header interface
    //-------------------------------------------------
    .gen_rx_pd_ready                    (1'b1), 
    .gen_rx_pd_data                     (gen_rx_pd_data),
    .gen_rx_pd_valid                    (gen_rx_pd_valid),
    .gen_rx_pd_startofpacket            (gen_rx_pd_startofpacket),
    .gen_rx_pd_endofpacket              (gen_rx_pd_endofpacket),
    .gen_rx_pd_empty                    (gen_rx_pd_empty),
  
    .gen_rx_hd_ready                    (1'b1), 
    .gen_rx_hd_data                     (gen_rx_hd_data),
    .gen_rx_hd_valid                    (gen_rx_hd_valid),
  
    .transport_rx_packet_dropped        (transport_rx_packet_dropped),
    //--------------------------------------------------
    // Transmit Side of Avalon-ST Pass-Through Interface
    //--------------------------------------------------
    .gen_tx_data                (gen_tx_data),    
    .gen_tx_valid               (gen_tx_valid),
    .gen_tx_startofpacket       (gen_tx_startofpacket),
    .gen_tx_endofpacket         (gen_tx_endofpacket),
    .gen_tx_empty               (gen_tx_empty),
    .gen_tx_ready               (gen_tx_ready),        
    .ext_tx_packet_size                 (ext_tx_packet_size),
    //------------------------------------------------------
    // Maintenance Bridge External Avalon-MM Slave Interface
    //------------------------------------------------------
    .ext_mnt_address          (ext_mnt_address[23:2]),
    .ext_mnt_write            (ext_mnt_write),
    .ext_mnt_read             (ext_mnt_read),
    .ext_mnt_writedata        (ext_mnt_writedata), 
    .ext_mnt_waitrequest      (ext_mnt_waitrequest), 
    .ext_mnt_readdata         (ext_mnt_readdata),
    .ext_mnt_readdatavalid    (ext_mnt_readdatavalid),
    .ext_mnt_readresponse     (ext_mnt_readresponse),
    .ext_mnt_writeresponse    (ext_mnt_writeresponse),
  
    .master_enable (master_enable),
    //---------------------------------------------------------------------
    // User Logic Avalon-MM Master interface Maintenance Register Interface 
    //---------------------------------------------------------------------
      
      .usr_mnt_waitrequest      (usr_mnt_waitrequest),
      .usr_mnt_readdata         (usr_mnt_readdata),
      .usr_mnt_readdatavalid    (usr_mnt_readdatavalid),
      .usr_mnt_address          (usr_mnt_address),
      .usr_mnt_write            (usr_mnt_write), 
      .usr_mnt_read             (usr_mnt_read),
      .usr_mnt_writedata        (usr_mnt_writedata),
    
    //------------------------
    // PHY IP input and output
    //------------------------
      .rx_serial_data                 (rx_serial_data),               
      .pll_ref_clk                    (pll_ref_clk),                               
      .multicast_event_rx             (multicast_event_rx),
      .send_multicast_event           (send_multicast_event),
      .send_link_request_reset_device (send_link_request_reset_device),
      .sent_link_request_reset_device (sent_link_request_reset_device), 
      .link_req_reset_device_received (link_req_reset_device_received), 
      .sent_multicast_event           (sent_multicast_event),
      .tx_serial_data                 (tx_serial_data),               
      .port_initialized               (port_initialized),                     
      .link_initialized               (link_initialized),    
      .port_ok                        (port_ok),                     
      .port_error                     (port_error),                     
      .packet_transmitted             (packet_transmitted),                     
      .packet_cancelled               (packet_cancelled),                     
      .packet_accepted_cs_sent        (packet_accepted_cs_sent),                     
      .packet_retry_cs_sent           (packet_retry_cs_sent),                     
      .packet_not_accepted_cs_sent    (packet_not_accepted_cs_sent),                     
      .packet_accepted_cs_received    (packet_accepted_cs_received),                     
      .packet_retry_cs_received       (packet_retry_cs_received),                    
      .packet_not_accepted_cs_received(packet_not_accepted_cs_received),
      .packet_crc_error               (packet_crc_error               ),                     
      .control_symbol_error           (control_symbol_error           ),                    
      .rx_syncstatus                  (rx_syncstatus),                
      .tx_ready                       (tx_ready),                    
      .rx_ready                       (rx_ready),                    
      .pll_locked                     (pll_locked),                    
//      .rx_rlv                         (rx_rlv),                    
      .rx_is_lockedtoref              (rx_is_lockedtoref),                    
      .rx_is_lockedtodata             (rx_is_lockedtodata),                    
      .rx_signaldetect                (rx_signaldetect),
      .rx_clkout                      (rx_clkout),                         
      .tx_clkout                      (tx_clkout),
    //------------------
    // Interrupt Signals
    //------------------
       .std_reg_mnt_irq                (std_reg_mnt_irq),
       .mnt_mnt_s_irq                  (mnt_mnt_s_irq),
       .io_m_mnt_irq                   (io_m_mnt_irq),
       .io_s_mnt_irq                   (io_s_mnt_irq),
       .drbell_s_irq                   (drbell_s_irq),
       .reconfig_to_xcvr               (reconfig_to_xcvr_input),
       .reconfig_from_xcvr             ()
  );

//-----------------------------------------------------------------
// SISTER SRIO
//-----------------------------------------------------------------
  
 //------- CAR Inputs ---------
  logic  [15:0]  sis_car_device_id;
  logic  [15:0]  sis_car_device_vendor_id;
  logic  [31:0]  sis_car_device_revision_id;
  logic  [15:0]  sis_car_assey_id;
  logic  [15:0]  sis_car_assey_vendor_id;
  logic  [15:0]  sis_car_revision_id;
  logic          sis_car_bridge;
  logic          sis_car_memory; 
  logic          sis_car_processor;
  logic          sis_car_switch;
  logic  [7:0]   sis_car_num_of_ports;
  logic  [7:0]   sis_car_port_num;
  logic          sis_car_extended_route_table;
  logic          sis_car_standard_route_table;
  logic          sis_car_flow_arbitration;
  logic          sis_car_flow_control;
  logic  [15:0]  sis_car_max_pdu_size;
  logic  [15:0]  sis_car_segmentation_contexts;
  logic  [15:0]  sis_car_max_destid;
  logic  [31:0]  sis_car_source_operations;
  logic  [31:0]  sis_car_destination_operations;
 
  //----------------------------
  //------- CSR Inputs ---------
  //----------------------------
  
  logic   [3:0]  sis_csr_tm_types_reset_value; 
  logic   [3:0]  sis_csr_tm_mode_reset_value;
  logic   [7:0]  sis_csr_mtu_reset_value;
  logic          sis_csr_external_tm_mode_wr;
  logic          sis_csr_external_mtu_wr;
  logic   [3:0]  sis_csr_external_tm_mode_in;
  logic   [7:0]  sis_csr_external_mtu_in;
  
  //----------------------------
  //-- Error Management Inputs -
  //----------------------------
  
  logic          sis_message_error_response_set;
  logic          sis_gsm_error_response_set;
  logic          sis_message_format_error_response_set;
  logic          sis_external_illegal_transaction_decode_set;
  logic          sis_external_message_request_timeout_set;
  logic          sis_external_slave_packet_response_timeout_set;
  logic          sis_external_unsolicited_response_set;
  logic          sis_external_unsupported_transaction_set;
  logic          sis_external_illegal_transaction_target_error_set;
  logic          sis_external_missing_data_streaming_context_set;
  logic          sis_external_open_existing_data_streaming_context_set;
  logic          sis_external_long_data_streaming_segment_set;
  logic          sis_external_short_data_streaming_segment_set;
  logic          sis_external_data_streaming_pdu_length_error_set;
  logic          sis_external_capture_destinationID_wr;
  logic   [15:0] sis_external_capture_destinationID_in;
  logic          sis_external_capture_sourceID_wr;
  logic   [15:0] sis_external_capture_sourceID_in;
  logic          sis_external_capture_ftype_wr;
  logic   [3:0]  sis_external_capture_ftype_in; 
  logic          sis_external_capture_ttype_wr;
  logic   [3:0]  sis_external_capture_ttype_in;
  logic          sis_external_letter_wr;
  logic   [1:0]  sis_external_letter_in;
  logic          sis_external_mbox_wr;
  logic   [1:0]  sis_external_mbox_in;
  logic          sis_external_msgseg_wr;
  logic   [3:0]  sis_external_msgseg_in;
  logic          sis_external_xmbox_wr;
  logic   [3:0]  sis_external_xmbox_in;

  //--------------------------------------
  // CAR; CSR and Error Management Outputs
  //--------------------------------------
  
  logic  [7:0]  sis_base_device_id;
  logic  [15:0] sis_large_base_device_id;
  logic  [3:0]  sis_tm_types;
  logic  [3:0]  sis_tm_mode;
  logic  [7:0]  sis_mtu;
  logic         sis_port_degraded;
  logic         sis_port_failed;
  logic         sis_al_transport_error;
  logic  [15:0] sis_time_to_live;
 
  //------------------------------------------------------------
  // Physical Layer Register (Lp-Serial & Lp-Serial Lane) Inputs
  //------------------------------------------------------------
  logic          sis_host_reset_value;  
  logic          sis_master_enable_reset_value;
  logic          sis_discovered_reset_value;
  logic          sis_flow_control_participant_reset_value;
  logic          sis_enumeration_boundary_reset_value;
  logic          sis_flow_arbitration_participant_reset_value;
  logic          sis_disable_destination_id_checking_reset_value;
  logic          sis_transmitter_type_reset_value;
  logic   [1:0]  sis_receiver_type_reset_value;
  logic  [15:0]  sis_ef_ptr_reset_value;

  //------------------------
  // PHY IP reg and wire
  //------------------------
  logic   [LSIZE-1:0] sis_rx_serial_data;               
  logic               sis_send_multicast_event;
  logic               sis_send_link_request_reset_device; 
  
  logic               sis_sent_link_request_reset_device;
  logic               sis_multicast_event_rx;
  logic               sis_link_req_reset_device_received; 
  logic               sis_sent_multicast_event;
  logic [LSIZE-1:0]   sis_tx_serial_data;               
  logic               sis_port_initialized;                     
  logic               sis_link_initialized;    
  logic               sis_port_ok;                     
  logic               sis_port_error;                     
  logic               sis_packet_transmitted;                     
  logic               sis_packet_cancelled;                     
  logic               sis_packet_accepted_cs_sent;                     
  logic               sis_packet_retry_cs_sent;                     
  logic               sis_packet_not_accepted_cs_sent;                     
  logic               sis_packet_accepted_cs_received;                     
  logic               sis_packet_retry_cs_received;                    
  logic               sis_packet_not_accepted_cs_received;
  logic               sis_packet_crc_error;                     
  logic               sis_control_symbol_error;                    
  logic [LSIZE-1:0]   sis_rx_syncstatus;                
  logic [LSIZE-1:0]   sis_tx_ready;                    
  logic [LSIZE-1:0]   sis_rx_ready;                    
  logic               sis_pll_locked;                    
  logic [LSIZE-1:0]   sis_rx_rlv;                    
  logic [LSIZE-1:0]   sis_rx_is_lockedtoref;                    
  logic [LSIZE-1:0]   sis_rx_is_lockedtodata;                    
  logic [LSIZE-1:0]   sis_rx_signaldetect;
  logic               sis_rx_clkout;                         
  logic               sis_tx_clkout;                         
 
 //------------------
 // Interrupt Signals
 //------------------
  logic  sis_std_reg_mnt_irq ;            
  logic  sis_mnt_mnt_s_irq   ;            
  logic  sis_io_m_mnt_irq    ;            
  logic  sis_io_s_mnt_irq    ;            
  logic  sis_drbell_s_irq    ;

//----------------------------------------------------------------------------
// Internal signals declarations
//----------------------------------------------------------------------------

  logic [7:0]   sis_i_device_id_high; 
  logic [7:0]   sis_i_device_id_low;
  logic [15:0]  sis_i_device_vendor_id;
  logic [31:0]  sis_i_device_revision_id;

  logic [15:0]  sis_i_assey_id;
  logic [15:0]  sis_i_assey_vendor_id;
  logic [15:0]  sis_i_revision_id;
  logic [15:0]  sis_i_ef_ptr;
  logic         sis_i_bridge;
  logic         sis_i_memory; 
  logic         sis_i_processor;
  logic         sis_i_switch;
  logic [7:0]   sis_i_num_of_ports;
  logic [7:0]   sis_i_port_num;
  logic         sis_i_extended_route_table;
  logic         sis_i_standard_route_table;
  logic         sis_i_flow_arregration;
  logic         sis_i_flow_control;
  logic [15:0]  sis_i_max_pdu_size;
  logic [15:0]  sis_i_segmentation_contexts;
  logic [15:0]  sis_i_max_destid;
  logic [31:0]  sis_i_source_operations;
  logic [31:0]  sis_i_destination_operations;
  logic [3:0]   sis_i_csr_tm_types_reset_value; 
  logic [3:0]   sis_i_csr_tm_mode_reset_value;
  logic [7:0]   sis_i_csr_mtu_reset_value;
  logic         sis_i_flow_arbitration;
  logic         sis_i_csr_external_tm_mode_wr;
  logic         sis_i_csr_external_mtu_wr;
  logic [3:0]   sis_i_csr_external_tm_mode_in;
  logic [7:0]   sis_i_csr_external_mtu_in;
  logic         sis_i_message_error_response_set;
  logic         sis_i_gsm_error_response_set;
  logic         sis_i_message_format_error_response_set;
  logic         sis_i_external_illegal_transaction_decode_set;
  logic         sis_i_external_message_request_timeout_set;
  logic         sis_i_external_slave_packet_response_timeout_set;
  logic         sis_i_external_unsolicited_response_set;
  logic         sis_i_external_unsupported_transaction_set;
  logic         sis_i_external_missing_data_streaming_context_set;
  logic         sis_i_external_open_existing_data_streaming_context_set;
  logic         sis_i_external_long_data_streaming_segment_set;
  logic         sis_i_external_short_data_streaming_segment_set;
  logic         sis_i_external_data_streaming_pdu_length_error_set;
  logic         sis_i_external_capture_destinationID_wr;
  logic [15:0]  sis_i_external_capture_destinationID_in;
  logic         sis_i_external_capture_sourceID_wr;
  logic [15:0]  sis_i_external_capture_sourceID_in;
  logic         sis_i_external_capture_ftype_wr;
  logic [3:0]   sis_i_external_capture_ftype_in; 
  logic         sis_i_external_capture_ttype_wr;
  logic [3:0]   sis_i_external_capture_ttype_in;
  logic         sis_i_external_letter_wr;
  logic [1:0]   sis_i_external_letter_in;
  logic         sis_i_external_mbox_wr;
  logic [1:0]   sis_i_external_mbox_in;
  logic         sis_i_external_msgseg_wr;
  logic [3:0]   sis_i_external_msgseg_in;
  logic         sis_i_external_xmbox_wr;
  logic [3:0]   sis_i_external_xmbox_in;
  logic         sis_i_host_reset_value;  
  logic         sis_i_master_enable_reset_value;
  logic         sis_i_discovered_reset_value;
  logic         sis_i_flow_control_participant_reset_value;
  logic         sis_i_enumeration_boundary_reset_value;
  logic         sis_i_flow_arbitration_participant_reset_value;
  logic         sis_i_disable_destination_id_checking_reset_value;
  logic         sis_i_transmitter_type_reset_value;
  logic [1:0]   sis_i_receiver_type_reset_value;

  //------------------------------
  // SRIO User visible Interfaces SISTER DUT 
  //------------------------------
  //----------------------------------------------------------
  // Maintenance Module User visible Avalon-MM Slave Interface
  //----------------------------------------------------------
   logic [25:0] sis_mnt_s_address;
   logic        sis_mnt_s_write;                          
   logic [31:0] sis_mnt_s_writedata;
   logic        sis_mnt_s_read;
   logic        sis_mnt_s_waitrequest;                   
   logic        sis_mnt_s_readdatavalid;
   logic [31:0] sis_mnt_s_readdata;                   
   logic        sis_mnt_s_readerror;                    

   
  //-----------------------------------------------------------------------
  // IO Master User visible Avalon-MM Slave Interface Read-Write Interface
  // for 128 bit module
  //-----------------------------------------------------------------------
   logic         sis_iom_rd_wr_readdatavalid;
   logic         sis_iom_rd_wr_readresponse;
   logic [127:0] sis_iom_rd_wr_readdata;
   logic         sis_iom_rd_wr_waitrequest;
   logic         sis_iom_rd_wr_read;      
   logic         sis_iom_rd_wr_write;     
   logic [127:0] sis_iom_rd_wr_writedata;                   
   logic [4:0]   sis_iom_rd_wr_burstcount;
   logic [15:0]  sis_iom_rd_wr_byteenable;
   logic [IO_MASTER_ADDRESS_WIDTH -1:0]  sis_iom_rd_wr_address;                    

  //----------------------------------------------------------------------
  // IO Slave User visible Avalon-MM Slave Interface Read-Write Interface
  // for 128 bit module
  //----------------------------------------------------------------------
   logic [IO_SLAVE_ADDRESS_WIDTH -1:0] sis_ios_rd_wr_address;                
   logic         sis_ios_rd_wr_write;                  
   logic         sis_ios_rd_wr_read;          
   logic [127:0] sis_ios_rd_wr_writedata;              
   logic [4:0]   sis_ios_rd_wr_burstcount;             
   logic [15:0]  sis_ios_rd_wr_byteenable;             
   logic         sis_ios_rd_wr_waitrequest;  
   logic [127:0] sis_ios_rd_wr_readdata;                
   logic         sis_ios_rd_wr_readresponse;               
   logic         sis_ios_rd_wr_readdatavalid;
  
  //-----------------------------------------------------------------
  // IO Slave User visible Avalon-MM Slave Interface Write Interface
  // for 128 bit module
  //-----------------------------------------------------------------
   logic [IO_SLAVE_ADDRESS_WIDTH -1:0]  sis_ios_wr_address;                
   logic         sis_ios_wr_write;                  
   logic [127:0] sis_ios_wr_writedata;              
   logic [15:0]  sis_ios_wr_byteenable;             
   logic [4:0]   sis_ios_wr_burstcount;             
   logic         sis_ios_wr_waitrequest;
  
  //----------------------------------------------------------------
  // IO Slave User visible Avalon-MM Slave Interface Read Interface
  // for 128 bit module
  //----------------------------------------------------------------
   logic [IO_SLAVE_ADDRESS_WIDTH -1:0]  sis_ios_rd_address;               
   logic         sis_ios_rd_read;          
   logic [4:0]   sis_ios_rd_burstcount;             
   logic [15:0]  sis_ios_rd_byteenable;             
   logic         sis_ios_rd_waitrequest;            
   logic [127:0] sis_ios_rd_readdata;                  
   logic         sis_ios_rd_readdatavalid;
   logic         sis_ios_rd_readresponse;               

           
  
  //---------------------------------------------------------------
  // IO Slave User visible Avalon-MM Slave Interface Read Interface
  // for 64 bit legacy module
  //---------------------------------------------------------------
   //logic [31:0]  sis_io_s_rd_address;               
   //logic         sis_io_s_rd_read;          
   //logic [4:0]   sis_io_s_rd_burstcount;             
   //logic         sis_io_s_rd_waitrequest;            
   //logic [63:0]  sis_io_s_rd_readdata;                  
   //logic         sis_io_s_rd_readerror;                 
   //logic         sis_io_s_rd_readdatavalid;

  //-------------------------------------------------
  // Doorbell User visible Avalon-MM Slave Interface
  //-------------------------------------------------
   logic         sis_drbell_s_read;
   logic         sis_drbell_s_write;
   logic [5:2]   sis_drbell_s_address;
   logic [31:0]  sis_drbell_s_writedata;
   logic         sis_drbell_s_waitrequest;
   logic [31:0]  sis_drbell_s_readdata;
   logic         sis_master_enable;
 
  //-------------------------------------------------
  // Pass-through Avalon Payload and Header interface
  //-------------------------------------------------
  logic          sis_gen_rx_pd_ready; 
  logic  [127:0] sis_gen_rx_pd_data;
  logic          sis_gen_rx_pd_valid;
  logic          sis_gen_rx_pd_startofpacket;
  logic          sis_gen_rx_pd_endofpacket;
  logic  [3:0]   sis_gen_rx_pd_empty;
  logic          sis_gen_rx_hd_ready; 
  logic  [114:0] sis_gen_rx_hd_data;
  logic          sis_gen_rx_hd_valid;

  logic   [8:0]  sis_ext_tx_packet_size; 
  logic          sis_transport_rx_packet_dropped;        
 
  //--------------------------------------------------
  // Transmit Side of Avalon-ST Pass-Through Interface
  //--------------------------------------------------
  logic  [127:0] sis_gen_tx_data;    
  logic          sis_gen_tx_valid;
  logic          sis_gen_tx_startofpacket;
  logic          sis_gen_tx_endofpacket;
  logic  [3:0]   sis_gen_tx_empty;
  logic          sis_gen_tx_ready;
  
  //------------------------------------------------------
  // Maintenance Bridge External Avalon-MM Slave Interface
  //------------------------------------------------------
  logic [31:0]   sis_ext_mnt_address;
  logic          sis_ext_mnt_write;
  logic          sis_ext_mnt_read;
  logic [31:0]   sis_ext_mnt_writedata; 
  logic          sis_ext_mnt_waitrequest; 
  logic [31:0]   sis_ext_mnt_readdata;
  logic          sis_ext_mnt_readdatavalid;
  logic          sis_ext_mnt_readresponse;
  logic          sis_ext_mnt_writeresponse;

 //---------------------------------------------------------------------
 // User Logic Avalon-MM Master interface Maintenance Register Interface 
 //---------------------------------------------------------------------
  logic         sis_usr_mnt_waitrequest; 
  logic [31:0]  sis_usr_mnt_readdata;
  logic         sis_usr_mnt_readdatavalid;
  logic [31:0]  sis_usr_mnt_address; 
  logic         sis_usr_mnt_write; 
  logic         sis_usr_mnt_read;
  logic [31:0]  sis_usr_mnt_writedata;
  //---------------------------------------------------------------------   
  // SISTER DUT Instantiation
  //---------------------------------------------------------------------
  
  
  altera_rapidio2_top_with_reset_ctrl #( //Parameters passed in from tb_hookup.sv (from parameters.v)
    .DEVICE_FAMILY (DEVICE_FAMILY) 
   ,.SUPPORT_4X (SUPPORT_4X)
   ,.SUPPORT_2X (SUPPORT_2X)
   ,.SUPPORT_1X (SUPPORT_1X)
   ,.ENABLE_TRANSPORT_LAYER(ENABLE_TRANSPORT_LAYER)
   ,.MAINTENANCE_SLAVE(MAINTENANCE_SLAVE)
   ,.MAINTENANCE_MASTER(MAINTENANCE_MASTER)
   ,.IO_SLAVE(IO_SLAVE)
    ,.IO_MASTER(IO_MASTER)
    ,.DOORBELL(DOORBELL)
    ,.SYS_CLK_FREQ(SYS_CLK_FREQ)
	,.ERROR_MANAGEMENT_EXTENSION(ERROR_MANAGEMENT_EXTENSION)
     //----------------------------------------------------
     //------------ PHYSICAL LAYER PARAMETERS -------------
     //----------------------------------------------------
     ,.MAX_BAUD_RATE(MAX_BAUD_RATE)
     ,.REF_CLK_PERIOD(REF_CLK_PERIOD)
     ,.SYS_CLK_PERIOD(SYS_CLK_PERIOD)
     //----------------------------------------------------
     //----------- TRANSPORT LAYER PARAMETERS -------------
     //----------------------------------------------------
     ,.TRANSPORT_LARGE(TRANSPORT_LARGE)
     ,.PASS_THROUGH(PASS_THROUGH)
     ,.PROMISCUOUS(PROMISCUOUS)
     //----------------------------------------------------
     //------------ MAINTENANCE PARAMETERS ----------------
     //----------------------------------------------------
     ,.MAINTENANCE_ADDRESS_WIDTH(MAINTENANCE_ADDRESS_WIDTH)
     ,.PORT_WRITE_TX(PORT_WRITE_TX)
	 ,.PORT_WRITE_RX(PORT_WRITE_RX)
     //----------------------------------------------------
     //--------------- DOORBELL PARAMETERS ----------------  
     //----------------------------------------------------
     ,.DOORBELL_TX_ENABLE(DOORBELL_TX_ENABLE)     
     ,.DOORBELL_RX_ENABLE(DOORBELL_RX_ENABLE)
     ,.IO_SLAVE_DOORBELL_WRITES_ORDER_PRESERVATION(IO_SLAVE_DOORBELL_WRITES_ORDER_PRESERVATION)
     //----------------------------------------------------
     //--------------- IO MASTER PARAMETERS ---------------
     //----------------------------------------------------
     ,.IO_MASTER_WINDOWS(IO_MASTER_WINDOWS)         
      //----------------------------------------------------
     //---------------- IO SLAVE PARAMETERS ---------------
     //----------------------------------------------------
     ,.IO_SLAVE_WINDOWS(IO_SLAVE_WINDOWS)
     ,.IO_MASTER_ADDRESS_WIDTH(IO_MASTER_ADDRESS_WIDTH)
     ,.IO_SLAVE_ADDRESS_WIDTH(IO_SLAVE_ADDRESS_WIDTH)
     //----------------------------------------------------
     //---------------- PHY IP PARAMETERS ---------------
     //----------------------------------------------------	  
     ,.MAX_BAUD_RATE_WITH_UNIT(MAX_BAUD_RATE_WITH_UNIT)
     ,.REF_CLK_FREQ_WITH_UNIT(REF_CLK_FREQ_WITH_UNIT)
  ) sis_rio_inst (       
     //----------------------------
     // Control Signal Declarations
     //----------------------------
     .sys_clk                             (sys_clk),
     .rst_n                               (sister_rst_n),
   
     //----------------------------
     //------- CAR Inputs ---------
     //----------------------------
     
      .car_device_id                            (sis_car_device_id),
      .car_device_vendor_id                     (sis_car_device_vendor_id),
      .car_device_revision_id                   (sis_car_device_revision_id),
      .car_assey_id                             (sis_car_assey_id),
      .car_assey_vendor_id                      (sis_car_assey_vendor_id),
      .car_revision_id                          (sis_car_revision_id),
      .car_bridge                               (sis_car_bridge),
      .car_memory                               (sis_car_memory), 
      .car_processor                            (sis_car_processor),
      .car_switch                               (sis_car_switch),
      .car_num_of_ports                         (sis_car_num_of_ports),
      .car_port_num                             (sis_car_port_num),
      .car_extended_route_table                 (sis_car_extended_route_table),
      .car_standard_route_table                 (sis_car_standard_route_table),
      .car_flow_arbitration                     (sis_car_flow_arbitration),
      .car_flow_control                         (sis_car_flow_control),
      .car_max_pdu_size                         (sis_car_max_pdu_size),
      .car_segmentation_contexts                (sis_car_segmentation_contexts),
      .car_max_destid                           (sis_car_max_destid),
      .car_source_operations                    (sis_car_source_operations),
      .car_destination_operations               (sis_car_destination_operations),
   
     //----------------------------
     //------- CSR Inputs ---------
     //----------------------------
     
       .csr_tm_types_reset_value                (sis_csr_tm_types_reset_value), 
       .csr_tm_mode_reset_value                 (sis_csr_tm_mode_reset_value),
       .csr_mtu_reset_value                     (sis_csr_mtu_reset_value),
       .csr_external_tm_mode_wr                 (sis_csr_external_tm_mode_wr),
       .csr_external_mtu_wr                     (sis_csr_external_mtu_wr),
       .csr_external_tm_mode_in                 (sis_csr_external_tm_mode_in),
       .csr_external_mtu_in                     (sis_csr_external_mtu_in),
     
     //----------------------------
     //-- Error Management Inputs -
     //----------------------------
     
      .message_error_response_set                             (sis_message_error_response_set),
      .gsm_error_response_set                                 (sis_gsm_error_response_set),
      .message_format_error_response_set                      (sis_message_format_error_response_set),
      .external_illegal_transaction_decode_set                (sis_external_illegal_transaction_decode_set),
      .external_message_request_timeout_set                   (sis_external_message_request_timeout_set),
      .external_slave_packet_response_timeout_set             (sis_external_slave_packet_response_timeout_set),
      .external_unsolicited_response_set                      (sis_external_unsolicited_response_set),
      .external_unsupported_transaction_set                   (sis_external_unsupported_transaction_set),
      .external_illegal_transaction_target_error_set          (sis_external_illegal_transaction_target_error_set),
      .external_missing_data_streaming_context_set            (sis_external_missing_data_streaming_context_set),
      .external_open_existing_data_streaming_context_set      (sis_external_open_existing_data_streaming_context_set),
      .external_long_data_streaming_segment_set               (sis_external_long_data_streaming_segment_set),
      .external_short_data_streaming_segment_set              (sis_external_short_data_streaming_segment_set),
      .external_data_streaming_pdu_length_error_set           (sis_external_data_streaming_pdu_length_error_set),
      .external_capture_destinationID_wr                      (sis_external_capture_destinationID_wr),
      .external_capture_destinationID_in                      (sis_external_capture_destinationID_in),
      .external_capture_sourceID_wr                           (sis_external_capture_sourceID_wr),
      .external_capture_sourceID_in                           (sis_external_capture_sourceID_in),
      .external_capture_ftype_wr                              (sis_external_capture_ftype_wr),
      .external_capture_ftype_in                              (sis_external_capture_ftype_in), 
      .external_capture_ttype_wr                              (sis_external_capture_ttype_wr),
      .external_capture_ttype_in                              (sis_external_capture_ttype_in),
      .external_letter_wr                                     (sis_external_letter_wr),
      .external_letter_in                                     (sis_external_letter_in),
      .external_mbox_wr                                       (sis_external_mbox_wr),
      .external_mbox_in                                       (sis_external_mbox_in),
      .external_msgseg_wr                                     (sis_external_msgseg_wr),
      .external_msgseg_in                                     (sis_external_msgseg_in),
      .external_xmbox_wr                                      (sis_external_xmbox_wr),
      .external_xmbox_in                                      (sis_external_xmbox_in),
  
     //--------------------------------------
     // CAR, CSR and Error Management Outputs
     //--------------------------------------
     
      .base_device_id                                         (sis_base_device_id),
      .large_base_device_id                                   (sis_large_base_device_id),
      .tm_types                                               (sis_tm_types),
      .tm_mode                                                (sis_tm_mode),
      .mtu                                                    (sis_mtu),
      .port_degraded                                          (sis_port_degraded),
      .port_failed                                            (sis_port_failed),
      .logical_transport_error                                (sis_logical_transport_error),
      .time_to_live                                           (sis_time_to_live),
   
     //------------------------------------------------------------
     // Physical Layer Register (Lp-Serial & Lp-Serial Lane) Inputs
     //------------------------------------------------------------
      .host_reset_value                                       (sis_host_reset_value),  
      .master_enable_reset_value                              (sis_master_enable_reset_value),
      .discovered_reset_value                                 (sis_discovered_reset_value),
      .flow_control_participant_reset_value                   (sis_flow_control_participant_reset_value),
      .enumeration_boundary_reset_value                       (sis_enumeration_boundary_reset_value),
      .flow_arbitration_participant_reset_value               (sis_flow_arbitration_participant_reset_value),
      .disable_destination_id_checking_reset_value            (sis_disable_destination_id_checking_reset_value),
      .transmitter_type_reset_value                           (sis_transmitter_type_reset_value),
      .receiver_type_reset_value                              (sis_receiver_type_reset_value),
      .ef_ptr_reset_value                                     (sis_ef_ptr_reset_value),
  //------------------------------
  // SRIO User visible Interfaces
  //------------------------------
  // Maintenance Module User visible Avalon-MM Slave Interface
     
       .mnt_s_address          (sis_mnt_s_address[25:2]),
       .mnt_s_write            (sis_mnt_s_write),                      
       .mnt_s_writedata        (sis_mnt_s_writedata),
       .mnt_s_read             (sis_mnt_s_read),
       .mnt_s_waitrequest      (sis_mnt_s_waitrequest),               
       .mnt_s_readdatavalid    (sis_mnt_s_readdatavalid),
       .mnt_s_readdata         (sis_mnt_s_readdata),               
       .mnt_s_readerror        (sis_mnt_s_readerror),                
  
      
    //-----------------------------------------------------------------------
    // IO Master User visible Avalon-MM Slave Interface Read-Write Interface
    // for 128 bit module
    //-----------------------------------------------------------------------
     
       .iom_rd_wr_readdatavalid (sis_iom_rd_wr_readdatavalid),
       .iom_rd_wr_readresponse  (sis_iom_rd_wr_readresponse),       
       .iom_rd_wr_readdata      (sis_iom_rd_wr_readdata),
       .iom_rd_wr_waitrequest   (sis_iom_rd_wr_waitrequest),
       .iom_rd_wr_read          (sis_iom_rd_wr_read),      
       .iom_rd_wr_write         (sis_iom_rd_wr_write),     
       .iom_rd_wr_writedata     (sis_iom_rd_wr_writedata),                   
       .iom_rd_wr_burstcount    (sis_iom_rd_wr_burstcount),
       .iom_rd_wr_byteenable    (sis_iom_rd_wr_byteenable),
       .iom_rd_wr_address       (sis_iom_rd_wr_address),                    
  
    //----------------------------------------------------------------------
    // IO Slave User visible Avalon-MM Slave Interface Read-Write Interface
    // for 128 bit module
    //----------------------------------------------------------------------
     
      .ios_rd_wr_address       (sis_ios_rd_wr_address[IO_SLAVE_ADDRESS_WIDTH -1:4]),                
      .ios_rd_wr_write         (sis_ios_rd_wr_write),                  
      .ios_rd_wr_read          (sis_ios_rd_wr_read),          
      .ios_rd_wr_writedata     (sis_ios_rd_wr_writedata),              
      .ios_rd_wr_burstcount    (sis_ios_rd_wr_burstcount),             
      .ios_rd_wr_byteenable    (sis_ios_rd_wr_byteenable),             
      .ios_rd_wr_waitrequest   (sis_ios_rd_wr_waitrequest),  
      .ios_rd_wr_readdata      (sis_ios_rd_wr_readdata),                
      .ios_rd_wr_readresponse  (sis_ios_rd_wr_readresponse),               
      .ios_rd_wr_readdatavalid (sis_ios_rd_wr_readdatavalid),
    
    //-----------------------------------------------------------------
    // IO Slave User visible Avalon-MM Slave Interface Write Interface
    // for 128 bit module SISTER DUT
    //-----------------------------------------------------------------
     
      .ios_wr_address          (sis_ios_wr_address[IO_SLAVE_ADDRESS_WIDTH -1:4]),                 
      .ios_wr_write            (sis_ios_wr_write),            
      .ios_wr_writedata        (sis_ios_wr_writedata),        
      .ios_wr_byteenable       (sis_ios_wr_byteenable),       
      .ios_wr_burstcount       (sis_ios_wr_burstcount),       
      .ios_wr_waitrequest      (sis_ios_wr_waitrequest),
    
    //----------------------------------------------------------------
    // IO Slave User visible Avalon-MM Slave Interface Read Interface
    // for 128 bit module
    //----------------------------------------------------------------
     
      .ios_rd_address           (sis_ios_rd_address[IO_SLAVE_ADDRESS_WIDTH -1:4]),              
      .ios_rd_read              (sis_ios_rd_read),          
      .ios_rd_burstcount        (sis_ios_rd_burstcount),             
      .ios_rd_waitrequest       (sis_ios_rd_waitrequest),
      .ios_rd_byteenable        (sis_ios_rd_byteenable),            
      .ios_rd_readdata          (sis_ios_rd_readdata),                  
      .ios_rd_readresponse      (sis_ios_rd_readresponse),                 
      .ios_rd_readdatavalid     (sis_ios_rd_readdatavalid),
  
    
    //-------------------------------------------------
    // Doorbell User visible Avalon-MM Slave Interface
    //-------------------------------------------------
     
     .drbell_s_read            (sis_drbell_s_read),
     .drbell_s_write           (sis_drbell_s_write),
     .drbell_s_address         (sis_drbell_s_address),
     .drbell_s_writedata       (sis_drbell_s_writedata),
     .drbell_s_waitrequest     (sis_drbell_s_waitrequest),
     .drbell_s_readdata        (sis_drbell_s_readdata),
  
    //-------------------------------------------------
    // Pass-through Avalon Payload and Header interface
    //-------------------------------------------------
    .gen_rx_pd_ready           (1'b1), 
    .gen_rx_pd_data            (sis_gen_rx_pd_data),
    .gen_rx_pd_valid           (sis_gen_rx_pd_valid),
    .gen_rx_pd_startofpacket   (sis_gen_rx_pd_startofpacket),
    .gen_rx_pd_endofpacket     (sis_gen_rx_pd_endofpacket),
    .gen_rx_pd_empty           (sis_gen_rx_pd_empty),
  
    .gen_rx_hd_ready           (1'b1), 
    .gen_rx_hd_data            (sis_gen_rx_hd_data),
    .gen_rx_hd_valid           (sis_gen_rx_hd_valid),
  
    .transport_rx_packet_dropped        (sis_transport_rx_packet_dropped),
    //--------------------------------------------------
    // Transmit Side of Avalon-ST Pass-Through Interface
    //--------------------------------------------------
    .gen_tx_data                (sis_gen_tx_data),    
    .gen_tx_valid               (sis_gen_tx_valid),
    .gen_tx_startofpacket       (sis_gen_tx_startofpacket),
    .gen_tx_endofpacket         (sis_gen_tx_endofpacket),
    .gen_tx_empty               (sis_gen_tx_empty),
    .gen_tx_ready               (sis_gen_tx_ready),        
    .ext_tx_packet_size         (sis_ext_tx_packet_size),
    //------------------------------------------------------
    // Maintenance Bridge External Avalon-MM Slave Interface
    //------------------------------------------------------
    .ext_mnt_address          (sis_ext_mnt_address[23:2]      ),
    .ext_mnt_write            (sis_ext_mnt_write        ),
    .ext_mnt_read             (sis_ext_mnt_read         ),
    .ext_mnt_writedata        (sis_ext_mnt_writedata    ), 
    .ext_mnt_waitrequest      (sis_ext_mnt_waitrequest  ), 
    .ext_mnt_readdata         (sis_ext_mnt_readdata     ),
    .ext_mnt_readdatavalid    (sis_ext_mnt_readdatavalid),
    .ext_mnt_readresponse     (sis_ext_mnt_readresponse ),
    .ext_mnt_writeresponse    (sis_ext_mnt_writeresponse),
  
    .master_enable (sis_master_enable),
    //---------------------------------------------------------------------
    // User Logic Avalon-MM Master interface Maintenance Register Interface 
    //---------------------------------------------------------------------
    //Not connected
      .usr_mnt_waitrequest      (sis_usr_mnt_waitrequest),
      .usr_mnt_readdata         (sis_usr_mnt_readdata),
      .usr_mnt_readdatavalid    (sis_usr_mnt_readdatavalid),
      .usr_mnt_address          (sis_usr_mnt_address),
      .usr_mnt_write            (sis_usr_mnt_write), 
      .usr_mnt_read             (sis_usr_mnt_read),
      .usr_mnt_writedata        (sis_usr_mnt_writedata),
    
    //------------------------
    // PHY IP input and output
    //------------------------
      .rx_serial_data                 (sis_rx_serial_data),               
      .pll_ref_clk                    (pll_ref_clk),                               
      .multicast_event_rx             (sis_multicast_event_rx),
      .send_multicast_event           (sis_send_multicast_event),
      .send_link_request_reset_device (sis_send_link_request_reset_device),
      .sent_link_request_reset_device (sis_sent_link_request_reset_device), 
      .link_req_reset_device_received (sis_link_req_reset_device_received), 
      .sent_multicast_event           (sis_sent_multicast_event),
      .tx_serial_data                 (sis_tx_serial_data),               
      .port_initialized               (sis_port_initialized),                     
      .link_initialized               (sis_link_initialized),    
      .port_ok                        (sis_port_ok),                     
      .port_error                     (sis_port_error),                     
      .packet_transmitted             (sis_packet_transmitted),                     
      .packet_cancelled               (sis_packet_cancelled),                     
      .packet_accepted_cs_sent        (sis_packet_accepted_cs_sent),                     
      .packet_retry_cs_sent           (sis_packet_retry_cs_sent),                     
      .packet_not_accepted_cs_sent    (sis_packet_not_accepted_cs_sent),                     
      .packet_accepted_cs_received    (sis_packet_accepted_cs_received),                     
      .packet_retry_cs_received       (sis_packet_retry_cs_received),                    
      .packet_not_accepted_cs_received(sis_packet_not_accepted_cs_received),
      .packet_crc_error               (sis_packet_crc_error               ),                     
      .control_symbol_error           (sis_control_symbol_error           ),                    
      .rx_syncstatus                  (sis_rx_syncstatus),                
      .tx_ready                       (sis_tx_ready),                    
      .rx_ready                       (sis_rx_ready),                    
      .pll_locked                     (sis_pll_locked),                    
                 
      .rx_is_lockedtoref              (sis_rx_is_lockedtoref),                    
      .rx_is_lockedtodata             (sis_rx_is_lockedtodata),                    
      .rx_signaldetect                (sis_rx_signaldetect),
      .rx_clkout                      (sis_rx_clkout),                         
      .tx_clkout                      (sis_tx_clkout),
    //------------------
    // Interrupt Signals
    //------------------
       .std_reg_mnt_irq                (sis_std_reg_mnt_irq),
       .mnt_mnt_s_irq                  (sis_mnt_mnt_s_irq),
       .io_m_mnt_irq                   (sis_io_m_mnt_irq),
       .io_s_mnt_irq                   (sis_io_s_mnt_irq),
       .drbell_s_irq                   (sis_drbell_s_irq),
       .reconfig_to_xcvr               (reconfig_to_xcvr_input),
       .reconfig_from_xcvr             ()
    );
  
  //Serial Connections
  assign rx_serial_data       = sis_tx_serial_data;
  assign sis_rx_serial_data   = tx_serial_data; 
  
  initial begin
    sis_i_device_id_low = $random;
    sis_i_device_id_high  = $random;
    sis_i_device_vendor_id = $random ;
    sis_i_device_revision_id = $random;
  
    sis_i_assey_id = $random;
    sis_i_assey_vendor_id  = $random;
    sis_i_revision_id  = $random;
    sis_i_ef_ptr = 16'h0100;
    sis_i_bridge = 1'b0;
    sis_i_memory = 1'b0; 
    sis_i_processor = 1'b0;
    sis_i_switch = 1'b0;
    sis_i_num_of_ports = 1;
    sis_i_port_num = 1 ;
    sis_i_extended_route_table = 0 ;
    sis_i_standard_route_table  = 0 ;
    sis_i_flow_arregration  = 0 ;
    sis_i_flow_control  = 0 ;
    sis_i_max_pdu_size  = 0 ;
    sis_i_segmentation_contexts  = 0 ;
    sis_i_max_destid = 0 ;
    sis_i_source_operations  = 0 ;
    sis_i_destination_operations  = 0 ;
    sis_i_flow_arbitration = 1'b0;
    
    sis_i_csr_tm_types_reset_value  = 0 ; 
    sis_i_csr_tm_mode_reset_value  = 0 ;
    sis_i_csr_mtu_reset_value  = 0 ;
    sis_i_csr_external_tm_mode_wr  = 0 ;
    sis_i_csr_external_mtu_wr  = 0 ;
    sis_i_csr_external_tm_mode_in  = 0 ;
    sis_i_csr_external_mtu_in  = 0 ;
    
    sis_i_message_error_response_set = 0 ;
    sis_i_gsm_error_response_set = 0;
    sis_i_message_format_error_response_set = 0;
    sis_i_external_illegal_transaction_decode_set = 0;
    sis_i_external_message_request_timeout_set = 0;
    sis_i_external_slave_packet_response_timeout_set = 0 ;
    sis_i_external_unsolicited_response_set = 0 ;
    sis_i_external_unsupported_transaction_set = 0 ;
    sis_i_external_missing_data_streaming_context_set = 0 ;
    sis_i_external_open_existing_data_streaming_context_set = 0 ;
    sis_i_external_long_data_streaming_segment_set = 0 ;
    sis_i_external_short_data_streaming_segment_set = 0 ;
    sis_i_external_data_streaming_pdu_length_error_set = 0 ;
    sis_i_external_capture_destinationID_wr = 0 ;
    sis_i_external_capture_destinationID_in = 0 ;
    sis_i_external_capture_sourceID_wr = 0 ;
    sis_i_external_capture_sourceID_in = 0 ;
    sis_i_external_capture_ftype_wr = 0 ;
    sis_i_external_capture_ftype_in = 0 ; 
    sis_i_external_capture_ttype_wr = 0 ;
    sis_i_external_capture_ttype_in = 0 ;
    sis_i_external_letter_wr = 0 ;
    sis_i_external_letter_in = 0 ;
    sis_i_external_mbox_wr = 0 ;
    sis_i_external_mbox_in = 0 ;
    sis_i_external_msgseg_wr = 0 ;
    sis_i_external_msgseg_in = 0 ;
    sis_i_external_xmbox_wr = 0 ;
    sis_i_external_xmbox_in = 0 ;
    
    sis_i_host_reset_value = 1'b1;  
    sis_i_master_enable_reset_value  = 1'b1;
    sis_i_discovered_reset_value  = 1'b1;
    sis_i_flow_control_participant_reset_value  = 1'b1;
    sis_i_enumeration_boundary_reset_value  = 1'b1;
    sis_i_flow_arbitration_participant_reset_value = 1'b1 ;
    sis_i_disable_destination_id_checking_reset_value = 1'b1 ;
    sis_i_transmitter_type_reset_value  = 1'b1;
    sis_i_receiver_type_reset_value =  2'b10;
  end // initial begin

  assign  sis_car_device_id [15:8] = sis_i_device_id_high;
  assign  sis_car_device_id [7:0] = sis_i_device_id_low;
  assign  sis_car_device_vendor_id = sis_i_device_vendor_id;
  assign  sis_car_device_revision_id = sis_i_device_revision_id;
  assign  sis_car_assey_id = sis_i_assey_id;
  assign  sis_car_assey_vendor_id = sis_i_assey_vendor_id;
  assign  sis_car_revision_id = sis_i_revision_id;
  assign  sis_car_bridge = sis_i_bridge;
  assign  sis_car_memory = sis_i_memory; 
  assign  sis_car_processor = sis_i_processor;
  assign  sis_car_switch = sis_i_switch;
  assign  sis_car_num_of_ports = sis_i_num_of_ports;
  assign  sis_car_port_num = sis_i_port_num;
  assign  sis_car_extended_route_table = sis_i_extended_route_table;
  assign  sis_car_standard_route_table = sis_i_standard_route_table;
  assign  sis_car_flow_arregration = sis_i_flow_arregration;
  assign  sis_car_flow_control =  sis_i_flow_control;
  assign  sis_car_max_pdu_size = sis_i_max_pdu_size;
  assign  sis_car_segmentation_contexts = sis_i_segmentation_contexts;
  assign  sis_car_max_destid = sis_i_max_destid;
  assign  sis_car_source_operations = sis_i_source_operations;
  assign  sis_car_destination_operations = sis_i_destination_operations;
  assign  sis_car_flow_arbitration = sis_i_flow_arbitration;
  
  assign  sis_csr_tm_types_reset_value =  sis_i_csr_tm_types_reset_value; 
  assign  sis_csr_tm_mode_reset_value = sis_i_csr_tm_mode_reset_value;
  assign  sis_csr_mtu_reset_value = sis_i_csr_mtu_reset_value;
  assign  sis_csr_external_tm_mode_wr = sis_i_csr_external_tm_mode_wr;
  assign  sis_csr_external_mtu_wr = sis_i_csr_external_mtu_wr;
  assign  sis_csr_external_tm_mode_in = sis_i_csr_external_tm_mode_in;
  assign  sis_csr_external_mtu_in = sis_i_csr_external_mtu_in;
  
  assign  sis_message_error_response_set = sis_i_message_error_response_set;
  assign  sis_gsm_error_response_set = sis_i_gsm_error_response_set;
  assign  sis_message_format_error_response_set = sis_i_message_format_error_response_set;
  assign  sis_external_illegal_transaction_decode_set =  sis_i_external_illegal_transaction_decode_set;
  assign  sis_external_message_request_timeout_set = sis_i_external_message_request_timeout_set;
  assign  sis_external_slave_packet_response_timeout_set = sis_i_external_slave_packet_response_timeout_set;
  assign  sis_external_unsolicited_response_set = sis_i_external_unsolicited_response_set;
  assign  sis_external_unsupported_transaction_set = sis_i_external_unsupported_transaction_set;
  assign  sis_external_missing_data_streaming_context_set = sis_i_external_missing_data_streaming_context_set;
  
  assign  sis_external_open_existing_data_streaming_context_set = sis_i_external_open_existing_data_streaming_context_set;
  assign  sis_external_long_data_streaming_segment_set = sis_i_external_long_data_streaming_segment_set;
  assign  sis_external_short_data_streaming_segment_set = sis_i_external_short_data_streaming_segment_set;
  assign  sis_external_data_streaming_pdu_length_error_set = sis_i_external_data_streaming_pdu_length_error_set;
  assign  sis_external_capture_destinationID_wr = sis_i_external_capture_destinationID_wr;
  assign  sis_external_capture_destinationID_in = sis_i_external_capture_destinationID_in;
  assign  sis_external_capture_sourceID_wr = sis_i_external_capture_sourceID_wr;
  assign  sis_external_capture_sourceID_in = sis_i_external_capture_sourceID_in;
  assign  sis_external_capture_ftype_wr = sis_i_external_capture_ftype_wr;
  assign  sis_external_capture_ftype_in = sis_i_external_capture_ftype_in; 
  assign  sis_external_capture_ttype_wr = sis_i_external_capture_ttype_wr;
  assign  sis_external_capture_ttype_in = sis_i_external_capture_ttype_in;
  assign  sis_external_letter_wr = sis_i_external_letter_wr;
  assign  sis_external_letter_in = sis_i_external_letter_in;
  assign  sis_external_mbox_wr = sis_i_external_mbox_wr;
  assign  sis_external_mbox_in = sis_i_external_mbox_in;
  assign  sis_external_msgseg_wr = sis_i_external_msgseg_wr;
  assign  sis_external_msgseg_in = sis_i_external_msgseg_in;
  assign  sis_external_xmbox_wr = sis_i_external_xmbox_wr;
  assign  sis_external_xmbox_in = sis_i_external_xmbox_in;
  
  
  assign  sis_host_reset_value = sis_i_host_reset_value;  
  assign  sis_master_enable_reset_value = sis_i_master_enable_reset_value;
  assign  sis_discovered_reset_value = sis_i_discovered_reset_value;
  assign  sis_flow_control_participant_reset_value = sis_i_flow_control_participant_reset_value;
  assign  sis_enumeration_boundary_reset_value = sis_i_enumeration_boundary_reset_value;
  assign  sis_flow_arbitration_participant_reset_value = sis_i_flow_arbitration_participant_reset_value;
  assign  sis_disable_destination_id_checking_reset_value = sis_i_disable_destination_id_checking_reset_value;
  assign  sis_transmitter_type_reset_value = sis_i_transmitter_type_reset_value;
  assign  sis_receiver_type_reset_value = sis_i_receiver_type_reset_value;
  assign  sis_ef_ptr_reset_value = sis_i_ef_ptr;
  
//------------------------------------------------------------------------
// RIO DUT side Master BFM
//------------------------------------------------------------------------

// Maintenance Bridge External Avalon-MM Slave Interface 
  avalon_mm_master_bfm_wrp #(
       .MM_ADDRESS_W               (32),
       .MM_SYMBOL_W                (8),           
       .MM_NUMSYMBOLS              (4),           
       .MM_BURSTCOUNT_W            (1),
       .MM_READRESPONSE_W          (1),
       .MM_WRITERESPONSE_W         (1),
       .MM_BEGIN_TRANSFER          (0),
       .MM_BEGIN_BURST_TRANSFER    (0),
       .MM_READRESPONSE            (0),
       .MM_USE_BURSTCOUNT          (0))               
                   
  sys_mnt_master_bfm(
           .clk                        (sys_clk), 
           .rst_n                      (rst_n), 
           .m_waitrequest              (ext_mnt_waitrequest),       
           .m_write                    (ext_mnt_write),           
           .m_read                     (ext_mnt_read),        
           .m_address                  (ext_mnt_address),           
           .m_byteenable               (),              
           .m_burstcount               (),              
           .m_writedata                (ext_mnt_writedata),                
           .m_readdata                 (ext_mnt_readdata),             
           .m_readdatavalid            (ext_mnt_readdatavalid),                
           .m_readresponse             (ext_mnt_readresponse)                  
          );

  // Maintenance Module User visible Avalon-MM Slave Interface
  assign mnt_s_address = mnt_s_address_bfm[25:0];
  avalon_mm_master_bfm_wrp #(
       .MM_ADDRESS_W               (32),
       .MM_SYMBOL_W                (8),           
       .MM_NUMSYMBOLS              (4),           
       .MM_BURSTCOUNT_W            (1),
       .MM_READRESPONSE_W          (1),
       .MM_WRITERESPONSE_W         (1),
       .MM_BEGIN_TRANSFER          (0),
       .MM_BEGIN_BURST_TRANSFER    (0),
       .MM_READRESPONSE            (1),
       .MM_USE_BURSTCOUNT          (0))            
                   
  bfm_mnt_master(
           .clk                        (sys_clk), 
           .rst_n                      (rst_n), 
           .m_waitrequest              (mnt_s_waitrequest),       
           .m_write                    (mnt_s_write),           
           .m_read                     (mnt_s_read),        
           .m_address                  (mnt_s_address_bfm),  
           .m_byteenable               (),  
           .m_burstcount               (),       
           .m_writedata                (mnt_s_writedata),                
           .m_readdata                 (mnt_s_readdata),             
           .m_readdatavalid            (mnt_s_readdatavalid),                
           .m_readresponse             (mnt_s_readerror)                  
          );


// IO Slave User visible Avalon-MM Slave Interface Write Interface
// for 128 bit module
  avalon_mm_master_bfm_wrp #(
       .MM_ADDRESS_W               (IO_SLAVE_ADDRESS_WIDTH) ,
       .MM_SYMBOL_W                (8),           
       .MM_NUMSYMBOLS              (16),           
       .MM_BURSTCOUNT_W            (5) ,
       .MM_READRESPONSE_W          (1),
       .MM_WRITERESPONSE_W         (1),
       .MM_BEGIN_TRANSFER          (0),
       .MM_BEGIN_BURST_TRANSFER    (0),
       .MM_READRESPONSE            (1),
       .MM_USE_BURSTCOUNT          (1))            
                   
  ios_128_rd_wr_master_bfm(
           .clk                        (sys_clk), 
           .rst_n                      (rst_n), 
           .m_waitrequest              (ios_rd_wr_waitrequest),       
           .m_write                    (ios_rd_wr_write),           
           .m_read                     (ios_rd_wr_read),        
           .m_address                  (ios_rd_wr_address),           
           .m_byteenable               (ios_rd_wr_byteenable),              
           .m_burstcount               (ios_rd_wr_burstcount),              
           .m_writedata                (ios_rd_wr_writedata),                
           .m_readdata                 (ios_rd_wr_readdata),             
           .m_readdatavalid            (ios_rd_wr_readdatavalid),                
           .m_readresponse             (ios_rd_wr_readresponse)                  
          );
  
  
 
   
  // IO Master User visible Avalon-MM Slave Interface Read-Write Interface
  // for 128 bit module

  avalon_mm_slave_bfm_wrp#(
           .S_ADDRESS_W               (IO_MASTER_ADDRESS_WIDTH),  // Address width in bits
           .S_SYMBOL_W                (8), // Data symbol width in bits
           .S_NUMSYMBOLS              (16), // Number of symbols per word
           .S_USE_BURSTCOUNT          (1),
           .S_BURSTCOUNT_W            (5), // Burst port width in bits
           .S_READRESPONSE_W          (1),
           .S_WRITERESPONSE_W         (0),  
           .S_BEGIN_TRANSFER          (0), // Use begintransfer pin on interface
           .S_BEGIN_BURST_TRANSFER    (0), // Use beginbursttransfer pin on interface
           .S_READRESPONSE            (1), // Use read response interface pins  
           .S_TRANSACTIONID_W         (8))

iom128_rd_wr_slave_bfm(
   .clk                      (sys_clk),
   .rst_n                    (rst_n),
   .s_waitrequest            (iom_rd_wr_waitrequest),
   .s_readdatavalid          (iom_rd_wr_readdatavalid),
   .s_readdata               (iom_rd_wr_readdata),
   .s_write                  (iom_rd_wr_write),
   .s_read                   (iom_rd_wr_read),
   .s_address                (iom_rd_wr_address),
   .s_byteenable             (iom_rd_wr_byteenable),
   .s_burstcount             (iom_rd_wr_burstcount),
   .s_writedata              (iom_rd_wr_writedata),
   .s_readresponse           (iom_rd_wr_readresponse));


//RIO SISTER DUT side TX Pass Through Source BFM
  avalon_st_src_bfm_wrp #(
           .ST_SYMBOL_W(8),
           .ST_NUMSYMBOLS(16),
           .ST_EMPTY_W(4),
           .ST_USE_PACKET(1),
           .ST_USE_EMPTY(1))
  tx_pt_src_bfm (
           .clk(sys_clk),
           .rst_n(rst_n),
           .src_data(gen_tx_data),
           .src_valid(gen_tx_valid),
           .src_startofpacket(gen_tx_startofpacket),
           .src_endofpacket(gen_tx_endofpacket),
           .src_error(),
           .src_empty(gen_tx_empty),                              
           .src_ready(gen_tx_ready)
           );
  //-------------------------------------------------
  // Doorbell User visible Avalon-MM Slave Interface
  //-------------------------------------------------
     avalon_mm_master_bfm_wrp #(
       .MM_ADDRESS_W               (4) ,
       .MM_SYMBOL_W                (8),           
       .MM_NUMSYMBOLS              (4),           
       .MM_BURSTCOUNT_W            (1) ,
       .MM_READRESPONSE_W          (1),
       .MM_WRITERESPONSE_W         (1),
       .MM_BEGIN_TRANSFER          (0),
       .MM_BEGIN_BURST_TRANSFER    (0),
       .MM_READRESPONSE            (0),
       .MM_USE_BURSTCOUNT          (0))            
                   
     drbl_master_bfm (
           .clk                        (sys_clk), 
           .rst_n                      (rst_n), 
           .m_waitrequest              (drbell_s_waitrequest),       
           .m_write                    (drbell_s_write),           
           .m_read                     (drbell_s_read),      
           .m_address                  (drbell_s_address), 
           .m_byteenable               (),
           .m_burstcount               (),               
           .m_writedata                (drbell_s_writedata),                
           .m_readdata                 (drbell_s_readdata),
           .m_readdatavalid            (),
           .m_readresponse             () 
                   
          ); 
  

//------------------------------------------------------------------------
// RIO SISTER DUT side Master BFM
//------------------------------------------------------------------------
// Maintenance Bridge External Avalon-MM Slave Interface
   avalon_mm_master_bfm_wrp #(
       .MM_ADDRESS_W               (32),
       .MM_SYMBOL_W                (8),           
       .MM_NUMSYMBOLS              (4),           
       .MM_BURSTCOUNT_W            (1),
       .MM_READRESPONSE_W          (1),
       .MM_WRITERESPONSE_W         (1),
       .MM_BEGIN_TRANSFER          (0),
       .MM_BEGIN_BURST_TRANSFER    (0),
       .MM_READRESPONSE            (1),
       .MM_USE_BURSTCOUNT          (0))             
                   
  sister_sys_mnt_master_bfm(
        .clk                        (sys_clk), 
        .rst_n                      (sister_rst_n), 
        .m_waitrequest              (sis_ext_mnt_waitrequest),       
        .m_write                    (sis_ext_mnt_write),           
        .m_read                     (sis_ext_mnt_read),        
        .m_address                  (sis_ext_mnt_address),           
        .m_byteenable               (),              
        .m_burstcount               (),              
        .m_writedata                (sis_ext_mnt_writedata),                
        .m_readdata                 (sis_ext_mnt_readdata),             
        .m_readdatavalid            (sis_ext_mnt_readdatavalid),                
        .m_readresponse             (sis_ext_mnt_readresponse));                  
       
  
  //Sister RIO DUT side RX Pass Through Header Sink BFM
  avalon_st_snk_bfm_wrp#(
                        .ST_SYMBOL_W(115),
                        .ST_NUMSYMBOLS(1),
                        .ST_EMPTY_W(1),
                        .ST_USE_PACKET(0),
                        .ST_USE_EMPTY(0))
  sister_pt_hdr_bfm (
                        .clk(sys_clk),
                        .rst_n(sister_rst_n),
                        .sink_data(sis_gen_rx_hd_data),
                        .sink_valid(sis_gen_rx_hd_valid),
                        .sink_startofpacket(1'b0),
                        .sink_endofpacket(1'b0),
                        .sink_error(),
                        .sink_empty(1'b0),                              
                        .sink_ready(sis_gen_rx_hd_ready)
                        );
  
  //Sister RIO DUT side RX Pass Through Payload Sink BFM
  avalon_st_snk_bfm_wrp#(
                        .ST_SYMBOL_W(8),
                        .ST_NUMSYMBOLS(16),
                        .ST_EMPTY_W(4),
                        .ST_USE_PACKET(1),
                        .ST_USE_EMPTY(1))
      sister_pt_pld_bfm (
                        .clk(sys_clk),
                        .rst_n(sister_rst_n),
                        .sink_data(sis_gen_rx_pd_data),
                        .sink_valid(sis_gen_rx_pd_valid),
                        .sink_startofpacket(sis_gen_rx_pd_startofpacket),
                        .sink_endofpacket(sis_gen_rx_pd_endofpacket),
                        .sink_error(),
                        .sink_empty(sis_gen_rx_pd_empty),                              
                        .sink_ready(sis_gen_rx_pd_ready)
                        );
                        
 //Sister RIO DUT side Master BFM 
 avalon_mm_master_bfm_wrp #(
       .MM_ADDRESS_W               (IO_SLAVE_ADDRESS_WIDTH) ,
       .MM_SYMBOL_W                (8),           
       .MM_NUMSYMBOLS              (16),           
       .MM_BURSTCOUNT_W            (5) ,
       .MM_READRESPONSE_W          (1),
       .MM_WRITERESPONSE_W         (1),
       .MM_BEGIN_TRANSFER          (0),
       .MM_BEGIN_BURST_TRANSFER    (0),
       .MM_READRESPONSE            (1),
       .MM_USE_BURSTCOUNT          (1))            
                   
  sister_ios_128_rd_wr_master_bfm(
           .clk                        (sys_clk), 
           .rst_n                      (sister_rst_n), 
           .m_waitrequest              (sis_ios_rd_wr_waitrequest),       
           .m_write                    (sis_ios_rd_wr_write),           
           .m_read                     (sis_ios_rd_wr_read),        
           .m_address                  (sis_ios_rd_wr_address),           
           .m_byteenable               (sis_ios_rd_wr_byteenable),              
           .m_burstcount               (sis_ios_rd_wr_burstcount),              
           .m_writedata                (sis_ios_rd_wr_writedata),                
           .m_readdata                 (sis_ios_rd_wr_readdata),             
           .m_readdatavalid            (sis_ios_rd_wr_readdatavalid),                
           .m_readresponse             (sis_ios_rd_wr_readresponse)                  
          );

  //-------------------------------------------------
  // Doorbell User visible Avalon-MM Slave Interface
  //-------------------------------------------------
     avalon_mm_master_bfm_wrp #(
       .MM_ADDRESS_W               (4) ,
       .MM_SYMBOL_W                (8),           
       .MM_NUMSYMBOLS              (4),           
       .MM_BURSTCOUNT_W            (1) ,
       .MM_READRESPONSE_W          (1),
       .MM_WRITERESPONSE_W         (1),
       .MM_BEGIN_TRANSFER          (0),
       .MM_BEGIN_BURST_TRANSFER    (0),
       .MM_READRESPONSE            (0),
       .MM_USE_BURSTCOUNT          (0))            
                   
     sister_drbl_master_bfm (
           .clk                        (sys_clk), 
           .rst_n                      (sister_rst_n), 
           .m_waitrequest              (sis_drbell_s_waitrequest),       
           .m_write                    (sis_drbell_s_write),           
           .m_read                     (sis_drbell_s_read),      
           .m_address                  (sis_drbell_s_address),   
           .m_byteenable               (),
           .m_burstcount               (),        
           .m_writedata                (sis_drbell_s_writedata),                
           .m_readdata                 (sis_drbell_s_readdata),
           .m_readdatavalid            (),
           .m_readresponse             ()           
              
          ); 

  // IO Master User visible Avalon-MM Slave Interface Read-Write Interface
  // for 128 bit module 
   avalon_mm_slave_bfm_wrp# (
            .S_ADDRESS_W               (IO_MASTER_ADDRESS_WIDTH), // Address width in bits
            .S_SYMBOL_W                (8), // Data symbol width in bits
            .S_NUMSYMBOLS              (16) , // Number of symbols per word
            .S_USE_BURSTCOUNT          (1) ,
            .S_BURSTCOUNT_W            (5) , // Burst port width in bits
            .S_READRESPONSE_W          (1) ,
            .S_WRITERESPONSE_W         (1) , 
            .S_BEGIN_TRANSFER          (0) , // Use begintransfer pin on interface
            .S_BEGIN_BURST_TRANSFER    (0) , // Use beginbursttransfer pin on interface
            .S_READRESPONSE            (1) , // Use read response interface pins  
            .S_TRANSACTIONID_W         (8)
                                ) 
   sister_iom128_rd_wr_slave_bfm (
            .clk                  (sys_clk),
            .rst_n                (sister_rst_n),
            .s_waitrequest        (sis_iom_rd_wr_waitrequest),
            .s_write              (sis_iom_rd_wr_write), 
            .s_read               (sis_iom_rd_wr_read),
            .s_address            (sis_iom_rd_wr_address), 
            .s_byteenable         (sis_iom_rd_wr_byteenable),
            .s_burstcount         (sis_iom_rd_wr_burstcount),
            .s_writedata          (sis_iom_rd_wr_writedata),
            .s_readdata           (sis_iom_rd_wr_readdata),
            .s_readdatavalid      (sis_iom_rd_wr_readdatavalid),
            .s_readresponse       (sis_iom_rd_wr_readresponse));

 
 //--------------------------------------------------------
 // End of TB Hookup
 //--------------------------------------------------------

 import verbosity_pkg::*;
 import avalon_utilities_pkg::*;
 import avalon_mm_pkg::*;
 import hutil_pkg::*;
 reg [31:0] reg_rd_data;
 reg [31:0] reg_wr_data;
 reg [31:0] exp_reg_data;
 reg [4:0] burstcnt;
 bit [3:0] ttype;
 bit promiscuous;
 bit pt_routed_pkt;
 reg rd_resp;
 string str;

 reg [15 : 0] source_id;
 reg [15 : 0] dest_id;
 reg [15 : 0] pt_dest_id;
 reg [15 : 0] source_dev_id;
 reg [15 : 0] dest_dev_id;
 bit [1: 0]   transport_type;
 reg [15 : 0] dest_id_t;
 reg [28  : 0  ] io_slave_width_mask;
 reg [28 : 0] rio_dut_addr;
 bit [31 : 0]base_dev_id_data;
 bit [31 : 0]exp_dst_base_dev_id_data;
 bit [31 : 0]dst_base_dev_id_data;
 bit [31 : 0]exp_src_base_dev_id_data;
 bit [31 : 0]src_base_dev_id_data;
 bit [2  : 0]init_port_width;
 bit trns_typ;
 int multicast_evnt_tx_cnt;
 int multicast_evnt_rx_cnt;
 int multicast_evnt_cnt;
 int i, j;

//----------------avalon_mm_mstr_trans.sv-----------------
task send_packet_avalon_mm;

  input reg  [1: 0] tt;
  input reg  [3: 0] ftype;
  input reg  [3: 0] ttype;
  input int         payload_size;
  input reg [15  : 0  ] dest_id;
  
  reg [1   : 0  ] trans_type;
  reg [15  : 0  ] rd_wr_byte_en;
  reg [31  : 0  ] reg_wr_data;
  reg [1   : 0  ] prio;
  reg [1   : 0  ] xamsbs;
  reg [28  : 0  ] rio_address;
  reg [7   : 0  ] payload [16];
  reg [28  : 0  ] ios_base_data_tmp;
  reg [27  : 0  ] ios_mask_data_tmp;
  reg [28  : 0  ] ios_offset_data_tmp;
  reg [31  : 0  ] ios_base_data;
  reg [31  : 0  ] ios_mask_data;
  reg [31  : 0  ] ios_offset_data;
  reg [28  : 0  ] io_slave_width_mask;
  bit [127:0] packet [];
  bit [IO_SLAVE_ADDRESS_WIDTH: 0] rd_wr_addr;

  int i,j; //rd_wr_index;
  int packet_size;
  bit swrite_en;
  bit nwrite_r_en;
  bit wen;
 //
  bit [127:0] rd_data;
  
begin
   //Fixing priority field to 2'b10
   prio          = 2'b10;
   xamsbs        = 2'b01;
   rd_wr_byte_en = 16'hffff;
   rio_address   = 29'b1_1110_1010_1101_1011_1110_1110_1111; //'h1EADBEEF?
   
   // trans type generation
   if ((ftype == 4'b0010) && (ttype == 0100))
   begin
      trans_type = 2'b00;
      $display("NREAD Transaction");
   end
   else if ((ftype == 4'b0101) && (ttype == 0100))
   begin
      trans_type = 2'b01;
      $display("NWRITE Transaction");
   end
   else if ((ftype == 4'b0101) && (ttype == 4'b0101))
   begin
      trans_type = 2'b10;
      $display("NWRITE_R Transaction");
   end
   else if ((ftype == 4'b0110) && (ttype == 4'b0000))
   begin
      trans_type = 2'b11;
      $display("SWRITE Transaction");
   end

//swrite_en bit set/reset for ios mapping window control reg 
   if (trans_type == 2'b11)
   begin
      swrite_en = 1'b1;
   end
   else
   begin
      swrite_en = 1'b0;
   end 
   
   //nwrite_r_en bit set/reset for ios mapping window control reg
   if (trans_type == 2'b10)
   begin
      nwrite_r_en = 1'b1;
   end
   else
   begin
      nwrite_r_en = 1'b0;
   end
   //address generation for ios transaction
 
   if (IO_SLAVE_WINDOWS > 5'd0)
   begin
     
      if (DIFF_32_IO_SLAVE_ADDRESS_WIDTH > 0) begin
            io_slave_width_mask = {{DIFF_32_IO_SLAVE_ADDRESS_WIDTH{1'b0}},{(29 - DIFF_32_IO_SLAVE_ADDRESS_WIDTH){1'b1}}};
      end else begin
            io_slave_width_mask = {IO_SLAVE_ADDRESS_WIDTH{1'b1}};
      end
      ios_base_data_tmp   = io_slave_width_mask[28:0] & tb_rio_address;
     
      // configuring IO_SLAVE MAPPING WINDOW_0 BASE REG
      ios_base_data     =  {ios_base_data_tmp, 3'b0};
      sys_mnt_master_bfm.read_write_cmd(REQ_WRITE,`IO_SLAVE_MAP_WINDOW_0_BASE,'hF,1,0,ios_base_data);

      $display("%t %m DUT IO_SLAVE MAPPING WINDOW_0 BASE REG configured",$time);
      rd_wr_addr = ios_base_data;
      $display("%d %t %m address",$time,rd_wr_addr);
      // configuring IO_SLAVE MAPPING WINDOW_0 MASK REG
      wen          = 1'b1;
      ios_mask_data_tmp   = 28'hffff_fff;
      ios_mask_data  =  {ios_mask_data_tmp, 1'b1, wen, 2'b0 };
      sys_mnt_master_bfm.read_write_cmd(REQ_WRITE,`IO_SLAVE_MAP_WINDOW_0_MASK,'hF,1,0,ios_mask_data);
      $display("%t %m DUT IO_SLAVE MAPPING WINDOW_0 MASK REG configured",$time);
      // configuring IO_SLAVE_MAP_WINDOW_0_OFFSET REG
      ios_offset_data_tmp = ios_base_data_tmp;
      ios_offset_data   =  {ios_offset_data_tmp , 1'b0, xamsbs};
      sys_mnt_master_bfm.read_write_cmd(REQ_WRITE,`IO_SLAVE_MAP_WINDOW_0_OFFSET,'hF,1,0,ios_offset_data);
      $display("%t %m DUT IO_SLAVE_MAP_WINDOW_0 OFFSET REG configured",$time);
      // configuring IO_SLAVE_MAP_WINDOW_0_CONTROL REG
      reg_wr_data   = {dest_id,8'h0, prio, 4'b0, swrite_en, nwrite_r_en};
      sys_mnt_master_bfm.read_write_cmd(REQ_WRITE,`IO_SLAVE_MAP_WINDOW_0_CONTROL,'hF,1,0,reg_wr_data);
      $display("%t %m DUT IO_SLAVE_MAP_WINDOW_0 CONTROL REG configured",$time);
   end
   else 
   begin 
      rd_wr_addr = {trans_type,1'b0,prio,1'b0,dest_id,xamsbs,rio_address};
      $display("%d %t %m address",$time,rd_wr_addr);
   end

   if (payload_size < 8)
        payload_size = 8;
   else
      payload_size = payload_size;
   
      packet_size = (payload_size*8);
   
   if (packet_size % 128)
        packet_size = (packet_size / 128) + 1;
      else
        packet_size = (packet_size / 128);
        packet = new[packet_size];
   
   for (i=0;i < payload_size; i = i + 16) begin
        j = (i/16);
        payload[0] = i;
        payload[1] = (i+1) >= payload_size ? 'h00 : (i+1);
        payload[2] = (i+2) >= payload_size ? 'h00 : (i+2);
        payload[3] = (i+3) >= payload_size ? 'h00 : (i+3);
        payload[4] = (i+4) >= payload_size ? 'h00 : (i+4);
        payload[5] = (i+5) >= payload_size ? 'h00 : (i+5);
        payload[6] = (i+6) >= payload_size ? 'h00 : (i+6);
        payload[7] = (i+7) >= payload_size ? 'h00 : (i+7);
        payload[8]  = (i+8) >= payload_size ? 'h00 : (i+8);
        payload[9]  = (i+9) >= payload_size ? 'h00 : (i+9);
        payload[10] = (i+10) >= payload_size ? 'h00 : (i+10);
        payload[11] = (i+11) >= payload_size ? 'h00 : (i+11);
        payload[12] = (i+12) >= payload_size ? 'h00 : (i+12);
        payload[13] = (i+13) >= payload_size ? 'h00 : (i+13);
        payload[14] = (i+14) >= payload_size ? 'h00 : (i+14);
        payload[15] = (i+15) >= payload_size ? 'h00 : (i+15);
        packet[j] = {payload[0],payload[1],payload[2],payload[3],payload[4],payload[5],payload[6],payload[7],payload[8],payload[9],payload[10],payload[11],payload[12],payload[13],payload[14],payload[15]};
      end
   end

for (int j = 0; j <= packet_size-1; j = j + 1)
  begin
      ios_128_rd_wr_master_bfm.read_write_cmd(REQ_WRITE,rd_wr_addr,16'hffff,packet_size,j,packet[j]);
  end

// configuring Input/Output Slave Interrupt Enable reg 0ffset: 0x10504
 reg_wr_data = {27'h0, 5'b11111}; //enabling all the intrrupt
 sys_mnt_master_bfm.read_write_cmd(REQ_WRITE,`IO_SLAVE_INTERRUPT_ENABLE,'hF,1,0,reg_wr_data);
 $display("%t %m DUT IO_SLAVE_INTERRUPT_ENABLE reg configured %h",$time, reg_wr_data);


  if (trans_type == 2'b10)
  begin
     #6000; //updation of reg takes at least 8 clock cycles after NWRITE_R
            // transaction
     //Checking Input/Output Slave Pending NWRITE_R Transactions reg value Offset: 0x10508
      sys_mnt_master_bfm.read_write_cmd(REQ_READ,`IO_SLAVE_PENDING_NWRITE_R_TRANS,'hF,1,0,00);
      sys_mnt_master_bfm.read_data(0,reg_rd_data,rd_resp);
      $display("%t %m no. of pending NWRITE_R Transaction is %h",  $time, reg_rd_data);
      //Checking Input/Output Slave Interrupt reg value offset: 0x10500
      sys_mnt_master_bfm.read_write_cmd(REQ_READ,`IO_SLAVE_INTERRUPT,'hF,1,0,00);
      sys_mnt_master_bfm.read_data(0,reg_rd_data,rd_resp);
      $display("%t %m pending NWRITE_R Transaction reg read data is %h",$time,reg_rd_data);
      if (reg_rd_data [5] == 1'b0)
      begin
         $display("%t %m no pending NWRITE_R Transaction",$time);
      end
      else
      begin
         $display("%t %m There is pending NWRITE_R Transaction" ,$time);
      end
  end
endtask


//----------avalon_mm_slavebfm_trans.sv--------------------------------------------------
task recieve_packet_avalon_mm;

  input reg  [1: 0] tt;
  input reg  [3: 0] ftype;
  input reg  [3: 0] ttype;
  input int         exp_payload_size; 
  input reg  [15:0] dest_id;  
  
  reg [15  : 0  ] source_id;
  reg [1   : 0  ] exp_trans_type;
  reg [15  : 0  ] exp_rd_wr_byte_en;
  reg [1   : 0  ] exp_prio;
  bit [1   : 0  ] xamsbs;
  bit [28  : 0  ] exp_rio_address;
  reg [7   : 0  ] exp_payload [16];
  bit [127 : 0  ] exp_packet [];
  bit [127:0]   actual_data ;
  bit [IO_MASTER_ADDRESS_WIDTH: 0] exp_rd_wr_addr;
  bit [IO_MASTER_ADDRESS_WIDTH: 0] actual_addr;
  bit [4 : 0 ] actual_burst_count;
  reg [15  : 0  ] actual_byte_enable ;
  reg [31 : 0 ]reg_wr_data;
  reg [28  : 0  ] iom_base_data;
  reg [27  : 0  ] iom_mask_data;
  reg [28 : 0]iom_offset_data;
  reg [28  : 0  ] io_master_width_mask;
  

  int i,j; 
  int exp_packet_size;
  bit swrite_en;
  bit nwrite_r_en;
  bit wen;
  bit error;
  bit timed_out;
  static time time_out = 100us;
 
begin
   info ("fetching data");
   //Fixing priority field to 2'b10
   exp_prio          = 2'b10;
   xamsbs            = 2'b01;
   exp_rd_wr_byte_en = 16'hffff;

   //exp_rd_wr_burstsize = exp_packet_size;
   // trans type generation
   if ((ftype == 4'b0010) && (ttype == 0100))
   begin
      exp_trans_type = 2'b00;
      $display("NREAD Transaction");
   end
   else if ((ftype == 4'b0101) && (ttype == 0100))
   begin
      exp_trans_type = 2'b01;
      $display("NWRITE Transaction");
   end
   else if ((ftype == 4'b0101) && (ttype == 4'b0101))
   begin
      exp_trans_type = 2'b10;
      $display("NWRITE_R Transaction");
   end
   else if ((ftype == 4'b0110) && (ttype == 4'b0000))
   begin
      exp_trans_type = 2'b11;
      $display("SWRITE Transaction");
   end

//swrite_en bit set/reset for iom mapping window control reg 
   if (exp_trans_type == 2'b11)
   begin
      swrite_en = 1'b1;
   end
   else
   begin
      swrite_en = 1'b0;
   end 
   
   //nwrite_r_en bit set/reset for iom mapping window control reg
   if (exp_trans_type == 2'b10)
   begin
      nwrite_r_en = 1'b1;
   end
   else
   begin
      nwrite_r_en = 1'b0;
   end

   if (tt == `SMALL) 
    source_id = 'h00AB;
   else
    source_id = 'hABAB;

    

if (IO_MASTER_WINDOWS > 5'd0)
   begin
   
     if (DIFF_32_IO_SLAVE_ADDRESS_WIDTH > 0) begin
            io_master_width_mask = {{DIFF_32_IO_SLAVE_ADDRESS_WIDTH{1'b0}},{(29 - DIFF_32_IO_SLAVE_ADDRESS_WIDTH) {1'b1}}};
      end else begin
            io_master_width_mask = {29{1'b1}};
      end
    
      exp_rio_address   = io_master_width_mask[28:0] &  tb_rio_address;
    
      iom_base_data   = exp_rio_address;
      // configuring IO_MASTER MAPPING WINDOW_0 BASE REG
      reg_wr_data     =  {iom_base_data, 3'b0};
      sister_sys_mnt_master_bfm.read_write_cmd(REQ_WRITE,`IO_MASTER_MAP_WINDOW_0_BASE,'hF,1,0,reg_wr_data);
      $display("%t %m SIS DUT IO_MASTER_MAP_WINDOW_0_BASE REG configured",$time);
      exp_rd_wr_addr = reg_wr_data;
      $display("%d %t %m address",$time,exp_rd_wr_addr);
      // configuring IO_MASTER MAPPING WINDOW_0 MASK REG
      wen          = 1'b1;
      iom_mask_data   = 28'hffff_fff;
      reg_wr_data   =  {iom_mask_data, 1'b1, wen, 2'b0 };
      sister_sys_mnt_master_bfm.read_write_cmd(REQ_WRITE,`IO_MASTER_MAP_WINDOW_0_MASK,'hF,1,0,reg_wr_data);
      $display("%t %m DUT IO_MASTER MAPPING WINDOW_0 MASK REG configured",$time);
      // configuring IO_MASTER_MAP_WINDOW_0_OFFSET REG
      iom_offset_data = iom_base_data;
      reg_wr_data   =  {iom_offset_data , 1'b0, xamsbs};
      sister_sys_mnt_master_bfm.read_write_cmd(REQ_WRITE,`IO_MASTER_MAP_WINDOW_0_OFFSET,'hF,1,0,reg_wr_data);
      $display("%t %m DUT IO_MASTER_MAP_WINDOW_0 OFFSET REG configured",$time);
   end
   else 
   begin
      exp_rd_wr_addr   = {xamsbs,exp_rio_address,3'b0};
      $display("%m %t Generated Exp read write address is %x",$stime,exp_rd_wr_addr);
   end 

if (exp_payload_size < 8)
     exp_payload_size = 8;
else
   exp_payload_size = exp_payload_size;

exp_packet_size = (exp_payload_size*8);

if (exp_packet_size % 128)
     exp_packet_size = (exp_packet_size / 128) + 1;
   else
     exp_packet_size = (exp_packet_size / 128);
     exp_packet = new[exp_packet_size];
$display("%m %t Generated Exp packet size is %x",$stime, exp_packet_size);

//exp_rd_wr_burstcnt = exp_packet_size;

for (i=0;i < exp_payload_size; i = i + 16) begin
     j = (i/16);
     exp_payload[0] = i;
     exp_payload[1] = (i+1) >= exp_payload_size ? 'h00 : (i+1);
     exp_payload[2] = (i+2) >= exp_payload_size ? 'h00 : (i+2);
     exp_payload[3] = (i+3) >= exp_payload_size ? 'h00 : (i+3);
     exp_payload[4] = (i+4) >= exp_payload_size ? 'h00 : (i+4);
     exp_payload[5] = (i+5) >= exp_payload_size ? 'h00 : (i+5);
     exp_payload[6] = (i+6) >= exp_payload_size ? 'h00 : (i+6);
     exp_payload[7] = (i+7) >= exp_payload_size ? 'h00 : (i+7);
     exp_payload[8]  = (i+8) >= exp_payload_size ? 'h00 : (i+8);
     exp_payload[9]  = (i+9) >= exp_payload_size ? 'h00 : (i+9);
     exp_payload[10] = (i+10) >= exp_payload_size ? 'h00 : (i+10);
     exp_payload[11] = (i+11) >= exp_payload_size ? 'h00 : (i+11);
     exp_payload[12] = (i+12) >= exp_payload_size ? 'h00 : (i+12);
     exp_payload[13] = (i+13) >= exp_payload_size ? 'h00 : (i+13);
     exp_payload[14] = (i+14) >= exp_payload_size ? 'h00 : (i+14);
     exp_payload[15] = (i+15) >= exp_payload_size ? 'h00 : (i+15);
     exp_packet[j] = {exp_payload[0],exp_payload[1],exp_payload[2],exp_payload[3],exp_payload[4],exp_payload[5],exp_payload[6],exp_payload[7],exp_payload[8],exp_payload[9],exp_payload[10],exp_payload[11],exp_payload[12],exp_payload[13],exp_payload[14],exp_payload[15]};
     $display("expected packet data is", exp_packet[j]);
  end

  begin
     fork
     begin // p1
        sister_iom128_rd_wr_slave_bfm.wait_for_write_cmd();
        $display("%m %t Transaction received on SISTER DUT IOM side",$stime);
     end //end p1
     begin//p2
        #time_out;   
        timed_out = 1;
     end // endp2
     join_any
  end 

   if (timed_out) 
   begin
      $display("%m %0t ERROR: Timed out waiting for Payload",$stime);
      err_cnt++;
      exit();
   end //end if timed_out
   else 
   begin
      for (j = 0; j <= exp_packet_size-1; j = j + 1)
      begin
         //pop command discriptor and retrieve Fields 
         sister_iom128_rd_wr_slave_bfm.read_write_data(j, actual_addr, actual_burst_count, actual_byte_enable, actual_data);            
         $display("%m %t Doing comparison for cycle %d",$stime,j);
         // compare fields
         if (j == 0)
         begin
               check("address",exp_rd_wr_addr[31:0], actual_addr[31 :0]);
         end
         expect_1("read write burst count",exp_packet_size,actual_burst_count);
         check("packet size",exp_packet_size, actual_burst_count);
         expect_1("read write byte enable is",16'hffff,actual_byte_enable);
         check("byte enable",exp_rd_wr_byte_en, actual_byte_enable);
         expect_1("pld_error",1'b0,error);
         check("pld_data",exp_packet[j][31:0],actual_data[31:0]); 
         check("pld_data",exp_packet[j][63:32],actual_data[63:32]); 
         check("pld_data",exp_packet[j][95:64],actual_data[95:64]); 
         check("pld_data",exp_packet[j][127:96],actual_data[127:96]);
      end // end for 
   end//end else timed_out
end
endtask


//--------------tb_ios_nread_trans.sv-----------------------------------------
task send_read_trans;

  input reg [1  : 0] tt;
  input bit [1  : 0] trans_type;          
  input     [15 : 0] rd_wr_byte_en;
  input bit [4  : 0] rd_wr_burstcnt;
  input reg [15 : 0] dest_id;
  
  int             exp_rd_payload_size;
  reg [31  : 0  ] reg_wr_data;
  reg [1   : 0  ] prio;
  reg [1   : 0  ] xamsbs;
  reg [28  : 0  ] rio_address;
  reg [7   : 0  ] payload [16];
  reg [27  : 0  ] ios_base_data_tmp;
  reg [27  : 0  ] ios_mask_data_tmp;
  reg [27  : 0  ] ios_offset_data_tmp;
  reg [31  : 0  ] ios_base_data;
  reg [31  : 0  ] ios_mask_data;
  reg [31  : 0  ] ios_offset_data;
  reg [27  : 0  ] io_slave_width_mask;

  bit [127:0] packet [];
  bit [IO_SLAVE_ADDRESS_WIDTH: 0] rd_wr_addr;

  int i,j; 
  bit wen;
 //
  bit [127:0] rd_data;
  
begin
   //Fixing priority field to 2'b10
   prio          = 2'b10;
   xamsbs        = 2'b01;
   rio_address   = 29'b1_1110_1010_1101_1011_1110_1110_1111; //'h1EADBEEF
   
   //address generation for ios transaction
   if (IO_SLAVE_WINDOWS > 5'd0)
   begin
          
      if (DIFF_32_IO_SLAVE_ADDRESS_WIDTH > 0) begin
        io_slave_width_mask = {{DIFF_32_IO_SLAVE_ADDRESS_WIDTH{1'b0}},{(28 - DIFF_32_IO_SLAVE_ADDRESS_WIDTH){1'b1}}};
      end else begin
        io_slave_width_mask = {28{1'b1}};
      end
      
      ios_base_data_tmp   = io_slave_width_mask & tb_rio_address[28:1];
      
      // configuring IO_SLAVE MAPPING WINDOW_0 BASE REG
      ios_base_data     =  {ios_base_data_tmp, 4'b0};
      sys_mnt_master_bfm.read_write_cmd(REQ_WRITE,`IO_SLAVE_MAP_WINDOW_0_BASE,'hF,1,0,ios_base_data);
      $display("%t %m DUT IO_SLAVE MAPPING WINDOW_0 BASE REG configured",$time);
      rd_wr_addr = ios_base_data;
      $display("%d %t %m address",$time,rd_wr_addr);
      // configuring IO_SLAVE MAPPING WINDOW_0 MASK REG
      wen          = 1'b1;
      ios_mask_data_tmp   = 28'hffff_fff;
      ios_mask_data  =  {ios_mask_data_tmp, 1'b1, wen, 2'b0 };
      sys_mnt_master_bfm.read_write_cmd(REQ_WRITE,`IO_SLAVE_MAP_WINDOW_0_MASK,'hF,1,0,ios_mask_data);
      $display("%t %m DUT IO_SLAVE MAPPING WINDOW_0 MASK REG configured",$time);
      // configuring IO_SLAVE_MAP_WINDOW_0_OFFSET REG
      ios_offset_data_tmp = ios_base_data_tmp;
      ios_offset_data   =  {ios_offset_data_tmp , 2'b0, xamsbs};
      sys_mnt_master_bfm.read_write_cmd(REQ_WRITE,`IO_SLAVE_MAP_WINDOW_0_OFFSET,'hF,1,0,ios_offset_data);
      $display("%t %m DUT IO_SLAVE_MAP_WINDOW_0 OFFSET REG configured",$time);
      // configuring IO_SLAVE_MAP_WINDOW_0_CONTROL REG
      reg_wr_data   = {dest_id,8'h0, prio, 4'b0, 1'b0, 1'b0};
      sys_mnt_master_bfm.read_write_cmd(REQ_WRITE,`IO_SLAVE_MAP_WINDOW_0_CONTROL,'hF,1,0,reg_wr_data);
      $display("%t %m DUT IO_SLAVE_MAP_WINDOW_0 CONTROL REG configured",$time);
   end
   else 
   begin 
      rd_wr_addr = {trans_type,1'b0,prio,1'b0,dest_id,xamsbs,rio_address};
      $display("%d %t %m address",$time,rd_wr_addr);
   end
  

   //payload size generation logic
   exp_rd_payload_size = (rd_wr_burstcnt * 16);
   $display(" %m payload size is %h",exp_rd_payload_size);
   packet = new[rd_wr_burstcnt];
      
   for (i=0;i < exp_rd_payload_size; i = i + 16) begin
        j = (i/16);
        payload[0] = i;
        payload[1] = (i+1) >= exp_rd_payload_size ? 'h00 : (i+1);
        payload[2] = (i+2) >= exp_rd_payload_size ? 'h00 : (i+2);
        payload[3] = (i+3) >= exp_rd_payload_size ? 'h00 : (i+3);
        payload[4] = (i+4) >= exp_rd_payload_size ? 'h00 : (i+4);
        payload[5] = (i+5) >= exp_rd_payload_size ? 'h00 : (i+5);
        payload[6] = (i+6) >= exp_rd_payload_size ? 'h00 : (i+6);
        payload[7] = (i+7) >= exp_rd_payload_size ? 'h00 : (i+7);
        payload[8]  = (i+8) >= exp_rd_payload_size ? 'h00 : (i+8);
        payload[9]  = (i+9) >= exp_rd_payload_size ? 'h00 : (i+9);
        payload[10] = (i+10) >= exp_rd_payload_size ? 'h00 : (i+10);
        payload[11] = (i+11) >= exp_rd_payload_size ? 'h00 : (i+11);
        payload[12] = (i+12) >= exp_rd_payload_size ? 'h00 : (i+12);
        payload[13] = (i+13) >= exp_rd_payload_size ? 'h00 : (i+13);
        payload[14] = (i+14) >= exp_rd_payload_size ? 'h00 : (i+14);
        payload[15] = (i+15) >= exp_rd_payload_size ? 'h00 : (i+15);
        packet[j] = {payload[0],payload[1],payload[2],payload[3],payload[4],payload[5],payload[6],payload[7],payload[8],payload[9],payload[10],payload[11],payload[12],payload[13],payload[14],payload[15]};
      end

//generating NREAD request. Retreiving & comparing Response data recieved   
  if (trans_type == 2'b00)
  begin
     ios_128_rd_wr_master_bfm.read_write_cmd(REQ_READ,rd_wr_addr,16'hffff,rd_wr_burstcnt,0,00);
     #1000;
     for (int j = 0; j <= rd_wr_burstcnt-1; j = j + 1)
     begin
        // pop response descriptor and retrieve fields
        ios_128_rd_wr_master_bfm.read_data(j,rd_data,rd_resp);
        check ("read response",1'b0, rd_resp);
        //compare data fields
        $display("%m %t Doing comparison for cycle %d",$stime,j);
        //expect_1("pld_error",1'b0, error);
        check("pld_rd_data",packet[j][31:0],rd_data[31:0]); 
        check("pld_rd_data",packet[j][63:32],rd_data[63:32]); 
        check("pld_rd_data",packet[j][95:64],rd_data[95:64]); 
        check("pld_rd_data",packet[j][127:96],rd_data[127:96]);
     end // end for 
  end

end //final
endtask


task send_read_response;

  input reg [1 : 0] tt;
  input bit [1 : 0] trans_type;

  bit [4 : 0] rd_burstcnt;
  reg [7   : 0  ] payload [16];
  bit [15 : 0]rd_byte_enable;
  
  bit timed_out;
  static time time_out = 100us;
  int i,j;
  int            payload_size;
  int exp_rd_payload_size;
  bit [127:0] packet [];
  int temp_rd_burstcnt;
  bit [4 : 0] rd_burst_size;

begin

  //pop read command descriptor at SISTER DUT
   begin
      fork
      begin // p1
         if (trans_type == 2'b00) //if read pop read command 
         begin
            for (int j = 0; j <= rd_burstcnt-1; j = j + 1)
            begin
               sister_iom128_rd_wr_slave_bfm.wait_for_read_cmd(j,rd_burstcnt,rd_byte_enable);
            end //end for
         end
      end //end p1
      begin//p2
         #time_out;   
         timed_out = 1;
      end // endp2
      join_any
   end 

   if (timed_out) 
   begin
      $display("%m %0t ERROR: Timed out waiting for Payload",$stime);
      err_cnt++;
      exit();
   end //end if timed_out
   else 
   begin
      //payload size generation logic
      temp_rd_burstcnt = rd_burstcnt;
      $display("read burst_count is %d", temp_rd_burstcnt);
      payload_size = (temp_rd_burstcnt * 16);
      $display("read Payload_size is %d", payload_size);
      packet = new[temp_rd_burstcnt];

  
      for (i=0;i < payload_size; i = i + 16) begin
           j = (i/16);
           payload[0] = i;
           payload[1] = (i+1) >= payload_size ? 'h00 : (i+1);
           payload[2] = (i+2) >= payload_size ? 'h00 : (i+2);
           payload[3] = (i+3) >= payload_size ? 'h00 : (i+3);
           payload[4] = (i+4) >= payload_size ? 'h00 : (i+4);
           payload[5] = (i+5) >= payload_size ? 'h00 : (i+5);
           payload[6] = (i+6) >= payload_size ? 'h00 : (i+6);
           payload[7] = (i+7) >= payload_size ? 'h00 : (i+7);
           payload[8]  = (i+8) >= payload_size ? 'h00 : (i+8);
           payload[9]  = (i+9) >= payload_size ? 'h00 : (i+9);
           payload[10] = (i+10) >= payload_size ? 'h00 : (i+10);
           payload[11] = (i+11) >= payload_size ? 'h00 : (i+11);
           payload[12] = (i+12) >= payload_size ? 'h00 : (i+12);
           payload[13] = (i+13) >= payload_size ? 'h00 : (i+13);
           payload[14] = (i+14) >= payload_size ? 'h00 : (i+14);
           payload[15] = (i+15) >= payload_size ? 'h00 : (i+15);
           packet[j] = {payload[0],payload[1],payload[2],payload[3],payload[4],payload[5],payload[6],payload[7],payload[8],payload[9],payload[10],payload[11],payload[12],payload[13],payload[14],payload[15]};
      end //end for
   end // end else timed_out

//burst_size generation logic
rd_burst_size = rd_burstcnt;

for (int j = 0; j <= rd_burstcnt-1; j = j + 1)
  begin
      // create response descriptor and send read data
      sister_iom128_rd_wr_slave_bfm.write_read_data(REQ_READ, j, rd_burstcnt, rd_burst_size, packet[j]);
      $display("%m %t %d read response descriptor created",$time,j);
  end


end // final
endtask //send_read_response

task port_wr_test_trans;

input int payload_size; // in terms of byte
input reg  [15: 0] dest_id;

bit clr_buf_int_en      ;
bit port_write_en     ;
bit rx_pkt_stored     ;
bit portwr_err_int_en     ;
bit rx_pkt_dropped_int_en    ;
bit wr_out_of_bounds_int_en ; 
bit rd_out_of_bounds_int_en ; 

//internal signal declaration
reg [ 31 : 0 ] tx_buffer_address;
reg [ 31 : 0 ] rx_buffer_address;
reg [ 31 : 0 ] reg_rd_data;
reg [ 31 : 0 ] reg_wr_data;
reg [ 1  : 0 ] prio;
bit packet_rdy;
bit [31:0] packet [];
reg [7 : 0] payload [4];
reg [3 : 0] payload_size_word;
reg [3 : 0] payload_size_dword;

int i, j;

 begin
    if (payload_size < 4)  // payload size in byte
       payload_size = 4;
    else if (payload_size > 64)
       payload_size = 64;
    else
       payload_size = payload_size;
   
    payload_size_word = ((payload_size * 8) / 32); // payload size in words
 
    if (payload_size < 8)
      payload_size_dword = 0;
    else if ((payload_size*8)/64)
       payload_size_dword = ((payload_size*8)/64);
    else 
       payload_size_dword = (((payload_size*8)/64) -1);
    
    packet = new [payload_size_word];

    clr_buf_int_en             = 1'b1;           
    port_write_en              = 1'b1;
    rx_pkt_stored              = 1'b1; 
    portwr_err_int_en          = 1'b1;
    rx_pkt_dropped_int_en      = 1'b1;
    wr_out_of_bounds_int_en    = 1'b1;
    rd_out_of_bounds_int_en    = 1'b1;

    info("Verify Tx Port-Write DUT to Rx Port-write SISTER");
    // Tx Port Write Control register Offset: 0x10200 configuration DUT
    prio     = 2'b10;
    packet_rdy = 1'b0;
    reg_wr_data = {dest_id, 8'h0,prio,payload_size_dword,1'b0,packet_rdy};
    sys_mnt_master_bfm.read_write_cmd(REQ_WRITE,`TX_PORT_WRITE_CONTROL,'hF,1,0,reg_wr_data);
    // enable Rx Port Write Control Offset: 0x10250 SISTER DUT
    reg_wr_data = {30'b0, clr_buf_int_en, port_write_en};
    sister_sys_mnt_master_bfm.read_write_cmd(REQ_WRITE,`RX_PORT_WRITE_CONTROL,'hF,1,0,reg_wr_data);
    $display("%m port write enabled for sister dut");
    // Interrupt reg Offset: 0x10084 SISTER DUT
    // enable Rx packet stored interrupt
    reg_wr_data = {25'b0, portwr_err_int_en, rx_pkt_dropped_int_en, 
             rx_pkt_stored, 2'b0, wr_out_of_bounds_int_en, rd_out_of_bounds_int_en};
    sister_sys_mnt_master_bfm.read_write_cmd(REQ_WRITE,`MAINTENANCE_INTERRUPT_ENABLE,'hF,1,0,reg_wr_data);
    sys_mnt_master_bfm.read_write_cmd(REQ_WRITE,`MAINTENANCE_INTERRUPT_ENABLE,'hF,1,0,reg_wr_data);
    $display("%m maintenance interrupt enabled for dut & sister dut");
   
   //fork
      // Tx port write
      //begin //process 1
         // Write Tx port write data
         wait (sis_mnt_mnt_s_irq == 1'b0); // Make sure sister rio buffer is read and cleared
         // Set up Tx port write payload
         for (i=0;i < payload_size; i = i + 4) 
         begin
            j = (i/4);
            payload[0] = i;
            payload[1] = (i+1) >= payload_size ? 'h00 : (i+1);
            payload[2] = (i+2) >= payload_size ? 'h00 : (i+2);
            payload[3] = (i+3) >= payload_size ? 'h00 : (i+3);
            packet[j] = {payload[0],payload[1],payload[2],payload[3]};
            $display("packet data is", packet[j]);
         end
         for (int j = 0; j <= payload_size_word-1; j = j + 1)
         begin
            tx_buffer_address = `TX_PORT_WRITE_BUFFER + 4*j;
            sys_mnt_master_bfm.read_write_cmd(REQ_WRITE,tx_buffer_address,'hF,1,0,packet[j]);
            $display ("%0t: data written on tx port write buffer %0h", $time, packet[j]);
         end
         // Set up Tx port write control register
            // set packet ready to to initiate transaction 
            // indicate port write processor that data is ready
            packet_rdy = 1'b1;
            reg_wr_data = {dest_id,8'h0,prio,payload_size_dword,1'b0,packet_rdy};
            sys_mnt_master_bfm.read_write_cmd(REQ_WRITE,`TX_PORT_WRITE_CONTROL,'hF,1,0,reg_wr_data);
            $display ("%t: Sent DUT port write packet %h", $time, i);
     //end   
      
    // Rx port write
     //begin //process 2
        wait (sis_mnt_mnt_s_irq == 1'b1);
        //verify that packet stored bit is set for sister dut
        info ("Sister RIO system interrupt asserted");
        sister_sys_mnt_master_bfm.read_write_cmd(REQ_READ,`MAINTENANCE_INTERRUPT,'hF,1,0,reg_rd_data);
        sister_sys_mnt_master_bfm.read_data(0,reg_rd_data,rd_resp);
        check("MAINTENANCE_INTERRUPT",{27'h0,1'b1,4'b0},reg_rd_data);
        donecheck("MAINTENANCE_INTERRUPT CSR Read done");
        expect_1 ("Check Rx port write stored interrupt", 32'h10, reg_rd_data);
        $display ("%0t: Received port write packet", $time);

        // generate expected port write read data
        for (i=0;i < payload_size; i = i + 4) 
        begin
           j = (i/4);
           payload[0] = i;
           payload[1] = (i+1) >= payload_size ? 'h00 : (i+1);
           payload[2] = (i+2) >= payload_size ? 'h00 : (i+2);
           payload[3] = (i+3) >= payload_size ? 'h00 : (i+3);
           packet[j] = {payload[0],payload[1],payload[2],payload[3]};
           $display("packet data is", packet[j]);
        end
        // Check Rx port write data
        for (int j = 0; j <= payload_size_word-1; j = j + 1)
        begin
           rx_buffer_address = `RX_PORT_WRITE_BUFFER + 4*j;
           sister_sys_mnt_master_bfm.read_write_cmd(REQ_READ,rx_buffer_address,'hF,1,0,00);
           sister_sys_mnt_master_bfm.read_data(0,reg_rd_data,rd_resp);
           check("Validate RX_PORT_WRITE_BUFFER",packet[j], reg_rd_data);
           expect_1 ("Check Rx port write data" ,packet[j], reg_rd_data);
           donecheck("RX_PORT_WRITE_BUFFER CSR Read done");
        end 
         
        // Check Rx port status for correct payload size
        sister_sys_mnt_master_bfm.read_write_cmd(REQ_READ,`RX_PORT_WRITE_STATUS,'hF,1,0,reg_rd_data);
        sister_sys_mnt_master_bfm.read_data(0,reg_rd_data,rd_resp);
        check("Validate RX_PORT_WRITE_STATUS CSR value",{26'h0, payload_size_dword, 2'b00},reg_rd_data);
        donecheck("RX_PORT_WRITE_STATUS CSR read done");
        expect_1 ("Check Rx port write status", {26'h0, payload_size_dword, 2'b00}, reg_rd_data);
        // Write 1 to clear packet stored interrupt at sister dut
        reg_wr_data = 32'h10;
        sister_sys_mnt_master_bfm.read_write_cmd(REQ_WRITE,`MAINTENANCE_INTERRUPT,'hF,1,0,reg_wr_data);
        sister_sys_mnt_master_bfm.read_write_cmd(REQ_READ,`MAINTENANCE_INTERRUPT,'hF,1,0,reg_rd_data);
        sister_sys_mnt_master_bfm.read_data(0,reg_rd_data,rd_resp);
        check("Validate MAINTENANCE_INTERRUPT CSR value",'h00,reg_rd_data);
        donecheck("MAINTENANCE_INTERRUPT CSR Read done");      
        expect_1 ("Check Rx port write stored interrupt clear", 32'h0, reg_rd_data);
     //end
  //join
end
endtask


//--------------include tb_mnt_test.sv---------------------------------------------------
task mnt_test_rw_trans;

input  Request_t  rd_wr_req;
input bit [15:0] dest_id;

reg [ 23 : 0 ] mnt_offset;
reg [ 31 : 0 ] mnt_wr_data;
reg [ 31 : 0 ] mnt_rd_data;
reg [ 31 : 0 ] exp_mnt_data;
reg [ 2  : 0 ] prio;
reg [ 31 : 0 ] mnt_base_reg_addr;
reg [ 31 : 0 ] mnt_mask_reg_addr;
reg [ 31 : 0 ] mnt_offset_reg_addr;
reg [ 31 : 0 ] mnt_cntrl_reg_addr;
reg [ 31 : 0 ] mnt_address;
bit [ 7  : 0 ] hop_cnt;
bit wen;
bit [ 31 : 0 ] reg_wr_data;

int i,j;

begin
   info ("verifying maintenance transaction");
//mnt reg configuration

   for (i = 0; i < 2; i = i +1)
   begin
      // configuration Tx Maintenance Mapping Window n Base Offset: 0x10100 and 0x10110 as 
      reg_wr_data = 32'h00000124;//`PORT_0_TIMEOUT_CSR //32'h00000060; // base device id csr
      mnt_base_reg_addr = `TX_MAINTENANCE_WINDOW_0_BASE + 16*i;
      sys_mnt_master_bfm.read_write_cmd(REQ_WRITE,mnt_base_reg_addr,'hF,1,0,reg_wr_data);
      $display("%t %m DUT TX MAINTENANCE WINDOW_0 BASE REG configured",$time);
      $display("%t %m DUT TX MAINTENANCE WINDOW_0 BASE REG address %h",$time,mnt_base_reg_addr);
      mnt_address = reg_wr_data;
      $display("%m mnt address %h",mnt_address);
      
      //TX_MAINTENANCE_WINDOW_MASK reg configuration DUT
      wen = 1'b1;
      reg_wr_data  = {28'hffff_fff, 1'b1,wen, 2'b0};
      mnt_mask_reg_addr     =  `TX_MAINTENANCE_WINDOW_0_MASK + 16*i;
      sys_mnt_master_bfm.read_write_cmd(REQ_WRITE,mnt_mask_reg_addr,'hF,1,0,reg_wr_data);
      $display("%t %m DUT TX MAINTENANCE WINDOW MASK REG configured",$time);
      $display("%m DUT TX MAINTENANCE WINDOW MASK REG address %h",mnt_mask_reg_addr);
           
     //Tx Maintenance Mapping Window n Offset Offset: 0x10108, 0x10118
     mnt_offset = 24'h000124; // base device id csr
     reg_wr_data = {8'b0, mnt_offset };
     mnt_offset_reg_addr  = `TX_MAINTENANCE_WINDOW_0_OFFSET + 16*i;
     sys_mnt_master_bfm.read_write_cmd(REQ_WRITE,mnt_offset_reg_addr,'hF,1,0,reg_wr_data);
     $display("%t %m DUT TX MAINTENANCE WINDOW_0 OFFSET REG configured",$time);
     $display("%m DUT TX MAINTENANCE WINDOW_0 OFFSET REG address %h",mnt_offset_reg_addr );
     //TX_MAINTENANCE_WINDOW_CONTROL reg configuration DUT
     prio = 2'b10;
     hop_cnt = 8'b1111_1111;
     //reg_wr_data = {dest_id, hop_cnt, prio, 6'b0};
     if (TRANSPORT_LARGE == 1'b1)
        reg_wr_data = 32'hcdcdff80;
     else
        reg_wr_data = 32'h00cdff80;
     $display ("Destination id is %h", dest_id);
     $display ("Maintenance Control reg write data is %h", reg_wr_data);
     //deafult value of hop count is 8'hFF
     mnt_cntrl_reg_addr = `TX_MAINTENANCE_WINDOW_0_CONTROL + 16*i;
     sys_mnt_master_bfm.read_write_cmd(REQ_WRITE,mnt_cntrl_reg_addr,'hF,1,0,reg_wr_data);
     $display("%t %m DUT TX MAINTENANCE WINDOW_0 CONTROL REG configured",$time);
     $display("%m DUT TX MAINTENANCE WINDOW_0 CONTROL REG address %h",mnt_cntrl_reg_addr);
   end

   if (rd_wr_req == REQ_WRITE)
   begin
      //Write timeout value to PORT_0_TIMEOUT_CSR as maintenance write
      mnt_wr_data = 32'hff_00ff_00;
      bfm_mnt_master.read_write_cmd(REQ_WRITE,mnt_address,'hF,1,0,mnt_wr_data);
      $display("%t %m DUT & mm data sent = %d",$time, mnt_wr_data);
      //Read base device id csr value
      //#1000;
      //sister_sys_mnt_master_bfm.read_write_cmd(REQ_READ,`PORT_0_TIMEOUT_CSR,'hF,1,0,00);
      //sister_sys_mnt_master_bfm.read_data(0,reg_rd_data,rd_resp);
      //check("Validate maintenance write value",'hFF_00FF_00,reg_rd_data);
      //donecheck("maintenance write done");
   end
//
  if (rd_wr_req == REQ_READ)
  begin
     exp_mnt_data = mnt_wr_data;
     $display("expected maintenance data is %h",exp_mnt_data); 
     //send read request PORT_0_TIMEOUT_CSR through maintenance slave
     bfm_mnt_master.read_write_cmd(REQ_READ, mnt_address,'hF,1,0,00);
     //collect read data from maintainance slave interface
     //compare with actual reg content
     bfm_mnt_master.read_data(0,mnt_rd_data,rd_resp);
     check("Validates maintenance read data",exp_mnt_data,mnt_rd_data);
     donecheck("Maintenance Read done");
  end

       #500;
     info("Maintenance Read Write Test complete");
end //
endtask

 //-------------------tb_doorbell_test.sv-------------------------------------------------------------
 task doorbell_test_trans;

input bit [15 : 0] dest_id;
input bit [1  : 0] tt;
bit tx_cpl_overflow ; //enable interrupt 
bit tx_cpl          ;
bit rx_int_en       ;

bit error     ;
bit completed ;
int i;
bit[1:0]error_code;

reg [2:0] drbl_prio;
reg [7:0] info_msb;
reg [7:0] info_lsb;
reg [31 : 0]exp_data;
reg [15 : 0]msg_data;

//internal reg declaration

reg [31 : 0 ] reg_wr_data;
reg [31 : 0 ] reg_rd_data;

reg [15 :0] source_id;

begin

   if (tt == `SMALL) 
    source_id = 16'h00AB;
   else
    source_id = 16'hABAB;

   tx_cpl_overflow = 1'b1;
   tx_cpl          = 1'b1;
   rx_int_en       = 1'b1;
   error           = 1'b1;
   completed       = 1'b1;
   //configure interrupt enable reg Offset: 0x20
   reg_wr_data = {29'b0, tx_cpl_overflow, tx_cpl, rx_int_en};
   drbl_master_bfm.read_write_cmd(REQ_WRITE,`DRBELL_INTR_ENABLE,'hF,1,0,reg_wr_data);
   $display("%m doorbell interrupt enable reg configured data is %h",reg_wr_data);
   // enable confirmation of successful outbound messages
   // set completed and error bit of the Tx Doorbell Status Control Offset: 0x1C
   // to enable completion & error reporting.
   reg_wr_data = {30'b0, error, completed};
   drbl_master_bfm.read_write_cmd(REQ_WRITE,`DRBELL_TX_STATUS_CNTRL,'hF,1,0,reg_wr_data);
   $display("%m doorbell status control reg configured data is %h",reg_wr_data);
   //set priority to the doorbell message
   //write priority field to Tx Doorbell Control Offset: 0x08
   drbl_prio = 2'b10;
   reg_wr_data = {30'b0, drbl_prio};
   drbl_master_bfm.read_write_cmd(REQ_WRITE,`DRBELL_TX_CNTRL,'hF,1,0,reg_wr_data);
   $display("%m doorbell tx control reg configured data is %h",reg_wr_data);
   //------------------------------------------------------------------------------
   //configure doorbell registers at sister dut side
   //------------------------------------------------------------------------------
   //Doorbell Interrupt Enable reg Offset: 0x20
   //configure intrrupt enable reg 
   reg_wr_data = {29'b0, 3'b1};//{29'b0, tx_cpl_overflow, tx_cpl, rx_int_en};
   sister_drbl_master_bfm.read_write_cmd(REQ_WRITE,`DRBELL_INTR_ENABLE,'hF,-1,0,reg_wr_data);
   $display("%m sister side doorbell interrupt enable reg configured data is %h",reg_wr_data);   
   // enable confirmation of successful outbound messages
   // set completed bit of the Tx Doorbell Status Control Offset: 0x1C
   reg_wr_data = {30'b0, error, completed};
   sister_drbl_master_bfm.read_write_cmd(REQ_WRITE,`DRBELL_TX_STATUS_CNTRL,'hF,1,0,reg_wr_data);
   $display("%m sister side doorbell status control reg configured data is %h",reg_wr_data);
     
   
   //set message data fields for doorbell transaction
   info_msb  = 8'b1111_1010;
   info_lsb  = 8'b1111_1100;
   msg_data  = {info_msb,info_lsb};
   $display("%m message data is %h",msg_data);
   //for (int i = 0; i < 7; i = i + 1)
   //begin
      wait (drbell_s_irq === 1'b0);
      begin
        //Tx Doorbell reg Offset: 0x0C
         msg_data  = msg_data +i;
         reg_wr_data = {dest_id, msg_data};
         drbl_master_bfm.read_write_cmd(REQ_WRITE,`DRBELL_TX_DOORBELL,'hF,1,0,reg_wr_data);
         $display("%m message data written in tx doorbell reg is %h",reg_wr_data);
      end
      // verify that the DOORBELL request packets have been sent
      // interrupt is set in both cases either request is sent or response
      // is recieved
      wait (drbell_s_irq == 1'b1);
      //begin 
         // check for the interrupt type
         //read doorbell interrupt status reg offset 0x24
         drbl_master_bfm.read_write_cmd(REQ_READ,`DRBELL_INTR_STATUS,'hF,1,0,00);
         drbl_master_bfm.read_data(0,reg_rd_data,rd_resp);
         //int_status = reg_rd_data;      
         if (reg_rd_data [1] == 1'b1) //interrupt asserted due to Tx completion status
         begin
            $display ("request sent");
            $display ("interrupt asserted due to Tx completion status");
         end
      //end // wait drbell_s_irq == 1'b1
   
   //-----------------------------------------------------------------------------------
   //receive doorbell message at sister dut side
   //for (int i = 0; i < 7; i = i + 1)
   //begin
      // wait for the DOORBELL request packets reception
      // interrupt is set in both cases either request is sent or response
      // is recieved
      wait (sis_drbell_s_irq == 1'b1);
      // check for the interrupt type
      //read doorbell interrupt status reg offset 0x24 at sis dut side
      sister_drbl_master_bfm.read_write_cmd(REQ_READ,`DRBELL_INTR_STATUS,'hF,1,0,00);
      sister_drbl_master_bfm.read_data(0,reg_rd_data,rd_resp);
      $display ("sister dut doorbell interrupt status reg is %h",reg_rd_data);
      //int_status = reg_rd_data;      
      if (reg_rd_data [0] == 1'b1) // interrupt asserted due to recieved message
      begin
         $display ("request recieved");
         $display ("interrupt asserted due to message data recieved");
         //read reg Rx Doorbell Offset: 0x00 for the available DOORBELL messages in the Rx FIFO
         //check data integrity at sister dut side
         sister_drbl_master_bfm.read_write_cmd(REQ_READ,`DRBELL_RX_DOORBELL,'hF,1,0,00);
         sister_drbl_master_bfm.read_data(0,reg_rd_data,rd_resp);
         exp_data = {source_id, msg_data};
         $display("%m source id is %h",source_id);
         check("Validate DRBELL_RX_DOORBELL reg value", exp_data ,reg_rd_data);//write vale to compare
         donecheck("DRBELL_RX_DOORBELL reg Read done");
      end
      //wait for response at dut side
         wait (drbell_s_irq == 1'b1)
         // check for the interrupt type
         //read doorbell interrupt status reg offset 0x24
         drbl_master_bfm.read_write_cmd(REQ_READ,`DRBELL_INTR_STATUS,'hF,1,0,00);
         drbl_master_bfm.read_data(0,reg_rd_data,rd_resp);
         $display("%m interrupt status read data is %h",reg_rd_data);
         //int_status = reg_rd_data;      
         if (reg_rd_data [0] == 1'b1) //interrupt asserted due to Tx completion status
         begin
            $display ("interrupt asserted due to recieved message");
         end
         if (reg_rd_data [1] == 1'b1) // interrupt asserted due to recieved message
         begin
            $display ("response recieved");
            $display ("interrupt asserted due to Tx completion status");
            // read doorbell completion status reg offset 0x18
            drbl_master_bfm.read_write_cmd(REQ_READ,`DRBELL_TX_COMPLETION_STATUS,'hF,1,0,00);
            drbl_master_bfm.read_data(0,reg_rd_data,rd_resp);
            error_code =  reg_rd_data [1 :0];
            // response without error
            if (error_code == 2'b00)
            begin
               $display("successfully recieved response data");
               drbl_master_bfm.read_write_cmd(REQ_READ,`DRBELL_TX_COMPLETION,'hF,1,0,00);
               drbl_master_bfm.read_data(0,reg_rd_data,rd_resp);
               exp_data = {dest_id, msg_data}; //change it to dest id
               check("Validate DRBELL_TX_COMPLETION reg value",exp_data,reg_rd_data);
               donecheck("DRBELL_TX_COMPLETION reg Read done");
            end
            //response timeout recieved
            if (error_code == 2'b10)
            begin
               $display ("response timeout");
            end
            // response with error status recieved
            if (error_code == 2'b01)
            begin
               $display ("response with error status recieved");
            end
         end // if (reg_rd_data [0] == 1'b1)
         //clear interrupt status bit by writing 1 to doorbell interrupt status register
         reg_wr_data = {29'b0, 1'b1, 1'b1, 1'b1};
         drbl_master_bfm.read_write_cmd(REQ_WRITE,`DRBELL_INTR_STATUS,'hF,1,0,reg_wr_data);
         $display("interrupt cleared");
   //end // end for
end // final
endtask
     

 
 
 //---------------------------------------------------------------
 //Testbench starts 
 //---------------------------------------------------------------
 initial 
 begin
     $display("==================================================================================");
     $display("title      : tb.demo");
     $display("description: demonstration testbench");
     $display("author     : Altera Corporation");
     $display("==================================================================================");
     $display("PURPOSE: Demonstrate basic functionality and provide hookup example.");
     $display("METHOD : Two Serial RapidIO core are connected through their RapidIO interfaces.  ");
     $display("         A few registers are written.");
     $display("         A few packets are exchanged.");
     $display("==================================================================================");
 end

 // clock generation
 initial 
 begin
    //Initializing with the number of checks we are going to perform here
    // The processing_element_features CAR value checking is turn on for all variants
    static int num_exp_chk_count = 11;
    static int init_done = 0;
    
    if (PASS_THROUGH == 1)
    begin
        if (PROMISCUOUS == 0)
        begin
            num_exp_chk_count = 7 + num_exp_chk_count;
        end
    end 
    
    if (MAINTENANCE_SLAVE == 1)
    begin
        num_exp_chk_count = 1 + num_exp_chk_count;
    end
    
    if (DOORBELL == 1)
    begin
        num_exp_chk_count = 10 + num_exp_chk_count;
    end
    
    if (PORT_WRITE_TX == 1)
    begin
        num_exp_chk_count = 55 + num_exp_chk_count;
    end
    
    if ((IO_SLAVE == 1) && (IO_MASTER == 1))
    begin
        if ((PROMISCUOUS == 0) && (PASS_THROUGH == 1))
        begin
            num_exp_chk_count = 6 + num_exp_chk_count;
        end
    end
    
    init_done = init(num_exp_chk_count);
    set_verbosity(verbosity_pkg::VERBOSITY_ERROR);
    
       
 end
 
  initial
  begin
   sys_clk = 1'b0;
   forever
   begin
       #SYS_CLK_HALF_CYCLE_PERIOD;
        sys_clk = !sys_clk;
   end
  end

initial
begin
   pll_ref_clk = 1'b0;
   forever
   begin
   #REF_CLK_HALF_CYCLE_PERIOD;
   pll_ref_clk = !pll_ref_clk;
   end
end
 
 
 // Reset Generation 
 initial 
 begin 
    rst_n = 1'b0;
    sister_rst_n = 1'b0;
    #200000;
    rst_n = 1'b1;
    sister_rst_n = 1'b1;
    $display ("%0t Out of reset ...", $time);
 end
 
 initial begin
 // wait for port initialization
   begin
     fork
        begin //process 1
           wait ( rio_inst.port_initialized == 1 );
           donecheck("DUT Port initialized");
        end
        begin // process 2
           wait ( sis_rio_inst.port_initialized == 1);
           donecheck("Sister Port initialized");
        end
     join
 
     #5000;
 // wait for link initialization
     fork
        begin // process 1
           wait ( rio_inst.link_initialized == 1 );
           donecheck("DUT link initialized");
        end
        begin //process 2
           wait ( sis_rio_inst.link_initialized == 1);
           donecheck("Sister link initialized");
        end
     join
   end
 //--------------------------------------------------------------------------------------
 // Testbench registers cnfiguration
 //--------------------------------------------------------------------------------------
      #300;
      if (PROMISCUOUS == 1)
      begin
         promiscuous = 1'b1;
      end
      else
      begin
         promiscuous = 1'b0;
      end

      // Transport type 
      if (TRANSPORT_LARGE == 1)
      begin
         transport_type = `LARGE;
         trns_typ       =  1'b1;
      end
      else
      begin
         transport_type = `SMALL;
         trns_typ       =  1'b0;
      end

      // source & Destination id generation
      if (transport_type == `LARGE)
      begin
         source_dev_id = 'hABAB;
         dest_dev_id   = 'hCDCD;
         src_base_dev_id_data = {8'b0,8'hff,source_dev_id};
         dst_base_dev_id_data = {8'b0,8'hff,dest_dev_id};
      end
      else
      begin
         source_dev_id = 'h00AB;
         dest_dev_id   = 'h00CD;
         src_base_dev_id_data = {source_dev_id,16'hffff};
         dst_base_dev_id_data = {dest_dev_id,16'hffff};
      end
    
      // Checking the processing_element_features CAR value
      sys_mnt_master_bfm.read_write_cmd(REQ_READ,`PROC_ELEMENT_FEATURE_CAR,'hF,1,0,00);
      sys_mnt_master_bfm.read_data(0,reg_rd_data,rd_resp);
      exp_reg_data = {26'b0,1'b1,trns_typ,1'b1,2'b0,1'b1};
      check("Validate Processing Element CAR value",exp_reg_data,reg_rd_data);
      donecheck("Processing_element_features CAR Read done");
   
      //Set up the Device ID values (Small Transport)
      //DUT : 'hAB Sister : 'hCD
      reg_wr_data = src_base_dev_id_data; //{source_dev_id, 16'b0};//source_id;//'hAB0000;
      sys_mnt_master_bfm.read_write_cmd(REQ_WRITE,`BASE_DEVICE_ID_CSR,'hF,1,0,reg_wr_data);
      sys_mnt_master_bfm.read_write_cmd(REQ_READ,`BASE_DEVICE_ID_CSR,'hF,1,0,reg_wr_data);
      sys_mnt_master_bfm.read_data(0,reg_rd_data,rd_resp);
      exp_src_base_dev_id_data = src_base_dev_id_data;
      check("Validate Base Device ID CSR value",src_base_dev_id_data,reg_rd_data);
      donecheck("Base Device ID CSR Read done");
      reg_wr_data = dst_base_dev_id_data; //{dest_dev_id, 16'b0}; //'hCD0000;
      sister_sys_mnt_master_bfm.read_write_cmd(REQ_WRITE,`BASE_DEVICE_ID_CSR,'hF,1,0,reg_wr_data);
      sister_sys_mnt_master_bfm.read_write_cmd(REQ_READ,`BASE_DEVICE_ID_CSR,'hF,1,0,reg_wr_data);
      sister_sys_mnt_master_bfm.read_data(0,reg_rd_data,rd_resp);
      exp_dst_base_dev_id_data = dst_base_dev_id_data;
      check("Validate Base Device ID CSR value",exp_dst_base_dev_id_data,reg_rd_data);
      donecheck("Sister Base Device ID CSR Read done");
   
      //Enable request packet generation on both sides
      reg_wr_data = 'h4000_0000;
      sys_mnt_master_bfm.read_write_cmd(REQ_WRITE,`GENERAL_CONTROL,'hF,1,0,reg_wr_data);
      sister_sys_mnt_master_bfm.read_write_cmd(REQ_WRITE,`GENERAL_CONTROL,'hF,1,0,reg_wr_data);
   
      //After Link Initialization read the Port Status and Control CSRs
      sys_mnt_master_bfm.read_write_cmd(REQ_READ,`PORT_STATUS,'hF,1,0,reg_wr_data);
      sys_mnt_master_bfm.read_data(0,reg_rd_data,rd_resp);
      check("Validate Port 0 Status CSR value",'hXXXXXXX2,reg_rd_data);
      donecheck("Port0 Status CSR Read done");
        
      //configuring DUT PORT 0 CONTROL CSR reg for promiscuous mode on 
      reg_wr_data = {reg_rd_data[31:8], promiscuous, reg_rd_data[6:0]};
      sys_mnt_master_bfm.read_write_cmd(REQ_WRITE,`PORT_STATUS,'hF,1,0,reg_wr_data);
      
      sister_sys_mnt_master_bfm.read_write_cmd(REQ_READ,`PORT_STATUS,'hF,1,0,reg_wr_data);
      sister_sys_mnt_master_bfm.read_data(0,reg_rd_data,rd_resp);
      check("Validate Port 0 Status CSR value",'hXXXXXXX2,reg_rd_data);
      donecheck("Sister Port0 Status CSR Read done");
      
      //configuring SISTER DUT PORT 0 CONTROL CSR reg for promiscuous mode on or off
      reg_wr_data = {reg_rd_data[31:8], promiscuous, reg_rd_data[6:0]};
      sister_sys_mnt_master_bfm.read_write_cmd(REQ_WRITE,`PORT_STATUS,'hF,1,0,reg_wr_data);     
           
      if (SUPPORT_4X == 1'b1)
          init_port_width = 3'b010;
      else if (SUPPORT_2X == 1'b1)
          init_port_width = 3'b011;
      else  
          init_port_width = 3'b000;

      exp_reg_data = {SUPPORT_2X,SUPPORT_4X,init_port_width,3'b000,1'b0,1'b0,1'b0,1'b0,1'b1,1'b1,1'b1,1'b1,2'b00,2'b00,4'b0,1'b1,6'b0,1'b1};
      sys_mnt_master_bfm.read_write_cmd(REQ_READ,`PORT_CONTROL,'hF,1,0,reg_wr_data);
      sys_mnt_master_bfm.read_data(0,reg_rd_data,rd_resp);
      check("Validate Port 0 Control CSR value",exp_reg_data,reg_rd_data);
      donecheck("Port0 Control CSR Read done");
      
      exp_reg_data = {SUPPORT_2X,SUPPORT_4X,init_port_width,3'b000,1'b0,1'b0,1'b0,1'b0,1'b1,1'b1,1'b1,1'b1,2'b00,2'b00,4'b0,1'b1,6'b0,1'b1};
      sister_sys_mnt_master_bfm.read_write_cmd(REQ_READ,`PORT_CONTROL,'hF,1,0,reg_wr_data);
      sister_sys_mnt_master_bfm.read_data(0,reg_rd_data,rd_resp);
      check("Validate Port 0 Control CSR value",exp_reg_data,reg_rd_data);
      donecheck("Sister Port0 Control CSR Read done");
   
      //Enable Input and Output ports
      reg_wr_data = reg_rd_data | 'h0060_0000;
      sys_mnt_master_bfm.read_write_cmd(REQ_WRITE,`PORT_CONTROL,'hF,1,0,reg_wr_data);
      sister_sys_mnt_master_bfm.read_write_cmd(REQ_WRITE,`PORT_CONTROL,'hF,1,0,reg_wr_data);
      $display("%t %m DUT & Sister Port0 Input and Output sides Enabled",$time);
      //temp reg to set timeout value of dut 
      reg_wr_data = 32'h00ff_ffff;
      sys_mnt_master_bfm.read_write_cmd(REQ_WRITE,`PORT_0_TIMEOUT_CSR,'hF,1,0,reg_wr_data);
   

  // Destination id generation
    if (transport_type == `LARGE)
    begin
       dest_id   = 'hCDCD;
    end // end if transport_type = LARGE
    else
    begin
       dest_id   = 'h00CD;
    end //transport_type = SMALL
//----------------------------------------------------------------------------     
// Maintenance Transaction 
//----------------------------------------------------------------------------
if (MAINTENANCE_SLAVE == 1'b1)
begin
    mnt_test_rw_trans (REQ_WRITE, dest_id);
    info("Testing maintenance Transaction");
    #100;
    mnt_test_rw_trans (REQ_READ, dest_id);
  
end

//----------------------------------------------------------
//doorbell transaction
//----------------------------------------------------------
if (DOORBELL == 1'b1)
begin
   for (int i =1; i <= 5; i = i + 1)
   begin
      doorbell_test_trans (dest_id, transport_type);
   end
end
//----------------------------------------------------------
// port write transaction
//----------------------------------------------------------
if (PORT_WRITE_TX == 1'b1)
begin
   for (int i =1; i <= 5; i = i + 1)
   begin
      port_wr_test_trans( 32,
                          dest_id);
   end
end

if ((IO_SLAVE == 1) && (IO_MASTER == 1))
 //Exercising the IO SLAVE
begin
   #300;
   fork
     begin //p1
        //Send some NWRITE and NWRITE_R
        for (int i=1; i<= 8; i++) 
        begin
           if (i%2)
              ttype = 4;
           else
            ttype = 5;
           
           send_packet_avalon_mm (transport_type,
                                  4'b0101, 
                                  ttype,
                                  2**(i),
                                  dest_id);
        end // end for
     end // end p1
     info("All Packets sent on Avalon mm slave");
     begin //p2
        for (int i=1; i<= 8; i++) 
        begin
           if (i%2)
              ttype = 4;
           else
            ttype = 5;
            

              recieve_packet_avalon_mm (transport_type,
                                        4'b0101, 
                                        ttype,
                                        2**(i),
                                        dest_id );
        end
     end //end p2
     info("All Packets received on Sister IO Master");
   join
   #1000;
   info("Avalon MM test complete");
end
   
if ((IO_SLAVE == 1) && (IO_MASTER == 1))
 
//sending SWRITE Transaction
  begin
     #300;
     fork
       begin //p1
          for (int i=1; i<= 8; i++) 
          begin 
             send_packet_avalon_mm (transport_type,
                                    4'b1000, 
                                    4'b0000,
                                    2**(i),
                                    dest_id);
          end // end for
        end // end p1
        info("All Packets sent on Avalon mm slave");
        begin //p2
        for (int i=1; i<= 8; i++) 
          begin
             recieve_packet_avalon_mm (transport_type,
                                       4'b1000, 
                                       4'b0000,
                                       2**(i),
                                       dest_id);
          end // end for
        end //end p1
         info("All SWRITE Packets received on Sister IO Master");
       join
    end
    #1000;
    info("Avalon MM test complete");
   

if ((IO_SLAVE == 1) && (IO_MASTER == 1))
//sending NREAD Transaction
  begin
     #300;
     fork
       begin //p1
          for (int i=1; i< 2; i++) 
          begin
             if (i%2) 
               burstcnt = 5'b00100;
             else
               burstcnt = 5'b00101;
             send_read_trans(transport_type,
                             2'b00,
                             16'hffff,
                             burstcnt,
                             dest_id
                                     );

          end // end for
        end // end p1
        info("All NREAD Packets sent on Avalon mm slave");
        begin //p2
        for (int i=1; i< 2; i++) 
          begin
             send_read_response (transport_type,
                                 2'b00);
          end // end for
        end //end p1
        info("All NREAD response send by sister IO Master");
       join
       #1000;
       info("Avalon MM test complete");
  end
    

//-----------------------------------------------------------
//sending some NWRITE Transaction With wrong Destination id
//-----------------------------------------------------------
if ((IO_SLAVE == 1) && (IO_MASTER == 1))
begin

   if (TRANSPORT_LARGE)
      dest_id_t = 'h5555;
    else
       dest_id_t = 'h0055;
       
      if (DIFF_32_IO_SLAVE_ADDRESS_WIDTH > 0) begin
            io_slave_width_mask = {{DIFF_32_IO_SLAVE_ADDRESS_WIDTH{1'b0}},{(29 - DIFF_32_IO_SLAVE_ADDRESS_WIDTH){1'b1}}};
      end else begin
            io_slave_width_mask = {IO_SLAVE_ADDRESS_WIDTH{1'b1}};
      end
      
      
      
      if ((dest_id_t == 'h5555) | (dest_id_t == 'h0055))
        rio_dut_addr   = io_slave_width_mask[28:0] & tb_rio_address; 
      else
        rio_dut_addr = 29'b1_1110_1010_1101_1011_1110_1110_1111;

    if ((PROMISCUOUS == 1'b0) && (dest_id_t != dest_dev_id))
    begin
       pt_routed_pkt = 1'b1;
       $display("%m packet with wrong dest id routed to passthrough %b",pt_routed_pkt); 
    end
    else
    begin
       pt_routed_pkt = 1'b0;
    end      

  #100;
   fork
     begin  //p1      
        for (int i=1; i<= 6; i++) 
        begin
           $display("%m sending packet with dest id %h", dest_id);
           send_packet_avalon_mm (transport_type,
                                  4'b0101, 
                                  4'b0101,
                                  64,//2**(i),
                                  dest_id_t);
        end // end for
     end // end p1
     info("sending packet with wrong dest id through Avalon mm slave");
     begin //p2
       for (int j=1; j<= 6; j++) 
       begin
         if (pt_routed_pkt == 1'b1)
           begin 
              if (PASS_THROUGH == 1)
              begin
                 $display("sending data to passthrough"); 
                 fork
                    sister_pt_hdr_bfm.receive_header_avalon_st(transport_type,
                                                             4'b0101,
                                                             4'b0101,
                                                             64,//2**(j),
                                                             dest_id_t,
                                                             rio_dut_addr);
                    sister_pt_pld_bfm.receive_payload_avalon_st(transport_type,
                                                      4'b0101,
                                                      4'b0101,
                                                      64,//2**(j),
                                                      dest_id_t);
                                                      
                 join
                 $sformat(str,"Received Packet no %0d on Sister PT RX",j);  
                 donecheck(str);
              end
              else
              begin
                 $display("%m packet dropped");
              end 
           end // pt_pkt_routed = 1
           else // check packet data at sis dut iom interface
           begin
              recieve_packet_avalon_mm (transport_type,
                                        4'b0101, 
                                        4'b0101,
                                        64,//2**(j),
                                       dest_id_t);
           end
        end // end for
     end  // end p2   
     join
end // end block

//----------------------------------------------------------
//Multicast Event
//----------------------------------------------------------

begin

#500;
  fork
  begin // 1st process start
      send_multicast_event = 1'b0;
      multicast_evnt_cnt   = 10;
      repeat (multicast_evnt_cnt)
      begin
         repeat (100) @(posedge sys_clk);
         begin
            send_multicast_event = ~send_multicast_event;
            $display ("DUT sending multicast_event");
            wait (sent_multicast_event); 
           //input from dut, asserted when dut sends a multicast event
            multicast_evnt_tx_cnt = multicast_evnt_tx_cnt + 1;
            $display ("multicast control symbol sent = %d", multicast_evnt_tx_cnt);
            #100;
         end
      end
   end //end 1st process
   #100;
   begin //2 nd process starts
      //poll sis multicast_event_rx and increment counter
      repeat (10)
      begin
         wait (sis_multicast_event_rx);
         multicast_evnt_rx_cnt = multicast_evnt_rx_cnt + 1;
      end
   end // end 2nd process
  join
  check("All multicast event sent & recieved",multicast_evnt_tx_cnt,multicast_evnt_rx_cnt);
  end


//----------------------------------------------------------------------
// Passthrough Transaction
//----------------------------------------------------------------------
if (PROMISCUOUS == 1'b0)
begin  
   // Space out each transaction by 3 clock cycles by default
   static int num_clk_cycle_delay = 3;
   if (PASS_THROUGH == 1'b1) 
    //Exercising the Pass Through Interface
      begin
        #300;
        if (TRANSPORT_LARGE)
          pt_dest_id = 'h1212;
        else
          pt_dest_id = 'h0012;

        fork
          begin //p1
            //Send a few NWRITE and NWRITE_R packets of different payloads
            for (int i=1; i<= 7; i++) begin
              if (i%2) 
                ttype = 4;
              else
                ttype = 5;
              ext_tx_packet_size = tx_pt_src_bfm.calc_pkt_size(transport_type,2**(i));
              tx_pt_src_bfm.send_packet_avalon_st(transport_type,
                                                  4'b0101, 
                                                  ttype,
                                                  2**(i),
                                                  pt_dest_id,
                                                  num_clk_cycle_delay); 
                                                      
              #(num_clk_cycle_delay * (SYS_CLK_PERIOD/10)); 
            end
            info("All Packets sent on TX Pass Through port");
          end
          begin //p2
            for (int j=1; j<= 7; j++) begin
              if (j%2) 
                ttype = 4;
              else
                ttype = 5;
              fork
                sister_pt_hdr_bfm.receive_header_avalon_st(transport_type,
                                                           4'b0101,
                                                           ttype,
                                                           2**(j),
                                                           pt_dest_id,
                                                           rio_dut_addr);
                sister_pt_pld_bfm.receive_payload_avalon_st(transport_type,
                                                           4'b0101,
                                                           ttype,
                                                           2**(j),
                                                           pt_dest_id);
              join
              $sformat(str,"Received Packet no %0d on Sister PT RX",j);  
              donecheck(str);
            end
            info("All Packets received on Sister RX Pass Through port");
          end
        join
      end
   end
   #1000;
   info("All Tests Completed");
   exit;
 end

 // watchdog... 
`ifdef WATCHTIME
`else
`define WATCHTIME 600us
`endif
initial begin
//  $dumpvars(0,tb_rio);
  $display("WATCHTIME = %D",`WATCHTIME);
  # `WATCHTIME;
  error("Watchdog: watchdog timer expired");
  err_cnt++;
  exit;
end

   
endmodule
