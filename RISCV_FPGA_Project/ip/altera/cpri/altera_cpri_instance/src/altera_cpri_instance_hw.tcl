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
# | module cpri_instance_wrapper
# |


package require -exact sopc 11.0
# +-------------------------------
# | For AVGT support
# |

set_module_property NAME altera_cpri_instance
set_module_property VERSION 13.1 
set_module_property AUTHOR "Altera Corporation"

set_module_property INTERNAL true
set_module_property DESCRIPTION "ALTERA CPRI"
set_module_property GROUP "Interface Protocols/High Speed"
set_module_property DISPLAY_NAME "CPRI_INSTANCE"
set_module_property LIBRARIES {ieee.std_logic_1164.all ieee.std_logic_arith.all ieee.std_logic_unsigned.all std.standard.all}
set_module_property TOP_LEVEL_HDL_FILE altera_cpri.vhd
set_module_property STATIC_TOP_LEVEL_MODULE_NAME altera_cpri
set_module_property TOP_LEVEL_HDL_MODULE altera_cpri
set_module_property EDITABLE false
set_module_property SIMULATION_MODEL_IN_VHDL true
set_module_property SIMULATION_MODEL_IN_VERILOG true
set_module_property ALLOW_GREYBOX_GENERATION true
set_module_property ELABORATION_CALLBACK my_elaboration_callback 
set_module_property VALIDATION_CALLBACK  my_validation_callback

# For files accessing
set module_dir [get_module_property MODULE_DIRECTORY]

# For IPFS model 
add_fileset synth QUARTUS_SYNTH synth_proc

# +-----------------------------------
# | files
# | 
add_file altera_cpri.vhd                                                                                                     SYNTHESIS
add_file cpri.vhd                                                                                                            SYNTHESIS
add_file cpri_cal.vhd                                                                                                        SYNTHESIS
add_file cpri_reg.vhd                                                                                                        SYNTHESIS
add_file cpri_cpuif.vhd                                                                                                      SYNTHESIS
add_file cpri_rx.vhd                                                                                                         SYNTHESIS
add_file cpri_rx_map.vhd                                                                                                     SYNTHESIS
add_file cpri_tx.vhd                                                                                                         SYNTHESIS
add_file cpri_tx_map.vhd                                                                                                     SYNTHESIS 
add_file altgx/614/arria2gx_614_m.vhd                                                                                        SYNTHESIS
add_file altgx/614/arria2gx_614_s_tx.vhd                                                                                     SYNTHESIS
add_file altgx/614/arria2gx_614_s_rx.vhd                                                                                     SYNTHESIS
add_file altgx/1228/arria2gx_1228_m.vhd                                                                                      SYNTHESIS
add_file altgx/1228/arria2gx_1228_s_tx.vhd                                                                                   SYNTHESIS
add_file altgx/1228/arria2gx_1228_s_rx.vhd                                                                                   SYNTHESIS
add_file altgx/2457/arria2gx_2457_m.vhd                                                                                      SYNTHESIS
add_file altgx/2457/arria2gx_2457_s_tx.vhd                                                                                   SYNTHESIS
add_file altgx/2457/arria2gx_2457_s_rx.vhd                                                                                   SYNTHESIS
add_file altgx/3072/arria2gx_3072_m.vhd                                                                                      SYNTHESIS
add_file altgx/3072/arria2gx_3072_s_tx.vhd                                                                                   SYNTHESIS
add_file altgx/3072/arria2gx_3072_s_rx.vhd                                                                                   SYNTHESIS
add_file altgx/4915/arria2gx_4915_m.vhd                                                                                      SYNTHESIS
add_file altgx/4915/arria2gx_4915_s_tx.vhd                                                                                   SYNTHESIS
add_file altgx/4915/arria2gx_4915_s_rx.vhd                                                                                   SYNTHESIS
add_file altgx/6144/arria2gx_6144_m.vhd                                                                                      SYNTHESIS
add_file altgx/6144/arria2gx_6144_s_tx.vhd                                                                                   SYNTHESIS
add_file altgx/6144/arria2gx_6144_s_rx.vhd                                                                                   SYNTHESIS
add_file altgx/614/stratix4gx_614_m.vhd                                                                                      SYNTHESIS
add_file altgx/614/stratix4gx_614_s_tx.vhd                                                                                   SYNTHESIS
add_file altgx/614/stratix4gx_614_s_rx.vhd                                                                                   SYNTHESIS
add_file altgx/1228/stratix4gx_1228_m.vhd                                                                                    SYNTHESIS
add_file altgx/1228/stratix4gx_1228_s_tx.vhd                                                                                 SYNTHESIS
add_file altgx/1228/stratix4gx_1228_s_rx.vhd                                                                                 SYNTHESIS
add_file altgx/2457/stratix4gx_2457_m.vhd                                                                                    SYNTHESIS
add_file altgx/2457/stratix4gx_2457_s_tx.vhd                                                                                 SYNTHESIS
add_file altgx/2457/stratix4gx_2457_s_rx.vhd                                                                                 SYNTHESIS
add_file altgx/3072/stratix4gx_3072_m.vhd                                                                                    SYNTHESIS
add_file altgx/3072/stratix4gx_3072_s_tx.vhd                                                                                 SYNTHESIS
add_file altgx/3072/stratix4gx_3072_s_rx.vhd                                                                                 SYNTHESIS
add_file altgx/4915/stratix4gx_4915_m.vhd                                                                                    SYNTHESIS
add_file altgx/4915/stratix4gx_4915_s_tx.vhd                                                                                 SYNTHESIS
add_file altgx/4915/stratix4gx_4915_s_rx.vhd                                                                                 SYNTHESIS
add_file altgx/6144/stratix4gx_6144_m.vhd                                                                                    SYNTHESIS
add_file altgx/6144/stratix4gx_6144_s_tx.vhd                                                                                 SYNTHESIS
add_file altgx/6144/stratix4gx_6144_s_rx.vhd                                                                                 SYNTHESIS
add_file altgx/614/cyclone4gx_614_m.vhd                                                                                      SYNTHESIS
add_file altgx/614/cyclone4gx_614_s_tx.vhd                                                                                   SYNTHESIS
add_file altgx/614/cyclone4gx_614_s_rx.vhd                                                                                   SYNTHESIS
add_file altgx/1228/cyclone4gx_1228_m.vhd                                                                                    SYNTHESIS
add_file altgx/1228/cyclone4gx_1228_s_tx.vhd                                                                                 SYNTHESIS
add_file altgx/1228/cyclone4gx_1228_s_rx.vhd                                                                                 SYNTHESIS
add_file altgx/2457/cyclone4gx_2457_m.vhd                                                                                    SYNTHESIS
add_file altgx/2457/cyclone4gx_2457_s_tx.vhd                                                                                 SYNTHESIS
add_file altgx/2457/cyclone4gx_2457_s_rx.vhd                                                                                 SYNTHESIS
add_file altgx/3072/cyclone4gx_3072_m.vhd                                                                                    SYNTHESIS
add_file altgx/3072/cyclone4gx_3072_s_tx.vhd                                                                                 SYNTHESIS
add_file altgx/3072/cyclone4gx_3072_s_rx.vhd                                                                                 SYNTHESIS
add_file altgx/614/arria2gz_614_m.vhd                                                                                        SYNTHESIS
add_file altgx/614/arria2gz_614_s_tx.vhd                                                                                     SYNTHESIS
add_file altgx/614/arria2gz_614_s_rx.vhd                                                                                     SYNTHESIS
add_file altgx/1228/arria2gz_1228_m.vhd                                                                                      SYNTHESIS
add_file altgx/1228/arria2gz_1228_s_tx.vhd                                                                                   SYNTHESIS
add_file altgx/1228/arria2gz_1228_s_rx.vhd                                                                                   SYNTHESIS
add_file altgx/2457/arria2gz_2457_m.vhd                                                                                      SYNTHESIS
add_file altgx/2457/arria2gz_2457_s_tx.vhd                                                                                   SYNTHESIS
add_file altgx/2457/arria2gz_2457_s_rx.vhd                                                                                   SYNTHESIS
add_file altgx/3072/arria2gz_3072_m.vhd                                                                                      SYNTHESIS
add_file altgx/3072/arria2gz_3072_s_tx.vhd                                                                                   SYNTHESIS
add_file altgx/3072/arria2gz_3072_s_rx.vhd                                                                                   SYNTHESIS
add_file altgx/4915/arria2gz_4915_m.vhd                                                                                      SYNTHESIS
add_file altgx/4915/arria2gz_4915_s_tx.vhd                                                                                   SYNTHESIS
add_file altgx/4915/arria2gz_4915_s_rx.vhd                                                                                   SYNTHESIS
add_file altgx/6144/arria2gz_6144_m.vhd                                                                                      SYNTHESIS
add_file altgx/6144/arria2gz_6144_s_tx.vhd                                                                                   SYNTHESIS
add_file altgx/6144/arria2gz_6144_s_rx.vhd                                                                                   SYNTHESIS
add_file src_altera/buf_ram.vhd                                                                                              SYNTHESIS
add_file src_altera/dp_ram.vhd                                                                                               SYNTHESIS
add_file src_altera/sp_ram.vhd                                                                                               SYNTHESIS
add_file src_shared/prbs_pck.vhd                                                                                             SYNTHESIS
add_file src_shared/pck_4b5b.vhd                                                                                             SYNTHESIS
add_file src_shared/loop_buf.vhd                                                                                             SYNTHESIS
add_file src_shared/ieee_ext.vhd                                                                                             SYNTHESIS
add_file src_shared/gray_pck.vhd                                                                                             SYNTHESIS
add_file src_shared/clock_sync.vhd                                                                                           SYNTHESIS
add_file src_shared/eth_crc_pck.vhd                                                                                          SYNTHESIS
add_file src_shared/freq_lock_check.vhd                                                                                      SYNTHESIS
add_file src_shared/sync_event.vhd                                                                                           SYNTHESIS
add_file src_shared/sync_bit.vhd                                                                                             SYNTHESIS
add_file src_shared/sync_vector.vhd                                                                                          SYNTHESIS
add_file src_shared/cpu_clock_sync.vhd                                                                                       SYNTHESIS
add_file src_shared/buf_ctrl.vhd                                                                                             SYNTHESIS
add_file src_shared/clock_switch.vhd                                                                                         SYNTHESIS
add_file src_mac/mac_tx.vhd                                                                                                  SYNTHESIS
add_file src_mac/mac_rx.vhd                                                                                                  SYNTHESIS
add_file src_mac/mac_reg.vhd                                                                                                 SYNTHESIS
add_file src_mac/mac_crc_calc.vhd                                                                                            SYNTHESIS
add_file src_mac/mac_cpuif.vhd                                                                                               SYNTHESIS
add_file src_mac/mac_buf_tx.vhd                                                                                              SYNTHESIS
add_file src_mac/mac_buf_rx.vhd                                                                                              SYNTHESIS
add_file src_mac/mac_ram.vhd                                                                                                 SYNTHESIS
add_file src_mac/mac.vhd                                                                                                     SYNTHESIS
add_file src_hdlc/hdlc_ram.vhd                                                                                               SYNTHESIS
add_file src_hdlc/hdlc_tx.vhd                                                                                                SYNTHESIS
add_file src_hdlc/hdlc_rx.vhd                                                                                                SYNTHESIS
add_file src_hdlc/hdlc_reg.vhd                                                                                               SYNTHESIS
add_file src_hdlc/hdlc_cpuif.vhd                                                                                             SYNTHESIS
add_file src_hdlc/hdlc_crc_calc.vhd                                                                                          SYNTHESIS
add_file src_hdlc/hdlc_buf_tx.vhd                                                                                            SYNTHESIS
add_file src_hdlc/hdlc_buf_rx.vhd                                                                                            SYNTHESIS
add_file src_hdlc/hdlc.vhd                                                                                                   SYNTHESIS
add_file reset_controller.vhd                                                                                                SYNTHESIS
add_file cpri.ocp                                                                                                            SYNTHESIS
add_file cpri2.ocp                                                                                                           SYNTHESIS
add_file cpri3.ocp                                                                                                           SYNTHESIS

