#Copyright (C)2001-2010 Altera Corporation
#Any megafunction design, and related net list (encrypted or decrypted),
#support information, device programming or simulation file, and any other
#associated documentation or information provided by Altera or a partner
#under Altera's Megafunction Partnership Program may be used only to
#program PLD devices (but not masked PLD devices) from Altera.  Any other
#use of such megafunction design, net list, support information, device
#programming or simulation file, or any other related documentation or
#information is prohibited for any other purpose, including, but not
#limited to modification, reverse engineering, de-compiling, or use with
#any other silicon devices, unless such use is explicitly licensed under
#a separate agreement with Altera or a megafunction partner.  Title to
#the intellectual property, including patents, copyrights, trademarks,
#trade secrets, or maskworks, embodied in any such megafunction design,
#net list, support information, device programming or simulation file, or
#any other related documentation or information provided by Altera or a
#megafunction partner, remains with Altera, the megafunction partner, or
#their respective licensors.  No other licenses, including any licenses
#needed under any third party's intellectual property, are provided herein.
#Copying or modifying any file, or portion thereof, to which this notice
#is attached violates this copyright.






















package nevada_control_regs;
use Exporter;
@ISA = Exporter;
@EXPORT = qw(
    $cop0_index_reg
    $cop0_random_reg
    $cop0_entry_lo_0_reg
    $cop0_entry_lo_1_reg
    $cop0_context_reg
    $cop0_page_mask_reg
    $cop0_wired_reg
    $cop0_hwr_ena_reg
    $cop0_bad_vaddr_reg
    $cop0_count_reg
    $cop0_entry_hi_reg
    $cop0_compare_reg
    $cop0_status_reg
    $cop0_int_ctl_reg
    $cop0_srs_ctl_reg
    $cop0_cause_reg
    $cop0_epc_reg
    $cop0_pr_id_reg
    $cop0_ebase_reg
    $cop0_config_reg
    $cop0_config_1_reg
    $cop0_config_2_reg
    $cop0_config_3_reg
    $cop0_debug_reg
    $cop0_depc_reg
    $cop0_tag_lo_0_reg
    $cop0_tag_lo_2_reg
    $cop0_tag_hi_0_reg
    $cop0_tag_hi_2_reg
    $cop0_error_epc_reg
    $cop0_de_save_reg

    $cop0_index_reg_regnum
    $cop0_random_reg_regnum
    $cop0_entry_lo_0_reg_regnum
    $cop0_entry_lo_1_reg_regnum
    $cop0_context_reg_regnum
    $cop0_page_mask_reg_regnum
    $cop0_wired_reg_regnum
    $cop0_hwr_ena_reg_regnum
    $cop0_bad_vaddr_reg_regnum
    $cop0_count_reg_regnum
    $cop0_entry_hi_reg_regnum
    $cop0_compare_reg_regnum
    $cop0_status_reg_regnum
    $cop0_int_ctl_reg_regnum
    $cop0_srs_ctl_reg_regnum
    $cop0_cause_reg_regnum
    $cop0_epc_reg_regnum
    $cop0_pr_id_reg_regnum
    $cop0_ebase_reg_regnum
    $cop0_config_reg_regnum
    $cop0_config_1_reg_regnum
    $cop0_config_2_reg_regnum
    $cop0_config_3_reg_regnum
    $cop0_debug_reg_regnum
    $cop0_depc_reg_regnum
    $cop0_tag_lo_0_reg_regnum
    $cop0_tag_lo_2_reg_regnum
    $cop0_tag_hi_0_reg_regnum
    $cop0_tag_hi_2_reg_regnum
    $cop0_error_epc_reg_regnum
    $cop0_de_save_reg_regnum

    $cop0_index_reg_select
    $cop0_random_reg_select
    $cop0_entry_lo_0_reg_select
    $cop0_entry_lo_1_reg_select
    $cop0_context_reg_select
    $cop0_page_mask_reg_select
    $cop0_wired_reg_select
    $cop0_hwr_ena_reg_select
    $cop0_bad_vaddr_reg_select
    $cop0_count_reg_select
    $cop0_entry_hi_reg_select
    $cop0_compare_reg_select
    $cop0_status_reg_select
    $cop0_int_ctl_reg_select
    $cop0_srs_ctl_reg_select
    $cop0_cause_reg_select
    $cop0_epc_reg_select
    $cop0_pr_id_reg_select
    $cop0_ebase_reg_select
    $cop0_config_reg_select
    $cop0_config_1_reg_select
    $cop0_config_2_reg_select
    $cop0_config_3_reg_select
    $cop0_debug_reg_select
    $cop0_depc_reg_select
    $cop0_tag_lo_0_reg_select
    $cop0_tag_lo_2_reg_select
    $cop0_tag_hi_0_reg_select
    $cop0_tag_hi_2_reg_select
    $cop0_error_epc_reg_select
    $cop0_de_save_reg_select

    $cop0_index_reg_sz
    $cop0_random_reg_sz
    $cop0_entry_lo_0_reg_sz
    $cop0_entry_lo_1_reg_sz
    $cop0_context_reg_sz
    $cop0_page_mask_reg_sz
    $cop0_wired_reg_sz
    $cop0_hwr_ena_reg_sz
    $cop0_bad_vaddr_reg_sz
    $cop0_count_reg_sz
    $cop0_entry_hi_reg_sz
    $cop0_compare_reg_sz
    $cop0_status_reg_sz
    $cop0_int_ctl_reg_sz
    $cop0_srs_ctl_reg_sz
    $cop0_cause_reg_sz
    $cop0_epc_reg_sz
    $cop0_pr_id_reg_sz
    $cop0_ebase_reg_sz
    $cop0_config_reg_sz
    $cop0_config_1_reg_sz
    $cop0_config_2_reg_sz
    $cop0_config_3_reg_sz
    $cop0_debug_reg_sz
    $cop0_depc_reg_sz
    $cop0_tag_lo_0_reg_sz
    $cop0_tag_lo_2_reg_sz
    $cop0_tag_hi_0_reg_sz
    $cop0_tag_hi_2_reg_sz
    $cop0_error_epc_reg_sz
    $cop0_de_save_reg_sz

    $cop0_index_reg_msb
    $cop0_random_reg_msb
    $cop0_entry_lo_0_reg_msb
    $cop0_entry_lo_1_reg_msb
    $cop0_context_reg_msb
    $cop0_page_mask_reg_msb
    $cop0_wired_reg_msb
    $cop0_hwr_ena_reg_msb
    $cop0_bad_vaddr_reg_msb
    $cop0_count_reg_msb
    $cop0_entry_hi_reg_msb
    $cop0_compare_reg_msb
    $cop0_status_reg_msb
    $cop0_int_ctl_reg_msb
    $cop0_srs_ctl_reg_msb
    $cop0_cause_reg_msb
    $cop0_epc_reg_msb
    $cop0_pr_id_reg_msb
    $cop0_ebase_reg_msb
    $cop0_config_reg_msb
    $cop0_config_1_reg_msb
    $cop0_config_2_reg_msb
    $cop0_config_3_reg_msb
    $cop0_debug_reg_msb
    $cop0_depc_reg_msb
    $cop0_tag_lo_0_reg_msb
    $cop0_tag_lo_2_reg_msb
    $cop0_tag_hi_0_reg_msb
    $cop0_tag_hi_2_reg_msb
    $cop0_error_epc_reg_msb
    $cop0_de_save_reg_msb

    $cop0_index_reg_lsb
    $cop0_random_reg_lsb
    $cop0_entry_lo_0_reg_lsb
    $cop0_entry_lo_1_reg_lsb
    $cop0_context_reg_lsb
    $cop0_page_mask_reg_lsb
    $cop0_wired_reg_lsb
    $cop0_hwr_ena_reg_lsb
    $cop0_bad_vaddr_reg_lsb
    $cop0_count_reg_lsb
    $cop0_entry_hi_reg_lsb
    $cop0_compare_reg_lsb
    $cop0_status_reg_lsb
    $cop0_int_ctl_reg_lsb
    $cop0_srs_ctl_reg_lsb
    $cop0_cause_reg_lsb
    $cop0_epc_reg_lsb
    $cop0_pr_id_reg_lsb
    $cop0_ebase_reg_lsb
    $cop0_config_reg_lsb
    $cop0_config_1_reg_lsb
    $cop0_config_2_reg_lsb
    $cop0_config_3_reg_lsb
    $cop0_debug_reg_lsb
    $cop0_depc_reg_lsb
    $cop0_tag_lo_0_reg_lsb
    $cop0_tag_lo_2_reg_lsb
    $cop0_tag_hi_0_reg_lsb
    $cop0_tag_hi_2_reg_lsb
    $cop0_error_epc_reg_lsb
    $cop0_de_save_reg_lsb

    $cop0_index_reg_index
    $cop0_index_reg_p
    $cop0_random_reg_random
    $cop0_entry_lo_0_reg_g
    $cop0_entry_lo_0_reg_v
    $cop0_entry_lo_0_reg_d
    $cop0_entry_lo_0_reg_c
    $cop0_entry_lo_0_reg_pfn
    $cop0_entry_lo_0_reg_fill
    $cop0_entry_lo_1_reg_g
    $cop0_entry_lo_1_reg_v
    $cop0_entry_lo_1_reg_d
    $cop0_entry_lo_1_reg_c
    $cop0_entry_lo_1_reg_pfn
    $cop0_entry_lo_1_reg_fill
    $cop0_context_reg_bad_vpn2
    $cop0_context_reg_pte_base
    $cop0_page_mask_reg_mask
    $cop0_wired_reg_wired
    $cop0_hwr_ena_reg_cpu_num
    $cop0_hwr_ena_reg_synci_step
    $cop0_hwr_ena_reg_cc
    $cop0_hwr_ena_reg_cc_res
    $cop0_hwr_ena_reg_ignored
    $cop0_bad_vaddr_reg_bad_vaddr
    $cop0_count_reg_count
    $cop0_entry_hi_reg_asid
    $cop0_entry_hi_reg_vpn2
    $cop0_compare_reg_compare
    $cop0_status_reg_ie
    $cop0_status_reg_exl
    $cop0_status_reg_erl
    $cop0_status_reg_r0
    $cop0_status_reg_um
    $cop0_status_reg_ux
    $cop0_status_reg_sx
    $cop0_status_reg_kx
    $cop0_status_reg_im_0
    $cop0_status_reg_im_1
    $cop0_status_reg_im_7_2
    $cop0_status_reg_impl
    $cop0_status_reg_nmi
    $cop0_status_reg_sr
    $cop0_status_reg_ts
    $cop0_status_reg_bev
    $cop0_status_reg_px
    $cop0_status_reg_mx
    $cop0_status_reg_re
    $cop0_status_reg_fr
    $cop0_status_reg_rp
    $cop0_status_reg_cu0
    $cop0_status_reg_cu1
    $cop0_status_reg_cu2
    $cop0_status_reg_cu3
    $cop0_int_ctl_reg_vs
    $cop0_int_ctl_reg_ippci
    $cop0_int_ctl_reg_ipti
    $cop0_srs_ctl_reg_css
    $cop0_srs_ctl_reg_pss
    $cop0_srs_ctl_reg_ess
    $cop0_srs_ctl_reg_eicss
    $cop0_srs_ctl_reg_hss
    $cop0_cause_reg_exc_code
    $cop0_cause_reg_ip_0
    $cop0_cause_reg_ip_1
    $cop0_cause_reg_ip_7_2
    $cop0_cause_reg_wp
    $cop0_cause_reg_iv
    $cop0_cause_reg_pci
    $cop0_cause_reg_dc
    $cop0_cause_reg_ce
    $cop0_cause_reg_ti
    $cop0_cause_reg_bd
    $cop0_epc_reg_epc
    $cop0_pr_id_reg_rev
    $cop0_pr_id_reg_pid
    $cop0_pr_id_reg_cid
    $cop0_ebase_reg_cpu_num
    $cop0_ebase_reg_exc_base
    $cop0_ebase_reg_zero
    $cop0_ebase_reg_one
    $cop0_config_reg_k0
    $cop0_config_reg_vi
    $cop0_config_reg_mt
    $cop0_config_reg_ar
    $cop0_config_reg_at
    $cop0_config_reg_be
    $cop0_config_reg_ku
    $cop0_config_reg_k23
    $cop0_config_reg_m
    $cop0_config_1_reg_fp
    $cop0_config_1_reg_ep
    $cop0_config_1_reg_ca
    $cop0_config_1_reg_wr
    $cop0_config_1_reg_pc
    $cop0_config_1_reg_mdmx
    $cop0_config_1_reg_c2
    $cop0_config_1_reg_da
    $cop0_config_1_reg_dl
    $cop0_config_1_reg_ds
    $cop0_config_1_reg_ia
    $cop0_config_1_reg_il
    $cop0_config_1_reg_is
    $cop0_config_1_reg_ms
    $cop0_config_1_reg_m
    $cop0_config_2_reg_su
    $cop0_config_2_reg_tu
    $cop0_config_2_reg_m
    $cop0_config_3_reg_tl
    $cop0_config_3_reg_sm
    $cop0_config_3_reg_sp
    $cop0_config_3_reg_vint
    $cop0_config_3_reg_veic
    $cop0_config_3_reg_m
    $cop0_debug_reg_dss
    $cop0_debug_reg_dbp
    $cop0_debug_reg_ddbl
    $cop0_debug_reg_ddbs
    $cop0_debug_reg_dib
    $cop0_debug_reg_dint
    $cop0_debug_reg_dib
    $cop0_debug_reg_offline
    $cop0_debug_reg_sst
    $cop0_debug_reg_no_sst
    $cop0_debug_reg_dexc_code
    $cop0_debug_reg_ejtag_ver
    $cop0_debug_reg_ddbl_impr
    $cop0_debug_reg_ddbs_impr
    $cop0_debug_reg_iexi
    $cop0_debug_reg_dbus_ep
    $cop0_debug_reg_cache_ep
    $cop0_debug_reg_mcheck_pend
    $cop0_debug_reg_ibus_err_pend
    $cop0_debug_reg_count_dm
    $cop0_debug_reg_halt
    $cop0_debug_reg_doze
    $cop0_debug_reg_lsnm
    $cop0_debug_reg_no_dcr
    $cop0_debug_reg_dm
    $cop0_debug_reg_dbd
    $cop0_depc_reg_depc
    $cop0_tag_lo_0_reg_d
    $cop0_tag_lo_0_reg_v
    $cop0_tag_lo_0_reg_pa
    $cop0_error_epc_reg_error_epc
    $cop0_de_save_reg_de_save

    $cop0_index_reg_index_sz
    $cop0_index_reg_index_msb
    $cop0_index_reg_index_lsb
    $cop0_index_reg_p_sz
    $cop0_index_reg_p_msb
    $cop0_index_reg_p_lsb
    $cop0_random_reg_random_sz
    $cop0_random_reg_random_msb
    $cop0_random_reg_random_lsb
    $cop0_entry_lo_0_reg_g_sz
    $cop0_entry_lo_0_reg_g_msb
    $cop0_entry_lo_0_reg_g_lsb
    $cop0_entry_lo_0_reg_v_sz
    $cop0_entry_lo_0_reg_v_msb
    $cop0_entry_lo_0_reg_v_lsb
    $cop0_entry_lo_0_reg_d_sz
    $cop0_entry_lo_0_reg_d_msb
    $cop0_entry_lo_0_reg_d_lsb
    $cop0_entry_lo_0_reg_c_sz
    $cop0_entry_lo_0_reg_c_msb
    $cop0_entry_lo_0_reg_c_lsb
    $cop0_entry_lo_0_reg_pfn_sz
    $cop0_entry_lo_0_reg_pfn_msb
    $cop0_entry_lo_0_reg_pfn_lsb
    $cop0_entry_lo_0_reg_fill_sz
    $cop0_entry_lo_0_reg_fill_msb
    $cop0_entry_lo_0_reg_fill_lsb
    $cop0_entry_lo_1_reg_g_sz
    $cop0_entry_lo_1_reg_g_msb
    $cop0_entry_lo_1_reg_g_lsb
    $cop0_entry_lo_1_reg_v_sz
    $cop0_entry_lo_1_reg_v_msb
    $cop0_entry_lo_1_reg_v_lsb
    $cop0_entry_lo_1_reg_d_sz
    $cop0_entry_lo_1_reg_d_msb
    $cop0_entry_lo_1_reg_d_lsb
    $cop0_entry_lo_1_reg_c_sz
    $cop0_entry_lo_1_reg_c_msb
    $cop0_entry_lo_1_reg_c_lsb
    $cop0_entry_lo_1_reg_pfn_sz
    $cop0_entry_lo_1_reg_pfn_msb
    $cop0_entry_lo_1_reg_pfn_lsb
    $cop0_entry_lo_1_reg_fill_sz
    $cop0_entry_lo_1_reg_fill_msb
    $cop0_entry_lo_1_reg_fill_lsb
    $cop0_context_reg_bad_vpn2_sz
    $cop0_context_reg_bad_vpn2_msb
    $cop0_context_reg_bad_vpn2_lsb
    $cop0_context_reg_pte_base_sz
    $cop0_context_reg_pte_base_msb
    $cop0_context_reg_pte_base_lsb
    $cop0_page_mask_reg_mask_sz
    $cop0_page_mask_reg_mask_msb
    $cop0_page_mask_reg_mask_lsb
    $cop0_wired_reg_wired_sz
    $cop0_wired_reg_wired_msb
    $cop0_wired_reg_wired_lsb
    $cop0_hwr_ena_reg_cpu_num_sz
    $cop0_hwr_ena_reg_cpu_num_msb
    $cop0_hwr_ena_reg_cpu_num_lsb
    $cop0_hwr_ena_reg_synci_step_sz
    $cop0_hwr_ena_reg_synci_step_msb
    $cop0_hwr_ena_reg_synci_step_lsb
    $cop0_hwr_ena_reg_cc_sz
    $cop0_hwr_ena_reg_cc_msb
    $cop0_hwr_ena_reg_cc_lsb
    $cop0_hwr_ena_reg_cc_res_sz
    $cop0_hwr_ena_reg_cc_res_msb
    $cop0_hwr_ena_reg_cc_res_lsb
    $cop0_hwr_ena_reg_ignored_sz
    $cop0_hwr_ena_reg_ignored_msb
    $cop0_hwr_ena_reg_ignored_lsb
    $cop0_bad_vaddr_reg_bad_vaddr_sz
    $cop0_bad_vaddr_reg_bad_vaddr_msb
    $cop0_bad_vaddr_reg_bad_vaddr_lsb
    $cop0_count_reg_count_sz
    $cop0_count_reg_count_msb
    $cop0_count_reg_count_lsb
    $cop0_entry_hi_reg_asid_sz
    $cop0_entry_hi_reg_asid_msb
    $cop0_entry_hi_reg_asid_lsb
    $cop0_entry_hi_reg_vpn2_sz
    $cop0_entry_hi_reg_vpn2_msb
    $cop0_entry_hi_reg_vpn2_lsb
    $cop0_compare_reg_compare_sz
    $cop0_compare_reg_compare_msb
    $cop0_compare_reg_compare_lsb
    $cop0_status_reg_ie_sz
    $cop0_status_reg_ie_msb
    $cop0_status_reg_ie_lsb
    $cop0_status_reg_exl_sz
    $cop0_status_reg_exl_msb
    $cop0_status_reg_exl_lsb
    $cop0_status_reg_erl_sz
    $cop0_status_reg_erl_msb
    $cop0_status_reg_erl_lsb
    $cop0_status_reg_r0_sz
    $cop0_status_reg_r0_msb
    $cop0_status_reg_r0_lsb
    $cop0_status_reg_um_sz
    $cop0_status_reg_um_msb
    $cop0_status_reg_um_lsb
    $cop0_status_reg_ux_sz
    $cop0_status_reg_ux_msb
    $cop0_status_reg_ux_lsb
    $cop0_status_reg_sx_sz
    $cop0_status_reg_sx_msb
    $cop0_status_reg_sx_lsb
    $cop0_status_reg_kx_sz
    $cop0_status_reg_kx_msb
    $cop0_status_reg_kx_lsb
    $cop0_status_reg_im_0_sz
    $cop0_status_reg_im_0_msb
    $cop0_status_reg_im_0_lsb
    $cop0_status_reg_im_1_sz
    $cop0_status_reg_im_1_msb
    $cop0_status_reg_im_1_lsb
    $cop0_status_reg_im_0_sz
    $cop0_status_reg_im_0_msb
    $cop0_status_reg_im_0_lsb
    $cop0_status_reg_im_1_sz
    $cop0_status_reg_im_1_msb
    $cop0_status_reg_im_1_lsb
    $cop0_status_reg_im_7_2_sz
    $cop0_status_reg_im_7_2_msb
    $cop0_status_reg_im_7_2_lsb
    $cop0_status_reg_impl_sz
    $cop0_status_reg_impl_msb
    $cop0_status_reg_impl_lsb
    $cop0_status_reg_nmi_sz
    $cop0_status_reg_nmi_msb
    $cop0_status_reg_nmi_lsb
    $cop0_status_reg_sr_sz
    $cop0_status_reg_sr_msb
    $cop0_status_reg_sr_lsb
    $cop0_status_reg_ts_sz
    $cop0_status_reg_ts_msb
    $cop0_status_reg_ts_lsb
    $cop0_status_reg_ts_sz
    $cop0_status_reg_ts_msb
    $cop0_status_reg_ts_lsb
    $cop0_status_reg_bev_sz
    $cop0_status_reg_bev_msb
    $cop0_status_reg_bev_lsb
    $cop0_status_reg_px_sz
    $cop0_status_reg_px_msb
    $cop0_status_reg_px_lsb
    $cop0_status_reg_mx_sz
    $cop0_status_reg_mx_msb
    $cop0_status_reg_mx_lsb
    $cop0_status_reg_re_sz
    $cop0_status_reg_re_msb
    $cop0_status_reg_re_lsb
    $cop0_status_reg_fr_sz
    $cop0_status_reg_fr_msb
    $cop0_status_reg_fr_lsb
    $cop0_status_reg_rp_sz
    $cop0_status_reg_rp_msb
    $cop0_status_reg_rp_lsb
    $cop0_status_reg_cu0_sz
    $cop0_status_reg_cu0_msb
    $cop0_status_reg_cu0_lsb
    $cop0_status_reg_cu1_sz
    $cop0_status_reg_cu1_msb
    $cop0_status_reg_cu1_lsb
    $cop0_status_reg_cu2_sz
    $cop0_status_reg_cu2_msb
    $cop0_status_reg_cu2_lsb
    $cop0_status_reg_cu3_sz
    $cop0_status_reg_cu3_msb
    $cop0_status_reg_cu3_lsb
    $cop0_int_ctl_reg_vs_sz
    $cop0_int_ctl_reg_vs_msb
    $cop0_int_ctl_reg_vs_lsb
    $cop0_int_ctl_reg_ippci_sz
    $cop0_int_ctl_reg_ippci_msb
    $cop0_int_ctl_reg_ippci_lsb
    $cop0_int_ctl_reg_ipti_sz
    $cop0_int_ctl_reg_ipti_msb
    $cop0_int_ctl_reg_ipti_lsb
    $cop0_srs_ctl_reg_css_sz
    $cop0_srs_ctl_reg_css_msb
    $cop0_srs_ctl_reg_css_lsb
    $cop0_srs_ctl_reg_pss_sz
    $cop0_srs_ctl_reg_pss_msb
    $cop0_srs_ctl_reg_pss_lsb
    $cop0_srs_ctl_reg_ess_sz
    $cop0_srs_ctl_reg_ess_msb
    $cop0_srs_ctl_reg_ess_lsb
    $cop0_srs_ctl_reg_eicss_sz
    $cop0_srs_ctl_reg_eicss_msb
    $cop0_srs_ctl_reg_eicss_lsb
    $cop0_srs_ctl_reg_hss_sz
    $cop0_srs_ctl_reg_hss_msb
    $cop0_srs_ctl_reg_hss_lsb
    $cop0_cause_reg_exc_code_sz
    $cop0_cause_reg_exc_code_msb
    $cop0_cause_reg_exc_code_lsb
    $cop0_cause_reg_ip_0_sz
    $cop0_cause_reg_ip_0_msb
    $cop0_cause_reg_ip_0_lsb
    $cop0_cause_reg_ip_1_sz
    $cop0_cause_reg_ip_1_msb
    $cop0_cause_reg_ip_1_lsb
    $cop0_cause_reg_ip_7_2_sz
    $cop0_cause_reg_ip_7_2_msb
    $cop0_cause_reg_ip_7_2_lsb
    $cop0_cause_reg_wp_sz
    $cop0_cause_reg_wp_msb
    $cop0_cause_reg_wp_lsb
    $cop0_cause_reg_iv_sz
    $cop0_cause_reg_iv_msb
    $cop0_cause_reg_iv_lsb
    $cop0_cause_reg_pci_sz
    $cop0_cause_reg_pci_msb
    $cop0_cause_reg_pci_lsb
    $cop0_cause_reg_dc_sz
    $cop0_cause_reg_dc_msb
    $cop0_cause_reg_dc_lsb
    $cop0_cause_reg_ce_sz
    $cop0_cause_reg_ce_msb
    $cop0_cause_reg_ce_lsb
    $cop0_cause_reg_ti_sz
    $cop0_cause_reg_ti_msb
    $cop0_cause_reg_ti_lsb
    $cop0_cause_reg_bd_sz
    $cop0_cause_reg_bd_msb
    $cop0_cause_reg_bd_lsb
    $cop0_epc_reg_epc_sz
    $cop0_epc_reg_epc_msb
    $cop0_epc_reg_epc_lsb
    $cop0_pr_id_reg_rev_sz
    $cop0_pr_id_reg_rev_msb
    $cop0_pr_id_reg_rev_lsb
    $cop0_pr_id_reg_pid_sz
    $cop0_pr_id_reg_pid_msb
    $cop0_pr_id_reg_pid_lsb
    $cop0_pr_id_reg_cid_sz
    $cop0_pr_id_reg_cid_msb
    $cop0_pr_id_reg_cid_lsb
    $cop0_ebase_reg_cpu_num_sz
    $cop0_ebase_reg_cpu_num_msb
    $cop0_ebase_reg_cpu_num_lsb
    $cop0_ebase_reg_exc_base_sz
    $cop0_ebase_reg_exc_base_msb
    $cop0_ebase_reg_exc_base_lsb
    $cop0_ebase_reg_zero_sz
    $cop0_ebase_reg_zero_msb
    $cop0_ebase_reg_zero_lsb
    $cop0_ebase_reg_one_sz
    $cop0_ebase_reg_one_msb
    $cop0_ebase_reg_one_lsb
    $cop0_config_reg_k0_sz
    $cop0_config_reg_k0_msb
    $cop0_config_reg_k0_lsb
    $cop0_config_reg_vi_sz
    $cop0_config_reg_vi_msb
    $cop0_config_reg_vi_lsb
    $cop0_config_reg_mt_sz
    $cop0_config_reg_mt_msb
    $cop0_config_reg_mt_lsb
    $cop0_config_reg_ar_sz
    $cop0_config_reg_ar_msb
    $cop0_config_reg_ar_lsb
    $cop0_config_reg_at_sz
    $cop0_config_reg_at_msb
    $cop0_config_reg_at_lsb
    $cop0_config_reg_be_sz
    $cop0_config_reg_be_msb
    $cop0_config_reg_be_lsb
    $cop0_config_reg_ku_sz
    $cop0_config_reg_ku_msb
    $cop0_config_reg_ku_lsb
    $cop0_config_reg_k23_sz
    $cop0_config_reg_k23_msb
    $cop0_config_reg_k23_lsb
    $cop0_config_reg_m_sz
    $cop0_config_reg_m_msb
    $cop0_config_reg_m_lsb
    $cop0_config_1_reg_fp_sz
    $cop0_config_1_reg_fp_msb
    $cop0_config_1_reg_fp_lsb
    $cop0_config_1_reg_ep_sz
    $cop0_config_1_reg_ep_msb
    $cop0_config_1_reg_ep_lsb
    $cop0_config_1_reg_ca_sz
    $cop0_config_1_reg_ca_msb
    $cop0_config_1_reg_ca_lsb
    $cop0_config_1_reg_wr_sz
    $cop0_config_1_reg_wr_msb
    $cop0_config_1_reg_wr_lsb
    $cop0_config_1_reg_pc_sz
    $cop0_config_1_reg_pc_msb
    $cop0_config_1_reg_pc_lsb
    $cop0_config_1_reg_mdmx_sz
    $cop0_config_1_reg_mdmx_msb
    $cop0_config_1_reg_mdmx_lsb
    $cop0_config_1_reg_c2_sz
    $cop0_config_1_reg_c2_msb
    $cop0_config_1_reg_c2_lsb
    $cop0_config_1_reg_da_sz
    $cop0_config_1_reg_da_msb
    $cop0_config_1_reg_da_lsb
    $cop0_config_1_reg_dl_sz
    $cop0_config_1_reg_dl_msb
    $cop0_config_1_reg_dl_lsb
    $cop0_config_1_reg_ds_sz
    $cop0_config_1_reg_ds_msb
    $cop0_config_1_reg_ds_lsb
    $cop0_config_1_reg_ia_sz
    $cop0_config_1_reg_ia_msb
    $cop0_config_1_reg_ia_lsb
    $cop0_config_1_reg_il_sz
    $cop0_config_1_reg_il_msb
    $cop0_config_1_reg_il_lsb
    $cop0_config_1_reg_is_sz
    $cop0_config_1_reg_is_msb
    $cop0_config_1_reg_is_lsb
    $cop0_config_1_reg_ms_sz
    $cop0_config_1_reg_ms_msb
    $cop0_config_1_reg_ms_lsb
    $cop0_config_1_reg_m_sz
    $cop0_config_1_reg_m_msb
    $cop0_config_1_reg_m_lsb
    $cop0_config_2_reg_su_sz
    $cop0_config_2_reg_su_msb
    $cop0_config_2_reg_su_lsb
    $cop0_config_2_reg_tu_sz
    $cop0_config_2_reg_tu_msb
    $cop0_config_2_reg_tu_lsb
    $cop0_config_2_reg_m_sz
    $cop0_config_2_reg_m_msb
    $cop0_config_2_reg_m_lsb
    $cop0_config_3_reg_tl_sz
    $cop0_config_3_reg_tl_msb
    $cop0_config_3_reg_tl_lsb
    $cop0_config_3_reg_sm_sz
    $cop0_config_3_reg_sm_msb
    $cop0_config_3_reg_sm_lsb
    $cop0_config_3_reg_sp_sz
    $cop0_config_3_reg_sp_msb
    $cop0_config_3_reg_sp_lsb
    $cop0_config_3_reg_vint_sz
    $cop0_config_3_reg_vint_msb
    $cop0_config_3_reg_vint_lsb
    $cop0_config_3_reg_veic_sz
    $cop0_config_3_reg_veic_msb
    $cop0_config_3_reg_veic_lsb
    $cop0_config_3_reg_m_sz
    $cop0_config_3_reg_m_msb
    $cop0_config_3_reg_m_lsb
    $cop0_debug_reg_dss_sz
    $cop0_debug_reg_dss_msb
    $cop0_debug_reg_dss_lsb
    $cop0_debug_reg_dbp_sz
    $cop0_debug_reg_dbp_msb
    $cop0_debug_reg_dbp_lsb
    $cop0_debug_reg_ddbl_sz
    $cop0_debug_reg_ddbl_msb
    $cop0_debug_reg_ddbl_lsb
    $cop0_debug_reg_ddbs_sz
    $cop0_debug_reg_ddbs_msb
    $cop0_debug_reg_ddbs_lsb
    $cop0_debug_reg_dib_sz
    $cop0_debug_reg_dib_msb
    $cop0_debug_reg_dib_lsb
    $cop0_debug_reg_dint_sz
    $cop0_debug_reg_dint_msb
    $cop0_debug_reg_dint_lsb
    $cop0_debug_reg_dib_sz
    $cop0_debug_reg_dib_msb
    $cop0_debug_reg_dib_lsb
    $cop0_debug_reg_offline_sz
    $cop0_debug_reg_offline_msb
    $cop0_debug_reg_offline_lsb
    $cop0_debug_reg_sst_sz
    $cop0_debug_reg_sst_msb
    $cop0_debug_reg_sst_lsb
    $cop0_debug_reg_no_sst_sz
    $cop0_debug_reg_no_sst_msb
    $cop0_debug_reg_no_sst_lsb
    $cop0_debug_reg_dexc_code_sz
    $cop0_debug_reg_dexc_code_msb
    $cop0_debug_reg_dexc_code_lsb
    $cop0_debug_reg_ejtag_ver_sz
    $cop0_debug_reg_ejtag_ver_msb
    $cop0_debug_reg_ejtag_ver_lsb
    $cop0_debug_reg_ddbl_impr_sz
    $cop0_debug_reg_ddbl_impr_msb
    $cop0_debug_reg_ddbl_impr_lsb
    $cop0_debug_reg_ddbs_impr_sz
    $cop0_debug_reg_ddbs_impr_msb
    $cop0_debug_reg_ddbs_impr_lsb
    $cop0_debug_reg_iexi_sz
    $cop0_debug_reg_iexi_msb
    $cop0_debug_reg_iexi_lsb
    $cop0_debug_reg_dbus_ep_sz
    $cop0_debug_reg_dbus_ep_msb
    $cop0_debug_reg_dbus_ep_lsb
    $cop0_debug_reg_cache_ep_sz
    $cop0_debug_reg_cache_ep_msb
    $cop0_debug_reg_cache_ep_lsb
    $cop0_debug_reg_mcheck_pend_sz
    $cop0_debug_reg_mcheck_pend_msb
    $cop0_debug_reg_mcheck_pend_lsb
    $cop0_debug_reg_ibus_err_pend_sz
    $cop0_debug_reg_ibus_err_pend_msb
    $cop0_debug_reg_ibus_err_pend_lsb
    $cop0_debug_reg_count_dm_sz
    $cop0_debug_reg_count_dm_msb
    $cop0_debug_reg_count_dm_lsb
    $cop0_debug_reg_halt_sz
    $cop0_debug_reg_halt_msb
    $cop0_debug_reg_halt_lsb
    $cop0_debug_reg_doze_sz
    $cop0_debug_reg_doze_msb
    $cop0_debug_reg_doze_lsb
    $cop0_debug_reg_lsnm_sz
    $cop0_debug_reg_lsnm_msb
    $cop0_debug_reg_lsnm_lsb
    $cop0_debug_reg_no_dcr_sz
    $cop0_debug_reg_no_dcr_msb
    $cop0_debug_reg_no_dcr_lsb
    $cop0_debug_reg_dm_sz
    $cop0_debug_reg_dm_msb
    $cop0_debug_reg_dm_lsb
    $cop0_debug_reg_dbd_sz
    $cop0_debug_reg_dbd_msb
    $cop0_debug_reg_dbd_lsb
    $cop0_depc_reg_depc_sz
    $cop0_depc_reg_depc_msb
    $cop0_depc_reg_depc_lsb
    $cop0_tag_lo_0_reg_d_sz
    $cop0_tag_lo_0_reg_d_msb
    $cop0_tag_lo_0_reg_d_lsb
    $cop0_tag_lo_0_reg_v_sz
    $cop0_tag_lo_0_reg_v_msb
    $cop0_tag_lo_0_reg_v_lsb
    $cop0_tag_lo_0_reg_pa_sz
    $cop0_tag_lo_0_reg_pa_msb
    $cop0_tag_lo_0_reg_pa_lsb
    $cop0_error_epc_reg_error_epc_sz
    $cop0_error_epc_reg_error_epc_msb
    $cop0_error_epc_reg_error_epc_lsb
    $cop0_de_save_reg_de_save_sz
    $cop0_de_save_reg_de_save_msb
    $cop0_de_save_reg_de_save_lsb

    $coherency_uncached
    $coherency_cached
    $boot_exception_vector_normal
    $boot_exception_vector_bootstrap
    $vector_spacing_0_bytes
    $vector_spacing_32_bytes
    $vector_spacing_64_bytes
    $vector_spacing_128_bytes
    $vector_spacing_256_bytes
    $vector_spacing_512_bytes
    $interrupt_num_hw0
    $interrupt_num_hw1
    $interrupt_num_hw2
    $interrupt_num_hw3
    $interrupt_num_hw4
    $interrupt_num_hw5
    $nevada_revision
    $nevada_processor_id
    $altera_company_id
    $mmu_type_none
    $mmu_type_standard_tlb
    $mmu_type_bat_tlb
    $mmu_type_fmt_tlb
    $arch_revision_mips32_release1
    $arch_revision_mips32_release2
    $arch_type_mips32
    $arch_type_mips64_only_32bit_segments
    $arch_type_mips64_all_segments
    $cache_assoc_direct_mapped
    $cache_assoc_2_way
    $cache_assoc_3_way
    $cache_assoc_4_way
    $cache_assoc_5_way
    $cache_assoc_6_way
    $cache_assoc_7_way
    $cache_assoc_8_way
    $cache_0_byte_lines
    $cache_4_byte_lines
    $cache_8_byte_lines
    $cache_16_byte_lines
    $cache_32_byte_lines
    $cache_64_byte_lines
    $cache_128_byte_lines
    $cache_64_sets_per_way
    $cache_128_sets_per_way
    $cache_256_sets_per_way
    $cache_512_sets_per_way
    $cache_1024_sets_per_way
    $cache_2048_sets_per_way
    $cache_4096_sets_per_way
    $ejtag_version_1_and_2_0
    $ejtag_version_2_5
    $ejtag_version_2_6
    $ejtag_version_3_1
);

