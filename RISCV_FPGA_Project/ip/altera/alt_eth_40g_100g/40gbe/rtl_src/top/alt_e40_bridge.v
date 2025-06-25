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


`timescale 1ps / 1ps

module alt_e40_bridge  (
    input [31:0] status_mac_readdata,
    input status_mac_readdata_valid,
    input [31:0] status_phy_readdata,
    input status_phy_readdata_valid,
    output clk_status_mac,
    output [15:0] status_mac_addr,
    output status_mac_read,
    output status_mac_write,
    output [31:0] status_mac_writedata,
    output clk_status_phy,
    output [15:0] status_phy_addr,
    output status_phy_read,
    output status_phy_write,
    output [31:0] status_phy_writedata,
    input clk_status,
    input [15:0] status_addr,
    input status_read,
    input status_write,
    input [31:0] status_writedata,
    output [31:0] status_readdata,
    output status_readdata_valid,

    input pma_arst_ST,
    output pma_arst_ST_out
);

// Status register bus
assign status_readdata = status_mac_readdata | status_phy_readdata;
assign status_readdata_valid = status_mac_readdata_valid | status_phy_readdata_valid;
assign clk_status_mac = clk_status;
assign status_mac_addr = status_addr;
assign status_mac_read = status_read;
assign status_mac_write = status_write;
assign status_mac_writedata = status_writedata;
assign clk_status_phy = clk_status;
assign status_phy_addr = status_addr;
assign status_phy_read = status_read;
assign status_phy_write = status_write;
assign status_phy_writedata = status_writedata;

assign pma_arst_ST_out = pma_arst_ST;

endmodule
