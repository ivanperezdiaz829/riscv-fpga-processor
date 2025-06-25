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

# Turn off parallel synthesis until case:128743 is resolved
set_global_assignment -name AUTO_PARALLEL_SYNTHESIS OFF

# Set the family, device, top-level entity
set_global_assignment -name FAMILY "Cyclone V"
set_global_assignment -name DEVICE 5CGTFD9E5F35C7
set_global_assignment -name TOP_LEVEL_ENTITY cv_dp_demo

# add files to the project
set_global_assignment -name VERILOG_FILE cv_dp_demo.v
set_global_assignment -name QIP_FILE ./cv_control/synthesis/cv_control.qip
set_global_assignment -name QIP_FILE cv_video_pll.qip
set_global_assignment -name QIP_FILE cv_pll_162.qip
set_global_assignment -name QIP_FILE cv_pll_270.qip
set_global_assignment -name QIP_FILE cv_xcvr_reconfig.qip
set_global_assignment -name QIP_FILE cv_aux_buffer.qip
set_global_assignment -name VERILOG_FILE reconfig_mgmt_write.v
set_global_assignment -name VERILOG_FILE reconfig_mgmt_hw_ctrl.v
set_global_assignment -name VERILOG_FILE dp_analog_mappings.v
set_global_assignment -name VERILOG_FILE dp_mif_mappings.v

#Add the example SDC last to not get overwritten by the IP ones
set_global_assignment -name SDC_FILE cv_dp_demo.sdc

# Add pin assignments (location and I/O standard)
# default to 2.5 V if not specified
set_global_assignment -name STRATIX_DEVICE_IO_STANDARD "2.5 V"

set_instance_assignment -name IO_STANDARD LVDS -to clk
set_location_assignment PIN_H19 -to clk
set_location_assignment PIN_H18 -to "clk(n)"

set_instance_assignment -name IO_STANDARD LVDS -to xcvr_pll_refclk
set_location_assignment PIN_AF18 -to xcvr_pll_refclk
set_location_assignment PIN_AG18 -to "xcvr_pll_refclk(n)"

set_location_assignment PIN_AN8 -to resetn

set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to rx_serial_data[*]
set_location_assignment PIN_R2 -to rx_serial_data[3]
set_location_assignment PIN_U2 -to rx_serial_data[2]
set_location_assignment PIN_W2 -to rx_serial_data[1]
set_location_assignment PIN_AA2 -to rx_serial_data[0]
set_location_assignment PIN_R1 -to "rx_serial_data[3](n)"
set_location_assignment PIN_U1 -to "rx_serial_data[2](n)"
set_location_assignment PIN_W1 -to "rx_serial_data[1](n)"
set_location_assignment PIN_AA1 -to "rx_serial_data[0](n)"

set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to tx_serial_data[*]
set_location_assignment PIN_Y4 -to tx_serial_data[3]
set_location_assignment PIN_V4 -to tx_serial_data[2]
set_location_assignment PIN_T4 -to tx_serial_data[1]
set_location_assignment PIN_P4 -to tx_serial_data[0]
set_location_assignment PIN_Y3 -to "tx_serial_data[3](n)"
set_location_assignment PIN_V3 -to "tx_serial_data[2](n)"
set_location_assignment PIN_T3 -to "tx_serial_data[1](n)"
set_location_assignment PIN_P3 -to "tx_serial_data[0](n)"

# Use this assignment to allow fitter to pack all the channels
# reconfig group. 
set_instance_assignment -name XCVR_TX_PLL_RECONFIG_GROUP 0 -to *cmu_pll.tx_pll

set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 2.5-V SSTL CLASS II" -to AUX_TX_PC
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 2.5-V SSTL CLASS II" -to AUX_TX_NC

# Bitec daughter card has AUX N&P pins swapped vs schematic
set_location_assignment PIN_E15 -to AUX_TX_PC
set_location_assignment PIN_D15 -to AUX_TX_NC
set_location_assignment PIN_L17 -to TX_HPD
set_location_assignment PIN_G15 -to AUX_TX_DRV_OE
set_location_assignment PIN_E18 -to AUX_TX_DRV_OUT

set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 2.5-V SSTL CLASS II" -to AUX_RX_PC
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 2.5-V SSTL CLASS II" -to AUX_RX_NC

