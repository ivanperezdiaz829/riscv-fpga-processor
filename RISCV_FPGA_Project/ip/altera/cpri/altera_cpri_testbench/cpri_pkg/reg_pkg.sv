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


// List of register
parameter REG_CPRI_INTR    	       = 14'h0;  //actual value 0x00
parameter REG_CPRI_STATUS    	       = 14'h1;  //actual value 0x04
parameter REG_CPRI_CONFIG    	       = 14'h2;  //actual value 0x08
parameter REG_CPRI_CTRL_INDEX 	    = 14'h3;  //actual value 0x0C
parameter REG_CPRI_RX_CTRL  	       = 14'h4;  //actual value 0x10
parameter REG_CPRI_TX_CTRL  	       = 14'h5;  //actual value 0x14
parameter REG_CPRI_LCV  	          = 14'h6;  //actual value 0x18
parameter REG_CPRI_BFN  	          = 14'h7;  //actual value 0x1C
parameter REG_CPRI_HW_RESET          = 14'h8;  //actual value 0x20
parameter REG_PHY_LOOP               = 14'h9;  //actual value 0x24
parameter REG_CPRI_CM_CONFIG         = 14'hA;  //actual value 0x28
parameter REG_CPRI_CM_STATUS         = 14'hB;  //actual value 0x2C 
parameter REG_CPRI_RX_DELAY_CTRL     = 14'hC;  //actual value 0x30
parameter REG_CPRI_RX_DELAY          = 14'hD;  //actual value 0x34
parameter REG_CPRI_ROUND_DELAY       = 14'hE;  //actual value 0x38
parameter REG_CPRI_EX_DELAY_CONFIG   = 14'hF;  //actual value 0x3C
parameter REG_CPRI_EX_DELAY_STATUS   = 14'h10; //actual value 0x40 
parameter REG_CPRI_SERDES_CONFIG     = 14'h11; //actual value 0x44
parameter REG_CPRI_AUTO_RATE_CONFIG  = 14'h12; //actual value 0x48  
parameter REG_CPRI_INTR_PEND         = 14'h13; //actual value 0x4C
parameter REG_CPRI_N_LCV             = 14'h14; //actual value 0x50
parameter REG_CPRI_T_LCV             = 14'h15; //actual value 0x54
parameter REG_CPRI_TX_PROT_VER       = 14'h16; //actual value 0x58
parameter REG_CPRI_TX_SCR_SEED       = 14'h17; //actual value 0x5C
parameter REG_CPRI_RX_SCR_SEED       = 14'h18; //actual value 0x60
parameter REG_CPRI_MAP_CONFIG        = 14'h40; //actual value 0x100
parameter REG_CPRI_MAP_CNT_CONFIG    = 14'h41; //actual value 0x104
parameter REG_CPRI_MAP_TBL_CONFIG    = 14'h42; //actual value 0x108
parameter REG_CPRI_MAP_TBL_INDEX     = 14'h43; //actual value 0x10C
parameter REG_CPRI_MAP_TBL_RX        = 14'h44; //actual value 0x110
parameter REG_CPRI_MAP_TBL_TX        = 14'h45; //actual value 0x114
parameter REG_CPRI_MAP_OFFSET_RX     = 14'h46; //actual value 0x118
parameter REG_CPRI_MAP_OFFSET_TX     = 14'h47; //actual value 0x11C
parameter REG_CPRI_START_OFFSET_RX   = 14'h48; //actual value 0x120
parameter REG_CPRI_START_OFFSET_TX   = 14'h49; //actual value 0x124
parameter REG_CPRI_MAP_RX_READY_THR  = 14'h4A; //actual value 0x128
parameter REG_CPRI_MAP_TX_READY_THR  = 14'h4B; //actual value 0x12C
parameter REG_CPRI_MAP_TX_START_THR  = 14'h4C; //actual value 0x130
parameter REG_CPRI_PRBS_CONFIG       = 14'h4F; //actual value 0x13C
parameter REG_CPRI_PRBS_STATUS_0     = 14'h50; //actual value 0x140  
parameter REG_CPRI_PRBS_STATUS_1     = 14'h51; //actual value 0x144
parameter REG_CPRI_IQ_RX_BUF_STATUS  = 14'h60; //actual value 0x180
parameter REG_CPRI_IQ_TX_BUF_STATUS  = 14'h68; //actual value 0x1A0  
parameter REG_CPRI_IQ_RX_BUF_CONTROL = 14'h54; //actual value 0x150
parameter REG_CPRI_IQ_TX_BUF_CONTROL = 14'h58; //actual value 0x160  
parameter REG_ETH_RX_STATUS 	       = 14'h80; //actual value 0x200
parameter REG_ETH_TX_STATUS 	       = 14'h81; //actual value 0x204
parameter REG_ETH_CONFIG_1           = 14'h82; //actual value 0x208
parameter REG_ETH_CONFIG_2           = 14'h83; //actual value 0x20C
parameter REG_ETH_RX_CONTROL         = 14'h84; //actual value 0x210
parameter REG_ETH_RX_DATA            = 14'h85; //actual value 0x214
parameter REG_ETH_RX_DATA_WAIT       = 14'h86; //actual value 0x218
parameter REG_ETH_TX_CONTROL         = 14'h87; //actual value 0x21C
parameter REG_ETH_TX_DATA            = 14'h88; //actual value 0x220
parameter REG_ETH_TX_DATA_WAIT       = 14'h89; //actual value 0x224
parameter REG_ETH_RX_EX_STATUS       = 14'h8A; //actual value 0x228
parameter REG_ETH_MAC_ADDR_MSB       = 14'h8B; //actual value 0x22C
parameter REG_ETH_MAC_ADDR_LSB       = 14'h8C; //actual value 0x230
parameter REG_ETH_HASH_TABLE         = 14'h8D; //actual value 0x234
parameter REG_ETH_CONFIG_3           = 14'h91; //actual value 0x244
parameter REG_ETH_CNT_RX_FRAME       = 14'h92; //actual value 0x248
parameter REG_ETH_CNT_TX_FRAME       = 14'h93; //actual value 0X24C
parameter REG_HDLC_RX_STATUS  	    = 14'hC0; //actual value 0x300
parameter REG_HDLC_TX_STATUS  	    = 14'hC1; //actual value 0x304
parameter REG_HDLC_CONFIG_1          = 14'hC2; //actual value 0x308
parameter REG_HDLC_CONFIG_2          = 14'hC3; //actual value 0x30C
parameter REG_HDLC_RX_CONTROL        = 14'hC4; //actual value 0x310
parameter REG_HDLC_RX_DATA           = 14'hC5; //actual value 0x314
parameter REG_HDLC_RX_DATA_WAIT      = 14'hC6; //actual value 0x318
parameter REG_HDLC_TX_CONTROL        = 14'hC7; //actual value 0x31C
parameter REG_HDLC_TX_DATA           = 14'hC8; //actual value 0x320
parameter REG_HDLC_TX_DATA_WAIT      = 14'hC9; //actual value 0x324
parameter REG_HDLC_RX_EX_STATUS      = 14'hCA; //actual value 0x328
parameter REG_HDLC_CONFIG_3          = 14'hCB; //actual value 0x32C
parameter REG_HDLC_CNT_RX_FRAME      = 14'hCC; //actual value 0x330
parameter REG_HDLC_CNT_TX_FRAME      = 14'hCD; //actual value 0x334
