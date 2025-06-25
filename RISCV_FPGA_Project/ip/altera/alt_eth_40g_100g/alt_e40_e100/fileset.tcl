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



package provide alt_e40_e100::fileset 13.0

package require alt_xcvr::utils::fileset
package require alt_xcvr::utils::device
package require alt_xcvr::utils::ipgen
package require alt_xcvr::ip_tcl::ip_module 12.1
package require altera_xcvr_native_sv::fileset
package require altera_xcvr_reset_control::fileset

namespace eval ::alt_e40_e100::fileset:: {
  namespace import ::alt_xcvr::ip_tcl::ip_module::*
  namespace import ::alt_xcvr::utils::fileset::*

  namespace export \
    declare_filesets \
    declare_files

  variable filesets

  set filesets {\
    { NAME            TYPE            CALLBACK                                                 TOP_LEVEL }\
    { quartus_synth   QUARTUS_SYNTH   ::alt_e40_e100::fileset::callback_quartus_synth          alt_e40_e100 }\
    { sim_verilog     SIM_VERILOG     ::alt_e40_e100::fileset::callback_sim_verilog            alt_e40_e100 }\
    { sim_vhdl        SIM_VHDL        ::alt_e40_e100::fileset::callback_sim_vhdl               alt_e40_e100 }\
	{ example         EXAMPLE_DESIGN  ::alt_e40_e100::fileset::callback_example_design         alt_e40_e100 }\
  }
}

proc ::alt_e40_e100::fileset::declare_filesets { } {
  variable filesets

  declare_files
  ip_declare_filesets $filesets
}



