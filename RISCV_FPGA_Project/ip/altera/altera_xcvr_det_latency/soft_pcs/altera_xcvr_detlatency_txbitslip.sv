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

module altera_xcvr_detlatency_txbitslip #(
    parameter   full_data_width = 80,
    parameter   sel_width       = 7,
    parameter   dwidth_size     = 7
)  (
    input   clk,
    input   rst,
    input   [dwidth_size-1:0]       data_width,
    input   [full_data_width-1:0]   datain,
    input   [sel_width-1:0]         tx_boundary_sel,
    output reg  [full_data_width-1:0]   dataout
);
	reg						[full_data_width-1:0]	datain_latch;
	reg            [sel_width-1:0]	tx_boundary_sel_latch;
	wire				[2*full_data_width-1:0]	data_wide_20;
	wire				[2*full_data_width-1:0]	data_wide_80;
	wire				[2*full_data_width-1:0]	data_wide;
	wire          [full_data_width-1:0]	dataout_wire;
	wire           [dwidth_size-1:0] sync_data_width;


	assign data_wide_20     = {120'b0,datain[19:0],datain_latch[19:0]};//form the double width data for the 20b width from PMA
	assign data_wide_80     = {datain[79:0],datain_latch[79:0]};//form the double width data for the 80b width from PMA
	assign data_wide        = (sync_data_width==7'd80)? data_wide_80:(sync_data_width==7'd20)? data_wide_20:{2*full_data_width{1'b0}};//to select the data from 20b width or 80b width

	assign dataout_wire     = (sync_data_width==7'd80)? ((tx_boundary_sel_latch<80)? data_wide[(80-tx_boundary_sel_latch) +: full_data_width] : datain) :
	                          (sync_data_width==7'd20)? ((tx_boundary_sel_latch<20)? data_wide[(20-tx_boundary_sel_latch) +: full_data_width] : datain) : {full_data_width{1'b0}};

	always @ (posedge clk or posedge rst)
	begin
		if (rst)
		begin
			datain_latch	<= {full_data_width{1'b0}};
			dataout       <= {full_data_width{1'b0}};
			tx_boundary_sel_latch <= {sel_width{1'b0}};
		end
		else
		begin
			datain_latch	<= datain;
			dataout       <= dataout_wire;
			tx_boundary_sel_latch <= tx_boundary_sel;
		end
	end

    altera_xcvr_detlatency_synchronizer #(
        .width (dwidth_size),
        .stages(2)
    )sync_data_width_inst(
        .clk (clk),
        .rst (rst),
        .dat_in (data_width),
        .dat_out (sync_data_width)
    );        
endmodule    