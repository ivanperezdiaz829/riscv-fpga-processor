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


module alt_vip_cvi_embedded_sync_extractor
    #(parameter
        DATA_WIDTH = 24,
        CHANNEL_WIDTH = 1,
        STD_WIDTH = 3,
        BPS = 10,
        GENERATE_ANC = 0,
        ANC_BASE_ADDRESS = 0,
        ANC_ADDRESS_WIDTH = 8)
    (
        input wire rst,
        input wire clk,
        
        input wire [DATA_WIDTH-1:0] vid_data,
        input wire [CHANNEL_WIDTH-1:0] vid_channel,
        input wire vid_datavalid,
        input wire vid_hd_sdn,
        
        // optional video ports
        output logic [DATA_WIDTH-1:0] cond_vid_data,
        output logic [CHANNEL_WIDTH-1:0] cond_vid_channel,
        output logic cond_vid_de,
        output logic cond_vid_f,
        output logic cond_vid_v_sync,
        output logic cond_vid_h_sync,
        output logic cond_vid_hd_sdn,
        
        output logic [ANC_ADDRESS_WIDTH-1:0] ram_address,
        output logic ram_we,
        output logic [15:0] ram_data);
        
localparam XYZ_BASE = (BPS >= 10) ? 2 : 0;
        
enum logic [1:0] { IDLE,
                   TRS_1,
                   TRS_2,
                   XYZ } state_nxt, state;

logic h_sync_nxt;
reg h_sync;
logic cond_vid_v_sync_nxt;
logic cond_vid_f_nxt;                   
                   
