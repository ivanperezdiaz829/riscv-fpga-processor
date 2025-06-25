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
// The AFI module serves two purposes.  First, it translates the main state
// machine commands into the AFI 2.0 protocol.  Second, it delays the write
// data to satisfy the write latency requirement.
//////////////////////////////////////////////////////////////////////////////

`timescale 1 ps / 1 ps

module alt_rld_afi_no_ifdef_params (
	clk,
	reset_n,
	do_write,
	do_read,
	do_aref,
	addr,
	chip_addr,
	bank_addr,
	aref_bank_addr,
	wdata,
	wdata_valid,
	rdata,
	rdata_valid,
	wdata_req,
	afi_addr,
	afi_ba,
	afi_cs_n,
	afi_we_n,
	afi_ref_n,
	afi_wdata_valid,
	afi_wdata,
	afi_dm,
	afi_rdata_en,
	afi_rdata_en_full,
	afi_rdata,
	afi_rdata_valid
);

//////////////////////////////////////////////////////////////////////////////
// BEGIN PARAMETER SECTION

// CONTROLLER PARAMETERS
// Maximum write latency in controller cycles
parameter CTL_MAX_WRITE_LATENCY	= 0;
// For a half rate controller (AFI_RATE_RATIO=2), the burst length in the controller - equals memory burst length / 4
// For a full rate controller (AFI_RATE_RATIO=1), the burst length in the controller - equals memory burst length / 2
parameter CTL_BURST_LENGTH		= 0;
parameter CTL_ADDR_WIDTH		= 0;
parameter CTL_BANKADDR_WIDTH	= 0;
parameter CTL_CONTROL_WIDTH		= 0;
parameter CTL_CS_WIDTH			= 0;
parameter CTL_T_WL				= 0;

// AFI 2.0 INTERFACE PARAMETERS
parameter AFI_ADDR_WIDTH		= 0;
parameter AFI_BANKADDR_WIDTH	= 0;
parameter AFI_CONTROL_WIDTH		= 0;
parameter AFI_CS_WIDTH			= 0;
parameter AFI_DM_WIDTH			= 0;
parameter AFI_DWIDTH			= 0;
parameter AFI_WRITE_DQS_WIDTH	= 0;
parameter AFI_RATE_RATIO		= 0;

// Write data FIFO setting
parameter AFI_WDATA_REQ_DELAY	= 0;

// END PARAMETER SECTION
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// BEGIN PORT SECTION

// Clock and reset interface
input								clk;
input								reset_n;

// Commands from main state machine
input								do_write;
input								do_read;
input								do_aref;

input	[CTL_ADDR_WIDTH-1:0]		addr;
input	[CTL_CS_WIDTH-1:0]			chip_addr;
input	[CTL_BANKADDR_WIDTH-1:0]	bank_addr;
input	[CTL_BANKADDR_WIDTH-1:0]	aref_bank_addr;
input	[AFI_DWIDTH-1:0]			wdata;
input								wdata_valid;
output	[AFI_DWIDTH-1:0]			rdata;
output								rdata_valid;
// Read enable signal for the write data FIFO
output								wdata_req;

// AFI 2.0 PHY-Controller Interface
// Address and command
output	[AFI_ADDR_WIDTH-1:0]		afi_addr;
output	[AFI_BANKADDR_WIDTH-1:0]	afi_ba;
output	[AFI_CS_WIDTH-1:0]			afi_cs_n;
output	[AFI_CONTROL_WIDTH-1:0]		afi_we_n;
output	[AFI_CONTROL_WIDTH-1:0]		afi_ref_n;
// Write data
output	[AFI_WRITE_DQS_WIDTH-1:0]	afi_wdata_valid;
output	[AFI_DWIDTH-1:0]			afi_wdata;
output	[AFI_DM_WIDTH-1:0]			afi_dm;
// Read data
output	[AFI_RATE_RATIO-1:0]							afi_rdata_en;
output	[AFI_RATE_RATIO-1:0]							afi_rdata_en_full;
input	[AFI_DWIDTH-1:0]			afi_rdata;
input	[AFI_RATE_RATIO-1:0]							afi_rdata_valid;

// END PORT SECTION
//////////////////////////////////////////////////////////////////////////////

logic	[CTL_ADDR_WIDTH-1:0]		afi_addr_reg;
logic	[CTL_BANKADDR_WIDTH-1:0]	afi_ba_reg;
logic	[CTL_CS_WIDTH-1:0]			afi_cs_n_reg;
logic	[CTL_CONTROL_WIDTH-1:0]		afi_we_n_reg;
logic	[CTL_CONTROL_WIDTH-1:0]		afi_ref_n_reg;
wire	[CTL_MAX_WRITE_LATENCY:0]	write_latency_shifter;
wire								read_enable_shifter;


// In half rate mode, the controller only uses the higher command/address bits
generate
begin
	if (AFI_RATE_RATIO == 2) begin
		assign afi_addr = {afi_addr_reg,{CTL_ADDR_WIDTH{1'b0}}};
		assign afi_ba = {afi_ba_reg,{CTL_BANKADDR_WIDTH{1'b0}}};
		assign afi_cs_n = {afi_cs_n_reg,{CTL_CS_WIDTH{1'b1}}};
		assign afi_we_n = {afi_we_n_reg,{CTL_CONTROL_WIDTH{1'b1}}};
		assign afi_ref_n = {afi_ref_n_reg,{CTL_CONTROL_WIDTH{1'b1}}};
	end else begin
		assign afi_addr = afi_addr_reg;
		assign afi_ba = afi_ba_reg;
		assign afi_cs_n = afi_cs_n_reg;
		assign afi_we_n = afi_we_n_reg;
		assign afi_ref_n = afi_ref_n_reg;
	end
end
endgenerate
assign afi_wdata_valid = {AFI_WRITE_DQS_WIDTH{write_latency_shifter[CTL_T_WL]}};
assign afi_dm = {AFI_DM_WIDTH{~wdata_valid}};
assign afi_rdata_en = {AFI_RATE_RATIO{read_enable_shifter}};
assign afi_rdata_en_full = {AFI_RATE_RATIO{read_enable_shifter}};

// Connect write and read data signals
assign afi_wdata = wdata;
assign rdata = afi_rdata;
assign rdata_valid = afi_rdata_valid[0];
// Write data request is delayed to satisfy write latency requirement
assign wdata_req = write_latency_shifter[AFI_WDATA_REQ_DELAY];


// Translate commands from the state machine to AFI 2.0 commands
always_comb
begin
	if (do_aref)
	begin
		// Refresh - all chips
		afi_ba_reg <= aref_bank_addr;
		afi_addr_reg <= {CTL_ADDR_WIDTH{1'b0}};
	end
	else
	begin
		// Write/Read/NOP
		afi_ba_reg <= bank_addr;
		afi_addr_reg <= addr;
	end

	if (do_aref)
	begin
		// Refresh - all chips
		afi_cs_n_reg <= {CTL_CS_WIDTH{1'b0}};
		afi_we_n_reg <= {CTL_CONTROL_WIDTH{1'b1}};
		afi_ref_n_reg <= {CTL_CONTROL_WIDTH{1'b0}};
	end
	else if (do_write)
	begin
		// Write
		afi_cs_n_reg <= ~chip_addr;
		afi_we_n_reg <= {CTL_CONTROL_WIDTH{1'b0}};
		afi_ref_n_reg <= {CTL_CONTROL_WIDTH{1'b1}};
	end
	else if (do_read)
	begin
		// Read
		afi_cs_n_reg <= ~chip_addr;
		afi_we_n_reg <= {CTL_CONTROL_WIDTH{1'b1}};
		afi_ref_n_reg <= {CTL_CONTROL_WIDTH{1'b1}};
	end
	else
	begin
		// NOP
		afi_cs_n_reg <= {CTL_CS_WIDTH{1'b1}};
		afi_we_n_reg <= {CTL_CONTROL_WIDTH{1'b1}};
		afi_ref_n_reg <= {CTL_CONTROL_WIDTH{1'b1}};
	end
end


// Generate 'wdata_req' and 'afi_wdata_valid' by delaying 'do_write'
// for CTL_T_WL cycles and asserting for the entire burst
memctl_burst_latency_shifter_no_ifdef_params write_latency_shifter_inst (
	.clk		(clk),
	.reset_n	(reset_n),
	.d			(do_write),
	.q			(write_latency_shifter));
defparam write_latency_shifter_inst.MAX_LATENCY		= CTL_MAX_WRITE_LATENCY;
defparam write_latency_shifter_inst.BURST_LENGTH	= CTL_BURST_LENGTH;


// Generate 'afi_rdata_en_reg' by asserting for the entire burst
memctl_burst_latency_shifter_no_ifdef_params read_enable_shifter_inst (
	.clk		(clk),
	.reset_n	(reset_n),
	.d			(do_read),
	.q			(read_enable_shifter));
defparam read_enable_shifter_inst.MAX_LATENCY		= 0;
defparam read_enable_shifter_inst.BURST_LENGTH		= CTL_BURST_LENGTH;


// Simulation assertions
// synthesis translate_off
initial
begin
	assert (CTL_BURST_LENGTH > 0) else $error ("Invalid burst length");
	assert (CTL_ADDR_WIDTH <= CTL_ADDR_WIDTH) else $error ("Invalid address width");
end

always_ff @(posedge clk)
begin
	if (reset_n)
	begin
		assert (!(do_aref && do_write)) else $error ("Cannot refresh and write in the same cycle");
		assert (!(do_aref && do_read)) else $error ("Cannot refresh and read in the same cycle");
		assert (!(do_write && do_read)) else $error ("Cannot write and read in the same cycle");
	end
end
// synthesis translate_on


endmodule

