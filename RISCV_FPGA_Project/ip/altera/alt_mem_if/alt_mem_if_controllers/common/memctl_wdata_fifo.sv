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
// This is a simple wrapper for the scfifo.
//////////////////////////////////////////////////////////////////////////////

`timescale 1 ps / 1 ps

module memctl_wdata_fifo(
	clk,
	reset_n,
	fifo_write_enable,
	fifo_read_enable,
	wdata_in,
	wdata_out
);

//////////////////////////////////////////////////////////////////////////////
// BEGIN PARAMETER SECTION

parameter DEVICE_FAMILY					= "";
parameter DWIDTH						= 0;
parameter NUM_BEATS_REQUIRED			= 0;
parameter WDATA_FIFO_ENABLE_PIPELINE	= 0;
parameter WDATA_FIFO_SHOW_AHEAD			= 0;
parameter AFI_RATE_RATIO				= 0;

// END PARAMETER SECTION
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// BEGIN LOCALPARAM SECTION

// The number of beats required to store in the FIFO adjusted for FIFO latency
localparam NUM_BEATS_REQUIRED_ADJUSTED	= NUM_BEATS_REQUIRED + 1;

localparam AFI_RATIO = 2 * AFI_RATE_RATIO;
localparam MEM_DWIDTH = DWIDTH / AFI_RATIO;

// FIFO size and FIFO address width
localparam FIFO_ADDR_WIDTH		= max(2, ceil_log2(NUM_BEATS_REQUIRED_ADJUSTED));
localparam FIFO_NUM_WORDS		= 2 ** FIFO_ADDR_WIDTH;

// END LOCALPARAM SECTION
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// BEGIN PORT SECTION

input					clk;
input					reset_n;
input					fifo_write_enable;
input					fifo_read_enable;
input	[DWIDTH-1:0]	wdata_in;
output	[DWIDTH-1:0]	wdata_out;

// END PORT SECTION
//////////////////////////////////////////////////////////////////////////////
wire	[DWIDTH-1:0]	data_in_wire;
wire                     write_req_wire;

wire	[DWIDTH-1:0]	data_in_remapped;
wire	[DWIDTH-1:0]	data_out_remapped;

generate
	if (WDATA_FIFO_ENABLE_PIPELINE == "ON") begin
		reg	[DWIDTH-1:0]	data_in_reg;
		reg                     write_req_reg;
		
		always_ff @ (posedge clk or negedge reset_n)
			if (~reset_n) begin
				data_in_reg = {DWIDTH{1'b0}};
				write_req_reg <= 1'b0;
			end
			else begin
				data_in_reg <= wdata_in;
				write_req_reg <= fifo_write_enable;
			end
		
		assign write_req_wire = write_req_reg;
		assign data_in_wire = data_in_reg;
	end
	else begin
		assign write_req_wire = fifo_write_enable;
		assign data_in_wire = wdata_in;
	end
endgenerate

genvar i, j;
generate
	for (i = 0; i < MEM_DWIDTH; i++)
	begin : wdata_map_dwidth
		for (j = 0; j < AFI_RATIO; j++)
		begin : wdata_map_afi_ratio
			assign data_in_remapped[i * AFI_RATIO + j] = data_in_wire[j * MEM_DWIDTH + i];
			assign wdata_out[j * MEM_DWIDTH + i] = data_out_remapped[i * AFI_RATIO + j];
		end
	end
endgenerate

scfifo wdata_fifo (
	.rdreq			(fifo_read_enable),
	.aclr			(~reset_n),
	.clock			(clk),
	.wrreq			(write_req_wire),
	.data			(data_in_remapped),
	.full			(),
	.q				(data_out_remapped),
	.sclr			(1'b0),
	.usedw			(),
	.empty			(),
	.almost_full	(),
	.almost_empty	());
defparam wdata_fifo.intended_device_family	= DEVICE_FAMILY;
defparam wdata_fifo.lpm_width				= DWIDTH;
defparam wdata_fifo.lpm_widthu				= FIFO_ADDR_WIDTH;
defparam wdata_fifo.lpm_numwords			= FIFO_NUM_WORDS;
defparam wdata_fifo.lpm_showahead			= WDATA_FIFO_SHOW_AHEAD;
defparam wdata_fifo.use_eab					= "ON";
defparam wdata_fifo.overflow_checking       = "OFF";
defparam wdata_fifo.underflow_checking      = "OFF";


// Returns the maximum of two numbers
function integer max;
	input integer a;
	input integer b;
	begin
		max = (a > b) ? a : b;
	end
endfunction


// Calculate the ceiling of log_2 of the input value
function integer ceil_log2;
	input integer value;
	begin
		value = value - 1;
		for (ceil_log2 = 0; value > 0; ceil_log2 = ceil_log2 + 1)
			value = value >> 1;
	end
endfunction


endmodule