# | 
# +-----------------------------------

# +-----------------------------------
# | parameters
# | 
add_parameter DEVICE integer 0
set_parameter_property DEVICE VISIBLE false
set_parameter_property DEVICE DERIVED true
set_parameter_property DEVICE IS_HDL_PARAMETER true 

add_parameter DEVICEFAMILY String ""
set_parameter_property DEVICEFAMILY VISIBLE false
set_parameter_property DEVICEFAMILY AFFECTS_GENERATION false
set_parameter_property DEVICEFAMILY IS_HDL_PARAMETER false
set_parameter_property DEVICEFAMILY SYSTEM_INFO DEVICE_FAMILY

add_parameter SYNC_MODE INTEGER 0 "This parameter specifies whether the CPRI MegaCore function is a Master or Slave port."
set_parameter_property SYNC_MODE DISPLAY_NAME "Operation mode " 
set_parameter_property SYNC_MODE UNITS None
set_parameter_property SYNC_MODE ALLOWED_RANGES {0:Master\ \(REC\ or\ RE\ Master\) 1:Slave\ \(RE\ Slave\)}
set_parameter_property SYNC_MODE DISPLAY_HINT ""
set_parameter_property SYNC_MODE AFFECTS_GENERATION true 
set_parameter_property SYNC_MODE IS_HDL_PARAMETER true
add_display_item "Physical Layer" SYNC_MODE parameter

add_parameter LINERATE INTEGER 614 "This parameter specifies the line rate on the CPRI link in Gigabaud"
set_parameter_property LINERATE DISPLAY_NAME "Line rate (Gbit/s) "
set_parameter_property LINERATE UNITS None
set_parameter_property LINERATE ALLOWED_RANGES {614:0.6144 0:1.2288 1:2.4576 2:3.0720 3:4.9152 4:6.1440 5:9.8304}
set_parameter_property LINERATE DISPLAY_HINT ""
set_parameter_property LINERATE AFFECTS_GENERATION true 
set_parameter_property LINERATE IS_HDL_PARAMETER true 
add_display_item "Physical Layer" LINERATE parameter

set ch [list]; for {set i 0} {$i < 381} {incr i} {  if {$i%4==0} { set ch [linsert $ch $i $i] } }

add_parameter S_CH_NUMBER_M INTEGER 0 "This parameter specifies the Starting Channel Number of Master Transceiver."
set_parameter_property S_CH_NUMBER_M DISPLAY_NAME "Master transceiver starting channel number"
set_parameter_property S_CH_NUMBER_M UNITS None
set_parameter_property S_CH_NUMBER_M ALLOWED_RANGES $ch
set_parameter_property S_CH_NUMBER_M DISPLAY_HINT ""
set_parameter_property S_CH_NUMBER_M AFFECTS_GENERATION true
set_parameter_property S_CH_NUMBER_M IS_HDL_PARAMETER true
add_display_item "Physical Layer" S_CH_NUMBER_M parameter

add_parameter S_CH_NUMBER_S_TX INTEGER 0 "This parameter specifies the Starting Channel Number of Slave Transmitter."
set_parameter_property S_CH_NUMBER_S_TX DISPLAY_NAME "Slave transmitter starting channel number" 
set_parameter_property S_CH_NUMBER_S_TX UNITS None
set_parameter_property S_CH_NUMBER_S_TX ALLOWED_RANGES $ch
set_parameter_property S_CH_NUMBER_S_TX DISPLAY_HINT ""
set_parameter_property S_CH_NUMBER_S_TX AFFECTS_GENERATION true
set_parameter_property S_CH_NUMBER_S_TX IS_HDL_PARAMETER true
add_display_item "Physical Layer" S_CH_NUMBER_S_TX parameter

add_parameter S_CH_NUMBER_S_RX INTEGER 4 "This parameter specifies the Starting Channel Number of Slave Receiver."
set_parameter_property S_CH_NUMBER_S_RX DISPLAY_NAME "Slave receiver starting channel number" 
set_parameter_property S_CH_NUMBER_S_RX UNITS None
set_parameter_property S_CH_NUMBER_S_RX ALLOWED_RANGES $ch
set_parameter_property S_CH_NUMBER_S_RX DISPLAY_HINT ""
set_parameter_property S_CH_NUMBER_S_RX AFFECTS_GENERATION true 
set_parameter_property S_CH_NUMBER_S_RX IS_HDL_PARAMETER true
add_display_item "Physical Layer" S_CH_NUMBER_S_RX parameter

add_parameter WIDTH_RX_BUF INTEGER 6 "This parameter specifies log2 of the depth of receiver elastic buffer."
set_parameter_property WIDTH_RX_BUF DISPLAY_NAME "Receiver FIFO depth (value shown is log2 of actual depth)" 
set_parameter_property WIDTH_RX_BUF UNITS None
set_parameter_property WIDTH_RX_BUF ALLOWED_RANGES {4:4 5:5 6:6 7:7 8:8}
set_parameter_property WIDTH_RX_BUF DISPLAY_HINT ""
set_parameter_property WIDTH_RX_BUF AFFECTS_GENERATION true 
set_parameter_property WIDTH_RX_BUF IS_HDL_PARAMETER true
add_display_item "Physical Layer" WIDTH_RX_BUF parameter

add_parameter XCVR_FREQ STRING 61.44 "This parameter specifies the frequency of the transceiver reference clock"
set_parameter_property XCVR_FREQ DISPLAY_NAME "Transceiver reference clock frequency "
set_parameter_property XCVR_FREQ UNITS Megahertz
set_parameter_property XCVR_FREQ DISPLAY_HINT ""
set_parameter_property XCVR_FREQ AFFECTS_GENERATION true 
set_parameter_property XCVR_FREQ IS_HDL_PARAMETER false 
add_display_item "Physical Layer" XCVR_FREQ parameter

add_parameter AUTORATE integer 0 "This parameter specifies whether the auto-rate negotiation feature is turned on or not"
set_parameter_property AUTORATE DISPLAY_NAME "Enable auto-rate negotiation "
set_parameter_property AUTORATE DISPLAY_HINT boolean
set_parameter_property AUTORATE AFFECTS_GENERATION true
set_parameter_property AUTORATE IS_HDL_PARAMETER true
add_display_item "Physical Layer" AUTORATE parameter

add_parameter CAL_OFF integer 0
set_parameter_property CAL_OFF VISIBLE false
set_parameter_property CAL_OFF DERIVED true
set_parameter_property CAL_OFF IS_HDL_PARAMETER true

add_parameter CALOFF boolean 0 "This parameter specifies whether to include the automatic round-trip delay calibration logic or not"
set_parameter_property CALOFF DISPLAY_NAME "Include automatic round-trip delay calibration logic"
set_parameter_property CALOFF DISPLAY_HINT boolean
set_parameter_property CALOFF IS_HDL_PARAMETER false
add_display_item "Physical Layer" CALOFF parameter

add_parameter HDLC_OFF integer 0
set_parameter_property HDLC_OFF VISIBLE false
set_parameter_property HDLC_OFF DERIVED true
set_parameter_property HDLC_OFF IS_HDL_PARAMETER true

add_parameter HDLCOFF boolean 0 "This parameter specifies whether to include internal HDLC block or not"
set_parameter_property HDLCOFF DISPLAY_NAME "Include HDLC block "
set_parameter_property HDLCOFF DISPLAY_HINT boolean
set_parameter_property HDLCOFF AFFECTS_GENERATION false
set_parameter_property HDLCOFF IS_HDL_PARAMETER false
add_display_item "Data Link Layer" HDLCOFF parameter

add_parameter MAC_OFF integer 0
set_parameter_property MAC_OFF VISIBLE false
set_parameter_property MAC_OFF DERIVED true
set_parameter_property MAC_OFF IS_HDL_PARAMETER true

add_parameter MACOFF boolean 0 "This parameter specifies whether to include internal MAC block or not"
set_parameter_property MACOFF DISPLAY_NAME "Include MAC block "
set_parameter_property MACOFF DISPLAY_HINT boolean
set_parameter_property MACOFF AFFECTS_GENERATION false
set_parameter_property MACOFF IS_HDL_PARAMETER false
add_display_item "Data Link Layer" MACOFF parameter

add_parameter MAP_MODE INTEGER 4 "This parameter specifies the CPRI MegaCore function mapping mode."
set_parameter_property MAP_MODE DISPLAY_NAME "Mapping mode " 
set_parameter_property MAP_MODE UNITS None
set_parameter_property MAP_MODE ALLOWED_RANGES {0:Basic 1:Advanced\ 1 2:Advanced\ 2 3:Advanced\ 3 4:All}
set_parameter_property MAP_MODE DISPLAY_HINT ""
set_parameter_property MAP_MODE AFFECTS_GENERATION true 
set_parameter_property MAP_MODE IS_HDL_PARAMETER true
add_display_item "Application Layer" MAP_MODE parameter

add_parameter N_MAP INTEGER 0 "This parameter specifices how many antenna/carrier interfaces are enabled"
set_parameter_property N_MAP DISPLAY_NAME "Number of antenna/carrier interfaces "
set_parameter_property N_MAP UNITS None
set_parameter_property N_MAP ALLOWED_RANGES {0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24}
set_parameter_property N_MAP DISPLAY_HINT ""
set_parameter_property N_MAP AFFECTS_GENERATION true
set_parameter_property N_MAP IS_HDL_PARAMETER true
add_display_item "Application Layer" N_MAP parameter

add_parameter SYNC_MAP integer 0 "This parameter specifies whether the map synchronization with core clock feature is turned on or not"
set_parameter_property SYNC_MAP DISPLAY_NAME "Enable map synchronization with core clock "
set_parameter_property SYNC_MAP DISPLAY_HINT boolean
set_parameter_property SYNC_MAP AFFECTS_GENERATION true
set_parameter_property SYNC_MAP IS_HDL_PARAMETER true
add_display_item "Application Layer" SYNC_MAP parameter

