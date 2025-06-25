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

module tb;

reg refclk;
reg reset_n;

parameter PIN_WIDTH = IPTCL_PIN_WIDTH;
parameter PIN_TYPE = "IPTCL_PIN_TYPE";
parameter OUTPUT_MULT = IPTCL_OUTPUT_MULT;
parameter HALF_RATE_CIRCUITRY = "IPTCL_USE_HALF_RATE_OUTPUT";
parameter USE_BIDIR_STROBE = "IPTCL_USE_BIDIR_STROBE";
parameter USE_HARD_FIFOS = "IPTCL_USE_HARD_FIFOS";

localparam SIDE_DATA_WIDTH = OUTPUT_MULT * PIN_WIDTH * 2;
`ifdef STRATIXV
localparam DQS_READ_VALID_LATENCY =  (HALF_RATE_CIRCUITRY == "true")? 22 : 8;
`else
`ifdef ARRIAVGZ
localparam DQS_READ_VALID_LATENCY =  (HALF_RATE_CIRCUITRY == "true")? 22 : 8;
`else
localparam DQS_READ_VALID_LATENCY =  (HALF_RATE_CIRCUITRY == "true")? 36 : 33;
`endif
`endif

wire [PIN_WIDTH - 1 : 0] dq;
wire dqs_agent_to_core;
wire dqs_n_agent_to_core;
wire dqs_core_to_agent;
wire dqs_n_core_to_agent;
wire [SIDE_DATA_WIDTH - 1 : 0] dqs_writedata;
wire [SIDE_DATA_WIDTH - 1 : 0] dqs_readdata;
wire [SIDE_DATA_WIDTH - 1 : 0] side_writedata;
wire [SIDE_DATA_WIDTH - 1 : 0] side_readdata;
wire [4:0] lfifo_rd_latency = 5'b01111;
wire force_read_error = 1'b0;
wire vfifo_inc;
wire dqs_write;
wire dqs_enable;
wire dqs_read;
wire core_clk_fr;
wire core_clk_hr;
wire oct_enable;

wire dqs_ios_to_agent;
wire dqs_n_ios_to_agent;

wire strobe_io;
wire strobe_n_io;

wire agent_dqs_in = (USE_BIDIR_STROBE == "true")? strobe_io : dqs_ios_to_agent;
wire agent_dqs_in_n = (USE_BIDIR_STROBE == "true")? strobe_n_io : dqs_n_ios_to_agent;
wire agent_dqs_out;
wire agent_dqs_out_n;
wire agent_output_enable;
wire agent_reset_n_to_dqs;

wire dqs_agent_to_ios = agent_dqs_out;
wire dqs_n_agent_to_ios = agent_dqs_out_n;
wire dqs_ios_to_core;
wire enable_driver;

`ifdef STRATIXV
wire lfifo_rden;
wire vfifo_qvld;
`endif
`ifdef ARRIAVGZ
wire lfifo_rden;
wire vfifo_qvld;
`endif

`ifdef USE_CAPTURE_REG_EXTERNAL_CLOCKING
wire external_ddio_capture_clock;
assign #625 external_ddio_capture_clock = ~core_clk_fr;
`endif
`ifdef USE_READ_FIFO_EXTERNAL_CLOCKING
wire external_fifo_capture_clock;
assign #625 external_fifo_capture_clock = core_clk_fr;
`endif

`ifdef USE_DYNAMIC_CONFIG
reg beginscan;
initial
begin
	beginscan <= 1'b0;
	#100000;
	beginscan <= 1'b1;
	#50000;
	beginscan <= 1'b0;
end
`endif

