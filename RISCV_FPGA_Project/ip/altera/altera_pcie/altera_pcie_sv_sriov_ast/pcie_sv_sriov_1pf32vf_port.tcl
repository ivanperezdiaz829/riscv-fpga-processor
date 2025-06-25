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
# HIP Clock conduit
#
proc add_pcie_sriov_port_clk {} {

   send_message debug "proc:add_pcie_sriov_port_clk"

   add_interface pld_clk clock end
   add_interface_port pld_clk pld_clk clk Input 1
   set pld_clk_MHz [ get_parameter_value pld_clk_MHz ]
   set_interface_property pld_clk clockRate [expr {$pld_clk_MHz * 100000}]

   add_interface coreclkout_hip clock start
   add_interface_port coreclkout_hip coreclkout_hip clk Output 1
   set_interface_property coreclkout_hip clockRate [expr {$pld_clk_MHz * 100000}]

   add_interface refclk clock end
   add_interface_port refclk refclk clk Input 1
   set pll_refclk_freq  [ get_parameter_value pll_refclk_freq_hwtcl]
   set refclk_hz        [ expr [ regexp 125 $pll_refclk_freq  ] ? 125000000 :  100000000 ]
   set_interface_property refclk clockRate $refclk_hz

}


####################################################################################################
#
# Power on reset
#
proc add_pcie_hip_port_npor {} {
   add_interface npor conduit end
   add_interface_port npor npor npor Input 1
   add_interface_port npor pin_perst pin_perst Input 1
}

####################################################################################################
#
# reconfig interface
#
proc add_pcie_sriov_port_reconfig {} {

   send_message debug "proc:add_pcie_sriov_port_reconfig"
   add_interface reconfig_to_xcvr     conduit end
   set reconfig_to_xcvr_width        [ get_parameter_value reconfig_to_xcvr_width ]
   add_interface_port reconfig_to_xcvr    reconfig_to_xcvr reconfig_to_xcvr Input $reconfig_to_xcvr_width
   set_interface_assignment reconfig_to_xcvr "ui.blockdiagram.direction" "output"

   add_interface reconfig_from_xcvr  conduit end
   set reconfig_from_xcvr_width      [ get_parameter_value reconfig_from_xcvr_width ]
   add_interface_port reconfig_from_xcvr  reconfig_from_xcvr reconfig_from_xcvr Output $reconfig_from_xcvr_width
}

####################################################################################################
#
# HIP Reset conduit
#
proc add_pcie_sriov_port_rst {} {

   send_message debug "proc:add_pcie_sriov_port_rst"

   add_interface hip_rst conduit end
   add_interface_port hip_rst reset_status    reset_status     Output 1
   add_interface_port hip_rst serdes_pll_locked serdes_pll_locked   Output 1
   add_interface_port hip_rst pld_clk_inuse   pld_clk_inuse    Output 1
   add_interface_port hip_rst pld_core_ready  pld_core_ready   Input  1
   add_interface_port hip_rst testin_zero     testin_zero    Output 1

   set port_type_hwtcl  [ get_parameter_value port_type_hwtcl ]

   if  { [ regexp Root $port_type_hwtcl ] } {
      add_interface_port hip_rst   sim_pipe_pclk_out    sim_pipe_pclk_out     Output 1
   } else {
      add_to_no_connect sim_pipe_pclk_out 1 Out
   }

}

####################################################################################################
#
# HIP Control conduit
#
proc add_pcie_sriov_port_control {} {

   send_message debug "proc:add_pcie_sriov_port_control"

   set enable_tl_only_sim_hwtcl   [ get_parameter_value enable_tl_only_sim_hwtcl ]

   add_interface hip_ctrl conduit end
   add_interface_port hip_ctrl test_in             test_in Input 32
   add_interface_port hip_ctrl reservedin          reservedin Input 32
   add_to_no_connect reservedin     32    In
   add_interface_port hip_ctrl simu_mode_pipe      simu_mode_pipe Input 1
   if { $enable_tl_only_sim_hwtcl == 1 } {
      add_interface_port hip_ctrl   tlbfm_in    tlbfm_in  Output 1001
      add_interface_port hip_ctrl   tlbfm_out   tlbfm_out  Input 1001
   } else {
      add_to_no_connect tlbfm_in    1001     Out
      add_to_no_connect tlbfm_out   1001     In
   }

}

####################################################################################################
#
# HIP Status conduit
#
proc add_pcie_sriov_port_status {} {

   send_message debug "proc:add_pcie_sriov_port_status"

   set track_rxfc_cplbuf_ovf_hwtcl   [ get_parameter_value track_rxfc_cplbuf_ovf_hwtcl ]

   add_interface hip_status conduit end
   add_interface_port hip_status derr_cor_ext_rcv   derr_cor_ext_rcv    Output 1
   add_interface_port hip_status derr_cor_ext_rpl   derr_cor_ext_rpl    Output 1
   add_interface_port hip_status derr_rpl           derr_rpl            Output 1
   add_interface_port hip_status dlup               dlup                Output 1
   add_interface_port hip_status dlup_exit          dlup_exit           Output 1
   add_interface_port hip_status ev128ns            ev128ns             Output 1
   add_interface_port hip_status ev1us              ev1us               Output 1
   add_interface_port hip_status hotrst_exit        hotrst_exit         Output 1
   add_interface_port hip_status int_status         int_status          Output 4
   add_interface_port hip_status l2_exit            l2_exit             Output 1
   add_interface_port hip_status lane_act           lane_act            Output 4
   add_interface_port hip_status ltssmstate         ltssmstate          Output 5

   # Parity error
   add_interface_port hip_status rx_par_err rx_par_err                  Output 1
   add_interface_port hip_status tx_par_err tx_par_err                  Output 2
   add_interface_port hip_status cfg_par_err cfg_par_err                Output 1

   # Completion space information
   add_interface_port hip_status ko_cpl_spc_header ko_cpl_spc_header    Output 8
   add_interface_port hip_status ko_cpl_spc_data   ko_cpl_spc_data      Output 12

   if { $track_rxfc_cplbuf_ovf_hwtcl == 1 } {
      add_interface_port  hip_status rxfc_cplbuf_ovf rxfc_cplbuf_ovf Output 1
   } else {
      add_to_no_connect rxfc_cplbuf_ovf     1     Out
   }

   add_interface hip_currentspeed conduit end
   add_interface_port hip_currentspeed currentspeed currentspeed Output 2

   set_interface_assignment hip_status "ui.blockdiagram.direction" "output"

}



