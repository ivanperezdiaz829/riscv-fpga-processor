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


//---------------------------------------------------------------------
// Module: RapidIO II Megacore with external reset controller
// Feature:
// Instantiated RapidIO II Megacore and Transceiver Reset Controller.
//---------------------------------------------------------------------
import altera_xcvr_functions::*; // for get_custom_reconfig_width functions.
// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on

module altera_rapidio2_top_with_reset_ctrl
//##############################################################################
//######################### Parameter Declarations #############################
//##############################################################################
  #( //----------------------------------------------------
     //------------- TOP LEVEL PARAMETERS -----------------
     //----------------------------------------------------
     parameter DEVICE_FAMILY                   = "Stratix V",
     parameter ENABLE_TRANSPORT_LAYER          = 1'b1,
     parameter MAINTENANCE_SLAVE               = 1'b0,
     parameter MAINTENANCE_MASTER              = 1'b0,
     parameter IO_SLAVE                        = 1'b0,
     parameter IO_MASTER                       = 1'b0,
     parameter DOORBELL                        = 1'b0,
     parameter SYS_CLK_FREQ                    = 156.25,
     parameter ARB_PRIORITY_M1                 = 1'b1,
     parameter IO_SLAVE_TRANS_ID_START_INIT    = 8'h40,
     parameter IO_SLAVE_TRANS_ID_END_INIT      = 8'h7f,
     parameter ERROR_MANAGEMENT_EXTENSION      = 1'b1,
     //----------------------------------------------------
     //------------ PHYSICAL LAYER PARAMETERS -------------
     //----------------------------------------------------
     parameter SUPPORT_4X                      = 1'b1,     
     parameter SUPPORT_2X                      = 1'b0,     
     parameter SUPPORT_1X                      = 1'b1,
     parameter MAX_BAUD_RATE                   = 6250,
     parameter REF_CLK_PERIOD                  = 6400,
     parameter SYS_CLK_PERIOD                  = 6400,
     parameter MAX_LINK_REQ_ATTEMPTS           = 7,
     //----------------------------------------------------
     //----------- TRANSPORT LAYER PARAMETERS -------------
     //----------------------------------------------------
     parameter TRANSPORT_LARGE                 = 1'b0,
     parameter PASS_THROUGH                    = 1'b1,
     parameter PROMISCUOUS                     = 1'b0,
     parameter HEADER_BUF_DEPTH                = 19,
     parameter PAYLOAD_BUF_DEPTH               = 128,
     //----------------------------------------------------
     //------------ MAINTENANCE PARAMETERS ----------------
     //----------------------------------------------------
     parameter MAINTENANCE_ADDRESS_WIDTH       = 26,
     parameter PORT_WRITE_TX                   = 1'b1,
     parameter PORT_WRITE_RX                   = 1'b1,
     //----------------------------------------------------
     //--------------- DOORBELL PARAMETERS ----------------  
     //----------------------------------------------------
     parameter DOORBELL_TX_ENABLE              = 1'b1,     
     parameter DOORBELL_RX_ENABLE              = 1'b1,
     parameter IO_SLAVE_DOORBELL_WRITES_ORDER_PRESERVATION = 1'b1,
     //----------------------------------------------------
     //--------------- IO MASTER PARAMETERS ---------------
     //----------------------------------------------------
     parameter IO_MASTER_WINDOWS               = 5'd0,
     parameter IO_MASTER_OUTSTANDING_READS     = 8,
     parameter IO_MASTER_WRITE                 = 1'b1,
     parameter IO_MASTER_READ                  = 1'b1,
     //----------------------------------------------------
     //---------------- IO SLAVE PARAMETERS ---------------
     //----------------------------------------------------
     parameter IO_SLAVE_WINDOWS                = 5'd1,
     parameter IO_SLAVE_OUTSTANDING_NREADS     = 8,
     parameter IO_SLAVE_OUTSTANDING_NWRITE_RS  = 8,
     parameter IO_SLAVE_WRITE                  = 1'b1,
     parameter IO_SLAVE_READ                   = 1'b1,
     parameter IO_SLAVE_READ_WRITE_ORDER       = 1'b1,
     parameter IO_MASTER_ADDRESS_WIDTH         = 32,
     parameter IO_SLAVE_ADDRESS_WIDTH          = 32,
     //----------------------------------------------------
     //---------------- PHY IP PARAMETERS ---------------
     //----------------------------------------------------	  
     parameter MAX_BAUD_RATE_WITH_UNIT         = "6250 Mbps",
     parameter REF_CLK_FREQ_WITH_UNIT          = "156.25 MHz",
     //---------------------------------------------------------
     // THESE PARAMETERS ARE NOT AVAILABLE FOR USER TO CONFIGURE
     //---------------------------------------------------------
     parameter LSIZE                           = ( SUPPORT_4X ) ? 4 : (( SUPPORT_2X )? 2 : 1 ),
     parameter CSIZE                           = 4*LSIZE,
     parameter number_of_reconfig_interfaces   = ( SUPPORT_4X ) ? 5 : (( SUPPORT_2X )? 3 : 2 )
   )
