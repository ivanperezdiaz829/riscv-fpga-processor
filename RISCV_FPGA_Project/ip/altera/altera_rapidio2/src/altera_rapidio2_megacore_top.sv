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


// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on

module altera_rapidio2_megacore_top
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
   input  logic [25:0]  mnt_s_address,
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
   input  logic [IO_SLAVE_ADDRESS_WIDTH -1:0] ios_rd_wr_address,                
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
   input  logic [IO_SLAVE_ADDRESS_WIDTH -1:0]  ios_wr_address,                
   input  logic         ios_wr_write,                  
   input  logic [127:0] ios_wr_writedata,              
   input  logic [15:0]  ios_wr_byteenable,             
   input  logic [4:0]   ios_wr_burstcount,             
   output logic         ios_wr_waitrequest,
  
  //----------------------------------------------------------------
  // IO Slave User visible Avalon-MM Slave Interface Read Interface
  // for 128 bit module
  //----------------------------------------------------------------
   input  logic [IO_SLAVE_ADDRESS_WIDTH -1:0]  ios_rd_address,               
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
   input  logic [31:0]  ext_mnt_address,
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

  //----------------------------------
  // Reset Controller input and output
  //----------------------------------
   input logic              tx_ready,

  //------------------------
  // PHY IP input and output
  //------------------------
   input logic [3:0]       rx_datak0,
   input logic [31:0]      rx_parallel_data0,
   input logic [3:0]       rx_datak1,
   input logic [31:0]      rx_parallel_data1,
   input logic [3:0]       rx_datak2,
   input logic [31:0]      rx_parallel_data2,
   input logic [3:0]       rx_datak3,
   input logic [31:0]      rx_parallel_data3,

   input logic             four_lanes_aligned,   
   input logic             two_lanes_aligned,  
   input logic [CSIZE-1:0] rx_dataerr,
   input logic             tx_clkout, 
   input logic             rx_clkout,  
   input logic [LSIZE-1:0] rx_syncstatus,                             

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
            
   output logic [3:0]       force_electrical_idle,
   output logic [3:0]       tx_datak0,
   output logic [31:0]      tx_parallel_data0,
   output logic [3:0]       tx_datak1,
   output logic [31:0]      tx_parallel_data1,
   output logic [3:0]       tx_datak2,
   output logic [31:0]      tx_parallel_data2,
   output logic [3:0]       tx_datak3,
   output logic [31:0]      tx_parallel_data3,                       
                      
  //------------------
  // Interrupt Signals
  //------------------
   output logic             std_reg_mnt_irq,
   output logic             mnt_mnt_s_irq,
   output logic             io_m_mnt_irq,
   output logic             io_s_mnt_irq,
   output logic             drbell_s_irq,

  // -------------
  // Master enable
  // -------------
   output logic             master_enable,

   altera_rapidio2_lp_serial_registers        lp_serial, //as output for altera_rapidio2_soft_pcs

  //--------------------------
  // PHY IP soft logic
  //--------------------------
   output logic [2:0] init_port_width_frozen, //initialized_port_width in rx_std_clkout[0] domain
   output logic       tx_clk_rst_n,
   output logic       rx_clk_rst_n    
  );

//-----------------------------------
// Local Parameter for timer prescaler, based on 4.5 s timeout value and 24
// bit counter.
// ----------------------------------


localparam int TIMER_PRESCALER = 0.26822 * (1000000/SYS_CLK_PERIOD);

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
logic             sent_link_response;
logic [3:0]       phy_tx_retry;                       
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
wire              io_m_mnt_irq_s,io_s_mnt_irq_s;

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
//altera_rapidio2_lp_serial_registers        lp_serial();
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
altera_rapidio2_avalon_st_1beat_if ext_hd();//note: header and payload data has different width.
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
/*altera_rapidio2_atlantic_if  iom_atlantic_source();
altera_rapidio2_atlantic_if  iom_atlantic_sink();
altera_rapidio2_atlantic_if  ios_atlantic_source();
altera_rapidio2_atlantic_if  ios_atlantic_sink();*/  // removed as we are not using legacy IOS and IOM modules
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

//##############################################################################
// MODULES & SUB-MODULES OF PHYSICAL, TRANSPORT & LOGICAL LAYERS INSTANTIATIONS 
//##############################################################################

//##############################################################################
//#################### CLOCK AND RESET MODULE INSTANTIATIONS ###################
//##############################################################################
 
altera_rapidio2_crm
  #(
    .REF_CLK_PERIOD                          (SYS_CLK_PERIOD)
   )
crm
  (
   // Inputs
   .rst_n                                    (rst_n),
   .sys_clk                                  (sys_clk),
   .xcvr_rx_clk                              (rx_clkout),
   .xcvr_tx_clk                              (tx_clkout),
   // Outputs
   .clk                                      (clk),
   .clk_rst_n                                (clk_rst_n),
   .tx_clk_rst_n                             (tx_clk_rst_n),
   .rx_clk_rst_n                             (rx_clk_rst_n),
   .timestamp                                (timestamp),
   .milisecond                               (milisecond),
   .ten_microsecond                          (ten_microsecond),
   .rx_clk                                   (rx_clk),
   .tx_clk                                   (tx_clk)
   );

//##############################################################################
//######################## PHYSICAL LAYER INSTANTIATION ########################
//##############################################################################
   
altera_rapidio2_phy_top  
  #(
    .DEVICE_FAMILY                           (DEVICE_FAMILY),
    .SUPPORT_1X                              (SUPPORT_1X),
    .SUPPORT_2X                              (SUPPORT_2X),
    .SUPPORT_4X                              (SUPPORT_4X),
    .MAX_BAUD_RATE                           (MAX_BAUD_RATE),
    .REF_CLK_PERIOD                          (REF_CLK_PERIOD),
    .LSIZE                                   (LSIZE),
    .CSIZE                                   (CSIZE)
   )