proc ::alt_e40_e100::fileset::declare_files { {path "./"} } {

  set path "$::env(QUARTUS_ROOTDIR)/../ip/altera/alt_eth_40g_100g"
  
  ::alt_xcvr::utils::fileset::common_fileset_group_plain ./top "$path/100gbe/rtl_src/top" {
    alt_e100_top.v
    alt_e100_bridge.v
  } {ALT_E100_FS_TOP}
  
  ::alt_xcvr::utils::fileset::common_fileset_group_plain ./adapter/rx "$path/100gbe/rtl_src/adapter/rx" {
    alt_e100_adapter_rx.v
    alt_e100_wide_buffered_read_scheduler.v
    alt_e100_wide_compact_words_8.v
    alt_e100_wide_l8if_rx528.v
    alt_e100_wide_l8if_rxfifo.v
    alt_e100_wide_regroup_8.v
    alt_e100_wide_six_three_comp.v
    alt_e100_wide_wide_word_ram_8.v
  } {ALT_E100_FS_ADAPTER_RX}
  
  ::alt_xcvr::utils::fileset::common_fileset_group_plain ./adapter/tx "$path/100gbe/rtl_src/adapter/tx" {
    alt_e100_adapter_tx.v
    alt_e100_wide_l8if_tx825.v
    alt_e100_wide_l8if_tx825fifo.v
    alt_e100_wide_l8if_txfifo.v
  } {ALT_E100_FS_ADAPTER_TX}
  
  ::alt_xcvr::utils::fileset::common_fileset_group_plain ./common "$path/100gbe/rtl_src/common" {
    alt_e100_lock_timer.v
    alt_e100_six_three_comp.v
    alt_e100_status_sync.v
    alt_e100_sticky_flag.v
    alt_e100_sync_arst.v
    alt_e100_user_mode_det.v
  } {ALT_E100_FS_COMMON}
  
  ::alt_xcvr::utils::fileset::common_fileset_group_encrypted ./mac "$path/100gbe/rtl_src/mac" {
    alt_e100_mac.v
  } {ALT_E100_FS_MAC}
  
  ::alt_xcvr::utils::fileset::common_fileset_group ./mac "$path/100gbe/rtl_src/mac" OTHER {
	alt_e100_mac.ocp
  } {ALT_E100_FS_MAC_OCP} {QENCRYPT}
  
  ::alt_xcvr::utils::fileset::common_fileset_group_encrypted ./mac/common "$path/100gbe/rtl_src/mac/common" {
    alt_e100_crc32_d64_sig.v
    alt_e100_crc32_rev_1.v
    alt_e100_crc32_rev_2.v
    alt_e100_crc32_rev_4.v
    alt_e100_crc32_z64_x1.v
    alt_e100_crc32_z64_x2.v
    alt_e100_crc32_z64_x3.v
    alt_e100_crc32_z64_x4.v
    alt_e100_crc32_z64_x5.v
    alt_e100_fcs_100g.v
    alt_e100_insert_parity.v
    alt_e100_remove_parity.v
    alt_e100_reverse_words.v
    alt_e100_stat_cntr_1port.v
    alt_e100_stat_cntr_5port.v
  } {ALT_E100_FS_MAC_COMMON}
  
  ::alt_xcvr::utils::fileset::common_fileset_group_encrypted ./mac/csr "$path/100gbe/rtl_src/mac/csr" {
    alt_e100_mac_addr_regs.v
    alt_e100_mac_csr.v
    alt_e100_status_cntr_pause_sync.v
  } {ALT_E100_FS_MAC_CSR}
  
  ::alt_xcvr::utils::fileset::common_fileset_group_encrypted ./mac/rx "$path/100gbe/rtl_src/mac/rx" {
    alt_e100_doe_cmd_fifo.v
    alt_e100_doe_fifo.v
    alt_e100_doe_storage_ram.v
    alt_e100_dst_addr_chk.v
    alt_e100_m9k_with_par.v
    alt_e100_mac_link_fault_det.v
    alt_e100_mac_link_fault_det_ns.v
    alt_e100_mac_rx.v
    alt_e100_mac_rx_stats.v
    alt_e100_mlab_delay.v
    alt_e100_mlab_sr_cells.v
    alt_e100_pause_chk.v
    alt_e100_runt_comparator.v
    alt_e100_runt_detect.v
    alt_e100_rx_inspect_100g.v
    alt_e100_rx_pad_strip.v
    alt_e100_rx_preamble_passthrough.v
  } {ALT_E100_FS_MAC_RX}
  
  ::alt_xcvr::utils::fileset::common_fileset_group_encrypted ./mac/tx "$path/100gbe/rtl_src/mac/tx" {
    alt_e100_cgmii_rom.v
    alt_e100_crc_fifo.v
    alt_e100_gap_monitor.v
    alt_e100_gap_monitor_ns.v
    alt_e100_idle_count.v
    alt_e100_inline_padder.v
    alt_e100_mac_link_fault_gen.v
    alt_e100_mac_tx.v
    alt_e100_mac_tx_stats.v
    alt_e100_pause_dp.v
    alt_e100_pause_ebuf.v
    alt_e100_src_addr_ovr.v
    alt_e100_tx_preamble_passthrough.v
    alt_e100_tx_prespace.v
    alt_e100_tx_spacer.v
    alt_e100_tx_to_mii.v
    alt_e100_wide_word_ram_8.v
  } {ALT_E100_FS_MAC_TX}
  
  
  ::alt_xcvr::utils::fileset::common_fileset_group_encrypted ./phy "$path/100gbe/rtl_src/phy" {
    alt_e100_phy.v
  } {ALT_E100_FS_PHY}
  
  ::alt_xcvr::utils::fileset::common_fileset_group_encrypted ./phy/csr "$path/100gbe/rtl_src/phy/csr" {
    alt_e100_frequency_monitor.v
    alt_e100_phy_csr.v
    alt_e100_phy_csr_caui4.v
    alt_e100_status_cntr_sync.v
    alt_e100_sticky_flag_group.v
  } {ALT_E100_FS_PHY_CSR}
  
  ::alt_xcvr::utils::fileset::common_fileset_group_encrypted ./phy/pcs "$path/100gbe/rtl_src/phy/pcs" {
    alt_e100_phy_pcs.v
  } {ALT_E100_FS_PHY_PCS}
  
  ::alt_xcvr::utils::fileset::common_fileset_group ./phy/pcs "$path/100gbe/rtl_src/phy/pcs" OTHER {
	alt_e100_phy_pcs.ocp
  } {ALT_E100_FS_PHY_PCS_OCP} {QENCRYPT}
  
    ::alt_xcvr::utils::fileset::common_fileset_group_encrypted ./phy/pcs "$path/100gbe/rtl_src/phy/pcs" {
    alt_e100_phy_pcs_caui4.v
  } {ALT_E100_FS_PHY_PCS_CAUI4}
  
    ::alt_xcvr::utils::fileset::common_fileset_group ./phy/pcs "$path/100gbe/rtl_src/phy/pcs" OTHER {
	alt_e100_phy_pcs_caui4.ocp
  } {ALT_E100_FS_PHY_PCS_CAUI4_OCP} {QENCRYPT}
  
  ::alt_xcvr::utils::fileset::common_fileset_group_encrypted ./phy/pcs/common "$path/100gbe/rtl_src/phy/pcs/common" {
    alt_e100_gray_to_bin.v
    alt_e100_mlab_dcfifo.v
    alt_e100_mlab_fifo_cells.v
    alt_e100_random_delay.v
  } {ALT_E100_FS_PHY_PCS_COMMON}
  
   ::alt_xcvr::utils::fileset::common_fileset_group_encrypted ./phy/pcs/common "$path/100gbe/rtl_src/phy/pcs/common" {
    alt_e100_mlab_dcfifo_caui4.v
    alt_e100_mlab_fifo_cells_caui4.v
  } {ALT_E100_FS_PHY_PCS_COMMON_CAUI4}
  
  ::alt_xcvr::utils::fileset::common_fileset_group_encrypted ./phy/pcs/rx "$path/100gbe/rtl_src/phy/pcs/rx" {
    alt_e100_block_decoder.v
    alt_e100_block_decoder_ns.v
    alt_e100_descrambler.v
    alt_e100_framed_descrambler.v
    alt_e100_gearbox_20_22.v
    alt_e100_gearbox_20_66.v
    alt_e100_lane_marker_compare.v
    alt_e100_lane_marker_lock.v
    alt_e100_mii_decode_multiple.v
    alt_e100_pcs_ber.v
    alt_e100_pcs_ber_cnt_ns.v
    alt_e100_pcs_ber_sm.v
    alt_e100_pcs_rx.v
    alt_e100_pcs_rx_testmode.v
    alt_e100_prbs_rx.v
    alt_e100_reorder_destripe.v
    alt_e100_reorder_destripe_helper.v
    alt_e100_reorder_destripe_helper_group.v
    alt_e100_rx_lane_array.v
    alt_e100_rx_lane_pair.v
    alt_e100_rx_nav_region.v
    alt_e100_word_align_control.v
  } {ALT_E100_FS_PHY_PCS_RX}
  
    ::alt_xcvr::utils::fileset::common_fileset_group_encrypted ./phy/pcs/rx "$path/100gbe/rtl_src/phy/pcs/rx" {
    alt_e100_lane_marker_lock_caui4.v
    alt_e100_pcs_rx_caui4.v
    alt_e100_prbs_rx_caui4.v
    alt_e100_rx_5lanes_caui4.v
    alt_e100_rx_gearbox_26_66_caui4.v
    alt_e100_rx_lane_array_caui4.v
  } {ALT_E100_FS_PHY_PCS_RX_CAUI4}
  
    ::alt_xcvr::utils::fileset::common_fileset_group_encrypted ./phy/pcs/tx "$path/100gbe/rtl_src/phy/pcs/tx" {
    alt_e100_block_encoder.v
    alt_e100_block_encoder_ns.v
    alt_e100_framed_scrambler.v
    alt_e100_gearbox_66_20.v
    alt_e100_mii_encode_multiple.v
    alt_e100_pcs_tx.v
    alt_e100_prbs_tx.v
    alt_e100_scrambler.v
    alt_e100_tx_lane_array.v
    alt_e100_tx_lane_pair.v
    alt_e100_tx_nav_region.v
  } {ALT_E100_FS_PHY_PCS_TX}
  
  ::alt_xcvr::utils::fileset::common_fileset_group_encrypted ./phy/pcs/tx "$path/100gbe/rtl_src/phy/pcs/tx" {
    alt_e100_pcs_tx_caui4.v
    alt_e100_prbs_tx_caui4.v
    alt_e100_tx_5lanes_caui4.v
    alt_e100_tx_gearbox_330_128_caui4.v
    alt_e100_tx_lane_array_caui4.v
  } {ALT_E100_FS_PHY_PCS_TX_CAUI4}
  
  
    ::alt_xcvr::utils::fileset::common_fileset_group_plain ./phy/pma_a10 "$path/100gbe/rtl_src/phy/pma_a10" {
    alt_e100_phy_pma_a10.v
  } {ALT_E100_FS_PHY_PMA_A10}
  
  ::alt_xcvr::utils::fileset::common_fileset_group_plain ./phy/pma_siv "$path/100gbe/rtl_src/phy/pma_siv" {
    alt_e100_phy_pma_siv.v
    alt_e100_reset_delay.v
  } {ALT_E100_FS_PHY_PMA_SIV}
  
  ::alt_xcvr::utils::fileset::common_fileset_group_plain ./phy/pma_sv "$path/100gbe/rtl_src/phy/pma_sv" {
    alt_e100_phy_pma_sv.v
  } {ALT_E100_FS_PHY_PMA_SV}
  
  ::alt_xcvr::utils::fileset::common_fileset_group_plain ./phy/pma_sv_caui4 "$path/100gbe/rtl_src/phy/pma_sv_caui4" {
    alt_e100_phy_pma_sv_caui4.v
  } {ALT_E100_FS_PHY_PMA_SV_CAUI4}
  
  ::alt_xcvr::utils::fileset::common_fileset_group_plain ./phy/pma_sv_bridge "$path/100gbe/rtl_src/phy/pma_sv_bridge" {
    alt_e100_pma_sv_bridge.v
  } {ALT_E100_FS_PHY_PMA_SV_BRIDGE}
  
  ::alt_xcvr::utils::fileset::common_fileset_group_plain ./phy/pma_sv_bridge_caui4 "$path/100gbe/rtl_src/phy/pma_sv_bridge_caui4" {
    alt_e100_pma_sv_bridge_caui4.v
  } {ALT_E100_FS_PHY_PMA_SV_BRIDGE_CAUI4}
  

    ::alt_xcvr::utils::fileset::common_fileset_group_plain ./top "$path/40gbe/rtl_src/top" {
    alt_e40_top.v
    alt_e40_bridge.v
  } {ALT_E40_FS_TOP}
  
  ::alt_xcvr::utils::fileset::common_fileset_group_plain ./adapter/rx "$path/40gbe/rtl_src/adapter/rx" {
    alt_e40_adapter_rx.v
    alt_e40_wide_l4if_rx2to4.v
    alt_e40_wide_l4if_rx2to4fifo.v
    alt_e40_wide_l4if_rxfifo.v
    alt_e40_wide_l4if_sopfifo.v
  } {ALT_E40_FS_ADAPTER_RX}
  
  ::alt_xcvr::utils::fileset::common_fileset_group_plain ./adapter/tx "$path/40gbe/rtl_src/adapter/tx" {
    alt_e40_adapter_tx.v
    alt_e40_wide_l4if_tx4to2.v
    alt_e40_wide_l4if_tx4to2fifo.v
    alt_e40_wide_l4if_txfifo.v
  } {ALT_E40_FS_ADAPTER_TX}
  
  ::alt_xcvr::utils::fileset::common_fileset_group_plain ./common "$path/40gbe/rtl_src/common" {
    alt_e40_lock_timer.v
    alt_e40_status_sync.v
    alt_e40_sticky_flag.v
    alt_e40_sync_arst.v
    alt_e40_user_mode_det.v
  } {ALT_E40_FS_COMMON}
  
  ::alt_xcvr::utils::fileset::common_fileset_group_encrypted ./mac "$path/40gbe/rtl_src/mac" {
    alt_e40_mac.v
  } {ALT_E40_FS_MAC}
  
  ::alt_xcvr::utils::fileset::common_fileset_group ./mac "$path/40gbe/rtl_src/mac" OTHER {
	alt_e40_mac.ocp
  } {ALT_E40_FS_MAC_OCP} {QENCRYPT}
  
  ::alt_xcvr::utils::fileset::common_fileset_group_encrypted ./mac/common "$path/40gbe/rtl_src/mac/common" {
    alt_e40_crc32_d64_sig.v
    alt_e40_crc32_rev_1.v
    alt_e40_crc32_rev_2.v
    alt_e40_crc32_rev_4.v
    alt_e40_crc32_z64_x1.v
    alt_e40_crc32_z64_x2.v
    alt_e40_fcs_40g.v
    alt_e40_insert_parity.v
    alt_e40_mlab_delay.v
    alt_e40_mlab_sr_cells.v
    alt_e40_remove_parity.v
    alt_e40_reverse_words.v
    alt_e40_six_three_comp.v
    alt_e40_stat_cntr_1port.v
    alt_e40_stat_cntr_2port.v
  } {ALT_E40_FS_MAC_COMMON}
  
  ::alt_xcvr::utils::fileset::common_fileset_group_encrypted ./mac/csr "$path/40gbe/rtl_src/mac/csr" {
    alt_e40_mac_addr_regs.v
    alt_e40_mac_csr.v
    alt_e40_status_cntr_pause_sync.v
  } {ALT_E40_FS_MAC_CSR}
  
  ::alt_xcvr::utils::fileset::common_fileset_group_encrypted ./mac/rx "$path/40gbe/rtl_src/mac/rx" {
    alt_e40_doe_cmd_fifo.v
    alt_e40_doe_fifo.v
    alt_e40_doe_storage_ram.v
    alt_e40_dst_addr_chk.v
    alt_e40_m9k_with_par.v
    alt_e40_mac_link_fault_det.v
    alt_e40_mac_link_fault_det_ns.v
    alt_e40_mac_rx.v
    alt_e40_mac_rx_stats.v
    alt_e40_pause_chk.v
    alt_e40_runt_comparator.v
    alt_e40_runt_detect.v
    alt_e40_rx_inspect_40g.v
    alt_e40_rx_pad_strip.v
    alt_e40_rx_preamble_passthrough.v
  } {ALT_E40_FS_MAC_RX}
  
  ::alt_xcvr::utils::fileset::common_fileset_group_encrypted ./mac/tx "$path/40gbe/rtl_src/mac/tx" {
    alt_e40_gap_monitor.v
    alt_e40_gap_monitor_ns.v
    alt_e40_idle_count.v
    alt_e40_mac_link_fault_gen.v
    alt_e40_mac_tx.v
    alt_e40_mac_tx_stats.v
    alt_e40_pause_dp.v
    alt_e40_pause_ebuf.v
    alt_e40_sum_of_3bit_pair.v
    alt_e40_twelve_four_comp.v
    alt_e40_tx_pad_and_spacer.v
    alt_e40_tx_preamble_passthrough.v
    alt_e40_tx_to_mii.v
    alt_e40_xlgmii_rom.v
  } {ALT_E40_FS_MAC_TX}
  
  
  ::alt_xcvr::utils::fileset::common_fileset_group_encrypted ./phy "$path/40gbe/rtl_src/phy" {
    alt_e40_phy.v
  } {ALT_E40_FS_PHY}
  
  ::alt_xcvr::utils::fileset::common_fileset_group_encrypted ./phy/csr "$path/40gbe/rtl_src/phy/csr" {
    alt_e40_frequency_monitor.v
    alt_e40_phy_csr.v
    alt_e40_status_cntr_sync.v
    alt_e40_sticky_flag_group.v
  } {ALT_E40_FS_PHY_CSR}
  
  ::alt_xcvr::utils::fileset::common_fileset_group_encrypted ./phy/pcs "$path/40gbe/rtl_src/phy/pcs" {
    alt_e40_phy_pcs.v
  } {ALT_E40_FS_PHY_PCS}
  
  ::alt_xcvr::utils::fileset::common_fileset_group ./phy/pcs "$path/40gbe/rtl_src/phy/pcs" OTHER {
	alt_e40_phy_pcs.ocp
  } {ALT_E40_FS_PHY_PCS_OCP} {QENCRYPT}
  
  ::alt_xcvr::utils::fileset::common_fileset_group_encrypted ./phy/pcs/common "$path/40gbe/rtl_src/phy/pcs/common" {
    alt_e40_gray_to_bin.v
    alt_e40_mlab_dcfifo.v
    alt_e40_mlab_fifo_cells.v
    alt_e40_random_delay.v
  } {ALT_E40_FS_PHY_PCS_COMMON}
  
  ::alt_xcvr::utils::fileset::common_fileset_group_encrypted ./phy/pcs/rx "$path/40gbe/rtl_src/phy/pcs/rx" {
    alt_e40_block_decoder.v
    alt_e40_block_decoder_ns.v
    alt_e40_descrambler.v
    alt_e40_framed_descrambler.v
    alt_e40_gearbox_40_66.v
    alt_e40_lane_marker_compare.v
    alt_e40_lane_marker_lock.v
    alt_e40_mii_decode_multiple.v
    alt_e40_pcs_ber.v
    alt_e40_pcs_ber_cnt_ns.v
    alt_e40_pcs_ber_sm.v
    alt_e40_pcs_rx.v
    alt_e40_pcs_rx_testmode.v
    alt_e40_prbs_rx.v
    alt_e40_reorder_destripe.v
    alt_e40_rx_lane.v
    alt_e40_rx_lane_array.v
    alt_e40_rx_nav_region.v
    alt_e40_word_align_control.v
  } {ALT_E40_FS_PHY_PCS_RX}
  
    ::alt_xcvr::utils::fileset::common_fileset_group_encrypted ./phy/pcs/tx "$path/40gbe/rtl_src/phy/pcs/tx" {
    alt_e40_block_encoder.v
    alt_e40_block_encoder_ns.v
    alt_e40_framed_scrambler.v
    alt_e40_gearbox_66_40.v
    alt_e40_mii_encode_multiple.v
    alt_e40_pcs_tx.v
    alt_e40_prbs_tx.v
    alt_e40_scrambler.v
    alt_e40_tx_lane.v
    alt_e40_tx_lane_array.v
    alt_e40_tx_nav_region.v
  } {ALT_E40_FS_PHY_PCS_TX}
  
    ::alt_xcvr::utils::fileset::common_fileset_group_plain ./phy/pma_a10 "$path/40gbe/rtl_src/phy/pma_a10" {
    alt_e40_phy_pma_a10.v
  } {ALT_E40_FS_PHY_PMA_A10}
  
  ::alt_xcvr::utils::fileset::common_fileset_group_plain ./phy/pma_siv "$path/40gbe/rtl_src/phy/pma_siv" {
    alt_e40_phy_pma_siv.v
    alt_e40_reset_delay.v
  } {ALT_E40_FS_PHY_PMA_SIV}
  
  ::alt_xcvr::utils::fileset::common_fileset_group_plain ./phy/pma_sv "$path/40gbe/rtl_src/phy/pma_sv" {
    alt_e40_phy_pma_sv.v
  } {ALT_E40_FS_PHY_PMA_SV}
  
  ::alt_xcvr::utils::fileset::common_fileset_group_plain ./phy/pma_sv_bridge "$path/40gbe/rtl_src/phy/pma_sv_bridge" {
    alt_e40_pma_sv_bridge.v
  } {ALT_E40_FS_PHY_PMA_SV_BRIDGE}
  
  #for KR4
  
  # Native PHY files
  ::altera_xcvr_native_sv::fileset::declare_files
  
  # Reset controller files
  ::altera_xcvr_reset_control::fileset::declare_files
  
  # Common PHY IP files
  set phypath [::alt_xcvr::utils::fileset::abs_to_rel_path [::alt_xcvr::utils::fileset::get_altera_xcvr_generic_path]]

  ::alt_xcvr::utils::fileset::common_fileset_group_plain ./ "${phypath}/ctrl/" {
    alt_xcvr_csr_common_h.sv
    alt_xcvr_csr_common.sv
    alt_xcvr_csr_selector.sv
    altera_wait_generate.v
  } {ALT_E40_KR4_SV}
  
  # altera_xcvr_reset_control files
  set rstpath [::alt_xcvr::utils::fileset::get_alt_xcvr_path]
  set rstpath "${rstpath}/altera_xcvr_reset_control"
  set rstpath [::alt_xcvr::utils::fileset::abs_to_rel_path $rstpath]
  ::alt_xcvr::utils::fileset::common_fileset_group_plain ./ $rstpath {
    altera_xcvr_reset_control.sv
    alt_xcvr_reset_counter.sv
  } {ALT_E40_KR4_SV}

  # Declare unencrypted common KR files
  ::alt_xcvr::utils::fileset::common_fileset_group_plain ./kr4_sv/common_src "$path/40gbe/rtl_src/kr4_sv/common_src" {
    alt_e40_csr_krtop_h.sv
    alt_e40_csr_kran.sv
    alt_e40_csr_krlt.sv
    alt_e40_csr_krtop.sv
    alt_e40_csr_krfec.sv
    alt_e40_seq_sm.sv
  } {ALT_E40_KR4_SV}

  # Declare unencrypted KR4 top files
  ::alt_xcvr::utils::fileset::common_fileset_group_plain ./kr4_sv "$path/40gbe/rtl_src/kr4_sv" {
    alt_e40_gearbox_64_66.v
    alt_e40_gearbox_66_64.v
    alt_e40_kr4_lane.v
    alt_e40_pma_sv_kr4.v
  } {ALT_E40_KR4_SV}
  
 # Declare encrypted common KR files
  ::alt_xcvr::utils::fileset::common_fileset_group_encrypted ./kr4_sv/common_src "$path/40gbe/rtl_src/kr4_sv/common_src" {
    alt_e40_an_arb_sm.sv
    alt_e40_an_decode.sv
    alt_e40_an_rx_sm.sv
    alt_e40_an_top.sv
    alt_e40_an_tx_sm.sv
    alt_e40_lt_cf_update.sv
    alt_e40_lt_coef_mstr.sv
    alt_e40_lt_frame_lock.sv
    alt_e40_lt_lcl_coef.sv
    alt_e40_lt_rmt_opt.sv
    alt_e40_lt_rmt_txeq.sv
    alt_e40_lt_rx_data.sv
    alt_e40_lt_rx_gbx.sv
    alt_e40_lt_top.sv
    alt_e40_lt_tx_data.sv
    alt_e40_lt_tx_gbx.sv
    alt_e40_lt_tx_train.sv
    alt_e40_six_two_comp.sv
  } {ALT_E40_KR4_SV}
  
  # Declare encrypted KR4 top files
  ::alt_xcvr::utils::fileset::common_fileset_group_encrypted ./kr4_sv "$path/40gbe/rtl_src/kr4_sv" {
    alt_e40_fec_valid_gen.v
    alt_e40_seq_reco_n.v
  } {ALT_E40_KR4_SV}
  
  # Declare encrypted FEC KR files
  ::alt_xcvr::utils::fileset::common_fileset_group_encrypted ./kr4_sv/sv_fec "$path/40gbe/rtl_src/kr4_sv/sv_fec" {
    alt_e40_dpcmn_bitsync.v
    alt_e40_dpcmn_bitsync2.v
    alt_e40_dpcmn_dprio_shadow_status_regs.v
    alt_e40_krfec.v
    alt_e40_krfec_blksync.v
    alt_e40_krfec_chk4_syndrm.v
    alt_e40_krfec_cmpt4syndrm_chk.v
    alt_e40_krfec_cmpt_syndrm.v
    alt_e40_krfec_decoder.v
    alt_e40_krfec_decoder_master_sm.v
    alt_e40_krfec_decoder_rd_sm.v
    alt_e40_krfec_decoder_sm.v
    alt_e40_krfec_descrm.v
    alt_e40_krfec_dpbuff.v
    alt_e40_krfec_encoder.v
    alt_e40_krfec_errcorrect.v
    alt_e40_krfec_errtrap.v
    alt_e40_krfec_errtrap_ind.v
    alt_e40_krfec_errtrap_lfsr.v
    alt_e40_krfec_errtrap_loc.v
    alt_e40_krfec_errtrap_pat.v
    alt_e40_krfec_errtrap_sm.v
    alt_e40_krfec_fast_search.v
    alt_e40_krfec_fast_search_sm.v
    alt_e40_krfec_gearbox_exp.v
    alt_e40_krfec_gearbox_red.v
    alt_e40_krfec_gx_64b.v
    alt_e40_krfec_head_tail_gen.v
    alt_e40_krfec_lock_sm.v
    alt_e40_krfec_nto1mux.v
    alt_e40_krfec_parity_chk.v
    alt_e40_krfec_parity_gen.v
    alt_e40_krfec_pulse_stretch.v
    alt_e40_krfec_rx_async_pld_out.v
    alt_e40_krfec_rx_chnl.v
    alt_e40_krfec_rx_testbus.v
    alt_e40_krfec_rxrst_ctrl.v
    alt_e40_krfec_scramble.v
    alt_e40_krfec_shf1_syndrm.v
    alt_e40_krfec_shf2_syndrm.v
    alt_e40_krfec_shf3_syndrm.v
    alt_e40_krfec_shf4_syndrm.v
    alt_e40_krfec_syndrm_sm.v
    alt_e40_krfec_top_wrapper.v
    alt_e40_krfec_transcode_dec.v
    alt_e40_krfec_transcode_enc.v
    alt_e40_krfec_tx_async_pld_out.v
    alt_e40_krfec_tx_chnl.v
    alt_e40_krfec_tx_testbus.v
    alt_e40_krfec_wdalign.v
  } {ALT_E40_KR4_SV}

}

