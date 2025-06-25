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


// Top level module for board testing

module top (
            // global signals:
            clk_50Mhz,
            ref_clk,
            reset_n, 
    
            // the_mdio
            mdc_from_the_mdio,
            mdio_in_out_from_the_mdio,

            // the_xaui
            xaui_rx_serial_export_to_the_xaui,
            xaui_tx_serial_export_from_the_xaui
);


  input         clk_50Mhz;
  input         ref_clk;
  input         reset_n;
  output        mdc_from_the_mdio;
  inout         mdio_in_out_from_the_mdio;
  output  [3:0] xaui_tx_serial_export_from_the_xaui;
  input   [3:0] xaui_rx_serial_export_to_the_xaui;
  
  wire          xaui_xgmii_rx_clk_clk_out;
  wire    [3:0] xaui_tx_serial_export_from_the_xaui;
  wire          mdc_from_the_mdio;
  wire          mdio_in_to_the_mdio;
  wire          mdio_oen_from_the_mdio;
  wire          mdio_out_from_the_mdio;
  
  wire   [63:0] avalon_st_rx_data_exp_from_the_eth_st_if;
  wire   [2:0]  avalon_st_rx_empty_exp_from_the_eth_st_if;
  wire          avalon_st_rx_eop_exp_from_the_eth_st_if;
  wire   [5:0]  avalon_st_rx_error_exp_from_the_eth_st_if;
  wire          avalon_st_rx_ready_exp_to_the_eth_st_if;
  wire          avalon_st_rx_sop_exp_from_the_eth_st_if;
  wire          avalon_st_rx_valid_exp_from_the_eth_st_if;  

  wire   [63:0] avalon_st_tx_data_exp_to_the_eth_st_if;
  wire   [2:0]  avalon_st_tx_empty_exp_to_the_eth_st_if;
  wire          avalon_st_tx_eop_exp_to_the_eth_st_if;
  wire          avalon_st_tx_error_exp_to_the_eth_st_if;
  wire          avalon_st_tx_ready_exp_from_the_eth_st_if;
  wire          avalon_st_tx_sop_exp_to_the_eth_st_if;
  wire          avalon_st_tx_valid_exp_to_the_eth_st_if;
  

  
altera_eth_10g_mac_xaui SUT(
    .mm_clk_clk(clk_50Mhz),
    .mm_reset_reset_n(reset_n),
          
    .mdio_mdio_oen(mdio_oen_from_the_mdio),
    .mdio_mdio_out(mdio_out_from_the_mdio),
    .mdio_mdio_in(mdio_in_to_the_mdio),
    .mdio_mdc(mdc_from_the_mdio),
    .xgmii_rx_clk_clk(xaui_xgmii_rx_clk_clk_out),
    
    .tx_sc_fifo_in_data(avalon_st_tx_data_exp_to_the_eth_st_if),
    .tx_sc_fifo_in_valid(avalon_st_tx_valid_exp_to_the_eth_st_if),
    .tx_sc_fifo_in_ready(avalon_st_tx_ready_exp_from_the_eth_st_if),
    .tx_sc_fifo_in_startofpacket(avalon_st_tx_sop_exp_to_the_eth_st_if),
    .tx_sc_fifo_in_endofpacket(avalon_st_tx_eop_exp_to_the_eth_st_if),
    .tx_sc_fifo_in_empty(avalon_st_tx_empty_exp_to_the_eth_st_if),
    .tx_sc_fifo_in_error(avalon_st_tx_error_exp_to_the_eth_st_if),
    
    .rx_sc_fifo_out_data(avalon_st_rx_data_exp_from_the_eth_st_if),
    .rx_sc_fifo_out_valid(avalon_st_rx_valid_exp_from_the_eth_st_if),
    .rx_sc_fifo_out_ready(avalon_st_rx_ready_exp_to_the_eth_st_if),
    .rx_sc_fifo_out_startofpacket(avalon_st_rx_sop_exp_from_the_eth_st_if),
    .rx_sc_fifo_out_endofpacket(avalon_st_rx_eop_exp_from_the_eth_st_if),
    .rx_sc_fifo_out_empty(avalon_st_rx_empty_exp_from_the_eth_st_if),
    .rx_sc_fifo_out_error(avalon_st_rx_error_exp_from_the_eth_st_if),
  
    .avalon_st_rxstatus_valid(),
    .avalon_st_rxstatus_data(),
    .avalon_st_rxstatus_error(),
    .avalon_st_txstatus_valid(),
    .avalon_st_txstatus_data(),
    .avalon_st_txstatus_error(),
    .link_fault_status_xgmii_rx_data(),
    
    .ref_clk_clk(ref_clk),
    .ref_reset_reset_n(reset_n),
    
    .tx_clk_clk(xaui_xgmii_rx_clk_clk_out),
    .tx_reset_reset_n(reset_n),
    
    .rx_ready_export(),
    .tx_ready_export(),
    .tx_serial_data_export(xaui_tx_serial_export_from_the_xaui),
    .rx_serial_data_export(xaui_rx_serial_export_to_the_xaui),
    
    .mm_pipeline_bridge_waitrequest(),
    .mm_pipeline_bridge_readdata(),
    .mm_pipeline_bridge_writedata(0),
    .mm_pipeline_bridge_address(0),
    .mm_pipeline_bridge_write(0),
    .mm_pipeline_bridge_read(0)

  
);
  
// MDIO ports connection
assign mdio_in_out_from_the_mdio = !mdio_oen_from_the_mdio? mdio_out_from_the_mdio : 1'bz;
assign mdio_in_to_the_mdio = mdio_in_out_from_the_mdio;

// Loopback on system side and address swapper instantiation
altera_eth_addr_swapper addr_swp_lb (
        .clk(xaui_xgmii_rx_clk_clk_out),           
        .reset_n(reset_n),
        .avalon_st_rx_data(avalon_st_rx_data_exp_from_the_eth_st_if),
        .avalon_st_rx_empty(avalon_st_rx_empty_exp_from_the_eth_st_if),
        .avalon_st_rx_eop(avalon_st_rx_eop_exp_from_the_eth_st_if),
        .avalon_st_rx_error(avalon_st_rx_error_exp_from_the_eth_st_if),
        .avalon_st_rx_ready(avalon_st_rx_ready_exp_to_the_eth_st_if),
        .avalon_st_rx_sop(avalon_st_rx_sop_exp_from_the_eth_st_if),
        .avalon_st_rx_valid(avalon_st_rx_valid_exp_from_the_eth_st_if),
        .avalon_st_tx_data(avalon_st_tx_data_exp_to_the_eth_st_if),
        .avalon_st_tx_empty(avalon_st_tx_empty_exp_to_the_eth_st_if),
        .avalon_st_tx_eop(avalon_st_tx_eop_exp_to_the_eth_st_if),
        .avalon_st_tx_error(avalon_st_tx_error_exp_to_the_eth_st_if),
        .avalon_st_tx_ready(avalon_st_tx_ready_exp_from_the_eth_st_if),
        .avalon_st_tx_sop(avalon_st_tx_sop_exp_to_the_eth_st_if),
        .avalon_st_tx_valid(avalon_st_tx_valid_exp_to_the_eth_st_if)
);

endmodule
