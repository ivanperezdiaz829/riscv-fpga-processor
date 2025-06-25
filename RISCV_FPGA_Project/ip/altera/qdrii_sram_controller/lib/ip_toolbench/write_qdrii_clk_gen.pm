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
#  File         : $RCSfile: write_qdrii_clk_gen.pm,v $
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

sub write_auk_qdrii_clk_gen
{
my $mem_type = $gMEM_TYPE;
my $top = e_module->new({name => $gWRAPPER_NAME."_auk_${mem_type}_clk_gen"});
my $project = e_project->new({top => $top, language => $language,__system_directory =>$output_directory , timescale => "1ps / 1ps"});#'temp_gen'});
my $module = $project->top();

#$module->vhdl_libraries()->{$gFAMILY} = all;
$module->vhdl_libraries()->{altera_mf} = all;


my $header_title = "QDRII Controller Clock Generator";
my $project_title = "QDRII Controller";
my $header_filename = $gWRAPPER_NAME."_auk_${mem_type}_clk_gen". $file_ext;
my $header_revision = "V" . $gWIZARD_VERSION;
my $header_abstract = "This file contains the memory clock generation for the QDRII Controller.";
my $verilog_dq_io_instname;# = "\\g_datapath:\$i:g_ddr_io ";
#####   Parameters declaration  ######
my $num_clock_pairs = $gNUM_OUTPUT_CLOCKS;
my $family = $gFAMILY;
my $vcc_signal = (2 ** $num_clock_pairs) - 1;
my $qdrii_pin_prefix = $gQDRII_PIN_PREFIX;
#my $clock_pos_pin_name = $gCLOCK_POS_PIN_NAME;
#my $clock_neg_pin_name = $gCLOCK_NEG_PIN_NAME;
my $clock_pos_pin_name = $qdrii_pin_prefix . "k";
my $clock_neg_pin_name = $qdrii_pin_prefix . "kn";
######################################################################################################################################################################
	$module->comment
	(
		"------------------------------------------------------------------------------\n
		 Title        : $header_title\n
		 Project      : $project_title\n\n\n
		 File         : $header_filename\n\n
		 Revision     : $header_revision\n\n
		 Abstract:\n $header_abstract\n\n
		----------------------------------------------------------------------------------\n
		 Parameters:\n
		 Number Memory Clock Pairs          : $num_clock_pairs\n
		 Positive Clock Signal Name         : $clock_pos_pin_name\n
		 Negative Clock Signal Name         : $clock_neg_pin_name\n
		 ----------------------------------------------------------------------------------\n",
	);
#####################################################################################################################################################################
	 $module->add_contents
	 (
	 #####	Ports declaration#	######
		 e_port->new({name => "clk",direction => "input"}),
		 e_port->new({name => $clock_pos_pin_name,direction => "output", width => $num_clock_pairs,declare_one_bit_as_std_logic_vector => 1}),
		 e_port->new({name => $clock_neg_pin_name,direction => "output", width => $num_clock_pairs,declare_one_bit_as_std_logic_vector => 1}),
		 e_port->new({name => "reset_n",direction => "input"}),
	);
#########################################################################################################################################################
	 $module->add_contents
	 (
	# #####   signal generation #####
		 e_signal->news #: ["signal", width, export, never_export]
		 (
#		 	 [ "vcc_signal",	$num_clock_pairs,	0,	1],
#			 [ "gnd_signal",	$num_clock_pairs,	0,	1],
#		 	 [ "clk_out",	$num_clock_pairs,	0,	1],
#			 [ "clk_out_n",	$num_clock_pairs,	0,	1],
		 ),
		 e_signal->new({name => "clk_out" , width => $num_clock_pairs, export => 0, never_export => 1, declare_one_bit_as_std_logic_vector => 1}),
		 e_signal->new({name => "clk_out_n" , width => $num_clock_pairs, export => 0, never_export => 1, declare_one_bit_as_std_logic_vector => 1}),
		 e_signal->new({name => "vcc_signal" , width => $num_clock_pairs, export => 0, never_export => 1}),
		 e_signal->new({name => "gnd_signal" , width => $num_clock_pairs, export => 0, never_export => 1}),
		 e_signal->new({name => "clk_n" , width => 1, export => 0, never_export => 1}),
	 );
######################################################################################################################################################################
    $module->add_contents(e_assign->new({lhs => "clk_n", rhs => "~clk"}),);

	$module->add_contents
	(

		e_assign->new({lhs => "vcc_signal", rhs => "{".$num_clock_pairs."{1'b1}}"}),
		e_assign->new({lhs => "gnd_signal", rhs => "0"}),

		e_comment->new({comment => "Instantiate DDR IOs for driving the QDR II clock off-chip"}),
		# e_blind_instance->new
		# ({
			# name 		=> "ddr_clk_out_p",
			# module 		=> "altddio_out",
			# comment 	=> " ",
			# in_port_map 	=>
			# {
				# aset 		=> "gnd_signal[0:0]",
				# datain_h 	=> "vcc_signal[]",
				# datain_l	=> "gnd_signal[]",
				# ## aset		=> "gnd_signal[0:0]",
				# outclock 	=> "clk",
			# },
			# out_port_map	=>
			# {
				# dataout  => "clk_out[]",
			# },
			# parameter_map	=>
			# {
			    # width => $num_clock_pairs,
			    # power_up_high => '"OFF"',
			    # intended_device_family => '"'.$family.'"',
			    # oe_reg => '"UNUSED"',
			    # extend_oe_disable => '"UNUSED"',
			    # lpm_type => '"altddio_out"',
			# },
			# std_logic_vector_signals =>
			# [
				# datain_h,
				# datain_l,
				# dataout,
			# ],
			# _port_default_values =>
			# {
				# datain_l,	=> $num_clock_pairs,
				# datain_h,	=> $num_clock_pairs,
				# dataout,	=> $num_clock_pairs,
			# },
#
		# }),
		#
		# e_blind_instance->new
		# ({
			# name 		=> "ddr_clk_out_n",
			# module 		=> "altddio_out",
			# comment 	=> " ",
			# in_port_map 	=>
			# {
				# aset 		=> "gnd_signal[0:0]",
				# datain_h 	=> "gnd_signal[]",
				# datain_l	=> "vcc_signal[]",
				# ## aset		=> "gnd_signal[0:0]",
				# outclock 	=> "clk",
			# },
			# out_port_map	=>
			# {
				# dataout  => "clk_out_n[]",
			# },
			# parameter_map	=>
			# {
			    # width => $num_clock_pairs,
			    # power_up_high => '"OFF"',
			    # intended_device_family => '"'.$family.'"',
			    # oe_reg => '"UNUSED"',
			    # extend_oe_disable => '"UNUSED"',
			    # lpm_type => '"altddio_out"',
			# },
			# std_logic_vector_signals =>
			# [
				# datain_h,
				# datain_l,
				# dataout,
			# ],
			# _port_default_values =>
			# {
				# datain_l,	=> $num_clock_pairs,
				# datain_h,	=> $num_clock_pairs,
				# dataout,	=> $num_clock_pairs,
			# },
		# }),
		e_lpm_altddio_out->new
		({
			name 		=> "ddr_clk_out_p",
			module 		=> "altddio_out",
			port_map 	=>
			{
				aset 		=> "gnd_signal[0:0]",
				datain_h 	=> "gnd_signal",
				datain_l	=> "vcc_signal",
				outclock 	=> "clk_n",
				dataout  	=> "clk_out[".($num_clock_pairs - 1).":0]",
			},
			parameter_map	=>
			{
			    width => $num_clock_pairs,
			    power_up_high => '"OFF"',
			    intended_device_family => '"'.$family.'"',
			    oe_reg => '"UNUSED"',
			    extend_oe_disable => '"UNUSED"',
			    lpm_type => '"altddio_out"',
			},
		}),

		e_lpm_altddio_out->new
		({
			name 		=> "ddr_clk_out_n",
			module 		=> "altddio_out",
			port_map 	=>
			{
				aset 		=> "gnd_signal[0:0]",
				datain_h 	=> "gnd_signal",
				datain_l	=> "vcc_signal",
				outclock 	=> "clk",

				dataout  	=> "clk_out_n[".($num_clock_pairs - 1).":0]",
			},
			parameter_map	=>
			{
			    width => $num_clock_pairs,
			    power_up_high => '"OFF"',
			    intended_device_family => '"'.$family.'"',
			    oe_reg => '"UNUSED"',
			    extend_oe_disable => '"UNUSED"',
			    lpm_type => '"altddio_out"',
			},
		}),
		e_assign->new({lhs => $clock_pos_pin_name, rhs => "clk_out"}),
		e_assign->new({lhs => $clock_neg_pin_name, rhs => "clk_out_n"}),
	);
######################################################################################################################################################################
$project->output();
}
1;
#You're done..
