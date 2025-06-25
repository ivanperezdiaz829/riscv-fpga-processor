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



`timescale 1 ps / 1 ps

`define XGMII_START     8'hFB
`define XGMII_TERMINATE 8'hFD

`define RX_SM_IDLE      1'b0
`define RX_SM_TRANSMIT  1'b1

`define S0_OFFSET				0
`define S4_OFFSET				72/2

module xgmii_sink (
	clock,
	reset,
	xgmii_tx_clk,
	xgmii_tx,
	xgmii_rx_clk,
	xgmii_rx,
	test_done,
	rx_ready,
	fifo_full,
	fifo_empty,
	read_stored_data,
	checker_pass,
	rx_mismatch,
	idle_state,
	xgmii_tx_d_mon,
	xgmii_tx_c_mon,
	xgmii_rx_d_mon,
	xgmii_rx_c_mon
); // module xgmii_sink

	input              clock;
	input              reset;
	input              xgmii_tx_clk;
	input       [71:0] xgmii_tx;
	input              xgmii_rx_clk;
	input       [71:0] xgmii_rx;
	input              rx_ready;
	input wire  [63:0] xgmii_rx_d_mon;
	input wire   [7:0] xgmii_rx_c_mon;
	input wire  [63:0] xgmii_tx_d_mon;
	input wire   [7:0] xgmii_tx_c_mon;
	input              test_done;
	output wire        fifo_full;
	output wire        fifo_empty;
	output      [71:0] read_stored_data;
	output reg         checker_pass = 0;
	output reg         rx_mismatch = 0;
	output reg				 idle_state=1;

	wire         [71:0] xgmii_rx_compare;
	reg                packet_write;
	reg                packet_read;
	reg         [31:0] match_count;
	reg         [31:0] mismatch_count;
	reg          [2:0] rx_sm_reg;


always @(posedge xgmii_tx_clk) begin
	if (reset) begin
		packet_write <= 0;
	end else begin
		if (rx_ready) begin
			if ((xgmii_tx_d_mon[7:0] == `XGMII_START) && ~fifo_full) begin
				packet_write <= 1;
			end else if (xgmii_tx_d_mon[7:0] == `XGMII_TERMINATE) begin
				packet_write <= 0;
			end
		end
	end
end

always @(posedge xgmii_rx_clk or negedge rx_ready) begin
	if (~rx_ready) begin
		rx_sm_reg      <= `RX_SM_IDLE;
		packet_read    <= 0;
		match_count    <= 0;
		mismatch_count <= 0;
		checker_pass   <= 0;
		idle_state     <= 1;
	end else begin
		case (rx_sm_reg)

			`RX_SM_IDLE: begin
		    idle_state  <= 1;
				packet_read <= 0;
				if ((test_done==1'b1) && (match_count>100) && (mismatch_count < 1)) begin
					checker_pass <= 1;
				end else if ((test_done==1'b1) && (mismatch_count > 1)) begin
					rx_mismatch <= 1;
				end
				if ((xgmii_rx_d_mon[7:0] == `XGMII_START)	&& ~fifo_empty) begin
				  packet_read <= 1; 
					rx_sm_reg <= `RX_SM_TRANSMIT;
				end
			end

			`RX_SM_TRANSMIT: begin
		    idle_state  <= 0;
				packet_read <= 1; 
				if (xgmii_rx_compare == read_stored_data) begin
					match_count <= match_count + 1;
				end 
				else begin
					mismatch_count <= mismatch_count + 1;
				end
				if (xgmii_rx_d_mon[7:0] == `XGMII_TERMINATE) begin
				  packet_read <= 0; 
					rx_sm_reg <= `RX_SM_IDLE;
				end
			end

		endcase // case (rx_sm_reg)
	end
end

assign xgmii_rx_compare = {xgmii_rx_d_mon,xgmii_rx_c_mon};

	checker_fifo checker_fifo_inst (
		.aclr(~rx_ready),
		.data({xgmii_tx_d_mon,xgmii_tx_c_mon}),
		.rdclk(xgmii_rx_clk),
		.rdreq(packet_read),
		.wrclk(xgmii_tx_clk),
		.wrreq(packet_write),
		.q(read_stored_data),
		.rdempty(fifo_empty),
		.wrfull(fifo_full)
	);
	
endmodule
