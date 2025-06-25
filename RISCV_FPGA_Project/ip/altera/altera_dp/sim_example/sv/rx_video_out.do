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
add wave -noupdate /sv_dp_harness/dut/rx_vid_clk
add wave -noupdate /sv_dp_harness/dut/rx_vid_valid
add wave -noupdate /sv_dp_harness/dut/rx_vid_sol
add wave -noupdate /sv_dp_harness/dut/rx_vid_eol
add wave -noupdate /sv_dp_harness/dut/rx_vid_sof
add wave -noupdate /sv_dp_harness/dut/rx_vid_eof
add wave -noupdate -radix hexadecimal /sv_dp_harness/dut/rx_vid_data
add wave -noupdate /sv_dp_harness/rx_cvi_datavalid
add wave -noupdate /sv_dp_harness/rx_cvi_f
add wave -noupdate /sv_dp_harness/rx_cvi_h_sync
add wave -noupdate /sv_dp_harness/rx_cvi_v_sync
add wave -noupdate /sv_dp_harness/rx_cvi_locked
add wave -noupdate /sv_dp_harness/rx_cvi_de
add wave -noupdate /sv_dp_harness/rx_cvi_data
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1113548999 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 358
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
WaveRestoreZoom {1111974818 ps} {1115218082 ps}
