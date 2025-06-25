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


// synthesis VERILOG_INPUT_VERSION VERILOG_2001

/* altera_adv_seu_detection_proc_int
	This  top level module supports the Advanced SEU Detection feature
	configuration, when SEU location reporting and lookup performed in
	the FPGA using external memory interface to access the sensitivity
	data.  It  instantiates  and  connects  the  emr_unloader,  and
	asd_sensitivity_processor modules
	Note,  that some of the low level modules,  used  by both internal
	and external processor are defined in the alt_adv_seu_detection.v

*/
module altera_adv_seu_detection_proc_int
(
	clk,
	nreset,

	mem_addr,
	mem_rd,
	mem_bytesel,
	mem_wait,
	mem_data,
	mem_critical,

	critical_error,
	noncritical_error,
	critical_regions,
	crcerror_core,
	crcerror_pin,
	
	cache_comparison_off
);

	parameter error_clock_divisor = 2;
	parameter error_delay_cycles = 0;
	parameter clock_frequency = 50;
	parameter cache_depth = 10;
	parameter enable_virtual_jtag = 1;
	parameter emr_reg_width = 7'd46;
	parameter intended_device_family = "Stratix III";
	parameter mem_addr_width = 32;
	parameter start_address = 0;
	parameter regions_mask_width = 1;

	localparam mem_data_width = 32;

	input clk;
	input nreset;
	
	output [mem_addr_width-1:0] mem_addr;
	output mem_rd;
	output [3:0] mem_bytesel;
	input mem_wait;
	input [mem_data_width-1:0] mem_data;
	input mem_critical;
	input cache_comparison_off;
	
	output noncritical_error;
	output critical_error;
	output [regions_mask_width-1:0] critical_regions;
	output crcerror_core;

	output wire crcerror_pin;
	
	reg [mem_addr_width-1:0] mem_addr;
	wire mem_rd;
	reg [3:0] mem_bytesel;
	
	wire reset = ~nreset;

	wire emr_sload;
	wire [emr_reg_width-1:0] emr;
	
	emr_unloader emr_unloader(
		.clk(clk),
		.emr(emr),
		.reset(reset),
		.ready(emr_sload),
		.crcerror_core(crcerror_core),
		.crcerror_pin(crcerror_pin)
	);
	defparam 
		emr_unloader.intended_device_family = intended_device_family,	
		emr_unloader.error_clock_divisor = error_clock_divisor,
		emr_unloader.error_delay_cycles = error_delay_cycles,	
		emr_unloader.enable_virtual_jtag = enable_virtual_jtag,
		emr_unloader.emr_reg_width = emr_reg_width;	

	wire critical_error1;
	wire critical_error2;
	wire noncritical_error1;
	wire noncritical_error2;
	wire [regions_mask_width-1:0] regions_report1;
	wire [regions_mask_width-1:0] regions_report2;
	
	wire mem_rd1;
	wire [mem_addr_width-1:0] mem_addr1;
	reg mem_wait1;
	wire [3:0] mem_bytesel1;

	wire mem_rd2;
	wire [mem_addr_width-1:0] mem_addr2;
	reg mem_wait2;
	wire [3:0] mem_bytesel2;
	
	reg mem1_select;
	reg mem2_select;
	reg mem1_select_delayed;
	reg mem2_select_delayed;
	
	asd_sensitivity_processor asdsp1(
		.clk(clk),
		.reset(reset),
		.emr(emr),
		.emr_sload(emr_sload),
		.mem_addr(mem_addr1),
		.mem_rd(mem_rd1),
		.mem_bytesel(mem_bytesel1),
		.mem_wait(mem_wait1),
		.mem_data(mem_data),
		.mem_critical(mem_critical),
		.noncritical_error(noncritical_error1),
		.critical_error(critical_error1),
		.regions_report(regions_report1),
		.cache_comparison_off(cache_comparison_off)
	);
	defparam 
		asdsp1.emr_reg_width = emr_reg_width,	
		asdsp1.mem_addr_width = mem_addr_width,
		asdsp1.reg_mask_width = regions_mask_width,
		asdsp1.error_clock_divisor = error_clock_divisor,
		asdsp1.error_delay_cycles = error_delay_cycles,
		asdsp1.clock_frequency = clock_frequency,
		asdsp1.cache_depth = cache_depth,
		asdsp1.enable_virtual_jtag = enable_virtual_jtag,
		asdsp1.start_address = start_address;
	
	asd_sensitivity_processor asdsp2(
		.clk(clk),
		.reset(reset),
		.emr(emr),
		.emr_sload(emr_sload),
		.mem_addr(mem_addr2),
		.mem_rd(mem_rd2),
		.mem_bytesel(mem_bytesel2),
		.mem_wait(mem_wait2),
		.mem_data(mem_data),
		.mem_critical(mem_critical),
		.noncritical_error(noncritical_error2),
		.critical_error(critical_error2),
		.regions_report(regions_report2),
		.cache_comparison_off(cache_comparison_off)
	);
	defparam 
		asdsp2.emr_reg_width = emr_reg_width,	
		asdsp2.mem_addr_width = mem_addr_width,
		asdsp2.reg_mask_width = regions_mask_width,
		asdsp2.error_clock_divisor = error_clock_divisor,
		asdsp2.error_delay_cycles = error_delay_cycles,
		asdsp2.clock_frequency = clock_frequency,
		asdsp2.cache_depth = cache_depth,
		asdsp2.enable_virtual_jtag = 0,
		asdsp2.start_address = start_address;
	
	always @(mem_rd1, mem_rd2, mem_addr1, mem_addr2, mem_bytesel1, mem_bytesel2, mem1_select, mem2_select)
	begin
		if (mem1_select)
		begin
			mem_addr = mem_addr1;
			mem_bytesel = mem_bytesel1;
		end
		else if (mem2_select)
		begin
			mem_addr = mem_addr2;
			mem_bytesel = mem_bytesel2;
		end
		else
		begin
			mem_addr = {mem_addr_width{1'bX}};
			mem_bytesel = 4'bXXXX;
		end
	end
	
	assign mem_rd = (mem_rd1 && mem1_select) || (mem_rd2 && mem2_select);
	
	always @(posedge clk or posedge reset)
	begin
		if (reset)
		begin
			mem1_select = 1'b0;
			mem2_select = 1'b0;
			mem1_select_delayed = 1'b0;
			mem2_select_delayed = 1'b0;
			mem_wait1 = 1'b1;
			mem_wait2 = 1'b1;
		end
		else
		begin
			mem_wait1 = mem_wait || ~mem1_select_delayed;
			mem_wait2 = mem_wait || ~mem2_select_delayed;
			mem1_select_delayed = mem1_select;
			mem2_select_delayed = mem2_select;
			if (mem1_select || mem2_select)
			begin
				if (mem1_select && ~mem_rd1)
					mem1_select <= 1'b0;
				if (mem2_select && ~mem_rd2)
					mem2_select <= 1'b0;
			end
			else if (~mem1_select && ~mem2_select)
			begin
				mem1_select <= mem_rd1;
 				mem2_select <= mem_rd2 && ~mem_rd1;
 			end
		end
	end
	
	assign critical_error = critical_error1 || critical_error2;
	assign noncritical_error = noncritical_error1 || noncritical_error2;
	assign critical_regions = regions_report1;
endmodule

/* asd_sensitivity_processor module
	This module instantiates and connects cache, and mem_controller modules.
*/
module asd_sensitivity_processor
(
	clk,
	reset,

	emr,
	emr_sload,

	mem_addr,
	mem_rd,
	mem_bytesel,
	mem_wait,
	mem_data,
	mem_critical,

	critical_error,
	noncritical_error,
	regions_report,
	
	cache_comparison_off
);

	parameter emr_reg_width = 7'd46;
	parameter mem_addr_width = 32;
	parameter reg_mask_width = 1;
	parameter error_clock_divisor = 2;
	parameter error_delay_cycles = 0;
	parameter clock_frequency = 50;
	parameter cache_depth = 10;
	parameter enable_virtual_jtag = 1;
	parameter start_address = 0;
	
	localparam mem_data_width = 32;

	input clk;
	input reset;
	
	output [mem_addr_width-1:0] mem_addr;
	output mem_rd;
	output [3:0] mem_bytesel;
	input mem_wait;
	input [mem_data_width-1:0] mem_data;
	input mem_critical;
	
	output noncritical_error;
	output critical_error;
	output [reg_mask_width-1:0] regions_report;

	input [emr_reg_width-1:0] emr;
	input emr_sload;
	input cache_comparison_off;
		
	wire controller_ready;
	wire controller_critical;
	wire [reg_mask_width-1:0] critical_regions;
	wire [reg_mask_width-1:0] cache_regions_report;
	wire [emr_reg_width-1:0] cache_emr;
	wire cache_miss;
	wire cache_hit;
	wire cache_sload;
	wire cache_overflow;
	wire cache_critical;
	oneshot emr_oneshot(.in(emr_sload), .out(cache_sload), .clk(clk), .reset(reset));
	cache cache (
		.clk(clk),
		.reset(reset),
		.data(emr),
		.q(cache_emr),
		.sload(cache_sload),
		.miss(cache_miss),
		.hit(cache_hit),
		.overflow(cache_overflow),
		.mem_ready(controller_ready),
		.critical_in(controller_critical),
		.critical_out(cache_critical),
		.regions_report_in(critical_regions),
		.regions_report_out(cache_regions_report),
		.cache_comparison_off(cache_comparison_off)
	);
	defparam 
		cache.reg_width = emr_reg_width,
		cache.report_width = reg_mask_width,
		cache.depth = cache_depth,
		cache.enable_virtual_jtag = enable_virtual_jtag;
	
	wire controller_sload;
	oneshot cachemiss_oneshot(.in(cache_miss), .out(controller_sload), .clk(clk), .reset(reset));
	mem_controller mem_controller (
		.clk(clk),
		.reset(reset),
		
		.emr(cache_emr),
		.sload(controller_sload),
		
		.mem_addr(mem_addr),
		.mem_rd(mem_rd),
		.mem_wait(mem_wait),
		.mem_data(mem_data),
		.mem_bytesel(mem_bytesel),
		.mem_ready(controller_ready),
		.critical_regions(critical_regions),
		.critical(controller_critical)
	);
	defparam 
		mem_controller.emr_reg_width = emr_reg_width,
		mem_controller.reg_mask_width = reg_mask_width,
		mem_controller.mem_addr_width = mem_addr_width,
		mem_controller.mem_data_width = mem_data_width,
		mem_controller.start_address = start_address;
	
	assign critical_error = cache_critical || mem_critical || controller_critical || cache_overflow;
	assign noncritical_error = (cache_hit && ~cache_critical) || (controller_ready && ~controller_critical);
	assign regions_report = critical_regions | cache_regions_report;
endmodule


/* emr_unloader module
	This module is used to interface to the EMR atom, shifting the serial data
	out of the EMR user register.  When the shifting is complete, the data is
	available on the emr output, and the ready output is asserted.  The ready
	output will stay asserted until another error is reporrted by the EDC
	block.  If a second error is reported by the EDC before the first error
	has been completely unloaded from the EMR, the critical output will be
	asserted. 
	
	This module includes two sources & probes instances.
	"EMR" probes the current contents of the unloaded EMR data, and allows
	   it to be overwritten.
	"CRCE" probes the crcerror output from the EMR block, and allows an
	   error to be injected.
	*/
module emr_unloader (
	clk,
	emr,
	reset,
	ready,

	crcerror_pin,
	crcerror_core
);
	parameter emr_reg_width = 7'd46;
	parameter enable_virtual_jtag = 1;
	parameter intended_device_family = "Stratix III";
	parameter error_clock_divisor = 2;
	parameter error_delay_cycles = 0;

	input clk;
	output [emr_reg_width-1:0] emr;
	output ready;
	input reset;
	output crcerror_core;
	
	output crcerror_pin;

	reg shiftnld;
	wire regout;
	wire crcerror_wire /* synthesis keep */;
	wire inject_error;
	wire is_crcerror = inject_error || crcerror_wire;
	wire crcerror_pulse;
	
	oneshot crcerror_oneshot(.in(is_crcerror), .out(crcerror_pulse), .clk(clk), .reset(reset));
		
	reg emr_clk;
	crcblock_atom emr_atom (
			.inclk(emr_clk),
			.shiftnld(shiftnld),
			.regout(regout),
			.crcerror(crcerror_wire)
		);
	defparam
		emr_atom.intended_device_family = intended_device_family,	
		emr_atom.error_delay_cycles = error_delay_cycles,
		emr_atom.error_clock_divisor = error_clock_divisor;

	assign crcerror_pin = crcerror_wire;

	reg [4:0] current_state /* synthesis altera_attribute = "-name SUPPRESS_REG_MINIMIZATION_MSG ON" */;
	reg [4:0] next_state;
	localparam STATE_WAIT		= 5'b00000;
	localparam STATE_LOAD 		= 5'b00010;
	localparam STATE_SHIFTSTART	= 5'b00101;
	localparam STATE_CLOCKLOW  	= 5'b01000;
	localparam STATE_CLOCKHIGH 	= 5'b01001;
	localparam STATE_READY		= 5'b10000;

	reg [emr_reg_width-1:0] emr_reg;
	wire [emr_reg_width-1:0] emr_reg_source;
	reg counter_enable;
	reg counter_set;
	reg [6:0] counter_value;
	wire counter_done;
	reg ready_reg;

	
	generate
		if (enable_virtual_jtag) begin: emr_enable_virtual_jtag
			source_probe #(.width(emr_reg_width),.instance_id("EMR")) emr_probe (.probe(emr_reg), .source(emr_reg_source));
			source_probe #(.width(1),.instance_id("CRCE")) crc_error_probe (.probe(is_crcerror), .source(inject_error));
		end
		else
		begin
			assign emr_reg_source = {emr_reg_width{1'bX}};
			assign inject_error = 1'b0;
		end
	endgenerate

	/* State machine:
		WAIT:        idle state, holds until crcerror pulse
		LOAD:        asserts shiftnld low, holds for counter cycles
		SHIFTSTART:  asserts shiftnld low, shifts first bit
		CLOCKLOW:    emr_clk low
		CLOCKHIGH:   emr_clk high, loops to SHIFTSTART 'emr_reg_width' times, then goes to READY
		READY:       asserts ready output, holds until next crcerror pulse
	*/
	always @(current_state or crcerror_pulse or counter_done or emr_reg)
		begin
			// default values
			ready_reg = 1'b0;
			emr_clk = 1'b0;
			counter_set = 1'b0;
			counter_value = 7'b0;
			counter_enable = 1'b0;
			shiftnld = 1'b1;
			next_state = current_state;
			case (current_state)
			STATE_WAIT:
				begin
					counter_set = 1'b1;
					counter_value = 7'd10;
					if (crcerror_pulse)
						next_state = STATE_LOAD;
				end
			STATE_LOAD:
				begin
					shiftnld = 1'b0;
					counter_enable = 1'b1;
					if (counter_done)
						next_state = STATE_SHIFTSTART;
				end
			STATE_SHIFTSTART:
				begin
					shiftnld = 1'b0;
					counter_set = 1'b1;
					counter_value = emr_reg_width[6:0] - 7'd1;
					emr_clk = 1'b1;
					next_state = STATE_CLOCKLOW;
				end
			STATE_CLOCKLOW:
				begin
					counter_enable = 1'b1;
					next_state = STATE_CLOCKHIGH;
				end
			STATE_CLOCKHIGH:
				begin
					emr_clk = 1'b1;
					if (counter_done)
						next_state = STATE_READY;
					else
						next_state = STATE_CLOCKLOW;
				end
			STATE_READY:
				begin
					counter_set = 1'b1;
					counter_value = 7'd10;
					ready_reg = 1'b1;
					if (crcerror_pulse)
						next_state = STATE_LOAD;
				end
			endcase
		end
	
	always @(posedge clk or posedge reset)
	begin
		if (reset)
		begin
			current_state = STATE_WAIT;
			emr_reg = {emr_reg_width{1'b0}};
		end
		else
		begin
			current_state = next_state;
			if (emr_clk && ~inject_error)
				emr_reg[emr_reg_width-1:0] = {regout, emr_reg[emr_reg_width-1:1]};
			else if (emr_clk && inject_error)
				emr_reg[emr_reg_width-1:0] = emr_reg_source[emr_reg_width-1:0];
		end
	end
	
	wire [6:0] counter_q;
	lpm_counter #(.lpm_width(7), .lpm_direction("DOWN")) counter(
		.clock(clk),
		.cnt_en(counter_enable),
		.sload(counter_set),
		.data(counter_value),
		.q(counter_q)
	);
	
	assign counter_done = (counter_q == 7'b0);
	assign ready = ready_reg;
	assign emr = emr_reg;
	assign crcerror_core = is_crcerror;
endmodule

/* cache module
	This module prevents reading from the critical error memory storage when
	a previous error is reported again. The data input is sampled when sload
	is asserted.  The  state machine then checks each cache slot against the
	the reported error. If a match is found, the hit output is asserted, and
	the  recorded  critical/noncritical  state is driven on the critical_out
	output.  If no match is found, the miss output is asserted, and the data
	is available on the q output.  The memory module should then look up the
	error and report  the  critical/noncritical  state  on  critical_in  and
	assert the mem_ready input.  The  cache  module  will then write the EMR
	data and the critical/noncritical state to the cache.
*/
module cache (
	clk,
	reset,

	data,
	q,
	sload,

	hit,
	miss,
	overflow,
	critical_out,
	critical_in,
	regions_report_out,
	regions_report_in,
	mem_ready,

	cache_comparison_off
);
	parameter depth = 10;
	parameter enable_virtual_jtag = 1;
	parameter report_width = 1;
	parameter reg_width = 46;
	
	localparam depth_width = log2(depth);
	
	localparam mem_width = reg_width + 1 + report_width;
	localparam mem_critical_rpt = reg_width + 1;
	localparam mem_critical_bit = reg_width;

	input clk;
	input reset;
	input [reg_width-1:0] data;
	input sload;
	input critical_in;
	input mem_ready;
	input cache_comparison_off;
	input [report_width-1:0] regions_report_in;
	output [report_width-1:0] regions_report_out;
	output [reg_width-1:0] q;
	output critical_out;
	output hit;
	output miss;
	output overflow;

	integer i;

	reg hit;
	reg miss;
	reg overflow;
	reg critical_out;
	reg [report_width-1:0] regions_report_out;
	reg report_latch;
	
	
	reg [mem_width-1:0] cache[depth-1:0];
	
	reg [reg_width-1:0] r /* synthesis preserve */;
	assign q = r;
	
	reg [depth_width-1:0] cache_address;
	wire [mem_width-1:0] cache_q;
	
	// Write to cache on mem_ready signal
	wire cache_write = mem_ready;
	wire write_counter_enable = mem_ready;
	
	// Cache write counter
	wire [depth_width-1:0] write_counter_q;
	lpm_counter #(.lpm_width(depth_width), .lpm_direction("UP")) write_counter (
		.clock(clk),
		.cnt_en(write_counter_enable),
		.aclr(reset),
		.q(write_counter_q)
	);

	// Cache read counter for hit/miss comparison
	reg read_counter_enable;
	wire [depth_width-1:0] read_counter_q;
	reg read_counter_clear;
	lpm_counter #(.lpm_width(depth_width), .lpm_direction("UP")) read_counter (
		.clock(clk),
		.cnt_en(read_counter_enable),
		.aclr(reset),
		.sclr(read_counter_clear),
		.q(read_counter_q)
	);

	reg [3:0] current_state;
	reg [3:0] next_state;
	localparam STATE_WAIT = 0;
	localparam STATE_READ_ADDR = 1;
	localparam STATE_READ = 2;
	localparam STATE_WRITE = 3;
	localparam STATE_OVERFLOW = 4;
	localparam STATE_CRITICAL = 5;
	localparam STATE_NONCRITICAL = 6;
	localparam STATE_MISS = 7;
	
	wire [mem_width-1:0] cache_data;
	assign cache_data[reg_width-1:0] = r;
	assign cache_data[mem_critical_bit] = critical_in;
	assign cache_data[mem_width-1:mem_critical_rpt] = regions_report_in;
		
	//probe #(.width(4),.instance_id("CRDC")) cache_read_probe (.probe(read_counter_q));
	
	always @(current_state, write_counter_q, read_counter_q, sload, r, cache_q, mem_ready, critical_in, cache_comparison_off)
	begin
		next_state = current_state;
		read_counter_clear = 1'b0;
		read_counter_enable = 1'b0;
		cache_address = {depth_width{1'bX}};
		report_latch = 1'b0;
		hit = 1'b0;
		miss = 1'b0;
		overflow = 1'b0;
		critical_out = 1'b0;

		case (current_state)
		STATE_WAIT:
			begin
				if (sload)
					next_state = STATE_READ_ADDR;
				read_counter_clear = 1'b1;
			end
		STATE_READ_ADDR:
			begin
				cache_address = read_counter_q;
				if (sload)
					next_state = STATE_CRITICAL;
				else if (read_counter_q == write_counter_q)
					if (write_counter_q == depth)
						next_state = STATE_OVERFLOW;
					else
						next_state = STATE_MISS;
				else if ( cache_comparison_off === 1'b1 )
					next_state = STATE_MISS;
				else
					next_state = STATE_READ;
			end
		STATE_READ:
			begin
				read_counter_enable = 1'b1;
				if (sload)
					next_state = STATE_CRITICAL;
				else if (cache_q[reg_width-1:0] == r)
				begin
					if (cache_q[mem_critical_bit])
						begin
							report_latch = 1'b1;
							next_state = STATE_CRITICAL;
						end
					else
						next_state = STATE_NONCRITICAL;
				end
				else
					next_state = STATE_READ_ADDR;
			end
		STATE_MISS:
			begin
				cache_address = write_counter_q;
				if (sload)
					next_state = STATE_CRITICAL;
				else if (mem_ready)
					if (critical_in)
						begin
							report_latch = 1'b1;
							next_state = STATE_CRITICAL;
						end
					else
						next_state = STATE_NONCRITICAL;
				miss = 1'b1;
			end
		STATE_NONCRITICAL:
			begin
				if (sload)
					next_state = STATE_READ_ADDR;
				read_counter_clear = 1'b1;
				hit = 1'b1;
				critical_out = 1'b0;
			end
		STATE_CRITICAL:
			begin
				if (sload)
					next_state = STATE_READ_ADDR;
				read_counter_clear = 1'b1;
				hit = 1'b1;
				critical_out = 1'b1;
			end
		STATE_OVERFLOW:
			begin
				if (sload)
					next_state = STATE_READ_ADDR;
				read_counter_clear = 1'b1;
				overflow = 1'b1;
				critical_out = 1'b1;
			end
		endcase
	end
	
	always @(posedge clk or posedge reset)
	begin
		if (reset)
		begin
			r = {reg_width{1'b0}};
			current_state = STATE_WAIT;
		end
		else
		begin
			current_state = next_state;
			if (sload)
				r = data;
		end
	end
		
	always @(posedge clk or posedge reset)
	begin
		for (i=0; i < depth; i = i + 1)
		begin
			if (reset)
			begin
				cache[i] = {reg_width{1'b0}};
			end
			else
			begin
				if (cache_write && cache_address == i)
					cache[i] = cache_data;
			end
		end
	end
	assign cache_q = cache[read_counter_q];
	
	always @(posedge clk or posedge reset)
	begin
		if (reset)
		begin		
			regions_report_out = {report_width{1'b0}};
		end
		else if (report_latch)
		begin
			if (miss)
				regions_report_out = cache_data[mem_width-1:mem_critical_rpt];
			else
				regions_report_out = cache_q[mem_width-1:mem_critical_rpt];
		end		
		else if (sload || overflow)
			regions_report_out = {report_width{1'b0}};
		
	end

	//localparam probe_width = mem_width * depth + depth_width;
	genvar g;
	generate
		if (enable_virtual_jtag) begin: cache_enable_virtual_jtag
			//wire [probe_width-1:0] cache_probe_val;
			//reg [mem_width*depth-1:0] cache_combined;
			//assign cache_probe_val = {cache_combined, write_counter_q};
			for (g=0; g < depth; g = g + 1)
			begin: cache_probe_loop
				/*always @(cache[g])
				begin
					cache_combined[g*mem_width + mem_width-1 : g*mem_width] = cache[g];
				end
				*/probe #(.width(mem_width),.instance_id("CACH")) cache_probe (.probe(cache[g]));
			end
			//probe #(.width(depth_width),.instance_id("CNUM")) cache_num_probe (.probe(write_counter_q));
			//probe #(.width(probe_width),.instance_id("CACH")) cache_probe (.probe(cache_probe_val));
		end
	endgenerate
	
	function integer log2;
	input integer value;
	begin
		for (log2=0; value>0; log2=log2+1) 
				value = value >> 1;
	end
	endfunction

endmodule

/* mem_controller module
	This module translates the contents of the EMR register to an address
	offset into the critical map, and requests the data from the memory.
	It also handles verifying that the critical map matches the SOF, and
	detection of an multibit/uncorrectable upset. When sload is asserted,
	the emr input is sampled.   The EMR is decoded  into a frame and bit
	address,  which is converted to the  memory  address on the mem_addr
	output. Output mem_rd is asserted, and mem_data is sampled as soon as
	mem_wait is low. The external memory interface can hold mem_wait high
	if memory reads are longer than 1 clock cycle.  The  returned  memory 
	data is parity checked and the  critical/noncritical  state is driven 
	on the critical output.
	
	TODO:  address decoder
	TODO:  parity checker
*/
module mem_controller(
	clk,
	reset,
	
	emr,
	sload,

	mem_addr,
	mem_rd,
	mem_bytesel,
	
	mem_wait,
	mem_data,
	
	mem_ready,
	
	critical_regions,
	critical
	);
	
	parameter emr_reg_width = 7'd46;
	parameter mem_addr_width = 32;
	parameter mem_data_width = 32;
	parameter start_address = 32'h00000000;
	parameter reg_mask_width = 32'b1;

	input clk;
	input reset;
	input [emr_reg_width-1:0] emr;
	input sload;
	output [mem_addr_width-1:0] mem_addr;
	output [3:0] mem_bytesel;
	output mem_rd;
	input mem_wait;
	input [mem_data_width-1:0] mem_data;
	output critical;
	output [reg_mask_width-1:0] critical_regions;
	output mem_ready;
	
	reg critical1;
	reg mem_ready;
	reg mem_rd;
	
	reg critical2;
	reg mem_read_done;

	assign critical = critical1 || critical2;
	
	reg [4:0] current_state;
	reg [4:0] next_state;
	localparam STATE_RESET = 0;
	localparam STATE_HEADER = 1;
	localparam STATE_WAIT = 2;
	localparam STATE_FRAME_INFO = 3;
	localparam STATE_OFFSET_MAP = 4;
	localparam STATE_SENSITIVITY_DATA = 5;
	localparam STATE_NONCRITICAL= 6;
	localparam STATE_CRITICAL = 7;
	localparam STATE_HEADER_TAG = 8;
	localparam STATE_SENSITIVITY_TAG = 9;
	localparam STATE_REGIONS_MAP = 10;

	reg [2:0] mem_current_state;
	reg [2:0] mem_next_state;
	localparam MEM_STATE_ADDR = 0;
	localparam MEM_STATE_READ = 1;
	localparam MEM_STATE_WAIT = 2;
	localparam MEM_STATE_DONE = 3;
	localparam MEM_STATE_CRITICAL = 4;
	
	localparam mem_header_len = 5;
	localparam mem_header_addr = 32'h0000;

	/* 
		32-bit SMH header signature is following:
		 [23:0]  - SMH signature 24'h445341
		 [27:24] - reserved for SMH revisions not backward compatible with ASD IP
			:25 - SMH may contain non-binary sensitivity data 
		 [31:28] - reserved for SMH revisions backward compatible with ASD IP
	*/
	localparam signature_rev1 = 28'h0445341;
	localparam signature_rev2 = 28'h2445341;
	localparam mem_header_tag_len = 2;
	localparam regions_map_entry_size = 2;
	localparam frame_info_size = 4;
	localparam offset_map_entry_size = 2;
	
	reg [31:0] header [mem_header_len-1:0];
	wire [31:0] header_signature = header[0];
	wire [31:0] frame_info_loc = header[1];
	wire [31:0] offset_maps_loc = header[2];
	wire [31:0] sensitivity_data_loc = header[3];
	wire [15:0] offset_map_len = header[4][15:0];
	reg [31:0] header_tag [mem_header_tag_len-1:0];
	wire [31:0] regions_mask_loc = header_tag[1];
	
	wire [15:0] tag_size;
	// check bit 25 to ensure presence of tag information 
	wire read_tag = header_signature[25]; 
	assign tag_size = read_tag ? header_tag[0][15:0] : 16'd1;
	
	reg mem_read_32;
	reg mem_read_16;
	reg mem_read_8;
	wire mem_do_read = mem_read_32 || mem_read_16 || mem_read_8;
	
	reg [mem_addr_width-1:0] mem_addr_reg;
	reg [31:0] mem_data_reg;
	reg [7:0] mem_data_byte;
	reg [15:0] mem_data_word;
	reg [31:0] mem_data_dword;
	reg [3:0] mem_bytesel_reg;

	reg emr_latch;
	reg [emr_reg_width-1:0] emr_reg;
	localparam is_STRATIXIII_reg = emr_reg_width == 7'd46 ? 1 : 0;
	localparam err_type_width = is_STRATIXIII_reg ? 2 : 4;
	localparam err_bit_loc = 3;
	localparam err_byte_loc = is_STRATIXIII_reg ? 11 : 12;
	localparam err_frame_adr = is_STRATIXIII_reg ? 14 : 16;

	wire [err_bit_loc-1:0] emr_bit = emr_reg[err_type_width+err_bit_loc-1 : err_type_width];
	wire [err_byte_loc-1:0] emr_byte = emr_reg[err_type_width+err_bit_loc+err_byte_loc-1 : err_type_width+err_bit_loc];
	wire [err_frame_adr-1:0] emr_frame = emr_reg[err_type_width+err_bit_loc+err_byte_loc+err_frame_adr-1 : err_type_width+err_bit_loc+err_byte_loc];

	reg [31:0] frame_info_reg;
	reg [15:0] offset_map_reg;
	reg [15:0] regions_map_reg = 16'd1;
	reg [7:0] tag_data_reg;	
	
	assign critical_regions = critical1 ? regions_map_reg[reg_mask_width-1:0] : {reg_mask_width{1'b0}};
	
	wire [7:0] offset_map_num = frame_info_reg[7:0];
	wire [23:0] sensitivity_data_off = frame_info_reg[31:8];
	wire [31:0] offset_map_entry = offset_map_reg[15:0] * tag_size;   
	wire [7:0] sensitivity_tag = (tag_data_reg >> offset_map_entry[2:0]) & ((8'b1 << tag_size) - 8'd1);	
	
	reg header_latch;
	reg frame_info_latch;
	reg offset_map_latch;
	reg header_tag_latch;
	reg tag_data_latch;
	reg regions_map_latch;

	wire [mem_addr_width-1:0] mem_frame_info_addr = frame_info_loc + emr_frame * frame_info_size;
	wire [mem_addr_width-1:0] mem_offset_map_addr = offset_maps_loc + offset_map_num * offset_map_len + (emr_byte*8 + emr_bit) * offset_map_entry_size;
	wire [mem_addr_width-1:0] mem_sensitivity_data_addr = sensitivity_data_loc + sensitivity_data_off + offset_map_entry/8;
	wire [mem_addr_width-1:0] regions_mask_addr = regions_mask_loc + sensitivity_tag * regions_map_entry_size - regions_map_entry_size;

	wire read_counter_enable = mem_read_done;
	wire [2:0] read_counter;
	reg read_counter_reset;
	lpm_counter #(.lpm_width(3), .lpm_direction("UP")) counter(
		.clock(clk),
		.cnt_en(read_counter_enable),
		.aclr(read_counter_reset),
		.q(read_counter)
	);
	
	wire mem_data_latch = mem_rd && ~mem_wait;

	always @(mem_current_state, mem_do_read, mem_wait)
	begin
		mem_next_state <= mem_current_state;
		mem_rd <= 1'b0;
		mem_read_done <= 1'b0;
		critical2 <= 1'b0;
		case (mem_current_state)
		MEM_STATE_ADDR:
			begin
				if (mem_do_read)
					mem_next_state <= MEM_STATE_READ;
			end
		MEM_STATE_READ:
			begin
				mem_rd <= 1'b1;
				mem_next_state <= MEM_STATE_WAIT;
			end
		MEM_STATE_WAIT:
			begin
				mem_rd <= 1'b1;
				if (~mem_wait)
				begin
					mem_next_state <= MEM_STATE_DONE;
				end
			end
		MEM_STATE_DONE:
			begin
				mem_read_done <= 1'b1;
				mem_next_state <= MEM_STATE_ADDR;
			end
		MEM_STATE_CRITICAL:
			begin
				critical2 <= 1'b1;
			end
		default:
			begin
				mem_next_state <= MEM_STATE_CRITICAL;
			end
		endcase
	end

	always @(current_state, mem_wait, sload, mem_read_done, mem_data_byte, read_counter, header_signature, mem_frame_info_addr, mem_offset_map_addr, mem_sensitivity_data_addr, offset_map_entry, regions_mask_addr, emr, read_tag, sensitivity_tag)
	begin
		next_state <= current_state;

		// Memory reader control outputs
		mem_addr_reg <= {mem_addr_width{1'bx}};
		mem_read_32 <= 1'b0;
		mem_read_16 <= 1'b0;
		mem_read_8 <= 1'b0;

		// Module outputs
		critical1 <= 1'b0;
		mem_ready <= 1'b0;

		// Signals to latch data inputs into registers
		emr_latch <= 1'b0;
		header_latch <= 1'b0;
		frame_info_latch <= 1'b0;
		offset_map_latch <= 1'b0;
		header_tag_latch <= 1'b0;
		tag_data_latch <= 1'b0;
		regions_map_latch <= 1'b0;

		read_counter_reset <= 1'b0;

		case (current_state)
		STATE_RESET:
			begin
				read_counter_reset <= 1'b1;
				next_state <= STATE_HEADER;
			end
		STATE_HEADER:
			begin
				mem_addr_reg <= mem_header_addr + read_counter * 4;
				mem_read_32 <= 1'b1;
				header_latch <= 1'b1;
				if (mem_read_done && read_counter == 3'd4)
					if (read_tag)
					begin
							next_state <= STATE_HEADER_TAG;
					end	
					else		
						next_state <= STATE_WAIT;
			end
		STATE_HEADER_TAG:
			begin
				mem_addr_reg <= mem_header_addr + read_counter * 4;
				mem_read_32 <= 1'b1;
				header_tag_latch <= 1'b1;
				if (mem_read_done && read_counter == 3'd6)
					next_state <= STATE_WAIT;
			end
		STATE_WAIT:
			begin
				emr_latch <= 1'b1;
				if ((header_signature[27:0] != signature_rev2) && (header_signature != signature_rev1))
					next_state <= STATE_CRITICAL;
				else if (sload)
				begin
					if ( emr[1:0] != 2'b01 )
						next_state <= STATE_CRITICAL;
					else
						next_state <= STATE_FRAME_INFO;
				end
			end
		STATE_FRAME_INFO:
			begin
				mem_addr_reg <= mem_frame_info_addr;
				mem_read_32 <= 1'b1;
				frame_info_latch <= 1'b1;
				if (mem_read_done)
					next_state <= STATE_OFFSET_MAP;
			end
		STATE_OFFSET_MAP:
			begin
				mem_addr_reg <= mem_offset_map_addr;
				mem_read_16 <= 1'b1;
				offset_map_latch <= 1'b1;
				if (mem_read_done)
					next_state <= STATE_SENSITIVITY_DATA;
			end
		STATE_SENSITIVITY_DATA:
			begin
				mem_addr_reg <= mem_sensitivity_data_addr;
				mem_read_8 <= 1'b1;
				tag_data_latch <= 1'b1;
				if (mem_read_done)
					next_state <= STATE_SENSITIVITY_TAG;
			end
		STATE_SENSITIVITY_TAG:
			begin
				if (sensitivity_tag)
					if (read_tag)
						next_state <= STATE_REGIONS_MAP;
					else
						next_state <= STATE_CRITICAL;
				else
					next_state <= STATE_NONCRITICAL;
			end
		STATE_NONCRITICAL:
			begin
				mem_ready <= 1'b1;
				next_state <= STATE_WAIT;
			end
		STATE_CRITICAL:
			begin
				mem_ready <= 1'b1;
				critical1 <= 1'b1;
				next_state <= STATE_WAIT;
			end
		STATE_REGIONS_MAP:
			begin
				mem_addr_reg <= regions_mask_addr;
				mem_read_16 <= 1'b1;
				regions_map_latch <= 1'b1;
				if (mem_read_done)
					next_state <= STATE_CRITICAL;
			end
		endcase
	end
	
	always @(posedge clk or posedge reset)
	begin
		if (reset)
		begin
			mem_current_state = MEM_STATE_ADDR;
			current_state = STATE_RESET;
			mem_data_reg = 32'hXXXXXXXX;
		end
		else
		begin
			current_state = next_state;
			mem_current_state = mem_next_state;
			if (mem_data_latch)
				mem_data_reg = mem_data;
			if (frame_info_latch)
				frame_info_reg = mem_data_dword;
			if (offset_map_latch)
				offset_map_reg = mem_data_word;
			if (tag_data_latch)
				tag_data_reg = mem_data_byte;
			if (regions_map_latch)
				regions_map_reg = mem_data_word;
			if (header_tag_latch)
				header_tag[read_counter-mem_header_len] = mem_data_dword;
			if (emr_latch)
				emr_reg = emr;
			if (header_latch)
				header[read_counter] = mem_data_dword;
		end
	end
	
	assign mem_addr = start_address + (mem_addr_reg & ~(3));
	assign mem_bytesel = mem_bytesel_reg;
	always @(mem_read_32, mem_read_16, mem_read_8, mem_addr_reg)
	begin
		if (mem_read_8)
		begin
			if (mem_addr_reg % 4 == 0)
			begin
				mem_bytesel_reg <= 4'b0001;
			end
			else if (mem_addr_reg % 4 == 1)
			begin
				mem_bytesel_reg <= 4'b0010;
			end
			else if (mem_addr_reg % 4 == 2)
			begin
				mem_bytesel_reg <= 4'b0100;
			end
			else // (mem_addr_reg % 4 == 3)
			begin
				mem_bytesel_reg <= 4'b1000;
			end
		end
		else if (mem_read_16)
		begin
			if ((mem_addr_reg & 32'h2) == 0)
			begin
				mem_bytesel_reg <= 4'b0011;
			end
			else
			begin
				mem_bytesel_reg <= 4'b1100;
			end
		end
		else // (mem_read_32)
		begin
			mem_bytesel_reg <= 4'b1111;
		end
	end
	
	always @(mem_addr_reg, mem_data_reg)
	begin
		if (mem_addr_reg % 4 == 0)
			mem_data_byte <= mem_data_reg[7:0];
		else if (mem_addr_reg % 4 == 1)
			mem_data_byte <= mem_data_reg[15:8];
		else if (mem_addr_reg % 4 == 2)
			mem_data_byte <= mem_data_reg[23:16];
		else // (mem_addr_reg % 4 == 3)
			mem_data_byte <= mem_data_reg[31:24];

		if ((mem_addr_reg & 32'h2) == 0)
			mem_data_word <= mem_data_reg[15:0];
		else
			mem_data_word <= mem_data_reg[31:16];

		mem_data_dword <= mem_data_reg;
	end
endmodule

