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

set group_name ""
# +-----------------------------------
# | module PCI Express
# |
set_module_property NAME altera_pcie_cfgbp_ed
set_module_property DESCRIPTION "Config-Bypass Application Example Design for PCI Express"
set_module_property DATASHEET_URL "http://www.altera.com/literature/ug/ug_s5_pcie.pdf"
set_module_property GROUP $group_name
set_module_property AUTHOR Altera
set_module_property DISPLAY_NAME "Config-Bypass App Example"
set_module_property HIDE_FROM_SOPC true
set_module_property INTERNAL false
set_module_property EDITABLE false
set_module_property ANALYZE_HDL FALSE
set_module_property ELABORATION_CALLBACK elaboration_callback
set_module_property instantiateInSystemModule "true"

# # +-----------------------------------
# # | QUARTUS_SYNTH design RTL files
#   |
add_fileset sim_vhdl SIM_VHDL proc_sim_vhdl
set_fileset_property sim_vhdl TOP_LEVEL altpcied_cfbp_app_example

add_fileset sim_verilog SIM_VERILOG proc_sim_verilog
set_fileset_property sim_verilog TOP_LEVEL altpcied_cfbp_app_example

add_fileset synth QUARTUS_SYNTH proc_quartus_synth
set_fileset_property synth TOP_LEVEL altpcied_cfbp_app_example

# +-----------------------------------
# | parameters
# |

