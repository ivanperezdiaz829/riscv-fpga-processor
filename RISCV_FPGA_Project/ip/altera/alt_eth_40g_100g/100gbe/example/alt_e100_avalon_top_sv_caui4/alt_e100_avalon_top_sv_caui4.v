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

module alt_e100_avalon_top_sv_caui4
(
	input clk50,
	input cpu_resetn,

	// 10G IO
	input clk_ref_r,
	input [3:0] rx_serial_r,
	output [3:0] tx_serial_r
	
);

`include "dynamic_parameters.v"

parameter TERM_STYLE_JTAG = 1'b1; // vs sys console

parameter WORDS = 8;
parameter WIDTH = 64;
parameter SOP_ON_LANE0 = 1'b1;

parameter FAST_SIMULATION = 1'b0;
parameter SIM_NO_JTAG     = 1'b0;
parameter SIM_NO_TEMP_SENSE = 1'b0;

/////////////////////////
// dev_clr sync-reset
/////////////////////////

wire user_mode_sync, arst;

alt_e100_user_mode_det dev_clr(
    .ref_clk(clk50),
    .user_mode_sync(user_mode_sync)
);

////////////////////////////////////////////

wire clk100, clk320;
wire sp100_locked, sp_locked;

alt_e100_sys_pll_sv_100 sp100(
	.rst(~user_mode_sync),
	.refclk(clk50),
	.outclk_0(clk100),
	.locked(sp100_locked)
);

alt_e100_sys_pll_sv sp (
	.rst(~sp100_locked),
	.refclk(clk100),
	.outclk_0(clk320),
	.locked(sp_locked)
);

assign arst = ~sp_locked | ~cpu_resetn;

wire [15:0] status_addr;
wire        status_read,status_write,status_readdata_valid_e100;
wire [31:0] status_readdata_e100, status_writedata;
wire        clk_status = clk100;

// input domain (from user logic toward pins)
wire                   clk_din = clk320;  // nominal 312
wire [WORDS*WIDTH-1:0] din;               // payload to send, left to right
wire       [WORDS-1:0] din_start;         // start pos, first of every 8 bytes
wire     [WORDS*8-1:0] din_end_pos;       // end position, any byte
wire                   din_ack;           // payload is accepted

// output domain (from pins toward user logic)
wire                   clk_dout = clk320; // nominal 312
wire    [WORDS*64-1:0] dout_d;            // 5 word out stream, left to right
// wire  [WORDS*8-1:0] dout_c;
wire       [WORDS-1:0] dout_first_data;
wire     [WORDS*8-1:0] dout_last_data;
// wire    [WORDS-1:0] dout_runt_last_data;
// wire    [WORDS-1:0] dout_payload;
// wire                dout_fcs_error;
// wire                dout_fcs_valid;
wire                   dout_valid;
//

////////////////////////////////////////////
// 100G E w/ 10x10 serial links
//////////////////////////////////////

wire            clk_txmac;    // MAC + PCS clock - at least 312.5Mhz
wire            clk_rxmac;    // MAC + PCS clock - at least 312.5Mhz
wire            clk_ref;      // GX PLL reference
wire    [511:0] l8_tx_data;
wire      [5:0] l8_tx_empty;
wire            l8_tx_endofpacket;
wire            l8_tx_ready;
wire            l8_tx_startofpacket;
wire            l8_tx_valid;
wire    [511:0] l8_rx_data;
wire      [5:0] l8_rx_empty;
wire            l8_rx_endofpacket;
wire            l8_rx_error;
wire            l8_rx_startofpacket;
wire            l8_rx_valid;
wire      [9:0] tx_serial;
wire      [9:0] rx_serial;

//--- functions
`include "../common/alt_e100_wide_l8if_functions.iv"

assign clk_txmac                    = clk320;
assign clk_rxmac                    = clk320;
assign clk_ref                      = clk_ref_r;

