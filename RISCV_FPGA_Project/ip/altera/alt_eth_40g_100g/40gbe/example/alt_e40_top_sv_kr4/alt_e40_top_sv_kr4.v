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

module alt_e40_top_sv_kr4
(
    input clk50,
    input cpu_resetn,

    // 10G IO
    input clk_ref_r,
    input [3:0] rx_serial_r,
    output [3:0] tx_serial_r
    
);
parameter TERM_STYLE_JTAG = 1'b1; // vs sys console

parameter WORDS = 2;

parameter FAST_SIMULATION = 0; 
parameter SIM_NO_JTAG     = 1'b0;
parameter SIM_NO_TEMP_SENSE = 1'b0;

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
wire clk_txmac = clk320;     // nominal 312
wire [WORDS*64-1:0] din;     // payload to send, regular left to right
wire [WORDS-1:0] din_start; // start position, first of every 8 bytes
wire [WORDS*8-1:0] din_end_pos; // end position, any byte
wire din_ack;             // payload is accepted

// output domain (from pins toward user logic)
wire clk_rxmac = clk320;            // nominal 312
wire [WORDS*64-1:0] dout_d;        // 2 word out stream, regular left to right
wire [WORDS*8-1:0] dout_c;
wire [WORDS-1:0] dout_first_data;
wire [WORDS*8-1:0] dout_last_data;
wire [WORDS-1:0] dout_runt_last_data;
wire [WORDS-1:0] dout_payload;
wire dout_fcs_error;
wire dout_fcs_valid;
wire dout_valid;

wire    [367:0] reconfig_from_xcvr;
wire    [559:0] reconfig_to_xcvr;

wire  [6-1:0]    seq_pcs_mode;
wire  [4*6-1:0]  seq_pma_vod;
wire  [4*5-1:0]  seq_pma_postap1;
wire  [4*4-1:0]  seq_pma_pretap;
wire  [4-1:0]    seq_start_rc;
wire  [4-1:0]    lt_start_rc;
wire  [4*3-1:0]  tap_to_upd;  
wire  [4-1:0]    hdsk_rc_busy;
wire  [4-1:0]    baser_ll_mif_done;
wire  [4-1:0]    dfe_start_rc;
wire  [4*2-1:0]  dfe_mode;
wire  [4-1:0]    ctle_start_rc;
wire  [4*4-1:0]  ctle_rc;
wire  [4*2-1:0]  ctle_mode;

