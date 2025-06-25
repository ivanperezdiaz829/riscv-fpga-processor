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

(* altera_attribute = "-name IP_TOOL_NAME altera_mem_if_rldram3_controller; -name IP_TOOL_VERSION 13.1; -name FITTER_ADJUST_HC_SHORT_PATH_GUARDBAND 100" *)
module alt_rld3_controller_top_ctl_bl_is_one_dec_lat (
	afi_clk,
	afi_reset_n,
	avl_ready,
	avl_write_req,
	avl_read_req,
	avl_addr,
	avl_size,
	avl_wdata,
	avl_rdata_valid,
	avl_rdata,
	afi_addr,
	afi_ba,
	afi_cs_n,
	afi_we_n,
	afi_ref_n,
	afi_rst_n,
	afi_wdata_valid,
	afi_wdata,
	afi_dm,
	afi_rdata_en,
	afi_rdata_en_full,
	afi_rdata,
	afi_rdata_valid,
	afi_wlat,
	afi_rlat,
	afi_cal_success,
	afi_cal_fail,
	local_init_done,
	local_cal_success,
	local_cal_fail
);

//////////////////////////////////////////////////////////////////////////////
// BEGIN PARAMETER SECTION

parameter DEVICE_FAMILY							= "";

parameter MEM_IF_CS_WIDTH						= 0;
// MEMORY TIMING PARAMETERS
// Bank cycle time in memory cycles
parameter MEM_T_RC								= 0;
// Write latency in memory cycles
parameter MEM_T_WL								= 0;
// Refresh interval in memory cycles
parameter MEM_T_REFI							= 0;
// Refresh interval in controller cycles
parameter CTL_T_REFI							= 0;
// DQ bus turnaround time in memory cycles
// In half rate (AFI_RATE_RATIO=2), these values are rounded up to the next odd number
parameter MEM_BUS_TURNAROUND_CYCLES_RD_TO_WR	= 0;
parameter MEM_BUS_TURNAROUND_CYCLES_WR_TO_RD	= 0;

// The memory burst length
parameter MEM_BURST_LENGTH						= 0;

// AFI 2.0 INTERFACE PARAMETERS
parameter AFI_WLAT_WIDTH                        = 0;
parameter AFI_RLAT_WIDTH                        = 0;
parameter AFI_ADDR_WIDTH						= 0;
parameter AFI_BANKADDR_WIDTH					= 0;
parameter AFI_CONTROL_WIDTH						= 0;
parameter AFI_CS_WIDTH							= 0;
parameter AFI_DM_WIDTH							= 0;
parameter AFI_DQ_WIDTH							= 0;
parameter AFI_WRITE_DQS_WIDTH 					= 0;
parameter AFI_RATE_RATIO    					= 0;

// CONTROLLER PARAMETERS
// For a half rate controller (AFI_RATE_RATIO=2), the burst length in the controller - equals memory burst length / 4
// For a full rate controller (AFI_RATE_RATIO=1), the burst length in the controller - equals memory burst length / 2
parameter CTL_BURST_LENGTH						= 0;
parameter CTL_ADDR_WIDTH						= 0;
parameter CTL_CHIPADDR_WIDTH					= 0;
parameter CTL_BANKADDR_WIDTH					= 0;
parameter CTL_BEATADDR_WIDTH					= 0;
parameter CTL_CONTROL_WIDTH						= 0;
parameter CTL_CS_WIDTH							= 0;

// AVALON INTERFACE PARAMETERS
parameter AVL_ADDR_WIDTH						= 0;
parameter AVL_SIZE_WIDTH						= 0;
parameter AVL_DATA_WIDTH						= 0;
parameter AVL_NUM_SYMBOLS						= 0;

parameter HR_DDIO_OUT_HAS_THREE_REGS			= 0;

// END PARAMETER SECTION
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// BEGIN PORT SECTION

// Clock and reset interface
input								afi_clk;
input								afi_reset_n;

// Avalon data slave interface
output								avl_ready;
input								avl_write_req;
input								avl_read_req;
input	[AVL_ADDR_WIDTH-1:0]		avl_addr;
input	[AVL_SIZE_WIDTH-1:0]		avl_size;
input	[AVL_DATA_WIDTH-1:0]			avl_wdata;
output								avl_rdata_valid;
output	[AVL_DATA_WIDTH-1:0]			avl_rdata;

