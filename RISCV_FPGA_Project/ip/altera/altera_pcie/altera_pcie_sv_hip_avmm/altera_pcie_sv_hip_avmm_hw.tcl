# (C) 2001-2013 Altera Corporation. All rights reserved.
# Your use of Altera Corporation's design tools, logic functions and other 
# software and tools, and its AMPP partner logic functions, and any output 
# files any of the foregoing (including device programming or simulation 
# files), and any associated documentation or information are expressly subject 
# to the terms and conditions of the Altera Program License Subscription 
# Agreement, Altera MegaCore Function License Agreement, or other applicable 
# license agreement, including, without limitation, that your use is for the 
# sole purpose of programming logic devices manufactured by Altera and sold by 
# Altera or its authorized distributors.  Please refer to the applicable 
# agreement for further details.


package require -exact qsys 12.0

sopc::preview_add_transform name preview_avalon_mm_transform
source pcie_sv_avmm_parameters.tcl
source pcie_sv_avmm_port.tcl
source pcie_parameters_validation.tcl

global env
set QUARTUS_ROOTDIR $env(QUARTUS_ROOTDIR)

# +-----------------------------------
# altera_pcie_sv_hip_avmm
# Convention : _common are proc shared with SV AST in pcie_sv_parameters_common.tcl
#

source ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie_pipe/xcvr_generic/altera_xcvr_pipe_common.tcl
pipe_decl_fileset_groups_sv_xcvr_pipe_native ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie_pipe/xcvr_generic
# +-----------------------------------
# | module PCI Express
# |
set_module_property NAME altera_pcie_sv_hip_avmm
set_module_property DESCRIPTION "Avalon-MM Stratix V Hard IP for PCI Express"
set_module_property VERSION 13.1
set_module_property DATASHEET_URL "http://www.altera.com/literature/ug/ug_s5_pcie.pdf"
set_module_property GROUP "Interface Protocols/PCI"
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "Avalon-MM Stratix V Hard IP for PCI Express"
set_module_property HIDE_FROM_SOPC true
set_module_property INTERNAL false
set_module_property EDITABLE false
set_module_property ANALYZE_HDL FALSE
set_module_property ELABORATION_CALLBACK elaboration_callback
set_module_property instantiateInSystemModule "true"

# # +-----------------------------------
# # | Global parameters
#   |
add_parameter INTENDED_DEVICE_FAMILY String "STRATIX V"
set_parameter_property INTENDED_DEVICE_FAMILY SYSTEM_INFO DEVICE_FAMILY
set_parameter_property INTENDED_DEVICE_FAMILY VISIBLE FALSE
add_parameter pcie_qsys integer 1
set_parameter_property pcie_qsys VISIBLE false

# # +-----------------------------------
# # | Testbench files
#   |
# This is to tell the testbench generator "my_partner_name" is a "my_partner_type"
set_module_assignment testbench.partner.pcie_tb.class  altera_pcie_tbed
set_module_assignment testbench.partner.pcie_tb.version 13.1
set_module_assignment testbench.partner.map.refclk     pcie_tb.refclk
set_module_assignment testbench.partner.map.hip_ctrl   pcie_tb.hip_ctrl
set_module_assignment testbench.partner.map.npor       pcie_tb.npor
set_module_assignment testbench.partner.map.hip_pipe   pcie_tb.hip_pipe
set_module_assignment testbench.partner.map.hip_serial pcie_tb.hip_serial

# # +-----------------------------------
# # | QUARTUS_SYNTH design RTL files
#   |
add_fileset synth QUARTUS_SYNTH proc_quartus_synth
set_fileset_property synth TOP_LEVEL altpcie_sv_hip_avmm_hwtcl

# # +-----------------------------------
# # | SIM_ design files
#   |
add_fileset sim_vhdl SIM_VHDL proc_sim_vhdl
set_fileset_property sim_vhdl TOP_LEVEL altpcie_sv_hip_avmm_hwtcl

add_fileset sim_verilog SIM_VERILOG proc_sim_verilog
set_fileset_property sim_verilog TOP_LEVEL altpcie_sv_hip_avmm_hwtcl

# # +-----------------------------------
# # | Example QSYS Design
#   |
add_fileset example_design {EXAMPLE_DESIGN} example_design_proc

