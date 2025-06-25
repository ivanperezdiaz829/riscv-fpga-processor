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
#  File         : $RCSfile: write_qdrii_example_instance.pm,v $
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


sub write_qdrii_example_instance
{
my $mem_type = $gMEM_TYPE;

my $top = e_module->new({name => $gTOPLEVEL_NAME});#, output_file => 'd:/OFadeyi/DATA_PATH/temp_gen/'});
my $project = e_project->new({top => $top, language => $language,__system_directory =>$output_directory,timescale => "1ps / 1ps"});#'temp_gen'});
my $module = $project->top();
$module->add_attribute(ALTERA_ATTRIBUTE => "SUPPRESS_DA_RULE_INTERNAL=R102;SUPPRESS_DA_RULE_INTERNAL=C104");
$module->vhdl_libraries()->{altera_mf} = all;
$module->vhdl_libraries()->{$gFAMILYlc} = all;


my $header_title = "Datapath for the Altera QDRII SDRAM Controller";
my $project_title = "QDRII SDRAM Controller";
my $header_filename = $gWRAPPER_NAME . "_auk_${mem_type}_datapath" . $file_ext;
my $header_revision = "V" . $gWIZARD_VERSION;
my $header_abstract = "This file contains the datapath for the QDRII SDRAM Controller";
my $family = $gFAMILY;
my $mem_dq_per_dqs = $gMEM_DQ_PER_DQS;
my $local_data_bits = $gLOCAL_DATA_BITS;
my $memory_data_width = $gMEMORY_DATA_WIDTH;
my $memory_address_width = $gMEMORY_ADDRESS_WIDTH;
my $stratixii_dll_delay_buffer_mode = $gSTRATIXII_DLL_DELAY_BUFFER_MODE;
my $clock_period_in_ps = int(((10**12) / ($gCLOCK_FREQ_IN_MHZ*(10**6))));#$gCLOCK_PERIOD_IN_PS;
my $stratixii_dll_delay_chain_length = $gSTRATIXII_DLL_DELAY_CHAIN_LENGTH;
my $avl_data_width_multiply = $gAVL_DATA_WIDTH_MULTIPLY;
my $bwsn_width;
my $use_dqs_for_read = $gUSE_DQS_FOR_READ;
my $is_busrt4_narrow = $gIS_BURST4_NARROW;
my $qdrii_pin_prefix = $gQDRII_PIN_PREFIX;
my $num_clock_pairs = $gNUM_OUTPUT_CLOCKS;
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
my $family = $gFAMILY;

my %in_param;
my @in_param;
my %out_param;
my @out_param;
my @in_pll_param;
my %in_pll_param;
my @out_pll_param;
my %out_pll_param;
my $num_chips_wide = $gNUM_CHIPS_WIDE;
my $num_chips_deep = $gNUM_CHIPS_DEEP;
my @addr_wrapper;
my %addr_wrapper;
my @addr_wrapper_list;
my $deep;
my $actual_number_clocks;
if($num_chips_deep > 1){
	$deep = 1;
}else{
	$deep = 0;
}
my @data_wrapper;
my %data_wrapper;
my @data_wrapper_list;
my $regression_test = $gREGRESSION_TEST;
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
		 QDRII Interface Data Width	     : $mem_dq_per_dqs\n
		 QDRII Interface Address Width	     : $memory_address_width\n
		 ----------------------------------------------------------------------------------\n",
	);
