### NOT USED ANYMORE

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
#  File         : $RCSfile: write_qdrii_addr_cmd_out_reg.pm,v $
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
use e_lpm_altddio_out;


sub write_qdrii_addr_cmd_out_reg
{

my $mem_type = $gMEM_TYPE;
my $top = e_module->new({name => $gWRAPPER_NAME."_auk_${mem_type}_addr_cmd_reg"});#, output_file => 'd:/OFadeyi/DATA_PATH/temp_gen/'{});
my $project = e_project->new({top => $top, language => $language,__system_directory =>$output_directory , timescale => "1ps / 1ps"});#'temp_gen'{});
my $module = $project->top();
$module->vhdl_libraries()->{altera_mf} = all;
$module->vhdl_libraries()->{$gFAMILYlc} = all;



my $header_title = "QDRII Controller Address and Command Output Register Module";
my $header_filename = $gWRAPPER_NAME . "_auk_${mem_type}_addr_cmd_reg" . $file_ext;
my $header_revision = "V" . $gWIZARD_VERSION;
my $header_abstract = "This file contains the output registers for the RLDRAM II Controller.";

my $burst_mode = $gMEMORY_BURST_LENGTH;
my $device_clk = "clk";
my $device_clk_edge = "1";
my $device_clk_edge_s = "positive";
my $memory_data_width = $gMEMORY_DATA_WIDTH;
my $memory_address_width = $gMEMORY_ADDRESS_WIDTH;
my $qdrii_pin_prefix = $gQDRII_PIN_PREFIX;
my $is_busrt4_narrow = $gIS_BURST4_NARROW;
my $mem_dq_per_dqs = $gMEM_DQ_PER_DQS;
######################################################################################################################################################################
my $bwsn_width;
my $avl_data_width_multiply = $gAVL_DATA_WIDTH_MULTIPLY;
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
######################################################################################################################################################################
	$module->comment
	(
		"------------------------------------------------------------------------------\n
		 Title        : $header_title\n
		 Project      : QDRII Controller\n\n
		 File         : $header_filename\n\n
		 Revision     : $header_revision\n\n
		 Abstract:\n$header_abstract\n\n
		------------------------------------------------------------------------------\n
		 Parameters:\n\n
		 Address and Command Clock          : $device_clk\n
		 Address & Command Clocking Edge    : $device_clk_edge_s\n
		 Memory data width 		    : $memory_data_width\n
		 Memory address width		    : $memory_address_width\n
		------------------------------------------------------------------------------"
	);
######################################################################################################################################################################
	$module->add_contents
	(
	#####	Ports declaration#	######
		e_port->new({name => "$device_clk",direction => "input"}),
		e_port->new({name => "reset_n",direction => "input"}),
		#e_port->new({name => "addr_cmd_clk",direction => "input"}),

	##Addr & Cmd Output Reg input and output signal
		e_port->new({name => "control_rpsn",direction => "input", width => 1}),
		e_port->new({name => "control_wpsn",direction => "input", width => 1}),
		e_port->new({name => "control_bwsn",direction => "input", width => $bwsn_width * 2}),
		e_port->new({name => "control_addr_wr",direction => "input", width => $memory_address_width ,declare_one_bit_as_std_logic_vector => 0}),
		e_port->new({name => "control_addr_rd",direction => "input", width => $memory_address_width ,declare_one_bit_as_std_logic_vector => 0}),

		e_port->new({name => "${qdrii_pin_prefix}rpsn",direction => "output", width => 1}),
		e_port->new({name => "${qdrii_pin_prefix}wpsn",direction => "output", width => 1}),
		e_port->new({name => "${qdrii_pin_prefix}bwsn",direction => "output", width => $bwsn_width}),
		e_port->new({name => "${qdrii_pin_prefix}a",direction => "output", width => $memory_address_width,declare_one_bit_as_std_logic_vector => 0}),
	##Internal signal
	);
######################################################################################################################################################################
##
######################################################################################################################################################################
#########################################################################################################################################################
	$module->add_contents
	(
	#####   signal generation #####
		#e_signal->new({name => "ONE", width => 1, export => 0, never_export => 1}),
		e_signal->new({name => "reset", width => 1, export => 0, never_export => 1}),

		#e_assign->new(["ONE" => "1"]),
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

	$module->add_contents
	(
		e_lpm_altddio_out->new
		({
			name 		=> "wpsn_pin",
			module 		=> "altddio_out",
			port_map 	=>
			{
				aset        => "reset",
				datain_h    => "control_wpsn",
				datain_l    => "control_wpsn",
				oe          => $std_logic1,
				outclock    => "clk",
				outclocken  => $std_logic1,
				dataout     => "${qdrii_pin_prefix}wpsn",
			},
			parameter_map	=>
			{
				width                   => 1,
				intended_device_family  => '"'.$gFAMILY.'"',
				oe_reg                  => '"UNUSED"',
				extend_oe_disable       => '"UNUSED"',
				lpm_type                => '"altddio_out"',
			},
		}),
		e_lpm_altddio_out->new
		({
			name 		=> "rpsn_pin",
			module 		=> "altddio_out",
			port_map 	=>
			{
				aset        => "reset",
				datain_h    => "control_rpsn",
				datain_l    => "control_rpsn",
				oe          => $std_logic1,
				outclock    => "clk",
				outclocken  => $std_logic1,
				dataout     => "${qdrii_pin_prefix}rpsn",
			},
			parameter_map	=>
			{
				width                   => 1,
				intended_device_family  => '"'.$gFAMILY.'"',
				oe_reg                  => '"UNUSED"',
				extend_oe_disable       => '"UNUSED"',
				lpm_type                => '"altddio_out"',
			},
		}),

	);
	if ($burst_mode == 4)
	{
		$module->add_contents
		(
		    e_signal->new({name => "temp_${qdrii_pin_prefix}a",width => $memory_address_width,export => 0,never_export => 1}),
			e_process->new
			({
    			clock		=> '',
    			reset		=> '',
    			_contents	=>
    			[
					e_if->new
					({
						condition	=> "!control_wpsn",
						then		=>
						[
							e_assign->new({lhs => "temp_${qdrii_pin_prefix}a", rhs => "control_addr_wr" }),
						],
						else		=>
						[
							e_assign->new({lhs => "temp_${qdrii_pin_prefix}a", rhs => "control_addr_rd" }),
						],
					}),
				],
			}),

    		e_lpm_altddio_out->new
    		({
    			name 		=> "address_pin",
    			module 		=> "altddio_out",
    			port_map 	=>
    			{
    				aset        => "reset",
    				datain_h    => "temp_${qdrii_pin_prefix}a",
    				datain_l    => "temp_${qdrii_pin_prefix}a",
    				oe          => $std_logic1,
    				outclock    => "clk",
    				outclocken  => $std_logic1,
    				dataout     => "${qdrii_pin_prefix}a",
    			},
    			parameter_map	=>
    			{
    				width                   => $memory_address_width,
    				intended_device_family  => '"'.$gFAMILY.'"',
    				oe_reg                  => '"UNUSED"',
    				extend_oe_disable       => '"UNUSED"',
    				lpm_type                => '"altddio_out"',
    			},
    		}),



		);
	}elsif ($burst_mode == 2)
	{
		$module->add_contents
		(
    		e_lpm_altddio_out->new
    		({
    			name 		=> "address_pin",
    			module 		=> "altddio_out",
    			port_map 	=>
    			{
    				aset        => "reset",
    				datain_h    => "control_addr_rd",
    				datain_l    => "control_addr_wr",
    				oe          => $std_logic1,
    				outclock    => "clk",
    				outclocken  => $std_logic1,
    				dataout     => "${qdrii_pin_prefix}a",
    			},
    			parameter_map	=>
    			{
    				width                   => $memory_address_width,
    				intended_device_family  => '"'.$gFAMILY.'"',
    				oe_reg                  => '"UNUSED"',
    				extend_oe_disable       => '"UNUSED"',
    				lpm_type                => '"altddio_out"',
    			},
    		}),
		);
	}
###############################################################################################################################################################
	$module->add_contents
	(
		e_comment->new({comment		=>
			"-----------------------------------------------------------------------------\n
			 Write `bswn` pins logic\n
 			 -----------------------------------------------------------------------------\n"}),
		# e_blind_instance->new
		# ({
			# name 		=> "d_pins",
			# module 		=> "altddio_out",
			# in_port_map 	=>
			# {
				# aclr        => "reset",
				# datain_h    => "control_bwsn[".(($bwsn_width * 2)-1).":".$bwsn_width."]",
				# datain_l    => "control_bwsn[".($bwsn_width - 1).":0]",
				# oe          => "ONE",
				# outclock    => "clk",
				# outclocken  => "ONE",
			# },
			# out_port_map	=>
			# {
				# dataout     => "qdrii_bwsn",
			# },
			# parameter_map	=>
			# {
				# width                   => $bwsn_width,
				# intended_device_family  => '"'.$gFAMILY.'"',
				# oe_reg                  => '"UNUSED"',
				# extend_oe_disable       => '"UNUSED"',
				# lpm_type                => '"altddio_out"',
			# },
			# std_logic_vector_signals =>
			# [
				# datain_h,
				# datain_l,
				# dataout,
			# ],
		# }),
		e_lpm_altddio_out->new
		({
			name 		=> "bswn_pins",
			module 		=> "altddio_out",
			port_map 	=>
			{
				aset        => "reset",
				datain_h    => "control_bwsn[".(($bwsn_width * 2)-1).":".$bwsn_width."]",
				datain_l    => "control_bwsn[".($bwsn_width - 1).":0]",
				oe          => $std_logic1,
				outclock    => "clk",
				outclocken  => $std_logic1,
				dataout     => "${qdrii_pin_prefix}bwsn",
			},
			parameter_map	=>
			{
				width                   => $bwsn_width,
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
