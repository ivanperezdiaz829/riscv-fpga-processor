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

`define FRAME_TYPE_CONSTANT  4'b0001
`define FRAME_TYPE_INCREMENT 4'b0010
`define FRAME_TYPE_RANDOM    4'b0100
`define FRAME_TYPE_CRC       4'b1000

`define DSM_INTER_FRAME      3'h0
`define DSM_PREAMBLE         3'h1
`define DSM_SFD              3'h2
`define DSM_DATA             3'h3
`define DSM_EFD              3'h4

`define XGMII_IDLE_D        64'h0707_0707_0707_0707
`define XGMII_IDLE_C         8'b11111111
`define XGMII_PREAMBLE_D    64'hABAA_AAAA_AAAA_AAFB
`define XGMII_PREAMBLE_C     8'b00000001
`define XGMII_DATA_C         8'b00000000
`define XGMII_START          8'hFB
`define XGMII_TERMINATE      8'hFD
`define XGMII_TXERROR        8'hFE
`define XGMII_IDLE           8'h07
`define XGMII_SEQOS          8'h9C //sequence order set
`define XGMII_RESERVED0      8'h1C
`define XGMII_RESERVED1      8'h3C
`define XGMII_RESERVED2      8'h7C
`define XGMII_RESERVED3      8'hBC
`define XGMII_RESERVED4      8'hDC
`define XGMII_RESERVED5      8'hFC
`define XGMII_SIGOS          8'h5C //signal order set
`define XGMII_CCNUM          12

`define FRAME_CONSTANT      64'h0000_0000_0000_0000
`define CRC_INIT            64'h2A26F826_2A26F826

`define POLYNOMIAL          33'h104C11DB7
`define PWIDTH              32
`define QWIDTH              32

`define POLYNOMIAL8          9'b1_0000_0111
`define PWIDTH8              8
`define QWIDTH8              8

module xgmii_src (
	clock,
	reset,
	frame_sof,
	frame_length,
	frame_type,
	frame_ifg,
	frame_constant,
	frame_done,
	xgmii_tx_clk,
	xgmii_tx,
	xgmii_rx_clk,
	xgmii_rx,
	xgmii_rx_d_mon,
	xgmii_rx_c_mon,
	xgmii_tx_d_mon,
	xgmii_tx_c_mon
); // module xgmii_src

	input  wire        clock;
	input  wire        reset;
	input  wire        frame_sof;
	input  wire [13:0] frame_length;
	input  wire  [3:0] frame_type;
	input  wire [15:0] frame_ifg;
	input  wire [63:0] frame_constant;
	output reg         frame_done;

	output wire        xgmii_tx_clk;
	output wire [71:0] xgmii_tx;
	input  wire        xgmii_rx_clk;
	input  wire [71:0] xgmii_rx;

	output wire [63:0] xgmii_rx_d_mon;
	output wire  [7:0] xgmii_rx_c_mon;
	output wire [63:0] xgmii_tx_d_mon;
	output wire  [7:0] xgmii_tx_c_mon;
  
	reg          [63:0] xgmii_tx_d;
	reg          [7:0] xgmii_tx_c;
	wire        [63:0] xgmii_rx_d;
	wire         [7:0] xgmii_rx_c;
	reg         [63:0] last_tx_d;
	reg          [2:0] dsm;
	reg         [13:0] f_length;
	reg          [4:0] f_type;
	reg         [63:0] f_crc;
	reg        [127:0] align_d_buf;
	reg         [63:0] align_d;
	reg         [15:0] align_c_buf;
	reg          [7:0] align_c;
	reg        [127:0] align_d_buf2;
	reg         [15:0] align_c_buf2;
	integer            bytesent;
	integer            byteslip;
	integer            i;

function [0:0] CheckControlCode;
input [(`QWIDTH-1):0] data;
reg		[0:0]						match;
reg		[7:0]						lane;
integer									i,j;
static reg [7:0] XGMII_CONTROL_CODE [0:`XGMII_CCNUM-1]= '{`XGMII_IDLE, `XGMII_START, `XGMII_TERMINATE, `XGMII_TXERROR, `XGMII_SEQOS, `XGMII_RESERVED0, `XGMII_RESERVED1,`XGMII_RESERVED2,`XGMII_RESERVED3,`XGMII_RESERVED4,`XGMII_RESERVED5,`XGMII_SIGOS};
begin
	match=0;
	for (i=0;i<4;i=i+1) begin
		for (j=0;j<`XGMII_CCNUM;j=j+1) begin
			lane = data[(i*8)+:8];
			match = (lane==XGMII_CONTROL_CODE[j])? 1'b1 : match;
	  end
  end
  CheckControlCode=match;
