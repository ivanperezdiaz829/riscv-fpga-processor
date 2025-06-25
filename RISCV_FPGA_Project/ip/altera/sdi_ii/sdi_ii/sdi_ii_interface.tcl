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


# +-----------------------------------
# | Add Clock interface and port of same name
# | 
# | $port_dir - can be 'input' or 'output'
proc common_add_clock { port_name port_dir used } {
  global common_composed_mode
  array set in_out [list {output} {start} {input} {end} ]
  add_interface $port_name clock $in_out($port_dir)
  if {$common_composed_mode == 0} {
    set_interface_property $port_name ENABLED $used
    add_interface_port $port_name $port_name clk $port_dir 1
  } else {
    # create clock source instance for composed mode
    add_instance $port_name clock_source
    set_interface_property $port_name export_of $port_name.clk_in
  }  
}

# +-----------------------------------
# | Add Clock interface and port of same name
# | 
# | $port_dir - can be 'input' or 'output'
# | $port_width - indicate how many bits is this clock
proc common_add_clock_bus { port_name port_dir used port_width} {
  global common_composed_mode
  array set in_out [list {output} {start} {input} {end} ]
  add_interface $port_name clock $in_out($port_dir)
  if {$common_composed_mode == 0} {
    set_interface_property $port_name ENABLED $used
    add_interface_port $port_name $port_name clk $port_dir $port_width
  } else {
    # create clock source instance for composed mode
    add_instance $port_name clock_source
    set_interface_property $port_name export_of $port_name.clk_in
  }  
}



# +-----------------------------------
# | Add Reset interface and port of same name
# | 
# | $port_dir - can be 'input' or 'output'
# | $associated_clk - which clock is this reset associated with
proc common_add_reset { port_name port_dir associated_clk } {
  array set in_out [list {output} {start} {input} {end} ]
  add_interface $port_name reset $in_out($port_dir)
  set_interface_property $port_name ASSOCIATED_CLOCK $associated_clk
  add_interface_port $port_name $port_name reset $port_dir 1
}

# +-----------------------------------
# | Add Reset interface and port of same name 
# | 
# | $port_dir - can be 'input' or 'output'
# | $associated_clk - which clock is this reset associated with
# | $associated_clk - which input reset is this reset associated with
proc common_add_reset_associated_sinks { port_name port_dir associated_clk sinks} {
  array set in_out [list {output} {start} {input} {end} ]
  add_interface $port_name reset $in_out($port_dir)
  set_interface_property $port_name ASSOCIATED_CLOCK $associated_clk  
  add_interface_port $port_name $port_name reset $port_dir 1
  set_interface_property $port_name associatedResetSinks $sinks

}




# +-----------------------------------
# | Add optional conduit interface and port of same name
# | 
# | $port_dir - can be 'input' or 'output'
# | $used     - can be 'true' or 'false'
proc common_add_optional_conduit { port_name signal_type port_dir width used } {
  global common_composed_mode
  array set in_out [list {output} {start} {input} {end} ]
  add_interface $port_name conduit $in_out($port_dir)
  set_interface_assignment $port_name "ui.blockdiagram.direction" $port_dir
  if {$common_composed_mode == 0} {
    set_interface_property $port_name ENABLED $used
    add_interface_port $port_name $port_name $signal_type $port_dir $width
  }
}

# +---------------------------------------------------------------------------
# proc: add_export_rename_interface
#
# Renames all ports on the interface of the supplied instance to be named the
# same as the instance ports. This is used when exporting the interface but
# wanting to keep the ports named appended with instance name.
#
proc add_export_rename_interface {instance interface interface_type port_dir} {
  array set in_out [list {output} {start} {input} {end}]
  add_interface ${instance}_${interface} $interface_type $in_out($port_dir)
  set_interface_property ${instance}_${interface} export_of $instance.$interface
  set port_map [list]
  lappend port_map ${instance}_${interface}
  lappend port_map $interface    
  set_interface_property ${instance}_${interface} PORT_NAME_MAP $port_map
}

# +---------------------------------------------------------------------------
# proc: add_export_free_rename_interface
#
# Freely renames all ports on the interface of with supplied input name and 
# desired output name
#
proc add_export_free_rename_interface {instance interface_int interface_ext interface_type port_dir} {
  array set in_out [list {output} {start} {input} {end}]
  add_interface ${interface_ext} $interface_type $in_out($port_dir)
  set_interface_property ${interface_ext} export_of $instance.$interface_int
  set port_map [list]
  lappend port_map $interface_ext
  lappend port_map $interface_int    
  set_interface_property ${interface_ext} PORT_NAME_MAP $port_map
}


# +---------------------------------------------------------------------------
# proc: add_export_interface
#
# Add and export interface without renaming
#
proc add_export_interface {instance interface interface_type port_dir} {
  array set in_out [list {output} {start} {input} {end}]
  add_interface ${interface} $interface_type $in_out($port_dir)
  set_interface_property ${interface} export_of $instance.$interface
  set port_map [list]
  lappend port_map $interface
  lappend port_map $interface    
  set_interface_property ${interface} PORT_NAME_MAP $port_map
}

proc add_export_interface_b {instance interface interface_type port_dir} {
  array set in_out [list {output} {start} {input} {end}]
  add_interface ${interface}_b $interface_type $in_out($port_dir)
  set_interface_property ${interface}_b export_of $instance.$interface
  set port_map [list]
  lappend port_map $interface
  lappend port_map $interface    
  set_interface_property ${interface}_b PORT_NAME_MAP $port_map
}

# +-----------------------------------------------------------------------------
# proc: propagate_params
#
# Propagate the parameters of current instance to the lower level instances
#
proc propagate_params {instance} {
  foreach param_name [get_instance_parameters $instance] {
    #_dprint 1 "Assigning parameter $param_name = [get_parameter_value $param_name] for dut"
    set_instance_parameter $instance $param_name [get_parameter_value $param_name]
  }
}

# +--------------------------------------------------------
# | 2011-09-19
#
# Add, export and rename interface in example design level
#
proc tx_protocol__add_export_rename_interface {instance std dl_sync insert_vpid trs_test frame_test} {

  if { $std != "sd" } {
    add_export_rename_interface $instance tx_enable_crc     conduit input
    add_export_rename_interface $instance tx_enable_ln      conduit input
  }
  if { $insert_vpid } {
    # add_export_rename_interface $instance tx_enable_vpid_c  conduit input
    add_export_rename_interface $instance tx_vpid_overwrite  conduit input
  }
  if { $dl_sync | $trs_test | $frame_test } {
    add_export_rename_interface $instance tx_datain          conduit input
    add_export_rename_interface $instance tx_datain_valid    conduit input
    add_export_rename_interface $instance tx_trs             conduit input
    if { $std == "dl" } {
      add_export_rename_interface $instance tx_datain_b        conduit input
      add_export_rename_interface $instance tx_datain_valid_b  conduit input
      add_export_rename_interface $instance tx_trs_b           conduit input
    }
  }
  if { $std == "threeg" | $std == "ds" | $std == "tr" } {
    add_export_rename_interface $instance tx_std        conduit input
  }

  #if { $std == "dl" } {
  #  add_export_rename_interface $instance tx_enable_crc_b conduit input
  #  add_export_rename_interface $instance tx_enable_ln_b  conduit input
  #}
}

