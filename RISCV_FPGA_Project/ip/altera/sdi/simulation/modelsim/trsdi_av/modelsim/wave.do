onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider RECONFIG
add wave -noupdate -radix hexadecimal /tb_sdi_megacore_top/sdi_tr_reconfig_multi_inst/rst
add wave -noupdate -radix hexadecimal /tb_sdi_megacore_top/sdi_tr_reconfig_multi_inst/write_ctrl
add wave -noupdate -radix hexadecimal /tb_sdi_megacore_top/sdi_tr_reconfig_multi_inst/rx_std_ch0
add wave -noupdate -radix hexadecimal /tb_sdi_megacore_top/sdi_tr_reconfig_multi_inst/rx_std_ch1
add wave -noupdate -radix hexadecimal /tb_sdi_megacore_top/sdi_tr_reconfig_multi_inst/rx_std_ch2
add wave -noupdate -radix hexadecimal /tb_sdi_megacore_top/sdi_tr_reconfig_multi_inst/rx_std_ch3
add wave -noupdate -radix hexadecimal /tb_sdi_megacore_top/sdi_tr_reconfig_multi_inst/reconfig_clk
add wave -noupdate -radix hexadecimal /tb_sdi_megacore_top/sdi_tr_reconfig_multi_inst/reconfig_fromgxb
add wave -noupdate -radix hexadecimal /tb_sdi_megacore_top/sdi_tr_reconfig_multi_inst/sdi_reconfig_done
add wave -noupdate -radix hexadecimal /tb_sdi_megacore_top/sdi_tr_reconfig_multi_inst/reconfig_togxb
add wave -noupdate -radix hexadecimal /tb_sdi_megacore_top/sdi_tr_reconfig_multi_inst/reconfig_busy
add wave -noupdate -radix hexadecimal /tb_sdi_megacore_top/sdi_tr_reconfig_multi_inst/reconfig_reset
add wave -noupdate -radix hexadecimal /tb_sdi_megacore_top/sdi_tr_reconfig_multi_inst/override_hd_data
add wave -noupdate -radix hexadecimal /tb_sdi_megacore_top/sdi_tr_reconfig_multi_inst/readdata
add wave -noupdate -radix hexadecimal /tb_sdi_megacore_top/sdi_tr_reconfig_multi_inst/reconfig_mgmt_address
add wave -noupdate -radix hexadecimal /tb_sdi_megacore_top/sdi_tr_reconfig_multi_inst/reconfig_mgmt_read
add wave -noupdate -radix hexadecimal /tb_sdi_megacore_top/sdi_tr_reconfig_multi_inst/reconfig_mgmt_write
add wave -noupdate -radix hexadecimal /tb_sdi_megacore_top/sdi_tr_reconfig_multi_inst/reconfig_mgmt_writedata
add wave -noupdate -radix hexadecimal /tb_sdi_megacore_top/sdi_tr_reconfig_multi_inst/reconfig_mgmt_waitrequest
add wave -noupdate -radix hexadecimal /tb_sdi_megacore_top/sdi_tr_reconfig_multi_inst/reconfig_mgmt_readdata
add wave -noupdate -radix hexadecimal /tb_sdi_megacore_top/sdi_tr_reconfig_multi_inst/wdata
add wave -noupdate -radix hexadecimal /tb_sdi_megacore_top/sdi_tr_reconfig_multi_inst/write
add wave -noupdate -divider {SDI TX}
add wave -noupdate -radix hexadecimal /tb_sdi_megacore_top/u_sdi_tr_tx/rst_tx
add wave -noupdate -radix hexadecimal /tb_sdi_megacore_top/u_sdi_tr_tx/tx_pclk
add wave -noupdate -radix hexadecimal /tb_sdi_megacore_top/u_sdi_tr_tx/tx_serial_refclk
add wave -noupdate -radix hexadecimal /tb_sdi_megacore_top/u_sdi_tr_tx/txdata
add wave -noupdate -radix hexadecimal /tb_sdi_megacore_top/u_sdi_tr_tx/tx_ln
add wave -noupdate -radix hexadecimal /tb_sdi_megacore_top/u_sdi_tr_tx/tx_trs
add wave -noupdate -radix hexadecimal /tb_sdi_megacore_top/u_sdi_tr_tx/enable_ln
add wave -noupdate -radix hexadecimal /tb_sdi_megacore_top/u_sdi_tr_tx/enable_crc
add wave -noupdate -radix hexadecimal /tb_sdi_megacore_top/u_sdi_tr_tx/gxb4_cal_clk
add wave -noupdate -radix hexadecimal /tb_sdi_megacore_top/u_sdi_tr_tx/tx_std
add wave -noupdate -radix hexadecimal /tb_sdi_megacore_top/u_sdi_tr_tx/sdi_tx
add wave -noupdate -radix hexadecimal /tb_sdi_megacore_top/u_sdi_tr_tx/tx_status
add wave -noupdate -divider {SDI RX}
add wave -noupdate -radix hexadecimal /tb_sdi_megacore_top/u_sdi_tr_rx/rst_rx
add wave -noupdate -radix hexadecimal /tb_sdi_megacore_top/u_sdi_tr_rx/rx_serial_refclk
add wave -noupdate -radix hexadecimal /tb_sdi_megacore_top/u_sdi_tr_rx/sdi_rx
add wave -noupdate -radix hexadecimal /tb_sdi_megacore_top/u_sdi_tr_rx/enable_hd_search
add wave -noupdate -radix hexadecimal /tb_sdi_megacore_top/u_sdi_tr_rx/enable_sd_search
add wave -noupdate -radix hexadecimal /tb_sdi_megacore_top/u_sdi_tr_rx/enable_3g_search
add wave -noupdate -radix hexadecimal /tb_sdi_megacore_top/u_sdi_tr_rx/gxb4_cal_clk
add wave -noupdate -radix hexadecimal /tb_sdi_megacore_top/u_sdi_tr_rx/sdi_reconfig_clk
add wave -noupdate -radix hexadecimal /tb_sdi_megacore_top/u_sdi_tr_rx/sdi_reconfig_togxb
add wave -noupdate -radix hexadecimal /tb_sdi_megacore_top/u_sdi_tr_rx/sdi_reconfig_done
add wave -noupdate -radix hexadecimal /tb_sdi_megacore_top/u_sdi_tr_rx/rxdata
add wave -noupdate -radix hexadecimal /tb_sdi_megacore_top/u_sdi_tr_rx/rx_F
add wave -noupdate -radix hexadecimal /tb_sdi_megacore_top/u_sdi_tr_rx/rx_V
add wave -noupdate -radix hexadecimal /tb_sdi_megacore_top/u_sdi_tr_rx/rx_H
add wave -noupdate -radix hexadecimal /tb_sdi_megacore_top/u_sdi_tr_rx/rx_AP
add wave -noupdate -radix hexadecimal /tb_sdi_megacore_top/u_sdi_tr_rx/rx_ln
add wave -noupdate -radix hexadecimal -childformat {{{/tb_sdi_megacore_top/u_sdi_tr_rx/rx_status[10]} -radix hexadecimal} {{/tb_sdi_megacore_top/u_sdi_tr_rx/rx_status[9]} -radix hexadecimal} {{/tb_sdi_megacore_top/u_sdi_tr_rx/rx_status[8]} -radix hexadecimal} {{/tb_sdi_megacore_top/u_sdi_tr_rx/rx_status[7]} -radix hexadecimal} {{/tb_sdi_megacore_top/u_sdi_tr_rx/rx_status[6]} -radix hexadecimal} {{/tb_sdi_megacore_top/u_sdi_tr_rx/rx_status[5]} -radix hexadecimal} {{/tb_sdi_megacore_top/u_sdi_tr_rx/rx_status[4]} -radix hexadecimal} {{/tb_sdi_megacore_top/u_sdi_tr_rx/rx_status[3]} -radix hexadecimal} {{/tb_sdi_megacore_top/u_sdi_tr_rx/rx_status[2]} -radix hexadecimal} {{/tb_sdi_megacore_top/u_sdi_tr_rx/rx_status[1]} -radix hexadecimal} {{/tb_sdi_megacore_top/u_sdi_tr_rx/rx_status[0]} -radix hexadecimal}} -subitemconfig {{/tb_sdi_megacore_top/u_sdi_tr_rx/rx_status[10]} {-radix hexadecimal} {/tb_sdi_megacore_top/u_sdi_tr_rx/rx_status[9]} {-radix hexadecimal} {/tb_sdi_megacore_top/u_sdi_tr_rx/rx_status[8]} {-radix hexadecimal} {/tb_sdi_megacore_top/u_sdi_tr_rx/rx_status[7]} {-radix hexadecimal} {/tb_sdi_megacore_top/u_sdi_tr_rx/rx_status[6]} {-radix hexadecimal} {/tb_sdi_megacore_top/u_sdi_tr_rx/rx_status[5]} {-radix hexadecimal} {/tb_sdi_megacore_top/u_sdi_tr_rx/rx_status[4]} {-radix hexadecimal} {/tb_sdi_megacore_top/u_sdi_tr_rx/rx_status[3]} {-radix hexadecimal} {/tb_sdi_megacore_top/u_sdi_tr_rx/rx_status[2]} {-radix hexadecimal} {/tb_sdi_megacore_top/u_sdi_tr_rx/rx_status[1]} {-radix hexadecimal} {/tb_sdi_megacore_top/u_sdi_tr_rx/rx_status[0]} {-radix hexadecimal}} /tb_sdi_megacore_top/u_sdi_tr_rx/rx_status
add wave -noupdate -radix hexadecimal /tb_sdi_megacore_top/u_sdi_tr_rx/rx_data_valid_out
add wave -noupdate -radix hexadecimal /tb_sdi_megacore_top/u_sdi_tr_rx/rx_clk
add wave -noupdate -radix hexadecimal /tb_sdi_megacore_top/u_sdi_tr_rx/sdi_reconfig_fromgxb
add wave -noupdate -radix hexadecimal /tb_sdi_megacore_top/u_sdi_tr_rx/sdi_start_reconfig
add wave -noupdate -radix hexadecimal /tb_sdi_megacore_top/u_sdi_tr_rx/rx_std
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2826646226381 fs} 0}
configure wave -namecolwidth 209
configure wave -valuecolwidth 50
configure wave -justifyvalue left
configure wave -signalnamewidth 2
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits fs
update
WaveRestoreZoom {0 fs} {7537723270350 fs}