use cpu_utils;
use cpu_control_reg;
use strict;














our $cop0_index_reg;
our $cop0_random_reg;
our $cop0_entry_lo_0_reg;
our $cop0_entry_lo_1_reg;
our $cop0_context_reg;
our $cop0_page_mask_reg;
our $cop0_wired_reg;
our $cop0_hwr_ena_reg;
our $cop0_bad_vaddr_reg;
our $cop0_count_reg;
our $cop0_entry_hi_reg;
our $cop0_compare_reg;
our $cop0_status_reg;
our $cop0_int_ctl_reg;
our $cop0_srs_ctl_reg;
our $cop0_cause_reg;
our $cop0_epc_reg;
our $cop0_pr_id_reg;
our $cop0_ebase_reg;
our $cop0_config_reg;
our $cop0_config_1_reg;
our $cop0_config_2_reg;
our $cop0_config_3_reg;
our $cop0_debug_reg;
our $cop0_depc_reg;
our $cop0_tag_lo_0_reg;
our $cop0_tag_lo_2_reg;
our $cop0_tag_hi_0_reg;
our $cop0_tag_hi_2_reg;
our $cop0_error_epc_reg;
our $cop0_de_save_reg;


our @check_control_regs;



our $cop0_index_reg_regnum;
our $cop0_random_reg_regnum;
our $cop0_entry_lo_0_reg_regnum;
our $cop0_entry_lo_1_reg_regnum;
our $cop0_context_reg_regnum;
our $cop0_page_mask_reg_regnum;
our $cop0_wired_reg_regnum;
our $cop0_hwr_ena_reg_regnum;
our $cop0_bad_vaddr_reg_regnum;
our $cop0_count_reg_regnum;
our $cop0_entry_hi_reg_regnum;
our $cop0_compare_reg_regnum;
our $cop0_status_reg_regnum;
our $cop0_int_ctl_reg_regnum;
our $cop0_srs_ctl_reg_regnum;
our $cop0_cause_reg_regnum;
our $cop0_epc_reg_regnum;
our $cop0_pr_id_reg_regnum;
our $cop0_ebase_reg_regnum;
our $cop0_config_reg_regnum;
our $cop0_config_1_reg_regnum;
our $cop0_config_2_reg_regnum;
our $cop0_config_3_reg_regnum;
our $cop0_debug_reg_regnum;
our $cop0_depc_reg_regnum;
our $cop0_tag_lo_0_reg_regnum;
our $cop0_tag_lo_2_reg_regnum;
our $cop0_tag_hi_0_reg_regnum;
our $cop0_tag_hi_2_reg_regnum;
our $cop0_error_epc_reg_regnum;
our $cop0_de_save_reg_regnum;

