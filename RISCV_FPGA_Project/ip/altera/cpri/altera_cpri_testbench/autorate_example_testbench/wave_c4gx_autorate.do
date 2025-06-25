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

add wave -noupdate -divider CLOCK_RESET
add wave -noupdate -format Logic /tb/clk_15_36
add wave -noupdate -format Logic /tb/clk_30_72
add wave -noupdate -format Logic /tb/gxb_clk_61_44
add wave -noupdate -format Logic /tb/clk_compare
add wave -noupdate -format Logic /tb/clk_ex_delay_wire
add wave -noupdate -format Logic /tb/reconfig_clk_wire
add wave -noupdate -format Logic /tb/reset_ex_delay_wire
add wave -noupdate -format Logic /tb/hw_reset_req_wire
add wave -noupdate -format Logic /tb/reset_wire
add wave -noupdate -divider {CPU Interface}
add wave -noupdate -format Logic /tb/cpu_reset_wire
add wave -noupdate -format Literal /tb/cpu_writedata_wire
add wave -noupdate -format Logic /tb/cpu_read_wire
add wave -noupdate -format Logic /tb/cpu_write_wire
add wave -noupdate -format Literal /tb/cpu_readdata_wire
add wave -noupdate -format Literal /tb/cpu_address_wire
add wave -noupdate -format Logic /tb/cpu_waitrequest_wire
add wave -noupdate -format Logic /tb/cpu_irq_wire
add wave -noupdate -format Literal /tb/cpu_irq_vector_wire
add wave -noupdate -divider ALTGX_RECONFIG
add wave -noupdate -format Literal /tb/state_gx
add wave -noupdate -format Logic /tb/error_wire
add wave -noupdate -format Literal /tb/reconfig_data
add wave -noupdate -format Logic /tb/reconfig_busy_wire
add wave -noupdate -format Logic /tb/reconfig_write_wire
add wave -noupdate -format Logic /tb/reconfig_done_wire
add wave -noupdate -format Literal /tb/reconfig_togxb_m_wire
add wave -noupdate -format Logic /tb/reconfig_address_en
add wave -noupdate -format Literal /tb/reconfig_address_out
add wave -noupdate -format Literal /tb/reconfig_fromgxb_m_wire
add wave -noupdate -divider rom_cyclone4gx_614_reconfig
add wave -noupdate -format Logic /tb/write_614_reconfig_data
add wave -noupdate -format Literal /tb/rom_614_reconfig_add
add wave -noupdate -divider rom_cyclone4gx_1228_reconfig
add wave -noupdate -format Logic /tb/write_1228_reconfig_data
add wave -noupdate -format Literal /tb/rom_1228_reconfig_add
add wave -noupdate -divider ALTPLL_RECONFIG
add wave -noupdate -format Literal /tb/state_pll
add wave -noupdate -format Logic /tb/clock_wire
add wave -noupdate -format Literal /tb/altpll_busy_wire
add wave -noupdate -format Logic /tb/rxpll_reset_rom_addr_wire
add wave -noupdate -format Logic /tb/rxpll_rom_data_in_wire
add wave -noupdate -format Logic /tb/rxpll_write_from_rom_wire
add wave -noupdate -format Literal /tb/rom_rx_address_out_wire
add wave -noupdate -format Logic /tb/write_rx_rom_ena_wire
add wave -noupdate -format Logic /tb/reconfig_rx_wire
add wave -noupdate -format Logic /tb/txpll_reset_rom_addr_wire
add wave -noupdate -format Logic /tb/txpll_rom_data_in_wire
add wave -noupdate -format Logic /tb/txpll_write_from_rom_wire
add wave -noupdate -format Literal /tb/rom_tx_address_out_wire
add wave -noupdate -format Logic /tb/write_tx_rom_ena_wire
add wave -noupdate -format Logic /tb/reconfig_tx_wire
add wave -noupdate -divider rom_cyclone4gx_1228_m_tx_rx
add wave -noupdate -format Literal /tb/rom_c4gx_614_reconfig_data
add wave -noupdate -format Literal /tb/rom_c4gx_614_tx_data_wire
add wave -noupdate -format Literal /tb/rom_c4gx_614_rx_data_wire
add wave -noupdate -divider rom_cyclone4gx_614_m_tx_rx
add wave -noupdate -format Literal /tb/rom_c4gx_1228_reconfig_data
add wave -noupdate -format Literal /tb/rom_c4gx_1228_tx_data_wire
add wave -noupdate -format Literal /tb/rom_c4gx_1228_rx_data_wire
add wave -noupdate -divider {Operational Counter}
add wave -noupdate -format Literal /tb/op_cnt
add wave -noupdate -format Logic /tb/cnt_en1
add wave -noupdate -format Logic /tb/cnt_en2
add wave -noupdate -format Literal /tb/fsm_cnt
add wave -noupdate -format Literal /tb/fsm_ctrl
add wave -noupdate -format Logic /tb/fsm_stop
add wave -noupdate -format Logic /tb/fsm_altgx_start
add wave -noupdate -format Logic /tb/fsm_altgx_stop
add wave -noupdate -format Logic /tb/cpu_running
add wave -noupdate -format Logic /tb/start_configure
add wave -noupdate -format Logic /tb/start_configure_hold
add wave -noupdate -format Literal /tb/num_configure
add wave -noupdate -format Logic /tb/completed_configure
add wave -noupdate -format Literal /tb/clk_check_configure
add wave -noupdate -format Literal /tb/gxb_refclk_select
add wave -noupdate -format Logic /tb/cpu_done_compare
add wave -noupdate -divider {Frequency Check}
add wave -noupdate -format Literal /tb/cnt
add wave -noupdate -format Literal /tb/cnt_check
add wave -noupdate -format Literal /tb/cnt_check_s0
add wave -noupdate -format Literal /tb/cnt_check_s1
add wave -noupdate -format Literal /tb/diff
add wave -noupdate -format Logic /tb/alarm_detected
add wave -noupdate -format Logic /tb/start_freq_checking
add wave -noupdate -format Logic /tb/reset_freq_check_wire
add wave -noupdate -format Logic /tb/freq_alarm_hold
add wave -noupdate -format Logic /tb/freq_alarm_wire
add wave -noupdate -format Logic /tb/alarm_detected_edge
add wave -noupdate -format Literal /tb/check_seq
add wave -noupdate -format Logic /tb/resync
add wave -noupdate -divider cpri_top_level
add wave -noupdate -format Logic /tb/cpri_rx_sync_state
add wave -noupdate -format Logic /tb/cpri_rec_loopback_wire
add wave -noupdate -format Logic /tb/cpri_rx_sync
add wave -noupdate -format Logic /tb/cpri_rx_sync_state2
add wave -noupdate -format Literal /tb/pll_areset_wire
add wave -noupdate -format Literal /tb/pll_configupdate_wire
add wave -noupdate -format Literal /tb/pll_scanclk_wire
add wave -noupdate -format Literal /tb/pll_scanclkena_wire
add wave -noupdate -format Literal /tb/pll_scandata_wire
add wave -noupdate -format Literal /tb/pll_reconfig_done_wire
add wave -noupdate -format Literal /tb/pll_scandataout_wire
add wave -noupdate -format Logic /tb/pll_clkout_wire
add wave -noupdate -format Logic /tb/datarate_en_wire
add wave -noupdate -format Literal /tb/datarate_set_wire
add wave -noupdate -format Logic /tb/cpri_clkout_wire
add wave -noupdate -format Literal /tb/extended_rx_status_data_wire
add wave -noupdate -format Logic /tb/gxb_refclk_wire
add wave -noupdate -format Logic /tb/gxb_cal_blk_clk_wire
add wave -noupdate -format Logic /tb/gxb_powerdown_wire
add wave -noupdate -format Logic /tb/gxb_pll_locked_wire
add wave -noupdate -format Logic /tb/gxb_rx_pll_locked_wire
add wave -noupdate -format Logic /tb/gxb_rx_freqlocked_wire
add wave -noupdate -format Literal /tb/gxb_rx_errdetect_wire
add wave -noupdate -format Literal /tb/gxb_rx_disperr_wire
add wave -noupdate -format Logic /tb/gxb_los_wire
add wave -noupdate -format Logic /tb/reset_done_wire
add wave -noupdate -format Literal /tb/aux_rx_status_data_wire
add wave -noupdate -format Literal /tb/aux_tx_status_data_wire
add wave -noupdate -format Literal /tb/aux_tx_mask_data_wire
add wave -noupdate -format Logic /tb/s_reset_done_wire
add wave -noupdate -format Logic /tb/config_reset_wire
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1643690015909 fs} 0}
configure wave -namecolwidth 477
configure wave -valuecolwidth 88
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
configure wave -timelineunits fs
update
WaveRestoreZoom {387877925 ps} {2597176973822 fs}
run -all
