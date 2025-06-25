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


set_global_assignment -name FAMILY "Stratix V"
set_global_assignment -name DEVICE 5SGXEA7K2F40C2
set_global_assignment -name PROJECT_OUTPUT_DIRECTORY pcie_quartus_files
set_global_assignment -name MIN_CORE_JUNCTION_TEMP 0
set_global_assignment -name MAX_CORE_JUNCTION_TEMP 85
set_global_assignment -name TOP_LEVEL_ENTITY top_hw
set_global_assignment -name SMART_RECOMPILE ON
set_global_assignment -name OPTIMIZATION_TECHNIQUE SPEED
set_global_assignment -name FITTER_EFFORT "STANDARD FIT"
set_global_assignment -name SYNTH_TIMING_DRIVEN_SYNTHESIS ON
set_location_assignment PIN_AD34 -to "refclk1_ql0_p(n)"
set_location_assignment PIN_AD33 -to refclk1_ql0_p
set_location_assignment PIN_V35 -to "refclk4_ql2_p(n)"
set_location_assignment PIN_V34 -to refclk4_ql2_p
set_location_assignment PIN_T34 -to "refclk5_ql2_p(n)"
set_location_assignment PIN_T33 -to refclk5_ql2_p
set_location_assignment PIN_AF5 -to "refclk0_qr0_p(n)"
set_location_assignment PIN_AF6 -to refclk0_qr0_p
set_location_assignment PIN_AD6 -to "refclk1_qr0_p(n)"
set_location_assignment PIN_AD7 -to refclk1_qr0_p
set_location_assignment PIN_AB5 -to "refclk2_qr1_p(n)"
set_location_assignment PIN_AB6 -to refclk2_qr1_p
set_location_assignment PIN_V5 -to "refclk4_qr2_p(n)"
set_location_assignment PIN_V6 -to refclk4_qr2_p
set_location_assignment PIN_T6 -to "refclk5_qr2_p(n)"
set_location_assignment PIN_T7 -to refclk5_qr2_p
set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to refclk1_ql0_p
set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to refclk4_ql2_p
set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to refclk5_ql2_p
set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to refclk0_qr0_p
set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to refclk1_qr0_p
set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to refclk2_qr1_p
set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to refclk4_qr2_p
set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to refclk5_qr2_p
set_location_assignment PIN_AF35 -to "refclk_clk(n)"
set_location_assignment PIN_AF34 -to refclk_clk
set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to refclk_clk
set_location_assignment PIN_AH22 -to reconfig_xcvr_clk
set_instance_assignment -name IO_STANDARD LVDS -to reconfig_xcvr_clk
set_location_assignment PIN_AC28 -to perstn
set_instance_assignment -name IO_STANDARD "2.5 V" -to perstn
set_location_assignment PIN_A7 -to local_rstn
set_instance_assignment -name IO_STANDARD "1.5 V" -to local_rstn
set_location_assignment PIN_B7 -to req_compliance_pb
set_instance_assignment -name IO_STANDARD "1.5 V" -to req_compliance_pb
set_location_assignment PIN_E7 -to set_compliance_mode
set_instance_assignment -name IO_STANDARD "1.5 V" -to set_compliance_mode
set_location_assignment PIN_AV39 -to "hip_serial_rx_in0(n)"
set_location_assignment PIN_AV38 -to hip_serial_rx_in0
set_location_assignment PIN_AT39 -to "hip_serial_rx_in1(n)"
set_location_assignment PIN_AT38 -to hip_serial_rx_in1
set_location_assignment PIN_AP39 -to "hip_serial_rx_in2(n)"
set_location_assignment PIN_AP38 -to hip_serial_rx_in2
set_location_assignment PIN_AM39 -to "hip_serial_rx_in3(n)"
set_location_assignment PIN_AM38 -to hip_serial_rx_in3
set_location_assignment PIN_AH39 -to "hip_serial_rx_in4(n)"
set_location_assignment PIN_AH38 -to hip_serial_rx_in4
set_location_assignment PIN_AF39 -to "hip_serial_rx_in5(n)"
set_location_assignment PIN_AF38 -to hip_serial_rx_in5
set_location_assignment PIN_AD39 -to "hip_serial_rx_in6(n)"
set_location_assignment PIN_AD38 -to hip_serial_rx_in6
set_location_assignment PIN_AB39 -to "hip_serial_rx_in7(n)"
set_location_assignment PIN_AB38 -to hip_serial_rx_in7
set_location_assignment PIN_AU37 -to "hip_serial_tx_out0(n)"
set_location_assignment PIN_AU36 -to hip_serial_tx_out0
set_location_assignment PIN_AR37 -to "hip_serial_tx_out1(n)"
set_location_assignment PIN_AR36 -to hip_serial_tx_out1
set_location_assignment PIN_AN37 -to "hip_serial_tx_out2(n)"
set_location_assignment PIN_AN36 -to hip_serial_tx_out2
set_location_assignment PIN_AL37 -to "hip_serial_tx_out3(n)"
set_location_assignment PIN_AL36 -to hip_serial_tx_out3
set_location_assignment PIN_AG37 -to "hip_serial_tx_out4(n)"
set_location_assignment PIN_AG36 -to hip_serial_tx_out4
set_location_assignment PIN_AE37 -to "hip_serial_tx_out5(n)"
set_location_assignment PIN_AE36 -to hip_serial_tx_out5
set_location_assignment PIN_AC37 -to "hip_serial_tx_out6(n)"
set_location_assignment PIN_AC36 -to hip_serial_tx_out6
set_location_assignment PIN_AA37 -to "hip_serial_tx_out7(n)"
set_location_assignment PIN_AA36 -to hip_serial_tx_out7
set_location_assignment PIN_G9 -to hsma_clk_out_p2
set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to hip_serial_rx_in0
set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to hip_serial_rx_in1
set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to hip_serial_rx_in2
set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to hip_serial_rx_in3
set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to hip_serial_rx_in4
set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to hip_serial_rx_in5
set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to hip_serial_rx_in6
set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to hip_serial_rx_in7
set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to hip_serial_tx_out0
set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to hip_serial_tx_out1
set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to hip_serial_tx_out2
set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to hip_serial_tx_out3
set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to hip_serial_tx_out4
set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to hip_serial_tx_out5
set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to hip_serial_tx_out6
set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to hip_serial_tx_out7
set_location_assignment PIN_U10 -to alive_led
set_instance_assignment -name IO_STANDARD "2.5 V" -to alive_led
set_location_assignment PIN_J11 -to L0_led
set_instance_assignment -name IO_STANDARD "2.5 V" -to L0_led
set_location_assignment PIN_U9 -to comp_led
set_instance_assignment -name IO_STANDARD "2.5 V" -to comp_led
set_location_assignment PIN_AH28 -to gen2_led
set_instance_assignment -name IO_STANDARD "2.5 V" -to gen2_led
set_location_assignment PIN_AL7 -to gen3_led
set_instance_assignment -name IO_STANDARD "2.5 V" -to gen3_led
set_location_assignment PIN_AF28 -to lane_active_led[0]
set_instance_assignment -name IO_STANDARD "2.5 V" -to lane_active_led[0]
set_location_assignment PIN_AE29 -to lane_active_led[1]
set_instance_assignment -name IO_STANDARD "2.5 V" -to lane_active_led[1]
set_location_assignment PIN_AR7 -to lane_active_led[2]
set_instance_assignment -name IO_STANDARD "2.5 V" -to lane_active_led[2]
set_location_assignment PIN_AV10 -to lane_active_led[3]
set_instance_assignment -name IO_STANDARD "2.5 V" -to lane_active_led[3]
set_global_assignment -name VCCT_L_USER_VOLTAGE 1.0V
set_global_assignment -name VCCT_R_USER_VOLTAGE 1.0V
set_global_assignment -name VCCR_L_USER_VOLTAGE 1.0V
set_global_assignment -name VCCR_R_USER_VOLTAGE 1.0V
set_global_assignment -name VCCA_L_USER_VOLTAGE 3.0V
set_global_assignment -name VCCA_R_USER_VOLTAGE 3.0V
set_global_assignment -name POWER_HSSI_VCCHIP_LEFT "Opportunistically power off"
set_global_assignment -name POWER_HSSI_VCCHIP_RIGHT "Opportunistically power off"
set_global_assignment -name ENABLE_DRC_SETTINGS ON
set_global_assignment -name DISABLE_OCP_HW_EVAL ON
set_instance_assignment -name XCVR_VCCR_VCCT_VOLTAGE 1_0V -to "hip_serial_rx_in0(n)"
set_instance_assignment -name XCVR_VCCR_VCCT_VOLTAGE 1_0V -to hip_serial_rx_in0
set_instance_assignment -name XCVR_VCCR_VCCT_VOLTAGE 1_0V -to "hip_serial_rx_in1(n)"
set_instance_assignment -name XCVR_VCCR_VCCT_VOLTAGE 1_0V -to hip_serial_rx_in1
set_instance_assignment -name XCVR_VCCR_VCCT_VOLTAGE 1_0V -to "hip_serial_rx_in2(n)"
set_instance_assignment -name XCVR_VCCR_VCCT_VOLTAGE 1_0V -to hip_serial_rx_in2
set_instance_assignment -name XCVR_VCCR_VCCT_VOLTAGE 1_0V -to "hip_serial_rx_in3(n)"
set_instance_assignment -name XCVR_VCCR_VCCT_VOLTAGE 1_0V -to hip_serial_rx_in3
set_instance_assignment -name XCVR_VCCR_VCCT_VOLTAGE 1_0V -to "hip_serial_rx_in4(n)"
set_instance_assignment -name XCVR_VCCR_VCCT_VOLTAGE 1_0V -to hip_serial_rx_in4
set_instance_assignment -name XCVR_VCCR_VCCT_VOLTAGE 1_0V -to "hip_serial_rx_in5(n)"
set_instance_assignment -name XCVR_VCCR_VCCT_VOLTAGE 1_0V -to hip_serial_rx_in5
set_instance_assignment -name XCVR_VCCR_VCCT_VOLTAGE 1_0V -to "hip_serial_rx_in6(n)"
set_instance_assignment -name XCVR_VCCR_VCCT_VOLTAGE 1_0V -to hip_serial_rx_in6
set_instance_assignment -name XCVR_VCCR_VCCT_VOLTAGE 1_0V -to "hip_serial_rx_in7(n)"
set_instance_assignment -name XCVR_VCCR_VCCT_VOLTAGE 1_0V -to hip_serial_rx_in7
set_instance_assignment -name XCVR_VCCA_VOLTAGE 3_0V -to "hip_serial_rx_in0(n)"
set_instance_assignment -name XCVR_VCCA_VOLTAGE 3_0V -to hip_serial_rx_in0
set_instance_assignment -name XCVR_VCCA_VOLTAGE 3_0V -to "hip_serial_rx_in1(n)"
set_instance_assignment -name XCVR_VCCA_VOLTAGE 3_0V -to hip_serial_rx_in1
set_instance_assignment -name XCVR_VCCA_VOLTAGE 3_0V -to "hip_serial_rx_in2(n)"
set_instance_assignment -name XCVR_VCCA_VOLTAGE 3_0V -to hip_serial_rx_in2
set_instance_assignment -name XCVR_VCCA_VOLTAGE 3_0V -to "hip_serial_rx_in3(n)"
set_instance_assignment -name XCVR_VCCA_VOLTAGE 3_0V -to hip_serial_rx_in3
set_instance_assignment -name XCVR_VCCA_VOLTAGE 3_0V -to "hip_serial_rx_in4(n)"
set_instance_assignment -name XCVR_VCCA_VOLTAGE 3_0V -to hip_serial_rx_in4
set_instance_assignment -name XCVR_VCCA_VOLTAGE 3_0V -to "hip_serial_rx_in5(n)"
set_instance_assignment -name XCVR_VCCA_VOLTAGE 3_0V -to hip_serial_rx_in5
set_instance_assignment -name XCVR_VCCA_VOLTAGE 3_0V -to "hip_serial_rx_in6(n)"
set_instance_assignment -name XCVR_VCCA_VOLTAGE 3_0V -to hip_serial_rx_in6
set_instance_assignment -name XCVR_VCCA_VOLTAGE 3_0V -to "hip_serial_rx_in7(n)"
set_instance_assignment -name XCVR_VCCA_VOLTAGE 3_0V -to hip_serial_rx_in7
set_instance_assignment -name GLOBAL_SIGNAL "GLOBAL CLOCK" -to altera_internal_jtag~TCKUTAP
set_instance_assignment -name GLOBAL_SIGNAL "GLOBAL CLOCK" -to "sld_signaltap:auto_signaltap_0|sld_signaltap_impl:sld_signaltap_body|reset_all"

set_global_assignment -name ENABLE_SIGNALTAP OFF
set_global_assignment -name PARTITION_NETLIST_TYPE SOURCE -section_id Top
set_global_assignment -name PARTITION_FITTER_PRESERVATION_LEVEL PLACEMENT_AND_ROUTING -section_id Top
set_global_assignment -name PARTITION_COLOR 16764057 -section_id Top
set_global_assignment -name TIMEQUEST_DO_CCPP_REMOVAL ON
set_global_assignment -name OPTIMIZE_HOLD_TIMING "ALL PATHS"
set_global_assignment -name OPTIMIZE_MULTI_CORNER_TIMING ON


set_global_assignment -name QIP_FILE top/synthesis/top.qip
set_global_assignment -name SDC_FILE top_hw.sdc
set_global_assignment -name SDC_FILE run_me_first.sdc
set_global_assignment -name POWER_PRESET_COOLING_SOLUTION "23 MM HEAT SINK WITH 200 LFPM AIRFLOW"
set_global_assignment -name POWER_BOARD_THERMAL_MODEL "NONE (CONSERVATIVE)"



set_instance_assignment -name PARTITION_HIERARCHY root_partition -to | -section_id Top
