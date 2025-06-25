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
add wave -noupdate -divider {Clock & Reset}
add wave -noupdate -radix hexadecimal -radixenum numeric /tb_sv/clk_50
add wave -noupdate -radix hexadecimal -radixenum numeric /tb_sv/reset
add wave -noupdate -divider {Avalon-MM CSR}
add wave -noupdate -radix hexadecimal -radixenum numeric /tb_sv/avalon_mm_csr_clk
add wave -noupdate -radix hexadecimal -radixenum numeric /tb_sv/avalon_mm_csr_address
add wave -noupdate -radix hexadecimal -radixenum numeric /tb_sv/avalon_mm_csr_read
add wave -noupdate -radix hexadecimal -radixenum numeric /tb_sv/avalon_mm_csr_readdata
add wave -noupdate -radix hexadecimal -radixenum numeric /tb_sv/avalon_mm_csr_write
add wave -noupdate -radix hexadecimal -radixenum numeric /tb_sv/avalon_mm_csr_writedata
add wave -noupdate -radix hexadecimal -radixenum numeric /tb_sv/avalon_mm_csr_waitrequest
add wave -noupdate /tb_sv/rx_data_ready
add wave -noupdate /tb_sv/rx_pma_ready
add wave -noupdate /tb_sv/tx_pma_ready
add wave -noupdate -divider {Avalon-ST RX}
add wave -noupdate -radix hexadecimal -radixenum numeric /tb_sv/avalon_st_rx_clk
add wave -noupdate -radix hexadecimal -radixenum numeric /tb_sv/avalon_st_rx_ready
add wave -noupdate -radix hexadecimal -radixenum numeric /tb_sv/avalon_st_rx_valid
add wave -noupdate -radix hexadecimal -radixenum numeric /tb_sv/avalon_st_rx_startofpacket
add wave -noupdate -radix hexadecimal -radixenum numeric /tb_sv/avalon_st_rx_endofpacket
add wave -noupdate -radix hexadecimal -radixenum numeric /tb_sv/avalon_st_rx_data
add wave -noupdate -radix hexadecimal -radixenum numeric /tb_sv/avalon_st_rx_empty
add wave -noupdate -radix hexadecimal -radixenum numeric /tb_sv/avalon_st_rx_error
add wave -noupdate -divider {Avalon-ST TX}
add wave -noupdate -radix hexadecimal -radixenum numeric /tb_sv/avalon_st_tx_clk
add wave -noupdate -radix hexadecimal -radixenum numeric /tb_sv/avalon_st_tx_ready
add wave -noupdate -radix hexadecimal -radixenum numeric /tb_sv/avalon_st_tx_valid
add wave -noupdate -radix hexadecimal -radixenum numeric /tb_sv/avalon_st_tx_startofpacket
add wave -noupdate -radix hexadecimal -radixenum numeric /tb_sv/avalon_st_tx_endofpacket
add wave -noupdate -radix hexadecimal -radixenum numeric /tb_sv/avalon_st_tx_data
add wave -noupdate -radix hexadecimal -radixenum numeric /tb_sv/avalon_st_tx_empty
add wave -noupdate -radix hexadecimal -radixenum numeric /tb_sv/avalon_st_tx_error
add wave -noupdate -divider {BASE-R RX}
add wave -noupdate -radix hexadecimal -radixenum numeric /tb_sv/base_r_rx_data
add wave -noupdate -divider {BASE-R TX}
add wave -noupdate -radix hexadecimal -radixenum numeric /tb_sv/base_r_tx_data
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {5749072 ps} 0}
configure wave -namecolwidth 246
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
WaveRestoreZoom {5282159 ps} {6183715 ps}
