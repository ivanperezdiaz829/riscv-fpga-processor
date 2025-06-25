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

`ifdef POST_CAL_DELAYS
import "DPI-C" function bit seq_done(input longint sim_time);
`endif
	
module altera_qdrii_board_delay_model_top #(
		MEM_IF_READ_DQS_WIDTH = 1,
		MEM_IF_DM_WIDTH = 4,
		MEM_IF_DQ_WIDTH = 36,
		MEM_IF_WRITE_DQS_WIDTH = 1,
		MEM_IF_ADDR_WIDTH = 19,
		MEM_IF_CS_WIDTH = 1,
		MEM_IF_CONTROL_WIDTH = 1,
		MEM_IF_BOARD_BASE_DELAY = 10
	)
	(
	tophy_mem_a,
	tophy_mem_bws_n,
	tophy_mem_cq,
	tophy_mem_cqn,
	tophy_mem_d,
	tophy_mem_k,
	tophy_mem_k_n,
	tophy_mem_q,
	tophy_mem_rps_n,
	tophy_mem_wps_n,
	tophy_mem_doff_n,

	tomem_mem_a,
	tomem_mem_bws_n,
	tomem_mem_cq,
	tomem_mem_cqn,
	tomem_mem_d,
	tomem_mem_k,
	tomem_mem_k_n,
	tomem_mem_q,
	tomem_mem_rps_n,
	tomem_mem_wps_n,
	tomem_mem_doff_n
);

input	 [MEM_IF_ADDR_WIDTH-1:0]	tophy_mem_a; 
input	 [MEM_IF_DM_WIDTH-1:0]		tophy_mem_bws_n;
output   [MEM_IF_READ_DQS_WIDTH-1:0] 	tophy_mem_cq;
output   [MEM_IF_READ_DQS_WIDTH-1:0] 	tophy_mem_cqn;
input    [MEM_IF_DQ_WIDTH-1:0] 		tophy_mem_d;
input    [MEM_IF_WRITE_DQS_WIDTH-1:0] 	tophy_mem_k;
input    [MEM_IF_WRITE_DQS_WIDTH-1:0] 	tophy_mem_k_n;
output   [MEM_IF_DQ_WIDTH-1:0] 		tophy_mem_q;
input    [MEM_IF_CS_WIDTH-1:0] 		tophy_mem_rps_n;
input    [MEM_IF_CS_WIDTH-1:0] 		tophy_mem_wps_n;
input    [MEM_IF_CONTROL_WIDTH-1:0] 	tophy_mem_doff_n;

output	 [MEM_IF_ADDR_WIDTH-1:0]	tomem_mem_a; 
output	 [MEM_IF_DM_WIDTH-1:0]		tomem_mem_bws_n;
input    [MEM_IF_READ_DQS_WIDTH-1:0] 	tomem_mem_cq;
input    [MEM_IF_READ_DQS_WIDTH-1:0] 	tomem_mem_cqn;
output   [MEM_IF_DQ_WIDTH-1:0] 		tomem_mem_d;
output   [MEM_IF_WRITE_DQS_WIDTH-1:0] 	tomem_mem_k;
output   [MEM_IF_WRITE_DQS_WIDTH-1:0] 	tomem_mem_k_n;
input    [MEM_IF_DQ_WIDTH-1:0] 		tomem_mem_q;
output   [MEM_IF_CS_WIDTH-1:0] 		tomem_mem_rps_n;
output   [MEM_IF_CS_WIDTH-1:0] 		tomem_mem_wps_n;
output   [MEM_IF_CONTROL_WIDTH-1:0] 	tomem_mem_doff_n;

string cfg_file = "board_delay_config.txt"; 
string cfg_file_postcal = "board_delay_config_postcal.txt"; 

integer base_delay[1] = {MEM_IF_BOARD_BASE_DELAY};

