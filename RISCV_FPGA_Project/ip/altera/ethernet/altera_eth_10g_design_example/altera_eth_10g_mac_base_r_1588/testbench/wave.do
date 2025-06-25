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


quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {Clock & Reset}
add wave -noupdate -radix hexadecimal /tb_top/DUT/ref_clk_clk
add wave -noupdate -radix hexadecimal /tb_top/DUT/csr_clk_clk
add wave -noupdate -radix hexadecimal /tb_top/DUT/xgmii_rx_clk_clk
add wave -noupdate -radix hexadecimal /tb_top/DUT/ref_reset_reset_n
add wave -noupdate -divider {Avalon-MM CSR}
add wave -noupdate -radix hexadecimal /tb_top/DUT/csr_address
add wave -noupdate -radix hexadecimal /tb_top/DUT/csr_read
add wave -noupdate -radix hexadecimal /tb_top/DUT/csr_readdata
add wave -noupdate -radix hexadecimal /tb_top/DUT/csr_write
add wave -noupdate -radix hexadecimal /tb_top/DUT/csr_writedata
add wave -noupdate -radix hexadecimal /tb_top/DUT/csr_waitrequest
add wave -noupdate -divider Configuration
add wave -noupdate -radix hexadecimal /tb_top/DUT/clock_operation_mode_mode
add wave -noupdate -radix hexadecimal /tb_top/DUT/pkt_with_crc_mode
add wave -noupdate -divider {Avalon-ST TX Packet & Status}
add wave -noupdate -radix hexadecimal /tb_top/DUT/avalon_st_tx_valid
add wave -noupdate -radix hexadecimal /tb_top/DUT/avalon_st_tx_ready
add wave -noupdate -radix hexadecimal /tb_top/DUT/avalon_st_tx_startofpacket
add wave -noupdate -radix hexadecimal /tb_top/DUT/avalon_st_tx_endofpacket
add wave -noupdate -radix hexadecimal /tb_top/DUT/avalon_st_tx_empty
add wave -noupdate -radix hexadecimal /tb_top/DUT/avalon_st_tx_data
add wave -noupdate -radix hexadecimal /tb_top/DUT/avalon_st_tx_error
add wave -noupdate -radix hexadecimal /tb_top/DUT/avalon_st_txstatus_valid
add wave -noupdate -radix hexadecimal /tb_top/DUT/avalon_st_txstatus_data
add wave -noupdate -radix hexadecimal /tb_top/DUT/avalon_st_txstatus_error
add wave -noupdate -divider {Avalon-ST RX Packet & Status}
add wave -noupdate -radix hexadecimal /tb_top/DUT/avalon_st_rx_valid
add wave -noupdate -radix hexadecimal /tb_top/DUT/avalon_st_rx_ready
add wave -noupdate -radix hexadecimal /tb_top/DUT/avalon_st_rx_startofpacket
add wave -noupdate -radix hexadecimal /tb_top/DUT/avalon_st_rx_endofpacket
add wave -noupdate -radix hexadecimal /tb_top/DUT/avalon_st_rx_empty
add wave -noupdate -radix hexadecimal /tb_top/DUT/avalon_st_rx_data
add wave -noupdate -radix hexadecimal /tb_top/DUT/avalon_st_rx_error
add wave -noupdate -radix hexadecimal /tb_top/DUT/avalon_st_rxstatus_valid
add wave -noupdate -radix hexadecimal /tb_top/DUT/avalon_st_rxstatus_data
add wave -noupdate -radix hexadecimal /tb_top/DUT/avalon_st_rxstatus_error
add wave -noupdate -divider {MAC Flow Control}
add wave -noupdate -radix hexadecimal /tb_top/DUT/avalon_st_pause_data
add wave -noupdate -divider {TX Egress Timestamp Request}
add wave -noupdate -radix hexadecimal /tb_top/DUT/tx_egress_timestamp_request_valid
add wave -noupdate -radix hexadecimal /tb_top/DUT/tx_egress_timestamp_request_fingerprint
add wave -noupdate -divider {Channel-0: TX Ingress Timestamp}
add wave -noupdate -radix hexadecimal /tb_top/DUT/tx_estamp_ins_ctrl_residence_time_update
add wave -noupdate -radix hexadecimal /tb_top/DUT/tx_estamp_ins_ctrl_ingress_timestamp_96b
add wave -noupdate -radix hexadecimal /tb_top/DUT/tx_estamp_ins_ctrl_ingress_timestamp_64b
add wave -noupdate -radix hexadecimal /tb_top/DUT/tx_estamp_ins_ctrl_residence_time_calc_format
add wave -noupdate -divider {TX Egress Timestamp}
add wave -noupdate -radix hexadecimal /tb_top/DUT/tx_egress_timestamp_96b_valid
add wave -noupdate -radix hexadecimal /tb_top/DUT/tx_egress_timestamp_96b_data
add wave -noupdate -radix hexadecimal /tb_top/DUT/tx_egress_timestamp_96b_fingerprint
add wave -noupdate -radix hexadecimal /tb_top/DUT/tx_egress_timestamp_64b_valid
add wave -noupdate -radix hexadecimal /tb_top/DUT/tx_egress_timestamp_64b_data
add wave -noupdate -radix hexadecimal /tb_top/DUT/tx_egress_timestamp_64b_fingerprint
add wave -noupdate -divider {RX Ingress Timestamp}
add wave -noupdate -radix hexadecimal /tb_top/DUT/rx_ingress_timestamp_96b_valid
add wave -noupdate -radix hexadecimal /tb_top/DUT/rx_ingress_timestamp_96b_data
add wave -noupdate -radix hexadecimal /tb_top/DUT/rx_ingress_timestamp_64b_valid
add wave -noupdate -radix hexadecimal /tb_top/DUT/rx_ingress_timestamp_64b_data
add wave -noupdate -divider {Pulse-per-second}
add wave -noupdate -radix hexadecimal /tb_top/DUT/pps_10g_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {4038401 ps} 0}
configure wave -namecolwidth 315
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
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
WaveRestoreZoom {0 ps} {14160401 ps}
