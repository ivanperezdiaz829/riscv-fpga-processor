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
#  File         : $RCSfile: write_qdrii_write_group.pm,v $
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
use e_lpm_altddio_out;

sub write_qdrii_write_group
{

my $mem_type = $gMEM_TYPE;

my $top = e_module->new({name => $gWRAPPER_NAME . "_auk_${mem_type}_write_group"});
my $project = e_project->new({top => $top, language => $language,__system_directory =>$output_directory});
my $module = $project->top();
$module->vhdl_libraries()->{altera_mf} = all;
$module->vhdl_libraries()->{$gFAMILYlc} = all;

#####   Parameters declaration  ######
my $header_title = "Write Datapath for the Altera QDRII SDRAM Controller";
my $header_filename = $gWRAPPER_NAME . "_ddr_${mem_type}_write_group" . $file_ext;
my $header_revision = "V" . $gWIZARD_VERSION;
my $header_abstract = "This file contains the datapath for the QDRII SDRAM Controller.";

my $memory_data_width = $gMEMORY_DATA_WIDTH;
my $mem_dq_per_dqs = $gMEM_DQ_PER_DQS;
my $local_data_bits = $gLOCAL_DATA_BITS;
my $memory_address_width = $gMEMORY_ADDRESS_WIDTH;
my $qdrii_pin_prefix = $gQDRII_PIN_PREFIX;
######################################################################################################################################################################
	$module->comment
	(
		"------------------------------------------------------------------------------\n
		 Title        : $header_title\n Project      : QDRII SDRAM Controller\n\n\n File         : $header_filename\n\n Revision     : $header_revision\n\n
		 Abstract:\n $header_abstract\n\n
		------------------------------------------------------------------------------\n
		 Parameters:\n\n
		 Device Family			    : $gFAMILY\n
		 Memory data width 		    : $mem_dq_per_dqs\n
		 Memory address width		    : $memory_address_width\n
		 ------------------------------------------------------------------------------\n"
	);
######################################################################################################################################################################
	$module->add_contents
	(
	#####	Ports declaration#	######
		e_port->new({name => "clk",direction => "input"}),
		e_port->new({name => "reset_n",direction => "input"}),

		e_port->new({name => "${qdrii_pin_prefix}d",direction => "output",width =>$mem_dq_per_dqs}),

		e_port->new({name => "control_wdata" ,direction => "input" , width => $mem_dq_per_dqs * 2}),
	);

#########################################################################################################################################################
	$module->add_contents
	(
	#####   signal generation #####
		e_signal->new({name => "reset", width => 1, export => 0, never_export => 1}),

		e_assign->new(["reset" => "~reset_n"]),
	);
	my $std_logic1 = "1'b1";
	if($language eq "vhdl"){
		$module->add_contents
		(
			e_signal->new({name => "ONE", width => 1, export => 0, never_export => 1}),
			e_assign->new(["ONE" => "1"]),
		);
		$std_logic1 = "ONE";
	}
###############################################################################################################################################################
	$module->add_contents
	(
		e_comment->new({comment		=>
			"-----------------------------------------------------------------------------\n
			 Write `d` pins logic\n
 			 -----------------------------------------------------------------------------\n"}),
		e_lpm_altddio_out->new
		({
			name 		=> "d_pins",
			module 		=> "altddio_out",
			port_map 	=>
			{
				aclr        => "reset",
				datain_h    => "control_wdata[".(($mem_dq_per_dqs * 2)-1).":".$mem_dq_per_dqs."]",
				datain_l    => "control_wdata[".($mem_dq_per_dqs - 1).":0]",
				oe          => "$std_logic1",
				outclock    => "clk",
				outclocken  => "$std_logic1",

				dataout     => "${qdrii_pin_prefix}d",
			},
			parameter_map	=>
			{
				width                   => $mem_dq_per_dqs,
				intended_device_family  => '"'.$gFAMILY.'"',
				oe_reg                  => '"UNUSED"',
				extend_oe_disable       => '"UNUSED"',
				lpm_type                => '"altddio_out"',
			},
		}),
	);
##################################################################################################################################################################
$project->output();
}
1;
#You're done.