integer mem_a_dly[MEM_IF_ADDR_WIDTH];
integer mem_bws_n_dly[MEM_IF_DM_WIDTH];
integer mem_cq_dly[MEM_IF_READ_DQS_WIDTH];
integer mem_cqn_dly[MEM_IF_READ_DQS_WIDTH];
integer mem_d_dly[MEM_IF_DQ_WIDTH];
integer mem_k_dly[MEM_IF_WRITE_DQS_WIDTH];
integer mem_k_n_dly[MEM_IF_WRITE_DQS_WIDTH];
integer mem_q_dly[MEM_IF_DQ_WIDTH];
integer mem_rps_n_dly[MEM_IF_CS_WIDTH];
integer mem_wps_n_dly[MEM_IF_CS_WIDTH];
integer mem_doff_n_dly[MEM_IF_CONTROL_WIDTH];

integer mem_a_bad[MEM_IF_ADDR_WIDTH];
integer mem_bws_n_bad[MEM_IF_DM_WIDTH];
integer mem_cq_bad[MEM_IF_READ_DQS_WIDTH];
integer mem_cqn_bad[MEM_IF_READ_DQS_WIDTH];
integer mem_d_bad[MEM_IF_DQ_WIDTH];
integer mem_k_bad[MEM_IF_WRITE_DQS_WIDTH];
integer mem_k_n_bad[MEM_IF_WRITE_DQS_WIDTH];
integer mem_q_bad[MEM_IF_DQ_WIDTH];
integer mem_rps_n_bad[MEM_IF_CS_WIDTH];
integer mem_wps_n_bad[MEM_IF_CS_WIDTH];
integer mem_doff_n_bad[MEM_IF_CONTROL_WIDTH];


altera_board_delay_util delay_util();

task load_config;
	input string filename;
	begin
		integer idx;
                integer fp;

                fp = $fopen(filename, "r");
                if (fp == 0)
                begin
                        $display("Warning: cannot open %0s for configuring memory delays/windows", filename);
                        return;
                end
                $fclose(fp);

		
		delay_util.read_config(.file(filename), .name("base_delay"),    .delays(base_delay));
		
		delay_util.read_config(.file(filename), .name("mem_a_dly"),     .delays(mem_a_dly));
		delay_util.read_config(.file(filename), .name("mem_bws_n_dly"), .delays(mem_bws_n_dly));
		delay_util.read_config(.file(filename), .name("mem_cq_dly"),    .delays(mem_cq_dly));
		delay_util.read_config(.file(filename), .name("mem_cqn_dly"),   .delays(mem_cqn_dly));
		delay_util.read_config(.file(filename), .name("mem_d_dly"),     .delays(mem_d_dly));
		delay_util.read_config(.file(filename), .name("mem_k_dly"),     .delays(mem_k_dly));
		delay_util.read_config(.file(filename), .name("mem_k_n_dly"),   .delays(mem_k_n_dly));
		delay_util.read_config(.file(filename), .name("mem_q_dly"),     .delays(mem_q_dly));
		delay_util.read_config(.file(filename), .name("mem_rps_n_dly"), .delays(mem_rps_n_dly));
		delay_util.read_config(.file(filename), .name("mem_wps_n_dly"), .delays(mem_wps_n_dly));
		delay_util.read_config(.file(filename), .name("mem_doff_n_dly"),.delays(mem_doff_n_dly));
		
		delay_util.read_config(.file(filename), .name("mem_a_bad"),     .delays(mem_a_bad));
		delay_util.read_config(.file(filename), .name("mem_bws_n_bad"), .delays(mem_bws_n_bad));
		delay_util.read_config(.file(filename), .name("mem_cq_bad"),    .delays(mem_cq_bad));
		delay_util.read_config(.file(filename), .name("mem_cqn_bad"),   .delays(mem_cqn_bad));
		delay_util.read_config(.file(filename), .name("mem_d_bad"),     .delays(mem_d_bad));
		delay_util.read_config(.file(filename), .name("mem_k_bad"),     .delays(mem_k_bad));
		delay_util.read_config(.file(filename), .name("mem_k_n_bad"),   .delays(mem_k_n_bad));
		delay_util.read_config(.file(filename), .name("mem_q_bad"),     .delays(mem_q_bad));
		delay_util.read_config(.file(filename), .name("mem_rps_n_bad"), .delays(mem_rps_n_bad));
		delay_util.read_config(.file(filename), .name("mem_wps_n_bad"), .delays(mem_wps_n_bad));
		delay_util.read_config(.file(filename), .name("mem_doff_n_bad"),.delays(mem_doff_n_bad));
	end
endtask

initial load_config(cfg_file);

