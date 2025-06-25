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


package require -exact qsys 13.0
sopc::preview_add_transform name preview_avalon_mm_transform

global env
set QUARTUS_ROOTDIR $env(QUARTUS_ROOTDIR)
set MAX_FUNC 8

source ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_av_hip_ast/pcie_av_parameters.tcl
source ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_av_hip_ast/pcie_av_port.tcl
source ${QUARTUS_ROOTDIR}/../ip/altera/altera_xcvr_generic/alt_xcvr_common.tcl
source ${QUARTUS_ROOTDIR}/../ip/altera/altera_xcvr_generic/av/av_xcvr_native_fileset.tcl
source ${QUARTUS_ROOTDIR}/../ip/altera/altera_xcvr_generic/ctrl/alt_xcvr_csr_fileset.tcl
source ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie_pipe/av/av_xcvr_pipe_common.tcl
pipe_decl_fileset_groups_top ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie_pipe/xcvr_generic


# +-----------------------------------
# | module PCI Express
# |
set_module_property NAME altera_pcie_cv_hip_ast
set_module_property DESCRIPTION "Cyclone V Hard IP for PCI Express"
set_module_property VERSION 13.1
set_module_property DATASHEET_URL "http://www.altera.com/literature/ug/ug_c5_pcie.pdf"
set_module_property GROUP "Interface Protocols/PCI"
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "Cyclone V Hard IP for PCI Express"
set_module_property HIDE_FROM_SOPC true
set_module_property INTERNAL false
set_module_property EDITABLE false
set_module_property ANALYZE_HDL FALSE
set_module_property ELABORATION_CALLBACK elaboration_callback
set_module_property instantiateInSystemModule "true"

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
set_module_assignment testbench.partner.pcie_tb.parameter.serial_sim_hwtcl  0


# # +-----------------------------------
# # | QUARTUS_SYNTH design RTL files
#   |
add_fileset synth QUARTUS_SYNTH proc_quartus_synth
set_fileset_property synth TOP_LEVEL altpcie_cv_hip_ast_hwtcl

# # +-----------------------------------
# # | SIM_ design files
#   |
add_fileset sim_vhdl SIM_VHDL proc_sim_vhdl
set_fileset_property sim_vhdl TOP_LEVEL altpcie_cv_hip_ast_hwtcl

add_fileset sim_verilog SIM_VERILOG proc_sim_verilog
set_fileset_property sim_verilog TOP_LEVEL altpcie_cv_hip_ast_hwtcl

# # +-----------------------------------
# # | Example QSYS Design
#   |
add_fileset example_design {EXAMPLE_DESIGN} example_design_proc

# # +-----------------------------------
# # | elaboration items
# # |
proc elaboration_callback {} {

   global MAX_FUNC
   update_param_validation_settings ${MAX_FUNC}
}

# +-----------------------------------
# | parameters
# |
add_parameter INTENDED_DEVICE_FAMILY String "CYCLONE V"
set_parameter_property INTENDED_DEVICE_FAMILY SYSTEM_INFO DEVICE_FAMILY
set_parameter_property INTENDED_DEVICE_FAMILY VISIBLE FALSE
add_parameter pcie_qsys integer 1
set_parameter_property pcie_qsys VISIBLE false
# Specify is AST of AVMM bridge when using common parameter
add_parameter altpcie_avmm_hwtcl integer 0
set_parameter_property altpcie_avmm_hwtcl VISIBLE false
set_parameter_property altpcie_avmm_hwtcl HDL_PARAMETER  false

# Gen1/Gen2
add_parameter          lane_mask_hwtcl string "x4"
set_parameter_property lane_mask_hwtcl DISPLAY_NAME "Number of lanes"
set_parameter_property lane_mask_hwtcl ALLOWED_RANGES {"x1" "x2" "x4"}
set_parameter_property lane_mask_hwtcl GROUP "System Settings"
set_parameter_property lane_mask_hwtcl VISIBLE true
set_parameter_property lane_mask_hwtcl HDL_PARAMETER true
set_parameter_property lane_mask_hwtcl DESCRIPTION "Selects the maximum number of lanes supported. The IP core supports 1, 2, or 4 lanes."
# Gen1/Gen2
add_parameter          gen12_lane_rate_mode_hwtcl string "Gen1 (2.5 Gbps)"
set_parameter_property gen12_lane_rate_mode_hwtcl DISPLAY_NAME "Lane rate"
set_parameter_property gen12_lane_rate_mode_hwtcl ALLOWED_RANGES {"Gen1 (2.5 Gbps)" "Gen2 (5.0 Gbps)"}
set_parameter_property gen12_lane_rate_mode_hwtcl GROUP "System Settings"
set_parameter_property gen12_lane_rate_mode_hwtcl VISIBLE true
set_parameter_property gen12_lane_rate_mode_hwtcl HDL_PARAMETER true
set_parameter_property gen12_lane_rate_mode_hwtcl DESCRIPTION "Selects the maximum data rate of the link.Gen1 (2.5 Gbps) is supported."