proc tx_phy_mgmt__add_export_rename_interface {instance config std} {
  if {$config == "xcvr"} {
    #add_export_rename_interface $instance tx_std     conduit input
  }
  add_export_rename_interface $instance tx_dataout_valid conduit output

  if { $std == "dl" } {
    add_export_rename_interface $instance tx_dataout_valid_b conduit output
  }
}

proc tx_phy__add_export_rename_interface {instance std xcvr_tx_pll_sel} {
  add_export_rename_interface $instance sdi_tx            conduit output
  add_export_rename_interface $instance tx_pll_locked     conduit output
  
  if { $xcvr_tx_pll_sel } {
    add_export_rename_interface    $instance  tx_pll_locked_alt   conduit  output
  }

  if { $std == "dl" } {
    add_export_rename_interface $instance sdi_tx_b            conduit output
  #add_export_rename_interface $instance tx_pll_locked_b     conduit output
  }
}

proc rx_phy__add_export_rename_interface {instance std} {
  add_export_rename_interface $instance sdi_rx              conduit input
  add_export_rename_interface $instance rx_pll_locked       conduit output

  if { $std == "dl" } {
    add_export_rename_interface $instance sdi_rx_b              conduit input
    add_export_rename_interface $instance rx_pll_locked_b       conduit output
  }
}

proc rx_phy_mgmt__add_export_rename_interface {instance std} {
  # add_export_rename_interface $instance rx_enable_sd_search conduit input
  # add_export_rename_interface $instance rx_enable_hd_search conduit input
  # add_export_rename_interface $instance rx_enable_3g_search conduit input
  add_export_rename_interface $instance rx_rst_proto_out        conduit output

  if { $std != "sd" } {
    add_export_rename_interface $instance rx_coreclk_is_ntsc_paln conduit input
    add_export_rename_interface $instance rx_clkout_is_ntsc_paln  conduit output
  }

  if { $std == "ds" | $std == "tr" } {
    add_export_rename_interface $instance rx_sdi_start_reconfig conduit output
  }

  if { $std == "threeg" | $std == "ds" | $std == "tr" } {
    add_export_rename_interface $instance rx_std              conduit output
  }
}

proc rx_protocol__add_export_rename_interface {instance std crc_err vpid_bytes_out } {
  if { $std == "threeg" | $std == "ds" | $std == "tr" } {
    add_export_rename_interface $instance rx_std           conduit output
  }
  
  add_export_rename_interface $instance rx_align_locked  conduit output
  add_export_rename_interface $instance rx_trs_locked    conduit output
  add_export_rename_interface $instance rx_frame_locked  conduit output
  add_export_rename_interface $instance rx_f             conduit output
  add_export_rename_interface $instance rx_v             conduit output
  add_export_rename_interface $instance rx_h             conduit output
  add_export_rename_interface $instance rx_ap            conduit output
  add_export_rename_interface $instance rx_format        conduit output
  add_export_rename_interface $instance rx_eav           conduit output
  add_export_rename_interface $instance rx_trs           conduit output

  if { $crc_err } {
    add_export_rename_interface $instance rx_crc_error_c   conduit output
    add_export_rename_interface $instance rx_crc_error_y   conduit output
    if { $std == "threeg" | $std == "dl" | $std == "tr" } {
      add_export_rename_interface $instance rx_crc_error_c_b conduit output
      add_export_rename_interface $instance rx_crc_error_y_b conduit output
    }
  }

  if { $std != "sd" } {
    add_export_rename_interface $instance rx_ln            conduit output
  }
  if { $std == "threeg" | $std == "dl" | $std == "tr" } {
    add_export_rename_interface $instance rx_ln_b          conduit output
  }

  # if { $trs_misc } {
    # add_export_rename_interface $instance rx_xyz           conduit output
    # add_export_rename_interface $instance rx_xyz_valid     conduit output
  # }

  #add_export_rename_interface $instance rx_anc_dataout   conduit output
  #add_export_rename_interface $instance rx_anc_valid     conduit output
  #add_export_rename_interface $instance rx_anc_error     conduit output
  add_export_rename_interface $instance rx_dataout       conduit output
  add_export_rename_interface $instance rx_dataout_valid conduit output
  #add_export_rename_interface $instance rx_clkout        clock   output

  if { $std == "dl" } {
    add_export_rename_interface $instance rx_align_locked_b  conduit output
    add_export_rename_interface $instance rx_trs_locked_b    conduit output
    add_export_rename_interface $instance rx_frame_locked_b  conduit output
    add_export_rename_interface $instance rx_dataout_b       conduit output
    add_export_rename_interface $instance rx_dataout_valid_b conduit output
    add_export_rename_interface $instance rx_dl_locked       conduit output
  }

  if { $vpid_bytes_out } {
    add_export_rename_interface $instance rx_vpid_byte1             conduit output
    add_export_rename_interface $instance rx_vpid_byte2             conduit output
    add_export_rename_interface $instance rx_vpid_byte3             conduit output
    add_export_rename_interface $instance rx_vpid_byte4             conduit output
    add_export_rename_interface $instance rx_vpid_valid             conduit output
    add_export_rename_interface $instance rx_vpid_checksum_error    conduit output
    add_export_rename_interface $instance rx_line_f0                conduit output
    add_export_rename_interface $instance rx_line_f1                conduit output
    if { $std == "dl" | $std == "threeg" | $std == "tr"} {
      add_export_rename_interface $instance rx_vpid_byte1_b           conduit output
      add_export_rename_interface $instance rx_vpid_byte2_b           conduit output
      add_export_rename_interface $instance rx_vpid_byte3_b           conduit output
      add_export_rename_interface $instance rx_vpid_byte4_b           conduit output
      add_export_rename_interface $instance rx_vpid_valid_b           conduit output
      add_export_rename_interface $instance rx_vpid_checksum_error_b  conduit output
    }
  }
}

# -----------------------------
# 2011-09-21
# Add connection in core level
#
proc add_tx_protocol__tx_phy_mgmt_connection {instance1 instance2 config std}  {
  if { $config == "xcvr_proto" } { 
    if { $std == "threeg" | $std == "ds" | $std == "tr" } {
      add_connection  ${instance1}.tx_std_out     ${instance2}.tx_std
    }
  }
  add_connection    ${instance1}.tx_dataout       ${instance2}.tx_datain
  add_connection    ${instance1}.tx_dataout_valid ${instance2}.tx_datain_valid
  if { $std == "dl" } {
    add_connection  ${instance1}.tx_dataout_b       ${instance2}.tx_datain_b
    add_connection  ${instance1}.tx_dataout_valid_b ${instance2}.tx_datain_valid_b
  }
}