add_parameter VSS_OFF integer 0
set_parameter_property VSS_OFF VISIBLE false
set_parameter_property VSS_OFF DERIVED true
set_parameter_property VSS_OFF IS_HDL_PARAMETER true

add_parameter VSSOFF boolean 0 "This parameter specifies whether the Vendor Specific Space (VSS) access is turned on or not"
set_parameter_property VSSOFF DISPLAY_NAME "Include Vendor Specific Space (VSS) access through CPU interface"
set_parameter_property VSSOFF DISPLAY_HINT boolean
set_parameter_property VSSOFF IS_HDL_PARAMETER false
add_display_item "Application Layer" VSSOFF parameter

add_parameter CODE_BASE integer 0 "This parameter specifies which code base to select"
set_parameter_property CODE_BASE DISPLAY_NAME "Code base number"
set_parameter_property CODE_BASE UNITS None
set_parameter_property CODE_BASE ALLOWED_RANGES {0 1 2 3}
set_parameter_property CODE_BASE DISPLAY_HINT boolean
set_parameter_property CODE_BASE AFFECTS_GENERATION true
set_parameter_property CODE_BASE IS_HDL_PARAMETER true
set_parameter_property CODE_BASE VISIBLE false
add_display_item "Application Layer" CODE_BASE parameter

# | 
# +-----------------------------------

# +-----------------------------------
# + Top-level interfaces                                                                         
# +-----------------------------------

# +-----------------------------------
# | connection point gxb_refclk
# | 
add_interface      gxb_refclk                          conduit end
add_interface_port gxb_refclk gxb_refclk               export  Input 1

# +-----------------------------------
# | connection point gxb_pll_inclk
# |
add_interface      gxb_pll_inclk                       conduit end
add_interface_port gxb_pll_inclk gxb_pll_inclk         export  Input 1

# +-----------------------------------
# | connection point gxb_cal_blk_clk
# |
add_interface      gxb_cal_blk_clk                      conduit end
add_interface_port gxb_cal_blk_clk gxb_cal_blk_clk      export  Input 1

# +-----------------------------------
# | GXB connection point gxb_powerdown
# | 
add_interface      gxb_powerdown                        conduit end
add_interface_port gxb_powerdown gxb_powerdown          export  Input 1

# +-----------------------------------
# | GXB connection point pll_locked
# | 
add_interface      gxb_pll_locked                       conduit start 
add_interface_port gxb_pll_locked gxb_pll_locked        export  Output 1

# +-----------------------------------
# | GXB connection point rx_pll_locked
# | 
add_interface      gxb_rx_pll_locked                     conduit start
add_interface_port gxb_rx_pll_locked gxb_rx_pll_locked   export  Output 1

# +-----------------------------------
# | GXB connection point rx_freqlocked
# | 
add_interface      gxb_rx_freqlocked                     conduit start
add_interface_port gxb_rx_freqlocked gxb_rx_freqlocked   export  Output 1

# +-----------------------------------
# | GXB connection point rx_errdetect
# | 
add_interface      gxb_rx_errdetect                       conduit start
add_interface_port gxb_rx_errdetect gxb_rx_errdetect      export  Output 4

# +-----------------------------------
# | GXB connection point rx_disperr
# | 
add_interface      gxb_rx_disperr                         conduit start
add_interface_port gxb_rx_disperr gxb_rx_disperr          export  Output 4

# +-----------------------------------
# | GXB connection point gxb_los
# | 
add_interface      gxb_los                                conduit end
add_interface_port gxb_los gxb_los                        export  Input 1 

# +-----------------------------------
# | GXB connection point gxb_txdataout
# | 
add_interface      gxb_txdataout                          conduit start
add_interface_port gxb_txdataout gxb_txdataout            export  Output 1

# +-----------------------------------
# | GXB connection point gxb_rxdatain
# | 
add_interface      gxb_rxdatain                           conduit end 
add_interface_port gxb_rxdatain gxb_rxdatain              export  Input 1    

# +-----------------------------------
# | GXB connection point reconfig_clk
# | 
add_interface      reconfig_clk                           conduit end 
add_interface_port reconfig_clk reconfig_clk              export  Input 1

# +-----------------------------------
# | GXB connection point reconfig_busy
# | 
add_interface      reconfig_busy                           conduit end 
add_interface_port reconfig_busy reconfig_busy             export  Input 1

# +-----------------------------------
# | GXB connection point reconfig_write
# | 
add_interface      reconfig_write                          conduit end 
add_interface_port reconfig_write reconfig_write           export  Input 1

# +-----------------------------------
# | GXB connection point reconfig_done
# | 
add_interface      reconfig_done                           conduit end 
add_interface_port reconfig_done reconfig_done             export  Input 1

# +-----------------------------------
# | GXB connection point reconfig_togxb_m
# | 
add_interface      reconfig_togxb_m                        conduit end 
add_interface_port reconfig_togxb_m reconfig_togxb_m       export  Input 4

# +-----------------------------------
# | GXB connection point reconfig_togxb_s_tx
# | 
add_interface      reconfig_togxb_s_tx                     conduit end 
add_interface_port reconfig_togxb_s_tx reconfig_togxb_s_tx export  Input 4

# +-----------------------------------
# | GXB connection point reconfig_togxb_s_rx
# | 
add_interface      reconfig_togxb_s_rx                     conduit end 
add_interface_port reconfig_togxb_s_rx reconfig_togxb_s_rx export  Input 4

# +-----------------------------------
# | GXB connection point reconfig_fromgxb_m
# | 
add_interface reconfig_fromgxb_m                            conduit start 
#Port will be added in the my_elaboration_callback due to different bit width

# +-----------------------------------
# | GXB connection point reconfig_fromgxb_s_tx
# | 
add_interface reconfig_fromgxb_s_tx                         conduit start 
#Port will be added in the my_elaboration_callback due to different bit width

# +-----------------------------------
# | GXB connection point reconfig_fromgxb_s_rx
# | 
add_interface reconfig_fromgxb_s_rx                          conduit start 
#Port will be added in the my_elaboration_callback due to different bit width

# +-----------------------------------
# | GXB connection point pll_areset
# | For ATLPLL_RECONFIG
add_interface      pll_areset                                 conduit end 
add_interface_port pll_areset pll_areset                      export  Input 2

# +-----------------------------------
# | GXB connection point pll_configupdate
# | 
add_interface      pll_configupdate                           conduit end 
add_interface_port pll_configupdate pll_configupdate          export  Input 2

# +-----------------------------------
# | GXB connection point pll_scanclk
# | 
add_interface      pll_scanclk                                conduit end 
add_interface_port pll_scanclk pll_scanclk                    export  Input 2

# +-----------------------------------
# | GXB connection point pll_scanclkena
# | 
add_interface      pll_scanclkena                             conduit end 
add_interface_port pll_scanclkena pll_scanclkena              export  Input 2
   
# +-----------------------------------
# | GXB connection point pll_scandata
# |    
add_interface      pll_scandata                               conduit end 
add_interface_port pll_scandata pll_scandata                  export  Input 2
   
# +-----------------------------------
# | GXB connection point pll_reconfig_done
# | 
add_interface      pll_reconfig_done                          conduit start 
add_interface_port pll_reconfig_done pll_reconfig_done        export  Output 2
                                              
# +-----------------------------------
# | GXB connection point pll_scandataout
# | 
add_interface      pll_scandataout                            conduit start 
add_interface_port pll_scandataout pll_scandataout            export  Output 2     

# +-----------------------------------
# | connection point cpri_clkout
# | 
#add_interface cpri_clkout conduit start
add_interface      cpri_clkout                                clock  start
add_interface_port cpri_clkout cpri_clkout                    export Output 1

# +-----------------------------------
# | connection point pll_clkout
# | 
add_interface      pll_clkout                                 conduit start
add_interface_port pll_clkout pll_clkout                      export  Output 1

# +-----------------------------------
# | connection point reset
# | 
add_interface      reset                                      conduit end
add_interface_port reset reset                                export  Input 1

# +-----------------------------------
# | connection point reset_done
# | 
add_interface      reset_done                                 conduit start
add_interface_port reset_done reset_done                      export  Output 1

# +-----------------------------------
# | connection point config_reset
# | 
add_interface config_reset                                    conduit end
add_interface_port config_reset config_reset                  export  Input 1

# +-----------------------------------
# | connection point clk_reset_ex_delay
# | 
add_interface      clk_reset_ex_delay                         clock   end
add_interface_port clk_reset_ex_delay clk_ex_delay            clk     Input 1
add_interface_port clk_reset_ex_delay reset_ex_delay          reset   Input 1

# +-----------------------------------
# | connection point hw_reset_assert
# | 
add_interface      hw_reset_assert                            conduit end
add_interface_port hw_reset_assert hw_reset_assert            export  Input 1

# +-----------------------------------
# | connection point hw_reset_req
# | 
add_interface      hw_reset_req                               conduit start
add_interface_port hw_reset_req hw_reset_req                  export  Output 1

# +-----------------------------------
# | connection point cpri_rx_extended_status_data
# | 
add_interface          rx_extended_status_data avalon_streaming start
set_interface_property rx_extended_status_data dataBitsPerSymbol 12
set_interface_property rx_extended_status_data readyLatency 0
set_interface_property rx_extended_status_data symbolsPerBeat 1
set_interface_property rx_extended_status_data ASSOCIATED_CLOCK cpri_clkout
add_interface_port     rx_extended_status_data extended_rx_status_data data Output 12

# +-----------------------------------
# | connection point datarate_en
# | 
add_interface      datarate_en                                 conduit start
add_interface_port datarate_en datarate_en                     export  Output 1

# +-----------------------------------
# | connection point datarate_set
# | 
add_interface      datarate_set                                conduit start
add_interface_port datarate_set datarate_set                   export  Output 5

# +-----------------------------------
# | connection point cpu_clock_reset
# | 
add_interface          cpu_clock_reset clock end
set_interface_property cpu_clock_reset ENABLED true
add_interface_port     cpu_clock_reset cpu_reset reset Input 1
add_interface_port     cpu_clock_reset cpu_clk clk Input 1

# +-----------------------------------
# | connection point cpu_interface
# | 
add_interface          cpu_interface avalon end
set_interface_property cpu_interface addressAlignment DYNAMIC
set_interface_property cpu_interface bridgesToMaster ""
set_interface_property cpu_interface burstOnBurstBoundariesOnly false
set_interface_property cpu_interface holdTime 0
set_interface_property cpu_interface isMemoryDevice false
set_interface_property cpu_interface isNonVolatileStorage false
set_interface_property cpu_interface linewrapBursts false
set_interface_property cpu_interface maximumPendingReadTransactions 0
set_interface_property cpu_interface printableDevice false
set_interface_property cpu_interface readLatency 0
set_interface_property cpu_interface readWaitTime 1
set_interface_property cpu_interface setupTime 0
set_interface_property cpu_interface timingUnits Cycles
set_interface_property cpu_interface writeWaitTime 0
set_interface_property cpu_interface ASSOCIATED_CLOCK cpu_clock_reset
set_interface_property cpu_interface ENABLED true
add_interface_port     cpu_interface cpu_writedata writedata Input 32
add_interface_port     cpu_interface cpu_byteenable byteenable Input 4
add_interface_port     cpu_interface cpu_read read Input 1
add_interface_port     cpu_interface cpu_write write Input 1
add_interface_port     cpu_interface cpu_readdata readdata Output 32
add_interface_port     cpu_interface cpu_address address Input 14
add_interface_port     cpu_interface cpu_waitrequest waitrequest Output 1