physical
  (
   // CRM Inputs
   .rst_n                                    (clk_rst_n),
   .clk                                      (clk),
   .tx_clk                                   (tx_clk),
   .tx_clk_rst_n                             (tx_clk_rst_n),
   .milisecond                               (milisecond),
   .ten_microsecond                          (ten_microsecond),
   // Inputs
   .phy_rx_retry                             (phy_rx_retry),          
   .send_multicast_event                     (send_multicast_event), 
   .send_link_request_reset_device           (send_link_request_reset_device),
   .phy_tx_data_in                           (phy_tx.data), 
   .phy_tx_startofpacket                     (phy_tx.startofpacket),
   .phy_tx_endofpacket                       (phy_tx.endofpacket),
   .phy_tx_empty                             (phy_tx.empty),
   .phy_tx_pkt_size                          (phy_packet_size), 
   .phy_tx_data_valid                        (phy_tx.valid),
   // input from transceiver
   .tx_ready                                 (tx_ready),
   .rx_syncstatus                            (rx_syncstatus),
   .rx_dataerr                               (rx_dataerr),
   .rx_datak0(rx_datak0),
   .rx_parallel_data0(rx_parallel_data0),
   .rx_datak1(rx_datak1),
   .rx_parallel_data1(rx_parallel_data1),
   .rx_datak2(rx_datak2),
   .rx_parallel_data2(rx_parallel_data2),
   .rx_datak3(rx_datak3),
   .rx_parallel_data3(rx_parallel_data3),
   .four_lanes_aligned                       (four_lanes_aligned), //input from PHY IP
   .two_lanes_aligned                        (two_lanes_aligned), //input from PHY IP
   // Outputs
   .phy_rx_start_of_packet                   (phy_rx.startofpacket),
   .phy_rx_end_of_packet                     (phy_rx.endofpacket),
   .phy_rx_error                             (phy_rx.error),
   .phy_rx_empty                             (phy_rx.empty),
   .phy_rx_valid                             (phy_rx.valid),
   .phy_rx_data                              (phy_rx.data),
   .link_initialized                         (link_initialized),
   .port_initialized                         (port_initialized),
   .port_error_out                           (port_error),
   .port_ok_out                              (port_ok),
   .sent_multicast_event                     (sent_multicast_event),
   .multicast_event_rx                       (multicast_event_rx),
   .packet_cancelled                         (packet_cancelled),
   .packet_accepted_cs_received              (packet_accepted_cs_received),                   
   .packet_retry_cs_received                 (packet_retry_cs_received),                  
   .packet_not_accepted_cs_received          (packet_not_accepted_cs_received),
   .packet_crc_error                         (packet_crc_error),                  
   .control_symbol_error                     (control_symbol_error),
   .sent_link_request_reset_device           (sent_link_request_reset_device),
   .sent_link_request_input_status           (sent_link_request_input_status), //NOT CONNECTED
   .sent_restart_from_retry                  (sent_restart_from_retry), //NOT CONNECTED
   .link_req_reset_device_received           (link_req_reset_device_received),
   .sent_packet_accepted                     (packet_accepted_cs_sent),
   .sent_packet_retry                        (packet_retry_cs_sent),
   .sent_packet_not_accepted                 (packet_not_accepted_cs_sent),
   .sent_link_response                       (sent_link_response),
   .sent_start_of_packet                     (packet_transmitted),
   .status_sent                              (status_sent), //NOT CONNECTED
   .phy_tx_retry                             (phy_tx_retry),
   .packet_dropped                           (packet_dropped), //NOT CONNECTED
   // Output to transceiver
   .force_electrical_idle                    (force_electrical_idle),
   .tx_datak0(tx_datak0),
   .tx_parallel_data0(tx_parallel_data0),
   .tx_datak1(tx_datak1),
   .tx_parallel_data1(tx_parallel_data1),
   .tx_datak2(tx_datak2),
   .tx_parallel_data2(tx_parallel_data2),
   .tx_datak3(tx_datak3),
   .tx_parallel_data3(tx_parallel_data3),
   // Sytem Verilog Interface Connections
   .av_mm_s                                  (phy_mm_intf),
   .lp_serial                                (lp_serial),
   .lp_serial_lane_0                         (lp_serial_lane_0),
   .lp_serial_lane_1                         (lp_serial_lane_1),
   .lp_serial_lane_2                         (lp_serial_lane_2),
   .lp_serial_lane_3                         (lp_serial_lane_3),
   .error_management                         (err_mgmt_intf)
  );

assign phy_tx.ready         = 1'b1;

wire [7:0] device_id_small;
assign device_id_small = car_csr_intf.csr_base_device_id.base_device_id_reg;
wire [15:0] device_id_large;
assign device_id_large = car_csr_intf.csr_base_device_id.large_base_device_id_reg;
//##############################################################################
//######################## TRANSPORT LAYER INSTANTIATION #######################
//##############################################################################