proc add_tx_phy_mgmt__phy_connection {instance1 instance2 std dir device}  {
  add_connection  ${instance1}.xcvr_tx_dataout       ${instance2}.xcvr_tx_datain
  if { $std == "dl" } {  
     add_connection ${instance1}.xcvr_tx_dataout_b        ${instance2}.xcvr_tx_datain_b 
  }
  
  
  #if { $device == "Stratix V" || $device == "Arria V" || $device == "Arria V GZ" } {
  #  if { $dir == "tx"} {
  #    add_connection  ${instance1}.phy_mgmt_address      ${instance2}.phy_mgmt_address
  #    add_connection  ${instance1}.phy_mgmt_read         ${instance2}.phy_mgmt_read
  #    add_connection  ${instance2}.phy_mgmt_readdata     ${instance1}.phy_mgmt_readdata
  #    add_connection  ${instance2}.phy_mgmt_waitrequest  ${instance1}.phy_mgmt_waitrequest
  #    add_connection  ${instance1}.phy_mgmt_write        ${instance2}.phy_mgmt_write
  #    add_connection  ${instance1}.phy_mgmt_writedata    ${instance2}.phy_mgmt_writedata
  #    if { $std == "dl" } {
  #      add_connection  ${instance1}.phy_mgmt_address_b      ${instance2}.phy_mgmt_address_b
  #      add_connection  ${instance1}.phy_mgmt_read_b         ${instance2}.phy_mgmt_read_b
  #      add_connection  ${instance2}.phy_mgmt_readdata_b     ${instance1}.phy_mgmt_readdata_b
  #      add_connection  ${instance2}.phy_mgmt_waitrequest_b  ${instance1}.phy_mgmt_waitrequest_b
  #      add_connection  ${instance1}.phy_mgmt_write_b        ${instance2}.phy_mgmt_write_b
  #      add_connection  ${instance1}.phy_mgmt_writedata_b    ${instance2}.phy_mgmt_writedata_b
  #    } 
  #  }
  #}
}

proc add_phy_xcvr_connection {instance1 instance2 dir device} {

  if { $device == "Arria 10" } {
     if { $dir == "tx" || $dir == "du" } {
        add_connection    ${instance1}.tx_std_coreclkin             ${instance2}.tx_coreclkin
        add_connection    ${instance1}.tx_serial_clkout             ${instance2}.tx_serial_clk0
        add_connection    ${instance1}.tx_pll_refclk                u_tx_pll.pll_refclk0
        add_connection    u_tx_pll.tx_serial_clk                    ${instance1}.tx_serial_clkin
        add_connection    ${instance2}.tx_clkout                    ${instance1}.tx_clkout_from_xcvr
     }

     if { $dir == "rx" || $dir == "du" } {
        add_connection    ${instance1}.rx_std_coreclkin             ${instance2}.rx_coreclkin
        add_connection    ${instance1}.rx_cdr_refclk                ${instance2}.rx_cdr_refclk0
        add_connection    ${instance2}.rx_clkout                    ${instance1}.rxclk_from_xcvr
     }

  } else {
     add_connection       ${instance1}.xcvr_reconfig_to_xcvr        ${instance2}.reconfig_to_xcvr
     add_connection       ${instance1}.xcvr_reconfig_from_xcvr      ${instance2}.reconfig_from_xcvr

     if { $dir == "tx" || $dir == "du" } {
        add_connection    ${instance1}.tx_std_coreclkin             ${instance2}.tx_std_coreclkin
        add_connection    ${instance1}.tx_pll_refclk                ${instance2}.tx_pll_refclk
        add_connection    ${instance1}.tx_clkout_from_xcvr          ${instance2}.tx_std_clkout
     }

     if { $dir == "rx" || $dir == "du" } {
        add_connection    ${instance1}.rx_cdr_refclk                ${instance2}.rx_cdr_refclk
        add_connection    ${instance1}.rx_std_coreclkin             ${instance2}.rx_std_coreclkin
        add_connection    ${instance1}.rxclk_from_xcvr              ${instance2}.rx_std_clkout
        add_connection    ${instance1}.rx_pma_clkout                ${instance2}.rx_pma_clkout
     }
  }

  if { $dir == "tx" || $dir == "du" } {
     add_connection       ${instance1}.tx_datain_to_xcvr            ${instance2}.tx_parallel_data
     add_connection       ${instance1}.sdi_tx_from_xcvr             ${instance2}.tx_serial_data
     add_connection       ${instance1}.tx_pll_locked_from_xcvr      pll_locked_fanout.sig_fanout1
  }

  if { $dir == "rx" || $dir == "du" } {
     add_connection       ${instance1}.rx_dataout_from_xcvr         ${instance2}.rx_parallel_data
     add_connection       ${instance1}.sdi_rx_to_xcvr               ${instance2}.rx_serial_data
     add_connection       ${instance1}.rxpll_locked_from_xcvr       ${instance2}.rx_is_lockedtoref
     add_connection       ${instance1}.xcvr_rx_is_lockedtodata      ${instance2}.rx_is_lockedtodata

     add_connection       ${instance1}.rx_set_locktodata_to_xcvr    ${instance2}.rx_set_locktodata
     add_connection       ${instance1}.rx_set_locktoref_to_xcvr     ${instance2}.rx_set_locktoref
  } 

}

proc add_phy_xcvr_b_connection {instance1 instance2 dir device} {

  if { $device == "Arria 10" } {
     if { $dir == "tx" || $dir == "du" } {
        add_connection    ${instance1}.tx_std_coreclkin_b           ${instance2}.tx_coreclkin
        add_connection    ${instance1}.tx_serial_clkout_b           ${instance2}.tx_serial_clk0
        add_connection    ${instance1}.tx_pll_refclk_b              u_tx_pll_b.pll_refclk0
        add_connection    u_tx_pll_b.tx_serial_clk                  ${instance1}.tx_serial_clkin_b
        add_connection    ${instance2}.tx_clkout                    ${instance1}.tx_clkout_from_xcvr_b
     }

     if { $dir == "rx" || $dir == "du" } {
        add_connection    ${instance1}.rx_std_coreclkin_b           ${instance2}.rx_coreclkin
        add_connection    ${instance1}.rx_cdr_refclk_b              ${instance2}.rx_cdr_refclk0
        add_connection    ${instance2}.rx_clkout                    ${instance1}.rxclk_from_xcvr_b
     }

  } else {
     add_connection       ${instance1}.xcvr_reconfig_to_xcvr_b      ${instance2}.reconfig_to_xcvr
     add_connection       ${instance1}.xcvr_reconfig_from_xcvr_b    ${instance2}.reconfig_from_xcvr 

     if { $dir == "tx" || $dir == "du" } {
        add_connection    ${instance1}.tx_std_coreclkin_b           ${instance2}.tx_std_coreclkin
        add_connection    ${instance1}.tx_pll_refclk_b              ${instance2}.tx_pll_refclk
        add_connection    ${instance1}.tx_clkout_from_xcvr_b        ${instance2}.tx_std_clkout
     }

     if { $dir == "rx" || $dir == "du" } {
        add_connection    ${instance1}.rx_cdr_refclk_b              ${instance2}.rx_cdr_refclk
        add_connection    ${instance1}.rx_std_coreclkin_b           ${instance2}.rx_std_coreclkin
        add_connection    ${instance1}.rxclk_from_xcvr_b            ${instance2}.rx_std_clkout
        add_connection    ${instance1}.rx_pma_clkout_b              ${instance2}.rx_pma_clkout
     }
  }

  if { $dir == "tx" || $dir == "du" } {
     add_connection       ${instance1}.tx_datain_to_xcvr_b          ${instance2}.tx_parallel_data
     add_connection       ${instance1}.sdi_tx_from_xcvr_b           ${instance2}.tx_serial_data
  }

  if { $dir == "rx" || $dir == "du" } {
     add_connection       ${instance1}.rx_dataout_from_xcvr_b       ${instance2}.rx_parallel_data
     add_connection       ${instance1}.sdi_rx_to_xcvr_b             ${instance2}.rx_serial_data
     add_connection       ${instance1}.rxpll_locked_from_xcvr_b     ${instance2}.rx_is_lockedtoref
     add_connection       ${instance1}.xcvr_rx_is_lockedtodata_b    ${instance2}.rx_is_lockedtodata
     add_connection       ${instance1}.rx_set_locktodata_to_xcvr_b  ${instance2}.rx_set_locktodata
     add_connection       ${instance1}.rx_set_locktoref_to_xcvr_b   ${instance2}.rx_set_locktoref
  }
}

