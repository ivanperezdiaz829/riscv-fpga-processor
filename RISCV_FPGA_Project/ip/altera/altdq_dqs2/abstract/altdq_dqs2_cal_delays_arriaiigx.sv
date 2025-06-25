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


module altdq_dqs2_cal_delays #(

        parameter CLOCK_FREQ = "",
        parameter PIN_WIDTH = 1,
        parameter EXTRA_OUTPUT_WIDTH = 1,
	parameter DEGREES_PER_PHASE_TAP = "",
	parameter DELAY_WIDTH = 32,
	parameter DLL_USE_2X_CLK = 0	
		    
) (
	input wire config_data_in,
	input wire config_update,
	input wire config_dqs_ena,
	input wire [PIN_WIDTH-1:0] config_io_ena,
	input wire [EXTRA_OUTPUT_WIDTH-1:0] config_extra_io_ena,
	input wire config_dqs_io_ena,
	input wire config_clock_in,

	output wire [DELAY_WIDTH-1:0] opa_clock_delay,
	output wire [DELAY_WIDTH-1:0] dqs_in_busout_delay,
	output wire [DELAY_WIDTH-1:0] dqs_in_enable_on_delay,
	output wire [DELAY_WIDTH-1:0] dqs_in_enable_off_delay,
	output wire [DELAY_WIDTH-1:0] dqs_out_ptap_delay,
	output wire [DELAY_WIDTH-1:0] dqs_out_dtap_delay,
	output wire [DELAY_WIDTH-1:0] dq_out_ptap_delay,
	output wire [(PIN_WIDTH*DELAY_WIDTH)-1:0] dq_out_dtap_delay,
	output wire [(PIN_WIDTH*DELAY_WIDTH)-1:0] dq_in_dtap_delay,
	output wire [(PIN_WIDTH*DELAY_WIDTH)-1:0] extra_out_dtap_delay

);


function integer phase_to_ps;
	input integer clk_rate;
	input integer deg;
	phase_to_ps = deg * (1000000) / clk_rate / (360);
endfunction

function integer phasetap_to_ps;
	input integer clk_rate;
	input integer tap;
	begin
		phasetap_to_ps = phase_to_ps(clk_rate, tap * DEGREES_PER_PHASE_TAP);
	end
endfunction

assign opa_clock_delay = 0;
assign dqs_in_busout_delay = phase_to_ps(CLOCK_FREQ, 90);
assign dqs_in_enable_on_delay = phase_to_ps(CLOCK_FREQ, 630);
assign dqs_in_enable_off_delay = phase_to_ps(CLOCK_FREQ, 630 - 180);
assign dqs_out_ptap_delay = phase_to_ps(CLOCK_FREQ, 420);
assign dqs_out_dtap_delay = 0;
assign dq_out_ptap_delay = phase_to_ps(CLOCK_FREQ, 360);

assign dq_out_dtap_delay = '0;
assign dq_in_dtap_delay = '0;
assign extra_out_dtap_delay = '0;

endmodule


