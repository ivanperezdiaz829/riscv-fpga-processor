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



proc add_pcie_hip_hidden_non_derived_rtl_parameters {} {

   send_message debug "proc:add_pcie_hip_hidden_non_derived_rtl_parameters"

   # Internal parameter to force using direct value for credit in the command line and bypass UI
   #  default zero
   add_parameter          advanced_default_parameter_override integer 0
   set_parameter_property advanced_default_parameter_override VISIBLE false
   set_parameter_property advanced_default_parameter_override HDL_PARAMETER false

   # Internal parameter to override default design exanmple tb partner
   #  default zero
   #       - When  1  driver simulate config only
   #       - When  2  driver simulate chaining dma
   #       - When  3  driver simulate config target
   #       - When  10 driver simulate config bypass
   add_parameter          override_tbpartner_driver_setting_hwtcl integer 0
   set_parameter_property override_tbpartner_driver_setting_hwtcl VISIBLE false
   set_parameter_property override_tbpartner_driver_setting_hwtcl HDL_PARAMETER false

   add_parameter bypass_clk_switch_hwtcl string "disable"
   set_parameter_property bypass_clk_switch_hwtcl VISIBLE false
   set_parameter_property bypass_clk_switch_hwtcl DERIVED true
   set_parameter_property bypass_clk_switch_hwtcl HDL_PARAMETER true

   add_parameter          cvp_rate_sel_hwtcl string "full_rate"
   set_parameter_property cvp_rate_sel_hwtcl VISIBLE false
   set_parameter_property cvp_rate_sel_hwtcl DERIVED true
   set_parameter_property cvp_rate_sel_hwtcl HDL_PARAMETER true

   add_parameter          cvp_data_compressed_hwtcl string "false"
   set_parameter_property cvp_data_compressed_hwtcl VISIBLE false
   set_parameter_property cvp_data_compressed_hwtcl DERIVED true
   set_parameter_property cvp_data_compressed_hwtcl HDL_PARAMETER true

   add_parameter          cvp_data_encrypted_hwtcl string "false"
   set_parameter_property cvp_data_encrypted_hwtcl VISIBLE false
   set_parameter_property cvp_data_encrypted_hwtcl DERIVED true
   set_parameter_property cvp_data_encrypted_hwtcl HDL_PARAMETER true

   add_parameter          cvp_mode_reset_hwtcl string "false"
   set_parameter_property cvp_mode_reset_hwtcl VISIBLE false
   set_parameter_property cvp_mode_reset_hwtcl DERIVED true
   set_parameter_property cvp_mode_reset_hwtcl HDL_PARAMETER true

   add_parameter          cvp_clk_reset_hwtcl string "false"
   set_parameter_property cvp_clk_reset_hwtcl VISIBLE false
   set_parameter_property cvp_clk_reset_hwtcl DERIVED true
   set_parameter_property cvp_clk_reset_hwtcl HDL_PARAMETER true

   add_parameter          core_clk_sel_hwtcl string "pld_clk"
   set_parameter_property core_clk_sel_hwtcl VISIBLE false
   set_parameter_property core_clk_sel_hwtcl DERIVED true
   set_parameter_property core_clk_sel_hwtcl HDL_PARAMETER true

   add_parameter          enable_rx_buffer_checking_hwtcl string "false"
   set_parameter_property enable_rx_buffer_checking_hwtcl VISIBLE false
   set_parameter_property enable_rx_buffer_checking_hwtcl HDL_PARAMETER true
   set_parameter_property enable_rx_buffer_checking_hwtcl DERIVED true

   add_parameter          disable_link_x2_support_hwtcl string "false"
   set_parameter_property disable_link_x2_support_hwtcl VISIBLE false
   set_parameter_property disable_link_x2_support_hwtcl HDL_PARAMETER true
   set_parameter_property disable_link_x2_support_hwtcl DERIVED true

   add_parameter          device_number_hwtcl integer 0
   set_parameter_property device_number_hwtcl VISIBLE false
   set_parameter_property device_number_hwtcl HDL_PARAMETER true
   set_parameter_property device_number_hwtcl DERIVED true

   add_parameter          pipex1_debug_sel_hwtcl string "disable"
   set_parameter_property pipex1_debug_sel_hwtcl VISIBLE false
   set_parameter_property pipex1_debug_sel_hwtcl HDL_PARAMETER true
   set_parameter_property pipex1_debug_sel_hwtcl DERIVED true

   add_parameter          pclk_out_sel_hwtcl string "pclk"
   set_parameter_property pclk_out_sel_hwtcl VISIBLE false
   set_parameter_property pclk_out_sel_hwtcl HDL_PARAMETER true
   set_parameter_property pclk_out_sel_hwtcl DERIVED true

   add_parameter          no_soft_reset_hwtcl string "false"
   set_parameter_property no_soft_reset_hwtcl VISIBLE false
   set_parameter_property no_soft_reset_hwtcl HDL_PARAMETER true
   set_parameter_property no_soft_reset_hwtcl DERIVED true

   add_parameter          d1_support_hwtcl string "false"
   set_parameter_property d1_support_hwtcl VISIBLE false
   set_parameter_property d1_support_hwtcl HDL_PARAMETER true
   set_parameter_property d1_support_hwtcl DERIVED true

   add_parameter          d2_support_hwtcl string "false"
   set_parameter_property d2_support_hwtcl VISIBLE false
   set_parameter_property d2_support_hwtcl HDL_PARAMETER true
   set_parameter_property d2_support_hwtcl DERIVED true

   add_parameter          d0_pme_hwtcl string "false"
   set_parameter_property d0_pme_hwtcl VISIBLE false
   set_parameter_property d0_pme_hwtcl HDL_PARAMETER true
   set_parameter_property d0_pme_hwtcl DERIVED true

   add_parameter          d1_pme_hwtcl string "false"
   set_parameter_property d1_pme_hwtcl VISIBLE false
   set_parameter_property d1_pme_hwtcl HDL_PARAMETER true
   set_parameter_property d1_pme_hwtcl DERIVED true

   add_parameter          d2_pme_hwtcl string "false"
   set_parameter_property d2_pme_hwtcl VISIBLE false
   set_parameter_property d2_pme_hwtcl HDL_PARAMETER true
   set_parameter_property d2_pme_hwtcl DERIVED true

   add_parameter          d3_hot_pme_hwtcl string "false"
   set_parameter_property d3_hot_pme_hwtcl VISIBLE false
   set_parameter_property d3_hot_pme_hwtcl HDL_PARAMETER true
   set_parameter_property d3_hot_pme_hwtcl DERIVED true

   add_parameter          d3_cold_pme_hwtcl string "false"
   set_parameter_property d3_cold_pme_hwtcl VISIBLE false
   set_parameter_property d3_cold_pme_hwtcl HDL_PARAMETER true
   set_parameter_property d3_cold_pme_hwtcl DERIVED true

   add_parameter          low_priority_vc_hwtcl string "single_vc"
   set_parameter_property low_priority_vc_hwtcl VISIBLE false
   set_parameter_property low_priority_vc_hwtcl HDL_PARAMETER true
   set_parameter_property low_priority_vc_hwtcl DERIVED true

   add_parameter          enable_l1_aspm_hwtcl string "false"
   set_parameter_property enable_l1_aspm_hwtcl VISIBLE false
   set_parameter_property enable_l1_aspm_hwtcl HDL_PARAMETER true
   set_parameter_property enable_l1_aspm_hwtcl DERIVED true

   add_parameter          l1_exit_latency_sameclock_hwtcl integer 0
   set_parameter_property l1_exit_latency_sameclock_hwtcl VISIBLE false
   set_parameter_property l1_exit_latency_sameclock_hwtcl HDL_PARAMETER true
   set_parameter_property l1_exit_latency_sameclock_hwtcl DERIVED true

   add_parameter          l1_exit_latency_diffclock_hwtcl integer 0
   set_parameter_property l1_exit_latency_diffclock_hwtcl VISIBLE false
   set_parameter_property l1_exit_latency_diffclock_hwtcl HDL_PARAMETER true
   set_parameter_property l1_exit_latency_diffclock_hwtcl DERIVED true

   add_parameter          hot_plug_support_hwtcl integer 0
   set_parameter_property hot_plug_support_hwtcl VISIBLE false
   set_parameter_property hot_plug_support_hwtcl HDL_PARAMETER true
   set_parameter_property hot_plug_support_hwtcl DERIVED true

   add_parameter          no_command_completed_hwtcl string "false"
   set_parameter_property no_command_completed_hwtcl VISIBLE false
   set_parameter_property no_command_completed_hwtcl HDL_PARAMETER true
   set_parameter_property no_command_completed_hwtcl DERIVED true

   add_parameter          eie_before_nfts_count_hwtcl integer 4
   set_parameter_property eie_before_nfts_count_hwtcl VISIBLE false
   set_parameter_property eie_before_nfts_count_hwtcl HDL_PARAMETER true
   set_parameter_property eie_before_nfts_count_hwtcl DERIVED true

   add_parameter          gen2_diffclock_nfts_count_hwtcl integer 255
   set_parameter_property gen2_diffclock_nfts_count_hwtcl VISIBLE false
   set_parameter_property gen2_diffclock_nfts_count_hwtcl HDL_PARAMETER true
   set_parameter_property gen2_diffclock_nfts_count_hwtcl DERIVED true

   add_parameter          gen2_sameclock_nfts_count_hwtcl integer 255
   set_parameter_property gen2_sameclock_nfts_count_hwtcl VISIBLE false
   set_parameter_property gen2_sameclock_nfts_count_hwtcl HDL_PARAMETER true
   set_parameter_property gen2_sameclock_nfts_count_hwtcl DERIVED true

   add_parameter          deemphasis_enable_hwtcl string "false"
   set_parameter_property deemphasis_enable_hwtcl VISIBLE false
   set_parameter_property deemphasis_enable_hwtcl HDL_PARAMETER true
   set_parameter_property deemphasis_enable_hwtcl DERIVED true

   add_parameter          l0_exit_latency_sameclock_hwtcl integer 6
   set_parameter_property l0_exit_latency_sameclock_hwtcl VISIBLE false
   set_parameter_property l0_exit_latency_sameclock_hwtcl HDL_PARAMETER true
   set_parameter_property l0_exit_latency_sameclock_hwtcl DERIVED true

   add_parameter          l0_exit_latency_diffclock_hwtcl integer 6
   set_parameter_property l0_exit_latency_diffclock_hwtcl VISIBLE false
   set_parameter_property l0_exit_latency_diffclock_hwtcl HDL_PARAMETER true
   set_parameter_property l0_exit_latency_diffclock_hwtcl DERIVED true

   add_parameter          vc0_clk_enable_hwtcl string "true"
   set_parameter_property vc0_clk_enable_hwtcl VISIBLE false
   set_parameter_property vc0_clk_enable_hwtcl HDL_PARAMETER true
   set_parameter_property vc0_clk_enable_hwtcl DERIVED true

   add_parameter          register_pipe_signals_hwtcl string "true"
   set_parameter_property register_pipe_signals_hwtcl VISIBLE false
   set_parameter_property register_pipe_signals_hwtcl HDL_PARAMETER true
   set_parameter_property register_pipe_signals_hwtcl DERIVED true

   add_parameter          tx_cdc_almost_empty_hwtcl integer 5
   set_parameter_property tx_cdc_almost_empty_hwtcl VISIBLE false
   set_parameter_property tx_cdc_almost_empty_hwtcl HDL_PARAMETER true
   set_parameter_property tx_cdc_almost_empty_hwtcl DERIVED true

   add_parameter          rx_l0s_count_idl_hwtcl integer 0
   set_parameter_property rx_l0s_count_idl_hwtcl VISIBLE false
   set_parameter_property rx_l0s_count_idl_hwtcl HDL_PARAMETER true
   set_parameter_property rx_l0s_count_idl_hwtcl DERIVED true

   add_parameter          cdc_dummy_insert_limit_hwtcl integer 11
   set_parameter_property cdc_dummy_insert_limit_hwtcl VISIBLE false
   set_parameter_property cdc_dummy_insert_limit_hwtcl HDL_PARAMETER true
   set_parameter_property cdc_dummy_insert_limit_hwtcl DERIVED true

   add_parameter          ei_delay_powerdown_count_hwtcl integer 10
   set_parameter_property ei_delay_powerdown_count_hwtcl VISIBLE false
   set_parameter_property ei_delay_powerdown_count_hwtcl HDL_PARAMETER true
   set_parameter_property ei_delay_powerdown_count_hwtcl DERIVED true

   add_parameter          skp_os_schedule_count_hwtcl integer 0
   set_parameter_property skp_os_schedule_count_hwtcl VISIBLE false
   set_parameter_property skp_os_schedule_count_hwtcl HDL_PARAMETER true
   set_parameter_property skp_os_schedule_count_hwtcl DERIVED true

   add_parameter          fc_init_timer_hwtcl integer 1024
   set_parameter_property fc_init_timer_hwtcl VISIBLE false
   set_parameter_property fc_init_timer_hwtcl HDL_PARAMETER true
   set_parameter_property fc_init_timer_hwtcl DERIVED true

   add_parameter          l01_entry_latency_hwtcl integer 31
   set_parameter_property l01_entry_latency_hwtcl VISIBLE false
   set_parameter_property l01_entry_latency_hwtcl HDL_PARAMETER true
   set_parameter_property l01_entry_latency_hwtcl DERIVED true

   add_parameter          flow_control_update_count_hwtcl integer 30
   set_parameter_property flow_control_update_count_hwtcl VISIBLE false
   set_parameter_property flow_control_update_count_hwtcl HDL_PARAMETER true
   set_parameter_property flow_control_update_count_hwtcl DERIVED true

   add_parameter          flow_control_timeout_count_hwtcl integer 200
   set_parameter_property flow_control_timeout_count_hwtcl VISIBLE false
   set_parameter_property flow_control_timeout_count_hwtcl HDL_PARAMETER true
   set_parameter_property flow_control_timeout_count_hwtcl DERIVED true

   add_parameter          retry_buffer_last_active_address_hwtcl integer 255
   set_parameter_property retry_buffer_last_active_address_hwtcl VISIBLE false
   set_parameter_property retry_buffer_last_active_address_hwtcl HDL_PARAMETER true
   set_parameter_property retry_buffer_last_active_address_hwtcl DERIVED true

   add_parameter          reserved_debug_hwtcl integer 0
   set_parameter_property reserved_debug_hwtcl VISIBLE false
   set_parameter_property reserved_debug_hwtcl HDL_PARAMETER true
   set_parameter_property reserved_debug_hwtcl DERIVED true

   add_parameter          use_tl_cfg_sync_hwtcl integer 1
   set_parameter_property use_tl_cfg_sync_hwtcl VISIBLE false
   set_parameter_property use_tl_cfg_sync_hwtcl HDL_PARAMETER true
   set_parameter_property use_tl_cfg_sync_hwtcl DERIVED true

   add_parameter diffclock_nfts_count_hwtcl integer 255
   set_parameter_property diffclock_nfts_count_hwtcl VISIBLE false
   set_parameter_property diffclock_nfts_count_hwtcl HDL_PARAMETER true
   set_parameter_property diffclock_nfts_count_hwtcl DERIVED true

   add_parameter sameclock_nfts_count_hwtcl integer 255
   set_parameter_property sameclock_nfts_count_hwtcl VISIBLE false
   set_parameter_property sameclock_nfts_count_hwtcl HDL_PARAMETER true
   set_parameter_property sameclock_nfts_count_hwtcl DERIVED true

   add_parameter l2_async_logic_hwtcl string "disable"
   set_parameter_property l2_async_logic_hwtcl VISIBLE false
   set_parameter_property l2_async_logic_hwtcl HDL_PARAMETER true
   set_parameter_property l2_async_logic_hwtcl DERIVED true

   add_parameter rx_cdc_almost_full_hwtcl integer 12
   set_parameter_property rx_cdc_almost_full_hwtcl VISIBLE false
   set_parameter_property rx_cdc_almost_full_hwtcl HDL_PARAMETER true
   set_parameter_property rx_cdc_almost_full_hwtcl DERIVED true

   add_parameter tx_cdc_almost_full_hwtcl integer 11
   set_parameter_property tx_cdc_almost_full_hwtcl VISIBLE false
   set_parameter_property tx_cdc_almost_full_hwtcl HDL_PARAMETER true
   set_parameter_property tx_cdc_almost_full_hwtcl DERIVED true

   add_parameter indicator_hwtcl integer 0
   set_parameter_property indicator_hwtcl VISIBLE false
   set_parameter_property indicator_hwtcl HDL_PARAMETER true
   set_parameter_property indicator_hwtcl DERIVED true

   ####### ADVANCED DEFAULT HWTCL

   add_parameter          enable_rx_buffer_checking_advanced_default_hwtcl string "false"
   set_parameter_property enable_rx_buffer_checking_advanced_default_hwtcl VISIBLE false
   set_parameter_property enable_rx_buffer_checking_advanced_default_hwtcl HDL_PARAMETER false

   add_parameter          disable_link_x2_support_advanced_default_hwtcl string "false"
   set_parameter_property disable_link_x2_support_advanced_default_hwtcl VISIBLE false
   set_parameter_property disable_link_x2_support_advanced_default_hwtcl HDL_PARAMETER false

   add_parameter          device_number_advanced_default_hwtcl integer 0
   set_parameter_property device_number_advanced_default_hwtcl VISIBLE false
   set_parameter_property device_number_advanced_default_hwtcl HDL_PARAMETER false

   add_parameter          pipex1_debug_sel_advanced_default_hwtcl string "disable"
   set_parameter_property pipex1_debug_sel_advanced_default_hwtcl VISIBLE false
   set_parameter_property pipex1_debug_sel_advanced_default_hwtcl HDL_PARAMETER false

   add_parameter          pclk_out_sel_advanced_default_hwtcl string "pclk"
   set_parameter_property pclk_out_sel_advanced_default_hwtcl VISIBLE false
   set_parameter_property pclk_out_sel_advanced_default_hwtcl HDL_PARAMETER false

   add_parameter          no_soft_reset_advanced_default_hwtcl string "false"
   set_parameter_property no_soft_reset_advanced_default_hwtcl VISIBLE false
   set_parameter_property no_soft_reset_advanced_default_hwtcl HDL_PARAMETER false

   add_parameter          d1_support_advanced_default_hwtcl string "false"
   set_parameter_property d1_support_advanced_default_hwtcl VISIBLE false
   set_parameter_property d1_support_advanced_default_hwtcl HDL_PARAMETER false

   add_parameter          d2_support_advanced_default_hwtcl string "false"
   set_parameter_property d2_support_advanced_default_hwtcl VISIBLE false
   set_parameter_property d2_support_advanced_default_hwtcl HDL_PARAMETER false

   add_parameter          d0_pme_advanced_default_hwtcl string "false"
   set_parameter_property d0_pme_advanced_default_hwtcl VISIBLE false
   set_parameter_property d0_pme_advanced_default_hwtcl HDL_PARAMETER false

   add_parameter          d1_pme_advanced_default_hwtcl string "false"
   set_parameter_property d1_pme_advanced_default_hwtcl VISIBLE false
   set_parameter_property d1_pme_advanced_default_hwtcl HDL_PARAMETER false

   add_parameter          d2_pme_advanced_default_hwtcl string "false"
   set_parameter_property d2_pme_advanced_default_hwtcl VISIBLE false
   set_parameter_property d2_pme_advanced_default_hwtcl HDL_PARAMETER false

   add_parameter          d3_hot_pme_advanced_default_hwtcl string "false"
   set_parameter_property d3_hot_pme_advanced_default_hwtcl VISIBLE false
   set_parameter_property d3_hot_pme_advanced_default_hwtcl HDL_PARAMETER false

   add_parameter          d3_cold_pme_advanced_default_hwtcl string "false"
   set_parameter_property d3_cold_pme_advanced_default_hwtcl VISIBLE false
   set_parameter_property d3_cold_pme_advanced_default_hwtcl HDL_PARAMETER false

   add_parameter          low_priority_vc_advanced_default_hwtcl string "single_vc"
   set_parameter_property low_priority_vc_advanced_default_hwtcl VISIBLE false
   set_parameter_property low_priority_vc_advanced_default_hwtcl HDL_PARAMETER false

   add_parameter          enable_l1_aspm_advanced_default_hwtcl string "false"
   set_parameter_property enable_l1_aspm_advanced_default_hwtcl VISIBLE false
   set_parameter_property enable_l1_aspm_advanced_default_hwtcl HDL_PARAMETER false

   add_parameter          l1_exit_latency_sameclock_advanced_default_hwtcl integer 0
   set_parameter_property l1_exit_latency_sameclock_advanced_default_hwtcl VISIBLE false
   set_parameter_property l1_exit_latency_sameclock_advanced_default_hwtcl HDL_PARAMETER false

   add_parameter          l1_exit_latency_diffclock_advanced_default_hwtcl integer 0
   set_parameter_property l1_exit_latency_diffclock_advanced_default_hwtcl VISIBLE false
   set_parameter_property l1_exit_latency_diffclock_advanced_default_hwtcl HDL_PARAMETER false

   add_parameter          hot_plug_support_advanced_default_hwtcl integer 0
   set_parameter_property hot_plug_support_advanced_default_hwtcl VISIBLE false
   set_parameter_property hot_plug_support_advanced_default_hwtcl HDL_PARAMETER false

   add_parameter          no_command_completed_advanced_default_hwtcl string "false"
   set_parameter_property no_command_completed_advanced_default_hwtcl VISIBLE false
   set_parameter_property no_command_completed_advanced_default_hwtcl HDL_PARAMETER false

   add_parameter          eie_before_nfts_count_advanced_default_hwtcl integer 4
   set_parameter_property eie_before_nfts_count_advanced_default_hwtcl VISIBLE false
   set_parameter_property eie_before_nfts_count_advanced_default_hwtcl HDL_PARAMETER false

   add_parameter          gen2_diffclock_nfts_count_advanced_default_hwtcl integer 255
   set_parameter_property gen2_diffclock_nfts_count_advanced_default_hwtcl VISIBLE false
   set_parameter_property gen2_diffclock_nfts_count_advanced_default_hwtcl HDL_PARAMETER false

   add_parameter          gen2_sameclock_nfts_count_advanced_default_hwtcl integer 255
   set_parameter_property gen2_sameclock_nfts_count_advanced_default_hwtcl VISIBLE false
   set_parameter_property gen2_sameclock_nfts_count_advanced_default_hwtcl HDL_PARAMETER false

   add_parameter          deemphasis_enable_advanced_default_hwtcl string "false"
   set_parameter_property deemphasis_enable_advanced_default_hwtcl VISIBLE false
   set_parameter_property deemphasis_enable_advanced_default_hwtcl HDL_PARAMETER false

   add_parameter          l0_exit_latency_sameclock_advanced_default_hwtcl integer 6
   set_parameter_property l0_exit_latency_sameclock_advanced_default_hwtcl VISIBLE false
   set_parameter_property l0_exit_latency_sameclock_advanced_default_hwtcl HDL_PARAMETER false

   add_parameter          l0_exit_latency_diffclock_advanced_default_hwtcl integer 6
   set_parameter_property l0_exit_latency_diffclock_advanced_default_hwtcl VISIBLE false
   set_parameter_property l0_exit_latency_diffclock_advanced_default_hwtcl HDL_PARAMETER false

   add_parameter          vc0_clk_enable_advanced_default_hwtcl string "true"
   set_parameter_property vc0_clk_enable_advanced_default_hwtcl VISIBLE false
   set_parameter_property vc0_clk_enable_advanced_default_hwtcl HDL_PARAMETER false

   add_parameter          register_pipe_signals_advanced_default_hwtcl string "true"
   set_parameter_property register_pipe_signals_advanced_default_hwtcl VISIBLE false
   set_parameter_property register_pipe_signals_advanced_default_hwtcl HDL_PARAMETER false

   add_parameter          tx_cdc_almost_empty_advanced_default_hwtcl integer 5
   set_parameter_property tx_cdc_almost_empty_advanced_default_hwtcl VISIBLE false
   set_parameter_property tx_cdc_almost_empty_advanced_default_hwtcl HDL_PARAMETER false

   add_parameter          rx_l0s_count_idl_advanced_default_hwtcl integer 0
   set_parameter_property rx_l0s_count_idl_advanced_default_hwtcl VISIBLE false
   set_parameter_property rx_l0s_count_idl_advanced_default_hwtcl HDL_PARAMETER false

   add_parameter          cdc_dummy_insert_limit_advanced_default_hwtcl integer 11
   set_parameter_property cdc_dummy_insert_limit_advanced_default_hwtcl VISIBLE false
   set_parameter_property cdc_dummy_insert_limit_advanced_default_hwtcl HDL_PARAMETER false

   add_parameter          ei_delay_powerdown_count_advanced_default_hwtcl integer 10
   set_parameter_property ei_delay_powerdown_count_advanced_default_hwtcl VISIBLE false
   set_parameter_property ei_delay_powerdown_count_advanced_default_hwtcl HDL_PARAMETER false

   add_parameter          skp_os_schedule_count_advanced_default_hwtcl integer 0
   set_parameter_property skp_os_schedule_count_advanced_default_hwtcl VISIBLE false
   set_parameter_property skp_os_schedule_count_advanced_default_hwtcl HDL_PARAMETER false

   add_parameter          fc_init_timer_advanced_default_hwtcl integer 1024
   set_parameter_property fc_init_timer_advanced_default_hwtcl VISIBLE false
   set_parameter_property fc_init_timer_advanced_default_hwtcl HDL_PARAMETER false

   add_parameter          l01_entry_latency_advanced_default_hwtcl integer 31
   set_parameter_property l01_entry_latency_advanced_default_hwtcl VISIBLE false
   set_parameter_property l01_entry_latency_advanced_default_hwtcl HDL_PARAMETER false

   add_parameter          flow_control_update_count_advanced_default_hwtcl integer 30
   set_parameter_property flow_control_update_count_advanced_default_hwtcl VISIBLE false
   set_parameter_property flow_control_update_count_advanced_default_hwtcl HDL_PARAMETER false

   add_parameter          flow_control_timeout_count_advanced_default_hwtcl integer 200
   set_parameter_property flow_control_timeout_count_advanced_default_hwtcl VISIBLE false
   set_parameter_property flow_control_timeout_count_advanced_default_hwtcl HDL_PARAMETER false

   add_parameter          retry_buffer_last_active_address_advanced_default_hwtcl integer 255
   set_parameter_property retry_buffer_last_active_address_advanced_default_hwtcl VISIBLE false
   set_parameter_property retry_buffer_last_active_address_advanced_default_hwtcl HDL_PARAMETER false

   add_parameter          reserved_debug_advanced_default_hwtcl integer 0
   set_parameter_property reserved_debug_advanced_default_hwtcl VISIBLE false
   set_parameter_property reserved_debug_advanced_default_hwtcl HDL_PARAMETER false

   add_parameter          use_tl_cfg_sync_advanced_default_hwtcl integer 1
   set_parameter_property use_tl_cfg_sync_advanced_default_hwtcl VISIBLE false
   set_parameter_property use_tl_cfg_sync_advanced_default_hwtcl HDL_PARAMETER false

   add_parameter diffclock_nfts_count_advanced_default_hwtcl integer 255
   set_parameter_property diffclock_nfts_count_advanced_default_hwtcl VISIBLE false
   set_parameter_property diffclock_nfts_count_advanced_default_hwtcl HDL_PARAMETER false

   add_parameter sameclock_nfts_count_advanced_default_hwtcl integer 255
   set_parameter_property sameclock_nfts_count_advanced_default_hwtcl VISIBLE false
   set_parameter_property sameclock_nfts_count_advanced_default_hwtcl HDL_PARAMETER false

   add_parameter l2_async_logic_advanced_default_hwtcl string "disable"
   set_parameter_property l2_async_logic_advanced_default_hwtcl VISIBLE false
   set_parameter_property l2_async_logic_advanced_default_hwtcl HDL_PARAMETER false

   add_parameter rx_cdc_almost_full_advanced_default_hwtcl integer 12
   set_parameter_property rx_cdc_almost_full_advanced_default_hwtcl VISIBLE false
   set_parameter_property rx_cdc_almost_full_advanced_default_hwtcl HDL_PARAMETER false

   add_parameter tx_cdc_almost_full_advanced_default_hwtcl integer 11
   set_parameter_property tx_cdc_almost_full_advanced_default_hwtcl VISIBLE false
   set_parameter_property tx_cdc_almost_full_advanced_default_hwtcl HDL_PARAMETER false

   add_parameter indicator_advanced_default_hwtcl integer 0
   set_parameter_property indicator_advanced_default_hwtcl VISIBLE false
   set_parameter_property indicator_advanced_default_hwtcl HDL_PARAMETER false

}