end
endfunction

function [(`QWIDTH-1):0] crc32;
	input [(`PWIDTH-1):0] p;
	input [(`QWIDTH-1):0] ini;

	reg   [(`PWIDTH-1):0] p;
	reg   [(`QWIDTH-1):0] ini;
	reg   [(`PWIDTH+1):0] poly;
	reg   [(`QWIDTH-1):0] r;
	integer               j;

	begin
		r = ini;
		poly = `POLYNOMIAL;

		for (j=0; j<`PWIDTH; j=j+1) begin
			if (r[`QWIDTH-1]) begin
				r[(`QWIDTH-1):1] = r[(`QWIDTH-2):0];
				r[0] = p[(`PWIDTH-1)-j];
				r = r^poly[(`QWIDTH-1):0];
			end else begin
				r[(`QWIDTH-1):1] = r[(`QWIDTH-2):0];
				r[0] = p[(`PWIDTH-1)-j];
			end
		end
		
		if (CheckControlCode(r)) begin
			r[31: 0] = r[31: 0]>>1;
		end

		crc32 = r;

	end
endfunction

function [(`QWIDTH8-1):0] crc8;
	input [(`PWIDTH8-1):0] p;
	input [(`QWIDTH8-1):0] ini;

	reg   [(`PWIDTH8-1):0] p;
	reg   [(`QWIDTH8-1):0] ini;
	reg   [(`PWIDTH8+1):0] poly;
	reg   [(`QWIDTH8-1):0] r;
	integer                j;

	begin
		r = ini;
		poly = `POLYNOMIAL8;

		for (j=0; j<`PWIDTH8; j=j+1) begin
			if (r[`QWIDTH8-1]) begin
				r[(`QWIDTH8-1):1] = r[(`QWIDTH8-2):0];
				r[0] = p[(`PWIDTH8-1)-j];
				r = r^poly[(`QWIDTH8-1):0];
			end else begin
				r[(`QWIDTH8-1):1] = r[(`QWIDTH8-2):0];
				r[0] = p[(`PWIDTH8-1)-j];
			end
		end

		crc8 = r;

	end
endfunction

assign xgmii_tx_clk = clock;

genvar g;
generate
	for (g=0; g<8; g=g+1) begin : ast_translation
		assign xgmii_tx[(g*9)+:8] = xgmii_tx_d[(g*8)+:8];
		assign xgmii_tx[(g*9)+8] = xgmii_tx_c[g];
		assign xgmii_rx_d[(g*8)+:8] = xgmii_rx[(g*9)+:8];
		assign xgmii_rx_c[g] = xgmii_rx[(g*9)+8];
	end
endgenerate


