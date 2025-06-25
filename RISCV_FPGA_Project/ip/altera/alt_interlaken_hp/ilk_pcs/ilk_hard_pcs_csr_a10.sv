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


// Copyright 2012 Altera Corporation. All rights reserved.
// Altera products are protected under numerous U.S. and foreign patents,
// maskwork rights, copyrights and other intellectual property laws.
//
// This reference design file, and your use thereof, is subject to and governed
// by the terms and conditions of the applicable Altera Reference Design
// License Agreement (either as signed by you or found at www.altera.com).  By
// using this reference design file, you indicate your acceptance of such terms
// and conditions between you and Altera Corporation.  In the event that you do
// not agree with such terms and conditions, you may not use the reference
// design file and please promptly destroy any copies you have made.
//
// This reference design file is being provided on an "as-is" basis and as an
// accommodation and therefore all warranties, representations or guarantees of
// any kind (whether express, implied or statutory) including, without
// limitation, warranties of merchantability, non-infringement, or fitness for
// a particular purpose, are specifically disclaimed.  By making this reference
// design file available, Altera expressly does not recommend, suggest or
// require that this reference design file be used in combination with any 
// other product not provided by Altera.
/////////////////////////////////////////////////////////////////////////////

`timescale 1 ps / 1 ps

module ilk_hard_pcs_csr_a10 #(
    parameter           NUM_LANES = 8,
    parameter           NUM_PLLS = 8,
    parameter           INCLUDE_TEMP_SENSE = 1'b1,
    parameter           MM_CLK_KHZ = 20'd100_000            // 75_000 to 125_000
)(
    input                               mm_clk,         // 75-125 MHz
    input                               mm_clk_locked,
    input                               mm_read,
    input                               mm_write,
    input [15:0]                        mm_addr,
    output [31:0]                       mm_rdata2,     // conbined with reconfig_readdata 
    output reg                          mm_rdata_valid,
    input [31:0]                        mm_wdata,

    // clocks to monitor
    input                               pll_ref_clk,
    input                               clk_rx_common,
    input                               srst_rx_common,
    input                               clk_tx_common,

    // status inputs
    input [NUM_PLLS-1:0]                tx_pll_locked,
    input [NUM_LANES-1:0]               tx_align_empty,
    input [NUM_LANES-1:0]               tx_align_pempty,
    input [NUM_LANES-1:0]               tx_align_full,
    input [NUM_LANES-1:0]               tx_align_pfull,
    input                               any_tx_frame,
    input                               all_tx_full,
    input                               any_tx_full,
    input                               any_tx_empty,
    input [2:0]                         txa_sm,
    input                               tx_lanes_aligned,

    input [NUM_LANES-1:0]               rx_deskew_empty,
    input [NUM_LANES-1:0]               rx_deskew_pempty,
    input [NUM_LANES-1:0]               rx_deskew_full,
    input [NUM_LANES-1:0]               rx_deskew_pfull,
    input [NUM_LANES-1:0]               rx_is_lockedtodata,
    input                               any_loss_of_meta,
    input                               any_control,
    input                               all_control,
    input [4:0]                         rxa_timer,
    input [1:0]                         rxa_sm,
    input                               rx_lanes_aligned,
    input [NUM_LANES-1:0]               rx_wordlock,
    input [NUM_LANES-1:0]               rx_metalock,
    input [NUM_LANES-1:0]               rx_crc32err,
    input [NUM_LANES-1:0]               rx_sh_err,

    // control outputs
    output reg [NUM_LANES-1:0]          local_serial_loopback,
    output reg                          rx_set_locktodata,
    output reg                          rx_set_locktoref,
    output reg                          ignore_rx_analog,
    output reg                          ignore_rx_digital,
    output reg                          soft_rst_txrx,
    output reg                          soft_rst_rx,

    // Arria 10 special
    output                              reconfig_write,
    output                              reconfig_read,
    output [log2(NUM_LANES-1)+1+8:0]      reconfig_address,
    output [31:0]                       reconfig_writedata,
    input  [31:0]                       reconfig_readdata
);

wire    [19:0]                          pll_ref_khz;
wire    [19:0]                          rx_khz;
wire    [19:0]                          tx_khz;
reg     [27:0]                          cntr0;
reg     [23:0]                          sec_cntr;
wire    [7:0]                           degrees_f;
wire    [7:0]                           degrees_c;
wire                                    sclr_txerr_txc_sync;
reg                                     sticky_tx_loa = 1'b0;
wire    [(NUM_LANES*4)-1:0]             crc32_error_cnt;
wire    [NUM_LANES-1:0]                 rx_sherr_rxc_sync;
wire                                    sclr_rxerr_rxc_sync;
reg     [NUM_LANES-1:0]                 sticky_sherr = { NUM_LANES{ 1'b0 }};
reg                                     sticky_rx_loa = 1'b0;
wire                                    rx_lanes_aligned_mm_sync;
wire    [NUM_LANES-1:0]                 rx_wordlock_mm_sync;
wire    [NUM_LANES-1:0]                 rx_metalock_mm_sync;
wire                                    tx_lanes_aligned_mm_sync;
wire    [NUM_LANES-1:0]                 sticky_sherr_mm_sync;
wire                                    sticky_tx_loa_mm_sync;
wire                                    sticky_rx_loa_mm_sync;
wire                                    all_control_mm_sync;
wire                                    any_control_mm_sync;
wire                                    any_loss_of_meta_mm_sync;
wire                                    any_tx_frame_mm_sync;
wire                                    all_tx_full_mm_sync;
wire                                    any_tx_full_mm_sync;
wire                                    any_tx_empty_mm_sync;
wire    [1:0]                           rxa_sm_mm_sync;
wire    [4:0]                           rxa_timer_mm_sync;
wire    [2:0]                           txa_sm_mm_sync;
wire    [NUM_LANES*4-1:0]               crc32_error_cnt_mm_sync;
reg                                     sclr_txerr;
reg                                     sclr_rxerr;

//////////////////////////////////////////////
// clock monitors, uptime counter
//////////////////////////////////////////////

ilk_frequency_monitor #(
        .NUM_SIGNALS  ( 3 ),
        .REF_KHZ      ( MM_CLK_KHZ )
    ) fm (
        .signal       ( { pll_ref_clk,
                          clk_rx_common,
                          clk_tx_common } ),
        .ref_clk      ( mm_clk ),
        .khz_counters ( { pll_ref_khz,
                          rx_khz,
                          tx_khz } )
   );

always @( posedge mm_clk or negedge mm_clk_locked ) begin
    if( !mm_clk_locked ) begin
        cntr0 <= 0;
        sec_cntr <= 0;
    end else begin
        if( cntr0 == ( MM_CLK_KHZ * 1_000 - 1) ) begin
            sec_cntr <= sec_cntr + 1'b1;
            cntr0 <= 0;
        end
        else begin
            cntr0 <= cntr0 + 1'b1;
        end
    end
end

//////////////////////////////////////////////
// temp sense diode
//////////////////////////////////////////////

generate
    if( INCLUDE_TEMP_SENSE ) begin
        ilk_sv_temp_sense ts (
            .clk       ( mm_clk ),
            .degrees_c ( degrees_c ),
            .degrees_f ( degrees_f )
        );
    end
    else begin
        assign degrees_f = 8'h0;
        assign degrees_c = 8'h0;
    end
endgenerate

//////////////////////////////////////////////
// make abnormal TX status sticky
//////////////////////////////////////////////

ilk_status_sync #( .WIDTH( 1 ) ) sclr_txerr_sync (
        .clk            ( clk_tx_common ),
        .din            ( sclr_txerr ),
        .dout           ( sclr_txerr_txc_sync )
    );

always @( posedge clk_tx_common ) begin
    if( sclr_txerr_txc_sync ) begin
        sticky_tx_loa <= 1'b0;
    end
    else begin
        sticky_tx_loa <= sticky_tx_loa | !tx_lanes_aligned;
    end
end

//////////////////////////////////////////////
// count crc32 errors for easier visibility
//////////////////////////////////////////////

wire [NUM_LANES-1:0] rx_crc32err_s;
ilk_status_sync #( .WIDTH( NUM_LANES ) ) rx_crc32err_sync (.clk(clk_rx_common),.din(rx_crc32err),.dout(rx_crc32err_s));
genvar i;
generate
    for( i = 0; i < NUM_LANES; i = i + 1 ) begin : ecnt
        reg [3:0] local_cnt;

        always @( posedge clk_rx_common or posedge srst_rx_common) begin
            if(srst_rx_common) begin
                local_cnt <= 4'h0;
            end
            else if( sclr_rxerr_rxc_sync ) begin
                local_cnt <= 4'h0;
            end
            else begin
                if( rx_crc32err_s[i] ) begin
                    // saturate rather than wrapping
                    if( ~&local_cnt )
                        local_cnt <= local_cnt + 1'b1;
                end
            end
        end

        assign crc32_error_cnt[(i+1)*4-1:i*4] = local_cnt;
    end
endgenerate

//////////////////////////////////////////////
// make abnormal RX status sticky
//////////////////////////////////////////////

ilk_status_sync #( .WIDTH( NUM_LANES ) ) rx_sh_err_sync (
        .clk            ( clk_rx_common),
        .din            ( rx_sh_err ),
        .dout           ( rx_sherr_rxc_sync )
    );

ilk_status_sync #( .WIDTH( 1 ) ) sclr_rxerr_sync (
        .clk            ( clk_rx_common ),
        .din            ( sclr_rxerr ),
        .dout           ( sclr_rxerr_rxc_sync )
    );

always @( posedge clk_rx_common ) begin
    if( sclr_rxerr_rxc_sync ) begin
        sticky_sherr <= { NUM_LANES{ 1'b0 }};
        sticky_rx_loa <= 1'b0;
    end
    else begin
        sticky_sherr <= sticky_sherr | rx_sherr_rxc_sync;
        sticky_rx_loa <= sticky_rx_loa | !rx_lanes_aligned;
    end
end

///////////////////////////////////////////////////
// Synchronize status inputs to the managment clock
///////////////////////////////////////////////////

ilk_status_sync #( .WIDTH( 21 + ( NUM_LANES * 7 ) ) ) rx_sync_to_mm (
        .clk  ( mm_clk ),
        .din  ( { rx_lanes_aligned, // 1
                  rx_wordlock,      // NUM_LANES
                  rx_metalock,      // NUM_LANES
                  tx_lanes_aligned, // 1
                  sticky_sherr,     // NUM_LANES
                  sticky_tx_loa,    // 1
                  sticky_rx_loa,    // 1
                  all_control,      // 1
                  any_control,      // 1
                  any_loss_of_meta, // 1
                  any_tx_frame,     // 1
                  all_tx_full,      // 1
                  any_tx_full,      // 1
                  any_tx_empty,     // 1
                  rxa_sm,           // 2
                  rxa_timer,        // 5
                  txa_sm,           // 3
                  crc32_error_cnt   // NUM_LANES * 4
            } ),
        .dout ( { rx_lanes_aligned_mm_sync,
                  rx_wordlock_mm_sync,
                  rx_metalock_mm_sync,
                  tx_lanes_aligned_mm_sync,
                  sticky_sherr_mm_sync,
                  sticky_tx_loa_mm_sync,
                  sticky_rx_loa_mm_sync,
                  all_control_mm_sync,
                  any_control_mm_sync,
                  any_loss_of_meta_mm_sync,
                  any_tx_frame_mm_sync,
                  all_tx_full_mm_sync,
                  any_tx_full_mm_sync,
                  any_tx_empty_mm_sync,
                  rxa_sm_mm_sync,
                  rxa_timer_mm_sync,
                  txa_sm_mm_sync,
                  crc32_error_cnt_mm_sync
            } )
    );

//////////////////////////////////////////////
// Service reads issued by the top level
//////////////////////////////////////////////

wire [32*4-1:0] padded_crc32_cnt = { (32*4){ 1'b0 }} | crc32_error_cnt_mm_sync;


reg [31:0] mm_rdata;

always @( posedge mm_clk or negedge mm_clk_locked ) begin
    if( !mm_clk_locked ) begin
        mm_rdata_valid <= 1'b0;
        mm_rdata <= 32'h0;
    end
    else begin
        mm_rdata_valid <= 1'b0;

        if( mm_read ) begin
            mm_rdata_valid <= 1'b1;
            case( mm_addr[5:0] )
            6'h0 : begin
                // cookie / version
                mm_rdata <= { "HSj", 8'h1 };
            end
            6'h1 : begin
                mm_rdata <= 32'h0 | NUM_LANES[7:0];
            end
            6'h2 : begin
                mm_rdata[31:16] <= 'h0;
                mm_rdata[15:8]  <= degrees_c;
                mm_rdata[7:0]   <= degrees_f;
            end
            6'h3 : begin
                // seconds since powerup
                mm_rdata <= 32'h0 | sec_cntr;
            end
            6'h4 : begin
                mm_rdata <= 32'h0 | tx_align_empty;
            end
            6'h5 : begin
                mm_rdata <= 32'h0 | tx_align_full;
            end
            6'h6 : begin
                mm_rdata <= 32'h0 | tx_align_pempty;
            end
            6'h7 : begin
                mm_rdata <= 32'h0 | tx_align_pfull;
            end
            6'h8 : begin
                mm_rdata <= 32'h0 | rx_deskew_empty;
            end
            6'h9 : begin
                mm_rdata <= 32'h0 | rx_deskew_full;
            end
            6'ha : begin
                mm_rdata <= 32'h0 | rx_deskew_pempty;
            end
            6'hb : begin
                mm_rdata <= 32'h0 | rx_deskew_pfull;
            end
            6'hc : begin
                mm_rdata <= 32'h0 | pll_ref_khz;
            end
            6'hd : begin
                mm_rdata <= 32'h0 | rx_khz;
            end
            6'he : begin
                mm_rdata <= 32'h0 | tx_khz;
            end
            6'h10 : begin
                mm_rdata <= 32'h0 | tx_pll_locked;
            end
            6'h11 : begin
                mm_rdata <= 32'h0 | rx_is_lockedtodata;
            end
            6'h12 : begin
                mm_rdata <= 32'h0 | local_serial_loopback;
            end
            6'h13 : begin
                mm_rdata[31:10] <= 'h0;
                mm_rdata[9] <= rx_set_locktodata;
                mm_rdata[8] <= rx_set_locktoref;
                mm_rdata[7] <= sclr_txerr;
                mm_rdata[6] <= sclr_rxerr;
                mm_rdata[5] <= 1'b0;
                mm_rdata[4] <= ignore_rx_analog;
                mm_rdata[3] <= 1'b0;
                mm_rdata[2] <= soft_rst_txrx;
                mm_rdata[1] <= soft_rst_rx;
                mm_rdata[0] <= ignore_rx_digital;
            end
            6'h20 : begin
                mm_rdata[31:21] <= 'h0;
                mm_rdata[20] <= any_tx_frame_mm_sync;
                mm_rdata[19] <= all_tx_full_mm_sync;
                mm_rdata[18] <= any_tx_full_mm_sync;
                mm_rdata[17] <= any_tx_empty_mm_sync;
                mm_rdata[16] <= all_tx_full_mm_sync;
                mm_rdata[15:13] <= txa_sm_mm_sync;
                mm_rdata[12] <= tx_lanes_aligned_mm_sync;
                mm_rdata[11] <= any_loss_of_meta_mm_sync;
                mm_rdata[10] <= any_control_mm_sync;
                mm_rdata[9] <= all_control_mm_sync;
                mm_rdata[8:4] <= rxa_timer_mm_sync;
                mm_rdata[3:2] <= rxa_sm_mm_sync;
                mm_rdata[1] <= 1'b0;
                mm_rdata[0] <= rx_lanes_aligned_mm_sync;
            end
            6'h21 : begin
                mm_rdata <= 32'h0 | rx_wordlock_mm_sync;
            end
            6'h22 : begin
                mm_rdata <= 32'h0 | rx_metalock_mm_sync;
            end
            6'h23 : begin
                mm_rdata <= 32'h0 | padded_crc32_cnt[31:0];
            end
            6'h24 : begin
                mm_rdata <= 32'h0 | padded_crc32_cnt[63:32];
            end
            6'h25 : begin
                mm_rdata <= 32'h0 | padded_crc32_cnt[95:64];
            end
            6'h26 : begin
                mm_rdata <= 32'h0 | padded_crc32_cnt[127:96];
            end
            6'h27 : begin
                mm_rdata <= 32'h0 | sticky_sherr_mm_sync;
            end
            6'h28 : begin
                mm_rdata <= 32'h0 | sticky_rx_loa_mm_sync;
            end
            6'h29 : begin
                mm_rdata <= 32'h0 | sticky_tx_loa_mm_sync;
            end
            default : begin
                mm_rdata <= 32'h0bad_0bad;
            end
            endcase
        end
    end
end

//////////////////////////////////////////////
// Service writes issued by the top level
//////////////////////////////////////////////
always @( posedge mm_clk or negedge mm_clk_locked ) begin
    if( !mm_clk_locked ) begin
        rx_set_locktodata <= 1'b0;
        rx_set_locktoref <= 1'b0;
        local_serial_loopback <= { NUM_LANES{ 1'b0 }};
        ignore_rx_analog <= 1'b0;
        soft_rst_txrx <= 1'b0;
        soft_rst_rx <= 1'b0;
        ignore_rx_digital <= 1'b0;
        sclr_txerr <= 1'b0;
        sclr_rxerr <= 1'b0;
    end
    else begin
        if( mm_write ) begin
            case( mm_addr[5:0] )
            6'h12 : begin
                local_serial_loopback <= mm_wdata[NUM_LANES-1:0];
            end
            6'h13 : begin
                rx_set_locktodata <= mm_wdata[9];
                rx_set_locktoref <= mm_wdata[8];
                sclr_txerr <= mm_wdata[7];
                sclr_rxerr <= mm_wdata[6];
                ignore_rx_analog <= mm_wdata[4];
                soft_rst_txrx <= mm_wdata[2];
                soft_rst_rx <= mm_wdata[1];
                ignore_rx_digital <= mm_wdata[0];
            end
            default : begin
                // invalid address - nothing to do
            end
            endcase
        end
    end
end

// reconfiguration control register access
assign reconfig_write      = mm_addr[14] ? mm_write : 1'b0;
assign reconfig_read       = mm_addr[14] ? mm_read  : 1'b0;
assign reconfig_address    = mm_addr[14] ? mm_addr[11:0]  : 12'b0;
assign reconfig_writedata  = mm_addr[14] ? mm_wdata  : 32'b0;
assign mm_rdata2           = mm_addr[14] ? reconfig_readdata : mm_rdata;

// NOTE: this is not a rigorous mathematical definition of LOG2(v).
// This function computes the number of bits required to represent "v".
// So log2(256) will be  9 rather than 8 (256 = 9'b1_0000_0000).

function integer log2;
   input integer val;
begin
   if (val == 0) begin
      log2 = 1;
   end
   else begin
      log2 = 0;
      while (val > 0) begin
         val  = val >> 1;
         log2 = log2 + 1;
      end
   end
end
endfunction

endmodule

