//`define AFD_INS_DEBUG
`define NO_OF_PACKETS 16'd200

module afd_inserter(
    input  wire rst,
    input  wire clk,
    
    input  wire din_valid,
    input  wire [19:0] din_data,
    input  wire din_sop,
    input  wire din_eop,
    output wire din_ready,
    
    output wire dout_valid,
    output reg  [19:0] dout_data,
    output reg  dout_sop,
    output reg  dout_eop,
    input  wire dout_ready,
    
    // Control
    input [3:0] av_address,
    input av_read,
    output reg [15:0] av_readdata,
    input av_write,
    input wire [15:0] av_writedata);

localparam WAITING = 5'd0;
localparam SEND_PACKET = 5'd1;
localparam SEND_ANC_PACKET = 5'd2;
localparam ANC_SOP = 5'd3;
localparam ANC_DATA_FLAG_1 = 5'd4;
localparam ANC_DATA_FLAG_2 = 5'd5;
localparam ANC_DATA_FLAG_3 = 5'd6;
localparam ANC_DATA_ID = 5'd7;
localparam ANC_SEC_DATA_ID = 5'd8;
localparam ANC_DATA_COUNT = 5'd9;
localparam ANC_USER_WORD_1 = 5'd10;  // AFD
localparam ANC_USER_WORD_2 = 5'd11;  // reserved
localparam ANC_USER_WORD_3 = 5'd12;  // reserved
localparam ANC_USER_WORD_4 = 5'd13;  // bar data flags
localparam ANC_USER_WORD_5 = 5'd14;  // bar data value 1
localparam ANC_USER_WORD_6 = 5'd15;  // bar data value 1
localparam ANC_USER_WORD_7 = 5'd16;  // bar data value 2
localparam ANC_USER_WORD_8 = 5'd17;  // bar data value 2
localparam ANC_CHECKSUM = 5'd18;
    
wire [16:0] packet_count;
reg [4:0] state;
    
`ifdef AFD_INS_DEBUG
reg [31:0] input_packet_size;
reg [31:0] output_packet_size;
reg [16:0] packet_count_reg;

assign packet_count = packet_count_reg;

always @ (posedge clk or posedge rst) begin
    if(rst) begin
        input_packet_size <= 32'd0;
        output_packet_size <= 32'd0;
        packet_count_reg <= `NO_OF_PACKETS;
    end else begin
        if(din_valid) begin
            if(din_sop)
                input_packet_size <= 32'd1;
            else
                input_packet_size <= input_packet_size + 32'd1;
        end
        
        if(dout_valid) begin
            if(dout_sop)
                output_packet_size <= 32'd1;
            else
                output_packet_size <= output_packet_size + 32'd1;
        end
        
        if(state == ANC_CHECKSUM)
            if(packet_count_reg == 16'd0)
                packet_count_reg <= `NO_OF_PACKETS;
            else 
                packet_count_reg = packet_count_reg - 16'd1;
    end
end
`else
assign packet_count = 16'd0;
`endif

reg go;
reg [3:0] afd;
reg ar;
reg [3:0] bar_data_flags;
reg [15:0] bar_data_value1;
reg [15:0] bar_data_value2;

reg enable;
reg go_synced_nxt;
reg go_synced;

reg [19:0] din_data_reg;
reg din_valid_reg;
reg din_sop_reg;
reg din_eop_reg;

reg dout_valid_reg;

reg [3:0] control_code;
reg [8:0] checksum;
    
reg stall_input;
reg [3:0] control_code_nxt;
reg dout_valid_nxt;
reg [19:0] dout_data_nxt;
reg dout_sop_nxt;
reg dout_eop_nxt;
reg [4:0] state_nxt;
reg [7:0] afd_data;
wire [1:0] even_parity;
reg reset_checksum;

