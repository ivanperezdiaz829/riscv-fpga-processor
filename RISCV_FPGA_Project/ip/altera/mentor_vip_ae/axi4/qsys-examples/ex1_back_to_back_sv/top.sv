// *****************************************************************************
//
// Copyright 2007-2013 Mentor Graphics Corporation
// All Rights Reserved.
//
// THIS WORK CONTAINS TRADE SECRET AND PROPRIETARY INFORMATION WHICH IS THE PROPERTY OF
// MENTOR GRAPHICS CORPORATION OR ITS LICENSORS AND IS SUBJECT TO LICENSE TERMS.
//
// *****************************************************************************

module top ();
  reg reset_reset_n = 0;
  reg clk_clk      ;
   
  master_test_program #(
        .AXI4_ADDRESS_WIDTH (32),
        .AXI4_RDATA_WIDTH   (32),
        .AXI4_WDATA_WIDTH   (32),
        .AXI4_ID_WIDTH      (18),
        .AXI4_USER_WIDTH    (8),
        .AXI4_REGION_MAP_SIZE(16)) u_master  (dut.mgc_axi4_master_0);

  slave_test_program #(
        .AXI4_ADDRESS_WIDTH (32),
        .AXI4_RDATA_WIDTH   (32),
        .AXI4_WDATA_WIDTH   (32),
        .AXI4_ID_WIDTH      (18),
        .AXI4_USER_WIDTH    (8),
        .AXI4_REGION_MAP_SIZE(16)) u_slave   (dut.mgc_axi4_slave_0);

  monitor_test_program #(
        .AXI4_ADDRESS_WIDTH (32),
        .AXI4_RDATA_WIDTH   (32),
        .AXI4_WDATA_WIDTH   (32),
        .AXI4_ID_WIDTH      (18),
        .AXI4_USER_WIDTH    (8),
        .AXI4_REGION_MAP_SIZE(16)) u_monitor (
    dut.mgc_axi4_inline_monitor_0.mgc_axi4_monitor_0);

  ex1_back_to_back_sv           dut       (.reset_reset_n(reset_reset_n), .clk_clk(clk_clk));

  always begin
    clk_clk = 0;
    #100;
    clk_clk = 1;
    #100;
  end

  initial begin
    reset_reset_n = 0;
    #1000 reset_reset_n = 1;
  end

endmodule
