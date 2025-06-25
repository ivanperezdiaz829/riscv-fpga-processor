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


//////////////////////////////////////////////////////////////////////////////
// This module buffers the write data and keeps track of which beats are
// addressed by the user in a write or read request.
//////////////////////////////////////////////////////////////////////////////

`timescale 1 ps / 1 ps

module memctl_wdata_rdata_logic(
	clk,
	reset_n,
	do_write,
	do_read,
	merge_write,
	merge_read,
	beat_addr,
	wdata_in_valid,
	wdata_in,
	wdata_req,
	wdata_out,
	wdata_valid_out,
	rdata_in,
	rdata_valid,
	rdata_out,
	rdata_valid_out
);

//////////////////////////////////////////////////////////////////////////////
// BEGIN PARAMETER SECTION

parameter DEVICE_FAMILY					= "";
parameter AFI_DWIDTH					= 0;

// Maximum write and read latency in controller cycles
parameter CTL_MAX_WRITE_LATENCY			= 0;
parameter CTL_MAX_READ_LATENCY			= 0;

// Overall latency in the controller, used to determine write data FIFO size
parameter CTL_LATENCY					= 0;

parameter AFI_RATE_RATIO				= 0;
// For a half rate controller (AFI_RATE_RATIO=2), the burst length in the controller - equals memory burst length / 4
// For a full rate controller (AFI_RATE_RATIO=1), the burst length in the controller - equals memory burst length / 2
parameter CTL_BURST_LENGTH				= 0;

// Write data FIFO setting
parameter WDATA_FIFO_ENABLE_PIPELINE	= 0;
parameter WDATA_FIFO_SHOW_AHEAD			= 0;
parameter REGISTER_WDATA_VALID_FIFO_OUT	= 0;

// END PARAMETER SECTION
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// BEGIN LOCALPARAM SECTION

// The minimum FIFO size required
localparam WRITE_FIFO_NUM_BEATS_REQUIRED	= CTL_MAX_WRITE_LATENCY + CTL_LATENCY;
localparam READ_FIFO_NUM_BEATS_REQUIRED		= CTL_MAX_READ_LATENCY + CTL_BURST_LENGTH;

// END LOCALPARAM SECTION
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// BEGIN PORT SECTION

// Clock and reset interface
input							clk;
input							reset_n;

// State machine command outputs
input							do_write;
input							do_read;
input							merge_write;
input							merge_read;
// Beat address is one-hot encoded
input	[CTL_BURST_LENGTH-1:0]	beat_addr;

// Write data
input							wdata_in_valid;
input	[AFI_DWIDTH-1:0]		wdata_in;
input							wdata_req;
output	[AFI_DWIDTH-1:0]		wdata_out;
output							wdata_valid_out;

// Read data
input	[AFI_DWIDTH-1:0]		rdata_in;
input							rdata_valid;
output	[AFI_DWIDTH-1:0]		rdata_out;
output							rdata_valid_out;

// END PORT SECTION
//////////////////////////////////////////////////////////////////////////////

wire	wdata_valid;

assign rdata_out = rdata_in;


generate
if (WDATA_FIFO_SHOW_AHEAD == "ON")
begin : show_ahead_on
	assign wdata_valid_out = wdata_valid;
end
else
begin : show_ahead_off
	// register the wdata_valid signal to sync with wdata,
	// which is registered at the output of the wdata FIFO
	reg wdata_valid_out_reg;

	assign wdata_valid_out = wdata_valid_out_reg;

	always_ff @(posedge clk or negedge reset_n)
	begin
		if (!reset_n)
			wdata_valid_out_reg <= 1'b0;
		else
			wdata_valid_out_reg <= wdata_valid;
	end
end
endgenerate


// Write data FIFO
memctl_wdata_fifo memctl_wdata_fifo_inst (
	.clk				(clk),
	.reset_n			(reset_n),
	.fifo_write_enable	(wdata_in_valid),
	.fifo_read_enable	(wdata_valid),
	.wdata_in			(wdata_in),
	.wdata_out			(wdata_out));
defparam memctl_wdata_fifo_inst.DEVICE_FAMILY				= DEVICE_FAMILY;
defparam memctl_wdata_fifo_inst.DWIDTH						= AFI_DWIDTH;
defparam memctl_wdata_fifo_inst.NUM_BEATS_REQUIRED			= WRITE_FIFO_NUM_BEATS_REQUIRED;
defparam memctl_wdata_fifo_inst.WDATA_FIFO_ENABLE_PIPELINE	= WDATA_FIFO_ENABLE_PIPELINE;
defparam memctl_wdata_fifo_inst.WDATA_FIFO_SHOW_AHEAD		= WDATA_FIFO_SHOW_AHEAD;
defparam memctl_wdata_fifo_inst.AFI_RATE_RATIO				= AFI_RATE_RATIO;


// Beat valid FIFO for write requests
memctl_beat_valid_fifo memctl_wdata_valid_fifo_inst (
	.clk				(clk),
	.reset_n			(reset_n),
	.do_command			(do_write),
	.merge_command		(merge_write),
	.beat_addr			(beat_addr),
	.read_enable		(wdata_req),
	.beat_valid_out		(wdata_valid));
defparam memctl_wdata_valid_fifo_inst.CTL_BURST_LENGTH		= CTL_BURST_LENGTH;
defparam memctl_wdata_valid_fifo_inst.NUM_BEATS_REQUIRED	= WRITE_FIFO_NUM_BEATS_REQUIRED;
defparam memctl_wdata_valid_fifo_inst.REGISTER_OUTPUT		= REGISTER_WDATA_VALID_FIFO_OUT;


// Beat valid FIFO for read requests
memctl_beat_valid_fifo memctl_rdata_valid_fifo_inst (
	.clk				(clk),
	.reset_n			(reset_n),
	.do_command			(do_read),
	.merge_command		(merge_read),
	.beat_addr			(beat_addr),
	.read_enable		(rdata_valid),
	.beat_valid_out		(rdata_valid_out));
defparam memctl_rdata_valid_fifo_inst.CTL_BURST_LENGTH		= CTL_BURST_LENGTH;
defparam memctl_rdata_valid_fifo_inst.NUM_BEATS_REQUIRED	= READ_FIFO_NUM_BEATS_REQUIRED;
defparam memctl_rdata_valid_fifo_inst.REGISTER_OUTPUT		= "ON";


endmodule

