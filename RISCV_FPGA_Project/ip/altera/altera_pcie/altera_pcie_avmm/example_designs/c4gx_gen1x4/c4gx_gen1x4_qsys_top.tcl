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


# (C) 2001-2011 Altera Corporation. All rights reserved.
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

set_global_assignment -name FAMILY "Cyclone IV GX"
set_global_assignment -name DEVICE EP4CGX150DF31C7
set_global_assignment -name TOP_LEVEL_ENTITY c4gx_gen1x4_qsys_top
set_global_assignment -name VERILOG_FILE c4gx_gen1x4_qsys_top.v
set_global_assignment -name VERILOG_FILE altgxb_reconfig.v
set_global_assignment -name VERILOG_FILE gpll.v
set_global_assignment -name SDC_FILE c4gx_gen1x4_qsys_top.sdc
set_global_assignment -name QIP_FILE hip_c4gx_gen1x4_qsys/synthesis/hip_c4gx_gen1x4_qsys.qip
set_global_assignment -name CYCLONEII_OPTIMIZATION_TECHNIQUE SPEED
set_global_assignment -name SYNTH_TIMING_DRIVEN_SYNTHESIS ON
set_global_assignment -name OPTIMIZE_HOLD_TIMING "ALL PATHS"
set_global_assignment -name OPTIMIZE_MULTI_CORNER_TIMING ON
set_global_assignment -name OPTIMIZE_POWER_DURING_FITTING OFF
set_global_assignment -name RESERVE_ALL_UNUSED_PINS_WEAK_PULLUP "AS INPUT TRI-STATED"
set_global_assignment -name SMART_RECOMPILE ON
set_global_assignment -name OPTIMIZE_POWER_DURING_SYNTHESIS OFF
set_global_assignment -name FITTER_EFFORT "STANDARD FIT"
set_global_assignment -name PHYSICAL_SYNTHESIS_EFFORT NORMAL
set_global_assignment -name PHYSICAL_SYNTHESIS_COMBO_LOGIC ON
set_global_assignment -name PHYSICAL_SYNTHESIS_REGISTER_RETIMING ON
set_global_assignment -name PHYSICAL_SYNTHESIS_ASYNCHRONOUS_SIGNAL_PIPELINING ON
set_global_assignment -name PHYSICAL_SYNTHESIS_REGISTER_DUPLICATION ON
set_global_assignment -name PHYSICAL_SYNTHESIS_COMBO_LOGIC_FOR_AREA OFF


#--------------------------------------------------------------#
#
#  C4GX dev kit board pin assignments
#
set_global_assignment -name ACTIVE_SERIAL_CLOCK FREQ_40MHZ
set_global_assignment -name USE_CONFIGURATION_DEVICE OFF
set_instance_assignment -name CLOCK_SETTINGS refclk -to refclk
set_instance_assignment -name INPUT_TERMINATION OFF -to refclk

set_location_assignment PIN_AC2 -to rx_in0
set_location_assignment PIN_AB4 -to tx_out0
set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to rx_in0
set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to tx_out0
set_instance_assignment -name INPUT_TERMINATION DIFFERENTIAL -to rx_in0 -entity top -disable

set_instance_assignment -name IO_STANDARD "2.5 V" -to pcie_rstn
set_location_assignment PIN_A7 -to pcie_rstn
set_instance_assignment -name IO_STANDARD "2.5 V" -to local_rstn_ext -disable
set_location_assignment PIN_C12 -to local_rstn_ext -disable

set_instance_assignment -name IO_STANDARD HCSL -to refclk
set_instance_assignment -name INPUT_TERMINATION DIFFERENTIAL -to refclk -entity top -disable
set_location_assignment PIN_V15 -to refclk

set_location_assignment PIN_E4 -to L0_led -disable
set_instance_assignment -name IO_STANDARD "2.5 V" -to L0_led -disable
set_location_assignment PIN_C7 -to alive_led -disable
set_instance_assignment -name IO_STANDARD "2.5 V" -to alive_led -disable
set_location_assignment PIN_F4 -to comp_led -disable
set_instance_assignment -name IO_STANDARD "2.5 V" -to comp_led -disable

set_instance_assignment -name IO_STANDARD "2.5 V" -to usr_sw -disable
set_location_assignment PIN_D14 -to usr_sw[0] -disable
set_location_assignment PIN_A10 -to usr_sw[1] -disable

set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to rx_in1
set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to rx_in2
set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to rx_in3
set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to tx_out1
set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to tx_out2
set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to tx_out3
set_location_assignment PIN_W15 -to "refclk(n)"
set_location_assignment PIN_AC1 -to "rx_in0(n)"
set_location_assignment PIN_AA2 -to rx_in1
set_location_assignment PIN_AA1 -to "rx_in1(n)"
set_location_assignment PIN_W2 -to rx_in2
set_location_assignment PIN_W1 -to "rx_in2(n)"
set_location_assignment PIN_U2 -to rx_in3
set_location_assignment PIN_U1 -to "rx_in3(n)"
set_location_assignment PIN_AB3 -to "tx_out0(n)"
set_location_assignment PIN_V4 -to tx_out2
set_location_assignment PIN_V3 -to "tx_out2(n)"
set_location_assignment PIN_T4 -to tx_out3
set_location_assignment PIN_T3 -to "tx_out3(n)"
set_location_assignment PIN_Y4 -to tx_out1
set_global_assignment -name STRATIX_DEVICE_IO_STANDARD "2.5 V"
set_instance_assignment -name IO_STANDARD HCSL -to "refclk(n)"
set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to "rx_in0(n)"
set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to "rx_in1(n)"
set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to "rx_in2(n)"
set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to "rx_in3(n)"
set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to "tx_out0(n)"
set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to "tx_out2(n)"
set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to "tx_out3(n)"
set_location_assignment PIN_Y3 -to "tx_out1(n)"
set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to "tx_out1(n)"
set_location_assignment PIN_AJ16 -to free_50MHz
set_instance_assignment -name IO_STANDARD LVDS -to free_50MHz
set_location_assignment PIN_AK16 -to "free_50MHz(n)"

