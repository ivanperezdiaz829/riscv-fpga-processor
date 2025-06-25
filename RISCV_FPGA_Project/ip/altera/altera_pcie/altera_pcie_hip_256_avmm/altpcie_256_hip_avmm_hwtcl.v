// (C) 2001-2013 Altera Corporation. All rights reserved.
// Your use of Altera Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License Subscription 
// Agreement, Altera MegaCore Function License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

module altpcie_256_hip_avmm_hwtcl # (

      parameter pll_refclk_freq_hwtcl                             = "100 MHz",
      parameter enable_slot_register_hwtcl                        = 0,
      parameter port_type_hwtcl                                   = "Native endpoint",
      parameter bypass_cdc_hwtcl                                  = "false",
      parameter enable_rx_buffer_checking_hwtcl                   = "false",
      parameter single_rx_detect_hwtcl                            = 0,
      parameter use_crc_forwarding_hwtcl                          = 0,
      parameter ast_width_hwtcl                                   = "rx_tx_64",
      parameter gen123_lane_rate_mode_hwtcl                       = "gen1",
      parameter lane_mask_hwtcl                                   = "x4",
      parameter disable_link_x2_support_hwtcl                     = "false",
      parameter hip_hard_reset_hwtcl                              = 1,
      parameter wrong_device_id_hwtcl                             = "disable",
      parameter data_pack_rx_hwtcl                                = "disable",
      parameter use_ast_parity                                    = 0,
      parameter ltssm_1ms_timeout_hwtcl                           = "disable",
      parameter ltssm_freqlocked_check_hwtcl                      = "disable",
      parameter deskew_comma_hwtcl                                = "com_deskw",
      parameter port_link_number_hwtcl                            = 1,
      parameter device_number_hwtcl                               = 0,
      parameter bypass_clk_switch_hwtcl                           = "TRUE",
      parameter pipex1_debug_sel_hwtcl                            = "disable",
      parameter pclk_out_sel_hwtcl                                = "pclk",
      parameter vendor_id_hwtcl                                   = 4466,
      parameter device_id_hwtcl                                   = 57345,
      parameter revision_id_hwtcl                                 = 1,
      parameter class_code_hwtcl                                  = 16711680,
      parameter subsystem_vendor_id_hwtcl                         = 4466,
      parameter subsystem_device_id_hwtcl                         = 57345,
      parameter no_soft_reset_hwtcl                               = "false",
      parameter maximum_current_hwtcl                             = 0,
      parameter d1_support_hwtcl                                  = "false",
      parameter d2_support_hwtcl                                  = "false",
      parameter d0_pme_hwtcl                                      = "false",
      parameter d1_pme_hwtcl                                      = "false",
      parameter d2_pme_hwtcl                                      = "false",
      parameter d3_hot_pme_hwtcl                                  = "false",
      parameter d3_cold_pme_hwtcl                                 = "false",
      parameter use_aer_hwtcl                                     = 0,
      parameter low_priority_vc_hwtcl                             = "single_vc",
      parameter disable_snoop_packet_hwtcl                        = "false",
      parameter max_payload_size_hwtcl                            = 256,
      parameter surprise_down_error_support_hwtcl                 = 0,
      parameter dll_active_report_support_hwtcl                   = 0,
      parameter extend_tag_field_hwtcl                            = "false",
      parameter endpoint_l0_latency_hwtcl                         = 0,
      parameter endpoint_l1_latency_hwtcl                         = 0,
      parameter indicator_hwtcl                                   = 7,
      parameter slot_power_scale_hwtcl                            = 0,
      parameter enable_l1_aspm_hwtcl                              = "false",
      parameter l1_exit_latency_sameclock_hwtcl                   = 0,
      parameter l1_exit_latency_diffclock_hwtcl                   = 0,
      parameter hot_plug_support_hwtcl                            = 0,
      parameter slot_power_limit_hwtcl                            = 0,
      parameter slot_number_hwtcl                                 = 0,
      parameter diffclock_nfts_count_hwtcl                        = 0,
      parameter sameclock_nfts_count_hwtcl                        = 0,
      parameter completion_timeout_hwtcl                          = "abcd",
      parameter enable_completion_timeout_disable_hwtcl           = 1,
      parameter extended_tag_reset_hwtcl                          = "false",
      parameter ecrc_check_capable_hwtcl                          = 0,
      parameter ecrc_gen_capable_hwtcl                            = 0,
      parameter no_command_completed_hwtcl                        = "true",
      parameter msi_multi_message_capable_hwtcl                   = "count_4",
      parameter msi_64bit_addressing_capable_hwtcl                = "true",
      parameter msi_masking_capable_hwtcl                         = "false",
      parameter msi_support_hwtcl                                 = "true",
      parameter interrupt_pin_hwtcl                               = "inta",
      parameter enable_function_msix_support_hwtcl                = 0,
      parameter msix_table_size_hwtcl                             = 0,
      parameter msix_table_bir_hwtcl                              = 0,
      parameter msix_table_offset_hwtcl                           = "0",
      parameter msix_pba_bir_hwtcl                                = 0,
      parameter msix_pba_offset_hwtcl                             = "0",
      parameter bridge_port_vga_enable_hwtcl                      = "false",
      parameter bridge_port_ssid_support_hwtcl                    = "false",
      parameter ssvid_hwtcl                                       = 0,
      parameter ssid_hwtcl                                        = 0,
      parameter eie_before_nfts_count_hwtcl                       = 4,
      parameter gen2_diffclock_nfts_count_hwtcl                   = 255,
      parameter gen2_sameclock_nfts_count_hwtcl                   = 255,
      parameter deemphasis_enable_hwtcl                           = "false",
      parameter pcie_spec_version_hwtcl                           = "v2",
      parameter l0_exit_latency_sameclock_hwtcl                   = 6,
      parameter l0_exit_latency_diffclock_hwtcl                   = 6,
      parameter rx_ei_l0s_hwtcl                                   = 1,
      parameter l2_async_logic_hwtcl                              = "enable",
      parameter aspm_config_management_hwtcl                      = "true",
      parameter atomic_op_routing_hwtcl                           = "false",
      parameter atomic_op_completer_32bit_hwtcl                   = "false",
      parameter atomic_op_completer_64bit_hwtcl                   = "false",
      parameter cas_completer_128bit_hwtcl                        = "false",
      parameter ltr_mechanism_hwtcl                               = "false",
      parameter tph_completer_hwtcl                               = "false",
      parameter extended_format_field_hwtcl                       = "false",
      parameter atomic_malformed_hwtcl                            = "false",
      parameter flr_capability_hwtcl                              = "true",
      parameter enable_adapter_half_rate_mode_hwtcl               = "false",
      parameter vc0_clk_enable_hwtcl                              = "true",
      parameter register_pipe_signals_hwtcl                       = "false",
      parameter bar0_io_space_hwtcl                               = "Disabled",
      parameter bar0_type_hwtcl                                   = 64,
      parameter bar0_64bit_mem_space_hwtcl                        = "Enabled",
      parameter bar0_prefetchable_hwtcl                           = "Enabled",
      parameter bar0_size_mask_hwtcl                              = "256 MBytes - 28 bits",
      parameter bar1_io_space_hwtcl                               = "Disabled",
      parameter bar1_type_hwtcl                                   = 1,
      parameter bar1_64bit_mem_space_hwtcl                        = "Disabled",
      parameter bar1_prefetchable_hwtcl                           = "Disabled",
      parameter bar1_size_mask_hwtcl                              = "N/A",
      parameter bar2_io_space_hwtcl                               = "Disabled",
      parameter bar2_type_hwtcl                                   = 32,
      parameter bar2_64bit_mem_space_hwtcl                        = "Disabled",
      parameter bar2_prefetchable_hwtcl                           = "Disabled",
      parameter bar2_size_mask_hwtcl                              = "N/A",
      parameter bar3_io_space_hwtcl                               = "Disabled",
      parameter bar3_type_hwtcl                                   = 32,
      parameter bar3_64bit_mem_space_hwtcl                        = "Disabled",
      parameter bar3_prefetchable_hwtcl                           = "Disabled",
      parameter bar3_size_mask_hwtcl                              = "N/A",
      parameter bar4_io_space_hwtcl                               = "Disabled",
      parameter bar4_type_hwtcl                                   = 32,
      parameter bar4_64bit_mem_space_hwtcl                        = "Disabled",
      parameter bar4_prefetchable_hwtcl                           = "Disabled",
      parameter bar4_size_mask_hwtcl                              = "N/A",
      parameter bar5_io_space_hwtcl                               = "Disabled",
      parameter bar5_type_hwtcl                                   = 32,
      parameter bar5_64bit_mem_space_hwtcl                        = "Disabled",
      parameter bar5_prefetchable_hwtcl                           = "Disabled",
      parameter bar5_size_mask_hwtcl                              = "N/A",
      parameter rd_dma_size_mask_hwtcl                            = 8,
      parameter wr_dma_size_mask_hwtcl                            = 8,
      parameter expansion_base_address_register_hwtcl             = 0,
      parameter io_window_addr_width_hwtcl                        = "window_32_bit",
      parameter prefetchable_mem_window_addr_width_hwtcl          = "prefetch_32",
      parameter skp_os_gen3_count_hwtcl                           = 0,
      parameter tx_cdc_almost_empty_hwtcl                         = 5,
      parameter rx_cdc_almost_full_hwtcl                          = 6,
      parameter tx_cdc_almost_full_hwtcl                          = 6,
      parameter rx_l0s_count_idl_hwtcl                            = 0,
      parameter cdc_dummy_insert_limit_hwtcl                      = 11,
      parameter ei_delay_powerdown_count_hwtcl                    = 10,
      parameter millisecond_cycle_count_hwtcl                     = 0,
      parameter skp_os_schedule_count_hwtcl                       = 0,
      parameter fc_init_timer_hwtcl                               = 1024,
      parameter l01_entry_latency_hwtcl                           = 31,
      parameter flow_control_update_count_hwtcl                   = 30,
      parameter flow_control_timeout_count_hwtcl                  = 200,
      parameter credit_buffer_allocation_aux_hwtcl                = "balanced",
      parameter vc0_rx_flow_ctrl_posted_header_hwtcl              = 50,
      parameter vc0_rx_flow_ctrl_posted_data_hwtcl                = 360,
      parameter vc0_rx_flow_ctrl_nonposted_header_hwtcl           = 54,
      parameter vc0_rx_flow_ctrl_nonposted_data_hwtcl             = 0,
      parameter vc0_rx_flow_ctrl_compl_header_hwtcl               = 112,
      parameter vc0_rx_flow_ctrl_compl_data_hwtcl                 = 448,
      parameter rx_ptr0_posted_dpram_min_hwtcl                    = 0,
      parameter rx_ptr0_posted_dpram_max_hwtcl                    = 0,
      parameter rx_ptr0_nonposted_dpram_min_hwtcl                 = 0,
      parameter rx_ptr0_nonposted_dpram_max_hwtcl                 = 0,
      parameter retry_buffer_last_active_address_hwtcl            = 2047,
      parameter retry_buffer_memory_settings_hwtcl                = 0,
      parameter vc0_rx_buffer_memory_settings_hwtcl               = 0,
      parameter in_cvp_mode_hwtcl                                 = 0,
      parameter slotclkcfg_hwtcl                                  = 1,
      parameter reconfig_to_xcvr_width                            = 350,
      parameter set_pld_clk_x1_625MHz_hwtcl                       = 0,
      parameter reconfig_from_xcvr_width                          = 230,
      parameter enable_l0s_aspm_hwtcl                             = "true",
      parameter cpl_spc_header_hwtcl                              = 195,
      parameter cpl_spc_data_hwtcl                                = 781,
      parameter port_width_be_hwtcl                               = 8,
      parameter port_width_data_hwtcl                             = 64,
      parameter reserved_debug_hwtcl                              = 0,
      parameter hip_reconfig_hwtcl                                = 0,
      parameter vsec_id_hwtcl                                     = 0,
      parameter vsec_rev_hwtcl                                    = 0,
      parameter gen3_rxfreqlock_counter_hwtcl                     = 0,
      parameter gen3_skip_ph2_ph3_hwtcl                           = 1,
      parameter g3_bypass_equlz_hwtcl                             = 1,
      parameter enable_tl_only_sim_hwtcl                          = 0,
      parameter use_atx_pll_hwtcl                                 = 0,
      parameter cvp_rate_sel_hwtcl                                = "full_rate",
      parameter cvp_data_compressed_hwtcl                         = "false",
      parameter cvp_data_encrypted_hwtcl                          = "false",
      parameter cvp_mode_reset_hwtcl                              = "false",
      parameter cvp_clk_reset_hwtcl                               = "false",
      parameter cseb_cpl_status_during_cvp_hwtcl                  = "config_retry_status",
      parameter core_clk_sel_hwtcl                                = "pld_clk",
      parameter g3_dis_rx_use_prst_hwtcl			  = "true",
      parameter g3_dis_rx_use_prst_ep_hwtcl			  = "false",

      parameter hwtcl_override_g2_txvod				  = 0, // When 1 use gen3 param from HWTCL, else use default
      parameter rpre_emph_a_val_hwtcl				  = 9 ,
      parameter rpre_emph_b_val_hwtcl                             = 0 ,
      parameter rpre_emph_c_val_hwtcl                             = 16,
      parameter rpre_emph_d_val_hwtcl                             = 11,
      parameter rpre_emph_e_val_hwtcl                             = 5 ,
      parameter rvod_sel_a_val_hwtcl                              = 42,
      parameter rvod_sel_b_val_hwtcl                              = 38,
      parameter rvod_sel_c_val_hwtcl                              = 38,
      parameter rvod_sel_d_val_hwtcl                              = 38,
      parameter rvod_sel_e_val_hwtcl                              = 15,


      /// Bridge Parameters
      parameter bar_prefetchable = 1,
      parameter avmm_width_hwtcl = 256,
      parameter avmm_burst_width_hwtcl = 7,
      parameter DMA_BRST_CNT_W = 5,
      parameter DMA_WIDTH = 256,
      parameter DMA_BE_WIDTH = 32,
      parameter TX_S_ADDR_WIDTH = 32




) (

      // Reset signals
      input                 pin_perst,
      input                 npor,
      output                reset_status,

      // Serdes related
      input                 refclk,

      // HIP control signals
      input  [4 : 0]        hpg_ctrler,

      // Driven by the testbench
      // Input PIPE simulation for simulation only
      input                 simu_mode_pipe,          // When 1'b1 indicate running DUT under pipe simulation
      input [31 : 0]        test_in,
      output [127 : 0]      testout,
      output [1 : 0]        sim_pipe_rate,
      input                 sim_pipe_pclk_in,
      output                sim_pipe_pclk_out,
      output                sim_pipe_clk250_out,
      output                sim_pipe_clk500_out,
      output [4 : 0]        sim_ltssmstate,
      input                 phystatus0,
      input                 phystatus1,
      input                 phystatus2,
      input                 phystatus3,
      input                 phystatus4,
      input                 phystatus5,
      input                 phystatus6,
      input                 phystatus7,
      input  [7 : 0]        rxdata0,
      input  [7 : 0]        rxdata1,
      input  [7 : 0]        rxdata2,
      input  [7 : 0]        rxdata3,
      input  [7 : 0]        rxdata4,
      input  [7 : 0]        rxdata5,
      input  [7 : 0]        rxdata6,
      input  [7 : 0]        rxdata7,
      input                 rxdatak0,
      input                 rxdatak1,
      input                 rxdatak2,
      input                 rxdatak3,
      input                 rxdatak4,
      input                 rxdatak5,
      input                 rxdatak6,
      input                 rxdatak7,
      input                 rxelecidle0,
      input                 rxelecidle1,
      input                 rxelecidle2,
      input                 rxelecidle3,
      input                 rxelecidle4,
      input                 rxelecidle5,
      input                 rxelecidle6,
      input                 rxelecidle7,
      input                 rxfreqlocked0,
      input                 rxfreqlocked1,
      input                 rxfreqlocked2,
      input                 rxfreqlocked3,
      input                 rxfreqlocked4,
      input                 rxfreqlocked5,
      input                 rxfreqlocked6,
      input                 rxfreqlocked7,
      input  [2 : 0]        rxstatus0,
      input  [2 : 0]        rxstatus1,
      input  [2 : 0]        rxstatus2,
      input  [2 : 0]        rxstatus3,
      input  [2 : 0]        rxstatus4,
      input  [2 : 0]        rxstatus5,
      input  [2 : 0]        rxstatus6,
      input  [2 : 0]        rxstatus7,
      input                 rxdataskip0,
      input                 rxdataskip1,
      input                 rxdataskip2,
      input                 rxdataskip3,
      input                 rxdataskip4,
      input                 rxdataskip5,
      input                 rxdataskip6,
      input                 rxdataskip7,
      input                 rxblkst0,
      input                 rxblkst1,
      input                 rxblkst2,
      input                 rxblkst3,
      input                 rxblkst4,
      input                 rxblkst5,
      input                 rxblkst6,
      input                 rxblkst7,
      input  [1 : 0]        rxsynchd0,
      input  [1 : 0]        rxsynchd1,
      input  [1 : 0]        rxsynchd2,
      input  [1 : 0]        rxsynchd3,
      input  [1 : 0]        rxsynchd4,
      input  [1 : 0]        rxsynchd5,
      input  [1 : 0]        rxsynchd6,
      input  [1 : 0]        rxsynchd7,
      input                 rxvalid0,
      input                 rxvalid1,
      input                 rxvalid2,
      input                 rxvalid3,
      input                 rxvalid4,
      input                 rxvalid5,
      input                 rxvalid6,
      input                 rxvalid7,

      // Output Pipe interface
      output [2 : 0]        eidleinfersel0,
      output [2 : 0]        eidleinfersel1,
      output [2 : 0]        eidleinfersel2,
      output [2 : 0]        eidleinfersel3,
      output [2 : 0]        eidleinfersel4,
      output [2 : 0]        eidleinfersel5,
      output [2 : 0]        eidleinfersel6,
      output [2 : 0]        eidleinfersel7,
      output [1 : 0]        powerdown0,
      output [1 : 0]        powerdown1,
      output [1 : 0]        powerdown2,
      output [1 : 0]        powerdown3,
      output [1 : 0]        powerdown4,
      output [1 : 0]        powerdown5,
      output [1 : 0]        powerdown6,
      output [1 : 0]        powerdown7,
      output                rxpolarity0,
      output                rxpolarity1,
      output                rxpolarity2,
      output                rxpolarity3,
      output                rxpolarity4,
      output                rxpolarity5,
      output                rxpolarity6,
      output                rxpolarity7,
      output                txcompl0,
      output                txcompl1,
      output                txcompl2,
      output                txcompl3,
      output                txcompl4,
      output                txcompl5,
      output                txcompl6,
      output                txcompl7,
      output [7 : 0]        txdata0,
      output [7 : 0]        txdata1,
      output [7 : 0]        txdata2,
      output [7 : 0]        txdata3,
      output [7 : 0]        txdata4,
      output [7 : 0]        txdata5,
      output [7 : 0]        txdata6,
      output [7 : 0]        txdata7,
      output                txdatak0,
      output                txdatak1,
      output                txdatak2,
      output                txdatak3,
      output                txdatak4,
      output                txdatak5,
      output                txdatak6,
      output                txdatak7,
      output                txdatavalid0,
      output                txdatavalid1,
      output                txdatavalid2,
      output                txdatavalid3,
      output                txdatavalid4,
      output                txdatavalid5,
      output                txdatavalid6,
      output                txdatavalid7,
      output                txdetectrx0,
      output                txdetectrx1,
      output                txdetectrx2,
      output                txdetectrx3,
      output                txdetectrx4,
      output                txdetectrx5,
      output                txdetectrx6,
      output                txdetectrx7,
      output                txelecidle0,
      output                txelecidle1,
      output                txelecidle2,
      output                txelecidle3,
      output                txelecidle4,
      output                txelecidle5,
      output                txelecidle6,
      output                txelecidle7,
      output [2 : 0]        txmargin0,
      output [2 : 0]        txmargin1,
      output [2 : 0]        txmargin2,
      output [2 : 0]        txmargin3,
      output [2 : 0]        txmargin4,
      output [2 : 0]        txmargin5,
      output [2 : 0]        txmargin6,
      output [2 : 0]        txmargin7,
      output                txswing0,
      output                txswing1,
      output                txswing2,
      output                txswing3,
      output                txswing4,
      output                txswing5,
      output                txswing6,
      output                txswing7,
      output                txdeemph0,
      output                txdeemph1,
      output                txdeemph2,
      output                txdeemph3,
      output                txdeemph4,
      output                txdeemph5,
      output                txdeemph6,
      output                txdeemph7,
      output                txblkst0,
      output                txblkst1,
      output                txblkst2,
      output                txblkst3,
      output                txblkst4,
      output                txblkst5,
      output                txblkst6,
      output                txblkst7,
      output [1 : 0]        txsynchd0,
      output [1 : 0]        txsynchd1,
      output [1 : 0]        txsynchd2,
      output [1 : 0]        txsynchd3,
      output [1 : 0]        txsynchd4,
      output [1 : 0]        txsynchd5,
      output [1 : 0]        txsynchd6,
      output [1 : 0]        txsynchd7,
      output [17 : 0]       currentcoeff0,
      output [17 : 0]       currentcoeff1,
      output [17 : 0]       currentcoeff2,
      output [17 : 0]       currentcoeff3,
      output [17 : 0]       currentcoeff4,
      output [17 : 0]       currentcoeff5,
      output [17 : 0]       currentcoeff6,
      output [17 : 0]       currentcoeff7,
      output [2 : 0]        currentrxpreset0,
      output [2 : 0]        currentrxpreset1,
      output [2 : 0]        currentrxpreset2,
      output [2 : 0]        currentrxpreset3,
      output [2 : 0]        currentrxpreset4,
      output [2 : 0]        currentrxpreset5,
      output [2 : 0]        currentrxpreset6,
      output [2 : 0]        currentrxpreset7,
      output                coreclkout,

        // Reconfig GXB
      input                [reconfig_to_xcvr_width-1:0]   reconfig_to_xcvr,
      output               [reconfig_from_xcvr_width-1:0] reconfig_from_xcvr,
      output               fixedclk_locked,

      //  HIP Status signals
      output   [1 : 0]        currentspeed,
      output                  derr_cor_ext_rcv,
      output                  derr_cor_ext_rpl,
      output                  derr_rpl,
      output                  dlup,
      output                  dlup_exit,
      output                  ev128ns,
      output                  ev1us,
      output                  hotrst_exit,
      output   [3 : 0]        int_status,
      output                  l2_exit,
      output   [3 : 0]        lane_act,
      output   [4 : 0]        ltssmstate,
      output                  rx_par_err,
      output   [1 : 0]        tx_par_err,
      output                  cfg_par_err,
      output   [7 : 0]        ko_cpl_spc_header,
      output   [11: 0]        ko_cpl_spc_data,
      output   [31:0]         reservedin,

      // CFG TL signals
      output   [3 : 0]        tl_cfg_add,
      output   [31 : 0]       tl_cfg_ctl,
      output   [52 : 0]       tl_cfg_sts,

      // serial interface
      input    rx_in0,
      input    rx_in1,
      input    rx_in2,
      input    rx_in3,
      input    rx_in4,
      input    rx_in5,
      input    rx_in6,
      input    rx_in7,

      output   tx_out0,
      output   tx_out1,
      output   tx_out2,
      output   tx_out3,
      output   tx_out4,
      output   tx_out5,
      output   tx_out6,
      output   tx_out7,

      output                            WrDmaRead_o,
      output    [63:0]                  WrDmaAddress_o,
      output    [DMA_BRST_CNT_W-1:0]    WrDmaBurstCount_o,
      input                             WrDmaWaitRequest_i,
      input                             WrDmaReadDataValid_i,
      input    [DMA_WIDTH-1:0]          WrDmaReadData_i,


// Upstream PCIe Read DMA master port

      output                            RdDmaWrite_o,
      output    [63:0]                  RdDmaAddress_o,
      output    [DMA_WIDTH-1:0]         RdDmaWriteData_o,
      output    [DMA_BRST_CNT_W-1:0]    RdDmaBurstCount_o,
      output    [DMA_BE_WIDTH-1:0]      RdDmaWriteEnable_o,
      input                             RdDmaWaitRequest_i,

      // Read DMA AST Rx port
      output                            RdDmaRxReady_o,
      input     [159:0]                  RdDmaRxData_i,
      input                             RdDmaRxValid_i,

      // Read DMA AST Tx port
      output     [31:0]                 RdDmaTxData_o,
      output                            RdDmaTxValid_o,

      // Write DMA AST Rx port
      output                            WrDmaRxReady_o,
      input     [159:0]                 WrDmaRxData_i,
      input                             WrDmaRxValid_i,

      // Write DMA AST Tx port
      output     [31:0]                 WrDmaTxData_o,
      output                            WrDmaTxValid_o,

      // Avalon Tx Slave interface
      input                                  TxsChipSelect_i,
      input                                  TxsRead_i,
      input                                  TxsWrite_i,
      input  [31:0]          TxsWriteData_i,
      input  [TX_S_ADDR_WIDTH-1:0]           TxsAddress_i,
      input  [(avmm_width_hwtcl/8)-1:0]      TxsByteEnable_i,
      output                                 TxsReadDataValid_o,
      output  [31:0]         TxsReadData_o,
      output                                 TxsWaitRequest_o,

      // Avalon Rx Master interface 0
      output                                 RxmWrite_0_o,
      output [bar0_type_hwtcl-1:0]           RxmAddress_0_o,
      output [31:0]          RxmWriteData_0_o,
      output [(avmm_width_hwtcl/8)-1:0]      RxmByteEnable_0_o,
      input                                  RxmWaitRequest_0_i,
      output                                 RxmRead_0_o,
      input  [31:0]          RxmReadData_0_i,
      input                                  RxmReadDataValid_0_i,

      // Avalon Rx Master interface 1
      output                                 RxmWrite_1_o,
      output [bar1_type_hwtcl-1:0]           RxmAddress_1_o,
      output [31:0]          RxmWriteData_1_o,
      output [(avmm_width_hwtcl/8)-1:0]      RxmByteEnable_1_o,
      input                                  RxmWaitRequest_1_i,
      output                                 RxmRead_1_o,
      input  [31:0]          RxmReadData_1_i,
      input                                  RxmReadDataValid_1_i,

      // Avalon Rx Master interface 2
      output                                 RxmWrite_2_o,
      output [bar2_type_hwtcl-1:0]           RxmAddress_2_o,
      output [31:0]          RxmWriteData_2_o,
      output [(avmm_width_hwtcl/8)-1:0]      RxmByteEnable_2_o,
      input                                  RxmWaitRequest_2_i,
      output                                 RxmRead_2_o,
      input  [31:0]          RxmReadData_2_i,
      input                                  RxmReadDataValid_2_i,

      // Avalon Rx Master interface 3
      output                                 RxmWrite_3_o,
      output [bar3_type_hwtcl-1:0]           RxmAddress_3_o,
      output [31:0]          RxmWriteData_3_o,
      output [(avmm_width_hwtcl/8)-1:0]      RxmByteEnable_3_o,
      input                                  RxmWaitRequest_3_i,
      output                                 RxmRead_3_o,
      input  [31:0]          RxmReadData_3_i,
      input                                  RxmReadDataValid_3_i,

      // Avalon Rx Master interface 4
      output                                 RxmWrite_4_o,
      output [bar4_type_hwtcl-1:0]           RxmAddress_4_o,
      output [31:0]          RxmWriteData_4_o,
      output [(avmm_width_hwtcl/8)-1:0]      RxmByteEnable_4_o,
      input                                  RxmWaitRequest_4_i,
      output                                 RxmRead_4_o,
      input  [31:0]          RxmReadData_4_i,
      input                                  RxmReadDataValid_4_i,

      // Avalon Rx Master interface 5
      output                                 RxmWrite_5_o,
      output [bar5_type_hwtcl-1:0]           RxmAddress_5_o,
      output [31:0]          RxmWriteData_5_o,
      output [(avmm_width_hwtcl/8)-1:0]      RxmByteEnable_5_o,
      input                                  RxmWaitRequest_5_i,
      output                                 RxmRead_5_o,
      input  [31:0]          RxmReadData_5_i,
      input                                  RxmReadDataValid_5_i,


      // Avalon Control Register Access (CRA)lave (This is 32-bit interface)
      input                                  CraChipSelect_i,
      input                                  CraRead,
      input                                  CraWrite,
      input  [31:0]                          CraWriteData_i,
      input  [13:2]                          CraAddress_i,
      input  [3:0]                           CraByteEnable_i,
      output [31:0]                          CraReadData_o,      // This comes from Rx Completion to be returned to Avalon master
      output                                 CraWaitRequest_o,
      output                                 CraIrq_o,

      /// MSI/MSI-X/INTx supported signals
      output  [81:0]                         MsiIntfc_o,
      output  [15:0]                         MsixIntfc_o,

      /// TL Direct BFM Interce
       output [1000 : 0]    tlbfm_in,
       input  [1000 : 0]    tlbfm_out
);