proc add_phy__rx_phy_mgmt_connection {instance1 instance2 std device}  {
  if { $device == "Stratix IV" } {
     add_connection  ${instance1}.gxb_ltr          ${instance2}.gxb_ltr
     add_connection  ${instance1}.gxb_ltd          ${instance2}.gxb_ltd
     add_connection  ${instance1}.gxb_rst_analog   ${instance2}.gxb_rst_analog
     add_connection  ${instance1}.gxb_rc_dig_rst   ${instance2}.gxb_rc_dig_rst

     if { $std == "dl" } {
        add_connection  ${instance1}.gxb_ltr_b          ${instance2}.gxb_ltr_b
        add_connection  ${instance1}.gxb_ltd_b          ${instance2}.gxb_ltd_b
        add_connection  ${instance1}.gxb_rst_analog_b   ${instance2}.gxb_rst_analog_b
        add_connection  ${instance1}.gxb_rc_dig_rst_b   ${instance2}.gxb_rc_dig_rst_b
     }
  } else {
     # V-series family
     add_connection  ${instance1}.xcvr_rxclk            ${instance2}.xcvr_rxclk
     add_connection  ${instance1}.xcvr_rx_dataout       ${instance2}.rx_datain
     add_connection  ${instance1}.rx_pll_locked         ${instance2}.rx_pll_locked

     add_connection  ${instance1}.xcvr_rx_ready         ${instance2}.rx_ready
     if { $std == "dl" } {
        add_connection  ${instance1}.xcvr_rxclk_b            ${instance2}.xcvr_rxclk_b
        add_connection  ${instance1}.xcvr_rx_dataout_b       ${instance2}.rx_datain_b
        add_connection  ${instance1}.rx_pll_locked_b         ${instance2}.rx_pll_locked_b
        add_connection  ${instance1}.xcvr_rx_ready_b         ${instance2}.rx_ready_b
     }

     add_connection  ${instance1}.rx_set_locktoref        ${instance2}.gxb_ltr
     add_connection  ${instance1}.rx_set_locktodata       ${instance2}.gxb_ltd
     add_connection  ${instance1}.trig_rst_ctrl           ${instance2}.trig_rst_ctrl
     if { $std == "dl" } {
        add_connection  ${instance1}.rx_set_locktoref_b   ${instance2}.gxb_ltr_b
        add_connection  ${instance1}.rx_set_locktodata_b  ${instance2}.gxb_ltd_b
        add_connection  ${instance1}.trig_rst_ctrl_b      ${instance2}.trig_rst_ctrl_b
     }
  }
}

proc add_rx_phy_mgmt__rx_protocol_connection {instance1 instance2 std} {
  add_connection  ${instance1}.rx_trs_loose_lock_in   ${instance2}.rx_trs_loose_lock_out  
  add_connection  ${instance1}.rx_rst_proto_out       ${instance2}.rx_rst_proto_in
  #add_clk_bridge  rx_clkin
  #add_connection  rx_clkin_bridge.out_clk            ${instance2}.rx_clkin
  add_connection  ${instance1}.rx_clkout              ${instance2}.rx_clkin
  add_connection  ${instance1}.rx_dataout             ${instance2}.rx_datain
  add_connection  ${instance1}.rx_dataout_valid       ${instance2}.rx_datain_valid

  if { $std == "threeg" | $std == "ds" | $std == "tr" } {
    add_connection  ${instance1}.rx_std            ${instance2}.rx_std_in
  }

  if { $std == "dl" } {
    add_connection  ${instance1}.rx_trs_loose_lock_in_b  ${instance2}.rx_trs_loose_lock_out_b
    add_connection  ${instance1}.rx_rst_proto_out_b      ${instance2}.rx_rst_proto_in_b 
    #add_clk_bridge  rx_clkin_b
    #add_connection  rx_clkin_b_bridge.out_clk           ${instance2}.rx_clkin_b
    add_connection  ${instance1}.rx_clkout_b             ${instance2}.rx_clkin_b
    add_connection  ${instance1}.rx_dataout_b            ${instance2}.rx_datain_b
    add_connection  ${instance1}.rx_dataout_valid_b      ${instance2}.rx_datain_valid_b
    #add_connection  ${instance1}.rx_std                 ${instance2}.rx_std_in
  }
}

# --------------------------------------
# Add interface and export in core level
#
proc tx_protocol__add_export_interface {instance config insert_vpid std} {

  if { $std != "sd" } {
    add_export_interface $instance tx_enable_crc conduit input
    add_export_interface $instance tx_enable_ln  conduit input
  }

  if { $std != "sd" || $insert_vpid } {
    add_export_interface $instance tx_ln         conduit input
  }

  if { $std == "threeg" | $std == "ds" | $std == "tr" } {
    add_export_interface $instance tx_std      conduit input
  }

  add_export_interface $instance tx_datain     conduit input
  add_export_interface $instance tx_datain_valid conduit input
  add_export_interface $instance tx_trs        conduit input
  
  if { $std == "threeg" | $std == "dl" | $std == "tr" } {
    add_export_interface $instance tx_ln_b       conduit input
  }

  if { $std == "dl" } {
    #add_export_interface $instance tx_enable_crc_b conduit input
    #add_export_interface $instance tx_enable_ln_b  conduit input
    add_export_interface $instance tx_datain_b     conduit input
    add_export_interface $instance tx_datain_valid_b conduit input
    add_export_interface $instance tx_trs_b        conduit input
  }

  if {$insert_vpid} {
    # if { $std == "hd" | $std == "dl" | $std == "ds" | $std == "tr" } {
      # add_export_interface $instance tx_enable_vpid_c conduit input
      add_export_interface $instance tx_vpid_overwrite conduit input
    # }
    add_export_interface $instance tx_vpid_byte1    conduit input
    add_export_interface $instance tx_vpid_byte2    conduit input
    add_export_interface $instance tx_vpid_byte3    conduit input
    add_export_interface $instance tx_vpid_byte4    conduit input
    if { $std == "dl" | $std == "threeg" | $std == "tr"} {
      add_export_interface $instance tx_vpid_byte1_b  conduit input
      add_export_interface $instance tx_vpid_byte2_b  conduit input
      add_export_interface $instance tx_vpid_byte3_b  conduit input
      add_export_interface $instance tx_vpid_byte4_b  conduit input
    }
    add_export_interface $instance tx_line_f0       conduit input
    add_export_interface $instance tx_line_f1       conduit input
  }

  if {$config == "proto"} {
    add_export_interface $instance tx_dataout  conduit output
    add_export_interface $instance tx_dataout_valid conduit output

    if { $std == "threeg" | $std == "ds" | $std == "tr" } {
      add_export_interface $instance tx_std_out  conduit output
    }

    if { $std == "dl" } {
      add_export_interface $instance tx_dataout_b  conduit output
      add_export_interface $instance tx_dataout_valid_b conduit output
    }
  }
}

