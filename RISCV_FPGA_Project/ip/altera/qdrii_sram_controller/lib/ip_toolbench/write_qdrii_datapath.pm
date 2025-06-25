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
#  File         : $RCSfile: write_qdrii_datapath.pm,v $
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


sub write_qdrii_datapath
{
my $mem_type = $gMEM_TYPE;
my $top = e_module->new({name => $gWRAPPER_NAME."_auk_${mem_type}_datapath"});#, output_file => 'd:/OFadeyi/DATA_PATH/temp_gen/'});
my $project = e_project->new({top => $top, language => $language,__system_directory =>$output_directory,timescale => "1ps / 1ps"});#'temp_gen'});
my $module = $project->top();



my $header_title = "Datapath for the Altera QDRII SDRAM Controller";
my $project_title = "QDRII SDRAM Controller";
my $header_filename = $gWRAPPER_NAME . "_auk_${mem_type}_datapath" . $file_ext;
my $header_revision = "V" . $gWIZARD_VERSION;
my $header_abstract = "This file contains the datapath for the QDRII SDRAM Controller";

my $mem_dq_per_dqs = $gMEM_DQ_PER_DQS;
my $num_clock_pairs = $gNUM_OUTPUT_CLOCKS;
my $mem_num_devices = $gMEM_NUM_DEVICES;
my $num_pipeline_addr_cmd_stages = $gPIPELINE_ADDRESS_COMMAND;
my $num_pipeline_wdata_stages = $gPIPELINE_ADDRESS_COMMAND;
my $num_pipeline_rdata_stages = $gPIPELINE_READ_DATA;

my $burst_mode	= $gBURST_MODE;
my $device_clk = "clk";
my $family = $gFAMILY;
my $memory_data_width = $gMEMORY_DATA_WIDTH;
my $memory_address_width = $gMEMORY_ADDRESS_WIDTH;
my $local_data_bits = $gLOCAL_DATA_BITS;
my $avl_data_width_multiply = $gAVL_DATA_WIDTH_MULTIPLY;
my $bwsn_width;
my $use_dqs_for_read = $gUSE_DQS_FOR_READ;
my $is_busrt4_narrow = $gIS_BURST4_NARROW;
my $ddio_memory_clocks = $gDDIO_MEMORY_CLOCKS;

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
my $family = $gFAMILY;
my @stratixii;
my %stratixii;
my @stratixii_list;
my $qdrii_pin_prefix = $gQDRII_PIN_PREFIX;

my $clock_pos_pin_name = $qdrii_pin_prefix . "k";
my $clock_neg_pin_name = $qdrii_pin_prefix . "kn";


my $num_chips_wide = $gNUM_CHIPS_WIDE;
my $num_chips_deep = $gNUM_CHIPS_DEEP;
my @addr_wrapper;
my %addr_wrapper;
my @addr_wrapper_list;
my $deep;
if($num_chips_deep > 1){
	$deep = 1;
}else{
	$deep = 0;
}
my @stratixii_in;
my %stratixii_in;
my @stratixii_in_list;
my @stratixii_out;
my %stratixii_out;
my @stratixii_out_list;
my @stratixii_inout;
my %stratixii_inout;
my @stratixii_inout_list;
my @resynch_ports_in;
my %resynch_ports_in;
my @resynch_ports_in_list;
my @resynch_ports_out;
my %resynch_ports_out;
my @resynch_ports_out_list;
my $resynch_type = $gRESYNCH_TYPE;
my $test = $gTRAIN_MODE;
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
		 Device Family                      : $gFAMILY\n
		 Control Interface Data Width       : $local_data_bits\n
		 QDRII Interface Data Width	     : $mem_dq_per_dqs\n
		 QDRII Interface Address Width	     : $memory_address_width.\n
		 Number Memory Clock Pairs          : $num_clock_pairs\n
		 Positive Clock Signal Name         : $clock_pos_pin_name\n
		 Negative Clock Signal Name         : $clock_neg_pin_name\n
		 Address and Command Pipeline Depth : $num_pipeline_addr_cmd_stages\n
		 Write Data Pipeline Depth          : $num_pipeline_wdata_stages\n
		 Read Data Pipeline Depth           : $num_pipeline_rdata_stages\n
		 Burst Mode	                     : $burst_mode\n
		 ----------------------------------------------------------------------------------\n",
	);
