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

// Title: axi4_inline_monitor
//

// import package for the axi4 interface
import mgc_axi4_pkg::*;

interface mgc_axi4_inline_monitor #(int AXI4_ADDRESS_WIDTH = 64, int AXI4_RDATA_WIDTH = 1024, int AXI4_WDATA_WIDTH = 1024, int AXI4_ID_WIDTH = 18, int AXI4_USER_WIDTH = 8, int AXI4_REGION_MAP_SIZE = 16, int index = 0)
(
    input  ACLK,
    input  ARESETn,
    output master_AWVALID,
    output [((AXI4_ADDRESS_WIDTH) - 1):0]  master_AWADDR,
    output [2:0] master_AWPROT,
    output [3:0] master_AWREGION,
    output [7:0] master_AWLEN,
    output [2:0] master_AWSIZE,
    output [1:0] master_AWBURST,
    output master_AWLOCK,
    output [3:0] master_AWCACHE,
    output [3:0] master_AWQOS,
    output [((AXI4_ID_WIDTH) - 1):0]  master_AWID,
    output [((AXI4_USER_WIDTH) - 1):0]  master_AWUSER,
    input  master_AWREADY,
    output master_ARVALID,
    output [((AXI4_ADDRESS_WIDTH) - 1):0]  master_ARADDR,
    output [2:0] master_ARPROT,
    output [3:0] master_ARREGION,
    output [7:0] master_ARLEN,
    output [2:0] master_ARSIZE,
    output [1:0] master_ARBURST,
    output master_ARLOCK,
    output [3:0] master_ARCACHE,
    output [3:0] master_ARQOS,
    output [((AXI4_ID_WIDTH) - 1):0]  master_ARID,
    output [((AXI4_USER_WIDTH) - 1):0]  master_ARUSER,
    input  master_ARREADY,
    input  master_RVALID,
    input  [((AXI4_RDATA_WIDTH) - 1):0]  master_RDATA,
    input  [1:0] master_RRESP,
    input  master_RLAST,
    input  [((AXI4_ID_WIDTH) - 1):0]  master_RID,
    output master_RREADY,
    output master_WVALID,
    output [((AXI4_WDATA_WIDTH) - 1):0]  master_WDATA,
    output [(((AXI4_WDATA_WIDTH / 8)) - 1):0]  master_WSTRB,
    output master_WLAST,
    input  master_WREADY,
    input  master_BVALID,
    input  [1:0] master_BRESP,
    input  [((AXI4_ID_WIDTH) - 1):0]  master_BID,
    output master_BREADY,
    input  slave_AWVALID,
    input  [((AXI4_ADDRESS_WIDTH) - 1):0]  slave_AWADDR,
    input  [2:0] slave_AWPROT,
    input  [3:0] slave_AWREGION,
    input  [7:0] slave_AWLEN,
    input  [2:0] slave_AWSIZE,
    input  [1:0] slave_AWBURST,
    input  slave_AWLOCK,
    input  [3:0] slave_AWCACHE,
    input  [3:0] slave_AWQOS,
    input  [((AXI4_ID_WIDTH) - 1):0]  slave_AWID,
    input  [((AXI4_USER_WIDTH) - 1):0]  slave_AWUSER,
    output slave_AWREADY,
    input  slave_ARVALID,
    input  [((AXI4_ADDRESS_WIDTH) - 1):0]  slave_ARADDR,
    input  [2:0] slave_ARPROT,
    input  [3:0] slave_ARREGION,
    input  [7:0] slave_ARLEN,
    input  [2:0] slave_ARSIZE,
    input  [1:0] slave_ARBURST,
    input  slave_ARLOCK,
    input  [3:0] slave_ARCACHE,
    input  [3:0] slave_ARQOS,
    input  [((AXI4_ID_WIDTH) - 1):0]  slave_ARID,
    input  [((AXI4_USER_WIDTH) - 1):0]  slave_ARUSER,
    output slave_ARREADY,
    output slave_RVALID,
    output [((AXI4_RDATA_WIDTH) - 1):0]  slave_RDATA,
    output [1:0] slave_RRESP,
    output slave_RLAST,
    output [((AXI4_ID_WIDTH) - 1):0]  slave_RID,
    input  slave_RREADY,
    input  slave_WVALID,
    input  [((AXI4_WDATA_WIDTH) - 1):0]  slave_WDATA,
    input  [(((AXI4_WDATA_WIDTH / 8)) - 1):0]  slave_WSTRB,
    input  slave_WLAST,
    output slave_WREADY,
    output slave_BVALID,
    output [1:0] slave_BRESP,
    output [((AXI4_ID_WIDTH) - 1):0]  slave_BID,
    input  slave_BREADY
);

