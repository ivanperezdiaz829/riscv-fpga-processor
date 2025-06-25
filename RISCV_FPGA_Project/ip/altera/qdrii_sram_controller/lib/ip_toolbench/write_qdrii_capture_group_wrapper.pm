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
#  File         : $RCSfile: write_qdrii_capture_group_wrapper.pm,v $
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


sub write_qdrii_capture_group_wrapper
{

my $mem_type = $gMEM_TYPE;
my $top = e_module->new({name => $gWRAPPER_NAME."_auk_${mem_type}_capture_group_wrapper"});
my $project = e_project->new({top => $top, language => $language,__system_directory =>$output_directory , timescale => "1ps / 1ps"});
my $module = $project->top();
$module->vhdl_libraries()->{altera_mf} = all;
$module->vhdl_libraries()->{$gFAMILYlc} = all;


my $family = $gFAMILY;
my $header_title = "QDRII Controller Capture Group Wrapper Module";
my $header_filename = $gWRAPPER_NAME . "_auk_${mem_type}capture_group_wrapper" . $file_ext;
my $header_revision = "V" . $gWIZARD_VERSION;
my $header_abstract = "This file contains the output registers for the QDRII Controller.";

my $burst_mode = $gMEMORY_BURST_LENGTH;
my $device_clk = "clk";
my $device_clk_edge = "1";
my $device_clk_edge_s = "positive";
my $mem_dq_per_dqs = $gMEM_DQ_PER_DQS;
my $memory_data_width = $gMEMORY_DATA_WIDTH;
my $memory_address_width = $gMEMORY_ADDRESS_WIDTH;
my $qdrii_pin_prefix = $gQDRII_PIN_PREFIX;
my $is_busrt4_narrow = $gIS_BURST4_NARROW;
my $avl_data_width_multiply = $gAVL_DATA_WIDTH_MULTIPLY;
my $use_dqs_for_read = $gUSE_DQS_FOR_READ;     

my $memory_latency = $gMEMORY_LATENCY;

my $num_chips_wide = $gNUM_CHIPS_WIDE;
my $num_chips_deep = $gNUM_CHIPS_DEEP;
######################################################################################################################################################################
my @capture_clock_variable;
my %capture_clock_variable;
my @capture_clock_list;
my $deep;
if($num_chips_deep > 1){
	$deep = 1;
}else{
	$deep = 0;
}
my $data_zeros;
for($i = 0; $i < ($mem_dq_per_dqs * 2); $i++)
{ $data_zeros .= "0"; }

my $half_data_zeros;
for($i = 0; $i < ($mem_dq_per_dqs); $i++)
{ $half_data_zeros .= "0"; }

my $bwsn_width;
my $avl_data_width_multiply = $gAVL_DATA_WIDTH_MULTIPLY;
if($memory_data_width <= 18)
{
	$bwsn_width = 2;
}elsif($memory_data_width > 18)
{
	$bwsn_width = 4;
}
my $resynch_type = $gRESYNCH_TYPE;
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
		 ------------------------------------------------------------------------------"
	);
