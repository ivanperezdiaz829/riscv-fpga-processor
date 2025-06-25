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


// lanny - 09-30-11

`timescale 1ps / 1ps

module alt_e100_wide_l8if_rx528(
    arst, clk_rxmac, rx8l_d, rx8l_sop, rx8l_eop, rx8l_empty, rx8l_error,
    rx8l_fcs_valid, rx8l_fcs_error,
    rx8l_wrfull, rx8l_wrreq, rx5l_d, rx5l_sop, rx5l_eop_bm, rx5l_valid,
    rx5l_fcs_valid, rx5l_fcs_error, rx5l_error

);

parameter DEVICE_FAMILY = "Stratix V";

localparam WORDS_IN = 5;
localparam WORDS = 8;
localparam WORD_LEN = 64;
localparam EXP_WORD_LEN = WORD_LEN + 1 + 4 + 2 /*Lanny: for fcs_valid and fcs_error*/;

//--- ports
input               arst;
input               clk_rxmac;     // MAC + PCS clock - at least 312.5Mhz

output reg  [511:0] rx8l_d;        // 8 lane payload data
output reg          rx8l_sop;
output reg          rx8l_eop;
output reg    [5:0] rx8l_empty;
output reg          rx8l_error;
output              rx8l_fcs_valid;
output              rx8l_fcs_error;
input               rx8l_wrfull;
output reg          rx8l_wrreq;

input       [319:0] rx5l_d;        // 5 lane payload to send
input       [5-1:0] rx5l_sop;      // 5 lane start position
input        [39:0] rx5l_eop_bm;   // 5 lane end position, any byte, bit map
input               rx5l_valid;    // payload is accepted
input               rx5l_error;
input               rx5l_fcs_valid;
input               rx5l_fcs_error;


//--- functions
//----------------------------------------------------------------------------
function [2:0] alt_e100_wide_encode8to3;
input [7:0] in;

reg   [2:0] out;
integer     i;

begin
    out = 0;
    for (i = 0; i < 8; i = i + 1) begin
        if (in[i])   out = out | i[2:0];
    end
    alt_e100_wide_encode8to3 = out;
end
endfunction




// pipeline input ports
reg rx5l_valid_q;
//reg rx5l_error_q;
reg rx5l_fcs_valid_q;
reg rx5l_fcs_error_q;
reg [319:0] rx5l_d_q;
reg [4:0]	rx5l_sop_q;
reg [39:0]	rx5l_eop_bm_q;

always @ (posedge clk_rxmac or posedge arst)
begin
	if (arst) begin
		rx5l_valid_q    <= 0;
		//rx5l_error_q    <= 0;
		rx5l_sop_q      <= 5'b0;
		rx5l_eop_bm_q   <= 40'b0;
        rx5l_fcs_valid_q <= 1'b0;
        rx5l_fcs_error_q <= 1'b0;
	end
	else begin
		rx5l_valid_q    <= rx5l_valid;
		//rx5l_error_q    <= rx5l_error;
		if (rx5l_valid)
		begin
			rx5l_sop_q      <= rx5l_sop;
			rx5l_eop_bm_q   <= rx5l_eop_bm;
			rx5l_fcs_valid_q<= rx5l_fcs_valid;
			rx5l_fcs_error_q<= rx5l_fcs_error;
		end
		else begin
			rx5l_sop_q    <= 5'b0;
			rx5l_eop_bm_q <= 40'b0;
			rx5l_fcs_valid_q <= 1'b0;
			rx5l_fcs_error_q <= 1'b0;
		end
	end
end
	
always @ (posedge clk_rxmac)
begin
	if (rx5l_valid)
		rx5l_d_q <= rx5l_d;
	else
		rx5l_d_q <= 320'b0;
end

// avoid writing junk data
reg rxi_in_packet = 1'b0;

always @(posedge clk_rxmac or posedge arst)
if (arst)
	begin
		rxi_in_packet <= 0;
	end
else
	begin
		 if      ( (|rx5l_sop_q) & (~(|rx5l_eop_bm_q)))
			  rxi_in_packet <= 1;
		 else if ((~(|rx5l_sop_q)) &  (|rx5l_eop_bm_q))
			  rxi_in_packet <= 0;
	end


///////////////////////////////////////////////////////
// compact_words to remove junk data between eop and sop
///////////////////////////////////////////////////////

// convert rx5l_eop_bm_q to rx5l_eopbits (gregg's eopbits notaion);
wire [4*WORDS_IN-1:0] rx5l_eopbits;
wire [WORDS_IN-1:0] rx5l_fcs_valid_bits;
wire [WORDS_IN-1:0] rx5l_fcs_error_bits;

genvar i;
generate
	for (i=0; i<WORDS_IN; i= i+1) begin : gen_eopbits
		assign rx5l_eopbits [i*4+3] = (|rx5l_eop_bm_q[8*i+7 : 8*i]);
		assign rx5l_eopbits [i*4+2 : i*4] = alt_e100_wide_encode8to3 (rx5l_eop_bm_q[8*i+7 : 8*i]);
		assign rx5l_fcs_valid_bits [i] = rx5l_fcs_valid_q & (|rx5l_eop_bm_q[8*i+7 : 8*i]) ;
		assign rx5l_fcs_error_bits [i] = rx5l_fcs_error_q & (|rx5l_eop_bm_q[8*i+7 : 8*i]) ;
		/* NOTE: FCS results will be dropped if they are not aligned with eop */
	end
endgenerate

// expand to words to { SOP, EOP[3:0], data }
wire [EXP_WORD_LEN*WORDS_IN-1:0] exp_annot;
reg [EXP_WORD_LEN*WORDS_IN-1:0] exp_annot_q;	// input of alt_e100_wide_compact_words_8

generate
	for (i=0; i<WORDS_IN; i= i+1) begin : exp_ann
		assign exp_annot [(i+1)*EXP_WORD_LEN-1:i*EXP_WORD_LEN] =
			{	rx5l_sop_q[i], rx5l_eopbits[i*4+3 : i*4],
				rx5l_fcs_valid_bits[i], rx5l_fcs_error_bits[i],
				rx5l_d_q[(i+1)*WORD_LEN-1:i*WORD_LEN]};
	end
endgenerate

// annot_words_valid
reg [4:0]	annot_words_valid;
reg [4:0]	annot_words_valid_q;		// input of alt_e100_wide_compact_words_8
wire [4:0]	rx5l_eop_mask;
assign rx5l_eop_mask [4] = rx5l_eopbits [19];
assign rx5l_eop_mask [3] = rx5l_eopbits [15];
assign rx5l_eop_mask [2] = rx5l_eopbits [11];
assign rx5l_eop_mask [1] = rx5l_eopbits [7 ];
assign rx5l_eop_mask [0] = rx5l_eopbits [3 ];

// the logic below:
// if rxi_in_packet == 0, annot_words_valid[x+3] = 1 only if (|rx5l_sop_q[4:x]) == 1 and (|rx5l_eop_mask[4:x+1]) != 1
// if rxi_in_packet == 1, annot_words_valid[x+3] = 0 only if (|rx5l_eop_mask[4:x+1]) == 1 and (|rx5l_sop_q[4:x]) != 1
// only the valid cases are included here. (frame size less then 5 is also included)
always @ (*)
begin
if (rx5l_valid_q == 1'b0)
	annot_words_valid = 5'b00000;
else
	case ({rx5l_sop_q, rx5l_eop_mask})
	// no sop or eop
	{5'b00000, 5'b00000}:	annot_words_valid = rxi_in_packet ? 5'b11111 : 5'b00000 ;
	// sop only
	{5'b10000, 5'b00000}:	annot_words_valid = rxi_in_packet ? 5'b11111 : 5'b11111 ;
	{5'b01000, 5'b00000}:	annot_words_valid = rxi_in_packet ? 5'b01111 : 5'b01111 ;
	{5'b00100, 5'b00000}:	annot_words_valid = rxi_in_packet ? 5'b00111 : 5'b00111 ;
	{5'b00010, 5'b00000}:	annot_words_valid = rxi_in_packet ? 5'b00011 : 5'b00011 ;
	{5'b00001, 5'b00000}:	annot_words_valid = rxi_in_packet ? 5'b00001 : 5'b00001 ;
	// eop only
	{5'b00000, 5'b10000}:	annot_words_valid = rxi_in_packet ? 5'b10000 : 5'b00000 ;
	{5'b00000, 5'b01000}:	annot_words_valid = rxi_in_packet ? 5'b11000 : 5'b00000 ;
	{5'b00000, 5'b00100}:	annot_words_valid = rxi_in_packet ? 5'b11100 : 5'b00000 ;
	{5'b00000, 5'b00010}:	annot_words_valid = rxi_in_packet ? 5'b11110 : 5'b00000 ;
	{5'b00000, 5'b00001}:	annot_words_valid = rxi_in_packet ? 5'b11111 : 5'b00000 ;
	// sop in front of eop
	{5'b10000, 5'b01000}:	annot_words_valid = rxi_in_packet ? 5'b11000 : 5'b11000 ;
	{5'b10000, 5'b00100}:	annot_words_valid = rxi_in_packet ? 5'b11100 : 5'b11100 ;
	{5'b10000, 5'b00010}:	annot_words_valid = rxi_in_packet ? 5'b11110 : 5'b11110 ;
	{5'b10000, 5'b00001}:	annot_words_valid = rxi_in_packet ? 5'b11111 : 5'b11111 ;
	{5'b01000, 5'b00100}:	annot_words_valid = rxi_in_packet ? 5'b01100 : 5'b01100 ;
	{5'b01000, 5'b00010}:	annot_words_valid = rxi_in_packet ? 5'b01110 : 5'b01110 ;
	{5'b01000, 5'b00001}:	annot_words_valid = rxi_in_packet ? 5'b01111 : 5'b01111 ;
	{5'b00100, 5'b00010}:	annot_words_valid = rxi_in_packet ? 5'b00110 : 5'b00110 ;
	{5'b00100, 5'b00001}:	annot_words_valid = rxi_in_packet ? 5'b00111 : 5'b00111 ;
	{5'b00010, 5'b00001}:	annot_words_valid = rxi_in_packet ? 5'b00011 : 5'b00011 ;
	// eop in front of sop
	{5'b01000, 5'b10000}:	annot_words_valid = rxi_in_packet ? 5'b11111 : 5'b01111 ;
	{5'b00100, 5'b10000}:	annot_words_valid = rxi_in_packet ? 5'b10111 : 5'b00111 ;
	{5'b00010, 5'b10000}:	annot_words_valid = rxi_in_packet ? 5'b10011 : 5'b00011 ;
	{5'b00001, 5'b10000}:	annot_words_valid = rxi_in_packet ? 5'b10001 : 5'b00001 ;
	{5'b00100, 5'b01000}:	annot_words_valid = rxi_in_packet ? 5'b11111 : 5'b00111 ;
	{5'b00010, 5'b01000}:	annot_words_valid = rxi_in_packet ? 5'b11011 : 5'b00011 ;
	{5'b00001, 5'b01000}:	annot_words_valid = rxi_in_packet ? 5'b11001 : 5'b00001 ;
	{5'b00010, 5'b00100}:	annot_words_valid = rxi_in_packet ? 5'b11111 : 5'b00011 ;
	{5'b00001, 5'b00100}:	annot_words_valid = rxi_in_packet ? 5'b11101 : 5'b00001 ;
	{5'b00001, 5'b00010}:	annot_words_valid = rxi_in_packet ? 5'b11111 : 5'b00001 ;
	// the case sop == eop
	default:						annot_words_valid = rxi_in_packet ? 5'b00000 : 5'b00000 ;
	endcase
end																
																			
////////////////////////////////////////////
// compact used words together on the bus
// e.g. 10001 to 11000
////////////////////////////////////////////

always @ (posedge clk_rxmac or posedge arst)
if (arst)
	begin
		annot_words_valid_q <= 5'b0;
	end
else
	begin
		annot_words_valid_q <= annot_words_valid;
	end

always @ (posedge clk_rxmac) exp_annot_q <= exp_annot;

wire [WORDS*EXP_WORD_LEN-1:0] compact_words;		// output of alt_e100_wide_compact_words_8
wire [3:0] num_compact_words_valid	;				// output of alt_e100_wide_compact_words_8

// power-on reset

alt_e100_wide_compact_words_8 cw
(
	.clk(clk_rxmac),
	.arst(arst),
		
	.din_valid_mask({annot_words_valid_q, 3'b0}),
	.din_words({exp_annot_q, 213'b0}),
		
	// packed toward more significant end
	.dout_words(compact_words),
	.num_dout_words_valid(num_compact_words_valid)	
);
defparam cw .WORDS = WORDS;
defparam cw .WORD_LEN = EXP_WORD_LEN;	

////////////////////////////////////////////
// split back up 
////////////////////////////////////////////

wire [WORDS-1:0] compact_sop;
wire [4*WORDS-1:0] compact_eopbits;
wire [(WORD_LEN+2)*WORDS-1:0] compact_dat; /*2 Lanny: for fcs_valid and fcs_error*/

generate
	for (i=0; i<WORDS; i= i+1) begin : spl
		assign {
			compact_sop[i], compact_eopbits[(i+1)*4-1:i*4],
			compact_dat[(i+1)*(WORD_LEN+2)-1:i*(WORD_LEN+2)]} =/* NOTE: compact_dat = 64'b data+2'b fcs_results */
			   compact_words [(i+1)*EXP_WORD_LEN-1:i*EXP_WORD_LEN];			  
	end
endgenerate

////////////////////////////////////////////
// realign to SOP boundaries
////////////////////////////////////////////

wire [3:0] num_dout_words_valid; // 0..8 valid, grouped toward left
wire dout_sop;							// referring to the first valid word
wire [3:0] dout_eopbits;			// referring to the last valid word
wire [WORDS*(WORD_LEN+2)-1:0] dout; /*2 Lanny: for fcs_valid and fcs_error*/
wire overflow;

// power-on reset

alt_e100_wide_regroup_8 rg (	
	.clk(clk_rxmac),
	.arst(arst),
	.din_num_valid(num_compact_words_valid),  // 0..8 valid, grouped toward left
	.din_sop(compact_sop),			// per input word
	.din_eopbits(compact_eopbits), // per input word	
	.din(compact_dat), 
		
	.dout_num_valid(num_dout_words_valid), // 0..8 valid, grouped toward left
	.dout_sop(dout_sop),			// referring to the first valid word	
	.dout_eopbits(dout_eopbits),	// referring to the last valid word
	.dout(dout),
	.overflow(overflow)	
);
defparam rg .WORD_WIDTH = WORD_LEN + 2 /*Lanny: for fcs_valid and fcs_error*/;
defparam rg .DEVICE_FAMILY = DEVICE_FAMILY;

// flop output from alt_e100_wide_regroup_8 logic
reg [WORDS-1:0] rx8l_fcs_valid_bits;
reg [WORDS-1:0] rx8l_fcs_error_bits;
assign rx8l_fcs_valid = |rx8l_fcs_valid_bits;
assign rx8l_fcs_error = |rx8l_fcs_error_bits;

generate
	for (i=0; i<WORDS; i=i+1) begin : split_fcs_and_data
		always @ (posedge clk_rxmac) begin
			{
			rx8l_fcs_valid_bits[i],
			rx8l_fcs_error_bits[i],
			rx8l_d [(i+1)*WORD_LEN-1 : i*WORD_LEN]
			}
			<= dout [(i+1)*(WORD_LEN+2)-1:i*(WORD_LEN+2)];
		end
	end
endgenerate

wire [6:0] rx8l_empty_tmp;
assign rx8l_empty_tmp = 7'b1000000 - {num_dout_words_valid, 3'b000} + dout_eopbits[2:0];

always @ (posedge clk_rxmac or posedge arst)
if (arst)
begin
	rx8l_sop <= 0;
	rx8l_eop <= 0;
	rx8l_empty <= 0; //7'b1000000
	
    rx8l_wrreq <= 0;
	rx8l_error <= 0;
end
else
begin
	rx8l_sop <= dout_sop;
	rx8l_eop <= dout_eopbits [3];
	rx8l_empty <= rx8l_empty_tmp[5:0];
	
    rx8l_wrreq <= (|num_dout_words_valid);
	rx8l_error <= overflow;
end

endmodule
