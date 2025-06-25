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

module alt_vip_cvi_av_st_output
    #(parameter
        DATA_WIDTH = 20,
        OUTPUT_DATA_WIDTH = 21,
        CHANNEL_WIDTH = 1)
    (
        input wire rst,
        input wire clk,
        
        output logic mem_read,
        output logic [4:0] mem_address,
        input wire [15:0] mem_read_data,
        
        input wire vid_locked_lost,
        
        output logic fifo_read_req,
        input wire fifo_read_valid,
        input wire [DATA_WIDTH-1:0] fifo_read_data,
        input wire fifo_read_packet,
        input wire [CHANNEL_WIDTH-1:0] fifo_read_channel,
        input wire fifo_read_empty,
        
        // connections to the video output bridge
        input wire av_st_cmd_ready,
        output wire av_st_cmd_valid,
        output wire av_st_cmd_startofpacket,
        output wire av_st_cmd_endofpacket,
        output wire [32:0] av_st_cmd_data,
        
        input wire av_st_dout_ready,
        output wire av_st_dout_valid,
        output wire av_st_dout_startofpacket,
        output wire av_st_dout_endofpacket,
        output wire [OUTPUT_DATA_WIDTH-1:0] av_st_dout_data,
        output wire [CHANNEL_WIDTH-1:0] av_st_dout_channel
);

import alt_vip_common_pkg::*;

localparam TASK_WIDTH = 1;

logic                                 av_st_cmd_int_ready;
logic                                 av_st_cmd_int_valid;
logic [31:0]                          av_st_cmd_int_arguments_in[2];
logic [1:0]                           av_st_cmd_int_number_arguments_in;
logic [TASK_WIDTH-1:0]                av_st_cmd_int_task_in;