proc ::alt_e40_e100::fileset::register_fileset {params} {
  
  set MAC_CONFIG    [::alt_xcvr::ip_tcl::ip_module::ip_get "parameter.MAC_CONFIG.value"   ]
  set DEVICE_FAMILY [::alt_xcvr::ip_tcl::ip_module::ip_get "parameter.DEVICE_FAMILY.value"]
  set VARIANT       [::alt_xcvr::ip_tcl::ip_module::ip_get "parameter.VARIANT.value"      ]
  set INTERFACE     [::alt_xcvr::ip_tcl::ip_module::ip_get "parameter.INTERFACE.value"    ]
  set PHY_CONFIG    [::alt_xcvr::ip_tcl::ip_module::ip_get "parameter.PHY_CONFIG.value"   ]
  set CORE_OPTION   [::alt_xcvr::ip_tcl::ip_module::ip_get "parameter.CORE_OPTION.value"  ]
  set IS_CAUI4      [::alt_xcvr::ip_tcl::ip_module::ip_get "parameter.IS_CAUI4.value"  ]
  set ENA_KR4       [::alt_xcvr::ip_tcl::ip_module::ip_get "parameter.ENA_KR4.value"  ]
  
  
  
  if {$MAC_CONFIG == "100 Gbe"} {
	  common_add_fileset_files {ALT_E100_FS_TOP} $params
	  common_add_fileset_files {ALT_E100_FS_COMMON} $params
	  
	  if {$INTERFACE == "Avalon-ST Interface" && ($CORE_OPTION == "MAC & PHY" || $CORE_OPTION == "MAC only")} {
		if {$VARIANT == 1} {
			common_add_fileset_files {ALT_E100_FS_ADAPTER_RX} $params
		 } elseif {$VARIANT == 2} {
			common_add_fileset_files {ALT_E100_FS_ADAPTER_TX} $params
		 } else {
			common_add_fileset_files {ALT_E100_FS_ADAPTER_RX} $params
			common_add_fileset_files {ALT_E100_FS_ADAPTER_TX} $params
		 }
	  }
	  
	  if {$CORE_OPTION == "MAC & PHY" || $CORE_OPTION == "MAC only"} {
		 common_add_fileset_files {ALT_E100_FS_MAC} $params
		 common_add_fileset_files {ALT_E100_FS_MAC_OCP} {QENCRYPT}
	     common_add_fileset_files {ALT_E100_FS_MAC_COMMON} $params
	     common_add_fileset_files {ALT_E100_FS_MAC_CSR} $params
	     
		 if {$VARIANT == 1} {
			common_add_fileset_files {ALT_E100_FS_MAC_RX} $params
		 } elseif {$VARIANT == 2} {
			common_add_fileset_files {ALT_E100_FS_MAC_TX} $params
		 } else {
			common_add_fileset_files {ALT_E100_FS_MAC_RX} $params
			common_add_fileset_files {ALT_E100_FS_MAC_TX} $params
		 }
	  }

	  if {$CORE_OPTION == "MAC & PHY" || $CORE_OPTION == "PHY only"} {
		  if {$DEVICE_FAMILY == "Stratix IV"} {
			common_add_fileset_files {ALT_E100_FS_PHY_PMA_SIV} $params
		  } elseif {$DEVICE_FAMILY == "Stratix V" || $DEVICE_FAMILY == "Arria V GZ"} {
			
			
			if {$IS_CAUI4} {
				common_add_fileset_files {ALT_E100_FS_PHY_PCS_COMMON_CAUI4} $params
				common_add_fileset_files {ALT_E100_FS_PHY_PCS_CAUI4} $params
				common_add_fileset_files {ALT_E100_FS_PHY_PCS_CAUI4_OCP} {QENCRYPT}
				common_add_fileset_files {ALT_E100_FS_PHY_PCS_RX_CAUI4} $params
				common_add_fileset_files {ALT_E100_FS_PHY_PCS_TX_CAUI4} $params
				common_add_fileset_files {ALT_E100_FS_PHY_PMA_SV_CAUI4} $params
				common_add_fileset_files {ALT_E100_FS_PHY_PMA_SV_BRIDGE_CAUI4} $params
			} else {
				common_add_fileset_files {ALT_E100_FS_PHY_PMA_SV} $params
				common_add_fileset_files {ALT_E100_FS_PHY_PMA_SV_BRIDGE} $params
			}
			
			
		  } elseif {$DEVICE_FAMILY == "Arria 10"} {
			common_add_fileset_files {ALT_E100_FS_PHY_PMA_A10} $params
		  }
		  
		 common_add_fileset_files {ALT_E100_FS_PHY} $params
	     common_add_fileset_files {ALT_E100_FS_PHY_CSR} $params
	     common_add_fileset_files {ALT_E100_FS_PHY_PCS} $params
		 common_add_fileset_files {ALT_E100_FS_PHY_PCS_OCP} {QENCRYPT}
	     common_add_fileset_files {ALT_E100_FS_PHY_PCS_COMMON} $params
	     
		 if {$VARIANT == 1} {
			common_add_fileset_files {ALT_E100_FS_PHY_PCS_RX} $params
		 } elseif {$VARIANT == 2} {
			common_add_fileset_files {ALT_E100_FS_PHY_PCS_TX} $params
		 } else {
			common_add_fileset_files {ALT_E100_FS_PHY_PCS_RX} $params
			common_add_fileset_files {ALT_E100_FS_PHY_PCS_TX} $params			
		 }
	  }
  
  } else {
  
  
	  common_add_fileset_files {ALT_E40_FS_TOP} $params
	  common_add_fileset_files {ALT_E40_FS_COMMON} $params
	  
	  if {$INTERFACE == "Avalon-ST Interface" && ($CORE_OPTION == "MAC & PHY" || $CORE_OPTION == "MAC only")} {
		if {$VARIANT == 1} {
			common_add_fileset_files {ALT_E40_FS_ADAPTER_RX} $params
		 } elseif {$VARIANT == 2} {
			common_add_fileset_files {ALT_E40_FS_ADAPTER_TX} $params
		 } else {
			common_add_fileset_files {ALT_E40_FS_ADAPTER_RX} $params
			common_add_fileset_files {ALT_E40_FS_ADAPTER_TX} $params
		 }
	  }
	  
	  if {$CORE_OPTION == "MAC & PHY" || $CORE_OPTION == "MAC only"} {
		 common_add_fileset_files {ALT_E40_FS_MAC} $params
		 common_add_fileset_files {ALT_E40_FS_MAC_OCP} {QENCRYPT}
	     common_add_fileset_files {ALT_E40_FS_MAC_COMMON} $params
	     common_add_fileset_files {ALT_E40_FS_MAC_CSR} $params
	     
		 if {$VARIANT == 1} {
			common_add_fileset_files {ALT_E40_FS_MAC_RX} $params
		 } elseif {$VARIANT == 2} {
			common_add_fileset_files {ALT_E40_FS_MAC_TX} $params
		 } else {
			common_add_fileset_files {ALT_E40_FS_MAC_RX} $params
			common_add_fileset_files {ALT_E40_FS_MAC_TX} $params
		 }
	  }

	  if {$CORE_OPTION == "MAC & PHY" || $CORE_OPTION == "PHY only"} {
		  if {$DEVICE_FAMILY == "Stratix IV"} {
			common_add_fileset_files {ALT_E40_FS_PHY_PMA_SIV} $params
		  } elseif {$DEVICE_FAMILY == "Stratix V" || $DEVICE_FAMILY == "Arria V GZ"} {
			common_add_fileset_files {ALT_E40_FS_PHY_PMA_SV} $params
			common_add_fileset_files {ALT_E40_FS_PHY_PMA_SV_BRIDGE} $params
			
		  } elseif {$DEVICE_FAMILY == "Arria 10"} {
			common_add_fileset_files {ALT_E40_FS_PHY_PMA_A10} $params
		  }
		  
		 common_add_fileset_files {ALT_E40_FS_PHY} $params
	     common_add_fileset_files {ALT_E40_FS_PHY_CSR} $params
	     common_add_fileset_files {ALT_E40_FS_PHY_PCS} $params
		 common_add_fileset_files {ALT_E40_FS_PHY_PCS_OCP} {QENCRYPT}
	     common_add_fileset_files {ALT_E40_FS_PHY_PCS_COMMON} $params
		 

		 if {$VARIANT == 1} {
			common_add_fileset_files {ALT_E40_FS_PHY_PCS_RX} $params
		 } elseif {$VARIANT == 2} {
			common_add_fileset_files {ALT_E40_FS_PHY_PCS_TX} $params
		 } else {
			common_add_fileset_files {ALT_E40_FS_PHY_PCS_RX} $params
			common_add_fileset_files {ALT_E40_FS_PHY_PCS_TX} $params	
			if {$ENA_KR4 && [::alt_xcvr::utils::device::has_s5_style_hssi $DEVICE_FAMILY]} {
				common_add_fileset_files {ALT_E40_KR4_SV} $params
			}
		 }
	  }  
  }
}

