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
// dp_mif_mappings
// 
// Description
// 
// This module maps the various mif settings used for reconfiguration
// mapping is based on device family and link rate
//
// This file contains the MIF information that needs to be written
// during a MIF mode1 direct write reconfiguration. The information
// is derived from "diff'ing" the reconfig mifs from each of the
// different transciever link rates. This has all the settings for
// the PLLs and any other transceiver settings that may have changed.
// 
// The parameter determines the family being mapped. 
//
// The mif_type indicates RX, TX or TX PLL for the mapping. 
// Link rate determines the link rate value to use.
// Index is the current MIF value to map. 
// Done is set true on the last value for each mif type. 
//
// *********************************************************************

`timescale 1 ps / 1 ps
`default_nettype none

module dp_mif_mappings #(
	parameter DEVICE_FAMILY = "Stratix V"
)(
	input  wire	[2:0]	mif_type,
	input  wire [1:0]   rx_link_rate,  
	input  wire [1:0]   tx_link_rate, 
	input  wire	[3:0]	index,
	output reg  [5:0]   offset, 
	output reg  [15:0]  value,
	output reg			done
);

	// MIF types
	localparam	DUPLEX	= 3'b000,
				CMU		= 3'b001,
				RX		= 3'b010,
				TX		= 3'b011,
				ATX		= 3'b100; 

	//Link rates
	localparam	RBR		= 2'b00,
				HBR		= 2'b01,
				HBR2	= 2'b10; 

	// Settings are based on family
	generate begin
		case (DEVICE_FAMILY)
			"Stratix V":
			begin : sv
				always @(*)
				begin
					done	= 1'b0;
					offset	= 6'h00;
					value	= 16'h0000;

					case (mif_type)
						RX :
						begin
							case(index) 
								4'd0 :	// PMA RX (PLL section) word 1
								begin
									offset	= 6'h0c;
									case (rx_link_rate)
										RBR	:	value = 16'h5600;
										HBR :	value = 16'h5600;
										HBR2 :	value = 16'h5500;
									endcase
								end
								4'd1 :	// PMA RX (PLL section) word 2
								begin
									offset	= 6'h0d;
									value	= 16'h0000;
								end
								4'd2 :	// PMA RX (PLL section) word 3
								begin
									offset	= 6'h0e;
									value	= 16'h0d60;
								end
								4'd3 :	// PMA RX (PLL section) word 4
								begin
									offset	= 6'h0f;
									value	= 16'h0006;
								end
								4'd4 :	// PMA RX (PLL section) word 5
								begin
									offset	= 6'h10;
									value	= 16'h4000;
								end
								4'd5 :	// RX EYE Monitor
								begin
									offset	= 6'h16;
									case (rx_link_rate)
										RBR	:	value = 16'h0296;
										HBR :	value = 16'h0496;
										HBR2 :	value = 16'h0496;
									endcase
									done	= 1'b1;	// Last MIF value
								end
							endcase
						end	// RX

						TX :
						begin
							case(index) 
								4'd0 :	// TX CGB DIV
								begin
									offset	= 6'h00;
									case (tx_link_rate)
										RBR	:	value = 16'h2838;
										HBR :	value = 16'h2a38;
										HBR2 :	value = 16'h2838;
									endcase
								end
								4'd1 :	// TX SLEW
								begin
									offset	= 6'h02;
									case (tx_link_rate)
										RBR	:	value = 16'h8094;
										HBR :	value = 16'h8094;
										HBR2 :	value = 16'h80d4;
									endcase
								end
								4'd2 :	// TX VCM
								begin
									offset	= 6'h04;
									case (tx_link_rate)
										RBR	:	value = 16'h06c0;
										HBR :	value = 16'h03c0;
										HBR2 :	value = 16'h03c0;
									endcase
									done	= 1'b1;	// Last MIF value
								end
							endcase
						end	// TX

						CMU :
						begin
							case(index) 
								4'd0 :	// PMA TX (PLL section) word 1
								begin
									offset	= 6'h0c;
									case (tx_link_rate)
										RBR	:	value = 16'h3801;
										HBR :	value = 16'h5401;
										HBR2 :	value = 16'h5401;
									endcase
								end
								4'd1 :	// PMA TX (PLL section) word 2
								begin
									offset	= 6'h0d;
									value	= 16'h0000;
								end
								4'd2 :	// PMA TX (PLL section) word 3
								begin
									offset	= 6'h0e;
									value	= 16'h0d60;
								end
								4'd3 :	// PMA TX (PLL section) word 4
								begin
									offset	= 6'h0f;
									value	= 16'h8006;
								end
								4'd4 :	// PMA TX (PLL section) word 5
								begin
									offset	= 6'h10;
									value	= 16'h4000;
									done	= 1'b1;	// Last MIF value
								end
							endcase
						end	// CMU
					endcase
				end
			end // Stratix V

			"Arria V GZ":
			begin : avgz
				always @(*)
				begin
					done	= 1'b0;
					offset	= 6'h00;
					value	= 16'h0000;

					case (mif_type)
						RX :
						begin
							case(index) 
								4'd0 :	// PMA RX (PLL section) word 1
								begin
									offset	= 6'h0c;
									case (rx_link_rate)
										RBR	:	value = 16'h5600;
										HBR :	value = 16'h5600;
										HBR2 :	value = 16'h5500;
									endcase
								end
								4'd1 :	// PMA RX (PLL section) word 2
								begin
									offset	= 6'h0d;
									value	= 16'h0000;
								end
								4'd2 :	// PMA RX (PLL section) word 3
								begin
									offset	= 6'h0e;
									value	= 16'h0d60;
								end
								4'd3 :	// PMA RX (PLL section) word 4
								begin
									offset	= 6'h0f;
									value	= 16'h0006;
								end
								4'd4 :	// PMA RX (PLL section) word 5
								begin
									offset	= 6'h10;
									value	= 16'h4000;
								end
								4'd5 :	// RX EYE Monitor
								begin
									offset	= 6'h16;
									case (rx_link_rate)
										RBR	:	value = 16'h0296;
										HBR :	value = 16'h0496;
										HBR2 :	value = 16'h0496;
									endcase
									done	= 1'b1;	// Last MIF value
								end
							endcase
						end	// RX

						TX :
						begin
							case(index) 
								4'd0 :	// TX CGB DIV
								begin
									offset	= 6'h00;
									case (tx_link_rate)
										RBR	:	value = 16'h2838;
										HBR :	value = 16'h2a38;
										HBR2 :	value = 16'h2838;
									endcase
								end
								4'd1 :	// TX SLEW
								begin
									offset	= 6'h02;
									case (tx_link_rate)
										RBR	:	value = 16'h8094;
										HBR :	value = 16'h8094;
										HBR2 :	value = 16'h80d4;
									endcase
								end
								4'd2 :	// TX VCM
								begin
									offset	= 6'h04;
									case (tx_link_rate)
										RBR	:	value = 16'h06c0;
										HBR :	value = 16'h03c0;
										HBR2 :	value = 16'h03c0;
									endcase
									done	= 1'b1;	// Last MIF value
								end
							endcase
						end	// TX

						CMU :
						begin
							case(index) 
								4'd0 :	// PMA TX (PLL section) word 1
								begin
									offset	= 6'h0c;
									case (tx_link_rate)
										RBR	:	value = 16'h3801;
										HBR :	value = 16'h5401;
										HBR2 :	value = 16'h5401;
									endcase
								end
								4'd1 :	// PMA TX (PLL section) word 2
								begin
									offset	= 6'h0d;
									value	= 16'h0000;
								end
								4'd2 :	// PMA TX (PLL section) word 3
								begin
									offset	= 6'h0e;
									value	= 16'h0d60;
								end
								4'd3 :	// PMA TX (PLL section) word 4
								begin
									offset	= 6'h0f;
									value	= 16'h8006;
								end
								4'd4 :	// PMA TX (PLL section) word 5
								begin
									offset	= 6'h10;
									value	= 16'h4000;
									done	= 1'b1;	// Last MIF value
								end
							endcase
						end	// CMU
					endcase
				end
			end // Arria V GZ

			"Arria V":
			begin : av
				always @(*)
				begin
					done	= 1'b0;
					offset	= 6'h00;
					value	= 16'h0000;

					case (mif_type)
						RX :
						begin
							case(index) 
								4'd0 :	// PMA RX (PLL section) word 1
								begin
									offset	= 6'h0e;
									case (rx_link_rate)
										RBR	:	value = 16'h1580;
										HBR :	value = 16'h0d40;
										HBR2 :	value = 16'h0d00;
									endcase
								end
								4'd1 :	// PMA RX (PLL section) word 2
								begin
									offset	= 6'h0f;
									value	= 16'h0000;
								end
								4'd2 :	// PMA RX (PLL section) word 3
								begin
									offset	= 6'h10;
									case (rx_link_rate)
										RBR	:	value = 16'h8450;
										HBR :	value = 16'h8440;
										HBR2 :	value = 16'h8440;
									endcase
								end
								4'd3 :	// PMA RX (PLL section) word 4
								begin
									offset	= 6'h11;
									case (rx_link_rate)
										RBR	:	value = 16'h0001;
										HBR :	value = 16'h0021;
										HBR2 :	value = 16'h0021;
									endcase
								end
								4'd4 :	// PMA RX (PLL section) word 5
								begin
									offset	= 6'h12;
									case (rx_link_rate)
										RBR	:	value = 16'h1100;
										HBR :	value = 16'h1100;
										HBR2 :	value = 16'h0100;
									endcase
									done	= 1'b1;	// Last MIF value
								end
							endcase
						end	// RX

						TX :
						begin
							case(index) 
								4'd0 :	// TX CGB DIV?
								begin
									offset	= 6'h00;
									case (tx_link_rate)
										RBR	:	value = 16'h052c;
										HBR :	value = 16'h056c;
										HBR2 :	value = 16'h052c;
									endcase
								end
								4'd1 :	// TX SLEW?
								begin
									offset	= 6'h02;
									case (tx_link_rate)
										RBR	:	value = 16'h012c;
										HBR :	value = 16'h012c;
										HBR2 :	value = 16'h03ac;
									endcase
									done	= 1'b1;	// Last MIF value
								end
							endcase
						end	// TX

						CMU :
						begin
							case(index) 
								4'd0 :	// PMA TX (PLL section) word 1
								begin
									offset	= 6'h0e;
									case (tx_link_rate)
										RBR	:	value = 16'h0e01;
										HBR :	value = 16'h1401;
										HBR2 :	value = 16'h1401;
									endcase
								end
								4'd1 :	// PMA TX (PLL section) word 2
								begin
									offset	= 6'h0f;
									value	= 16'h0000;
								end
								4'd2 :	// PMA TX (PLL section) word 3
								begin
									offset	= 6'h10;
									case (tx_link_rate)
										RBR	:	value = 16'h8450;
										HBR :	value = 16'h8440;
										HBR2 :	value = 16'h8440;
									endcase
								end
								4'd3 :	// PMA TX (PLL section) word 4
								begin
									offset	= 6'h11;
									case (tx_link_rate)
										RBR	:	value = 16'h4001;
										HBR :	value = 16'h4021;
										HBR2 :	value = 16'h0021;
									endcase
								end
								4'd4 :	// PMA TX (PLL section) word 5
								begin
									offset	= 6'h12;
									case (tx_link_rate)
										RBR	:	value = 16'h0100;
										HBR :	value = 16'h0100;
										HBR2 :	value = 16'h0100;
									endcase
									done	= 1'b1;	// Last MIF value
								end
							endcase
						end	// CMU
					endcase
				end
			end // Arria V

			"Cyclone V":
			begin : cv
				always @(*)
				begin
					done	= 1'b0;
					offset	= 6'h00;
					value	= 16'h0000;

					case (mif_type)
						RX :
						begin
							case(index) 
								4'd0 :	// PMA RX (PLL section) word 1
								begin
									offset	= 6'h0e;
									case (rx_link_rate)
										RBR	:	value = 16'h1580;
										HBR :	value = 16'h0d40;
										HBR2 :	value = 16'h0d00;
									endcase
								end
								4'd1 :	// PMA RX (PLL section) word 2
								begin
									offset	= 6'h0f;
									value	= 16'h0000;
								end
								4'd2 :	// PMA RX (PLL section) word 3
								begin
									offset	= 6'h10;
									case (rx_link_rate)
										RBR	:	value = 16'h8450;
										HBR :	value = 16'h8440;
										HBR2 :	value = 16'h8440;
									endcase
								end
								4'd3 :	// PMA RX (PLL section) word 4
								begin
									offset	= 6'h11;
									case (rx_link_rate)
										RBR	:	value = 16'h0001;
										HBR :	value = 16'h0021;
										HBR2 :	value = 16'h0021;
									endcase
								end
								4'd4 :	// PMA RX (PLL section) word 5
								begin
									offset	= 6'h12;
									case (rx_link_rate)
										RBR	:	value = 16'h1100;
										HBR :	value = 16'h1100;
										HBR2 :	value = 16'h0100;
									endcase
									done	= 1'b1;	// Last MIF value
								end
							endcase
						end	// RX

						TX :
						begin
							case(index) 
								4'd0 :	// TX CGB DIV?
								begin
									offset	= 6'h00;
									case (tx_link_rate)
										RBR	:	value = 16'h052c;
										HBR :	value = 16'h056c;
										HBR2 :	value = 16'h052c;
									endcase
								end
								4'd1 :	// TX SLEW?
								begin
									offset	= 6'h02;
									case (tx_link_rate)
										RBR	:	value = 16'h012c;
										HBR :	value = 16'h012c;
										HBR2 :	value = 16'h03ac;
									endcase
									done	= 1'b1;	// Last MIF value
								end
							endcase
						end	// TX

						CMU :
						begin
							case(index) 
								4'd0 :	// PMA TX (PLL section) word 1
								begin
									offset	= 6'h0e;
									case (tx_link_rate)
										RBR	:	value = 16'h0e01;
										HBR :	value = 16'h1401;
										HBR2 :	value = 16'h1401;
									endcase
								end
								4'd1 :	// PMA TX (PLL section) word 2
								begin
									offset	= 6'h0f;
									value	= 16'h0000;
								end
								4'd2 :	// PMA TX (PLL section) word 3
								begin
									offset	= 6'h10;
									case (tx_link_rate)
										RBR	:	value = 16'h8450;
										HBR :	value = 16'h8440;
										HBR2 :	value = 16'h8440;
									endcase
								end
								4'd3 :	// PMA TX (PLL section) word 4
								begin
									offset	= 6'h11;
									case (tx_link_rate)
										RBR	:	value = 16'h4001;
										HBR :	value = 16'h4021;
										HBR2 :	value = 16'h0021;
									endcase
								end
								4'd4 :	// PMA TX (PLL section) word 5
								begin
									offset	= 6'h12;
									case (tx_link_rate)
										RBR	:	value = 16'h0100;
										HBR :	value = 16'h0100;
										HBR2 :	value = 16'h0100;
									endcase
									done	= 1'b1;	// Last MIF value
								end
							endcase
						end	// CMU
					endcase
				end
			end // Cyclone V
		endcase
	end // generate
	endgenerate

endmodule

`default_nettype wire
