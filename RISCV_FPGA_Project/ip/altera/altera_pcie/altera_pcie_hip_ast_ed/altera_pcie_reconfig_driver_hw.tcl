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

# +-----------------------------------
# | module PCI Express
# |
set_module_property NAME altera_pcie_reconfig_driver
set_module_property DESCRIPTION "Drive the reconfig_mgmt AvMM Slave Port on the Reconfig Controller"
set_module_property DATASHEET_URL "http://www.altera.com/literature/ug/ug_s5_pcie.pdf"
set_module_property GROUP "Interface Protocols/PCI"
set_module_property AUTHOR Altera
set_module_property DISPLAY_NAME "Altera PCIe Reconfig Driver"
set_module_property HIDE_FROM_SOPC true
set_module_property INTERNAL false
set_module_property EDITABLE false
set_module_property ANALYZE_HDL FALSE
set_module_property TOP_LEVEL_HDL_FILE altpcie_reconfig_driver.sv
set_module_property TOP_LEVEL_HDL_MODULE altpcie_reconfig_driver
set_module_property STATIC_TOP_LEVEL_MODULE_NAME altpcie_reconfig_driver
set_module_property instantiateInSystemModule "true"

# # +-----------------------------------
# # | QUARTUS_SYNTH design RTL files
#   |
add_fileset synth QUARTUS_SYNTH proc_quartus_synth
add_fileset sim_vhdl SIM_VHDL proc_sim_vhdl
add_fileset sim_verilog SIM_VERILOG proc_sim_verilog
set_module_property ELABORATION_CALLBACK elaboration_callback

# +-----------------------------------
# | parameters
# |
add_parameter INTENDED_DEVICE_FAMILY String "Stratix V"
set_parameter_property INTENDED_DEVICE_FAMILY SYSTEM_INFO DEVICE_FAMILY
set_parameter_property INTENDED_DEVICE_FAMILY HDL_PARAMETER true
set_parameter_property INTENDED_DEVICE_FAMILY VISIBLE FALSE

# Gen1/Gen2/Gen3
add_parameter          gen123_lane_rate_mode_hwtcl string "Gen1 (2.5 Gbps)"
set_parameter_property gen123_lane_rate_mode_hwtcl DISPLAY_NAME "Lane Rate"
set_parameter_property gen123_lane_rate_mode_hwtcl ALLOWED_RANGES {"Gen1 (2.5 Gbps)" "Gen2 (5.0 Gbps)" "Gen3 (8.0 Gbps)"}
set_parameter_property gen123_lane_rate_mode_hwtcl VISIBLE true
set_parameter_property gen123_lane_rate_mode_hwtcl HDL_PARAMETER true
set_parameter_property gen123_lane_rate_mode_hwtcl DESCRIPTION "Selects the maximum data rate of the link. Gen1 (2.5 Gbps), Gen2 (5.0 Gbps) and Gen3 (8.0 Gbps) are supported."

# number of reconfig interfaces
add_parameter number_of_reconfig_interfaces INTEGER 2
set_parameter_property number_of_reconfig_interfaces DISPLAY_NAME "Number of reconfiguration interfaces"
set_parameter_property number_of_reconfig_interfaces ALLOWED_RANGES 1:2048
set_parameter_property number_of_reconfig_interfaces VISIBLE true
set_parameter_property number_of_reconfig_interfaces HDL_PARAMETER true
set_parameter_property number_of_reconfig_interfaces DESCRIPTION "Specifies the total number of reconfiguration interfaces that connect to this Transceiver Reconfiguration Controller. There is one interface for each channel and TX PLL."

add_parameter          enable_cal_busy_hwtcl integer 0
set_parameter_property enable_cal_busy_hwtcl DISPLAY_NAME "Add cal_busy_in output port conduit"
set_parameter_property enable_cal_busy_hwtcl DISPLAY_HINT boolean
set_parameter_property enable_cal_busy_hwtcl VISIBLE true
set_parameter_property enable_cal_busy_hwtcl HDL_PARAMETER false
set_parameter_property enable_cal_busy_hwtcl DESCRIPTION "When On, add cal_busy_in output port conduit to drive alt_xcvr_reconfig input port cal_busy_in"

# number of reconfig interfaces
add_parameter number_of_reconfig_interfaces INTEGER 2
set_parameter_property number_of_reconfig_interfaces DISPLAY_NAME "Number of reconfiguration interfaces"
set_parameter_property number_of_reconfig_interfaces ALLOWED_RANGES 1:2048
set_parameter_property number_of_reconfig_interfaces VISIBLE true
set_parameter_property number_of_reconfig_interfaces HDL_PARAMETER true
set_parameter_property number_of_reconfig_interfaces DESCRIPTION "Specifies the total number of reconfiguration interfaces that connect to this Transceiver Reconfiguration Controller. There is one interface for each channel and TX PLL."

# +-----------------------------------
# | Static IO
# |
add_interface            reconfig_xcvr_clk clock end
add_interface_port       reconfig_xcvr_clk reconfig_xcvr_clk clk Input 1
set_interface_assignment reconfig_xcvr_clk "ui.blockdiagram.direction" "input"


add_interface reconfig_xcvr_rst reset end reconfig_xcvr_clk
add_interface_port reconfig_xcvr_rst reconfig_xcvr_rst reset Input 1
set_interface_assignment reconfig_xcvr_rst "ui.blockdiagram.direction" "input"

