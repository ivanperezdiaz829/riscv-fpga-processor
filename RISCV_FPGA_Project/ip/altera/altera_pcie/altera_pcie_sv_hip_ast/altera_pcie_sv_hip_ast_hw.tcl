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
source pcie_sv_parameters.tcl
source pcie_sv_port.tcl

global env
set QUARTUS_ROOTDIR $env(QUARTUS_ROOTDIR)

source ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie_pipe/xcvr_generic/altera_xcvr_pipe_common.tcl

pipe_decl_fileset_groups_sv_xcvr_pipe_native ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie_pipe/xcvr_generic

# +-----------------------------------
# | module PCI Express
# |
set_module_property NAME altera_pcie_sv_hip_ast
set_module_property DESCRIPTION "Stratix V Hard IP for PCI Express"
set_module_property VERSION 13.1
set_module_property DATASHEET_URL "http://www.altera.com/literature/ug/ug_s5_pcie.pdf"
set_module_property GROUP "Interface Protocols/PCI"
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "Stratix V Hard IP for PCI Express"
set_module_property HIDE_FROM_SOPC true
set_module_property INTERNAL false
set_module_property EDITABLE false
set_module_property ANALYZE_HDL FALSE
set_module_property ELABORATION_CALLBACK elaboration_callback
set_module_property instantiateInSystemModule "true"

# # +-----------------------------------
# # | Global parameters
#   |
add_parameter design_environment_hwtcl String "NATIVE"
set_parameter_property design_environment_hwtcl SYSTEM_INFO DESIGN_ENVIRONMENT
set_parameter_property design_environment_hwtcl HDL_PARAMETER false
set_parameter_property design_environment_hwtcl VISIBLE FALSE

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
set_fileset_property synth TOP_LEVEL altpcie_sv_hip_ast_hwtcl

# # +-----------------------------------
# # | SIM_ design files
#   |
add_fileset sim_vhdl SIM_VHDL proc_sim_vhdl
set_fileset_property sim_vhdl TOP_LEVEL altpcie_sv_hip_ast_hwtcl

add_fileset sim_verilog SIM_VERILOG proc_sim_verilog
set_fileset_property sim_verilog TOP_LEVEL altpcie_sv_hip_ast_hwtcl

# # +-----------------------------------
# # | Example QSYS Design
#   |
add_fileset example_design {EXAMPLE_DESIGN} example_design_proc

