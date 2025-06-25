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


package require -exact qsys 13.1
sopc::preview_add_transform name preview_avalon_mm_transform
source rd_pcie_sv_parameters.tcl
source rd_pcie_sv_port.tcl

global env
set QUARTUS_ROOTDIR $env(QUARTUS_ROOTDIR)

# get xcvr PHY function definitions
source ${QUARTUS_ROOTDIR}/../ip/altera/altera_xcvr_generic/alt_xcvr_common.tcl

# +-----------------------------------
# | module PCI Express
# |
set_module_property DESCRIPTION "Example design for Avalon-Streaming hard IP for PCI Express"
set_module_property NAME altera_pcie_hip_ast_ed
set_module_property VERSION 13.1
set_module_property DATASHEET_URL "http://www.altera.com/literature/ug/ug_s5_pcie.pdf"
set_module_property GROUP "Interface Protocols/PCI"
set_module_property AUTHOR Altera
set_module_property DISPLAY_NAME "Example design for Avalon-Streaming Hard IP for PCI Express"

set_module_property HIDE_FROM_SOPC true
set_module_property INTERNAL true
set_module_property EDITABLE false
set_module_property ANALYZE_HDL FALSE

set_module_property ELABORATION_CALLBACK elaboration_callback

set_module_property instantiateInSystemModule "true"

add_parameter INTENDED_DEVICE_FAMILY String "Stratix V"
set_parameter_property INTENDED_DEVICE_FAMILY SYSTEM_INFO DEVICE_FAMILY
set_parameter_property INTENDED_DEVICE_FAMILY HDL_PARAMETER FALSE
set_parameter_property INTENDED_DEVICE_FAMILY VISIBLE FALSE

# # +-----------------------------------
# # | Testbench files
#   |
# This is to tell the testbench generator "my_partner_name" is a "my_partner_type"
#set_module_assignment testbench.partner.pcie_design_example_clk_tb.class  altera_avalon_clock_source
#set_module_assignment testbench.partner.pcie_design_example_clk_tb.version 13.1
#set_module_assignment testbench.partner.map.reconfig_xcvr_clk     pcie_design_example_clk_tb.clk
#set_module_assignment testbench.partner.pcie_design_example_clk_tb.parameter.CLOCK_RATE  50

# # +-----------------------------------
# # | Example design RTL files
#   |
add_fileset sim_vhdl SIM_VHDL proc_sim_vhdl
set_fileset_property sim_vhdl TOP_LEVEL altpcied_sv_hwtcl

add_fileset sim_verilog SIM_VERILOG proc_sim_verilog
set_fileset_property sim_verilog TOP_LEVEL altpcied_sv_hwtcl

add_fileset synth QUARTUS_SYNTH proc_quartus_synth
set_fileset_property synth TOP_LEVEL altpcied_sv_hwtcl

# +-----------------------------------
# | parameters
# |
add_rdpcie_parameters_ui
add_rdpcie_hip_parameters_hidden

# +-----------------------------------
# | ports

# # +-----------------------------------
# # | elaboration items
# # |
proc elaboration_callback { } {
   validation_parameter_func
   rdpcie_hip_parameters_valid
   add_rdpcie_port_clk

   # Port updates
   add_rdpcie_port_ast_rx
   add_rdpcie_port_ast_tx
   add_rdpcie_port_rst
   add_rdpcie_port_interrupt
   add_rdpcie_port_status
   add_rdpcie_port_tl_cfg
   add_rdpcie_port_lmi
   add_rdpcie_port_pw_mngt
}

# +-----------------------------------
# | Static IO
# |
add_interface no_connect conduit end

# ************** Global Variables ***************
set not_init "default"
# **************** Parameters *******************


