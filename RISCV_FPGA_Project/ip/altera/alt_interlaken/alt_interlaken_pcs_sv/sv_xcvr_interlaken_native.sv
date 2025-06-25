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


//###########################################################################
// This module Instantiates  sv_xcvr_native and Generic PLL
// This module manually bonds the 5 CH/PLL or 6 CH/PLL depending on PLL TYPE
// $Header$
//###########################################################################

`timescale 1ns/1ps

import altera_xcvr_functions::*;


module sv_xcvr_interlaken_native 
  #(
    parameter CH_INDEX = 1,
    parameter PLEX = "DUPLEX",		          
    parameter LINKWIDTH = 5,
    parameter METALEN = 2048,

    // PLL
    parameter PLL_REFCLK_CNT = 1,         // number of reference clocks
    parameter PLL_REF_FREQ = "312.5 MHz", // frequency of each refernce clock
    parameter PLL_REFCLK_SELECT = "0",    // selects the initial reference clock for each TX PLL
    parameter PLLS = 1,    
    parameter PLL_TYPE = "AUTO" ,         // PLL type pf each pll
    parameter PLL_SELECT = 0,              // selects the initial PLL
    parameter NUM_PLLS = 1,

    // Data rate
    parameter DATA_RATE = "6250 Mbps",
    parameter BASE_DATA_RATE = "0 Mbps",  // (PLL Rate) - must be (data_rate * 1,2,4,or8)
    //     
    parameter TX_USE_CORECLK = 1,
    parameter RX_USE_CORECLK = 1,
    parameter MASTER_LANE = 0,
    parameter BONDED_GROUP_SIZE = 1
  
    )(
  
    input [LINKWIDTH -1 :0] rx_serial_data,
    input 		    pll_ref_clk,
    input [(LINKWIDTH*64)-1:0] tx_datain,
    input [LINKWIDTH-1:0]      tx_ctrlin,
      //   
    output [LINKWIDTH-1:0]     tx_dataready,
  
  
    output [NUM_PLLS-1:0]      pll_locked,
    output [LINKWIDTH-1:0]     rx_is_lockedtodata,
    output [LINKWIDTH-1:0]     rx_is_lockedtoref,			
    output [LINKWIDTH-1:0]     tx_serial_data,
    output [LINKWIDTH*64-1:0]  rx_dataout,
    output [LINKWIDTH-1:0]     rx_datavalid, 
  
    input [LINKWIDTH-1:0]      tx_datavalid,  //  wr_en of TX_FIFO
  
      //   RX/TX FIFO status signals for multialignment logic
    output [LINKWIDTH-1:0]     rx_fifopempty,
    output [LINKWIDTH-1:0]     rx_fifofull,
    output [LINKWIDTH-1:0]     rx_fifopfull,
    
    input [LINKWIDTH-1:0]      rx_dataready,   //rd_en of RX FIFO
    input [LINKWIDTH-1:0]      rx_fifoclr, 	// clear signal for RX FIFO to flush the fifo
  
  
    output [LINKWIDTH-1:0]     rx_ctrlout,

// renaming 
      // rx_syncout=> rx_block_frame_lock
      //  rx_wordlock => rx_align_val
      //  rx_synclock => rx_frame_lock    
    output [LINKWIDTH-1:0]     rx_block_frame_lock,
    output [LINKWIDTH-1:0]     rx_align_val,
    output [LINKWIDTH-1:0]     rx_frame_lock,      
    output [LINKWIDTH-1:0]     rx_crc32err,
    output [LINKWIDTH-1:0]     rx_framing_error,
    output [LINKWIDTH-1:0]     rx_scrambler_mismatch,
    output [LINKWIDTH-1:0]     rx_missing_sync,			
  
    output [LINKWIDTH-1:0]     tx_clkout,
    output [LINKWIDTH-1:0]     rx_clkout,
  
    input 		       csr_pll_powerdown,
    input [LINKWIDTH-1:0]      csr_tx_digitalreset,
    input [LINKWIDTH-1:0]      csr_rx_analogreset,									
    input [LINKWIDTH-1:0]      csr_rx_digitalreset,
    input [LINKWIDTH-1:0]      csr_phy_loopback_serial,
    input [LINKWIDTH-1:0]      csr_rx_set_locktodata,
    input [LINKWIDTH-1:0]      csr_rx_set_locktoref, 			
    input 		       rx_coreclkin,
    input 		       tx_coreclkin,
    output 		       tx_user_clock,
    output 		       rx_user_clock,     
    // Calibration busy signals
    output  wire    [LINKWIDTH-1:0]     tx_cal_busy,
    output  wire    [LINKWIDTH-1:0]     rx_cal_busy, 


      // Following for PCS bonding Solution IP

      // Burst_en : Async input of Frame generator, TX FIFO read is controlled by the burst_en, 
      // when burst_en "0" frame generator will not read any data from FIFO and insert SKIP continuously
      // tx_fifo_pfull - Synchronous output, TX FIFO partialfull flag
      // tx_frame: Async Output of the frame generator, goes "1" when begining of the new metaframe
      // 
    input [LINKWIDTH-1:0]      tx_burst_en,
    output [LINKWIDTH-1:0]     tx_fifo_pfull,
    output [LINKWIDTH-1:0]     tx_fifo_full,
    output [LINKWIDTH-1:0]     tx_fifo_empty,            
    output [LINKWIDTH-1:0]     tx_frame,
      
      //Reconfig interface
    input   wire [get_interlaken_reconfig_to_width  ("Stratix V",PLEX,BONDED_GROUP_SIZE,LINKWIDTH)-1:0] reconfig_to_xcvr,
    output  wire [get_interlaken_reconfig_from_width("Stratix V",PLEX,BONDED_GROUP_SIZE,LINKWIDTH)-1:0] reconfig_from_xcvr 
  
  
      );

   import altera_xcvr_functions::*;

   // reconfig parameters
   localparam w_bundle_to_xcvr     = W_S5_RECONFIG_BUNDLE_TO_XCVR;
   localparam w_bundle_from_xcvr   = W_S5_RECONFIG_BUNDLE_FROM_XCVR;
   localparam reconfig_interfaces = altera_xcvr_functions::get_interlaken_reconfig_interfaces("Stratix V",PLEX,BONDED_GROUP_SIZE,LINKWIDTH);
   
   //localparam time data_rate_int = str2hz(data_rate);    // data rate in Hz.  Must use time unit since its a 64-bit unsigned int
`define data_rate_int (str2hz(DATA_RATE)/1000000)       // data rate in Hz.  Must use time unit since its a 64-bit unsigned int
   //`define half_data_rate string'(hz2str(`data_rate_int/2))
   
   localparam pll_select = 0;   
   // Default base data rate to data rate if not specified
   localparam [MAX_STRS*MAX_CHARS*8-1:0] INT_BASE_DATA_RATE = (get_value_at_index(0, BASE_DATA_RATE) == "0 Mbps") ? DATA_RATE : BASE_DATA_RATE;
   localparam INT_TX_CLK_DIV = str2hz(get_value_at_index(pll_select, INT_BASE_DATA_RATE)) / str2hz(DATA_RATE);
   

   
   wire [LINKWIDTH-1:0] tx_pma_clkout;
   wire [LINKWIDTH-1:0] rx_pma_clkout;
   wire [LINKWIDTH-1:0] tx_partialfull;   
   
   wire [(LINKWIDTH*40)-1:0] tx_pmadata;
   wire [(LINKWIDTH*40)-1:0] rx_pmadata;
   wire [LINKWIDTH-1:0]      rx_pll_locked;
   
   wire [LINKWIDTH-1:0]      slblpbkout;
   
   
   wire [LINKWIDTH*9 -1:0]   tx_control;
   wire [LINKWIDTH-1:0]     tx_fifo_pempty;
   wire [LINKWIDTH-1:0]     tx_fifo_empty_int;   
   wire [LINKWIDTH-1:0]     tx_fifo_pempty_int;    
   wire [LINKWIDTH-1:0]     r_csr_tx_digitalreset;
   
   
   
   localparam  INT_RX_ENABLE = (PLEX == "Rx" || PLEX == "RX"
				|| PLEX == "Duplex" || PLEX == "DUPLEX") ? 1 : 0;
   localparam  INT_TX_ENABLE = (PLEX == "Tx" || PLEX == "TX"
				|| PLEX == "Duplex" || PLEX == "DUPLEX") ? 1 : 0;
   localparam NUM_RECONFIG_INTERFACES = LINKWIDTH + PLLS;

   assign tx_fifo_pfull = tx_partialfull;
   
   assign tx_dataready = tx_fifo_pempty;   



   wire [LINKWIDTH-1:0] rx_pll_reset;
   wire [LINKWIDTH-1:0] rx_pma_fref;
   wire [LINKWIDTH-1:0] rx_pma_clklow;
   wire [LINKWIDTH-1:0] freqlock_torxpma;
   wire [LINKWIDTH-1:0] signaldetect_from_pma;
   
   
   wire 		sv_tx_clk;
   
   wire [LINKWIDTH * 10 - 1 : 0] rx_pcs_ctrl_out;
   
   
   wire [NUM_PLLS-1:0] 		 pll_locked_wire;
   
   assign pll_locked = pll_locked_wire;
   wire 			 tx_pld_clk;
   wire 			 rx_pld_clk;