proc gen_pma { {sim 0} } {

    set     variant                   [::alt_xcvr::ip_tcl::ip_module::ip_get "parameter.VARIANT.value"      ]
    set     phy_refclk                [::alt_xcvr::ip_tcl::ip_module::ip_get "parameter.PHY_REFCLK.value"      ]
	set		mac_config                [::alt_xcvr::ip_tcl::ip_module::ip_get "parameter.MAC_CONFIG.value"		]
	set     phy_config                [get_parameter_value PHY_CONFIG]
    set     QUARTUS_ROOTDIR           $::env(QUARTUS_ROOTDIR)
    set     TMP                       $::env(TMP)
    
    set dest_dir "phy/pma_siv"
    set temp_dir "$TMP/pma_siv"
	
    
    if {$variant == 1} {
		if {$mac_config == "100 Gbe"} {
			set base_name "alt_e100_rx_e10x10"
			set base_dir  "../100gbe/rtl_src/phy/pma_siv/alt_e100_rx_e10x10"
		} else {
			set base_name "alt_e40_rx_e4x10"
			set base_dir  "../40gbe/rtl_src/phy/pma_siv/alt_e40_rx_e4x10"		
		}
    } elseif {$variant == 2} {
		if {$mac_config == "100 Gbe"} {
			set base_name "alt_e100_tx_e10x10"
			set base_dir  "../100gbe/rtl_src/phy/pma_siv/alt_e100_tx_e10x10"
		} else {
			set base_name "alt_e40_tx_e4x10"
			set base_dir  "../40gbe/rtl_src/phy/pma_siv/alt_e40_tx_e4x10"		
		}
    } else {
		if {$mac_config == "100 Gbe"} {
			set base_name "alt_e100_e10x10"
			set base_dir  "../100gbe/rtl_src/phy/pma_siv/alt_e100_e10x10"
		} else {
			set base_name "alt_e40_e4x10"
			set base_dir  "../40gbe/rtl_src/phy/pma_siv/alt_e40_e4x10"		
		}
    }
    
    file mkdir $temp_dir
    
    set src_file "$base_dir/${base_name}_base.v"
    set dest_file "$temp_dir/$base_name.v"
    
    if {[file type $src_file] != "file"} {
        exec cp -f $src_file $dest_file
    } else {
        file copy -force -- $src_file $dest_file
    }
    #file attributes $dest_file -readonly 0
    
    set outfile [open $dest_file a]
    	
    if {$phy_refclk == 1 && $phy_config == 2 && $mac_config == "40 Gbe"} {
        puts $outfile "// Retrieval info: PRIVATE: WIZ_BASE_DATA_RATE STRING \"6250\""
		puts $outfile "// Retrieval info: PRIVATE: WIZ_DATA_RATE STRING \"6250\""
		puts $outfile "// Retrieval info: PRIVATE: WIZ_DPRIO_REF_CLK0_FREQ STRING \"390.625\""
		puts $outfile "// Retrieval info: PRIVATE: WIZ_INCLK_FREQ STRING \"390.625\""
		puts $outfile "// Retrieval info: PRIVATE: WIZ_INCLK_FREQ_ARRAY STRING \"195.3125 390.625\""
		puts $outfile "// Retrieval info: PRIVATE: WIZ_INPUT_A STRING \"6250\""
		puts $outfile "// Retrieval info: PRIVATE: WIZ_INPUT_B STRING \"390.625\""	
	} elseif {$phy_refclk == 2 && $phy_config == 2 && $mac_config == "40 Gbe"} {
        puts $outfile "// Retrieval info: PRIVATE: WIZ_BASE_DATA_RATE STRING \"6250\""
		puts $outfile "// Retrieval info: PRIVATE: WIZ_DATA_RATE STRING \"6250\""
		puts $outfile "// Retrieval info: PRIVATE: WIZ_DPRIO_REF_CLK0_FREQ STRING \"195.3125\""
		puts $outfile "// Retrieval info: PRIVATE: WIZ_INCLK_FREQ STRING \"195.3125\""
		puts $outfile "// Retrieval info: PRIVATE: WIZ_INCLK_FREQ_ARRAY STRING \"195.3125 390.625\""
		puts $outfile "// Retrieval info: PRIVATE: WIZ_INPUT_A STRING \"6250\""
		puts $outfile "// Retrieval info: PRIVATE: WIZ_INPUT_B STRING \"195.3125\""		
	} elseif {$phy_refclk == 1} {
		puts $outfile "// Retrieval info: PRIVATE: WIZ_BASE_DATA_RATE STRING \"10312.5\""
		puts $outfile "// Retrieval info: PRIVATE: WIZ_DATA_RATE STRING \"10312.5\""
		puts $outfile "// Retrieval info: PRIVATE: WIZ_DPRIO_REF_CLK0_FREQ STRING \"644.53125\""
		puts $outfile "// Retrieval info: PRIVATE: WIZ_INCLK_FREQ STRING \"644.53125\""
		puts $outfile "// Retrieval info: PRIVATE: WIZ_INCLK_FREQ_ARRAY STRING \"322.265625 644.53125\""
		puts $outfile "// Retrieval info: PRIVATE: WIZ_INPUT_A STRING \"10312.5\""
		puts $outfile "// Retrieval info: PRIVATE: WIZ_INPUT_B STRING \"644.53125\""
    } elseif {$phy_refclk == 2} {
        puts $outfile "// Retrieval info: PRIVATE: WIZ_BASE_DATA_RATE STRING \"10312.5\""
		puts $outfile "// Retrieval info: PRIVATE: WIZ_DATA_RATE STRING \"10312.5\""
		puts $outfile "// Retrieval info: PRIVATE: WIZ_DPRIO_REF_CLK0_FREQ STRING \"322.265625\""
		puts $outfile "// Retrieval info: PRIVATE: WIZ_INCLK_FREQ STRING \"322.265625\""
		puts $outfile "// Retrieval info: PRIVATE: WIZ_INCLK_FREQ_ARRAY STRING \"322.265625 644.53125\""
		puts $outfile "// Retrieval info: PRIVATE: WIZ_INPUT_A STRING \"10312.5\""
		puts $outfile "// Retrieval info: PRIVATE: WIZ_INPUT_B STRING \"322.265625\""
    } 
	
	if {$variant != 1 } {
		puts $outfile "// Retrieval info: CONSTANT: TX_PLL_TYPE STRING \"CMU\""
    }
    
    close $outfile
    
    #override tx_0ppm_core_clock to work around bug in ALTGX
    exec $QUARTUS_ROOTDIR/bin/qmegawiz -silent -p:$temp_dir -wiz_override=tx_0ppm_core_clock=true $dest_file
    
    if {$sim == 1} {
        add_fileset_file "./mentor/$dest_dir/$base_name/$base_name.v" VERILOG PATH $dest_file MENTOR_SPECIFIC
        add_fileset_file "./cadence/$dest_dir/$base_name/$base_name.v" VERILOG PATH $dest_file CADENCE_SPECIFIC
        add_fileset_file "./synopsys/$dest_dir/$base_name/$base_name.v" VERILOG PATH $dest_file SYNOPSYS_SPECIFIC
        add_fileset_file "./aldec/$dest_dir/$base_name/$base_name.v" VERILOG PATH $dest_file ALDEC_SPECIFIC
    } else {
        add_fileset_file "$dest_dir/$base_name/$base_name.v" VERILOG PATH $dest_file
    }
}