function integer is_pld_clk_250MHz;
   input [8*25:1] l_ast_width;
   input [8*25:1] l_gen123_lane_rate_mode;
   input [8*25:1] l_lane_mask;
   begin
           if ((l_ast_width=="Avalon-ST 64-bit" ) && (l_gen123_lane_rate_mode=="Gen2 (5.0 Gbps)") && (l_lane_mask=="x4"))  is_pld_clk_250MHz=1;
      else if ((l_ast_width=="Avalon-ST 64-bit" ) && (l_gen123_lane_rate_mode=="Gen1 (2.5 Gbps)") && (l_lane_mask=="x8"))  is_pld_clk_250MHz=1;
      else if ((l_ast_width=="Avalon-ST 128-bit") && (l_gen123_lane_rate_mode=="Gen2 (5.0 Gbps)") && (l_lane_mask=="x8"))  is_pld_clk_250MHz=1;
      else                                                                                                                 is_pld_clk_250MHz=0;
   end
endfunction

// Exposed parameters
localparam pll_refclk_freq                               = pll_refclk_freq_hwtcl                                               ;// String  : "100 MHz";
localparam enable_slot_register                          = (enable_slot_register_hwtcl==1)?"true":"false"                      ;// String  : "false";
localparam bypass_cdc                                    = bypass_cdc_hwtcl                                                    ;// String  : "false";
localparam enable_rx_buffer_checking                     = enable_rx_buffer_checking_hwtcl                                     ;// String  : "false";
localparam [3:0] single_rx_detect                        = single_rx_detect_hwtcl                                     ;// integer : 4'b0;
localparam use_crc_forwarding                            = (use_crc_forwarding_hwtcl==1)?"true":"false"                        ;// String  : "false";
localparam gen123_lane_rate_mode                         = (gen123_lane_rate_mode_hwtcl=="Gen3 (8.0 Gbps)")?"gen1_gen2_gen3":
                                                            (gen123_lane_rate_mode_hwtcl=="Gen2 (5.0 Gbps)")?"gen1_gen2":"gen1";// String  : "gen1";
