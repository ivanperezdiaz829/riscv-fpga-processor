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
#  Title        : Example driver
#  Project      : QDRII SRAM Controller
#
#
#  File         : $RCSfile: write_qdrii_new_example_driver.pm,v $
#
#  Last modified: $Date: 2013/08/11 $
#  Revision     : $Revision: #1 $
#
#  Abstract:
#
#  Notes:  This example driver is optimised for frequency and testing is minimal
# ------------------------------------------------------------------------------
#sopc_builder free code
use europa_all;
use europa_utils;
use e_comment;
use e_generate;


sub write_qdrii_new_example_driver
{
my $mem_type = $gMEM_TYPE;

my $top = e_module->new({name => $gWRAPPER_NAME."_auk_${mem_type}_example_driver"});
my $project = e_project->new({top => $top, language => $language,__system_directory =>$output_directory , timescale => "1ps / 1ps"});#'temp_gen'});
my $module = $project->top();

$module->vhdl_libraries()->{altera_mf} = all;


my $header_title = "QDRII Controller Example Driver";
my $project_title = "QDRII Controller";
my $header_filename = $gWRAPPER_NAME."_auk_${mem_type}_example_driver". $file_ext;
my $header_revision = "V" . $gWIZARD_VERSION;
my $header_abstract = "This file contains the memory clock generation for the QDRII Controller.";

#####   Parameters declaration  ######
my $family = $gFAMILY;
my $memory_data_width = $gMEMORY_DATA_WIDTH;
my $memory_address_width = $gMEMORY_ADDRESS_WIDTH;
my $mem_dq_per_dqs = $gMEM_DQ_PER_DQS;
my $local_data_bits = $gLOCAL_DATA_BITS;
my $delay_chain = $gDELAY_CHAIN;
my $burst_mode = $gMEMORY_BURST_LENGTH;
my $memory_byteen_width = $gMEMORY_BYTEEN_WIDTH;
my $avl_data_width_multiply = $gAVL_DATA_WIDTH_MULTIPLY;
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
my $num_chips_wide = $gNUM_CHIPS_WIDE;
my $num_chips_deep = $gNUM_CHIPS_DEEP;
my $deep;
if($num_chips_deep > 1){
	$deep = 1;
}else{
	$deep = 0;
}
my $is_busrt4_narrow = $gIS_BURST4_NARROW;
my $qdrii_pin_prefix = $gQDRII_PIN_PREFIX;

my $wr_be = $bwsn_width * $avl_data_width_multiply * $num_chips_wide;

my $bswn_ones; my $bswn_zeros;
my $data_ones; my $data_zeros;
my $addr_ones; my $addr_zeros;           
my $counter_ones; my $counter_zeros;
my $fail_per_byte_ones; my $fail_per_byte_zeros; 
my $fail_per_byte_size;                            
my $cycle_length_bit;
for($i = 0; $i < ($bwsn_width * $avl_data_width_multiply * $num_chips_wide); $i++)
{ $bswn_ones .= "1"; $bswn_zeros .= "0"; }


for($i = 0; $i < ($memory_data_width ); $i++)
{ $data_ones .= "1"; $data_zeros .= "0"; }

for($i = 0; $i < ($memory_address_width + $deep); $i++)
{ $addr_ones .= "1"; $addr_zeros .= "0"; }
for($i = 0; $i < 16; $i++)
{ $counter_ones .= "1"; $counter_zeros .= "0"; }

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
		 Device Family			    : $family\n
		 ----------------------------------------------------------------------------------\n",
	);