//##############################################################################
//#################### INPUT & OUTPUT PORTS Declarations #######################
//##############################################################################
   (
   //----------------------------
   // Control Signal Declarations
   //----------------------------
   input  logic        sys_clk,
   input  logic        rst_n,
 

   //----------------------------
   //------- CAR Inputs ---------
   //----------------------------
   
   input  logic [15:0] car_device_id,
   input  logic [15:0] car_device_vendor_id,
   input  logic [31:0] car_device_revision_id,
   input  logic [15:0] car_assey_id,
   input  logic [15:0] car_assey_vendor_id,
   input  logic [15:0] car_revision_id,
   input  logic        car_bridge,
   input  logic        car_memory, 
   input  logic        car_processor,
   input  logic        car_switch,
   input  logic [7:0]  car_num_of_ports,
   input  logic [7:0]  car_port_num,
   input  logic        car_extended_route_table,
   input  logic        car_standard_route_table,
   input  logic        car_flow_arbitration,
   input  logic        car_flow_control,
   input  logic [15:0] car_max_pdu_size,
   input  logic [15:0] car_segmentation_contexts,
   input  logic [15:0] car_max_destid,
   input  logic [31:0] car_source_operations,
   input  logic [31:0] car_destination_operations,
 
   //----------------------------
   //------- CSR Inputs ---------
   //----------------------------
   
   input  logic [3:0]  csr_tm_types_reset_value, 
   input  logic [3:0]  csr_tm_mode_reset_value,
   input  logic [7:0]  csr_mtu_reset_value,
   input  logic        csr_external_tm_mode_wr,
   input  logic        csr_external_mtu_wr,
   input  logic [3:0]  csr_external_tm_mode_in,
   input  logic [7:0]  csr_external_mtu_in,

   //----------------------------
   //-- Error Management Inputs -
   //----------------------------
   
   input  logic        message_error_response_set,
   input  logic        gsm_error_response_set,
   input  logic        message_format_error_response_set,
   input  logic        external_illegal_transaction_decode_set,
   input  logic        external_message_request_timeout_set,
   input  logic        external_slave_packet_response_timeout_set,
   input  logic        external_unsolicited_response_set,
   input  logic        external_unsupported_transaction_set,
   input  logic        external_illegal_transaction_target_error_set,
   input  logic        external_missing_data_streaming_context_set,
   input  logic        external_open_existing_data_streaming_context_set,
   input  logic        external_long_data_streaming_segment_set,
   input  logic        external_short_data_streaming_segment_set,
   input  logic        external_data_streaming_pdu_length_error_set,
   input  logic        external_capture_destinationID_wr,
   input  logic [15:0] external_capture_destinationID_in,
   input  logic        external_capture_sourceID_wr,
   input  logic [15:0] external_capture_sourceID_in,
   input  logic        external_capture_ftype_wr,
   input  logic [3:0]  external_capture_ftype_in, 
   input  logic        external_capture_ttype_wr,
   input  logic [3:0]  external_capture_ttype_in,
   input  logic        external_letter_wr,
   input  logic [1:0]  external_letter_in,
   input  logic        external_mbox_wr,
   input  logic [1:0]  external_mbox_in,
   input  logic        external_msgseg_wr,
   input  logic [3:0]  external_msgseg_in,
   input  logic        external_xmbox_wr,
   input  logic [3:0]  external_xmbox_in,

   //--------------------------------------
   // CAR, CSR and Error Management Outputs
   //--------------------------------------
   
   output logic [7:0]  base_device_id,
   output logic [15:0] large_base_device_id,
   output logic [3:0]  tm_types,
   output logic [3:0]  tm_mode,
   output logic [7:0]  mtu,
   output logic        port_degraded,
   output logic        port_failed,
   output logic        logical_transport_error,
   output logic [15:0] time_to_live,
 
   //------------------------------------------------------------
   // Physical Layer Register (Lp-Serial & Lp-Serial Lane) Inputs
   //------------------------------------------------------------
   input  logic        host_reset_value,  
   input  logic        master_enable_reset_value,
   input  logic        discovered_reset_value,
   input  logic        flow_control_participant_reset_value,
   input  logic        enumeration_boundary_reset_value,
   input  logic        flow_arbitration_participant_reset_value,
   input  logic        disable_destination_id_checking_reset_value,
   input  logic        transmitter_type_reset_value,
   input  logic [1:0]  receiver_type_reset_value,

   //--------------------------------------
   // Extended Features Block Inputs
   //--------------------------------------
   input  logic [15:0] ef_ptr_reset_value,

  //------------------------------
  // SRIO User visible Interfaces
  //------------------------------
  //----------------------------------------------------------
  // Maintenance Module User visible Avalon-MM Slave Interface
  //----------------------------------------------------------
   input  logic [25:2]  mnt_s_address,
   input  logic         mnt_s_write,                          
   input  logic [31:0]  mnt_s_writedata,
   input  logic         mnt_s_read,
   output logic         mnt_s_waitrequest,                   
   output logic         mnt_s_readdatavalid,
   output logic [31:0]  mnt_s_readdata,                   
   output logic         mnt_s_readerror,                    

  //-----------------------------------------------------------------------
  // IO Master User visible Avalon-MM Slave Interface Read-Write Interface
  // for 128 bit module
  //-----------------------------------------------------------------------
   input  logic         iom_rd_wr_readdatavalid,
   input  logic         iom_rd_wr_readresponse,
   input  logic [127:0] iom_rd_wr_readdata,
   input  logic         iom_rd_wr_waitrequest,
   output logic         iom_rd_wr_read,      
   output logic         iom_rd_wr_write,     
   output logic [127:0] iom_rd_wr_writedata,                   
   output logic [4:0]   iom_rd_wr_burstcount,
   output logic [15:0]  iom_rd_wr_byteenable,
   output logic [IO_MASTER_ADDRESS_WIDTH -1:0]  iom_rd_wr_address,                    

  //----------------------------------------------------------------------
  // IO Slave User visible Avalon-MM Slave Interface Read-Write Interface
  // for 128 bit module
  //----------------------------------------------------------------------
   input  logic [IO_SLAVE_ADDRESS_WIDTH -1:4] ios_rd_wr_address,                
   input  logic         ios_rd_wr_write,                  
   input  logic         ios_rd_wr_read,          
   input  logic [127:0] ios_rd_wr_writedata,              
   input  logic [4:0]   ios_rd_wr_burstcount,             
   input  logic [15:0]  ios_rd_wr_byteenable,             
   output logic         ios_rd_wr_waitrequest,  
   output logic [127:0] ios_rd_wr_readdata,                
   output logic         ios_rd_wr_readresponse,               
   output logic         ios_rd_wr_readdatavalid,
  
  //-----------------------------------------------------------------
  // IO Slave User visible Avalon-MM Slave Interface Write Interface
  // for 128 bit module
  //-----------------------------------------------------------------
   input  logic [IO_SLAVE_ADDRESS_WIDTH -1:4]  ios_wr_address,                
   input  logic         ios_wr_write,                  
   input  logic [127:0] ios_wr_writedata,              
   input  logic [15:0]  ios_wr_byteenable,             
   input  logic [4:0]   ios_wr_burstcount,             
   output logic         ios_wr_waitrequest,
  
  //----------------------------------------------------------------
  // IO Slave User visible Avalon-MM Slave Interface Read Interface
  // for 128 bit module
  //----------------------------------------------------------------
   input  logic [IO_SLAVE_ADDRESS_WIDTH -1:4]  ios_rd_address,               
   input  logic         ios_rd_read,          
   input  logic [4:0]   ios_rd_burstcount,             
   input  logic [15:0]  ios_rd_byteenable,             
   output logic         ios_rd_waitrequest,            
   output logic [127:0] ios_rd_readdata,                  
   output logic         ios_rd_readdatavalid,
   output logic         ios_rd_readresponse,               

  //-------------------------------------------------
  // Doorbell User visible Avalon-MM Slave Interface
  //-------------------------------------------------
   input  logic         drbell_s_read,
   input  logic         drbell_s_write,
   input  logic [5:2]   drbell_s_address,
   input  logic [31:0]  drbell_s_writedata,
   output logic         drbell_s_waitrequest,
   output logic [31:0]  drbell_s_readdata,

  //-------------------------------------------------
  // Pass-through Avalon Payload and Header interface
  //-------------------------------------------------
   input  logic         gen_rx_pd_ready, 
   output logic [127:0] gen_rx_pd_data,
   output logic         gen_rx_pd_valid,
   output logic         gen_rx_pd_startofpacket,
   output logic         gen_rx_pd_endofpacket,
   output logic [3:0]   gen_rx_pd_empty,
                             
   input  logic         gen_rx_hd_ready, 
   output logic [114:0] gen_rx_hd_data,
   output logic         gen_rx_hd_valid,

   input  logic  [8:0]  ext_tx_packet_size, 
   output logic         transport_rx_packet_dropped,        
 
  //--------------------------------------------------
  // Transmit Side of Avalon-ST Pass-Through Interface
  //--------------------------------------------------
   input  logic [127:0] gen_tx_data,    
   input  logic         gen_tx_valid,
   input  logic         gen_tx_startofpacket,
   input  logic         gen_tx_endofpacket,
   input  logic [3:0]   gen_tx_empty,
   output logic         gen_tx_ready,
  
  //------------------------------------------------------
  // Maintenance Bridge External Avalon-MM Slave Interface
  //------------------------------------------------------
   input  logic [23:2]  ext_mnt_address,//location of 'configuration space' register is hardcoded to lowest 24-bit bute address space, tie the MSBits to low.
   input  logic         ext_mnt_write,
   input  logic         ext_mnt_read,
   input  logic [31:0]  ext_mnt_writedata, 
   output logic         ext_mnt_waitrequest, 
   output logic [31:0]  ext_mnt_readdata,
   output logic         ext_mnt_readdatavalid,
   output logic         ext_mnt_readresponse,
   output logic         ext_mnt_writeresponse,

  //---------------------------------------------------------------------
  // User Logic Avalon-MM Master interface Maintenance Register Interface 
  //---------------------------------------------------------------------
   input  logic         usr_mnt_waitrequest, 
   input  logic [31:0]  usr_mnt_readdata,
   input  logic         usr_mnt_readdatavalid,
   output logic [31:0]  usr_mnt_address, 
   output logic         usr_mnt_write, 
   output logic         usr_mnt_read,
   output logic [31:0]  usr_mnt_writedata,
   
  //------------------------
  // PHY input and output
  //------------------------
   input  logic             send_multicast_event,
   input  logic             send_link_request_reset_device, 
   output logic             sent_link_request_reset_device,
   output logic             multicast_event_rx,
   output logic             link_req_reset_device_received, 
   output logic             sent_multicast_event,
   output logic             port_initialized,                     
   output logic             link_initialized,    
   output logic             port_ok,
   output logic             port_error,
   output logic             packet_transmitted,                    
   output logic             packet_cancelled,
   output logic             packet_accepted_cs_sent,                    
   output logic             packet_retry_cs_sent,                     
   output logic             packet_not_accepted_cs_sent,                   
   output logic             packet_accepted_cs_received,
   output logic             packet_retry_cs_received,
   output logic             packet_not_accepted_cs_received,
   output logic             packet_crc_error,
   output logic             control_symbol_error,

  //------------------------
  // PHY IP input and output
  //------------------------
   input  logic             pll_ref_clk,

   input  logic [LSIZE-1:0] rx_serial_data,                                 
   output logic [LSIZE-1:0] tx_serial_data,               
   output logic [0:0]       pll_locked,  
   output logic [LSIZE-1:0] rx_is_lockedtoref,                    
   output logic [LSIZE-1:0] rx_is_lockedtodata,  
   output logic [LSIZE-1:0] rx_syncstatus,  
   output logic [LSIZE-1:0] rx_signaldetect,
   output logic             tx_clkout,  
   output logic             rx_clkout,    
                     
   output logic [LSIZE-1:0] tx_ready,// from Transceiver PHY reset controller                    
   output logic [LSIZE-1:0] rx_ready,// from Transceiver PHY reset controller                   
                  
  //------------------
  // Interrupt Signals
  //------------------
   output logic             std_reg_mnt_irq,
   output logic             mnt_mnt_s_irq,
   output logic             io_m_mnt_irq,
   output logic             io_s_mnt_irq,
   output logic             drbell_s_irq,

  //------------------
  // Master enable
  //------------------
   output logic             master_enable,
  //---------------------------
  // Reconfig Controller Ports
  //---------------------------
   input  logic  [altera_xcvr_functions::get_reconfig_to_width(DEVICE_FAMILY,number_of_reconfig_interfaces)-1:0] reconfig_to_xcvr,
   output logic  [altera_xcvr_functions::get_reconfig_from_width(DEVICE_FAMILY,number_of_reconfig_interfaces)-1:0] reconfig_from_xcvr
  );

