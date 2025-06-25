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


// Filename: altera_xcvr_cdr_pll_a10.sv
// 
// Design instantiates following atom
// -- twentynm_xcvr_avmm
// -- twentynm_hssi_pma_cdr_refclk_select_mux
// -- twentynm_hssi_pma_channel_pll
 
// 			## TBD  - Fmin VCO
//			## TBD  - cdr_pll_chgpmp_current_pd , cdr_pll_chgpmp_current_pfd - pending data from ICD
//			##       [cdr_pll_chgpmp_replicate? , cdr_pll_chgpmp_testmode? ]  
//			## TBD  - some parameters below are commented, need to verify.
// 			## Apart from the above mentioned comments with TBD need to be finalized.
//			## Case:132274 - Cal_busy temporarily tied off.

module altera_xcvr_cdr_pll_a10
    #(
//### PARAM_LIST_START
		//-----------------------------------------------------------------------------------------------
		//Parameter list - twentynm_hssi_pma_channel_pll
		//-----------------------------------------------------------------------------------------------
        parameter cdr_pll_output_clock_frequency = "2500 Mhz", 
        parameter cdr_pll_reference_clock_frequency =  "125 Mhz",
		parameter cdr_pll_m_counter = 1,														// \RANGE (1) 2| 3 |4| 5|6|8| 9|10|12| 15|16| 18|20|24| 25|30|32| 36|40| 48| 50|60| 64|72| 80|96| 100|120| 128|160| 200
		parameter cdr_pll_n_counter = 1,														// \RANGE (1) 0..31
		parameter cdr_pll_pfd_l_counter = 1,													// \RANGE (1) 0|2|4|8|16|100
		parameter cdr_pll_pd_l_counter = 1,													 	// \RANGE (1) 0|2|4|8|16|100
		parameter cdr_pll_cdr_cmu_mode = "cmu_mode",											// \RANGE (cmu_mode) cdr_powerdn cdr_reset auto_mode auto_mode_ignore_lock cdr_mode
		parameter cdr_pll_prot_mode = "basic_rx",												// TBD - \RANGE (basic_rx) basic_kr_rx pcie_gen1_rx pcie_gen2_rx pcie_gen3_rx pcie_gen4_rx qpi_rx unused gpon_rx cpri_rx sata_rx
		parameter cdr_pll_bw_sel = "low",														// \RANGE (low) medium high
		parameter cdr_pll_pma_width = 8,
		parameter cdr_pll_silicon_rev = "reva",
		
		//TBD - need to set all parameters?
		parameter cdr_pll_iqclk_mux_sel = "power_down",
		parameter cdr_pll_cgb_div = 1,															// \RANGE (1) 2 4 8
		parameter cdr_pll_txpll_hclk_driver_enable = "false",									// \RANGE (false) true
		parameter cdr_pll_fb_select = "direct_fb",												// \RANGE (direct_fb) iqtxrxclk_fb
		parameter cdr_pll_atb_select_control = "atb_off",
		parameter cdr_pll_bbpd_data_pattern_filter_select = "bbpd_data_pat_off",
		parameter cdr_pll_cdr_odi_select = "sel_cdr",
		parameter cdr_pll_chgpmp_current_pd = "cp_current_pd_setting0",
		parameter cdr_pll_chgpmp_current_pfd = "cp_current_pfd_setting0",
		parameter cdr_pll_chgpmp_replicate = "true",
		parameter cdr_pll_chgpmp_testmode = "cp_test_disable",
		parameter cdr_pll_clklow_mux_select = "clklow_mux_cdr_fbclk",
		parameter cdr_pll_diag_loopback_enable = "false",
		parameter cdr_pll_disable_up_dn = "true",
		parameter cdr_pll_fref_clklow_div = 1,
		parameter cdr_pll_fref_mux_select = "fref_mux_cdr_refclk",
		parameter cdr_pll_gpon_lck2ref_control = "gpon_lck2ref_off",
		parameter cdr_pll_lck2ref_delay_control = "lck2ref_delay_off",
		parameter cdr_pll_lf_resistor_pd = "lf_pd_setting0",
		parameter cdr_pll_lf_resistor_pfd = "lf_pfd_setting0",
		parameter cdr_pll_lf_ripple_cap = "lf_no_ripple",
		parameter cdr_pll_loop_filter_bias_select = "lpflt_bias_off",
		parameter cdr_pll_loopback_mode = "loopback_disabled",
		parameter cdr_pll_ltd_ltr_micro_controller_select = "ltd_ltr_pcs",
		parameter cdr_pll_op_mode = "pwr_down",
		parameter cdr_pll_pd_fastlock_mode = "false",
		parameter cdr_pll_power_mode = "low_power",
		parameter cdr_pll_reverse_serial_loopback = "no_loopback",
		parameter cdr_pll_set_cdr_v2i_enable = "true",
		parameter cdr_pll_set_cdr_vco_reset = "false",
		parameter cdr_pll_set_cdr_vco_speed = "cdr_vco_max_speedbin",
		parameter cdr_pll_set_cdr_vco_speed_pciegen3 = "cdr_vco_max_speedbin_pciegen3",
		parameter cdr_pll_vco_overrange_voltage = "vco_overrange_off",
		parameter cdr_pll_vco_underrange_voltage = "vco_underange_off",
		parameter cdr_pll_is_cascaded_pll = "false",
		parameter cdr_pll_device_variant = "device1",
		parameter cdr_pll_optimal = "true",
		parameter cdr_pll_position = "position_unknown",
		parameter cdr_pll_primary_use = "cmu",
		parameter cdr_pll_side = "side_unknown",
		parameter cdr_pll_speed_grade = "dash2",
		parameter cdr_pll_sup_mode = "user_mode",
		parameter cdr_pll_top_or_bottom = "tb_unknown",
		//parameter cdr_pll_datarate = 0,
		//parameter cdr_pll_f_max_pfd = 0,
		//parameter cdr_pll_f_max_vco = 0,
		//parameter cdr_pll_f_min_pfd = 0,
		//parameter cdr_pll_f_min_vco = 0,
		//parameter cdr_pll_m_counter_scratch = 8'b1,
		//parameter cdr_pll_n_counter_scratch = 6'b1,
		//parameter cdr_pll_out_freq = 0,
		//parameter cdr_pll_reference_clock_frequency_scratch
		//parameter cdr_pll_vco_freq
		//parameter cdr_pll_pcie_gen
		//parameter cdr_pll_uc_cru_rstb
		//parameter cdr_pll_uc_ro_cal
		//parameter cdr_pll_uc_ro_cal_status

		
		parameter avmm_interfaces = 1,  // TBD - 1 for PLL, refclk mux need one?
		
		//YMCHIN ---------dummy PARAM -- needs to handle later on 
		
		parameter refclk_cnt = 1,
		parameter refclk_index = 0,
		//parameter silicon_rev = 0, //TBD - needs handling in UI
		parameter enable_pll_reconfig = 0,
		
		parameter SIZE_AVMM_RDDATA_BUS = 32,
		parameter SIZE_AVMM_WRDATA_BUS = 32,
		
		//-----------------------------------------------------------------------------------------------
		//Parameter list - twentynm_hssi_pma_cdr_refclk_select_mux
		//-----------------------------------------------------------------------------------------------
		parameter pma_cdr_refclk_select_mux_refclk_select = "ref_iqclk0",						 // \RANGE (ref_iqclk0) ref_iqclk1 ref_iqclk2 ref_iqclk3 ref_iqclk4 ref_iqclk5 ref_iqclk6 ref_iqclk7 ref_iqclk8 ref_iqclk9 ref_iqclk10 ref_iqclk11 iqtxrxclk0 iqtxrxclk1 iqtxrxclk2 iqtxrxclk3 iqtxrxclk4 iqtxrxclk5 coreclk fixed_clk lvpecl adj_pll_clk power_down     
		parameter pma_cdr_refclk_select_mux_silicon_rev = "reva",								 // \RANGE (reva) revb revc
		parameter pma_cdr_refclk_select_mux_xmux_refclk_src = "refclk_iqclk",					 // \RANGE (refclk_iqclk) refclk_coreclk
		parameter pma_cdr_refclk_select_mux_xpm_iqref_mux_iqclk_sel = "power_down",				 // \RANGE (power_down) ref_iqclk0 ref_iqclk1 ref_iqclk2 ref_iqclk3 ref_iqclk4 ref_iqclk5 ref_iqclk6 ref_iqclk7 ref_iqclk8 ref_iqclk9 ref_iqclk10 ref_iqclk11 iqtxrxclk0 iqtxrxclk1 iqtxrxclk2 iqtxrxclk3 iqtxrxclk4 iqtxrxclk5
		parameter pma_cdr_refclk_select_mux_inclk0_logical_to_physical_mapping = "ref_iqclk0",   // \RANGE (ref_iqclk0) ref_iqclk1 ref_iqclk2 ref_iqclk3 ref_iqclk4 ref_iqclk5 ref_iqclk6 ref_iqclk7 ref_iqclk8 ref_iqclk9 ref_iqclk10 ref_iqclk11 iqtxrxclk0 iqtxrxclk1 iqtxrxclk2 iqtxrxclk3 iqtxrxclk4 iqtxrxclk5 coreclk fixed_clk lvpecl adj_pll_clk power_down
		parameter pma_cdr_refclk_select_mux_inclk1_logical_to_physical_mapping = "ref_iqclk1",   // \RANGE (ref_iqclk1) ref_iqclk1 ref_iqclk2 ref_iqclk3 ref_iqclk4 ref_iqclk5 ref_iqclk6 ref_iqclk7 ref_iqclk8 ref_iqclk9 ref_iqclk10 ref_iqclk11 iqtxrxclk0 iqtxrxclk1 iqtxrxclk2 iqtxrxclk3 iqtxrxclk4 iqtxrxclk5 coreclk fixed_clk lvpecl adj_pll_clk power_down
		parameter pma_cdr_refclk_select_mux_inclk2_logical_to_physical_mapping = "ref_iqclk2",   // \RANGE (ref_iqclk2) ref_iqclk1 ref_iqclk2 ref_iqclk3 ref_iqclk4 ref_iqclk5 ref_iqclk6 ref_iqclk7 ref_iqclk8 ref_iqclk9 ref_iqclk10 ref_iqclk11 iqtxrxclk0 iqtxrxclk1 iqtxrxclk2 iqtxrxclk3 iqtxrxclk4 iqtxrxclk5 coreclk fixed_clk lvpecl adj_pll_clk power_down
		parameter pma_cdr_refclk_select_mux_inclk3_logical_to_physical_mapping = "ref_iqclk3",   // \RANGE (ref_iqclk3) ref_iqclk1 ref_iqclk2 ref_iqclk3 ref_iqclk4 ref_iqclk5 ref_iqclk6 ref_iqclk7 ref_iqclk8 ref_iqclk9 ref_iqclk10 ref_iqclk11 iqtxrxclk0 iqtxrxclk1 iqtxrxclk2 iqtxrxclk3 iqtxrxclk4 iqtxrxclk5 coreclk fixed_clk lvpecl adj_pll_clk power_down
		parameter pma_cdr_refclk_select_mux_inclk4_logical_to_physical_mapping = "ref_iqclk4",   // \RANGE (ref_iqclk4) ref_iqclk1 ref_iqclk2 ref_iqclk3 ref_iqclk4 ref_iqclk5 ref_iqclk6 ref_iqclk7 ref_iqclk8 ref_iqclk9 ref_iqclk10 ref_iqclk11 iqtxrxclk0 iqtxrxclk1 iqtxrxclk2 iqtxrxclk3 iqtxrxclk4 iqtxrxclk5 coreclk fixed_clk lvpecl adj_pll_clk power_down
		parameter pma_cdr_refclk_select_mux_xpm_iqref_mux_scratch0_src = "scratch0_power_down",  // \RANGE (scratch0_power_down) scratch0_ref_iqclk0 scratch0_ref_iqclk1 scratch0_ref_iqclk2 scratch0_ref_iqclk3 scratch0_ref_iqclk4 scratch0_ref_iqclk5 scratch0_ref_iqclk6 scratch0_ref_iqclk7 scratch0_ref_iqclk8 scratch0_ref_iqclk9 scratch0_ref_iqclk10 scratch0_ref_iqclk11 scratch0_iqtxrxclk0 scratch0_iqtxrxclk1 scratch0_iqtxrxclk2 scratch0_iqtxrxclk3 scratch0_iqtxrxclk4 scratch0_iqtxrxclk5
		parameter pma_cdr_refclk_select_mux_xpm_iqref_mux_scratch1_src = "scratch1_power_down",  // \RANGE (scratch1_power_down) scratch0_ref_iqclk0 scratch0_ref_iqclk1 scratch0_ref_iqclk2 scratch0_ref_iqclk3 scratch0_ref_iqclk4 scratch0_ref_iqclk5 scratch0_ref_iqclk6 scratch0_ref_iqclk7 scratch0_ref_iqclk8 scratch0_ref_iqclk9 scratch0_ref_iqclk10 scratch0_ref_iqclk11 scratch0_iqtxrxclk0 scratch0_iqtxrxclk1 scratch0_iqtxrxclk2 scratch0_iqtxrxclk3 scratch0_iqtxrxclk4 scratch0_iqtxrxclk5
		parameter pma_cdr_refclk_select_mux_xpm_iqref_mux_scratch2_src = "scratch2_power_down",  // \RANGE (scratch2_power_down) scratch0_ref_iqclk0 scratch0_ref_iqclk1 scratch0_ref_iqclk2 scratch0_ref_iqclk3 scratch0_ref_iqclk4 scratch0_ref_iqclk5 scratch0_ref_iqclk6 scratch0_ref_iqclk7 scratch0_ref_iqclk8 scratch0_ref_iqclk9 scratch0_ref_iqclk10 scratch0_ref_iqclk11 scratch0_iqtxrxclk0 scratch0_iqtxrxclk1 scratch0_iqtxrxclk2 scratch0_iqtxrxclk3 scratch0_iqtxrxclk4 scratch0_iqtxrxclk5
		parameter pma_cdr_refclk_select_mux_xpm_iqref_mux_scratch3_src = "scratch3_power_down",  // \RANGE (scratch3_power_down) scratch0_ref_iqclk0 scratch0_ref_iqclk1 scratch0_ref_iqclk2 scratch0_ref_iqclk3 scratch0_ref_iqclk4 scratch0_ref_iqclk5 scratch0_ref_iqclk6 scratch0_ref_iqclk7 scratch0_ref_iqclk8 scratch0_ref_iqclk9 scratch0_ref_iqclk10 scratch0_ref_iqclk11 scratch0_iqtxrxclk0 scratch0_iqtxrxclk1 scratch0_iqtxrxclk2 scratch0_iqtxrxclk3 scratch0_iqtxrxclk4 scratch0_iqtxrxclk5
		parameter pma_cdr_refclk_select_mux_xpm_iqref_mux_scratch4_src = "scratch4_power_down"   // \RANGE (scratch4_power_down) scratch0_ref_iqclk0 scratch0_ref_iqclk1 scratch0_ref_iqclk2 scratch0_ref_iqclk3 scratch0_ref_iqclk4 scratch0_ref_iqclk5 scratch0_ref_iqclk6 scratch0_ref_iqclk7 scratch0_ref_iqclk8 scratch0_ref_iqclk9 scratch0_ref_iqclk10 scratch0_ref_iqclk11 scratch0_iqtxrxclk0 scratch0_iqtxrxclk1 scratch0_iqtxrxclk2 scratch0_iqtxrxclk3 scratch0_iqtxrxclk4 scratch0_iqtxrxclk5
		//-------------------------------------------------------------------------------------------------
		