# # +-----------------------------------
# # | Interrupts
# # | 
#set interrupts {irq_cpri irq_eth_rx irq_eth_tx irq_hdlc_rx irq_hdlc_tx }
#add_interface          cpu_interrupt interrupt end
#set_interface_property cpu_interrupt associatedAddressablePoint cpu_interface
#set_interface_property cpu_interrupt ASSOCIATED_CLOCK cpri_clkout
#add_interface_port     cpu_interrupt cpu_irq irq Output 1

add_interface       cpu_interrupt conduit start
add_interface_port  cpu_interrupt cpu_irq export Output 1
## +------------------------
## + Interrupt vector
## 
add_interface          cpu_irq_vector avalon_streaming start
set_interface_property cpu_irq_vector dataBitsPerSymbol 5
set_interface_property cpu_irq_vector readyLatency 0
set_interface_property cpu_irq_vector symbolsPerBeat 1
set_interface_property cpu_irq_vector ASSOCIATED_CLOCK cpri_clkout
add_interface_port     cpu_irq_vector cpu_irq_vector data Output 5

# +-----------------------------------
# | connection point cpri_rx_aux_data and status data
# | CPRI AUX and Synchronization Receiver Interface
# | 
add_interface          rx_aux_status avalon_streaming start
set_interface_property rx_aux_status dataBitsPerSymbol 76
set_interface_property rx_aux_status readyLatency 0
set_interface_property rx_aux_status symbolsPerBeat 1
set_interface_property rx_aux_status ASSOCIATED_CLOCK cpri_clkout
set_interface_property rx_aux_status ENABLED true
add_interface_port     rx_aux_status aux_rx_status_data data Output 76

# +----------------------------------------
# | CPRI AUX and Synchronization Transceiver Interface
# | connection point cpri_tx_status_data
# | 
add_interface          tx_aux_status avalon_streaming start
set_interface_property tx_aux_status dataBitsPerSymbol 44
set_interface_property tx_aux_status readyLatency 0
set_interface_property tx_aux_status symbolsPerBeat 1
set_interface_property tx_aux_status ASSOCIATED_CLOCK cpri_clkout
set_interface_property tx_aux_status ENABLED true
add_interface_port     tx_aux_status aux_tx_status_data data Output 44

# +-----------------------------------
# | connection point cpri_tx_aux_data
# | 
add_interface          tx_aux avalon_streaming end
set_interface_property tx_aux dataBitsPerSymbol 65
set_interface_property tx_aux readyLatency 0
set_interface_property tx_aux symbolsPerBeat 1
set_interface_property tx_aux ASSOCIATED_CLOCK cpri_clkout
add_interface_port     tx_aux aux_tx_mask_data data input 65

# +-----------------------------------
# | MII Interface
# | 
add_interface      cpri_mii_txclk                conduit start
add_interface_port cpri_mii_txclk cpri_mii_txclk export  Output 1

add_interface      cpri_mii_txen                 conduit end
add_interface_port cpri_mii_txen cpri_mii_txen   export  Input  1

add_interface      cpri_mii_txer                 conduit end
add_interface_port cpri_mii_txer cpri_mii_txer   export  Input  1

add_interface      cpri_mii_txd                  conduit end
add_interface_port cpri_mii_txd cpri_mii_txd     export  Input  4

add_interface      cpri_mii_txrd                 conduit start
add_interface_port cpri_mii_txrd cpri_mii_txrd   export  Output 1

add_interface      cpri_mii_rxclk                conduit start
add_interface_port cpri_mii_rxclk cpri_mii_rxclk export  Output 1

add_interface      cpri_mii_rxwr                 conduit start
add_interface_port cpri_mii_rxwr cpri_mii_rxwr   export  Output 1

add_interface      cpri_mii_rxdv                 conduit start
add_interface_port cpri_mii_rxdv cpri_mii_rxdv   export  Output 1

add_interface      cpri_mii_rxer                 conduit start
add_interface_port cpri_mii_rxer cpri_mii_rxer   export  Output 1

add_interface      cpri_mii_rxd                  conduit start
add_interface_port cpri_mii_rxd cpri_mii_rxd     export  Output 4

# +-----------------------------------
# | connection point: IQ Mapping RX Interface

for {set i 0} {$i < 24} {incr i} {
	# +-----------------------------------
	# | connection point map_rx_clk
	# | 
	add_interface      map${i}_rx_clk clock end
	add_interface_port map${i}_rx_clk map${i}_rx_reset reset Input 1
	add_interface_port map${i}_rx_clk map${i}_rx_clk   clk Input 1
	# +-----------------------------------
	# | connection point cpri_map_rx
	# | 
	add_interface          map${i}_rx avalon_streaming start
	set_interface_property map${i}_rx dataBitsPerSymbol 16
	set_interface_property map${i}_rx readyLatency 0
	set_interface_property map${i}_rx symbolsPerBeat 2
	add_interface_port     map${i}_rx map${i}_rx_valid valid Output 1
	add_interface_port     map${i}_rx map${i}_rx_data data Output 32
	add_interface_port     map${i}_rx map${i}_rx_ready ready Input 1
	
	# +-----------------------------------
	# | connection point cpri_map_rx_status
	# | 
	add_interface          map${i}_rx_status avalon_streaming start
	set_interface_property map${i}_rx_status dataBitsPerSymbol 3
	set_interface_property map${i}_rx_status readyLatency 0
	set_interface_property map${i}_rx_status symbolsPerBeat 1
	add_interface_port     map${i}_rx_status map${i}_rx_status_data data Output 3
	
	# +------------------------------------
	# | cpri_map_rx_resync

	add_interface          map${i}_rx_resync avalon_streaming end
	set_interface_property map${i}_rx_resync dataBitsPerSymbol 1
	set_interface_property map${i}_rx_resync readyLatency 0
	set_interface_property map${i}_rx_resync symbolsPerBeat 1
	add_interface_port     map${i}_rx_resync map${i}_rx_resync data input 1
}

# +-----------------------------------
# | connection point: IQ Mapping TX Interface
# | 
for {set i 0} {$i < 24} {incr i} {
	# +-----------------------------------
	# | connection point map_tx_clk
	# | 
	 add_interface      map${i}_tx_clk clock end
    add_interface_port map${i}_tx_clk map${i}_tx_clk   clk Input 1
    add_interface_port map${i}_tx_clk map${i}_tx_reset reset Input 1
   #add_interface      map${i}_tx_reset reset end
	#add_interface_port map${i}_tx_reset map${i}_tx_reset reset Input 1
	#set_interface_property map${i}_tx_reset ASSOCIATED_CLOCK map${i}_tx_clk
	# +-----------------------------------
	# | connection point cpri_map_tx
	# | 
	add_interface          map${i}_tx avalon_streaming end
	set_interface_property map${i}_tx dataBitsPerSymbol 16
	set_interface_property map${i}_tx readyLatency 0
	set_interface_property map${i}_tx symbolsPerBeat 2	
	add_interface_port     map${i}_tx map${i}_tx_valid valid Input 1
	add_interface_port     map${i}_tx map${i}_tx_data data Input 32
	add_interface_port     map${i}_tx map${i}_tx_ready ready Output 1
	
	# +-----------------------------------
	# | connection point cpri_map_tx_status
	# | 
	add_interface          map${i}_tx_status avalon_streaming start
	set_interface_property map${i}_tx_status dataBitsPerSymbol 3
	set_interface_property map${i}_tx_status readyLatency 0
	set_interface_property map${i}_tx_status symbolsPerBeat 1
 	add_interface_port     map${i}_tx_status map${i}_tx_status_data data Output 3
	
	# +------------------------------------
	# | cpri_map_tx_resync
	add_interface          map${i}_tx_resync avalon_streaming end
	set_interface_property map${i}_tx_resync dataBitsPerSymbol 1
	set_interface_property map${i}_tx_resync readyLatency 0
	set_interface_property map${i}_tx_resync symbolsPerBeat 1
    add_interface_port     map${i}_tx_resync map${i}_tx_resync data input 1

   # +------------------------------------
   # | cpri_map_rx_start
   add_interface          map${i}_rx_start avalon_streaming start
   set_interface_property map${i}_rx_start dataBitsPerSymbol 1
   set_interface_property map${i}_rx_start readyLatency 0
   set_interface_property map${i}_rx_start symbolsPerBeat 1
   add_interface_port     map${i}_rx_start map${i}_rx_start data output 1
 
}

# +--------------------------------
# | altera_xcvr_det_latency
# |Interface and ports declaration
# |
add_interface          phy_mgmt_clk       clock                output
add_interface_port     phy_mgmt_clk       phy_mgmt_clk     clk output 1

add_interface          phy_pll_ref_clk    clock                output
add_interface_port     phy_pll_ref_clk    phy_pll_ref_clk  clk output 1

add_interface          phy_pll_inclk      clock                output
add_interface_port     phy_pll_inclk      phy_pll_inclk    clk output 1
set_interface_property phy_pll_inclk      ENABLED false

add_interface          phy_mgmt_clk_reset reset                output
add_interface_port     phy_mgmt_clk_reset phy_mgmt_clk_reset   reset output 1
set_interface_property phy_mgmt_clk_reset ASSOCIATED_CLOCK     phy_mgmt_clk

add_interface          phy_mgmt_interface avalon start
add_interface_port     phy_mgmt_interface phy_mgmt_address     address     Output 12
add_interface_port     phy_mgmt_interface phy_mgmt_read        read        Output 1
add_interface_port     phy_mgmt_interface phy_mgmt_readdata    readdata    Input  32
add_interface_port     phy_mgmt_interface phy_mgmt_waitrequest waitrequest Input  1
add_interface_port     phy_mgmt_interface phy_mgmt_write       write       Output 1
add_interface_port     phy_mgmt_interface phy_mgmt_writedata   writedata   Output 32
set_interface_property phy_mgmt_interface ASSOCIATED_CLOCK     phy_mgmt_clk

add_interface          phy_tx_ready                                                    conduit  end
add_interface_port     phy_tx_ready                    phy_tx_ready                    export   Input 1

add_interface          phy_rx_ready                                                    conduit  end
add_interface_port     phy_rx_ready                    phy_rx_ready                    export   Input 1

add_interface          phy_tx_serial_data                                              conduit  end
add_interface_port     phy_tx_serial_data              phy_tx_serial_data              export   Input 1

