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


//GMII 16bit aligner.
//Author:tihgoh

module altera_tse_gmii_rx_aligner_16b(
	clk,
	reset,
	gmii_data_in,
	gmii_enable_in,
	gmii_error_in,
	gmii_data_out,
	gmii_enable_out,
	gmii_error_out

);

input clk;
input reset;
input [15:0] gmii_data_in;
input [ 1:0] gmii_enable_in;
input [ 1:0] gmii_error_in;
output reg [15:0] gmii_data_out;
output reg [ 1:0] gmii_enable_out;
output reg [ 1:0] gmii_error_out;

parameter IDLE=0;
parameter UNALIGN=1;

reg gmii_align_state;
reg [15:0] gmii_data_pipeline;
reg [ 1:0] gmii_error_pipeline;
reg [ 1:0] gmii_enable_pipeline;


always@(posedge clk or posedge reset)
begin
	if(reset) begin
		gmii_align_state <= IDLE;
	end else begin
		case(gmii_align_state)
		
		IDLE:
		begin
			if(gmii_enable_in == 2'b01) begin
				gmii_data_out <= {gmii_data_in[15:8],8'h00};
				gmii_enable_out <= {gmii_enable_in[1], gmii_enable_in[1]};
				gmii_error_out  <= {gmii_error_in[1], 1'b0};
				gmii_error_pipeline <= gmii_error_in[0];
				gmii_data_pipeline  <= gmii_data_in[7:0];
				gmii_enable_pipeline <= gmii_enable_in[0];
				gmii_align_state    <= UNALIGN;
			end else begin
				gmii_data_out <= gmii_data_in;
				gmii_error_out <= gmii_error_in;
				gmii_enable_out <= gmii_enable_in;
			end
		end
		
		UNALIGN:
		begin
			if(gmii_enable_in == 2'b00) begin
				gmii_data_out <= {gmii_data_pipeline,gmii_data_in[15:8]};
				gmii_enable_out <= 2'b10;
				gmii_error_out  <= {gmii_error_pipeline,gmii_error_in[1]};
				gmii_align_state <= IDLE;
			end else if (gmii_enable_in == 2'b10) begin
				gmii_data_out <= {gmii_data_pipeline,gmii_data_in[15:8]};
				gmii_enable_out <= 2'b11;
				gmii_error_out  <= {gmii_error_pipeline,gmii_error_in[1]};
				gmii_align_state <= IDLE;
			end else begin
				gmii_data_out <= {gmii_data_pipeline,gmii_data_in[15:8]};
				gmii_enable_out <= {gmii_enable_pipeline, gmii_enable_in[1]};
				gmii_error_out  <= {gmii_error_pipeline,gmii_error_in[1]};
				gmii_error_pipeline <= gmii_error_in[0];
				gmii_data_pipeline  <= gmii_data_in[7:0];
				gmii_enable_pipeline <= gmii_enable_in[0];
			end
		end 
		
		endcase
	end

end

endmodule //module altera_tse_gmii_aligner_16b
