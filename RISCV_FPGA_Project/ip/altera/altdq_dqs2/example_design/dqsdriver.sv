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



module dqsdriver (
	clk,
	clk_hr,
	reset_n,
	core_reset_n,
	enable,
	dqs_enable,
	dqs_write,
	dqs_writedata,
	dqs_read,
	dqs_readdata,
	dqs_readdata_valid,
	oct_enable,
	side_write,
	side_writedata,
	side_read,
	side_readdata,
	side_readdata_valid,
	vfifo_inc,
	dqs_in
);

parameter PIN_WIDTH = 1;
parameter OUTPUT_MULT = 2;
parameter CHECK_FIFO_DEPTH_LOG_2 = 4;
parameter HALF_RATE_CIRCUITRY = "false";
parameter DQS_READ_LATENCY = 2;
parameter USE_BIDIR_STROBE = "false";
localparam CHECK_FIFO_DEPTH = 2 ** CHECK_FIFO_DEPTH_LOG_2;
localparam VERBOSE = 1;
localparam DATA_WIDTH = OUTPUT_MULT * PIN_WIDTH * 2;
localparam HALF_DATA_WIDTH = OUTPUT_MULT * PIN_WIDTH;

input clk_hr;
input clk;
input reset_n;
output core_reset_n;
input enable;
output dqs_enable;
output dqs_write;
output [DATA_WIDTH - 1 : 0] dqs_writedata;
output dqs_read;
input [DATA_WIDTH - 1 : 0] dqs_readdata;
input dqs_readdata_valid;
output oct_enable;
output side_write;
output [DATA_WIDTH - 1 : 0] side_writedata;
output side_read;
input [DATA_WIDTH - 1 : 0] side_readdata;
input side_readdata_valid;
output vfifo_inc;
input dqs_in;

reg SIMULATION_ERROR;
reg [DATA_WIDTH - 1 : 0] capture_reg;
reg [HALF_DATA_WIDTH - 1 : 0] capture_reg_tmp;
reg [DATA_WIDTH - 1 : 0] side_readdata_reg;
reg side_readdata_valid_reg;
wire side_readdata_valid_wire = (HALF_RATE_CIRCUITRY == "true")? side_readdata_valid_reg : side_readdata_valid;
wire [DATA_WIDTH - 1 : 0] side_readdata_wire = (HALF_RATE_CIRCUITRY == "true")? side_readdata_reg : side_readdata;

typedef enum int unsigned {
	STATE_FETCH,
	STATE_DEC,
	STATE_EXEC
} DQSDRIVERSTATE_T;

DQSDRIVERSTATE_T state;

