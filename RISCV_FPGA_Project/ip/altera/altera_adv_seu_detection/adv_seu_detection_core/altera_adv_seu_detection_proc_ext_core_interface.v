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

/* alt_adv_seu_detection_proc_ext module
	This  top level module supports the Advanced SEU Detection feature
	configuration when SEU lookup against sensitivity map is performed
	by an external unit (such as microprocessor).  It instantiates and
	connects the emr_unloader, and asd_emr_processor modules
	Note,  that some of the low level modules,  used  by both internal
	and external processor are defined in the alt_adv_seu_detection.v
*/
module altera_adv_seu_detection_proc_ext
(
	clk,
	nreset,

	emr_cache_ack,
	emr_cache_int,
	
	emr_data,
	
	critical_error,
	crcerror_core,	

	cache_fill_level,
	cache_full,

	clk_cp,
	shiftnld_cp,
	regout_cp,
	crcerror_cp,
	cache_comparison_off
);

	parameter intended_device_family = "Stratix III";
	parameter error_clock_divisor = 2;
	parameter error_delay_cycles = 0;
	parameter clock_frequency = 50;
	parameter cache_depth = 8;
	parameter enable_virtual_jtag = 0;
	parameter emr_reg_width = 7'd67;
	parameter mem_addr_width = 32;
	parameter start_address = 0;
	
	localparam emr_data_width = emr_reg_width == 7'd67 ? 7'd35 : 7'd30;
	
	input clk;
	input nreset;

	output critical_error;
	output [emr_data_width-1:0] emr_data;

	input emr_cache_ack;
	output emr_cache_int;
	
	input cache_comparison_off;
	output [3:0] cache_fill_level;
	output cache_full;
	
	output wire clk_cp;
	output wire shiftnld_cp;
	input wire regout_cp;
	input wire crcerror_cp;

	output wire crcerror_core;			

	wire cpu_ack;
	wire [emr_data_width-1:0] emr_data;
	
	wire emr_cache_int;
	
	wire reset;
	
	wire emr_sload;
	wire [emr_reg_width-1:0] emr;

	wire critical_error;
	wire critical_error1;
	wire critical_error2;
	
	wire cpu_int;
	wire cpu_int1;
	wire cpu_int2;

	wire [3:0] cache_fill_level;
	wire [3:0] cache_fill_level1;
	wire [3:0] cache_fill_level2;
	
	wire cache_full;
	wire cache_full1;
	wire cache_full2;
	
	wire [emr_reg_width-1:0] cache_emr;
	wire [emr_reg_width-1:0] cache_emr1;
	wire [emr_reg_width-1:0] cache_emr2;
	
	assign emr_cache_int = cpu_int;
	assign cpu_ack = emr_cache_ack;
	assign reset = ~nreset;
	assign emr_data = cache_emr[emr_data_width-1:0];
	
	assign critical_error = critical_error1 || critical_error2;
	assign cache_full = cache_full1 || cache_full2;
	assign cache_fill_level = cache_fill_level1;
	assign cache_emr = cache_emr1;
	assign cpu_int = cpu_int1 || cpu_int2;

	emr_unloader emr_unloader(
		.clk(clk),
		.emr(emr),
		.reset(reset),
		.ready(emr_sload),
		.crcerror_core(crcerror_core),
		.clk_cp(clk_cp),
		.shiftnld_cp(shiftnld_cp),
		.regout_cp(regout_cp),
		.crcerror_cp(crcerror_cp)
	);
	defparam 
		emr_unloader.enable_virtual_jtag = enable_virtual_jtag,
		emr_unloader.emr_reg_width = emr_reg_width;	

	asd_emr_processor asdsp1(
		.clk(clk),
		.reset(reset),
		.emr(emr),
		.emr_sload(emr_sload),
		.cache_emr(cache_emr1),
		.cpu_int(cpu_int1),
		.cpu_ack(cpu_ack),
		.critical_error(critical_error1),
		.cache_full(cache_full1),
		.cache_fill_level(cache_fill_level1),
		.cache_comparison_off(cache_comparison_off)
	);
	defparam 
		asdsp1.error_clock_divisor = error_clock_divisor,
		asdsp1.error_delay_cycles = error_delay_cycles,
		asdsp1.clock_frequency = clock_frequency,
		asdsp1.cache_depth = cache_depth,
		asdsp1.enable_virtual_jtag = enable_virtual_jtag,
		asdsp1.emr_reg_width = emr_reg_width;	
	
	asd_emr_processor asdsp2(
		.clk(clk),
		.reset(reset),
		.emr(emr),
		.emr_sload(emr_sload),
		.cache_emr(cache_emr2),
		.cpu_int(cpu_int2),
		.cpu_ack(cpu_ack),
		.critical_error(critical_error2),
		.cache_full(cache_full2),
		.cache_fill_level(cache_fill_level2),
		.cache_comparison_off(cache_comparison_off)
	);
	defparam 
		asdsp2.error_clock_divisor = error_clock_divisor,
		asdsp2.error_delay_cycles = error_delay_cycles,
		asdsp2.clock_frequency = clock_frequency,
		asdsp2.cache_depth = cache_depth,
		asdsp2.enable_virtual_jtag = 0,
		asdsp2.emr_reg_width = emr_reg_width;	
	
