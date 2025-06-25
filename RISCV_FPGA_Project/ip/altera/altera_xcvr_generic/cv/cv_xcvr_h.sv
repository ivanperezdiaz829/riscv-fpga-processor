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


// (C) 2001-2011 Altera Corporation. All rights reserved.
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


//
// CV-generation transceiver definitions and functions
//
// $Header$
//
// PACKAGE DECLARATION
package cv_xcvr_h;

  // SV Reconfiguration address definitions

   // PMA, PCS Base address
   localparam RECONFIG_PMA_CH0_BASE = 11'h000;
   localparam RECONFIG_PCSPMAIF_CH0_BASE = 11'h064;
   localparam RECONFIG_PCS8G_CH0_BASE = 11'h096;
   localparam RECONFIG_G3PCS_CH0_BASE = 11'h0FA;
   localparam RECONFIG_PCS10G_CH0_BASE = 11'h12C;
   localparam RECONFIG_PCSPLDIF_CH0_BASE = 11'h1C2;

   localparam RECONFIG_PMA_CH1_BASE = 11'h258;
   localparam RECONFIG_PCSPMAIF_CH1_BASE = RECONFIG_PMA_CH1_BASE + RECONFIG_PCSPMAIF_CH0_BASE;
   localparam RECONFIG_PCS8G_CH1_BASE = RECONFIG_PMA_CH1_BASE + RECONFIG_PCS8G_CH0_BASE;
   localparam RECONFIG_G3PCS_CH1_BASE = RECONFIG_PMA_CH1_BASE + RECONFIG_G3PCS_CH0_BASE;
   localparam RECONFIG_PCS10G_CH1_BASE = RECONFIG_PMA_CH1_BASE + RECONFIG_PCS10G_CH0_BASE;
   localparam RECONFIG_PCSPLDIF_CH1_BASE = RECONFIG_PMA_CH1_BASE + RECONFIG_PCSPLDIF_CH0_BASE;

   localparam RECONFIG_PMA_CH2_BASE = 11'h4B0;
   localparam RECONFIG_PCSPMAIF_CH2_BASE = RECONFIG_PMA_CH2_BASE + RECONFIG_PCSPMAIF_CH0_BASE;
   localparam RECONFIG_PCS8G_CH2_BASE = RECONFIG_PMA_CH2_BASE + RECONFIG_PCS8G_CH0_BASE;
   localparam RECONFIG_G3PCS_CH2_BASE = RECONFIG_PMA_CH2_BASE + RECONFIG_G3PCS_CH0_BASE;
   localparam RECONFIG_PCS10G_CH2_BASE = RECONFIG_PMA_CH2_BASE + RECONFIG_PCS10G_CH0_BASE;
   localparam RECONFIG_PCSPLDIF_CH2_BASE = RECONFIG_PMA_CH2_BASE + RECONFIG_PCSPLDIF_CH0_BASE;


   // PMA RECONFIG Address

   localparam RECONFIG_PMA_CH0_VOD = RECONFIG_PMA_CH0_BASE + 11'h004;
   localparam RECONFIG_PMA_CH0_POSTTAP1 = RECONFIG_PMA_CH0_BASE + 11'h003;
   localparam RECONFIG_PMA_CH0_RX_EQA = RECONFIG_PMA_CH0_BASE + 11'h012;		
   localparam RECONFIG_PMA_CH0_RX_EQV = RECONFIG_PMA_CH0_BASE + 11'h013;		
   localparam RECONFIG_PMA_CH0_RX_EQDCGAIN = RECONFIG_PMA_CH0_BASE + 11'h013;

   localparam RECONFIG_PMA_CH0_RCRU_RLBK = RECONFIG_PMA_CH0_BASE + 11'h010;
   localparam RECONFIG_PMA_CH0_RREVLB_SW = RECONFIG_PMA_CH0_BASE + 11'h012;
   localparam RECONFIG_PMA_CH0_RRX_DLPBK = RECONFIG_PMA_CH0_BASE + 11'h013;

   localparam RECONFIG_PMA_CH0_RADCE_ADAPT = RECONFIG_PMA_CH0_BASE + 11'h033;
   localparam RECONFIG_PMA_CH0_RPCIE_EQZ = RECONFIG_PMA_CH0_BASE + 11'h01b;
   localparam RECONFIG_PMA_CH0_RXBYPASSEQZ123 = RECONFIG_PMA_CH0_BASE + 11'h012;
   localparam RECONFIG_PMA_CH0_RXSELHALFBW = RECONFIG_PMA_CH0_BASE + 11'h01b;

   localparam RECONFIG_PMA_CH0_DFE8  = RECONFIG_PMA_CH0_BASE + 11'h00e;
   localparam RECONFIG_PMA_CH0_DFE11 = RECONFIG_PMA_CH0_BASE + 11'h011;
   localparam RECONFIG_PMA_CH0_DFE12 = RECONFIG_PMA_CH0_BASE + 11'h012;
   localparam RECONFIG_PMA_CH0_DFE13 = RECONFIG_PMA_CH0_BASE + 11'h013;
   localparam RECONFIG_PMA_CH0_DFE14 = RECONFIG_PMA_CH0_BASE + 11'h014;
   localparam RECONFIG_PMA_CH0_DFE15 = RECONFIG_PMA_CH0_BASE + 11'h015;
   localparam RECONFIG_PMA_CH0_DFE21 = RECONFIG_PMA_CH0_BASE + 11'h01b;

   localparam RECONFIG_PMA_CH0_EYMON0C = RECONFIG_PMA_CH0_BASE + 11'h0C;
   localparam RECONFIG_PMA_CH0_EYMON16 = RECONFIG_PMA_CH0_BASE + 11'h016;
   localparam RECONFIG_PMA_CH0_EYMON17 = RECONFIG_PMA_CH0_BASE + 11'h017;

   // LC Tuning IP Addresses
   localparam RECONFIG_PMA_PCH_RCMU_CTL0            = RECONFIG_PMA_CH1_BASE + 11'h041;
   localparam RECONFIG_PMA_PCH_RCMU_CTL0_OFST       = 3;
   localparam RECONFIG_PMA_PCH_RCMU_CTL0_MASK       = 16'h0008;
   localparam RECONFIG_PMA_PCH_RCMU_LVCO_SEL        = RECONFIG_PMA_CH1_BASE + 11'h041;
   localparam RECONFIG_PMA_PCH_RCMU_LVCO_SEL_OFST   = 6;
   localparam RECONFIG_PMA_PCH_RCMU_LVCO_SEL_MASK   = 16'h0040;
   localparam RECONFIG_PMA_PCH_RCMU_VREG1_SEL       = RECONFIG_PMA_CH2_BASE + 11'h041;
   localparam RECONFIG_PMA_PCH_RCMU_VREG1_SEL_OFST  = 9;
   localparam RECONFIG_PMA_PCH_RCMU_VREG1_SEL_MASK  = 16'h0E00;

   //DCD
   localparam RECONFIG_PMA_CH0_DCD_RSER_CLK_MON    = RECONFIG_PMA_CH0_BASE + 12'h001; // Forced data (test pattern)
   localparam RECONFIG_PMA_CH0_DCD_RCRU_EYE        = RECONFIG_PMA_CH0_BASE + 12'h00c; // EYE mon / CDR data
   localparam RECONFIG_PMA_CH0_DCD_RCRU_RCLK_MON   = RECONFIG_PMA_CH0_BASE + 12'h010; // VCO data select
   localparam RECONFIG_PMA_CH0_DCD_REYE_MON        = RECONFIG_PMA_CH0_BASE + 12'h016; // eye monitor register
   localparam RECONFIG_PMA_CH0_DCD_DC_TUNE         = RECONFIG_PMA_CH0_BASE + 12'h040; // DCD calibration

   // register bits offsets
   localparam RSER_CLK_MON_OFST    = 10; // Forced data (test pattern)
   localparam RCRU_EYE_OFST        = 5;  // EYE mon / CDR data
   localparam RCRU_RCLK_MON_OFST   = 3;  // VCO data select
   localparam REYE_MON_5_OFST      = 8;  // eye monitor msb 
   localparam REYE_MON_0_OFST      = 3;  // eye monitor lsb
   localparam RSER_DC_TUNE_2_OFST  = 15; // DCD calibration -msb
   localparam RSER_DC_TUNE_1_OFST  = 14;
   localparam RSER_DC_TUNE_0_OFST  = 13; // DCD calibration -lsb
   localparam REYE_ISEL_2          = 2;  // ISEL msb
   localparam REYE_ISEL_1          = 1;  
   localparam REYE_ISEL_0          = 0;  // ISEL lsb
   localparam REYE_PDB             = 11; // power enable

   //MIF RMW offsets and masks
   localparam RECONFIG_PMA_CGB_REG_OFST     = 12'h000; // contains rcgb_clk_sel bits
   localparam RECONFIG_PMA_BBPD_REG_OFST    = 12'h00d; // contains BBPD control
   localparam RECONFIG_PMA_TB_REG_OFST      = 12'h00e; // contains Testbus control control
   localparam RECONFIG_PMA_PCIEMD_REG_OFST  = 12'h010; // contains pcie_mode_sel bit
   localparam RECONFIG_PMA_DFE0_REG_OFST    = 12'h011; // contains dfe controls
   localparam RECONFIG_PMA_DFE1_REG_OFST    = 12'h012; // contains dfe controls
   localparam RECONFIG_PMA_DFE2_REG_OFST    = 12'h013; // contains dfe controls
   localparam RECONFIG_PMA_DFE3_REG_OFST    = 12'h014; // contains dfe controls
   localparam RECONFIG_PMA_DFE4_REG_OFST    = 12'h015; // contains dfe controls
   localparam RECONFIG_PMA_RREF_REG_OFST    = 12'h017; // contains rref_sel and OC cal bits
   localparam RECONFIG_PMA_OC_REG_OFST      = 12'h019; // allow OC cal to take effect
   localparam RECONFIG_PMA_RXBUF_REG_OFST   = 12'h01a; // allows rx buffer adjustment
   localparam RECONFIG_PMA_RXDATAO_REG_OFST = 12'h030; // contains rx_data_out_sel
   localparam RECONFIG_PMA_REFIQ_REG_OFST   = 12'h03a; // contains pma_iq_clk_sel bits
   localparam RECONFIG_PMA_DCD_REG_OFST     = 12'h040; // DCD control adjustment
  

   localparam RECONFIG_PMA_CGB_REG_MASK     = 16'h01fe; // contains rcgb_clk_sel bits
   localparam RECONFIG_PMA_BBPD_REG_MASK    = 16'hffff; // contains BBPD controla
   localparam RECONFIG_PMA_TB_REG_MASK      = 16'h0004; // enables testbus toggling
   localparam RECONFIG_PMA_PCIEMD_REG_MASK  = 16'h0040; // contains pcie_mode_sel bit
   localparam RECONFIG_PMA_DFE0_REG_MASK    = 16'hffff; // contains dfe controls
   localparam RECONFIG_PMA_DFE1_REG_MASK    = 16'hffff; // contains dfe controls
   localparam RECONFIG_PMA_DFE2_REG_MASK    = 16'hffff; // contains dfe controls
   localparam RECONFIG_PMA_DFE3_REG_MASK    = 16'hffff; // contains dfe controls
   localparam RECONFIG_PMA_DFE4_REG_MASK    = 16'hffff; // contains dfe controls
   localparam RECONFIG_PMA_RREF_REG_MASK    = 16'h8001; // contains rref_sel and OC cal bits
   localparam RECONFIG_PMA_OC_REG_MASK      = 16'h0200; // allow OC cal to take effect
   localparam RECONFIG_PMA_RXBUF_REG_MASK   = 16'h01fe; // allows rx buffer adjustment
   localparam RECONFIG_PMA_RXDATAO_REG_MASK = 16'hcfff;  // contains rx_data_out_sel
   localparam RECONFIG_PMA_REFIQ_REG_MASK   = 16'h07f8; // contains pma_iq_clk_sel bits
   localparam RECONFIG_PMA_DCD_REG_MASK     = 16'h0007; // DCD control adjustment