# # | TODO parse project property to enable use of VHDL design vs VERILOG design
# #send_message info "hw.tcl dir is [get_module_property MODULE_DIRECTORY]"
# #source ./sv_xcvr_pipe_common.tcl
#
# # +-----------------------------------
# # | elaboration items
# # |
proc elaboration_callback { } {
   validation_parameter_system_setting
   validation_parameter_bar
   validation_parameter_base_limit_reg
   validation_parameter_pcie_cap_reg
   update_default_value_hidden_parameter_common

   # Port updates
   add_pcie_hip_port_ast_rx
   add_pcie_hip_port_ast_tx
   add_pcie_hip_port_clk
   add_pcie_hip_port_rst
   add_pcie_hip_port_reconfig
   add_pcie_hip_port_serial
   add_pcie_hip_port_pipe
   add_pcie_hip_port_interrupt
   add_pcie_hip_port_hip_reconfig
   add_pcie_hip_port_config_bypass
   add_pcie_hip_port_cseb
   add_pcie_hip_port_control
   add_pcie_hip_port_status


   # Parameter updates
   set_pcie_hip_flow_control_settings_common
   set_pcie_cvp_parameters_common
   set_module_assignment testbench.partner.pcie_tb.parameter.lane_mask_hwtcl                       [get_parameter lane_mask_hwtcl]
   set_module_assignment testbench.partner.pcie_tb.parameter.pll_refclk_freq_hwtcl                 [get_parameter pll_refclk_freq_hwtcl]
   set_module_assignment testbench.partner.pcie_tb.parameter.port_type_hwtcl                       [get_parameter port_type_hwtcl]
   set_module_assignment testbench.partner.pcie_tb.parameter.gen123_lane_rate_mode_hwtcl           [get_parameter gen123_lane_rate_mode_hwtcl]
   set_module_assignment testbench.partner.pcie_tb.parameter.serial_sim_hwtcl                      [get_parameter serial_sim_hwtcl ]
   set_module_assignment testbench.partner.pcie_tb.parameter.enable_pipe32_sim_hwtcl               [get_parameter enable_pipe32_sim_hwtcl ]
   set_module_assignment testbench.partner.pcie_tb.parameter.enable_pipe32_phyip_ser_driver_hwtcl  [get_parameter enable_pipe32_phyip_ser_driver_hwtcl ]
   set_module_assignment testbench.partner.pcie_tb.parameter.enable_tl_only_sim_hwtcl              [get_parameter enable_tl_only_sim_hwtcl ]
   set_module_assignment testbench.partner.pcie_tb.parameter.deemphasis_enable_hwtcl               [get_parameter deemphasis_enable_hwtcl ]
   set_module_assignment testbench.partner.pcie_tb.parameter.pld_clk_MHz                           [get_parameter pld_clk_MHz ]
   set_module_assignment testbench.partner.pcie_tb.parameter.millisecond_cycle_count_hwtcl         [get_parameter millisecond_cycle_count_hwtcl ]
   set_module_assignment testbench.partner.pcie_tb.parameter.use_crc_forwarding_hwtcl              [get_parameter use_crc_forwarding_hwtcl ]
   set_module_assignment testbench.partner.pcie_tb.parameter.ecrc_check_capable_hwtcl              [get_parameter ecrc_check_capable_hwtcl ]
   set_module_assignment testbench.partner.pcie_tb.parameter.ecrc_gen_capable_hwtcl                [get_parameter ecrc_gen_capable_hwtcl ]


   set vendor_id_hwtcl         [get_parameter_value vendor_id_hwtcl ]
   set device_id_hwtcl         [get_parameter_value device_id_hwtcl ]
   set ast_width_hwtcl         [get_parameter_value ast_width_hwtcl ]
   set use_config_bypass_hwtcl [get_parameter_value use_config_bypass_hwtcl ]
   set override_tbpartner_driver_setting_hwtcl [get_parameter_value override_tbpartner_driver_setting_hwtcl ]
   set set_bfm_driver_to_config_only   1
   set set_bfm_driver_to_chaining_dma  2
   set set_bfm_driver_to_config_target 3
   set set_bfm_driver_to_config_bypass 10
   set set_bfm_driver_to_simple_ep_downstream 11

   # Setting testbench driver
   # If Vendor ID == 0x1172 && Device ID == 0xE001 --> assign driver to DMA or target
   # else  assign driver to training & configuration only
   # set_parameter_property apps_type_hwtcl ALLOWED_RANGES {"1:Link training and configuration" "2:Link training, configuration and chaining DMA" "3:Link training, configuration and target"}
   if { $override_tbpartner_driver_setting_hwtcl>0 } {
     set_module_assignment testbench.partner.pcie_tb.parameter.apps_type_hwtcl  $override_tbpartner_driver_setting_hwtcl
   } elseif { $vendor_id_hwtcl == 4466 && $device_id_hwtcl == 57345 } {
      if { [ regexp 1 $use_config_bypass_hwtcl ] } {
        set_module_assignment testbench.partner.pcie_tb.parameter.apps_type_hwtcl $set_bfm_driver_to_config_bypass
        send_message info "When using VendorID:0x1172 and DeviceID:0xE001 the generated testbench driver will run a simulation which includes link training, configuration and target"
      } else {
         if { [ regexp 256 $ast_width_hwtcl ] } {
           set_module_assignment testbench.partner.pcie_tb.parameter.apps_type_hwtcl $set_bfm_driver_to_config_target
           send_message info "When using VendorID:0x1172 and DeviceID:0xE001 the generated testbench driver will run a simulation which includes link training, configuration and target"
         } else {
           set_module_assignment testbench.partner.pcie_tb.parameter.apps_type_hwtcl $set_bfm_driver_to_chaining_dma
           send_message info "When using VendorID:0x1172 and DeviceID:0xE001 the generated testbench driver will run a simulation which includes link training, configuration and chaining DMA"
         }
      }
   } else {
     set_module_assignment testbench.partner.pcie_tb.parameter.apps_type_hwtcl  $set_bfm_driver_to_config_only
   }

}

# +-----------------------------------
# | parameters
# |
add_pcie_hip_parameters_ui_system_settings
add_pcie_hip_parameters_ui_pci_registers
add_pcie_hip_parameters_ui_pcie_cap_registers
add_pcie_hip_hidden_rtl_parameters
add_pcie_hip_common_hidden_rtl_parameters
add_pcie_hip_gen2_vod
add_pcie_hip_parameters_gen3_coef
add_pcie_hip_parameters_phy_characteristics

