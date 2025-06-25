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


package require -exact qsys 11.1
sopc::preview_add_transform name preview_avalon_mm_transform
source pcie_sv_sriov_app_parameters.tcl
source pcie_sv_sriov_app_port.tcl

global env
set QUARTUS_ROOTDIR $env(QUARTUS_ROOTDIR)

# get xcvr PHY function definitions
source ${QUARTUS_ROOTDIR}/../ip/altera/altera_xcvr_generic/alt_xcvr_common.tcl

# +-----------------------------------
# | module PCI Express
# |
set_module_property NAME altera_pcie_sv_sriov_ast_ed
set_module_property DESCRIPTION "Example design for PCIe SR-IOV AVST"
set_module_property VERSION 13.1
set_module_property DATASHEET_URL "http://www.altera.com/literature/ug/ug_s5_pcie.pdf"
set_module_property GROUP "Interface Protocols/PCI"
set_module_property AUTHOR Altera
set_module_property DISPLAY_NAME "Example design for PCIe SR-IOV AVST"
set_module_property HIDE_FROM_SOPC true
set_module_property INTERNAL false
set_module_property EDITABLE false
set_module_property ANALYZE_HDL FALSE
set_module_property ELABORATION_CALLBACK elaboration_callback
set_module_property instantiateInSystemModule "true"

# # +-----------------------------------
# # | Example design RTL files
#   |
add_fileset sim_vhdl SIM_VHDL proc_sim_vhdl
set_fileset_property sim_vhdl TOP_LEVEL altera_pcie_sv_sriov_app_hwtcl

add_fileset sim_verilog SIM_VERILOG proc_sim_verilog
set_fileset_property sim_verilog TOP_LEVEL altera_pcie_sv_sriov_app_hwtcl

add_fileset synth QUARTUS_SYNTH proc_quartus_synth
set_fileset_property synth TOP_LEVEL altera_pcie_sv_sriov_app_hwtcl

# +-----------------------------------
# | parameters
# |
add_ed_sriov_parameters_ui
add_ed_sriov_parameters_hidden

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
   add_ed_sriov_port_ast_rx
   add_ed_sriov_port_ast_tx
   add_ed_sriov_port_rst
   add_ed_sriov_port_interrupt
   add_ed_sriov_port_status
   add_ed_sriov_port_lmi
   add_ed_sriov_port_flr
   add_ed_sriov_port_cfgstatus
   add_ed_sriov_port_completion
   add_ed_sriov_port_hip_misc
}

# +-----------------------------------
# | Static IO
# |
add_interface no_connect conduit end

# ************** Global Variables ***************
set not_init "default"
# **************** Parameters *******************

#=======================
# Synthesis files
#=======================
proc proc_quartus_synth {name} {

   global env
   set QUARTUS_ROOTDIR $env(QUARTUS_ROOTDIR)

   set port_type_hwtcl  [ get_parameter_value port_type_hwtcl ]
   set dev_family [get_parameter_value device_family_hwtcl ]

   if { [ regexp endpoint $port_type_hwtcl ] } {
        add_fileset_file altera_pcie_sv_sriov_app_hwtcl.sv    SYSTEMVERILOG PATH altera_pcie_sv_sriov_app_hwtcl.sv
        add_fileset_file altpcierd_hip_rs.v                   VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/example_design/verilog/chaining_dma/altpcierd_hip_rs.v
        add_fileset_file altpcierd_cplerr_lmi.v               VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/example_design/verilog/chaining_dma/altpcierd_cplerr_lmi.v
        add_fileset_file altpcied_cfbp_top.v                  VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_sv_sriov_ast_ed/simple_256b_downstream/altpcied_cfbp_top.v
        add_fileset_file altpcied_cfbp_256b_control.v         VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_sv_sriov_ast_ed/simple_256b_downstream/altpcied_cfbp_256b_control.v
        add_fileset_file altpcied_cfbp_target.v               VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_sv_sriov_ast_ed/simple_256b_downstream/altpcied_cfbp_target.v
        add_fileset_file altpcied_cfbp_mbox.v                 VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_sv_sriov_ast_ed/simple_256b_downstream/altpcied_cfbp_mbox.v
        add_fileset_file altpcied_tgt_mux.v                   VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_sv_sriov_ast_ed/simple_256b_downstream/altpcied_tgt_mux.v
   }
   common_add_fileset_files { S5 ALL_HDL } { PLAIN }
}