#   add_rdpcie_parameters_ui
####################################################################################################
#
#proc add_rdpcie_parameters_ui {} {
#   send_message debug "proc:add_rdpcie_parameters_ui"
#   set group_name "Design example parameters"

   # avalon_waddr_hwltcl
   add_parameter          avalon_waddr_hwltcl integer 20
   set_parameter_property avalon_waddr_hwltcl DISPLAY_NAME "Target address width"
   set_parameter_property avalon_waddr_hwltcl ALLOWED_RANGES { 20 }
   set_parameter_property avalon_waddr_hwltcl GROUP $group_name
   set_parameter_property avalon_waddr_hwltcl VISIBLE FALSE
   set_parameter_property avalon_waddr_hwltcl HDL_PARAMETER true
   set_parameter_property avalon_waddr_hwltcl DESCRIPTION "Avalon-MM address width on the target interface. It represents the total memory size claimed by target"

    # AVALON_WDATA
   add_parameter          port_width_data_hwtcl integer 64
   set_parameter_property port_width_data_hwtcl VISIBLE false
   set_parameter_property port_width_data_hwtcl DERIVED true
   set_parameter_property port_width_data_hwtcl HDL_PARAMETER true

   # AVALON_BE
   add_parameter          port_width_be_hwtcl integer 8
   set_parameter_property port_width_be_hwtcl VISIBLE false
   set_parameter_property port_width_be_hwtcl HDL_PARAMETER true
   set_parameter_property port_width_be_hwtcl DERIVED true

   # DEVIDE_ID
   add_parameter          DEVIDE_ID integer 0xE001
   set_parameter_property DEVIDE_ID DISPLAY_NAME "Device ID"
   set_parameter_property DEVIDE_ID ALLOWED_RANGES { 0:65534 }
   set_parameter_property DEVIDE_ID DISPLAY_HINT hexadecimal
   set_parameter_property DEVIDE_ID VISIBLE TRUE
   set_parameter_property DEVIDE_ID HDL_PARAMETER true
   set_parameter_property DEVIDE_ID DESCRIPTION "Device ID"

   # VENDOR_ID
   add_parameter          VENDOR_ID integer 0x1172
   set_parameter_property VENDOR_ID DISPLAY_NAME "Vendor ID"
   set_parameter_property VENDOR_ID ALLOWED_RANGES { 0:65534 }
   set_parameter_property VENDOR_ID DISPLAY_HINT hexadecimal
   set_parameter_property VENDOR_ID VISIBLE TRUE
   set_parameter_property VENDOR_ID HDL_PARAMETER true
   set_parameter_property VENDOR_ID DESCRIPTION "Vendor ID"

   # SUBSYS_ID
   add_parameter          SUBSYS_ID integer 0x1234
   set_parameter_property SUBSYS_ID DISPLAY_NAME "Subsystem ID"
   set_parameter_property SUBSYS_ID ALLOWED_RANGES { 0:65534 }
   set_parameter_property SUBSYS_ID DISPLAY_HINT hexadecimal
   set_parameter_property SUBSYS_ID VISIBLE TRUE
   set_parameter_property SUBSYS_ID HDL_PARAMETER true
   set_parameter_property SUBSYS_ID DESCRIPTION "Subsystem ID"

   # SUBVENDOR_ID
   add_parameter          SUBVENDOR_ID integer 0x5678
   set_parameter_property SUBVENDOR_ID DISPLAY_NAME "Subsystem Vendor ID"
   set_parameter_property SUBVENDOR_ID ALLOWED_RANGES { 0:65534 }
   set_parameter_property SUBVENDOR_ID DISPLAY_HINT hexadecimal
   set_parameter_property SUBVENDOR_ID VISIBLE TRUE
   set_parameter_property SUBVENDOR_ID HDL_PARAMETER true
   set_parameter_property SUBVENDOR_ID DESCRIPTION "Subsystem Vendor ID"

   # BAR0_PREFETCHABLE
   add_parameter          BAR0_PREFETCHABLE integer 1
   set_parameter_property BAR0_PREFETCHABLE DISPLAY_NAME "BAR0 Prefetchable"
   set_parameter_property BAR0_PREFETCHABLE ALLOWED_RANGES { 0 1 }
   set_parameter_property BAR0_PREFETCHABLE VISIBLE TRUE
   set_parameter_property BAR0_PREFETCHABLE HDL_PARAMETER true
   set_parameter_property BAR0_PREFETCHABLE DESCRIPTION "Prefechable bit of BAR0"

   # BAR0_TYPE
   add_parameter          BAR0_TYPE integer 2
   set_parameter_property BAR0_TYPE DISPLAY_NAME "BAR0 Type"
   set_parameter_property BAR0_TYPE ALLOWED_RANGES { 0 2 }
   set_parameter_property BAR0_TYPE VISIBLE TRUE
   set_parameter_property BAR0_TYPE HDL_PARAMETER true
   set_parameter_property BAR0_TYPE DESCRIPTION "BAR0 Type: 0 = 32bit Addressing, 2 = 64bit Addressing"

   #multiple_packets_per_cycle_hwtcl
   add_parameter          multiple_packets_per_cycle_hwtcl integer 0
   set_parameter_property multiple_packets_per_cycle_hwtcl DISPLAY_NAME "Enable multiple packets per cycle"
   set_parameter_property multiple_packets_per_cycle_hwtcl DISPLAY_HINT boolean
   set_parameter_property multiple_packets_per_cycle_hwtcl GROUP $group_name
   set_parameter_property multiple_packets_per_cycle_hwtcl VISIBLE FALSE
   set_parameter_property multiple_packets_per_cycle_hwtcl HDL_PARAMETER true
   set_parameter_property multiple_packets_per_cycle_hwtcl DESCRIPTION "When On, the Avalon-ST interface supports the transmission of TLPs starting at any 128-bit address boundary, allowing support for multiple packets in a single cycle. To support multiple packets per cycle, the Avalon-ST interface includes 2 start of packet and end of packet signals for the 256-bit Avalon-ST interfaces."

   # PLD clock rate
   add_parameter          pld_clockrate_hwtcl integer 125000000
   set_parameter_property pld_clockrate_hwtcl DISPLAY_NAME "Application Clock Rate"
   set_parameter_property pld_clockrate_hwtcl ALLOWED_RANGES { "62500000:62.5 MHz" "125000000:125 MHz" "250000000:250 MHz" }
   set_parameter_property pld_clockrate_hwtcl GROUP $group_name
   set_parameter_property pld_clockrate_hwtcl VISIBLE true
   set_parameter_property pld_clockrate_hwtcl HDL_PARAMETER true
   set_parameter_property pld_clockrate_hwtcl DESCRIPTION "Selects the maximum data rate of the link.Gen1 (2.5 Gbps) and Gen2 (5.0 Gbps) are supported."

   # Application Interface
   add_parameter          ast_width_hwtcl string "Avalon-ST 128-bit"
   set_parameter_property ast_width_hwtcl DISPLAY_NAME "Application interface"
   set_parameter_property ast_width_hwtcl ALLOWED_RANGES {"Avalon-ST 64-bit" "Avalon-ST 128-bit" "Avalon-ST 256-bit"}
   set_parameter_property ast_width_hwtcl GROUP $group_name
   set_parameter_property ast_width_hwtcl VISIBLE true
   set_parameter_property ast_width_hwtcl HDL_PARAMETER true
   #set_parameter_property ast_width_hwtcl DESCRIPTION "Selects the width of the data interface between the transaction layer and the application layer implemented in the PLD fabric. The IP core supports interfaces of 64, 128, or 256 bits."
   set_parameter_property ast_width_hwtcl DESCRIPTION "Selects the width of the data interface between the transaction layer and the application layer implemented in the PLD fabric. The IP core supports interfaces of 128bits."

   #Function
   add_parameter          num_of_func_hwtcl integer 1
   set_parameter_property num_of_func_hwtcl DISPLAY_NAME "Number of Functions"
   set_parameter_property num_of_func_hwtcl ALLOWED_RANGES {"1" "2" "3" "4" "5" "6" "7" "8"}
   set_parameter_property num_of_func_hwtcl GROUP $group_name
   set_parameter_property num_of_func_hwtcl VISIBLE false
   set_parameter_property num_of_func_hwtcl HDL_PARAMETER true
   set_parameter_property num_of_func_hwtcl DESCRIPTION "Number of Functions to supported by the HIP. For Config-Bypass Application Logic, Only partial of function 0 in HIP is valid"

   # Gen1/Gen2
   add_parameter          gen123_lane_rate_mode_hwtcl string "Gen2 (5.0 Gbps)"
   set_parameter_property gen123_lane_rate_mode_hwtcl DISPLAY_NAME "Lane rate"
   set_parameter_property gen123_lane_rate_mode_hwtcl ALLOWED_RANGES {"Gen1 (2.5 Gbps)" "Gen2 (5.0 Gbps)" "Gen3 (8.0 Gbps)"}
   set_parameter_property gen123_lane_rate_mode_hwtcl GROUP $group_name
   set_parameter_property gen123_lane_rate_mode_hwtcl VISIBLE true
   set_parameter_property gen123_lane_rate_mode_hwtcl HDL_PARAMETER true
   set_parameter_property gen123_lane_rate_mode_hwtcl DESCRIPTION "Selects the maximum data rate of the link.Gen1 (2.5 Gbps), Gen2 (5.0 Gbps) and Gen3 (8.0 Gbps) are supported."

   #device_family_hwtcl
   add_parameter           device_family_hwtcl  string "Stratix V"
   set_parameter_property  device_family_hwtcl  DISPLAY_NAME "Targeted Device Family"
   #set_parameter_property  device_family_hwtcl  ALLOWED_RANGES {"Stratix V" "Arria V" "Cyclone V"}
   set_parameter_property  device_family_hwtcl  ALLOWED_RANGES {"Stratix V"}
   set_parameter_property  device_family_hwtcl  GROUP $group_name
   set_parameter_property  device_family_hwtcl  VISIBLE true
   set_parameter_property  device_family_hwtcl  HDL_PARAMETER true
   set_parameter_property  device_family_hwtcl  DESCRIPTION "Selects the targeted device family for device specific parameterization"

