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


`timescale 1 ps / 1 ps
// altera message_off 10036
// Disabled message for rx_freqlocked unused warning
module alt_e100_pma_sv_bridge_caui4 #(
    parameter CAUI4_PMA_ADDR_PREFIX = 5'h01,    // 0x40-0x7f
    parameter PHY_ADDR_PREFIX = 10'h001,    // 0x40-0x7f
    parameter RECO_ADDR_PREFIX = 9'h001,    // 0x80-0xff
    parameter FAKE_TX_SKEW = 1'b0,            // skew the TX data for simulation
    parameter VARIANT = 3,                    // 1=>RX, 2=>TX, 3=> RX_AND_TX
	parameter en_synce_support = 0
)(
    input pma_arst,
    input clk_status,
    input clk_ref,
	input rx_clk_ref,
	input tx_clk_ref,

    // to high speed IO pins
    input [3:0] rx_datain,
    output [3:0] tx_dataout,
    
    // debug+status (async)
    output [3:0] tx_pll_lock,
    output [3:0] rx_cdr_lock,
    
    // 40 bit data words on clk_tx
    output clk_tx,
    input [1:0] err_inject,  // rising edge injects one bit error
    output tx_ready,
    input [128*4-1:0] tx_datain,
    
    // 40 bit data words on clk_rx
    output clk_rx,
    output rx_ready,
    output [128*4-1:0] rx_dataout,    
    
    // avalon_mm (on clk_status)
    input status_read,
    input status_write,
    input [15:0] status_addr,
    output [31:0] reco_readdata,
    output [31:0] phy_readdata0,
    output [31:0] phy_readdata1,
    output [31:0] phy_readdata2,
    output [31:0] phy_readdata3,
    input [31:0] status_writedata,
    output reco_readdata_valid,
    output phy_readdata_valid0,
    output phy_readdata_valid1,
    output phy_readdata_valid2,
    output phy_readdata_valid3,
    output out_busy,

    // additional ports for composed hw.tcl
    // gx
    output  clk_status_gx_0,
    output  pma_arst_gx_0,
    output    phy_mgmt_0_read, 
    output    phy_mgmt_0_write,
    output [8:0] phy_mgmt_0_address, //[10:0] 
    output [31:0] phy_mgmt_0_writedata,
    input    phy_mgmt_0_waitrequest,
    input  [31:0]  phy_mgmt_0_readdata,
    output   pll_inclk_0,
	output   cdr_ref_0_clk,
    input  rx_freqlocked_0,
    input  rx_is_lockedtodata_0,
    input  rx_clkout_0, 
    input pll_locked_0,// reset and status signals 
    input  tx_clkout_0 ,
    output [127:0] tx_parallel_data_0,
    input [127:0] rx_parallel_data_0,
    output  rx_serial_data_0,
    input   tx_serial_data_0,
    input tx_ready_0,
    input rx_ready_0,

    output  clk_status_gx_1,
    output  pma_arst_gx_1,
    output    phy_mgmt_1_read, 
    output    phy_mgmt_1_write,
    output [8:0] phy_mgmt_1_address, //[10:0] 
    output [31:0] phy_mgmt_1_writedata,
    input    phy_mgmt_1_waitrequest,
    input  [31:0]  phy_mgmt_1_readdata,
    output   pll_inclk_1,
	output   cdr_ref_1_clk,
    input  rx_freqlocked_1,
    input  rx_is_lockedtodata_1,
    input  rx_clkout_1, 
    input pll_locked_1,// reset and status signals 
    input  tx_clkout_1 ,
    output [127:0] tx_parallel_data_1,
    input [127:0] rx_parallel_data_1,
    output  rx_serial_data_1,
    input   tx_serial_data_1,
    input tx_ready_1,
    input rx_ready_1,

    output  clk_status_gx_2,
    output  pma_arst_gx_2,
    output    phy_mgmt_2_read, 
    output    phy_mgmt_2_write,
    output [8:0] phy_mgmt_2_address, //[10:0] 
    output [31:0] phy_mgmt_2_writedata,
    input    phy_mgmt_2_waitrequest,
    input  [31:0]  phy_mgmt_2_readdata,
    output   pll_inclk_2,
	output   cdr_ref_2_clk,
    input  rx_freqlocked_2,
    input  rx_is_lockedtodata_2,
    input  rx_clkout_2, 
    input pll_locked_2,// reset and status signals 
    input  tx_clkout_2 ,
    output [127:0] tx_parallel_data_2,
    input [127:0] rx_parallel_data_2,
    output  rx_serial_data_2,
    input   tx_serial_data_2,
    input tx_ready_2,
    input rx_ready_2,

    output  clk_status_gx_3,
    output  pma_arst_gx_3,
    output    phy_mgmt_3_read, 
    output    phy_mgmt_3_write,
    output [8:0] phy_mgmt_3_address, //[10:0] 
    output [31:0] phy_mgmt_3_writedata,
    input    phy_mgmt_3_waitrequest,
    input  [31:0]  phy_mgmt_3_readdata,
    output   pll_inclk_3,
	output   cdr_ref_3_clk,
    input  rx_freqlocked_3,
    input  rx_is_lockedtodata_3,
    input  rx_clkout_3, 
    input pll_locked_3,// reset and status signals 
    input  tx_clkout_3 ,
    output [127:0] tx_parallel_data_3,
    input [127:0] rx_parallel_data_3,
    output  rx_serial_data_3,
    input   tx_serial_data_3,
    input tx_ready_3,
    input rx_ready_3
);

reg    status_read_r;
reg    status_write_r;
reg [31:0] status_writedata_r;
reg [15:0] status_addr_r;
wire [4*32-1:0] phy_readdata_i;

assign phy_readdata0 = phy_readdata_i[1*32-1:0*32];
assign phy_readdata1 = phy_readdata_i[2*32-1:1*32];
assign phy_readdata2 = phy_readdata_i[3*32-1:2*32];
assign phy_readdata3 = phy_readdata_i[4*32-1:3*32];

wire       pma_arst_status, pma_arst_tx, pma_arst_rx;
wire [3:0] pma_arst_tx_i;
wire [3:0] pma_arst_rx_i;
wire       tx_ready_tx;
wire       rx_ready_rx;
wire [3:0] tx_ready_tx_i;
wire [3:0] rx_ready_rx_i;

// clock distribution
wire pll_inclk = clk_ref;
//wire [3:0] rx_coreclk;
wire [3:0] rx_clkout;
//wire [3:0] tx_coreclk;
wire [3:0] tx_clkout;

wire [3:0] tx_clkout_inv;
wire [3:0] rx_clkout_inv;
assign tx_clkout = ~tx_clkout_inv;
assign rx_clkout = ~rx_clkout_inv;

// reset and status signals
wire [3:0] pll_locked;
wire [3:0] rx_freqlocked;
wire [3:0] rx_is_lockedtodata;

wire [3:0] tx_ready_i;
wire [3:0] rx_ready_i;

wire [4*128-1:0] tx_datainx;
wire [4*128-1:0] tx_datain_r;
// bit error injection on the low 2 bits	
reg [1:0] err_inject_r10 = 2'b00;
wire [7:0] err_inject_r;
assign err_inject_r= {6'h0, err_inject_r10};

reg [1:0] last_err_inject = 2'b00;
        
        // select master clocks, force separation on to global clock network
stratixv_clkena #(
	.clock_type("Global Clock"),
	.ena_register_mode("always enabled"),
	.lpm_type("stratixv_clkena")
) clkbuf_rx ( 
	.ena(1'b1),
	.enaout(),
	.inclk(rx_clkout[2]),
	.outclk(clk_rx)
);

stratixv_clkena #(
	.clock_type("Global Clock"),
	.ena_register_mode("always enabled"),
	.lpm_type("stratixv_clkena")
) clkbuf_tx ( 
	.ena(1'b1),
	.enaout(),
	.inclk(tx_clkout[2]),
	.outclk(clk_tx)
);

        //assign clk_rx = rx_clkout[2];
        //assign clk_tx = tx_clkout[2];
        //assign rx_coreclk = {4{clk_rx}};
        //assign tx_coreclk = {4{clk_tx}};

        assign rx_cdr_lock = rx_is_lockedtodata; // rx_freqlocked;
        assign tx_pll_lock = pll_locked;

alt_e100_sync_arst arst_0( .clk(clk_status),     .arst(pma_arst), .sync_arst(pma_arst_status)); 
alt_e100_sync_arst arst_1( .clk(clk_tx),         .arst(pma_arst), .sync_arst(pma_arst_tx));
alt_e100_sync_arst arst_2( .clk(tx_clkout[0]),   .arst(pma_arst), .sync_arst(pma_arst_tx_i[0]));
alt_e100_sync_arst arst_3( .clk(tx_clkout[1]),   .arst(pma_arst), .sync_arst(pma_arst_tx_i[1]));
alt_e100_sync_arst arst_4( .clk(tx_clkout[2]),   .arst(pma_arst), .sync_arst(pma_arst_tx_i[2]));
alt_e100_sync_arst arst_5( .clk(tx_clkout[3]),   .arst(pma_arst), .sync_arst(pma_arst_tx_i[3]));
alt_e100_sync_arst arst_6( .clk(clk_rx),         .arst(pma_arst), .sync_arst(pma_arst_rx));
alt_e100_sync_arst arst_7( .clk(rx_clkout[0]),   .arst(pma_arst), .sync_arst(pma_arst_rx_i[0]));
alt_e100_sync_arst arst_8( .clk(rx_clkout[1]),   .arst(pma_arst), .sync_arst(pma_arst_rx_i[1]));
alt_e100_sync_arst arst_9( .clk(rx_clkout[2]),   .arst(pma_arst), .sync_arst(pma_arst_rx_i[2]));
alt_e100_sync_arst arst_a( .clk(rx_clkout[3]),   .arst(pma_arst), .sync_arst(pma_arst_rx_i[3]));

alt_e100_status_sync sync_0 (.clk(clk_tx), .din(tx_ready), .dout(tx_ready_tx)); 
defparam sync_0 .WIDTH = 1;

alt_e100_status_sync sync_1 (.clk(tx_clkout[0]), .din(tx_ready), .dout(tx_ready_tx_i[0])); 
defparam sync_1 .WIDTH = 1;

alt_e100_status_sync sync_2 (.clk(tx_clkout[1]), .din(tx_ready), .dout(tx_ready_tx_i[1])); 
defparam sync_2 .WIDTH = 1;

alt_e100_status_sync sync_3 (.clk(tx_clkout[2]), .din(tx_ready), .dout(tx_ready_tx_i[2])); 
defparam sync_3 .WIDTH = 1;

alt_e100_status_sync sync_4 (.clk(tx_clkout[3]), .din(tx_ready), .dout(tx_ready_tx_i[3])); 
defparam sync_4 .WIDTH = 1;

alt_e100_status_sync sync_5 (.clk(clk_rx), .din(rx_ready), .dout(rx_ready_rx));
defparam sync_5 .WIDTH = 1;

alt_e100_status_sync sync_6 (.clk(rx_clkout[0]), .din(rx_ready), .dout(rx_ready_rx_i[0])); 
defparam sync_6 .WIDTH = 1;

alt_e100_status_sync sync_7 (.clk(rx_clkout[1]), .din(rx_ready), .dout(rx_ready_rx_i[1])); 
defparam sync_7 .WIDTH = 1;

alt_e100_status_sync sync_8 (.clk(rx_clkout[2]), .din(rx_ready), .dout(rx_ready_rx_i[2])); 
defparam sync_8 .WIDTH = 1;

alt_e100_status_sync sync_9 (.clk(rx_clkout[3]), .din(rx_ready), .dout(rx_ready_rx_i[3])); 
defparam sync_9 .WIDTH = 1;


        // bit error injection on the low 2 bits
        always @(posedge clk_tx) begin
            last_err_inject <= err_inject;
            err_inject_r10 <= err_inject & ~last_err_inject;
        end

//wire    [4*138-1:0] reconfig_from_xcvr;
//wire    [4*210-1:0] reconfig_to_xcvr;

//wire          reco_waitrequest;
wire [3:0]    phy_waitrequest;

always @(posedge clk_status) begin
    if (pma_arst_status) begin
        status_read_r <= 0;
        status_write_r <= 0;
        status_writedata_r <= 32'b0;
        status_addr_r <= 16'b0;
    end
    else if( /*!reco_waitrequest && */!(|phy_waitrequest)) begin
        status_read_r <= status_read;
        status_write_r <= status_write;
        status_writedata_r <= status_writedata;
        status_addr_r <= status_addr;
    end
end

//wire    reco_read = status_read_r && (status_addr_r[15:7]==RECO_ADDR_PREFIX[8:0]);
//wire    reco_write = status_write_r && (status_addr_r[15:7]==RECO_ADDR_PREFIX[8:0]);
//wire [6:0] reco_addr = (reco_read || reco_write) ? status_addr_r[6:0] : 7'b0;

wire [3:0] phy_read;
wire [3:0] phy_write;
wire       is_phy_addr;

assign    is_phy_addr = (status_addr_r[15:11]==CAUI4_PMA_ADDR_PREFIX[4:0]);
assign    phy_read[0] = status_read_r && is_phy_addr && (status_addr_r[10:9]==2'h0);
assign    phy_read[1] = status_read_r && is_phy_addr && (status_addr_r[10:9]==2'h1);
assign    phy_read[2] = status_read_r && is_phy_addr && (status_addr_r[10:9]==2'h2);
assign    phy_read[3] = status_read_r && is_phy_addr && (status_addr_r[10:9]==2'h3);
assign    phy_write[0] = status_write_r && is_phy_addr && (status_addr_r[10:9]==2'h0);
assign    phy_write[1] = status_write_r && is_phy_addr && (status_addr_r[10:9]==2'h1);
assign    phy_write[2] = status_write_r && is_phy_addr && (status_addr_r[10:9]==2'h2);
assign    phy_write[3] = status_write_r && is_phy_addr && (status_addr_r[10:9]==2'h3);
wire [8:0] phy_addr = is_phy_addr? status_addr_r[8:0] : 9'b0;

assign reco_readdata_valid = 1'b0;
// assign    reco_readdata_valid = reco_read && !reco_waitrequest;
assign    phy_readdata_valid0 = phy_read[0] && !phy_waitrequest[0];
assign    phy_readdata_valid1 = phy_read[1] && !phy_waitrequest[1];
assign    phy_readdata_valid2 = phy_read[2] && !phy_waitrequest[2];
assign    phy_readdata_valid3 = phy_read[3] && !phy_waitrequest[3];
assign    tx_ready = &tx_ready_i;
assign    rx_ready = &rx_ready_i;

wire  [128*4-1:0] rx_dataoutx;   
//instantiate low latency phy
genvar i;
generate
for (i=0; i<4; i=i+1) begin: gx0_3

wire [11:0] tx_dummy_12;
reg         tx_rdreq;
wire        tx_rdempty;
reg         tx_wrreq;
wire [11:0] rx_dummy_12;
reg         rx_rdreq;
wire        rx_rdempty;
reg         rx_wrreq;

always @(posedge clk_tx or posedge pma_arst_tx) begin
   if (pma_arst_tx)      tx_wrreq <= 1'b0;
   else if (tx_ready_tx) tx_wrreq <= 1'b1;
end

always @(posedge tx_clkout[i] or posedge pma_arst_tx_i[i]) begin
   if (pma_arst_tx_i[i])                     tx_rdreq <= 1'b0;
   else if (tx_ready_tx_i[i] && !tx_rdempty) tx_rdreq <= 1'b1;
end

    alt_e100_mlab_dcfifo_caui4 mf_tx (
	.arst(pma_arst),
	.wrclk(clk_tx),
        .wrdata({12'h0, (tx_datain_r[(i+1)*128-1:i*128] ^ {126'h0, err_inject_r[i*2+1:i*2+0]})}),    // input [127:0]
	.wrreq(tx_wrreq),
	.wrfull(),
	.wrused (),
	
	.rdclk (tx_clkout[i]),
	.rddata({tx_dummy_12, tx_datainx[(i+1)*128-1:i*128]}),
	//.rddata(),
	.rdreq(tx_rdreq),
	.rdempty(tx_rdempty),	
	.rdused(),	
	.parity_err()
);
defparam mf_tx .LABS_WIDE = 7;
//defparam mf_tx .SIM_DELAYS = FIFO_SIM_DELAYS;
//defparam mf_tx .DEVICE_FAMILY = DEVICE_FAMILY;

//    alt_e100_e1x25_caui4 gx(
//        .phy_mgmt_clk        (clk_status),                         // input 
//        .phy_mgmt_clk_reset  (pma_arst),                           // input
//        .phy_mgmt_address    (phy_addr),                           // input [8:0]
//        .phy_mgmt_read       (phy_read[i]),                           // input
//        .phy_mgmt_readdata   (phy_readdata_i[(i+1)*32-1:i*32]),       // output [31:0]
//        .phy_mgmt_waitrequest(phy_waitrequest[i]),                    // output
//        .phy_mgmt_write      (phy_write[i]),                          // input
//        .phy_mgmt_writedata  (status_writedata_r[31:0]),           // input [31:0]
//        .tx_ready            (tx_ready_i[i]),                           // output
//        .rx_ready            (rx_ready_i[i]),                           // output
//        .pll_ref_clk         (pll_inclk),                          // input
//        .pll_locked          (pll_locked[i]),                         // output
//        .tx_serial_data      (tx_dataout[i]),                         // output [9:0]
//        .rx_serial_data      (rx_datain[i]),                          // input [9:0]
//        .rx_is_lockedtoref   (rx_freqlocked[i]),                      // output [9:0]
//        .rx_is_lockedtodata  (rx_is_lockedtodata[i]),                 // output [9:0]
//        .tx_clkout           (tx_clkout_inv[i]),                     // output
//        .rx_clkout           (rx_clkout_inv[i]),                          // output 
//        //.tx_parallel_data    (tx_datain_r[(i+1)*128-1:i*128] ^ err_inject_r[i*2+1:i*2+0]),    // input [127:0]
//        .tx_parallel_data    (tx_datainx[(i+1)*128-1:i*128]),    // input [127:0]
//        .rx_parallel_data    (rx_dataoutx[(i+1)*128-1:i*128]),                         // input [127:0]
//        .reconfig_from_xcvr  (reconfig_from_xcvr[(i+1)*138-1:i*138]),             // output [920:0]
//        .reconfig_to_xcvr    (reconfig_to_xcvr[(i+1)*210-1:i*210])                // input [1400:0]
//        );

always @(posedge rx_clkout[i] or posedge pma_arst_rx_i[i]) begin
   if (pma_arst_rx_i[i])         rx_wrreq <= 1'b0;
   else if (rx_ready_rx_i[i])    rx_wrreq <= 1'b1;
end

always @(posedge clk_rx or posedge pma_arst_rx) begin
   if (pma_arst_rx)                     rx_rdreq <= 1'b0;
   else if (rx_ready_rx && !rx_rdempty) rx_rdreq <= 1'b1;
end

    alt_e100_mlab_dcfifo_caui4 mf_rx (
	.arst(pma_arst),
	.wrclk(rx_clkout[i]),
	.wrdata({12'h0, rx_dataoutx[(i+1)*128-1:i*128]}),
	.wrreq(rx_wrreq),
	.wrfull(),
	.wrused (),
	
	.rdclk (clk_rx),
	.rddata({rx_dummy_12, rx_dataout[(i+1)*128-1:i*128]}),
	//.rddata(),
	.rdreq(rx_rdreq),
	.rdempty(rx_rdempty),	
	.rdused(),	
	.parity_err()
);
defparam mf_rx .LABS_WIDE = 7;
//defparam mf_rx .SIM_DELAYS = FIFO_SIM_DELAYS;
//defparam mf_rx .DEVICE_FAMILY = DEVICE_FAMILY;

end


if (en_synce_support) begin
	assign pll_inclk_0 = tx_clk_ref;
	assign pll_inclk_1 = tx_clk_ref;
	assign pll_inclk_2 = tx_clk_ref;
	assign pll_inclk_3 = tx_clk_ref;
	assign cdr_ref_0_clk = rx_clk_ref;
	assign cdr_ref_1_clk = rx_clk_ref;
	assign cdr_ref_2_clk = rx_clk_ref;
	assign cdr_ref_3_clk = rx_clk_ref;
end
else begin
	assign pll_inclk_0 = pll_inclk;
	assign pll_inclk_1 = pll_inclk;
	assign pll_inclk_2 = pll_inclk;
	assign pll_inclk_3 = pll_inclk;
	assign cdr_ref_0_clk = pll_inclk;
	assign cdr_ref_1_clk = pll_inclk;
	assign cdr_ref_2_clk = pll_inclk;
	assign cdr_ref_3_clk = pll_inclk;
end


endgenerate

// Assignments for GX
assign clk_status_gx_0 = clk_status;
assign pma_arst_gx_0 = pma_arst;
assign phy_mgmt_0_address = phy_addr;
assign phy_mgmt_0_read = phy_read[0];
assign phy_readdata_i[(0+1)*32-1:0*32] = phy_mgmt_0_readdata;
assign phy_waitrequest[0] = phy_mgmt_0_waitrequest;
assign phy_mgmt_0_write = phy_write[0];
assign phy_mgmt_0_writedata = status_writedata_r[31:0];
assign tx_ready_i[0] = tx_ready_0;
assign rx_ready_i[0] = rx_ready_0;
assign pll_locked[0] = pll_locked_0;
assign tx_dataout[0] = tx_serial_data_0;
assign rx_serial_data_0 = rx_datain[0];
assign rx_freqlocked[0] = rx_freqlocked_0;
assign rx_is_lockedtodata[0] = rx_is_lockedtodata_0;
assign tx_clkout_inv[0] = tx_clkout_0;
assign rx_clkout_inv[0] = rx_clkout_0;
assign tx_parallel_data_0 = tx_datainx[(0+1)*128-1:0*128];
assign rx_dataoutx[(0+1)*128-1:0*128] = rx_parallel_data_0;

assign clk_status_gx_1 = clk_status;
assign pma_arst_gx_1 = pma_arst;
assign phy_mgmt_1_address = phy_addr;
assign phy_mgmt_1_read = phy_read[1];
assign phy_readdata_i[(1+1)*32-1:1*32] = phy_mgmt_1_readdata;
assign phy_waitrequest[1] = phy_mgmt_1_waitrequest;
assign phy_mgmt_1_write = phy_write[1];
assign phy_mgmt_1_writedata = status_writedata_r[31:0];
assign tx_ready_i[1] = tx_ready_1;
assign rx_ready_i[1] = rx_ready_1;
assign pll_locked[1] = pll_locked_1;
assign tx_dataout[1]= tx_serial_data_1;
assign rx_serial_data_1 = rx_datain[1];
assign rx_freqlocked[1] = rx_freqlocked_1;
assign rx_is_lockedtodata[1] = rx_is_lockedtodata_1;
assign tx_clkout_inv[1] = tx_clkout_1;
assign rx_clkout_inv[1] = rx_clkout_1;
assign tx_parallel_data_1 = tx_datainx[(1+1)*128-1:1*128];
assign rx_dataoutx[(1+1)*128-1:1*128] = rx_parallel_data_1;

assign clk_status_gx_2 = clk_status;
assign pma_arst_gx_2 = pma_arst;
assign phy_mgmt_2_address = phy_addr;
assign phy_mgmt_2_read = phy_read[2];
assign phy_readdata_i[(2+1)*32-1:2*32] = phy_mgmt_2_readdata;
assign phy_waitrequest[2] = phy_mgmt_2_waitrequest;
assign phy_mgmt_2_write = phy_write[2];
assign phy_mgmt_2_writedata = status_writedata_r[31:0];
assign tx_ready_i[2] = tx_ready_2;
assign rx_ready_i[2] = rx_ready_2;
assign pll_locked[2] = pll_locked_2;
assign tx_dataout[2] = tx_serial_data_2;
assign rx_serial_data_2 = rx_datain[2];
assign rx_freqlocked[2] = rx_freqlocked_2;
assign rx_is_lockedtodata[2] = rx_is_lockedtodata_2;
assign tx_clkout_inv[2] = tx_clkout_2;
assign rx_clkout_inv[2] = rx_clkout_2;
assign tx_parallel_data_2 = tx_datainx[(2+1)*128-1:2*128];
assign rx_dataoutx[(2+1)*128-1:2*128] = rx_parallel_data_2;

assign clk_status_gx_3 = clk_status;
assign pma_arst_gx_3 = pma_arst;
assign phy_mgmt_3_address = phy_addr;
assign phy_mgmt_3_read = phy_read[3];
assign phy_readdata_i[(3+1)*32-1:3*32] = phy_mgmt_3_readdata;
assign phy_waitrequest[3] = phy_mgmt_3_waitrequest;
assign phy_mgmt_3_write = phy_write[3];
assign phy_mgmt_3_writedata = status_writedata_r[31:0];
assign tx_ready_i[3] = tx_ready_3;
assign rx_ready_i[3] = rx_ready_3;
assign pll_locked[3] = pll_locked_3;
assign tx_dataout[3] = tx_serial_data_3;
assign rx_serial_data_3 = rx_datain[3];
assign rx_freqlocked[3] = rx_freqlocked_3;
assign rx_is_lockedtodata[3] = rx_is_lockedtodata_3;
assign tx_clkout_inv[3] = tx_clkout_3;
assign rx_clkout_inv[3] = rx_clkout_3;
assign tx_parallel_data_3 = tx_datainx[(3+1)*128-1:3*128];
assign rx_dataoutx[(3+1)*128-1:3*128] = rx_parallel_data_3;
//assign rx_dataout = tx_datain_r ^ err_inject_r[1:0];

assign out_busy = 1'b0;
assign reco_readdata = 32'b0;
//alt_e100_reco_caui4 rc(
//        .reconfig_busy             (busy),                         // output
//        .mgmt_clk_clk              (clk_status),                   // input
//        .mgmt_rst_reset            (pma_arst),                     // input
//        .reconfig_mgmt_address     (reco_addr),                    // input [6:0]
//        .reconfig_mgmt_read        (reco_read),                    // input
//        .reconfig_mgmt_readdata    (reco_readdata[31:0]),          // output [31:0]
//        .reconfig_mgmt_waitrequest (reco_waitrequest),             // output
//        .reconfig_mgmt_write       (reco_write),                   // input
//        .reconfig_mgmt_writedata   (status_writedata_r[31:0]),     // input [31:0]
//        .ch0_2_to_xcvr             (reconfig_to_xcvr[209:0]),         // output [209:0]
//        .ch0_2_from_xcvr           (reconfig_from_xcvr[137:0]),       // input [137:0]
//        .ch3_5_to_xcvr             (reconfig_to_xcvr[2*210-1:1*210]),         // output [209:0]
//        .ch3_5_from_xcvr           (reconfig_from_xcvr[2*138-1:1*138]),       // input [137:0]
//        .ch6_8_to_xcvr             (reconfig_to_xcvr[3*210-1:2*210]),         // output [209:0]
//        .ch6_8_from_xcvr           (reconfig_from_xcvr[3*138-1:2*138]),       // input [137:0]
//        .ch9_11_to_xcvr            (reconfig_to_xcvr[4*210-1:3*210]),        // output [209:0]
//        .ch9_11_from_xcvr          (reconfig_from_xcvr[4*138-1:3*138])      // input [137:0]
//);

localparam SKEW = 75; // bits to skew the TX's per lane pair
genvar j;
generate
        if (FAKE_TX_SKEW) begin
            // synthesis translate off
            for (j=0; j<4; j=j+1) begin : foo
                wire [127:0] tmp_in = tx_datain[(j+1)*128-1:j*128];
                reg [127+4*SKEW:0] history = 0;
                always @(posedge clk_tx) begin
                    history <= (history >> 128);
                    history[127+j*SKEW:j*SKEW] <= tmp_in;
                end
                wire [127:0] tmp_out = history[127:0];
                assign tx_datain_r[(j+1)*128-1:j*128] = tmp_out;    
            end
            // synthesis translate on
        end
        else begin
            assign tx_datain_r = tx_datain;
        end
endgenerate

//assign tx_datain_r = tx_datain;

endmodule
