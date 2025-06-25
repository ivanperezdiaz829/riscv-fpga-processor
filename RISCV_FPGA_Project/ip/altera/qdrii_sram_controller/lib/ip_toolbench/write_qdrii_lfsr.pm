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
#  File         : $RCSfile: write_qdrii_lfsr.pm,v $
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

my $data_width;
my $lfsr = "example_lfsr";
my $postfix;
my $flag;
my @ports_name = ("clk","reset_n","enable","pause","load","rand","seed","data");
my @ports_dir = ("input","input","input","input","input","input","input","output");
my @ports_width;
#my @lfsr_funcs;
my @lfsr_func;
my $post_title = "An $data_width bit LFSR";
my @assign_name;
my @func;
my $num_chips_wide;
my $num_chips_deep;
my $deep;
sub set_funcs{
	my $var = shift;
	# print "\n$var\n";
	@func = (1) if($var == 1);#1
	@func = (2, 1) if($var == 2);
	@func = (3, 2) if($var == 3);
	@func = (4, 3) if($var == 4);
	@func = (5, 4, 3, 1) if($var == 5);
	@func = (6, 5, 3, 2) if($var == 6);
	@func = (7, 6, 5, 4, 3, 2) if($var == 7);
	@func = (8, 6, 5, 2) if($var == 8);
	@func = (9, 8, 7, 6, 5, 4, 3, 1) if($var == 9);
	@func = (10, 9, 8, 6, 5, 4, 3, 2) if($var == 10);
	@func = (11, 10, 9, 5, 3, 1) if($var == 11);
	@func = (12, 11, 10, 9, 8, 4) if($var == 12);
	@func = (13, 12, 11, 6, 4, 3) if($var == 13);
	@func = (14, 13, 10, 9, 7, 1) if($var == 14);
	@func = (15, 14, 13, 9, 8, 4) if($var == 15);
	@func = (16, 14, 13, 10, 8, 5, 4, 2) if($var == 16);
	@func = (17, 16, 15, 14, 13, 9, 8, 7, 5, 3) if($var == 17);
	@func = (18, 17, 15, 14, 13, 10, 9, 5) if($var == 18);
	@func = (19, 17, 16, 15, 14, 12, 10, 9, 6, 4) if($var == 19);
	@func = (20, 19, 17, 15, 12, 10, 6, 4) if($var == 20);
	@func = (21, 20, 19, 17, 15, 12, 10, 6, 4) if($var == 21);
	return @func;
}


sub gen_lfsr{
#####   Parameters declaration  ######
my $family = $gFAMILY;
my $mem_dq_per_dqs = $gMEM_DQ_PER_DQS;
my $local_data_bits = $gLOCAL_DATA_BITS;
my $memory_address_width = $gMEMORY_ADDRESS_WIDTH;
my $delay_chain = $gDELAY_CHAIN;
my $burst_mode = $gMEMORY_BURST_LENGTH;
my $avl_data_width_multiply = $gAVL_DATA_WIDTH_MULTIPLY;
my $is_busrt4_narrow = $gIS_BURST4_NARROW;
$num_chips_wide = $gNUM_CHIPS_WIDE;
$num_chips_deep = $gNUM_CHIPS_DEEP;
$deep;
if($num_chips_deep > 1){
	$deep = 1;
}else{
	$deep = 0;
}
#####   End Parameters declaration  ######
	for(my $i = 0; $i < 3; $i++){
		if( $i == 0)
		{
			$data_width = 8;
			@ports_width = (1,1,1,1,1,1,$data_width,$data_width);
			@lfsr_func = (8,6,5,2);
			$postfix = $lfsr.$data_width;
			$flag = 0;
			&write_qdrii_lfsr();
		}
		if( $i == 1)
		{
			$data_width = 18;
			@ports_width = (1,1,1,1,1,1,$data_width,$data_width);
			@lfsr_func = &set_funcs(18);#$lfsr_funcs[17];
			$postfix = $lfsr.$data_width;
			$flag = 0;
			&write_qdrii_lfsr();
#			print "local_data_bits $local_data_bits -- avl_data_width_multiply $avl_data_width_multiply\n";
			$data_width = (($local_data_bits) % 18);#$mem_dq_per_dqs
			if($data_width > 0){
				@ports_width = (1,1,1,1,1,1,$data_width,$data_width);
				@lfsr_func = &set_funcs($data_width);#$lfsr_funcs[$data_width-1];
				$postfix = $lfsr.$data_width;
				$flag = 0;
				&write_qdrii_lfsr();
			}
		}
		if( $i == 2)
		{
#			$data_width = ($memory_address_width + $is_busrt4_narrow + $deep);
			$data_width = ($memory_address_width  + $deep);
			@ports_width = (1,1,1,1,1,1,$data_width,$data_width);
#			@lfsr_func = &set_funcs(($memory_address_width + $is_busrt4_narrow + $deep));#(20, 19, 17, 15, 12, 10, 6, 4);
			@lfsr_func = &set_funcs(($memory_address_width  + $deep));#(20, 19, 17, 15, 12, 10, 6, 4);
			$postfix = $lfsr.$data_width;
			$flag = 1;
			&write_qdrii_lfsr();
		}
	}
}