proc add_av_pcie_hip_common_hidden_parameters_update {} {
   send_message debug "proc:add_av_pcie_hip_common_hidden_parameters_update"
   set advanced_default_parameter_override  [ get_parameter_value advanced_default_parameter_override ]
   if { $advanced_default_parameter_override == 0 } {
      set_parameter_value  enable_rx_buffer_checking_hwtcl         "false"
      set_parameter_value  disable_link_x2_support_hwtcl           "false"
      set_parameter_value  device_number_hwtcl                     0
      set_parameter_value  pipex1_debug_sel_hwtcl                  "disable"
      set_parameter_value  pclk_out_sel_hwtcl                      "pclk"
      set_parameter_value  no_soft_reset_hwtcl                     "false"
      set_parameter_value  d1_support_hwtcl                        "false"
      set_parameter_value  d2_support_hwtcl                        "false"
      set_parameter_value  d0_pme_hwtcl                            "false"
      set_parameter_value  d1_pme_hwtcl                            "false"
      set_parameter_value  d2_pme_hwtcl                            "false"
      set_parameter_value  d3_hot_pme_hwtcl                        "false"
      set_parameter_value  d3_cold_pme_hwtcl                       "false"
      set_parameter_value  low_priority_vc_hwtcl                   "single_vc"
      set_parameter_value  enable_l1_aspm_hwtcl                    "false"
      set_parameter_value  l1_exit_latency_sameclock_hwtcl         0
      set_parameter_value  l1_exit_latency_diffclock_hwtcl         0
      set_parameter_value  hot_plug_support_hwtcl                  0
      set_parameter_value  no_command_completed_hwtcl              "false"
      set_parameter_value  eie_before_nfts_count_hwtcl             4
      set_parameter_value  gen2_diffclock_nfts_count_hwtcl         255
      set_parameter_value  gen2_sameclock_nfts_count_hwtcl         255
      set_parameter_value  deemphasis_enable_hwtcl                 "false"
      set_parameter_value  l0_exit_latency_sameclock_hwtcl         6
      set_parameter_value  l0_exit_latency_diffclock_hwtcl         6
      set_parameter_value  vc0_clk_enable_hwtcl                    "true"
      set_parameter_value  register_pipe_signals_hwtcl             "true"
      set_parameter_value  tx_cdc_almost_empty_hwtcl               5
      set_parameter_value  rx_l0s_count_idl_hwtcl                  0
      set_parameter_value  cdc_dummy_insert_limit_hwtcl            11
      set_parameter_value  ei_delay_powerdown_count_hwtcl          10
      set_parameter_value  skp_os_schedule_count_hwtcl             0
      set_parameter_value  fc_init_timer_hwtcl                     1024
      set_parameter_value  l01_entry_latency_hwtcl                 31
      set_parameter_value  flow_control_update_count_hwtcl         30
      set_parameter_value  flow_control_timeout_count_hwtcl        200
      set_parameter_value  retry_buffer_last_active_address_hwtcl  255
      set_parameter_value  reserved_debug_hwtcl                    0
      set_parameter_value  use_tl_cfg_sync_hwtcl                   1
      set_parameter_value  diffclock_nfts_count_hwtcl              255
      set_parameter_value  sameclock_nfts_count_hwtcl              255
      set_parameter_value  l2_async_logic_hwtcl                    "disable"
      set_parameter_value  rx_cdc_almost_full_hwtcl                12
      set_parameter_value  tx_cdc_almost_full_hwtcl                11
      set_parameter_value  indicator_hwtcl                         0
   } else {
      set_parameter_value  enable_rx_buffer_checking_hwtcl         [ get_parameter_value enable_rx_buffer_checking_advanced_default_hwtcl        ]
      set_parameter_value  disable_link_x2_support_hwtcl           [ get_parameter_value disable_link_x2_support_advanced_default_hwtcl          ]
      set_parameter_value  device_number_hwtcl                     [ get_parameter_value device_number_advanced_default_hwtcl                    ]
      set_parameter_value  pipex1_debug_sel_hwtcl                  [ get_parameter_value pipex1_debug_sel_advanced_default_hwtcl                 ]
      set_parameter_value  pclk_out_sel_hwtcl                      [ get_parameter_value pclk_out_sel_advanced_default_hwtcl                     ]
      set_parameter_value  no_soft_reset_hwtcl                     [ get_parameter_value no_soft_reset_advanced_default_hwtcl                    ]
      set_parameter_value  d1_support_hwtcl                        [ get_parameter_value d1_support_advanced_default_hwtcl                       ]
      set_parameter_value  d2_support_hwtcl                        [ get_parameter_value d2_support_advanced_default_hwtcl                       ]
      set_parameter_value  d0_pme_hwtcl                            [ get_parameter_value d0_pme_advanced_default_hwtcl                           ]
      set_parameter_value  d1_pme_hwtcl                            [ get_parameter_value d1_pme_advanced_default_hwtcl                           ]
      set_parameter_value  d2_pme_hwtcl                            [ get_parameter_value d2_pme_advanced_default_hwtcl                           ]
      set_parameter_value  d3_hot_pme_hwtcl                        [ get_parameter_value d3_hot_pme_advanced_default_hwtcl                       ]
      set_parameter_value  d3_cold_pme_hwtcl                       [ get_parameter_value d3_cold_pme_advanced_default_hwtcl                      ]
      set_parameter_value  low_priority_vc_hwtcl                   [ get_parameter_value low_priority_vc_advanced_default_hwtcl                  ]
      set_parameter_value  enable_l1_aspm_hwtcl                    [ get_parameter_value enable_l1_aspm_advanced_default_hwtcl                   ]
      set_parameter_value  l1_exit_latency_sameclock_hwtcl         [ get_parameter_value l1_exit_latency_sameclock_advanced_default_hwtcl        ]
      set_parameter_value  l1_exit_latency_diffclock_hwtcl         [ get_parameter_value l1_exit_latency_diffclock_advanced_default_hwtcl        ]
      set_parameter_value  hot_plug_support_hwtcl                  [ get_parameter_value hot_plug_support_advanced_default_hwtcl                 ]
      set_parameter_value  no_command_completed_hwtcl              [ get_parameter_value no_command_completed_advanced_default_hwtcl             ]
      set_parameter_value  eie_before_nfts_count_hwtcl             [ get_parameter_value eie_before_nfts_count_advanced_default_hwtcl            ]
      set_parameter_value  gen2_diffclock_nfts_count_hwtcl         [ get_parameter_value gen2_diffclock_nfts_count_advanced_default_hwtcl        ]
      set_parameter_value  gen2_sameclock_nfts_count_hwtcl         [ get_parameter_value gen2_sameclock_nfts_count_advanced_default_hwtcl        ]
      set_parameter_value  deemphasis_enable_hwtcl                 [ get_parameter_value deemphasis_enable_advanced_default_hwtcl                ]
      set_parameter_value  l0_exit_latency_sameclock_hwtcl         [ get_parameter_value l0_exit_latency_sameclock_advanced_default_hwtcl        ]
      set_parameter_value  l0_exit_latency_diffclock_hwtcl         [ get_parameter_value l0_exit_latency_diffclock_advanced_default_hwtcl        ]
      set_parameter_value  vc0_clk_enable_hwtcl                    [ get_parameter_value vc0_clk_enable_advanced_default_hwtcl                   ]
      set_parameter_value  register_pipe_signals_hwtcl             [ get_parameter_value register_pipe_signals_advanced_default_hwtcl            ]
      set_parameter_value  tx_cdc_almost_empty_hwtcl               [ get_parameter_value tx_cdc_almost_empty_advanced_default_hwtcl              ]
      set_parameter_value  rx_l0s_count_idl_hwtcl                  [ get_parameter_value rx_l0s_count_idl_advanced_default_hwtcl                 ]
      set_parameter_value  cdc_dummy_insert_limit_hwtcl            [ get_parameter_value cdc_dummy_insert_limit_advanced_default_hwtcl           ]
      set_parameter_value  ei_delay_powerdown_count_hwtcl          [ get_parameter_value ei_delay_powerdown_count_advanced_default_hwtcl         ]
      set_parameter_value  skp_os_schedule_count_hwtcl             [ get_parameter_value skp_os_schedule_count_advanced_default_hwtcl            ]
      set_parameter_value  fc_init_timer_hwtcl                     [ get_parameter_value fc_init_timer_advanced_default_hwtcl                    ]
      set_parameter_value  l01_entry_latency_hwtcl                 [ get_parameter_value l01_entry_latency_advanced_default_hwtcl                ]
      set_parameter_value  flow_control_update_count_hwtcl         [ get_parameter_value flow_control_update_count_advanced_default_hwtcl        ]
      set_parameter_value  flow_control_timeout_count_hwtcl        [ get_parameter_value flow_control_timeout_count_advanced_default_hwtcl       ]
      set_parameter_value  retry_buffer_last_active_address_hwtcl  [ get_parameter_value retry_buffer_last_active_address_advanced_default_hwtcl ]
      set_parameter_value  reserved_debug_hwtcl                    [ get_parameter_value reserved_debug_advanced_default_hwtcl                   ]
      set_parameter_value  use_tl_cfg_sync_hwtcl                   [ get_parameter_value use_tl_cfg_sync_advanced_default_hwtcl                  ]
      set_parameter_value  diffclock_nfts_count_hwtcl              [ get_parameter_value diffclock_nfts_count_advanced_default_hwtcl             ]
      set_parameter_value  sameclock_nfts_count_hwtcl              [ get_parameter_value sameclock_nfts_count_advanced_default_hwtcl             ]
      set_parameter_value  l2_async_logic_hwtcl                    [ get_parameter_value l2_async_logic_advanced_default_hwtcl                   ]
      set_parameter_value  rx_cdc_almost_full_hwtcl                [ get_parameter_value rx_cdc_almost_full_advanced_default_hwtcl               ]
      set_parameter_value  tx_cdc_almost_full_hwtcl                [ get_parameter_value tx_cdc_almost_full_advanced_default_hwtcl               ]
      set_parameter_value  indicator_hwtcl                         [ get_parameter_value indicator_advanced_default_hwtcl                        ]
   }
}

