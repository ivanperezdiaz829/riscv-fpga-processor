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
#  Title        : DLL generation
#  Project      : QDRII SRAM Controller
#
#
#  File         : $RCSfile: write_qdrii_dll_gen.pm,v $
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
use e_component;

sub write_ddr_dll_gen
{                          
    my $mem_type = $gMEM_TYPE;
    my $family = $gFAMILY;

	if (($gFAMILY eq "Stratix II")){# and ($gENABLE_CAPTURE_CLK ne "true" this condition is not checked so the file gets generated but not added to the project
		my $top = e_module->new({name =>  $gWRAPPER_NAME."_auk_${mem_type}_dll"});
		my $project = e_project->new({top => $top, language => $language,__system_directory =>$output_directory , timescale => "1ps / 1ps"});
		my $module = $project->top();
		
		$module->vhdl_libraries()->{$gFAMILYlc} = all;
		$module->vhdl_libraries()->{altera_mf} = all;
		
		my $header_title = "DLL for the Altera QDRII SRAM Controller";
		my $header_filename = $gWRAPPER_NAME . "_auk_${mem_type}_dll" . $file_ext;
		my $header_revision = "V" . $gWIZARD_VERSION;
		my $header_abstract = "// This file contains the DLL for the QDRII SRAM Controller.";
		
		# my $clock_period_in_ps = $gCLOCK_PERIOD_IN_PS;
		# my $dqs_phase_shift = $gDQS_PHASE_SHIFT;
		my $clock_period_in_ps = int(((10**12) / ($gCLOCK_FREQ_IN_MHZ*(10**6))));#$gCLOCK_PERIOD_IN_PS;
		my $stratixii_dll_delay_buffer_mode = $gSTRATIXII_DLL_DELAY_BUFFER_MODE;
		my $stratixii_dll_delay_chain_length = ${gSTRATIXII_DLL_DELAY_CHAIN_LENGTH};
		my @in_ports;
		my @out_ports;
		my @in_ports_w;
		my @out_ports_w;
		my @in_ports_d;
		my @out_ports_d;
		my @b_inports;
		my @b_outports;
		my %params;
		my $comment = "------------------------------------------------------------\n
		Instantiate $gFAMILY DLL\n
		------------------------------------------------------------\n";
		push (@in_ports,"clk");
		push (@in_ports_w,1);
		push (@in_ports_d,"input");
		push (@out_ports,"delayctrlout");
		push (@out_ports_w,6);
		push (@out_ports_d,"output");
		push (@b_inports, "clk");
		if ($gFAMILY eq "Stratix II"){
			push (@b_outports, "delayctrlout");
			$params{'delay_buffer_mode'} = "\"$gSTRATIXII_DLL_DELAY_BUFFER_MODE\"";
			$params{'delay_chain_length'} = "$gSTRATIXII_DLL_DELAY_CHAIN_LENGTH";
			$params{'delayctrlout_mode'} = "\"normal\"";
			$params{'input_frequency'} = "\"$clock_period_in_ps"."ps\"";
			$params{'jitter_reduction'} = "\"false\"";
			$params{'offsetctrlout_mode'} = "\"static\"";
			$params{'sim_loop_delay_increment'} = "144";
			$params{'sim_loop_intrinsic_delay'} = "3600";
			$params{'sim_valid_lock'} = "1";
			$params{'sim_valid_lockcount'} = "27";
			$params{'static_offset'} = "\"0\"";
			$params{'use_upndnin'} = "\"false\"";
			$params{'use_upndninclkena'} = "\"false\"";
		}
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
				 ----------------------------------------------------------------------------------\n",
				 # Positive Clock Signal Name         : $clock_pos_pin_name\n
				 # Negative Clock Signal Name         : $clock_neg_pin_name\n
			);
#####################################################################################################################################################################
			for( my $i = 0; $i < scalar(@in_ports); $i++){
				$module->add_contents(e_port->new({name=>@in_ports[$i],width=>@in_ports_w[$i],direction=>@in_ports_d[$i]}),);
			}
			for( my $i = 0; $i < scalar(@out_ports); $i++){
				$module->add_contents(e_port->new({name=>@out_ports[$i],width=>@out_ports_w[$i],direction=>@out_ports_d[$i]}),);
			}
			$module->add_contents
			(
				e_comment->new({comment => $comment}),
				e_blind_instance->new
				({
					name 		=> "dll",
					module 		=> $gFAMILYlc."_dll",
					in_port_map 	=> {@in_ports => @b_inports},
					out_port_map	=> {@out_ports => @b_outports},
					parameter_map 	=> {%params},
				}),
			);
###############################################################################################################################################
		$project->output();
	}
}

1;
#You're done.