`ifdef POST_CAL_DELAYS
reg cal_done = 0;

always 
begin
	#10000;
	if (!cal_done && seq_done($time))
	begin
		$display("%0t: Calibration done; loading %s", $time, cfg_file_postcal);
		cal_done = 1;
		load_config(cfg_file_postcal);
	end
end
`endif

generate
	genvar i;

	for (i = 0; i < MEM_IF_ADDR_WIDTH; i = i + 1)
		unidir_delay mem_a_inst (.in(tophy_mem_a[i]), .out(tomem_mem_a[i]), 
					 .base_delay(base_delay[0]), .delay(mem_a_dly[i]), .bad(mem_a_bad[i]));
	
	for (i = 0; i < MEM_IF_DM_WIDTH; i = i + 1)
		unidir_delay mem_bws_n_inst (.in(tophy_mem_bws_n[i]), .out(tomem_mem_bws_n[i]), 
					 .base_delay(base_delay[0]), .delay(mem_bws_n_dly[i]), .bad(mem_bws_n_bad[i]));
	
	for (i = 0; i < MEM_IF_READ_DQS_WIDTH; i = i + 1)
		unidir_delay mem_cq_inst (.in(tomem_mem_cq[i]), .out(tophy_mem_cq[i]),
					 .base_delay(base_delay[0]), .delay(mem_cq_dly[i]), .bad(mem_cq_bad[i]));
		
	for (i = 0; i < MEM_IF_READ_DQS_WIDTH; i = i + 1)
		unidir_delay mem_cqn_inst (.in(tomem_mem_cqn[i]), .out(tophy_mem_cqn[i]),
					 .base_delay(base_delay[0]), .delay(mem_cqn_dly[i]), .bad(mem_cqn_bad[i]));
		
	for (i = 0; i < MEM_IF_DQ_WIDTH; i = i + 1)
		bidir_delay mem_d_inst (.mem(tomem_mem_d[i]), .phy(tophy_mem_d[i]),
					 .base_delay(base_delay[0]), .delay(mem_d_dly[i]), .bad(mem_d_bad[i]));
	
	for (i = 0; i < MEM_IF_WRITE_DQS_WIDTH; i = i + 1)
		unidir_delay mem_k_inst (.in(tophy_mem_k[i]), .out(tomem_mem_k[i]),
					 .base_delay(base_delay[0]), .delay(mem_k_dly[i]), .bad(mem_k_bad[i]));
		
	for (i = 0; i < MEM_IF_WRITE_DQS_WIDTH; i = i + 1)
		unidir_delay mem_k_n_inst (.in(tophy_mem_k_n[i]), .out(tomem_mem_k_n[i]),
					 .base_delay(base_delay[0]), .delay(mem_k_n_dly[i]), .bad(mem_k_n_bad[i]));
		
	for (i = 0; i < MEM_IF_DQ_WIDTH; i = i + 1)
		bidir_delay mem_q_inst (.mem(tomem_mem_q[i]), .phy(tophy_mem_q[i]),
					 .base_delay(base_delay[0]), .delay(mem_q_dly[i]), .bad(mem_q_bad[i]));
	
	for (i = 0; i < MEM_IF_CS_WIDTH; i = i + 1)
		unidir_delay mem_rps_n_inst (.in(tophy_mem_rps_n[i]), .out(tomem_mem_rps_n[i]),
					 .base_delay(base_delay[0]), .delay(mem_rps_n_dly[i]), .bad(mem_rps_n_bad[i]));
		
	for (i = 0; i < MEM_IF_CS_WIDTH; i = i + 1)
		unidir_delay mem_wps_n_inst (.in(tophy_mem_wps_n[i]), .out(tomem_mem_wps_n[i]),
					 .base_delay(base_delay[0]), .delay(mem_wps_n_dly[i]), .bad(mem_wps_n_bad[i]));
		
	for (i = 0; i < MEM_IF_CONTROL_WIDTH; i = i + 1)
		unidir_delay mem_doff_n_inst (.in(tophy_mem_doff_n[i]), .out(tomem_mem_doff_n[i]),
					 .base_delay(base_delay[0]), .delay(mem_doff_n_dly[i]), .bad(mem_doff_n_bad[i]));
		
endgenerate

endmodule
