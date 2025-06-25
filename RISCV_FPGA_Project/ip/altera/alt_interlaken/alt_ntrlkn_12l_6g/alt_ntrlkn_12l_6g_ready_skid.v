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

// baeckler - 11-06-2008
// pipeline for ready / valid data

module alt_ntrlkn_12l_6g_ready_skid #(
	parameter WIDTH = 16
)
(
	input clk,arst,

	input valid_i,
	input [WIDTH-1:0] dat_i,
	output reg ready_i,

	output reg valid_o,
	output reg [WIDTH-1:0] dat_o,
	input ready_o
);

reg [WIDTH-1:0] backup_storage;
reg backup_valid;

// duplicate control registers to mitigate
// high fanout loading.
reg internal_valid_o /* synthesis preserve */;
reg internal_ready_i /* synthesis preserve */;

// simulation only sanity check
// synthesis translate off
always @(posedge clk) begin
	if ((ready_i != internal_ready_i) ||
		(valid_o != internal_valid_o)) begin
		$display ("Error: Duplicate internal regs out of sync");
	end
end
// synthesis translate on

always @(posedge clk or posedge arst) begin
	if (arst) begin
		ready_i <= 1'b0;
		internal_ready_i <= 1'b0;
		valid_o <= 1'b0;
		internal_valid_o <= 1'b0;
		dat_o <= {WIDTH{1'b0}};
		backup_storage <= {WIDTH{1'b0}};
		backup_valid <= 1'b0;
	end
	else begin
		ready_i <= ready_o;
		internal_ready_i <= ready_o;

		if (internal_valid_o & ready_o) begin
			// main data is leaving to the sink
			if (backup_valid) begin
				// dump the backup word to main storage
				backup_valid <= 1'b0;
				dat_o <= backup_storage;
				valid_o <= 1'b1;
				internal_valid_o <= 1'b1;
                                // synthesis translate off
				if (ready_i && valid_i) begin
                                  $display ("ERROR: data lost in skid buffer");
				end
                                // synthesis translate on
			end
			else begin
				// if not overwritten below, you are done.
				valid_o <= 1'b0;
				internal_valid_o <= 1'b0;
			end
		end

		if (internal_ready_i && valid_i) begin
			// must accept data from source
			if (ready_o || !internal_valid_o) begin
				// accept to main registers
				valid_o <= 1'b1;
				internal_valid_o <= 1'b1;
				dat_o <= dat_i;
			end
			else begin
				// accept to backup storage
				backup_valid <= 1'b1;
				backup_storage <= dat_i;
				ready_i <= 1'b0; // stop stop!
				internal_ready_i <= 1'b0;
			end
		end
	end
end

endmodule