# # +-----------------------------------
# # | elaboration items
# # |
proc elaboration_callback { } {


   validation_parameter_system_setting
   validation_parameter_bar
   validation_parameter_base_limit_reg
   validation_parameter_pcie_cap_reg
   validation_parameter_prj_setting
   validation_parameter_avmm_setting
   update_default_value_hidden_parameter_common
   update_default_value_hidden_avmm_parameter

   # Port updates
   add_pcie_hip_port_avmm_rxmaster

   set enable_multiple_msi_support [ get_parameter_value  CG_ENABLE_ADVANCED_INTERRUPT ]
   if { $enable_multiple_msi_support == 1 } {
          add_pcie_hip_port_interrupt
        }

   set enable_hip_status_ext [ get_parameter_value  CG_ENABLE_HIP_STATUS_EXTENSION ]
   if { $enable_hip_status_ext  == 1 } {
   	  add_pcie_hip_status_ext
   	}

   set enable_hip_status [ get_parameter_value  CG_ENABLE_HIP_STATUS ]
   if { $enable_hip_status  == 1 } {
      add_pcie_hip_port_status   
      }
      
   add_pcie_hip_port_reconfig
   add_pcie_hip_port_serial
   add_pcie_hip_port_pipe
   add_pcie_hip_port_control

   # Parameter updates
   set_pcie_hip_flow_control_settings_common
   set_pcie_cvp_parameters_common
   set_module_assignment testbench.partner.pcie_tb.parameter.lane_mask_hwtcl                 [get_parameter lane_mask_hwtcl]
   set_module_assignment testbench.partner.pcie_tb.parameter.pll_refclk_freq_hwtcl           [get_parameter pll_refclk_freq_hwtcl]
   set_module_assignment testbench.partner.pcie_tb.parameter.port_type_hwtcl                 [get_parameter port_type_hwtcl]
   set_module_assignment testbench.partner.pcie_tb.parameter.gen123_lane_rate_mode_hwtcl     [get_parameter gen123_lane_rate_mode_hwtcl]
   set_module_assignment testbench.partner.pcie_tb.parameter.serial_sim_hwtcl                [get_parameter serial_sim_hwtcl ]
   set_module_assignment testbench.partner.pcie_tb.parameter.enable_tl_only_sim_hwtcl        [get_parameter enable_tl_only_sim_hwtcl ]
   set_module_assignment testbench.partner.pcie_tb.parameter.deemphasis_enable_hwtcl         [get_parameter deemphasis_enable_hwtcl ]
   set_module_assignment testbench.partner.pcie_tb.parameter.pld_clk_MHz                     [get_parameter pld_clk_MHz ]
   set_module_assignment testbench.partner.pcie_tb.parameter.millisecond_cycle_count_hwtcl   [get_parameter millisecond_cycle_count_hwtcl ]
   set_module_assignment testbench.partner.pcie_tb.parameter.use_crc_forwarding_hwtcl        [get_parameter use_crc_forwarding_hwtcl ]
   set_module_assignment testbench.partner.pcie_tb.parameter.ecrc_check_capable_hwtcl        [get_parameter ecrc_check_capable_hwtcl ]
   set_module_assignment testbench.partner.pcie_tb.parameter.ecrc_gen_capable_hwtcl          [get_parameter ecrc_gen_capable_hwtcl ]

    set port_type_hwtcl [ get_parameter_value port_type_hwtcl ]

   set avmm_width_hwtcl [ get_parameter_value  avmm_width_hwtcl ]
   if { $avmm_width_hwtcl == 128 } {
      set_module_assignment testbench.partner.pcie_tb.parameter.apps_type_hwtcl 5
   } else {
      set_module_assignment testbench.partner.pcie_tb.parameter.apps_type_hwtcl 4
   }


   # Calculate TXS Address Width
   set pcie_mode [ get_parameter_value CB_PCIE_MODE ]
   set avmm_address_width  [ get_parameter_value AVALON_ADDR_WIDTH ]
   set txs_address_width   [ get_parameter_value TX_S_ADDR_WIDTH ]

    if { $pcie_mode == 0 } {
        add_pcie_hip_port_avmm_txslave
        set i_Cg_Avalon_RP_Addr_Width [ get_parameter_value CB_RP_S_ADDR_WIDTH ]
        set i_Cg_Avalon_S_Addr_Width [ get_parameter_value CB_A2P_ADDR_MAP_PASS_THRU_BITS ]
        set CB_A2P_ADDR_MAP_NUM_ENTRIES [get_parameter_value CB_A2P_ADDR_MAP_NUM_ENTRIES]
        set i_Cg_Avalon_S_Addr_Width [ calculate_avalon_s_address_width $CB_A2P_ADDR_MAP_NUM_ENTRIES $i_Cg_Avalon_S_Addr_Width ]
         if { $avmm_address_width == 32 } {
        add_interface_port     Txs "TxsAddress_i" "address" "input" [expr $i_Cg_Avalon_S_Addr_Width]
        set_parameter_value CG_AVALON_S_ADDR_WIDTH $i_Cg_Avalon_S_Addr_Width
      } else {
	add_interface_port     Txs "TxsAddress_i" "address" "input" $txs_address_width
        set_parameter_value CG_AVALON_S_ADDR_WIDTH $txs_address_width

      }
          }

 # set the mask bit for each Rxm master
   for { set i 0 } { $i < 6 } { incr i } {
      set span [get_parameter_value "SLAVE_ADDRESS_MAP_${i}"]

     if { [ regexp endpoint $port_type_hwtcl ] } {
      set_parameter_value "bar${i}_size_mask_hwtcl" $span
     } else {     # RP
         set_parameter_value "bar0_size_mask_hwtcl" 32
         set_module_assignment embeddedsw.dts.vendor "ALTR"
         set_module_assignment embeddedsw.dts.group "pcie"
         set_module_assignment embeddedsw.dts.name "pcie-root-port"
         set_module_assignment embeddedsw.dts.compatible "altr,pcie-root-port-1.0"
    }
   }

   set isCRA  [get_parameter_value CG_IMPL_CRA_AV_SLAVE_PORT]
   if { $isCRA == 1 } {
      add_pcie_hip_port_avmm_cra_craIrq
   }

}