alt_vip_common_event_packet_encode #(
         .BITS_PER_ELEMENT(32),
         .ELEMENTS_PER_BEAT(1),
         .NUMBER_OF_ARGUMENTS(2),
         .SRC_WIDTH(0),
         .DST_WIDTH(0),
         .CONTEXT_WIDTH(0),
         .TASK_WIDTH(TASK_WIDTH),
         .USER_WIDTH(0),
         .DST_BASE(0), 
         .SRC_BASE(0), 
         .TASK_BASE(0), 
         .CONTEXT_BASE(0), 
         .USER_BASE(0), 
         .PIPELINE_READY(1)
   ) cmd_output(
   
         .clock(clk),
         .reset(rst),

         .din_ready(),
         .din_valid(1'b0),
         .din_startofpacket(1'b1),
         .din_endofpacket(1'b1),
         .din_data(1'b0),
         .din_eop_empty(1'b0),
         .din_sop_empty(1'b0),

         .av_st_dout_ready(av_st_cmd_ready),
         .av_st_dout_valid(av_st_cmd_valid),
         .av_st_dout_startofpacket(av_st_cmd_startofpacket),
         .av_st_dout_endofpacket(av_st_cmd_endofpacket),
         .av_st_dout_data(av_st_cmd_data),
         
         .arguments_in(av_st_cmd_int_arguments_in),
         .arguments_valid(av_st_cmd_int_valid),
         .arguments_ready(av_st_cmd_int_ready),
         .number_of_arguments(av_st_cmd_int_number_arguments_in),
         .source_in('0),
         .destination_in('0),
         .context_in('0),
         .task_in(av_st_cmd_int_task_in),
         .user_in(1'b0)
   );

logic                         av_st_dout_int_ready;
logic                         av_st_dout_int_valid;
logic                         av_st_dout_int_startofpacket;
logic                         av_st_dout_int_endofpacket;
   
alt_vip_common_event_packet_encode #(
        .BITS_PER_ELEMENT(DATA_WIDTH),
        .ELEMENTS_PER_BEAT(1),
        .NUMBER_OF_ARGUMENTS(0),
        .SRC_WIDTH(0),
        .DST_WIDTH(0),
        .CONTEXT_WIDTH(0),
        .TASK_WIDTH(TASK_WIDTH),
        .USER_WIDTH(0), 
        .DST_BASE(0), 
        .SRC_BASE(0), 
        .TASK_BASE(0), 
        .CONTEXT_BASE(0), 
        .USER_BASE(0), 
        .PIPELINE_READY(1)
    ) data_output(
    
        .clock(clk),
        .reset(rst),
        
        .din_ready(av_st_dout_int_ready),
        .din_valid(av_st_dout_int_valid),
        .din_startofpacket(av_st_dout_int_startofpacket),
        .din_endofpacket(av_st_dout_int_endofpacket),
        .din_data(fifo_read_data),
        .din_eop_empty(1'b0),
        .din_sop_empty(1'b0),
        
        .av_st_dout_ready(av_st_dout_ready),
        .av_st_dout_valid(av_st_dout_valid),
        .av_st_dout_startofpacket(av_st_dout_startofpacket),
        .av_st_dout_endofpacket(av_st_dout_endofpacket),
        .av_st_dout_data(av_st_dout_data),
        
        .arguments_in(),
        .arguments_valid(), 
        .arguments_ready(), 
        .number_of_arguments(1'b0),
        
        .source_in('0),
        .destination_in('0),
        .context_in('0),
        .task_in('0)
    );

enum logic [4:0] { IDLE,
                   FIND_SOF,
                   RES_IDLE,
                   RES_UPDATE_WAIT,
                   RES_SET_WIDTH,
                   RES_SET_HEIGHT_F0,
                   RES_SET_HEIGHT_F1,
                   RES_SET_INTERLACED,
                   SEND_CONTROL_PACKET,
                   SEND_CONTROL_PACKET_WAIT,
                   SEND_FIRST_LINE_COMMAND,
                   SEND_FIRST_LINE_COMMAND_WAIT,
                   SEND_FIRST_LINE,
                   COMPLETE_FIRST_LINE,
                   CHECK_FOR_EOF,
                   COMPLETE_FRAME,
                   SEND_LINE,
                   COMPLETE_LINE,
                   SEND_LINE_COMMAND,
                   SEND_LINE_COMMAND_WAIT } state_nxt, state;                   

logic [15:0] width_nxt, width;
logic [15:0] height_f0_nxt, height_f0;
logic [15:0] height_f1_nxt, height_f1;
logic interlaced_nxt, interlaced;
                   
task send_control_packet(input bit valid, input bit field);
   automatic integer tsk = Response_t'(VID_OUTPUT_BRIDGE_CMD_SEND_CTRL_PACKET);
   VID_OUTPUT_BRIDGE_CMD_SEND_CTRL_PACKET_ARG0 arg0;
   VID_OUTPUT_BRIDGE_CMD_SEND_CTRL_PACKET_ARG1 arg1;
   begin
      arg0.height = (field) ? height_f1 : height_f0;
      arg0.width = width;
      
      arg1.reserved = '0;
      arg1.interlaced_flag = {interlaced, field, 2'b10};
      
      av_st_cmd_int_valid = valid;
      av_st_cmd_int_task_in = tsk[TASK_WIDTH-1:0];
      
      av_st_cmd_int_number_arguments_in = 2'd2;
      av_st_cmd_int_arguments_in[0] = arg0;
      av_st_cmd_int_arguments_in[1] = arg1;
   end
endtask

task send_line_packet(input bit eop);
   automatic integer tsk = Response_t'(VID_OUTPUT_BRIDGE_CMD_SEND_PACKET);
   VID_OUTPUT_BRIDGE_CMD_SEND_PACKET_ARG0 arg0;
   begin
      arg0.packet_type = 4'd0;
      arg0.reserved0 = 4'd0;
      arg0.eop = eop;
      arg0.empty = 1'b0;
      arg0.reserved1 = 22'd0;
      
      av_st_cmd_int_valid = 1'b1;
      av_st_cmd_int_task_in = tsk[TASK_WIDTH-1:0];
      
      av_st_cmd_int_number_arguments_in = 2'd1;
      av_st_cmd_int_arguments_in[0] = arg0;
   end
endtask

logic field_nxt, field;
logic start_of_packet_nxt, start_of_packet;

logic clear_vid_locked_lost_nxt;
reg vid_locked_lost_reg;
logic hold_read_valid_nxt;
reg hold_read_valid;
wire combined_read_valids;

assign combined_read_valids = fifo_read_valid || hold_read_valid;

always_comb begin
    state_nxt = state;
    field_nxt = field;
    fifo_read_req = 0;
    start_of_packet_nxt = start_of_packet;
    mem_read = 0;
    mem_address = REGISTER_ACTIVE_SAMPLES_ADDR[4:0];
    width_nxt = width;
    height_f0_nxt = height_f0;
    height_f1_nxt = height_f1;
    interlaced_nxt = interlaced;
    hold_read_valid_nxt = 0;
    
    av_st_dout_int_valid = 0;
    av_st_dout_int_startofpacket = start_of_packet;
    av_st_dout_int_endofpacket = fifo_read_packet;
    
    clear_vid_locked_lost_nxt = 0;
    
    send_control_packet(0, field);
    
    case(state)
        IDLE: begin
                clear_vid_locked_lost_nxt = 1;
            if(!fifo_read_empty) begin
                state_nxt = FIND_SOF;
                fifo_read_req = 1;
            end
        end
        FIND_SOF: begin
            if(fifo_read_valid && !fifo_read_packet) begin
                mem_read = 1;
                mem_address = REGISTER_ACTIVE_SAMPLES_ADDR[4:0]; // width address
                state_nxt = RES_SET_WIDTH;
            end else
                fifo_read_req = 1;
        end
        RES_SET_WIDTH: begin
            mem_read = 1;
            mem_address = REGISTER_ACTIVE_LINES_F0_ADDR[4:0]; // height address
            width_nxt = mem_read_data;
            state_nxt = RES_SET_HEIGHT_F0;
        end
        RES_SET_HEIGHT_F0: begin
            mem_read = 1;
            mem_address = REGISTER_ACTIVE_LINES_F1_ADDR[4:0]; // height address
            height_f0_nxt = mem_read_data;
            state_nxt = RES_SET_HEIGHT_F1;
        end
        RES_SET_HEIGHT_F1: begin
            mem_read = 1;
            mem_address = REGISTER_STATUS_ADDR[4:0]; // interlaced address
            height_f1_nxt = mem_read_data;
            state_nxt = RES_SET_INTERLACED;
        end
        RES_SET_INTERLACED: begin
            interlaced_nxt = mem_read_data[STATUS_BIT_INTERLACED];
            state_nxt = SEND_CONTROL_PACKET;
        end
        SEND_CONTROL_PACKET: begin
            field_nxt = fifo_read_data[1];
            send_control_packet(1, field_nxt);
            if(av_st_cmd_int_ready)
                state_nxt = SEND_FIRST_LINE_COMMAND;
            else
                state_nxt = SEND_CONTROL_PACKET_WAIT;
        end
        SEND_CONTROL_PACKET_WAIT: begin
            send_control_packet(1, field);
            if(av_st_cmd_int_ready)
                state_nxt = SEND_FIRST_LINE_COMMAND;
        end
        SEND_FIRST_LINE_COMMAND: begin
            send_line_packet(0);
            if(av_st_cmd_int_ready) begin
                fifo_read_req = 1;
                start_of_packet_nxt = 1;
                state_nxt = SEND_FIRST_LINE;
            end else
                state_nxt = SEND_FIRST_LINE_COMMAND_WAIT;
        end
        SEND_FIRST_LINE_COMMAND_WAIT: begin
            send_line_packet(0);
            if(av_st_cmd_int_ready) begin
                fifo_read_req = 1;
                start_of_packet_nxt = 1;
                state_nxt = SEND_FIRST_LINE;
            end
        end
        SEND_FIRST_LINE: begin
            fifo_read_req = av_st_dout_int_ready && !vid_locked_lost_reg;
            av_st_dout_int_valid = combined_read_valids;
            av_st_dout_int_startofpacket = start_of_packet;
            av_st_dout_int_endofpacket = fifo_read_packet;
            if(vid_locked_lost_reg && !(av_st_dout_int_valid && av_st_dout_int_endofpacket))
                state_nxt = COMPLETE_FIRST_LINE;
            else if(combined_read_valids) begin 
                if(av_st_dout_int_ready) begin
                    start_of_packet_nxt = 0;
                    if(fifo_read_packet)
                        state_nxt = CHECK_FOR_EOF;
                end else begin
                    hold_read_valid_nxt = 1;
                end
            end
        end
        COMPLETE_FIRST_LINE: begin
            av_st_dout_int_valid = 1;
            av_st_dout_int_startofpacket = 0;
            av_st_dout_int_endofpacket = 1;
            if(av_st_dout_int_ready)
                state_nxt = COMPLETE_FRAME;
        end
        CHECK_FOR_EOF: begin
            if(fifo_read_valid || vid_locked_lost_reg) begin
                start_of_packet_nxt = 1;
                if(fifo_read_packet || vid_locked_lost_reg) begin
                    state_nxt = COMPLETE_FRAME;
                end else begin
                    hold_read_valid_nxt = 1;
                    state_nxt = SEND_LINE;
                end
            end else
                fifo_read_req = 1;
        end
        COMPLETE_FRAME: begin
            // The frame packet is open so we must send a beat of dummy
            // data and a line command to close it
            av_st_dout_int_valid = 1;
            av_st_dout_int_startofpacket = 1;
            av_st_dout_int_endofpacket = 1;
            if(av_st_dout_int_ready)
                state_nxt = SEND_LINE_COMMAND;
        end
        SEND_LINE: begin
            fifo_read_req = av_st_dout_int_ready && !vid_locked_lost_reg;
            av_st_dout_int_valid = combined_read_valids;
            av_st_dout_int_startofpacket = start_of_packet;
            av_st_dout_int_endofpacket = fifo_read_packet;
            if(vid_locked_lost_reg && !(av_st_dout_int_valid && av_st_dout_int_endofpacket))
                state_nxt = COMPLETE_LINE;
            else if(combined_read_valids) begin
                if(av_st_dout_int_ready) begin
                    start_of_packet_nxt = 0;
                    if(fifo_read_packet)
                        state_nxt = SEND_LINE_COMMAND;
                end else begin
                    hold_read_valid_nxt = 1;
                end
            end
        end
        COMPLETE_LINE: begin
            av_st_dout_int_valid = 1;
            av_st_dout_int_startofpacket = 0;
            av_st_dout_int_endofpacket = 1;
            if(av_st_dout_int_ready)
                state_nxt = SEND_LINE_COMMAND;
        end
        SEND_LINE_COMMAND: begin
            // the send line command is delayed until we know 
            // if this is the end of frame or not
            if(fifo_read_valid || vid_locked_lost_reg) begin
                send_line_packet(fifo_read_packet || vid_locked_lost_reg);
                hold_read_valid_nxt = 1;
                if(av_st_cmd_int_ready)
                    if(fifo_read_packet || vid_locked_lost_reg)
                        state_nxt = IDLE;
                    else begin
                        start_of_packet_nxt = 1;
                        state_nxt = SEND_LINE;
                    end
                else
                    state_nxt = SEND_LINE_COMMAND_WAIT;
            end else
                fifo_read_req = 1;
        end
        SEND_LINE_COMMAND_WAIT: begin
            send_line_packet(fifo_read_packet || vid_locked_lost_reg);
            hold_read_valid_nxt = 1;
            if(av_st_cmd_int_ready) begin
                if(fifo_read_packet || vid_locked_lost_reg)
                    state_nxt = IDLE;
                else begin
                    start_of_packet_nxt = 1;
                    state_nxt = SEND_LINE;
                end
            end
        end
    endcase
end

always @(posedge clk or posedge rst) begin
    if(rst) begin
        state <= IDLE;
        field <= 0;
        start_of_packet <= 0;
        vid_locked_lost_reg <= 0;
        width <= '0;
        height_f0 <= '0;
        height_f1 <= '0;
        interlaced <= '0;
        hold_read_valid <= 0;
    end else begin
        state <= state_nxt;
        field <= field_nxt;
        start_of_packet <= start_of_packet_nxt;
        vid_locked_lost_reg <= vid_locked_lost || (vid_locked_lost_reg && !clear_vid_locked_lost_nxt);
        width <= width_nxt;
        height_f0 <= height_f0_nxt;
        height_f1 <= height_f1_nxt;
        interlaced <= interlaced_nxt;
        hold_read_valid <= hold_read_valid_nxt;
    end
end

endmodule