endmodule 

/* asd_emr_processor module
	This module instantiates and connects cache, and cpu_controller
	modules.  It  asserts  the  critical_error  output  when
	multibit/uncorrectable error is detected  by  cpu_controller, or
	cache is overflow, or device EMR was overwritten before previous
	value was cached.	
*/
module asd_emr_processor
(
	clk,
	reset,

	emr,
	emr_sload,

	cache_emr,
	cpu_int,
	cpu_ack,

	critical_error,
	
	cache_full,
	cache_fill_level,
	
	cache_comparison_off
);

	parameter emr_reg_width = 7'd46;
	parameter error_clock_divisor = 2;
	parameter error_delay_cycles = 0;
	parameter clock_frequency = 50;
	parameter cache_depth = 8;
	parameter enable_virtual_jtag = 1;
	
	
	input clk;
	input reset;
	
	output cpu_int;
	input cpu_ack;
	
	output critical_error;

	input [emr_reg_width-1:0] emr;
	input emr_sload;
	
	input cache_comparison_off;
	
	output cache_full;
	output [3:0] cache_fill_level;
	
	output [emr_reg_width-1:0] cache_emr;
		
	wire controller_ready;
	wire critical_seu;			
	wire [emr_reg_width-1:0] cache_emr;
	wire cache_miss;
	wire cache_hit;
	wire cache_sload;
	wire cache_full;
	wire cache_critical;
	wire controller_sload;
	wire [3:0] cache_fill_level;
		
	oneshot emr_oneshot(.in(emr_sload), .out(cache_sload), .clk(clk), .reset(reset));
	cache cache (
		.clk(clk),
		.reset(reset),
		.data(emr),
		.q(cache_emr),
		.sload(cache_sload),
		.miss(cache_miss),
		.hit(cache_hit),								
		.cache_full(cache_full),
		.cpu_ready(controller_ready),
		.critical_in(critical_seu),						// not used by this asd configuration
		.critical_out(cache_critical),
		.cache_fill_level(cache_fill_level),
		.cache_comparison_off(cache_comparison_off)
	);
	defparam 
		cache.reg_width = emr_reg_width,
		cache.depth = cache_depth,
		cache.enable_virtual_jtag = enable_virtual_jtag;

	assign controller_sload = (cache_fill_level == 4'h0) ? 1'b0 : 1'b1;
	
	cpu_controller cpu_controller (
		.clk(clk),
		.reset(reset),
		
		.emr(cache_emr),
		.sload(controller_sload),
		
		.cpu_int(cpu_int),
		.cpu_ack(cpu_ack),
		
		.cpu_ready(controller_ready),
		.critical_seu(critical_seu)
	);
	defparam 
		cpu_controller.emr_reg_width = emr_reg_width;
	
	assign critical_error = cache_critical || critical_seu;
endmodule


/* emr_unloader module
	This module is used to interface to the EMR atom, shifting the serial data
	out of the EMR user register.  When the shifting is complete, the data is
	available on the emr output, and the ready output is asserted.  The ready
	output will stay asserted until another error is reporrted by the EDC
	block.  If a second error is reported by the EDC before the first error
	has been completely unloaded from the EMR, the critical output will be
	asserted. 
	*/
module emr_unloader (
	clk,
	emr,
	reset,
	ready,

	clk_cp,
	shiftnld_cp,
	regout_cp,
	crcerror_cp,
	crcerror_core
);
	parameter emr_reg_width = 7'd46;
	parameter enable_virtual_jtag = 1;

	input clk;
	output [emr_reg_width-1:0] emr;
	output ready;
	input reset;
	output crcerror_core;

	output wire clk_cp;
	output wire shiftnld_cp;
	input wire regout_cp;
	input wire crcerror_cp;
	
	reg shiftnld;
	wire regout;
	wire crcerror_wire /* synthesis keep */;
	wire inject_error;
	wire is_crcerror = inject_error || crcerror_wire;
	wire crcerror_pulse;
	
	oneshot crcerror_oneshot(.in(is_crcerror), .out(crcerror_pulse), .clk(clk), .reset(reset));
		
	reg emr_clk;
	assign clk_cp = emr_clk;
	assign shiftnld_cp = shiftnld;
	assign regout = regout_cp;
	assign crcerror_wire = crcerror_cp;

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
	This module caches EMR register state and prevents reporting new SEU error 
	when a previous error is reported again.    The data input is sampled when
	sload is asserted. The  state  machine then checks each cache slot against 
	the  reported  error.  If  a  match  is found,  the hit output is asserted,
	otherwise, the miss output is asserted and cache module write the EMR data 
	to the cache and increase the cache_fill_level value on the output.
	This module provides the last unread by the CPU chached EMR value on the q
	output.  The  cpu_controller  module should assert cpu_ready input to make
	next chached EMR value available on the q output.
*/
module cache (
	clk,
	reset,

	data,
	q,
	sload,

	hit,
	miss,
	cache_full,
	critical_out,						// not used by this asd configuration
	critical_in,
	cpu_ready,

	cache_fill_level,
	cache_comparison_off
);
	parameter depth = 8;
	parameter enable_virtual_jtag = 1;
	parameter reg_width = 7'd46;
	
	localparam depth_width = log2(depth-1);
	
	localparam mem_width = reg_width;

	input clk;
	input reset;
	input [reg_width-1:0] data;
	input sload;
	input critical_in;
	input cpu_ready;
	input cache_comparison_off;
	output [reg_width-1:0] q;
	output critical_out;
	output hit;
	output miss;
	output cache_full;
	output [3:0] cache_fill_level;

	integer i;

	reg hit;
	reg miss;
	reg overflow;
	reg cache_full;
	reg critical_out;
	
	reg [mem_width-1:0] cache[depth-1:0];
	
	reg [reg_width-1:0] r /* synthesis preserve */;
	
	wire [3:0] cache_fill_level;
	reg [depth_width-1:0] cache_address;
	wire [mem_width-1:0] cache_q;

	wire cache_write;
	wire write_counter_enable;
	
	// Write to cache right on miss signal
	assign cache_write = miss;
	assign write_counter_enable = miss;

	// Cache write counter
	wire [depth_width-1:0] write_counter_q;
	reg write_counter_clear;
	lpm_counter #(.lpm_width(depth_width), .lpm_direction("UP")) write_counter (
		.clock(clk),
		.cnt_en(write_counter_enable),
		.aclr(reset),
		.sclr(write_counter_clear),
		.q(write_counter_q)
	);

	// The CPU interface read counter
	wire cpu_read_counter_enable;
	wire [depth_width-1:0] cpu_read_counter_q;

	oneshot cpuread_oneshot(.in(cpu_ready), .out(cpu_read_counter_enable), .clk(clk), .reset(reset));
	reg cpu_read_counter_clear;
	lpm_counter #(.lpm_width(depth_width), .lpm_direction("UP")) cpu_read_counter (
		.clock(clk),
		.cnt_en(cpu_read_counter_enable),
		.aclr(reset),
		.sclr(cpu_read_counter_clear),
		.q(cpu_read_counter_q)
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
	localparam STATE_OVERFLOW = 4;			// not used by this asd configuration
	localparam STATE_CRITICAL = 5;		
	localparam STATE_NONCRITICAL = 6;		// not used by this asd configuration
	localparam STATE_MISS = 7;
	localparam STATE_HIT = 8;
	
	wire [mem_width-1:0] cache_data;

	// Cached EMR out to the CPU interface
	assign q = cache[cpu_read_counter_q];
	assign cache_data[reg_width-1:0] = r;
		
	//probe #(.width(4),.instance_id("CRDC")) cache_read_probe (.probe(read_counter_q));
	assign cache_fill_level =  (cache_full) ?
										(depth[depth_width-1:0] - (cpu_read_counter_q - write_counter_q)):
										(write_counter_q - cpu_read_counter_q);						
	
	always @(current_state, write_counter_q, read_counter_q, sload, r, cache_q, cache_comparison_off, cache_fill_level, cache_full)
	begin
		next_state = current_state;
		read_counter_clear = 1'b0;
		read_counter_enable = 1'b0;
		cache_address = {depth_width{1'bX}};
		hit = 1'b0;
		miss = 1'b0;
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
				
				else if (cache_fill_level == depth)
					next_state = STATE_CRITICAL;				// STATE_OVERFLOW
				
				else if (cache_comparison_off === 1'b1)
					next_state = STATE_MISS;
				
				else if (cache_full)
					next_state = read_counter_q == depth ? STATE_MISS : STATE_READ;

				else if (read_counter_q == write_counter_q)
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
					next_state = STATE_HIT;
				
				else
					next_state = STATE_READ_ADDR;
			end
		STATE_HIT:
			begin
				if (sload)
					next_state = STATE_READ_ADDR;
				
				read_counter_clear = 1'b1;
				hit = 1'b1;

				next_state = STATE_WAIT;
			end
		STATE_MISS:
			begin
				cache_address = write_counter_q;
				if (sload)
					next_state = STATE_CRITICAL;

				read_counter_clear = 1'b1;
				miss = 1'b1;

				next_state = STATE_WAIT;
			end
		STATE_CRITICAL:								 // STATE_OVERFLOW
			begin
				if (sload)
					next_state = STATE_READ_ADDR;
				read_counter_clear = 1'b1;
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
	
	always @(posedge reset or posedge write_counter_enable)
	begin
		if (reset)
			write_counter_clear <= 1'b0;
		else if (write_counter_q == depth - 1)	
			write_counter_clear <= 1'b1;
		else 	
			write_counter_clear <= 1'b0;
	end

	always @(posedge reset or posedge cpu_read_counter_enable)
	begin
		if (reset)
			cpu_read_counter_clear <= 1'b0;
		else if (cpu_read_counter_q == depth - 1)	
			cpu_read_counter_clear <= 1'b1;
		else 	
			cpu_read_counter_clear <= 1'b0;
	end

	always @(posedge clk or posedge reset)
	begin
		if (reset)
			cache_full = 1'b0;
		else if (cache_write && (cache_address == depth-1))
			cache_full = 1'b1;
		else if (cpu_read_counter_enable && (cpu_read_counter_q == depth -1))
			cache_full = 1'b0;
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

	//localparam probe_width = mem_width * depth + depth_width;
	genvar g;
	generate
		if (enable_virtual_jtag) begin: cache_enable_virtual_jtag
			//wire [probe_width-1:0] cache_probe_val;
			//reg [mem_width*depth-1:0] cache_combined;
			//assign cache_probe_val = {cache_combined, write_counter_q};
			for (g=0; g < depth; g = g + 1)
			begin: cache_probe_loop
				//always @(cache[g])
				//begin
					//cache_combined[g*mem_width + mem_width-1 : g*mem_width] = cache[g];
				//end
				probe #(.width(mem_width),.instance_id("CACH")) cache_probe (.probe(cache[g]));
			end
			probe #(.width(depth_width),.instance_id("CNUM")) cache_num_probe (.probe(write_counter_q));
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

/*  cpu_controller module
	This module generates an interrupt on the cpu interface when there is an EMR entry
	available.  The chached EMR information is available along with the interrupt. The
	module  waits for an ack from the cpu before ussuing cpu_ready signal to the cache
	module and issuing the next cpu interrupt.  This module also decodes the EMR error
	type to rase critical_seu output when there is multi bit or uncorrectable upset.
*/
module cpu_controller(
	clk,
	reset,
	
	emr,
	sload,

	cpu_int,	
	cpu_ack,
	
	cpu_ready,
	
	critical_seu
	);
	
	parameter emr_reg_width = 7'd67;

	input clk;
	input reset;
	input [emr_reg_width-1:0] emr;
	input sload;
	output cpu_int;
	input cpu_ack;
	output critical_seu;
	output cpu_ready;
	
	reg cpu_ready;
	reg cpu_int;
	reg critical_seu;

	reg [2:0] cpu_current_state;
	reg [2:0] cpu_next_state;
	localparam CPU_STATE_START = 0;
	localparam CPU_STATE_READ = 1;
	localparam CPU_STATE_WAIT = 2;
	localparam CPU_STATE_DONE = 3;
	
	localparam error_bf_width = ( emr_reg_width == 7'd67 ) ? 4 : 2;
	

	always @(cpu_current_state, sload, emr, cpu_ack)
	begin
		cpu_next_state <= cpu_current_state;
		cpu_int <= 1'b0;
		cpu_ready <= 1'b0;
		critical_seu <= 1'b0;
		case (cpu_current_state)
		CPU_STATE_START:
			begin
				if (sload)
					cpu_next_state <= CPU_STATE_READ;
			end
		CPU_STATE_READ:
			begin
				cpu_int <= 1'b1;
				cpu_next_state <= CPU_STATE_WAIT;
			end
		CPU_STATE_WAIT:
			begin
				cpu_int <= 1'b1;
				if (emr[error_bf_width-1:0] != 2'b01)
					critical_seu <= 1'b1;
				else
					critical_seu <= 1'b0;
				if (cpu_ack)
				begin
					cpu_next_state <= CPU_STATE_DONE;
				end
			end
		CPU_STATE_DONE:
			begin
				cpu_ready <= 1'b1;
				if (~cpu_ack)
					cpu_next_state <= CPU_STATE_START;
				else
					cpu_next_state <= CPU_STATE_DONE;
			end
		default:
			begin
				cpu_next_state <= CPU_STATE_START;
			end
		endcase
	end

	always @(posedge clk or posedge reset)
	begin
		if (reset)		
			cpu_current_state <= CPU_STATE_START;
		else		
			cpu_current_state <= cpu_next_state;					
	end

endmodule