# +-----------------------------------
# | parameters
# |
add_pcie_hip_parameters_ui_system_settings
add_pcie_hip_parameters_bar_avmm
add_pcie_hip_parameters_ui_pci_registers
add_pcie_hip_parameters_ui_pcie_cap_registers
add_avalon_mm_parameters
add_pcie_hip_hidden_rtl_parameters
add_pcie_hip_common_hidden_rtl_parameters
add_pcie_hip_gen2_vod

# +-----------------------------------
# | Static IO
# |
add_interface no_connect conduit end
add_pcie_hip_port_clk_rst


# ************** Global Variables ***************
set not_init "default"
# **************** Parameters *******************


proc proc_quartus_synth {name} {
         set pld_clk_MHz                                    [ get_parameter_value pld_clk_MHz ]
   add_fileset_file altpcie_sv_hip_avmm_hwtcl.v         VERILOG PATH altpcie_sv_hip_avmm_hwtcl.v
   add_fileset_file altpcie_sv_hip_ast_hwtcl.v          VERILOG PATH ../altera_pcie_sv_hip_ast/altpcie_sv_hip_ast_hwtcl.v
   add_fileset_file altpcie_hip_256_pipen1b.v           VERILOG PATH ../altera_pcie_sv_hip_ast/altpcie_hip_256_pipen1b.v
   add_fileset_file altpcie_rs_hip.v                    VERILOG PATH ../altera_pcie_sv_hip_ast/altpcie_rs_hip.v
   add_fileset_file altpcie_rs_serdes.v                 VERILOG PATH ../altera_pcie_sv_hip_ast/altpcie_rs_serdes.v
   add_fileset_file altpcierd_hip_rs.v                  VERILOG PATH ../altera_pcie_hip_ast_ed/example_design/verilog/chaining_dma/altpcierd_hip_rs.v
   add_fileset_file altera_pci_express.sdc              SDC     PATH altera_pci_express.sdc
   add_fileset_file altpciexpav_stif_a2p_addrtrans.v    VERILOG PATH ../altera_pcie_av_hip_avmm/avalon_stif/altpciexpav_stif_a2p_addrtrans.v
   add_fileset_file altpciexpav_stif_a2p_fixtrans.v     VERILOG PATH ../altera_pcie_av_hip_avmm/avalon_stif/altpciexpav_stif_a2p_fixtrans.v
   add_fileset_file altpciexpav_stif_a2p_vartrans.v     VERILOG PATH ../altera_pcie_av_hip_avmm/avalon_stif/altpciexpav_stif_a2p_vartrans.v
   add_fileset_file altpciexpav_stif_app.v              VERILOG PATH ../altera_pcie_av_hip_avmm/avalon_stif/altpciexpav_stif_app.v
   add_fileset_file altpciexpav_stif_control_register.v VERILOG PATH ../altera_pcie_av_hip_avmm/avalon_stif/altpciexpav_stif_control_register.v
   add_fileset_file altpciexpav_stif_cr_avalon.v        VERILOG PATH ../altera_pcie_av_hip_avmm/avalon_stif/altpciexpav_stif_cr_avalon.v
   add_fileset_file altpciexpav_stif_cr_interrupt.v     VERILOG PATH ../altera_pcie_av_hip_avmm/avalon_stif/altpciexpav_stif_cr_interrupt.v
   add_fileset_file altpciexpav_stif_cr_rp.v            VERILOG PATH ../altera_pcie_av_hip_avmm/avalon_stif/altpciexpav_stif_cr_rp.v
   add_fileset_file altpciexpav_stif_cr_mailbox.v       VERILOG PATH ../altera_pcie_av_hip_avmm/avalon_stif/altpciexpav_stif_cr_mailbox.v
   add_fileset_file altpciexpav_stif_p2a_addrtrans.v    VERILOG PATH ../altera_pcie_av_hip_avmm/avalon_stif/altpciexpav_stif_p2a_addrtrans.v
   add_fileset_file altpciexpav_stif_reg_fifo.v         VERILOG PATH ../altera_pcie_av_hip_avmm/avalon_stif/altpciexpav_stif_reg_fifo.v
   add_fileset_file altpciexpav_stif_rx.v               VERILOG PATH ../altera_pcie_av_hip_avmm/avalon_stif/altpciexpav_stif_rx.v
   add_fileset_file altpciexpav_stif_rx_cntrl.v         VERILOG PATH ../altera_pcie_av_hip_avmm/avalon_stif/altpciexpav_stif_rx_cntrl.v
   add_fileset_file altpciexpav_stif_rx_resp.v          VERILOG PATH ../altera_pcie_av_hip_avmm/avalon_stif/altpciexpav_stif_rx_resp.v
   add_fileset_file altpciexpav_stif_tx.v               VERILOG PATH ../altera_pcie_av_hip_avmm/avalon_stif/altpciexpav_stif_tx.v
   add_fileset_file altpciexpav_stif_tx_cntrl.v         VERILOG PATH ../altera_pcie_av_hip_avmm/avalon_stif/altpciexpav_stif_tx_cntrl.v
   add_fileset_file altpciexpav_stif_txavl_cntrl.v      VERILOG PATH ../altera_pcie_av_hip_avmm/avalon_stif/altpciexpav_stif_txavl_cntrl.v
   add_fileset_file altpciexpav_stif_txresp_cntrl.v     VERILOG PATH ../altera_pcie_av_hip_avmm/avalon_stif/altpciexpav_stif_txresp_cntrl.v
   add_fileset_file altpciexpav_clksync.v               VERILOG PATH ../altera_pcie_av_hip_avmm/avalon_stif/altpciexpav_clksync.v
   add_fileset_file altpciexpav128_a2p_addrtrans.v      VERILOG PATH ../altera_pcie_av_hip_avmm/avalon_mm_128/altpciexpav128_a2p_addrtrans.v
   add_fileset_file altpciexpav128_a2p_fixtrans.v       VERILOG PATH ../altera_pcie_av_hip_avmm/avalon_mm_128/altpciexpav128_a2p_fixtrans.v
   add_fileset_file altpciexpav128_a2p_vartrans.v       VERILOG PATH ../altera_pcie_av_hip_avmm/avalon_mm_128/altpciexpav128_a2p_vartrans.v
   add_fileset_file altpciexpav128_app.v                VERILOG PATH ../altera_pcie_av_hip_avmm/avalon_mm_128/altpciexpav128_app.v
   add_fileset_file altpciexpav128_clksync.v            VERILOG PATH ../altera_pcie_av_hip_avmm/avalon_mm_128/altpciexpav128_clksync.v
   add_fileset_file altpciexpav128_control_register.v   VERILOG PATH ../altera_pcie_av_hip_avmm/avalon_mm_128/altpciexpav128_control_register.v
   add_fileset_file altpciexpav128_cr_avalon.v          VERILOG PATH ../altera_pcie_av_hip_avmm/avalon_mm_128/altpciexpav128_cr_avalon.v
   add_fileset_file altpciexpav128_cr_interrupt.v       VERILOG PATH ../altera_pcie_av_hip_avmm/avalon_mm_128/altpciexpav128_cr_interrupt.v
   add_fileset_file altpciexpav128_cr_rp.v              VERILOG PATH ../altera_pcie_av_hip_avmm/avalon_mm_128/altpciexpav128_cr_rp.v
   add_fileset_file altpciexpav128_cr_mailbox.v         VERILOG PATH ../altera_pcie_av_hip_avmm/avalon_mm_128/altpciexpav128_cr_mailbox.v
   add_fileset_file altpciexpav128_p2a_addrtrans.v      VERILOG PATH ../altera_pcie_av_hip_avmm/avalon_mm_128/altpciexpav128_p2a_addrtrans.v
   add_fileset_file altpciexpav128_rx.v                 VERILOG PATH ../altera_pcie_av_hip_avmm/avalon_mm_128/altpciexpav128_rx.v
   add_fileset_file altpciexpav128_rx_cntrl.v           VERILOG PATH ../altera_pcie_av_hip_avmm/avalon_mm_128/altpciexpav128_rx_cntrl.v
   add_fileset_file altpciexpav128_fifo.v               VERILOG PATH ../altera_pcie_av_hip_avmm/avalon_mm_128/altpciexpav128_fifo.v
   add_fileset_file altpciexpav128_rxm_adapter.v        VERILOG PATH ../altera_pcie_av_hip_avmm/avalon_mm_128/altpciexpav128_rxm_adapter.v
   add_fileset_file altpciexpav128_rx_resp.v            VERILOG PATH ../altera_pcie_av_hip_avmm/avalon_mm_128/altpciexpav128_rx_resp.v
   add_fileset_file altpciexpav128_tx.v                 VERILOG PATH ../altera_pcie_av_hip_avmm/avalon_mm_128/altpciexpav128_tx.v
   add_fileset_file altpciexpav128_tx_cntrl.v           VERILOG PATH ../altera_pcie_av_hip_avmm/avalon_mm_128/altpciexpav128_tx_cntrl.v
   add_fileset_file altpciexpav128_txavl_cntrl.v        VERILOG PATH ../altera_pcie_av_hip_avmm/avalon_mm_128/altpciexpav128_txavl_cntrl.v
   add_fileset_file altpciexpav128_txresp_cntrl.v       VERILOG PATH ../altera_pcie_av_hip_avmm/avalon_mm_128/altpciexpav128_txresp_cntrl.v
   add_fileset_file altpciexpav_lite_app.v              VERILOG PATH ../altera_pcie_av_hip_avmm/avalon_lite/altpciexpav_lite_app.v
   common_add_fileset_files { S5 ALL_HDL } { PLAIN }
}

