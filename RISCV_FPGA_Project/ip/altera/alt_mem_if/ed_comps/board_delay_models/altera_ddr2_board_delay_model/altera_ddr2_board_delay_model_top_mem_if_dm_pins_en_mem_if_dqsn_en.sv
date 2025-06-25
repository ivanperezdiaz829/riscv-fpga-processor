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

module altera_ddr2_board_delay_model_top_mem_if_dm_pins_en_mem_if_dqsn_en 
    # (parameter MEM_IF_CLK_EN_WIDTH = 1,
		MEM_IF_CK_WIDTH = 1,
		MEM_IF_BANKADDR_WIDTH = 2,
		MEM_IF_ADDR_WIDTH = 14,
		MEM_IF_CS_WIDTH = 1,
		MEM_IF_CONTROL_WIDTH = 1,
		MEM_IF_DQS_WIDTH = 1,
		MEM_IF_DQ_WIDTH = 8,
		MEM_IF_ODT_WIDTH = 1,
       		MEM_IF_BOARD_BASE_DELAY = 10
	)                    
	(

	tophy_mem_a,
	tophy_mem_ba,
	tophy_mem_ck,
	tophy_mem_ck_n,
	tophy_mem_cke,
	tophy_mem_cs_n,
	tophy_mem_ras_n,
	tophy_mem_cas_n,
	tophy_mem_we_n,
	tophy_mem_dm,
	tophy_mem_dq,
	tophy_mem_dqs,
	tophy_mem_dqs_n,
	tophy_mem_odt,

	tomem_mem_a,
	tomem_mem_ba,
	tomem_mem_ck,
	tomem_mem_ck_n,
	tomem_mem_cke,
	tomem_mem_cs_n,
	tomem_mem_ras_n,
	tomem_mem_cas_n,
	tomem_mem_we_n,
	tomem_mem_dm,
	tomem_mem_dq,
	tomem_mem_dqs,
	tomem_mem_dqs_n,
	tomem_mem_odt
);

input	[MEM_IF_ADDR_WIDTH - 1:0]	tophy_mem_a;
input	[MEM_IF_BANKADDR_WIDTH - 1:0]	tophy_mem_ba;
input	[MEM_IF_CK_WIDTH - 1:0] 	tophy_mem_ck;
input	[MEM_IF_CK_WIDTH - 1:0] 	tophy_mem_ck_n;
input	[MEM_IF_CLK_EN_WIDTH - 1:0] 	tophy_mem_cke;
input	[MEM_IF_CS_WIDTH - 1:0] 	tophy_mem_cs_n;
input	[MEM_IF_CONTROL_WIDTH - 1:0] 	tophy_mem_ras_n;
input	[MEM_IF_CONTROL_WIDTH - 1:0] 	tophy_mem_cas_n;
input	[MEM_IF_CONTROL_WIDTH - 1:0] 	tophy_mem_we_n;
input	[MEM_IF_DQS_WIDTH - 1:0] 	tophy_mem_dm;
inout   [MEM_IF_DQ_WIDTH - 1:0]		tophy_mem_dq;
inout   [MEM_IF_DQS_WIDTH - 1:0]	tophy_mem_dqs;
inout   [MEM_IF_DQS_WIDTH - 1:0]	tophy_mem_dqs_n;
input 	[MEM_IF_ODT_WIDTH - 1:0] 	tophy_mem_odt;


output	[MEM_IF_ADDR_WIDTH - 1:0]	tomem_mem_a;
output	[MEM_IF_BANKADDR_WIDTH - 1:0]	tomem_mem_ba;
output	[MEM_IF_CK_WIDTH - 1:0] 	tomem_mem_ck;
output	[MEM_IF_CK_WIDTH - 1:0] 	tomem_mem_ck_n;
output	[MEM_IF_CLK_EN_WIDTH - 1:0] 	tomem_mem_cke;
output	[MEM_IF_CS_WIDTH - 1:0] 	tomem_mem_cs_n;
output	[MEM_IF_CONTROL_WIDTH - 1:0] 	tomem_mem_ras_n;
output	[MEM_IF_CONTROL_WIDTH - 1:0] 	tomem_mem_cas_n;
output	[MEM_IF_CONTROL_WIDTH - 1:0] 	tomem_mem_we_n;
output	[MEM_IF_DQS_WIDTH - 1:0] 	tomem_mem_dm;
inout   [MEM_IF_DQ_WIDTH - 1:0]		tomem_mem_dq;
inout   [MEM_IF_DQS_WIDTH - 1:0]	tomem_mem_dqs;
inout   [MEM_IF_DQS_WIDTH - 1:0]	tomem_mem_dqs_n;
output 	[MEM_IF_ODT_WIDTH - 1:0] 	tomem_mem_odt;



string cfg_file = "board_delay_config.txt"; 
string cfg_file_postcal = "board_delay_config_postcal.txt"; 

integer base_delay[1] = {MEM_IF_BOARD_BASE_DELAY};