######################################################################################################################################################################
if($family eq "Stratix II" and $use_dqs_for_read eq "true")
{
	$module->add_contents
	(
	#####	Ports declaration#	######
		e_port->new({name => "dll_delay_ctrl" , direction => "input", width => 6, declare_one_bit_as_std_logic_vector => 1}),
#		e_port->new({name => "write_clk" , direction => "input", width => 1}),
	);
#	$capture_clock{'write_clk'} = "write_clk";
}
my $i;
if ($family eq "Stratix II" and $use_dqs_for_read eq "false")
{
	$module->add_contents
	(
		e_port->new({name => "non_dqs_capture_clk",direction => "input"}),
	);
}
if($num_chips_wide > 1)
{
	for($i = 0; $i < $num_chips_wide; $i++)
	{

		if($use_dqs_for_read eq "true")
		{
			$module->add_contents
			(
			#####	Ports declaration#	######
				e_port->new({name => "${qdrii_pin_prefix}cq_$i",direction => "inout", declare_one_bit_as_std_logic_vector => 1}),
				e_port->new({name => "${qdrii_pin_prefix}cqn_$i",direction => "inout", declare_one_bit_as_std_logic_vector => 1}),
			);
		}
		$module->add_contents
		(
		#####	Ports declaration#	######
#			e_port->new({name => "clk",direction => "input"}),
			e_port->new({name => "reset_n",direction => "input"}),
			e_port->new({name => "${qdrii_pin_prefix}q_$i" , direction => "input" , width => $mem_dq_per_dqs}),
			e_port->new({name => "captured_data_$i" , direction => "output" , width => $mem_dq_per_dqs * 2}),

			e_port->new({name => "capture_clock_$i", direction => "output", width => 1, declare_one_bit_as_std_logic_vector => 1}),
			# e_signal->new({name => "cq_$i", width => 1, declare_one_bit_as_std_logic_vector => 1, export => 0, never_export => 1}),
			e_signal->new({name => "cqn_$i", width => 1, declare_one_bit_as_std_logic_vector => 1, export => 0, never_export => 1}),
    		e_signal->new({name => "io_captured_data_$i", width => $mem_dq_per_dqs * 2, export => 0, never_export => 1}),
    		e_signal->new({name => "latency_aligned_io_captured_data_$i", width => $mem_dq_per_dqs * 2, export => 0, never_export => 1}),
    		e_signal->new({name => "lower_latency_aligned_io_captured_data_$i", width => $mem_dq_per_dqs, export => 0, never_export => 1}),
			e_port->new({name => "io_recaptured_data_$i" , width => $mem_dq_per_dqs * 2}, export => 0, never_export => 1),
					);
	}
}else{
		if($use_dqs_for_read eq "true")
		{
			$module->add_contents
			(
			#####	Ports declaration#	######
				e_port->new({name => "${qdrii_pin_prefix}cq",direction => "inout", declare_one_bit_as_std_logic_vector => 1}),
				e_port->new({name => "${qdrii_pin_prefix}cqn",direction => "inout", declare_one_bit_as_std_logic_vector => 1}),
			);
		}
		$module->add_contents
		(
		#####	Ports declaration#	######
			e_port->new({name => "${qdrii_pin_prefix}q" , direction => "input" , width => $mem_dq_per_dqs}),

			e_port->new({name => "captured_data" , direction => "output" , width => $mem_dq_per_dqs * 2}),
			e_port->new({name => "capture_clock", direction => "output", width => 1, declare_one_bit_as_std_logic_vector => 1}),
			# e_signal->new({name => "cq", width => 1, declare_one_bit_as_std_logic_vector => 1, export => 0, never_export => 1}),
			e_signal->new({name => "capture_clock_n", width => 1, declare_one_bit_as_std_logic_vector => 1, export => 0, never_export => 1}),
			e_signal->new({name => "latency_aligned_io_captured_data", width => $mem_dq_per_dqs * 2, export => 0, never_export => 1}),
			e_signal->new({name => "io_captured_data", width => $mem_dq_per_dqs * 2, export => 0, never_export => 1}),
			e_signal->new({name => "lower_latency_aligned_io_captured_data", width => $mem_dq_per_dqs , export => 0, never_export => 1}),
			e_port->new({name => "io_recaptured_data" , width => $mem_dq_per_dqs * 2, export => 0, never_export => 1}),
			);
}
$module->add_contents
(
	#####	Ports declaration#	######
#	e_port->new({name => "clk",direction => "input"}),
	e_port->new({name => "reset_n",direction => "input"}),
);
##################################################################################################################################################################
for($i = 0; $i < $num_chips_wide; $i++)
{
	if (($use_dqs_for_read eq "true")and ($family eq "Stratix II"))
	{
		if($num_chips_wide > 1)
		{
			$module->add_contents
			(
			  e_blind_instance->new
				  ({
					  name 		=> "auk_${mem_type}_cq_cqn_group_$i",
					  module 	=> $gWRAPPER_NAME."_auk_${mem_type}_cq_cqn_group",
					  in_port_map 	=>
					  {
#						  clk				=> "clk",
						  dll_delay_ctrl    		=> "dll_delay_ctrl",
					  },
					  out_port_map	=>
					  {
						  local_cq			     	=> "capture_clock_$i"."[0]",
						  local_cqn			     	=> "capture_clock_n_$i"."[0]",
					  },
					  inout_port_map	=>
					  {
						  "${qdrii_pin_prefix}cq"      	=> "${qdrii_pin_prefix}cq_$i"."[0:0]",
						  "${qdrii_pin_prefix}cqn"     	=> "${qdrii_pin_prefix}cqn_$i"."[0:0]",
					  },
					  std_logic_vector_signals =>
					  [
						"${qdrii_pin_prefix}cq",
						"${qdrii_pin_prefix}cqn",
						local_cq,
						local_cqn,
					  ],
				  }),
			);
			$capture_clock_variable{"capture_clock"} = "capture_clock_$i"."[0]";
			$capture_clock_variable{"capture_clock_n"} = "capture_clock_n_$i"."[0]";
		}else{
			$module->add_contents
			(
			  e_blind_instance->new
				  ({
					  name 		=> "auk_${mem_type}_cq_cqn_group",
					  module 	=> $gWRAPPER_NAME."_auk_${mem_type}_cq_cqn_group",
					  in_port_map 	=>
					  {
#						  clk				=> "clk",
						  dll_delay_ctrl    		=> "dll_delay_ctrl",
					  },
					  out_port_map	=>
					  {
						  local_cq			     	=> "capture_clock"."[0]",
						  local_cqn			     	=> "capture_clock_n"."[0]",
					  },
					  inout_port_map	=>
					  {
						  "${qdrii_pin_prefix}cq"      	=> "${qdrii_pin_prefix}cq"."[0:0]",
						  "${qdrii_pin_prefix}cqn"     	=> "${qdrii_pin_prefix}cqn"."[0:0]",
					  },
					  std_logic_vector_signals =>
					  [
						"${qdrii_pin_prefix}cq",
						"${qdrii_pin_prefix}cqn",
						local_cq,
						local_cqn,
					  ],
				  }),

			);
			$capture_clock_variable{"capture_clock"} = "capture_clock"."[0]";
			$capture_clock_variable{"capture_clock_n"} = "capture_clock_n"."[0]";
		}
	}
	else
	{
		if($num_chips_wide > 1)
		{
			$capture_clock{'capture_clk'} = "non_dqs_capture_clk";
			$module->add_contents(e_assign->new(["capture_clock_$i"."[0]","non_dqs_capture_clk"]));
			$capture_clock_variable{"non_dqs_capture_clk"} = "non_dqs_capture_clk";
		} else {
			$capture_clock{'capture_clk'} = "non_dqs_capture_clk";
			$module->add_contents(e_assign->new(["capture_clock[0]","non_dqs_capture_clk"]));
			$capture_clock_variable{"non_dqs_capture_clk"} = "non_dqs_capture_clk";
		}
	};
	@capture_clock_variable = %capture_clock_variable;
	foreach my $param (@capture_clock_variable)
	{
		push (@capture_clock_list, $param);
	}

	if($num_chips_wide > 1)
	{
		$module->add_contents
		(
			  e_blind_instance->new
			  ({
				  name 		=> "auk_${mem_type}_read_group_$i",
				  module 	=> $gWRAPPER_NAME."_auk_${mem_type}_read_group",
				  in_port_map 	=>
				  {
#					  clk			=> "clk",
					  reset_n              	=> "reset_n",
					  @capture_clock_variable		=> @capture_clock_list,
					"${qdrii_pin_prefix}q"	=> "${qdrii_pin_prefix}q_$i",
				  },
				  out_port_map	=>
				  {
					  captured_data     	=> "io_captured_data_$i",
				  },
			  }),                                           

			
		);
	}else{
		$module->add_contents
		(
		  e_blind_instance->new
		  ({
			  name 		=> "auk_${mem_type}_read_group",
			  module 	=> $gWRAPPER_NAME."_auk_${mem_type}_read_group",
			  in_port_map 	=>
			  {
#				  clk			=> "clk",
				  reset_n              	=> "reset_n",
				  @capture_clock_variable	=> @capture_clock_list,
				"${qdrii_pin_prefix}q"	=> "${qdrii_pin_prefix}q",
			  },
			  out_port_map	=>
			  {
				  captured_data     	=> "io_captured_data",
			  },
		  }),

 	
		);
	}          
#
# Here we need to add a register on the lower part of the captured data to realign it properly in the case of a 2.0 cycle latency.
# The easiest possible solution would be to have an intermediate signal that is either registered or passed through depending on the
# latency.
#
#
#   

# latency_aligned_
print "mem latecy $memory_latency\n";
    if ($memory_latency == 2) {         
    
       	if($num_chips_wide > 1)
    	{
print "latency2 numchip > 1\n";
        	$module->add_contents
        	(
         	    e_process->new
        	    ({
				clock		=> "capture_clock_$i"."[0]",
				reset		=> "",
				contents => [
						e_assign->new(["lower_latency_aligned_io_captured_data_$i", "io_recaptured_data_$i"."[".($mem_dq_per_dqs -1).":0]"]),
					    ],
		    }),										#end_process
		);										#end_module
					
        	$module->add_contents
        	(
#         	    e_assign->new(["captured_data_$i[".($mem_dq_per_dqs * 2 -1).":".($mem_dq_per_dqs)."]", "io_recaptured_data_$i[".($mem_dq_per_dqs * 2 -1).":".($mem_dq_per_dqs)."]"]),
         	    e_assign->new(["captured_data_$i"."[".($mem_dq_per_dqs -1).":0]", "io_recaptured_data_$i"."[".($mem_dq_per_dqs * 2 -1).":".($mem_dq_per_dqs)."]"]),
         	    e_assign->new(["captured_data_$i"."[".($mem_dq_per_dqs * 2 -1).":".($mem_dq_per_dqs)."]", "lower_latency_aligned_io_captured_data_$i" ]),
         	);
        } else {
print "latency2 numchip == 1\n";
        	$module->add_contents
        	(
         	    e_process->new
        	    ({
				clock		=> "capture_clock"."[0]",
				reset		=> "",
				contents => [
						e_assign->new(["lower_latency_aligned_io_captured_data", "io_recaptured_data[".($mem_dq_per_dqs -1).":0]"]),
					    ],
		     }),										#end_process
		);										#end_module	    
	
        	$module->add_contents
        	(
         	    e_assign->new(["captured_data"."[".($mem_dq_per_dqs -1).":0]", "io_recaptured_data[".($mem_dq_per_dqs * 2 -1).":".$mem_dq_per_dqs ."]"]),
         	    e_assign->new(["captured_data"."[".($mem_dq_per_dqs * 2 -1).":".$mem_dq_per_dqs ."]", "lower_latency_aligned_io_captured_data"]),
         	
         	);
        }  
  
    
    } else {      
        # in this case we don't need to shift the data at all.
       	if($num_chips_wide > 1)
    	{                    
print "latency non2 numchip > 1\n";
    		$module->add_contents
    		(
          	    e_assign->new(["captured_data_$i", "io_recaptured_data_$i"]),
          	 );
    	} else {    
print "latency non2 numchip == 1\n"    	    ;
       		$module->add_contents
      		(
         	    e_assign->new(["captured_data", "io_recaptured_data"]),
         	);
    	}
    }       
    
	
	if (($use_dqs_for_read eq "true")and ($family eq "Stratix II"))
	{  
    	if($num_chips_wide > 1)
    	{
    		$module->add_contents
    		(
         	    e_process->new
        	    ({
        		clock		=> "capture_clock_$i"."[0]",
        		contents	=>
        		[
    	    		e_assign->new(["io_recaptured_data_$i", "io_captured_data_$i"]),
        		],
        	    }),
            );
        } else {
    		$module->add_contents
    		(
		  	    e_process->new
        	    ({
        		clock		=> "capture_clock"."[0]",
        		contents	=>
        		[
    	    		e_assign->new(["io_recaptured_data", "io_captured_data"]),
        		],
        	    }),
            );
        }
	} else {
       	if($num_chips_wide > 1)
    	{
    		$module->add_contents
    		(
          	    e_assign->new(["io_recaptured_data_$i", "io_captured_data_$i"]),
          	 );
    	} else { 
       		$module->add_contents
      		(
         	    e_assign->new(["io_recaptured_data", "io_captured_data"]),
         	);
    	}
 
	    
	}
	
}
##################################################################################################################################################################
$project->output();
}

1;
#You're done.
