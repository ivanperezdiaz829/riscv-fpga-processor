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


#################################################################################################
# Global variables (constants)
# These global variable constants are shared among the TSE core and its ucores.
# DO NOT attempt to change these variables in your proc as it is a bad coding style.
#################################################################################################
set mac_instance i_tse_mac
set fifoless_mac_instance i_tse_fifoless_mac
set pcs_instance i_tse_pcs
set lvdsio_rx_instance i_lvdsio_rx
set lvdsio_tx_instance i_lvdsio_tx
set lvdsio_terminator_instance i_lvdsio_terminator
set altgxb_instance i_altgxb
set phyip_instance i_custom_phyip
set phyip_terminator_instance i_phyip_terminator
set nf_phyip_instance i_nf_native_phyip
set nf_phyip_terminator_instance i_nf_native_phyip_terminator

# Connection point names
set AVALON_CP_NAME control_port
set AVALON_CLOCK_CP_NAME control_port_clock_connection
set AVALON_RESET_CP_NAME reset_connection

set ATLANTIC_SOURCE_CLOCK_CP_NAME receive_clock_connection
set ATLANTIC_SINK_CLOCK_CP_NAME transmit_clock_connection

set ATLANTIC_SOURCE_CP_NAME receive
set ATLANTIC_SINK_CP_NAME transmit

set ATLANTIC_SOURCE_PACKET_CLASS_CP_NAME receive_packet_type

set MAC_GMII_CP_NAME mac_gmii_connection
set MAC_MII_CP_NAME mac_mii_connection
set MAC_RGMII_CP_NAME mac_rgmii_connection
set MAC_STATUS_CP_NAME mac_status_connection
set MAC_MDIO_CP_NAME mac_mdio_connection
set WIRE_MISC_CP_NAME mac_misc_connection
set WIRE_CLKENA_CP_NAME mac_clkena_connection

set MAC_TX_CLOCK_NAME mac_tx_clock_connection
set MAC_RX_CLOCK_NAME mac_rx_clock_connection

set PCS_MAC_TX_CLOCK_NAME pcs_mac_tx_clock_connection
set PCS_MAC_RX_CLOCK_NAME pcs_mac_rx_clock_connection

set MAC_RX_FIFO_STATUS_CLOCK_NAME receive_fifo_status_clock_connection
set MAC_RX_FIFO_STATUS_NAME receive_fifo_status

set MAC_REG_SHARE_OUT_NAME register_share_out_connection
set MAC_REG_SHARE_IN_NAME register_share_in_connection

# Arria 10 Native PHYIP reconfiguration connection point nams
set NF_PHYIP_RECONFIG_CLK_NAME reconfig_clk
set NF_PHYIP_RECONFIG_RESET_NAME reconfig_reset
set NF_PHYIP_RECONFIG_SLAVE_NAME reconfig_avmm


# PCS only connection point names
set PCS_TX_CLK_NAME pcs_transmit_clock_connection
set PCS_RX_CLK_NAME pcs_receive_clock_connection
set PCS_REF_CLK_CP_NAME pcs_ref_clk_clock_connection
set PCS_CDR_REF_CLK_CP_NAME pcs_cdr_ref_clk_clock_connection

set PCS_TX_RESET_NAME pcs_transmit_reset_connection
set PCS_RX_RESET_NAME pcs_receive_reset_connection

set PCS_GMII_CP_NAME gmii_connection
set PCS_MII_CP_NAME mii_connection

set PCS_CLKENA_CP_NAME clock_enable_connection

set PCS_SGMII_STATUS_CP_NAME sgmii_status_connection
set PCS_STATUS_LED_CP_NAME status_led_connection
set PCS_SERDES_CONTROL_CP_NAME serdes_control_connection
set PCS_TBI_CP_NAME tbi_connection
set PMA_SERIAL_CP_NAME serial_connection
set PMA_GXB_CAL_BLK_CLK_CP_NAME cal_blk_clk

