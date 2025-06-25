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


####################################################################################################
#
# Design Example Clock conduit
#
proc add_rdpcie_port_clk {} {

   send_message debug "proc:add_rdpcie_port_clk"

   add_interface coreclkout_hip clock end
   add_interface_port coreclkout_hip coreclkout_hip clk Input 1

   add_interface pld_clk_hip clock start
   add_interface_port pld_clk_hip pld_clk_hip clk Output 1
   set pld_clockrate_hwtcl [ get_parameter_value pld_clockrate_hwtcl ]
   set_interface_property pld_clk_hip clockRate $pld_clockrate_hwtcl

}


####################################################################################################
#
# Design Example Reset conduit
#
proc add_ed_sriov_port_rst {} {

   send_message debug "proc:add_ed_sriov_port_rst"

   add_interface hip_rst conduit end
   add_interface_port hip_rst reset_status   reset_status  Input 1
   add_interface_port hip_rst serdes_pll_locked   serdes_pll_locked  Input 1
   add_interface_port hip_rst pld_clk_inuse  pld_clk_inuse Input 1
   add_interface_port hip_rst pld_core_ready pld_core_ready     Output 1
   add_interface_port hip_rst testin_zero    testin_zero   Input 1

   set port_type_hwtcl  [ get_parameter_value port_type_hwtcl ]

   if  { [ regexp Root $port_type_hwtcl ] } {
      add_interface_port hip_rst    sim_pipe_pclk_out sim_pipe_pclk_out Input 1
   } else {
      add_interface_port no_connect sim_pipe_pclk_out sim_pipe_pclk_out Input 1
      set_port_property             sim_pipe_pclk_out TERMINATION true
      set_port_property             sim_pipe_pclk_out TERMINATION_VALUE 0
   }
}


####################################################################################################
#
# Design Example Status conduit
#
proc add_ed_sriov_port_status {} {

   send_message debug "proc:add_ed_sriov_port_status"
   set number_of_func_hwtcl [ get_parameter_value num_of_func_hwtcl ]
   set dev_family [get_parameter_value device_family_hwtcl ]
   set track_rxfc_cplbuf_ovf_hwtcl [get_parameter_value track_rxfc_cplbuf_ovf_hwtcl]

   add_interface hip_status conduit end
   add_interface_port hip_status derr_cor_ext_rcv   derr_cor_ext_rcv   Input 1
   add_interface_port hip_status derr_cor_ext_rpl   derr_cor_ext_rpl   Input 1
   add_interface_port hip_status derr_rpl           derr_rpl           Input 1
   add_interface_port hip_status dlup_exit          dlup_exit          Input 1
   add_interface_port hip_status ev128ns            ev128ns            Input 1
   add_interface_port hip_status ev1us              ev1us              Input 1
   add_interface_port hip_status hotrst_exit        hotrst_exit        Input 1
   add_interface_port hip_status int_status         int_status         Input 4
   add_interface_port hip_status l2_exit            l2_exit            Input 1
   add_interface_port hip_status lane_act           lane_act           Input 4
   add_interface_port hip_status ltssmstate         ltssmstate         Input 5

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

   if { $dev_family == "Arria V" || $dev_family == "Cyclone V" } {
      add_to_no_connect  dlup 1 In
      add_to_no_connect  rx_par_err  1 In
      add_to_no_connect  tx_par_err  2 In
      add_to_no_connect  cfg_par_err 1 In
   } else {
      add_interface_port hip_status     dlup               dlup               Input 1
      # Parity error
      add_interface_port hip_status     rx_par_err         rx_par_err         Input 1
      add_interface_port hip_status	tx_par_err         tx_par_err         Input 2
      add_interface_port hip_status	cfg_par_err        cfg_par_err        Input 1

      add_interface_port hip_status_drv dlup_drv           dlup               Output 1
      # Parity error
      add_interface_port hip_status_drv rx_par_err_drv     rx_par_err         Output 1
      add_interface_port hip_status_drv tx_par_err_drv     tx_par_err         Output 2
      add_interface_port hip_status_drv cfg_par_err_drv    cfg_par_err        Output 1
   }

   # Completion space information
   add_interface_port hip_status     ko_cpl_spc_header	   ko_cpl_spc_header Input 8
   add_interface_port hip_status     ko_cpl_spc_data	   ko_cpl_spc_data   Input 12
   add_interface_port hip_status_drv ko_cpl_spc_header_drv ko_cpl_spc_header Output 8
   add_interface_port hip_status_drv ko_cpl_spc_data_drv   ko_cpl_spc_data   Output 12


   if { $track_rxfc_cplbuf_ovf_hwtcl == 1 } {
      add_interface_port  hip_status rxfc_cplbuf_ovf rxfc_cplbuf_ovf Input 1
   } else {
      add_to_no_connect rxfc_cplbuf_ovf     1     In
   }

}



