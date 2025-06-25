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
#  Title        : Resynchronisation block
#  Project      : QDRII SRAM Controller
#
#
#  File         : $RCSfile: write_qdrii_resynch_reg.pm,v $
#
#  Last modified: $Date: 2013/08/11 $
#  Revision     : $Revision: #1 $
#
#  Abstract:   This module instantiate the FIFO for the resynchronisation between capture clock and sytem clock
#
#  Notes:
# ------------------------------------------------------------------------------
#sopc_builder free code
use europa_all;
use europa_utils;
use e_lpm_ram;

sub write_qdrii_resynch_reg
{
my $mem_type = $gMEM_TYPE;

my $top = e_module->new({name => $gWRAPPER_NAME."_auk_${mem_type}_resynch_reg"});#, output_file => 'd:/OFadeyi/DATA_PATH/temp_gen/'});
my $project = e_project->new({top => $top, language => $language,__system_directory =>$output_directory, timescale => "1ps / 1ps"});#'temp_gen'});
my $module = $project->top();
$module->add_attribute(ALTERA_ATTRIBUTE => "SUPPRESS_DA_RULE_INTERNAL=C106");
$module->vhdl_libraries()->{altera_mf} = "altera_mf_components.all";


my $header_title = "Resynch Registers for the Altera QDRII SDRAM Controller";
my $header_filename = $gWRAPPER_NAME . "_auk_${mem_type}_resynch_reg" . $file_ext;
my $header_revision = "V" . $gWIZARD_VERSION;
my $header_abstract = "This file contains the resynchronization registers for the QDRII SDRAM Controller.";

my $family = $gFAMILY;
my $mem_dq_per_dqs = $gMEM_DQ_PER_DQS;
my $memory_data_width = $gMEMORY_DATA_WIDTH;
my $memory_address_width = $gMEMORY_ADDRESS_WIDTH;
my $resynch_type = $gRESYNCH_TYPE;
######################################################################################################################################################################
	$module->comment
	(
		"------------------------------------------------------------------------------\n
		 Title        : $header_title\n Project      : QDRII Controller\n\n\n File         : $header_filename\n\n Revision     : $header_revision\n\n
		 Abstract:\n $header_abstract\n\n
		------------------------------------------------------------------------------\n"
	);
######################################################################################################################################################################
	$module->add_contents
	(
	#####	Ports declaration#	######
		e_port->new({name => "clk", direction => "input",}),
		e_port->new({name => "reset_n", direction => "input"}),

	##DM GROUP input and output signal
		e_port->new({name => "unsynch_data" , direction => "input" , width => $mem_dq_per_dqs * 2 , declare_one_bit_as_std_logic_vector => 0}),

		e_port->new({name => "resynch_data" , direction => "output", width => $mem_dq_per_dqs * 2 , declare_one_bit_as_std_logic_vector => 0}),
	##Internal signal
	);
######################################################################################################################################################################
##



if( $resynch_type ne "ram"){
	$module->add_contents
	(
		e_register->new
		({
			q   		=> "resynch_data",
			d   		=> "unsynch_data",
			async_set   	=> "reset_n",
			#async_value 	=> "-1",
			enable	    	=> 1,
		})
	);
}else{
    $module->add_contents
        (
		e_port->new({name => "cq" , direction => "input", width => 1}),
		e_port->new({name => "address_plus_two" , direction => "input", width => 1}),
		e_port->new({name => "address_plus_zero" , direction => "input", width => 1}),
		e_port->new({name => "reset_read_and_fifo_n" , direction => "input", width => 1}),
		e_signal->new(["one",1,0,1]),
		e_signal->new(["zero",1,0,1]),
		e_signal->new(["temp_resynch_data",($mem_dq_per_dqs * 2),0,1]),
		e_signal->new(["unsynch_data_reg",($mem_dq_per_dqs * 2),0,1]),
		e_assign->new(["one","1'b1"]),
		e_signal->new(["wr_addr",4,0,1]),
		e_signal->new(["rd_addr",4,0,1]),
		e_signal->new(["cq_reset_n",1,0,1]),
		e_signal->new(["meta_cq_reset_n",1,0,1]),
		e_assign->new(["zero","1'b0"]),
		e_process->new
		({
			clock		=> "cq",
			reset		=> "cq_reset_n",
			_asynchronous_contents	=>
			[
				e_assign->new(["wr_addr", "4'b0110"]),
			],
			contents	=>
			[
				e_assign->new(["wr_addr", "wr_addr + 1"]),
			],
		}),


		e_process->new
		({
			clock		=> "cq",
			contents	=>
			[
				e_assign->new(["meta_cq_reset_n", "reset_read_and_fifo_n"]),
				e_assign->new(["cq_reset_n", "meta_cq_reset_n"]),
			],
		}),

		e_process->new
		({
			clock		=> "clk",
			reset		=> "reset_n",
			_asynchronous_contents	=>
			[
				e_assign->new(["rd_addr", "4'b0000"]),
			],
			contents	=>
			[
				e_if->new
				({
					condition	=> "(reset_read_and_fifo_n == 1'b0)",
					then		=>
					[
						e_assign->new(["rd_addr", "4'b0000"]),
					],
					else		=>
					[
					e_if->new
					({
						condition	=> "address_plus_two",
						then		=>
						[	e_assign->new(["rd_addr", "rd_addr + 2"]),	],
						else		=>
						[
							e_if->new
							({
								condition	=> "address_plus_zero",
								then		=>
								[	e_assign->new(["rd_addr", "rd_addr"]),	],
								else		=>
								[
									e_assign->new(["rd_addr", "rd_addr + 1"]),
								],
							}),
						],
					}),
					],
				}),
			],
		}),








		e_lpm_ram->new
		({
		 	comment => "Dual Port RAM",
		 	name        => "ram_inst",
		 	port_map    =>
			{
				wren_a		=> "one",
		        clocken0  => "one",
                clocken1  => "one",


				address_a	=> "wr_addr",
				address_b	=> "rd_addr",
				data_a		=> "unsynch_data",
				clock0		=> "cq",
				clock1		=> "clk",
				q_b		=> "resynch_data",
			},
			parameter_map =>
			{
				intended_device_family => "\"$family\"",
				operation_mode => "\"DUAL_PORT\"",
				width_a => $mem_dq_per_dqs * 2,
				widthad_a => 4,
				numwords_a => 16,
				width_b => $mem_dq_per_dqs * 2,
				widthad_b => 4,
				numwords_b => 16,
				lpm_type => "\"altsyncram\"",
				width_byteena_a => 1,
				outdata_reg_b => "\"CLOCK1\"",
				address_reg_b => "\"CLOCK1\"",
				outdata_aclr_b => "\"NONE\"",
				@ram_params_list			=> @ram_params_list,
				read_during_write_mode_mixed_ports => "\"DONT_CARE\"",
				power_up_uninitialized => "\"FALSE\""
			},
		}),

     );
}
######################################################################################################################################################################
$project->output();
}

1;
#You're done.