proc add_pcie_pre_emph_vod_av {} {

   send_message debug "proc:add_pcie_pre_emph_vod_av"

   add_parameter          rpre_emph_a_val_hwtcl integer 12
   set_parameter_property rpre_emph_a_val_hwtcl VISIBLE false
   set_parameter_property rpre_emph_a_val_hwtcl HDL_PARAMETER true

   add_parameter          rpre_emph_b_val_hwtcl integer 0
   set_parameter_property rpre_emph_b_val_hwtcl VISIBLE false
   set_parameter_property rpre_emph_b_val_hwtcl HDL_PARAMETER true

   add_parameter          rpre_emph_c_val_hwtcl integer 19
   set_parameter_property rpre_emph_c_val_hwtcl VISIBLE false
   set_parameter_property rpre_emph_c_val_hwtcl HDL_PARAMETER true

   add_parameter          rpre_emph_d_val_hwtcl integer 13
   set_parameter_property rpre_emph_d_val_hwtcl VISIBLE false
   set_parameter_property rpre_emph_d_val_hwtcl HDL_PARAMETER true

   add_parameter          rpre_emph_e_val_hwtcl integer 21
   set_parameter_property rpre_emph_e_val_hwtcl VISIBLE false
   set_parameter_property rpre_emph_e_val_hwtcl HDL_PARAMETER true

   add_parameter          rvod_sel_a_val_hwtcl integer 42
   set_parameter_property rvod_sel_a_val_hwtcl VISIBLE false
   set_parameter_property rvod_sel_a_val_hwtcl HDL_PARAMETER true

   add_parameter          rvod_sel_b_val_hwtcl integer 30
   set_parameter_property rvod_sel_b_val_hwtcl VISIBLE false
   set_parameter_property rvod_sel_b_val_hwtcl HDL_PARAMETER true

   add_parameter          rvod_sel_c_val_hwtcl integer 43
   set_parameter_property rvod_sel_c_val_hwtcl VISIBLE false
   set_parameter_property rvod_sel_c_val_hwtcl HDL_PARAMETER true

   add_parameter          rvod_sel_d_val_hwtcl integer 43
   set_parameter_property rvod_sel_d_val_hwtcl VISIBLE false
   set_parameter_property rvod_sel_d_val_hwtcl HDL_PARAMETER true

   add_parameter          rvod_sel_e_val_hwtcl integer 9
   set_parameter_property rvod_sel_e_val_hwtcl VISIBLE false
   set_parameter_property rvod_sel_e_val_hwtcl HDL_PARAMETER true
}