#}

# +-----------------------------------
# | Static IO
# |

#add_interface no_connect conduit end

# # +-----------------------------------
# # | elaboration items
# # |
proc elaboration_callback { } {

   set gen123_lane_rate_mode_hwtcl [ get_parameter gen123_lane_rate_mode_hwtcl ]
   validation_parameter_system_setting

   # Clock and reset
   add_rdpcie_port_clk
   add_rdpcie_port_rst

   # Port updates
   add_rdpcie_port_ast_rx
   add_rdpcie_port_ast_tx
   add_rdpcie_port_status
   add_rdpcie_port_lmi
   add_cfgbp_port_io

   # Parameter updates
   set_module_assignment testbench.partner.pcie_tb.parameter.port_type_hwtcl "Native endpoint"
   set_module_assignment testbench.partner.pcie_tb.parameter.apps_type_hwtcl 10
   set_module_assignment testbench.partner.pcie_tb.parameter.gen123_lane_rate_mode_hwtcl  [get_parameter gen123_lane_rate_mode_hwtcl]
   if { [ regexp Gen3 $gen123_lane_rate_mode_hwtcl ] } {
      set_module_assignment testbench.partner.pcie_tb.parameter.serial_sim_hwtcl 1
   }
}

####################################################################################################
   #
   # Design Example Clock conduit
   #
   proc add_rdpcie_port_clk {} {

   send_message debug "proc: add_rdpcie_port_clk"

   add_interface        coreclkout_hip clock end
   add_interface_port   coreclkout_hip coreclkout_hip clk Input 1

   add_interface        pld_clk_hip clock start
   add_interface_port   pld_clk_hip pld_clk_hip clk Output 1

   set pld_clockrate_hwtcl [ get_parameter_value pld_clockrate_hwtcl ]
   set_interface_property pld_clk_hip clockRate $pld_clockrate_hwtcl

}

####################################################################################################
#
# Design Example Reset conduit
#
proc add_rdpcie_port_rst {} {

   send_message debug "proc:add_rdpcie_port_rst"

   add_interface hip_rst conduit end
   add_interface_port hip_rst reset_status   reset_status  Input 1
   add_interface_port hip_rst serdes_pll_locked   serdes_pll_locked  Input 1
   add_interface_port hip_rst pld_clk_inuse  pld_clk_inuse Input 1
   add_interface_port hip_rst pld_core_ready pld_core_ready     Output 1
   add_interface_port hip_rst testin_zero    testin_zero   Input 1

}

