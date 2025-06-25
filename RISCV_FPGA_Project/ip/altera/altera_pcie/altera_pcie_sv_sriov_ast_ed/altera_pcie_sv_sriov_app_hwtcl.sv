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


// (C) 2001-2013 Altera Corporation. All rights reserved.
// Your use of Altera Corporation's design tools, logic functions and other 
// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

module altera_pcie_sv_sriov_app_hwtcl # (
   parameter MAX_NUM_FUNC_SUPPORT             = 8,
   parameter num_of_func_hwtcl                = MAX_NUM_FUNC_SUPPORT,
   parameter device_family_hwtcl              = "Stratix V",
   parameter use_crc_forwarding_hwtcl         = 0,
   parameter pld_clockrate_hwtcl              = 125000000,
   parameter lane_mask_hwtcl                  = "x4",
   parameter max_payload_size_hwtcl           = 256,
   parameter gen123_lane_rate_mode_hwtcl      = "Gen1 (2.5 Gbps)",
   parameter ast_width_hwtcl                  = "Avalon-ST 64-bit",
   parameter port_width_data_hwtcl            = 64,
   parameter port_width_be_hwtcl              = 8,
   parameter extend_tag_field_hwtcl           = 32,
   parameter avalon_waddr_hwltcl              = 12,
   parameter check_bus_master_ena_hwtcl       = 1,
   parameter check_rx_buffer_cpl_hwtcl        = 1,
   parameter port_type_hwtcl                  = "Native endpoint",
   parameter apps_type_hwtcl                  = 2,
   parameter multiple_packets_per_cycle_hwtcl = 0,
   parameter VF_COUNT                         = 32,   // Number of Virtual Functions 
   parameter use_ast_parity                   = 0

) (
      // Reset signals

      input                  reset_status,
      input                  serdes_pll_locked,
      input                  pld_clk_inuse,
      output                 pld_core_ready,

      // Clock
      input                  coreclkout_hip,
      output                 pld_clk_hip,
      input                  testin_zero,

      //###################################################################################
      // Legacy and MSI interrupt signals
      //###################################################################################
      output                 app_int_sts_a,
      output                 app_int_sts_b,
      output                 app_int_sts_c,
      output                 app_int_sts_d,
      output [2:0]           app_int_sts_fn, // Function Num associated with the Legacy interrupt request
      input                  app_int_ack,

      output                 app_msi_req,
      input                  app_msi_ack,
      output  [7 : 0]        app_msi_req_fn,
      output  [4 : 0]        app_msi_num,
      output  [2 : 0]        app_msi_tc,

      output                app_int_pend_status,  // Interrupt pending stats from Function
      input                 app_intx_disable,     // INTX Disable from PCI Command Register of PF 0
      input                 app_msi_enable_pf,    // MSI Enable setting of PF 0
      input [2:0]           app_msi_multi_msg_enable_pf,// MSI Multiple Msg field setting of PF 0
      input [VF_COUNT-1:0]  app_msi_enable_vf,// MSI Enable setting of VFs
      input [VF_COUNT*3-1:0] app_msi_multi_msg_enable_vf,// MSI Multiple Msg field setting of VFs
      input                 app_msix_en_pf,       // MSIX Enable bit from MSIX Control Reg of PF 0
      input                 app_msix_fn_mask_pf,  // MSIX Function Mask bit from MSIX Control Reg of PF 0
      input [VF_COUNT-1:0]  app_msix_en_vf,       // MSIX Enable bits from MSIX Control Reg of VFs
      input [VF_COUNT-1:0]  app_msix_fn_mask_vf,  // MSIX Function Mask bits from MSIX Control Reg of VFs

      // BAR hit signals
      input [7:0]     rx_st_bar_hit_tlp0, // BAR hit information for first TLP in this cycle
      input [7:0]     rx_st_bar_hit_fn_tlp0, // Target Function for first TLP in this cycle
      input [7:0]     rx_st_bar_hit_tlp1, // BAR hit information for second TLP in this cycle
      input [7:0]     rx_st_bar_hit_fn_tlp1, // Target Function for second TLP in this cycle

      //###################################################################################
      // LMI
      //###################################################################################

      output  wire [11 : 0]  lmi_addr,
      output  wire [ 8 : 0]  lmi_func,  // [7:0] =  Function Number,
                                        // [ 8] = 0 => access to Hard IP register
                                        // [ 8] = 1 => access to SR-IOV bridge config space
      output  wire [31 : 0]  lmi_din,
      output  wire           lmi_rden,
      output  wire           lmi_wren,


      output  [port_width_data_hwtcl-1  : 0]          tx_st_data,
      output  [((device_family_hwtcl == "Arria V" || device_family_hwtcl == "Cyclone V")?1:2)-1:0] tx_st_empty,
      output  [multiple_packets_per_cycle_hwtcl:0]    tx_st_eop,
      output  [multiple_packets_per_cycle_hwtcl:0]    tx_st_err,
      output  [multiple_packets_per_cycle_hwtcl:0]    tx_st_sop,
      output  [multiple_packets_per_cycle_hwtcl:0]    tx_st_valid,
      output  [port_width_be_hwtcl-1:0]               tx_st_parity,
      input                                           tx_st_ready,
      input                                           tx_fifo_empty,

      // hip_sriov_completion
      output  [6 :0]         cpl_err,
      output  [2 :0]         cpl_err_fn,
      output                 cpl_pending_pf,
      output [VF_COUNT-1:0]  cpl_pending_vf,// Completion pending status from VFs
      output  [127:0]        log_hdr,

   //###################################################################################
   // FLR Interface
   //###################################################################################
    input                 flr_active_pf,    // FLR status for PF 0
    input [VF_COUNT-1:0]  flr_active_vf, // FLR status for VFs
    output                flr_completed_pf, // Indication from user to re-enable PF 0 after FLR
    output [VF_COUNT-1:0] flr_completed_vf, // Indication from user to re-enable VFs after FLR

   //###################################################################################
      // Input HIP Status signals
      input                derr_cor_ext_rcv,
      input                derr_cor_ext_rpl,
      input                derr_rpl,
      input                rx_par_err ,
      input [1:0]          tx_par_err ,
      input                cfg_par_err,
      input                dlup,
      input                dlup_exit,
      input                ev128ns,
      input                ev1us,
      input                hotrst_exit,
      input [3 : 0]        int_status,
      input                l2_exit,
      input [3:0]          lane_act,
      input [4 : 0]        ltssmstate,
      input [7:0]          ko_cpl_spc_header,
      input [11:0]         ko_cpl_spc_data,
      input                rxfc_cplbuf_ovf,

      input                lmi_ack,
      input [31 : 0]       lmi_dout,

      // Output HIP status signals
      output                derr_cor_ext_rcv_drv,
      output                derr_cor_ext_rpl_drv,
      output                derr_rpl_drv,
      output                dlup_drv,
      output                dlup_exit_drv,
      output                ev128ns_drv,
      output                ev1us_drv,
      output                hotrst_exit_drv,
      output [3 : 0]        int_status_drv,
      output                l2_exit_drv,
      output [3:0]          lane_act_drv,
      output [4 : 0]        ltssmstate_drv,
      output                rx_par_err_drv,
      output [1:0]          tx_par_err_drv,
      output                cfg_par_err_drv,
      output [7:0]          ko_cpl_spc_header_drv,
      output [11:0]         ko_cpl_spc_data_drv,

      input [port_width_be_hwtcl-1  :0]            rx_st_parity,
      input [port_width_data_hwtcl-1:0]            rx_st_data,
      output                                       rx_st_ready,
      input [multiple_packets_per_cycle_hwtcl:0]   rx_st_sop,
      input [multiple_packets_per_cycle_hwtcl:0]   rx_st_valid,
      input [((device_family_hwtcl == "Arria V" || device_family_hwtcl == "Cyclone V")?1:2)-1:0] rx_st_empty,
      input [multiple_packets_per_cycle_hwtcl:0]   rx_st_eop,
      input [multiple_packets_per_cycle_hwtcl:0]   rx_st_err,

      output                            rx_st_mask,

      input                sim_pipe_pclk_out,

      // HIP control signals
      output  [4 : 0]        hpg_ctrler,

   //   input [addr_width_delta(num_of_func_hwtcl)+3 : 0] tl_cfg_add,
   //   input [31 : 0]       tl_cfg_ctl,
   //   input [((num_of_func_hwtcl-1)*10)+52 : 0] tl_cfg_sts,
   //   input                tl_cfg_ctl_wr,
   //   input                tl_cfg_sts_wr,

      //==========================
      // Cfg_Status Interface
      //==========================
      input [7:0]          bus_num_f0,       // Captured bus number for Function 0
      input [4:0]          device_num_f0,    // Captured device number for Function 0
      input                mem_space_en_pf,  // Memory Space Enable for PF 0
      input                bus_master_en_pf, // Bus Master Enable for PF 0
      input [VF_COUNT-1:0] mem_space_en_vf,  // Memory Space Enable for VFs (common for all VFs)
      input [VF_COUNT-1:0] bus_master_en_vf, // Bus Master Enable for VFs
      input [7:0]          num_vfs,          // Number of enabled VFs
      input [2:0]          max_payload_size, // Max payload size from Device Control Register of PF 0
      input [2:0]          rd_req_size,      // Read Request Size from Device Control Register of PF 0

      
      //==========================
      // tx credits
      //==========================
      input [11 : 0]       tx_cred_datafccp,
      input [11 : 0]       tx_cred_datafcnp,
      input [11 : 0]       tx_cred_datafcp,
      input [5 : 0]        tx_cred_fchipcons,
      input [5 : 0]        tx_cred_fcinfinite,
      input [7 : 0]        tx_cred_hdrfccp,
      input [7 : 0]        tx_cred_hdrfcnp,
      input [7 : 0]        tx_cred_hdrfcp

      );

      assign                derr_cor_ext_rcv_drv = derr_cor_ext_rcv;
      assign                derr_cor_ext_rpl_drv = derr_cor_ext_rpl;
      assign                derr_rpl_drv = derr_rpl;
      assign                dlup_drv = dlup;
      assign                dlup_exit_drv = dlup_exit;
      assign                ev128ns_drv = ev128ns;
      assign                ev1us_drv =  ev1us;
      assign                hotrst_exit_drv = hotrst_exit;
      assign                int_status_drv = int_status;
      assign                l2_exit_drv = l2_exit;
      assign                lane_act_drv = lane_act;
      assign                ltssmstate_drv = ltssmstate;
      assign		    rx_par_err_drv = rx_par_err;
      assign		    tx_par_err_drv = tx_par_err;
      assign		    cfg_par_err_drv = cfg_par_err;
      assign		    ko_cpl_spc_header_drv = ko_cpl_spc_header;
      assign		    ko_cpl_spc_data_drv = ko_cpl_spc_data;