proc gen_reco { {sim 0} } {
	set		mac_config                [::alt_xcvr::ip_tcl::ip_module::ip_get "parameter.MAC_CONFIG.value"		]
    set     QUARTUS_ROOTDIR           $::env(QUARTUS_ROOTDIR)
    set     TMP                       $::env(TMP)

    set dest_dir "phy/pma_siv"
    set temp_dir "$TMP/pma_siv"

	if {$mac_config == "100 Gbe"} {
		set src_file "../100gbe/rtl_src/phy/pma_siv/alt_e100_e_reco/alt_e100_e_reco_base.v"
		set dest_file "$temp_dir/alt_e100_e_reco.v"
	} else {
		set src_file "../40gbe/rtl_src/phy/pma_siv/alt_e40_e_reco/alt_e40_e_reco_base.v"
		set dest_file "$temp_dir/alt_e40_e_reco.v"	
	}
    
	
    
    if {[file type $src_file] != "file"} {
        exec cp -f $src_file $dest_file
    } else {
        file copy -force -- $src_file $dest_file
    }
    #file attributes $dest_file -readonly 0
    
    exec $QUARTUS_ROOTDIR/bin/qmegawiz -silent -p:$temp_dir $dest_file
    
    if {$sim == 1} {
        add_fileset_file "./mentor/$dest_dir/alt_e100_e_reco/alt_e100_e_reco.v" VERILOG PATH $dest_file MENTOR_SPECIFIC
        add_fileset_file "./cadence/$dest_dir/alt_e100_e_reco/alt_e100_e_reco.v" VERILOG PATH $dest_file CADENCE_SPECIFIC
        add_fileset_file "./synopsys/$dest_dir/alt_e100_e_reco/alt_e100_e_reco.v" VERILOG PATH $dest_file SYNOPSYS_SPECIFIC
        add_fileset_file "./aldec/$dest_dir/alt_e100_e_reco/alt_e100_e_reco.v" VERILOG PATH $dest_file ALDEC_SPECIFIC
    } else {
        add_fileset_file "$dest_dir/alt_e100_e_reco/alt_e100_e_reco.v" VERILOG PATH $dest_file
    }
}


