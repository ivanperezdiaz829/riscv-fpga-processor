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
# | SDI II Testbench Control v12.1
# | Altera Corporation 2009.08.19.17:10:07
# | 
# +-----------------------------------

package require -exact qsys 12.0

source ../sdi_ii/sdi_ii_params.tcl
source ../sdi_ii/sdi_ii_interface.tcl

# +-----------------------------------
# | module SDI II Testbench Test Control
# | 
set_module_property DESCRIPTION "SDI II Testbench Control"
set_module_property NAME sdi_ii_tb_control
set_module_property VERSION 13.1
set_module_property INTERNAL true
set_module_property GROUP "Interface Protocols/SDI II Testbench Control"
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "SDI II Testbench Control"
# set_module_property DATASHEET_URL http://www.altera.com/literature/ug/ug_sdi.pdf
# set_module_property TOP_LEVEL_HDL_FILE src_hdl/sdi_ii_tb_control.v
# set_module_property TOP_LEVEL_HDL_MODULE sdi_ii_tb_control
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false
set_module_property ELABORATION_CALLBACK elaboration_callback

# | 
# +-----------------------------------

# +-----------------------------------
# | files
# | 
# set module_dir [get_module_property MODULE_DIRECTORY]
# add_file ${module_dir}/src_hdl/sdi_ii_beta_tb_test_control.v   {SIMULATION}
# add_file ${module_dir}/src_hdl/sdi_ii_beta_tb_reconfig_control.v   {SIMULATION}
# add_file ${module_dir}/src_hdl/sdi_ii_beta_tb_clk_rst_control.v   {SIMULATION}

add_fileset simulation_verilog SIM_VERILOG generate_files
add_fileset simulation_vhdl    SIM_VHDL    generate_files

set_fileset_property simulation_verilog TOP_LEVEL   sdi_ii_tb_control
set_fileset_property simulation_vhdl    TOP_LEVEL   sdi_ii_tb_control

proc generate_files {name} {
   add_fileset_file sdi_ii_tb_control.v       VERILOG PATH src_hdl/sdi_ii_tb_control.v
   add_fileset_file tb_clk_rst.v              VERILOG PATH src_hdl/tb_clk_rst.v
   add_fileset_file tb_data_delay.v           VERILOG PATH src_hdl/tb_data_delay.v
   add_fileset_file tb_serial_delay.sv        SYSTEM_VERILOG PATH src_hdl/tb_serial_delay.sv
   add_fileset_file tb_serial_descrambler.v   VERILOG PATH ../sdi_ii_tb_tx_checker/src_hdl/tb_serial_descrambler.v
   add_fileset_file tb_tasks.v                VERILOG_INCLUDE PATH src_hdl/tb_tasks.v
}

# | 
# +-----------------------------------

set common_composed_mode 0
sdi_ii_common_params
set_parameter_property    FAMILY                     HDL_PARAMETER false
set_parameter_property    DIRECTION                  HDL_PARAMETER true
set_parameter_property    TRANSCEIVER_PROTOCOL       HDL_PARAMETER false
#set_parameter_property   USE_SOFT_LOGIC             HDL_PARAMETER false
#set_parameter_property   STARTING_CHANNEL_NUMBER    HDL_PARAMETER false
set_parameter_property    RX_EN_VPID_EXTRACT         HDL_PARAMETER false
#set_parameter_property    HD_2X_OVERSAMPLING         HDL_PARAMETER false
set_parameter_property    TX_EN_VPID_INSERT          HDL_PARAMETER false
set_parameter_property    SD_BIT_WIDTH               HDL_PARAMETER false
set_parameter_property    XCVR_TX_PLL_SEL            HDL_PARAMETER true
set_parameter_property    HD_FREQ                    HDL_PARAMETER true

sdi_ii_test_params
set_parameter_property    TEST_LN_OUTPUT             HDL_PARAMETER true
set_parameter_property    TEST_SYNC_OUTPUT           HDL_PARAMETER true
set_parameter_property    TEST_RECONFIG_SEQ          HDL_PARAMETER true
set_parameter_property    TEST_DISTURB_SERIAL        HDL_PARAMETER true
set_parameter_property    TEST_DL_SYNC               HDL_PARAMETER true
set_parameter_property    TEST_TRS_LOCKED            HDL_PARAMETER true
set_parameter_property    TEST_FRAME_LOCKED          HDL_PARAMETER true
set_parameter_property    TEST_VPID_OVERWRITE        HDL_PARAMETER true
set_parameter_property    TEST_MULTI_RECON           HDL_PARAMETER true
set_parameter_property    TEST_SERIAL_DELAY          HDL_PARAMETER true
set_parameter_property    TEST_RESET_SEQ             HDL_PARAMETER true
set_parameter_property    TEST_RESET_RECON           HDL_PARAMETER true
set_parameter_property    TEST_RST_PRE_OW            HDL_PARAMETER true
set_parameter_property    TEST_RXSAMPLE_CHK          HDL_PARAMETER true
set_parameter_property    TEST_TXPLL_RECONFIG        HDL_PARAMETER true


