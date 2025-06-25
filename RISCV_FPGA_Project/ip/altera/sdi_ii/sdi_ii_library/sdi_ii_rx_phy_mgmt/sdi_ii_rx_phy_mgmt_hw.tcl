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


# +----------------------------------
# | 
# | SDI II RX PHY Management v12.0
# | Altera Corporation 2011.08.19.17:10:07
# | 
# +-----------------------------------

package require -exact qsys 12.0
package require altera_terp ;# required to use terp

source ../../sdi_ii/sdi_ii_interface.tcl
source ../../sdi_ii/sdi_ii_params.tcl

# +-----------------------------------
# | module SDI II RX PHY Management
# | 
set_module_property DESCRIPTION "SDI II RX PHY Management"
set_module_property NAME sdi_ii_rx_phy_mgmt
set_module_property VERSION 13.1
set_module_property INTERNAL true
set_module_property GROUP "Interface Protocols/SDI II/SDI II RX PHY Management"
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "SDI II RX PHY Management"
# set_module_property DATASHEET_URL http://www.altera.com/literature/ug/ug_sdi.pdf
# set_module_property TOP_LEVEL_HDL_FILE src_hdl/sdi_ii_rx_phy_mgmt.v
# set_module_property TOP_LEVEL_HDL_MODULE sdi_ii_rx_phy_mgmt
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false
#set_module_property SIMULATION_MODEL_IN_VERILOG true
#set_module_property SIMULATION_MODEL_IN_VHDL true
set_module_property ELABORATION_CALLBACK elaboration_callback

# | 
# +-----------------------------------

# +-----------------------------------
# | IEEE Encryption
# | 

add_fileset          simulation_verilog SIM_VERILOG   generate_files
add_fileset          simulation_vhdl    SIM_VHDL      generate_files
add_fileset          synthesis_fileset  QUARTUS_SYNTH generate_ed_files

set_fileset_property simulation_verilog TOP_LEVEL   sdi_ii_rx_phy_mgmt
set_fileset_property simulation_vhdl    TOP_LEVEL   sdi_ii_rx_phy_mgmt
set_fileset_property synthesis_fileset  TOP_LEVEL   sdi_ii_rx_phy_mgmt