proc tx_phy_mgmt__add_export_interface {instance config std} {
  if { $config == "xcvr" } {

    if { $std == "threeg" | $std == "ds" | $std == "tr" } {
      add_export_interface $instance tx_std           conduit input
    }

    add_export_interface $instance tx_datain        conduit input
    add_export_interface $instance tx_datain_valid  conduit input

    if { $std == "dl" } {
      add_export_interface $instance tx_datain_b        conduit input
      add_export_interface $instance tx_datain_valid_b  conduit input
    }
  }

  add_export_interface $instance tx_dataout_valid   conduit output
  
  if { $std == "dl" } {
    add_export_interface $instance tx_dataout_valid_b conduit output
  }
}

proc phy__add_export_interface {instance dir std device xcvr_tx_pll_sel} {
  if { $dir == "du" | $dir == "tx" } {
    add_export_interface $instance sdi_tx              conduit output
    add_export_interface $instance tx_pll_locked       conduit output
    add_export_interface $instance tx_clkout           clock   output
 
    if { $std == "dl" } {
      add_export_interface $instance sdi_tx_b              conduit output
  #add_export_interface $instance tx_pll_locked_b       conduit output
  #add_export_interface $instance tx_clkout_b           clock   output
    }
  }

  if { $dir == "du" | $dir == "rx" } {
    add_export_interface $instance sdi_rx             conduit input
    add_export_interface $instance rx_pll_locked      conduit output
    if { $std == "dl" } {
      add_export_interface $instance sdi_rx_b              conduit input
      add_export_interface $instance rx_pll_locked_b       conduit output
    }
  }

  if { $device != "Arria 10"} {
     add_export_interface $instance reconfig_to_xcvr   conduit input
     add_export_interface $instance reconfig_from_xcvr conduit output

     if { $std == "dl" } {
        add_export_interface $instance reconfig_to_xcvr_b   conduit input
        add_export_interface $instance reconfig_from_xcvr_b conduit output
     }
  }

  if { $xcvr_tx_pll_sel } {
    add_export_interface    $instance  xcvr_refclk_sel      conduit input
    add_export_interface    $instance      tx_pll_locked_alt    conduit output
  }
}

proc rx_phy_mgmt__add_export_interface {instance config std} {
  # add_export_interface $instance rx_enable_sd_search   conduit input
  # add_export_interface $instance rx_enable_hd_search   conduit input
  # add_export_interface $instance rx_enable_3g_search   conduit input
  add_export_interface $instance rx_rst_proto_out        conduit output
  #add_export_interface $instance rx_clkout             clock   output

  if { $std != "sd" } {
    add_export_interface $instance rx_coreclk_is_ntsc_paln conduit input
    add_export_interface $instance rx_clkout_is_ntsc_paln  conduit output
  }

  if { $std == "ds" | $std == "tr" } {
    add_export_interface $instance rx_sdi_start_reconfig conduit output
    add_export_interface $instance rx_sdi_reconfig_done  conduit input
  }

  if { $std == "dl" } {
    #add_export_interface $instance rx_clkout_b         clock   output
  }

  if {$config == "xcvr"} {
    add_export_interface $instance rx_trs_loose_lock_in   conduit input
    add_export_interface $instance rx_dataout             conduit output
    add_export_interface $instance rx_dataout_valid       conduit output
    add_export_interface $instance rx_clkout              clock   output
    
    if { $std == "threeg" | $std == "ds" | $std == "tr" } {
      add_export_interface $instance rx_std              conduit output
    }
  
    if { $std == "dl" } {
      add_export_interface $instance rx_trs_loose_lock_in_b   conduit input
      add_export_interface $instance rx_rst_proto_out_b       conduit output
      add_export_interface $instance rx_dataout_b             conduit output
      add_export_interface $instance rx_dataout_valid_b       conduit output
      add_export_interface $instance rx_clkout_b              clock   output
    }
  }
}