localparam lane_mask                                     = lane_mask_hwtcl                                                     ;// String  : "x4";
localparam disable_link_x2_support                       = disable_link_x2_support_hwtcl                                       ;// String  : "false";
localparam hip_hard_reset                                =  (hip_hard_reset_hwtcl==0)? "disable" : "enable";
localparam use_atx_pll                                   =  (use_atx_pll_hwtcl==1)? "true":"false";
localparam dis_paritychk                                 = (use_ast_parity==0)?"disable":"enable"                              ;// String  : "enable";
localparam wrong_device_id                               = wrong_device_id_hwtcl                                               ;// String  : "disable";
localparam data_pack_rx                                  = data_pack_rx_hwtcl                                                  ;// String  : "disable";
localparam ast_width                                     = (ast_width_hwtcl=="Avalon-ST 256-bit")?"rx_tx_256":(ast_width_hwtcl=="Avalon-ST 128-bit")?"rx_tx_128":"rx_tx_64";// String  : "rx_tx_64";
localparam rx_ast_parity                                 = (use_ast_parity==0)?"disable":"enable"                              ;// String  : "disable";
localparam tx_ast_parity                                 = (use_ast_parity==0)?"disable":"enable"                              ;// String  : "disable";
localparam ltssm_1ms_timeout                             = ltssm_1ms_timeout_hwtcl                                             ;// String  : "disable";
localparam ltssm_freqlocked_check                        = ltssm_freqlocked_check_hwtcl                                        ;// String  : "disable";
localparam deskew_comma                                  = deskew_comma_hwtcl                                                  ;// String  : "skp_eieos_deskw";
localparam [7:0] port_link_number                        = port_link_number_hwtcl                                     ;// integer : 8'b1;
localparam [4:0] device_number                           = device_number_hwtcl                                        ;// Integer : 5'b0;
localparam bypass_clk_switch                             = bypass_clk_switch_hwtcl                                             ;// String  : "TRUE";
localparam pipex1_debug_sel                              = pipex1_debug_sel_hwtcl                                              ;// String  : "disable";
localparam pclk_out_sel                                  = pclk_out_sel_hwtcl                                                  ;// String  : "pclk";
localparam [15:0] vendor_id                              = vendor_id_hwtcl                                           ;// integer : 16'b1000101110010;
localparam [15:0] device_id                              = device_id_hwtcl                                           ;// integer : 16'b1;
localparam [ 7:0] revision_id                            = revision_id_hwtcl                                          ;// integer : 8'b1;
localparam [23:0] class_code                             = class_code_hwtcl                                          ;// integer : 24'b111111110000000000000000;
localparam [15:0] subsystem_vendor_id                    = subsystem_vendor_id_hwtcl                                 ;// integer : 16'b1000101110010;
localparam [15:0] subsystem_device_id                    = subsystem_device_id_hwtcl                                 ;// integer : 16'b1;

localparam no_soft_reset                                 = no_soft_reset_hwtcl                                        ;// String  : "false";
localparam [2:0] maximum_current                         = maximum_current_hwtcl                                      ;// integer : 3'b0;
localparam d1_support                                    = d1_support_hwtcl                                                    ;// String  : "false";
localparam d2_support                                    = d2_support_hwtcl                                                    ;// String  : "false";
localparam d0_pme                                        = d0_pme_hwtcl                                                        ;// String  : "false";
localparam d1_pme                                        = d1_pme_hwtcl                                                        ;// String  : "false";
localparam d2_pme                                        = d2_pme_hwtcl                                                        ;// String  : "false";
localparam d3_hot_pme                                    = d3_hot_pme_hwtcl                                                    ;// String  : "false";
localparam d3_cold_pme                                   = d3_cold_pme_hwtcl                                                   ;// String  : "false";
localparam use_aer                                       = (use_aer_hwtcl==1)?"true":"false"                                   ;// String  : "false";
localparam low_priority_vc                               = low_priority_vc_hwtcl                                               ;// String  : "single_vc";
localparam disable_snoop_packet                          = disable_snoop_packet_hwtcl                                          ;// String  : "false";
localparam max_payload_size                              = (max_payload_size_hwtcl==128 )?"payload_128":
                                                           (max_payload_size_hwtcl==256 )?"payload_256":
                                                           (max_payload_size_hwtcl==512 )?"payload_512":
                                                           (max_payload_size_hwtcl==1024)?"payload_1024":
                                                           (max_payload_size_hwtcl==2048)?"payload_2048":"payload_128"         ;// String  : "payload_512";
localparam surprise_down_error_support                   = (surprise_down_error_support_hwtcl==1)?"true":"false"               ;// String  : "false";
localparam dll_active_report_support                     = (dll_active_report_support_hwtcl  ==1)?"true":"false"               ;// String  : "false";
localparam extend_tag_field                              = (extend_tag_field_hwtcl=="32")?"false":"true"                       ;// String  : "false";
localparam [2:0] endpoint_l0_latency                     = endpoint_l0_latency_hwtcl                                  ;// Integer : 3'b0;
localparam [2:0] endpoint_l1_latency                     = endpoint_l1_latency_hwtcl                                  ;// Integer : 3'b0;
localparam [2:0] indicator                               = indicator_hwtcl                                            ;// Integer : 3'b111;
localparam [1:0] slot_power_scale                        = slot_power_scale_hwtcl                                     ;// Integer : 2'b0;
localparam max_link_width                                = lane_mask_hwtcl                                                     ;// String  : "x4";
localparam enable_l1_aspm                                = enable_l1_aspm_hwtcl                                                ;// String  : "false";
localparam [2:0] l1_exit_latency_sameclock               = l1_exit_latency_sameclock_hwtcl                            ;// Integer : 3'b0;
localparam [2:0] l1_exit_latency_diffclock               = l1_exit_latency_diffclock_hwtcl                            ;// Integer : 3'b0;
localparam [6:0] hot_plug_support                        = hot_plug_support_hwtcl                                     ;// Integer : 7'b0;
localparam [7:0] slot_power_limit                        = slot_power_limit_hwtcl                                     ;// Integer : 8'b0;
localparam [12:0] slot_number                            = slot_number_hwtcl                                         ;// Integer : 13'b0;
localparam [7:0] diffclock_nfts_count                    = diffclock_nfts_count_hwtcl                                 ;// Integer : 8'b0;
localparam [7:0] sameclock_nfts_count                    = sameclock_nfts_count_hwtcl                                 ;// Integer : 8'b0;
localparam completion_timeout                            = completion_timeout_hwtcl                                            ;// String  : "abcd";
localparam enable_completion_timeout_disable             = (enable_completion_timeout_disable_hwtcl==1)?"true":"false"        ;// String  : "true";
localparam extended_tag_reset                            = extended_tag_reset_hwtcl                                            ;// String  : "false";
localparam ecrc_check_capable                            = (ecrc_check_capable_hwtcl==1)?"true":"false"                        ;// String  : "true";
localparam ecrc_gen_capable                              = (ecrc_gen_capable_hwtcl  ==1)?"true":"false"                        ;// String  : "true";
localparam no_command_completed                          = no_command_completed_hwtcl                                          ;// String  : "true";
localparam msi_multi_message_capable                     = (msi_multi_message_capable_hwtcl=="1")?"count_1":
                                                           (msi_multi_message_capable_hwtcl=="2")?"count_2":
                                                           (msi_multi_message_capable_hwtcl=="4")?"count_4":
                                                           (msi_multi_message_capable_hwtcl=="8")?"count_8":"count_16"         ;// String  : "count_4";
localparam msi_64bit_addressing_capable                  = msi_64bit_addressing_capable_hwtcl                                  ;// String  : "true";
localparam msi_masking_capable                           = msi_masking_capable_hwtcl                                           ;// String  : "false";
localparam msi_support                                   = msi_support_hwtcl                                                   ;// String  : "true";
localparam interrupt_pin                                 = interrupt_pin_hwtcl                                                 ;// String  : "inta";
localparam enable_function_msix_support                  = (enable_function_msix_support_hwtcl==1)?"true":"false"              ;// String  : "true";
localparam [10:0] msix_table_size                        = msix_table_size_hwtcl                                     ;// Integer : 11'b0;
localparam [2:0]  msix_table_bir                         = msix_table_bir_hwtcl                                       ;// Integer : 3'b0;
localparam [28:0] msix_table_offset                      = msix_table_offset_hwtcl                                   ;// Integer : 29'b0;
localparam [2:0]  msix_pba_bir                           = msix_pba_bir_hwtcl                                         ;// Integer : 3'b0;
localparam [28:0] msix_pba_offset                        = msix_pba_offset_hwtcl                                     ;// Integer : 29'b0;
localparam bridge_port_vga_enable                        = bridge_port_vga_enable_hwtcl                                        ;// String  : "false";
localparam bridge_port_ssid_support                      = bridge_port_ssid_support_hwtcl                                      ;// String  : "false";
localparam [15:0] ssvid                                  = ssvid_hwtcl                                               ;// String  : 16'b0;
localparam [15:0] ssid                                   = ssid_hwtcl                                                ;// String  : 16'b0;
localparam [ 3:0] eie_before_nfts_count                  = eie_before_nfts_count_hwtcl                                ;// String  : 4'b100;
localparam [ 7:0] gen2_diffclock_nfts_count              = gen2_diffclock_nfts_count_hwtcl                            ;// String  : 8'b11111111;
localparam [ 7:0] gen2_sameclock_nfts_count              = gen2_sameclock_nfts_count_hwtcl                            ;// String  : 8'b11111111;
localparam deemphasis_enable                             = deemphasis_enable_hwtcl                                             ;// String  : "false";
localparam pcie_spec_version                             = (pcie_spec_version_hwtcl=="2.1")?"v2":"v2"                          ;// String  : "v2";
localparam [2:0] l0_exit_latency_sameclock               = l0_exit_latency_sameclock_hwtcl                            ;// String  : 3'b110;
localparam [2:0] l0_exit_latency_diffclock               = l0_exit_latency_diffclock_hwtcl                            ;// String  : 3'b110;
localparam rx_ei_l0s                                     = (rx_ei_l0s_hwtcl==0)?"disable":"enable"                             ;// String  : "disable";
localparam l2_async_logic                                = l2_async_logic_hwtcl                                                ;// String  : "enable";
localparam aspm_config_management                        = aspm_config_management_hwtcl                                        ;// String  : "true";
localparam atomic_op_routing                             = atomic_op_routing_hwtcl                                             ;// String  : "false";
localparam atomic_op_completer_32bit                     = atomic_op_completer_32bit_hwtcl                                     ;// String  : "false";
localparam atomic_op_completer_64bit                     = atomic_op_completer_64bit_hwtcl                                     ;// String  : "false";
localparam cas_completer_128bit                          = cas_completer_128bit_hwtcl                                          ;// String  : "false";
localparam ltr_mechanism                                 = ltr_mechanism_hwtcl                                                 ;// String  : "false";
localparam tph_completer                                 = tph_completer_hwtcl                                                 ;// String  : "false";
localparam extended_format_field                         = extended_format_field_hwtcl                                         ;// String  : "true";
localparam atomic_malformed                              = atomic_malformed_hwtcl                                              ;// String  : "false";
localparam flr_capability                                = flr_capability_hwtcl                                                ;// String  : "true";
localparam enable_adapter_half_rate_mode                 = enable_adapter_half_rate_mode_hwtcl                                 ;// String  : "false";
localparam vc0_clk_enable                                = vc0_clk_enable_hwtcl                                                ;// String  : "true";
localparam register_pipe_signals                         = register_pipe_signals_hwtcl                                         ;// String  : "false";

