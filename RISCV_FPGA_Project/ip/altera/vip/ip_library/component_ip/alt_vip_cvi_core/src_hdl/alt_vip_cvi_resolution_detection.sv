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
import alt_vip_cvi_register_addresses::*;

module alt_vip_cvi_resolution_detection 
    #(parameter
        NUMBER_OF_COLOUR_PLANES = 3,
        COLOUR_PLANES_ARE_IN_PARALLEL = 1,
        PIXELS_IN_PARALLEL = 1,
        CHANNEL_WIDTH = 1,
        STD_WIDTH = 1,
        INTERLACED = 1,
        H_ACTIVE_PIXELS = 1920,
        V_ACTIVE_LINES_F0 = 540,
        V_ACTIVE_LINES_F1 = 540)
    (
    input wire rst,
    input wire clk,
    
    input wire cond_vid_de,
    input wire cond_vid_datavalid,
    input wire [CHANNEL_WIDTH-1:0] cond_vid_channel,
    input wire cond_vid_f,
    input wire cond_vid_v_sync,
    input wire cond_vid_h_sync,
    input wire cond_vid_hd_sdn,
    input wire [STD_WIDTH-1:0] cond_vid_std,
    input wire [7:0] cond_vid_color_encoding,
    input wire [7:0] cond_vid_bit_width,
    
    output logic [4:0] mem_address,
    output logic mem_write,
    output logic [15:0] mem_write_data,
    input  wire mem_stall,
    
    output reg status_update,
    
    output wire sof,
    output wire sof_locked,
    output wire refclk_div
);

localparam PIXELS_IN_PARALLEL_SHIFT = (PIXELS_IN_PARALLEL == 4) ? 2 : (PIXELS_IN_PARALLEL == 2) ? 1 : 0;
localparam LOG2_NUMBER_OF_COLOUR_PLANES = alt_clogb2_pure(NUMBER_OF_COLOUR_PLANES);

wire rising_edge_de_nxt;
wire falling_edge_de_nxt;
wire rising_edge_vsync_nxt;
wire rising_edge_hsync_nxt;

reg cond_vid_de_reg;
reg cond_vid_v_sync_reg;
reg cond_vid_h_sync_reg;

always @(posedge clk or posedge rst) begin
    if(rst) begin
        cond_vid_de_reg <= 0;
        cond_vid_v_sync_reg <= 0;
        cond_vid_h_sync_reg <= 0;
     end else begin
        if(cond_vid_datavalid) begin
            cond_vid_de_reg <= cond_vid_de;
            cond_vid_v_sync_reg <= cond_vid_v_sync;
            cond_vid_h_sync_reg <= cond_vid_h_sync;
        end
     end
end

assign rising_edge_de_nxt = cond_vid_de && ~cond_vid_de_reg;
assign falling_edge_de_nxt = ~cond_vid_de && cond_vid_de_reg;
assign rising_edge_vsync_nxt = cond_vid_v_sync && ~cond_vid_v_sync_reg;
assign rising_edge_hsync_nxt = cond_vid_h_sync && ~cond_vid_h_sync_reg;

wire count_cycle;
assign count_cycle = cond_vid_datavalid && cond_vid_channel == 0;

wire count_sample;

alt_vip_cvi_sample_counter #(
        .NUMBER_OF_COLOUR_PLANES(NUMBER_OF_COLOUR_PLANES),
        .COLOUR_PLANES_ARE_IN_PARALLEL(COLOUR_PLANES_ARE_IN_PARALLEL),
        .LOG2_NUMBER_OF_COLOUR_PLANES(LOG2_NUMBER_OF_COLOUR_PLANES))
    sampler_counter(
        .rst(rst),
        .clk(clk),
        .sclr(rising_edge_de_nxt),
        
        .count_cycle(count_cycle),
        .hd_sdn(cond_vid_hd_sdn),
        
        .count_sample(count_sample),
        .start_of_sample(),
        .sample_ticks()
);