#####################################################################################################################################################################
	 $module->add_contents
	 (
	 #####	Ports declaration#	######
        e_port->new({name => "clk",direction => "input", width => 1}),
        e_port->new({name => "reset_n",direction => "input", width => 1}),

	     ### Inputs ####
        e_port->new({name => "avl_read_data",direction => "input",width => $local_data_bits}),
        e_port->new({name => "avl_read_data_valid",direction => "input", width => 1}),
        e_port->new({name => "avl_read_wait",direction => "input", width => 1}),
        e_port->new({name => "avl_write_wait",direction => "input", width => 1}),

	    ### Outputs ####
        e_port->new({name => "avl_read_addr",direction => "output", width => $memory_address_width + $is_busrt4_narrow + $deep,declare_one_bit_as_std_logic_vector => 0}),
        e_port->new({name => "avl_read",direction => "output",width => 1}),
        e_port->new({name => "avl_write_addr",direction => "output", width => $memory_address_width + $is_busrt4_narrow + $deep,declare_one_bit_as_std_logic_vector => 0}),
        e_port->new({name => "avl_wr_be",direction => "output",width => $wr_be}),
        e_port->new({name => "avl_write_data",direction => "output",width => $local_data_bits}),
        e_port->new({name => "avl_write",direction => "output", width => 1}),

        e_port->new({name => "fail",direction => "output", width => 1}),
        e_port->new({name => "fail_permanent",direction => "output", width => 1}),
        e_port->new({name => "test_complete",direction => "output", width => 1}),

	#### internal signals and parameter####

		e_signal->new({name  => "avl_read_data_valid_reg",  width => 1, never_export => 1, export => 0}),
		e_signal->new({name  => "cycle_length_write",  width => 16, never_export => 1, export => 0}),
		e_signal->new({name  => "cycle_length_read",  width => 16, never_export => 1, export => 0}),
		e_signal->new({name  => "counter_rw", 	 width => 16, never_export => 1, export => 0, comment => "counts the number of read and write"}),
		e_signal->new({name  => "counter_read",  width => 16, never_export => 1, export => 0, comment => "counts the number of read and write"}),
		e_signal->new({name  => "counter_pause", width =>  6, never_export => 1, export => 0, comment => "count pause between read and write sequences"}),
		e_signal->new({name  => "counter_addr",  width => $memory_address_width + $is_busrt4_narrow + $deep, never_export => 1, export => 0, comment => "count pause between read and write sequences"}),
		e_signal->new({name  => "state", 	 width =>  4, never_export => 1, export => 0, comment => "state: 00 write, 01 pause, 10 read, 11 pause"}),
		e_signal->new({name  => "expected_data", 	 width =>  $local_data_bits, never_export => 1, export => 0, comment => "expected data"}),
	);