add_interface          phy_pll_locked                                                  conduit  end
add_interface_port     phy_pll_locked                  phy_pll_locked                  export   Input 1

add_interface          phy_rx_serial_data                                              conduit  start
add_interface_port     phy_rx_serial_data              phy_rx_serial_data              export   Output 1

add_interface          phy_tx_clkout                                                   conduit  end
add_interface_port     phy_tx_clkout                   phy_tx_clkout                   export   Input 1

add_interface          phy_rx_clkout                                                   conduit  end
add_interface_port     phy_rx_clkout                   phy_rx_clkout                   export   Input 1

add_interface          phy_rx_is_lockedtoref                                           conduit  end 
add_interface_port     phy_rx_is_lockedtoref           phy_rx_is_lockedtoref           export   Input 1
 
add_interface          phy_rx_is_lockedtodata                                          conduit  end
add_interface_port     phy_rx_is_lockedtodata          phy_rx_is_lockedtodata          export   Input 1

add_interface          phy_rx_bitslipboundaryselectout                                 conduit end
add_interface_port     phy_rx_bitslipboundaryselectout phy_rx_bitslipboundaryselectout export  Input 5

add_interface          phy_tx_bitslipboundaryselect                                    conduit start
add_interface_port     phy_tx_bitslipboundaryselect    phy_tx_bitslipboundaryselect    export  Output 5

add_interface          phy_tx_parallel_data                            conduit  start
add_interface          phy_rx_parallel_data                            conduit  end

# +-------------------------------
# | Specially for AV GT
# |-------------------------------
add_interface          usr_clk                                   clock  end
add_interface_port     usr_clk             usr_clk               export Input 1

add_interface          usr_pma_clk                               clock  end
add_interface_port     usr_pma_clk         usr_pma_clk           export Input 1

add_interface          xcvr_usr_clk        clock                 output
add_interface_port     xcvr_usr_clk        xcvr_usr_clk          clk output 1

add_interface          xcvr_usr_pma_clk    clock                 output
add_interface_port     xcvr_usr_pma_clk    xcvr_usr_pma_clk      clk output 1

add_interface          xcvr_mgmt_clk       clock                 output 
add_interface_port     xcvr_mgmt_clk       xcvr_mgmt_clk         clk output 1

add_interface          xcvr_pll_ref_clk    clock                 output
add_interface_port     xcvr_pll_ref_clk    xcvr_pll_ref_clk      clk output 1

add_interface          xcvr_mgmt_clk_reset reset                output
add_interface_port     xcvr_mgmt_clk_reset xcvr_mgmt_clk_reset  reset output 1
set_interface_property xcvr_mgmt_clk_reset ASSOCIATED_CLOCK     xcvr_mgmt_clk

add_interface          xcvr_mgmt_interface avalon start
add_interface_port     xcvr_mgmt_interface xcvr_mgmt_address     address     Output 12
add_interface_port     xcvr_mgmt_interface xcvr_mgmt_read        read        Output 1
add_interface_port     xcvr_mgmt_interface xcvr_mgmt_readdata    readdata    Input  32
add_interface_port     xcvr_mgmt_interface xcvr_mgmt_waitrequest waitrequest Input  1
add_interface_port     xcvr_mgmt_interface xcvr_mgmt_write       write       Output 1
add_interface_port     xcvr_mgmt_interface xcvr_mgmt_writedata   writedata   Output 32
set_interface_property xcvr_mgmt_interface ASSOCIATED_CLOCK     xcvr_mgmt_clk

add_interface          xcvr_tx_ready                                                     conduit  end
add_interface_port     xcvr_tx_ready                    xcvr_tx_ready                    export   Input 1

add_interface          xcvr_rx_ready                                                     conduit  end
add_interface_port     xcvr_rx_ready                    xcvr_rx_ready                     export   Input 1

add_interface          xcvr_tx_serial_data                                               conduit  end
add_interface_port     xcvr_tx_serial_data              xcvr_tx_serial_data              export   Input 1

add_interface          xcvr_pll_locked                                                   conduit  end
add_interface_port     xcvr_pll_locked                  xcvr_pll_locked                  export   Input 1

add_interface          xcvr_rx_serial_data                                               conduit  start
add_interface_port     xcvr_rx_serial_data              xcvr_rx_serial_data              export   Output 1

# txclkout is not used for 9.8G AVGT
#add_interface          xcvr_tx_clkout                                                   conduit  end
#add_interface_port     xcvr_tx_clkout                   xcvr_tx_clkout                  export   Input 1

add_interface          xcvr_rx_clkout                                                    conduit  end
add_interface_port     xcvr_rx_clkout                   xcvr_rx_clkout                   export   Input 1

add_interface          xcvr_rx_is_lockedtoref                                            conduit  end 
add_interface_port     xcvr_rx_is_lockedtoref           xcvr_rx_is_lockedtoref           export   Input 1
 
add_interface          xcvr_rx_is_lockedtodata                                           conduit  end
add_interface_port     xcvr_rx_is_lockedtodata          xcvr_rx_is_lockedtodata          export   Input 1

add_interface          xcvr_rx_bitslipboundaryselectout                                  conduit  end
add_interface_port     xcvr_rx_bitslipboundaryselectout xcvr_rx_bitslipboundaryselectout export   Input 7

add_interface          xcvr_tx_bitslipboundaryselect                                     conduit  start
add_interface_port     xcvr_tx_bitslipboundaryselect    xcvr_tx_bitslipboundaryselect    export   Output 7

add_interface          xcvr_tx_parallel_data                                             conduit  start
add_interface_port     xcvr_tx_parallel_data            xcvr_tx_parallel_data            export   Output 32

add_interface          xcvr_rx_parallel_data                                             conduit  end
add_interface_port     xcvr_rx_parallel_data            xcvr_rx_parallel_data            export   Input  32

add_interface          xcvr_cdr_ref_clk                                                  clock    Output   
add_interface_port     xcvr_cdr_ref_clk                 xcvr_cdr_ref_clk                 clk      Output 1

add_interface          xcvr_fifo_calc_clk                                                clock    Output   
add_interface_port     xcvr_fifo_calc_clk               xcvr_fifo_calc_clk               clk      Output 1

add_interface         xcvr_tx_fifocalreset                                               conduit  start
add_interface_port    xcvr_tx_fifocalreset              xcvr_tx_fifocalreset             export   Output 1  

add_interface         xcvr_rx_fifocalreset                                               conduit  start
add_interface_port    xcvr_rx_fifocalreset              xcvr_rx_fifocalreset             export   Output 1  

add_interface         xcvr_rx_clkout                                                     conduit  end 
add_interface_port    xcvr_rx_clkout                   xcvr_rx_clkout                    export   Input 1                           

add_interface         xcvr_tx_datak                                                      conduit  start
add_interface_port    xcvr_tx_datak                    xcvr_tx_datak                     export   Output 4

add_interface         xcvr_rx_datak                                                      conduit  end
add_interface_port    xcvr_rx_datak                    xcvr_rx_datak                     export   Input 4

add_interface         xcvr_rx_disperr                                                    conduit  end
add_interface_port    xcvr_rx_disperr                  xcvr_rx_disperr                   export   Input 4

add_interface        xcvr_rx_errdetect                                                   conduit  end
add_interface_port   xcvr_rx_errdetect                 xcvr_rx_errdetect                 export Input 4

add_interface         xcvr_rx_syncstatus                                                 conduit  end
add_interface_port    xcvr_rx_syncstatus               xcvr_rx_syncstatus                export   Input 4

add_interface       xcvr_tx_fifo_sample_size                                             conduit start
add_interface_port  xcvr_tx_fifo_sample_size          xcvr_tx_fifo_sample_size           export Output 8

add_interface       xcvr_rx_fifo_sample_size                                             conduit start
add_interface_port  xcvr_rx_fifo_sample_size          xcvr_rx_fifo_sample_size           export Output 8

add_interface       xcvr_tx_phase_measure_acc                                            conduit end
add_interface_port  xcvr_tx_phase_measure_acc         xcvr_tx_phase_measure_acc          export Input 32

add_interface       xcvr_rx_phase_measure_acc                                            conduit end
add_interface_port  xcvr_rx_phase_measure_acc         xcvr_rx_phase_measure_acc          export Input 32

add_interface       xcvr_tx_fifo_latency                                                 conduit end
add_interface_port  xcvr_tx_fifo_latency              xcvr_tx_fifo_latency               export Input 5

add_interface       xcvr_rx_fifo_latency                                                 conduit end
# Due to the width is affected by the WIDTH_RX_BUF, the width of the xcvr_rx_fifo_latency will be determined at the elaboration call back.

add_interface      xcvr_tx_ph_acc_valid                                                  conduit end
add_interface_port xcvr_tx_ph_acc_valid               xcvr_tx_ph_acc_valid               export Input 1  

add_interface      xcvr_rx_ph_acc_valid                                                  conduit end
add_interface_port xcvr_rx_ph_acc_valid               xcvr_rx_ph_acc_valid               export Input 1  

add_interface      xcvr_tx_wr_full                                                       conduit end
add_interface_port xcvr_tx_wr_full                    xcvr_tx_wr_full                    export Input 1

add_interface      xcvr_rx_wr_full                                                       conduit end
add_interface_port xcvr_rx_wr_full                    xcvr_rx_wr_full                    export Input 1

add_interface      xcvr_tx_rd_empty                                                      conduit end
add_interface_port xcvr_tx_rd_empty                   xcvr_tx_rd_empty                   export Input 1

add_interface      xcvr_rx_rd_empty                                                      conduit end
add_interface_port xcvr_rx_rd_empty                   xcvr_rx_rd_empty                   export Input 1

add_interface      xcvr_tx_fiforeset                                                     conduit start
add_interface_port xcvr_tx_fiforeset                  xcvr_tx_fiforeset                  export  Output 1

add_interface      xcvr_rx_fiforeset                                                     conduit start
add_interface_port xcvr_rx_fiforeset                  xcvr_rx_fiforeset                  export Output 1

add_interface      xcvr_rx_data_width_pma                                                conduit start
add_interface_port xcvr_rx_data_width_pma             xcvr_rx_data_width_pma             export Output 7

add_interface      xcvr_tx_data_width_pma                                                conduit start
add_interface_port xcvr_tx_data_width_pma             xcvr_tx_data_width_pma             export Output 7

# +---------------------------------------------------------------------------------------
# | Procedures 
# | 1. phy_interface_off : Used to disable all the phy interface
# | 2. phy_generic       : Used to enable the phy interface that require parameter passing
# | 3. civ_interface_off : Used to disable all the Cyclone IV reconfiguration interface
# | 4. xcvr_interface_off: Used to disable the AVGT phy management interface 