localparam bar0_io_space                                 = (bar0_io_space_hwtcl        == "Enabled")?"true":"false"            ;// String  : "false";
localparam bar0_bar_type                                 = (bar0_io_space_hwtcl        == "Enabled")?"true":"false"            ;// String  : "false";
localparam bar0_64bit_mem_space                          = (bar0_64bit_mem_space_hwtcl == "Enabled")?"true":"false"            ;// String  : "true";
localparam bar0_prefetchable                             = (bar0_prefetchable_hwtcl    == "Enabled")?"true":"false"            ;// String  : "true";
localparam bar0_size_mask                                = bar0_size_mask_hwtcl                                                ;// String  : "256 MBytes - 28 bits";
localparam bar1_io_space                                 = (bar1_io_space_hwtcl        == "Enabled")?"true":"false"            ;// String  : "false";
localparam bar1_64bit_mem_space                          = (bar1_64bit_mem_space_hwtcl == "Enabled")?"true":"false"            ;// String  : "false";
localparam bar1_prefetchable                             = (bar1_prefetchable_hwtcl    == "Enabled")?"true":"false"            ;// String  : "false";
localparam bar1_size_mask                                = bar1_size_mask_hwtcl                                                ;// String  : "N/A";
localparam bar2_io_space                                 = (bar2_io_space_hwtcl        == "Enabled")?"true":"false"            ;// String  : "false";
localparam bar2_64bit_mem_space                          = (bar2_64bit_mem_space_hwtcl == "Enabled")?"true":"false"            ;// String  : "false";
localparam bar2_prefetchable                             = (bar2_prefetchable_hwtcl    == "Enabled")?"true":"false"            ;// String  : "false";
localparam bar2_size_mask                                = bar2_size_mask_hwtcl                                                ;// String  : "N/A";
localparam bar3_io_space                                 = (bar3_io_space_hwtcl        == "Enabled")?"true":"false"            ;// String  : "false";
localparam bar3_64bit_mem_space                          = (bar3_64bit_mem_space_hwtcl == "Enabled")?"true":"false"            ;// String  : "false";
localparam bar3_prefetchable                             = (bar3_prefetchable_hwtcl    == "Enabled")?"true":"false"            ;// String  : "false";
localparam bar3_size_mask                                = bar3_size_mask_hwtcl                                                ;// String  : "N/A";
localparam bar4_io_space                                 = (bar4_io_space_hwtcl        == "Enabled")?"true":"false"            ;// String  : "false";
localparam bar4_64bit_mem_space                          = (bar4_64bit_mem_space_hwtcl == "Enabled")?"true":"false"            ;// String  : "false";
localparam bar4_prefetchable                             = (bar4_prefetchable_hwtcl    == "Enabled")?"true":"false"            ;// String  : "false";
localparam bar4_size_mask                                = bar4_size_mask_hwtcl                                                ;// String  : "N/A";
localparam bar5_io_space                                 = (bar5_io_space_hwtcl         == "Enabled")?"true":"false"           ;// String  : "false";
localparam bar5_64bit_mem_space                          = (bar5_64bit_mem_space_hwtcl  == "Enabled")?"true":"false"           ;// String  : "false";
localparam bar5_prefetchable                             = (bar5_prefetchable_hwtcl     == "Enabled")?"true":"false"           ;// String  : "false";
localparam bar5_size_mask                                = bar5_size_mask_hwtcl                                                ;// String  : "N/A";
localparam bar_io_window_size                            = 0;

localparam expansion_base_address_register               = expansion_base_address_register_hwtcl                     ;// String  : 32'b0;

localparam io_window_addr_width                          = io_window_addr_width_hwtcl                                ;// String  : "window_32_bit";
localparam prefetchable_mem_window_addr_width            = prefetchable_mem_window_addr_width_hwtcl                  ;// String  : "prefetch_32";
localparam [10:0] skp_os_gen3_count                      = skp_os_gen3_count_hwtcl                                   ;// Integer : 11'b0;
localparam [ 3:0] tx_cdc_almost_empty                    = tx_cdc_almost_empty_hwtcl                                 ;// Integer : 4'b101;
localparam [ 3:0] rx_cdc_almost_full                     = rx_cdc_almost_full_hwtcl                                  ;// Integer : 4'b1100;
localparam [ 3:0] tx_cdc_almost_full                     = tx_cdc_almost_full_hwtcl                                  ;// Integer : 4'b1100;
localparam [ 7:0] rx_l0s_count_idl                       = rx_l0s_count_idl_hwtcl                                    ;// Integer : 8'b0;
localparam [ 3:0] cdc_dummy_insert_limit                 = cdc_dummy_insert_limit_hwtcl                              ;// Integer : 4'b1011;
localparam [ 7:0] ei_delay_powerdown_count               = ei_delay_powerdown_count_hwtcl                            ;// Integer : 8'b1010;
localparam [19:0] millisecond_cycle_count                = millisecond_cycle_count_hwtcl                             ;// Integer : 20'b0;
localparam [10:0] skp_os_schedule_count                  = skp_os_schedule_count_hwtcl                               ;// Integer : 11'b0;
localparam [10:0] fc_init_timer                          = fc_init_timer_hwtcl                                       ;// Integer : 11'b10000000000;
localparam [ 4:0] l01_entry_latency                      = l01_entry_latency_hwtcl                                   ;// Integer : 5'b11111;
localparam [ 4:0] flow_control_update_count              = flow_control_update_count_hwtcl                           ;// Integer : 5'b11110;
localparam [ 7:0] flow_control_timeout_count             = flow_control_timeout_count_hwtcl                          ;// Integer : 8'b11001000;
localparam [ 7:0] vc0_rx_flow_ctrl_posted_header         = vc0_rx_flow_ctrl_posted_header_hwtcl                      ;// Integer : 8'b110010;
localparam [11:0] vc0_rx_flow_ctrl_posted_data           = vc0_rx_flow_ctrl_posted_data_hwtcl                        ;// Integer : 12'b101101000;
localparam [ 7:0] vc0_rx_flow_ctrl_nonposted_header      = vc0_rx_flow_ctrl_nonposted_header_hwtcl                   ;// Integer : 8'b110110;
localparam [ 7:0] vc0_rx_flow_ctrl_nonposted_data        = vc0_rx_flow_ctrl_nonposted_data_hwtcl                     ;// Integer : 8'b0;
localparam [ 7:0] vc0_rx_flow_ctrl_compl_header          = vc0_rx_flow_ctrl_compl_header_hwtcl                       ;// Integer : 8'b1110000;
localparam [11:0] vc0_rx_flow_ctrl_compl_data            = vc0_rx_flow_ctrl_compl_data_hwtcl                         ;// Integer : 12'b111000000;
localparam [10:0] rx_ptr0_posted_dpram_min               = rx_ptr0_posted_dpram_min_hwtcl                            ;// Integer : 11'b0;
localparam [10:0] rx_ptr0_posted_dpram_max               = rx_ptr0_posted_dpram_max_hwtcl                            ;// Integer : 11'b0;
localparam [10:0] rx_ptr0_nonposted_dpram_min            = rx_ptr0_nonposted_dpram_min_hwtcl                         ;// Integer : 11'b0;
localparam [10:0] rx_ptr0_nonposted_dpram_max            = rx_ptr0_nonposted_dpram_max_hwtcl                         ;// Integer : 11'b0;
localparam [10:0] retry_buffer_last_active_address       = retry_buffer_last_active_address_hwtcl                    ;// Integer : 11'b11111111111;
localparam [29:0] retry_buffer_memory_settings           = retry_buffer_memory_settings_hwtcl                        ;// Integer : 30'b0;
localparam [29:0] vc0_rx_buffer_memory_settings          = vc0_rx_buffer_memory_settings_hwtcl                       ;// Integer : 30'b0;


// Not visible parameters
localparam pcie_mode                                     = "shared_mode"                                                       ;// String  : "shared_mode";
localparam rx_sop_ctrl                                   = (ast_width=="rx_tx_256")? "boundary_256":"boundary_64";// String  : "boundary_64";
localparam bist_memory_settings                          = 75'b0;
localparam credit_buffer_allocation_aux                  = credit_buffer_allocation_aux_hwtcl;
localparam iei_enable_settings                           = "gen2_infei_infsd_gen1_infei_sd";
localparam vsec_id                                       = 16'b1000101110010;
localparam cvp_rate_sel                                  = "full_rate";
localparam hard_reset_bypass                             = "true";
localparam cvp_data_compressed                           = "false";
localparam cvp_data_encrypted                            = "false";
localparam cvp_mode_reset                                = "false";
localparam cvp_clk_reset                                 = "false";

localparam ACDS_V10=1;
localparam MEM_CHECK=0;
localparam USE_INTERNAL_250MHZ_PLL = 1;
localparam in_cvp_mode = "NOT_IN_CVP_MODE";
localparam vsec_cap = 4'b0;
localparam jtag_id = 32'b0;
localparam user_id = 16'b0;
localparam cseb_extend_pci = "false";
localparam cseb_extend_pcie = "false";
localparam cseb_cpl_status_during_cvp = "config_retry_status";
localparam cseb_route_to_avl_rx_st = "cseb";
localparam cseb_config_bypass = "disable";
localparam cseb_cpl_tag_checking = "enable";
localparam cseb_bar_match_checking = "enable";
localparam cseb_min_error_checking = "false";
localparam cseb_temp_busy_crs = "completer_abort";
localparam gen3_diffclock_nfts_count = 8'b10000000;
localparam gen3_sameclock_nfts_count = 8'b10000000;
localparam gen3_coeff_errchk = "enable";
localparam gen3_paritychk = "enable";
localparam gen3_coeff_delay_count = 7'b1111101;
localparam gen3_coeff_1 = 18'b0;
localparam gen3_coeff_1_sel = "coeff_1";
localparam gen3_coeff_1_preset_hint = 3'b0;
localparam gen3_coeff_1_nxtber_more_ptr = 4'b0;
localparam gen3_coeff_1_nxtber_more = "g3_coeff_1_nxtber_more";
localparam gen3_coeff_1_nxtber_less_ptr = 4'b0;
localparam gen3_coeff_1_nxtber_less = "g3_coeff_1_nxtber_less";
localparam gen3_coeff_1_reqber = 5'b0;
localparam gen3_coeff_1_ber_meas = 6'b0;
localparam gen3_coeff_2 = 18'b0;
localparam gen3_coeff_2_sel = "coeff_2";
localparam gen3_coeff_2_preset_hint = 3'b0;
localparam gen3_coeff_2_nxtber_more_ptr = 4'b0;
localparam gen3_coeff_2_nxtber_more = "g3_coeff_2_nxtber_more";
localparam gen3_coeff_2_nxtber_less_ptr = 4'b0;
localparam gen3_coeff_2_nxtber_less = "g3_coeff_2_nxtber_less";
localparam gen3_coeff_2_reqber = 5'b0;
localparam gen3_coeff_2_ber_meas = 6'b0;
localparam gen3_coeff_3 = 18'b0;
localparam gen3_coeff_3_sel = "coeff_3";
localparam gen3_coeff_3_preset_hint = 3'b0;
localparam gen3_coeff_3_nxtber_more_ptr = 4'b0;
localparam gen3_coeff_3_nxtber_more = "g3_coeff_3_nxtber_more";
localparam gen3_coeff_3_nxtber_less_ptr = 4'b0;
localparam gen3_coeff_3_nxtber_less = "g3_coeff_3_nxtber_less";
localparam gen3_coeff_3_reqber = 5'b0;
localparam gen3_coeff_3_ber_meas = 6'b0;
localparam gen3_coeff_4 = 18'b0;
localparam gen3_coeff_4_sel = "coeff_4";
localparam gen3_coeff_4_preset_hint = 3'b0;
localparam gen3_coeff_4_nxtber_more_ptr = 4'b0;
localparam gen3_coeff_4_nxtber_more = "g3_coeff_4_nxtber_more";
localparam gen3_coeff_4_nxtber_less_ptr = 4'b0;
localparam gen3_coeff_4_nxtber_less = "g3_coeff_4_nxtber_less";
localparam gen3_coeff_4_reqber = 5'b0;
localparam gen3_coeff_4_ber_meas = 6'b0;
localparam gen3_coeff_5 = 18'b0;
localparam gen3_coeff_5_sel = "coeff_5";
localparam gen3_coeff_5_preset_hint = 3'b0;
localparam gen3_coeff_5_nxtber_more_ptr = 4'b0;
localparam gen3_coeff_5_nxtber_more = "g3_coeff_5_nxtber_more";
localparam gen3_coeff_5_nxtber_less_ptr = 4'b0;
localparam gen3_coeff_5_nxtber_less = "g3_coeff_5_nxtber_less";
localparam gen3_coeff_5_reqber = 5'b0;
localparam gen3_coeff_5_ber_meas = 6'b0;
localparam gen3_coeff_6 = 18'b0;
localparam gen3_coeff_6_sel = "coeff_6";
localparam gen3_coeff_6_preset_hint = 3'b0;
localparam gen3_coeff_6_nxtber_more_ptr = 4'b0;
localparam gen3_coeff_6_nxtber_more = "g3_coeff_6_nxtber_more";
localparam gen3_coeff_6_nxtber_less_ptr = 4'b0;
localparam gen3_coeff_6_nxtber_less = "g3_coeff_6_nxtber_less";
localparam gen3_coeff_6_reqber = 5'b0;
localparam gen3_coeff_6_ber_meas = 6'b0;
localparam gen3_coeff_7 = 18'b0;
localparam gen3_coeff_7_sel = "coeff_7";
localparam gen3_coeff_7_preset_hint = 3'b0;
localparam gen3_coeff_7_nxtber_more_ptr = 4'b0;
localparam gen3_coeff_7_nxtber_more = "g3_coeff_7_nxtber_more";
localparam gen3_coeff_7_nxtber_less_ptr = 4'b0;
localparam gen3_coeff_7_nxtber_less = "g3_coeff_7_nxtber_less";
localparam gen3_coeff_7_reqber = 5'b0;
localparam gen3_coeff_7_ber_meas = 6'b0;
localparam gen3_coeff_8 = 18'b0;
localparam gen3_coeff_8_sel = "coeff_8";
localparam gen3_coeff_8_preset_hint = 3'b0;
localparam gen3_coeff_8_nxtber_more_ptr = 4'b0;
localparam gen3_coeff_8_nxtber_more = "g3_coeff_8_nxtber_more";
localparam gen3_coeff_8_nxtber_less_ptr = 4'b0;
localparam gen3_coeff_8_nxtber_less = "g3_coeff_8_nxtber_less";
localparam gen3_coeff_8_reqber = 5'b0;
localparam gen3_coeff_8_ber_meas = 6'b0;
localparam gen3_coeff_9 = 18'b0;
localparam gen3_coeff_9_sel = "coeff_9";
localparam gen3_coeff_9_preset_hint = 3'b0;
localparam gen3_coeff_9_nxtber_more_ptr = 4'b0;
localparam gen3_coeff_9_nxtber_more = "g3_coeff_9_nxtber_more";
localparam gen3_coeff_9_nxtber_less_ptr = 4'b0;
localparam gen3_coeff_9_nxtber_less = "g3_coeff_9_nxtber_less";
localparam gen3_coeff_9_reqber = 5'b0;
localparam gen3_coeff_9_ber_meas = 6'b0;
localparam gen3_coeff_10 = 18'b0;
localparam gen3_coeff_10_sel = "coeff_10";
localparam gen3_coeff_10_preset_hint = 3'b0;
localparam gen3_coeff_10_nxtber_more_ptr = 4'b0;
localparam gen3_coeff_10_nxtber_more = "g3_coeff_10_nxtber_more";
localparam gen3_coeff_10_nxtber_less_ptr = 4'b0;
localparam gen3_coeff_10_nxtber_less = "g3_coeff_10_nxtber_less";
localparam gen3_coeff_10_reqber = 5'b0;
localparam gen3_coeff_10_ber_meas = 6'b0;
localparam gen3_coeff_11 = 18'b0;
localparam gen3_coeff_11_sel = "coeff_11";
localparam gen3_coeff_11_preset_hint = 3'b0;
localparam gen3_coeff_11_nxtber_more_ptr = 4'b0;
localparam gen3_coeff_11_nxtber_more = "g3_coeff_11_nxtber_more";
localparam gen3_coeff_11_nxtber_less_ptr = 4'b0;
localparam gen3_coeff_11_nxtber_less = "g3_coeff_11_nxtber_less";
localparam gen3_coeff_11_reqber = 5'b0;
localparam gen3_coeff_11_ber_meas = 6'b0;
localparam gen3_coeff_12 = 18'b0;
localparam gen3_coeff_12_sel = "coeff_12";
localparam gen3_coeff_12_preset_hint = 3'b0;
localparam gen3_coeff_12_nxtber_more_ptr = 4'b0;
localparam gen3_coeff_12_nxtber_more = "g3_coeff_12_nxtber_more";
localparam gen3_coeff_12_nxtber_less_ptr = 4'b0;
localparam gen3_coeff_12_nxtber_less = "g3_coeff_12_nxtber_less";
localparam gen3_coeff_12_reqber = 5'b0;
localparam gen3_coeff_12_ber_meas = 6'b0;
localparam gen3_coeff_13 = 18'b0;
localparam gen3_coeff_13_sel = "coeff_13";
localparam gen3_coeff_13_preset_hint = 3'b0;
localparam gen3_coeff_13_nxtber_more_ptr = 4'b0;
localparam gen3_coeff_13_nxtber_more = "g3_coeff_13_nxtber_more";
localparam gen3_coeff_13_nxtber_less_ptr = 4'b0;
localparam gen3_coeff_13_nxtber_less = "g3_coeff_13_nxtber_less";
localparam gen3_coeff_13_reqber = 5'b0;
localparam gen3_coeff_13_ber_meas = 6'b0;
localparam gen3_coeff_14 = 18'b0;
localparam gen3_coeff_14_sel = "coeff_14";
localparam gen3_coeff_14_preset_hint = 3'b0;
localparam gen3_coeff_14_nxtber_more_ptr = 4'b0;
localparam gen3_coeff_14_nxtber_more = "g3_coeff_14_nxtber_more";
localparam gen3_coeff_14_nxtber_less_ptr = 4'b0;
localparam gen3_coeff_14_nxtber_less = "g3_coeff_14_nxtber_less";
localparam gen3_coeff_14_reqber = 5'b0;
localparam gen3_coeff_14_ber_meas = 6'b0;
localparam gen3_coeff_15 = 18'b0;
localparam gen3_coeff_15_sel = "coeff_15";
localparam gen3_coeff_15_preset_hint = 3'b0;
localparam gen3_coeff_15_nxtber_more_ptr = 4'b0;
localparam gen3_coeff_15_nxtber_more = "g3_coeff_15_nxtber_more";
localparam gen3_coeff_15_nxtber_less_ptr = 4'b0;
localparam gen3_coeff_15_nxtber_less = "g3_coeff_15_nxtber_less";
localparam gen3_coeff_15_reqber = 5'b0;
localparam gen3_coeff_15_ber_meas = 6'b0;
localparam gen3_coeff_16 = 18'b0;
localparam gen3_coeff_16_sel = "coeff_16";
localparam gen3_coeff_16_preset_hint = 3'b0;
localparam gen3_coeff_16_nxtber_more_ptr = 4'b0;
localparam gen3_coeff_16_nxtber_more = "g3_coeff_16_nxtber_more";
localparam gen3_coeff_16_nxtber_less_ptr = 4'b0;
localparam gen3_coeff_16_nxtber_less = "g3_coeff_16_nxtber_less";
localparam gen3_coeff_16_reqber = 5'b0;
localparam gen3_coeff_16_ber_meas = 6'b0;
localparam gen3_preset_coeff_1 = 18'b0;
localparam gen3_preset_coeff_2 = 18'b0;
localparam gen3_preset_coeff_3 = 18'b0;
localparam gen3_preset_coeff_4 = 18'b0;
localparam gen3_preset_coeff_5 = 18'b0;
localparam gen3_preset_coeff_6 = 18'b0;
localparam gen3_preset_coeff_7 = 18'b0;
localparam gen3_preset_coeff_8 = 18'b0;
localparam gen3_preset_coeff_9 = 18'b0;
localparam gen3_preset_coeff_10 = 18'b0;
localparam gen3_rxfreqlock_counter = 20'b0;
localparam QW_ZERO                 = 64'h0;
localparam INTENDED_DEVICE_FAMILY = "Stratix V";