####################################################################################################
#
# Avalon-ST RX
#
proc add_pcie_sriov_port_ast_rx {} {

   send_message debug "proc:add_pcie_sriov_port_ast_rx"

   set ast_width_hwtcl                    [ get_parameter_value ast_width_hwtcl]
   set ast_parity                         [ get_parameter_value use_ast_parity ]
   set dataWidth                          [ expr [ regexp 256 $ast_width_hwtcl  ] ? 256 : [ regexp 128 $ast_width_hwtcl ] ? 128 : 64 ]
   set dataByteWidth                      [ expr [ regexp 256 $ast_width_hwtcl  ] ? 32  : [ regexp 128 $ast_width_hwtcl ] ? 16 : 8 ]
   set multiple_packets_per_cycle_hwtcl   [ get_parameter_value multiple_packets_per_cycle_hwtcl]


   # Avalon-stream RX HIP
   # indicates that AST symbols ordering is little endian instead of Big endian
   # set_interface_property rx_st highOrderSymbolAtMSB false
   add_interface rx_st avalon_streaming start
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
   set_interface_property rx_st ASSOCIATED_CLOCK pld_clk
   if { $multiple_packets_per_cycle_hwtcl == 1 } {
      add_interface_port rx_st rx_st_sop startofpacket Output 2
      add_interface_port rx_st rx_st_eop endofpacket Output 2
      add_interface_port rx_st rx_st_err error Output 2
      add_interface_port rx_st rx_st_valid valid Output 2
   } else {
      add_interface_port rx_st rx_st_sop startofpacket Output 1
      add_interface_port rx_st rx_st_eop endofpacket Output 1
      add_interface_port rx_st rx_st_err error Output 1
      add_interface_port rx_st rx_st_valid valid Output 1
   }
   set_port_property rx_st_sop VHDL_TYPE std_logic_vector
   set_port_property rx_st_eop VHDL_TYPE std_logic_vector
   set_port_property rx_st_err VHDL_TYPE std_logic_vector
   set_port_property rx_st_valid VHDL_TYPE std_logic_vector
   if { $dataWidth > 64 } {
      add_interface_port rx_st rx_st_empty empty Output 2
   } else {
      add_to_no_connect rx_st_empty 1 Out
   }
   add_interface_port rx_st rx_st_ready ready Input 1
   add_interface_port rx_st rx_st_data data Output $dataWidth
   # AST Parity
   if { $ast_parity == 0 } {
      add_to_no_connect rx_st_parity $dataByteWidth Out
   } else {
      add_interface_port rx_st rx_st_parity parity Output $dataByteWidth
   }

   add_interface_port rx_st rx_st_mask rx_st_mask Input 1

   #===================================
   # rx_bar_hit I/O
   #===================================
   add_interface rx_bar_hit conduit end
   add_interface_port rx_bar_hit rx_st_bar_hit_tlp0    rx_st_bar_hit_tlp0     Output 8
   add_interface_port rx_bar_hit rx_st_bar_hit_fn_tlp0 rx_st_bar_hit_fn_tlp0  Output 8
   add_interface_port rx_bar_hit rx_st_bar_hit_tlp1    rx_st_bar_hit_tlp1     Output 8
   add_interface_port rx_bar_hit rx_st_bar_hit_fn_tlp1 rx_st_bar_hit_fn_tlp1  Output 8

   # rx_bar_be combines the HIP Bar decode signal with the HIP RX_DATA_BE
   # which are not avalon-st but synchronous to the rx_st_data bus
   # BAR Decode output
 #  add_interface rx_bar_be conduit end
 #  add_interface_port rx_bar_be rx_st_bar rx_st_bar  Output 8
 #  # Byte enable
 #  set use_rx_st_be_hwtcl [ get_parameter_value use_rx_st_be_hwtcl ]
 #  if { $use_rx_st_be_hwtcl == 0 } {
 #     add_to_no_connect rx_st_be $dataByteWidth Out
 #  } else {
 #     add_interface_port rx_bar_be rx_st_be rx_st_be  Output $dataByteWidth
 #  }
 #  # rx_st_mask
 #  add_interface_port rx_bar_be rx_st_mask rx_st_mask Input 1
 #  set_interface_assignment rx_bar_be "ui.blockdiagram.direction" "output"
}

####################################################################################################
#
# Avalon-ST TX
#
proc add_pcie_sriov_port_ast_tx {} {

   send_message debug "proc:add_pcie_sriov_port_ast_tx"

   set ast_width_hwtcl                    [ get_parameter_value ast_width_hwtcl]
   set ast_parity                         [ get_parameter_value use_ast_parity ]
   set dataWidth                          [ expr [ regexp 256 $ast_width_hwtcl  ] ? 256 : [ regexp 128 $ast_width_hwtcl ] ? 128 : 64 ]
   set dataByteWidth                      [ expr [ regexp 256 $ast_width_hwtcl  ] ? 32  : [ regexp 128 $ast_width_hwtcl ] ? 16 : 8 ]
   set multiple_packets_per_cycle_hwtcl   [ get_parameter_value multiple_packets_per_cycle_hwtcl]
   set use_tx_cons_cred_sel_hwtcl    [ get_parameter_value use_tx_cons_cred_sel_hwtcl ]

   # AST TX
   # indicates that AST symbols ordering is little endian instead of Big endian
   # set_interface_property tx_st highOrderSymbolAtMSB false
   add_interface tx_st avalon_streaming end
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
   set_interface_property tx_st ASSOCIATED_CLOCK pld_clk
   if { $multiple_packets_per_cycle_hwtcl == 1 } {
      add_interface_port tx_st tx_st_sop startofpacket Input 2
      add_interface_port tx_st tx_st_eop endofpacket Input 2
      add_interface_port tx_st tx_st_err error Input 2
      add_interface_port tx_st tx_st_valid valid Input 2
   } else {
      add_interface_port tx_st tx_st_sop startofpacket Input 1
      add_interface_port tx_st tx_st_eop endofpacket Input 1
      add_interface_port tx_st tx_st_err error Input 1
      add_interface_port tx_st tx_st_valid valid Input 1
   }
   set_port_property tx_st_sop VHDL_TYPE std_logic_vector
   set_port_property tx_st_eop VHDL_TYPE std_logic_vector
   set_port_property tx_st_err VHDL_TYPE std_logic_vector
   set_port_property tx_st_valid VHDL_TYPE std_logic_vector
   if { $dataWidth > 64 } {
      add_interface_port tx_st tx_st_empty empty Input 2
   } else {
      add_to_no_connect tx_st_empty 2 In
   }
   add_interface_port tx_st tx_st_ready ready Output 1
   add_interface_port tx_st tx_st_data data Input $dataWidth
   # Parity
   if { $ast_parity == 0 } {
      add_to_no_connect tx_st_parity $dataByteWidth In
   } else {
      add_interface_port tx_st tx_st_parity parity Input $dataByteWidth
   }

   # Credit Information
   add_interface tx_cred conduit end
   add_interface_port tx_cred tx_cred_datafccp    tx_cred_datafccp    Output 12
   add_interface_port tx_cred tx_cred_datafcnp    tx_cred_datafcnp    Output 12
   add_interface_port tx_cred tx_cred_datafcp     tx_cred_datafcp     Output 12
   add_interface_port tx_cred tx_cred_fchipcons   tx_cred_fchipcons   Output 6
   add_interface_port tx_cred tx_cred_fcinfinite  tx_cred_fcinfinite  Output 6
   add_interface_port tx_cred tx_cred_hdrfccp     tx_cred_hdrfccp     Output 8
   add_interface_port tx_cred tx_cred_hdrfcnp     tx_cred_hdrfcnp     Output 8
   add_interface_port tx_cred tx_cred_hdrfcp      tx_cred_hdrfcp      Output 8
   if { $use_tx_cons_cred_sel_hwtcl == 1 } {
      add_interface_port tx_cred tx_cons_cred_sel  tx_cons_cred_sel  Input 1
   } else {
      add_to_no_connect tx_cons_cred_sel 1 In
   }

}

