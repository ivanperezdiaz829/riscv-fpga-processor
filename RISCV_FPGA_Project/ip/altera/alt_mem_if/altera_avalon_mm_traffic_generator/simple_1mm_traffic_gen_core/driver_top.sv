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


(* altera_attribute = "-name ALLOW_SYNCH_CTRL_USAGE OFF;-name AUTO_CLOCK_ENABLE_RECOGNITION OFF;-name FITTER_ADJUST_HC_SHORT_PATH_GUARDBAND 200" *)
module driver_top (
	avl_clk,
	avl_reset_n,
	avl_ready,
	avl_write_req,
	avl_read_req,
	avl_addr,
	avl_size,
	avl_be,
	avl_wdata,
	avl_rdata_valid,
	avl_rdata,
	avl_burstbegin,
	pass,
	fail,
	test_complete,
	pnf_per_bit,
	pnf_per_bit_persist,
	
	csr_address,
	csr_write,
	csr_writedata,
	csr_read,
	csr_readdata,
	csr_waitrequest,
	csr_be
	
);



parameter DEVICE_FAMILY							= "Stratix V";

parameter TG_AVL_ADDR_WIDTH							= 33;
parameter TG_AVL_SIZE_WIDTH						= 7;
parameter TG_AVL_DATA_WIDTH							= 288;
parameter TG_AVL_BE_WIDTH								= 36;
parameter TG_GEN_BYTE_ADDR = 1;
parameter TG_AVL_WORD_ADDR_WIDTH = 32;

parameter TG_NUM_DRIVER_LOOP   = 1;

parameter DRIVER_SIGNATURE = 0;

parameter TRANSACTION_COUNT = 2000;

parameter TRANSACTION_COUNTER_WIDTH = 32;
parameter LOOP_COUNTER_WIDTH = 32;
parameter TIMEOUT_COUNTER_WIDTH = 30;



localparam NUM_DRIVER_RESET = 1;

localparam WOB_ADDR_LSB				= (TG_GEN_BYTE_ADDR == 1) ? TG_AVL_ADDR_WIDTH - TG_AVL_WORD_ADDR_WIDTH : 0;



input							avl_clk;
input							avl_reset_n;

input							avl_ready;
output	reg						avl_write_req;
output	reg						avl_read_req;
output	reg [TG_AVL_ADDR_WIDTH-1:0]		avl_addr;
output	reg [TG_AVL_SIZE_WIDTH-1:0]	avl_size;
output	reg [TG_AVL_BE_WIDTH-1:0]			avl_be;
output	reg [TG_AVL_DATA_WIDTH-1:0]		avl_wdata;
input							avl_rdata_valid;
input 	[TG_AVL_DATA_WIDTH-1:0]		avl_rdata;
output	reg						avl_burstbegin;

output	reg						pass;
output	reg						fail;
output	reg						test_complete;
output	reg [TG_AVL_DATA_WIDTH-1:0]		pnf_per_bit;
output	reg [TG_AVL_DATA_WIDTH-1:0]		pnf_per_bit_persist;



input [13 - 1:0] csr_address;
input csr_write;
input [32 - 1:0] csr_writedata;
input [4 - 1:0] csr_be;
input csr_read;
output [32 - 1:0] csr_readdata;
output csr_waitrequest;



wire	[NUM_DRIVER_RESET-1:0]	resync_reset_n;

reg int_avl_rdata_valid;
reg [TG_AVL_DATA_WIDTH-1:0]	int_avl_rdata;


wire int_test_complete;
wire write_data_gen_enable;
wire read_data_gen_enable;
wire address_gen_enable;
wire transaction_inc;
reg [TRANSACTION_COUNTER_WIDTH-1:0] transaction_counter;
reg [TRANSACTION_COUNTER_WIDTH-1:0] reads_counter;
wire read_complete;

wire [TG_AVL_WORD_ADDR_WIDTH-1:0] next_avl_address;
wire [TG_AVL_DATA_WIDTH-1:0] next_avl_wdata;
wire [TG_AVL_DATA_WIDTH-1:0] next_avl_rdata;

reg [TRANSACTION_COUNTER_WIDTH-1:0] error_transaction;
reg [TG_AVL_DATA_WIDTH-1:0] expected_data;
reg [TG_AVL_DATA_WIDTH-1:0] read_data;