####################################################################################################
#
# Avalon-ST RX
#
proc add_rdpcie_port_ast_rx {} {

   send_message debug "proc: add_rdpcie_port_ast_rx"
  #set number_of_func_hwtcl [ get_parameter_value num_of_func_hwtcl ]
   set ast_width_hwtcl  [ get_parameter_value ast_width_hwtcl]
   set dev_family [get_parameter_value device_family_hwtcl ]
   set multiple_packets_per_cycle_hwtcl   [ get_parameter_value multiple_packets_per_cycle_hwtcl]


   # Design example does not support parity yet
   set ast_parity   0
   set dataWidth        [ expr [ regexp 256 $ast_width_hwtcl  ] ? 256 : [ regexp 128 $ast_width_hwtcl ] ? 128 : 64 ]
   set dataByteWidth    [ expr [ regexp 256 $ast_width_hwtcl  ] ? 32  : [ regexp 128 $ast_width_hwtcl ] ? 16 : 8 ]

   # Avalon-stream RX HIP
   add_interface rx_st avalon_streaming end
   if { $multiple_packets_per_cycle_hwtcl == 1 } {
      set_interface_property rx_st beatsPerCycle 2
      set_interface_property rx_st dataBitsPerSymbol 128
   } else {
      set_interface_property rx_st beatsPerCycle 1
      set_interface_property rx_st dataBitsPerSymbol $dataWidth
   }
   set_interface_property rx_st maxChannel 0
   set_interface_property rx_st readyLatency 3
   set_interface_property rx_st symbolsPerBeat 1
   set_interface_property rx_st ENABLED true
   set_interface_property rx_st ASSOCIATED_CLOCK pld_clk_hip
   if { $multiple_packets_per_cycle_hwtcl == 1 } {
      add_interface_port rx_st rx_st_sop startofpacket Input 2
      add_interface_port rx_st rx_st_eop endofpacket Input 2
      add_interface_port rx_st rx_st_err error Input 2
      add_interface_port rx_st rx_st_valid valid Input 2
   } else {
      add_interface_port rx_st rx_st_sop startofpacket Input 1
      add_interface_port rx_st rx_st_eop endofpacket Input 1
      add_interface_port rx_st rx_st_err error Input 1
      add_interface_port rx_st rx_st_valid valid Input 1
   }
   set_port_property rx_st_sop VHDL_TYPE std_logic_vector
   set_port_property rx_st_eop VHDL_TYPE std_logic_vector
   set_port_property rx_st_err VHDL_TYPE std_logic_vector
   set_port_property rx_st_valid VHDL_TYPE std_logic_vector
   if { $dataWidth > 64 } {
      if { $dev_family == "Arria V" || $dev_family == "Cyclone V" } {
         add_interface_port rx_st rx_st_empty empty Input 1
         set_port_property  rx_st_empty VHDL_TYPE std_logic_vector
      } else {
         add_interface_port rx_st rx_st_empty empty Input 2
         set_port_property  rx_st_empty VHDL_TYPE std_logic_vector
      }
   } else {
      if { $dev_family == "Arria V" || $dev_family == "Cyclone V" } {
         add_to_no_connect rx_st_empty 1 In
      } else {
         add_to_no_connect rx_st_empty 2 In
      }
   }
   add_interface_port rx_st rx_st_ready ready Output 1
   add_interface_port rx_st rx_st_data data Input $dataWidth
   # Parity
   if { $ast_parity == 0 } {
      add_to_no_connect rx_st_parity $dataByteWidth Input
   } else {
     add_interface_port rx_st rx_st_parity parity Input $dataByteWidth
   }

   # rx_bar_be combines the Design Example Bar decode signal with the Design Example RX_DATA_BE
   # which are not avalon-st but synchronous to the rx_st_data bus
   add_interface rx_bar_be conduit end

   # BAR Decode output
   add_interface_port rx_bar_be rx_st_bar rx_st_bar   Input 8

   # Byte enable
 #  add_interface_port rx_bar_be rx_st_be rx_st_be     Input $dataByteWidth

   # Rx st mask
   add_interface_port rx_bar_be rx_st_mask rx_st_mask Output 1
}

####################################################################################################
#
# Avalon-ST TX
#
proc add_rdpcie_port_ast_tx {} {

   send_message debug "proc: add_rdpcie_port_ast_tx"
  #set number_of_func_hwtcl [ get_parameter_value num_of_func_hwtcl ]
   set dev_family [get_parameter_value device_family_hwtcl ]
   set ast_width_hwtcl  [ get_parameter_value ast_width_hwtcl]
   set multiple_packets_per_cycle_hwtcl   [ get_parameter_value multiple_packets_per_cycle_hwtcl]

   # Design example does not support parity yet
   set ast_parity   0
   set dataWidth        [ expr [ regexp 256 $ast_width_hwtcl  ] ? 256 : [ regexp 128 $ast_width_hwtcl ] ? 128 : 64 ]
   set dataByteWidth    [ expr [ regexp 256 $ast_width_hwtcl  ] ? 32  : [ regexp 128 $ast_width_hwtcl ] ? 16 : 8 ]

   # Avalon-stream RX HIP
   # indicates that AST symbols ordering is little endian instead of Big endian
   # set_interface_property rx_st highOrderSymbolAtMSB false
   add_interface tx_st avalon_streaming start
   if { $multiple_packets_per_cycle_hwtcl == 1 } {
      set_interface_property tx_st beatsPerCycle 2
      set_interface_property tx_st dataBitsPerSymbol 128
   } else {
      set_interface_property tx_st beatsPerCycle 1
      set_interface_property tx_st dataBitsPerSymbol $dataWidth
   }
   set_interface_property tx_st maxChannel 0
   set_interface_property tx_st readyLatency 3
   set_interface_property tx_st symbolsPerBeat 1
   set_interface_property tx_st ENABLED true
   set_interface_property tx_st ASSOCIATED_CLOCK pld_clk_hip
   if { $multiple_packets_per_cycle_hwtcl == 1 } {
      add_interface_port tx_st tx_st_sop startofpacket Output 2
      add_interface_port tx_st tx_st_eop endofpacket Output 2
      add_interface_port tx_st tx_st_err error Output 2
      add_interface_port tx_st tx_st_valid valid Output 2
   } else {
      add_interface_port tx_st tx_st_sop startofpacket Output 1
      add_interface_port tx_st tx_st_eop endofpacket Output 1
      add_interface_port tx_st tx_st_err error Output 1
      add_interface_port tx_st tx_st_valid valid Output 1
   }
   set_port_property tx_st_sop VHDL_TYPE std_logic_vector
   set_port_property tx_st_eop VHDL_TYPE std_logic_vector
   set_port_property tx_st_err VHDL_TYPE std_logic_vector
   set_port_property tx_st_valid VHDL_TYPE std_logic_vector
   if { $dataWidth > 64 } {
      if { $dev_family == "Arria V" || $dev_family == "Cyclone V" } {
          add_interface_port tx_st tx_st_empty empty Output 1
          set_port_property  tx_st_empty VHDL_TYPE std_logic_vector
      } else {
         add_interface_port tx_st tx_st_empty empty Output 2
         set_port_property  tx_st_empty VHDL_TYPE std_logic_vector
      }
   }
   add_interface_port tx_st tx_st_ready ready Input 1
   add_interface_port tx_st tx_st_data data Output $dataWidth

   # Parity
   if { $ast_parity == 0 } {
      add_to_no_connect tx_st_parity $dataByteWidth Output
   } else {
     add_interface_port tx_st tx_st_parity parity Output $dataByteWidth
   }

   #Tx Fifo Information
   if { $dev_family == "Arria V" || $dev_family == "Cyclone V" } {
      add_interface tx_fifo conduit end
      add_interface_port tx_fifo tx_fifo_empty tx_fifo_empty Input 1
   } else {
      add_to_no_connect tx_fifo_empty 1 In
      set_port_property             tx_fifo_empty TERMINATION true
      set_port_property             tx_fifo_empty TERMINATION_VALUE 1
   }

}

