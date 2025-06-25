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



#derive_pll_clocks -create_base_clocks
#derive_clock_uncertainty


create_clock -period "125 MHz" -name {reconfig_xcvr_clk} {*reconfig_xcvr_clk*}
create_clock -period "125 MHz" -name {hsma_clk_out_p2} {*hsma_clk_out_p2*}
set_input_delay  -add_delay  -clock [get_clocks {altera_reserved_tck}]  20.000 [get_ports {altera_reserved_tdi}]
set_input_delay  -add_delay  -clock [get_clocks {altera_reserved_tck}]  20.000 [get_ports {altera_reserved_tms}]
#set_output_delay -add_delay  -clock [get_clocks {altera_reserved_tck}]  20.000 [get_ports {altera_reserved_tdo}]

set_false_path -from [get_ports {reconfig_xcvr_clk}] -to [get_ports {hsma_clk_out_p2}]
set_false_path -from [get_ports {perstn}]
set_false_path -from [get_ports {local_rstn}]
set_false_path -to [get_ports {L0_led}]
set_false_path -to [get_ports {alive_led}]
set_false_path -to [get_ports {comp_led}]
set_false_path -to [get_ports {gen2_led}]
set_false_path -to [get_ports {lane_active_led[0]}]
set_false_path -to [get_ports {lane_active_led[1]}]
set_false_path -to [get_ports {lane_active_led[2]}]
set_false_path -to [get_ports {lane_active_led[3]}]

# Set false path on JTAG clocks
#set_false_path -from [get_clocks {altera_reserved_tck}] -to [get_clocks *]
set_false_path -from [get_clocks {reconfig_xcvr_clk}] -to [get_clocks {altera_reserved_tck}]
set_false_path -from [get_clocks {reconfig_xcvr_clk}]  -to [get_clocks {*|altpcie_hip_256_pipen1b|stratixv_hssi_gen3_pcie_hip|coreclkout}]
set_false_path -from [get_clocks {*|altpcie_hip_256_pipen1b|stratixv_hssi_gen3_pcie_hip|coreclkout}]  -to  [get_clocks {reconfig_xcvr_clk}]
set_false_path -from [get_keepers {top:top|altera_pcie_sv_sriov_app_hwtcl:apps|altpcierd_hip_rs:rs_hip|app_rstn}] 
set_false_path -from [get_keepers {*|altera_pcie_sv_sriov_1pf32vf_ast_hwtcl:dut|altera_pcie_sv_sriov_1pf32vf:sriov_bridge|altpcierd_hip_rs:rs_hip|app_rstn}]
set_false_path -from [get_keepers {*|altpcie_sv_hip_ast_hwtcl:altpcie_sv_hip_ast_hwtcl|altpcie_hip_256_pipen1b:altpcie_hip_256_pipen1b|altpcie_rs_serdes:g_soft_reset.altpcie_rs_serdes|arst_r*}] 





