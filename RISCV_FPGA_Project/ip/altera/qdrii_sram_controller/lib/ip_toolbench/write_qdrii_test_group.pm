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
#  Title        : Test group
#  Project      : QDRII SRAM Controller
#
#
#  File         : $RCSfile: write_qdrii_test_group.pm,v $
#
#  Last modified: $Date: 2013/08/11 $
#  Revision     : $Revision: #1 $
#
#  Abstract:  Reads data back and calulate the latency compared to a reference latency
#
#  Notes:
# ------------------------------------------------------------------------------
#sopc_builder free code
use europa_all;
use europa_utils;


sub write_qdrii_test_group
{
my $mem_type = $gMEM_TYPE;

my $top = e_module->new({name => $gWRAPPER_NAME."_auk_${mem_type}_test_group"});#, output_file => 'd:/OFadeyi/DATA_PATH/temp_gen/'});
my $project = e_project->new({top => $top, language => $language,__system_directory =>$output_directory, timescale => "1ps / 1ps"});#'temp_gen'});
my $module = $project->top();
my $family = $gFAMILY;

my $mem_dq_per_dqs = $gMEM_DQ_PER_DQS;
my $memory_data_width = $gMEMORY_DATA_WIDTH;
my $memory_address_width = $gMEMORY_ADDRESS_WIDTH;
my $qdrii_pin_prefix = $gQDRII_PIN_PREFIX;
my $is_busrt4_narrow = $gIS_BURST4_NARROW;
my $avl_data_width_multiply = $gAVL_DATA_WIDTH_MULTIPLY;
my $use_dqs_for_read = $gUSE_DQS_FOR_READ;
my $local_data_bits = $gLOCAL_DATA_BITS;
my $num_chips_wide = $gNUM_CHIPS_WIDE;
my $num_chips_deep = $gNUM_CHIPS_DEEP;
my $deep;
if($num_chips_deep > 1){
	$deep = 1;
}else{
	$deep = 0;
}
my $train_Ref = $gTRAIN_REFERENCE ;
my $len = 13 + $train_Ref;
my $searched = "1";
for ($j = 0; $j < $train_Ref; $j++){
	$searched .= "0";
}
my $sequence = $searched."000000000000";
# print "\n-> $sequence <-\n\t";
     $module->comment
    (
    	"------------------------------------------------------------------------------\n
    	Title        : $header_title
    	Project      : QDRII Controller
    	File         : $header_filename
    	Revision     : $header_revision
    	Abstract:
    	QDRII Test Bench
    	----------------------------------------------------------------------------------\n"
    );

######################################################################################################################################################################
	$module->add_contents
	(
	#####	Ports declaration	#####
		e_port->new({name => "clk" , direction => "input", width => 1}),
		e_port->new({name => "reset_n" , direction => "input", width => 1}),
		e_port->new({name => "train_rdata" , direction => "input", width => 1}),
		e_port->new({name => "latency_counter" , direction => "input", width => 5}),
		e_port->new({name =>  "training_on", width => 1, direction => "input"}),

		e_port->new({name => "pattern_not_found", direction => "output", width => 1}),
		e_port->new({name => "pattern_incorrect", direction => "output", width => 1}),
		e_port->new({name => "pattern_on_time", direction => "output", width => 1}),
		e_port->new({name => "pattern_early", direction => "output", width => 1}),
		e_port->new({name =>  "pattern_late", width => 1, direction => "output"}),


	#####	Signals declaration	#####
		e_signal->new({name =>  "training_on_reg", width => 1, export => 0, never_export => 1}),
		e_signal->new({name =>  "pattern_found_pulse", width => 1, export => 0, never_export => 1}),
		e_signal->new({name =>  "pattern_not_found_reg", width => 1, export => 0, never_export => 1}),

		e_signal->new({name =>  "detected_latency", width => 5, export => 0, never_export => 1}),


	);
######################################################################################################################################################################

	$module->add_contents
	(
 	    e_process->new
	    ({
		clock		=> "clk",
		reset		=> "reset_n",
		_asynchronous_contents	=>
		[
			e_assign->new(["pattern_not_found", "1'b1"]),
			e_assign->new(["pattern_incorrect", "1'b1"]),
			e_assign->new(["pattern_on_time", "1'b0"]),
			e_assign->new(["pattern_early", "1'b1"]),
			e_assign->new(["pattern_late", "1'b0"]),
			e_assign->new(["training_on_reg", "1'b0"]),
			e_assign->new(["pattern_not_found_reg", "1'b1"]),
			e_assign->new(["detected_latency", "5'b00000"]),
		],
		contents	=>
		[
			e_assign->new(["training_on_reg", "training_on"]),
			e_assign->new(["pattern_not_found_reg", "pattern_not_found"]),
			e_if->new
			({
				condition	=> "((training_on_reg == 1'b0) && (training_on == 1'b1))",
				then		=>
				[
					e_assign->new(["pattern_not_found", "1'b1"]),
					e_assign->new(["pattern_incorrect", "1'b1"]),
					e_assign->new(["pattern_on_time", "1'b0"]),
					e_assign->new(["pattern_early", "1'b1"]),
					e_assign->new(["pattern_late", "1'b0"]),
					e_assign->new(["detected_latency", "5'b00000"]),
				],
			}),
			e_if->new
			({
				condition	=> "(training_on == 1'b1)",
				then		=>
				[
					e_if->new
					({
						condition	=> "(train_rdata == 1'b1)",
						then		=>
						[
							e_assign->new(["pattern_not_found", "1'b0"]),
							e_if->new
							({
								condition	=> "((pattern_not_found_reg == 1'b1) && (pattern_not_found == 1'b0))",
								then		=>
								[
									e_assign->new(["detected_latency", "latency_counter"]),
								],
							}),
						],
					}),

				],
			}),

			e_if->new
			({
				condition	=> "(pattern_not_found == 1'b0)",
				then		=>
				[
					e_assign->new(["pattern_incorrect", "1'b0"]),
					e_if->new
					({
						condition	=> "detected_latency >".$train_Ref,
						then		=>
						[
							e_assign->new(["pattern_on_time", "1'b0"]),
							e_assign->new(["pattern_early", "1'b0"]),
							e_assign->new(["pattern_late", "1'b1"]),

						],
						else =>
						[
							e_if->new
							({
								condition	=> "detected_latency ==  ".$train_Ref,
								then		=>
								[
									e_assign->new(["pattern_on_time", "1'b1"]),
									e_assign->new(["pattern_early", "1'b0"]),
									e_assign->new(["pattern_late", "1'b0"]),

								],
							}),

						],
					}),
					e_if->new
					({
						condition	=> "detected_latency < 4",
						then		=>
						[
							e_assign->new(["pattern_incorrect", "1'b1"]),
						],
					}),

				],
			}),

		],
	    }),
      );
######################################################################################################################################################################

$project->output();
}

1;
#You're done.