our $cop0_index_reg_select;
our $cop0_random_reg_select;
our $cop0_entry_lo_0_reg_select;
our $cop0_entry_lo_1_reg_select;
our $cop0_context_reg_select;
our $cop0_page_mask_reg_select;
our $cop0_wired_reg_select;
our $cop0_hwr_ena_reg_select;
our $cop0_bad_vaddr_reg_select;
our $cop0_count_reg_select;
our $cop0_entry_hi_reg_select;
our $cop0_compare_reg_select;
our $cop0_status_reg_select;
our $cop0_int_ctl_reg_select;
our $cop0_srs_ctl_reg_select;
our $cop0_cause_reg_select;
our $cop0_epc_reg_select;
our $cop0_pr_id_reg_select;
our $cop0_ebase_reg_select;
our $cop0_config_reg_select;
our $cop0_config_1_reg_select;
our $cop0_config_2_reg_select;
our $cop0_config_3_reg_select;
our $cop0_debug_reg_select;
our $cop0_depc_reg_select;
our $cop0_tag_lo_0_reg_select;
our $cop0_tag_lo_2_reg_select;
our $cop0_tag_hi_0_reg_select;
our $cop0_tag_hi_2_reg_select;
our $cop0_error_epc_reg_select;
our $cop0_de_save_reg_select;



our $cop0_index_reg_sz;
our $cop0_random_reg_sz;
our $cop0_entry_lo_0_reg_sz;
our $cop0_entry_lo_1_reg_sz;
our $cop0_context_reg_sz;
our $cop0_page_mask_reg_sz;
our $cop0_wired_reg_sz;
our $cop0_hwr_ena_reg_sz;
our $cop0_bad_vaddr_reg_sz;
our $cop0_count_reg_sz;
our $cop0_entry_hi_reg_sz;
our $cop0_compare_reg_sz;
our $cop0_status_reg_sz;
our $cop0_int_ctl_reg_sz;
our $cop0_srs_ctl_reg_sz;
our $cop0_cause_reg_sz;
our $cop0_epc_reg_sz;
our $cop0_pr_id_reg_sz;
our $cop0_ebase_reg_sz;
our $cop0_config_reg_sz;
our $cop0_config_1_reg_sz;
our $cop0_config_2_reg_sz;
our $cop0_config_3_reg_sz;
our $cop0_debug_reg_sz;
our $cop0_depc_reg_sz;
our $cop0_tag_lo_0_reg_sz;
our $cop0_tag_lo_2_reg_sz;
our $cop0_tag_hi_0_reg_sz;
our $cop0_tag_hi_2_reg_sz;
our $cop0_error_epc_reg_sz;
our $cop0_de_save_reg_sz;

our $cop0_index_reg_msb;
our $cop0_random_reg_msb;
our $cop0_entry_lo_0_reg_msb;
our $cop0_entry_lo_1_reg_msb;
our $cop0_context_reg_msb;
our $cop0_page_mask_reg_msb;
our $cop0_wired_reg_msb;
our $cop0_hwr_ena_reg_msb;
our $cop0_bad_vaddr_reg_msb;
our $cop0_count_reg_msb;
our $cop0_entry_hi_reg_msb;
our $cop0_compare_reg_msb;
our $cop0_status_reg_msb;
our $cop0_int_ctl_reg_msb;
our $cop0_srs_ctl_reg_msb;
our $cop0_cause_reg_msb;
our $cop0_epc_reg_msb;
our $cop0_pr_id_reg_msb;
our $cop0_ebase_reg_msb;
our $cop0_config_reg_msb;
our $cop0_config_1_reg_msb;
our $cop0_config_2_reg_msb;
our $cop0_config_3_reg_msb;
our $cop0_debug_reg_msb;
our $cop0_depc_reg_msb;
our $cop0_tag_lo_0_reg_msb;
our $cop0_tag_lo_2_reg_msb;
our $cop0_tag_hi_0_reg_msb;
our $cop0_tag_hi_2_reg_msb;
our $cop0_error_epc_reg_msb;
our $cop0_de_save_reg_msb;

our $cop0_index_reg_lsb;
our $cop0_random_reg_lsb;
our $cop0_entry_lo_0_reg_lsb;
our $cop0_entry_lo_1_reg_lsb;
our $cop0_context_reg_lsb;
our $cop0_page_mask_reg_lsb;
our $cop0_wired_reg_lsb;
our $cop0_hwr_ena_reg_lsb;
our $cop0_bad_vaddr_reg_lsb;
our $cop0_count_reg_lsb;
our $cop0_entry_hi_reg_lsb;
our $cop0_compare_reg_lsb;
our $cop0_status_reg_lsb;
our $cop0_int_ctl_reg_lsb;
our $cop0_srs_ctl_reg_lsb;
our $cop0_cause_reg_lsb;
our $cop0_epc_reg_lsb;
our $cop0_pr_id_reg_lsb;
our $cop0_ebase_reg_lsb;
our $cop0_config_reg_lsb;
our $cop0_config_1_reg_lsb;
our $cop0_config_2_reg_lsb;
our $cop0_config_3_reg_lsb;
our $cop0_debug_reg_lsb;
our $cop0_depc_reg_lsb;
our $cop0_tag_lo_0_reg_lsb;
our $cop0_tag_lo_2_reg_lsb;
our $cop0_tag_hi_0_reg_lsb;
our $cop0_tag_hi_2_reg_lsb;
our $cop0_error_epc_reg_lsb;
our $cop0_de_save_reg_lsb;