proc proc_sim_vhdl {name} {
     set verilog_file_common_rtl  {"avalon_stif/altpciexpav_stif_a2p_addrtrans.v"
                        "avalon_stif/altpciexpav_stif_a2p_fixtrans.v"
                        "avalon_stif/altpciexpav_stif_a2p_vartrans.v"
                        "avalon_stif/altpciexpav_stif_control_register.v"
                        "avalon_stif/altpciexpav_stif_cr_avalon.v"
                        "avalon_stif/altpciexpav_stif_cr_interrupt.v"
                        "avalon_stif/altpciexpav_stif_cr_rp.v"
                        "avalon_stif/altpciexpav_stif_cr_mailbox.v"
                        "avalon_stif/altpciexpav_stif_p2a_addrtrans.v"
                        "avalon_stif/altpciexpav_stif_reg_fifo.v"
                        "avalon_stif/altpciexpav_stif_rx.v"
                        "avalon_stif/altpciexpav_stif_rx_cntrl.v"
                        "avalon_stif/altpciexpav_stif_rx_resp.v"
                        "avalon_stif/altpciexpav_stif_tx.v"
                        "avalon_stif/altpciexpav_stif_tx_cntrl.v"
                        "avalon_stif/altpciexpav_stif_txavl_cntrl.v"
                        "avalon_stif/altpciexpav_stif_txresp_cntrl.v"
                        "avalon_stif/altpciexpav_clksync.v"
                        "avalon_mm_128/altpciexpav128_a2p_addrtrans.v"
                        "avalon_mm_128/altpciexpav128_a2p_fixtrans.v"
                        "avalon_mm_128/altpciexpav128_a2p_vartrans.v"
                        "avalon_mm_128/altpciexpav128_clksync.v"
                        "avalon_mm_128/altpciexpav128_control_register.v"
                        "avalon_mm_128/altpciexpav128_cr_avalon.v"
                        "avalon_mm_128/altpciexpav128_cr_interrupt.v"
                        "avalon_mm_128/altpciexpav128_cr_rp.v"
                        "avalon_mm_128/altpciexpav128_cr_mailbox.v"
                        "avalon_mm_128/altpciexpav128_p2a_addrtrans.v"
                        "avalon_mm_128/altpciexpav128_rx.v"
                        "avalon_mm_128/altpciexpav128_rx_cntrl.v"
                        "avalon_mm_128/altpciexpav128_fifo.v"
                        "avalon_mm_128/altpciexpav128_rxm_adapter.v"
                        "avalon_mm_128/altpciexpav128_rx_resp.v"
                        "avalon_mm_128/altpciexpav128_tx.v"
                        "avalon_mm_128/altpciexpav128_tx_cntrl.v"
                        "avalon_mm_128/altpciexpav128_txavl_cntrl.v"
                        "avalon_mm_128/altpciexpav128_txresp_cntrl.v"
                        "avalon_lite/altpciexpav_lite_app.v"
                        "avalon_stif/altpciexpav_stif_app.v"
                        "avalon_mm_128/altpciexpav128_app.v"
                         }

  foreach vf $verilog_file_common_rtl {
      add_fileset_file mentor/${vf} VERILOG_ENCRYPT PATH "../altera_pcie_av_hip_avmm/mentor/${vf}" {MENTOR_SPECIFIC}
      add_fileset_file aldec/${vf} VERILOG_ENCRYPT PATH "../altera_pcie_av_hip_avmm/aldec/${vf}" {ALDEC_SPECIFIC}
      #add_fileset_file aldec/${vf} VERILOG_ENCRYPT PATH "aldec/${vf}" {ALDEC_SPECIFIC}
      if { 0 } {
         add_fileset_file cadence/${vf} VERILOG_ENCRYPT PATH "../altera_pcie_av_hip_avmm/cadence/${vf}" {CADENCE_SPECIFIC}
      }
      if { 0 } {
         add_fileset_file synopsys/${vf} VERILOG_ENCRYPT PATH "../altera_pcie_av_hip_avmm/synopsys/${vf}" {SYNOPSYS_SPECIFIC}
      }
   }

      add_fileset_file mentor/altpcie_sv_hip_avmm_hwtcl.v         VERILOG_ENCRYPT PATH "mentor/altpcie_sv_hip_avmm_hwtcl.v"                                                        {MENTOR_SPECIFIC}
      add_fileset_file mentor/altpcie_sv_hip_ast_hwtcl.v          VERILOG_ENCRYPT PATH "../altera_pcie_sv_hip_ast/mentor/altpcie_sv_hip_ast_hwtcl.v"                               {MENTOR_SPECIFIC}
      add_fileset_file mentor/altpcie_hip_256_pipen1b.v           VERILOG_ENCRYPT PATH "../altera_pcie_sv_hip_ast/mentor/altpcie_hip_256_pipen1b.v"                                {MENTOR_SPECIFIC}
      add_fileset_file mentor/altpcie_rs_hip.v                    VERILOG_ENCRYPT PATH "../altera_pcie_sv_hip_ast/mentor/altpcie_rs_hip.v"                                         {MENTOR_SPECIFIC}
      add_fileset_file mentor/altpcie_rs_serdes.v                 VERILOG_ENCRYPT PATH "../altera_pcie_sv_hip_ast/mentor/altpcie_rs_serdes.v"                                      {MENTOR_SPECIFIC}
      add_fileset_file mentor/altpcierd_hip_rs.v                  VERILOG_ENCRYPT PATH "../altera_pcie_hip_ast_ed/mentor/example_design/verilog/chaining_dma/altpcierd_hip_rs.v"   {MENTOR_SPECIFIC}

      add_fileset_file aldec/altpcie_sv_hip_avmm_hwtcl.v         VERILOG_ENCRYPT PATH "altpcie_sv_hip_avmm_hwtcl.v"                                                        {ALDEC_SPECIFIC}
      add_fileset_file aldec/altpcie_sv_hip_ast_hwtcl.v          VERILOG_ENCRYPT PATH "../altera_pcie_sv_hip_ast/altpcie_sv_hip_ast_hwtcl.v"                               {ALDEC_SPECIFIC}
      add_fileset_file aldec/altpcie_hip_256_pipen1b.v           VERILOG_ENCRYPT PATH "../altera_pcie_sv_hip_ast/altpcie_hip_256_pipen1b.v"                                {ALDEC_SPECIFIC}
      add_fileset_file aldec/altpcie_rs_hip.v                    VERILOG_ENCRYPT PATH "../altera_pcie_sv_hip_ast/altpcie_rs_hip.v"                                         {ALDEC_SPECIFIC}
      add_fileset_file aldec/altpcie_rs_serdes.v                 VERILOG_ENCRYPT PATH "../altera_pcie_sv_hip_ast/altpcie_rs_serdes.v"                                      {ALDEC_SPECIFIC}
      add_fileset_file aldec/altpcierd_hip_rs.v                  VERILOG_ENCRYPT PATH "../altera_pcie_hip_ast_ed/example_design/verilog/chaining_dma/altpcierd_hip_rs.v"   {ALDEC_SPECIFIC}



      if { 0 } {
      add_fileset_file  altpcie_sv_hip_avmm_hwtcl.v        VERILOG_ENCRYPT PATH "altpcie_sv_hip_avmm_hwtcl.v"                                                        {CADENCE_SPECIFIC}
      add_fileset_file altpcie_sv_hip_ast_hwtcl.v          VERILOG_ENCRYPT PATH "../altera_pcie_sv_hip_ast/altpcie_sv_hip_ast_hwtcl.v"                               {CADENCE_SPECIFIC}
      add_fileset_file altpcie_hip_256_pipen1b.v           VERILOG_ENCRYPT PATH "../altera_pcie_sv_hip_ast/altpcie_hip_256_pipen1b.v"                                {CADENCE_SPECIFIC}
      add_fileset_file altpcie_rs_hip.v                    VERILOG_ENCRYPT PATH "../altera_pcie_sv_hip_ast/altpcie_rs_hip.v"                                         {CADENCE_SPECIFIC}
      add_fileset_file altpcie_rs_serdes.v                 VERILOG_ENCRYPT PATH "../altera_pcie_sv_hip_ast/altpcie_rs_serdes.v"                                      {CADENCE_SPECIFIC}
      add_fileset_file altpcierd_hip_rs.v                 VERILOG_ENCRYPT PATH "../altera_pcie_hip_ast_ed/example_design/verilog/chaining_dma/altpcierd_hip_rs.v"   {CADENCE_SPECIFIC}
      }
      if { 0 } {
      add_fileset_file  altpcie_sv_hip_avmm_hwtcl.v        VERILOG_ENCRYPT PATH "altpcie_sv_hip_avmm_hwtcl.v"                                                        {SYNOPSYS_SPECIFIC}
      add_fileset_file altpcie_sv_hip_ast_hwtcl.v          VERILOG_ENCRYPT PATH "../altera_pcie_sv_hip_ast/altpcie_sv_hip_ast_hwtcl.v"                              {SYNOPSYS_SPECIFIC}
      add_fileset_file altpcie_hip_256_pipen1b.v           VERILOG_ENCRYPT PATH "../altera_pcie_sv_hip_ast/altpcie_hip_256_pipen1b.v"                                {SYNOPSYS_SPECIFIC}
      add_fileset_file altpcie_rs_hip.v                    VERILOG_ENCRYPT PATH "../altera_pcie_sv_hip_ast/altpcie_rs_hip.v"                                         {SYNOPSYS_SPECIFIC}
      add_fileset_file altpcie_rs_serdes.v                 VERILOG_ENCRYPT PATH "../altera_pcie_sv_hip_ast/altpcie_rs_serdes.v"                                      {SYNOPSYS_SPECIFIC}
      add_fileset_file altpcierd_hip_rs.v                 VERILOG_ENCRYPT PATH "../altera_pcie_hip_ast_ed/example_design/verilog/chaining_dma/altpcierd_hip_rs.v"   {SYNOPSYS_SPECIFIC}
   }

   common_add_fileset_files { S5 ALL_HDL } { PLAIN MENTOR}

}

