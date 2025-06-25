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



package provide altera_xcvr_10gbase_kr::fileset 12.0

package require alt_xcvr::utils::fileset
package require alt_xcvr::utils::device
package require alt_xcvr::ip_tcl::ip_module
package require altera_xcvr_native_sv::fileset

namespace eval ::altera_xcvr_10gbase_kr::fileset:: {
  namespace import ::alt_xcvr::ip_tcl::ip_module::*
  namespace import ::alt_xcvr::utils::fileset::*

  namespace export \
    declare_filesets \
    declare_files


  variable filesets

  set filesets {\
    { NAME            TYPE            CALLBACK                                                  TOP_LEVEL             }\
    { quartus_synth   QUARTUS_SYNTH   ::altera_xcvr_10gbase_kr::fileset::callback_quartus_synth altera_xcvr_10gbase_kr }\
    { sim_verilog     SIM_VERILOG     ::altera_xcvr_10gbase_kr::fileset::callback_sim_verilog   altera_xcvr_10gbase_kr }\
    { sim_vhdl        SIM_VHDL        ::altera_xcvr_10gbase_kr::fileset::callback_sim_vhdl      altera_xcvr_10gbase_kr }\
  }

}

proc ::altera_xcvr_10gbase_kr::fileset::declare_filesets { } {
  variable filesets

  declare_files
  ip_declare_filesets $filesets
}