# +-----------------------------------
# | Static IO
# |
add_interface no_connect conduit end
add_pcie_hip_port_npor
add_pcie_hip_port_lmi
add_pcie_hip_port_tl_cfg
add_pcie_hip_port_pw_mngt

# ************** Global Variables ***************
set not_init "default"
# **************** Parameters *******************


proc proc_quartus_synth {name} {

   set pld_clk_MHz                                    [ get_parameter_value pld_clk_MHz ]
   set design_environment_hwtcl                       [ get_parameter_value design_environment_hwtcl ]

   add_fileset_file altpcie_sv_hip_ast_hwtcl.v        VERILOG PATH altpcie_sv_hip_ast_hwtcl.v
   add_fileset_file altpcie_hip_256_pipen1b.v         VERILOG PATH altpcie_hip_256_pipen1b.v
   add_fileset_file altpcie_rs_serdes.v               VERILOG PATH altpcie_rs_serdes.v
   add_fileset_file altpcie_rs_hip.v                  VERILOG PATH altpcie_rs_hip.v

   common_add_fileset_files { S5 ALL_HDL } { PLAIN }

   if { $design_environment_hwtcl=="NATIVE" } {
      add_fileset_file alt_xcvr_reconfig_h.sv            SYSTEMVERILOG PATH ../../alt_xcvr_reconfig/alt_xcvr_reconfig/alt_xcvr_reconfig_h.sv
      add_fileset_file altpcie_reconfig_driver.sv        SYSTEMVERILOG PATH ../altera_pcie_hip_ast_ed/altpcie_reconfig_driver.sv
   }
}

proc proc_sim_vhdl {name} {
   set design_environment_hwtcl                       [ get_parameter_value design_environment_hwtcl ]

   set verilog_file {"altpcie_sv_hip_ast_hwtcl.v" "altpcie_hip_256_pipen1b.v" "altpcie_rs_serdes.v" "altpcie_rs_hip.v" }
   foreach vf $verilog_file {
      # Co-simulation clear text verilog files
      if {1} {
         add_fileset_file aldec/${vf} VERILOG_ENCRYPT PATH "aldec/${vf}" {ALDEC_SPECIFIC}
      }
      if {1} {
         add_fileset_file mentor/${vf} VERILOG_ENCRYPT PATH "mentor/${vf}" {MENTOR_SPECIFIC}
      }
      if {0} {
         add_fileset_file synopsys/${vf} VERILOG_ENCRYPT PATH "synopsys/${vf}" {SYNOPSYS_SPECIFIC}
      }
      if {0} {
         add_fileset_file cadence/${vf} VERILOG_ENCRYPT PATH "cadence/${vf}" {CADENCE_SPECIFIC}
      }
   }
   common_add_fileset_files { S5 ALL_HDL } { PLAIN MENTOR  }

   if { $design_environment_hwtcl=="NATIVE" } {
      if {1} {
         add_fileset_file mentor/alt_xcvr_reconfig_h.sv            SYSTEMVERILOG PATH ../../alt_xcvr_reconfig/alt_xcvr_reconfig/mentor/alt_xcvr_reconfig_h.sv     MENTOR_SPECIFIC
         add_fileset_file mentor/altpcie_reconfig_driver.sv        SYSTEMVERILOG PATH ../altera_pcie_hip_ast_ed/mentor/altpcie_reconfig_driver.sv                 MENTOR_SPECIFIC
      }
         add_fileset_file synopsys/alt_xcvr_reconfig_h.sv          SYSTEMVERILOG PATH ../../alt_xcvr_reconfig/alt_xcvr_reconfig/alt_xcvr_reconfig_h.sv            SYNOPSYS_SPECIFIC
         add_fileset_file synopsys/altpcie_reconfig_driver.sv      SYSTEMVERILOG PATH ../altera_pcie_hip_ast_ed/altpcie_reconfig_driver.sv                        SYNOPSYS_SPECIFIC
         add_fileset_file cadence/alt_xcvr_reconfig_h.sv           SYSTEMVERILOG PATH ../../alt_xcvr_reconfig/alt_xcvr_reconfig/alt_xcvr_reconfig_h.sv            CADENCE_SPECIFIC
         add_fileset_file cadence/altpcie_reconfig_driver.sv       SYSTEMVERILOG PATH ../altera_pcie_hip_ast_ed/altpcie_reconfig_driver.sv                        CADENCE_SPECIFIC
         add_fileset_file aldec/alt_xcvr_reconfig_h.sv             SYSTEMVERILOG PATH ../../alt_xcvr_reconfig/alt_xcvr_reconfig/alt_xcvr_reconfig_h.sv            ALDEC_SPECIFIC
         add_fileset_file aldec/altpcie_reconfig_driver.sv         SYSTEMVERILOG PATH ../altera_pcie_hip_ast_ed/altpcie_reconfig_driver.sv                        ALDEC_SPECIFIC
   }
}