######################################################################################################################################################################
	$module->add_contents
	(
		#####	Ports declaration#	######
		e_port->new({name => "clk_in",direction => "input"}),
		e_port->new({name => "reset_n",direction => "input"}),
#			e_port->new({name => $clock_pos_pin_name,direction => "output", width => $num_clock_pairs,declare_one_bit_as_std_logic_vector => 1}),
#			e_port->new({name => $clock_neg_pin_name,direction => "output", width => $num_clock_pairs,declare_one_bit_as_std_logic_vector => 1}),
		e_port->new({name => "test_complete",direction => "output"}),
		e_port->new({name => "fail_permanent",direction => "output",width => 1}),
		e_port->new({name => "fail",direction => "output"}),
		e_port->new({name => "training_done",direction => "output"}),
		e_port->new({name => "training_incorrect",direction => "output"}),
		e_port->new({name => "training_pattern_not_found",direction => "output"}),

		 #####   signal generation #####
          	e_signal->news #: ["signal", width, export, never_export]
		(
	        ["clock_source",1,	0,	1],
			["system_reset_n",1,	0,	1],

			["Avl_wr_be",$bwsn_width * $avl_data_width_multiply * $num_chips_wide,	0,	1],
			["Avl_write",1,	0,	1],
			["Avl_wr_cs",1,	0,	1],
			["Avl_wr_addr",$memory_address_width + $is_busrt4_narrow + $deep,	0,	1],
			["Avl_wr_data",$local_data_bits,	0,	1],

			["Avl_rd_data",$local_data_bits,	0,	1],
			["Avl_rd_addr",$memory_address_width + $is_busrt4_narrow + $deep,	0,	1],
			["Avl_rd_be",$bwsn_width * $avl_data_width_multiply * $num_chips_wide,	0,	1],
			["Avl_read",1,	0,	1],
			["Avl_rd_cs",1,	0,	1],
		),
	);
	if ($ddio_memory_clocks eq "true") {
		$module->add_contents
		(
			#####   Internal signal    ######
			e_port->new({name => $clock_pos_pin_name,direction => "output", width => $num_clock_pairs,declare_one_bit_as_std_logic_vector => 1}),
			e_port->new({name => $clock_neg_pin_name,direction => "output", width => $num_clock_pairs,declare_one_bit_as_std_logic_vector => 1}),
		);
		$out_param{"$clock_pos_pin_name"} = "${clock_pos_pin_name}"."["."(${num_clock_pairs} -1):0"."]";
		$out_param{"$clock_neg_pin_name"} = "${clock_neg_pin_name}"."["."(${num_clock_pairs} -1):0"."]";

	}	else {

		# here we need to add only the positive port and only up to 3 ports.
		# if more than 3, reduce to 3.
			if($num_clock_pairs >= 3) {	
				$actual_number_clocks = 3;
			} else {
				$actual_number_clocks = $num_clock_pairs;
			}
		$module->add_contents
		(
			e_port->new({name => $clock_pos_pin_name,direction => "output", width => $actual_number_clocks,declare_one_bit_as_std_logic_vector => 1}),
		);
	}
	if(($use_dqs_for_read eq "true") and ($family eq "Stratix II")){
		$module->add_contents
		(
			#####   Internal signal    ######
			e_signal->new({name => "dll_delay_ctrl", width => 6, export => 0, never_export => 1}),
		);
		$in_param{'dll_delay_ctrl'} = "dll_delay_ctrl";
	}
	if(($family eq "Stratix II") or ($family eq "Cyclone II") or ($family eq "Stratix"))
	{
		$in_pll_param{'inclk0'} = "clk_in";
		$out_pll_param{'c0'} = "sys_clk";
		$out_pll_param{'c1'} = "write_clk";
		# here we need to add the direct PLL output when used
		if ($ddio_memory_clocks eq "false") {
		
			if($num_clock_pairs >= 1) {	
			
					$out_pll_param{'c2'} = "memory_clk_0";
			} 
			if($num_clock_pairs >= 2) {	
			
					$out_pll_param{'c3'} = "memory_clk_1";
			} 
			if($num_clock_pairs >= 3) {	
			
					$out_pll_param{'c4'} = "memory_clk_2";
			}
		}
	}
	my $dir = "inout";
	if((($use_dqs_for_read eq "false") and ($family eq "Stratix II")) or ($family eq "Stratix"))
	{
		$in_param{'non_dqs_capture_clock'} = "non_dqs_capture_clock";
		@in_param = %in_param;
		$dir = "input";
	}
	if($num_chips_wide > 1){
		for(my $k = 0; $k < ($num_chips_wide); $k++)
		{
			$module->add_contents
			(
				e_port->new({name => "${qdrii_pin_prefix}cq_$k",direction => "$dir", declare_one_bit_as_std_logic_vector => 1}),
				e_port->new({name => "${qdrii_pin_prefix}cqn_$k",direction => "$dir", declare_one_bit_as_std_logic_vector => 1}),
			);
			if($use_dqs_for_read ne "false")
			{
				$inout_param{"${qdrii_pin_prefix}cq_$k"} = "${qdrii_pin_prefix}cq_$k"."[0:0]";
				$inout_param{"${qdrii_pin_prefix}cqn_$k"} = "${qdrii_pin_prefix}cqn_$k"."[0:0]";
			}
		}
	}else{
		$module->add_contents
		(
			e_port->new({name => "${qdrii_pin_prefix}cq",direction => "$dir", declare_one_bit_as_std_logic_vector => 1}),
			e_port->new({name => "${qdrii_pin_prefix}cqn",direction => "$dir", declare_one_bit_as_std_logic_vector => 1}),
		);
		if($use_dqs_for_read ne "false")
		{
			$inout_param{"${qdrii_pin_prefix}cq"} = "${qdrii_pin_prefix}cq"."[0:0]";
			$inout_param{"${qdrii_pin_prefix}cqn"} = "${qdrii_pin_prefix}cqn"."[0:0]";
		}
	}
	if($num_chips_wide > 1){
		for(my $k = 0; $k < ($num_chips_wide); $k++)
		{
			$module->add_contents
			(
				e_port->new({name => "${qdrii_pin_prefix}d_$k",direction => "output",width => $mem_dq_per_dqs}),
				e_port->new({name => "${qdrii_pin_prefix}q_$k",direction => "input",width => $mem_dq_per_dqs}),
			);

			$data_wrapper{"${qdrii_pin_prefix}d_$k"} = "${qdrii_pin_prefix}d_$k";
			$in_param{"${qdrii_pin_prefix}q_$k"} = "${qdrii_pin_prefix}q_$k";
		}
	}else{
		$module->add_contents
		(
			e_port->new({name => "${qdrii_pin_prefix}d",direction => "output",width => $mem_dq_per_dqs}),
			e_port->new({name => "${qdrii_pin_prefix}q",direction => "input",width => $mem_dq_per_dqs}),
		);

		$data_wrapper{"${qdrii_pin_prefix}d"} = "${qdrii_pin_prefix}d";
		$in_param{"${qdrii_pin_prefix}q"} = "${qdrii_pin_prefix}q";
	}
	if(($num_chips_wide > 1) || ($num_chips_deep > 1)){
		for($i = 0; $i < ($num_chips_deep ); $i++){
			for($j = 0; $j < ($num_chips_wide ); $j++){
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
	@in_param = %in_param;
	@in_pll_param = %in_pll_param;
	@out_pll_param = %out_pll_param;
	@inout_param = %inout_param;
	@addr_wrapper = %addr_wrapper;
	@data_wrapper = %data_wrapper;
	my @in_parameter_list;
	foreach my $parameter (@in_param) {push (@in_parameter_list, $parameter);}
	@out_param = %out_param;
	my @out_parameter_list;
	foreach my $parameter (@out_param) {push (@out_parameter_list, $parameter);}
	
	my @inout_parameter_list;
	foreach my $parameter (@inout_param) {push (@inout_parameter_list, $parameter);}
	my @in_pll_parameter_list;
	foreach my $parameter (@in_pll_param) {push (@in_pll_parameter_list, $parameter);}
	my @out_pll_parameter_list;
	foreach my $parameter (@out_pll_param) {push (@out_pll_parameter_list, $parameter);}
	foreach my $data (@data_wrapper) {push (@data_wrapper_list, $data);}
	foreach my $addr (@addr_wrapper) {push (@addr_wrapper_list, $addr);}
##################################################################################################################################################################
	$module->add_contents
	(
		e_comment->new
		({
			comment => "-----------------------------------------------------------------\n
				   Instance of the MegaWizard Wrapper for the QDRII SDRAM Controller\n
				   ------------------------------------------------------------------\n"
		}),
		e_blind_instance->new
		({
			name 		=> "auk_qdrii_mw_wrapper",
			module 		=> $gWRAPPER_NAME,#."_auk_${mem_type}_mw_wrapper",
			in_port_map 	=>
			{
				avl_clock		=> "sys_clk",
				avl_clock_wr		=> "write_clk",
				avl_resetn		=> "soft_reset_n",

				avl_addr_wr		=> "Avl_wr_addr",
				avl_data_wr		=> "Avl_wr_data",
				avl_write		=> "Avl_write",
				avl_chipselect_wr	=> "Avl_write",
				avl_byteen_wr		=> "Avl_wr_be",


				avl_addr_rd		=> "Avl_rd_addr",
				avl_chipselect_rd	=> "Avl_read",
				avl_read		=> "Avl_read",
				avl_byteen_rd		=> "Avl_rd_be",

				@in_param		=> @in_parameter_list,
			},
			out_port_map	=>
			{
				avl_wait_request_wr	=> "Avl_wr_wait",

				avl_wait_request_rd 	=> "Avl_rd_wait",
				avl_data_read_valid	=> "Avl_rd_datavalid",
				avl_data_rd		=> "Avl_rd_data",
				training_done		=> "training_done",
				training_incorrect		=> "training_incorrect",
				training_pattern_not_found		=> "training_pattern_not_found",

				@addr_wrapper		=> @addr_wrapper_list,
				@data_wrapper		=> @data_wrapper_list,
				@out_param	=> @out_param_list,
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
################################################ Example Driver #################################################################################################
	if ($regression_test ne "true")
	{
		$module->add_contents
		(
			e_comment->new
			({
				comment => "------------------------------------------------------------\n
					   Instance of the Example Driver self-test,
					   synthesisable code to exercise the QDRII SDRAM Controller\n
					   ------------------------------------------------------------\n"
			}),
			e_blind_instance->new
			({
				name 		=> "example_driver",
				module 		=> $gWRAPPER_NAME."_auk_${mem_type}_example_driver",
				in_port_map 	=>
				{
					clk	 		=> "sys_clk",
					reset_n	 		=> "soft_reset_n",

					avl_read_data_valid	=> "Avl_rd_datavalid",
					avl_read_data		=> "Avl_rd_data",
					avl_read_wait		=> "Avl_rd_wait",
					avl_write_wait		=> "Avl_wr_wait",
				},
				out_port_map	=>
				{
					avl_read_addr 		=> "Avl_rd_addr",
					avl_read 		=> "Avl_read",
					avl_write_addr 		=> "Avl_wr_addr",
					avl_wr_be 		=> "Avl_wr_be",
					avl_write_data 		=> "Avl_wr_data",
					avl_write 		=> "Avl_write",

					fail_permanent		=> "fail_permanent",
					fail			=> "fail",
					test_complete		=> "test_complete",
				},
			}),
		);
	}else{
		$module->add_contents
		(
			e_comment->new
			({
				comment => "------------------------------------------------------------\n
					   Instance of the Example Driver self-test,
					   synthesisable code to exercise the QDRII SDRAM Controller\n
					   ------------------------------------------------------------\n"
			}),
			e_blind_instance->new
			({
				name 		=> "example_driver",
				module 		=> $gWRAPPER_NAME."_auk_${mem_type}_example_driver",
				in_port_map 	=>
				{
					clk	 		=> "sys_clk",
					reset_n	 		=> "soft_reset_n",

					Avl_rd_datavalid	=> "Avl_rd_datavalid",
					Avl_rd_data		=> "Avl_rd_data",
					Avl_rd_wait		=> "Avl_rd_wait",
					Avl_wr_wait		=> "Avl_wr_wait",
				},
				out_port_map	=>
				{
					Avl_rd_addr 		=> "Avl_rd_addr",
					Avl_rd_be 		=> "Avl_rd_be",
					Avl_rd_cs 		=> "Avl_rd_cs",
					Avl_read 		=> "Avl_read",
					Avl_wr_addr 		=> "Avl_wr_addr",
					Avl_wr_be 		=> "Avl_wr_be",
					Avl_wr_cs 		=> "Avl_wr_cs",
					Avl_wr_data 		=> "Avl_wr_data",
					Avl_write 		=> "Avl_write",

					fail_permanent		=> "fail_permanent",
					fail			=> "fail",
					test_complete		=> "test_complete",
				},
			}),
		);
	}

##################################################### Reset #################################################################################################################

# the reset in is reset_n
# the reset scheme will be the folowing:
# reset_n goes to PLL
# Once locked, and the reset and PLL lock signal, register twice and feed to the system
# this reset signal is edge detect (in order to monitor loss of lock) and fed back to the reset of the PLL

		$module->add_contents
		(
			#####   Internal signal    ######
			e_signal->new({name => "pll_locked", width => 1, export => 0, never_export => 1}),
			#e_signal->new({name => "reset_n_and_pll_locked", width => 1, export => 0, never_export => 1}),
			e_signal->new({name => "soft_reset_n", width => 1, export => 0, never_export => 1}),
			e_signal->new({name => "soft_reset_meta1_n", width => 1, export => 0, never_export => 1}),
			e_signal->new({name => "soft_reset_reg_n", width => 1, export => 0, never_export => 1}),
			e_signal->new({name => "soft_reset_reg2_n", width => 1, export => 0, never_export => 1}),
			e_signal->new({name => "pll_reset", width => 1, export => 0, never_export => 1}),
            e_signal->new({name => "pll_reset_cascade", width => 1, export => 0, never_export => 1}),
			
		);

	$module->add_contents
	(
    e_process->new
	    ({
				clock		=> "clk_in",
				reset		=> "reset_n",
				_asynchronous_contents	=>
				[
			  	e_assign->new(["soft_reset_reg_n", "1'b0"]),
			  	e_assign->new(["soft_reset_reg2_n", "1'b0"]),
				],
				contents	=>
				[
					e_assign->new(["soft_reset_reg_n", "soft_reset_n"]),
					e_assign->new(["soft_reset_reg2_n", "soft_reset_reg_n"]),

				],
	    }),

	);
	$module->add_contents
	(
    e_process->new
	    ({
				clock		=> "sys_clk",
				reset		=> "pll_locked",
				_asynchronous_contents	=>
				[
			  	e_assign->new(["soft_reset_meta1_n", "1'b0"]),
			  	e_assign->new(["soft_reset_n", "1'b0"]),
				],
				contents	=>
				[
					e_assign->new(["soft_reset_meta1_n", "1'b1"]),
					e_assign->new(["soft_reset_n", "soft_reset_meta1_n"]),

			
				],
	    }),

	);

		$module->add_contents
		(
      	    e_assign->new(["pll_reset", "(soft_reset_reg2_n && !soft_reset_reg_n) || !reset_n"]),
     );
		#$module->add_contents
		#(
      	   # e_assign->new(["reset_n_and_pll_locked", "reset_n && pll_locked "]),
     #);
     
     # Fix for SPR 285268, remove pll_reset and replace pll_reset_cascade from cascading non_dqs pll
    $module->add_contents
	(
        e_assign->new(["pll_reset_cascade", "!soft_reset_n"]),
    );


##################################################### PLLs #################################################################################################################

	$module->add_contents
	(
		e_comment->new
		({
			comment => "------------------------------------------------------------\n
				   Instantiate $family PLL \n
				   ------------------------------------------------------------\n"
		}),
		e_blind_instance->new
		({
			name 		=> "g_${gFAMILYlc}pll_qdrii_pll_inst",
			module 		=> "qdrii_pll_${gFAMILYlc}",
			comment 	=> " ",
			in_port_map 	=>
			{
				areset => pll_reset,
				@in_pll_param		=> @in_pll_parameter_list,
			},
			out_port_map	=>
			{
				locked => pll_locked,
				@out_pll_param		=> @out_pll_parameter_list,
			},
		}),
	);
			##########################  STRATIX_II nonDQS or STRATIX  #####################
if((($use_dqs_for_read eq "false") and ($family eq "Stratix II")) or ($family eq "Stratix"))
{
	my $suf;
	if($num_chips_wide > 1)
	{
		$suf = "_0";
	}
	$module->add_contents
	(
		e_comment->new
		({
			comment => "------------------------------------------------------------\n
				   Instantiate $family PLL \n
				   ------------------------------------------------------------\n"
		}),
		e_blind_instance->new
		({
			name 		=> "g_${gFAMILYlc}_non_dqs_pll_qdrii_pll_inst",
			module 		=> "qdrii_pll_${gFAMILYlc}_non_dqs",
			comment 	=> " ",
			in_port_map 	=>
			{
				areset => pll_reset_cascade,
				inclk0	=> "${qdrii_pin_prefix}cq".$suf."[0:0]",
			},
			out_port_map	=>
			{
				c0	=> "non_dqs_capture_clock",
			},
		}),
	);
}
# ####################### PLL output #################################
print "hello ddio_memory_clocks $ddio_memory_clocks\n";
if ($ddio_memory_clocks eq "false") {
	if($num_clock_pairs >= 1) {	
		$module->add_contents
		(
			e_assign->new({lhs => $clock_pos_pin_name."[0]", rhs => "memory_clk_0"}),
		);
	} 
	if($num_clock_pairs >= 2) {	
		$module->add_contents
		(
			e_assign->new({lhs => $clock_pos_pin_name."[1]", rhs => "memory_clk_1"}),
		);
	}
	if($num_clock_pairs >= 3) {	
		$module->add_contents
		(
			e_assign->new({lhs => $clock_pos_pin_name."[2]", rhs => "memory_clk_2"}),
		);
	}
}

########################################################  DLL  ###################################################################################
# DLL in example instance
if (($use_dqs_for_read eq "true") and ($gFAMILY eq "Stratix II")){#  & ($gENABLE_CAPTURE_CLK ne "true")) {


	$module->add_contents
	(
		e_comment->new
		({
			comment => "------------------------------------------------------------\n
				   Instantiate Stratix II DLL for Read DQS Phase shift\n
				   ------------------------------------------------------------\n"
		}),
		e_blind_instance->new
		({
			name 		=> "g_${gWRAPPER_NAME}_auk_${mem_type}_dll_inst",
			module 		=> "${gWRAPPER_NAME}_auk_${mem_type}_dll",
			comment 	=> "stratixii_dll",
			in_port_map 	=>
			{
				clk 	=> "sys_clk",
			},
			out_port_map	=>
			{
				delayctrlout => "dll_delay_ctrl",
			},
		}),
	);

	
}
##################################################################################################################################################################
$project->output();
}

1;
#You're done.
