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


# +--------------------------------------------
# | 
# | SDI II PHY Adapter v12.1 (Stratix V series)
# | Altera Corporation 2011.08.19.17:10:07
# | 
# +-------------------------------------------

package require -exact qsys 12.0

source ../../sdi_ii/sdi_ii_interface.tcl
source ../../sdi_ii/sdi_ii_params.tcl

# +-----------------------------------
# | module SDI II PHY Adapter
# | 
set_module_property DESCRIPTION "SDI II PHY Adapter"
set_module_property NAME sdi_ii_phy_adapter
set_module_property VERSION 13.1
set_module_property INTERNAL true
set_module_property GROUP "Interface Protocols/SDI II/SDI II PHY Adapter"
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "SDI II PHY ADAPTER"
# set_module_property DATASHEET_URL http://www.altera.com/literature/ug/ug_sdi.pdf
# set_module_property TOP_LEVEL_HDL_FILE src_hdl/sdi_ii_phy_adapter.v
# set_module_property TOP_LEVEL_HDL_MODULE sdi_ii_phy_adapter
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

set_fileset_property simulation_verilog TOP_LEVEL   sdi_ii_phy_adapter
set_fileset_property simulation_vhdl    TOP_LEVEL   sdi_ii_phy_adapter
set_fileset_property synthesis_fileset  TOP_LEVEL   sdi_ii_phy_adapter

proc generate_files {name} {
  if {1} {
    add_fileset_file mentor/src_hdl/sdi_ii_phy_adapter.v    VERILOG_ENCRYPT PATH "mentor/src_hdl/sdi_ii_phy_adapter.v"   {MENTOR_SPECIFIC}
  }
  if {1} {
    add_fileset_file aldec/src_hdl/sdi_ii_phy_adapter.v     VERILOG_ENCRYPT PATH "aldec/src_hdl/sdi_ii_phy_adapter.v"    {ALDEC_SPECIFIC}
  }
#  if {0} {
#    add_fileset_file cadence/src_hdl/sdi_ii_phy_adapter.v   VERILOG_ENCRYPT PATH "cadence/src_hdl/sdi_ii_phy_adapter.v"  {CADENCE_SPECIFIC}
#  }
  if {0} {
    add_fileset_file synopsys/src_hdl/sdi_ii_phy_adapter.v  VERILOG_ENCRYPT PATH "synopsys/src_hdl/sdi_ii_phy_adapter.v" {SYNOPSYS_SPECIFIC}
  }
}

#proc sim_vhd {name} {
#  if {1} {
#    add_fileset_file mentor/src_hdl/sdi_ii_phy_adapter.v     VERILOG_ENCRYPT PATH "mentor/src_hdl/sdi_ii_phy_adapter.v"    {MENTOR_SPECIFIC}
#  }
  #if {1} {
  #  add_fileset_file aldec/src_hdl/sdi_ii_phy_adapter.v     VERILOG_ENCRYPT PATH "aldec/src_hdl/sdi_ii_phy_adapter.v"     {ALDEC_SPECIFIC}
  #}
  #if {0} {
  #  add_fileset_file cadence/src_hdl/sdi_ii_phy_adapter.v   VERILOG_ENCRYPT PATH "cadence/src_hdl/sdi_ii_phy_adapter.v"   {CADENCE_SPECIFIC}
  #}
  #if {0} {
  #  add_fileset_file synopsys/src_hdl/sdi_ii_phy_adapter.v  VERILOG_ENCRYPT PATH "synopsys/src_hdl/sdi_ii_phy_adapter.v"  {SYNOPSYS_SPECIFIC}
  #}
#}

# | 
# +-----------------------------------


# +-----------------------------------
# | files
# | 
proc generate_ed_files {name} {
   add_fileset_file sdi_ii_phy_adapter.v                  VERILOG PATH src_hdl/sdi_ii_phy_adapter.v
}

#set module_dir [get_module_property MODULE_DIRECTORY]
#add_file ${module_dir}/src_hdl/sdi_ii_phy_adapter.v  {SYNTHESIS}

# | 
# +-----------------------------------

