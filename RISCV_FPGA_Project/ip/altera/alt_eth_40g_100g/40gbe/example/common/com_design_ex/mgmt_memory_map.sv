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


package mgmt_memory_map;

// for the Reconfig functions
   import alt_xcvr_reconfig_h::*;

   // MIF reconfig memory map
   localparam LOCAL_ADDR_XR_MIF_LCH    = ADDR_XR_MIF_LCH;
   localparam LOCAL_ADDR_XR_MIF_PCH    = ADDR_XR_MIF_PCH;
   localparam LOCAL_ADDR_XR_MIF_STATUS = ADDR_XR_MIF_STATUS;
   localparam LOCAL_ADDR_XR_MIF_OFFSET = ADDR_XR_MIF_OFFSET;
   localparam LOCAL_ADDR_XR_MIF_DATA   = ADDR_XR_MIF_DATA;
   
   // PLL reconfig memory map
   localparam LOCAL_ADDR_XR_PLL_LCH    = ADDR_XR_PLL_LCH;
   localparam LOCAL_ADDR_XR_PLL_PCH    = ADDR_XR_PLL_PCH;
   localparam LOCAL_ADDR_XR_PLL_STATUS = ADDR_XR_PLL_STATUS;
   localparam LOCAL_ADDR_XR_PLL_OFFSET = ADDR_XR_PLL_OFFSET;
   localparam LOCAL_ADDR_XR_PLL_DATA   = ADDR_XR_PLL_DATA;


// PHY common registers
localparam  ADDR_RESERVED                     = 0,
            ADDR_PHY_INTERRUPT_CH_BITMASK     = 1,
            ADDR_PHY_INTERRUPT_ENABLE_BITMASK = 2,
            ADDR_PHY_INTERRUPT_SOURCE         = 3,
            ADDR_PHY_INTERRUPT_TX_INVPOLARITY = 4,
            ADDR_PHY_INTERRUPT_RX_INVPOLARITY = 5,
            ADDR_PHY_LOOPBACK_SERIAL          = 6,
            ADDR_PHY_LOOBPACK_REVERSE_SERIAL  = 7;

// PMA registers
localparam  ADDR_PMA_RESEERVED      = 32,
            ADDR_CALIBRATION_PDN    = 33,
            ADDR_PLL_LOCKED         = 34;

// Reset control and status registers
localparam  ADDR_RESET_RESERVED     = 64,
            ADDR_RESET_CH_BITMASK   = 65,
            ADDR_RESET_CTRL_STAT    = 66,
            ADDR_RESET_FINE_CTRL    = 68;

// Reset control and status bits
localparam  BIT_RESET_CTRL_STAT_RESET_TX_DIGITAL      = 0,
            BIT_RESET_CTRL_STAT_RESET_TX_DIGITAL_MSK  = 32'h1,
            BIT_RESET_CTRL_STAT_RESET_RX_DIGITAL      = 1,
            BIT_RESET_CTRL_STAT_RESET_RX_DIGITAL_MSK  = 32'h2,
            BIT_RESET_CTRL_STAT_RESET_ALL             = 2,
            BIT_RESET_CTRL_STAT_RESET_ALL_MSK         = 32'h4;

localparam  BIT_RESET_FINE_CTRL_PLL_POWERDOWN         = 0,
            BIT_RESET_FINE_CTRL_PLL_POWERDOWN_MSK     = 32'h1,
            BIT_RESET_FINE_CTRL_RESET_TX_DIGITAL      = 1,
            BIT_RESET_FINE_CTRL_RESET_TX_DIGITAL_MSK  = 32'h2,
            BIT_RESET_FINE_CTRL_RESET_TX_ANALOG       = 2,
            BIT_RESET_FINE_CTRL_RESET_TX_ANALOG_MSK   = 32'h4,
            BIT_RESET_FINE_CTRL_RESET_RX_DIGITAL      = 3,
            BIT_RESET_FINE_CTRL_RESET_RX_DIGITAL_MSK  = 32'h8,
            BIT_RESET_FINE_CTRL_RESET_ALL_MSK         = 32'hF;

// PMA channel control and status registers
localparam  ADDR_PMA_LOOPBACK_SERIAL    = 97,
            ADDR_PMA_RX_SIGNALDETECT    = 99,
            ADDR_PMA_RX_SET_LOCKTODATA  = 100,
            ADDR_PMA_RX_SET_LOCKTOREF   = 101,
            ADDR_PMA_RX_IS_LOCKEDTODATA = 102,
            ADDR_PMA_RX_IS_LOCKEDTOREF  = 103;

// PCS Control and Status registers
localparam  ADDR_PCS_LANE_GROUP       = 128,
            ADDR_PCS10G_CNT_CONTROL   = 129,
            ADDR_PCS10G_STATUS        = 130,
            ADDR_PCS10G_CNT_STATUS    = 131;

// PCS Control and status bits
localparam  BIT_PCS10G_PCS_STATUS             = 0,
            BIT_PCS10G_PCS_STATUS_MSK         = 32'd1,
            BIT_PCS10G_HI_BER                 = 1,
            BIT_PCS10G_HI_BER_MSK             = 32'd2,
            BIT_PCS10G_BLOCK_LOCK             = 2,
            BIT_PCS10G_BLOCK_LOCK_MSK         = 32'd4,
            BIT_PCS10G_TX_FIFO_FULL           = 3,
            BIT_PCS10G_TX_FIFO_FULL_MSK       = 32'd8,
            BIT_PCS10G_RX_FIFO_FULL           = 4,
            BIT_PCS10G_RX_FIFO_FULL_MSK       = 32'd16,
            BIT_PCS10G_RX_SYNC_HEAD_ERROR     = 5,
            BIT_PCS10G_RX_SYNC_HEAD_ERROR_MSK = 32'd32,
            BIT_PCS10G_RX_SCRAMBLER_ERROR     = 6,
            BIT_PCS10G_RX_SCRAMBLER_ERROR_MSK = 32'd64,
            BIT_PCS10G_RX_DATA_READY          = 7,
            BIT_PCS10G_RX_DATA_READY_MSK      = 32'd128,
            BIT_PCS10G_ALL_STATUS_MSK         = 32'd255;

// PCS Control and status bits
localparam  BIT_PCS10G_CLR_ERRBLK_CNT         = 2,
            BIT_PCS10G_CLR_ERRBLK_CNT_MSK     = 32'd4,
            BIT_PCS10G_CLR_BER_CNT            = 3,
            BIT_PCS10G_CLR_BER_CNT_MSK        = 32'd8;

endpackage
