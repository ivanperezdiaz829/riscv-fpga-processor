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
#  Title        : Training block
#  Project      : QDRII SRAM Controller
#
#
#  File         : $RCSfile: write_qdrii_train_wrapper.pm,v $
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


sub write_qdrii_train_wrapper
{
my $mem_type = $gMEM_TYPE;

my $top = e_module->new({name => $gWRAPPER_NAME."_auk_${mem_type}_train_wrapper"});#, output_file => 'd:/OFadeyi/DATA_PATH/temp_gen/'});
my $project = e_project->new({top => $top, language => $language,__system_directory =>$output_directory, timescale => "1ps / 1ps"});#'temp_gen'});
my $module = $project->top();
my $family = $gFAMILY;

my $mem_dq_per_dqs = $gMEM_DQ_PER_DQS;
my $memory_data_width = $gMEMORY_DATA_WIDTH;
my $memory_address_width = $gMEMORY_ADDRESS_WIDTH;
my $qdrii_pin_prefix = $gQDRII_PIN_PREFIX;
my $is_busrt4_narrow = $gIS_BURST4_NARROW;
my $avl_data_width_multiply = $gAVL_DATA_WIDTH_MULTIPLY;
my $use_dqs_for_read = $gUSE_DQS_FOR_READ;
my $local_data_bits = $gLOCAL_DATA_BITS;
my $num_chips_wide = $gNUM_CHIPS_WIDE;
my $num_chips_deep = $gNUM_CHIPS_DEEP;
my $bwsn_width;
my $burst_mode = $gMEMORY_BURST_LENGTH;
my $wr_cmd;
my $rd_cmd;
if($burst_mode == 4){
	$wr_cmd = "enable_wr_rd";
	$rd_cmd = "~enable_wr_rd";
	print "gMEMORY_BURST_LENGTH => $gMEMORY_BURST_LENGTH\n";
}else{
	$wr_cmd = "1'b0";
	$rd_cmd = "1'b0";
}
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
my $deep;
if($num_chips_deep > 1){
	$deep = 1;
}else{
	$deep = 0;
}
my $ram_delay = 13;#"1101";
my $train_Ref = $gTRAIN_REFERENCE;
my $seq = 13 + $train_Ref;
my $bswn_ones; my $bswn_zeros;
my $data_ones; my $data_zeros;
my $addr_ones; my $addr_zeros;
my $chipwide_ones; my $chipwide_zeros;

for($i = 0; $i < ($bwsn_width * 2 * $num_chips_wide); $i++)
{ $bswn_ones .= "1"; $bswn_zeros .= "0"; }

for($i = 0; $i < ($memory_data_width * 2); $i++)
{ $data_ones .= "1"; $data_zeros .= "0"; }

for($i = 0; $i < ($memory_address_width + $deep); $i++)
{ $addr_ones .= "1"; $addr_zeros .= "0"; }

for($i = 0; $i < ($num_chips_wide); $i++)
{ $chipwide_ones .= "1"; $chipwide_zeros .= "0"; }


my $index;
if($num_chips_wide > 1) { $index = "_0"; }
else { $index = ""; }
$module->comment
(
	"------------------------------------------------------------------------------\n
	Title        : $header_title
	Project      : QDRII Controller
	File         : $header_filename
	Revision     : $header_revision
	Abstract:
	QDRII Test Bench
	----------------------------------------------------------------------------------\n",
);
######################################################################################################################################################################
	$module->add_contents
	(
	#####	Ports declaration	#####
		e_port->new({name => "clk" , direction => "input", width => 1}),
		e_port->new({name => "reset_n" , direction => "input", width => 1}),
		e_port->new({name => "train_rdata", direction => "input", width => $memory_data_width * 2 }),
		e_port->new({name => "train_start_training", direction => "input", width => 1}),

		e_port->new({name => "train_wpsn", direction => "output", width => 1}),
		e_port->new({name => "train_rpsn", direction => "output", width => 1}),
		e_port->new({name => "train_been", direction => "output", width => $bwsn_width  * 2 * $num_chips_wide}),
		e_port->new({name => "train_addr", direction => "output", width => $memory_address_width + $deep}),
		e_port->new({name => "train_wdata", direction => "output", width => $memory_data_width * 2 }),
		e_port->new({name =>  "flag_training_done", width => 1, direction => "output"}),
		e_port->new({name =>  "flag_training_incorrect", width => 1, direction => "output"}),
		e_port->new({name =>  "flag_training_pattern_not_found", width => 1, direction => "output"}),
		e_port->new({name =>  "fifo_address_plus_two", width => $num_chips_wide, direction => "output"}),
		e_port->new({name =>  "fifo_address_plus_zero", width => $num_chips_wide, direction => "output"}),
		e_port->new({name =>  "reset_read_and_fifo_n", width => 1, direction => "output"}),





	#####	Signals declaration	#####
		e_signal->new({name =>  "dll_setup_counter", width => 12, export => 0, never_export => 1}),
		e_signal->new({name =>  "flush_lat_counter", width => 6, export => 0, never_export => 1}),
		e_signal->new({name =>  "state", width => 2, export => 0, never_export => 1}),
		e_signal->new({name =>  "training_on", width => 1, export => 0, never_export => 1}),
		e_signal->new({name =>  "rpsn_burst2", width => 1, export => 0, never_export => 1}),
		e_signal->new({name =>  "rpsn_burst4", width => 1, export => 0, never_export => 1}),
		e_signal->new({name =>  "wpsn_burst1", width => 1, export => 0, never_export => 1}),
		e_signal->new({name =>  "wpsn_burst2", width => 1, export => 0, never_export => 1}),
		e_signal->new({name =>  "wpsn_burst4", width => 1, export => 0, never_export => 1}),
		e_signal->new({name =>  "block_pattern_not_found", width => $num_chips_wide, export => 0, never_export => 1}),
		e_signal->new({name =>  "block_pattern_incorrect", width => $num_chips_wide, export => 0, never_export => 1}),
		e_signal->new({name =>  "block_pattern_on_time", width => $num_chips_wide, export => 0, never_export => 1}),
		e_signal->new({name =>  "block_pattern_early", width => $num_chips_wide, export => 0, never_export => 1}),

		e_signal->new({name =>  "block_pattern_late", width => $num_chips_wide, export => 0, never_export => 1}),
		e_signal->new({name =>  "load_new_address", width => 1, export => 0, never_export => 1}),
		e_signal->new({name =>  "training_attempt_counter", width => 5, export => 0, never_export => 1}),
	);
######################################################################################################################################################################
	$module->add_contents
	(

	    e_process->new
	    ({
		clock		=> "clk",
		reset		=> "reset_n",
		_asynchronous_contents	=>
		[
	  	e_assign->new(["flag_training_pattern_not_found", "1'b1"]),
	  	e_assign->new(["flag_training_incorrect", "1'b1"]),
	  	e_assign->new(["flag_training_done", "1'b0"]),
	  	e_assign->new(["state", "2'b00"]),
	  	e_assign->new(["dll_setup_counter", "12'b00000000000"]),
	  	e_assign->new(["flush_lat_counter", "6'b000000"]),
	  	e_assign->new(["training_attempt_counter", "5'b00000"]),
	  	e_assign->new(["load_new_address", "1'b0"]),
	  	e_assign->new(["training_on", "1'b0"]),
	  	e_assign->new(["rpsn_burst2", "1'b1"]),
	  	e_assign->new(["rpsn_burst4", "1'b1"]),
	  	e_assign->new(["wpsn_burst2", "1'b1"]),
	  	e_assign->new(["wpsn_burst4", "1'b1"]),
	  	e_assign->new(["reset_read_and_fifo_n", "1'b0"]),
	  	e_assign->new(["train_wdata", ($memory_data_width * 2)."'b".$data_zeros]),
		],
		contents	=>
		[
			e_assign->new(["state", "state"]),
			e_assign->new(["load_new_address", "1'b0"]),
			e_assign->new(["rpsn_burst2", "rpsn_burst2"]),
			e_assign->new(["rpsn_burst4", "rpsn_burst4"]),
			e_assign->new(["wpsn_burst2", "wpsn_burst2"]),
			e_assign->new(["wpsn_burst4", "wpsn_burst4"]),
			e_assign->new(["train_wdata", ($memory_data_width * 2)."'b".$data_zeros]),
			e_assign->new(["reset_read_and_fifo_n", "dll_setup_counter[11]"]),
			
			e_if->new
			({
				condition	=> "(state == 2'b00)",
				then		=>
				[
					e_if->new
					({
						condition	=> "(dll_setup_counter[11] == 1'b1) && (dll_setup_counter[3] == 1'b1)",
						then		=>
						[
							e_assign->new(["state", "2'b01"]),
							e_assign->new(["flush_lat_counter", "6'b000000"]),
							e_assign->new(["rpsn_burst2", "1'b0"]),
							e_assign->new(["rpsn_burst4", "1'b0"]),
							e_assign->new(["wpsn_burst2", "1'b0"]),
							e_assign->new(["wpsn_burst1", "1'b1"]),
						],
						else		=>
						[e_assign->new(["dll_setup_counter", "dll_setup_counter + 1"]),],
					}),
				],
				else		=>
				[
					e_if->new
					({
						condition	=> "(state == 2'b01)",
						then		=>
						[
							e_assign->new(["rpsn_burst4", "~rpsn_burst4"]),
							e_assign->new(["wpsn_burst4", "~wpsn_burst4"]),

							e_if->new
							({
								condition	=> "(flush_lat_counter[4:0] == 5'b11111)",
								then		=>
								[
									e_assign->new(["state", "2'b10"]),
									e_assign->new(["flush_lat_counter", "6'b000000"]),
									e_assign->new(["training_on", "1'b1"]),
									e_assign->new(["train_wdata", ($memory_data_width * 2)."'b".$data_ones]),
								],
								else		=>
								[e_assign->new(["flush_lat_counter", "flush_lat_counter + 1"]),],
							}),
						],
						else		=>
						[
							e_if->new
							({
								condition	=> "(state == 2'b10)",
								then		=>
								[
									e_assign->new(["rpsn_burst4", "~rpsn_burst4"]),
									e_assign->new(["wpsn_burst4", "~wpsn_burst4"]),
									e_assign->new(["train_wdata", ($memory_data_width * 2)."'b".$data_ones]),

									e_if->new
									({
										condition	=> "(flush_lat_counter[4:0] == 5'b11111)",
										then		=>
										[
											e_assign->new(["train_wdata", ($memory_data_width * 2)."'b".$data_zeros]),
											e_assign->new(["load_new_address", "1'b1"]),
											e_assign->new(["training_on", "1'b0"]),
											e_if->new
											({
												condition	=> "(block_pattern_on_time != ".($num_chips_wide)."'b".$chipwide_ones.") && (training_attempt_counter[4] == 1'b0)",
												then		=>
												[
													e_assign->new(["state", "2'b01"]),
													e_assign->new(["flush_lat_counter", "6'b000000"]),
													e_assign->new(["training_attempt_counter", "training_attempt_counter + 1"]),
												],
												else    =>
												[
													e_if->new
													({
														condition	=> "(&block_pattern_on_time != 1)",
														then		=>
														[
															e_assign->new(["flag_training_incorrect", "1'b1"]),
														],
														else =>
														[
															e_assign->new(["flag_training_incorrect", "1'b0"]),
														],
													}),
													e_if->new
													({
														condition	=> "(|block_pattern_not_found == 1)",
														then		=>
														[
															e_assign->new(["flag_training_pattern_not_found", "1'b1"]),
														],
														else =>
														[
															e_assign->new(["flag_training_pattern_not_found", "1'b0"]),
														],
													}),
													e_assign->new(["state", "2'b11"]),
													e_assign->new(["flag_training_done", "1'b1"]),
													e_assign->new(["rpsn_burst2", "1'b1"]),
													e_assign->new(["rpsn_burst4", "1'b1"]),
													e_assign->new(["wpsn_burst2", "1'b1"]),
													e_assign->new(["wpsn_burst1", "1'b1"]),

												],
											}),
										],
										else		=>
										[e_assign->new(["flush_lat_counter", "flush_lat_counter + 1"]),],
									}),
								],
								else		=>
								[
									e_if->new
									({
										condition	=> "(train_start_training == 1'b1 )",
										then		=>
										[
											e_assign->new(["state", "2'b01"]),
											e_assign->new(["flush_lat_counter", "6'b000000"]),
											e_assign->new(["rpsn_burst2", "1'b0"]),
											e_assign->new(["rpsn_burst4", "1'b0"]),
											e_assign->new(["wpsn_burst2", "1'b0"]),
											e_assign->new(["wpsn_burst1", "1'b1"]),
										],
									}),

								],
							}),
						],
					}),

				],
			}),
		],
	    }),

		e_process->new
		({
			clock		=> '',
			reset		=> '',
			sensitivity_list=>
			["rpsn_burst2","rpsn_burst4","wpsn_burst2","wpsn_burst4"],
			_contents	=>
			[
				e_if->new
				({
					condition	=> $burst_mode ." == 2 ",
					then		=>
					[
						e_assign->new(["train_rpsn", "rpsn_burst2"]),
						e_assign->new(["train_wpsn", "wpsn_burst2"]),
					],
					else  =>
					[
						e_assign->new(["train_rpsn", "rpsn_burst4"]),
						e_assign->new(["train_wpsn", "wpsn_burst4"]),
					],
				}),

			],
		}),

		e_process->new
		({
			clock		=> '',
			reset		=> '',
			sensitivity_list=>
			["load_new_address","block_pattern_early","block_pattern_late"],
			_contents	=>
			[
				e_if->new
				({
					condition	=> "(load_new_address == 1'b1 )",
					then		=>
					[
						e_assign->new(["fifo_address_plus_zero", "block_pattern_early"]),
						e_assign->new(["fifo_address_plus_two", "block_pattern_late"]),
					],
					else  =>
					[
						e_assign->new(["fifo_address_plus_two", ($num_chips_wide)."'b".$chipwide_zeros]),
						e_assign->new(["fifo_address_plus_zero", ($num_chips_wide)."'b".$chipwide_zeros]),
					],
				}),

			],
		}),

		e_assign->new(["train_been", ($bwsn_width  * 2 * $num_chips_wide)."'b".$bswn_zeros]),
		e_assign->new(["train_addr", ($memory_address_width + $deep)."'b".$addr_zeros]),


	);
######################################################################################################################################################################
my $training;
if($num_chips_wide > 1)
{
	for($i = 0; $i < $num_chips_wide; $i++)
	{
		$module->add_contents
		(
			e_blind_instance->new
			({
				name 		=> "auk_${mem_type}_test_group_$i",
				module 		=> $gWRAPPER_NAME."_auk_${mem_type}_test_group",
				in_port_map 	=>
				{
					clk			=> "clk",
					reset_n 		=> "reset_n",
					train_rdata 		=> "train_rdata[".($memory_data_width * 2 * $i / $num_chips_wide)."]",
					training_on => "training_on",
					latency_counter => "flush_lat_counter[4:0]",
				},
				out_port_map	=>
				{
					pattern_not_found 	=> "block_pattern_not_found[".($i)."]",
					pattern_incorrect	=> "block_pattern_incorrect[".($i)."]",
					pattern_on_time		=> "block_pattern_on_time[".($i)."]",
					pattern_early		=> "block_pattern_early[".($i)."]",
					pattern_late		=> "block_pattern_late[".($i)."]",
				},
			}),
		);
	}
}else{
	$module->add_contents
	(
		e_blind_instance->new
		({
			name 		=> "auk_${mem_type}_test_group",
			module 		=> $gWRAPPER_NAME."_auk_${mem_type}_test_group",
			in_port_map 	=>
			{
				clk			=> "clk",
				reset_n 		=> "reset_n",
				train_rdata 		=> "train_rdata[0]",
				training_on => "training_on",
				latency_counter => "flush_lat_counter[4:0]",
			},
			out_port_map	=>
			{
				pattern_not_found 	=> "block_pattern_not_found[0]",
				pattern_incorrect	=> "block_pattern_incorrect[0]",
				pattern_on_time		=> "block_pattern_on_time[0]",
				pattern_early		=> "block_pattern_early[0]",
				pattern_late		=> "block_pattern_late[0]",
			},
		}),
	);
}

######################################################################################################################################################################
$project->output();
}

1;
#You're done.