####################################################################################################
#
# Pipe interface conduit
#
proc add_pcie_sriov_port_pipe {} {

   send_message debug "proc:add_pcie_sriov_port_pipe"

   set lane_mask_hwtcl  [ get_parameter_value lane_mask_hwtcl]
   set nlane [ expr [ regexp x8 $lane_mask_hwtcl  ] ? 8 : [ regexp x4 $lane_mask_hwtcl ] ? 4 :  [ regexp x2 $lane_mask_hwtcl ] ? 2 : 1 ]

   add_interface hip_pipe conduit end

   # clock and rate signals for pipe simulation only
   add_interface_port hip_pipe sim_pipe_pclk_in sim_pipe_pclk_in Input 1
   add_interface_port hip_pipe sim_pipe_rate    sim_pipe_rate    Output 2
   add_interface_port hip_pipe sim_ltssmstate   sim_ltssmstate   Output 5
   set_interface_assignment hip_pipe "ui.blockdiagram.direction" "output"

   if { $nlane == 1 } {
      add_interface_port hip_pipe eidleinfersel0 eidleinfersel0  Output 3
      add_to_no_connect eidleinfersel1 3 Out
      add_to_no_connect eidleinfersel2 3 Out
      add_to_no_connect eidleinfersel3 3 Out
      add_to_no_connect eidleinfersel4 3 Out
      add_to_no_connect eidleinfersel5 3 Out
      add_to_no_connect eidleinfersel6 3 Out
      add_to_no_connect eidleinfersel7 3 Out
      add_interface_port hip_pipe powerdown0     powerdown0      Output 2
      add_to_no_connect powerdown1      2 Output
      add_to_no_connect powerdown2      2 Output
      add_to_no_connect powerdown3      2 Output
      add_to_no_connect powerdown4      2 Output
      add_to_no_connect powerdown5      2 Output
      add_to_no_connect powerdown6      2 Output
      add_to_no_connect powerdown7      2 Output
      add_interface_port hip_pipe rxpolarity0    rxpolarity0     Output 1
      add_to_no_connect rxpolarity1     1 Output
      add_to_no_connect rxpolarity2     1 Output
      add_to_no_connect rxpolarity3     1 Output
      add_to_no_connect rxpolarity4     1 Output
      add_to_no_connect rxpolarity5     1 Output
      add_to_no_connect rxpolarity6     1 Output
      add_to_no_connect rxpolarity7     1 Output
      add_interface_port hip_pipe txcompl0       txcompl0        Output 1
      add_to_no_connect txcompl1        1 Output
      add_to_no_connect txcompl2        1 Output
      add_to_no_connect txcompl3        1 Output
      add_to_no_connect txcompl4        1 Output
      add_to_no_connect txcompl5        1 Output
      add_to_no_connect txcompl6        1 Output
      add_to_no_connect txcompl7        1 Output
      add_interface_port hip_pipe txdata0        txdata0         Output 8
      add_to_no_connect txdata1         8 Output
      add_to_no_connect txdata2         8 Output
      add_to_no_connect txdata3         8 Output
      add_to_no_connect txdata4         8 Output
      add_to_no_connect txdata5         8 Output
      add_to_no_connect txdata6         8 Output
      add_to_no_connect txdata7         8 Output
      add_interface_port hip_pipe txdatak0       txdatak0        Output 1
      add_to_no_connect txdatak1        1 Output
      add_to_no_connect txdatak2        1 Output
      add_to_no_connect txdatak3        1 Output
      add_to_no_connect txdatak4        1 Output
      add_to_no_connect txdatak5        1 Output
      add_to_no_connect txdatak6        1 Output
      add_to_no_connect txdatak7        1 Output
      add_interface_port hip_pipe txdetectrx0    txdetectrx0     Output 1
      add_to_no_connect txdetectrx1     1 Output
      add_to_no_connect txdetectrx2     1 Output
      add_to_no_connect txdetectrx3     1 Output
      add_to_no_connect txdetectrx4     1 Output
      add_to_no_connect txdetectrx5     1 Output
      add_to_no_connect txdetectrx6     1 Output
      add_to_no_connect txdetectrx7     1 Output
      add_interface_port hip_pipe txelecidle0    txelecidle0     Output 1
      add_to_no_connect txelecidle1     1 Output
      add_to_no_connect txelecidle2     1 Output
      add_to_no_connect txelecidle3     1 Output
      add_to_no_connect txelecidle4     1 Output
      add_to_no_connect txelecidle5     1 Output
      add_to_no_connect txelecidle6     1 Output
      add_to_no_connect txelecidle7     1 Output
      add_interface_port hip_pipe txdeemph0      txdeemph0       Output 1
      add_to_no_connect txdeemph1       1 Output
      add_to_no_connect txdeemph2       1 Output
      add_to_no_connect txdeemph3       1 Output
      add_to_no_connect txdeemph4       1 Output
      add_to_no_connect txdeemph5       1 Output
      add_to_no_connect txdeemph6       1 Output
      add_to_no_connect txdeemph7       1 Output
      add_interface_port hip_pipe txmargin0       txmargin0        Output 3
      add_to_no_connect txmargin1       3 Output
      add_to_no_connect txmargin2       3 Output
      add_to_no_connect txmargin3       3 Output
      add_to_no_connect txmargin4       3 Output
      add_to_no_connect txmargin5       3 Output
      add_to_no_connect txmargin6       3 Output
      add_to_no_connect txmargin7       3 Output
      add_interface_port hip_pipe txswing0        txswing0        Output 1
      add_to_no_connect txswing1        1 Output
      add_to_no_connect txswing2        1 Output
      add_to_no_connect txswing3        1 Output
      add_to_no_connect txswing4        1 Output
      add_to_no_connect txswing5        1 Output
      add_to_no_connect txswing6        1 Output
      add_to_no_connect txswing7        1 Output
      add_interface_port hip_pipe phystatus0     phystatus0      Input  1
      add_to_no_connect phystatus1      1 Input
      add_to_no_connect phystatus2      1 Input
      add_to_no_connect phystatus3      1 Input
      add_to_no_connect phystatus4      1 Input
      add_to_no_connect phystatus5      1 Input
      add_to_no_connect phystatus6      1 Input
      add_to_no_connect phystatus7      1 Input
      add_interface_port hip_pipe rxdata0        rxdata0         Input  8
      add_to_no_connect rxdata1         8 Input
      add_to_no_connect rxdata2         8 Input
      add_to_no_connect rxdata3         8 Input
      add_to_no_connect rxdata4         8 Input
      add_to_no_connect rxdata5         8 Input
      add_to_no_connect rxdata6         8 Input
      add_to_no_connect rxdata7         8 Input
      add_interface_port hip_pipe rxdatak0       rxdatak0        Input  1
      add_to_no_connect rxdatak1        1 Input
      add_to_no_connect rxdatak2        1 Input
      add_to_no_connect rxdatak3        1 Input
      add_to_no_connect rxdatak4        1 Input
      add_to_no_connect rxdatak5        1 Input
      add_to_no_connect rxdatak6        1 Input
      add_to_no_connect rxdatak7        1 Input
      add_interface_port hip_pipe rxelecidle0    rxelecidle0     Input  1
      add_to_no_connect rxelecidle1     1 Input
      add_to_no_connect rxelecidle2     1 Input
      add_to_no_connect rxelecidle3     1 Input
      add_to_no_connect rxelecidle4     1 Input
      add_to_no_connect rxelecidle5     1 Input
      add_to_no_connect rxelecidle6     1 Input
      add_to_no_connect rxelecidle7     1 Input
      add_interface_port hip_pipe rxstatus0      rxstatus0       Input  3
      add_to_no_connect rxstatus1       3 Input
      add_to_no_connect rxstatus2       3 Input
      add_to_no_connect rxstatus3       3 Input
      add_to_no_connect rxstatus4       3 Input
      add_to_no_connect rxstatus5       3 Input
      add_to_no_connect rxstatus6       3 Input
      add_to_no_connect rxstatus7       3 Input
      add_interface_port hip_pipe rxvalid0       rxvalid0        Input  1
      add_to_no_connect rxvalid1        1 Input
      add_to_no_connect rxvalid2        1 Input
      add_to_no_connect rxvalid3        1 Input
      add_to_no_connect rxvalid4        1 Input
      add_to_no_connect rxvalid5        1 Input
      add_to_no_connect rxvalid6        1 Input
      add_to_no_connect rxvalid7        1 Input
   } elseif { $nlane == 2 } {
      add_interface_port hip_pipe eidleinfersel0 eidleinfersel0  Output 3
      add_interface_port hip_pipe eidleinfersel1 eidleinfersel1  Output 3
      add_to_no_connect eidleinfersel2 3 Output
      add_to_no_connect eidleinfersel3 3 Output
      add_to_no_connect eidleinfersel4 3 Output
      add_to_no_connect eidleinfersel5 3 Output
      add_to_no_connect eidleinfersel6 3 Output
      add_to_no_connect eidleinfersel7 3 Output
      add_interface_port hip_pipe powerdown0     powerdown0      Output 2
      add_interface_port hip_pipe powerdown1     powerdown1      Output 2
      add_to_no_connect powerdown2     2 Output
      add_to_no_connect powerdown3     2 Output
      add_to_no_connect powerdown4     2 Output
      add_to_no_connect powerdown5     2 Output
      add_to_no_connect powerdown6     2 Output
      add_to_no_connect powerdown7     2 Output
      add_interface_port hip_pipe rxpolarity0    rxpolarity0     Output 1
      add_interface_port hip_pipe rxpolarity1    rxpolarity1     Output 1
      add_to_no_connect rxpolarity2    1 Output
      add_to_no_connect rxpolarity3    1 Output
      add_to_no_connect rxpolarity4    1 Output
      add_to_no_connect rxpolarity5    1 Output
      add_to_no_connect rxpolarity6    1 Output
      add_to_no_connect rxpolarity7    1 Output
      add_interface_port hip_pipe txcompl0       txcompl0        Output 1
      add_interface_port hip_pipe txcompl1       txcompl1        Output 1
      add_to_no_connect txcompl2       1 Output
      add_to_no_connect txcompl3       1 Output
      add_to_no_connect txcompl4       1 Output
      add_to_no_connect txcompl5       1 Output
      add_to_no_connect txcompl6       1 Output
      add_to_no_connect txcompl7       1 Output
      add_interface_port hip_pipe txdata0        txdata0         Output 8
      add_interface_port hip_pipe txdata1        txdata1         Output 8
      add_to_no_connect txdata2        8 Output
      add_to_no_connect txdata3        8 Output
      add_to_no_connect txdata4        8 Output
      add_to_no_connect txdata5        8 Output
      add_to_no_connect txdata6        8 Output
      add_to_no_connect txdata7        8 Output
      add_interface_port hip_pipe txdatak0       txdatak0        Output 1
      add_interface_port hip_pipe txdatak1       txdatak1        Output 1
      add_to_no_connect txdatak2       1 Output
      add_to_no_connect txdatak3       1 Output
      add_to_no_connect txdatak4       1 Output
      add_to_no_connect txdatak5       1 Output
      add_to_no_connect txdatak6       1 Output
      add_to_no_connect txdatak7       1 Output
      add_interface_port hip_pipe txdetectrx0    txdetectrx0     Output 1
      add_interface_port hip_pipe txdetectrx1    txdetectrx1     Output 1
      add_to_no_connect txdetectrx2    1 Output
      add_to_no_connect txdetectrx3    1 Output
      add_to_no_connect txdetectrx4    1 Output
      add_to_no_connect txdetectrx5    1 Output
      add_to_no_connect txdetectrx6    1 Output
      add_to_no_connect txdetectrx7    1 Output
      add_interface_port hip_pipe txelecidle0    txelecidle0     Output 1
      add_interface_port hip_pipe txelecidle1    txelecidle1     Output 1
      add_to_no_connect txelecidle2    1 Output
      add_to_no_connect txelecidle3    1 Output
      add_to_no_connect txelecidle4    1 Output
      add_to_no_connect txelecidle5    1 Output
      add_to_no_connect txelecidle6    1 Output
      add_to_no_connect txelecidle7    1 Output
      add_interface_port hip_pipe txdeemph0      txdeemph0       Output 1
      add_interface_port hip_pipe txdeemph1      txdeemph1       Output 1
      add_to_no_connect txdeemph2      1 Output
      add_to_no_connect txdeemph3      1 Output
      add_to_no_connect txdeemph4      1 Output
      add_to_no_connect txdeemph5      1 Output
      add_to_no_connect txdeemph6      1 Output
      add_to_no_connect txdeemph7      1 Output
      add_interface_port hip_pipe txmargin0      txmargin0       Output 3
      add_interface_port hip_pipe txmargin1      txmargin1       Output 3
      add_to_no_connect txmargin2      3 Output
      add_to_no_connect txmargin3      3 Output
      add_to_no_connect txmargin4      3 Output
      add_to_no_connect txmargin5      3 Output
      add_to_no_connect txmargin6      3 Output
      add_to_no_connect txmargin7      3 Output
      add_interface_port hip_pipe txswing0       txswing0       Output 1
      add_interface_port hip_pipe txswing1       txswing1       Output 1
      add_to_no_connect txswing2       1 Output
      add_to_no_connect txswing3       1 Output
      add_to_no_connect txswing4       1 Output
      add_to_no_connect txswing5       1 Output
      add_to_no_connect txswing6       1 Output
      add_to_no_connect txswing7       1 Output
      add_interface_port hip_pipe phystatus0     phystatus0      Input  1
      add_interface_port hip_pipe phystatus1     phystatus1      Input  1
      add_to_no_connect phystatus2     1 Input
      add_to_no_connect phystatus3     1 Input
      add_to_no_connect phystatus4     1 Input
      add_to_no_connect phystatus5     1 Input
      add_to_no_connect phystatus6     1 Input
      add_to_no_connect phystatus7     1 Input
      add_interface_port hip_pipe rxdata0        rxdata0         Input  8
      add_interface_port hip_pipe rxdata1        rxdata1         Input  8
      add_to_no_connect rxdata2        8 Input
      add_to_no_connect rxdata3        8 Input
      add_to_no_connect rxdata4        8 Input
      add_to_no_connect rxdata5        8 Input
      add_to_no_connect rxdata6        8 Input
      add_to_no_connect rxdata7        8 Input
      add_interface_port hip_pipe rxdatak0       rxdatak0        Input  1
      add_interface_port hip_pipe rxdatak1       rxdatak1        Input  1
      add_to_no_connect rxdatak2       1 Input
      add_to_no_connect rxdatak3       1 Input
      add_to_no_connect rxdatak4       1 Input
      add_to_no_connect rxdatak5       1 Input
      add_to_no_connect rxdatak6       1 Input
      add_to_no_connect rxdatak7       1 Input
      add_interface_port hip_pipe rxelecidle0    rxelecidle0     Input  1
      add_interface_port hip_pipe rxelecidle1    rxelecidle1     Input  1
      add_to_no_connect rxelecidle2    1 Input
      add_to_no_connect rxelecidle3    1 Input
      add_to_no_connect rxelecidle4    1 Input
      add_to_no_connect rxelecidle5    1 Input
      add_to_no_connect rxelecidle6    1 Input
      add_to_no_connect rxelecidle7    1 Input
      add_interface_port hip_pipe rxstatus0      rxstatus0       Input  3
      add_interface_port hip_pipe rxstatus1      rxstatus1       Input  3
      add_to_no_connect rxstatus2      3 Input
      add_to_no_connect rxstatus3      3 Input
      add_to_no_connect rxstatus4      3 Input
      add_to_no_connect rxstatus5      3 Input
      add_to_no_connect rxstatus6      3 Input
      add_to_no_connect rxstatus7      3 Input
      add_interface_port hip_pipe rxvalid0       rxvalid0        Input  1
      add_interface_port hip_pipe rxvalid1       rxvalid1        Input  1
      add_to_no_connect rxvalid2       1 Input
      add_to_no_connect rxvalid3       1 Input
      add_to_no_connect rxvalid4       1 Input
      add_to_no_connect rxvalid5       1 Input
      add_to_no_connect rxvalid6       1 Input
      add_to_no_connect rxvalid7       1 Input
   } elseif { $nlane == 4 } {
      add_interface_port hip_pipe eidleinfersel0 eidleinfersel0  Output 3
      add_interface_port hip_pipe eidleinfersel1 eidleinfersel1  Output 3
      add_interface_port hip_pipe eidleinfersel2 eidleinfersel2  Output 3
      add_interface_port hip_pipe eidleinfersel3 eidleinfersel3  Output 3
      add_to_no_connect eidleinfersel4 3 Output
      add_to_no_connect eidleinfersel5 3 Output
      add_to_no_connect eidleinfersel6 3 Output
      add_to_no_connect eidleinfersel7 3 Output
      add_interface_port hip_pipe powerdown0     powerdown0      Output 2
      add_interface_port hip_pipe powerdown1     powerdown1      Output 2
      add_interface_port hip_pipe powerdown2     powerdown2      Output 2
      add_interface_port hip_pipe powerdown3     powerdown3      Output 2
      add_to_no_connect powerdown4   2   Output
      add_to_no_connect powerdown5   2   Output
      add_to_no_connect powerdown6   2   Output
      add_to_no_connect powerdown7   2   Output
      add_interface_port hip_pipe rxpolarity0    rxpolarity0     Output 1
      add_interface_port hip_pipe rxpolarity1    rxpolarity1     Output 1
      add_interface_port hip_pipe rxpolarity2    rxpolarity2     Output 1
      add_interface_port hip_pipe rxpolarity3    rxpolarity3     Output 1
      add_to_no_connect rxpolarity4  1   Output
      add_to_no_connect rxpolarity5  1   Output
      add_to_no_connect rxpolarity6  1   Output
      add_to_no_connect rxpolarity7  1   Output
      add_interface_port hip_pipe txcompl0       txcompl0        Output 1
      add_interface_port hip_pipe txcompl1       txcompl1        Output 1
      add_interface_port hip_pipe txcompl2       txcompl2        Output 1
      add_interface_port hip_pipe txcompl3       txcompl3        Output 1
      add_to_no_connect txcompl4     1   Output
      add_to_no_connect txcompl5     1   Output
      add_to_no_connect txcompl6     1   Output
      add_to_no_connect txcompl7     1   Output
      add_interface_port hip_pipe txdata0        txdata0         Output 8
      add_interface_port hip_pipe txdata1        txdata1         Output 8
      add_interface_port hip_pipe txdata2        txdata2         Output 8
      add_interface_port hip_pipe txdata3        txdata3         Output 8
      add_to_no_connect txdata4      8   Output
      add_to_no_connect txdata5      8   Output
      add_to_no_connect txdata6      8   Output
      add_to_no_connect txdata7      8   Output
      add_interface_port hip_pipe txdatak0       txdatak0        Output 1
      add_interface_port hip_pipe txdatak1       txdatak1        Output 1
      add_interface_port hip_pipe txdatak2       txdatak2        Output 1
      add_interface_port hip_pipe txdatak3       txdatak3        Output 1
      add_to_no_connect txdatak4     1   Output
      add_to_no_connect txdatak5     1   Output
      add_to_no_connect txdatak6     1   Output
      add_to_no_connect txdatak7     1   Output
      add_interface_port hip_pipe txdetectrx0    txdetectrx0     Output 1
      add_interface_port hip_pipe txdetectrx1    txdetectrx1     Output 1
      add_interface_port hip_pipe txdetectrx2    txdetectrx2     Output 1
      add_interface_port hip_pipe txdetectrx3    txdetectrx3     Output 1
      add_to_no_connect txdetectrx4  1   Output
      add_to_no_connect txdetectrx5  1   Output
      add_to_no_connect txdetectrx6  1   Output
      add_to_no_connect txdetectrx7  1   Output
      add_interface_port hip_pipe txelecidle0    txelecidle0     Output 1
      add_interface_port hip_pipe txelecidle1    txelecidle1     Output 1
      add_interface_port hip_pipe txelecidle2    txelecidle2     Output 1
      add_interface_port hip_pipe txelecidle3    txelecidle3     Output 1
      add_to_no_connect txelecidle4  1   Output
      add_to_no_connect txelecidle5  1   Output
      add_to_no_connect txelecidle6  1   Output
      add_to_no_connect txelecidle7  1   Output
      add_interface_port hip_pipe txdeemph0      txdeemph0       Output 1
      add_interface_port hip_pipe txdeemph1      txdeemph1       Output 1
      add_interface_port hip_pipe txdeemph2      txdeemph2       Output 1
      add_interface_port hip_pipe txdeemph3      txdeemph3       Output 1
      add_to_no_connect txdeemph4    1   Output
      add_to_no_connect txdeemph5    1   Output
      add_to_no_connect txdeemph6    1   Output
      add_to_no_connect txdeemph7    1   Output
      add_interface_port hip_pipe txmargin0      txmargin0       Output 3
      add_interface_port hip_pipe txmargin1      txmargin1       Output 3
      add_interface_port hip_pipe txmargin2      txmargin2       Output 3
      add_interface_port hip_pipe txmargin3      txmargin3       Output 3
      add_to_no_connect txmargin4    3   Output
      add_to_no_connect txmargin5    3   Output
      add_to_no_connect txmargin6    3   Output
      add_to_no_connect txmargin7    3   Output
      add_interface_port hip_pipe txswing0       txswing0       Output 1
      add_interface_port hip_pipe txswing1       txswing1       Output 1
      add_interface_port hip_pipe txswing2       txswing2       Output 1
      add_interface_port hip_pipe txswing3       txswing3       Output 1
      add_to_no_connect txswing4     1   Output
      add_to_no_connect txswing5     1   Output
      add_to_no_connect txswing6     1   Output
      add_to_no_connect txswing7     1   Output
      add_interface_port hip_pipe phystatus0     phystatus0      Input  1
      add_interface_port hip_pipe phystatus1     phystatus1      Input  1
      add_interface_port hip_pipe phystatus2     phystatus2      Input  1
      add_interface_port hip_pipe phystatus3     phystatus3      Input  1
      add_to_no_connect phystatus4   1   Input
      add_to_no_connect phystatus5   1   Input
      add_to_no_connect phystatus6   1   Input
      add_to_no_connect phystatus7   1   Input
      add_interface_port hip_pipe rxdata0        rxdata0         Input  8
      add_interface_port hip_pipe rxdata1        rxdata1         Input  8
      add_interface_port hip_pipe rxdata2        rxdata2         Input  8
      add_interface_port hip_pipe rxdata3        rxdata3         Input  8
      add_to_no_connect rxdata4      8   Input
      add_to_no_connect rxdata5      8   Input
      add_to_no_connect rxdata6      8   Input
      add_to_no_connect rxdata7      8   Input
      add_interface_port hip_pipe rxdatak0       rxdatak0        Input  1
      add_interface_port hip_pipe rxdatak1       rxdatak1        Input  1
      add_interface_port hip_pipe rxdatak2       rxdatak2        Input  1
      add_interface_port hip_pipe rxdatak3       rxdatak3        Input  1
      add_to_no_connect rxdatak4     1   Input
      add_to_no_connect rxdatak5     1   Input
      add_to_no_connect rxdatak6     1   Input
      add_to_no_connect rxdatak7     1   Input
      add_interface_port hip_pipe rxelecidle0    rxelecidle0     Input  1
      add_interface_port hip_pipe rxelecidle1    rxelecidle1     Input  1
      add_interface_port hip_pipe rxelecidle2    rxelecidle2     Input  1
      add_interface_port hip_pipe rxelecidle3    rxelecidle3     Input  1
      add_to_no_connect rxelecidle4  1   Input
      add_to_no_connect rxelecidle5  1   Input
      add_to_no_connect rxelecidle6  1   Input
      add_to_no_connect rxelecidle7  1   Input
      add_interface_port hip_pipe rxstatus0      rxstatus0       Input  3
      add_interface_port hip_pipe rxstatus1      rxstatus1       Input  3
      add_interface_port hip_pipe rxstatus2      rxstatus2       Input  3
      add_interface_port hip_pipe rxstatus3      rxstatus3       Input  3
      add_to_no_connect rxstatus4    3   Input
      add_to_no_connect rxstatus5    3   Input
      add_to_no_connect rxstatus6    3   Input
      add_to_no_connect rxstatus7    3   Input
      add_interface_port hip_pipe rxvalid0       rxvalid0        Input  1
      add_interface_port hip_pipe rxvalid1       rxvalid1        Input  1
      add_interface_port hip_pipe rxvalid2       rxvalid2        Input  1
      add_interface_port hip_pipe rxvalid3       rxvalid3        Input  1
      add_to_no_connect rxvalid4     1   Input
      add_to_no_connect rxvalid5     1   Input
      add_to_no_connect rxvalid6     1   Input
      add_to_no_connect rxvalid7     1   Input
   } else {
     add_interface_port hip_pipe eidleinfersel0 eidleinfersel0  Output 3
     add_interface_port hip_pipe eidleinfersel1 eidleinfersel1  Output 3
     add_interface_port hip_pipe eidleinfersel2 eidleinfersel2  Output 3
     add_interface_port hip_pipe eidleinfersel3 eidleinfersel3  Output 3
     add_interface_port hip_pipe eidleinfersel4 eidleinfersel4  Output 3
     add_interface_port hip_pipe eidleinfersel5 eidleinfersel5  Output 3
     add_interface_port hip_pipe eidleinfersel6 eidleinfersel6  Output 3
     add_interface_port hip_pipe eidleinfersel7 eidleinfersel7  Output 3
     add_interface_port hip_pipe powerdown0     powerdown0      Output 2
     add_interface_port hip_pipe powerdown1     powerdown1      Output 2
     add_interface_port hip_pipe powerdown2     powerdown2      Output 2
     add_interface_port hip_pipe powerdown3     powerdown3      Output 2
     add_interface_port hip_pipe powerdown4     powerdown4      Output 2
     add_interface_port hip_pipe powerdown5     powerdown5      Output 2
     add_interface_port hip_pipe powerdown6     powerdown6      Output 2
     add_interface_port hip_pipe powerdown7     powerdown7      Output 2
     add_interface_port hip_pipe rxpolarity0    rxpolarity0     Output 1
     add_interface_port hip_pipe rxpolarity1    rxpolarity1     Output 1
     add_interface_port hip_pipe rxpolarity2    rxpolarity2     Output 1
     add_interface_port hip_pipe rxpolarity3    rxpolarity3     Output 1
     add_interface_port hip_pipe rxpolarity4    rxpolarity4     Output 1
     add_interface_port hip_pipe rxpolarity5    rxpolarity5     Output 1
     add_interface_port hip_pipe rxpolarity6    rxpolarity6     Output 1
     add_interface_port hip_pipe rxpolarity7    rxpolarity7     Output 1
     add_interface_port hip_pipe txcompl0       txcompl0        Output 1
     add_interface_port hip_pipe txcompl1       txcompl1        Output 1
     add_interface_port hip_pipe txcompl2       txcompl2        Output 1
     add_interface_port hip_pipe txcompl3       txcompl3        Output 1
     add_interface_port hip_pipe txcompl4       txcompl4        Output 1
     add_interface_port hip_pipe txcompl5       txcompl5        Output 1
     add_interface_port hip_pipe txcompl6       txcompl6        Output 1
     add_interface_port hip_pipe txcompl7       txcompl7        Output 1
     add_interface_port hip_pipe txdata0        txdata0         Output 8
     add_interface_port hip_pipe txdata1        txdata1         Output 8
     add_interface_port hip_pipe txdata2        txdata2         Output 8
     add_interface_port hip_pipe txdata3        txdata3         Output 8
     add_interface_port hip_pipe txdata4        txdata4         Output 8
     add_interface_port hip_pipe txdata5        txdata5         Output 8
     add_interface_port hip_pipe txdata6        txdata6         Output 8
     add_interface_port hip_pipe txdata7        txdata7         Output 8
     add_interface_port hip_pipe txdatak0       txdatak0        Output 1
     add_interface_port hip_pipe txdatak1       txdatak1        Output 1
     add_interface_port hip_pipe txdatak2       txdatak2        Output 1
     add_interface_port hip_pipe txdatak3       txdatak3        Output 1
     add_interface_port hip_pipe txdatak4       txdatak4        Output 1
     add_interface_port hip_pipe txdatak5       txdatak5        Output 1
     add_interface_port hip_pipe txdatak6       txdatak6        Output 1
     add_interface_port hip_pipe txdatak7       txdatak7        Output 1
     add_interface_port hip_pipe txdetectrx0    txdetectrx0     Output 1
     add_interface_port hip_pipe txdetectrx1    txdetectrx1     Output 1
     add_interface_port hip_pipe txdetectrx2    txdetectrx2     Output 1
     add_interface_port hip_pipe txdetectrx3    txdetectrx3     Output 1
     add_interface_port hip_pipe txdetectrx4    txdetectrx4     Output 1
     add_interface_port hip_pipe txdetectrx5    txdetectrx5     Output 1
     add_interface_port hip_pipe txdetectrx6    txdetectrx6     Output 1
     add_interface_port hip_pipe txdetectrx7    txdetectrx7     Output 1
     add_interface_port hip_pipe txelecidle0    txelecidle0     Output 1
     add_interface_port hip_pipe txelecidle1    txelecidle1     Output 1
     add_interface_port hip_pipe txelecidle2    txelecidle2     Output 1
     add_interface_port hip_pipe txelecidle3    txelecidle3     Output 1
     add_interface_port hip_pipe txelecidle4    txelecidle4     Output 1
     add_interface_port hip_pipe txelecidle5    txelecidle5     Output 1
     add_interface_port hip_pipe txelecidle6    txelecidle6     Output 1
     add_interface_port hip_pipe txelecidle7    txelecidle7     Output 1
     add_interface_port hip_pipe txdeemph0      txdeemph0       Output 1
     add_interface_port hip_pipe txdeemph1      txdeemph1       Output 1
     add_interface_port hip_pipe txdeemph2      txdeemph2       Output 1
     add_interface_port hip_pipe txdeemph3      txdeemph3       Output 1
     add_interface_port hip_pipe txdeemph4      txdeemph4       Output 1
     add_interface_port hip_pipe txdeemph5      txdeemph5       Output 1
     add_interface_port hip_pipe txdeemph6      txdeemph6       Output 1
     add_interface_port hip_pipe txdeemph7      txdeemph7       Output 1
     add_interface_port hip_pipe txmargin0      txmargin0       Output 3
     add_interface_port hip_pipe txmargin1      txmargin1       Output 3
     add_interface_port hip_pipe txmargin2      txmargin2       Output 3
     add_interface_port hip_pipe txmargin3      txmargin3       Output 3
     add_interface_port hip_pipe txmargin4      txmargin4       Output 3
     add_interface_port hip_pipe txmargin5      txmargin5       Output 3
     add_interface_port hip_pipe txmargin6      txmargin6       Output 3
     add_interface_port hip_pipe txmargin7      txmargin7       Output 3
     add_interface_port hip_pipe txswing0       txswing0        Output 1
     add_interface_port hip_pipe txswing1       txswing1        Output 1
     add_interface_port hip_pipe txswing2       txswing2        Output 1
     add_interface_port hip_pipe txswing3       txswing3        Output 1
     add_interface_port hip_pipe txswing4       txswing4        Output 1
     add_interface_port hip_pipe txswing5       txswing5        Output 1
     add_interface_port hip_pipe txswing6       txswing6        Output 1
     add_interface_port hip_pipe txswing7       txswing7        Output 1
     add_interface_port hip_pipe phystatus0     phystatus0      Input  1
     add_interface_port hip_pipe phystatus1     phystatus1      Input  1
     add_interface_port hip_pipe phystatus2     phystatus2      Input  1
     add_interface_port hip_pipe phystatus3     phystatus3      Input  1
     add_interface_port hip_pipe phystatus4     phystatus4      Input  1
     add_interface_port hip_pipe phystatus5     phystatus5      Input  1
     add_interface_port hip_pipe phystatus6     phystatus6      Input  1
     add_interface_port hip_pipe phystatus7     phystatus7      Input  1
     add_interface_port hip_pipe rxdata0        rxdata0         Input  8
     add_interface_port hip_pipe rxdata1        rxdata1         Input  8
     add_interface_port hip_pipe rxdata2        rxdata2         Input  8
     add_interface_port hip_pipe rxdata3        rxdata3         Input  8
     add_interface_port hip_pipe rxdata4        rxdata4         Input  8
     add_interface_port hip_pipe rxdata5        rxdata5         Input  8
     add_interface_port hip_pipe rxdata6        rxdata6         Input  8
     add_interface_port hip_pipe rxdata7        rxdata7         Input  8
     add_interface_port hip_pipe rxdatak0       rxdatak0        Input  1
     add_interface_port hip_pipe rxdatak1       rxdatak1        Input  1
     add_interface_port hip_pipe rxdatak2       rxdatak2        Input  1
     add_interface_port hip_pipe rxdatak3       rxdatak3        Input  1
     add_interface_port hip_pipe rxdatak4       rxdatak4        Input  1
     add_interface_port hip_pipe rxdatak5       rxdatak5        Input  1
     add_interface_port hip_pipe rxdatak6       rxdatak6        Input  1
     add_interface_port hip_pipe rxdatak7       rxdatak7        Input  1
     add_interface_port hip_pipe rxelecidle0    rxelecidle0     Input  1
     add_interface_port hip_pipe rxelecidle1    rxelecidle1     Input  1
     add_interface_port hip_pipe rxelecidle2    rxelecidle2     Input  1
     add_interface_port hip_pipe rxelecidle3    rxelecidle3     Input  1
     add_interface_port hip_pipe rxelecidle4    rxelecidle4     Input  1
     add_interface_port hip_pipe rxelecidle5    rxelecidle5     Input  1
     add_interface_port hip_pipe rxelecidle6    rxelecidle6     Input  1
     add_interface_port hip_pipe rxelecidle7    rxelecidle7     Input  1
     add_interface_port hip_pipe rxstatus0      rxstatus0       Input  3
     add_interface_port hip_pipe rxstatus1      rxstatus1       Input  3
     add_interface_port hip_pipe rxstatus2      rxstatus2       Input  3
     add_interface_port hip_pipe rxstatus3      rxstatus3       Input  3
     add_interface_port hip_pipe rxstatus4      rxstatus4       Input  3
     add_interface_port hip_pipe rxstatus5      rxstatus5       Input  3
     add_interface_port hip_pipe rxstatus6      rxstatus6       Input  3
     add_interface_port hip_pipe rxstatus7      rxstatus7       Input  3
     add_interface_port hip_pipe rxvalid0       rxvalid0        Input  1
     add_interface_port hip_pipe rxvalid1       rxvalid1        Input  1
     add_interface_port hip_pipe rxvalid2       rxvalid2        Input  1
     add_interface_port hip_pipe rxvalid3       rxvalid3        Input  1
     add_interface_port hip_pipe rxvalid4       rxvalid4        Input  1
     add_interface_port hip_pipe rxvalid5       rxvalid5        Input  1
     add_interface_port hip_pipe rxvalid6       rxvalid6        Input  1
     add_interface_port hip_pipe rxvalid7       rxvalid7        Input  1
   }

# Gen3 only
   add_to_no_connect rxdataskip0 1 In
   add_to_no_connect rxdataskip1 1 In
   add_to_no_connect rxdataskip2 1 In
   add_to_no_connect rxdataskip3 1 In
   add_to_no_connect rxdataskip4 1 In
   add_to_no_connect rxdataskip5 1 In
   add_to_no_connect rxdataskip6 1 In
   add_to_no_connect rxdataskip7 1 In
   add_to_no_connect rxblkst0         1  In
   add_to_no_connect rxblkst1         1  In
   add_to_no_connect rxblkst2         1  In
   add_to_no_connect rxblkst3         1  In
   add_to_no_connect rxblkst4         1  In
   add_to_no_connect rxblkst5         1  In
   add_to_no_connect rxblkst6         1  In
   add_to_no_connect rxblkst7         1  In
   add_to_no_connect rxsynchd0        2  In
   add_to_no_connect rxsynchd1        2  In
   add_to_no_connect rxsynchd2        2  In
   add_to_no_connect rxsynchd3        2  In
   add_to_no_connect rxsynchd4        2  In
   add_to_no_connect rxsynchd5        2  In
   add_to_no_connect rxsynchd6        2  In
   add_to_no_connect rxsynchd7        2  In
   add_to_no_connect rxfreqlocked0    1  In
   add_to_no_connect rxfreqlocked1    1  In
   add_to_no_connect rxfreqlocked2    1  In
   add_to_no_connect rxfreqlocked3    1  In
   add_to_no_connect rxfreqlocked4    1  In
   add_to_no_connect rxfreqlocked5    1  In
   add_to_no_connect rxfreqlocked6    1  In
   add_to_no_connect rxfreqlocked7    1  In
   add_to_no_connect currentcoeff0    18 Out
   add_to_no_connect currentcoeff1    18 Out
   add_to_no_connect currentcoeff2    18 Out
   add_to_no_connect currentcoeff3    18 Out
   add_to_no_connect currentcoeff4    18 Out
   add_to_no_connect currentcoeff5    18 Out
   add_to_no_connect currentcoeff6    18 Out
   add_to_no_connect currentcoeff7    18 Out
   add_to_no_connect currentrxpreset0 3  Out
   add_to_no_connect currentrxpreset1 3  Out
   add_to_no_connect currentrxpreset2 3  Out
   add_to_no_connect currentrxpreset3 3  Out
   add_to_no_connect currentrxpreset4 3  Out
   add_to_no_connect currentrxpreset5 3  Out
   add_to_no_connect currentrxpreset6 3  Out
   add_to_no_connect currentrxpreset7 3  Out
   add_to_no_connect txsynchd0        2  Out
   add_to_no_connect txsynchd1        2  Out
   add_to_no_connect txsynchd2        2  Out
   add_to_no_connect txsynchd3        2  Out
   add_to_no_connect txsynchd4        2  Out
   add_to_no_connect txsynchd5        2  Out
   add_to_no_connect txsynchd6        2  Out
   add_to_no_connect txsynchd7        2  Out
   add_to_no_connect txblkst0         1  Out
   add_to_no_connect txblkst1         1  Out
   add_to_no_connect txblkst2         1  Out
   add_to_no_connect txblkst3         1  Out
   add_to_no_connect txblkst4         1  Out
   add_to_no_connect txblkst5         1  Out
   add_to_no_connect txblkst6         1  Out
   add_to_no_connect txblkst7         1  Out
}

