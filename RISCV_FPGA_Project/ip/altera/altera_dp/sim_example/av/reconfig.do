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


onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /av_dp_harness/dut/xcvr_mgmt_clk
add wave -noupdate /av_dp_harness/dut/rx_link_rate
add wave -noupdate /av_dp_harness/dut/rx_reconfig_req
add wave -noupdate /av_dp_harness/dut/rx_reconfig_ack
add wave -noupdate /av_dp_harness/dut/rx_reconfig_busy
add wave -noupdate /av_dp_harness/dut/tx_link_rate
add wave -noupdate /av_dp_harness/dut/tx_reconfig_req
add wave -noupdate /av_dp_harness/dut/tx_reconfig_ack
add wave -noupdate /av_dp_harness/dut/tx_reconfig_busy
add wave -noupdate -radix hexadecimal /av_dp_harness/dut/tx_vod
add wave -noupdate -radix hexadecimal /av_dp_harness/dut/tx_emp
add wave -noupdate /av_dp_harness/dut/tx_analog_reconfig_req
add wave -noupdate /av_dp_harness/dut/tx_analog_reconfig_ack
add wave -noupdate /av_dp_harness/dut/tx_analog_reconfig_busy
add wave -noupdate /av_dp_harness/dut/reconfig/reconfig_busy
add wave -noupdate -radix hexadecimal /av_dp_harness/dut/reconfig/reconfig_mgmt_address
add wave -noupdate /av_dp_harness/dut/reconfig/reconfig_mgmt_write
add wave -noupdate -radix hexadecimal /av_dp_harness/dut/reconfig/reconfig_mgmt_writedata
add wave -noupdate /av_dp_harness/dut/reconfig/reconfig_mgmt_waitrequest
add wave -noupdate /av_dp_harness/dut/reconfig/reconfig_mgmt_read
add wave -noupdate -radix hexadecimal /av_dp_harness/dut/reconfig/reconfig_mgmt_readdata
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 370
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {2084370750 ps}