// AFI 2.0 interface
input   [AFI_WLAT_WIDTH-1:0]        afi_wlat;
input   [AFI_RLAT_WIDTH-1:0]        afi_rlat;
output	[AFI_ADDR_WIDTH-1:0]		afi_addr;
output	[AFI_BANKADDR_WIDTH-1:0]	afi_ba;
output	[AFI_CS_WIDTH-1:0]			afi_cs_n;
output	[AFI_CONTROL_WIDTH-1:0]		afi_we_n;
output	[AFI_CONTROL_WIDTH-1:0]		afi_ref_n;
output	[AFI_CONTROL_WIDTH-1:0]		afi_rst_n;
output	[AFI_WRITE_DQS_WIDTH-1:0]	afi_wdata_valid;
output	[AFI_DQ_WIDTH-1:0]			afi_wdata;
output	[AFI_DM_WIDTH-1:0]			afi_dm;

output	[AFI_RATE_RATIO-1:0]		afi_rdata_en;
output	[AFI_RATE_RATIO-1:0]		afi_rdata_en_full;

input	[AFI_DQ_WIDTH-1:0]			afi_rdata;
input	[AFI_RATE_RATIO-1:0]		afi_rdata_valid;
input								afi_cal_success;
input								afi_cal_fail;
output								local_init_done;
output								local_cal_success;
output								local_cal_fail;

// END PORT SECTION
//////////////////////////////////////////////////////////////////////////////

wire force_error;

