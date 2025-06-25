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


// Downstream only EP application
//
// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on
/////////////////////////////////////////////////////////////////////////////////////////////////////
// RX Header
// Downstream Memory TLP Format Header
//       ||31                                                                  0||
//       ||7|6|5|4|3|2|1|0|7|6|5|4|3|2|1|0 | 7|6 |5|4 |3|2|1|0 | 7|6|5|4|3|2|1|0||
// rx_h0 ||R|Fmt| type    |R|TC   |  R     |TD|EP|Attr|R  |  Length             ||
// rx_h1 ||     Requester ID               |     Tag           |LastBE  |FirstBE||
// rx_h2 ||                          Address [63:32]                            ||
// rx_h4 ||                          Address [31: 2]                        | R ||
//
// Downstream Completer TLP Format Header
//       ||31                                                                  0||
//       ||7|6|5|4|3|2|1|0|7|6|5|4|3|2|1|0 | 7|6 |5|4 |3|2|1|0 | 7|6|5|4|3|2|1|0||
// rx_h0 ||R|Fmt| type    |R|TC   |  R     |TD|EP|Attr|R  |  Length             ||
// rx_h1 ||    Completer ID                |Cplst| |  Byte Count                ||
// rx_h2 ||     Requester ID               |     Tag           |LastBE  |FirstBE||
//
//
module altpcied_sv_hwtcl # (
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

      // AST TX
      output  [port_width_data_hwtcl-1  : 0]          tx_st_data,
      output  [((device_family_hwtcl == "Arria V" || device_family_hwtcl == "Cyclone V")?1:2)-1:0] tx_st_empty,
      output  [multiple_packets_per_cycle_hwtcl:0]    tx_st_eop,
      output  [multiple_packets_per_cycle_hwtcl:0]    tx_st_err,
      output  [multiple_packets_per_cycle_hwtcl:0]    tx_st_sop,
      output  [multiple_packets_per_cycle_hwtcl:0]    tx_st_valid,
      output  [port_width_be_hwtcl-1:0]               tx_st_parity,
      input                                           tx_st_ready,
      input                                           tx_fifo_empty,

      // AST RX
      input [port_width_be_hwtcl-1  :0]            rx_st_parity,
      input [port_width_data_hwtcl-1:0]            rx_st_data,
      output                                       rx_st_ready,
      input [multiple_packets_per_cycle_hwtcl:0]   rx_st_sop,
      input [multiple_packets_per_cycle_hwtcl:0]   rx_st_valid,
      input [((device_family_hwtcl == "Arria V" || device_family_hwtcl == "Cyclone V")?1:2)-1:0] rx_st_empty,
      input [multiple_packets_per_cycle_hwtcl:0]   rx_st_eop,
      input [multiple_packets_per_cycle_hwtcl:0]   rx_st_err,

      input [port_width_be_hwtcl-1  :0] rx_st_be,
      output                            rx_st_mask,
      input [7 : 0]                     rx_st_bar,
      input [2 : 0]        rx_bar_dec_func_num,

      // HIP control signals
      output  [4 : 0]                  hpg_ctrler,
      output  [6 :0]                   cpl_err,
      output  [num_of_func_hwtcl-1:0]  cpl_pending,
      output  [2 :0]                   cpl_err_func,

      output  [addr_width_delta(num_of_func_hwtcl)+11 : 0] lmi_addr,
      output  [31 : 0]       lmi_din,
      output                 lmi_rden,
      output                 lmi_wren,
      output                 pm_auxpwr,
      output  [9 : 0]        pm_data,
      output                 pme_to_cr,
      output                 pm_event,
      output  [2 : 0]        pm_event_func,


      // Application signals inputs
      output  [4 : 0]        aer_msi_num,
      output  [(2**addr_width_delta(num_of_func_hwtcl))-1 : 0] app_int_sts,
      output  [2 : 0]        app_msi_func,
      output  [4 : 0]        app_msi_num,
      output                 app_msi_req,
      output  [2 : 0]        app_msi_tc,
      output  [4 : 0]        pex_msi_num,

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

      input                app_int_ack,
      input                app_msi_ack,
      input                lmi_ack,
      input [31 : 0]       lmi_dout,
      input                pme_to_sr,

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
      input                serr_out,
      input                sim_pipe_pclk_out,

      input [addr_width_delta(num_of_func_hwtcl)+3 : 0] tl_cfg_add,
      input [31 : 0]       tl_cfg_ctl,
      input [((num_of_func_hwtcl-1)*10)+52 : 0] tl_cfg_sts,
      input                tl_cfg_ctl_wr,
      input                tl_cfg_sts_wr,

      // tx credits
      input [11 : 0]       tx_cred_datafccp,
      input [11 : 0]       tx_cred_datafcnp,
      input [11 : 0]       tx_cred_datafcp,
      input [5 : 0]        tx_cred_fchipcons,
      input [5 : 0]        tx_cred_fcinfinite,
      input [7 : 0]        tx_cred_hdrfccp,
      input [7 : 0]        tx_cred_hdrfcnp,
      input [7 : 0]        tx_cred_hdrfcp

      );
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


