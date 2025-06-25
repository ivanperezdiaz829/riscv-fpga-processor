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
#  File         : $RCSfile: write_qdrii_test_bench.pm,v $
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

use e_testbench;
use e_reset; 
use e_clk; 

use e_memory;

sub write_qdrii_test_bench
{
my $top = e_module->new({name => $gTOPLEVEL_NAME."_tb"});
my $project = e_project->new({top => $top, language => $language,__system_directory =>$output_directory."/testbench/",timescale => "1ps / 1ps"});#'temp_gen'});
#my $project = e_project->new({top => $top, language => $language,__system_directory =>$output_directory,timescale => "1ps / 1ps"});#'temp_gen'});

my $module = $project->top();
#####   Parameters declaration  ######
$header_title = "QDR II Controller Test Bench";
$header_filename = $gTOPLEVEL_NAME . "_tb";
$header_revision = "V" . $gWIZARD_VERSION;
my $regtest = $gREGRESSION_TEST;

my $mem_dq_per_dqs = $gMEM_DQ_PER_DQS;
my $local_data_bits = $gLOCAL_DATA_BITS;
my $memory_data_width = $gMEMORY_DATA_WIDTH;
my $memory_address_width = $gMEMORY_ADDRESS_WIDTH;
my $delay_chain = $gDELAY_CHAIN;
my $latency = $gMEMORY_LATENCY;
my $burst_mode = $gMEMORY_BURST_LENGTH;
my $avl_data_width_multiply = $gAVL_DATA_WIDTH_MULTIPLY;
my $bwsn_width;             
my $family = $gFAMILY;
my $ddio_memory_clocks = $gDDIO_MEMORY_CLOCKS;
my $clock_period_in_ps = int(((10**12) / ($gCLOCK_FREQ_IN_MHZ*(10**6))));#$gCLOCK_PERIOD_IN_PS;

my $temp_latency;
if ($latency == 2)
{
	$temp_latency = "2.0";
}
else
{
	$temp_latency = $latency;
} 
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
my $memory_component_name = $gMEMORY_MODEL_NAME;
my $qdrii_pin_prefix = $gQDRII_PIN_PREFIX;
my $is_busrt4_narrow = $gIS_BURST4_NARROW;
my $use_dqs_for_read = $gUSE_DQS_FOR_READ;
my $num_clock_pairs = $gNUM_OUTPUT_CLOCKS;

#my $clock_pos_pin_name = $gCLOCK_POS_PIN_NAME;
#my $clock_neg_pin_name = $gCLOCK_NEG_PIN_NAME;
my $clock_pos_pin_name = $qdrii_pin_prefix . "k";
my $clock_neg_pin_name = $qdrii_pin_prefix . "kn";

my @inout_param;
my %inout_param;
my @inout_parameter_list;
my @in_param;
my %in_param;
my @in_parameter_list;
my @data_wrapper;
my %data_wrapper;
my @data_wrapper_list;
my @addr_wrapper;
my %addr_wrapper;
my @addr_wrapper_list;

my @kn_param;
my %kn_param;
my @kn_parameter_list;


foreach my $parameter (@inout_param)
{
	push (@inout_parameter_list, $parameter);
}
my $num_chips_wide = $gNUM_CHIPS_WIDE;
my $num_chips_deep = $gNUM_CHIPS_DEEP;
my $mem_sizes = (((2 ** $memory_address_width) * 4) - 1);
my $deep;
if($num_chips_deep > 1){
	$deep = 1;
}else{
	$deep = 0;
}
my $bwsn_size;
if($regtest = "true"){
	$bwsn_size = $bwsn_width;
}else{
	$bwsn_size = 4;
}
my $clock_freq_in_mhz = $gCLOCK_FREQ_IN_MHZ;
my $clock_period = ((10.0 ** 3) / $clock_freq_in_mhz);
my $delay_45_deg = $clock_period / 8;
my $suffix;
if($memory_component_name eq "qdrii_model") { $suffix = "_n"; } else { $suffix = "_N" }

my $std_logic1 = "1'b1";
if($language eq "vhdl"){
	$module->add_contents
	(
		e_signal->new({name => "ONE", width => 1, export => 0, never_export => 1}),
		e_assign->new(["ONE" => "1"]),
	);
	$std_logic1 = "ONE";
}


#######################################################################################################################################

$module->comment
(
	"------------------------------------------------------------------------------\n
	Title        : $header_title
	Project      : QDRII Controller
	File         : $header_filename
	Revision     : $header_revision
	Abstract:
	QDRII Test Bench
	----------------------------------------------------------------------------------\n
	Memory Interface Setup:\n
	Memory Device                       : $memory_component_name\n
	Memory Interface Data Width         : $mem_dq_per_dqs\n
	Number Memory Address Bits          : $memory_address_width\n
	Positive Clock Signal Name          : $clock_pos_pin_name\n
	Negative Clock Signal Name          : $clock_neg_pin_name\n
	Clock Frequence                     : $clock_freq_in_mhz MHz\n
	----------------------------------------------------------------------------------\n",
);
#########################################################################################################################################################
	$module->add_contents
	(
	#####	Parameters declaration	######
		e_parameter->add({name => "use_rtl_delay", default => "0", vhdl_type => "integer"}),
	);          
	
	# here we need to change the clock pins. If not using ddio, we'll hook all the clocks to clock0 and invert them to get the neg verion of them
	
	
if($num_chips_wide > 1) 
{
	for(my $k = 0; $k < $num_chips_wide; $k++)
	{
		$module->add_contents
		 (
			#####   signal generation #####
			e_signal->new({name => "undelayed_${qdrii_pin_prefix}q_$k", width => $mem_dq_per_dqs, export => 0, never_export => 1}),
			e_signal->new({name => "delayed_${qdrii_pin_prefix}q_$k", width => $mem_dq_per_dqs, export => 0, never_export => 1}),
			e_signal->new({name => "${qdrii_pin_prefix}d_$k", width => $mem_dq_per_dqs, export => 0, never_export => 1}),
			e_signal->new({name => "${qdrii_pin_prefix}cq_$k",  width => 1, export => 0, never_export => 1, declare_one_bit_as_std_logic_vector => 1}),
			e_signal->new({name => "${qdrii_pin_prefix}cqn_$k", width => 1, export => 0, never_export => 1, declare_one_bit_as_std_logic_vector => 1}),
		);
		$data_wrapper{"${qdrii_pin_prefix}d_$k"} = "${qdrii_pin_prefix}d_$k";
		$inout_param{"${qdrii_pin_prefix}q_$k"} = "delayed_${qdrii_pin_prefix}q_$k";
		if ($use_dqs_for_read ne "false")
		{
			$inout_param{"${qdrii_pin_prefix}cq_$k"} = "${qdrii_pin_prefix}cq_$k"."[0:0]";
			$inout_param{"${qdrii_pin_prefix}cqn_$k"} = "${qdrii_pin_prefix}cqn_$k"."[0:0]";
		}else{
			$in_param{"${qdrii_pin_prefix}cq_$k"} = "${qdrii_pin_prefix}cq_$k"."[0:0]";
			$in_param{"${qdrii_pin_prefix}cqn_$k"} = "${qdrii_pin_prefix}cqn_$k"."[0:0]";
		}
	}
}else{
	$module->add_contents
	 (
		#####   signal generation #####
		e_signal->new({name => "${qdrii_pin_prefix}q", width => $mem_dq_per_dqs, export => 0, never_export => 1}),
		e_signal->new({name => "undelayed_${qdrii_pin_prefix}q", width => $mem_dq_per_dqs, export => 0, never_export => 1}),
		e_signal->new({name => "delayed_${qdrii_pin_prefix}q", width => $mem_dq_per_dqs, export => 0, never_export => 1}),
		e_signal->new({name => "${qdrii_pin_prefix}d", width => $mem_dq_per_dqs, export => 0, never_export => 1}),
		e_signal->new({name => "${qdrii_pin_prefix}cq",  width => 1, export => 0, never_export => 1, declare_one_bit_as_std_logic_vector => 1}),
		e_signal->new({name => "${qdrii_pin_prefix}cqn", width => 1, export => 0, never_export => 1, declare_one_bit_as_std_logic_vector => 1}),
	);
	if ($use_dqs_for_read ne "false")
	{
		$inout_param{"${qdrii_pin_prefix}cq"} = "${qdrii_pin_prefix}cq"."[0:0]";
		$inout_param{"${qdrii_pin_prefix}cqn"} = "${qdrii_pin_prefix}cqn"."[0:0]";
	}else{
		$in_param{"${qdrii_pin_prefix}cq"} = "${qdrii_pin_prefix}cq"."[0:0]";
		$in_param{"${qdrii_pin_prefix}cqn"} = "${qdrii_pin_prefix}cqn"."[0:0]";
	}
	$data_wrapper{"${qdrii_pin_prefix}d"} = "${qdrii_pin_prefix}d";
	$inout_param{"${qdrii_pin_prefix}q"} = "delayed_${qdrii_pin_prefix}q";
}


# create a temoporary clock signal which is 3 wide max.
# here we have to add to the data wrapper the clocks. if less than 3, the same number, if greater than 3, just 3
# then we need to add the missing signals to the clock0. Also would add the nedgedge signal as the invert of the posedge

	 $module->add_contents
	 (
			e_signal->new({name => "temp_pos_clock",   width => $num_clock_pairs,	export => 0, never_export => 1, declare_one_bit_as_std_logic_vector => 1}),
			e_signal->new({name => "temp_neg_clock",  width => $num_clock_pairs,	export => 0, never_export => 1, declare_one_bit_as_std_logic_vector => 1}),
		);


#
my $temp_num_clocks_top;
my $i_clock;

if ($num_clock_pairs > 3 && $ddio_memory_clocks eq "false") { $temp_num_clocks_top = 3 } else { $temp_num_clocks_top = $num_clock_pairs}

	if ($ddio_memory_clocks eq "false") {
		if ($num_clock_pairs > 3) {
			$module->add_contents
			(
				e_assign->new({lhs => "temp_pos_clock[$num_clock_pairs -1 : 3]", rhs => ${clock_pos_pin_name}."[0]"}),
				e_assign->new({lhs => "temp_neg_clock[$num_clock_pairs -1 : 3]", rhs => "!".${clock_pos_pin_name}."[0]"}),
				e_assign->new({lhs => "temp_pos_clock[0]", rhs => ${clock_pos_pin_name}."[0]"}),
				e_assign->new({lhs => "temp_pos_clock[1]", rhs => ${clock_pos_pin_name}."[1]"}),
				e_assign->new({lhs => "temp_pos_clock[2]", rhs => ${clock_pos_pin_name}."[2]"}),
				e_assign->new({lhs => "temp_neg_clock[0]", rhs => "!".${clock_pos_pin_name}."[0]"}),
				e_assign->new({lhs => "temp_neg_clock[1]", rhs => "!".${clock_pos_pin_name}."[1]"}),
				e_assign->new({lhs => "temp_neg_clock[2]", rhs => "!".${clock_pos_pin_name}."[2]"}),
			);
		} else {
			for($i_clock = 0; $i_clock < $num_clock_pairs; $i_clock++){
				$module->add_contents
				(
					e_assign->new({lhs => "temp_pos_clock[".($i_clock)."]", rhs => ${clock_pos_pin_name}."[".($i_clock)."]"}),
					e_assign->new({lhs => "temp_neg_clock[".($i_clock)."]", rhs => "!".${clock_pos_pin_name}."[".($i_clock)."]"}),
				);
			}
		} 
	} else {
		$kn_param{"${clock_neg_pin_name}"} = "${clock_neg_pin_name}"."[".($num_clock_pairs - 1).":0]";

		$module->add_contents
		(
			e_assign->new({lhs => "temp_pos_clock[$num_clock_pairs -1 : 0]", rhs => ${clock_pos_pin_name}."[$num_clock_pairs -1 :0]"}),
			e_assign->new({lhs => "temp_neg_clock[$num_clock_pairs -1 : 0]", rhs => ${clock_neg_pin_name}."[$num_clock_pairs -1 :0]"}),
		);
		
	}
@kn_param = %kn_param;
foreach my $param_kn (@kn_param) {push (@kn_parameter_list, $param_kn);}

my $i,$j;
if(($num_chips_wide > 1) || ($num_chips_deep > 1))
{
	for($i = 0; $i < $num_chips_deep; $i++){
		for($j = 0; $j < $num_chips_wide; $j++){
			$module->add_contents
			(
				e_signal->new({name => "${qdrii_pin_prefix}rpsn_$j"."_$i", width => 1,export => 0, never_export => 1}),
				e_signal->new({name => "${qdrii_pin_prefix}wpsn_$j"."_$i", width => 1,export => 0, never_export => 1}),
				e_signal->new({name => "${qdrii_pin_prefix}bwsn_$j"."_$i", width => $bwsn_width,export => 0, never_export => 1}),
				e_signal->new({name => "${qdrii_pin_prefix}a_$j"."_$i", width => $memory_address_width, export => 0, never_export => 1, declare_one_bit_as_std_logic_vector => 0}),
			);
			$addr_wrapper{"${qdrii_pin_prefix}rpsn_$j"."_$i"} = "${qdrii_pin_prefix}rpsn_$j"."_$i";
			$addr_wrapper{"${qdrii_pin_prefix}wpsn_$j"."_$i"} = "${qdrii_pin_prefix}wpsn_$j"."_$i";
			$addr_wrapper{"${qdrii_pin_prefix}bwsn_$j"."_$i"} = "${qdrii_pin_prefix}bwsn_$j"."_$i";
			$addr_wrapper{"${qdrii_pin_prefix}a_$j"."_$i"} = "${qdrii_pin_prefix}a_$j"."_$i";
			@addr_wrapper = %addr_wrapper;
		}
	}
}else{
	$module->add_contents
	(
		e_signal->new({name => "${qdrii_pin_prefix}rpsn", width => 1,export => 0, never_export => 1}),
		e_signal->new({name => "${qdrii_pin_prefix}wpsn", width => 1,export => 0, never_export => 1}),
		e_signal->new({name => "${qdrii_pin_prefix}bwsn", width => $bwsn_width,export => 0, never_export => 1}),
		e_signal->new({name => "${qdrii_pin_prefix}a", width => $memory_address_width, export => 0, never_export => 1, declare_one_bit_as_std_logic_vector => 0}),
	);
	$addr_wrapper{"${qdrii_pin_prefix}rpsn"} = "${qdrii_pin_prefix}rpsn";
	$addr_wrapper{"${qdrii_pin_prefix}wpsn"} = "${qdrii_pin_prefix}wpsn";
	$addr_wrapper{"${qdrii_pin_prefix}bwsn"} = "${qdrii_pin_prefix}bwsn";
	$addr_wrapper{"${qdrii_pin_prefix}a"} = "${qdrii_pin_prefix}a";
	@addr_wrapper = %addr_wrapper;
}
@in_param = %in_param;
@inout_param = %inout_param;
@addr_wrapper = %addr_wrapper;
@data_wrapper = %data_wrapper;
foreach my $param (@in_param) {push (@in_parameter_list, $param);}
foreach my $parameter (@inout_param) {push (@inout_parameter_list, $parameter);}
foreach my $data (@data_wrapper) {push (@data_wrapper_list, $data);}
foreach my $addr (@addr_wrapper) { push (@addr_wrapper_list, $addr); }
	 $module->add_contents
	 (
	 #####   signal generation #####
          	e_signal->news #: ["signal", width, export, never_export]
		(
	         	["clock_source",1,	0,	1],
			["system_reset_n",1,	0,	1],
			["test_complete",1,	0,	1],
			["fail_permanent",1,	0,	1],
			["fail",1,	0,	1],
			["training_done",1,	0,	1],
			["training_incorrect",1,	0,	1],
			["training_pattern_not_found",1,	0,	1],
			
		),
		e_signal->new({name => "$clock_pos_pin_name",   width => $num_clock_pairs,	export => 0, never_export => 1, declare_one_bit_as_std_logic_vector => 1}),
		e_signal->new({name => "$clock_neg_pin_name",  width => $num_clock_pairs,	export => 0, never_export => 1, declare_one_bit_as_std_logic_vector => 1}),
		e_signal->new({name => "clk",  width => 1,	export => 0, never_export => 1}),
		e_signal->new({name => "reset_n",  width => 1,	export => 0, never_export => 1}),
	 );        

	if((($use_dqs_for_read eq "false") and (($family eq "Stratix II") or ($family eq "Stratix II GX"))) or ($family eq "Stratix") or ($family eq "Stratix GX"))
	{	 
        if($num_chips_wide > 1) {
        	for($i = 0; $i < $num_chips_wide; $i++){
         		$module->add_contents
         		(
             		e_process->new
            		({
            			clock		=> '',
            			reset		=> '',
            			sensitivity_list=>
            			["undelayed_${qdrii_pin_prefix}q_$i"],
            			_contents	=>
            			[
            				e_if->new
            				({
            					condition	=> "(use_rtl_delay == 1)",
            					then		=>
            					[
                                    e_assign->new ({ lhs => "delayed_${qdrii_pin_prefix}q_$i", rhs => "undelayed_${qdrii_pin_prefix}q_$i",sim_delay => $delay_45_deg }),
                                ],
                                else =>
                                [
                                    e_assign->new ({lhs => "delayed_${qdrii_pin_prefix}q_$i", rhs => "undelayed_${qdrii_pin_prefix}q_$i"}),
                                ],
                                
            					
            				}),
            			],
            		})    
                );            	
            }


        }else{
     		$module->add_contents
     		(
            	e_process->new
        		({
        			clock		=> '',
        			reset		=> '',
        			sensitivity_list=>
        			["undelayed_${qdrii_pin_prefix}q"],
        			_contents	=>
        			[
        				e_if->new
        				({
        					condition	=> "(use_rtl_delay == 1)",
        					then		=>
        					[
                                e_assign->new ({ lhs => "delayed_${qdrii_pin_prefix}q", rhs => "undelayed_${qdrii_pin_prefix}q", sim_delay => $delay_45_deg }),
                            ],
                            else =>
                            [
                                e_assign->new ({ lhs => "delayed_${qdrii_pin_prefix}q", rhs => "undelayed_${qdrii_pin_prefix}q" }),
                            ],
                            
        					
        				}),
        			],
        		})    
        	);
        }	 
    } else {
        if($num_chips_wide > 1)  {
        	for($i = 0; $i < $num_chips_wide; $i++){
         		$module->add_contents
         		(
                    e_assign->new ({lhs => "delayed_${qdrii_pin_prefix}q_$i", rhs => "undelayed_${qdrii_pin_prefix}q_$i"}),
                );
            }
        } else {
         		$module->add_contents
         		(
                    e_assign->new ({lhs => "delayed_${qdrii_pin_prefix}q", rhs => "undelayed_${qdrii_pin_prefix}q"}),
                );
        }
    }
    
    
#########################################################################################################################################################
	$module->add_contents
	(

		e_blind_instance->new
		({
			name 		=> "top_level",
			module 		=> $gTOPLEVEL_NAME,
			in_port_map 	=>
			{
				clk_in			=> "clock_source",
				reset_n 		=> "system_reset_n",
				@in_param		=> @in_parameter_list,
			},
			inout_port_map	=>
			{
				@inout_param		=> @inout_parameter_list,
			},
			out_port_map	=>
			{
				test_complete 		=> "test_complete",
				fail_permanent 		=> "fail_permanent",
				fail 			=> "fail",
				training_done		=> "training_done",
				training_incorrect		=> "training_incorrect",
				training_pattern_not_found		=> "training_pattern_not_found",

				@addr_wrapper		=> @addr_wrapper_list,
				@data_wrapper		=> @data_wrapper_list,
				@kn_parameter_list => @kn_parameter_list,
				$clock_pos_pin_name 	=> $clock_pos_pin_name."[".($temp_num_clocks_top - 1).":0]",
				
			},
			std_logic_vector_signals =>
			[
				@in_parameter_list,
				@inout_parameter_list,
				$clock_pos_pin_name,
				$clock_neg_pin_name,
			],
		}),
	);
#################################### Memory module ############################################
if(($num_chips_wide > 1) || ($num_chips_deep > 1))
{
	my $i,$j,$k;
	for($i = 0; $i < $num_chips_deep; $i++)
	{
		for($j = 0; $j < $num_chips_wide; $j++)
		{
			if($num_chips_wide > 1){ $k = "_$j";}
			if ($memory_component_name eq "qdrii_model")
			{
				$module->add_contents
				(
					e_comment->new({comment => "Instantiate Generic QDRII Memory"}),
					e_memory->new
					({
						name 		=> "qdrii_memory_inst_$j"."_$i",
						module 		=> $memory_component_name,
						port_map 	=>
						{
							d 		=> "${qdrii_pin_prefix}d$k",
							sa 		=> "${qdrii_pin_prefix}a_$j"."_$i",
							bw.$suffix 	=> "${qdrii_pin_prefix}bwsn_$j"."_$i",
							k		=> "temp_pos_clock"."[$j:$j]",
							k.$suffix	=> "temp_neg_clock"."[$j:$j]",
							c		=> "temp_pos_clock"."[$j:$j]",
							c.$suffix	=> "temp_neg_clock"."[$j:$j]",
							w.$suffix	=> "${qdrii_pin_prefix}wpsn_$j"."_$i",
							r.$suffix	=> "${qdrii_pin_prefix}rpsn_$j"."_$i",
							doff.$suffix	=>  "$std_logic1",
							q 		=> "undelayed_${qdrii_pin_prefix}q$k",
							cq		=> "${qdrii_pin_prefix}cq$k"."[0:0]",
							cq.$suffix	=> "${qdrii_pin_prefix}cqn$k"."[0:0]",
						},
						parameter_map 	=>
						{
							addr_bits	=> $memory_address_width ,
							data_bits	=> $mem_dq_per_dqs,
							latency   => $temp_latency,
							burst_mode => $burst_mode,
							mem_sizes	=> $mem_sizes,
						},
					}),
				);
	
			}	else {
				$module->add_contents
				(
					e_comment->new({comment => "Instantiate Specific QDRII Memory"}),
					e_blind_instance->new
					({
						name 		=> "qdrii_memory_inst_$j"."_$i",
						module 		=> $memory_component_name,
						in_port_map 	=>
						{
							D 		=> "${qdrii_pin_prefix}d$k",
							SA 		=> "${qdrii_pin_prefix}a_$j"."_$i",
							BW.$suffix 	=> "${qdrii_pin_prefix}bwsn_$j"."_$i",
							K		=> "temp_pos_clock"."[$j:$j]",
							K.$suffix	=> "temp_neg_clock"."[$j:$j]",
							C		=> "temp_pos_clock"."[$j:$j]",
							C.$suffix	=> "temp_neg_clock"."[$j:$j]",
							W.$suffix	=> "${qdrii_pin_prefix}wpsn_$j"."_$i",
							R.$suffix	=> "${qdrii_pin_prefix}rpsn_$j"."_$i",
							DOFF.$suffix	=>  "$std_logic1",
						########DOFF_N  => "open",
						},
						out_port_map	=>
						{
							Q 		=> "undelayed_${qdrii_pin_prefix}q$k",
							CQ		=> "${qdrii_pin_prefix}cq$k"."[0:0]",
							CQ.$suffix	=> "${qdrii_pin_prefix}cqn$k"."[0:0]",
						},
						parameter_map 	=>
						{
							addr_bits	=> $memory_address_width ,
							data_bits	=> $mem_dq_per_dqs,
							mem_sizes	=> $mem_sizes,
						},
					}),
				);
			}



		}
	}
}else{
	if (${memory_component_name} eq "qdrii_model")
	{
		$module->add_contents
		(
			e_comment->new({comment => "Instantiate Generic QDRII Memory"}),
			e_memory->new
			({
				name 		=> "qdrii_memory_inst",
				module 		=> $memory_component_name,
				port_map 	=>
				{
					d 		=> "${qdrii_pin_prefix}d",
					sa 		=> "${qdrii_pin_prefix}a",
					bw.$suffix 	=> "${qdrii_pin_prefix}bwsn",
					k		=> "temp_pos_clock"."[0:0]",
					k.$suffix	=> "temp_neg_clock"."[0:0]",
					c		=> "temp_pos_clock"."[0:0]",
					c.$suffix	=> "temp_neg_clock"."[0:0]",
					w.$suffix	=> "${qdrii_pin_prefix}wpsn",
					r.$suffix	=> "${qdrii_pin_prefix}rpsn",
					doff.$suffix	=>  "$std_logic1",
					q	 	=> "undelayed_${qdrii_pin_prefix}q",
					cq		=> "${qdrii_pin_prefix}cq[0:0]",
					cq.$suffix	=> "${qdrii_pin_prefix}cqn[0:0]",
				},
				parameter_map 	=>
				{
					addr_bits	=> $memory_address_width ,
					data_bits	=> $mem_dq_per_dqs,
							latency   => $temp_latency,
							burst_mode => $burst_mode,
				    
				    mem_sizes	=> $mem_sizes,
	
				},
			}),
		);
	} else {
	
		$module->add_contents
		(
			e_comment->new({comment => "Instantiate Specific QDRII Memory"}),
			e_blind_instance->new
			({
				name 		=> "qdrii_memory_inst",
				module 		=> $memory_component_name,
				in_port_map 	=>
				{
					D 		=> "${qdrii_pin_prefix}d",
					SA 		=> "${qdrii_pin_prefix}a",
					BW.$suffix 	=> "${qdrii_pin_prefix}bwsn",
					K		=> "temp_pos_clock"."[0:0]",
					K.$suffix	=> "temp_neg_clock"."[0:0]",
					C		=> "temp_pos_clock"."[0:0]",
					C.$suffix	=> "temp_neg_clock"."[0:0]",
					W.$suffix	=> "${qdrii_pin_prefix}wpsn",
					R.$suffix	=> "${qdrii_pin_prefix}rpsn",
					DOFF.$suffix	=>  "$std_logic1",
				},
				out_port_map	=>
				{
					Q	 	=> "undelayed_${qdrii_pin_prefix}q",
					CQ		=> "${qdrii_pin_prefix}cq[0:0]",
					CQ.$suffix	=> "${qdrii_pin_prefix}cqn[0:0]",
				},
				parameter_map 	=>
				{
					addr_bits	=> $memory_address_width ,
					data_bits	=> $mem_dq_per_dqs,
					mem_sizes	=> $mem_sizes,
					# bwsn_size	=> $bwsn_size,
				},
			}),
		);
	}

}
#########################################################################################################################################################
	$module->add_contents
	(
	    e_clk->add({clk => "clock_source",
		    	      ns_period => $clock_period}),
	                      #clk_speed_in_mhz => $CLOCK_FREQ_IN_MHZ}),
            e_reset->add({reset => "system_reset_n",
                              clk_speed_in_mhz => 10,}),
            e_process->new
	    ({
		clock	=> "clock_source",
		reset	=> "system_reset_n",
		contents	=>
		[
			e_if->new
			({
			    condition	=> "test_complete",
			    then	=>
			    [
				e_if->new
				({
					condition	=> "(!fail_permanent) &&  (training_done) && (!training_incorrect) && (!training_pattern_not_found)",
					then		=>
					[
						e_testbench->new({display =>"          --- SIMULATION PASSED --- ",severity_level => "FAILURE"}),
					],
					else		=>
					[
						e_testbench->new({display =>"          --- SIMULATION FAILED --- ",severity_level => "FAILURE"}),
					],
				}),
			    ],
			}),
		],
	    }),
        );

#################################################################################################################################################################

$project->output();

}

1;



