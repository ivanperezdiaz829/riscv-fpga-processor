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


// *********************************************************************
//
//
// dp_analog_mappings
// 
// Description
// 
// This module maps the 2-bit VOD and pre-emphasis settings from the
// DisplayPort core to the family specific settings.
//
// *********************************************************************

`timescale 1 ps / 1 ps
`default_nettype none

module dp_analog_mappings #(
	parameter DEVICE_FAMILY = "Stratix V"
)(
	input  wire [1:0]   in_vod,  
	input  wire [1:0]   in_emp, 
	output reg  [5:0]   out_vod, 
	output reg  [4:0]   out_emp
);

	// Settings are based on family
	generate begin
		case (DEVICE_FAMILY)
			"Stratix V":
			begin : sv
				always @(*)
					case (in_vod)
						2'b00 :
						begin
							out_vod = 6'd20;			//400mv
							case(in_emp) 
								2'b00 : out_emp = 5'h0; // (0db)
								2'b01 : out_emp = 5'h6; // (3.5db)
								2'b10 : out_emp = 5'h9; // (6.1db)
								2'b11 : out_emp = 5'hb; // (9.5db)
							endcase
						end
						2'b01 :
						begin
							out_vod = 6'd30;			//600mv
							case(in_emp) 
								2'b00 : out_emp = 5'h0; // (0db)
								2'b01 : out_emp = 5'h9; // (3.5db)
								2'b10 : out_emp = 5'he; // (6.1db)
								2'b11 : out_emp = 5'he; // Unused
							endcase
						end
						2'b10 :
						begin
							out_vod = 6'd40;			//800mv
							case(in_emp) 
								2'b00 : out_emp = 5'h0; // (0db)
								2'b01 : out_emp = 5'hc; // (3.4db)
								2'b10 : out_emp = 5'hc; // Unused
								2'b11 : out_emp = 5'hc; // Unused
							endcase
						end
						2'b11 :
						begin
							out_vod = 6'd60;			//1200mv
							case(in_emp) 
								2'b00 : out_emp = 5'h0; // (0db)
								2'b01 : out_emp = 5'h0; // Unused
								2'b10 : out_emp = 5'h0; // Unused
								2'b11 : out_emp = 5'h0; // Unused
							endcase
						end
					endcase
			end // Stratix V

			"Arria V":
			begin : av
				always @(*)
					case (in_vod)
						2'b00 :
						begin
							out_vod = 6'd20;			//400mv
							case(in_emp) 
								2'b00 : out_emp = 5'h0; // (0db)
								2'b01 : out_emp = 5'h4; // (3.31db)
								2'b10 : out_emp = 5'h7; // (5.99db)
								2'b11 : out_emp = 5'ha; // (9.04db)
							endcase
						end
						2'b01 :
						begin
							out_vod = 6'd30;			//600mv
							case(in_emp) 
								2'b00 : out_emp = 5'h0; // (0db)
								2'b01 : out_emp = 5'h6; // (3.11db)
								2'b10 : out_emp = 5'hb; // (6.09db)
								2'b11 : out_emp = 5'hb; // Unused
							endcase
						end
						2'b10 :
						begin
							out_vod = 6'd40;			//800mv
							case(in_emp) 
								2'b00 : out_emp = 5'h0; // (0db)
								2'b01 : out_emp = 5'h9; // (3.38db)
								2'b10 : out_emp = 5'h9; // Unused
								2'b11 : out_emp = 5'h9; // Unused
							endcase
						end
						2'b11 :
						begin
							out_vod = 6'd60;			//1200mv
							case(in_emp) 
								2'b00 : out_emp = 5'h0; // (0db)
								2'b01 : out_emp = 5'h0; // Unused
								2'b10 : out_emp = 5'h0; // Unused
								2'b11 : out_emp = 5'h0; // Unused
							endcase
						end
					endcase
			end // End Arria V

			"Arria V GZ":
			begin : avgz
				// AV GZ uses same settings as SV
				always @(*)
					case (in_vod)
						2'b00 :
						begin
							out_vod = 6'd20;			//400mv
							case(in_emp) 
								2'b00 : out_emp = 5'h0; // (0db)
								2'b01 : out_emp = 5'h6; // (3.5db)
								2'b10 : out_emp = 5'h9; // (6.1db)
								2'b11 : out_emp = 5'hb; // (9.5db)
							endcase
						end
						2'b01 :
						begin
							out_vod = 6'd30;			//600mv
							case(in_emp) 
								2'b00 : out_emp = 5'h0; // (0db)
								2'b01 : out_emp = 5'h9; // (3.5db)
								2'b10 : out_emp = 5'he; // (6.1db)
								2'b11 : out_emp = 5'he; // Unused
							endcase
						end
						2'b10 :
						begin
							out_vod = 6'd40;			//800mv
							case(in_emp) 
								2'b00 : out_emp = 5'h0; // (0db)
								2'b01 : out_emp = 5'hc; // (3.4db)
								2'b10 : out_emp = 5'hc; // Unused
								2'b11 : out_emp = 5'hc; // Unused
							endcase
						end
						2'b11 :
						begin
							out_vod = 6'd60;			//1200mv
							case(in_emp) 
								2'b00 : out_emp = 5'h0; // (0db)
								2'b01 : out_emp = 5'h0; // Unused
								2'b10 : out_emp = 5'h0; // Unused
								2'b11 : out_emp = 5'h0; // Unused
							endcase
						end
					endcase
			end // End Arria V GZ

			"Cyclone V":
			begin : cv
				// Need to look up values, using Cyclone V values for
				// now
				always @(*)
					case (in_vod)
						2'b00 :
						begin
							out_vod = 6'd20;			//400mv
							case(in_emp) 
								2'b00 : out_emp = 5'h0; // (0db)
								2'b01 : out_emp = 5'h4; // (3.31db)
								2'b10 : out_emp = 5'h7; // (5.99db)
								2'b11 : out_emp = 5'ha; // (9.04db)
							endcase
						end
						2'b01 :
						begin
							out_vod = 6'd30;			//600mv
							case(in_emp) 
								2'b00 : out_emp = 5'h0; // (0db)
								2'b01 : out_emp = 5'h6; // (3.11db)
								2'b10 : out_emp = 5'hb; // (6.09db)
								2'b11 : out_emp = 5'hb; // Unused
							endcase
						end
						2'b10 :
						begin
							out_vod = 6'd40;			//800mv
							case(in_emp) 
								2'b00 : out_emp = 5'h0; // (0db)
								2'b01 : out_emp = 5'h9; // (3.38db)
								2'b10 : out_emp = 5'h9; // Unused
								2'b11 : out_emp = 5'h9; // Unused
							endcase
						end
						2'b11 :
						begin
							out_vod = 6'd60;			//1200mv
							case(in_emp) 
								2'b00 : out_emp = 5'h0; // (0db)
								2'b01 : out_emp = 5'h0; // Unused
								2'b10 : out_emp = 5'h0; // Unused
								2'b11 : out_emp = 5'h0; // Unused
							endcase
						end
					endcase
			end // End Cyclone V
		endcase
	end // generate
	endgenerate

endmodule

`default_nettype wire