assign l8_tx_data            = din;
assign l8_tx_empty           = alt_e100_wide_encode64to6(din_end_pos);
assign l8_tx_endofpacket     = |din_end_pos;
assign din_ack               = l8_tx_ready;
assign l8_tx_startofpacket   = din_start[WORDS-1];
assign dout_d                = l8_rx_data;
assign dout_last_data   = l8_rx_endofpacket ? alt_e100_wide_decode6to64(l8_rx_empty) : 64'h0;
assign dout_first_data       = {l8_rx_startofpacket, {WORDS-1{1'b0}}};
assign dout_valid  = l8_rx_valid;

assign tx_serial_r  = tx_serial;
assign rx_serial    = rx_serial_r;

wire    [137:0] reconfig_from_xcvr0, reconfig_from_xcvr1, reconfig_from_xcvr2, reconfig_from_xcvr3;
wire    [209:0] reconfig_to_xcvr0, reconfig_to_xcvr1, reconfig_to_xcvr2, reconfig_to_xcvr3;

ENET_ENTITY_QMEGA_06072013 ior (
    .mac_rx_arst_ST(arst),
    .mac_tx_arst_ST(arst),
    .pcs_rx_arst_ST(arst),
    .pcs_tx_arst_ST(arst),
    .pma_arst_ST(arst),
	
    .clk_txmac(clk_txmac),    // MAC + PCS clock - at least 312.5Mhz
    .clk_rxmac(clk_rxmac),    // MAC + PCS clock - at least 312.5Mhz
    
    `ifdef SYNC_E
    .rx_clk_ref(clk_ref_r),//input  wire                           //           clk_ref.clk
    .tx_clk_ref(clk_ref_r),//input  wire                           //           clk_ref.clk
    `else
    .clk_ref(clk_ref_r),//input  wire                           //           clk_ref.clk
    `endif

    // status register bus
    .clk_status(clk_status),
    .status_addr(status_addr),
    .status_read(status_read),
    .status_write(status_write),
    .status_writedata(status_writedata),
    .status_readdata(status_readdata_e100),
    .status_readdata_valid(status_readdata_valid_e100),

    .l8_tx_data(l8_tx_data),
    .l8_tx_empty(l8_tx_empty),
    .l8_tx_startofpacket(l8_tx_startofpacket),
    .l8_tx_endofpacket(l8_tx_endofpacket),
    .l8_tx_ready(l8_tx_ready),
    .l8_tx_valid(1'b1),
    
    .l8_rx_data(l8_rx_data),
    .l8_rx_empty(l8_rx_empty),
    .l8_rx_startofpacket(l8_rx_startofpacket),
    .l8_rx_endofpacket(l8_rx_endofpacket),
    .l8_rx_error(l8_rx_error),
    .l8_rx_valid(l8_rx_valid),
     
    .tx_serial(tx_serial),
    .rx_serial(rx_serial),
	
    // pause generation
    .pause_insert_tx(1'b0),	// generate pause
    .pause_insert_time(16'b0),	// generated pause time
    .pause_insert_mcast(1'b0),	// generate mcast pause
    .pause_insert_dst(48'b0),	// generated pause destination addr
    .pause_insert_src(48'b0),		// generated pause source addr

    .reconfig_from_xcvr0  (reconfig_from_xcvr0[137:0]),          // output [137:0]
    .reconfig_from_xcvr1  (reconfig_from_xcvr1[137:0]),          // output [137:0]
    .reconfig_from_xcvr2  (reconfig_from_xcvr2[137:0]),          // output [137:0]
    .reconfig_from_xcvr3  (reconfig_from_xcvr3[137:0]),          // output [137:0]
    .reconfig_to_xcvr0    (reconfig_to_xcvr0[209:0]),            // input [209:0]
    .reconfig_to_xcvr1    (reconfig_to_xcvr1[209:0]),            // input [209:0]
    .reconfig_to_xcvr2    (reconfig_to_xcvr2[209:0]),            // input [209:0]
    .reconfig_to_xcvr3    (reconfig_to_xcvr3[209:0])             // input [209:0]
);
//defparam ior.gen_100_inst.phy.phy_pcs.FAST_SIMULATION = FAST_SIMULATION;

// map reconfig registers to 0x600-0x67F

wire    reco_waitrequest;
wire    reco_readdata_valid;
wire [31:0] reco_readdata;

reg    status_read_r;
reg    status_write_r;
reg [31:0] status_writedata_r;
reg [15:0] status_addr_r;

always @(posedge clk_status) begin
    if (arst) begin
        status_read_r <= 0;
        status_write_r <= 0;
        status_writedata_r <= 32'b0;
        status_addr_r <= 32'b0;
    end
    else if( !reco_waitrequest ) begin
        status_read_r <= status_read;
        status_write_r <= status_write;
        status_writedata_r <= status_writedata;
        status_addr_r <= status_addr;
    end
end

wire    reco_read = status_read_r && (status_addr_r[15:7]==9'b0000_0110_0);
wire    reco_write = status_write_r && (status_addr_r[15:7]==9'b0000_0110_0);
wire [6:0] reco_addr = (reco_read || reco_write) ? status_addr_r[6:0] : 7'b0;

assign    reco_readdata_valid = reco_read && !reco_waitrequest;

alt_e100_e_reco_caui4 rc(
        .reconfig_busy             (),                         // output
        .mgmt_clk_clk              (clk_status),                   // input
        .mgmt_rst_reset            (arst),                     // input
        .reconfig_mgmt_address     (reco_addr),                    // input [6:0]
        .reconfig_mgmt_read        (reco_read),                    // input
        .reconfig_mgmt_readdata    (reco_readdata[31:0]),          // output [31:0]
        .reconfig_mgmt_waitrequest (reco_waitrequest),             // output
        .reconfig_mgmt_write       (reco_write),                   // input
        .reconfig_mgmt_writedata   (status_writedata_r[31:0]),     // input [31:0]
        .ch0_2_to_xcvr             (reconfig_to_xcvr0[209:0]),     // output [209:0]
        .ch0_2_from_xcvr           (reconfig_from_xcvr0[137:0]),   // input [137:0]
        .ch3_5_to_xcvr             (reconfig_to_xcvr1[209:0]),     // output [209:0]
        .ch3_5_from_xcvr           (reconfig_from_xcvr1[137:0]),   // input [137:0]
        .ch6_8_to_xcvr             (reconfig_to_xcvr2[209:0]),     // output [209:0]
        .ch6_8_from_xcvr           (reconfig_from_xcvr2[137:0]),   // input [137:0]
        .ch9_11_to_xcvr            (reconfig_to_xcvr3[209:0]),     // output [209:0]
        .ch9_11_from_xcvr          (reconfig_from_xcvr3[137:0]),   // input [137:0]
        .reconfig_mif_address      (),
        .reconfig_mif_read         (),
        .reconfig_mif_readdata     (16'b0),
        .reconfig_mif_waitrequest  (1'b0)
);


///////////////////////////////////
// generate and check some simple data transfers
///////////////////////////////////

wire [31:0] status_readdata_pc;
wire status_readdata_valid_pc;

	
alt_e100_packet_client pc (
	.arst(arst),
	
    // TX to Ethernet
    .clk_tx                 (clk_din),
    .tx_ack                 (din_ack),
    .tx_data                (din),
    .tx_start               (din_start),
    .tx_end_pos             (din_end_pos),

    // RX from Ethernet
    .clk_rx                 (clk_dout),
    .rx_valid               (dout_valid),
    .rx_data                (dout_d),
    .rx_start               (dout_first_data),
    .rx_end_pos             (dout_last_data),

    // status register bus
    .clk_status             (clk_status),
    .status_addr            (status_addr),
    .status_read            (status_read),
    .status_write           (status_write),
    .status_writedata       (status_writedata),
    .status_readdata        (status_readdata_pc),
    .status_readdata_valid  (status_readdata_valid_pc)
);
defparam pc  .WORDS        = WORDS;
defparam pc  .WIDTH        = WIDTH;
defparam pc  .SIM_NO_TEMP_SENSE  = SIM_NO_TEMP_SENSE;
defparam pc  .DEVICE_FAMILY = "Stratix V";
defparam pc  .SOP_ON_LANE0 = SOP_ON_LANE0;

//////////////////////////////////////
// merge status bus
//////////////////////////////////////

wire [31:0] status_readdata;
wire status_readdata_valid, status_waitrequest;

alt_e100_avalon_mm_read_combine arc (
	.clk(clk_status),
	.host_read(status_read),
	.host_readdata(status_readdata),
	.host_readdata_valid(status_readdata_valid),
	.host_waitrequest(status_waitrequest),

	.client_readdata_valid(
		{status_readdata_valid_e100,
		status_readdata_valid_pc,
		reco_readdata_valid}),
	.client_readdata(
		{status_readdata_e100,
		status_readdata_pc,
		reco_readdata})		

);
defparam arc .NUM_CLIENTS = 3;
	
//////////////////////////////////////
// JTAG host port
//////////////////////////////////////

generate
if (!SIM_NO_JTAG) begin

    // TODO
    // this guy doesn't support wait yet, but it is SLOOw.
    // ... so it will wait in practice.

    if (TERM_STYLE_JTAG) begin
        alt_e100_jtag_term_master jm (
            .clk            (clk_status),
            .arst           (~sp100_locked),

            .mm_addr        (status_addr),
            .mm_read        (status_read),
            .mm_write       (status_write),
            .mm_writedata   (status_writedata),

            .mm_readdata    (status_readdata),
            .mm_readdata_valid(status_readdata_valid)
        );
    end
    else begin
        wire [31:0] av_addr;
        assign status_addr = av_addr[17:2];
        jtag_sys_console_master jsm (
            .clk            (clk_status),
            .arst           (~sp100_locked),

            .addr           (av_addr),
            .read           (status_read),
            .write          (status_write),
            .writedata      (status_writedata),

            .readdata       (status_readdata),
            .readdata_valid (status_readdata_valid),
            .waitreq        (status_waitrequest)
        );
    end
end
else begin : sim

    assign status_addr = 16'b0;
    assign status_read = 1'b0;
    assign status_write = 1'b0;
    assign status_writedata = 32'b0;

end
endgenerate

////////////////////////////////////////////



endmodule