####################################################################################################
#
# Design Example Status conduit
#
proc add_rdpcie_port_status {} {

   send_message debug "proc: add_rdpcie_port_status"
   set dev_family [get_parameter_value device_family_hwtcl]
  #set track_rxfc_cplbuf_ovf_hwtcl [get_parameter_value track_rxfc_cplbuf_ovf_hwtcl]

   add_interface hip_status conduit end
   add_interface_port hip_status derr_cor_ext_rcv   derr_cor_ext_rcv   Input 1
   add_interface_port hip_status derr_cor_ext_rpl   derr_cor_ext_rpl   Input 1
   add_interface_port hip_status derr_rpl           derr_rpl           Input 1
   add_interface_port hip_status dlup               dlup               Input 1
   add_interface_port hip_status dlup_exit          dlup_exit          Input 1
   add_interface_port hip_status ev128ns            ev128ns            Input 1
   add_interface_port hip_status ev1us              ev1us              Input 1
   add_interface_port hip_status hotrst_exit        hotrst_exit        Input 1
   add_interface_port hip_status int_status         int_status         Input 4
   add_interface_port hip_status l2_exit            l2_exit            Input 1
   add_interface_port hip_status lane_act           lane_act           Input 4
   add_interface_port hip_status ltssmstate         ltssmstate         Input 5

   # Parity error
   add_interface_port hip_status rx_par_err         rx_par_err         Input 1
   add_interface_port hip_status tx_par_err         tx_par_err         Input 2
   add_interface_port hip_status cfg_par_err        cfg_par_err        Input 1

   # Completion space information
   add_interface_port hip_status ko_cpl_spc_header ko_cpl_spc_header Input 8
   add_interface_port hip_status ko_cpl_spc_data   ko_cpl_spc_data   Input 12

 #  if { $track_rxfc_cplbuf_ovf_hwtcl == 1 } {
 #     add_interface_port  hip_status rxfc_cplbuf_ovf rxfc_cplbuf_ovf Input 1
 #  } else {
 #     add_to_no_connect rxfc_cplbuf_ovf     1     In
 #  }

   add_interface hip_status_drv conduit end
   add_interface_port hip_status_drv derr_cor_ext_rcv_drv   derr_cor_ext_rcv   Output 1
   add_interface_port hip_status_drv derr_cor_ext_rpl_drv   derr_cor_ext_rpl   Output 1
   add_interface_port hip_status_drv derr_rpl_drv           derr_rpl           Output 1
   add_interface_port hip_status_drv dlup_exit_drv          dlup_exit          Output 1
   add_interface_port hip_status_drv ev128ns_drv            ev128ns            Output 1
   add_interface_port hip_status_drv ev1us_drv              ev1us              Output 1
   add_interface_port hip_status_drv hotrst_exit_drv        hotrst_exit        Output 1
   add_interface_port hip_status_drv int_status_drv         int_status         Output 4
   add_interface_port hip_status_drv l2_exit_drv            l2_exit            Output 1
   add_interface_port hip_status_drv lane_act_drv           lane_act           Output 4
   add_interface_port hip_status_drv ltssmstate_drv         ltssmstate         Output 5
   add_interface_port hip_status_drv dlup_drv               dlup               Output 1
   add_interface_port hip_status_drv rx_par_err_drv         rx_par_err         Output 1
   add_interface_port hip_status_drv tx_par_err_drv         tx_par_err         Output 2
   add_interface_port hip_status_drv cfg_par_err_drv        cfg_par_err        Output 1
   add_interface_port hip_status_drv ko_cpl_spc_header_drv	ko_cpl_spc_header  Output 8
   add_interface_port hip_status_drv ko_cpl_spc_data_drv	   ko_cpl_spc_data    Output 12


}

####################################################################################################
#
# LMI interface conduit TODO Map it to AVMM
#
proc add_rdpcie_port_lmi {} {

   send_message debug "proc:add_rdpcie_port_lmi"
   set number_of_func_hwtcl [ get_parameter_value num_of_func_hwtcl ]

   add_interface lmi conduit end

   if { $number_of_func_hwtcl == 1 } {
      add_interface_port lmi lmi_addr lmi_addr  Output  12
   } else {
      add_interface_port lmi lmi_addr lmi_addr  Output  15
   }

   add_interface_port lmi lmi_din  lmi_din   Output  32
   add_interface_port lmi lmi_rden lmi_rden  Output  1
   add_interface_port lmi lmi_wren lmi_wren  Output  1
   add_interface_port lmi lmi_ack  lmi_ack   Input 1
   add_interface_port lmi lmi_dout lmi_dout  Input 32
}