######################################################################################################################################################################
	$module->add_contents
	(
	#####	Ports declaration#	######
		e_port->new({name => "clk",direction => "input"}),
		e_port->new({name => "reset_n",direction => "input"}),
		e_port->new({name => "write_clk",direction => "input"}),
#		e_port->new({name => $clock_pos_pin_name,direction => "output", width => $num_clock_pairs,declare_one_bit_as_std_logic_vector => 1}),
#		e_port->new({name => $clock_neg_pin_name,direction => "output", width => $num_clock_pairs,declare_one_bit_as_std_logic_vector => 1}),
#
#	##Addr & Cmd Output Reg input and output signal
#		e_port->new({name => "control_rpsn",direction => "input", width => 1}),
#		e_port->new({name => "control_wpsn",direction => "input", width => 1}),
#		e_port->new({name => "control_bwsn",direction => "input", width => $bwsn_width * 2 * $num_chips_wide}),
#		e_port->new({name => "control_a_wr",direction => "input", width => $memory_address_width + $deep,declare_one_bit_as_std_logic_vector => 0}),
#		e_port->new({name => "control_a_rd",direction => "input", width => $memory_address_width + $deep,declare_one_bit_as_std_logic_vector => 0}),
#
#	##Write Data Path input and output signal
#		e_port->new({name => "control_wdata" ,direction => "input" , width => $memory_data_width * 2}),

	##Read Data Path input and output signal
		e_comment->new({comment => "\n"}),
	);
	if ($ddio_memory_clocks eq "true") {
		$module->add_contents
		(
			#####   Internal signal    ######
			e_port->new({name => $clock_pos_pin_name,direction => "output", width => $num_clock_pairs,declare_one_bit_as_std_logic_vector => 1}),
			e_port->new({name => $clock_neg_pin_name,direction => "output", width => $num_clock_pairs,declare_one_bit_as_std_logic_vector => 1}),
		);
	}	
               
                 