proc rx_protocol__add_export_interface {instance config extract_vpid std crc_err a2b b2a} {
  if { $a2b | $b2a } {
    add_export_interface $instance rx_clkin_smpte372   clock   input
  }
 
  add_export_interface $instance rx_dataout       conduit output
  add_export_interface $instance rx_dataout_valid conduit output
  add_export_interface $instance rx_f             conduit output
  add_export_interface $instance rx_v             conduit output
  add_export_interface $instance rx_h             conduit output
  add_export_interface $instance rx_ap            conduit output
  add_export_interface $instance rx_format        conduit output
  add_export_interface $instance rx_eav           conduit output
  add_export_interface $instance rx_trs           conduit output

  if { $std == "threeg" | $std == "ds" | $std == "tr" } {
    add_export_interface $instance rx_std           conduit output
  }

  add_export_interface $instance rx_align_locked  conduit output
  add_export_interface $instance rx_trs_locked    conduit output
  add_export_interface $instance rx_frame_locked  conduit output

  if { $crc_err } {
    add_export_interface $instance rx_crc_error_c   conduit output
    add_export_interface $instance rx_crc_error_y   conduit output
    if { $std == "threeg" | $std == "dl" | $std == "tr" } {
      add_export_interface $instance rx_crc_error_c_b conduit output
      add_export_interface $instance rx_crc_error_y_b conduit output
    }
  }

  if { $std != "sd" } {
    add_export_interface $instance rx_ln            conduit output
  }
  if { $std == "threeg" | $std == "dl" | $std == "tr" } {
    add_export_interface $instance rx_ln_b          conduit output
  }

  # if { $trs_misc} {
    # add_export_interface $instance rx_xyz           conduit output
    # add_export_interface $instance rx_xyz_valid     conduit output
  # }

  #add_export_interface $instance rx_anc_dataout   conduit output
  #add_export_interface $instance rx_anc_valid     conduit output
  #add_export_interface $instance rx_anc_error     conduit output
  add_export_interface $instance rx_clkout        clock   output
  
  if { $std == "dl" | $b2a } {
    add_export_interface $instance rx_dataout_b       conduit output
    add_export_interface $instance rx_dataout_valid_b conduit output
  }

  if { $std == "dl" } {
    add_export_interface $instance rx_clkout_b        clock   output    
    add_export_interface $instance rx_align_locked_b  conduit output
    add_export_interface $instance rx_trs_locked_b    conduit output
    add_export_interface $instance rx_frame_locked_b  conduit output
    add_export_interface $instance rx_dl_locked       conduit output
  }

  if {$config == "proto"} {
    add_export_interface $instance rx_clkin              clock   input
    add_export_interface $instance rx_rst_proto_in       conduit input
    add_export_interface $instance rx_datain             conduit input
    add_export_interface $instance rx_datain_valid       conduit input
    add_export_interface $instance rx_trs_loose_lock_out conduit output

    if { $std == "threeg" | $std == "ds" | $std == "tr" } {
      add_export_interface $instance rx_std_in         conduit input
    }

    if { $std == "dl" } {
      add_export_interface $instance rx_clkin_b              clock   input
      add_export_interface $instance rx_rst_proto_in_b       conduit input
      add_export_interface $instance rx_datain_b             conduit input
      add_export_interface $instance rx_datain_valid_b       conduit input
      add_export_interface $instance rx_trs_loose_lock_out_b conduit output
    }
  }

  if {$extract_vpid} {
    add_export_interface $instance rx_vpid_byte1             conduit output
    add_export_interface $instance rx_vpid_byte2             conduit output
    add_export_interface $instance rx_vpid_byte3             conduit output
    add_export_interface $instance rx_vpid_byte4             conduit output
    add_export_interface $instance rx_vpid_valid             conduit output
    add_export_interface $instance rx_vpid_checksum_error    conduit output
    add_export_interface $instance rx_line_f0                conduit output
    add_export_interface $instance rx_line_f1                conduit output
    if { $std == "dl" | $std == "threeg" | $std == "tr"} {
      add_export_interface $instance rx_vpid_byte1_b           conduit output
      add_export_interface $instance rx_vpid_byte2_b           conduit output
      add_export_interface $instance rx_vpid_byte3_b           conduit output
      add_export_interface $instance rx_vpid_byte4_b           conduit output
      add_export_interface $instance rx_vpid_valid_b           conduit output
      add_export_interface $instance rx_vpid_checksum_error_b  conduit output
    }
  }
}

# -----------------------------------
# Add clock and reset connection for:
# tx_rst
# tx_pclk,   
# rx_coreclk, rx_rst
# xcvr_refclk
# phy_mgmt_clk, phy_mgmt_clk_rst

proc add_tx_clk_rst_connection {config dir std device hd_frequency} {
   add_clk_bridge           tx_pclk
   add_connection           tx_pclk_bridge.out_clk                tx_rst_pclk_sync.clk

   if {$config == "xcvr_proto" | $config == "xcvr"} {
      add_connection           tx_pclk_bridge.out_clk                u_tx_phy_mgmt.tx_pclk
      add_connection           tx_rst_pclk_sync.reset_out            u_tx_phy_mgmt.tx_rst

      if { $hd_frequency == "74.25" } {
         add_clk_bridge        tx_coreclk_hd
         add_connection        tx_coreclk_hd_bridge.out_clk          tx_rst_bridge.clk
         add_connection        tx_coreclk_hd_bridge.out_clk          tx_rst_coreclk_sync.clk
         add_connection        tx_coreclk_hd_bridge.out_clk          u_tx_phy_rst_ctrl.clock
         if { $std == "dl" } {
            add_connection     tx_coreclk_hd_bridge.out_clk          u_tx_phy_rst_ctrl_b.clock
         }
      } else { 
         add_clk_bridge        tx_coreclk
         add_connection        tx_coreclk_bridge.out_clk             tx_rst_bridge.clk
         add_connection        tx_coreclk_bridge.out_clk             tx_rst_coreclk_sync.clk
         add_connection        tx_coreclk_bridge.out_clk             u_tx_phy_rst_ctrl.clock
         if { $std == "dl" } {
            add_connection     tx_coreclk_bridge.out_clk             u_tx_phy_rst_ctrl_b.clock
         }
      }

      add_connection           tx_rst_coreclk_sync.reset_out               u_tx_phy_rst_ctrl.reset
      if { $std == "dl" } {
         add_connection        tx_rst_coreclk_sync.reset_out               u_tx_phy_rst_ctrl_b.reset
      }  
   }

   # Protocol clock and reset
   if {$config == "xcvr_proto"} {
      add_connection    tx_pclk_bridge.out_clk         u_tx_protocol.tx_pclk
      add_connection    tx_rst_pclk_sync.reset_out     u_tx_protocol.tx_rst
   } elseif {$config == "proto"} {
      add_connection    tx_pclk_bridge.out_clk         tx_rst_bridge.clk
      add_connection    tx_pclk_bridge.out_clk         u_tx_protocol.tx_pclk
      add_connection    tx_rst_pclk_sync.reset_out     u_tx_protocol.tx_rst
   }
}

proc add_rx_clk_rst_connection {std device hd_frequency} {
   if { $hd_frequency == "74.25" } {
      add_clk_bridge      rx_coreclk_hd
      add_connection      rx_coreclk_hd_bridge.out_clk          rx_rst_bridge.clk
      add_connection      rx_coreclk_hd_bridge.out_clk          u_rx_phy_mgmt.rx_coreclk_hd
      add_connection      rx_coreclk_hd_bridge.out_clk          rx_rst_coreclk_sync.clk
      add_connection      rx_rst_coreclk_sync.reset_out         u_rx_phy_mgmt.rx_rst
   } else {
      add_clk_bridge      rx_coreclk
      add_connection      rx_coreclk_bridge.out_clk             rx_rst_bridge.clk
      add_connection      rx_coreclk_bridge.out_clk             u_rx_phy_mgmt.rx_coreclk
      add_connection      rx_coreclk_bridge.out_clk             rx_rst_coreclk_sync.clk
      add_connection      rx_rst_coreclk_sync.reset_out         u_rx_phy_mgmt.rx_rst
   }
   
       if { $hd_frequency == "74.25" } {
          add_connection      rx_coreclk_hd_bridge.out_clk          u_rx_phy_rst_ctrl.clock
          add_connection      rx_coreclk_hd_bridge.out_clk          rx_phy_rst_ctrl_bridge.clk
          
          if { $std == "dl" } {
             add_connection  rx_coreclk_hd_bridge.out_clk           u_rx_phy_rst_ctrl_b.clock
             add_connection  rx_coreclk_hd_bridge.out_clk           rx_phy_rst_ctrl_b_bridge.clk
          }
       } else {
          add_connection      rx_coreclk_bridge.out_clk             u_rx_phy_rst_ctrl.clock
          add_connection      rx_coreclk_bridge.out_clk             rx_phy_rst_ctrl_bridge.clk
          
          if { $std == "dl" } {
             add_connection  rx_coreclk_bridge.out_clk    u_rx_phy_rst_ctrl_b.clock
             add_connection  rx_coreclk_bridge.out_clk    rx_phy_rst_ctrl_b_bridge.clk
          }
       }
   

#   if { $device == "Stratix V" || $device == "Arria V" || $device == "Arria V GZ" } {
#      add_clk_bridge      phy_mgmt_clk
#      add_connection      phy_mgmt_clk_bridge.out_clk           phy_mgmt_clk_rst_bridge.clk
#      add_connection      phy_mgmt_clk_bridge.out_clk           u_rx_phy_mgmt.phy_mgmt_clk
#      add_connection      phy_mgmt_clk_bridge.out_clk           u_phy_adapter.phy_mgmt_clk
#      add_connection      phy_mgmt_clk_bridge.out_clk           u_phy.phy_mgmt_clk
#      add_connection      phy_mgmt_clk_rst_bridge.out_reset     u_phy_adapter.phy_mgmt_clk_reset    
#      add_connection      phy_mgmt_clk_rst_bridge.out_reset     u_rx_phy_mgmt.phy_mgmt_clk_reset
#      add_connection      phy_mgmt_clk_rst_bridge.out_reset     u_phy.phy_mgmt_clk_reset
      #add_connection     rx_refclk_bridge.out_clk              u_phy_adapter.rx_refclk 
      #add_connection     rx_rst_bridge.out_reset               u_phy_adapter.rx_rst 
#      if { $std == "dl" } {
#         add_connection   phy_mgmt_clk_bridge.out_clk           u_phy_b.phy_mgmt_clk
#         add_connection   phy_mgmt_clk_rst_bridge.out_reset     u_phy_b.phy_mgmt_clk_reset
#      }
#   }
}

