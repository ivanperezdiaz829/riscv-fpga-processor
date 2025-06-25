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


module cyclonev_hps_interface_hps2fpga_light_weight (
   input  wire        clk,
   output wire [11:0] awid,
   output wire [20:0] awaddr,
   output wire [3:0]  awlen,
   output wire [2:0]  awsize,
   output wire [1:0]  awburst,
   output wire [1:0]  awlock,
   output wire [3:0]  awcache,
   output wire [2:0]  awprot,
   output wire        awvalid,
   input  wire        awready,
   output wire [11:0] wid,
   output wire [31:0] wdata,
   output wire [3:0]  wstrb,
   output wire        wlast,
   output wire        wvalid,
   input  wire        wready,
   input  wire [11:0] bid,
   input  wire [1:0]  bresp,
   input  wire        bvalid,
   output wire        bready,
   output wire [11:0] arid,
   output wire [20:0] araddr,
   output wire [3:0]  arlen,
   output wire [2:0]  arsize,
   output wire [1:0]  arburst,
   output wire [1:0]  arlock,
   output wire [3:0]  arcache,
   output wire [2:0]  arprot,
   output wire        arvalid,
   input  wire        arready,
   input  wire [11:0] rid,
   input  wire [31:0] rdata,
   input  wire [1:0]  rresp,
   input  wire        rlast,
   input  wire        rvalid,
   output wire        rready
);
   logic resetn;
   
   initial begin
      resetn = 1'b0;
      @(posedge clk);
      resetn = 1'b1;
   end
   
   mgc_axi_master #(
      .AXI_ADDRESS_WIDTH(21),
      .AXI_RDATA_WIDTH(32),
      .AXI_WDATA_WIDTH(32),
      .AXI_ID_WIDTH(12)
   ) h2f_lw_axi_master (
     .ACLK(clk),
     .ARESETn(resetn), 
     .AWVALID(awvalid),
     .AWADDR(awaddr),
     .AWLEN(awlen),
     .AWSIZE(awsize),
     .AWBURST(awburst),
     .AWLOCK(awlock),
     .AWCACHE(awcache),
     .AWPROT(awprot),
     .AWID(awid),
     .AWREADY(awready),
     .AWUSER(),
     .ARVALID(arvalid),
     .ARADDR(araddr),
     .ARLEN(arlen),
     .ARSIZE(arsize),
     .ARBURST(arburst),
     .ARLOCK(arlock),
     .ARCACHE(arcache),
     .ARPROT(arprot),
     .ARID(arid),
     .ARREADY(arready),
     .ARUSER(),
     .RVALID(rvalid),
     .RLAST(rlast),
     .RDATA(rdata),
     .RRESP(rresp),
     .RID(rid),
     .RREADY(rready),
     .WVALID(wvalid),
     .WLAST(wlast),
     .WDATA(wdata),
     .WSTRB(wstrb),
     .WID(wid),
     .WREADY(wready),
     .BVALID(bvalid),
     .BRESP(bresp),
     .BID(bid),
     .BREADY(bready)
    );

endmodule 

module arriav_hps_interface_hps2fpga_light_weight (
   input  wire        clk,
   output wire [11:0] awid,
   output wire [20:0] awaddr,
   output wire [3:0]  awlen,
   output wire [2:0]  awsize,
   output wire [1:0]  awburst,
   output wire [1:0]  awlock,
   output wire [3:0]  awcache,
   output wire [2:0]  awprot,
   output wire        awvalid,
   input  wire        awready,
   output wire [11:0] wid,
   output wire [31:0] wdata,
   output wire [3:0]  wstrb,
   output wire        wlast,
   output wire        wvalid,
   input  wire        wready,
   input  wire [11:0] bid,
   input  wire [1:0]  bresp,
   input  wire        bvalid,
   output wire        bready,
   output wire [11:0] arid,
   output wire [20:0] araddr,
   output wire [3:0]  arlen,
   output wire [2:0]  arsize,
   output wire [1:0]  arburst,
   output wire [1:0]  arlock,
   output wire [3:0]  arcache,
   output wire [2:0]  arprot,
   output wire        arvalid,
   input  wire        arready,
   input  wire [11:0] rid,
   input  wire [31:0] rdata,
   input  wire [1:0]  rresp,
   input  wire        rlast,
   input  wire        rvalid,
   output wire        rready
);
   logic resetn;
   
   initial begin
      resetn = 1'b0;
      @(posedge clk);
      resetn = 1'b1;
   end
   
   mgc_axi_master #(
      .AXI_ADDRESS_WIDTH(21),
      .AXI_RDATA_WIDTH(32),
      .AXI_WDATA_WIDTH(32),
      .AXI_ID_WIDTH(12)
   ) h2f_lw_axi_master (
     .ACLK(clk),
     .ARESETn(resetn), 
     .AWVALID(awvalid),
     .AWADDR(awaddr),
     .AWLEN(awlen),
     .AWSIZE(awsize),
     .AWBURST(awburst),
     .AWLOCK(awlock),
     .AWCACHE(awcache),
     .AWPROT(awprot),
     .AWID(awid),
     .AWREADY(awready),
     .AWUSER(),
     .ARVALID(arvalid),
     .ARADDR(araddr),
     .ARLEN(arlen),
     .ARSIZE(arsize),
     .ARBURST(arburst),
     .ARLOCK(arlock),
     .ARCACHE(arcache),
     .ARPROT(arprot),
     .ARID(arid),
     .ARREADY(arready),
     .ARUSER(),
     .RVALID(rvalid),
     .RLAST(rlast),
     .RDATA(rdata),
     .RRESP(rresp),
     .RID(rid),
     .RREADY(rready),
     .WVALID(wvalid),
     .WLAST(wlast),
     .WDATA(wdata),
     .WSTRB(wstrb),
     .WID(wid),
     .WREADY(wready),
     .BVALID(bvalid),
     .BRESP(bresp),
     .BID(bid),
     .BREADY(bready)
    );

endmodule 