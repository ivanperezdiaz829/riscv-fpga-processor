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
set_global_assignment -name FAMILY "Stratix V"
set_global_assignment -name DEVICE 5SGXEA7K2F40C2
set_global_assignment -name TOP_LEVEL_ENTITY sv_dp_demo

# add files to the project
set_global_assignment -name VERILOG_FILE sv_dp_demo.v
set_global_assignment -name QIP_FILE ./sv_control/synthesis/sv_control.qip
set_global_assignment -name QIP_FILE sv_video_pll.qip
set_global_assignment -name QIP_FILE sv_xcvr_pll.qip
set_global_assignment -name QIP_FILE sv_xcvr_reconfig.qip
set_global_assignment -name QIP_FILE sv_aux_buffer.qip
set_global_assignment -name VERILOG_FILE reconfig_mgmt_write.v
set_global_assignment -name VERILOG_FILE reconfig_mgmt_hw_ctrl.v
set_global_assignment -name VERILOG_FILE dp_analog_mappings.v
set_global_assignment -name VERILOG_FILE dp_mif_mappings.v

#Add the example SDC last to not get overwritten by the IP ones
set_global_assignment -name SDC_FILE sv_dp_demo.sdc

# Add pin assignments (location and I/O standard)
# default to 2.5 V if not specified
set_global_assignment -name STRATIX_DEVICE_IO_STANDARD "2.5 V"

set_instance_assignment -name IO_STANDARD LVDS -to clk
set_location_assignment PIN_AH22 -to clk

set_instance_assignment -name IO_STANDARD "2.5 V" -to xcvr_pll_refclk
set_location_assignment PIN_AN6	-to xcvr_pll_refclk

set_location_assignment PIN_A7  -to resetn

set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to rx_serial_data[*]
set_location_assignment PIN_AK2 -to rx_serial_data[3]
set_location_assignment PIN_AM2 -to rx_serial_data[2]
set_location_assignment PIN_AP2 -to rx_serial_data[1]
set_location_assignment PIN_AV2 -to rx_serial_data[0]

set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to tx_serial_data[*]
set_location_assignment PIN_AJ4 -to tx_serial_data[0]
set_location_assignment PIN_AL4 -to tx_serial_data[1]
set_location_assignment PIN_AN4 -to tx_serial_data[2]
set_location_assignment PIN_AU4 -to tx_serial_data[3]
# Use this assignment to allow fitter to pack all the channels
# reconfig group. 
set_instance_assignment -name XCVR_TX_PLL_RECONFIG_GROUP 0 -to *cmu_pll.tx_pll

# Set the VOD to 200 mV by default when using the Bitec daughter card with TI re-drivers
set_instance_assignment -name XCVR_TX_VOD 10 -to tx_serial_data[*]

# Set the AC Gain to 4 to improve link quality at HBR2 rates
set_instance_assignment -name XCVR_RX_LINEAR_EQUALIZER_CONTROL 4 -to rx_serial_data[*]

set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 2.5-V SSTL CLASS II" -to AUX_TX_PC
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 2.5-V SSTL CLASS II" -to AUX_TX_NC

# Bitec daughter card has AUX N&P pins swapped vs schematic
set_location_assignment PIN_T9 -to AUX_TX_PC
set_location_assignment PIN_R9 -to AUX_TX_NC
set_location_assignment PIN_AJ12 -to TX_HPD
set_location_assignment PIN_L9 -to AUX_TX_DRV_OE
set_location_assignment PIN_M8 -to AUX_TX_DRV_OUT

set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 2.5-V SSTL CLASS II" -to AUX_RX_PC
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 2.5-V SSTL CLASS II" -to AUX_RX_NC

# Bitec daughter card has AUX N&P pins swapped vs schematic
set_location_assignment PIN_AF10 -to AUX_RX_PC
set_location_assignment PIN_AG10 -to AUX_RX_NC
set_location_assignment PIN_AK29 -to RX_HPD
set_location_assignment PIN_AB10 -to AUX_RX_DRV_OE
set_location_assignment PIN_AC10 -to AUX_RX_DRV_OUT

set_location_assignment PIN_J11 -to user_led[0]
set_location_assignment PIN_U10 -to user_led[1]
set_location_assignment PIN_U9 -to user_led[2]
set_location_assignment PIN_AU24 -to user_led[3]
set_location_assignment PIN_AF28 -to user_led[4]
set_location_assignment PIN_AE29 -to user_led[5]
set_location_assignment PIN_AR7 -to user_led[6]
set_location_assignment PIN_AV10 -to user_led[7]

