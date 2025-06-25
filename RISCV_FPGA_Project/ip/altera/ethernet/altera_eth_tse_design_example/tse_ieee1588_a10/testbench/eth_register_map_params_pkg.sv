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


`ifndef ETH_REGISTER_MAP_PARAMS_PKG__SV
`define ETH_REGISTER_MAP_PARAMS_PKG__SV

// Package defines address of registers
package eth_register_map_params_pkg;
    
    // Unicast address for source address insertion on TX path
    parameter TX_ADDRESS_INSERT_UCAST_MAC_ADD_0_ADDR            = 32'hC;
    parameter TX_ADDRESS_INSERT_UCAST_MAC_ADD_1_ADDR            = 32'h10;
	

	
	parameter TSE_COMMAND_CONFIG_ADDR  = 32'h8;
	parameter TX_IPG_LENGTH_ADDR  = 32'h5C;
	parameter TX_FRM_LENGTH_ADDR = 32'h14;
	parameter TX_PAUSE_QUANT_ADDR = 32'h18;

	
	parameter TX_CMD_STAT_ADDR									= 32'hE8;
	
	//pcs Address
	parameter PCS_CONTROL_ADDR									= 32'h200;
	parameter PCS_IF_MODE_ADDR									= 32'h250;
	
	//TSU period address
	parameter TX_TSU_PERIOD_ADDR								= 32'h340;
	parameter RX_TSU_PERIOD_ADDR								= 32'h34C;
	
	//TSU adjustment address
	parameter TX_TSU_ADJ_NS_ADDR								= 32'h348;
	parameter TX_TSU_ADJ_FNS_ADDR								= 32'h344;
	parameter RX_TSU_ADJ_NS_ADDR								= 32'h354;
	parameter RX_TSU_ADJ_FNS_ADDR								= 32'h350;	
	
	//Clock Mode Address
	parameter TX_CLOCK_MODE_ADDR								= 32'h358;
	
	//TOD Address
	parameter TOD_SEC_H_ADDR									= 32'h0;	
	parameter TOD_SEC_L_ADDR									= 32'h4;	
	parameter TOD_NSEC_ADDR										= 32'h8;	
	parameter TOD_PERIOD_ADDR									= 32'hC;	
	parameter TOD_ADJUST_PERIOD_ADDR							= 32'h14;	
	parameter TOD_ADJUST_COUNT_ADDR								= 32'h18;	


	parameter BASE_ADDR_MAC										=32'h0000;
	parameter BASE_ADDR_TOD										=32'h1000;
	parameter BASE_ADDR_XCVR_RECONFIG							=32'h2000;

     
    
    // ******************************************************************************************
    // Registers Offset of MAC
    // ******************************************************************************************
    // ------------------------------------------------------------------------------------------
    // Statistics
    // ------------------------------------------------------------------------------------------
    parameter STATISTICS_framesOK_OFFSET                        = 32'h008;
    parameter STATISTICS_framesErr_OFFSET                       = 32'h010;
    parameter STATISTICS_framesCRCErr_OFFSET                    = 32'h018;
    parameter STATISTICS_octetsOK_OFFSET                        = 32'h020;
    parameter STATISTICS_pauseMACCtrlFrames_OFFSET              = 32'h028;
    parameter STATISTICS_ifErrors_OFFSET                        = 32'h030;
    parameter STATISTICS_unicastFramesOK_OFFSET                 = 32'h038;
    parameter STATISTICS_unicastFramesErr_OFFSET                = 32'h040;
    parameter STATISTICS_multicastFramesOK_OFFSET               = 32'h048;
    parameter STATISTICS_multicastFramesErr_OFFSET              = 32'h050;
    parameter STATISTICS_broadcastFramesOK_OFFSET               = 32'h058;
    parameter STATISTICS_broadcastFramesErr_OFFSET              = 32'h060;
    parameter STATISTICS_etherStatsOctets_OFFSET                = 32'h068;
    parameter STATISTICS_etherStatsPkts_OFFSET                  = 32'h070;
    parameter STATISTICS_etherStatsUndersizePkts_OFFSET         = 32'h078;
    parameter STATISTICS_etherStatsOversizePkts_OFFSET          = 32'h080;
    parameter STATISTICS_etherStatsPkts64Octets_OFFSET          = 32'h088;
    parameter STATISTICS_etherStatsPkts65to127Octets_OFFSET     = 32'h090;
    parameter STATISTICS_etherStatsPkts128to255Octets_OFFSET    = 32'h098;
    parameter STATISTICS_etherStatsPkts256to511Octets_OFFSET    = 32'h0A0;
    parameter STATISTICS_etherStatsPkts512to1023Octets_OFFSET   = 32'h0A8;
    parameter STATISTICS_etherStatPkts1024to1518Octets_OFFSET   = 32'h0B0;
    parameter STATISTICS_etherStatsPkts1519toXOctets_OFFSET     = 32'h0B8;
    parameter STATISTICS_etherStatsFragments_OFFSET             = 32'h0C0;
    parameter STATISTICS_etherStatsJabbers_OFFSET               = 32'h0C8;
    parameter STATISTICS_etherStatsCRCErr_OFFSET                = 32'h0D0;
    parameter STATISTICS_unicastMACCtrlFrames_OFFSET            = 32'h0D8;
    parameter STATISTICS_multicastMACCtrlFrames_OFFSET          = 32'h0E0;
    parameter STATISTICS_broadcastMACCtrlFrames_OFFSET          = 32'h0E8;
	
	

    
endpackage

`endif