ENET_ENTITY_QMEGA_06072013 ior (
    .mac_rx_arst_ST(arst),
    .mac_tx_arst_ST(arst),
    .pcs_rx_arst_ST(arst),
    .pcs_tx_arst_ST(arst),
    .pma_arst_ST(arst),

    // serdes
    .clk_ref(clk_ref_r),  // GX PLL reference
    .rx_serial(rx_serial_r),
    .tx_serial(tx_serial_r),

    // input domain (from user logic toward pins)
    .clk_txmac(clk_txmac),          // nominal 312
    .din(din),                  // payload to send, regular left to right
    .din_start(din_start),      // start position, first of every 8 bytes
    .din_end_pos(din_end_pos),  // end position, any byte
    .din_ack(din_ack),          // payload is accepted

    // output domain (from pins toward user logic)
    .clk_rxmac(clk_rxmac),                       // nominal 312
    .dout_d(dout_d),                           // 2 word out stream, regular left to right
    .dout_c(dout_c),
    .dout_first_data(dout_first_data),         // first data byte after preamble
    .dout_last_data(dout_last_data),           // last data byte before FCS
    .dout_runt_last_data(dout_runt_last_data), // last data of a packet < 64 bytes
    .dout_payload(dout_payload),               // user data, not control
    .dout_fcs_error(dout_fcs_error),           // referring to nonzero last data
    .dout_fcs_valid(dout_fcs_valid),
    .dout_dst_addr_match(),                       // on first word, DST matches a table entry
    .dout_valid(dout_valid),                   // bus has valid info from PCS

    // status register bus
    .clk_status(clk_status),
    .status_addr(status_addr),
    .status_read(status_read),
    .status_write(status_write),
    .status_writedata(status_writedata),
    .status_readdata(status_readdata_e40),
    .status_readdata_valid(status_readdata_valid_e40),

    // pause generation
    .pause_insert_tx(1'b0),    // LEDA
    .pause_insert_time(16'b0),    // LEDA
    .pause_insert_mcast(1'b0),    // LEDA
    .pause_insert_dst(48'b0),    // LEDA
    .pause_insert_src(48'b0),    // LEDA
    
    .reconfig_from_xcvr  (reconfig_from_xcvr[367:0]),          // output [367:0]
    .reconfig_to_xcvr    (reconfig_to_xcvr[559:0]),            // input [559:0]
    
    .rc_busy(hdsk_rc_busy),              // reconfig is busy servicing request
                                         // for lane [3:0] 
    .lt_start_rc(lt_start_rc),           // start the TX EQ reconfig for lane 3-0
    .main_rc(seq_pma_vod),               // main tap value for reconfig
    .post_rc(seq_pma_postap1),           // post tap value for reconfig
    .pre_rc(seq_pma_pretap),             // pre tap value for reconfig
    .tap_to_upd(tap_to_upd),             // specific TX EQ tap to update
                                         // bit-2 = main, bit-1 = post, ...
    .en_lcl_rxeq(/*unused*/),            // Enable local RX Equalization
    .rxeq_done(4'hF),                    // Local RX Equalization is finished
    .seq_start_rc(seq_start_rc),         // start the PCS reconfig for lane 3-0
    .dfe_start_rc(dfe_start_rc),         // start DFE reconfig for lane 3-0
    .dfe_mode(dfe_mode),                 // DFE mode 00=disabled, 01=triggered, 10=continuous
    .ctle_start_rc(ctle_start_rc),       // start CTLE reconfig for lane 3-0
    .ctle_rc(ctle_rc),                   // CTLE manual setting for lane 3-0
    .ctle_mode(ctle_mode),               // CTLE mode 00=manual, 01=one-time, 10=continuous
    .pcs_mode_rc(seq_pcs_mode),          // PCS mode for reconfig - 1 hot
                                         // bit 0 = AN mode = low_lat, PLL LTR, 66:40
                                         // bit 1 = LT mode = low_lat, PLL LTD, 66:40
                                         // bit 2 = (N/A) 10G data mode = 10GBASE-R, 66:40
                                         // bit 3 = (N/A) GigE data mode = 8G PCS
                                         // bit 4 = (N/A) XAUI data mode = future?
                                         // bit 5 = 10G-FEC/40G data mode = low lat, 64:64
    .reco_mif_done(|baser_ll_mif_done)  // PMA reconfiguration done (resets the PHYs)
    
);
//defparam ior.gen_40_inst.phy.phy_pcs.FAST_SIMULATION = FAST_SIMULATION;

//////////////////////////////////////
// reconfiguration bundle
//////////////////////////////////////

// map reconfig registers to 0x600-0x6FF
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
        status_addr_r <= 16'b0;
    end
    else if( !reco_waitrequest ) begin
        status_read_r <= status_read;
        status_write_r <= status_write;
        status_writedata_r <= status_writedata;
        status_addr_r <= status_addr;
    end
end

wire    reco_read = status_read_r && (status_addr_r[15:8]==9'b0000_0110);
wire    reco_write = status_write_r && (status_addr_r[15:8]==9'b0000_0110);
wire [7:0] reco_addr = (reco_read || reco_write) ? status_addr_r[7:0] : 8'b0;

assign    reco_readdata_valid = reco_read && !reco_waitrequest;

sv_rcn_bundle #(
    .PMA_RD_AFTER_WRITE(1),
    .PLLS(4),                 // virtual TX plls (pre-merge)
    .CHANNELS(4),             // arbitrary number of channels
    .MAP_PLLS(0),             // remap logical channels to account for PLLs?
    .SYNTH_1588_1G(0),        // GigE data-path is not 1588-enabled 
    .SYNTH_1588_10G(0),       // 10GBASE-R data-path is not 1588-enabled
    .KR_PHY_SYNTH_AN(1),      // AN enabled
    .KR_PHY_SYNTH_LT(1),      // LT enabled
    .KR_PHY_SYNTH_DFE(1),
    .KR_PHY_SYNTH_CTLE(1),
    .USER_RECONFIG_CONTROL(1),
    .USER_RCFG_PRIORITY(1),
    .KR_PHY_SYNTH_GIGE(0),    // GigE not enabled    
    .ENA_RECONFIG_CONTROLLER_DFE_RCFG(1),
    .ENA_RECONFIG_CONTROLLER_CTLE_RCFG(1),
    .DISABLE_CTLE_DFE_BEFORE_AN(2'b01), // disable DFE upon AN
    .PRI_RR(1)                // use round-robin priority in arbiter
) reco_bundle (
    .reconfig_clk(clk_status),
    .reconfig_reset(arst),

    .reconfig_from_xcvr(reconfig_from_xcvr),
    .reconfig_to_xcvr(reconfig_to_xcvr),
    .reconfig_mgmt_busy(), // unused

    .seq_pcs_mode({4{seq_pcs_mode}}),
    .seq_pma_vod(seq_pma_vod),
    .seq_pma_postap1(seq_pma_postap1),
    .seq_pma_pretap(seq_pma_pretap),
    .seq_start_rc(seq_start_rc),
    .lt_start_rc(lt_start_rc),
    .tap_to_upd(tap_to_upd),
    .hdsk_rc_busy(hdsk_rc_busy),
    .baser_ll_mif_done(baser_ll_mif_done),
    
    .dfe_start_rc      (dfe_start_rc),
    .dfe_mode          (dfe_mode),
    .ctle_start_rc     (ctle_start_rc),
    .ctle_rc           (ctle_rc),
    .ctle_mode         (ctle_mode),
    
    .avmm_address(reco_addr),
    .avmm_read(reco_read),
    .avmm_write(reco_write),
    .avmm_writedata(status_writedata_r[31:0]),
    .avmm_readdata(reco_readdata[31:0]),
    .avmm_waitrequest(reco_waitrequest)

);

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
    .rx_valid(dout_valid),
    .rx_data(dout_d),
    .rx_start(dout_first_data),
    .rx_end_pos(dout_last_data),
    
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
defparam pc .DEVICE_FAMILY = "Stratix V";
defparam pc .WORDS = 2;

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
        {status_readdata_valid_e40,
        status_readdata_valid_pc,
        reco_readdata_valid}),
    .client_readdata(
        {status_readdata_e40,
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
