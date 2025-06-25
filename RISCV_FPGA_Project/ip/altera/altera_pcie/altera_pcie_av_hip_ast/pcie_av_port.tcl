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
proc add_pcie_hip_port_clk {} {

   send_message debug "proc:add_pcie_hip_port_clk"

   add_interface pld_clk clock end
   add_interface_port pld_clk pld_clk clk Input 1
   set pld_clk_MHz [ get_parameter_value pld_clk_MHz ]
   set_interface_property pld_clk clockRate [expr {$pld_clk_MHz * 100000}]

   add_interface coreclkout_hip clock start
   add_interface_port coreclkout_hip coreclkout clk Output 1
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
proc add_pcie_hip_port_por {} {
   add_interface npor conduit end
   add_interface_port npor npor npor Input 1
   add_interface_port npor pin_perst pin_perst Input 1
}

####################################################################################################
#
# reconfig interface
#
proc add_pcie_hip_port_reconfig {} {

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
proc add_pcie_hip_port_rst {} {

   send_message debug "proc:add_pcie_hip_port_rst"

   add_interface hip_rst conduit end
   add_interface_port hip_rst reset_status      reset_status      Output 1
   add_interface_port hip_rst serdes_pll_locked serdes_pll_locked Output 1
   add_interface_port hip_rst pld_clk_inuse     pld_clk_inuse     Output 1
   add_interface_port hip_rst pld_core_ready    pld_core_ready    Input  1
   add_interface_port hip_rst testin_zero       testin_zero       Output 1

   set port_type_hwtcl  [ get_parameter_value porttype_func0_hwtcl ]

   if  { [ regexp Root $port_type_hwtcl ] } {
      add_interface_port hip_rst   sim_pipe_pclk_out    sim_pipe_pclk_out     Output 1
   } else {
      add_to_no_connect sim_pipe_pclk_out 1 out
   }

}

####################################################################################################
#
# HIP Control conduit
#
proc add_pcie_hip_port_control {} {

   send_message debug "proc:add_pcie_hip_port_control"

   add_interface hip_ctrl conduit end
   add_interface_port hip_ctrl test_in        test_in   Input 32
   add_interface_port hip_ctrl simu_mode_pipe simu_mode_pipe Input 1

}

####################################################################################################
#
# HIP Status conduit
#
proc add_pcie_hip_port_status {} {

   send_message debug "proc:add_pcie_hip_port_status"
   set number_of_func_hwtcl [ get_parameter_value num_of_func_hwtcl ]

   add_interface hip_status conduit end

   add_interface_port hip_status derr_cor_ext_rcv0  derr_cor_ext_rcv    Output 1
   add_interface_port hip_status derr_cor_ext_rpl   derr_cor_ext_rpl    Output 1
   add_interface_port hip_status derr_rpl           derr_rpl            Output 1
#   add_interface_port hip_status dlup               dlup                Output 1
   add_interface_port hip_status dlup_exit          dlup_exit           Output 1
   add_interface_port hip_status dl_ltssm           ltssmstate          Output 5
#   add_interface_port hip_status ratetiedtognd      ratetiedtognd       Output 1
   add_interface_port hip_status ev128ns            ev128ns             Output 1
   add_interface_port hip_status ev1us              ev1us               Output 1
   add_interface_port hip_status hotrst_exit        hotrst_exit         Output 1
   add_interface_port hip_status int_status         int_status          Output 4
   add_interface_port hip_status l2_exit            l2_exit             Output 1
   add_interface_port hip_status lane_act           lane_act            Output 4
#   add_interface_port hip_status ltssml0state       ltssml0state        Output 1

#   # Parity error
#   add_interface_port hip_status rx_par_err rx_par_err                  Output 1
#   add_interface_port hip_status tx_par_err tx_par_err                  Output 2
#   add_interface_port hip_status cfg_par_err cfg_par_err                Output 1

   # Completion space information
   add_interface_port hip_status ko_cpl_spc_header ko_cpl_spc_header    Output 8
   add_interface_port hip_status ko_cpl_spc_data   ko_cpl_spc_data      Output 12

   add_interface hip_currentspeed conduit end
   add_interface_port hip_currentspeed dl_current_speed   currentspeed  Output 2


   set_interface_assignment hip_status "ui.blockdiagram.direction" "output"

}



####################################################################################################
#
# Avalon-ST RX
#
proc add_pcie_hip_port_ast_rx {} {

   send_message debug "proc:add_pcie_hip_port_ast_rx"

   set ast_width_hwtcl  [ get_parameter_value ast_width_hwtcl]
#   set ast_parity       [ get_parameter_value use_ast_parity ]
   set dataWidth        [ expr [ regexp 128 $ast_width_hwtcl ] ? 128 : 64 ]
   set dataByteWidth    [ expr [ regexp 128 $ast_width_hwtcl ] ? 16 : 8 ]
   set number_of_func_hwtcl [ get_parameter_value num_of_func_hwtcl ]


   # Avalon-stream RX HIP
   # indicates that AST symbols ordering is little endian instead of Big endian
   # set_interface_property rx_st highOrderSymbolAtMSB false
   add_interface rx_st avalon_streaming start
   set_interface_property rx_st dataBitsPerSymbol $dataWidth
   set_interface_property rx_st maxChannel 0
   set_interface_property rx_st readyLatency 3
   set_interface_property rx_st symbolsPerBeat 1
   set_interface_property rx_st ENABLED true
   set_interface_property rx_st associatedClock pld_clk
   add_interface_port rx_st rx_st_valid valid Output 1
   add_interface_port rx_st rx_st_sop startofpacket Output 1
   add_interface_port rx_st rx_st_eop endofpacket Output 1
   if { $dataWidth > 64 } {
      add_interface_port rx_st rx_st_empty empty Output 1
   } else {
      add_to_no_connect rx_st_empty 1 Out
   }
   add_interface_port rx_st rx_st_ready ready Input 1
   add_interface_port rx_st rx_st_err error Output 1
   add_interface_port rx_st rx_st_data data Output $dataWidth

   add_to_no_connect rx_fifo_empty 1 Out
   add_to_no_connect rx_fifo_full 1 Out
   # AST Parity
#   if { $ast_parity == 0 } {
#      add_to_no_connect rx_st_parity $dataByteWidth out
#   } else {
#      add_interface_port rx_st rx_st_parity parity Output $dataByteWidth
#   }

   # rx_bar_be combines the HIP Bar decode signal with the HIP RX_DATA_BE
   # which are not avalon-st but synchronous to the rx_st_data bus
   add_interface rx_bar_be conduit end
   # BAR Decode output

   if { $number_of_func_hwtcl == 1} {
      add_to_no_connect rx_bar_dec_func_num 3 Out
   } else {
      add_interface_port rx_bar_be rx_bar_dec_func_num rx_bar_dec_func_num  Output 3
   }
   add_interface_port rx_bar_be rx_st_bar rx_st_bar  Output 8

   # Byte enable
   set use_rx_st_be_hwtcl [ get_parameter_value use_rx_st_be_hwtcl ]
   if { $use_rx_st_be_hwtcl == 0 } {
      add_to_no_connect rx_st_be $dataByteWidth out
   } else {
      add_interface_port rx_bar_be rx_st_be rx_st_be  Output $dataByteWidth
   }

   # rx_st_mask
   add_interface_port rx_bar_be rx_st_mask rx_st_mask Input 1
   set_interface_assignment rx_bar_be "ui.blockdiagram.direction" "output"
}

####################################################################################################
#
# Avalon-ST TX
#
proc add_pcie_hip_port_ast_tx {} {

   send_message debug "proc:add_pcie_hip_port_ast_tx"

   set ast_width_hwtcl  [ get_parameter_value ast_width_hwtcl]
#   set ast_parity       [ get_parameter_value use_ast_parity ]
   set dataWidth        [ expr [ regexp 128 $ast_width_hwtcl ] ? 128 : 64 ]
   set dataByteWidth    [ expr [ regexp 128 $ast_width_hwtcl ] ? 16 : 8 ]

   # AST TX
   # indicates that AST symbols ordering is little endian instead of Big endian
   # set_interface_property tx_st highOrderSymbolAtMSB false
   add_interface tx_st avalon_streaming end
   set_interface_property tx_st dataBitsPerSymbol $dataWidth
   set_interface_property tx_st maxChannel 0
   set_interface_property tx_st readyLatency 3
   set_interface_property tx_st symbolsPerBeat 1
   set_interface_property tx_st ENABLED true
   set_interface_property tx_st associatedClock pld_clk
   add_interface_port tx_st tx_st_valid valid Input 1
   add_interface_port tx_st tx_st_sop startofpacket Input 1
   add_interface_port tx_st tx_st_eop endofpacket Input 1
   if { $dataWidth > 64 } {
      add_interface_port tx_st tx_st_empty empty Input 1
   } else {
      add_to_no_connect tx_st_empty 1 In
   }
   add_interface_port tx_st tx_st_ready ready Output 1
   add_interface_port tx_st tx_st_err error Input 1
   add_interface_port tx_st tx_st_data data Input $dataWidth
   # Parity
#   if { $ast_parity == 0 } {
#      add_to_no_connect tx_st_parity $dataByteWidth In
#   } else {
#      add_interface_port tx_st tx_st_parity# parity Input $dataByteWidth
#   }

   #Tx Fifo Information
   add_interface tx_fifo conduit end
   add_interface_port tx_fifo tx_fifo_empty fifo_empty Output 1
   add_to_no_connect tx_fifo_full 1 Out
   add_to_no_connect tx_fifo_rdp 4 Out
   add_to_no_connect tx_fifo_wrp 4 Out

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
#add_interface_port tx_cred tx_cred         tx_cred         Output 36

}

####################################################################################################
#
# AVMM HIP Reconfig
#
proc add_pcie_hip_port_hip_reconfig {} {

   send_message debug "proc:add_pcie_hip_port_hip_reconfig"
   set hip_reconfig_hwtcl [get_parameter_value hip_reconfig_hwtcl ]
   if {$hip_reconfig_hwtcl == 1 } {
      # +-----------------------------------
      # | hip_reconfig clock and reset
      # |
      add_interface      hip_reconfig_clk clock end
      add_interface_port hip_reconfig_clk hip_reconfig_clk clk Input 1

      add_interface          hip_reconfig_rst reset end
      add_interface_port     hip_reconfig_rst hip_reconfig_rst_n reset_n Input 1
      set_interface_property hip_reconfig_rst ASSOCIATED_CLOCK hip_reconfig_clk

      # +-----------------------------------
      # | connection point hip_reconfig
      # |
      add_interface          hip_reconfig avalon slave hip_reconfig_clk
      set_interface_property hip_reconfig addressAlignment DYNAMIC
      set_interface_property hip_reconfig writeWaitTime 0
      set_interface_property hip_reconfig ASSOCIATED_CLOCK hip_reconfig_clk

      add_interface_port hip_reconfig hip_reconfig_address   address        input  10
      add_interface_port hip_reconfig hip_reconfig_byte_en   byteenable     input  2
      add_interface_port hip_reconfig hip_reconfig_read      read           input  1
      add_interface_port hip_reconfig hip_reconfig_readdata  readdata       output 16
      add_interface_port hip_reconfig hip_reconfig_write     write          input  1
      add_interface_port hip_reconfig hip_reconfig_writedata writedata      input  16

      add_interface      hip_reconfig_ctrl conduit end
      add_interface_port hip_reconfig_ctrl ser_shift_load ser_shift_load Input  1
      add_interface_port hip_reconfig_ctrl interface_sel interface_sel Input  1
   } else {
      add_to_no_connect  hip_reconfig_clk       1  In
      add_to_no_connect  hip_reconfig_rst_n     1  In

      add_to_no_connect  hip_reconfig_address   10 In
      add_to_no_connect  hip_reconfig_byte_en   2  In
      add_to_no_connect  hip_reconfig_read      1  In
      add_to_no_connect  hip_reconfig_readdata  16 Out
      add_to_no_connect  hip_reconfig_write     1  In
      add_to_no_connect  hip_reconfig_writedata 16 In

      add_to_no_connect ser_shift_load          1  In
      add_to_no_connect interface_sel           1  In
   }
}


####################################################################################################
#
# Pipe interface conduit
#
proc add_pcie_hip_port_pipe {} {

   send_message debug "proc:add_pcie_hip_port_pipe"

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
      add_interface_port hip_pipe txswing0      txswing0       Output 1
      add_to_no_connect txswing1       1 Output
      add_to_no_connect txswing2       1 Output
      add_to_no_connect txswing3       1 Output
      add_to_no_connect txswing4       1 Output
      add_to_no_connect txswing5       1 Output
      add_to_no_connect txswing6       1 Output
      add_to_no_connect txswing7       1 Output
      add_interface_port hip_pipe txmargin0      txmargin0       Output 3
      add_to_no_connect txmargin1       3 Output
      add_to_no_connect txmargin2       3 Output
      add_to_no_connect txmargin3       3 Output
      add_to_no_connect txmargin4       3 Output
      add_to_no_connect txmargin5       3 Output
      add_to_no_connect txmargin6       3 Output
      add_to_no_connect txmargin7       3 Output
      add_interface_port hip_pipe txdeemph0      txdeemph0       Output 1
      add_to_no_connect txdeemph1       1 Output
      add_to_no_connect txdeemph2       1 Output
      add_to_no_connect txdeemph3       1 Output
      add_to_no_connect txdeemph4       1 Output
      add_to_no_connect txdeemph5       1 Output
      add_to_no_connect txdeemph6       1 Output
      add_to_no_connect txdeemph7       1 Output
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
      add_interface_port hip_pipe txmargin0      txmargin0       Output 3
      add_interface_port hip_pipe txmargin1      txmargin1       Output 3
      add_to_no_connect txmargin2      3 Output
      add_to_no_connect txmargin3      3 Output
      add_to_no_connect txmargin4      3 Output
      add_to_no_connect txmargin5      3 Output
      add_to_no_connect txmargin6      3 Output
      add_to_no_connect txmargin7      3 Output
      add_interface_port hip_pipe txswing0      txswing0       Output 1
      add_interface_port hip_pipe txswing1      txswing1       Output 1
      add_to_no_connect txswing2      1 Output
      add_to_no_connect txswing3      1 Output
      add_to_no_connect txswing4      1 Output
      add_to_no_connect txswing5      1 Output
      add_to_no_connect txswing6      1 Output
      add_to_no_connect txswing7      1 Output
      add_interface_port hip_pipe txdeemph0      txdeemph0       Output 1
      add_interface_port hip_pipe txdeemph1      txdeemph1       Output 1
      add_to_no_connect txdeemph2      1 Output
      add_to_no_connect txdeemph3      1 Output
      add_to_no_connect txdeemph4      1 Output
      add_to_no_connect txdeemph5      1 Output
      add_to_no_connect txdeemph6      1 Output
      add_to_no_connect txdeemph7      1 Output
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
      add_interface_port hip_pipe txswing0      txswing0       Output 1
      add_interface_port hip_pipe txswing1      txswing1       Output 1
      add_interface_port hip_pipe txswing2      txswing2       Output 1
      add_interface_port hip_pipe txswing3      txswing3       Output 1
      add_to_no_connect txswing4    1   Output
      add_to_no_connect txswing5    1   Output
      add_to_no_connect txswing6    1   Output
      add_to_no_connect txswing7    1   Output
      add_interface_port hip_pipe txmargin0      txmargin0       Output 3
      add_interface_port hip_pipe txmargin1      txmargin1       Output 3
      add_interface_port hip_pipe txmargin2      txmargin2       Output 3
      add_interface_port hip_pipe txmargin3      txmargin3       Output 3
      add_to_no_connect txmargin4    3   Output
      add_to_no_connect txmargin5    3   Output
      add_to_no_connect txmargin6    3   Output
      add_to_no_connect txmargin7    3   Output
      add_interface_port hip_pipe txdeemph0      txdeemph0       Output 1
      add_interface_port hip_pipe txdeemph1      txdeemph1       Output 1
      add_interface_port hip_pipe txdeemph2      txdeemph2       Output 1
      add_interface_port hip_pipe txdeemph3      txdeemph3       Output 1
      add_to_no_connect txdeemph4    1   Output
      add_to_no_connect txdeemph5    1   Output
      add_to_no_connect txdeemph6    1   Output
      add_to_no_connect txdeemph7    1   Output
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
     add_interface_port hip_pipe txswing0       txswing0        Output 1
     add_interface_port hip_pipe txswing1       txswing1        Output 1
     add_interface_port hip_pipe txswing2       txswing2        Output 1
     add_interface_port hip_pipe txswing3       txswing3        Output 1
     add_interface_port hip_pipe txswing4       txswing4        Output 1
     add_interface_port hip_pipe txswing5       txswing5        Output 1
     add_interface_port hip_pipe txswing6       txswing6        Output 1
     add_interface_port hip_pipe txswing7       txswing7        Output 1
     add_interface_port hip_pipe txmargin0      txmargin0       Output 3
     add_interface_port hip_pipe txmargin1      txmargin1       Output 3
     add_interface_port hip_pipe txmargin2      txmargin2       Output 3
     add_interface_port hip_pipe txmargin3      txmargin3       Output 3
     add_interface_port hip_pipe txmargin4      txmargin4       Output 3
     add_interface_port hip_pipe txmargin5      txmargin5       Output 3
     add_interface_port hip_pipe txmargin6      txmargin6       Output 3
     add_interface_port hip_pipe txmargin7      txmargin7       Output 3
     add_interface_port hip_pipe txdeemph0      txdeemph0       Output 1
     add_interface_port hip_pipe txdeemph1      txdeemph1       Output 1
     add_interface_port hip_pipe txdeemph2      txdeemph2       Output 1
     add_interface_port hip_pipe txdeemph3      txdeemph3       Output 1
     add_interface_port hip_pipe txdeemph4      txdeemph4       Output 1
     add_interface_port hip_pipe txdeemph5      txdeemph5       Output 1
     add_interface_port hip_pipe txdeemph6      txdeemph6       Output 1
     add_interface_port hip_pipe txdeemph7      txdeemph7       Output 1
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

}

####################################################################################################
#
# Serial interface conduit
#
proc add_pcie_hip_port_serial {} {

   send_message debug "proc:add_pcie_hip_port_serial"

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
proc add_pcie_hip_port_interrupt {} {

   send_message debug "proc:add_pcie_hip_port_interrupt"
   set port_type_hwtcl [ get_parameter_value porttype_func0_hwtcl ]
   set number_of_func_hwtcl [ get_parameter_value num_of_func_hwtcl ]

   add_interface int_msi conduit end

   if { $number_of_func_hwtcl == 1 } {
      add_to_no_connect app_msi_func 3 In
   } else {
      add_interface_port int_msi app_msi_func      app_msi_func      Input 3
   }

   set_interface_assignment int_msi "ui.blockdiagram.direction" "output"

   if { [ regexp Root $port_type_hwtcl ] } {
      add_interface_port int_msi serr_out    serr_out     Output 1
      add_interface_port int_msi aer_msi_num aer_msi_num  Input  5
      add_interface_port int_msi pex_msi_num pex_msi_num  Input  5
      add_to_no_connect app_msi_num 5 In
      add_to_no_connect app_msi_req 1 In
      add_to_no_connect app_msi_tc  3 In
      add_to_no_connect app_msi_ack 1 Out
      add_to_no_connect app_int_sts_vec 1 In
   } else {
      add_to_no_connect serr_out    1 Out
      add_to_no_connect aer_msi_num 5 In
      add_to_no_connect pex_msi_num 5 In
      add_interface_port int_msi app_msi_num       app_msi_num          Input  5
      add_interface_port int_msi app_msi_req       app_msi_req          Input  1
      add_interface_port int_msi app_msi_tc        app_msi_tc           Input  3
      add_interface_port int_msi app_msi_ack       app_msi_ack          Output 1
      if { $number_of_func_hwtcl == 1 } {
         add_interface_port int_msi app_int_sts_vec   app_int_sts       Input 1
      } else {
         add_interface_port int_msi app_int_sts_vec   app_int_sts       Input 8
         set_port_property  app_int_sts_vec VHDL_TYPE std_logic_vector
      }
   }

}


####################################################################################################
#
# LMI interface conduit
#
proc add_pcie_hip_port_lmi {} {

   send_message debug "proc:add_pcie_hip_port_lmi"
   set number_of_func_hwtcl [ get_parameter_value num_of_func_hwtcl ]

   add_interface lmi conduit end

   if { $number_of_func_hwtcl == 1 } {
      add_interface_port lmi lmi_addr lmi_addr  Input  12
      set_port_property  lmi_addr VHDL_TYPE std_logic_vector
   } else {
      add_interface_port lmi lmi_addr lmi_addr  Input  15
      set_port_property  lmi_addr VHDL_TYPE std_logic_vector
   }

   add_interface_port lmi lmi_din  lmi_din   Input  32
   add_interface_port lmi lmi_rden lmi_rden  Input  1
   add_interface_port lmi lmi_wren lmi_wren  Input  1
   add_interface_port lmi lmi_ack  lmi_ack   Output 1
   add_interface_port lmi lmi_dout lmi_dout  Output 32
}

####################################################################################################
#
# Power management interface conduit
#
proc add_pcie_hip_port_pw_mngt {} {

   send_message debug "proc:add_pcie_hip_port_pw_mngt"
   set number_of_func_hwtcl [ get_parameter_value num_of_func_hwtcl ]

   add_interface power_mngt conduit end

   add_interface_port power_mngt pm_auxpwr pm_auxpwr           Input   1
   add_interface_port power_mngt pm_data   pm_data             Input   10
   add_interface_port power_mngt pme_to_cr pme_to_cr           Input   1
   add_interface_port power_mngt pm_event  pm_event            Input   1
   if { $number_of_func_hwtcl == 1 } {
      add_to_no_connect pm_event_func 3 In
   } else {
      add_interface_port power_mngt pm_event_func  pm_event_func  Input   3

   }
   add_interface_port power_mngt pme_to_sr pme_to_sr           Output  1
}


####################################################################################################
#
# TL Cfg management interface conduit
#
proc add_pcie_hip_port_tl_cfg {} {

   send_message debug "proc:add_pcie_hip_port_tl_cfg"

   set number_of_func_hwtcl   [ get_parameter_value num_of_func_hwtcl ]
   set tl_cfg_sts_width       [ expr { (($number_of_func_hwtcl-1)*10) + 53 } ]

   add_interface config_tl conduit end
   add_interface_port config_tl tl_hpg_ctrl_er hpg_ctrler      Input  5
   add_interface_port config_tl tl_cfg_ctl     tl_cfg_ctl      Output 32
   add_interface_port config_tl cpl_err        cpl_err         Input  7

   if { $number_of_func_hwtcl == 1 } {
      add_to_no_connect cpl_err_func 3 In

      add_interface_port config_tl tl_cfg_add     tl_cfg_add      Output 4
      set_port_property  tl_cfg_add VHDL_TYPE std_logic_vector

   } else {
      add_interface_port config_tl cpl_err_func   cpl_err_func    Input  3
      add_interface_port config_tl tl_cfg_add     tl_cfg_add      Output 7
      set_port_property  tl_cfg_add VHDL_TYPE std_logic_vector
   }

   add_interface_port config_tl tl_cfg_ctl_wr  tl_cfg_ctl_wr   Output 1
   add_interface_port config_tl tl_cfg_sts_wr  tl_cfg_sts_wr   Output 1

   add_interface_port config_tl tl_cfg_sts     tl_cfg_sts      Output $tl_cfg_sts_width
   set_port_property  tl_cfg_sts VHDL_TYPE std_logic_vector

   add_interface_port config_tl cpl_pending    cpl_pending     Input  $number_of_func_hwtcl
   set_port_property  cpl_pending VHDL_TYPE std_logic_vector

   set_interface_assignment config_tl "ui.blockdiagram.direction" "output"

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
