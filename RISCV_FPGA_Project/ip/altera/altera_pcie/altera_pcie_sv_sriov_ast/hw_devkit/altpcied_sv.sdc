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


# derive_pll_clock is used to calculate all clock derived from PCIe refclk
#  the derive_pll_clocks and derive clock_uncertainty should only
# be applied once across all of the SDC files used in a project
derive_pll_clocks -create_base_clocks
derive_clock_uncertainty

##############################################################################
# PHY IP reconfig controller constraints
# Set reconfig_xcvr clock
# this line will likely need to be modified to match the actual clock pin name
# used for this clock, and also changed to have the correct period set for the actually used clock
create_clock -period "125 MHz" -name {reconfig_xcvr_clk} {*reconfig_xcvr_clk*}

######################################################################
# HIP Soft reset controller SDC constraints
set_false_path -from [get_registers *sv_xcvr_pipe_native*] -to [get_registers *altpcie_rs_serdes|*]

# HIP testin pins SDC constraints
set_false_path -from [get_pins -compatibility_mode *hip_ctrl*]

######################################################################
# Constraints for CV SIG asynchonous logic
set_false_path -from [get_keepers {*|altpcie_hip_256_pipen1b:altpcie_hip_256_pipen1b|hip_eq_dprio:sigtesten.hip_eq_dprio_inst|altpcie_hip_vecsync2:vecsync_ltssm|altpcie_hip_vecsync:altpcie_hip_vecsync2|data_in_d0[*]}] -to [get_keepers {*|altpcie_hip_256_pipen1b:altpcie_hip_256_pipen1b|hip_eq_dprio:sigtesten.hip_eq_dprio_inst|altpcie_hip_vecsync2:vecsync_ltssm|altpcie_hip_vecsync:altpcie_hip_vecsync2|data_out[*]}]

set_false_path -from [get_keepers {*|altpcie_hip_256_pipen1b:altpcie_hip_256_pipen1b|hip_eq_dprio:sigtesten.hip_eq_dprio_inst|altpcie_hip_vecsync2:vecsync_ltssm|altpcie_hip_vecsync:altpcie_hip_vecsync2|req_wr_clk}] -to [get_keepers {*|altpcie_hip_256_pipen1b:altpcie_hip_256_pipen1b|hip_eq_dprio:sigtesten.hip_eq_dprio_inst|altpcie_hip_vecsync2:vecsync_ltssm|altpcie_hip_vecsync:altpcie_hip_vecsync2|altpcie_hip_bitsync:u_req_rd_clk|sync_regs[*]}]

set_false_path -from [get_keepers {*|altpcie_hip_256_pipen1b:altpcie_hip_256_pipen1b|hip_eq_dprio:sigtesten.hip_eq_dprio_inst|altpcie_hip_vecsync2:vecsync_tls|altpcie_hip_vecsync:altpcie_hip_vecsync2|req_rd_clk_d0}] -to [get_keepers {*|altpcie_hip_256_pipen1b:altpcie_hip_256_pipen1b|hip_eq_dprio:sigtesten.hip_eq_dprio_inst|altpcie_hip_vecsync2:vecsync_tls|altpcie_hip_vecsync:altpcie_hip_vecsync2|altpcie_hip_bitsync:u_ack_wr_clk|sync_regs[*]}]

set_false_path -from [get_keepers {*|altpcie_hip_256_pipen1b:altpcie_hip_256_pipen1b|hip_eq_dprio:sigtesten.hip_eq_dprio_inst|altpcie_hip_vecsync2:vecsync_tls|altpcie_hip_vecsync:altpcie_hip_vecsync2|req_wr_clk}] -to [get_keepers {*|altpcie_hip_256_pipen1b:altpcie_hip_256_pipen1b|hip_eq_dprio:sigtesten.hip_eq_dprio_inst|altpcie_hip_vecsync2:vecsync_tls|altpcie_hip_vecsync:altpcie_hip_vecsync2|altpcie_hip_bitsync:u_req_rd_clk|sync_regs[*]}]

set_false_path -from [get_keepers {*|altpcie_hip_256_pipen1b:altpcie_hip_256_pipen1b|hip_eq_dprio:sigtesten.hip_eq_dprio_inst|altpcie_hip_vecsync2:vecsync_tls|altpcie_hip_vecsync:altpcie_hip_vecsync2|data_in_d0[*]}] -to [get_keepers {*|altpcie_hip_256_pipen1b:altpcie_hip_256_pipen1b|hip_eq_dprio:sigtesten.hip_eq_dprio_inst|altpcie_hip_vecsync2:vecsync_tls|altpcie_hip_vecsync:altpcie_hip_vecsync2|data_out[*]}]

set_false_path -from [get_keepers {*|altpcie_hip_256_pipen1b:altpcie_hip_256_pipen1b|hip_eq_dprio:sigtesten.hip_eq_dprio_inst|altpcie_hip_vecsync2:vecsync_ltssm|altpcie_hip_vecsync:altpcie_hip_vecsync2|req_rd_clk_d0}] -to [get_keepers {*|altpcie_hip_256_pipen1b:altpcie_hip_256_pipen1b|hip_eq_dprio:sigtesten.hip_eq_dprio_inst|altpcie_hip_vecsync2:vecsync_ltssm|altpcie_hip_vecsync:altpcie_hip_vecsync2|altpcie_hip_bitsync:u_ack_wr_clk|sync_regs[*]}]


set_false_path -from [get_keepers {*|altpcie_hip_256_pipen1b:altpcie_hip_256_pipen1b|stratixv_hssi_gen3_pcie_hip~SYNC_DATA_REG122}] -to [get_keepers {*|altpcie_sv_hip_ast_hwtcl:altpcie_sv_hip_ast_hwtcl|altpcie_hip_256_pipen1b:altpcie_hip_256_pipen1b|test_out_r[*]}]


######################################################################
# Constraint to add more margin into the design
#set_clock_uncertainty -add -setup 0.55 -from {*|altpcie_hip_256_pipen1b|stratixv_hssi_gen3_pcie_hip|coreclkout} -to {*|altpcie_hip_256_pipen1b|stratixv_hssi_gen3_pcie_hip|coreclkout} 