proc generate_files {name} {
  if {1} {
    add_fileset_file mentor/src_hdl/sdi_ii_rx_phy_mgmt.v              VERILOG_ENCRYPT PATH "mentor/src_hdl/sdi_ii_rx_phy_mgmt.v"              {MENTOR_SPECIFIC}
    add_fileset_file mentor/src_hdl/sdi_ii_rx_sample.v                VERILOG_ENCRYPT PATH "mentor/src_hdl/sdi_ii_rx_sample.v"                {MENTOR_SPECIFIC}
    add_fileset_file mentor/src_hdl/sdi_ii_rx_xcvr_ctrl_altgx.v       VERILOG_ENCRYPT PATH "mentor/src_hdl/sdi_ii_rx_xcvr_ctrl_altgx.v"       {MENTOR_SPECIFIC}
    add_fileset_file mentor/src_hdl/sdi_ii_rx_xcvr_ctrl_custom.v      VERILOG_ENCRYPT PATH "mentor/src_hdl/sdi_ii_rx_xcvr_ctrl_custom.v"      {MENTOR_SPECIFIC}
    add_fileset_file mentor/src_hdl/sdi_ii_rx_xcvr_ctrl_native.v      VERILOG_ENCRYPT PATH "mentor/src_hdl/sdi_ii_rx_xcvr_ctrl_native.v"      {MENTOR_SPECIFIC}
    add_fileset_file mentor/src_hdl/sdi_ii_rx_xcvr_interface.v        VERILOG_ENCRYPT PATH "mentor/src_hdl/sdi_ii_rx_xcvr_interface.v"        {MENTOR_SPECIFIC}
    add_fileset_file mentor/src_hdl/sdi_ii_rx_vid_std_detect.v        VERILOG_ENCRYPT PATH "mentor/src_hdl/sdi_ii_rx_vid_std_detect.v"        {MENTOR_SPECIFIC}
    add_fileset_file mentor/src_hdl/sdi_ii_rx_xcvr_avmm_interface.v   VERILOG_ENCRYPT PATH "mentor/src_hdl/sdi_ii_rx_xcvr_avmm_interface.v"   {MENTOR_SPECIFIC}
    add_fileset_file mentor/src_hdl/sdi_ii_rx_rate_detect.v           VERILOG_ENCRYPT PATH "mentor/src_hdl/sdi_ii_rx_rate_detect.v"           {MENTOR_SPECIFIC}

  }
  if {1} {
    add_fileset_file aldec/src_hdl/sdi_ii_rx_phy_mgmt.v               VERILOG_ENCRYPT PATH "aldec/src_hdl/sdi_ii_rx_phy_mgmt.v"               {ALDEC_SPECIFIC}
    add_fileset_file aldec/src_hdl/sdi_ii_rx_sample.v                 VERILOG_ENCRYPT PATH "aldec/src_hdl/sdi_ii_rx_sample.v"                 {ALDEC_SPECIFIC}
    add_fileset_file aldec/src_hdl/sdi_ii_rx_xcvr_ctrl_altgx.v        VERILOG_ENCRYPT PATH "aldec/src_hdl/sdi_ii_rx_xcvr_ctrl_altgx.v"        {ALDEC_SPECIFIC}
    add_fileset_file aldec/src_hdl/sdi_ii_rx_xcvr_ctrl_custom.v       VERILOG_ENCRYPT PATH "aldec/src_hdl/sdi_ii_rx_xcvr_ctrl_custom.v"       {ALDEC_SPECIFIC}
    add_fileset_file aldec/src_hdl/sdi_ii_rx_xcvr_ctrl_native.v       VERILOG_ENCRYPT PATH "aldec/src_hdl/sdi_ii_rx_xcvr_ctrl_native.v"       {ALDEC_SPECIFIC}
    add_fileset_file aldec/src_hdl/sdi_ii_rx_xcvr_interface.v         VERILOG_ENCRYPT PATH "aldec/src_hdl/sdi_ii_rx_xcvr_interface.v"         {ALDEC_SPECIFIC}
    add_fileset_file aldec/src_hdl/sdi_ii_rx_vid_std_detect.v         VERILOG_ENCRYPT PATH "aldec/src_hdl/sdi_ii_rx_vid_std_detect.v"         {ALDEC_SPECIFIC}
    add_fileset_file aldec/src_hdl/sdi_ii_rx_xcvr_avmm_interface.v    VERILOG_ENCRYPT PATH "aldec/src_hdl/sdi_ii_rx_xcvr_avmm_interface.v"    {ALDEC_SPECIFIC}
    add_fileset_file aldec/src_hdl/sdi_ii_rx_rate_detect.v            VERILOG_ENCRYPT PATH "aldec/src_hdl/sdi_ii_rx_rate_detect.v"            {ALDEC_SPECIFIC}
  }
 # if {0} {
 #   add_fileset_file cadence/src_hdl/sdi_ii_rx_phy_mgmt.v             VERILOG_ENCRYPT PATH "cadence/src_hdl/sdi_ii_rx_phy_mgmt.v"             {CADENCE_SPECIFIC}
 #   add_fileset_file cadence/src_hdl/sdi_ii_rx_sample.v               VERILOG_ENCRYPT PATH "cadence/src_hdl/sdi_ii_rx_sample.v"               {CADENCE_SPECIFIC}
 #   add_fileset_file cadence/src_hdl/sdi_ii_rx_xcvr_ctrl_altgx.v      VERILOG_ENCRYPT PATH "cadence/src_hdl/sdi_ii_rx_xcvr_ctrl_altgx.v"      {CADENCE_SPECIFIC}
 #   add_fileset_file cadence/src_hdl/sdi_ii_rx_xcvr_ctrl_custom.v     VERILOG_ENCRYPT PATH "cadence/src_hdl/sdi_ii_rx_xcvr_ctrl_custom.v"     {CADENCE_SPECIFIC}
 #   add_fileset_file cadence/src_hdl/sdi_ii_rx_xcvr_interface.v       VERILOG_ENCRYPT PATH "cadence/src_hdl/sdi_ii_rx_xcvr_interface.v"       {CADENCE_SPECIFIC}
 #   add_fileset_file cadence/src_hdl/sdi_ii_rx_vid_std_detect.v       VERILOG_ENCRYPT PATH "cadence/src_hdl/sdi_ii_rx_vid_std_detect.v"       {CADENCE_SPECIFIC}
 #   add_fileset_file cadence/src_hdl/sdi_ii_rx_xcvr_avmm_interface.v  VERILOG_ENCRYPT PATH "cadence/src_hdl/sdi_ii_rx_xcvr_avmm_interface.v"  {CADENCE_SPECIFIC}
 #   add_fileset_file cadence/src_hdl/sdi_ii_rx_rate_detect.v          VERILOG_ENCRYPT PATH "cadence/src_hdl/sdi_ii_rx_rate_detect.v"          {CADENCE_SPECIFIC}
 # }
  if {0} {
    add_fileset_file synopsys/src_hdl/sdi_ii_rx_phy_mgmt.v            VERILOG_ENCRYPT PATH "synopsys/src_hdl/sdi_ii_rx_phy_mgmt.v"            {SYNOPSYS_SPECIFIC}
    add_fileset_file synopsys/src_hdl/sdi_ii_rx_sample.v              VERILOG_ENCRYPT PATH "synopsys/src_hdl/sdi_ii_rx_sample.v"              {SYNOPSYS_SPECIFIC}
    add_fileset_file synopsys/src_hdl/sdi_ii_rx_xcvr_ctrl_altgx.v     VERILOG_ENCRYPT PATH "synopsys/src_hdl/sdi_ii_rx_xcvr_ctrl_altgx.v"     {SYNOPSYS_SPECIFIC}
    add_fileset_file synopsys/src_hdl/sdi_ii_rx_xcvr_ctrl_custom.v    VERILOG_ENCRYPT PATH "synopsys/src_hdl/sdi_ii_rx_xcvr_ctrl_custom.v"    {SYNOPSYS_SPECIFIC}
    add_fileset_file synopsys/src_hdl/sdi_ii_rx_xcvr_ctrl_native.v    VERILOG_ENCRYPT PATH "synopsys/src_hdl/sdi_ii_rx_xcvr_ctrl_native.v"    {SYNOPSYS_SPECIFIC}
    add_fileset_file synopsys/src_hdl/sdi_ii_rx_xcvr_interface.v      VERILOG_ENCRYPT PATH "synopsys/src_hdl/sdi_ii_rx_xcvr_interface.v"      {SYNOPSYS_SPECIFIC}
    add_fileset_file synopsys/src_hdl/sdi_ii_rx_vid_std_detect.v      VERILOG_ENCRYPT PATH "synopsys/src_hdl/sdi_ii_rx_vid_std_detect.v"      {SYNOPSYS_SPECIFIC}
    add_fileset_file synopsys/src_hdl/sdi_ii_rx_xcvr_avmm_interface.v VERILOG_ENCRYPT PATH "synopsys/src_hdl/sdi_ii_rx_xcvr_avmm_interface.v" {SYNOPSYS_SPECIFIC}
    add_fileset_file synopsys/src_hdl/sdi_ii_rx_rate_detect.v         VERILOG_ENCRYPT PATH "synopsys/src_hdl/sdi_ii_rx_rate_detect.v"         {SYNOPSYS_SPECIFIC}
  }
}