set_location_assignment PIN_C7 -to user_pb[0]
set_location_assignment PIN_B7 -to user_pb[1]

set_location_assignment PIN_G31 -to mem_a[0]
set_location_assignment PIN_K31 -to mem_a[1]
set_location_assignment PIN_H31 -to mem_a[2]
set_location_assignment PIN_D31 -to mem_a[3]
set_location_assignment PIN_L30 -to mem_a[4]
set_location_assignment PIN_E31 -to mem_a[5]
set_location_assignment PIN_N31 -to mem_a[6]
set_location_assignment PIN_F30 -to mem_a[7]
set_location_assignment PIN_P31 -to mem_a[8]
set_location_assignment PIN_J29 -to mem_a[9]
set_location_assignment PIN_J30 -to mem_a[10]
set_location_assignment PIN_L31 -to mem_a[11]
set_location_assignment PIN_R30 -to mem_a[12]
set_location_assignment PIN_J31 -to mem_a[13]
set_location_assignment PIN_C31 -to mem_ba[0]
set_location_assignment PIN_K30 -to mem_ba[1]
set_location_assignment PIN_E30 -to mem_ba[2]
set_location_assignment PIN_A29 -to mem_dm[0]
set_location_assignment PIN_J28 -to mem_dm[1]
set_location_assignment PIN_A26 -to mem_dm[2]
set_location_assignment PIN_L27 -to mem_dm[3]
set_location_assignment PIN_A25 -to mem_dm[4]
set_location_assignment PIN_K25 -to mem_dm[5]
set_location_assignment PIN_A22 -to mem_dm[6]
set_location_assignment PIN_B20 -to mem_dm[7]
set_location_assignment PIN_M21 -to mem_dm[8]
set_location_assignment PIN_A28 -to mem_dq[0]
set_location_assignment PIN_E28 -to mem_dq[1]
set_location_assignment PIN_B29 -to mem_dq[2]
set_location_assignment PIN_F29 -to mem_dq[3]
set_location_assignment PIN_D28 -to mem_dq[4]
set_location_assignment PIN_H28 -to mem_dq[5]
set_location_assignment PIN_C28 -to mem_dq[6]
set_location_assignment PIN_G28 -to mem_dq[7]
set_location_assignment PIN_K28 -to mem_dq[8]
set_location_assignment PIN_M29 -to mem_dq[9]
set_location_assignment PIN_L28 -to mem_dq[10]
set_location_assignment PIN_R29 -to mem_dq[11]
set_location_assignment PIN_P29 -to mem_dq[12]
set_location_assignment PIN_V29 -to mem_dq[13]
set_location_assignment PIN_N28 -to mem_dq[14]
set_location_assignment PIN_U29 -to mem_dq[15]
set_location_assignment PIN_G26 -to mem_dq[16]
set_location_assignment PIN_D27 -to mem_dq[17]
set_location_assignment PIN_F26 -to mem_dq[18]
set_location_assignment PIN_C27 -to mem_dq[19]
set_location_assignment PIN_C26 -to mem_dq[20]
set_location_assignment PIN_J26 -to mem_dq[21]
set_location_assignment PIN_E27 -to mem_dq[22]
set_location_assignment PIN_H26 -to mem_dq[23]
set_location_assignment PIN_J27 -to mem_dq[24]
set_location_assignment PIN_N27 -to mem_dq[25]
set_location_assignment PIN_T27 -to mem_dq[26]
set_location_assignment PIN_M27 -to mem_dq[27]
set_location_assignment PIN_U26 -to mem_dq[28]
set_location_assignment PIN_P28 -to mem_dq[29]
set_location_assignment PIN_U27 -to mem_dq[30]
set_location_assignment PIN_R27 -to mem_dq[31]
set_location_assignment PIN_B25 -to mem_dq[32]
set_location_assignment PIN_F24 -to mem_dq[33]
set_location_assignment PIN_C25 -to mem_dq[34]
set_location_assignment PIN_G24 -to mem_dq[35]
set_location_assignment PIN_D24 -to mem_dq[36]
set_location_assignment PIN_H25 -to mem_dq[37]
set_location_assignment PIN_C24 -to mem_dq[38]
set_location_assignment PIN_G25 -to mem_dq[39]
set_location_assignment PIN_J25 -to mem_dq[40]
set_location_assignment PIN_N26 -to mem_dq[41]
set_location_assignment PIN_L26 -to mem_dq[42]
set_location_assignment PIN_P26 -to mem_dq[43]
set_location_assignment PIN_P25 -to mem_dq[44]
set_location_assignment PIN_T25 -to mem_dq[45]
set_location_assignment PIN_N25 -to mem_dq[46]
set_location_assignment PIN_U25 -to mem_dq[47]
set_location_assignment PIN_H22 -to mem_dq[48]
set_location_assignment PIN_B23 -to mem_dq[49]
set_location_assignment PIN_G22 -to mem_dq[50]
set_location_assignment PIN_G23 -to mem_dq[51]
set_location_assignment PIN_D22 -to mem_dq[52]
set_location_assignment PIN_H23 -to mem_dq[53]
set_location_assignment PIN_C22 -to mem_dq[54]
set_location_assignment PIN_A23 -to mem_dq[55]
set_location_assignment PIN_A20 -to mem_dq[56]
set_location_assignment PIN_C20 -to mem_dq[57]
set_location_assignment PIN_F20 -to mem_dq[58]
set_location_assignment PIN_C21 -to mem_dq[59]
set_location_assignment PIN_H20 -to mem_dq[60]
set_location_assignment PIN_D21 -to mem_dq[61]
set_location_assignment PIN_G20 -to mem_dq[62]
set_location_assignment PIN_E20 -to mem_dq[63]
set_location_assignment PIN_M20 -to mem_dq[64]
set_location_assignment PIN_L20 -to mem_dq[65]
set_location_assignment PIN_N22 -to mem_dq[66]
set_location_assignment PIN_J21 -to mem_dq[67]
set_location_assignment PIN_N21 -to mem_dq[68]
set_location_assignment PIN_K21 -to mem_dq[69]
set_location_assignment PIN_N20 -to mem_dq[70]
set_location_assignment PIN_L21 -to mem_dq[71]
set_location_assignment PIN_G29 -to mem_dqs_n[0]
set_location_assignment PIN_T30 -to mem_dqs_n[1]
set_location_assignment PIN_F27 -to mem_dqs_n[2]
set_location_assignment PIN_T28 -to mem_dqs_n[3]
set_location_assignment PIN_E25 -to mem_dqs_n[4]
set_location_assignment PIN_R26 -to mem_dqs_n[5]
set_location_assignment PIN_E23 -to mem_dqs_n[6]
set_location_assignment PIN_F21 -to mem_dqs_n[7]
set_location_assignment PIN_J22 -to mem_dqs_n[8]
set_location_assignment PIN_H29 -to mem_dqs[0]
set_location_assignment PIN_U30 -to mem_dqs[1]
set_location_assignment PIN_G27 -to mem_dqs[2]
set_location_assignment PIN_U28 -to mem_dqs[3]
set_location_assignment PIN_E24 -to mem_dqs[4]
set_location_assignment PIN_R25 -to mem_dqs[5]
set_location_assignment PIN_F23 -to mem_dqs[6]
set_location_assignment PIN_G21 -to mem_dqs[7]
set_location_assignment PIN_K22 -to mem_dqs[8]
set_location_assignment PIN_B34 -to oct_rzqin
set_location_assignment PIN_B28 -to mem_cas_n
set_location_assignment PIN_R31 -to mem_cke
set_location_assignment PIN_M30 -to mem_ck_n
set_location_assignment PIN_N30 -to mem_ck
set_location_assignment PIN_B31 -to mem_cs_n
set_location_assignment PIN_A31 -to mem_odt
set_location_assignment PIN_B26 -to mem_ras_n
set_location_assignment PIN_G30 -to mem_reset_n
set_location_assignment PIN_C30 -to mem_we_n

set_location_assignment PIN_N30 -to mem_ck[0]
set_location_assignment PIN_M30 -to mem_ck_n[0]

set_location_assignment PIN_J23 -to ddr_clk
set_location_assignment PIN_J24 -to "ddr_clk(n)"
set_instance_assignment -name IO_STANDARD LVDS -to ddr_clk

set_instance_assignment -name CURRENT_STRENGTH_NEW 16MA -to RX_HPD

# I2C Pins 
set_location_assignment PIN_AJ29 -to RX_CAD
set_location_assignment PIN_AV11 -to RX_ENA
set_location_assignment PIN_AM29 -to SCL_CTL
set_location_assignment PIN_AL29 -to SDA_CTL
set_location_assignment PIN_AR12 -to TX_ENA

set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to SCL_CTL
set_instance_assignment -name AUTO_OPEN_DRAIN_PINS ON -to SCL_CTL
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to SDA_CTL
set_instance_assignment -name AUTO_OPEN_DRAIN_PINS ON -to SDA_CTL
