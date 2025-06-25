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
#  File         : $RCSfile: write_qdrii_mw_wrapper.pm,v $
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

sub write_qdrii_mw_wrapper

{
my $mem_type = $gMEM_TYPE;

my $top = e_module->new({name => $gWRAPPER_NAME."_auk_${mem_type}_mw_wrapper"});#, output_file => 'd:/OFadeyi/DATA_PATH/temp_gen/'});
my $project = e_project->new({top => $top, language => $language,__system_directory =>$output_directory,timescale => "1ps / 1ps"});#'temp_gen'});
my $module = $project->top();


my $family = $gFAMILY;
my $header_title = "Datapath for the Altera QDRII SDRAM Controller";
my $project_title = "QDRII SDRAM Controller";
my $header_filename = $gWRAPPER_NAME . "_auk_${mem_type}_datapath" . $file_ext;
my $header_revision = "V" . $gWIZARD_VERSION;
my $header_abstract = "This file contains the datapath for the QDRII SDRAM Controller";
my $num_clock_pairs = $gNUM_OUTPUT_CLOCKS;

my $device_clk = "write_clk";
my $memory_data_width = $gMEMORY_DATA_WIDTH;
my $memory_address_width = $gMEMORY_ADDRESS_WIDTH;
my $mem_dq_per_dqs = $gMEM_DQ_PER_DQS;
my $local_data_bits = $gLOCAL_DATA_BITS;
my $avl_data_width_multiply = $gAVL_DATA_WIDTH_MULTIPLY;
my $bwsn_width;
my $is_busrt4_narrow = $gIS_BURST4_NARROW;
my $use_dqs_for_read = $gUSE_DQS_FOR_READ;
my $qdrii_pin_prefix = $gQDRII_PIN_PREFIX;
my $num_chips_wide = $gNUM_CHIPS_WIDE;
my $num_chips_deep = $gNUM_CHIPS_DEEP;
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

my %in_param;
my @in_param;
my @addr_wrapper;
my %addr_wrapper;
my @addr_wrapper_list;
my $deep;
if($num_chips_deep > 1){
	$deep = 1;
}else{
	$deep = 0;
}
my @data_wrapper;
my %data_wrapper;
my @data_wrapper_list;
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
		----------------------------------------------------------------------------------\n"
	);