####################################################################################################
#
# Serial interface conduit
#
proc add_pcie_sriov_port_serial {} {

   send_message debug "proc:add_pcie_sriov_port_serial"

   set lane_mask_hwtcl  [ get_parameter_value lane_mask_hwtcl]
   set nlane [ expr [ regexp x8 $lane_mask_hwtcl  ] ? 8 : [ regexp x4 $lane_mask_hwtcl ] ? 4 :  [ regexp x2 $lane_mask_hwtcl ] ? 2 : 1 ]

   add_interface hip_serial conduit end

   if { $nlane == 1 } {
      add_interface_port hip_serial rx_in0 rx_in0  Input 1
      add_to_no_connect              rx_in1 1 In
      add_to_no_connect              rx_in2 1 In
      add_to_no_connect              rx_in3 1 In
      add_to_no_connect              rx_in4 1 In
      add_to_no_connect              rx_in5 1 In
      add_to_no_connect              rx_in6 1 In
      add_to_no_connect              rx_in7 1 In
      add_interface_port hip_serial tx_out0 tx_out0  Output 1
      add_to_no_connect              tx_out1 1 Out
      add_to_no_connect              tx_out2 1 Out
      add_to_no_connect              tx_out3 1 Out
      add_to_no_connect              tx_out4 1 Out
      add_to_no_connect              tx_out5 1 Out
      add_to_no_connect              tx_out6 1 Out
      add_to_no_connect              tx_out7 1 Out
   } elseif { $nlane == 2 } {
      add_interface_port hip_serial rx_in0 rx_in0  Input 1
      add_interface_port hip_serial rx_in1 rx_in1   Input 1
      add_to_no_connect              rx_in2 1 In
      add_to_no_connect              rx_in3 1 In
      add_to_no_connect              rx_in4 1 In
      add_to_no_connect              rx_in5 1 In
      add_to_no_connect              rx_in6 1 In
      add_to_no_connect              rx_in7 1 In
      add_interface_port hip_serial tx_out0 tx_out0  Output 1
      add_interface_port hip_serial tx_out1 tx_out1  Output 1
      add_to_no_connect              tx_out2 1 Out
      add_to_no_connect              tx_out3 1 Out
      add_to_no_connect              tx_out4 1 Out
      add_to_no_connect              tx_out5 1 Out
      add_to_no_connect              tx_out6 1 Out
      add_to_no_connect              tx_out7 1 Out
   } elseif { $nlane == 4 } {
      add_interface_port hip_serial rx_in0 rx_in0  Input 1
      add_interface_port hip_serial rx_in1 rx_in1  Input 1
      add_interface_port hip_serial rx_in2 rx_in2  Input 1
      add_interface_port hip_serial rx_in3 rx_in3  Input 1
      add_to_no_connect              rx_in4 1 In
      add_to_no_connect              rx_in5 1 In
      add_to_no_connect              rx_in6 1 In
      add_to_no_connect              rx_in7 1 In
      add_interface_port hip_serial tx_out0 tx_out0  Output 1
      add_interface_port hip_serial tx_out1 tx_out1  Output 1
      add_interface_port hip_serial tx_out2 tx_out2  Output 1
      add_interface_port hip_serial tx_out3 tx_out3  Output 1
      add_to_no_connect              tx_out4 1 Out
      add_to_no_connect              tx_out5 1 Out
      add_to_no_connect              tx_out6 1 Out
      add_to_no_connect              tx_out7 1 Out
   } else {
      add_interface_port hip_serial rx_in0 rx_in0  Input 1
      add_interface_port hip_serial rx_in1 rx_in1  Input 1
      add_interface_port hip_serial rx_in2 rx_in2  Input 1
      add_interface_port hip_serial rx_in3 rx_in3  Input 1
      add_interface_port hip_serial rx_in4 rx_in4  Input 1
      add_interface_port hip_serial rx_in5 rx_in5  Input 1
      add_interface_port hip_serial rx_in6 rx_in6  Input 1
      add_interface_port hip_serial rx_in7 rx_in7  Input 1
      add_interface_port hip_serial tx_out0 tx_out0  Output 1
      add_interface_port hip_serial tx_out1 tx_out1  Output 1
      add_interface_port hip_serial tx_out2 tx_out2  Output 1
      add_interface_port hip_serial tx_out3 tx_out3  Output 1
      add_interface_port hip_serial tx_out4 tx_out4  Output 1
      add_interface_port hip_serial tx_out5 tx_out5  Output 1
      add_interface_port hip_serial tx_out6 tx_out6  Output 1
      add_interface_port hip_serial tx_out7 tx_out7  Output 1
   }
   set_interface_assignment hip_serial "ui.blockdiagram.direction" "output"
}