####################################################################################################
#
# Design Example Config-Bypass conduit
#
proc add_cfgbp_port_io {} {

   send_message debug "proc: add_cfgbp_port_io"
   set dev_family [get_parameter_value device_family_hwtcl]

   add_interface      config_bypass conduit end
   add_interface_port config_bypass    cfgbp_link2csr               cfgbp_link2csr                Output 13
   add_interface_port config_bypass    cfgbp_comclk_reg             cfgbp_comclk_reg              Output 1
   add_interface_port config_bypass    cfgbp_extsy_reg              cfgbp_extsy_reg               Output 1
   add_interface_port config_bypass    cfgbp_max_pload              cfgbp_max_pload               Output 3
   add_interface_port config_bypass    cfgbp_tx_ecrcgen             cfgbp_tx_ecrcgen              Output 1
   add_interface_port config_bypass    cfgbp_rx_ecrchk              cfgbp_rx_ecrchk               Output 1
   add_interface_port config_bypass    cfgbp_secbus                 cfgbp_secbus                  Output 8
   add_interface_port config_bypass    cfgbp_linkcsr_bit0           cfgbp_linkcsr_bit0            Output 1
   add_interface_port config_bypass    cfgbp_tx_req_pm              cfgbp_tx_req_pm               Output 1
   add_interface_port config_bypass    cfgbp_tx_typ_pm              cfgbp_tx_typ_pm               Output 3
   add_interface_port config_bypass    cfgbp_req_phypm              cfgbp_req_phypm               Output 4
   add_interface_port config_bypass    cfgbp_req_phycfg             cfgbp_req_phycfg              Output 4
   add_interface_port config_bypass    cfgbp_vc0_tcmap_pld          cfgbp_vc0_tcmap_pld           Output 7
   add_interface_port config_bypass    cfgbp_inh_dllp               cfgbp_inh_dllp                Output 1
   add_interface_port config_bypass    cfgbp_inh_tx_tlp             cfgbp_inh_tx_tlp              Output 1
   add_interface_port config_bypass    cfgbp_req_wake               cfgbp_req_wake                Output 1
   add_interface_port config_bypass    cfgbp_link3_ctl              cfgbp_link3_ctl               Output 2
   add_interface_port config_bypass    cfgbp_lane_err               cfgbp_lane_err                 Input 8
   add_interface_port config_bypass    cfgbp_link_equlz_req         cfgbp_link_equlz_req           Input 1
   add_interface_port config_bypass    cfgbp_equiz_complete         cfgbp_equiz_complete           Input 1
   add_interface_port config_bypass    cfgbp_phase_3_successful     cfgbp_phase_3_successful       Input 1
   add_interface_port config_bypass    cfgbp_phase_2_successful     cfgbp_phase_2_successful       Input 1
   add_interface_port config_bypass    cfgbp_phase_1_successful     cfgbp_phase_1_successful       Input 1
   add_interface_port config_bypass    cfgbp_current_deemph         cfgbp_current_deemph           Input 1
   add_interface_port config_bypass    cfgbp_current_speed          cfgbp_current_speed            Input 2
   add_interface_port config_bypass    cfgbp_link_up                cfgbp_link_up                  Input 1
   add_interface_port config_bypass    cfgbp_link_train             cfgbp_link_train               Input 1
   add_interface_port config_bypass    cfgbp_10state                cfgbp_10state                  Input 1
   add_interface_port config_bypass    cfgbp_10sstate               cfgbp_10sstate                 Input 1
   add_interface_port config_bypass    cfgbp_rx_val_pm              cfgbp_rx_val_pm                Input 1
   add_interface_port config_bypass    cfgbp_rx_typ_pm              cfgbp_rx_typ_pm                Input 3
   add_interface_port config_bypass    cfgbp_tx_ack_pm              cfgbp_tx_ack_pm                Input 1
   add_interface_port config_bypass    cfgbp_ack_phypm              cfgbp_ack_phypm                Input 2
   add_interface_port config_bypass    cfgbp_vc_status              cfgbp_vc_status                Input 1
   add_interface_port config_bypass    cfgbp_rxfc_max               cfgbp_rxfc_max                 Input 1
   add_interface_port config_bypass    cfgbp_txfc_max               cfgbp_txfc_max                 Input 1
   add_interface_port config_bypass    cfgbp_txbuf_emp              cfgbp_txbuf_emp                Input 1
   add_interface_port config_bypass    cfgbp_cfgbuf_emp             cfgbp_cfgbuf_emp               Input 1
   add_interface_port config_bypass    cfgbp_rpbuf_emp              cfgbp_rpbuf_emp                Input 1
   add_interface_port config_bypass    cfgbp_dll_req                cfgbp_dll_req                  Input 1
   add_interface_port config_bypass    cfgbp_link_auto_bdw_status   cfgbp_link_auto_bdw_status     Input 1
   add_interface_port config_bypass    cfgbp_link_bdw_mng_status    cfgbp_link_bdw_mng_status      Input 1
   add_interface_port config_bypass    cfgbp_rst_tx_margin_field    cfgbp_rst_tx_margin_field      Input 1
   add_interface_port config_bypass    cfgbp_rst_enter_comp_bit     cfgbp_rst_enter_comp_bit       Input 1
   add_interface_port config_bypass    cfgbp_rx_st_ecrcerr          cfgbp_rx_st_ecrcerr            Input 4
   add_interface_port config_bypass    cfgbp_err_uncorr_internal    cfgbp_err_uncorr_internal      Input 1
   add_interface_port config_bypass    cfgbp_rx_corr_internal       cfgbp_rx_corr_internal         Input 1
   add_interface_port config_bypass    cfgbp_err_tlrcvovf           cfgbp_err_tlrcvovf             Input 1
   add_interface_port config_bypass    cfgbp_txfc_err               cfgbp_txfc_err                 Input 1
   add_interface_port config_bypass    cfgbp_err_tlmalf             cfgbp_err_tlmalf               Input 1
   add_interface_port config_bypass    cfgbp_err_surpdwn_dll        cfgbp_err_surpdwn_dll          Input 1
   add_interface_port config_bypass    cfgbp_err_dllrev             cfgbp_err_dllrev               Input 1
   add_interface_port config_bypass    cfgbp_err_dll_repnum         cfgbp_err_dll_repnum           Input 1
   add_interface_port config_bypass    cfgbp_err_dllreptim          cfgbp_err_dllreptim            Input 1
   add_interface_port config_bypass    cfgbp_err_dllp_baddllp       cfgbp_err_dllp_baddllp         Input 1
   add_interface_port config_bypass    cfgbp_err_dll_badtlp         cfgbp_err_dll_badtlp           Input 1
   add_interface_port config_bypass    cfgbp_err_phy_tng            cfgbp_err_phy_tng              Input 1
   add_interface_port config_bypass    cfgbp_err_phy_rcv            cfgbp_err_phy_rcv              Input 1
   add_interface_port config_bypass    cfgbp_root_err_reg_sts       cfgbp_root_err_reg_sts         Input 1
   add_interface_port config_bypass    cfgbp_corr_err_reg_sts       cfgbp_corr_err_reg_sts         Input 1
   add_interface_port config_bypass    cfgbp_unc_err_reg_sts        cfgbp_unc_err_reg_sts          Input 1
}