# 1588 Timestamp connection point names
set PCS_PHASE_MEASURE_CLK pcs_phase_measure_clk
set RX_LATENCY_ADJ rx_latency_adj
set TX_LATENCY_ADJ tx_latency_adj
set WA_BOUNDARY wa_boundary

set TX_EGRESS_TIMESTAMP_REQUEST        tx_egress_timestamp_request
set TX_ETSTAMP_INS_CTRL                tx_etstamp_ins_ctrl
set TX_PATH_DELAY                      tx_path_delay
set RX_PATH_DELAY                      rx_path_delay

set TX_TIME_OF_DAY_96B                 tx_time_of_day_96b
set TX_TIME_OF_DAY_64B                 tx_time_of_day_64b

set TX_EGRESS_TIMESTAMP_96B            tx_egress_timestamp_96b
set TX_EGRESS_TIMESTAMP_64B            tx_egress_timestamp_64b
set RX_INGRESS_TIMESTAMP_96B           rx_ingress_timestamp_96b
set RX_INGRESS_TIMESTAMP_64B           rx_ingress_timestamp_64b

set RX_TIME_OF_DAY_96B                 rx_time_of_day_96b
set RX_TIME_OF_DAY_64B                 rx_time_of_day_64b

# A direct mapping between the mac instance parameter with the
# core parameter
array set mac_instance_param_map {
   ENABLE_MAGIC_DETECT        enable_magic_detect
   ENABLE_MDIO                useMDIO
   ENABLE_SHIFT16             enable_shift16
   ENABLE_SUP_ADDR            enable_sup_addr
   MDIO_CLK_DIV               mdio_clk_div
   ENA_HASH                   ena_hash
   STAT_CNT_ENA               stat_cnt_ena
   ENABLE_GMII_LOOPBACK       enable_gmii_loopback
   ENABLE_MAC_FLOW_CTRL       enable_mac_flow_ctrl
   ENABLE_MAC_RX_VLAN         enable_mac_vlan
   ENABLE_MAC_TX_VLAN         enable_mac_vlan
   EG_ADDR                    eg_addr
   ENABLE_ENA                 enable_ena
   ING_ADDR                   ing_addr
   CORE_VERSION               core_version
   EG_FIFO                    eg_fifo
   ING_FIFO                   ing_fifo
   REDUCED_INTERFACE_ENA      reduced_interface_ena
   SYNCHRONIZER_DEPTH         synchronizer_depth
   ENABLE_PADDING             enable_padding
   ENABLE_LGTH_CHECK          enable_lgth_check
   GBIT_ONLY                  gbit_only
   MBIT_ONLY                  mbit_only
   REDUCED_CONTROL            reduced_control
   DEVICE_FAMILY              deviceFamily
}

# A direct mapping between the fifoless mac instance parameter with the
# core parameter
array set fifoless_mac_instance_param_map {
   ENABLE_MAGIC_DETECT        enable_magic_detect
   ENABLE_SHIFT16             enable_shift16
   ENABLE_SUP_ADDR            enable_sup_addr
   MDIO_CLK_DIV               mdio_clk_div
   ENA_HASH                   ena_hash
   STAT_CNT_ENA               stat_cnt_ena
   ENABLE_GMII_LOOPBACK       enable_gmii_loopback
   ENABLE_MAC_FLOW_CTRL       enable_mac_flow_ctrl
   ENABLE_MAC_RX_VLAN         enable_mac_vlan
   ENABLE_MAC_TX_VLAN         enable_mac_vlan
   CORE_VERSION               core_version
   REDUCED_INTERFACE_ENA      reduced_interface_ena
   SYNCHRONIZER_DEPTH         synchronizer_depth
   ENABLE_PADDING             enable_padding
   ENABLE_LGTH_CHECK          enable_lgth_check
   GBIT_ONLY                  gbit_only
   MBIT_ONLY                  mbit_only
   REDUCED_CONTROL            reduced_control
   DEVICE_FAMILY              deviceFamily
}

