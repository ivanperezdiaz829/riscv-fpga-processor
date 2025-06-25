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


// /**
//  * Wrapper for SR-IOV Adapter with 1 PF and 32 VFs
//  */
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
// File          : altera_pcie_sv_sriov_1pf32vf.sv
// Author        : Altera Corporation
//-----------------------------------------------------------------------------
//

module altera_pcie_sv_sriov_1pf32vf #
  (
   parameter port_width_data_hwtcl               = 256, // Width of internal data path
   parameter port_width_be_hwtcl                 = 32,  // Width of byte enable bus
   parameter multiple_packets_per_cycle_hwtcl    = 0, // 0 = 1 TLP per cycle, 1 = 2 TLPs may be present in the same cycle
   parameter num_of_func_hwtcl                   = 1,
   parameter gen123_lane_rate_mode_hwtcl         = "Gen3 (8.0 Gbps)",
   parameter ast_width_hwtcl                     = "Avalon-ST 256-bit",
   parameter VF_COUNT                            = 32, 
   parameter SIG_TEST_EN                         = 1'b1, // Set this to 1 to enable PCIECV work-around 
   parameter DROP_POISONED_REQ                   = 0, // Set this to 1 to make the bridge drop Poisoned requests received from the link
   parameter DROP_POISONED_COMPL                 = 0, // Set this to 1 to make the bridge drop Poisoned Completions received from the link
   // HIP parameters
   parameter slotclkcfg_hwtcl                    = 1,
   parameter vendor_id_hwtcl                     = 4466,
   parameter device_id_hwtcl                     = 57345,
   parameter revision_id_hwtcl                   = 1,
   parameter class_code_hwtcl                    = 16711680,
   parameter subsystem_vendor_id_hwtcl           = 4466,
   parameter subsystem_device_id_hwtcl           = 57345,
   parameter no_soft_reset_hwtcl                 = "false",
   parameter use_aer_hwtcl                       = 1,
   parameter max_payload_size_hwtcl              = 256,
   parameter surprise_down_error_support_hwtcl   = 0,
   parameter extend_tag_field_hwtcl              = "false",
   parameter endpoint_l0_latency_hwtcl           = 0,
   parameter endpoint_l1_latency_hwtcl           = 0,
   parameter enable_l0s_aspm_hwtcl               = "true",
   parameter enable_l1_aspm_hwtcl                = "false",
   parameter l1_exit_latency_sameclock_hwtcl     = 0,
   parameter completion_timeout_hwtcl            =  "abcd",
   parameter enable_completion_timeout_disable_hwtcl = 1,
   parameter ecrc_check_capable_hwtcl            = 0,
   parameter ecrc_gen_capable_hwtcl              = 0,
   parameter msi_multi_message_capable_hwtcl     = 3'd4,
   parameter msi_64bit_addressing_capable_hwtcl  = "true",
   parameter msi_support_hwtcl                   = "true",
   parameter interrupt_pin_hwtcl                 = "inta",
   parameter enable_function_msix_support_hwtcl  = "false",
   parameter msix_table_size_hwtcl               = 11'h1F, // 32
   parameter msix_table_bir_hwtcl                = 0,
   parameter msix_table_offset_hwtcl             = 29'd0,
   parameter msix_pba_bir_hwtcl                  = 0,
   parameter msix_pba_offset_hwtcl               = 29'h1000,
   parameter l0_exit_latency_sameclock_hwtcl     = 6,
   parameter flr_capability_hwtcl                = "false",

  // Device-Level Parameters				      
   parameter SUBCLASS_CODE          = 8'd0,
   parameter PCI_PROG_INTFC_BYTE    = 8'd0,
   parameter VF_DEVICE_ID           = 16'hE001,
   // Config Space pointers
   parameter VF_MSI_CAP_PRESENT     = "true", // Indicates whether VFs include MSI Capability Structure
   parameter VF_MSI_64BIT_CAPABLE   = 1'b1,
   parameter VF_MSI_MULTI_MSG_CAPABLE = 3'd1,
   parameter VF_MSIX_CAP_PRESENT    = "false", // Indicates whether VFs include MSIX Capability Structure
   parameter VF_MSIX_TBL_SIZE       = 11'h1F, // 32
   parameter VF_MSIX_TBL_OFFSET     = 29'd0,
   parameter VF_MSIX_TBL_BIR        = 3'd0,
   parameter VF_MSIX_PBA_OFFSET     = 29'h1000,
   parameter VF_MSIX_PBA_BIR        = 3'd0,
   parameter RELAXED_ORDER_SUPPORT  = 1'b1, // Device supports relaxed ordering
   parameter SYSTEM_PAGE_SIZES_SUPPORTED = 32'h553, // Supported page sizes for SR-IOV
   // INTX pin and line settings
   parameter F0_INTR_LINE           = 8'hff,
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
   ) (
   // Clocks 
   input                                        pld_clk,
   // Resets
   input                                        power_on_reset_n,
   input                                        testin_zero,
   input                                        reset_status,

   input                                        pld_clk_inuse,
   //###################################################################################
   // Avalon receive Data Streaming Interface to HIP
   //###################################################################################
   input [multiple_packets_per_cycle_hwtcl:0]   rx_st_sop_hip,
   input [multiple_packets_per_cycle_hwtcl:0]   rx_st_eop_hip,
   input [multiple_packets_per_cycle_hwtcl:0]   rx_st_err_hip, 
   input [multiple_packets_per_cycle_hwtcl:0]   rx_st_valid_hip,
   input [1:0]                                  rx_st_empty_hip,
   output  wire                                 rx_st_ready_hip,
   input [port_width_data_hwtcl-1:0]            rx_st_data_hip,
   input [port_width_be_hwtcl-1  :0]            rx_st_parity_hip,
   output  wire                                 rx_st_mask_hip, 
   input                                        rxfc_cplbuf_ovf_hip,  // Signals overflow of the RX buffer in the HIP
   //###################################################################################
   // Avalon receive Data Streaming Interface from user application
   //###################################################################################
   output [multiple_packets_per_cycle_hwtcl:0]  rx_st_sop_app,
   output [multiple_packets_per_cycle_hwtcl:0]  rx_st_eop_app,
   output [multiple_packets_per_cycle_hwtcl:0]  rx_st_err_app,
   output [multiple_packets_per_cycle_hwtcl:0]  rx_st_valid_app,
   output [1:0]                                 rx_st_empty_app,
   input wire                                   rx_st_ready_app,
   output [port_width_data_hwtcl-1:0]           rx_st_data_app,
   output [port_width_be_hwtcl-1  :0]           rx_st_parity_app,
   input                                        rx_st_mask_app, 
   // BAR hit signals
   output [7:0]                                 rx_st_bar_hit_tlp0, // BAR hit information for first TLP in this cycle
   output [7:0]                                 rx_st_bar_hit_fn_tlp0, // Target Function for first TLP in this cycle
   output [7:0]                                 rx_st_bar_hit_tlp1, // BAR hit information for first TLP in this cycle
   output [7:0]                                 rx_st_bar_hit_fn_tlp1, // Target Function for second TLP in this cycle
   //###################################################################################
   // Avalon Transmit Data Streaming Interface to HIP
   //###################################################################################
   output wire  [multiple_packets_per_cycle_hwtcl:0]   tx_st_sop_hip,
   output wire  [multiple_packets_per_cycle_hwtcl:0]   tx_st_eop_hip,
   output wire  [multiple_packets_per_cycle_hwtcl:0]   tx_st_err_hip,
   output wire  [multiple_packets_per_cycle_hwtcl:0]   tx_st_valid_hip,
   output wire  [1:0]                                  tx_st_empty_hip,
   input  wire                                         tx_st_ready_hip,
   output wire  [port_width_data_hwtcl-1  : 0]         tx_st_data_hip,
   output wire  [port_width_be_hwtcl-1:0]              tx_st_parity_hip,
   //###################################################################################
   // Avalon Transmit Data Streaming Interface to user application
   //###################################################################################
   input wire  [multiple_packets_per_cycle_hwtcl:0]    tx_st_sop_app,
   input wire  [multiple_packets_per_cycle_hwtcl:0]    tx_st_eop_app,
   input wire  [multiple_packets_per_cycle_hwtcl:0]    tx_st_err_app,
   input wire  [multiple_packets_per_cycle_hwtcl:0]    tx_st_valid_app,
   input wire  [1:0]                                   tx_st_empty_app,
   output  wire                                        tx_st_ready_app,
   input wire  [port_width_data_hwtcl-1  : 0]          tx_st_data_app,
   input wire  [port_width_be_hwtcl-1:0]               tx_st_parity_app,
   //###################################################################################
   // LMI interface to HIP
   //###################################################################################
   output  [11 : 0]       lmi_addr_hip,
   output  [31 : 0]       lmi_din_hip,
   output                 lmi_rden_hip,
   output                 lmi_wren_hip,
   input                  lmi_ack_hip,
   input [31 : 0]         lmi_dout_hip,
   //###################################################################################
   // LMI interface to user application
   //###################################################################################
   input  [11 : 0]        lmi_addr_app, // [11:0] = address
   input  [8 : 0]         lmi_func_app, // [7:0] = Function Number, 
                                        // [8] = 0 => access to Hard IP register  
                                        // [8] = 1 => access to 2-Function config space
   input  [31 : 0]        lmi_din_app,
   input                  lmi_rden_app,
   input                  lmi_wren_app,
   output                 lmi_ack_app,
   output [31 : 0]        lmi_dout_app,
   //###################################################################################
   // Status signals from HIP
   // These are passed through to the user application unmodified.
   //###################################################################################
    input                 derr_cor_ext_rcv,
    input                 derr_cor_ext_rpl,
    input                 derr_rpl,
    input                 dlup_exit,
    input                 ev128ns,
    input                 ev1us,
    input                 hotrst_exit,
    input [3 : 0]         int_status,
    input                 l2_exit,          // used by reset block
    input [3:0]           lane_act,
    input [4 : 0]         ltssmstate,       // used by reset block  
    input                 dlup,
    input                 rx_par_err ,
    input [1:0]           tx_par_err ,
    input                 cfg_par_err,
    input [7:0]           ko_cpl_spc_header,
    input [11:0]          ko_cpl_spc_data,
   //###################################################################################
   // Status signals to user application
   //###################################################################################
    output                derr_cor_ext_rcv_drv,
    output                derr_cor_ext_rpl_drv,
    output                derr_rpl_drv,
    output                dlup_exit_drv,
    output                ev128ns_drv,
    output                ev1us_drv,
    output                hotrst_exit_drv,
    output [3 : 0]        int_status_drv,
    output                l2_exit_drv,
    output [3:0]          lane_act_drv,
    output [4 : 0]        ltssmstate_drv,
    output                dlup_drv,
    output                rx_par_err_drv,
    output [1:0]          tx_par_err_drv,
    output                cfg_par_err_drv,
    output [7:0]          ko_cpl_spc_header_drv,
    output [11:0]         ko_cpl_spc_data_drv,
    output                rxfc_cplbuf_ovf_app,  // Signals overflow of the RX buffer in the HIP
   //###################################################################################
   // Completion Status Signals from user application
   //###################################################################################
   input [6:0]            cpl_err,    // Error indications for Function 0 from user application  
                                      // [0] = Completion timeout with recovery
                                      // [1] = Completion timeout without recovery
                                      // [2] = Completer Abort sent
                                      // [3] = Unexpected Completion received
                                      // [4] = Posted request received and flagged as UR
                                      // [5] = Non-Posted request received and flagged as UR
                                      // [6] = Header Logging enable (header supplied on log_hdr input) 
    input [7:0]           cpl_err_fn, // Function number of reporting Function      
    input                 cpl_pending_pf,// Completion pending status from PF 0
    input [VF_COUNT-1:0]  cpl_pending_vf,// Completion pending status from VFs
    input [127:0]         log_hdr,    // TLP header for logging
   //###################################################################################
   // FLR Interface
   //###################################################################################
    output                flr_active_pf, // FLR status for PF 0
    output [VF_COUNT-1:0] flr_active_vf, // FLR status for VFs
    input                 flr_completed_pf, // Indication from user to re-enable PF 0 after FLR
    input [VF_COUNT-1:0]  flr_completed_vf, // Indication from user to re-enable VFs after FLR
   //###################################################################################
   // Configuration Status Interface
   //###################################################################################
    output [7:0]          bus_num_f0, // Captured bus number for Function 0 	
    output [4:0]          device_num_f0, // Captured device number for Function 0 (set to 0 for an ARI device) 	
    output                mem_space_en_pf, // Memory Space Enable for PF 0
    output                bus_master_en_pf, // Bus Master Enable for PF 0
    output                mem_space_en_vf, // Memory Space Enable for VFs (common for all VFs)
    output [VF_COUNT-1:0] bus_master_en_vf, // Bus Master Enable for VFs
    output [7:0]          num_vfs, // Number of enabled VFs        
    output [2:0]          max_payload_size, // Max payload size from Device Control Register of PF 0
    output [2:0]          rd_req_size, // Read Request Size from Device Control Register of PF 0
   //###################################################################################
   // Interrupt interface
   //###################################################################################
   input                  app_int_sts_a, // Legacy interrupt request, INTA
   input                  app_int_sts_b, // Legacy interrupt request, INTB
   input                  app_int_sts_c, // Legacy interrupt request, INTC
   input                  app_int_sts_d, // Legacy interrupt request, INTD
   input [2:0]            app_int_sts_fn, // Function Num associated with the Legacy interrupt request
   output                 app_int_ack, // Ack to Legacy interrupt request, common for all interrupts
   input                  app_msi_req, // MSI interrupt request, common for all Functions
   output                 app_msi_ack, // Ack to MSI interrupt request, common for all Functions
   input [7:0]            app_msi_req_fn, // Function number corresponding to MSI interrupt request
   input [4:0]            app_msi_num, // MSI interrupt number corresponding to MSI interrupt request
   input [2:0]            app_msi_tc,  // Traffic Class corresponding to MSI interrupt request
   input                  app_int_pend_status, // Interrupt pending stats from Function
   output                 app_intx_disable, // INTX Disable from PCI Command Register of PF 0
   output                 app_msi_enable_pf,// MSI Enable setting of PF 0
   output [2:0]           app_msi_multi_msg_enable_pf,// MSI Multiple Msg field setting of PF 0
   output [VF_COUNT-1:0]  app_msi_enable_vf,// MSI Enable setting of VFs
   output [VF_COUNT*3-1:0] app_msi_multi_msg_enable_vf,// MSI Multiple Msg field setting of VFs
   output                 app_msix_en_pf, // MSIX Enable bit from MSIX Control Reg of PF 0
   output   	          app_msix_fn_mask_pf, // MSIX Function Mask bit from MSIX Control Reg of PF 0
   output [VF_COUNT-1:0]  app_msix_en_vf, // MSIX Enable bits from MSIX Control Reg of VFs
   output [VF_COUNT-1:0]  app_msix_fn_mask_vf, // MSIX Function Mask bits from MSIX Control Reg of VFs
   //###################################################################################
   // Config Bypass inputs from HIP
   //###################################################################################
   input  [7:0]           cfgbp_lane_err,
   input                  cfgbp_link_equlz_req,
   input                  cfgbp_equiz_complete,
   input                  cfgbp_phase_3_successful,
   input                  cfgbp_phase_2_successful,
   input                  cfgbp_phase_1_successful,
   input                  cfgbp_current_deemph,
   input  [1:0]           cfgbp_current_speed,
   input                  cfgbp_link_up,
   input                  cfgbp_link_train,
   input                  cfgbp_10state,
   input                  cfgbp_10sstate,
   input                  cfgbp_rx_val_pm,
   input  [2:0]           cfgbp_rx_typ_pm,
   input                  cfgbp_tx_ack_pm,
   input  [1:0]           cfgbp_ack_phypm,
   input                  cfgbp_vc_status,
   input                  cfgbp_rxfc_max,
   input                  cfgbp_txfc_max,
   input                  cfgbp_txbuf_emp,
   input                  cfgbp_cfgbuf_emp,
   input                  cfgbp_rpbuf_emp,
   input                  cfgbp_dll_req,
   input                  cfgbp_link_auto_bdw_status,
   input                  cfgbp_link_bdw_mng_status,
   input                  cfgbp_rst_tx_margin_field,
   input                  cfgbp_rst_enter_comp_bit,
   input  [3:0]           cfgbp_rx_st_ecrcerr,
   input                  cfgbp_err_uncorr_internal,
   input                  cfgbp_rx_corr_internal,
   input                  cfgbp_err_tlrcvovf,
   input                  cfgbp_txfc_err,
   input                  cfgbp_err_tlmalf,
   input                  cfgbp_err_surpdwn_dll,
   input                  cfgbp_err_dllrev,
   input                  cfgbp_err_dll_repnum,
   input                  cfgbp_err_dllreptim,
   input                  cfgbp_err_dllp_baddllp,
   input                  cfgbp_err_dll_badtlp,
   input                  cfgbp_err_phy_tng,
   input                  cfgbp_err_phy_rcv,
   input                  cfgbp_root_err_reg_sts,
   input                  cfgbp_corr_err_reg_sts,
   input                  cfgbp_unc_err_reg_sts,         
   //###################################################################################
   // Config Bypass Outputs to HIP
   //###################################################################################
   output  [12:0]         cfgbp_link2csr,
   output                 cfgbp_comclk_reg,
   output                 cfgbp_extsy_reg,
   output  [2:0]          cfgbp_max_pload,
   output                 cfgbp_tx_ecrcgen,
   output                 cfgbp_rx_ecrchk,
   output  [7:0]          cfgbp_secbus,
   output                 cfgbp_linkcsr_bit0,
   output                 cfgbp_tx_req_pm,
   output  [2:0]          cfgbp_tx_typ_pm,
   output  [3:0]          cfgbp_req_phypm,
   output  [3:0]          cfgbp_req_phycfg,
   output  [6:0]          cfgbp_vc0_tcmap_pld,
   output                 cfgbp_inh_dllp,
   output                 cfgbp_inh_tx_tlp,
   output                 cfgbp_req_wake,
   output  [1:0]          cfgbp_link3_ctl      
   );

  // BAR apertures	
   wire [31:0]    f0_bar0_aperture;
   wire [31:0]    f0_bar1_aperture;
   wire [31:0]    f0_bar2_aperture;
   wire [31:0]    f0_bar3_aperture;

   wire [31:0]    f0_vf_bar0_aperture;
   wire [31:0]    f0_vf_bar1_aperture;
   wire [31:0]    f0_vf_bar2_aperture;
   wire [31:0]    f0_vf_bar3_aperture;

   wire [31:0]    f0_vf_bar0_aperture_bitmask;
   wire [31:0]    f0_vf_bar1_aperture_bitmask;
   wire [31:0]    f0_vf_bar2_aperture_bitmask;
   wire [31:0]    f0_vf_bar3_aperture_bitmask;

   wire [2:0] 	  max_payload_size_int;

   wire 	  app_rstn;

   //======================
   // Generated reset
   //======================
   altpcierd_hip_rs rs_hip (
      .npor             (!reset_status & pld_clk_inuse),
      .pld_clk          (pld_clk),
      .dlup_exit        (dlup_exit),
      .hotrst_exit      (!reset_status),
      .l2_exit          (l2_exit),     // from hip_status block
      .ltssm            (ltssmstate),  // from hip_status block
      .app_rstn         (app_rstn),
      .test_sim         (testin_zero)
   );

  //=====================================================================
  // Calculate BAR apertures of Function 0 BARs
  //=====================================================================
   generate begin: find_bar_aperture_settings_f0_bar0
   if (PF_BAR0_SIZE == 7) begin
     assign f0_bar0_aperture = 32'hffff_ff80; // 128 bytes
    end
   else if (PF_BAR0_SIZE == 8) begin
     assign f0_bar0_aperture = 32'hffff_ff00;
    end
   else if (PF_BAR0_SIZE == 9) begin
     assign f0_bar0_aperture = 32'hffff_fe00;
    end
   else if (PF_BAR0_SIZE == 10) begin
     assign f0_bar0_aperture = 32'hffff_fc00;
    end
   else if (PF_BAR0_SIZE == 11) begin
     assign f0_bar0_aperture = 32'hffff_f800;
    end
   else if (PF_BAR0_SIZE == 5+7) begin
     assign f0_bar0_aperture = 32'hffff_f000;
    end
   else if (PF_BAR0_SIZE == 6+7) begin
     assign f0_bar0_aperture = 32'hffff_e000;
    end
   else if (PF_BAR0_SIZE == 7+7) begin
     assign f0_bar0_aperture = 32'hffff_c000;
    end
   else if (PF_BAR0_SIZE == 8+7) begin
     assign f0_bar0_aperture = 32'hffff_8000;
    end
   else if (PF_BAR0_SIZE == 9+7) begin
     assign f0_bar0_aperture = 32'hffff_0000;
    end
   else if (PF_BAR0_SIZE == 10+7) begin
     assign f0_bar0_aperture = 32'hfffe_0000;
    end
   else if (PF_BAR0_SIZE == 11+7) begin
     assign f0_bar0_aperture = 32'hfffc_0000;
    end
   else if (PF_BAR0_SIZE == 12+7) begin
     assign f0_bar0_aperture = 32'hfff8_0000;
    end
   else if (PF_BAR0_SIZE == 13+7) begin
     assign f0_bar0_aperture = 32'hfff0_0000;
    end
   else if (PF_BAR0_SIZE == 14+7) begin
     assign f0_bar0_aperture = 32'hffe0_0000;
    end
   else if (PF_BAR0_SIZE == 15+7) begin
     assign f0_bar0_aperture = 32'hffc0_0000;
    end
   else if (PF_BAR0_SIZE == 16+7) begin
     assign f0_bar0_aperture = 32'hff80_0000;
    end
   else if (PF_BAR0_SIZE == 17+7) begin
     assign f0_bar0_aperture = 32'hff00_0000;
    end
   else if (PF_BAR0_SIZE == 18+7) begin
     assign f0_bar0_aperture = 32'hfe00_0000;
    end
   else if (PF_BAR0_SIZE == 19+7) begin
     assign f0_bar0_aperture = 32'hfc00_0000;
    end
   else if (PF_BAR0_SIZE == 20+7) begin
     assign f0_bar0_aperture = 32'hf800_0000;
    end
   else if (PF_BAR0_SIZE == 21+7) begin
     assign f0_bar0_aperture = 32'hf000_0000;
    end
   else if (PF_BAR0_SIZE == 22+7) begin
     assign f0_bar0_aperture = 32'he000_0000;
    end
   else if (PF_BAR0_SIZE == 23+7) begin
     assign f0_bar0_aperture = 32'hc000_0000;
    end
   else begin
     assign f0_bar0_aperture = 32'h8000_0000; // 2 Gbytes
    end
     
   end
   endgenerate

   generate begin: find_bar_aperture_settings_f0_bar1

   if (PF_BAR0_TYPE == 1) // 64-bit BAR
     assign f0_bar1_aperture = 32'hffff_ffff;

   else if (PF_BAR1_SIZE == 7) begin
     assign f0_bar1_aperture = 32'hffff_ff80; // 128 bytes
    end
   else if (PF_BAR1_SIZE == 1+7) begin
     assign f0_bar1_aperture = 32'hffff_ff00;
    end
   else if (PF_BAR1_SIZE == 2+7) begin
     assign f0_bar1_aperture = 32'hffff_fe00;
    end
   else if (PF_BAR1_SIZE == 3+7) begin
     assign f0_bar1_aperture = 32'hffff_fc00;
    end
   else if (PF_BAR1_SIZE == 4+7) begin
     assign f0_bar1_aperture = 32'hffff_f800;
    end
   else if (PF_BAR1_SIZE == 5+7) begin
     assign f0_bar1_aperture = 32'hffff_f000;
    end
   else if (PF_BAR1_SIZE == 6+7) begin
     assign f0_bar1_aperture = 32'hffff_e000;
    end
   else if (PF_BAR1_SIZE == 7+7) begin
     assign f0_bar1_aperture = 32'hffff_c000;
    end
   else if (PF_BAR1_SIZE == 8+7) begin
     assign f0_bar1_aperture = 32'hffff_8000;
    end
   else if (PF_BAR1_SIZE == 9+7) begin
     assign f0_bar1_aperture = 32'hffff_0000;
    end
   else if (PF_BAR1_SIZE == 10+7) begin
     assign f0_bar1_aperture = 32'hfffe_0000;
    end
   else if (PF_BAR1_SIZE == 11+7) begin
     assign f0_bar1_aperture = 32'hfffc_0000;
    end
   else if (PF_BAR1_SIZE == 12+7) begin
     assign f0_bar1_aperture = 32'hfff8_0000;
    end
   else if (PF_BAR1_SIZE == 13+7) begin
     assign f0_bar1_aperture = 32'hfff0_0000;
    end
   else if (PF_BAR1_SIZE == 14+7) begin
     assign f0_bar1_aperture = 32'hffe0_0000;
    end
   else if (PF_BAR1_SIZE == 15+7) begin
     assign f0_bar1_aperture = 32'hffc0_0000;
    end
   else if (PF_BAR1_SIZE == 16+7) begin
     assign f0_bar1_aperture = 32'hff80_0000;
    end
   else if (PF_BAR1_SIZE == 17+7) begin
     assign f0_bar1_aperture = 32'hff00_0000;
    end
   else if (PF_BAR1_SIZE == 18+7) begin
     assign f0_bar1_aperture = 32'hfe00_0000;
    end
   else if (PF_BAR1_SIZE == 19+7) begin
     assign f0_bar1_aperture = 32'hfc00_0000;
    end
   else if (PF_BAR1_SIZE == 20+7) begin
     assign f0_bar1_aperture = 32'hf800_0000;
    end
   else if (PF_BAR1_SIZE == 21+7) begin
     assign f0_bar1_aperture = 32'hf000_0000;
    end
   else if (PF_BAR1_SIZE == 22+7) begin
     assign f0_bar1_aperture = 32'he000_0000;
    end
   else if (PF_BAR1_SIZE == 23+7) begin
     assign f0_bar1_aperture = 32'hc000_0000;
    end
   else begin
     assign f0_bar1_aperture = 32'h8000_0000; // 2 Gbytes
    end
     
   end
   endgenerate

   generate begin: find_bar_aperture_settings_f0_bar2
   if (PF_BAR2_SIZE == 7) begin
     assign f0_bar2_aperture = 32'hffff_ff80; // 128 bytes
    end
   else if (PF_BAR2_SIZE == 1+7) begin
     assign f0_bar2_aperture = 32'hffff_ff00;
    end
   else if (PF_BAR2_SIZE == 2+7) begin
     assign f0_bar2_aperture = 32'hffff_fe00;
    end
   else if (PF_BAR2_SIZE == 3+7) begin
     assign f0_bar2_aperture = 32'hffff_fc00;
    end
   else if (PF_BAR2_SIZE == 4+7) begin
     assign f0_bar2_aperture = 32'hffff_f800;
    end
   else if (PF_BAR2_SIZE == 5+7) begin
     assign f0_bar2_aperture = 32'hffff_f000;
    end
   else if (PF_BAR2_SIZE == 6+7) begin
     assign f0_bar2_aperture = 32'hffff_e000;
    end
   else if (PF_BAR2_SIZE == 7+7) begin
     assign f0_bar2_aperture = 32'hffff_c000;
    end
   else if (PF_BAR2_SIZE == 8+7) begin
     assign f0_bar2_aperture = 32'hffff_8000;
    end
   else if (PF_BAR2_SIZE == 9+7) begin
     assign f0_bar2_aperture = 32'hffff_0000;
    end
   else if (PF_BAR2_SIZE == 10+7) begin
     assign f0_bar2_aperture = 32'hfffe_0000;
    end
   else if (PF_BAR2_SIZE == 11+7) begin
     assign f0_bar2_aperture = 32'hfffc_0000;
    end
   else if (PF_BAR2_SIZE == 12+7) begin
     assign f0_bar2_aperture = 32'hfff8_0000;
    end
   else if (PF_BAR2_SIZE == 13+7) begin
     assign f0_bar2_aperture = 32'hfff0_0000;
    end
   else if (PF_BAR2_SIZE == 14+7) begin
     assign f0_bar2_aperture = 32'hffe0_0000;
    end
   else if (PF_BAR2_SIZE == 15+7) begin
     assign f0_bar2_aperture = 32'hffc0_0000;
    end
   else if (PF_BAR2_SIZE == 16+7) begin
     assign f0_bar2_aperture = 32'hff80_0000;
    end
   else if (PF_BAR2_SIZE == 17+7) begin
     assign f0_bar2_aperture = 32'hff00_0000;
    end
   else if (PF_BAR2_SIZE == 18+7) begin
     assign f0_bar2_aperture = 32'hfe00_0000;
    end
   else if (PF_BAR2_SIZE == 19+7) begin
     assign f0_bar2_aperture = 32'hfc00_0000;
    end
   else if (PF_BAR2_SIZE == 20+7) begin
     assign f0_bar2_aperture = 32'hf800_0000;
    end
   else if (PF_BAR2_SIZE == 21+7) begin
     assign f0_bar2_aperture = 32'hf000_0000;
    end
   else if (PF_BAR2_SIZE == 22+7) begin
     assign f0_bar2_aperture = 32'he000_0000;
    end
   else if (PF_BAR2_SIZE == 23+7) begin
     assign f0_bar2_aperture = 32'hc000_0000;
    end
   else begin
     assign f0_bar2_aperture = 32'h8000_0000; // 2 Gbytes
    end
     
   end
   endgenerate

   generate begin: find_bar_aperture_settings_f0_bar3

   if (PF_BAR2_TYPE == 1) // 64-bit BAR
     assign f0_bar3_aperture = 32'hffff_ffff;

   else if (PF_BAR3_SIZE == 7) begin
     assign f0_bar3_aperture = 32'hffff_ff80; // 128 bytes
    end
   else if (PF_BAR3_SIZE == 1+7) begin
     assign f0_bar3_aperture = 32'hffff_ff00;
    end
   else if (PF_BAR3_SIZE == 2+7) begin
     assign f0_bar3_aperture = 32'hffff_fe00;
    end
   else if (PF_BAR3_SIZE == 3+7) begin
     assign f0_bar3_aperture = 32'hffff_fc00;
    end
   else if (PF_BAR3_SIZE == 4+7) begin
     assign f0_bar3_aperture = 32'hffff_f800;
    end
   else if (PF_BAR3_SIZE == 5+7) begin
     assign f0_bar3_aperture = 32'hffff_f000;
    end
   else if (PF_BAR3_SIZE == 6+7) begin
     assign f0_bar3_aperture = 32'hffff_e000;
    end
   else if (PF_BAR3_SIZE == 7+7) begin
     assign f0_bar3_aperture = 32'hffff_c000;
    end
   else if (PF_BAR3_SIZE == 8+7) begin
     assign f0_bar3_aperture = 32'hffff_8000;
    end
   else if (PF_BAR3_SIZE == 9+7) begin
     assign f0_bar3_aperture = 32'hffff_0000;
    end
   else if (PF_BAR3_SIZE == 10+7) begin
     assign f0_bar3_aperture = 32'hfffe_0000;
    end
   else if (PF_BAR3_SIZE == 11+7) begin
     assign f0_bar3_aperture = 32'hfffc_0000;
    end
   else if (PF_BAR3_SIZE == 12+7) begin
     assign f0_bar3_aperture = 32'hfff8_0000;
    end
   else if (PF_BAR3_SIZE == 13+7) begin
     assign f0_bar3_aperture = 32'hfff0_0000;
    end
   else if (PF_BAR3_SIZE == 14+7) begin
     assign f0_bar3_aperture = 32'hffe0_0000;
    end
   else if (PF_BAR3_SIZE == 15+7) begin
     assign f0_bar3_aperture = 32'hffc0_0000;
    end
   else if (PF_BAR3_SIZE == 16+7) begin
     assign f0_bar3_aperture = 32'hff80_0000;
    end
   else if (PF_BAR3_SIZE == 17+7) begin
     assign f0_bar3_aperture = 32'hff00_0000;
    end
   else if (PF_BAR3_SIZE == 18+7) begin
     assign f0_bar3_aperture = 32'hfe00_0000;
    end
   else if (PF_BAR3_SIZE == 19+7) begin
     assign f0_bar3_aperture = 32'hfc00_0000;
    end
   else if (PF_BAR3_SIZE == 20+7) begin
     assign f0_bar3_aperture = 32'hf800_0000;
    end
   else if (PF_BAR3_SIZE == 21+7) begin
     assign f0_bar3_aperture = 32'hf000_0000;
    end
   else if (PF_BAR3_SIZE == 22+7) begin
     assign f0_bar3_aperture = 32'he000_0000;
    end
   else if (PF_BAR3_SIZE == 23+7) begin
     assign f0_bar3_aperture = 32'hc000_0000;
    end
   else begin
     assign f0_bar3_aperture = 32'h8000_0000; // 2 Gbytes
    end
     
   end
   endgenerate

   generate begin: find_bar_aperture_settings_f0_vf_bar0
   if (VF_BAR0_SIZE == 7) begin
     assign f0_vf_bar0_aperture = 32'h80; // 128 bytes
     assign f0_vf_bar0_aperture_bitmask = 32'hffff_ff80; // 128 bytes
    end
   else if (VF_BAR0_SIZE == 8) begin
     assign f0_vf_bar0_aperture = 32'h100; // 256 bytes
     assign f0_vf_bar0_aperture_bitmask = 32'hffff_ff00;
    end
   else if (VF_BAR0_SIZE == 9) begin
     assign f0_vf_bar0_aperture = 32'h200; // 512 bytes
     assign f0_vf_bar0_aperture_bitmask = 32'hffff_fe00;
    end
   else if (VF_BAR0_SIZE == 10) begin
     assign f0_vf_bar0_aperture = 32'h400; // 1024 bytes
     assign f0_vf_bar0_aperture_bitmask = 32'hffff_fc00;
    end
   else if (VF_BAR0_SIZE == 11) begin
     assign f0_vf_bar0_aperture = 32'h800; // 2K bytes
     assign f0_vf_bar0_aperture_bitmask = 32'hffff_f800;
    end
   else if (VF_BAR0_SIZE == 5+7) begin
     assign f0_vf_bar0_aperture = 32'h1000; // 4K bytes
     assign f0_vf_bar0_aperture_bitmask = 32'hffff_f000;
    end
   else if (VF_BAR0_SIZE == 6+7) begin
     assign f0_vf_bar0_aperture = 32'h2000; // 8K bytes
     assign f0_vf_bar0_aperture_bitmask = 32'hffff_e000;
    end
   else if (VF_BAR0_SIZE == 7+7) begin
     assign f0_vf_bar0_aperture = 32'h4000; // 16K bytes
     assign f0_vf_bar0_aperture_bitmask = 32'hffff_c000;
    end
   else if (VF_BAR0_SIZE == 8+7) begin
     assign f0_vf_bar0_aperture = 32'h8000; // 32K bytes
     assign f0_vf_bar0_aperture_bitmask = 32'hffff_8000;
    end
   else if (VF_BAR0_SIZE == 9+7) begin
     assign f0_vf_bar0_aperture = 32'h1_0000; // 64K bytes
     assign f0_vf_bar0_aperture_bitmask = 32'hffff_0000;
    end
   else if (VF_BAR0_SIZE == 10+7) begin
     assign f0_vf_bar0_aperture = 32'h2_0000; // 128K bytes
     assign f0_vf_bar0_aperture_bitmask = 32'hfffe_0000;
    end
   else if (VF_BAR0_SIZE == 11+7) begin
     assign f0_vf_bar0_aperture = 32'h4_0000; // 256K bytes
     assign f0_vf_bar0_aperture_bitmask = 32'hfffc_0000;
    end
   else if (VF_BAR0_SIZE == 12+7) begin
     assign f0_vf_bar0_aperture = 32'h8_0000; // 512K bytes
     assign f0_vf_bar0_aperture_bitmask = 32'hfff8_0000;
    end
   else if (VF_BAR0_SIZE == 13+7) begin
     assign f0_vf_bar0_aperture = 32'h10_0000; // 1M bytes
     assign f0_vf_bar0_aperture_bitmask = 32'hfff0_0000;
    end
   else if (VF_BAR0_SIZE == 14+7) begin
     assign f0_vf_bar0_aperture = 32'h20_0000; // 2M bytes
     assign f0_vf_bar0_aperture_bitmask = 32'hffe0_0000;
    end
   else if (VF_BAR0_SIZE == 15+7) begin
     assign f0_vf_bar0_aperture = 32'h40_0000; // 4M bytes
     assign f0_vf_bar0_aperture_bitmask = 32'hffc0_0000;
    end
   else if (VF_BAR0_SIZE == 16+7) begin
     assign f0_vf_bar0_aperture = 32'h80_0000; // 8M bytes
     assign f0_vf_bar0_aperture_bitmask = 32'hff80_0000;
    end
   else if (VF_BAR0_SIZE == 17+7) begin
     assign f0_vf_bar0_aperture = 32'h100_0000; // 16M bytes
     assign f0_vf_bar0_aperture_bitmask = 32'hff00_0000;
    end
   else if (VF_BAR0_SIZE == 18+7) begin
     assign f0_vf_bar0_aperture = 32'h200_0000; // 32M bytes
     assign f0_vf_bar0_aperture_bitmask = 32'hfe00_0000;
    end
   else if (VF_BAR0_SIZE == 19+7) begin
     assign f0_vf_bar0_aperture = 32'h400_0000; // 64M bytes
     assign f0_vf_bar0_aperture_bitmask = 32'hfc00_0000;
    end
   else if (VF_BAR0_SIZE == 20+7) begin
     assign f0_vf_bar0_aperture = 32'h800_0000; // 128M bytes
     assign f0_vf_bar0_aperture_bitmask = 32'hf800_0000;
    end
   else if (VF_BAR0_SIZE == 21+7) begin
     assign f0_vf_bar0_aperture = 32'h1000_0000; // 256M bytes
     assign f0_vf_bar0_aperture_bitmask = 32'hf000_0000;
    end
   else if (VF_BAR0_SIZE == 22+7) begin
     assign f0_vf_bar0_aperture = 32'h2000_0000; // 512M bytes
     assign f0_vf_bar0_aperture_bitmask = 32'he000_0000;
    end
   else if (VF_BAR0_SIZE == 23+7) begin
     assign f0_vf_bar0_aperture = 32'h4000_0000; // 1G bytes
     assign f0_vf_bar0_aperture_bitmask = 32'hc000_0000;
    end
   else begin
     assign f0_vf_bar0_aperture = 32'h8000_0000; // 2G bytes
     assign f0_vf_bar0_aperture_bitmask = 32'h8000_0000; // 2 Gbytes
    end
     
   end
   endgenerate

   generate begin: find_bar_aperture_settings_f0_vf_bar1

   if (VF_BAR0_TYPE == 1) begin // 64-bit BAR
     assign f0_vf_bar1_aperture = 32'h0;
     assign f0_vf_bar1_aperture_bitmask = 32'hffff_ffff; 
    end
   else if (VF_BAR1_SIZE == 7) begin
     assign f0_vf_bar1_aperture = 32'h80; // 128 bytes
     assign f0_vf_bar1_aperture_bitmask = 32'hffff_ff80; // 128 bytes
    end
   else if (VF_BAR1_SIZE == 8) begin
     assign f0_vf_bar1_aperture = 32'h100; // 256 bytes
     assign f0_vf_bar1_aperture_bitmask = 32'hffff_ff00;
    end
   else if (VF_BAR1_SIZE == 9) begin
     assign f0_vf_bar1_aperture = 32'h200; // 512 bytes
     assign f0_vf_bar1_aperture_bitmask = 32'hffff_fe00;
    end
   else if (VF_BAR1_SIZE == 10) begin
     assign f0_vf_bar1_aperture = 32'h400; // 1024 bytes
     assign f0_vf_bar1_aperture_bitmask = 32'hffff_fc00;
    end
   else if (VF_BAR1_SIZE == 11) begin
     assign f0_vf_bar1_aperture = 32'h800; // 2K bytes
     assign f0_vf_bar1_aperture_bitmask = 32'hffff_f800;
    end
   else if (VF_BAR1_SIZE == 5+7) begin
     assign f0_vf_bar1_aperture = 32'h1000; // 4K bytes
     assign f0_vf_bar1_aperture_bitmask = 32'hffff_f000;
    end
   else if (VF_BAR1_SIZE == 6+7) begin
     assign f0_vf_bar1_aperture = 32'h2000; // 8K bytes
     assign f0_vf_bar1_aperture_bitmask = 32'hffff_e000;
    end
   else if (VF_BAR1_SIZE == 7+7) begin
     assign f0_vf_bar1_aperture = 32'h4000; // 16K bytes
     assign f0_vf_bar1_aperture_bitmask = 32'hffff_c000;
    end
   else if (VF_BAR1_SIZE == 8+7) begin
     assign f0_vf_bar1_aperture = 32'h8000; // 32K bytes
     assign f0_vf_bar1_aperture_bitmask = 32'hffff_8000;
    end
   else if (VF_BAR1_SIZE == 9+7) begin
     assign f0_vf_bar1_aperture = 32'h1_0000; // 64K bytes
     assign f0_vf_bar1_aperture_bitmask = 32'hffff_0000;
    end
   else if (VF_BAR1_SIZE == 10+7) begin
     assign f0_vf_bar1_aperture = 32'h2_0000; // 128K bytes
     assign f0_vf_bar1_aperture_bitmask = 32'hfffe_0000;
    end
   else if (VF_BAR1_SIZE == 11+7) begin
     assign f0_vf_bar1_aperture = 32'h4_0000; // 256K bytes
     assign f0_vf_bar1_aperture_bitmask = 32'hfffc_0000;
    end
   else if (VF_BAR1_SIZE == 12+7) begin
     assign f0_vf_bar1_aperture = 32'h8_0000; // 512K bytes
     assign f0_vf_bar1_aperture_bitmask = 32'hfff8_0000;
    end
   else if (VF_BAR1_SIZE == 13+7) begin
     assign f0_vf_bar1_aperture = 32'h10_0000; // 1M bytes
     assign f0_vf_bar1_aperture_bitmask = 32'hfff0_0000;
    end
   else if (VF_BAR1_SIZE == 14+7) begin
     assign f0_vf_bar1_aperture = 32'h20_0000; // 2M bytes
     assign f0_vf_bar1_aperture_bitmask = 32'hffe0_0000;
    end
   else if (VF_BAR1_SIZE == 15+7) begin
     assign f0_vf_bar1_aperture = 32'h40_0000; // 4M bytes
     assign f0_vf_bar1_aperture_bitmask = 32'hffc0_0000;
    end
   else if (VF_BAR1_SIZE == 16+7) begin
     assign f0_vf_bar1_aperture = 32'h80_0000; // 8M bytes
     assign f0_vf_bar1_aperture_bitmask = 32'hff80_0000;
    end
   else if (VF_BAR1_SIZE == 17+7) begin
     assign f0_vf_bar1_aperture = 32'h100_0000; // 16M bytes
     assign f0_vf_bar1_aperture_bitmask = 32'hff00_0000;
    end
   else if (VF_BAR1_SIZE == 18+7) begin
     assign f0_vf_bar1_aperture = 32'h200_0000; // 32M bytes
     assign f0_vf_bar1_aperture_bitmask = 32'hfe00_0000;
    end
   else if (VF_BAR1_SIZE == 19+7) begin
     assign f0_vf_bar1_aperture = 32'h400_0000; // 64M bytes
     assign f0_vf_bar1_aperture_bitmask = 32'hfc00_0000;
    end
   else if (VF_BAR1_SIZE == 20+7) begin
     assign f0_vf_bar1_aperture = 32'h800_0000; // 128M bytes
     assign f0_vf_bar1_aperture_bitmask = 32'hf800_0000;
    end
   else if (VF_BAR1_SIZE == 21+7) begin
     assign f0_vf_bar1_aperture = 32'h1000_0000; // 256M bytes
     assign f0_vf_bar1_aperture_bitmask = 32'hf000_0000;
    end
   else if (VF_BAR1_SIZE == 22+7) begin
     assign f0_vf_bar1_aperture = 32'h2000_0000; // 512M bytes
     assign f0_vf_bar1_aperture_bitmask = 32'he000_0000;
    end
   else if (VF_BAR1_SIZE == 23+7) begin
     assign f0_vf_bar1_aperture = 32'h4000_0000; // 1G bytes
     assign f0_vf_bar1_aperture_bitmask = 32'hc000_0000;
    end
   else begin
     assign f0_vf_bar1_aperture = 32'h8000_0000; // 2G bytes
     assign f0_vf_bar1_aperture_bitmask = 32'h8000_0000; // 2 Gbytes
    end
     
   end
   endgenerate

   generate begin: find_bar_aperture_settings_f0_vf_bar2
   if (VF_BAR2_SIZE == 7) begin
     assign f0_vf_bar2_aperture = 32'h80; // 128 bytes
     assign f0_vf_bar2_aperture_bitmask = 32'hffff_ff80; // 128 bytes
    end
   else if (VF_BAR2_SIZE == 8) begin
     assign f0_vf_bar2_aperture = 32'h100; // 256 bytes
     assign f0_vf_bar2_aperture_bitmask = 32'hffff_ff00;
    end
   else if (VF_BAR2_SIZE == 9) begin
     assign f0_vf_bar2_aperture = 32'h200; // 512 bytes
     assign f0_vf_bar2_aperture_bitmask = 32'hffff_fe00;
    end
   else if (VF_BAR2_SIZE == 10) begin
     assign f0_vf_bar2_aperture = 32'h400; // 1024 bytes
     assign f0_vf_bar2_aperture_bitmask = 32'hffff_fc00;
    end
   else if (VF_BAR2_SIZE == 11) begin
     assign f0_vf_bar2_aperture = 32'h800; // 2K bytes
     assign f0_vf_bar2_aperture_bitmask = 32'hffff_f800;
    end
   else if (VF_BAR2_SIZE == 5+7) begin
     assign f0_vf_bar2_aperture = 32'h1000; // 4K bytes
     assign f0_vf_bar2_aperture_bitmask = 32'hffff_f000;
    end
   else if (VF_BAR2_SIZE == 6+7) begin
     assign f0_vf_bar2_aperture = 32'h2000; // 8K bytes
     assign f0_vf_bar2_aperture_bitmask = 32'hffff_e000;
    end
   else if (VF_BAR2_SIZE == 7+7) begin
     assign f0_vf_bar2_aperture = 32'h4000; // 16K bytes
     assign f0_vf_bar2_aperture_bitmask = 32'hffff_c000;
    end
   else if (VF_BAR2_SIZE == 8+7) begin
     assign f0_vf_bar2_aperture = 32'h8000; // 32K bytes
     assign f0_vf_bar2_aperture_bitmask = 32'hffff_8000;
    end
   else if (VF_BAR2_SIZE == 9+7) begin
     assign f0_vf_bar2_aperture = 32'h1_0000; // 64K bytes
     assign f0_vf_bar2_aperture_bitmask = 32'hffff_0000;
    end
   else if (VF_BAR2_SIZE == 10+7) begin
     assign f0_vf_bar2_aperture = 32'h2_0000; // 128K bytes
     assign f0_vf_bar2_aperture_bitmask = 32'hfffe_0000;
    end
   else if (VF_BAR2_SIZE == 11+7) begin
     assign f0_vf_bar2_aperture = 32'h4_0000; // 256K bytes
     assign f0_vf_bar2_aperture_bitmask = 32'hfffc_0000;
    end
   else if (VF_BAR2_SIZE == 12+7) begin
     assign f0_vf_bar2_aperture = 32'h8_0000; // 512K bytes
     assign f0_vf_bar2_aperture_bitmask = 32'hfff8_0000;
    end
   else if (VF_BAR2_SIZE == 13+7) begin
     assign f0_vf_bar2_aperture = 32'h10_0000; // 1M bytes
     assign f0_vf_bar2_aperture_bitmask = 32'hfff0_0000;
    end
   else if (VF_BAR2_SIZE == 14+7) begin
     assign f0_vf_bar2_aperture = 32'h20_0000; // 2M bytes
     assign f0_vf_bar2_aperture_bitmask = 32'hffe0_0000;
    end
   else if (VF_BAR2_SIZE == 15+7) begin
     assign f0_vf_bar2_aperture = 32'h40_0000; // 4M bytes
     assign f0_vf_bar2_aperture_bitmask = 32'hffc0_0000;
    end
   else if (VF_BAR2_SIZE == 16+7) begin
     assign f0_vf_bar2_aperture = 32'h80_0000; // 8M bytes
     assign f0_vf_bar2_aperture_bitmask = 32'hff80_0000;
    end
   else if (VF_BAR2_SIZE == 17+7) begin
     assign f0_vf_bar2_aperture = 32'h100_0000; // 16M bytes
     assign f0_vf_bar2_aperture_bitmask = 32'hff00_0000;
    end
   else if (VF_BAR2_SIZE == 18+7) begin
     assign f0_vf_bar2_aperture = 32'h200_0000; // 32M bytes
     assign f0_vf_bar2_aperture_bitmask = 32'hfe00_0000;
    end
   else if (VF_BAR2_SIZE == 19+7) begin
     assign f0_vf_bar2_aperture = 32'h400_0000; // 64M bytes
     assign f0_vf_bar2_aperture_bitmask = 32'hfc00_0000;
    end
   else if (VF_BAR2_SIZE == 20+7) begin
     assign f0_vf_bar2_aperture = 32'h800_0000; // 128M bytes
     assign f0_vf_bar2_aperture_bitmask = 32'hf800_0000;
    end
   else if (VF_BAR2_SIZE == 21+7) begin
     assign f0_vf_bar2_aperture = 32'h1000_0000; // 256M bytes
     assign f0_vf_bar2_aperture_bitmask = 32'hf000_0000;
    end
   else if (VF_BAR2_SIZE == 22+7) begin
     assign f0_vf_bar2_aperture = 32'h2000_0000; // 512M bytes
     assign f0_vf_bar2_aperture_bitmask = 32'he000_0000;
    end
   else if (VF_BAR2_SIZE == 23+7) begin
     assign f0_vf_bar2_aperture = 32'h4000_0000; // 1G bytes
     assign f0_vf_bar2_aperture_bitmask = 32'hc000_0000;
    end
   else begin
     assign f0_vf_bar2_aperture = 32'h8000_0000; // 2G bytes
     assign f0_vf_bar2_aperture_bitmask = 32'h8000_0000; // 2 Gbytes
    end
     
   end
   endgenerate

   generate begin: find_bar_aperture_settings_f0_vf_bar3

   if (VF_BAR2_TYPE == 1) begin // 64-bit BAR
     assign f0_vf_bar3_aperture = 32'h0;
     assign f0_vf_bar3_aperture_bitmask = 32'hffff_ffff; 
    end
   else if (VF_BAR3_SIZE == 7) begin
     assign f0_vf_bar3_aperture = 32'h80; // 128 bytes
     assign f0_vf_bar3_aperture_bitmask = 32'hffff_ff80; // 128 bytes
    end
   else if (VF_BAR3_SIZE == 8) begin
     assign f0_vf_bar3_aperture = 32'h100; // 256 bytes
     assign f0_vf_bar3_aperture_bitmask = 32'hffff_ff00;
    end
   else if (VF_BAR3_SIZE == 9) begin
     assign f0_vf_bar3_aperture = 32'h200; // 512 bytes
     assign f0_vf_bar3_aperture_bitmask = 32'hffff_fe00;
    end
   else if (VF_BAR3_SIZE == 10) begin
     assign f0_vf_bar3_aperture = 32'h400; // 1024 bytes
     assign f0_vf_bar3_aperture_bitmask = 32'hffff_fc00;
    end
   else if (VF_BAR3_SIZE == 11) begin
     assign f0_vf_bar3_aperture = 32'h800; // 2K bytes
     assign f0_vf_bar3_aperture_bitmask = 32'hffff_f800;
    end
   else if (VF_BAR3_SIZE == 5+7) begin
     assign f0_vf_bar3_aperture = 32'h1000; // 4K bytes
     assign f0_vf_bar3_aperture_bitmask = 32'hffff_f000;
    end
   else if (VF_BAR3_SIZE == 6+7) begin
     assign f0_vf_bar3_aperture = 32'h2000; // 8K bytes
     assign f0_vf_bar3_aperture_bitmask = 32'hffff_e000;
    end
   else if (VF_BAR3_SIZE == 7+7) begin
     assign f0_vf_bar3_aperture = 32'h4000; // 16K bytes
     assign f0_vf_bar3_aperture_bitmask = 32'hffff_c000;
    end
   else if (VF_BAR3_SIZE == 8+7) begin
     assign f0_vf_bar3_aperture = 32'h8000; // 32K bytes
     assign f0_vf_bar3_aperture_bitmask = 32'hffff_8000;
    end
   else if (VF_BAR3_SIZE == 9+7) begin
     assign f0_vf_bar3_aperture = 32'h1_0000; // 64K bytes
     assign f0_vf_bar3_aperture_bitmask = 32'hffff_0000;
    end
   else if (VF_BAR3_SIZE == 10+7) begin
     assign f0_vf_bar3_aperture = 32'h2_0000; // 128K bytes
     assign f0_vf_bar3_aperture_bitmask = 32'hfffe_0000;
    end
   else if (VF_BAR3_SIZE == 11+7) begin
     assign f0_vf_bar3_aperture = 32'h4_0000; // 256K bytes
     assign f0_vf_bar3_aperture_bitmask = 32'hfffc_0000;
    end
   else if (VF_BAR3_SIZE == 12+7) begin
     assign f0_vf_bar3_aperture = 32'h8_0000; // 512K bytes
     assign f0_vf_bar3_aperture_bitmask = 32'hfff8_0000;
    end
   else if (VF_BAR3_SIZE == 13+7) begin
     assign f0_vf_bar3_aperture = 32'h10_0000; // 1M bytes
     assign f0_vf_bar3_aperture_bitmask = 32'hfff0_0000;
    end
   else if (VF_BAR3_SIZE == 14+7) begin
     assign f0_vf_bar3_aperture = 32'h20_0000; // 2M bytes
     assign f0_vf_bar3_aperture_bitmask = 32'hffe0_0000;
    end
   else if (VF_BAR3_SIZE == 15+7) begin
     assign f0_vf_bar3_aperture = 32'h40_0000; // 4M bytes
     assign f0_vf_bar3_aperture_bitmask = 32'hffc0_0000;
    end
   else if (VF_BAR3_SIZE == 16+7) begin
     assign f0_vf_bar3_aperture = 32'h80_0000; // 8M bytes
     assign f0_vf_bar3_aperture_bitmask = 32'hff80_0000;
    end
   else if (VF_BAR3_SIZE == 17+7) begin
     assign f0_vf_bar3_aperture = 32'h100_0000; // 16M bytes
     assign f0_vf_bar3_aperture_bitmask = 32'hff00_0000;
    end
   else if (VF_BAR3_SIZE == 18+7) begin
     assign f0_vf_bar3_aperture = 32'h200_0000; // 32M bytes
     assign f0_vf_bar3_aperture_bitmask = 32'hfe00_0000;
    end
   else if (VF_BAR3_SIZE == 19+7) begin
     assign f0_vf_bar3_aperture = 32'h400_0000; // 64M bytes
     assign f0_vf_bar3_aperture_bitmask = 32'hfc00_0000;
    end
   else if (VF_BAR3_SIZE == 20+7) begin
     assign f0_vf_bar3_aperture = 32'h800_0000; // 128M bytes
     assign f0_vf_bar3_aperture_bitmask = 32'hf800_0000;
    end
   else if (VF_BAR3_SIZE == 21+7) begin
     assign f0_vf_bar3_aperture = 32'h1000_0000; // 256M bytes
     assign f0_vf_bar3_aperture_bitmask = 32'hf000_0000;
    end
   else if (VF_BAR3_SIZE == 22+7) begin
     assign f0_vf_bar3_aperture = 32'h2000_0000; // 512M bytes
     assign f0_vf_bar3_aperture_bitmask = 32'he000_0000;
    end
   else if (VF_BAR3_SIZE == 23+7) begin
     assign f0_vf_bar3_aperture = 32'h4000_0000; // 1G bytes
     assign f0_vf_bar3_aperture_bitmask = 32'hc000_0000;
    end
   else begin
     assign f0_vf_bar3_aperture = 32'h8000_0000; // 2G bytes
     assign f0_vf_bar3_aperture_bitmask = 32'h8000_0000; // 2 Gbytes
    end
     
   end
   endgenerate


   //======================
   // SR_IOV Bridge Top
   //======================
   altpcied_sriov_1pf32vf_top 
     #(
       .port_width_data_hwtcl  (port_width_data_hwtcl),  
       .port_width_be_hwtcl    (port_width_be_hwtcl),    
       .multiple_packets_per_cycle_hwtcl (multiple_packets_per_cycle_hwtcl),
       .VF_COUNT (VF_COUNT),
       .SIG_TEST_EN (SIG_TEST_EN),
       .DROP_POISONED_REQ (DROP_POISONED_REQ),
       .DROP_POISONED_COMPL (DROP_POISONED_COMPL),
       // Device-Level Parameters				      
       .DEVICE_ID(device_id_hwtcl),
       .VENDOR_ID(vendor_id_hwtcl),
       .REVISION_CODE(revision_id_hwtcl),
       .SUBSYS_ID(subsystem_device_id_hwtcl),
       .SUBVENDOR_ID(subsystem_vendor_id_hwtcl),
       .CLASS_CODE(class_code_hwtcl),
       .SUBCLASS_CODE(SUBCLASS_CODE),
       .PCI_PROG_INTFC_BYTE(PCI_PROG_INTFC_BYTE),
       .VF_DEVICE_ID(VF_DEVICE_ID),
       .SLOT_CLK_CONFIGURATION(slotclkcfg_hwtcl),
       .PM_NO_SOFT_RESET(no_soft_reset_hwtcl),
       .AER_CAP_PRESENT(use_aer_hwtcl),
       .MAX_PAYLOAD_SIZE(max_payload_size_hwtcl),
       .AER_SURPRISE_DOWN_REPORTING_CAPABLE(surprise_down_error_support_hwtcl),
       .EXTENDED_TAG_SUPPORT(extend_tag_field_hwtcl),
       .L0S_LATENCY(endpoint_l0_latency_hwtcl),
       .L1_LATENCY(endpoint_l1_latency_hwtcl),
       .L0S_EXIT_LATENCY(l0_exit_latency_sameclock_hwtcl),
       .L1_EXIT_LATENCY(l1_exit_latency_sameclock_hwtcl),
       .ASPM_L0S_SUPPORT(enable_l0s_aspm_hwtcl),
       .ASPM_L1_SUPPORT(enable_l1_aspm_hwtcl),
       .FLR_SUPPORT(flr_capability_hwtcl),
       .COMPLETION_TIMEOUT_RANGES_SUPPORTED(completion_timeout_hwtcl),
       .COMPLETION_TIMEOUT_DISABLE_SUPPORT(enable_completion_timeout_disable_hwtcl),
       .ECRC_GENERATION_SUPPORT(ecrc_gen_capable_hwtcl),
       .ECRC_CHECK_SUPPORT(ecrc_check_capable_hwtcl),
       .RELAXED_ORDER_SUPPORT    (RELAXED_ORDER_SUPPORT),
       .SYSTEM_PAGE_SIZES_SUPPORTED(SYSTEM_PAGE_SIZES_SUPPORTED),
       // INTX pin and line settings
       .F0_INTR_PIN(interrupt_pin_hwtcl),
       .F0_INTR_LINE             (F0_INTR_LINE),
       // MSI parameters
       .MSI_CAP_PRESENT(msi_support_hwtcl),
       .MSI_MULTI_MSG_CAPABLE(msi_multi_message_capable_hwtcl),
       .MSI_64BIT_CAPABLE(msi_64bit_addressing_capable_hwtcl),
       .VF_MSI_CAP_PRESENT(VF_MSI_CAP_PRESENT),
       .VF_MSI_64BIT_CAPABLE     (VF_MSI_64BIT_CAPABLE),
       .VF_MSI_MULTI_MSG_CAPABLE (VF_MSI_MULTI_MSG_CAPABLE),
       // MSIX parameters
       .MSIX_CAP_PRESENT(enable_function_msix_support_hwtcl),
       .MSIX_TBL_SIZE(msix_table_size_hwtcl),
       .MSIX_TBL_OFFSET(msix_table_offset_hwtcl),
       .MSIX_TBL_BIR(msix_table_bir_hwtcl),
       .MSIX_PBA_BIR(msix_pba_bir_hwtcl),
       .MSIX_PBA_OFFSET(msix_pba_offset_hwtcl),
       .VF_MSIX_CAP_PRESENT(VF_MSIX_CAP_PRESENT),
       .VF_MSIX_TBL_SIZE         (VF_MSIX_TBL_SIZE),
       .VF_MSIX_TBL_OFFSET       (VF_MSIX_TBL_OFFSET),
       .VF_MSIX_TBL_BIR          (VF_MSIX_TBL_BIR),
       .VF_MSIX_PBA_OFFSET       (VF_MSIX_PBA_OFFSET),
       .VF_MSIX_PBA_BIR          (VF_MSIX_PBA_BIR),
       // PF BAR parameters
       .PF_BAR0_PRESENT          (PF_BAR0_PRESENT),
       .PF_BAR1_PRESENT          (PF_BAR1_PRESENT),
       .PF_BAR2_PRESENT          (PF_BAR2_PRESENT),
       .PF_BAR3_PRESENT          (PF_BAR3_PRESENT),
       .PF_BAR0_TYPE             (PF_BAR0_TYPE),
       .PF_BAR2_TYPE             (PF_BAR2_TYPE),
       .PF_BAR0_PREFETCHABLE     (PF_BAR0_PREFETCHABLE),
       .PF_BAR1_PREFETCHABLE     (PF_BAR1_PREFETCHABLE),
       .PF_BAR2_PREFETCHABLE     (PF_BAR2_PREFETCHABLE),
       .PF_BAR3_PREFETCHABLE     (PF_BAR3_PREFETCHABLE),
       // VF BAR parameters
       .VF_BAR0_PRESENT          (VF_BAR0_PRESENT),
       .VF_BAR1_PRESENT          (VF_BAR1_PRESENT),
       .VF_BAR2_PRESENT          (VF_BAR2_PRESENT),
       .VF_BAR3_PRESENT          (VF_BAR3_PRESENT),
       .VF_BAR0_TYPE             (VF_BAR0_TYPE),
       .VF_BAR2_TYPE             (VF_BAR2_TYPE),
       .VF_BAR0_PREFETCHABLE     (VF_BAR0_PREFETCHABLE),
       .VF_BAR1_PREFETCHABLE     (VF_BAR1_PREFETCHABLE),
       .VF_BAR2_PREFETCHABLE     (VF_BAR2_PREFETCHABLE),
       .VF_BAR3_PREFETCHABLE     (VF_BAR3_PREFETCHABLE)
       ) 
       altpcied_pcie_sriov_top_inst 
	 (
          .Clk_i			( pld_clk ),
          .Rstn_i			( app_rstn     ),
          .PowerOnRstn_i              (power_on_reset_n),

	  // BAR apertures
          .f0_bar0_aperture_i     ( f0_bar0_aperture ),
	  .f0_bar1_aperture_i     ( f0_bar1_aperture ),
          .f0_bar2_aperture_i     ( f0_bar2_aperture ),
          .f0_bar3_aperture_i     ( f0_bar3_aperture ),

          .f0_vf_bar0_aperture_i  ( f0_vf_bar0_aperture ),
	  .f0_vf_bar1_aperture_i  ( f0_vf_bar1_aperture ),
          .f0_vf_bar2_aperture_i  ( f0_vf_bar2_aperture ),
          .f0_vf_bar3_aperture_i  ( f0_vf_bar3_aperture ),

          .f0_vf_bar0_aperture_bitmask_i  ( f0_vf_bar0_aperture_bitmask ),
          .f0_vf_bar1_aperture_bitmask_i  ( f0_vf_bar1_aperture_bitmask ),
          .f0_vf_bar2_aperture_bitmask_i  ( f0_vf_bar2_aperture_bitmask ),
          .f0_vf_bar3_aperture_bitmask_i  ( f0_vf_bar3_aperture_bitmask ),

          // RX Streaming Interface to HIP 
          .RxStMask_hip_o	    ( rx_st_mask_hip   ),
          .RxStSop_hip_i          ( rx_st_sop_hip    ),
          .RxStEop_hip_i	    ( rx_st_eop_hip    ),
          .RxStErr_hip_i	    ( rx_st_err_hip    ),
          .RxStData_hip_i         ( rx_st_data_hip   ),
          .RxStValid_hip_i        ( rx_st_valid_hip  ),
          .RxStEmpty_hip_i        ( rx_st_empty_hip  ),
          .RxStReady_hip_o        ( rx_st_ready_hip  ),
          .RxStParity_hip_i       ( rx_st_parity_hip ),
	  .RxStBuff_Overflow_i    ( rxfc_cplbuf_ovf_hip ),
	  
          // RX Streaming Interface to app layer
          .RxStMask_app_i	    ( rx_st_mask_app   ),
          .RxStSop_app_o          ( rx_st_sop_app    ),
          .RxStEop_app_o	    ( rx_st_eop_app    ),
          .RxStErr_app_o	    ( rx_st_err_app    ),
          .RxStData_app_o         ( rx_st_data_app   ),
          .RxStValid_app_o        ( rx_st_valid_app  ),
          .RxStEmpty_app_o        ( rx_st_empty_app  ),
          .RxStReady_app_i        ( rx_st_ready_app  ),
          .RxStParity_app_o       ( rx_st_parity_app ),
          .rx_st_bar_hit_tlp0_o   (rx_st_bar_hit_tlp0),
          .rx_st_bar_hit_fn_tlp0_o(rx_st_bar_hit_fn_tlp0),
          .rx_st_bar_hit_tlp1_o   (rx_st_bar_hit_tlp1),
          .rx_st_bar_hit_fn_tlp1_o(rx_st_bar_hit_fn_tlp1),
	  
          // TX Streaming Interface to HIP 
          .TxStSop_hip_o	   ( tx_st_sop_hip    ),
          .TxStEop_hip_o	   ( tx_st_eop_hip    ),
          .TxStErr_hip_o	   ( tx_st_err_hip    ),
          .TxStEmpty_hip_o       ( tx_st_empty_hip  ),
          .TxStData_hip_o	   ( tx_st_data_hip   ),
          .TxStParity_hip_o	   ( tx_st_parity_hip   ),
          .TxStValid_hip_o       ( tx_st_valid_hip  ),
          .TxStReady_hip_i	   ( tx_st_ready_hip  ),
	  
          // TX Streaming Interface to app layer 
          .TxStSop_app_i	   ( tx_st_sop_app    ),
          .TxStEop_app_i	   ( tx_st_eop_app    ),
          .TxStErr_app_i	   ( tx_st_err_app    ),
          .TxStEmpty_app_i       ( tx_st_empty_app  ),
          .TxStData_app_i	   ( tx_st_data_app   ),
          .TxStParity_app_i	   ( tx_st_parity_app   ),
          .TxStValid_app_i       ( tx_st_valid_app  ),
          .TxStReady_app_o	   ( tx_st_ready_app  ),
	  
	  // LMI interface to HIP
          .lmi_addr_hip_o        ( lmi_addr_hip ),
          .lmi_din_hip_o         ( lmi_din_hip ),
          .lmi_rden_hip_o        ( lmi_rden_hip ),
          .lmi_wren_hip_o        ( lmi_wren_hip ),
          .lmi_ack_hip_i         ( lmi_ack_hip ),
          .lmi_dout_hip_i        ( lmi_dout_hip ),
	  
          // LMI interface to user application
	  .lmi_addr_app_i        ({lmi_func_app, lmi_addr_app}),
          .lmi_din_app_i         ( lmi_din_app ),
          .lmi_rden_app_i        ( lmi_rden_app ),
          .lmi_wren_app_i        ( lmi_wren_app ),
          .lmi_ack_app_o         ( lmi_ack_app ),
          .lmi_dout_app_o        ( lmi_dout_app ),
	  
          // Control/Status signals from HIP Config Bypass interface
          .current_speed_i       (cfgbp_current_speed),
          .current_deemph_i      (cfgbp_current_deemph),
          .lane_active_i         (lane_act),
          .dl_prot_err_i         (cfgbp_err_dllrev), 
          .fl_prot_err_i         (cfgbp_txfc_err), 
          .rx_fifo_overflow_i    (cfgbp_err_tlrcvovf), 
          .malf_tlp_rcvd_i       (cfgbp_err_tlmalf),
          .ecrc_err_i            (|cfgbp_rx_st_ecrcerr), 
          .phy_err_i             (cfgbp_err_phy_rcv), 
          .dllp_err_i            (cfgbp_err_dllp_baddllp), 
          .tlp_err_i             (cfgbp_err_dll_badtlp),
          .replay_timeout_i      (cfgbp_err_dllreptim), 
          .replay_timer_rollover_i(cfgbp_err_dll_repnum), 
          .link_control2_reg_reset_enter_compl_i(cfgbp_rst_enter_comp_bit),
          .link_control2_reg_reset_tx_margin_i(cfgbp_rst_tx_margin_field),
	  .lane_error_detected_i (cfgbp_lane_err),
          .link_equalization_req_i(cfgbp_link_equlz_req),
          .link_equalization_complete_i(cfgbp_equiz_complete),
          .link_eq_phase1_successful_i(cfgbp_phase_1_successful),
	  .link_eq_phase2_successful_i(cfgbp_phase_2_successful),
	  .link_eq_phase3_successful_i(cfgbp_phase_3_successful),
          .ltssm_state_i         (ltssmstate),

	 // Config register outputs to HIP
	  .f0_link_control2_reg_o(cfgbp_link2csr),
	  .f0_link_control_reg_com_clk_conf_o(cfgbp_comclk_reg),
	  .f0_link_control_reg_ext_synch_o(cfgbp_extsy_reg),
          .device_control_reg_max_payload_size_o(max_payload_size_int),
          .device_control_reg_read_req_size_o(rd_req_size),
	  .f0_link_control_reg_aspm_ctl_o(cfgbp_linkcsr_bit0),
	  .f0_ecrc_gen_enable_o(cfgbp_tx_ecrcgen),
	  .f0_ecrc_chk_enable_o(cfgbp_rx_ecrchk),

          //========================================================================
          // Interrupt interface
          //======================================================================== 	
          .int_sts_a_i            (app_int_sts_a),
          .int_sts_b_i            (app_int_sts_b),
          .int_sts_c_i            (app_int_sts_c),
          .int_sts_d_i            (app_int_sts_d),
          .int_sts_fn_i           (app_int_sts_fn),
          .int_ack_o              (app_int_ack),
          .msi_req_i              (app_msi_req),
          .msi_ack_o              (app_msi_ack),
          .msi_req_fn_i           (app_msi_req_fn),
          .msi_num_i              (app_msi_num),
          .msi_tc_i               (app_msi_tc),
          .interrupt_pending_i    (app_int_pend_status),
	  .intx_disable_o         (app_intx_disable),
          .msi_en_pf_o            (app_msi_enable_pf),
          .msi_mult_msg_en_pf_o   (app_msi_multi_msg_enable_pf),
          .msi_en_vf_o            (app_msi_enable_vf),
          .msi_mult_msg_en_vf_o   (app_msi_multi_msg_enable_vf),
          .msix_en_pf_o           (app_msix_en_pf),
          .msix_fn_mask_pf_o      (app_msix_fn_mask_pf),
          .msix_en_vf_o           (app_msix_en_vf),
          .msix_fn_mask_vf_o      (app_msix_fn_mask_vf),

          //======================================================================== 	
          // Status and Error input from user application
          //======================================================================== 	
          .compl_timeout_with_recovery_i   (cpl_err[0]),
          .compl_timeout_without_recovery_i(cpl_err[1]),
          .ca_sent_i                       (cpl_err[2]),
          .unexp_compl_rcvd_i              (cpl_err[3]),
          .unsupp_p_req_rcvd_i             (cpl_err[4]),
          .unsupp_np_req_rcvd_i            (cpl_err[5]),
          .app_header_logging_en_i         (cpl_err[6]),
	  .error_reporting_fn_i            (cpl_err_fn),
	  .trans_pending_pf_i		   (cpl_pending_pf),
	  .trans_pending_vf_i		   (cpl_pending_vf),
          .app_log_hdr_i                   (log_hdr),
          .flr_active_pf_o                 (flr_active_pf),
          .flr_completed_pf_i              (flr_completed_pf),
          .flr_active_vf_o                 (flr_active_vf),
          .flr_completed_vf_i              (flr_completed_vf),
          .bus_num_f0_o                    (bus_num_f0),
	  .mem_space_en_pf_o               (mem_space_en_pf),
	  .mem_space_en_vf_o               (mem_space_en_vf),
	  .bus_master_en_pf_o              (bus_master_en_pf),
	  .bus_master_en_vf_o              (bus_master_en_vf),
	  .num_vfs_o                       (num_vfs)
	  );       

   assign   cfgbp_max_pload                  = max_payload_size_int;
   //===============================================================
   // Unused Config Bypass status inputs to HIP, assigned to 0.
   //===============================================================
   assign     cfgbp_secbus		     = 8'h0;   
   assign     cfgbp_tx_req_pm		     = 1'b0;
   assign     cfgbp_tx_typ_pm		     = 3'h0;   
   assign     cfgbp_req_phypm		     = 4'h0;   
   assign     cfgbp_req_phycfg	             = 4'h0;   
   assign     cfgbp_vc0_tcmap_pld            = 7'h0;   
   assign     cfgbp_inh_dllp		     = 1'b0; 
   assign     cfgbp_inh_tx_tlp	             = 1'b0;   
   assign     cfgbp_req_wake		     = 1'b0;  
   assign     cfgbp_link3_ctl                 = 2'h0;
  //-----------------------------------------------------------------------------------------	
  // Pass through HIP status for HWTCL script
   assign     derr_cor_ext_rcv_drv  = derr_cor_ext_rcv;
   assign     derr_cor_ext_rpl_drv  = derr_cor_ext_rpl;
   assign     derr_rpl_drv          = derr_rpl;
   assign     dlup_drv              = dlup;
   assign     dlup_exit_drv         = dlup_exit;
   assign     ev128ns_drv           = ev128ns;
   assign     ev1us_drv             =  ev1us;
   assign     hotrst_exit_drv       = hotrst_exit;
   assign     int_status_drv        = int_status;
   assign     l2_exit_drv           = l2_exit;
   assign     lane_act_drv          = lane_act;
   assign     ltssmstate_drv        = ltssmstate;
   assign     rx_par_err_drv        = rx_par_err;
   assign     tx_par_err_drv        = tx_par_err;
   assign     cfg_par_err_drv       = cfg_par_err;
   assign     ko_cpl_spc_header_drv = ko_cpl_spc_header;
   assign     ko_cpl_spc_data_drv   = ko_cpl_spc_data; 
   assign     rxfc_cplbuf_ovf_app   = rxfc_cplbuf_ovf_hip;
  //-----------------------------------------------------------------------------------------	
   assign     max_payload_size = max_payload_size_int;

   assign device_num_f0 = 5'd0;

endmodule

