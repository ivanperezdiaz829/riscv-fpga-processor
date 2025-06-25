////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//      Logic Core:  PCI/Avalon Bridge Megacore Function
//         Company:  Altera Corporation.
//                       www.altera.com 
//          Author:  IPBU SIO Group               
//
//     Description:  Avalon to PCI Variable Address Translation Table   
// 
// Copyright (c) 2004 Altera Corporation. All rights reserved.  This source code
// is highly confidential and proprietary information of Altera and is being
// provided in accordance with and subject to the protections of a
// Non-Disclosure Agreement which governs its use and disclosure.  Altera
// products and services are protected under numerous U.S. and foreign patents,
// maskwork rights, copyrights and other intellectual property laws.  Altera
// assumes no responsibility or liability arising out of the application or use
// of this source code.
// 
// For Best Viewing Set tab stops to 4 spaces.
// 
// $Id: altpciav_lite_p2a_addrtrans.v,v 1.1 2007/06/06 09:53:42 lfching Exp $
//
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

// This module contains the address translation logic from the PCI to Avalon
// direction. The translation is done per BAR bases using a pre-defined 
// translation table.

module altpciav_lite_p2a_addrtrans ( cpcicomp_bar0_i, 
                        cpcicomp_bar1_i,
                        cpcicomp_bar2_i,
                        cpcicomp_bar3_i,
                        cpcicomp_bar4_i,
                        cpcicomp_bar5_i,
                        cpcicomp_exp_rom_bar_i,
                        cb_p2a_avalon_addr_b0_i,
                        cb_p2a_avalon_addr_b1_i,
                        cb_p2a_avalon_addr_b2_i,
                        cb_p2a_avalon_addr_b3_i,
                        cb_p2a_avalon_addr_b4_i,
                        cb_p2a_avalon_addr_b5_i,
                        cb_p2a_avalon_addr_b6_i,
                        PCIAddr_i,
                        BarHit_i,
                        AvlAddr_o
                       );
                       
input [31:0] cpcicomp_bar0_i;
input [31:0] cpcicomp_bar1_i;
input [31:0] cpcicomp_bar2_i;
input [31:0] cpcicomp_bar3_i;
input [31:0] cpcicomp_bar4_i;
input [31:0] cpcicomp_bar5_i;
input [31:0] cpcicomp_exp_rom_bar_i;
input [31:0] cb_p2a_avalon_addr_b0_i;
input [31:0] cb_p2a_avalon_addr_b1_i;
input [31:0] cb_p2a_avalon_addr_b2_i;
input [31:0] cb_p2a_avalon_addr_b3_i;
input [31:0] cb_p2a_avalon_addr_b4_i;
input [31:0] cb_p2a_avalon_addr_b5_i;
input [31:0] cb_p2a_avalon_addr_b6_i;
input [31:0] PCIAddr_i;
input [6:0] BarHit_i;
output [31:0] AvlAddr_o;


reg [31:0] bar_parameter;
reg [31:0] avl_addr;

// mux to select the right BAR parameter to use.
// based on the BAR hit information, determined BAR paremeter
// is used for the address translation

always  @(BarHit_i or cpcicomp_bar0_i or cpcicomp_bar1_i or cpcicomp_bar2_i or
        cpcicomp_bar3_i or cpcicomp_bar4_i or cpcicomp_bar5_i or
        cpcicomp_exp_rom_bar_i)
begin
  case (BarHit_i)
    7'b0000001 : bar_parameter = cpcicomp_bar0_i;
    7'b0000010 : bar_parameter = cpcicomp_bar1_i;
    7'b0000100 : bar_parameter = cpcicomp_bar2_i;
    7'b0001000 : bar_parameter = cpcicomp_bar3_i;
    7'b0010000 : bar_parameter = cpcicomp_bar4_i;
    7'b0100000 : bar_parameter = cpcicomp_bar5_i;
    7'b1000000 : bar_parameter = cpcicomp_exp_rom_bar_i;
    7'b0000011 : bar_parameter = cpcicomp_bar1_i; // 64-bit bar hit
    default    : bar_parameter = 32'h00000000;
  endcase
end


// mux to select the right avalon address entry to use
// Based on the BAR hit information, select which entry in the table to
// be used for the address translation

always  @(BarHit_i or cb_p2a_avalon_addr_b0_i or cb_p2a_avalon_addr_b1_i or
        cb_p2a_avalon_addr_b2_i or cb_p2a_avalon_addr_b3_i or
        cb_p2a_avalon_addr_b4_i or cb_p2a_avalon_addr_b5_i or
        cb_p2a_avalon_addr_b6_i)
begin
  case (BarHit_i )
    7'b0000001 : avl_addr = cb_p2a_avalon_addr_b0_i;
    7'b0000010 : avl_addr = cb_p2a_avalon_addr_b1_i;
    7'b0000100 : avl_addr = cb_p2a_avalon_addr_b2_i;
    7'b0001000 : avl_addr = cb_p2a_avalon_addr_b3_i;
    7'b0010000 : avl_addr = cb_p2a_avalon_addr_b4_i;
    7'b0100000 : avl_addr = cb_p2a_avalon_addr_b5_i;
    7'b1000000 : avl_addr = cb_p2a_avalon_addr_b6_i;
    7'b0000011 : avl_addr = cb_p2a_avalon_addr_b1_i; // 64-bit bar hit
    default    : avl_addr = 32'h00000000;
  endcase
end

// address translation. The high order bits is from the corresponding
// entry of the table and low order is passed through unchanged.
assign AvlAddr_o = (PCIAddr_i & ~({bar_parameter[31:4], 4'b0000})) |
                   (avl_addr & ({bar_parameter[31:4], 4'b0000})) ;

endmodule


