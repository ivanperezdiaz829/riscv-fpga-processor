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



# ----------------------------------------
# vsim - simulation script for alt_e40_avalon_kr4_tb

# ----------------------------------------
# copy RAM/ROM files to simulation directory

foreach ram_file [glob -nocomplain ../example/common/alt_e40_e_reco/alt_e40_e_reco/*.mif] {
    file copy -force -- $ram_file .
}
foreach ram_file [glob -nocomplain ../example/common/alt_e40_e_reco/alt_e40_e_reco/*.hex] {
    file copy -force -- $ram_file .
}
foreach ram_file [glob -nocomplain ../example/common/com_design_ex/*.mif] {
    file copy -force -- $ram_file .
}

set TOP_LEVEL_NAME "alt_e40_avalon_kr4_tb"
set QUARTUS_INSTALL_DIR $env(QUARTUS_ROOTDIR)
set QSYS_SIMDIR ../../../ENET_ENTITY_QMEGA_06072013_sim

do $QSYS_SIMDIR/aldec/rivierapro_setup.tcl

dev_com
com

vlog +acc -sv ../example/common/alt_e40_e_reco/alt_e40_e_reco.v
vlog +acc -sv ../example/common/alt_e40_e_reco/alt_e40_e_reco/altera_xcvr_functions.sv
vlog +acc -sv ../example/common/alt_e40_e_reco/alt_e40_e_reco/sv_xcvr_h.sv
vlog +acc -sv ../example/common/alt_e40_e_reco/alt_e40_e_reco/alt_xcvr_resync.sv
vlog +acc -sv ../example/common/alt_e40_e_reco/alt_e40_e_reco/alt_xcvr_reconfig_h.sv
vlog +acc -sv ../example/common/alt_e40_e_reco/alt_e40_e_reco/sv_xcvr_dfe_cal_sweep_h.sv
vlog +acc -sv ../example/common/alt_e40_e_reco/alt_e40_e_reco/alt_xcvr_reconfig.sv
vlog +acc -sv ../example/common/alt_e40_e_reco/alt_e40_e_reco/alt_xcvr_reconfig_sv.sv
vlog +acc -sv ../example/common/alt_e40_e_reco/alt_e40_e_reco/alt_xcvr_reconfig_cal_seq.sv
vlog +acc -sv ../example/common/alt_e40_e_reco/alt_e40_e_reco/alt_xreconf_cif.sv
vlog +acc -sv ../example/common/alt_e40_e_reco/alt_e40_e_reco/alt_xreconf_uif.sv
vlog +acc -sv ../example/common/alt_e40_e_reco/alt_e40_e_reco/alt_xreconf_basic_acq.sv
vlog +acc -sv ../example/common/alt_e40_e_reco/alt_e40_e_reco/alt_xcvr_reconfig_analog.sv
vlog +acc -sv ../example/common/alt_e40_e_reco/alt_e40_e_reco/alt_xcvr_reconfig_analog_sv.sv
vlog +acc -sv ../example/common/alt_e40_e_reco/alt_e40_e_reco/alt_xreconf_analog_datactrl.sv
vlog +acc -sv ../example/common/alt_e40_e_reco/alt_e40_e_reco/alt_xreconf_analog_rmw.sv
vlog +acc -sv ../example/common/alt_e40_e_reco/alt_e40_e_reco/alt_xreconf_analog_ctrlsm.sv
vlog +acc -sv ../example/common/alt_e40_e_reco/alt_e40_e_reco/alt_xcvr_reconfig_offset_cancellation.sv
vlog +acc -sv ../example/common/alt_e40_e_reco/alt_e40_e_reco/alt_xcvr_reconfig_offset_cancellation_sv.sv
vlog +acc -sv ../example/common/alt_e40_e_reco/alt_e40_e_reco/alt_xcvr_reconfig_eyemon.sv
vlog +acc -sv ../example/common/alt_e40_e_reco/alt_e40_e_reco/alt_xcvr_reconfig_eyemon_sv.sv
vlog +acc -sv ../example/common/alt_e40_e_reco/alt_e40_e_reco/alt_xcvr_reconfig_eyemon_ctrl_sv.sv
vlog +acc -sv ../example/common/alt_e40_e_reco/alt_e40_e_reco/alt_xcvr_reconfig_eyemon_ber_sv.sv
vlog +acc -sv ../example/common/alt_e40_e_reco/alt_e40_e_reco/ber_reader_dcfifo.v
vlog +acc -sv ../example/common/alt_e40_e_reco/alt_e40_e_reco/step_to_mon_sv.sv
vlog +acc -sv ../example/common/alt_e40_e_reco/alt_e40_e_reco/mon_to_step_sv.sv
vlog +acc -sv ../example/common/alt_e40_e_reco/alt_e40_e_reco/alt_xcvr_reconfig_dfe.sv
vlog +acc -sv ../example/common/alt_e40_e_reco/alt_e40_e_reco/alt_xcvr_reconfig_dfe_sv.sv
vlog +acc -sv ../example/common/alt_e40_e_reco/alt_e40_e_reco/alt_xcvr_reconfig_dfe_reg_sv.sv
vlog +acc -sv ../example/common/alt_e40_e_reco/alt_e40_e_reco/alt_xcvr_reconfig_dfe_cal_sv.sv
vlog +acc -sv ../example/common/alt_e40_e_reco/alt_e40_e_reco/alt_xcvr_reconfig_dfe_cal_sweep_sv.sv
vlog +acc -sv ../example/common/alt_e40_e_reco/alt_e40_e_reco/alt_xcvr_reconfig_dfe_cal_sweep_datapath_sv.sv
vlog +acc -sv ../example/common/alt_e40_e_reco/alt_e40_e_reco/alt_xcvr_reconfig_dfe_oc_cal_sv.sv
vlog +acc -sv ../example/common/alt_e40_e_reco/alt_e40_e_reco/alt_xcvr_reconfig_dfe_pi_phase_sv.sv
vlog +acc -sv ../example/common/alt_e40_e_reco/alt_e40_e_reco/alt_xcvr_reconfig_dfe_step_to_mon_en_sv.sv
vlog +acc -sv ../example/common/alt_e40_e_reco/alt_e40_e_reco/alt_xcvr_reconfig_dfe_adapt_tap_sv.sv
vlog +acc -sv ../example/common/alt_e40_e_reco/alt_e40_e_reco/alt_xcvr_reconfig_dfe_ctrl_mux_sv.sv
vlog +acc -sv ../example/common/alt_e40_e_reco/alt_e40_e_reco/alt_xcvr_reconfig_dfe_local_reset_sv.sv
vlog +acc -sv ../example/common/alt_e40_e_reco/alt_e40_e_reco/alt_xcvr_reconfig_dfe_cal_sim_sv.sv
vlog +acc -sv ../example/common/alt_e40_e_reco/alt_e40_e_reco/alt_xcvr_reconfig_dfe_adapt_tap_sim_sv.sv
vlog +acc -sv ../example/common/alt_e40_e_reco/alt_e40_e_reco/alt_xcvr_reconfig_adce.sv
vlog +acc -sv ../example/common/alt_e40_e_reco/alt_e40_e_reco/alt_xcvr_reconfig_adce_sv.sv
vlog +acc -sv ../example/common/alt_e40_e_reco/alt_e40_e_reco/alt_xcvr_reconfig_adce_datactrl_sv.sv
vlog +acc -sv ../example/common/alt_e40_e_reco/alt_e40_e_reco/alt_xcvr_reconfig_dcd.sv
vlog +acc -sv ../example/common/alt_e40_e_reco/alt_e40_e_reco/alt_xcvr_reconfig_dcd_sv.sv
vlog +acc -sv ../example/common/alt_e40_e_reco/alt_e40_e_reco/alt_xcvr_reconfig_dcd_cal.sv
vlog +acc -sv ../example/common/alt_e40_e_reco/alt_e40_e_reco/alt_xcvr_reconfig_dcd_control.sv
vlog +acc -sv ../example/common/alt_e40_e_reco/alt_e40_e_reco/alt_xcvr_reconfig_dcd_datapath.sv
vlog +acc -sv ../example/common/alt_e40_e_reco/alt_e40_e_reco/alt_xcvr_reconfig_dcd_pll_reset.sv
vlog +acc -sv ../example/common/alt_e40_e_reco/alt_e40_e_reco/alt_xcvr_reconfig_dcd_eye_width.sv
vlog +acc -sv ../example/common/alt_e40_e_reco/alt_e40_e_reco/alt_xcvr_reconfig_dcd_align_clk.sv
vlog +acc -sv ../example/common/alt_e40_e_reco/alt_e40_e_reco/alt_xcvr_reconfig_dcd_get_sum.sv
vlog +acc -sv ../example/common/alt_e40_e_reco/alt_e40_e_reco/alt_xcvr_reconfig_dcd_cal_sim_model.sv
vlog +acc -sv ../example/common/alt_e40_e_reco/alt_e40_e_reco/alt_xcvr_reconfig_mif.sv
vlog +acc -sv ../example/common/alt_e40_e_reco/alt_e40_e_reco/sv_xcvr_reconfig_mif.sv
vlog +acc -sv ../example/common/alt_e40_e_reco/alt_e40_e_reco/sv_xcvr_reconfig_mif_ctrl.sv
vlog +acc -sv ../example/common/alt_e40_e_reco/alt_e40_e_reco/sv_xcvr_reconfig_mif_avmm.sv
vlog +acc -sv ../example/common/alt_e40_e_reco/alt_e40_e_reco/alt_xcvr_reconfig_pll.sv
vlog +acc -sv ../example/common/alt_e40_e_reco/alt_e40_e_reco/sv_xcvr_reconfig_pll.sv
vlog +acc -sv ../example/common/alt_e40_e_reco/alt_e40_e_reco/sv_xcvr_reconfig_pll_ctrl.sv
vlog +acc -sv ../example/common/alt_e40_e_reco/alt_e40_e_reco/alt_xcvr_reconfig_soc.sv
vlog +acc -sv ../example/common/alt_e40_e_reco/alt_e40_e_reco/alt_xcvr_reconfig_cpu_ram.sv
vlog +acc -sv ../example/common/alt_e40_e_reco/alt_e40_e_reco/alt_xcvr_reconfig_direct.sv
vlog +acc -sv ../example/common/alt_e40_e_reco/alt_e40_e_reco/sv_xrbasic_l2p_addr.sv
vlog +acc -sv ../example/common/alt_e40_e_reco/alt_e40_e_reco/sv_xrbasic_l2p_ch.sv
vlog +acc -sv ../example/common/alt_e40_e_reco/alt_e40_e_reco/sv_xrbasic_l2p_rom.sv
vlog +acc -sv ../example/common/alt_e40_e_reco/alt_e40_e_reco/sv_xrbasic_lif_csr.sv
vlog +acc -sv ../example/common/alt_e40_e_reco/alt_e40_e_reco/sv_xrbasic_lif.sv
vlog +acc -sv ../example/common/alt_e40_e_reco/alt_e40_e_reco/sv_xcvr_reconfig_basic.sv
vlog +acc -sv ../example/common/alt_e40_e_reco/alt_e40_e_reco/alt_arbiter_acq.sv
vlog +acc -sv ../example/common/alt_e40_e_reco/alt_e40_e_reco/alt_xcvr_reconfig_basic.sv
vlog +acc -sv ../example/common/alt_e40_e_reco/alt_e40_e_reco/alt_xcvr_arbiter.sv
vlog +acc -sv ../example/common/alt_e40_e_reco/alt_e40_e_reco/alt_xcvr_m2s.sv
vlog +acc -sv ../example/common/alt_e40_e_reco/alt_e40_e_reco/sv_reconfig_bundle_to_basic.sv
vlog +acc -sv ../example/common/alt_e40_e_reco/alt_e40_e_reco/alt_xcvr_reconfig_cpu.v
vlog +acc -sv ../example/common/alt_e40_e_reco/alt_e40_e_reco/alt_xcvr_reconfig_cpu_reconfig_cpu.v
vlog +acc -sv ../example/common/alt_e40_e_reco/alt_e40_e_reco/alt_xcvr_reconfig_cpu_reconfig_cpu_test_bench.v
vlog +acc -sv ../example/common/alt_e40_e_reco/alt_e40_e_reco/altera_merlin_master_translator.sv
vlog +acc -sv ../example/common/alt_e40_e_reco/alt_e40_e_reco/altera_merlin_slave_translator.sv
vlog +acc -sv ../example/common/alt_e40_e_reco/alt_e40_e_reco/altera_merlin_master_agent.sv
vlog +acc -sv ../example/common/alt_e40_e_reco/alt_e40_e_reco/altera_merlin_slave_agent.sv
vlog +acc -sv ../example/common/alt_e40_e_reco/alt_e40_e_reco/altera_merlin_burst_uncompressor.sv
vlog +acc -sv ../example/common/alt_e40_e_reco/alt_e40_e_reco/altera_avalon_sc_fifo.v
vlog +acc -sv ../example/common/alt_e40_e_reco/alt_e40_e_reco/alt_xcvr_reconfig_cpu_addr_router.sv
vlog +acc -sv ../example/common/alt_e40_e_reco/alt_e40_e_reco/alt_xcvr_reconfig_cpu_addr_router_001.sv
vlog +acc -sv ../example/common/alt_e40_e_reco/alt_e40_e_reco/alt_xcvr_reconfig_cpu_id_router.sv
vlog +acc -sv ../example/common/alt_e40_e_reco/alt_e40_e_reco/alt_xcvr_reconfig_cpu_id_router_001.sv
vlog +acc -sv ../example/common/alt_e40_e_reco/alt_e40_e_reco/altera_reset_controller.v
vlog +acc -sv ../example/common/alt_e40_e_reco/alt_e40_e_reco/altera_reset_synchronizer.v
vlog +acc -sv ../example/common/alt_e40_e_reco/alt_e40_e_reco/alt_xcvr_reconfig_cpu_cmd_xbar_demux.sv
vlog +acc -sv ../example/common/alt_e40_e_reco/alt_e40_e_reco/alt_xcvr_reconfig_cpu_cmd_xbar_demux_001.sv
vlog +acc -sv ../example/common/alt_e40_e_reco/alt_e40_e_reco/altera_merlin_arbitrator.sv
vlog +acc -sv ../example/common/alt_e40_e_reco/alt_e40_e_reco/alt_xcvr_reconfig_cpu_cmd_xbar_mux.sv
vlog +acc -sv ../example/common/alt_e40_e_reco/alt_e40_e_reco/alt_xcvr_reconfig_cpu_rsp_xbar_mux.sv
vlog +acc -sv ../example/common/alt_e40_e_reco/alt_e40_e_reco/alt_xcvr_reconfig_cpu_irq_mapper.sv

vlog +acc -sv ../example/common/com_design_ex/arbiter.v
vlog +acc -sv ../example/common/com_design_ex/channel_sel.sv
vlog +acc -sv ../example/common/com_design_ex/ctle_states.sv
vlog +acc -sv ../example/common/com_design_ex/dfe_states.sv
vlog +acc -sv ../example/common/com_design_ex/mgmt_memory_map.sv
vlog +acc -sv ../example/common/com_design_ex/mif_states.sv
vlog +acc -sv ../example/common/com_design_ex/pma_states.sv
vlog +acc -sv ../example/common/com_design_ex/reconfig_master.sv
vlog +acc -sv ../example/common/com_design_ex/rom_all_modes.v
vlog +acc -sv ../example/common/com_design_ex/sv_rcn_bundle.sv
vlog +acc -sv ../example/common/com_design_ex/user_avmm_if_sm.sv
vlog +acc -sv ../example/common/com_design_ex/user_reconfig_access.sv

vlog +acc -sv ./alt_e40_avalon_kr4_tb.sv
vlog +acc -sv ./alt_e40_avalon_tb_packet_gen.v
vlog +acc -sv ./alt_e40_avalon_tb_packet_gen_sanity_check.v
vlog +acc -sv ./alt_e40_avalon_tb_sample_tx_rom.v

elab

#UNCOMMENT FOLLOWING FOR WAVEFORMS
#add wave *
#add wave alt_40gbe_tb/dut/*
run -all
quit
