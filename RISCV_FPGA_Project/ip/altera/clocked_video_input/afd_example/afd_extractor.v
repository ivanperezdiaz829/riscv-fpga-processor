//`define AFD_EXT_DEBUG

module afd_extractor(
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
    input wire [15:0] av_writedata,
    output reg av_interrupt);

`ifdef AFD_EXT_DEBUG
reg [31:0] input_packet_size;
reg [31:0] output_packet_size;

always @ (posedge clk or posedge rst) begin
    if(rst) begin
        input_packet_size <= 32'd0;
        output_packet_size <= 32'd0;
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
    end
end
`endif
    
localparam WAITING = 5'd0;
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

reg enable;

reg [9:0] afd_data1_nxt;
reg [9:0] afd_data2_nxt;
reg [9:0] afd_data3_nxt;
reg [9:0] afd_data4_nxt;
reg [9:0] afd_data5_nxt;
reg [9:0] afd_data6_nxt;
reg [9:0] afd_data7_nxt;
reg [9:0] afd_data8_nxt;
reg [9:0] afd_data1;
reg [9:0] afd_data2;
reg [9:0] afd_data3;
reg [9:0] afd_data4;
reg [9:0] afd_data5;
reg [9:0] afd_data6;
reg [9:0] afd_data7;
reg [9:0] afd_data8;

wire av_interrupt_nxt;
reg checksum_state;
reg go;
reg go_synced_nxt;
reg go_synced;

reg dout_valid_reg;

reg [4:0] state;
    
reg dout_valid_nxt;
reg [4:0] state_nxt;

wire image_packet;
reg ancilliary_packet;
reg afd_valid;
reg afd_valid_reg;
reg change_detected_nxt;
reg change_detected;
reg afd_change;

assign image_packet = din_valid && din_sop && din_data[3:0] == 4'd0;
assign av_interrupt_nxt = afd_change | (afd_valid & ~afd_valid_reg);

always @ (posedge clk or posedge rst) begin
    if(rst) begin
        av_interrupt <= 1'd0;
        av_readdata <= 16'd0;
        afd_valid <= 1'b0;
        afd_valid_reg <= 1'b0;
        change_detected <= 1'b0;
        go <= 1'b0;
        go_synced <= 1'b0;
        
        ancilliary_packet <= 1'b0;
        
        afd_data1 <= 10'd0;
        afd_data2 <= 10'd0;
        afd_data3 <= 10'd0;
        afd_data4 <= 10'd0;
        afd_data5 <= 10'd0;
        afd_data6 <= 10'd0;
        afd_data7 <= 10'd0;
        afd_data8 <= 10'd0;
        
        enable <= 1'b0;
        
        dout_data <= {20{1'b0}};
        dout_valid_reg <= 1'b0;
        dout_sop <= 1'b0;
        dout_eop <= 1'b0;
            
        state <= WAITING;
    end else begin
        if(av_read) begin
            case(av_address)
                4'd2: av_readdata <= {14'd0, av_interrupt, 1'b0};
                4'd3: av_readdata <= {12'd0, afd_data1[6:3]};   // afd
                4'd4: av_readdata <= {15'd0, afd_data1[2]};     // ar
                4'd5: av_readdata <= {12'd0, afd_data4[7:4]};   // bar_data_flags
                4'd6: av_readdata <= {afd_data5[7:0], afd_data6[7:0]};    // bar_data_value1
                4'd7: av_readdata <= {afd_data7[7:0], afd_data8[7:0]};    // bar_data_value2
                4'd8: av_readdata <= {15'd0, afd_valid};
                default: av_readdata <= 16'd0;
            endcase
        end
        
        if(av_write) begin
            case(av_address)
                4'd0: go <= av_writedata[0];
                4'd2: av_interrupt <= av_interrupt_nxt;
            endcase
        end else begin
            av_interrupt <= av_interrupt | av_interrupt_nxt;
        end
        
        ancilliary_packet <= (checksum_state | ancilliary_packet) & ~image_packet;
        afd_valid <= (checksum_state | afd_valid) & ~(image_packet & ~ancilliary_packet);
        afd_valid_reg <= afd_valid;
        change_detected <= (change_detected_nxt | change_detected) & ~checksum_state;
        
        go_synced <= go_synced_nxt;
    
        afd_data1 <= afd_data1_nxt;
        afd_data2 <= afd_data2_nxt;
        afd_data3 <= afd_data3_nxt;
        afd_data4 <= afd_data4_nxt;
        afd_data5 <= afd_data5_nxt;
        afd_data6 <= afd_data6_nxt;
        afd_data7 <= afd_data7_nxt;
        afd_data8 <= afd_data8_nxt;
    
        enable <= dout_ready;

        if(enable) begin            
            dout_data <= din_data;
            dout_valid_reg <= dout_valid_nxt;  // special case as the valid must be dropped when ready drops
            dout_sop <= din_sop;
            dout_eop <= din_eop;
            
            state <= state_nxt;
        end
    end
end

assign din_ready = dout_ready;
assign dout_valid = dout_valid_reg & enable;