function integer clogb2 (input integer depth);
begin
   clogb2 = 0;
   for(clogb2=0; depth>1; clogb2=clogb2+1)
      depth = depth >> 1;
end
endfunction
function integer addr_width_delta (input integer num_of_func);
begin
   if (num_of_func > 1) begin
      addr_width_delta = clogb2(MAX_NUM_FUNC_SUPPORT);
   end
   else begin
      addr_width_delta = 0;
   end
end
endfunction

function integer is_pld_clk_250MHz;
   input [8*25:1] l_ast_width;
   input [8*25:1] l_gen123_lane_rate_mode;
   input [8*25:1] l_lane_mask;
   begin
           if ((l_ast_width=="Avalon-ST 64-bit" ) && (l_gen123_lane_rate_mode=="Gen2 (5.0 Gbps)") && (l_lane_mask=="x4")) is_pld_clk_250MHz=1;
      else if ((l_ast_width=="Avalon-ST 64-bit" ) && (l_gen123_lane_rate_mode=="Gen1 (2.5 Gbps)") && (l_lane_mask=="x8")) is_pld_clk_250MHz=1;
      else if ((l_ast_width=="Avalon-ST 128-bit") && (l_gen123_lane_rate_mode=="Gen2 (5.0 Gbps)") && (l_lane_mask=="x8")) is_pld_clk_250MHz=1;
      else                                                                                                                is_pld_clk_250MHz=0;
   end