proc proc_quartus_synth {name} {

   set port_type_hwtcl  [ get_parameter_value port_type_hwtcl ]
   set dev_family [get_parameter_value device_family_hwtcl ]
   set use_ep_simple_downstream_apps_hwtcl [get_parameter_value use_ep_simple_downstream_apps_hwtcl ]

   if { $use_ep_simple_downstream_apps_hwtcl == 1 } {
      add_fileset_file altpcied_sv_hwtcl.sv                SYSTEMVERILOG PATH altpcie_simple_downstream_apps/altpcied_simple_downstream_app.sv
      add_fileset_file altpcied_ep_64bit_downstream.v       VERILOG PATH altpcie_simple_downstream_apps/altpcied_ep_64bit_downstream.v
      add_fileset_file altpcied_ep_128bit_downstream.v      VERILOG PATH altpcie_simple_downstream_apps/altpcied_ep_128bit_downstream.v
      add_fileset_file altpcied_ep_256bit_downstream.v      VERILOG PATH altpcie_simple_downstream_apps/altpcied_ep_256bit_downstream.v
   } else {
      add_fileset_file altpcied_sv_hwtcl.sv                SYSTEMVERILOG PATH altpcied_sv_hwtcl.sv
      add_fileset_file altpcierd_hip_rs.v                  VERILOG PATH example_design/verilog/chaining_dma/altpcierd_hip_rs.v
      add_fileset_file altpcierd_tl_cfg_sample.v           VERILOG PATH example_design/verilog/chaining_dma/altpcierd_tl_cfg_sample.v

      global env
      set QUARTUS_ROOTDIR $env(QUARTUS_ROOTDIR)

      if { [ regexp endpoint $port_type_hwtcl ] } {
         add_fileset_file altpcierd_ast256_downstream.v       VERILOG PATH example_design/verilog/chaining_dma/altpcierd_ast256_downstream.v
         add_fileset_file altpcierd_cdma_app_icm.v            VERILOG PATH example_design/verilog/chaining_dma/altpcierd_cdma_app_icm.v
         add_fileset_file altpcierd_cdma_ast_msi.v            VERILOG PATH example_design/verilog/chaining_dma/altpcierd_cdma_ast_msi.v
         add_fileset_file altpcierd_cdma_ast_rx.v             VERILOG PATH example_design/verilog/chaining_dma/altpcierd_cdma_ast_rx.v
         add_fileset_file altpcierd_cdma_ast_rx_128.v         VERILOG PATH example_design/verilog/chaining_dma/altpcierd_cdma_ast_rx_128.v
         add_fileset_file altpcierd_cdma_ast_rx_64.v          VERILOG PATH example_design/verilog/chaining_dma/altpcierd_cdma_ast_rx_64.v
         add_fileset_file altpcierd_cdma_ast_tx.v             VERILOG PATH example_design/verilog/chaining_dma/altpcierd_cdma_ast_tx.v
         add_fileset_file altpcierd_cdma_ast_tx_128.v         VERILOG PATH example_design/verilog/chaining_dma/altpcierd_cdma_ast_tx_128.v
         add_fileset_file altpcierd_cdma_ast_tx_64.v          VERILOG PATH example_design/verilog/chaining_dma/altpcierd_cdma_ast_tx_64.v
         add_fileset_file altpcierd_compliance_test.v         VERILOG PATH example_design/verilog/chaining_dma/altpcierd_compliance_test.v
         add_fileset_file altpcierd_cpld_rx_buffer.v          VERILOG PATH example_design/verilog/chaining_dma/altpcierd_cpld_rx_buffer.v
         add_fileset_file altpcierd_cplerr_lmi.v              VERILOG PATH example_design/verilog/chaining_dma/altpcierd_cplerr_lmi.v
         add_fileset_file altpcierd_dma_descriptor.v          VERILOG PATH example_design/verilog/chaining_dma/altpcierd_dma_descriptor.v
         add_fileset_file altpcierd_dma_dt.v                  VERILOG PATH example_design/verilog/chaining_dma/altpcierd_dma_dt.v
         add_fileset_file altpcierd_dma_prg_reg.v             VERILOG PATH example_design/verilog/chaining_dma/altpcierd_dma_prg_reg.v
         add_fileset_file altpcierd_example_app_chaining.v    VERILOG PATH example_design/verilog/chaining_dma/altpcierd_example_app_chaining.v
         add_fileset_file altpcierd_npcred_monitor.v          VERILOG PATH example_design/verilog/chaining_dma/altpcierd_npcred_monitor.v
         add_fileset_file altpcierd_pcie_reconfig_initiator.v VERILOG PATH example_design/verilog/chaining_dma/altpcierd_pcie_reconfig_initiator.v
         add_fileset_file altpcierd_rc_slave.v                VERILOG PATH example_design/verilog/chaining_dma/altpcierd_rc_slave.v
         add_fileset_file altpcierd_read_dma_requester.v      VERILOG PATH example_design/verilog/chaining_dma/altpcierd_read_dma_requester.v
         add_fileset_file altpcierd_read_dma_requester_128.v  VERILOG PATH example_design/verilog/chaining_dma/altpcierd_read_dma_requester_128.v
         add_fileset_file altpcierd_reconfig_clk_pll.v        VERILOG PATH example_design/verilog/chaining_dma/altpcierd_reconfig_clk_pll.v
         add_fileset_file altpcierd_reg_access.v              VERILOG PATH example_design/verilog/chaining_dma/altpcierd_reg_access.v
         add_fileset_file altpcierd_rxtx_downstream_intf.v    VERILOG PATH example_design/verilog/chaining_dma/altpcierd_rxtx_downstream_intf.v
         add_fileset_file altpcierd_write_dma_requester.v     VERILOG PATH example_design/verilog/chaining_dma/altpcierd_write_dma_requester.v
         add_fileset_file altpcierd_write_dma_requester_128.v VERILOG PATH example_design/verilog/chaining_dma/altpcierd_write_dma_requester_128.v
      }
   }

   set INTENDED_DEVICE_FAMILY [ get_parameter_value INTENDED_DEVICE_FAMILY ]
   if { $INTENDED_DEVICE_FAMILY == "Arria 10" } {
      add_fileset_file altpcied_a10.sdc                     SDC     PATH altpcied_a10.sdc
   } else {
      add_fileset_file altpcied_sv.sdc                     SDC     PATH altpcied_sv.sdc
   }
}