# Selects the port type
add_parameter          porttype_func_hwtcl string "Native endpoint"
set_parameter_property porttype_func_hwtcl DISPLAY_NAME "Port type"
set_parameter_property porttype_func_hwtcl ALLOWED_RANGES {"Root port" "Native endpoint" "Legacy endpoint" }
set_parameter_property porttype_func_hwtcl GROUP "System Settings"
set_parameter_property porttype_func_hwtcl VISIBLE true
set_parameter_property porttype_func_hwtcl HDL_PARAMETER false
set_parameter_property porttype_func_hwtcl DESCRIPTION "Selects the port type. Native endpoints, root ports, and legacy endpoints are supported."

# Version
add_parameter          pcie_spec_version_hwtcl string "2.1"
set_parameter_property pcie_spec_version_hwtcl DISPLAY_NAME "PCI Express Base Specification version"
set_parameter_property pcie_spec_version_hwtcl ALLOWED_RANGES {"2.1"}
set_parameter_property pcie_spec_version_hwtcl GROUP "System Settings"
set_parameter_property pcie_spec_version_hwtcl VISIBLE false
set_parameter_property pcie_spec_version_hwtcl HDL_PARAMETER true
set_parameter_property pcie_spec_version_hwtcl DESCRIPTION "Selects the version of PCI Express Base Specification implemented. Version 2.1 is supported."

# Application Interface
add_parameter          ast_width_hwtcl string "Avalon-ST 64-bit"
set_parameter_property ast_width_hwtcl DISPLAY_NAME "Application interface"
set_parameter_property ast_width_hwtcl ALLOWED_RANGES {"Avalon-ST 64-bit" "Avalon-ST 128-bit"}
set_parameter_property ast_width_hwtcl GROUP "System Settings"
set_parameter_property ast_width_hwtcl VISIBLE true
set_parameter_property ast_width_hwtcl HDL_PARAMETER true
set_parameter_property ast_width_hwtcl DESCRIPTION "Selects the width of the data interface between the transaction layer and the application layer implemented in the PLD fabric. The IP core supports interfaces of 64 bits."

add_pcie_hip_parameters_ui_system_settings
add_pcie_hip_param_ui_func_registers ${MAX_FUNC}
add_pcie_pre_emph_vod_cv
# +-----------------------------------
# | Static IO
# |
add_interface no_connect conduit end
add_pcie_hip_port_por
add_pcie_hip_port_control

# ************** Global Variables ***************
set not_init "default"
# **************** Parameters *******************


proc proc_quartus_synth {name} {

   global QUARTUS_ROOTDIR
   add_fileset_file altpcie_cv_hip_ast_hwtcl.v       VERILOG PATH altpcie_cv_hip_ast_hwtcl.v
   add_fileset_file altpcie_rs_serdes.v              VERILOG PATH ../altera_pcie_sv_hip_ast/altpcie_rs_serdes.v
   add_fileset_file altpcie_rs_hip.v                 VERILOG PATH ../altera_pcie_sv_hip_ast/altpcie_rs_hip.v
   add_fileset_file altpcie_av_hip_128bit_atom.v     VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_av_hip_ast/altpcie_av_hip_128bit_atom.v
   add_fileset_file altpcie_av_hip_ast_hwtcl.v       VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_av_hip_ast/altpcie_av_hip_ast_hwtcl.v
   common_add_fileset_files { A5 ALL_HDL } { PLAIN }
}