proc add_pcie_pre_emph_vod_cv {} {

   send_message debug "proc:add_pcie_pre_emph_vod_cv"

   add_parameter          rpre_emph_a_val_hwtcl integer 11
   set_parameter_property rpre_emph_a_val_hwtcl VISIBLE false
   set_parameter_property rpre_emph_a_val_hwtcl HDL_PARAMETER true

   add_parameter          rpre_emph_b_val_hwtcl integer 0
   set_parameter_property rpre_emph_b_val_hwtcl VISIBLE false
   set_parameter_property rpre_emph_b_val_hwtcl HDL_PARAMETER true

   add_parameter          rpre_emph_c_val_hwtcl integer 22
   set_parameter_property rpre_emph_c_val_hwtcl VISIBLE false
   set_parameter_property rpre_emph_c_val_hwtcl HDL_PARAMETER true

   add_parameter          rpre_emph_d_val_hwtcl integer 12
   set_parameter_property rpre_emph_d_val_hwtcl VISIBLE false
   set_parameter_property rpre_emph_d_val_hwtcl HDL_PARAMETER true

   add_parameter          rpre_emph_e_val_hwtcl integer 21
   set_parameter_property rpre_emph_e_val_hwtcl VISIBLE false
   set_parameter_property rpre_emph_e_val_hwtcl HDL_PARAMETER true

   add_parameter          rvod_sel_a_val_hwtcl integer 50
   set_parameter_property rvod_sel_a_val_hwtcl VISIBLE false
   set_parameter_property rvod_sel_a_val_hwtcl HDL_PARAMETER true

   add_parameter          rvod_sel_b_val_hwtcl integer 34
   set_parameter_property rvod_sel_b_val_hwtcl VISIBLE false
   set_parameter_property rvod_sel_b_val_hwtcl HDL_PARAMETER true

   add_parameter          rvod_sel_c_val_hwtcl integer 50
   set_parameter_property rvod_sel_c_val_hwtcl VISIBLE false
   set_parameter_property rvod_sel_c_val_hwtcl HDL_PARAMETER true

   add_parameter          rvod_sel_d_val_hwtcl integer 50
   set_parameter_property rvod_sel_d_val_hwtcl VISIBLE false
   set_parameter_property rvod_sel_d_val_hwtcl HDL_PARAMETER true

   add_parameter          rvod_sel_e_val_hwtcl integer 9
   set_parameter_property rvod_sel_e_val_hwtcl VISIBLE false
   set_parameter_property rvod_sel_e_val_hwtcl HDL_PARAMETER true
}