sub getValue{
	my $in = shift;
	#my $inLen = shift;
	my $bool = 0;
	
	for(my $l = 0 ; $l < scalar(@lfsr_func); $l++){
		if($in == @lfsr_func[$l]){$bool = 1}
	}
	return $bool;
}

sub write_qdrii_lfsr
{
my $mem_type = $gMEM_TYPE;
if ($mem_type =~ m/_/) {
$mem_type = $`;
}
my $header_title = "QDRII Controller ".$postfix;
my $header_filename = $postfix;
my $header_revision = "V" . $gWIZARD_VERSION;
my $header_abstract = "This file contains $post_title for the QDRII Controller.";

#####   Parameters declaration  ######
my $top = e_module->new({name => $postfix});
my $project = e_project->new({top => $top, language => $language,__system_directory =>$output_directory, timescale => "1ps / 1ps"});
my $module = $project->top();

$module->vhdl_libraries()->{altera_mf} = all;



######################################################################################################################################################################
	$module->comment
	(
		"------------------------------------------------------------------------------\n
		 This confidential and proprietary software may be used only as authorized by\n	 a licensing agreement from Altera Corporation.\n\n
		 (C) COPYRIGHT 2005 ALTERA CORPORATION\n ALL RIGHTS RESERVED\n\n
		 The entire notice above must be reproduced on all authorized copies and any\n such reproduction must be pursuant to a licensing agreement from Altera.\n\n
		 Title        : $header_title\n
		 Project      : $project_title\n\n\n
		 File         : $header_filename\n\n
		 Revision     : $header_revision\n\n
		 Abstract:\n $header_abstract\n\n
		----------------------------------------------------------------------------------\n"
	);
#####################################################################################################################################################################

for (my $j = 0; $j < scalar(@ports_name); $j++){
	$module->add_contents
	 (
	 #####	Ports declaration#	######
		 e_port->new({name => @ports_name[$j],direction => @ports_dir[$j], width => @ports_width[$j]}),
	 );
}
#print "\n------------ $j \n";

#####################################################################################################################################################################

$module->add_contents
(
 #####	Signals declaration#	######
	 e_signal->new({name => lfsr_data , width => $data_width,export => 0, never_export => 1}),
	 e_signal->new({name => ONE,width => 1,export => 0, never_export => 1}),
	 e_signal->new({name => ZERO,width => 1,export => 0, never_export => 1}),
 );

######################################################################################################################################################################
for (my $y = scalar(@assign_name); $y >= 0; $y--){pop @assign_name;}
my @test_array;
for (my $k = $data_width -1; $k >= 0;$k--){

	if($k > 0){
		my $value = getValue($k,scalar(@lfsr_func));
		if($value == 1){
			push @assign_name, e_assign->new({lhs => "lfsr_data[$k]", rhs => "(lfsr_data[".($k-1)."] ^ lfsr_data[".($data_width - 1)."])"});
		}else
		{
			push @assign_name, e_assign->new({lhs => "lfsr_data[$k]", rhs => "lfsr_data[".($k-1)."]"});
		}
	}
	elsif($k == 0)
	{
		push @assign_name, e_assign->new({lhs => "lfsr_data[$k]", rhs => "lfsr_data[".($data_width - 1)."]"});
	}
}

######################################################################################################################################################################

$module->add_contents
(
 #####	Module Body ######
 	e_assign->new({lhs => "ONE",rhs => "1"}),
	e_assign->new({lhs => "ZERO",rhs => "0"}),
	
	e_assign->new({lhs => "data",rhs => "lfsr_data"}),
	
	e_process->new
	({
		clock			=> "clk",
		reset			=> "reset_n",
		_asynchronous_contents	=>
		[e_assign->new({lhs => "lfsr_data",rhs => "seed"})],
		_contents	=>
		[
			e_if->new
			({
				condition	=> "(enable == ZERO)",
				then		=>
				[e_assign->new({lhs => "lfsr_data",rhs => "seed"})], #e_parameter->new({name => "seed",default => 150, vhdl_type => "integer"})
				else		=>
				[
					e_if->new
					({
						condition	=> "(load == ONE)",
						then		=>
						[e_assign->new({lhs => "lfsr_data",rhs => "data"})],
						else		=>
						[
							e_if->new
							({
								condition	=> "(rand == ZERO)",
								then		=>
								[
									e_assign->new({lhs => "lfsr_data",rhs => "(lfsr_data + ONE)"}),
									e_if->new
									({
										condition	=> "(pause == ONE)",
										then		=>
										[e_assign->new({lhs => "lfsr_data",rhs => "lfsr_data"})],
									}),
								],
								else		=>
								[
									e_if->new
									({
										condition	=> "(pause == ZERO)",
										then		=>
										[
											#e_assign->new({lhs => "@assign_name", rhs => "@assignments"})
											@assign_name,
										],
									}),
								],
							}),
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