//****************************************************************************
//************************ Local channel registers ***************************

  // Register address offset to gain access to the soft reconfig registers.
  // This value must be added to the register addresses listed below.
  localparam SV_XR_LOCAL_OFFSET  = 12'h800;

  //****************************
  // Relative register addresses
  localparam SV_XR_ADDR_DUMMY   = 4'd0; // Dummy register for read/write testing
  localparam SV_XR_ADDR_ADCE    = 4'd1; // internal register for ADCE capture and standby
  localparam SV_XR_ADDR_OC      = 4'd2; // internal register for hard OC cal enable
  localparam SV_XR_ADDR_PRBS    = 4'd3; // internal register for PRBS control and status
  localparam SV_XR_ADDR_DCD     = 4'd4; // internal register for DCD control and status
  localparam SV_XR_ADDR_DCD_RES = 4'd5; // internal register for DCD results
  localparam SV_XR_ADDR_SLPBK   = 4'd6; // internal register for serial loopback control
  localparam SV_XR_ADDR_STATUS  = 4'd7; // internal register for channel status
  localparam SV_XR_ADDR_ID      = 4'd8; // internal register for channel ID
  localparam SV_XR_ADDR_REQUEST = 4'd9; // internal register for channel services request
  localparam SV_XR_ADDR_RSTCTL  = 4'd10; // internal register for channel reset control and override

  //****************************
  // Absolute register addresses
  localparam SV_XR_ABS_ADDR_DUMMY   = SV_XR_LOCAL_OFFSET + SV_XR_ADDR_DUMMY;
  localparam SV_XR_ABS_ADDR_ADCE    = SV_XR_LOCAL_OFFSET + SV_XR_ADDR_ADCE;
  localparam SV_XR_ABS_ADDR_OC      = SV_XR_LOCAL_OFFSET + SV_XR_ADDR_OC;
  localparam SV_XR_ABS_ADDR_PRBS    = SV_XR_LOCAL_OFFSET + SV_XR_ADDR_PRBS;
  localparam SV_XR_ABS_ADDR_DCD     = SV_XR_LOCAL_OFFSET + SV_XR_ADDR_DCD;
  localparam SV_XR_ABS_ADDR_DCD_RES = SV_XR_LOCAL_OFFSET + SV_XR_ADDR_DCD_RES;
  localparam SV_XR_ABS_ADDR_SLPBK   = SV_XR_LOCAL_OFFSET + SV_XR_ADDR_SLPBK;
  localparam SV_XR_ABS_ADDR_STATUS  = SV_XR_LOCAL_OFFSET + SV_XR_ADDR_STATUS;
  localparam SV_XR_ABS_ADDR_ID      = SV_XR_LOCAL_OFFSET + SV_XR_ADDR_ID;
  localparam SV_XR_ABS_ADDR_REQUEST = SV_XR_LOCAL_OFFSET + SV_XR_ADDR_REQUEST;
  localparam SV_XR_ABS_ADDR_RSTCTL  = SV_XR_LOCAL_OFFSET + SV_XR_ADDR_RSTCTL;

  //*****************************
  // Bit masks for DUMMY register
  localparam SV_XR_DUMMY_DUMMY_OFST   = 0;
  localparam SV_XR_DUMMY_DUMMY_LEN    = 1;
  localparam SV_XR_DUMMY_DUMMY_MASK   = 16'h0001;

  //****************************
  // Bit masks for ADCE register
  localparam SV_XR_ADCE_CAPTURE_OFST  = 0;
  localparam SV_XR_ADCE_STANDBY_OFST  = 1;
  localparam SV_XR_ADCE_DONE_OFST     = 2;
  localparam SV_XR_ADCE_UNUSED_OFST   = 3;

  localparam SV_XR_ADCE_CAPTURE_LEN   = 1;
  localparam SV_XR_ADCE_STANDBY_LEN   = 1;
  localparam SV_XR_ADCE_DONE_LEN      = 1;
  localparam SV_XR_ADCE_UNUSED_LEN    = 13;

  localparam SV_XR_ADCE_CAPTURE_MASK  = 16'h0001; // bitfield position of ADCE capture, within ADCE reg
  localparam SV_XR_ADCE_STANDBY_MASK  = 16'h0002; // bitfield position of ADCE standby, within ADCE reg
  localparam SV_XR_ADCE_DONE_MASK     = 16'h0004; // bitfield position of ADCE adapt done, within ADCE reg

  //************************************
  // Bit masks for HARDOC_CALEN register
  localparam SV_XR_OC_CALEN_OFST    = 0;
  localparam SV_XR_OC_CALDONE_OFST  = 1;
  localparam SV_XR_OC_UNUSED_OFST   = 2;

  localparam SV_XR_OC_CALEN_LEN     = 1;
  localparam SV_XR_OC_CALDONE_LEN   = 1;
  localparam SV_XR_OC_UNUSED_LEN    = 14;

  localparam SV_XR_OC_CALEN_MASK    = 16'h0001;
  localparam SV_XR_OC_CALDONE_MASK  = 16'h0002;

  //****************************
  // Bit masks for PRBS register
  localparam SV_XR_PRBS_CLR_OFST      = 0;
  localparam SV_XR_PRBS_8G_ERR_OFST   = 1;
  localparam SV_XR_PRBS_8G_DONE_OFST  = 2;
  localparam SV_XR_PRBS_10G_ERR_OFST  = 3;
  localparam SV_XR_PRBS_10G_DONE_OFST = 4;
  localparam SV_XR_PRBS_UNUSED_OFST   = 5;

  localparam SV_XR_PRBS_CLR_LEN       = 1;
  localparam SV_XR_PRBS_8G_ERR_LEN    = 1;
  localparam SV_XR_PRBS_8G_DONE_LEN   = 1;
  localparam SV_XR_PRBS_10G_ERR_LEN   = 1;
  localparam SV_XR_PRBS_10G_DONE_LEN  = 1;
  localparam SV_XR_PRBS_UNUSED_LEN    = 11;

  localparam SV_XR_PRBS_CLR_MASK      = 16'h0001;
  localparam SV_XR_PRBS_8G_ERR_MASK   = 16'h0002;
  localparam SV_XR_PRBS_8G_DONE_MASK  = 16'h0004;
  localparam SV_XR_PRBS_10G_ERR_MASK  = 16'h0008;
  localparam SV_XR_PRBS_10G_DONE_MASK = 16'h0010;

  //***************************
  // Bit masks for DCD register
  localparam SV_XR_DCD_REQ_OFST     = 0;
  localparam SV_XR_DCD_ACK_OFST     = 1;
  localparam SV_XR_DCD_UNUSED_OFST  = 2;

  localparam SV_XR_DCD_REQ_LEN      = 1;
  localparam SV_XR_DCD_ACK_LEN      = 1;
  localparam SV_XR_DCD_UNUSED_LEN   = 14;

  localparam SV_XR_DCD_REQ_MASK  = 16'h0001;
  localparam SV_XR_DCD_ACK_MASK  = 16'h0002;

  //*******************************
  // Bit masks for DCD_RES register
  localparam SV_XR_DCD_RES_A_OFST  = 0;
  localparam SV_XR_DCD_RES_B_OFST  = 8;

  localparam SV_XR_DCD_RES_A_LEN   = 8;
  localparam SV_XR_DCD_RES_B_LEN   = 8;

  localparam SV_XR_DCD_RES_A_MASK  = 16'h00ff;
  localparam SV_XR_DCD_RES_B_MASK  = 16'hff00;

  //*****************************
  // Bit masks for SLPBK register
  localparam SV_XR_SLPBK_SLPBKEN_OFST = 0;
  localparam SV_XR_SLPBK_UNUSED_OFST  = 1;

  localparam SV_XR_SLPBK_SLPBKEN_LEN  = 1;
  localparam SV_XR_SLPBK_UNUSED_LEN   = 15;

  localparam SV_XR_SLPBK_SLPBKEN_MASK = 16'h0001;

  //******************************
  // Bit masks for STATUS register
  localparam SV_XR_STATUS_TX_DIGITAL_RESET_OFST  = 0;  // Valid only for channel interfaces
  localparam SV_XR_STATUS_RX_DIGITAL_RESET_OFST  = 1;  // Valid only for channel interfaces
  localparam SV_XR_STATUS_PLL_LOCKED_OFST        = 2;  // Valid only for PLL interfaces
  localparam SV_XR_STATUS_PLL_LOCKED_FLAG_OFST   = 3;  // Valid only for PLL interfaces
  localparam SV_XR_STATUS_UNUSED_OFST            = 4;  // Valid only for PLL interfaces

  localparam SV_XR_STATUS_TX_DIGITAL_RESET_LEN   = 1;
  localparam SV_XR_STATUS_RX_DIGITAL_RESET_LEN   = 1;
  localparam SV_XR_STATUS_PLL_LOCKED_LEN         = 1;
  localparam SV_XR_STATUS_PLL_LOCKED_FLAG_LEN    = 1;
  localparam SV_XR_STATUS_UNUSED_LEN             = 12;

  localparam SV_XR_STATUS_TX_DIGITAL_RESET_MASK  = 16'h0001;
  localparam SV_XR_STATUS_RX_DIGITAL_RESET_MASK  = 16'h0002;
  localparam SV_XR_STATUS_PLL_LOCKED_MASK        = 16'h0004;
  localparam SV_XR_STATUS_PLL_LOCKED_FLAG_MASK   = 16'h0008;

  //**************************
  // Bit masks for ID register
  localparam SV_XR_ID_TX_CHANNEL_OFST  = 0;
  localparam SV_XR_ID_RX_CHANNEL_OFST  = 1;
  localparam SV_XR_ID_ATT_CHANNEL_OFST = 2;
  localparam SV_XR_ID_PLL_TYPE_OFST    = 3;
  localparam SV_XR_ID_UNUSED_OFST      = 5;

  localparam SV_XR_ID_TX_CHANNEL_LEN   = 1;
  localparam SV_XR_ID_RX_CHANNEL_LEN   = 1;
  localparam SV_XR_ID_ATT_CHANNEL_LEN  = 1;
  localparam SV_XR_ID_PLL_TYPE_LEN     = 2;
  localparam SV_XR_ID_UNUSED_LEN       = 11;

  localparam SV_XR_ID_TX_CHANNEL_MASK  = 16'h0001;
  localparam SV_XR_ID_RX_CHANNEL_MASK  = 16'h0002;
  localparam SV_XR_ID_ATT_CHANNEL_MASK = 16'h0004;
  localparam SV_XR_ID_PLL_TYPE_MASK    = 16'h0018;

  // Parameters for PLL Type field
  localparam SV_XR_ID_PLL_TYPE_NONE     = 0;
  localparam SV_XR_ID_PLL_TYPE_CMU      = 1;
  localparam SV_XR_ID_PLL_TYPE_LC       = 2;
  localparam SV_XR_ID_PLL_TYPE_FPLL     = 3;

  //*******************************
  // Bit masks for REQUEST register
  localparam SV_XR_REQUEST_ADCE_CONT_OFST    = 0;
  localparam SV_XR_REQUEST_ADCE_SINGLE_OFST  = 1;
  localparam SV_XR_REQUEST_DCD_OFST          = 2;
  localparam SV_XR_REQUEST_DFE_OFST          = 3;
  localparam SV_XR_REQUEST_VRC_OFST          = 4;
  localparam SV_XR_REQUEST_ADCE_CANCEL_OFST  = 5;
  localparam SV_XR_REQUEST_UNUSED_OFST       = 6;

  localparam SV_XR_REQUEST_ADCE_CONT_LEN     = 1;
  localparam SV_XR_REQUEST_ADCE_SINGLE_LEN   = 1;
  localparam SV_XR_REQUEST_DCD_LEN           = 1;
  localparam SV_XR_REQUEST_DFE_LEN           = 1;
  localparam SV_XR_REQUEST_VRC_LEN           = 1;
  localparam SV_XR_REQUEST_ADCE_CANCEL_LEN   = 1;
  localparam SV_XR_REQUEST_UNUSED_LEN        = 10;

  localparam SV_XR_REQUEST_ADCE_CONT_MASK    = 16'h0001;
  localparam SV_XR_REQUEST_ADCE_SINGLE_MASK  = 16'h0002;
  localparam SV_XR_REQUEST_DCD_MASK          = 16'h0004;
  localparam SV_XR_REQUEST_DFE_MASK          = 16'h0008;
  localparam SV_XR_REQUEST_VRC_MASK          = 16'h0010;
  localparam SV_XR_REQUEST_ADCE_CANCEL_MASK  = 16'h0020;


