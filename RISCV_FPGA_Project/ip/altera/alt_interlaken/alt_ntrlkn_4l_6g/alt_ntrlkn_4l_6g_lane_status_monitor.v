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

// baeckler - 10-27-2008

module alt_ntrlkn_4l_6g_lane_status_monitor #(
	parameter WIDTH = 4,
	parameter SYNC_STAGES = 3 // not less than 2
)
(
	input common_clk,
	input common_arst,
	input [WIDTH-1:0] lane_clk,
	input [WIDTH-1:0] lane_arst,

	// these are on the lane clock domains
	input [WIDTH-1:0] word_locked,
	input [WIDTH-1:0] sync_locked,
	input [WIDTH-1:0] framing_error,
	input [WIDTH-1:0] crc32_error,
	input [WIDTH-1:0] scrambler_mismatch,
	input [WIDTH-1:0] missing_sync,

	// raw signals on the common clock domain
	output [WIDTH-1:0] s_word_locked,
	output [WIDTH-1:0] s_sync_locked,
	output [WIDTH-1:0] s_framing_error,
	output [WIDTH-1:0] s_crc32_error,
	output [WIDTH-1:0] s_scrambler_mismatch,
	output [WIDTH-1:0] s_missing_sync,

	output reg all_word_locked,
	output reg all_sync_locked,
	output [WIDTH*8-1:0] crc32_err_cntrs
);


////////////////////////////////////////
// register for crossing, XOR pulsed signals

reg [WIDTH-1:0] word_locked_d
   /* synthesis ALTERA_ATTRIBUTE = "SUPPRESS_DA_RULE_INTERNAL=D102"  */;
reg [WIDTH-1:0] sync_locked_d
   /* synthesis ALTERA_ATTRIBUTE = "SUPPRESS_DA_RULE_INTERNAL=D102"  */;
reg [WIDTH-1:0] crc32_error_d
   /* synthesis ALTERA_ATTRIBUTE = "SUPPRESS_DA_RULE_INTERNAL=D102"  */;
reg [WIDTH-1:0] framing_error_d, scrambler_mismatch_d, missing_sync_d;

genvar i;
generate
for (i=0; i<WIDTH; i=i+1)
begin : src
	always @(posedge lane_clk[i] or posedge lane_arst[i]) begin
		if (lane_arst[i]) begin
			word_locked_d[i] <= 1'b0;
			sync_locked_d[i] <= 1'b0;
			framing_error_d[i] <= 1'b0;
			crc32_error_d[i] <= 1'b0;
			scrambler_mismatch_d[i] <= 1'b0;
			missing_sync_d[i] <= 1'b0;
		end
		else begin
			// steady signals
			word_locked_d[i] <= word_locked[i];
			sync_locked_d[i] <= sync_locked[i];

			// pulsed signals
			framing_error_d[i] <= framing_error_d[i] ^ framing_error[i];
			crc32_error_d[i] <= crc32_error_d[i] ^ crc32_error[i];
			scrambler_mismatch_d[i] <= scrambler_mismatch_d[i] ^ scrambler_mismatch[i];
			missing_sync_d[i] <= missing_sync_d[i] ^ missing_sync[i];
		end
	end
end
endgenerate

////////////////////////////////////////
// cross and meta harden

reg [SYNC_STAGES * WIDTH-1:0] word_locked_c /* synthesis preserve */
	/* synthesis ALTERA_ATTRIBUTE = "-name SDC_STATEMENT \"set_false_path -to [get_keepers *lane_status_monitor*word_locked_c\[*\]]\" " */;

reg [SYNC_STAGES * WIDTH-1:0] sync_locked_c /* synthesis preserve */
	/* synthesis ALTERA_ATTRIBUTE = "-name SDC_STATEMENT \"set_false_path -to [get_keepers *lane_status_monitor*sync_locked_c\[*\]]\" " */;

reg [(SYNC_STAGES+1) * WIDTH-1:0] framing_error_c /* synthesis preserve */;

reg [(SYNC_STAGES+1) * WIDTH-1:0] crc32_error_c /* synthesis preserve */
	/* synthesis ALTERA_ATTRIBUTE = "-name SDC_STATEMENT \"set_false_path -to [get_keepers *lane_status_monitor*crc32_error_c\[*\]]\" " */;