####################################################################################################
#
# Interrupt interface conduit
#
proc add_pcie_sriov_port_interrupt {} {

   send_message debug "proc:add_pcie_sriov_port_interrupt"
   set VF_COUNT [ get_parameter_value VF_COUNT]

   add_interface int_msi conduit end
   #set_interface_assignment int_msi "ui.blockdiagram.direction" "output"

   add_interface_port int_msi app_msi_req    app_msi_req    Input  1
   add_interface_port int_msi app_msi_ack    app_msi_ack    Output 1
   add_interface_port int_msi app_msi_req_fn app_msi_req_fn Input  8
   add_interface_port int_msi app_msi_num    app_msi_num    Input  5
   add_interface_port int_msi app_msi_tc     app_msi_tc     Input  3

   add_interface_port int_msi app_msi_enable_pf               app_msi_enable_pf             Output 1
   add_interface_port int_msi app_msi_multi_msg_enable_pf     app_msi_multi_msg_enable_pf   Output 3
   add_interface_port int_msi app_msi_enable_vf               app_msi_enable_vf             Output $VF_COUNT
   add_interface_port int_msi app_msi_multi_msg_enable_vf     app_msi_multi_msg_enable_vf   Output $VF_COUNT*3
   add_interface_port int_msi app_msix_en_pf                  app_msix_en_pf                Output 1
   add_interface_port int_msi app_msix_fn_mask_pf             app_msix_fn_mask_pf           Output 1
   add_interface_port int_msi app_msix_en_vf                  app_msix_en_vf                Output $VF_COUNT
   add_interface_port int_msi app_msix_fn_mask_vf             app_msix_fn_mask_vf           Output $VF_COUNT

   add_interface_port int_msi app_int_ack    app_int_ack        Output 1
   add_interface_port int_msi app_int_sts_a  app_int_sts_a      Input  1
   add_interface_port int_msi app_int_sts_b  app_int_sts_b      Input  1
   add_interface_port int_msi app_int_sts_c  app_int_sts_c      Input  1
   add_interface_port int_msi app_int_sts_d  app_int_sts_d      Input  1
   add_interface_port int_msi app_int_sts_fn app_int_sts_fn     Input  3

   add_interface_port int_msi app_int_pend_status app_int_pend_status Input 1
   add_interface_port int_msi app_intx_disable app_intx_disable       Output 1

}