//### PARAM_LIST_END
    )
    (
//### PORT_LIST_START
	          
        // reset
        input wire          pll_powerdown,
        
		// avmm interface for PLL 
		input wire reconfig_clk0,
		input wire reconfig_reset0,
		input wire reconfig_write0,
		input wire reconfig_read0,
		input wire [9:0] reconfig_address0,                        //[8:0] is for twentynm_xcvr_avmm, MSB is for future expansion of soft CSR registers.  
		input wire [SIZE_AVMM_WRDATA_BUS-1:0] reconfig_writedata0,
		output wire [SIZE_AVMM_RDDATA_BUS-1:0] reconfig_readdata0,
		output reconfig_waitrequest0,
		output pll_cal_busy,
		output hip_cal_done,
		
        // twentynm_hssi_pma_cdr_refclk_select_mux
        input wire    pll_refclk0,
		input wire    pll_refclk1,
		input wire    pll_refclk2,
		input wire    pll_refclk3,
		input wire    pll_refclk4,
        
        // output clocks and status
		output wire         tx_serial_clk,
        output wire         pll_locked                           

//### PORT_LIST_END
    );

	//wires for AVMM to PLL interface
	// interface #0 to PLL, interface #1 to CGB 
    wire  [avmm_interfaces-1    :0] pll_avmm_clk;
    wire  [avmm_interfaces-1    :0] pll_avmm_rstn;
    wire  [avmm_interfaces*8-1  :0] pll_avmm_writedata;
    wire  [avmm_interfaces*9-1  :0] pll_avmm_address;
    wire  [avmm_interfaces-1    :0] pll_avmm_write;
    wire  [avmm_interfaces-1    :0] pll_avmm_read;
     
    wire  [avmm_interfaces*8-1  :0] pll_avmmreaddata_cdr_pll;                 			// NOTE only [7:0] is used
	//assign pll_avmmreaddata_cdr_pll[avmm_interfaces*8-1:8] = { 8 {1'b0} };     			// NOTE hence [15:8] is tied-off to '0'
	
    wire  [avmm_interfaces*8-1  :0] pll_avmmreaddata_cdr_refclk_select;       			// NOTE only [7:0] is used  
	//assign pll_avmmreaddata_cdr_refclk_select[avmm_interfaces*8-1:8] = { 8 {1'b0} };   	// NOTE hence [15:8] is tied-off to '0'

    wire  [avmm_interfaces-1    :0] pll_blockselect_cdr_pll;                  			// NOTE only [0:0] is used
	//assign pll_blockselect_cdr_pll[avmm_interfaces-1:1] = {1'b0};                      	// NOTE hence [1:1] is tied-off to '0'
	 
    wire  [avmm_interfaces-1    :0] pll_blockselect_cdr_refclk_select;        			// NOTE only [0:0] is used 
	//assign pll_blockselect_cdr_refclk_select[avmm_interfaces-1:1] = {1'b0};            	// NOTE hence [1:1] is tied-off to '0'
	 
	wire  [avmm_interfaces-1    :0] pld_cal_done;  
	
	// Case:132274 - Tie off Cal_busy for the time being. 
	//assign pll_cal_busy = ~pld_cal_done[0];
	assign pll_cal_busy = 1'b0;
	
    wire        w_cdr_refclk_select_refclk;
	wire 		reconfig_busy0;
    
	assign reconfig_readdata0[31:8] = 24'b0;
	
	///////////Multiple refclk support///////////////////////////////////////////
	localparam refclk_select = refclk_index == 0  ?  "ref_iqclk0" :
                               refclk_index == 1  ?  "ref_iqclk1" :
                               refclk_index == 2  ?  "ref_iqclk2" :
                               refclk_index == 3  ?  "ref_iqclk3" :
                               refclk_index == 4  ?  "ref_iqclk4" :
                                                     "ref_iqclk0" ;
	
	localparam REF_IQCLK_INPUT = 12;
    localparam REFCLK_CNT = 5;
	////////////////////////////////////////////////////////////////////////////////
	
	// instantiating twentynm_xcvr_avmm

		twentynm_xcvr_avmm
    #(
       .avmm_interfaces(avmm_interfaces),       //Number of AVMM interfaces required - one for each bonded_lane, PLL, and Master CGB                                 
       .arbiter_ctrl ("pld"), 					// TBD == "uc"? 
       .calibration_en ("disable"),				// Enable/disable calibration attributes
	   .enable_avmm(1)                			//Enable/disable AVMM atom instantiation
    )

    inst_twentynm_xcvr_avmm (
       .avmm_clk(       reconfig_clk0       ),
	   .avmm_reset( reconfig_reset0 ),
       .avmm_writedata( reconfig_writedata0[7:0] ),
       .avmm_address(   reconfig_address0[8:0]   ),
       .avmm_write(     reconfig_write0     ),
       .avmm_read(      reconfig_read0      ),
       .avmm_readdata(  reconfig_readdata0[7:0]  ),
       .avmm_waitrequest(reconfig_waitrequest0),
	   .avmm_busy(      reconfig_busy0      ),    
	   .hip_cal_done( hip_cal_done),
	   .pld_cal_done(pld_cal_done),
	   

       .chnl_pll_avmm_clk(pll_avmm_clk),
       .chnl_pll_avmm_rstn(pll_avmm_rstn),
       .chnl_pll_avmm_writedata(pll_avmm_writedata),
       .chnl_pll_avmm_address(pll_avmm_address),
       .chnl_pll_avmm_write(pll_avmm_write),
       .chnl_pll_avmm_read(pll_avmm_read),    

       .pma_avmmreaddata_cdr_pll(pll_avmmreaddata_cdr_pll),                           
       .pma_avmmreaddata_cdr_refclk_select(pll_avmmreaddata_cdr_refclk_select), 
      
       .pma_blockselect_cdr_pll(pll_blockselect_cdr_pll),            
       .pma_blockselect_cdr_refclk_select(pll_blockselect_cdr_refclk_select),

		// UNUSED PORTS
	   .pll_avmmreaddata_lc_pll					  ( {avmm_interfaces{8'b0}} ),
	   .pll_avmmreaddata_lc_refclk_select		  ( {avmm_interfaces{8'b0}} ),
	   .pll_avmmreaddata_cgb_master				  ( {avmm_interfaces{8'b0}} ),
	   .pll_blockselect_lc_pll					  ( {avmm_interfaces{1'b0}} ),
	   .pll_blockselect_lc_refclk_select		  ( {avmm_interfaces{1'b0}} ),
	   .pll_blockselect_cgb_master				  ( {avmm_interfaces{1'b0}} ),
	   .pma_avmmreaddata_tx_ser                   ( {avmm_interfaces{8'b0}} ),
       .pma_avmmreaddata_tx_cgb                   ( {avmm_interfaces{8'b0}} ),
       .pma_avmmreaddata_tx_buf                   ( {avmm_interfaces{8'b0}} ),
       .pma_avmmreaddata_rx_deser                 ( {avmm_interfaces{8'b0}} ),
       .pma_avmmreaddata_rx_buf                   ( {avmm_interfaces{8'b0}} ),
       .pma_avmmreaddata_rx_sd                    ( {avmm_interfaces{8'b0}} ),
       .pma_avmmreaddata_rx_odi                   ( {avmm_interfaces{8'b0}} ),
       .pma_avmmreaddata_rx_dfe                   ( {avmm_interfaces{8'b0}} ),
       .pma_avmmreaddata_pma_adapt                ( {avmm_interfaces{8'b0}} ),
       .pma_blockselect_tx_ser                    ( {avmm_interfaces{1'b0}} ),
       .pma_blockselect_tx_cgb                    ( {avmm_interfaces{1'b0}} ),
       .pma_blockselect_tx_buf                    ( {avmm_interfaces{1'b0}} ),
       .pma_blockselect_rx_deser                  ( {avmm_interfaces{1'b0}} ),
       .pma_blockselect_rx_buf                    ( {avmm_interfaces{1'b0}} ),
       .pma_blockselect_rx_sd                     ( {avmm_interfaces{1'b0}} ),
       .pma_blockselect_rx_odi                    ( {avmm_interfaces{1'b0}} ),
       .pma_blockselect_rx_dfe                    ( {avmm_interfaces{1'b0}} ),
       .pma_blockselect_pma_adapt                 ( {avmm_interfaces{1'b0}} ),
       .pcs_avmmreaddata_8g_rx_pcs                ( {avmm_interfaces{8'b0}} ),
       .pcs_avmmreaddata_pipe_gen1_2              ( {avmm_interfaces{8'b0}} ),
       .pcs_avmmreaddata_8g_tx_pcs                ( {avmm_interfaces{8'b0}} ),
       .pcs_avmmreaddata_10g_rx_pcs               ( {avmm_interfaces{8'b0}} ),
       .pcs_avmmreaddata_10g_tx_pcs               ( {avmm_interfaces{8'b0}} ),
       .pcs_avmmreaddata_gen3_rx_pcs              ( {avmm_interfaces{8'b0}} ),
       .pcs_avmmreaddata_pipe_gen3                ( {avmm_interfaces{8'b0}} ),
       .pcs_avmmreaddata_gen3_tx_pcs              ( {avmm_interfaces{8'b0}} ),
       .pcs_avmmreaddata_krfec_rx_pcs             ( {avmm_interfaces{8'b0}} ),
       .pcs_avmmreaddata_krfec_tx_pcs             ( {avmm_interfaces{8'b0}} ),
       .pcs_avmmreaddata_fifo_rx_pcs              ( {avmm_interfaces{8'b0}} ),
       .pcs_avmmreaddata_fifo_tx_pcs              ( {avmm_interfaces{8'b0}} ),
       .pcs_avmmreaddata_rx_pcs_pld_if            ( {avmm_interfaces{8'b0}} ),
       .pcs_avmmreaddata_com_pcs_pld_if           ( {avmm_interfaces{8'b0}} ),
       .pcs_avmmreaddata_tx_pcs_pld_if            ( {avmm_interfaces{8'b0}} ),
       .pcs_avmmreaddata_rx_pcs_pma_if            ( {avmm_interfaces{8'b0}} ),
       .pcs_avmmreaddata_com_pcs_pma_if           ( {avmm_interfaces{8'b0}} ),
       .pcs_avmmreaddata_tx_pcs_pma_if            ( {avmm_interfaces{8'b0}} ),
       .pcs_blockselect_8g_rx_pcs                 ( {avmm_interfaces{1'b0}} ),
       .pcs_blockselect_pipe_gen1_2               ( {avmm_interfaces{1'b0}} ),
       .pcs_blockselect_8g_tx_pcs                 ( {avmm_interfaces{1'b0}} ),
       .pcs_blockselect_10g_rx_pcs                ( {avmm_interfaces{1'b0}} ),
       .pcs_blockselect_10g_tx_pcs                ( {avmm_interfaces{1'b0}} ),
       .pcs_blockselect_gen3_rx_pcs               ( {avmm_interfaces{1'b0}} ),
       .pcs_blockselect_pipe_gen3                 ( {avmm_interfaces{1'b0}} ),
       .pcs_blockselect_gen3_tx_pcs               ( {avmm_interfaces{1'b0}} ),
       .pcs_blockselect_krfec_rx_pcs              ( {avmm_interfaces{1'b0}} ),
       .pcs_blockselect_krfec_tx_pcs              ( {avmm_interfaces{1'b0}} ),
       .pcs_blockselect_fifo_rx_pcs               ( {avmm_interfaces{1'b0}} ),
       .pcs_blockselect_fifo_tx_pcs               ( {avmm_interfaces{1'b0}} ),
       .pcs_blockselect_rx_pcs_pld_if             ( {avmm_interfaces{1'b0}} ),
       .pcs_blockselect_com_pcs_pld_if            ( {avmm_interfaces{1'b0}} ),
       .pcs_blockselect_tx_pcs_pld_if             ( {avmm_interfaces{1'b0}} ),
       .pcs_blockselect_rx_pcs_pma_if             ( {avmm_interfaces{1'b0}} ),
       .pcs_blockselect_com_pcs_pma_if            ( {avmm_interfaces{1'b0}} ),
       .pcs_blockselect_tx_pcs_pma_if             ( {avmm_interfaces{1'b0}} ),
       .pll_avmmreaddata_cmu_fpll                 ( {avmm_interfaces{8'b0}} ),
       .pll_avmmreaddata_cmu_fpll_refclk_select   ( {avmm_interfaces{8'b0}} ),
       .pll_blockselect_cmu_fpll                  ( {avmm_interfaces{1'b0}} ),
       .pll_blockselect_cmu_fpll_refclk_select    ( {avmm_interfaces{1'b0}} )

    );
    
    
        // instantiating twentynm_hssi_pma_cdr_refclk_select_mux           
        twentynm_hssi_pma_cdr_refclk_select_mux #(
			.refclk_select						(pma_cdr_refclk_select_mux_refclk_select),    // ref_iqclk0|ref_iqclk1|ref_iqclk2|ref_iqclk3|ref_iqclk4|ref_iqclk5|ref_iqclk6|ref_iqclk7|ref_iqclk8|ref_iqclk9|ref_iqclk10|ref_iqclk11|iqtxrxclk0|iqtxrxclk1|iqtxrxclk2|iqtxrxclk3|iqtxrxclk4|iqtxrxclk5|coreclk|fixed_clk|lvpecl|adj_pll_clk
            .silicon_rev						(pma_cdr_refclk_select_mux_silicon_rev),
			.xmux_refclk_src                    (pma_cdr_refclk_select_mux_xmux_refclk_src),
			.inclk0_logical_to_physical_mapping (pma_cdr_refclk_select_mux_inclk0_logical_to_physical_mapping), // scratch0_ref_iqclk0|scratch0_ref_iqclk1|scratch0_ref_iqclk2|scratch0_ref_iqclk3|scratch0_ref_iqclk4|scratch0_ref_iqclk5|scratch0_ref_iqclk6|scratch0_ref_iqclk7|scratch0_ref_iqclk8|scratch0_ref_iqclk9|scratch0_ref_iqclk10|scratch0_ref_iqclk11|scratch0_iqtxrxclk0|scratch0_iqtxrxclk1|scratch0_iqtxrxclk2|scratch0_iqtxrxclk3|scratch0_iqtxrxclk4|scratch0_iqtxrxclk5|scratch0_power_down
            .inclk1_logical_to_physical_mapping (pma_cdr_refclk_select_mux_inclk1_logical_to_physical_mapping),
			.inclk2_logical_to_physical_mapping (pma_cdr_refclk_select_mux_inclk2_logical_to_physical_mapping),
			.inclk3_logical_to_physical_mapping (pma_cdr_refclk_select_mux_inclk3_logical_to_physical_mapping),
			.inclk4_logical_to_physical_mapping (pma_cdr_refclk_select_mux_inclk4_logical_to_physical_mapping),
			.xpm_iqref_mux_scratch0_src         (pma_cdr_refclk_select_mux_xpm_iqref_mux_scratch0_src),
			.xpm_iqref_mux_scratch1_src			(pma_cdr_refclk_select_mux_xpm_iqref_mux_scratch1_src),
			.xpm_iqref_mux_scratch2_src			(pma_cdr_refclk_select_mux_xpm_iqref_mux_scratch2_src),
			.xpm_iqref_mux_scratch3_src			(pma_cdr_refclk_select_mux_xpm_iqref_mux_scratch3_src),
			.xpm_iqref_mux_scratch4_src			(pma_cdr_refclk_select_mux_xpm_iqref_mux_scratch4_src),
			.xpm_iqref_mux_iqclk_sel			(pma_cdr_refclk_select_mux_xpm_iqref_mux_iqclk_sel)
        ) inst_twentynm_hssi_pma_cdr_refclk_select_mux (            
            ///INPUTS
			.ref_iqclk          ({{(REF_IQCLK_INPUT-REFCLK_CNT){1'b0}}, {pll_refclk4, pll_refclk3, pll_refclk2, pll_refclk1, pll_refclk0}}),  // Hard-coded to iqtxrxclk[0] by .refclk_select and .xpm_iqref_mux_iqclk_sel parameters
            .avmmaddress        (pll_avmm_address),
            .avmmclk            (pll_avmm_clk),
            .avmmread           (pll_avmm_read),
            .avmmrstn           (pll_avmm_rstn),
            .avmmwrite          (pll_avmm_write),
            .avmmwritedata      (pll_avmm_writedata),  
			.avmmreaddata		(pll_avmmreaddata_cdr_refclk_select),
			
			///OUTPUTS
            .blockselect        (pll_blockselect_cdr_refclk_select), // TBD - not sure about this
            .refclk             (w_cdr_refclk_select_refclk),
			
			///UNUSED PORTS //TBD
			.rx_det_clk			( /*unused*/ ),
            .core_refclk        ( /*unused*/ ), // in_core_refclk
            .iqtxrxclk          ( /*unused*/ ) // in_iqtxrxclk
            
        );
    

    
        // instantiating twentynm_hssi_pma_channel_pll
        twentynm_hssi_pma_channel_pll #(
			.reference_clock_frequency  (cdr_pll_reference_clock_frequency),          
            .output_clock_frequency     (cdr_pll_output_clock_frequency),   
			.m_counter          		(cdr_pll_m_counter),     
            .n_counter          		(cdr_pll_n_counter),    
            .pfd_l_counter      		(cdr_pll_pfd_l_counter),
            .pd_l_counter       		(cdr_pll_pd_l_counter),
			.cdr_cmu_mode       		(cdr_pll_cdr_cmu_mode),
			.prot_mode 					(cdr_pll_prot_mode),
			.bw_sel						(cdr_pll_bw_sel),
            .cgb_div            		(cdr_pll_cgb_div),                
            .txpll_hclk_driver_enable	(cdr_pll_txpll_hclk_driver_enable),  
            .fb_select					(cdr_pll_fb_select),                
            .iqclk_mux_sel				(cdr_pll_iqclk_mux_sel),
			
			.atb_select_control					(cdr_pll_atb_select_control),
			.bbpd_data_pattern_filter_select	(cdr_pll_bbpd_data_pattern_filter_select),
			.cdr_odi_select						(cdr_pll_cdr_odi_select),
			.chgpmp_current_pd					(cdr_pll_chgpmp_current_pd),
			.chgpmp_current_pfd					(cdr_pll_chgpmp_current_pfd),
			.chgpmp_replicate					(cdr_pll_chgpmp_replicate),
			.chgpmp_testmode					(cdr_pll_chgpmp_testmode),
			.clklow_mux_select					(cdr_pll_clklow_mux_select),
			.diag_loopback_enable				(cdr_pll_diag_loopback_enable),
			.disable_up_dn						(cdr_pll_disable_up_dn),
			.fref_clklow_div					(cdr_pll_fref_clklow_div),
			.fref_mux_select					(cdr_pll_fref_mux_select),
			.gpon_lck2ref_control				(cdr_pll_gpon_lck2ref_control),
			.lck2ref_delay_control				(cdr_pll_lck2ref_delay_control),
			.lf_resistor_pd						(cdr_pll_lf_resistor_pd),
			.lf_resistor_pfd					(cdr_pll_lf_resistor_pfd),
			.lf_ripple_cap						(cdr_pll_lf_ripple_cap),
			.loop_filter_bias_select			(cdr_pll_loop_filter_bias_select),
			.loopback_mode						(cdr_pll_loopback_mode),
			.ltd_ltr_micro_controller_select	(cdr_pll_ltd_ltr_micro_controller_select),
			.op_mode							(cdr_pll_op_mode),
			.pd_fastlock_mode					(cdr_pll_pd_fastlock_mode),
			.power_mode							(cdr_pll_power_mode),
			.reverse_serial_loopback			(cdr_pll_reverse_serial_loopback),
			.set_cdr_v2i_enable					(cdr_pll_set_cdr_v2i_enable),
			.set_cdr_vco_reset					(cdr_pll_set_cdr_vco_reset),
			.set_cdr_vco_speed					(cdr_pll_set_cdr_vco_speed),
			.set_cdr_vco_speed_pciegen3			(cdr_pll_set_cdr_vco_speed_pciegen3),
			.vco_overrange_voltage				(cdr_pll_vco_overrange_voltage),
			.vco_underrange_voltage				(cdr_pll_vco_underrange_voltage),
			.pma_width							(cdr_pll_pma_width),
			.is_cascaded_pll					(cdr_pll_is_cascaded_pll),
			.device_variant						(cdr_pll_device_variant),
			.optimal							(cdr_pll_optimal),
			.position							(cdr_pll_position),
			.primary_use						(cdr_pll_primary_use),
			.side								(cdr_pll_side),
			.silicon_rev						(cdr_pll_silicon_rev),
			.speed_grade						(cdr_pll_speed_grade),
			.sup_mode							(cdr_pll_sup_mode),
			.top_or_bottom						(cdr_pll_top_or_bottom)
			//.datarate							(cdr_pll_datarate),
			//.f_max_pfd							(cdr_pll_f_max_pfd),
			//.f_max_vco							(cdr_pll_f_max_vco),
			//.f_min_pfd							(cdr_pll_f_min_pfd),
			//.f_min_vco							(cdr_pll_f_min_vco),
			//.m_counter_scratch					(cdr_pll_m_counter_scratch),
			//.n_counter_scratch					(cdr_pll_n_counter_scratch)
			//.out_freq							(cdr_pll_out_freq),
			//.reference_clock_frequency_scratch	(cdr_pll_reference_clock_frequency_scratch),
			//.vco_freq							(cdr_pll_vco_freq),
			//.pcie_gen							(cdr_pll_pcie_gen),
			//.uc_cru_rstb						(cdr_pll_uc_cru_rstb),
			//.uc_ro_cal							(cdr_pll_uc_ro_cal),
			//.uc_ro_cal_status					(cdr_pll_uc_ro_cal_status)
			
			
        ) inst_twentynm_hssi_pma_channel_pll (
            
			//INPUTS
            .refclk(w_cdr_refclk_select_refclk),
            .rst_n(~pll_powerdown),   // make reset active high
			
			//OUTPUTS
			.clk0_pfd(tx_serial_clk),		 
			.lock(pll_locked),			 
			//     AVMM
            .avmmaddress        (pll_avmm_address),
            .avmmclk            (pll_avmm_clk),
            .avmmread           (pll_avmm_read),
            .avmmrstn           (pll_avmm_rstn),
            .avmmwrite          (pll_avmm_write),
            .avmmwritedata      (pll_avmm_writedata),
			.avmmreaddata		(pll_avmmreaddata_cdr_pll),
			
			
			.blockselect        (pll_blockselect_cdr_pll),
			.ltr(1'b1),
			.ltd_b(1'b1),
            .sd(1'b0),          // w_pma_rx_sd_sd
            .ppm_lock(1'b0),    // in_ppm_lock      
			
           // UNUSED PORTS 
			.clk180_pfd			(/*unused*/),   
			.clk0_pd			(/*unused*/),        
            .clk180_pd			(/*unused*/),   	
            .overrange			(/*unused*/),
            .rxpll_lock			(/*unused*/),
            .underrange			(/*unused*/),
            .clk0_bbpd			(/*unused*/),
			.clk90_bbpd			(/*unused*/),
			.clk180_bbpd		(/*unused*/),
			.clk270_bbpd		(/*unused*/),
			.clk90_eye			(/*unused*/),
			.clk270_eye			(/*unused*/),
            .clk270_des			(/*unused*/),
            .clk270_pd			(/*unused*/),
            .clk90_des			(/*unused*/),
            .clk90_pd			(/*unused*/),            
            .cdr_lpbkp			(/*unused*/),
            .cdr_lpbkdp			(/*unused*/),
			.deven_eye			(/*unused*/),
            .deven_des			(/*unused*/),
			.dfe_test			(/*unused*/),
			.dodd_eye			(/*unused*/),
			.dodd_des			(/*unused*/),
            .fref				(/*unused*/),
            .clklow				(/*unused*/),            
			.iqtxrxclk			(/*unused*/),   // in_iqtxrxclk (feedback clock)
            .deven				(/*unused*/),
            .dodd				(/*unused*/),
            .e270				(/*unused*/),
			.e270b				(/*unused*/),
            .e90				(/*unused*/),
			.e90b				(/*unused*/),
            .early_eios			(/*unused*/),
            .pcie_sw			(/*unused*/),     // in_pcie_sw
            .fpll_test0			(/*unused*/),                             
			.fpll_test1			(/*unused*/),
			.ibc50u				(/*unused*/),
			.ibp50u				(/*unused*/),
			.rx_deser_pclk_test	(/*unused*/),
			.rxp				(/*unused*/),
			.tx_ser_pclk_test	(/*unused*/),
			.lock2ref			(/*unused*/),
			.lock2ref_delay		(/*unused*/),
			.rxpll_lock_delay	(/*unused*/),
			.rx_lpbkn			( /*unused*/ ),
			.rx_lpbkp			( /*unused*/ ),
			.cdr_refclk_cal_out	( /*unused*/ ),
			.cdr_vco_cal_out	( /*unused*/ ),
			.rlpbkdn			( /*unused*/ ),
			.rlpbkdp			( /*unused*/ ),
			.rlpbkn				( /*unused*/ ),
			.rlpbkp				( /*unused*/ ),
			.tx_rlpbk			( /*unused*/ ),
			.von_lp				( /*unused*/ ),
			.vop_lp				( /*unused*/ ) 
            
        );
		
		

endmodule