our $cop0_index_reg_index;
our $cop0_index_reg_p;
our $cop0_random_reg_random;
our $cop0_entry_lo_0_reg_g;
our $cop0_entry_lo_0_reg_v;
our $cop0_entry_lo_0_reg_d;
our $cop0_entry_lo_0_reg_c;
our $cop0_entry_lo_0_reg_pfn;
our $cop0_entry_lo_0_reg_fill;
our $cop0_entry_lo_1_reg_g;
our $cop0_entry_lo_1_reg_v;
our $cop0_entry_lo_1_reg_d;
our $cop0_entry_lo_1_reg_c;
our $cop0_entry_lo_1_reg_pfn;
our $cop0_entry_lo_1_reg_fill;
our $cop0_context_reg_bad_vpn2;
our $cop0_context_reg_pte_base;
our $cop0_page_mask_reg_mask;
our $cop0_wired_reg_wired;
our $cop0_hwr_ena_reg_cpu_num;
our $cop0_hwr_ena_reg_synci_step;
our $cop0_hwr_ena_reg_cc;
our $cop0_hwr_ena_reg_cc_res;
our $cop0_hwr_ena_reg_ignored;
our $cop0_bad_vaddr_reg_bad_vaddr;
our $cop0_count_reg_count;
our $cop0_entry_hi_reg_asid;
our $cop0_entry_hi_reg_vpn2;
our $cop0_compare_reg_compare;
our $cop0_status_reg_ie;
our $cop0_status_reg_exl;
our $cop0_status_reg_erl;
our $cop0_status_reg_r0;
our $cop0_status_reg_um;
our $cop0_status_reg_ux;
our $cop0_status_reg_sx;
our $cop0_status_reg_kx;
our $cop0_status_reg_im_0;
our $cop0_status_reg_im_1;
our $cop0_status_reg_im_7_2;
our $cop0_status_reg_impl;
our $cop0_status_reg_nmi;
our $cop0_status_reg_sr;
our $cop0_status_reg_ts;
our $cop0_status_reg_bev;
our $cop0_status_reg_px;
our $cop0_status_reg_mx;
our $cop0_status_reg_re;
our $cop0_status_reg_fr;
our $cop0_status_reg_rp;
our $cop0_status_reg_cu0;
our $cop0_status_reg_cu1;
our $cop0_status_reg_cu2;
our $cop0_status_reg_cu3;
our $cop0_int_ctl_reg_vs;
our $cop0_int_ctl_reg_ippci;
our $cop0_int_ctl_reg_ipti;
our $cop0_srs_ctl_reg_css;
our $cop0_srs_ctl_reg_pss;
our $cop0_srs_ctl_reg_ess;
our $cop0_srs_ctl_reg_eicss;
our $cop0_srs_ctl_reg_hss;
our $cop0_cause_reg_exc_code;
our $cop0_cause_reg_ip_0;
our $cop0_cause_reg_ip_1;
our $cop0_cause_reg_ip_7_2;
our $cop0_cause_reg_wp;
our $cop0_cause_reg_iv;
our $cop0_cause_reg_pci;
our $cop0_cause_reg_dc;
our $cop0_cause_reg_ce;
our $cop0_cause_reg_ti;
our $cop0_cause_reg_bd;
our $cop0_epc_reg_epc;
our $cop0_pr_id_reg_rev;
our $cop0_pr_id_reg_pid;
our $cop0_pr_id_reg_cid;
our $cop0_ebase_reg_cpu_num;
our $cop0_ebase_reg_exc_base;
our $cop0_ebase_reg_zero;
our $cop0_ebase_reg_one;
our $cop0_config_reg_k0;
our $cop0_config_reg_vi;
our $cop0_config_reg_mt;
our $cop0_config_reg_ar;
our $cop0_config_reg_at;
our $cop0_config_reg_be;
our $cop0_config_reg_ku;
our $cop0_config_reg_k23;
our $cop0_config_reg_m;
our $cop0_config_1_reg_fp;
our $cop0_config_1_reg_ep;
our $cop0_config_1_reg_ca;
our $cop0_config_1_reg_wr;
our $cop0_config_1_reg_pc;
our $cop0_config_1_reg_mdmx;
our $cop0_config_1_reg_c2;
our $cop0_config_1_reg_da;
our $cop0_config_1_reg_dl;
our $cop0_config_1_reg_ds;
our $cop0_config_1_reg_ia;
our $cop0_config_1_reg_il;
our $cop0_config_1_reg_is;
our $cop0_config_1_reg_ms;
our $cop0_config_1_reg_m;
our $cop0_config_2_reg_su;
our $cop0_config_2_reg_tu;
our $cop0_config_2_reg_m;
our $cop0_config_3_reg_tl;
our $cop0_config_3_reg_sm;
our $cop0_config_3_reg_sp;
our $cop0_config_3_reg_vint;
our $cop0_config_3_reg_veic;
our $cop0_config_3_reg_m;
our $cop0_debug_reg_dss;
our $cop0_debug_reg_dbp;
our $cop0_debug_reg_ddbl;
our $cop0_debug_reg_ddbs;
our $cop0_debug_reg_dib;
our $cop0_debug_reg_dint;
our $cop0_debug_reg_dib;
our $cop0_debug_reg_offline;
our $cop0_debug_reg_sst;
our $cop0_debug_reg_no_sst;
our $cop0_debug_reg_dexc_code;
our $cop0_debug_reg_ejtag_ver;
our $cop0_debug_reg_ddbl_impr;
our $cop0_debug_reg_ddbs_impr;
our $cop0_debug_reg_iexi;
our $cop0_debug_reg_dbus_ep;
our $cop0_debug_reg_cache_ep;
our $cop0_debug_reg_mcheck_pend;
our $cop0_debug_reg_ibus_err_pend;
our $cop0_debug_reg_count_dm;
our $cop0_debug_reg_halt;
our $cop0_debug_reg_doze;
our $cop0_debug_reg_lsnm;
our $cop0_debug_reg_no_dcr;
our $cop0_debug_reg_dm;
our $cop0_debug_reg_dbd;
our $cop0_depc_reg_depc;
our $cop0_tag_lo_0_reg_d;
our $cop0_tag_lo_0_reg_v;
our $cop0_tag_lo_0_reg_pa;
our $cop0_error_epc_reg_error_epc;
our $cop0_de_save_reg_de_save;