`ifdef ENABLE_ISS_PROBES
iss_source #(
	.WIDTH(1)
) iss_driver_force_error (
	.source(force_error)
);
`else
assign force_error = 1'b0;
`endif






assign local_cal_success = afi_cal_success;
assign local_cal_fail = afi_cal_fail;


enum {
	INIT_WRITES,                          
	ISSUE_WRITE_0,
	ISSUE_WRITE_1,
	WAIT_WRITE,
	WRITE_WAIT_TRC,
	NEXT_WRITE_LOOP,
	INIT_READS,
	ISSUE_READ_0,
	WAIT_READ_0,
	READ_DATA_0,
	ISSUE_READ_1,
	WAIT_READ_1,
	READ_DATA_1,
	READ_WAIT_TRC,
	NEXT_BANK_SET,
	NEXT_READ_LOOP,
	FAILED,
	DONE                           
} state;

localparam TRC_COUNTER_WIDTH = 4;                           
localparam MAX_AFI_WLAT = 10;                               
localparam LOOP_COUNTER_WIDTH = AFI_RATE_RATIO * 2;   
localparam DQ_DDR_WIDTH = AFI_DQ_WIDTH / AFI_RATE_RATIO;
localparam BANKS_PER_WRITE = 1; 

reg [MAX_AFI_WLAT-1:0] write_latency_shifter0;
reg [MAX_AFI_WLAT-1:0] write_latency_shifter1;

reg [LOOP_COUNTER_WIDTH-1:0] loop_counter;
reg [TRC_COUNTER_WIDTH-1:0] trc_counter;

reg [3:0] bank_counter;

wire [AFI_DQ_WIDTH-1:0] expected_afi_rdata;
wire [AFI_DQ_WIDTH-1:0] masked_afi_rdata;

always_ff @(posedge afi_clk, negedge afi_reset_n)
begin
	if (! afi_reset_n) begin
		state <= INIT_WRITES;
	end else begin
		case(state)
			INIT_WRITES:
				if (afi_cal_success) 
					state <= ISSUE_WRITE_0;
			ISSUE_WRITE_0:
				state <= ISSUE_WRITE_1;
			ISSUE_WRITE_1:
				state <= WAIT_WRITE;
			WAIT_WRITE:
				if (write_latency_shifter0 == '0 && write_latency_shifter1 == '0)
					state <= WRITE_WAIT_TRC;
			WRITE_WAIT_TRC:
				if (trc_counter[TRC_COUNTER_WIDTH-1] == 1)
					if (loop_counter == 0)
						state <= INIT_READS;
					else
						state <= NEXT_WRITE_LOOP;
			NEXT_WRITE_LOOP:
				state <= ISSUE_WRITE_0;
			INIT_READS:
				state <= ISSUE_READ_0;
			ISSUE_READ_0:
				state <= ISSUE_READ_1;
			ISSUE_READ_1:
				state <= WAIT_READ_0;
			WAIT_READ_0:
				if (|afi_rdata_valid) 
					state <= (expected_afi_rdata == masked_afi_rdata) ? WAIT_READ_1 : FAILED;
			WAIT_READ_1:
				if (|afi_rdata_valid) 
					if (expected_afi_rdata == masked_afi_rdata)
						state <= READ_WAIT_TRC;
					else 
						state <= FAILED;
				else
					state <= READ_WAIT_TRC;
			READ_WAIT_TRC:
				if (trc_counter[TRC_COUNTER_WIDTH-1] == 1)
					if (bank_counter > 0)
						state <= NEXT_BANK_SET;
					else
						if (loop_counter == 0)
							state <= DONE;
						else
							state <= NEXT_READ_LOOP;
			NEXT_BANK_SET:
				state <= ISSUE_READ_0;			
			NEXT_READ_LOOP:
				state <= ISSUE_READ_0;
			DONE:
				begin
				state <= (force_error ? FAILED : DONE);
				//synthesis translate_off
				$display("          --- SIMULATION PASSED --- ");
				$finish;
				//synthesis translate_on
				end
			FAILED:
				begin
				state <= FAILED;
				//synthesis translate_off
				$display("          --- SIMULATION FAILED --- ");
				$finish;
				//synthesis translate_on
				end
			default:
				state <= INIT_WRITES;
		endcase
	end
end

always_ff @(posedge afi_clk, negedge afi_reset_n)
begin
	if (! afi_reset_n) begin
		write_latency_shifter0 <= '0;
		write_latency_shifter1 <= '0;
	end else begin
		if (state == ISSUE_WRITE_0) begin
			write_latency_shifter0[afi_wlat-1] <= 1'b1;
		end else begin
			write_latency_shifter0 <= {1'b0, write_latency_shifter0[MAX_AFI_WLAT-1:1]};
		end
		
		if (state == ISSUE_WRITE_1) begin
			write_latency_shifter1[afi_wlat-1] <= 1'b1;
		end else begin
			write_latency_shifter1 <= {1'b0, write_latency_shifter1[MAX_AFI_WLAT-1:1]};
		end
	end
end

always_ff @(posedge afi_clk)
begin
	if (state == INIT_WRITES || state == INIT_READS) 
		loop_counter <= '1 - 1;
	else if (state == NEXT_WRITE_LOOP || state == NEXT_READ_LOOP) 
		loop_counter <= loop_counter - 1;
end

always_ff @(posedge afi_clk)
begin
	if (state == WAIT_WRITE || state == WAIT_READ_1) 
		trc_counter <= 0;
	else
		trc_counter <= trc_counter + 1;
end

always_ff @(posedge afi_clk)
begin
	if (state == INIT_WRITES)
		bank_counter <= '0;
	else if (state == INIT_READS || state == NEXT_READ_LOOP)
		bank_counter <= BANKS_PER_WRITE - 1;
	else if (state == NEXT_BANK_SET)
		bank_counter <= bank_counter - 1;
end


wire [AFI_RATE_RATIO*2-1:0] cmd;
wire [AFI_RATE_RATIO*2-1:0] cmd_data_en;

wire [AFI_RATE_RATIO-1:0] cmd_0 = cmd[AFI_RATE_RATIO-1:0];
wire [AFI_RATE_RATIO-1:0] cmd_1 = cmd[AFI_RATE_RATIO*2-1:AFI_RATE_RATIO];

wire [AFI_RATE_RATIO-1:0] cmd_0_data_en = cmd_data_en[AFI_RATE_RATIO-1:0];
wire [AFI_RATE_RATIO-1:0] cmd_1_data_en = cmd_data_en[AFI_RATE_RATIO*2-1:AFI_RATE_RATIO];

wire issue_cmd_0 = (state == ISSUE_WRITE_0 || state == ISSUE_READ_0);
wire issue_cmd_1 = (state == ISSUE_WRITE_1 || state == ISSUE_READ_1);

wire [AFI_WRITE_DQS_WIDTH-1:0] cmd_0_afi_wdata_valid;
wire [AFI_WRITE_DQS_WIDTH-1:0] cmd_1_afi_wdata_valid;

assign afi_ref_n = '1;

assign afi_rst_n = '1;
				
assign afi_addr = {AFI_RATE_RATIO{
	{((AFI_ADDR_WIDTH/AFI_RATE_RATIO)-LOOP_COUNTER_WIDTH){1'b0}},
	loop_counter}};

assign afi_wdata = {(AFI_DQ_WIDTH/LOOP_COUNTER_WIDTH){loop_counter}};

assign afi_dm = '0;

assign afi_rdata_en_full = afi_rdata_en;

assign afi_we_n        = (state == ISSUE_WRITE_0 ? cmd_0 : (state == ISSUE_WRITE_1 ? cmd_1 : '1));
assign afi_cs_n        = (issue_cmd_0 ? cmd_0 : (issue_cmd_1 ? cmd_1 : '1));
assign afi_wdata_valid = (write_latency_shifter0[0] ? cmd_0_afi_wdata_valid : (write_latency_shifter1[0] ? cmd_1_afi_wdata_valid : '0));
assign afi_rdata_en    = (state == ISSUE_READ_0 ? cmd_0_data_en : (state == ISSUE_READ_1 ? cmd_1_data_en : '0));

generate
	genvar i, j;
	for (i = 0; i < AFI_RATE_RATIO; i = i + 1)
	begin : gen_wdata_valid_loop_timeslot
		for (j = 0; j < AFI_WRITE_DQS_WIDTH / AFI_RATE_RATIO; j = j + 1)
		begin : gen_wdata_valid_loop_group
			assign cmd_0_afi_wdata_valid[i * (AFI_WRITE_DQS_WIDTH / AFI_RATE_RATIO) + j] = cmd_0_data_en[i];
			assign cmd_1_afi_wdata_valid[i * (AFI_WRITE_DQS_WIDTH / AFI_RATE_RATIO) + j] = cmd_1_data_en[i];
		end
	end
endgenerate

generate
	genvar k;
	for (k = 0; k < AFI_RATE_RATIO; k = k + 1)
	begin : gen_rdata_loop_timeslot
		assign expected_afi_rdata[DQ_DDR_WIDTH*(k+1)-1 : DQ_DDR_WIDTH*k] = afi_rdata_valid[k] ? 
			afi_wdata[DQ_DDR_WIDTH*(k+1)-1 : DQ_DDR_WIDTH*k] : '0;
			
		assign masked_afi_rdata[DQ_DDR_WIDTH*(k+1)-1 : DQ_DDR_WIDTH*k] = afi_rdata_valid[k] ?
			afi_rdata[DQ_DDR_WIDTH*(k+1)-1 : DQ_DDR_WIDTH*k] : '0;
	end
endgenerate

generate
	if (AFI_RATE_RATIO == 4) begin
	
		if (BANKS_PER_WRITE == 2) begin
			assign afi_ba = issue_cmd_0 ? {4'b1000+(bank_counter<<3), 4'b0100+(bank_counter<<3), 4'b0010+(bank_counter<<3), 4'b0001+(bank_counter<<3)} : (
							issue_cmd_1 ? {4'b0101+(bank_counter<<3), 4'b0111+(bank_counter<<3), 4'b0110+(bank_counter<<3), 4'b0011+(bank_counter<<3)} : (
							'0));
		end
		else if (BANKS_PER_WRITE == 4) begin
			assign afi_ba = issue_cmd_0 ? {4'bxxxx, 4'b0000+(bank_counter<<2), 4'bxxxx, 4'b0001+(bank_counter<<2)} : (
							issue_cmd_1 ? {4'bxxxx, 4'b0011+(bank_counter<<2), 4'bxxxx, 4'b0010+(bank_counter<<2)} : (
							'0));
		end
		else begin
			assign afi_ba = issue_cmd_0 ? {4'b1000, 4'b0100, 4'b0010, 4'b0001} : (
							issue_cmd_1 ? {4'b1001, 4'b1100, 4'b0110, 4'b0011} : (
							'0));
		end	
	
		if (BANKS_PER_WRITE == 4) begin
			if (MEM_BURST_LENGTH == 2) begin
				assign cmd =         (loop_counter[1:0] == 2'b00) ? 8'b10101010 : (
									 (loop_counter[1:0] == 2'b01) ? 8'b10111011 : (
									 (loop_counter[1:0] == 2'b10) ? 8'b11111110 : (
																	8'b11101111 )));

				assign cmd_data_en = (loop_counter[1:0] == 2'b00) ? 8'b01010101 : (
									 (loop_counter[1:0] == 2'b01) ? 8'b01000100 : (
									 (loop_counter[1:0] == 2'b10) ? 8'b00000001 : (
																	8'b00010000 )));
			end
			else if (MEM_BURST_LENGTH == 4) begin
				assign cmd =         (loop_counter[1:0] == 2'b00) ? 8'b10101010 : (
									 (loop_counter[1:0] == 2'b01) ? 8'b10111011 : (
									 (loop_counter[1:0] == 2'b10) ? 8'b11111110 : (
																	8'b11101111 )));

				assign cmd_data_en = (loop_counter[1:0] == 2'b00) ? 8'b11111111 : (
									 (loop_counter[1:0] == 2'b01) ? 8'b11001100 : (
									 (loop_counter[1:0] == 2'b10) ? 8'b00000011 : (
																	8'b00110000 )));
			end
			else if (MEM_BURST_LENGTH == 8) begin
				assign cmd =         (loop_counter[1:0] == 2'b00) ? 8'b11101110 : (
									 (loop_counter[1:0] == 2'b01) ? 8'b11111011 : (
									 (loop_counter[1:0] == 2'b10) ? 8'b11111011 : (
																	8'b11111110 )));

				assign cmd_data_en = (loop_counter[1:0] == 2'b00) ? 8'b11111111 : (
									 (loop_counter[1:0] == 2'b01) ? 8'b00111100 : (
									 (loop_counter[1:0] == 2'b10) ? 8'b00111100 : (
																	8'b00001111 )));
			end
		end
		else begin
			if (MEM_BURST_LENGTH == 2) begin
				assign cmd = loop_counter[AFI_RATE_RATIO*2-1:0];
				assign cmd_data_en = ~loop_counter[AFI_RATE_RATIO*2-1:0];
			end
			else if (MEM_BURST_LENGTH == 4) begin
				assign cmd =         (loop_counter[1:0] == 2'b00) ? 8'b10101010 : (
									 (loop_counter[1:0] == 2'b01) ? 8'b11010101 : (
									 (loop_counter[1:0] == 2'b10) ? 8'b10110110 : (
																	8'b11101110 )));

				assign cmd_data_en = (loop_counter[1:0] == 2'b00) ? 8'b11111111 : (
									 (loop_counter[1:0] == 2'b01) ? 8'b01111110 : (
									 (loop_counter[1:0] == 2'b10) ? 8'b11011011 : (
																	8'b00110011 )));
			end
			else if (MEM_BURST_LENGTH == 8) begin
				assign cmd =         (loop_counter[1:0] == 2'b00) ? 8'b11101110 : (
									 (loop_counter[1:0] == 2'b01) ? 8'b11111101 : (
									 (loop_counter[1:0] == 2'b10) ? 8'b11111011 : (
																	8'b11110111 )));

				assign cmd_data_en = (loop_counter[1:0] == 2'b00) ? 8'b11111111 : (
									 (loop_counter[1:0] == 2'b01) ? 8'b00011110 : (
									 (loop_counter[1:0] == 2'b10) ? 8'b00111100 : (
																	8'b01111000 )));
			end
		end
	end
	else if (AFI_RATE_RATIO == 2) begin
	
		if (BANKS_PER_WRITE == 2) begin
			assign afi_ba = issue_cmd_0 ? {4'b0010+(bank_counter<<3), 4'b0001+(bank_counter<<3)} : (
							issue_cmd_1 ? {4'b0110+(bank_counter<<3), 4'b0011+(bank_counter<<3)} : (
							'0));
		end
		else if (BANKS_PER_WRITE == 4) begin
			assign afi_ba = issue_cmd_0 ? {4'b0010+(bank_counter<<2), 4'b0001+(bank_counter<<2)} : (
							issue_cmd_1 ? {4'b0000+(bank_counter<<2), 4'b0011+(bank_counter<<2)} : (
							'0));
		end
		else begin
			assign afi_ba = issue_cmd_0 ? {4'b0010, 4'b0001} : (
							issue_cmd_1 ? {4'b0110, 4'b0011} : (
							'0));
		end	
	
		if (MEM_BURST_LENGTH == 2) begin
			assign cmd = loop_counter[AFI_RATE_RATIO*2-1:0];
			assign cmd_data_en = ~loop_counter[AFI_RATE_RATIO*2-1:0];
		end
		else if (MEM_BURST_LENGTH == 4) begin
			assign cmd =         (loop_counter[1:0] == 2'b00) ? 4'b1010 : (
			                     (loop_counter[1:0] == 2'b01) ? 4'b1101 : (
						         (loop_counter[1:0] == 2'b10) ? 4'b1011 : (
						                                        4'b1110 )));

			assign cmd_data_en = (loop_counter[1:0] == 2'b00) ? 4'b1111 : (
			                     (loop_counter[1:0] == 2'b01) ? 4'b0110 : (
						         (loop_counter[1:0] == 2'b10) ? 4'b1100 : (
						                                        4'b0011 )));
		end
		else if (MEM_BURST_LENGTH == 8) begin
			assign cmd =         (loop_counter[1:0] == 2'b00) ? 4'b1110 : (
			                     (loop_counter[1:0] == 2'b01) ? 4'b1110 : (
						         (loop_counter[1:0] == 2'b10) ? 4'b1110 : (
						                                        4'b1110 )));

			assign cmd_data_en = (loop_counter[1:0] == 2'b00) ? 4'b1111 : (
			                     (loop_counter[1:0] == 2'b01) ? 4'b1111 : (
						         (loop_counter[1:0] == 2'b10) ? 4'b1111 : (
						                                        4'b1111 )));
		end
	end
endgenerate


`ifdef ENABLE_ISS_PROBES
reg [AFI_DQ_WIDTH-1:0] pnf_per_bit_r;
reg [AFI_DQ_WIDTH-1:0] pnf_per_bit_persist_r;
reg pass_r;
reg fail_r;
reg timeout_r;
reg test_complete_r;
reg [31:0] loop_counter_r;
reg [31:0] loop_counter_persist_r;