proc proc_sim_vhdl {name} {
   set dev_family [get_parameter_value device_family_hwtcl ]
   set use_ep_simple_downstream_apps_hwtcl [get_parameter_value use_ep_simple_downstream_apps_hwtcl ]

   # Reconfig IP files

   if { $use_ep_simple_downstream_apps_hwtcl == 1 } {
      add_fileset_file altpcied_sv_hwtcl.sv                SYSTEMVERILOG PATH altpcie_simple_downstream_apps/altpcied_simple_downstream_app.sv
      add_fileset_file altpcied_ep_64bit_downstream.v       VERILOG PATH altpcie_simple_downstream_apps/altpcied_ep_64bit_downstream.v
      add_fileset_file altpcied_ep_128bit_downstream.v      VERILOG PATH altpcie_simple_downstream_apps/altpcied_ep_128bit_downstream.v
      add_fileset_file altpcied_ep_256bit_downstream.v      VERILOG PATH altpcie_simple_downstream_apps/altpcied_ep_256bit_downstream.v
   } else {
      set verilog_file {"example_design/verilog/chaining_dma/altpcierd_hip_rs.v" "example_design/verilog/chaining_dma/altpcierd_rx_ecrc_128_sim.v" "example_design/verilog/chaining_dma/altpcierd_rx_ecrc_64_sim.v" "example_design/verilog/chaining_dma/altpcierd_tx_ecrc_128_sim.v" "example_design/verilog/chaining_dma/altpcierd_tx_ecrc_64_sim.v"  }
      foreach vf $verilog_file {
         # Co-simulation clear text verilog files
         # Mentor only co-simulation files encrypted
         if {1} {
            add_fileset_file mentor/${vf} VERILOG_ENCRYPT PATH mentor/${vf} {MENTOR_SPECIFIC}
         }
      }
      add_fileset_file mentor/altpcied_sv_hwtcl.sv          SYSTEMVERILOG_ENCRYPT PATH mentor/altpcied_sv_hwtcl.sv {MENTOR_SPECIFIC}

      set port_type_hwtcl  [ get_parameter_value port_type_hwtcl ]

      add_fileset_file altpcierd_tl_cfg_sample.vhd            VHDL PATH example_design/vhdl/chaining_dma/altpcierd_tl_cfg_sample.vhd

      if { [ regexp endpoint $port_type_hwtcl ] } {
         add_fileset_file altpcierd_ast256_downstream.vhd        VHDL PATH example_design/vhdl/chaining_dma/altpcierd_ast256_downstream.vhd
         add_fileset_file altpcierd_cdma_app_icm.vhd             VHDL PATH example_design/vhdl/chaining_dma/altpcierd_cdma_app_icm.vhd
         add_fileset_file altpcierd_cdma_ast_msi.vhd             VHDL PATH example_design/vhdl/chaining_dma/altpcierd_cdma_ast_msi.vhd
         add_fileset_file altpcierd_cdma_ast_rx.vhd              VHDL PATH example_design/vhdl/chaining_dma/altpcierd_cdma_ast_rx.vhd
         add_fileset_file altpcierd_cdma_ast_rx_128.vhd          VHDL PATH example_design/vhdl/chaining_dma/altpcierd_cdma_ast_rx_128.vhd
         add_fileset_file altpcierd_cdma_ast_rx_64.vhd           VHDL PATH example_design/vhdl/chaining_dma/altpcierd_cdma_ast_rx_64.vhd
         add_fileset_file altpcierd_cdma_ast_tx.vhd              VHDL PATH example_design/vhdl/chaining_dma/altpcierd_cdma_ast_tx.vhd
         add_fileset_file altpcierd_cdma_ast_tx_128.vhd          VHDL PATH example_design/vhdl/chaining_dma/altpcierd_cdma_ast_tx_128.vhd
         add_fileset_file altpcierd_cdma_ast_tx_64.vhd           VHDL PATH example_design/vhdl/chaining_dma/altpcierd_cdma_ast_tx_64.vhd
         add_fileset_file altpcierd_cdma_ecrc_check_128.vhd      VHDL PATH example_design/vhdl/chaining_dma/altpcierd_cdma_ecrc_check_128.vhd
         add_fileset_file altpcierd_cdma_ecrc_check_64.vhd       VHDL PATH example_design/vhdl/chaining_dma/altpcierd_cdma_ecrc_check_64.vhd
         add_fileset_file altpcierd_cdma_ecrc_gen.vhd            VHDL PATH example_design/vhdl/chaining_dma/altpcierd_cdma_ecrc_gen.vhd
         add_fileset_file altpcierd_cdma_ecrc_gen_calc.vhd       VHDL PATH example_design/vhdl/chaining_dma/altpcierd_cdma_ecrc_gen_calc.vhd
         add_fileset_file altpcierd_cdma_ecrc_gen_ctl_128.vhd    VHDL PATH example_design/vhdl/chaining_dma/altpcierd_cdma_ecrc_gen_ctl_128.vhd
         add_fileset_file altpcierd_cdma_ecrc_gen_ctl_64.vhd     VHDL PATH example_design/vhdl/chaining_dma/altpcierd_cdma_ecrc_gen_ctl_64.vhd
         add_fileset_file altpcierd_cdma_ecrc_gen_datapath.vhd   VHDL PATH example_design/vhdl/chaining_dma/altpcierd_cdma_ecrc_gen_datapath.vhd
         add_fileset_file altpcierd_compliance_test.vhd          VHDL PATH example_design/vhdl/chaining_dma/altpcierd_compliance_test.vhd
         add_fileset_file altpcierd_cpld_rx_buffer.vhd           VHDL PATH example_design/vhdl/chaining_dma/altpcierd_cpld_rx_buffer.vhd
         add_fileset_file altpcierd_cplerr_lmi.vhd               VHDL PATH example_design/vhdl/chaining_dma/altpcierd_cplerr_lmi.vhd
         add_fileset_file altpcierd_dma_descriptor.vhd           VHDL PATH example_design/vhdl/chaining_dma/altpcierd_dma_descriptor.vhd
         add_fileset_file altpcierd_dma_dt.vhd                   VHDL PATH example_design/vhdl/chaining_dma/altpcierd_dma_dt.vhd
         add_fileset_file altpcierd_dma_prg_reg.vhd              VHDL PATH example_design/vhdl/chaining_dma/altpcierd_dma_prg_reg.vhd
         add_fileset_file altpcierd_example_app_chaining.vhd     VHDL PATH example_design/vhdl/chaining_dma/altpcierd_example_app_chaining.vhd
         add_fileset_file altpcierd_pcie_reconfig_initiator.vhd  VHDL PATH example_design/vhdl/chaining_dma/altpcierd_pcie_reconfig_initiator.vhd
         add_fileset_file altpcierd_rc_slave.vhd                 VHDL PATH example_design/vhdl/chaining_dma/altpcierd_rc_slave.vhd
         add_fileset_file altpcierd_read_dma_requester.vhd       VHDL PATH example_design/vhdl/chaining_dma/altpcierd_read_dma_requester.vhd
         add_fileset_file altpcierd_read_dma_requester_128.vhd   VHDL PATH example_design/vhdl/chaining_dma/altpcierd_read_dma_requester_128.vhd
         add_fileset_file altpcierd_reconfig_clk_pll.vhd         VHDL PATH example_design/vhdl/chaining_dma/altpcierd_reconfig_clk_pll.vhd
         add_fileset_file altpcierd_reg_access.vhd               VHDL PATH example_design/vhdl/chaining_dma/altpcierd_reg_access.vhd
         add_fileset_file altpcierd_rxtx_downstream_intf.vhd     VHDL PATH example_design/vhdl/chaining_dma/altpcierd_rxtx_downstream_intf.vhd
         add_fileset_file altpcierd_tx_ecrc_ctl_fifo.vhd         VHDL PATH example_design/vhdl/chaining_dma/altpcierd_tx_ecrc_ctl_fifo.vhd
         add_fileset_file altpcierd_tx_ecrc_data_fifo.vhd        VHDL PATH example_design/vhdl/chaining_dma/altpcierd_tx_ecrc_data_fifo.vhd
         add_fileset_file altpcierd_tx_ecrc_fifo.vhd             VHDL PATH example_design/vhdl/chaining_dma/altpcierd_tx_ecrc_fifo.vhd
         add_fileset_file altpcierd_write_dma_requester.vhd      VHDL PATH example_design/vhdl/chaining_dma/altpcierd_write_dma_requester.vhd
         add_fileset_file altpcierd_write_dma_requester_128.vhd  VHDL PATH example_design/vhdl/chaining_dma/altpcierd_write_dma_requester_128.vhd
      } else {
         # Currently No VHDL support for RP simulation Verilog only
         add_fileset_file altpcietb_bfm_vc_intf_ast.v  VERILOG PATH example_design/verilog/root_port/altpcietb_bfm_vc_intf_ast.v
         add_fileset_file altpcierd_reconfig_clk_pll.v VERILOG PATH example_design/verilog/root_port/altpcierd_reconfig_clk_pll.v
         add_fileset_file altpcierd_cdma_ecrc_check.v  VERILOG PATH example_design/verilog/root_port/altpcierd_cdma_ecrc_check.v
      }
   }

}