reg [12:0] sample_count;
logic [12:0] line_count;
wire sample_count_gte_32, line_count_gte_32;

assign sample_count_gte_32 = sample_count >= 32;
assign line_count_gte_32 = line_count >= 32;

logic rising_edge_v_blank_nxt, falling_edge_v_blank_nxt, sticky_vid_v_sync_nxt;
reg sticky_vid_v_sync;

enum logic [2:0] { LINE_IDLE,
                   LINE_LOOK_FOR_DE,
                   LINE_ACTIVE_LINES,
                   LINE_COUNT_ACTIVE_LINE,
                   CHECK_FOR_MISSING_HSYNC } line_state_nxt, line_state;

always_comb begin
    line_state_nxt = line_state;
    rising_edge_v_blank_nxt = 0;
    falling_edge_v_blank_nxt = 0;
    sticky_vid_v_sync_nxt = 0;
    
    case(line_state)
        LINE_IDLE: begin
            if(rising_edge_hsync_nxt)
                line_state_nxt = LINE_LOOK_FOR_DE;
        end
        LINE_LOOK_FOR_DE: begin
            if(rising_edge_de_nxt) begin
                falling_edge_v_blank_nxt = 1;
                line_state_nxt = LINE_ACTIVE_LINES;
            end
        end
        LINE_ACTIVE_LINES: begin
            // catches the case if the vsync is short and comes before the hsync
            sticky_vid_v_sync_nxt = sticky_vid_v_sync || cond_vid_v_sync;
            if(rising_edge_hsync_nxt)
                if(cond_vid_v_sync || sticky_vid_v_sync)
                    line_state_nxt = CHECK_FOR_MISSING_HSYNC;
                else
                line_state_nxt = LINE_COUNT_ACTIVE_LINE;
        end
        LINE_COUNT_ACTIVE_LINE: begin                
            if(rising_edge_hsync_nxt) begin
                rising_edge_v_blank_nxt = 1;
                line_state_nxt = LINE_LOOK_FOR_DE;
            end else if(rising_edge_de_nxt)
                line_state_nxt = LINE_ACTIVE_LINES;
            else if(cond_vid_v_sync)
                line_state_nxt = CHECK_FOR_MISSING_HSYNC;
        end
        CHECK_FOR_MISSING_HSYNC: begin
            if(rising_edge_hsync_nxt) begin
                rising_edge_v_blank_nxt = 1;
                line_state_nxt = LINE_LOOK_FOR_DE;
            end else if(rising_edge_de_nxt) begin
                // the v blanking was less than 1 line
                rising_edge_v_blank_nxt = 1;
                falling_edge_v_blank_nxt = 1;
                line_state_nxt = LINE_ACTIVE_LINES;
            end
        end
    endcase
end

reg [12:0] active_sample_count;
reg [12:0] total_sample_count;
reg [12:0] active_line_f0_count;
reg [12:0] active_line_f1_count;
reg [12:0] total_line_f0_count;
reg [12:0] total_line_f1_count;
reg current_field;
reg set_active_samples_flag;
reg set_total_samples_flag;
reg set_active_lines_f0_flag;
reg set_active_lines_f1_flag;
reg set_total_lines_f0_flag;
reg set_total_lines_f1_flag;

reg rising_edge_de, falling_edge_de;

enum logic [2:0] { ST_IDLE,
                   ST_WAIT_FOR_TOTAL_SAMPLES,
                   ST_2ND_LINE,
                   ST_2ND_LINE_WAIT_FOR_TOTAL_SAMPLES,
                   ST_STABLE,
                   ST_WAIT_FOR_RISING_EDGE_DE} stable_state_nxt, stable_state;

enum logic [1:0] { INT_IDLE,
                   INT_PROGRESSIVE,
                   INT_INTERLACED } interlaced_state_nxt, interlaced_state;                   
                   