# | 
# +-----------------------------------

# +-----------------------------------
# | files
# | 
proc generate_ed_files {name} {
   add_fileset_file sdi_ii_rx_phy_mgmt.v                VERILOG PATH src_hdl/sdi_ii_rx_phy_mgmt.v
   add_fileset_file sdi_ii_rx_sample.v                  VERILOG PATH src_hdl/sdi_ii_rx_sample.v 
   add_fileset_file sdi_ii_rx_xcvr_ctrl_altgx.v         VERILOG PATH src_hdl/sdi_ii_rx_xcvr_ctrl_altgx.v
   add_fileset_file sdi_ii_rx_xcvr_ctrl_custom.v        VERILOG PATH src_hdl/sdi_ii_rx_xcvr_ctrl_custom.v
   add_fileset_file sdi_ii_rx_xcvr_ctrl_native.v        VERILOG PATH src_hdl/sdi_ii_rx_xcvr_ctrl_native.v
   add_fileset_file sdi_ii_rx_xcvr_interface.v          VERILOG PATH src_hdl/sdi_ii_rx_xcvr_interface.v
   add_fileset_file sdi_ii_rx_vid_std_detect.v          VERILOG PATH src_hdl/sdi_ii_rx_vid_std_detect.v
   add_fileset_file sdi_ii_rx_xcvr_avmm_interface.v     VERILOG PATH src_hdl/sdi_ii_rx_xcvr_avmm_interface.v
   add_fileset_file sdi_ii_rx_rate_detect.v             VERILOG PATH src_hdl/sdi_ii_rx_rate_detect.v
   add_fileset_file sdi_ii_rx_phy_mgmt.ocp              OTHER   PATH src_hdl/sdi_ii_rx_phy_mgmt.ocp 
   add_fileset_file sdi_ii_rx_phy_mgmt.sdc              SDC     PATH src_hdl/sdi_ii_rx_phy_mgmt.sdc
}


# | 
# +-----------------------------------

