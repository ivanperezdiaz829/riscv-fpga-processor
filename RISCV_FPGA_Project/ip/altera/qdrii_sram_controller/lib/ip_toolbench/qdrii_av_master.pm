# ------------------------------------------------------------------------------
#  This confidential and proprietary software may be used only as authorized by
#  a licensing agreement from Altera Corporation.
#
#  (C) COPYRIGHT 2005 ALTERA CORPORATION
#  ALL RIGHTS RESERVED
#
#  The entire notice above must be reproduced on all authorized copies and any
#  such reproduction must be pursuant to a licensing agreement from Altera.
#
#  Title        : QDRII SRAM Controller Avalon read interface
#  Project      : QDRII SRAM Controller
#
#
#  File         : $RCSfile: qdrii_av_master.pm,v $
#
#  Last modified: $Date: 2013/08/11 $
#  Revision     : $Revision: #1 $
#
#  Abstract:
#
#  Notes:
# ------------------------------------------------------------------------------


use europa_all;
use europa_utils;

use e_comment;

sub qdrii_av_master
{


my $top = e_module->new({name => $gWRAPPER_NAME."_av_master"});
my $project = e_project->new({top => $top, language => $language,__system_directory =>$output_directory});
my $module = $project->top();
my $name = $project->get_top_module_name();
#####   Parameters declaration  ######
my $family = $gFAMILY;
my $mem_dq_per_dqs = $gMEM_DQ_PER_DQS;
my $local_data_bits = $gLOCAL_DATA_BITS;
my $memory_data_width = $gMEMORY_DATA_WIDTH;
my $memory_address_width = $gMEMORY_ADDRESS_WIDTH;
my $delay_chain = $gDELAY_CHAIN;
my $burst_mode = $gMEMORY_BURST_LENGTH;
my $memory_byteen_width = $gMEMORY_BYTEEN_WIDTH;
my $avl_data_width_multiply = $gAVL_DATA_WIDTH_MULTIPLY;
my $is_busrt4_narrow = $gIS_BURST4_NARROW;
my $bwsn_width;
if($mem_dq_per_dqs <= 18)
{
	$bwsn_width = 2;
}elsif($mem_dq_per_dqs > 18)
{
	$bwsn_width = 4;
}

my $num_chips_wide = $gNUM_CHIPS_WIDE;
my $num_chips_deep = $gNUM_CHIPS_DEEP;
my $deep;
if($num_chips_deep > 1){
	$deep = 1;
}else{
	$deep = 0;
}
my @wr_burst0;
my @rd_burst0;
my $write_all_mem = $gWRITE_ALL_MEM;
my $total_size;
if($write_all_mem eq "true"){
	$total_size = $memory_address_width + $is_busrt4_narrow + $deep + 1;
}else
{
	$total_size = 11;
}
if ($burst_mode == 2)
{
		push (@wr_burst0,
			e_assign->new(["Avl_wr_data","wr_data"]),
			e_assign->new(["Avl_wr_addr","wr_addr"]),
			e_assign->new(["num_wr","num_wr + 1"]),
			e_if->new
			({
				condition	=> "(wr_burst_done != 0)",#"(tmp_wr_burst_len > 0)",
				then		=>
				[
					e_assign->new(["tmp_wr_burst_len","(tmp_wr_burst_len -1)"]),
				],
			}),
		);
		push (@rd_burst0,
			e_assign->new(["Avl_rd_addr","rd_addr"]),
			e_assign->new(["Avl_rd_be","{".($bwsn_width * $avl_data_width_multiply * $num_chips_wide)."{1'b0}}"]),
			e_assign->new(["num_rd","num_rd + 1"]),
			e_if->new
			({
				condition	=> "(rd_burst_done != 0)",#"(tmp_rd_burst_len > 0)",
				then		=>
				[
					e_assign->new(["tmp_rd_burst_len","(tmp_rd_burst_len -1)"]),
				],
			}),
		);

}
# print "\n\n $wr_burst0 \n\n $rd_burst0";
########################################   MAIN MODULE   ###################################################################
   $module->add_contents
   (
   	#e_parameter->add (["data_Bus_Width", $DDR_Tester_Options->{data_Bus_Width],"integer"]),
   	e_port->news
	(
		["clk", 		1,	"in"],
		["reset_n", 		1, 	"in"],
############# Write interface
		["Avl_wr_addr",		$memory_address_width + $is_busrt4_narrow + $deep,	"out"],
		["Avl_wr_wait",		1,	"in"],
		["Avl_wr_data",		$local_data_bits,	"out"],
		["Avl_write",		1,	"out"],
		["Avl_wr_be", 		$bwsn_width * $avl_data_width_multiply * $num_chips_wide,	"out"],
		["Avl_wr_cs",		1,	"out"],
############# Read interface
		["Avl_rd_addr",		$memory_address_width + $is_busrt4_narrow + $deep,	"out"],
		["Avl_rd_data",		$local_data_bits,	"in"],
		["Avl_read",		1,	"out"],
		["Avl_rd_datavalid",	1,	"in"],
		["Avl_rd_wait",		1,	"in"],
		["Avl_rd_be",  		$bwsn_width * $avl_data_width_multiply * $num_chips_wide,	"out"],
		["Avl_rd_cs",  		1,	"out"],
		["wr_en",		1,	"in"],
		["rd_en",		1,	"in"],
		["total_rd_wr",		$total_size,	"in"],
		["num_wr",		$total_size,	"out"],#$memory_address_width + $is_busrt4_narrow + $deep
		["num_rd",		$total_size,	"out"],
		["rd_enable",		1,	"out"],
		["wr_enable",		1,	"out"],
		["random",		1,	"in"],
		["read_pause",		1,	"out"],
		["write_pause",		1,	"out"],
		["rd_start",		1,	"out"],
		["wr_start",		1,	"out"],

		["rd_done",		1,	"out"],
		["wr_done",		1,	"out"],

		["rd_flag",		1,	"out"],
		["wr_flag",		1,	"out"],
	),
   );


     my $Idle = "4'b0000";
     my $Write = "4'b0001";
     my $Pause = "4'b0011";
     my $Read = "4'b0010";
     my $burst_seed = int(rand(5)+1);
     my $pause_seed = int(rand(3)+1);

    $module->add_contents
    (
      e_instance->add
      	({
		module => e_module->new
		({
			name 	=> $name."_av_master_dev",
			contents =>
			[
			   e_port->adds
			   (
				["Avl_wr_addr", $memory_address_width + $is_busrt4_narrow + $deep,"out"],
				["Avl_wr_wait", 1,"in"],
				["Avl_wr_data", $local_data_bits,"out"],
				["Avl_write",   1,"out"],
				["Avl_wr_be",   $bwsn_width * $avl_data_width_multiply * $num_chips_wide,"out"],
				["Avl_wr_cs",   1,"out"],

				["Avl_rd_addr",		$memory_address_width + $is_busrt4_narrow + $deep,	"out"],
				["Avl_rd_data",		$local_data_bits,	"in"],
				["Avl_read",		1,	"out"],
				["Avl_rd_datavalid",	1,	"in"],
				["Avl_rd_wait",		1,	"in"],
				["Avl_rd_be",  		$bwsn_width * $avl_data_width_multiply * $num_chips_wide,	"out"],
				["Avl_rd_cs",  		1,	"out"],

				["wr_addr",		$memory_address_width + $is_busrt4_narrow + $deep,	"in"],
				["wr_data",		$local_data_bits,	"in"],
				["rd_addr",		$memory_address_width + $is_busrt4_narrow + $deep,	"in"],
				["wr_en",		1,	"in"],
				["rd_en",		1,	"in"],
				["total_rd_wr",		$total_size,	"in"],
				["num_wr",		$total_size,	"out"],
				["num_rd",		$total_size,	"out"],
				["rd_enable",		1,	"out"],
				["wr_enable",		1,	"out"],
				["random",		1,	"in"],
				["read_pause",		1,	"out"],
				["write_pause",		1,	"out"],
				["rd_start",		1,	"out"],
				["wr_start",		1,	"out"],

				["rd_done",		1,	"out"],
				["wr_done",		1,	"out"],

				["rd_flag",		1,	"out"],
				["wr_flag",		1,	"out"],
			    ),

			    e_signal->news
			    (
				    ["write_en",	 1,      0,      1],
				    ["read_en",		 1,      0,      1],
				    ["wr_burst_len",	 8,      0,      1],
				    ["wr_pause_len",	 8,      0,      1],
				    ["reg_wr_burst_len",	 8,      0,      1],
				    ["reg_wr_pause_len",	 8,      0,      1],
				    ["tmp_wr_burst_len", 6,      0,      1],
				    ["tmp_wr_pause_len", 3,      0,      1],
				    ["wr_burst_done",    1,      0,      1],
				    ["rd_burst_len",	 8,      0,      1],
				    ["rd_pause_len",	 8,      0,      1],
				    ["reg_rd_burst_len",	 8,      0,      1],
				    ["reg_rd_pause_len",	 8,      0,      1],
				    ["tmp_rd_burst_len", 6,      0,      1],
				    ["tmp_rd_pause_len", 3,      0,      1],
				    ["rd_burst_done",    1,      0,      1],
				    ["burst_seed",	 8,      0,      1],
				    ["pause_seed",	 8,      0,      1],
				    ["nxState",		 4,      0,      1],
				    ["nState",		 4,      0,      1],
				    ["num_wr",		 8,	 0,	 1],
				    ["num_rd",		 8,	 0,	 1],
				    ["wr_load_en",	 1,      0,      1],
				    ["rd_load_en",	 1,      0,      1],

				    ["initial_delay",   12,	 0,	 1],#1111101000
				    ["delay_counter",   12,	 0,	 1],
				    ["delay_counter_done",   	 1,	 0,	 1],
				    ["reg_delay_counter_done",   1,	 0,	 1],
				    ["ZERO",	 1,      0,      1],
				    ["ONE",	 1,      0,      1],
				    ["ZEROS",	 8,      0,      1],
				    ["Avl_rd_wait_reg",	 1,      0,      1],
			      ),
			      	e_comment->new({comment=>"\n\n"}),
				e_assign->new(["burst_seed",$burst_seed]),
				e_assign->new(["pause_seed",$pause_seed]),
				e_assign->new({lhs => "ZERO",	rhs => 0,}),
				e_assign->new({lhs => "ONE",	rhs => 1,}),
				e_assign->new({lhs => "ZEROS",	rhs => 00000000,}),
				e_assign->new({lhs => "initial_delay",	rhs => "12'b101110111000"}),#delay of 3000 to accomodate for the newlonger setup time

########################################   READ BURST AND   PAUSE GENERATOR    ###################################################################

				e_comment->new
				({
					comment =>
					"\n\n---------------------------------------------------------------------\n
					Generate the write burst length\n
					---------------------------------------------------------------------\n"
				}),
				e_blind_instance->new
				({
					name 		=> "wr_burst_gen",
					module 		=> "example_lfsr8",
					in_port_map 	=>
					{
						clk   => "clk",
						reset_n   => "reset_n",
						enable   => "write_en",
						pause   => "ZERO",
						load   => "ZERO",
						"rand"	=> "ZERO",
						seed => "burst_seed",
					},
					out_port_map	=>
					{
						data   => "reg_wr_burst_len",
					},
				}),
				e_comment->new
				({
					comment	=>
					"\n\n---------------------------------------------------------------------\n
					Generate the write pause length\n
					---------------------------------------------------------------------\n"
				}),
				e_blind_instance->new
				({
					name 		=> "wr_pause_gen",
					module 		=> "example_lfsr8",
					in_port_map 	=>
					{
						clk   => "clk",
						reset_n   => "reset_n",
						enable   => "write_en",
						pause   => "ZERO",
						load   => "ZERO",
						"rand"	=> "ZERO",
						seed => "pause_seed",
					},
					out_port_map	=>
					{
						data   => "reg_wr_pause_len",
					},
				}),

########################################   READ BURST AND   PAUSE GENERATOR    ###################################################################

				e_comment->new
				({
					comment 	=>
					"\n\n---------------------------------------------------------------------\n
					Generate the read burst length\n
					---------------------------------------------------------------------\n"
				}),
				e_blind_instance->new
				({
					name 		=> "rd_burst_gen",
					module 		=> "example_lfsr8",
					in_port_map 	=>
					{
						clk   => "clk",
						reset_n   => "reset_n",
						enable   => "read_en",
						pause   => "ZERO",
						load   => "ZERO",
						"rand"	=> "ZERO",
						seed => "burst_seed",
					},
					out_port_map	=>
					{
						data   => "reg_rd_burst_len",
					},
				}),

				e_comment->new
				({comment 	=>
					"\n\n---------------------------------------------------------------------\n
					Generate the read pause length\n
					---------------------------------------------------------------------\n"
				}),
				e_blind_instance->new
				({
					name 		=> "rd_pause_gen",
					module 		=> "example_lfsr8",
					in_port_map 	=>
					{
						clk   => "clk",
						reset_n   => "reset_n",
						enable   => "read_en",
						pause   => "ZERO",
						load   => "ZERO",
						"rand"	=> "ZERO",
						seed => "pause_seed",
					},
					out_port_map	=>
					{
						data   => "reg_rd_pause_len",
					},
				}),


				e_register->new
				({
					clock		=> "clk",
					q   		=> "wr_pause_len",
					d   		=> "reg_wr_pause_len",
					async_set   	=> "reset_n",
					enable	    	=> 1,
				}),
				e_register->new
				({
					clock		=> "clk",
					q   		=> "wr_burst_len",
					d   		=> "reg_wr_burst_len",
					async_set   	=> "reset_n",
					enable	    	=> 1,
				}),
				e_register->new
				({
					clock		=> "clk",
					q   		=> "rd_burst_len",
					d   		=> "reg_rd_burst_len",
					async_set   	=> "reset_n",
					enable	    	=> 1,
				}),
				e_register->new
				({
					clock		=> "clk",
					q   		=> "rd_pause_len",
					d   		=> "reg_rd_pause_len",
					async_set   	=> "reset_n",
					enable	    	=> 1,
				}),
########################################   WRITE STATE MACHINE    ################################################################################

				e_comment->new({comment => "\n\nWRITE STATE MACHINE"}),
				e_process->new
				({
					clock		=> "clk",
					reset		=> "reset_n",
					_asynchronous_contents	=>
					[
						e_assign->new(["delay_counter_done", "0"]),
						e_assign->new(["delay_counter", "12'b0"]),
					],
					contents	=>
					[
						e_if->new
						({
							condition	=> "(delay_counter < (initial_delay - 1))",
							then		=>
							[	e_assign->new(["delay_counter", "delay_counter + 1"]), ],
							else		=>
							[	e_assign->new(["delay_counter_done", "1'b1"]), ],
						}),
					],
				}),
				e_register->new
				({
					clock		=> "clk",
					q   		=> "reg_delay_counter_done",
					d   		=> "delay_counter_done",
					async_set   	=> "reset_n",
					enable	    	=> 1,
				}),
				e_process->new
				({
					clock		=> '',
					reset		=> '',
					sensitivity_list=>
					["tmp_wr_burst_len","wr_en"],
					_contents	=>
					[
						e_if->new
						({
							condition	=> "(wr_en == 1)",
							then		=>
							[e_assign->new({lhs => "wr_burst_done",rhs => "(tmp_wr_burst_len || ZEROS[5:0])"})],
							else		=>
							[e_assign->new({lhs => "wr_burst_done",rhs => "1"})],
						}),
					],
				}),
				e_process->new
				({
					clock	=>	"clk",
					reset	=>	"reset_n",
					_asynchronous_contents	=>
					[
						 e_assign->news
						 (
						 	{lhs =>	"write_en", rhs => "1'b1"},
							{lhs => "Avl_write", rhs => "0"},
							# {lhs => "Avl_wr_data", rhs => ($local_data_bits / 2)."'b0"},
							# {lhs => "Avl_wr_addr", rhs => $memory_address_width."'b0"},
							{lhs => "Avl_wr_data", rhs => "{".($local_data_bits)."{1'b0}}"},#"wr_data"},
							{lhs => "Avl_wr_addr", rhs => "{".($memory_address_width + $is_busrt4_narrow + $deep)."{1'b0}}"},#"wr_addr"},
							{lhs => "Avl_wr_be", rhs => "{".($bwsn_width * $avl_data_width_multiply * $num_chips_wide)."{1'b1}}"},
							{lhs =>	"tmp_wr_burst_len", rhs => "7'b0"},
							{lhs =>	"tmp_wr_pause_len", rhs => "3'b0"},
						 ),
						 e_assign->new(["num_wr","8'b0"]),
						 e_assign->new(["nxState" => "0"]),
						 e_assign->new(["wr_enable","0"]),
						 # e_assign->new({lhs => "delay_counter",	rhs => 0,}),#delay of 1000
						 e_assign->new(["write_pause","1"]),
						 e_assign->new(["wr_start","0"]),
						 e_assign->new(["wr_done","0"]),
						 e_assign->new(["wr_load_en","0"]),
						 e_assign->new(["wr_flag","0"]),
						 e_assign->new(["Avl_wr_wait_reg","0"]),


					],
					contents	=>
					[
                        e_assign->new(["Avl_wr_wait_reg","Avl_wr_wait"]),
						e_case->new
						({
						      switch    => "nxState",
						      parallel  => 0,
						      full      => 0,
						      contents  =>
						      {
							      "$Idle" =>
							      [
							      		e_if->new
									({
										condition	=> "(reg_delay_counter_done == 1'b0) ",#"(delay_counter < initial_delay)",
										then		=>
										[
#											e_assign->new(["delay_counter","delay_counter + ONE"]),
											e_assign->new(["nxState","$Idle"]),
										],
										else		=>
										[
											e_comment->new({comment => "Write Idle state"}),
											e_if->new
											({
												condition	=> "(~wr_load_en)",
												then		=>
												[
													e_assign->new(["tmp_wr_burst_len","(wr_burst_len[5:0] )"]),
													e_assign->new(["tmp_wr_pause_len","(wr_pause_len[2:0] )"]),
													e_assign->new(["wr_load_en","1"]),
												],
											}),
											e_if->new
											({
												condition	=> "((wr_en == 1) & (wr_done == 0))",#(total_rd_wr > num_wr)
												then		=>
												[
													e_assign->new(["wr_enable","1"]),
													#e_assign->new(["write_en","1"]),
													e_if->new
													({
														condition	=>	"(wr_burst_done == 0)",#"(tmp_wr_burst_len == 0)",
														then		=>
														[
															#e_assign->new(["write_en","1"]),
															e_assign->new(["nxState","$Idle"]),
														],
														else		=>
														[
															e_comment->new({comment => "go to the write state state"}),
															e_assign->new(["nxState","$Write"]),
															e_assign->new(["write_en","0"]),
															e_assign->new(["Avl_write","1"]),
															e_assign->new(["wr_start","1"]),
															e_assign->new(["Avl_wr_data","wr_data"]),
															e_assign->new(["Avl_wr_addr","wr_addr"]),
															e_assign->new(["Avl_wr_be","{".($bwsn_width * $avl_data_width_multiply * $num_chips_wide)."{1'b0}}"]),
															e_assign->new(["num_wr","num_wr + 1"]),
															e_if->new
															({
																condition	=> "(wr_burst_done != 0)",#"(tmp_wr_burst_len > 0)",
																then		=>
																[
																	e_assign->new(["tmp_wr_burst_len","(tmp_wr_burst_len -1)"]),
																],
															}),
														],
													}),
												],
												else		=>
												[
													e_assign->new(["nxState","$Idle"]),
													e_assign->new(["wr_enable","0"]),
													e_assign->new(["Avl_write","0"]),
												],
											}),
										],
									}),
								],
								"$Write" =>
								[
									e_comment->new({comment => "Write state"}),
									e_if->new
									({
										condition	=> "((num_wr[".($total_size - 1)."] == 1'b0) | (num_wr[1] == 1'b0))",
										then		=>
										[
											e_if->new
											({
												condition	=> "(wr_burst_done != 1'b0)",#"(tmp_wr_burst_len > 0)",
												then		=>
												[
													e_if->new
													({
														condition	=> "(Avl_wr_wait == 1'b0)",
														then		=>
														[
															# e_if->new
															# ({
															# 	condition	=>	"~random",
															# 	then		=>
															# 	[
															 		e_assign->new(["Avl_write","1"]),
															# 	],
															# }),
															e_assign->new(["Avl_wr_data","wr_data"]),
															e_assign->new(["Avl_wr_addr","wr_addr"]),
															e_assign->new(["Avl_wr_be","{".($bwsn_width * $avl_data_width_multiply * $num_chips_wide)."{1'b0}}"]),
															e_assign->new(["num_wr","num_wr + 1"]),
															e_if->new
															({
																condition	=> "(wr_burst_done != 1'b0)",#"(tmp_wr_burst_len > 0)",
																then		=>
																[
																	e_assign->new(["tmp_wr_burst_len","(tmp_wr_burst_len -1)"]),
																],
															}),
															e_comment->new({comment => "go to the write state state"}),
															e_assign->new(["nxState","$Write"]),
														],
														else		=>
														[
															e_assign->new(["Avl_write","Avl_write"]),
															e_assign->new(["Avl_wr_data","Avl_wr_data"]),
															e_assign->new(["num_wr","num_wr"]),
															e_assign->new(["Avl_wr_addr","Avl_wr_addr"]),
															e_assign->new(["Avl_wr_be","Avl_wr_be"]),
															e_comment->new({comment => "go to the write state state"}),
															e_assign->new(["nxState","$Write"]),
														],
													}),
												],
												else		=>
												[
													e_if->new
													({
														condition	=> "(tmp_wr_pause_len > 0)",
														then		=>
														[
															e_comment->new({comment => "go to the pause state state"}),
															e_assign->new(["nxState","$Pause"]),
															e_assign->new(["Avl_write","0"]),
															e_assign->new(["write_pause","0"]),
															e_assign->new(["wr_flag","1"]),
															e_if->new
															({
																condition	=> "(Avl_wr_wait == 1'b0)",
																then		=>
																[
																	e_assign->new(["Avl_wr_data","wr_data"]),
																	e_assign->new(["Avl_wr_addr","wr_addr"]),
																	e_assign->new(["Avl_wr_be","{".($bwsn_width * $avl_data_width_multiply * $num_chips_wide)."{1'b1}}"]),
																	e_assign->new(["num_wr","num_wr + 1"]),
																	e_assign->new(["tmp_wr_burst_len","(wr_burst_len[5:0] )"]),
																],
																else		=>
																[
																	e_assign->new(["Avl_wr_data","Avl_wr_data"]),
																	e_assign->new(["Avl_wr_addr","Avl_wr_addr"]),
																	e_assign->new(["Avl_wr_be","Avl_wr_be"]),
																	e_assign->new(["num_wr","num_wr"]),
																],
															}),
														],
														else		=>
														[
															e_comment->new({comment => "go to the write state state"}),
															e_assign->new(["nxState","$Write"]),
															e_assign->new(["write_en","1'b1"]),
															e_assign->new(["Avl_write","1"]),
															@wr_burst0,
															e_assign->new(["tmp_wr_burst_len","(wr_burst_len[5:0] )"]),
															e_assign->new(["tmp_wr_pause_len","(wr_pause_len[2:0] )"]),
														],
													}),
												],
											}),
										],
										else		=>
										[
											e_assign->new(["nxState","$Idle"]),
											e_assign->new(["wr_enable","0"]),
											e_assign->new(["Avl_write","0"]),
											e_assign->new(["wr_done","1"]),
											e_assign->new(["wr_flag","0"]),
											e_assign->new(["wr_start","0"]),
										],
									}),
							      ],
							      "$Pause" =>
							      [
							      		e_comment->new({comment => "Write Pause state"}),
									e_if->new
									({
										condition	=> "(tmp_wr_pause_len > 0)",
										then		=>
										[
											e_comment->new({comment => "go to the pause state state"}),
											e_assign->new(["nxState","$Pause"]),
											e_assign->new(["Avl_write","0"]),
											e_assign->new(["Avl_wr_data","Avl_wr_data"]),
											e_assign->new(["num_wr","num_wr"]),
											e_assign->new(["Avl_wr_addr","Avl_wr_addr"]),
											e_assign->new(["Avl_wr_be","{".($bwsn_width * $avl_data_width_multiply * $num_chips_wide)."{1'b1}}"]),
											e_if->new
											({
												condition	=> "(tmp_wr_pause_len > 0)",
												then		=>
												[e_assign->new(["tmp_wr_pause_len","(tmp_wr_pause_len - 1)"]),],
											}),
										],
										else		=>
										[
											e_assign->new(["tmp_wr_pause_len","(wr_pause_len[2:0] )"]),
											e_if->new
											({
												condition	=> "(wr_burst_done != 0)",#"(tmp_wr_burst_len > 0)",
												then		=>
												[
													e_comment->new({comment => "go to the write state state"}),
													e_assign->new(["nxState","$Write"]),
													e_assign->new(["write_en","1'b1"]),
													e_assign->new(["Avl_write","1"]),
													e_assign->new(["Avl_wr_be","{".($bwsn_width * $avl_data_width_multiply * $num_chips_wide)."{1'b0}}"]),
													e_assign->new(["write_pause","1"]),
												],
												else		=>
												[
													e_assign->new(["nxState","$Pause"]),
													e_assign->new(["write_en","1'b1"]),
													e_assign->new(["tmp_wr_burst_len","(wr_burst_len[5:0] )"]),
												],
											}),
										],
									}),
							      ],
							      default =>
							      [
							      		e_comment->new({comment => "Default case state same as the Idle state"}),
									e_assign->new(["tmp_wr_burst_len","(wr_burst_len[5:0] )"]),
									e_assign->new(["tmp_wr_pause_len","(wr_pause_len[2:0] )"]),
							      		e_if->new
									({
										condition	=> "((wr_en == 1) & (total_rd_wr > num_wr))",
										then		=>
										[
											e_if->new
											({
												condition	=>	"(wr_burst_done == 0)",#"(tmp_wr_burst_len == 0)",
												then		=>
												[
													e_assign->new(["write_en","1"]),
												],
												else		=>
												[
													e_comment->new({comment => "go to the write state state"}),
													e_assign->new(["nxState","$Write"]),
													e_assign->new(["write_en","0"]),
													# e_assign->new(["Avl_write","1"]),
												],
											}),
											e_assign->new(["wr_enable","1"]),
										],
										else		=>
										[
											e_assign->new(["nxState","$Idle"]),
											e_assign->new(["wr_enable","0"]),
											e_assign->new(["Avl_write","0"]),
										],
									}),
							      ],
						      },
						}),
					 ],
				     }),#end of write FSM

########################################   READ STATE MACHINE    ################################################################################
				     e_comment->new({comment => "\n\n\tREAD STATE MACHINE"}),
				     e_process->new
				     ({
					     clock		=> '',
					     reset		=> '',
					     sensitivity_list=>
					     ["tmp_rd_burst_len","rd_en"],
					     _contents	=>
					     [
						e_if->new
						({
							condition	=> "(rd_en == 1)",
							then		=>
							[e_assign->new({lhs => "rd_burst_done",rhs => "(tmp_rd_burst_len || ZEROS[5:0])"})],
							else		=>
							[e_assign->new({lhs => "rd_burst_done",rhs => "1"})],
						}),
					     ],
				     }),
				     e_process->new
				     ({
					clock	=>	"clk",
					reset	=>	"reset_n",
					_asynchronous_contents	=>
					[
						 e_assign->news
						 (
						 	{lhs =>	"read_en", rhs => "1'b1"},
							{lhs =>	"tmp_rd_burst_len", rhs => "6'b0"},
							{lhs =>	"tmp_rd_pause_len", rhs => "3'b0"},
							{lhs => "Avl_read", rhs => "0"},
							#{lhs => "Avl_rd_addr", rhs => $memory_address_width."'b0"},
							{lhs => "Avl_rd_addr", rhs => "{".($memory_address_width + $is_busrt4_narrow + $deep)."{1'b0}}"},#"rd_addr"},
							{lhs => "Avl_rd_be",rhs => "{".($bwsn_width * $avl_data_width_multiply * $num_chips_wide)."{1'b1}}"},
						 ),
						 e_assign->new(["num_rd","8'b0"]),
						 e_assign->new(["nState" => "0"]),
						 e_assign->new(["rd_enable","0"]),
						 e_assign->new(["read_pause","1"]),
						 e_assign->new(["rd_start","0"]),
						 e_assign->new(["rd_done","0"]),
						 e_assign->new(["rd_load_en","0"]),
						 e_assign->new(["rd_flag","0"]),
					],
					contents	=>
					[
						e_case->new
						({
						      switch    => "nState",
						      parallel  => 0,
						      full      => 0,
						      contents  =>
						      {
							      "$Idle" =>
							      [
							      		e_comment->new({comment => "Read Idle state"}),
							      		e_if->new
									({
										condition	=> "(rd_en)",
										then		=>
										[
										e_if->new
										({
											condition	=> "(~rd_load_en)",
											then		=>
											[
													
												e_assign->new(["tmp_rd_burst_len","(rd_burst_len[5:0] )"]),
												e_if->new
												({
													condition	=> "(rd_burst_len[5:0] == 0)",
													then		=>
													[
														e_assign->new(["tmp_rd_burst_len","000010"]),
													],
												}),
												e_assign->new(["tmp_rd_pause_len","(rd_pause_len[2:0] )"]),
												e_assign->new(["rd_load_en","1"]),
											],
										}),
										e_assign->new(["rd_enable","1"]),
											#e_assign->new(["read_en","1"]),
											e_if->new
											({
												condition	=>	"(rd_burst_done== 0)",#"(tmp_rd_burst_len == 0)",
												#condition	=>	"(1 == 0)",#"(tmp_rd_burst_len == 0)",
												then		=>
												[
													#e_assign->new(["read_en","1"]),
													e_assign->new(["nState","$Idle"]),
												],
												else		=>
												[
													e_comment->new({comment => "go to the read state state"}),
													e_assign->new(["nState","$Read"]),
													e_assign->new(["read_en","0"]),
													e_assign->new(["Avl_read","1"]),
													e_assign->new(["rd_start","1"]),
													e_assign->new(["Avl_rd_addr","rd_addr"]),
													e_assign->new(["Avl_rd_be","{".($bwsn_width * $avl_data_width_multiply * $num_chips_wide)."{1'b0}}"]),
													e_assign->new(["num_rd","num_rd + 1"]),
													e_if->new
													({
														condition	=> "(rd_burst_done != 0)",#"(tmp_rd_burst_len > 0)",
														then		=>
														[
															e_assign->new(["tmp_rd_burst_len","(tmp_rd_burst_len -1)"]),
														],
													}),
												],
											}),
										],
										else		=>
										[
											e_assign->new(["nState","$Idle"]),
											e_assign->new(["rd_enable","0"]),
											e_assign->new(["Avl_read","0"]),
										],
									}),
								],
								"$Read" =>
								[
									e_comment->new({comment => "Read state"}),
									e_if->new
									({
										condition	=> "(num_rd[".($total_size - 1)."] == 0)",#"(total_rd_wr > num_rd)",
										then		=>
										[
											e_if->new
											({
												condition	=> "(rd_burst_done != 0)",#"(tmp_rd_burst_len > 0)",
												then		=>
												[
													e_if->new
													({
														condition	=> "(Avl_rd_wait == 0)",
														then		=>
														[
															# e_if->new
															# ({
															# 	condition	=>	"~random",
															# 	then		=>
															# 	[
															 		e_assign->new(["Avl_read","1"]),
															# 	],
															# }),
															e_assign->new(["Avl_rd_addr","rd_addr"]),
															e_assign->new(["Avl_rd_be","{".($bwsn_width * $avl_data_width_multiply * $num_chips_wide)."{1'b0}}"]),
															e_assign->new(["num_rd","num_rd + 1"]),
															e_if->new
															({
																condition	=> "(rd_burst_done != 0)",#"(tmp_rd_burst_len > 0)",
																then		=>
																[
																	e_assign->new(["tmp_rd_burst_len","(tmp_rd_burst_len -1)"]),
																],
															}),
															e_comment->new({comment => "go to the read state state"}),
															e_assign->new(["nState","$Read"]),
														],
														else		=>
														[
															e_assign->new(["Avl_read","Avl_read"]),
															e_assign->new(["Avl_rd_addr","Avl_rd_addr"]),
															e_assign->new(["num_rd","num_rd"]),
															e_assign->new(["Avl_rd_be","Avl_rd_be"]),
															e_comment->new({comment => "go to the read state state"}),
															e_assign->new(["nState","$Read"]),
														],
													}),
												],
												else		=>
												[
													e_if->new
													({
														condition	=> "(tmp_rd_pause_len > 0)",
														then		=>
														[
															e_comment->new({comment => "go to the pause state state"}),
															e_assign->new(["nState","$Pause"]),
															e_assign->new(["Avl_read","0"]),
															e_assign->new(["read_pause","0"]),
															e_assign->new(["rd_flag","1"]),
															e_if->new
															({
																condition	=> "(Avl_rd_wait == 0)",
																then		=>
																[
																	e_assign->new(["Avl_rd_addr","rd_addr"]),
																	e_assign->new(["Avl_rd_be","{".($bwsn_width * $avl_data_width_multiply * $num_chips_wide)."{1'b1}}"]),
																	e_assign->new(["num_rd","num_rd + 1"]),
																	e_assign->new(["tmp_rd_burst_len","(rd_burst_len[5:0] )"]),
																],
																else		=>
																[
																	e_assign->new(["Avl_rd_addr","Avl_rd_addr"]),
																	e_assign->new(["Avl_rd_be","Avl_rd_be"]),
																	e_assign->new(["num_rd","num_rd"]),
																],
															}),
														],
														else		=>
														[
															e_comment->new({comment => "go to the read state state"}),
															e_assign->new(["nState","$Read"]),
															e_assign->new(["read_en","1'b1"]),
															e_assign->new(["Avl_read","1"]),
															@rd_burst0,
															e_assign->new(["tmp_rd_burst_len","(rd_burst_len[5:0] )"]),
															e_assign->new(["tmp_rd_pause_len","(rd_pause_len[2:0] )"]),
														],
													}),
												],
											}),
										],
										else		=>
										[
											e_assign->new(["nState","$Idle"]),
											e_assign->new(["rd_enable","0"]),
											e_assign->new(["Avl_read","0"]),
											e_assign->new(["rd_done","1"]),
											e_assign->new(["rd_flag","0"]),
											e_assign->new(["rd_start","0"]),
										],
									}),

							      ],

							      "$Pause" =>
							      [
							      		e_comment->new({comment => "Read Pause state"}),
									e_if->new
									({
										condition	=> "(tmp_rd_pause_len > 0)",
										then		=>
										[
											e_comment->new({comment => "stay in the pause state state"}),
											e_assign->new(["nState","$Pause"]),
											e_assign->new(["Avl_read","0"]),
											e_assign->new(["num_rd","num_rd"]),
											e_assign->new(["Avl_rd_addr","Avl_rd_addr"]),
											e_assign->new(["Avl_rd_be","{".($bwsn_width * $avl_data_width_multiply * $num_chips_wide)."{1'b1}}"]),
											e_if->new
											({
												condition	=> "(tmp_rd_pause_len > 0)",
												then		=>
												[e_assign->new(["tmp_rd_pause_len","(tmp_rd_pause_len -1)"]),]
											}),
										],
										else		=>
										[
											#e_assign->new(["tmp_rd_burst_len","(rd_burst_len[5:0] )"]),
											e_assign->new(["tmp_rd_pause_len","(rd_pause_len[2:0] )"]),
											e_if->new
											({
												condition	=> "(rd_burst_done != 0)",#"(tmp_rd_burst_len > 0)",
												then		=>
												[
													e_comment->new({comment => "go to the read state state"}),
													e_assign->new(["nState","$Read"]),
													e_assign->new(["read_en","1'b1"]),
													e_assign->new(["Avl_read","1"]),
													e_assign->new(["Avl_rd_be","{".($bwsn_width * $avl_data_width_multiply * $num_chips_wide)."{1'b0}}"]),
													e_assign->new(["read_pause","1"]),
												],
												else		=>
												[
													e_assign->new(["nState","$Pause"]),
													e_assign->new(["read_en","1'b1"]),
													e_assign->new(["tmp_rd_burst_len","(rd_burst_len[5:0] )"]),
												],
											}),
										],
									}),
							      ],
							      default =>
							      [
							      		e_comment->new({comment => "Default case state same as the Idle state"}),
									e_assign->new(["tmp_rd_burst_len","(rd_burst_len[5:0] )"]),
									e_assign->new(["tmp_rd_pause_len","(rd_pause_len[2:0] )"]),
							      		e_if->new
									({
										condition	=> "(rd_en)",
										then		=>
										[
											e_if->new
											({
												condition	=>	"(total_rd_wr == num_wr)",
												then		=>
												[
													e_assign->new(["rd_enable","1"]),
													e_if->new
													({
														condition	=>	"(rd_burst_done == 0)",#"(tmp_rd_burst_len == 0)",
														then		=>
														[
															e_assign->new(["read_en","1"]),
														],
														else		=>
														[
															e_comment->new({comment => "go to the read state state"}),
															e_assign->new(["nState","$Read"]),
															e_assign->new(["read_en","0"]),
															e_assign->new(["Avl_read","1"]),
														],
													}),
													#e_assign->new(["rd_enable","1"]),
												],
											}),
										],
										else		=>
										[
											e_assign->new(["nState","$Idle"]),
											e_assign->new(["rd_enable","0"]),
											e_assign->new(["Avl_read","0"]),
										],
									}),
							      ],
						      },
						}),
					 ],
				     }),#end of read FSM
			  ],#end av_slave module
		}),
	}),#end of the instance
     );
$project->output();
}
1;
#You're done.