proc phy_interface_off {} {
   set_interface_property phy_mgmt_clk                    ENABLED false
   set_interface_property phy_mgmt_interface              ENABLED false
   set_interface_property phy_pll_ref_clk                 ENABLED false
   set_interface_property phy_pll_locked                  ENABLED false
   set_interface_property phy_tx_ready                    ENABLED false
   set_interface_property phy_tx_serial_data              ENABLED false
   set_interface_property phy_tx_clkout                   ENABLED false
   set_interface_property phy_tx_parallel_data            ENABLED false
   set_interface_property phy_tx_bitslipboundaryselect    ENABLED false
   set_interface_property phy_rx_serial_data              ENABLED false
   set_interface_property phy_rx_clkout                   ENABLED false
   set_interface_property phy_rx_parallel_data            ENABLED false
   set_interface_property phy_rx_ready                    ENABLED false
   set_interface_property phy_rx_is_lockedtodata          ENABLED false
   set_interface_property phy_rx_is_lockedtoref           ENABLED false
   set_interface_property phy_rx_bitslipboundaryselectout ENABLED false
}

proc phy_generic {} {
   add_interface_port phy_tx_parallel_data phy_tx_parallel_data export Output 44
   add_interface_port phy_rx_parallel_data phy_rx_parallel_data export Input  64
 }

proc civ_interface_off {} {
   set_parameter_property S_CH_NUMBER_M         enabled false
   set_parameter_property S_CH_NUMBER_S_TX      enabled false
   set_parameter_property S_CH_NUMBER_S_RX      enabled false
   set_interface_property reconfig_togxb_m      enabled false 
   set_interface_property reconfig_togxb_s_tx   enabled false 
   set_interface_property reconfig_togxb_s_rx   enabled false 
   set_interface_property reconfig_fromgxb_m    enabled false 
   set_interface_property reconfig_fromgxb_s_tx enabled false 
   set_interface_property reconfig_fromgxb_s_rx enabled false
   set_interface_property pll_areset            enabled false
   set_interface_property pll_configupdate      enabled false  
   set_interface_property pll_scanclk           enabled false
   set_interface_property pll_scanclkena        enabled false
   set_interface_property pll_scandata          enabled false
   set_interface_property pll_reconfig_done     enabled false
   set_interface_property pll_scandataout       enabled false 
   set_interface_property reconfig_busy         enabled false 
   set_interface_property reconfig_write        enabled false 
   set_interface_property reconfig_done         enabled false 
   set_interface_property gxb_cal_blk_clk       enabled false
   set_interface_property gxb_powerdown         enabled false
}

proc xcvr_interface_off {} {
   set_interface_property usr_clk                            ENABLED                   false
   set_interface_property usr_pma_clk                        ENABLED                   false
   set_interface_property xcvr_usr_clk                       ENABLED                   false
   set_interface_property xcvr_usr_pma_clk                   ENABLED                   false
   set_interface_property xcvr_mgmt_clk                      ENABLED                   false
   set_interface_property xcvr_pll_ref_clk                   ENABLED                   false
   set_interface_property xcvr_mgmt_clk_reset                ENABLED                   false
   set_interface_property xcvr_mgmt_interface                ENABLED                   false
   set_interface_property xcvr_tx_ready                      ENABLED                   false
   set_interface_property xcvr_rx_ready                      ENABLED                   false
   set_interface_property xcvr_tx_serial_data                ENABLED                   false
   set_interface_property xcvr_pll_locked                    ENABLED                   false
   set_interface_property xcvr_rx_serial_data                ENABLED                   false
   set_interface_property xcvr_rx_clkout                     ENABLED                   false
   set_interface_property xcvr_rx_bitslipboundaryselectout   ENABLED                   false
   set_interface_property xcvr_tx_bitslipboundaryselect      ENABLED                   false
   set_interface_property xcvr_tx_parallel_data              ENABLED                   false
   set_interface_property xcvr_rx_parallel_data              ENABLED                   false
   set_interface_property xcvr_cdr_ref_clk                   ENABLED                   false
   set_interface_property xcvr_fifo_calc_clk                 ENABLED                   false
   set_interface_property xcvr_tx_fifocalreset               ENABLED                   false
   set_interface_property xcvr_rx_fifocalreset               ENABLED                   false
   set_interface_property xcvr_rx_clkout                     ENABLED                   false
   set_interface_property xcvr_tx_datak                      ENABLED                   false
   set_interface_property xcvr_rx_datak                      ENABLED                   false
   set_interface_property xcvr_rx_disperr                    ENABLED                   false
   set_interface_property xcvr_rx_errdetect                  ENABLED                   false
   set_interface_property xcvr_rx_syncstatus                 ENABLED                   false
   set_interface_property xcvr_tx_fifo_sample_size           ENABLED                   false
   set_interface_property xcvr_rx_fifo_sample_size           ENABLED                   false
   set_interface_property xcvr_tx_phase_measure_acc          ENABLED                   false
   set_interface_property xcvr_rx_phase_measure_acc          ENABLED                   false
   set_interface_property xcvr_tx_fifo_latency               ENABLED                   false
   set_interface_property xcvr_rx_fifo_latency               ENABLED                   false 
   set_interface_property xcvr_tx_ph_acc_valid               ENABLED                   false
   set_interface_property xcvr_rx_ph_acc_valid               ENABLED                   false
   set_interface_property xcvr_tx_wr_full                    ENABLED                   false
   set_interface_property xcvr_rx_wr_full                    ENABLED                   false
   set_interface_property xcvr_tx_rd_empty                   ENABLED                   false
   set_interface_property xcvr_rx_rd_empty                   ENABLED                   false
   set_interface_property xcvr_tx_fiforeset                  ENABLED                   false
   set_interface_property xcvr_rx_fiforeset                  ENABLED                   false
   set_interface_property xcvr_rx_data_width_pma             ENABLED                   false
   set_interface_property xcvr_tx_data_width_pma             ENABLED                   false
   set_interface_property xcvr_rx_is_lockedtodata            ENABLED                   false
   set_interface_property xcvr_rx_is_lockedtoref             ENABLED                   false
}


proc my_elaboration_callback {} {
set mode       [get_parameter_value SYNC_MODE]
set n          [get_parameter_value N_MAP]
set mac__off   [get_parameter_value MACOFF]
set device     [get_parameter_value DEVICEFAMILY]
set autorate   [get_parameter_value AUTORATE]
set linerate   [get_parameter_value LINERATE]
set syncmap    [get_parameter_value SYNC_MAP]
set widthrxbuf [get_parameter_value WIDTH_RX_BUF]

if { $device == "Arria V"} {
  if {$linerate == 5} {
     add_interface_port  xcvr_rx_fifo_latency              xcvr_rx_fifo_latency               export Input $widthrxbuf+1
  }
}

if {$device == "Arria V" || $device == "Stratix V" || $device == "Cyclone V" || $device == "Arria V GZ"} {
   # INFO:
   # Reconfiguration interface for Cyclone IV should not be exposed
   civ_interface_off
} elseif {$device == "Cyclone IV GX"} then {
   add_interface_port     reconfig_fromgxb_m    reconfig_fromgxb_m    export Output 5
   add_interface_port     reconfig_fromgxb_s_tx reconfig_fromgxb_s_tx export Output 5
   add_interface_port     reconfig_fromgxb_s_rx reconfig_fromgxb_s_rx export Output 5
   
   if {$mode == "0"} then {
      set_parameter_property S_CH_NUMBER_M         enabled true
      set_parameter_property S_CH_NUMBER_S_TX      enabled false
      set_parameter_property S_CH_NUMBER_S_RX      enabled false
      
	   set_interface_property reconfig_togxb_s_tx   enabled false 
	   set_interface_property reconfig_togxb_s_rx   enabled false 
	   set_interface_property reconfig_fromgxb_s_tx enabled false 
	   set_interface_property reconfig_fromgxb_s_rx enabled false 
   } else {
      set_parameter_property S_CH_NUMBER_M         enabled false
      set_parameter_property S_CH_NUMBER_S_TX      enabled true
      set_parameter_property S_CH_NUMBER_S_RX      enabled true
	  
      set_interface_property reconfig_togxb_m      enabled false 
	   set_interface_property reconfig_fromgxb_m    enabled false 
   }

   if { $autorate== 0} then {
     set_interface_property pll_areset            enabled false 
	  set_interface_property pll_configupdate      enabled false  
	  set_interface_property pll_scanclk           enabled false
	  set_interface_property pll_scanclkena        enabled false
	  set_interface_property pll_scandata          enabled false
	  set_interface_property pll_reconfig_done     enabled false
	  set_interface_property pll_scandataout       enabled false
  }

} else {
     # For Stratix IV, Arria II GX/GZ
     add_interface_port     reconfig_fromgxb_m    reconfig_fromgxb_m    export Output 17
     add_interface_port     reconfig_fromgxb_s_tx reconfig_fromgxb_s_tx export Output 17
     add_interface_port     reconfig_fromgxb_s_rx reconfig_fromgxb_s_rx export Output 17  
     
     set_interface_property pll_areset            enabled false
     set_interface_property pll_configupdate      enabled false  
     set_interface_property pll_scanclk           enabled false
     set_interface_property pll_scanclkena        enabled false
     set_interface_property pll_scandata          enabled false
     set_interface_property pll_reconfig_done     enabled false
     set_interface_property pll_scandataout       enabled false 

   if {$mode == "0"} then {
      set_parameter_property S_CH_NUMBER_M         enabled true
      set_parameter_property S_CH_NUMBER_S_TX      enabled false
      set_parameter_property S_CH_NUMBER_S_RX      enabled false
         
		set_interface_property reconfig_togxb_s_tx   enabled false 
		set_interface_property reconfig_togxb_s_rx   enabled false  
		set_interface_property reconfig_fromgxb_s_tx enabled false 
		set_interface_property reconfig_fromgxb_s_rx enabled false 
   } else {
      set_parameter_property S_CH_NUMBER_M         enabled false
      set_parameter_property S_CH_NUMBER_S_TX      enabled true
      set_parameter_property S_CH_NUMBER_S_RX      enabled true
        
		set_interface_property reconfig_togxb_m      enabled false 
		set_interface_property reconfig_fromgxb_m    enabled false 
   }
}  

if {$mac__off == "true"} {
   set_interface_property cpri_mii_txclk enabled false
   set_interface_property cpri_mii_txrd  enabled false
   set_interface_property cpri_mii_txen  enabled false
   set_interface_property cpri_mii_txer  enabled false
   set_interface_property cpri_mii_txd   enabled false
   set_interface_property cpri_mii_rxclk enabled false
   set_interface_property cpri_mii_rxwr  enabled false
   set_interface_property cpri_mii_rxdv  enabled false
   set_interface_property cpri_mii_rxer  enabled false
   set_interface_property cpri_mii_rxd   enabled false
}                  

if { $device == "Arria V"} {
   if {$linerate == 5} {
      phy_interface_off
   } else {
      phy_generic
      xcvr_interface_off  
      if { $mode == "1" } {
         set_interface_property phy_pll_inclk ENABLED true
      }
   } 
} elseif { $device == "Stratix V"  || $device == "Cyclone V" || $device == "Arria V GZ"} {  
   # Slave will require the phy_pll_inclk port
   if { $mode == "1" } {
      set_interface_property phy_pll_inclk ENABLED true      
   }
   phy_generic
   xcvr_interface_off 
   # INFO :
   # By default it is TRUE, thus it is not necessary to set_interface_property here
   } else {
      phy_interface_off
      xcvr_interface_off  
   }
   
   if { $n == "0" } {
      set_parameter_property SYNC_MAP ENABLED false
   } else {
      set_parameter_property SYNC_MAP ENABLED true
   } 
     
	for {set i 0} {$i < 24} {incr i} {
		if {$i < $n} {
			if { $syncmap == "1" } {
            set_interface_property map${i}_rx        ASSOCIATED_CLOCK cpri_clkout
				set_interface_property map${i}_rx_status ASSOCIATED_CLOCK cpri_clkout
				set_interface_property map${i}_tx        ASSOCIATED_CLOCK cpri_clkout
				set_interface_property map${i}_tx_status ASSOCIATED_CLOCK cpri_clkout
            set_interface_property map${i}_rx_start  ASSOCIATED_CLOCK cpri_clkout
            set_interface_property map${i}_rx_clk enabled false
				set_interface_property map${i}_tx_clk enabled false
			} elseif { $syncmap == "0" } {
				set_interface_property map${i}_rx        ASSOCIATED_CLOCK map${i}_rx_clk
				set_interface_property map${i}_rx_resync ASSOCIATED_CLOCK map${i}_rx_clk
				set_interface_property map${i}_rx_status ASSOCIATED_CLOCK map${i}_rx_clk
				set_interface_property map${i}_tx        ASSOCIATED_CLOCK map${i}_tx_clk
				set_interface_property map${i}_tx_resync ASSOCIATED_CLOCK map${i}_tx_clk
				set_interface_property map${i}_tx_status ASSOCIATED_CLOCK map${i}_tx_clk
            set_interface_property map${i}_rx_start enabled false
         }
      } else {
         set_interface_property map${i}_rx        enabled false
			set_interface_property map${i}_rx_clk    enabled false
			set_interface_property map${i}_rx_status enabled false
			set_interface_property map${i}_tx        enabled false
			set_interface_property map${i}_tx_clk    enabled false
			set_interface_property map${i}_tx_status enabled false
			set_interface_property map${i}_tx_resync enabled false
			set_interface_property map${i}_rx_resync enabled false
         set_interface_property map${i}_rx_start  enabled false
      }
   }
}

