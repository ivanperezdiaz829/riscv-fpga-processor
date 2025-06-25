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


import alt_vip_common_pkg::alt_clogb2_pure;

module alt_vip_cvi_core
    #(parameter
        USE_EMBEDDED_SYNCS = 1,
        STD_WIDTH = 3,
        BPS = 10,
        GENERATE_ANC = 0,
        GENERATE_VID_F = 0,
        CLOCKS_ARE_SAME = 0,
        NUMBER_OF_COLOUR_PLANES = 2,
        COLOUR_PLANES_ARE_IN_PARALLEL = 1,
        PIXELS_IN_PARALLEL = 1,
        FIFO_DEPTH = 1920,
        FAMILY = "Stratix II",
        INTERLACED = 1,
        H_ACTIVE_PIXELS = 1920,
        V_ACTIVE_LINES_F0 = 540,
        V_ACTIVE_LINES_F1 = 540,
        SYNC_TO = 2,
        USE_CHANNEL = 0,
        CHANNEL_WIDTH = 1,
        ANC_DEPTH = 8,
        USE_CONTROL = 1)
    (
    rst,
    
    // video
    vid_clk,
    vid_data,
    vid_de,
    vid_datavalid,
    vid_locked,
    vid_channel,
    
    // optional video ports
    vid_f,
    vid_v_sync,
    vid_h_sync,
    vid_hd_sdn,
    vid_std,
    vid_color_encoding,
    vid_bit_width,
    
    // IS
    is_clk,
    
    av_st_cmd_ready,
    av_st_cmd_valid,
    av_st_cmd_startofpacket,
    av_st_cmd_endofpacket,
    av_st_cmd_data,
    
    av_st_dout_ready,
    av_st_dout_valid,
    av_st_dout_startofpacket,
    av_st_dout_endofpacket,
    av_st_dout_data,
    av_st_dout_channel,
    
    // Control
    av_address,
    av_read,
    av_readdata,
    av_write,
    av_writedata,
    av_byteenable,
    av_waitrequest,
    
    // Interrupt
    status_update_int,
    
    // sync
    sof,
    sof_locked,
    refclk_div,
    
    // Error
    overflow
);

localparam USED_WORDS_WIDTH = alt_clogb2_pure(FIFO_DEPTH);
localparam DATA_WIDTH = (COLOUR_PLANES_ARE_IN_PARALLEL) ? BPS * NUMBER_OF_COLOUR_PLANES * PIXELS_IN_PARALLEL : BPS;
localparam RAM_SIZE = ANC_DEPTH + 15;
localparam ANC_ADDRESS_WIDTH = (alt_clogb2_pure(RAM_SIZE) < 5) ? 5 : alt_clogb2_pure(RAM_SIZE);
localparam OUTPUT_DATA_WIDTH = DATA_WIDTH + 1; // +1 because the TID is appended

input  wire rst;

// video
input  wire vid_clk;
input  wire [DATA_WIDTH-1:0] vid_data;
input  wire vid_de;
input  wire vid_datavalid;
input  wire vid_locked;
input  wire [CHANNEL_WIDTH-1:0] vid_channel;

// optional video ports
input  wire vid_f;
input  wire vid_v_sync;
input  wire vid_h_sync;
input  wire vid_hd_sdn;
input  wire [STD_WIDTH-1:0] vid_std;
input  wire [7:0] vid_color_encoding;
input  wire [7:0] vid_bit_width;

// IS
input  wire is_clk;

input  wire av_st_cmd_ready;
output wire av_st_cmd_valid;
output wire av_st_cmd_startofpacket;
output wire av_st_cmd_endofpacket;
output wire [32:0] av_st_cmd_data;

input  wire av_st_dout_ready;
output wire av_st_dout_valid;
output wire av_st_dout_startofpacket;
output wire av_st_dout_endofpacket;
output wire [OUTPUT_DATA_WIDTH-1:0] av_st_dout_data;
output wire [CHANNEL_WIDTH-1:0] av_st_dout_channel;
output wire av_waitrequest;

// Control
input  wire [ANC_ADDRESS_WIDTH-1:0] av_address;
input  wire av_read;
output wire [31:0] av_readdata;
input  wire av_write;
input  wire [31:0] av_writedata;
input  wire [3:0] av_byteenable;

// Interrupt
output wire status_update_int;

