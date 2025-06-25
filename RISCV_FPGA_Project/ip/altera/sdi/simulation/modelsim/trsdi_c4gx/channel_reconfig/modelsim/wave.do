onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /tb_sdi_megacore_top/rx_inst/rst_rx
add wave -noupdate -format Logic /tb_sdi_megacore_top/rx_inst/rx_serial_refclk
add wave -noupdate -format Logic /tb_sdi_megacore_top/rx_inst/sdi_rx
add wave -noupdate -format Logic /tb_sdi_megacore_top/rx_inst/en_sync_switch
add wave -noupdate -format Logic /tb_sdi_megacore_top/rx_inst/enable_hd_search
add wave -noupdate -format Logic /tb_sdi_megacore_top/rx_inst/enable_sd_search
add wave -noupdate -format Logic /tb_sdi_megacore_top/rx_inst/gxb4_cal_clk
add wave -noupdate -format Logic /tb_sdi_megacore_top/rx_inst/sdi_reconfig_clk
add wave -noupdate -format Literal /tb_sdi_megacore_top/rx_inst/sdi_reconfig_togxb
add wave -noupdate -format Logic /tb_sdi_megacore_top/rx_inst/sdi_gxb_powerdown
add wave -noupdate -format Logic /tb_sdi_megacore_top/rx_inst/enable_3g_search
add wave -noupdate -format Logic /tb_sdi_megacore_top/rx_inst/sdi_reconfig_done
add wave -noupdate -format Literal -radix hexadecimal /tb_sdi_megacore_top/rx_inst/rxdata
add wave -noupdate -format Literal /tb_sdi_megacore_top/rx_inst/rx_data_valid_out
add wave -noupdate -format Literal /tb_sdi_megacore_top/rx_inst/crc_error_y
add wave -noupdate -format Literal /tb_sdi_megacore_top/rx_inst/crc_error_c
add wave -noupdate -format Literal /tb_sdi_megacore_top/rx_inst/rx_anc_data
add wave -noupdate -format Literal /tb_sdi_megacore_top/rx_inst/rx_anc_valid
add wave -noupdate -format Literal /tb_sdi_megacore_top/rx_inst/rx_anc_error
add wave -noupdate -format Logic /tb_sdi_megacore_top/rx_inst/rx_std_flag_hd_sdn
add wave -noupdate -format Logic /tb_sdi_megacore_top/rx_inst/rx_clk
add wave -noupdate -format Literal /tb_sdi_megacore_top/rx_inst/rx_F
add wave -noupdate -format Literal /tb_sdi_megacore_top/rx_inst/rx_V
add wave -noupdate -format Literal /tb_sdi_megacore_top/rx_inst/rx_H
add wave -noupdate -format Literal /tb_sdi_megacore_top/rx_inst/rx_AP
add wave -noupdate -format Literal /tb_sdi_megacore_top/rx_inst/rx_status
add wave -noupdate -format Literal /tb_sdi_megacore_top/rx_inst/rx_ln
add wave -noupdate -format Logic /tb_sdi_megacore_top/rx_inst/rx_xyz
add wave -noupdate -format Logic /tb_sdi_megacore_top/rx_inst/xyz_valid
add wave -noupdate -format Logic /tb_sdi_megacore_top/rx_inst/rx_eav
add wave -noupdate -format Logic /tb_sdi_megacore_top/rx_inst/rx_trs
add wave -noupdate -format Literal /tb_sdi_megacore_top/rx_inst/sdi_reconfig_fromgxb
add wave -noupdate -format Literal /tb_sdi_megacore_top/rx_inst/rx_std
add wave -noupdate -format Logic /tb_sdi_megacore_top/rx_inst/sdi_start_reconfig
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {34895851736 fs} 0} {{Cursor 2} {1048913101584 fs} 0} {{Cursor 3} {125172352546 fs} 0}
configure wave -namecolwidth 330
configure wave -valuecolwidth 39
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
WaveRestoreZoom {0 fs} {108103932300 fs}
