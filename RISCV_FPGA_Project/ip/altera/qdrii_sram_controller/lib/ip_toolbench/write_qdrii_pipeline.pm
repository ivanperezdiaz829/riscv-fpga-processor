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
#  File         : $RCSfile: write_qdrii_pipeline.pm,v $
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


my $pipeline_width;
my $pipeline_depth;
my $postfix;
my $flag;
my $mem_num_devices;
my $mem_dq_per_dqs = $gMEM_DQ_PER_DQS;;
my $memory_address_width;
my $bwsn_width;
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

my $use_addr_as_cs;
my $avl_data_width_multiply;
my $is_busrt4_narrow;
my $deep;
my $num_chips_wide;
my $num_chips_deep;
my $local_data_bits;
my $memory_data_width;       
my $regression_test = $gREGRESSION_TEST;
sub gen_pipelines{
	$mem_num_devices = $gMEM_NUM_DEVICES;
	$mem_dq_per_dqs = $gMEM_DQ_PER_DQS;
	$memory_data_width = $gMEMORY_DATA_WIDTH;
	$memory_address_width = $gMEMORY_ADDRESS_WIDTH;
	$local_data_bits = $gLOCAL_DATA_BITS;
	$avl_data_width_multiply = $gAVL_DATA_WIDTH_MULTIPLY;
	my $delay_chain = $gDELAY_CHAIN;
	my $burst_mode = $gMEMORY_BURST_LENGTH;
	$is_busrt4_narrow = $gIS_BURST4_NARROW;
	$num_chips_wide = $gNUM_CHIPS_WIDE;
	$num_chips_deep = $gNUM_CHIPS_DEEP;

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



	for(my $i = 0; $i < 4; $i++){
		if( $i == 0)
		{
			if($num_chips_deep > 1){
				$deep = 1;
			}else{
				$deep = 0;
			}
			$pipeline_width = (($memory_address_width + $deep) + ($bwsn_width * 2) + 2 );
			$pipeline_depth = $gPIPELINE_ADDRESS_COMMAND;
			if($pipeline_depth > 0){
				$post_title = " Address and Command Pipeline Module";
				$postfix = "addr_cmd";
				$reset_value = "0";
				$flag = 1;
				$use_addr_as_cs = $gUSE_ADDR_AS_CS;
				&write_auk_qdrii_pipeline(); 
			}
#			$pipeline_width = 1;
#			$pipeline_depth = $gPIPELINE_ADDRESS_COMMAND;
#			if($pipeline_depth > 0){
#				$post_title = " Write Command Pipeline Module";
#				$postfix = "wpsn_cmd";
#				$reset_value = "0";
#				$flag = 0;
#				&write_auk_qdrii_pipeline(); 
#			}
#			if($pipeline_depth > 0){
#				$post_title = " Read Command Pipeline Module";
#				$postfix = "rpsn_cmd";
#				$reset_value = "0";
#				$flag = 0;
#				&write_auk_qdrii_pipeline(); 
#			}

		}
		if( $i == 1)
		{
			$pipeline_width = $memory_data_width * 2;#$mem_dq_per_dqs * 2;
			$pipeline_depth = $gPIPELINE_ADDRESS_COMMAND;
			if($pipeline_depth > 0){
				$post_title = " Write Data Pipeline Module";
				$postfix = "wdata";
				$reset_value = "0";
				$flag = 0;
				&write_auk_qdrii_pipeline();
			}
		}
		if( $i == 2)
		{
			$pipeline_width = $memory_data_width * 2;#(($mem_dq_per_dqs*2) * $num_chips_wide);
			$pipeline_depth = $gPIPELINE_READ_DATA;
			if($pipeline_depth > 0){
				$post_title = " Read Data Pipeline Module";
				$postfix = "rdata";
				$reset_value = "0";
				$flag = 0;
				&write_auk_qdrii_pipeline();
			}
		} 
		
		if( $i == 3)
		{
            if ($gREGRESSION_TEST eq "true")
            {
    			$pipeline_width = 1;
    			$pipeline_depth = 30; #prefix deley for the test_complete signal

    			$post_title = " Pipeline Module For The test_complete Signal";
    			$postfix = "test_complete";
    			$reset_value = "0";
    			$flag = 0;
    			&write_auk_qdrii_pipeline();
            }
		}
	}
}