endfunction

localparam rxtx_st_empty_width = (device_family_hwtcl == "Arria V" || device_family_hwtcl == "Cyclone V") ? 1 : 2;
localparam IS_ROOTPORT= (port_type_hwtcl == "Root port")?1:0;
localparam PLD_CLK_IS_250MHZ = is_pld_clk_250MHz(ast_width_hwtcl, gen123_lane_rate_mode_hwtcl, lane_mask_hwtcl);

//synthesis translate_off
localparam ALTPCIE_ED_SIM_ONLY  = 1;
//synthesis translate_on
//synthesis read_comments_as_HDL on
//localparam ALTPCIE_ED_SIM_ONLY  = 0;
//synthesis read_comments_as_HDL off

wire [  7: 0] open_msi_stream_data0;
wire          open_msi_stream_valid0;
wire [23: 0]  open_cfg_tcvcmap;

wire           app_rstn;
wire [127: 0]  err_desc;
wire [12: 0]   cfg_busdev;
wire [31: 0]   cfg_devcsr;
wire [19: 0]   cfg_io_bas;
wire [31: 0]   cfg_linkcsr;
wire [15: 0]   cfg_msicsr;
wire [11: 0]   cfg_np_bas;
wire [43: 0]   cfg_pr_bas;
wire [31: 0]   cfg_prmcsr;
wire [ 6: 0]   cpl_err_in;

