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
# | SDI II Reconfig v12.1 (V series)
# | Altera Corporation 2009.08.19.17:10:07
# | 
# +----------------------------------------

package require -exact qsys 12.0

source ../sdi_ii/sdi_ii_interface.tcl
source ../sdi_ii/sdi_ii_params.tcl

# +-----------------------------------
# | module SDI II Reconfig Management
# | 
set_module_property DESCRIPTION "SDI II Reconfig Router"
set_module_property NAME sdi_ii_ed_reconfig_router
set_module_property VERSION 13.1
set_module_property INTERNAL true
set_module_property GROUP "Interface Protocols/SDI II Reconfig Router"
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "SDI II Reconfig Router"
# set_module_property DATASHEET_URL http://www.altera.com/literature/ug/ug_sdi.pdf
# set_module_property TOP_LEVEL_HDL_FILE src_hdl/sdi_ii_ed_reconfig_router.v
# set_module_property TOP_LEVEL_HDL_MODULE sdi_ii_ed_reconfig_router
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

set_fileset_property simulation_verilog TOP_LEVEL   sdi_ii_ed_reconfig_router
set_fileset_property simulation_vhdl    TOP_LEVEL   sdi_ii_ed_reconfig_router
set_fileset_property synthesis_fileset  TOP_LEVEL   sdi_ii_ed_reconfig_router

proc generate_files {name} {
   add_fileset_file sdi_ii_ed_reconfig_router.v   VERILOG PATH src_hdl/sdi_ii_ed_reconfig_router.v
}

#set module_dir [get_module_property MODULE_DIRECTORY]
#add_file ${module_dir}/src_hdl/sdi_ii_ed_reconfig_router.v   {SYNTHESIS}


# | 
# +-----------------------------------

proc common_add_reconfig_to_conduit { port_name port_dir width used } {
  global common_composed_mode
  array set in_out [list {output} {start} {input} {end} ]
  add_interface $port_name conduit $in_out($port_dir)
  set_interface_assignment $port_name "ui.blockdiagram.direction" $port_dir
  if {$common_composed_mode == 0} {
    set_interface_property $port_name ENABLED $used
    add_interface_port $port_name $port_name reconfig_to_xcvr $port_dir $width
  }
}

proc common_add_reconfig_from_conduit { port_name port_dir width used } {
  global common_composed_mode
  array set in_out [list {output} {start} {input} {end} ]
  add_interface $port_name conduit $in_out($port_dir)
  set_interface_assignment $port_name "ui.blockdiagram.direction" $port_dir
  if {$common_composed_mode == 0} {
    set_interface_property $port_name ENABLED $used
    add_interface_port $port_name $port_name reconfig_from_xcvr $port_dir $width
  }
}

sdi_ii_common_params
sdi_ii_ed_reconfig_params
set common_composed_mode 0

set_parameter_property NUM_CHS                   HDL_PARAMETER true
set_parameter_property NUM_INTERFACES            HDL_PARAMETER true
set_parameter_property RX_EN_A2B_CONV            HDL_PARAMETER true
set_parameter_property RX_EN_B2A_CONV            HDL_PARAMETER true
set_parameter_property VIDEO_STANDARD            HDL_PARAMETER true
set_parameter_property DIRECTION                 HDL_PARAMETER true
set_parameter_property FAMILY                    HDL_PARAMETER false
set_parameter_property RX_INC_ERR_TOLERANCE      HDL_PARAMETER false
set_parameter_property RX_CRC_ERROR_OUTPUT       HDL_PARAMETER false
set_parameter_property RX_EN_VPID_EXTRACT        HDL_PARAMETER false
# set_parameter_property RX_EN_TRS_MISC            HDL_PARAMETER false
set_parameter_property TX_HD_2X_OVERSAMPLING     HDL_PARAMETER false
set_parameter_property TX_EN_VPID_INSERT         HDL_PARAMETER false
#set_parameter_property USE_SOFT_LOGIC           HDL_PARAMETER false
set_parameter_property TRANSCEIVER_PROTOCOL      HDL_PARAMETER false
#set_parameter_property STARTING_CHANNEL_NUMBER  HDL_PARAMETER false
set_parameter_property SD_BIT_WIDTH              HDL_PARAMETER false
set_parameter_property XCVR_TX_PLL_SEL           HDL_PARAMETER true
set_parameter_property HD_FREQ                   HDL_PARAMETER false

