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


//
//
//  An example distiller deisgned to highlihgt when a "trigger" event has happened and indicate that time at which it occured.
//
//  Pacekt format is as follows
//     packet encap byte
//     long TS
//     Byte detailing settings
//    EOP
`timescale 1ps / 1ps
`default_nettype none
module altera_trace_trigger_monitor_core #(


    parameter FULL_TS_LENGTH     = 40,     // Full resolution timestamp bitwidth // should be a multiple of 8 bits!
    parameter WAKE_UP_RUNNING    = 0,      // NOTE NOT YET SUPPORTED...

    parameter MFGR_ID            = 110,
    parameter TYPE_NUM           = 271,

// derived params
    parameter NUM_TS_SYMBOLS        = (FULL_TS_LENGTH + 7) / 8,
    parameter TRACE_SYMBOL_WIDTH    = (2 + NUM_TS_SYMBOLS),
    parameter TRACE_DATA_WIDTH      = 8 * TRACE_SYMBOL_WIDTH,
    parameter TRACE_EMPTY_WIDTH     = $clog2(TRACE_SYMBOL_WIDTH)
) (
    input  wire clk,
    input  wire arst_n,

    input  wire                         iut_st_valid,

// av_st_trace output
    input  wire                         av_st_tr_ready,
    output wire                         av_st_tr_valid,
    output wire                         av_st_tr_sop,
    output wire                         av_st_tr_eop,
    output reg   [TRACE_DATA_WIDTH-1:0] av_st_tr_data,
    output wire [TRACE_EMPTY_WIDTH-1:0] av_st_tr_empty,


    input  wire                         csr_s_write,
    input  wire                         csr_s_read,
    input  wire                   [3:0] csr_s_address,
    input  wire                  [31:0] csr_s_write_data,
    output reg                   [31:0] csr_s_readdata

);


localparam LP_TPIO_WIDTH = 1;

(* dont_merge *) reg        csr_wr_op;
(* dont_merge *) reg        csr_rd_op;
(* dont_merge *) reg  [3:0] csr_addr;
(* dont_merge *) reg [31:0] csr_wdata;

reg        output_enable;

reg                     enable_on_rising_edge;
reg                     enable_edge_detection;
reg                     manual_trigger_enable;
reg                     manual_trigger_request;
reg [LP_TPIO_WIDTH-1:0] tpoi_value;

