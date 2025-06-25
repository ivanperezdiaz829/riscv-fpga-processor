// *****************************************************************************
//
// Copyright 2007-2013 Mentor Graphics Corporation
// All Rights Reserved.
//
// THIS WORK CONTAINS TRADE SECRET AND PROPRIETARY INFORMATION WHICH IS THE PROPERTY OF
// MENTOR GRAPHICS CORPORATION OR ITS LICENSORS AND IS SUBJECT TO LICENSE TERMS.
//
// *****************************************************************************
//            Version: 20130911_Questa_10.2c
// *****************************************************************************

// Title: axi_inline_monitor
//

// import package for the axi interface
import mgc_axi_pkg::*;

interface mgc_axi_inline_monitor #(int AXI_ADDRESS_WIDTH = 64, int AXI_RDATA_WIDTH = 1024, int AXI_WDATA_WIDTH = 1024, int AXI_ID_WIDTH = 18, int index = 0)
(
    input  ACLK,
    input  ARESETn,
    output master_AWVALID,
    output [((AXI_ADDRESS_WIDTH) - 1):0]  master_AWADDR,
    output [3:0] master_AWLEN,
    output [2:0] master_AWSIZE,
    output [1:0] master_AWBURST,
    output [1:0] master_AWLOCK,
    output [3:0] master_AWCACHE,
    output [2:0] master_AWPROT,
    output [((AXI_ID_WIDTH) - 1):0]  master_AWID,
    input  master_AWREADY,
    output [7:0] master_AWUSER,
    output master_ARVALID,
    output [((AXI_ADDRESS_WIDTH) - 1):0]  master_ARADDR,
    output [3:0] master_ARLEN,
    output [2:0] master_ARSIZE,
    output [1:0] master_ARBURST,
    output [1:0] master_ARLOCK,
    output [3:0] master_ARCACHE,
    output [2:0] master_ARPROT,
    output [((AXI_ID_WIDTH) - 1):0]  master_ARID,
    input  master_ARREADY,
    output [7:0] master_ARUSER,
    input  master_RVALID,
    input  master_RLAST,
    input  [((AXI_RDATA_WIDTH) - 1):0]  master_RDATA,
    input  [1:0] master_RRESP,
    input  [((AXI_ID_WIDTH) - 1):0]  master_RID,
    output master_RREADY,
    output master_WVALID,
    output master_WLAST,
    output [((AXI_WDATA_WIDTH) - 1):0]  master_WDATA,
    output [(((AXI_WDATA_WIDTH / 8)) - 1):0]  master_WSTRB,
    output [((AXI_ID_WIDTH) - 1):0]  master_WID,
    input  master_WREADY,
    input  master_BVALID,
    input  [1:0] master_BRESP,
    input  [((AXI_ID_WIDTH) - 1):0]  master_BID,
    output master_BREADY,
    input  slave_AWVALID,
    input  [((AXI_ADDRESS_WIDTH) - 1):0]  slave_AWADDR,
    input  [3:0] slave_AWLEN,
    input  [2:0] slave_AWSIZE,
    input  [1:0] slave_AWBURST,
    input  [1:0] slave_AWLOCK,
    input  [3:0] slave_AWCACHE,
    input  [2:0] slave_AWPROT,
    input  [((AXI_ID_WIDTH) - 1):0]  slave_AWID,
    output slave_AWREADY,
    input  [7:0] slave_AWUSER,
    input  slave_ARVALID,
    input  [((AXI_ADDRESS_WIDTH) - 1):0]  slave_ARADDR,
    input  [3:0] slave_ARLEN,
    input  [2:0] slave_ARSIZE,
    input  [1:0] slave_ARBURST,
    input  [1:0] slave_ARLOCK,
    input  [3:0] slave_ARCACHE,
    input  [2:0] slave_ARPROT,
    input  [((AXI_ID_WIDTH) - 1):0]  slave_ARID,
    output slave_ARREADY,
    input  [7:0] slave_ARUSER,
    output slave_RVALID,
    output slave_RLAST,
    output [((AXI_RDATA_WIDTH) - 1):0]  slave_RDATA,
    output [1:0] slave_RRESP,
    output [((AXI_ID_WIDTH) - 1):0]  slave_RID,
    input  slave_RREADY,
    input  slave_WVALID,
    input  slave_WLAST,
    input  [((AXI_WDATA_WIDTH) - 1):0]  slave_WDATA,
    input  [(((AXI_WDATA_WIDTH / 8)) - 1):0]  slave_WSTRB,
    input  [((AXI_ID_WIDTH) - 1):0]  slave_WID,
    output slave_WREADY,
    output slave_BVALID,
    output [1:0] slave_BRESP,
    output [((AXI_ID_WIDTH) - 1):0]  slave_BID,
    input  slave_BREADY
);

