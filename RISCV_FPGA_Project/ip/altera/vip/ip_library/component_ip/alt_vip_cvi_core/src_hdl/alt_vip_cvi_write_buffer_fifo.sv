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


module alt_vip_cvi_write_fifo_buffer
    #(parameter
        DATA_WIDTH = 20,
        USE_CHANNEL = 0,
        CHANNEL_WIDTH = 1,
        NUMBER_OF_COLOUR_PLANES = 2,
        BPS = 10,
        CLOCKS_ARE_SAME = 1,
        FIFO_DEPTH = 512,
        DEVICE_FAMILY = "Stratix II",
        SYNC_TO = 2,
        USED_WORDS_WIDTH = 1,
        COLOUR_PLANES_ARE_IN_PARALLEL = 1)
    (
    input wire rst,
    input wire clk,
    
    input wire enable,
    
    input wire [DATA_WIDTH-1:0] cond_vid_data,
    input wire cond_vid_de,
    input wire cond_vid_datavalid,
    input wire [CHANNEL_WIDTH-1:0] cond_vid_channel,
    input wire cond_vid_v_sync,
    input wire cond_vid_hd_sdn,
    input wire cond_vid_f,
    
    output reg fifo_overflow,
    output reg overflow,
    output reg start_of_frame,

    input wire read_clock,
    input wire read_reset,
    input wire read_req,
    output logic read_valid,
    output wire [DATA_WIDTH-1:0] read_data,
    output wire read_packet,
    output wire [CHANNEL_WIDTH-1:0] read_channel,
    output wire read_empty,
    output wire [USED_WORDS_WIDTH-1:0] read_usedw
);

localparam FIFO_WIDTH = (USE_CHANNEL) ? DATA_WIDTH + CHANNEL_WIDTH + 1 : DATA_WIDTH + 1;

enum logic [2:0] { IDLE,
                   IDLE_OVERFLOW,
                   LINE,
                   WAIT_FOR_NEXT_LINE,
                   OVERFLOW,
                   END_OF_FRAME,
                   END_OF_FRAME_OVERFLOW } state_nxt, state;

logic [DATA_WIDTH-1:0] buffer_nxt, buffer;
logic [CHANNEL_WIDTH-1:0] channel_buffer_nxt, channel_buffer;
logic write_req_nxt;
logic [DATA_WIDTH-1:0] write_data_nxt;
logic [1:0] pixel_count_nxt, pixel_count;
logic packet_nxt;
wire full;

task check_for_start_of_line(bit send_field);
    if(cond_vid_de) begin // start of line
        if(cond_vid_hd_sdn || !COLOUR_PLANES_ARE_IN_PARALLEL) begin
            pixel_count_nxt = 0;
            buffer_nxt = cond_vid_data;
        end else begin
            buffer_nxt[BPS-1:0] = cond_vid_data[BPS-1:0];
            pixel_count_nxt = 1;
        end
        channel_buffer_nxt = cond_vid_channel;
        if(send_field) begin
            if(full) begin
                state_nxt = IDLE_OVERFLOW;
            end else begin
                write_data_nxt = {'0, cond_vid_f, 1'b0};
                write_req_nxt = 1;
                state_nxt = LINE;
            end
        end else
            state_nxt = LINE;
    end
endtask

// the enable signal is only checked at the start of the frame
wire sync_field;
generate
    if(SYNC_TO == 0)
        assign sync_field = !cond_vid_f;
    else if(SYNC_TO == 1)
        assign sync_field = cond_vid_f;
    else
        assign sync_field = 1;
endgenerate

logic overflow_nxt;
wire synced_enable_nxt;
reg synced_enable, cond_vid_v_sync_reg;

wire start_of_frame_nxt;
assign start_of_frame_nxt = cond_vid_datavalid && cond_vid_v_sync_reg && !cond_vid_v_sync && sync_field;
assign synced_enable_nxt = (start_of_frame_nxt) ? enable && !overflow_nxt : synced_enable && !overflow_nxt;