if(($num_chips_deep > 1) || ($num_chips_wide > 1))
{
	for($j = 0; $j < $num_chips_wide; $j++){
    	for($i = 0; $i < $num_chips_deep; $i++){                                               

            $module->add_contents
            (
            e_port->new({name => "control_rpsn_$j"."_$i",direction => "input", width => 1}),
        	e_port->new({name => "control_wpsn_$j"."_$i",direction => "input", width => 1}),
 
    		e_port->new({name => "control_bwsn_$j"."_$i",direction => "input", width => $bwsn_width * 2 * $num_chips_wide}),
    		e_port->new({name => "control_a_wr_$j"."_$i",direction => "input", width => $memory_address_width + $deep,declare_one_bit_as_std_logic_vector => 0}),
    		e_port->new({name => "control_a_rd_$j"."_$i",direction => "input", width => $memory_address_width + $deep,declare_one_bit_as_std_logic_vector => 0}),
    
    	##Write Data Path input and output signal
    		e_port->new({name => "control_wdata" ,direction => "input" , width => $memory_data_width * 2}),
			e_port->new({name => "${qdrii_pin_prefix}rpsn_$j"."_$i",direction => "output", width => 1}),
			e_port->new({name => "${qdrii_pin_prefix}wpsn_$j"."_$i",direction => "output", width => 1}),
			e_port->new({name => "${qdrii_pin_prefix}bwsn_$j"."_$i",direction => "output", width => $bwsn_width}),
			e_port->new({name => "${qdrii_pin_prefix}a_$j"."_$i",direction => "output", width => $memory_address_width,declare_one_bit_as_std_logic_vector => 0}),

  			e_comment->new({comment => "\nInstantiating the address & command output register module number $j of column $i\n"}),
				e_blind_instance->new
				 ({
					 name 		=> "qdrii_addr_cmd_output_$j"."_$i",
					 module 	=> $gWRAPPER_NAME."_auk_${mem_type}_addr_cmd_reg",
					 in_port_map 	=>
					 {
						 clk		        	=> "$device_clk",
						 reset_n                	=> "reset_n",
						 control_rpsn      		=> "control_rpsn_${j}_${i}",
						 control_wpsn      		=> "control_wpsn_${j}_${i}",
						 control_bwsn      		=> "control_bwsn_${j}_${i}[".(($bwsn_width * 2 * ($j + 1))  - 1).":".($bwsn_width * 2 * $j)."]",
						 control_addr_wr	     	=> "control_a_wr_${j}_${i}[".(($memory_address_width ) - 1).":0]",
						 control_addr_rd     		=> "control_a_rd_${j}_${i}[".(($memory_address_width ) - 1).":0]",
					 },
					 out_port_map	=>
					 {
						 "${qdrii_pin_prefix}rpsn"     	=> "${qdrii_pin_prefix}rpsn_${j}_${i}",
						 "${qdrii_pin_prefix}wpsn"     	=> "${qdrii_pin_prefix}wpsn_${j}_${i}",
						 "${qdrii_pin_prefix}bwsn" 	=> "${qdrii_pin_prefix}bwsn_${j}_${i}",
						 "${qdrii_pin_prefix}a"      	=> "${qdrii_pin_prefix}a_${j}_${i}",
					 },
				 }),
			);
		}
	}               
 }else{
    $module->add_contents
	(
    	##Addr & Cmd Output Reg input and output signal
    		e_port->new({name => "control_rpsn",direction => "input", width => 1}),
    		e_port->new({name => "control_wpsn",direction => "input", width => 1}),
    		e_port->new({name => "control_bwsn",direction => "input", width => $bwsn_width * 2 * $num_chips_wide}),
    		e_port->new({name => "control_a_wr",direction => "input", width => $memory_address_width + $deep,declare_one_bit_as_std_logic_vector => 0}),
    		e_port->new({name => "control_a_rd",direction => "input", width => $memory_address_width + $deep,declare_one_bit_as_std_logic_vector => 0}),
    
    	##Write Data Path input and output signal
    		e_port->new({name => "control_wdata" ,direction => "input" , width => $memory_data_width * 2}),
	
			e_port->new({name => "${qdrii_pin_prefix}rpsn",direction => "output", width => 1}),
		e_port->new({name => "${qdrii_pin_prefix}wpsn",direction => "output", width => 1}),
		e_port->new({name => "${qdrii_pin_prefix}bwsn",direction => "output", width => $bwsn_width}),
		e_port->new({name => "${qdrii_pin_prefix}a",direction => "output", width => $memory_address_width,declare_one_bit_as_std_logic_vector => 0}),

		e_comment->new({comment => "\nInstantiating the address & command output register module\n"}),
		e_blind_instance->new
		 ({
			 name 		=> "qdrii_addr_cmd_output",
			 module 	=> $gWRAPPER_NAME."_auk_${mem_type}_addr_cmd_reg",
			 in_port_map 	=>
			 {
				 clk		        	=> "$device_clk",
				 reset_n                	=> "reset_n",
				 control_rpsn      		=> "control_rpsn",
				 control_wpsn      		=> "control_wpsn",
				 control_bwsn      		=> "control_bwsn[".(($bwsn_width * 2 * ($j + 1))  - 1).":".($bwsn_width * 2 * $j)."]",
				 control_addr_wr	     	=> "control_a_wr[".(($memory_address_width ) - 1).":0]",
				 control_addr_rd     		=> "control_a_rd[".(($memory_address_width ) - 1).":0]",
			 },
			 out_port_map	=>
			 {
				 "${qdrii_pin_prefix}rpsn"     	=> "${qdrii_pin_prefix}rpsn",
				 "${qdrii_pin_prefix}wpsn"     	=> "${qdrii_pin_prefix}wpsn",
				 "${qdrii_pin_prefix}bwsn" 	=> "${qdrii_pin_prefix}bwsn",
				 "${qdrii_pin_prefix}a"      	=> "${qdrii_pin_prefix}a",
			 },
		 }),
	);

}              
               
	if(($family eq "Stratix II") and ($use_dqs_for_read eq "true"))
	{
		$module->add_contents
		(
			e_port->new({name => "dll_delay_ctrl",direction => "input", width => 6}),
		);
		$stratixii{'dll_delay_ctrl'} = "dll_delay_ctrl";
	}

	if((($use_dqs_for_read eq "false") and ($family eq "Stratix II")) or ($family eq "Stratix"))
	{
		$module->add_contents
		(
			e_port->new({name => "non_dqs_capture_clk",direction => "input", width => 1}),
		);
		$stratixii{'non_dqs_capture_clk'} = "non_dqs_capture_clk";
	}
