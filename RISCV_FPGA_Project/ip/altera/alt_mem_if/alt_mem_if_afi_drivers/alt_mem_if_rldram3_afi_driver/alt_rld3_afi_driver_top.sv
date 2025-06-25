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

//////////////////////////////////////////////////////////////////////////////
// This is an example AFI driver for the RLDRAM3 PHY. In real designs, this
// module will be replaced by a controller interfaced with user logic.
//////////////////////////////////////////////////////////////////////////////

(* altera_attribute = "-name IP_TOOL_NAME altera_mem_if_rldram3_afi_driver; -name IP_TOOL_VERSION 13.1; -name FITTER_ADJUST_HC_SHORT_PATH_GUARDBAND 100" *)
module alt_rld3_afi_driver_top (
   afi_clk,
   afi_reset_n,
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
parameter DEVICE_FAMILY                     = "";

// The memory burst length
parameter MEM_BURST_LENGTH                  = 0;

// The write protocol used
parameter MRS_WRITE_PROTOCOL                = 0;

// AFI 2.0 INTERFACE PARAMETERS
parameter AFI_WLAT_WIDTH                    = 0;
parameter AFI_RLAT_WIDTH                    = 0;
parameter AFI_ADDR_WIDTH                    = 0;
parameter AFI_BANKADDR_WIDTH                = 0;
parameter AFI_CONTROL_WIDTH                 = 0;
parameter AFI_CS_WIDTH                      = 0;
parameter AFI_DM_WIDTH                      = 0;
parameter AFI_DQ_WIDTH                      = 0;
parameter AFI_WRITE_DQS_WIDTH               = 0;
parameter AFI_RATE_RATIO                    = 0;
parameter MEM_IF_CS_WIDTH		    = 1;

// Width of counter to keep track of current loop iteration.
// The counter value is also used to derive how many and the scheduling
// of read or write commands within the AFI cycles. It is set to 
// AFI_RATE_RATIO * 2 so that we can enumerate all sub-AFI-cycle access
// combinations of two AFI cycles when BL=2.
localparam LOOP_COUNTER_WIDTH = AFI_RATE_RATIO * 2;   

// 2**CMD_COUNTER_WIDTH == Maximum consecutive AFI cycles commands
// are issued. A value of 3 translates to 8 AFI cycles, which means a 
// maximum of 32 consecutive memory reads or writes at HR (or 64 at QR)
// which is sufficient to expose read fifo overflows. The minimum
// value for CMD_COUNTER_WIDTH is 1. When multi-bank write is enabled
// this is always set to 1.
localparam CMD_COUNTER_WIDTH = (MRS_WRITE_PROTOCOL == 0) ? 3 : 1;

// Width of counter to keep track of tRC requirement
localparam TRC_COUNTER_WIDTH = 3;

// Length of shift register to keep track of AFI write latency requirement
// 16 AFI cycles should be sufficient in any case.
localparam MAX_AFI_WLAT = 16;

// Length of shift register to keep track of AFI read latency requirement
// 16 AFI cycles should be sufficient in any case.
localparam MAX_AFI_RLAT = 16;

// Number of banks written to per write command.
localparam BANKS_PER_WRITE = 2**MRS_WRITE_PROTOCOL;

// Width of data bus to represent a single memory cycle worth of data.
localparam DQ_DDR_WIDTH = AFI_DQ_WIDTH / AFI_RATE_RATIO;

// END PARAMETER SECTION
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// BEGIN PORT SECTION

input                                     afi_clk;
input                                     afi_reset_n;
input      [AFI_WLAT_WIDTH-1:0]           afi_wlat;
input      [AFI_RLAT_WIDTH-1:0]           afi_rlat;
output reg [AFI_ADDR_WIDTH-1:0]           afi_addr;
output reg [AFI_BANKADDR_WIDTH-1:0]       afi_ba;
output reg [AFI_CS_WIDTH-1:0]             afi_cs_n;
output reg [AFI_CONTROL_WIDTH-1:0]        afi_we_n;
output     [AFI_CONTROL_WIDTH-1:0]        afi_ref_n;
output     [AFI_CONTROL_WIDTH-1:0]        afi_rst_n;
output reg [AFI_WRITE_DQS_WIDTH-1:0]      afi_wdata_valid;
output reg [AFI_DQ_WIDTH-1:0]             afi_wdata;
output     [AFI_DM_WIDTH-1:0]             afi_dm;
output reg [AFI_RATE_RATIO-1:0]           afi_rdata_en;
output reg [AFI_RATE_RATIO-1:0]           afi_rdata_en_full;
input      [AFI_DQ_WIDTH-1:0]             afi_rdata;
input      [AFI_RATE_RATIO-1:0]           afi_rdata_valid;
input                                     afi_cal_success;
input                                     afi_cal_fail;
output                                    local_init_done;
output                                    local_cal_success;
output                                    local_cal_fail;

// END PORT SECTION
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
//Logic for ISS probes
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
assign local_cal_fail    = afi_cal_fail;
assign local_init_done   = afi_cal_success;

// The driver is a simple state machine that goes through a write
// loop and then a read loop. During the read commands we verify
// that we read back the correct data.
enum {
   INIT_WRITE_OUTER_LOOP_COUNTER,
   INIT_WRITE_INNER_LOOP_COUNTER,
   ISSUE_WRITES,
   WAIT_WL,
   WRITE_WAIT_TRC,
   NEXT_WRITE_OUTER_LOOP,
   INIT_READ_OUTER_LOOP_COUNTER,
   INIT_READ_INNER_LOOP_COUNTER,
   ISSUE_READS,
   WAIT_RL,
   READ_DATA,
   READ_WAIT_TRC,
   NEXT_BANK_SET,
   NEXT_READ_OUTER_LOOP,
   FAILED,
   DONE                           
} state;

reg [LOOP_COUNTER_WIDTH-1:0]         loop_counter;
reg [CMD_COUNTER_WIDTH-1:0]          cmd_counter;
reg [CMD_COUNTER_WIDTH-1:0]          wdata_counter;
reg [MAX_AFI_RLAT-1:0]               rl_shifter;
reg [MAX_AFI_WLAT-1:0]               wl_shifter;
reg [TRC_COUNTER_WIDTH-1:0]          trc_counter;
reg [3:0]                            bank_counter;
reg                                  read_failed;

wire [AFI_BANKADDR_WIDTH-1:0]        afi_ba_int;
wire [AFI_DQ_WIDTH-1:0]              expected_afi_rdata;
wire [AFI_DQ_WIDTH-1:0]              masked_afi_rdata;
reg  [3:0]							 rank_num;

//////////////////////////////////////////////////////////////////////////////
// State machine
//////////////////////////////////////////////////////////////////////////////
always_ff @(posedge afi_clk, negedge afi_reset_n)
begin
   if (! afi_reset_n) begin
      state <= INIT_WRITE_OUTER_LOOP_COUNTER;
	  rank_num <= '0;
   end else begin
      case(state)
         INIT_WRITE_OUTER_LOOP_COUNTER:
            if (afi_cal_success) begin
               state <= INIT_WRITE_INNER_LOOP_COUNTER;
            end else begin
				if (afi_cal_fail) begin
					$display("          --- CALIBRATION FAILED --- ");
					state <= FAILED;
				end
			end	
         INIT_WRITE_INNER_LOOP_COUNTER:
            state <= ISSUE_WRITES;
            
         ISSUE_WRITES:
            if (cmd_counter == '1) 
               state <= WAIT_WL;
               
         WAIT_WL:
            if (wl_shifter == '0)
               state <= WRITE_WAIT_TRC;
               
         WRITE_WAIT_TRC:
            if (trc_counter == '1)
               if (loop_counter == 0)
                  state <= INIT_READ_OUTER_LOOP_COUNTER;
               else
                  state <= NEXT_WRITE_OUTER_LOOP;
                  
         NEXT_WRITE_OUTER_LOOP:
            state <= INIT_WRITE_INNER_LOOP_COUNTER;
            
         INIT_READ_OUTER_LOOP_COUNTER:
            state <= INIT_READ_INNER_LOOP_COUNTER;
            
         INIT_READ_INNER_LOOP_COUNTER:
            state <= ISSUE_READS;
            
         ISSUE_READS:
            if (cmd_counter == '1) 
               state <= WAIT_RL;
               
         WAIT_RL:
            if (read_failed)
               state <= FAILED;
            else if (rl_shifter[0] == 1'b1)
               state <= READ_WAIT_TRC;
               
         READ_WAIT_TRC:
            if (trc_counter == '1) begin
               if (bank_counter > 0) begin
                  state <= NEXT_BANK_SET;
               end else begin
                  if (loop_counter == 0) begin
					 rank_num <= rank_num + 1'b1;
					 if (rank_num == MEM_IF_CS_WIDTH) begin
						state <= DONE;
					 end else begin
						state <= INIT_WRITE_OUTER_LOOP_COUNTER;
					 end	
                  end else begin
                     state <= NEXT_READ_OUTER_LOOP;
				  end	
				end	
			end	
				      
         NEXT_BANK_SET:
            state <= ISSUE_READS;
            
         NEXT_READ_OUTER_LOOP:
            state <= INIT_READ_INNER_LOOP_COUNTER;
            
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
            state <= INIT_WRITE_OUTER_LOOP_COUNTER;
      endcase
   end
end

//////////////////////////////////////////////////////////////////////////////
// Counters management
//////////////////////////////////////////////////////////////////////////////
always_ff @(posedge afi_clk)
begin
   if (state == INIT_WRITE_OUTER_LOOP_COUNTER || state == INIT_READ_OUTER_LOOP_COUNTER) 
      loop_counter <= '1 - 1'b1;
   else if (state == NEXT_WRITE_OUTER_LOOP || state == NEXT_READ_OUTER_LOOP) 
      loop_counter <= loop_counter - 1'b1;
end

always_ff @(posedge afi_clk)
begin
   if (state == INIT_WRITE_INNER_LOOP_COUNTER || state == INIT_READ_INNER_LOOP_COUNTER)
      cmd_counter <= '0;
   else if (state == ISSUE_WRITES || state == ISSUE_READS)
      cmd_counter <= cmd_counter + 1'b1;
end

always_ff @(posedge afi_clk)
begin
   if (state == INIT_WRITE_INNER_LOOP_COUNTER)
      wdata_counter <= '0;
   else if (wl_shifter[0] == 1'b1)
      wdata_counter <= wdata_counter + 1'b1;
end

always_ff @(posedge afi_clk, negedge afi_reset_n)
begin
   if (!afi_reset_n)
      rl_shifter <= '0;
   else if (state == ISSUE_READS)
      rl_shifter <= {1'b1, {(MAX_AFI_RLAT-1){1'b0}}};
   else if (state == WAIT_RL)
      rl_shifter <= {1'b0, rl_shifter[MAX_AFI_RLAT-1:1]};
end

always_ff @(posedge afi_clk, negedge afi_reset_n)
begin
   if (!afi_reset_n)
      wl_shifter <= '0;
   else begin
      wl_shifter <= {1'b0, wl_shifter[MAX_AFI_WLAT-1:1]};
      if (state == ISSUE_WRITES)
         wl_shifter[afi_wlat-1] <= 1'b1;
   end
end

always_ff @(posedge afi_clk)
begin
   if (state == WAIT_WL || state == WAIT_RL) 
      trc_counter <= '0;
   else
      trc_counter <= trc_counter + 1'b1;
end

always_ff @(posedge afi_clk)
begin
   if (state == INIT_WRITE_OUTER_LOOP_COUNTER)
      bank_counter <= '0;
   else if (state == INIT_READ_INNER_LOOP_COUNTER)
      bank_counter <= BANKS_PER_WRITE[3:0] - 1'b1;
   else if (state == NEXT_BANK_SET)
      bank_counter <= bank_counter - 1'b1;
end

//////////////////////////////////////////////////////////////////////////////
// Generate AFI signals
//////////////////////////////////////////////////////////////////////////////

// Generate two AFI cycles of commands
wire [AFI_RATE_RATIO*2-1:0] cmd;
wire [AFI_RATE_RATIO*2-1:0] cmd_data_en;

reg [AFI_RATE_RATIO-1:0] afi_cs_per_rank;
wire [AFI_RATE_RATIO-1:0] cmd_0 = cmd[AFI_RATE_RATIO-1:0];
wire [AFI_RATE_RATIO-1:0] cmd_1 = cmd[AFI_RATE_RATIO*2-1:AFI_RATE_RATIO];

wire [AFI_RATE_RATIO-1:0] cmd_0_data_en = cmd_data_en[AFI_RATE_RATIO-1:0];
wire [AFI_RATE_RATIO-1:0] cmd_1_data_en = cmd_data_en[AFI_RATE_RATIO*2-1:AFI_RATE_RATIO];

wire issue_cmd_0 = (state == ISSUE_WRITES || state == ISSUE_READS) && (cmd_counter[0] == 1'b0);
wire issue_cmd_1 = (state == ISSUE_WRITES || state == ISSUE_READS) && (cmd_counter[0] == 1'b1);

wire [AFI_WRITE_DQS_WIDTH-1:0] cmd_0_afi_wdata_valid;
wire [AFI_WRITE_DQS_WIDTH-1:0] cmd_1_afi_wdata_valid;

wire [AFI_CS_WIDTH-1:0]  local_afi_cs_n;

assign afi_ref_n = '1;
assign afi_rst_n = '1;
assign afi_dm = '0;

always_ff @(posedge afi_clk, negedge afi_reset_n) begin
   if (! afi_reset_n) begin
      afi_ba <= '0;
      afi_addr <= '0;
      afi_we_n <= '1;
      afi_cs_per_rank <= '1;
      afi_wdata_valid <= '0;
      afi_rdata_en_full <= '0;
      afi_rdata_en <= '0;
   end else begin
      afi_ba <= afi_ba_int;
      
      afi_addr <= {AFI_RATE_RATIO{ {((AFI_ADDR_WIDTH/AFI_RATE_RATIO)-LOOP_COUNTER_WIDTH-CMD_COUNTER_WIDTH){1'b0}}, loop_counter, cmd_counter}};

      afi_cs_per_rank <= (issue_cmd_0 ? cmd_0 : (issue_cmd_1 ? cmd_1 : '1));

      if (state == ISSUE_WRITES)
         afi_we_n <= (cmd_counter[0] == 1'b0) ? cmd_0 : cmd_1;
      else
         afi_we_n <= '1;
      
      if (wl_shifter[0] == 1'b1)
         afi_wdata_valid <= (wdata_counter[0] == 1'b0) ? cmd_0_afi_wdata_valid : cmd_1_afi_wdata_valid;
      else
         afi_wdata_valid <= '0;

      if (state == ISSUE_READS) begin
         afi_rdata_en_full <= (cmd_counter[0] == 1'b0) ? cmd_0_data_en : cmd_1_data_en;
         afi_rdata_en      <= (cmd_counter[0] == 1'b0) ? cmd_0_data_en : cmd_1_data_en;
      end else begin         
         afi_rdata_en_full <= '0;
         afi_rdata_en      <= '0;
      end
   end
end

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
	if ( MEM_IF_CS_WIDTH == 1 ) begin
		assign local_afi_cs_n = afi_cs_per_rank;
	end else if ( MEM_IF_CS_WIDTH == 2 ) begin
		assign local_afi_cs_n =(rank_num[3:0] == 4'b0000) ? { {(AFI_RATE_RATIO){1'b1}} , afi_cs_per_rank } : (
						 (rank_num[3:0] == 4'b0001) ? {  afi_cs_per_rank , {(AFI_RATE_RATIO){1'b1}} } : (
														'1));
	end else if ( MEM_IF_CS_WIDTH == 4 ) begin
		assign local_afi_cs_n =(rank_num[3:0] == 4'b0000) ? { {(AFI_RATE_RATIO*3){1'b1}} , afi_cs_per_rank } : (
						 (rank_num[3:0] == 4'b0001) ? { {(AFI_RATE_RATIO*2){1'b1}} , afi_cs_per_rank , {(AFI_RATE_RATIO*1){1'b1}} } : (
						 (rank_num[3:0] == 4'b0010) ? { {(AFI_RATE_RATIO*1){1'b1}} , afi_cs_per_rank , {(AFI_RATE_RATIO*2){1'b1}} } : (
						 (rank_num[3:0] == 4'b0011) ? {  afi_cs_per_rank , {(AFI_RATE_RATIO*3){1'b1}} } : (
														'1 ))));
	end else begin
		assign local_afi_cs_n = '1;
	end	
endgenerate														

generate
	genvar m,l;
	for (l = 0; l < AFI_RATE_RATIO; l = l + 1)
	begin : reorder_afi_cs_n_in_correct_time_slot
		for (m = 0; m < MEM_IF_CS_WIDTH; m = m + 1)
		begin : reorder_afi_cs_n_in_correct_time_slot_2
			assign afi_cs_n[ MEM_IF_CS_WIDTH*l + m] = local_afi_cs_n[m*AFI_RATE_RATIO + l];
		end
	end
endgenerate	
														
generate
   if (AFI_RATE_RATIO == 4) begin
   
      if (BANKS_PER_WRITE == 2) begin
         assign afi_ba_int = issue_cmd_0 ? {4'b1000+(bank_counter<<3), 4'b0100+(bank_counter<<3), 4'b0010+(bank_counter<<3), 4'b0001+(bank_counter<<3)} : (
                             issue_cmd_1 ? {4'b0101+(bank_counter<<3), 4'b0111+(bank_counter<<3), 4'b0110+(bank_counter<<3), 4'b0011+(bank_counter<<3)} : (
                             '0));
      end
      else if (BANKS_PER_WRITE == 4) begin
         assign afi_ba_int = issue_cmd_0 ? {4'b0000, 4'b0000+(bank_counter<<2), 4'b0000, 4'b0001+(bank_counter<<2)} : (
                             issue_cmd_1 ? {4'b0000, 4'b0011+(bank_counter<<2), 4'b0000, 4'b0010+(bank_counter<<2)} : (
                             '0));
      end
      else begin
         assign afi_ba_int = {cmd_counter[1:0], 2'b11, cmd_counter[1:0], 2'b10, cmd_counter[1:0], 2'b01, cmd_counter[1:0], 2'b00};
      end   
   
      if (BANKS_PER_WRITE == 4) begin
         if (MEM_BURST_LENGTH == 2) begin
            assign cmd         = (loop_counter[1:0] == 2'b00) ? 8'b10101010 : (
                                 (loop_counter[1:0] == 2'b01) ? 8'b10111011 : (
                                 (loop_counter[1:0] == 2'b10) ? 8'b11111110 : (
                                                                8'b11101111 )));

            assign cmd_data_en = (loop_counter[1:0] == 2'b00) ? 8'b01010101 : (
                                 (loop_counter[1:0] == 2'b01) ? 8'b01000100 : (
                                 (loop_counter[1:0] == 2'b10) ? 8'b00000001 : (
                                                                8'b00010000 )));
         end
         else if (MEM_BURST_LENGTH == 4) begin
            assign cmd         = (loop_counter[1:0] == 2'b00) ? 8'b10101010 : (
                                 (loop_counter[1:0] == 2'b01) ? 8'b10111011 : (
                                 (loop_counter[1:0] == 2'b10) ? 8'b11111110 : (
                                                                8'b11101111 )));

            assign cmd_data_en = (loop_counter[1:0] == 2'b00) ? 8'b11111111 : (
                                 (loop_counter[1:0] == 2'b01) ? 8'b11001100 : (
                                 (loop_counter[1:0] == 2'b10) ? 8'b00000011 : (
                                                                8'b00110000 )));
         end
         else if (MEM_BURST_LENGTH == 8) begin
            assign cmd         = (loop_counter[1:0] == 2'b00) ? 8'b11101110 : (
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
            assign cmd         =  loop_counter[AFI_RATE_RATIO*2-1:0];
            assign cmd_data_en = ~loop_counter[AFI_RATE_RATIO*2-1:0];
         end
         else if (MEM_BURST_LENGTH == 4) begin
            assign cmd         = (loop_counter[1:0] == 2'b00) ? 8'b10101010 : (
                                 (loop_counter[1:0] == 2'b01) ? 8'b11010101 : (
                                 (loop_counter[1:0] == 2'b10) ? 8'b10110110 : (
                                                                8'b11101110 )));

            assign cmd_data_en = (loop_counter[1:0] == 2'b00) ? 8'b11111111 : (
                                 (loop_counter[1:0] == 2'b01) ? 8'b01111110 : (
                                 (loop_counter[1:0] == 2'b10) ? 8'b11011011 : (
                                                                8'b00110011 )));
         end
         else if (MEM_BURST_LENGTH == 8) begin
            assign cmd         = (loop_counter[1:0] == 2'b00) ? 8'b11101110 : (
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
         assign afi_ba_int = issue_cmd_0 ? {4'b0010+(bank_counter<<3), 4'b0001+(bank_counter<<3)} : (
                             issue_cmd_1 ? {4'b0110+(bank_counter<<3), 4'b0011+(bank_counter<<3)} : (
                             '0));
      end
      else if (BANKS_PER_WRITE == 4) begin
         assign afi_ba_int = issue_cmd_0 ? {4'b0010+(bank_counter<<2), 4'b0001+(bank_counter<<2)} : (
                             issue_cmd_1 ? {4'b0000+(bank_counter<<2), 4'b0011+(bank_counter<<2)} : (
                             '0));
      end
      else begin
         assign afi_ba_int = {cmd_counter[2:0], 1'b1, cmd_counter[2:0], 1'b0};
      end   
   
      if (MEM_BURST_LENGTH == 2) begin
         assign cmd         =  loop_counter[AFI_RATE_RATIO*2-1:0];
         assign cmd_data_en = ~loop_counter[AFI_RATE_RATIO*2-1:0];
      end
      else if (MEM_BURST_LENGTH == 4) begin
         assign cmd         = (loop_counter[1:0] == 2'b00) ? 4'b1010 : (
                              (loop_counter[1:0] == 2'b01) ? 4'b1101 : (
                              (loop_counter[1:0] == 2'b10) ? 4'b1011 : (
                                                             4'b1110 )));

         assign cmd_data_en = (loop_counter[1:0] == 2'b00) ? 4'b1111 : (
                              (loop_counter[1:0] == 2'b01) ? 4'b0110 : (
                              (loop_counter[1:0] == 2'b10) ? 4'b1100 : (
                                                             4'b0011 )));
      end
      else if (MEM_BURST_LENGTH == 8) begin
         assign cmd         = (loop_counter[1:0] == 2'b00) ? 4'b1110 : (
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

//////////////////////////////////////////////////////////////////////////////
// Generate simple read/write data patterns based on counter
//////////////////////////////////////////////////////////////////////////////

reg [LOOP_COUNTER_WIDTH-1:0]  wdata_pattern;
reg [LOOP_COUNTER_WIDTH-1:0]  rdata_pattern;

always_ff @(posedge afi_clk, negedge afi_reset_n) begin
   if (! afi_reset_n) begin
      wdata_pattern <= '0;
      rdata_pattern <= '0;
   end else begin
      if (MRS_WRITE_PROTOCOL == 0) begin
         if (|afi_wdata_valid)
            wdata_pattern <= wdata_pattern + 1;
         
         if (|afi_rdata_valid)
            rdata_pattern <= rdata_pattern + 1;
      end else begin
         wdata_pattern <= loop_counter;
         rdata_pattern <= loop_counter;
      end
   end
end

wire [AFI_DQ_WIDTH-1:0] full_wdata_pattern = {(AFI_DQ_WIDTH/LOOP_COUNTER_WIDTH){wdata_pattern}};
wire [AFI_DQ_WIDTH-1:0] full_rdata_pattern = {(AFI_DQ_WIDTH/LOOP_COUNTER_WIDTH){rdata_pattern}};

assign afi_wdata = full_wdata_pattern;

generate
   genvar k;
   for (k = 0; k < AFI_RATE_RATIO; k = k + 1)
   begin : gen_rdata_loop_timeslot
      assign expected_afi_rdata[DQ_DDR_WIDTH*(k+1)-1 : DQ_DDR_WIDTH*k] = afi_rdata_valid[k] ? 
         full_rdata_pattern[DQ_DDR_WIDTH*(k+1)-1 : DQ_DDR_WIDTH*k] : '0;
         
      assign masked_afi_rdata[DQ_DDR_WIDTH*(k+1)-1 : DQ_DDR_WIDTH*k] = afi_rdata_valid[k] ?
         afi_rdata[DQ_DDR_WIDTH*(k+1)-1 : DQ_DDR_WIDTH*k] : '0;
   end
endgenerate

always_ff @(posedge afi_clk, negedge afi_reset_n)
begin
   if (!afi_reset_n)
      read_failed <= 1'b0;
   else if (expected_afi_rdata != masked_afi_rdata)
      read_failed <= 1'b1;
end

//////////////////////////////////////////////////////////////////////////////
// Pass/Fail Status Logic
//////////////////////////////////////////////////////////////////////////////

`ifdef ENABLE_ISS_PROBES
reg [AFI_DQ_WIDTH-1:0] pnf_per_bit_r;
reg [AFI_DQ_WIDTH-1:0] pnf_per_bit_persist_r;
reg pass_r;
reg fail_r;
reg timeout_r;
reg test_complete_r;
reg [31:0] loop_counter_r;
reg [31:0] loop_counter_persist_r;

always_ff @(posedge afi_clk, negedge afi_reset_n)
begin
   if (! afi_reset_n) begin
      pass_r <= '0;
      fail_r <= '0;
      timeout_r <= '0;
      test_complete_r <= '0;
      loop_counter_r <= '0;
      pnf_per_bit_r <= '0;
      pnf_per_bit_persist_r <= '0;
      loop_counter_persist_r <= '0;
   end else begin
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