proc ::alt_e40_e100::fileset::callback_quartus_synth {name} {
  set HAS_PHY                   [get_parameter_value HAS_PHY]
  set family                    [get_parameter_value DEVICE_FAMILY]
  set ENA_KR4       [ip_get "parameter.ENA_KR4.value"]
  if {$ENA_KR4 == 1} {
	if {[::alt_xcvr::utils::device::has_s5_style_hssi $family]} {
		::altera_xcvr_native_sv::fileset::callback_quartus_synth $name
	}
  }

  ::alt_e40_e100::fileset::register_fileset {PLAIN QENCRYPT}
  
  if {$family == "Stratix IV" && $HAS_PHY == 1} {
	gen_pma 0
	gen_reco 0
  }
  
}

proc ::alt_e40_e100::fileset::callback_sim_verilog {name} {
  set HAS_PHY                   [get_parameter_value HAS_PHY]
  set family                    [get_parameter_value DEVICE_FAMILY]
  set ENA_KR4       [ip_get "parameter.ENA_KR4.value"]
  if {$ENA_KR4 == 1} {
	if {[::alt_xcvr::utils::device::has_s5_style_hssi $family]} {
		::altera_xcvr_native_sv::fileset::callback_sim_verilog $name
	}
  }

  ::alt_e40_e100::fileset::register_fileset [concat PLAIN [common_fileset_tags_all_simulators]]
  
  if {$family == "Stratix IV"  && $HAS_PHY == 1} {
	gen_pma 1
	gen_reco 1
  }
  
}

proc ::alt_e40_e100::fileset::callback_sim_vhdl {name} {
  set HAS_PHY                   [get_parameter_value HAS_PHY]
  set family                    [get_parameter_value DEVICE_FAMILY]
  set ENA_KR4       [ip_get "parameter.ENA_KR4.value"]
  if {$ENA_KR4 == 1} {
	if {[::alt_xcvr::utils::device::has_s5_style_hssi $family]} {
		::altera_xcvr_native_sv::fileset::callback_sim_vhdl $name
	}
  }
  
  ::alt_e40_e100::fileset::register_fileset [concat PLAIN [common_fileset_tags_all_simulators]]
  
  if {$family == "Stratix IV"  && $HAS_PHY == 1} {
	gen_pma 1
	gen_reco 1
  }
  
}


proc ::alt_e40_e100::fileset::parse_name {variant path} {
	set fp [open $path r]
    set file_buffer [read $fp]
	close $fp
	regsub -all "ENET_ENTITY_QMEGA_06072013" $file_buffer $variant file_buffer
	return $file_buffer
}


