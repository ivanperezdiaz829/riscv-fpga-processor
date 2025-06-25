# NOT USED ANYMORE



#sopc_builder free code
use europa_all; 
use europa_utils;


sub write_qdrii_capture_group
{
my $mem_type = "qdrii_sram";

my $top = e_module->new({name => $gWRAPPER_NAME."_auk_${mem_type}_capture_group"});#, output_file => 'd:/OFadeyi/DATA_PATH/temp_gen/'{});
my $project = e_project->new({top => $top, language => $language,__system_directory =>$output_directory, timescale => "1ps / 1ps"});#'temp_gen'{});
my $module = $project->top();



my $header_title = "Resynch Registers for the Altera QDRII SDRAM Controller";
my $header_filename = $gWRAPPER_NAME . "_auk_${mem_type}_capture_group" . $file_ext;
my $header_revision = "V" . $gWIZARD_VERSION;
my $header_abstract = "This file contains the resynchronization registers for the QDRII SDRAM Controller.";

my $family = $gFAMILY;
my $mem_dq_per_dqs = $gMEM_DQ_PER_DQS;
my $memory_data_width = $gMEMORY_DATA_WIDTH;
######################################################################################################################################################################
	$module->comment
	(
		"------------------------------------------------------------------------------\n
		 This confidential and proprietary software may be used only as authorized by\na licensing agreement from Altera Corporation.\n\n
		 (C) COPYRIGHT 2004 ALTERA CORPORATION\nALL RIGHTS RESERVED\n\nThe entire notice above must be reproduced on all authorized copies and any\n
		 such reproduction must be pursuant to a licensing agreement from Altera.\n\n
		 Title        : $header_title\nProject      : DDR SDRAM Controller\n\n
		 File         : $header_filename\n\nRevision     : $header_revision\n\nAbstract:\n$header_abstract\n\n		
		------------------------------------------------------------------------------\nParameters:\n\n		
		 Device Family                      : $family\n
		------------------------------------------------------------------------------"
	);
######################################################################################################################################################################
	$module->add_contents
	(
	#####	Ports declaration#	######
		e_port->new({name => "clk", direction => "input",}),
		e_port->new({name => "clk_n", direction => "input",}),
		e_port->new({name => "reset_n", direction => "input"}),
		e_port->new({name => "qdrii_q", direction => "input"}),

		e_port->new({name => "captured_rdata_l" , direction => "output" , width => $memory_data_width , declare_one_bit_as_std_logic_vector => 0}),
		e_port->new({name => "captured_rdata_h" , direction => "output", width => $memory_data_width, declare_one_bit_as_std_logic_vector => 0}),
	##Internal signal
	);
######################################################################################################################################################################
##
$module->add_contents
(
	e_process->new
	({
		clock  		=> "clk",
		reset   	=> "reset_n",
		_asynchronous_contents 	=> 
		[
			e_assign->new({lhs => "captured_rdata_l", rhs => 0 }),
		],
		_contents	=> 
		[
			e_assign->new({lhs => "captured_rdata_l", rhs => "qdrii_q" }),
		],
	})
	e_process->new
	({
		clock  		=> "clk_n",
		reset   	=> "reset_n",
		_asynchronous_contents 	=> 
		[
			e_assign->new({lhs => "tmp_captured_rdata_h", rhs => 0 }),
		],
		_contents	=> 
		[
			e_assign->new({lhs => "tmp_captured_rdata_h", rhs => "qdrii_q" }),
		],
	})
	e_process->new
	({
		clock  		=> "clk",
		reset   	=> "reset_n",
		_asynchronous_contents 	=> 
		[
			e_assign->new({lhs => "captured_rdata_h", rhs => 0 }),
		],
		_contents	=> 
		[
			e_assign->new({lhs => "captured_rdata_h", rhs => "tmp_captured_rdata_h" }),
		],
	})
);
######################################################################################################################################################################
$project->output();
}

1;
#You're done.
