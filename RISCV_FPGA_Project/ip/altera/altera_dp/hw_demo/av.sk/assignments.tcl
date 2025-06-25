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
set_global_assignment -name DEVICE 5AGXFB3H4F35C4
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
set_location_assignment PIN_AH18 -to clk
set_location_assignment PIN_AG18 -to "clk(n)"

set_instance_assignment -name IO_STANDARD LVDS -to xcvr_pll_refclk
set_location_assignment PIN_A3 -to xcvr_pll_refclk
set_location_assignment PIN_B3 -to "xcvr_pll_refclk(n)"

set_location_assignment PIN_B14 -to resetn

set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to rx_serial_data[*]
set_location_assignment PIN_P1 -to rx_serial_data[3]
set_location_assignment PIN_M1 -to rx_serial_data[2]
set_location_assignment PIN_K1 -to rx_serial_data[1]
set_location_assignment PIN_H1 -to rx_serial_data[0]

set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to tx_serial_data[*]
set_location_assignment PIN_G3 -to tx_serial_data[3]
set_location_assignment PIN_J3 -to tx_serial_data[2]
set_location_assignment PIN_L3 -to tx_serial_data[1]
set_location_assignment PIN_N3 -to tx_serial_data[0]

# Use this assignment to allow fitter to pack all the channels
# reconfig group. 
set_instance_assignment -name XCVR_TX_PLL_RECONFIG_GROUP 0 -to *cmu_pll.tx_pll

set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 2.5-V SSTL CLASS II" -to AUX_TX_PC
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 2.5-V SSTL CLASS II" -to AUX_TX_NC

# Bitec daughter card has AUX N&P pins swapped vs schematic
set_location_assignment PIN_A13 -to AUX_TX_PC
set_location_assignment PIN_B12 -to AUX_TX_NC
set_location_assignment PIN_AK12 -to TX_HPD
set_location_assignment PIN_B11 -to AUX_TX_DRV_OE
set_location_assignment PIN_E11 -to AUX_TX_DRV_OUT

set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 2.5-V SSTL CLASS II" -to AUX_RX_PC
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 2.5-V SSTL CLASS II" -to AUX_RX_NC

# Bitec daughter card has AUX N&P pins swapped vs schematic
set_location_assignment PIN_AM13 -to AUX_RX_PC
set_location_assignment PIN_AL13 -to AUX_RX_NC
set_location_assignment PIN_AH10 -to RX_HPD
set_location_assignment PIN_AJ13 -to AUX_RX_DRV_OE
set_location_assignment PIN_AH13 -to AUX_RX_DRV_OUT

set_location_assignment PIN_C16 -to user_led[7]
set_location_assignment PIN_C14 -to user_led[6]
set_location_assignment PIN_C13 -to user_led[5]
set_location_assignment PIN_D16 -to user_led[4]
set_location_assignment PIN_G17 -to user_led[3]
set_location_assignment PIN_G16 -to user_led[2]
set_location_assignment PIN_G15 -to user_led[1]
set_location_assignment PIN_F17 -to user_led[0]

set_location_assignment PIN_B15 -to user_pb[1]
set_location_assignment PIN_A14 -to user_pb[0]


set_instance_assignment -name CURRENT_STRENGTH_NEW 16MA -to RX_HPD


set_instance_assignment -name IO_STANDARD "1.5 V" -to oct_rzqin

set_location_assignment PIN_E26 -to mem_ck

set_location_assignment PIN_F26 -to mem_ck_n

set_location_assignment PIN_D26 -to mem_a[0]

set_location_assignment PIN_E27 -to mem_a[1]

set_location_assignment PIN_A27 -to mem_a[2]

set_location_assignment PIN_B27 -to mem_a[3]

set_location_assignment PIN_G26 -to mem_a[4]

set_location_assignment PIN_H26 -to mem_a[5]

set_location_assignment PIN_K27 -to mem_a[6]

set_location_assignment PIN_L27 -to mem_a[7]

set_location_assignment PIN_D27 -to mem_a[8]

set_location_assignment PIN_C28 -to mem_a[9]

set_location_assignment PIN_C29 -to mem_a[10]

set_location_assignment PIN_D28 -to mem_a[11]