localparam [255:0] ZEROS = 256'h0;

//synthesis translate_off
localparam ALTPCIE_ED_SIM_ONLY  = 1;
//synthesis translate_on
//synthesis read_comments_as_HDL on
//localparam ALTPCIE_ED_SIM_ONLY  = 0;
//synthesis read_comments_as_HDL off


// Reset synchronizer
wire pld_clk;
wire rst_pldclk;
reg [2:0] rst_pldclk_r;

reg  [12: 0] cfg_busdev;

//////////////////////////////////////////////////////////////////////
//
// 64 Bit Interface
//
generate begin : g_ep_dwn
   if (ast_width_hwtcl=="Avalon-ST 64-bit") begin
      altpcied_ep_64bit_downstream # (
               .MAX_NUM_FUNC_SUPPORT             (MAX_NUM_FUNC_SUPPORT            ),
               .num_of_func_hwtcl                (num_of_func_hwtcl               ),
               .device_family_hwtcl              (device_family_hwtcl             ),
               .use_crc_forwarding_hwtcl         (use_crc_forwarding_hwtcl        ),
               .pld_clockrate_hwtcl              (pld_clockrate_hwtcl             ),
               .lane_mask_hwtcl                  (lane_mask_hwtcl                 ),
               .max_payload_size_hwtcl           (max_payload_size_hwtcl          ),
               .gen123_lane_rate_mode_hwtcl      (gen123_lane_rate_mode_hwtcl     ),
               .ast_width_hwtcl                  (ast_width_hwtcl                 ),
               .port_width_data_hwtcl            (port_width_data_hwtcl           ),
               .port_width_be_hwtcl              (port_width_be_hwtcl             ),
               .extend_tag_field_hwtcl           (extend_tag_field_hwtcl          ),
               .avalon_waddr_hwltcl              (avalon_waddr_hwltcl             ),
               .check_bus_master_ena_hwtcl       (check_bus_master_ena_hwtcl      ),
               .check_rx_buffer_cpl_hwtcl        (check_rx_buffer_cpl_hwtcl       ),
               .port_type_hwtcl                  (port_type_hwtcl                 ),
               .apps_type_hwtcl                  (apps_type_hwtcl                 ),
               .multiple_packets_per_cycle_hwtcl (multiple_packets_per_cycle_hwtcl),
               .use_ast_parity                   (use_ast_parity                  )
            ) altpcied_ep_64bit_downstream (
               .pld_clk              (pld_clk),
               .rst_pldclk           (rst_pldclk),
               .cfg_busdev           (cfg_busdev),
               .tx_st_data           (tx_st_data),
               .tx_st_empty          (tx_st_empty),
               .tx_st_eop            (tx_st_eop),
               .tx_st_err            (tx_st_err),
               .tx_st_sop            (tx_st_sop),
               .tx_st_valid          (tx_st_valid),
               .tx_st_parity         (tx_st_parity),
               .tx_st_ready          (tx_st_ready),
               .tx_fifo_empty        (tx_fifo_empty),
               .rx_st_parity         (rx_st_parity),
               .rx_st_data           (rx_st_data),
               .rx_st_ready          (rx_st_ready),
               .rx_st_sop            (rx_st_sop),
               .rx_st_valid          (rx_st_valid),
               .rx_st_empty          (rx_st_empty),
               .rx_st_eop            (rx_st_eop),
               .rx_st_err            (rx_st_err),
               .rx_st_mask           (rx_st_mask)
         );
   end
   else if (ast_width_hwtcl=="Avalon-ST 128-bit") begin
      altpcied_ep_128bit_downstream # (
               .MAX_NUM_FUNC_SUPPORT             (MAX_NUM_FUNC_SUPPORT            ),
               .num_of_func_hwtcl                (num_of_func_hwtcl               ),
               .device_family_hwtcl              (device_family_hwtcl             ),
               .use_crc_forwarding_hwtcl         (use_crc_forwarding_hwtcl        ),
               .pld_clockrate_hwtcl              (pld_clockrate_hwtcl             ),
               .lane_mask_hwtcl                  (lane_mask_hwtcl                 ),
               .max_payload_size_hwtcl           (max_payload_size_hwtcl          ),
               .gen123_lane_rate_mode_hwtcl      (gen123_lane_rate_mode_hwtcl     ),
               .ast_width_hwtcl                  (ast_width_hwtcl                 ),
               .port_width_data_hwtcl            (port_width_data_hwtcl           ),
               .port_width_be_hwtcl              (port_width_be_hwtcl             ),
               .extend_tag_field_hwtcl           (extend_tag_field_hwtcl          ),
               .avalon_waddr_hwltcl              (avalon_waddr_hwltcl             ),
               .check_bus_master_ena_hwtcl       (check_bus_master_ena_hwtcl      ),
               .check_rx_buffer_cpl_hwtcl        (check_rx_buffer_cpl_hwtcl       ),
               .port_type_hwtcl                  (port_type_hwtcl                 ),
               .apps_type_hwtcl                  (apps_type_hwtcl                 ),
               .multiple_packets_per_cycle_hwtcl (multiple_packets_per_cycle_hwtcl),
               .use_ast_parity                   (use_ast_parity                  )
            ) altpcied_ep_128bit_downstream (
               .pld_clk              (pld_clk),
               .rst_pldclk           (rst_pldclk),
               .cfg_busdev           (cfg_busdev),
               .tx_st_data           (tx_st_data),
               .tx_st_empty          (tx_st_empty),
               .tx_st_eop            (tx_st_eop),
               .tx_st_err            (tx_st_err),
               .tx_st_sop            (tx_st_sop),
               .tx_st_valid          (tx_st_valid),
               .tx_st_parity         (tx_st_parity),
               .tx_st_ready          (tx_st_ready),
               .tx_fifo_empty        (tx_fifo_empty),
               .rx_st_parity         (rx_st_parity),
               .rx_st_data           (rx_st_data),
               .rx_st_ready          (rx_st_ready),
               .rx_st_sop            (rx_st_sop),
               .rx_st_valid          (rx_st_valid),
               .rx_st_empty          (rx_st_empty),
               .rx_st_eop            (rx_st_eop),
               .rx_st_err            (rx_st_err),
               .rx_st_mask           (rx_st_mask)
         );
   end
   else if (ast_width_hwtcl=="Avalon-ST 256-bit") begin
      altpcied_ep_256bit_downstream # (
               .MAX_NUM_FUNC_SUPPORT             (MAX_NUM_FUNC_SUPPORT            ),
               .num_of_func_hwtcl                (num_of_func_hwtcl               ),
               .device_family_hwtcl              (device_family_hwtcl             ),
               .use_crc_forwarding_hwtcl         (use_crc_forwarding_hwtcl        ),
               .pld_clockrate_hwtcl              (pld_clockrate_hwtcl             ),
               .lane_mask_hwtcl                  (lane_mask_hwtcl                 ),
               .max_payload_size_hwtcl           (max_payload_size_hwtcl          ),
               .gen123_lane_rate_mode_hwtcl      (gen123_lane_rate_mode_hwtcl     ),
               .ast_width_hwtcl                  (ast_width_hwtcl                 ),
               .port_width_data_hwtcl            (port_width_data_hwtcl           ),
               .port_width_be_hwtcl              (port_width_be_hwtcl             ),
               .extend_tag_field_hwtcl           (extend_tag_field_hwtcl          ),
               .avalon_waddr_hwltcl              (avalon_waddr_hwltcl             ),
               .check_bus_master_ena_hwtcl       (check_bus_master_ena_hwtcl      ),
               .check_rx_buffer_cpl_hwtcl        (check_rx_buffer_cpl_hwtcl       ),
               .port_type_hwtcl                  (port_type_hwtcl                 ),
               .apps_type_hwtcl                  (apps_type_hwtcl                 ),
               .multiple_packets_per_cycle_hwtcl (multiple_packets_per_cycle_hwtcl),
               .use_ast_parity                   (use_ast_parity                  )
            ) altpcied_ep_256bit_downstream (
               .pld_clk              (pld_clk),
               .rst_pldclk           (rst_pldclk),
               .cfg_busdev           (cfg_busdev),
               .tx_st_data           (tx_st_data),
               .tx_st_empty          (tx_st_empty),
               .tx_st_eop            (tx_st_eop),
               .tx_st_err            (tx_st_err),
               .tx_st_sop            (tx_st_sop),
               .tx_st_valid          (tx_st_valid),
               .tx_st_parity         (tx_st_parity),
               .tx_st_ready          (tx_st_ready),
               .tx_fifo_empty        (tx_fifo_empty),
               .rx_st_parity         (rx_st_parity),
               .rx_st_data           (rx_st_data),
               .rx_st_ready          (rx_st_ready),
               .rx_st_sop            (rx_st_sop),
               .rx_st_valid          (rx_st_valid),
               .rx_st_empty          (rx_st_empty),
               .rx_st_eop            (rx_st_eop),
               .rx_st_err            (rx_st_err),
               .rx_st_mask           (rx_st_mask)
         );
   end