our $cop0_index_reg_index_sz;
our $cop0_index_reg_index_msb;
our $cop0_index_reg_index_lsb;
our $cop0_index_reg_p_sz;
our $cop0_index_reg_p_msb;
our $cop0_index_reg_p_lsb;
our $cop0_random_reg_random_sz;
our $cop0_random_reg_random_msb;
our $cop0_random_reg_random_lsb;
our $cop0_entry_lo_0_reg_g_sz;
our $cop0_entry_lo_0_reg_g_msb;
our $cop0_entry_lo_0_reg_g_lsb;
our $cop0_entry_lo_0_reg_v_sz;
our $cop0_entry_lo_0_reg_v_msb;
our $cop0_entry_lo_0_reg_v_lsb;
our $cop0_entry_lo_0_reg_d_sz;
our $cop0_entry_lo_0_reg_d_msb;
our $cop0_entry_lo_0_reg_d_lsb;
our $cop0_entry_lo_0_reg_c_sz;
our $cop0_entry_lo_0_reg_c_msb;
our $cop0_entry_lo_0_reg_c_lsb;
our $cop0_entry_lo_0_reg_pfn_sz;
our $cop0_entry_lo_0_reg_pfn_msb;
our $cop0_entry_lo_0_reg_pfn_lsb;
our $cop0_entry_lo_0_reg_fill_sz;
our $cop0_entry_lo_0_reg_fill_msb;
our $cop0_entry_lo_0_reg_fill_lsb;
our $cop0_entry_lo_1_reg_g_sz;
our $cop0_entry_lo_1_reg_g_msb;
our $cop0_entry_lo_1_reg_g_lsb;
our $cop0_entry_lo_1_reg_v_sz;
our $cop0_entry_lo_1_reg_v_msb;
our $cop0_entry_lo_1_reg_v_lsb;
our $cop0_entry_lo_1_reg_d_sz;
our $cop0_entry_lo_1_reg_d_msb;
our $cop0_entry_lo_1_reg_d_lsb;
our $cop0_entry_lo_1_reg_c_sz;
our $cop0_entry_lo_1_reg_c_msb;
our $cop0_entry_lo_1_reg_c_lsb;
our $cop0_entry_lo_1_reg_pfn_sz;
our $cop0_entry_lo_1_reg_pfn_msb;
our $cop0_entry_lo_1_reg_pfn_lsb;
our $cop0_entry_lo_1_reg_fill_sz;
our $cop0_entry_lo_1_reg_fill_msb;
our $cop0_entry_lo_1_reg_fill_lsb;
our $cop0_context_reg_bad_vpn2_sz;
our $cop0_context_reg_bad_vpn2_msb;
our $cop0_context_reg_bad_vpn2_lsb;
our $cop0_context_reg_pte_base_sz;
our $cop0_context_reg_pte_base_msb;
our $cop0_context_reg_pte_base_lsb;
our $cop0_page_mask_reg_mask_sz;
our $cop0_page_mask_reg_mask_msb;
our $cop0_page_mask_reg_mask_lsb;
our $cop0_wired_reg_wired_sz;
our $cop0_wired_reg_wired_msb;
our $cop0_wired_reg_wired_lsb;
our $cop0_hwr_ena_reg_cpu_num_sz;
our $cop0_hwr_ena_reg_cpu_num_msb;
our $cop0_hwr_ena_reg_cpu_num_lsb;
our $cop0_hwr_ena_reg_synci_step_sz;
our $cop0_hwr_ena_reg_synci_step_msb;
our $cop0_hwr_ena_reg_synci_step_lsb;
our $cop0_hwr_ena_reg_cc_sz;
our $cop0_hwr_ena_reg_cc_msb;
our $cop0_hwr_ena_reg_cc_lsb;
our $cop0_hwr_ena_reg_cc_res_sz;
our $cop0_hwr_ena_reg_cc_res_msb;
our $cop0_hwr_ena_reg_cc_res_lsb;
our $cop0_hwr_ena_reg_ignored_sz;
our $cop0_hwr_ena_reg_ignored_msb;
our $cop0_hwr_ena_reg_ignored_lsb;
our $cop0_bad_vaddr_reg_bad_vaddr_sz;
our $cop0_bad_vaddr_reg_bad_vaddr_msb;
our $cop0_bad_vaddr_reg_bad_vaddr_lsb;
our $cop0_count_reg_count_sz;
our $cop0_count_reg_count_msb;
our $cop0_count_reg_count_lsb;
our $cop0_entry_hi_reg_asid_sz;
our $cop0_entry_hi_reg_asid_msb;
our $cop0_entry_hi_reg_asid_lsb;
our $cop0_entry_hi_reg_vpn2_sz;
our $cop0_entry_hi_reg_vpn2_msb;
our $cop0_entry_hi_reg_vpn2_lsb;
our $cop0_compare_reg_compare_sz;
our $cop0_compare_reg_compare_msb;
our $cop0_compare_reg_compare_lsb;
our $cop0_status_reg_ie_sz;
our $cop0_status_reg_ie_msb;
our $cop0_status_reg_ie_lsb;
our $cop0_status_reg_exl_sz;
our $cop0_status_reg_exl_msb;
our $cop0_status_reg_exl_lsb;
our $cop0_status_reg_erl_sz;
our $cop0_status_reg_erl_msb;
our $cop0_status_reg_erl_lsb;
our $cop0_status_reg_r0_sz;
our $cop0_status_reg_r0_msb;
our $cop0_status_reg_r0_lsb;
our $cop0_status_reg_um_sz;
our $cop0_status_reg_um_msb;
our $cop0_status_reg_um_lsb;
our $cop0_status_reg_ux_sz;
our $cop0_status_reg_ux_msb;
our $cop0_status_reg_ux_lsb;
our $cop0_status_reg_sx_sz;
our $cop0_status_reg_sx_msb;
our $cop0_status_reg_sx_lsb;
our $cop0_status_reg_kx_sz;
our $cop0_status_reg_kx_msb;
our $cop0_status_reg_kx_lsb;
our $cop0_status_reg_im_0_sz;
our $cop0_status_reg_im_0_msb;
our $cop0_status_reg_im_0_lsb;
our $cop0_status_reg_im_1_sz;
our $cop0_status_reg_im_1_msb;
our $cop0_status_reg_im_1_lsb;
our $cop0_status_reg_im_0_sz;
our $cop0_status_reg_im_0_msb;
our $cop0_status_reg_im_0_lsb;
our $cop0_status_reg_im_1_sz;
our $cop0_status_reg_im_1_msb;
our $cop0_status_reg_im_1_lsb;
our $cop0_status_reg_im_7_2_sz;
our $cop0_status_reg_im_7_2_msb;
our $cop0_status_reg_im_7_2_lsb;
our $cop0_status_reg_impl_sz;
our $cop0_status_reg_impl_msb;
our $cop0_status_reg_impl_lsb;
our $cop0_status_reg_nmi_sz;
our $cop0_status_reg_nmi_msb;
our $cop0_status_reg_nmi_lsb;
our $cop0_status_reg_sr_sz;
our $cop0_status_reg_sr_msb;
our $cop0_status_reg_sr_lsb;
our $cop0_status_reg_ts_sz;
our $cop0_status_reg_ts_msb;
our $cop0_status_reg_ts_lsb;
our $cop0_status_reg_ts_sz;
our $cop0_status_reg_ts_msb;
our $cop0_status_reg_ts_lsb;
our $cop0_status_reg_bev_sz;
our $cop0_status_reg_bev_msb;
our $cop0_status_reg_bev_lsb;
our $cop0_status_reg_px_sz;
our $cop0_status_reg_px_msb;
our $cop0_status_reg_px_lsb;
our $cop0_status_reg_mx_sz;
our $cop0_status_reg_mx_msb;
our $cop0_status_reg_mx_lsb;
our $cop0_status_reg_re_sz;
our $cop0_status_reg_re_msb;
our $cop0_status_reg_re_lsb;
our $cop0_status_reg_fr_sz;
our $cop0_status_reg_fr_msb;
our $cop0_status_reg_fr_lsb;
our $cop0_status_reg_rp_sz;
our $cop0_status_reg_rp_msb;
our $cop0_status_reg_rp_lsb;
our $cop0_status_reg_cu0_sz;
our $cop0_status_reg_cu0_msb;
our $cop0_status_reg_cu0_lsb;
our $cop0_status_reg_cu1_sz;
our $cop0_status_reg_cu1_msb;
our $cop0_status_reg_cu1_lsb;
our $cop0_status_reg_cu2_sz;
our $cop0_status_reg_cu2_msb;
our $cop0_status_reg_cu2_lsb;
our $cop0_status_reg_cu3_sz;
our $cop0_status_reg_cu3_msb;
our $cop0_status_reg_cu3_lsb;
our $cop0_int_ctl_reg_vs_sz;
our $cop0_int_ctl_reg_vs_msb;
our $cop0_int_ctl_reg_vs_lsb;
our $cop0_int_ctl_reg_ippci_sz;
our $cop0_int_ctl_reg_ippci_msb;
our $cop0_int_ctl_reg_ippci_lsb;
our $cop0_int_ctl_reg_ipti_sz;
our $cop0_int_ctl_reg_ipti_msb;
our $cop0_int_ctl_reg_ipti_lsb;
our $cop0_srs_ctl_reg_css_sz;
our $cop0_srs_ctl_reg_css_msb;
our $cop0_srs_ctl_reg_css_lsb;
our $cop0_srs_ctl_reg_pss_sz;
our $cop0_srs_ctl_reg_pss_msb;
our $cop0_srs_ctl_reg_pss_lsb;
our $cop0_srs_ctl_reg_ess_sz;
our $cop0_srs_ctl_reg_ess_msb;
our $cop0_srs_ctl_reg_ess_lsb;
our $cop0_srs_ctl_reg_eicss_sz;
our $cop0_srs_ctl_reg_eicss_msb;
our $cop0_srs_ctl_reg_eicss_lsb;
our $cop0_srs_ctl_reg_hss_sz;
our $cop0_srs_ctl_reg_hss_msb;
our $cop0_srs_ctl_reg_hss_lsb;
our $cop0_cause_reg_exc_code_sz;
our $cop0_cause_reg_exc_code_msb;
our $cop0_cause_reg_exc_code_lsb;
our $cop0_cause_reg_ip_0_sz;
our $cop0_cause_reg_ip_0_msb;
our $cop0_cause_reg_ip_0_lsb;
our $cop0_cause_reg_ip_1_sz;
our $cop0_cause_reg_ip_1_msb;
our $cop0_cause_reg_ip_1_lsb;
our $cop0_cause_reg_ip_7_2_sz;
our $cop0_cause_reg_ip_7_2_msb;
our $cop0_cause_reg_ip_7_2_lsb;
our $cop0_cause_reg_wp_sz;
our $cop0_cause_reg_wp_msb;
our $cop0_cause_reg_wp_lsb;
our $cop0_cause_reg_iv_sz;
our $cop0_cause_reg_iv_msb;
our $cop0_cause_reg_iv_lsb;
our $cop0_cause_reg_pci_sz;
our $cop0_cause_reg_pci_msb;
our $cop0_cause_reg_pci_lsb;
our $cop0_cause_reg_dc_sz;
our $cop0_cause_reg_dc_msb;
our $cop0_cause_reg_dc_lsb;
our $cop0_cause_reg_ce_sz;
our $cop0_cause_reg_ce_msb;
our $cop0_cause_reg_ce_lsb;
our $cop0_cause_reg_ti_sz;
our $cop0_cause_reg_ti_msb;
our $cop0_cause_reg_ti_lsb;
our $cop0_cause_reg_bd_sz;
our $cop0_cause_reg_bd_msb;
our $cop0_cause_reg_bd_lsb;
our $cop0_epc_reg_epc_sz;
our $cop0_epc_reg_epc_msb;
our $cop0_epc_reg_epc_lsb;
our $cop0_pr_id_reg_rev_sz;
our $cop0_pr_id_reg_rev_msb;
our $cop0_pr_id_reg_rev_lsb;
our $cop0_pr_id_reg_pid_sz;
our $cop0_pr_id_reg_pid_msb;
our $cop0_pr_id_reg_pid_lsb;
our $cop0_pr_id_reg_cid_sz;
our $cop0_pr_id_reg_cid_msb;
our $cop0_pr_id_reg_cid_lsb;
our $cop0_ebase_reg_cpu_num_sz;
our $cop0_ebase_reg_cpu_num_msb;
our $cop0_ebase_reg_cpu_num_lsb;
our $cop0_ebase_reg_exc_base_sz;
our $cop0_ebase_reg_exc_base_msb;
our $cop0_ebase_reg_exc_base_lsb;
our $cop0_ebase_reg_zero_sz;
our $cop0_ebase_reg_zero_msb;
our $cop0_ebase_reg_zero_lsb;
our $cop0_ebase_reg_one_sz;
our $cop0_ebase_reg_one_msb;
our $cop0_ebase_reg_one_lsb;
our $cop0_config_reg_k0_sz;
our $cop0_config_reg_k0_msb;
our $cop0_config_reg_k0_lsb;
our $cop0_config_reg_vi_sz;
our $cop0_config_reg_vi_msb;
our $cop0_config_reg_vi_lsb;
our $cop0_config_reg_mt_sz;
our $cop0_config_reg_mt_msb;
our $cop0_config_reg_mt_lsb;
our $cop0_config_reg_ar_sz;
our $cop0_config_reg_ar_msb;
our $cop0_config_reg_ar_lsb;
our $cop0_config_reg_at_sz;
our $cop0_config_reg_at_msb;
our $cop0_config_reg_at_lsb;
our $cop0_config_reg_be_sz;
our $cop0_config_reg_be_msb;
our $cop0_config_reg_be_lsb;
our $cop0_config_reg_ku_sz;
our $cop0_config_reg_ku_msb;
our $cop0_config_reg_ku_lsb;
our $cop0_config_reg_k23_sz;
our $cop0_config_reg_k23_msb;
our $cop0_config_reg_k23_lsb;
our $cop0_config_reg_m_sz;
our $cop0_config_reg_m_msb;
our $cop0_config_reg_m_lsb;
our $cop0_config_1_reg_fp_sz;
our $cop0_config_1_reg_fp_msb;
our $cop0_config_1_reg_fp_lsb;
our $cop0_config_1_reg_ep_sz;
our $cop0_config_1_reg_ep_msb;
our $cop0_config_1_reg_ep_lsb;
our $cop0_config_1_reg_ca_sz;
our $cop0_config_1_reg_ca_msb;
our $cop0_config_1_reg_ca_lsb;
our $cop0_config_1_reg_wr_sz;
our $cop0_config_1_reg_wr_msb;
our $cop0_config_1_reg_wr_lsb;
our $cop0_config_1_reg_pc_sz;
our $cop0_config_1_reg_pc_msb;
our $cop0_config_1_reg_pc_lsb;
our $cop0_config_1_reg_mdmx_sz;
our $cop0_config_1_reg_mdmx_msb;
our $cop0_config_1_reg_mdmx_lsb;
our $cop0_config_1_reg_c2_sz;
our $cop0_config_1_reg_c2_msb;
our $cop0_config_1_reg_c2_lsb;
our $cop0_config_1_reg_da_sz;
our $cop0_config_1_reg_da_msb;
our $cop0_config_1_reg_da_lsb;
our $cop0_config_1_reg_dl_sz;
our $cop0_config_1_reg_dl_msb;
our $cop0_config_1_reg_dl_lsb;
our $cop0_config_1_reg_ds_sz;
our $cop0_config_1_reg_ds_msb;
our $cop0_config_1_reg_ds_lsb;
our $cop0_config_1_reg_ia_sz;
our $cop0_config_1_reg_ia_msb;
our $cop0_config_1_reg_ia_lsb;
our $cop0_config_1_reg_il_sz;
our $cop0_config_1_reg_il_msb;
our $cop0_config_1_reg_il_lsb;
our $cop0_config_1_reg_is_sz;
our $cop0_config_1_reg_is_msb;
our $cop0_config_1_reg_is_lsb;
our $cop0_config_1_reg_ms_sz;
our $cop0_config_1_reg_ms_msb;
our $cop0_config_1_reg_ms_lsb;
our $cop0_config_1_reg_m_sz;
our $cop0_config_1_reg_m_msb;
our $cop0_config_1_reg_m_lsb;
our $cop0_config_2_reg_su_sz;
our $cop0_config_2_reg_su_msb;
our $cop0_config_2_reg_su_lsb;
our $cop0_config_2_reg_tu_sz;
our $cop0_config_2_reg_tu_msb;
our $cop0_config_2_reg_tu_lsb;
our $cop0_config_2_reg_m_sz;
our $cop0_config_2_reg_m_msb;
our $cop0_config_2_reg_m_lsb;
our $cop0_config_3_reg_tl_sz;
our $cop0_config_3_reg_tl_msb;
our $cop0_config_3_reg_tl_lsb;
our $cop0_config_3_reg_sm_sz;
our $cop0_config_3_reg_sm_msb;
our $cop0_config_3_reg_sm_lsb;
our $cop0_config_3_reg_sp_sz;
our $cop0_config_3_reg_sp_msb;
our $cop0_config_3_reg_sp_lsb;
our $cop0_config_3_reg_vint_sz;
our $cop0_config_3_reg_vint_msb;
our $cop0_config_3_reg_vint_lsb;
our $cop0_config_3_reg_veic_sz;
our $cop0_config_3_reg_veic_msb;
our $cop0_config_3_reg_veic_lsb;
our $cop0_config_3_reg_m_sz;
our $cop0_config_3_reg_m_msb;
our $cop0_config_3_reg_m_lsb;
our $cop0_debug_reg_dss_sz;
our $cop0_debug_reg_dss_msb;
our $cop0_debug_reg_dss_lsb;
our $cop0_debug_reg_dbp_sz;
our $cop0_debug_reg_dbp_msb;
our $cop0_debug_reg_dbp_lsb;
our $cop0_debug_reg_ddbl_sz;
our $cop0_debug_reg_ddbl_msb;
our $cop0_debug_reg_ddbl_lsb;
our $cop0_debug_reg_ddbs_sz;
our $cop0_debug_reg_ddbs_msb;
our $cop0_debug_reg_ddbs_lsb;
our $cop0_debug_reg_dib_sz;
our $cop0_debug_reg_dib_msb;
our $cop0_debug_reg_dib_lsb;
our $cop0_debug_reg_dint_sz;
our $cop0_debug_reg_dint_msb;
our $cop0_debug_reg_dint_lsb;
our $cop0_debug_reg_dib_sz;
our $cop0_debug_reg_dib_msb;
our $cop0_debug_reg_dib_lsb;
our $cop0_debug_reg_offline_sz;
our $cop0_debug_reg_offline_msb;
our $cop0_debug_reg_offline_lsb;
our $cop0_debug_reg_sst_sz;
our $cop0_debug_reg_sst_msb;
our $cop0_debug_reg_sst_lsb;
our $cop0_debug_reg_no_sst_sz;
our $cop0_debug_reg_no_sst_msb;
our $cop0_debug_reg_no_sst_lsb;
our $cop0_debug_reg_dexc_code_sz;
our $cop0_debug_reg_dexc_code_msb;
our $cop0_debug_reg_dexc_code_lsb;
our $cop0_debug_reg_ejtag_ver_sz;
our $cop0_debug_reg_ejtag_ver_msb;
our $cop0_debug_reg_ejtag_ver_lsb;
our $cop0_debug_reg_ddbl_impr_sz;
our $cop0_debug_reg_ddbl_impr_msb;
our $cop0_debug_reg_ddbl_impr_lsb;
our $cop0_debug_reg_ddbs_impr_sz;
our $cop0_debug_reg_ddbs_impr_msb;
our $cop0_debug_reg_ddbs_impr_lsb;
our $cop0_debug_reg_iexi_sz;
our $cop0_debug_reg_iexi_msb;
our $cop0_debug_reg_iexi_lsb;
our $cop0_debug_reg_dbus_ep_sz;
our $cop0_debug_reg_dbus_ep_msb;
our $cop0_debug_reg_dbus_ep_lsb;
our $cop0_debug_reg_cache_ep_sz;
our $cop0_debug_reg_cache_ep_msb;
our $cop0_debug_reg_cache_ep_lsb;
our $cop0_debug_reg_mcheck_pend_sz;
our $cop0_debug_reg_mcheck_pend_msb;
our $cop0_debug_reg_mcheck_pend_lsb;
our $cop0_debug_reg_ibus_err_pend_sz;
our $cop0_debug_reg_ibus_err_pend_msb;
our $cop0_debug_reg_ibus_err_pend_lsb;
our $cop0_debug_reg_count_dm_sz;
our $cop0_debug_reg_count_dm_msb;
our $cop0_debug_reg_count_dm_lsb;
our $cop0_debug_reg_halt_sz;
our $cop0_debug_reg_halt_msb;
our $cop0_debug_reg_halt_lsb;
our $cop0_debug_reg_doze_sz;
our $cop0_debug_reg_doze_msb;
our $cop0_debug_reg_doze_lsb;
our $cop0_debug_reg_lsnm_sz;
our $cop0_debug_reg_lsnm_msb;
our $cop0_debug_reg_lsnm_lsb;
our $cop0_debug_reg_no_dcr_sz;
our $cop0_debug_reg_no_dcr_msb;
our $cop0_debug_reg_no_dcr_lsb;
our $cop0_debug_reg_dm_sz;
our $cop0_debug_reg_dm_msb;
our $cop0_debug_reg_dm_lsb;
our $cop0_debug_reg_dbd_sz;
our $cop0_debug_reg_dbd_msb;
our $cop0_debug_reg_dbd_lsb;
our $cop0_depc_reg_depc_sz;
our $cop0_depc_reg_depc_msb;
our $cop0_depc_reg_depc_lsb;
our $cop0_tag_lo_0_reg_d_sz;
our $cop0_tag_lo_0_reg_d_msb;
our $cop0_tag_lo_0_reg_d_lsb;
our $cop0_tag_lo_0_reg_v_sz;
our $cop0_tag_lo_0_reg_v_msb;
our $cop0_tag_lo_0_reg_v_lsb;
our $cop0_tag_lo_0_reg_pa_sz;
our $cop0_tag_lo_0_reg_pa_msb;
our $cop0_tag_lo_0_reg_pa_lsb;
our $cop0_error_epc_reg_error_epc_sz;
our $cop0_error_epc_reg_error_epc_msb;
our $cop0_error_epc_reg_error_epc_lsb;
our $cop0_de_save_reg_de_save_sz;
our $cop0_de_save_reg_de_save_msb;
our $cop0_de_save_reg_de_save_lsb;


our $coherency_uncached;
our $coherency_cached;
our $boot_exception_vector_normal;
our $boot_exception_vector_bootstrap;
our $vector_spacing_0_bytes;
our $vector_spacing_32_bytes;
our $vector_spacing_64_bytes;
our $vector_spacing_128_bytes;
our $vector_spacing_256_bytes;
our $vector_spacing_512_bytes;
our $interrupt_num_hw0;
our $interrupt_num_hw1;
our $interrupt_num_hw2;
our $interrupt_num_hw3;
our $interrupt_num_hw4;
our $interrupt_num_hw5;
our $nevada_revision;
our $nevada_processor_id;
our $altera_company_id;
our $mmu_type_none;
our $mmu_type_standard_tlb;
our $mmu_type_bat_tlb;
our $mmu_type_fmt_tlb;
our $arch_revision_mips32_release1;
our $arch_revision_mips32_release2;
our $arch_type_mips32;
our $arch_type_mips64_only_32bit_segments;
our $arch_type_mips64_all_segments;
our $cache_assoc_direct_mapped;
our $cache_assoc_2_way;
our $cache_assoc_3_way;
our $cache_assoc_4_way;
our $cache_assoc_5_way;
our $cache_assoc_6_way;
our $cache_assoc_7_way;
our $cache_assoc_8_way;
our $cache_0_byte_lines;
our $cache_4_byte_lines;
our $cache_8_byte_lines;
our $cache_16_byte_lines;
our $cache_32_byte_lines;
our $cache_64_byte_lines;
our $cache_128_byte_lines;
our $cache_64_sets_per_way;
our $cache_128_sets_per_way;
our $cache_256_sets_per_way;
our $cache_512_sets_per_way;
our $cache_1024_sets_per_way;
our $cache_2048_sets_per_way;
our $cache_4096_sets_per_way;
our $ejtag_version_1_and_2_0;
our $ejtag_version_2_5;
our $ejtag_version_2_6;
our $ejtag_version_3_1;







sub
create_control_reg_args_from_infos
{
    my $nevada_isa_info = shift;
    my $interrupt_info = shift;
    my $misc_info = shift;
    my $mmu_info = shift;
    my $dcache_info = shift;
    my $icache_info = shift;
    my $test_info = shift;
    my $elaborated_test_info = shift;
    my $elaborated_avalon_master_info = shift;

    my $local_mmu_present = manditory_bool($mmu_info, "mmu_present");
    my $local_tlb_present = $local_mmu_present ? 
      manditory_bool($mmu_info, "tlb_present") : 
      undef;

    my $control_reg_args = {
      interrupt_sz => 
        manditory_int(
          manditory_hash($nevada_isa_info, "isa_constants"), "interrupt_sz"),

      timer_ip_num => manditory_int($interrupt_info, "timer_ip_num"),
      eic_present => manditory_bool($interrupt_info, "eic_present"),

      soft_reset_present => manditory_bool($misc_info, "soft_reset_present"),
      nmi_present => manditory_bool($misc_info, "nmi_present"),
      big_endian => manditory_bool($misc_info, "big_endian"),
      debug_port_present => manditory_bool($misc_info, "debug_port_present"),
      ebase_cpu_num => manditory_int($misc_info, "ebase_cpu_num"),
      num_shadow_reg_sets => manditory_int($misc_info, "num_shadow_reg_sets"),

      mmu_present => $local_mmu_present,
        tlb_present => $local_tlb_present,
        tlb_num_entries => ($local_tlb_present ? 
                        manditory_int($mmu_info, "tlb_num_entries") : 
                        undef),
        tlb_ptr_sz => ($local_tlb_present ? 
                        count2sz(manditory_int($mmu_info, "tlb_num_entries")) :
                        undef),

      cache_dcache_size => 
        manditory_int($dcache_info, "cache_dcache_size"),
      cache_dcache_line_size => 
        manditory_int($dcache_info, "cache_dcache_line_size"),
      cache_icache_size => 
        manditory_int($icache_info, "cache_icache_size"),
      cache_icache_line_size => 
        manditory_int($icache_info, "cache_icache_line_size"),

      sim_reg_present => 
        manditory_bool($elaborated_test_info, "sim_reg_present"),
      activate_test_end_checker => 
        manditory_bool($test_info, "activate_test_end_checker"),
      perf_cnt_present => 
        manditory_bool($elaborated_test_info, "perf_cnt_present"),
      sim_reg_c_model_fields_present => 
        manditory_bool($elaborated_test_info, "sim_reg_c_model_fields_present"),

      max_address_width => 
        manditory_int($elaborated_avalon_master_info, "Max_Address_Width"),
      pcb_sz => 
        manditory_int($elaborated_avalon_master_info, "pcb_sz"),
      mem_baddr_sz => 
        manditory_int($elaborated_avalon_master_info, "mem_baddr_sz"),
    };

    return $control_reg_args;
}




