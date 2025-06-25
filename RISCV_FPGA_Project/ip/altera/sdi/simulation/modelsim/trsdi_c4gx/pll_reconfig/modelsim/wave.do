onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {SDI Triple Standard Duplex}
add wave -noupdate -format Literal /tb_sdi_megacore_top/duplex_inst/crc_error_c
add wave -noupdate -format Literal /tb_sdi_megacore_top/duplex_inst/crc_error_y
add wave -noupdate -format Logic /tb_sdi_megacore_top/duplex_inst/en_sync_switch
add wave -noupdate -format Logic /tb_sdi_megacore_top/duplex_inst/enable_3g_search
add wave -noupdate -format Logic /tb_sdi_megacore_top/duplex_inst/enable_crc
add wave -noupdate -format Logic /tb_sdi_megacore_top/duplex_inst/enable_hd_search
add wave -noupdate -format Logic /tb_sdi_megacore_top/duplex_inst/enable_ln
add wave -noupdate -format Logic /tb_sdi_megacore_top/duplex_inst/enable_sd_search
add wave -noupdate -format Logic /tb_sdi_megacore_top/duplex_inst/gxb4_cal_clk
add wave -noupdate -format Logic /tb_sdi_megacore_top/duplex_inst/gxb_tx_clkout
add wave -noupdate -format Logic /tb_sdi_megacore_top/duplex_inst/pll_areset
add wave -noupdate -format Logic /tb_sdi_megacore_top/duplex_inst/pll_configupdate
add wave -noupdate -format Logic /tb_sdi_megacore_top/duplex_inst/pll_scanclk
add wave -noupdate -format Logic /tb_sdi_megacore_top/duplex_inst/pll_scanclkena
add wave -noupdate -format Logic /tb_sdi_megacore_top/duplex_inst/pll_scandata
add wave -noupdate -format Logic /tb_sdi_megacore_top/duplex_inst/pll_scandataout
add wave -noupdate -format Logic /tb_sdi_megacore_top/duplex_inst/pll_scandone
add wave -noupdate -format Logic /tb_sdi_megacore_top/duplex_inst/rst_rx
add wave -noupdate -format Logic /tb_sdi_megacore_top/duplex_inst/rst_tx
add wave -noupdate -format Literal /tb_sdi_megacore_top/duplex_inst/rx_anc_data
add wave -noupdate -format Literal /tb_sdi_megacore_top/duplex_inst/rx_anc_error
add wave -noupdate -format Literal /tb_sdi_megacore_top/duplex_inst/rx_anc_valid
add wave -noupdate -format Literal /tb_sdi_megacore_top/duplex_inst/rx_AP
add wave -noupdate -format Logic /tb_sdi_megacore_top/duplex_inst/rx_clk
add wave -noupdate -format Literal /tb_sdi_megacore_top/duplex_inst/rx_data_valid_out
add wave -noupdate -format Logic /tb_sdi_megacore_top/duplex_inst/rx_eav
add wave -noupdate -format Literal /tb_sdi_megacore_top/duplex_inst/rx_F
add wave -noupdate -format Literal /tb_sdi_megacore_top/duplex_inst/rx_H
add wave -noupdate -format Literal /tb_sdi_megacore_top/duplex_inst/rx_ln
add wave -noupdate -format Logic /tb_sdi_megacore_top/duplex_inst/rx_serial_refclk
add wave -noupdate -format Literal /tb_sdi_megacore_top/duplex_inst/rx_status
add wave -noupdate -format Literal /tb_sdi_megacore_top/duplex_inst/rx_std
add wave -noupdate -format Logic /tb_sdi_megacore_top/duplex_inst/rx_std_flag_hd_sdn
add wave -noupdate -format Logic /tb_sdi_megacore_top/duplex_inst/rx_trs
add wave -noupdate -format Literal /tb_sdi_megacore_top/duplex_inst/rx_V
add wave -noupdate -format Logic /tb_sdi_megacore_top/duplex_inst/rx_xyz
add wave -noupdate -format Literal /tb_sdi_megacore_top/duplex_inst/rxdata
add wave -noupdate -format Logic /tb_sdi_megacore_top/duplex_inst/sdi_gxb_powerdown
add wave -noupdate -format Logic /tb_sdi_megacore_top/duplex_inst/sdi_rx
add wave -noupdate -format Logic /tb_sdi_megacore_top/duplex_inst/sdi_start_reconfig
add wave -noupdate -format Logic /tb_sdi_megacore_top/duplex_inst/sdi_tx
add wave -noupdate -format Literal /tb_sdi_megacore_top/duplex_inst/tx_ln
add wave -noupdate -format Logic /tb_sdi_megacore_top/duplex_inst/tx_pclk
add wave -noupdate -format Logic /tb_sdi_megacore_top/duplex_inst/tx_serial_refclk
add wave -noupdate -format Logic /tb_sdi_megacore_top/duplex_inst/tx_status
add wave -noupdate -format Literal /tb_sdi_megacore_top/duplex_inst/tx_std
add wave -noupdate -format Logic /tb_sdi_megacore_top/duplex_inst/tx_trs
add wave -noupdate -format Literal /tb_sdi_megacore_top/duplex_inst/txdata
add wave -noupdate -format Logic /tb_sdi_megacore_top/duplex_inst/xyz_valid
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {92655297645 fs} 0}
configure wave -namecolwidth 348
configure wave -valuecolwidth 40
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
configure wave -timelineunits fs
update
WaveRestoreZoom {0 fs} {169521800175 fs}
