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

module alt_vip_cvi_control
    #(parameter
        ANC_ADDRESS_WIDTH = 5,
        RAM_SIZE = 64,
        USED_WORDS_WIDTH = 1,
        USE_CONTROL = 1)
    (
    input wire rst,
    input wire clk,
    
    // Embedded sync extractor
    input wire [ANC_ADDRESS_WIDTH-1:0] sync_cond_mem_address,
    input wire sync_cond_mem_write,
    input wire [15:0] sync_cond_mem_data,
    
    // Resolution Output
    input wire [4:0] res_det_mem_address,
    input wire res_det_mem_write,
    input wire [15:0] res_det_mem_write_data,
    output logic res_det_mem_stall,
    
    input wire is_rst,
    input wire is_clk,
    
    // Aavalon-MM slave port
    input wire [ANC_ADDRESS_WIDTH-1:0] av_address,
    input wire av_read,
    output reg [31:0] av_readdata,
    input wire av_write,
    input wire [31:0] av_writedata,
    input wire [3:0] av_byteenable,
    output logic av_waitrequest,
    output reg status_update_int,
    
    // Avalon-ST output
    input logic [4:0] av_st_out_mem_address,
    input logic av_st_out_mem_read,
    output wire [15:0] av_st_out_mem_read_data,
    
    input wire overflow,
    input wire [USED_WORDS_WIDTH-1:0] read_usedw,
    input wire vid_locked,
    input wire start_of_frame,
    input wire status_update,
    
    output wire vid_locked_lost,
    output wire go);

logic write_nxt;
logic [ANC_ADDRESS_WIDTH-1:0] write_address_nxt;
logic [15:0] write_data_nxt;

always_comb begin
    if(sync_cond_mem_write) begin
        write_nxt = 1;
        write_address_nxt = sync_cond_mem_address;
        write_data_nxt = sync_cond_mem_data;
        res_det_mem_stall = 1;
    end else begin
        write_nxt = res_det_mem_write;
        write_address_nxt = {'0, res_det_mem_address};
        write_data_nxt = res_det_mem_write_data;
        res_det_mem_stall = 0;
    end
end

(* ramstyle = "no_rw_check" *) reg [15:0] ram[RAM_SIZE];


always @(posedge clk) begin
    if(write_nxt)
        ram[write_address_nxt] <= write_data_nxt;
end

logic [ANC_ADDRESS_WIDTH-1:0] read_address_nxt;

always_comb begin
    if(av_st_out_mem_read) begin
        read_address_nxt = {'0, av_st_out_mem_address};
        av_waitrequest = av_read;
    end else begin
        read_address_nxt = av_address;
        av_waitrequest = 0;
    end
end

reg [15:0] q;

assign av_st_out_mem_read_data = q;

always @(posedge is_clk) begin
    q <= ram[read_address_nxt];
end

reg vid_locked_reg;
reg genlock_enable;
reg [1:0] interrupt_enable;
reg overflow_reg;
reg overflow_sticky;
reg status_interrupt;
wire edge_vid_locked, rising_edge_overflow_sticky;
reg v_sync_interrupt;

assign vid_locked_lost = !vid_locked && vid_locked_reg;
assign edge_vid_locked = vid_locked ^ vid_locked_reg;
assign rising_edge_overflow_sticky = overflow && !overflow_reg;

reg [ANC_ADDRESS_WIDTH-1:0] av_address_reg;
reg go_reg;
reg status_update_reg;
reg start_of_frame_reg;

// mask out the interrupt toggling that happens after a vid_locked reset
reg vid_locked_delay[4];
wire vid_locked_mask;
assign vid_locked_mask = vid_locked && vid_locked_delay[3];
generate begin : vid_locked_delay_array
    genvar i;
    for(i = 0; i < 4; i++) begin : vid_locked_delay_for_loop
        always @ (posedge is_rst or posedge is_clk) begin
            if(is_rst) begin
                vid_locked_delay[i] <= 1'b0;
            end else begin
                if(!vid_locked)
                    vid_locked_delay[i] <= 1'b0;
                else
                    if(i == 0)
                        vid_locked_delay[i] <= vid_locked;
                    else
                        vid_locked_delay[i] <= vid_locked_delay[i-1];
            end
        end
    end
end endgenerate
always @(posedge is_clk or posedge is_rst) begin
    if(is_rst) begin
        av_address_reg <= '0;
        av_readdata <= '0;
        genlock_enable <= 0;
        interrupt_enable <= '0;
        go_reg <= !USE_CONTROL;
        overflow_reg <= 0;
        overflow_sticky <= 0;
        status_update_reg <= 0;
        status_interrupt <= 0;
        v_sync_interrupt <= 0;
        vid_locked_reg <= 0;
        start_of_frame_reg <= 0;
        status_update_int <= 0;
    end else begin
        av_address_reg <= av_address;
        
        if(av_address_reg == REGISTER_GO_ADDR)
            av_readdata <= {'0, genlock_enable, interrupt_enable, go};
        else if(av_address_reg == REGISTER_STATUS_ADDR) // video locked, resolution valid, overflow, stable, interlaced, 6'd0, go
            av_readdata <= {'0, vid_locked, q[STATUS_BIT_RES_VALID], overflow_sticky, q[STATUS_BIT_STABLE], q[STATUS_BIT_INTERLACED], 6'd0, go};
        else if(av_address_reg == REGISTER_INTERRUPT_ADDR)
            av_readdata <= {'0, v_sync_interrupt, status_interrupt, 1'b0};    
        else if(av_address_reg == REGISTER_USEDW_ADDR)
            av_readdata <= {'0, read_usedw};
        else
            av_readdata <= q;
        
        if(av_address == REGISTER_GO_ADDR && av_write && av_byteenable[0]) begin
            genlock_enable <= av_writedata[3];
            interrupt_enable <= av_writedata[2:1];
            go_reg <= av_writedata[0];
        end
        
        overflow_reg <= overflow;
        if(vid_locked_mask && rising_edge_overflow_sticky)
            overflow_sticky <= 1'b1;
        else if(av_address == REGISTER_STATUS_ADDR && av_write && av_byteenable[1])
            overflow_sticky <= overflow_sticky && !av_writedata[9];
        else
            overflow_sticky <= overflow_sticky;
        
        status_update_reg <= status_update;
        if(av_address == REGISTER_INTERRUPT_ADDR && av_write && av_byteenable[0]) begin
            status_interrupt <= status_interrupt && !av_writedata[1];
            v_sync_interrupt <= v_sync_interrupt && !av_writedata[2];
        end else begin
            if(vid_locked_mask) begin
                status_interrupt <= (status_update ^ status_update_reg) || edge_vid_locked || rising_edge_overflow_sticky || status_interrupt;
                v_sync_interrupt <= (start_of_frame ^ start_of_frame_reg) || v_sync_interrupt;
            end else begin
                status_interrupt <= status_interrupt;
                v_sync_interrupt <= v_sync_interrupt;
            end
        end
        
        vid_locked_reg <= vid_locked;
        start_of_frame_reg <= start_of_frame;
        status_update_int <= (interrupt_enable[0] && status_interrupt) || (interrupt_enable[1] && v_sync_interrupt);
    end
end


        assign go = go_reg;

endmodule