//--------------------------
// Internal Wire Declaration
//--------------------------
logic             clk;
//--------------------------
// Clock & Reset Module
//--------------------------
logic             xcvr_mgmt_clk;
logic             mgmt_clk;
logic             ten_microsecond;
logic             tx_clk;                                  
logic             rx_clk;                                  
                                  
//--------------------------
// Physical layer
//--------------------------
logic             clk_rst_n;
logic [23:0]      timestamp;                                
logic             milisecond;                               
logic             sent_link_request_input_status;  
logic             sent_restart_from_retry;                
logic             link_response_reset_device_received;   
logic             status_sent; 
logic [3:0]       phy_tx_retry;                       
logic [CSIZE-1:0] rx_runningdisp;                   
logic [CSIZE-1:0] rx_patterndetect;                   
logic             four_lanes_aligned;   
logic             two_lanes_aligned;   
logic [LSIZE-1:0] rx_rmfifodatainserted;     
logic [LSIZE-1:0] rx_rmfifodatadeleted;                     
logic [LSIZE-1:0] rx_rmfifofull;                    
logic [LSIZE-1:0] rx_rmfifoempty;                    
logic [CSIZE-1:0] rx_dataerr;
logic             packet_dropped;
  
//--------------------------
// Transport layer
//--------------------------
logic             ttype;                       
logic  [8:0]      mnt_packet_size;                 
logic  [8:0]      io_m_packet_size;                 
logic  [8:0]      io_s_packet_size;                  
logic  [8:0]      drb_tx_packet_size;                    
logic  [8:0]      phy_packet_size; 
logic  [3:0]      phy_rx_retry;                         

