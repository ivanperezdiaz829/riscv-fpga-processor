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



package require -exact sopc 10.1
sopc::preview_add_transform name preview_avalon_mm_transform
source tbed_pcie_sv_parameters.tcl
source tbed_pcie_sv_port.tcl

# +-----------------------------------
# | module PCI Express
# |
set_module_property NAME altera_pcie_tbed
set_module_property VERSION 13.1
set_module_property DESCRIPTION "Testbench for Avalon-Streaming Stratix V hard IP for PCI Express"
set_module_property DATASHEET_URL "http://www.altera.com/literature/ug/ug_s5_pcie.pdf"
set_module_property GROUP "Interface Protocols/PCI"
set_module_property AUTHOR Altera
set_module_property DISPLAY_NAME "Testbench for Avalon-Streaming Stratix V hard IP for PCI Express"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true

set_module_property HIDE_FROM_SOPC "true"
set_module_property EDITABLE true
set_module_property INTERNAL true
set_module_property ANALYZE_HDL FALSE

set_module_property ELABORATION_CALLBACK elaboration_callback

set_module_property instantiateInSystemModule "true"

set_module_assignment postgeneration.pcie_tb.device_family "STRATIX IV"

# # +-----------------------------------
# # | Example design RTL files
#   |
add_fileset sim_vhdl SIM_VHDL proc_sim_vhdl
set_fileset_property sim_vhdl TOP_LEVEL altpcie_tbed_sv_hwtcl

add_fileset sim_verilog SIM_VERILOG proc_sim_verilog
set_fileset_property sim_verilog TOP_LEVEL altpcie_tbed_sv_hwtcl

# # +-----------------------------------
# # | elaboration items
# # |
proc elaboration_callback { } {
    # Port updates
    add_tbed_hip_port_clk
    add_tbed_hip_port_pipe
    add_tbed_hip_port_serial
    add_tbed_hip_port_control
}
#

# +-----------------------------------
# | files
# |

# |
# +-----------------------------------

# +-----------------------------------
# | parameters
# |
add_tbed_pcie_parameters_ui

# +-----------------------------------
# | Static IO
# |
add_interface no_connect conduit end
add_tbed_hip_port_npor

# ************** Global Variables ***************
set not_init "default"
# **************** Parameters *******************

