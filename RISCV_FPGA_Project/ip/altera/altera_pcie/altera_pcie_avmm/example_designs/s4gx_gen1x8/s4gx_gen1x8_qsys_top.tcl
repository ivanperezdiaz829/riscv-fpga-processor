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


set_global_assignment -name FAMILY "Stratix IV"
set_global_assignment -name DEVICE EP4SGX230KF40C2
set_global_assignment -name TOP_LEVEL_ENTITY s4gx_gen1x8_qsys_top
set_global_assignment -name QIP_FILE hip_s4gx_gen1x8_qsys/synthesis/hip_s4gx_gen1x8_qsys.qip
set_global_assignment -name VERILOG_FILE s4gx_gen1x8_qsys_top.v
set_global_assignment -name SDC_FILE s4gx_gen1x8_qsys_top.sdc
set_global_assignment -name VERILOG_FILE altgxb_reconfig.v
set_global_assignment -name VERILOG_FILE gpll.v
#--------------------------------------------------------------#
#
#  S4GX dev kit board pin assignments
#
set_global_assignment -name MIN_CORE_JUNCTION_TEMP 0
set_global_assignment -name MAX_CORE_JUNCTION_TEMP 85
set_global_assignment -name DEVICE_FILTER_PACKAGE FBGA
set_global_assignment -name DEVICE_FILTER_PIN_COUNT 1517
set_global_assignment -name STRATIX_DEVICE_IO_STANDARD "2.5 V"
set_location_assignment PIN_AV22 -to free_100MHZ
set_location_assignment PIN_F33 -to L0_led -disable
set_instance_assignment -name IO_STANDARD "2.5 V" -to L0_led -disable
set_location_assignment PIN_AK33 -to alive_led -disable
set_instance_assignment -name IO_STANDARD "2.5 V" -to alive_led -disable
set_location_assignment PIN_W28 -to comp_led -disable
set_instance_assignment -name IO_STANDARD "2.5 V" -to comp_led
set_instance_assignment -name IO_STANDARD LVDS -to free_100MHz
set_location_assignment PIN_AB28 -to gen2_led -disable
set_location_assignment PIN_AF29 -to lane_active_led[3] -disable
set_instance_assignment -name IO_STANDARD "2.5 V" -to lane_active_led[3] -disable
set_location_assignment PIN_AH35 -to lane_active_led[2] -disable
set_instance_assignment -name IO_STANDARD "2.5 V" -to lane_active_led[2] -disable
set_location_assignment PIN_R29 -to lane_active_led[0] -disable
set_instance_assignment -name IO_STANDARD "2.5 V" -to lane_active_led[0] -disable
set_location_assignment PIN_AK35 -to local_rstn_ext -disable
set_instance_assignment -name IO_STANDARD "2.5 V" -to local_rstn_ext -disable
set_location_assignment PIN_R32 -to pcie_rstn
set_instance_assignment -name IO_STANDARD "2.5 V" -to pcie_rstn
set_location_assignment PIN_AN38 -to refclk
set_instance_assignment -name IO_STANDARD HCSL -to refclk
set_location_assignment PIN_W32 -to req_compliance_push_button_n -disable
set_instance_assignment -name IO_STANDARD "2.5 V" -to req_compliance_push_button_n -disable
set_location_assignment PIN_AU38 -to rx_in0
set_instance_assignment -name IO_STANDARD "1.4-V PCML" -to rx_in0
set_location_assignment PIN_AR38 -to rx_in1
set_instance_assignment -name IO_STANDARD "1.4-V PCML" -to rx_in1
set_location_assignment PIN_AJ38 -to rx_in2
set_instance_assignment -name IO_STANDARD "1.4-V PCML" -to rx_in2
set_location_assignment PIN_AG38 -to rx_in3
set_instance_assignment -name IO_STANDARD "1.4-V PCML" -to rx_in3
set_location_assignment PIN_AE38 -to rx_in4
set_instance_assignment -name IO_STANDARD "1.4-V PCML" -to rx_in4
set_location_assignment PIN_AC38 -to rx_in5
set_instance_assignment -name IO_STANDARD "1.4-V PCML" -to rx_in5
set_location_assignment PIN_U38 -to rx_in6
set_instance_assignment -name IO_STANDARD "1.4-V PCML" -to rx_in6
set_location_assignment PIN_R38 -to rx_in7
set_instance_assignment -name IO_STANDARD "1.4-V PCML" -to rx_in7
set_location_assignment PIN_AT36 -to tx_out0
set_instance_assignment -name IO_STANDARD "1.4-V PCML" -to tx_out0
set_location_assignment PIN_AP36 -to tx_out1
set_instance_assignment -name IO_STANDARD "1.4-V PCML" -to tx_out1
set_location_assignment PIN_AH36 -to tx_out2
set_instance_assignment -name IO_STANDARD "1.4-V PCML" -to tx_out2
set_location_assignment PIN_AF36 -to tx_out3
set_instance_assignment -name IO_STANDARD "1.4-V PCML" -to tx_out3
set_location_assignment PIN_AD36 -to tx_out4
set_instance_assignment -name IO_STANDARD "1.4-V PCML" -to tx_out4
set_location_assignment PIN_AB36 -to tx_out5
set_instance_assignment -name IO_STANDARD "1.4-V PCML" -to tx_out5
set_location_assignment PIN_T36 -to tx_out6
set_instance_assignment -name IO_STANDARD "1.4-V PCML" -to tx_out6
set_location_assignment PIN_P36 -to tx_out7
set_instance_assignment -name IO_STANDARD "1.4-V PCML" -to tx_out7
set_location_assignment PIN_AG31 -to usr_sw[7] -disable
set_instance_assignment -name IO_STANDARD "2.5 V" -to usr_sw[7] -disable
set_location_assignment PIN_AG34 -to usr_sw[6] -disable
set_instance_assignment -name IO_STANDARD "2.5 V" -to usr_sw[6] -disable
set_location_assignment PIN_K35 -to usr_sw[5] -disable
set_instance_assignment -name IO_STANDARD "2.5 V" -to usr_sw[5] -disable
set_location_assignment PIN_G33 -to usr_sw[4] -disable
set_instance_assignment -name IO_STANDARD "2.5 V" -to usr_sw[4] -disable
set_location_assignment PIN_AN35 -to usr_sw[3] -disable
set_instance_assignment -name IO_STANDARD "2.5 V" -to usr_sw[3] -disable
set_location_assignment PIN_J34 -to usr_sw[2] -disable
set_instance_assignment -name IO_STANDARD "2.5 V" -to usr_sw[2] -disable
set_location_assignment PIN_AC35 -to usr_sw[1] -disable
set_instance_assignment -name IO_STANDARD "2.5 V" -to usr_sw[1] -disable
set_location_assignment PIN_AL35 -to usr_sw[0] -disable
set_instance_assignment -name IO_STANDARD "2.5 V" -to usr_sw[0] -disable
set_location_assignment PIN_W32 -to comp_cycle -disable
set_instance_assignment -name IO_STANDARD "2.5 V" -to comp_cycle -disable
set_instance_assignment -name IO_STANDARD HCSL -to "refclk(n)"
set_instance_assignment -name IO_STANDARD LVDS -to "free_100MHz(n)"
set_instance_assignment -name IO_STANDARD "1.4-V PCML" -to "rx_in0(n)"
set_instance_assignment -name IO_STANDARD "1.4-V PCML" -to "rx_in1(n)"
set_instance_assignment -name IO_STANDARD "1.4-V PCML" -to "rx_in2(n)"
set_instance_assignment -name IO_STANDARD "1.4-V PCML" -to "rx_in3(n)"
set_instance_assignment -name IO_STANDARD "1.4-V PCML" -to "rx_in4(n)"
set_instance_assignment -name IO_STANDARD "1.4-V PCML" -to "rx_in5(n)"
set_instance_assignment -name IO_STANDARD "1.4-V PCML" -to "rx_in6(n)"
set_instance_assignment -name IO_STANDARD "1.4-V PCML" -to "rx_in7(n)"
set_instance_assignment -name IO_STANDARD "1.4-V PCML" -to "tx_out0(n)"
set_instance_assignment -name IO_STANDARD "1.4-V PCML" -to "tx_out1(n)"
set_instance_assignment -name IO_STANDARD "1.4-V PCML" -to "tx_out2(n)"
set_instance_assignment -name IO_STANDARD "1.4-V PCML" -to "tx_out3(n)"
set_instance_assignment -name IO_STANDARD "1.4-V PCML" -to "tx_out4(n)"
set_instance_assignment -name IO_STANDARD "1.4-V PCML" -to "tx_out5(n)"
set_instance_assignment -name IO_STANDARD "1.4-V PCML" -to "tx_out6(n)"
set_instance_assignment -name IO_STANDARD "1.4-V PCML" -to "tx_out7(n)"
set_instance_assignment -name INPUT_TERMINATION OFF -to refclk
set_instance_assignment -name PARTITION_HIERARCHY root_partition -to | -section_id Top
