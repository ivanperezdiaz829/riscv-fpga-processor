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
#  Title        : Pipeline and resynchronisation group
#  Project      : QDRII SRAM Controller
#
#
#  File         : $RCSfile: write_qdrii_pipe_resynch_wrapper.pm,v $
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


sub write_qdrii_pipe_resynch_wrapper
{
my $mem_type = $gMEM_TYPE;
my $top = e_module->new({name => $gWRAPPER_NAME."_auk_${mem_type}_pipe_resynch_wrapper"});
my $project = e_project->new({top => $top, language => $language,__system_directory =>$output_directory,timescale => "1ps / 1ps"});
my $module = $project->top();
my $header_title = "Resynch and Pipeline wrapper for the Altera QDRII SDRAM Controller";
my $project_title = "QDRII SDRAM Controller";
my $header_filename = $gWRAPPER_NAME . "_auk_${mem_type}_pipe_resynch_wrapper" . $file_ext;
my $header_revision = "V" . $gWIZARD_VERSION;
my $header_abstract = "This file contains the Resynch Group, the optional Pipeline modules and the Traing Block for the QDRII SDRAM Controller";
my $num_clock_pairs = $gNUM_OUTPUT_CLOCKS;

my $device_clk = "write_clk";
my $family = $gFAMILY;
my $memory_data_width = $gMEMORY_DATA_WIDTH;
my $memory_address_width = $gMEMORY_ADDRESS_WIDTH;
my $local_data_bits = $gLOCAL_DATA_BITS;
my $delay_chain = $gDELAY_CHAIN;
my $burst_mode = $gMEMORY_BURST_LENGTH;
my $avl_data_width_multiply = $gAVL_DATA_WIDTH_MULTIPLY;
my $mem_dq_per_dqs = $gMEM_DQ_PER_DQS;
my $num_pipeline_addr_cmd_stages = $gPIPELINE_ADDRESS_COMMAND;
my $num_pipeline_rdata_stages = $gPIPELINE_READ_DATA;
my $read_valid_cycle = 5 + $num_pipeline_rdata_stages + $num_pipeline_addr_cmd_stages;
my $bwsn_width;
my $is_busrt4_narrow = $gIS_BURST4_NARROW;
my $use_dqs_for_read = $gUSE_DQS_FOR_READ;
my $qdrii_pin_prefix = $gQDRII_PIN_PREFIX;
my $clock_pos_pin_name = $qdrii_pin_prefix . "k";
my $clock_neg_pin_name = $qdrii_pin_prefix . "kn";

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

my %in_param;
my @in_param;
my @addr_wrapper;
my %addr_wrapper;
my @addr_wrapper_list;
my @stratixii_inout;
my %stratixii_inout;
my @stratixii_inout_list;
my @resynch_ports_in;
my %resynch_ports_in;
my @resynch_ports_in_list;
my @resynch_ports_out;
my %resynch_ports_out;
my @resynch_ports_out_list;
my $num_chips_wide = $gNUM_CHIPS_WIDE;
my $num_chips_deep = $gNUM_CHIPS_DEEP;
my $deep;
if($num_chips_deep > 1){
	$deep = 1;
}else{
	$deep = 0;
}
my $test = $gTRAIN_MODE;
my $resynched_rdata;
######################################################################################################################################################################
	$module->comment
	(
		"------------------------------------------------------------------------------\n
		 Title        : $header_title\n
		 Project      : $project_title\n
		 File         : $header_filename\n\n
		 Revision     : $header_revision\n\n
		 Abstract:\n$header_abstract\n\n
		 ----------------------------------------------------------------------------------\n
		 Parameters:\n
		 Device Family                      : $gFAMILY\n
		 Control Interface Data Width       : $local_data_bits\n
		 Number Memory Clock Pairs          : $num_clock_pairs\n
		 QDRII Interface Data Width	     : $mem_dq_per_dqs\n
		 QDRII Interface Address Width	     : $memory_address_width\n
		 ----------------------------------------------------------------------------------\n",
	);
######################################################################################################################################################################
	$module->add_contents
	(
	#####	Ports declaration#	######
		e_port->new({name => "clk",direction => "input"}),
		e_port->new({name => "reset_n",direction => "input"}),

		e_port->new({name => "avl_control_a_rd", width => $memory_address_width + $deep,direction => "input"}),
		e_port->new({name => "avl_control_a_wr", width => $memory_address_width + $deep,direction => "input"}),
		e_port->new({name => "avl_control_bwsn", width => $bwsn_width * 2 * $num_chips_wide,direction => "input"}),
		e_port->new({name => "avl_control_rpsn", width => 1,direction => "input"}),
		e_port->new({name => "avl_control_wdata", width =>  $memory_data_width * 2,direction => "input"}),
		e_port->new({name => "avl_control_wpsn", width => 1,direction => "input"}),

#		e_port->new({name => "control_a_rd", width => $memory_address_width + $deep,direction => "output"}),
#		e_port->new({name => "control_a_wr", width => $memory_address_width + $deep,direction => "output"}),
#		e_port->new({name => "control_bwsn", width => $bwsn_width * 2 * $num_chips_wide,direction => "output"}),
#		e_port->new({name => "control_rpsn", width => 1,direction => "output"}),
#		e_port->new({name => "control_wpsn", width => 1,direction => "output"}),

		e_port->new({name => "control_wdata", width =>  $memory_data_width * 2,direction => "output"}),
		e_port->new({name => "control_rdata", width =>  $memory_data_width * 2,direction => "output"}),     
		
		e_port->new({name => "training_done", width => 1, direction => "output"}),
		e_port->new({name => "training_incorrect", width => 1, direction => "output"}),
		e_port->new({name => "training_pattern_not_found", width => 1, direction => "output"}),

		e_signal->new(["init_control_a_rd",$memory_address_width + $deep,0,1]),
		e_signal->new(["init_control_a_wr",$memory_address_width + $deep,0,1]),
		e_signal->new(["init_control_bwsn",$bwsn_width * 2 * $num_chips_wide,0,1]),
		e_signal->new(["init_control_rpsn",1,0,1]),
		e_signal->new(["init_control_wdata", $memory_data_width * 2,0,1]),
		e_signal->new(["init_control_wpsn",1,0,1]),

		e_signal->new(["training_addr",$memory_address_width + $deep,0,1]),
		e_signal->new(["training_bwsn",$bwsn_width * 2 * $num_chips_wide,0,1]),
		e_signal->new(["training_rpsn",1,0,1]),
		e_signal->new(["training_wdata", $memory_data_width * 2,0,1]),
		e_signal->new(["training_wpsn",1,0,1]),

		e_signal->new(["resynched_rdata",(($mem_dq_per_dqs * 2) * $num_chips_wide),0,1]),
		e_signal->new(["ZERO",1,0,1]),

		e_assign->new({lhs => "ZERO",	rhs => 0,}),
	);

if(($num_chips_deep > 1) || ($num_chips_wide > 1))
{
	for($i = 0; $i < $num_chips_deep; $i++){
		for($j = 0; $j < $num_chips_wide; $j++){

            $module->add_contents
            (
    		e_port->new({name => "control_rpsn_$j"."_$i",direction => "output", width => 1}),
    		e_port->new({name => "control_wpsn_$j"."_$i",direction => "output", width => 1}),
    		e_port->new({name => "control_bwsn_$j"."_$i",direction => "output", width => $bwsn_width * 2 * $num_chips_wide}),
    		e_port->new({name => "control_a_wr_$j"."_$i",direction => "output", width => $memory_address_width + $deep,declare_one_bit_as_std_logic_vector => 0}),
    		e_port->new({name => "control_a_rd_$j"."_$i",direction => "output", width => $memory_address_width + $deep,declare_one_bit_as_std_logic_vector => 0}),
            );
        }
    }
}else{
    $module->add_contents
    (
		e_port->new({name => "control_a_rd", width => $memory_address_width + $deep,direction => "output"}),
		e_port->new({name => "control_a_wr", width => $memory_address_width + $deep,direction => "output"}),
		e_port->new({name => "control_bwsn", width => $bwsn_width * 2 * $num_chips_wide,direction => "output"}),
		e_port->new({name => "control_rpsn", width => 1,direction => "output"}),
		e_port->new({name => "control_wpsn", width => 1,direction => "output"}),
	);
}  
###############################################  Address and Command Pipeline Module  #################################################################################

if($num_chips_deep > 1){
	$module->add_contents
	(
		# e_signal->new(["wpsn2",1,0,1]),
		# e_signal->new(["rpsn2",1,0,1]),
		e_assign->new(["internal_wpsn_0", "(init_control_a_wr[".(($memory_address_width + $deep) - 1)."]) || init_control_wpsn"]),
		e_assign->new(["internal_wpsn_1", "(~init_control_a_wr[".(($memory_address_width + $deep) - 1)."]) || init_control_wpsn"]),
		e_assign->new(["internal_rpsn_0", "(init_control_a_rd[".(($memory_address_width + $deep) - 1)."]) || init_control_rpsn"]),
		e_assign->new(["internal_rpsn_1", "(~init_control_a_rd[".(($memory_address_width + $deep) - 1)."]) || init_control_rpsn"]),
	);
}elsif($num_chips_wide > 1){
	$module->add_contents
	(
		e_signal->new(["internal_wpsn_0",1,0,1]),
		e_signal->new(["internal_rpsn_0",1,0,1]),
		e_assign->new(["internal_wpsn_0", "init_control_wpsn"]),
		e_assign->new(["internal_rpsn_0", "init_control_rpsn"]),
	);
}


if( $num_pipeline_addr_cmd_stages > 0)
{                                       


    if(($num_chips_deep > 1) || ($num_chips_wide > 1))
    {


		for($j = 0; $j < $num_chips_wide; $j++){     
        	for($i = 0; $i < $num_chips_deep; $i++){
            	$module->add_contents
            	(
            		e_comment->new({comment => "\nInstantiating the pipeline module for the address and command signals\n"}),
            		e_blind_instance->new
            		 ({
            			 name 		=> "${mem_type}_addr_cmd_pipeline_${j}_${i}",
            			 module 	=> $gWRAPPER_NAME."_auk_${mem_type}_pipeline_addr_cmd",
            			 in_port_map 	=>
            			 {
            				 clk                  	=> "clk",
            				 reset_n             	=> "reset_n",
            				 pipeline_rpsn_in      	=> "internal_rpsn_$i",
            				 pipeline_wpsn_in	=> "internal_wpsn_$i",
            				 pipeline_bwsn_in	=> "init_control_bwsn",
            				 pipeline_addr_wr_in	=> "init_control_a_wr",
            				 pipeline_addr_rd_in	=> "init_control_a_rd",
            			 },
            			 out_port_map	=>
            			 {
            				 pipeline_rpsn_out      => "control_rpsn_$j"."_$i",
            				 pipeline_wpsn_out	=> "control_wpsn_$j"."_$i",
            				 pipeline_bwsn_out	=> "control_bwsn_$j"."_$i",
            				 pipeline_addr_wr_out	=> "control_a_wr_${j}_${i}",
            				 pipeline_addr_rd_out	=> "control_a_rd_${j}_${i}",
            			 },
            		 }),
            	);
            }
        }
    } else {

            	$module->add_contents
            	(
            		e_comment->new({comment => "\nInstantiating the pipeline module for the address and command signals\n"}),
            		e_blind_instance->new
            		 ({
            			 name 		=> "${mem_type}_addr_cmd_pipeline",
            			 module 	=> $gWRAPPER_NAME."_auk_${mem_type}_pipeline_addr_cmd",
            			 in_port_map 	=>
            			 {
            				 clk                  	=> "clk",
            				 reset_n             	=> "reset_n",
            				 pipeline_rpsn_in      	=> "init_control_rpsn",
            				 pipeline_wpsn_in	=> "init_control_wpsn",
            				 pipeline_bwsn_in	=> "init_control_bwsn",
            				 pipeline_addr_wr_in	=> "init_control_a_wr",
            				 pipeline_addr_rd_in	=> "init_control_a_rd",
            			 },
            			 out_port_map	=>
            			 {
            				 pipeline_rpsn_out      => "control_rpsn",
            				 pipeline_wpsn_out	=> "control_wpsn",
            				 pipeline_bwsn_out	=> "control_bwsn",
            				 pipeline_addr_wr_out	=> "control_a_wr",
            				 pipeline_addr_rd_out	=> "control_a_rd",
            			 },
            		 }),
            	);
    }
}
else
{
    if(($num_chips_deep > 1) || ($num_chips_wide > 1))
    {
    	for($i = 0; $i < $num_chips_deep; $i++){
    		for($j = 0; $j < $num_chips_wide; $j++){

            	$module->add_contents
            	(
            		e_comment->new({comment => "\nNo pipeline module for the address and command signals\n"}),
            		e_assign->news
            		(
            			["control_rpsn_${j}_${i}" => "internal_rpsn_$i"],
            			["control_wpsn_${j}_${i}"	=> "internal_wpsn_$i"],
            			["control_bwsn_${j}_${i}"	=> "init_control_bwsn"],
            			["control_a_wr_${j}_${i}"	=> "init_control_a_wr"],
            			["control_a_rd_${j}_${i}"	=> "init_control_a_rd"],

            		),
            	);         
            }
        }
    } else {
    	$module->add_contents
    	(
    		e_comment->new({comment => "\nNo pipeline module for the address and command signals\n"}),
    		e_assign->news
    		(
    			["control_rpsn" => "init_control_rpsn"],
    			["control_wpsn"	=> "init_control_wpsn"],
    			["control_bwsn"	=> "init_control_bwsn"],
    			["control_a_wr"	=> "init_control_a_wr"],
    			["control_a_rd"	=> "init_control_a_rd"],
    		),
    	);         
    }
}

###############################################      Write Data Pipeline Module   #################################################################################
if( $num_pipeline_addr_cmd_stages > 0)
{
	 $module->add_contents
	 (
		e_comment->new({comment => "\nInstantiating the pipeline stages for the Write Data Path\n"}),
		e_blind_instance->new
		({
			name 		=> "${mem_type}_wdata_pipeline",
			module 	=> $gWRAPPER_NAME."_auk_${mem_type}_pipeline_wdata",
			in_port_map 	=>
			{
				clk               	=> "clk",
				reset_n               	=> "reset_n",
				pipeline_data_in    	=> "init_control_wdata",
			},
			out_port_map	=>
			{
				pipeline_data_out       => "control_wdata",
			},
		}),
	);
}
else
{
	$module->add_contents
	 (
		e_comment->new({comment => "\nNo pipeline stages for the Write Data Path\n"}),
		e_assign->new(["control_wdata","init_control_wdata"]),
	 );
}
###############################################      Test Module   #################################################################################

		$module->add_contents
		(
			e_signal->new(["fifo_address_plus_two",$num_chips_wide,0,1]),
			e_signal->new(["fifo_address_plus_zero",$num_chips_wide,0,1]),
			e_signal->new(["reset_read_and_fifo_n",1,0,1]),
		);
	$module->add_contents
	(
		e_comment->new
		({
			comment => "------------------------------------------------------------\n
				   Instance of the Training module\n
				   ------------------------------------------------------------\n"
		}),
		e_blind_instance->new
		({
			name 		=> "auk_${mem_type}_train_wrapper",
			module 		=> $gWRAPPER_NAME."_auk_${mem_type}_train_wrapper",
			in_port_map 	=>
			{
				clk			=> "clk",
				reset_n 		=> "reset_n",
				train_rdata 		=> "control_rdata",
				train_start_training 		=> "ZERO",
			},
			out_port_map	=>
			{
				train_addr 		=> "training_addr",
				train_been	 		=> "training_bwsn",
				train_rpsn	 		=> "training_rpsn",
				train_wdata 		=> "training_wdata",
				train_wpsn	 		=> "training_wpsn",
				fifo_address_plus_zero	 		=> "fifo_address_plus_zero",
				fifo_address_plus_two	 		=> "fifo_address_plus_two",
				flag_training_done		=> "training_done",
				flag_training_incorrect		=> "training_incorrect",
				flag_training_pattern_not_found		=> "training_pattern_not_found",
				reset_read_and_fifo_n => "reset_read_and_fifo_n"
			},
		}),
	);


###############################################         Mux         ###############################################################################

	$module->add_contents
	(
		e_process->new
		({
			clock			=> " ",
			reset			=> " ",
			sensitivity_list	=>
			[
				"training_done","training_addr","training_bwsn",
				"training_wpsn","training_wdata","training_rpsn",
				"avl_control_a_rd","avl_control_a_wr","avl_control_bwsn",
				"avl_control_rpsn","avl_control_wpsn","avl_control_wdata"
			],
			contents	=>
			[
				e_if->new
				({
					condition	=> "~training_done",
					then		=>
					[
					e_assign->news
					(
						["init_control_a_rd"	=>	"training_addr"],
						["init_control_a_wr"	=>	"training_addr"],
						["init_control_bwsn"	=>	"training_bwsn"],
						["init_control_rpsn"	=>	"training_rpsn"],
						["init_control_wpsn"	=>	"training_wpsn"],
						["init_control_wdata"	=>	"training_wdata"],
					),
					],
					else		=>
					[
						["init_control_a_rd"	=>	"avl_control_a_rd"],
						["init_control_a_wr"	=>	"avl_control_a_wr"],
						["init_control_bwsn"	=>	"avl_control_bwsn"],
						["init_control_rpsn"	=>	"avl_control_rpsn"],
						["init_control_wpsn"	=>	"avl_control_wpsn"],
						["init_control_wdata"	=>	"avl_control_wdata"],
					],
				}),
			],
		}),
	);

###############################################      Resynch Modules   ###############################################################################
for($i = 0; $i < $num_chips_wide; $i++)
{
	if($num_chips_wide > 1)
	{
		$module->add_contents
		(
			e_signal->new(["resynched_rdata_$i",$mem_dq_per_dqs * 2,0,1]),
			e_port->new({name => "capture_clock_$i", direction => "input", width => 1, declare_one_bit_as_std_logic_vector => 1}),
			e_port->new({name => "captured_data_$i", direction => "input", width => $mem_dq_per_dqs * 2}),
			e_blind_instance->new
			({
				  name 		=> "auk_${mem_type}_resynch_reg_$i",
				  module 	=> $gWRAPPER_NAME."_auk_${mem_type}_resynch_reg",
				  in_port_map 	=>
				  {
					  clk                 	=> "clk",
					  reset_n              	=> "reset_n",
					  unsynch_data    	=> "captured_data_$i",
					  cq			=> "capture_clock_$i"."[0]",
					  address_plus_two			=> "fifo_address_plus_two"."[$i]",
					  address_plus_zero			=> "fifo_address_plus_zero"."[$i]",
					  reset_read_and_fifo_n => "reset_read_and_fifo_n",
				  },
				  out_port_map	=>
				  {
					  resynch_data     	=> "resynched_rdata_$i",
				  },
			}),
		);
	}
	else
	{
		$module->add_contents
		(
			# e_signal->new(["resynched_rdata",$mem_dq_per_dqs * 2,0,1]),
			e_port->new({name => "capture_clock", direction => "input", width => 1, declare_one_bit_as_std_logic_vector => 1}),
			e_port->new({name => "captured_data", direction => "input", width => $mem_dq_per_dqs * 2}),
			e_blind_instance->new
			({
				  name 		=> "auk_${mem_type}_resynch_reg",
				  module 	=> $gWRAPPER_NAME."_auk_${mem_type}_resynch_reg",
				  in_port_map 	=>
				  {
					  clk                 	=> "clk",
					  reset_n              	=> "reset_n",
					  unsynch_data    	=> "captured_data",
					  cq			=> "capture_clock"."[0]",
					  address_plus_two			=> "fifo_address_plus_two",
					  address_plus_zero			=> "fifo_address_plus_zero",
					  reset_read_and_fifo_n => "reset_read_and_fifo_n",
				  },
				  out_port_map	=>
				  {
					  resynch_data     	=> "resynched_rdata",
				  },
			}),
		);
	}
}
for(my $k = ($num_chips_wide -1); $k >= 0; $k--)
{
	if($k > 0)
	{
		$resynched_rdata .= "resynched_rdata_$k,";
	}else{
		$resynched_rdata .= "resynched_rdata_$k";
	}
}
if($num_chips_wide > 1){
  $module->add_contents(e_assign->new(["resynched_rdata","{$resynched_rdata}"]),);
}else{
  $resynched_rdata = "resynched_rdata";
}

###############################################      Read Data Pipeline Module   #################################################################################
if( $num_pipeline_rdata_stages > 0)
{
	$module->add_contents
	(
		e_comment->new({comment => "\n\nInstantiating the pipeline stage for the Read Data Path\n"}),
		e_blind_instance->new
		({
			  name 		=> "auk_${mem_type}_pipeline_rdata",
			  module 	=> $gWRAPPER_NAME."_auk_${mem_type}_pipeline_rdata",
			  in_port_map 	=>
			  {
				  clk                 	=> "clk",
				  reset_n              	=> "reset_n",
				  pipeline_data_in    	=> "resynched_rdata",
			  },
			  out_port_map	=>
			  {
				  pipeline_data_out      => "control_rdata",
			  },
		}),
	);
}
else
{
	$module->add_contents
	(
		e_assign->new(["control_rdata","{$resynched_rdata}"]),
	);
}

##################################################################################################################################################################
$project->output();
}

1;
#You're done.
