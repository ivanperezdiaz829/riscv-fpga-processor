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
#  File         : $RCSfile: write_qdrii_cq_cqn_group.pm,v $
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
use e_lpm_stratixii_io;

sub write_qdrii_cq_cqn_group
{

my $mem_type = $gMEM_TYPE;

my $top = e_module->new({name => $gWRAPPER_NAME . "_auk_${mem_type}_cq_cqn_group"});
my $project = e_project->new({top => $top, language => $language,__system_directory =>$output_directory});
my $module = $project->top();
$module->vhdl_libraries()->{altera_mf} = all;
$module->vhdl_libraries()->{$gFAMILYlc} = all;

#####   Parameters declaration  ######
my $header_title = "Datapath for the Altera QDRII Controller";
my $header_filename = $gWRAPPER_NAME . "_ddr_${mem_type}_writegroup" . $file_ext;
my $header_revision = "V" . $gWIZARD_VERSION;
my $header_abstract = "This file contains the datapath for the DDR SDRAM Controller.";
my $dqs_group_instname;# = "\\g_datapath:\$i:g_ddr_io ";
my $q_group_instname;
my $d_group_instname;
my $family = $gFAMILY;
my $clock_period_in_ps = ((10**12) / ($gCLOCK_FREQ_IN_MHZ*(10**6)));
my $dll_input_frequency = "${clock_period_in_ps}ps";
my $stratixii_dqs_phase                = ${gSTRATIXII_DQS_PHASE_SHIFT}; # 9000/100 "90 degrees",  7200/100 "72 degrees"
my $stratixii_dll_delay_buffer_mode    = "${gSTRATIXII_DLL_DELAY_BUFFER_MODE}";
my $stratixii_dqs_out_mode             = "${gSTRATIXII_DQS_OUT_MODE}";

my $CYCLONE2_DQS_DELAY = $dll_input_frequency;
my $memory_data_width = $gMEMORY_DATA_WIDTH;
my $qdrii_pin_prefix = $gQDRII_PIN_PREFIX;
######################################################################################################################################################################
	$module->comment
	(
		"------------------------------------------------------------------------------\n
		 Title        : $header_title\n Project      : QDRII Controller\n\n\n File         : $header_filename\n\n Revision     : $header_revision\n\n
		 Abstract:\n $header_abstract\n\n
		------------------------------------------------------------------------------\n
		 Parameters:\n\n
		 Device Family			    : $gFAMILY\n
		 DLL Input Frequency		    : $dll_input_frequency\n
		 ------------------------------------------------------------------------------\n"
	);
######################################################################################################################################################################
# if( $use_dqs_for_read eq "false")
# {
# 	$module->add_contents
# 	(
		#####	Ports declaration#	######
# 		e_port->new({name => "fb_capture_clk",  width =>  1, direction => "input", declare_one_bit_as_std_logic_vector => 0}),
# 		e_port->new({name => "fedback_capture_clk",  width =>  1, direction => "input", declare_one_bit_as_std_logic_vector => 0}),
# 		e_port->new({name => "fedback_capture_clkn",  width =>  1, direction => "input", declare_one_bit_as_std_logic_vector => 0}),

# 		e_assign->new(["fedback_capture_clk" => "fb_capture_clk"]),
# 		e_assign->new(["fedback_capture_clkn"  => "~fedback_capture_clk"]),
# 	);
# }
# else
# {
if($family eq "Stratix II")
{
	$module->add_contents
	(
	#####	Ports declaration#	######
		e_port->new({name => "dll_delay_ctrl" , direction => "input", width => 6, declare_one_bit_as_std_logic_vector => 1}),
#		e_port->new({name => "clk" , direction => "input", width => 1}),
		e_parameter->add({name => "gDLL_INPUT_FREQUENCY", default => "$dll_input_frequency", vhdl_type => "string"}),
		e_parameter->add({name => "gSTRATIXII_DQS_PHASE", default => $stratixii_dqs_phase, vhdl_type => "natural"}),
		e_parameter->add({name => "gSTRATIXII_DLL_DELAY_BUFFER_MODE", default => $stratixii_dll_delay_buffer_mode, vhdl_type => "string"}),
		e_parameter->add({name => "gSTRATIXII_DQS_OUT_MODE", default => $stratixii_dqs_out_mode, vhdl_type => "string"}),
	);
}
	$module->add_contents
	(
	#####	Ports declaration#	######
		e_port->new({name => "${qdrii_pin_prefix}cq",direction => "inout", declare_one_bit_as_std_logic_vector => 1}),
		e_port->new({name => "${qdrii_pin_prefix}cqn",direction => "inout", declare_one_bit_as_std_logic_vector => 1}),

#		e_port->new({name => "reset_n",direction => "input"}),

		e_port->new({name => "local_cq",direction => "output", width => 1, declare_one_bit_as_std_logic_vector => 1}),
		e_port->new({name => "local_cqn",direction => "output", width => 1, declare_one_bit_as_std_logic_vector => 1}),

	);
	my $std_logic1 = "1'b1";
	my $std_logic0 = "1'b0";
	if($language eq "vhdl"){
		$module->add_contents
		(
			e_signal->new({name => "ONE", width => 1, export => 0, never_export => 1}),
			e_signal->new({name => "ZERO", width => 1, export => 0, never_export => 1}),
			e_assign->new(["ONE" => "1"]),
			e_assign->new(["ZERO" => "0"]),
		);
		$std_logic1 = "ONE";
		$std_logic0 = "ZERO";
	}
#########################################################################################################################################################

if($family eq "Stratix II")
{
	$module->add_contents
	(
		#e_signal->new({name => "ONE",export => 0, never_export => 1}),
		#e_assign->new(["ONE" => "1'b1"]),
		e_signal->new({name => "link",width => 1,export => 0, never_export => 1}),
		e_comment->new({comment => "\nDQS Input\n"}),
		# e_signal->new({name => "tmp_cqn",export => 0, never_export => 1, declare_one_bit_as_std_logic_vector => 1}),
		# e_assign->new(["tmp_cqn","qdrii_cqn"]),
		# e_signal->new({name => "tmp_cq",export => 0, never_export => 1, declare_one_bit_as_std_logic_vector => 1}),
		# e_assign->new(["tmp_cq","qdrii_cq"]),
		e_signal->new({name => "linkin_linkout",export => 0, never_export => 1}),
		# e_blind_instance->new
		# ({
			# name 		=> "cqn_inst",
			# module 		=> "stratixii_io",
			# comment 	=> "DQS pin",
			# in_port_map 	=>
			# {
				# areset          => "ONE",
				# delayctrlin 	=> "dll_delay_ctrl",
				# sreset          => "ONE",
				# inclk		=> "ONE",
				# linkin		=> "link",
			# },
			# out_port_map	=>
			# {
				# dqsbusout 	=> "cqn[0]",
				# regout		=> "open",
				# ddioregout	=> "open",
				# linkout 	=> "open",
			# },
			# _inout_port_map	=>
			# {
				# padio 		=> "tmp_cqn[0]",
			# },
			# _port_default_values =>
			# {
				# delayctrlin	=> "6",
			# },
			# std_logic_vector_signals =>
			# [
				# delayctrlin,
			# ],
			# parameter_map 	=>
			# {
				# bus_hold  =>'"false"',
				# ddio_mode => '"input"',#'"bidir"',
				# ddioinclk_input  =>'"negated_inclk"',
	#
				# dqs_ctrl_latches_enable => '"false"',
				# dqs_delay_buffer_mode => '"'.$stratixii_dll_delay_buffer_mode.'"',
				# dqs_edge_detect_enable => '"false"',
				# dqs_input_frequency => '"'.$dll_input_frequency.'"',
				# dqs_offsetctrl_enable => '"false"',
				# dqs_out_mode => '"'.$stratixii_dqs_out_mode.'"',
	#
				# dqs_phase_shift => $stratixii_dqs_phase,
				# extend_oe_disable => '"false"',
	#
				# gated_dqs => '"false"',#'"true"',
				# inclk_input => '"normal"',#'"dqs_bus"',
				# input_async_reset => '"preset"',
				# input_power_up => '"high"',
				# input_register_mode => '"register"',
				# input_sync_reset => '"clear"',
				# lpm_type  =>'"stratixii_io"',
				# oe_async_reset => '"none"',
				# oe_power_up => '"low"',
				# oe_register_mode => '"none"',#'"register"',
				# oe_sync_reset => '"none"',
				# open_drain_output => '"false"',
				# operation_mode => '"input"',#'"bidir"',
				# output_async_reset => '"none"',
	#
				# output_power_up => '"low"',
				# output_register_mode => '"none"',#'"register"',
				# output_sync_reset => '"none"',
				# sim_dqs_delay_increment => 36,
				# sim_dqs_intrinsic_delay => 900,
				# sim_dqs_offset_increment => 0,
				# tie_off_oe_clock_enable => '"false"',
				# tie_off_output_clock_enable => '"false"',
			# },
	#
		# }),
		# e_blind_instance->new
		# ({
			# name 		=> "cq_inst",
			# module 		=> "stratixii_io",
			# comment 	=> "DQS pin",
			# in_port_map 	=>
			# {
				# areset          => "ONE",
				# delayctrlin 	=> "dll_delay_ctrl",
				# sreset          => "ONE",
				# inclk		=> "ONE",
				# #linkin	 	=> "link",
			# },
			# out_port_map	=>
			# {
				# dqsbusout 	=> "cq[0]",
				# regout		=> "open",
				# ddioregout	=> "open",
				# linkout		=> "link"
			# },
			# _inout_port_map	=>
			# {
				# padio 		=> "tmp_cq[0]",
			# },
			# _port_default_values =>
			# {
				# delayctrlin	=> "6",
			# },
			# std_logic_vector_signals =>
			# [
				# delayctrlin,
			# ],
			# parameter_map 	=>
			# {
				# bus_hold  =>'"false"',
				# ddio_mode => '"input"',#'"bidir"',
				# ddioinclk_input  =>'"negated_inclk"',
	#
				# dqs_ctrl_latches_enable => '"false"',
				# dqs_delay_buffer_mode => '"'.$stratixii_dll_delay_buffer_mode.'"',
				# dqs_edge_detect_enable => '"false"',
				# dqs_input_frequency => '"'.$dll_input_frequency.'"',
				# dqs_offsetctrl_enable => '"false"',
				# dqs_out_mode => '"'.$stratixii_dqs_out_mode.'"',
	#
				# dqs_phase_shift => $stratixii_dqs_phase,
				# extend_oe_disable => '"false"',
	#
				# gated_dqs => '"false"',#'"true"',
				# inclk_input => '"normal"',#'"dqs_bus"',
				# input_async_reset => '"preset"',
				# input_power_up => '"high"',
				# input_register_mode => '"register"',
				# input_sync_reset => '"clear"',
				# lpm_type  =>'"stratixii_io"',
				# oe_async_reset => '"none"',
				# oe_power_up => '"low"',
				# oe_register_mode => '"none"',#'"register"',
				# oe_sync_reset => '"none"',
				# open_drain_output => '"false"',
				# operation_mode => '"input"',#'"bidir"',
				# output_async_reset => '"none"',
	#
				# output_power_up => '"low"',
				# output_register_mode => '"none"',#'"register"',
				# output_sync_reset => '"none"',
				# sim_dqs_delay_increment => 36,
				# sim_dqs_intrinsic_delay => 900,
				# sim_dqs_offset_increment => 0,
				# tie_off_oe_clock_enable => '"false"',
				# tie_off_output_clock_enable => '"false"',
			# },
	#
		# }),
		e_lpm_stratixii_io->new
		({
			name 		=> "cqn_inst",
			module 		=> "stratixii_io",
			comment 	=> "CQN pin",
			port_map 	=>
			{
				oe		=> "$std_logic0",
				outclk		=> "$std_logic0",
				outclkena	=> "$std_logic1",
				ddiodatain	=> "$std_logic0",
				areset          => "$std_logic1",
				delayctrlin 	=> "dll_delay_ctrl",
				sreset          => "$std_logic1",
				inclk		=> "$std_logic1",
				linkin => "linkin_linkout",

				dqsbusout 	=> "local_cqn[0]",
				# regout		=> "open",
				# ddioregout	=> "open",
				# linkout 	=> "open",

				padio 		=> "${qdrii_pin_prefix}cqn[0]",#"tmp_cqn[0]",
			},
			parameter_map 	=>
			{
				ddio_mode => '"output"',#'"bidir"',
				dqs_delay_buffer_mode => '"'.$stratixii_dll_delay_buffer_mode.'"',
				dqs_input_frequency => '"'.$dll_input_frequency.'"',
				dqs_out_mode => '"'.$stratixii_dqs_out_mode.'"',
				dqs_phase_shift => $stratixii_dqs_phase,

				input_async_reset => '"preset"',
				input_power_up => '"high"',
				input_register_mode => '"register"',
				input_sync_reset => '"clear"',
				output_register_mode => '"register"',#'"register"',

				operation_mode => '"bidir"',#'"bidir"',

				sim_dqs_delay_increment => 36,
				sim_dqs_intrinsic_delay => 900,
				sim_dqs_offset_increment => 0,
			},

		}),
		e_lpm_stratixii_io->new
		({
			name 		=> "cq_inst",
			module 		=> "stratixii_io",
			comment 	=> "CQ pin",
			port_map 	=>
			{
				oe		=> "$std_logic0",
				outclk		=> "$std_logic0",
				outclkena	=> "$std_logic1",
				ddiodatain	=> "$std_logic0",
				areset          => "$std_logic1",
				delayctrlin 	=> "dll_delay_ctrl",
				sreset          => "$std_logic1",
				inclk		=> "$std_logic1",
				#linkin	 	=> "link",

				dqsbusout 	=> "local_cq[0]",
				# regout		=> "open",
				# ddioregout	=> "open",
				linkout => "linkin_linkout",

				padio 		=> "${qdrii_pin_prefix}cq[0]",#"tmp_cq[0]",
			},
			parameter_map 	=>
			{
				ddio_mode => '"output"',#'"bidir"',
				dqs_delay_buffer_mode => '"'.$stratixii_dll_delay_buffer_mode.'"',
				dqs_input_frequency => '"'.$dll_input_frequency.'"',
				dqs_out_mode => '"'.$stratixii_dqs_out_mode.'"',
				dqs_phase_shift => $stratixii_dqs_phase,

				input_async_reset => '"preset"',
				input_power_up => '"high"',
				input_register_mode => '"register"',
				input_sync_reset => '"clear"',
				output_register_mode => '"register"',#'"register"',

				operation_mode => '"bidir"',#'"bidir"',

				sim_dqs_delay_increment => 36,
				sim_dqs_intrinsic_delay => 900,
				sim_dqs_offset_increment => 0,
			},

		}),
	);
}
if($family eq "Cyclone II")
{
	$module->add_contents
	(
		e_comment->new({comment		=>
			"-----------------------------------------------------------------------------\n
			 Instatiation of the Cyclone II Clock Delay Control Block\n
			 -----------------------------------------------------------------------------\n"}),
		e_blind_instance->new
		({
			name 		=> "cq_inst",
			module 		=> "cycloneii_clk_delay_ctrl",
			in_port_map 	=>
			{
				clk 	=> "${qdrii_pin_prefix}cq[0:0]",
			},
			out_port_map	=>
			{
				clkout	=> "local_cq[0:0]",
			},
			parameter_map	=>
			{
				delay_chain       	=> '"'.$CYCLONE2_DQS_DELAY.'"',
				behavioral_sim_delay => '"'.$CYCLONE2_DQS_DELAY.'"',

				delay_chain_mode	=> '"static"',
			},
		}),
		e_blind_instance->new
		({
			name 		=> "cqn_inst",
			module 		=> "cycloneii_clk_delay_ctrl",
			in_port_map 	=>
			{
				clk 	=> "${qdrii_pin_prefix}cqn[0:0]",
			},
			out_port_map	=>
			{
				clkout	=> "local_cqn[0:0]",
			},
			parameter_map	=>
			{
				behavioral_sim_delay => '"'.$CYCLONE2_DQS_DELAY.'"',
				delay_chain       	=> '"'.$CYCLONE2_DQS_DELAY.'"',
				delay_chain_mode	=> '"static"',
			},
		}),
	);
}
# }
##################################################################################################################################################################
$project->output();
}
1;
#You're done.