proc proc_sim_verilog {name} {
   set design_environment_hwtcl                       [ get_parameter_value design_environment_hwtcl ]

   add_fileset_file altpcie_sv_hip_ast_hwtcl.v   VERILOG PATH altpcie_sv_hip_ast_hwtcl.v
   add_fileset_file altpcie_hip_256_pipen1b.v    VERILOG PATH altpcie_hip_256_pipen1b.v
   add_fileset_file altpcie_rs_serdes.v          VERILOG PATH altpcie_rs_serdes.v
   add_fileset_file altpcie_rs_hip.v             VERILOG PATH altpcie_rs_hip.v
   common_add_fileset_files { S5 ALL_HDL } { PLAIN }
   if { $design_environment_hwtcl=="NATIVE" } {
      add_fileset_file alt_xcvr_reconfig_h.sv            SYSTEMVERILOG PATH ../../alt_xcvr_reconfig/alt_xcvr_reconfig/alt_xcvr_reconfig_h.sv
      add_fileset_file altpcie_reconfig_driver.sv        SYSTEMVERILOG PATH ../altera_pcie_hip_ast_ed/altpcie_reconfig_driver.sv
   }
}


proc example_design_proc { outputName } {

   global env
   set QUARTUS_ROOTDIR $env(QUARTUS_ROOTDIR)
   set ast_width_hwtcl [ get_parameter_value ast_width_hwtcl ]
   set port_type_hwtcl [ get_parameter_value port_type_hwtcl ]
   set gen123_lane_rate_mode_hwtcl [ get_parameter_value gen123_lane_rate_mode_hwtcl ]
#  set tmpdir          [ add_fileset_file {} OTHER TEMP {} ]
#  set CurrentDir      [pwd]
   set qsysprj       "pcie_de_gen1_x4_ast64"

   if { [ regexp endpoint $port_type_hwtcl ] } {
      #Add EP Design example
      if { [ regexp 256 $ast_width_hwtcl ] } {
         if { [ regexp Gen3 $gen123_lane_rate_mode_hwtcl ] } {
            set qsysprj  "pcie_de_gen3_x8_ast256"
            add_fileset_file pcie_de_gen3_x8_ast256.qsys OTHER PATH ../altera_pcie_hip_ast_ed/example_design/sv/pcie_de_gen3_x8_ast256.qsys
         } else {
            set qsysprj  "pcie_de_gen2_x8_ast256"
            add_fileset_file pcie_de_gen2_x8_ast256.qsys OTHER PATH ../altera_pcie_hip_ast_ed/example_design/sv/pcie_de_gen2_x8_ast256.qsys
         }
      } elseif { [ regexp 128 $ast_width_hwtcl ] } {
         if { [ regexp Gen3 $gen123_lane_rate_mode_hwtcl ] } {
            set qsysprj  "pcie_de_gen3_x4_ast128"
            add_fileset_file pcie_de_gen3_x4_ast128.qsys OTHER PATH ../altera_pcie_hip_ast_ed/example_design/sv/pcie_de_gen3_x4_ast128.qsys
         } else {
            set qsysprj  "pcie_de_gen1_x8_ast128"
            add_fileset_file pcie_de_gen1_x8_ast128.qsys OTHER PATH ../altera_pcie_hip_ast_ed/example_design/sv/pcie_de_gen1_x8_ast128.qsys
         }
      } else {
          if { [ regexp Gen3 $gen123_lane_rate_mode_hwtcl ] } {
            set qsysprj  "pcie_de_gen3_x1_ast64"
            add_fileset_file pcie_de_gen3_x1_ast64.qsys OTHER PATH ../altera_pcie_hip_ast_ed/example_design/sv/pcie_de_gen3_x1_ast64.qsys
         } else {
            set qsysprj  "pcie_de_gen1_x4_ast64"
            add_fileset_file pcie_de_gen1_x4_ast64.qsys OTHER PATH ../altera_pcie_hip_ast_ed/example_design/sv/pcie_de_gen1_x4_ast64.qsys
         }
      }
   } else {
      #Add RP Design example
      if { [ regexp 128 $ast_width_hwtcl ] } {
         set qsysprj  "pcie_de_rp_gen1_x8_ast128"
         add_fileset_file pcie_de_rp_gen1_x8_ast128.qsys OTHER PATH ../altera_pcie_hip_ast_ed/example_design/sv/pcie_de_rp_gen1_x8_ast128.qsys
      } else {
         set qsysprj  "pcie_de_rp_gen1_x4_ast64"
         add_fileset_file pcie_de_rp_gen1_x4_ast64.qsys OTHER PATH ../altera_pcie_hip_ast_ed/example_design/sv/pcie_de_rp_gen1_x4_ast64.qsys
      }
   }

   add_fileset_file altpcied_qii.tcl OTHER PATH ../altera_pcie_hip_ast_ed/example_design/altpcied_qii.tcl

#   if { [catch {cd $tmpdir} ] } {
#      send_message info "Unable to generate design example"
#   } else {
#
#      set qsysfile        ${qsysprj}.qsys
#      set qsysfiledir     ${tmpdir}${qsysfile}
#      set qsyslib         pcielib
#
#      file copy ${CurrentDir}/../altera_pcie_hip_ast_ed/example_design/sv/${qsysfile} ${tmpdir}${qsysfile}
#      file copy ${CurrentDir}/../altera_pcie_hip_ast_ed/example_design/altpcied_qii.tcl ${tmpdir}altpcied_qii.tcl
#
#      # Quartus II project generation
#      set ipgenerate ${QUARTUS_ROOTDIR}/sopc_builder/bin/ip-generate
#      send_message info "${ipgenerate} --component-file=${qsysfile}  --submodule-naming-pattern=%o --output-directory=pcie_lib --file-set=QUARTUS_SYNTH --report-file=qip:${qsysprj}.qip --report-file=sopcinfo:${qsysprj}.sopcinfo --report-file=html:${qsysprj}.html "
#      set exec_list "exec ${ipgenerate} --component-file=${qsysfile} --submodule-naming-pattern=%o --output-directory=pcie_lib --file-set=QUARTUS_SYNTH --report-file=qip:${qsysprj}.qip --report-file=sopcinfo:${qsysprj}.sopcinfo --report-file=html:${qsysprj}.html "
#      safe_exe $exec_list
#
#      #set exec_list "exec ls"
#      #safe_exe $exec_list
#
#      #set exec_list "exec pwd"
#      #safe_exe $exec_list
#
#      #set exec_list "exec ls pcie_lib"
#      #safe_exe $exec_list
#
#      set files [glob -nocomplain pcie_lib/*.v]
#      set sf [ array size $files ]
#      if { $sf > 0 } {
#         foreach f $files {
#            add_fileset_file ${f} VERILOG PATH ${tmpdir}${f}
#         }
#      } else {
#         send_message info " Unable to locate pcie_lib/*v"
#      }
#
#      set files [glob -nocomplain pcie_lib/*.sv]
#      set sf [ array size $files ]
#      if { $sf > 0 } {
#         foreach f $files {
#            add_fileset_file ${f} SYSTEM_VERILOG PATH ${tmpdir}${f}
#         }
#      } else {
#         send_message info " Unable to locate pcie_lib/*.sv"
#      }
#
#      set exec_list "exec quartus_sh -t altpcied_qii.tcl ${qsysprj}"
#      safe_exe $exec_list
#
#      set files [glob ${qsysprj}.*]
#      foreach f $files {
#         if { ! [ regexp qsys $f ] } {
#            add_fileset_file ${f} OTHER PATH ${tmpdir}${f}
#         }
#      }
#
#      # Return to current dir
#      catch {cd $CurrentDir}
#   }
}

proc safe_exe {exec_list} {
    if {[catch {set gen_output [ eval $exec_list ]} errmsg]} {
        puts $errmsg
        send_message info "Failed: $exec_list"
    } else {
        puts $gen_output
    }
}
