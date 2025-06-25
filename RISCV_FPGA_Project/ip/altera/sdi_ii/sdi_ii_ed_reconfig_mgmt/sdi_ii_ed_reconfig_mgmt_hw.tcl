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


# +----------------------------------------
# | 
# | SDI II Reconfig Management v12.1 (V series)
# | Altera Corporation 2009.08.19.17:10:07
# | 
# +----------------------------------------

package require -exact qsys 12.0

source ../sdi_ii/sdi_ii_interface.tcl
source ../sdi_ii/sdi_ii_params.tcl

# +-----------------------------------
# | module SDI II Reconfig Management
# | 
set_module_property DESCRIPTION "SDI II Reconfig Management"
set_module_property NAME sdi_ii_ed_reconfig_mgmt
set_module_property VERSION 13.1
set_module_property INTERNAL true
set_module_property GROUP "Interface Protocols/SDI II Reconfig Mgmt"
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "SDI II Reconfig Management"
# set_module_property DATASHEET_URL http://www.altera.com/literature/ug/ug_sdi.pdf
# set_module_property TOP_LEVEL_HDL_FILE src_hdl/sdi_ii_ed_reconfig_mgmt.v
# set_module_property TOP_LEVEL_HDL_MODULE sdi_ii_ed_reconfig_mgmt
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false
#set_module_property SIMULATION_MODEL_IN_VERILOG true
#set_module_property SIMULATION_MODEL_IN_VHDL true
set_module_property ELABORATION_CALLBACK elaboration_callback

# | 
# +-----------------------------------

# +-----------------------------------
# | files
# | 

add_fileset simulation_verilog SIM_VERILOG   generate_files
add_fileset simulation_vhdl    SIM_VHDL      generate_files
add_fileset synthesis_fileset  QUARTUS_SYNTH generate_files

set_fileset_property simulation_verilog TOP_LEVEL   sdi_ii_ed_reconfig_mgmt
set_fileset_property simulation_vhdl    TOP_LEVEL   sdi_ii_ed_reconfig_mgmt
set_fileset_property synthesis_fileset  TOP_LEVEL   sdi_ii_ed_reconfig_mgmt

proc generate_files {name} {
   add_fileset_file sdi_ii_ed_reconfig_mgmt.v     VERILOG PATH src_hdl/sdi_ii_ed_reconfig_mgmt.v
   add_fileset_file sdi_ii_reconfig_logic.v       VERILOG PATH src_hdl/sdi_ii_reconfig_logic.v
   add_fileset_file sdi_ii_ed_reconfig_mgmt.sdc   SDC     PATH src_hdl/sdi_ii_ed_reconfig_mgmt.sdc
}

#set module_dir [get_module_property MODULE_DIRECTORY]
#add_file ${module_dir}/src_hdl/sdi_ii_ed_reconfig_mgmt.v   {SYNTHESIS}
#add_file ${module_dir}/src_hdl/sdi_ii_reconfig_logic.v     {SYNTHESIS}
#add_file ${module_dir}/src_hdl/sdi_ii_ed_reconfig_mgmt.sdc {SDC}



# | 
# +-----------------------------------

sdi_ii_common_params
sdi_ii_ed_reconfig_params
set common_composed_mode 0

set_parameter_property NUM_CHS                  HDL_PARAMETER true
set_parameter_property FAMILY                   HDL_PARAMETER true
set_parameter_property RX_INC_ERR_TOLERANCE     HDL_PARAMETER false
set_parameter_property RX_CRC_ERROR_OUTPUT      HDL_PARAMETER false
set_parameter_property RX_EN_VPID_EXTRACT       HDL_PARAMETER false
# set_parameter_property RX_EN_TRS_MISC           HDL_PARAMETER false
set_parameter_property RX_EN_A2B_CONV           HDL_PARAMETER false
set_parameter_property RX_EN_B2A_CONV           HDL_PARAMETER false
set_parameter_property TX_HD_2X_OVERSAMPLING    HDL_PARAMETER false
set_parameter_property TX_EN_VPID_INSERT        HDL_PARAMETER false
set_parameter_property DIRECTION                HDL_PARAMETER true
set_parameter_property XCVR_TX_PLL_SEL          HDL_PARAMETER true
#set_parameter_property VIDEO_STANDARD           HDL_PARAMETER false
#set_parameter_property USE_SOFT_LOGIC          HDL_PARAMETER false
set_parameter_property TRANSCEIVER_PROTOCOL     HDL_PARAMETER false
#set_parameter_property STARTING_CHANNEL_NUMBER HDL_PARAMETER false
set_parameter_property SD_BIT_WIDTH             HDL_PARAMETER false
set_parameter_property HD_FREQ                  HDL_PARAMETER false
  