//--------------------------
// Maintenance    
//--------------------------
logic             mnt_mnt_s_reset_n;                    
logic [23:0]      port_response_timeout;                
logic [6:0]       timer_prescaler;                      
logic             mnt_tx_packet_available;              
logic             mnt_s_error_response;          
logic             mnt_s_illegal_trans_decode;     
logic             mnt_s_illegal_trans_target;      
logic             mnt_s_error_timeout;              
logic             mnt_s_unsolicited_response;        
logic [7:0]       mnt_s_err_dest_id;                  
logic [7:0]       mnt_s_err_src_id;                     
logic [3:0]       mnt_s_err_ftype;                      
logic [3:0]       mnt_s_err_ttype; 
logic             mnt_tx_error;                 

//--------------------------
// Maintenance Adaptor
//--------------------------
logic [8:0]       mnt_tx_packet_size;                  

//--------------------------
// IO Master 128 Bit
//--------------------------
logic [8:0]       io_m_tx_packet_size; 

//--------------------------
// IO Master 64 Bit
//--------------------------
logic             io_m_err_unsupported_transaction;    
logic             io_m_err_illegal_transaction_decode;
logic [7:0]       io_m_err_source_id;
logic [7:0]       io_m_err_destination_id;
logic [3:0]       io_m_err_ttype;
logic [3:0]       io_m_err_ftype;
logic [1:0]       io_m_err_xamsbs;
logic [28:0]      io_m_err_address;
logic             io_m_tx_packet_available;
logic             io_m_tx_error;
logic             io_s_tx_error;

