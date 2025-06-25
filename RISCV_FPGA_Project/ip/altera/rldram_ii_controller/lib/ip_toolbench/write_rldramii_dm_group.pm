#sopc_builder free code
use europa_all; 
use europa_utils;


sub write_rldramii_dm_group
{
my $top = e_module->new({name => $gWRAPPER_NAME."_auk_rldramii_dm_group"});#, output_file => 'd:/OFadeyi/DATA_PATH/temp_gen/'});
my $project = e_project->new({top => $top, language => $language,__system_directory =>$output_directory, timescale => "1ps / 1ps"});#'temp_gen'});
my $module = $project->top();

$module->vhdl_libraries()->{altera_mf} = all;

my $header_title = "RLDRAM II Controller DM Group";
my $header_filename = $gWRAPPER_NAME . "_auk_rldramii_dm_group" . $file_ext;
my $header_revision = "V" . $gWIZARD_VERSION;
my $header_abstract = "This file contains the DM generation logic for the RLDRAM II Controller.";

my $local_data_mode = $gLOCAL_DATA_MODE;
my $local_burst_len = $gLOCAL_BURST_LEN;
my $local_data_bits = $gLOCAL_DATA_BITS;
my $mem_dq_per_dqs = $gMEM_DQ_PER_DQS;
my $mem_addr_bits = $mem_addr_bits;
my $num_clock_pairs = $num_clock_pairs;
my $mem_addr_bits = $gMEM_ADDR_BITS;
my $mem_num_devices = $gMEM_NUM_DEVICES;
my $enable_addr_cmd_clk = $gENABLE_ADDR_CMD_CLK;
my $addr_cmd_negedge = $gADDR_CMD_NEGEDGE;
my $mem_num_device = $gMEM_NUM_DEVICE;
my $device_clk = "clk";
my $device_clk_edge = "1";
my $device_clk_edge_s = "positive";
my $cap_dm_clk_width;


######################################################################################################################################################################
	$module->comment
	(
		"------------------------------------------------------------------------------\n
		 Title        : $header_title\n
		 Project      : RLDRAM II Controller\n\n
		 File         : $header_filename\n\n
		 Revision     : $header_revision\n\n
		 Abstract:\n$header_abstract\n\n		
		------------------------------------------------------------------------------"
	);
######################################################################################################################################################################
	$module->add_contents
	(
	#####	Ports declaration#	######
		e_port->new({name => "clk",direction => "input",}),
		e_port->new({name => "write_clk",direction => "input",}),
		#e_port->new({name => "reset_n",direction => "input"}),

	##DM GROUP input and output signal
		e_port->new({name => "control_doing_wr",direction => "input",width => 1}),
		e_port->new({name => "control_dm",direction => "input", width => 2 }),
		e_port->new({name => "rldramii_dm",direction => "output", width => 1}),
	##Internal signal
		e_signal->new({name => "dm_out",width => 2, export => 0, never_export => 1}),
		e_signal->new({name => "dm",width => 2, export => 0, never_export => 1}),
		e_signal->new({name => "dm_out_int",width => 2, export => 0, never_export => 1}),
		e_signal->new({name => "ONE",width => 1, export => 0, never_export => 1}),
		#e_signal->new({name => "reset",width => 1, export => 0, never_export => 1}),
		e_assign->new({lhs => "ONE", rhs => "1'b1", comment => "\n\n"}),
		e_assign->new(["dm" => "control_dm"]),
		#e_assign->new(["reset" => "~reset_n"]),
		#e_assign->new(["reset" => "0"]),
	);
######################################################################################################################################################################

$module->add_contents
 (
 	e_comment->new
	({
		comment => 	"-------------------------------------------------------------------------------\n
				  Data mask registers\n
				  These are the last registers before the registers in the altddio_out. They\n
				  are clocked off the system clock but feed registers which are clocked off the\n
				  write clock, so their output is the beginning of 3/4 cycle path.\n
    				 -------------------------------------------------------------------------------\n"
	}),
	 # e_process->new
	 # ({
		 # clock			=> "clk",
		 # #reset			=> "reset_n",
		 # # _asynchronous_contents  =>
		 # # [
			 # # e_assign->new({lhs => "dm_out", rhs => 0 }),
		 # # ],
		 # _contents		=>
		 # [
			 # e_if->new
			 # ({
				 # condition	=> "clk",
				 # then		=> 
				 # [
				  	# e_if->new
				  	# ({
						# condition	=> "control_doing_wr",
						# then		=>
						# [
						# e_assign->new({lhs => "dm_out", rhs => "~dm"}),
						# ],
						# else		=>
						# [
							# e_assign->new({lhs => "dm_out", rhs => "3"}),
						# ],
					# }),
				 # ],
			# }),
		# ],
	 # }),
	 

	e_process->new
        ({
                  clock          =>  "",
                  reset          =>  "",
                  comment            =>
                  "-----------------------------------------------------------------------------\n
                    Hold DM output at 1 unless actually doing a write\n
                   -----------------------------------------------------------------------------",
                  sensitivity_list       =>["dm","control_doing_wr"],
                  contents   =>
                  [
		  	e_if->new
			({
				condition   => "control_doing_wr",
				then        => [ e_assign->new({lhs => "dm_out_int",rhs => "dm"}), ],
				else        => [ e_assign->new({lhs => "dm_out_int",rhs => "{2{1'b1}}"}), ],
			}),
                  ],
        }),

	 e_register->new
	 ({
		 clock			=>	"clk",
		 reset			=>	'',
		 in			=>	"dm_out_int",
		 out			=>	"dm_out",
		 preserve_register  	=>	"1",
		 enable			=>	"",
		 #_sync_set		=>	"control_doing_wr",
		 #_set_value		=> 	"2'b11",#"~dm",
		 #_async_value		=>	"2'b11",
	}),

 );
#	
######################################################################################################################################################################


$module->add_contents
(
	e_comment->new({comment		=>
		"-----------------------------------------------------------------------------\n
		 DM pins and their logic\n
		 -----------------------------------------------------------------------------\n"}),
	e_blind_instance->new
	({
		name 		=> "dm_pin",
		module 		=> "altddio_out",
		in_port_map 	=>
		{
			#aclr        => "reset",
			datain_h    => "dm_out[0]",
			datain_l    => "dm_out[1]",
			oe          => "ONE",
			outclock    => "write_clk",
			outclocken  => "ONE",
		},
		out_port_map	=>
		{
			dataout     => "rldramii_dm",				
		},
		parameter_map	=>
		{
			width                   => 1,
			intended_device_family  => '"'.$gFAMILY.'"',
			oe_reg                  => '"UNUSED"',
			#extend_oe_disable       => '"UNUSED"',
			#extend_oe_disable 	=> '"FALSE"',
			lpm_type                => '"altddio_out"',
		},
		std_logic_vector_signals =>
		[
			datain_h,
			datain_l,
			dataout,
		],
	}),
);
######################################################################################################################################################################
$project->output();
}

1;
#You're done.
