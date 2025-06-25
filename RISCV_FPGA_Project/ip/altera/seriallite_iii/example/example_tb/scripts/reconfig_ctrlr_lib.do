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


vlog -sv  $env(SRC_SIM_LOCATION)/seriallite_iii/alt_xcvr_reconfig/header/alt_xcvr_reconfig_h.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv  $env(SRC_SIM_LOCATION)/seriallite_iii/alt_xcvr_reconfig/header/sv_xcvr_dfe_cal_sweep_h.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv  $env(SRC_SIM_LOCATION)/seriallite_iii/alt_xcvr_reconfig/alt_xcvr_reconfig_basic.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv  $env(SRC_SIM_LOCATION)/seriallite_iii/alt_xcvr_reconfig/sv_reconfig_bundle_to_basic.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv  $env(SRC_SIM_LOCATION)/seriallite_iii/alt_xcvr_reconfig/alt_xcvr_arbiter.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv  $env(SRC_SIM_LOCATION)/seriallite_iii/alt_xcvr_reconfig/alt_arbiter_acq.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv  $env(SRC_SIM_LOCATION)/seriallite_iii/alt_xcvr_reconfig/alt_xcvr_resync.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv  $env(SRC_SIM_LOCATION)/seriallite_iii/alt_xcvr_reconfig/alt_xcvr_reconfig.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv  $env(SRC_SIM_LOCATION)/seriallite_iii/alt_xcvr_reconfig/alt_xcvr_reconfig_sv.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv  $env(SRC_SIM_LOCATION)/seriallite_iii/alt_xcvr_reconfig/alt_xcvr_reconfig_cal_seq.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv  $env(SRC_SIM_LOCATION)/seriallite_iii/alt_xcvr_reconfig/alt_xreconf_cif.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv  $env(SRC_SIM_LOCATION)/seriallite_iii/alt_xcvr_reconfig/alt_xreconf_uif.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv  $env(SRC_SIM_LOCATION)/seriallite_iii/alt_xcvr_reconfig/alt_xreconf_basic_acq.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv  $env(SRC_SIM_LOCATION)/seriallite_iii/alt_xcvr_reconfig/alt_xcvr_reconfig_analog.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv  $env(SRC_SIM_LOCATION)/seriallite_iii/alt_xcvr_reconfig/alt_xcvr_reconfig_analog_sv.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv  $env(SRC_SIM_LOCATION)/seriallite_iii/alt_xcvr_reconfig/alt_xreconf_analog_datactrl.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv  $env(SRC_SIM_LOCATION)/seriallite_iii/alt_xcvr_reconfig/alt_xreconf_analog_rmw.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv  $env(SRC_SIM_LOCATION)/seriallite_iii/alt_xcvr_reconfig/alt_xreconf_analog_ctrlsm.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv  $env(SRC_SIM_LOCATION)/seriallite_iii/alt_xcvr_reconfig/alt_xcvr_reconfig_offset_cancellation.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv  $env(SRC_SIM_LOCATION)/seriallite_iii/alt_xcvr_reconfig/alt_xcvr_reconfig_offset_cancellation_sv.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv  $env(SRC_SIM_LOCATION)/seriallite_iii/alt_xcvr_reconfig/alt_xcvr_reconfig_eyemon.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv  $env(SRC_SIM_LOCATION)/seriallite_iii/alt_xcvr_reconfig/alt_xcvr_reconfig_eyemon_sv.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv  $env(SRC_SIM_LOCATION)/seriallite_iii/alt_xcvr_reconfig/alt_xcvr_reconfig_eyemon_ctrl_sv.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv  $env(SRC_SIM_LOCATION)/seriallite_iii/alt_xcvr_reconfig/step_to_mon_sv.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv  $env(SRC_SIM_LOCATION)/seriallite_iii/alt_xcvr_reconfig/mon_to_step_sv.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv  $env(SRC_SIM_LOCATION)/seriallite_iii/alt_xcvr_reconfig/alt_xcvr_reconfig_dfe.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv  $env(SRC_SIM_LOCATION)/seriallite_iii/alt_xcvr_reconfig/alt_xcvr_reconfig_dfe_sv.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv  $env(SRC_SIM_LOCATION)/seriallite_iii/alt_xcvr_reconfig/alt_xcvr_reconfig_dfe_reg_sv.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv  $env(SRC_SIM_LOCATION)/seriallite_iii/alt_xcvr_reconfig/alt_xcvr_reconfig_dfe_cal_sv.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv  $env(SRC_SIM_LOCATION)/seriallite_iii/alt_xcvr_reconfig/alt_xcvr_reconfig_dfe_cal_sweep_sv.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv  $env(SRC_SIM_LOCATION)/seriallite_iii/alt_xcvr_reconfig/alt_xcvr_reconfig_dfe_cal_sweep_datapath_sv.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv  $env(SRC_SIM_LOCATION)/seriallite_iii/alt_xcvr_reconfig/alt_xcvr_reconfig_dfe_oc_cal_sv.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv  $env(SRC_SIM_LOCATION)/seriallite_iii/alt_xcvr_reconfig/alt_xcvr_reconfig_dfe_pi_phase_sv.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv  $env(SRC_SIM_LOCATION)/seriallite_iii/alt_xcvr_reconfig/alt_xcvr_reconfig_dfe_step_to_mon_en_sv.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv  $env(SRC_SIM_LOCATION)/seriallite_iii/alt_xcvr_reconfig/alt_xcvr_reconfig_dfe_ctrl_mux_sv.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv  $env(SRC_SIM_LOCATION)/seriallite_iii/alt_xcvr_reconfig/alt_xcvr_reconfig_dfe_local_reset_sv.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv  $env(SRC_SIM_LOCATION)/seriallite_iii/alt_xcvr_reconfig/alt_xcvr_reconfig_adce.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv  $env(SRC_SIM_LOCATION)/seriallite_iii/alt_xcvr_reconfig/alt_xcvr_reconfig_adce_sv.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv  $env(SRC_SIM_LOCATION)/seriallite_iii/alt_xcvr_reconfig/alt_xcvr_reconfig_adce_datactrl_sv.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv  $env(SRC_SIM_LOCATION)/seriallite_iii/alt_xcvr_reconfig/alt_xcvr_reconfig_dcd.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv  $env(SRC_SIM_LOCATION)/seriallite_iii/alt_xcvr_reconfig/alt_xcvr_reconfig_dcd_sv.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv  $env(SRC_SIM_LOCATION)/seriallite_iii/alt_xcvr_reconfig/alt_xcvr_reconfig_dcd_cal.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv  $env(SRC_SIM_LOCATION)/seriallite_iii/alt_xcvr_reconfig/alt_xcvr_reconfig_dcd_control.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv  $env(SRC_SIM_LOCATION)/seriallite_iii/alt_xcvr_reconfig/alt_xcvr_reconfig_dcd_datapath.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv  $env(SRC_SIM_LOCATION)/seriallite_iii/alt_xcvr_reconfig/alt_xcvr_reconfig_dcd_pll_reset.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv  $env(SRC_SIM_LOCATION)/seriallite_iii/alt_xcvr_reconfig/alt_xcvr_reconfig_dcd_eye_width.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv  $env(SRC_SIM_LOCATION)/seriallite_iii/alt_xcvr_reconfig/alt_xcvr_reconfig_dcd_align_clk.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv  $env(SRC_SIM_LOCATION)/seriallite_iii/alt_xcvr_reconfig/alt_xcvr_reconfig_dcd_get_sum.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv  $env(SRC_SIM_LOCATION)/seriallite_iii/alt_xcvr_reconfig/alt_xcvr_reconfig_dcd_cal_sim_model.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv  $env(SRC_SIM_LOCATION)/seriallite_iii/alt_xcvr_reconfig/alt_xcvr_reconfig_mif.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv  $env(SRC_SIM_LOCATION)/seriallite_iii/alt_xcvr_reconfig/sv_xcvr_reconfig_mif.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv  $env(SRC_SIM_LOCATION)/seriallite_iii/alt_xcvr_reconfig/sv_xcvr_reconfig_mif_ctrl.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv  $env(SRC_SIM_LOCATION)/seriallite_iii/alt_xcvr_reconfig/sv_xcvr_reconfig_mif_avmm.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv  $env(SRC_SIM_LOCATION)/seriallite_iii/alt_xcvr_reconfig/alt_xcvr_reconfig_pll.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv  $env(SRC_SIM_LOCATION)/seriallite_iii/alt_xcvr_reconfig/sv_xcvr_reconfig_pll.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv  $env(SRC_SIM_LOCATION)/seriallite_iii/alt_xcvr_reconfig/sv_xcvr_reconfig_pll_ctrl.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv  $env(SRC_SIM_LOCATION)/seriallite_iii/alt_xcvr_reconfig/alt_xcvr_reconfig_soc.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv  $env(SRC_SIM_LOCATION)/seriallite_iii/alt_xcvr_reconfig/alt_xcvr_reconfig_cpu_ram.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv  $env(SRC_SIM_LOCATION)/seriallite_iii/alt_xcvr_reconfig/alt_xcvr_reconfig_direct.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv  $env(SRC_SIM_LOCATION)/seriallite_iii/alt_xcvr_reconfig/sv_xrbasic_l2p_addr.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv  $env(SRC_SIM_LOCATION)/seriallite_iii/alt_xcvr_reconfig/sv_xrbasic_l2p_ch.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv  $env(SRC_SIM_LOCATION)/seriallite_iii/alt_xcvr_reconfig/sv_xrbasic_l2p_rom.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv  $env(SRC_SIM_LOCATION)/seriallite_iii/alt_xcvr_reconfig/sv_xrbasic_lif_csr.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv  $env(SRC_SIM_LOCATION)/seriallite_iii/alt_xcvr_reconfig/sv_xrbasic_lif.sv +access +w +define+ALTERA +define+SIMULATION
vlog -sv  $env(SRC_SIM_LOCATION)/seriallite_iii/alt_xcvr_reconfig/sv_xcvr_reconfig_basic.sv +access +w +define+ALTERA +define+SIMULATION