always_comb begin
    state_nxt = state;
    
    h_sync_nxt = h_sync;
    cond_vid_v_sync_nxt = cond_vid_v_sync;
    cond_vid_f_nxt = cond_vid_f;
    
    case(state)
        IDLE: begin
            if(vid_data[BPS-1:0] == {BPS{1'b1}})
                state_nxt = TRS_1;
        end
        TRS_1: begin
            if(vid_data[BPS-1:0] == {BPS{1'b0}})
                state_nxt = TRS_2;
            else if(vid_data[BPS-1:0] != {BPS{1'b1}})
                state_nxt = IDLE;
        end
        TRS_2: begin
            if(vid_data[BPS-1:0] == {BPS{1'b0}})
                state_nxt = XYZ;
            else
                state_nxt = IDLE;
        end
        XYZ: begin
            h_sync_nxt = vid_data[XYZ_BASE+4];
            cond_vid_v_sync_nxt = vid_data[XYZ_BASE+5];
            cond_vid_f_nxt = vid_data[XYZ_BASE+6];
            state_nxt = IDLE;
        end
    endcase
end

reg [DATA_WIDTH-1:0] vid_data_delay[4];
reg vid_hd_sdn_delay[4];
reg [CHANNEL_WIDTH-1:0] vid_channel_delay[4];
reg h_sync_delay[4];

assign cond_vid_data = vid_data_delay[3];
assign cond_vid_de = !cond_vid_h_sync && !cond_vid_v_sync;
assign cond_vid_hd_sdn = vid_hd_sdn_delay[3];
assign cond_vid_channel = vid_channel_delay[3];

// Delay the data so that it lines up with the sync signals
generate begin : vid_data_delay_array
    genvar i;
    for(i = 0; i < 4; i++) begin : vid_data_delay_for_loop
        always @ (posedge rst or posedge clk) begin
            if(rst) begin
                vid_data_delay[i] <= '0;
                vid_hd_sdn_delay[i] <= 1'b0;
                vid_channel_delay[i] <= '0;
                h_sync_delay[i] <= 1'b0;
            end else begin
                if(vid_datavalid) begin
                    if(i == 0) begin
                        vid_data_delay[i] <= vid_data;
                        vid_hd_sdn_delay[i] <= vid_hd_sdn;
                        vid_channel_delay[i] <= vid_channel;
                        h_sync_delay[i] <= h_sync_nxt;
                    end else begin 
                        vid_data_delay[i] <= vid_data_delay[i-1];
                        vid_hd_sdn_delay[i] <= vid_hd_sdn_delay[i-1];
                        vid_channel_delay[i] <= vid_channel_delay[i-1];
                        h_sync_delay[i] <= h_sync_delay[i-1];
                    end
                end
            end
        end
    end
end endgenerate

always @ (posedge rst or posedge clk) begin
    if(rst) begin
        state <= IDLE;
        h_sync <= 1'b1;
        cond_vid_h_sync <= 1'b0;
        cond_vid_v_sync <= 1'b1;
        cond_vid_f <= 1'b0;
        end else begin
        if(vid_datavalid) begin
            state <= state_nxt;
            h_sync <= h_sync_nxt;
            cond_vid_h_sync <= h_sync_nxt || h_sync_delay[3]; // the h sync must cover the EAV trs
            cond_vid_v_sync <= cond_vid_v_sync_nxt;
            cond_vid_f <= cond_vid_f_nxt;
        end
    end
end

generate begin : extract_ancillary_packets
    if(GENERATE_ANC) begin
        enum logic [3:0] { ANC_IDLE,
                           ANC_DATA_FLAG_1,
                           ANC_DATA_FLAG_2,
                           ANC_DATA_FLAG_3,
                           ANC_DID,
                           ANC_SID,
                           ANC_DATA_COUNT,
                           ANC_USER_WORDS,
                           ANC_END_PACKETS } anc_state_nxt, anc_state;
        
        logic [ANC_ADDRESS_WIDTH+1:0] anc_address_nxt;
        logic [ANC_ADDRESS_WIDTH:0] anc_address;
        logic anc_we_nxt, ram_we_nxt;
        logic [7:0] anc_data_nxt;
        logic [7:0] data_count_nxt, data_count;
        
        wire [BPS-1:0] anc_vid_data;
        assign anc_vid_data = (cond_vid_hd_sdn) ? cond_vid_data[DATA_WIDTH-1:DATA_WIDTH-BPS] : cond_vid_data[BPS-1:0];
        
        always_comb begin
            anc_state_nxt = anc_state;
            anc_address_nxt = {1'b0, anc_address};
            anc_we_nxt = 1'b0;
            anc_data_nxt = anc_vid_data[7:0];
            data_count_nxt = data_count;
            ram_we_nxt = 1'b0;
            
            case(anc_state)
                ANC_IDLE: begin
                    anc_address_nxt = {ANC_BASE_ADDRESS[ANC_ADDRESS_WIDTH+1:0], 1'b0};
                    if(vid_datavalid)
                        if(cond_vid_v_sync)
                            anc_state_nxt = ANC_DATA_FLAG_1;
                end
                ANC_DATA_FLAG_1: begin
                    if(vid_datavalid)
                        if(!cond_vid_v_sync)
                            anc_state_nxt = ANC_END_PACKETS;
                        else if(anc_vid_data == {BPS{1'b0}})
                            anc_state_nxt = ANC_DATA_FLAG_2; 
                end
                ANC_DATA_FLAG_2: begin
                    if(vid_datavalid)
                        if(anc_vid_data == {BPS{1'b1}})
                            anc_state_nxt = ANC_DATA_FLAG_3;
                        else if(anc_vid_data != {BPS{1'b0}})
                            anc_state_nxt = ANC_DATA_FLAG_1;
                end
                ANC_DATA_FLAG_3: begin
                    if(vid_datavalid)
                        if(anc_vid_data == {BPS{1'b1}})
                            anc_state_nxt = ANC_DID;
                        else
                            anc_state_nxt = ANC_DATA_FLAG_1;
                end
                ANC_DID: begin
                    anc_data_nxt = anc_vid_data[7:0];
                    if(vid_datavalid) begin
                        anc_address_nxt = anc_address + 1'b1;
                        anc_we_nxt = 1'b1;
                        anc_state_nxt = ANC_SID;
                    end
                end
                ANC_SID: begin
                    anc_data_nxt = anc_vid_data[7:0];
                    if(vid_datavalid) begin
                        anc_address_nxt = anc_address + 1'b1;
                        anc_we_nxt = 1'b1;
                        anc_state_nxt = ANC_DATA_COUNT;
                    end
                end
                ANC_DATA_COUNT: begin
                    anc_data_nxt = anc_vid_data[7:0];
                    data_count_nxt = anc_data_nxt - 1'd1;
                    if(vid_datavalid) begin
                        anc_address_nxt = anc_address + 1'b1;
                        anc_we_nxt = 1'b1;
                        anc_state_nxt = ANC_USER_WORDS;
                    end
                end
                ANC_USER_WORDS: begin
                    anc_data_nxt = anc_vid_data[7:0];
                    if(vid_datavalid) begin
                        anc_address_nxt = anc_address + 1'b1;
                        anc_we_nxt = 1'b1;
                        if(data_count == 8'd0)
                            anc_state_nxt = ANC_DATA_FLAG_1;
                        else
                            data_count_nxt = data_count - 1'd1;
                    end
                end
                ANC_END_PACKETS: begin
                    // end the ancillary packets with a word of all 1s
                    anc_we_nxt = 1'b1;
                    anc_data_nxt = '1;
                    anc_state_nxt = ANC_IDLE;
                    ram_we_nxt = 1'b1;
                end
            endcase
        end
        
        always @ (posedge rst or posedge clk) begin
            if(rst) begin
                anc_state <= ANC_IDLE;
                ram_address <= '0;
                ram_we <= 1'b0;
                ram_data <= '0;
                data_count <= '0;
                anc_address <= '0;
            end else begin
                anc_state <= anc_state_nxt;
                // protect against the address wrapping
                if(anc_address_nxt[ANC_ADDRESS_WIDTH+1] == 1)
                    anc_address <= anc_address;
                else
                    anc_address <= anc_address_nxt[ANC_ADDRESS_WIDTH:0];
                // convert from 8 bit data to 16 bit ram
                ram_address[ANC_ADDRESS_WIDTH-1:0] <= anc_address[ANC_ADDRESS_WIDTH:1];
                if(anc_we_nxt) begin
                    if(!anc_address[0]) begin
                        ram_data <= {ram_data[15:8], anc_data_nxt};
                        ram_we <= ram_we_nxt;
                    end else begin
                        ram_data <= {anc_data_nxt, ram_data[7:0]};
                        ram_we <= 1'b1;
                    end
                end else
                    ram_we <= 1'b0;
                data_count <= data_count_nxt;
            end
        end
    end else begin
        assign ram_address = '0;
        assign ram_we = 1'b0;
        assign ram_data = '0;
    end
end endgenerate

endmodule
