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
#  File         : $RCSfile: write_qdrii_avalon_read_if_ipfs_wrap.pm,v $
#
#  Last modified: $Date: 2013/08/11 $
#  Revision     : $Revision: #1 $
#
#  Abstract:
#
#  Notes:
# ------------------------------------------------------------------------------
#sopc_builder free code
use e_auk_qdrii_avalon_read_if;
use europa_all;
use europa_utils;


sub write_qdrii_avalon_read_if_ipfs_wrap
{
my $mem_type = $gMEM_TYPE;
my $top = e_module->new({name => "auk_qdrii_avalon_read_if_ipfs_wrap"});#, output_file => 'd:/OFadeyi/DATA_PATH/temp_gen/'});
my $project = e_project->new({top => $top, language => $language,__system_directory =>$output_directory,timescale => "1ps / 1ps"});#'temp_gen'});
my $module = $project->top();



my $header_title = "Datapath for the Altera QDRII SDRAM Controller";
my $project_title = "QDRII SDRAM Controller";
my $header_filename = "auk_qdrii_avalon_read_if_ipfs_wrap" . $file_ext;
my $header_revision = "V" . $gWIZARD_VERSION;
my $header_abstract = "This file contains the datapath for the QDRII SDRAM Controller";
my $num_clock_pairs = $gNUM_OUTPUT_CLOCKS;

my $device_clk = "write_clk";
my $family = $gFAMILY;
my $memory_data_width = $gMEMORY_DATA_WIDTH;
my $memory_address_width = $gMEMORY_ADDRESS_WIDTH;
my $local_data_bits = $gLOCAL_DATA_BITS;
my $delay_chain = $gDELAY_CHAIN;
my $burst_mode = $gMEMORY_BURST_LENGTH;
my $delay = 0;
#if($burst_mode == 2) { $delay = 3 }
my $avl_data_width_multiply = $gAVL_DATA_WIDTH_MULTIPLY;
my $mem_dq_per_dqs = $gMEM_DQ_PER_DQS;
my $num_pipeline_addr_cmd_stages = $gPIPELINE_ADDRESS_COMMAND;
my $num_pipeline_rdata_stages = $gPIPELINE_READ_DATA;
my $read_valid_cycle = $gREAD_VALID_CYCLE;#($gTRAIN_REFERENCE + $delay) + $num_pipeline_rdata_stages + $num_pipeline_addr_cmd_stages;
my $bwsn_width;
my $is_busrt4_narrow = $gIS_BURST4_NARROW;
my $use_dqs_for_read = $gUSE_DQS_FOR_READ;
my $qdrii_pin_prefix = $gQDRII_PIN_PREFIX;
#my $clock_pos_pin_name = $gCLOCK_POS_PIN_NAME;
#my $clock_neg_pin_name = $gCLOCK_NEG_PIN_NAME;
my $clock_pos_pin_name = $qdrii_pin_prefix . "k";
my $clock_neg_pin_name = $qdrii_pin_prefix . "kn";

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

######################################################################################################################################################################
	$module->comment
	(
		"------------------------------------------------------------------------------\n
		 This confidential and proprietary software may be used only as authorized by\na licensing agreement from Altera Corporation.\n\n
		 (C) COPYRIGHT 2004 ALTERA CORPORATION\nALL RIGHTS RESERVED\n\nThe entire notice above must be reproduced on all authorized copies and any\n
		 such reproduction must be pursuant to a licensing agreement from Altera.\n\n
		 Title        : $header_title\n
		 Project      : $project_title\n
		 File         : $header_filename\n\n
		 Revision     : $header_revision\n\n
		 Abstract:\n$header_abstract\n\n
		 ----------------------------------------------------------------------------------\n
		 Parameters:\n
		 Device Family                      : $gFAMILY\n
		 ----------------------------------------------------------------------------------\n",
	);
######################################################################################################################################################################
	$module->add_contents
	(
	#####	Ports declaration#	######
		e_port->new({name => "avl_addr_rd",direction => "input",width => $memory_address_width + $is_busrt4_narrow + $deep}),
		e_port->new({name => "avl_data_rd",direction => "output" ,width => $local_data_bits}), #($mem_dq_per_dqs * 2)
		#e_port->new({name => "avl_byteen_rd",direction => "input" ,width => $bwsn_width * $avl_data_width_multiply * $num_chips_wide}),
		e_port->new({name => "avl_data_read_valid",direction => "output"}),
		e_port->new({name => "avl_wait_request_rd",direction => "output"}),
		e_port->new({name => "avl_chipselect_rd",direction => "input"}),
		e_port->new({name => "avl_read",direction => "input"}),
		e_port->new({name => "control_training_finished",direction => "input"}),
		e_port->new({name => "control_undelayed_read_valid",direction => "output"}),


		e_port->new({name => "control_addr_comb_rd",direction => "output",width => $memory_address_width + $deep}),
		e_port->new({name => "control_wpsn_comb",direction => "input",width => 1}),
		e_port->new({name => "control_rpsn",direction => "output",width => 1}),
		#e_signal->new({name => "control_bwsn",$bwsn_width * 2 * $num_chips_wide,0,1]),
		e_port->new({name => "control_q",direction => "input",width => $memory_data_width * 2}),


		e_port->new({name => "avl_clock",direction => "input"}),
		e_port->new({name => "avl_resetn",direction => "input"}),
	);
	$module->add_contents
	(
		e_comment->new
		({
			comment => "------------------------------------------------------------\n
				   Instance of the Controller Avalon Read Interface\n
				   ------------------------------------------------------------\n"
		}),
		e_auk_qdrii_avalon_read_if->new
		({
			name 		=> "avalon_read_interface",
			module 		=> "auk_qdrii_avalon_read_if",
			port_map 	=>
			{
				avl_addr_rd		=> "avl_addr_rd[".(($memory_address_width + $is_busrt4_narrow + $deep) - 1).":0]",
				avl_clock		=> "avl_clock",
				avl_resetn		=> "avl_resetn",
				avl_chipselect_rd	=> "avl_chipselect_rd",
				avl_read		=> "avl_read",
				# avl_byteen_rd		=> "avl_byteen_rd",
				control_wpsn_comb	=> "control_wpsn_comb",
				control_q		=> "control_q",
				control_training_finished		=> "control_training_finished",
			},
			out_port_map	=>
			{
				avl_data_rd		=> "avl_data_rd",
				avl_data_read_valid	=> "avl_data_read_valid",
				avl_wait_request_rd	=> "avl_wait_request_rd",
				control_addr_comb_rd	=> "control_addr_comb_rd",
				control_rpsn		=> "control_rpsn",
				control_undelayed_read_valid		=> "control_undelayed_read_valid",
			},
			parameter_map =>
			{
				gIS_BURST4_NARROW	=> $is_busrt4_narrow,
				gAVL_DATA_WIDTH_MULTIPLY=> $avl_data_width_multiply,
				gBURST_MODE             => $burst_mode,
				gMEMORY_DATA_WIDTH      => $memory_data_width,
				gMEMORY_ADDRESS_WIDTH   => $memory_address_width + $deep,
				gREAD_VALID_CYCLE	=> $read_valid_cycle,
			}
		}),
	);
##################################################################################################################################################################
$project->output();
}

1;
#You're done.