enum logic [2:0] { RES_IDLE,
                   RES_WAIT_FOR_TOTAL_SAMPLES,
                   RES_WAIT_FOR_F0_ACTIVE_LINES,
                   RES_WAIT_FOR_F0_TOTAL_LINES,
                   RES_WAIT_FOR_F1_ACTIVE_LINES,
                   RES_WAIT_FOR_F1_TOTAL_LINES,
                   RES_RESOLUTION_VALID } resolution_state_nxt, resolution_state;

reg [STD_WIDTH-1:0] captured_cond_vid_std;
reg [7:0] captured_cond_vid_bit_width;
reg [7:0] captured_cond_vid_color_encoding;
logic stable_nxt, resolution_valid_nxt, interlaced_nxt;
reg stable, resolution_valid, interlaced;

always @(posedge clk or posedge rst) begin
    if(rst) begin
        sample_count <= '0;
        line_state <= LINE_IDLE;
        line_count <= '0;
        active_sample_count <= '0;
        total_sample_count <= '0;
        active_line_f0_count <= '0;
        active_line_f1_count <= '0;
        total_line_f0_count <= '0;
        total_line_f1_count <= '0;
        current_field <= 0;
        captured_cond_vid_std <= '0;
        captured_cond_vid_bit_width <= '0;
        captured_cond_vid_color_encoding <= '0;
        set_active_samples_flag <= 0;
        set_total_samples_flag <= 0;
        set_active_lines_f0_flag <= 0;
        set_active_lines_f1_flag <= 0;
        set_total_lines_f0_flag <= 0;
        set_total_lines_f1_flag <= 0;
        rising_edge_de <= 0;
        falling_edge_de <= 0;
        stable_state <= ST_IDLE;
        resolution_state <= RES_IDLE;
        interlaced_state <= INT_IDLE;
        stable <= 0;
        resolution_valid <= 0;
        interlaced <= INTERLACED[0];
        status_update <= 0;
        sticky_vid_v_sync <= 0;
    end else begin
        if(cond_vid_datavalid) begin
            if(rising_edge_de_nxt || line_state == LINE_IDLE || line_state == LINE_LOOK_FOR_DE)
                sample_count <= (cond_vid_hd_sdn) ? {'0, 1'b1} : {'0, 1'b0};
            else if(count_sample)
                sample_count <= sample_count + 1'b1;
            
            line_state <= line_state_nxt;
            
            if(falling_edge_v_blank_nxt)
                line_count <= 'd0;
            else if(rising_edge_hsync_nxt)
                line_count <= line_count + 1'b1;
            
            if(falling_edge_de_nxt
               && sample_count_gte_32
               && sample_count != active_sample_count) begin
                active_sample_count <= sample_count;
                set_active_samples_flag <= 1;
            end else
                set_active_samples_flag <= 0;
                
            if(rising_edge_de_nxt
               && sample_count_gte_32
               && sample_count != total_sample_count) begin
                total_sample_count <= sample_count;
                set_total_samples_flag <= 1;
            end else
                set_total_samples_flag <= 0;
            
            if(falling_edge_v_blank_nxt)
                current_field <= cond_vid_f;
            
            if(falling_edge_de_nxt) begin
                captured_cond_vid_std <= cond_vid_std;
                captured_cond_vid_bit_width <= cond_vid_bit_width;
                captured_cond_vid_color_encoding <= cond_vid_color_encoding;
            end
                
            if(rising_edge_v_blank_nxt && line_count_gte_32) begin
                if(!current_field && line_count != active_line_f0_count) begin
                    active_line_f0_count <= line_count;
                    set_active_lines_f0_flag <= 1;
                end else
                    set_active_lines_f0_flag <= 0;
                
                if(current_field && line_count != active_line_f1_count) begin
                    active_line_f1_count <= line_count;
                    set_active_lines_f1_flag <= 1;
                end else
                    set_active_lines_f1_flag <= 0;
            end else begin
                set_active_lines_f0_flag <= 0;
                set_active_lines_f1_flag <= 0;
            end
            
            if(falling_edge_v_blank_nxt && line_count_gte_32) begin
                if(!current_field && line_count != total_line_f0_count) begin
                    total_line_f0_count <= line_count;
                    set_total_lines_f0_flag <= 1;
                end else
                    set_total_lines_f0_flag <= 0;
                
                if(current_field && line_count != total_line_f1_count) begin
                    total_line_f1_count <= line_count;
                    set_total_lines_f1_flag <= 1;
                end else
                    set_total_lines_f1_flag <= 0;
            end else begin
                set_total_lines_f0_flag <= 0;
                set_total_lines_f1_flag <= 0;
            end
            
            rising_edge_de <= rising_edge_de_nxt;
            falling_edge_de <= falling_edge_de_nxt;
            
            stable_state <= stable_state_nxt;
            resolution_state <= resolution_state_nxt;
            interlaced_state <= interlaced_state_nxt;
            
            stable <= stable_nxt;
            resolution_valid <= resolution_valid_nxt;
            interlaced <= interlaced_nxt;
            
            // toggle for clock crossing
            status_update <= status_update ^ ((resolution_valid_nxt ^ resolution_valid)
                                              || (stable_nxt ^ stable)
                                              || (interlaced_nxt ^ interlaced));
            sticky_vid_v_sync <= sticky_vid_v_sync_nxt;
        end
    end