sub
create_control_reg_args_default_configuration
{
    my $control_reg_args = {
      interrupt_sz => 32,

      timer_ip_num => 7,
      eic_present => 0,             # Not yet supported

      soft_reset_present => 0,      # Not yet supported
      nmi_present => 0,             # Not yet supported
      big_endian => 1,
      debug_port_present => 1,
      ebase_cpu_num => 0,
      num_shadow_reg_sets => 0,     # Not yet supported

      mmu_present => 1,
        tlb_present => 1,           # Not FMT
        tlb_num_entries => 64,      # Max possible
        tlb_ptr_sz => 6,

      cache_dcache_size => (16*1024),
      cache_dcache_line_size => 32,

      cache_icache_size => (16*1024),
      cache_icache_line_size => 32,

      sim_reg_present => 1,
      activate_test_end_checker => 1,
      perf_cnt_present => 1,
      sim_reg_c_model_fields_present => 1,
      
      max_address_width => 32,
      pcb_sz => 32,
      mem_baddr_sz => 32,
    };

    return $control_reg_args;
}




sub
validate_and_elaborate
{
    my $control_reg_args = shift; # Hash reference containing all args

    my $constants = create_control_reg_constants();

    my ($all_control_regs, $control_regs, 
      $skip_control_reg_when_creating_global_field_scalars) =
        create_control_regs($control_reg_args, $constants);


    my $control_reg_info = {
      control_reg_constants => $constants,
      all_control_regs      => $all_control_regs,
      control_regs          => $control_regs,
    };



    foreach my $var (keys(%$constants)) {
        eval_cmd('$' . $var . ' = "' . $constants->{$var} . '"');
    }


    foreach my $control_reg (@$control_regs) {






        foreach my $cmd (@{get_control_reg_into_scalars($control_regs,
          $control_reg)}) {
            eval_cmd($cmd);
        }


        my $skip = 0;
        foreach my $skip_control_reg 
          (@$skip_control_reg_when_creating_global_field_scalars) {
            if ($control_reg == $skip_control_reg) {
                $skip = 1;
            }
        }

        if ($skip) {
            next;
        }






        foreach my $field (@{get_control_reg_fields($control_reg)}) {
            foreach my $cmd (@{get_control_reg_field_into_scalars($field)}) {
                eval_cmd($cmd);
            }
        }
    }

    return $control_reg_info;
}


sub
convert_to_c
{
    my $control_reg_info = shift;
    my $c_lines = shift;        # Reference to array of lines for *.c file
    my $h_lines = shift;        # Reference to array of lines for *.h file

    my $all_control_regs = 
      manditory_array($control_reg_info, "all_control_regs");
    if (!defined($all_control_regs)) {
        return undef;
    }

    push(@$h_lines, "");
    push(@$h_lines, "/*");
    push(@$h_lines, " * Control register macros");
    push(@$h_lines, " */");

    foreach my $control_reg (@$all_control_regs) {
        if (!defined(
          convert_control_reg_to_c($control_reg, $c_lines, $h_lines))) {
            return undef;
        }
    }

    push(@$h_lines, "");
    push(@$h_lines, "/* Control register field values */");
    return format_hash_as_c_macros($control_reg_info->{control_reg_constants},
      $h_lines, "MIPS32_");

    return 1;   # Some defined value
}





sub
create_control_reg_constants
{
    my $mmu_args = shift;

    my %constants;


    $constants{coherency_uncached} = 2;
    $constants{coherency_cached} = 3;


    $constants{boot_exception_vector_normal} = 0;
    $constants{boot_exception_vector_bootstrap} = 1;


    $constants{vector_spacing_0_bytes} = 0;
    $constants{vector_spacing_32_bytes} = 1;
    $constants{vector_spacing_64_bytes} = 2;
    $constants{vector_spacing_128_bytes} = 4;
    $constants{vector_spacing_256_bytes} = 8;
    $constants{vector_spacing_512_bytes} = 16;



    $constants{interrupt_num_hw0} = 2;
    $constants{interrupt_num_hw1} = 3;
    $constants{interrupt_num_hw2} = 4;
    $constants{interrupt_num_hw3} = 5;
    $constants{interrupt_num_hw4} = 6;
    $constants{interrupt_num_hw5} = 7;


    $constants{nevada_revision} = 0;
    $constants{nevada_processor_id} = 0;
    $constants{altera_company_id} = 16;


    $constants{mmu_type_none} = 0;
    $constants{mmu_type_standard_tlb} = 1;
    $constants{mmu_type_bat_tlb} = 2;
    $constants{mmu_type_fmt_tlb} = 3;


    $constants{arch_revision_mips32_release1} = 0;
    $constants{arch_revision_mips32_release2} = 1;


    $constants{arch_type_mips32} = 0;
    $constants{arch_type_mips64_only_32bit_segments} = 1;
    $constants{arch_type_mips64_all_segments} = 2;



    $constants{cache_assoc_direct_mapped} = 0;
    $constants{cache_assoc_2_way} = 1;
    $constants{cache_assoc_3_way} = 2;
    $constants{cache_assoc_4_way} = 3;
    $constants{cache_assoc_5_way} = 4;
    $constants{cache_assoc_6_way} = 5;
    $constants{cache_assoc_7_way} = 6;
    $constants{cache_assoc_8_way} = 7;



    $constants{cache_0_byte_lines} = 0;
    $constants{cache_4_byte_lines} = 1;
    $constants{cache_8_byte_lines} = 2;
    $constants{cache_16_byte_lines} = 3;
    $constants{cache_32_byte_lines} = 4;
    $constants{cache_64_byte_lines} = 5;
    $constants{cache_128_byte_lines} = 6;



    $constants{cache_64_sets_per_way} = 0;
    $constants{cache_128_sets_per_way} = 1;
    $constants{cache_256_sets_per_way} = 2;
    $constants{cache_512_sets_per_way} = 3;
    $constants{cache_1024_sets_per_way} = 4;
    $constants{cache_2048_sets_per_way} = 5;
    $constants{cache_4096_sets_per_way} = 6;


    $constants{ejtag_version_1_and_2_0} = 0;
    $constants{ejtag_version_2_5} = 1;
    $constants{ejtag_version_2_6} = 2;
    $constants{ejtag_version_3_1} = 3;

    return \%constants;
}

