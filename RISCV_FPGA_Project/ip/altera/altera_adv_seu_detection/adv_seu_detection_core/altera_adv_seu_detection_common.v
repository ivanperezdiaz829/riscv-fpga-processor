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

/*
 Low level modules used by both alt_adv_seu_detection_proc_int and alt_adv_seu_detection_proc_ext modules
*/
module oneshot (
	clk,
	reset,
	in,
	out
	);

	input clk;
	input reset;
	input in;
	output out;

	reg last /* synthesis preserve */;
	always @(posedge clk or posedge reset)
	begin
		if (reset)
			last = 1'b0;
		else
			last = in;
	end
	assign out = ~last && in;
	
endmodule

module source_probe (
	probe,
	source
	);

	parameter width = 1;
	input [width-1:0] probe;
	output [width-1:0] source;
	
	parameter instance_id = "NONE";

	altsource_probe altsource_probe_component (
							.probe (probe),
							.source (source)
							);
	defparam
	altsource_probe_component.enable_metastability = "NO",
	altsource_probe_component.instance_id = instance_id,
	altsource_probe_component.probe_width = width,
	altsource_probe_component.sld_auto_instance_index = "YES",
	altsource_probe_component.sld_instance_index = 0,
	altsource_probe_component.source_initial_value = "0",
	altsource_probe_component.source_width = width;
endmodule

module probe (
	probe
	);

	parameter width = 1;
	input [width-1:0] probe;
	
	parameter instance_id = "NONE";

	altsource_probe altsource_probe_component (
							.probe (probe)
							);
	defparam
	altsource_probe_component.enable_metastability = "NO",
	altsource_probe_component.instance_id = instance_id,
	altsource_probe_component.probe_width = width,
	altsource_probe_component.sld_auto_instance_index = "YES",
	altsource_probe_component.sld_instance_index = 0,
	altsource_probe_component.source_initial_value = "0",
	altsource_probe_component.source_width = 0;
endmodule

module crcblock_atom (
	inclk,
	crcerror,
	regout,
	shiftnld	
	);
	
	parameter intended_device_family = "Stratix III";
	parameter error_clock_divisor = 2;
	parameter error_delay_cycles = 0;

	input wire inclk;
	input wire shiftnld;
	
	output wire crcerror;
	output wire regout;

	generate
		if  ( (intended_device_family == "Stratix III") ||
			  (intended_device_family == "Arria II GZ") ||
			  (intended_device_family == "Arria II GX") ||
			  (intended_device_family == "Stratix IV") ) begin: generate_crcblock_atom
			stratixiii_crcblock emr_atom (
					.clk(inclk),
					.shiftnld(shiftnld),
					.regout(regout),
					.crcerror(crcerror)
				);
			defparam
				emr_atom.error_delay = error_delay_cycles,
				emr_atom.oscillator_divider = error_clock_divisor;
		end
		else if ( (intended_device_family == "Arria V") ||
				  (intended_device_family == "Cyclone V") ) begin: generate_crcblock_atom
			arriav_crcblock emr_atom (
					.clk(inclk),
					.shiftnld(shiftnld),
					.regout(regout),
					.crcerror(crcerror)
				);
			defparam
				emr_atom.error_delay = error_delay_cycles,
				emr_atom.oscillator_divider = error_clock_divisor;
		end
		else begin: generate_crcblock_atom
			stratixv_crcblock emr_atom (
					.clk(inclk),
					.shiftnld(shiftnld),
					.regout(regout),
					.crcerror(crcerror)
				);
			defparam
				emr_atom.error_delay = error_delay_cycles,
				emr_atom.oscillator_divider = error_clock_divisor;
		end
	endgenerate			

endmodule