wire [255:0] ZEROS = 256'h0;

wire         reset_status_hip;

wire coreclkout_pll_locked;
wire pld_clk;

reg          derr_cor_ext_rcv_r;
reg          derr_cor_ext_rpl_r;
reg          derr_rpl_r;
reg          rx_par_err_r ;
reg [1:0]    tx_par_err_r ;
reg          cfg_par_err_r;
reg          dlup_r;
reg          dlup_exit_r;
reg          ev128ns_r;
reg          ev1us_r;
reg          hotrst_exit_r;
reg [3 : 0]  int_status_r;
reg          l2_exit_r;
reg [3:0]    lane_act_r;
reg [4 : 0]  ltssmstate_r;
reg [7:0]    ko_cpl_spc_header_r;
reg [11:0]   ko_cpl_spc_data_r;
//reg [addr_width_delta(num_of_func_hwtcl)+3 : 0]  tl_cfg_add_r;
//reg [31 : 0] tl_cfg_ctl_r;
//reg [((num_of_func_hwtcl-1)*10)+52 : 0] tl_cfg_sts_r;
reg [2:0]   reset_status_sync_pldclk_r;

wire        reset_status_sync_pldclk;
wire        app_int_sts_vec_int;
wire        cpl_pending_int;
wire [1:0]  tx_st_empty_int;
wire [7 : 0] rx_st_bar = rx_st_bar_hit_tlp0;