end

always_comb begin
    stable_state_nxt = stable_state;
    stable_nxt = stable;
    
    case(stable_state)
        ST_IDLE: begin
            stable_nxt = 0;
            if(falling_edge_de && !set_active_samples_flag)
                stable_state_nxt = ST_WAIT_FOR_TOTAL_SAMPLES;
        end
        ST_WAIT_FOR_TOTAL_SAMPLES: begin
            if(set_active_samples_flag)
                stable_state_nxt = ST_IDLE;
            else if(rising_edge_de && !set_total_samples_flag)
                stable_state_nxt = ST_2ND_LINE;
        end
        ST_2ND_LINE: begin
            if(set_active_samples_flag || set_total_samples_flag)
                stable_state_nxt = ST_IDLE;
            else if(falling_edge_de)
                stable_state_nxt = ST_2ND_LINE_WAIT_FOR_TOTAL_SAMPLES;    
        end
        ST_2ND_LINE_WAIT_FOR_TOTAL_SAMPLES: begin
            if(set_active_samples_flag || set_total_samples_flag)
                stable_state_nxt = ST_IDLE;
            else if(rising_edge_de)
                stable_state_nxt = ST_STABLE;    
        end
        ST_STABLE: begin
            stable_nxt = 1; // if two out of the last three lines have the same length then we are stable
            if(set_active_samples_flag)
                stable_state_nxt = ST_WAIT_FOR_RISING_EDGE_DE;
            else if(set_total_samples_flag)
                stable_state_nxt = ST_2ND_LINE;
        end
        ST_WAIT_FOR_RISING_EDGE_DE: begin
            if(rising_edge_de)
                stable_state_nxt = ST_2ND_LINE;
        end
    endcase
end

always_comb begin
    interlaced_state_nxt = interlaced_state;
    interlaced_nxt = interlaced;
    
    case(interlaced_state_nxt)
        INT_IDLE: begin
            if(falling_edge_v_blank_nxt)
                if(INTERLACED[0])
                    interlaced_state_nxt = INT_INTERLACED;
                else
                    interlaced_state_nxt = INT_PROGRESSIVE;
        end
        INT_PROGRESSIVE: begin
            if(falling_edge_v_blank_nxt && cond_vid_f) begin
                interlaced_nxt = 1;
                interlaced_state_nxt = INT_INTERLACED;
            end    
        end
        INT_INTERLACED: begin
            if(falling_edge_v_blank_nxt && current_field == cond_vid_f) begin
                interlaced_nxt = 0;
                interlaced_state_nxt = INT_PROGRESSIVE;
            end
        end
    endcase
end