proc my_validation_callback {} {
   set device                 [get_parameter_value DEVICEFAMILY]
   set autorate               [get_parameter_value AUTORATE]
   set linerate               [get_parameter_value LINERATE]
   set mac___off              [get_parameter_value MACOFF]
   set hdlc___off             [get_parameter_value HDLCOFF]
   set vss___off              [get_parameter_value VSSOFF]
   set cal___off              [get_parameter_value CALOFF] 
   set S_CH_NUMBER_S_TX_value [get_parameter_value S_CH_NUMBER_S_TX]
   set S_CH_NUMBER_S_RX_value [get_parameter_value S_CH_NUMBER_S_RX]
   set widthrxbuf             [get_parameter_value WIDTH_RX_BUF]
   set mode                   [get_parameter_value SYNC_MODE]

   # INFO:
   # Supported linerate for all the supported family
   set aii_siv_freq  {614:0.6144 0:1.2288 1:2.4576 2:3.0720 3:4.9152 4:6.1440}
   set civ_freq      {614:0.6144 0:1.2288 1:2.4576 2:3.0720}
   set av_sv_freq    {614:0.6144 0:1.2288 1:2.4576 2:3.0720 3:4.9152 4:6.1440 5:9.8304}
   set cv_freq       {614:0.6144 0:1.2288 1:2.4576 2:3.0720}

   # Derived MAC_OFF parameter from mac__off  
   if {$mac___off == "false"} {
      set_parameter_value MAC_OFF 1
   } else {
      set_parameter_value MAC_OFF 0
	}
   
    # Derived HDLC_OFF parameter from hdlc___off  
   if {$hdlc___off == "false"} {
      set_parameter_value HDLC_OFF 1
   } else {
      set_parameter_value HDLC_OFF 0
	}

    # Derived VSS_OFF parameter from vss___off  
   if {$vss___off == "false"} {
      set_parameter_value VSS_OFF 1
   } else {
      set_parameter_value VSS_OFF 0
	}

   # Derived CAL_OFF parameter from cal___off  
   if {$cal___off == "false"} {
      set_parameter_value CAL_OFF 1
   } else {
      set_parameter_value CAL_OFF 0
	}

	send_message info "$device is selected."
    # Derived DEVICE parameter from device
	if { $device == "Stratix IV"} {
		set_parameter_value DEVICE 0
      set_parameter_property LINERATE ALLOWED_RANGES $aii_siv_freq
	} elseif { $device == "Arria II GX"} {
		set_parameter_value DEVICE 1
      set_parameter_property LINERATE ALLOWED_RANGES $aii_siv_freq
	} elseif { $device == "Arria II GZ"} {
		set_parameter_value DEVICE 2
      set_parameter_property LINERATE ALLOWED_RANGES $aii_siv_freq
	} elseif { $device == "HardCopy IV"} {
		set_parameter_value DEVICE 0
      set_parameter_property LINERATE ALLOWED_RANGES $aii_siv_freq
	} elseif { $device == "Cyclone IV GX"} { 
      set_parameter_value DEVICE 3
      set_parameter_property LINERATE ALLOWED_RANGES $civ_freq
    } elseif { $device == "Stratix V"} {
      set_parameter_value DEVICE 4
      set_parameter_property LINERATE ALLOWED_RANGES $av_sv_freq
    } elseif { $device == "Arria V"} {
      set_parameter_value DEVICE 5
      set_parameter_property LINERATE ALLOWED_RANGES $av_sv_freq
    } elseif { $device == "Cyclone V"} {
      set_parameter_value DEVICE 6
      set_parameter_property LINERATE ALLOWED_RANGES $cv_freq
    } elseif { $device == "Arria V GZ"} {
       set_parameter_value DEVICE 7
       set_parameter_property LINERATE ALLOWED_RANGES $av_sv_freq
    } else {
		set_parameter_value DEVICE 8
      send_message error "Invalid device family selected."
	}

    # Validate the recommended receiver buffer value
    if { $mode == "0" && $widthrxbuf != "6" } {
		send_message info "Recomended receiver buffer value for master mode is 6 (2^6=64)"
	}
 	if { $mode == "1" && $widthrxbuf != "4" } {
		send_message info "Recomended receiver buffer value for slave mode is 4 (2^4=16)"
	}

    # Validate the supported linerate of Cyclone IV
	if {(($linerate > 2) && ($linerate != 614) && ($device == "Cyclone IV GX"))} {
		send_message error "$device only supports Line Rate = 0.6144, 1.2288, 2.4576 or 3.072 Gbps."
        }
        	
    # Validate the Channel number of TX & RX
    if {$S_CH_NUMBER_S_TX_value == $S_CH_NUMBER_S_RX_value} {
		send_message error "Slave transmitter and receiver starting channel number must not be the same"
	}
}

# INFO:
# Files that are add_fileset_file will be used to generate IPFS model
# Only the targetted device file will be added into the qip file