// Root port only: Remove from output ports for SR-IOV
wire  [4 : 0]        aer_msi_num; 
wire  [4 : 0]        pex_msi_num;
wire                 serr_out;



   generate begin : g_cpl_pending_pf
      if (num_of_func_hwtcl==1) begin
         assign cpl_pending_pf = cpl_pending_int;
      end
      else begin
         assign cpl_pending_pf = {7'h0, cpl_pending_int};
      end
   end
   endgenerate

   assign app_int_sts = app_int_sts_vec_int;

   assign tx_st_empty = tx_st_empty_int[rxtx_st_empty_width-1 : 0];


   // Parity is currently not supported in the design example
   assign tx_st_parity =ZEROS[port_width_be_hwtcl-1:0];

   //////////////// SIMULATION-ONLY CONTENTS
   //synthesis translate_off
   initial begin
      reset_status_sync_pldclk_r = 3'b111;
   end
  //synthesis translate_on

   always @(posedge pld_clk or posedge reset_status) begin
      if (reset_status == 1'b1) begin
         reset_status_sync_pldclk_r <= 3'b111;
      end
      else begin
         reset_status_sync_pldclk_r[0] <= 1'b0;
         reset_status_sync_pldclk_r[1] <= reset_status_sync_pldclk_r[0];
         reset_status_sync_pldclk_r[2] <= reset_status_sync_pldclk_r[1];
      end
   end
   assign reset_status_sync_pldclk = reset_status_sync_pldclk_r[2];

   always @(posedge pld_clk or posedge reset_status_sync_pldclk) begin
      if (reset_status_sync_pldclk == 1'b1) begin
          derr_cor_ext_rcv_r  <= 1'b0              ;
          derr_cor_ext_rpl_r  <= 1'b0              ;
          derr_rpl_r          <= 1'b0              ;
          rx_par_err_r        <= 1'b0              ;
          tx_par_err_r        <= ZEROS[1:0]        ;
          cfg_par_err_r       <= 1'b0              ;
          dlup_r              <= 1'b0              ;
          dlup_exit_r         <= 1'b0              ;
          ev128ns_r           <= 1'b0              ;
          ev1us_r             <= 1'b0              ;
          hotrst_exit_r       <= 1'b0              ;
          int_status_r        <= ZEROS[3 : 0]      ;
          l2_exit_r           <= 1'b0              ;
          lane_act_r          <= ZEROS[3:0]        ;
          ltssmstate_r        <= ZEROS[4 : 0]      ;
          ko_cpl_spc_header_r <= ZEROS[7:0]        ;
          ko_cpl_spc_data_r   <= ZEROS[11:0]       ;
         // tl_cfg_add_r        <= 0                 ;
         // tl_cfg_ctl_r        <= ZEROS[31 : 0]     ;
         // tl_cfg_sts_r        <= 0                 ;
      end
      else begin
          derr_cor_ext_rcv_r  <=  derr_cor_ext_rcv ;
          derr_cor_ext_rpl_r  <=  derr_cor_ext_rpl ;
          derr_rpl_r          <=  derr_rpl         ;
          rx_par_err_r        <=  rx_par_err       ;
          tx_par_err_r        <=  tx_par_err       ;
          cfg_par_err_r       <=  cfg_par_err      ;
          dlup_r              <=  dlup             ;
          dlup_exit_r         <=  dlup_exit        ;
          ev128ns_r           <=  ev128ns          ;
          ev1us_r             <=  ev1us            ;
          hotrst_exit_r       <=  hotrst_exit      ;
          int_status_r        <=  int_status       ;
          l2_exit_r           <=  l2_exit          ;
          lane_act_r          <=  lane_act         ;
          ltssmstate_r        <=  ltssmstate       ;
          ko_cpl_spc_header_r <=  ko_cpl_spc_header;
          ko_cpl_spc_data_r   <=  ko_cpl_spc_data  ;
         // tl_cfg_add_r        <=  tl_cfg_add       ;
         // tl_cfg_ctl_r        <=  tl_cfg_ctl       ;
         // tl_cfg_sts_r        <=  tl_cfg_sts       ;
      end
   end

   assign reset_status_hip = ~reset_status_sync_pldclk;

   altpcierd_hip_rs rs_hip (
      .npor             (reset_status_hip & pld_clk_inuse),
      .pld_clk          (pld_clk),
      .dlup_exit        (dlup_exit),
      .hotrst_exit      (reset_status_hip),
      .l2_exit          (l2_exit),
      .ltssm            (ltssmstate),
      .app_rstn         (app_rstn),
      .test_sim         (testin_zero)
   );

   wire    [port_width_be_hwtcl-1  :0] rx_st_be  = 0; // TBD => Temporarily tied to zer0. Must be derived for CDMA, but not used for 256bit
   wire    [ 81: 0] rx_stream_data0;
   wire    [ 81: 0] rx_stream_data0_1;

   generate begin : g_rxstream
      if (ast_width_hwtcl=="Avalon-ST 128-bit") begin
         assign rx_stream_data0   = {rx_st_be[7 : 0], rx_st_sop[0], rx_st_empty[0], rx_st_bar, rx_st_data[63 : 0]} ;
         assign rx_stream_data0_1 = {rx_st_be[15: 8], rx_st_sop[0], rx_st_eop[0], rx_st_bar, rx_st_data[127 : 64]} ;
      end
      else begin
         assign rx_stream_data0   = {rx_st_be[7:0], rx_st_sop[0], rx_st_eop[0], rx_st_bar, rx_st_data};
         assign rx_stream_data0_1 = 82'h0;
      end
   end
   endgenerate


   generate begin : g_chaining_dma

      if (((ast_width_hwtcl=="Avalon-ST 64-bit")||(ast_width_hwtcl=="Avalon-ST 128-bit")) && (IS_ROOTPORT == 0)) begin

         wire    [ 74: 0] tx_stream_data0;
         wire    [ 74: 0] tx_stream_data0_1;
         wire    [127:0]  tx_st_data_int;

         assign tx_st_sop[0]  = tx_stream_data0[73];
         assign tx_st_err     = (multiple_packets_per_cycle_hwtcl==1)?{1'b0, tx_stream_data0[74]}:tx_stream_data0[74];
         assign tx_st_eop[0]                          = (ast_width_hwtcl=="Avalon-ST 128-bit")?tx_stream_data0_1[72]                              : tx_stream_data0[72];
         assign tx_st_empty_int[0]                    = (ast_width_hwtcl=="Avalon-ST 128-bit")?tx_stream_data0[72]                                : 1'b0;
         assign tx_st_empty_int[1]                    = 1'b0;
         assign tx_st_data_int                        = (ast_width_hwtcl=="Avalon-ST 128-bit")?{tx_stream_data0_1[63 : 0],tx_stream_data0[63 : 0]}: {64'h0,tx_stream_data0[63 : 0]} ;
         assign tx_st_data[port_width_data_hwtcl-1:0] = tx_st_data_int[port_width_data_hwtcl-1:0];

         altpcierd_example_app_chaining # (

            .AVALON_WADDR           (avalon_waddr_hwltcl),
            .CHECK_BUS_MASTER_ENA   (check_bus_master_ena_hwtcl),
            .CHECK_RX_BUFFER_CPL    (check_rx_buffer_cpl_hwtcl ),
            .CLK_250_APP            (is_pld_clk_250MHz(ast_width_hwtcl, gen123_lane_rate_mode_hwtcl, lane_mask_hwtcl )),
            .ECRC_FORWARD_CHECK     (0),
            .ECRC_FORWARD_GENER     (0),
            .MAX_NUMTAG             (20),
            .MAX_PAYLOAD_SIZE_BYTE  (max_payload_size_hwtcl),
            .TL_SELECTION           ((ast_width_hwtcl=="Avalon-ST 128-bit")?7:6),
            .INTENDED_DEVICE_FAMILY (device_family_hwtcl),
            .TXCRED_WIDTH           (36)

            ) app (

            .clk_in      (pld_clk),
            .rstn        (app_rstn),
            .test_sim    (testin_zero),

            .aer_msi_num (aer_msi_num),
            .app_int_ack (app_int_ack),
            .app_int_sts (app_int_sts_vec_int),
            .app_msi_ack (app_msi_ack),
            .app_msi_num (app_msi_num),
            .app_msi_req (app_msi_req),
            .app_msi_tc  (app_msi_tc),

            .pex_msi_num (pex_msi_num),
            .pm_data     (),

            .cfg_busdev  ({bus_num_f0, device_num_f0}),
            .cfg_devcsr  (cfg_devcsr),
            .cfg_linkcsr (cfg_linkcsr),
            .cfg_msicsr  (cfg_msicsr),
            .cfg_prmcsr  (cfg_prmcsr),
            .cfg_tcvcmap (ZEROS[23:0]),

            .cpl_err          (cpl_err_in),
            .cpl_pending      (cpl_pending_int),
            .err_desc         (err_desc),
            .ko_cpl_spc_vc0   ({ko_cpl_spc_data,ko_cpl_spc_header}),

            .msi_stream_data0    (open_msi_stream_data0),
            .msi_stream_ready0   (1'b0),
            .msi_stream_valid0   (open_msi_stream_valid0),
            .tx_stream_fifo_empty0  (tx_fifo_empty),

            .rx_stream_data0_0      (rx_stream_data0),
            .rx_stream_data0_1      (rx_stream_data0_1),
            .rx_stream_mask0        (rx_st_mask),
            .rx_stream_ready0       (rx_st_ready),
            .rx_stream_valid0       (rx_st_valid[0]),

            .tx_stream_cred0        ({tx_cred_datafccp[11 : 0], tx_cred_hdrfccp[2 : 0], tx_cred_datafcnp[2 : 0],tx_cred_hdrfcnp[2 : 0],tx_cred_datafcp[11 : 0],tx_cred_hdrfcp[2 : 0]}),
            .tx_stream_data0_0      (tx_stream_data0),
            .tx_stream_data0_1      (tx_stream_data0_1),
            .tx_stream_mask0        (1'b0),
            .tx_stream_ready0       (tx_st_ready),
            .tx_stream_valid0       (tx_st_valid[0])
         );
   end
end
endgenerate

generate begin : g_256b_target
   if ((ast_width_hwtcl=="Avalon-ST 256-bit") && (IS_ROOTPORT == 0)) begin

         altpcied_cfbp_top #(
            .ast_width_hwtcl        ( ast_width_hwtcl     ),
            .AVALON_WADDR           ( avalon_waddr_hwltcl ),
            .AVALON_WDATA           ( port_width_data_hwtcl),
            .CB_RXM_DATA_WIDTH      ( 32 ) ,
            .VF_COUNT               (VF_COUNT ),
            .INTENDED_DEVICE_FAMILY ( device_family_hwtcl )
         ) altpcierd_cfbp_top (
            .Clk_i			            ( pld_clk      ),
            .Rstn_i			            ( app_rstn     ),
            .RxStMask_o	            ( rx_st_mask   ),
            .RxStSop_i		          ( rx_st_sop    ),
            .RxStEop_i	            ( rx_st_eop    ),
            .RxStData_i		          ( rx_st_data   ),
            .RxStValid_i	          ( rx_st_valid[0]  ),
            .RxStReady_o	          ( rx_st_ready  ),
            .TxStReady_i	          ( tx_st_ready  ),
            .TxStSop_o	            ( tx_st_sop[0]    ),
            .TxStEop_o	            ( tx_st_eop[0]    ),
            .TxStEmpty_o            ( tx_st_empty_int ),
            .TxStData_o	            ( tx_st_data   ),
            .TxStValid_o            ( tx_st_valid[0] ),
            .TxStErr_o              ( tx_st_err[0] ),
            .rx_st_bar_hit_tlp0     ( rx_st_bar_hit_tlp0),
            .rx_st_bar_hit_fn_tlp0  ( rx_st_bar_hit_fn_tlp0),
            .rx_st_bar_hit_tlp1     ( rx_st_bar_hit_tlp1),
            .rx_st_bar_hit_fn_tlp1  ( rx_st_bar_hit_fn_tlp1),
            .mem_space_en_pf        ( mem_space_en_pf),
            .bus_master_en_pf       ( bus_master_en_pf),
            .mem_space_en_vf        ( mem_space_en_vf),
            .bus_master_en_vf       ( bus_master_en_vf),
            .bus_num_f0             ( bus_num_f0),
            .device_num_f0          ( device_num_f0),
   // MSI Interrupts
            .app_intx_disable            ( app_intx_disable            ),     
            .app_msi_enable_pf           ( app_msi_enable_pf           ),   
            .app_msi_multi_msg_enable_pf ( app_msi_multi_msg_enable_pf ),
            .app_msi_enable_vf           ( app_msi_enable_vf           ),
            .app_msi_multi_msg_enable_vf ( app_msi_multi_msg_enable_vf ),
            .app_msi_req                 ( app_msi_req                 ),
            .app_msi_ack                 ( app_msi_ack                 ),
            .app_msi_req_fn              ( app_msi_req_fn              ),
            .app_msi_num                 ( app_msi_num                 ),
            .app_msi_tc                  ( app_msi_tc                  ),
            .app_int_sts_a               ( app_int_sts_a               ),
            .app_int_sts_b               ( app_int_sts_b               ),
            .app_int_sts_c               ( app_int_sts_c               ),
            .app_int_sts_d               ( app_int_sts_d               ),
            .app_int_sts_fn              ( app_int_sts_fn              ), 
            .app_int_pend_status         ( app_int_pend_status         ),
            .app_int_ack                 ( app_int_ack                 ),
            .lmi_ack                     ( lmi_ack                     ),
            .lmi_dout                    ( lmi_dout                    ),
            .lmi_addr                    ( lmi_addr                    ),
            .lmi_func                    ( lmi_func                    ),  
            .lmi_din                     ( lmi_din                     ),
            .lmi_rden                    ( lmi_rden                    ),
            .lmi_wren                    ( lmi_wren                    )
   );       
   end // if
end
endgenerate

// Power management
assign pme_to_cr     =1'b0;
// Hot plug
assign hpg_ctrler = 5'h0;

assign pld_core_ready =  serdes_pll_locked;

   //synthesis translate_off
   assign pld_clk = coreclkout_hip;
   //synthesis translate_on

   //synthesis read_comments_as_HDL on
   //global u_global_buffer_coreclkout (.in(coreclkout_hip), .out(pld_clk));
   //synthesis read_comments_as_HDL off

   assign pld_clk_hip   = coreclkout_hip;

  //=========================================
  // Tie undriven output to default values
  //=========================================
  assign cpl_pending_vf = 1'b0;
  assign log_hdr        = 128'h0;
  assign cpl_err_fn     = 8'h0;

  assign flr_completed_pf = 1'b1;   // Indication from user to re-enable PF 0 after FLR
  assign flr_completed_vf = 32'hFFFFFFFF;  // Indication from user to re-enable VFs after FLR


endmodule

