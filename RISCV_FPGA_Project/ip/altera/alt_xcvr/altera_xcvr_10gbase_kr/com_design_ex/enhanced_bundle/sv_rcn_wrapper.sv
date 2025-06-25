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


//============================================================================
// This confidential and proprietary software may be used only as authorized
// by a licensing agreement from ALTERA 
// copyright notice must be reproduced on all authorized copies.
//============================================================================
//

// Reconfig Wrapper contains these modules
//               -> 1G/10G/KR PHY  
//               -> reset controller
//               -> fPLL for XGMII clock generation
//               -> sv_rcn_bundle

`timescale 1 ps / 1 ps

import altera_xcvr_functions::*;

module sv_rcn_wrapper
  #(
  parameter CHANNELS                 = 2 ,     // Number of channels. This is passed in from design_example_wrapper.sv.
  parameter PMA_RD_AFTER_WRITE       = 0,      // Passed to sv_rcn_bundle: 1= test PMA writes (for debug only. this will cause a timeout during LT) 
  parameter SYS_CLK_IN_MHZ           = 100,    // system clock in Mhz
  parameter PLL_REF_CLK_IN_MHZ       = "322.265625 Mhz",
  parameter KR_PHY_SYNTH_AN          = 1,      // Synthesize/include the AN logic
  parameter KR_PHY_SYNTH_LT          = 1,      // Synthesize/include the LT logic
  parameter KR_PHY_SYNTH_FEC         = 0,      // Synthesize/include the FEC logic+10GSoft PCS
  parameter SYNTH_SEQ                = 1,      // Synthesize/include the Seqencer logic
  parameter KR_PHY_SYNTH_GIGE        = 0,      // Synthesize/include the GIGE logic 
  parameter SYNTH_GMII               = 0,      // Synthesize/include the GMII PCS
  parameter SYNTH_CL37ANEG           = 0,      // Synthesize/include CL37 AN in GMII PCS    
  parameter SYNTH_1588_1G            = 0,      // Synthesize/include the 1588 1G logic
  parameter SYNTH_1588_10G           = 0,      // Synthesize/include the 1588 10G logic
  parameter KR_PHY_LFT_R_MSB         = 6'd63,  // Link Fail Timer MSB for BASE-R PCS
  parameter KR_PHY_LFT_R_LSB         = 10'd0,  // Link Fail Timer lsb for BASE-R PCS
  parameter KR_PHY_LFT_X_MSB         = 6'd6,   // Link Fail Timer MSB for BASE-X PCS
  parameter KR_PHY_LFT_X_LSB         = 10'd0,  // Link Fail Timer lsb for BASE-X PCS

  parameter OPTIONAL_RXEQ            = 0,     // Enable RX equalization
  parameter RECONFIG_CONTROLLER_DFE  = 0,     // Turn on Reconfig controller DFE feature 
  parameter RECONFIG_CONTROLLER_CTLE = 0,     // Turn on Reconfig controller CTLE feature 
  parameter USER_RECONFIG_CONTROL    = 0,     // Turn on User Reconfig Access 
  parameter CAPABLE_FEC              = 0,     // Power up value of fec_ability
  parameter ENABLE_FEC               = 0,     // Power up value of fec_request
  parameter KR_PHY_BERWIDTH          = 8,      // Width (4-8) of the Bit Error counter
  parameter AN_TECH                  = 6'd5,   // Technology Ability Field.  6'd5 for 1G/10G, 6'd4 for 10G only.
  parameter PLL_TYPE_10G	         = "ATX",   // PLL type for 10G TX PLL.  ATX is recommended.
  parameter PLL_TYPE_1G				 = "CMU"   // PLL type for 1G TX PLL.
    ) (
   // clocks
  input wire                            pll_ref_clk_10g, 
  input wire                            pll_ref_clk_1g, 
  input wire                            xgmii_tx_clk,
  output wire                           xgmii_rx_clk,
  output wire [CHANNELS-1:0]            rx_recovered_clk,

   // resets
  input wire                            generic_pll_rst,     // reset the FPLL
  input wire                            reset_rc_bundle,     // reset the reconfiguration bundle
   // data
  input     wire [CHANNELS-1:0]         rx_serial_data,
  output wire [CHANNELS-1:0]            tx_serial_data,
  input     wire [CHANNELS*72-1:0]      xgmii_tx_dc,         // XGMII data to PMA.
  output wire [CHANNELS*72-1:0]         xgmii_rx_dc,         // XGMII data from PMA.
   // status
  output wire [CHANNELS-1:0]            tx_ready,
  output wire [CHANNELS-1:0]            rx_ready,
  output wire [CHANNELS-1:0]            pll_locked,
  output wire [CHANNELS-1:0]            tx_cal_busy,
  output wire [CHANNELS-1:0]            rx_cal_busy,
  input     wire [CHANNELS-1:0]         lcl_rf,                 // local device (MAC) Remote Fault = D13

  // GMII, XMGII signals
  output wire [CHANNELS-1:0]            tx_clkout_1g, 
  output wire [CHANNELS-1:0]            rx_clkout_1g, 
  input     wire [CHANNELS*8-1:0]       gmii_tx_data, 
  output wire [CHANNELS*8-1:0]          gmii_rx_data, 
  input     wire [CHANNELS-1:0]         gmii_tx_data_en, 
  input     wire [CHANNELS-1:0]         gmii_tx_err, 
  output wire [CHANNELS-1:0]            gmii_rx_err,
  output wire [CHANNELS-1:0]            gmii_rx_dv,

  // reconfig
  output wire [CHANNELS-1:0]            reconfig_busy, 
  input     wire [CHANNELS-1:0]         reconfig_req,                 // Only used if sequencer is disabled. Otherwise, tie off.
  input     wire [CHANNELS-1:0]         reconfig_rom1_rom0bar,    // Only used if sequencer is disabled. Otherwise, tie off.

  // avalon phy master for phy controls
  input     wire [11:0]                 phy_mgmt_address,
  input     wire                        phy_mgmt_clk,
  input     wire                        phy_mgmt_clk_reset,
  input     wire                        phy_mgmt_read,
  input     wire [31:0]                 phy_mgmt_writedata,
  input     wire                        phy_mgmt_write,
  output wire [31:0]                    phy_mgmt_readdata,
  output wire                           phy_mgmt_waitrequest
  
  // "backdoor" access
    ,input [7:0]                        avmm_address
    ,input                              avmm_read
    ,input                              avmm_write
    ,input [31:0]                       avmm_writedata
    ,output wire [31:0]                 avmm_readdata
    ,output wire                        avmm_waitrequest
);

//============================================================================
// --> wires
//============================================================================
   // rst controller output
   wire [CHANNELS-1:0]  rst_cntlr_tx_analogreset;
   wire [CHANNELS-1:0]  rst_cntlr_tx_digitalreset;
   wire [CHANNELS-1:0]  rst_cntlr_rx_analogreset;
   wire [CHANNELS-1:0]  rst_cntlr_rx_digitalreset;
   
   // reconfig wires for the reconfig blocks
   wire [CHANNELS*6-1:0] pcs_mode_no_seq;
   wire [CHANNELS*6-1:0] seq_pcs_mode;
   wire [CHANNELS*6-1:0] seq_pma_vod;
   wire [CHANNELS*5-1:0] seq_pma_postap1;
   wire [CHANNELS*4-1:0] seq_pma_pretap;
   wire [CHANNELS*3-1:0] tap_to_upd;
   wire [CHANNELS-1:0]   seq_start_rc;
   wire [CHANNELS-1:0]   lt_start_rc;
   wire [CHANNELS-1:0]   en_lcl_rxeq;
   wire [CHANNELS-1:0]   rxeq_done;
   wire [CHANNELS-1:0]   dfe_start_rc;
   wire [CHANNELS*2-1:0] dfe_mode;
   wire [CHANNELS-1:0]   ctle_start_rc;
   wire [CHANNELS*4-1:0] ctle_rc;
   wire [CHANNELS*2-1:0] ctle_mode;

   // reconfig controller wires
   localparam XCVR_TO_WIDTH   = altera_xcvr_functions::get_custom_reconfig_to_width("Stratix V","duplex",1,KR_PHY_SYNTH_GIGE+1,1);        
   localparam XCVR_FROM_WIDTH = altera_xcvr_functions::get_custom_reconfig_from_width("Stratix V","duplex",1,KR_PHY_SYNTH_GIGE+1,1);
   localparam WIDTH_CH        = altera_xcvr_functions::clogb2(CHANNELS) ; 
   wire [XCVR_TO_WIDTH*CHANNELS-1:0] reconfig_to_xcvr;
   wire [XCVR_FROM_WIDTH*CHANNELS-1:0] reconfig_from_xcvr;

   // for 156 PLL
   wire        pll156M_locked;
   wire        reconfig_mgmt_busy;
   
   // phy wires
   // TX PLL
   wire [CHANNELS-1:0] phy_pll_locked;
   wire [CHANNELS-1:0] baser_ll_mif_done;

   wire [CHANNELS-1:0] rx_data_ready;
   wire [CHANNELS-1:0] rx_block_lock;
   wire [CHANNELS-1:0] rx_hi_ber;
   wire [CHANNELS-1:0] rx_is_lockedtodata;
   
   wire [CHANNELS-1:0] seq_start_rc_to_bundle;
   wire [CHANNELS*6-1:0] seq_pcs_mode_to_bundle;

//============================================================================
// Instantiate <CHANNELS> number of PHYs.
//        This is a direct instantiation of the 10gbase-kr atom which can be used
//        for both 1G/10G and 10GBASE-KR
//============================================================================
wire [CHANNELS-1:0]     ch_en_avalon,ch_mgmt_waitrequest;
wire                    ch0_mgmt_waitrequest;
wire [CHANNELS*32-1:0]  ch_mgmt_readdata;


/// AVMM- EN mapping here  
genvar av_ch ;
  generate 
    for (av_ch=0; av_ch<CHANNELS; av_ch=av_ch+1) begin : AVMM_EN
        assign ch_en_avalon[av_ch] = (phy_mgmt_address[11:8] == av_ch); end
  endgenerate 


genvar kr_ch ;
  generate 
  for (kr_ch=0; kr_ch<CHANNELS; kr_ch=kr_ch+1) begin : INST_PHY
  altera_xcvr_10gbase_kr  #(
    .SYNTH_AN             (KR_PHY_SYNTH_AN),
    .SYNTH_LT             (KR_PHY_SYNTH_LT),
    .SYNTH_FEC            (KR_PHY_SYNTH_FEC),
    .SYNTH_SEQ            (SYNTH_SEQ),
    .SYNTH_GIGE           (KR_PHY_SYNTH_GIGE),
    .SYNTH_GMII           (KR_PHY_SYNTH_GIGE),
    .SYNTH_CL37ANEG       (SYNTH_CL37ANEG), 
    .SYNTH_1588_1G        (SYNTH_1588_1G),
    .SYNTH_SGMII          (1),
    .SYNTH_1588_10G       (SYNTH_1588_10G),
    .LFT_R_MSB            (KR_PHY_LFT_R_MSB),
    .LFT_R_LSB            (KR_PHY_LFT_R_LSB),
    .LFT_X_MSB            (KR_PHY_LFT_X_MSB),
    .LFT_X_LSB            (KR_PHY_LFT_X_LSB),
    .BERWIDTH             (KR_PHY_BERWIDTH),
    .AN_TECH              (AN_TECH),
    .PLL_CNT              (KR_PHY_SYNTH_GIGE ? 2: 1),
    .REF_CLK_FREQ_10G     (PLL_REF_CLK_IN_MHZ),
    .PLL_TYPE_10G         (PLL_TYPE_10G),
	.PLL_TYPE_1G		  (PLL_TYPE_1G),
    .OPTIONAL_RXEQ        (OPTIONAL_RXEQ),
    .CAPABLE_FEC          (CAPABLE_FEC),
    .ENABLE_FEC           (ENABLE_FEC)
  ) kr_phy_ch_inst (
      .pll_ref_clk_10g   (pll_ref_clk_10g),
      .pll_ref_clk_1g    (pll_ref_clk_1g),
      .xgmii_tx_clk      (xgmii_tx_clk),
      .xgmii_rx_clk      (xgmii_rx_clk),
      .rx_recovered_clk  (rx_recovered_clk[kr_ch]),
      .tx_coreclkin_1g   (tx_clkout_1g[kr_ch]),    // driven by tx_clkout_1g
      .rx_coreclkin_1g   (rx_clkout_1g[kr_ch]),    // driven by rx_clkout_1g
      .tx_clkout_1g      (tx_clkout_1g[kr_ch]),    
      .rx_clkout_1g      (rx_clkout_1g[kr_ch]),    
      .calc_clk_1g       (phy_mgmt_clk),
      .gmii_tx_d         (gmii_tx_data[kr_ch*8+:8]),    
      .gmii_rx_d         (gmii_rx_data[kr_ch*8+:8]),    
      .gmii_tx_en        (gmii_tx_data_en[kr_ch]), 
      .gmii_tx_err       (gmii_tx_err[kr_ch]),     
      .gmii_rx_err       (gmii_rx_err[kr_ch]),     
      .gmii_rx_dv        (gmii_rx_dv[kr_ch]),      
      .mode_1g_10gbar    (reconfig_rom1_rom0bar[kr_ch]),  
      .rx_clkslip        (1'b0           ), 
      .pll_powerdown_10g (generic_pll_rst), // to enable pll merging
      .pll_powerdown_1g  (generic_pll_rst), // to enable pll merging
      .tx_analogreset    (rst_cntlr_tx_analogreset[kr_ch]),
      .tx_digitalreset   (rst_cntlr_tx_digitalreset[kr_ch]),
      .rx_analogreset    (rst_cntlr_rx_analogreset[kr_ch]),
      .rx_digitalreset   (rst_cntlr_rx_digitalreset[kr_ch]),
      .usr_an_lt_reset   (1'b0),
      .usr_seq_reset     (1'b0),
      .usr_fec_reset     (1'b0),
      .usr_soft_10g_pcs_reset(1'b0),

      .mgmt_clk          (phy_mgmt_clk),
      .mgmt_clk_reset    (phy_mgmt_clk_reset),
      .mgmt_address      (phy_mgmt_address[7:0]),
      .mgmt_read         (ch_en_avalon[kr_ch] & phy_mgmt_read),
      .mgmt_readdata     (ch_mgmt_readdata[kr_ch*32+:32]),
      .mgmt_writedata    (phy_mgmt_writedata),
      .mgmt_write        (ch_en_avalon[kr_ch] & phy_mgmt_write),
      .mgmt_waitrequest  (ch_mgmt_waitrequest[kr_ch]),
 
      .reconfig_from_xcvr(reconfig_from_xcvr[XCVR_FROM_WIDTH*kr_ch+:XCVR_FROM_WIDTH]),
      .reconfig_to_xcvr  (reconfig_to_xcvr[XCVR_TO_WIDTH*kr_ch+:XCVR_TO_WIDTH]),

      .rc_busy           (reconfig_busy[kr_ch]),   
      .lt_start_rc       (lt_start_rc[kr_ch]),
      .main_rc           (seq_pma_vod[kr_ch*6+:6]),
      .post_rc           (seq_pma_postap1[kr_ch*5+:5]),
      .pre_rc            (seq_pma_pretap[kr_ch*4+:4]),
      .tap_to_upd        (tap_to_upd[kr_ch*3+:3]),
      .en_lcl_rxeq       (en_lcl_rxeq),
      .rxeq_done         (1'b1),
      .seq_start_rc      (seq_start_rc[kr_ch]),
      .dfe_start_rc      (dfe_start_rc[kr_ch]),
      .dfe_mode          (dfe_mode[kr_ch*2+:2]),
      .ctle_start_rc     (ctle_start_rc[kr_ch]),
      .ctle_rc           (ctle_rc[kr_ch*4+:4]),
      .ctle_mode         (ctle_mode[kr_ch*2+:2]),
      .pcs_mode_rc       (seq_pcs_mode[kr_ch*6+:6]),
      .lcl_rf            (lcl_rf[kr_ch]),
      .tm_in_trigger     (4'd0),
      .tm_out_trigger    ( ),

      .xgmii_tx_dc       (xgmii_tx_dc[kr_ch*72+:72]),
      .xgmii_rx_dc       (xgmii_rx_dc[kr_ch*72+:72]),
      .pll_locked        (phy_pll_locked[kr_ch]),
      .rx_is_lockedtodata(rx_is_lockedtodata[kr_ch]),
      .tx_cal_busy       (tx_cal_busy[kr_ch]),
      .rx_cal_busy       (rx_cal_busy[kr_ch]),
      .rx_data_ready     (rx_data_ready[kr_ch]),
      .rx_block_lock     (rx_block_lock[kr_ch]),
      .rx_hi_ber         (rx_hi_ber[kr_ch]),
      .tx_serial_data    (tx_serial_data[kr_ch]),
      .rx_serial_data    (rx_serial_data[kr_ch]),
      
        // Daisy chain interface not used.
      .dmi_mode_en       (1'b0),      
      .dmi_frame_lock    (1'b0),      
      .dmi_rmt_rx_ready  (1'b0), 
      .dmi_lcl_coefl     (6'd0),      
      .dmi_lcl_coefh     (2'd0),      
      .dmi_lcl_upd_new   (1'b0),  
      .dmi_rx_trained    (1'b0),      
      .dmo_frame_lock    (/*unused*/),      
      .dmo_rmt_rx_ready  (/*unused*/), 
      .dmo_lcl_coefl     (/*unused*/),      
      .dmo_lcl_coefh     (/*unused*/),      
      .dmo_lcl_upd_new   (/*unused*/),  
      .dmo_rx_trained    (/*unused*/),

        // Microprocessor interface not used
      .upi_mode_en       (1'b0),     
      .upi_adj           (2'b00),     
      .upi_inc           (1'b0),     
      .upi_dec           (1'b0),     
      .upi_pre           (1'b0),     
      .upi_init          (1'b0),     
      .upi_st_bert       (1'b0),     
      .upi_train_err     (1'b0),     
      .upi_lock_err      (1'b0),     
      .upi_rx_trained    (1'b0),    
      .upo_enable        (/* unused */),     
      .upo_frame_lock    (/* unused */),     
      .upo_cm_done       (/* unused */),     
      .upo_bert_done     (/* unused */),     
      .upo_ber_cnt       (/* unused */),     
      .upo_ber_max       (/* unused */),     
      .upo_coef_max      (/* unused */)
      )  ;

    end
    endgenerate 


// MUX to select appropriate RDDATA and WAITREQ 
  assign phy_mgmt_readdata    =  ch_mgmt_readdata[phy_mgmt_address[11:8]*32+:32] ;
  assign phy_mgmt_waitrequest =  ch_mgmt_waitrequest[phy_mgmt_address[11:8]];
  
// --> End Phy

//============================================================================
// --> Instantiate reset controller for PHY
//============================================================================
genvar rst_ch ;
  generate 
  for (rst_ch=0; rst_ch<CHANNELS; rst_ch=rst_ch+1) begin : INST_RESET_CTR
  altera_xcvr_reset_control #( 
    .CHANNELS(1),
    .PLLS(1),
    .TX_PLL_ENABLE(1),
    .TX_ENABLE(1),
    .RX_ENABLE(1),
    .SYS_CLK_IN_MHZ(SYS_CLK_IN_MHZ)
    ) altera_xcvr_reset_control_inst (
    .clock                   (phy_mgmt_clk),
    .reset                   (phy_mgmt_clk_reset | baser_ll_mif_done[rst_ch]),
    .pll_powerdown           (/*UNUSED*/),
    .tx_analogreset          (rst_cntlr_tx_analogreset[rst_ch]),
    .tx_digitalreset         (rst_cntlr_tx_digitalreset[rst_ch]),
    .rx_analogreset          (rst_cntlr_rx_analogreset[rst_ch]),
    .rx_digitalreset         (rst_cntlr_rx_digitalreset[rst_ch]),
    .tx_ready                (tx_ready[rst_ch]),
    .rx_ready                (rx_ready[rst_ch]),
    .tx_digitalreset_or      (1'b0),  // reset request for tx_digitalreset
    .rx_digitalreset_or      (1'b0),  // reset request for rx_digitalreset
    .pll_locked              (phy_pll_locked[rst_ch]),
    .pll_select              (1'b0),
    .tx_cal_busy             (tx_cal_busy[rst_ch]),
    .rx_cal_busy             (rx_cal_busy[rst_ch]),
    .rx_is_lockedtodata      (rx_is_lockedtodata[rst_ch]),
    .rx_manual               (1'b1),  // 0 = Automatically restart rx_digitalreset
                                                // when rx_is_lockedtodata deasserts
                                                // 1 = Do nothing on rx_is_lockedtodata deassert
    .tx_manual               (1'b1)   // 0 = Automatically restart tx_digitalreset
                                                // when pll_locked deasserts.
                                                // 1 = Do nothing when pll_locked deasserts
  );
  end
  endgenerate 
  
// --> End reset controller

//============================================================================
// --> Instantiate fPLL that generates 156.25 XGMII clock from 10G refclk
//============================================================================
   wire            fboutclk1;

  generic_pll  #(
    .reference_clock_frequency  (PLL_REF_CLK_IN_MHZ),
    .output_clock_frequency     ("156.25 MHz"  )
   ) altera_pll_156M  (
    .outclk                (xgmii_rx_clk),
    .fboutclk                 (fboutclk1),
    .rst                     (generic_pll_rst),
   .refclk              (pll_ref_clk_10g),
    .fbclk                (fboutclk1),
    .locked                (pll156M_locked),
    .writerefclkdata     (/*unused*/  ),
    .writeoutclkdata     (/*unused*/  ),
    .writephaseshiftdata (/*unused*/  ),
    .writedutycycledata  (/*unused*/  ),
    .readrefclkdata      (/*unused*/  ),
    .readoutclkdata      (/*unused*/  ),
    .readphaseshiftdata  (/*unused*/  ),
    .readdutycycledata   (/*unused*/  )
    );

   // TX PLL | FPLL 
   assign pll_locked     = phy_pll_locked && {(CHANNELS){pll156M_locked}};
    
// --> End fPLL

//================================================================================
// Instantiate sv_rcn_bundle (contains: reconfig controller, mgmt_master and MIFs)
//================================================================================

genvar phy_ch ;

generate 
  for (phy_ch=0; phy_ch<CHANNELS; phy_ch=phy_ch+1) begin : CONCAT_NO_SEQ 
  assign pcs_mode_no_seq[(phy_ch+1)*6-1:phy_ch*6] = {2'b00,reconfig_rom1_rom0bar[phy_ch],~reconfig_rom1_rom0bar[phy_ch],2'b00};
  end	  
endgenerate

// select request from Sequencer or test harness depending upon SYNTH_SEQ
generate
    if (SYNTH_SEQ) begin: REQ_SEQ
        assign seq_start_rc_to_bundle = seq_start_rc ; 
        assign seq_pcs_mode_to_bundle = seq_pcs_mode ; end
    else begin :     REQ_TH
        assign seq_start_rc_to_bundle = reconfig_req ; 
        assign seq_pcs_mode_to_bundle = pcs_mode_no_seq; end
endgenerate

 sv_rcn_bundle #(
      .PMA_RD_AFTER_WRITE               (PMA_RD_AFTER_WRITE),
      .PLLS                             (KR_PHY_SYNTH_GIGE ? CHANNELS*2 : CHANNELS),
      .CHANNELS                         (CHANNELS),
      .SYNTH_1588_1G                    (SYNTH_1588_1G),
      .SYNTH_1588_10G                   (SYNTH_1588_10G),
      .KR_PHY_SYNTH_AN                  (KR_PHY_SYNTH_AN),
      .KR_PHY_SYNTH_LT                  (KR_PHY_SYNTH_LT),
      .KR_PHY_SYNTH_DFE                 (RECONFIG_CONTROLLER_DFE),
      .KR_PHY_SYNTH_CTLE                (RECONFIG_CONTROLLER_CTLE),
      .USER_RECONFIG_CONTROL            (USER_RECONFIG_CONTROL),
      .USER_RCFG_PRIORITY               (1),
      .KR_PHY_SYNTH_GIGE                (KR_PHY_SYNTH_GIGE),
      .ENA_RECONFIG_CONTROLLER_DFE_RCFG (RECONFIG_CONTROLLER_DFE),
      .ENA_RECONFIG_CONTROLLER_CTLE_RCFG(RECONFIG_CONTROLLER_CTLE),
      .DISABLE_CTLE_DFE_BEFORE_AN       (2'b01)
 ) sv_rc_bundle_inst (
      .reconfig_clk        (phy_mgmt_clk),
      .reconfig_reset      (phy_mgmt_clk_reset | reset_rc_bundle),
      
      .reconfig_to_xcvr    (reconfig_to_xcvr),
      .reconfig_from_xcvr  (reconfig_from_xcvr),
      .reconfig_mgmt_busy  (reconfig_mgmt_busy),

      .seq_pcs_mode        (seq_pcs_mode_to_bundle), 
      .seq_pma_vod         (seq_pma_vod),
      .seq_pma_postap1     (seq_pma_postap1),
      .seq_pma_pretap      (seq_pma_pretap),
      .seq_start_rc        (seq_start_rc_to_bundle),  
      .lt_start_rc         (lt_start_rc),
      .tap_to_upd          (tap_to_upd),
      .hdsk_rc_busy        (reconfig_busy), 
      .baser_ll_mif_done   (baser_ll_mif_done),
      
      .dfe_start_rc        (dfe_start_rc),
      .dfe_mode            (dfe_mode),
      .ctle_start_rc       (ctle_start_rc),
      .ctle_rc             (ctle_rc),
      .ctle_mode           (ctle_mode),
      
      .avmm_address        (avmm_address),
      .avmm_read           (avmm_read),
      .avmm_write          (avmm_write),
      .avmm_writedata      (avmm_writedata),
      .avmm_readdata       (avmm_readdata),
      .avmm_waitrequest    (avmm_waitrequest)
      );
   
endmodule // sv_rcn_wrapper
