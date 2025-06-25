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

module alt_e40_tx_top_a10
(
	input clk50,
	input cpu_resetn,

	// 10G IO
	input clk_ref_r,
	//input [3:0] rx_serial_r,
	output [3:0] tx_serial_r,
	
	// CFP MDIO controls
	output cfp_mdc,
	inout  cfp_mdio,
	input  cfp_glb_alrm,
	//output [4:0] cfp_prtadr,	
	
	// CFP custom controls
	output cfp_mod_lopwr,
	output cfp_mod_rst,
	output cfp_tx_dis,
	input cfp_mod_abs,
	input cfp_rx_los,
	input [3:1] cfp_prg_alrm,
	output [3:1] cfp_prg_cntl
	
);

parameter FAST_SIMULATION = 1'b0;
parameter SIM_NO_JTAG = 1'b0;
parameter SIM_NO_TEMP_SENSE = 1'b0;
parameter TERM_STYLE_JTAG = 1'b1; // vs sys console
parameter WORDS = 2; // no override

/////////////////////////
// dev_clr sync-reset
/////////////////////////

wire user_mode_sync, arst;

alt_e40_user_mode_det dev_clr(
    .ref_clk(clk50),
    .user_mode_sync(user_mode_sync)
);

////////////////////////////////////////////

wire clk100, clk320;
wire sp100_locked, sp_locked;

alt_e40_sys_pll_sv_100 sp100(
	.rst(~user_mode_sync),
	.refclk(clk50),
	.outclk_0(clk100),
	.locked(sp100_locked)
);

alt_e40_sys_pll_sv sp (
	.rst(~sp100_locked),
	.refclk(clk100),
	.outclk_0(clk320),
	.locked(sp_locked)
);

assign arst = ~sp_locked | ~cpu_resetn;

////////////////////////////////////////////
// 40G E w/ 4x10 serial links
//////////////////////////////////////

wire [15:0] status_addr;
wire status_read,status_write,status_readdata_valid_e40;
wire [31:0] status_readdata_e40, status_writedata;
wire clk_status = clk100;

// input domain (from user logic toward pins)
wire clk_txmac = clk320;	 // nominal 312
wire [WORDS*64-1:0] din;	 // payload to send, regular left to right
wire [WORDS-1:0] din_start; // start position, first of every 8 bytes
wire [WORDS*8-1:0] din_end_pos; // end position, any byte
wire din_ack;			 // payload is accepted

// output domain (from pins toward user logic)
wire clk_rxmac = clk320;			// nominal 312

wire    [367:0] reconfig_from_xcvr;
wire    [559:0] reconfig_to_xcvr;

wire    pll_locked;
wire    tx_serial_clk;

atx_pll atx (
	.pll_powerdown(arst), //   atx_pll_powerdown.pll_powerdown
	.pll_refclk0(clk_ref),             //     atx_pll_refclk0.clk
    .pll_locked(pll_locked),       //      atx_pll_locked.pll_locked
    .pll_cal_busy(),   //    atx_pll_cal_busy.pll_cal_busy
    .mcgb_rst(arst),           //        atx_mcgb_rst.mcgb_rst
    .mcgb_serial_clk(tx_serial_clk)          // atx_mcgb_serial_clk.clk
    );