#=======================
# VHDL files
#=======================
proc proc_sim_vhdl {name} {

   global env
   set QUARTUS_ROOTDIR $env(QUARTUS_ROOTDIR)

   set port_type_hwtcl  [ get_parameter_value port_type_hwtcl ]
   set dev_family [get_parameter_value device_family_hwtcl ]


   if { [ regexp endpoint $port_type_hwtcl ] } {
        add_fileset_file altera_pcie_sv_sriov_app_hwtcl.sv    SYSTEMVERILOG PATH altera_pcie_sv_sriov_app_hwtcl.sv
        add_fileset_file altpcierd_hip_rs.v                   VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/example_design/verilog/chaining_dma/altpcierd_hip_rs.v
        add_fileset_file altpcierd_cplerr_lmi.v               VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/example_design/verilog/chaining_dma/altpcierd_cplerr_lmi.v
        add_fileset_file altpcied_cfbp_top.v                  VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_sv_sriov_ast_ed/simple_256b_downstream/altpcied_cfbp_top.v
        add_fileset_file altpcied_cfbp_256b_control.v         VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_sv_sriov_ast_ed/simple_256b_downstream/altpcied_cfbp_256b_control.v
        add_fileset_file altpcied_cfbp_target.v               VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_sv_sriov_ast_ed/simple_256b_downstream/altpcied_cfbp_target.v
        add_fileset_file altpcied_cfbp_mbox.v                 VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_sv_sriov_ast_ed/simple_256b_downstream/altpcied_cfbp_mbox.v
        add_fileset_file altpcied_tgt_mux.v                   VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_sv_sriov_ast_ed/simple_256b_downstream/altpcied_tgt_mux.v
   }

   # The following files are needed for Gen3 RP BFM. These files are listed in altera_pcie_hip_ast_ed_hw.tcl
   add_fileset_file altpcied_sv_hwtcl.sv          SYSTEMVERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/altpcied_sv_hwtcl.sv
   add_fileset_file altpcierd_tl_cfg_sample.v           VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/example_design/verilog/chaining_dma/altpcierd_tl_cfg_sample.v
   add_fileset_file altpcierd_cdma_app_icm.v            VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/example_design/verilog/chaining_dma/altpcierd_cdma_app_icm.v
   add_fileset_file altpcierd_cdma_ast_msi.v            VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/example_design/verilog/chaining_dma/altpcierd_cdma_ast_msi.v
   add_fileset_file altpcierd_cdma_ast_rx.v             VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/example_design/verilog/chaining_dma/altpcierd_cdma_ast_rx.v
   add_fileset_file altpcierd_cdma_ast_rx_128.v         VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/example_design/verilog/chaining_dma/altpcierd_cdma_ast_rx_128.v
   add_fileset_file altpcierd_cdma_ast_rx_64.v          VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/example_design/verilog/chaining_dma/altpcierd_cdma_ast_rx_64.v
   add_fileset_file altpcierd_cdma_ast_tx.v             VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/example_design/verilog/chaining_dma/altpcierd_cdma_ast_tx.v
   add_fileset_file altpcierd_cdma_ast_tx_128.v         VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/example_design/verilog/chaining_dma/altpcierd_cdma_ast_tx_128.v
   add_fileset_file altpcierd_cdma_ast_tx_64.v          VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/example_design/verilog/chaining_dma/altpcierd_cdma_ast_tx_64.v
   add_fileset_file altpcierd_compliance_test.v         VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/example_design/verilog/chaining_dma/altpcierd_compliance_test.v
   add_fileset_file altpcierd_cpld_rx_buffer.v          VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/example_design/verilog/chaining_dma/altpcierd_cpld_rx_buffer.v
   add_fileset_file altpcierd_cplerr_lmi.v              VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/example_design/verilog/chaining_dma/altpcierd_cplerr_lmi.v
   add_fileset_file altpcierd_dma_descriptor.v          VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/example_design/verilog/chaining_dma/altpcierd_dma_descriptor.v
   add_fileset_file altpcierd_dma_dt.v                  VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/example_design/verilog/chaining_dma/altpcierd_dma_dt.v
   add_fileset_file altpcierd_dma_prg_reg.v             VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/example_design/verilog/chaining_dma/altpcierd_dma_prg_reg.v
   add_fileset_file altpcierd_example_app_chaining.v    VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/example_design/verilog/chaining_dma/altpcierd_example_app_chaining.v
   add_fileset_file altpcierd_npcred_monitor.v          VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/example_design/verilog/chaining_dma/altpcierd_npcred_monitor.v
   add_fileset_file altpcierd_pcie_reconfig_initiator.v VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/example_design/verilog/chaining_dma/altpcierd_pcie_reconfig_initiator.v
   add_fileset_file altpcierd_rc_slave.v                VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/example_design/verilog/chaining_dma/altpcierd_rc_slave.v
   add_fileset_file altpcierd_read_dma_requester.v      VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/example_design/verilog/chaining_dma/altpcierd_read_dma_requester.v
   add_fileset_file altpcierd_read_dma_requester_128.v  VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/example_design/verilog/chaining_dma/altpcierd_read_dma_requester_128.v
   add_fileset_file altpcierd_reconfig_clk_pll.v        VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/example_design/verilog/chaining_dma/altpcierd_reconfig_clk_pll.v
   add_fileset_file altpcierd_reg_access.v              VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/example_design/verilog/chaining_dma/altpcierd_reg_access.v
   add_fileset_file altpcierd_rxtx_downstream_intf.v    VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/example_design/verilog/chaining_dma/altpcierd_rxtx_downstream_intf.v
   add_fileset_file altpcierd_write_dma_requester.v     VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/example_design/verilog/chaining_dma/altpcierd_write_dma_requester.v
   add_fileset_file altpcierd_write_dma_requester_128.v VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/example_design/verilog/chaining_dma/altpcierd_write_dma_requester_128.v

   common_add_fileset_files { S5 ALL_HDL } { PLAIN }
}