always_comb begin
    resolution_state_nxt = resolution_state;
    resolution_valid_nxt = 0;

    case(resolution_state_nxt)
        RES_IDLE: begin
            if(falling_edge_de_nxt && sample_count_gte_32) begin
                resolution_state_nxt = RES_WAIT_FOR_TOTAL_SAMPLES;
            end
        end
        RES_WAIT_FOR_TOTAL_SAMPLES: begin
            if(rising_edge_de_nxt && sample_count_gte_32) begin
                resolution_state_nxt = RES_WAIT_FOR_F0_ACTIVE_LINES;
            end
        end
        RES_WAIT_FOR_F0_ACTIVE_LINES: begin
            if(set_active_samples_flag)
                resolution_state_nxt = RES_WAIT_FOR_TOTAL_SAMPLES;
            else if(rising_edge_v_blank_nxt && line_count_gte_32 && !current_field)
                resolution_state_nxt = RES_WAIT_FOR_F0_TOTAL_LINES;
        end
        RES_WAIT_FOR_F0_TOTAL_LINES: begin
            if(set_active_samples_flag)
                resolution_state_nxt = RES_WAIT_FOR_TOTAL_SAMPLES;
            else if(set_total_samples_flag)
                resolution_state_nxt = RES_WAIT_FOR_F0_ACTIVE_LINES;
            else if(falling_edge_v_blank_nxt) begin
                if(line_count_gte_32 && !current_field) begin
                    if(!interlaced_nxt)
                        resolution_state_nxt = RES_RESOLUTION_VALID;
                    else
                        resolution_state_nxt = RES_WAIT_FOR_F1_ACTIVE_LINES;
                end else
                    resolution_state_nxt = RES_IDLE;
            end
        end
        RES_WAIT_FOR_F1_ACTIVE_LINES: begin
            if(set_active_samples_flag)
                resolution_state_nxt = RES_WAIT_FOR_TOTAL_SAMPLES;
            else if(set_total_samples_flag)
                resolution_state_nxt = RES_WAIT_FOR_F0_ACTIVE_LINES;
            else if(set_active_lines_f0_flag)
                resolution_state_nxt = RES_WAIT_FOR_F0_TOTAL_LINES;
            else if(rising_edge_v_blank_nxt) begin
                if(line_count_gte_32 && current_field)
                    resolution_state_nxt = RES_WAIT_FOR_F1_TOTAL_LINES;
                else
                    resolution_state_nxt = RES_IDLE;
            end
        end
        RES_WAIT_FOR_F1_TOTAL_LINES: begin
            if(set_active_samples_flag)
                resolution_state_nxt = RES_WAIT_FOR_TOTAL_SAMPLES;
            else if(set_total_samples_flag)
                resolution_state_nxt = RES_WAIT_FOR_F0_ACTIVE_LINES;
            else if(set_active_lines_f0_flag)
                resolution_state_nxt = RES_WAIT_FOR_F0_TOTAL_LINES;
            else if(set_total_lines_f0_flag)
                resolution_state_nxt = RES_WAIT_FOR_F1_ACTIVE_LINES;
            else if(falling_edge_v_blank_nxt) begin
                if(line_count_gte_32 && current_field)
                    resolution_state_nxt = RES_RESOLUTION_VALID;
                else
                    resolution_state_nxt = RES_IDLE;
            end
        end
        RES_RESOLUTION_VALID: begin
            resolution_valid_nxt = 1;
            if(set_active_samples_flag)
                resolution_state_nxt = RES_WAIT_FOR_TOTAL_SAMPLES;
            else if(set_total_samples_flag)
                resolution_state_nxt = RES_WAIT_FOR_F0_ACTIVE_LINES;
            else if(set_active_lines_f0_flag)
                resolution_state_nxt = RES_WAIT_FOR_F0_TOTAL_LINES;
            else if(set_total_lines_f0_flag) begin
                if(!interlaced_nxt)
                    resolution_valid_nxt = 0;
                else
                    resolution_state_nxt = RES_WAIT_FOR_F1_ACTIVE_LINES;
            end else if(set_active_lines_f1_flag)
                resolution_state_nxt = RES_WAIT_FOR_F1_TOTAL_LINES;
            else if(set_total_lines_f1_flag) 
                resolution_valid_nxt = 0;
        end
    endcase