ENET_ENTITY_QMEGA_06072013 ior (
    .mac_tx_arst_ST(arst),
    .pcs_tx_arst_ST(arst),
    .pma_arst_ST(arst),

    // serdes
    .clk_ref(clk_ref_r),  // GX PLL reference
    .tx_serial(tx_serial_r),
	
	.pll_locked(pll_locked), 
	.tx_serial_clk({4{tx_serial_clk}}),

    // input domain (from user logic toward pins)
    .clk_txmac(clk_txmac),          // nominal 312
    .din(din),                  // payload to send, regular left to right
    .din_start(din_start),      // start position, first of every 8 bytes
    .din_end_pos(din_end_pos),  // end position, any byte
    .din_ack(din_ack),          // payload is accepted

    // status register bus
    .clk_status(clk_status),
    .status_addr(status_addr),
    .status_read(status_read),
    .status_write(status_write),
    .status_writedata(status_writedata),
    .status_readdata(status_readdata_e40),
    .status_readdata_valid(status_readdata_valid_e40),

    // pause generation
    .pause_insert_tx(1'b0),	// LEDA
    .pause_insert_time(16'b0),	// LEDA
    .pause_insert_mcast(1'b0),	// LEDA
    .pause_insert_dst(48'b0),	// LEDA
    .pause_insert_src(48'b0),		// LEDA
    
    .pause_match_to_tx(1'b0),            // used only if variant==2, TX only
    .pause_time_to_tx(16'b0),      // used only if variant==2, TX only
    .remote_fault_to_tx(1'b0),          // used only if variant==2, TX only
    .local_fault_to_tx(1'b0),            // used only if variant==2, TX only
    
	.a10_reconfig_write(1'b0),
    .a10_reconfig_read(1'b0),
    .a10_reconfig_address(32'b0),
    .a10_reconfig_writedata(32'b0),
    .a10_reconfig_readdata(),
    .a10_reconfig_waitrequest()
    
);
//defparam ior.gen_40_inst.phy.phy_pcs.FAST_SIMULATION = FAST_SIMULATION;

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

// alt_e40_e_reco rc(
        // .reconfig_busy             (),                         // output
        // .mgmt_clk_clk              (clk_status),                   // input
        // .mgmt_rst_reset            (arst),                     // input
        // .reconfig_mgmt_address     (reco_addr),                    // input [6:0]
        // .reconfig_mgmt_read        (reco_read),                    // input
        // .reconfig_mgmt_readdata    (reco_readdata[31:0]),          // output [31:0]
        // .reconfig_mgmt_waitrequest (reco_waitrequest),             // output
        // .reconfig_mgmt_write       (reco_write),                   // input
        // .reconfig_mgmt_writedata   (status_writedata_r[31:0]),     // input [31:0]
        // .reconfig_to_xcvr          (reconfig_to_xcvr[559:0]),     // output [559:0]
        // .reconfig_from_xcvr        (reconfig_from_xcvr[367:0])     // input [367:0]
// );

assign reco_waitrequest = 1'b0;
assign reconfig_to_xcvr = 560'b0;
assign reco_readdata = 32'b0;

///////////////////////////////////
// generate and check some simple data transfers
///////////////////////////////////

wire [31:0] status_readdata_pc;
wire status_readdata_valid_pc;

alt_e40_packet_client pc (
	.arst(arst),
	
	// TX to Ethernet
	.clk_tx(clk_txmac),
	.tx_ack(din_ack),
	.tx_data(din),
	.tx_start(din_start),
	.tx_end_pos(din_end_pos),
	
	// RX from Ethernet
	.clk_rx(clk_rxmac),
	.rx_valid(0),
	.rx_data(0),
	.rx_start(0),
	.rx_end_pos(0),
	
	// status register bus
	.clk_status(clk_status),
	.status_addr(status_addr),
	.status_read(status_read),
	.status_write(status_write),
	.status_writedata(status_writedata),
	.status_readdata(status_readdata_pc),
	.status_readdata_valid(status_readdata_valid_pc)
);
defparam pc .SIM_NO_TEMP_SENSE  = SIM_NO_TEMP_SENSE;
defparam pc .DEVICE_FAMILY = "Arria 10";
defparam pc .WORDS = 2;

//////////////////////////////////////
// CFP control
//////////////////////////////////////

wire [31:0] status_readdata_cfp;
wire status_readdata_valid_cfp;
wire cfp_mdio_out, cfp_mdio_oe;
assign cfp_mdio = cfp_mdio_oe ? cfp_mdio_out : 1'bz;

wire xfp_sda_out, xfp_sda_oe;
wire xfp_scl_out, xfp_scl_oe;
//assign xfp_scl = xfp_scl_oe ? xfp_scl_out : 1'bz;
//assign xfp_sda = xfp_sda_oe ? xfp_sda_out : 1'bz;
wire xfp_scl_in, xfp_sda_in;
assign xfp_scl_in = 1'b0; //xfp_scl;
assign xfp_sda_in = 1'b0; //xfp_sda;

alt_e40_optics_control cc (

	// status register bus
	.clk_status(clk_status),
	.status_addr(status_addr),
	.status_read(status_read),
	.status_write(status_write),
	.status_writedata(status_writedata),
	.status_readdata(status_readdata_cfp),
	.status_readdata_valid(status_readdata_valid_cfp),	
	
	// CFP MDIO controls
	.cfp_mdc(cfp_mdc),
	.cfp_mdio_in(cfp_mdio),
	.cfp_mdio_out(cfp_mdio_out),
	.cfp_mdio_oe(cfp_mdio_oe), // active high
	.cfp_glb_alrm(cfp_glb_alrm),
	.cfp_prtadr(),//cfp_prtadr),	
	
	// CFP custom controls
	.cfp_mod_lopwr(cfp_mod_lopwr),
	.cfp_mod_rst(cfp_mod_rst), // active low
	.cfp_tx_dis(cfp_tx_dis),
	.cfp_mod_abs(cfp_mod_abs),
	.cfp_rx_los(cfp_rx_los),
	.cfp_prg_alrm(cfp_prg_alrm),
	.cfp_prg_cntl(cfp_prg_cntl),
	
	// XFP I2C controls
	.xfp_sda_in(xfp_sda_in),
	.xfp_sda_out(xfp_sda_out),
	.xfp_sda_oe(xfp_sda_oe),	// active high
	.xfp_scl_in(xfp_scl_in),
	.xfp_scl_out(xfp_scl_out),
	.xfp_scl_oe(xfp_scl_oe)	// active high
);

//////////////////////////////////////
// merge status bus
//////////////////////////////////////

wire [31:0] status_readdata;
wire status_readdata_valid, status_waitrequest;

alt_e40_avalon_mm_read_combine arc (
	.clk(clk_status),
	.host_read(status_read),
	.host_readdata(status_readdata),
	.host_readdata_valid(status_readdata_valid),
	.host_waitrequest(status_waitrequest),

	.client_readdata_valid(
		{status_readdata_valid_cfp, 
		status_readdata_valid_e40,
		status_readdata_valid_pc,
		reco_readdata_valid}),
	.client_readdata(
		{status_readdata_cfp,
		status_readdata_e40,
		status_readdata_pc,
		reco_readdata})		

);
defparam arc .NUM_CLIENTS = 4;
	
//////////////////////////////////////
// JTAG host port
//////////////////////////////////////
	
generate 
if (!SIM_NO_JTAG) begin

	// TODO
	// this guy doesn't support wait yet, but it is SLOOw.
	// ... so it will wait in practice.
	
	if (TERM_STYLE_JTAG) begin
		alt_e40_jtag_term_master jm (
			.clk(clk_status),
			.arst(~sp100_locked),
			
			.mm_addr(status_addr),
			.mm_read(status_read),
			.mm_write(status_write),
			.mm_writedata(status_writedata),
			
			.mm_readdata(status_readdata),
			.mm_readdata_valid(status_readdata_valid)
		);
	end
	else begin
		wire [31:0] av_addr;
		assign status_addr = av_addr[17:2];
		jtag_sys_console_master jsm (
			.clk(clk_status),
			.arst(~sp100_locked),
			
			.addr(av_addr),
			.read(status_read),
			.write(status_write),
			.writedata(status_writedata),
			
			.readdata(status_readdata),
			.readdata_valid(status_readdata_valid),
			.waitreq(status_waitrequest)
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