proc proc_sim_verilog {name} {

    set verilog_file {"avalon_stif/altpciexpav_stif_a2p_addrtrans.v"
                        "avalon_stif/altpciexpav_stif_a2p_fixtrans.v"
                        "avalon_stif/altpciexpav_stif_a2p_vartrans.v"
                        "avalon_stif/altpciexpav_stif_control_register.v"
                        "avalon_stif/altpciexpav_stif_cr_avalon.v"
                        "avalon_stif/altpciexpav_stif_cr_interrupt.v"
                        "avalon_stif/altpciexpav_stif_cr_rp.v"
                        "avalon_stif/altpciexpav_stif_cr_mailbox.v"
                        "avalon_stif/altpciexpav_stif_p2a_addrtrans.v"
                        "avalon_stif/altpciexpav_stif_reg_fifo.v"
                        "avalon_stif/altpciexpav_stif_rx.v"
                        "avalon_stif/altpciexpav_stif_rx_cntrl.v"
                        "avalon_stif/altpciexpav_stif_rx_resp.v"
                        "avalon_stif/altpciexpav_stif_tx.v"
                        "avalon_stif/altpciexpav_stif_tx_cntrl.v"
                        "avalon_stif/altpciexpav_stif_txavl_cntrl.v"
                        "avalon_stif/altpciexpav_stif_txresp_cntrl.v"
                        "avalon_stif/altpciexpav_clksync.v"
                        "avalon_mm_128/altpciexpav128_a2p_addrtrans.v"
                        "avalon_mm_128/altpciexpav128_a2p_fixtrans.v"
                        "avalon_mm_128/altpciexpav128_a2p_vartrans.v"
                        "avalon_mm_128/altpciexpav128_clksync.v"
                        "avalon_mm_128/altpciexpav128_control_register.v"
                        "avalon_mm_128/altpciexpav128_cr_avalon.v"
                        "avalon_mm_128/altpciexpav128_cr_interrupt.v"
                        "avalon_mm_128/altpciexpav128_cr_rp.v"
                        "avalon_mm_128/altpciexpav128_cr_mailbox.v"
                        "avalon_mm_128/altpciexpav128_p2a_addrtrans.v"
                        "avalon_mm_128/altpciexpav128_rx.v"
                        "avalon_mm_128/altpciexpav128_rx_cntrl.v"
                        "avalon_mm_128/altpciexpav128_fifo.v"
                        "avalon_mm_128/altpciexpav128_rxm_adapter.v"
                        "avalon_mm_128/altpciexpav128_rx_resp.v"
                        "avalon_mm_128/altpciexpav128_tx.v"
                        "avalon_mm_128/altpciexpav128_tx_cntrl.v"
                        "avalon_mm_128/altpciexpav128_txavl_cntrl.v"
                        "avalon_mm_128/altpciexpav128_txresp_cntrl.v"
                        "avalon_lite/altpciexpav_lite_app.v" }
  foreach vf $verilog_file {
      add_fileset_file mentor/${vf} VERILOG_ENCRYPT PATH "../altera_pcie_av_hip_avmm/mentor/${vf}" {MENTOR_SPECIFIC}
      add_fileset_file aldec/${vf} VERILOG_ENCRYPT PATH "../altera_pcie_av_hip_avmm/aldec/${vf}" {ALDEC_SPECIFIC}
      #add_fileset_file aldec/${vf} VERILOG_ENCRYPT PATH "aldec/${vf}" {ALDEC_SPECIFIC}
      if { 0 } {
         add_fileset_file cadence/${vf} VERILOG_ENCRYPT PATH "../altera_pcie_av_hip_avmm/cadence/${vf}" {CADENCE_SPECIFIC}
      }
      if { 0 } {
         add_fileset_file synopsys/${vf} VERILOG_ENCRYPT PATH "../altera_pcie_av_hip_avmm/synopsys/${vf}" {SYNOPSYS_SPECIFIC}
      }
   }

   add_fileset_file altpciexpav_stif_app.v              VERILOG PATH ../altera_pcie_av_hip_avmm/avalon_stif/altpciexpav_stif_app.v
   add_fileset_file altpciexpav128_app.v                VERILOG PATH ../altera_pcie_av_hip_avmm/avalon_mm_128/altpciexpav128_app.v
   add_fileset_file altpcie_sv_hip_avmm_hwtcl.v         VERILOG PATH altpcie_sv_hip_avmm_hwtcl.v
   add_fileset_file altpcie_sv_hip_ast_hwtcl.v          VERILOG PATH ../altera_pcie_sv_hip_ast/altpcie_sv_hip_ast_hwtcl.v
   add_fileset_file altpcie_hip_256_pipen1b.v           VERILOG PATH ../altera_pcie_sv_hip_ast/altpcie_hip_256_pipen1b.v
   add_fileset_file altpcie_rs_hip.v                    VERILOG PATH ../altera_pcie_sv_hip_ast/altpcie_rs_hip.v
   add_fileset_file altpcie_rs_serdes.v                 VERILOG PATH ../altera_pcie_sv_hip_ast/altpcie_rs_serdes.v
   add_fileset_file altpcierd_hip_rs.v                 VERILOG PATH ../altera_pcie_hip_ast_ed/example_design/verilog/chaining_dma/altpcierd_hip_rs.v
   common_add_fileset_files { S5 ALL_HDL } { PLAIN }
}