// Sync
output wire sof;
output wire sof_locked;
output wire refclk_div;

// Error
output wire overflow;

wire vid_clk_int;
generate begin : clocks_are_same_generate
     if(CLOCKS_ARE_SAME) begin
         assign vid_clk_int = is_clk;
     end else begin
         assign vid_clk_int = vid_clk;
     end
end endgenerate

reg rst_vid_clk_reg;
reg rst_vid_clk_reg2;

always @(negedge vid_locked or posedge vid_clk_int) begin
    if(!vid_locked) begin
       rst_vid_clk_reg <= 1'b1;
       rst_vid_clk_reg2 <= 1'b1;
    end else begin
       rst_vid_clk_reg <= 1'b0;
       rst_vid_clk_reg2 <= rst_vid_clk_reg;
    end
end

wire rst_vid_clk;
assign rst_vid_clk = rst_vid_clk_reg2;

wire [DATA_WIDTH-1:0] cond_vid_data;
wire cond_vid_de;
wire cond_vid_datavalid;
wire [CHANNEL_WIDTH-1:0] cond_vid_channel;
wire cond_vid_f;
wire cond_vid_v_sync;
wire cond_vid_h_sync;
wire cond_vid_hd_sdn;
wire [STD_WIDTH-1:0] cond_vid_std;
wire [7:0] cond_vid_color_encoding;
wire [7:0] cond_vid_bit_width;

wire [ANC_ADDRESS_WIDTH-1:0] sync_cond_mem_address;
wire sync_cond_mem_write;
wire [15:0] sync_cond_mem_data;

alt_vip_cvi_sync_conditioner #(
        .USE_EMBEDDED_SYNCS(USE_EMBEDDED_SYNCS),
        .DATA_WIDTH(DATA_WIDTH),
        .STD_WIDTH(STD_WIDTH),
        .BPS(BPS),
        .GENERATE_ANC(GENERATE_ANC),
        .ANC_ADDRESS_WIDTH(ANC_ADDRESS_WIDTH),
        .GENERATE_VID_F(GENERATE_VID_F))
    sync_conditioner(
        .rst(rst_vid_clk),
        .clk(vid_clk_int),
        
        // raw input signals
        .vid_data(vid_data),
        .vid_de(vid_de),
        .vid_datavalid(vid_datavalid),
        .vid_channel(vid_channel),
        .vid_f(vid_f),
        .vid_v_sync(vid_v_sync),
        .vid_h_sync(vid_h_sync),
        .vid_hd_sdn(vid_hd_sdn),
        .vid_std(vid_std),
        .vid_color_encoding(vid_color_encoding),
        .vid_bit_width(vid_bit_width),
        
        // conditioned output signals
        .cond_vid_data(cond_vid_data),
        .cond_vid_de(cond_vid_de),
        .cond_vid_datavalid(cond_vid_datavalid),
        .cond_vid_channel(cond_vid_channel),
        .cond_vid_f(cond_vid_f),
        .cond_vid_v_sync(cond_vid_v_sync),
        .cond_vid_h_sync(cond_vid_h_sync),
        .cond_vid_hd_sdn(cond_vid_hd_sdn),
        .cond_vid_std(cond_vid_std),
        .cond_vid_color_encoding(cond_vid_color_encoding),
        .cond_vid_bit_width(cond_vid_bit_width),
        
        .ram_address(sync_cond_mem_address),
        .ram_we(sync_cond_mem_write),
        .ram_data(sync_cond_mem_data));

wire [4:0] res_det_mem_address;
wire res_det_mem_write;
wire [15:0] res_det_mem_write_data;
wire res_det_mem_stall;

wire [4:0] av_st_out_mem_address;
wire av_st_out_mem_read;
wire [15:0] av_st_out_mem_read_data;

wire fifo_overflow;
wire fifo_overflow_synced;
wire [USED_WORDS_WIDTH-1:0] read_usedw;
wire vid_locked_synced;
wire status_update;
wire status_update_synced;
wire enable;
wire enable_synced;
wire vid_locked_lost;
wire start_of_frame;
wire start_of_frame_synced;

alt_vip_common_sync #(
        .CLOCKS_ARE_SAME(CLOCKS_ARE_SAME),
        .WIDTH(1))
    status_update_clock_crossing(
        .rst(rst),
        .sync_clock(is_clk),
        .data_in(status_update),
        .data_out(status_update_synced));

