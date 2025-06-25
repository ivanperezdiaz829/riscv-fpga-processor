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
# Power on reset
#
proc add_pcie_hip_port_clk_rst {} {

   add_interface coreclkout clock start
   add_interface_port coreclkout coreclkout clk Output 1

   add_interface refclk clock end
   add_interface_port refclk refclk clk Input 1

   add_interface npor conduit end
   add_interface_port npor npor npor Input 1
   add_interface_port npor pin_perst pin_perst Input 1

   add_interface nreset_status reset start coreclkout
   add_interface_port nreset_status reset_status reset_n Output 1
   set_interface_property nreset_status synchronousEdges both
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
   add_interface_port reconfig_from_xcvr  fixedclk_locked fixedclk_locked Output 1

   add_interface reconfig_clk_locked  conduit end
   add_interface_port reconfig_clk_locked  fixedclk_locked fixedclk_locked Output 1
}


proc add_pcie_hip_port_interrupt {} {

   add_interface MSI_Interface      conduit end
   add_interface_port MSI_Interface    MsiIntfc_o msi_intfc Output 82
   set_interface_assignment MSI_Interface "ui.blockdiagram.direction" "Input"

   add_interface MSIX_Interface      conduit end
   add_interface_port MSIX_Interface    MsixIntfc_o msix_intfc Output 16
   set_interface_assignment MSIX_Interface "ui.blockdiagram.direction" "Input"

   add_interface INTX_Interface      conduit end
   add_interface_port INTX_Interface    IntxReq_i intx_req Input 1
   add_interface_port INTX_Interface    IntxAck_o intx_ack Output 1
   set_interface_assignment INTX_Interface "ui.blockdiagram.direction" "Input"
}

proc add_pcie_hip_status_ext {} {  
	  set avmm_data_width  [ get_parameter_value avmm_width_hwtcl ]  
	  add_interface HIP_status_ext        conduit end
    add_interface_port  HIP_status_ext  rx_st_valid       rx_st_valid        output        1
    add_interface_port  HIP_status_ext  rx_st_sop         rx_st_sop          output        1
    add_interface_port  HIP_status_ext  rx_st_eop         rx_st_eop          output        1
    add_interface_port  HIP_status_ext  rx_st_err         rx_st_err          output        1
    add_interface_port  HIP_status_ext  rx_st_data        rx_st_data         output        $avmm_data_width
    add_interface_port  HIP_status_ext  rx_st_bar         rx_st_bar          output        8
    add_interface_port  HIP_status_ext  tx_st_ready       tx_st_ready        output        1
    add_interface_port  HIP_status_ext  pld_clk_inuse     pld_clk_inuse      output        1
    add_interface_port  HIP_status_ext  dlup_exit         dlup_exit          output        1
    add_interface_port  HIP_status_ext  hotrst_exit       hotrst_exit        output        1
    add_interface_port  HIP_status_ext  l2_exit           l2_exit            output        1
    add_interface_port  HIP_status_ext  currentspeed      currentspeed       output        2
    add_interface_port  HIP_status_ext  ltssmstate        ltssmstate         output        5  
    add_interface_port  HIP_status_ext  derr_cor_ext_rcv  derr_cor_ext_rcv   output        1
    add_interface_port  HIP_status_ext  derr_cor_ext_rpl  derr_cor_ext_rpl   output        1
    add_interface_port  HIP_status_ext  derr_rpl          derr_rpl           output        1
    add_interface_port  HIP_status_ext  int_status        int_status         output        4
    add_interface_port  HIP_status_ext  serr_out          serr_out           output        1
    add_interface_port  HIP_status_ext  tl_cfg_add        tl_cfg_add         output        4
    add_interface_port  HIP_status_ext  tl_cfg_ctl        tl_cfg_ctl         output        32
    add_interface_port  HIP_status_ext  tl_cfg_sts        tl_cfg_sts         output        53
    add_interface_port  HIP_status_ext  pme_to_sr         pme_to_sr          output        1
    add_interface_port  HIP_status_ext  lane_act          lane_act           output        4

}

####################################################################################################
#
# HIP Control conduit
#
proc add_pcie_hip_port_control {} {

   send_message debug "proc:add_pcie_hip_port_control"
   set enable_tl_only_sim_hwtcl   [ get_parameter_value enable_tl_only_sim_hwtcl ]
   add_interface hip_ctrl conduit end
   add_interface_port hip_ctrl test_in        test_in   Input 32
   add_interface_port hip_ctrl simu_mode_pipe simu_mode_pipe Input 1
    if { $enable_tl_only_sim_hwtcl == 1 } {
      add_interface_port hip_ctrl   tlbfm_in    tlbfm_in  Output 1001
      add_interface_port hip_ctrl   tlbfm_out   tlbfm_out  Input 1001
   } else {
      add_to_no_connect tlbfm_in    1001     out
      add_to_no_connect tlbfm_out   1001     in
   }

}