####################################################################################################
#
# LMI interface conduit
#
proc add_pcie_hip_port_lmi {} {

   send_message debug "proc:add_pcie_hip_port_lmi"

   add_interface lmi conduit end

   add_interface_port lmi lmi_addr lmi_addr  Input  12
   add_interface_port lmi lmi_func lmi_func  Input  9
   add_interface_port lmi lmi_din  lmi_din   Input  32
   add_interface_port lmi lmi_rden lmi_rden  Input  1
   add_interface_port lmi lmi_wren lmi_wren  Input  1
   add_interface_port lmi lmi_ack  lmi_ack   Output 1
   add_interface_port lmi lmi_dout lmi_dout  Output 32

}

####################################################################################################
#
# Completion Status Signals from user application
#
proc add_pcie_sriov_port_completion {} {

   send_message debug "proc: add_pcie_sriov_port_completion"
   set VF_COUNT [ get_parameter_value VF_COUNT]

   add_interface      hip_completion conduit end
   add_interface_port hip_completion cpl_err         cpl_err        Input  7
   add_interface_port hip_completion cpl_err_fn      cpl_err_fn     Input 8
   add_interface_port hip_completion cpl_pending_pf  cpl_pending_pf Input 1
   add_interface_port hip_completion cpl_pending_vf  cpl_pending_vf Input $VF_COUNT
   add_interface_port hip_completion log_hdr         log_hdr        Input 128

  #set_interface_assignment hip_completion "ui.blockdiagram.direction" "output"

}

