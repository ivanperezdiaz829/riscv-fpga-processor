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
quietly virtual signal -install /design_example_wrapper_nch/LOCAL_sv_rc_wrapper { /design_example_wrapper_nch/LOCAL_sv_rc_wrapper/seq_pcs_mode[11:6]} seq_pcs_mode_Ch1
quietly virtual signal -install /design_example_wrapper_nch/LOCAL_sv_rc_wrapper { /design_example_wrapper_nch/LOCAL_sv_rc_wrapper/seq_pcs_mode[5:0]} seq_pcs_mode_Ch0
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /design_example_wrapper_nch/phy_mgmt_clk
add wave -noupdate -radix hexadecimal /design_example_wrapper_nch/phy_mgmt_clk_reset
add wave -noupdate -divider {Test Harness AVMM IF}
add wave -noupdate -radix hexadecimal /design_example_wrapper_nch/test_harness_inst/phy_mgmt_address
add wave -noupdate -radix hexadecimal /design_example_wrapper_nch/test_harness_inst/phy_mgmt_clk
add wave -noupdate -radix hexadecimal /design_example_wrapper_nch/test_harness_inst/phy_mgmt_clk_reset
add wave -noupdate -radix hexadecimal /design_example_wrapper_nch/test_harness_inst/phy_mgmt_read
add wave -noupdate -radix hexadecimal /design_example_wrapper_nch/test_harness_inst/phy_mgmt_readdata
add wave -noupdate -radix hexadecimal /design_example_wrapper_nch/test_harness_inst/phy_mgmt_waitrequest
add wave -noupdate -radix hexadecimal /design_example_wrapper_nch/test_harness_inst/phy_mgmt_write
add wave -noupdate -radix hexadecimal /design_example_wrapper_nch/test_harness_inst/phy_mgmt_writedata
add wave -noupdate -radix hexadecimal /design_example_wrapper_nch/test_harness_inst/master_bfm_done
add wave -noupdate -divider {GMII Test Signals}
add wave -noupdate -radix hexadecimal /design_example_wrapper_nch/test_harness_inst/tx_clkout_1g
add wave -noupdate -radix hexadecimal /design_example_wrapper_nch/test_harness_inst/gmii_rx_d
add wave -noupdate -radix hexadecimal /design_example_wrapper_nch/test_harness_inst/gige_pattern_chk_inst/gmii_rx_dv
add wave -noupdate -radix hexadecimal /design_example_wrapper_nch/test_harness_inst/gmii_rx_en
add wave -noupdate -radix hexadecimal /design_example_wrapper_nch/test_harness_inst/gmii_tx_d
add wave -noupdate -radix hexadecimal /design_example_wrapper_nch/test_harness_inst/gmii_tx_en
add wave -noupdate -radix hexadecimal /design_example_wrapper_nch/test_harness_inst/gmii_tx_err
add wave -noupdate -radix hexadecimal /design_example_wrapper_nch/test_harness_inst/packet_complete_chk
add wave -noupdate -radix hexadecimal /design_example_wrapper_nch/test_harness_inst/packet_complete_gen
add wave -noupdate -label {Start GMII Test} /design_example_wrapper_nch/test_harness_inst/gige_sync_start
add wave -noupdate -label {GMII Test Passed} -radix hexadecimal /design_example_wrapper_nch/test_harness_inst/ch_pass
add wave -noupdate -divider {XGMII Test Signals}
add wave -noupdate -radix hexadecimal /design_example_wrapper_nch/test_harness_inst/xgmii_tx_clk
add wave -noupdate -radix hexadecimal /design_example_wrapper_nch/test_harness_inst/xgmii_rx_dc
add wave -noupdate -radix hexadecimal /design_example_wrapper_nch/test_harness_inst/xgmii_tx_dc
add wave -noupdate -radix hexadecimal /design_example_wrapper_nch/test_harness_inst/num_frame
add wave -noupdate -radix hexadecimal /design_example_wrapper_nch/test_harness_inst/rx_mismatch
add wave -noupdate -radix hexadecimal /design_example_wrapper_nch/test_harness_inst/start_xgmii_test
add wave -noupdate -label {XGMII Test Passed} -radix hexadecimal /design_example_wrapper_nch/test_harness_inst/checker_pass
add wave -noupdate -radix hexadecimal /design_example_wrapper_nch/test_harness_inst/test_done
add wave -noupdate -divider {RC Request Signals}
add wave -noupdate -radix hexadecimal /design_example_wrapper_nch/phy_mgmt_clk
add wave -noupdate -radix hexadecimal {/design_example_wrapper_nch/LOCAL_sv_rc_wrapper/seq_pcs_mode[5]}
add wave -noupdate -radix hexadecimal {/design_example_wrapper_nch/LOCAL_sv_rc_wrapper/seq_pcs_mode[4]}
add wave -noupdate -radix hexadecimal {/design_example_wrapper_nch/LOCAL_sv_rc_wrapper/seq_pcs_mode[3]}
add wave -noupdate -radix hexadecimal {/design_example_wrapper_nch/LOCAL_sv_rc_wrapper/seq_pcs_mode[2]}
add wave -noupdate -radix hexadecimal {/design_example_wrapper_nch/LOCAL_sv_rc_wrapper/seq_pcs_mode[1]}
add wave -noupdate -radix hexadecimal {/design_example_wrapper_nch/LOCAL_sv_rc_wrapper/seq_pcs_mode[0]}
add wave -noupdate -radix hexadecimal /design_example_wrapper_nch/LOCAL_sv_rc_wrapper/seq_pcs_mode_Ch1
add wave -noupdate -radix hexadecimal /design_example_wrapper_nch/LOCAL_sv_rc_wrapper/seq_pcs_mode_Ch0
add wave -noupdate -radix hexadecimal -childformat {{{/design_example_wrapper_nch/LOCAL_sv_rc_wrapper/seq_pcs_mode[11]} -radix hexadecimal} {{/design_example_wrapper_nch/LOCAL_sv_rc_wrapper/seq_pcs_mode[10]} -radix hexadecimal} {{/design_example_wrapper_nch/LOCAL_sv_rc_wrapper/seq_pcs_mode[9]} -radix hexadecimal} {{/design_example_wrapper_nch/LOCAL_sv_rc_wrapper/seq_pcs_mode[8]} -radix hexadecimal} {{/design_example_wrapper_nch/LOCAL_sv_rc_wrapper/seq_pcs_mode[7]} -radix hexadecimal} {{/design_example_wrapper_nch/LOCAL_sv_rc_wrapper/seq_pcs_mode[6]} -radix hexadecimal} {{/design_example_wrapper_nch/LOCAL_sv_rc_wrapper/seq_pcs_mode[5]} -radix hexadecimal} {{/design_example_wrapper_nch/LOCAL_sv_rc_wrapper/seq_pcs_mode[4]} -radix hexadecimal} {{/design_example_wrapper_nch/LOCAL_sv_rc_wrapper/seq_pcs_mode[3]} -radix hexadecimal} {{/design_example_wrapper_nch/LOCAL_sv_rc_wrapper/seq_pcs_mode[2]} -radix hexadecimal} {{/design_example_wrapper_nch/LOCAL_sv_rc_wrapper/seq_pcs_mode[1]} -radix hexadecimal} {{/design_example_wrapper_nch/LOCAL_sv_rc_wrapper/seq_pcs_mode[0]} -radix hexadecimal}} -subitemconfig {{/design_example_wrapper_nch/LOCAL_sv_rc_wrapper/seq_pcs_mode[11]} {-height 16 -radix hexadecimal} {/design_example_wrapper_nch/LOCAL_sv_rc_wrapper/seq_pcs_mode[10]} {-height 16 -radix hexadecimal} {/design_example_wrapper_nch/LOCAL_sv_rc_wrapper/seq_pcs_mode[9]} {-height 16 -radix hexadecimal} {/design_example_wrapper_nch/LOCAL_sv_rc_wrapper/seq_pcs_mode[8]} {-height 16 -radix hexadecimal} {/design_example_wrapper_nch/LOCAL_sv_rc_wrapper/seq_pcs_mode[7]} {-height 16 -radix hexadecimal} {/design_example_wrapper_nch/LOCAL_sv_rc_wrapper/seq_pcs_mode[6]} {-height 16 -radix hexadecimal} {/design_example_wrapper_nch/LOCAL_sv_rc_wrapper/seq_pcs_mode[5]} {-height 16 -radix hexadecimal} {/design_example_wrapper_nch/LOCAL_sv_rc_wrapper/seq_pcs_mode[4]} {-height 16 -radix hexadecimal} {/design_example_wrapper_nch/LOCAL_sv_rc_wrapper/seq_pcs_mode[3]} {-height 16 -radix hexadecimal} {/design_example_wrapper_nch/LOCAL_sv_rc_wrapper/seq_pcs_mode[2]} {-height 16 -radix hexadecimal} {/design_example_wrapper_nch/LOCAL_sv_rc_wrapper/seq_pcs_mode[1]} {-height 16 -radix hexadecimal} {/design_example_wrapper_nch/LOCAL_sv_rc_wrapper/seq_pcs_mode[0]} {-height 16 -radix hexadecimal}} /design_example_wrapper_nch/LOCAL_sv_rc_wrapper/seq_pcs_mode
add wave -noupdate -radix hexadecimal /design_example_wrapper_nch/LOCAL_sv_rc_wrapper/seq_start_rc
add wave -noupdate -radix hexadecimal /design_example_wrapper_nch/LOCAL_sv_rc_wrapper/ctle_rc
add wave -noupdate -radix hexadecimal /design_example_wrapper_nch/LOCAL_sv_rc_wrapper/ctle_start_rc
add wave -noupdate -radix hexadecimal /design_example_wrapper_nch/LOCAL_sv_rc_wrapper/dfe_mode
add wave -noupdate -radix hexadecimal /design_example_wrapper_nch/LOCAL_sv_rc_wrapper/dfe_start_rc
add wave -noupdate -radix hexadecimal /design_example_wrapper_nch/LOCAL_sv_rc_wrapper/lt_start_rc
add wave -noupdate -divider {Reconfig Bundle}
add wave -noupdate -radix hexadecimal /design_example_wrapper_nch/LOCAL_sv_rc_wrapper/sv_rc_bundle_inst/reconfig_clk
add wave -noupdate -radix hexadecimal /design_example_wrapper_nch/LOCAL_sv_rc_wrapper/sv_rc_bundle_inst/reconfig_reset
add wave -noupdate -radix hexadecimal /design_example_wrapper_nch/LOCAL_sv_rc_wrapper/sv_rc_bundle_inst/baser_ll_mif_done
add wave -noupdate -radix hexadecimal /design_example_wrapper_nch/LOCAL_sv_rc_wrapper/sv_rc_bundle_inst/hdsk_rc_busy
add wave -noupdate -radix hexadecimal /design_example_wrapper_nch/LOCAL_sv_rc_wrapper/sv_rc_bundle_inst/reconfig_mgmt_busy
add wave -noupdate /design_example_wrapper_nch/LOCAL_sv_rc_wrapper/sv_rc_bundle_inst/to_reconfig_mgmt_address
add wave -noupdate /design_example_wrapper_nch/LOCAL_sv_rc_wrapper/sv_rc_bundle_inst/to_reconfig_mgmt_read
add wave -noupdate /design_example_wrapper_nch/LOCAL_sv_rc_wrapper/sv_rc_bundle_inst/to_reconfig_mgmt_write
add wave -noupdate -radix hexadecimal /design_example_wrapper_nch/LOCAL_sv_rc_wrapper/sv_rc_bundle_inst/to_reconfig_mgmt_writedata
add wave -noupdate -radix hexadecimal /design_example_wrapper_nch/LOCAL_sv_rc_wrapper/sv_rc_bundle_inst/from_reconfig_mgmt_readdata
add wave -noupdate /design_example_wrapper_nch/LOCAL_sv_rc_wrapper/sv_rc_bundle_inst/from_reconfig_mgmt_waitrequest
add wave -noupdate -radix hexadecimal /design_example_wrapper_nch/LOCAL_sv_rc_wrapper/sv_rc_bundle_inst/reconfig_mif_address
add wave -noupdate /design_example_wrapper_nch/LOCAL_sv_rc_wrapper/sv_rc_bundle_inst/reconfig_mif_read
add wave -noupdate /design_example_wrapper_nch/LOCAL_sv_rc_wrapper/sv_rc_bundle_inst/reconfig_mif_waitrequest
add wave -noupdate -radix hexadecimal /design_example_wrapper_nch/LOCAL_sv_rc_wrapper/sv_rc_bundle_inst/reconfig_mif_readdata
add wave -noupdate -divider {PHY Reset Signals}
add wave -noupdate -radix hexadecimal /design_example_wrapper_nch/LOCAL_sv_rc_wrapper/rst_cntlr_rx_analogreset
add wave -noupdate -radix hexadecimal /design_example_wrapper_nch/LOCAL_sv_rc_wrapper/rst_cntlr_rx_digitalreset
add wave -noupdate -radix hexadecimal /design_example_wrapper_nch/LOCAL_sv_rc_wrapper/rst_cntlr_tx_analogreset
add wave -noupdate -radix hexadecimal /design_example_wrapper_nch/LOCAL_sv_rc_wrapper/rst_cntlr_tx_digitalreset
add wave -noupdate -divider {PHY Status Signals}
add wave -noupdate /design_example_wrapper_nch/LOCAL_sv_rc_wrapper/tx_ready
add wave -noupdate /design_example_wrapper_nch/LOCAL_sv_rc_wrapper/rx_ready
add wave -noupdate -radix hexadecimal /design_example_wrapper_nch/LOCAL_sv_rc_wrapper/rx_block_lock
add wave -noupdate -radix hexadecimal /design_example_wrapper_nch/LOCAL_sv_rc_wrapper/rx_data_ready
add wave -noupdate -radix hexadecimal /design_example_wrapper_nch/LOCAL_sv_rc_wrapper/rx_hi_ber
add wave -noupdate -radix hexadecimal /design_example_wrapper_nch/LOCAL_sv_rc_wrapper/rx_is_lockedtodata
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {48418231 ps} 0} {{Cursor 2} {598519275 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 231
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
WaveRestoreZoom {0 ps} {210 us}