# A direct mapping between the PCS instance parameter with the core parameter
array set pcs_instance_param_map {
   PHY_IDENTIFIER             phy_identifier
   DEV_VERSION                dev_version
   ENABLE_SGMII               enable_sgmii
   ENABLE_CLK_SHARING         enable_clk_sharing
   SYNCHRONIZER_DEPTH         synchronizer_depth
}

# A direct mapping between the PCS PMA LVDS instance parameter with the core parameter
array set pcs_pma_lvds_instance_param_map {
   PHY_IDENTIFIER             phy_identifier
   DEV_VERSION                dev_version
   ENABLE_SGMII               enable_sgmii
   ENABLE_CLK_SHARING         enable_clk_sharing
   SYNCHRONIZER_DEPTH         synchronizer_depth
   DEVICE_FAMILY              deviceFamily
}

# A direct mapping between the PCS PMA LVDS instance parameter with the core parameter
# for NightFury (Arria 10) device family
array set pcs_pma_nf_lvds_instance_param_map {
   PHY_IDENTIFIER             phy_identifier
   DEV_VERSION                dev_version
   ENABLE_SGMII               enable_sgmii
   ENABLE_CLK_SHARING         enable_clk_sharing
   SYNCHRONIZER_DEPTH         synchronizer_depth
   DEVICE_FAMILY              deviceFamily
}

# A direct mapping between the PCS PMA GXB instance parameter with the core parameter
array set pcs_pma_gxb_instance_param_map {
   PHY_IDENTIFIER             phy_identifier
   DEV_VERSION                dev_version
   ENABLE_SGMII               enable_sgmii
   ENABLE_CLK_SHARING         enable_clk_sharing
   SYNCHRONIZER_DEPTH         synchronizer_depth
   DEVICE_FAMILY              deviceFamily
}

# A direct mapping between the ALTGXB instance parameter with the core parameter
array set altgxb_instance_param_map {
   DEVICE_FAMILY              deviceFamily
   export_pwrdn               export_pwrdn
}

# A direct mapping between the PCS PMA PHYIP instance parameter with the core parameter
array set pcs_pma_phyip_instance_param_map {
   PHY_IDENTIFIER             phy_identifier
   DEV_VERSION                dev_version
   ENABLE_SGMII               enable_sgmii
   ENABLE_CLK_SHARING         enable_clk_sharing
   SYNCHRONIZER_DEPTH         synchronizer_depth
   DEVICE_FAMILY              deviceFamily
   ENABLE_TIMESTAMPING        enable_timestamping
}

# A direct port mapping between ALTGXB and PCS
# PCS <-> ALTGXB
array set pcs_altgxb_port_connection {
   rx_analogreset_sqcnr             rx_analogreset_sqcnr
   rx_digitalreset_sqcnr_rx_clk     rx_digitalreset_sqcnr_rx_clk
   sd_loopback                      sd_loopback
   tx_kchar                         tx_kchar
   tx_frame                         tx_frame
   tx_digitalreset_sqcnr_tx_clk     tx_digitalreset_sqcnr_tx_clk
   pll_locked                       pll_locked
   rx_freqlocked                    rx_freqlocked
   rx_kchar                         rx_kchar
   rx_pcs_clk                       rx_pcs_clk
   rx_frame                         rx_frame
   rx_disp_err                      rx_disp_err
   rx_char_err_gx                   rx_char_err_gx
   rx_patterndetect                 rx_patterndetect
   rx_runlengthviolation            rx_runlengthviolation
   rx_syncstatus                    rx_syncstatus
   tx_pcs_clk                       tx_pcs_clk
   rx_rmfifodatadeleted             rx_rmfifodatadeleted
   rx_rmfifodatainserted            rx_rmfifodatainserted
   rx_runningdisp                   rx_runningdisp
   gxb_pwrdn_in_to_pcs              gxb_pwrdn_in_to_pcs
   reconfig_busy_to_pcs             reconfig_busy_to_pcs
   pcs_pwrdn_out_from_pcs           pcs_pwrdn_out_from_pcs
}

