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


vlog -sv $env(SNK_SIM_LOCATION)/seriallite_iii/altera_xcvr_interlaken/altera_xcvr_functions.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv $env(SNK_SIM_LOCATION)/seriallite_iii/altera_xcvr_interlaken/alt_xcvr_csr_common_h.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv $env(SNK_SIM_LOCATION)/seriallite_iii/altera_xcvr_interlaken/alt_xcvr_csr_pcs8g_h.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv $env(SNK_SIM_LOCATION)/seriallite_iii/altera_xcvr_interlaken/sv_xcvr_h.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv $env(SNK_SIM_LOCATION)/seriallite_iii/altera_xcvr_interlaken/alt_xcvr_resync.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv $env(SNK_SIM_LOCATION)/seriallite_iii/altera_xcvr_interlaken/sv_pcs.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv $env(SNK_SIM_LOCATION)/seriallite_iii/altera_xcvr_interlaken/sv_pcs_ch.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv $env(SNK_SIM_LOCATION)/seriallite_iii/altera_xcvr_interlaken/sv_pma.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv $env(SNK_SIM_LOCATION)/seriallite_iii/altera_xcvr_interlaken/sv_reconfig_bundle_to_xcvr.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv $env(SNK_SIM_LOCATION)/seriallite_iii/altera_xcvr_interlaken/sv_reconfig_bundle_to_ip.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv $env(SNK_SIM_LOCATION)/seriallite_iii/altera_xcvr_interlaken/sv_reconfig_bundle_merger.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv $env(SNK_SIM_LOCATION)/seriallite_iii/altera_xcvr_interlaken/sv_rx_pma.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv $env(SNK_SIM_LOCATION)/seriallite_iii/altera_xcvr_interlaken/sv_tx_pma.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv $env(SNK_SIM_LOCATION)/seriallite_iii/altera_xcvr_interlaken/sv_tx_pma_ch.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv $env(SNK_SIM_LOCATION)/seriallite_iii/altera_xcvr_interlaken/sv_xcvr_avmm_csr.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv $env(SNK_SIM_LOCATION)/seriallite_iii/altera_xcvr_interlaken/sv_xcvr_avmm_dcd.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv $env(SNK_SIM_LOCATION)/seriallite_iii/altera_xcvr_interlaken/sv_xcvr_avmm.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv $env(SNK_SIM_LOCATION)/seriallite_iii/altera_xcvr_interlaken/sv_xcvr_data_adapter.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv $env(SNK_SIM_LOCATION)/seriallite_iii/altera_xcvr_interlaken/sv_xcvr_native.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv $env(SNK_SIM_LOCATION)/seriallite_iii/altera_xcvr_interlaken/sv_xcvr_plls.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv $env(SNK_SIM_LOCATION)/seriallite_iii/altera_xcvr_interlaken/sv_hssi_10g_rx_pcs_rbc.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv $env(SNK_SIM_LOCATION)/seriallite_iii/altera_xcvr_interlaken/sv_hssi_10g_tx_pcs_rbc.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv $env(SNK_SIM_LOCATION)/seriallite_iii/altera_xcvr_interlaken/sv_hssi_8g_rx_pcs_rbc.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv $env(SNK_SIM_LOCATION)/seriallite_iii/altera_xcvr_interlaken/sv_hssi_8g_tx_pcs_rbc.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv $env(SNK_SIM_LOCATION)/seriallite_iii/altera_xcvr_interlaken/sv_hssi_8g_pcs_aggregate_rbc.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv $env(SNK_SIM_LOCATION)/seriallite_iii/altera_xcvr_interlaken/sv_hssi_common_pcs_pma_interface_rbc.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv $env(SNK_SIM_LOCATION)/seriallite_iii/altera_xcvr_interlaken/sv_hssi_common_pld_pcs_interface_rbc.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv $env(SNK_SIM_LOCATION)/seriallite_iii/altera_xcvr_interlaken/sv_hssi_pipe_gen1_2_rbc.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv $env(SNK_SIM_LOCATION)/seriallite_iii/altera_xcvr_interlaken/sv_hssi_pipe_gen3_rbc.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv $env(SNK_SIM_LOCATION)/seriallite_iii/altera_xcvr_interlaken/sv_hssi_rx_pcs_pma_interface_rbc.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv $env(SNK_SIM_LOCATION)/seriallite_iii/altera_xcvr_interlaken/sv_hssi_rx_pld_pcs_interface_rbc.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv $env(SNK_SIM_LOCATION)/seriallite_iii/altera_xcvr_interlaken/sv_hssi_tx_pcs_pma_interface_rbc.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv $env(SNK_SIM_LOCATION)/seriallite_iii/altera_xcvr_interlaken/sv_hssi_tx_pld_pcs_interface_rbc.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv $env(SNK_SIM_LOCATION)/seriallite_iii/altera_xcvr_interlaken/alt_xcvr_csr_common.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv $env(SNK_SIM_LOCATION)/seriallite_iii/altera_xcvr_interlaken/alt_xcvr_csr_pcs8g.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv $env(SNK_SIM_LOCATION)/seriallite_iii/altera_xcvr_interlaken/alt_xcvr_csr_selector.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv $env(SNK_SIM_LOCATION)/seriallite_iii/altera_xcvr_interlaken/alt_xcvr_mgmt2dec.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv $env(SNK_SIM_LOCATION)/seriallite_iii/altera_xcvr_interlaken/altera_wait_generate.v +access +w +define+ALTERA +define+SIMULATION
vlog -sv $env(SNK_SIM_LOCATION)/seriallite_iii/altera_xcvr_interlaken/alt_xcvr_interlaken_amm_slave.v +access +w +define+ALTERA +define+SIMULATION
vlog -sv $env(SNK_SIM_LOCATION)/seriallite_iii/altera_xcvr_interlaken/alt_xcvr_interlaken_soft_pbip.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv $env(SNK_SIM_LOCATION)/seriallite_iii/altera_xcvr_interlaken/sv_xcvr_interlaken_native.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv $env(SNK_SIM_LOCATION)/seriallite_iii/altera_xcvr_interlaken/sv_xcvr_interlaken_nr.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv $env(SNK_SIM_LOCATION)/seriallite_iii/altera_xcvr_interlaken/ilk_mux.v +access +w +define+ALTERA +define+SIMULATION
vlog -sv $env(SNK_SIM_LOCATION)/seriallite_iii/altera_xcvr_interlaken/altera_xcvr_interlaken.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv $env(SNK_SIM_LOCATION)/seriallite_iii/altera_xcvr_interlaken/altera_xcvr_reset_control.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv $env(SNK_SIM_LOCATION)/seriallite_iii/altera_xcvr_interlaken/alt_xcvr_reset_counter.sv +access +w +define+ALTERA +define+SIMULATION