sdi_ii_common_params
# set_parameter_property FAMILY                  HDL_PARAMETER false
#set_parameter_property VIDEO_STANDARD         HDL_PARAMETER false
set_parameter_property TRANSCEIVER_PROTOCOL    HDL_PARAMETER false
set_parameter_property RX_INC_ERR_TOLERANCE    HDL_PARAMETER false
set_parameter_property RX_CRC_ERROR_OUTPUT     HDL_PARAMETER false
# set_parameter_property RX_EN_TRS_MISC          HDL_PARAMETER false
set_parameter_property RX_EN_VPID_EXTRACT      HDL_PARAMETER false
set_parameter_property RX_EN_A2B_CONV          HDL_PARAMETER false
set_parameter_property RX_EN_B2A_CONV          HDL_PARAMETER false
set_parameter_property TX_HD_2X_OVERSAMPLING   HDL_PARAMETER false
set_parameter_property TX_EN_VPID_INSERT       HDL_PARAMETER false
set_parameter_property SD_BIT_WIDTH            HDL_PARAMETER false
set_parameter_property XCVR_TX_PLL_SEL         HDL_PARAMETER true
set_parameter_property HD_FREQ                 HDL_PARAMETER false

set common_composed_mode 0

proc elaboration_callback {} {
  set dir [get_parameter_value DIRECTION] 
  set video_std [get_parameter_value VIDEO_STANDARD]
  set device_family [get_parameter_value FAMILY]
  set xcvr_tx_pll_sel [get_parameter_value XCVR_TX_PLL_SEL]
  
  if { $xcvr_tx_pll_sel } {
    set txpll_num 2
  } else {
    set txpll_num 1
  }
  
  if { $video_std == "hd" | $video_std == "dl" } {
     set clock_rate "74250000"
  } else {
     set clock_rate "148500000"
  }
  
  if { $xcvr_tx_pll_sel == 1 } {
      set rcfg_frm_xcvr_width 138
      set rcfg_to_xcvr_width 210
  } else {
      if {$dir == "rx" } {
        set rcfg_frm_xcvr_width 46
        set rcfg_to_xcvr_width 70
      } else {
        set rcfg_frm_xcvr_width 92
        set rcfg_to_xcvr_width 140
      }
  }
  
  if { $device_family != "Arria 10" } {
     if {$dir == "rx"} {
       common_add_optional_conduit    reconfig_from_xcvr          reconfig_from_xcvr   output  $rcfg_frm_xcvr_width   true
       common_add_optional_conduit    reconfig_to_xcvr            reconfig_to_xcvr     input   $rcfg_to_xcvr_width   true
       common_add_optional_conduit    xcvr_reconfig_from_xcvr     reconfig_from_xcvr   input   $rcfg_frm_xcvr_width   true
       common_add_optional_conduit    xcvr_reconfig_to_xcvr       reconfig_to_xcvr     output  $rcfg_to_xcvr_width   true

       if {$video_std == "dl"} {
          common_add_optional_conduit reconfig_from_xcvr_b        reconfig_from_xcvr   output  $rcfg_frm_xcvr_width   true
          common_add_optional_conduit reconfig_to_xcvr_b          reconfig_to_xcvr     input   $rcfg_to_xcvr_width   true
          common_add_optional_conduit xcvr_reconfig_from_xcvr_b   reconfig_from_xcvr   input   $rcfg_frm_xcvr_width   true
          common_add_optional_conduit xcvr_reconfig_to_xcvr_b     reconfig_to_xcvr     output  $rcfg_to_xcvr_width   true
       }
     } else {
       common_add_optional_conduit    reconfig_from_xcvr          reconfig_from_xcvr   output  $rcfg_frm_xcvr_width   true
       common_add_optional_conduit    reconfig_to_xcvr            reconfig_to_xcvr     input   $rcfg_to_xcvr_width  true
       common_add_optional_conduit    xcvr_reconfig_from_xcvr     reconfig_from_xcvr   input   $rcfg_frm_xcvr_width   true
       common_add_optional_conduit    xcvr_reconfig_to_xcvr       reconfig_to_xcvr     output  $rcfg_to_xcvr_width  true

       if {$video_std == "dl"} {
          common_add_optional_conduit reconfig_from_xcvr_b        reconfig_from_xcvr   output  $rcfg_frm_xcvr_width   true
          common_add_optional_conduit reconfig_to_xcvr_b          reconfig_to_xcvr     input   $rcfg_to_xcvr_width  true
          common_add_optional_conduit xcvr_reconfig_from_xcvr_b   reconfig_from_xcvr   input   $rcfg_frm_xcvr_width   true
          common_add_optional_conduit xcvr_reconfig_to_xcvr_b     reconfig_to_xcvr     output  $rcfg_to_xcvr_width  true
       }
     }
  }
#  if { $device_family == "Stratix V" || $device_family == "Arria V" || $device_family == "Arria V GZ" } {
#     common_add_clock            xcvr_refclk            input  true
#     common_add_clock            phy_mgmt_clk           input  true
#     common_add_reset            phy_mgmt_clk_reset     input  phy_mgmt_clk
     #common_add_clock            pll_ref_clk_to_xcvr    output true
#     common_add_clock_bus        pll_ref_clk_to_xcvr    output true $txpll_num

#     add_interface          phy_mgmt avalon start
#     set_interface_property phy_mgmt ASSOCIATED_CLOCK phy_mgmt_clk

#     add_interface_port phy_mgmt phy_mgmt_address_to_xcvr         address     Output 11
#     add_interface_port phy_mgmt phy_mgmt_read_to_xcvr            read        Output 1
#     add_interface_port phy_mgmt phy_mgmt_readdata_from_xcvr      readdata    Input  32
#     add_interface_port phy_mgmt phy_mgmt_waitrequest_from_xcvr   waitrequest Input  1
#     add_interface_port phy_mgmt phy_mgmt_write_to_xcvr           write       Output 1
#     add_interface_port phy_mgmt phy_mgmt_writedata_to_xcvr       writedata   Output 32

#     common_add_optional_conduit phy_mgmt_address                 export      input  11  true
#     common_add_optional_conduit phy_mgmt_read                    export      input  1   true  
#     common_add_optional_conduit phy_mgmt_readdata                export      output 32  true
#     common_add_optional_conduit phy_mgmt_waitrequest             export      output 1   true
#     common_add_optional_conduit phy_mgmt_write                   export      input  1   true
#     common_add_optional_conduit phy_mgmt_writedata               export      input  32  true

#     if {$video_std == "dl"} {
#        common_add_clock      pll_ref_clk_to_xcvr_b    output      true

#        add_interface          phy_mgmt_b avalon start
#        set_interface_property phy_mgmt_b ASSOCIATED_CLOCK phy_mgmt_clk 

#        add_interface_port phy_mgmt_b phy_mgmt_address_to_xcvr_b       address      Output 11
#        add_interface_port phy_mgmt_b phy_mgmt_read_to_xcvr_b          read         Output 1
#        add_interface_port phy_mgmt_b phy_mgmt_readdata_from_xcvr_b    readdata     Input  32
#        add_interface_port phy_mgmt_b phy_mgmt_waitrequest_from_xcvr_b waitrequest  Input  1
#        add_interface_port phy_mgmt_b phy_mgmt_write_to_xcvr_b         write        Output 1
#        add_interface_port phy_mgmt_b phy_mgmt_writedata_to_xcvr_b     writedata    Output 32

#        common_add_optional_conduit phy_mgmt_address_b          export  input  11 true
#        common_add_optional_conduit phy_mgmt_read_b             export  input  1  true  
#        common_add_optional_conduit phy_mgmt_readdata_b         export  output 32 true
#        common_add_optional_conduit phy_mgmt_waitrequest_b      export  output 1  true
#        common_add_optional_conduit phy_mgmt_write_b            export  input  1  true
#        common_add_optional_conduit phy_mgmt_writedata_b        export  input  32 true
#     }

#     if {$dir == "du" | $dir == "rx"} {
        ##common_add_clock            rx_refclk            input  true
        ##common_add_reset            rx_rst               input  xcvr_refclk
#        common_add_clock            xcvr_rxclk            output   true 
#        set_interface_property      xcvr_rxclk            clockRateKnown  true
#        set_interface_property      xcvr_rxclk            clockRate       $clock_rate

#        common_add_optional_conduit rxclk_from_xcvr              export  input  1  true 
#        common_add_optional_conduit sdi_rx                       export  input  1  true
#        common_add_optional_conduit xcvr_rx_dataout              export  output 20 true
#        common_add_optional_conduit rx_pll_locked                export  output 1  true
#        common_add_optional_conduit rx_is_lockedtodata           export  output 1  true
#        common_add_optional_conduit sdi_rx_to_xcvr               export  output 1  true
#        common_add_optional_conduit rx_dataout_from_xcvr         export  input  20 true
#        common_add_optional_conduit rxpll_locked_from_xcvr       export  input  1  true
#        common_add_optional_conduit xcvr_rx_ready                export  output 1  true
#        
#        common_add_optional_conduit xcvr_rx_bitslip              export  output 1  true
#        common_add_optional_conduit xcvr_rx_signaldetect         export  input  1  true    
#        common_add_optional_conduit xcvr_rx_is_lockedtodata      export  input  1  true
#        if { $dir == "du"} {
#           common_add_optional_conduit xcvr_tx_forceelecidle      export  output  1  true
#        }
        
#        if { $xcvr_tx_pll_sel } {

#          common_add_reset_associated_sinks            reset_to_xcvr_rst_ctrl       output      xcvr_refclk none
#          common_add_optional_conduit trig_rst_ctrl                export             input  1  true
          
#          common_add_optional_conduit rx_analogreset_from_xcvr_rst       rx_analogreset  input  1  true
#          common_add_optional_conduit rx_digitalreset_from_xcvr_rst      rx_digitalreset  input  1  true
#          common_add_optional_conduit rx_cal_busy_from_xcvr          export  input  1  true
          
#          common_add_optional_conduit rx_analogreset_to_xcvr       export  output  1  true
#          common_add_optional_conduit rx_digitalreset_to_xcvr      export  output  1  true
#          common_add_optional_conduit rx_cal_busy_to_xcvr_rst      rx_cal_busy  output  1  true
#          common_add_optional_conduit rx_is_lockedtodata_to_xcvr_rst    rx_is_lockedtodata  output 1  true
          
          
#          common_add_optional_conduit rx_ready_from_xcvr           rx_ready  input  1  true

#        } else {
#          common_add_optional_conduit rx_ready_from_xcvr           export  input  1  true
#        }
        
#        if {$video_std == "dl"} {
#           common_add_clock            xcvr_rxclk_b        output          true 
#           set_interface_property      xcvr_rxclk_b        clockRateKnown  true
#           set_interface_property      xcvr_rxclk_b        clockRate       $clock_rate

#           common_add_optional_conduit sdi_rx_b                    export  input  1  true
#           common_add_optional_conduit sdi_rx_to_xcvr_b            export  output 1  true
#           common_add_optional_conduit rxclk_from_xcvr_b           export  input  1  true 
#           common_add_optional_conduit xcvr_rx_dataout_b           export  output 20 true
#           common_add_optional_conduit rx_pll_locked_b             export  output 1  true
#           common_add_optional_conduit rx_is_lockedtodata_b        export  output 1  true
#           common_add_optional_conduit rx_dataout_from_xcvr_b      export  input  20 true
#           common_add_optional_conduit rxpll_locked_from_xcvr_b    export  input  1  true
#           common_add_optional_conduit xcvr_rx_ready_b             export  output 1  true
#           common_add_optional_conduit xcvr_rx_bitslip_b           export  output 1  true
#           common_add_optional_conduit xcvr_rx_signaldetect_b      export  input  1  true    
#           common_add_optional_conduit xcvr_rx_is_lockedtodata_b   export  input  1  true
#           if { $dir == "du"} {
#              common_add_optional_conduit xcvr_tx_forceelecidle_b  export  output 1  true
#           }
#           if { $xcvr_tx_pll_sel } {
               
#             common_add_reset_associated_sinks                  reset_to_xcvr_rst_ctrl_b       output   xcvr_refclk     none
#             common_add_optional_conduit trig_rst_ctrl_b        export                          input   1               true
          
#             common_add_optional_conduit rx_analogreset_from_xcvr_rst_b       rx_analogreset  input  1  true
#             common_add_optional_conduit rx_digitalreset_from_xcvr_rst_b      rx_digitalreset  input  1  true
#             common_add_optional_conduit rx_cal_busy_from_xcvr_b          export  input  1  true
             
#             common_add_optional_conduit rx_analogreset_to_xcvr_b       export  output  1  true
#             common_add_optional_conduit rx_digitalreset_to_xcvr_b      export  output  1  true
#             common_add_optional_conduit rx_cal_busy_to_xcvr_rst_b      rx_cal_busy  output  1  true
#             common_add_optional_conduit rx_is_lockedtodata_to_xcvr_rst_b    rx_is_lockedtodata  output 1  true
             
#             common_add_optional_conduit rx_ready_from_xcvr_b        rx_ready  input  1  true
#           } else {
#             common_add_optional_conduit rx_ready_from_xcvr_b        export  input  1  true
#           }
#        }
#     }

#     if {$dir == "du" | $dir == "tx"} {
        ##common_add_clock          tx_refclk                    input  true
        ##common_add_reset          tx_rst                       input  xcvr_refclk
#        common_add_clock            tx_clkout        output          true
#        set_interface_property      tx_clkout        clockRateKnown  true
#        set_interface_property      tx_clkout        clockRate       $clock_rate

#        common_add_optional_conduit sdi_tx                       export  output 1  true
#        common_add_optional_conduit xcvr_tx_datain               export  input  20 true
#        common_add_optional_conduit tx_pll_locked                export  output 1  true
#        common_add_optional_conduit sdi_tx_from_xcvr             export  input  1  true
#        common_add_optional_conduit tx_datain_to_xcvr            export  output 20 true
        
#        common_add_optional_conduit tx_clkout_from_xcvr          export  input  1  true 
        
        
#        if { $xcvr_tx_pll_sel } {
#          common_add_optional_conduit tx_pll_select_to_xcvr_rst   pll_select  output 1  true
#          common_add_optional_conduit txpll_locked_to_xcvr_rst    pll_locked  output 2  true
#          common_add_optional_conduit pll_powerdown_from_xcvr_rst   pll_powerdown      input  2  true
#          common_add_optional_conduit tx_analogreset_from_xcvr_rst  tx_analogreset      input  1  true
#          common_add_optional_conduit tx_digitalreset_from_xcvr_rst tx_digitalreset      input  1  true
#          common_add_optional_conduit tx_cal_busy_from_xcvr     export      input  1  true
          
#          common_add_optional_conduit pll_powerdown_to_xcvr   export      output  2  true
#          common_add_optional_conduit tx_analogreset_to_xcvr  export      output  1  true
#          common_add_optional_conduit tx_digitalreset_to_xcvr export      output  1  true
#          common_add_optional_conduit tx_cal_busy_to_xcvr_rst     tx_cal_busy      output  1  true
          
#          common_add_optional_conduit xcvr_tx_ready                tx_ready  input  1  true
#          common_add_optional_conduit txpll_locked_from_xcvr       export  input  2  true
#        } else {
#          common_add_optional_conduit xcvr_tx_ready                export  input  1  true
#          common_add_optional_conduit txpll_locked_from_xcvr       export  input  1  true
#        }

#        if {$video_std == "dl"} {
#           common_add_optional_conduit sdi_tx_b                   export   output 1  true
#           common_add_optional_conduit xcvr_tx_datain_b           export  input  20 true
           #common_add_optional_conduit tx_pll_locked_b           output 1  true
#           common_add_optional_conduit sdi_tx_from_xcvr_b         export  input  1  true
#           common_add_optional_conduit tx_datain_to_xcvr_b        export  output 20 true
           
           #common_add_clock            tx_clkout_b       output          true
           #set_interface_property      tx_clkout_b       clockRateKnown  true
           #set_interface_property      tx_clkout_b       clockRate       $clock_rate
#           common_add_optional_conduit tx_clkout_from_xcvr_b      export  input  1        true
           
           
#           if { $xcvr_tx_pll_sel } {
#             common_add_optional_conduit tx_pll_select_to_xcvr_rst_b  pll_select   output 1  true
#             common_add_optional_conduit txpll_locked_to_xcvr_rst_b   pll_locked  output  2  true
#             common_add_optional_conduit pll_powerdown_from_xcvr_rst_b   pll_powerdown      input  2  true
#             common_add_optional_conduit tx_analogreset_from_xcvr_rst_b  tx_analogreset      input  1  true
#             common_add_optional_conduit tx_digitalreset_from_xcvr_rst_b tx_digitalreset      input  1  true
#             common_add_optional_conduit tx_cal_busy_from_xcvr_b     export      input  1  true
             
#             common_add_optional_conduit pll_powerdown_to_xcvr_b   export      output  2  true
#             common_add_optional_conduit tx_analogreset_to_xcvr_b  export      output  1  true
#             common_add_optional_conduit tx_digitalreset_to_xcvr_b export      output  1  true
#             common_add_optional_conduit tx_cal_busy_to_xcvr_rst_b     tx_cal_busy      output  1  true
             
#             common_add_optional_conduit xcvr_tx_ready_b            tx_ready  input  1  true
#             common_add_optional_conduit txpll_locked_from_xcvr_b   export  input  2  true
             
#           } else {
#             common_add_optional_conduit xcvr_tx_ready_b            export  input  1  true
#             common_add_optional_conduit txpll_locked_from_xcvr_b   export  input  1  true
#           }
#        }
#     }
#   } elseif { $device_family == "Cyclone V" } {

      if { $device_family == "Arria 10" } {
         set tx_parallel_data_width 128
      } elseif { $device_family == "Stratix V" || $device_family == "Arria V GZ" } {
         set tx_parallel_data_width 64
      } else {
         set tx_parallel_data_width 44
      }
      common_add_clock            xcvr_refclk            input  true
      
      if { $xcvr_tx_pll_sel } {
         common_add_clock            xcvr_refclk_alt          input     true
         common_add_optional_conduit xcvr_refclk_sel          export    input  1  true
         common_add_optional_conduit tx_pll_locked_alt        export    output 1  true
         
      }

      if {$dir == "du" | $dir == "tx"} {
         common_add_clock            tx_clkout        output          true
         set_interface_property      tx_clkout        clockRateKnown  true
         set_interface_property      tx_clkout        clockRate       $clock_rate

         if {$device_family == "Arria 10"} {
            common_add_clock            tx_pll_refclk        output              true
            set_interface_property      tx_pll_refclk        clockRateKnown      true
            set_interface_property      tx_pll_refclk        clockRate           $clock_rate

            common_add_clock            tx_std_coreclkin     output              true
            set_interface_property      tx_std_coreclkin     clockRateKnown      true
            set_interface_property      tx_std_coreclkin     clockRate           $clock_rate

            common_add_clock            tx_clkout_from_xcvr  input               true

            add_interface               tx_serial_clkout     hssi_serial_clock   output
            set_interface_property      tx_serial_clkout     ENABLED             true
            add_interface_port          tx_serial_clkout     tx_serial_clkout    clk      output   1

            add_interface               tx_serial_clkin      hssi_serial_clock   input
            set_interface_property      tx_serial_clkin      ENABLED             true
            add_interface_port          tx_serial_clkin      tx_serial_clkin     clk      input   1

         } else {
            common_add_optional_conduit tx_clkout_from_xcvr          tx_std_clkout      input  1                        true
            common_add_optional_conduit tx_pll_refclk                tx_pll_refclk      output $txpll_num               true
            common_add_optional_conduit tx_std_coreclkin             tx_std_coreclkin   output 1                        true
         }
         common_add_optional_conduit sdi_tx_from_xcvr             tx_serial_data     input  1                        true
         common_add_optional_conduit xcvr_tx_datain               export             input  20                       true
         common_add_optional_conduit tx_pll_locked_from_xcvr      pll_locked         input  $txpll_num               true
         common_add_optional_conduit xcvr_tx_ready                tx_ready           input  1                        true
         common_add_optional_conduit sdi_tx                       export             output 1                        true
         common_add_optional_conduit tx_datain_to_xcvr            tx_parallel_data   output $tx_parallel_data_width  true
         common_add_optional_conduit tx_pll_locked                export             output 1                        true
         common_add_optional_conduit tx_pll_select_to_xcvr_rst    pll_select         output 1                        true

         if {$video_std == "dl"} {
            if {$device_family == "Arria 10"} {
               common_add_clock            tx_pll_refclk_b        output              true
               set_interface_property      tx_pll_refclk_b        clockRateKnown      true
               set_interface_property      tx_pll_refclk_b        clockRate           $clock_rate

               common_add_clock            tx_std_coreclkin_b     output              true
               set_interface_property      tx_std_coreclkin_b     clockRateKnown      true
               set_interface_property      tx_std_coreclkin_b     clockRate           $clock_rate

               common_add_clock            tx_clkout_from_xcvr_b  input               true

               add_interface               tx_serial_clkout_b     hssi_serial_clock   output
               set_interface_property      tx_serial_clkout_b     ENABLED             true
               add_interface_port          tx_serial_clkout_b     tx_serial_clkout_b  clk      output   1

               add_interface               tx_serial_clkin_b      hssi_serial_clock   input
               set_interface_property      tx_serial_clkin_b      ENABLED             true
               add_interface_port          tx_serial_clkin_b      tx_serial_clkin_b   clk      input   1

            } else {
               common_add_optional_conduit tx_clkout_from_xcvr_b         tx_std_clkout      input  1                       true
               common_add_optional_conduit tx_pll_refclk_b               tx_pll_refclk      output $txpll_num              true
               common_add_optional_conduit tx_std_coreclkin_b            tx_std_coreclkin   output 1                       true
            }

            common_add_optional_conduit sdi_tx_from_xcvr_b            tx_serial_data     input  1                       true
            common_add_optional_conduit xcvr_tx_datain_b              export             input  20                      true
            #common_add_optional_conduit tx_pll_locked_from_xcvr_b     pll_locked         input  $txpll_num              true
            common_add_optional_conduit xcvr_tx_ready_b               tx_ready           input  1                       true
            common_add_optional_conduit sdi_tx_b                      export             output 1                       true
            #common_add_optional_conduit tx_pll_locked_b               export             output 1                       true
            common_add_optional_conduit tx_datain_to_xcvr_b           tx_parallel_data   output $tx_parallel_data_width true
            common_add_optional_conduit tx_pll_select_to_xcvr_rst_b   pll_select         output 1                       true
         }
      }

      if {$dir == "du" | $dir == "rx"} {
         common_add_clock            xcvr_rxclk            output   true 
         set_interface_property      xcvr_rxclk            clockRateKnown  true
         set_interface_property      xcvr_rxclk            clockRate       $clock_rate

         if {$device_family == "Arria 10"} {
            common_add_clock            rx_cdr_refclk        output          true
            set_interface_property      rx_cdr_refclk        clockRateKnown  true
            set_interface_property      rx_cdr_refclk        clockRate       $clock_rate

            common_add_clock            rx_std_coreclkin        output          true
            set_interface_property      rx_std_coreclkin        clockRateKnown  true
            set_interface_property      rx_std_coreclkin        clockRate       $clock_rate

            common_add_clock            rxclk_from_xcvr        input          true

            common_add_optional_conduit rx_dataout_from_xcvr         rx_parallel_data   input  128 true

         } else {
            common_add_optional_conduit rx_cdr_refclk                rx_cdr_refclk      output 1  true
            common_add_optional_conduit rx_std_coreclkin             rx_std_coreclkin   output 1  true
            common_add_optional_conduit rxclk_from_xcvr              rx_std_clkout      input  1  true
            common_add_optional_conduit rx_dataout_from_xcvr         rx_parallel_data   input  64 true
            common_add_optional_conduit rx_pma_clkout                rx_pma_clkout      input  1  true
         }
 
         common_add_reset            reset_to_xcvr_rst_ctrl       output             xcvr_rxclk
         common_add_optional_conduit trig_rst_ctrl                export             input  1  true

         common_add_optional_conduit sdi_rx                       export             input  1  true
         common_add_optional_conduit rx_set_locktodata            export             input  1  true
         common_add_optional_conduit rx_set_locktoref             export             input  1  true
         common_add_optional_conduit rxpll_locked_from_xcvr       rx_is_lockedtoref  input  1  true
         common_add_optional_conduit xcvr_rx_is_lockedtodata      rx_is_lockedtodata input  1  true
         common_add_optional_conduit rx_ready_from_xcvr           rx_ready           input  1  true
         common_add_optional_conduit sdi_rx_to_xcvr               rx_serial_data     output 1  true
         common_add_optional_conduit xcvr_rx_dataout              export             output 20 true
         common_add_optional_conduit rx_set_locktodata_to_xcvr    rx_set_locktodata  output 1  true
         common_add_optional_conduit rx_set_locktoref_to_xcvr     rx_set_locktoref   output 1  true
         common_add_optional_conduit rx_pll_locked                export             output 1  true
         common_add_optional_conduit xcvr_rx_ready                export             output 1  true
         common_add_optional_conduit rx_locked_to_xcvr_ctrl       rx_is_lockedtodata output 1  true
         common_add_optional_conduit rx_manual                    rx_reset_mode      output 1  true

         if {$video_std == "dl"} {
            if {$device_family == "Arria 10"} {
               common_add_clock            rx_cdr_refclk_b                output             true
               set_interface_property      rx_cdr_refclk_b                clockRateKnown     true
               set_interface_property      rx_cdr_refclk_b                clockRate          $clock_rate

               common_add_clock            rx_std_coreclkin_b             output             true
               set_interface_property      rx_std_coreclkin_b             clockRateKnown     true
               set_interface_property      rx_std_coreclkin_b             clockRate          $clock_rate

               common_add_clock            rxclk_from_xcvr_b              input              true

               common_add_optional_conduit rx_dataout_from_xcvr_b         rx_parallel_data   input  128 true

            } else {
               common_add_optional_conduit rx_cdr_refclk_b                rx_cdr_refclk      output 1 true
               common_add_optional_conduit rx_std_coreclkin_b             rx_std_coreclkin   output 1  true
               common_add_optional_conduit rxclk_from_xcvr_b              rx_std_clkout      input  1  true
               common_add_optional_conduit rx_pma_clkout_b                rx_pma_clkout      input  1  true
               common_add_optional_conduit rx_dataout_from_xcvr_b         rx_parallel_data   input  64 true
            }

            common_add_clock            xcvr_rxclk_b        output          true 
            set_interface_property      xcvr_rxclk_b        clockRateKnown  true
            set_interface_property      xcvr_rxclk_b        clockRate       $clock_rate

            common_add_reset            reset_to_xcvr_rst_ctrl_b       output             xcvr_rxclk
            common_add_optional_conduit trig_rst_ctrl_b                export             input  1  true
            common_add_optional_conduit sdi_rx_b                       export             input  1  true
            common_add_optional_conduit rx_set_locktodata_b            export             input  1  true
            common_add_optional_conduit rx_set_locktoref_b             export             input  1  true
            common_add_optional_conduit rxpll_locked_from_xcvr_b       rx_is_lockedtoref  input  1  true
            common_add_optional_conduit xcvr_rx_is_lockedtodata_b      rx_is_lockedtodata input  1  true
            common_add_optional_conduit rx_ready_from_xcvr_b           rx_ready           input  1  true
            common_add_optional_conduit sdi_rx_to_xcvr_b               rx_serial_data     output 1  true
            common_add_optional_conduit xcvr_rx_dataout_b              export             output 20 true
            common_add_optional_conduit rx_set_locktodata_to_xcvr_b    rx_set_locktodata  output 1  true
            common_add_optional_conduit rx_set_locktoref_to_xcvr_b     rx_set_locktoref   output 1  true
            common_add_optional_conduit rx_pll_locked_b                export             output 1  true
            common_add_optional_conduit xcvr_rx_ready_b                export             output 1  true
            common_add_optional_conduit rx_locked_to_xcvr_ctrl_b       rx_is_lockedtodata output 1  true
            common_add_optional_conduit rx_manual_b                    rx_reset_mode      output 1  true
         }
      }
#   }
}