proc proc_sim_verilog {name} {

   set port_type_hwtcl  [ get_parameter_value port_type_hwtcl ]
   set dev_family [get_parameter_value device_family_hwtcl ]
   set use_ep_simple_downstream_apps_hwtcl [get_parameter_value use_ep_simple_downstream_apps_hwtcl ]

   if { $use_ep_simple_downstream_apps_hwtcl == 1 } {
      add_fileset_file altpcied_sv_hwtcl.sv                SYSTEMVERILOG PATH altpcie_simple_downstream_apps/altpcied_simple_downstream_app.sv
      add_fileset_file altpcied_ep_64bit_downstream.v      VERILOG PATH altpcie_simple_downstream_apps/altpcied_ep_64bit_downstream.v
      add_fileset_file altpcied_ep_128bit_downstream.v     VERILOG PATH altpcie_simple_downstream_apps/altpcied_ep_128bit_downstream.v
      add_fileset_file altpcied_ep_256bit_downstream.v     VERILOG PATH altpcie_simple_downstream_apps/altpcied_ep_256bit_downstream.v
   } else {
      add_fileset_file altpcied_sv_hwtcl.sv                 SYSTEMVERILOG PATH altpcied_sv_hwtcl.sv
      add_fileset_file altpcierd_hip_rs.v                   VERILOG PATH example_design/verilog/chaining_dma/altpcierd_hip_rs.v
      add_fileset_file altpcierd_tl_cfg_sample.v            VERILOG PATH example_design/verilog/chaining_dma/altpcierd_tl_cfg_sample.v

      if { [ regexp endpoint $port_type_hwtcl ] } {
         add_fileset_file altpcierd_rx_ecrc_128_sim.v          VERILOG PATH example_design/verilog/chaining_dma/altpcierd_rx_ecrc_128_sim.v
         add_fileset_file altpcierd_rx_ecrc_64_sim.v           VERILOG PATH example_design/verilog/chaining_dma/altpcierd_rx_ecrc_64_sim.v
         add_fileset_file altpcierd_tx_ecrc_128_sim.v          VERILOG PATH example_design/verilog/chaining_dma/altpcierd_tx_ecrc_128_sim.v
         add_fileset_file altpcierd_tx_ecrc_64_sim.v           VERILOG PATH example_design/verilog/chaining_dma/altpcierd_tx_ecrc_64_sim.v
         add_fileset_file altpcierd_ast256_downstream.v        VERILOG PATH example_design/verilog/chaining_dma/altpcierd_ast256_downstream.v
         add_fileset_file altpcierd_cdma_app_icm.v             VERILOG PATH example_design/verilog/chaining_dma/altpcierd_cdma_app_icm.v
         add_fileset_file altpcierd_cdma_ast_msi.v             VERILOG PATH example_design/verilog/chaining_dma/altpcierd_cdma_ast_msi.v
         add_fileset_file altpcierd_cdma_ast_rx.v              VERILOG PATH example_design/verilog/chaining_dma/altpcierd_cdma_ast_rx.v
         add_fileset_file altpcierd_cdma_ast_rx_128.v          VERILOG PATH example_design/verilog/chaining_dma/altpcierd_cdma_ast_rx_128.v
         add_fileset_file altpcierd_cdma_ast_rx_64.v           VERILOG PATH example_design/verilog/chaining_dma/altpcierd_cdma_ast_rx_64.v
         add_fileset_file altpcierd_cdma_ast_tx.v              VERILOG PATH example_design/verilog/chaining_dma/altpcierd_cdma_ast_tx.v
         add_fileset_file altpcierd_cdma_ast_tx_128.v          VERILOG PATH example_design/verilog/chaining_dma/altpcierd_cdma_ast_tx_128.v
         add_fileset_file altpcierd_cdma_ast_tx_64.v           VERILOG PATH example_design/verilog/chaining_dma/altpcierd_cdma_ast_tx_64.v
         add_fileset_file altpcierd_cdma_ecrc_check_128.v      VERILOG PATH example_design/verilog/chaining_dma/altpcierd_cdma_ecrc_check_128.v
         add_fileset_file altpcierd_cdma_ecrc_check_64.v       VERILOG PATH example_design/verilog/chaining_dma/altpcierd_cdma_ecrc_check_64.v
         add_fileset_file altpcierd_cdma_ecrc_gen.v            VERILOG PATH example_design/verilog/chaining_dma/altpcierd_cdma_ecrc_gen.v
         add_fileset_file altpcierd_cdma_ecrc_gen_calc.v       VERILOG PATH example_design/verilog/chaining_dma/altpcierd_cdma_ecrc_gen_calc.v
         add_fileset_file altpcierd_cdma_ecrc_gen_ctl_128.v    VERILOG PATH example_design/verilog/chaining_dma/altpcierd_cdma_ecrc_gen_ctl_128.v
         add_fileset_file altpcierd_cdma_ecrc_gen_ctl_64.v     VERILOG PATH example_design/verilog/chaining_dma/altpcierd_cdma_ecrc_gen_ctl_64.v
         add_fileset_file altpcierd_cdma_ecrc_gen_datapath.v   VERILOG PATH example_design/verilog/chaining_dma/altpcierd_cdma_ecrc_gen_datapath.v
         add_fileset_file altpcierd_compliance_test.v          VERILOG PATH example_design/verilog/chaining_dma/altpcierd_compliance_test.v
         add_fileset_file altpcierd_cpld_rx_buffer.v           VERILOG PATH example_design/verilog/chaining_dma/altpcierd_cpld_rx_buffer.v
         add_fileset_file altpcierd_cplerr_lmi.v               VERILOG PATH example_design/verilog/chaining_dma/altpcierd_cplerr_lmi.v
         add_fileset_file altpcierd_dma_descriptor.v           VERILOG PATH example_design/verilog/chaining_dma/altpcierd_dma_descriptor.v
         add_fileset_file altpcierd_dma_dt.v                   VERILOG PATH example_design/verilog/chaining_dma/altpcierd_dma_dt.v
         add_fileset_file altpcierd_dma_prg_reg.v              VERILOG PATH example_design/verilog/chaining_dma/altpcierd_dma_prg_reg.v
         add_fileset_file altpcierd_example_app_chaining.v     VERILOG PATH example_design/verilog/chaining_dma/altpcierd_example_app_chaining.v
         add_fileset_file altpcierd_npcred_monitor.v           VERILOG PATH example_design/verilog/chaining_dma/altpcierd_npcred_monitor.v
         add_fileset_file altpcierd_pcie_reconfig_initiator.v  VERILOG PATH example_design/verilog/chaining_dma/altpcierd_pcie_reconfig_initiator.v
         add_fileset_file altpcierd_rc_slave.v                 VERILOG PATH example_design/verilog/chaining_dma/altpcierd_rc_slave.v
         add_fileset_file altpcierd_read_dma_requester.v       VERILOG PATH example_design/verilog/chaining_dma/altpcierd_read_dma_requester.v
         add_fileset_file altpcierd_read_dma_requester_128.v   VERILOG PATH example_design/verilog/chaining_dma/altpcierd_read_dma_requester_128.v
         add_fileset_file altpcierd_reconfig_clk_pll.v         VERILOG PATH example_design/verilog/chaining_dma/altpcierd_reconfig_clk_pll.v
         add_fileset_file altpcierd_reg_access.v               VERILOG PATH example_design/verilog/chaining_dma/altpcierd_reg_access.v
         add_fileset_file altpcierd_rxtx_downstream_intf.v     VERILOG PATH example_design/verilog/chaining_dma/altpcierd_rxtx_downstream_intf.v
         add_fileset_file altpcierd_tx_ecrc_ctl_fifo.v         VERILOG PATH example_design/verilog/chaining_dma/altpcierd_tx_ecrc_ctl_fifo.v
         add_fileset_file altpcierd_tx_ecrc_data_fifo.v        VERILOG PATH example_design/verilog/chaining_dma/altpcierd_tx_ecrc_data_fifo.v
         add_fileset_file altpcierd_tx_ecrc_fifo.v             VERILOG PATH example_design/verilog/chaining_dma/altpcierd_tx_ecrc_fifo.v
         add_fileset_file altpcierd_write_dma_requester.v      VERILOG PATH example_design/verilog/chaining_dma/altpcierd_write_dma_requester.v
         add_fileset_file altpcierd_write_dma_requester_128.v  VERILOG PATH example_design/verilog/chaining_dma/altpcierd_write_dma_requester_128.v
      } else {
         add_fileset_file altpcietb_bfm_vc_intf_ast.v          VERILOG PATH example_design/verilog/root_port/altpcietb_bfm_vc_intf_ast.v
         add_fileset_file altpcierd_reconfig_clk_pll.v         VERILOG PATH example_design/verilog/root_port/altpcierd_reconfig_clk_pll.v
         add_fileset_file altpcierd_cdma_ecrc_check.v          VERILOG PATH example_design/verilog/root_port/altpcierd_cdma_ecrc_check.v
      }
   }

}