set_location_assignment PIN_G27 -to mem_a[12]

set_location_assignment PIN_A29 -to mem_ba[0]

set_location_assignment PIN_A28 -to mem_ba[1]

set_location_assignment PIN_B29 -to mem_ba[2]

set_location_assignment PIN_F28 -to mem_cas_n

set_location_assignment PIN_K29 -to mem_cke

set_location_assignment PIN_D30 -to mem_cs_n

set_location_assignment PIN_H27 -to mem_odt

set_location_assignment PIN_B30 -to mem_ras_n

set_location_assignment PIN_F29 -to mem_we_n

set_location_assignment PIN_K25 -to mem_reset_n

set_location_assignment PIN_E32 -to oct_rzqin

set_location_assignment PIN_G24 -to mem_dq[0]

set_location_assignment PIN_H24 -to mem_dq[1]

set_location_assignment PIN_M24 -to mem_dq[2]

set_location_assignment PIN_A26 -to mem_dq[3]

set_location_assignment PIN_A25 -to mem_dq[4]

set_location_assignment PIN_C25 -to mem_dq[5]

set_location_assignment PIN_B26 -to mem_dq[6]

set_location_assignment PIN_C26 -to mem_dq[7]

set_location_assignment PIN_M25 -to mem_dm[0]

set_location_assignment PIN_F25 -to mem_dqs[0]

set_location_assignment PIN_G25 -to mem_dqs_n[0]

set_location_assignment PIN_H23 -to mem_dq[8]

set_location_assignment PIN_J23 -to mem_dq[9]

set_location_assignment PIN_K24 -to mem_dq[10]

set_location_assignment PIN_B24 -to mem_dq[11]

set_location_assignment PIN_C23 -to mem_dq[12]

set_location_assignment PIN_D23 -to mem_dq[13]

set_location_assignment PIN_D24 -to mem_dq[14]

set_location_assignment PIN_E24 -to mem_dq[15]

set_location_assignment PIN_M23 -to mem_dm[1]

set_location_assignment PIN_F23 -to mem_dqs[1]

set_location_assignment PIN_G23 -to mem_dqs_n[1]

set_location_assignment PIN_D21 -to mem_dq[16]

set_location_assignment PIN_E21 -to mem_dq[17]

set_location_assignment PIN_M21 -to mem_dq[18]

set_location_assignment PIN_C22 -to mem_dq[19]

set_location_assignment PIN_D22 -to mem_dq[20]

set_location_assignment PIN_G21 -to mem_dq[21]

set_location_assignment PIN_A23 -to mem_dq[22]

set_location_assignment PIN_B23 -to mem_dq[23]

set_location_assignment PIN_M22 -to mem_dm[2]

set_location_assignment PIN_F22 -to mem_dqs[2]

set_location_assignment PIN_G22 -to mem_dqs_n[2]

set_location_assignment PIN_K20 -to mem_dq[24]

set_location_assignment PIN_L20 -to mem_dq[25]

set_location_assignment PIN_M20 -to mem_dq[26]

set_location_assignment PIN_A22 -to mem_dq[27]

set_location_assignment PIN_B21 -to mem_dq[28]

set_location_assignment PIN_B20 -to mem_dq[29]

set_location_assignment PIN_F20 -to mem_dq[30]

set_location_assignment PIN_G20 -to mem_dq[31]

set_location_assignment PIN_K21 -to mem_dm[3]

set_location_assignment PIN_D20 -to mem_dqs[3]

set_location_assignment PIN_E20 -to mem_dqs_n[3]

set_instance_assignment -name IO_STANDARD LVDS -to ddr_clk
set_location_assignment PIN_A19 -to ddr_clk

# I2C Pins 
set_location_assignment PIN_AJ10 -to RX_CAD
set_location_assignment PIN_AP11 -to RX_ENA
set_location_assignment PIN_AJ8 -to SCL_CTL
set_location_assignment PIN_AK8 -to SDA_CTL
set_location_assignment PIN_AL8 -to TX_ENA

set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to SCL_CTL
set_instance_assignment -name AUTO_OPEN_DRAIN_PINS ON -to SCL_CTL
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to SDA_CTL
set_instance_assignment -name AUTO_OPEN_DRAIN_PINS ON -to SDA_CTL