proc elaboration_callback {} {

   set family           [get_parameter_value FAMILY]
   set video_std        [get_parameter_value VIDEO_STANDARD]
   set dir              [get_parameter_value DIRECTION]
   set a2b              [get_parameter_value RX_EN_A2B_CONV]
   set b2a              [get_parameter_value RX_EN_B2A_CONV]
   set disturb_serial   [get_parameter_value TEST_DISTURB_SERIAL]
   set dl_sync          [get_parameter_value TEST_DL_SYNC]
   set insert_vpid      [get_parameter_value TX_EN_VPID_INSERT]
   set trs_test         [get_parameter_value TEST_TRS_LOCKED]
   set frame_test       [get_parameter_value TEST_FRAME_LOCKED]
   set multi_recon      [get_parameter_value TEST_MULTI_RECON]
   set reset_reconfig   [get_parameter_value TEST_RESET_RECON]
   set xcvr_tx_pll_sel  [get_parameter_value XCVR_TX_PLL_SEL]
   set xcvr_tx_pll_recon [get_parameter_value TEST_TXPLL_RECONFIG]

   common_add_clock              tx_xcvr_refclk            output   true
   common_add_clock              rx_xcvr_refclk            output   true
   common_add_clock              rx_coreclk                output   true
   common_add_clock              tx_coreclk                output   true
   common_add_clock              tx_chk_refclk             output   true
   common_add_clock              rx_chk_refclk             output   true
   common_add_clock              reconfig_clk              output   true
   common_add_reset              tx_rst                    output   tx_xcvr_refclk
   common_add_reset              rx_rst                    output   rx_xcvr_refclk
   common_add_reset              tx_rst_ch0                output   tx_xcvr_refclk
   common_add_reset              rx_rst_ch0                output   rx_xcvr_refclk
   common_add_reset              rx_chk_rst                output   rx_xcvr_refclk

   #if { $family == "Stratix V" || $family== "Arria V" || $family== "Arria V GZ" } {
   #   common_add_clock           phy_mgmt_clk              output   true
   #   common_add_reset           rx_phy_mgmt_clk_rst       output   phy_mgmt_clk
   #   if { $dir == "tx" || $dir == "rx" } {
   #     common_add_reset           tx_phy_mgmt_clk_rst       output   phy_mgmt_clk
   #   }
   #} else {
   #   common_add_clock           tx_coreclk                output   true
   #   common_add_clock            clk_fpga                  output   true
   #}
   
   if { $family != "Stratix V" && $family != "Arria V" && $family != "Arria V GZ" && $family != "Cyclone V" } {
      common_add_clock           tx_coreclk                output   true
      common_add_clock           clk_fpga                  output   true
   }

   if { $a2b | $b2a } {
      set insert_vpid 1
      common_add_clock           tx_xcvr_refclk_smpte372   output   true
      common_add_clock           rx_xcvr_refclk_smpte372   output   true
      common_add_clock           tx_coreclk_smpte372       output   true
      common_add_clock           rx_coreclk_smpte372       output   true
      common_add_reset           tx_rst_smpte372           output   tx_xcvr_refclk_smpte372
      common_add_reset           rx_rst_smpte372           output   rx_xcvr_refclk_smpte372
      common_add_optional_conduit      rx_rst_proto        export   input   1   true

      #if { $family == "Stratix V" || $family== "Arria V" || $family== "Arria V GZ"  } {
      #   common_add_clock        phy_mgmt_clk_smpte372     output   true
      #} else {
      #   common_add_clock              tx_coreclk_smpte372   output   true
      #   common_add_optional_conduit   sdi_gxb_powerdown     export  output   1   true
      #}
      
      # if { $family != "Stratix V" && $family != "Arria V" && $family != "Arria V GZ"  } {
      #    common_add_clock              tx_coreclk_smpte372   output   true
      #    common_add_optional_conduit   sdi_gxb_powerdown     export  output   1   true
      # }
   }

   common_add_optional_conduit       pattgen_bar_100_75n    export  output   1   true
   #common_add_optional_conduit   pattgen_enable            output   1   true
   common_add_optional_conduit       pattgen_patho          export  output   1   true
   common_add_optional_conduit       pattgen_blank          export  output   1   true
   common_add_optional_conduit       pattgen_no_color       export  output   1   true  
   common_add_optional_conduit       pattgen_sgmt_frame     export  output   1   true  
   common_add_optional_conduit       pattgen_dl_mapping     export  output   1   true
   common_add_optional_conduit       pattgen_tx_std         export  output   2   true
   common_add_optional_conduit       pattgen_tx_format      export  output   4   true
   common_add_optional_conduit       pattgen_ntsc_paln      export  output   1   true

   common_add_optional_conduit       tx_status              export  output   1   true
   common_add_optional_conduit       tx_pll_locked          export  input    1   true

   if { $video_std != "sd" } {
     common_add_optional_conduit     tx_enable_crc          export  output   1   true
     common_add_optional_conduit     tx_enable_ln           export  output   1   true
   }

   # common_add_optional_conduit   rx_enable_sd_search       output   1   true
   # common_add_optional_conduit   rx_enable_hd_search       output   1   true
   # common_add_optional_conduit   rx_enable_3g_search       output   1   true

   common_add_optional_conduit       tx_chk_tx_std          export  output   2   true
   common_add_optional_conduit       tx_chk_start_chk       export  output   2   true

   common_add_optional_conduit       rx_chk_done            export  input    2   true
   common_add_optional_conduit       rx_chk_start_chk       export  output   2   true
   common_add_optional_conduit       rx_chk_dl_mapping      export  output   1   true
   common_add_optional_conduit       rx_chk_tx_format       export  output   4   true
   common_add_optional_conduit       rx_chk_completed       export  input    1   true

   if { $video_std == "threeg" | $video_std == "ds" | $video_std == "tr" } {
      common_add_optional_conduit    tx_std                 export  output   2   true
   }

   if { $multi_recon } {
      common_add_optional_conduit    rx_chk_start_chk_ch0   export  output   2   true
      common_add_optional_conduit    rx_chk_done_ch0        export  input    2   true
      common_add_optional_conduit    rx_chk_completed_ch0   export  input    1   true
   }

   if { $insert_vpid } {
      # common_add_optional_conduit   tx_enable_vpid_c       export  output   1   true
      common_add_optional_conduit    tx_vpid_overwrite      export  output   1   true
    }

   if { $disturb_serial | $dl_sync | $trs_test | $frame_test } {
       common_add_optional_conduit   tx_sdi_serial         export  input    1   true
       common_add_optional_conduit   rx_sdi_serial         export  output   1   true

      if { ($video_std == "dl" & !$a2b) | $b2a } {
         common_add_optional_conduit tx_sdi_serial_b       export  input    1   true
         common_add_optional_conduit rx_sdi_serial_b       export  output   1   true
      }
   }
    
   if { $multi_recon } {
      if { $disturb_serial == "0" } {
        common_add_optional_conduit tx_sdi_serial          export  input     1  true
      }
      common_add_optional_conduit   rx_sdi_serial_ch0      export  output    1  true
   }
      
   if { $dl_sync | $trs_test | $frame_test } {
      common_add_optional_conduit   pattgen_dout           export  input    20  true
      common_add_optional_conduit   pattgen_dvalid         export  input    1   true
      common_add_optional_conduit   pattgen_trs            export  input    1   true
      common_add_optional_conduit   tx_dout                export  output   20  true
      common_add_optional_conduit   tx_dvalid              export  output   1   true
      common_add_optional_conduit   tx_trs                 export  output   1   true

      if { $video_std == "dl" } {
         common_add_optional_conduit pattgen_dout_b        export  input    20  true
         common_add_optional_conduit pattgen_dvalid_b      export  input    1   true
         common_add_optional_conduit pattgen_trs_b         export  input    1   true
         common_add_optional_conduit tx_dout_b             export  output   20  true
         common_add_optional_conduit tx_dvalid_b           export  output   1   true
         common_add_optional_conduit tx_trs_b              export  output   1   true
      }
    }

   if { $reset_reconfig } {
     common_add_reset              reconfig_rst            output         reconfig_clk
     common_add_optional_conduit   rx_sdi_start_reconfig   export         input   1   true
     common_add_optional_conduit   rx_reconfig_busy        reconfig_busy  input   1   true
   }
   
   if { $xcvr_tx_pll_sel | $xcvr_tx_pll_recon } {
     common_add_clock              tx_xcvr_refclk_alt       output   true
     common_add_optional_conduit   tx_sdi_start_reconfig    export  output   1   true
     #common_add_optional_conduit   tx_xcvr_refclk_sel       export  output   1   true
     common_add_optional_conduit   tx_sdi_pll_sel           export  output   1   true
     common_add_optional_conduit   tx_pll_locked_alt        export  input    1   true
     common_add_optional_conduit   tx_clkout_match          export  input    1   true
     common_add_optional_conduit   rx_check_posedge         export  input    1   true  
   }
   
}
