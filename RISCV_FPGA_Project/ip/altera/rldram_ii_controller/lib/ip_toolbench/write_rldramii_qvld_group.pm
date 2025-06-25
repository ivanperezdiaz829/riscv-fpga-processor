#sopc_builder free code
use europa_all; 
use europa_utils;
use e_lpm_stratixii_io;
use e_lpm_stratixiigx_io;
use e_lpm_hardcopyii_io;

sub write_rldramii_qvld_group
{
my $top = e_module->new({name => $gWRAPPER_NAME."_auk_rldramii_qvld_group"});#, output_file => 'd:/OFadeyi/DATA_PATH/temp_gen/'});
my $project = e_project->new({top => $top, language => $language,__system_directory =>$output_directory, timescale => "1ps / 1ps"});#'temp_gen'});
my $module = $project->top();



my $header_title = "Datapath for the Altera DDR SDRAM Controller";
my $header_filename = $gWRAPPER_NAME . "_auk_rldramii_qvld_group" . $file_ext;
my $header_revision = "V" . $gWIZARD_VERSION;
my $header_abstract = "RLDRAM II Controller QVLD Group.";


my $family = $gFAMILY;
my $familylc = $gFAMILYlc;

$module->vhdl_libraries()->{$familylc} = all;
my $io_elem = "e_lpm_".$familylc."_io";
if ($familylc eq "stratixiigx"){
	$io_modName = "stratixii_gx_io";
}else{
	$io_modName = $familylc."_io";
}
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
my $cap_qvld_clk_width;
my $ENABLE_CAPTURE_CLK = $gENABLE_CAPTURE_CLK;

if ($ENABLE_CAPTURE_CLK eq "true") {
	$INCLK_INPUT = "normal";
} else {
	#$INCLK_INPUT = "normal";
	$INCLK_INPUT = "dqs_bus";
	#$INCLK_INPUT = "normal";
}
######################################################################################################################################################################
##Checking the local data mode(Narrow or Wide)
if($local_data_mode eq "narrow")
{
	$cap_qvld_clk_width = int($local_data_bits / $mem_dq_per_dqs / 2);
}elsif($local_data_mode eq "wide")
{
	$cap_qvld_clk_width =  int($local_data_bits / $local_burst_len / $mem_dq_per_dqs / 2);
}

######################################################################################################################################################################
	#$module->vhdl_libraries()->{stratixii} = all;
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
		e_port->new({name => "clk",direction => "input"}),
		e_port->new({name => "reset_read_clk_n",direction => "input"}),

	##QVLD GROUP input and output signal
		e_port->new({name => "control_qvld",direction => "output", width => 1 , declare_one_bit_as_std_logic_vector => 0}),
		
		e_port->new({name => "rldramii_qvld",direction => "input", width => 1 , declare_one_bit_as_std_logic_vector => 0}),
	##Internal signal
	);

######################################################################################################################################################################	
	# $module->add_contents
	# (
		# e_signal->new({name => "control_qvld_r", width => 1 , export => 0, never_export => 1, declare_one_bit_as_std_logic_vector => 1}),
		# e_signal->new({name => "rd_compare", width => 1 , export => 0, never_export => 1, declare_one_bit_as_std_logic_vector => 1}),
	# );
	# 
# ######################################################################################################################################################################
	# $module->add_contents
	# (
		# e_process->new
		# ({
			# clock			=> "clk",
			# reset			=> "reset_n",
			# clock_level		=> "0",
			# _asynchronous_contents  =>
			# [
				# e_assign->new({lhs => "control_qvld_r", rhs => 0 }),
			# ],
			# _contents		=>
			# [
				# e_assign->new({lhs => "control_qvld_r", rhs => "rldramii_qvld" }),
			# ],
		# }),
	# );
# ######################################################################################################################################################################
# 
	# $module->add_contents
	# (
		# e_process->new
		# ({
			# clock			=> "clk",
			# reset			=> "reset_n",
			# _asynchronous_contents  =>
			# [
				# e_assign->new({lhs => "control_qvld", rhs => 0 }),
			# ],
			# _contents		=>
			# [
				# e_assign->new({lhs => "control_qvld", rhs => "control_qvld_r" }),
			# ],
		# }),
	# );