proc add_xcvr_clk_connection {std device dir xcvr_tx_pll_sel} {
   add_clk_bridge  xcvr_refclk
   add_connection  xcvr_refclk_bridge.out_clk    u_phy_adapter.xcvr_refclk
   
   if { $xcvr_tx_pll_sel } { 
      add_clk_bridge  xcvr_refclk_alt
      add_connection  xcvr_refclk_alt_bridge.out_clk    u_phy_adapter.xcvr_refclk_alt
   }
}

proc add_xcvr_rst_ctrl_connection {phy_name tx_xcvr_rst_name rx_xcvr_rst_name std dir device} {
   if {$dir == "du" || $dir == "tx"} {
      if {$device == "Arria 10"} {
         add_connection  u_tx_pll.pll_powerdown                       ${tx_xcvr_rst_name}.pll_powerdown
         add_connection  pll_locked_fanout.sig_fanout0                 ${tx_xcvr_rst_name}.pll_locked
      } else {
         add_connection  ${phy_name}.pll_powerdown                       ${tx_xcvr_rst_name}.pll_powerdown
         add_connection  pll_locked_fanout.sig_fanout0                   ${tx_xcvr_rst_name}.pll_locked
      }
      add_connection  ${phy_name}.tx_analogreset                      ${tx_xcvr_rst_name}.tx_analogreset
      add_connection  ${phy_name}.tx_digitalreset                     ${tx_xcvr_rst_name}.tx_digitalreset
      add_connection  ${phy_name}.tx_cal_busy                         ${tx_xcvr_rst_name}.tx_cal_busy
      add_connection  ${phy_name}_adapter.tx_pll_select_to_xcvr_rst   ${tx_xcvr_rst_name}.pll_select
      add_connection  ${phy_name}_adapter.xcvr_tx_ready               ${tx_xcvr_rst_name}.tx_ready
   }

   if {$dir == "du" || $dir == "rx"} {
      add_connection  ${phy_name}.rx_analogreset                      ${rx_xcvr_rst_name}.rx_analogreset
      add_connection  ${phy_name}.rx_digitalreset                     ${rx_xcvr_rst_name}.rx_digitalreset
      add_connection  ${phy_name}_adapter.rx_locked_to_xcvr_ctrl      ${rx_xcvr_rst_name}.rx_is_lockedtodata
      add_connection  ${phy_name}.rx_cal_busy                         ${rx_xcvr_rst_name}.rx_cal_busy
      add_connection  ${phy_name}_adapter.reset_to_xcvr_rst_ctrl      rx_phy_rst_ctrl_bridge.in_reset
      add_connection  rx_phy_rst_ctrl_bridge.out_reset                ${rx_xcvr_rst_name}.reset
      add_connection  ${phy_name}_adapter.rx_ready_from_xcvr          ${rx_xcvr_rst_name}.rx_ready
      add_connection  ${phy_name}_adapter.rx_manual                   ${rx_xcvr_rst_name}.rx_reset_mode
   }

   if { $std == "dl" } {
      if {$dir == "du" || $dir == "tx"} {
         if {$device == "Arria 10"} {
            add_connection  u_tx_pll_b.pll_powerdown                       ${tx_xcvr_rst_name}_b.pll_powerdown
            add_connection  u_tx_pll_b.pll_locked                          ${tx_xcvr_rst_name}_b.pll_locked
         } else {
            add_connection  ${phy_name}_b.pll_powerdown                    ${tx_xcvr_rst_name}_b.pll_powerdown
            add_connection  ${phy_name}_b.pll_locked                       ${tx_xcvr_rst_name}_b.pll_locked
         }

         add_connection  ${phy_name}_b.tx_analogreset                      ${tx_xcvr_rst_name}_b.tx_analogreset
         add_connection  ${phy_name}_b.tx_digitalreset                     ${tx_xcvr_rst_name}_b.tx_digitalreset
         add_connection  ${phy_name}_b.tx_cal_busy                         ${tx_xcvr_rst_name}_b.tx_cal_busy
         add_connection  ${phy_name}_adapter.tx_pll_select_to_xcvr_rst_b   ${tx_xcvr_rst_name}_b.pll_select
         add_connection  ${phy_name}_adapter.xcvr_tx_ready_b               ${tx_xcvr_rst_name}_b.tx_ready
      }

      if {$dir == "du" || $dir == "rx"} {
         add_connection  ${phy_name}_b.rx_analogreset                      ${rx_xcvr_rst_name}_b.rx_analogreset
         add_connection  ${phy_name}_b.rx_digitalreset                     ${rx_xcvr_rst_name}_b.rx_digitalreset
         add_connection  ${phy_name}_adapter.rx_locked_to_xcvr_ctrl_b      ${rx_xcvr_rst_name}_b.rx_is_lockedtodata
         add_connection  ${phy_name}_b.rx_cal_busy                         ${rx_xcvr_rst_name}_b.rx_cal_busy
         add_connection  ${phy_name}_adapter.reset_to_xcvr_rst_ctrl_b      rx_phy_rst_ctrl_b_bridge.in_reset
         add_connection  rx_phy_rst_ctrl_b_bridge.out_reset                ${rx_xcvr_rst_name}_b.reset
         add_connection  ${phy_name}_adapter.rx_ready_from_xcvr_b          ${rx_xcvr_rst_name}_b.rx_ready
         add_connection  ${phy_name}_adapter.rx_manual_b                   ${rx_xcvr_rst_name}_b.rx_reset_mode

      }
   }
}