sub write_auk_qdrii_pipeline
{
my $mem_type = $gMEM_TYPE;
# if ($mem_type =~ m/_/) {
# $mem_type = $`;
# }
my $header_title = "QDRII Controller".$post_title;
my $header_filename = $gWRAPPER_NAME . "_auk_${mem_type}_pipeline_".$postfix. $file_ext;
my $header_revision = "V" . $gWIZARD_VERSION;
my $header_abstract = "This file contains pipelining for the QDRII Controller.";
my $verilog_dq_io_instname;# = "\\g_datapath:\$i:g_ddr_io ";

#####   Parameters declaration  ######
my $top = e_module->new({name => $gWRAPPER_NAME . "_auk_${mem_type}_pipeline_".$postfix});
my $project = e_project->new({top => $top, language => $language,__system_directory =>$output_directory, timescale => "1ps / 1ps"});
my $module = $project->top();

my $data_width_zeros;
my $bswn_ones; my $bswn_zeros;
my $addr_ones; my $addr_zeros;

for($i = 0; $i < ($pipeline_width); $i++)
{ $data_width_zeros .= "0"; }
for($i = 0; $i < ($bwsn_width * 2 * $num_chips_wide); $i++)
{ $bswn_ones .= "1"; $bswn_zeros .= "0"; }
for($i = 0; $i < ($memory_address_width + $deep); $i++)
{ $addr_ones .= "1"; $addr_zeros .= "0"; }
$module->vhdl_libraries()->{altera_mf} = all;
######################################################################################################################################################################
	$module->comment
	(
		"------------------------------------------------------------------------------\n
		 Title        : $header_title\n
		 Project      : $project_title\n\n\n
		 File         : $header_filename\n\n
		 Revision     : $header_revision\n\n
		 Abstract:\n $header_abstract\n\n
		----------------------------------------------------------------------------------\n",
	);
#####################################################################################################################################################################
if(!$flag)
{
	$module->add_contents
	 (
	 #####	Ports declaration#	######
		 e_port->new({name => "clk",direction => "input"}),
		 e_port->new({name => "reset_n",direction => "input"}),
		 e_port->new({name => "pipeline_data_in",direction => "input", width => $pipeline_width}),
		 e_port->new({name => "pipeline_data_out",direction => "output", width => $pipeline_width}),
	);
	my $in;
	my $i = 0;
	#if($pipeline_depth > 0){
	for( $i = 1; $i < ($pipeline_depth+1); $i++){
		my $j = $i -1;
		if( $i == 1)
		{
			$in = "pipeline_data_in";
		}else
		{
			$in = "pipeline_data_r"."$j";
		}
		 $module->add_contents
		 (
			e_signal->new({name=>"pipeline_data_r"."$i",width=>"$pipeline_width",export=>0,never_export=>1}),
			e_register->new({
				q   		=> "pipeline_data_r"."$i",
				d   		=> $in,
				async_set   	=> "reset_n",
				#async_value 	=> "-1",
				async_value 	=> $pipeline_width."'b".$data_width_zeros,
				enable	    	=> 1,
			})
		 );
	}
	$module->add_contents
	(
		e_assign->new(["pipeline_data_out","pipeline_data_r".($i-1)]),
	);
}else
{

	$module->add_contents
	 (
	 #####	Ports declaration#	######
		 e_port->new({name => "clk",direction => "input"}),
		 e_port->new({name => "reset_n",direction => "input"}),
		 e_port->new({name => "pipeline_rpsn_in",direction => "input", width => 1}),
		 e_port->new({name => "pipeline_wpsn_in",direction => "input", width => 1}),
		 e_port->new({name => "pipeline_bwsn_in",direction => "input", width => $bwsn_width * 2 * $num_chips_wide}),
		 e_port->new({name => "pipeline_addr_wr_in",direction => "input", width => $memory_address_width + $deep}),
		 e_port->new({name => "pipeline_addr_rd_in",direction => "input", width => $memory_address_width + $deep}),
		 e_port->new({name => "pipeline_rpsn_out",direction => "output", width => 1}),
		 e_port->new({name => "pipeline_wpsn_out",direction => "output", width => 1}),
		 e_port->new({name => "pipeline_bwsn_out",direction => "output", width => $bwsn_width * 2 * $num_chips_wide}),
		 e_port->new({name => "pipeline_addr_wr_out",direction => "output", width => $memory_address_width + $deep}),
		 e_port->new({name => "pipeline_addr_rd_out",direction => "output", width => $memory_address_width + $deep}),

		 e_signal->new(["ONE",1,0,1]),
		 e_signal->new(["ONES",$bwsn_width * 2]),
		 e_assign->new(["ONE",1]),
		 e_assign->new(["ONES",($bwsn_width * 2)."'b1111"]),
	);
	my $rpsn_in;
	my $wpsn_in;
	my $bwsn_in;
	my $addr_wr_in;
	my $addr_rd_in;
	my $i = 0;
	for( $i = 1; $i < ($pipeline_depth+1); $i++){
		my $j = $i -1;
		if( $i == 1)
		{
			$rpsn_in = "pipeline_rpsn_in";
			$wpsn_in = "pipeline_wpsn_in";
			$bwsn_in = "pipeline_bwsn_in";
			$addr_wr_in = "pipeline_addr_wr_in";
			$addr_rd_in = "pipeline_addr_rd_in";
		}else
		{
			$rpsn_in = "pipeline_rpsn_r"."$j";
			$wpsn_in = "pipeline_wpsn_r"."$j";
			$bwsn_in = "pipeline_bwsn_r"."$j";
			$addr_wr_in = "pipeline_addr_wr_r"."$j";
			$addr_rd_in = "pipeline_addr_rd_r"."$j";
		}
		 $module->add_contents
		 (
			e_signal->new({name=>"pipeline_rpsn_r"."$i",width => 1,export=>0,never_export=>1}),
			e_register->new({
				q   		=> "pipeline_rpsn_r"."$i",
				d   		=> $rpsn_in,
				async_set   	=> "reset_n",
				async_value 	=> "ONE",
				#async_value 	=> $reset_value,
				enable	    	=> 1,
			})
		 );
		 $module->add_contents
		 (
			e_signal->new({name=>"pipeline_wpsn_r"."$i",width => 1,export=>0,never_export=>1}),
			e_register->new({
				q   		=> "pipeline_wpsn_r"."$i",
				d   		=> $wpsn_in,
				async_set   	=> "reset_n",
				async_value 	=> "ONE",
				#async_value 	=> $reset_value,
				enable	    	=> 1,
			})
		 );
		 $module->add_contents
		 (
			e_signal->new({name=>"pipeline_bwsn_r"."$i",width => $bwsn_width * 2 * $num_chips_wide ,export=>0,never_export=>1}),
			e_register->new({
				q   		=> "pipeline_bwsn_r"."$i",
				d   		=> $bwsn_in,
				async_set   	=> "reset_n",
				async_value 	=> ($bwsn_width * 2 * $num_chips_wide)."'b".$bswn_ones,
				#async_value 	=> $reset_value,
				enable	    	=> 1,
			})
		 );
		 $module->add_contents
		 (
			e_signal->new({name=>"pipeline_addr_wr_r"."$i",width => $memory_address_width + $deep,export=>0,never_export=>1}),
			e_register->new({
				q   		=> "pipeline_addr_wr_r"."$i",
				d   		=> $addr_wr_in,
				async_set   	=> "reset_n",
				#async_value 	=> "-1",
				async_value 	=> ($memory_address_width + $deep)."'b".$addr_zeros,
				enable	    	=> 1,
			}),
			e_signal->new({name=>"pipeline_addr_rd_r"."$i",width => $memory_address_width + $deep,export=>0,never_export=>1}),
			e_register->new({
				q   		=> "pipeline_addr_rd_r"."$i",
				d   		=> $addr_rd_in,
				async_set   	=> "reset_n",
				#async_value 	=> "-1",
				async_value 	=> ($memory_address_width + $deep)."'b".$addr_zeros,
				enable	    	=> 1,
			})
		 );
	}
	$module->add_contents
	(
		e_assign->new(["pipeline_rpsn_out","pipeline_rpsn_r".($i-1)]),
		e_assign->new(["pipeline_wpsn_out","pipeline_wpsn_r".($i-1)]),
		e_assign->new(["pipeline_bwsn_out","pipeline_bwsn_r".($i-1)]),
		e_assign->new(["pipeline_addr_wr_out","pipeline_addr_wr_r".($i-1)]),
		e_assign->new(["pipeline_addr_rd_out","pipeline_addr_rd_r".($i-1)]),
	);
}

######################################################################################################################################################################

$project->output();
}
1;
#You're done.