//--------------------------
// IO Master Adaptor
//--------------------------
logic [8:0]       iom_tx_packet_size; 

//--------------------------
// IO Slave 128  Bit
//--------------------------
logic [23:0]      free_running_counter;                 

//--------------------------
// IO Slave 64 Bit
//--------------------------
logic             io_s_tx_packet_available;
logic [15:0]      started_writes;
logic [15:0]      completed_writes;
logic             io_s_err_error_response;
logic             io_s_err_illegal_transaction_decode;
logic             io_s_err_timeout;
logic             io_s_err_unexpected_response;
logic [7:0]       io_s_err_source_id;
logic [7:0]       io_s_err_destination_id;
logic [3:0]       io_s_err_ttype;
logic [3:0]       io_s_err_ftype;
logic [1:0]       io_s_err_xamsbs;
logic [28:0]      io_s_err_address;

//--------------------------
// IO Slave Adaptor
//--------------------------
logic [8:0]       ios_tx_packet_size;

//--------------------------
// Doorbell
//--------------------------
//logic [6:0]       sysclk_timeout_prescaler;
logic             drbell_s_tx_packet_available;
logic             drbell_s_tx_error;
logic             drbell_s_err_unexpected_response;
logic             drbell_s_err_timeout;
logic [7:0]       drbell_s_err_source_id;
logic [7:0]       drbell_s_err_destination_id;
logic [3:0]       drbell_s_err_ftype;
logic [3:0]       drbell_s_err_ttype;

