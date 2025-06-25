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











//altmem_init CBX_AUTO_BLACKBOX="ALL" DEVICE_FAMILY="Stratix III" INIT_TO_ZERO="NO" NUMWORDS=4096 PORT_ROM_DATA_READY="PORT_USED" ROM_READ_LATENCY=1 WIDTH=32 WIDTHAD=12 clock datain dataout init init_busy ram_address ram_wren rom_address rom_data_ready rom_rden
//VERSION_BEGIN 10.0 cbx_altmem_init 2010:02:18:22:06:51:TO cbx_altsyncram 2010:02:18:22:06:51:TO cbx_cycloneii 2010:02:18:22:06:51:TO cbx_lpm_add_sub 2010:02:18:22:06:51:TO cbx_lpm_compare 2010:02:18:22:06:51:TO cbx_lpm_counter 2010:02:18:22:06:51:TO cbx_lpm_decode 2010:02:18:22:06:51:TO cbx_lpm_mux 2010:02:18:22:06:51:TO cbx_mgl 2010:02:18:22:28:03:TO cbx_stratix 2010:02:18:22:06:51:TO cbx_stratixii 2010:02:18:22:06:51:TO cbx_stratixiii 2010:02:18:22:06:51:TO cbx_util_mgl 2010:02:18:22:06:51:TO  VERSION_END
// synthesis VERILOG_INPUT_VERSION VERILOG_2001
// altera message_off 10463


//synthesis_resources = lpm_compare 2 lpm_counter 2 reg 51 
//synopsys translate_off
`timescale 1 ps / 1 ps
//synopsys translate_on
module  sequencer_raminit_meminit_46o
	( 
	clock,
	datain,
	dataout,
	init,
	init_busy,
	ram_address,
	ram_wren,
	rom_address,
	rom_data_ready,
	rom_rden) ;

	parameter ADDR_WIDTH = 13;
	parameter MEM_SIZE = 0;

	input   clock;
	input   [31:0]  datain;
	output   [31:0]  dataout;
	input   init;
	output   init_busy;
	output   [ADDR_WIDTH-1:0]  ram_address;
	output   ram_wren;
	output   [ADDR_WIDTH-1:0]  rom_address;
	input   rom_data_ready;
	output   rom_rden;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_off
`endif
	tri0   [31:0]  datain;
	tri0   rom_data_ready;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_on