reg [TIMEOUT_COUNTER_WIDTH-1:0] timeout_counter;
reg fail_timeout;
reg fail_data_compare;

wire force_error;

reset_sync	ureset_driver_clk(
	.reset_n		(avl_reset_n),
	.clk			(avl_clk),
	.reset_n_sync	(resync_reset_n)
);
defparam ureset_driver_clk.NUM_RESET_OUTPUT = NUM_DRIVER_RESET;


always_ff @ (posedge avl_clk or negedge resync_reset_n) begin
	if (~resync_reset_n) begin
		int_avl_rdata_valid <= 0;
		int_avl_rdata <= 0;
	end
	else begin
		int_avl_rdata_valid <= avl_rdata_valid;
		int_avl_rdata <= avl_rdata;
	end
end

typedef enum int unsigned {
	INIT,

	ISSUE_WRITE,
	WAIT_WRITE_COMPLETE,

	ISSUE_READ,
	WAIT_READ_COMPLETE,

	WAIT_PENDING_READS,
	TEST_COMPLETE,
	TIMEOUT,
	
	FSM_ERROR
} state_t;

state_t state;
state_t last_state;

always_ff @ (posedge avl_clk or negedge resync_reset_n) begin
	if (~resync_reset_n) begin
		state <= INIT;
		last_state <= INIT;
	end
	else begin
		last_state <= state;
	
	
		case (state)

			INIT :
				state <= ISSUE_WRITE;

			ISSUE_WRITE : begin
				if (avl_ready)
					state <= ISSUE_READ;
				else
					state <= WAIT_WRITE_COMPLETE;
			end

			WAIT_WRITE_COMPLETE : begin
				if (timeout_counter == '1)
					state <= TIMEOUT;
				else if (avl_ready)
					state <= ISSUE_READ;
				else
					state <= WAIT_WRITE_COMPLETE;
			end

			ISSUE_READ : begin
				if (avl_ready)
					if (transaction_counter < (TRANSACTION_COUNT-1))
						state <= ISSUE_WRITE;
					else
						state <= WAIT_PENDING_READS;
				else
					state <= WAIT_READ_COMPLETE;
			end

			WAIT_READ_COMPLETE : begin
				if (timeout_counter == '1)
					state <= TIMEOUT;
				else if (avl_ready)
					if (transaction_counter < (TRANSACTION_COUNT-1))
						state <= ISSUE_WRITE;
					else
						state <= WAIT_PENDING_READS;
				else
					state <= WAIT_READ_COMPLETE;
			end

			WAIT_PENDING_READS :
				if (timeout_counter == '1)
					state <= TIMEOUT;
				else if (reads_counter == TRANSACTION_COUNT)
					state <= TEST_COMPLETE;
				else
					state <= WAIT_PENDING_READS;

			TEST_COMPLETE :
				state <= TEST_COMPLETE;

			TIMEOUT :
				state <= TIMEOUT;
		
			FSM_ERROR :
				state <= FSM_ERROR;

			default :
				state <= FSM_ERROR;
		
		endcase
	end

end

always_comb begin
	avl_read_req <= 0;
	avl_write_req <= 0;
	avl_addr[TG_AVL_ADDR_WIDTH-1:WOB_ADDR_LSB] <= next_avl_address;
	avl_wdata <= 0;
	avl_burstbegin <= 0;

	case (state)
		ISSUE_WRITE : begin
			avl_burstbegin <= 1'b1;
			avl_write_req <= 1;
			avl_addr[TG_AVL_ADDR_WIDTH-1:WOB_ADDR_LSB] <= next_avl_address;
			avl_wdata <= next_avl_wdata;
		end

		WAIT_WRITE_COMPLETE : begin
			avl_write_req <= 1;
			avl_addr[TG_AVL_ADDR_WIDTH-1:WOB_ADDR_LSB] <= next_avl_address;
			avl_wdata <= next_avl_wdata;
		end

		ISSUE_READ : begin
			avl_burstbegin <= 1'b1;
			avl_read_req <= 1;
			avl_addr[TG_AVL_ADDR_WIDTH-1:WOB_ADDR_LSB] <= next_avl_address;
		end

		WAIT_READ_COMPLETE : begin
			avl_read_req <= 1;
			avl_addr[TG_AVL_ADDR_WIDTH-1:WOB_ADDR_LSB] <= next_avl_address;
		end

		default : begin
		end
		
	endcase	
end

always_ff @ (posedge avl_clk or negedge resync_reset_n) begin
	if (~resync_reset_n) begin
		transaction_counter <= 0;
	end
	else begin
		if (transaction_inc)
			transaction_counter <= transaction_counter + 1'b1;
	end
end

always_ff @ (posedge avl_clk or negedge resync_reset_n) begin
	if (~resync_reset_n) begin
		reads_counter <= 0;
	end
	else begin
		if (read_complete)
			reads_counter <= reads_counter + 1'b1;
	end
end

assign int_test_complete = ((state == TEST_COMPLETE) || (state == TIMEOUT)) ? 1'b1 : 1'b0;
always_ff @ (posedge avl_clk or negedge resync_reset_n) begin
	if (~resync_reset_n) begin
		test_complete <= 0;
		pass <= 0;
		fail <= 0;
	end
	else begin
		pass <= 0;
		fail <= 0;
		
		test_complete <= int_test_complete;
		
		
		if (fail_data_compare || fail_timeout) begin
			pass <= 0;
			fail <= 1'b1;
		end
		else begin
			if (int_test_complete) begin
				pass <= 1'b1;
				fail <= 0;
			end
		end
	end
end

assign write_data_gen_enable = (state == ISSUE_READ) ? 1'b1 : 1'b0;
assign read_data_gen_enable = (int_avl_rdata_valid) ? 1'b1 : 1'b0;

assign address_gen_enable = (((state == WAIT_READ_COMPLETE) || (state == ISSUE_READ)) && avl_ready) ? 1'b1 : 1'b0;

assign transaction_inc = (((last_state == WAIT_READ_COMPLETE) || (last_state == ISSUE_READ)) && ((state == ISSUE_WRITE) || (state == WAIT_PENDING_READS))) ? 1'b1 : 1'b0;

always_comb begin
	avl_size <= 1;
	avl_be <= '1;
end

always_ff @ (posedge avl_clk or negedge resync_reset_n) begin
	if (~resync_reset_n) begin
		pnf_per_bit <= {TG_AVL_DATA_WIDTH{1'b1}};
		pnf_per_bit_persist <= {TG_AVL_DATA_WIDTH{1'b1}};
	end
	else begin
		if (int_avl_rdata_valid) begin
			for (int bit_num = 0; bit_num < TG_AVL_DATA_WIDTH; bit_num++)
				if ((int_avl_rdata[bit_num] == next_avl_rdata[bit_num]) && (~force_error))
					pnf_per_bit[bit_num] <= 1'b1;
				else begin
					pnf_per_bit[bit_num] <= 1'b0;
					pnf_per_bit_persist[bit_num] <= 1'b0;
				end
		end
	end
end

wire [TG_AVL_DATA_WIDTH-1:0] int_avl_rdata_delay;
reg_delay #(
	.DATA_WIDTH(TG_AVL_DATA_WIDTH),
	.CYCLE_DELAY(1)
) read_data_reg_delay (
	.clk(avl_clk),
	.reset_n(resync_reset_n),
	.data_in(int_avl_rdata),
	.data_out(int_avl_rdata_delay)
);

wire [TG_AVL_DATA_WIDTH-1:0] next_avl_rdata_delay;
reg_delay #(
	.DATA_WIDTH(TG_AVL_DATA_WIDTH),
	.CYCLE_DELAY(1)
) expected_data_reg_delay (
	.clk(avl_clk),
	.reset_n(resync_reset_n),
	.data_in(next_avl_rdata),
	.data_out(next_avl_rdata_delay)
);

wire [TRANSACTION_COUNTER_WIDTH-1:0] reads_counter_delay;
reg_delay #(
	.DATA_WIDTH(TRANSACTION_COUNTER_WIDTH),
	.CYCLE_DELAY(1)
) transaction_counter_reg_delay (
	.clk(avl_clk),
	.reset_n(resync_reset_n),
	.data_in(reads_counter),
	.data_out(reads_counter_delay)
);

always_ff @ (posedge avl_clk or negedge resync_reset_n) begin
	if (~resync_reset_n) begin
		timeout_counter <= 0;
		fail_timeout <= 0;
	end
	else begin
		if (int_avl_rdata_valid) begin
			timeout_counter <= 0;
		end
		else begin
			if (state != TEST_COMPLETE) begin
				if (timeout_counter != '1)
					timeout_counter <= timeout_counter + 1'b1;
				else
					fail_timeout <= 1'b1;
			end
		end
	end
end

always_ff @ (posedge avl_clk or negedge resync_reset_n) begin
	if (~resync_reset_n) begin
		fail_data_compare <= 0;
		expected_data <= 0;
		read_data <= 0;
		error_transaction <= 0;
	end
	else begin
		if ((pnf_per_bit_persist != '1) && (fail_data_compare == 0)) begin
			fail_data_compare <= 1'b1;
			expected_data <= next_avl_rdata_delay;
			read_data <= int_avl_rdata_delay;
			
			error_transaction <= reads_counter_delay; 
		end
	end
end



assign read_complete = int_avl_rdata_valid;


counter_gen #(
	.DATA_WIDTH(TG_AVL_WORD_ADDR_WIDTH)
) address_gen (
	.clk(avl_clk),
	.reset_n(resync_reset_n),
	.data_out(next_avl_address),
	.enable(address_gen_enable)
);

counter_gen #(
	.DATA_WIDTH(TG_AVL_DATA_WIDTH)
) read_data_gen (
	.clk(avl_clk),
	.reset_n(resync_reset_n),
	.data_out(next_avl_rdata),
	.enable(read_data_gen_enable)
);



counter_gen #(
	.DATA_WIDTH(TG_AVL_DATA_WIDTH)
) write_data_gen (
	.clk(avl_clk),
	.reset_n(resync_reset_n),
	.data_out(next_avl_wdata),
	.enable(write_data_gen_enable)
);



	
`ifdef ENABLE_ISS_PROBES
iss_source #(
	.WIDTH(1)
) iss_driver_force_error (
	.source(force_error)
);
`else
assign force_error = 1'b0;
`endif

`ifdef ENABLE_ISS_PROBES
reg [TG_AVL_DATA_WIDTH-1:0] pnf_per_bit_r;
reg [TG_AVL_DATA_WIDTH-1:0] pnf_per_bit_persist_r;
reg pass_r;
reg fail_r;
reg timeout_r;
reg test_complete_r;
reg [31:0] loop_counter_r;
reg [31:0] loop_counter_persist_r;

always_ff @(posedge avl_clk)
begin
	pass_r <= pass;
	fail_r <= fail;
	timeout_r <= fail_timeout;
	test_complete_r <= test_complete;
	loop_counter_r <= transaction_counter;
	pnf_per_bit_r <= pnf_per_bit;
	pnf_per_bit_persist_r <= pnf_per_bit_persist;
	loop_counter_persist_r <= transaction_counter;

	if (~fail_r) begin
		loop_counter_persist_r <= loop_counter_r;
	end
end

iss_probe #(
	.WIDTH((TG_AVL_DATA_WIDTH > 511) ? 511 : TG_AVL_DATA_WIDTH)
) pnf_per_bit_probe (
	.probe_input(pnf_per_bit_r[((TG_AVL_DATA_WIDTH > 511) ? 511 : TG_AVL_DATA_WIDTH) - 1 : 0])
);

iss_probe #(
	.WIDTH((TG_AVL_DATA_WIDTH > 511) ? 511 : TG_AVL_DATA_WIDTH)
) pnf_per_bit_persist_probe (
	.probe_input(pnf_per_bit_persist_r[((TG_AVL_DATA_WIDTH > 511) ? 511 : TG_AVL_DATA_WIDTH) - 1: 0])
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

/*
driver_csr #(
	.PNF_PER_BIT_WIDTH(TG_AVL_DATA_WIDTH),
	.DRIVER_SIGNATURE(DRIVER_SIGNATURE)
) csr (
	.avl_clk(clk),
	.avl_reset_n(resync_reset_n[0]),
	.avl_address(csr_address),
	.avl_write(csr_write),
	.avl_writedata(csr_writedata),
	.avl_read(csr_read),
	.avl_readdata(csr_readdata),
	.avl_waitrequest(csr_waitrequest),
	.avl_be(csr_be),
	.drv_pass(pass),
	.drv_fail(fail),
	.drv_timeout(timeout),
	.drv_test_complete(test_complete),
	.loop_counter(loop_counter_persist),
	.pnf_per_bit_persist(pnf_per_bit_persist)
);

*/

endmodule

