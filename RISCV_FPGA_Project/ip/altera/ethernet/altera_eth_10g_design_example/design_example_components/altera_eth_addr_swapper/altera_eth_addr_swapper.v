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


//-----------------------------------------------------------------------------
// DESCRIPTION
//
// The altera_eth_fifo_loopback module loopbacks the RX FIFO datapath to the TX FIFO datapath
// It will swap the destination address with the source address of Ethernet packets
// This core can only work for 10G applications. It does not supports backpressure. 
// Latency = 1
//
//-----------------------------------------------------------------------------

module altera_eth_addr_swapper (
        clk,           
        reset_n,
        avalon_st_rx_data,
        avalon_st_rx_empty,
        avalon_st_rx_eop,
        avalon_st_rx_error,
        avalon_st_rx_ready,
        avalon_st_rx_sop,
        avalon_st_rx_valid,
        avalon_st_tx_data,
        avalon_st_tx_empty,
        avalon_st_tx_eop,
        avalon_st_tx_error,
        avalon_st_tx_ready,
        avalon_st_tx_sop,
        avalon_st_tx_valid
    );

input          clk;           
input          reset_n;
input[63:0]    avalon_st_rx_data;
input[2:0]     avalon_st_rx_empty;
input          avalon_st_rx_eop;
input[5:0]     avalon_st_rx_error;
output         avalon_st_rx_ready;
input          avalon_st_rx_sop;
input          avalon_st_rx_valid;
output [63:0]  avalon_st_tx_data;
output [2:0]   avalon_st_tx_empty;
output         avalon_st_tx_eop;
output         avalon_st_tx_error;
input          avalon_st_tx_ready;
output         avalon_st_tx_sop;
output         avalon_st_tx_valid;

reg [63:0]     pipeline_data;
reg [2:0]      pipeline_empty;
reg            pipeline_eop;
reg            pipeline_error;
reg            pipeline_sop;
reg            pipeline_valid;

wire [63:0]    avalon_st_tx_data;
wire [2:0]     avalon_st_tx_empty;
wire           avalon_st_tx_eop;
wire           avalon_st_tx_error;
wire           avalon_st_rx_ready;
wire           avalon_st_tx_sop;
wire           avalon_st_tx_valid;


always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        pipeline_data <= {63{1'b0}};
        pipeline_empty <= {3{1'b0}};
        pipeline_eop <= 1'b0;
        pipeline_error <= 1'b0;
        pipeline_sop <= 1'b0;
        pipeline_valid <= 1'b0;
    end
    else begin
        if(avalon_st_tx_ready) begin
            if (pipeline_sop & pipeline_valid) begin
                pipeline_data <= {pipeline_data[47:16],avalon_st_rx_data[31:0]};
            end
            else begin
                pipeline_data <= avalon_st_rx_data;
            end
            pipeline_empty <= avalon_st_rx_empty;
            pipeline_eop <= avalon_st_rx_eop;
            pipeline_error <= |avalon_st_rx_error;
            pipeline_sop <= avalon_st_rx_sop;
            pipeline_valid <= avalon_st_rx_valid;
        end
    end
end

// Output
assign avalon_st_tx_data = (pipeline_sop & pipeline_valid)? {pipeline_data[15:0], avalon_st_rx_data[63:32],pipeline_data[63:48]} : pipeline_data;
assign avalon_st_tx_empty = pipeline_empty;
assign avalon_st_tx_eop = pipeline_eop;
assign avalon_st_tx_error = pipeline_error;
assign avalon_st_tx_sop = pipeline_sop;
assign avalon_st_tx_valid = pipeline_valid;

assign avalon_st_rx_ready = avalon_st_tx_ready;

endmodule