proc proc_sim_verilog {name} {

   global env
   set QUARTUS_ROOTDIR $env(QUARTUS_ROOTDIR)
   set port_type_hwtcl             [ get_parameter_value port_type_hwtcl ]
   set lane_mask_hwtcl             [ get_parameter lane_mask_hwtcl ]
   set pll_refclk_freq_hwtcl       [ get_parameter pll_refclk_freq_hwtcl ]
   set gen123_lane_rate_mode_hwtcl [ get_parameter gen123_lane_rate_mode_hwtcl ]
   set apps_type_hwtcl             [ get_parameter_value apps_type_hwtcl ]
   set enable_tl_only_sim_hwtcl    [ get_parameter_value enable_tl_only_sim_hwtcl ]

   set set_bfm_driver_to_config_only            1
   set set_bfm_driver_to_chaining_dma           2
   set set_bfm_driver_to_config_target          3
   set set_bfm_driver_to_config_bypass          10
   set set_bfm_driver_to_simple_ep_downstream   11

   add_fileset_file altpcietb_ltssm_mon.v                VERILOG PATH verilog/altpcietb_ltssm_mon.v
   add_fileset_file altpcietb_pipe_phy.v                 VERILOG PATH verilog/altpcietb_pipe_phy.v
   add_fileset_file altpcietb_pipe32_hip_interface.v     VERILOG PATH verilog/altpcietb_pipe32_hip_interface.v
   add_fileset_file altpcietb_pipe32_driver.v            VERILOG PATH verilog/altpcietb_pipe32_driver.v
   add_fileset_file altpcie_tbed_sv_hwtcl.v              VERILOG PATH altpcie_tbed_sv_hwtcl.v
   add_fileset_file altpcietb_bfm_log.v                  VERILOG_INCLUDE PATH verilog/altpcietb_bfm_log.v
   add_fileset_file altpcietb_bfm_configure.v            VERILOG_INCLUDE PATH verilog/altpcietb_bfm_configure.v
   add_fileset_file altpcietb_bfm_constants.v            VERILOG_INCLUDE PATH verilog/altpcietb_bfm_constants.v
   add_fileset_file altpcietb_bfm_rdwr.v                 VERILOG_INCLUDE PATH verilog/altpcietb_bfm_rdwr.v
   add_fileset_file altpcietb_bfm_req_intf.v             VERILOG_INCLUDE PATH verilog/altpcietb_bfm_req_intf.v
   add_fileset_file altpcietb_bfm_shmem.v                VERILOG_INCLUDE PATH verilog/altpcietb_bfm_shmem.v


   if { $enable_tl_only_sim_hwtcl == 1 } {

      if {1} {
      add_fileset_file mentor/altpcietb_tlbfm_rp_gen3_x8.v         VERILOG_ENCRYPT PATH mentor/verilog/altpcietb_tlbfm_rp_gen3_x8.v        {MENTOR_SPECIFIC}
      }

      if {0} {
         add_fileset_file synopsys/altpcietb_tlbfm_rp_gen3_x8.v    VERILOG_ENCRYPT PATH synopsys/verilog/altpcietb_tlbfm_rp_gen3_x8.v      {SYNOPSYS_SPECIFIC}
      }

      if {0} {
         add_fileset_file cadence/altpcietb_tlbfm_rp_gen3_x8.v     VERILOG_ENCRYPT PATH cadence/verilog/altpcietb_tlbfm_rp_gen3_x8.v       {CADENCE_SPECIFIC}
      }

      if {1} {
         add_fileset_file aldec/altpcietb_tlbfm_rp_gen3_x8.v       VERILOG_ENCRYPT PATH aldec/verilog/altpcietb_tlbfm_rp_gen3_x8.v         {ALDEC_SPECIFIC}
      }

      add_fileset_file altpcietb_tlbfm_rp.v                 VERILOG PATH verilog/altpcietb_tlbfm_rp.v
      add_fileset_file altpcietb_bfm_driver_chaining.v      VERILOG PATH verilog/altpcietb_bfm_driver_chaining.v
      add_fileset_file altpcietb_bfm_driver_downstream.v    VERILOG PATH verilog/altpcietb_bfm_driver_downstream.v
      add_fileset_file altpcietb_bfm_driver_avmm.v          VERILOG PATH verilog/altpcietb_bfm_driver_avmm.v
      add_fileset_file altpcietb_bfm_log_common.v           VERILOG PATH verilog/altpcietb_bfm_log_common.v
      add_fileset_file altpcietb_bfm_req_intf_common.v      VERILOG PATH verilog/altpcietb_bfm_req_intf_common.v
      add_fileset_file altpcietb_bfm_shmem_common.v         VERILOG PATH verilog/altpcietb_bfm_shmem_common.v
      add_fileset_file altpcietb_bfm_vc_intf_64.v           VERILOG PATH verilog/altpcietb_bfm_vc_intf_64.v
      add_fileset_file altpcietb_rst_clk.v                  VERILOG PATH verilog/altpcietb_rst_clk.v
   } else {
      if { [ regexp endpoint $port_type_hwtcl ] } {
         if { [ regexp Gen3 $gen123_lane_rate_mode_hwtcl ] } {
            # Use testbench BFM Gen3 x8
            add_fileset_file altpcietb_bfm_top_rp.v                VERILOG PATH verilog/altpcietb_bfm_top_rp.v
            if { $apps_type_hwtcl == $set_bfm_driver_to_config_bypass } {
               add_fileset_file altpcietb_bfm_rp_g3x8_cfgbp.v         VERILOG PATH ../altera_pcie_hip_ast_ed/altera_pcie_cfgbp_ed/sim_bfm/altpcietb_bfm_rp_g3x8_cfgbp.v
            } else {
               add_fileset_file altpcietb_bfm_rp_gen3_x8.v         VERILOG PATH verilog/altpcietb_bfm_rp_gen3_x8.v
            }
            add_fileset_file altpcietb_g3bfm_log.v                 VERILOG_INCLUDE PATH verilog/altpcietb_g3bfm_log.v
            add_fileset_file altpcietb_g3bfm_configure.v           VERILOG_INCLUDE PATH verilog/altpcietb_g3bfm_configure.v
            add_fileset_file altpcietb_g3bfm_constants.v           VERILOG_INCLUDE PATH verilog/altpcietb_g3bfm_constants.v
            add_fileset_file altpcietb_g3bfm_rdwr.v                VERILOG_INCLUDE PATH verilog/altpcietb_g3bfm_rdwr.v
            add_fileset_file altpcietb_g3bfm_req_intf.v            VERILOG_INCLUDE PATH verilog/altpcietb_g3bfm_req_intf.v
            add_fileset_file altpcietb_g3bfm_shmem.v               VERILOG_INCLUDE PATH verilog/altpcietb_g3bfm_shmem.v
            add_fileset_file altpcietb_g3bfm_vc_intf_ast_common.v  VERILOG_INCLUDE PATH verilog/altpcietb_g3bfm_vc_intf_ast_common.v
            if { $apps_type_hwtcl ==  4 || $apps_type_hwtcl == 5 || $apps_type_hwtcl == 6 }  {
               add_fileset_file alt_xcvr_reconfig_h.sv             SYSTEMVERILOG PATH ../../alt_xcvr_reconfig/alt_xcvr_reconfig/alt_xcvr_reconfig_h.sv
               add_fileset_file altpcierd_tl_cfg_sample.v          VERILOG PATH ../altera_pcie_hip_ast_ed/example_design/verilog/chaining_dma/altpcierd_tl_cfg_sample.v
               add_fileset_file altpcied_sv_hwtcl.sv               SYSTEMVERILOG PATH ../altera_pcie_hip_ast_ed/altpcied_sv_hwtcl.sv
            }
         } else {
            # Use testbench BFM Gen2 x8
            add_fileset_file altpcietb_bfm_top_rp.v               VERILOG PATH verilog/altpcietb_bfm_top_rp.v
            add_fileset_file altpcietb_bfm_rp_gen2_x8.v           VERILOG PATH verilog/altpcietb_bfm_rp_gen2_x8.v
            if { $apps_type_hwtcl == $set_bfm_driver_to_config_target } {
              add_fileset_file altpcietb_bfm_driver_downstream.v VERILOG PATH verilog/altpcietb_bfm_driver_downstream.v
            } elseif { $apps_type_hwtcl == 4 || $apps_type_hwtcl == 5 } {
              add_fileset_file altpcietb_bfm_driver_avmm.v VERILOG PATH verilog/altpcietb_bfm_driver_avmm.v
            } elseif { $apps_type_hwtcl == $set_bfm_driver_to_config_bypass } {
              add_fileset_file altpcietb_bfm_driver_cfgbp.v VERILOG PATH  ../altera_pcie_hip_ast_ed/altera_pcie_cfgbp_ed/sim_bfm/altpcietb_bfm_driver_cfgbp.v
            } elseif { $apps_type_hwtcl == $set_bfm_driver_to_simple_ep_downstream } {
              add_fileset_file altpcietb_bfm_driver_simple_ep_downstream.v VERILOG PATH  verilog/altpcietb_bfm_driver_simple_ep_downstream.v
            } else {
               add_fileset_file altpcietb_bfm_driver_chaining.v   VERILOG PATH verilog/altpcietb_bfm_driver_chaining.v
            }
         }
      } else {
         add_fileset_file altpcietb_bfm_top_ep.v                      VERILOG PATH verilog/altpcietb_bfm_top_ep.v
         add_fileset_file altpcietb_bfm_ep_example_chaining_pipen1b.v VERILOG PATH verilog/altpcietb_bfm_ep_example_chaining_pipen1b.v
         add_fileset_file altpcietb_bfm_driver_rp.v                   VERILOG PATH verilog/altpcietb_bfm_driver_rp.v
         add_fileset_file altpcietb_bfm_vc_intf_64.v                  VERILOG PATH verilog/altpcietb_bfm_vc_intf_64.v
         add_fileset_file altpcietb_bfm_vc_intf_128.v                 VERILOG PATH verilog/altpcietb_bfm_vc_intf_128.v
      }
   }

#  Adding sim scripts
   add_fileset_file pcie_sim_script/pcie_mti_setup.tcl OTHER PATH verilog/pcie_mti_setup.tcl
}