proc elaboration_callback {} {

  set video_std    [get_parameter_value VIDEO_STANDARD]
  set xcvr_tx_pll_sel [get_parameter_value XCVR_TX_PLL_SEL]

  common_add_clock            reconfig_clk          input          true
  common_add_reset            rst                   input          reconfig_clk
  common_add_optional_conduit reconfig_busy         reconfig_busy  input  1    true

  if { $video_std == "tr" ||  $video_std == "ds" } {
    common_add_optional_conduit sdi_rx_std               export  input  2*NUM_CHS  true
    common_add_optional_conduit sdi_rx_start_reconfig    export  input  NUM_CHS    true
    common_add_optional_conduit sdi_rx_reconfig_done     export  output NUM_CHS    true
  # common_add_optional_conduit write_ctrl_ch0        input  1  true
  # common_add_optional_conduit write_ctrl_ch1        input  1  true
  # common_add_optional_conduit write_ctrl_ch2        input  1  true
  # common_add_optional_conduit write_ctrl_ch3        input  1  true
  # common_add_optional_conduit rx_std_ch0            input  2  true
  # common_add_optional_conduit rx_std_ch1            input  2  true
  # common_add_optional_conduit rx_std_ch2            input  2  true
  # common_add_optional_conduit rx_std_ch3            input  2  true
    
  }
  
  if { $video_std == "tr" ||  $video_std == "ds" || $xcvr_tx_pll_sel } {
    ## Connections with alt_xcvr_reconfig reconfig_mif interface (drive to ground)
    add_interface reconfig_mif avalon end reconfig_clk
    set_interface_property reconfig_mif ASSOCIATED_CLOCK reconfig_clk
    set_interface_property reconfig_mif bitsPerSymbol 8
    set_interface_property reconfig_mif addressUnits SYMBOLS
    add_interface_port reconfig_mif reconfig_mif_address     address     Input  32
    add_interface_port reconfig_mif reconfig_mif_read        read        Input  1
    add_interface_port reconfig_mif reconfig_mif_readdata    readdata    Output 16
    add_interface_port reconfig_mif reconfig_mif_waitrequest waitrequest Output 1
  }
  
  
  common_add_optional_conduit sdi_tx_pll_sel           export  input  NUM_CHS    true
  common_add_optional_conduit sdi_tx_start_reconfig    export  input  NUM_CHS    true
  common_add_optional_conduit sdi_tx_reconfig_done     export  output NUM_CHS    true

  
  if { $xcvr_tx_pll_sel == 0 } {
    set_port_property sdi_tx_pll_sel TERMINATION true
    set_port_property sdi_tx_pll_sel TERMINATION_VALUE 0
    
    set_port_property sdi_tx_start_reconfig TERMINATION true
    set_port_property sdi_tx_start_reconfig TERMINATION_VALUE 0
    
    set_port_property sdi_tx_reconfig_done TERMINATION true
  }
  
  

  ## Connections with alt_xcvr_reconfig reconfig_mgmt interface
  add_interface reconfig_mgmt avalon start
  set_interface_property reconfig_mgmt ASSOCIATED_CLOCK reconfig_clk
  add_interface_port reconfig_mgmt reconfig_mgmt_address     address     Output  9
  add_interface_port reconfig_mgmt reconfig_mgmt_read        read        Output  1
  add_interface_port reconfig_mgmt reconfig_mgmt_readdata    readdata    Input   32
  add_interface_port reconfig_mgmt reconfig_mgmt_waitrequest waitrequest Input   1
  add_interface_port reconfig_mgmt reconfig_mgmt_write       write       Output  1
  add_interface_port reconfig_mgmt reconfig_mgmt_writedata   writedata   Output  32 

}

