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
#  Title        : Top level of the core
#  Project      : QDRII SRAM Controller
#
#
#  File         : $RCSfile: write_qdrii_sdram.pm,v $
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


sub write_qdrii_sdram
{
my $mem_type = $gMEM_TYPE;
my $top = e_module->new({name => $gWRAPPER_NAME."_auk_qdrii_sram"});#, output_file => 'd:/OFadeyi/DATA_PATH/temp_gen/'});
my $project = e_project->new({top => $top, language => $language,__system_directory =>$output_directory,timescale => "1ps / 1ps"});#'temp_gen'});
my $module = $project->top();



my $header_title = "Datapath for the Altera QDRII SDRAM Controller";
my $project_title = "QDRII SDRAM Controller";
my $header_filename = $gWRAPPER_NAME . "_auk_${mem_type}_sram". $file_ext;
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
my $avl_data_width_multiply = $gAVL_DATA_WIDTH_MULTIPLY;
my $mem_dq_per_dqs = $gMEM_DQ_PER_DQS;
my $num_pipeline_addr_cmd_stages = $gPIPELINE_ADDRESS_COMMAND;
my $num_pipeline_rdata_stages = $gPIPELINE_READ_DATA;
my $read_valid_cycle = 5 + $num_pipeline_rdata_stages + $num_pipeline_addr_cmd_stages;
my $bwsn_width;
my $is_busrt4_narrow = $gIS_BURST4_NARROW;
my $use_dqs_for_read = $gUSE_DQS_FOR_READ;
my $qdrii_pin_prefix = $gQDRII_PIN_PREFIX;
my $clock_pos_pin_name = $qdrii_pin_prefix . "k";
my $clock_neg_pin_name = $qdrii_pin_prefix . "kn";
my $ddio_memory_clocks = $gDDIO_MEMORY_CLOCKS;

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

my %in_param;
my @in_param;
my @addr_wrapper;
my %addr_wrapper;
my @clock_ports;
my %clock_ports;
my @clock_ports_list;
my @out_ports;
my %out_ports;
my @out_ports_list;
my @addr_wrapper_list;
my @stratixii_inout;
my %stratixii_inout;
my @stratixii_inout_list;
my @resynch_ports_in;
my %resynch_ports_in;
my @resynch_ports_in_list;
my @resynch_ports_out;
my %resynch_ports_out;
my @resynch_ports_out_list;
my $num_chips_wide = $gNUM_CHIPS_WIDE;
my $num_chips_deep = $gNUM_CHIPS_DEEP;
my $deep;
if($num_chips_deep > 1){
	$deep = 1;
}else{
	$deep = 0;
}
my $test = $gTRAIN_MODE;
######################################################################################################################################################################
	$module->comment
	(
		"------------------------------------------------------------------------------\n
		 Title        : $header_title\n
		 Project      : $project_title\n
		 File         : $header_filename\n\n
		 Revision     : $header_revision\n\n
		 Abstract:\n$header_abstract\n\n
		 ----------------------------------------------------------------------------------\n
		 Parameters:\n
		 Device Family                      : $gFAMILY\n
		 Control Interface Data Width       : $local_data_bits\n
		 Number Memory Clock Pairs          : $num_clock_pairs\n
		 QDRII Interface Data Width	     : $mem_dq_per_dqs\n
		 QDRII Interface Address Width	     : $memory_address_width\n
		 ----------------------------------------------------------------------------------\n",
	);
######################################################################################################################################################################
	$module->add_contents
	(
	#####	Parameters declaration	######
		e_parameter->add({name => "clock_freq_in_mhz", default => "160.0", vhdl_type => "string"}),
		e_parameter->add({name => "memory_device", default => "Default", vhdl_type => "string"}),
		e_parameter->add({name => "memory_model_name", default => "Default", vhdl_type => "string"}),
		e_parameter->add({name => "update_top_level", default => 1, vhdl_type => "string"}),
		e_parameter->add({name => "toplevel_name", default => "qdrii_example_top", vhdl_type => "string"}),
		e_parameter->add({name => "wrapper_name", default => "qdrii_sram_top", vhdl_type => "string"}),
		e_parameter->add({name => "clock_pos_pin_name", default => "k", vhdl_type => "string"}),
		e_parameter->add({name => "clock_neg_pin_name", default => "kn", vhdl_type => "string"}),
		e_parameter->add({name => "capture_clock_pos_pin_name", default => "cq", vhdl_type => "string"}),
		e_parameter->add({name => "capture_clock_neg_pin_name", default => "cqn", vhdl_type => "string"}),
		e_parameter->add({name => "variation_test_path", default => 0, vhdl_type => "string"}),
		e_parameter->add({name => "variation_path", default => "Default", vhdl_type => "string"}),
		e_parameter->add({name => "qdrii_pin_prefix", default => 16, vhdl_type => "string"}),
		e_parameter->add({name => "memory_burst_length", default => 2, vhdl_type => "string"}),
		e_parameter->add({name => "mem_dq_per_cq", default => 9, vhdl_type => "string"}),
		e_parameter->add({name => "memory_address_width", default => 18, vhdl_type => "string"}),
		e_parameter->add({name => "num_chips_deep", default => 1, vhdl_type => "string"}),
		e_parameter->add({name => "num_chips_wide", default => 1, vhdl_type => "string"}),
		e_parameter->add({name => "narrow_mode", default => 1, vhdl_type => "string"}),
		e_parameter->add({name => "memory_voltage", default => "1.8", vhdl_type => "string"}),
		e_parameter->add({name => "avalon_memory_data_bits", default => 18, vhdl_type => "string"}),
		e_parameter->add({name => "local_data_bits", default => 18, vhdl_type => "string"}),
		e_parameter->add({name => "avalon_memory_address_bits", default => 18, vhdl_type => "string"}),
		e_parameter->add({name => "local_address_bits", default => 18, vhdl_type => "string"}),
		e_parameter->add({name => "num_output_clocks", default => 1, vhdl_type => "string"}),
		e_parameter->add({name => "num_output_control", default => 1, vhdl_type => "string"}),
		e_parameter->add({name => "pipeline_address_command", default => 0, vhdl_type => "string"}),
		e_parameter->add({name => "pipeline_read_data", default => 0, vhdl_type => "string"}),
		e_parameter->add({name => "use_dqs_for_read", default => 1, vhdl_type => "string"}),
		e_parameter->add({name => "fedback_clock_mode", default => 1, vhdl_type => "string"}),
		e_parameter->add({name => "pipe_com_check", default => 0, vhdl_type => "string"}),
		e_parameter->add({name => "pipe_read_check", default => 0, vhdl_type => "string"}),
		e_parameter->add({name => "chosen_resynch_cycle", default => 5, vhdl_type => "string"}),
		e_parameter->add({name => "chosen_resynch_clock", default => "System clock", vhdl_type => "string"}),
		e_parameter->add({name => "chosen_resynch_phase", default => 0, vhdl_type => "string"}),
		e_parameter->add({name => "chosen_resynch_edge", default => 1, vhdl_type => "string"}),
		e_parameter->add({name => "inter_resynch", default => 0, vhdl_type => "string"}),
		e_parameter->add({name => "man_resynch", default => 0, vhdl_type => "string"}),
	);
	$module->add_contents
	(
	#####	Ports declaration#	######
		e_port->new({name => "avl_addr_wr",direction => "input" ,width => $memory_address_width + $is_busrt4_narrow + $deep}),
		e_port->new({name => "avl_data_wr",direction => "input" ,width => $local_data_bits}), # ($mem_dq_per_dqs * 2)
		e_port->new({name => "avl_byteen_wr",direction => "input" ,width => $bwsn_width * $avl_data_width_multiply * $num_chips_wide}),
		e_port->new({name => "avl_wait_request_wr",direction => "output"}),
		e_port->new({name => "avl_chipselect_wr",direction => "input"}),
		e_port->new({name => "avl_write",direction => "input"}),

		# e_port->new({name => "${qdrii_pin_prefix}d",direction => "output",width => $mem_dq_per_dqs}),
		# e_port->new({name => $clock_pos_pin_name,direction => "output",width => $num_clock_pairs,declare_one_bit_as_std_logic_vector => 1}),
		# e_port->new({name => $clock_neg_pin_name,direction => "output",width => $num_clock_pairs,declare_one_bit_as_std_logic_vector => 1}),


		e_port->new({name => "avl_addr_rd",direction => "input",width => $memory_address_width + $is_busrt4_narrow + $deep}),
		e_port->new({name => "avl_data_rd",direction => "output" ,width => $local_data_bits}), #($mem_dq_per_dqs * 2)
		e_port->new({name => "avl_byteen_rd",direction => "input" ,width => $bwsn_width * $avl_data_width_multiply * $num_chips_wide}),
		e_port->new({name => "avl_data_read_valid",direction => "output"}),
		e_port->new({name => "avl_wait_request_rd",direction => "output"}),
		e_port->new({name => "avl_chipselect_rd",direction => "input"}),
		e_port->new({name => "avl_read",direction => "input"}),

		e_port->new({name => "avl_clock",direction => "input"}),
		e_port->new({name => "avl_clock_wr",direction => "input"}),
		e_port->new({name => "avl_resetn",direction => "input"}),
		e_port->new({name => "training_done",direction => "output"}),
		e_port->new({name => "training_incorrect",direction => "output"}),
		e_port->new({name => "training_pattern_not_found",direction => "output"}),


		e_signal->new(["control_a_rd",$memory_address_width + $deep,0,1]),
		e_signal->new(["control_a_wr",$memory_address_width + $deep,0,1]),
		e_signal->new(["control_bwsn",$bwsn_width * 2 * $num_chips_wide,0,1]),
		e_signal->new(["control_rpsn",1,0,1]),
		e_signal->new(["control_wdata", $memory_data_width * 2,0,1]),
		e_signal->new(["control_wpsn",1,0,1]),
		e_signal->new(["control_rdata", $memory_data_width * 2, 0, 1]),
		e_signal->new(["control_wpsn_comb",1,0,1]),
		e_signal->new(["training_addr",$memory_address_width + $deep,0,1]),
		e_signal->new(["training_bwsn",$bwsn_width * 2 * $num_chips_wide,0,1]),
		e_signal->new(["training_rpsn",1,0,1]),
		e_signal->new(["training_wdata", $memory_data_width * 2,0,1]),
		
		# e_signal->new(["training_rdata", $memory_data_width * 2,0,1]),
		e_signal->new(["training_wpsn",1,0,1]),
		e_signal->new(["datapath_wdata", $memory_data_width * 2,0,1]),
		# e_signal->new(["datapath_rdata", $memory_data_width * 2,0,1]),
		# Training signals




		e_comment->new({comment => "\n\n\ncomponents are:\ndatapath including the various level of buffering and IO
					   avalon read interface\navalon write interface\n\n"}),
	);
	
	if ($ddio_memory_clocks eq "true") {
		$module->add_contents
		(
			#####   Internal signal    ######
			e_port->new({name => $clock_pos_pin_name,direction => "output", width => $num_clock_pairs,declare_one_bit_as_std_logic_vector => 1}),
			e_port->new({name => $clock_neg_pin_name,direction => "output", width => $num_clock_pairs,declare_one_bit_as_std_logic_vector => 1}),
		);
	}	
	
if((($use_dqs_for_read eq "false") and ($family eq "Stratix II")) or ($family eq "Stratix"))
	{
		$module->add_contents
		(
			e_port->new({name => "non_dqs_capture_clock",direction => "input", width => 1}),
		);
		$in_param{'non_dqs_capture_clk'} = "non_dqs_capture_clock";
	} else {
		$module->add_contents
		(
			e_port->new({name => "dll_delay_ctrl",direction => "input", width => 6}),
		);
		$in_param{'dll_delay_ctrl'} = "dll_delay_ctrl";

	}

	if(($num_chips_wide > 1) || ($num_chips_deep > 1))
	{
		for($i = 0; $i < $num_chips_deep; $i++){
			for($j = 0; $j < $num_chips_wide; $j++){
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
	@addr_wrapper = %addr_wrapper;
	foreach my $addr (@addr_wrapper) {push (@addr_wrapper_list, $addr);}

	if($num_chips_wide > 1)
	{
		for(my $k = 0; $k < $num_chips_wide; $k++)
		{
			$module->add_contents
			(
				e_port->new({name => "${qdrii_pin_prefix}d_$k",direction => "output",width => $mem_dq_per_dqs}),
			);
			$out_ports{"${qdrii_pin_prefix}d_$k"} = "${qdrii_pin_prefix}d_$k",
		}
	}else{
		$module->add_contents
		(
			e_port->new({name => "${qdrii_pin_prefix}d",direction => "output",width => $mem_dq_per_dqs}),
			e_port->new({name => "${qdrii_pin_prefix}q",direction => "input",width => $mem_dq_per_dqs}),
		);

		$out_ports{"${qdrii_pin_prefix}d"} = "${qdrii_pin_prefix}d";
	}
	if ($ddio_memory_clocks eq "true") {
		$out_ports{"${clock_pos_pin_name}"} = "${clock_pos_pin_name}"."["."($num_clock_pairs-1)".":0]";
		$clock_ports{"${clock_pos_pin_name}"} = "${clock_pos_pin_name}"."["."($num_clock_pairs-1)".":0]";
		$out_ports{"${clock_neg_pin_name}"} = "${clock_neg_pin_name}"."["."($num_clock_pairs-1)".":0]";
		$clock_ports{"${clock_neg_pin_name}"} = "${clock_neg_pin_name}"."["."($num_clock_pairs-1)".":0]";
	}	
	
	#my $cq_cqn;
	if($num_chips_wide > 1)
	{
		for(my $k = 0; $k < $num_chips_wide; $k++)
		{
			$module->add_contents
			(
				e_port->new({name => "${qdrii_pin_prefix}q_$k",direction => "input",width => $mem_dq_per_dqs}),
				#e_port->new({name => "${qdrii_pin_prefix}cq_0",direction => "inout", declare_one_bit_as_std_logic_vector => 1}),
			);
			$in_param{"${qdrii_pin_prefix}q_$k"} = "${qdrii_pin_prefix}q_$k";
			#$stratixii_inout{"${qdrii_pin_prefix}cq_0"} = "${qdrii_pin_prefix}cq_0"."[0:0]";
			if(!((($use_dqs_for_read eq "false") and ($family eq "Stratix II")) or ($family eq "Stratix")))
			{
				$module->add_contents
				(
					e_port->new({name => "${qdrii_pin_prefix}cq_$k",direction => "inout", declare_one_bit_as_std_logic_vector => 1}),
					e_port->new({name => "${qdrii_pin_prefix}cqn_$k",direction => "inout", declare_one_bit_as_std_logic_vector => 1}),
				);
				$stratixii_inout{"${qdrii_pin_prefix}cq_$k"} = "${qdrii_pin_prefix}cq_$k"."[0:0]";
				$stratixii_inout{"${qdrii_pin_prefix}cqn_$k"} = "${qdrii_pin_prefix}cqn_$k"."[0:0]";
				#$cq_cqn .= "${qdrii_pin_prefix}cq_$k,${qdrii_pin_prefix}cqn_$k";
			}
		}
	}else{
		$module->add_contents
		(
			e_port->new({name => "${qdrii_pin_prefix}q",direction => "input",width => $mem_dq_per_dqs}),
			#e_port->new({name => "${qdrii_pin_prefix}cq",direction => "inout", declare_one_bit_as_std_logic_vector => 1}),
		);
		$in_param{"${qdrii_pin_prefix}q"} = "${qdrii_pin_prefix}q";
		if(!((($use_dqs_for_read eq "false") and ($family eq "Stratix II")) or ($family eq "Stratix")))
		{
			$module->add_contents
			(
				e_port->new({name => "${qdrii_pin_prefix}cq",direction => "inout", declare_one_bit_as_std_logic_vector => 1}),
				e_port->new({name => "${qdrii_pin_prefix}cqn",direction => "inout", declare_one_bit_as_std_logic_vector => 1}),
			);
			$stratixii_inout{"${qdrii_pin_prefix}cq"} = "${qdrii_pin_prefix}cq"."[0:0]";
			$stratixii_inout{"${qdrii_pin_prefix}cqn"} = "${qdrii_pin_prefix}cqn"."[0:0]";
		}
	}

    @in_param = %in_param;
    my @in_parameter_list;
	foreach my $parameter (@in_param) {push (@in_parameter_list, $parameter);}
  @clock_ports = %clock_ports;
  my @clock_ports_list;
	foreach my $parameter (@clock_ports) {push (@clock_ports_list, $parameter);}

	@out_ports = %out_ports;
	foreach my $params (@out_ports) {push (@out_ports_list, $params);}
	@stratixii_inout = %stratixii_inout;
	foreach my $var (@stratixii_inout) {push (@stratixii_inout_list, $var);}
######################################################################################################################################################################
	$module->add_contents
	(
		e_comment->new
		({
			comment => "------------------------------------------------------------\n
				   Instance of the Avalon Controller Interface\n
				   ------------------------------------------------------------\n"
		}),
		e_blind_instance->new
		({
			name 		=> "auk_${mem_type}_controller_ipfs",
			module 		=> $gWRAPPER_NAME."_auk_${mem_type}_avalon_controller_ipfs_wrap",
			in_port_map 	=>
			{
				avl_addr_wr		=> "avl_addr_wr[".(($memory_address_width + $is_busrt4_narrow + $deep) - 1).":0]",
				avl_data_wr		=> "avl_data_wr",
				avl_clock		=> "avl_clock",
				avl_resetn		=> "avl_resetn",
				avl_write		=> "avl_write",
				avl_chipselect_wr	=> "avl_chipselect_wr",
				avl_byteen_wr		=> "avl_byteen_wr",
				control_training_finished	=> "training_done",
				#   Read controller signals
				avl_addr_rd		=> "avl_addr_rd[".(($memory_address_width + $is_busrt4_narrow + $deep) - 1).":0]",
				avl_clock		=> "avl_clock",
				avl_resetn		=> "avl_resetn",
				avl_chipselect_rd	=> "avl_chipselect_rd",
				avl_read		=> "avl_read",
				control_wpsn_comb_in	=> "control_wpsn_comb",
				control_q		=> "control_rdata",
				control_training_finished	=> "training_done",
			},
			out_port_map	=>
			{
				avl_wait_request_wr	=> "avl_wait_request_wr",
				control_addr_comb_wr	=> "control_a_wr",
				control_d		=> "control_wdata",
				control_wpsn		=> "control_wpsn",
				control_wpsn_comb_out	=> "control_wpsn_comb",
				control_bwsn		=> "control_bwsn",
				#   Read controller signals
				avl_data_rd		=> "avl_data_rd",
				avl_data_read_valid	=> "avl_data_read_valid",
				avl_wait_request_rd	=> "avl_wait_request_rd",
				control_addr_comb_rd	=> "control_a_rd",
				control_rpsn		=> "control_rpsn",
			},
		}),
	);
############################################### Resynch & Pipeline Modules #########################################################################
my @ports; my %ports;
my @ports_list;
if($num_chips_wide > 1)
{
	for(my $i = 0; $i < $num_chips_wide; $i++)
	{
		$ports{"capture_clock_$i"} = "capture_clock_$i"."[0:0]";
		$ports{"captured_data_$i"} = "captured_data_$i";
		$module->add_contents
		(
			e_signal->new({name => "capture_clock_$i",width => 1,export => 0,never_export => 1,declare_one_bit_as_std_logic_vector => 1}),
			e_signal->new(["captured_data_$i",$mem_dq_per_dqs * 2,0,1]),
		);
	}
}
else
{
	$ports{"capture_clock"} = "capture_clock"."[0:0]";
	$ports{"captured_data"} = "captured_data";
	$module->add_contents
	(
		e_signal->new({name => "capture_clock_$i",width => 1,export => 0,never_export => 1,declare_one_bit_as_std_logic_vector => 1}),
		e_signal->new(["captured_data",$mem_dq_per_dqs * 2,0,1]),
	);
}
@ports = %ports;
foreach my $params (@ports) {push (@ports_list, $params);}

my @ports_pipeline; my %ports_pipeline;
my @ports_pipeline_list;

if(($num_chips_deep > 1) || ($num_chips_wide > 1))
{
    for($j = 0; $j < $num_chips_wide; $j++){
       	for($i = 0; $i < $num_chips_deep; $i++){
            $ports_pipeline{"control_rpsn_${j}_${i}"} = "datapath_rpsn_${j}_${i}";
            $ports_pipeline{"control_wpsn_${j}_${i}"} = "datapath_wpsn_${j}_${i}";
            $ports_pipeline{"control_a_rd_${j}_${i}"} = "datapath_a_rd_${j}_${i}";
            $ports_pipeline{"control_a_wr_${j}_${i}"} = "datapath_a_wr_${j}_${i}";
            $ports_pipeline{"control_bwsn_${j}_${i}"} = "datapath_bwsn_${j}_${i}";
    
            	$module->add_contents
            	(
             		e_signal->new(["control_rpsn_${j}_${i}",1,0,1]),
        	    	e_signal->new(["control_wpsn_${j}_${i}",1,0,1]),
            		e_signal->new(["datapath_a_rd_${j}_${i}",$memory_address_width + $deep,0,1]),
            		e_signal->new(["datapath_a_wr_${j}_${i}",$memory_address_width + $deep,0,1]),
            		e_signal->new(["datapath_bwsn_${j}_${i}",$bwsn_width * 2 * $num_chips_wide,0,1]),
                );

        }
    }
} else {
    $ports_pipeline{"control_rpsn"} = "datapath_rpsn";
    $ports_pipeline{"control_wpsn"} = "datapath_wpsn";
    $ports_pipeline{"control_a_rd"} = "datapath_a_rd";
    $ports_pipeline{"control_a_wr"} = "datapath_a_wr";
    $ports_pipeline{"control_bwsn"} = "datapath_bwsn";
	$module->add_contents
	(
		e_signal->new(["datapath_a_rd",$memory_address_width + $deep,0,1]),
		e_signal->new(["datapath_a_wr",$memory_address_width + $deep,0,1]),
		e_signal->new(["datapath_bwsn",$bwsn_width * 2 * $num_chips_wide,0,1]),
		e_signal->new(["datapath_rpsn",1,0,1]),
		e_signal->new(["datapath_wpsn",1,0,1]),
    );
}

@ports_pipeline = %ports_pipeline;
foreach my $params (@ports_pipeline) {push (@ports_pipeline_list, $params);}


$module->add_contents                                                                              
(
	e_comment->new
	({
		comment => "------------------------------------------------------------\n
			   Instance of the Resynch & Pipeline Module\n
			   ------------------------------------------------------------\n"
	}),
	e_blind_instance->new
	({
		name 		=> "auk_${mem_type}_pipe_resynch_wrapper",
		module 		=> $gWRAPPER_NAME."_auk_${mem_type}_pipe_resynch_wrapper",
		in_port_map 	=>
		{
			clk			=> "avl_clock",
			reset_n 		=> "avl_resetn",
			avl_control_a_rd	=> "control_a_rd",
			avl_control_a_wr	=> "control_a_wr",
			avl_control_bwsn	=> "control_bwsn",
			avl_control_rpsn	=> "control_rpsn",
			avl_control_wdata	=> "control_wdata",
			avl_control_wpsn	=> "control_wpsn",
			@ports			=> @ports_list,
		},
		out_port_map	=>
		{
			control_wdata 		=> "datapath_wdata",
			control_rdata		=> "control_rdata",
			training_done 		=> "training_done",
			training_incorrect 		=> "training_incorrect",
			training_pattern_not_found 		=> "training_pattern_not_found",
			@ports_pipeline			=> @ports_pipeline_list,
		},
		std_logic_vector_signals	=>	[@ports_list],
	}),
);


###############################################      Datapath Module ##############################################################################
$module->add_contents
(
	e_comment->new
	({
		comment => "------------------------------------------------------------\n
			   Instance of the DataPath module\n
			   ------------------------------------------------------------\n"
	}),
	e_blind_instance->new
	({
		  name 		=> "auk_${mem_type}_datapath",
		  module 	=> $gWRAPPER_NAME."_auk_${mem_type}_datapath",
		in_port_map 	=>
		{
			clk			=> "avl_clock",
			write_clk 		=> "avl_clock_wr",
			reset_n 		=> "avl_resetn",
			control_wdata 		=> "datapath_wdata",
			@ports_pipeline			=> @ports_pipeline_list,
			@in_param		=> @in_parameter_list,

		},
		out_port_map	=>
		{
			@ports			=> @ports_list,
			@addr_wrapper		=> @addr_wrapper_list,
			@out_ports		=> @out_ports_list,
		},
		inout_port_map	=>
		{
			@stratixii_inout	=> @stratixii_inout_list,
		},
		std_logic_vector_signals	=>
		[
			@stratixii_inout_list,
			@ports_list,
			@clock_ports_list,
		],
	}),
);
##################################################################################################################################################################
$project->output();
}

1;
#You're done.