# ************** Global Variables ***************
set not_init "default"
# **************** Parameters *******************


proc proc_quartus_synth {name} {
   global env
   set QUARTUS_ROOTDIR $env(QUARTUS_ROOTDIR)
   source ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_sv_hip_ast/pcie_sv_parameters_common.tcl
   
   add_fileset_file altpcied_cfbp_app_example.sv      SYSTEMVERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/altera_pcie_cfgbp_ed/altpcied_cfbp_app_example.sv
   add_fileset_file altera_pci_express.sdc              SDC         PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/altera_pcie_cfgbp_ed/altera_pci_express.sdc
   add_fileset_file altpcierd_hip_rs.v                VERILOG       PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/example_design/verilog/chaining_dma/altpcierd_hip_rs.v
   add_fileset_file altpcierd_cplerr_lmi.v            VERILOG       PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/example_design/verilog/chaining_dma/altpcierd_cplerr_lmi.v
   add_fileset_file altpcied_cfbp_64b_control.v       VERILOG       PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/altera_pcie_cfgbp_ed/verilog/altpcied_cfbp_64b_control.v
   add_fileset_file altpcied_cfbp_128b_control.v      VERILOG       PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/altera_pcie_cfgbp_ed/verilog/altpcied_cfbp_128b_control.v
   add_fileset_file altpcied_cfbp_256b_control.v      VERILOG       PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/altera_pcie_cfgbp_ed/verilog/altpcied_cfbp_256b_control.v
   add_fileset_file altpcied_cfbp_target.v            VERILOG       PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/altera_pcie_cfgbp_ed/verilog/altpcied_cfbp_target.v
   add_fileset_file altpcied_cfbp_cfgspace.v          VERILOG       PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/altera_pcie_cfgbp_ed/verilog/altpcied_cfbp_cfgspace.v
   add_fileset_file altpcied_cfbp_multifunc.v         VERILOG       PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/altera_pcie_cfgbp_ed/verilog/altpcied_cfbp_multifunc.v
   add_fileset_file altpcied_cfbp_top.v               VERILOG       PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/altera_pcie_cfgbp_ed/verilog/altpcied_cfbp_top.v


}

proc proc_sim_verilog {name} {
   global env
   set QUARTUS_ROOTDIR $env(QUARTUS_ROOTDIR)
   source ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_sv_hip_ast/pcie_sv_parameters_common.tcl

   add_fileset_file altpcied_cfbp_app_example.sv     SYSTEMVERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/altera_pcie_cfgbp_ed/altpcied_cfbp_app_example.sv
   add_fileset_file altpcierd_hip_rs.v                VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/example_design/verilog/chaining_dma/altpcierd_hip_rs.v
   add_fileset_file altpcierd_cplerr_lmi.v            VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/example_design/verilog/chaining_dma/altpcierd_cplerr_lmi.v
   add_fileset_file altpcied_cfbp_64b_control.v       VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/altera_pcie_cfgbp_ed/verilog/altpcied_cfbp_64b_control.v
   add_fileset_file altpcied_cfbp_128b_control.v      VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/altera_pcie_cfgbp_ed/verilog/altpcied_cfbp_128b_control.v
   add_fileset_file altpcied_cfbp_256b_control.v      VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/altera_pcie_cfgbp_ed/verilog/altpcied_cfbp_256b_control.v
   add_fileset_file altpcied_cfbp_target.v            VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/altera_pcie_cfgbp_ed/verilog/altpcied_cfbp_target.v
   add_fileset_file altpcied_cfbp_cfgspace.v          VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/altera_pcie_cfgbp_ed/verilog/altpcied_cfbp_cfgspace.v
   add_fileset_file altpcied_cfbp_multifunc.v         VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/altera_pcie_cfgbp_ed/verilog/altpcied_cfbp_multifunc.v
   add_fileset_file altpcied_cfbp_top.v               VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/altera_pcie_cfgbp_ed/verilog/altpcied_cfbp_top.v

   add_fileset_file altpcietb_bfm_cfbp.v              VERILOG_INCLUDE PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/altera_pcie_cfgbp_ed/sim_bfm/altpcietb_bfm_cfbp.v

   # The following files are needed for Gen3 RP BFM. These files are listed in altera_pcie_hip_ast_ed_hw.tcl
   add_fileset_file altpcied_sv_hwtcl.sv          SYSTEMVERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/altpcied_sv_hwtcl.sv
   add_fileset_file altpcierd_tl_cfg_sample.v           VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/example_design/verilog/chaining_dma/altpcierd_tl_cfg_sample.v
   add_fileset_file altpcierd_ast256_downstream.v       VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/example_design/verilog/chaining_dma/altpcierd_ast256_downstream.v
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
}


