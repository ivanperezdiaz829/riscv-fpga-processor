set quartus_rootdir "$env(QUARTUS_ROOTDIR)"

vlib work

# Quartus libraries
vlog $quartus_rootdir/libraries/megafunctions/alt_cal_sv.v
vlog -sv +define+GENERIC_PLL_TIMESCALE_100_FS=1 $quartus_rootdir/eda/sim_lib/altera_lnsim.sv
vlog $quartus_rootdir/eda/sim_lib/altera_primitives.v
vlog $quartus_rootdir/eda/sim_lib/220model.v
vlog $quartus_rootdir/eda/sim_lib/sgate.v
vlog $quartus_rootdir/eda/sim_lib/altera_mf.v
vlog $quartus_rootdir/eda/sim_lib/stratixv_hssi_atoms.v
vlog $quartus_rootdir/eda/sim_lib/mentor/stratixv_hssi_atoms_ncrypt.v

# Custom PHY files
vlog ../testbench/xcvr/altera_xcvr_functions.sv
vlog ../testbench/xcvr/alt_xcvr_csr_common_h.sv
vlog ../testbench/xcvr/alt_xcvr_csr_pcs8g_h.sv
vlog ../testbench/xcvr/sv_xcvr_h.sv
vlog ../testbench/xcvr/altera_xcvr_custom.sv
vlog ../testbench/xcvr/alt_reset_ctrl_lego.sv
vlog ../testbench/xcvr/alt_reset_ctrl_tgx_cdrauto.sv
vlog ../testbench/xcvr/alt_xcvr_arbiter.sv
vlog ../testbench/xcvr/alt_xcvr_csr_common_h.sv
vlog ../testbench/xcvr/alt_xcvr_csr_common.sv
vlog ../testbench/xcvr/alt_xcvr_csr_pcs8g_h.sv
vlog ../testbench/xcvr/alt_xcvr_csr_pcs8g.sv
vlog ../testbench/xcvr/alt_xcvr_csr_selector.sv
vlog ../testbench/xcvr/alt_xcvr_m2s.sv
vlog ../testbench/xcvr/alt_xcvr_mgmt2dec.sv
vlog ../testbench/xcvr/alt_xcvr_resync.sv
vlog ../testbench/xcvr/stratixv_hssi_10g_rx_pcs_rbc.sv
vlog ../testbench/xcvr/stratixv_hssi_10g_tx_pcs_rbc.sv
vlog ../testbench/xcvr/stratixv_hssi_8g_pcs_aggregate_rbc.sv
vlog ../testbench/xcvr/stratixv_hssi_8g_rx_pcs_rbc.sv
vlog ../testbench/xcvr/stratixv_hssi_8g_tx_pcs_rbc.sv
vlog ../testbench/xcvr/stratixv_hssi_common_pcs_pma_interface_rbc.sv
vlog ../testbench/xcvr/stratixv_hssi_common_pld_pcs_interface_rbc.sv
vlog ../testbench/xcvr/stratixv_hssi_pipe_gen1_2_rbc.sv
vlog ../testbench/xcvr/stratixv_hssi_pipe_gen3_rbc.sv
vlog ../testbench/xcvr/stratixv_hssi_rx_pcs_pma_interface_rbc.sv
vlog ../testbench/xcvr/stratixv_hssi_rx_pld_pcs_interface_rbc.sv
vlog ../testbench/xcvr/stratixv_hssi_tx_pcs_pma_interface_rbc.sv
vlog ../testbench/xcvr/stratixv_hssi_tx_pld_pcs_interface_rbc.sv
vlog ../testbench/xcvr/sv_pcs_ch.sv
vlog ../testbench/xcvr/sv_pcs.sv
vlog ../testbench/xcvr/sv_pma.sv
vlog ../testbench/xcvr/sv_reconfig_bundle_merger.sv
vlog ../testbench/xcvr/sv_reconfig_bundle_to_ip.sv
vlog ../testbench/xcvr/sv_reconfig_bundle_to_xcvr.sv
vlog ../testbench/xcvr/sv_rx_pma.sv
vlog ../testbench/xcvr/sv_tx_pma_ch.sv
vlog ../testbench/xcvr/sv_tx_pma.sv
vlog ../testbench/xcvr/sv_xcvr_avmm_csr.sv
vlog ../testbench/xcvr/sv_xcvr_avmm_dcd.sv
vlog ../testbench/xcvr/sv_xcvr_avmm.sv
vlog ../testbench/xcvr/sv_xcvr_custom_native.sv
vlog ../testbench/xcvr/sv_xcvr_custom_nr.sv
vlog ../testbench/xcvr/sv_xcvr_data_adapter.sv
vlog ../testbench/xcvr/sv_xcvr_native.sv
vlog ../testbench/xcvr/sv_xcvr_plls.sv

# Reconfig and pattern gen files
vlog ../testbench/reconfig/alt_xcvr_reconfig_h.sv
vlog ../testbench/reconfig/*.sv
vlog ../testbench/reconfig/*.v
vlog ../testbench/pattern_gen/*.v

# SDI simulation model
vlog ../testbench/sdi_mc_build/*.vo

# Testbench
vlog ../testbench/tb_sdi_megacore_top.v

vsim -novopt work.tb_sdi_megacore_top -L work
do wave.do
set StdArithNoWarnings 1
run -all