always @(posedge clock or posedge reset) begin
	if (reset) begin
		dsm        <= `DSM_INTER_FRAME;
		xgmii_tx_c <= `XGMII_IDLE_C;
		xgmii_tx_d <= `XGMII_IDLE_D;
		frame_done <= 1'b0;
		last_tx_d  <= 64'h0706_0504_0302_0100;
		bytesent   <= 0;
		f_crc      <= `CRC_INIT;
	end else begin
		case (dsm)

			`DSM_INTER_FRAME: begin
				if (frame_sof) begin
					f_length <= frame_length;
					f_type <= frame_type;
					dsm <= `DSM_PREAMBLE;
				end else begin
					dsm <= `DSM_INTER_FRAME;
				end
				xgmii_tx_c <= `XGMII_IDLE_C;
				xgmii_tx_d <= `XGMII_IDLE_D;
				frame_done <= 1'b0;
			end

			`DSM_PREAMBLE: begin
				dsm <= `DSM_DATA;
				xgmii_tx_c <= `XGMII_PREAMBLE_C;
				xgmii_tx_d <= `XGMII_PREAMBLE_D;
				frame_done <= 1'b0;
				bytesent <= 0;
				f_crc <= `CRC_INIT;
			end

			`DSM_DATA: begin
				xgmii_tx_c <= `XGMII_DATA_C;
				frame_done <= 1'b0;
				case (f_type & 4'b0111)

					`FRAME_TYPE_CONSTANT: begin
						xgmii_tx_d <= frame_constant;
					end

					`FRAME_TYPE_INCREMENT: begin
						xgmii_tx_d <= last_tx_d;
						last_tx_d  <= last_tx_d + 64'h0808_0808_0808_0808;
					end

					`FRAME_TYPE_RANDOM: begin
						xgmii_tx_d       <= last_tx_d;
						last_tx_d[63:32] <= crc32(64'h0, last_tx_d[63:32]);
						last_tx_d[31: 0] <= crc32(64'h0, last_tx_d[31: 0]);
					end

				endcase // case (f_type & 4'b0111)

				f_crc[63:32] <= crc32(xgmii_tx_d[63:32], f_crc[63:32]);
				f_crc[31: 0] <= crc32(xgmii_tx_d[31: 0], f_crc[31: 0]);
				if (bytesent < (f_length-8)) begin
					dsm <= `DSM_DATA;
				end else begin
					dsm <= `DSM_EFD;
					if ((f_type & 4'b1000) == `FRAME_TYPE_CRC) begin
						xgmii_tx_d <= ~f_crc;
					end
				end
				bytesent <= bytesent + 8;
			end

			`DSM_EFD: begin
				dsm <= `DSM_INTER_FRAME;
				xgmii_tx_c <= 8'b11111111;
				xgmii_tx_d <= 64'h07070707_070707FD;
				frame_done <= 1'b1;
			end

		endcase // case (dsm)
	end
end

always @(posedge xgmii_rx_clk) begin
	align_d_buf[63:0] <= align_d_buf[127:64];
	align_d_buf[127:64] <= xgmii_rx_d;
	align_c_buf[7:0] <= align_c_buf[15:8];
	align_c_buf[15:8] <= xgmii_rx_c;

	align_d_buf2 <= align_d_buf;
	align_c_buf2 <= align_c_buf;
end


always @(posedge xgmii_rx_clk or posedge reset) begin
	if (reset) begin
		byteslip <= -1;
		align_d <= `XGMII_IDLE_D;
		align_c <= `XGMII_IDLE_C;
	end else begin
		if (byteslip == -1) begin
			for (i=0; i<2; i=i+1) begin
				if ((align_d_buf[(i * 32) +: 64] == `XGMII_PREAMBLE_D) && (align_c_buf[(i *  4) +:  8] == `XGMII_PREAMBLE_C)) begin
					byteslip  <= i;
//synopsys translate_off
					$display("Start frame detected, byteslip %1d, time %0d", i, $time);
//synopsys translate_on
				end
			end
		end 
		if (byteslip != -1) begin
			align_d <= align_d_buf2[(byteslip*32)+:64];
			align_c <= align_c_buf2[(byteslip*4)+:8];
		end
	end
end

assign xgmii_rx_d_mon = align_d;
assign xgmii_rx_c_mon = align_c;
assign xgmii_tx_d_mon = xgmii_tx_d;
assign xgmii_tx_c_mon = xgmii_tx_c;

endmodule