proc proc_sim_vhdl {name} {
   global env
   set QUARTUS_ROOTDIR $env(QUARTUS_ROOTDIR)
   source ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_sv_hip_ast/pcie_sv_parameters_common.tcl

   add_fileset_file altpcied_cfbp_app_example.sv     SYSTEMVERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/altera_pcie_cfgbp_ed/altpcied_cfbp_app_example.sv
   add_fileset_file altpcierd_hip_rs.v                VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/example_design/verilog/chaining_dma/altpcierd_hip_rs.v
   add_fileset_file altpcierd_cplerr_lmi.v            VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/example_design/verilog/chaining_dma/altpcierd_cplerr_lmi.v
   add_fileset_file altpcied_cfbp_64b_control.v       VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/altera_pcie_cfgbp_ed/verilog/altpcied_cfbp_64b_control.v
   add_fileset_file altpcied_cfbp_128b_control.v      VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/altera_pcie_cfgbp_ed/verilog/altpcied_cfbp_128b_control.v
   add_fileset_file altpcied_cfbp_256b_control.v      VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/altera_pcie_cfgbp_ed/verilog/altpcied_cfbp_256b_control.v
   add_fileset_file altpcied_cfbp_target.v            VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/altera_pcie_cfgbp_ed/verilog/altpcied_cfbp_target.v
   add_fileset_file altpcied_cfbp_cfgspace.v          VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/altera_pcie_cfgbp_ed/verilog/altpcied_cfbp_cfgspace.v
   add_fileset_file altpcied_cfbp_multifunc.v         VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/altera_pcie_cfgbp_ed/verilog/altpcied_cfbp_multifunc.v
   add_fileset_file altpcied_cfbp_top.v               VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/altera_pcie_cfgbp_ed/verilog/altpcied_cfbp_top.v

   add_fileset_file altpcietb_bfm_cfbp.v              VERILOG_INCLUDE PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/altera_pcie_cfgbp_ed/sim_bfm/altpcietb_bfm_cfbp.v

   # The following files are needed for Gen3 RP BFM. These files are listed in altera_pcie_hip_ast_ed_hw.tcl
   add_fileset_file altpcied_sv_hwtcl.sv          SYSTEMVERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/altpcied_sv_hwtcl.sv
   add_fileset_file altpcierd_tl_cfg_sample.v           VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/example_design/verilog/chaining_dma/altpcierd_tl_cfg_sample.v
   add_fileset_file altpcierd_ast256_downstream.v       VERILOG PATH ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_hip_ast_ed/example_design/verilog/chaining_dma/altpcierd_ast256_downstream.v
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
}

####################################################################################################
#
# add_to_no_connect signal_name:string signal_width:int direction:string
#  tied internal signal to
#     - open (when output of the instance)
#     - GND (input of the instance)
#
proc add_to_no_connect { signal_name signal_width direction } {
#send_message debug "proc add_to_no_connect $signal_name $signal_width $direction"
   add_interface no_connect conduit end
   if { [ regexp In $direction ] } {
      add_interface_port no_connect $signal_name $signal_name Input $signal_width
      set_port_property $signal_name TERMINATION true
      set_port_property $signal_name TERMINATION_VALUE 0
   } else {
      add_interface_port no_connect $signal_name $signal_name Output $signal_width
      set_port_property  $signal_name TERMINATION true
   }
}

####################################################################################################
#
# Derived Parameters
#
####################################################################################################
proc validation_parameter_system_setting {} {
   set ast_width_hwtcl  [ get_parameter_value ast_width_hwtcl]

   # Setting AST Port width parameters
   set dataWidth        [ expr [ regexp 256 $ast_width_hwtcl  ] ? 256 : [ regexp 128 $ast_width_hwtcl ] ? 128 : 64 ]
   set dataByteWidth    [ expr [ regexp 256 $ast_width_hwtcl  ] ? 32  : [ regexp 128 $ast_width_hwtcl ] ? 16 : 8 ]
   set dataEmptyWidth   [ expr [ regexp 256 $ast_width_hwtcl  ] ? 2  : 1 ]

   set_parameter_value port_width_data_hwtcl      $dataWidth
   set_parameter_value port_width_be_hwtcl        $dataByteWidth

}
