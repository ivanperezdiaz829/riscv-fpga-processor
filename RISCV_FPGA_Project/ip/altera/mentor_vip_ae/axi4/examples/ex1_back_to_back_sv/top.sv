// *****************************************************************************
//
// Copyright 2007-2013 Mentor Graphics Corporation
// All Rights Reserved.
//
// THIS WORK CONTAINS TRADE SECRET AND PROPRIETARY INFORMATION WHICH IS THE PROPERTY OF
// MENTOR GRAPHICS CORPORATION OR ITS LICENSORS AND IS SUBJECT TO LICENSE TERMS.
//
// *****************************************************************************

`timescale 1ns/1ns

module top ();

    parameter AXI4_ADDRESS_WIDTH    = 32;
    parameter AXI4_RDATA_WIDTH      = 32;
    parameter AXI4_WDATA_WIDTH      = 32;
    parameter AXI4_ID_WIDTH         = 18;
    parameter AXI4_USER_WIDTH       = 8;
    parameter AXI4_REGION_MAP_SIZE  = 16;

    reg ACLK = 0;
    reg ARESETn = 0;
    
    wire                                      AWVALID;
    wire  [((AXI4_ADDRESS_WIDTH) - 1):0]      AWADDR;
    wire  [2:0]                               AWPROT;
    wire  [3:0]                               AWREGION;
    wire  [7:0]                               AWLEN;
    wire  [2:0]                               AWSIZE;
    wire  [1:0]                               AWBURST;
    wire                                      AWLOCK;
    wire  [3:0]                               AWCACHE;
    wire  [3:0]                               AWQOS;
    wire  [((AXI4_ID_WIDTH) - 1):0]           AWID;
    wire [((AXI4_USER_WIDTH) - 1):0]          AWUSER;
    wire                                      AWREADY;
    wire                                      ARVALID;
    wire  [((AXI4_ADDRESS_WIDTH) - 1):0]      ARADDR;
    wire  [2:0]                               ARPROT;
    wire  [3:0]                               ARREGION;
    wire  [7:0]                               ARLEN;
    wire  [2:0]                               ARSIZE;
    wire  [1:0]                               ARBURST;
    wire                                      ARLOCK;
    wire  [3:0]                               ARCACHE;
    wire [3:0]                                ARQOS;
    wire  [((AXI4_ID_WIDTH) - 1):0]           ARID;
    wire [((AXI4_USER_WIDTH) - 1):0]          ARUSER;
    wire                                      ARREADY;
    wire                                      RVALID;
    wire  [((AXI4_RDATA_WIDTH) - 1):0]        RDATA;
    wire  [1:0]                               RRESP;
    wire                                      RLAST;
    wire  [((AXI4_ID_WIDTH) - 1):0]           RID;
    wire                                      RREADY;
    wire                                      WVALID;
    wire  [((AXI4_WDATA_WIDTH) - 1):0]        WDATA;
    wire  [(((AXI4_WDATA_WIDTH / 8)) - 1):0]  WSTRB;
    wire                                      WLAST;
    wire                                      WREADY;
    wire                                      BVALID;
    wire  [1:0]                               BRESP;
    wire  [((AXI4_ID_WIDTH) - 1):0]           BID;
    wire                                      BREADY;


    mgc_axi4_master #(AXI4_ADDRESS_WIDTH, AXI4_RDATA_WIDTH, AXI4_WDATA_WIDTH, AXI4_ID_WIDTH, AXI4_USER_WIDTH, AXI4_REGION_MAP_SIZE) bfm_master
    (
        .ACLK(ACLK), .ARESETn(ARESETn), 
        .AWVALID(AWVALID), .AWADDR(AWADDR), .AWLEN(AWLEN), .AWSIZE(AWSIZE), .AWBURST(AWBURST), .AWLOCK(AWLOCK), .AWCACHE(AWCACHE), .AWPROT(AWPROT), .AWID(AWID), .AWREADY(AWREADY), .AWUSER(AWUSER), .AWREGION(AWREGION), .AWQOS(AWQOS),
        .ARVALID(ARVALID), .ARADDR(ARADDR), .ARLEN(ARLEN), .ARSIZE(ARSIZE), .ARBURST(ARBURST), .ARLOCK(ARLOCK), .ARCACHE(ARCACHE), .ARPROT(ARPROT), .ARID(ARID), .ARREADY(ARREADY), .ARUSER(ARUSER), .ARREGION(ARREGION), .ARQOS(ARQOS),
        .RVALID(RVALID), .RLAST(RLAST), .RDATA(RDATA), .RRESP(RRESP), .RID(RID), .RREADY(RREADY),
        .WVALID(WVALID), .WLAST(WLAST), .WDATA(WDATA), .WSTRB(WSTRB), .WREADY(WREADY),
        .BVALID(BVALID), .BRESP(BRESP), .BID(BID), .BREADY(BREADY)
    );
                                                                                                                     
    mgc_axi4_slave #(AXI4_ADDRESS_WIDTH, AXI4_RDATA_WIDTH, AXI4_WDATA_WIDTH, AXI4_ID_WIDTH, AXI4_USER_WIDTH, AXI4_REGION_MAP_SIZE) bfm_slave
    (
        .ACLK(ACLK), .ARESETn(ARESETn), 
        .AWVALID(AWVALID), .AWADDR(AWADDR), .AWLEN(AWLEN), .AWSIZE(AWSIZE), .AWBURST(AWBURST), .AWLOCK(AWLOCK), .AWCACHE(AWCACHE), .AWPROT(AWPROT), .AWID(AWID), .AWREADY(AWREADY), .AWUSER(AWUSER), .AWREGION(AWREGION), .AWQOS(AWQOS),
        .ARVALID(ARVALID), .ARADDR(ARADDR), .ARLEN(ARLEN), .ARSIZE(ARSIZE), .ARBURST(ARBURST), .ARLOCK(ARLOCK), .ARCACHE(ARCACHE), .ARPROT(ARPROT), .ARID(ARID), .ARREADY(ARREADY), .ARUSER(ARUSER), .ARREGION(ARREGION), .ARQOS(ARQOS),
        .RVALID(RVALID), .RLAST(RLAST), .RDATA(RDATA), .RRESP(RRESP), .RID(RID), .RREADY(RREADY),
        .WVALID(WVALID), .WLAST(WLAST), .WDATA(WDATA), .WSTRB(WSTRB), .WREADY(WREADY),
        .BVALID(BVALID), .BRESP(BRESP), .BID(BID), .BREADY(BREADY)
    );

    mgc_axi4_monitor #(AXI4_ADDRESS_WIDTH, AXI4_RDATA_WIDTH, AXI4_WDATA_WIDTH, AXI4_ID_WIDTH, AXI4_USER_WIDTH, AXI4_REGION_MAP_SIZE) bfm_monitor
    (
        .ACLK(ACLK), .ARESETn(ARESETn), 
        .AWVALID(AWVALID), .AWADDR(AWADDR), .AWLEN(AWLEN), .AWSIZE(AWSIZE), .AWBURST(AWBURST), .AWLOCK(AWLOCK), .AWCACHE(AWCACHE), .AWPROT(AWPROT), .AWID(AWID), .AWREADY(AWREADY), .AWUSER(AWUSER), .AWREGION(AWREGION), .AWQOS(AWQOS),
        .ARVALID(ARVALID), .ARADDR(ARADDR), .ARLEN(ARLEN), .ARSIZE(ARSIZE), .ARBURST(ARBURST), .ARLOCK(ARLOCK), .ARCACHE(ARCACHE), .ARPROT(ARPROT), .ARID(ARID), .ARREADY(ARREADY), .ARUSER(ARUSER), .ARREGION(ARREGION), .ARQOS(ARQOS),
        .RVALID(RVALID), .RLAST(RLAST), .RDATA(RDATA), .RRESP(RRESP), .RID(RID), .RREADY(RREADY),
        .WVALID(WVALID), .WLAST(WLAST), .WDATA(WDATA), .WSTRB(WSTRB), .WREADY(WREADY),
        .BVALID(BVALID), .BRESP(BRESP), .BID(BID), .BREADY(BREADY)
    );

    master_test_program  #(AXI4_ADDRESS_WIDTH, AXI4_RDATA_WIDTH, AXI4_WDATA_WIDTH, AXI4_ID_WIDTH, AXI4_USER_WIDTH, AXI4_REGION_MAP_SIZE) u_master  (bfm_master);
    slave_test_program   #(AXI4_ADDRESS_WIDTH, AXI4_RDATA_WIDTH, AXI4_WDATA_WIDTH, AXI4_ID_WIDTH, AXI4_USER_WIDTH, AXI4_REGION_MAP_SIZE) u_slave   (bfm_slave);
    monitor_test_program #(AXI4_ADDRESS_WIDTH, AXI4_RDATA_WIDTH, AXI4_WDATA_WIDTH, AXI4_ID_WIDTH, AXI4_USER_WIDTH, AXI4_REGION_MAP_SIZE) u_monitor (bfm_monitor);
 
    initial
    begin
        ARESETn = 0;
        #100
        ARESETn = 1;
    end
    
    always
    begin
        #5

        ACLK = ~ACLK;
    end

endmodule