always @ (state or go_synced_nxt or go_synced or change_detected or
          din_data or din_sop or din_eop or din_valid or
          afd_data1 or afd_data2 or afd_data3 or afd_data4 or afd_data5 or afd_data6 or afd_data7 or afd_data8) begin
    
    go_synced_nxt = go_synced;
    dout_valid_nxt = 1'b0;
    state_nxt = state;
    afd_data1_nxt = afd_data1;
    afd_data2_nxt = afd_data2;
    afd_data3_nxt = afd_data3;
    afd_data4_nxt = afd_data4;
    afd_data5_nxt = afd_data5;
    afd_data6_nxt = afd_data6;
    afd_data7_nxt = afd_data7;
    afd_data8_nxt = afd_data8;
    checksum_state = 1'b0;
    afd_change = 1'b0;
    change_detected_nxt = 1'b0;
    
    case(state)
        WAITING: begin
            if(din_valid & din_sop)
                go_synced_nxt = go;
            
            if(din_valid && din_sop && din_data[3:0] == 4'd13)
                state_nxt = ANC_DATA_FLAG_1;
            else if(go_synced_nxt)
                dout_valid_nxt = din_valid;
        end
        ANC_DATA_FLAG_1: begin
            if(din_valid)
                if(din_eop)
                    state_nxt = WAITING;
                else if(din_data[19:10] != {10{1'b0}})
                    state_nxt = ANC_DATA_FLAG_1;
                else
                    state_nxt = ANC_DATA_FLAG_2;
        end
        ANC_DATA_FLAG_2: begin
            if(din_valid)
                if(din_eop)
                    state_nxt = WAITING;
                else if(din_data[19:10] != {10{1'b1}})
                    state_nxt = ANC_DATA_FLAG_1;
                else
                    state_nxt = ANC_DATA_FLAG_3;
        end
        ANC_DATA_FLAG_3: begin
            if(din_valid)
                if(din_eop)
                    state_nxt = WAITING;
                else if(din_data[19:10] != {10{1'b1}})
                    state_nxt = ANC_DATA_FLAG_1;
                else
                    state_nxt = ANC_DATA_ID;
        end
        ANC_DATA_ID: begin
            if(din_valid)
                if(din_eop)
                    state_nxt = WAITING;
                else if(din_data[19:10] != {10'h241})
                    state_nxt = ANC_DATA_FLAG_1;
                else
                    state_nxt = ANC_SEC_DATA_ID;
        end
        ANC_SEC_DATA_ID: begin
            if(din_valid)
                if(din_eop)
                    state_nxt = WAITING;
                else if(din_data[19:10] != {10'h205})
                    state_nxt = ANC_DATA_FLAG_1;
                else
                    state_nxt = ANC_DATA_COUNT;
        end
        ANC_DATA_COUNT: begin
            if(din_valid)
                if(din_eop)
                    state_nxt = WAITING;
                else if(din_data[19:10] != {10'h108})
                    state_nxt = ANC_DATA_FLAG_1;
                else
                    state_nxt = ANC_USER_WORD_1;
        end
        ANC_USER_WORD_1: begin  // AFD
            if(din_valid) begin
                afd_data1_nxt = din_data[19:10];
                
                if(afd_data1 != afd_data1_nxt)
                    change_detected_nxt = 1'b1;
                
                if(din_eop)
                    state_nxt = WAITING;
                else
                    state_nxt = ANC_USER_WORD_2;
            end
        end
        ANC_USER_WORD_2: begin  // reserved
            afd_data2_nxt = din_data[19:10];
            
            if(din_valid)
                if(din_eop)
                    state_nxt = WAITING;
                else
                    state_nxt = ANC_USER_WORD_3;
        end
        ANC_USER_WORD_3: begin  // reserved
            afd_data3_nxt = din_data[19:10];
            
            if(din_valid)
                if(din_eop)
                    state_nxt = WAITING;
                else
                    state_nxt = ANC_USER_WORD_4;
        end
        ANC_USER_WORD_4: begin  // bar data flags
            if(din_valid) begin
                afd_data4_nxt = din_data[19:10];
                
                if(afd_data4 != afd_data4_nxt)
                    change_detected_nxt = 1'b1;
                
                if(din_eop)
                    state_nxt = WAITING;
                else
                    state_nxt = ANC_USER_WORD_5;
            end
        end
        ANC_USER_WORD_5: begin  // bar data value 1
            if(din_valid) begin
                afd_data5_nxt = din_data[19:10];
                
                if(afd_data5 != afd_data5_nxt)
                    change_detected_nxt = 1'b1;
                
                if(din_eop)
                    state_nxt = WAITING;
                else
                    state_nxt = ANC_USER_WORD_6;
            end
        end
        ANC_USER_WORD_6: begin  // bar data value 1
            if(din_valid) begin
                afd_data6_nxt = din_data[19:10];
                
                if(afd_data6 != afd_data6_nxt)
                    change_detected_nxt = 1'b1;
                
                if(din_eop)
                    state_nxt = WAITING;
                else
                    state_nxt = ANC_USER_WORD_7;
            end
        end
        ANC_USER_WORD_7: begin  // bar data value 2
            if(din_valid) begin
                afd_data7_nxt = din_data[19:10];
                
                if(afd_data7 != afd_data7_nxt)
                    change_detected_nxt = 1'b1;
                
                if(din_eop)
                    state_nxt = WAITING;
                else
                    state_nxt = ANC_USER_WORD_8;
            end
        end
        ANC_USER_WORD_8: begin  // bar data value 2
            if(din_valid) begin
                afd_data8_nxt = din_data[19:10];
                
                if(afd_data8 != afd_data8_nxt)
                    change_detected_nxt = 1'b1;
                
                if(din_eop)
                    state_nxt = WAITING;
                else
                    state_nxt = ANC_CHECKSUM;
            end
        end
        ANC_CHECKSUM: begin
            if(din_valid) begin
                checksum_state = 1'b1;
                
                if(change_detected)
                    afd_change = 1'b1;
                
                if(din_eop)
                    state_nxt = WAITING;
                else
                    state_nxt = ANC_DATA_FLAG_1;
            end
        end
    endcase
end

endmodule
