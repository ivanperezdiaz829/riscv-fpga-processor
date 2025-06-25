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


program phylite_sim_ctrl #(
	// Top Level parameters
	parameter PHYLITE_NUM_GROUPS                      = 1,
	parameter PHYLITE_RATE_ENUM                       = "RATE_IN_QUARTER",
	parameter PHYLITE_USE_DYNAMIC_RECONFIGURATION     = 0,

	// Group Parameters
	parameter GROUP_0_PIN_TYPE                        = "BIDIR",
	parameter GROUP_0_PIN_WIDTH                       = 9,
	parameter GROUP_0_DDR_SDR_MODE                    = "DDR",
	parameter GROUP_0_USE_OUTPUT_STROBE               = 1,
	parameter GROUP_1_PIN_TYPE                        = "BIDIR",
	parameter GROUP_1_PIN_WIDTH                       = 9,
	parameter GROUP_1_DDR_SDR_MODE                    = "DDR",
	parameter GROUP_1_USE_OUTPUT_STROBE               = 1,
	parameter GROUP_2_PIN_TYPE                        = "BIDIR",
	parameter GROUP_2_PIN_WIDTH                       = 9,
	parameter GROUP_2_DDR_SDR_MODE                    = "DDR",
	parameter GROUP_2_USE_OUTPUT_STROBE               = 1,
	parameter GROUP_3_PIN_TYPE                        = "BIDIR",
	parameter GROUP_3_PIN_WIDTH                       = 9,
	parameter GROUP_3_DDR_SDR_MODE                    = "DDR",
	parameter GROUP_3_USE_OUTPUT_STROBE               = 1,
	parameter GROUP_4_PIN_TYPE                        = "BIDIR",
	parameter GROUP_4_PIN_WIDTH                       = 9,
	parameter GROUP_4_DDR_SDR_MODE                    = "DDR",
	parameter GROUP_4_USE_OUTPUT_STROBE               = 1,
	parameter GROUP_5_PIN_TYPE                        = "BIDIR",
	parameter GROUP_5_PIN_WIDTH                       = 9,
	parameter GROUP_5_DDR_SDR_MODE                    = "DDR",
	parameter GROUP_5_USE_OUTPUT_STROBE               = 1,
	parameter GROUP_6_PIN_TYPE                        = "BIDIR",
	parameter GROUP_6_PIN_WIDTH                       = 9,
	parameter GROUP_6_DDR_SDR_MODE                    = "DDR",
	parameter GROUP_6_USE_OUTPUT_STROBE               = 1,
	parameter GROUP_7_PIN_TYPE                        = "BIDIR",
	parameter GROUP_7_PIN_WIDTH                       = 9,
	parameter GROUP_7_DDR_SDR_MODE                    = "DDR",
	parameter GROUP_7_USE_OUTPUT_STROBE               = 1,
	parameter GROUP_8_PIN_TYPE                        = "BIDIR",
	parameter GROUP_8_PIN_WIDTH                       = 9,
	parameter GROUP_8_DDR_SDR_MODE                    = "DDR",
	parameter GROUP_8_USE_OUTPUT_STROBE               = 1,
	parameter GROUP_9_PIN_TYPE                        = "BIDIR",
	parameter GROUP_9_PIN_WIDTH                       = 9,
	parameter GROUP_9_DDR_SDR_MODE                    = "DDR",
	parameter GROUP_9_USE_OUTPUT_STROBE               = 1,
	parameter GROUP_10_PIN_TYPE                       = "BIDIR",
	parameter GROUP_10_PIN_WIDTH                      = 9,
	parameter GROUP_10_DDR_SDR_MODE                   = "DDR",
	parameter GROUP_10_USE_OUTPUT_STROBE              = 1,
	parameter GROUP_11_PIN_TYPE                       = "BIDIR",
	parameter GROUP_11_PIN_WIDTH                      = 9,
	parameter GROUP_11_DDR_SDR_MODE                   = "DDR",
	parameter GROUP_11_USE_OUTPUT_STROBE              = 1
	) (
	// Clock and Start
	start,
	core_clk,
	
	// Core Interface
	oe_from_sim_ctrl,
	data_from_sim_ctrl,
	data_to_sim_ctrl,
	rdata_en_from_sim_ctrl,
	rdata_valid_to_sim_ctrl,
	strobe_oe_from_sim_ctrl,
	grp_sel,

	// ADDR/CMD Core Interface
	core_cmd_out,
	core_cmd_out_oe,
	core_cmd_clk,
	core_cmd_clk_oe,
	
	// ADDR/CMD Mem Interface
	mem_cmd_in,
	mem_cmd_clk,

	// Side Interface
	side_write,
	side_read,
	side_write_data,
	side_read_data,
	side_readdata_valid,
	side_readaddr,
	agent_select
	);
	timeunit 1ps;
	timeprecision 1ps;

	////////////////////////////////////////////////////////////////////////////
	// Local Parameters
	////////////////////////////////////////////////////////////////////////////

	// Agent Params
	localparam FIFO_ADDR_WIDTH = 3;
	localparam AGENT_FIFO_DEPTH = 8;   

	// This is used for $random as it returns a 32-bit random number
	localparam WRITE_GROUPS = 1;

	localparam string GROUP_PIN_TYPE             [0:11] = '{ GROUP_0_PIN_TYPE            ,
	                                                         GROUP_1_PIN_TYPE            ,
	                                                         GROUP_2_PIN_TYPE            ,
	                                                         GROUP_3_PIN_TYPE            ,
	                                                         GROUP_4_PIN_TYPE            ,
	                                                         GROUP_5_PIN_TYPE            ,
	                                                         GROUP_6_PIN_TYPE            ,
	                                                         GROUP_7_PIN_TYPE            ,
	                                                         GROUP_8_PIN_TYPE            ,
	                                                         GROUP_9_PIN_TYPE            ,
	                                                         GROUP_10_PIN_TYPE           ,
	                                                         GROUP_11_PIN_TYPE           };
	localparam integer GROUP_PIN_WIDTH           [0:11] = '{ GROUP_0_PIN_WIDTH           ,
	                                                         GROUP_1_PIN_WIDTH           ,
	                                                         GROUP_2_PIN_WIDTH           ,
	                                                         GROUP_3_PIN_WIDTH           ,
	                                                         GROUP_4_PIN_WIDTH           ,
	                                                         GROUP_5_PIN_WIDTH           ,
	                                                         GROUP_6_PIN_WIDTH           ,
	                                                         GROUP_7_PIN_WIDTH           ,
	                                                         GROUP_8_PIN_WIDTH           ,
	                                                         GROUP_9_PIN_WIDTH           ,
	                                                         GROUP_10_PIN_WIDTH          ,
	                                                         GROUP_11_PIN_WIDTH          };
	localparam string GROUP_DDR_SDR_MODE         [0:11] = '{ GROUP_0_DDR_SDR_MODE        ,
	                                                         GROUP_1_DDR_SDR_MODE        ,
	                                                         GROUP_2_DDR_SDR_MODE        ,
	                                                         GROUP_3_DDR_SDR_MODE        ,
	                                                         GROUP_4_DDR_SDR_MODE        ,
	                                                         GROUP_5_DDR_SDR_MODE        ,
	                                                         GROUP_6_DDR_SDR_MODE        ,
	                                                         GROUP_7_DDR_SDR_MODE        ,
	                                                         GROUP_8_DDR_SDR_MODE        ,
	                                                         GROUP_9_DDR_SDR_MODE        ,
	                                                         GROUP_10_DDR_SDR_MODE       ,
	                                                         GROUP_11_DDR_SDR_MODE       };
	localparam integer GROUP_USE_OUTPUT_STROBE   [0:11] = '{ GROUP_0_USE_OUTPUT_STROBE   ,
	                                                         GROUP_1_USE_OUTPUT_STROBE   ,
	                                                         GROUP_2_USE_OUTPUT_STROBE   ,
	                                                         GROUP_3_USE_OUTPUT_STROBE   ,
	                                                         GROUP_4_USE_OUTPUT_STROBE   ,
	                                                         GROUP_5_USE_OUTPUT_STROBE   ,
	                                                         GROUP_6_USE_OUTPUT_STROBE   ,
	                                                         GROUP_7_USE_OUTPUT_STROBE   ,
	                                                         GROUP_8_USE_OUTPUT_STROBE   ,
	                                                         GROUP_9_USE_OUTPUT_STROBE   ,
	                                                         GROUP_10_USE_OUTPUT_STROBE  ,
	                                                         GROUP_11_USE_OUTPUT_STROBE  };

	// Group Core Interface Widths
	localparam integer RATE_MULT =  (PHYLITE_RATE_ENUM == "RATE_IN_QUARTER") ? 4 :
	                                (PHYLITE_RATE_ENUM == "RATE_IN_HALF")    ? 2 :
	                                                                           1 ;

	localparam integer GROUP_DDR_MULT [0:11] = '{ (GROUP_0_DDR_SDR_MODE == "DDR")  ? 2 : 1,
	                                              (GROUP_1_DDR_SDR_MODE == "DDR")  ? 2 : 1,
	                                              (GROUP_2_DDR_SDR_MODE == "DDR")  ? 2 : 1,
	                                              (GROUP_3_DDR_SDR_MODE == "DDR")  ? 2 : 1,
	                                              (GROUP_4_DDR_SDR_MODE == "DDR")  ? 2 : 1,
	                                              (GROUP_5_DDR_SDR_MODE == "DDR")  ? 2 : 1,
	                                              (GROUP_6_DDR_SDR_MODE == "DDR")  ? 2 : 1,
	                                              (GROUP_7_DDR_SDR_MODE == "DDR")  ? 2 : 1,
	                                              (GROUP_8_DDR_SDR_MODE == "DDR")  ? 2 : 1,
	                                              (GROUP_9_DDR_SDR_MODE == "DDR")  ? 2 : 1,
	                                              (GROUP_10_DDR_SDR_MODE == "DDR") ? 2 : 1,
	                                              (GROUP_11_DDR_SDR_MODE == "DDR") ? 2 : 1 };

	localparam integer GROUP_PIN_DATA_WIDTH [0:11] = '{ RATE_MULT * GROUP_DDR_MULT[0],
	                                                    RATE_MULT * GROUP_DDR_MULT[1],
	                                                    RATE_MULT * GROUP_DDR_MULT[2],
	                                                    RATE_MULT * GROUP_DDR_MULT[3],
	                                                    RATE_MULT * GROUP_DDR_MULT[4],
	                                                    RATE_MULT * GROUP_DDR_MULT[5],
	                                                    RATE_MULT * GROUP_DDR_MULT[6],
	                                                    RATE_MULT * GROUP_DDR_MULT[7],
	                                                    RATE_MULT * GROUP_DDR_MULT[8],
	                                                    RATE_MULT * GROUP_DDR_MULT[9],
	                                                    RATE_MULT * GROUP_DDR_MULT[10],
	                                                    RATE_MULT * GROUP_DDR_MULT[11] };

	localparam integer GROUP_DATA_WIDTH [0:11] = '{ GROUP_0_PIN_WIDTH  * GROUP_PIN_DATA_WIDTH[0],
	                                                GROUP_1_PIN_WIDTH  * GROUP_PIN_DATA_WIDTH[1],
	                                                GROUP_2_PIN_WIDTH  * GROUP_PIN_DATA_WIDTH[2],
	                                                GROUP_3_PIN_WIDTH  * GROUP_PIN_DATA_WIDTH[3],
	                                                GROUP_4_PIN_WIDTH  * GROUP_PIN_DATA_WIDTH[4],
	                                                GROUP_5_PIN_WIDTH  * GROUP_PIN_DATA_WIDTH[5],
	                                                GROUP_6_PIN_WIDTH  * GROUP_PIN_DATA_WIDTH[6],
	                                                GROUP_7_PIN_WIDTH  * GROUP_PIN_DATA_WIDTH[7],
	                                                GROUP_8_PIN_WIDTH  * GROUP_PIN_DATA_WIDTH[8],
	                                                GROUP_9_PIN_WIDTH  * GROUP_PIN_DATA_WIDTH[9],
	                                                GROUP_10_PIN_WIDTH * GROUP_PIN_DATA_WIDTH[10],
	                                                GROUP_11_PIN_WIDTH * GROUP_PIN_DATA_WIDTH[11] };

	localparam integer GROUP_PIN_OE_WIDTH [0:11] = '{ RATE_MULT,
	                                                  RATE_MULT,
	                                                  RATE_MULT,
	                                                  RATE_MULT,
	                                                  RATE_MULT,
	                                                  RATE_MULT,
	                                                  RATE_MULT,
	                                                  RATE_MULT,
	                                                  RATE_MULT,
	                                                  RATE_MULT,
	                                                  RATE_MULT,
	                                                  RATE_MULT };

	localparam integer GROUP_OE_WIDTH [0:11] =  '{ GROUP_0_PIN_WIDTH  * GROUP_PIN_OE_WIDTH[0],
	                                               GROUP_1_PIN_WIDTH  * GROUP_PIN_OE_WIDTH[1],
	                                               GROUP_2_PIN_WIDTH  * GROUP_PIN_OE_WIDTH[2],
	                                               GROUP_3_PIN_WIDTH  * GROUP_PIN_OE_WIDTH[3],
	                                               GROUP_4_PIN_WIDTH  * GROUP_PIN_OE_WIDTH[4],
	                                               GROUP_5_PIN_WIDTH  * GROUP_PIN_OE_WIDTH[5],
	                                               GROUP_6_PIN_WIDTH  * GROUP_PIN_OE_WIDTH[6],
	                                               GROUP_7_PIN_WIDTH  * GROUP_PIN_OE_WIDTH[7],
	                                               GROUP_8_PIN_WIDTH  * GROUP_PIN_OE_WIDTH[8],
	                                               GROUP_9_PIN_WIDTH  * GROUP_PIN_OE_WIDTH[9],
	                                               GROUP_10_PIN_WIDTH * GROUP_PIN_OE_WIDTH[10],
	                                               GROUP_11_PIN_WIDTH * GROUP_PIN_OE_WIDTH[11] };

	localparam integer GROUP_STROBE_PIN_OE_WIDTH [0:11] = '{ RATE_MULT,
	                                                         RATE_MULT,
	                                                         RATE_MULT,
	                                                         RATE_MULT,
	                                                         RATE_MULT,
	                                                         RATE_MULT,
	                                                         RATE_MULT,
	                                                         RATE_MULT,
	                                                         RATE_MULT,
	                                                         RATE_MULT,
	                                                         RATE_MULT,
	                                                         RATE_MULT };

	localparam integer GROUP_OUTPUT_STROBE_OE_WIDTH [0:11] = '{ GROUP_STROBE_PIN_OE_WIDTH[0],
	                                                            GROUP_STROBE_PIN_OE_WIDTH[1],
	                                                            GROUP_STROBE_PIN_OE_WIDTH[2],
	                                                            GROUP_STROBE_PIN_OE_WIDTH[3],
	                                                            GROUP_STROBE_PIN_OE_WIDTH[4],
	                                                            GROUP_STROBE_PIN_OE_WIDTH[5],
	                                                            GROUP_STROBE_PIN_OE_WIDTH[6],
	                                                            GROUP_STROBE_PIN_OE_WIDTH[7],
	                                                            GROUP_STROBE_PIN_OE_WIDTH[8],
	                                                            GROUP_STROBE_PIN_OE_WIDTH[9],
	                                                            GROUP_STROBE_PIN_OE_WIDTH[10],
	                                                            GROUP_STROBE_PIN_OE_WIDTH[11] };

	// Sim Ctrl Core Interface Widths
	localparam integer SIM_CTRL_OE_WIDTH   = 48 * RATE_MULT;
	localparam integer SIM_CTRL_DATA_WIDTH = 48 * 2 * RATE_MULT;

	// Sim Ctrl ADDR/CMD Core Interface Widths
	localparam integer SIM_CTRL_CMD_WIDTH     = (3 + PHYLITE_NUM_GROUPS) * RATE_MULT;
	localparam integer SIM_CTRL_CMD_CLK_WIDTH = RATE_MULT * 2;

	// Sim Ctrl ADDR/CMD Memory Interface Widths
	localparam integer SIM_CTRL_MEM_CMD_WIDTH = 3 + PHYLITE_NUM_GROUPS;

	////////////////////////////////////////////////////////////////////////////
	// Port Declarations
	////////////////////////////////////////////////////////////////////////////
	// Clock and Start
	input logic start   ;
	input logic core_clk;
	
	// Core Interface
	output logic   [SIM_CTRL_OE_WIDTH - 1 : 0] oe_from_sim_ctrl       ;
	output logic [SIM_CTRL_DATA_WIDTH - 1 : 0] data_from_sim_ctrl     ;
	input  logic [SIM_CTRL_DATA_WIDTH - 1 : 0] data_to_sim_ctrl       ;
	output logic           [RATE_MULT - 1 : 0] rdata_en_from_sim_ctrl ;
	input  logic           [RATE_MULT - 1 : 0] rdata_valid_to_sim_ctrl;
	output logic           [RATE_MULT - 1 : 0] strobe_oe_from_sim_ctrl;
	output logic  [PHYLITE_NUM_GROUPS - 1 : 0] grp_sel                ;

	// ADDR/CMD Core Interface
	output logic     [SIM_CTRL_CMD_WIDTH - 1 : 0] core_cmd_out   ;
	output logic     [SIM_CTRL_CMD_WIDTH - 1 : 0] core_cmd_out_oe;
	output logic [SIM_CTRL_CMD_CLK_WIDTH - 1 : 0] core_cmd_clk   ;
	output logic              [RATE_MULT - 1 : 0] core_cmd_clk_oe;
	
	// ADDR/CMD Mem Interface
	input logic [SIM_CTRL_MEM_CMD_WIDTH - 1 : 0] mem_cmd_in;
	input logic                                  mem_cmd_clk;

	// Side Interface
	output logic                              side_write         ;
	output logic                              side_read          ;
	output logic                     [95 : 0] side_write_data    ;
	input  logic                     [95 : 0] side_read_data     ;
	input  logic                              side_readdata_valid;
	output logic                      [3 : 0] side_readaddr      ;
	output logic [PHYLITE_NUM_GROUPS - 1 : 0] agent_select       ;

	////////////////////////////////////////////////////////////////////////////
	// Wire Declarations
	////////////////////////////////////////////////////////////////////////////
	// ADDR/CMD Core Interface
	logic                              core_cmd_mem_rst_n;
	logic                              core_cmd_mem_rd   ;
	logic                              core_cmd_mem_wr   ;
	logic [PHYLITE_NUM_GROUPS - 1 : 0] core_cmd_mem_sel  ;
	logic                              core_cmd_en       ;

	// Write Path
	logic                      [47 : 0] out_data_buf        [(2 * RATE_MULT) - 1 : 0]      ; // random data buffer
	logic [SIM_CTRL_DATA_WIDTH - 1 : 0] out_data_bus                                       ;
	logic                      [95 : 0] expected_write_data [((2 * RATE_MULT) / 2) - 1 : 0];

	// Read Path
	logic                  [47 : 0] expected_read_data [(2 * AGENT_FIFO_DEPTH) - 1 : 0]; //save read_data
	logic [FIFO_ADDR_WIDTH - 1 : 0] ram_addr                                           ; //counter for expected_read_data
	logic                  [95 : 0] read_value;
	logic                  [47 : 0] data_to_core_buf [(2 * RATE_MULT) - 1 : 0];
	logic [FIFO_ADDR_WIDTH - 1 : 0] rdaddr;

	// Error Tracking
	logic has_error;

	////////////////////////////////////////////////////////////////////////////
	// Assignments
	////////////////////////////////////////////////////////////////////////////
	// ADDR/CMD Core Interface
	assign core_cmd_mem_sel = grp_sel;
	assign core_cmd_out[(3 * RATE_MULT) - 1 : 0] = {{RATE_MULT{core_cmd_mem_wr}}, {RATE_MULT{core_cmd_mem_rd}}, {RATE_MULT{core_cmd_mem_rst_n}}};
	generate
		genvar i;
		for (i = 0; i < PHYLITE_NUM_GROUPS; i = i + 1) begin : core_sel_cmd_gen
			assign core_cmd_out[(RATE_MULT * (i + 4)) - 1 : (RATE_MULT * (i + 3))] = {RATE_MULT{core_cmd_mem_sel[i]}};
		end
	endgenerate
	assign core_cmd_out_oe = {SIM_CTRL_CMD_WIDTH{core_cmd_en}};
	assign core_cmd_clk    = {(SIM_CTRL_CMD_CLK_WIDTH / 2){2'b10}};
	assign core_cmd_clk_oe = {RATE_MULT{core_cmd_en}};

	// Side Interface
	assign agent_select = grp_sel;

	////////////////////////////////////////////////////////////////////////////
	// Main
	////////////////////////////////////////////////////////////////////////////
	integer grp_num;
 	initial 
 	begin: test_main
		// Core Interface Reset Values
		oe_from_sim_ctrl        = {SIM_CTRL_OE_WIDTH{1'b0}}  ;
		data_from_sim_ctrl      = {SIM_CTRL_DATA_WIDTH{1'b1}};
		rdata_en_from_sim_ctrl  = {RATE_MULT{1'b0}}          ;
		strobe_oe_from_sim_ctrl = {RATE_MULT{1'b0}}          ;
		grp_sel                 = {PHYLITE_NUM_GROUPS{1'b0}} ;

		// ADDR/CMD Core Interface Reset Values
		core_cmd_mem_rst_n = 1'b0;
		core_cmd_mem_rd    = 1'b0;
		core_cmd_mem_wr    = 1'b0;
		core_cmd_en        = 1'b0;

		// Side Interface Reset Values
		side_write      = 1'b0 ;
		side_read       = 1'b0 ;
		side_write_data = 96'd0;

		// Internal Reset Values
		rdaddr    = {FIFO_ADDR_WIDTH{1'b0}};
		ram_addr  = {FIFO_ADDR_WIDTH{1'b0}};
		has_error = 1'b0;
		
		wait(start == 1'b1);

		repeat (1024)
		    @(posedge core_clk);
		core_cmd_en = 1'b1;
		
		repeat (4)
		    @(posedge core_clk);
		core_cmd_mem_rst_n = 1'b1;

		// Allow reset release time to go out to agent
		repeat (4)
		    @(posedge core_clk);
		
		// Loop through and test all groups
		for (grp_num = 0; grp_num < PHYLITE_NUM_GROUPS; grp_num++) begin
			$display("==========================================");
			$display("========== Testing group %d", grp_num);
			$display("==========================================");
			grp_sel = 1 << grp_num;

			// write path test begins
			if (GROUP_PIN_TYPE[grp_num] == "OUTPUT" || GROUP_PIN_TYPE[grp_num] == "BIDIR") begin
			    $display("Starting Write...");
			
			    repeat (AGENT_FIFO_DEPTH) begin
				write_dut(); // write random data to dut
			
			        // wait for write data to complete
			        repeat (4)
			            @(posedge core_clk);
			
			        repeat (RATE_MULT) begin
			            read_and_cmp_agent( rdaddr ); // compare
			            rdaddr = rdaddr + 1;
			        end
			
			        @(posedge core_clk);
			    end
			end
			
			// read path test begins
			if (GROUP_PIN_TYPE[grp_num] == "INPUT" || GROUP_PIN_TYPE[grp_num] == "BIDIR") begin
			    $display("Starting Read...");
			
			
			    repeat (AGENT_FIFO_DEPTH) begin
			        // fill up the agent fifo depending on rate, only half because
			        // pos and neg data is written at the same time
			        // QR rate, write to 4 slots
			        // HR rate, write to 2 slots
			        // FR rate, write to 1 slot
			        repeat (RATE_MULT) begin
			            write_agent(ram_addr);  // write random data to agent
			            ram_addr = ram_addr + 1;
			        end
			
			        read_and_cmp_dut();
			        @(posedge mem_cmd_clk);
			        ram_addr = 0;
			    end
			end
		end
		
		#20000
		
		if (has_error == 1'b0)
		    $display("Simulation SUCCESS");
		else
		    $display("Simulation ERROR");
		
		$finish;
 	end 

	////////////////////////////////////////////////////////////////////////////
	// Tasks for bit manipulations
	////////////////////////////////////////////////////////////////////////////
	// Write to DUT
	task write_dut ();
	
		for( int i = 0; i < GROUP_PIN_DATA_WIDTH[grp_num]; i++ ) begin
			out_data_buf[i] = ($random << 32) | $random;
		end
		prepare_write_data();
		
		// strobe data tied-off in driver
		
		@(posedge core_clk);
		strobe_oe_from_sim_ctrl = {RATE_MULT{1'b0}};
		strobe_oe_from_sim_ctrl[GROUP_OUTPUT_STROBE_OE_WIDTH[grp_num] - 1] = 1'b1;
		
		// Write command is issued on this clock edge
		@(posedge core_clk);
		core_cmd_mem_wr = 1'b1;
		
		data_from_sim_ctrl = out_data_bus;
		for ( int i = 0; i < GROUP_OE_WIDTH[grp_num]; i++ ) begin
			oe_from_sim_ctrl[i] = 1'b1;
		end

		for ( int i = 0; i < GROUP_OUTPUT_STROBE_OE_WIDTH[grp_num]; i++ ) begin
			strobe_oe_from_sim_ctrl[i] = 1'b1;
		end
		
		// Deassert write command
		@(posedge core_clk);
		core_cmd_mem_wr = 1'b0;
		
		data_from_sim_ctrl      = {SIM_CTRL_DATA_WIDTH{1'bx}};
		oe_from_sim_ctrl        = {SIM_CTRL_OE_WIDTH{1'b0}};
		strobe_oe_from_sim_ctrl = {RATE_MULT{1'b0}};
	
	
	endtask

	// Arrange expected write data to align with read from side channel
	task prepare_write_data ();
		// t stands for Time slot. Time slot is a function of rate: FR=2, HR=4, QR=8
		// p stands for Pin. 
		for( int t = 0; t < GROUP_PIN_DATA_WIDTH[grp_num]; t++ ) begin
			for( int p = 0; p < GROUP_PIN_WIDTH[grp_num]; p++ ) begin
				out_data_bus[(p * GROUP_PIN_DATA_WIDTH[grp_num]) + t] = out_data_buf[t][p];
			end
		end

 		for( int t = 0; t < GROUP_PIN_DATA_WIDTH[grp_num]/GROUP_DDR_MULT[grp_num]; t++ ) begin
			expected_write_data[t] = 96'd0;
			for ( int p = 0; p < GROUP_PIN_WIDTH[grp_num]; p++ ) begin
 				if (GROUP_DDR_SDR_MODE[grp_num] == "DDR") begin
					expected_write_data[t][p]                            = out_data_buf[2 * t][p];
					expected_write_data[t][p + GROUP_PIN_WIDTH[grp_num]] = out_data_buf[(2 * t) + 1][p];
 				end else begin
					expected_write_data[t][p]                            = out_data_buf[t][p];
					expected_write_data[t][p + GROUP_PIN_WIDTH[grp_num]] = out_data_buf[t][p];
				end
			end
 		end
	endtask

	// Read from DUT and compare
 	task read_and_cmp_dut ();
 		@(posedge core_clk)
 		core_cmd_mem_rd = 1'b1;
 		rdata_en_from_sim_ctrl <= {{RATE_MULT}{1'b1}};

 		@(posedge core_clk);
 		core_cmd_mem_rd = 1'b0;
 		rdata_en_from_sim_ctrl <= {{RATE_MULT}{1'b0}};

 		
 		@(posedge rdata_valid_to_sim_ctrl[0]);
		collect_read_data();

 		ram_addr = 0;
 		repeat (GROUP_PIN_DATA_WIDTH[grp_num]) begin
 			if ( ((expected_read_data[ram_addr]) !== (data_to_core_buf[ram_addr])) ) begin
 				$display("Error: read: time %d: DUT read 0x%h, expected 0x%h, time slot %d", $time, (data_to_core_buf[ram_addr]), (expected_read_data[ram_addr]), ram_addr );
 				has_error <= 1;
 			end else begin
 				$display("Correct: read: time %d: DUT read 0x%h, expected 0x%h, time slot %d", $time, (data_to_core_buf[ram_addr]), (expected_read_data[ram_addr]), ram_addr );
 			end
 			ram_addr = ram_addr+1;
 		end
 	endtask

	// Rewire read data
	task collect_read_data ();
 		for( int t = 0; t < GROUP_PIN_DATA_WIDTH[grp_num]; t++ ) begin
 			for( int p = 0; p < 48; p++ ) begin
				if (p < GROUP_PIN_WIDTH[grp_num]) begin
 					data_to_core_buf[t][p] = data_to_sim_ctrl[(p * GROUP_PIN_DATA_WIDTH[grp_num]) + t] ;
				end else begin
 					data_to_core_buf[t][p] = 1'b0;
				end
 			end
 		end
	endtask

	// Write to the agent
	task write_agent (reg [FIFO_ADDR_WIDTH-1:0] addr);
		// Randomize read data and mask out irrelevant bits
		read_value = ($random << 64) | ($random << 32) | $random;
		for ( int i = GROUP_PIN_WIDTH[grp_num]; i < 48; i++ ) begin
			read_value[i]      = 1'b0;
			read_value[i + 48] = 1'b0;
		end

		// Overwrite negedge data with same data for SDR
		if (GROUP_DDR_SDR_MODE[grp_num] == "SDR") begin
			read_value[95:48] = read_value[47:0];
		end
		
		@(negedge mem_cmd_clk) 
			side_write_data <= read_value;
		
		@(posedge mem_cmd_clk) begin
			side_write <= 1'b1;
			if (GROUP_DDR_SDR_MODE[grp_num] == "DDR") begin
				expected_read_data[2*addr]     <= read_value[47 : 0] ;
				expected_read_data[(2*addr)+1] <= read_value[95 : 48];
			end else begin
				expected_read_data[addr] <= read_value[47 : 0] ;
			end
		end
		
		
		@(posedge mem_cmd_clk)
			side_write <= 1'b0;
	endtask
	
	// Read from agent and compare
	task read_and_cmp_agent (reg [FIFO_ADDR_WIDTH-1:0] addr);
		side_readaddr <= addr;
		
		@(posedge mem_cmd_clk)
			side_read <= 1'b1;
		
		#1;
		if ((side_read_data) !== (expected_write_data[addr%(GROUP_PIN_DATA_WIDTH[grp_num]/GROUP_DDR_MULT[grp_num])])) begin
			$display("Error: write: time %g: DUT written 0x%h, expected 0x%h", $time, (side_read_data), (expected_write_data[addr%(GROUP_PIN_DATA_WIDTH[grp_num]/GROUP_DDR_MULT[grp_num])]));
			has_error <= 1;
		end else begin
			$display("Correct: write: time %g: DUT written 0x%h, expected 0x%h", $time, (side_read_data), (expected_write_data[addr%(GROUP_PIN_DATA_WIDTH[grp_num]/GROUP_DDR_MULT[grp_num])]));
		end
		
		
		@(posedge mem_cmd_clk)
			side_read <= 1'b0;
		
		
		@(posedge mem_cmd_clk);
	endtask

endprogram