proc example_design_proc { outputName } {

   # example_designs/ep_g1x1.qsys
   # example_designs/ep_g1x4.qsys
   # example_designs/ep_g1x8.qsys
   # example_designs/ep_g2x1.qsys
   # example_designs/ep_g2x4.qsys
   # example_designs/ep_g2x8.qsys
   global env
   set QUARTUS_ROOTDIR $env(QUARTUS_ROOTDIR)
   set ast_width_hwtcl [ get_parameter_value ast_width_hwtcl ]
   set port_type_hwtcl [ get_parameter_value port_type_hwtcl ]

   add_fileset_file ep_g1x1.qsys     OTHER PATH example_designs/ep_g1x1.qsys
   add_fileset_file altpcied_qii.tcl OTHER PATH ../altera_pcie_hip_ast_ed/example_design/altpcied_qii.tcl

}

proc calculate_avalon_s_address_width {i_CB_A2P_ADDR_MAP_NUM_ENTRIES i_Cg_Avalon_S_Addr_Width } {

set my_Cg_Avalon_S_Addr_Width $i_Cg_Avalon_S_Addr_Width
   switch $i_CB_A2P_ADDR_MAP_NUM_ENTRIES {
      1     {}
      2     {set my_Cg_Avalon_S_Addr_Width [expr $i_Cg_Avalon_S_Addr_Width + 1]}
      4     {set my_Cg_Avalon_S_Addr_Width [expr $i_Cg_Avalon_S_Addr_Width + 2]}
      8     {set my_Cg_Avalon_S_Addr_Width [expr $i_Cg_Avalon_S_Addr_Width + 3]}
      16    {set my_Cg_Avalon_S_Addr_Width [expr $i_Cg_Avalon_S_Addr_Width + 4]}
      32    {set my_Cg_Avalon_S_Addr_Width [expr $i_Cg_Avalon_S_Addr_Width + 5]}
      64    {set my_Cg_Avalon_S_Addr_Width [expr $i_Cg_Avalon_S_Addr_Width + 6]}
      128   {set my_Cg_Avalon_S_Addr_Width [expr $i_Cg_Avalon_S_Addr_Width + 7]}
      256   {set my_Cg_Avalon_S_Addr_Width [expr $i_Cg_Avalon_S_Addr_Width + 8]}
      512   {set my_Cg_Avalon_S_Addr_Width [expr $i_Cg_Avalon_S_Addr_Width + 9]}
      default { }
   }

   return $my_Cg_Avalon_S_Addr_Width
}