sub
create_control_regs
{
    my $args = shift;       # Hash ref containing all required arguments
    my $constants = shift;  # Hash ref containing all control reg constants 

    my $max_address_width = manditory_int($args, "max_address_width");
    my $pcb_sz = manditory_int($args, "pcb_sz");
    my $mem_baddr_sz = manditory_int($args, "mem_baddr_sz");
    my $soft_reset_present = manditory_bool($args, "soft_reset_present");
    my $nmi_present = manditory_bool($args, "nmi_present");
    my $big_endian = manditory_bool($args, "big_endian");
    my $debug_port_present = manditory_bool($args, "debug_port_present");
    my $ebase_cpu_num = manditory_int($args, "ebase_cpu_num");
    my $timer_ip_num = manditory_int($args, "timer_ip_num");
    my $eic_present = manditory_bool($args, "eic_present");
    my $mmu_present = manditory_bool($args, "mmu_present");
    my $tlb_present = 
      $mmu_present ? manditory_bool($args, "tlb_present") : undef;
    my $cache_dcache_size = manditory_int($args, "cache_dcache_size");
    my $cache_dcache_line_size = manditory_int($args, "cache_dcache_line_size");
    my $cache_icache_size = manditory_int($args, "cache_icache_size");
    my $cache_icache_line_size = manditory_int($args, "cache_icache_line_size");
    my $sim_reg_present = manditory_bool($args, "sim_reg_present");
    my $num_shadow_reg_sets = manditory_int($args, "num_shadow_reg_sets");

    my $tlb_num_entries;
    my $tlb_ptr_sz;

    if ($tlb_present) {
        $tlb_num_entries = manditory_int($args, "tlb_num_entries");
        if (($tlb_num_entries < 3) || ($tlb_num_entries > 64)) {
            &$error("tlb_num_entries of '$tlb_num_entries' out of range");
        }
        $tlb_ptr_sz = manditory_int($args, "tlb_ptr_sz");
        if (($tlb_ptr_sz < 1) || ($tlb_ptr_sz > 6)) {
            &$error("tlb_ptr_sz of '$tlb_ptr_sz' out of range");
        }
    }

    my $all_control_regs = [];      # Every possible control reg
    my $control_regs = [];          # Only present control regs
    my @skip_control_reg_when_creating_global_field_scalars;

    my $always_present = 1;




    $cop0_index_reg = add_control_reg($all_control_regs, $control_regs,
      $tlb_present, { name => "cop0_index", num => 0, select => 0 });
    $cop0_random_reg = add_control_reg($all_control_regs, $control_regs, 
      $tlb_present, { name => "cop0_random", num => 1, select => 0 });
    $cop0_entry_lo_0_reg = add_control_reg($all_control_regs, $control_regs, 
      $tlb_present, { name => "cop0_entry_lo_0", num => 2, select => 0 });
    $cop0_entry_lo_1_reg = add_control_reg($all_control_regs, $control_regs, 
      $tlb_present, { name => "cop0_entry_lo_1", num => 3, select => 0 });
    $cop0_context_reg = add_control_reg($all_control_regs, $control_regs, 
      $tlb_present, { name => "cop0_context", num => 4, select => 0 });
    $cop0_page_mask_reg = add_control_reg($all_control_regs, $control_regs, 
      $tlb_present, { name => "cop0_page_mask", num => 5, select => 0 });
    $cop0_wired_reg = add_control_reg($all_control_regs, $control_regs, 
      $tlb_present, { name => "cop0_wired", num => 6, select => 0 });
    $cop0_hwr_ena_reg = add_control_reg($all_control_regs, $control_regs, 
      $always_present, { name => "cop0_hwr_ena", num => 7, select => 0 });
    $cop0_bad_vaddr_reg = add_control_reg($all_control_regs, $control_regs, 
      $always_present, { name => "cop0_bad_vaddr", num => 8, select => 0 });
    $cop0_count_reg = add_control_reg($all_control_regs, $control_regs, 
      $always_present, { name => "cop0_count", num => 9, select => 0 });
    $cop0_entry_hi_reg = add_control_reg($all_control_regs, $control_regs, 
      $tlb_present, { name => "cop0_entry_hi", num => 10, select => 0 });
    $cop0_compare_reg = add_control_reg($all_control_regs, $control_regs, 
      $always_present, { name => "cop0_compare", num => 11, select => 0 });
    $cop0_status_reg = add_control_reg($all_control_regs, $control_regs, 
      $always_present, { name => "cop0_status", num => 12, select => 0 });
    $cop0_int_ctl_reg = add_control_reg($all_control_regs, $control_regs, 
      $always_present, { name => "cop0_int_ctl", num => 12, select => 1 });
    $cop0_srs_ctl_reg = add_control_reg($all_control_regs, $control_regs, 
      $always_present, { name => "cop0_srs_ctl", num => 12, select => 2 });
    $cop0_cause_reg = add_control_reg($all_control_regs, $control_regs, 
      $always_present, { name => "cop0_cause", num => 13, select => 0 });
    $cop0_epc_reg = add_control_reg($all_control_regs, $control_regs, 
      $always_present, { name => "cop0_epc", num => 14, select => 0 });
    $cop0_pr_id_reg = add_control_reg($all_control_regs, $control_regs, 
      $always_present, { name => "cop0_pr_id", num => 15, select => 0 });
    $cop0_ebase_reg = add_control_reg($all_control_regs, $control_regs, 
      $always_present, { name => "cop0_ebase", num => 15, select => 1 });
    $cop0_config_reg = add_control_reg($all_control_regs, $control_regs, 
      $always_present, { name => "cop0_config", num => 16, select => 0 });
    $cop0_config_1_reg = add_control_reg($all_control_regs, $control_regs, 
      $always_present, { name => "cop0_config_1", num => 16, select => 1 });
    $cop0_config_2_reg = add_control_reg($all_control_regs, $control_regs, 
      $always_present, { name => "cop0_config_2", num => 16, select => 2 });
    $cop0_config_3_reg = add_control_reg($all_control_regs, $control_regs, 
      $always_present, { name => "cop0_config_3", num => 16, select => 3 });
    $cop0_debug_reg = add_control_reg($all_control_regs, $control_regs, 
      $debug_port_present, { name => "cop0_debug", num => 23, select => 0 });
    $cop0_depc_reg = add_control_reg($all_control_regs, $control_regs, 
      $debug_port_present, { name => "cop0_depc", num => 24, select => 0 });
    $cop0_tag_lo_0_reg = add_control_reg($all_control_regs, $control_regs, 
      $always_present, { name => "cop0_tag_lo_0", num => 28, select => 0 });
    $cop0_tag_lo_2_reg = add_control_reg($all_control_regs, $control_regs, 
      $always_present, { name => "cop0_tag_lo_2", num => 28, select => 2 });
    $cop0_tag_hi_0_reg = add_control_reg($all_control_regs, $control_regs, 
      $always_present, { name => "cop0_tag_hi_0", num => 29, select => 0 });
    $cop0_tag_hi_2_reg = add_control_reg($all_control_regs, $control_regs, 
      $always_present, { name => "cop0_tag_hi_2", num => 29, select => 2 });
    $cop0_error_epc_reg = add_control_reg($all_control_regs, $control_regs, 
      $always_present, { name => "cop0_error_epc", num => 30, select => 0 });
    $cop0_de_save_reg = add_control_reg($all_control_regs, $control_regs, 
      $debug_port_present, { name => "cop0_de_save", num => 31, select => 0 });

    if ($tlb_present) {



        $cop0_index_reg_index = add_control_reg_field($cop0_index_reg, 
          { name => "index", lsb => 0, sz => $tlb_ptr_sz });
        $cop0_index_reg_p = add_control_reg_field($cop0_index_reg, 
          { name => "p", lsb => 31, sz => 1, mode => $MODE_READ_ONLY });
    



        $cop0_random_reg_random = add_control_reg_field($cop0_random_reg, 
          { name => "random", lsb => 0, sz => $tlb_ptr_sz, 
            mode => $MODE_READ_ONLY, reset_value => ($tlb_num_entries-1) });
    



        my $pfn_sz = $max_address_width - 12;
        my $entry_lo_g_props = { name => "g", lsb => 0, sz => 1 };
        my $entry_lo_v_props = { name => "v", lsb => 1, sz => 1 };
        my $entry_lo_d_props = { name => "d", lsb => 2, sz => 1 };
        my $entry_lo_c_props = { name => "c", lsb => 3, sz => 3 };
        my $entry_lo_pfn_props = { name => "pfn", lsb => 6, sz => $pfn_sz };
        my $entry_lo_fill_props = 
          { name => "fill", lsb => (6+$pfn_sz), sz => (32-6-$pfn_sz),
            mode => $MODE_IGNORED };




        $cop0_entry_lo_0_reg_g = add_control_reg_field($cop0_entry_lo_0_reg, 
          $entry_lo_g_props);
        $cop0_entry_lo_0_reg_v = add_control_reg_field($cop0_entry_lo_0_reg, 
          $entry_lo_v_props);
        $cop0_entry_lo_0_reg_d = add_control_reg_field($cop0_entry_lo_0_reg, 
          $entry_lo_d_props);
        $cop0_entry_lo_0_reg_c = add_control_reg_field($cop0_entry_lo_0_reg, 
          $entry_lo_c_props);
        $cop0_entry_lo_0_reg_pfn = add_control_reg_field($cop0_entry_lo_0_reg, 
          $entry_lo_pfn_props);
        $cop0_entry_lo_0_reg_fill = add_control_reg_field($cop0_entry_lo_0_reg, 
          $entry_lo_fill_props);
    



        $cop0_entry_lo_1_reg_g = add_control_reg_field($cop0_entry_lo_1_reg, 
          $entry_lo_g_props);
        $cop0_entry_lo_1_reg_v = add_control_reg_field($cop0_entry_lo_1_reg, 
          $entry_lo_v_props);
        $cop0_entry_lo_1_reg_d = add_control_reg_field($cop0_entry_lo_1_reg, 
          $entry_lo_d_props);
        $cop0_entry_lo_1_reg_c = add_control_reg_field($cop0_entry_lo_1_reg, 
          $entry_lo_c_props);
        $cop0_entry_lo_1_reg_pfn = add_control_reg_field($cop0_entry_lo_1_reg, 
          $entry_lo_pfn_props);
        $cop0_entry_lo_1_reg_fill = add_control_reg_field($cop0_entry_lo_1_reg, 
          $entry_lo_fill_props);
    



        $cop0_context_reg_bad_vpn2 = add_control_reg_field($cop0_context_reg, 
          { name => "bad_vpn2", lsb => 4, sz => 19, mode => $MODE_READ_ONLY });
        $cop0_context_reg_pte_base = add_control_reg_field($cop0_context_reg, 
          { name => "pte_base", lsb => 23, sz => 9 });
    



        $cop0_page_mask_reg_mask = add_control_reg_field($cop0_page_mask_reg, 
          { name => "mask", lsb => 13, sz => 16 });
    



        $cop0_wired_reg_wired = add_control_reg_field($cop0_wired_reg, 
          { name => "wired", lsb => 0, sz => $tlb_ptr_sz });
    }




    $cop0_hwr_ena_reg_cpu_num = add_control_reg_field($cop0_hwr_ena_reg, 
      { name => "cpu_num", lsb => 0, sz => 1 });
    $cop0_hwr_ena_reg_synci_step = add_control_reg_field($cop0_hwr_ena_reg, 
      { name => "synci_step", lsb => 1, sz => 1 });
    $cop0_hwr_ena_reg_cc = add_control_reg_field($cop0_hwr_ena_reg, 
      { name => "cc", lsb => 2, sz => 1 });
    $cop0_hwr_ena_reg_cc_res = add_control_reg_field($cop0_hwr_ena_reg, 
      { name => "cc_res", lsb => 3, sz => 1 });
    $cop0_hwr_ena_reg_ignored = add_control_reg_field($cop0_hwr_ena_reg, 
      { name => "ignored", lsb => 4, sz => 28, mode => $MODE_IGNORED });




    $cop0_bad_vaddr_reg_bad_vaddr = add_control_reg_field($cop0_bad_vaddr_reg, 
      { name => "bad_vaddr", lsb => 0, sz => 32, mode => $MODE_READ_ONLY });




    $cop0_count_reg_count = add_control_reg_field($cop0_count_reg, 
      { name => "count", lsb => 0, sz => 32 });

    if ($tlb_present) {



        $cop0_entry_hi_reg_asid = add_control_reg_field($cop0_entry_hi_reg, 
          { name => "asid", lsb => 0, sz => 8 });
        $cop0_entry_hi_reg_vpn2 = add_control_reg_field($cop0_entry_hi_reg, 
          { name => "vpn2", lsb => 13, sz => 19 });
    }




    $cop0_compare_reg_compare = add_control_reg_field($cop0_compare_reg, 
      { name => "compare", lsb => 0, sz => 32 });




    $cop0_status_reg_ie = add_control_reg_field($cop0_status_reg, 
      { name => "ie", lsb => 0, sz => 1 });
    $cop0_status_reg_exl = add_control_reg_field($cop0_status_reg, 
      { name => "exl", lsb => 1, sz => 1 });
    $cop0_status_reg_erl = add_control_reg_field($cop0_status_reg, 
      { name => "erl", lsb => 2, sz => 1, reset_value => 1 });
    $cop0_status_reg_r0 = add_control_reg_field($cop0_status_reg, 
      { name => "r0", lsb => 3, sz => 1,
        mode => $MODE_CONSTANT, constant_value => 0 }); 
    $cop0_status_reg_um = add_control_reg_field($cop0_status_reg, 
      { name => "um", lsb => 4, sz => 1 });
    $cop0_status_reg_ux = add_control_reg_field($cop0_status_reg, 
      { name => "ux", lsb => 5, sz => 1,
        mode => $MODE_CONSTANT, constant_value => 0 }); 
    $cop0_status_reg_sx = add_control_reg_field($cop0_status_reg, 
      { name => "sx", lsb => 6, sz => 1,
        mode => $MODE_CONSTANT, constant_value => 0 }); 
    $cop0_status_reg_kx = add_control_reg_field($cop0_status_reg, 
      { name => "kx", lsb => 7, sz => 1,
        mode => $MODE_CONSTANT, constant_value => 0 }); 
    $cop0_status_reg_im_0 = add_control_reg_field($cop0_status_reg, 
      { name => "im_0", lsb => 8, sz => 1 }); 
    $cop0_status_reg_im_1 = add_control_reg_field($cop0_status_reg, 
      { name => "im_1", lsb => 9, sz => 1 }); 
    $cop0_status_reg_im_7_2 = add_control_reg_field($cop0_status_reg, 
      { name => "im_7_2", lsb => 10, sz => 6 }); 
    $cop0_status_reg_impl = add_control_reg_field($cop0_status_reg, 
      { name => "impl", lsb => 16, sz => 2,
        mode => $MODE_CONSTANT, constant_value => 0 }); 
    if ($nmi_present) {
        $cop0_status_reg_nmi = add_control_reg_field($cop0_status_reg, 
          { name => "nmi", lsb => 19, sz => 1 }); 
    } else {
        $cop0_status_reg_nmi = add_control_reg_field($cop0_status_reg, 
          { name => "nmi", lsb => 19, sz => 1,
            mode => $MODE_CONSTANT, constant_value => 0 }); 
    }
    if ($soft_reset_present) {
        $cop0_status_reg_sr = add_control_reg_field($cop0_status_reg, 
          { name => "sr", lsb => 20, sz => 1 }); 
    } else {
        $cop0_status_reg_sr = add_control_reg_field($cop0_status_reg, 
          { name => "sr", lsb => 20, sz => 1,
            mode => $MODE_CONSTANT, constant_value => 0 }); 
    }
    $cop0_status_reg_ts = add_control_reg_field($cop0_status_reg, 
      { name => "ts", lsb => 21, sz => 1,
        mode => $MODE_CONSTANT, constant_value => 0 }); 
    $cop0_status_reg_bev = add_control_reg_field($cop0_status_reg, 
      { name => "bev", lsb => 22, sz => 1, reset_value => 
          manditory_int($constants, "boot_exception_vector_bootstrap") });
    $cop0_status_reg_px = add_control_reg_field($cop0_status_reg, 
      { name => "px", lsb => 23, sz => 1,
        mode => $MODE_CONSTANT, constant_value => 0 }); 
    $cop0_status_reg_mx = add_control_reg_field($cop0_status_reg, 
      { name => "mx", lsb => 24, sz => 1,
        mode => $MODE_CONSTANT, constant_value => 0 }); 
    $cop0_status_reg_re = add_control_reg_field($cop0_status_reg, 
      { name => "re", lsb => 25, sz => 1,
        mode => $MODE_CONSTANT, constant_value => 0 }); 
    $cop0_status_reg_fr = add_control_reg_field($cop0_status_reg, 
      { name => "fr", lsb => 26, sz => 1,
        mode => $MODE_CONSTANT, constant_value => 0 }); 
    $cop0_status_reg_rp = add_control_reg_field($cop0_status_reg, 
      { name => "rp", lsb => 27, sz => 1,
        mode => $MODE_CONSTANT, constant_value => 0 }); 
    $cop0_status_reg_cu0 = add_control_reg_field($cop0_status_reg, 
      { name => "cu0", lsb => 28, sz => 1 }); 
    $cop0_status_reg_cu1 = add_control_reg_field($cop0_status_reg, 
      { name => "cu1", lsb => 29, sz => 1,
        mode => $MODE_CONSTANT, constant_value => 0 }); 
    $cop0_status_reg_cu2 = add_control_reg_field($cop0_status_reg, 
      { name => "cu2", lsb => 30, sz => 1,
        mode => $MODE_CONSTANT, constant_value => 0 }); 
    $cop0_status_reg_cu3 = add_control_reg_field($cop0_status_reg, 
      { name => "cu3", lsb => 31, sz => 1,
        mode => $MODE_CONSTANT, constant_value => 0 }); 




    if ($eic_present) {
        $cop0_int_ctl_reg_vs = add_control_reg_field($cop0_int_ctl_reg, 
          { name => "vs", lsb => 5, sz => 5 }); 
    } else {
        $cop0_int_ctl_reg_vs = add_control_reg_field($cop0_int_ctl_reg, 
          { name => "vs", lsb => 5, sz => 5,
            mode => $MODE_CONSTANT, constant_value => 0 });
    }
    $cop0_int_ctl_reg_ippci = add_control_reg_field($cop0_int_ctl_reg, 
      { name => "ippci", lsb => 26, sz => 3,
        mode => $MODE_CONSTANT, constant_value => 0 });
    $cop0_int_ctl_reg_ipti = add_control_reg_field($cop0_int_ctl_reg, 
      { name => "ipti", lsb => 29, sz => 3,
        mode => $MODE_CONSTANT, constant_value => $timer_ip_num });




    $cop0_srs_ctl_reg_css = add_control_reg_field($cop0_srs_ctl_reg, 
      { name => "css", lsb => 0, sz => 4,
        mode => $MODE_CONSTANT, constant_value => 0 });
    $cop0_srs_ctl_reg_pss = add_control_reg_field($cop0_srs_ctl_reg, 
      { name => "pss", lsb => 6, sz => 4,
        mode => $MODE_CONSTANT, constant_value => 0 });
    $cop0_srs_ctl_reg_ess = add_control_reg_field($cop0_srs_ctl_reg, 
      { name => "ess", lsb => 12, sz => 4,
        mode => $MODE_CONSTANT, constant_value => 0 });
    $cop0_srs_ctl_reg_eicss = add_control_reg_field($cop0_srs_ctl_reg, 
      { name => "eicss", lsb => 18, sz => 4,
        mode => $MODE_CONSTANT, constant_value => 0 });
    $cop0_srs_ctl_reg_hss = add_control_reg_field($cop0_srs_ctl_reg, 
      { name => "hss", lsb => 26, sz => 4,
        mode => $MODE_CONSTANT, constant_value => 0 });




    $cop0_cause_reg_exc_code = add_control_reg_field($cop0_cause_reg, 
      { name => "exc_code", lsb => 2, sz => 5, mode => $MODE_READ_ONLY });
    $cop0_cause_reg_ip_0 = add_control_reg_field($cop0_cause_reg, 
      { name => "ip_0", lsb => 8, sz => 1 });
    $cop0_cause_reg_ip_1 = add_control_reg_field($cop0_cause_reg, 
      { name => "ip_1", lsb => 9, sz => 1 });
    $cop0_cause_reg_ip_7_2 = add_control_reg_field($cop0_cause_reg, 
      { name => "ip_7_2", lsb => 10, sz => 6, mode => $MODE_READ_ONLY });
    $cop0_cause_reg_wp = add_control_reg_field($cop0_cause_reg, 
      { name => "wp", lsb => 22, sz => 1,
        mode => $MODE_CONSTANT, constant_value => 0 });
    $cop0_cause_reg_iv = add_control_reg_field($cop0_cause_reg, 
      { name => "iv", lsb => 23, sz => 1 });
    $cop0_cause_reg_pci = add_control_reg_field($cop0_cause_reg, 
      { name => "pci", lsb => 26, sz => 1, mode => $MODE_CONSTANT,
        constant_value => 0 });
    $cop0_cause_reg_dc = add_control_reg_field($cop0_cause_reg, 
      { name => "dc", lsb => 27, sz => 1 });
    $cop0_cause_reg_ce = add_control_reg_field($cop0_cause_reg, 
      { name => "ce", lsb => 28, sz => 2, mode => $MODE_READ_ONLY });
    $cop0_cause_reg_ti = add_control_reg_field($cop0_cause_reg, 
      { name => "ti", lsb => 30, sz => 1, mode => $MODE_READ_ONLY });
    $cop0_cause_reg_bd = add_control_reg_field($cop0_cause_reg, 
      { name => "bd", lsb => 31, sz => 1, mode => $MODE_READ_ONLY });




    $cop0_epc_reg_epc = add_control_reg_field($cop0_epc_reg, 
      { name => "epc", lsb => 0, sz => 32 });




    $cop0_pr_id_reg_rev = add_control_reg_field($cop0_pr_id_reg, 
      { name => "rev", lsb => 0, sz => 8,
        mode => $MODE_CONSTANT,
        constant_value => manditory_int($constants, "nevada_revision") });
    $cop0_pr_id_reg_pid = add_control_reg_field($cop0_pr_id_reg, 
      { name => "pid", lsb => 8, sz => 8,
        mode => $MODE_CONSTANT,
        constant_value => manditory_int($constants, "nevada_processor_id") });
    $cop0_pr_id_reg_cid = add_control_reg_field($cop0_pr_id_reg, 
      { name => "cid", lsb => 16, sz => 8,
        mode => $MODE_CONSTANT,
        constant_value => manditory_int($constants, "altera_company_id") });




    $cop0_ebase_reg_cpu_num = add_control_reg_field($cop0_ebase_reg, 
      { name => "cpu_num", lsb => 0, sz => 10,
        mode => $MODE_CONSTANT, constant_value => $ebase_cpu_num });
    $cop0_ebase_reg_exc_base = add_control_reg_field($cop0_ebase_reg, 
      { name => "exc_base", lsb => 12, sz => 18 });
    $cop0_ebase_reg_zero = add_control_reg_field($cop0_ebase_reg, 
      { name => "zero", lsb => 30, sz => 1,
        mode => $MODE_CONSTANT, constant_value => 0 });
    $cop0_ebase_reg_one = add_control_reg_field($cop0_ebase_reg, 
      { name => "one", lsb => 31, sz => 1,
        mode => $MODE_CONSTANT, constant_value => 1 });




    $cop0_config_reg_k0 = add_control_reg_field($cop0_config_reg, 
      { name => "k0", lsb => 0, sz => 3,
        reset_value => manditory_int($constants, "coherency_uncached") });
    $cop0_config_reg_vi = add_control_reg_field($cop0_config_reg, 
      { name => "vi", lsb => 3, sz => 1,
        mode => $MODE_CONSTANT, constant_value => 0 });
    $cop0_config_reg_mt = add_control_reg_field($cop0_config_reg, 
      { name => "mt", lsb => 7, sz => 3,
        mode => $MODE_CONSTANT,
        constant_value => manditory_int($constants, 
          ($mmu_present & $tlb_present)  ? "mmu_type_standard_tlb" : 
          ($mmu_present & !$tlb_present) ? "mmu_type_fmt_tlb" :
                                           "mmu_type_none") });
    $cop0_config_reg_ar = add_control_reg_field($cop0_config_reg, 
      { name => "ar", lsb => 10, sz => 3,
        mode => $MODE_CONSTANT,
        constant_value => manditory_int($constants, 
          "arch_revision_mips32_release2") });
    $cop0_config_reg_at = add_control_reg_field($cop0_config_reg, 
      { name => "at", lsb => 13, sz => 2,
        mode => $MODE_CONSTANT,
        constant_value => manditory_int($constants, "arch_type_mips32") });
    $cop0_config_reg_be = add_control_reg_field($cop0_config_reg, 
      { name => "be", lsb => 15, sz => 1,
        mode => $MODE_CONSTANT, constant_value => $big_endian });



    my %ku_k23_mode_flags =
      ($mmu_present && !$tlb_present) ? 
         () :
         ( mode => $MODE_CONSTANT, constant_value => 0 );

    $cop0_config_reg_ku = add_control_reg_field($cop0_config_reg, 
      { name => "ku", lsb => 25, sz => 3, %ku_k23_mode_flags });
    $cop0_config_reg_k23 = add_control_reg_field($cop0_config_reg, 
      { name => "k23", lsb => 28, sz => 3, %ku_k23_mode_flags });
    $cop0_config_reg_m = add_control_reg_field($cop0_config_reg, 
      { name => "m", lsb => 31, sz => 1,
        mode => $MODE_CONSTANT, constant_value => 1 });




    $cop0_config_1_reg_fp = add_control_reg_field($cop0_config_1_reg, 
      { name => "fp", lsb => 0, sz => 1,
        mode => $MODE_CONSTANT, constant_value => 0 });
    $cop0_config_1_reg_ep = add_control_reg_field($cop0_config_1_reg, 
      { name => "ep", lsb => 1, sz => 1,
        mode => $MODE_CONSTANT, constant_value => $debug_port_present });
    $cop0_config_1_reg_ca = add_control_reg_field($cop0_config_1_reg, 
      { name => "ca", lsb => 2, sz => 1,
        mode => $MODE_CONSTANT, constant_value => 0 });
    $cop0_config_1_reg_wr = add_control_reg_field($cop0_config_1_reg, 
      { name => "wr", lsb => 3, sz => 1,
        mode => $MODE_CONSTANT, constant_value => 0 });
    $cop0_config_1_reg_pc = add_control_reg_field($cop0_config_1_reg, 
      { name => "pc", lsb => 4, sz => 1,
        mode => $MODE_CONSTANT, constant_value => 0 });
    $cop0_config_1_reg_mdmx = add_control_reg_field($cop0_config_1_reg, 
      { name => "mdmx", lsb => 5, sz => 1,
        mode => $MODE_CONSTANT, constant_value => 0 });
    $cop0_config_1_reg_c2 = add_control_reg_field($cop0_config_1_reg, 
      { name => "c2", lsb => 6, sz => 1,
        mode => $MODE_CONSTANT, constant_value => 0 });
    $cop0_config_1_reg_da = add_control_reg_field($cop0_config_1_reg, 
      { name => "da", lsb => 7, sz => 3,
        mode => $MODE_CONSTANT, 
        constant_value => 
          manditory_int($constants, "cache_assoc_direct_mapped") });
    $cop0_config_1_reg_dl = add_control_reg_field($cop0_config_1_reg, 
      { name => "dl", lsb => 10, sz => 3,
        mode => $MODE_CONSTANT, 
        constant_value => 
          encode_cache_line_size($constants, $cache_dcache_line_size) });
    $cop0_config_1_reg_ds = add_control_reg_field($cop0_config_1_reg, 
      { name => "ds", lsb => 13, sz => 3,
        mode => $MODE_CONSTANT, 
        constant_value => encode_cache_sets_per_way($constants,
          $cache_dcache_size / $cache_dcache_line_size) });
    $cop0_config_1_reg_ia = add_control_reg_field($cop0_config_1_reg, 
      { name => "ia", lsb => 16, sz => 3,
        mode => $MODE_CONSTANT, 
        constant_value => 
          manditory_int($constants, "cache_assoc_direct_mapped") });
    $cop0_config_1_reg_il = add_control_reg_field($cop0_config_1_reg, 
      { name => "il", lsb => 19, sz => 3,
        mode => $MODE_CONSTANT, 
        constant_value => 
          encode_cache_line_size($constants, $cache_icache_line_size) });
    $cop0_config_1_reg_is = add_control_reg_field($cop0_config_1_reg, 
      { name => "is", lsb => 22, sz => 3,
        mode => $MODE_CONSTANT, 
        constant_value => encode_cache_sets_per_way($constants,
          $cache_icache_size / $cache_icache_line_size) });
    $cop0_config_1_reg_ms = add_control_reg_field($cop0_config_1_reg, 
      { name => "ms", lsb => 25, sz => 6,
        mode => $MODE_CONSTANT, 
        constant_value => $tlb_present ? ($tlb_num_entries-1) : 0 });
    $cop0_config_1_reg_m = add_control_reg_field($cop0_config_1_reg, 
      { name => "m", lsb => 31, sz => 1,
        mode => $MODE_CONSTANT, constant_value => 1 });




    $cop0_config_2_reg_su = add_control_reg_field($cop0_config_2_reg, 
      { name => "su", lsb => 12, sz => 3,
        mode => $MODE_CONSTANT, constant_value => 0 });
    $cop0_config_2_reg_tu = add_control_reg_field($cop0_config_2_reg, 
      { name => "tu", lsb => 28, sz => 3,
        mode => $MODE_CONSTANT, constant_value => 0 });
    $cop0_config_2_reg_m = add_control_reg_field($cop0_config_2_reg, 
      { name => "m", lsb => 31, sz => 1,
        mode => $MODE_CONSTANT, constant_value => 1 });




    $cop0_config_3_reg_m = add_control_reg_field($cop0_config_3_reg, 
      { name => "m", lsb => 31, sz => 1,
        mode => $MODE_CONSTANT, constant_value => 0 });

    if ($eic_present) {
        $cop0_config_3_reg_tl = add_control_reg_field($cop0_config_3_reg, 
          { name => "tl", lsb => 0, sz => 1,
            mode => $MODE_CONSTANT, constant_value => 0 });
        $cop0_config_3_reg_sm = add_control_reg_field($cop0_config_3_reg, 
          { name => "sm", lsb => 1, sz => 1,
            mode => $MODE_CONSTANT, constant_value => 0 });
        $cop0_config_3_reg_sp = add_control_reg_field($cop0_config_3_reg, 
          { name => "sp", lsb => 4, sz => 1,
            mode => $MODE_CONSTANT, constant_value => 0 });
        $cop0_config_3_reg_vint = add_control_reg_field($cop0_config_3_reg, 
          { name => "vint", lsb => 5, sz => 1,
            mode => $MODE_CONSTANT, constant_value => 0 });
        $cop0_config_3_reg_veic = add_control_reg_field($cop0_config_3_reg, 
          { name => "veic", lsb => 6, sz => 1,
            mode => $MODE_CONSTANT, constant_value => 0 });
    }

    if ($debug_port_present) {



        $cop0_debug_reg_dss = add_control_reg_field($cop0_debug_reg, 
          { name => "dss", lsb => 0, sz => 1, mode => $MODE_READ_ONLY });
        $cop0_debug_reg_dbp = add_control_reg_field($cop0_debug_reg, 
          { name => "dbp", lsb => 1, sz => 1, mode => $MODE_READ_ONLY });
        $cop0_debug_reg_ddbl = add_control_reg_field($cop0_debug_reg, 
          { name => "ddbl", lsb => 2, sz => 1, 
            mode => $MODE_CONSTANT, constant_value => 0 });
        $cop0_debug_reg_ddbs = add_control_reg_field($cop0_debug_reg, 
          { name => "ddbs", lsb => 3, sz => 1, 
            mode => $MODE_CONSTANT, constant_value => 0 });
        $cop0_debug_reg_dib = add_control_reg_field($cop0_debug_reg, 
          { name => "dib", lsb => 4, sz => 1, mode => $MODE_READ_ONLY });
        $cop0_debug_reg_dint = add_control_reg_field($cop0_debug_reg, 
          { name => "dint", lsb => 5, sz => 1, mode => $MODE_READ_ONLY });
        $cop0_debug_reg_offline = add_control_reg_field($cop0_debug_reg, 
          { name => "offline", lsb => 7, sz => 1, 
            mode => $MODE_CONSTANT, constant_value => 0 });
        $cop0_debug_reg_sst = add_control_reg_field($cop0_debug_reg, 
          { name => "sst", lsb => 8, sz => 1 });
        $cop0_debug_reg_no_sst = add_control_reg_field($cop0_debug_reg, 
          { name => "no_sst", lsb => 9, sz => 1, 
            mode => $MODE_CONSTANT, constant_value => 0 });
        $cop0_debug_reg_dexc_code = add_control_reg_field($cop0_debug_reg, 
          { name => "dexc_code", lsb => 10, sz => 5, mode => $MODE_READ_ONLY });
        $cop0_debug_reg_ejtag_ver = add_control_reg_field($cop0_debug_reg, 
          { name => "ejtag_ver", lsb => 15, sz => 3, 
            mode => $MODE_CONSTANT,
            constant_value => manditory_int($constants, "ejtag_version_2_6") });
        $cop0_debug_reg_ddbl_impr = add_control_reg_field($cop0_debug_reg, 
          { name => "ddbl_impr", lsb => 18, sz => 1, 
            mode => $MODE_CONSTANT, constant_value => 0 });
        $cop0_debug_reg_ddbs_impr = add_control_reg_field($cop0_debug_reg, 
          { name => "ddbs_impr", lsb => 19, sz => 1, 
            mode => $MODE_CONSTANT, constant_value => 0 });
        $cop0_debug_reg_iexi = add_control_reg_field($cop0_debug_reg, 
          { name => "iexi", lsb => 20, sz => 1, 
            mode => $MODE_CONSTANT, constant_value => 0 });
        $cop0_debug_reg_dbus_ep = add_control_reg_field($cop0_debug_reg, 
          { name => "dbus_ep", lsb => 21, sz => 1, 
            mode => $MODE_CONSTANT, constant_value => 0 });
        $cop0_debug_reg_cache_ep = add_control_reg_field($cop0_debug_reg, 
          { name => "cache_ep", lsb => 22, sz => 1, 
            mode => $MODE_CONSTANT, constant_value => 0 });
        $cop0_debug_reg_mcheck_pend = add_control_reg_field($cop0_debug_reg, 
          { name => "mcheck_pend", lsb => 23, sz => 1, 
            mode => $MODE_CONSTANT, constant_value => 0 });
        $cop0_debug_reg_ibus_err_pend = add_control_reg_field($cop0_debug_reg, 
          { name => "ibus_err_pend", lsb => 24, sz => 1, 
            mode => $MODE_CONSTANT, constant_value => 0 });
        $cop0_debug_reg_count_dm = add_control_reg_field($cop0_debug_reg, 
          { name => "count_dm", lsb => 25, sz => 1, 
            mode => $MODE_CONSTANT, constant_value => 0 });
        $cop0_debug_reg_halt = add_control_reg_field($cop0_debug_reg, 
          { name => "halt", lsb => 26, sz => 1, 
            mode => $MODE_CONSTANT, constant_value => 0 });
        $cop0_debug_reg_doze = add_control_reg_field($cop0_debug_reg, 
          { name => "doze", lsb => 27, sz => 1, 
            mode => $MODE_CONSTANT, constant_value => 0 });
        $cop0_debug_reg_lsnm = add_control_reg_field($cop0_debug_reg, 
          { name => "lsnm", lsb => 28, sz => 1 });
        $cop0_debug_reg_no_dcr = add_control_reg_field($cop0_debug_reg, 
          { name => "no_dcr", lsb => 29, sz => 1, 
            mode => $MODE_CONSTANT, constant_value => 0 });
        $cop0_debug_reg_dm = add_control_reg_field($cop0_debug_reg, 
          { name => "dm", lsb => 30, sz => 1, mode => $MODE_READ_ONLY });
        $cop0_debug_reg_dbd = add_control_reg_field($cop0_debug_reg, 
          { name => "dbd", lsb => 31, sz => 1, mode => $MODE_READ_ONLY });




        $cop0_depc_reg_depc = add_control_reg_field($cop0_depc_reg, 
          { name => "depc", lsb => 0, sz => 32 });
    }





    $cop0_tag_lo_0_reg_d = add_control_reg_field($cop0_tag_lo_0_reg, 
      { name => "d", lsb => 6, sz => 1 });
    $cop0_tag_lo_0_reg_v = add_control_reg_field($cop0_tag_lo_0_reg, 
      { name => "v", lsb => 7, sz => 1 });
    $cop0_tag_lo_0_reg_pa = add_control_reg_field($cop0_tag_lo_0_reg, 
      { name => "pa", lsb => 8, sz => 24 });




    $cop0_error_epc_reg_error_epc = add_control_reg_field(
      $cop0_error_epc_reg, 
      { name => "error_epc", lsb => 0, sz => 32 });
    
    if ($debug_port_present) {



        $cop0_de_save_reg_de_save = add_control_reg_field($cop0_de_save_reg, 
          { name => "de_save", lsb => 0, sz => 32 });
    }

    return ($all_control_regs, $control_regs, 
      \@skip_control_reg_when_creating_global_field_scalars);
}



