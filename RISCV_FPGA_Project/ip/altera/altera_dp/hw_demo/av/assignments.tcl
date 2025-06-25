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


#######################################################
#
# Device, pin and other assignments for the 
# DisplayPort MegaCore Hardware Demo
# 
# #####################################################

# Set the family, device, top-level entity
set_global_assignment -name FAMILY "Arria V"
set_global_assignment -name DEVICE 5AGXFB3H4F40C5ES
set_global_assignment -name TOP_LEVEL_ENTITY av_dp_demo

# add files to the project
set_global_assignment -name VERILOG_FILE av_dp_demo.v
set_global_assignment -name QIP_FILE ./av_control/synthesis/av_control.qip
set_global_assignment -name QIP_FILE av_video_pll.qip
set_global_assignment -name QIP_FILE av_xcvr_pll.qip
set_global_assignment -name QIP_FILE av_xcvr_reconfig.qip
set_global_assignment -name QIP_FILE av_aux_buffer.qip
set_global_assignment -name VERILOG_FILE reconfig_mgmt_write.v
set_global_assignment -name VERILOG_FILE reconfig_mgmt_hw_ctrl.v
set_global_assignment -name VERILOG_FILE dp_analog_mappings.v
set_global_assignment -name VERILOG_FILE dp_mif_mappings.v

#Add the example SDC last to not get overwritten by the IP ones
set_global_assignment -name SDC_FILE av_dp_demo.sdc

# Add pin assignments (location and I/O standard)
# default to 2.5 V if not specified
set_global_assignment -name STRATIX_DEVICE_IO_STANDARD "2.5 V"

set_instance_assignment -name IO_STANDARD LVDS -to clk
set_location_assignment PIN_AD20 -to clk
set_location_assignment PIN_AC21 -to "clk(n)"

set_instance_assignment -name IO_STANDARD LVDS -to xcvr_pll_refclk
set_location_assignment PIN_AB9 -to xcvr_pll_refclk
set_location_assignment PIN_AB8 -to "xcvr_pll_refclk(n)"

set_location_assignment PIN_F18 -to resetn

set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to rx_serial_data[*]
set_location_assignment PIN_AJ1 -to rx_serial_data[3]
set_location_assignment PIN_W1 -to rx_serial_data[2]
set_location_assignment PIN_U1 -to rx_serial_data[1]
set_location_assignment PIN_R1 -to rx_serial_data[0]

set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to tx_serial_data[*]
set_location_assignment PIN_P3 -to tx_serial_data[3]
set_location_assignment PIN_T3 -to tx_serial_data[2]
set_location_assignment PIN_V3 -to tx_serial_data[1]
set_location_assignment PIN_AH3 -to tx_serial_data[0]

# Use this assignment to allow fitter to pack all the channels
# reconfig group. 
set_instance_assignment -name XCVR_TX_PLL_RECONFIG_GROUP 0 -to *cmu_pll.tx_pll

set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 2.5-V SSTL CLASS II" -to AUX_TX_PC
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 2.5-V SSTL CLASS II" -to AUX_TX_NC

# Bitec daughter card has AUX N&P pins swapped vs schematic
set_location_assignment PIN_AW11 -to AUX_TX_PC
set_location_assignment PIN_AW10 -to AUX_TX_NC
set_location_assignment PIN_AV9 -to TX_HPD
set_location_assignment PIN_AP10 -to AUX_TX_DRV_OE
set_location_assignment PIN_AM10 -to AUX_TX_DRV_OUT

set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 2.5-V SSTL CLASS II" -to AUX_RX_PC
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 2.5-V SSTL CLASS II" -to AUX_RX_NC

# Bitec daughter card has AUX N&P pins swapped vs schematic
set_location_assignment PIN_AU11 -to AUX_RX_PC
set_location_assignment PIN_AT11 -to AUX_RX_NC
set_location_assignment PIN_AH16 -to RX_HPD
set_location_assignment PIN_AW5 -to AUX_RX_DRV_OE
set_location_assignment PIN_AW6 -to AUX_RX_DRV_OUT

set_location_assignment PIN_AK15 -to user_led[7]
set_location_assignment PIN_AF15 -to user_led[6]
set_location_assignment PIN_AE16 -to user_led[5]
set_location_assignment PIN_AU14 -to user_led[4]
set_location_assignment PIN_AP11 -to user_led[3]
set_location_assignment PIN_F11 -to user_led[2]
set_location_assignment PIN_R18 -to user_led[1]
set_location_assignment PIN_C15 -to user_led[0]