`ifdef MODEL_TECH
  `ifdef _MGC_VIP_VHDL_INTERFACE
    `include "mgc_axi_inline_monitor.mti.svp"
  `endif
`endif

    assign master_AWVALID        = slave_AWVALID;
    assign master_AWADDR         = slave_AWADDR;
    assign master_AWLEN          = slave_AWLEN;
    assign master_AWSIZE         = slave_AWSIZE;
    assign master_AWBURST        = slave_AWBURST;
    assign master_AWLOCK         = slave_AWLOCK;
    assign master_AWCACHE        = slave_AWCACHE;
    assign master_AWPROT         = slave_AWPROT;
    assign master_AWID           = slave_AWID;
    assign slave_AWREADY         = master_AWREADY;
    assign master_AWUSER         = slave_AWUSER;
    assign master_ARVALID        = slave_ARVALID;
    assign master_ARADDR         = slave_ARADDR;
    assign master_ARLEN          = slave_ARLEN;
    assign master_ARSIZE         = slave_ARSIZE;
    assign master_ARBURST        = slave_ARBURST;
    assign master_ARLOCK         = slave_ARLOCK;
    assign master_ARCACHE        = slave_ARCACHE;
    assign master_ARPROT         = slave_ARPROT;
    assign master_ARID           = slave_ARID;
    assign slave_ARREADY         = master_ARREADY;
    assign master_ARUSER         = slave_ARUSER;
    assign slave_RVALID          = master_RVALID;
    assign slave_RLAST           = master_RLAST;
    assign slave_RDATA           = master_RDATA;
    assign slave_RRESP           = master_RRESP;
    assign slave_RID             = master_RID;
    assign master_RREADY         = slave_RREADY;
    assign master_WVALID         = slave_WVALID;
    assign master_WLAST          = slave_WLAST;
    assign master_WDATA          = slave_WDATA;
    assign master_WSTRB          = slave_WSTRB;
    assign master_WID            = slave_WID;
    assign slave_WREADY          = master_WREADY;
    assign slave_BVALID          = master_BVALID;
    assign slave_BRESP           = master_BRESP;
    assign slave_BID             = master_BID;
    assign master_BREADY         = slave_BREADY;

    mgc_axi_monitor #(AXI_ADDRESS_WIDTH, AXI_RDATA_WIDTH, AXI_WDATA_WIDTH, AXI_ID_WIDTH, index)  mgc_axi_monitor_0
    (
        .ACLK      ( ACLK ),
        .ARESETn   ( ARESETn ),
        .AWVALID   ( slave_AWVALID ),
        .AWADDR    ( slave_AWADDR ),
        .AWLEN     ( slave_AWLEN ),
        .AWSIZE    ( slave_AWSIZE ),
        .AWBURST   ( slave_AWBURST ),
        .AWLOCK    ( slave_AWLOCK ),
        .AWCACHE   ( slave_AWCACHE ),
        .AWPROT    ( slave_AWPROT ),
        .AWID      ( slave_AWID ),
        .AWREADY   ( master_AWREADY ),
        .AWUSER    ( slave_AWUSER ),
        .ARVALID   ( slave_ARVALID ),
        .ARADDR    ( slave_ARADDR ),
        .ARLEN     ( slave_ARLEN ),
        .ARSIZE    ( slave_ARSIZE ),
        .ARBURST   ( slave_ARBURST ),
        .ARLOCK    ( slave_ARLOCK ),
        .ARCACHE   ( slave_ARCACHE ),
        .ARPROT    ( slave_ARPROT ),
        .ARID      ( slave_ARID ),
        .ARREADY   ( master_ARREADY ),
        .ARUSER    ( slave_ARUSER ),
        .RVALID    ( master_RVALID ),
        .RLAST     ( master_RLAST ),
        .RDATA     ( master_RDATA ),
        .RRESP     ( master_RRESP ),
        .RID       ( master_RID ),
        .RREADY    ( slave_RREADY ),
        .WVALID    ( slave_WVALID ),
        .WLAST     ( slave_WLAST ),
        .WDATA     ( slave_WDATA ),
        .WSTRB     ( slave_WSTRB ),
        .WID       ( slave_WID ),
        .WREADY    ( master_WREADY ),
        .BVALID    ( master_BVALID ),
        .BRESP     ( master_BRESP ),
        .BID       ( master_BID ),
        .BREADY    ( slave_BREADY )
    );

endinterface