if ($avl_data_width_multiply == 2)
{                    
    if (($mem_dq_per_dqs == 9) || ($mem_dq_per_dqs == 18) || ($mem_dq_per_dqs == 36))
    {
    	 $module->add_contents
    	 (
    		e_signal->new({name  => "fail_per_byte",  width => $num_chips_wide * $mem_dq_per_dqs * 2 / 9, never_export => 1, export => 0}),
    		e_signal->new({name  => "fail_per_byte_reg",  width => $num_chips_wide * $mem_dq_per_dqs * 2 / 9, never_export => 1, export => 0}),
    	);
        for($i = 0; $i < ($num_chips_wide * $mem_dq_per_dqs * 2 / 9 ); $i++)
            { $fail_per_byte_ones .= "1"; $fail_per_byte_zeros .= "0"; }
        $fail_per_byte_size = ($num_chips_wide * $mem_dq_per_dqs * 2 / 9 );
    } else {
    	 $module->add_contents
    	 (
    		e_signal->new({name  => "fail_per_byte",  width => $num_chips_wide * $mem_dq_per_dqs * 2 / 8, never_export => 1, export => 0}),
    		e_signal->new({name  => "fail_per_byte_reg",  width => $num_chips_wide * $mem_dq_per_dqs * 2 / 8, never_export => 1, export => 0}),
    	);
        for($i = 0; $i < ($num_chips_wide * $mem_dq_per_dqs * 2 / 8 ); $i++)
            { $fail_per_byte_ones .= "1"; $fail_per_byte_zeros .= "0"; }      
        $fail_per_byte_size = ($num_chips_wide * $mem_dq_per_dqs * 2 / 8 );
    }  
} else {
    if (($mem_dq_per_dqs == 9) || ($mem_dq_per_dqs == 18) || ($mem_dq_per_dqs == 36))
    {
    	 $module->add_contents
    	 (
    		e_signal->new({name  => "fail_per_byte",  width => $num_chips_wide * $mem_dq_per_dqs * 4 / 9, never_export => 1, export => 0}),
    		e_signal->new({name  => "fail_per_byte_reg",  width => $num_chips_wide * $mem_dq_per_dqs * 4 / 9, never_export => 1, export => 0}),
    	);
        for($i = 0; $i < ($num_chips_wide * $mem_dq_per_dqs * 4 / 9 ); $i++)
            { $fail_per_byte_ones .= "1"; $fail_per_byte_zeros .= "0"; }      
        $fail_per_byte_size = ($num_chips_wide * $mem_dq_per_dqs * 4 / 9 );
    } else {
    	 $module->add_contents
    	 (
    		e_signal->new({name  => "fail_per_byte",  width => $num_chips_wide * $mem_dq_per_dqs * 4 / 8, never_export => 1, export => 0}),
    		e_signal->new({name  => "fail_per_byte_reg",  width => $num_chips_wide * $mem_dq_per_dqs * 4 / 8, never_export => 1, export => 0}),
    	);
        for($i = 0; $i < ($num_chips_wide * $mem_dq_per_dqs * 4 / 8 ); $i++)
            { $fail_per_byte_ones .= "1"; $fail_per_byte_zeros .= "0"; }      
        $fail_per_byte_size = ($num_chips_wide * $mem_dq_per_dqs * 4 / 8 );
    }        
}
########################################   Write Address Generator   ###################################################################
    if($memory_data_width <= 9)
    {
	    $cycle_length_bit = 7;
    	$module->add_contents
    	(
    	    e_assign->new({lhs => "cycle_length_write",rhs => "16'd128"}),
    		e_assign->new({lhs => "cycle_length_read",rhs => "16'd124"}),
        );
    }else
    {
	    $cycle_length_bit = 9;
    	$module->add_contents
    	(
    		e_assign->new({lhs => "cycle_length_write",rhs => "16'd512"}),
    		e_assign->new({lhs => "cycle_length_read",rhs => "16'd508"}),
        );
    }


	$module->add_contents
	(
		e_process->new
		({
			clock	=> "clk",
			reset	=> "reset_n",
			_asynchronous_contents	=>
			[
				e_assign->new({lhs => "state",rhs => "2'b00"}),
				e_assign->new({lhs => "counter_rw",rhs => "16'b".$counter_zeros}),
				e_assign->new({lhs => "counter_addr",rhs => ($memory_address_width + $is_busrt4_narrow + $deep)."'b".$addr_zeros}),
				e_assign->new({lhs => "counter_pause",rhs => "6'b000000"}),
				e_assign->new({lhs => "counter_read",rhs => "16'b".$counter_zeros}),
				e_assign->new({lhs => "avl_write",rhs => "1'b0"}),
				e_assign->new({lhs => "avl_wr_be",rhs => ($wr_be)."'b".$bswn_zeros}),
				e_assign->new({lhs => "avl_read",rhs => "1'b0"}),
				e_assign->new({lhs => "test_complete",rhs => "1'b0"}),
				
			],
			contents	=>
			[
				e_assign->new({lhs => "avl_write",rhs => "1'b0"}),
				e_assign->new({lhs => "avl_read",rhs => "1'b0"}),
				
				e_if->new
				({
					condition	=> "(state == 2'b00)",
					then		=>
					[
						e_assign->new({lhs => "counter_read",rhs => "16'd0"}),
						e_assign->new({lhs => "avl_write",rhs => "1'b1"}),
						e_if->new
						({
							condition	=> "(avl_write_wait == 1'b0)",
							then		=>
							[
								e_assign->news
								(
									["counter_rw", "counter_rw + 16'd1"],
									["counter_addr", "counter_addr + 1"],
								),
							],
						}),
						e_if->new
						({
							condition	=> "(counter_rw[".$cycle_length_bit."] == 1'b1) && (counter_rw[1] == 1'b1)",
							then		=>
							[
								e_assign->news
								(
									["state", "2'b01"],
									["counter_pause", "6'b000000"],
									["avl_write", "1'b0"],
									["counter_rw", "16'b".$counter_zeros],
									["counter_addr", ($memory_address_width + $is_busrt4_narrow + $deep)."'b".$addr_zeros],
								),
							],
						}),
					],
				}),

				e_if->new
				({
					condition	=> "(state == 2'b01)",
					then		=>
					[
						e_if->new
						({
							condition	=> "(counter_pause[5] == 1'b1)",
							then		=>
							[
								e_assign->news
								(
									["state", "2'b10"],
									["counter_pause", "6'b000000"],
									["avl_read", "1'b1"],
								),
							],
						}),
						e_assign->new({lhs => "counter_pause",rhs => "counter_pause + 1"}),
						e_assign->new({lhs => "avl_wr_be",rhs => ($wr_be)."'b".$bswn_ones}),
					],
				}),

				e_if->new
				({
					condition	=> "(state == 2'b10)",
					then		=>
					[
						e_assign->new({lhs => "avl_read",rhs => "1'b1"}),
						e_if->new
						({
							condition	=> "(avl_read_wait == 1'b0)",
							then		=>
							[
								e_assign->news
								(
									["counter_rw", "counter_rw + 16'd1"],
									["counter_addr", "counter_addr + 1"],
								),
							],
						}),
						e_if->new
						({
							condition	=> "(counter_rw[".$cycle_length_bit."] == 1'b1)",
							then		=>
							[
								e_assign->news
								(
									["state", "2'b11"],
									["test_complete","1'b1"],
									["avl_wr_be", ($wr_be)."'b".$bswn_zeros],
									["counter_pause", "6'b000000"],
									["avl_read", "1'b0"],
									["counter_rw", "16'b".$counter_zeros],
									["counter_addr",  ($memory_address_width + $is_busrt4_narrow + $deep)."'b".$addr_zeros],
								),
							],
						}),
					],
				}),

				e_if->new
				({
					condition	=> "(state == 2'b11)",
					then		=>
					[
						e_if->new
						({
							condition	=> "(counter_pause[5] == 1'b1)",
							then		=>
							[
								e_assign->news
								(
									["state", "2'b00"],
									["counter_pause", "6'b000000"],
								),
								e_assign->new({lhs => "avl_write", rhs => "1'b1", comment => " <- set test complete to 1 as well"}),
							],
						}),
						e_assign->new({lhs => "counter_pause",rhs => "counter_pause + 1"}),
					],
				}),
				e_if->new
				({
					condition	=> "(avl_read_data_valid == 1'b1)",
					then		=>
					[
						e_assign->new({lhs => "counter_read",rhs => "counter_read + 16'd1"}),
                    ],
                }),

			],
		}),

		e_assign->new({lhs => "avl_write_addr",rhs => "counter_addr"}),
		e_assign->new({lhs => "avl_read_addr",rhs => "counter_addr"}),
	);