reg [(SYNC_STAGES+1) * WIDTH-1:0] scrambler_mismatch_c /* synthesis preserve */;
reg [(SYNC_STAGES+1) * WIDTH-1:0] missing_sync_c /* synthesis preserve */;

always @(posedge common_clk or posedge common_arst) begin
	if (common_arst) begin
		word_locked_c <= {SYNC_STAGES*WIDTH{1'b0}};
		sync_locked_c <= {SYNC_STAGES*WIDTH{1'b0}};
		framing_error_c <= {(SYNC_STAGES+1)*WIDTH{1'b0}};
		crc32_error_c <= {(SYNC_STAGES+1)*WIDTH{1'b0}};
		scrambler_mismatch_c <= {(SYNC_STAGES+1)*WIDTH{1'b0}};
		missing_sync_c <= {(SYNC_STAGES+1)*WIDTH{1'b0}};
	end
	else begin
		// steady signals
		word_locked_c <= {word_locked_c[(SYNC_STAGES-1)*WIDTH-1:0],word_locked_d};
		sync_locked_c <= {sync_locked_c[(SYNC_STAGES-1)*WIDTH-1:0],sync_locked_d};

		// pulsed signals - grab one extra layer of registers for XOR
		framing_error_c <= {framing_error_c[(SYNC_STAGES)*WIDTH-1:0],framing_error_d};
		crc32_error_c <= {crc32_error_c[(SYNC_STAGES)*WIDTH-1:0],crc32_error_d};
		scrambler_mismatch_c <= {scrambler_mismatch_c[(SYNC_STAGES)*WIDTH-1:0],scrambler_mismatch_d};
		missing_sync_c <= {missing_sync_c[(SYNC_STAGES)*WIDTH-1:0],missing_sync_d};
	end
end

////////////////////////////////////////
// pull out the good bits

assign s_word_locked = word_locked_c[(SYNC_STAGES)*WIDTH-1:(SYNC_STAGES-1)*WIDTH];
assign s_sync_locked = sync_locked_c[(SYNC_STAGES)*WIDTH-1:(SYNC_STAGES-1)*WIDTH];

// pulsed signals - grab one extra layer of registers for XOR
assign s_framing_error =
				framing_error_c[(SYNC_STAGES+1)*WIDTH-1:(SYNC_STAGES)*WIDTH] ^
				framing_error_c[(SYNC_STAGES)*WIDTH-1:(SYNC_STAGES-1)*WIDTH];
assign s_crc32_error =
				crc32_error_c[(SYNC_STAGES+1)*WIDTH-1:(SYNC_STAGES)*WIDTH] ^
				crc32_error_c[(SYNC_STAGES)*WIDTH-1:(SYNC_STAGES-1)*WIDTH];
assign s_scrambler_mismatch =
				scrambler_mismatch_c[(SYNC_STAGES+1)*WIDTH-1:(SYNC_STAGES)*WIDTH] ^
				scrambler_mismatch_c[(SYNC_STAGES)*WIDTH-1:(SYNC_STAGES-1)*WIDTH];
assign s_missing_sync =
				missing_sync_c[(SYNC_STAGES+1)*WIDTH-1:(SYNC_STAGES)*WIDTH] ^
				missing_sync_c[(SYNC_STAGES)*WIDTH-1:(SYNC_STAGES-1)*WIDTH];

////////////////////////////////////////
// interpret some more info

// aggregated locked signals
always @(posedge common_clk or posedge common_arst) begin
	if (common_arst) begin
		all_word_locked <= 1'b0;
		all_sync_locked <= 1'b0;
	end
	else begin
		all_word_locked <= &s_word_locked;
		all_sync_locked <= &s_sync_locked;
	end
end

// tally of CRC32 errors by lane
generate
	for (i=0; i<WIDTH; i=i+1) begin : crc32cnt
		reg [7:0] crccntr;
		always @(posedge common_clk or posedge common_arst) begin
			if (common_arst) begin
				crccntr <= {8{1'b0}};
			end
			else if (s_crc32_error[i]) begin
				crccntr <= crccntr + 1'b1;
			end
		end
		assign crc32_err_cntrs[(i+1)*8-1:i*8] = crccntr;
	end
endgenerate

endmodule