// CSR set
always @(posedge clk or negedge arst_n) begin
    if (1'b0 == arst_n) begin
        csr_wr_op       <= 1'b0;
        csr_rd_op       <= 1'b0;
        csr_addr        <= 0;
        csr_wdata       <= 0;
        csr_s_readdata  <= {32{1'b0}};

        output_enable   <= WAKE_UP_RUNNING[0];

        enable_on_rising_edge    <= 1'b0;
        manual_trigger_enable    <= 1'b0;
        enable_edge_detection    <= 1'b0;
        tpoi_value               <= {LP_TPIO_WIDTH{1'b1}};
        manual_trigger_request   <= 1'b0;
    end else begin
        manual_trigger_request <= 1'b0;

        if (1'b1 == csr_wr_op) begin
            case (csr_addr)
                'd4:     begin output_enable                <= csr_wdata[ 0];
                               enable_edge_detection        <= csr_wdata[ 8];
                               enable_on_rising_edge        <= csr_wdata[ 9];
                               manual_trigger_enable        <= csr_wdata[10];
                               manual_trigger_request       <= csr_wdata[11];
                               tpoi_value[0+:LP_TPIO_WIDTH] <= csr_wdata[16+:LP_TPIO_WIDTH];
                         end
                default: begin                                 end
            endcase
        end

        csr_s_readdata <= {32{1'b0}};
        if (1'b1 == csr_rd_op) begin
            case (csr_addr)
                'd0: begin
                        csr_s_readdata[31:28]  <= 4'h0;
                        csr_s_readdata[27:12]  <= TYPE_NUM[15:0];
                        csr_s_readdata[11]     <= 1'b0;
                        csr_s_readdata[10: 0]  <= MFGR_ID[ 10:0];
                     end

                'd1: begin
                        csr_s_readdata[ 0+:8]  <= FULL_TS_LENGTH[0+:8];
                        // room for short TS if/when supported.
                     end

                'd4: begin  //CONTROL
                        csr_s_readdata[ 0] <= output_enable;
                        csr_s_readdata[ 8] <= enable_edge_detection;
                        csr_s_readdata[ 9] <= enable_on_rising_edge;
                        csr_s_readdata[10] <= manual_trigger_enable;
                       // csr_s_readdata[11] <= manual_trigger_request;

                        csr_s_readdata[16+:LP_TPIO_WIDTH] <= tpoi_value;
                     end

                default: begin
                          end
            endcase
        end

        csr_wr_op <= csr_s_write;
        csr_rd_op <= csr_s_read;
        csr_addr  <= csr_s_address;
        csr_wdata <= csr_s_write_data;
    end
end


reg                      dropped_ouptut_event_message;
reg                      write_output;
(* dont_merge *) reg [FULL_TS_LENGTH-1:0] int_ts;
reg [FULL_TS_LENGTH-1:0] sampled_ts;

assign av_st_tr_valid = write_output;




reg iut_st_valid_last;
reg manual_trigger_request_1t;
// Sample timestamp and define if we are going to try and write.
always @(posedge clk or negedge arst_n) begin
    if (1'b0 == arst_n) begin
        int_ts                       <= {FULL_TS_LENGTH{1'b0}};
        write_output                 <= 1'b0;
        dropped_ouptut_event_message <= 1'b0;
        sampled_ts                   <= {FULL_TS_LENGTH{1'b0}};
        iut_st_valid_last            <= 1'b0;
        manual_trigger_request_1t    <= 1'b0;
    end else begin
        int_ts <= int_ts + 1'b1;

        iut_st_valid_last <= iut_st_valid;

        if ((write_output == 1'b1) ) begin
            dropped_ouptut_event_message <= ~av_st_tr_ready;
        end

        write_output <= 1'b0;

        if (  ((iut_st_valid_last == ~iut_st_valid) && (1'b1 == enable_edge_detection) && (iut_st_valid == enable_on_rising_edge) )
             || ((manual_trigger_request == 1'b1) && (manual_trigger_enable == 1'b1))
            ) begin
            manual_trigger_request_1t <= manual_trigger_request & manual_trigger_enable;
            write_output <= output_enable;
            sampled_ts   <= int_ts;
        end
    end
end



assign av_st_tr_sop = 1'b1;
assign av_st_tr_eop = 1'b1;

// comb logic to assemble the output message
integer i;
always @(*) begin
    av_st_tr_data  = {TRACE_DATA_WIDTH{1'b0}};

    av_st_tr_data[TRACE_DATA_WIDTH-8+:8] = 'h80;                          //full TS no ED bits sent, no triggering or expansion bits set
    av_st_tr_data[TRACE_DATA_WIDTH-8]    = dropped_ouptut_event_message;   // set if we dropped previous message

    av_st_tr_data[TRACE_DATA_WIDTH-5 +:LP_TPIO_WIDTH] = tpoi_value[0+:LP_TPIO_WIDTH];
    // insert the TS here!
    for (i = 0; i < NUM_TS_SYMBOLS; i = i + 1) begin
        av_st_tr_data[TRACE_DATA_WIDTH-16- (8*i)+:8] = sampled_ts[8*i +:8];
    end

    // encode the settings and cause in the message
    av_st_tr_data[3] = manual_trigger_request_1t;
    av_st_tr_data[2] = enable_edge_detection;
    av_st_tr_data[1] = enable_on_rising_edge;
    av_st_tr_data[0] = manual_trigger_enable;
end

assign av_st_tr_empty = {TRACE_EMPTY_WIDTH{1'b0}};


endmodule
`default_nettype wire