######################################################################################################################################################################

	$module->add_contents
	(
		e_signal->new({name => "control_qvld_r", width => 1 , export => 0, never_export => 1, declare_one_bit_as_std_logic_vector => 1}),
		e_signal->new({name => "rd_compare", width => 1 , export => 0, never_export => 1, declare_one_bit_as_std_logic_vector => 1}),
		e_signal->new({name => "reset", width => 1 , export => 0, never_export => 1}),
		e_signal->new({name => "ONE", width => 1 , export => 0, never_export => 1}),
		e_signal->new({name => "ZERO", width => 1 , export => 0, never_export => 1}),
		e_signal->new({name => "ZEROS", width => 6 , export => 0, never_export => 1}),
		e_signal->new({name => "qvld_pin", width => 1 , export => 0, never_export => 1}),
	);

######################################################################################################################################################################	
	$module->add_contents
	(
		e_assign->new({lhs => "reset", rhs => "! reset_read_clk_n" }),
		e_assign->new({lhs => "ONE", rhs => "1'b1"}),
		e_assign->new({lhs => "ZERO", rhs => "1'b0"}),
		e_assign->new({lhs => "qvld_pin", rhs => "rldramii_qvld[0]"}),
	);
	
######################################################################################################################################################################	
	$module->add_contents
	(
			$io_elem->new
			({
				name 		=> qvld_capture,
				module 		=> $familylc."_io",
				#_use_generated_component=>0,
				#in_port_map 	=>
				port_map 	=>
				{
					areset          => "reset",
					#datain          => "ZERO",
					#ddiodatain      => "ZERO",
					inclkena        => "ONE",
					inclk           => "clk",
					#outclkena       => "ONE",
					#outclk          => "ZERO",
					#oe              => "ZERO",
					ddioinclk	=> "ZERO",
					#sreset      	=> "ZERO",
				#},
				#inout_port_map	=>
				#{
					padio           => "qvld_pin",
				#},
				#out_port_map	=>
				#{
					ddioregout  	=> "control_qvld[0]",
					#ddioregout  	=> "open",
					#regout      	=> "control_qvld[0]",
					regout      	=> "open",
					dqsbusout   	=> "open",
					combout	    	=> "open",
				},
				#std_logic_vector_signals =>
				#[
				#	delayctrlin,
				#],
				#_port_default_values =>
				#{
				#	 delayctrlin	=> "6",
				#},
				parameter_map 	=>
				{
					ddio_mode            		=>  '"input"',#'"bidir"',
					ddioinclk_input      		=>  '"negated_inclk"',
					extend_oe_disable    		=>  '"false"',
					operation_mode       		=>  '"input"',#'"bidir"',
					inclk_input          		=>  '"'.$INCLK_INPUT.'"',
					#inclk_input          		=>  '"normal"',
					#inclk_input          		=>  '"dqs_bus"',
					input_async_reset    		=>  '"clear"',
					input_power_up      		=>  '"low"',
					input_register_mode  		=>  '"register"',
					input_sync_reset  		=>  '"none"',
					
					oe_async_reset       		=>  '"none"',#'"clear"',
					oe_power_up         		=>  '"low"',
					oe_register_mode     		=>  '"none"',#'"register"',
					oe_sync_reset  			=>  '"none"',
					
					output_async_reset   		=>  '"none"',
					output_power_up      		=>  '"low"',
					output_register_mode 		=>  '"none"',
					output_sync_reset 		=>  '"none"',
					
					bus_hold 			=>  '"false"',
					sim_dqs_delay_increment 	=>  0,
					sim_dqs_intrinsic_delay 	=>  0,
					sim_dqs_offset_increment 	=>  0,
					tie_off_oe_clock_enable 	=>  '"false"',
					tie_off_output_clock_enable 	=>  '"false"',
					dqs_input_frequency  		=>  '"none"',
					dqs_out_mode  			=>  '"none"',
					dqs_delay_buffer_mode  		=>  '"none"',
					dqs_phase_shift 		=>  0,
					dqs_offsetctrl_enable  		=>  '"false"',
					dqs_ctrl_latches_enable  	=>  '"false"',
					dqs_edge_detect_enable  	=>  '"false"',
					gated_dqs  			=>  '"false"',
					lpm_type  			=>  '"'.$familylc."_io".'"',
					open_drain_output  		=>  '"false"',
				},
			}),
			
	);

$project->output();
}

1;
#You're done.
