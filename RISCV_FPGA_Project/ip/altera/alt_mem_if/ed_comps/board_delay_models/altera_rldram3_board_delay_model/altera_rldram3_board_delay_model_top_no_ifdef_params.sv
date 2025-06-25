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


`ifdef POST_CAL_DELAYS
import "DPI-C" function bit seq_done(input longint sim_time);
`endif

module altera_rldram3_board_delay_model_top_no_ifdef_params 
	# (parameter MEM_IF_WRITE_DQS_WIDTH = 1,
	MEM_IF_DM_WIDTH = 1,
	MEM_IF_DQ_WIDTH = 18,
	MEM_IF_READ_DQS_WIDTH = 2,
	MEM_IF_BANKADDR_WIDTH = 3,
	MEM_IF_ADDR_WIDTH = 20,
	MEM_IF_CS_WIDTH = 1,
	MEM_IF_BOARD_BASE_DELAY = 10,
	SHADOW_REG_IDX = 0	
	)
	(
	tophy_mem_a,
	tophy_mem_ba,
	tophy_mem_ck,
	tophy_mem_ck_n,
	tophy_mem_cs_n,
	tophy_mem_dk,
	tophy_mem_dk_n,
	tophy_mem_dm,
	tophy_mem_dq,
	tophy_mem_qk,
	tophy_mem_qk_n,
	tophy_mem_ref_n,
	tophy_mem_we_n,
	tophy_mem_reset_n,
  
	tomem_mem_a,
	tomem_mem_ba,
	tomem_mem_ck,
	tomem_mem_ck_n,
	tomem_mem_cs_n,
	tomem_mem_dk,
	tomem_mem_dk_n,
	tomem_mem_dm,
	tomem_mem_dq,
	tomem_mem_qk,
	tomem_mem_qk_n,
	tomem_mem_ref_n,
	tomem_mem_we_n,
	tomem_mem_reset_n
);

input	[MEM_IF_ADDR_WIDTH-1:0]			tophy_mem_a; 
input	[MEM_IF_BANKADDR_WIDTH-1:0]		tophy_mem_ba;
input						tophy_mem_ck; 
input						tophy_mem_ck_n;
input	[MEM_IF_CS_WIDTH-1:0] 			tophy_mem_cs_n; 
input	[MEM_IF_WRITE_DQS_WIDTH-1:0]		tophy_mem_dk; 
input	[MEM_IF_WRITE_DQS_WIDTH-1:0]		tophy_mem_dk_n; 
input	[MEM_IF_DM_WIDTH-1:0]			tophy_mem_dm; 
inout   [MEM_IF_DQ_WIDTH-1:0]			tophy_mem_dq; 
output logic [MEM_IF_READ_DQS_WIDTH-1:0]	tophy_mem_qk; 
output logic [MEM_IF_READ_DQS_WIDTH-1:0]	tophy_mem_qk_n; 
input						tophy_mem_ref_n; 
input						tophy_mem_we_n;
input						tophy_mem_reset_n;

output	[MEM_IF_ADDR_WIDTH-1:0]			tomem_mem_a; 
output	[MEM_IF_BANKADDR_WIDTH-1:0]		tomem_mem_ba;
output						tomem_mem_ck; 
output						tomem_mem_ck_n;
output	[MEM_IF_CS_WIDTH-1:0] 			tomem_mem_cs_n; 
output	[MEM_IF_WRITE_DQS_WIDTH-1:0]		tomem_mem_dk; 
output	[MEM_IF_WRITE_DQS_WIDTH-1:0]		tomem_mem_dk_n; 
output	[MEM_IF_DM_WIDTH-1:0]			tomem_mem_dm; 
inout   [MEM_IF_DQ_WIDTH-1:0]			tomem_mem_dq; 
input logic [MEM_IF_READ_DQS_WIDTH-1:0]		tomem_mem_qk; 
input logic [MEM_IF_READ_DQS_WIDTH-1:0]		tomem_mem_qk_n; 
output						tomem_mem_ref_n; 
output						tomem_mem_we_n;
output						tomem_mem_reset_n;



string cfg_file = "board_delay_config.txt"; 
string cfg_file_postcal = "board_delay_config_postcal.txt"; 

integer base_delay[1] = {MEM_IF_BOARD_BASE_DELAY};
integer rank_delay[1] = {0};

integer mem_a_dly[MEM_IF_ADDR_WIDTH];
integer mem_ba_dly[MEM_IF_BANKADDR_WIDTH];
integer mem_ck_dly[1];
integer mem_ck_n_dly[1];
integer mem_cs_n_dly[MEM_IF_CS_WIDTH];
integer mem_dk_dly[MEM_IF_WRITE_DQS_WIDTH];
integer mem_dk_n_dly[MEM_IF_WRITE_DQS_WIDTH];
integer mem_dm_dly[MEM_IF_DM_WIDTH];
integer mem_dq_dly[MEM_IF_DQ_WIDTH];
integer mem_qk_dly[MEM_IF_READ_DQS_WIDTH];
integer mem_qk_n_dly[MEM_IF_READ_DQS_WIDTH];
integer mem_ref_n_dly[1];
integer mem_we_n_dly[1];
integer mem_reset_n_dly[1];