# Bitec daughter card has AUX N&P pins swapped vs schematic
set_location_assignment PIN_B8 -to AUX_RX_PC
set_location_assignment PIN_A8 -to AUX_RX_NC
set_location_assignment PIN_F11 -to RX_HPD
set_location_assignment PIN_H14 -to AUX_RX_DRV_OE
set_location_assignment PIN_G14 -to AUX_RX_DRV_OUT


set_instance_assignment -name IO_STANDARD "1.5 V" -to user_led[*]

set_location_assignment PIN_AH27 -to user_led[7]
set_location_assignment PIN_AC22 -to user_led[6]
set_location_assignment PIN_AJ27 -to user_led[5]
set_location_assignment PIN_AF25 -to user_led[4]
set_location_assignment PIN_AL31 -to user_led[3]
set_location_assignment PIN_AK29 -to user_led[2]
set_location_assignment PIN_AE25 -to user_led[1]
set_location_assignment PIN_AM23 -to user_led[0]

set_location_assignment PIN_AK13 -to user_pb[0]
set_location_assignment PIN_AA15 -to user_pb[1]

set_location_assignment PIN_H29 -to mem_a[0]
set_location_assignment PIN_K28 -to mem_a[1]
set_location_assignment PIN_V33 -to mem_a[10]
set_location_assignment PIN_U33 -to mem_a[11]
set_location_assignment PIN_T31 -to mem_a[12]
set_location_assignment PIN_T30 -to mem_a[13]
set_location_assignment PIN_K34 -to mem_a[2]
set_location_assignment PIN_L32 -to mem_a[3]
set_location_assignment PIN_R32 -to mem_a[4]
set_location_assignment PIN_R33 -to mem_a[5]
set_location_assignment PIN_N32 -to mem_a[6]
set_location_assignment PIN_G33 -to mem_a[7]
set_location_assignment PIN_AE34 -to mem_a[8]
set_location_assignment PIN_L27 -to mem_a[9]
set_location_assignment PIN_J31 -to mem_ba[0]
set_location_assignment PIN_N29 -to mem_ba[1]
set_location_assignment PIN_P27 -to mem_ba[2]
set_location_assignment PIN_N27 -to mem_cas_n
set_location_assignment PIN_AF32 -to mem_cke
set_location_assignment PIN_R29 -to mem_ck_n
set_location_assignment PIN_R30 -to mem_ck
set_location_assignment PIN_V27 -to mem_cs_n
set_location_assignment PIN_AE30 -to mem_dm[0]
set_location_assignment PIN_AE32 -to mem_dm[1]
set_location_assignment PIN_AC34 -to mem_dm[2]
set_location_assignment PIN_W34 -to mem_dm[3]
set_location_assignment PIN_M33 -to mem_dm[4]
set_location_assignment PIN_K32 -to mem_dm[5]
set_location_assignment PIN_L31 -to mem_dm[6]
set_location_assignment PIN_H28 -to mem_dm[7]
set_location_assignment PIN_AF31 -to mem_dq[0]
set_location_assignment PIN_AD30 -to mem_dq[1]
set_location_assignment PIN_AB31 -to mem_dq[10]
set_location_assignment PIN_AJ34 -to mem_dq[11]
set_location_assignment PIN_AA31 -to mem_dq[12]
set_location_assignment PIN_AK34 -to mem_dq[13]
set_location_assignment PIN_W31 -to mem_dq[14]
set_location_assignment PIN_AG33 -to mem_dq[15]
set_location_assignment PIN_AD34 -to mem_dq[16]
set_location_assignment PIN_AC33 -to mem_dq[17]
set_location_assignment PIN_AG34 -to mem_dq[18]
set_location_assignment PIN_AB33 -to mem_dq[19]
set_location_assignment PIN_AJ32 -to mem_dq[2]
set_location_assignment PIN_AE33 -to mem_dq[20]
set_location_assignment PIN_V32 -to mem_dq[21]
set_location_assignment PIN_AH34 -to mem_dq[22]
set_location_assignment PIN_W32 -to mem_dq[23]
set_location_assignment PIN_U29 -to mem_dq[24]
set_location_assignment PIN_V34 -to mem_dq[25]
set_location_assignment PIN_U34 -to mem_dq[26]
set_location_assignment PIN_AA33 -to mem_dq[27]
set_location_assignment PIN_R34 -to mem_dq[28]
set_location_assignment PIN_Y33 -to mem_dq[29]
set_location_assignment PIN_AC31 -to mem_dq[3]
set_location_assignment PIN_P34 -to mem_dq[30]
set_location_assignment PIN_U28 -to mem_dq[31]
set_location_assignment PIN_T32 -to mem_dq[32]
set_location_assignment PIN_N33 -to mem_dq[33]
set_location_assignment PIN_T33 -to mem_dq[34]
set_location_assignment PIN_L33 -to mem_dq[35]
set_location_assignment PIN_T28 -to mem_dq[36]
set_location_assignment PIN_J34 -to mem_dq[37]
set_location_assignment PIN_T27 -to mem_dq[38]
set_location_assignment PIN_M34 -to mem_dq[39]
set_location_assignment PIN_AH32 -to mem_dq[4]
set_location_assignment PIN_K33 -to mem_dq[40]
set_location_assignment PIN_N31 -to mem_dq[41]
set_location_assignment PIN_G34 -to mem_dq[42]
set_location_assignment PIN_R28 -to mem_dq[43]
set_location_assignment PIN_H33 -to mem_dq[44]
set_location_assignment PIN_P32 -to mem_dq[45]
set_location_assignment PIN_H34 -to mem_dq[46]
set_location_assignment PIN_R27 -to mem_dq[47]
set_location_assignment PIN_N28 -to mem_dq[48]
set_location_assignment PIN_L30 -to mem_dq[49]
set_location_assignment PIN_Y28 -to mem_dq[5]
set_location_assignment PIN_P30 -to mem_dq[50]
set_location_assignment PIN_K30 -to mem_dq[51]
set_location_assignment PIN_J32 -to mem_dq[52]
set_location_assignment PIN_H32 -to mem_dq[53]
set_location_assignment PIN_M31 -to mem_dq[54]
set_location_assignment PIN_H31 -to mem_dq[55]
set_location_assignment PIN_G30 -to mem_dq[56]
set_location_assignment PIN_K29 -to mem_dq[57]
set_location_assignment PIN_G31 -to mem_dq[58]
set_location_assignment PIN_M30 -to mem_dq[59]
set_location_assignment PIN_AN34 -to mem_dq[6]
set_location_assignment PIN_J30 -to mem_dq[60]
set_location_assignment PIN_M29 -to mem_dq[61]
set_location_assignment PIN_J29 -to mem_dq[62]
set_location_assignment PIN_L28 -to mem_dq[63]
set_location_assignment PIN_Y27 -to mem_dq[7]
set_location_assignment PIN_AD32 -to mem_dq[8]
set_location_assignment PIN_AH33 -to mem_dq[9]
set_location_assignment PIN_Y29 -to mem_dqs[0]
set_location_assignment PIN_W29 -to mem_dqs[1]
set_location_assignment PIN_V24 -to mem_dqs[2]
set_location_assignment PIN_U24 -to mem_dqs[3]
set_location_assignment PIN_U23 -to mem_dqs[4]
set_location_assignment PIN_T25 -to mem_dqs[5]
set_location_assignment PIN_R23 -to mem_dqs[6]
set_location_assignment PIN_P24 -to mem_dqs[7]
set_location_assignment PIN_AA32 -to mem_odt
set_location_assignment PIN_Y32 -to mem_ras_n
set_location_assignment PIN_AG31 -to mem_reset_n
set_location_assignment PIN_AM34 -to mem_we_n
set_location_assignment PIN_AP19 -to oct_rzqin

set_instance_assignment -name IO_STANDARD LVDS -to ddr_clk
set_location_assignment PIN_W26 -to ddr_clk

# I2C Pins 
set_location_assignment PIN_L12 -to RX_CAD
set_location_assignment PIN_P14 -to RX_ENA
set_location_assignment PIN_E12 -to SCL_CTL
set_location_assignment PIN_K13 -to SDA_CTL
set_location_assignment PIN_L13 -to TX_ENA

set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to SCL_CTL
set_instance_assignment -name AUTO_OPEN_DRAIN_PINS ON -to SCL_CTL
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to SDA_CTL
set_instance_assignment -name AUTO_OPEN_DRAIN_PINS ON -to SDA_CTL
