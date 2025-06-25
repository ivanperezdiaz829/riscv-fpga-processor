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
add wave -noupdate -divider {SDI DU}
add wave -noupdate -radix hexadecimal /tb_sdi_megacore_top/u_sdi_tr_du/en_sync_switch
add wave -noupdate -radix hexadecimal /tb_sdi_megacore_top/u_sdi_tr_du/enable_3g_search
add wave -noupdate -radix hexadecimal /tb_sdi_megacore_top/u_sdi_tr_du/enable_crc
add wave -noupdate -radix hexadecimal /tb_sdi_megacore_top/u_sdi_tr_du/enable_hd_search
add wave -noupdate -radix hexadecimal /tb_sdi_megacore_top/u_sdi_tr_du/enable_ln
add wave -noupdate -radix hexadecimal /tb_sdi_megacore_top/u_sdi_tr_du/enable_sd_search
add wave -noupdate -radix hexadecimal /tb_sdi_megacore_top/u_sdi_tr_du/gxb4_cal_clk
add wave -noupdate -radix hexadecimal /tb_sdi_megacore_top/u_sdi_tr_du/gxb_tx_clkout
add wave -noupdate -radix hexadecimal /tb_sdi_megacore_top/u_sdi_tr_du/refclk_rate
add wave -noupdate -radix hexadecimal /tb_sdi_megacore_top/u_sdi_tr_du/rst_rx
add wave -noupdate -radix hexadecimal /tb_sdi_megacore_top/u_sdi_tr_du/rst_tx
add wave -noupdate -radix hexadecimal /tb_sdi_megacore_top/u_sdi_tr_du/rx_anc_data
add wave -noupdate -radix hexadecimal /tb_sdi_megacore_top/u_sdi_tr_du/rx_anc_error
add wave -noupdate -radix hexadecimal /tb_sdi_megacore_top/u_sdi_tr_du/rx_anc_valid
add wave -noupdate -radix hexadecimal /tb_sdi_megacore_top/u_sdi_tr_du/rx_clk
add wave -noupdate -radix hexadecimal /tb_sdi_megacore_top/u_sdi_tr_du/rx_data_valid_out
add wave -noupdate -radix hexadecimal /tb_sdi_megacore_top/u_sdi_tr_du/rx_eav
add wave -noupdate -radix hexadecimal /tb_sdi_megacore_top/u_sdi_tr_du/rx_serial_refclk
add wave -noupdate -radix hexadecimal -childformat {{{/tb_sdi_megacore_top/u_sdi_tr_du/rx_status[10]} -radix hexadecimal} {{/tb_sdi_megacore_top/u_sdi_tr_du/rx_status[9]} -radix hexadecimal} {{/tb_sdi_megacore_top/u_sdi_tr_du/rx_status[8]} -radix hexadecimal} {{/tb_sdi_megacore_top/u_sdi_tr_du/rx_status[7]} -radix hexadecimal} {{/tb_sdi_megacore_top/u_sdi_tr_du/rx_status[6]} -radix hexadecimal} {{/tb_sdi_megacore_top/u_sdi_tr_du/rx_status[5]} -radix hexadecimal} {{/tb_sdi_megacore_top/u_sdi_tr_du/rx_status[4]} -radix hexadecimal} {{/tb_sdi_megacore_top/u_sdi_tr_du/rx_status[3]} -radix hexadecimal} {{/tb_sdi_megacore_top/u_sdi_tr_du/rx_status[2]} -radix hexadecimal} {{/tb_sdi_megacore_top/u_sdi_tr_du/rx_status[1]} -radix hexadecimal} {{/tb_sdi_megacore_top/u_sdi_tr_du/rx_status[0]} -radix hexadecimal}} -subitemconfig {{/tb_sdi_megacore_top/u_sdi_tr_du/rx_status[10]} {-radix hexadecimal} {/tb_sdi_megacore_top/u_sdi_tr_du/rx_status[9]} {-radix hexadecimal} {/tb_sdi_megacore_top/u_sdi_tr_du/rx_status[8]} {-radix hexadecimal} {/tb_sdi_megacore_top/u_sdi_tr_du/rx_status[7]} {-radix hexadecimal} {/tb_sdi_megacore_top/u_sdi_tr_du/rx_status[6]} {-radix hexadecimal} {/tb_sdi_megacore_top/u_sdi_tr_du/rx_status[5]} {-radix hexadecimal} {/tb_sdi_megacore_top/u_sdi_tr_du/rx_status[4]} {-radix hexadecimal} {/tb_sdi_megacore_top/u_sdi_tr_du/rx_status[3]} {-radix hexadecimal} {/tb_sdi_megacore_top/u_sdi_tr_du/rx_status[2]} {-radix hexadecimal} {/tb_sdi_megacore_top/u_sdi_tr_du/rx_status[1]} {-radix hexadecimal} {/tb_sdi_megacore_top/u_sdi_tr_du/rx_status[0]} {-radix hexadecimal}} /tb_sdi_megacore_top/u_sdi_tr_du/rx_status
add wave -noupdate -radix hexadecimal /tb_sdi_megacore_top/u_sdi_tr_du/rx_std
add wave -noupdate -radix hexadecimal /tb_sdi_megacore_top/u_sdi_tr_du/rx_std_flag_hd_sdn
add wave -noupdate -radix hexadecimal /tb_sdi_megacore_top/u_sdi_tr_du/rx_trs
add wave -noupdate -radix hexadecimal /tb_sdi_megacore_top/u_sdi_tr_du/rx_video_format
add wave -noupdate -radix hexadecimal /tb_sdi_megacore_top/u_sdi_tr_du/rx_xyz
add wave -noupdate -radix hexadecimal /tb_sdi_megacore_top/u_sdi_tr_du/rxdata
add wave -noupdate -radix hexadecimal /tb_sdi_megacore_top/u_sdi_tr_du/sdi_gxb_powerdown
add wave -noupdate -radix hexadecimal /tb_sdi_megacore_top/u_sdi_tr_du/sdi_reconfig_clk
add wave -noupdate -radix hexadecimal /tb_sdi_megacore_top/u_sdi_tr_du/sdi_reconfig_done
add wave -noupdate -radix hexadecimal /tb_sdi_megacore_top/u_sdi_tr_du/sdi_reconfig_fromgxb
add wave -noupdate -radix hexadecimal /tb_sdi_megacore_top/u_sdi_tr_du/sdi_reconfig_togxb
add wave -noupdate -radix hexadecimal /tb_sdi_megacore_top/u_sdi_tr_du/sdi_rx
add wave -noupdate -radix hexadecimal /tb_sdi_megacore_top/u_sdi_tr_du/sdi_start_reconfig
add wave -noupdate -radix hexadecimal /tb_sdi_megacore_top/u_sdi_tr_du/sdi_tx
add wave -noupdate -radix hexadecimal /tb_sdi_megacore_top/u_sdi_tr_du/tx_ln
add wave -noupdate -radix hexadecimal /tb_sdi_megacore_top/u_sdi_tr_du/tx_pclk
add wave -noupdate -radix hexadecimal /tb_sdi_megacore_top/u_sdi_tr_du/tx_serial_refclk
add wave -noupdate -radix hexadecimal /tb_sdi_megacore_top/u_sdi_tr_du/tx_status
add wave -noupdate -radix hexadecimal /tb_sdi_megacore_top/u_sdi_tr_du/tx_std
add wave -noupdate -radix hexadecimal /tb_sdi_megacore_top/u_sdi_tr_du/tx_trs
add wave -noupdate -radix hexadecimal /tb_sdi_megacore_top/u_sdi_tr_du/txdata
add wave -noupdate -radix hexadecimal /tb_sdi_megacore_top/u_sdi_tr_du/xyz_valid
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