integer mem_a_bad[MEM_IF_ADDR_WIDTH];
integer mem_ba_bad[MEM_IF_BANKADDR_WIDTH];
integer mem_ck_bad[1];
integer mem_ck_n_bad[1];
integer mem_cs_n_bad[MEM_IF_CS_WIDTH];
integer mem_dk_bad[MEM_IF_WRITE_DQS_WIDTH];
integer mem_dk_n_bad[MEM_IF_WRITE_DQS_WIDTH];
integer mem_dm_bad[MEM_IF_DM_WIDTH];
integer mem_dq_bad[MEM_IF_DQ_WIDTH];
integer mem_qk_bad[MEM_IF_READ_DQS_WIDTH];
integer mem_qk_n_bad[MEM_IF_READ_DQS_WIDTH];
integer mem_ref_n_bad[1];
integer mem_we_n_bad[1];
integer mem_reset_n_bad[1];


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

		$display("Loading %0s for configuring memory delays/windows", filename);
		
		delay_util.read_config(.file(filename), .name("base_delay"),    .delays(base_delay));
                delay_util.read_config(.file(filename), .name("rank_delay"),    .delays(rank_delay));
		
		delay_util.read_config(.file(filename), .name("mem_a_dly"),     .delays(mem_a_dly));
		delay_util.read_config(.file(filename), .name("mem_ba_dly"),    .delays(mem_ba_dly));
		delay_util.read_config(.file(filename), .name("mem_ck_dly"),    .delays(mem_ck_dly));
		delay_util.read_config(.file(filename), .name("mem_ck_n_dly"),  .delays(mem_ck_n_dly));
		delay_util.read_config(.file(filename), .name("mem_cs_n_dly"),  .delays(mem_cs_n_dly));
		delay_util.read_config(.file(filename), .name("mem_dk_dly"),    .delays(mem_dk_dly));
		delay_util.read_config(.file(filename), .name("mem_dk_n_dly"),  .delays(mem_dk_n_dly));
		delay_util.read_config(.file(filename), .name("mem_dm_dly"),    .delays(mem_dm_dly));
		delay_util.read_config(.file(filename), .name("mem_dq_dly"),    .delays(mem_dq_dly));
		delay_util.read_config(.file(filename), .name("mem_qk_dly"),    .delays(mem_qk_dly));
		delay_util.read_config(.file(filename), .name("mem_qk_n_dly"),  .delays(mem_qk_n_dly));
		delay_util.read_config(.file(filename), .name("mem_ref_n_dly"), .delays(mem_ref_n_dly));
		delay_util.read_config(.file(filename), .name("mem_we_n_dly"),  .delays(mem_we_n_dly));
		delay_util.read_config(.file(filename), .name("mem_reset_n_dly"),  .delays(mem_reset_n_dly));
		

		delay_util.read_config(.file(filename), .name("mem_a_bad"),     .delays(mem_a_bad));
		delay_util.read_config(.file(filename), .name("mem_ba_bad"),    .delays(mem_ba_bad));
		delay_util.read_config(.file(filename), .name("mem_ck_bad"),    .delays(mem_ck_bad));
		delay_util.read_config(.file(filename), .name("mem_ck_n_bad"),  .delays(mem_ck_n_bad));
		delay_util.read_config(.file(filename), .name("mem_cs_n_bad"),  .delays(mem_cs_n_bad));
		delay_util.read_config(.file(filename), .name("mem_dk_bad"),    .delays(mem_dk_bad));
		delay_util.read_config(.file(filename), .name("mem_dk_n_bad"),  .delays(mem_dk_n_bad));
		delay_util.read_config(.file(filename), .name("mem_dm_bad"),    .delays(mem_dm_bad));
		delay_util.read_config(.file(filename), .name("mem_dq_bad"),    .delays(mem_dq_bad));
		delay_util.read_config(.file(filename), .name("mem_qk_bad"),    .delays(mem_qk_bad));
		delay_util.read_config(.file(filename), .name("mem_qk_n_bad"),  .delays(mem_qk_n_bad));
		delay_util.read_config(.file(filename), .name("mem_ref_n_bad"), .delays(mem_ref_n_bad));
		delay_util.read_config(.file(filename), .name("mem_we_n_bad"),  .delays(mem_we_n_bad));
		delay_util.read_config(.file(filename), .name("mem_reset_n_bad"),  .delays(mem_reset_n_bad));
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
		load_config(cfg_file_postcal, 1);
	end
