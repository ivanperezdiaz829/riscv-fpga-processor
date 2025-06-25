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


import alt_vip_cvi_register_addresses::*;

module alt_vip_cvi_sync_conditioner
    #(parameter 
        USE_EMBEDDED_SYNCS = 1,
        DATA_WIDTH = 24,
        CHANNEL_WIDTH = 1,
        STD_WIDTH = 3,
        BPS = 10,
        GENERATE_ANC = 0,
        ANC_ADDRESS_WIDTH = 8,
        GENERATE_VID_F = 0)
    (
        input rst,
        input clk,
        
        // raw input signals
        input [DATA_WIDTH-1:0] vid_data,
        input vid_de,
        input vid_datavalid,
        input [CHANNEL_WIDTH-1:0] vid_channel,
        input vid_f,
        input vid_v_sync,
        input vid_h_sync,
        input vid_hd_sdn,
        input [STD_WIDTH-1:0] vid_std,
        input [7:0] vid_color_encoding,
        input [7:0] vid_bit_width,
        
        // conditioned output signals
        output [DATA_WIDTH-1:0] cond_vid_data,
        output cond_vid_de,
        output cond_vid_datavalid,
        output [CHANNEL_WIDTH-1:0] cond_vid_channel,
        output cond_vid_f,
        output cond_vid_v_sync,
        output cond_vid_h_sync,
        output cond_vid_hd_sdn,
        output [STD_WIDTH-1:0] cond_vid_std,
        output [7:0] cond_vid_color_encoding,
        output [7:0] cond_vid_bit_width,
        
        output [ANC_ADDRESS_WIDTH-1:0] ram_address,
        output ram_we,
        output [15:0] ram_data);
        
    reg [DATA_WIDTH-1:0] vid_data_reg;
    reg vid_de_reg;
    reg vid_datavalid_reg;
    reg [CHANNEL_WIDTH-1:0] vid_channel_reg;
    reg vid_v_sync_reg;
    reg vid_h_sync_reg;
    reg vid_hd_sdn_reg;
    reg [STD_WIDTH-1:0] vid_std_reg;
    reg [7:0] vid_color_encoding_reg;
    reg [7:0] vid_bit_width_reg;

    // Register the video input signals
    always @ (posedge rst or posedge clk) begin
        if(rst) begin
            vid_data_reg <= '0;
            vid_datavalid_reg <= 1'b0;
            vid_channel_reg <= '0;
            vid_hd_sdn_reg <= 1'b0;
            vid_std_reg <= '0;
            vid_color_encoding_reg <= '0;
            vid_bit_width_reg <= '0;
        end else begin
            vid_data_reg <= vid_data;
            vid_datavalid_reg <= vid_datavalid;
            vid_channel_reg <= vid_channel;
            vid_hd_sdn_reg <= vid_hd_sdn;
            vid_std_reg <= vid_std;
            vid_color_encoding_reg <= vid_color_encoding;
            vid_bit_width_reg <= vid_bit_width;
        end
    end
    
    assign cond_vid_std = vid_std_reg;
    assign cond_vid_color_encoding = vid_color_encoding_reg;
    assign cond_vid_bit_width = vid_bit_width_reg;        
    
    generate begin : use_embedded_syncs_generate
        if(USE_EMBEDDED_SYNCS) begin
            assign cond_vid_datavalid = vid_datavalid_reg;
        
            alt_vip_cvi_embedded_sync_extractor #(
                    .DATA_WIDTH(DATA_WIDTH),
                    .CHANNEL_WIDTH(CHANNEL_WIDTH),
                    .STD_WIDTH(STD_WIDTH),
                    .BPS(BPS),
                    .GENERATE_ANC(GENERATE_ANC),
                    .ANC_BASE_ADDRESS(REGISTER_ANC_BASE_ADDR),
                    .ANC_ADDRESS_WIDTH(ANC_ADDRESS_WIDTH))
                sync_extractor(
                    .rst(rst),
                    .clk(clk),
        
                    // video
                    .vid_data(vid_data_reg),
                    .vid_channel(vid_channel_reg),
                    .vid_datavalid(vid_datavalid_reg),
                    .vid_hd_sdn(vid_hd_sdn_reg),
                    
                    // optional video ports
                    .cond_vid_data(cond_vid_data),
                    .cond_vid_channel(cond_vid_channel),
                    .cond_vid_de(cond_vid_de),
                    .cond_vid_f(cond_vid_f),
                    .cond_vid_v_sync(cond_vid_v_sync),
                    .cond_vid_h_sync(cond_vid_h_sync),
                    .cond_vid_hd_sdn(cond_vid_hd_sdn),
                    
                    .ram_address(ram_address),
                    .ram_we(ram_we),
                    .ram_data(ram_data));
        end else begin
            always @ (posedge rst or posedge clk) begin
                if(rst) begin
                    vid_de_reg <= 1'b0;
                    vid_v_sync_reg <= 1'b1;
                    vid_h_sync_reg <= 1'b1;
                end else begin
                    vid_de_reg <= vid_de;
                    vid_v_sync_reg <= vid_v_sync;
                    vid_h_sync_reg <= vid_h_sync;
                end
            end
        
            assign cond_vid_data = vid_data_reg;
            assign cond_vid_de = vid_de_reg;
            assign cond_vid_datavalid = vid_datavalid_reg;
            assign cond_vid_channel = vid_channel_reg;
            
            if(GENERATE_VID_F) begin
                reg generated_vid_f;
                logic generated_vid_f_nxt;
                reg vid_v_sync_reg2;
                
                always_comb begin
                    if(vid_datavalid_reg && vid_v_sync_reg && !vid_v_sync_reg2) begin
                        if(!vid_h_sync_reg)
                            generated_vid_f_nxt = 0;
                        else
                            generated_vid_f_nxt = 1;
                    end else
                        generated_vid_f_nxt = generated_vid_f;
                end
                
                always @(posedge rst or posedge clk) begin
                    if(rst) begin
                        generated_vid_f <= 0;
                        vid_v_sync_reg2 <= 1;
                    end else begin
                        if(vid_datavalid_reg) begin
                            generated_vid_f <= generated_vid_f_nxt;
                            vid_v_sync_reg2 <= vid_v_sync_reg;
                        end
                    end
                end
                
                assign cond_vid_f = generated_vid_f_nxt;
            end else begin
                reg vid_f_reg;
                
                always @ (posedge rst or posedge clk) begin
                    if(rst) begin
                        vid_f_reg <= 1'b0;
                    end else begin
                        vid_f_reg <= vid_f;
                    end
                end
            
                assign cond_vid_f = vid_f_reg;
            end
            
            alt_vip_cvi_sync_polarity_convertor hsync_convertor(
                .rst(rst),
                .clk(clk),
                
                .sync_in(vid_h_sync_reg),
                .datavalid(vid_datavalid_reg),
                .de(vid_de_reg),
                .sync_out(cond_vid_h_sync));
                
            alt_vip_cvi_sync_polarity_convertor vsync_convertor(
                .rst(rst),
                .clk(clk),
                
                .sync_in(vid_v_sync_reg),
                .datavalid(vid_datavalid_reg),
                .de(vid_de_reg),
                .sync_out(cond_vid_v_sync));
                
            assign cond_vid_hd_sdn = vid_hd_sdn_reg;
            
            assign ram_address = '0;
            assign ram_we = 1'b0;
            assign ram_data = '0;
        end
    end endgenerate
        
endmodule
    