//-------------------------------------------------------------------------------
// Top level System Verilog Interface Instatntiation for PHY & Standard Registers
//-------------------------------------------------------------------------------
altera_rapidio2_car_csr_registers          car_csr_intf();
altera_rapidio2_error_management_registers err_mgmt_intf();
altera_rapidio2_lp_serial_registers        lp_serial();
altera_rapidio2_lp_serial_lane_n_registers lp_serial_lane_0();
altera_rapidio2_lp_serial_lane_n_registers lp_serial_lane_1();
altera_rapidio2_lp_serial_lane_n_registers lp_serial_lane_2();
altera_rapidio2_lp_serial_lane_n_registers lp_serial_lane_3();

//------------------------------------------
// SYSTEM VERILOG WIRE INTERFACE DECLARATION
//------------------------------------------

//---------------------------------------
// 128 bit IO Master read-write interface
//----------------------------------------
altera_rapidio2_avalon_mm_if io_master_av_mm();

//----------------------------------------------------
// 128 bit IO Slave read, write & read-write interface
//----------------------------------------------------
altera_rapidio2_avalon_mm_if avln_rd_wr();
altera_rapidio2_avalon_mm_if avln_wr();
altera_rapidio2_avalon_mm_if avln_rd();

//----------------------------------------------------
// User Logic Avalon-MM Maintenance Register Interface
//----------------------------------------------------
altera_rapidio2_avalon_mm_if ext_mm_intf();

//----------------------------------------------------
// Maintenance bridge Avalon-MM User visible Interface
//----------------------------------------------------
altera_rapidio2_avalon_mm_if ext_avl_intf();

//-----------------------------------------------------------------
// Pass-Through Avalon-ST Header,Payload & Transmit side Interfaces
//-----------------------------------------------------------------
altera_rapidio2_avalon_st_1beat_if ext_pd();
altera_rapidio2_avalon_st_1beat_if ext_hd();
altera_rapidio2_avalon_st_1beat_if ext_tx();

//-------------------------------------------------------
// Logical to Transport Layer Payload & Header Interfaces
//-------------------------------------------------------
altera_rapidio2_avalon_st_1beat_if iom_pd();
altera_rapidio2_avalon_st_1beat_if iom_hd();

altera_rapidio2_avalon_st_1beat_if ios_pd();
altera_rapidio2_avalon_st_1beat_if ios_hd();