localparam PLD_CLK_IS_250MHZ = (is_pld_clk_250MHz(ast_width_hwtcl, gen123_lane_rate_mode_hwtcl, lane_mask_hwtcl ));


// Input for internal test port (PE/TE)
wire                 gnd_entest             = 1'b0;
wire                 gnd_frzlogic           = 1'b0;
wire                 gnd_frzreg             = 1'b0;
wire  [7 : 0]        gnd_idrcv              = QW_ZERO[7 : 0];
wire  [7 : 0]        gnd_idrpl              = QW_ZERO[7 : 0];
wire                 gnd_bistenrcv          = 1'b0;
wire                 gnd_bistenrpl          = 1'b0;
wire                 gnd_bistscanen         = 1'b0;
wire                 gnd_bistscanin         = 1'b0;
wire                 gnd_bisttesten         = 1'b0;
wire                 gnd_memhiptestenable   = 1'b0;
wire                 gnd_memredenscan       = 1'b0;
wire                 gnd_memredscen         = 1'b0;
wire                 gnd_memredscin         = 1'b0;
wire                 gnd_memredsclk         = 1'b0;
wire                 gnd_memredscrst        = 1'b0;
wire                 gnd_memredscsel        = 1'b0;
wire                 gnd_memregscanen       = 1'b0;
wire                 gnd_memregscanin       = 1'b0;
wire                 gnd_scanmoden          = 1'b0;
wire                 gnd_usermode           = 1'b0;
wire                 gnd_scanshiftn         = 1'b0;
wire                 gnd_nfrzdrv            = 1'b0;
wire                 gnd_plniotri           = 1'b0;
// Input for past QII 10.0 support
wire  [31 : 0]       gnd_csebrddata         = QW_ZERO[31 : 0];
wire  [3 : 0]        gnd_csebrddataparity   = QW_ZERO[3 : 0];
wire  [2 : 0]        gnd_csebrdresponse     = QW_ZERO[2 : 0];
wire                 gnd_csebwaitrequest    = 1'b0;
wire  [2 : 0]        gnd_csebwrresponse     = QW_ZERO[2 : 0];
wire                 gnd_csebwrrespvalid    = 1'b0;
wire  [43 : 0]       gnd_dbgpipex1rx        = QW_ZERO[43 : 0];
wire  [1 : 0]        gnd_swctmod            = QW_ZERO[1 : 0];
wire  [2 : 0]        gnd_swdn_in            = QW_ZERO[2 : 0];
wire  [6 : 0]        gnd_swup_in            = QW_ZERO[6 : 0];
wire                 gnd_cal_blk_clk        = 1'b0;


wire [1 :0]        tx_st_empty;
wire               tx_st_eop;
wire               tx_st_err;
wire               tx_st_sop;
wire [avmm_width_hwtcl-1 : 0]     tx_st_data;
wire [(avmm_width_hwtcl/8)-1:0]      tx_st_parity;
wire [avmm_width_hwtcl-1 : 0]     rx_st_data;
wire [(avmm_width_hwtcl/8)-1:0]      rx_st_parity;
wire [(avmm_width_hwtcl/8)-1:0]      rx_st_be;
wire [3 : 0]       rx_st_sop_int;
wire [3 : 0]       rx_st_valid_int;
wire [1 : 0]       rx_st_empty_int;
wire [3 : 0]       rx_st_eop_int;
wire [3 : 0]       rx_st_err_int;
wire [7 : 0]       rx_st_bardec1;
wire [7 : 0]       rx_st_bardec2;


wire                serdes_pll_locked;
wire                pld_clk_inuse;
wire                pld_core_ready;
wire                coreclkout_pll_locked;
wire                coreclkout_hip;
wire                pld_clk_hip;
reg           [1:0] pld_clk_rst_r;
reg                 pld_clk_rst;
wire                app_rstn;

//  Application interface
wire                  serr_out;
wire                  app_int_ack;
wire                  app_msi_ack;
wire                  lmi_ack;
wire   [31 : 0]       lmi_dout;
wire                  pme_to_sr;

wire   [7 : 0]        rx_st_bar;
wire                  rx_st_sop;
wire                  rx_st_valid;
wire  [1 : 0]         rx_st_empty;
wire                  rx_st_eop;
wire                  rx_st_err;

wire   [11 : 0]       tx_cred_datafccp;
wire   [11 : 0]       tx_cred_datafcnp;
wire   [11 : 0]       tx_cred_datafcp;
wire   [5 : 0]        tx_cred_fchipcons;
wire   [5 : 0]        tx_cred_fcinfinite;
wire   [7 : 0]        tx_cred_hdrfccp;
wire   [7 : 0]        tx_cred_hdrfcnp;
wire   [7 : 0]        tx_cred_hdrfcp;
wire                  tx_st_ready;

wire  [1 : 0]        mode;

// Internal wire for internal test port (PE/TE)
wire [32 : 0] open_csebaddr;
wire [4 : 0]  open_csebaddrparity;
wire [3 : 0]  open_csebbe;
wire          open_csebisshadow;
wire          open_csebrden;
wire [31 : 0] open_csebwrdata;
wire [3 : 0]  open_csebwrdataparity;
wire          open_csebwren;
wire          open_csebwrrespreq;
wire [6 : 0]  open_swdnout;
wire [2 : 0]  open_swupout;
wire          open_bistdonearcv;
wire          open_bistdonearcv1;
wire          open_bistdonearpl;
wire          open_bistdonebrcv;
wire          open_bistdonebrcv1;
wire          open_bistdonebrpl;
wire          open_bistpassrcv;
wire          open_bistpassrcv1;
wire          open_bistpassrpl;
wire          open_bistscanoutrcv;
wire          open_bistscanoutrcv1;
wire          open_bistscanoutrpl;
wire          open_memredscout;
wire          open_memregscanout;
wire          open_wakeoen;


// Application signals
wire  [4 : 0]        aer_msi_num;
wire                 app_int_sts;
wire  [4 : 0]        app_msi_num;
wire                 app_msi_req;
wire  [2 : 0]        app_msi_tc;
wire  [4 : 0]        pex_msi_num;

wire                 pm_auxpwr;
wire  [9 : 0]        pm_data;
wire                 pme_to_cr;
wire                 pm_event;
wire                 rx_st_mask;
wire                 rx_st_ready;

wire                 tx_st_valid;
wire  [6 :0]         cpl_err;
wire                 cpl_pending;
wire                 tl_slotclk_cfg;

wire           avalon_rstn;
wire           avalon_clk;

reg [2:0]   reset_status_sync_pldclk_r;
wire        reset_status_sync_pldclk;
wire        npor_int;

wire      reset_status_int;
wire      app_int_sts_internal;
wire      tx_cons_cred_sel;

assign mode = (port_type_hwtcl=="Native endpoint")?2'b00:2'b01;