end

enum logic [3:0] { IDLE,
                   WRITE_DEFAULT_LINES_F0,
                   WRITE_DEFAULT_LINES_F1,
                   WRITE_DEFAULT_STATUS,
                   WAIT_FOR_SOF,
                   WAIT_FOR_RES_UPDATE,
                   WRITE_ACTIVE_SAMPLES,
                   WRITE_ACTIVE_LINES,
                   WRITE_TOTAL_SAMPLES,
                   WRITE_TOTAL_LINES_F0,
                   WRITE_TOTAL_LINES_F1,
                   WRITE_STATUS, 
                   WRITE_STANDARD,
                   WRITE_COLOUR } state_nxt, state;                   

logic status_update_done_nxt;
reg stable_needs_update;
reg res_needs_update;
logic stored_current_field_nxt;
reg stored_current_field;
logic write_total_lines_nxt;
reg write_total_lines;
                   
always_comb begin
    state_nxt = state;
    mem_write = 0;
    mem_address = REGISTER_ACTIVE_SAMPLES_ADDR[4:0];
    mem_write_data = active_sample_count << PIXELS_IN_PARALLEL_SHIFT;
    status_update_done_nxt = 0;
    stored_current_field_nxt = stored_current_field;
    write_total_lines_nxt = write_total_lines;
    
    case(state)
        IDLE: begin
            mem_write = 1;
            mem_address = REGISTER_ACTIVE_SAMPLES_ADDR[4:0];
            mem_write_data = H_ACTIVE_PIXELS[15:0];
            state_nxt = WRITE_DEFAULT_LINES_F0;
        end
        WRITE_DEFAULT_LINES_F0: begin
            mem_write = 1;
            mem_address = REGISTER_ACTIVE_LINES_F0_ADDR[4:0];
            mem_write_data = V_ACTIVE_LINES_F0[15:0];
            state_nxt = WRITE_DEFAULT_LINES_F1;
        end
        WRITE_DEFAULT_LINES_F1: begin
            mem_write = 1;
            mem_address = REGISTER_ACTIVE_LINES_F1_ADDR[4:0];
            mem_write_data = V_ACTIVE_LINES_F1[15:0];
            state_nxt = WRITE_DEFAULT_STATUS;
        end
        WRITE_DEFAULT_STATUS: begin
            mem_write = 1;
            mem_address = REGISTER_STATUS_ADDR[4:0];
            mem_write_data = {'0, INTERLACED[0], 7'd0};
            state_nxt = WAIT_FOR_SOF;
        end
        WAIT_FOR_SOF: begin
            if(cond_vid_datavalid && falling_edge_v_blank_nxt)
                state_nxt = WAIT_FOR_RES_UPDATE;
        end
        WAIT_FOR_RES_UPDATE: begin
            if(cond_vid_datavalid) begin
                if(rising_edge_v_blank_nxt) begin
                    state_nxt = WRITE_ACTIVE_SAMPLES;
                    stored_current_field_nxt = current_field;
                    if(falling_edge_v_blank_nxt)
                        write_total_lines_nxt = 1;
                    else
                        write_total_lines_nxt = 0;
                end else if(falling_edge_v_blank_nxt) begin
                    if(!current_field)
                        state_nxt = WRITE_TOTAL_LINES_F0;
                    else
                        state_nxt = WRITE_TOTAL_LINES_F1;
                end else if(stable_needs_update || res_needs_update)
                    state_nxt = WRITE_STATUS;
            end
        end
        WRITE_ACTIVE_SAMPLES: begin
        	mem_write = 1;
            mem_address = REGISTER_ACTIVE_SAMPLES_ADDR[4:0];
            mem_write_data = active_sample_count << PIXELS_IN_PARALLEL_SHIFT;
            if(!mem_stall) begin
                state_nxt = WRITE_ACTIVE_LINES;
            end
        end
        WRITE_ACTIVE_LINES: begin
        	mem_write = 1;
        	if(!stored_current_field) begin
                mem_address = REGISTER_ACTIVE_LINES_F0_ADDR[4:0];
                mem_write_data = active_line_f0_count << PIXELS_IN_PARALLEL_SHIFT;
            end else begin
                mem_address = REGISTER_ACTIVE_LINES_F1_ADDR[4:0];
                mem_write_data = active_line_f1_count << PIXELS_IN_PARALLEL_SHIFT;
            end    
            if(!mem_stall) begin
                state_nxt = WRITE_TOTAL_SAMPLES;
            end	
        end
        WRITE_TOTAL_SAMPLES: begin
        	mem_write = 1;
            mem_address = REGISTER_TOTAL_SAMPLES_ADDR[4:0];
            mem_write_data = total_sample_count << PIXELS_IN_PARALLEL_SHIFT;
            if(!mem_stall) begin
                if(write_total_lines)
                    if(!stored_current_field)
                        state_nxt = WRITE_TOTAL_LINES_F0;
                    else
                        state_nxt = WRITE_TOTAL_LINES_F1;
                else
                state_nxt = WAIT_FOR_RES_UPDATE;
            end
        end
        WRITE_TOTAL_LINES_F0: begin
        	mem_write = 1;
            mem_address = REGISTER_TOTAL_LINES_F0_ADDR[4:0];
            mem_write_data = total_line_f0_count << PIXELS_IN_PARALLEL_SHIFT;
            if(!mem_stall) begin
                state_nxt = WRITE_STANDARD;
            end	
        end
        WRITE_TOTAL_LINES_F1: begin
        	mem_write = 1;
            mem_address = REGISTER_TOTAL_LINES_F1_ADDR[4:0];
            mem_write_data = total_line_f1_count << PIXELS_IN_PARALLEL_SHIFT;
            if(!mem_stall) begin
                state_nxt = WRITE_STANDARD;
            end
        end
        WRITE_STANDARD: begin
            mem_write = 1;
            mem_address = REGISTER_STANDARD_ADDR[4:0];
            mem_write_data = {'0, captured_cond_vid_std};
            if(!mem_stall) begin
                state_nxt = WRITE_COLOUR;
            end
        end
        WRITE_COLOUR: begin
            mem_write = 1;
            mem_address = REGISTER_COLOUR_PATTERN_ADDR[4:0];
            mem_write_data = {captured_cond_vid_bit_width, captured_cond_vid_color_encoding};
            if(!mem_stall) begin
                state_nxt = WRITE_STATUS;
            end
        end
        WRITE_STATUS: begin
            mem_write = 1;
            mem_address = REGISTER_STATUS_ADDR[4:0];
            mem_write_data[STATUS_BIT_INTERLACED] = interlaced;
            mem_write_data[STATUS_BIT_RES_VALID] = resolution_valid;
            mem_write_data[STATUS_BIT_STABLE] = stable;
            status_update_done_nxt = 1;
            if(!mem_stall) begin
                state_nxt = WAIT_FOR_RES_UPDATE;
            end
        end
    endcase
end

always @(posedge clk or posedge rst) begin
    if(rst) begin
        state <= IDLE;
        stable_needs_update <= 0;
        res_needs_update <= 0;
        stored_current_field <= 0;
        write_total_lines <= 0;
    end else begin
        state <= state_nxt;
        stable_needs_update <= (stable_nxt ^ stable) || (stable_needs_update && !status_update_done_nxt);
        res_needs_update <=  (!resolution_valid_nxt && resolution_valid) || (res_needs_update && !status_update_done_nxt);
        stored_current_field <= stored_current_field_nxt;
        write_total_lines <= write_total_lines_nxt;
    end
end

assign refclk_div = rising_edge_hsync_nxt;
assign sof_locked = stable_nxt;
assign sof = rising_edge_vsync_nxt && (!interlaced || current_field);
    
endmodule