altera_rapidio2_avalon_st_1beat_if mnt_pd();
altera_rapidio2_avalon_st_1beat_if mnt_hd();

altera_rapidio2_avalon_st_1beat_if drb_hd();

//--------------------------------------------------
// Physical layer Receive & Transmit side Interfaces
//--------------------------------------------------
altera_rapidio2_avalon_st_2beat_if phy_rx();
altera_rapidio2_avalon_st_1beat_if phy_tx();

//---------------------------------------
// Logical Layer Transmit side Interfaces
//---------------------------------------
altera_rapidio2_avalon_st_1beat_if mnt_tx();
altera_rapidio2_avalon_st_1beat_if iom_tx();
altera_rapidio2_avalon_st_1beat_if ios_tx();
altera_rapidio2_avalon_st_1beat_if drb_tx();

//-----------------------------------------------------------------
// Logical Layer to Adaptors Atlantic Interfaces for Legacy modules
//-----------------------------------------------------------------
altera_rapidio2_atlantic_if  mnt_atlantic_source();
altera_rapidio2_atlantic_if  mnt_atlantic_sink();
altera_rapidio2_atlantic_if  iom_atlantic_source();
altera_rapidio2_atlantic_if  iom_atlantic_sink();
altera_rapidio2_atlantic_if  ios_atlantic_source();
altera_rapidio2_atlantic_if  ios_atlantic_sink();
altera_rapidio2_atlantic_if  drb_atlantic_source();
altera_rapidio2_atlantic_if  drb_atlantic_sink();

//-----------------------------------------
// Maintenance Register Avalon-MM Interface
//-----------------------------------------
altera_rapidio2_avalon_mm_if mnt_reg_intf();
altera_rapidio2_avalon_mm_if car_mm_intf();
altera_rapidio2_avalon_mm_if phy_mm_intf();
altera_rapidio2_avalon_mm_if mnt_mm_intf();
altera_rapidio2_avalon_mm_if iom_mm_intf();
altera_rapidio2_avalon_mm_if ios_mm_intf();