alt_vip_common_sync #(
        .CLOCKS_ARE_SAME(CLOCKS_ARE_SAME),
        .WIDTH(1))
    vid_locked_clock_crossing(
        .rst(rst),
        .sync_clock(is_clk),
        .data_in(vid_locked),
        .data_out(vid_locked_synced));

alt_vip_common_sync #(
        .CLOCKS_ARE_SAME(CLOCKS_ARE_SAME),
        .WIDTH(1))
    start_of_frame_clock_crossing(
        .rst(rst),
        .sync_clock(is_clk),
        .data_in(start_of_frame),
        .data_out(start_of_frame_synced));

alt_vip_common_sync #(
        .CLOCKS_ARE_SAME(CLOCKS_ARE_SAME),
        .WIDTH(1))
    overflow_clock_crossing(
        .rst(rst),
        .sync_clock(is_clk),
        .data_in(fifo_overflow),
        .data_out(fifo_overflow_synced));

alt_vip_cvi_control #(
        .ANC_ADDRESS_WIDTH(ANC_ADDRESS_WIDTH),
        .RAM_SIZE(RAM_SIZE),
        .USED_WORDS_WIDTH(USED_WORDS_WIDTH),
        .USE_CONTROL(USE_CONTROL))
    control(
        .rst(rst_vid_clk),
        .clk(vid_clk_int),
    
        .sync_cond_mem_address(sync_cond_mem_address),
        .sync_cond_mem_write(sync_cond_mem_write),
        .sync_cond_mem_data(sync_cond_mem_data),
    
        .res_det_mem_address(res_det_mem_address),
        .res_det_mem_write(res_det_mem_write),
        .res_det_mem_write_data(res_det_mem_write_data),
        .res_det_mem_stall(res_det_mem_stall),
    
        .is_rst(rst),
        .is_clk(is_clk),
    
        .av_address(av_address),
        .av_read(av_read),
        .av_readdata(av_readdata),
        .av_write(av_write),
        .av_writedata(av_writedata),
        .av_byteenable(av_byteenable),
        .av_waitrequest(av_waitrequest),
        .status_update_int(status_update_int),
    
        .av_st_out_mem_address(av_st_out_mem_address),
        .av_st_out_mem_read(av_st_out_mem_read),
        .av_st_out_mem_read_data(av_st_out_mem_read_data),
    
        .overflow(fifo_overflow_synced),
        .read_usedw(read_usedw),
        .vid_locked(vid_locked_synced),
        .start_of_frame(start_of_frame_synced),
        .status_update(status_update_synced),
        
        .go(enable),
        .vid_locked_lost(vid_locked_lost));

alt_vip_common_sync #(
        .CLOCKS_ARE_SAME(CLOCKS_ARE_SAME),
        .WIDTH(1))
    enable_clock_crossing(
        .rst(rst_vid_clk),
        .sync_clock(vid_clk_int),
        .data_in(enable),
        .data_out(enable_synced));
        
alt_vip_cvi_resolution_detection #(
        .NUMBER_OF_COLOUR_PLANES(NUMBER_OF_COLOUR_PLANES),
        .COLOUR_PLANES_ARE_IN_PARALLEL(COLOUR_PLANES_ARE_IN_PARALLEL),
        .PIXELS_IN_PARALLEL(PIXELS_IN_PARALLEL),
        .CHANNEL_WIDTH(CHANNEL_WIDTH),
        .INTERLACED(INTERLACED),
        .H_ACTIVE_PIXELS(H_ACTIVE_PIXELS),
        .V_ACTIVE_LINES_F0(V_ACTIVE_LINES_F0),
        .V_ACTIVE_LINES_F1(V_ACTIVE_LINES_F1),
        .STD_WIDTH(STD_WIDTH))
    resolution_detection(
        .rst(rst_vid_clk),
        .clk(vid_clk_int),
        
        .cond_vid_de(cond_vid_de),
        .cond_vid_datavalid(cond_vid_datavalid),
        .cond_vid_channel(cond_vid_channel),
        .cond_vid_f(cond_vid_f),
        .cond_vid_v_sync(cond_vid_v_sync),
        .cond_vid_h_sync(cond_vid_h_sync),
        .cond_vid_hd_sdn(cond_vid_hd_sdn),
        .cond_vid_std(cond_vid_std),
        .cond_vid_color_encoding(cond_vid_color_encoding),
        .cond_vid_bit_width(cond_vid_bit_width),
        
        .mem_address(res_det_mem_address),
        .mem_write(res_det_mem_write),
        .mem_write_data(res_det_mem_write_data),
        .mem_stall(res_det_mem_stall),
        
        .status_update(status_update),
        
        .sof(sof),
        .sof_locked(sof_locked),
        .refclk_div(refclk_div));

