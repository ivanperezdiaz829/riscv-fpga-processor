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


import altera_xcvr_functions::*;
// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on

module altera_rapidio2_top
#(
     //----------------------------------------------------
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
     parameter SUPPORT_2X                      = 1'b1,     
     parameter SUPPORT_1X                      = 1'b1,
     parameter MAX_BAUD_RATE                   = 6250,
     parameter REF_CLK_PERIOD                  = 6400,
     parameter SYS_CLK_PERIOD                  = 6400,
     parameter MAX_LINK_REQ_ATTEMPTS           = 7,
     parameter LANE_SYNC_VMIN                  = 13'd4095,
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
     parameter DSIZE                           = 32*LSIZE,

     parameter number_of_reconfig_interfaces   = ( SUPPORT_4X ) ? 5 : (( SUPPORT_2X )? 3 : 2 )
)
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
   input  logic [15:0] ef_ptr_reset_value,

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

  //------------------------------
  // SRIO User visible Interfaces
  //------------------------------
  //----------------------------------------------------------
  // Maintenance Module User visible Avalon-MM Slave Interface
  //----------------------------------------------------------
   input  logic [25:2]  mnt_s_address,//24-bit from generated top level, and tie the two LSBits to low as word address. 
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
   input  logic [IO_SLAVE_ADDRESS_WIDTH -1:4] ios_rd_wr_address,//Word address with 128-bit readdata, tie four LSBits to low.  
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
   input  logic [IO_SLAVE_ADDRESS_WIDTH -1:4]  ios_wr_address,//Word address with 128-bit readdata, tie four LSBits to low.
   input  logic         ios_wr_write,                  
   input  logic [127:0] ios_wr_writedata,              
   input  logic [15:0]  ios_wr_byteenable,             
   input  logic [4:0]   ios_wr_burstcount,             
   output logic         ios_wr_waitrequest,
  
  //----------------------------------------------------------------
  // IO Slave User visible Avalon-MM Slave Interface Read Interface
  // for 128 bit module
  //----------------------------------------------------------------
   input  logic [IO_SLAVE_ADDRESS_WIDTH -1:4]  ios_rd_address,//Word address with 128-bit readdata, tie four LSBits to low.
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
   input  logic [23:2]  ext_mnt_address,//location of 'configuration space' register is hardcoded to lowest 24-bit bute address space, tie the MSBits to low. So only 24-bit byte address (or 22-bit word address) of ext_mnt_address in used. 
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
   input logic             tx_pll_refclk,
   //input logic             rx_cdr_refclk,//tied to tx_pll_refclk

   input  logic [LSIZE-1:0] rx_serial_data,               
   output logic [LSIZE-1:0] tx_serial_data, 
   output logic [LSIZE-1:0] tx_cal_busy, //export. needed by reset controller.
   output logic [LSIZE-1:0] rx_cal_busy, //export. needed by reset controller. 
   output logic [0:0]       pll_locked,  //export. needed by reset controller. 1-bit only.
   output logic [LSIZE-1:0] rx_is_lockedtoref,
   output logic [LSIZE-1:0] rx_is_lockedtodata,
   output logic [LSIZE-1:0] rx_syncstatus,
   output logic [LSIZE-1:0] rx_signaldetect,
   output logic tx_clkout,
   output logic rx_clkout,
   output logic four_lanes_aligned,
   output logic two_lanes_aligned,

  //---------------------------------------------- 
  // PHY IP Avalon-MM User visible Slave Interface
  //---------------------------------------------- 
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

  //----------------------------------
  // External reset controller signals
  //----------------------------------
   // from Transceiver PHY reset controller
   input logic [LSIZE-1:0] tx_ready,
   input logic [LSIZE-1:0] rx_ready,
   input logic [0:0]       pll_powerdown,
   input logic [LSIZE-1:0] tx_analogreset,
   input logic [LSIZE-1:0] tx_digitalreset,
   input logic [LSIZE-1:0] rx_analogreset,
   input logic [LSIZE-1:0] rx_digitalreset,

  //---------------------------
  // Reconfig Controller Ports
  //---------------------------
   input  logic  [altera_xcvr_functions::get_reconfig_to_width(DEVICE_FAMILY,number_of_reconfig_interfaces)-1:0] reconfig_to_xcvr,
   output logic  [altera_xcvr_functions::get_reconfig_from_width(DEVICE_FAMILY,number_of_reconfig_interfaces)-1:0] reconfig_from_xcvr
);

  //---------------------------
  // PHY IP signals
  //---------------------------

   logic [LSIZE-1:0] tx_std_clkout;
   logic [LSIZE-1:0] rx_std_clkout;
   logic [LSIZE-1:0] tx_std_elecidle;
   logic [LSIZE-1:0] rx_std_signaldetect;
   logic [LSIZE-1:0] rx_std_wa_patternalign; //For manual word alignment in Native PHY MegaFunction, soft logics is required.
   logic [(LSIZE*64)-1:0] rx_parallel_data_native_phy;//Raw 64-bit/lane data.
   logic [(LSIZE*44)-1:0] tx_parallel_data_native_phy;//Raw 44-bit/lane data.
   logic [(LSIZE*(20+44))-1:0] tx_parallel_data_native_phy_stratixv; 

   logic [3:0]   force_electrical_idle;

   logic [3:0]  tx_datak0;
   logic [31:0] tx_parallel_data0;
   logic [3:0]  tx_datak1;
   logic [31:0] tx_parallel_data1;
   logic [3:0]  tx_datak2;
   logic [31:0] tx_parallel_data2;
   logic [3:0]  tx_datak3;
   logic [31:0] tx_parallel_data3;

  //---------------------------------------------------------------------
  // Soft PCS signals
  //---------------------------------------------------------------------
   logic [LSIZE-1:0] rx_std_rmfifo_full;
   logic [LSIZE-1:0] rx_std_rmfifo_empty;
   logic [DSIZE-1:0] rx_data;
   logic [CSIZE-1:0] rx_datak;
   logic [CSIZE-1:0] rx_dataerr;

   logic [15:0] rx_datak_int;
   logic [127:0] rx_parallel_data_int; 

   logic [2:0] init_port_width_frozen; //initialized_port_width in rx_std_clkout[0] domain
   logic       tx_clk_rst_n;
   logic       rx_clk_rst_n; 
  //-------------------------------------------------------------------------------
  // Top level System Verilog Interface Instatntiation for PHY & Standard Registers
  //-------------------------------------------------------------------------------
  altera_rapidio2_lp_serial_registers        lp_serial();

  //---------------------------------------------------------------------
  // Combinational logics
  //---------------------------------------------------------------------
   assign tx_clkout = tx_std_clkout[0];
   assign rx_clkout = rx_std_clkout[0];

   assign rx_signaldetect = rx_std_signaldetect;
   assign tx_std_elecidle = force_electrical_idle[LSIZE-1:0];
   assign rx_parallel_data_int  = {{128-DSIZE{1'b0}},rx_data};
   assign rx_datak_int = { {16-CSIZE{1'b0}},rx_datak };
  //---------------------------------------------------------------------
  // Instantiations
  //---------------------------------------------------------------------
   altera_rapidio2_megacore_top 
   #(
    .DEVICE_FAMILY                               (DEVICE_FAMILY)
   ,.ENABLE_TRANSPORT_LAYER                      (ENABLE_TRANSPORT_LAYER)
   ,.MAINTENANCE_SLAVE                           (MAINTENANCE_SLAVE)
   ,.MAINTENANCE_MASTER                          (MAINTENANCE_MASTER)
   ,.IO_SLAVE                                    (IO_SLAVE)
   ,.IO_MASTER                                   (IO_MASTER)
   ,.DOORBELL                                    (DOORBELL)
   ,.SYS_CLK_FREQ                                (SYS_CLK_FREQ)
   ,.ARB_PRIORITY_M1                             (ARB_PRIORITY_M1)
   ,.IO_SLAVE_TRANS_ID_START_INIT                (IO_SLAVE_TRANS_ID_START_INIT)
   ,.IO_SLAVE_TRANS_ID_END_INIT                  (IO_SLAVE_TRANS_ID_END_INIT)
   ,.ERROR_MANAGEMENT_EXTENSION                  (ERROR_MANAGEMENT_EXTENSION)
   ,.SUPPORT_4X                                  (SUPPORT_4X)
   ,.SUPPORT_2X                                  (SUPPORT_2X)
   ,.SUPPORT_1X                                  (SUPPORT_1X)
   ,.MAX_BAUD_RATE                               (MAX_BAUD_RATE)
   ,.REF_CLK_PERIOD                              (REF_CLK_PERIOD)
   ,.SYS_CLK_PERIOD                              (SYS_CLK_PERIOD)
   ,.MAX_LINK_REQ_ATTEMPTS                       (MAX_LINK_REQ_ATTEMPTS)
   ,.TRANSPORT_LARGE                             (TRANSPORT_LARGE)
   ,.PASS_THROUGH                                (PASS_THROUGH)
   ,.PROMISCUOUS                                 (PROMISCUOUS)
   ,.HEADER_BUF_DEPTH                            (HEADER_BUF_DEPTH)
   ,.PAYLOAD_BUF_DEPTH                           (PAYLOAD_BUF_DEPTH)
   ,.MAINTENANCE_ADDRESS_WIDTH                   (MAINTENANCE_ADDRESS_WIDTH)
   ,.PORT_WRITE_TX                               (PORT_WRITE_TX)
   ,.PORT_WRITE_RX                               (PORT_WRITE_RX)
   ,.DOORBELL_TX_ENABLE                          (DOORBELL_TX_ENABLE)
   ,.DOORBELL_RX_ENABLE                          (DOORBELL_RX_ENABLE)
   ,.IO_SLAVE_DOORBELL_WRITES_ORDER_PRESERVATION (IO_SLAVE_DOORBELL_WRITES_ORDER_PRESERVATION)
   ,.IO_MASTER_WINDOWS                           (IO_MASTER_WINDOWS)
   ,.IO_MASTER_ADDRESS_WIDTH                     (IO_MASTER_ADDRESS_WIDTH)
   ,.IO_MASTER_OUTSTANDING_READS                 (IO_MASTER_OUTSTANDING_READS)
   ,.IO_SLAVE_WINDOWS                            (IO_SLAVE_WINDOWS)
   ,.IO_SLAVE_ADDRESS_WIDTH                      (IO_SLAVE_ADDRESS_WIDTH)
   ,.IO_SLAVE_OUTSTANDING_NREADS                 (IO_SLAVE_OUTSTANDING_NREADS)
   ,.IO_SLAVE_OUTSTANDING_NWRITE_RS              (IO_SLAVE_OUTSTANDING_NWRITE_RS)
   ,.IO_SLAVE_READ_WRITE_ORDER                   (IO_SLAVE_READ_WRITE_ORDER)
   //Note that some parameters in this parameter list are not configurable by users.
   ) altera_rapidio2_megacore_top(
   //inputs
    .sys_clk                                           (sys_clk)
   ,.rst_n                                             (rst_n)
   ,.car_device_id                                     (car_device_id)
   ,.car_device_vendor_id                              (car_device_vendor_id)
   ,.car_device_revision_id                            (car_device_revision_id)
   ,.car_assey_id                                      (car_assey_id)
   ,.car_assey_vendor_id                               (car_assey_vendor_id)
   ,.car_revision_id                                   (car_revision_id)
   ,.car_bridge                                        (car_bridge)
   ,.car_memory                                        (car_memory)
   ,.car_processor                                     (car_processor)
   ,.car_switch                                        (car_switch)
   ,.car_num_of_ports                                  (car_num_of_ports)
   ,.car_port_num                                      (car_port_num)
   ,.car_extended_route_table                          (car_extended_route_table)
   ,.car_standard_route_table                          (car_standard_route_table)
   ,.car_flow_arbitration                              (car_flow_arbitration)
   ,.car_flow_control                                  (car_flow_control)
   ,.car_max_pdu_size                                  (car_max_pdu_size)
   ,.car_segmentation_contexts                         (car_segmentation_contexts)
   ,.car_max_destid                                    (car_max_destid)
   ,.car_source_operations                             (car_source_operations)
   ,.car_destination_operations                        (car_destination_operations)
   ,.csr_tm_types_reset_value                          (csr_tm_types_reset_value)
   ,.csr_tm_mode_reset_value                           (csr_tm_mode_reset_value)
   ,.csr_mtu_reset_value                               (csr_mtu_reset_value)
   ,.csr_external_tm_mode_wr                           (csr_external_tm_mode_wr)
   ,.csr_external_mtu_wr                               (csr_external_mtu_wr)
   ,.csr_external_tm_mode_in                           (csr_external_tm_mode_in)
   ,.csr_external_mtu_in                               (csr_external_mtu_in)
   ,.ef_ptr_reset_value                                (ef_ptr_reset_value)
   ,.message_error_response_set                        (message_error_response_set)
   ,.gsm_error_response_set                            (gsm_error_response_set)
   ,.message_format_error_response_set                 (message_format_error_response_set)
   ,.external_illegal_transaction_decode_set           (external_illegal_transaction_decode_set)
   ,.external_message_request_timeout_set              (external_message_request_timeout_set)
   ,.external_slave_packet_response_timeout_set        (external_slave_packet_response_timeout_set)
   ,.external_unsolicited_response_set                 (external_unsolicited_response_set)
   ,.external_unsupported_transaction_set              (external_unsupported_transaction_set)
   ,.external_illegal_transaction_target_error_set     (external_illegal_transaction_target_error_set)
   ,.external_missing_data_streaming_context_set       (external_missing_data_streaming_context_set)
   ,.external_open_existing_data_streaming_context_set (external_open_existing_data_streaming_context_set)
   ,.external_long_data_streaming_segment_set          (external_long_data_streaming_segment_set)
   ,.external_short_data_streaming_segment_set         (external_short_data_streaming_segment_set)
   ,.external_data_streaming_pdu_length_error_set      (external_data_streaming_pdu_length_error_set)
   ,.external_capture_destinationID_wr                 (external_capture_destinationID_wr)
   ,.external_capture_destinationID_in                 (external_capture_destinationID_in)
   ,.external_capture_sourceID_wr                      (external_capture_sourceID_wr)
   ,.external_capture_sourceID_in                      (external_capture_sourceID_in)
   ,.external_capture_ftype_wr                         (external_capture_ftype_wr)
   ,.external_capture_ftype_in                         (external_capture_ftype_in)
   ,.external_capture_ttype_wr                         (external_capture_ttype_wr)
   ,.external_capture_ttype_in                         (external_capture_ttype_in)
   ,.external_letter_wr                                (external_letter_wr)
   ,.external_letter_in                                (external_letter_in)
   ,.external_mbox_wr                                  (external_mbox_wr)
   ,.external_mbox_in                                  (external_mbox_in)
   ,.external_msgseg_wr                                (external_msgseg_wr)
   ,.external_msgseg_in                                (external_msgseg_in)
   ,.external_xmbox_wr                                 (external_xmbox_wr)
   ,.external_xmbox_in                                 (external_xmbox_in)
   ,.host_reset_value                                  (host_reset_value)
   ,.master_enable_reset_value                         (master_enable_reset_value)
   ,.discovered_reset_value                            (discovered_reset_value)
   ,.flow_control_participant_reset_value              (flow_control_participant_reset_value)
   ,.enumeration_boundary_reset_value                  (enumeration_boundary_reset_value)
   ,.flow_arbitration_participant_reset_value          (flow_arbitration_participant_reset_value)
   ,.disable_destination_id_checking_reset_value       (disable_destination_id_checking_reset_value)
   ,.transmitter_type_reset_value                      (transmitter_type_reset_value)
   ,.receiver_type_reset_value                         (receiver_type_reset_value)
   ,.mnt_s_address                                     ({mnt_s_address,2'd0})
   ,.mnt_s_write                                       (mnt_s_write)
   ,.mnt_s_writedata                                   (mnt_s_writedata)
   ,.mnt_s_read                                        (mnt_s_read)
   ,.iom_rd_wr_readdatavalid                           (iom_rd_wr_readdatavalid)
   ,.iom_rd_wr_readresponse                            (iom_rd_wr_readresponse)
   ,.iom_rd_wr_readdata                                (iom_rd_wr_readdata)
   ,.iom_rd_wr_waitrequest                             (iom_rd_wr_waitrequest)
   ,.ios_rd_wr_address                                 ({ios_rd_wr_address,4'd0})
   ,.ios_rd_wr_write                                   (ios_rd_wr_write)
   ,.ios_rd_wr_read                                    (ios_rd_wr_read)
   ,.ios_rd_wr_writedata                               (ios_rd_wr_writedata)
   ,.ios_rd_wr_burstcount                              (ios_rd_wr_burstcount)
   ,.ios_rd_wr_byteenable                              (ios_rd_wr_byteenable)
   ,.ios_wr_address                                    ({ios_wr_address,4'd0})
   ,.ios_wr_write                                      (ios_wr_write)
   ,.ios_wr_writedata                                  (ios_wr_writedata)
   ,.ios_wr_byteenable                                 (ios_wr_byteenable)
   ,.ios_wr_burstcount                                 (ios_wr_burstcount)
   ,.ios_rd_address                                    ({ios_rd_address,4'd0})               
   ,.ios_rd_read                                       (ios_rd_read) 
   ,.ios_rd_burstcount                                 (ios_rd_burstcount) 
   ,.ios_rd_byteenable                                 (ios_rd_byteenable) 
   ,.drbell_s_read                                     (drbell_s_read) 
   ,.drbell_s_write                                    (drbell_s_write)
   ,.drbell_s_address                                  (drbell_s_address)
   ,.drbell_s_writedata                                (drbell_s_writedata)
   ,.gen_rx_pd_ready                                   (gen_rx_pd_ready)
   ,.gen_rx_hd_ready                                   (gen_rx_hd_ready)
   ,.ext_tx_packet_size                                (ext_tx_packet_size)
   ,.gen_tx_data                                       (gen_tx_data)
   ,.gen_tx_valid                                      (gen_tx_valid)
   ,.gen_tx_startofpacket                              (gen_tx_startofpacket)
   ,.gen_tx_endofpacket                                (gen_tx_endofpacket)
   ,.gen_tx_empty                                      (gen_tx_empty)
   ,.ext_mnt_address                                   ({8'd0, ext_mnt_address, 2'd0})//location of 'configuration space' register is hardcoded to lowest 24-bit bute address space, tie the MSBits to low. Also tie the two LSBits to low for word address. 
   ,.ext_mnt_write                                     (ext_mnt_write)
   ,.ext_mnt_read                                      (ext_mnt_read)      
   ,.ext_mnt_writedata                                 (ext_mnt_writedata) 
   ,.usr_mnt_waitrequest                               (usr_mnt_waitrequest) 
   ,.usr_mnt_readdata                                  (usr_mnt_readdata) 
   ,.usr_mnt_readdatavalid                             (usr_mnt_readdatavalid) 
   ,.four_lanes_aligned                                (four_lanes_aligned) 
   ,.two_lanes_aligned                                 (two_lanes_aligned) 
   ,.rx_dataerr                                        (rx_dataerr)
   ,.rx_syncstatus                                     (rx_syncstatus)
   ,.send_multicast_event                              (send_multicast_event)
   ,.send_link_request_reset_device                    (send_link_request_reset_device)
     //Note: different name in connecting signals
   ,.tx_clkout                                         (tx_std_clkout[0])
   ,.rx_clkout                                         (rx_std_clkout[0])
   ,.rx_datak0                                         (rx_datak_int[3:0])
   ,.rx_datak1                                         (rx_datak_int[7:4])
   ,.rx_datak2                                         (rx_datak_int[11:8])
   ,.rx_datak3                                         (rx_datak_int[15:12])
   ,.rx_parallel_data0                                 (rx_parallel_data_int[31:0])
   ,.rx_parallel_data1                                 (rx_parallel_data_int[63:32])
   ,.rx_parallel_data2                                 (rx_parallel_data_int[95:64])
   ,.rx_parallel_data3                                 (rx_parallel_data_int[127:96])
   ,.tx_ready                                          (&tx_ready) //1-bit for all lane
   //outputs
   ,.base_device_id                                    (base_device_id)
   ,.large_base_device_id                              (large_base_device_id)
   ,.tm_types                                          (tm_types)
   ,.tm_mode                                           (tm_mode)
   ,.mtu                                               (mtu)
   ,.port_degraded                                     (port_degraded)
   ,.port_failed                                       (port_failed)
   ,.logical_transport_error                           (logical_transport_error)
   ,.time_to_live                                      (time_to_live)
   ,.mnt_s_waitrequest                                 (mnt_s_waitrequest)
   ,.mnt_s_readdatavalid                               (mnt_s_readdatavalid)
   ,.mnt_s_readdata                                    (mnt_s_readdata)
   ,.mnt_s_readerror                                   (mnt_s_readerror)
   ,.iom_rd_wr_read                                    (iom_rd_wr_read)
   ,.iom_rd_wr_write                                   (iom_rd_wr_write)
   ,.iom_rd_wr_writedata                               (iom_rd_wr_writedata)
   ,.iom_rd_wr_burstcount                              (iom_rd_wr_burstcount)
   ,.iom_rd_wr_byteenable                              (iom_rd_wr_byteenable)
   ,.iom_rd_wr_address                                 (iom_rd_wr_address)
   ,.ios_wr_waitrequest                                (ios_wr_waitrequest)
   ,.ios_rd_wr_waitrequest                             (ios_rd_wr_waitrequest)
   ,.ios_rd_wr_readdata                                (ios_rd_wr_readdata)
   ,.ios_rd_wr_readresponse                            (ios_rd_wr_readresponse)
   ,.ios_rd_wr_readdatavalid                           (ios_rd_wr_readdatavalid)
   ,.ios_rd_waitrequest                                (ios_rd_waitrequest)
   ,.ios_rd_readdata                                   (ios_rd_readdata)
   ,.ios_rd_readdatavalid                              (ios_rd_readdatavalid)
   ,.ios_rd_readresponse                               (ios_rd_readresponse)
   ,.drbell_s_waitrequest                              (drbell_s_waitrequest)
   ,.drbell_s_readdata                                 (drbell_s_readdata)
   ,.gen_rx_pd_data                                    (gen_rx_pd_data)
   ,.gen_rx_pd_valid                                   (gen_rx_pd_valid)
   ,.gen_rx_pd_startofpacket                           (gen_rx_pd_startofpacket)
   ,.gen_rx_pd_endofpacket                             (gen_rx_pd_endofpacket)
   ,.gen_rx_pd_empty                                   (gen_rx_pd_empty)
   ,.gen_rx_hd_data                                    (gen_rx_hd_data)
   ,.gen_rx_hd_valid                                   (gen_rx_hd_valid)
   ,.transport_rx_packet_dropped                       (transport_rx_packet_dropped)
   ,.gen_tx_ready                                      (gen_tx_ready)
   ,.ext_mnt_waitrequest                               (ext_mnt_waitrequest)
   ,.ext_mnt_readdata                                  (ext_mnt_readdata)
   ,.ext_mnt_readdatavalid                             (ext_mnt_readdatavalid)
   ,.ext_mnt_readresponse                              (ext_mnt_readresponse)
   ,.ext_mnt_writeresponse                             (ext_mnt_writeresponse)
   ,.usr_mnt_address                                   (usr_mnt_address)
   ,.usr_mnt_write                                     (usr_mnt_write)
   ,.usr_mnt_read                                      (usr_mnt_read)
   ,.usr_mnt_writedata                                 (usr_mnt_writedata)
   ,.sent_link_request_reset_device                    (sent_link_request_reset_device)
   ,.multicast_event_rx                                (multicast_event_rx)
   ,.link_req_reset_device_received                    (link_req_reset_device_received)
   ,.sent_multicast_event                              (sent_multicast_event)
   ,.port_initialized                                  (port_initialized)
   ,.link_initialized                                  (link_initialized)
   ,.port_ok                                           (port_ok)
   ,.port_error                                        (port_error)
   ,.packet_transmitted                                (packet_transmitted)
   ,.packet_cancelled                                  (packet_cancelled)
   ,.packet_accepted_cs_sent                           (packet_accepted_cs_sent)
   ,.packet_retry_cs_sent                              (packet_retry_cs_sent)
   ,.packet_not_accepted_cs_sent                       (packet_not_accepted_cs_sent)
   ,.packet_accepted_cs_received                       (packet_accepted_cs_received)
   ,.packet_retry_cs_received                          (packet_retry_cs_received)
   ,.packet_not_accepted_cs_received                   (packet_not_accepted_cs_received)
   ,.packet_crc_error                                  (packet_crc_error)
   ,.control_symbol_error                              (control_symbol_error)
   ,.force_electrical_idle                             (force_electrical_idle)
   ,.tx_datak0                                         (tx_datak0)
   ,.tx_parallel_data0                                 (tx_parallel_data0)
   ,.tx_datak1                                         (tx_datak1)
   ,.tx_parallel_data1                                 (tx_parallel_data1)
   ,.tx_datak2                                         (tx_datak2)
   ,.tx_parallel_data2                                 (tx_parallel_data2)
   ,.tx_datak3                                         (tx_datak3)
   ,.tx_parallel_data3                                 (tx_parallel_data3)
   ,.std_reg_mnt_irq                                   (std_reg_mnt_irq)
   ,.mnt_mnt_s_irq                                     (mnt_mnt_s_irq)
   ,.io_m_mnt_irq                                      (io_m_mnt_irq)
   ,.io_s_mnt_irq                                      (io_s_mnt_irq)
   ,.drbell_s_irq                                      (drbell_s_irq)
   ,.master_enable                                     (master_enable)
   ,.lp_serial                                         (lp_serial)
   ,.init_port_width_frozen                            (init_port_width_frozen)
   ,.tx_clk_rst_n                                      (tx_clk_rst_n)
   ,.rx_clk_rst_n                                      (rx_clk_rst_n)
   );

genvar i;
generate 
//Module altera_xcvr_native_sv is sharing for both Stratix V and Arria V GZ
   if( DEVICE_FAMILY == "Stratix V" || DEVICE_FAMILY == "Arria V GZ" ) begin
      for (i=0; i<LSIZE; i=i+1) begin :rawdata//64*lanes TX raw data (Stratix V)
         //Mapping of TX data control character and TX data bus
         assign tx_parallel_data_native_phy_stratixv[(64*i)+63:(64*i)] = {20'd0,tx_parallel_data_native_phy[(44*i)+43:(44*i)]};
      end
   end
endgenerate

generate
// Module altera_xcvr_native_av is sharing for both Arria V and Cyclone V
 if( DEVICE_FAMILY == "Arria V" || DEVICE_FAMILY == "Cyclone V" ) begin
   altera_rapidio2_native_phy #(
    .MAX_BAUD_RATE_WITH_UNIT (MAX_BAUD_RATE_WITH_UNIT)
   ,.REF_CLK_FREQ_WITH_UNIT  (REF_CLK_FREQ_WITH_UNIT)
   ) altera_rapidio2_native_phy( //Arria V Native PHY
   // inputs
    .tx_pll_refclk             (tx_pll_refclk)
   ,.rx_cdr_refclk             (tx_pll_refclk)               //tied to tx_pll_refclk
   ,.tx_std_coreclkin          ({LSIZE{tx_std_clkout[0]}})   //feedback from clkout. bonded mode so all coreclkin driven by tx_std_clkout[0] master channel.

   ,.rx_std_coreclkin          ({LSIZE{rx_std_clkout[0]}})   //feedback from rx clkout, all channels driven by single clock to have 0 phase difference.

   ,.pll_powerdown             (pll_powerdown)
   ,.tx_analogreset            (tx_analogreset)              //from reset controller. Width = LSIZE.
   ,.tx_digitalreset           (tx_digitalreset)             //from reset controller. Width = LSIZE.
   ,.rx_analogreset            (rx_analogreset)              //from reset controller. Width = LSIZE.
   ,.rx_digitalreset           (rx_digitalreset)             //from reset controller. Width = LSIZE.
   ,.rx_serial_data            (rx_serial_data)
   ,.rx_set_locktodata         ({LSIZE{1'b0}})               //Not in used, MUST tied to zero.
   ,.rx_set_locktoref          ({LSIZE{1'b0}})               //Not in used, MUST tied to zero.
   ,.tx_parallel_data          (tx_parallel_data_native_phy) //Raw 44-bit/lane data.
   ,.rx_std_wa_patternalign    (rx_std_wa_patternalign)      //for manual word alignment
   ,.tx_std_elecidle           (tx_std_elecidle)             //IF not in used, MUST tied to zero.
   ,.rx_std_bitrev_ena         ({LSIZE{1'b0}})     
   ,.tx_std_polinv             ({LSIZE{1'b0}})             //IF not in used, MUST tied to zero.
   ,.rx_std_polinv             ({LSIZE{1'b0}})     
   ,.reconfig_to_xcvr          (reconfig_to_xcvr)
   // outputs
   ,.tx_std_clkout             (tx_std_clkout)               //to soft PCS and export
   ,.rx_std_clkout             (rx_std_clkout)               //to soft PCS and export

   ,.tx_serial_data            (tx_serial_data)
   ,.pll_locked                (pll_locked) 
   ,.rx_is_lockedtoref         (rx_is_lockedtoref)
   ,.rx_is_lockedtodata        (rx_is_lockedtodata)
   ,.rx_parallel_data          (rx_parallel_data_native_phy) //Output raw data, 64bit/lane.
   ,.rx_std_signaldetect       (rx_std_signaldetect)         //to soft PCS and export
   ,.tx_cal_busy               (tx_cal_busy)
   ,.rx_cal_busy               (rx_cal_busy)
   ,.reconfig_from_xcvr        (reconfig_from_xcvr)
   );

   // To map 32-bit data per lane into Transceiver Native PHY tx_parallel_data.
   altera_rapidio2_av_tx_data_map
   #(
    .SUPPORT_2X(SUPPORT_2X)
   ,.SUPPORT_4X(SUPPORT_4X)) altera_rapidio2_tx_data_map (
   // inputs
    .tx_datak0         (tx_datak0)
   ,.tx_parallel_data0 (tx_parallel_data0)
   ,.tx_datak1         (tx_datak1)
   ,.tx_parallel_data1 (tx_parallel_data1)
   ,.tx_datak2         (tx_datak2)
   ,.tx_parallel_data2 (tx_parallel_data2)
   ,.tx_datak3         (tx_datak3)
   ,.tx_parallel_data3 (tx_parallel_data3)
   // outputs
   ,.tx_parallel_data_native_phy (tx_parallel_data_native_phy)
   );
 end else if( DEVICE_FAMILY == "Stratix V" || DEVICE_FAMILY == "Arria V GZ" ) begin
   altera_rapidio2_native_phy #(
    .MAX_BAUD_RATE_WITH_UNIT (MAX_BAUD_RATE_WITH_UNIT)
   ,.REF_CLK_FREQ_WITH_UNIT  (REF_CLK_FREQ_WITH_UNIT)
   )
   altera_rapidio2_native_phy(                               //Stratix V Native PHY
   // inputs
    .tx_pll_refclk             (tx_pll_refclk)
   ,.rx_cdr_refclk             (tx_pll_refclk)               //tied to tx_pll_refclk
   ,.tx_std_coreclkin          ({LSIZE{tx_std_clkout[0]}})   //feedback from clkout. bonded mode so all coreclkin driven by tx_std_clkout[0] master channel.
   ,.rx_std_coreclkin          ({LSIZE{rx_std_clkout[0]}})   //feedback from rx clkout, all channels driven by single clock to have 0 phase difference.

   ,.pll_powerdown             (pll_powerdown) 
   ,.tx_analogreset            (tx_analogreset)              //from reset controller. Width = LSIZE.
   ,.tx_digitalreset           (tx_digitalreset)             //from reset controller. Width = LSIZE.
   ,.rx_analogreset            (rx_analogreset)              //from reset controller. Width = LSIZE.
   ,.rx_digitalreset           (rx_digitalreset)             //from reset controller. Width = LSIZE.
   ,.rx_serial_data            (rx_serial_data)
   ,.rx_set_locktodata         ({LSIZE{1'b0}})               //Not in used, MUST tied to zero.
   ,.rx_set_locktoref          ({LSIZE{1'b0}})               //Not in used, MUST tied to zero.
   ,.tx_parallel_data          (tx_parallel_data_native_phy_stratixv)//generic for diff LSIZE //Raw 64-bit/lane data. MSB 20-bit unused in Stratix V Native PHY. 
   ,.rx_std_wa_patternalign    (rx_std_wa_patternalign)      //for manual word alignment
   ,.tx_std_elecidle           (tx_std_elecidle)             //IF not in used, MUST tied to zero.
   ,.rx_std_bitrev_ena         ({LSIZE{1'b0}})     
   ,.tx_std_polinv             ({LSIZE{1'b0}})             //IF not in used, MUST tied to zero.
   ,.rx_std_polinv             ({LSIZE{1'b0}})  
   ,.reconfig_to_xcvr          (reconfig_to_xcvr)
   // outputs
   ,.tx_std_clkout             (tx_std_clkout)               //to soft PCS and export
   ,.rx_std_clkout             (rx_std_clkout)               //to soft PCS and export

   ,.tx_serial_data            (tx_serial_data)
   ,.pll_locked                (pll_locked) 
   ,.rx_is_lockedtoref         (rx_is_lockedtoref)
   ,.rx_is_lockedtodata        (rx_is_lockedtodata)
   ,.rx_parallel_data          (rx_parallel_data_native_phy) //Output raw data, 64bit/lane.
   ,.rx_std_signaldetect       (rx_std_signaldetect)         //to soft PCS and export
   ,.tx_cal_busy               (tx_cal_busy)
   ,.rx_cal_busy               (rx_cal_busy)
   ,.reconfig_from_xcvr        (reconfig_from_xcvr)
   );

   // To map 32-bit data per lane into Transceiver Native PHY tx_parallel_data.
   altera_rapidio2_av_tx_data_map
   #(
    .SUPPORT_2X(SUPPORT_2X)
   ,.SUPPORT_4X(SUPPORT_4X)) altera_rapidio2_tx_data_map (
   // inputs
    .tx_datak0         (tx_datak0)
   ,.tx_parallel_data0 (tx_parallel_data0)
   ,.tx_datak1         (tx_datak1)
   ,.tx_parallel_data1 (tx_parallel_data1)
   ,.tx_datak2         (tx_datak2)
   ,.tx_parallel_data2 (tx_parallel_data2)
   ,.tx_datak3         (tx_datak3)
   ,.tx_parallel_data3 (tx_parallel_data3)
   // outputs
   ,.tx_parallel_data_native_phy (tx_parallel_data_native_phy)
   );

 end else begin
   //Native PHY of other device families
 end
endgenerate

   altera_rapidio2_soft_pcs 
   #(
    .DEVICE_FAMILY(DEVICE_FAMILY)
   ,.SUPPORT_2X(SUPPORT_2X)
   ,.SUPPORT_4X(SUPPORT_4X)
   ,.LANE_SYNC_VMIN(LANE_SYNC_VMIN)) altera_rapidio2_soft_pcs(
   // inputs -- from PHY IP and reset controller.
    .clk                         (rx_std_clkout[0])
   ,.rdclk                       (tx_std_clkout[0])            //bonded mode.
   ,.rx_clk_rst_n                (rx_clk_rst_n)//rx_std_clkout domain.
   ,.tx_clk_rst_n                (tx_clk_rst_n)//tx_std_clkout domain.
   ,.rx_ready                    (rx_ready)                    //from reset controller. Width=LSIZE.
   ,.rx_parallel_data_native_phy (rx_parallel_data_native_phy) //from Native PHY. Raw 64bit/lane data.
   ,.rx_signaldetect             (rx_std_signaldetect)
   ,.init_port_width_frozen      (init_port_width_frozen)	//metastable crossed over from sys_clk to rx_std_clkout domain
   // outputs -- after processed by soft PCS, data goes into RapidIO II megacore.
   ,.rx_syncstatus        (rx_syncstatus)                      //Width=LSIZE
   ,.four_lanes_aligned   (four_lanes_aligned)
   ,.two_lanes_aligned    (two_lanes_aligned)
   ,.rx_rmfifodatainserted()//Not connected. To indicate that one |R| character is inserted by Rate Matcher, for clock compensation.
   ,.rx_rmfifodatadeleted ()//Not connected. To indicate that one |R| character is deleted by Rate Matcher, for clock compensation.
   ,.rx_rmfifofull        (rx_std_rmfifo_full)                 //overwrite Native PHY value.
   ,.rx_rmfifoempty       (rx_std_rmfifo_empty)                //overwrite Native PHY value.
   ,.rx_data              (rx_data)
   ,.rx_datak             (rx_datak)
   ,.rx_dataerr           (rx_dataerr)
   ,.rx_wa_patternalign   (rx_std_wa_patternalign)
   ,.rx_parallel_data_fnl () //(Optional) Map back to (64*LSIZE)-bit after soft PCS processing, with the following data/status updates:
                             //Bits [14:13] "RM deletion/insertion", [10] "word alignment status", data error, datak and data of each 16-bit word.

   );

endmodule