####################################################################################################
#
# Avalon-ST RX
#
proc add_ed_sriov_port_ast_rx {} {

   send_message debug "proc:add_ed_sriov_port_ast_rx"
   set number_of_func_hwtcl [ get_parameter_value num_of_func_hwtcl ]
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
         add_interface_port rx_st rx_st_empty empty Input 2
         set_port_property  rx_st_empty VHDL_TYPE std_logic_vector
   } else {
         add_to_no_connect rx_st_empty 1 In
   }
   add_interface_port rx_st rx_st_ready ready Output 1
   add_interface_port rx_st rx_st_data data Input $dataWidth
   # Parity
   if { $ast_parity == 0 } {
      add_to_no_connect rx_st_parity $dataByteWidth Input
   } else {
      add_interface_port rx_st rx_st_parity parity Input $dataByteWidth
   }

   # Rx st mask
   add_interface_port rx_st rx_st_mask rx_st_mask Output 1

   #===================================
   # rx_bar_hit I/O
   #===================================
   add_interface rx_bar_hit conduit end
   add_interface_port rx_bar_hit rx_st_bar_hit_tlp0    rx_st_bar_hit_tlp0     Input 8
   add_interface_port rx_bar_hit rx_st_bar_hit_fn_tlp0 rx_st_bar_hit_fn_tlp0  Input 8
   add_interface_port rx_bar_hit rx_st_bar_hit_tlp1    rx_st_bar_hit_tlp1     Input 8
   add_interface_port rx_bar_hit rx_st_bar_hit_fn_tlp1 rx_st_bar_hit_fn_tlp1  Input 8

}

####################################################################################################
#
# Avalon-ST TX
#
proc add_ed_sriov_port_ast_tx {} {

   send_message debug "proc:add_ed_sriov_port_ast_tx"
   set number_of_func_hwtcl [ get_parameter_value num_of_func_hwtcl ]
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
      add_interface_port tx_fifo tx_fifo_empty fifo_empty Input 1
   } else {
      add_interface_port no_connect tx_fifo_empty fifo_empty Input 1
      set_port_property             tx_fifo_empty TERMINATION true
      set_port_property             tx_fifo_empty TERMINATION_VALUE 1
   }

   # Credit Information
   add_interface tx_cred conduit end
   add_interface_port tx_cred tx_cred_datafccp    tx_cred_datafccp    Input 12
   add_interface_port tx_cred tx_cred_datafcnp    tx_cred_datafcnp    Input 12
   add_interface_port tx_cred tx_cred_datafcp     tx_cred_datafcp     Input 12
   add_interface_port tx_cred tx_cred_fchipcons   tx_cred_fchipcons   Input 6
   add_interface_port tx_cred tx_cred_fcinfinite  tx_cred_fcinfinite  Input 6
   add_interface_port tx_cred tx_cred_hdrfccp     tx_cred_hdrfccp     Input 8
   add_interface_port tx_cred tx_cred_hdrfcnp     tx_cred_hdrfcnp     Input 8
   add_interface_port tx_cred tx_cred_hdrfcp      tx_cred_hdrfcp      Input 8

}

####################################################################################################
#
# Interrupt interface conduit
#
proc add_ed_sriov_port_interrupt {} {

   send_message debug "proc:add_ed_sriov_port_interrupt"
   set VF_COUNT [ get_parameter_value VF_COUNT]

   add_interface int_msi conduit end

   add_interface_port int_msi app_msi_req    app_msi_req    Output  1
   add_interface_port int_msi app_msi_ack    app_msi_ack    Input 1
   add_interface_port int_msi app_msi_req_fn app_msi_req_fn Output  8
   add_interface_port int_msi app_msi_num    app_msi_num    Output  5
   add_interface_port int_msi app_msi_tc     app_msi_tc     Output  3

   add_interface_port int_msi app_msi_enable_pf               app_msi_enable_pf             Input 1
   add_interface_port int_msi app_msi_multi_msg_enable_pf     app_msi_multi_msg_enable_pf   Input 3
   add_interface_port int_msi app_msi_enable_vf               app_msi_enable_vf             Input $VF_COUNT
   add_interface_port int_msi app_msi_multi_msg_enable_vf     app_msi_multi_msg_enable_vf   Input $VF_COUNT*3
   add_interface_port int_msi app_msix_en_pf                  app_msix_en_pf                Input 1
   add_interface_port int_msi app_msix_fn_mask_pf             app_msix_fn_mask_pf           Input 1
   add_interface_port int_msi app_msix_en_vf                  app_msix_en_vf                Input $VF_COUNT
   add_interface_port int_msi app_msix_fn_mask_vf             app_msix_fn_mask_vf           Input $VF_COUNT

   add_interface_port int_msi app_int_ack    app_int_ack        Input   1
   add_interface_port int_msi app_int_sts_a  app_int_sts_a      Output  1
   add_interface_port int_msi app_int_sts_b  app_int_sts_b      Output  1
   add_interface_port int_msi app_int_sts_c  app_int_sts_c      Output  1
   add_interface_port int_msi app_int_sts_d  app_int_sts_d      Output  1
   add_interface_port int_msi app_int_sts_fn app_int_sts_fn     Output  3

   add_interface_port int_msi app_int_pend_status app_int_pend_status Output 1
   add_interface_port int_msi app_intx_disable app_intx_disable       Input  1

}