if ($avl_data_width_multiply == 2)
{                    
# need a better comparison method for the fail on a per byte basis    
	$module->add_contents
	(
		e_process->new
		({
			clock	=> "clk",
			reset	=> "reset_n",
			_asynchronous_contents	=>
			[
				e_assign->new({lhs => "fail",rhs => "1'b0"}),
				e_assign->new({lhs => "avl_read_data_valid_reg",rhs => "1'b0"}),
				
				e_assign->new({lhs => "fail_permanent",rhs => "1'b0"}),
				e_assign->new({lhs => "fail_per_byte_reg",rhs => $fail_per_byte_size."'b".$fail_per_byte_zeros}),
			],
			contents	=>
			[
			    e_assign->new({lhs => "fail",rhs => "1'b0"}),
			    e_assign->new({lhs => "avl_read_data_valid_reg",rhs => "avl_read_data_valid"}),
			    e_assign->new({lhs => "fail_per_byte_reg",rhs => "fail_per_byte"}),

				e_if->new
				({
					condition	=> "(avl_read_data_valid_reg == 1'b1)",
					then		=>
					[
						e_if->new
						({
							condition	=> "(fail_per_byte_reg != ".$fail_per_byte_size."'b".$fail_per_byte_ones.")",
							then		=>
							[
								e_assign->new({lhs => "fail",rhs => "1'b1"}),
							],
						}),
					],
				}),

				e_if->new
				({
					condition	=> "(fail == 1'b1)",
					then		=>
					[
						e_assign->new({lhs => "fail_permanent",rhs => "1'b1"}),
					],
				}),
	            ],
        }),

      );

# e_assign->new({lhs => "fail_per_byte",rhs => $fail_per_byte_size."'b".$fail_per_byte_zeros}),


    if (($mem_dq_per_dqs == 9) || ($mem_dq_per_dqs == 18) || ($mem_dq_per_dqs == 36))
    {
    	for(my $k = 0; $k < $num_chips_wide * $mem_dq_per_dqs / 9 ; $k++)
    	{
        	$module->add_contents
        	(
        		e_assign->new({lhs => "avl_write_data[".(($k + 1) * 9 -1).":".($k * 9)."]",rhs => "~counter_rw[".(9 - 1).":0]"}),
        		e_assign->new({lhs => "avl_write_data[".(($k + 1) * 9 + ($num_chips_wide * $mem_dq_per_dqs) -1).":".($k * 9 + ($num_chips_wide * $mem_dq_per_dqs))."]",rhs => "counter_rw[".(9 - 1).":0]"}),
            );	    
        	$module->add_contents
        	(
        		e_assign->new({lhs => "expected_data[".(($k + 1) * 9 -1).":".($k * 9)."]",rhs => "~counter_read[".(9 - 1).":0]"}),
        		e_assign->new({lhs => "expected_data[".(($k + 1) * 9 + ($num_chips_wide * $mem_dq_per_dqs) -1).":".($k * 9 + ($num_chips_wide * $mem_dq_per_dqs))."]",rhs => "counter_read[".(9 - 1).":0]"}),
            );	    
        	$module->add_contents
        	(
                e_assign->new({lhs => "fail_per_byte[".$k."]",rhs => "expected_data[".(($k + 1) * 9 -1).":".($k * 9)."] == avl_read_data[".(($k + 1) * 9 -1).":".($k * 9)."]"}),
                e_assign->new({lhs => "fail_per_byte[".($k + $num_chips_wide * $mem_dq_per_dqs / 9)."]",rhs => "expected_data[".(($k + 1) * 9 + ($num_chips_wide * $mem_dq_per_dqs) -1).":".($k * 9 + ($num_chips_wide * $mem_dq_per_dqs))."] == avl_read_data[".(($k + 1) * 9 + ($num_chips_wide * $mem_dq_per_dqs) -1).":".($k * 9 + ($num_chips_wide * $mem_dq_per_dqs))."]"}),
            );	    
        }
    }else
    {
        # 8 , 16 or 36
    	for(my $k = 0; $k <  $num_chips_wide * $mem_dq_per_dqs / 8; $k++)
    	{
        	$module->add_contents
        	(
        		e_assign->new({lhs => "avl_write_data[".(($k + 1) * 8 - 1 ).":".($k * 8)."]",rhs => "~counter_rw[".(8 - 1).":0]"}),
        		e_assign->new({lhs => "avl_write_data[".(($k + 1) * 8 - 1 + ($num_chips_wide * $mem_dq_per_dqs)).":".($k * 8 + ($num_chips_wide * $mem_dq_per_dqs))."]",rhs => "counter_rw[".(8 - 1).":0]"}),
            );	    
        	$module->add_contents
        	(
        		e_assign->new({lhs => "expected_data[".(($k + 1) * 8 - 1 ).":".($k * 8)."]",rhs => "~counter_read[".(8 - 1).":0]"}),
        		e_assign->new({lhs => "expected_data[".(($k + 1) * 8 - 1 + ($num_chips_wide * $mem_dq_per_dqs)).":".($k * 8 + ($num_chips_wide * $mem_dq_per_dqs))."]",rhs => "counter_read[".(8 - 1).":0]"}),
            );	    
        	$module->add_contents
        	(
                e_assign->new({lhs => "fail_per_byte[".$k."]",rhs => "expected_data[".(($k + 1) * 8 -1).":".($k * 8)."] == avl_read_data[".(($k + 1) * 8 -1).":".($k * 8)."]"}),
                e_assign->new({lhs => "fail_per_byte[".($k + $num_chips_wide * $mem_dq_per_dqs / 8)."]",rhs => "expected_data[".(($k + 1) * 8 + ($num_chips_wide * $mem_dq_per_dqs) -1).":".($k * 8 + ($num_chips_wide * $mem_dq_per_dqs))."] == avl_read_data[".(($k + 1) * 8 + ($num_chips_wide * $mem_dq_per_dqs) -1).":".($k * 8 + ($num_chips_wide * $mem_dq_per_dqs))."]"}),
            );	    
        }

    }
} else {
	$module->add_contents
	(
		e_process->new
		({
			clock	=> "clk",
			reset	=> "reset_n",
			_asynchronous_contents	=>
			[
				e_assign->new({lhs => "fail",rhs => "1'b0"}),
				e_assign->new({lhs => "avl_read_data_valid_reg",rhs => "1'b0"}),
				e_assign->new({lhs => "fail_permanent",rhs => "1'b0"}),
				e_assign->new({lhs => "fail_per_byte_reg",rhs => $fail_per_byte_size."'b".$fail_per_byte_zeros}),
				
			],
			contents	=>
			[
			    e_assign->new({lhs => "fail",rhs => "1'b0"}),
			    e_assign->new({lhs => "avl_read_data_valid_reg",rhs => "avl_read_data_valid"}),
			    e_assign->new({lhs => "fail_per_byte_reg",rhs => "fail_per_byte"}),

				e_if->new
				({
					condition	=> "(avl_read_data_valid_reg == 1'b1)",
					then		=>
					[
						e_if->new
						({
							condition	=> "(fail_per_byte_reg != ".$fail_per_byte_size."'b".$fail_per_byte_ones.")",
							then		=>
							[
								e_assign->new({lhs => "fail",rhs => "1'b1"}),
							],
						}),
					],
				}),

				e_if->new
				({
					condition	=> "(fail == 1'b1)",
					then		=>
					[
						e_assign->new({lhs => "fail_permanent",rhs => "1'b1"}),
					],
				}),
	            ],
        }),

    );
    if (($mem_dq_per_dqs == 9) || ($mem_dq_per_dqs == 18) || ($mem_dq_per_dqs == 36))
    {
    	for(my $k = 0; $k <  $num_chips_wide * $mem_dq_per_dqs / 9; $k++)
    	{
        	$module->add_contents
        	(
        		e_assign->new({lhs => "avl_write_data[".(($k + 1) * 9 -1).":".($k * 9)."]",rhs => "counter_rw[".(9 - 1).":0]"}),
        		e_assign->new({lhs => "avl_write_data[".(($k + 1) * 9 + ($num_chips_wide * $mem_dq_per_dqs) -1).":".($k * 9 + ($num_chips_wide * $mem_dq_per_dqs))."]",rhs => "~counter_rw[".(9 - 1).":0]"}),
        		e_assign->new({lhs => "avl_write_data[".(($k + 1) * 9 + ($num_chips_wide * $mem_dq_per_dqs * 2) -1).":".($k * 9 + ($num_chips_wide * $mem_dq_per_dqs * 2))."]",rhs => "~counter_rw[".(9 - 1).":0]"}),
        		e_assign->new({lhs => "avl_write_data[".(($k + 1) * 9 + ($num_chips_wide * $mem_dq_per_dqs * 3) -1).":".($k * 9 + ($num_chips_wide * $mem_dq_per_dqs * 3))."]",rhs => "counter_rw[".(9 - 1).":0]"}),
            );	    
        	$module->add_contents
        	(
        		e_assign->new({lhs => "expected_data[".(($k + 1) * 9 -1).":".($k * 9)."]",rhs => "counter_read[".(9 - 1).":0]"}),
        		e_assign->new({lhs => "expected_data[".(($k + 1) * 9 + ($num_chips_wide * $mem_dq_per_dqs) -1).":".($k * 9 + ($num_chips_wide * $mem_dq_per_dqs))."]",rhs => "~counter_read[".(9 - 1).":0]"}),
        		e_assign->new({lhs => "expected_data[".(($k + 1) * 9 + ($num_chips_wide * $mem_dq_per_dqs * 2) -1).":".($k * 9 + ($num_chips_wide * $mem_dq_per_dqs * 2))."]",rhs => "~counter_read[".(9 - 1).":0]"}),
        		e_assign->new({lhs => "expected_data[".(($k + 1) * 9 + ($num_chips_wide * $mem_dq_per_dqs * 3) -1).":".($k * 9 + ($num_chips_wide * $mem_dq_per_dqs * 3))."]",rhs => "counter_read[".(9 - 1).":0]"}),
            );	    
        	$module->add_contents
        	(
                e_assign->new({lhs => "fail_per_byte[".$k."]",rhs => "expected_data[".(($k + 1) * 9 -1).":".($k * 9)."] == avl_read_data[".(($k + 1) * 9 -1).":".($k * 9)."]"}),
                e_assign->new({lhs => "fail_per_byte[".($k + $num_chips_wide * $mem_dq_per_dqs / 9)."]",rhs => "expected_data[".(($k + 1) * 9 + ($num_chips_wide * $mem_dq_per_dqs) -1).":".($k * 9 + ($num_chips_wide * $mem_dq_per_dqs))."] == avl_read_data[".(($k + 1) * 9 + ($num_chips_wide * $mem_dq_per_dqs) -1).":".($k * 9 + ($num_chips_wide * $mem_dq_per_dqs))."]"}),
                e_assign->new({lhs => "fail_per_byte[".($k + $num_chips_wide * $mem_dq_per_dqs * 2 / 9)."]",rhs => "expected_data[".(($k + 1) * 9 + ($num_chips_wide * $mem_dq_per_dqs * 2) -1).":".($k * 9 + ($num_chips_wide * $mem_dq_per_dqs * 2))."] == avl_read_data[".(($k + 1) * 9 + ($num_chips_wide * $mem_dq_per_dqs * 2) -1).":".($k * 9 + ($num_chips_wide * $mem_dq_per_dqs * 2))."]"}),
                e_assign->new({lhs => "fail_per_byte[".($k + $num_chips_wide * $mem_dq_per_dqs * 3 / 9)."]",rhs => "expected_data[".(($k + 1) * 9 + ($num_chips_wide * $mem_dq_per_dqs * 3) -1).":".($k * 9 + ($num_chips_wide * $mem_dq_per_dqs * 3 ))."] == avl_read_data[".(($k + 1) * 9 + ($num_chips_wide * $mem_dq_per_dqs * 3) -1).":".($k * 9 + ($num_chips_wide * $mem_dq_per_dqs * 3))."]"}),
            );	    

        }
    }else
    {
        # 8 , 16 or 36
    	for(my $k = 0; $k <  $num_chips_wide * $mem_dq_per_dqs / 8; $k++)
    	{
        	$module->add_contents
        	(
        		e_assign->new({lhs => "avl_write_data[".(($k + 1) * 8 -1).":".($k * 8)."]",rhs => "counter_rw[".(8 - 1).":0]"}),
        		e_assign->new({lhs => "avl_write_data[".(($k + 1) * 8 + ($num_chips_wide * $mem_dq_per_dqs) -1).":".($k * 8 + ($num_chips_wide * $mem_dq_per_dqs))."]",rhs => "~counter_rw[".(8 - 1).":0]"}),
        		e_assign->new({lhs => "avl_write_data[".(($k + 1) * 8 + ($num_chips_wide * $mem_dq_per_dqs * 2) -1).":".($k * 8 + ($num_chips_wide * $mem_dq_per_dqs * 2))."]",rhs => "~counter_rw[".(8 - 1).":0]"}),
        		e_assign->new({lhs => "avl_write_data[".(($k + 1) * 8 + ($num_chips_wide * $mem_dq_per_dqs * 3) -1).":".($k * 8 + ($num_chips_wide * $mem_dq_per_dqs * 3))."]",rhs => "counter_rw[".(8 - 1).":0]"}),
            );	    
        	$module->add_contents
        	(
        		e_assign->new({lhs => "expected_data[".(($k + 1) * 8 -1).":".($k * 8)."]",rhs => "counter_read[".(8 - 1).":0]"}),
        		e_assign->new({lhs => "expected_data[".(($k + 1) * 8 + ($num_chips_wide * $mem_dq_per_dqs) -1).":".($k * 8 + ($num_chips_wide * $mem_dq_per_dqs))."]",rhs => "~counter_read[".(8 - 1).":0]"}),
        		e_assign->new({lhs => "expected_data[".(($k + 1) * 8 + ($num_chips_wide * $mem_dq_per_dqs * 2) -1).":".($k * 8 + ($num_chips_wide * $mem_dq_per_dqs * 2))."]",rhs => "~counter_read[".(8 - 1).":0]"}),
        		e_assign->new({lhs => "expected_data[".(($k + 1) * 8 + ($num_chips_wide * $mem_dq_per_dqs * 3) -1).":".($k * 8 + ($num_chips_wide * $mem_dq_per_dqs * 3))."]",rhs => "counter_read[".(8 - 1).":0]"}),
            );	    
        	$module->add_contents
        	(
                e_assign->new({lhs => "fail_per_byte[".$k."]",rhs => "expected_data[".(($k + 1) * 8 -1).":".($k * 8)."] == avl_read_data[".(($k + 1) * 8 -1).":".($k * 8)."]"}),
                e_assign->new({lhs => "fail_per_byte[".($k + $num_chips_wide * $mem_dq_per_dqs / 8)."]",rhs => "expected_data[".(($k + 1) * 8 + ($num_chips_wide * $mem_dq_per_dqs) -1).":".($k * 8 + ($num_chips_wide * $mem_dq_per_dqs))."] == avl_read_data[".(($k + 1) * 8 + ($num_chips_wide * $mem_dq_per_dqs) -1).":".($k * 8 + ($num_chips_wide * $mem_dq_per_dqs))."]"}),
                e_assign->new({lhs => "fail_per_byte[".($k + $num_chips_wide * $mem_dq_per_dqs * 2/ 8)."]",rhs => "expected_data[".(($k + 1) * 8 + ($num_chips_wide * $mem_dq_per_dqs * 2) -1).":".($k * 8 + ($num_chips_wide * $mem_dq_per_dqs * 2))."] == avl_read_data[".(($k + 1) * 8 + ($num_chips_wide * $mem_dq_per_dqs * 2) -1).":".($k * 8 + ($num_chips_wide * $mem_dq_per_dqs * 2))."]"}),
                e_assign->new({lhs => "fail_per_byte[".($k + $num_chips_wide * $mem_dq_per_dqs * 3/ 8)."]",rhs => "expected_data[".(($k + 1) * 8 + ($num_chips_wide * $mem_dq_per_dqs * 3) -1).":".($k * 8 + ($num_chips_wide * $mem_dq_per_dqs * 3))."] == avl_read_data[".(($k + 1) * 8 + ($num_chips_wide * $mem_dq_per_dqs * 3) -1).":".($k * 8 + ($num_chips_wide * $mem_dq_per_dqs * 3))."]"}),
            );	    

        }
    }

}







######################################################################################################################################################################
$project->output();
}
1;
#You're done..
