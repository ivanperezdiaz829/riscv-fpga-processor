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


// (C) 2001-2012 Altera Corporation. All rights reserved.
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
//  * This Verilog HDL file is used for simulation and synthesis in
//  * the chaining DMA design example. It manage the interface between the
//  * chaining DMA and the Avalon Streaming ports
//  */
// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

// synthesis verilog_input_version verilog_2001
// turn off superfluous verilog processor warnings
// altera message_level Level1
// altera message_off 10034 10035 10036 10037 10230 10240 10030

//-----------------------------------------------------------------------------
// Title         : PCI Express Reference Design Example Application
// Project       : PCI Express MegaCore function
//-----------------------------------------------------------------------------
// File          : altpcierd_example_app_chaining.v
// Author        : Altera Corporation
//-----------------------------------------------------------------------------
//
// AVALON_WDATA    : Width of the data port of the on chip Avalon memory
// AVALON_WADDR    : Width of the address port of the on chip Avalon memory
// MAX_NUMTAG      : Indicates the maximum number of PCIe tags
// BOARD_DEMO      : Indicates to the software application which board is being
//                   used
//                    0 - Altera Stratix II GX  x1
//                    1 - Altera Stratix II GX  x4
//                    2 - Altera Stratix II GX  x8
//                    3 - Cyclone II            x1
//                    4 - Arria GX              x1
//                    5 - Arria GX              x4
//                    6 - Custom PHY            x1
//                    7 - Custom PHY            x4
// USE_RCSLAVE     : When USE_RCSLAVE is set an additional module (~1000 LE)
//                   is added to the design to provide instrumentation to the
//                   PCI Express Chained DMA design such as Performance
//                   counter, debug register and EP memory Write a Read by
//                   bypassing the DMA engine.
// TXCRED_WIDTH    : Width of the PCIe tx_cred back bus
// TL_SELECTION    : Interface type
//                    0 : Descriptor data interface (in use with ICM)
//                    6 : Avalon-ST interface
//                    7:  Avalon-ST 128bit interface
// MAX_PAYLOAD_SIZE_BYTE : Indicates the Maxpayload parameter specified in the
//                         PCIe MegaWizzard
//
module altpcied_cfbp_app_example #(
   parameter avalon_waddr_hwltcl    = 20,  // original 12
   parameter port_width_data_hwtcl  = 128,
   parameter port_width_be_hwtcl    = 16,
   parameter DEVIDE_ID              = 16'hE001,
   parameter VENDOR_ID              = 16'h1172,
   parameter SUBSYS_ID              = 16'h1234,
   parameter SUBVENDOR_ID           = 16'h5678,
   parameter BAR0_PREFETCHABLE      = 1'b1,  
   parameter BAR0_TYPE              = 2'h2, // support 64bit 
   parameter multiple_packets_per_cycle_hwtcl       = 0,
   parameter num_of_func_hwtcl      = 1,
   parameter gen123_lane_rate_mode_hwtcl   = "Gen1 (2.5 Gbps)",
   parameter pld_clockrate_hwtcl    = 125000000,
   parameter ast_width_hwtcl        = "Avalon-ST 128-bit",
   parameter device_family_hwtcl    ="Stratix V"
   ) (


   // Clocks
   input                  coreclkout_hip,
   output wire            pld_clk_hip,

   // Resets
   input                  testin_zero,
   input                  reset_status,
   input                  serdes_pll_locked,
   input                  pld_clk_inuse,
   output  wire           pld_core_ready,

   // Avalon streaming interface Receive Data
   input [multiple_packets_per_cycle_hwtcl:0]   rx_st_sop,
   input [multiple_packets_per_cycle_hwtcl:0]   rx_st_eop,
   input [multiple_packets_per_cycle_hwtcl:0]   rx_st_err,  // TBD => not used
   input [multiple_packets_per_cycle_hwtcl:0]   rx_st_valid,
   input [((device_family_hwtcl == "Arria V" || device_family_hwtcl == "Cyclone V")?1:2)-1:0] rx_st_empty,
   //input [1:0] rx_st_empty,
   output  wire                 rx_st_ready,
   input [port_width_data_hwtcl-1:0]     rx_st_data,
   input [port_width_be_hwtcl-1  :0]      rx_st_parity,
   input [7:0]                  rx_st_bar,  // Not used added for HWTCL script
   input [port_width_be_hwtcl-1  :0]      rx_st_be,   // Not used for single dword 
   output  wire                 rx_st_mask, // Hardwire to zero

   // Avalon streaming interface Transmit Data
   output wire  [multiple_packets_per_cycle_hwtcl:0]    tx_st_sop,
   output wire  [multiple_packets_per_cycle_hwtcl:0]    tx_st_eop,
   output wire  [multiple_packets_per_cycle_hwtcl:0]    tx_st_err,
   output wire  [multiple_packets_per_cycle_hwtcl:0]    tx_st_valid,
   output wire  [((device_family_hwtcl == "Arria V" || device_family_hwtcl == "Cyclone V")?1:2)-1:0] tx_st_empty,
   //output wire  [1:0] tx_st_empty,
   input  wire                          tx_st_ready,
   output wire  [port_width_data_hwtcl-1  : 0]   tx_st_data,
   output wire  [port_width_be_hwtcl-1:0]         tx_st_parity,
   input                                tx_fifo_empty, // TBD => Not used for single dword
   
   // LMI interface
   output  [addr_width_delta(num_of_func_hwtcl)+11 : 0] lmi_addr,
   output  [31 : 0]     lmi_din,
   output               lmi_rden,
   output               lmi_wren,
   input                lmi_ack,
   input [31 : 0]       lmi_dout,

    // HIP Status signals
    input                derr_cor_ext_rcv,
    input                derr_cor_ext_rpl,
    input                derr_rpl,
    input                dlup_exit,
    input                ev128ns,
    input                ev1us,
    input                hotrst_exit,
    input [3 : 0]        int_status,
    input                l2_exit,          // used by reset block
    input [3:0]          lane_act,
    input [4 : 0]        ltssmstate,       // used by reset block  
    input                dlup,
    input                rx_par_err ,
    input [1:0]          tx_par_err ,
    input                cfg_par_err,
    input [7:0]          ko_cpl_spc_header,
    input [11:0]         ko_cpl_spc_data,

   //HIP passthrough outputs
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
    output                rx_par_err_drv ,
    output [1:0]          tx_par_err_drv ,
    output                cfg_par_err_drv,
    output [7:0]          ko_cpl_spc_header_drv,
    output [11:0]         ko_cpl_spc_data_drv,

   //=====================
   // Config Bypass I/O
   //=====================
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
   output  [1:0]          cfgbp_link3_ctl,      

   //========================================================================
   // The following Config-Bypass inputs are not connected anywhere because
   // the config-space is not fully implemented in the example design
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
   input                  cfgbp_unc_err_reg_sts         
   );

   // Local parameters
   localparam CB_RXM_DATA_WIDTH     = 32;
   localparam BAR0_MEMSPACE         = 1'b0;  