# A direct port mapping between PHYIP and PCS
# PCS <-> PHYIP
array set pcs_pma_phyip_port_connection {
   tx_pcs_clk                 tx_clkout
   tx_frame                   tx_parallel_data
   tx_kchar                   tx_datak
   rx_frame                   rx_parallel_data
   rx_kchar                   rx_datak
   rx_runlengthviolation      rx_rlv
   rx_patterndetect           rx_patterndetect
   rx_runningdisp             rx_runningdisp
   rx_syncstatus              rx_syncstatus
   rx_char_err_gx             rx_errdetect
   rx_disp_err                rx_disperr
   wa_boundary                rx_bitslipboundaryselectout
}

# A direct port mapping between PHYIP and PHYIP terminator
# PHYIP <-> PHYIP terminator
array set phyip_terminator_port_connection {
   tx_serial_data             tx_serial_data
   rx_serial_data             rx_serial_data
   tx_ready                   tx_ready
   rx_ready                   rx_ready
   pll_locked                 pll_locked
   reconfig_from_xcvr         reconfig_from_xcvr
   reconfig_to_xcvr           reconfig_to_xcvr
}

# A direct port mapping between PHYIP and PCS
# PCS <-> PHYIP (NightFury)
array set pcs_pma_nf_phyip_port_connection {
   tx_frame                   tx_parallel_data
   tx_kchar                   tx_datak
   rx_frame                   rx_parallel_data
   rx_kchar                   rx_datak
   rx_patterndetect           rx_patterndetect
   rx_runningdisp             rx_runningdisp
   rx_syncstatus              rx_syncstatus
   rx_char_err_gx             rx_errdetect
   rx_disp_err                rx_disperr
   wa_boundary                rx_std_bitslipboundarysel
}

# A direct port mapping between PHYIP and PHYIP terminator
# PHYIP <-> PHYIP terminator (NighFury)
array set nf_phyip_terminator_port_connection {
   tx_serial_data             tx_serial_data
   rx_serial_data             rx_serial_data
   rx_seriallpbken            rx_seriallpbken
   unused_tx_parallel_data    unused_tx_parallel_data
   unused_rx_parallel_data    unused_rx_parallel_data
   tx_clkout                  tx_clk
   rx_clkout                  rx_clk
}

#################################################################################################
# RTL files
#################################################################################################
set timestamp_rtl_files {
   altera_tse_ptp_inserter.v              VERILOG
   altera_tse_avst_to_gmii_if.v           VERILOG
   altera_tse_gmii_to_avst_if.v           VERILOG
   altera_tse_ptp_1588_crc.v              VERILOG
   altera_tse_ptp_1588_rx_top.v           VERILOG
   altera_tse_ptp_1588_tx_top.v           VERILOG
   altera_tse_timestamp_req_ctrl.v        VERILOG
   altera_tse_tsu.v                       VERILOG
}

set timestamp_ocp_files {
   altera_tse_ptp_1588_rx_top.ocp         OTHER
   altera_tse_ptp_1588_tx_top.ocp         OTHER
}

set common_rtl_files {
   altera_tse_false_path_marker.v         VERILOG
   altera_tse_reset_synchronizer.v        VERILOG
   altera_tse_clock_crosser.v             VERILOG
   altera_tse_a_fifo_13.v                 VERILOG
   altera_tse_a_fifo_24.v                 VERILOG
   altera_tse_a_fifo_34.v                 VERILOG
   altera_tse_a_fifo_opt_1246.v           VERILOG
   altera_tse_a_fifo_opt_14_44.v          VERILOG
   altera_tse_a_fifo_opt_36_10.v          VERILOG
   altera_tse_gray_cnt.v                  VERILOG
   altera_tse_sdpm_altsyncram.v           VERILOG
   altera_tse_altsyncram_dpm_fifo.v       VERILOG
   altera_tse_bin_cnt.v                   VERILOG
   altera_tse_ph_calculator.sv            SYSTEM_VERILOG
   altera_tse_sdpm_gen.v                  VERILOG
   altera_tse_dc_fifo.v                   VERILOG
}