proc ::altera_xcvr_10gbase_kr::fileset::declare_files {} {
  # Native PHY files
  ::altera_xcvr_native_sv::fileset::declare_files

  # Common PHY IP files
  set path [::alt_xcvr::utils::fileset::abs_to_rel_path [::alt_xcvr::utils::fileset::get_altera_xcvr_generic_path]]

  ::alt_xcvr::utils::fileset::common_fileset_group_plain ./ "${path}/ctrl/" {
    alt_xcvr_csr_common_h.sv
    alt_xcvr_csr_common.sv
    alt_xcvr_csr_selector.sv
    altera_wait_generate.v
  } {ALTERA_XCVR_10GBASE_KR}

  ::alt_xcvr::utils::fileset::common_fileset_group_plain ./ "${path}/../altera_10gbaser_phy/siv/" {
    csr_pcs10gbaser_h.sv
    csr_pcs10gbaser.sv
  } {ALTERA_XCVR_10GBASE_KR}

  # 10G 1588 files

  ::alt_xcvr::utils::fileset::common_fileset_group_encrypted ./ "${path}/../altera_10gbaser_phy/soft_pcs/" {
    altera_10gbaser_phy_params.sv
    altera_10gbaser_phy_clockcomp.sv
    altera_10gbaser_phy_async_fifo.sv
    altera_10gbaser_phy_1588_latency.sv
    altera_10gbaser_phy_rx_fifo_wrap.v
    altera_10gbaser_phy_rx_fifo.v
    altera_10gbaser_phy_async_fifo_fpga.sv
  } {ALTERA_XCVR_10GBASE_KR}
  
  ::alt_xcvr::utils::fileset::common_fileset_group_plain ./ "${path}/../avalon_st/altera_avalon_st_handshake_clock_crosser/" {
    altera_avalon_st_handshake_clock_crosser.v
    altera_avalon_st_clock_crosser.v
  } {ALTERA_XCVR_10GBASE_KR}
  
  ::alt_xcvr::utils::fileset::common_fileset_group_plain ./ "${path}/../avalon_st/altera_avalon_st_pipeline_stage/" {
    altera_avalon_st_pipeline_stage.sv
    altera_avalon_st_pipeline_base.v
  } {ALTERA_XCVR_10GBASE_KR}

  # altera_xcvr_10gbase_kr files
  set path [::alt_xcvr::utils::fileset::get_alt_xcvr_path]
  set path "${path}/altera_xcvr_10gbase_kr/common_src/"
  set path [::alt_xcvr::utils::fileset::abs_to_rel_path $path]

  # Declare unencrypted common KR files
  ::alt_xcvr::utils::fileset::common_fileset_group_plain ./ $path {
    csr_krtop_h.sv
    csr_kran.sv
    csr_krlt.sv
    csr_krgige.sv
    csr_krtop.sv
    csr_krfec.sv
    seq_sm.sv
  } {ALTERA_XCVR_10GBASE_KR}

  # Declare KR TOP file
  ::alt_xcvr::utils::fileset::common_fileset_group_plain ./ "$path/../altera_xcvr_10gbase_kr/" {
    altera_xcvr_10gbase_kr.sv
  } {ALTERA_XCVR_10GBASE_KR}
  
 # Declare encrypted common KR files
  ::alt_xcvr::utils::fileset::common_fileset_group_encrypted ./ $path {
    an_arb_sm.sv
    an_decode.sv
    an_rx_sm.sv
    an_top.sv
    an_tx_sm.sv
    lt_cf_update.sv
    lt_coef_mstr.sv
    lt_frame_lock.sv
    lt_lcl_coef.sv
    lt_rmt_opt.sv
    lt_rmt_txeq.sv
    lt_rx_data.sv
    lt_rx_gbx.sv
    lt_top.sv
    lt_tx_data.sv
    lt_tx_gbx.sv
    lt_tx_train.sv
    six_two_comp.sv
  } {ALTERA_XCVR_10GBASE_KR}
	
	
# Declare encrypted FEC KR files
  ::alt_xcvr::utils::fileset::common_fileset_group_encrypted ./ "$path/../sv_fec" {
    hd_dpcmn_bitsync.v
    hd_dpcmn_bitsync2.v
    hd_dpcmn_bitsync3.v
    hd_dpcmn_bitsync4.v
    hd_dpcmn_dprio_csr_reg_bit.v
    hd_dpcmn_dprio_csr_reg_nbits.v
    hd_dpcmn_dprio_csr_reg_nregs.v
    hd_dpcmn_dprio_csr_test_mux.v
    hd_dpcmn_dprio_ctrl_reg_bit.v
    hd_dpcmn_dprio_ctrl_reg_nbits.v
    hd_dpcmn_dprio_ctrl_reg_nregs.v
    hd_dpcmn_dprio_ctrl_stat_interface_top.v
    hd_dpcmn_dprio_ctrl_stat_reg_chnl.v
    hd_dpcmn_dprio_ctrl_stat_reg_top.v
    hd_dpcmn_dprio_ctrl_stat_reg_w_resvrd_chnl.v
    hd_dpcmn_dprio_ctrl_stat_reg_w_resvrd_top.v
    hd_dpcmn_dprio_dis_ctrl_cvp.v
    hd_dpcmn_dprio_readdata_mux.v
    hd_dpcmn_dprio_readdata_mux_mod.v
    hd_dpcmn_dprio_readdata_sel.v
    hd_dpcmn_dprio_shadow_status_nregs.v
    hd_dpcmn_dprio_shadow_status_regs.v
    hd_dpcmn_dprio_status_reg_nbits.v
    hd_dpcmn_dprio_status_reg_nregs.v
    hd_dpcmn_dprio_status_sync_regs.v
    hd_krfec.v
    hd_krfec_blksync.v
    hd_krfec_chk4_syndrm.v
    hd_krfec_cmpt4syndrm_chk.v
    hd_krfec_cmpt_syndrm.v
    hd_krfec_decoder.v
    hd_krfec_decoder_master_sm.v
    hd_krfec_decoder_rd_sm.v
    hd_krfec_decoder_sm.v
    hd_krfec_descrm.v
    hd_krfec_dpbuff.v
    hd_krfec_encoder.v
    hd_krfec_errcorrect.v
    hd_krfec_errtrap.v
    hd_krfec_errtrap_ind.v
    hd_krfec_errtrap_lfsr.v
    hd_krfec_errtrap_loc.v
    hd_krfec_errtrap_pat.v
    hd_krfec_errtrap_sm.v
    hd_krfec_fast_search.v
    hd_krfec_fast_search_sm.v
    hd_krfec_gearbox_exp.v
    hd_krfec_gearbox_red.v
    hd_krfec_gx_64b.v
    hd_krfec_head_tail_gen.v
    hd_krfec_lock_sm.v
    hd_krfec_nto1mux.v
    hd_krfec_parity_chk.v
    hd_krfec_parity_gen.v
    hd_krfec_pulse_stretch.v
    hd_krfec_rx_async_pld_out.v
    hd_krfec_rx_chnl.v
    hd_krfec_rx_testbus.v
    hd_krfec_rxrst_ctrl.v
    hd_krfec_scramble.v
    hd_krfec_shf1_syndrm.v
    hd_krfec_shf2_syndrm.v
    hd_krfec_shf3_syndrm.v
    hd_krfec_shf4_syndrm.v
    hd_krfec_syndrm_sm.v
    hd_krfec_top_wrapper.v
    hd_krfec_transcode_dec.v
    hd_krfec_transcode_enc.v
    hd_krfec_tx_async_pld_out.v
    hd_krfec_tx_chnl.v
    hd_krfec_tx_testbus.v
    hd_krfec_wdalign.v
  } {ALTERA_XCVR_10GBASE_KR}


# Declare encrypted SV Soft 10G PCS files
  ::alt_xcvr::utils::fileset::common_fileset_group_encrypted ./ "$path/../sv_soft_10gbaser/sv_soft_pcs" {
    kr_altera_10gbaser_phy_params.sv
    kr_altera_10gbaser_phy_async_fifo_fpga.sv
    kr_altera_10gbaser_phy_clockcomp.sv
    altera_10gbaser_phy_pcs_10g_top.sv
    altera_10gbaser_phy_reg_map_av.sv
    kr_altera_10gbaser_phy_rx_fifo.sv
    alt_10gbaser_pcs.v
    altera_10gbaser_phy_bitsync.v
    altera_10gbaser_phy_bitsync2.v
    altera_10gbaser_phy_clk_ctrl.v
    altera_10gbaser_phy_gearbox_exp.v
    altera_10gbaser_phy_gearbox_red.v
    altera_10gbaser_phy_pcs_10g.v
    kr_altera_10gbaser_phy_rx_fifo_wrap.v
    altera_10gbaser_phy_rx_top.v
    altera_10gbaser_phy_tx_top.v	  
  } {ALTERA_XCVR_10GBASE_KR}

# List of files need to add in above list

# Declare encrypted other Soft 10G PCS files
  ::alt_xcvr::utils::fileset::common_fileset_group_encrypted ./ "$path/../sv_soft_10gbaser/soft_pcs" {
    altera_10gbaser_phy_ber.v
    altera_10gbaser_phy_ber_cnt_ns.v
    altera_10gbaser_phy_ber_sm.v
    altera_10gbaser_phy_blksync.v
    altera_10gbaser_phy_blksync_datapath.v
    altera_10gbaser_phy_descramble.v
    altera_10gbaser_phy_lock_sm.v
    altera_10gbaser_phy_nto1mux.v
    altera_10gbaser_phy_prbs_gen_xg.v
    altera_10gbaser_phy_prbs_ver_xg.v
    altera_10gbaser_phy_register_with_byte_enable.v
    altera_10gbaser_phy_scramble.v
    altera_10gbaser_phy_square_wave_gen.v
    altera_10gbaser_phy_word_align.v
    kr_altera_10gbaser_phy_1588_latency.sv
    altera_10gbaser_phy_decode.sv
    altera_10gbaser_phy_decode_type.sv
    altera_10gbaser_phy_encode.sv
    altera_10gbaser_phy_encode_type.sv
    altera_10gbaser_phy_random_err_cnt_ns.sv
    altera_10gbaser_phy_random_gen.sv
    altera_10gbaser_phy_random_ver.sv
    altera_10gbaser_phy_random_ver_10g.sv
    altera_10gbaser_phy_rx_sm_datapath.sv
    altera_10gbaser_phy_rx_sm_ns.sv
    altera_10gbaser_phy_tx_sm_datapath.sv
    altera_10gbaser_phy_tx_sm_ns.sv
  } {ALTERA_XCVR_10GBASE_KR}

# List of files need to add in above list
  
  
  set path [::alt_xcvr::utils::fileset::get_alt_xcvr_path]
  set path "${path}/altera_xcvr_10gbase_kr/gige_pcs/"
  set path [::alt_xcvr::utils::fileset::abs_to_rel_path $path]
  # Declare encrypted common KR files
  ::alt_xcvr::utils::fileset::common_fileset_group_encrypted ./ $path {
    kr_gige_pcs_a_fifo_24.v
    kr_gige_pcs_carrier_sense.v
    kr_gige_pcs_colision_detect.v
    kr_gige_pcs_gray_cnt.v
    kr_gige_pcs_gxb_aligned_rxsync.v
    kr_gige_pcs_mdio_reg.v
    kr_gige_pcs_mii_rx_if_pcs.v
    kr_gige_pcs_mii_tx_if_pcs.v
    kr_gige_pcs_pcs_control.v
    kr_gige_pcs_pcs_host_control.v
    kr_gige_pcs_reset_synchronizer.v
    kr_gige_pcs_rx_converter.v
    kr_gige_pcs_rx_encapsulation_strx_gx.v
    kr_gige_pcs_rx_fifo_rd.v
    kr_gige_pcs_sdpm_altsyncram.v
    kr_gige_pcs_sgmii_clk_enable.v
    kr_gige_pcs_top.sv
    kr_gige_pcs_clock_crosser.v
    kr_gige_pcs_ph_calculator.sv
    kr_gige_pcs_top_1000_base_x_strx_gx.v
    kr_gige_pcs_top_autoneg.v
    kr_gige_pcs_top_pcs_strx_gx.v
    kr_gige_pcs_top_rx_converter.v
    kr_gige_pcs_top_sgmii_strx_gx.v
    kr_gige_pcs_top_tx_converter.v
    kr_gige_pcs_tx_converter.v
    kr_gige_pcs_tx_encapsulation.v
  } {ALTERA_XCVR_10GBASE_KR}

  ::alt_xcvr::utils::fileset::common_fileset_group_plain ./ $path {
    kr_gige_pcs_top.ocp
  } {ALTERA_XCVR_10GBASE_KR}

}