proc set_pcie_hip_flow_control_settings {} {

   set credit_type "absolute"
   set icredit_type 2
   set altpcie_avmm [ get_parameter_value altpcie_avmm_hwtcl ]

   if { $altpcie_avmm > 0 } {
      set max_payload  [ get_parameter_value max_payload_size_hwtcl ]
   } else {
      set max_payload  [ get_parameter_value max_payload_size_0_hwtcl ]
   }

   set use_crc_forwarding_hwtcl [ get_parameter_value use_crc_forwarding_hwtcl ]
   set rxbuffer_rxreq_hwtcl [ get_parameter_value rxbuffer_rxreq_hwtcl ]
   set override_rxbuffer_cred_preset [ get_parameter_value override_rxbuffer_cred_preset ]

   if { $override_rxbuffer_cred_preset == 1 } {
      # when set override presets
      set icredit_type 5
   } else {
      if  { [ regexp Minimum $rxbuffer_rxreq_hwtcl ] } {
         set icredit_type 0
      } elseif { [ regexp Low $rxbuffer_rxreq_hwtcl ] } {
         set icredit_type 1
      } elseif { [ regexp High $rxbuffer_rxreq_hwtcl ] } {
         set icredit_type 3
      } elseif { [ regexp Maximum $rxbuffer_rxreq_hwtcl ] } {
         set icredit_type 4
      } else {
         set icredit_type 2
      }
      set_parameter_value credit_buffer_allocation_aux_hwtcl "absolute"
   }

   # Info display
   #
   send_message info "Credit allocation in the 6K bytes receive buffer:"
   set cred_val ""

   #For readability
   set kvc_minimum   0
   set kvc_low       1
   set kvc_balanced  2
   set kvc_high      3
   set kvc_maximum   4

   if { $use_crc_forwarding_hwtcl == 0 } {
      #
      #                                                            k_vc0 = Cpld, CplH, NPD, NPH, PD, PH             ko_cpl_spc_vc0
      #   MINIMUM REQUESTOR CREDS (MAXPAYLD=128B , 8 CREDS  )      k_vc0 = { 0,    0,    0,     4,     8,      1 }  ko_cpl_spc_vc0 :  CPLD=809,  CPLH=202
      #   MINIMUM REQUESTOR CREDS (MAXPAYLD=256B , 16 CREDS )      k_vc0 = { 0,    0,    0,     4,     16,     1 }  ko_cpl_spc_vc0 :  CPLD=803,  CPLH=200
      #   MINIMUM REQUESTOR CREDS (MAXPAYLD=512B , 32 CREDS )      k_vc0 = { 0,    0,    0,     4,     32,     1 }  ko_cpl_spc_vc0 :  CPLD=790,  CPLH=197
      #   MINIMUM REQUESTOR CREDS (MAXPAYLD=1024B, 64 CREDS )      k_vc0 = { 0,    0,    0,     4,     64,     1 }  ko_cpl_spc_vc0 :  CPLD=764,  CPLH=191
      #   MINIMUM REQUESTOR CREDS (MAXPAYLD=2048B, 128 CREDS)      k_vc0 = { 0,    0,    0,     4,     128,    1 }  ko_cpl_spc_vc0 :  CPLD=713,  CPLH=178
      #
      #
      #   LOW REQUESTOR CREDS (MAXPAYLD=128B, 8 CREDS)             k_vc0 = { 0,    0,    0,     16,    16,     16 } ko_cpl_spc_vc0 :  CPLD=781,  CPLH=195
      #   LOW REQUESTOR CREDS (MAXPAYLD=256B, 16 CREDS)            k_vc0 = { 0,    0,    0,     16,    16,     16 } ko_cpl_spc_vc0 :  CPLD=781,  CPLH=195
      #   LOW REQUESTOR CREDS (MAXPAYLD=512B, 32 CREDS)            k_vc0 = { 0,    0,    0,     16,    32,     16 } ko_cpl_spc_vc0 :  CPLD=768,  CPLH=192
      #   LOW REQUESTOR CREDS (MAXPAYLD=1024B, 64 CREDS)           k_vc0 = { 0,    0,    0,     16,    64,     16 } ko_cpl_spc_vc0 :  CPLD=743,  CPLH=185
      #   LOW REQUESTOR CREDS (MAXPAYLD=2048B, 128 CREDS)          k_vc0 = { 0,    0,    0,     16,    128,    16 } ko_cpl_spc_vc0 :  CPLD=692,  CPLH=172
      #
      #   HIGH REQUESTOR - OPTION A (BALANCE PD = 8*PH)
      #
      #   HIGH REQUESTOR CREDS (MAXPAYLD=128B, 8 CREDS)            k_vc0 = { 0,    0,    0,     92,    800,    100} ko_cpl_spc_vc0 :  CPLD=16,  CPLH=16
      #   HIGH REQUESTOR CREDS (MAXPAYLD=256B, 16 CREDS)           k_vc0 = { 0,    0,    0,     52,    882,    58 } ko_cpl_spc_vc0 :  CPLD=16,  CPLH=16
      #   HIGH REQUESTOR CREDS (MAXPAYLD=512B, 32 CREDS)           k_vc0 = { 0,    0,    0,     28,    918,    30 } ko_cpl_spc_vc0 :  CPLD=32,  CPLH=16
      #   HIGH REQUESTOR CREDS (MAXPAYLD=1024B, 64 CREDS)          k_vc0 = { 0,    0,    0,     16,    912,    16 } ko_cpl_spc_vc0 :  CPLD=64,  CPLH=16
      #   HIGH REQUESTOR CREDS (MAXPAYLD=2048B, 128 CREDS)         k_vc0 = { 0,    0,    0,     16,    832,    16 } ko_cpl_spc_vc0 :  CPLD=128,  CPLH=32
      #
      #   MAX REQUESTOR (MAXPAYLD=128B, 8 CREDS)                   k_vc0 = { 0,    0,    0,     88,     815,   112 }ko_cpl_spc_vc0 :  CPLD=8,  CPLH=1
      #   MAX REQUESTOR (MAXPAYLD=256B, 16 CREDS)                  k_vc0 = { 0,    0,    0,     52,     897,    58 }ko_cpl_spc_vc0 :  CPLD=16,  CPLH=1
      #   MAX REQUESTOR CREDS (MAXPAYLD=512B, 32 CREDS)            k_vc0 = { 0,    0,    0,     28,     933,    30 }ko_cpl_spc_vc0 :  CPLD=32,  CPLH=1
      #   MAX REQUESTOR CREDS (MAXPAYLD=1024B, 64 CREDS)           k_vc0 = { 0,    0,    0,     16,     927,    16 }ko_cpl_spc_vc0 :  CPLD=64,  CPLH=1
      #   MAX REQUESTOR CREDS (MAXPAYLD=2048B, 128 CREDS)          k_vc0 = { 0,    0,    0,     16,     863,    16 }ko_cpl_spc_vc0 :  CPLD=128,  CPLH=1

      #              Cpld, CplH, NPD, NPH, PD, PH, Size CPLD, Size CPLH
      set k_vc($kvc_minimum,128)   "0 0 0 1 8 1 300 74"
      set k_vc($kvc_minimum,256)   "0 0 0 1 16 1 293 73"
      set k_vc($kvc_minimum,512)   "0 0 0 1 32 1 280 70"

      set k_vc($kvc_low,128)       "0 0 0 16 16 16 269 67"
      set k_vc($kvc_low,256)       "0 0 0 16 16 16 269 67"
      set k_vc($kvc_low,512)       "0 0 0 16 32 16 256 64"

      set k_vc($kvc_balanced,128)  "0 0 0 32 94 18 196 44"
      set k_vc($kvc_balanced,256)  "0 0 0 32 94 18 196 44"
      set k_vc($kvc_balanced,512)  "0 0 0 32 94 18 196 44"

      set k_vc($kvc_high,128)      "0 0 0 36 280 36 16 16"
      set k_vc($kvc_high,256)      "0 0 0 20 312 20 16 16"
      set k_vc($kvc_high,512)      "0 0 0 16 304 16 32 16"

      set k_vc($kvc_maximum,128)   "0 0 0 39 297 39 8 1"
      set k_vc($kvc_maximum,256)   "0 0 0 23 320 24 16 1"
      set k_vc($kvc_maximum,512)   "0 0 0 16 319 16 32 1"
   } else  {
      # ECRC Forwarding
      #    MINIMUM REQUESTOR CREDS (MAXPAYLD=128B, 8 CREDS)         k_vc0 = { 0,    0,    0,     8,     8,      2 } ko_cpl_spc_vc0 :  CPLD=799,  CPLH=202
      #    MINIMUM REQUESTOR CREDS (MAXPAYLD=256B, 16 CREDS)        k_vc0 = { 0,    0,    0,     8,     16,     2 } ko_cpl_spc_vc0 :  CPLD=793,  CPLH=200
      #    MINIMUM REQUESTOR CREDS (MAXPAYLD=512B, 32 CREDS)        k_vc0 = { 0,    0,    0,     8,     32,     2 } ko_cpl_spc_vc0 :  CPLD=780,  CPLH=197
      #    MINIMUM REQUESTOR CREDS (MAXPAYLD=1024B, 64 CREDS)       k_vc0 = { 0,    0,    0,     8,     64,     2 } ko_cpl_spc_vc0 :  CPLD=754,  CPLH=191
      #    MINIMUM REQUESTOR CREDS (MAXPAYLD=2048B, 128 CREDS)      k_vc0 = { 0,    0,    0,     8,     128,    2 } ko_cpl_spc_vc0 :  CPLD=703,  CPLH=178
      #
      #    LOW REQUESTOR CREDS (MAXPAYLD=128B, 8 CREDS)             k_vc0 = { 0,    0,    0,     16,     16,     16 } ko_cpl_spc_vc0 :  CPLD=765,  CPLH=195
      #    LOW REQUESTOR CREDS (MAXPAYLD=256B, 16 CREDS)            k_vc0 = { 0,    0,    0,     16,     16,     16 } ko_cpl_spc_vc0 :  CPLD=765,  CPLH=195
      #    LOW REQUESTOR CREDS (MAXPAYLD=512B, 32 CREDS)            k_vc0 = { 0,    0,    0,     16,     32,     16 } ko_cpl_spc_vc0 :  CPLD=752,  CPLH=192
      #    LOW REQUESTOR CREDS (MAXPAYLD=1024B, 64 CREDS)           k_vc0 = { 0,    0,    0,     16,     64,     16 } ko_cpl_spc_vc0 :  CPLD=727,  CPLH=185
      #    LOW REQUESTOR CREDS (MAXPAYLD=2048B, 128 CREDS)          k_vc0 = { 0,    0,    0,     16,     128,    16 } ko_cpl_spc_vc0 :  CPLD=676,  CPLH=172
      #
      #    HIGH REQUESTOR - OPTION A (BALANCE PD = 8*PH)
      #
      #    HIGH REQUESTOR CREDS (MAXPAYLD=128B, 8 CREDS)            k_vc0 = { 0,    0,    0,     88,     710,    100 } ko_cpl_spc_vc0 :  CPLD=16,  CPLH=16
      #    HIGH REQUESTOR CREDS (MAXPAYLD=256B, 16 CREDS)           k_vc0 = { 0,    0,    0,     48,     833,     58 } ko_cpl_spc_vc0 :  CPLD=16,  CPLH=16
      #    HIGH REQUESTOR CREDS (MAXPAYLD=512B, 32 CREDS)           k_vc0 = { 0,    0,    0,     24,     895,     30 } ko_cpl_spc_vc0 :  CPLD=32,  CPLH=16
      #    HIGH REQUESTOR CREDS (MAXPAYLD=1024B, 64 CREDS)          k_vc0 = { 0,    0,    0,     16,     896,     16 } ko_cpl_spc_vc0 :  CPLD=64,  CPLH=16
      #    HIGH REQUESTOR CREDS (MAXPAYLD=2048B, 128 CREDS)         k_vc0 = { 0,    0,    0,     16,     816,     16 } ko_cpl_spc_vc0 :  CPLD=128, CPLH=32
      #
      #    MAX REQUESTOR (MAXPAYLD=128B, 8 CREDS)                   k_vc0 = { 0,    0,    0,     88,     715,    112 } ko_cpl_spc_vc0 :  CPLD=8,   CPLH=1
      #    MAX REQUESTOR (MAXPAYLD=256B, 16 CREDS)                  k_vc0 = { 0,    0,    0,     48,     848,     58 } ko_cpl_spc_vc0 :  CPLD=16,  CPLH=1
      #    MAX REQUESTOR CREDS (MAXPAYLD=512B, 32 CREDS)            k_vc0 = { 0,    0,    0,     24,     910,     30 } ko_cpl_spc_vc0 :  CPLD=32,  CPLH=1
      #    MAX REQUESTOR CREDS (MAXPAYLD=1024B, 64 CREDS)           k_vc0 = { 0,    0,    0,     16,     911,     16 } ko_cpl_spc_vc0 :  CPLD=64,  CPLH=1
      #    MAX REQUESTOR CREDS (MAXPAYLD=2048B, 128 CREDS)          k_vc0 = { 0,    0,    0,     16,     847,     16 } ko_cpl_spc_vc0 :  CPLD=128, CPLH=1

      #   Cpld, CplH, NPD, NPH, PD, PH, Size CPLD, Size CPLH
      set k_vc($kvc_minimum,128)   "0 0 0 1 8 1 299 74"
      set k_vc($kvc_minimum,256)   "0 0 0 1 16 1 292 73"
      set k_vc($kvc_minimum,512)   "0 0 0 1 32 1 279 70"

      set k_vc($kvc_low,128)       "0 0 0 16 16 16 253 67"
      set k_vc($kvc_low,256)       "0 0 0 16 16 16 253 67"
      set k_vc($kvc_low,512)       "0 0 0 16 32 16 240 64"

      set k_vc($kvc_balanced,128)  "0 0 0 32 88 18 176 44"
      set k_vc($kvc_balanced,256)  "0 0 0 32 88 18 176 44"
      set k_vc($kvc_balanced,512)  "0 0 0 32 88 18 176 44"

      set k_vc($kvc_high,128)      "0 0 0 36 244 36 16 16"
      set k_vc($kvc_high,256)      "0 0 0 20 292 20 16 16"
      set k_vc($kvc_high,512)      "0 0 0 16 288 16 32 16"

      set k_vc($kvc_maximum,128)   "0 0 0 39 258 39 8 1"
      set k_vc($kvc_maximum,256)   "0 0 0 23 296 24 16 1"
      set k_vc($kvc_maximum,512)   "0 0 0 26 303 16 32 1"

   }

   if { $override_rxbuffer_cred_preset == 0 } {
      set cred_val $k_vc($icredit_type,$max_payload)
      set cred_array [ split $cred_val " "]
      # Cpld(0), CplH(1), NPD(2), NPH(3), PD(4), PH(5), Size CPLD(6), Size CPLH(7)

      set CPLH_ADVERTISE [ lindex $cred_array 1 ]
      set CPLD_ADVERTISE [ lindex $cred_array 0 ]
      set NPH  [ lindex $cred_array 3]
      set NPD  [ lindex $cred_array 2]
      set PH   [ lindex $cred_array 5]
      set PD   [ lindex $cred_array 4]
      set CPLH [ lindex $cred_array 7]
      set CPLD [ lindex $cred_array 6]

      set_parameter_value vc0_rx_flow_ctrl_posted_header_hwtcl $PH
      set_parameter_value vc0_rx_flow_ctrl_posted_data_hwtcl $PD
      set_parameter_value vc0_rx_flow_ctrl_nonposted_header_hwtcl $NPH
      set_parameter_value vc0_rx_flow_ctrl_nonposted_data_hwtcl $NPD
      set_parameter_value vc0_rx_flow_ctrl_compl_header_hwtcl $CPLH_ADVERTISE
      set_parameter_value vc0_rx_flow_ctrl_compl_data_hwtcl $CPLD_ADVERTISE
      set_parameter_value cpl_spc_data_hwtcl $CPLD
      set_parameter_value cpl_spc_header_hwtcl $CPLH

      send_message info "Posted    : header=$PH  data=$PD"
      send_message info "Non posted: header=$NPH  data=$NPD"
      send_message info "Completion: header=$CPLH data=$CPLD"

   } else {
      set PH   [ get_parameter_value vc0_rx_flow_ctrl_posted_header_hwtcl   ]
      set PD   [ get_parameter_value vc0_rx_flow_ctrl_posted_data_hwtcl     ]
      set NPH  [ get_parameter_value vc0_rx_flow_ctrl_nonposted_header_hwtcl]
      set NPD  [ get_parameter_value vc0_rx_flow_ctrl_nonposted_data_hwtcl  ]
      set CPLH [ get_parameter_value vc0_rx_flow_ctrl_compl_header_hwtcl    ]
      set CPLD [ get_parameter_value vc0_rx_flow_ctrl_compl_data_hwtcl      ]

      send_message info "Posted    : header=$PH  data=$PD"
      send_message info "Non posted: header=$NPH  data=$NPD"
      send_message info "Completion: header=$CPLH data=$CPLD"
   }
}