# MAC RTL Files
set mac_rtl_files {
   altera_tse_clk_cntl.v                  VERILOG
   altera_tse_crc328checker.v             VERILOG
   altera_tse_crc328generator.v           VERILOG
   altera_tse_crc32ctl8.v                 VERILOG
   altera_tse_crc32galois8.v              VERILOG
   altera_tse_gmii_io.v                   VERILOG
   altera_tse_lb_read_cntl.v              VERILOG
   altera_tse_lb_wrt_cntl.v               VERILOG
   altera_tse_hashing.v                   VERILOG
   altera_tse_host_control.v              VERILOG
   altera_tse_host_control_small.v        VERILOG
   altera_tse_mac_control.v               VERILOG
   altera_tse_register_map.v              VERILOG
   altera_tse_register_map_small.v        VERILOG
   altera_tse_rx_counter_cntl.v           VERILOG
   altera_tse_shared_mac_control.v        VERILOG
   altera_tse_shared_register_map.v       VERILOG
   altera_tse_tx_counter_cntl.v           VERILOG
   altera_tse_lfsr_10.v                   VERILOG
   altera_tse_loopback_ff.v               VERILOG
   altera_tse_altshifttaps.v              VERILOG
   altera_tse_fifoless_mac_rx.v           VERILOG
   altera_tse_mac_rx.v                    VERILOG
   altera_tse_fifoless_mac_tx.v           VERILOG
   altera_tse_mac_tx.v                    VERILOG
   altera_tse_magic_detection.v           VERILOG
   altera_tse_mdio.v                      VERILOG
   altera_tse_mdio_clk_gen.v              VERILOG
   altera_tse_mdio_cntl.v                 VERILOG
   altera_tse_top_mdio.v                  VERILOG
   altera_tse_mii_rx_if.v                 VERILOG
   altera_tse_mii_tx_if.v                 VERILOG
   altera_tse_pipeline_base.v             VERILOG
   altera_tse_pipeline_stage.sv           SYSTEM_VERILOG
   altera_tse_dpram_16x32.v               VERILOG
   altera_tse_dpram_8x32.v                VERILOG
   altera_tse_quad_16x32.v                VERILOG
   altera_tse_quad_8x32.v                 VERILOG
   altera_tse_fifoless_retransmit_cntl.v  VERILOG
   altera_tse_retransmit_cntl.v           VERILOG
   altera_tse_rgmii_in1.v                 VERILOG
   altera_tse_rgmii_in4.v                 VERILOG
   altera_tse_nf_rgmii_module.v           VERILOG
   altera_tse_rgmii_module.v              VERILOG
   altera_tse_rgmii_out1.v                VERILOG
   altera_tse_rgmii_out4.v                VERILOG
   altera_tse_rx_ff.v                     VERILOG
   altera_tse_rx_min_ff.v                 VERILOG
   altera_tse_rx_ff_cntrl.v               VERILOG
   altera_tse_rx_ff_cntrl_32.v            VERILOG
   altera_tse_rx_ff_cntrl_32_shift16.v    VERILOG
   altera_tse_rx_ff_length.v              VERILOG
   altera_tse_rx_stat_extract.v           VERILOG
   altera_tse_timing_adapter32.v          VERILOG
   altera_tse_timing_adapter8.v           VERILOG
   altera_tse_timing_adapter_fifo32.v     VERILOG
   altera_tse_timing_adapter_fifo8.v      VERILOG
   altera_tse_top_1geth.v                 VERILOG
   altera_tse_top_fifoless_1geth.v        VERILOG
   altera_tse_top_w_fifo.v                VERILOG
   altera_tse_top_w_fifo_10_100_1000.v    VERILOG
   altera_tse_top_wo_fifo.v               VERILOG
   altera_tse_top_wo_fifo_10_100_1000.v   VERILOG
   altera_tse_top_gen_host.v              VERILOG
   altera_tse_tx_ff.v                     VERILOG
   altera_tse_tx_min_ff.v                 VERILOG
   altera_tse_tx_ff_cntrl.v               VERILOG
   altera_tse_tx_ff_cntrl_32.v            VERILOG
   altera_tse_tx_ff_cntrl_32_shift16.v    VERILOG
   altera_tse_tx_ff_length.v              VERILOG
   altera_tse_tx_ff_read_cntl.v           VERILOG
   altera_tse_tx_stat_extract.v           VERILOG
}