//-----------------------------------------
// External reset controller
//-----------------------------------------
   logic pll_powerdown;//1-bit from reset controller

   logic [LSIZE-1:0] tx_analogreset;
   logic [LSIZE-1:0] tx_digitalreset;
   logic [LSIZE-1:0] rx_analogreset;
   logic [LSIZE-1:0] rx_digitalreset;

   logic [LSIZE-1:0] tx_cal_busy;
   logic [LSIZE-1:0] rx_cal_busy;

   logic tx_pll_refclk;
   logic rx_cdr_refclk;
   assign tx_pll_refclk = pll_ref_clk;
   assign rx_cdr_refclk = pll_ref_clk;
   //---------------------------------------------------------------------
   // Instantiation
   //---------------------------------------------------------------------
   altera_rapidio2_top #(
    .DEVICE_FAMILY (DEVICE_FAMILY)
   ,.ENABLE_TRANSPORT_LAYER (ENABLE_TRANSPORT_LAYER)
   ,.MAINTENANCE_SLAVE (MAINTENANCE_SLAVE)
   ,.MAINTENANCE_MASTER (MAINTENANCE_MASTER)
   ,.IO_SLAVE (IO_SLAVE)
   ,.IO_MASTER (IO_MASTER)
   ,.DOORBELL (DOORBELL)
   ,.SYS_CLK_FREQ (SYS_CLK_FREQ)
   ,.ARB_PRIORITY_M1 (ARB_PRIORITY_M1)
   ,.IO_SLAVE_TRANS_ID_START_INIT (IO_SLAVE_TRANS_ID_START_INIT)
   ,.IO_SLAVE_TRANS_ID_END_INIT (IO_SLAVE_TRANS_ID_END_INIT)
   ,.ERROR_MANAGEMENT_EXTENSION (ERROR_MANAGEMENT_EXTENSION)
   ,.SUPPORT_4X (SUPPORT_4X)
   ,.SUPPORT_2X (SUPPORT_2X)
   ,.SUPPORT_1X (SUPPORT_1X)
   ,.MAX_BAUD_RATE (MAX_BAUD_RATE)
   ,.REF_CLK_PERIOD (REF_CLK_PERIOD)
   ,.SYS_CLK_PERIOD (SYS_CLK_PERIOD)
   ,.MAX_LINK_REQ_ATTEMPTS (MAX_LINK_REQ_ATTEMPTS)
   ,.TRANSPORT_LARGE (TRANSPORT_LARGE)
   ,.PASS_THROUGH (PASS_THROUGH)
   ,.PROMISCUOUS (PROMISCUOUS)
   ,.HEADER_BUF_DEPTH (HEADER_BUF_DEPTH)
   ,.PAYLOAD_BUF_DEPTH (PAYLOAD_BUF_DEPTH)
   ,.MAINTENANCE_ADDRESS_WIDTH (MAINTENANCE_ADDRESS_WIDTH)
   ,.PORT_WRITE_TX (PORT_WRITE_TX)
   ,.PORT_WRITE_RX (PORT_WRITE_RX)
   ,.DOORBELL_TX_ENABLE (DOORBELL_TX_ENABLE)
   ,.DOORBELL_RX_ENABLE (DOORBELL_RX_ENABLE)
   ,.IO_SLAVE_DOORBELL_WRITES_ORDER_PRESERVATION (IO_SLAVE_DOORBELL_WRITES_ORDER_PRESERVATION)
   ,.IO_MASTER_WINDOWS (IO_MASTER_WINDOWS)
   ,.IO_MASTER_OUTSTANDING_READS (IO_MASTER_OUTSTANDING_READS)
   ,.IO_SLAVE_WINDOWS (IO_SLAVE_WINDOWS)
   ,.IO_SLAVE_OUTSTANDING_NREADS (IO_SLAVE_OUTSTANDING_NREADS)
   ,.IO_SLAVE_OUTSTANDING_NWRITE_RS (IO_SLAVE_OUTSTANDING_NWRITE_RS)
   ,.IO_SLAVE_READ_WRITE_ORDER (IO_SLAVE_READ_WRITE_ORDER)
   ,.IO_MASTER_ADDRESS_WIDTH (IO_MASTER_ADDRESS_WIDTH)
   ,.IO_SLAVE_ADDRESS_WIDTH (IO_SLAVE_ADDRESS_WIDTH)
   ,.MAX_BAUD_RATE_WITH_UNIT (MAX_BAUD_RATE_WITH_UNIT)
   ,.REF_CLK_FREQ_WITH_UNIT  (REF_CLK_FREQ_WITH_UNIT)
    )top(
   .*
   //input
   ,.pll_powerdown      (pll_powerdown)
   ,.tx_analogreset     (tx_analogreset)  
   ,.tx_digitalreset    (tx_digitalreset)
   ,.rx_analogreset     (rx_analogreset)  
   ,.rx_digitalreset    (rx_digitalreset)
   //output
   ,.pll_locked         (pll_locked)
   ,.tx_cal_busy        (tx_cal_busy)  
   ,.rx_cal_busy        (rx_cal_busy) 
   ,.rx_is_lockedtodata (rx_is_lockedtodata)
   ,.tx_ready           (tx_ready)  
   ,.rx_ready           (rx_ready)  
   );

   xcvr_rst_ctrl reset_controller(
   // inputs
    .clock              (sys_clk)
   ,.reset              (~rst_n)
   ,.pll_locked         (pll_locked)        //Width = 1. 
   ,.pll_select         (1'b0)               //Width = 1
   ,.tx_cal_busy        (tx_cal_busy)        //Width = LSIZE
   ,.rx_is_lockedtodata (rx_is_lockedtodata) //Width = LSIZE
   ,.rx_cal_busy        (rx_cal_busy)        //Width = LSIZE
   // outputs
   ,.pll_powerdown      (pll_powerdown)      //Width = 1.

   ,.tx_analogreset     (tx_analogreset)     //Width = LSIZE
   ,.tx_digitalreset    (tx_digitalreset)    //Width = LSIZE
   ,.tx_ready           (tx_ready)           //Width = LSIZE
   ,.rx_analogreset     (rx_analogreset)     //Width = LSIZE
   ,.rx_digitalreset    (rx_digitalreset)    //Width = LSIZE
   ,.rx_ready           (rx_ready)           //Width = LSIZE
   );

endmodule
