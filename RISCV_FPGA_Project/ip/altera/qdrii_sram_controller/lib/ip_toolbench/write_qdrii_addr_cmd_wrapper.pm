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
#  File         : $RCSfile: write_qdrii_addr_cmd_wrapper.pm,v $
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


sub write_qdrii_addr_cmd_wrapper
{
	
my $mem_type = $gMEM_TYPE;
my $top = e_module->new({name => $gWRAPPER_NAME."_auk_${mem_type}_addr_cmd_wrapper"});
my $project = e_project->new({top => $top, language => $language,__system_directory =>$output_directory , timescale => "1ps / 1ps"});
my $module = $project->top();
$module->vhdl_libraries()->{altera_mf} = all;
$module->vhdl_libraries()->{$gFAMILYlc} = all;



my $header_title = "QDRII Controller Address and Command Wrapper Module";
my $header_filename = $gWRAPPER_NAME . "_auk_${mem_type}_addr_cmd_wrapper" . $file_ext;
my $header_revision = "V" . $gWIZARD_VERSION;
my $header_abstract = "This file contains the output registers for the QDRII Controller.";

my $burst_mode = $gMEMORY_BURST_LENGTH;
my $device_clk = "clk";
my $device_clk_edge = "1";
my $device_clk_edge_s = "positive";
my $memory_data_width = $gMEMORY_DATA_WIDTH;
my $memory_address_width = $gMEMORY_ADDRESS_WIDTH;
my $qdrii_pin_prefix = $gQDRII_PIN_PREFIX;
my $is_busrt4_narrow = $gIS_BURST4_NARROW;


my $num_chips_wide = $gNUM_CHIPS_WIDE;
my $num_chips_deep = $gNUM_CHIPS_DEEP;
my $mem_dq_per_dqs = $gMEM_DQ_PER_DQS;
######################################################################################################################################################################
my $deep;
if($num_chips_deep > 1){
	$deep = 1;
}else{
	$deep = 0;
}

my $bwsn_width;
my $avl_data_width_multiply = $gAVL_DATA_WIDTH_MULTIPLY;
if($mem_dq_per_dqs <= 18)
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
		 Numbers of Chips in Parallel	: $num_chips_wide\n
		 Numbers of Chips in Serial	: $num_chips_deep\n
		 QDRII Interface Data Width	     : $memory_data_width\n
		------------------------------------------------------------------------------"
	);
######################################################################################################################################################################
	$module->add_contents
	( 
	#####	Ports declaration#	######
		e_port->new({name => "$device_clk",direction => "input"}),
		e_port->new({name => "reset_n",direction => "input"}),

	##Addr & Cmd Output Reg input and output signal
		e_port->new({name => "control_rpsn",direction => "input", width => 1}),
		e_port->new({name => "control_wpsn",direction => "input", width => 1}),
		e_port->new({name => "control_bwsn",direction => "input", width => $bwsn_width * 2 * $num_chips_wide}),
		e_port->new({name => "control_addr_wr",direction => "input", width => $memory_address_width + $deep,declare_one_bit_as_std_logic_vector => 0}),
		e_port->new({name => "control_addr_rd",direction => "input", width => $memory_address_width + $deep,declare_one_bit_as_std_logic_vector => 0}),
				
		# e_port->new({name => "${qdrii_pin_prefix}rpsn",direction => "output", width => 1}),
		# e_port->new({name => "${qdrii_pin_prefix}wpsn",direction => "output", width => 1}),
		# e_port->new({name => "${qdrii_pin_prefix}bwsn",direction => "output", width => $bwsn_width}),
		# e_port->new({name => "${qdrii_pin_prefix}a",direction => "output", width => $memory_address_width,declare_one_bit_as_std_logic_vector => 0}),
	##Internal signal
		# e_signal->new(["wpsn1",1,0,1]),
		# e_signal->new(["rpsn1",1,0,1]),
	);
######################################################################################################################################################################
if($num_chips_deep > 1){
	$module->add_contents
	(
		# e_signal->new(["wpsn2",1,0,1]),
		# e_signal->new(["rpsn2",1,0,1]),
		e_assign->new(["wpsn0", "(control_addr_wr[".(($memory_address_width + $deep) - 1)."]) || control_wpsn"]),
		e_assign->new(["wpsn1", "(~control_addr_wr[".(($memory_address_width + $deep) - 1)."]) || control_wpsn"]),
		e_assign->new(["rpsn0", "(control_addr_rd[".(($memory_address_width + $deep) - 1)."]) || control_rpsn"]),
		e_assign->new(["rpsn1", "(~control_addr_rd[".(($memory_address_width + $deep) - 1)."]) || control_rpsn"]),
	);
}else{
	$module->add_contents
	(
		e_signal->new(["wpsn",1,0,1]),
		e_signal->new(["rpsn",1,0,1]),
		e_assign->new(["wpsn", "control_wpsn"]),
		e_assign->new(["rpsn", "control_rpsn"]),
	);
}

######################################################################################################################################################################
my $i;
my $j;
my $k;
if(($num_chips_deep > 1) || ($num_chips_wide > 1))
{
	for($i = 0; $i < $num_chips_deep; $i++){
		if($num_chips_deep > 1)
		{
			$k = $i;
			$module->add_contents
			(	
				e_signal->new(["rpsn$i",1,0,1]),
				e_signal->new(["wpsn$i",1,0,1]),
			);
		}
		for($j = 0; $j < $num_chips_wide; $j++){
			$module->add_contents
			(
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
						 control_rpsn      		=> "rpsn$k",
						 control_wpsn      		=> "wpsn$k",
						 control_bwsn      		=> "control_bwsn[".(($bwsn_width * 2 * ($j + 1))  - 1).":".($bwsn_width * 2 * $j)."]",
						 control_addr_wr	     	=> "control_addr_wr[".(($memory_address_width ) - 1).":0]",
						 control_addr_rd     		=> "control_addr_rd[".(($memory_address_width ) - 1).":0]",
					 },
					 out_port_map	=>
					 {
						 "${qdrii_pin_prefix}rpsn"     	=> "${qdrii_pin_prefix}rpsn_$j"."_$i",
						 "${qdrii_pin_prefix}wpsn"     	=> "${qdrii_pin_prefix}wpsn_$j"."_$i",
						 "${qdrii_pin_prefix}bwsn" 	=> "${qdrii_pin_prefix}bwsn_$j"."_$i",
						 "${qdrii_pin_prefix}a"      	=> "${qdrii_pin_prefix}a_$j"."_$i",
					 },
				 }),
			);
		}
	}
}else{
	$module->add_contents
	(
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
				 control_rpsn      		=> "rpsn",
				 control_wpsn      		=> "wpsn",
				 control_bwsn      		=> "control_bwsn[".(($bwsn_width * 2 * ($j + 1))  - 1).":".($bwsn_width * 2 * $j)."]",
				 control_addr_wr	     	=> "control_addr_wr[".(($memory_address_width ) - 1).":0]",
				 control_addr_rd     		=> "control_addr_rd[".(($memory_address_width ) - 1).":0]",
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
##################################################################################################################################################################
$project->output();
}

1;
#You're done.