set mac_ocp_files {
   altera_tse_top_wo_fifo_10_100_1000.ocp OTHER
   altera_tse_top_w_fifo_10_100_1000.ocp  OTHER
}

# PCS RTL Files
set pcs_rtl_files {
   altera_tse_align_sync.v                VERILOG
   altera_tse_dec10b8b.v                  VERILOG
   altera_tse_dec_func.v                  VERILOG
   altera_tse_enc8b10b.v                  VERILOG
   altera_tse_top_autoneg.v               VERILOG
   altera_tse_carrier_sense.v             VERILOG
   altera_tse_clk_gen.v                   VERILOG
   altera_tse_sgmii_clk_div.v             VERILOG
   altera_tse_sgmii_clk_enable.v          VERILOG
   altera_tse_rx_encapsulation.v          VERILOG
   altera_tse_tx_encapsulation.v          VERILOG
   altera_tse_rx_encapsulation_strx_gx.v  VERILOG
   altera_tse_pcs_control.v               VERILOG
   altera_tse_pcs_host_control.v          VERILOG
   altera_tse_mdio_reg.v                  VERILOG
   altera_tse_mii_rx_if_pcs.v             VERILOG
   altera_tse_mii_tx_if_pcs.v             VERILOG
   altera_tse_rx_sync.v                   VERILOG
   altera_tse_sgmii_clk_cntl.v            VERILOG
   altera_tse_colision_detect.v           VERILOG
   altera_tse_rx_converter.v              VERILOG
   altera_tse_rx_fifo_rd.v                VERILOG
   altera_tse_top_rx_converter.v          VERILOG
   altera_tse_top_sgmii.v                 VERILOG
   altera_tse_top_sgmii_strx_gx.v         VERILOG
   altera_tse_top_tx_converter.v          VERILOG
   altera_tse_tx_converter.v              VERILOG
   altera_tse_top_1000_base_x.v           VERILOG
   altera_tse_top_1000_base_x_strx_gx.v   VERILOG
   altera_tse_top_pcs.v                   VERILOG
   altera_tse_top_pcs_strx_gx.v           VERILOG
   altera_tse_top_rx.v                    VERILOG
   altera_tse_top_tx.v                    VERILOG
}

set pcs_ocp_files {
   altera_tse_top_1000_base_x.ocp         OTHER
   altera_tse_top_1000_base_x_strx_gx.ocp OTHER
}

# LVDS RTL Files
set lvds_rtl_files {
   altera_tse_lvds_reset_sequencer.v      VERILOG
   altera_tse_lvds_reverse_loopback.v     VERILOG
   altera_tse_pma_lvds_rx_av.v            VERILOG
   altera_tse_pma_lvds_rx.v               VERILOG
   altera_tse_pma_lvds_tx.v               VERILOG
}

# GXB RTL files
set gxb_rtl_files {
   altera_tse_reset_sequencer.sv          SYSTEM_VERILOG
   altera_tse_reset_ctrl_lego.sv          SYSTEM_VERILOG
   altera_tse_xcvr_resync.v               VERILOG
   altera_tse_gxb_aligned_rxsync.v        VERILOG
}

