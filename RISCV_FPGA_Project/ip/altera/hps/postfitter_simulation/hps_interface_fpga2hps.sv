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


module cyclonev_hps_interface_fpga2hps
#(
	parameter data_width	= 64
)(
   input  wire [1:0]    port_size_config,
   input  wire			   clk,
   input  wire [7:0]    awid,
   input  wire [31:0]   awaddr,
   input  wire [3:0]    awlen,
   input  wire [2:0]    awsize,
   input  wire [1:0]    awburst,
   input  wire [1:0]    awlock,
   input  wire [3:0]    awcache,
   input  wire [2:0]    awprot,
   input  wire	         awvalid,
   output wire          awready,
	input  wire [4:0]    awuser,
   input  wire [7:0]    wid,
   input  wire [127:0]  wdata,
   input  wire [15:0]   wstrb, 
   input  wire          wlast,
   input  wire          wvalid,
   output wire          wready,
   output wire [7:0]    bid,
   output wire [1:0]    bresp,
   output wire          bvalid,
   input  wire          bready,
   input  wire [7:0]    arid,
   input  wire [31:0]   araddr,
   input  wire [3:0]    arlen,
   input  wire [2:0]    arsize,
   input  wire [1:0]    arburst,
   input  wire [1:0]    arlock,
   input  wire [3:0]    arcache,
   input  wire [2:0]    arprot,
   input  wire          arvalid,
   output wire          arready,
	input  wire [4:0]    aruser,
   output wire [7:0]    rid,
   output wire [127:0]  rdata,
   output wire [1:0]    rresp,
   output wire          rlast,
   output wire          rvalid,
   input  wire          rready
);
	
   logic                      resetn;
   logic [data_width-1:0]     rdata_temp;
   logic [data_width-1:0]     wdata_temp;
   logic [(data_width/8)-1:0] wstrb_temp;
   
   assign rdata = (data_width == 128)? rdata_temp :
                   (data_width == 32)? {{96{1'b0}},rdata_temp} : {{64{1'b0}},rdata_temp};

   assign wdata_temp = (data_width == 128)? wdata :
                        (data_width == 32)? wdata[31:0] : wdata[63:0];
   
   assign wstrb_temp = (data_width == 128)? wstrb :
                        (data_width == 32)? wstrb[3:0] : wstrb[7:0];
   
   initial begin
      resetn = 1'b0;
      @(posedge clk);
      resetn = 1'b1;
   end
   
   mgc_axi_slave #(
      .AXI_ADDRESS_WIDTH(32),
      .AXI_WDATA_WIDTH(data_width),
      .AXI_RDATA_WIDTH(data_width),
      .AXI_ID_WIDTH(8)
   ) f2h_axi_slave (
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
     .AWUSER({3'b0,awuser}),
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
     .ARUSER({3'b0,aruser}),
     .RVALID(rvalid),
     .RLAST(rlast),
     .RDATA(rdata_temp),
     .RRESP(rresp),
     .RID(rid),
     .RREADY(rready),
     .WVALID(wvalid),
     .WLAST(wlast),
     .WDATA(wdata_temp),
     .WSTRB(wstrb_temp),
     .WID(wid),
     .WREADY(wready),
     .BVALID(bvalid),
     .BRESP(bresp),
     .BID(bid),
     .BREADY(bready)
   );

endmodule 

module arriav_hps_interface_fpga2hps
#(
	parameter data_width	= 64
)(
   input  wire [1:0]    port_size_config,
   input  wire			   clk,
   input  wire [7:0]    awid,
   input  wire [31:0]   awaddr,
   input  wire [3:0]    awlen,
   input  wire [2:0]    awsize,
   input  wire [1:0]    awburst,
   input  wire [1:0]    awlock,
   input  wire [3:0]    awcache,
   input  wire [2:0]    awprot,
   input  wire	         awvalid,
   output wire          awready,
	input  wire [4:0]    awuser,
   input  wire [7:0]    wid,
   input  wire [127:0]  wdata,
   input  wire [15:0]   wstrb, 
   input  wire          wlast,
   input  wire          wvalid,
   output wire          wready,
   output wire [7:0]    bid,
   output wire [1:0]    bresp,
   output wire          bvalid,
   input  wire          bready,
   input  wire [7:0]    arid,
   input  wire [31:0]   araddr,
   input  wire [3:0]    arlen,
   input  wire [2:0]    arsize,
   input  wire [1:0]    arburst,
   input  wire [1:0]    arlock,
   input  wire [3:0]    arcache,
   input  wire [2:0]    arprot,
   input  wire          arvalid,
   output wire          arready,
	input  wire [4:0]    aruser,
   output wire [7:0]    rid,
   output wire [127:0]  rdata,
   output wire [1:0]    rresp,
   output wire          rlast,
   output wire          rvalid,
   input  wire          rready
);
	
   logic                      resetn;
   logic [data_width-1:0]     rdata_temp;
   logic [data_width-1:0]     wdata_temp;
   logic [(data_width/8)-1:0] wstrb_temp;
   
   assign rdata = (data_width == 128)? rdata_temp :
                   (data_width == 32)? {{96{1'b0}},rdata_temp} : {{64{1'b0}},rdata_temp};

   assign wdata_temp = (data_width == 128)? wdata :
                        (data_width == 32)? wdata[31:0] : wdata[63:0];
   
   assign wstrb_temp = (data_width == 128)? wstrb :
                        (data_width == 32)? wstrb[3:0] : wstrb[7:0];
   
   initial begin
      resetn = 1'b0;
      @(posedge clk);
      resetn = 1'b1;
   end
   
   mgc_axi_slave #(
      .AXI_ADDRESS_WIDTH(32),
      .AXI_WDATA_WIDTH(data_width),
      .AXI_RDATA_WIDTH(data_width),
      .AXI_ID_WIDTH(8)
   ) f2h_axi_slave (
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
     .AWUSER({3'b0,awuser}),
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
     .ARUSER({3'b0,aruser}),
     .RVALID(rvalid),
     .RLAST(rlast),
     .RDATA(rdata_temp),
     .RRESP(rresp),
     .RID(rid),
     .RREADY(rready),
     .WVALID(wvalid),
     .WLAST(wlast),
     .WDATA(wdata_temp),
     .WSTRB(wstrb_temp),
     .WID(wid),
     .WREADY(wready),
     .BVALID(bvalid),
     .BRESP(bresp),
     .BID(bid),
     .BREADY(bready)
   );

endmodule 