####################################################################################################
#
# HIP Status conduit
#
proc add_pcie_hip_port_status {} {

   send_message debug "proc:add_pcie_hip_port_status"

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

   add_interface hip_currentspeed conduit end
   add_interface_port hip_currentspeed currentspeed currentspeed Output 2

   set_interface_assignment hip_status "ui.blockdiagram.direction" "output"

}
####################################################################################################
#
# Avalon-MM RX
#
proc add_pcie_hip_port_avmm_rxmaster {} {

   set CB_PCIE_MODE     [ get_parameter_value CB_PCIE_MODE ]
   set rx_lite_core [ get_parameter_value CB_PCIE_RX_LITE ]
   set isCRA  [get_parameter_value CG_IMPL_CRA_AV_SLAVE_PORT]
   set port_type [get_parameter_value port_type_hwtcl]
   set avmm_data_width  [ get_parameter_value avmm_width_hwtcl ]
   set avmm_address_width  [ get_parameter_value AVALON_ADDR_WIDTH ]
  # set rxm_data_width   [expr $CB_PCIE_MODE == 2   ? 32 :  64 ]
#   set bar_type_list [split [ get_parameter_value "BAR Type" ] ","]

   if { $rx_lite_core == 0 } {
       set rxm_data_width $avmm_data_width
   } else {
      set rxm_data_width 32
   }

   if { $rxm_data_width == 128 } {
         set rxm_burst_count_width 6
    } else {
         set rxm_burst_count_width 7
    }

   # Previous BAR was 64-bit Bar64_prev
   set Bar64_prev 0
   set BarUsed 0

   # Keep track of whether we added Interupt Receiver yet
   set rxm_irq_bar 99

   for { set i 0 } { $i < 6 } { incr i } {

      set bar_type [ get_parameter_value "bar${i}_type_hwtcl" ]
       # set BarUsed        [ expr [ $bar_type > 0  ] ?  1  : 0  ]

      if { $bar_type > 0 } {
         set BarUsed 1
      } elseif { ( $i==1 ||$i==3 || $i ==5) && ( $Bar64_prev == 1) } {
         set BarUsed 0
      } else {
         set BarUsed 0
      }

      if { $BarUsed == 1 } {
         add_interface          "Rxm_BAR${i}" "avalon" "master" "coreclkout"
         set_interface_property "Rxm_BAR${i}" "interleaveBursts" "false"
         set_interface_property "Rxm_BAR${i}" "doStreamReads" "false"
         set_interface_property "Rxm_BAR${i}" "doStreamWrites" "false"
         set_interface_property "Rxm_BAR${i}" "maxAddressWidth" $avmm_address_width
         set_interface_property "Rxm_BAR${i}" "addressGroup" ${i}

         # Ports in interface $master_name
         add_interface_port     "Rxm_BAR${i}"  "RxmAddress_${i}_o" "address" "output" $avmm_address_width
         add_interface_port     "Rxm_BAR${i}"  "RxmRead_${i}_o" "read" "output" 1
         add_interface_port     "Rxm_BAR${i}"  "RxmWaitRequest_${i}_i" "waitrequest" "input" 1
         add_interface_port     "Rxm_BAR${i}"  "RxmWrite_${i}_o" "write" "output" 1
         add_interface_port     "Rxm_BAR${i}"  "RxmReadDataValid_${i}_i" "readdatavalid" "input" 1
         add_interface_port "Rxm_BAR${i}" "RxmReadData_${i}_i" "readdata" "input" $rxm_data_width
         add_interface_port "Rxm_BAR${i}" "RxmWriteData_${i}_o" "writedata" "output" $rxm_data_width
           if { $rx_lite_core == 0 } {
              add_interface_port "Rxm_BAR${i}" "RxmBurstCount_${i}_o" "burstcount" "output" $rxm_burst_count_width
             }
         add_interface_port "Rxm_BAR${i}" "RxmByteEnable_${i}_o" "byteenable" "output" [ expr $rxm_data_width/8 ]

      }

      if { $bar_type == 1 } {
         set Bar64_prev 1
      } else {
         set Bar64_prev 0
      }

   }

 if { [ regexp Root $port_type ] } {
         add_interface          "RP_Master" "avalon" "master" "coreclkout"
         set_interface_property "RP_Master" "interleaveBursts" "false"
         set_interface_property "RP_Master" "doStreamReads" "false"
         set_interface_property "RP_Master" "doStreamWrites" "false"
         set_interface_property "RP_Master" "maxAddressWidth" $avmm_address_width
         set_interface_property "RP_Master" "addressGroup" 0

         add_interface_port     "RP_Master"  "RxmAddress_0_o" "address" "output" $avmm_address_width
         add_interface_port     "RP_Master"  "RxmRead_0_o" "read" "output" 1
         add_interface_port     "RP_Master"  "RxmWaitRequest_0_i" "waitrequest" "input" 1
         add_interface_port     "RP_Master"  "RxmWrite_0_o" "write" "output" 1
         add_interface_port     "RP_Master"  "RxmReadDataValid_0_i" "readdatavalid" "input" 1
         add_interface_port     "RP_Master"  "RxmReadData_0_i" "readdata" "input" $rxm_data_width
         add_interface_port     "RP_Master"  "RxmWriteData_0_o" "writedata" "output" $rxm_data_width
         add_interface_port     "RP_Master" "RxmBurstCount_0_o" "burstcount" "output" $rxm_burst_count_width
         add_interface_port     "RP_Master" "RxmByteEnable_0_o" "byteenable" "output" [ expr $rxm_data_width/8 ]

}




      # RxmIrq port
       if { $isCRA == 1 } {
          add_interface "RxmIrq" "interrupt" "receiver" "coreclkout"
          set_interface_property "RxmIrq" "irqScheme" "individualRequests"
        if { [ regexp endpoint $port_type ] } {
          set_interface_property "RxmIrq" "associatedAddressablePoint" "Rxm_BAR0"
        } else {
                 set_interface_property "RxmIrq" "associatedAddressablePoint" "RP_Master"
        }
          add_interface_port "RxmIrq" "RxmIrq_i" "irq" "input" [ get_parameter_value CG_RXM_IRQ_NUM ]
        }

}