proc add_rst_connection_phy_adapter {phy_name  tx_xcvr_rst_name rx_xcvr_rst_name  std dir} {
   if {$dir == "du" || $dir == "tx"} {
      add_connection  ${phy_name}.pll_powerdown                       ${phy_name}_adapter.pll_powerdown_to_xcvr
      add_connection  ${phy_name}.tx_analogreset                      ${phy_name}_adapter.tx_analogreset_to_xcvr
      add_connection  ${phy_name}.tx_digitalreset                     ${phy_name}_adapter.tx_digitalreset_to_xcvr
      add_connection  ${phy_name}.tx_cal_busy                         ${phy_name}_adapter.tx_cal_busy_from_xcvr
      
      #tx_xcvr_rst connection
      add_connection  ${tx_xcvr_rst_name}.pll_select   ${phy_name}_adapter.tx_pll_select_to_xcvr_rst
      add_connection  ${phy_name}_adapter.xcvr_tx_ready                         ${tx_xcvr_rst_name}.tx_ready
      
      add_connection  ${phy_name}_adapter.pll_powerdown_from_xcvr_rst           ${tx_xcvr_rst_name}.pll_powerdown
      add_connection  ${phy_name}_adapter.tx_analogreset_from_xcvr_rst          ${tx_xcvr_rst_name}.tx_analogreset
      add_connection  ${phy_name}_adapter.tx_digitalreset_from_xcvr_rst         ${tx_xcvr_rst_name}.tx_digitalreset
      add_connection  ${tx_xcvr_rst_name}.tx_cal_busy                           ${phy_name}_adapter.tx_cal_busy_to_xcvr_rst
      add_connection ${phy_name}_adapter.txpll_locked_to_xcvr_rst               ${tx_xcvr_rst_name}.pll_locked
   }

   if {$dir == "du" || $dir == "rx"} {
      add_connection  ${phy_name}.rx_analogreset                      ${phy_name}_adapter.rx_analogreset_to_xcvr
      add_connection  ${phy_name}.rx_digitalreset                     ${phy_name}_adapter.rx_digitalreset_to_xcvr
      add_connection  ${phy_name}.rx_cal_busy                         ${phy_name}_adapter.rx_cal_busy_from_xcvr
      
      add_connection  ${phy_name}_adapter.rx_ready_from_xcvr             ${rx_xcvr_rst_name}.rx_ready
      add_connection  ${phy_name}_adapter.reset_to_xcvr_rst_ctrl         ${rx_xcvr_rst_name}.reset
      add_connection  ${phy_name}_adapter.rx_analogreset_from_xcvr_rst   ${rx_xcvr_rst_name}.rx_analogreset
      add_connection  ${phy_name}_adapter.rx_digitalreset_from_xcvr_rst  ${rx_xcvr_rst_name}.rx_digitalreset
      add_connection  ${phy_name}_adapter.rx_cal_busy_to_xcvr_rst        ${rx_xcvr_rst_name}.rx_cal_busy
      add_connection  ${phy_name}_adapter.rx_is_lockedtodata_to_xcvr_rst ${rx_xcvr_rst_name}.rx_is_lockedtodata
   }

   if { $std == "dl" } {
      if {$dir == "du" || $dir == "tx"} {
         add_connection  ${phy_name}_b.pll_powerdown                       ${phy_name}_adapter.pll_powerdown_to_xcvr_b
         add_connection  ${phy_name}_b.tx_analogreset                      ${phy_name}_adapter.tx_analogreset_to_xcvr_b
         add_connection  ${phy_name}_b.tx_digitalreset                     ${phy_name}_adapter.tx_digitalreset_to_xcvr_b
         add_connection  ${phy_name}_b.tx_cal_busy                         ${phy_name}_adapter.tx_cal_busy_from_xcvr_b
      
         #tx_xcvr_rst connection
         add_connection  ${tx_xcvr_rst_name}_b.pll_select   ${phy_name}_adapter.tx_pll_select_to_xcvr_rst_b
         add_connection  ${phy_name}_adapter.xcvr_tx_ready_b                         ${tx_xcvr_rst_name}_b.tx_ready
      
         add_connection  ${phy_name}_adapter.pll_powerdown_from_xcvr_rst_b           ${tx_xcvr_rst_name}_b.pll_powerdown
         add_connection  ${phy_name}_adapter.tx_analogreset_from_xcvr_rst_b          ${tx_xcvr_rst_name}_b.tx_analogreset
         add_connection  ${phy_name}_adapter.tx_digitalreset_from_xcvr_rst_b         ${tx_xcvr_rst_name}_b.tx_digitalreset
         add_connection  ${tx_xcvr_rst_name}_b.tx_cal_busy                           ${phy_name}_adapter.tx_cal_busy_to_xcvr_rst_b
      }

      if {$dir == "du" || $dir == "rx"} {
         add_connection  ${phy_name}_b.rx_analogreset                      ${phy_name}_adapter.rx_analogreset_to_xcvr_b
         add_connection  ${phy_name}_b.rx_digitalreset                     ${phy_name}_adapter.rx_digitalreset_to_xcvr_b
         add_connection  ${phy_name}_b.rx_cal_busy                         ${phy_name}_adapter.rx_cal_busy_from_xcvr_b
      
         add_connection  ${phy_name}_adapter.rx_ready_from_xcvr_b             ${rx_xcvr_rst_name}_b.rx_ready
         add_connection  ${phy_name}_adapter.reset_to_xcvr_rst_ctrl_b         ${rx_xcvr_rst_name}_b.reset
         add_connection  ${phy_name}_adapter.rx_analogreset_from_xcvr_rst_b   ${rx_xcvr_rst_name}_b.rx_analogreset
         add_connection  ${phy_name}_adapter.rx_digitalreset_from_xcvr_rst_b  ${rx_xcvr_rst_name}_b.rx_digitalreset
         add_connection  ${phy_name}_adapter.rx_cal_busy_to_xcvr_rst_b        ${rx_xcvr_rst_name}_b.rx_cal_busy
         add_connection  ${phy_name}_adapter.rx_is_lockedtodata_to_xcvr_rst_b ${rx_xcvr_rst_name}_b.rx_is_lockedtodata
      }
   }
}

proc add_clk_bridge {interface} {
  add_instance           ${interface}_bridge     altera_clock_bridge
  add_interface          ${interface}            clock                 end
  set_interface_property ${interface}            export_of             ${interface}_bridge.in_clk
  set port_map_clk [list]
  lappend port_map_clk $interface
  lappend port_map_clk in_clk    
  set_interface_property ${interface} PORT_NAME_MAP $port_map_clk
}

proc add_rst_bridge {interface} {
  add_instance           ${interface}_rst_bridge altera_reset_bridge
  add_interface          ${interface}_rst        reset                 end
  set_interface_property ${interface}_rst        export_of             ${interface}_rst_bridge.in_reset
  set port_map_rst [list]
  lappend port_map_rst ${interface}_rst
  lappend port_map_rst in_reset    
  set_interface_property ${interface}_rst PORT_NAME_MAP $port_map_rst
}