end
`endif
wire [31:0] dq_rank_dly[MEM_IF_DQ_WIDTH];
wire [31:0] dm_rank_dly;

generate 
	genvar dqs_i, dq_i;

	for (dq_i = 0; dq_i < MEM_IF_DQ_WIDTH; dq_i = dq_i + 1)
		if (dq_i % (MEM_IF_DQ_WIDTH) == 0)
			assign dq_rank_dly[dq_i] = '0;
		else			
			assign dq_rank_dly[dq_i] = (SHADOW_REG_IDX) ? rank_delay[0] : -rank_delay[0];
        
	assign dm_rank_dly = (SHADOW_REG_IDX) ? rank_delay[0] : -rank_delay[0];

endgenerate

generate
	genvar i;

	for (i = 0; i < MEM_IF_ADDR_WIDTH; i = i + 1)
		unidir_delay mem_a_inst (.in(tophy_mem_a[i]), .out(tomem_mem_a[i]), 
					 .base_delay(base_delay[0]), .delay(mem_a_dly[i]), .bad(mem_a_bad[i]));
	
	for (i = 0; i < MEM_IF_BANKADDR_WIDTH; i = i + 1)
		unidir_delay mem_ba_inst (.in(tophy_mem_ba[i]), .out(tomem_mem_ba[i]),
					 .base_delay(base_delay[0]), .delay(mem_ba_dly[i]), .bad(mem_ba_bad[i]));
					  
	unidir_delay mem_ck_inst (.in(tophy_mem_ck), .out(tomem_mem_ck),
				  .base_delay(base_delay[0]), .delay(mem_ck_dly[0]), .bad(mem_ck_bad[0]));
		
	unidir_delay mem_ck_n_inst (.in(tophy_mem_ck_n), .out(tomem_mem_ck_n),
				    .base_delay(base_delay[0]), .delay(mem_ck_n_dly[0]), .bad(mem_ck_n_bad[0]));
		
	for (i = 0; i < MEM_IF_CS_WIDTH; i = i + 1)
		unidir_delay mem_cs_n_inst (.in(tophy_mem_cs_n[i]), .out(tomem_mem_cs_n[i]),
					 .base_delay(base_delay[0]), .delay(mem_cs_n_dly[i]), .bad(mem_cs_n_bad[i]));
		
	for (i = 0; i < MEM_IF_WRITE_DQS_WIDTH; i = i + 1)
		unidir_delay mem_dk_inst (.in(tophy_mem_dk[i]), .out(tomem_mem_dk[i]),
					 .base_delay(base_delay[0]), .delay(mem_dk_dly[i]), .bad(mem_dk_bad[i]));
		
	for (i = 0; i < MEM_IF_WRITE_DQS_WIDTH; i = i + 1)
		unidir_delay mem_dk_n_inst (.in(tophy_mem_dk_n[i]), .out(tomem_mem_dk_n[i]),
					 .base_delay(base_delay[0]), .delay(mem_dk_n_dly[i]), .bad(mem_dk_n_bad[i]));
		
	for (i = 0; i < MEM_IF_DM_WIDTH; i = i + 1)
		unidir_delay mem_dm_inst (.in(tophy_mem_dm[i]), .out(tomem_mem_dm[i]),
					 .base_delay(base_delay[0] + dm_rank_dly), .delay(mem_dm_dly[i]), .bad(mem_dm_bad[i]));
		
	for (i = 0; i < MEM_IF_DQ_WIDTH; i = i + 1)
		bidir_delay mem_dq_inst (.mem(tomem_mem_dq[i]), .phy(tophy_mem_dq[i]),
					 .base_delay(base_delay[0] + dq_rank_dly[i]), .delay(mem_dq_dly[i]), .bad(mem_dq_bad[i]));
	
	for (i = 0; i < MEM_IF_READ_DQS_WIDTH; i = i + 1)
		unidir_delay mem_qk_inst (.in(tomem_mem_qk[i]), .out(tophy_mem_qk[i]),
					 .base_delay(base_delay[0]), .delay(mem_qk_dly[i]), .bad(mem_qk_bad[i]));
		
	for (i = 0; i < MEM_IF_READ_DQS_WIDTH; i = i + 1)
		unidir_delay mem_qk_n_inst (.in(tomem_mem_qk_n[i]), .out(tophy_mem_qk_n[i]),
					 .base_delay(base_delay[0]), .delay(mem_qk_n_dly[i]), .bad(mem_qk_n_bad[i]));
		
	unidir_delay mem_ref_n_inst (.in(tophy_mem_ref_n), .out(tomem_mem_ref_n),
				     .base_delay(base_delay[0]), .delay(mem_ref_n_dly[0]), .bad(mem_ref_n_bad[0]));
		
	unidir_delay mem_we_n_inst (.in(tophy_mem_we_n), .out(tomem_mem_we_n),
				    .base_delay(base_delay[0]), .delay(mem_we_n_dly[0]), .bad(mem_we_n_bad[0]));
		
	unidir_delay mem_reset_n_inst (.in(tophy_mem_reset_n), .out(tomem_mem_reset_n),
				    .base_delay(base_delay[0]), .delay(mem_reset_n_dly[0]), .bad(mem_reset_n_bad[0]));
endgenerate

endmodule