//-----------------------------------------------------------------------------
// Generate block to Create the Tranport Layer Instance based on the parameter 
// ENABLE_TRANSPORT_LAYER
//-----------------------------------------------------------------------------
generate
  if(ENABLE_TRANSPORT_LAYER == 1'b1) 
    begin
      altera_rapidio2_transport_top 
        #(
          //.DEVICE_FAMILY                       (DEVICE_FAMILY),
          .PASS_THROUGH                        (PASS_THROUGH),             
          .PROMISCUOUS                         (PROMISCUOUS),          
          .HEADER_BUF_DEPTH                    (HEADER_BUF_DEPTH),
          .PAYLOAD_BUF_DEPTH                   (PAYLOAD_BUF_DEPTH),
          .IO_SLAVE                            (IO_SLAVE),            
          .IO_MASTER                           (IO_MASTER),            
          .DOORBELL                            (DOORBELL),            
          .MAINTENANCE_SLAVE                   (MAINTENANCE_SLAVE), 
          .MAINTENANCE_MASTER                  (MAINTENANCE_MASTER)
         )
      transport_top
        (
         // Inputs
         .clk                                  (clk),
         .rst_n                                (clk_rst_n),
         .phy_retry                            (phy_tx_retry),
         .mnt_packet_size                      ((MAINTENANCE_MASTER | MAINTENANCE_SLAVE)? mnt_tx_packet_size : 'd0),
         .io_m_packet_size                     ((IO_MASTER)?iom_tx_packet_size:'d0),
         .io_s_packet_size                     ((IO_SLAVE)? ios_tx_packet_size:'d0),
         .drb_packet_size                      ((DOORBELL)? drb_tx_packet_size:'d0),
         .gen_packet_size                      ((PASS_THROUGH)? ext_tx_packet_size: 'd0),
         // Outputs
         .phy_packet_size                      (phy_packet_size), 
         .transport_rx_packet_dropped          (transport_rx_packet_dropped),
         .phy_rx_retry                         (phy_rx_retry),
         // System Verilog Interface connection
         .mnt_tx                               (mnt_tx),
         .io_m_tx                              (iom_tx),
         .io_s_tx                              (ios_tx),
         .drb_tx                               (drb_tx),
         .gen_tx                               (ext_tx),
         .phy_tx                               (phy_tx),
         .phy_rx                               (phy_rx),
         .mnt_rx_pd                            (mnt_pd),
         .io_m_rx_pd                           (iom_pd),
         .io_s_rx_pd                           (ios_pd),
         .gen_rx_pd                            (ext_pd),  
         .mnt_rx_hd                            (mnt_hd),
         .io_m_rx_hd                           (iom_hd),
         .drb_rx_hd                            (drb_hd),
         .io_s_rx_hd                           (ios_hd),
         .gen_rx_hd                            (ext_hd),  
         .car_csr_if                           (car_csr_intf),
         .err_mgmt_if                          (err_mgmt_intf)
        );
    end
        //-----------------------------------------------------------
        // Converting Interface Signals to Ports
        //-----------------------------------------------------------
        assign gen_rx_pd_data                 = ext_pd.data;         
        assign ext_pd.ready                   = (PASS_THROUGH)? gen_rx_pd_ready : 1'd0;     
        assign gen_rx_pd_valid                = ext_pd.valid;        
        assign gen_rx_pd_startofpacket        = ext_pd.startofpacket;
        assign gen_rx_pd_endofpacket          = ext_pd.endofpacket;  
        assign gen_rx_pd_empty                = ext_pd.empty;        
      
        assign gen_rx_hd_data                 = ext_hd.data[114:0];         
        assign ext_hd.ready                   = (PASS_THROUGH)? gen_rx_hd_ready : 1'd0;     
        assign gen_rx_hd_valid                = ext_hd.valid;        
      
        assign ext_tx.data                    = gen_tx_data;
        assign gen_tx_ready                   = ext_tx.ready; 
        assign ext_tx.valid                   = (PASS_THROUGH)? gen_tx_valid: 1'd0;
        assign ext_tx.startofpacket           = (PASS_THROUGH)? gen_tx_startofpacket : 1'd0;
        assign ext_tx.endofpacket             = (PASS_THROUGH)? gen_tx_endofpacket : 1'd0;
        assign ext_tx.empty                   = (PASS_THROUGH)? gen_tx_empty : 1'd0;
        assign ext_tx.error[0]                = 1'b0;                   
        assign ext_tx.channel[0]              = 1'b0;
endgenerate
 
//##############################################################################
//######################## LOGICAL LAYER INSTANTIATION #########################
//##############################################################################

//---------------------------------------------------------------------------------
// Generate block to Create the Maintenance Module Instance based on the parameters 
// MAINTENANCE_MASTER OR MAINTENANCE_SLAVE
//---------------------------------------------------------------------------------
assign mnt_reg_intf.address[52:32] = 21'd0;
assign mnt_reg_intf.writedata[127:32] = 96'd0;  
// assign mnt_reg_intf.readdata[127:32] = 96'd0;  
generate
  if(MAINTENANCE_MASTER == 1'b1 || MAINTENANCE_SLAVE == 1'b1)
    begin
      //----------------------------------------
      // Condition to Create Maintenance Module 
      // for Small or Large Transport System
      //----------------------------------------
      if(TRANSPORT_LARGE == 1'b0)
        begin
          //----------------------------------------------
          // Maintenance Module for Small Transport System
          //----------------------------------------------
          defparam maintenance_dev8.maintenance_address_width=MAINTENANCE_ADDRESS_WIDTH;

          altera_rapidio2_dev8_maintenance
          maintenance_dev8
            (
             // Inputs
             .sysclk                               (clk),
             .reset_n                              (clk_rst_n),
             .mnt_tx_ready                         (mnt_atlantic_sink.ready),
             .mnt_rx_valid                         (mnt_atlantic_source.valid),
             .mnt_rx_start_packet                  (mnt_atlantic_source.start_packet),
             .mnt_rx_end_packet                    (mnt_atlantic_source.end_packet),
             .mnt_rx_empty                         (mnt_atlantic_source.empty),
             .mnt_rx_data                          (mnt_atlantic_source.data),
             .mnt_rx_size                          (mnt_atlantic_source.size),
             .mnt_s_clk                            (clk),
             .mnt_s_chipselect                     (1'b1),
             .mnt_s_address                        (mnt_s_address),
             .mnt_s_write                          (mnt_s_write),
             .mnt_s_writedata                      (mnt_s_writedata),
             .mnt_s_read                           (mnt_s_read),
             .mnt_m_clk                            (clk),
             .mnt_m_readdatavalid                  (mnt_reg_intf.readdatavalid),
             .mnt_m_readdata                       (mnt_reg_intf.readdata[31:0]),
             .mnt_m_waitrequest                    (mnt_reg_intf.waitrequest),
             .mnt_mnt_s_clk                        (clk),
             .mnt_mnt_s_reset_n                    (clk_rst_n),
             .mnt_mnt_s_chipselect                 (1'b1),
             .mnt_mnt_s_address                    (mnt_mm_intf.address),
             .mnt_mnt_s_read                       (mnt_mm_intf.read),
             .mnt_mnt_s_write                      (mnt_mm_intf.write),
             .mnt_mnt_s_writedata                  (mnt_mm_intf.writedata[31:0]),
             .port_response_timeout                (port_response_timeout),
             .timer_prescaler                      (TIMER_PRESCALER), //NOT CONNECTED
             .device_id                            (device_id_small),
             .master_enable                        (master_enable),  
            // Outputs
             .mnt_tx_packet_available              (mnt_tx_packet_available),
             .mnt_tx_valid                         (mnt_atlantic_sink.valid),
             .mnt_tx_start_packet                  (mnt_atlantic_sink.start_packet),
             .mnt_tx_end_packet                    (mnt_atlantic_sink.end_packet),
             .mnt_tx_error                         (mnt_tx_error), //NOT CONNECTED
             .mnt_tx_empty                         (mnt_atlantic_sink.empty),
             .mnt_tx_data                          (mnt_atlantic_sink.data),
             .mnt_tx_size                          (mnt_atlantic_sink.size),
             .mnt_rx_ready                         (mnt_atlantic_source.ready),
             .mnt_s_waitrequest                    (mnt_s_waitrequest),
             .mnt_s_readdatavalid                  (mnt_s_readdatavalid),
             .mnt_s_readdata                       (mnt_s_readdata),
             .mnt_s_readerror                      (mnt_s_readerror),
             .mnt_m_read                           (mnt_reg_intf.read),
             .mnt_m_address                        (mnt_reg_intf.address[31:0]),
             .mnt_m_write                          (mnt_reg_intf.write),
             .mnt_m_writedata                      (mnt_reg_intf.writedata[31:0]),
             .mnt_mnt_s_irq                        (mnt_mnt_s_irq),
             .mnt_mnt_s_waitrequest                (mnt_mm_intf.waitrequest),
             .mnt_mnt_s_readdata                   (mnt_mm_intf.readdata[31:0]),
             .mnt_s_error_response                 (mnt_s_error_response),
             .mnt_s_illegal_trans_decode           (mnt_s_illegal_trans_decode),
             .mnt_s_illegal_trans_target           (mnt_s_illegal_trans_target),
             .mnt_s_error_timeout                  (mnt_s_error_timeout),
             .mnt_s_unsolicited_response           (mnt_s_unsolicited_response),
             .mnt_s_err_dest_id                    (mnt_s_err_dest_id),
             .mnt_s_err_src_id                     (mnt_s_err_src_id),
             .mnt_s_err_ftype                      (mnt_s_err_ftype),
             .mnt_s_err_ttype                      (mnt_s_err_ttype)
            );
          end
        else
          begin
            //----------------------------------------------
            // Maintenance Module for Large Transport System
            //----------------------------------------------
            defparam maintenance_dev16.maintenance_address_width=MAINTENANCE_ADDRESS_WIDTH;

            altera_rapidio2_dev16_maintenance
            maintenance_dev16
            (
             // Inputs
             .sysclk                               (clk),
             .reset_n                              (clk_rst_n),
             .mnt_tx_ready                         (mnt_atlantic_sink.ready),
             .mnt_rx_valid                         (mnt_atlantic_source.valid),
             .mnt_rx_start_packet                  (mnt_atlantic_source.start_packet),
             .mnt_rx_end_packet                    (mnt_atlantic_source.end_packet),
             .mnt_rx_empty                         (mnt_atlantic_source.empty),
             .mnt_rx_data                          (mnt_atlantic_source.data),
             .mnt_rx_size                          (mnt_atlantic_source.size),
             .mnt_s_clk                            (clk),
             .mnt_s_chipselect                     (1'b1),
             .mnt_s_address                        (mnt_s_address),
             .mnt_s_write                          (mnt_s_write),
             .mnt_s_writedata                      (mnt_s_writedata),
             .mnt_s_read                           (mnt_s_read),
             .mnt_m_clk                            (clk),
             .mnt_m_readdatavalid                  (mnt_reg_intf.readdatavalid),
             .mnt_m_readdata                       (mnt_reg_intf.readdata[31:0]),
             .mnt_m_waitrequest                    (mnt_reg_intf.waitrequest),
             .mnt_mnt_s_clk                        (clk),
             .mnt_mnt_s_reset_n                    (clk_rst_n),
             .mnt_mnt_s_chipselect                 (1'b1),
             .mnt_mnt_s_address                    (mnt_mm_intf.address),
             .mnt_mnt_s_read                       (mnt_mm_intf.read),
             .mnt_mnt_s_write                      (mnt_mm_intf.write),
             .mnt_mnt_s_writedata                  (mnt_mm_intf.writedata[31:0]),
             .port_response_timeout                (port_response_timeout),
             .timer_prescaler                      (TIMER_PRESCALER), //NOT CONNECTED
             .device_id                            (device_id_large),
             .master_enable                        (master_enable),  
            // Outputs
             .mnt_tx_packet_available              (mnt_tx_packet_available),
             .mnt_tx_valid                         (mnt_atlantic_sink.valid),
             .mnt_tx_start_packet                  (mnt_atlantic_sink.start_packet),
             .mnt_tx_end_packet                    (mnt_atlantic_sink.end_packet),
             .mnt_tx_error                         (mnt_tx_error), //NOT CONNECTED
             .mnt_tx_empty                         (mnt_atlantic_sink.empty),
             .mnt_tx_data                          (mnt_atlantic_sink.data),
             .mnt_tx_size                          (mnt_atlantic_sink.size),
             .mnt_rx_ready                         (mnt_atlantic_source.ready),
             .mnt_s_waitrequest                    (mnt_s_waitrequest),
             .mnt_s_readdatavalid                  (mnt_s_readdatavalid),
             .mnt_s_readdata                       (mnt_s_readdata),
             .mnt_s_readerror                      (mnt_s_readerror),
             .mnt_m_read                           (mnt_reg_intf.read),
             .mnt_m_address                        (mnt_reg_intf.address[31:0]),
             .mnt_m_write                          (mnt_reg_intf.write),
             .mnt_m_writedata                      (mnt_reg_intf.writedata[31:0]),
             .mnt_mnt_s_irq                        (mnt_mnt_s_irq),
             .mnt_mnt_s_waitrequest                (mnt_mm_intf.waitrequest),
             .mnt_mnt_s_readdata                   (mnt_mm_intf.readdata[31:0]),
             .mnt_s_error_response                 (mnt_s_error_response),
             .mnt_s_illegal_trans_decode           (mnt_s_illegal_trans_decode),
             .mnt_s_illegal_trans_target           (mnt_s_illegal_trans_target),
             .mnt_s_error_timeout                  (mnt_s_error_timeout),
             .mnt_s_unsolicited_response           (mnt_s_unsolicited_response),
             .mnt_s_err_dest_id                    (mnt_s_err_dest_id),
             .mnt_s_err_src_id                     (mnt_s_err_src_id),
             .mnt_s_err_ftype                      (mnt_s_err_ftype),
             .mnt_s_err_ttype                      (mnt_s_err_ttype)
            );
          end
          
          //--------------------------------------------------------------------  
          // Maintenance Adaptor Instanace Created only with Maintenance Module 
          //--------------------------------------------------------------------
          altera_rapidio2_mnt_adp_top 
           #(
             .DEVICE_FAMILY                        (DEVICE_FAMILY),
             .TRANSPORT_LARGE                      (TRANSPORT_LARGE)
            )
          mnt_adaptor
            ( 
             // Inputs
             .clk                                  (clk),
             .rst_n                                (clk_rst_n),
             .transport_type                       ({1'b0,TRANSPORT_LARGE}),
             // Outputs                                            
             .mnt_tx_packet_size                   (mnt_tx_packet_size),
             .mnt_s_error_response                 (mnt_s_error_response),
             .mnt_s_illegal_trans_decode           (mnt_s_illegal_trans_decode),
             .mnt_s_illegal_trans_target           (mnt_s_illegal_trans_target),
             .mnt_s_error_timeout                  (mnt_s_error_timeout),
             .mnt_s_unsolicited_response           (mnt_s_unsolicited_response),
             .mnt_s_err_dest_id                    (mnt_s_err_dest_id),
             .mnt_s_err_src_id                     (mnt_s_err_src_id),
             .mnt_s_err_ftype                      (mnt_s_err_ftype),
             .mnt_s_err_ttype                      (mnt_s_err_ttype),
             // System Verilog Interface connection
             .atlantic_source                      (mnt_atlantic_source),
             .atlantic_sink                        (mnt_atlantic_sink),
             .avl_st_source                        (mnt_tx),
             .avl_st_sink_pl                       (mnt_pd),
             .avl_st_sink_hd                       (mnt_hd),
             .error_management_intf                (err_mgmt_intf)
            );
    end
   else
      begin
          assign mnt_mnt_s_irq             = 1'b0;
          assign mnt_mm_intf.waitrequest   = 1'b0;
          assign mnt_mm_intf.readdata      = 'b0;
          assign mnt_mm_intf.readdatavalid = 1'b1;
          assign mnt_mm_intf.readresponse  = 1'b0;
          assign mnt_reg_intf.read         = 1'b0;
          assign mnt_reg_intf.write        = 1'b0;
          assign mnt_tx.valid = 'd0;
          assign mnt_tx.startofpacket = 'd0;
          assign mnt_tx.endofpacket = 'd0;
          assign mnt_tx.data = 'd0;
          assign mnt_tx.empty = 'd0;
          assign mnt_hd.ready = 'd0;
          assign mnt_pd.ready = 'd0;
      end
endgenerate

//---------------------------------------------------------------------------------
// Generate block to Create the IO Master Module Instance based on the parameters 
// IO_MASTER 
//---------------------------------------------------------------------------------  
generate
  if(IO_MASTER == 1'b1) begin
      //-------------------------
      // 128 bit IO Master Module 
      //-------------------------
      altera_rapidio2_128_io_master
        #(  
          .DEVICE_FAMILY                              (DEVICE_FAMILY),
          .IO_MASTER_WRITE                     (IO_MASTER_WRITE),
          .IO_MASTER_READ                      (IO_MASTER_READ),
          .IO_MASTER_OUTSTANDING_READS         (IO_MASTER_OUTSTANDING_READS),
          .IO_MASTER_WINDOWS                   (IO_MASTER_WINDOWS)
         )
      io_master
        (
         // Inputs
         .clk                                  (clk),
         .rst_n                                (clk_rst_n),
         .transport_type                       ({1'b0,TRANSPORT_LARGE}),
         // Outputs
         .io_m_tx_packet_size                  (iom_tx_packet_size),
         .io_m_mnt_irq                         (io_m_mnt_irq_s), 
         // System Verilog Interface connection
         .io_master_rx_hd                      (iom_hd),
         .io_master_rx_pd                      (iom_pd),
         .io_master_rx_error                   (err_mgmt_intf), 
         .io_master_tx_pkt                     (iom_tx),
         .io_master_av_mm                      (io_master_av_mm),
         .io_master_mnt                        (iom_mm_intf)   
        );
      
      //------------------------------------------------------------------
      // Converting Interface signals to Ports
      //------------------------------------------------------------------
      assign iom_rd_wr_read                 = io_master_av_mm.read;    
      assign iom_rd_wr_write                = io_master_av_mm.write;
      assign iom_rd_wr_address              = io_master_av_mm.address;                     
      assign iom_rd_wr_writedata            = io_master_av_mm.writedata;                    
      assign iom_rd_wr_byteenable           = io_master_av_mm.byteenable;                  
      assign iom_rd_wr_burstcount           = io_master_av_mm.burstcount;
      assign io_master_av_mm.readdatavalid  = iom_rd_wr_readdatavalid;
      assign io_master_av_mm.readresponse   = iom_rd_wr_readresponse;
      assign io_master_av_mm.readdata       = iom_rd_wr_readdata;
      assign io_master_av_mm.waitrequest    = iom_rd_wr_waitrequest;
    end
    else begin
      assign iom_rd_wr_read                 = 1'b0;    
      assign iom_rd_wr_write                = 1'b0;
      assign iom_rd_wr_address              = 32'b0;                     
      assign iom_rd_wr_writedata            = 32'b0;                    
      assign iom_rd_wr_byteenable           = 16'b0;                  
      assign iom_rd_wr_burstcount           = 5'b0;
      assign iom_mm_intf.waitrequest        = 1'b0;
      assign iom_mm_intf.readdata           = 'b0;
      assign iom_mm_intf.readdatavalid      = 1'b1;
      assign iom_mm_intf.readresponse       = 1'b0;
      assign iom_tx.valid = 'd0;
      assign iom_tx.startofpacket = 'd0;
      assign iom_tx.endofpacket = 'd0;
      assign iom_tx.data = 'd0;
      assign iom_tx.empty = 'd0;
      assign iom_hd.ready = 'd0;
      assign iom_pd.ready = 'd0;
    end
endgenerate

//---------------------------------------------------------------------------------
// Generate block to Create the IO Slave Module Instance based on the parameters 
// IO_SLAVE 
//---------------------------------------------------------------------------------  
generate
  if(IO_SLAVE == 1'b1) begin
      //------------------------
      // 128 bit IO Slave Module
      //------------------------
      altera_rapidio2_128_io_slave
        #(
          .DEVICE_FAMILY                       (DEVICE_FAMILY),
          .IO_SLAVE_WINDOWS                    (IO_SLAVE_WINDOWS),
          .IO_SLAVE_OUTSTANDING_NREADS         (IO_SLAVE_OUTSTANDING_NREADS),
          .IO_SLAVE_OUTSTANDING_NWRITE_RS      (IO_SLAVE_OUTSTANDING_NWRITE_RS),
          .IO_SLAVE_WRITE                      (IO_SLAVE_WRITE),
          .IO_SLAVE_READ                       (IO_SLAVE_READ),
          .IO_SLAVE_READ_WRITE_ORDER           (IO_SLAVE_READ_WRITE_ORDER)
         )
      io_slave
        (
         // Inputs
         .clk                                  (clk),
         .rst_n                                (clk_rst_n),
         .device_id((TRANSPORT_LARGE)?device_id_large : {8'd0,device_id_small}),
         .port_response_timeout                (port_response_timeout),
         .free_running_counter                 (timestamp), 
         .transport_type                       ({1'b0,TRANSPORT_LARGE}),
         .master_enable                        (master_enable),
         // Outputs
         .io_s_mnt_irq                         (io_s_mnt_irq_s),
         .started_write                        (started_writes),
         .completed_cancelled_write            (completed_writes),
         .io_s_tx_packet_size                  (ios_tx_packet_size),
         // System Verilog Interface connection
         .config_reg                           (car_csr_intf),
         .rx_err                               (err_mgmt_intf), 
         .avln_rd_wr                           (avln_rd_wr), 
         .mnt_slv                              (ios_mm_intf),
         .avln_rd                              (avln_rd),  
         .avln_wr                              (avln_wr),  
         .avln_tx                              (ios_tx),
         .avln_rx_hd                           (ios_hd),
         .avln_rx_pd                           (ios_pd)
        );
      
      //---------------------------------------------------------
      // Converting Interface signals to Ports
      //---------------------------------------------------------
      assign avln_rd_wr.address            = ios_rd_wr_address;                
      assign avln_rd_wr.write              = ios_rd_wr_write;                  
      assign avln_rd_wr.read               = ios_rd_wr_read;          
      assign avln_rd_wr.writedata          = ios_rd_wr_writedata;              
      assign avln_rd_wr.burstcount         = ios_rd_wr_burstcount;             
      assign avln_rd_wr.byteenable         = ios_rd_wr_byteenable;             
      assign ios_rd_wr_waitrequest         = avln_rd_wr.waitrequest;
      assign ios_rd_wr_readdata            = avln_rd_wr.readdata;               
      assign ios_rd_wr_readresponse        = avln_rd_wr.readresponse;              
      assign ios_rd_wr_readdatavalid       = avln_rd_wr.readdatavalid;

      assign avln_wr.address               = ios_wr_address;                
      assign avln_wr.write                 = ios_wr_write;                  
      assign avln_wr.writedata             = ios_wr_writedata;              
      assign avln_wr.byteenable            = ios_wr_byteenable;             
      assign avln_wr.burstcount            = ios_wr_burstcount;             
      assign ios_wr_waitrequest            = avln_wr.waitrequest;            

      assign avln_rd.address               = ios_rd_address;               
      assign avln_rd.read                  = ios_rd_read;          
      assign avln_rd.burstcount            = ios_rd_burstcount;             
      assign avln_rd.byteenable            = ios_rd_byteenable;             
      assign ios_rd_waitrequest            = avln_rd.waitrequest;            
      assign ios_rd_readdata               = avln_rd.readdata;               
      assign ios_rd_readdatavalid          = avln_rd.readdatavalid;
      assign ios_rd_readresponse           = avln_rd.readresponse;              
    end
    else begin
      assign ios_rd_wr_waitrequest         = 1'b1;
      assign ios_rd_wr_readdata            = 32'b0;
      assign ios_rd_wr_readresponse        = 1'b0;
      assign ios_rd_wr_readdatavalid       = 1'b0;

      assign ios_wr_waitrequest            = 1'b1;

      assign ios_rd_waitrequest            = 1'b1;    
      assign ios_rd_readdata               = 32'b0;
      assign ios_rd_readdatavalid          = 1'b0;
      assign ios_rd_readresponse           = 1'b0; 
      assign ios_mm_intf.waitrequest        = 1'b0;
      assign ios_mm_intf.readdata           = 'b0;
      assign ios_mm_intf.readdatavalid      = 1'b1;
      assign ios_mm_intf.readresponse       = 1'b0;
      assign ios_tx.valid = 'd0;
      assign ios_tx.startofpacket = 'd0;
      assign ios_tx.endofpacket = 'd0;
      assign ios_tx.data = 'd0;
      assign ios_tx.empty = 'd0;
      assign ios_hd.ready = 'd0;
      assign ios_pd.ready = 'd0;
    end
endgenerate

//---------------------------------------------------------------------------------
// Generate block to Create the Doorbell Module Instance based on the parameter 
// DOORBELL 
//---------------------------------------------------------------------------------
// Doorbell
generate
  if(DOORBELL == 1'b1) begin
    //----------------------------------------
    // Condition to Create Doorbell Module 
    // for Small or Large Transport System
    //----------------------------------------
    if(TRANSPORT_LARGE == 1'b0) begin
      //----------------------------------------------
      // Doorbell Module for Small Transport System
      //----------------------------------------------
      altera_rapidio2_dev8_drbell
        #( 
         .DRBELL_TX_ENABLE                     (DOORBELL_TX_ENABLE),     
         .DRBELL_RX_ENABLE                     (DOORBELL_RX_ENABLE),
         .DRBELL_WRITE_ORDER                   (IO_SLAVE_DOORBELL_WRITES_ORDER_PRESERVATION)
         )
      doorbell_dev8
        (
         // Inputs
         .sysclk                               (clk),
         .reset_n                              (clk_rst_n),
         .drbell_s_chipselect                  (1'b1),
         .drbell_s_read                        (drbell_s_read),
         .drbell_s_write                       (drbell_s_write),
         .drbell_s_address                     (drbell_s_address),
         .drbell_s_writedata                   (drbell_s_writedata),
         .drbell_s_tx_ready                    (drb_atlantic_sink.ready),
         .drbell_s_rx_valid                    (drb_atlantic_source.valid),
         .drbell_s_rx_data                     (drb_atlantic_source.data),
         .drbell_s_rx_start_packet             (drb_atlantic_source.start_packet),
         .drbell_s_rx_end_packet               (drb_atlantic_source.end_packet),
         .drbell_s_rx_empty                    (drb_atlantic_source.empty),
         .master_enable                        (master_enable),
         .device_id                            (device_id_small),
         .started_writes                       ((IO_SLAVE)?started_writes[4:0]:5'd0),
         .completed_writes                     ((IO_SLAVE)?completed_writes[4:0]:5'd0),
         .sysclk_timeout_prescaler             (TIMER_PRESCALER),
         .port_response_timeout                (port_response_timeout),
          // Outputs
         .drbell_s_waitrequest                 (drbell_s_waitrequest),
         .drbell_s_readdata                    (drbell_s_readdata),
         .drbell_s_irq                         (drbell_s_irq),
         .drbell_s_tx_packet_available         (drbell_s_tx_packet_available), //NOT CONNECTED
         .drbell_s_tx_start_packet             (drb_atlantic_sink.start_packet),
         .drbell_s_tx_end_packet               (drb_atlantic_sink.end_packet),
         .drbell_s_tx_empty                    (drb_atlantic_sink.empty),
         .drbell_s_tx_data                     (drb_atlantic_sink.data),
         .drbell_s_tx_valid                    (drb_atlantic_sink.valid),
         .drbell_s_tx_error                    (drbell_s_tx_error), //NOT CONNECTED
         .drbell_s_rx_ready                    (drb_atlantic_source.ready),
         .drbell_s_err_unexpected_response     (drbell_s_err_unexpected_response),
         .drbell_s_err_timeout                 (drbell_s_err_timeout),
         .drbell_s_err_source_id               (drbell_s_err_source_id),
         .drbell_s_err_destination_id          (drbell_s_err_destination_id),
         .drbell_s_err_ftype                   (drbell_s_err_ftype),
         .drbell_s_err_ttype                   (drbell_s_err_ttype)
        );
      end
    else begin
      //----------------------------------------------
      // Doorbell Module for Large Transport System
      //----------------------------------------------
      altera_rapidio2_dev16_drbell
        #( 
         .DRBELL_TX_ENABLE                     (DOORBELL_TX_ENABLE),     
         .DRBELL_RX_ENABLE                     (DOORBELL_RX_ENABLE),
         .DRBELL_WRITE_ORDER                   (IO_SLAVE_DOORBELL_WRITES_ORDER_PRESERVATION)
         )
      doorbell_dev16
        (
         // Inputs
         .sysclk                               (clk),
         .reset_n                              (clk_rst_n),
         .drbell_s_chipselect                  (1'b1),
         .drbell_s_read                        (drbell_s_read),
         .drbell_s_write                       (drbell_s_write),
         .drbell_s_address                     (drbell_s_address),
         .drbell_s_writedata                   (drbell_s_writedata),
         .drbell_s_tx_ready                    (drb_atlantic_sink.ready),
         .drbell_s_rx_valid                    (drb_atlantic_source.valid),
         .drbell_s_rx_data                     (drb_atlantic_source.data),
         .drbell_s_rx_start_packet             (drb_atlantic_source.start_packet),
         .drbell_s_rx_end_packet               (drb_atlantic_source.end_packet),
         .drbell_s_rx_empty                    (drb_atlantic_source.empty),
         .master_enable                        (master_enable),
         .device_id                            (device_id_large),
         .started_writes                       ((IO_SLAVE)?started_writes[4:0]:5'd0),
         .completed_writes                     ((IO_SLAVE)?completed_writes[4:0]:5'd0),
         .sysclk_timeout_prescaler             (TIMER_PRESCALER),
         .port_response_timeout                (port_response_timeout),
          // Outputs
         .drbell_s_waitrequest                 (drbell_s_waitrequest),
         .drbell_s_readdata                    (drbell_s_readdata),
         .drbell_s_irq                         (drbell_s_irq),
         .drbell_s_tx_packet_available         (drbell_s_tx_packet_available), //NOT CONNECTED
         .drbell_s_tx_start_packet             (drb_atlantic_sink.start_packet),
         .drbell_s_tx_end_packet               (drb_atlantic_sink.end_packet),
         .drbell_s_tx_empty                    (drb_atlantic_sink.empty),
         .drbell_s_tx_data                     (drb_atlantic_sink.data),
         .drbell_s_tx_valid                    (drb_atlantic_sink.valid),
         .drbell_s_tx_error                    (drbell_s_tx_error), //NOT CONNECTED
         .drbell_s_rx_ready                    (drb_atlantic_source.ready),
         .drbell_s_err_unexpected_response     (drbell_s_err_unexpected_response),
         .drbell_s_err_timeout                 (drbell_s_err_timeout),
         .drbell_s_err_source_id               (drbell_s_err_source_id),
         .drbell_s_err_destination_id          (drbell_s_err_destination_id),
         .drbell_s_err_ftype                   (drbell_s_err_ftype),
         .drbell_s_err_ttype                   (drbell_s_err_ttype)
        );
    end
   
    //----------------------------------------------------------------------------------
    // Doorbell Adaptor Module Instance created only with Doorbell Module
    //----------------------------------------------------------------------------------
    assign drb_atlantic_sink.size = 6'd0;
    altera_rapidio2_drbell_adp_top #(
       .TRANSPORT_LARGE                      (TRANSPORT_LARGE)
      )
    drbell_adaptor
      (
       // Inputs
       .clk                                  (clk),
       .rst_n                                (clk_rst_n),
       // Outputs
       .drbell_tx_packet_size                (drb_tx_packet_size),
       .drbell_s_err_unexpected_response     (drbell_s_err_unexpected_response),
       .drbell_s_err_timeout                 (drbell_s_err_timeout),
       .drbell_s_err_source_id               (drbell_s_err_source_id),
       .drbell_s_err_destination_id          (drbell_s_err_destination_id),
       .drbell_s_err_ftype                   (drbell_s_err_ftype),
       .drbell_s_err_ttype                   (drbell_s_err_ttype),
       // System Verilog Interface Connection
       .atlantic_source                      (drb_atlantic_source),
       .atlantic_sink                        (drb_atlantic_sink),
       .avl_st_source                        (drb_tx),
       .avl_st_sink_hd                       (drb_hd),
       .error_management_intf                (err_mgmt_intf)
      );
  end
  else begin // If parameter DOORBELL == 1'b0
     assign drb_tx.valid = 1'd0;
     assign drb_tx.startofpacket = 1'd0;
     assign drb_tx.endofpacket = 1'd0;
     assign drb_tx.data = 128'd0;
     assign drb_tx.empty = 4'd0;
     assign drb_hd.ready = 1'd0;
   
  end 
endgenerate

//##############################################################################
//###################### MAINTENANCE BRIDGE INSTANTIATION ######################
//##############################################################################

altera_rapidio2_maintenance_bridge_top
 #(.ARB_PRIORITY_M1                      (ARB_PRIORITY_M1),
   .SUPPORT_4X                           (SUPPORT_4X)
  )
maintenance_bridge
  (
   // Inputs
   .clk                                  (clk),
   .rst_n                                (clk_rst_n),
   // System Verilog Interface Connection
   .ext_avl_intf                         (ext_avl_intf),
   .mnt_reg_intf                         (mnt_reg_intf),
   .car_csr_mm_intf                      (car_mm_intf),
   .lp_sr_mm_intf                        (phy_mm_intf),
   .mnt_mm_intf                          (mnt_mm_intf),
   .io_master_mm_intf                    (iom_mm_intf),
   .io_slave_mm_intf                     (ios_mm_intf),
   .external_mm_intf                     (ext_mm_intf)
  );

  //--------------------------------------------------------------
  // Converting Interface Signals to Ports
  //--------------------------------------------------------------
  assign ext_avl_intf.address        = ext_mnt_address;    
  assign ext_avl_intf.write          = ext_mnt_write;     
  assign ext_avl_intf.read           = ext_mnt_read;      
  assign ext_avl_intf.writedata[31:0]      = ext_mnt_writedata;
  assign ext_avl_intf.writedata[127:32] = 96'd0;
  assign ext_mnt_waitrequest         = ext_avl_intf.waitrequest; 
  assign ext_mnt_readdata            = ext_avl_intf.readdata[31:0]; 
  assign ext_mnt_readdatavalid       = ext_avl_intf.readdatavalid; 
  assign ext_mnt_readresponse        = ext_avl_intf.readresponse; 
  assign ext_mnt_writeresponse       = ext_avl_intf.writeresponse; 

  assign usr_mnt_address             = ext_mm_intf.address; 
  assign usr_mnt_write               = ext_mm_intf.write; 
  assign usr_mnt_read                = ext_mm_intf.read; 
  assign usr_mnt_writedata           = ext_mm_intf.writedata[31:0]; 
  assign ext_mm_intf.waitrequest     = usr_mnt_waitrequest;   
  assign ext_mm_intf.readdata        = usr_mnt_readdata;     
  assign ext_mm_intf.readdatavalid   = usr_mnt_readdatavalid; 

//##############################################################################
//#################### STANDARD REGISTER MODULE INSTANTIATION ##################
//##############################################################################

altera_rapidio2_std_reg_top 
  #(
    .TRANSPORT_LARGE                     (TRANSPORT_LARGE),
    .IO_SLAVE_READ                       ((IO_SLAVE_READ & IO_SLAVE)),
    .IO_SLAVE_WRITE                      ((IO_SLAVE_WRITE & IO_SLAVE)),
    .IO_MASTER_READ                      ((IO_MASTER_READ & IO_MASTER)),
    .IO_MASTER_WRITE                     ((IO_MASTER_WRITE & IO_MASTER)),
    .DRBELL_RX_ENABLE                    ((DOORBELL_TX_ENABLE & DOORBELL)),
    .DRBELL_TX_ENABLE                    ((DOORBELL_RX_ENABLE & DOORBELL)),
    .PORT_WRITE_TX                       (PORT_WRITE_TX),
    .PORT_WRITE_RX                       (PORT_WRITE_RX),
    .IO_SLAVE_TRANS_ID_START_INIT        (IO_SLAVE_TRANS_ID_START_INIT),
    .IO_SLAVE_TRANS_ID_END_INIT          (IO_SLAVE_TRANS_ID_END_INIT),
    .ERROR_MANAGEMENT_EXTENSION          (ERROR_MANAGEMENT_EXTENSION)
   ) 
std_reg
  (
   // Inputs
   .clk                                  (clk),
   .rst_n                                (clk_rst_n),
   .clk_ms                               (milisecond),
   //Outputs
   .std_reg_mnt_irq                      (std_reg_mnt_irq),
   // System Verilog Interface Connection
   .car_csr_intf                         (car_csr_intf),
   .err_mgmt_intf                        (err_mgmt_intf),
   .avalon_mm_intf                       (car_mm_intf) 
  );

//##############################################################################
//################### SYNCHRONIZER FOR initialized_port_width ##################
//##############################################################################

   altera_rapidio2_bus_synchronizer
   altera_rapidio2_bus_synchronizer (
   //inputs
    .sys_clk                                           (clk)
   ,.rx_clkout                                         (rx_clkout)
   ,.rst_n                                             (clk_rst_n)
   ,.rx_clk_rst_n                                      (rx_clk_rst_n)
   ,.lp_serial                                         (lp_serial)
   //outputs
   ,.init_port_width_frozen                            (init_port_width_frozen)
   );

//##############################################################################
//####################### INPUT CONNECTIONS TO CAR, CSR ########################
//##############################################################################

  assign car_csr_intf.car_device_identity.device_identity_reset_value                     =  car_device_id;
  assign car_csr_intf.car_device_identity.device_vendor_identity_reset_value              =  car_device_vendor_id; 
  assign car_csr_intf.car_device_info.device_revision_reset_value                         =  car_device_revision_id; 
  assign car_csr_intf.car_assembly_identity.assembly_identity_reset_value                 =  car_assey_id; 
  assign car_csr_intf.car_assembly_identity.assembly_vendor_identity_reset_value          =  car_assey_vendor_id; 
  assign car_csr_intf.car_assembly_info.assembly_revision_reset_value                     =  car_revision_id; 
  assign car_csr_intf.car_processing_element_features.bridge_reset_value                  =  car_bridge; 
  assign car_csr_intf.car_processing_element_features.memory_reset_value                  =  car_memory; 
  assign car_csr_intf.car_processing_element_features.processor_reset_value               =  car_processor; 
  assign car_csr_intf.car_processing_element_features.switch_reset_value                  =  car_switch; 
  assign car_csr_intf.car_switch_port_info.port_total_reset_value                         =  car_num_of_ports; 
  assign car_csr_intf.car_switch_port_info.port_number_reset_value                        =  car_port_num; 
  assign car_csr_intf.car_processing_element_features.extended_route_table_reset_value    =  car_extended_route_table; 
  assign car_csr_intf.car_processing_element_features.standard_route_table_reset_value    =  car_standard_route_table; 
  assign car_csr_intf.car_processing_element_features.flow_arbitration_reset_value        =  car_flow_arbitration; 
  assign car_csr_intf.car_processing_element_features.flow_control_reset_value            =  car_flow_control; 
  assign car_csr_intf.car_data_streaming_dest_id_info.max_pdu_size_reset_value            =  car_max_pdu_size; 
  assign car_csr_intf.car_data_streaming_dest_id_info.segmentation_contexts_reset_value   =  car_segmentation_contexts; 
  assign car_csr_intf.car_switch_route_table_dest_id_limit.max_destid_reset_value         =  car_max_destid; 
  assign car_csr_intf.car_xored_source_operations.source_operations_xor_reset_value       =  car_source_operations; 
  assign car_csr_intf.car_xored_dest_operations.destination_operations_xor_reset_value    =  car_destination_operations;

  assign car_csr_intf.csr_data_streaming_logical_ctrl.tm_types_reset_value                =  csr_tm_types_reset_value; 
  assign car_csr_intf.csr_data_streaming_logical_ctrl.tm_mode_reset_value                 =  csr_tm_mode_reset_value;
  assign car_csr_intf.csr_data_streaming_logical_ctrl.mtu_reset_value                     =  csr_mtu_reset_value;
  assign car_csr_intf.csr_data_streaming_logical_ctrl.external_tm_mode_wr                 =  csr_external_tm_mode_wr;
  assign car_csr_intf.csr_data_streaming_logical_ctrl.external_mtu_wr                     =  csr_external_mtu_wr;
  assign car_csr_intf.csr_data_streaming_logical_ctrl.external_tm_mode_in                 =  csr_external_tm_mode_in;
  assign car_csr_intf.csr_data_streaming_logical_ctrl.external_mtu_in                     =  csr_external_mtu_in; 

//##############################################################################
//##################### OUTPUT CONNECTIONS FROM CAR, CSR #######################
//##############################################################################
  
  assign base_device_id       = car_csr_intf.std_reg_outputs.base_device_id_out;
  assign large_base_device_id = car_csr_intf.std_reg_outputs.large_base_device_id_out;
  assign tm_types             = car_csr_intf.std_reg_outputs.tm_types;
  assign tm_mode              = car_csr_intf.std_reg_outputs.tm_mode ; 
  assign mtu                  = car_csr_intf.std_reg_outputs.mtu;
  
//##############################################################################
//################ INPUT CONNECTIONS TO ERROR MANAGEMENT BLOCK #################
//##############################################################################
  
  assign err_mgmt_intf.emef_err_mgmt_ext_header.ef_ptr_reset_value                                     =  ef_ptr_reset_value;
  assign err_mgmt_intf.emef_logical_trans_err_detect_csr.message_error_response_set                    =  message_error_response_set;
  assign err_mgmt_intf.emef_logical_trans_err_detect_csr.gsm_error_response_set                        =  gsm_error_response_set;
  assign err_mgmt_intf.emef_logical_trans_err_detect_csr.message_format_error_response_set             =  message_format_error_response_set;
  assign err_mgmt_intf.emef_logical_trans_err_detect_csr.external_illegal_transaction_decode_set       =  external_illegal_transaction_decode_set;
  assign err_mgmt_intf.emef_logical_trans_err_detect_csr.message_request_timeout_set                   =  external_message_request_timeout_set;
  assign err_mgmt_intf.emef_logical_trans_err_detect_csr.external_slave_packet_response_timeout_set    =  external_slave_packet_response_timeout_set;
  assign err_mgmt_intf.emef_logical_trans_err_detect_csr.external_unsolicited_response_set             =  external_unsolicited_response_set;
  assign err_mgmt_intf.emef_logical_trans_err_detect_csr.external_unsupported_transaction_set          =  external_unsupported_transaction_set;
  assign err_mgmt_intf.emef_logical_trans_err_detect_csr.external_illegal_transaction_target_error_set =  external_illegal_transaction_target_error_set;
  assign err_mgmt_intf.emef_logical_trans_err_detect_csr.missing_data_streaming_context_set            =  external_missing_data_streaming_context_set;
  assign err_mgmt_intf.emef_logical_trans_err_detect_csr.open_existing_data_streaming_context_set      =  external_open_existing_data_streaming_context_set;
  assign err_mgmt_intf.emef_logical_trans_err_detect_csr.long_data_streaming_segment_set               =  external_long_data_streaming_segment_set;
  assign err_mgmt_intf.emef_logical_trans_err_detect_csr.short_data_streaming_segment_set              =  external_short_data_streaming_segment_set;
  assign err_mgmt_intf.emef_logical_trans_err_detect_csr.data_streaming_pdu_length_error_set           =  external_data_streaming_pdu_length_error_set;
  assign err_mgmt_intf.emef_logical_trans_dev_id_capt_csr.external_capture_destinationID_wr            =  external_capture_destinationID_wr;
  assign err_mgmt_intf.emef_logical_trans_dev_id_capt_csr.external_capture_destinationID_in            =  external_capture_destinationID_in;
  assign err_mgmt_intf.emef_logical_trans_dev_id_capt_csr.external_capture_sourceID_wr                 =  external_capture_sourceID_wr;
  assign err_mgmt_intf.emef_logical_trans_dev_id_capt_csr.external_capture_sourceID_in                 =  external_capture_sourceID_in;
  assign err_mgmt_intf.emef_logical_trans_ctrl_capt_csr.external_capture_ftype_wr                      =  external_capture_ftype_wr;
  assign err_mgmt_intf.emef_logical_trans_ctrl_capt_csr.external_capture_ftype_in                      =  external_capture_ftype_in; 
  assign err_mgmt_intf.emef_logical_trans_ctrl_capt_csr.external_capture_ttype_wr                      =  external_capture_ttype_wr;
  assign err_mgmt_intf.emef_logical_trans_ctrl_capt_csr.external_capture_ttype_in                      =  external_capture_ttype_in;
  assign err_mgmt_intf.emef_logical_trans_ctrl_capt_csr.external_letter_wr                             =  external_letter_wr;
  assign err_mgmt_intf.emef_logical_trans_ctrl_capt_csr.external_letter_in                             =  external_letter_in;
  assign err_mgmt_intf.emef_logical_trans_ctrl_capt_csr.external_mbox_wr                               =  external_mbox_wr;
  assign err_mgmt_intf.emef_logical_trans_ctrl_capt_csr.external_mbox_in                               =  external_mbox_in;
  assign err_mgmt_intf.emef_logical_trans_ctrl_capt_csr.external_msgseg_wr                             =  external_msgseg_wr;
  assign err_mgmt_intf.emef_logical_trans_ctrl_capt_csr.external_msgseg_in                             =  external_msgseg_in;
  assign err_mgmt_intf.emef_logical_trans_ctrl_capt_csr.external_xmbox_wr                              =  external_xmbox_wr;
  assign err_mgmt_intf.emef_logical_trans_ctrl_capt_csr.external_xmbox_in                              =  external_xmbox_in;

//##############################################################################
//############## OUTPUT CONNECTIONS FROM ERROR MANAGEMENT BLOCK ################
//##############################################################################  
  
  assign port_degraded           = err_mgmt_intf.std_reg_output.port_degraded;
  assign port_failed             = err_mgmt_intf.std_reg_output.port_failed;
  assign logical_transport_error = err_mgmt_intf.std_reg_output.logical_transport_error;
  assign time_to_live            = err_mgmt_intf.std_reg_output.time_to_live;

//##############################################################################
//###### INPUT CONNECTIONS TO Lp-Serial & Lp-serial Lane PHY Registers #########
//##############################################################################

  assign lp_serial.port_general_control_csr.host_reset_value                       = host_reset_value;
  assign lp_serial.port_general_control_csr.master_enable_reset_value              = master_enable_reset_value;
  assign lp_serial.port_general_control_csr.discovered_reset_value                 = discovered_reset_value;
  assign lp_serial.port_0_control_csr.flow_control_participant_reset_value         = flow_control_participant_reset_value;
  assign lp_serial.port_0_control_csr.enumeration_boundary_reset_value             = enumeration_boundary_reset_value;
  assign lp_serial.port_0_control_csr.flow_arbitration_participant_reset_value     = flow_arbitration_participant_reset_value;
  assign lp_serial.port_0_control_csr.disable_destination_id_checking_reset_value  = disable_destination_id_checking_reset_value;
 
  assign lp_serial_lane_0.lane_n_status_0_csr.transmitter_type_reset_value         = transmitter_type_reset_value;
  assign lp_serial_lane_0.lane_n_status_0_csr.receiver_type_reset_value            = receiver_type_reset_value;
  assign lp_serial_lane_1.lane_n_status_0_csr.transmitter_type_reset_value         = transmitter_type_reset_value;
  assign lp_serial_lane_1.lane_n_status_0_csr.receiver_type_reset_value            = receiver_type_reset_value;
  assign lp_serial_lane_2.lane_n_status_0_csr.transmitter_type_reset_value         = transmitter_type_reset_value;
  assign lp_serial_lane_2.lane_n_status_0_csr.receiver_type_reset_value            = receiver_type_reset_value;
  assign lp_serial_lane_3.lane_n_status_0_csr.transmitter_type_reset_value         = transmitter_type_reset_value;
  assign lp_serial_lane_3.lane_n_status_0_csr.receiver_type_reset_value            = receiver_type_reset_value;

  assign lp_serial_lane_0.lane_register_block_header.ef_ptr_reset_value            = (ERROR_MANAGEMENT_EXTENSION==1)? 16'h0300 : ef_ptr_reset_value; 

  assign master_enable          = lp_serial.port_general_control_csr.master_enable;
  assign port_response_timeout  = lp_serial.port_response_timeout_control_csr.timeout_interval_value;

assign io_m_mnt_irq = (IO_MASTER)?io_m_mnt_irq_s:1'b0;

assign io_s_mnt_irq = (IO_SLAVE)?io_s_mnt_irq_s:1'b0;

// Warning Removal
assign phy_rx.channel[0] = 1'b0;

assign io_master_av_mm.writeresponse[0] = 1'b0;
assign io_master_av_mm.readerror = 1'd0;
assign io_master_av_mm.irq = 1'd0;
assign io_master_av_mm.chipselect = 1'd0;

assign avln_rd_wr.chipselect = 1'd0;

assign avln_wr.read = 1'd0;
assign avln_wr.chipselect = 1'd0;

assign avln_rd.writedata = 128'd0;
assign avln_rd.chipselect = 1'd0;

endmodule : altera_rapidio2_megacore_top

//##############################################################################
//################################ END OF FILE #################################
//############################################################################## 