######################################################################################################################################################################
	$module->add_contents
	(
	#####	Ports declaration#	######
		e_port->new({name => "avl_addr_wr",direction => "input" ,width => $gMEMORY_ADDRESS_WIDTH + $is_busrt4_narrow + $deep}),
		e_port->new({name => "avl_data_wr",direction => "input" ,width => $local_data_bits}), #($mem_dq_per_dqs * 2)
		e_port->new({name => "avl_byteen_wr",direction => "input" ,width => $bwsn_width * $avl_data_width_multiply * $num_chips_wide}),
		e_port->new({name => "avl_wait_request_wr",direction => "output"}),
		e_port->new({name => "avl_chipselect_wr",direction => "input"}),
		e_port->new({name => "avl_write",direction => "input"}),

		e_port->new({name => $clock_pos_pin_name,direction => "output",width => $num_clock_pairs,declare_one_bit_as_std_logic_vector => 1}),
		e_port->new({name => $clock_neg_pin_name,direction => "output",width => $num_clock_pairs,declare_one_bit_as_std_logic_vector => 1}),

		e_port->new({name => "avl_addr_rd",direction => "input",width => $gMEMORY_ADDRESS_WIDTH + $is_busrt4_narrow + $deep}),
		e_port->new({name => "avl_data_rd",direction => "output" ,width => ($local_data_bits / 2) * $gAVL_DATA_WIDTH_MULTIPLY}), #($mem_dq_per_dqs * 2)
		e_port->new({name => "avl_byteen_rd",direction => "input" ,width => $bwsn_width * $avl_data_width_multiply * $num_chips_wide}),
		e_port->new({name => "avl_data_read_valid",direction => "output"}),
		e_port->new({name => "avl_wait_request_rd",direction => "output"}),
		e_port->new({name => "avl_chipselect_rd",direction => "input"}),
		e_port->new({name => "avl_read",direction => "input"}),

		e_port->new({name => "avl_clock",direction => "input"}),
		e_port->new({name => "avl_clock_wr",direction => "input"}),
		e_port->new({name => "avl_resetn",direction => "input"}),

		e_comment->new({comment => "\n\n\ncontroller instantiation\n\n"}),
	);
	if($family eq "Stratix II")
	{
		$module->add_contents
		(
			e_port->new({name => "dll_delay_ctrl",direction => "input", width => 6}),
		);
		$in_param{'dll_delay_ctrl'} = "dll_delay_ctrl";
		@in_param = %in_param;
	}
	if ($use_dqs_for_read eq "false")
	{
		$module->add_contents
		(
			e_port->new({name => "capture_clk",direction => "input", width => 1}),
		);
		$in_param{'capture_clk'} = "capture_clk";
	}
	else
	{
		if($num_chips_wide > 1)
		{
			for(my $k = 0; $k < ($num_chips_wide + 0); $k++)
			{
				$module->add_contents
				(
					e_port->new({name => "${qdrii_pin_prefix}cq_$k",direction => "inout", declare_one_bit_as_std_logic_vector => 1}),
					e_port->new({name => "${qdrii_pin_prefix}cqn_$k",direction => "inout", declare_one_bit_as_std_logic_vector => 1}),
				);

				$inout_param{"${qdrii_pin_prefix}cq_$k"} = "${qdrii_pin_prefix}cq_$k"."[0:0]";
				$inout_param{"${qdrii_pin_prefix}cqn_$k"} = "${qdrii_pin_prefix}cqn_$k"."[0:0]";
			}
		}else{
			$module->add_contents
			(
				e_port->new({name => "${qdrii_pin_prefix}cq",direction => "inout", declare_one_bit_as_std_logic_vector => 1}),
				e_port->new({name => "${qdrii_pin_prefix}cqn",direction => "inout", declare_one_bit_as_std_logic_vector => 1}),
			);
			$inout_param{"${qdrii_pin_prefix}cq"} = "${qdrii_pin_prefix}cq"."[0:0]";
			$inout_param{"${qdrii_pin_prefix}cqn"} = "${qdrii_pin_prefix}cqn"."[0:0]";
		}
	}
	if($num_chips_wide > 1)
	{
		for(my $k = 0; $k < ($num_chips_wide + 0); $k++)
		{
			$module->add_contents
			(
				e_port->new({name => "${qdrii_pin_prefix}d_$k",direction => "output",width => $mem_dq_per_dqs}),
				e_port->new({name => "${qdrii_pin_prefix}q_$k",direction => "inout",width => $mem_dq_per_dqs}),
			);

			$data_wrapper{"${qdrii_pin_prefix}d_$k"} = "${qdrii_pin_prefix}d_$k";
			$inout_param{"${qdrii_pin_prefix}q_$k"} = "${qdrii_pin_prefix}q_$k";
		}
	}else{
		$module->add_contents
		(
			e_port->new({name => "${qdrii_pin_prefix}d",direction => "output",width => $mem_dq_per_dqs}),
			e_port->new({name => "${qdrii_pin_prefix}q",direction => "inout",width => $mem_dq_per_dqs}),
		);

		$data_wrapper{"${qdrii_pin_prefix}d"} = "${qdrii_pin_prefix}d";
		$inout_param{"${qdrii_pin_prefix}q"} = "${qdrii_pin_prefix}q";
	}
	if(($num_chips_wide > 1) || ($num_chips_deep > 1))
	{
		for($i = 0; $i < ($num_chips_deep + 0); $i++){
			for($j = 0; $j < ($num_chips_wide + 0); $j++){
				$module->add_contents
				(
					e_port->new({name => "${qdrii_pin_prefix}rpsn_$j"."_$i",direction => "output", width => 1}),
					e_port->new({name => "${qdrii_pin_prefix}wpsn_$j"."_$i",direction => "output", width => 1}),
					e_port->new({name => "${qdrii_pin_prefix}bwsn_$j"."_$i",direction => "output", width => $bwsn_width}),
					e_port->new({name => "${qdrii_pin_prefix}a_$j"."_$i",direction => "output", width => $memory_address_width,declare_one_bit_as_std_logic_vector => 0}),
				);
				$addr_wrapper{"${qdrii_pin_prefix}rpsn_$j"."_$i"} = "${qdrii_pin_prefix}rpsn_$j"."_$i";
				$addr_wrapper{"${qdrii_pin_prefix}wpsn_$j"."_$i"} = "${qdrii_pin_prefix}wpsn_$j"."_$i";
				$addr_wrapper{"${qdrii_pin_prefix}bwsn_$j"."_$i"} = "${qdrii_pin_prefix}bwsn_$j"."_$i";
				$addr_wrapper{"${qdrii_pin_prefix}a_$j"."_$i"} = "${qdrii_pin_prefix}a_$j"."_$i";

			}
		}
	}else{
		$module->add_contents
		(
			e_port->new({name => "${qdrii_pin_prefix}rpsn",direction => "output", width => 1}),
			e_port->new({name => "${qdrii_pin_prefix}wpsn",direction => "output", width => 1}),
			e_port->new({name => "${qdrii_pin_prefix}bwsn",direction => "output", width => $bwsn_width}),
			e_port->new({name => "${qdrii_pin_prefix}a",direction => "output", width => $memory_address_width,declare_one_bit_as_std_logic_vector => 0}),
		);
		$addr_wrapper{"${qdrii_pin_prefix}rpsn"} = "${qdrii_pin_prefix}rpsn";
		$addr_wrapper{"${qdrii_pin_prefix}wpsn"} = "${qdrii_pin_prefix}wpsn";
		$addr_wrapper{"${qdrii_pin_prefix}bwsn"} = "${qdrii_pin_prefix}bwsn";
		$addr_wrapper{"${qdrii_pin_prefix}a"} = "${qdrii_pin_prefix}a";
	}

	@inout_param = %inout_param;
	@in_param = %in_param;
	@addr_wrapper = %addr_wrapper;
	@data_wrapper = %data_wrapper;
	my @inout_parameter_list;
	foreach my $parameter (@inout_param) {push (@inout_parameter_list, $parameter);}
	my @in_parameter_list;
	foreach my $parameter (@in_param) {push (@in_parameter_list, $parameter);}
	foreach my $data (@data_wrapper) {push (@data_wrapper_list, $data);}
	foreach my $addr (@addr_wrapper) { push (@addr_wrapper_list, $addr); }