sdi_ii_common_params
sdi_ii_test_params
set_parameter_property RX_INC_ERR_TOLERANCE    HDL_PARAMETER false
set_parameter_property RX_CRC_ERROR_OUTPUT     HDL_PARAMETER false
# set_parameter_property RX_EN_TRS_MISC          HDL_PARAMETER false
set_parameter_property RX_EN_VPID_EXTRACT      HDL_PARAMETER false
set_parameter_property RX_EN_A2B_CONV          HDL_PARAMETER false
set_parameter_property RX_EN_B2A_CONV          HDL_PARAMETER false
set_parameter_property TX_HD_2X_OVERSAMPLING   HDL_PARAMETER false
set_parameter_property TX_EN_VPID_INSERT       HDL_PARAMETER false
set_parameter_property IS_RTL_SIM              HDL_PARAMETER true
set_parameter_property XCVR_TX_PLL_SEL         HDL_PARAMETER false

set common_composed_mode 0

proc elaboration_callback {} {
  set video_std [get_parameter_value VIDEO_STANDARD]
  set device    [get_parameter_value FAMILY]
  set xcvr_tx_pll_sel [get_parameter_value XCVR_TX_PLL_SEL]
  set hd_frequency    [get_parameter_value HD_FREQ]
  
  common_add_clock            xcvr_rxclk                 input  true
  common_add_optional_conduit rx_pll_locked                export  input  1  true

  # common_add_optional_conduit rx_enable_sd_search   input  1  true
  # common_add_optional_conduit rx_enable_hd_search   input  1  true
  # common_add_optional_conduit rx_enable_3g_search   input  1  true
  common_add_optional_conduit rx_trs_loose_lock_in         export  input  1  true
  common_add_optional_conduit rx_datain                    export  input 20  true
  common_add_optional_conduit rx_rst_proto_out             export  output 1  true
  common_add_optional_conduit rx_dataout                   export  output 20 true
  common_add_optional_conduit rx_dataout_valid             export  output 1  true
  common_add_optional_conduit rx_ready                   export  input  1  true

  if {$hd_frequency == "74.25"} {
    common_add_clock            rx_coreclk_hd              input  true
    common_add_reset            rx_rst                     input  rx_coreclk_hd
  } else {
    common_add_clock            rx_coreclk                 input  true
    common_add_reset            rx_rst                     input  rx_coreclk  
  }

  if { $video_std != "sd" } {
    common_add_optional_conduit rx_coreclk_is_ntsc_paln    export  input  1  true
    common_add_optional_conduit rx_clkout_is_ntsc_paln     export  output 1  true
  }

  if {$video_std == "ds" | $video_std == "tr"} {
    common_add_optional_conduit rx_sdi_start_reconfig      export  output 1  true
    common_add_optional_conduit rx_sdi_reconfig_done       export  input  1  true
  }

  if {$video_std == "threeg" | $video_std == "ds" | $video_std == "tr"} {
    common_add_optional_conduit rx_std                     export  output 2  true
  }

  common_add_clock             rx_clkout                   output   true
  
  if { $video_std == "sd" } {
    set clock_rate "67500000"
  } elseif { $video_std == "hd" | $video_std == "dl" } {
    set clock_rate "74250000"
  } elseif { $video_std == "threeg" | $video_std == "ds" | $video_std == "tr" } {
    set clock_rate "148500000"
  }

  set_interface_property       rx_clkout                   clockRateKnown  true
  set_interface_property       rx_clkout                   clockRate       $clock_rate

  if {$video_std == "dl"} {
    common_add_clock            xcvr_rxclk_b               input   true
    common_add_optional_conduit rx_pll_locked_b            export  input  1  true
    common_add_optional_conduit rx_trs_loose_lock_in_b     export  input  1  true
    common_add_optional_conduit rx_datain_b                export  input 20  true
    common_add_optional_conduit rx_rst_proto_out_b         export  output 1  true
    common_add_optional_conduit rx_dataout_b               export  output 20 true
    common_add_optional_conduit rx_dataout_valid_b         export  output 1  true
    common_add_optional_conduit rx_ready_b                 export  input  1  true

    common_add_clock            rx_clkout_b                output          true
    set_interface_property      rx_clkout_b                clockRateKnown  true
    set_interface_property      rx_clkout_b                clockRate       $clock_rate
  }

    common_add_optional_conduit gxb_ltr                    export  output 1  true
    common_add_optional_conduit gxb_ltd                    export  output 1  true
    common_add_optional_conduit trig_rst_ctrl              export  output 1  true
    if {$video_std == "dl"} {
      common_add_optional_conduit gxb_ltr_b                export  output 1  true
      common_add_optional_conduit gxb_ltd_b                export  output 1  true
      common_add_optional_conduit trig_rst_ctrl_b          export  output 1  true
    }

}  