add_interface reconfig_mgmt avalon master reconfig_xcvr_clk
set_interface_property reconfig_mgmt associatedReset reconfig_xcvr_rst
set_interface_property reconfig_mgmt addressUnits WORDS
add_interface_port reconfig_mgmt reconfig_mgmt_address address Output 7
add_interface_port reconfig_mgmt reconfig_mgmt_read read Output 1
add_interface_port reconfig_mgmt reconfig_mgmt_readdata readdata Input 32
add_interface_port reconfig_mgmt reconfig_mgmt_waitrequest waitrequest Input 1
add_interface_port reconfig_mgmt reconfig_mgmt_write write Output 1
add_interface_port reconfig_mgmt reconfig_mgmt_writedata writedata Output 32
set_interface_assignment reconfig_mgmt "ui.blockdiagram.direction" "output"

add_interface hip_currentspeed conduit end
add_interface_port hip_currentspeed currentspeed       currentspeed       Input 2

add_interface reconfig_busy conduit end
add_interface_port reconfig_busy reconfig_busy       reconfig_busy       Input 1

add_interface            pld_clk clock end
add_interface_port       pld_clk pld_clk clk Input 1
set_interface_assignment pld_clk "ui.blockdiagram.direction" "input"

# ************** Global Variables ***************
set not_init "default"
# **************** Parameters *******************

proc elaboration_callback { } {
   proc_altera_pcie_reconfig_driver_port_upd
}


proc proc_quartus_synth {name} {

   add_fileset_file alt_xcvr_reconfig_h.sv            SYSTEMVERILOG PATH ../../alt_xcvr_reconfig/alt_xcvr_reconfig/alt_xcvr_reconfig_h.sv
   add_fileset_file altpcie_reconfig_driver.sv        SYSTEMVERILOG PATH altpcie_reconfig_driver.sv
}

proc proc_sim_vhdl {name} {

   add_fileset_file alt_xcvr_reconfig_h.sv            SYSTEMVERILOG PATH ../../alt_xcvr_reconfig/alt_xcvr_reconfig/alt_xcvr_reconfig_h.sv
   add_fileset_file altpcie_reconfig_driver.sv        SYSTEMVERILOG PATH altpcie_reconfig_driver.sv
}

proc proc_sim_verilog {name} {

   add_fileset_file alt_xcvr_reconfig_h.sv            SYSTEMVERILOG PATH ../../alt_xcvr_reconfig/alt_xcvr_reconfig/alt_xcvr_reconfig_h.sv
   add_fileset_file altpcie_reconfig_driver.sv        SYSTEMVERILOG PATH altpcie_reconfig_driver.sv
}

proc proc_altera_pcie_reconfig_driver_port_upd { } {
   set INTENDED_DEVICE_FAMILY [ get_parameter_value INTENDED_DEVICE_FAMILY ]
   set ena_cal_busy_port [ get_parameter_value enable_cal_busy_hwtcl]

   add_interface no_connect conduit end

   if { $ena_cal_busy_port == 1} {
      add_interface cal_busy_in conduit end
      add_interface_port   cal_busy_in    cal_busy_in    cal_busy_in Output 1
   } else {
      add_interface_port no_connect cal_busy_in cal_busy_in Output 1
      set_port_property  cal_busy_in TERMINATION true
   }

   add_interface hip_status_drv conduit end
   add_interface_port hip_status_drv derr_cor_ext_rcv_drv   derr_cor_ext_rcv   Input 1
   add_interface_port hip_status_drv derr_cor_ext_rpl_drv   derr_cor_ext_rpl   Input 1
   add_interface_port hip_status_drv derr_rpl_drv           derr_rpl           Input 1
   add_interface_port hip_status_drv dlup_exit_drv          dlup_exit          Input 1
   add_interface_port hip_status_drv ev128ns_drv            ev128ns            Input 1
   add_interface_port hip_status_drv ev1us_drv              ev1us              Input 1
   add_interface_port hip_status_drv hotrst_exit_drv        hotrst_exit        Input 1
   add_interface_port hip_status_drv int_status_drv         int_status         Input 4
   add_interface_port hip_status_drv l2_exit_drv            l2_exit            Input 1
   add_interface_port hip_status_drv lane_act_drv           lane_act           Input 4
   add_interface_port hip_status_drv ltssmstate_drv         ltssmstate         Input 5
   # Parity error
   if { $INTENDED_DEVICE_FAMILY == "Arria V" || $INTENDED_DEVICE_FAMILY == "Cyclone V" } {
      add_interface_port no_connect  dlup_drv	     dlup	 Input 1
      add_interface_port no_connect  rx_par_err_drv  rx_par_err  Input 1
      add_interface_port no_connect  tx_par_err_drv  tx_par_err  Input 2
      add_interface_port no_connect  cfg_par_err_drv cfg_par_err Input 1
      set_port_property		     dlup_drv	     TERMINATION true
      set_port_property		     rx_par_err_drv  TERMINATION true
      set_port_property		     tx_par_err_drv  TERMINATION true
      set_port_property		     cfg_par_err_drv TERMINATION true
   } else {
      add_interface_port hip_status_drv dlup_drv             dlup               Input 1
      add_interface_port hip_status_drv rx_par_err_drv       rx_par_err         Input 1
      add_interface_port hip_status_drv	tx_par_err_drv       tx_par_err         Input 2
      add_interface_port hip_status_drv	cfg_par_err_drv      cfg_par_err        Input 1
   }
   # Completion space information
   add_interface_port hip_status_drv ko_cpl_spc_header_drv	 ko_cpl_spc_header  Input 8
   add_interface_port hip_status_drv ko_cpl_spc_data_drv	 ko_cpl_spc_data    Input 12
}