wire fifo_read_req;
wire fifo_read_valid;
wire [DATA_WIDTH-1:0] fifo_read_data;
wire [CHANNEL_WIDTH-1:0] fifo_read_channel;
wire fifo_read_packet;
wire fifo_read_empty;

alt_vip_cvi_write_fifo_buffer #(
        .DATA_WIDTH(DATA_WIDTH),
        .USE_CHANNEL(USE_CHANNEL),
        .CHANNEL_WIDTH(CHANNEL_WIDTH),
        .NUMBER_OF_COLOUR_PLANES(NUMBER_OF_COLOUR_PLANES),
        .BPS(BPS),
        .CLOCKS_ARE_SAME(CLOCKS_ARE_SAME),
        .FIFO_DEPTH(FIFO_DEPTH),
        .DEVICE_FAMILY(FAMILY),
        .SYNC_TO(SYNC_TO),
        .USED_WORDS_WIDTH(USED_WORDS_WIDTH),
        .COLOUR_PLANES_ARE_IN_PARALLEL(COLOUR_PLANES_ARE_IN_PARALLEL))
    write_fifo_buffer(
        .rst(rst_vid_clk),
        .clk(vid_clk_int),
        
        .enable(enable_synced),
        
        .cond_vid_data(cond_vid_data),
        .cond_vid_de(cond_vid_de),
        .cond_vid_datavalid(cond_vid_datavalid),
        .cond_vid_channel(cond_vid_channel),
        .cond_vid_v_sync(cond_vid_v_sync),
        .cond_vid_hd_sdn(cond_vid_hd_sdn),
        .cond_vid_f(cond_vid_f),
        
        .fifo_overflow(fifo_overflow),
        .overflow(overflow),
        .start_of_frame(start_of_frame),
        
        .read_clock(is_clk),
        .read_reset(rst),
        .read_req(fifo_read_req),
        .read_valid(fifo_read_valid),
        .read_data(fifo_read_data),
        .read_channel(fifo_read_channel),
        .read_packet(fifo_read_packet),
        .read_empty(fifo_read_empty),
        .read_usedw(read_usedw));

alt_vip_cvi_av_st_output #(
        .DATA_WIDTH(DATA_WIDTH),
        .OUTPUT_DATA_WIDTH(OUTPUT_DATA_WIDTH),
        .CHANNEL_WIDTH(CHANNEL_WIDTH))
    av_st_output(
        .rst(rst),
        .clk(is_clk),
        
        .mem_read(av_st_out_mem_read),
        .mem_address(av_st_out_mem_address),
        .mem_read_data(av_st_out_mem_read_data),
        
        .vid_locked_lost(vid_locked_lost),
        
        .fifo_read_req(fifo_read_req),
        .fifo_read_valid(fifo_read_valid),
        .fifo_read_data(fifo_read_data),
        .fifo_read_channel(fifo_read_channel),
        .fifo_read_packet(fifo_read_packet),
        .fifo_read_empty(fifo_read_empty),
        
        // connections to the video output bridge
        .av_st_cmd_ready(av_st_cmd_ready),
        .av_st_cmd_valid(av_st_cmd_valid),
        .av_st_cmd_startofpacket(av_st_cmd_startofpacket),
        .av_st_cmd_endofpacket(av_st_cmd_endofpacket),
        .av_st_cmd_data(av_st_cmd_data),
        
        .av_st_dout_ready(av_st_dout_ready),
        .av_st_dout_valid(av_st_dout_valid),
        .av_st_dout_startofpacket(av_st_dout_startofpacket),
        .av_st_dout_endofpacket(av_st_dout_endofpacket),
        .av_st_dout_data(av_st_dout_data),
        .av_st_dout_channel(av_st_dout_channel));

endmodule