`endif

	reg	[0:0]	capture_init;
	reg	[ADDR_WIDTH-1:0]	delay_addr;
	wire		wire_delay_addr_ena;
	reg	[31:0]	delay_data;
	wire		wire_delay_data_ena;
	reg	[2:0]	prev_state;
	wire	[2:0]	wire_state_reg_d;
	reg	[2:0]	state_reg;
	wire	[2:0]	wire_state_reg_sclr;
	wire	[2:0]	wire_state_reg_sload;
	wire  wire_addr_cmpr_aeb;
	wire  wire_addr_cmpr_alb;
	wire  wire_wait_cmpr_aeb;
	wire  wire_wait_cmpr_alb;
	wire  [ADDR_WIDTH-1:0]   wire_addr_ctr_q;
	wire  [0:0]   wire_wait_ctr_q;
	wire  [0:0]  addrct_eq_numwords;
	wire  [0:0]  addrct_lt_numwords;
	wire clken;
	wire  [31:0]  dataout_w;
	wire  [0:0]  done_state;
	wire  [0:0]  idle_state;
	wire  [0:0]  ram_write_state;
	wire  [0:0]  reset_state_machine;
	wire  [0:0]  rom_addr_state;
	wire  [0:0]  rom_data_capture_state;
	wire  [0:0]  state_machine_clken;

	// synopsys translate_off
	initial
		capture_init = 0;
	// synopsys translate_on
	always @ ( posedge clock)
		if (clken == 1'b1)   capture_init <= ((init | capture_init) & (~ done_state));


	// synopsys translate_off
	initial
		delay_addr = 0;
	// synopsys translate_on

	always @ ( posedge clock)
		if (wire_delay_addr_ena == 1'b1)   delay_addr <= wire_addr_ctr_q;

	assign
		wire_delay_addr_ena = clken & rom_data_capture_state;

	// synopsys translate_off
	initial
		delay_data = 0;
	// synopsys translate_on

	always @ ( posedge clock)
		if (wire_delay_data_ena == 1'b1)   delay_data <= datain;
	assign
		wire_delay_data_ena = clken & rom_data_capture_state;

	// synopsys translate_off
	initial
		prev_state = 0;
	// synopsys translate_on
	always @ ( posedge clock)
		if (clken == 1'b1)   prev_state <= state_reg;
	// synopsys translate_off
	initial
		state_reg[0:0] = 0;
	// synopsys translate_on
	always @ ( posedge clock)
		if (state_machine_clken == 1'b1) 
			if (wire_state_reg_sclr[0:0] == 1'b1) state_reg[0:0] <= 1'b0;
			else if (wire_state_reg_sload[0:0] == 1'b1) state_reg[0:0] <= 1;
			else  state_reg[0:0] <= wire_state_reg_d[0:0];
	// synopsys translate_off
	initial
		state_reg[1:1] = 0;
	// synopsys translate_on
	always @ ( posedge clock)
		if (state_machine_clken == 1'b1) 
			if (wire_state_reg_sclr[1:1] == 1'b1) state_reg[1:1] <= 1'b0;
			else if (wire_state_reg_sload[1:1] == 1'b1) state_reg[1:1] <= 1;
			else  state_reg[1:1] <= wire_state_reg_d[1:1];
	// synopsys translate_off
	initial
		state_reg[2:2] = 0;
	// synopsys translate_on
	always @ ( posedge clock)
		if (state_machine_clken == 1'b1) 
			if (wire_state_reg_sclr[2:2] == 1'b1) state_reg[2:2] <= 1'b0;
			else if (wire_state_reg_sload[2:2] == 1'b1) state_reg[2:2] <= 1;
			else  state_reg[2:2] <= wire_state_reg_d[2:2];
	assign
		wire_state_reg_d = {(((~ state_reg[2]) & state_reg[1]) & state_reg[0]), ((~ state_reg[2]) & (state_reg[1] ^ state_reg[0])), ((~ state_reg[2]) & (~ state_reg[0]))};
	assign
		wire_state_reg_sclr = {{2{reset_state_machine}}, 1'b0},
		wire_state_reg_sload = {{2{1'b0}}, reset_state_machine};
	lpm_compare   addr_cmpr
	( 
	.aeb(wire_addr_cmpr_aeb),
	.agb(),
	.ageb(),
	.alb(wire_addr_cmpr_alb),
	.aleb(),
	.aneb(),
	.dataa(delay_addr),
	.datab((MEM_SIZE/4) - 1)	
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_off
	`endif
	,
	.aclr(1'b0),
	.clken(1'b1),
	.clock(1'b0)
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_on
	`endif
	);
	defparam
		addr_cmpr.lpm_width = ADDR_WIDTH,
		addr_cmpr.lpm_type = "lpm_compare";
	lpm_compare   wait_cmpr
	( 
	.aeb(wire_wait_cmpr_aeb),
	.agb(),
	.ageb(),
	.alb(wire_wait_cmpr_alb),
	.aleb(),
	.aneb(),
	.dataa(wire_wait_ctr_q),
	.datab(1'b0)
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_off
	`endif
	,
	.aclr(1'b0),
	.clken(1'b1),
	.clock(1'b0)
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_on
	`endif
	);
	defparam
		wait_cmpr.lpm_width = 1,
		wait_cmpr.lpm_type = "lpm_compare";
	lpm_counter   addr_ctr
	( 
	.clk_en(clken),
	.clock(clock),
	.cnt_en(ram_write_state),
	.cout(),
	.eq(),
	.q(wire_addr_ctr_q),
	.sclr(((~ state_reg[1]) & (~ state_reg[0])))
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_off
	`endif
	,
	.aclr(1'b0),
	.aload(1'b0),
	.aset(1'b0),
	.cin(1'b1),
	.data({ADDR_WIDTH{1'b0}}),
	.sload(1'b0),
	.sset(1'b0),
	.updown(1'b1)
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_on
	`endif
	);
	defparam
		addr_ctr.lpm_direction = "UP",
		addr_ctr.lpm_modulus = (1<<ADDR_WIDTH),
		addr_ctr.lpm_port_updown = "PORT_UNUSED",
		addr_ctr.lpm_width = ADDR_WIDTH,
		addr_ctr.lpm_type = "lpm_counter";
	lpm_counter   wait_ctr
	( 
	.clk_en(clken),
	.clock(clock),
	.cnt_en(rom_addr_state),
	.cout(),
	.eq(),
	.q(wire_wait_ctr_q),
	.sclr((~ rom_addr_state))
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_off
	`endif
	,
	.aclr(1'b0),
	.aload(1'b0),
	.aset(1'b0),
	.cin(1'b1),
	.data({1{1'b0}}),
	.sload(1'b0),
	.sset(1'b0),
	.updown(1'b1)
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_on
	`endif
	);
	defparam
		wait_ctr.lpm_direction = "UP",
		wait_ctr.lpm_modulus = 1,
		wait_ctr.lpm_port_updown = "PORT_UNUSED",
		wait_ctr.lpm_width = 1,
		wait_ctr.lpm_type = "lpm_counter";
	assign
		addrct_eq_numwords = wire_addr_cmpr_aeb,
		addrct_lt_numwords = wire_addr_cmpr_alb,
		clken = 1'b1,
		dataout = dataout_w,
		dataout_w = delay_data,
		done_state = ((state_reg[2] & (~ state_reg[1])) & (~ state_reg[0])),
		idle_state = (((~ state_reg[2]) & (~ state_reg[1])) & (~ state_reg[0])),
		init_busy = capture_init,
		ram_address = delay_addr,
		ram_wren = ram_write_state,
		ram_write_state = (((~ state_reg[2]) & state_reg[1]) & state_reg[0]),
		reset_state_machine = (ram_write_state & addrct_lt_numwords),
		rom_addr_state = (((~ state_reg[2]) & (~ state_reg[1])) & state_reg[0]),
		rom_address = wire_addr_ctr_q,
		rom_data_capture_state = (((~ state_reg[2]) & state_reg[1]) & (~ state_reg[0])),
		rom_rden = (((~ prev_state[2]) & (((~ prev_state[1]) & (~ prev_state[0])) | (prev_state[1] & prev_state[0]))) & (((~ state_reg[2]) & (~ state_reg[1])) & state_reg[0])),
		state_machine_clken = (clken & ((idle_state & capture_init) | ((rom_data_capture_state | done_state) | (capture_init & (((~ (rom_addr_state & (~ rom_data_ready))) | (rom_addr_state & rom_data_ready)) | (ram_write_state & addrct_eq_numwords))))));
endmodule 


// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on
module sequencer_raminit (
	clock,
	datain,
	init,
	rom_data_ready,
	dataout,
	init_busy,
	ram_address,
	ram_wren,
	rom_address,
	rom_rden);

	parameter ADDR_WIDTH = 13;
	parameter MEM_SIZE = 0;

	input	  clock;
	input	[31:0]  datain;
	input	  init;
	input	  rom_data_ready;
	output	[31:0]  dataout;
	output	  init_busy;
	output	[ADDR_WIDTH-1:0]  ram_address;
	output	  ram_wren;
	output	[ADDR_WIDTH-1:0]  rom_address;
	output	  rom_rden;

	wire [ADDR_WIDTH-1:0] sub_wire0;
	wire  sub_wire1;
	wire [ADDR_WIDTH-1:0] sub_wire2;
	wire [31:0] sub_wire3;
	wire  sub_wire4;
	wire  sub_wire5;
	wire [ADDR_WIDTH-1:0] ram_address = sub_wire0[ADDR_WIDTH-1:0];
	wire  ram_wren = sub_wire1;
	wire [ADDR_WIDTH-1:0] rom_address = sub_wire2[ADDR_WIDTH-1:0];
	wire [31:0] dataout = sub_wire3[31:0];
	wire  init_busy = sub_wire4;
	wire  rom_rden = sub_wire5;

	sequencer_raminit_meminit_46o	sequencer_raminit_meminit_46o_component (
				.clock (clock),
				.init (init),
				.datain (datain),
				.rom_data_ready (rom_data_ready),
				.ram_address (sub_wire0),
				.ram_wren (sub_wire1),
				.rom_address (sub_wire2),
				.dataout (sub_wire3),
				.init_busy (sub_wire4),
				.rom_rden (sub_wire5));

	defparam sequencer_raminit_meminit_46o_component.ADDR_WIDTH = ADDR_WIDTH;
	defparam sequencer_raminit_meminit_46o_component.MEM_SIZE = MEM_SIZE;

endmodule