altpcie_sv_hip_ast_hwtcl # (
           .pll_refclk_freq_hwtcl                         (pll_refclk_freq_hwtcl                                   ),
         .enable_slot_register_hwtcl                    (enable_slot_register_hwtcl                              ),
           .port_type_hwtcl                               (port_type_hwtcl                                         ),
         .bypass_cdc_hwtcl                              (bypass_cdc_hwtcl                                        ),
         .enable_rx_buffer_checking_hwtcl               (enable_rx_buffer_checking_hwtcl                         ),
         .single_rx_detect_hwtcl                        (single_rx_detect_hwtcl                                  ),
         .use_crc_forwarding_hwtcl                      (use_crc_forwarding_hwtcl                                ),
           .gen123_lane_rate_mode_hwtcl                   (gen123_lane_rate_mode_hwtcl                             ),
           .lane_mask_hwtcl                               (lane_mask_hwtcl                                         ),
           .set_pld_clk_x1_625MHz_hwtcl                   (set_pld_clk_x1_625MHz_hwtcl                             ),
           .in_cvp_mode_hwtcl                             (in_cvp_mode_hwtcl                                       ),
           .slotclkcfg_hwtcl                              (slotclkcfg_hwtcl                                        ),
           .reconfig_to_xcvr_width                        (reconfig_to_xcvr_width                                  ),
           .reconfig_from_xcvr_width                      (reconfig_from_xcvr_width                                ),
           .enable_l0s_aspm_hwtcl                         (enable_l0s_aspm_hwtcl                                   ),
           .cpl_spc_header_hwtcl                          (cpl_spc_header_hwtcl                                    ),
           .cpl_spc_data_hwtcl                            (cpl_spc_data_hwtcl                                      ),
           .port_width_be_hwtcl                           (port_width_be_hwtcl                                     ),
           .port_width_data_hwtcl                         (port_width_data_hwtcl                                   ),
         .reserved_debug_hwtcl                          (reserved_debug_hwtcl                                    ),
         .hip_reconfig_hwtcl                            (hip_reconfig_hwtcl                                      ),
         .vsec_id_hwtcl                                 (vsec_id_hwtcl                                           ),
         .vsec_rev_hwtcl                                (vsec_rev_hwtcl                                          ),
         .gen3_rxfreqlock_counter_hwtcl                 (gen3_rxfreqlock_counter_hwtcl                           ),
           .gen3_skip_ph2_ph3_hwtcl                       (gen3_skip_ph2_ph3_hwtcl                                 ),
           .g3_bypass_equlz_hwtcl                         (g3_bypass_equlz_hwtcl                                   ),
           .enable_tl_only_sim_hwtcl                      (enable_tl_only_sim_hwtcl                                ),
           .use_atx_pll_hwtcl                             (use_atx_pll_hwtcl                                       ),
         .cvp_rate_sel_hwtcl                            (cvp_rate_sel_hwtcl                                      ),
         .cvp_data_compressed_hwtcl                     (cvp_data_compressed_hwtcl                               ),
         .cvp_data_encrypted_hwtcl                      (cvp_data_encrypted_hwtcl                                ),
         .cvp_mode_reset_hwtcl                          (cvp_mode_reset_hwtcl                                    ),
         .cvp_clk_reset_hwtcl                           (cvp_clk_reset_hwtcl                                     ),
           .cseb_cpl_status_during_cvp_hwtcl              (cseb_cpl_status_during_cvp_hwtcl                        ),
           .core_clk_sel_hwtcl                            (core_clk_sel_hwtcl                                      ),
         .disable_link_x2_support_hwtcl                 (disable_link_x2_support_hwtcl                           ),
           .hip_hard_reset_hwtcl                          (hip_hard_reset_hwtcl                                    ),
         .wrong_device_id_hwtcl                         (wrong_device_id_hwtcl                                   ),
         .data_pack_rx_hwtcl                            (data_pack_rx_hwtcl                                      ),
           .ast_width_hwtcl                               (ast_width_hwtcl                                         ),
         .use_ast_parity                                (use_ast_parity                                          ),
         .ltssm_1ms_timeout_hwtcl                       (ltssm_1ms_timeout_hwtcl                                 ),
         .ltssm_freqlocked_check_hwtcl                  (ltssm_freqlocked_check_hwtcl                            ),
         .deskew_comma_hwtcl                            (deskew_comma_hwtcl                                      ),
           .port_link_number_hwtcl                        (port_link_number_hwtcl                                  ),
         .device_number_hwtcl                           (device_number_hwtcl                                     ),
           .bypass_clk_switch_hwtcl                       (bypass_clk_switch_hwtcl                                 ),
         .pipex1_debug_sel_hwtcl                        (pipex1_debug_sel_hwtcl                                  ),
         .pclk_out_sel_hwtcl                            (pclk_out_sel_hwtcl                                      ),
           .vendor_id_hwtcl                               (vendor_id_hwtcl                                         ),
           .device_id_hwtcl                               (device_id_hwtcl                                         ),
           .revision_id_hwtcl                             (revision_id_hwtcl                                       ),
           .class_code_hwtcl                              (class_code_hwtcl                                        ),
           .subsystem_vendor_id_hwtcl                     (subsystem_vendor_id_hwtcl                               ),
           .subsystem_device_id_hwtcl                     (subsystem_device_id_hwtcl                               ),
         .no_soft_reset_hwtcl                           (no_soft_reset_hwtcl                                     ),
         .maximum_current_hwtcl                         (maximum_current_hwtcl                                   ),
         .d1_support_hwtcl                              (d1_support_hwtcl                                        ),
         .d2_support_hwtcl                              (d2_support_hwtcl                                        ),
         .d0_pme_hwtcl                                  (d0_pme_hwtcl                                            ),
         .d1_pme_hwtcl                                  (d1_pme_hwtcl                                            ),
         .d2_pme_hwtcl                                  (d2_pme_hwtcl                                            ),
         .d3_hot_pme_hwtcl                              (d3_hot_pme_hwtcl                                        ),
         .d3_cold_pme_hwtcl                             (d3_cold_pme_hwtcl                                       ),
           .use_aer_hwtcl                                 (use_aer_hwtcl                                           ),
         .low_priority_vc_hwtcl                         (low_priority_vc_hwtcl                                   ),
         .disable_snoop_packet_hwtcl                    (disable_snoop_packet_hwtcl                              ),
           .max_payload_size_hwtcl                        (max_payload_size_hwtcl                                  ),
         .surprise_down_error_support_hwtcl             (surprise_down_error_support_hwtcl                       ),
         .dll_active_report_support_hwtcl               (dll_active_report_support_hwtcl                         ),
         .extend_tag_field_hwtcl                        (extend_tag_field_hwtcl                                  ),
           .endpoint_l0_latency_hwtcl                     (endpoint_l0_latency_hwtcl                               ),
           .endpoint_l1_latency_hwtcl                     (endpoint_l1_latency_hwtcl                               ),
         .indicator_hwtcl                               (indicator_hwtcl                                         ),
         .slot_power_scale_hwtcl                        (slot_power_scale_hwtcl                                  ),
         .enable_l1_aspm_hwtcl                          (enable_l1_aspm_hwtcl                                    ),
         .l1_exit_latency_sameclock_hwtcl               (l1_exit_latency_sameclock_hwtcl                         ),
         .l1_exit_latency_diffclock_hwtcl               (l1_exit_latency_diffclock_hwtcl                         ),
         .hot_plug_support_hwtcl                        (hot_plug_support_hwtcl                                  ),
         .slot_power_limit_hwtcl                        (slot_power_limit_hwtcl                                  ),
         .slot_number_hwtcl                             (slot_number_hwtcl                                       ),
         .diffclock_nfts_count_hwtcl                    (diffclock_nfts_count_hwtcl                              ),
         .sameclock_nfts_count_hwtcl                    (sameclock_nfts_count_hwtcl                              ),
           .completion_timeout_hwtcl                      (completion_timeout_hwtcl                                ),
           .enable_completion_timeout_disable_hwtcl       (enable_completion_timeout_disable_hwtcl                 ),
         .extended_tag_reset_hwtcl                      (extended_tag_reset_hwtcl                                ),
           .ecrc_check_capable_hwtcl                      (ecrc_check_capable_hwtcl                                ),
           .ecrc_gen_capable_hwtcl                        (ecrc_gen_capable_hwtcl                                  ),
         .no_command_completed_hwtcl                    (no_command_completed_hwtcl                              ),
           .msi_multi_message_capable_hwtcl               (msi_multi_message_capable_hwtcl                         ),
           .msi_64bit_addressing_capable_hwtcl            (msi_64bit_addressing_capable_hwtcl                      ),
           .msi_masking_capable_hwtcl                     (msi_masking_capable_hwtcl                               ),
           .msi_support_hwtcl                             (msi_support_hwtcl                                       ),
         .interrupt_pin_hwtcl                           (interrupt_pin_hwtcl                                     ),
           .enable_function_msix_support_hwtcl            (enable_function_msix_support_hwtcl                      ),
           .msix_table_size_hwtcl                         (msix_table_size_hwtcl                                   ),
           .msix_table_bir_hwtcl                          (msix_table_bir_hwtcl                                    ),
           .msix_table_offset_hwtcl                       (msix_table_offset_hwtcl                                 ),
           .msix_pba_bir_hwtcl                            (msix_pba_bir_hwtcl                                      ),
           .msix_pba_offset_hwtcl                         (msix_pba_offset_hwtcl                                   ),
           .bridge_port_vga_enable_hwtcl                  (bridge_port_vga_enable_hwtcl                            ),
           .bridge_port_ssid_support_hwtcl                (bridge_port_ssid_support_hwtcl                          ),
           .ssvid_hwtcl                                   (ssvid_hwtcl                                             ),
           .ssid_hwtcl                                    (ssid_hwtcl                                              ),
           .eie_before_nfts_count_hwtcl                   (eie_before_nfts_count_hwtcl                             ),
           .gen2_diffclock_nfts_count_hwtcl               (gen2_diffclock_nfts_count_hwtcl                         ),
           .gen2_sameclock_nfts_count_hwtcl               (gen2_sameclock_nfts_count_hwtcl                         ),
           .deemphasis_enable_hwtcl                       (deemphasis_enable_hwtcl                                 ),
           .pcie_spec_version_hwtcl                       (pcie_spec_version_hwtcl                                 ),
           .l0_exit_latency_sameclock_hwtcl               (l0_exit_latency_sameclock_hwtcl                         ),
           .l0_exit_latency_diffclock_hwtcl               (l0_exit_latency_diffclock_hwtcl                         ),
             .rx_ei_l0s_hwtcl                               (rx_ei_l0s_hwtcl                                         ),
           .l2_async_logic_hwtcl                          (l2_async_logic_hwtcl                                    ),
           .aspm_config_management_hwtcl                  (aspm_config_management_hwtcl                            ),
           .atomic_op_routing_hwtcl                       (atomic_op_routing_hwtcl                                 ),
           .atomic_op_completer_32bit_hwtcl               (atomic_op_completer_32bit_hwtcl                         ),
           .atomic_op_completer_64bit_hwtcl               (atomic_op_completer_64bit_hwtcl                         ),
           .cas_completer_128bit_hwtcl                    (cas_completer_128bit_hwtcl                              ),
           .ltr_mechanism_hwtcl                           (ltr_mechanism_hwtcl                                     ),
           .tph_completer_hwtcl                           (tph_completer_hwtcl                                     ),
           .extended_format_field_hwtcl                   (extended_format_field_hwtcl                             ),
           .atomic_malformed_hwtcl                        (atomic_malformed_hwtcl                                  ),
           .flr_capability_hwtcl                          (flr_capability_hwtcl                                    ),
           .enable_adapter_half_rate_mode_hwtcl           (enable_adapter_half_rate_mode_hwtcl                     ),
           .vc0_clk_enable_hwtcl                          (vc0_clk_enable_hwtcl                                    ),
           .register_pipe_signals_hwtcl                   (register_pipe_signals_hwtcl                             ),
           .bar0_io_space_hwtcl                           (bar0_io_space_hwtcl                                     ),
           .bar0_64bit_mem_space_hwtcl                    (bar0_64bit_mem_space_hwtcl                              ),
           .bar0_prefetchable_hwtcl                       (bar0_prefetchable_hwtcl                                 ),
           .bar0_size_mask_hwtcl                          (bar0_size_mask_hwtcl                                    ),
           .bar1_io_space_hwtcl                           (bar1_io_space_hwtcl                                     ),
           .bar1_64bit_mem_space_hwtcl                    (bar1_64bit_mem_space_hwtcl                              ),
           .bar1_prefetchable_hwtcl                       (bar1_prefetchable_hwtcl                                 ),
           .bar1_size_mask_hwtcl                          (bar1_size_mask_hwtcl                                    ),
           .bar2_io_space_hwtcl                           (bar2_io_space_hwtcl                                     ),
           .bar2_64bit_mem_space_hwtcl                    (bar2_64bit_mem_space_hwtcl                              ),
           .bar2_prefetchable_hwtcl                       (bar2_prefetchable_hwtcl                                 ),
           .bar2_size_mask_hwtcl                          (bar2_size_mask_hwtcl                                    ),
           .bar3_io_space_hwtcl                           (bar3_io_space_hwtcl                                     ),
           .bar3_64bit_mem_space_hwtcl                    (bar3_64bit_mem_space_hwtcl                              ),
           .bar3_prefetchable_hwtcl                       (bar3_prefetchable_hwtcl                                 ),
           .bar3_size_mask_hwtcl                          (bar3_size_mask_hwtcl                                    ),
           .bar4_io_space_hwtcl                           (bar4_io_space_hwtcl                                     ),
           .bar4_64bit_mem_space_hwtcl                    (bar4_64bit_mem_space_hwtcl                              ),
           .bar4_prefetchable_hwtcl                       (bar4_prefetchable_hwtcl                                 ),
           .bar4_size_mask_hwtcl                          (bar4_size_mask_hwtcl                                    ),
           .bar5_io_space_hwtcl                           (bar5_io_space_hwtcl                                     ),
           .bar5_64bit_mem_space_hwtcl                    (bar5_64bit_mem_space_hwtcl                              ),
           .bar5_prefetchable_hwtcl                       (bar5_prefetchable_hwtcl                                 ),
           .bar5_size_mask_hwtcl                          (bar5_size_mask_hwtcl                                    ),
           .expansion_base_address_register_hwtcl         (expansion_base_address_register_hwtcl                   ),
           .io_window_addr_width_hwtcl                    (io_window_addr_width_hwtcl                              ),
           .prefetchable_mem_window_addr_width_hwtcl      (prefetchable_mem_window_addr_width_hwtcl                ),
           .skp_os_gen3_count_hwtcl                       (skp_os_gen3_count_hwtcl                                 ),
           .tx_cdc_almost_empty_hwtcl                     (tx_cdc_almost_empty_hwtcl                               ),
           .rx_cdc_almost_full_hwtcl                      (rx_cdc_almost_full_hwtcl                                ),
           .tx_cdc_almost_full_hwtcl                      (tx_cdc_almost_full_hwtcl                                ),
           .rx_l0s_count_idl_hwtcl                        (rx_l0s_count_idl_hwtcl                                  ),
           .cdc_dummy_insert_limit_hwtcl                  (cdc_dummy_insert_limit_hwtcl                            ),
           .ei_delay_powerdown_count_hwtcl                (ei_delay_powerdown_count_hwtcl                          ),
           .millisecond_cycle_count_hwtcl                 (millisecond_cycle_count_hwtcl                           ),
           .skp_os_schedule_count_hwtcl                   (skp_os_schedule_count_hwtcl                             ),
           .fc_init_timer_hwtcl                           (fc_init_timer_hwtcl                                     ),
           .l01_entry_latency_hwtcl                       (l01_entry_latency_hwtcl                                 ),
           .flow_control_update_count_hwtcl               (flow_control_update_count_hwtcl                         ),
           .flow_control_timeout_count_hwtcl              (flow_control_timeout_count_hwtcl                        ),
           .credit_buffer_allocation_aux_hwtcl            (credit_buffer_allocation_aux_hwtcl                      ),
           .vc0_rx_flow_ctrl_posted_header_hwtcl          (vc0_rx_flow_ctrl_posted_header_hwtcl                    ),
           .vc0_rx_flow_ctrl_posted_data_hwtcl            (vc0_rx_flow_ctrl_posted_data_hwtcl                      ),
           .vc0_rx_flow_ctrl_nonposted_header_hwtcl       (vc0_rx_flow_ctrl_nonposted_header_hwtcl                 ),
           .vc0_rx_flow_ctrl_nonposted_data_hwtcl         (vc0_rx_flow_ctrl_nonposted_data_hwtcl                   ),
           .vc0_rx_flow_ctrl_compl_header_hwtcl           (vc0_rx_flow_ctrl_compl_header_hwtcl                     ),
           .vc0_rx_flow_ctrl_compl_data_hwtcl             (vc0_rx_flow_ctrl_compl_data_hwtcl                       ),
           .retry_buffer_last_active_address_hwtcl        (retry_buffer_last_active_address_hwtcl                  ),
	   .g3_dis_rx_use_prst_hwtcl                      (g3_dis_rx_use_prst_hwtcl                                ),
	   .g3_dis_rx_use_prst_ep_hwtcl                   (g3_dis_rx_use_prst_ep_hwtcl                             ),
	   .hwtcl_override_g2_txvod			  (hwtcl_override_g2_txvod				   ),
           .rpre_emph_a_val_hwtcl                         (rpre_emph_a_val_hwtcl                                   ),
           .rpre_emph_b_val_hwtcl                         (rpre_emph_b_val_hwtcl                                   ),
           .rpre_emph_c_val_hwtcl                         (rpre_emph_c_val_hwtcl                                   ),
           .rpre_emph_d_val_hwtcl                         (rpre_emph_d_val_hwtcl                                   ),
           .rpre_emph_e_val_hwtcl                         (rpre_emph_e_val_hwtcl                                   ),
           .rvod_sel_a_val_hwtcl                          (rvod_sel_a_val_hwtcl                                    ),
           .rvod_sel_b_val_hwtcl                          (rvod_sel_b_val_hwtcl                                    ),
           .rvod_sel_c_val_hwtcl                          (rvod_sel_c_val_hwtcl                                    ),
           .rvod_sel_d_val_hwtcl                          (rvod_sel_d_val_hwtcl                                    ),
           .rvod_sel_e_val_hwtcl                          (rvod_sel_e_val_hwtcl                                    )

  ) altera_s5_a2p (
                 // Control signals
      .test_in(test_in),
      .simu_mode_pipe(simu_mode_pipe),          // When 1'b1 indicate running DUT under pipe simulation

      // Reset signals
      .pin_perst         (pin_perst        ),
      .npor              (npor             ),
      .reset_status      (reset_status_int ),
      .serdes_pll_locked (serdes_pll_locked),
      .pld_clk_inuse     (pld_clk_inuse    ),
      .pld_core_ready    (pld_core_ready   ),
      .testin_zero       (      ),

      // Clock
      .pld_clk(pld_clk_hip),

      // Serdes related
      .refclk(refclk),

      // HIP control signals
      .hpg_ctrler(hpg_ctrler),

      // Input PIPE simulation _ext for simulation only
      .sim_pipe_rate(sim_pipe_rate),
      .sim_pipe_pclk_in(sim_pipe_pclk_in),
      .sim_pipe_pclk_out(sim_pipe_pclk_out),
      .sim_pipe_clk250_out(sim_pipe_clk250_out),
      .sim_pipe_clk500_out(sim_pipe_clk500_out),
      .sim_ltssmstate(sim_ltssmstate),
      .phystatus0(phystatus0),
      .phystatus1(phystatus1),
      .phystatus2(phystatus2),
      .phystatus3(phystatus3),
      .phystatus4(phystatus4),
      .phystatus5(phystatus5),
      .phystatus6(phystatus6),
      .phystatus7(phystatus7),
      .rxdata0(rxdata0),
      .rxdata1(rxdata1),
      .rxdata2(rxdata2),
      .rxdata3(rxdata3),
      .rxdata4(rxdata4),
      .rxdata5(rxdata5),
      .rxdata6(rxdata6),
      .rxdata7(rxdata7),
      .rxdatak0(rxdatak0),
      .rxdatak1(rxdatak1),
      .rxdatak2(rxdatak2),
      .rxdatak3(rxdatak3),
      .rxdatak4(rxdatak4),
      .rxdatak5(rxdatak5),
      .rxdatak6(rxdatak6),
      .rxdatak7(rxdatak7),
      .rxelecidle0(rxelecidle0),
      .rxelecidle1(rxelecidle1),
      .rxelecidle2(rxelecidle2),
      .rxelecidle3(rxelecidle3),
      .rxelecidle4(rxelecidle4),
      .rxelecidle5(rxelecidle5),
      .rxelecidle6(rxelecidle6),
      .rxelecidle7(rxelecidle7),
      .rxfreqlocked0(rxfreqlocked0),
      .rxfreqlocked1(rxfreqlocked1),
      .rxfreqlocked2(rxfreqlocked2),
      .rxfreqlocked3(rxfreqlocked3),
      .rxfreqlocked4(rxfreqlocked4),
      .rxfreqlocked5(rxfreqlocked5),
      .rxfreqlocked6(rxfreqlocked6),
      .rxfreqlocked7(rxfreqlocked7),
      .rxstatus0(rxstatus0),
      .rxstatus1(rxstatus1),
      .rxstatus2(rxstatus2),
      .rxstatus3(rxstatus3),
      .rxstatus4(rxstatus4),
      .rxstatus5(rxstatus5),
      .rxstatus6(rxstatus6),
      .rxstatus7(rxstatus7),
      .rxdataskip0(rxdataskip0),
      .rxdataskip1(rxdataskip1),
      .rxdataskip2(rxdataskip2),
      .rxdataskip3(rxdataskip3),
      .rxdataskip4(rxdataskip4),
      .rxdataskip5(rxdataskip5),
      .rxdataskip6(rxdataskip6),
      .rxdataskip7(rxdataskip7),
      .rxblkst0(rxblkst0),
      .rxblkst1(rxblkst1),
      .rxblkst2(rxblkst2),
      .rxblkst3(rxblkst3),
      .rxblkst4(rxblkst4),
      .rxblkst5(rxblkst5),
      .rxblkst6(rxblkst6),
      .rxblkst7(rxblkst7),
      .rxsynchd0(rxsynchd0),
      .rxsynchd1(rxsynchd1),
      .rxsynchd2(rxsynchd2),
      .rxsynchd3(rxsynchd3),
      .rxsynchd4(rxsynchd4),
      .rxsynchd5(rxsynchd5),
      .rxsynchd6(rxsynchd6),
      .rxsynchd7(rxsynchd7),
      .rxvalid0(rxvalid0),
      .rxvalid1(rxvalid1),
      .rxvalid2(rxvalid2),
      .rxvalid3(rxvalid3),
      .rxvalid4(rxvalid4),
      .rxvalid5(rxvalid5),
      .rxvalid6(rxvalid6),
      .rxvalid7(rxvalid7),

      // Application signals inputs
      .aer_msi_num(aer_msi_num),
      .app_int_sts(1'b0),
      .app_msi_num(app_msi_num),
      .app_msi_req(app_msi_req),
      .app_msi_tc(app_msi_tc),
      .pex_msi_num(pex_msi_num),
      .lmi_addr(12'h0),
      .lmi_din(32'h0),
      .lmi_rden(1'b0),
      .lmi_wren(1'b0),
      .pm_auxpwr(1'b0),
      .pm_data(10'h0),
      .pme_to_cr(1'b0),
      .pm_event(1'b0),
      .rx_st_mask(1'b0),
      .rx_st_ready(rx_st_ready),

      .tx_st_data(tx_st_data),

      .tx_st_empty(tx_st_empty),
      .tx_st_eop(tx_st_eop),
      .tx_st_err(1'b0),
      .tx_st_sop(tx_st_sop),
      .tx_st_parity(0),
      .tx_st_valid(tx_st_valid),
      .reconfig_to_xcvr                                               (reconfig_to_xcvr                                           ),
      .reconfig_from_xcvr                                             (reconfig_from_xcvr                                         ),
      .fixedclk_locked                                                (fixedclk_locked                                            ),

      .cpl_err(7'h0),
      .cpl_pending(cpl_pending),

      // Output Pipe interface
      .eidleinfersel0(eidleinfersel0),
      .eidleinfersel1(eidleinfersel1),
      .eidleinfersel2(eidleinfersel2),
      .eidleinfersel3(eidleinfersel3),
      .eidleinfersel4(eidleinfersel4),
      .eidleinfersel5(eidleinfersel5),
      .eidleinfersel6(eidleinfersel6),
      .eidleinfersel7(eidleinfersel7),
      .powerdown0(powerdown0),
      .powerdown1(powerdown1),
      .powerdown2(powerdown2),
      .powerdown3(powerdown3),
      .powerdown4(powerdown4),
      .powerdown5(powerdown5),
      .powerdown6(powerdown6),
      .powerdown7(powerdown7),
      .rxpolarity0(rxpolarity0),
      .rxpolarity1(rxpolarity1),
      .rxpolarity2(rxpolarity2),
      .rxpolarity3(rxpolarity3),
      .rxpolarity4(rxpolarity4),
      .rxpolarity5(rxpolarity5),
      .rxpolarity6(rxpolarity6),
      .rxpolarity7(rxpolarity7),
      .txcompl0(txcompl0),
      .txcompl1(txcompl1),
      .txcompl2(txcompl2),
      .txcompl3(txcompl3),
      .txcompl4(txcompl4),
      .txcompl5(txcompl5),
      .txcompl6(txcompl6),
      .txcompl7(txcompl7),
      .txdata0(txdata0),
      .txdata1(txdata1),
      .txdata2(txdata2),
      .txdata3(txdata3),
      .txdata4(txdata4),
      .txdata5(txdata5),
      .txdata6(txdata6),
      .txdata7(txdata7),
      .txdatak0(txdatak0),
      .txdatak1(txdatak1),
      .txdatak2(txdatak2),
      .txdatak3(txdatak3),
      .txdatak4(txdatak4),
      .txdatak5(txdatak5),
      .txdatak6(txdatak6),
      .txdatak7(txdatak7),
      .txdetectrx0(txdetectrx0),
      .txdetectrx1(txdetectrx1),
      .txdetectrx2(txdetectrx2),
      .txdetectrx3(txdetectrx3),
      .txdetectrx4(txdetectrx4),
      .txdetectrx5(txdetectrx5),
      .txdetectrx6(txdetectrx6),
      .txdetectrx7(txdetectrx7),
      .txelecidle0(txelecidle0),
      .txelecidle1(txelecidle1),
      .txelecidle2(txelecidle2),
      .txelecidle3(txelecidle3),
      .txelecidle4(txelecidle4),
      .txelecidle5(txelecidle5),
      .txelecidle6(txelecidle6),
      .txelecidle7(txelecidle7),
      .txmargin0  (txmargin0  ),
      .txmargin1  (txmargin1  ),
      .txmargin2  (txmargin2  ),
      .txmargin3  (txmargin3  ),
      .txmargin4  (txmargin4  ),
      .txmargin5  (txmargin5  ),
      .txmargin6  (txmargin6  ),
      .txmargin7  (txmargin7  ),
      .txswing0  (txswing0  ),
      .txswing1  (txswing1  ),
      .txswing2  (txswing2  ),
      .txswing3  (txswing3  ),
      .txswing4  (txswing4  ),
      .txswing5  (txswing5  ),
      .txswing6  (txswing6  ),
      .txswing7  (txswing7  ),
      .txdeemph0  (txdeemph0  ),
      .txdeemph1  (txdeemph1  ),
      .txdeemph2  (txdeemph2  ),
      .txdeemph3  (txdeemph3  ),
      .txdeemph4  (txdeemph4  ),
      .txdeemph5  (txdeemph5  ),
      .txdeemph6  (txdeemph6  ),
      .txdeemph7  (txdeemph7  ),
      .txblkst0( txblkst0     ),
      .txblkst1( txblkst1     ),
      .txblkst2( txblkst2     ),
      .txblkst3( txblkst3     ),
      .txblkst4( txblkst4     ),
      .txblkst5( txblkst5     ),
      .txblkst6( txblkst6     ),
      .txblkst7( txblkst7     ),
      .txsynchd0(txsynchd0    ),
      .txsynchd1(txsynchd1    ),
      .txsynchd2(txsynchd2    ),
      .txsynchd3(txsynchd3    ),
      .txsynchd4(txsynchd4    ),
      .txsynchd5(txsynchd5    ),
      .txsynchd6(txsynchd6    ),
      .txsynchd7(txsynchd7    ),
      .currentcoeff0( currentcoeff0 ),
      .currentcoeff1( currentcoeff1 ),
      .currentcoeff2( currentcoeff2 ),
      .currentcoeff3( currentcoeff3 ),
      .currentcoeff4( currentcoeff4 ),
      .currentcoeff5( currentcoeff5 ),
      .currentcoeff6( currentcoeff6 ),
      .currentcoeff7( currentcoeff7 ),
      .currentrxpreset0(currentrxpreset0 ),
      .currentrxpreset1(currentrxpreset1 ),
      .currentrxpreset2(currentrxpreset2 ),
      .currentrxpreset3(currentrxpreset3 ),
      .currentrxpreset4(currentrxpreset4 ),
      .currentrxpreset5(currentrxpreset5 ),
      .currentrxpreset6(currentrxpreset6 ),
      .currentrxpreset7(currentrxpreset7 ),


      // Output HIP Status signals
      .coreclkout_hip(coreclkout_hip),
      .currentspeed(currentspeed),
      .derr_cor_ext_rcv(derr_cor_ext_rcv),
      .derr_cor_ext_rpl(derr_cor_ext_rpl),
      .derr_rpl(derr_rpl),
      .dlup(dlup),
      .dlup_exit(dlup_exit),
      .ev128ns(ev128ns),
      .ev1us(ev1us),
      .hotrst_exit(hotrst_exit),
      .int_status(int_status),
      .l2_exit(l2_exit),
      .lane_act(lane_act),
      .ltssmstate(ltssmstate),

      // Output Application interface
      .serr_out(),
      .app_int_ack(app_int_ack),
      .app_msi_ack(app_msi_ack),
      .lmi_ack(),
      .lmi_dout(),
      .pme_to_sr(),
      .rx_st_bar(rx_st_bar),

      .rx_st_be(rx_st_be),
      .rx_st_parity(rx_st_parity),
      .rx_st_data(rx_st_data),
      .rx_st_sop(rx_st_sop),
      .rx_st_valid(rx_st_valid),
      .rx_st_empty(rx_st_empty),
      .rx_st_eop(rx_st_eop),
      .rx_st_err(rx_st_err),
      .tl_cfg_add(tl_cfg_add),
      .tl_cfg_ctl(tl_cfg_ctl),
      .tl_cfg_sts(tl_cfg_sts),
      .tx_cred_datafccp(tx_cred_datafccp),
      .tx_cred_datafcnp(tx_cred_datafcnp),
      .tx_cred_datafcp(tx_cred_datafcp),
      .tx_cred_fchipcons(tx_cred_fchipcons),
      .tx_cred_fcinfinite(tx_cred_fcinfinite),
      .tx_cred_hdrfccp(tx_cred_hdrfccp),
      .tx_cred_hdrfcnp(tx_cred_hdrfcnp),
      .tx_cred_hdrfcp(tx_cred_hdrfcp),
      .tx_st_ready(tx_st_ready),
      .rx_in0(rx_in0),
      .rx_in1(rx_in1),
      .rx_in2(rx_in2),
      .rx_in3(rx_in3),
      .rx_in4(rx_in4),
      .rx_in5(rx_in5),
      .rx_in6(rx_in6),
      .rx_in7(rx_in7),
      .tx_out0(tx_out0),
      .tx_out1(tx_out1),
      .tx_out2(tx_out2),
      .tx_out3(tx_out3),
      .tx_out4(tx_out4),
      .tx_out5(tx_out5),
      .tx_out6(tx_out6),
      .tx_out7(tx_out7),
      .rx_par_err(rx_par_err),
      .tx_par_err(tx_par_err),
      .cfg_par_err(cfg_par_err),
      .ko_cpl_spc_header(ko_cpl_spc_header),
      .ko_cpl_spc_data(ko_cpl_spc_data),
      .tlbfm_in  (tlbfm_in),
      .tlbfm_out (tlbfm_out),

      .reservedin(reservedin)
);

//// instantiate the Avalon-MM bridge logic

altpcieav_256_app
  # (
    .DEVICE_FAMILY                  (INTENDED_DEVICE_FAMILY),
    .DMA_WIDTH                      (DMA_WIDTH             ),
    .DMA_BE_WIDTH                   (DMA_BE_WIDTH          ),
    .DMA_BRST_CNT_W                 (DMA_BRST_CNT_W        ),
    .RDDMA_AVL_ADDR_WIDTH           (rd_dma_size_mask_hwtcl),
    .WRDMA_AVL_ADDR_WIDTH           (wr_dma_size_mask_hwtcl),
    .BAR0_SIZE_MASK                 (bar0_size_mask_hwtcl  ),
    .BAR1_SIZE_MASK                 (bar1_size_mask_hwtcl  ),
    .BAR2_SIZE_MASK                 (bar2_size_mask_hwtcl  ),
    .BAR3_SIZE_MASK                 (bar3_size_mask_hwtcl  ),
    .BAR4_SIZE_MASK                 (bar4_size_mask_hwtcl  ),
    .BAR5_SIZE_MASK                 (bar5_size_mask_hwtcl  ),
    .BAR0_TYPE                      (bar0_type_hwtcl  ),
    .BAR1_TYPE                      (bar1_type_hwtcl  ),
    .BAR2_TYPE                      (bar2_type_hwtcl  ),
    .BAR3_TYPE                      (bar3_type_hwtcl  ),
    .BAR4_TYPE                      (bar4_type_hwtcl  ),
    .BAR5_TYPE                      (bar5_type_hwtcl  ),
    .TX_S_ADDR_WIDTH                (TX_S_ADDR_WIDTH)
    )
 altpcieav_256_app
  (
    .Clk_i                          (avalon_clk             ),
    .Rstn_i                         (app_rstn               ),
    .HipRxStReady_o                 ( rx_st_ready           ),
    .HipRxStMask_o                  ( rx_st_mask            ),
    .HipRxStData_i                  ( rx_st_data            ),
    .HipRxStBe_i                    ( rx_st_be              ),
    .HipRxStEmpty_i                 ( rx_st_empty           ),
    .HipRxStErr_i                   ( rx_st_err             ),
    .HipRxStSop_i                   ( rx_st_sop             ),
    .HipRxStEop_i                   ( rx_st_eop             ),
    .HipRxStValid_i                 ( rx_st_valid           ),
    .HipRxStBarDec1_i               ( rx_st_bar             ),
    .HipTxStReady_i                 ( tx_st_ready           ),
    .HipTxStData_o                  ( tx_st_data            ),
    .HipTxStSop_o                   ( tx_st_sop             ),
    .HipTxStEop_o                   ( tx_st_eop             ),
    .HipTxStEmpty_o                 ( tx_st_empty           ),
    .HipTxStValid_o                 ( tx_st_valid           ),
    .HipCplPending_o                ( cpl_pending           ),
    .AvWrDmaRead_o                  ( WrDmaRead_o           ),
    .AvWrDmaAddress_o               ( WrDmaAddress_o        ),
    .AvWrDmaBurstCount_o            ( WrDmaBurstCount_o     ),
    .AvWrDmaWaitRequest_i           ( WrDmaWaitRequest_i    ),
    .AvWrDmaReadDataValid_i         ( WrDmaReadDataValid_i  ),
    .AvWrDmaReadData_i              ( WrDmaReadData_i       ),
    .AvRdDmaWrite_o                 ( RdDmaWrite_o          ),
    .AvRdDmaAddress_o               ( RdDmaAddress_o        ),
    .AvRdDmaWriteData_o             ( RdDmaWriteData_o      ),
    .AvRdDmaBurstCount_o            ( RdDmaBurstCount_o     ),
    .AvRdDmaWriteEnable_o           ( RdDmaWriteEnable_o    ),
    .AvRdDmaWaitRequest_i           ( RdDmaWaitRequest_i    ),
    .AvRxmWrite_0_o                 ( RxmWrite_0_o          ),
    .AvRxmAddress_0_o               ( RxmAddress_0_o        ),
    .AvRxmWriteData_0_o             ( RxmWriteData_0_o      ),
    .AvRxmByteEnable_0_o            ( RxmByteEnable_0_o     ),
    .AvRxmWaitRequest_0_i           ( RxmWaitRequest_0_i    ),
    .AvRxmRead_0_o                  ( RxmRead_0_o           ),
    .AvRxmReadData_0_i              ( RxmReadData_0_i       ),
    .AvRxmReadDataValid_0_i         ( RxmReadDataValid_0_i  ),
    .AvRxmWrite_1_o                 ( RxmWrite_1_o          ),
    .AvRxmAddress_1_o               ( RxmAddress_1_o        ),
    .AvRxmWriteData_1_o             ( RxmWriteData_1_o      ),
    .AvRxmByteEnable_1_o            ( RxmByteEnable_1_o     ),
    .AvRxmWaitRequest_1_i           ( RxmWaitRequest_1_i    ),
    .AvRxmRead_1_o                  ( RxmRead_1_o           ),
    .AvRxmReadData_1_i              ( RxmReadData_1_i       ),
    .AvRxmReadDataValid_1_i         ( RxmReadDataValid_1_i  ),
    .AvRxmWrite_2_o                 ( RxmWrite_2_o          ),
    .AvRxmAddress_2_o               ( RxmAddress_2_o        ),
    .AvRxmWriteData_2_o             ( RxmWriteData_2_o      ),
    .AvRxmByteEnable_2_o            ( RxmByteEnable_2_o     ),
    .AvRxmWaitRequest_2_i           ( RxmWaitRequest_2_i    ),
    .AvRxmRead_2_o                  ( RxmRead_2_o           ),
    .AvRxmReadData_2_i              ( RxmReadData_2_i       ),
    .AvRxmReadDataValid_2_i         ( RxmReadDataValid_2_i  ),
    .AvRxmWrite_3_o                 ( RxmWrite_3_o          ),
    .AvRxmAddress_3_o               ( RxmAddress_3_o        ),
    .AvRxmWriteData_3_o             ( RxmWriteData_3_o      ),
    .AvRxmByteEnable_3_o            ( RxmByteEnable_3_o     ),
    .AvRxmWaitRequest_3_i           ( RxmWaitRequest_3_i    ),
    .AvRxmRead_3_o                  ( RxmRead_3_o           ),
    .AvRxmReadData_3_i              ( RxmReadData_3_i       ),
    .AvRxmReadDataValid_3_i         ( RxmReadDataValid_3_i  ),
    .AvRxmWrite_4_o                 ( RxmWrite_4_o          ),
    .AvRxmAddress_4_o               ( RxmAddress_4_o        ),
    .AvRxmWriteData_4_o             ( RxmWriteData_4_o      ),
    .AvRxmByteEnable_4_o            ( RxmByteEnable_4_o     ),
    .AvRxmWaitRequest_4_i           ( RxmWaitRequest_4_i    ),
    .AvRxmRead_4_o                  ( RxmRead_4_o         ),
    .AvRxmReadData_4_i              ( RxmReadData_4_i       ),
    .AvRxmReadDataValid_4_i         ( RxmReadDataValid_4_i  ),
    .AvRxmWrite_5_o                 ( RxmWrite_5_o          ),
    .AvRxmAddress_5_o               ( RxmAddress_5_o        ),
    .AvRxmWriteData_5_o             ( RxmWriteData_5_o      ),
    .AvRxmByteEnable_5_o            ( RxmByteEnable_5_o     ),
    .AvRxmWaitRequest_5_i           ( RxmWaitRequest_5_i    ),
    .AvRxmRead_5_o                  ( RxmRead_5_o           ),
    .AvRxmReadData_5_i              ( RxmReadData_5_i       ),
    .AvRxmReadDataValid_5_i         ( RxmReadDataValid_5_i  ),
    .AvTxsWrite_i                   ( TxsWrite_i            ),
    .AvTxsAddress_i                 ( TxsAddress_i          ),
    .AvTxsWriteData_i               ( TxsWriteData_i        ),
    .AvTxsByteEnable_i              ( TxsByteEnable_i       ),
    .AvTxsWaitRequest_o             ( TxsWaitRequest_o      ),
    .AvTxsRead_i                    ( TxsRead_i             ),
    .AvTxsReadData_o                ( TxsReadData_o         ),
    .AvTxsReadDataValid_o           ( TxsReadDataValid_o    ),
    .AvTxsChipSelect_i              ( TxsChipSelect_i       ),
    .AvCraChipSelect_i              ( CraChipSelect_i       ),
    .AvCraRead_i                    ( CraRead_i             ),
    .AvCraWrite_i                   ( CraWrite_i            ),
    .AvCraWriteData_i               ( CraWriteData_i        ),
    .AvCraAddress_i                 ( CraAddress_i          ),
    .AvCraByteEnable_i              ( CraByteEnable_i       ),
    .AvCraReadData_o                ( CraReadData_o         ),
    .AvCraWaitRequest_o             ( CraWaitRequest_o      ),
    .AvRdDmaRxReady_o               ( RdDmaRxReady_o       ),
    .AvRdDmaRxData_i                ( RdDmaRxData_i        ),
    .AvRdDmaRxValid_i               ( RdDmaRxValid_i       ),
    .AvRdDmaTxData_o                ( RdDmaTxData_o        ),
    .AvRdDmaTxValid_o               ( RdDmaTxValid_o       ),
    .AvWrDmaRxReady_o               ( WrDmaRxReady_o       ),
    .AvWrDmaRxData_i                ( WrDmaRxData_i        ),
    .AvWrDmaRxValid_i               ( WrDmaRxValid_i       ),
    .AvWrDmaTxData_o                ( WrDmaTxData_o       ),
    .AvWrDmaTxValid_o               ( WrDmaTxValid_o       ),
    .AvMsiIntfc_o                   ( MsiIntfc_o           ),
    .AvMsixIntfc_o                  ( MsixIntfc_o          ),
    .HipCfgAddr_i                   ( tl_cfg_add           ),
    .HipCfgCtl_i                    ( tl_cfg_ctl           ),
    .TLCfgSts_i                     ( tl_cfg_sts[46:31]    )
  );




// Intx export

assign avalon_rstn = (pin_perst==1'b0)?1'b0:(npor==1'b0)?1'b0:1'b1;
assign avalon_clk = coreclkout;



  //////////////// SIMULATION-ONLY CONTENTS
   //synthesis translate_off
   initial begin
      reset_status_sync_pldclk_r = 3'b111;
   end
  //synthesis translate_on

   always @(posedge coreclkout or posedge reset_status_int) begin
      if (reset_status_int == 1'b1) begin
         reset_status_sync_pldclk_r <= 3'b111;
      end
      else begin
         reset_status_sync_pldclk_r[0] <= 1'b0;
         reset_status_sync_pldclk_r[1] <= reset_status_sync_pldclk_r[0];
         reset_status_sync_pldclk_r[2] <= reset_status_sync_pldclk_r[1];
      end
   end
   assign reset_status_sync_pldclk = reset_status_sync_pldclk_r[2];
   assign npor_int         = ~reset_status_sync_pldclk;

assign reset_status = app_rstn;

   altpcierd_hip_rs rs_hip (
      .app_rstn (app_rstn),
      .dlup_exit (dlup_exit),
      .hotrst_exit (npor_int),
      .l2_exit (l2_exit),
      .ltssm (ltssmstate),
      .npor (npor_int & pld_clk_inuse),
      .pld_clk (coreclkout),
      .test_sim (1'b1)
   );



   assign pld_core_ready =  serdes_pll_locked;

/// SIMULATION CONTENTS
            //synthesis translate_off
      assign coreclkout = coreclkout_hip;
generate if(port_type_hwtcl == "Root port")
   begin
      wire       bfm_log_common_dummy_out;
      wire       driver_rp_dummy_out;
      wire       bfm_req_intf_common_dummy_out;
      wire       bfm_shmem_common_dummy_out;
      wire       ltssm_dummy_out;
      altpcietb_bfm_log_common bfm_log_common ( .dummy_out (bfm_log_common_dummy_out));
      altpcietb_bfm_req_intf_common bfm_req_intf_common ( .dummy_out (bfm_req_intf_common_dummy_out));
      altpcietb_bfm_shmem_common bfm_shmem_common ( .dummy_out (bfm_shmem_common_dummy_out));
      altpcietb_ltssm_mon ltssm_mon ( .dummy_out (ltssm_dummy_out), .ep_ltssm (5'h0), .rp_clk (sim_pipe_pclk_out), .rp_ltssm (ltssmstate), .rstn (npor));
   end
endgenerate
// END SIMULATION CONTENTS

         //synthesis translate_on

          //synthesis read_comments_as_HDL on
         //global u_global_buffer_coreclkout (.in(coreclkout_hip), .out(coreclkout));
         //synthesis read_comments_as_HDL off

       assign pld_clk_hip   = coreclkout_hip;


assign reservedin[31:0] = {22'h0,tx_cons_cred_sel ,9'h0};

endmodule