####################################################################################################
#
# LMI interface conduit 
#
proc add_ed_sriov_port_lmi {} {

   send_message debug "proc:add_ed_sriov_port_lmi"

   add_interface lmi conduit end

   add_interface_port lmi lmi_addr lmi_addr  Output  12
   add_interface_port lmi lmi_func lmi_func  Output  9
   add_interface_port lmi lmi_din  lmi_din   Output  32
   add_interface_port lmi lmi_rden lmi_rden  Output  1
   add_interface_port lmi lmi_wren lmi_wren  Output  1
   add_interface_port lmi lmi_ack  lmi_ack   Input 1
   add_interface_port lmi lmi_dout lmi_dout  Input 32
}

#####################################################################################################
#
# HIP control
#
proc add_ed_sriov_port_hip_misc {} {

   send_message debug "proc:add_ed_sriov_port_hip_misc"
   set number_of_func_hwtcl [ get_parameter_value num_of_func_hwtcl ]
   set dev_family [get_parameter_value device_family_hwtcl ]

   add_interface      hip_misc conduit end
   add_interface_port hip_misc hpg_ctrler     hpg_ctrler      Output  5

}

################################################################################################
#
# Completion Status Signals from user application
#
proc add_ed_sriov_port_completion {} {

   send_message debug "proc: add_ed_sriov_port_completion"
   set VF_COUNT [ get_parameter_value VF_COUNT]

   add_interface      hip_completion conduit end
   add_interface_port hip_completion cpl_err         cpl_err        Output  7
   add_interface_port hip_completion cpl_err_fn      cpl_err_fn     Output 8
   add_interface_port hip_completion cpl_pending_pf  cpl_pending_pf Output 1
   add_interface_port hip_completion cpl_pending_vf  cpl_pending_vf Output $VF_COUNT
   add_interface_port hip_completion log_hdr         log_hdr        Output 128

  #set_interface_assignment hip_completion "ui.blockdiagram.direction" "output"

}

####################################################################################################
#
# Config-Status interface conduit 
#
proc add_ed_sriov_port_cfgstatus {} {

   send_message debug "proc:add_ed_sriov_port_cfgstatus"
   set VF_COUNT [ get_parameter_value VF_COUNT]

   add_interface cfg_status conduit end

   add_interface_port cfg_status  bus_num_f0        bus_num_f0         Input  8
   add_interface_port cfg_status  device_num_f0     device_num_f0      Input  5
   add_interface_port cfg_status  mem_space_en_pf   mem_space_en_pf    Input  1
   add_interface_port cfg_status  bus_master_en_pf  bus_master_en_pf   Input  1
   add_interface_port cfg_status  mem_space_en_vf   mem_space_en_vf    Input  1
   add_interface_port cfg_status  bus_master_en_vf  bus_master_en_vf   Input  $VF_COUNT
   add_interface_port cfg_status  num_vfs           num_vfs            Input  8
   add_interface_port cfg_status  max_payload_size  max_payload_size   Input  3
   add_interface_port cfg_status  rd_req_size       rd_req_size        Input  3
}

##############################################################################################
#
# Functional_level reset
#
proc add_ed_sriov_port_flr {} {

   send_message debug "proc: add_ed_sriov_port_flr"
   set VF_COUNT [ get_parameter_value VF_COUNT]

   add_interface flr conduit end
   add_interface_port flr  flr_active_pf     flr_active_pf     Input   1
   add_interface_port flr  flr_active_vf     flr_active_vf     Input   $VF_COUNT
   add_interface_port flr  flr_completed_pf  flr_completed_pf  Output  1
   add_interface_port flr  flr_completed_vf  flr_completed_vf  Output  $VF_COUNT
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
   if { [ regexp In $direction ] } {
      add_interface_port no_connect $signal_name $signal_name Input $signal_width
      set_port_property $signal_name TERMINATION true
      set_port_property $signal_name TERMINATION_VALUE 0
   } else {
      add_interface_port no_connect $signal_name $signal_name Output $signal_width
      set_port_property  $signal_name TERMINATION true
   }
}