#################################################################################################
# Testbench files
#################################################################################################
# Testbench files in verilog
# output_file file_source_path
set testbench_verilog_files {
   models/mdio_slave.v             ../tse_ucores/altera_eth_tse_testbench/testbench/models/verilog/mdio/mdio_slave.v
   models/top_mdio_slave.v         ../tse_ucores/altera_eth_tse_testbench/testbench/models/verilog/mdio/top_mdio_slave.v
   models/mdio_reg.v               ../tse_ucores/altera_eth_tse_testbench/testbench/models/verilog/mdio/mdio_reg.v
   models/ethgen32.v               ../tse_ucores/altera_eth_tse_testbench/testbench/models/verilog/ethernet_model/gen/ethgen32.v
   models/loopback_adapter_fifo.v  ../tse_ucores/altera_eth_tse_testbench/testbench/models/verilog/ethernet_model/gen/loopback_adapter_fifo.v
   models/timing_adapter_fifo_8.v  ../tse_ucores/altera_eth_tse_testbench/testbench/models/verilog/ethernet_model/gen/timing_adapter_fifo_8.v
   models/timing_adapter_32.v      ../tse_ucores/altera_eth_tse_testbench/testbench/models/verilog/ethernet_model/gen/timing_adapter_32.v
   models/timing_adapter_8.v       ../tse_ucores/altera_eth_tse_testbench/testbench/models/verilog/ethernet_model/gen/timing_adapter_8.v
   models/loopback_adapter.v       ../tse_ucores/altera_eth_tse_testbench/testbench/models/verilog/ethernet_model/gen/loopback_adapter.v
   models/ethgen2.v                ../tse_ucores/altera_eth_tse_testbench/testbench/models/verilog/ethernet_model/gen/ethgen2.v
   models/timing_adapter_fifo_32.v ../tse_ucores/altera_eth_tse_testbench/testbench/models/verilog/ethernet_model/gen/timing_adapter_fifo_32.v
   models/top_ethgen8.v            ../tse_ucores/altera_eth_tse_testbench/testbench/models/verilog/ethernet_model/gen/top_ethgen8.v
   models/ethgen.v                 ../tse_ucores/altera_eth_tse_testbench/testbench/models/verilog/ethernet_model/gen/ethgen.v
   models/top_ethgen32.v           ../tse_ucores/altera_eth_tse_testbench/testbench/models/verilog/ethernet_model/gen/top_ethgen32.v
   models/nf_phyip_reset_model.v   ../tse_ucores/altera_eth_tse_testbench/testbench/models/verilog/ethernet_model/gen/nf_phyip_reset_model.v
   models/ethmon2.v                ../tse_ucores/altera_eth_tse_testbench/testbench/models/verilog/ethernet_model/mon/ethmon2.v
   models/ethmon_32.v              ../tse_ucores/altera_eth_tse_testbench/testbench/models/verilog/ethernet_model/mon/ethmon_32.v
   models/ethmon.v                 ../tse_ucores/altera_eth_tse_testbench/testbench/models/verilog/ethernet_model/mon/ethmon.v
   models/top_ethmon32.v           ../tse_ucores/altera_eth_tse_testbench/testbench/models/verilog/ethernet_model/mon/top_ethmon32.v
}

