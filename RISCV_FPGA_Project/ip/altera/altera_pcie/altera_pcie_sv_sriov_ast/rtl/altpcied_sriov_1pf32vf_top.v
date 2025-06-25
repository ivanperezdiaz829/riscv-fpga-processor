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


//  *  Top Level of SR-IOV Adapter with 1 PF and 32 VFs *
//
// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

// synthesis verilog_input_version verilog_2001
// turn off superfluous verilog processor warnings
// altera message_level Level1
// altera message_off 10034 10035 10036 10037 10230 10240 10030

//-----------------------------------------------------------------------------
// Title         : PCI Express SR-IOV MultiFunction Adapter
// Project       : PCI Express MegaCore function
//-----------------------------------------------------------------------------
// File          : altpcied_sriov_1pf32vf_top.v
// Author        : Altera Corporation
//-----------------------------------------------------------------------------
//

module altpcied_sriov_1pf32vf_top #
  (
   parameter port_width_data_hwtcl               = 256, // Width of internal data path
   parameter port_width_be_hwtcl                 = 32,  // Width of byte enable bus
   parameter multiple_packets_per_cycle_hwtcl    = 0, // 0 = 1 TLP per cycle, 1 = 2 TLPs may be present in the same cycle
   parameter VF_COUNT                            = 32,
   parameter SIG_TEST_EN                         = 1'b1, // Set this to 1 to enable PCIECV work-around 
   parameter DROP_POISONED_REQ                   = 0, // Set this to 1 to make the bridge drop Poisoned requests received from the link
   parameter DROP_POISONED_COMPL                 = 0, // Set this to 1 to make the bridge drop Poisoned Completions received from the link
   // HIP parameters
   parameter [15:0] DEVICE_ID       = 16'hE001,
   parameter [15:0] VENDOR_ID       = 16'h1172,
   parameter [15:0] SUBSYS_ID       = 16'h1234,
   parameter [15:0] SUBVENDOR_ID    = 16'h5678,
   parameter [7:0] CLASS_CODE       = 8'd0,
   parameter [7:0] SUBCLASS_CODE    = 8'd0,
   parameter [7:0] PCI_PROG_INTFC_BYTE = 8'd0,
   parameter [7:0] REVISION_CODE    = 8'd0,
   parameter [15:0] VF_DEVICE_ID    = 16'hE001,
   parameter SLOT_CLK_CONFIGURATION = 1,
   parameter PM_NO_SOFT_RESET       = "false",
   parameter MAX_PAYLOAD_SIZE       = 128, // Max payload size supported, 128/256 bytes
   // Config Space pointers
   parameter AER_CAP_PRESENT        = 1,
   parameter AER_SURPRISE_DOWN_REPORTING_CAPABLE = 0,
   parameter EXTENDED_TAG_SUPPORT   = "false", // Extended tags supported
   parameter ASPM_L0S_SUPPORT       = "true",
   parameter ASPM_L1_SUPPORT        = "false",
   parameter [2:0] L0S_LATENCY      = 3'd0,
   parameter [2:0] L1_LATENCY       = 3'd0,
   parameter [2:0] L0S_EXIT_LATENCY = 3'd6,
   parameter [2:0] L1_EXIT_LATENCY  = 3'd0,
   parameter COMPLETION_TIMEOUT_RANGES_SUPPORTED = "abcd",
   parameter COMPLETION_TIMEOUT_DISABLE_SUPPORT = 1,
   parameter ECRC_GENERATION_SUPPORT = 1'b0,// ECRC generation supported
   parameter ECRC_CHECK_SUPPORT     = 1'b0,// ECRC check supported
   parameter FLR_SUPPORT            = "false", // FLR supported
   parameter RELAXED_ORDER_SUPPORT  = 1'b1, // Device supports relaxed ordering
   parameter [31:0] SYSTEM_PAGE_SIZES_SUPPORTED = 32'h553, // Supported page sizes for SR-IOV
   // INTX pin and line settings
   parameter F0_INTR_PIN            = "inta",
   parameter [7:0] F0_INTR_LINE     = 8'hff,
   // MSI parameters
   parameter MSI_CAP_PRESENT        = "true",
   parameter [2:0] MSI_MULTI_MSG_CAPABLE = 3'd4,
   parameter MSI_64BIT_CAPABLE      = "true",
   parameter VF_MSI_CAP_PRESENT     = "true", // Indicates whether VFs include MSI Capability Structure
   parameter VF_MSI_64BIT_CAPABLE   = 1'b1,
   parameter VF_MSI_MULTI_MSG_CAPABLE = 3'd1,
   // MSIX parameters
   parameter MSIX_CAP_PRESENT        = "true",
   parameter [10:0] MSIX_TBL_SIZE   = 11'h1F, // 32  
   parameter [28:0] MSIX_TBL_OFFSET = 29'd0,
   parameter [2:0] MSIX_TBL_BIR     = 3'd0,
   parameter [28:0] MSIX_PBA_OFFSET = 29'h1000,
   parameter [2:0] MSIX_PBA_BIR     = 3'd0,
   parameter VF_MSIX_CAP_PRESENT    = "true",
   parameter [10:0] VF_MSIX_TBL_SIZE       = 11'h1F, // 32
   parameter [28:0] VF_MSIX_TBL_OFFSET     = 29'd0,
   parameter [2:0] VF_MSIX_TBL_BIR        = 3'd0,
   parameter [28:0] VF_MSIX_PBA_OFFSET     = 29'h1000,
   parameter [2:0] VF_MSIX_PBA_BIR        = 3'd0,

   // PF BAR parameters
   parameter PF_BAR0_PRESENT        = 1,  // 0 = not present, 1 = present
   parameter PF_BAR1_PRESENT        = 1,  // 0 = not present, 1 = present
   parameter PF_BAR2_PRESENT        = 1,  // 0 = not present, 1 = present
   parameter PF_BAR3_PRESENT        = 1,  // 0 = not present, 1 = present
   parameter PF_BAR0_TYPE           = 0, // 0 = 32-bit addressing, 1 = 64-bit addressing
   parameter PF_BAR2_TYPE           = 1, // 0 = 32-bit addressing, 1 = 64-bit addressing
   parameter PF_BAR0_PREFETCHABLE   = 0, // 0 = non-prefetchable, 1 = prefetchable
   parameter PF_BAR1_PREFETCHABLE   = 0, // 0 = non-prefetchable, 1 = prefetchable
   parameter PF_BAR2_PREFETCHABLE   = 1, // 0 = non-prefetchable, 1 = prefetchable
   parameter PF_BAR3_PREFETCHABLE   = 1, // 0 = non-prefetchable, 1 = prefetchable
   parameter PF_BAR0_SIZE           = 22, // 7 = 128 bytes, 8 = 256 bytes, 9 = 512 bytes, ..., 31 = 2G
   parameter PF_BAR1_SIZE           = 22, // 7 = 128 bytes, 8 = 256 bytes, 9 = 512 bytes, ..., 31 = 2G
   parameter PF_BAR2_SIZE           = 22, // 7 = 128 bytes, 8 = 256 bytes, 9 = 512 bytes, ..., 31 = 2G
   parameter PF_BAR3_SIZE           = 22, // 7 = 128 bytes, 8 = 256 bytes, 9 = 512 bytes, ..., 31 = 2G
   // VF BAR parameters
   parameter VF_BAR0_PRESENT        = 1,  // 0 = not present, 1 = present
   parameter VF_BAR1_PRESENT        = 1,  // 0 = not present, 1 = present
   parameter VF_BAR2_PRESENT        = 1,  // 0 = not present, 1 = present
   parameter VF_BAR3_PRESENT        = 1,  // 0 = not present, 1 = present
   parameter VF_BAR0_TYPE           = 0, // 0 = 32-bit addressing, 1 = 64-bit addressing
   parameter VF_BAR2_TYPE           = 1, // 0 = 32-bit addressing, 1 = 64-bit addressing
   parameter VF_BAR0_PREFETCHABLE   = 0, // 0 = non-prefetchable, 1 = prefetchable
   parameter VF_BAR1_PREFETCHABLE   = 0, // 0 = non-prefetchable, 1 = prefetchable
   parameter VF_BAR2_PREFETCHABLE   = 1, // 0 = non-prefetchable, 1 = prefetchable
   parameter VF_BAR3_PREFETCHABLE   = 1, // 0 = non-prefetchable, 1 = prefetchable
   parameter VF_BAR0_SIZE           = 22, // 7 = 128 bytes, 8 = 256 bytes, 9 = 512 bytes, ..., 31 = 2G
   parameter VF_BAR1_SIZE           = 22, // 7 = 128 bytes, 8 = 256 bytes, 9 = 512 bytes, ..., 31 = 2G
   parameter VF_BAR2_SIZE           = 22, // 7 = 128 bytes, 8 = 256 bytes, 9 = 512 bytes, ..., 31 = 2G
   parameter VF_BAR3_SIZE           = 22 // 7 = 128 bytes, 8 = 256 bytes, 9 = 512 bytes, ..., 31 = 2G
   ) 
  (
   // Clock and reset
   //
   input                      Clk_i,
   input                      Rstn_i,
   input                      PowerOnRstn_i,
   //###################################################################################
   // BAR apertures
   //###################################################################################
   input [31:0]               f0_bar0_aperture_i,
   input [31:0]               f0_bar1_aperture_i,
   input [31:0]               f0_bar2_aperture_i,
   input [31:0]               f0_bar3_aperture_i,
   input [31:0]               f0_vf_bar0_aperture_i,
   input [31:0]               f0_vf_bar1_aperture_i,
   input [31:0]               f0_vf_bar2_aperture_i,
   input [31:0]               f0_vf_bar3_aperture_i,
   input [31:0]               f0_vf_bar0_aperture_bitmask_i,
   input [31:0]               f0_vf_bar1_aperture_bitmask_i,
   input [31:0]               f0_vf_bar2_aperture_bitmask_i,
   input [31:0]               f0_vf_bar3_aperture_bitmask_i,
   //###################################################################################
   // RX Streaming Interface to HIP 
   //###################################################################################
   input [port_width_data_hwtcl-1:0] RxStData_hip_i,
   input [multiple_packets_per_cycle_hwtcl:0] RxStSop_hip_i,
   input [multiple_packets_per_cycle_hwtcl:0] RxStEop_hip_i,
   input [multiple_packets_per_cycle_hwtcl:0] RxStErr_hip_i,
   input [multiple_packets_per_cycle_hwtcl:0] RxStValid_hip_i,
   output                     RxStMask_hip_o,
   input [1:0]                RxStEmpty_hip_i,
   output                     RxStReady_hip_o,
   input [port_width_be_hwtcl-1:0] RxStParity_hip_i,
   input                      RxStBuff_Overflow_i,
   //###################################################################################
   // RX Streaming Interface to app layer
   //###################################################################################
   output [port_width_data_hwtcl-1:0] RxStData_app_o,
   output [multiple_packets_per_cycle_hwtcl:0] RxStSop_app_o,
   output [multiple_packets_per_cycle_hwtcl:0] RxStEop_app_o,
   output [multiple_packets_per_cycle_hwtcl:0] RxStErr_app_o,
   output [multiple_packets_per_cycle_hwtcl:0] RxStValid_app_o,
   input                      RxStMask_app_i,
   output [1:0]               RxStEmpty_app_o,
   input                      RxStReady_app_i,
   output [port_width_be_hwtcl-1:0] RxStParity_app_o,
   // BAR hit signals
   output [7:0]               rx_st_bar_hit_tlp0_o, // BAR hit information for first TLP in this cycle
   output [7:0]               rx_st_bar_hit_fn_tlp0_o, // Target Function for first TLP in this cycle
   output [7:0]               rx_st_bar_hit_tlp1_o, // BAR hit information for first TLP in this cycle
   output [7:0]               rx_st_bar_hit_fn_tlp1_o, // Target Function for second TLP in this cycle
   //###################################################################################
   // TX Streaming Interface to HIP 
   //###################################################################################
   output [port_width_data_hwtcl-1:0] TxStData_hip_o,
   output [multiple_packets_per_cycle_hwtcl:0] TxStSop_hip_o,
   output [multiple_packets_per_cycle_hwtcl:0] TxStEop_hip_o,
   output [multiple_packets_per_cycle_hwtcl:0] TxStErr_hip_o,
   output [multiple_packets_per_cycle_hwtcl:0] TxStValid_hip_o,
   output [1:0]               TxStEmpty_hip_o,
   output [port_width_be_hwtcl-1:0] TxStParity_hip_o,
   input                      TxStReady_hip_i,
   //###################################################################################
   // TX Streaming Interface to app layer 
   //###################################################################################
   input [port_width_data_hwtcl-1:0] TxStData_app_i,
   input [multiple_packets_per_cycle_hwtcl:0]  TxStSop_app_i,
   input [multiple_packets_per_cycle_hwtcl:0]  TxStEop_app_i,
   input [multiple_packets_per_cycle_hwtcl:0]  TxStErr_app_i,
   input [multiple_packets_per_cycle_hwtcl:0]  TxStValid_app_i,
   input [1:0]                   TxStEmpty_app_i,
   input [port_width_be_hwtcl-1:0] TxStParity_app_i,
   output                     TxStReady_app_o,
   //###################################################################################
   // LMI interface to HIP
   //###################################################################################
   output [11 : 0]            lmi_addr_hip_o,
   output [31 : 0]            lmi_din_hip_o,
   output reg                 lmi_rden_hip_o,
   output reg                 lmi_wren_hip_o,
   input                      lmi_ack_hip_i,
   input [31 : 0]             lmi_dout_hip_i,
   //###################################################################################
   // LMI interface to user application
   //###################################################################################
   input  [20 : 0]            lmi_addr_app_i, // [11:0] = address
                                              // [19:12] = Function Number, 
                                              // [20] = 0 => access to Hard IP register  
                                              // [20] = 1 => access to 2-Function config space
   input  [31 : 0]            lmi_din_app_i,
   input                      lmi_rden_app_i,
   input                      lmi_wren_app_i,
   output reg                 lmi_ack_app_o,
   output reg [31 : 0]        lmi_dout_app_o,
   //###################################################################################
   // Status and error inputs from HIP
   //###################################################################################
   input [1:0]                current_speed_i, // 2'b01 = 2.5G, 2'b010 = 5G
   input                      current_deemph_i, // Current de-emphasis setting
   input [3:0]                lane_active_i, // Active lane map
   input                      dl_prot_err_i, // DL protocol error
   input                      fl_prot_err_i, // Flow control protocol error
   input                      rx_fifo_overflow_i, // Receive FIFO overflow
   input                      malf_tlp_rcvd_i, // Malformed TLP received
   input                      ecrc_err_i, // ECRC error detected
   input                      phy_err_i,  // Receiver error
   input                      dllp_err_i, // Bad DLLP received
   input                      tlp_err_i, // TLP failed LCRC check
   input                      replay_timeout_i, // Replay occurred
   input                      replay_timer_rollover_i, // Replay timer rolled over               
   input                      link_control2_reg_reset_enter_compl_i, // Resets Enter Compliance bit in Link Control 2 Reg
   input                      link_control2_reg_reset_tx_margin_i, // Resets Tx Margin bit in Link Control 2 Reg
   input [7:0]                lane_error_detected_i, // Lane error indications for setting Lane Error Status Register bits (1 per lane)
   input                      link_equalization_req_i, // Input to set Link equalization request bit of Link Status 2 Register
   input                      link_equalization_complete_i, // Input to set Equalization Complete bit of Link Status 2 Register
   input                      link_eq_phase1_successful_i,// Input to set Equalization Phase 1 Successful bit of Link Status 2 Register
   input                      link_eq_phase2_successful_i,// Input to set Equalization Phase 2 Successful bit of Link Status 2 Register
   input                      link_eq_phase3_successful_i,// Input to set Equalization Phase 3 Successful bit of Link Status 2 Register
   input [4:0]                ltssm_state_i, 
   //###################################################################################
   // Config register outputs to HIP
   //###################################################################################
   output [12:0]              f0_link_control2_reg_o, // bits [12:0] of Link Control 2 Register
   output                     f0_link_control_reg_ext_synch_o, // Extended Synch Enable bit from Link Control Register
   output                     f0_link_control_reg_com_clk_conf_o, // Common Clock Configuration bit from Link Control Register
   output [2:0]               device_control_reg_max_payload_size_o, // Max Payload Size from Device Control Register
   output [2:0] 	      device_control_reg_read_req_size_o, // Read Request Size from Device Control Register
   output                     f0_link_control_reg_aspm_ctl_o, // ASPM control bit 0 from Link Control Register
   output                     f0_ecrc_gen_enable_o, // ECRC Generation Enable
   output                     f0_ecrc_chk_enable_o, // ECRC Check Enable
   //========================================================================
   // Interrupt interface
   //======================================================================== 	
   input                      int_sts_a_i,
   input                      int_sts_b_i,
   input                      int_sts_c_i,
   input                      int_sts_d_i,
   input [2:0]                int_sts_fn_i,
   output                     int_ack_o,
   input                      msi_req_i,
   output                     msi_ack_o,
   input [7:0]                msi_req_fn_i,
   input [4:0]                msi_num_i,
   input [2:0]                msi_tc_i,
   input                      interrupt_pending_i,
   output                     intx_disable_o,
   output                     msi_en_pf_o,
   output [2:0]               msi_mult_msg_en_pf_o,
   output [VF_COUNT-1:0]      msi_en_vf_o,
   output [VF_COUNT*3-1:0]    msi_mult_msg_en_vf_o,
   output                     msix_en_pf_o,
   output        	      msix_fn_mask_pf_o,
   output [VF_COUNT-1:0]      msix_en_vf_o,
   output [VF_COUNT-1:0]      msix_fn_mask_vf_o,
   //======================================================================== 	
   // Status and Error input from user application
   //======================================================================== 	
   input                      compl_timeout_with_recovery_i,
   input                      compl_timeout_without_recovery_i,
   input                      ca_sent_i,
   input                      unexp_compl_rcvd_i,
   input                      unsupp_p_req_rcvd_i,
   input                      unsupp_np_req_rcvd_i,
   input                      app_header_logging_en_i,
   input [7:0]                error_reporting_fn_i,
   input                      trans_pending_pf_i,
   input [VF_COUNT-1:0]       trans_pending_vf_i,
   input [127:0]              app_log_hdr_i,
   output                     flr_active_pf_o,
   input                      flr_completed_pf_i,
   output [VF_COUNT-1:0]      flr_active_vf_o,
   input [VF_COUNT-1:0]       flr_completed_vf_i,
   output [7:0]               bus_num_f0_o,
   output                     mem_space_en_pf_o,
   output                     mem_space_en_vf_o,
   output                     bus_master_en_pf_o,
   output [VF_COUNT-1:0]      bus_master_en_vf_o,
   output [7:0]               num_vfs_o
   );
   
   // LMI state machine states
   localparam 		      LMI_IDLE = 4'd0;
   localparam 		      WAIT_FOR_REMOTE_ACK = 4'd1;
   localparam 		      WAIT_FOR_LOCAL_ACK = 4'd2;
   localparam                 LMI_HIP_READ_HEADER_LOG_REG_1 = 4'd3;
   localparam                 LMI_HIP_READ_HEADER_LOG_REG_2 = 4'd4;
   localparam                 LMI_HIP_READ_HEADER_LOG_REG_3 = 4'd5;
   localparam                 LMI_HIP_READ_HEADER_LOG_REG_4 = 4'd6;
   localparam                 LMI_HIP_READ_HEADER_LOG_REG_5 = 4'd7;
   localparam                 LMI_HIP_READ_HEADER_LOG_REG_6 = 4'd8;
   localparam                 LMI_HIP_READ_HEADER_LOG_REG_7 = 4'd9;
   localparam                 LMI_HIP_READ_HEADER_LOG_REG_8 = 4'd10;
   localparam                 LMI_HIP_READ_HEADER_LOG_REG_9 = 4'd11;
   localparam                 LMI_WAIT_CYCLE = 4'd12;

   // Address of Header Log Register in HIP for access through LMI
   localparam                 HIP_HEADER_LOG_REG_ADDR = 12'h81c;
   // Address of AER Uncorrectable Error Status Register in HIP for access through LMI
   localparam                 HIP_AER_UNCORR_STATUS_REG_ADDR = 12'h804;

   // Function BARs
   wire [31:7] 		      f0_bar0;
   wire [31:0] 		      f0_bar1;
   wire [31:7] 		      f0_bar2;
   wire [31:0] 		      f0_bar3;
   // VF BAR base and limit settings
   wire [31:7] 		      f0_vf_bar0_base;
   wire [31:0] 		      f0_vf_bar1_base;
   wire [31:7] 		      f0_vf_bar2_base;
   wire [31:0] 		      f0_vf_bar3_base;
   wire [31:7] 		      f0_vf_bar0_limit;
   wire [31:0] 		      f0_vf_bar1_limit;
   wire [31:7] 		      f0_vf_bar2_limit;
   wire [31:0] 		      f0_vf_bar3_limit;
   wire [31:7] 		      vf_bar0_aperture_for_barcheck; // Aperture used for BAR checking
   wire [31:0] 		      vf_bar1_aperture_for_barcheck; // Aperture used for BAR checking
   wire [31:7] 		      vf_bar2_aperture_for_barcheck; // Aperture used for BAR checking
   wire [31:0] 		      vf_bar3_aperture_for_barcheck; // Aperture used for BAR checking
   wire 		      vf_bars_ready;

   wire [VF_COUNT-1:0] 	      vf_enable;

   // Config requests from RX bridge to config module
   wire [port_width_data_hwtcl-1:0] RxCfgData;
   wire [multiple_packets_per_cycle_hwtcl:0] RxCfgSop;
   wire [multiple_packets_per_cycle_hwtcl:0] RxCfgEop;
   wire [multiple_packets_per_cycle_hwtcl:0] RxCfgValid;
   wire [multiple_packets_per_cycle_hwtcl:0] RxCfgErr;
   wire 		      RxCfgReady;

   // Completions from Config module to TX bridge
   wire 		      CfgReq_send_compl;
   wire [95:0] 		      CfgReq_send_compl_hdr;
   wire [31:0] 		      CfgReq_send_compl_data;
   wire 		      CfgReq_send_compl_ack;

   // Interrupt and Error messages from Config module to TX bridge
   wire 		      CfgReq_send_msg;
   wire [127:0]               CfgReq_msg_hdr;
   wire [15:0]                CfgReq_msg_data;
   wire 		      CfgReq_msg_data_valid;
   wire                       CfgReq_msg_sent_ack;

   // Data from RX Streaming Interface to BAR check module
   wire [multiple_packets_per_cycle_hwtcl:0] RxStSop_barcheck;
   wire [multiple_packets_per_cycle_hwtcl:0] RxStEop_barcheck;
   wire [multiple_packets_per_cycle_hwtcl:0] RxStErr_barcheck;
   wire [port_width_data_hwtcl-1:0] RxStData_barcheck;
   wire [multiple_packets_per_cycle_hwtcl:0] RxStValid_barcheck;
   wire [1:0]                 RxStEmpty_barcheck;
   wire 		      RxStReady_barcheck;
   wire [port_width_be_hwtcl-1:0] RxStParity_barcheck;

   // Error reporting signals from BAR check module
   wire 		      bar_check_unsupp_p_req_rcvd;
   wire 		      bar_check_unsupp_np_req_rcvd;
   wire 		      bar_check_poisoned_req_rcvd_pf;
   wire [VF_COUNT-1:0] 	      bar_check_poisoned_req_rcvd_vf;
   wire 		      bar_check_poisoned_req_rcvd_vf_any;
   wire 		      bar_check_poisoned_compl_rcvd_pf;
   wire [VF_COUNT-1:0] 	      bar_check_poisoned_compl_rcvd_vf;
   wire 		      bar_check_poisoned_compl_rcvd_vf_any;  
   wire 		      bar_check_ur_compl_rcvd_pf;
   wire [VF_COUNT-1:0] 	      bar_check_ur_compl_rcvd_vf;
   wire 		      bar_check_ca_compl_rcvd_pf;
   wire [VF_COUNT-1:0] 	      bar_check_ca_compl_rcvd_vf;
   wire [127:0] 	      bar_check_captured_header;

   // Error reporting signals from TX bridge 
   wire 		      poisoned_req_sent_pf;
   wire [VF_COUNT-1:0] 	      poisoned_req_sent_vf;
   wire 		      poisoned_req_sent_vf_any;

   // Completions from BAR check module
   wire 		      bar_check_send_compl;
   wire [95:0] 		      bar_check_compl_hdr;
   wire 		      bar_check_compl_sent_ack;

   // LMI registers
   reg [20:0] 		      lmi_addr_reg;
   reg [31:0] 		      lmi_data_reg;
   reg [3:0] 		      lmi_state;
   wire [20:0] 		      lmi_addr_local;
   wire [31:0] 		      lmi_read_data_local;
   wire [31:0] 		      lmi_write_data_local;
   reg 			      lmi_rden_local;
   reg 			      lmi_wren_local;
   wire 		      lmi_ack_local;

   reg 			      hip_lmi_ack_in_reg;
   reg [31:0] 		      hip_lmi_data_in_reg;
   reg 			      app_lmi_read_pending;
   reg 			      app_lmi_write_pending;
   reg [20:0] 		      app_lmi_addr;
   reg [31:0]    	      app_lmi_write_data;

   reg [127:0] 		      hip_captured_tlp_hdr;

   reg 			      malf_tlp_rcvd_reg;
   reg 			      ecrc_err_reg;
   reg 			      malf_tlp_error_detected;
   reg 			      ecrc_error_detected;
   reg 			      cfg_malf_tlp_error_detected;
   reg 			      cfg_ecrc_error_detected;

   reg 			      dl_prot_err_reg;
   reg 			      fl_prot_err_reg;
   reg 			      rx_fifo_overflow_reg;
   reg 			      phy_err_reg;
   reg 			      dllp_err_reg;
   reg 			      tlp_err_reg;
   reg 			      replay_timeout_reg;
   reg 			      replay_timer_rollover_reg;

   // Pass the mask bits from user application to HIP
   assign 		      RxStMask_hip_o = RxStMask_app_i;

   // Receive-side data bridge between HIP and user application
   altpcied_sriov_rx_data_bridge #
     (
      .port_width_data_hwtcl  (port_width_data_hwtcl),  
      .port_width_be_hwtcl    (port_width_be_hwtcl),
      .multiple_packets_per_cycle_hwtcl (multiple_packets_per_cycle_hwtcl)
      )    
     altpcied_sriov_rx_data_bridge_inst 
       (
	.Clk_i            (Clk_i),
        .Rstn_i           (Rstn_i),
       
	// RX Streaming Interface to HIP 
        .RxStSop_hip_i    (RxStSop_hip_i),
        .RxStEop_hip_i    (RxStEop_hip_i),
        .RxStErr_hip_i    (RxStErr_hip_i),
        .RxStData_hip_i   (RxStData_hip_i),
        .RxStValid_hip_i  (RxStValid_hip_i),
        .RxStEmpty_hip_i  (RxStEmpty_hip_i),
        .RxStReady_hip_o  (RxStReady_hip_o),
        .RxStParity_hip_i (RxStParity_hip_i),

        // RX Streaming Interface to BAR check module
        .RxStSop_barcheck_o    (RxStSop_barcheck),
        .RxStEop_barcheck_o    (RxStEop_barcheck),
        .RxStErr_barcheck_o    (RxStErr_barcheck),
        .RxStData_barcheck_o   (RxStData_barcheck),
        .RxStValid_barcheck_o  (RxStValid_barcheck),
        .RxStEmpty_barcheck_o  (RxStEmpty_barcheck),
        .RxStReady_barcheck_i  (RxStReady_barcheck),
        .RxStParity_barcheck_o (RxStParity_barcheck),

	// TLP Interface to config module
	.RxCfgData_o      (RxCfgData),
	.RxCfgSop_o       (RxCfgSop),
	.RxCfgEop_o       (RxCfgEop),
	.RxCfgValid_o     (RxCfgValid),
	.RxCfgErr_o       (RxCfgErr),
	.RxCfgReady_i     (RxCfgReady)
	);
   

   // Transmit-side data bridge between HIP and user application
   altpcied_sriov_tx_data_bridge #
     (
      .port_width_data_hwtcl  (port_width_data_hwtcl),  
      .port_width_be_hwtcl    (port_width_be_hwtcl),
      .multiple_packets_per_cycle_hwtcl (multiple_packets_per_cycle_hwtcl)
      )    
     altpcied_sriov_tx_data_bridge_inst 
       (
	.Clk_i            (Clk_i),
        .Rstn_i           (Rstn_i),
       
	// TX Streaming Interface to HIP 
        .TxStSop_hip_o    (TxStSop_hip_o),
        .TxStEop_hip_o    (TxStEop_hip_o),
        .TxStErr_hip_o    (TxStErr_hip_o),
        .TxStData_hip_o   (TxStData_hip_o),
        .TxStValid_hip_o  (TxStValid_hip_o),
        .TxStEmpty_hip_o  (TxStEmpty_hip_o),
        .TxStReady_hip_i  (TxStReady_hip_i),
        .TxStParity_hip_o (TxStParity_hip_o),

        // TX Streaming data from app layer
        .TxStSop_app_i    (TxStSop_app_i),
        .TxStEop_app_i    (TxStEop_app_i),
        .TxStErr_app_i    (TxStErr_app_i),
        .TxStData_app_i   (TxStData_app_i),
        .TxStValid_app_i  (TxStValid_app_i),
        .TxStEmpty_app_i  (TxStEmpty_app_i),
        .TxStReady_app_o  (TxStReady_app_o),
        .TxStParity_app_i (TxStParity_app_i),

	// Completions from Config module
	.cfg_req_to_send_compl_i(CfgReq_send_compl),
	.cfg_compl_hdr_i        (CfgReq_send_compl_hdr),
	.cfg_compl_data_i       (CfgReq_send_compl_data),
	.cfg_compl_sent_ack_o   (CfgReq_send_compl_ack),

	// Interrupt and Error messages from Config module
	.cfg_req_to_send_msg_i  (CfgReq_send_msg),
	.cfg_msg_hdr_i          (CfgReq_msg_hdr),
	.cfg_msg_data_i         (CfgReq_msg_data),
	.cfg_msg_data_valid_i   (CfgReq_msg_data_valid),
	.cfg_msg_sent_ack_o     (CfgReq_msg_sent_ack),

	// Completions from BAR check module
        .bar_check_send_compl_i(bar_check_send_compl),
        .bar_check_compl_hdr_i(bar_check_compl_hdr),
	.bar_check_compl_sent_ack_o(bar_check_compl_sent_ack),

	// Error reporting signals to Config module
	.poisoned_req_sent_pf_o    (poisoned_req_sent_pf),
	.poisoned_req_sent_vf_o    (poisoned_req_sent_vf),
	.poisoned_req_sent_vf_any_o()
	);

   // Config TLP processing module
   altpcied_sriov_cfg_dataflow #
     (
      .port_width_data_hwtcl  (port_width_data_hwtcl),  
      .port_width_be_hwtcl    (port_width_be_hwtcl),
      .multiple_packets_per_cycle_hwtcl (multiple_packets_per_cycle_hwtcl),
      .SIG_TEST_EN(SIG_TEST_EN),
       // Device-Level Parameters				      
      .DEVICE_ID(DEVICE_ID),
      .VENDOR_ID(VENDOR_ID),
      .SUBSYS_ID(SUBSYS_ID),
      .SUBVENDOR_ID(SUBVENDOR_ID),
      .CLASS_CODE(CLASS_CODE),
      .SUBCLASS_CODE(SUBCLASS_CODE),
      .PCI_PROG_INTFC_BYTE(PCI_PROG_INTFC_BYTE),
      .REVISION_CODE(REVISION_CODE),
      .VF_DEVICE_ID(VF_DEVICE_ID),
      .SLOT_CLK_CONFIGURATION(SLOT_CLK_CONFIGURATION),
      .PM_NO_SOFT_RESET(PM_NO_SOFT_RESET),
      .AER_CAP_PRESENT(AER_CAP_PRESENT),
      .MAX_PAYLOAD_SIZE(MAX_PAYLOAD_SIZE),
      .AER_SURPRISE_DOWN_REPORTING_CAPABLE(AER_SURPRISE_DOWN_REPORTING_CAPABLE),
      .EXTENDED_TAG_SUPPORT(EXTENDED_TAG_SUPPORT),
      .L0S_LATENCY(L0S_LATENCY),
      .L1_LATENCY(L1_LATENCY),
      .L0S_EXIT_LATENCY(L0S_EXIT_LATENCY),
      .L1_EXIT_LATENCY(L1_EXIT_LATENCY),
      .ASPM_L0S_SUPPORT(ASPM_L0S_SUPPORT),
      .ASPM_L1_SUPPORT(ASPM_L1_SUPPORT),
      .FLR_SUPPORT(FLR_SUPPORT),
      .COMPLETION_TIMEOUT_RANGES_SUPPORTED(COMPLETION_TIMEOUT_RANGES_SUPPORTED),
      .COMPLETION_TIMEOUT_DISABLE_SUPPORT(COMPLETION_TIMEOUT_DISABLE_SUPPORT),
      .ECRC_GENERATION_SUPPORT(ECRC_GENERATION_SUPPORT),
      .ECRC_CHECK_SUPPORT(ECRC_CHECK_SUPPORT),
      .RELAXED_ORDER_SUPPORT(RELAXED_ORDER_SUPPORT),
      .SYSTEM_PAGE_SIZES_SUPPORTED(SYSTEM_PAGE_SIZES_SUPPORTED),
       // INTX pin and line settings
      .F0_INTR_PIN(F0_INTR_PIN),
      .F0_INTR_LINE(F0_INTR_LINE),
      // MSI parameters
      .MSI_CAP_PRESENT(MSI_CAP_PRESENT),
      .MSI_MULTI_MSG_CAPABLE(MSI_MULTI_MSG_CAPABLE),
      .MSI_64BIT_CAPABLE(MSI_64BIT_CAPABLE),
      .VF_MSI_CAP_PRESENT(VF_MSI_CAP_PRESENT),
      .VF_MSI_64BIT_CAPABLE(VF_MSI_64BIT_CAPABLE),
      .VF_MSI_MULTI_MSG_CAPABLE (VF_MSI_MULTI_MSG_CAPABLE),
      // MSIX parameters
      .MSIX_CAP_PRESENT(MSIX_CAP_PRESENT),
      .MSIX_TBL_SIZE(MSIX_TBL_SIZE),
      .MSIX_TBL_OFFSET(MSIX_TBL_OFFSET),
      .MSIX_TBL_BIR(MSIX_TBL_BIR),
      .MSIX_PBA_BIR(MSIX_PBA_BIR),
      .MSIX_PBA_OFFSET(MSIX_PBA_OFFSET),
      .VF_MSIX_CAP_PRESENT(VF_MSIX_CAP_PRESENT),
      .VF_MSIX_TBL_SIZE(VF_MSIX_TBL_SIZE),
      .VF_MSIX_TBL_OFFSET(VF_MSIX_TBL_OFFSET),
      .VF_MSIX_TBL_BIR(VF_MSIX_TBL_BIR),
      .VF_MSIX_PBA_OFFSET(VF_MSIX_PBA_OFFSET),
      .VF_MSIX_PBA_BIR(VF_MSIX_PBA_BIR),
      // PF BAR parameters
      .F0_BAR0_PRESENT        ( PF_BAR0_PRESENT ) ,  
      .F0_BAR1_PRESENT        ( PF_BAR1_PRESENT ) ,  
      .F0_BAR2_PRESENT        ( PF_BAR2_PRESENT ) ,  
      .F0_BAR3_PRESENT        ( PF_BAR3_PRESENT ) ,  
      .F0_BAR0_TYPE           ( PF_BAR0_TYPE ),
      .F0_BAR2_TYPE           ( PF_BAR2_TYPE ),
      .F0_BAR0_PREFETCHABLE   ( PF_BAR0_PREFETCHABLE ),
      .F0_BAR1_PREFETCHABLE   ( PF_BAR1_PREFETCHABLE ),
      .F0_BAR2_PREFETCHABLE   ( PF_BAR2_PREFETCHABLE ),
      .F0_BAR3_PREFETCHABLE   ( PF_BAR3_PREFETCHABLE ),
       // VF BAR parameters
      .F0_VF_BAR0_PRESENT     (VF_BAR0_PRESENT),
      .F0_VF_BAR1_PRESENT     (VF_BAR1_PRESENT),
      .F0_VF_BAR2_PRESENT     (VF_BAR2_PRESENT),
      .F0_VF_BAR3_PRESENT     (VF_BAR3_PRESENT),
      .F0_VF_BAR0_TYPE        (VF_BAR0_TYPE),
      .F0_VF_BAR2_TYPE        (VF_BAR2_TYPE),
      .F0_VF_BAR0_PREFETCHABLE(VF_BAR0_PREFETCHABLE),
      .F0_VF_BAR1_PREFETCHABLE(VF_BAR1_PREFETCHABLE),
      .F0_VF_BAR2_PREFETCHABLE(VF_BAR2_PREFETCHABLE),
      .F0_VF_BAR3_PREFETCHABLE(VF_BAR3_PREFETCHABLE)
      ) 
     altpcied_sriov_cfg_dataflow_inst
       (
	.Clk_i            (Clk_i),
        .Rstn_i           (Rstn_i),
	.PowerOnRstn_i    (PowerOnRstn_i),

	// BAR apertures
        .f0_bar0_aperture_i     (f0_bar0_aperture_i),
	.f0_bar1_aperture_i     (f0_bar1_aperture_i),
        .f0_bar2_aperture_i     (f0_bar2_aperture_i),
        .f0_bar3_aperture_i     (f0_bar3_aperture_i),
	.f0_vf_bar0_aperture_i  (f0_vf_bar0_aperture_i),
	.f0_vf_bar1_aperture_i  (f0_vf_bar1_aperture_i),
	.f0_vf_bar2_aperture_i  (f0_vf_bar2_aperture_i),
	.f0_vf_bar3_aperture_i  (f0_vf_bar3_aperture_i),
	.f0_vf_bar0_aperture_bitmask_i(f0_vf_bar0_aperture_bitmask_i), 
	.f0_vf_bar1_aperture_bitmask_i(f0_vf_bar1_aperture_bitmask_i), 
	.f0_vf_bar2_aperture_bitmask_i(f0_vf_bar2_aperture_bitmask_i), 
	.f0_vf_bar3_aperture_bitmask_i(f0_vf_bar3_aperture_bitmask_i), 
	// BAR settings to BAR check module
	.f0_bar0_o              (f0_bar0),
	.f0_bar1_o              (f0_bar1),
	.f0_bar2_o              (f0_bar2),
	.f0_bar3_o              (f0_bar3),
	// VF BAR base and limit settings
	.f0_vf_bar0_base_o      (f0_vf_bar0_base),
	.f0_vf_bar1_base_o      (f0_vf_bar1_base),
	.f0_vf_bar2_base_o      (f0_vf_bar2_base),
	.f0_vf_bar3_base_o      (f0_vf_bar3_base),
	.f0_vf_bar0_limit_o      (f0_vf_bar0_limit),
	.f0_vf_bar1_limit_o      (f0_vf_bar1_limit),
	.f0_vf_bar2_limit_o      (f0_vf_bar2_limit),
	.f0_vf_bar3_limit_o      (f0_vf_bar3_limit),
 	.vf_bar0_aperture_for_barcheck_o(vf_bar0_aperture_for_barcheck),
 	.vf_bar1_aperture_for_barcheck_o(vf_bar1_aperture_for_barcheck),
 	.vf_bar2_aperture_for_barcheck_o(vf_bar2_aperture_for_barcheck),
 	.vf_bar3_aperture_for_barcheck_o(vf_bar3_aperture_for_barcheck),
	.vf_bars_ready_o         (vf_bars_ready),

        // Data from RX bridge
	.Data_i                 (RxCfgData),
	.Sop_i                  (RxCfgSop),
	.Eop_i                  (RxCfgEop),
	.DataValid_i            (RxCfgValid),
	.Err_i                  (RxCfgErr),
	.Ready_o                (RxCfgReady),

	// Completions to TX bridge
	.req_to_send_compl_o    (CfgReq_send_compl),
	.compl_hdr_o            (CfgReq_send_compl_hdr),
	.compl_data_o           (CfgReq_send_compl_data),
	.compl_sent_ack_i       (CfgReq_send_compl_ack),

	// Interrupt and Error messages from Config module
	.req_to_send_msg_o      (CfgReq_send_msg),
	.msg_hdr_o              (CfgReq_msg_hdr),
	.msg_data_o             (CfgReq_msg_data),
	.msg_data_valid_o       (CfgReq_msg_data_valid),
	.msg_sent_ack_i         (CfgReq_msg_sent_ack),

	//###################################################################################
	// LMI interface
	//###################################################################################
        .lmi_addr_i             (lmi_addr_local),
        .lmi_write_data_i       (lmi_write_data_local), 
        .lmi_rden_i             (lmi_rden_local),
        .lmi_wren_i             (lmi_wren_local),
        .lmi_ack_o              (lmi_ack_local),
	.lmi_read_data_o        (lmi_read_data_local),   
	//###################################################################################
	// Status and error inputs from HIP
	//###################################################################################
	.current_speed_i        (current_speed_i),
	.current_deemph_i       (current_deemph_i),
	.lane_active_i          (lane_active_i),
	.dl_prot_err_i          (dl_prot_err_reg),
	.fl_prot_err_i          (fl_prot_err_reg),
	.rx_fifo_overflow_i     (rx_fifo_overflow_reg),
	.malf_tlp_rcvd_i        (cfg_malf_tlp_error_detected),
	.ecrc_err_i             (cfg_ecrc_error_detected),
	.phy_err_i              (phy_err_reg),
	.dllp_err_i             (dllp_err_reg),
	.tlp_err_i              (tlp_err_reg),
	.replay_timeout_i       (replay_timeout_reg),
	.replay_timer_rollover_i(replay_timer_rollover_reg),
	.link_control2_reg_reset_enter_compl_i(link_control2_reg_reset_enter_compl_i),
	.link_control2_reg_reset_tx_margin_i  (link_control2_reg_reset_tx_margin_i),
	.lane_error_detected_i  (lane_error_detected_i),
	.link_equalization_req_i(link_equalization_req_i),
	.link_equalization_complete_i(link_equalization_complete_i),
	.link_eq_phase1_successful_i(link_eq_phase1_successful_i),
	.link_eq_phase2_successful_i(link_eq_phase2_successful_i),
	.link_eq_phase3_successful_i(link_eq_phase3_successful_i),
	.ltssm_state_i          (ltssm_state_i),  
	.hip_captured_tlp_hdr_i (hip_captured_tlp_hdr),
	//###################################################################################
	// Config register outputs to HIP
	//###################################################################################
	.f0_link_control2_reg_o        (f0_link_control2_reg_o),
	.f0_link_control_reg_ext_synch_o(f0_link_control_reg_ext_synch_o),
	.f0_link_control_reg_com_clk_conf_o(f0_link_control_reg_com_clk_conf_o),
	.device_control_reg_max_payload_size_o(device_control_reg_max_payload_size_o),
	.device_control_reg_read_req_size_o(device_control_reg_read_req_size_o),
	.f0_link_control_reg_aspm_ctl_o (f0_link_control_reg_aspm_ctl_o),
	.f0_ecrc_gen_enable_o           (f0_ecrc_gen_enable_o),
	.f0_ecrc_chk_enable_o           (f0_ecrc_chk_enable_o),
	//========================================================================
	// Interrupt interface
	//======================================================================== 	
	.int_sts_a_i            (int_sts_a_i),
	.int_sts_b_i            (int_sts_b_i),
	.int_sts_c_i            (int_sts_c_i),
	.int_sts_d_i            (int_sts_d_i),
	.int_sts_fn_i           (int_sts_fn_i),
	.int_ack_o              (int_ack_o),
	.msi_req_i              (msi_req_i),
	.msi_ack_o              (msi_ack_o),
	.msi_req_fn_i           (msi_req_fn_i),
	.msi_num_i              (msi_num_i),
	.msi_tc_i               (msi_tc_i),
	.msi_en_pf_o            (msi_en_pf_o),
	.msi_mult_msg_en_pf_o   (msi_mult_msg_en_pf_o),
	.msi_en_vf_o            (msi_en_vf_o),
	.msi_mult_msg_en_vf_o   (msi_mult_msg_en_vf_o),
        .msix_en_pf_o           (msix_en_pf_o),
 	.msix_fn_mask_pf_o      (msix_fn_mask_pf_o),
        .msix_en_vf_o           (msix_en_vf_o),
 	.msix_fn_mask_vf_o      (msix_fn_mask_vf_o),
	.interrupt_pending_i    (interrupt_pending_i),
	.intx_disable_o         (intx_disable_o),
	//======================================================================== 	
	// Status and Error input from user application
	//======================================================================== 	
	.compl_timeout_with_recovery_i   (compl_timeout_with_recovery_i),
	.compl_timeout_without_recovery_i(compl_timeout_without_recovery_i),
	.ca_sent_i                       (ca_sent_i),
	.unexp_compl_rcvd_i              (unexp_compl_rcvd_i),
	.unsupp_p_req_rcvd_i             (unsupp_p_req_rcvd_i),
	.unsupp_np_req_rcvd_i            (unsupp_np_req_rcvd_i),
        .error_reporting_fn_i            (error_reporting_fn_i),
	.trans_pending_pf_i              (trans_pending_pf_i),
	.trans_pending_vf_i              (trans_pending_vf_i),
	.app_header_logging_en_i         (app_header_logging_en_i),
	.app_log_hdr_i                   (app_log_hdr_i),
	.flr_active_pf_o                 (flr_active_pf_o),
	.flr_completed_pf_i              (flr_completed_pf_i),
	.flr_active_vf_o                 (flr_active_vf_o),
	.flr_completed_vf_i              (flr_completed_vf_i),
	.rx_compl_buffer_overflow_i      (RxStBuff_Overflow_i),

	// Mem space enables of Functions
	.mem_space_en_pf_o         (mem_space_en_pf_o),
	.mem_space_en_vf_o         (mem_space_en_vf_o),
	.bus_master_en_pf_o        (bus_master_en_pf_o),
	.bus_master_en_vf_o        (bus_master_en_vf_o),
	// Bus and Device numbers of Functions
	.f0_bus_num_o           (bus_num_f0_o),
        // Number of enabled VFs
        .num_vfs_o              (num_vfs_o),
	// Enables for VFs
	.vf_enable_o            (vf_enable),
	// Error reporting signals from BAR check module
	.bar_check_unsupp_p_req_rcvd_i(bar_check_unsupp_p_req_rcvd),
	.bar_check_unsupp_np_req_rcvd_i(bar_check_unsupp_np_req_rcvd),
	.bar_check_poisoned_req_rcvd_pf_i(bar_check_poisoned_req_rcvd_pf),
	.bar_check_poisoned_req_rcvd_vf_i(bar_check_poisoned_req_rcvd_vf),
	.bar_check_poisoned_req_rcvd_vf_any_i(bar_check_poisoned_req_rcvd_vf_any),
	.bar_check_poisoned_compl_rcvd_pf_i(bar_check_poisoned_compl_rcvd_pf),
	.bar_check_poisoned_compl_rcvd_vf_i(bar_check_poisoned_compl_rcvd_vf),
	.bar_check_poisoned_compl_rcvd_vf_any_i(bar_check_poisoned_compl_rcvd_vf_any),
	.bar_check_captured_header_i(bar_check_captured_header),
	.bar_check_ur_compl_rcvd_pf_i(bar_check_ur_compl_rcvd_pf),
	.bar_check_ur_compl_rcvd_vf_i(bar_check_ur_compl_rcvd_vf),
	.bar_check_ca_compl_rcvd_pf_i(bar_check_ca_compl_rcvd_pf),
	.bar_check_ca_compl_rcvd_vf_i(bar_check_ca_compl_rcvd_vf),
	// Error reporting signals from TX bridge
	.poisoned_req_sent_pf_i    (poisoned_req_sent_pf),
	.poisoned_req_sent_vf_i    (poisoned_req_sent_vf)
	);

   // BAR check module
   altpcied_sriov_rx_bar_check #
     (
      .port_width_data_hwtcl  (port_width_data_hwtcl),  
      .port_width_be_hwtcl    (port_width_be_hwtcl),
      .multiple_packets_per_cycle_hwtcl (multiple_packets_per_cycle_hwtcl),
      .DROP_POISONED_REQ      (DROP_POISONED_REQ),
      .DROP_POISONED_COMPL    (DROP_POISONED_COMPL),
      .VF_COUNT               (VF_COUNT),
      .F0_BAR0_PRESENT        ( PF_BAR0_PRESENT ) ,  
      .F0_BAR1_PRESENT        ( PF_BAR1_PRESENT ) ,  
      .F0_BAR2_PRESENT        ( PF_BAR2_PRESENT ) ,  
      .F0_BAR3_PRESENT        ( PF_BAR3_PRESENT ) ,  
      .F0_BAR0_TYPE           ( PF_BAR0_TYPE ),
      .F0_BAR2_TYPE           ( PF_BAR2_TYPE ),
       // VF BAR parameters
      .F0_VF_BAR0_PRESENT     (VF_BAR0_PRESENT),
      .F0_VF_BAR1_PRESENT     (VF_BAR1_PRESENT),
      .F0_VF_BAR2_PRESENT     (VF_BAR2_PRESENT),
      .F0_VF_BAR3_PRESENT     (VF_BAR3_PRESENT),
      .F0_VF_BAR0_TYPE        (VF_BAR0_TYPE),
      .F0_VF_BAR2_TYPE        (VF_BAR2_TYPE)
      )    
     altpcied_sriov_rx_bar_check_inst
       (
	.Clk_i            (Clk_i),
        .Rstn_i           (Rstn_i),

	// BAR apertures
        .f0_bar0_aperture_i     (f0_bar0_aperture_i),
	.f0_bar1_aperture_i     (f0_bar1_aperture_i),
        .f0_bar2_aperture_i     (f0_bar2_aperture_i),
        .f0_bar3_aperture_i     (f0_bar3_aperture_i),
	.f0_vf_bar0_aperture_i  (vf_bar0_aperture_for_barcheck),
	.f0_vf_bar1_aperture_i  (vf_bar1_aperture_for_barcheck),
	.f0_vf_bar2_aperture_i  (vf_bar2_aperture_for_barcheck),
	.f0_vf_bar3_aperture_i  (vf_bar3_aperture_for_barcheck),
	// BAR settings from Functions
	.f0_bar0_i              (f0_bar0),
	.f0_bar1_i              (f0_bar1),
	.f0_bar2_i              (f0_bar2),
	.f0_bar3_i              (f0_bar3),
	// VF BAR base and limit settings
	.f0_vf_bar0_base_i      (f0_vf_bar0_base),
	.f0_vf_bar1_base_i      (f0_vf_bar1_base),
	.f0_vf_bar2_base_i      (f0_vf_bar2_base),
	.f0_vf_bar3_base_i      (f0_vf_bar3_base),
	.f0_vf_bar0_limit_i      (f0_vf_bar0_limit),
	.f0_vf_bar1_limit_i      (f0_vf_bar1_limit),
	.f0_vf_bar2_limit_i      (f0_vf_bar2_limit),
	.f0_vf_bar3_limit_i      (f0_vf_bar3_limit),
	.vf_bars_ready_i         (vf_bars_ready),
        // Data from HIP
        .Sop_i            (RxStSop_barcheck),
        .Eop_i            (RxStEop_barcheck),
        .Err_i            (RxStErr_barcheck),
        .Data_i           (RxStData_barcheck),
        .DataValid_i      (RxStValid_barcheck),
        .Empty_i          (RxStEmpty_barcheck),
        .Ready_o          (RxStReady_barcheck),
        .Parity_i         (RxStParity_barcheck),

	// Streaming data to user application
        .RxStSop_app_o    (RxStSop_app_o),
        .RxStEop_app_o    (RxStEop_app_o),
        .RxStErr_app_o    (RxStErr_app_o),
        .RxStData_app_o   (RxStData_app_o),
        .RxStValid_app_o  (RxStValid_app_o),
        .RxStEmpty_app_o  (RxStEmpty_app_o),
        .RxStReady_app_i  (RxStReady_app_i),
        .RxStParity_app_o (RxStParity_app_o),
        .rx_st_bar_hit_tlp0_o(rx_st_bar_hit_tlp0_o),
        .rx_st_bar_hit_fn_tlp0_o(rx_st_bar_hit_fn_tlp0_o),
        .rx_st_bar_hit_tlp1_o(rx_st_bar_hit_tlp1_o),
        .rx_st_bar_hit_fn_tlp1_o(rx_st_bar_hit_fn_tlp1_o),

	// Completions to TX streaming interface
        .send_ur_compl_o   (bar_check_send_compl),
        .compl_hdr_o       (bar_check_compl_hdr),
	.ur_sent_ack_i     (bar_check_compl_sent_ack),
	// Mem space enables from Functions
	.f0_mem_sp_en_i         (mem_space_en_pf_o),
	// Bus and Device numbers from Functions
	.f0_bus_num_i           (bus_num_f0_o),
	// Enables for VFs
	.vf_enable_i            (vf_enable),
	// Error reporting signals to config module
	.unsupp_p_req_rcvd_o    (bar_check_unsupp_p_req_rcvd),
	.unsupp_np_req_rcvd_o   (bar_check_unsupp_np_req_rcvd),
	.poisoned_req_rcvd_pf_o (bar_check_poisoned_req_rcvd_pf),
	.poisoned_req_rcvd_vf_o (bar_check_poisoned_req_rcvd_vf),
	.poisoned_req_rcvd_vf_any_o(bar_check_poisoned_req_rcvd_any_vf),
	.poisoned_compl_rcvd_pf_o(bar_check_poisoned_compl_rcvd_pf),
	.poisoned_compl_rcvd_vf_o(bar_check_poisoned_compl_rcvd_vf),
	.poisoned_compl_rcvd_vf_any_o(bar_check_poisoned_compl_rcvd_vf_any),
	.ur_compl_rcvd_pf_o     (bar_check_ur_compl_rcvd_pf),
	.ur_compl_rcvd_vf_o     (bar_check_ur_compl_rcvd_vf),
	.ca_compl_rcvd_pf_o     (bar_check_ca_compl_rcvd_pf),
	.ca_compl_rcvd_vf_o     (bar_check_ca_compl_rcvd_vf),
	.captured_header_o      (bar_check_captured_header)
	);


   // Register error status inputs from HIP
   always @(posedge Clk_i or negedge Rstn_i) 
     if (~Rstn_i)
       begin
	  dl_prot_err_reg <= 1'b0;
	  fl_prot_err_reg <= 1'b0;
	  rx_fifo_overflow_reg <= 1'b0;
	  phy_err_reg <= 1'b0;
	  dllp_err_reg <= 1'b0;
	  tlp_err_reg <= 1'b0;
	  replay_timeout_reg <= 1'b0;
	  replay_timer_rollover_reg <= 1'b0;
       end // if (~Rstn_i)
     else
       begin
	  dl_prot_err_reg <= dl_prot_err_i;
	  fl_prot_err_reg <= fl_prot_err_i;
	  rx_fifo_overflow_reg <= rx_fifo_overflow_i;
	  phy_err_reg <= phy_err_i;
	  dllp_err_reg <= dllp_err_i;
	  tlp_err_reg <= tlp_err_i;
	  replay_timeout_reg <= replay_timeout_i;
	  replay_timer_rollover_reg <= replay_timer_rollover_i;
       end // else: !if(~Rstn_i)

   // LMI Request Forwarding State Machine
   // Forward an LMI request from the user to either the HIP or the local config space,
   // and return data and ack.

   assign 		      lmi_addr_hip_o = lmi_addr_reg[11:0];
   assign 		      lmi_din_hip_o = lmi_data_reg[31:0]; // Write data

   assign 		      lmi_addr_local = lmi_addr_reg[20:0];
   assign 		      lmi_write_data_local = lmi_data_reg[31:0];

   always @(posedge Clk_i or negedge Rstn_i) 
     if (~Rstn_i)
       begin
	  app_lmi_read_pending <= 1'b0;
	  app_lmi_write_pending <= 1'b0;
	  app_lmi_addr <= 21'd0;
	  app_lmi_write_data <= 32'd0;
       end
     else
       begin
	  app_lmi_read_pending <= lmi_rden_app_i;
	  app_lmi_write_pending <= lmi_wren_app_i;
	  app_lmi_addr <= lmi_addr_app_i;
	  app_lmi_write_data <= lmi_din_app_i;
       end

   // Register LMI read data and ack from HIP
   always @(posedge Clk_i or negedge Rstn_i) 
     if (~Rstn_i)
       begin
	  hip_lmi_ack_in_reg <= 1'b0;
	  hip_lmi_data_in_reg <= 32'b0;
       end
     else
       begin
	  hip_lmi_ack_in_reg <= lmi_ack_hip_i;
	  hip_lmi_data_in_reg <= lmi_dout_hip_i;
       end

   always @(posedge Clk_i or negedge Rstn_i) 
     if (~Rstn_i)
       begin
          lmi_ack_app_o <= 1'b0;
          lmi_addr_reg <= 21'd0;
	  lmi_data_reg <= 32'd0;

          lmi_rden_hip_o <= 1'b0;
          lmi_wren_hip_o <= 1'b0;

          lmi_rden_local <= 1'b0;
          lmi_wren_local <= 1'b0;

	  lmi_dout_app_o <= 32'd0;
	  lmi_ack_app_o <= 1'b0;

	  hip_captured_tlp_hdr <= 128'd0;

	  lmi_state <= LMI_IDLE;

       end
     else
       case(lmi_state)
	 LMI_IDLE:
	   begin
              lmi_ack_app_o <= 1'b0;
	      if (malf_tlp_error_detected | ecrc_error_detected)
		begin
		   // Read TLP header from HIP through LMI
		   lmi_addr_reg <= {9'd0, HIP_HEADER_LOG_REG_ADDR};
		   lmi_rden_hip_o <= 1'b1;
		   lmi_state <= LMI_HIP_READ_HEADER_LOG_REG_1;
		end
	      else
		begin
		   if (app_lmi_read_pending | app_lmi_write_pending)
		     lmi_addr_reg <= app_lmi_addr[20:0];
		   if (app_lmi_write_pending)
		     lmi_data_reg <= app_lmi_write_data;

		   if (app_lmi_read_pending)
		     begin
			if (~app_lmi_addr[20]) // Access to HIP register
			  begin
			     lmi_rden_hip_o <= 1'b1;
			     lmi_state <= WAIT_FOR_REMOTE_ACK;
			  end
			else
			  begin
			     // access to local config space
			     lmi_rden_local <= 1'b1;
			     lmi_state <= WAIT_FOR_LOCAL_ACK;
			  end
		     end

		   else if (app_lmi_write_pending)
		     begin
			if (~app_lmi_addr[20]) // Access to HIP register
			  begin
			     lmi_wren_hip_o <= 1'b1;
			     lmi_state <= WAIT_FOR_REMOTE_ACK;
			  end
			else
			  begin
			     // access to local config space
			     lmi_wren_local <= 1'b1;
			     lmi_state <= WAIT_FOR_LOCAL_ACK;
			  end // else: !if(~app_lmi_addr[20])
		     end // if (app_lmi_write_pending)
		end // else: !if(malf_tlp_error_detected | ecrc_error_detected)
	   end // case: LMI_IDLE
	 
	 WAIT_FOR_REMOTE_ACK:
	   begin
	      // Forward ack from HIP to user
	      if (hip_lmi_ack_in_reg)
		begin
		   lmi_rden_hip_o <= 1'b0;
		   lmi_wren_hip_o <= 1'b0;
		   lmi_dout_app_o <= hip_lmi_data_in_reg;
		   lmi_ack_app_o <= 1'b1;
		   lmi_state <= LMI_WAIT_CYCLE;
		end
	   end // case: WAIT_FOR_REMOTE_ACK
	 
	 WAIT_FOR_LOCAL_ACK:
	   // Wait for ack from Config module and send it to user
	   begin
	      if (lmi_ack_local)
		begin
		   lmi_rden_local <= 1'b0;
		   lmi_wren_local <= 1'b0;
		   lmi_dout_app_o <= lmi_read_data_local;
		   lmi_ack_app_o <= 1'b1;
		   lmi_state <= LMI_WAIT_CYCLE;
		end
	   end // case: WAIT_FOR_LCAL_ACK

	 LMI_HIP_READ_HEADER_LOG_REG_1:
	   begin
	      lmi_rden_hip_o <= 1'b0;
	      // Save first Dword of header
	      hip_captured_tlp_hdr[127:96] <= {hip_lmi_data_in_reg[7:0], hip_lmi_data_in_reg[15:8],
					       hip_lmi_data_in_reg[23:16], hip_lmi_data_in_reg[31:24]};
	      if (hip_lmi_ack_in_reg)
		lmi_state <= LMI_HIP_READ_HEADER_LOG_REG_2;
	   end
	 
	 LMI_HIP_READ_HEADER_LOG_REG_2:
	   begin
	      // Initiate read for second Dword of header
	      if (~hip_lmi_ack_in_reg)
		begin
		   lmi_addr_reg <= {9'd0, HIP_HEADER_LOG_REG_ADDR+4};
		   lmi_rden_hip_o <= 1'b1;
		   lmi_state <= LMI_HIP_READ_HEADER_LOG_REG_3;
		end
	   end

	 LMI_HIP_READ_HEADER_LOG_REG_3:
	   begin
	      lmi_rden_hip_o <= 1'b0;
	      // Save second Dword of header
	      hip_captured_tlp_hdr[95:64] <= {hip_lmi_data_in_reg[7:0], hip_lmi_data_in_reg[15:8],
					      hip_lmi_data_in_reg[23:16], hip_lmi_data_in_reg[31:24]};
	      if (hip_lmi_ack_in_reg)
		lmi_state <= LMI_HIP_READ_HEADER_LOG_REG_4;
	   end

	 LMI_HIP_READ_HEADER_LOG_REG_4:
	   begin
	      // Initiate read for third Dword of header
	      if (~hip_lmi_ack_in_reg)
		begin
		   lmi_addr_reg <= {9'd0, HIP_HEADER_LOG_REG_ADDR+8};
		   lmi_rden_hip_o <= 1'b1;
		   lmi_state <= LMI_HIP_READ_HEADER_LOG_REG_5;
		end
	   end

	 LMI_HIP_READ_HEADER_LOG_REG_5:
	   begin
	      lmi_rden_hip_o <= 1'b0;
	      // Save third Dword of header
	      hip_captured_tlp_hdr[63:32] <= {hip_lmi_data_in_reg[7:0], hip_lmi_data_in_reg[15:8],
					      hip_lmi_data_in_reg[23:16], hip_lmi_data_in_reg[31:24]};
	      if (hip_lmi_ack_in_reg)
		lmi_state <= LMI_HIP_READ_HEADER_LOG_REG_6;
	   end

	 LMI_HIP_READ_HEADER_LOG_REG_6:
	   begin
	      // Initiate read for fourth Dword of header
	      if (~hip_lmi_ack_in_reg)
		begin
		   lmi_addr_reg <= {9'd0, HIP_HEADER_LOG_REG_ADDR+12};
		   lmi_rden_hip_o <= 1'b1;
		   lmi_state <= LMI_HIP_READ_HEADER_LOG_REG_7;
		end
	   end

	 LMI_HIP_READ_HEADER_LOG_REG_7:
	   begin
	      lmi_rden_hip_o <= 1'b0;
	      // Save fourth Dword of header
	      hip_captured_tlp_hdr[31:0] <= {hip_lmi_data_in_reg[7:0], hip_lmi_data_in_reg[15:8],
					     hip_lmi_data_in_reg[23:16], hip_lmi_data_in_reg[31:24]};
	      if (hip_lmi_ack_in_reg)
		lmi_state <= LMI_HIP_READ_HEADER_LOG_REG_8;
	   end
	 
	 LMI_HIP_READ_HEADER_LOG_REG_8:
	   // Clear AER Uncorrectable Error Status Register
	   begin
	      if (~hip_lmi_ack_in_reg)
		begin
		   lmi_addr_reg <= {9'd0, HIP_AER_UNCORR_STATUS_REG_ADDR};
		   lmi_data_reg <= 32'hffff_ffff;
		   lmi_wren_hip_o <= 1'b1;
		   lmi_state <= LMI_HIP_READ_HEADER_LOG_REG_9;
		end
	   end

	 LMI_HIP_READ_HEADER_LOG_REG_9:
	   begin
	      lmi_wren_hip_o <= 1'b0;
	      if (hip_lmi_ack_in_reg)
		begin
		   lmi_state <= LMI_IDLE;
		end
	   end

	 // Wait for app to de-assert request before sampling next request
	 LMI_WAIT_CYCLE:
	   begin
	      lmi_dout_app_o <= 32'd0;
	      lmi_ack_app_o <= 1'b0;
	      if (~app_lmi_read_pending & ~app_lmi_write_pending)
		lmi_state <= LMI_IDLE;
	   end
	 
	 default:
	   begin
	      lmi_rden_hip_o <= 1'b0;
	      lmi_wren_hip_o <= 1'b0;
	      lmi_rden_local <= 1'b0;
	      lmi_wren_local <= 1'b0;
	      lmi_state <= LMI_IDLE;
	   end
       endcase // case(lmi_state)

   // When HIP signals a Malformed TLP Error or ECRC Error, delay its indication to the Config module
   // until the logged TLP header is read out from the HIP.
   always @(posedge Clk_i or negedge Rstn_i) 
     if (~Rstn_i)
       begin
          malf_tlp_rcvd_reg <= 1'b0;
	  ecrc_err_reg <= 1'b0;
	  malf_tlp_error_detected <= 1'b0;
	  ecrc_error_detected <= 1'b0;
	  cfg_malf_tlp_error_detected <= 1'b0;
	  cfg_ecrc_error_detected <= 1'b0;
       end
     else
       begin
          malf_tlp_rcvd_reg <= malf_tlp_rcvd_i;
	  ecrc_err_reg <= ecrc_err_i;
	  if ((lmi_state == LMI_HIP_READ_HEADER_LOG_REG_9) &&
	      hip_lmi_ack_in_reg)
	    begin
	       cfg_malf_tlp_error_detected <= malf_tlp_error_detected;
	       cfg_ecrc_error_detected <= ecrc_error_detected;
	       malf_tlp_error_detected <= 1'b0;
	       ecrc_error_detected <= 1'b0;
	    end
	  else
	    begin
	       cfg_malf_tlp_error_detected <= 1'b0;
	       cfg_ecrc_error_detected <= 1'b0;
               if (malf_tlp_rcvd_reg)
		 malf_tlp_error_detected <= 1'b1;
	       else if (ecrc_err_reg)
		 ecrc_error_detected <= 1'b1;
	    end // else: !if((lmi_state == LMI_HIP_READ_HEADER_LOG_REG_9) &&...
       end // else: !if(~Rstn_i)

endmodule // altpcied_sriov_1pf32vf_top