proc ::alt_e40_e100::fileset::callback_example_design {name} {
    set device_family             [get_parameter_value DEVICE_FAMILY]
	set bandwidth                 [get_parameter_value MAC_CONFIG]
	set phy_config                [get_parameter_value PHY_CONFIG]
	set phy_refclk                [get_parameter_value PHY_REFCLK]
	set mac_config                [get_parameter_value MAC_CONFIG]
    set core_option               [get_parameter_value CORE_OPTION]
	set en_synce_support          [get_parameter_value en_synce_support]
	set INTERFACE                 [get_parameter_value INTERFACE]
	set RX_ONLY_IF                [get_parameter_value RX_ONLY_IF]
	set TX_ONLY_IF                [get_parameter_value TX_ONLY_IF]
	set IS_CAUI4                  [get_parameter_value IS_CAUI4]
	set ENA_KR4                   [get_parameter_value ENA_KR4]
	
	set path "$::env(QUARTUS_ROOTDIR)/../ip/altera/alt_eth_40g_100g/"
	
	if {$bandwidth == "40 Gbe"} {
		set ip_dir "40gbe"
	} else {
		set ip_dir "100gbe"
	}
	
	##
	# Figure out the variant name the user specified
	##
	set filelocation [create_temp_file ".tempfile"]
    regexp "^.*/" $filelocation filelocation
    regsub "/$" $filelocation "" filelocation
    regsub "^.*/" $filelocation "" filelocation
    regsub "^.*?_" $filelocation "" filelocation
    regexp "^.*_" $filelocation filelocation
    regsub "_$" $filelocation "" variant
	
	##
	# Create the dynamic parameters file
	##
	set file_buffer "// This is a dynamically generated parameter file for the 40g/100g example testbench and example design\n\n"
	if {$en_synce_support == 1} {
		append file_buffer "`define SYNC_E\n\n"
	}
	append file_buffer "parameter DEVICE_FAMILY            = \"[get_parameter_value DEVICE_FAMILY]\";\n"
	append file_buffer "parameter VARIANT                  = [get_parameter_value VARIANT]\;\n"
	append file_buffer "parameter ENABLE_STATISTICS_CNTR   = [get_parameter_value ENABLE_STATISTICS_CNTR];\n"
	append file_buffer "parameter HAS_ADAPTERS             = [get_parameter_value HAS_ADAPTERS];\n"
	append file_buffer "parameter IS_CAUI4                 = [get_parameter_value IS_CAUI4];\n"
	append file_buffer "parameter STATUS_CLK_KHZ           = [get_parameter_value STATUS_CLK_KHZ];\n"
	append file_buffer "parameter HAS_MAC                  = [get_parameter_value HAS_MAC];\n"
	append file_buffer "parameter HAS_PHY                  = [get_parameter_value HAS_PHY];\n"
	append file_buffer "parameter MAC_CONFIG               = \"[get_parameter_value MAC_CONFIG]\";\n"
	append file_buffer "parameter VARIANT_NAME             = \"$variant\";\n"
	append file_buffer "parameter en_synce_support         = $en_synce_support;\n"
	
	if {$IS_CAUI4} {
		append file_buffer "parameter REF_CLK_PERIOD           = 1552;\n"	
	} elseif {$mac_config == "40 Gbe" && $phy_config == 2 && $phy_refclk == 1} {
		append file_buffer "parameter REF_CLK_PERIOD           = 2560;\n"
	} elseif {$mac_config == "40 Gbe" && $phy_config == 2 && $phy_refclk == 2} {
		append file_buffer "parameter REF_CLK_PERIOD           = 5120;\n"	
	} elseif {$phy_refclk == 1} {
		append file_buffer "parameter REF_CLK_PERIOD           = 1552;\n"	
	} elseif {$phy_refclk == 2} {
		append file_buffer "parameter REF_CLK_PERIOD           = 3104;\n"	
	}
	
	if {$mac_config == "40 Gbe" && $phy_config == 2} {
		append file_buffer "parameter MAC_CLK_PERIOD           = 3636;\n"
	} else {
		append file_buffer "parameter MAC_CLK_PERIOD           = 3200;\n"	
	}

	add_fileset_file "./example_testbench/dynamic_parameters.v" VERILOG TEXT $file_buffer

	if {$ENA_KR4} {
		##
		# Create the testbench files
		##
		add_fileset_file "./example_testbench/alt_e40_avalon_kr4_tb.sv" SYSTEM_VERILOG TEXT [::alt_e40_e100::fileset::parse_name $variant "$path/40gbe/example_testbenches/kr4_sv/alt_e40_avalon_kr4_tb.sv"]
		add_fileset_file "./example_testbench/alt_e40_avalon_tb_packet_gen.v" VERILOG PATH "$path/40gbe/example_testbenches/kr4_sv/alt_e40_avalon_tb_packet_gen.v"
		add_fileset_file "./example_testbench/alt_e40_avalon_tb_packet_gen_sanity_check.v" VERILOG PATH "$path/40gbe/example_testbenches/kr4_sv/alt_e40_avalon_tb_packet_gen_sanity_check.v"
		add_fileset_file "./example_testbench/alt_e40_avalon_tb_sample_tx_rom.v" VERILOG PATH "$path/40gbe/example_testbenches/kr4_sv/alt_e40_avalon_tb_sample_tx_rom.v"
		add_fileset_file "./example_testbench/alt_e40_avalon_tb_sample_tx_rom.hex" OTHER PATH "$path/40gbe/example_testbenches/kr4_sv/alt_e40_avalon_tb_sample_tx_rom.hex"
		add_fileset_file "./example_testbench/kr4_example_files.txt" OTHER PATH "$path/40gbe/example_testbenches/kr4_sv/kr4_example_files.txt"
		
		##
		# Create the aldec setup script file
		##
		add_fileset_file "./example_testbench/run_aldec.do" OTHER TEXT [::alt_e40_e100::fileset::parse_name $variant "$path/$ip_dir/example_testbenches/kr4_sv/run_aldec.do"]
		
		##
		# Create the ncsim setup script file
		##
		add_fileset_file "./example_testbench/run_ncsim.sh" OTHER TEXT [::alt_e40_e100::fileset::parse_name $variant "$path/$ip_dir/example_testbenches/kr4_sv/run_ncsim.sh"]
		
		##
		# Create the vcs setup script file
		##
		add_fileset_file "./example_testbench/run_vcs.sh" OTHER TEXT [::alt_e40_e100::fileset::parse_name $variant "$path/$ip_dir/example_testbenches/kr4_sv/run_vcs.sh"]
		
		##
		# Create the vsim setup script file
		##
		add_fileset_file "./example_testbench/run_vsim.do" OTHER TEXT [::alt_e40_e100::fileset::parse_name $variant "$path/$ip_dir/example_testbenches/kr4_sv/run_vsim.do"]
	} else {
		##
		# Create the testbench file
		##
		add_fileset_file "./example_testbench/alt_${ip_dir}_tb.v" VERILOG TEXT [::alt_e40_e100::fileset::parse_name $variant "$path/$ip_dir/example_testbenches/alt_${ip_dir}_tb.v"]
		
		##
		# Create the aldec setup script file
		##
		add_fileset_file "./example_testbench/run_aldec.do" OTHER TEXT [::alt_e40_e100::fileset::parse_name $variant "$path/$ip_dir/example_testbenches/run_aldec.do"]
		
		##
		# Create the ncsim setup script file
		##
		add_fileset_file "./example_testbench/run_ncsim.sh" OTHER TEXT [::alt_e40_e100::fileset::parse_name $variant "$path/$ip_dir/example_testbenches/run_ncsim.sh"]
		
		##
		# Create the vcs setup script file
		##
		add_fileset_file "./example_testbench/run_vcs.sh" OTHER TEXT [::alt_e40_e100::fileset::parse_name $variant "$path/$ip_dir/example_testbenches/run_vcs.sh"]
		
		##
		# Create the vsim setup script file
		##
		add_fileset_file "./example_testbench/run_vsim.do" OTHER TEXT [::alt_e40_e100::fileset::parse_name $variant "$path/$ip_dir/example_testbenches/run_vsim.do"]
	}
	
	if {$mac_config == "100 Gbe"} {
		set speed "_e100"
	} else {
		set speed "_e40"
	}
	
	if {$INTERFACE == "Avalon-ST Interface"} {
		set a_if "_avalon"
	} else {
		set a_if ""
	}
	
	if {$RX_ONLY_IF} {
		set dup "_rx"
	} elseif {$TX_ONLY_IF} {
		set dup "_tx"
	} else {
		set dup ""
	}
	
	if {$device_family == "Stratix V"} {
		set fam "_sv"
	} elseif {$device_family == "Stratix IV"} {
		set fam "_siv"
	} elseif {$device_family == "Arria 10"} {
		set fam "_a10"
	}
	
	if {$core_option == "PHY only"} {
		set co "_phy"
	} elseif {$core_option == "MAC only"} {
		set co "_mac"
	} else {
		set co ""
	}
	
	if {$IS_CAUI4} {
		set caui4 "_caui4"
	} else {
		set caui4 ""
	}
	
	if {$ENA_KR4} {
		set kr4 "_kr4"
	} else {
		set kr4 ""
	}
	
	set approved_designs {"alt_e100_avalon_top_a10" "alt_e100_avalon_top_siv" "alt_e100_avalon_top_sv" "alt_e100_avalon_top_sv_caui4" \
                          "alt_e100_rx_top_a10"     "alt_e100_rx_top_siv"     "alt_e100_rx_top_sv"     "alt_e100_top_a10" \
						  "alt_e100_top_siv"        "alt_e100_top_sv"         "alt_e100_top_sv_caui4"  "alt_e100_tx_top_a10" \
						  "alt_e100_tx_top_siv"     "alt_e100_tx_top_sv"      "alt_e40_avalon_top_a10" "alt_e40_avalon_top_siv" \
						  "alt_e40_avalon_top_sv"   "alt_e40_rx_top_a10"      "alt_e40_rx_top_siv"     "alt_e40_rx_top_sv" \
                          "alt_e40_top_siv"         "alt_e40_top_sv"          "alt_e40_top_a10"     "alt_e40_tx_top_a10" \
                          "alt_e40_tx_top_siv"      "alt_e40_tx_top_sv"       "alt_e40_top_sv_kr4"     "alt_e40_avalon_top_sv_kr4" }
	
	
	set design_name "alt${speed}${a_if}${co}${dup}_top${fam}${caui4}${kr4}"
	
	if {[lsearch $approved_designs $design_name] == -1} {
		# The design was not found in our approved designs list, return
		return
	}
	
	
	
	add_fileset_file "./example/${design_name}.v"   VERILOG TEXT [::alt_e40_e100::fileset::parse_name $variant "$path/$ip_dir/example/${design_name}/${design_name}.v"]
	add_fileset_file "./example/${design_name}.qpf" OTHER   TEXT [::alt_e40_e100::fileset::parse_name $variant "$path/$ip_dir/example/${design_name}/${design_name}.qpf"]
	add_fileset_file "./example/${design_name}.qsf" OTHER   TEXT [::alt_e40_e100::fileset::parse_name $variant "$path/$ip_dir/example/${design_name}/${design_name}.qsf"]
	add_fileset_file "./example/dynamic_parameters.v" VERILOG TEXT $file_buffer


    set folder_lst {"common"}
    lappend folder_lst "common/alt${speed}_e_reco"
    lappend folder_lst "common/alt${speed}_e_reco/alt${speed}_e_reco"
    lappend folder_lst "common/alt${speed}_sys_pll_siv"
    lappend folder_lst "common/alt${speed}_sys_pll_sv"
    lappend folder_lst "common/alt${speed}_sys_pll_sv/alt${speed}_sys_pll_sv"
    lappend folder_lst "common/alt${speed}_sys_pll_sv_100"
    lappend folder_lst "common/alt${speed}_sys_pll_sv_100/alt${speed}_sys_pll_sv_100"
    
    if { $mac_config == "100 Gbe" } {
        lappend folder_lst "common/alt${speed}_e_reco_caui4"
        lappend folder_lst "common/alt${speed}_e_reco_caui4/alt${speed}_e_reco_caui4"
    }
	
	if {$ENA_KR4} {
        lappend folder_lst "common/com_design_ex"
	}
    
	if {$mac_config == "100 Gbe"} {
		set src_dir     "../100gbe/example"
	} else {
		set src_dir     "../40gbe/example"
	}
	 
    foreach folder $folder_lst {
        set file_lst    [glob -- -path "${src_dir}/${folder}/*.*"]
        foreach file    $file_lst {
            set file_string [split $file /]
            set file_name [lindex $file_string end]
            add_fileset_file "./example/$folder/$file_name" OTHER PATH $file
        }
    }
	
	
}



