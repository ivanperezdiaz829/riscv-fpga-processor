onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {Testbench signals}
add wave -noupdate -format Logic /tb_asi_mc/refclk
add wave -noupdate -format Logic /tb_asi_mc/refclk_source
add wave -noupdate -format Logic /tb_asi_mc/rst
add wave -noupdate -format Logic /tb_asi_mc/asi_test_tx
add wave -noupdate -format Logic /tb_asi_mc/asi_rx
add wave -noupdate -format Logic /tb_asi_mc/rxdata_valid
add wave -noupdate -format Literal /tb_asi_mc/random_delay
add wave -noupdate -format Literal /tb_asi_mc/random_delay_temp
add wave -noupdate -format Literal /tb_asi_mc/gen_dat
add wave -noupdate -format Logic /tb_asi_mc/gen_ena
add wave -noupdate -format Literal /tb_asi_mc/rx_data
add wave -noupdate -format Literal /tb_asi_mc/rx_ts_status
add wave -noupdate -format Logic /tb_asi_mc/rxclk
add wave -noupdate -format Logic /tb_asi_mc/check_error
add wave -noupdate -divider {ASI transmit}
add wave -noupdate -format Logic /tb_asi_mc/u_tx/rst
add wave -noupdate -format Logic /tb_asi_mc/u_tx/tx_refclk
add wave -noupdate -format Literal /tb_asi_mc/u_tx/tx_data
add wave -noupdate -format Literal /tb_asi_mc/u_rx/rx_data
add wave -noupdate -format Logic /tb_asi_mc/u_tx/tx_en
add wave -noupdate -format Logic /tb_asi_mc/u_tx/asi_tx
add wave -noupdate -divider {ASI receiver}
add wave -noupdate -format Logic /tb_asi_mc/u_rx/asi_rx
add wave -noupdate -format Logic /tb_asi_mc/u_rx/rst
add wave -noupdate -format Literal /tb_asi_mc/u_rx/rx_data
add wave -noupdate -format Logic /tb_asi_mc/u_rx/rx_data_clk
add wave -noupdate -format Literal /tb_asi_mc/u_rx/rx_ts_status
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {8170450 ps} 0}
configure wave -namecolwidth 239
configure wave -valuecolwidth 195
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
update
WaveRestoreZoom {7854785 ps} {8308651 ps}
