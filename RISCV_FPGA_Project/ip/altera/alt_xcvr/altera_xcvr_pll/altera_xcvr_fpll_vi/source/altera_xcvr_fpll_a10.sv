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


 
//------------------------------------------------------------------
// filename: altera_xcvr_fpll_a10.sv
//
// Description : instantiates avmm and cmu_fpll
//
// Limitation  : Intended for NightFury
//
// Copyright (c) Altera Corporation 1997-2012
// All rights reserved
//-------------------------------------------------------------------

module altera_xcvr_fpll_a10
#( 
	// Virtual parameters
	parameter enable_debug_info = "true",
	parameter bw_sel = "auto",
	parameter cgb_div = 1,
	parameter compensation_mode = "direct",
	parameter datarate = "0 ps",
	parameter duty_cycle_0 = 50,
	parameter duty_cycle_1 = 50,
	parameter duty_cycle_2 = 50,
	parameter duty_cycle_3 = 50,
	parameter hssi_output_clock_frequency = "0 ps",
	parameter is_cascaded_pll = "false",
	parameter output_clock_frequency_0 = "100.0 MHz",
	parameter output_clock_frequency_1 = "0 ps",
	parameter output_clock_frequency_2 = "0 ps",
	parameter output_clock_frequency_3 = "0 ps",
	parameter phase_shift_0 = "0 ps",
	parameter phase_shift_1 = "0 ps",
	parameter phase_shift_2 = "0 ps",
	parameter phase_shift_3 = "0 ps",
	parameter pma_width = 8,
	parameter prot_mode = "basic",
	parameter reference_clock_frequency = "100.0 MHz",
	parameter vco_frequency = "100.0 MHz",

	// twentynm_cmu_fpll_refclk_select parameters
	parameter cmu_fpll_refclk_select_pll_clkin_0_src = "pll_clkin_0_src_vss",
	parameter cmu_fpll_refclk_select_pll_clkin_1_src = "pll_clkin_1_src_vss",
	parameter cmu_fpll_refclk_select_pll_auto_clk_sw_en = "false",
	parameter cmu_fpll_refclk_select_pll_clk_loss_edge = "pll_clk_loss_both_edges",
	parameter cmu_fpll_refclk_select_pll_clk_loss_sw_en = "false",
	parameter cmu_fpll_refclk_select_pll_clk_sw_dly = 0,
	parameter cmu_fpll_refclk_select_pll_manu_clk_sw_en = "false",
	parameter cmu_fpll_refclk_select_pll_sw_refclk_src = "pll_sw_refclk_src_clk_0",
	parameter mux0_inclk0_logical_to_physical_mapping = "power_down",
	parameter mux0_inclk1_logical_to_physical_mapping = "power_down",
	parameter mux0_inclk2_logical_to_physical_mapping = "power_down",
	parameter mux0_inclk3_logical_to_physical_mapping = "power_down",
	parameter mux0_inclk4_logical_to_physical_mapping = "power_down",
	parameter mux1_inclk0_logical_to_physical_mapping = "power_down",
	parameter mux1_inclk1_logical_to_physical_mapping = "power_down",
	parameter mux1_inclk2_logical_to_physical_mapping = "power_down",
	parameter mux1_inclk3_logical_to_physical_mapping = "power_down",
	parameter mux1_inclk4_logical_to_physical_mapping = "power_down",
	parameter cmu_fpll_refclk_select_refclk_select0 = "power_down",
	parameter cmu_fpll_refclk_select_refclk_select1 = "power_down",
	
	// twentynm_cmu_fpll parameters
	parameter cmu_fpll_pll_a_csr_bufin_posedge = "zero", 
	parameter cmu_fpll_pll_atb = "atb_selectdisable",
	parameter cmu_fpll_pll_bw_mode = "low_bw",
	parameter cmu_fpll_pll_c_counter_0 = 1,	
	parameter cmu_fpll_pll_c_counter_0_coarse_dly = "0 ps",
	parameter cmu_fpll_pll_c_counter_0_fine_dly = "0 ps",
	parameter cmu_fpll_pll_c_counter_0_in_src = "c_cnt_in_src_test_clk",
	parameter cmu_fpll_pll_c_counter_0_min_tco_enable = "true",
	parameter cmu_fpll_pll_c_counter_0_ph_mux_prst = 0,
	parameter cmu_fpll_pll_c_counter_0_prst = 1,
	parameter cmu_fpll_pll_c_counter_1 = 1,
	parameter cmu_fpll_pll_c_counter_1_coarse_dly = "0 ps",
	parameter cmu_fpll_pll_c_counter_1_fine_dly = "0 ps",
	parameter cmu_fpll_pll_c_counter_1_in_src = "c_cnt_in_src_test_clk",
	parameter cmu_fpll_pll_c_counter_1_min_tco_enable = "true",
	parameter cmu_fpll_pll_c_counter_1_ph_mux_prst = 0,
	parameter cmu_fpll_pll_c_counter_1_prst = 1,
	parameter cmu_fpll_pll_c_counter_2 = 1,
	parameter cmu_fpll_pll_c_counter_2_coarse_dly = "0 ps",
	parameter cmu_fpll_pll_c_counter_2_fine_dly = "0 ps",
	parameter cmu_fpll_pll_c_counter_2_in_src = "c_cnt_in_src_test_clk",
	parameter cmu_fpll_pll_c_counter_2_min_tco_enable = "true",
	parameter cmu_fpll_pll_c_counter_2_ph_mux_prst = 0,
	parameter cmu_fpll_pll_c_counter_2_prst = 1,
	parameter cmu_fpll_pll_c_counter_3 = 1,
	parameter cmu_fpll_pll_c_counter_3_coarse_dly = "0 ps",
	parameter cmu_fpll_pll_c_counter_3_fine_dly = "0 ps",
	parameter cmu_fpll_pll_c_counter_3_in_src = "c_cnt_in_src_test_clk",
	parameter cmu_fpll_pll_c_counter_3_min_tco_enable = "true",
	parameter cmu_fpll_pll_c_counter_3_ph_mux_prst = 0,
	parameter cmu_fpll_pll_c_counter_3_prst = 1,
	parameter cmu_fpll_pll_cal_status = "true", 	
	parameter cmu_fpll_pll_calibration = "false",
	parameter cmu_fpll_pll_cmp_buf_dly = "0 ps",
	parameter cmu_fpll_pll_cp_compensation = "true",
	parameter cmu_fpll_pll_cp_current_setting = "cp_current_setting0",
	parameter cmu_fpll_pll_cp_testmode = "cp_normal",
	parameter cmu_fpll_pll_cp_lf_3rd_pole_freq = "lf_3rd_pole_setting0",
	parameter cmu_fpll_pll_cp_lf_4th_pole_freq = "lf_4th_pole_setting0",
	parameter cmu_fpll_pll_cp_lf_order = "lf_2nd_order",
	parameter cmu_fpll_pll_ctrl_override_setting = "true",
	parameter cmu_fpll_pll_ctrl_plniotri_override = "false",   
	parameter cmu_fpll_pll_device_variant = "device1",
	parameter cmu_fpll_pll_dprio_base_addr = 256,
	parameter cmu_fpll_pll_dprio_broadcast_en = "true",
	parameter cmu_fpll_pll_dprio_clk_vreg_boost = "clk_fpll_vreg_no_voltage_boost",
	parameter cmu_fpll_pll_dprio_cvp_inter_sel = "true",
	parameter cmu_fpll_pll_dprio_force_inter_sel = "true",
	parameter cmu_fpll_pll_dprio_fpll_vreg_boost = "fpll_vreg_no_voltage_boost",
	parameter cmu_fpll_pll_dprio_fpll_vreg1_boost = "fpll_vreg1_no_voltage_boost",
	parameter cmu_fpll_pll_dprio_power_iso_en = "true",
	parameter cmu_fpll_pll_dprio_status_select = "dprio_normal_status",
	parameter cmu_fpll_pll_dsm_ecn_bypass = "false",
	parameter cmu_fpll_pll_dsm_ecn_test_en = "false",
	parameter cmu_fpll_pll_dsm_fractional_division = 1,
	parameter cmu_fpll_pll_dsm_fractional_value_ready = "pll_k_ready",
	parameter cmu_fpll_pll_dsm_mode = "dsm_mode_integer",
	parameter cmu_fpll_pll_dsm_out_sel = "pll_dsm_disable",
	parameter cmu_fpll_pll_enable = "true",
	parameter cmu_fpll_pll_extra_csr = 0,
	parameter cmu_fpll_pll_fbclk_mux_1 = "pll_fbclk_mux_1_glb",
	parameter cmu_fpll_pll_fbclk_mux_2 = "pll_fbclk_mux_2_m_cnt",
	parameter cmu_fpll_pll_iqclk_mux_sel	= "power_down", 
	parameter cmu_fpll_pll_l_counter	= 1,
	parameter cmu_fpll_pll_l_counter_bypass = "false",
	parameter cmu_fpll_pll_l_counter_enable = "true",
	parameter cmu_fpll_pll_lf_resistance = "lf_res_setting0",
	parameter cmu_fpll_pll_lf_ripplecap = "lf_ripple_enabled",
	parameter cmu_fpll_pll_lock_fltr_cfg = 1,
	parameter cmu_fpll_pll_lock_fltr_test = "pll_lock_fltr_nrm",
	parameter cmu_fpll_pll_lpf_rstn_value = "true",
	parameter cmu_fpll_pll_m_counter	= 1, 
	parameter cmu_fpll_pll_m_counter_coarse_dly = "0 ps",
	parameter cmu_fpll_pll_m_counter_fine_dly = "0 ps",
	parameter cmu_fpll_pll_m_counter_in_src = "m_cnt_in_src_test_clk",
	parameter cmu_fpll_pll_m_counter_min_tco_enable = "true",
	parameter cmu_fpll_pll_m_counter_ph_mux_prst	= 0,
	parameter cmu_fpll_pll_m_counter_prst = 1,
	parameter cmu_fpll_pll_n_counter	= 1,
	parameter cmu_fpll_pll_n_counter_coarse_dly = "0 ps",
	parameter cmu_fpll_pll_n_counter_fine_dly = "0 ps",
	parameter cmu_fpll_pll_nreset_invert = "false", 
	parameter cmu_fpll_pll_op_mode = "false",
	parameter cmu_fpll_pll_optimal = "true",
	parameter cmu_fpll_pll_overrange_underrange_voltage_coarse_sel = "vreg_setting_coarse1",
	parameter cmu_fpll_pll_overrange_voltage = "over_setting3",
	parameter cmu_fpll_pll_power_mode = "low_power",
	parameter cmu_fpll_pll_powerdown_mode = "false",
	parameter cmu_fpll_pll_ppm_clk0_src = "ppm_clk0_vss",
	parameter cmu_fpll_pll_ppm_clk1_src = "ppm_clk1_vss",
	parameter cmu_fpll_pll_ref_buf_dly = "0 ps",
	parameter cmu_fpll_pll_rstn_override = "false",
	parameter cmu_fpll_pll_self_reset = "false",
	parameter cmu_fpll_pll_silicon_rev = "reva",
	parameter cmu_fpll_pll_speed_grade = "dash2",
	parameter cmu_fpll_pll_sup_mode = "user_mode",
	parameter cmu_fpll_pll_tclk_mux_en = "false",
	parameter cmu_fpll_pll_tclk_sel = "pll_tclk_m_src",
	parameter cmu_fpll_pll_test_enable = "false",
	parameter cmu_fpll_pll_underrange_voltage = "under_setting3",
	parameter cmu_fpll_pll_unlock_fltr_cfg = 0,
	parameter cmu_fpll_pll_vccr_pd_en = "true",
	parameter cmu_fpll_pll_vco_freq_band = "pll_freq_band0",
	parameter cmu_fpll_pll_vco_ph0_en = "false",
	parameter cmu_fpll_pll_vco_ph0_value = "pll_vco_ph0_vss",
	parameter cmu_fpll_pll_vco_ph1_en = "false",
	parameter cmu_fpll_pll_vco_ph1_value = "pll_vco_ph1_vss",
	parameter cmu_fpll_pll_vco_ph2_en = "false",
	parameter cmu_fpll_pll_vco_ph2_value = "pll_vco_ph2_vss",
	parameter cmu_fpll_pll_vco_ph3_en = "false",
	parameter cmu_fpll_pll_vco_ph3_value = "pll_vco_ph3_vss",
	parameter cmu_fpll_pll_vreg0_output = "vccdreg_nominal",
	parameter cmu_fpll_pll_vreg1_output = "vccdreg_nominal",
	
	parameter enable_mcgb = 0,                                                   // \RANGE (0) 1
        parameter enable_mcgb_debug_ports_parameters = 0,                      // \RANGE (0) 1
    parameter pma_cgb_master_silicon_rev = "reva",                         		// \RANGE (reva) "revb" "revc"
    parameter pma_cgb_master_prot_mode  = "basic_tx",                      		// \RANGE "unused" (basic_tx) "basic_kr_tx" "pcie_gen1_tx" "pcie_gen2_tx" "pcie_gen3_tx" "pcie_gen4_tx" "cei_tx" "qpi_tx" "cpri_tx" "fc_tx" "srio_tx" "gpon_tx" "sdi_tx" "sata_tx" "xaui_tx" "obsai_tx" "gige_tx" "higig_tx" "sonet_tx" "sfp_tx" "xfp_tx" "sfi_tx"
    parameter pma_cgb_master_cgb_enable_iqtxrxclk = "disable_iqtxrxclk",   		// \OPEN in atom default is enable in _hw.tcl default is disable // \RANGE disable_iqtxrxclk (enable_iqtxrxclk) 
    parameter pma_cgb_master_x1_div_m_sel = "divbypass",                   		// \RANGE (divbypass) divby2 divby4 divby8
    parameter pma_cgb_master_ser_mode = "eight_bit",                       		// \RANGE (eight_bit) ten_bit sixteen_bit twenty_bit thirty_two_bit forty_bit sixty_four_bit
    parameter pma_cgb_master_data_rate = "0 Mbps",
    parameter pma_cgb_master_cgb_power_down                     = "normal_cgb",                  // \RANGE normal_cgb (power_down_cgb)                           
    parameter pma_cgb_master_master_cgb_clock_control           = "master_cgb_no_dft_control",   // \RANGE (master_cgb_no_dft_control) master_cgb_dft_control_high master_cgb_dft_control_low  
    parameter pma_cgb_master_observe_cgb_clocks                 = "observe_nothing",             // \RANGE (observe_nothing) observe_x1mux_out   
    parameter pma_cgb_master_op_mode                            = "enabled",                     // \RANGE (enabled) pwr_down             
    parameter pma_cgb_master_tx_ucontrol_reset_pcie             = "pcscorehip_controls_mcgb",    // \RANGE (pcscorehip_controls_mcgb) cgb_reset tx_pcie_gen1 tx_pcie_gen2 tx_pcie_gen3 tx_pcie_gen4  
    parameter pma_cgb_master_vccdreg_output                     = "vccdreg_nominal",             // \RANGE (vccdreg_nominal) vccdreg_pos_setting0 vccdreg_pos_setting1 vccdreg_pos_setting2 vccdreg_pos_setting3 vccdreg_pos_setting4 vccdreg_pos_setting5 vccdreg_pos_setting6 vccdreg_pos_setting7 vccdreg_pos_setting8 vccdreg_pos_setting9 vccdreg_pos_setting10 vccdreg_pos_setting11 vccdreg_pos_setting12 vccdreg_pos_setting13 vccdreg_pos_setting14 vccdreg_pos_setting15 reserved1 reserved2 vccdreg_neg_setting0 vccdreg_neg_setting1 vccdreg_neg_setting2 vccdreg_neg_setting3 reserved3 reserved4 reserved5 reserved6 reserved7 reserved8 reserved9 reserved10 reserved11   
    parameter pma_cgb_master_input_select                       = "lcpll_top",                   // \RANGE lcpll_bot lcpll_top fpll_bot fpll_top (unused)      
    parameter pma_cgb_master_input_select_gen3                  = "unused",                      // \RANGE lcpll_bot lcpll_top fpll_bot fpll_top (unused) 
    parameter pma_cgb_master_inclk0_logical_to_physical_mapping = "unused",                      // \RANGE lcpll_bot lcpll_top fpll_bot fpll_top (unused) 
    parameter pma_cgb_master_inclk1_logical_to_physical_mapping = "unused",                      // \RANGE lcpll_bot lcpll_top fpll_bot fpll_top (unused) 
    parameter pma_cgb_master_inclk2_logical_to_physical_mapping = "unused",                      // \RANGE lcpll_bot lcpll_top fpll_bot fpll_top (unused) 
    parameter pma_cgb_master_inclk3_logical_to_physical_mapping = "unused",                      // \RANGE lcpll_bot lcpll_top fpll_bot fpll_top (unused) 

	parameter SIZE_AVMM_RDDATA_BUS = 32,
	parameter SIZE_AVMM_WRDATA_BUS = 32
)
(
	// general usage for core and HSSI
	input pll_refclk0,
    input pll_refclk1,          
    input pll_refclk2,          
    input pll_refclk3,          
    input pll_refclk4,          
	input pll_powerdown,
	output tx_serial_clk,
	output tx_serial_clk_n,
	output outclk0,
	output outclk1,
	output outclk2,
	output outclk3,
	output pll_pcie_clk,
	output pll_locked,

	// dynamic phase shift
	input phase_reset,
	input phase_en,
	input updn,
	input [3:0] cntsel,
	input [2:0] num_phase_shifts,
	output phase_done,

	// clock switchover
	input extswitch,
	output [1:0] clkbad,
	output activeclk,

	// reconfig for PLL
    input reconfig_clk0,
    input reconfig_write0,
    input reconfig_read0,
	input reconfig_reset0,
    input [9:0] reconfig_address0,                     
    input [SIZE_AVMM_WRDATA_BUS-1:0] reconfig_writedata0,
    output [SIZE_AVMM_RDDATA_BUS-1:0] reconfig_readdata0,
    output reconfig_waitrequest0,
    output pll_cal_busy,
    output hip_cal_done,

    // reconfig for Master CGB
    input reconfig_clk1,
    input reconfig_write1,
    input reconfig_read1,
	input reconfig_reset1,
    input [9:0] reconfig_address1,              
    input  [SIZE_AVMM_WRDATA_BUS-1:0] reconfig_writedata1,
    output [SIZE_AVMM_RDDATA_BUS-1:0] reconfig_readdata1,
    output reconfig_waitrequest1,    
    output mcgb_cal_busy,   
    output mcgb_hip_cal_done,  

	// Central Clock Divider
    input mcgb_aux_clk0,                      
    input mcgb_aux_clk1,
    input mcgb_aux_clk2,
    input mcgb_rst,
	input [1:0] pcie_sw,
    output [5:0] tx_bonding_clocks,               
    output mcgb_serial_clk,                      
    output [1:0] pcie_sw_done, 	
	
	// cascading
	output pll_cascade_clk,
	output atx_pll_cascade_clk,

	// debug ports
	output clk_src,
	output clklow,
	output fref,
	output overrange,
	output underrange
);

    localparam SIZE_CGB_BONDING_CLK = 6;
    localparam avmm_interfaces = ((enable_mcgb==1) && (enable_mcgb_debug_ports_parameters==1)) ? 2 : 1;
    localparam refiqclk_size = 12;
    localparam refclk_cnt = 3;

    // upper 24 bits are not used, but should not be left at X
    assign reconfig_readdata0[SIZE_AVMM_RDDATA_BUS-1:8] =  0;
    assign reconfig_readdata1[SIZE_AVMM_RDDATA_BUS-1:8] =  0;

    //-----------------------------------
    // reconfig AVMM to pll internal wires  
    // interface #0 to PLL, interface #1 to CGB 
    wire  [avmm_interfaces-1    :0] pll_avmm_clk;
    wire  [avmm_interfaces-1    :0] pll_avmm_rstn;
    wire  [avmm_interfaces*8-1  :0] pll_avmm_writedata;
    wire  [avmm_interfaces*9-1  :0] pll_avmm_address;
    wire  [avmm_interfaces-1    :0] pll_avmm_write;
    wire  [avmm_interfaces-1    :0] pll_avmm_read;
    wire  [avmm_interfaces*8-1  :0] pll_avmmreaddata_cmu_fpll;                 
    wire  [avmm_interfaces*8-1  :0] pll_avmmreaddata_cmu_fpll_refclk_select;       
    wire  [avmm_interfaces*8-1  :0] pll_avmmreaddata_cgb_master;          
    wire  [avmm_interfaces-1    :0] pll_blockselect_cmu_fpll;               
    wire  [avmm_interfaces-1    :0] pll_blockselect_cmu_fpll_refclk_select;  
    wire  [avmm_interfaces-1    :0] pll_blockselect_cgb_master; 

    //-----------------------------------
    // reconfigAVMM to top wrapper wires  
    // interface #0 to PLL, interface #1 to CGB 
    wire  [avmm_interfaces-1    :0] reconfig_clk;
    wire  [avmm_interfaces-1    :0] reconfig_reset;
    wire  [avmm_interfaces*8-1  :0] reconfig_writedata;
    wire  [avmm_interfaces*10-1 :0] reconfig_address;
    wire  [avmm_interfaces-1    :0] reconfig_write;
    wire  [avmm_interfaces-1    :0] reconfig_read;
    wire  [avmm_interfaces*8-1  :0] reconfig_readdata;
    wire  [avmm_interfaces-1    :0] reconfig_waitrequest;
    wire  [avmm_interfaces-1    :0] avmm_busy;
    wire  [avmm_interfaces-1    :0] pld_cal_done;
    wire  [avmm_interfaces-1    :0] hip_cal_done_w;

    //-----------------------------------
    // reconfigAVMM to cgb atom 
    wire         avmm_clk_mcgb;
    wire         avmm_rstn_mcgb;
    wire   [7:0] avmm_writedata_mcgb;
    wire   [8:0] avmm_address_mcgb;
    wire         avmm_write_mcgb;
    wire         avmm_read_mcgb;
    wire   [7:0] avmmreaddata_mcgb;
    wire         blockselect_mcgb;

    assign pll_avmmreaddata_cgb_master[7:0] = { 8 {1'b0} };                           // \NOTE only [15:8] is used, hence [7:0] is tied-off to '0'
    assign pll_blockselect_cgb_master[0:0] = {1'b0};  

    assign reconfig_clk[0] = reconfig_clk0;
    assign reconfig_reset[0] = reconfig_reset0;
    assign reconfig_writedata[7:0] = reconfig_writedata0[7:0];
    assign reconfig_address[9:0] = reconfig_address0;
    assign reconfig_write[0] = reconfig_write0;
    assign reconfig_read[0] = reconfig_read0;
    assign reconfig_readdata0[7:0]=reconfig_readdata[7:0];
    assign reconfig_waitrequest0 = reconfig_waitrequest[0];
    assign hip_cal_done = hip_cal_done_w[0];
	assign mcgb_serial_clk = tx_bonding_clocks[SIZE_CGB_BONDING_CLK-1];

    generate
       if (avmm_interfaces==2) begin
          assign pll_avmmreaddata_cmu_fpll[avmm_interfaces*8-1:8] = { 8 {1'b0} };             // \NOTE only [7:0] is used, hence [15:8] is tied-off to '0'
          assign pll_avmmreaddata_cmu_fpll_refclk_select[avmm_interfaces*8-1:8] = { 8 {1'b0} };   // \NOTE only [7:0] is used, hence [15:8] is tied-off to '0'

          assign pll_blockselect_cmu_fpll[avmm_interfaces-1:1] = {1'b0};                      // \NOTE only [0:0] is used, hence [1:1] is tied-off to '0'
          assign pll_blockselect_cmu_fpll_refclk_select[avmm_interfaces-1:1] = {1'b0};            // \NOTE only [0:0] is used, hence [1:1] is tied-off to '0'

          assign avmm_clk_mcgb                     = pll_avmm_clk[1];
          assign avmm_rstn_mcgb                    = pll_avmm_rstn[1];
          assign avmm_writedata_mcgb               = pll_avmm_writedata[15:8];
          assign avmm_address_mcgb                 = pll_avmm_address[17:9];
          assign avmm_write_mcgb                   = pll_avmm_write[1];
          assign avmm_read_mcgb                    = pll_avmm_read[1];
          assign pll_avmmreaddata_cgb_master[15:8] = avmmreaddata_mcgb;
          assign pll_blockselect_cgb_master[1]     = blockselect_mcgb;
       end
    endgenerate

   //---
   // temporary:
   // Case:132273 -- tie off cal_busy ports
   assign pll_cal_busy = 1'b0; 
   assign mcgb_cal_busy = 1'b0;
   //assign pll_cal_busy = ~pld_cal_done[0];

   generate
      if (avmm_interfaces==2) begin
         assign reconfig_clk[1] = reconfig_clk1;
         assign reconfig_reset[1] = reconfig_reset1;
         assign reconfig_writedata[15:8] = reconfig_writedata1[7:0];
         assign reconfig_address[19:10] = reconfig_address1;
         assign reconfig_write[1] = reconfig_write1;
         assign reconfig_read[1] = reconfig_read1;
         assign reconfig_readdata1[7:0]=reconfig_readdata[15:8];
         assign reconfig_waitrequest1 = reconfig_waitrequest[1];
         //assign mcgb_cal_busy = ~pld_cal_done[1];
         assign mcgb_hip_cal_done = hip_cal_done_w[1];
      end
   endgenerate

	// feedback wire
	wire refclk_sel_outclk_wire;
	wire fbclk_wire;
	wire iqtxrxclk_wire;
	wire pll_extfb_wire;
	
	// cascade out on IQTXRXCLK
	assign atx_pll_cascade_clk = iqtxrxclk_wire;
	
	//-----------------------------------
    // instantiation of twentynm_xcvr_avmm 
    twentynm_xcvr_avmm
    #(
       .avmm_interfaces(avmm_interfaces),
	   .arbiter_ctrl("pld"),
	   .calibration_en("disable")
    ) xcvr_avmm_inst (
        .avmm_clk(       {reconfig_clk           } ),
       .avmm_reset(      {reconfig_reset         } ),
       .avmm_writedata(  {reconfig_writedata     } ),
       .avmm_address(    {reconfig_address       } ),
       .avmm_write(      {reconfig_write         } ),
       .avmm_read(       {reconfig_read          } ),
       .avmm_readdata(   {reconfig_readdata      } ),
       .avmm_waitrequest({reconfig_waitrequest   } ),
       .avmm_busy(       {avmm_busy              } ),
       .pld_cal_done(    {pld_cal_done           } ),
       .hip_cal_done(    {hip_cal_done_w         } ),

       .chnl_pll_avmm_clk(pll_avmm_clk),
       .chnl_pll_avmm_rstn(pll_avmm_rstn),
       .chnl_pll_avmm_writedata(pll_avmm_writedata),
       .chnl_pll_avmm_address(pll_avmm_address),
       .chnl_pll_avmm_write(pll_avmm_write),
       .chnl_pll_avmm_read(pll_avmm_read),

       .pll_avmmreaddata_cmu_fpll(pll_avmmreaddata_cmu_fpll),                          
       .pll_avmmreaddata_cmu_fpll_refclk_select(pll_avmmreaddata_cmu_fpll_refclk_select), 
       .pll_avmmreaddata_cgb_master(pll_avmmreaddata_cgb_master),                                        
       .pll_blockselect_cmu_fpll(pll_blockselect_cmu_fpll),            
       .pll_blockselect_cmu_fpll_refclk_select(pll_blockselect_cmu_fpll_refclk_select),  
       .pll_blockselect_cgb_master(pll_blockselect_cgb_master),  

       //-----------------------------------
       // IRRELEVANT PORTS
       .pma_avmmreaddata_tx_ser                   ( /*unused*/ ),
       .pma_avmmreaddata_tx_cgb                   ( /*unused*/ ),
       .pma_avmmreaddata_tx_buf                   ( /*unused*/ ),
       .pma_avmmreaddata_rx_deser                 ( /*unused*/ ),
       .pma_avmmreaddata_rx_buf                   ( /*unused*/ ),
       .pma_avmmreaddata_rx_sd                    ( /*unused*/ ),
       .pma_avmmreaddata_rx_odi                   ( /*unused*/ ),
       .pma_avmmreaddata_rx_dfe                   ( /*unused*/ ),
       .pma_avmmreaddata_cdr_pll                  ( /*unused*/ ),
       .pma_avmmreaddata_cdr_refclk_select        ( /*unused*/ ),
       .pma_avmmreaddata_pma_adapt                ( /*unused*/ ),
       .pma_blockselect_tx_ser                    ( 2'b0 ),
       .pma_blockselect_tx_cgb                    ( 2'b0 ),
       .pma_blockselect_tx_buf                    ( 2'b0 ),
       .pma_blockselect_rx_deser                  ( 2'b0 ),
       .pma_blockselect_rx_buf                    ( 2'b0 ),
       .pma_blockselect_rx_sd                     ( 2'b0 ),
       .pma_blockselect_rx_odi                    ( 2'b0 ),
       .pma_blockselect_rx_dfe                    ( 2'b0 ),
       .pma_blockselect_cdr_pll                   ( 2'b0 ),
       .pma_blockselect_cdr_refclk_select         ( 2'b0 ),
       .pma_blockselect_pma_adapt                 ( 2'b0 ),
       .pcs_avmmreaddata_8g_rx_pcs                ( /*unused*/ ),
       .pcs_avmmreaddata_pipe_gen1_2              ( /*unused*/ ),
       .pcs_avmmreaddata_8g_tx_pcs                ( /*unused*/ ),
       .pcs_avmmreaddata_10g_rx_pcs               ( /*unused*/ ),
       .pcs_avmmreaddata_10g_tx_pcs               ( /*unused*/ ),
       .pcs_avmmreaddata_gen3_rx_pcs              ( /*unused*/ ),
       .pcs_avmmreaddata_pipe_gen3                ( /*unused*/ ),
       .pcs_avmmreaddata_gen3_tx_pcs              ( /*unused*/ ),
       .pcs_avmmreaddata_krfec_rx_pcs             ( /*unused*/ ),
       .pcs_avmmreaddata_krfec_tx_pcs             ( /*unused*/ ),
       .pcs_avmmreaddata_fifo_rx_pcs              ( /*unused*/ ),
       .pcs_avmmreaddata_fifo_tx_pcs              ( /*unused*/ ),
       .pcs_avmmreaddata_rx_pcs_pld_if            ( /*unused*/ ),
       .pcs_avmmreaddata_com_pcs_pld_if           ( /*unused*/ ),
       .pcs_avmmreaddata_tx_pcs_pld_if            ( /*unused*/ ),
       .pcs_avmmreaddata_rx_pcs_pma_if            ( /*unused*/ ),
       .pcs_avmmreaddata_com_pcs_pma_if           ( /*unused*/ ),
       .pcs_avmmreaddata_tx_pcs_pma_if            ( /*unused*/ ),
       .pcs_blockselect_8g_rx_pcs                 ( 2'b0 ),
       .pcs_blockselect_pipe_gen1_2               ( 2'b0 ),
       .pcs_blockselect_8g_tx_pcs                 ( 2'b0 ),
       .pcs_blockselect_10g_rx_pcs                ( 2'b0 ),
       .pcs_blockselect_10g_tx_pcs                ( 2'b0 ),
       .pcs_blockselect_gen3_rx_pcs               ( 2'b0 ),
       .pcs_blockselect_pipe_gen3                 ( 2'b0 ),
       .pcs_blockselect_gen3_tx_pcs               ( 2'b0 ),
       .pcs_blockselect_krfec_rx_pcs              ( 2'b0 ),
       .pcs_blockselect_krfec_tx_pcs              ( 2'b0 ),
       .pcs_blockselect_fifo_rx_pcs               ( 2'b0 ),
       .pcs_blockselect_fifo_tx_pcs               ( 2'b0 ),
       .pcs_blockselect_rx_pcs_pld_if             ( 2'b0 ),
       .pcs_blockselect_com_pcs_pld_if            ( 2'b0 ),
       .pcs_blockselect_tx_pcs_pld_if             ( 2'b0 ),
       .pcs_blockselect_rx_pcs_pma_if             ( 2'b0 ),
       .pcs_blockselect_com_pcs_pma_if            ( 2'b0 ),
       .pcs_blockselect_tx_pcs_pma_if             ( 2'b0 ),
       .pll_avmmreaddata_lc_pll                   ( /*unused*/ ),
       .pll_avmmreaddata_lc_refclk_select         ( /*unused*/ ),
       .pll_blockselect_lc_pll                    ( 2'b0 ),
       .pll_blockselect_lc_refclk_select          ( 2'b0 )
    );   
	
	//-----------------------------------
    // instantiation of twentynm_cmu_fpll_refclk_select 
	twentynm_cmu_fpll_refclk_select
	#(
		.pll_clkin_0_src(cmu_fpll_refclk_select_pll_clkin_0_src),
		.pll_clkin_1_src(cmu_fpll_refclk_select_pll_clkin_1_src),
		.pll_auto_clk_sw_en(cmu_fpll_refclk_select_pll_auto_clk_sw_en),
		.pll_clk_loss_edge(cmu_fpll_refclk_select_pll_clk_loss_edge),
		.pll_clk_loss_sw_en(cmu_fpll_refclk_select_pll_clk_loss_sw_en),
		.pll_clk_sw_dly(cmu_fpll_refclk_select_pll_clk_sw_dly),
		.pll_manu_clk_sw_en(cmu_fpll_refclk_select_pll_manu_clk_sw_en),
		.pll_sw_refclk_src(cmu_fpll_refclk_select_pll_sw_refclk_src),
		.mux0_inclk0_logical_to_physical_mapping(mux0_inclk0_logical_to_physical_mapping),
		.mux0_inclk1_logical_to_physical_mapping(mux0_inclk1_logical_to_physical_mapping),
		.mux0_inclk2_logical_to_physical_mapping(mux0_inclk2_logical_to_physical_mapping),
		.mux0_inclk3_logical_to_physical_mapping(mux0_inclk3_logical_to_physical_mapping),
		.mux0_inclk4_logical_to_physical_mapping(mux0_inclk4_logical_to_physical_mapping),
		.mux1_inclk0_logical_to_physical_mapping(mux1_inclk0_logical_to_physical_mapping),
		.mux1_inclk1_logical_to_physical_mapping(mux1_inclk1_logical_to_physical_mapping),
		.mux1_inclk2_logical_to_physical_mapping(mux1_inclk2_logical_to_physical_mapping),
		.mux1_inclk3_logical_to_physical_mapping(mux1_inclk3_logical_to_physical_mapping),
		.mux1_inclk4_logical_to_physical_mapping(mux1_inclk4_logical_to_physical_mapping),
		.refclk_select0(cmu_fpll_refclk_select_refclk_select0),
		.refclk_select1(cmu_fpll_refclk_select_refclk_select1)
	) fpll_refclk_select_inst
	(
		// Input Ports
		.avmmaddress(pll_avmm_address[8:0]),
		.avmmclk(pll_avmm_clk[0]),
		.avmmread(pll_avmm_read[0]),
		.avmmrstn(pll_avmm_rstn[0]),
		.avmmwrite(pll_avmm_write[0]),
		.avmmwritedata(pll_avmm_writedata[7:0]),
		.core_refclk(pll_refclk1),
		.extswitch(extswitch),
		.iqtxrxclk(),
		.pll_cascade_in(),
		.ref_iqclk({{(refiqclk_size-refclk_cnt){1'b0}}, {pll_refclk4, pll_refclk3, pll_refclk2}}),
		.refclk(pll_refclk0),
		.tx_rx_core_refclk(),
		
		// Output Ports
		.avmmreaddata(pll_avmmreaddata_cmu_fpll_refclk_select[7:0]),
		.blockselect(pll_blockselect_cmu_fpll_refclk_select[0]),
		.clk_src(clk_src),
		.clk0bad(clkbad[0]),
		.clk1bad(clkbad[1]),
		.extswitch_buf(),
		.outclk(refclk_sel_outclk_wire),
		.pllclksel(activeclk)
	);

	//-----------------------------------
	// instantiate of twentynm_cmu_fpll 
	twentynm_cmu_fpll
	#(
		// virtual parameters
		.bw_sel(bw_sel),
		.cgb_div(cgb_div),
		.compensation_mode(compensation_mode),
		.datarate(datarate),
		.duty_cycle_0(duty_cycle_0),
		.duty_cycle_1(duty_cycle_1),
		.duty_cycle_2(duty_cycle_2),
		.duty_cycle_3(duty_cycle_3),
		.hssi_output_clock_frequency(hssi_output_clock_frequency),
		.is_cascaded_pll(is_cascaded_pll),
		.output_clock_frequency_0(output_clock_frequency_0),
		.output_clock_frequency_1(output_clock_frequency_1),
		.output_clock_frequency_2(output_clock_frequency_2),
		.output_clock_frequency_3(output_clock_frequency_3),
		.phase_shift_0(phase_shift_0),
		.phase_shift_1(phase_shift_1),
		.phase_shift_2(phase_shift_2),
		.phase_shift_3(phase_shift_3),
		.pma_width(pma_width),
		.prot_mode(),
		.reference_clock_frequency(reference_clock_frequency),
		.vco_frequency(vco_frequency),
	
		// twentynm_cmu_fpll parameters	
		.pll_atb(cmu_fpll_pll_atb),
		.pll_bw_mode(cmu_fpll_pll_bw_mode),
		.pll_c_counter_0(cmu_fpll_pll_c_counter_0),
		.pll_c_counter_0_coarse_dly(cmu_fpll_pll_c_counter_0_coarse_dly),
		.pll_c_counter_0_fine_dly(cmu_fpll_pll_c_counter_0_fine_dly),
		.pll_c_counter_0_in_src(cmu_fpll_pll_c_counter_0_in_src),
		.pll_c_counter_0_min_tco_enable(cmu_fpll_pll_c_counter_0_min_tco_enable),
		.pll_c_counter_0_ph_mux_prst(cmu_fpll_pll_c_counter_0_ph_mux_prst),
		.pll_c_counter_0_prst(cmu_fpll_pll_c_counter_0_prst),
		.pll_c_counter_1(cmu_fpll_pll_c_counter_1),
		.pll_c_counter_1_coarse_dly(cmu_fpll_pll_c_counter_1_coarse_dly),
		.pll_c_counter_1_fine_dly(cmu_fpll_pll_c_counter_1_fine_dly),
		.pll_c_counter_1_in_src(cmu_fpll_pll_c_counter_1_in_src),
		.pll_c_counter_1_min_tco_enable(cmu_fpll_pll_c_counter_1_min_tco_enable),
		.pll_c_counter_1_ph_mux_prst(cmu_fpll_pll_c_counter_1_ph_mux_prst),
		.pll_c_counter_1_prst(cmu_fpll_pll_c_counter_1_prst),
		.pll_c_counter_2(cmu_fpll_pll_c_counter_2),
		.pll_c_counter_2_coarse_dly(cmu_fpll_pll_c_counter_2_coarse_dly),
		.pll_c_counter_2_fine_dly(cmu_fpll_pll_c_counter_2_fine_dly),
		.pll_c_counter_2_in_src(cmu_fpll_pll_c_counter_2_in_src),
		.pll_c_counter_2_min_tco_enable(cmu_fpll_pll_c_counter_2_min_tco_enable),		
		.pll_c_counter_2_ph_mux_prst(cmu_fpll_pll_c_counter_2_ph_mux_prst),
		.pll_c_counter_2_prst(cmu_fpll_pll_c_counter_2_prst),
		.pll_c_counter_3(cmu_fpll_pll_c_counter_3),
		.pll_c_counter_3_coarse_dly(cmu_fpll_pll_c_counter_3_coarse_dly),
		.pll_c_counter_3_fine_dly(cmu_fpll_pll_c_counter_3_fine_dly),
		.pll_c_counter_3_in_src(cmu_fpll_pll_c_counter_3_in_src),
		.pll_c_counter_3_min_tco_enable(cmu_fpll_pll_c_counter_3_min_tco_enable),		
		.pll_c_counter_3_ph_mux_prst(cmu_fpll_pll_c_counter_3_ph_mux_prst),
		.pll_c_counter_3_prst(cmu_fpll_pll_c_counter_3_prst),
		.pll_cal_status(cmu_fpll_pll_cal_status),
		.pll_calibration(cmu_fpll_pll_calibration),
		.pll_cmp_buf_dly(cmu_fpll_pll_cmp_buf_dly),
		.pll_cp_compensation(cmu_fpll_pll_cp_compensation),
		.pll_cp_current_setting(cmu_fpll_pll_cp_current_setting),
		.pll_cp_testmode(cmu_fpll_pll_cp_testmode),
		.pll_cp_lf_3rd_pole_freq(cmu_fpll_pll_cp_lf_3rd_pole_freq),
		.pll_cp_lf_4th_pole_freq(cmu_fpll_pll_cp_lf_4th_pole_freq),
		.pll_cp_lf_order(cmu_fpll_pll_cp_lf_order),
		.pll_ctrl_override_setting(cmu_fpll_pll_ctrl_override_setting),
		.pll_ctrl_plniotri_override(cmu_fpll_pll_ctrl_plniotri_override),
		.pll_device_variant(cmu_fpll_pll_device_variant),
		.pll_dprio_base_addr(cmu_fpll_pll_dprio_base_addr),
		.pll_dprio_broadcast_en(cmu_fpll_pll_dprio_broadcast_en),
		.pll_dprio_clk_vreg_boost(cmu_fpll_pll_dprio_clk_vreg_boost),
		.pll_dprio_cvp_inter_sel(cmu_fpll_pll_dprio_cvp_inter_sel),
		.pll_dprio_force_inter_sel(cmu_fpll_pll_dprio_force_inter_sel),
		.pll_dprio_fpll_vreg_boost(cmu_fpll_pll_dprio_fpll_vreg_boost),
		.pll_dprio_fpll_vreg1_boost(cmu_fpll_pll_dprio_fpll_vreg1_boost),
		.pll_dprio_power_iso_en(cmu_fpll_pll_dprio_power_iso_en),
		.pll_dprio_status_select(cmu_fpll_pll_dprio_status_select),
		.pll_dsm_ecn_bypass(cmu_fpll_pll_dsm_ecn_bypass),
		.pll_dsm_ecn_test_en(cmu_fpll_pll_dsm_ecn_test_en),
		.pll_dsm_fractional_division(cmu_fpll_pll_dsm_fractional_division),
		.pll_dsm_fractional_value_ready(cmu_fpll_pll_dsm_fractional_value_ready),
		.pll_dsm_mode(cmu_fpll_pll_dsm_mode),
		.pll_dsm_out_sel(cmu_fpll_pll_dsm_out_sel),
		.pll_enable(cmu_fpll_pll_enable),
		.pll_extra_csr(cmu_fpll_pll_extra_csr),
		.pll_fbclk_mux_1(cmu_fpll_pll_fbclk_mux_1),
		.pll_fbclk_mux_2(cmu_fpll_pll_fbclk_mux_2),
		.pll_iqclk_mux_sel(cmu_fpll_pll_iqclk_mux_sel),
		.pll_l_counter(cmu_fpll_pll_l_counter),
		.pll_l_counter_bypass(cmu_fpll_pll_l_counter_bypass),
		.pll_l_counter_enable(cmu_fpll_pll_l_counter_enable),
		.pll_lf_resistance(cmu_fpll_pll_lf_resistance),
		.pll_lf_ripplecap(cmu_fpll_pll_lf_ripplecap),
		.pll_lock_fltr_cfg(cmu_fpll_pll_lock_fltr_cfg),
		.pll_lock_fltr_test(cmu_fpll_pll_lock_fltr_test),
		.pll_lpf_rstn_value(cmu_fpll_pll_lpf_rstn_value),
		.pll_m_counter(cmu_fpll_pll_m_counter),
		.pll_m_counter_coarse_dly(cmu_fpll_pll_m_counter_coarse_dly),
		.pll_m_counter_fine_dly(cmu_fpll_pll_m_counter_fine_dly),
		.pll_m_counter_in_src(cmu_fpll_pll_m_counter_in_src),
		.pll_m_counter_min_tco_enable(cmu_fpll_pll_m_counter_min_tco_enable),
		.pll_m_counter_ph_mux_prst(cmu_fpll_pll_m_counter_ph_mux_prst),
		.pll_m_counter_prst(cmu_fpll_pll_m_counter_prst),
		.pll_n_counter(cmu_fpll_pll_n_counter),
		.pll_n_counter_coarse_dly(cmu_fpll_pll_n_counter_coarse_dly),
		.pll_n_counter_fine_dly(cmu_fpll_pll_n_counter_fine_dly),
		.pll_nreset_invert(cmu_fpll_pll_nreset_invert),
		.pll_op_mode(cmu_fpll_pll_op_mode),
		.pll_optimal(cmu_fpll_pll_optimal),
		.pll_overrange_underrange_voltage_coarse_sel(cmu_fpll_pll_overrange_underrange_voltage_coarse_sel),
		.pll_overrange_voltage(cmu_fpll_pll_overrange_voltage),
		.pll_power_mode(cmu_fpll_pll_power_mode),
		.pll_powerdown_mode(cmu_fpll_pll_powerdown_mode),
		.pll_ppm_clk0_src(cmu_fpll_pll_ppm_clk0_src),
		.pll_ppm_clk1_src(cmu_fpll_pll_ppm_clk1_src),
		.pll_ref_buf_dly(cmu_fpll_pll_ref_buf_dly),
		.pll_rstn_override(cmu_fpll_pll_rstn_override),
		.pll_self_reset(cmu_fpll_pll_self_reset),
		.pll_silicon_rev(cmu_fpll_pll_silicon_rev),
		.pll_speed_grade(cmu_fpll_pll_speed_grade),
		.pll_sup_mode(cmu_fpll_pll_sup_mode),
		.pll_tclk_mux_en(cmu_fpll_pll_tclk_mux_en),
		.pll_tclk_sel(cmu_fpll_pll_tclk_sel),
		.pll_test_enable(cmu_fpll_pll_test_enable),
		.pll_underrange_voltage(cmu_fpll_pll_underrange_voltage),
		.pll_unlock_fltr_cfg(cmu_fpll_pll_unlock_fltr_cfg),
		.pll_vccr_pd_en(cmu_fpll_pll_vccr_pd_en),
		.pll_vco_freq_band(cmu_fpll_pll_vco_freq_band),
		.pll_vco_ph0_en(cmu_fpll_pll_vco_ph0_en),
		.pll_vco_ph0_value(cmu_fpll_pll_vco_ph0_value),
		.pll_vco_ph1_en(cmu_fpll_pll_vco_ph1_en),
		.pll_vco_ph1_value(cmu_fpll_pll_vco_ph1_value),
		.pll_vco_ph2_en(cmu_fpll_pll_vco_ph2_en),
		.pll_vco_ph2_value(cmu_fpll_pll_vco_ph2_value),
		.pll_vco_ph3_en(cmu_fpll_pll_vco_ph3_en),
		.pll_vco_ph3_value(cmu_fpll_pll_vco_ph3_value),
		.pll_vreg0_output(cmu_fpll_pll_vreg0_output),
		.pll_vreg1_output(cmu_fpll_pll_vreg1_output)		
	) fpll_inst
	(
		// Input Ports
		.avmmaddress(pll_avmm_address[8:0]),
		.avmmclk(pll_avmm_clk[0]),
		.avmmread(pll_avmm_read[0]),
		.avmmrstn(pll_avmm_rstn[0]),
		.avmmwrite(pll_avmm_write[0]),
		.avmmwritedata(pll_avmm_writedata[7:0]),

		.cnt_sel(cntsel),
		.csr_bufin(),
		.csr_clk(),
		.csr_en(),
		.csr_in(),
		.csr_en_dly(),
		.dps_rst_n(~phase_reset),
		.fbclk_in((compensation_mode == "normal") ? fbclk_wire : 1'b0),	
		.iqtxrxclk((compensation_mode == "iqtxrxclk") ? iqtxrxclk_wire : (compensation_mode == "fpll_bonding") ? pll_extfb_wire : 1'b0),
		.mdio_dis(),
		.num_phase_shifts(num_phase_shifts),
		.pfden(),
		.phase_en(phase_en),
		.pma_csr_test_dis(),
		.refclk(refclk_sel_outclk_wire),
		.rst_n(~pll_powerdown),
		.scan_mode_n(),
		.scan_shift_n(),
		.up_dn(updn),
			
		// Output Ports
		.avmmreaddata(pll_avmmreaddata_cmu_fpll[7:0]),
		.block_select(pll_blockselect_cmu_fpll[0]),
		.clk0(tx_serial_clk),
		.clk180(tx_serial_clk_n),
		.clklow(clklow),
		.csr_bufout(),
		.csr_out(),
		.fbclk_out(fbclk_wire),
		.fref(fref),
		.hclk_out(pll_pcie_clk),
		.iqtxrxclk_out(iqtxrxclk_wire),
		.lock(pll_locked),
		.outclk({outclk3, outclk2, outclk1, outclk0}),
		.overrange(overrange),
		.phase_done(phase_done),
		.pll_cascade_out(pll_cascade_clk),
		.underrange(underrange)	
	);
	
	//-----------------------------------
	// instantiate of twentynm_hssi_pma_cgb_master 
	generate
	if (enable_mcgb == 1) begin  
		twentynm_hssi_pma_cgb_master
		#(
		   .enable_debug_info					(	enable_debug_info									),	   
		   .silicon_rev							(	pma_cgb_master_silicon_rev							),
		   .datarate							(	pma_cgb_master_data_rate							),
		   .x1_div_m_sel						(	pma_cgb_master_x1_div_m_sel							),
		   .prot_mode							(	pma_cgb_master_prot_mode							),
		   .ser_mode							(	pma_cgb_master_ser_mode								),
		   .cgb_enable_iqtxrxclk				(	pma_cgb_master_cgb_enable_iqtxrxclk					), 
		   .cgb_power_down                     	(	pma_cgb_master_cgb_power_down                    	),
		   .master_cgb_clock_control           	(	pma_cgb_master_master_cgb_clock_control          	),
		   .observe_cgb_clocks                 	(	pma_cgb_master_observe_cgb_clocks                	),
		   .op_mode                            	(	pma_cgb_master_op_mode                           	),
		   .tx_ucontrol_reset_pcie             	(	pma_cgb_master_tx_ucontrol_reset_pcie            	),
		   .vccdreg_output                     	(	pma_cgb_master_vccdreg_output                    	),
		   .input_select                       	(	pma_cgb_master_input_select                      	),
		   .input_select_gen3                  	(	pma_cgb_master_input_select_gen3                 	)
		) twentynm_hssi_pma_cgb_master_inst (
		   .cgb_rstb(~mcgb_rst),                             // \OPEN active high or low?

		   //-----------------------------------           // \OPEN [FITTER]?      
		   .clk_fpll_b(mcgb_aux_clk2),
		   .clk_fpll_t(mcgb_aux_clk0),
		   .clk_lc_b(mcgb_aux_clk1),
		   .clk_lc_t(tx_serial_clk),

		   .clkb_fpll_b( /*unused*/ ),
		   .clkb_fpll_t( /*unused*/ ),
		   .clkb_lc_b( /*unused*/ ),
		   .clkb_lc_t( /*unused*/ ),
		   //-----------------------------------

		   .cpulse_out_bus(tx_bonding_clocks),              

		   .tx_iqtxrxclk_out(pll_extfb_wire),

		   .pcie_sw_done(pcie_sw_done),
		   .pcie_sw(pcie_sw),

		   //-----------------------------------                           
		   .tx_bonding_rstb(1'b1),                        // \NOTE carried over from slave cgb
		   //-----------------------------------  

		   .avmmaddress(avmm_address_mcgb),
		   .avmmclk(avmm_clk_mcgb),
		   .avmmread(avmm_read_mcgb),
		   .avmmrstn(avmm_rstn_mcgb),
		   .avmmwrite(avmm_write_mcgb),
		   .avmmwritedata(avmm_writedata_mcgb),
		   .avmmreaddata(avmmreaddata_mcgb),
		   .blockselect(blockselect_mcgb)        
		); 
	end
	endgenerate

endmodule