######################################################################################################################################################################
	$module->add_contents
	(
		e_comment->new
		({
			comment => "------------------------------------------------------------\n
				   Instance of the Controller module \n
				   ------------------------------------------------------------\n"
		}),
		e_blind_instance->new
		({
			name 		=> "auk_auk_qdrii_sram",
			module 		=> $gWRAPPER_NAME."_auk_qdrii_sram",
			in_port_map 	=>
			{
				avl_clock		=> "avl_clock",
				avl_clock_wr		=> "avl_clock_wr",
				avl_resetn		=> "avl_resetn",

				avl_addr_wr		=> "avl_addr_wr",
				avl_data_wr		=> "avl_data_wr",
				avl_write		=> "avl_write",
				avl_chipselect_wr	=> "avl_chipselect_wr",
				avl_byteen_wr		=> "avl_byteen_wr",


				avl_addr_rd		=> "avl_addr_rd",
				avl_chipselect_rd	=> "avl_chipselect_rd",
				avl_read		=> "avl_read",
				avl_byteen_rd		=> "avl_byteen_rd",

				@in_param		=> @in_parameter_list,
			},
			out_port_map	=>
			{
				avl_wait_request_wr	=> "avl_wait_request_wr",

				avl_wait_request_rd 	=> "avl_wait_request_rd",
				avl_data_read_valid	=> "avl_data_read_valid",
				avl_data_rd		=> "avl_data_rd",

				@addr_wrapper		=> @addr_wrapper_list,
				@data_wrapper		=> @data_wrapper_list,
				$clock_pos_pin_name 	=> $clock_pos_pin_name."[".($num_clock_pairs-1).":0]",
				$clock_neg_pin_name	=> $clock_neg_pin_name."[".($num_clock_pairs-1).":0]",
			},
  			inout_port_map	=>
			{
				@inout_param		=> @inout_parameter_list,
			},

			std_logic_vector_signals	=>
			[
				@inout_parameter_list,
				$clock_pos_pin_name,
				$clock_neg_pin_name,
			],
		}),
	);
##################################################################################################################################################################
$project->output();
}

1;
#You're done.