proc proc_sim_vhdl {name} {

   global env
   set QUARTUS_ROOTDIR $env(QUARTUS_ROOTDIR)

   set port_type_hwtcl             [ get_parameter_value port_type_hwtcl ]
   set lane_mask_hwtcl             [ get_parameter lane_mask_hwtcl ]
   set pll_refclk_freq_hwtcl       [ get_parameter pll_refclk_freq_hwtcl ]
   set gen123_lane_rate_mode_hwtcl [ get_parameter gen123_lane_rate_mode_hwtcl ]
   set apps_type_hwtcl             [ get_parameter_value apps_type_hwtcl ]
   set enable_tl_only_sim_hwtcl    [ get_parameter_value enable_tl_only_sim_hwtcl ]

   set set_bfm_driver_to_config_only            1
   set set_bfm_driver_to_chaining_dma           2
   set set_bfm_driver_to_config_target          3
   set set_bfm_driver_to_config_bypass          10
   set set_bfm_driver_to_simple_ep_downstream   11

   if {1} {
      add_fileset_file mentor/altpcietb_ltssm_mon.v                          VERILOG_ENCRYPT PATH mentor/verilog/altpcietb_ltssm_mon.v                         {MENTOR_SPECIFIC}
      add_fileset_file mentor/altpcietb_pipe_phy.v                           VERILOG_ENCRYPT PATH mentor/verilog/altpcietb_pipe_phy.v                          {MENTOR_SPECIFIC}
      add_fileset_file mentor/altpcietb_pipe32_hip_interface.v               VERILOG_ENCRYPT PATH mentor/verilog/altpcietb_pipe32_hip_interface.v              {MENTOR_SPECIFIC}
      add_fileset_file mentor/altpcietb_pipe32_driver.v                      VERILOG_ENCRYPT PATH mentor/verilog/altpcietb_pipe32_driver.v                     {MENTOR_SPECIFIC}
      add_fileset_file mentor/altpcie_tbed_sv_hwtcl.v                        VERILOG_ENCRYPT PATH mentor/altpcie_tbed_sv_hwtcl.v                               {MENTOR_SPECIFIC}
      add_fileset_file mentor/altpcietb_bfm_log.v                            VERILOG_INCLUDE PATH verilog/altpcietb_bfm_log.v
      add_fileset_file mentor/altpcietb_bfm_configure.v                      VERILOG_INCLUDE PATH verilog/altpcietb_bfm_configure.v
      add_fileset_file mentor/altpcietb_bfm_constants.v                      VERILOG_INCLUDE PATH verilog/altpcietb_bfm_constants.v
      add_fileset_file mentor/altpcietb_bfm_rdwr.v                           VERILOG_INCLUDE PATH verilog/altpcietb_bfm_rdwr.v
      add_fileset_file mentor/altpcietb_bfm_req_intf.v                       VERILOG_INCLUDE PATH verilog/altpcietb_bfm_req_intf.v
      add_fileset_file mentor/altpcietb_bfm_shmem.v                          VERILOG_INCLUDE PATH verilog/altpcietb_bfm_shmem.v


      if { $enable_tl_only_sim_hwtcl == 1 } {
         add_fileset_file mentor/altpcietb_tlbfm_rp_gen3_x8.v               VERILOG_ENCRYPT PATH mentor/verilog/altpcietb_tlbfm_rp_gen3_x8.v                                {MENTOR_SPECIFIC}

         add_fileset_file mentor/altpcietb_tlbfm_rp.v                       VERILOG PATH verilog/altpcietb_tlbfm_rp.v
         add_fileset_file mentor/altpcietb_bfm_driver_chaining.v            VERILOG PATH verilog/altpcietb_bfm_driver_chaining.v
         add_fileset_file mentor/altpcietb_bfm_driver_downstream.v          VERILOG PATH verilog/altpcietb_bfm_driver_downstream.v
         add_fileset_file mentor/altpcietb_bfm_driver_avmm.v                VERILOG PATH verilog/altpcietb_bfm_driver_avmm.v
         add_fileset_file mentor/altpcietb_bfm_log_common.v                 VERILOG PATH verilog/altpcietb_bfm_log_common.v
         add_fileset_file mentor/altpcietb_bfm_req_intf_common.v            VERILOG PATH verilog/altpcietb_bfm_req_intf_common.v
         add_fileset_file mentor/altpcietb_bfm_shmem_common.v               VERILOG PATH verilog/altpcietb_bfm_shmem_common.v
         add_fileset_file mentor/altpcietb_bfm_vc_intf_64.v                 VERILOG PATH verilog/altpcietb_bfm_vc_intf_64.v
         add_fileset_file mentor/altpcietb_rst_clk.v                        VERILOG PATH verilog/altpcietb_rst_clk.v
         } else {
         if { [ regexp endpoint $port_type_hwtcl ] } {
            if { [ regexp Gen3 $gen123_lane_rate_mode_hwtcl ] } {
               # Use testbench BFM Gen3 x8
               add_fileset_file mentor/altpcietb_bfm_top_rp.v                         VERILOG_ENCRYPT PATH mentor/verilog/altpcietb_bfm_top_rp.v                        {MENTOR_SPECIFIC}
               add_fileset_file mentor/altpcietb_bfm_rp_gen3_x8.v                     VERILOG         PATH verilog/altpcietb_bfm_rp_gen3_x8.v
               add_fileset_file mentor/altpcietb_g3bfm_log.v                          VERILOG_INCLUDE PATH verilog/altpcietb_g3bfm_log.v
               add_fileset_file mentor/altpcietb_g3bfm_configure.v                    VERILOG_INCLUDE PATH verilog/altpcietb_g3bfm_configure.v
               add_fileset_file mentor/altpcietb_g3bfm_constants.v                    VERILOG_INCLUDE PATH verilog/altpcietb_g3bfm_constants.v
               add_fileset_file mentor/altpcietb_g3bfm_rdwr.v                         VERILOG_INCLUDE PATH verilog/altpcietb_g3bfm_rdwr.v
               add_fileset_file mentor/altpcietb_g3bfm_req_intf.v                     VERILOG_INCLUDE PATH verilog/altpcietb_g3bfm_req_intf.v
               add_fileset_file mentor/altpcietb_g3bfm_shmem.v                        VERILOG_INCLUDE PATH verilog/altpcietb_g3bfm_shmem.v
               add_fileset_file mentor/altpcietb_g3bfm_vc_intf_ast_common.v           VERILOG_INCLUDE PATH verilog/altpcietb_g3bfm_vc_intf_ast_common.v
               if { $apps_type_hwtcl ==  4 || $apps_type_hwtcl == 5 || $apps_type_hwtcl == 6 }  {
                  add_fileset_file alt_xcvr_reconfig_h.sv             SYSTEMVERILOG PATH ../../alt_xcvr_reconfig/alt_xcvr_reconfig/alt_xcvr_reconfig_h.sv
                  add_fileset_file altpcierd_tl_cfg_sample.v                          VERILOG PATH ../altera_pcie_hip_ast_ed/example_design/verilog/chaining_dma/altpcierd_tl_cfg_sample.v
                  add_fileset_file altpcied_sv_hwtcl.sv                               SYSTEMVERILOG PATH ../altera_pcie_hip_ast_ed/altpcied_sv_hwtcl.sv
               }
            } else {
               # Use testbench BFM Gen2 x8
               add_fileset_file mentor/altpcietb_bfm_top_rp.v                       VERILOG_ENCRYPT PATH mentor/verilog/altpcietb_bfm_top_rp.v                        {MENTOR_SPECIFIC}
               add_fileset_file mentor/altpcietb_bfm_rp_gen2_x8.v                   VERILOG_ENCRYPT PATH mentor/verilog/altpcietb_bfm_rp_gen2_x8.v                    {MENTOR_SPECIFIC}
               if { $apps_type_hwtcl == $set_bfm_driver_to_config_target } {
                 add_fileset_file mentor/altpcietb_bfm_driver_downstream.v          VERILOG PATH verilog/altpcietb_bfm_driver_downstream.v
               } elseif { $apps_type_hwtcl == 4 || $apps_type_hwtcl == 5 } {
                 add_fileset_file mentor/altpcietb_bfm_driver_avmm.v                VERILOG PATH verilog/altpcietb_bfm_driver_avmm.v
               } else {
                 add_fileset_file mentor/altpcietb_bfm_driver_chaining.v            VERILOG PATH verilog/altpcietb_bfm_driver_chaining.v
               }
            }
         } else {
            add_fileset_file mentor/altpcietb_bfm_top_ep.v                      VERILOG_ENCRYPT PATH mentor/verilog/altpcietb_bfm_top_ep.v                        {MENTOR_SPECIFIC}
            add_fileset_file mentor/altpcietb_bfm_ep_example_chaining_pipen1b.v VERILOG_ENCRYPT PATH mentor/verilog/altpcietb_bfm_ep_example_chaining_pipen1b.v   {MENTOR_SPECIFIC}
            add_fileset_file mentor/altpcietb_bfm_driver_rp.v                   VERILOG_ENCRYPT PATH mentor/verilog/altpcietb_bfm_driver_rp.v                     {MENTOR_SPECIFIC}
            add_fileset_file mentor/altpcietb_bfm_vc_intf_64.v                  VERILOG_ENCRYPT PATH verilog/altpcietb_bfm_vc_intf_64.v
            add_fileset_file mentor/altpcietb_bfm_vc_intf_128.v                 VERILOG_ENCRYPT PATH mentor/verilog/altpcietb_bfm_vc_intf_128.v                   {MENTOR_SPECIFIC}
         }
      }
   }


   if {0} {
      add_fileset_file synopsys/altpcietb_ltssm_mon.v                          VERILOG_ENCRYPT PATH synopsys/verilog/altpcietb_ltssm_mon.v                           {SYNOPSYS_SPECIFIC}
      add_fileset_file synopsys/altpcietb_pipe_phy.v                           VERILOG_ENCRYPT PATH synopsys/verilog/altpcietb_pipe_phy.v                            {SYNOPSYS_SPECIFIC}
      add_fileset_file synopsys/altpcietb_pipe32_hip_interface.v               VERILOG_ENCRYPT PATH synopsys/verilog/altpcietb_pipe32_hip_interface.v                {SYNOPSYS_SPECIFIC}
      add_fileset_file synopsys/altpcie_tbed_sv_hwtcl.v                        VERILOG_ENCRYPT PATH synopsys/altpcie_tbed_sv_hwtcl.v                                 {SYNOPSYS_SPECIFIC}
      add_fileset_file synopsys/altpcietb_bfm_log.v                            VERILOG_INCLUDE PATH verilog/altpcietb_bfm_log.v
      add_fileset_file synopsys/altpcietb_bfm_configure.v                      VERILOG_INCLUDE PATH verilog/altpcietb_bfm_configure.v
      add_fileset_file synopsys/altpcietb_bfm_constants.v                      VERILOG_INCLUDE PATH verilog/altpcietb_bfm_constants.v
      add_fileset_file synopsys/altpcietb_bfm_rdwr.v                           VERILOG_INCLUDE PATH verilog/altpcietb_bfm_rdwr.v
      add_fileset_file synopsys/altpcietb_bfm_req_intf.v                       VERILOG_INCLUDE PATH verilog/altpcietb_bfm_req_intf.v
      add_fileset_file synopsys/altpcietb_bfm_shmem.v                          VERILOG_INCLUDE PATH verilog/altpcietb_bfm_shmem.v


      if { $enable_tl_only_sim_hwtcl == 1 } {
         add_fileset_file synopsys/altpcietb_tlbfm_rp_gen3_x8.v                VERILOG_ENCRYPT PATH synopsys/verilog/altpcietb_tlbfm_rp_gen3_x8.v                    {SYNOPSYS_SPECIFIC}

         add_fileset_file synopsys/altpcietb_tlbfm_rp.v                        VERILOG PATH verilog/altpcietb_tlbfm_rp.v
         add_fileset_file synopsys/altpcietb_bfm_driver_chaining.v             VERILOG PATH verilog/altpcietb_bfm_driver_chaining.v
         add_fileset_file synopsys/altpcietb_bfm_driver_downstream.v           VERILOG PATH verilog/altpcietb_bfm_driver_downstream.v
         add_fileset_file synopsys/altpcietb_bfm_driver_avmm.v                 VERILOG PATH verilog/altpcietb_bfm_driver_avmm.v
         add_fileset_file synopsys/altpcietb_bfm_log_common.v                  VERILOG PATH verilog/altpcietb_bfm_log_common.v
         add_fileset_file synopsys/altpcietb_bfm_req_intf_common.v             VERILOG PATH verilog/altpcietb_bfm_req_intf_common.v
         add_fileset_file synopsys/altpcietb_bfm_shmem_common.v                VERILOG PATH verilog/altpcietb_bfm_shmem_common.v
         add_fileset_file synopsys/altpcietb_bfm_vc_intf_64.v                  VERILOG PATH verilog/altpcietb_bfm_vc_intf_64.v
         add_fileset_file synopsys/altpcietb_rst_clk.v                         VERILOG PATH verilog/altpcietb_rst_clk.v
      } else {
         if { [ regexp endpoint $port_type_hwtcl ] } {
            if { [ regexp Gen3 $gen123_lane_rate_mode_hwtcl ] } {
               # Use testbench BFM Gen3 x8
               add_fileset_file synopsys/altpcietb_bfm_top_rp.v                           VERILOG_ENCRYPT PATH synopsys/verilog/altpcietb_bfm_top_rp.v                          {SYNOPSYS_SPECIFIC}
               add_fileset_file synopsys/altpcietb_bfm_rp_gen3_x8.v                       VERILOG         PATH verilog/altpcietb_bfm_rp_gen3_x8.v
               add_fileset_file synopsys/altpcietb_g3bfm_log.v                            VERILOG_INCLUDE PATH verilog/altpcietb_g3bfm_log.v
               add_fileset_file synopsys/altpcietb_g3bfm_configure.v                      VERILOG_INCLUDE PATH verilog/altpcietb_g3bfm_configure.v
               add_fileset_file synopsys/altpcietb_g3bfm_constants.v                      VERILOG_INCLUDE PATH verilog/altpcietb_g3bfm_constants.v
               add_fileset_file synopsys/altpcietb_g3bfm_rdwr.v                           VERILOG_INCLUDE PATH verilog/altpcietb_g3bfm_rdwr.v
               add_fileset_file synopsys/altpcietb_g3bfm_req_intf.v                       VERILOG_INCLUDE PATH verilog/altpcietb_g3bfm_req_intf.v
               add_fileset_file synopsys/altpcietb_g3bfm_shmem.v                          VERILOG_INCLUDE PATH verilog/altpcietb_g3bfm_shmem.v
               add_fileset_file synopsys/altpcietb_g3bfm_vc_intf_ast_common.v             VERILOG_INCLUDE PATH verilog/altpcietb_g3bfm_vc_intf_ast_common.v
               if { $apps_type_hwtcl ==  4 || $apps_type_hwtcl == 5 || $apps_type_hwtcl == 6}  {
                  add_fileset_file alt_xcvr_reconfig_h.sv             SYSTEMVERILOG PATH ../../alt_xcvr_reconfig/alt_xcvr_reconfig/alt_xcvr_reconfig_h.sv
                  add_fileset_file altpcierd_tl_cfg_sample.v                              VERILOG PATH ../altera_pcie_hip_ast_ed/example_design/verilog/chaining_dma/altpcierd_tl_cfg_sample.v
                  add_fileset_file altpcied_sv_hwtcl.sv                                   SYSTEMVERILOG PATH ../altera_pcie_hip_ast_ed/altpcied_sv_hwtcl.sv
               }
            } else {
               # Use testbench BFM Gen2 x8
               add_fileset_file synopsys/altpcietb_bfm_top_rp.v                         VERILOG_ENCRYPT PATH synopsys/verilog/altpcietb_bfm_top_rp.v                          {SYNOPSYS_SPECIFIC}
               add_fileset_file synopsys/altpcietb_bfm_rp_gen2_x8.v                     VERILOG_ENCRYPT PATH synopsys/verilog/altpcietb_bfm_rp_gen2_x8.v                      {SYNOPSYS_SPECIFIC}
               if { $apps_type_hwtcl == 3 } {
                  add_fileset_file synopsys/altpcietb_bfm_driver_downstream.v           VERILOG PATH verilog/altpcietb_bfm_driver_downstream.v
               } elseif { $apps_type_hwtcl == 4 || $apps_type_hwtcl == 5 } {
                  add_fileset_file synopsys/altpcietb_bfm_driver_avmm.v                 VERILOG PATH verilog/altpcietb_bfm_driver_avmm.v
               } else {
                  add_fileset_file synopsys/altpcietb_bfm_driver_chaining.v             VERILOG PATH verilog/altpcietb_bfm_driver_chaining.v
               }
            }
         } else {
            add_fileset_file synopsys/altpcietb_bfm_top_ep.v                      VERILOG_ENCRYPT PATH synopsys/verilog/altpcietb_bfm_top_ep.v                          {SYNOPSYS_SPECIFIC}
            add_fileset_file synopsys/altpcietb_bfm_ep_example_chaining_pipen1b.v VERILOG_ENCRYPT PATH synopsys/verilog/altpcietb_bfm_ep_example_chaining_pipen1b.v     {SYNOPSYS_SPECIFIC}
            add_fileset_file synopsys/altpcietb_bfm_driver_rp.v                   VERILOG_ENCRYPT PATH synopsys/verilog/altpcietb_bfm_driver_rp.v                       {SYNOPSYS_SPECIFIC}
            add_fileset_file synopsys/altpcietb_bfm_vc_intf_64.v                  VERILOG_ENCRYPT PATH verilog/altpcietb_bfm_vc_intf_64.v
            add_fileset_file synopsys/altpcietb_bfm_vc_intf_128.v                 VERILOG_ENCRYPT PATH synopsys/verilog/altpcietb_bfm_vc_intf_128.v                     {SYNOPSYS_SPECIFIC}
         }
      }
   }

   if {0} {
      add_fileset_file cadence/altpcietb_ltssm_mon.v                          VERILOG_ENCRYPT PATH cadence/verilog/altpcietb_ltssm_mon.v                         {CADENCE_SPECIFIC}
      add_fileset_file cadence/altpcietb_pipe_phy.v                           VERILOG_ENCRYPT PATH cadence/verilog/altpcietb_pipe_phy.v                          {CADENCE_SPECIFIC}
      add_fileset_file cadence/altpcietb_pipe32_hip_interface.v               VERILOG_ENCRYPT PATH cadence/verilog/altpcietb_pipe32_hip_interface.v              {CADENCE_SPECIFIC}
      add_fileset_file cadence/altpcietb_pipe32_driver.v                      VERILOG_ENCRYPT PATH cadence/verilog/altpcietb_pipe32_driver.v                     {CADENCE_SPECIFIC}
      add_fileset_file cadence/altpcie_tbed_sv_hwtcl.v                        VERILOG_ENCRYPT PATH cadence/altpcie_tbed_sv_hwtcl.v                               {CADENCE_SPECIFIC}
      add_fileset_file cadence/altpcietb_bfm_log.v                            VERILOG_INCLUDE PATH verilog/altpcietb_bfm_log.v
      add_fileset_file cadence/altpcietb_bfm_configure.v                      VERILOG_INCLUDE PATH verilog/altpcietb_bfm_configure.v
      add_fileset_file cadence/altpcietb_bfm_constants.v                      VERILOG_INCLUDE PATH verilog/altpcietb_bfm_constants.v
      add_fileset_file cadence/altpcietb_bfm_rdwr.v                           VERILOG_INCLUDE PATH verilog/altpcietb_bfm_rdwr.v
      add_fileset_file cadence/altpcietb_bfm_req_intf.v                       VERILOG_INCLUDE PATH verilog/altpcietb_bfm_req_intf.v
      add_fileset_file cadence/altpcietb_bfm_shmem.v                          VERILOG_INCLUDE PATH verilog/altpcietb_bfm_shmem.v


      if { $enable_tl_only_sim_hwtcl == 1 } {
         add_fileset_file cadence/altpcietb_tlbfm_rp_gen3_x8.v                VERILOG_ENCRYPT PATH cadence/verilog/altpcietb_tlbfm_rp_gen3_x8.v                  {CADENCE_SPECIFIC}

         add_fileset_file cadence/altpcietb_tlbfm_rp.v                        VERILOG PATH verilog/altpcietb_tlbfm_rp.v
         add_fileset_file cadence/altpcietb_bfm_driver_chaining.v             VERILOG PATH verilog/altpcietb_bfm_driver_chaining.v
         add_fileset_file cadence/altpcietb_bfm_driver_downstream.v           VERILOG PATH verilog/altpcietb_bfm_driver_downstream.v
         add_fileset_file cadence/altpcietb_bfm_driver_avmm.v                 VERILOG PATH verilog/altpcietb_bfm_driver_avmm.v
         add_fileset_file cadence/altpcietb_bfm_log_common.v                  VERILOG PATH verilog/altpcietb_bfm_log_common.v
         add_fileset_file cadence/altpcietb_bfm_req_intf_common.v             VERILOG PATH verilog/altpcietb_bfm_req_intf_common.v
         add_fileset_file cadence/altpcietb_bfm_shmem_common.v                VERILOG PATH verilog/altpcietb_bfm_shmem_common.v
         add_fileset_file cadence/altpcietb_bfm_vc_intf_64.v                  VERILOG PATH verilog/altpcietb_bfm_vc_intf_64.v
         add_fileset_file cadence/altpcietb_rst_clk.v                         VERILOG PATH verilog/altpcietb_rst_clk.v
      } else {
         if { [ regexp endpoint $port_type_hwtcl ] } {
            if { [ regexp Gen3 $gen123_lane_rate_mode_hwtcl ] } {
               # Use testbench BFM Gen3 x8
               add_fileset_file cadence/altpcietb_bfm_top_rp.v                           VERILOG_ENCRYPT PATH cadence/verilog/altpcietb_bfm_top_rp.v                          {CADENCE_SPECIFIC}
               add_fileset_file cadence/altpcietb_bfm_rp_gen3_x8.v                       VERILOG         PATH verilog/altpcietb_bfm_rp_gen3_x8.v
               add_fileset_file cadence/altpcietb_g3bfm_log.v                            VERILOG_INCLUDE PATH verilog/altpcietb_g3bfm_log.v
               add_fileset_file cadence/altpcietb_g3bfm_configure.v                      VERILOG_INCLUDE PATH verilog/altpcietb_g3bfm_configure.v
               add_fileset_file cadence/altpcietb_g3bfm_constants.v                      VERILOG_INCLUDE PATH verilog/altpcietb_g3bfm_constants.v
               add_fileset_file cadence/altpcietb_g3bfm_rdwr.v                           VERILOG_INCLUDE PATH verilog/altpcietb_g3bfm_rdwr.v
               add_fileset_file cadence/altpcietb_g3bfm_req_intf.v                       VERILOG_INCLUDE PATH verilog/altpcietb_g3bfm_req_intf.v
               add_fileset_file cadence/altpcietb_g3bfm_shmem.v                          VERILOG_INCLUDE PATH verilog/altpcietb_g3bfm_shmem.v
               add_fileset_file cadence/altpcietb_g3bfm_vc_intf_ast_common.v             VERILOG_INCLUDE PATH verilog/altpcietb_g3bfm_vc_intf_ast_common.v
               if { $apps_type_hwtcl ==  4 || $apps_type_hwtcl == 5 || $apps_type_hwtcl == 6 }  {
                  add_fileset_file alt_xcvr_reconfig_h.sv             SYSTEMVERILOG PATH ../../alt_xcvr_reconfig/alt_xcvr_reconfig/alt_xcvr_reconfig_h.sv
                  add_fileset_file altpcierd_tl_cfg_sample.v                             VERILOG PATH ../altera_pcie_hip_ast_ed/example_design/verilog/chaining_dma/altpcierd_tl_cfg_sample.v
                  add_fileset_file altpcied_sv_hwtcl.sv                                  SYSTEMVERILOG PATH ../altera_pcie_hip_ast_ed/altpcied_sv_hwtcl.sv
               }
            } else {
               # Use testbench BFM Gen2 x8
               add_fileset_file cadence/altpcietb_bfm_top_rp.v                         VERILOG_ENCRYPT PATH cadence/verilog/altpcietb_bfm_top_rp.v                          {CADENCE_SPECIFIC}
               add_fileset_file cadence/altpcietb_bfm_rp_gen2_x8.v                     VERILOG_ENCRYPT PATH cadence/verilog/altpcietb_bfm_rp_gen2_x8.v                      {CADENCE_SPECIFIC}
               if { $apps_type_hwtcl == 3 } {
                  add_fileset_file cadence/altpcietb_bfm_driver_downstream.v           VERILOG PATH verilog/altpcietb_bfm_driver_downstream.v
               } elseif { $apps_type_hwtcl == 4 || $apps_type_hwtcl == 5 } {
                  add_fileset_file cadence/altpcietb_bfm_driver_avmm.v                 VERILOG PATH verilog/altpcietb_bfm_driver_avmm.v
               } else {
                  add_fileset_file cadence/altpcietb_bfm_driver_chaining.v             VERILOG PATH verilog/altpcietb_bfm_driver_chaining.v
               }
            }
         } else {
            add_fileset_file cadence/altpcietb_bfm_top_ep.v                      VERILOG_ENCRYPT PATH cadence/verilog/altpcietb_bfm_top_ep.v                          {CADENCE_SPECIFIC}
            add_fileset_file cadence/altpcietb_bfm_ep_example_chaining_pipen1b.v VERILOG_ENCRYPT PATH cadence/verilog/altpcietb_bfm_ep_example_chaining_pipen1b.v     {CADENCE_SPECIFIC}
            add_fileset_file cadence/altpcietb_bfm_driver_rp.v                   VERILOG_ENCRYPT PATH cadence/verilog/altpcietb_bfm_driver_rp.v                       {CADENCE_SPECIFIC}
            add_fileset_file cadence/altpcietb_bfm_vc_intf_64.v                  VERILOG_ENCRYPT PATH verilog/altpcietb_bfm_vc_intf_64.v
            add_fileset_file cadence/altpcietb_bfm_vc_intf_128.v                 VERILOG_ENCRYPT PATH cadence/verilog/altpcietb_bfm_vc_intf_128.v                     {CADENCE_SPECIFIC}
         }
      }

   }

    if {1} {
      add_fileset_file aldec/altpcietb_ltssm_mon.v                            VERILOG_ENCRYPT PATH aldec/verilog/altpcietb_ltssm_mon.v                         {ALDEC_SPECIFIC}
      add_fileset_file aldec/altpcietb_pipe_phy.v                             VERILOG_ENCRYPT PATH aldec/verilog/altpcietb_pipe_phy.v                          {ALDEC_SPECIFIC}
      add_fileset_file aldec/altpcietb_pipe32_hip_interface.v                 VERILOG_ENCRYPT PATH aldec/verilog/altpcietb_pipe32_hip_interface.v              {ALDEC_SPECIFIC}
      add_fileset_file aldec/altpcietb_pipe32_driver.v                        VERILOG_ENCRYPT PATH aldec/verilog/altpcietb_pipe32_driver.v                     {ALDEC_SPECIFIC}
      add_fileset_file aldec/altpcie_tbed_sv_hwtcl.v                          VERILOG_ENCRYPT PATH aldec/altpcie_tbed_sv_hwtcl.v                               {ALDEC_SPECIFIC}
      add_fileset_file aldec/altpcietb_bfm_log.v                              VERILOG_INCLUDE PATH verilog/altpcietb_bfm_log.v
      add_fileset_file aldec/altpcietb_bfm_configure.v                        VERILOG_INCLUDE PATH verilog/altpcietb_bfm_configure.v
      add_fileset_file aldec/altpcietb_bfm_constants.v                        VERILOG_INCLUDE PATH verilog/altpcietb_bfm_constants.v
      add_fileset_file aldec/altpcietb_bfm_rdwr.v                             VERILOG_INCLUDE PATH verilog/altpcietb_bfm_rdwr.v
      add_fileset_file aldec/altpcietb_bfm_req_intf.v                         VERILOG_INCLUDE PATH verilog/altpcietb_bfm_req_intf.v
      add_fileset_file aldec/altpcietb_bfm_shmem.v                            VERILOG_INCLUDE PATH verilog/altpcietb_bfm_shmem.v


      if { $enable_tl_only_sim_hwtcl == 1 } {
         add_fileset_file aldec/altpcietb_tlbfm_rp_gen3_x8.v                  VERILOG_ENCRYPT PATH aldec/verilog/altpcietb_tlbfm_rp_gen3_x8.v                  {ALDEC_SPECIFIC}

         add_fileset_file aldec/altpcietb_tlbfm_rp.v                          VERILOG PATH verilog/altpcietb_tlbfm_rp.v
         add_fileset_file aldec/altpcietb_bfm_driver_chaining.v               VERILOG PATH verilog/altpcietb_bfm_driver_chaining.v
         add_fileset_file aldec/altpcietb_bfm_driver_downstream.v             VERILOG PATH verilog/altpcietb_bfm_driver_downstream.v
         add_fileset_file aldec/altpcietb_bfm_driver_avmm.v                   VERILOG PATH verilog/altpcietb_bfm_driver_avmm.v
         add_fileset_file aldec/altpcietb_bfm_log_common.v                    VERILOG PATH verilog/altpcietb_bfm_log_common.v
         add_fileset_file aldec/altpcietb_bfm_req_intf_common.v               VERILOG PATH verilog/altpcietb_bfm_req_intf_common.v
         add_fileset_file aldec/altpcietb_bfm_shmem_common.v                  VERILOG PATH verilog/altpcietb_bfm_shmem_common.v
         add_fileset_file aldec/altpcietb_bfm_vc_intf_64.v                    VERILOG PATH verilog/altpcietb_bfm_vc_intf_64.v
         add_fileset_file aldec/altpcietb_rst_clk.v                           VERILOG PATH verilog/altpcietb_rst_clk.v
      } else {
         if { [ regexp endpoint $port_type_hwtcl ] } {
            if { [ regexp Gen3 $gen123_lane_rate_mode_hwtcl ] } {
               # Use testbench BFM Gen3 x8
               add_fileset_file aldec/altpcietb_bfm_top_rp.v                         VERILOG_ENCRYPT PATH aldec/verilog/altpcietb_bfm_top_rp.v                          {ALDEC_SPECIFIC}
               add_fileset_file aldec/altpcietb_bfm_rp_gen3_x8.v                     VERILOG         PATH verilog/altpcietb_bfm_rp_gen3_x8.v
               add_fileset_file aldec/altpcietb_g3bfm_log.v                          VERILOG_INCLUDE PATH verilog/altpcietb_g3bfm_log.v
               add_fileset_file aldec/altpcietb_g3bfm_configure.v                    VERILOG_INCLUDE PATH verilog/altpcietb_g3bfm_configure.v
               add_fileset_file aldec/altpcietb_g3bfm_constants.v                    VERILOG_INCLUDE PATH verilog/altpcietb_g3bfm_constants.v
               add_fileset_file aldec/altpcietb_g3bfm_rdwr.v                         VERILOG_INCLUDE PATH verilog/altpcietb_g3bfm_rdwr.v
               add_fileset_file aldec/altpcietb_g3bfm_req_intf.v                     VERILOG_INCLUDE PATH verilog/altpcietb_g3bfm_req_intf.v
               add_fileset_file aldec/altpcietb_g3bfm_shmem.v                        VERILOG_INCLUDE PATH verilog/altpcietb_g3bfm_shmem.v
               add_fileset_file aldec/altpcietb_g3bfm_vc_intf_ast_common.v           VERILOG_INCLUDE PATH verilog/altpcietb_g3bfm_vc_intf_ast_common.v
               if { $apps_type_hwtcl ==  4 || $apps_type_hwtcl == 5 || $apps_type_hwtcl == 6 }  {
                  add_fileset_file alt_xcvr_reconfig_h.sv             SYSTEMVERILOG PATH ../../alt_xcvr_reconfig/alt_xcvr_reconfig/alt_xcvr_reconfig_h.sv
                  add_fileset_file altpcierd_tl_cfg_sample.v                         VERILOG PATH ../altera_pcie_hip_ast_ed/example_design/verilog/chaining_dma/altpcierd_tl_cfg_sample.v
                  add_fileset_file altpcied_sv_hwtcl.sv                              SYSTEMVERILOG PATH ../altera_pcie_hip_ast_ed/altpcied_sv_hwtcl.sv
               }
            } else {
               # Use testbench BFM Gen2 x8
               add_fileset_file aldec/altpcietb_bfm_top_rp.v                         VERILOG_ENCRYPT PATH aldec/verilog/altpcietb_bfm_top_rp.v                          {ALDEC_SPECIFIC}
               add_fileset_file aldec/altpcietb_bfm_rp_gen2_x8.v                     VERILOG_ENCRYPT PATH aldec/verilog/altpcietb_bfm_rp_gen2_x8.v                      {ALDEC_SPECIFIC}
               if { $apps_type_hwtcl == 3 } {
                  add_fileset_file aldec/altpcietb_bfm_driver_downstream.v           VERILOG PATH verilog/altpcietb_bfm_driver_downstream.v
               } elseif { $apps_type_hwtcl == 4 || $apps_type_hwtcl == 5 } {
                  add_fileset_file aldec/altpcietb_bfm_driver_avmm.v                 VERILOG PATH verilog/altpcietb_bfm_driver_avmm.v
               } else {
                  add_fileset_file aldec/altpcietb_bfm_driver_chaining.v             VERILOG PATH verilog/altpcietb_bfm_driver_chaining.v
               }
            }
         } else {
            add_fileset_file aldec/altpcietb_bfm_top_ep.v                      VERILOG_ENCRYPT PATH aldec/verilog/altpcietb_bfm_top_ep.v                          {ALDEC_SPECIFIC}
            add_fileset_file aldec/altpcietb_bfm_ep_example_chaining_pipen1b.v VERILOG_ENCRYPT PATH aldec/verilog/altpcietb_bfm_ep_example_chaining_pipen1b.v     {ALDEC_SPECIFIC}
            add_fileset_file aldec/altpcietb_bfm_driver_rp.v                   VERILOG_ENCRYPT PATH aldec/verilog/altpcietb_bfm_driver_rp.v                       {ALDEC_SPECIFIC}
            add_fileset_file aldec/altpcietb_bfm_vc_intf_64.v                  VERILOG_ENCRYPT PATH verilog/altpcietb_bfm_vc_intf_64.v
            add_fileset_file aldec/altpcietb_bfm_vc_intf_128.v                 VERILOG_ENCRYPT PATH aldec/verilog/altpcietb_bfm_vc_intf_128.v                     {ALDEC_SPECIFIC}
         }
      }

   }

   #  Adding sim scripts
#  add_fileset_file pcie_sim_script/pcie_mti_setup.tcl OTHER PATH verilog/pcie_mti_setup.tcl
#  add_fileset_file pcie_sim_script/pcie_vcs_setup.sh  OTHER PATH verilog/pcie_vcs_setup.sh
#  add_fileset_file pcie_sim_script/pcie_ncsim_setup.sh OTHER PATH verilog/pcie_ncsim_setup.sh


}