proc proc_sim_vhdl {name} {

   global QUARTUS_ROOTDIR
   set verilog_file { "altpcie_cv_hip_ast_hwtcl.v" }
   foreach vf $verilog_file {
      # Co-simulation clear text verilog files
      add_fileset_file ${vf} VERILOG PATH ${vf}
      # Mentor only co-simulation files encrypted
      if {[file exist "mentor/${vf}"]} {
         add_fileset_file mentor/${vf} VERILOG_ENCRYPT PATH "mentor/${vf}" {MENTOR_SPECIFIC}
      }
   }
   add_fileset_file altpcie_rs_serdes.v     VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_sv_hip_ast/altpcie_rs_serdes.v
   if {[file exist "${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_sv_hip_ast/altpcie_rs_serdes.v"]} {
      add_fileset_file mentor/altpcie_rs_serdes.v VERILOG_ENCRYPT PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_sv_hip_ast/mentor/altpcie_rs_serdes.v {MENTOR_SPECIFIC}
   }
   add_fileset_file altpcie_rs_hip.v     VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_sv_hip_ast/altpcie_rs_hip.v
   if {[file exist "${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_sv_hip_ast/altpcie_rs_hip.v"]} {
      add_fileset_file mentor/altpcie_rs_hip.v VERILOG_ENCRYPT PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_sv_hip_ast/mentor/altpcie_rs_hip.v {MENTOR_SPECIFIC}
   }
   add_fileset_file altpcie_av_hip_128bit_atom.v     VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_av_hip_ast/altpcie_av_hip_128bit_atom.v
   if {[file exist "${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_av_hip_ast/mentor/altpcie_av_hip_128bit_atom.v"]} {
      add_fileset_file mentor/altpcie_av_hip_128bit_atom.v VERILOG_ENCRYPT PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_av_hip_ast/mentor/altpcie_av_hip_128bit_atom.v {MENTOR_SPECIFIC}
   }
   add_fileset_file altpcie_av_hip_ast_hwtcl.v       VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_av_hip_ast/altpcie_av_hip_ast_hwtcl.v
   if {[file exist "${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_av_hip_ast/mentor/altpcie_av_hip_ast_hwtcl.v"]} {
      add_fileset_file mentor/altpcie_av_hip_ast_hwtcl.v VERILOG_ENCRYPT PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_av_hip_ast/mentor/altpcie_av_hip_ast_hwtcl.v {MENTOR_SPECIFIC}
   }
   common_add_fileset_files { A5 ALL_HDL } { PLAIN MENTOR  }
}


proc proc_sim_verilog {name} {

   global QUARTUS_ROOTDIR
   add_fileset_file altpcie_cv_hip_ast_hwtcl.v       VERILOG PATH altpcie_cv_hip_ast_hwtcl.v
   add_fileset_file altpcie_rs_serdes.v              VERILOG PATH ../altera_pcie_sv_hip_ast/altpcie_rs_serdes.v
   add_fileset_file altpcie_rs_hip.v              VERILOG PATH ../altera_pcie_sv_hip_ast/altpcie_rs_hip.v
   add_fileset_file altpcie_av_hip_128bit_atom.v     VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_av_hip_ast/altpcie_av_hip_128bit_atom.v
   add_fileset_file altpcie_av_hip_ast_hwtcl.v       VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_av_hip_ast/altpcie_av_hip_ast_hwtcl.v
   common_add_fileset_files { A5 ALL_HDL } { PLAIN }
}

proc example_design_proc { outputName } {

   set ast_width_hwtcl [ get_parameter_value ast_width_hwtcl ]
   set port_type_hwtcl [ get_parameter_value porttype_func0_hwtcl ]
   set qsysprj       "pcie_de_gen1_x4_ast64"

   if { [ regexp endpoint $port_type_hwtcl ] } {
      #Add EP Design example
      set qsysprj  "pcie_de_gen1_x4_ast64"
      add_fileset_file pcie_de_gen1_x4_ast64.qsys OTHER PATH ../altera_pcie_hip_ast_ed/example_design/cv/pcie_de_gen1_x4_ast64.qsys
   } else {
      #Add RP Design example
      set qsysprj  "pcie_de_rp_gen1_x4_ast64"
      add_fileset_file pcie_de_rp_gen1_x4_ast64.qsys OTHER PATH ../altera_pcie_hip_ast_ed/example_design/cv/pcie_de_rp_gen1_x4_ast64.qsys
   }

#   add_fileset_file altpcied_qii.tcl OTHER PATH ../altera_pcie_hip_ast_ed/example_design/altpcied_qii.tcl
}