always @ (posedge clk or posedge rst) begin
    if(rst) begin
        go <= 1'b0;
        afd <= 4'd0;
        ar <= 1'b0;
        bar_data_flags <= 4'd0;
        bar_data_value1 <= 16'd0;
        bar_data_value2 <= 16'd0;
        
        enable <= 1'b0;
        
        go_synced <= 1'b0;
        
        din_data_reg <= 1'b0;
        din_valid_reg <= {20{1'b0}};
        din_sop_reg <= 1'b0;
        din_eop_reg <= 1'b0;
        
        dout_data <= {20{1'b0}};
        dout_valid_reg <= 1'b0;
        dout_sop <= 1'b0;
        dout_eop <= 1'b0;
        
        control_code <= 4'd0;
        checksum <= 9'd0;
            
        state <= WAITING;
    end else begin
        if(av_write) begin
            case(av_address)
                4'd0: go <= av_writedata[0];
                4'd3: afd <= av_writedata[3:0];
                4'd4: ar <= av_writedata[0];
                4'd5: bar_data_flags <= av_writedata[3:0];
                4'd6: bar_data_value1 <= av_writedata[15:0];
                4'd7: bar_data_value2 <= av_writedata[15:0];
            endcase
        end
        
        go_synced <= go_synced_nxt;
    
        enable <= dout_ready;

        if(enable) begin
            din_data_reg <= din_data;
            din_valid_reg <= din_valid;
            din_sop_reg <= din_sop;
            din_eop_reg <= din_eop;
            
            dout_data <= dout_data_nxt;
            dout_valid_reg <= dout_valid_nxt;  // special case as the valid must be dropped when ready drops
            dout_sop <= dout_sop_nxt;
            dout_eop <= dout_eop_nxt;
            
            control_code <= control_code_nxt;
            if(reset_checksum)
                checksum <= 9'd0;
            else
                checksum <= checksum + dout_data_nxt[18:10];
            
            state <= state_nxt;
        end
    end
end

assign din_ready = dout_ready & ~stall_input;
assign dout_valid = dout_valid_reg & enable;

always @ (state or go_synced_nxt or go or
          din_data or din_eop or din_valid or
          din_data_reg or din_sop_reg or din_eop_reg or din_valid_reg or
          control_code or afd_data or even_parity or checksum or dout_data_nxt) begin
    
    go_synced_nxt = go_synced;
    stall_input = 1'b1;
    control_code_nxt = control_code;
    dout_valid_nxt = 1'b1;
    dout_sop_nxt = 1'b0;
    dout_eop_nxt = 1'b0;
    dout_data_nxt = din_data_reg;
    reset_checksum = 1'b0;
    state_nxt = state;
    afd_data = 8'd0;
    
    case(state)
        WAITING: begin
            stall_input = 1'b0;
            
            dout_sop_nxt = din_sop_reg;
            dout_eop_nxt = din_eop_reg;
            dout_valid_nxt = din_valid_reg;
            
            if(din_valid && din_sop) begin
                go_synced_nxt = go;
                control_code_nxt = din_data[3:0];
                state_nxt = SEND_PACKET;
            end
        end
        SEND_PACKET: begin
            dout_sop_nxt = din_sop_reg;
            dout_eop_nxt = din_eop_reg;
            dout_valid_nxt = din_valid_reg;
            
            if(din_eop) begin
                if(control_code == 4'd15 && go_synced)
                    state_nxt = SEND_ANC_PACKET;
                else begin
                    stall_input = 1'b0;
                    state_nxt = WAITING;
                end
            end else
                stall_input = 1'b0;
        end
        SEND_ANC_PACKET: begin
            dout_sop_nxt = din_sop_reg;
            dout_eop_nxt = din_eop_reg;
            dout_valid_nxt = din_valid_reg;

            state_nxt = ANC_SOP;
        end
        ANC_SOP: begin
            dout_data_nxt = {{16{1'b0}}, 4'd13};
            dout_sop_nxt = 1'b1;
            
            state_nxt = ANC_DATA_FLAG_1;
        end
        ANC_DATA_FLAG_1: begin
            dout_data_nxt = {{10{1'b0}}, 10'h200};
            
            state_nxt = ANC_DATA_FLAG_2;
        end
        ANC_DATA_FLAG_2: begin
            dout_data_nxt = {{10{1'b1}}, 10'h200};
            
            state_nxt = ANC_DATA_FLAG_3;
        end
        ANC_DATA_FLAG_3: begin
            dout_data_nxt = {{10{1'b1}}, 10'h200};
            reset_checksum = 1'b1;
            
            state_nxt = ANC_DATA_ID;
        end
        ANC_DATA_ID: begin
            dout_data_nxt = {10'h241, 10'h200};
            
            state_nxt = ANC_SEC_DATA_ID;
        end
        ANC_SEC_DATA_ID: begin
            dout_data_nxt = {10'h205, 10'h200};
            
            state_nxt = ANC_DATA_COUNT;
        end
        ANC_DATA_COUNT: begin
            dout_data_nxt = {10'h108, 10'h200};
            
            state_nxt = ANC_USER_WORD_1;
        end
        ANC_USER_WORD_1: begin  // AFD
            afd_data[7:0] = {1'b0, afd[3:0], ar, 2'd0};
            dout_data_nxt = {even_parity, afd_data, 10'h200};
            
            state_nxt = ANC_USER_WORD_2;
        end
        ANC_USER_WORD_2: begin  // reserved
            afd_data[7:0] = {8'd0};
            dout_data_nxt = {even_parity, afd_data, 10'h200};
            
            state_nxt = ANC_USER_WORD_3;
        end
        ANC_USER_WORD_3: begin  // reserved
            afd_data[7:0] = {8'd0};
            dout_data_nxt = {even_parity, afd_data, 10'h200};
            
            state_nxt = ANC_USER_WORD_4;
        end
        ANC_USER_WORD_4: begin  // bar data flags
            afd_data[7:0] = {bar_data_flags[3:0], 4'd0};
            dout_data_nxt = {even_parity, afd_data, 10'h200};
            
            state_nxt = ANC_USER_WORD_5;
        end
        ANC_USER_WORD_5: begin  // bar data value 1
            afd_data[7:0] = {bar_data_value1[15:8]};
            dout_data_nxt = {even_parity, afd_data, 10'h200};
            
            state_nxt = ANC_USER_WORD_6;
        end
        ANC_USER_WORD_6: begin  // bar data value 1
            afd_data[7:0] = {bar_data_value1[7:0]};
            dout_data_nxt = {even_parity, afd_data, 10'h200};
            
            state_nxt = ANC_USER_WORD_7;
        end
        ANC_USER_WORD_7: begin  // bar data value 2
            afd_data[7:0] = {bar_data_value2[15:8]};
            dout_data_nxt = {even_parity, afd_data, 10'h200};
            
            state_nxt = ANC_USER_WORD_8;
        end
        ANC_USER_WORD_8: begin  // bar data value 2
            afd_data[7:0] = {bar_data_value2[7:0]};
            dout_data_nxt = {even_parity, afd_data, 10'h200};
            
            state_nxt = ANC_CHECKSUM;
        end
        ANC_CHECKSUM: begin
            dout_data_nxt = {~checksum[8], checksum[8:0], 10'h200};

            if(packet_count == 16'd0) begin
                dout_eop_nxt = 1'b1;
                state_nxt = WAITING;
            end else begin
                dout_eop_nxt = 1'b0;
                state_nxt = ANC_DATA_FLAG_1;
            end
        end
    endcase
end

assign even_parity[0] = ^afd_data;
assign even_parity[1] = ~even_parity[0];

endmodule
