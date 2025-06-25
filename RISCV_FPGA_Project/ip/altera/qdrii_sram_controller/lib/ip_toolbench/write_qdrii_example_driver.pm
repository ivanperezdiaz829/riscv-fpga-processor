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
#  Title        : Top level of the example driver
#  Project      : QDRII SRAM Controller
#
#
#  File         : $RCSfile: write_qdrii_example_driver.pm,v $
#
#  Last modified: $Date: 2013/08/11 $
#  Revision     : $Revision: #1 $
#
#  Abstract:
#
#  Notes:
# ------------------------------------------------------------------------------
#sopc_builder free code
use europa_all;
use europa_utils;
use e_comment;
use e_generate;


sub write_qdrii_example_driver
{
my $mem_type = $gMEM_TYPE;
my $top = e_module->new({name => $gWRAPPER_NAME."_auk_${mem_type}_example_driver"});
my $project = e_project->new({top => $top, language => $language,__system_directory =>$output_directory , timescale => "1ps / 1ps"});#'temp_gen'});
my $module = $project->top();

$module->vhdl_libraries()->{altera_mf} = all;


my $header_title = "QDRII Controller Example Driver";
my $project_title = "QDRII Controller";
my $header_filename = $gWRAPPER_NAME."_auk_${mem_type}_example_driver". $file_ext;
my $header_revision = "V" . $gWIZARD_VERSION;
my $header_abstract = "This file contains the memory clock generation for the QDRII Controller.";

#####   Parameters declaration  ######
my $family = $gFAMILY;
my $memory_data_width = $gMEMORY_DATA_WIDTH;
my $memory_address_width = $gMEMORY_ADDRESS_WIDTH;
my $mem_dq_per_dqs = $gMEM_DQ_PER_DQS;
my $local_data_bits = $gLOCAL_DATA_BITS;
my $delay_chain = $gDELAY_CHAIN;
my $burst_mode = $gMEMORY_BURST_LENGTH;
my $memory_byteen_width = $gMEMORY_BYTEEN_WIDTH;
my $avl_data_width_multiply = $gAVL_DATA_WIDTH_MULTIPLY;
my $bwsn_width;
my $is_busrt4_narrow = $gIS_BURST4_NARROW;
my $qdrii_pin_prefix = $gQDRII_PIN_PREFIX;
if($mem_dq_per_dqs == 9)
{
	$bwsn_width = 1;
}elsif($mem_dq_per_dqs <= 18)
{
	$bwsn_width = 2;
}elsif($mem_dq_per_dqs > 18)
{
	$bwsn_width = 4;
}
my $i = "j";
my $j = 1;
my $addr_seed;# = int(rand(32)+1); #generate random seed
my $data_seed;
my $def_lfsr = 18;
my $def_addr_lfsr = 20;
my $num_chips_wide = $gNUM_CHIPS_WIDE;
my $num_chips_deep = $gNUM_CHIPS_DEEP;
my $deep;
if($num_chips_deep > 1){
	$deep = 1;
}else{
	$deep = 0;
}
my $write_all_mem = $gWRITE_ALL_MEM;
my $total_size;
if($write_all_mem eq "true"){
	$total_size = $memory_address_width + $is_busrt4_narrow + $deep + 1;
}else
{
	$total_size = 11;
}
my @wr_burst;
my @rd_burst;
if($burst_mode == 4)
{
	push (@wr_burst,
		e_process->new
		({
			clock		=> '',
			reset		=> '',
			sensitivity_list=>
			["Avl_write","Avl_wr_wait","wr_dgen_enable","wr_start"],
			_contents	=>
			[
				e_if->new
				({
					condition	=> "(wr_dgen_enable == 0)",
					then		=>
					[e_assign->new({lhs => "wr_pause",rhs => "1"})],
					else		=>
					[
						e_if->new
						({
							condition	=> "(wr_start == 0)",
							then		=>
							[e_assign->new({lhs => "wr_pause",rhs => "0"})],
							else		=>
							[
								e_if->new
								({
									condition	=> "Avl_wr_wait",
									then		=>
									[e_assign->new({lhs => "wr_pause",rhs => "(Avl_wr_wait)"})],
									else		=>
									[
										e_assign->new({lhs => "wr_pause",rhs => "(~Avl_write)"}),
									],
								}),
							],
						}),
					],
				}),
			],
		}),
	);

	push (@rd_burst,
		e_process->new
		({
			clock		=> '',
			reset		=> '',
			sensitivity_list=>
			["Avl_read","Avl_rd_wait","rd_enable","rd_start"],
			_contents	=>
			[
				e_if->new
				({
					condition	=> "(rd_enable == 0)",
					then		=>
					[e_assign->new({lhs => "rd_pause",rhs => "1"})],
					else		=>
					[
						e_if->new
						({
							condition	=> "(rd_start == 0)",
							then		=>
							[e_assign->new({lhs => "rd_pause",rhs => "0"})],
							else		=>
							[
								e_if->new
								({
									condition	=> "Avl_rd_wait",
									then		=>
									[e_assign->new({lhs => "rd_pause",rhs => "(Avl_rd_wait)"})],
									else		=>
									[
										e_assign->new({lhs => "rd_pause",rhs => "(~Avl_read)"}),
									],
								}),
							],
						}),
					],
				}),
			],
		}),
	);
}
else
{
	push (@wr_burst,
		e_process->new
		({
			clock		=> '',
			reset		=> '',
			sensitivity_list=>
			["Avl_write","wr_dgen_enable"],
			_contents	=>
			[
				e_if->new
				({
					condition	=> "(wr_dgen_enable == 0)",
					then		=>
					[e_assign->new({lhs => "wr_pause",rhs => "1"})],
					else		=>
					[
						e_if->new
						({
							condition	=> "(wr_start == 0)",
							then		=>
							[e_assign->new({lhs => "wr_pause",rhs => "0"})],
							else		=>
							[e_assign->new({lhs => "wr_pause",rhs => "(~Avl_write)"}),],
						}),
					],
				}),
			],
		}),
	);

	push (@rd_burst,
		e_process->new
		({
			clock		=> '',
			reset		=> '',
			sensitivity_list=>
			["Avl_read","rd_enable"],
			_contents	=>
			[
				e_if->new
				({
					condition	=> "(rd_enable == 0)",
					then		=>
					[e_assign->new({lhs => "rd_pause",rhs => "1"})],
					else		=>
					[
						e_if->new
						({
							condition	=> "(rd_start == 0)",
							then		=>
							[e_assign->new({lhs => "rd_pause",rhs => "0"})],
							else		=>
							[e_assign->new({lhs => "rd_pause",rhs => "(~Avl_read)"}),],
						}),
					],
				}),
			],
		}),
	);
}
######################################################################################################################################################################
	$module->comment
	(
		"------------------------------------------------------------------------------\n
		 This confidential and proprietary software may be used only as authorized by\n	 a licensing agreement from Altera Corporation.\n\n
		 (C) COPYRIGHT 2005 ALTERA CORPORATION\n ALL RIGHTS RESERVED\n\n
		 The entire notice above must be reproduced on all authorized copies and any\n such reproduction must be pursuant to a licensing agreement from Altera.\n\n
		 Title        : $header_title\n
		 Project      : $project_title\n\n\n
		 File         : $header_filename\n\n
		 Revision     : $header_revision\n\n
		 Abstract:\n $header_abstract\n\n
		 ----------------------------------------------------------------------------------\n",
	);
#####################################################################################################################################################################
	 $module->add_contents
	 (
	 #####	Ports declaration#	######
		 e_port->new({name => "clk",direction => "input", width => 1}),
		 e_port->new({name => "reset_n",direction => "input", width => 1}),

	     ### Inputs ####
		 e_port->new({name => "Avl_rd_data",direction => "input",width => $local_data_bits}),
		 e_port->new({name => "Avl_rd_datavalid",direction => "input", width => 1}),
		 e_port->new({name => "Avl_rd_wait",direction => "input", width => 1}),
		 e_port->new({name => "Avl_wr_wait",direction => "input", width => 1}),

	    ### Outputs ####
	    	 e_port->new({name => "Avl_rd_addr",direction => "output", width => $memory_address_width + $is_busrt4_narrow + $deep,declare_one_bit_as_std_logic_vector => 0}),
	    	 e_port->new({name => "Avl_rd_be",direction => "output",width => $bwsn_width * $avl_data_width_multiply * $num_chips_wide}),
	    	 e_port->new({name => "Avl_rd_cs",direction => "output"}),
	    	 e_port->new({name => "Avl_read",direction => "output", width => 1}),
	    	 e_port->new({name => "Avl_wr_addr",direction => "output", width => $memory_address_width + $is_busrt4_narrow + $deep,declare_one_bit_as_std_logic_vector => 0}),
	    	 e_port->new({name => "Avl_wr_be",direction => "output",width => $bwsn_width * $avl_data_width_multiply * $num_chips_wide}),
	    	 e_port->new({name => "Avl_wr_cs",direction => "output"}),
	    	 e_port->new({name => "Avl_wr_data",direction => "output",width => $local_data_bits}),
	    	 e_port->new({name => "Avl_write",direction => "output", width => 1}),

		 e_port->new({name => "fail",direction => "output", width => 1}),
		 e_port->new({name => "fail_permanent",direction => "output", width => 1}),
		 e_port->new({name => "test_complete",direction => "output", width => 1}),

	#### internal signals ####
		e_signal->news
		(
			["wr_dgen_enable",	 1,      0,      1],
			["rd_dgen_enable",	 1,      0,      1],

			["num_wr",	 $total_size,      0,      1],#$memory_address_width + $is_busrt4_narrow + $deep
			["num_rd",	 $total_size,      0,      1],
			["total_rd_wr",	 $total_size,      0,      1],

			["rd_dgen_enable",	 1,      0,      1],
			["rd_dgen_data",	 $local_data_bits,      0,      1],
			["rd_dgen_data_reg",	 $local_data_bits,      0,      1],
			["Avl_wr_data_reg",	 $local_data_bits,      0,      1],
			["Avl_rd_datavalid_reg", 1,      0,      1],

			["ONE",	 1,      0,      1],
			["ZERO",	 1,      0,      1],
			["wr_enable",	 1,	 0,	 1],
			["rd_enable",	 1,	 0,	 1],
			["wr_pause",	 1,	 0,	 1],
			["rd_pause",	 1,	 0,	 1],
			["rd_data_enable",	 1,	 0,	 1],
			["rd_data_pause",	 1,	 0,	 1],
			["start_write",	 1,	 0,	 1],
			["start_read",	 1,	 0,	 1],
			["rand",	 1,	 0,	 1],
			["test_complete_deley",	 1,	 0,	 1],
			["Addr_Seed",	 ($memory_address_width + $deep),	 0,	 1],
			["read_pause",	 1,	 0,	 1],
			["write_pause",	 1,	 0,	 1],
			["rd_start",	 1,	 0,	 1],
			["wr_start",	 1,	 0,	 1],
			["rd_done",	 1,	 0,	 1],
			["wr_done",	 1,	 0,	 1],
			["rd_flag",	 1,	 0,	 1],
			["wr_flag",	 1,	 0,	 1],
			["rd_load",	 1,	 0,	 1],
			["wr_load",	 1,	 0,	 1],
		),
		e_signal->new({name  => "reg_rd_addr", width => $memory_address_width + $is_busrt4_narrow + $deep, never_export => 1, export => 0}),
		e_signal->new({name  => "Read_Addr", width => $memory_address_width + $is_busrt4_narrow + $deep, never_export => 1, export => 0}),
		e_signal->new({name  => "Read_Addr_temp", width => $memory_address_width  + $deep, never_export => 1, export => 0}),
		e_signal->new({name  => "Write_Addr_temp", width => $memory_address_width  + $deep, never_export => 1, export => 0}),
		e_signal->new({name  => "Write_Addr", width => $memory_address_width + $is_busrt4_narrow + $deep, never_export => 1, export => 0}),
		e_signal->new({name  => "Write_Data", width => $local_data_bits, never_export => 1, export => 0}),
		e_signal->new({name  => "reg_wr_addr", width => $memory_address_width + $is_busrt4_narrow + $deep, never_export => 1, export => 0}),
		e_signal->new({name  => "reg_wr_data", width => $local_data_bits, never_export => 1, export => 0}),
		e_signal->new({name  => "wr_addr", width => $memory_address_width + $is_busrt4_narrow + $deep, never_export => 1, export => 0}),
		e_signal->new({name  => "wr_data", width => $local_data_bits, never_export => 1, export => 0}),
		e_signal->new({name  => "rd_addr", width => $memory_address_width + $is_busrt4_narrow + $deep, never_export => 1, export => 0}),
	);

########################################   Write Address Generator   ###################################################################
	$addr_seed = int(rand(1500)+1);
	$module->add_contents
	(
		e_assign->new({lhs => "ZERO",	rhs => 0,}),
		e_assign->new({lhs => "ONE",	rhs => 1,}),
		e_assign->new({lhs => "rand",	rhs => "ONE"}),
		e_assign->new({lhs => "total_rd_wr",	rhs => 1023}),#"({".$memory_address_width."{1'b1}} - 1)",}),
		e_assign->new({lhs => "Addr_Seed",	rhs => "$addr_seed"}),

		@wr_burst,
		@rd_burst,
		e_process->new
		({
			clock	=> "clk",
			reset	=> "reset_n",
			_asynchronous_contents	=>
			[
				e_assign->new({lhs => "rd_data_enable",rhs => 0}),
			],
			contents	=>
			[
				e_assign->new({lhs => "rd_data_enable",rhs => 1}),
			],
		}),
		e_assign->new({lhs => "rd_data_pause",rhs => "~Avl_rd_datavalid"}),
	);
########################################   Write Address Generator   ###################################################################
$module->add_contents
(
	e_blind_instance->new
	({
		name 		=> "lfsr_inst_waddr",
		module 		=> "example_lfsr".($memory_address_width + $deep),
		in_port_map 	=>
		{
			clk   	=> "clk",
			reset_n => "reset_n",
			enable  => "wr_enable",#"wr_dgen_enable",
			pause   => "wr_pause",
			load   	=> "wr_pause",#"wr_load",#"ZERO",
			"rand"	=> "rand",
			seed 	=> "Addr_Seed",
		},
		out_port_map	=>
		{
			data    => "Write_Addr_temp",#"wr_dgen_addr",
		},
	}),
);
if( $is_busrt4_narrow eq "1" )
{
		$module->add_contents
		(
			e_assign->new({lhs => "Write_Addr[".(($memory_address_width + $is_busrt4_narrow + $deep -1)).":1]",rhs => "Write_Addr_temp"}),
			e_assign->new({lhs => "Write_Addr[0]",rhs => "Write_Addr_temp[0]"}),
		);

}
else
{
		$module->add_contents
		(
			e_assign->new({lhs => "Write_Addr[".(($memory_address_width  + $deep -1 )).":0]",rhs => "Write_Addr_temp"}),
		);

}


########################################   Write Data Generator   ###################################################################
$data_seed = int(rand(1500)+1);
my $res = (($local_data_bits) / $def_lfsr);
$res = int($res);
my $mod = (($local_data_bits) % $def_lfsr);
$mod = int($mod);
# print "\n--> $res\n";
# print "\n**> $mod\n";
for( my $i = 0 ; $i < $res ; $i++)
{
	 $module->add_contents
	 (
	 	e_signal->new(["Data_Seed_$i",	 18,	 0,	 1]),
	 	e_assign->new({lhs => "Data_Seed_$i",	rhs => "($data_seed + ($i * 4))",
		comment	=> "This is doing ($data_seed + ($i * 4)) to get the seed"}),
	 	e_comment->new
		({
			comment 	=>
			"---------------------------------------------------------------------\n
			Write Data Generatorfor the block of write_data["
			.(($def_lfsr * ($i + 1) -1).":".($i * $def_lfsr))."]\n
			---------------------------------------------------------------------\n",
		}),
		e_blind_instance->new
		({
			name 		=> "lfsr_inst_wdata_$i",
			module 		=> "example_lfsr18",
			in_port_map 	=>
			{
				clk   	=> "clk",
				reset_n => "reset_n",
				enable  => "wr_enable",#"wr_dgen_enable",
				pause   => "wr_pause",
				load	=> "wr_pause",#"wr_load",#"ZERO",
				"rand"	=> "ZERO",
				seed 	=> "Data_Seed_$i",# + ($i * 4),
#				ldata   => "0",
			},
			out_port_map	=>
			{
				data    => "Write_Data[".(($def_lfsr * ($i + 1) -1).":".($i * $def_lfsr))."]",#wr_dgen_data
			},
		}),
	);
}
if($mod > 0){
	$module->add_contents
	(
	 	e_signal->new(["Data_Seed_modulo",	 $mod,	 0,	 1]),
	 	e_assign->new({lhs => "Data_Seed_modulo",	rhs => "($data_seed )",
	 	comment	=> "This is doing ($data_seed ) to get the seed"}),
		e_comment->new
		({
			comment 	=>
			"---------------------------------------------------------------------\n
			Write Data Generatorfor the block of write_data["
			.($local_data_bits).
			":".($def_lfsr * $res)."]\n
			---------------------------------------------------------------------\n",
		}),
		e_blind_instance->new
		({
			name 		=> "lfsr_inst_wdata",
			module 		=> "example_lfsr$mod",
			in_port_map 	=>
			{
				clk   	=> "clk",
				reset_n => "reset_n",
				enable  => "wr_enable",#"wr_dgen_enable",
				pause   => "wr_pause",
				load	=> "wr_pause",#"wr_load",#"ZERO",
				"rand"	=> "ZERO",
				seed 	=> "Data_Seed_modulo[".($mod -1).":0]",
			},
			out_port_map	=>
			{
				data    => "Write_Data[".(($local_data_bits) -1).":".($def_lfsr * $res)."]",#wr_dgen_data
			},
		}),
	);
}
########################################   QDRII Avalon Master   ###################################################################
	 $module->add_contents
	 (
	 	e_comment->new
		({
			comment 	=>
			"---------------------------------------------------------------------\n
			QDRII Avalon Master this test the two avalon masters in the controller\n
			---------------------------------------------------------------------\n",
		}),
		e_blind_instance->new
		({
			name 		=> "the_$gWRAPPER_NAME"."_av_master",
			module 		=> $gWRAPPER_NAME."_av_master",
			in_port_map 	=>
			{
				Avl_rd_data 		=> "Avl_rd_data",
				Avl_rd_datavalid 	=> "Avl_rd_datavalid",
				Avl_rd_wait 		=> "Avl_rd_wait",
				Avl_wr_wait 		=> "Avl_wr_wait",
				clk 			=> "clk",
				rd_addr 		=> "Read_Addr",# "rd_dgen_addr",
				reset_n 		=> "reset_n",
				wr_addr 		=> "Write_Addr",#"wr_dgen_addr",
				wr_data 		=> "Write_Data",#"wr_dgen_data",
				wr_en			=> "wr_dgen_enable",
				rd_en			=> "rd_dgen_enable",
				total_rd_wr		=> "total_rd_wr",
				random			=> "rand",
			},
			out_port_map	=>
			{
				Avl_rd_addr 		=> "Avl_rd_addr",
				Avl_rd_be 		=> "Avl_rd_be",
				Avl_rd_cs		=> "Avl_rd_cs",
				Avl_read		=> "Avl_read",
				Avl_wr_addr		=> "Avl_wr_addr",
				Avl_wr_be 		=> "Avl_wr_be",
				Avl_wr_cs		=> "Avl_wr_cs",
				Avl_wr_data		=> "Avl_wr_data",
				Avl_write		=> "Avl_write",
				num_wr			=> "num_wr",
				num_rd			=> "num_rd",
				wr_enable		=> "wr_enable",
				rd_enable		=> "rd_enable",
				write_pause		=> "write_pause",
				read_pause		=> "read_pause",
				wr_start		=> "wr_start",
				rd_start		=> "rd_start",
				wr_done			=> "wr_done",
				rd_done			=> "rd_done",
				wr_flag			=> "wr_flag",
				rd_flag			=> "rd_flag",
			}
		}),
	);
########################################   Read Address Generator   ###################################################################
$module->add_contents
(
		e_blind_instance->new
	({
		name 		=> "lfsr_inst_raddr",
		module 		=> "example_lfsr".($memory_address_width  + $deep),
		in_port_map 	=>
		{
			clk   	=> "clk",
			reset_n => "reset_n",
			enable  => "rd_dgen_enable",
			pause   => "rd_pause",
			load   	=> "rd_pause",#"wr_load",#"ZERO",
			"rand"	=> "rand",
			seed 	=> "Addr_Seed",
		},
		out_port_map	=>
		{
			data   => "Read_Addr_temp",#"rd_dgen_addr",
		},
	}),

);
if( $is_busrt4_narrow eq "1" )
{
		$module->add_contents
		(
			e_assign->new({lhs => "Read_Addr[".(($memory_address_width + $is_busrt4_narrow + $deep -1)).":1]",rhs => "Read_Addr_temp"}),
			e_assign->new({lhs => "Read_Addr[0]",rhs => "Read_Addr_temp[0]"}),
		);

}
else
{
		$module->add_contents
		(
			e_assign->new({lhs => "Read_Addr[".(($memory_address_width +  $deep - 1)).":0]",rhs => "Read_Addr_temp"}),
		);

}


########################################   Read Data Generator   ###################################################################
for( my $i = 0 ; $i < $res ; $i++)
{
	 $module->add_contents
	 (
	 	e_comment->new
		({
			comment 	=>
			"---------------------------------------------------------------------\n
			Read Data Generator for the block of data read_data["
			.(($def_lfsr * ($i + 1) -1).":".($i * $def_lfsr))."]\n
			---------------------------------------------------------------------\n",
		}),
		e_blind_instance->new
		({
			name 		=> "lfsr_inst_rdata_$i",
			module 		=> "example_lfsr18",
			in_port_map 	=>
			{
				clk   	=> "clk",
				reset_n => "reset_n",
				enable  => "rd_data_enable",#"rd_dgen_enable",#"rd_enable",
				pause   => "rd_data_pause",
				load	=> "ZERO",
				"rand"	=> "ZERO",
				seed 	=> "Data_Seed_$i",# + ($i * 4),
#				ldata   => "0",
			},
			out_port_map	=>
			{
				data   => "rd_dgen_data[".(($def_lfsr * ($i + 1) -1).":".($i * $def_lfsr))."]",
			},
		}),
	 );
}
if($mod > 0){
	$module->add_contents
	(
		e_comment->new
		({
			comment 	=>
			"---------------------------------------------------------------------\n
			Read Data Generator for the block of data read_data["
			.($local_data_bits).
			":".($def_lfsr * $res)."]\n
			---------------------------------------------------------------------\n",
		}),
		e_blind_instance->new
		({
			name 		=> "lfsr_inst_rdata",
			module 		=> "example_lfsr$mod",
			in_port_map 	=>
			{
				clk   	=> "clk",
				reset_n => "reset_n",
				enable  => "rd_data_enable",#"rd_dgen_enable",#"rd_enable",
				pause   => "rd_data_pause",
				load	=> "ZERO",
				"rand"	=> "ZERO",
				seed 	=> "Data_Seed_modulo[".($mod -1).":0]",# + ($i * 4),
			},
			out_port_map	=>
			{
				data   => "rd_dgen_data[".(($local_data_bits) -1).":".($def_lfsr * $res)."]",
			},
		}),
	);
}

########################################   Code For Error Checking   ###################################################################
	 $module->add_contents
	 (
		e_register->new
		({
			clock		=> "clk",
			q   		=> "rd_dgen_data_reg",
			d   		=> "rd_dgen_data",
			async_set   	=> "reset_n",
			enable	    	=> 1,
		}),

		e_register->new
		({
			clock		=> "clk",
			q   		=> "Avl_rd_data_reg",
			d   		=> "Avl_rd_data",
			async_set   	=> "reset_n",
			enable	    	=> 1,
		}),
		e_register->new
		({
			clock		=> "clk",
			q   		=> "Avl_rd_datavalid_reg",
			d   		=> "Avl_rd_datavalid",
			async_set   	=> "reset_n",
			enable	    	=> 1,
		}),

		e_process->new
		({
			clock	=> "clk",
			reset	=> "reset_n",
			_asynchronous_contents	=>
			[
				e_assign->new({lhs => "fail",rhs => 0}),
			],
			contents	=>
			[
				e_if->new
				({
					condition	=> "Avl_rd_datavalid_reg",
					then		=>
					[
						e_if->new
						({
							condition	=> "rd_dgen_data_reg != Avl_rd_data_reg",
							then		=>
							[e_assign->new({lhs => "fail",rhs => 1})],
							else		=>
							[e_assign->new({lhs => "fail",rhs => 0})],
						}),
					],
					else		=>
					[e_assign->new({lhs => "fail",rhs => 0})],
				}),
			],
		}),
		e_process->new
		({
			clock	=> "clk",
			reset	=> "reset_n",
			_asynchronous_contents	=>
			[
				e_assign->new({lhs => "fail_permanent",rhs => 0}),
			],
			contents	=>
			[
				e_if->new
				({
					condition	=> "fail",
					then		=>
					[
						e_assign->new({lhs => "fail_permanent",rhs => 1}),
					],
				}),
			],
		}),
		e_process->new
		({
			clock	=> '',
			reset	=> '',
			sensitivity_list	=> ["wr_done","wr_dgen_enable"],#num_wr
			contents	=>
			[
				e_if->new
				({
					condition	=> "(~wr_done)",
					then		=>
					[
						e_assign->new({lhs => "wr_dgen_enable",rhs => 1}),
					],
					else		=>
					[
						e_assign->new({lhs => "wr_dgen_enable",rhs => 0}),
					],
				}),
			],
		}),
		e_process->new
		({
			clock	=> '',
			reset	=> '',
			sensitivity_list	=> ["rd_done","wr_done","rd_dgen_enable"],#num_wr","num_rd
			contents	=>
			[
				e_if->new
				({
					condition	=> "((~rd_done) & (wr_done))",# &
					then		=>
					[
						e_assign->new({lhs => "rd_dgen_enable",rhs => 1}),
					],
					else		=>
					[
						e_assign->new({lhs => "rd_dgen_enable",rhs => 0}),
					],
				}),
			],
		}),
		e_process->new
		({
			clock	=> "clk",
			reset	=> "reset_n",
			_asynchronous_contents	=>
			[
				e_assign->new({lhs => "test_complete_deley",rhs => 0}),
			],
			contents	=>
			[
				e_if->new
				({
					condition	=> "(wr_done) & (rd_done)",
					then		=>
					[
						e_assign->new({lhs => "test_complete_deley",rhs => 1}),
					],
					else		=>
					[
						e_assign->new({lhs => "test_complete_deley",rhs => 0}),
					],
				}),
			],
		}),
		e_comment->new({comment => "\n\nInstantiating the pipeline stage to delay the test_complete signal\n
					to make sure that the test is stopped at the end."}),
		  e_blind_instance->new
		  ({
			  name 		=> "auk_${mem_type}_pipeline_test_complete",
			  module 	=> $gWRAPPER_NAME."_auk_${mem_type}_pipeline_test_complete",
			  in_port_map 	=>
			  {
				  clk                 	=> "clk",
				  reset_n              	=> "reset_n",
				  pipeline_data_in    	=> "test_complete_deley",
			  },
			  out_port_map	=>
			  {
				  pipeline_data_out      => "test_complete",
			  },
		  }),
	);
######################################################################################################################################################################
$project->output();
}

1;
#You're done..
