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


module dqsagent(
	clk,
	reset_n,
	dqs_in,
	dqs_in_n,
	dqs_out,
	dqs_out_n,
	dq,
	dqs_write,
	dqs_read,
	side_write,
	side_writedata,
	side_read,
	side_readdata,
	side_readdata_valid,
	force_read_error,
	output_enable_out
);

parameter DATA_WIDTH = 1;
parameter SIDE_DATA_WIDTH = 2;
parameter FIFO_ADDR_WIDTH = 3;
parameter DQS_READ_LATENCY = 1;
parameter DQS_WRITE_LATENCY = 1;
parameter HALF_RATE_CIRCUITRY = "false";

localparam FIFO_DEPTH = 2 ** FIFO_ADDR_WIDTH;

input clk;
input reset_n;
input dqs_in;
input dqs_in_n;
output dqs_out;
output dqs_out_n;
inout [DATA_WIDTH - 1 : 0] dq;
input dqs_write;
input dqs_read;
input side_write;
input [SIDE_DATA_WIDTH - 1 : 0] side_writedata;
input side_read;
output [SIDE_DATA_WIDTH - 1 : 0] side_readdata;
output side_readdata_valid;
input force_read_error;
output output_enable_out;

reg [2 * DATA_WIDTH - 1 : 0] fifo [ 0 : FIFO_DEPTH - 1];
reg [FIFO_ADDR_WIDTH - 1 : 0] wradd;
reg [FIFO_ADDR_WIDTH - 1 : 0] rdadd;
reg [2 * DATA_WIDTH - 1 : 0] capture_reg;
reg [DATA_WIDTH - 1 : 0] capture_reg_tmp;
reg [2 * DATA_WIDTH - 1 : 0] read_data;
wire [DATA_WIDTH -1 : 0] read_data_ddio;
wire side_read_extended;

wire wrena;
reg [DQS_WRITE_LATENCY - 1 : 0] wrena_reg;
wire rdena;
reg [DQS_READ_LATENCY - 1 : 0] rdena_reg;
reg side_read_reg;
wire output_enable = rdena;
assign output_enable_out = output_enable | rdena_reg[DQS_READ_LATENCY - 2];

assign dqs_out = clk;
assign dqs_out_n = ~clk;

assign dq = (output_enable === 1'b1) ? read_data_ddio : {DATA_WIDTH{1'bz}};

genvar i;

generate
begin : wrlat
	assign wrena = wrena_reg[DQS_WRITE_LATENCY - 1];
	always @(posedge clk or negedge reset_n) begin
		if(~reset_n) begin
			wrena_reg[0] <= 0;
		end
		else begin
			wrena_reg[0] <= dqs_write;
		end
	end
	for(i = 1; i < DQS_WRITE_LATENCY; i = i + 1) begin
		always @(posedge clk or negedge reset_n) begin
			if(~reset_n) begin
				wrena_reg[i] <= 0;
			end
			else begin
				wrena_reg[i] <= wrena_reg[i - 1];
			end
		end
	end
end
endgenerate

generate
begin : rdlat
	assign rdena = rdena_reg[DQS_READ_LATENCY - 1];
	always @(posedge clk) begin
		rdena_reg[0] <= dqs_read;
	end
	for(i = 1; i < DQS_READ_LATENCY; i = i + 1) begin
		always @(posedge clk) begin
			rdena_reg[i] <= rdena_reg[i - 1];
		end
	end
end
endgenerate

always @ (posedge clk or negedge reset_n) begin
	if(~reset_n) begin
		wradd <= 0;
		rdadd <= 0;
	end
	else begin
		if(wrena | side_write) begin
			wradd <= wradd + 1'b1;
		end

		if(rdena | side_readdata_valid) begin
			rdadd <= rdadd + 1'b1;
		end

		if(wrena) begin
			fifo[wradd] <= capture_reg;
		end
		else if(side_write) begin
			fifo[wradd] <= side_writedata;
		end
	end
end

generate
begin : creg
	for(i = 0; i < DATA_WIDTH; i = i + 1) begin
		always @(posedge dqs_in) begin
			capture_reg_tmp[i] <= dq[i];
		end
		always @(negedge dqs_in) begin
			capture_reg[i] <= capture_reg_tmp[i];
			capture_reg[i + DATA_WIDTH] <= dq[i];
		end
	end
end
endgenerate

assign read_data = fifo[rdadd];
assign read_data_ddio = dqs_out ? read_data[DATA_WIDTH - 1 : 0] : read_data[2 * DATA_WIDTH - 1 : DATA_WIDTH];

assign side_readdata = force_read_error ? ~read_data : read_data;
assign side_readdata_valid = side_read;

endmodule