function integer addr_width_delta (input integer num_of_func);
begin
   if (num_of_func > 1) begin
      addr_width_delta = clogb2(num_of_func_hwtcl);
   end
   else begin
      addr_width_delta = 0;
   end
end

endfunction
   // Clock and reset
   wire           pld_clk;
   wire           app_rstn;

   // LMI inputs
   wire [11:0]    lmi_addr_int;
   wire [127: 0]  err_desc;
   wire [6:0]     cpl_err_in;
   
   // Unconnected ouputs
   wire [6:0]     open_cpl_err_out;          // cpl_err bits from application.  edge sensitive inputs.
   wire           open_cplerr_lmi_busy;

//======================
// Generated clock
//======================
   assign pld_clk_hip   = coreclkout_hip;
   assign pld_clk       = coreclkout_hip;

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


//======================
// LMI interface
//======================

   function integer clogb2 (input integer depth);
   begin
      clogb2 = 0;
      for(clogb2=0; depth>1; clogb2=clogb2+1)
         depth = depth >> 1;
   end
   endfunction

   generate begin : g_lmi_addr
      if (num_of_func_hwtcl== 1) begin
         assign lmi_addr = lmi_addr_int;
      end
      else begin
         assign lmi_addr = {{clogb2(num_of_func_hwtcl){1'b0}}, lmi_addr_int};
      end
   end
   endgenerate

   // Since no error is supported in the CFGBP APP, hardwire error signals to zero
   assign err_desc = 128'h0;
   assign cpl_err_in = 7'h0;    

   generate begin : g_lmi_blk
     altpcierd_cplerr_lmi lmi_blk (
        .clk_in (pld_clk),
        .rstn (app_rstn),
        .cpl_err_in (cpl_err_in),
        .cpl_err_out (open_cpl_err_out),
        .cplerr_lmi_busy (open_cplerr_lmi_busy),
        .err_desc (err_desc),
        .lmi_ack (lmi_ack),
        .lmi_addr (lmi_addr_int),
        .lmi_din (lmi_din),
        .lmi_rden (lmi_rden),
        .lmi_wren (lmi_wren)
     );
   end
   endgenerate

//======================
// Config Bypass Apps
//======================
         altpcied_cfbp_top #(
            .ast_width_hwtcl        ( ast_width_hwtcl     ),
            .AVALON_WADDR           ( avalon_waddr_hwltcl ),
            .AVALON_WDATA           ( port_width_data_hwtcl),
            .CB_RXM_DATA_WIDTH      ( CB_RXM_DATA_WIDTH ) ,
            .DEVIDE_ID              ( DEVIDE_ID         ) ,
            .VENDOR_ID              ( VENDOR_ID         ) ,
            .SUBSYS_ID              ( SUBSYS_ID         ) ,
            .SUBVENDOR_ID           ( SUBVENDOR_ID      ) ,
            .BAR0_PREFETCHABLE      ( BAR0_PREFETCHABLE ) ,  
            .BAR0_TYPE              ( BAR0_TYPE         ) ,
            .BAR0_MEMSPACE          ( BAR0_MEMSPACE     ) ,  
            .INTENDED_DEVICE_FAMILY ( device_family_hwtcl )
         ) altpcierd_cfbp_top (
            .Clk_i			( pld_clk      ),
            .Rstn_i			( app_rstn     ),
            .RxStMask_o	   ( rx_st_mask   ),
            .RxStSop_i		( rx_st_sop    ),
            .RxStEop_i	   ( rx_st_eop    ),
            .RxStData_i		( rx_st_data   ),
            .RxStValid_i	( rx_st_valid  ),
            .RxStReady_o	( rx_st_ready  ),
            .TxStReady_i	( tx_st_ready  ),
            .TxStSop_o	   ( tx_st_sop    ),
            .TxStEop_o	   ( tx_st_eop    ),
            .TxStEmpty_o   ( tx_st_empty  ),
            .TxStData_o	   ( tx_st_data   ),
            .TxStValid_o   ( tx_st_valid  )
   );       

   //===========================
   // Default outputs signals
   //===========================
   assign tx_st_parity = 0; // don't support parity
   assign tx_st_err    = 0; // No error checking
   
   //===============================================================
   // Config Bypass status => eventually must be derived from the
   // user configuration space. 
   //===============================================================
   assign     cfgbp_link2csr  =  (gen123_lane_rate_mode_hwtcl ==  "Gen3 (8.0 Gbps)") ? 13'h3 : ((gen123_lane_rate_mode_hwtcl =="Gen2 (5.0 Gbps)") ? 13'h2 : 13'h1);   //  Gen1 speed
   assign     cfgbp_comclk_reg     = 1'b0;
   assign     cfgbp_extsy_reg		  = 1'b0;
   assign     cfgbp_max_pload		  = 3'h0;   
   assign     cfgbp_tx_ecrcgen     = 1'b0;
   assign     cfgbp_rx_ecrchk		  = 1'b0;
   assign     cfgbp_secbus		     = 8'h0;   
   assign     cfgbp_linkcsr_bit0   = 1'b0;
   assign     cfgbp_tx_req_pm		  = 1'b0;
   assign     cfgbp_tx_typ_pm		  = 3'h0;   
   assign     cfgbp_req_phypm		  = 4'h0;   
   assign     cfgbp_req_phycfg	  = 4'h0;   
   assign     cfgbp_vc0_tcmap_pld  = 7'h0;   
   assign     cfgbp_inh_dllp		  = 1'b0; 
   assign     cfgbp_inh_tx_tlp	  = 1'b0;   
   assign     cfgbp_req_wake		  = 1'b0;  
   assign     cfgbp_link3_ctl      = 2'h0;

   // Pass through HIP status for HWTCL script
   assign     derr_cor_ext_rcv_drv  = derr_cor_ext_rcv;
   assign     derr_cor_ext_rpl_drv  = derr_cor_ext_rpl;
   assign     derr_rpl_drv          = derr_rpl;
   assign     dlup_exit_drv         = dlup_exit;
   assign     ev128ns_drv           = ev128ns;
   assign     ev1us_drv             =  ev1us;
   assign     hotrst_exit_drv       = hotrst_exit;
   assign     int_status_drv        = int_status;
   assign     l2_exit_drv           = l2_exit;
   assign     lane_act_drv          = lane_act;
   assign     ltssmstate_drv        = ltssmstate;
   assign     dlup_drv              = dlup            ;
   assign     rx_par_err_drv        = rx_par_err      ;
   assign     tx_par_err_drv        = tx_par_err      ;
   assign     cfg_par_err_drv       = cfg_par_err     ;
   assign     ko_cpl_spc_header_drv = ko_cpl_spc_header;
   assign     ko_cpl_spc_data_drv   = ko_cpl_spc_data ;

   // Reset related signals
   assign pld_core_ready =  serdes_pll_locked;

endmodule