#####################################################################################################
#
# HIP control
#
proc add_pcie_sriov_port_hip_misc {} {

   send_message debug "proc:add_sriov_port_hip_misc"

   add_interface      hip_misc conduit end
   add_interface_port hip_misc hpg_ctrler     hpg_ctrler      Input  5

}

####################################################################################################
#
# Config-Status interface conduit 
#
proc add_pcie_sriov_port_cfgstatus {} {

   send_message debug "proc:add_pcie_sriov_port_cfgstatus"
   set VF_COUNT [ get_parameter_value VF_COUNT]

   add_interface cfg_status conduit end

   add_interface_port cfg_status  bus_num_f0        bus_num_f0         Output  8
   add_interface_port cfg_status  device_num_f0     device_num_f0      Output  5
   add_interface_port cfg_status  mem_space_en_pf   mem_space_en_pf    Output  1
   add_interface_port cfg_status  bus_master_en_pf  bus_master_en_pf   Output  1
   add_interface_port cfg_status  mem_space_en_vf   mem_space_en_vf    Output  1
   add_interface_port cfg_status  bus_master_en_vf  bus_master_en_vf   Output  $VF_COUNT
   add_interface_port cfg_status  num_vfs           num_vfs            Output  8
   add_interface_port cfg_status  max_payload_size  max_payload_size   Output  3
   add_interface_port cfg_status  rd_req_size       rd_req_size        Output  3
}

####################################################################################################
#
# Functional_level reset
#
proc add_pcie_sriov_port_flr {} {

   send_message debug "proc: add_pcie_sriov_port_flr"
   set VF_COUNT [ get_parameter_value VF_COUNT]

   add_interface flr conduit end
   add_interface_port flr  flr_active_pf     flr_active_pf     Output   1
   add_interface_port flr  flr_active_vf     flr_active_vf     Output   $VF_COUNT
   add_interface_port flr  flr_completed_pf  flr_completed_pf  Input    1
   add_interface_port flr  flr_completed_vf  flr_completed_vf  Input    $VF_COUNT
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