proc synth_proc { outputName } {
   set device                 [get_parameter_value DEVICEFAMILY]
   set linerate               [get_parameter_value LINERATE]
   set module_dir             [get_module_property MODULE_DIRECTORY]
   
   add_fileset_file ieee_ext.vhd VHDL PATH src_shared/ieee_ext.vhd
   add_fileset_file hdlc_reg.vhd VHDL PATH src_hdlc/hdlc_reg.vhd
   add_fileset_file mac_reg.vhd VHDL PATH src_mac/mac_reg.vhd
   add_fileset_file gray_pck.vhd VHDL PATH src_shared/gray_pck.vhd
   add_fileset_file prbs_pck.vhd VHDL PATH src_shared/prbs_pck.vhd
   add_fileset_file pck_4b5b.vhd VHDL PATH src_shared/pck_4b5b.vhd
   add_fileset_file altera_cpri.vhd VHDL PATH altera_cpri.vhd
   add_fileset_file cpri.vhd VHDL PATH cpri.vhd
   add_fileset_file cpri_cal.vhd VHDL PATH cpri_cal.vhd
   add_fileset_file cpri_reg.vhd VHDL PATH cpri_reg.vhd
   add_fileset_file cpri_cpuif.vhd VHDL PATH cpri_cpuif.vhd
   add_fileset_file cpri_rx.vhd VHDL PATH cpri_rx.vhd
   add_fileset_file cpri_rx_map.vhd VHDL PATH cpri_rx_map.vhd
   add_fileset_file cpri_tx.vhd VHDL PATH cpri_tx.vhd
   add_fileset_file cpri_tx_map.vhd VHDL PATH cpri_tx_map.vhd
   if { $device == "Stratix IV" || $device == "HardCopy IV" } {
      add_fileset_file stratix4gx_614_m.vhd VHDL PATH altgx/614/stratix4gx_614_m.vhd 
      add_fileset_file stratix4gx_614_s_tx.vhd VHDL PATH altgx/614/stratix4gx_614_s_tx.vhd 
      add_fileset_file stratix4gx_614_s_rx.vhd VHDL PATH altgx/614/stratix4gx_614_s_rx.vhd 
      add_fileset_file stratix4gx_1228_m.vhd VHDL PATH altgx/1228/stratix4gx_1228_m.vhd 
      add_fileset_file stratix4gx_1228_s_tx.vhd VHDL PATH altgx/1228/stratix4gx_1228_s_tx.vhd 
      add_fileset_file stratix4gx_1228_s_rx.vhd VHDL PATH altgx/1228/stratix4gx_1228_s_rx.vhd 
      add_fileset_file stratix4gx_2457_m.vhd VHDL PATH altgx/2457/stratix4gx_2457_m.vhd 
      add_fileset_file stratix4gx_2457_s_tx.vhd VHDL PATH altgx/2457/stratix4gx_2457_s_tx.vhd 
      add_fileset_file stratix4gx_2457_s_rx.vhd VHDL PATH altgx/2457/stratix4gx_2457_s_rx.vhd 
      add_fileset_file stratix4gx_3072_m.vhd VHDL PATH altgx/3072/stratix4gx_3072_m.vhd 
      add_fileset_file stratix4gx_3072_s_tx.vhd VHDL PATH altgx/3072/stratix4gx_3072_s_tx.vhd 
      add_fileset_file stratix4gx_3072_s_rx.vhd VHDL PATH altgx/3072/stratix4gx_3072_s_rx.vhd 
      add_fileset_file stratix4gx_4915_m.vhd VHDL PATH altgx/4915/stratix4gx_4915_m.vhd 
      add_fileset_file stratix4gx_4915_s_tx.vhd VHDL PATH altgx/4915/stratix4gx_4915_s_tx.vhd 
      add_fileset_file stratix4gx_4915_s_rx.vhd VHDL PATH altgx/4915/stratix4gx_4915_s_rx.vhd 
      add_fileset_file stratix4gx_6144_m.vhd VHDL PATH altgx/6144/stratix4gx_6144_m.vhd 
      add_fileset_file stratix4gx_6144_s_tx.vhd VHDL PATH altgx/6144/stratix4gx_6144_s_tx.vhd 
      add_fileset_file stratix4gx_6144_s_rx.vhd VHDL PATH altgx/6144/stratix4gx_6144_s_rx.vhd
   } elseif { $device == "Arria II GX"} {
      add_fileset_file arria2gx_614_m.vhd VHDL PATH altgx/614/arria2gx_614_m.vhd 
      add_fileset_file arria2gx_614_s_tx.vhd VHDL PATH altgx/614/arria2gx_614_s_tx.vhd 
      add_fileset_file arria2gx_614_s_rx.vhd VHDL PATH altgx/614/arria2gx_614_s_rx.vhd 
      add_fileset_file arria2gx_1228_m.vhd VHDL PATH altgx/1228/arria2gx_1228_m.vhd 
      add_fileset_file arria2gx_1228_s_tx.vhd VHDL PATH altgx/1228/arria2gx_1228_s_tx.vhd 
      add_fileset_file arria2gx_1228_s_rx.vhd VHDL PATH altgx/1228/arria2gx_1228_s_rx.vhd 
      add_fileset_file arria2gx_2457_m.vhd VHDL PATH altgx/2457/arria2gx_2457_m.vhd 
      add_fileset_file arria2gx_2457_s_tx.vhd VHDL PATH altgx/2457/arria2gx_2457_s_tx.vhd 
      add_fileset_file arria2gx_2457_s_rx.vhd VHDL PATH altgx/2457/arria2gx_2457_s_rx.vhd 
      add_fileset_file arria2gx_3072_m.vhd VHDL PATH altgx/3072/arria2gx_3072_m.vhd 
      add_fileset_file arria2gx_3072_s_tx.vhd VHDL PATH altgx/3072/arria2gx_3072_s_tx.vhd 
      add_fileset_file arria2gx_3072_s_rx.vhd VHDL PATH altgx/3072/arria2gx_3072_s_rx.vhd 
      add_fileset_file arria2gx_4915_m.vhd VHDL PATH altgx/4915/arria2gx_4915_m.vhd 
      add_fileset_file arria2gx_4915_s_tx.vhd VHDL PATH altgx/4915/arria2gx_4915_s_tx.vhd 
      add_fileset_file arria2gx_4915_s_rx.vhd VHDL PATH altgx/4915/arria2gx_4915_s_rx.vhd 
      add_fileset_file arria2gx_6144_m.vhd VHDL PATH altgx/6144/arria2gx_6144_m.vhd 
      add_fileset_file arria2gx_6144_s_tx.vhd VHDL PATH altgx/6144/arria2gx_6144_s_tx.vhd 
      add_fileset_file arria2gx_6144_s_rx.vhd VHDL PATH altgx/6144/arria2gx_6144_s_rx.vhd 	
   } elseif { $device == "Arria II GZ"} {
      add_fileset_file arria2gz_614_m.vhd VHDL PATH altgx/614/arria2gz_614_m.vhd 
      add_fileset_file arria2gz_614_s_tx.vhd VHDL PATH altgx/614/arria2gz_614_s_tx.vhd 
      add_fileset_file arria2gz_614_s_rx.vhd VHDL PATH altgx/614/arria2gz_614_s_rx.vhd 
      add_fileset_file arria2gz_1228_m.vhd VHDL PATH altgx/1228/arria2gz_1228_m.vhd 
      add_fileset_file arria2gz_1228_s_tx.vhd VHDL PATH altgx/1228/arria2gz_1228_s_tx.vhd 
      add_fileset_file arria2gz_1228_s_rx.vhd VHDL PATH altgx/1228/arria2gz_1228_s_rx.vhd 
      add_fileset_file arria2gz_2457_m.vhd VHDL PATH altgx/2457/arria2gz_2457_m.vhd 
      add_fileset_file arria2gz_2457_s_tx.vhd VHDL PATH altgx/2457/arria2gz_2457_s_tx.vhd 
      add_fileset_file arria2gz_2457_s_rx.vhd VHDL PATH altgx/2457/arria2gz_2457_s_rx.vhd 
      add_fileset_file arria2gz_3072_m.vhd VHDL PATH altgx/3072/arria2gz_3072_m.vhd 
      add_fileset_file arria2gz_3072_s_tx.vhd VHDL PATH altgx/3072/arria2gz_3072_s_tx.vhd 
      add_fileset_file arria2gz_3072_s_rx.vhd VHDL PATH altgx/3072/arria2gz_3072_s_rx.vhd 
      add_fileset_file arria2gz_4915_m.vhd VHDL PATH altgx/4915/arria2gz_4915_m.vhd 
      add_fileset_file arria2gz_4915_s_tx.vhd VHDL PATH altgx/4915/arria2gz_4915_s_tx.vhd 
      add_fileset_file arria2gz_4915_s_rx.vhd VHDL PATH altgx/4915/arria2gz_4915_s_rx.vhd 
      add_fileset_file arria2gz_6144_m.vhd VHDL PATH altgx/6144/arria2gz_6144_m.vhd 
      add_fileset_file arria2gz_6144_s_tx.vhd VHDL PATH altgx/6144/arria2gz_6144_s_tx.vhd 
      add_fileset_file arria2gz_6144_s_rx.vhd VHDL PATH altgx/6144/arria2gz_6144_s_rx.vhd 				 
   } elseif { $device == "Cyclone IV GX"} { 
      add_fileset_file cyclone4gx_614_m.vhd VHDL PATH altgx/614/cyclone4gx_614_m.vhd 
      add_fileset_file cyclone4gx_614_s_tx.vhd VHDL PATH altgx/614/cyclone4gx_614_s_tx.vhd 
      add_fileset_file cyclone4gx_614_s_rx.vhd VHDL PATH altgx/614/cyclone4gx_614_s_rx.vhd 
      add_fileset_file cyclone4gx_1228_m.vhd VHDL PATH altgx/1228/cyclone4gx_1228_m.vhd 
      add_fileset_file cyclone4gx_1228_s_tx.vhd VHDL PATH altgx/1228/cyclone4gx_1228_s_tx.vhd 
      add_fileset_file cyclone4gx_1228_s_rx.vhd VHDL PATH altgx/1228/cyclone4gx_1228_s_rx.vhd 
      add_fileset_file cyclone4gx_2457_m.vhd VHDL PATH altgx/2457/cyclone4gx_2457_m.vhd 
      add_fileset_file cyclone4gx_2457_s_tx.vhd VHDL PATH altgx/2457/cyclone4gx_2457_s_tx.vhd 
      add_fileset_file cyclone4gx_2457_s_rx.vhd VHDL PATH altgx/2457/cyclone4gx_2457_s_rx.vhd 
      add_fileset_file cyclone4gx_3072_m.vhd VHDL PATH altgx/3072/cyclone4gx_3072_m.vhd 
      add_fileset_file cyclone4gx_3072_s_tx.vhd VHDL PATH altgx/3072/cyclone4gx_3072_s_tx.vhd 
      add_fileset_file cyclone4gx_3072_s_rx.vhd VHDL PATH altgx/3072/cyclone4gx_3072_s_rx.vhd   	                          
   } else {
      # add nothing
}
   add_fileset_file buf_ram.vhd VHDL PATH src_altera/buf_ram.vhd 
	add_fileset_file dp_ram.vhd VHDL PATH src_altera/dp_ram.vhd 
	add_fileset_file sp_ram.vhd VHDL PATH src_altera/sp_ram.vhd 	
	add_fileset_file loop_buf.vhd VHDL PATH src_shared/loop_buf.vhd 
	add_fileset_file clock_sync.vhd VHDL PATH src_shared/clock_sync.vhd 
	add_fileset_file eth_crc_pck.vhd VHDL PATH src_shared/eth_crc_pck.vhd 
	add_fileset_file freq_lock_check.vhd VHDL PATH src_shared/freq_lock_check.vhd 
	add_fileset_file sync_event.vhd VHDL PATH src_shared/sync_event.vhd 
	add_fileset_file sync_bit.vhd VHDL PATH src_shared/sync_bit.vhd
	add_fileset_file sync_vector.vhd VHDL PATH src_shared/sync_vector.vhd
	add_fileset_file cpu_clock_sync.vhd VHDL PATH src_shared/cpu_clock_sync.vhd 
	add_fileset_file buf_ctrl.vhd VHDL PATH src_shared/buf_ctrl.vhd 
	add_fileset_file clock_switch.vhd VHDL PATH src_shared/clock_switch.vhd 
	add_fileset_file mac_tx.vhd VHDL PATH src_mac/mac_tx.vhd 
	add_fileset_file mac_rx.vhd VHDL PATH src_mac/mac_rx.vhd
	add_fileset_file mac_crc_calc.vhd VHDL PATH src_mac/mac_crc_calc.vhd 
	add_fileset_file mac_cpuif.vhd VHDL PATH src_mac/mac_cpuif.vhd 
	add_fileset_file mac_buf_tx.vhd VHDL PATH src_mac/mac_buf_tx.vhd 
	add_fileset_file mac_buf_rx.vhd VHDL PATH src_mac/mac_buf_rx.vhd 
	add_fileset_file mac_ram.vhd VHDL PATH src_mac/mac_ram.vhd 
	add_fileset_file mac.vhd VHDL PATH src_mac/mac.vhd 
	add_fileset_file hdlc_ram.vhd VHDL PATH src_hdlc/hdlc_ram.vhd 
	add_fileset_file hdlc_tx.vhd VHDL PATH src_hdlc/hdlc_tx.vhd 
	add_fileset_file hdlc_rx.vhd VHDL PATH src_hdlc/hdlc_rx.vhd 
	add_fileset_file hdlc_cpuif.vhd VHDL PATH src_hdlc/hdlc_cpuif.vhd 
	add_fileset_file hdlc_crc_calc.vhd VHDL PATH src_hdlc/hdlc_crc_calc.vhd 
	add_fileset_file hdlc_buf_tx.vhd VHDL PATH src_hdlc/hdlc_buf_tx.vhd 
	add_fileset_file hdlc_buf_rx.vhd VHDL PATH src_hdlc/hdlc_buf_rx.vhd 
	add_fileset_file hdlc.vhd VHDL PATH src_hdlc/hdlc.vhd 
	add_fileset_file reset_controller.vhd VHDL PATH reset_controller.vhd
	add_fileset_file cpri.ocp OTHER PATH cpri.ocp
	add_fileset_file cpri2.ocp OTHER PATH cpri2.ocp
	add_fileset_file cpri3.ocp OTHER PATH cpri3.ocp
	
	send_message info "Generating custom SDC script..."
	source ../constraints/cpri_constraints.tcl
}