proc set_pcie_cvp_parameters {} {
   set in_cvp_mode_hwtcl [ get_parameter_value in_cvp_mode_hwtcl ]
   if { $in_cvp_mode_hwtcl == 1 } {
      set_parameter_value  cvp_rate_sel_hwtcl         "full_rate"
      set_parameter_value  cvp_data_compressed_hwtcl  "false"
      set_parameter_value  cvp_data_encrypted_hwtcl   "false"
      set_parameter_value  cvp_mode_reset_hwtcl       "false"
      set_parameter_value  cvp_clk_reset_hwtcl        "false"
      set_parameter_value  core_clk_sel_hwtcl         "core_clk_out"
      set_parameter_value  bypass_clk_switch_hwtcl    "disable"
   } else {
      set_parameter_value  cvp_rate_sel_hwtcl         "full_rate"
      set_parameter_value  cvp_data_compressed_hwtcl  "false"
      set_parameter_value  cvp_data_encrypted_hwtcl   "false"
      set_parameter_value  cvp_mode_reset_hwtcl       "false"
      set_parameter_value  cvp_clk_reset_hwtcl        "false"
      set_parameter_value  core_clk_sel_hwtcl         "pld_clk"
      set_parameter_value  bypass_clk_switch_hwtcl    "disable"
  }
}