set_location_assignment PIN_R19 -to user_pb[1]
set_location_assignment PIN_T19 -to user_pb[0]

set_instance_assignment -name CURRENT_STRENGTH_NEW 16MA -to RX_HPD

set_location_assignment PIN_M34 -to mem_a[0]
set_location_assignment PIN_H25 -to mem_a[1]
set_location_assignment PIN_F32 -to mem_a[2]
set_location_assignment PIN_P28 -to mem_a[3]
set_location_assignment PIN_L24 -to mem_a[4]
set_location_assignment PIN_G32 -to mem_a[5]
set_location_assignment PIN_R21 -to mem_a[6]
set_location_assignment PIN_K30 -to mem_a[7]
set_location_assignment PIN_D21 -to mem_a[8]
set_location_assignment PIN_M30 -to mem_a[9]
set_location_assignment PIN_J28 -to mem_a[10]
set_location_assignment PIN_M21 -to mem_a[11]
set_location_assignment PIN_G28 -to mem_a[12]
set_location_assignment PIN_M31 -to mem_a[13]
set_location_assignment PIN_G30 -to mem_ba[0]
set_location_assignment PIN_T24 -to mem_ba[1]
set_location_assignment PIN_K34 -to mem_ba[2]
set_location_assignment PIN_D32 -to mem_cas_n
set_location_assignment PIN_K29 -to mem_cke
set_location_assignment PIN_F34 -to mem_ck_n
set_location_assignment PIN_E34 -to mem_ck
set_location_assignment PIN_F31 -to mem_cs_n
set_location_assignment PIN_M32 -to mem_dm[0]
set_location_assignment PIN_D31 -to mem_dm[1]
set_location_assignment PIN_D29 -to mem_dm[2]
set_location_assignment PIN_H28 -to mem_dm[3]
set_location_assignment PIN_E27 -to mem_dm[4]
set_location_assignment PIN_A26 -to mem_dm[5]
set_location_assignment PIN_P24 -to mem_dm[6]
set_location_assignment PIN_B24 -to mem_dm[7]
set_location_assignment PIN_P22 -to mem_dm[8]
set_location_assignment PIN_N33 -to mem_dq[0]
set_location_assignment PIN_N31 -to mem_dq[1]
set_location_assignment PIN_N34 -to mem_dq[2]
set_location_assignment PIN_L31 -to mem_dq[3]
set_location_assignment PIN_N32 -to mem_dq[4]
set_location_assignment PIN_J34 -to mem_dq[5]
set_location_assignment PIN_P31 -to mem_dq[6]
set_location_assignment PIN_J32 -to mem_dq[7]
set_location_assignment PIN_A30 -to mem_dq[8]
set_location_assignment PIN_C30 -to mem_dq[9]
set_location_assignment PIN_B30 -to mem_dq[10]
set_location_assignment PIN_H31 -to mem_dq[11]
set_location_assignment PIN_B31 -to mem_dq[12]
set_location_assignment PIN_E31 -to mem_dq[13]
set_location_assignment PIN_A31 -to mem_dq[14]
set_location_assignment PIN_C31 -to mem_dq[15]
set_location_assignment PIN_D30 -to mem_dq[16]
set_location_assignment PIN_C29 -to mem_dq[17]
set_location_assignment PIN_R30 -to mem_dq[18]
set_location_assignment PIN_A29 -to mem_dq[19]
set_location_assignment PIN_L30 -to mem_dq[20]
set_location_assignment PIN_A28 -to mem_dq[21]
set_location_assignment PIN_J30 -to mem_dq[22]
set_location_assignment PIN_B28 -to mem_dq[23]
set_location_assignment PIN_J29 -to mem_dq[24]
set_location_assignment PIN_C28 -to mem_dq[25]
set_location_assignment PIN_L28 -to mem_dq[26]
set_location_assignment PIN_F28 -to mem_dq[27]
set_location_assignment PIN_N29 -to mem_dq[28]
set_location_assignment PIN_D28 -to mem_dq[29]
set_location_assignment PIN_M29 -to mem_dq[30]
set_location_assignment PIN_M28 -to mem_dq[31]
set_location_assignment PIN_P27 -to mem_dq[32]
set_location_assignment PIN_B27 -to mem_dq[33]
set_location_assignment PIN_R27 -to mem_dq[34]
set_location_assignment PIN_C27 -to mem_dq[35]
set_location_assignment PIN_M27 -to mem_dq[36]
set_location_assignment PIN_H27 -to mem_dq[37]
set_location_assignment PIN_N27 -to mem_dq[38]
set_location_assignment PIN_K27 -to mem_dq[39]
set_location_assignment PIN_J26 -to mem_dq[40]
set_location_assignment PIN_D26 -to mem_dq[41]
set_location_assignment PIN_K25 -to mem_dq[42]
set_location_assignment PIN_G26 -to mem_dq[43]
set_location_assignment PIN_T27 -to mem_dq[44]
set_location_assignment PIN_F26 -to mem_dq[45]
set_location_assignment PIN_R26 -to mem_dq[46]
set_location_assignment PIN_C26 -to mem_dq[47]
set_location_assignment PIN_T26 -to mem_dq[48]
set_location_assignment PIN_R24 -to mem_dq[49]
set_location_assignment PIN_D25 -to mem_dq[50]
set_location_assignment PIN_T25 -to mem_dq[51]
set_location_assignment PIN_E25 -to mem_dq[52]
set_location_assignment PIN_N24 -to mem_dq[53]
set_location_assignment PIN_G25 -to mem_dq[54]
set_location_assignment PIN_K24 -to mem_dq[55]
set_location_assignment PIN_F23 -to mem_dq[56]
set_location_assignment PIN_J23 -to mem_dq[57]
set_location_assignment PIN_G23 -to mem_dq[58]
set_location_assignment PIN_C24 -to mem_dq[59]
set_location_assignment PIN_F24 -to mem_dq[60]
set_location_assignment PIN_R23 -to mem_dq[61]
set_location_assignment PIN_G24 -to mem_dq[62]
set_location_assignment PIN_M23 -to mem_dq[63]
set_location_assignment PIN_B22 -to mem_dq[64]
set_location_assignment PIN_L22 -to mem_dq[65]
set_location_assignment PIN_C22 -to mem_dq[66]
set_location_assignment PIN_N22 -to mem_dq[67]
set_location_assignment PIN_E22 -to mem_dq[68]
set_location_assignment PIN_J22 -to mem_dq[69]
set_location_assignment PIN_A23 -to mem_dq[70]
set_location_assignment PIN_F22 -to mem_dq[71]
set_location_assignment PIN_M33 -to mem_dqs_n[0]
set_location_assignment PIN_B33 -to mem_dqs_n[1]
set_location_assignment PIN_P30 -to mem_dqs_n[2]
set_location_assignment PIN_T29 -to mem_dqs_n[3]
set_location_assignment PIN_T28 -to mem_dqs_n[4]
set_location_assignment PIN_N26 -to mem_dqs_n[5]
set_location_assignment PIN_B25 -to mem_dqs_n[6]
set_location_assignment PIN_E24 -to mem_dqs_n[7]
set_location_assignment PIN_D23 -to mem_dqs_n[8]
set_location_assignment PIN_L33 -to mem_dqs[0]
set_location_assignment PIN_A33 -to mem_dqs[1]
set_location_assignment PIN_N30 -to mem_dqs[2]
set_location_assignment PIN_R29 -to mem_dqs[3]
set_location_assignment PIN_R28 -to mem_dqs[4]
set_location_assignment PIN_M26 -to mem_dqs[5]
set_location_assignment PIN_A25 -to mem_dqs[6]
set_location_assignment PIN_D24 -to mem_dqs[7]
set_location_assignment PIN_C23 -to mem_dqs[8]
set_location_assignment PIN_E33 -to mem_odt
set_location_assignment PIN_A32 -to mem_ras_n
set_location_assignment PIN_J31 -to mem_reset_n
set_location_assignment PIN_G29 -to mem_we_n
set_location_assignment PIN_F33 -to oct_rzqin

set_instance_assignment -name IO_STANDARD LVDS -to ddr_clk
set_location_assignment PIN_A22 -to ddr_clk

# I2C Pins 
set_location_assignment PIN_AG16 -to RX_CAD
set_location_assignment PIN_AW12 -to RX_ENA
set_location_assignment PIN_AU15 -to SCL_CTL
set_location_assignment PIN_AT14 -to SDA_CTL
set_location_assignment PIN_AU7 -to TX_ENA

set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to SCL_CTL
set_instance_assignment -name AUTO_OPEN_DRAIN_PINS ON -to SCL_CTL
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to SDA_CTL
set_instance_assignment -name AUTO_OPEN_DRAIN_PINS ON -to SDA_CTL