always_comb begin
    state_nxt = state;
    buffer_nxt = buffer;
    channel_buffer_nxt = channel_buffer;
    write_req_nxt = 0;
    pixel_count_nxt = pixel_count;
    packet_nxt = 0;
    overflow_nxt = 0;
    write_data_nxt = buffer;
    
    case(state)
        IDLE: begin   
            if(synced_enable_nxt) // the enable signal must be cleared if there is an overflow
                check_for_start_of_line(1);
        end
        IDLE_OVERFLOW: begin
            overflow_nxt = 1;
        
            if(!full)
                state_nxt = IDLE;
        end
        LINE: begin
            if(pixel_count == 0 || !cond_vid_de) begin
                if(full)
                    state_nxt = OVERFLOW;
                else
                    write_req_nxt = 1;
            end
            
            if(!cond_vid_de) begin // end of line
                packet_nxt = 1;
                if(cond_vid_v_sync)
                    state_nxt = END_OF_FRAME;
                else
                    state_nxt = WAIT_FOR_NEXT_LINE;
            end else begin
                if(cond_vid_hd_sdn || !COLOUR_PLANES_ARE_IN_PARALLEL)
                    buffer_nxt = cond_vid_data;
                else begin
                    buffer_nxt[BPS * pixel_count +: BPS] = cond_vid_data[BPS-1:0]; // convert from sequential to parallel
                    
                    if(pixel_count_nxt == NUMBER_OF_COLOUR_PLANES - 1)
                        pixel_count_nxt = 0;
                    else
                        pixel_count_nxt = pixel_count_nxt + 1'b1;
                end
                channel_buffer_nxt = cond_vid_channel;
            end
        end
        WAIT_FOR_NEXT_LINE: begin
            if(cond_vid_v_sync)
                state_nxt = END_OF_FRAME;
            else 
                check_for_start_of_line(0);
        end
        OVERFLOW: begin
            overflow_nxt = 1;
        
            if(!full) begin
                packet_nxt = 1;
                write_req_nxt = 1;
                state_nxt = END_OF_FRAME;
            end    
        end
        END_OF_FRAME: begin
            if(full)
                state_nxt = END_OF_FRAME_OVERFLOW;
            else begin
                packet_nxt = 1;
                write_req_nxt = 1;
                state_nxt = IDLE;
            end
        end
        END_OF_FRAME_OVERFLOW: begin
            overflow_nxt = 1;
            
            if(!full) begin
                packet_nxt = 1;
                write_req_nxt = 1;
                state_nxt = IDLE;
            end    
        end
    endcase
end

wire rising_edge_overflow;
assign rising_edge_overflow = overflow_nxt && !overflow;

always @(posedge clk or posedge rst) begin
    if(rst) begin
        state <= IDLE;
        buffer <= '0;
        channel_buffer <= '0;
        pixel_count <= '0;
        synced_enable <= 0;
        cond_vid_v_sync_reg <= 0;
        fifo_overflow <= 0;
        overflow <= 0;
        start_of_frame <= 0;
    end else begin
        if(cond_vid_datavalid) begin
            state <= state_nxt;
            buffer <= buffer_nxt;
            channel_buffer <= channel_buffer_nxt;
            pixel_count <= pixel_count_nxt;
            overflow <= overflow_nxt;
            fifo_overflow <= fifo_overflow ^ rising_edge_overflow; // toggle for clock crossing
            cond_vid_v_sync_reg <= cond_vid_v_sync;
        end
        synced_enable <= synced_enable_nxt;
        start_of_frame <= start_of_frame ^ start_of_frame_nxt; // toggle for clock crossing
    end
end

wire read_req_not_empty_nxt;
assign read_req_not_empty_nxt = read_req && !read_empty;

always @(posedge read_clock or posedge read_reset) begin
    if(read_reset) begin
        read_valid <= 0;
    end else begin
        read_valid <= read_req_not_empty_nxt;
    end
end

wire write_req_and_valid_nxt;
assign write_req_and_valid_nxt = write_req_nxt && cond_vid_datavalid;

wire [FIFO_WIDTH-1:0] din, dout;

generate
    if(USE_CHANNEL) begin
        assign din = { channel_buffer, write_data_nxt, packet_nxt };
        assign {read_channel, read_data, read_packet} = dout;
    end else begin
        assign din = { write_data_nxt, packet_nxt };
        assign { read_data, read_packet} = dout;
        assign read_channel = '0;
    end
endgenerate

alt_vip_common_dc_mixed_widths_fifo #(
        .INPUT_DATA_WIDTH(FIFO_WIDTH),
        .OUTPUT_DATA_WIDTH(FIFO_WIDTH),
        .CLOCKS_ARE_SAME(CLOCKS_ARE_SAME),
        .FIFO_DEPTH(FIFO_DEPTH),
        .DEVICE_FAMILY(DEVICE_FAMILY))
    input_fifo(
        .write_clock(clk),
        .write_reset(rst),
        .write(write_req_and_valid_nxt),
        .din(din),
        .write_empty(),
        .write_full(full),
        .write_usedw(),
        
        .read_clock(read_clock),
        .read_reset(read_reset),
        .read(read_req_not_empty_nxt),
        .dout(dout),
        .read_empty(read_empty),
        .read_full(),
        .read_usedw(read_usedw));

endmodule