//********************************
  // Bit masks for RSTCTL register
  localparam SV_XR_RSTCTL_TX_RST_OVR_OFST               = 0;
  localparam SV_XR_RSTCTL_TX_DIGITAL_RST_N_VAL_OFST = 1;
  localparam SV_XR_RSTCTL_RX_RST_OVR_OFST               = 2;
  localparam SV_XR_RSTCTL_RX_DIGITAL_RST_N_VAL_OFST = 3;
  localparam SV_XR_RSTCTL_RX_ANALOG_RST_N_VAL_OFST  = 4;
  localparam SV_XR_RSTCTL_UNUSED_OFST                           = 5;

  localparam SV_XR_RSTCTL_TX_RST_OVR_LEN                = 1;
  localparam SV_XR_RSTCTL_TX_DIGITAL_RST_N_VAL_LEN  = 1;
  localparam SV_XR_RSTCTL_RX_RST_OVR_LEN                = 1;
  localparam SV_XR_RSTCTL_RX_DIGITAL_RST_N_VAL_LEN  = 1;
  localparam SV_XR_RSTCTL_RX_ANALOG_RST_N_VAL_LEN   = 1;
  localparam SV_XR_RSTCTL_UNUSED_LEN                            = 11;

  localparam SV_XR_RSTCTL_TX_RST_OVR_MASK               = 16'h0001;
  localparam SV_XR_RSTCTL_TX_DIGITAL_RST_N_MASK         = 16'h0002;
  localparam SV_XR_RSTCTL_RX_RST_OVR_MASK               = 16'h0004;
  localparam SV_XR_RSTCTL_RX_DIGITAL_RST_N_MASK         = 16'h0008;
  localparam SV_XR_RSTCTL_RX_ANALOG_RST_N_MASK          = 16'h0010;

//********************** End local channel registers *************************
//****************************************************************************


endpackage