# Testbench files in vhdl
# output_file file_source_path
set testbench_vhdl_files {
   models/ethgen.vhd                  ../tse_ucores/altera_eth_tse_testbench/testbench/models/vhdl/ethernet_model/gen/ethgen.vhd
   models/ethgen2.vhd                 ../tse_ucores/altera_eth_tse_testbench/testbench/models/vhdl/ethernet_model/gen/ethgen2.vhd
   models/ethgen32.vhd                ../tse_ucores/altera_eth_tse_testbench/testbench/models/vhdl/ethernet_model/gen/ethgen32.vhd
   models/loopback_adapter.vhd        ../tse_ucores/altera_eth_tse_testbench/testbench/models/vhdl/ethernet_model/gen/loopback_adapter.vhd
   models/loopback_adapter_fifo.vhd   ../tse_ucores/altera_eth_tse_testbench/testbench/models/vhdl/ethernet_model/gen/loopback_adapter_fifo.vhd
   models/timing_adapter_32.vhd       ../tse_ucores/altera_eth_tse_testbench/testbench/models/vhdl/ethernet_model/gen/timing_adapter_32.vhd
   models/timing_adapter_fifo_32.vhd  ../tse_ucores/altera_eth_tse_testbench/testbench/models/vhdl/ethernet_model/gen/timing_adapter_fifo_32.vhd
   models/timing_adapter_8.vhd        ../tse_ucores/altera_eth_tse_testbench/testbench/models/vhdl/ethernet_model/gen/timing_adapter_8.vhd
   models/timing_adapter_8_fifo.vhd   ../tse_ucores/altera_eth_tse_testbench/testbench/models/vhdl/ethernet_model/gen/timing_adapter_8_fifo.vhd
   models/timing_adapter_fifo_8.vhd   ../tse_ucores/altera_eth_tse_testbench/testbench/models/vhdl/ethernet_model/gen/timing_adapter_fifo_8.vhd
   models/top_ethgen8.vhd             ../tse_ucores/altera_eth_tse_testbench/testbench/models/vhdl/ethernet_model/gen/top_ethgen8.vhd
   models/nf_phyip_reset_model.vhd    ../tse_ucores/altera_eth_tse_testbench/testbench/models/vhdl/ethernet_model/gen/nf_phyip_reset_model.vhd
   models/ethmon.vhd                  ../tse_ucores/altera_eth_tse_testbench/testbench/models/vhdl/ethernet_model/mon/ethmon.vhd
   models/ethmon2.vhd                 ../tse_ucores/altera_eth_tse_testbench/testbench/models/vhdl/ethernet_model/mon/ethmon2.vhd
   models/ethmon_32.vhd               ../tse_ucores/altera_eth_tse_testbench/testbench/models/vhdl/ethernet_model/mon/ethmon_32.vhd
   models/top_ethmon32.vhd            ../tse_ucores/altera_eth_tse_testbench/testbench/models/vhdl/ethernet_model/mon/top_ethmon32.vhd
   models/altera_ethmodels_pack.vhd   ../tse_ucores/altera_eth_tse_testbench/testbench/models/vhdl/ethernet_model/package/altera_ethmodels_pack.vhd
   models/mdio_reg.vhd                ../tse_ucores/altera_eth_tse_testbench/testbench/models/vhdl/mdio/mdio_reg.vhd
   models/mdio_slave.vhd              ../tse_ucores/altera_eth_tse_testbench/testbench/models/vhdl/mdio/mdio_slave.vhd
   models/top_mdio_slave.vhd          ../tse_ucores/altera_eth_tse_testbench/testbench/models/vhdl/mdio/top_mdio_slave.vhd
}

#################################################################################################
# Testbench dut port list
# Support termination of port with different signal name
# and with constant value (currently only decimal value)
# or left open
#################################################################################################
# dut port <-> testbench port
set testbench_port_connection {
   clk               reg_clk
   read              reg_rd
   waitrequest       reg_busy
   write             reg_wr

   reset_rx_clk      reset
   reset_tx_clk      reset
   reset_ff_rx_clk   reset
   reset_ff_tx_clk   reset
   reset_reg_clk     reset
   gm_rx_d           gm_rx_data
   gm_rx_dv          gm_rx_en
   gm_tx_d           gm_tx_data
   gm_rx_dv          gm_rx_en
   m_rx_d            m_rx_data
   m_tx_d            m_tx_data

   address           reg_addr
   readdata          reg_data_out
   writedata         reg_data_in
   eth_mode          ""
   ena_10            ""

   tx_ff_uflow       ""

   mii_crs           ""
   mii_col           ""
   led_col           ""
   rx_afull_channel  rx_afull_channel

   gxb_cal_blk_clk   ref_clk
}

set testbench_port_mac_only_connection {
   set_10            "0"
   set_1000          "0"
}

set testbench_port_pcs_only_connection {
   set_10            ""
   set_1000          ""
}