`include "./example_design/dqsdriver_microcode.sv"

reg [7:0] PC;

reg [DATA_WIDTH - 1 : 0] check_fifo [0 : CHECK_FIFO_DEPTH - 1];
reg [CHECK_FIFO_DEPTH - 1 : 0] check_fifo_radd;
reg [CHECK_FIFO_DEPTH - 1 : 0] check_fifo_wadd;


reg [15:0] cmd;

wire [3:0] inst = cmd[3:0];

wire inst_nope = (inst == 4'b0000);

wire [3:0] read_write_bl = cmd[15:12];
wire [3:0] calib_length = cmd[15:12];
reg [3:0] burst_counter;
reg [3:0] calib_counter;
reg dqs_preamble_counter;

wire inst_write = (inst == 4'b0001);
wire [1:0] write_type = cmd[5:4];
wire write_type_sequential = (write_type == 2'b00);
wire write_type_random = (write_type == 2'b01);
wire write_dqs_channel = ~cmd[6];
wire write_side_channel = cmd[6];
reg [DATA_WIDTH - 1 : 0] write_data_counter;
reg [DATA_WIDTH - 1 : 0] write_data_random;
wire [DATA_WIDTH - 1 : 0] write_data = 
	(write_type_sequential) ? write_data_counter : 
	(write_type_random) ? write_data_random : {DATA_WIDTH{1'b0}};

wire inst_read = (inst == 4'b0010);
wire read_skip_comparison = cmd[5];
wire read_dqs_channel = ~cmd[6];
wire read_side_channel = cmd[6];

wire inst_exit = (inst == 4'b1111);

wire inst_calib = (inst == 4'b0011);

wire exec_done =
	inst_nope |
	((inst_write | inst_read) & (burst_counter == 0)) |
	(inst_calib & (calib_counter == 0));

initial begin
	SIMULATION_ERROR = 0;
end

wire driver_clk = (HALF_RATE_CIRCUITRY == "true") ? clk_hr : clk;


always @(posedge driver_clk or negedge reset_n) begin
	if(~reset_n) begin
		PC <= 0;
		state <= STATE_FETCH;
		cmd <= 0;
		burst_counter <= 0;
		calib_counter <= 0;
		write_data_counter <= 0;
		write_data_random <= 0;
		check_fifo_radd <= 0;
		check_fifo_wadd <= 0;
		side_readdata_valid_reg <= 0;
		side_readdata_reg <= 0;
		dqs_preamble_counter <= 0;
	end
	else if (enable)
	begin
		side_readdata_valid_reg <= side_readdata_valid;
		side_readdata_reg <= capture_reg;
		
		case(state)
			STATE_FETCH: begin
				state <= STATE_DEC;
				cmd <= microcode[PC];
				PC <= PC + 1;
			end

			STATE_DEC: begin
				if(inst_write | inst_read) begin
					burst_counter <= read_write_bl;
				end
				
				if(inst_write) begin
					dqs_preamble_counter <= 1;
				end

				if(inst_calib) begin
					calib_counter <= calib_length;
				end

				state <= STATE_EXEC;
			end

			STATE_EXEC: begin
				if(exec_done) begin
					state <= STATE_FETCH;
				end

				if(inst_exit) begin
					if(SIMULATION_ERROR) begin
						$display("Simulation ERROR");
					end
					else begin
						$display("Simulation SUCCESS");
					end

					$finish;
				end

				if(inst_write && ~exec_done) begin
					if(write_type_sequential) begin
						write_data_counter <= write_data_counter + 1;
					end
					if(write_type_random) begin
						write_data_random <= $random;
					end
				end

				if (dqs_preamble_counter > 0) begin
					burst_counter <= burst_counter;
				end
				else begin
					burst_counter <= burst_counter - 1'b1;
				end
				
				calib_counter <= calib_counter - 1'b1;
				
				if (dqs_preamble_counter > 0) begin
					dqs_preamble_counter <= dqs_preamble_counter - 1'b1;
				end
			end
		endcase
	end
end

wire [DATA_WIDTH - 1 : 0] readdata = 
	dqs_readdata_valid === 1'b1 ? dqs_readdata : 
	side_readdata_valid_wire ? side_readdata_wire : {DATA_WIDTH{1'bz}};
wire [DATA_WIDTH - 1 : 0] check_fifo_data = check_fifo[check_fifo_radd];
always @(posedge driver_clk) begin
	if((dqs_readdata_valid | side_readdata_valid_wire) & ~read_skip_comparison) begin
		if(check_fifo_data !== readdata) begin
			$display("Error during comparison at time %t", $time);
			$display("   Expected %x", check_fifo_data);
			$display("   Received %x", readdata);
			SIMULATION_ERROR = 1;
		end
		else begin
			if(VERBOSE) begin
				if(dqs_readdata_valid) begin
					$display("   [%0t] DQS READ: %x", $time, readdata);
				end
				if(side_readdata_valid_wire) begin
					$display("   [%0t] SIDE READ: %x", $time, readdata);
				end
			end
		end
		check_fifo_radd <= check_fifo_radd + 1'b1;
	end
	if(side_write | dqs_write) begin
		check_fifo[check_fifo_wadd] <= write_data;
		check_fifo_wadd <= check_fifo_wadd + 1'b1;

		if(VERBOSE) begin
			if(dqs_write) begin
				$display("   [%0t] DQS WRITE: %x", $time, write_data);
			end
			if(side_write) begin
				$display("   [%0t] SIDE WRITE: %x", $time, write_data);
			end
		end
	end
end

reg side_writedata_to_fr ;
always @(posedge clk or negedge reset_n) begin
	if(~reset_n) begin
		side_writedata_to_fr  <= 1'b0;
	end
	else begin
		side_writedata_to_fr  <= ~side_writedata_to_fr ;
	end
end
wire [HALF_DATA_WIDTH - 1 : 0] side_writedata_fr = side_writedata_to_fr ? write_data[HALF_DATA_WIDTH - 1 : 0] :
												write_data[2 * HALF_DATA_WIDTH - 1 : HALF_DATA_WIDTH];

assign side_write = (state == STATE_EXEC) & inst_write & write_side_channel & (burst_counter > 0);
assign dqs_write = (state == STATE_EXEC) & inst_write & write_dqs_channel & (burst_counter > 0) & (dqs_preamble_counter == 0);
assign side_writedata = (HALF_RATE_CIRCUITRY == "true")? side_writedata_fr : write_data;
assign dqs_writedata = write_data;
assign dqs_enable = (state == STATE_EXEC) & inst_write & write_dqs_channel;

assign side_read = (state == STATE_EXEC) & inst_read & read_side_channel & (burst_counter > 0);
assign dqs_read = (state == STATE_EXEC) & inst_read & read_dqs_channel & (burst_counter > 0);

assign vfifo_inc = (state == STATE_EXEC) & inst_calib & (calib_counter > 0);

genvar i;
generate
begin : creg
	for(i = 0; i < HALF_DATA_WIDTH; i = i + 1) begin
		always @(posedge clk) begin
			capture_reg_tmp[i] = side_readdata[i];
		end
		always @(negedge clk) begin
			capture_reg[i] = capture_reg_tmp[i];
			capture_reg[i + HALF_DATA_WIDTH] = side_readdata[i];
		end
	end
end
endgenerate

localparam READ_LATENCY = (HALF_RATE_CIRCUITRY == "true" ? (DQS_READ_LATENCY / 2) - 1 : DQS_READ_LATENCY);
reg read_latency [READ_LATENCY - 1 : 0];
always @(posedge driver_clk or negedge reset_n)
begin
	if (~reset_n)
	begin
		read_latency <= '{READ_LATENCY{1'b0}};
	end
	else
	begin
		read_latency[0] <= dqs_read;
		read_latency[READ_LATENCY - 1 : 1] <= read_latency[READ_LATENCY - 2 : 0];
	end
end
assign oct_enable = read_latency[READ_LATENCY - 1] | read_latency[READ_LATENCY - 2];

reg [2:0] core_reset_n_shiftreg;
always @(posedge driver_clk or negedge reset_n)
begin
	if (~reset_n)
	begin
		core_reset_n_shiftreg <= 3'b000;
	end
	else
	begin
		core_reset_n_shiftreg <= {core_reset_n_shiftreg[1:0], 1'b1};
	end
end
assign core_reset_n = core_reset_n_shiftreg[2];

endmodule