top top_inst(
`ifdef PIN_HAS_OUTPUT
	.reset_n_core_clock_in(agent_reset_n_to_dqs),
`endif
`ifdef CONNECT_TO_HARD_PHY
	.write_strobe(),
`endif
`ifdef USE_DQS_ENABLE
	`ifdef STRATIXV	
		.capture_strobe_ena(capture_strobe_ena),
	`else
		`ifdef ARRIAVGZ
		.capture_strobe_ena(capture_strobe_ena),
		`else
			`ifndef USE_HARD_FIFOS
		.capture_strobe_ena(),
			`endif
		`endif
	`endif
`endif
`ifdef USE_DQS_TRACKING
	.capture_strobe_tracking(),
`endif
`ifdef PIN_TYPE_BIDIR
	.read_write_data_io(dq),
`endif
`ifdef PIN_HAS_OUTPUT
	.write_oe_in({OUTPUT_MULT*PIN_WIDTH{dqs_write}}),
`endif
`ifdef PIN_TYPE_INPUT
	.read_data_in(dq),
`endif
`ifdef PIN_TYPE_OUTPUT
	.write_data_out(dq),
`endif
`ifdef USE_BIDIR_STROBE
	.strobe_io(strobe_io),
	.output_strobe_ena({OUTPUT_MULT{dqs_enable}}),
	`ifdef USE_STROBE_N
	.strobe_n_io(strobe_n_io),
	`endif
`else
	`ifdef USE_OUTPUT_STROBE
	.output_strobe_out(dqs_ios_to_agent),
		`ifdef USE_STROBE_N
	.output_strobe_n_out(dqs_n_ios_to_agent),
		`endif
	`endif
	
	`ifdef PIN_HAS_INPUT
	.capture_strobe_in(dqs_agent_to_ios),
		`ifdef USE_STROBE_N
	.capture_strobe_n_in(dqs_n_agent_to_ios),
		`endif
	`endif
`endif

`ifdef USE_CAPTURE_REG_EXTERNAL_CLOCKING
	.external_ddio_capture_clock(external_ddio_capture_clock),
`endif
`ifdef USE_READ_FIFO_EXTERNAL_CLOCKING
	.external_fifo_capture_clock(external_fifo_capture_clock),
`endif

`ifdef USE_OCT_ENA_IN
	.oct_ena_in({OUTPUT_MULT{oct_enable}}),
`endif
`ifdef PIN_HAS_INPUT
	.read_data_out(dqs_readdata),
	.capture_strobe_out(dqs_ios_to_core),
`endif
`ifdef PIN_HAS_OUTPUT
	.write_data_in(dqs_writedata),
`endif	
`ifdef HAS_EXTRA_OUTPUT_IOS
	.extra_write_data_in(),
	.extra_write_data_out(),
`endif
`ifdef PIN_HAS_INPUT
`ifdef USE_HARD_FIFOS
	`ifdef STRATIXV
	.lfifo_rden (lfifo_rden),
	.vfifo_qvld (vfifo_qvld),
	.rfifo_reset_n (reset_n),
	`else
		`ifdef ARRIAVGZ
	.lfifo_rden (lfifo_rden),
	.vfifo_qvld (vfifo_qvld),
	.rfifo_reset_n (reset_n),
		`else
	.lfifo_rdata_en_full({OUTPUT_MULT{dqs_read}}),
	.lfifo_rd_latency(lfifo_rd_latency),
	.lfifo_reset_n(~reset_n),
	.vfifo_inc_wr_ptr({1'b0,vfifo_inc}),
	.vfifo_reset_n(~reset_n),
	.rfifo_reset_n(~reset_n),
		`endif
	`endif
`endif
`endif
`ifdef USE_DYNAMIC_CONFIG
	.beginscan(beginscan),
`endif
	.core_clk_fr(core_clk_fr),
	.core_clk_hr(core_clk_hr),
	.refclk(refclk),
	.reset_n(reset_n),
	.enable_driver(enable_driver),
	.rzqin(1'b0)
);

localparam DQS_WRITE_LATENCY = (HALF_RATE_CIRCUITRY == "true")? 3 : 1;
localparam DQS_READ_LATENCY = 8;

initial
	$vcdpluson;

dqsagent #(
	.DATA_WIDTH(PIN_WIDTH),
	.SIDE_DATA_WIDTH(SIDE_DATA_WIDTH),
	.FIFO_ADDR_WIDTH(5),
	.DQS_READ_LATENCY (DQS_READ_LATENCY),
	.DQS_WRITE_LATENCY(DQS_WRITE_LATENCY),
	.HALF_RATE_CIRCUITRY(HALF_RATE_CIRCUITRY)
) dqsagent_inst(
	.clk(core_clk_fr),
	.reset_n(reset_n),
	.dqs_in(agent_dqs_in),
	.dqs_in_n(agent_dqs_in_n),
	.dqs_out(agent_dqs_out),
	.dqs_out_n(agent_dqs_out_n),
	.dq(dq),
	.dqs_write(dqs_write),
	.dqs_read(dqs_read),
	.side_write(side_write),
	.side_writedata(side_writedata),
	.side_read(side_read),
	.side_readdata(side_readdata),
	.side_readdata_valid(side_readdata_valid),
	.force_read_error(force_read_error),
	.output_enable_out(agent_output_enable)
);

dqsdriver #(
	.PIN_WIDTH(PIN_WIDTH),
	.OUTPUT_MULT(OUTPUT_MULT),
	.CHECK_FIFO_DEPTH_LOG_2(4),
	.DQS_READ_LATENCY (DQS_READ_LATENCY),
	.HALF_RATE_CIRCUITRY(HALF_RATE_CIRCUITRY),
	.USE_BIDIR_STROBE(USE_BIDIR_STROBE)
) dqsdriver_inst(
	.clk(core_clk_fr),
	.clk_hr(core_clk_hr),
	.reset_n(reset_n),
	.core_reset_n(agent_reset_n_to_dqs),
	.enable(enable_driver),
	.dqs_write(dqs_write),
	.dqs_enable(dqs_enable),
	.dqs_writedata(dqs_writedata),
	.dqs_read(dqs_read),
	.dqs_readdata(dqs_readdata),
	.dqs_readdata_valid(dqs_readdata_valid),
	.oct_enable(oct_enable),
	.side_write(side_write),
	.side_writedata(side_writedata),
	.side_read(side_read),
	.side_readdata(side_readdata),
	.side_readdata_valid(side_readdata_valid),
	.vfifo_inc(vfifo_inc),
	.dqs_in(dqs_ios_to_core)
);

reg [DQS_READ_VALID_LATENCY - 1 : 0] dqs_read_valid_lat;
genvar i;
generate
begin : rdvalid

`ifdef STRATIXV
	if (USE_HARD_FIFOS == "true" && HALF_RATE_CIRCUITRY == "true")
	begin
		assign lfifo_rden = dqs_read_valid_lat[DQS_READ_VALID_LATENCY - 3];
		if (PIN_TYPE == "input")
		begin
			assign vfifo_qvld = dqs_read_valid_lat[DQS_READ_VALID_LATENCY - 16];
		end
		else begin
			assign vfifo_qvld = dqs_read_valid_lat[DQS_READ_VALID_LATENCY - 15];
		end
		assign capture_strobe_ena = dqs_read_valid_lat[DQS_READ_VALID_LATENCY - 17];
	end
	else
	begin
		assign capture_strobe_ena = dqs_read_valid_lat[DQS_READ_VALID_LATENCY - 3];
	end
`else
`ifdef ARRIAVGZ
	if (USE_HARD_FIFOS == "true" && HALF_RATE_CIRCUITRY == "true")
	begin
		assign lfifo_rden = dqs_read_valid_lat[DQS_READ_VALID_LATENCY - 3];
		if (PIN_TYPE == "input")
		begin
			assign vfifo_qvld = dqs_read_valid_lat[DQS_READ_VALID_LATENCY - 16];
		end
		else begin
			assign vfifo_qvld = dqs_read_valid_lat[DQS_READ_VALID_LATENCY - 15];
		end
		assign capture_strobe_ena = dqs_read_valid_lat[DQS_READ_VALID_LATENCY - 17];
	end
	else
	begin
		assign capture_strobe_ena = dqs_read_valid_lat[DQS_READ_VALID_LATENCY - 3];
	end
`else
	assign capture_strobe_ena = dqs_read_valid_lat[DQS_READ_VALID_LATENCY - 3];
`endif
`endif
	assign dqs_readdata_valid = dqs_read_valid_lat[DQS_READ_VALID_LATENCY - 1];
	
	always @(posedge core_clk_fr or negedge reset_n) begin
		if (~reset_n)
		begin
			dqs_read_valid_lat <= {DQS_READ_VALID_LATENCY{1'b0}};
		end
		else
		begin
			dqs_read_valid_lat[0] <= dqs_read;
		end
	end
	for(i = 1; i < DQS_READ_VALID_LATENCY; i = i + 1) begin
		always @(posedge core_clk_fr) begin
			dqs_read_valid_lat[i] <= dqs_read_valid_lat[i - 1];
		end
	end
end
endgenerate

assign strobe_io = agent_output_enable? dqs_agent_to_ios : 1'bz;
assign strobe_n_io = agent_output_enable? dqs_n_agent_to_ios : 1'bz;

always begin
	#5000 refclk = ~refclk;
end

initial begin
	// $vcdpluson;
	refclk = 0;
	reset_n = 0;
	#70000 reset_n = 1;
end

endmodule