// Declare local merged versions of reconfig buses 
   wire [get_interlaken_reconfig_to_width  ("Stratix V",PLEX,BONDED_GROUP_SIZE,LINKWIDTH)-1:0] rcfg_to_xcvr;
   wire [get_interlaken_reconfig_from_width ("Stratix V",PLEX,BONDED_GROUP_SIZE,LINKWIDTH)-1:0] rcfg_from_xcvr;



   
   
   // Check for the clock_connection_mode parameter,
   // if mode is auto then rx_clkout[master_lane] will feed rdclk for RX Deskew FIFO and tx_clkout[master_lane] will feed a wrclk of TX FIFO
   // if mode is manual then user provided rx_coreclk will feed the rdclk for RX Deskew FIFO, user provided tx_coreclk will feed the wrclk for TX FIFO 
   assign tx_pld_clk = (!TX_USE_CORECLK) ? tx_clkout[MASTER_LANE] : tx_coreclkin;
   assign rx_pld_clk = (!RX_USE_CORECLK) ? rx_clkout[MASTER_LANE] : rx_coreclkin;      
   assign tx_user_clock = tx_clkout[MASTER_LANE];
   assign rx_user_clock = rx_clkout[MASTER_LANE];

   genvar   ig;
   genvar   num_word;
   

   
   generate

      for (ig=0; ig<LINKWIDTH; ig=ig+1) begin:inst_sv_xcvr_native

	 
	// bonding size for bonded channl instantiation
	// Calculate the num_bonded
	// If bonded_group_size = 5 and suppose LINKWIDTH = 10
	// for ig =0,1,2,3,4 num_bonded = 5
	// for ig = 5-9, num_bonded = LINKWIDTH - ig which is (5,4, 3, 2, 1)
	 localparam num_bonded = (BONDED_GROUP_SIZE > (LINKWIDTH-ig)) ? LINKWIDTH-ig : BONDED_GROUP_SIZE;

	 // Determine the pllindex paramater as we need following logic for pllindex
	 // ig = 0, pllindex = 0
	 // ig = 1, pllindex = 1
	 // ig = 10, pllindex = 2
	 // ig = 15, pllindex = 3
	 // so pllindex = ig/5 i.e. ig/BONDED_GROUP_SIZE
	 localparam pllindex = (ig/BONDED_GROUP_SIZE);
	 
	 if (ig % BONDED_GROUP_SIZE == 0)
	   // come here only when ig is 0 and multiple of BONDED_GROUP SIZE so in case of
	   // BONDED_GROUP_SIZE =5, implement following when ig = 0, 5, 10, 15, 20...
	   begin
	      
	      wire [PLLS-1:0] sv_tx_clk;
	      
	      
	      if (INT_TX_ENABLE == 1) begin
		 wire [PLLS-1:0] pll_fb_clk;
		 
		 
		 sv_xcvr_plls #(
				.plls (PLLS),
				.pll_type(PLL_TYPE),
				.refclks(PLL_REFCLK_CNT),
				.reference_clock_frequency(PLL_REF_FREQ),
				.reference_clock_select(PLL_REFCLK_SELECT),
				.output_clock_datarate(INT_BASE_DATA_RATE)
				
				) tx_pll0 (
					   .refclk (pll_ref_clk),
					   .rst (csr_pll_powerdown),
					   .outclk (sv_tx_clk),
					   .locked (pll_locked_wire[pllindex*PLLS+:PLLS]),					   
					   .fbclk (pll_fb_clk),
					   .fboutclk (pll_fb_clk),
					   // avalon MM native reconfiguration interfaces
					   .reconfig_to_xcvr    (rcfg_to_xcvr  [(LINKWIDTH+(PLLS*pllindex))*w_bundle_to_xcvr+:PLLS*w_bundle_to_xcvr]),
					   .reconfig_from_xcvr  (rcfg_from_xcvr[(LINKWIDTH+(PLLS*pllindex))*w_bundle_from_xcvr+:PLLS*w_bundle_from_xcvr])
					   );
	      end // if (INT_TX_ENABLE == 1)
	      else  // TX disabled
		begin
		   assign sv_tx_clk = {PLLS{1'b0}};
		   assign pll_locked_wire[pllindex*PLLS+:PLLS]= {PLLS{1'b1}};
		end // else: !if(INT_TX_ENABLE == 1)
	      
	      /* Defination of rx_ctrl_out is as follows, all are synchronous status signals	       
	       Bit 9: block_frame_lock
	       bit 8: error_out (sync_header_error or Metaframe error or CRC32 error)
	       bit 7: Diagnostic Word location within a Metaframe
	       bit 6 :SKIP Word location within a Metaframe
	       bit 5: Scrambler State Word location within a Metaframe
	       bit 4: Synchronization Word location within a Metaframe
	       bit 3 : indicates a non SKIP Word in the SKIP Word location within a Metaframe. Referred to as the PYLD_INS bit
	       bit 2 : inversion bit - sync_hdr[2],
	       bit 1 : sync_hdr[1], (1 indicates control word)
	       bit 0 : sync_hdr[0], (1 indicate data word)
	       
	       bit1,0 = 01 - data word
	       = 10 - control word
	       
	       bit 2: 0 - no inversion
	       1 - inversion 
	       
	       */   
	      // RX PCS Interlaken Specific Parameter description
	      // tx_fifo_mode rx_fifo_mode ("generic")  :put TX FIFO and RXFIFO in generic mode for Interlaken
	      // rxfifo_align_del_en ("true"), : When rxfifo alignment detection in Interlaken mode, the align word is deleted
	      // rxfifo_control_del ("control_del_all") : When RXFIFO is in Interlaken generic mode, all control words (metarfame words - skip, scrambler, diagnostic) are deleted
	      
	      sv_xcvr_native #(
			       // Common parameters
			       // PMA Parameters
			       .rx_enable (INT_RX_ENABLE),
			       .tx_enable(INT_TX_ENABLE),
			       .enable_10g_rx(INT_RX_ENABLE ? "true" : "false"),
			       .enable_10g_tx(INT_TX_ENABLE ? "true" : "false"),
			       .enable_8g_rx ("false"),
			       .enable_8g_tx ("false"),
			       .enable_dyn_reconfig("false"),
			       .enable_gen12_pipe("false"),
			       .enable_gen3_pipe("false"),
			       .enable_gen3_rx ("false"),
			       .enable_gen3_tx ("false"),
			       .tx_clk_div(INT_TX_CLK_DIV),

			       // New
			       .plls(PLLS),
			       .pll_sel(PLL_SELECT),
			       

		 
			       // Interface specific parameters
			       .rx_pcs_pma_if_selectpcs("ten_g_pcs"),
			       .rx_pld_pcs_if_selectpcs("ten_g_pcs"),			  
			       .tx_pcs_pma_if_selectpcs("ten_g_pcs"),
			       .rx_pcs_pma_if_prot_mode("other_protocols"),
			       .com_pcs_pma_if_func_mode("teng_only"),
			       .com_pcs_pma_if_prot_mode("other_protocols"),
			       .com_pcs_pma_if_sup_mode("user_mode"),
			       .com_pcs_pma_if_force_freqdet("force_freqdet_dis"),
			       .com_pcs_pma_if_ppmsel("ppmsel_1000"),

			       .pcs10g_tx_tx_polarity_inv("invert_disable"),
		 
			       .bonded_lanes (num_bonded),
			       .pma_mode (40),
			       .pma_data_rate (DATA_RATE),
			       .channel_number (0),
			       .auto_negotiation ("false"),
		 
			       // TX PCS parameters
		 
			       .pcs10g_tx_gb_tx_idwidth ("width_67"),
			       .pcs10g_tx_gb_tx_odwidth ("width_40"),
			       .pcs10g_tx_prot_mode ("interlaken_mode"),
			       .pcs10g_tx_txfifo_mode ("interlaken_generic"),
			       `ifdef ALTERA_RESERVED_QIS_ES
			       .pcs10g_tx_frmgen_mfrm_length("frmgen_mfrm_length_user_setting"),
			       `endif				       
			       .pcs10g_tx_frmgen_mfrm_length_user (METALEN),
			       .pcs10g_tx_enc_64b66b_txsm_bypass("enc_64b66b_txsm_bypass_en"),
			       .pcs10g_tx_tx_sm_bypass("tx_sm_bypass_en"), 
			       .pcs10g_tx_scrm_seed("scram_seed_user_setting"),
			       .pcs10g_tx_scrm_seed_user (58'h123456789abcde + (24'h826a73 * (CH_INDEX+ig))),
			       .pcs10g_tx_test_mode ("test_off"),
			       .pcs10g_tx_pseudo_random ("all_0"),
			       .pcs10g_tx_sq_wave ("sq_wave_4"),
			       // Assign following parameters to default values to avoid critical warning
			       .pcs10g_tx_sup_mode("user_mode"),
			       .pcs10g_tx_sh_err("sh_err_dis"),
			       .pcs10g_tx_bitslip_en("bitslip_dis"),
			       .pcs10g_tx_tx_testbus_sel("crc32_gen_testbus1"),
			       .pcs10g_tx_comp_cnt("<auto_any>"),			       
			       //.pcs10g_tx_comp_del_sel_agg("<auto_any>"),	
			       .pcs10g_tx_distup_bypass_pipeln_agg("<auto_any>"),
			       .pcs10g_tx_txfifo_pempty(8),			       			       

                               // For TX PCS bonding
			       .pcs10g_tx_frmgen_burst("frmgen_burst_en"),

			       // RX PMA Parameters
			       .cdr_reference_clock_frequency (PLL_REF_FREQ),

			       // RX PCS Parameters
			       .pcs10g_rx_gb_rx_idwidth ("width_40"),
			       .pcs10g_rx_gb_rx_odwidth ("width_67"),
			       .pcs10g_rx_prot_mode ("interlaken_mode"),
		 
			       .pcs10g_rx_gb_sel_mode ("internal"),
			       .pcs10g_rx_blksync_knum_sh_cnt_prelock ("knum_sh_cnt_prelock_10g"),
			       .pcs10g_rx_blksync_knum_sh_cnt_postlock ("knum_sh_cnt_postlock_10g"),
			       .pcs10g_rx_blksync_enum_invalid_sh_cnt ("enum_invalid_sh_cnt_10g"),			  
			       .pcs10g_rx_blksync_bypass ("blksync_bypass_dis"),
			       `ifdef ALTERA_RESERVED_QIS_ES
			       .pcs10g_rx_frmsync_mfrm_length("frmsync_mfrm_length_user_setting"),
			       `endif	
			       .pcs10g_rx_frmsync_mfrm_length_user(METALEN),
			       .pcs10g_rx_rx_sm_hiber("rx_sm_hiber_en"),
			       .pcs10g_rx_rxfifo_mode("generic_interlaken"),
			       // MAC needs to see all control words so updating
			       // rx_control_del to control_del_none and 
			       // rx_align_en to "align_del_dis" 
//			       .pcs10g_rx_align_del("align_del_en"),
//			       .pcs10g_rx_control_del("control_del_all"),
			       .pcs10g_rx_align_del("align_del_dis"),
			       .pcs10g_rx_control_del("control_del_none"),
			       .pcs10g_rx_rxfifo_pempty(8),			       
			       .pcs10g_rx_test_mode("test_off"),
			       // Assign following parameters to default values to avoid critical warnings			       
			       .pcs10g_rx_sup_mode("user_mode"),
			       .pcs10g_rx_rx_testbus_sel("crc32_chk_testbus1"),
			       .pcs10g_rx_rx_polarity_inv("invert_disable")
			       ) 
	      interlaken_inst (
			       // TX/RX ports
			       // +: is part select e.g. [ig+: num_bonded] means start from ig and add num_bonded bits there
		 
			       .seriallpbken(csr_phy_loopback_serial[ig +: num_bonded]),   // 1 = enable serial loopback                    
		 
			       // RX Ports                                                                 
			       .rx_crurstn(~csr_rx_analogreset[ig +: num_bonded]),  
			       .rx_datain(rx_serial_data[ig +: num_bonded]),      // RX serial data input                          
			       .rx_cdr_ref_clk({num_bonded{pll_ref_clk}}), // Reference clock for CDR                       
			       .rx_ltd(csr_rx_set_locktodata[ig +: num_bonded]),         // Force lock-to-data stream                     
			       .rx_is_lockedtoref(rx_is_lockedtoref[ig +: num_bonded]),  // Indicates lock to reference clock
			       .rx_is_lockedtodata(rx_is_lockedtodata[ig +: num_bonded]),
		 
		 
			       // TX Ports                                                                 
		 
			       .tx_rxdetclk(1'b0),    // Clock for detection of downstream receiver
			       .tx_dataout(tx_serial_data[ig +: num_bonded]),     // TX serial data output
			       .tx_rstn({num_bonded{~csr_pll_powerdown}}),       
			       .tx_ser_clk({num_bonded{sv_tx_clk}}),     // High-speed serial clock from PLL   
                    // calibration status indication
                   .tx_cal_busy(tx_cal_busy[ig +: num_bonded]),
                   .rx_cal_busy(rx_cal_busy[ig +: num_bonded]),           
		 
			       // PCS Ports
			       .in_agg_align_status(/*unused*/),
			       .in_agg_align_status_sync_0(/*unused*/),
			       .in_agg_align_status_sync_0_top_or_bot(/*unused*/),
			       .in_agg_align_status_top_or_bot(/*unused*/),
			       .in_agg_cg_comp_rd_d_all(/*unused*/),
			       .in_agg_cg_comp_rd_d_all_top_or_bot(/*unused*/),
			       .in_agg_cg_comp_wr_all(/*unused*/),
			       .in_agg_cg_comp_wr_all_top_or_bot(/*unused*/),
			       .in_agg_del_cond_met_0(/*unused*/),
			       .in_agg_del_cond_met_0_top_or_bot(/*unused*/),
			       .in_agg_en_dskw_qd(/*unused*/),
			       .in_agg_en_dskw_qd_top_or_bot(/*unused*/),
			       .in_agg_en_dskw_rd_ptrs(/*unused*/),
			       .in_agg_en_dskw_rd_ptrs_top_or_bot(/*unused*/),
			       .in_agg_fifo_ovr_0(/*unused*/),
			       .in_agg_fifo_ovr_0_top_or_bot(/*unused*/),
			       .in_agg_fifo_rd_in_comp_0(/*unused*/),
			       .in_agg_fifo_rd_in_comp_0_top_or_bot(/*unused*/),
			       .in_agg_fifo_rst_rd_qd(/*unused*/),
			       .in_agg_fifo_rst_rd_qd_top_or_bot(/*unused*/),
			       .in_agg_insert_incomplete_0(/*unused*/),
			       .in_agg_insert_incomplete_0_top_or_bot(/*unused*/),
			       .in_agg_latency_comp_0(/*unused*/),
			       .in_agg_latency_comp_0_top_or_bot(/*unused*/),
			       .in_agg_rcvd_clk_agg(/*unused*/),
			       .in_agg_rcvd_clk_agg_top_or_bot(/*unused*/),
			       .in_agg_rx_control_rs(/*unused*/),
			       .in_agg_rx_control_rs_top_or_bot(/*unused*/),
			       .in_agg_rx_data_rs(/*unused*/),
			       .in_agg_rx_data_rs_top_or_bot(/*unused*/),
			       .in_agg_test_so_to_pld_in(/*unused*/),
			       .in_agg_testbus(/*unused*/),
			       .in_agg_tx_ctl_ts(/*unused*/),
			       .in_agg_tx_ctl_ts_top_or_bot(/*unused*/),
			       .in_agg_tx_data_ts(/*unused*/),
			       .in_agg_tx_data_ts_top_or_bot(/*unused*/),
			       .in_emsip_com_in(/*unused*/),
			       .in_emsip_com_special_in(/*unused*/),
			       .in_emsip_rx_clk_in(/*unused*/),
			       .in_emsip_rx_in(/*unused*/),
			       .in_emsip_rx_special_in(/*unused*/),
			       .in_emsip_tx_clk_in(/*unused*/),
			       .in_emsip_tx_in(/*unused*/),
			       .in_emsip_tx_special_in(/*unused*/),
		 
			       .in_pld_10g_refclk_dig({num_bonded{1'b0}}),
			       .in_pld_10g_rx_align_clr(rx_fifoclr[ig +: num_bonded]),
			       .in_pld_10g_rx_align_en({num_bonded{1'b1}}),
			       .in_pld_10g_rx_bitslip({num_bonded{1'b0}}),
			       .in_pld_10g_rx_clr_ber_count({num_bonded{1'b0}}),
			       .in_pld_10g_rx_clr_errblk_cnt({num_bonded{1'b0}}),
			       .in_pld_10g_rx_disp_clr({num_bonded{1'b0}}),
			       .in_pld_10g_rx_pld_clk({num_bonded{rx_pld_clk}}),
			       .in_pld_10g_rx_prbs_err_clr({num_bonded{1'b0}}),
			       .in_pld_10g_rx_rd_en(rx_dataready[ig +: num_bonded]),
			       .in_pld_10g_rx_rst_n(~csr_rx_digitalreset[ig +: num_bonded]),
		 
			       .in_pld_tx_data(tx_datain[64*ig +: num_bonded*64]), //tx_datain is 64 bit bus
			       .in_pld_10g_tx_bitslip({num_bonded{7'b0}}),
			       
			       // Bring out busrt_en for PCS bonding solution IP
			       //.in_pld_10g_tx_burst_en({num_bonded{1'b1}}),
			       .in_pld_10g_tx_burst_en(tx_burst_en[ig +: num_bonded]),			       
			       
			       .in_pld_10g_tx_control(tx_control[9*ig +: num_bonded*9]), //tx_control is 9 bit bus per lane
			       .in_pld_10g_tx_data_valid(tx_datavalid[ig +: num_bonded]),
			       .in_pld_10g_tx_diag_status({num_bonded{2'b11}}), //lane,link status, hardcode to 11, 11 means lane & link is healthy
			       .in_pld_10g_tx_pld_clk({num_bonded{tx_pld_clk}}),
			       .in_pld_10g_tx_rst_n(~csr_tx_digitalreset[ig +: num_bonded]),
			       .in_pld_10g_tx_wordslip({num_bonded{1'b0}}),
		 
			       .in_pld_8g_a1a2_size(/*unused*/),
			       .in_pld_8g_bitloc_rev_en(/*unused*/),
			       .in_pld_8g_bitslip(/*unused*/),
			       .in_pld_8g_byte_rev_en(/*unused*/),
			       .in_pld_8g_bytordpld(/*unused*/),
			       .in_pld_8g_cmpfifourst_n(/*unused*/),
			       .in_pld_8g_encdt(/*unused*/),
			       .in_pld_8g_phfifourst_rx_n(/*unused*/),
			       .in_pld_8g_phfifourst_tx_n(/*unused*/),
			       .in_pld_8g_pld_rx_clk(/*unused*/),
			       .in_pld_8g_pld_tx_clk(/*unused*/),
			       .in_pld_8g_polinv_rx(/*unused*/),
			       .in_pld_8g_polinv_tx(/*unused*/),
			       .in_pld_8g_powerdown(/*unused*/),
			       .in_pld_8g_prbs_cid_en(/*unused*/),
			       .in_pld_8g_rddisable_tx(/*unused*/),
			       .in_pld_8g_rdenable_rmf(/*unused*/),
			       .in_pld_8g_rdenable_rx(/*unused*/),
			       .in_pld_8g_refclk_dig(/*unused*/),
			       .in_pld_8g_refclk_dig2(/*unused*/),
			       .in_pld_8g_rev_loopbk(/*unused*/),
			       .in_pld_8g_rxpolarity(/*unused*/),
			       .in_pld_8g_rxurstpcs_n(/*unused*/),
			       .in_pld_8g_tx_blk_start(/*unused*/),
			       .in_pld_8g_tx_boundary_sel(/*unused*/),
			       .in_pld_8g_tx_data_valid(/*unused*/),
			       .in_pld_8g_tx_sync_hdr(/*unused*/),
			       .in_pld_8g_txdeemph(/*unused*/),
			       .in_pld_8g_txdetectrxloopback(/*unused*/),
			       .in_pld_8g_txelecidle(/*unused*/),
			       .in_pld_8g_txmargin(/*unused*/),
			       .in_pld_8g_txswing(/*unused*/),
			       .in_pld_8g_txurstpcs_n(/*unused*/),
			       .in_pld_8g_wrdisable_rx(/*unused*/),
			       .in_pld_8g_wrenable_rmf(/*unused*/),
			       .in_pld_8g_wrenable_tx(/*unused*/),
			       .in_pld_agg_refclk_dig(/*unused*/),
			       .in_pld_eidleinfersel(/*unused*/),
			       .in_pld_gen3_current_coeff(/*unused*/),
			       .in_pld_gen3_current_rxpreset(/*unused*/),
			       .in_pld_gen3_rx_rstn(/*unused*/),
			       .in_pld_gen3_tx_rstn(/*unused*/),
			       .in_pld_ltr(csr_rx_set_locktoref[ig +: num_bonded]),
			       .in_pld_partial_reconfig_in({num_bonded{1'b1}}),
			       .in_pld_pcs_pma_if_refclk_dig(/*unused*/),
			       .in_pld_rate(/*unused*/),
			       .in_pld_reserved_in(/*unused*/),
			       .in_pld_rx_clk_slip_in({num_bonded{1'b0}}),
			       .in_pld_rxpma_rstb_in(~csr_rx_analogreset[ig +: num_bonded]),  
			       .in_pld_scan_mode_n({num_bonded{1'b1}}),
			       .in_pld_scan_shift_n({num_bonded{1'b1}}),
			       .in_pld_sync_sm_en(/*unused*/),
			       .in_pma_clkdiv33_lc_in({num_bonded{1'b0}}),
			       .in_pma_eye_monitor_in(/*unused*/),
			       .in_pma_hclk(/*unused*/),
			       .in_pma_reserved_in(/*unused*/),
			       .in_pma_rx_freq_tx_cmu_pll_lock_in({num_bonded{1'b0}}),
			       .in_pma_tx_lc_pll_lock_in({num_bonded{1'b0}}),
		 
		 
			       .out_agg_align_det_sync(/*unused*/),                               
			       .out_agg_align_status_sync(/*unused*/),
			       .out_agg_cg_comp_rd_d_out(/*unused*/),
			       .out_agg_cg_comp_wr_out(/*unused*/),
			       .out_agg_dec_ctl(/*unused*/),
			       .out_agg_dec_data(/*unused*/),
			       .out_agg_dec_data_valid(/*unused*/),
			       .out_agg_del_cond_met_out(/*unused*/),
			       .out_agg_fifo_ovr_out(/*unused*/),
			       .out_agg_fifo_rd_out_comp(/*unused*/),
			       .out_agg_insert_incomplete_out(/*unused*/),
			       .out_agg_latency_comp_out(/*unused*/),
			       .out_agg_rd_align(/*unused*/),
			       .out_agg_rd_enable_sync(/*unused*/),
			       .out_agg_refclk_dig(/*unused*/),
			       .out_agg_running_disp(/*unused*/),
			       .out_agg_rxpcs_rst(/*unused*/),
			       .out_agg_scan_mode_n(/*unused*/),
			       .out_agg_scan_shift_n(/*unused*/),
			       .out_agg_sync_status(/*unused*/),
			       .out_agg_tx_ctl_tc(/*unused*/),
			       .out_agg_tx_data_tc(/*unused*/),
			       .out_agg_txpcs_rst(/*unused*/),
			       .out_emsip_com_clk_out(/*unused*/),
			       .out_emsip_com_out(/*unused*/),
			       .out_emsip_com_special_out(/*unused*/),
			       .out_emsip_rx_clk_out(/*unused*/),
			       .out_emsip_rx_out(/*unused*/),
			       .out_emsip_rx_special_out(/*unused*/),
			       .out_emsip_tx_clk_out(/*unused*/),
			       .out_emsip_tx_out(/*unused*/),
			       .out_emsip_tx_special_out(/*unused*/),		 
			       .out_pld_rx_data(rx_dataout[64*ig +: num_bonded*64]),
			       .out_pld_10g_rx_align_val(rx_align_val[ig +: num_bonded]),			       
			       .out_pld_10g_rx_blk_lock(/*unused*/),
			       .out_pld_10g_rx_clk_out(rx_clkout[ig +: num_bonded]),
			       .out_pld_10g_rx_control(rx_pcs_ctrl_out[10*ig +: num_bonded*10]), //rx_control is 10 bit bus/lane
			       .out_pld_10g_rx_crc32_err(rx_crc32err[ig +: num_bonded]),
			       .out_pld_10g_rx_data_valid(rx_datavalid[ig +: num_bonded]),
			       .out_pld_10g_rx_diag_err(/*unused*/),
			       .out_pld_10g_rx_diag_status(/*unused*/),
			       .out_pld_10g_rx_empty(/*unused*/),
			       .out_pld_10g_rx_fifo_del(/*unused*/),
			       .out_pld_10g_rx_fifo_insert(/*unused*/),
			       .out_pld_10g_rx_frame_lock(rx_frame_lock[ig +: num_bonded]),
			       .out_pld_10g_rx_hi_ber(/*unused*/),
			       .out_pld_10g_rx_mfrm_err(rx_framing_error[ig +: num_bonded]),
			       .out_pld_10g_rx_oflw_err(rx_fifofull[ig +: num_bonded]),
			       .out_pld_10g_rx_pempty(rx_fifopempty[ig +: num_bonded]),
			       .out_pld_10g_rx_pfull(rx_fifopfull[ig +: num_bonded]),
			       .out_pld_10g_rx_prbs_err(/*unused*/),
			       .out_pld_10g_rx_pyld_ins(/*unused*/),
			       .out_pld_10g_rx_rdneg_sts(/*unused*/),
			       .out_pld_10g_rx_rdpos_sts(/*unused*/),
			       .out_pld_10g_rx_rx_frame(/*unused*/),
			       .out_pld_10g_rx_scrm_err(rx_scrambler_mismatch[ig +: num_bonded]),
			       .out_pld_10g_rx_sh_err(/*unused*/),
			       .out_pld_10g_rx_skip_err(/*unused*/),
			       .out_pld_10g_rx_skip_ins(/*unused*/),
			       .out_pld_10g_rx_sync_err(rx_missing_sync[ig +: num_bonded]),
		 
			       .out_pld_10g_tx_burst_en_exe(/*unused*/),
			       .out_pld_10g_tx_clk_out(tx_clkout[ig +: num_bonded]),
			       .out_pld_10g_tx_empty(tx_fifo_empty_int[ig +: num_bonded]),
			       .out_pld_10g_tx_fifo_del(/*unused*/),
			       .out_pld_10g_tx_fifo_insert(/*unused*/),
			  
			       // Expose tx_frame and pfull for PCS bonding solution IP			       
			       .out_pld_10g_tx_frame(tx_frame[ig +: num_bonded]),
			       .out_pld_10g_tx_pfull(tx_partialfull[ig +: num_bonded]),
			       
			       .out_pld_10g_tx_full(tx_fifo_full[ig +: num_bonded]),
			       .out_pld_10g_tx_pempty(tx_fifo_pempty_int[ig +: num_bonded]),
			       .out_pld_10g_tx_wordslip_exe(/*unused*/),
		 
			       .out_pld_8g_a1a2_k1k2_flag(/*unused*/),
			       .out_pld_8g_align_status(/*unused*/),
			       .out_pld_8g_bistdone(/*unused*/),
			       .out_pld_8g_bisterr(/*unused*/),
			       .out_pld_8g_byteord_flag(/*unused*/),
			       .out_pld_8g_empty_rmf(/*unused*/),
			       .out_pld_8g_empty_rx(/*unused*/),
			       .out_pld_8g_empty_tx(/*unused*/),
			       .out_pld_8g_full_rmf(/*unused*/),
			       .out_pld_8g_full_rx(/*unused*/),
			       .out_pld_8g_full_tx(/*unused*/),
			       .out_pld_8g_phystatus(/*unused*/),
			       .out_pld_8g_rlv_lt(/*unused*/),
			       .out_pld_8g_rx_blk_start(/*unused*/),
			       .out_pld_8g_rx_clk_out(/*unused*/),
			       .out_pld_8g_rx_data_valid(/*unused*/),
			       .out_pld_8g_rx_sync_hdr(/*unused*/),
			       .out_pld_8g_rxelecidle(/*unused*/),
			       .out_pld_8g_rxstatus(/*unused*/),
			       .out_pld_8g_rxvalid(/*unused*/),
			       .out_pld_8g_signal_detect_out(/*unused*/),
			       .out_pld_8g_tx_clk_out(/*unused*/),
			       .out_pld_8g_wa_boundary(/*unused*/),
		 
			       .out_pld_clkdiv33_lc(/*unused*/),
			       .out_pld_clkdiv33_txorrx(/*unused*/),
			       .out_pld_clklow(/*unused*/),
			       .out_pld_fref(/*unused*/),
			       .out_pld_gen3_mask_tx_pll(/*unused*/),
			       .out_pld_gen3_rx_eq_ctrl(/*unused*/),
			       .out_pld_gen3_rxdeemph(/*unused*/),
			       .out_pld_reserved_out(/*unused*/),
			       .out_pld_test_data(/*unused*/),
			       .out_pld_test_si_to_agg_out(/*unused*/),
			       .out_pma_current_rxpreset(/*unused*/),
			       .out_pma_eye_monitor_out(/*unused*/),
			       .out_pma_lc_cmu_rstb(/*unused*/),
			       .out_pma_nfrzdrv(/*unused*/),
			       .out_pma_partial_reconfig(/*unused*/),
			       .out_pma_reserved_out(/*unused*/),
			       .out_pma_rx_clk_out(/*unused*/),
			       //			  .out_pma_rxpma_rstb(/*unused*/),
			       .out_pma_tx_clk_out(/*unused*/),
			       .out_pma_tx_pma_syncp_fbkp(/*unused*/),
		 
			       // sv_xcvr_avmm ports
			       .reconfig_to_xcvr(rcfg_to_xcvr   [ig*w_bundle_to_xcvr+:num_bonded*w_bundle_to_xcvr]    ),
			       .reconfig_from_xcvr(rcfg_from_xcvr [ig*w_bundle_from_xcvr+:num_bonded*w_bundle_from_xcvr]) 
		 
			       );
	   end // if (ig % BONDED_GROUP_SIZE == 0)
      end // block: inst_sv_xcvr_native
      
   endgenerate
   
   // Merge critical reconfig signals
   sv_reconfig_bundle_merger 
     #(
       .reconfig_interfaces(reconfig_interfaces)
       ) sv_reconfig_bundle_merger_inst (
					 // Reconfig buses to/from reconfig controller
					 .rcfg_reconfig_to_xcvr  (reconfig_to_xcvr   ),
					 .rcfg_reconfig_from_xcvr(reconfig_from_xcvr ),
					 
					 // Reconfig buses to/from native xcvr
					 .xcvr_reconfig_to_xcvr  (rcfg_to_xcvr   ),
					 .xcvr_reconfig_from_xcvr(rcfg_from_xcvr )
					 );
   


   // rx_pcs_ctrl_out is 10 bit bus per lane, out of that bit [4] is syncout and bit [2:0] are sync_hdr bits and decides whether is's a control word or data word, so for single lane:
   //	 assign rx_ctrlout[lanenum] = (rx_pcs_ctrl_out[1] & !rx_pcs_ctrl_out[0]) ? 1'b1:1'b0;
   //	 assign rx_syncout[lanenum] = rx_pcs_ctrl_out[9];
   // tx_control bus is 9 bits per lane

   genvar numlane;   
   generate
      for (numlane=0; numlane < LINKWIDTH; numlane=numlane+1) begin:ctrlsync
	 assign rx_ctrlout[numlane] = rx_pcs_ctrl_out[(numlane*10) +1] & !rx_pcs_ctrl_out[numlane*10]? 1'b1:1'b0;
	 assign rx_block_frame_lock[numlane] = rx_pcs_ctrl_out[(numlane*10)+9];	 
	 assign tx_control[((numlane*9)+8):(numlane*9)] = {7'b0, tx_ctrlin[numlane], ~tx_ctrlin[numlane]};
	 

	 // Synchronize the tx_digitalreset

	   alt_xcvr_resync #(
    	   .INIT_VALUE (1)
	     ) inst_reset_sync (
                 .clk    (tx_pld_clk       ),
                 .reset  (csr_tx_digitalreset[numlane]),
                 .d      (1'b0               ),
                 .q      (r_csr_tx_digitalreset[numlane]   )
             );




	 //pempty & empty is async so synchronize it with tx_pld_clk
	 altera_std_synchronizer #(
				   .depth (2)
				   ) stdsync_txpempty ( 
							.clk(tx_pld_clk),
							.din(tx_fifo_pempty_int[numlane]),
							.dout(tx_fifo_pempty[numlane]),
							.reset_n(~r_csr_tx_digitalreset[numlane])
							);

	 altera_std_synchronizer #(
				   .depth (2)
				   ) stdsync_txempty ( 
							.clk(tx_pld_clk),
							.din(tx_fifo_empty_int[numlane]),
							.dout(tx_fifo_empty[numlane]),
							.reset_n(~r_csr_tx_digitalreset[numlane])
							);


      end
   endgenerate
   

   
   
endmodule // bonded_lanes

