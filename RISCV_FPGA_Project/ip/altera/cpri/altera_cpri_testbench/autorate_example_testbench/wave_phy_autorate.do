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

add wave -noupdate -divider Register
add wave -noupdate /tb/REG_CPRI_CONFIG
add wave -noupdate /tb/REG_CPRI_MAP_CNT_CONFIG
add wave -noupdate /tb/REG_CPRI_MAP_CONFIG
add wave -noupdate /tb/REG_CPRI_RATE_CONFIG
add wave -noupdate -divider CLOCK_RESET
add wave -noupdate /tb/clk_15_36
add wave -noupdate /tb/clk_30_72
add wave -noupdate /tb/clk_check_configure
add wave -noupdate /tb/clk_compare
add wave -noupdate /tb/clk_ex_delay_wire
add wave -noupdate /tb/reset_done_wire
add wave -noupdate /tb/reset_ex_delay_wire
add wave -noupdate /tb/reset_freq_check_wire
add wave -noupdate /tb/reset_phy_wire
add wave -noupdate /tb/reset_wire
add wave -noupdate -divider {CPU Interface}
add wave -noupdate /tb/cpu_clk_wire
add wave -noupdate /tb/cpu_reset_wire
add wave -noupdate /tb/cpu_address_wire
add wave -noupdate /tb/cpu_done_compare
add wave -noupdate /tb/cpu_irq_vector_wire
add wave -noupdate /tb/cpu_irq_wire
add wave -noupdate /tb/cpu_running
add wave -noupdate /tb/cpu_waitrequest_wire
add wave -noupdate /tb/cpu_read_wire
add wave -noupdate -radix hexadecimal /tb/cpu_readdata_wire
add wave -noupdate /tb/cpu_write_wire
add wave -noupdate -radix hexadecimal /tb/cpu_writedata_wire
add wave -noupdate -divider {PHY Reconfig}
add wave -noupdate /tb/reconfig_busy_wire
add wave -noupdate /tb/reconfig_clk_wire
add wave -noupdate /tb/reconfig_from_xcvr_wire
add wave -noupdate /tb/reconfig_to_xcvr_wire
add wave -noupdate -divider {Frequency Check}
add wave -noupdate /tb/cnt
add wave -noupdate /tb/cnt_auto
add wave -noupdate /tb/cnt_check
add wave -noupdate /tb/cnt_check_s0
add wave -noupdate /tb/cnt_check_s1
add wave -noupdate /tb/diff
add wave -noupdate /tb/alarm_detected
add wave -noupdate /tb/alarm_detected_edge
add wave -noupdate /tb/freq_alarm_hold
add wave -noupdate /tb/freq_alarm_wire
add wave -noupdate /tb/freq_check_cnt
add wave -noupdate /tb/resync
add wave -noupdate /tb/check_seq
add wave -noupdate -divider cpri_top_level
add wave -noupdate /tb/main_reset
add wave -noupdate /tb/aux_rx_status_data_wire
add wave -noupdate /tb/aux_tx_mask_data_wire
add wave -noupdate /tb/aux_tx_status_data_wire
add wave -noupdate /tb/extended_rx_status_data_wire
add wave -noupdate /tb/completed_configure
add wave -noupdate /tb/completed_configure_hold
add wave -noupdate /tb/config_reset_wire
add wave -noupdate /tb/cpri_clkout_wire
add wave -noupdate /tb/cpri_rx_sync
add wave -noupdate /tb/cpri_rx_sync_state
add wave -noupdate /tb/datarate_en_wire
add wave -noupdate /tb/datarate_set_wire
add wave -noupdate /tb/done_reconfig
add wave -noupdate /tb/gxb_los_wire
add wave -noupdate /tb/gxb_pll_inclk_wire
add wave -noupdate /tb/gxb_pll_locked_wire
add wave -noupdate /tb/gxb_refclk_wire
add wave -noupdate /tb/gxb_rx_disperr_wire
add wave -noupdate /tb/gxb_rx_errdetect_wire
add wave -noupdate /tb/gxb_rx_freqlocked_wire
add wave -noupdate /tb/gxb_rx_pll_locked_wire
add wave -noupdate /tb/gxb_wire
add wave -noupdate /tb/hw_reset_assert_wire
add wave -noupdate /tb/hw_reset_req_wire
add wave -noupdate /tb/op_cnt
add wave -noupdate /tb/pll_clkout_wire
add wave -noupdate /tb/start_auto
add wave -noupdate /tb/start_configure
add wave -noupdate /tb/start_configure_hold
add wave -noupdate /tb/start_freq_checking
add wave -noupdate /tb/start_reconfig_wire
add wave -noupdate -divider cpri_reconfig_controller
add wave -noupdate /tb/cpri_reconfig_controller_inst/REG_CS
add wave -noupdate /tb/cpri_reconfig_controller_inst/REG_DATA
add wave -noupdate /tb/cpri_reconfig_controller_inst/REG_LOG_CH
add wave -noupdate /tb/cpri_reconfig_controller_inst/REG_OFFSET
add wave -noupdate /tb/cpri_reconfig_controller_inst/clk
add wave -noupdate /tb/cpri_reconfig_controller_inst/reset
add wave -noupdate /tb/cpri_reconfig_controller_inst/reset_done
add wave -noupdate /tb/cpri_reconfig_controller_inst/reset_phy
add wave -noupdate /tb/cpri_reconfig_controller_inst/reset_phy_counter
add wave -noupdate /tb/cpri_reconfig_controller_inst/done_reconfig
add wave -noupdate /tb/cpri_reconfig_controller_inst/done_reconfig_wire
add wave -noupdate /tb/cpri_reconfig_controller_inst/state
add wave -noupdate /tb/cpri_reconfig_controller_inst/read_done
add wave -noupdate /tb/cpri_reconfig_controller_inst/config_mode
add wave -noupdate /tb/cpri_reconfig_controller_inst/reconfig_channel_addr
add wave -noupdate /tb/cpri_reconfig_controller_inst/reconfig_pll_addr
add wave -noupdate /tb/cpri_reconfig_controller_inst/reconfig_channel_readdata
add wave -noupdate /tb/cpri_reconfig_controller_inst/reconfig_pll_readdata
add wave -noupdate /tb/cpri_reconfig_controller_inst/reconfig_busy
add wave -noupdate /tb/cpri_reconfig_controller_inst/reconfig_busy_wire
add wave -noupdate /tb/cpri_reconfig_controller_inst/reconfig_from_xcvr
add wave -noupdate /tb/cpri_reconfig_controller_inst/reconfig_in_progress
add wave -noupdate /tb/cpri_reconfig_controller_inst/reconfig_mgmt_address
add wave -noupdate /tb/cpri_reconfig_controller_inst/reconfig_mgmt_read
add wave -noupdate /tb/cpri_reconfig_controller_inst/reconfig_mgmt_readdata
add wave -noupdate /tb/cpri_reconfig_controller_inst/reconfig_mgmt_waitrequest
add wave -noupdate /tb/cpri_reconfig_controller_inst/reconfig_mgmt_write
add wave -noupdate /tb/cpri_reconfig_controller_inst/reconfig_mgmt_writedata
add wave -noupdate /tb/cpri_reconfig_controller_inst/reconfig_mif_address
add wave -noupdate /tb/cpri_reconfig_controller_inst/reconfig_mif_read
add wave -noupdate /tb/cpri_reconfig_controller_inst/reconfig_mif_readdata
add wave -noupdate /tb/cpri_reconfig_controller_inst/reconfig_mif_waitrequest
add wave -noupdate /tb/cpri_reconfig_controller_inst/reconfig_to_xcvr
add wave -noupdate /tb/cpri_reconfig_controller_inst/start_reconfig
add wave -noupdate -divider rom_channel
add wave -noupdate /tb/cpri_reconfig_controller_inst/rom_channel_614_inst/init_file
add wave -noupdate -radix unsigned /tb/cpri_reconfig_controller_inst/rom_channel_614_inst/address
add wave -noupdate /tb/cpri_reconfig_controller_inst/rom_channel_614_inst/clock
add wave -noupdate /tb/cpri_reconfig_controller_inst/rom_channel_614_inst/q
add wave -noupdate -divider rom_pll
add wave -noupdate /tb/cpri_reconfig_controller_inst/rom_pll_614_inst/init_file
add wave -noupdate -radix unsigned /tb/cpri_reconfig_controller_inst/rom_pll_614_inst/address
add wave -noupdate /tb/cpri_reconfig_controller_inst/rom_pll_614_inst/clock
add wave -noupdate /tb/cpri_reconfig_controller_inst/rom_pll_614_inst/q
add wave -noupdate -divider xcvr_reconfig_cpri
add wave -noupdate /tb/cpri_reconfig_controller_inst/xcvr_reconfig_cpri_inst/reconfig_busy
add wave -noupdate /tb/cpri_reconfig_controller_inst/xcvr_reconfig_cpri_inst/mgmt_clk_clk
add wave -noupdate /tb/cpri_reconfig_controller_inst/xcvr_reconfig_cpri_inst/mgmt_rst_reset
add wave -noupdate /tb/cpri_reconfig_controller_inst/xcvr_reconfig_cpri_inst/reconfig_mgmt_address
add wave -noupdate /tb/cpri_reconfig_controller_inst/xcvr_reconfig_cpri_inst/reconfig_mgmt_read
add wave -noupdate /tb/cpri_reconfig_controller_inst/xcvr_reconfig_cpri_inst/reconfig_mgmt_readdata
add wave -noupdate /tb/cpri_reconfig_controller_inst/xcvr_reconfig_cpri_inst/reconfig_mgmt_waitrequest
add wave -noupdate /tb/cpri_reconfig_controller_inst/xcvr_reconfig_cpri_inst/reconfig_mgmt_write
add wave -noupdate /tb/cpri_reconfig_controller_inst/xcvr_reconfig_cpri_inst/reconfig_mgmt_writedata
add wave -noupdate /tb/cpri_reconfig_controller_inst/xcvr_reconfig_cpri_inst/reconfig_mif_address
add wave -noupdate /tb/cpri_reconfig_controller_inst/xcvr_reconfig_cpri_inst/reconfig_mif_read
add wave -noupdate /tb/cpri_reconfig_controller_inst/xcvr_reconfig_cpri_inst/reconfig_mif_readdata
add wave -noupdate /tb/cpri_reconfig_controller_inst/xcvr_reconfig_cpri_inst/reconfig_mif_waitrequest
add wave -noupdate /tb/cpri_reconfig_controller_inst/xcvr_reconfig_cpri_inst/reconfig_to_xcvr
add wave -noupdate /tb/cpri_reconfig_controller_inst/xcvr_reconfig_cpri_inst/reconfig_from_xcvr
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1353918495298 fs} 0}
configure wave -namecolwidth 226
configure wave -valuecolwidth 47
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
WaveRestoreZoom {0 fs} {2100 us}
run -all
