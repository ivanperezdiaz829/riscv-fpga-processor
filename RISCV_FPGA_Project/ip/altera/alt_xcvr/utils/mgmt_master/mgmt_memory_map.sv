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
            ADDR_RESET_FINE_CTRL    = 67;
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
            BIT_RESET_FINE_CTRL_RESET_RX_DIGITAL_MSK  = 32'h8;

// PMA channel control and status registers
localparam  ADDR_PMA_LOOPBACK_SERIAL    = 97,
            ADDR_PMA_RX_SIGNALDETECT    = 99,
            ADDR_PMA_RX_SET_LOCKTODATA  = 100,
            ADDR_PMA_RX_SET_LOCKTOREF   = 101,
            ADDR_PMA_RX_IS_LOCKEDTODATA = 102,
            ADDR_PMA_RX_IS_LOCKEDTOREF  = 103;


// PCS Control and Status registers
localparam  ADDR_PCS_LANE_NUM         = 128,
            ADDR_PCS8G_RX_STATUS      = 129,
            ADDR_PCS8G_TX_STATUS      = 130,
            ADDR_PCS8G_TX_CONTROL     = 131,
            ADDR_PCS8G_RX_CONTROL     = 132,
            ADDR_PCS8G_RX_WA_CONTROL  = 133,
            ADDR_PCS8G_RX_WA_STATUS   = 135;
// PCS Control and status bits
localparam  BIT_PCS8G_RX_STATUS_RX_PHASE_COMP_FIFO_ERROR        = 0,
            BIT_PCS8G_RX_STATUS_RX_PHASE_COMP_FIFO_ERROR_MSK    = 32'h1,
            BIT_PCS8G_RX_STATUS_RX_BITSLIPBOUNDARYSELECTOUT     = 1,
            BIT_PCS8G_RX_STATUS_RX_BITSLIPBOUNDARYSELECTOUT_MSK = 32'h3E;

localparam  BIT_PCS8G_TX_STATUS_TX_PHASE_COMP_FIFO_ERROR      = 0,
            BIT_PCS8G_TX_STATUS_TX_PHASE_COMP_FIFO_ERROR_MSK  = 32'h1;

localparam  BIT_PCS8G_TX_CONTROL_TX_INVPOLARITY               = 0,
            BIT_PCS8G_TX_CONTROL_TX_INVPOLARITY_MSK           = 32'h1,
            BIT_PCS8G_TX_CONTROL_TX_BITSLIPBOUNDARYSELECT     = 1,
            BIT_PCS8G_TX_CONTROL_TX_BITSLIPBOUNDARYSELECT_MSK = 32'h3E;
          
localparam  BIT_PCS8G_RX_CONTROL_RX_INVPOLARITY     = 0,
            BIT_PCS8G_RX_CONTROL_RX_INVPOLARITY_MSK = 32'h1;

localparam  BIT_PCS8G_RX_WA_CONTROL_RX_ENAPATTERNALIGN        = 0,
            BIT_PCS8G_RX_WA_CONTROL_RX_ENAPATTERNALIGN_MSK    = 32'h1,
            BIT_PCS8G_RX_WA_CONTROL_RX_BITREVERSALENABLE      = 1,
            BIT_PCS8G_RX_WA_CONTROL_RX_BITREVERSALENABLE_MSK  = 32'h2,
            BIT_PCS8G_RX_WA_CONTROL_RX_BYTEREVERSALENABLE     = 2,
            BIT_PCS8G_RX_WA_CONTROL_RX_BYTEREVERSALENABLE_MSK = 32'h4,
            BIT_PCS8G_RX_WA_CONTROL_RX_BITSLIP                = 3,
            BIT_PCS8G_RX_WA_CONTROL_RX_BITSLIP_MSK            = 32'h8;

localparam  BIT_PCS8G_RX_WA_STATUS_RX_ERRDETECT         = 0,
            BIT_PCS8G_RX_WA_STATUS_RX_ERRDETECT_MSK     = 32'hf,
            BIT_PCS8G_RX_WA_STATUS_RX_SYNCSTATUS        = 4,
            BIT_PCS8G_RX_WA_STATUS_RX_SYNCSTATUS_MSK    = 32'hf0,
            BIT_PCS8G_RX_WA_STATUS_RX_DISPERR           = 8,
            BIT_PCS8G_RX_WA_STATUS_RX_DISPERR_MSK       = 32'hf00,
            BIT_PCS8G_RX_WA_STATUS_RX_PATTERNDETECT     = 12,
            BIT_PCS8G_RX_WA_STATUS_RX_PATTERNDETECT_MSK = 32'hf000,
            BIT_PCS8G_RX_WA_STATUS_RX_RLV               = 16,
            BIT_PCS8G_RX_WA_STATUS_RX_RLV_MSK           = 32'hf_0000,
            BIT_PCS8G_RX_WA_STATUS_RX_A1A2SIZEOUT       = 20,
            BIT_PCS8G_RX_WA_STATUS_RX_A1A2SIZEOUT_MSK   = 32'hf0_0000;

endpackage