#=======================
# Vefilog files
#=======================
proc proc_sim_verilog {name} {

   global env
   set QUARTUS_ROOTDIR $env(QUARTUS_ROOTDIR)

   set port_type_hwtcl  [ get_parameter_value port_type_hwtcl ]
   set dev_family [get_parameter_value device_family_hwtcl ]


   if { [ regexp endpoint $port_type_hwtcl ] } {
        add_fileset_file altera_pcie_sv_sriov_app_hwtcl.sv    SYSTEMVERILOG PATH altera_pcie_sv_sriov_app_hwtcl.sv
        add_fileset_file altpcierd_hip_rs.v                   VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/example_design/verilog/chaining_dma/altpcierd_hip_rs.v
        add_fileset_file altpcierd_cplerr_lmi.v               VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/example_design/verilog/chaining_dma/altpcierd_cplerr_lmi.v
        add_fileset_file altpcied_cfbp_top.v                  VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_sv_sriov_ast_ed/simple_256b_downstream/altpcied_cfbp_top.v
        add_fileset_file altpcied_cfbp_256b_control.v         VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_sv_sriov_ast_ed/simple_256b_downstream/altpcied_cfbp_256b_control.v
        add_fileset_file altpcied_cfbp_target.v               VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_sv_sriov_ast_ed/simple_256b_downstream/altpcied_cfbp_target.v
        add_fileset_file altpcied_cfbp_mbox.v                 VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_sv_sriov_ast_ed/simple_256b_downstream/altpcied_cfbp_mbox.v
        add_fileset_file altpcied_tgt_mux.v                   VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_sv_sriov_ast_ed/simple_256b_downstream/altpcied_tgt_mux.v
   }

   # The following files are needed for Gen3 RP BFM. These files are listed in altera_pcie_hip_ast_ed_hw.tcl
   add_fileset_file altpcied_sv_hwtcl.sv          SYSTEMVERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/altpcied_sv_hwtcl.sv
   add_fileset_file altpcierd_tl_cfg_sample.v           VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/example_design/verilog/chaining_dma/altpcierd_tl_cfg_sample.v
   add_fileset_file altpcierd_cdma_app_icm.v            VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/example_design/verilog/chaining_dma/altpcierd_cdma_app_icm.v
   add_fileset_file altpcierd_cdma_ast_msi.v            VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/example_design/verilog/chaining_dma/altpcierd_cdma_ast_msi.v
   add_fileset_file altpcierd_cdma_ast_rx.v             VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/example_design/verilog/chaining_dma/altpcierd_cdma_ast_rx.v
   add_fileset_file altpcierd_cdma_ast_rx_128.v         VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/example_design/verilog/chaining_dma/altpcierd_cdma_ast_rx_128.v
   add_fileset_file altpcierd_cdma_ast_rx_64.v          VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/example_design/verilog/chaining_dma/altpcierd_cdma_ast_rx_64.v
   add_fileset_file altpcierd_cdma_ast_tx.v             VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/example_design/verilog/chaining_dma/altpcierd_cdma_ast_tx.v
   add_fileset_file altpcierd_cdma_ast_tx_128.v         VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/example_design/verilog/chaining_dma/altpcierd_cdma_ast_tx_128.v
   add_fileset_file altpcierd_cdma_ast_tx_64.v          VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/example_design/verilog/chaining_dma/altpcierd_cdma_ast_tx_64.v
   add_fileset_file altpcierd_compliance_test.v         VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/example_design/verilog/chaining_dma/altpcierd_compliance_test.v
   add_fileset_file altpcierd_cpld_rx_buffer.v          VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/example_design/verilog/chaining_dma/altpcierd_cpld_rx_buffer.v
   add_fileset_file altpcierd_cplerr_lmi.v              VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/example_design/verilog/chaining_dma/altpcierd_cplerr_lmi.v
   add_fileset_file altpcierd_dma_descriptor.v          VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/example_design/verilog/chaining_dma/altpcierd_dma_descriptor.v
   add_fileset_file altpcierd_dma_dt.v                  VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/example_design/verilog/chaining_dma/altpcierd_dma_dt.v
   add_fileset_file altpcierd_dma_prg_reg.v             VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/example_design/verilog/chaining_dma/altpcierd_dma_prg_reg.v
   add_fileset_file altpcierd_example_app_chaining.v    VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/example_design/verilog/chaining_dma/altpcierd_example_app_chaining.v
   add_fileset_file altpcierd_npcred_monitor.v          VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/example_design/verilog/chaining_dma/altpcierd_npcred_monitor.v
   add_fileset_file altpcierd_pcie_reconfig_initiator.v VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/example_design/verilog/chaining_dma/altpcierd_pcie_reconfig_initiator.v
   add_fileset_file altpcierd_rc_slave.v                VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/example_design/verilog/chaining_dma/altpcierd_rc_slave.v
   add_fileset_file altpcierd_read_dma_requester.v      VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/example_design/verilog/chaining_dma/altpcierd_read_dma_requester.v
   add_fileset_file altpcierd_read_dma_requester_128.v  VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/example_design/verilog/chaining_dma/altpcierd_read_dma_requester_128.v
   add_fileset_file altpcierd_reconfig_clk_pll.v        VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/example_design/verilog/chaining_dma/altpcierd_reconfig_clk_pll.v
   add_fileset_file altpcierd_reg_access.v              VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/example_design/verilog/chaining_dma/altpcierd_reg_access.v
   add_fileset_file altpcierd_rxtx_downstream_intf.v    VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/example_design/verilog/chaining_dma/altpcierd_rxtx_downstream_intf.v
   add_fileset_file altpcierd_write_dma_requester.v     VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/example_design/verilog/chaining_dma/altpcierd_write_dma_requester.v
   add_fileset_file altpcierd_write_dma_requester_128.v VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/example_design/verilog/chaining_dma/altpcierd_write_dma_requester_128.v

   common_add_fileset_files { S5 ALL_HDL } { PLAIN }

}