end
endgenerate

//////////////////////////////////////////////////////////////////////
//
// Reset sync
//
   //////////////// SIMULATION-ONLY CONTENTS
   //synthesis translate_off
   initial begin
      rst_pldclk_r = 3'b111;
   end
  //synthesis translate_on

   always @(posedge pld_clk or posedge reset_status) begin
      if (reset_status == 1'b1) begin
         rst_pldclk_r <= 3'b111;
      end
      else begin
         rst_pldclk_r[0] <= 1'b0;
         rst_pldclk_r[1] <= rst_pldclk_r[0];
         rst_pldclk_r[2] <= rst_pldclk_r[1];
      end
   end
   assign rst_pldclk = rst_pldclk_r[2];

   always @(posedge pld_clk or posedge rst_pldclk) begin : p_cst
      if (rst_pldclk == 1'b1) begin
         cfg_busdev           <= 13'h0;
      end
      else begin
         if (tl_cfg_add==4'hF)  begin
            cfg_busdev[12:0] <= tl_cfg_ctl[12:0];
         end
      end
   end
//////////////////////////////////////////////////////////////////////
//
// Constant IO
//
   assign derr_cor_ext_rcv_drv   = derr_cor_ext_rcv;
   assign derr_cor_ext_rpl_drv   = derr_cor_ext_rpl;
   assign derr_rpl_drv           = derr_rpl;
   assign dlup_drv               = dlup;
   assign dlup_exit_drv          = dlup_exit;
   assign ev128ns_drv            = ev128ns;
   assign ev1us_drv              =  ev1us;
   assign hotrst_exit_drv        = hotrst_exit;
   assign int_status_drv         = int_status;
   assign l2_exit_drv            = l2_exit;
   assign lane_act_drv           = lane_act;
   assign ltssmstate_drv         = ltssmstate;
   assign rx_par_err_drv         = rx_par_err;
   assign tx_par_err_drv         = tx_par_err;
   assign cfg_par_err_drv        = cfg_par_err;
   assign ko_cpl_spc_header_drv  = ko_cpl_spc_header;
   assign ko_cpl_spc_data_drv    = ko_cpl_spc_data;

   // Clocks
   assign pld_core_ready =  serdes_pll_locked;
   //synthesis translate_off
   assign pld_clk = coreclkout_hip;
   //synthesis translate_on

   //synthesis read_comments_as_HDL on
   //global u_global_buffer_coreclkout (.in(coreclkout_hip), .out(pld_clk));
   //synthesis read_comments_as_HDL off
   assign pld_clk_hip   = pld_clk;


   // Completion Error
   assign cpl_err              =ZEROS[6 :0];
   assign cpl_pending          =ZEROS[num_of_func_hwtcl-1:0];
   assign cpl_err_func         =ZEROS[2 :0];

   // LMI
   assign  lmi_addr            = ZEROS[addr_width_delta(num_of_func_hwtcl)+11 : 0];
   assign  lmi_din             = ZEROS[31 : 0]                                    ;
   assign  lmi_rden            = ZEROS[0]                                         ;
   assign  lmi_wren            = ZEROS[0]                                         ;

   // Interrupt
   assign  app_int_sts        = ZEROS[(2**addr_width_delta(num_of_func_hwtcl))-1 : 0];
   assign  aer_msi_num        = ZEROS[4 : 0]                                         ;
   assign  app_msi_func       = ZEROS[2 : 0]                                         ;
   assign  app_msi_num        = ZEROS[4 : 0]                                         ;
   assign  app_msi_req        = ZEROS                                                ;
   assign  app_msi_tc         = ZEROS[2 : 0]                                         ;
   assign  pex_msi_num        = ZEROS[4 : 0]                                         ;


   // Power management
   assign pm_auxpwr     =1'b0;
   assign pme_to_cr     =1'b0;
   assign pm_event      =1'b0;
   assign pm_event_func =3'b0;
   assign pm_data       =10'h0;

   // Hot plug
   assign hpg_ctrler = 5'h0;

endmodule
