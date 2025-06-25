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



proc add_tbed_pcie_parameters_ui {} {

   send_message debug "proc:add_tbed_pcie_parameters_ui"

   set group_name "Testbench parameters"
   # Gen1/Gen2
   add_parameter          lane_mask_hwtcl string "x4"
   set_parameter_property lane_mask_hwtcl DISPLAY_NAME "Lanes"
   set_parameter_property lane_mask_hwtcl ALLOWED_RANGES {"x1" "x2" "x4" "x8"}
   set_parameter_property lane_mask_hwtcl GROUP $group_name
   set_parameter_property lane_mask_hwtcl VISIBLE true
   set_parameter_property lane_mask_hwtcl HDL_PARAMETER true

   # Gen1/Gen2
   add_parameter          gen123_lane_rate_mode_hwtcl string "Gen1 (2.5 Gbps)"
   set_parameter_property gen123_lane_rate_mode_hwtcl DISPLAY_NAME "Reference clock"
   set_parameter_property gen123_lane_rate_mode_hwtcl ALLOWED_RANGES {"Gen1 (2.5 Gbps)" "Gen2 (5.0 Gbps)" "Gen3 (8.0 Gbps)"}
   set_parameter_property gen123_lane_rate_mode_hwtcl GROUP $group_name
   set_parameter_property gen123_lane_rate_mode_hwtcl VISIBLE true
   set_parameter_property gen123_lane_rate_mode_hwtcl HDL_PARAMETER true

   # Port Type
   add_parameter          port_type_hwtcl string "Native endpoint"
   set_parameter_property port_type_hwtcl DISPLAY_NAME "Port type"
   set_parameter_property port_type_hwtcl ALLOWED_RANGES {"Native endpoint" "Legacy endpoint" "Root port"}
   set_parameter_property port_type_hwtcl GROUP $group_name
   set_parameter_property port_type_hwtcl VISIBLE true
   set_parameter_property port_type_hwtcl HDL_PARAMETER true

   # Ref clk
   add_parameter          pll_refclk_freq_hwtcl string "100 MHz"
   set_parameter_property pll_refclk_freq_hwtcl DISPLAY_NAME "Reference clock"
   set_parameter_property pll_refclk_freq_hwtcl ALLOWED_RANGES {"100 MHz" "125 MHz"}
   set_parameter_property pll_refclk_freq_hwtcl GROUP $group_name
   set_parameter_property pll_refclk_freq_hwtcl VISIBLE true
   set_parameter_property pll_refclk_freq_hwtcl HDL_PARAMETER true

   # Application Type
   add_parameter          apps_type_hwtcl integer 1
   set_parameter_property apps_type_hwtcl DISPLAY_NAME "Testbench runs"
   set_parameter_property apps_type_hwtcl ALLOWED_RANGES {"1:Link training and configuration" "2:Link training, configuration and chaining DMA" "3:Link training, configuration and target" "4:Avalon-MM"}
   set_parameter_property apps_type_hwtcl GROUP $group_name
   set_parameter_property apps_type_hwtcl VISIBLE false
   set_parameter_property apps_type_hwtcl HDL_PARAMETER true

   # Application Type
   add_parameter          serial_sim_hwtcl integer 1
   set_parameter_property serial_sim_hwtcl DISPLAY_NAME "Simulation type"
   set_parameter_property serial_sim_hwtcl ALLOWED_RANGES {"0:PIPE Simulation" "1:Serial Simulation"}
   set_parameter_property serial_sim_hwtcl GROUP $group_name
   set_parameter_property serial_sim_hwtcl VISIBLE true
   set_parameter_property serial_sim_hwtcl HDL_PARAMETER true

   # Application Type
   add_parameter          enable_pipe32_sim_hwtcl integer 1
   set_parameter_property enable_pipe32_sim_hwtcl DISPLAY_NAME "Enable HIP PIPE 32-bit simulation"
   set_parameter_property enable_pipe32_sim_hwtcl ALLOWED_RANGES {"0:PIPE Simulation 8-bit " "1:PIPE Simulation 32-bit"}
   set_parameter_property enable_pipe32_sim_hwtcl GROUP $group_name
   set_parameter_property enable_pipe32_sim_hwtcl VISIBLE true
   set_parameter_property enable_pipe32_sim_hwtcl HDL_PARAMETER true

   add_parameter          enable_tl_only_sim_hwtcl integer 0
   set_parameter_property enable_tl_only_sim_hwtcl GROUP $group_name
   set_parameter_property enable_tl_only_sim_hwtcl VISIBLE false
   set_parameter_property enable_tl_only_sim_hwtcl HDL_PARAMETER true

   add_parameter          deemphasis_enable_hwtcl string "false"
   set_parameter_property deemphasis_enable_hwtcl GROUP $group_name
   set_parameter_property deemphasis_enable_hwtcl VISIBLE false
   set_parameter_property deemphasis_enable_hwtcl HDL_PARAMETER true

   add_parameter          pld_clk_MHz integer 125
   set_parameter_property pld_clk_MHz GROUP $group_name
   set_parameter_property pld_clk_MHz VISIBLE false
   set_parameter_property pld_clk_MHz HDL_PARAMETER true

   add_parameter          millisecond_cycle_count_hwtcl integer 124250
   set_parameter_property millisecond_cycle_count_hwtcl GROUP $group_name
   set_parameter_property millisecond_cycle_count_hwtcl VISIBLE false
   set_parameter_property millisecond_cycle_count_hwtcl HDL_PARAMETER true

   add_parameter          use_crc_forwarding_hwtcl integer 0
   set_parameter_property use_crc_forwarding_hwtcl GROUP $group_name
   set_parameter_property use_crc_forwarding_hwtcl VISIBLE false
   set_parameter_property use_crc_forwarding_hwtcl HDL_PARAMETER true

   add_parameter          ecrc_check_capable_hwtcl integer 0
   set_parameter_property ecrc_check_capable_hwtcl GROUP $group_name
   set_parameter_property ecrc_check_capable_hwtcl VISIBLE false
   set_parameter_property ecrc_check_capable_hwtcl HDL_PARAMETER true

   add_parameter          ecrc_gen_capable_hwtcl integer 0
   set_parameter_property ecrc_gen_capable_hwtcl GROUP $group_name
   set_parameter_property ecrc_gen_capable_hwtcl VISIBLE false
   set_parameter_property ecrc_gen_capable_hwtcl HDL_PARAMETER true


   # Application Type
   add_parameter          enable_pipe32_phyip_ser_driver_hwtcl integer 0
   set_parameter_property enable_pipe32_phyip_ser_driver_hwtcl VISIBLE false
   set_parameter_property enable_pipe32_phyip_ser_driver_hwtcl HDL_PARAMETER true
}
