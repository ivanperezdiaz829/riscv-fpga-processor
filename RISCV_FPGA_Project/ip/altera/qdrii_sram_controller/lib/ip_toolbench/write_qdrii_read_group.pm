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
#  Title        : Read group
#  Project      : QDRII SRAM Controller
#
#
#  File         : $RCSfile: write_qdrii_read_group.pm,v $
#
#  Last modified: $Date: 2013/08/11 $
#  Revision     : $Revision: #1 $
#
#  Abstract:   This module captures the data (Q)
#
#  Notes:
# ------------------------------------------------------------------------------
#sopc_builder free code
use europa_all;
use europa_utils;
use e_comment;
use e_lpm_stratixii_io;
use e_lpm_stratix_io;

sub write_qdrii_read_group
{

my $mem_type = $gMEM_TYPE;

my $top = e_module->new({name => $gWRAPPER_NAME . "_auk_${mem_type}_read_group"});
my $project = e_project->new({top => $top, language => $language,__system_directory =>$output_directory});
my $module = $project->top();
$module->add_attribute(ALTERA_ATTRIBUTE => "SUPPRESS_DA_RULE_INTERNAL=C106");
$module->vhdl_libraries()->{altera_mf} = all;
$module->vhdl_libraries()->{$gFAMILYlc} = all;

#####   Parameters declaration  ######
my $header_title = "Read Datapath for the Altera QDRII Controller";
my $header_filename = $gWRAPPER_NAME . "_ddr_${mem_type}_read_group" . $file_ext;
my $header_revision = "V" . $gWIZARD_VERSION;
my $header_abstract = "This file contains the datapath for the QDRII SDRAM Controller.";

my $mem_dq_per_dqs = $gMEM_DQ_PER_DQS;
my $family = $gFAMILY;

my $memory_data_width = $gMEMORY_DATA_WIDTH;
my $memory_address_width = $gMEMORY_ADDRESS_WIDTH;
my $qdrii_pin_prefix = $gQDRII_PIN_PREFIX;
my $use_dqs_for_read = $gUSE_DQS_FOR_READ;
######################################################################################################################################################################
	$module->comment
	(
		"------------------------------------------------------------------------------\n
		 Title        : $header_title\n Project      : QDRII Controller\n\n\n File         : $header_filename\n\n Revision     : $header_revision\n\n
		 Abstract:\n $header_abstract\n\n
		------------------------------------------------------------------------------\n
		 Parameters:\n\n
		 Device Family			: $gFAMILY\n
		 Memory data width		: $mem_dq_per_dqs\n
		 Memory address width		: $memory_address_width\n
		 Use dqs for read		: $use_dqs_for_read\n
		 ------------------------------------------------------------------------------\n"
	);
######################################################################################################################################################################

	if($family eq "Stratix II" and $use_dqs_for_read eq "true")
	{
		$module->add_contents
		(
			e_port->new({name => "capture_clock",direction => "input"}),
			e_port->new({name => "capture_clock_n",direction => "input"}),
		);
	}
	elsif (($family eq "Stratix II" and $use_dqs_for_read eq "false") or ($family eq "Stratix"))
	{
		$module->add_contents
		(
			e_port->new({name => "non_dqs_capture_clk",direction => "input"}),
		);
	}
	else
	{
		$module->add_contents
		(
			e_port->new({name => "capture_clock",direction => "input"}),
			e_port->new({name => "capture_clock_n",direction => "input"}),
		);
	}
	$module->add_contents
	(
	#####	Ports declaration#	######
		e_port->new({name => "reset_n",direction => "input"}),

		e_port->new({name => "${qdrii_pin_prefix}q" , direction => "input" , width => $mem_dq_per_dqs}),

		e_port->new({name => "captured_data" , direction => "output" , width => $mem_dq_per_dqs * 2}),
	);

#########################################################################################################################################################
	$module->add_contents
	(
	#####   signal generation #####
		e_signal->new({name => "ONE", width => 1, export => 0, never_export => 1}),
		e_signal->new({name => "ZERO", width => 1, export => 0, never_export => 1}),
		e_signal->new({name => "ZEROS", width => 6, export => 0, never_export => 1}),
		e_signal->new({name => "reset", width => 1, export => 0, never_export => 1}),
		e_signal->new({name => "q_captured_rising",  width =>  $mem_dq_per_dqs,export => 0,never_export => 1,declare_one_bit_as_std_logic_vector => 1}),
		e_signal->new({name => "q_captured_falling", width =>  $mem_dq_per_dqs,export => 0,never_export => 1,declare_one_bit_as_std_logic_vector => 1}),

		e_assign->new(["ONE" => "1"]),
		e_assign->new(["ZERO"  => "0"]),
		e_assign->new(["ZEROS" => "000000"]),
		e_assign->new(["reset" => "~reset_n"]),
	);
###############################################################################################################################################################
if( $family eq "Stratix II" )
{
	$module->add_contents
	(
#		e_port->new({name => "write_clk",direction => "input"}),
		e_signal->new(["q_pin", $mem_dq_per_dqs,	0,	1]),#enable signal for the q pins
		e_assign->new({lhs => "q_pin", rhs => "${qdrii_pin_prefix}q"}),

	);
	for ( my    $i = 0 ; $i < $mem_dq_per_dqs; $i++)
	{
		if ($use_dqs_for_read eq "true")
		{
			$module->add_contents
			(
				e_comment->new({comment		=>
				"-----------------------------------------------------------------------------\n
				 Read `q[$i]` pins logic\n
				 -----------------------------------------------------------------------------\n"
				 }),
				e_lpm_stratixii_io->new
				({
					name 		=> "q_capture_reg_$i",
					module 		=> stratixii_io,
					suppress_open_ports   => 1,
					port_map 	=>
					{



                        #areset => "reset",								
                        ddioinclk => "capture_clock_n",
                        ddioregout => "q_captured_rising[$i]",
                        inclk => "capture_clock",
                        inclkena => "ONE",
                        padio => "q_pin[$i]",
                        regout => "q_captured_falling[$i]",

					},
					parameter_map 	=>
					{



                        ddio_mode               => '"input"',
                        ddioinclk_input         => '"dqsb_bus"',
                        dqs_ctrl_latches_enable => '"false"',
                        dqs_delay_buffer_mode   => '"none"',
                        dqs_edge_detect_enable  => '"false"',
                        dqs_input_frequency     => '"unused"',
                        dqs_offsetctrl_enable   => '"false"',
                        dqs_out_mode            => '"none"',
                        dqs_phase_shift         => '0',
                        extend_oe_disable       => '"false"',
                        gated_dqs               => '"false"',
                        inclk_input             => '"dqs_bus"',
                        input_async_reset       => '"none"',		
                        input_power_up          => '"low"',
                        input_register_mode     => '"register"',
                        input_sync_reset        => '"none"',		
                        lpm_type                => '"stratixii_io"',
                        open_drain_output       => '"false"',
                        operation_mode          => '"input"',
                        sim_dqs_delay_increment => '0',
                        sim_dqs_intrinsic_delay => '0',
                        sim_dqs_offset_increment => '0',
                        tie_off_oe_clock_enable => '"false"',
                        tie_off_output_clock_enable => '"false"',

					},
				}),
			);
		}
		else
		{
			$module->add_contents
			(
				e_comment->new({comment		=>
				"-----------------------------------------------------------------------------\n
				 Read `q[$i]` pins logic\n
				 -----------------------------------------------------------------------------\n"
				 }),
				e_lpm_stratixii_io->new
				 ({
					 name 		=> "q_capture_reg_$i",
					 module 		=> stratixii_io,
					 suppress_open_ports	=> 1,
					 port_map 	=>
					 {

                        #areset => "reset",							
                        ddioregout => "q_captured_rising[$i]",
                        inclk => "non_dqs_capture_clk",
                        inclkena => "ONE",
                        padio => "q_pin[$i]",
                        regout => "q_captured_falling[$i]",
					 },
					 parameter_map 	=>
					 {



                        ddio_mode               => '"input"',
                        ddioinclk_input         => '"negated_inclk"',
                        dqs_ctrl_latches_enable => '"false"',
                        dqs_delay_buffer_mode   => '"none"',
                        dqs_edge_detect_enable  => '"false"',
                        dqs_input_frequency     => '"unused"',
                        dqs_offsetctrl_enable   => '"false"',
                        dqs_out_mode            => '"none"',
                        dqs_phase_shift         => '0',
                        extend_oe_disable       => '"false"',
                        gated_dqs               => '"false"',
                        inclk_input             => '"normal"',
                        input_async_reset       => '"none"',		
                        input_power_up          => '"low"',
                        input_register_mode     => '"register"',
                        input_sync_reset        => '"none"',		
                        lpm_type                => '"stratixii_io"',
                        open_drain_output       => '"false"',
                        operation_mode          => '"input"',
                        sim_dqs_delay_increment => '0',
                        sim_dqs_intrinsic_delay => '0',
                        sim_dqs_offset_increment => '0',
                        tie_off_oe_clock_enable => '"false"',
                        tie_off_output_clock_enable => '"false"',

					 },
				 }),
			  );
		}
	}
}
elsif( $family eq "Cyclone II" )
{
	$module->add_contents
	(
		e_comment->new({comment		=>
			"-----------------------------------------------------------------------------\n
			  Using ${gWRAPPER_NAME}_auk_${mem_type}_capture_group component to capture the `q` data from the memory\n
 			 -----------------------------------------------------------------------------\n"
 			 }),
		e_blind_instance->new
		({
			name 		=> "q_pin",
			module 		=> $gWRAPPER_NAME."_auk_${mem_type}_capture_group",
			in_port_map 	=>
			{
				reset_n        		=> "reset_n",
				datain			=> "${qdrii_pin_prefix}q",
				clk    			=> "capture_clock",
				clk_n  			=> "capture_clock_n",
			},
			out_port_map	=>
			{
				captured_rdata_h   	=> "q_captured_rising",
				captured_rdata_l     	=> "q_captured_falling",
			},
		}),
	);
}
elsif( $family eq "Stratix" )
    {
			$module->add_contents
			(
		#		e_port->new({name => "write_clk",direction => "input"}),
				e_signal->new(["q_pin", $mem_dq_per_dqs,	0,	1]),#enable signal for the q pins
				e_assign->new({lhs => "q_pin", rhs => "${qdrii_pin_prefix}q"}),
		
			);
     	for ( my    $i = 0 ; $i < $mem_dq_per_dqs; $i++)
    	{

			$module->add_contents
			(
				e_comment->new({comment		=>
				"-----------------------------------------------------------------------------\n
				 Read `q[$i]` pins logic\n
				 -----------------------------------------------------------------------------\n"
				 }),



				e_lpm_stratix_io->new
				 ({
					 name 		=> "q_capture_reg_$i",
					 module 		=> stratix_io,
					 suppress_open_ports	=> 1,
					 in_port_map 	=>
					 {


                        #areset => "reset",				
                        ddioregout => "q_captured_rising[$i]",
                        inclk => "non_dqs_capture_clk",
                        inclkena => "ONE",
                        padio => "q_pin[$i]",
                        regout => "q_captured_falling[$i]",
					 },
					 parameter_map 	=>
					 {

 					ddio_mode               => '"input"',
					input_async_reset       => '"none"',
					input_register_mode     => '"register"',
                    operation_mode          => '"input"'


					 },
				 }),
			  );
		}

	}





	$module->add_contents

	(
		e_assign->new(["captured_data", "{q_captured_rising,q_captured_falling}"]),
	);

##################################################################################################################################################################
$project->output();
}
1;
#You're done.
