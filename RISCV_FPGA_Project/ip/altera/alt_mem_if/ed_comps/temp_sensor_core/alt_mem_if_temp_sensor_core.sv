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


module alt_mem_if_temp_sensor_core (pll_clk, global_reset_n, pll_locked, sense_value);

parameter SENSE_WORD_WIDTH = 8;
parameter DEVICE_FAMILY = "STRATIXV";

input pll_locked;
input pll_clk;
input global_reset_n;
output [SENSE_WORD_WIDTH-1:0] sense_value;


wire clock_enable;
reg clear_reading;
wire reading_complete;

reg [SENSE_WORD_WIDTH-1:0] reading_value_r;
wire [SENSE_WORD_WIDTH-1:0] reading_value;
wire [SENSE_WORD_WIDTH-1:0] probe_input;

wire sense_reset_n;
wire reset_request_n;

assign sense_value = reading_value_r;

assign clock_enable = 1'b1;


assign reset_request_n = (global_reset_n && pll_locked);

reset_sync ureset(
	.reset_n(reset_request_n),
	.clk(pll_clk),
	.reset_n_sync(sense_reset_n)
);

generate
	if (DEVICE_FAMILY == "STRATIXV") begin
		stratixv_tsdblock   sd1
		( 
		.ce(clock_enable),
		.clk(pll_clk),
		.clr(clear_reading),
		.offsetout(),
		.tsdcaldone(reading_complete),
		.tsdcalo(reading_value),
		.tsdcompout(),
		.compouttest(1'b0),
		.fdbkctrlfromcore(1'b0),
		.testin({8{1'b0}})
		);
		defparam
			sd1.clock_divider_enable = "true",
			sd1.clock_divider_value = 80,
			sd1.sim_tsdcalo = 0,
			sd1.lpm_type = "stratixv_tsdblock";
	end

	else if (DEVICE_FAMILY == "ARRIAVGZ") begin
		arriavgz_tsdblock   sd1
		( 
		.ce(clock_enable),
		.clk(pll_clk),
		.clr(clear_reading),
		.offsetout(),
		.tsdcaldone(reading_complete),
		.tsdcalo(reading_value),
		.tsdcompout(),
		.compouttest(1'b0),
		.fdbkctrlfromcore(1'b0),
		.testin({8{1'b0}})
		);
		defparam
			sd1.clock_divider_enable = "true",
			sd1.clock_divider_value = 80,
			sd1.sim_tsdcalo = 0,
			sd1.lpm_type = "arriavgz_tsdblock";
	end
	
	else if (DEVICE_FAMILY == "STRATIXIV") begin
		stratixiv_tsdblock   sd1
		( 
		.ce(clock_enable),
		.clk(pll_clk),
		.clr(clear_reading),
		.offsetout(),
		.tsdcaldone(reading_complete),
		.tsdcalo(reading_value),
		.tsdcompout(),
		.compouttest(1'b0),
		.fdbkctrlfromcore(1'b0),
		.offset({6{1'b0}}),
		.testin({8{1'b0}})
		);
		defparam
			sd1.clock_divider_enable = "on",
			sd1.clock_divider_value = 80,
			sd1.sim_tsdcalo = 0,
			sd1.lpm_type = "stratixiv_tsdblock";
	end

	else if (DEVICE_FAMILY == "ARRIAV") begin
		arriav_tsdblock   sd1
		( 
		.ce(clock_enable),
		.clk(pll_clk),
		.clr(clear_reading),
		.offsetout(),
		.tsdcaldone(reading_complete),
		.tsdcalo(reading_value),
		.tsdcompout(),
		.compouttest(1'b0),
		.fdbkctrlfromcore(1'b0),
		.testin({8{1'b0}})
		);
		defparam
			sd1.clock_divider_enable = "true",
			sd1.clock_divider_value = 80,
			sd1.sim_tsdcalo = 0,
			sd1.lpm_type = "arriav_tsdblock";
	end
endgenerate


always@(posedge pll_clk or negedge sense_reset_n)
begin
	if (~sense_reset_n) begin
		clear_reading <= 1'b1;
		reading_value_r <= 0;
	end
	else begin
		if (reading_complete == 1'b1)
				reading_value_r <= reading_value;
		else
				reading_value_r <= reading_value_r;

		clear_reading <= reading_complete;
	end
end



altsource_probe	iss_probe_inst (
				.probe (probe_input),
				.source ()
				,
				.clrn (),
				.ena (),
				.ir_in (),
				.ir_out (),
				.jtag_state_cdr (),
				.jtag_state_cir (),
				.jtag_state_e1dr (),
				.jtag_state_sdr (),
				.jtag_state_tlr (),
				.jtag_state_udr (),
				.jtag_state_uir (),
				.raw_tck (),
				.source_clk (),
				.source_ena (),
				.tdi (),
				.tdo (),
				.usr1 ()
				);
	defparam
		iss_probe_inst.enable_metastability = "NO",
		iss_probe_inst.instance_id = "PROB",
		iss_probe_inst.probe_width = SENSE_WORD_WIDTH,
		iss_probe_inst.sld_auto_instance_index = "YES",
		iss_probe_inst.sld_instance_index = 0,
		iss_probe_inst.source_initial_value = "0",
		iss_probe_inst.source_width = 0;
		

endmodule
