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

`define FIFO_SAMPLE_SIZE_WIDTH 8
`define FIFO_PH_MEASURE_ACC 32

module altera_xcvr_detlatency_ph_measure_fifo # (
  parameter data_width = 80,
  parameter fifo_depth = 4 //determine the depth. default 2 pow of 4
) (
  input                                rd_clk,
  input                                wr_clk,
  input                                calc_clk,
  input                                rst_rd,
  input                                rst_wr,
  input                                rst_calc,
  input               [data_width-1:0] wr_data,
  input  [`FIFO_SAMPLE_SIZE_WIDTH-1:0] fifo_sample_size,
  output              [data_width-1:0] rd_data,
  output    [`FIFO_PH_MEASURE_ACC-1:0] phase_measure_acc,
  output                [fifo_depth:0] fifo_wr_latency,
  output                [fifo_depth:0] fifo_rd_latency,
  output                               ph_acc_valid,
  output                               wr_full,
  output                               rd_empty
);

	localparam WR_RD_PTR_GAP = 6;  //avoid the wr_ptr to be too close to rd_ptr
	
	reg [WR_RD_PTR_GAP-1:0] rd_req;
  wire [fifo_depth:0] gray_rd_ptr, gray_wr_ptr;

  integer i;
	always @(posedge rd_clk or posedge rst_rd)
	begin 
		if (rst_rd)
			rd_req <= '0;
		else
		begin
			rd_req[0] <= ~rst_rd;
			for (i=WR_RD_PTR_GAP-1; i>0;i=i-1)
				rd_req[i] <= rd_req[i-1];
		end
	end
	
  altera_xcvr_detlatency_ph_dcfifo #(
    .dat_width    (data_width ),
    .addr_width   (fifo_depth ),
    .ptr_gap      (WR_RD_PTR_GAP)  
  ) fifo_inst (
    .rst_wr       (rst_wr                 ),
    .rst_rd       (rst_rd                 ),
    .rd_dat       (rd_data                ),
    .rd_clk       (rd_clk                 ),
    .rd_req       (rd_req[WR_RD_PTR_GAP-1]),
    .rd_empty     (rd_empty               ),
    .rd_used      (fifo_rd_latency        ),
    .gray_rd_ptr  (gray_rd_ptr            ),
    .wr_dat       (wr_data                ),
    .wr_clk       (wr_clk                 ),
    .wr_req       (~rst_wr                ),
    .wr_full      (wr_full                ),
    .wr_used      (fifo_wr_latency        ),
    .gray_wr_ptr  (gray_wr_ptr            )
  );
    
  altera_xcvr_detlatency_ph_calculator #(
    .data_width     (data_width),
    .addr_width     (fifo_depth)
  ) ph_cal_inst (
    .rd_ptr           (gray_rd_ptr      ),
    .wr_ptr           (gray_wr_ptr      ),
    .rd_clk           (rd_clk           ),
    .wr_clk           (wr_clk           ),
    .rst              (rst_calc         ),
    .calc_clk         (calc_clk         ),
    .fifo_sample_size (fifo_sample_size ),
    .phase_measure_acc(phase_measure_acc),
    .ph_acc_valid     (ph_acc_valid     )
  );

endmodule