always_ff @(posedge afi_clk)
begin
	pass_r <= (state == DONE);
	fail_r <= (state == FAILED);
	timeout_r <= '0;
	test_complete_r <= (state == DONE || state == FAILED);
	loop_counter_r <= loop_counter;
	pnf_per_bit_r <= '0;
	pnf_per_bit_persist_r <= '0;
	loop_counter_persist_r <= loop_counter;

	if (~fail_r) begin
		loop_counter_persist_r <= loop_counter_r;
	end
end

iss_probe #(
	.WIDTH((AFI_DQ_WIDTH > 511) ? 511 : AFI_DQ_WIDTH)
) pnf_per_bit_probe (
	.probe_input(pnf_per_bit_r[((AFI_DQ_WIDTH > 511) ? 511 : AFI_DQ_WIDTH) - 1 : 0])
);

iss_probe #(
	.WIDTH((AFI_DQ_WIDTH > 511) ? 511 : AFI_DQ_WIDTH)
) pnf_per_bit_persist_probe (
	.probe_input(pnf_per_bit_persist_r[((AFI_DQ_WIDTH > 511) ? 511 : AFI_DQ_WIDTH) - 1: 0])
);

iss_probe #(
	.WIDTH(1)
) driver_pass_probe (
	.probe_input(pass_r)
);

iss_probe #(
	.WIDTH(1)
) driver_fail_probe (
	.probe_input(fail_r)
);

iss_probe #(
	.WIDTH(1)
) driver_timeout_probe (
	.probe_input(timeout_r)
);

iss_probe #(
	.WIDTH(1)
) driver_test_complete_probe (
	.probe_input(test_complete_r)
);

iss_probe #(
	.WIDTH(32)
) driver_loop_counter_probe (
	.probe_input(loop_counter_persist_r)
);
`endif


endmodule