######################################################################################################################################################################
if ($ddio_memory_clocks eq "true") {
	$module->add_contents
	(
		e_blind_instance->new
		({
			name 		=> "${mem_type}_clk_gen",
			module 		=> $gWRAPPER_NAME."_auk_${mem_type}_clk_gen",
			in_port_map 	=>
			{
				clk                     => "write_clk",
				reset_n                 => "reset_n",
			},
			out_port_map	=>
			{
				$clock_pos_pin_name     => $clock_pos_pin_name."[".($num_clock_pairs-1).":0]",
				$clock_neg_pin_name     => $clock_neg_pin_name."[".($num_clock_pairs-1).":0]",
			},
			std_logic_vector_signals  =>
			[
				$clock_pos_pin_name, $clock_neg_pin_name,
			]
		}),
	);
}
##################################################################################################################################################################

if($num_chips_wide > 1)
{
	for(my $k = 0; $k  < $num_chips_wide; $k++)
	{
		$stratixii_in{"${qdrii_pin_prefix}d_$k"} = "${qdrii_pin_prefix}d_$k";
		$module->add_contents(
		e_port->new({name => "${qdrii_pin_prefix}d_$k",direction => "output",width => $mem_dq_per_dqs}),);
	}
}else{
	$stratixii_in{"${qdrii_pin_prefix}d"} = "${qdrii_pin_prefix}d";
	$module->add_contents(
	e_port->new({name => "${qdrii_pin_prefix}d",direction => "output",width => $mem_dq_per_dqs}),);
}
@stratixii_in = %stratixii_in;
foreach my $param (@stratixii_in) {push (@stratixii_in_list, $param);}
my $j = 0;
if($num_chips_wide > 1)
{
for(my $k = 0; $k  < $num_chips_wide; $k++)
{
	 $module->add_contents
	 (
		e_blind_instance->new
		({
			name 		=> "${mem_type}_write_group_$k",
			module 		=> $gWRAPPER_NAME."_auk_${mem_type}_write_group",
			in_port_map 	=>
			{
				clk               	=> "clk",
				reset_n               	=> "reset_n",
				control_wdata     	=> "control_wdata[".((($mem_dq_per_dqs * 2) * ($k + 1) -1).":".($k * ($mem_dq_per_dqs * 2)))."]",
			},
			out_port_map	=>
			{
					"${qdrii_pin_prefix}d" 	=> "${qdrii_pin_prefix}d_$k",
				},
			}),
		  );
		  $j = $j + 2;
	}
}else{
	for(my $k = 0; $k  < $num_chips_wide; $k++)
	{
		 $module->add_contents
		 (
			e_blind_instance->new
			({
				name 		=> "${mem_type}_write_group_$k",
				module 		=> $gWRAPPER_NAME."_auk_${mem_type}_write_group",
				in_port_map 	=>
				{
					clk               	=> "clk",
					reset_n               	=> "reset_n",
					control_wdata     	=> "control_wdata[".((($mem_dq_per_dqs * 2) * ($k + 1) -1).":".($k * ($mem_dq_per_dqs * 2)))."]",
				},
				out_port_map	=>
				{
					"${qdrii_pin_prefix}d" 	=> "${qdrii_pin_prefix}d",
				},
			}),
		  );
		  $j = $j + 2;
	}
}
if($num_chips_wide > 1){
	for(my $k = 0; $k < $num_chips_wide; $k++)
	{
		$module->add_contents
		(
		##Read Data Path input and output signal
			e_port->new({name => "${qdrii_pin_prefix}q_$k" , direction => "input" , width => $mem_dq_per_dqs}),
			e_port->new({name => "captured_data_$k" , direction => "output" , width => $mem_dq_per_dqs * 2}),
			e_port->new({name => "capture_clock_$k", direction => "output", width => 1, declare_one_bit_as_std_logic_vector => 1}),
			e_port->new({name => "${qdrii_pin_prefix}cq_0" , direction => "inout" , width => 1,declare_one_bit_as_std_logic_vector => 1}),
		);
		$stratixii_out{"captured_data_$k"} = "captured_data_$k";
		$stratixii_out{"capture_clock_$k"} = "capture_clock_$k"."[0:0]";
		$stratixii{"${qdrii_pin_prefix}q_$k"} = "${qdrii_pin_prefix}q_$k";
		if(!((($use_dqs_for_read eq "false") and ($family eq "Stratix II")) or ($family eq "Stratix")))
		{
			$module->add_contents
			(
				##CQ/CQn Group input and output and internal signal
				e_port->new({name => "${qdrii_pin_prefix}cq_$k" , direction => "inout" , width => 1,declare_one_bit_as_std_logic_vector => 1}),
				e_port->new({name => "${qdrii_pin_prefix}cqn_$k" , direction => "inout" , width => 1,declare_one_bit_as_std_logic_vector => 1}),
			);
			$stratixii_inout{"${qdrii_pin_prefix}cq_$k"} = "${qdrii_pin_prefix}cq_$k"."[0:0]";
			$stratixii_inout{"${qdrii_pin_prefix}cqn_$k"} = "${qdrii_pin_prefix}cqn_$k"."[0:0]";
		}
	}
}else{
	$module->add_contents
	(
	##Read Data Path input and output signal
		e_port->new({name => "${qdrii_pin_prefix}q" , direction => "input" , width => $mem_dq_per_dqs}),
		e_port->new({name => "captured_data" , direction => "output" , width => $mem_dq_per_dqs * 2}),
		e_port->new({name => "capture_clock", direction => "output", width => 1, declare_one_bit_as_std_logic_vector => 1}),
		e_port->new({name => "${qdrii_pin_prefix}cq" , direction => "inout" , width => 1,declare_one_bit_as_std_logic_vector => 1}),
	);
	$stratixii_out{"captured_data"} = "captured_data";
	$stratixii_out{"capture_clock"} = "capture_clock"."[0:0]";
	$stratixii{"${qdrii_pin_prefix}q"} = "${qdrii_pin_prefix}q";
	if(!((($use_dqs_for_read eq "false") and ($family eq "Stratix II")) or ($family eq "Stratix")))
	{
		$module->add_contents
		(
			e_port->new({name => "${qdrii_pin_prefix}cq" , direction => "inout" , width => 1,declare_one_bit_as_std_logic_vector => 1}),
			e_port->new({name => "${qdrii_pin_prefix}cqn" , direction => "inout" , width => 1,declare_one_bit_as_std_logic_vector => 1}),
		);
		$stratixii_inout{"${qdrii_pin_prefix}cq"} = "${qdrii_pin_prefix}cq"."[0:0]";
		$stratixii_inout{"${qdrii_pin_prefix}cqn"} = "${qdrii_pin_prefix}cqn"."[0:0]";
	}
	# $captured_rdata .= "captured_rdata";
}

foreach my $par (@resynch_ports_out) {push (@resynch_ports_out_list, $par);}
@stratixii = %stratixii;
foreach my $param (@stratixii) {push (@stratixii_list, $param);}
@stratixii_out = %stratixii_out;
foreach my $params (@stratixii_out) {push (@stratixii_out_list, $params);}
@stratixii_inout = %stratixii_inout;
foreach my $var (@stratixii_inout) {push (@stratixii_inout_list, $var);}
$module->add_contents
(
	  e_blind_instance->new
	  ({
		  name 		=> "auk_${mem_type}_capture_group_wrapper",
		  module 	=> $gWRAPPER_NAME."_auk_${mem_type}_capture_group_wrapper",
		  in_port_map 	=>
		  {
			  reset_n              	=> "reset_n",
			  @stratixii		=> @stratixii_list,
		  },
		  out_port_map	=>
		  {
			  @stratixii_out	=> @stratixii_out_list,
		  },
		  inout_port_map	=>
		  {
			 @stratixii_inout	=> @stratixii_inout_list,
		  },
		  std_logic_vector_signals	=>	[@stratixii_inout_list,@stratixii_out_list],
	  }),
);

##################################################################################################################################################################
$project->output();
}

1;
#You're done.