proc add_pcie_hip_port_avmm_txslave {} {

   # +-----------------------------------
   # | connection point Txs Slave
   # |
   # Interface Txs Slave

   set txs_data_width  [ get_parameter_value avmm_width_hwtcl ]
   set TX_S_ADDR_WIDTH     [ get_parameter_value TX_S_ADDR_WIDTH ]
   send_message info "TXS ADDRESS WIDTH is $TX_S_ADDR_WIDTH"


    if { $txs_data_width == 128 } {
         set txs_burst_count_width 6
    } else {
         set txs_burst_count_width 7
    }
   add_interface          Txs "avalon" "slave" "coreclkout"
   set_interface_property Txs "addressAlignment" "DYNAMIC"
   set_interface_property Txs "interleaveBursts" "false"
   set_interface_property Txs "readLatency" "0"
   set_interface_property Txs "writeWaitTime" "1"
   set_interface_property Txs "readWaitTime" "1"
   set_interface_property Txs "addressUnits" "SYMBOLS"
   set_interface_property Txs "maximumPendingReadTransactions" 8

   add_interface_port     Txs "TxsAddress_i" "address" "input" $TX_S_ADDR_WIDTH
   add_interface_port     Txs "TxsChipSelect_i" "chipselect" "input" 1
   add_interface_port     Txs "TxsByteEnable_i" "byteenable" "input" [ expr $txs_data_width/8 ]
   add_interface_port     Txs "TxsReadData_o" "readdata" "output" $txs_data_width
   add_interface_port     Txs "TxsWriteData_i" "writedata" "input" $txs_data_width
   add_interface_port     Txs "TxsRead_i" "read" "input" 1
   add_interface_port     Txs "TxsWrite_i" "write" "input" 1
   add_interface_port     Txs "TxsBurstCount_i" "burstcount" "input" $txs_burst_count_width
   add_interface_port     Txs "TxsReadDataValid_o" "readdatavalid" "output" 1
   add_interface_port     Txs "TxsWaitRequest_o" "waitrequest" "output" 1

}

proc add_pcie_hip_port_avmm_cra_craIrq {} {

   add_interface          Cra "avalon" "slave" "coreclkout"
   set_interface_property Cra "readLatency" "0"
   set_interface_property Cra "addressAlignment" "DYNAMIC"
   set_interface_property Cra "writeWaitTime" "1"
   set_interface_property Cra "readWaitTime" "1"
   # Ports in interface Cra
   add_interface_port     Cra "CraChipSelect_i" "chipselect" "input" 1
   add_interface_port     Cra "CraAddress_i" "address" "input" 12
   add_interface_port     Cra "CraByteEnable_i" "byteenable" "input" 4
   add_interface_port     Cra "CraRead" "read" "input" 1
   add_interface_port     Cra "CraReadData_o" "readdata" "output" 32
   add_interface_port     Cra "CraWrite" "write" "input" 1
   add_interface_port     Cra "CraWriteData_i" "writedata" "input" 32
   add_interface_port     Cra "CraWaitRequest_o" "waitrequest" "output" 1

   add_interface          CraIrq interrupt sender
   add_interface_port     CraIrq CraIrq_o irq output 1
   set_interface_property CraIrq associatedAddressablePoint Cra

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
