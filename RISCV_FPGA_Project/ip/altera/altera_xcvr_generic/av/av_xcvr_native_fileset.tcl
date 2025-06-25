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


#
# Common functions for Stratix V transceiver datapath blocks
#

proc av_xcvr_native_decl_fileset_groups { altera_xcvr_generic_root } {

        # package with common functions
        common_fileset_group_plain ./ "$altera_xcvr_generic_root/" {
                altera_xcvr_functions.sv
        } {ALL_HDL}

    # reconfig top component
    common_fileset_group_plain ./ "$altera_xcvr_generic_root/sv/" {
        sv_reconfig_bundle_to_xcvr.sv
        sv_reconfig_bundle_to_ip.sv
        sv_reconfig_bundle_merger.sv
    } {A5}

    common_fileset_group_plain ./ "$altera_xcvr_generic_root/av/" {
		av_xcvr_h.sv
        av_xcvr_avmm_csr.sv
        av_tx_pma_ch.sv
        av_tx_pma.sv
        av_rx_pma.sv
        av_pma.sv
        av_pcs_ch.sv
        av_pcs.sv
        av_xcvr_avmm.sv
        av_xcvr_native.sv
        av_xcvr_plls.sv
        av_xcvr_data_adapter.sv
		av_reconfig_bundle_to_basic.sv
        av_reconfig_bundle_to_xcvr.sv
    } {A5}

        common_fileset_group_plain ./ "$altera_xcvr_generic_root/av/rbc/" {
                av_hssi_8g_rx_pcs_rbc.sv
                av_hssi_8g_tx_pcs_rbc.sv
                av_hssi_common_pcs_pma_interface_rbc.sv
                av_hssi_common_pld_pcs_interface_rbc.sv
                av_hssi_pipe_gen1_2_rbc.sv
                av_hssi_rx_pcs_pma_interface_rbc.sv
                av_hssi_rx_pld_pcs_interface_rbc.sv
                av_hssi_tx_pcs_pma_interface_rbc.sv
                av_hssi_tx_pld_pcs_interface_rbc.sv
        } {A5}
#       stratixv_hssi_hi_rx_if_rbc.sv
#       stratixv_hssi_hi_tx_if_rbc.sv
# stratixv_hssi_8g_pcs_aggregate_rbc.sv
# stratixv_hssi_pma_aux_rbc.sv
# stratixv_hssi_pma_cdr_refclk_select_mux_rbc.sv
# stratixv_hssi_pma_int_rbc.sv
# stratixv_hssi_pma_rx_buf_rbc.sv
# stratixv_hssi_pma_rx_deser_rbc.sv
# stratixv_hssi_pma_tx_buf_rbc.sv
# stratixv_hssi_pma_tx_cgb_rbc.sv
# stratixv_hssi_pma_tx_ser_rbc.sv
# stratixv_hssi_refclk_divider_rbc.sv
}