sub
add_control_reg
{
    my $all_control_regs = shift;
    my $control_regs = shift;
    my $present = shift;
    my $props = shift;

    my $name = not_empty_scalar($props, "name");
    my $num = manditory_int($props, "num");
    my $select = manditory_int($props, "select");

    if (defined(get_control_reg_by_name_or_undef($control_regs, $name))) {
        return &$error("Control register name '$name' already exists");
    }

    if (
      defined(get_control_reg_by_num_or_undef($control_regs, $num, $select))) {
        return &$error("Control register number $num with select $select" .
          " already exists");
    }

    my $control_reg = create_control_reg($props);


    push(@$all_control_regs, $control_reg);
    if ($present) {
        push(@$control_regs, $control_reg);
    }

    return $present ? $control_reg : undef;
}

sub
encode_cache_line_size
{
    my $constants = shift;
    my $bytes_per_line = shift;

    if ($bytes_per_line == 4) {
        return $constants->{cache_4_byte_lines};
    }
    if ($bytes_per_line == 8) {
        return $constants->{cache_8_byte_lines};
    }
    if ($bytes_per_line == 16) {
        return $constants->{cache_16_byte_lines};
    }
    if ($bytes_per_line == 32) {
        return $constants->{cache_32_byte_lines};
    }
    if ($bytes_per_line == 64) {
        return $constants->{cache_64_byte_lines};
    }
    if ($bytes_per_line == 128) {
        return $constants->{cache_128_byte_lines};
    }

    &$error("Can't encode '$bytes_per_line' bytes_per_line");
}

sub
encode_cache_sets_per_way
{
    my $constants = shift;
    my $sets_per_way = shift;

    if ($sets_per_way == 64) {
        return $constants->{cache_64_sets_per_way};
    }
    if ($sets_per_way == 128) {
        return $constants->{cache_128_sets_per_way};
    }
    if ($sets_per_way == 256) {
        return $constants->{cache_256_sets_per_way};
    }
    if ($sets_per_way == 512) {
        return $constants->{cache_512_sets_per_way};
    }
    if ($sets_per_way == 1024) {
        return $constants->{cache_1024_sets_per_way};
    }
    if ($sets_per_way == 2048) {
        return $constants->{cache_2048_sets_per_way};
    }
    if ($sets_per_way == 4096) {
        return $constants->{cache_4096_sets_per_way};
    }




    if (($ENV{EPGTEST_HOME} ne "") && 
      (($sets_per_way == 32) || ($sets_per_way == 16))) {
        return $constants->{cache_64_sets_per_way};
    }

    &$error("Can't encode '$sets_per_way' sets_per_way");
}

sub
eval_cmd
{
    my $cmd = shift;

    eval($cmd);
    if ($@) {
        &$error("nevada_control_regs.pm: eval($cmd) returns '$@'\n");
    }
}

1;