integer mem_a_dly[MEM_IF_ADDR_WIDTH];
integer mem_ba_dly[MEM_IF_BANKADDR_WIDTH];
integer mem_ck_dly[MEM_IF_CK_WIDTH];
integer mem_ck_n_dly[MEM_IF_CK_WIDTH];
integer mem_cke_dly[MEM_IF_CLK_EN_WIDTH];
integer mem_cs_n_dly[MEM_IF_CS_WIDTH];
integer mem_ras_n_dly[MEM_IF_CONTROL_WIDTH];
integer mem_cas_n_dly[MEM_IF_CONTROL_WIDTH];
integer mem_we_n_dly[MEM_IF_CONTROL_WIDTH];
integer mem_dm_dly[MEM_IF_DQS_WIDTH];
integer mem_dq_dly[MEM_IF_DQ_WIDTH];
integer mem_dqs_dly[MEM_IF_DQS_WIDTH];
integer mem_dqs_n_dly[MEM_IF_DQS_WIDTH];
integer mem_odt_dly[MEM_IF_ODT_WIDTH];
	
integer mem_a_bad[MEM_IF_ADDR_WIDTH];
integer mem_ba_bad[MEM_IF_BANKADDR_WIDTH];
integer mem_ck_bad[MEM_IF_CK_WIDTH];
integer mem_ck_n_bad[MEM_IF_CK_WIDTH];
integer mem_cke_bad[MEM_IF_CLK_EN_WIDTH];
integer mem_cs_n_bad[MEM_IF_CS_WIDTH];
integer mem_ras_n_bad[MEM_IF_CONTROL_WIDTH];
integer mem_cas_n_bad[MEM_IF_CONTROL_WIDTH];
integer mem_we_n_bad[MEM_IF_CONTROL_WIDTH];
integer mem_dm_bad[MEM_IF_DQS_WIDTH];
integer mem_dq_bad[MEM_IF_DQ_WIDTH];
integer mem_dqs_bad[MEM_IF_DQS_WIDTH];
integer mem_dqs_bad_z[MEM_IF_DQS_WIDTH];
integer mem_dqs_n_bad[MEM_IF_DQS_WIDTH];
integer mem_dqs_n_bad_z[MEM_IF_DQS_WIDTH];
integer mem_odt_bad[MEM_IF_ODT_WIDTH];

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
		delay_util.read_config(.file(filename), .name("mem_ba_dly"),    .delays(mem_ba_dly));
		delay_util.read_config(.file(filename), .name("mem_ck_dly"),    .delays(mem_ck_dly));
		delay_util.read_config(.file(filename), .name("mem_ck_n_dly"),  .delays(mem_ck_n_dly));
		delay_util.read_config(.file(filename), .name("mem_cke_dly"),   .delays(mem_cke_dly));
		delay_util.read_config(.file(filename), .name("mem_cs_n_dly"),  .delays(mem_cs_n_dly));
		delay_util.read_config(.file(filename), .name("mem_ras_n_dly"), .delays(mem_ras_n_dly));
		delay_util.read_config(.file(filename), .name("mem_cas_n_dly"), .delays(mem_cas_n_dly));
		delay_util.read_config(.file(filename), .name("mem_we_n_dly"),  .delays(mem_we_n_dly));
		delay_util.read_config(.file(filename), .name("mem_dm_dly"),    .delays(mem_dm_dly));
		delay_util.read_config(.file(filename), .name("mem_dq_dly"),    .delays(mem_dq_dly));
		delay_util.read_config(.file(filename), .name("mem_dqs_dly"),   .delays(mem_dqs_dly));
		delay_util.read_config(.file(filename), .name("mem_dqs_n_dly"), .delays(mem_dqs_n_dly));
		delay_util.read_config(.file(filename), .name("mem_odt_dly"),   .delays(mem_odt_dly));

		delay_util.read_config(.file(filename), .name("mem_a_bad"),     .delays(mem_a_bad));
		delay_util.read_config(.file(filename), .name("mem_ba_bad"),    .delays(mem_ba_bad));
		delay_util.read_config(.file(filename), .name("mem_ck_bad"),    .delays(mem_ck_bad));
		delay_util.read_config(.file(filename), .name("mem_ck_n_bad"),  .delays(mem_ck_n_bad));
		delay_util.read_config(.file(filename), .name("mem_cke_bad"),   .delays(mem_cke_bad));
		delay_util.read_config(.file(filename), .name("mem_cs_n_bad"),  .delays(mem_cs_n_bad));
		delay_util.read_config(.file(filename), .name("mem_ras_n_bad"), .delays(mem_ras_n_bad));
		delay_util.read_config(.file(filename), .name("mem_cas_n_bad"), .delays(mem_cas_n_bad));
		delay_util.read_config(.file(filename), .name("mem_we_n_bad"),  .delays(mem_we_n_bad));
		delay_util.read_config(.file(filename), .name("mem_dm_bad"),    .delays(mem_dm_bad));
		delay_util.read_config(.file(filename), .name("mem_dq_bad"),    .delays(mem_dq_bad));
		delay_util.read_config(.file(filename), .name("mem_dqs_bad"),   .delays(mem_dqs_bad));
		delay_util.read_config(.file(filename), .name("mem_dqs_bad_z"),   .delays(mem_dqs_bad_z));
		delay_util.read_config(.file(filename), .name("mem_dqs_n_bad"), .delays(mem_dqs_n_bad));
		delay_util.read_config(.file(filename), .name("mem_dqs_n_bad_z"), .delays(mem_dqs_n_bad_z));
		delay_util.read_config(.file(filename), .name("mem_odt_bad"),   .delays(mem_odt_bad));
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
	
	for (i = 0; i < MEM_IF_BANKADDR_WIDTH; i = i + 1)
		unidir_delay mem_ba_inst (.in(tophy_mem_ba[i]), .out(tomem_mem_ba[i]),
					 .base_delay(base_delay[0]), .delay(mem_ba_dly[i]), .bad(mem_ba_bad[i]));
					  
	for (i = 0; i < MEM_IF_CK_WIDTH; i = i + 1)
		unidir_delay mem_ck_inst (.in(tophy_mem_ck[i]), .out(tomem_mem_ck[i]),
					 .base_delay(base_delay[0]), .delay(mem_ck_dly[i]), .bad(mem_ck_bad[i]));
		
	for (i = 0; i < MEM_IF_CK_WIDTH; i = i + 1)
		unidir_delay mem_ck_n_inst (.in(tophy_mem_ck_n[i]), .out(tomem_mem_ck_n[i]),
					 .base_delay(base_delay[0]), .delay(mem_ck_n_dly[i]), .bad(mem_ck_n_bad[i]));
		
	for (i = 0; i < MEM_IF_CLK_EN_WIDTH; i = i + 1)
		unidir_delay mem_cke_inst (.in(tophy_mem_cke[i]), .out(tomem_mem_cke[i]),
					 .base_delay(base_delay[0]), .delay(mem_cke_dly[i]), .bad(mem_cke_bad[i]));
		
	for (i = 0; i < MEM_IF_CS_WIDTH; i = i + 1)
		unidir_delay mem_cs_n_inst (.in(tophy_mem_cs_n[i]), .out(tomem_mem_cs_n[i]),
					 .base_delay(base_delay[0]), .delay(mem_cs_n_dly[i]), .bad(mem_cs_n_bad[i]));
		
	for (i = 0; i < MEM_IF_CONTROL_WIDTH; i = i + 1)
		unidir_delay mem_ras_n_inst (.in(tophy_mem_ras_n[i]), .out(tomem_mem_ras_n[i]),
					 .base_delay(base_delay[0]), .delay(mem_ras_n_dly[i]), .bad(mem_ras_n_bad[i]));
		
	for (i = 0; i < MEM_IF_CONTROL_WIDTH; i = i + 1)
		unidir_delay mem_cas_n_inst (.in(tophy_mem_cas_n[i]), .out(tomem_mem_cas_n[i]),
					 .base_delay(base_delay[0]), .delay(mem_cas_n_dly[i]), .bad(mem_cas_n_bad[i]));
		
	for (i = 0; i < MEM_IF_CONTROL_WIDTH; i = i + 1)
		unidir_delay mem_we_n_inst (.in(tophy_mem_we_n[i]), .out(tomem_mem_we_n[i]),
					 .base_delay(base_delay[0]), .delay(mem_we_n_dly[i]), .bad(mem_we_n_bad[i]));
		
	for (i = 0; i < MEM_IF_DQS_WIDTH; i = i + 1)
		unidir_delay mem_dm_inst (.in(tophy_mem_dm[i]), .out(tomem_mem_dm[i]),
					 .base_delay(base_delay[0]), .delay(mem_dm_dly[i]), .bad(mem_dm_bad[i]));
		
	for (i = 0; i < MEM_IF_DQ_WIDTH; i = i + 1)
		bidir_delay mem_dq_inst (.mem(tomem_mem_dq[i]), .phy(tophy_mem_dq[i]),
					 .base_delay(base_delay[0]), .delay(mem_dq_dly[i]), .bad(mem_dq_bad[i]));
	
	for (i = 0; i < MEM_IF_DQS_WIDTH; i = i + 1)
		bidir_delay mem_dqs_inst (.mem(tomem_mem_dqs[i]), .phy(tophy_mem_dqs[i]),
					 .base_delay(base_delay[0]), .delay(mem_dqs_dly[i]), .bad(mem_dqs_bad[i]), .bad_from_z(mem_dqs_bad_z[i]));

	for (i = 0; i < MEM_IF_DQS_WIDTH; i = i + 1)
		bidir_delay mem_dqs_n_inst (.mem(tomem_mem_dqs_n[i]), .phy(tophy_mem_dqs_n[i]),
					 .base_delay(base_delay[0]), .delay(mem_dqs_n_dly[i]), .bad(mem_dqs_n_bad[i]), .bad_from_z(mem_dqs_n_bad_z[i]));


	for (i = 0; i < MEM_IF_ODT_WIDTH; i = i + 1)
		unidir_delay mem_odt_inst (.in(tophy_mem_odt[i]), .out(tomem_mem_odt[i]),
					 .base_delay(base_delay[0]), .delay(mem_odt_dly[i]), .bad(mem_odt_bad[i]));

endgenerate



endmodule