proc ::altera_xcvr_10gbase_kr::fileset::callback_quartus_synth {name} {
  set device_family [ip_get "parameter.DEVICE_FAMILY.value"]
  if {[::alt_xcvr::utils::device::has_s5_style_hssi $device_family]} {
    ::altera_xcvr_native_sv::fileset::callback_quartus_synth $name
  }
  common_add_fileset_files {ALTERA_XCVR_10GBASE_KR} {PLAIN QIP QENCRYPT}
}

proc ::altera_xcvr_10gbase_kr::fileset::callback_sim_verilog {name} {
  set device_family [ip_get "parameter.DEVICE_FAMILY.value"]
  if {[::alt_xcvr::utils::device::has_s5_style_hssi $device_family]} {
    ::altera_xcvr_native_sv::fileset::callback_sim_verilog $name
  }
  common_add_fileset_files {ALTERA_XCVR_10GBASE_KR} [concat PLAIN [common_fileset_tags_all_simulators]]
}

proc ::altera_xcvr_10gbase_kr::fileset::callback_sim_vhdl {name} {
  set device_family [ip_get "parameter.DEVICE_FAMILY.value"]
  if {[::alt_xcvr::utils::device::has_s5_style_hssi $device_family]} {
    ::altera_xcvr_native_sv::fileset::callback_sim_vhdl $name
  }
  common_add_fileset_files {ALTERA_XCVR_10GBASE_KR} [concat PLAIN [common_fileset_tags_all_simulators]]
}