proc elaboration_callback {} {

  set dir         [get_parameter_value DIRECTION]
  set vid_std     [get_parameter_value VIDEO_STANDARD]
  set a2b         [get_parameter_value RX_EN_A2B_CONV]
  set b2a         [get_parameter_value RX_EN_B2A_CONV]
  set xcvr_tx_pll_sel [get_parameter_value XCVR_TX_PLL_SEL]
  
  ## Reconfig ports from alt_xcvr_reconfig
  common_add_reconfig_to_conduit   reconfig_to_xcvr        input   NUM_INTERFACES*70    true
  common_add_reconfig_from_conduit reconfig_from_xcvr      output  NUM_INTERFACES*46    true
  
  ## Reconfig ports to SDI Du CH0
  common_add_reconfig_to_conduit   reconfig_to_xcvr_du_ch0     output  140                    true
  common_add_reconfig_from_conduit reconfig_from_xcvr_du_ch0   input   92                     true
  if { $vid_std == "dl" } {
    common_add_reconfig_to_conduit   reconfig_to_xcvr_du_ch0_b     output  140                      true
    common_add_reconfig_from_conduit reconfig_from_xcvr_du_ch0_b   input   92                       true
  }

  ## Reconfig ports to various SDI Instances  
  if { $dir == "du" } {
    if { $xcvr_tx_pll_sel } {
      common_add_reconfig_to_conduit   reconfig_to_xcvr_du_ch1     output  210  true
      common_add_reconfig_from_conduit reconfig_from_xcvr_du_ch1   input   138  true
      if { $vid_std == "dl" } {
        common_add_reconfig_to_conduit   reconfig_to_xcvr_du_ch1_b     output  210  true
        common_add_reconfig_from_conduit reconfig_from_xcvr_du_ch1_b   input   138  true
      }
    } else {
      common_add_reconfig_to_conduit   reconfig_to_xcvr_du_ch1     output  140  true
      common_add_reconfig_from_conduit reconfig_from_xcvr_du_ch1   input   92   true
      if { $vid_std == "dl" } {
        common_add_reconfig_to_conduit   reconfig_to_xcvr_du_ch1_b     output  140  true
        common_add_reconfig_from_conduit reconfig_from_xcvr_du_ch1_b   input   92   true
      }
    }
  } else {
    if { $xcvr_tx_pll_sel } {
      common_add_reconfig_to_conduit   reconfig_to_xcvr_tx_ch1     output  210                     true
      common_add_reconfig_to_conduit   reconfig_to_xcvr_rx_ch1     output  70                      true
      common_add_reconfig_from_conduit reconfig_from_xcvr_tx_ch1   input   138                     true
      common_add_reconfig_from_conduit reconfig_from_xcvr_rx_ch1   input   46                      true
      if { $vid_std == "dl" } {
        common_add_reconfig_to_conduit   reconfig_to_xcvr_tx_ch1_b     output  210                 true
        common_add_reconfig_to_conduit   reconfig_to_xcvr_rx_ch1_b     output  70                  true
        common_add_reconfig_from_conduit reconfig_from_xcvr_tx_ch1_b   input   138                 true
        common_add_reconfig_from_conduit reconfig_from_xcvr_rx_ch1_b   input   46                  true
      }
    } else {
      common_add_reconfig_to_conduit   reconfig_to_xcvr_tx_ch1     output  140                      true
      common_add_reconfig_to_conduit   reconfig_to_xcvr_rx_ch1     output  70                       true
      common_add_reconfig_from_conduit reconfig_from_xcvr_tx_ch1   input   92                       true
      common_add_reconfig_from_conduit reconfig_from_xcvr_rx_ch1   input   46                       true
      if { $vid_std == "dl" } {
        common_add_reconfig_to_conduit   reconfig_to_xcvr_tx_ch1_b     output  140                      true
        common_add_reconfig_to_conduit   reconfig_to_xcvr_rx_ch1_b     output  70                       true
        common_add_reconfig_from_conduit reconfig_from_xcvr_tx_ch1_b   input   92                       true
        common_add_reconfig_from_conduit reconfig_from_xcvr_rx_ch1_b   input   46                       true
      }
    }

    if { $a2b | $b2a } {
      common_add_reconfig_to_conduit   reconfig_to_xcvr_tx_smpte372     output  140                      true
      common_add_reconfig_to_conduit   reconfig_to_xcvr_rx_smpte372     output  70                       true
      common_add_reconfig_from_conduit reconfig_from_xcvr_tx_smpte372   input   92                       true
      common_add_reconfig_from_conduit reconfig_from_xcvr_rx_smpte372   input   46                       true
    }
    
    if { $b2a } {
      common_add_reconfig_to_conduit   reconfig_to_xcvr_tx_smpte372_b     output  140                    true
      common_add_reconfig_to_conduit   reconfig_to_xcvr_rx_smpte372_b     output  70                     true
      common_add_reconfig_from_conduit reconfig_from_xcvr_tx_smpte372_b   input   92                     true
      common_add_reconfig_from_conduit reconfig_from_xcvr_rx_smpte372_b   input   46                     true
    }
  }

  ## Handshake signals between SDI Rx and reconfig_mgmt
  if { $vid_std == "tr" || $vid_std == "ds" } {
    common_add_optional_conduit sdi_rx_start_reconfig_du_ch0     export  input  1   true
    common_add_optional_conduit sdi_rx_reconfig_done_du_ch0      export  output 1   true
    common_add_optional_conduit sdi_rx_std_du_ch0                 export  input  2   true
    if { $dir == "du" } {
      common_add_optional_conduit sdi_rx_start_reconfig_du_ch1   export  input  1   true
      common_add_optional_conduit sdi_rx_reconfig_done_du_ch1    export  output 1   true
      common_add_optional_conduit sdi_rx_std_du_ch1               export  input  2   true
    } else {
      common_add_optional_conduit sdi_rx_start_reconfig_rx_ch1   export  input  1   true
      common_add_optional_conduit sdi_rx_reconfig_done_rx_ch1    export  output 1   true
      common_add_optional_conduit sdi_rx_std_rx_ch1               export  input  2   true
    }  
    common_add_optional_conduit sdi_rx_start_reconfig_to_mgmt    export  output  NUM_CHS   true
    common_add_optional_conduit sdi_rx_reconfig_done_from_mgmt   export  input   NUM_CHS   true
    common_add_optional_conduit sdi_rx_std_to_mgmt            export  output  2*NUM_CHS   true
  }
  
  #always 1 channel for Tx PLL switching in example design
  if { $xcvr_tx_pll_sel } {
    common_add_optional_conduit sdi_tx_start_reconfig_${dir}_ch1     export  input  1   true
    common_add_optional_conduit sdi_tx_pll_sel_${dir}_ch1            export  input  1   true
    common_add_optional_conduit sdi_tx_reconfig_done_${dir}_ch1      export  output 1   true
    
    common_add_optional_conduit sdi_tx_start_reconfig_to_mgmt     export  output  NUM_CHS   true
    common_add_optional_conduit sdi_tx_reconfig_done_from_mgmt    export  input   NUM_CHS   true
    common_add_optional_conduit sdi_tx_pll_sel_to_mgmt            export  output  NUM_CHS   true
    
    common_add_optional_conduit sdi_tx_pll_sel_to_xcvr_ch1        export  output  1         true
    
  }
}