`ifdef MODEL_TECH
  `ifdef _MGC_VIP_VHDL_INTERFACE
    `include "mgc_axi4_inline_monitor.mti.svp"
  `endif
`endif

    assign master_AWVALID        = slave_AWVALID;
    assign master_AWADDR         = slave_AWADDR;
    assign master_AWPROT         = slave_AWPROT;
    assign master_AWREGION       = slave_AWREGION;
    assign master_AWLEN          = slave_AWLEN;
    assign master_AWSIZE         = slave_AWSIZE;
    assign master_AWBURST        = slave_AWBURST;
    assign master_AWLOCK         = slave_AWLOCK;
    assign master_AWCACHE        = slave_AWCACHE;
    assign master_AWQOS          = slave_AWQOS;
    assign master_AWID           = slave_AWID;
    assign master_AWUSER         = slave_AWUSER;
    assign slave_AWREADY         = master_AWREADY;
    assign master_ARVALID        = slave_ARVALID;
    assign master_ARADDR         = slave_ARADDR;
    assign master_ARPROT         = slave_ARPROT;
    assign master_ARREGION       = slave_ARREGION;
    assign master_ARLEN          = slave_ARLEN;
    assign master_ARSIZE         = slave_ARSIZE;
    assign master_ARBURST        = slave_ARBURST;
    assign master_ARLOCK         = slave_ARLOCK;
    assign master_ARCACHE        = slave_ARCACHE;
    assign master_ARQOS          = slave_ARQOS;
    assign master_ARID           = slave_ARID;
    assign master_ARUSER         = slave_ARUSER;
    assign slave_ARREADY         = master_ARREADY;
    assign slave_RVALID          = master_RVALID;
    assign slave_RDATA           = master_RDATA;
    assign slave_RRESP           = master_RRESP;
    assign slave_RLAST           = master_RLAST;
    assign slave_RID             = master_RID;
    assign master_RREADY         = slave_RREADY;
    assign master_WVALID         = slave_WVALID;
    assign master_WDATA          = slave_WDATA;
    assign master_WSTRB          = slave_WSTRB;
    assign master_WLAST          = slave_WLAST;
    assign slave_WREADY          = master_WREADY;
    assign slave_BVALID          = master_BVALID;
    assign slave_BRESP           = master_BRESP;
    assign slave_BID             = master_BID;
    assign master_BREADY         = slave_BREADY;

    mgc_axi4_monitor #(AXI4_ADDRESS_WIDTH, AXI4_RDATA_WIDTH, AXI4_WDATA_WIDTH, AXI4_ID_WIDTH, AXI4_USER_WIDTH, AXI4_REGION_MAP_SIZE, index)  mgc_axi4_monitor_0
    (
        .ACLK      ( ACLK ),
        .ARESETn   ( ARESETn ),
        .AWVALID   ( slave_AWVALID ),
        .AWADDR    ( slave_AWADDR ),
        .AWPROT    ( slave_AWPROT ),
        .AWREGION  ( slave_AWREGION ),
        .AWLEN     ( slave_AWLEN ),
        .AWSIZE    ( slave_AWSIZE ),
        .AWBURST   ( slave_AWBURST ),
        .AWLOCK    ( slave_AWLOCK ),
        .AWCACHE   ( slave_AWCACHE ),
        .AWQOS     ( slave_AWQOS ),
        .AWID      ( slave_AWID ),
        .AWUSER    ( slave_AWUSER ),
        .AWREADY   ( master_AWREADY ),
        .ARVALID   ( slave_ARVALID ),
        .ARADDR    ( slave_ARADDR ),
        .ARPROT    ( slave_ARPROT ),
        .ARREGION  ( slave_ARREGION ),
        .ARLEN     ( slave_ARLEN ),
        .ARSIZE    ( slave_ARSIZE ),
        .ARBURST   ( slave_ARBURST ),
        .ARLOCK    ( slave_ARLOCK ),
        .ARCACHE   ( slave_ARCACHE ),
        .ARQOS     ( slave_ARQOS ),
        .ARID      ( slave_ARID ),
        .ARUSER    ( slave_ARUSER ),
        .ARREADY   ( master_ARREADY ),
        .RVALID    ( master_RVALID ),
        .RDATA     ( master_RDATA ),
        .RRESP     ( master_RRESP ),
        .RLAST     ( master_RLAST ),
        .RID       ( master_RID ),
        .RREADY    ( slave_RREADY ),
        .WVALID    ( slave_WVALID ),
        .WDATA     ( slave_WDATA ),
        .WSTRB     ( slave_WSTRB ),
        .WLAST     ( slave_WLAST ),
        .WREADY    ( master_WREADY ),
        .BVALID    ( master_BVALID ),
        .BRESP     ( master_BRESP ),
        .BID       ( master_BID ),
        .BREADY    ( slave_BREADY )
    );

endinterface
