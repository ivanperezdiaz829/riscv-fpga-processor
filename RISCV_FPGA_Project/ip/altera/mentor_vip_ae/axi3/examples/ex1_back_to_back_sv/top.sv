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

    parameter AXI_ADDRESS_WIDTH    = 32;
    parameter AXI_RDATA_WIDTH      = 32;
    parameter AXI_WDATA_WIDTH      = 32;
    parameter AXI_ID_WIDTH         = 18;

    reg ACLK = 0;
    reg ARESETn = 0;
    
    wire  AWVALID                                     ;
    wire  [((AXI_ADDRESS_WIDTH) - 1):0]  AWADDR       ;
    wire  [3:0] AWREGION                              ;
    wire  [3:0] AWLEN                                 ;
    wire  [2:0] AWSIZE                                ;
    wire  [1:0] AWBURST                               ;
    wire  [1:0] AWLOCK                                ;
    wire  [3:0] AWCACHE                               ;
    wire  [2:0] AWPROT                                ;
    wire  [((AXI_ID_WIDTH) - 1):0]  AWID              ;
    wire  AWREADY                                     ;
    wire  [7:0]  AWUSER                               ;
    wire  ARVALID                                     ;
    wire  [((AXI_ADDRESS_WIDTH) - 1):0]  ARADDR       ;
    wire  [3:0] ARREGION                              ;
    wire  [3:0] ARLEN                                 ;
    wire  [2:0] ARSIZE                                ;
    wire  [1:0] ARBURST                               ;
    wire  [1:0] ARLOCK                                ;
    wire  [3:0] ARCACHE                               ;
    wire  [2:0] ARPROT                                ;
    wire  [((AXI_ID_WIDTH) - 1):0]  ARID              ;
    wire  [7:0]  ARUSER                               ;
    wire  ARREADY                                     ;
    wire  RVALID                                      ;
    wire  [((AXI_RDATA_WIDTH) - 1):0]  RDATA          ;
    wire  [1:0] RRESP                                 ;
    wire  RLAST                                       ;
    wire  [((AXI_ID_WIDTH) - 1):0]  RID               ;
    wire  RREADY                                      ;
    wire  WVALID                                      ;
    wire  [((AXI_WDATA_WIDTH) - 1):0]  WDATA          ;
    wire  [(((AXI_WDATA_WIDTH / 8)) - 1):0]  WSTRB    ;
    wire  [((AXI_ID_WIDTH) - 1):0]  WID               ;
    wire  WLAST                                       ;
    wire  WREADY                                      ;
    wire  BVALID                                      ;
    wire  [1:0] BRESP                                 ;
    wire  [((AXI_ID_WIDTH) - 1):0]  BID               ;
    wire  BREADY                                      ;


    mgc_axi_master #(AXI_ADDRESS_WIDTH, AXI_RDATA_WIDTH, AXI_WDATA_WIDTH, AXI_ID_WIDTH) bfm_master
    (
        .ACLK(ACLK), .ARESETn(ARESETn), 
        .AWVALID(AWVALID), .AWADDR(AWADDR), .AWLEN(AWLEN), .AWSIZE(AWSIZE), .AWBURST(AWBURST), .AWLOCK(AWLOCK), .AWCACHE(AWCACHE), .AWPROT(AWPROT), .AWID(AWID), .AWREADY(AWREADY), .AWUSER(AWUSER),
        .ARVALID(ARVALID), .ARADDR(ARADDR), .ARLEN(ARLEN), .ARSIZE(ARSIZE), .ARBURST(ARBURST), .ARLOCK(ARLOCK), .ARCACHE(ARCACHE), .ARPROT(ARPROT), .ARID(ARID), .ARREADY(ARREADY), .ARUSER(ARUSER),
        .RVALID(RVALID), .RLAST(RLAST), .RDATA(RDATA), .RRESP(RRESP), .RID(RID), .RREADY(RREADY),
        .WVALID(WVALID), .WLAST(WLAST), .WDATA(WDATA), .WSTRB(WSTRB), .WID(WID), .WREADY(WREADY),
        .BVALID(BVALID), .BRESP(BRESP), .BID(BID), .BREADY(BREADY)
    );
                                                                                                                     
    mgc_axi_slave #(AXI_ADDRESS_WIDTH, AXI_RDATA_WIDTH, AXI_WDATA_WIDTH, AXI_ID_WIDTH) bfm_slave
    (
        .ACLK(ACLK), .ARESETn(ARESETn), 
        .AWVALID(AWVALID), .AWADDR(AWADDR), .AWLEN(AWLEN), .AWSIZE(AWSIZE), .AWBURST(AWBURST), .AWLOCK(AWLOCK), .AWCACHE(AWCACHE), .AWPROT(AWPROT), .AWID(AWID), .AWREADY(AWREADY), .AWUSER(AWUSER),
        .ARVALID(ARVALID), .ARADDR(ARADDR), .ARLEN(ARLEN), .ARSIZE(ARSIZE), .ARBURST(ARBURST), .ARLOCK(ARLOCK), .ARCACHE(ARCACHE), .ARPROT(ARPROT), .ARID(ARID), .ARREADY(ARREADY), .ARUSER(ARUSER),
        .RVALID(RVALID), .RLAST(RLAST), .RDATA(RDATA), .RRESP(RRESP), .RID(RID), .RREADY(RREADY),
        .WVALID(WVALID), .WLAST(WLAST), .WDATA(WDATA), .WSTRB(WSTRB), .WID(WID), .WREADY(WREADY),
        .BVALID(BVALID), .BRESP(BRESP), .BID(BID), .BREADY(BREADY)
    );

    mgc_axi_monitor #(AXI_ADDRESS_WIDTH, AXI_RDATA_WIDTH, AXI_WDATA_WIDTH, AXI_ID_WIDTH) bfm_monitor
    (
        .ACLK(ACLK), .ARESETn(ARESETn), 
        .AWVALID(AWVALID), .AWADDR(AWADDR), .AWLEN(AWLEN), .AWSIZE(AWSIZE), .AWBURST(AWBURST), .AWLOCK(AWLOCK), .AWCACHE(AWCACHE), .AWPROT(AWPROT), .AWID(AWID), .AWREADY(AWREADY), .AWUSER(AWUSER),
        .ARVALID(ARVALID), .ARADDR(ARADDR), .ARLEN(ARLEN), .ARSIZE(ARSIZE), .ARBURST(ARBURST), .ARLOCK(ARLOCK), .ARCACHE(ARCACHE), .ARPROT(ARPROT), .ARID(ARID), .ARREADY(ARREADY), .ARUSER(ARUSER),
        .RVALID(RVALID), .RLAST(RLAST), .RDATA(RDATA), .RRESP(RRESP), .RID(RID), .RREADY(RREADY),
        .WVALID(WVALID), .WLAST(WLAST), .WDATA(WDATA), .WSTRB(WSTRB), .WID(WID), .WREADY(WREADY),
        .BVALID(BVALID), .BRESP(BRESP), .BID(BID), .BREADY(BREADY)
    );

    master_test_program  #(AXI_ADDRESS_WIDTH, AXI_RDATA_WIDTH, AXI_WDATA_WIDTH, AXI_ID_WIDTH) u_master ( bfm_master );
    slave_test_program   #(AXI_ADDRESS_WIDTH, AXI_RDATA_WIDTH, AXI_WDATA_WIDTH, AXI_ID_WIDTH) u_slave  ( bfm_slave  );
    monitor_test_program #(AXI_ADDRESS_WIDTH, AXI_RDATA_WIDTH, AXI_WDATA_WIDTH, AXI_ID_WIDTH) u_monitor ( bfm_monitor );
 
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