proc ::alt_e40_e100::fileset::add_instances {} {
	set HAS_PHY                   [get_parameter_value HAS_PHY]
	set bandwidth                 [get_parameter_value MAC_CONFIG]
	set family                    [get_parameter_value DEVICE_FAMILY]
	set VARIANT                   [get_parameter_value VARIANT]
	set is_caui4                  [get_parameter_value IS_CAUI4]
	set PHY_REFCLK                [get_parameter_value PHY_REFCLK]
	set PHY_PLL                   [get_parameter_value PHY_PLL]
	set PHY_CONFIG                [get_parameter_value PHY_CONFIG]
	set ENA_KR4                   [get_parameter_value ENA_KR4]
	
	if {$family == "Arria 10"} {
		if {$bandwidth == "40 Gbe"} {
				if { $VARIANT == 3} {
					set inst_name alt_e40_e4x10
					set duplex_mode "duplex"
					set TX_ENABLE 1
					set RX_ENABLE 1
				} elseif { $VARIANT == 1} {
					set inst_name alt_e40_rx_e4x10
					set duplex_mode "rx"
					set TX_ENABLE 0
					set RX_ENABLE 1
				} elseif { $VARIANT == 2} {
					set inst_name alt_e40_tx_e4x10
					set duplex_mode "tx"
					set TX_ENABLE 1
					set RX_ENABLE 0
				}
				set CHANNELS 4
			} else {
				if { $VARIANT == 3} {
					set inst_name alt_e100_e10x10
					set duplex_mode "duplex"
					set TX_ENABLE 1
					set RX_ENABLE 1
				} elseif { $VARIANT == 1} {
					set inst_name alt_e100_rx_e10x10
					set duplex_mode "rx"
					set TX_ENABLE 0
					set RX_ENABLE 1
				} elseif { $VARIANT == 2} {
					set inst_name alt_e100_tx_e10x10
					set duplex_mode "tx"
					set TX_ENABLE 1
					set RX_ENABLE 0
				}
				set CHANNELS 10
		}
		
		if {$HAS_PHY == 1} {
		
			if {$TX_ENABLE == 1} {
				set pll_inst "atx_pll"
				add_hdl_instance $pll_inst altera_xcvr_atx_pll_a10
				set_instance_parameter_value     $pll_inst       device_family "Arria 10"
				set_instance_parameter_value     $pll_inst       enable_8G_path 0
				set_instance_parameter_value     $pll_inst       set_output_clock_frequency "5156.25"
				
				if {$PHY_REFCLK == 1} {
					set_instance_parameter_value     $pll_inst       set_auto_reference_clock_frequency "644.53125"
				}
				if {$PHY_REFCLK == 2} {
					set_instance_parameter_value     $pll_inst       set_auto_reference_clock_frequency "322.265625"
				}
				set_instance_parameter_value     $pll_inst       enable_mcgb 1
				set_instance_parameter_value     $pll_inst       enable_hfreq_clk 1
			}
		
		
			add_hdl_instance                 $inst_name       altera_xcvr_native_a10
			set_instance_parameter_value     $inst_name       device_family "Arria 10"
			set_instance_parameter_value     $inst_name       protocol_mode "basic_enh"
			set_instance_parameter_value     $inst_name       duplex_mode $duplex_mode
			set_instance_parameter_value     $inst_name       channels $CHANNELS
			set_instance_parameter_value     $inst_name       set_data_rate 10312.5
			set_instance_parameter_value     $inst_name       enable_port_rx_seriallpbken 1
			
			if {$PHY_REFCLK == 1} {
				set_instance_parameter_value     $inst_name       set_cdr_refclk_freq "644.531250"
			}
			if {$PHY_REFCLK == 2} {
				set_instance_parameter_value     $inst_name       set_cdr_refclk_freq "322.265625"
			}
			
			set_instance_parameter_value     $inst_name       rx_ppm_detect_threshold 100
			set_instance_parameter_value     $inst_name       rcfg_enable 1
			set_instance_parameter_value     $inst_name       rcfg_shared 1

			add_hdl_instance                 "${inst_name}_reset"       altera_xcvr_reset_control
			set_instance_parameter_value     "${inst_name}_reset"       CHANNELS       $CHANNELS
			set_instance_parameter_value     "${inst_name}_reset"       SYS_CLK_IN_MHZ [expr int([get_parameter_value STATUS_CLK_KHZ] / 1000.0)]	
			set_instance_parameter_value     "${inst_name}_reset"       TX_PLL_ENABLE 0
			set_instance_parameter_value     "${inst_name}_reset"       TX_ENABLE $TX_ENABLE
			set_instance_parameter_value     "${inst_name}_reset"       RX_ENABLE $RX_ENABLE
		} 
	}
	
	if {$HAS_PHY == 1 && ($family == "Stratix V" || $family == "Arria V GZ") && $ENA_KR4 == 0} {
	
		if {$bandwidth == "40 Gbe"} {
				
				set CHANNELS 4
				
				if { $VARIANT == 3} {
					set inst_name alt_e40_e4x10
				} elseif { $VARIANT == 1} {
					set inst_name alt_e40_rx_e4x10
				} elseif { $VARIANT == 2} {
					set inst_name alt_e40_tx_e4x10
				}
				
			} else {
				if { $VARIANT == 3} {
					set inst_name alt_e100_e10x10
				} elseif { $VARIANT == 1} {
					set inst_name alt_e100_rx_e10x10
				} elseif { $VARIANT == 2} {
					set inst_name alt_e100_tx_e10x10
				}
				set CHANNELS 10
		}

		if {$is_caui4 == 1} {
		
			set inst_name alt_e100_e1x25
			add_hdl_instance             $inst_name altera_xcvr_low_latency_phy			
			set_instance_parameter_value $inst_name device_family "Stratix V"
			set_instance_parameter_value $inst_name gui_data_path_type "GT"
			set_instance_parameter_value $inst_name operation_mode "DUPLEX"
			set_instance_parameter_value $inst_name lanes "1"
			set_instance_parameter_value $inst_name gui_pll_type "ATX"
			set_instance_parameter_value $inst_name data_rate "25781.25 Mbps"
			set_instance_parameter_value $inst_name en_synce_support  "1"

		
		} else {
			add_hdl_instance                $inst_name      altera_xcvr_low_latency_phy
			set_instance_parameter_value	$inst_name		device_family $family
			
			if { $VARIANT == 3} {
				set_instance_parameter_value	$inst_name		operation_mode "DUPLEX"
				set_instance_parameter_value	$inst_name		gui_tx_use_coreclk 1
				set_instance_parameter_value	$inst_name		gui_rx_use_coreclk 1
				set_instance_parameter_value    $inst_name      en_synce_support  "1"
			}
			if { $VARIANT == 2} {
				set_instance_parameter_value	$inst_name		operation_mode "TX"
				set_instance_parameter_value	$inst_name		gui_tx_use_coreclk 1
			}
			if { $VARIANT == 1} {
				set_instance_parameter_value	$inst_name		operation_mode "RX"
				set_instance_parameter_value	$inst_name		gui_rx_use_coreclk 1
			}
			
			set_instance_parameter_value	$inst_name		gui_data_path_type "10G"
			set_instance_parameter_value	$inst_name		gui_bonding_enable 0
			set_instance_parameter_value	$inst_name		lanes $CHANNELS
			set_instance_parameter_value	$inst_name		gui_serialization_factor 40
			set_instance_parameter_value	$inst_name		gui_pll_type $PHY_PLL
			
			if {$PHY_CONFIG == 1 && $PHY_REFCLK == 1} {
				set_instance_parameter_value	$inst_name		data_rate "10312.5 Mbps"
				set_instance_parameter_value	$inst_name		gui_pll_refclk_freq "644.53125 MHz"
			}
			
			if {$PHY_CONFIG == 1 && $PHY_REFCLK == 2} {
				set_instance_parameter_value	$inst_name		data_rate "10312.5 Mbps"
				set_instance_parameter_value    $inst_name       gui_pll_refclk_freq "322.265625 MHz"
			}
			
			if {$PHY_CONFIG == 2 && $PHY_REFCLK == 1} {
				set_instance_parameter_value	$inst_name		data_rate "6250 Mbps"
				set_instance_parameter_value	$inst_name		gui_pll_refclk_freq "390.625 MHz"
			}
			
			if {$PHY_CONFIG == 2 && $PHY_REFCLK == 2} {
				set_instance_parameter_value	$inst_name		data_rate "6250 Mbps"
				set_instance_parameter_value    $inst_name       gui_pll_refclk_freq "195.3125 MHz"
			}

			set_instance_parameter_value	$inst_name		gui_ppm_det_threshold 100
		}

	}
}
