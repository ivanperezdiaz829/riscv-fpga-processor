#sopc_builder free code
use europa_all; 
use europa_utils;


sub write_rldramii_addr_cmd_out_reg
{
my $top = e_module->new({name => $gWRAPPER_NAME."_auk_rldramii_addr_cmd_reg"});#, output_file => 'd:/OFadeyi/DATA_PATH/temp_gen/'});
my $project = e_project->new({top => $top, language => $language,__system_directory =>$output_directory , timescale => "1ps / 1ps"});#'temp_gen'});
my $module = $project->top();



my $header_title = "RLDRAM II Controller Address and Command Output Register Module";
my $header_filename = $gWRAPPER_NAME . "_auk_rldramii_addr_cmd_reg" . $file_ext;
my $header_revision = "V" . $gWIZARD_VERSION;
my $header_abstract = "This file contains the address and command output registers for the RLDRAM II Controller.";

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
my $insert_addr_cmd_negedge_reg = $gINSERT_ADDR_CMD_NEGEDGE_REG;
my $device_clk = "clk";
my $device_clk_edge = "1";
my $device_clk_edge_s = "positive";

######################################################################################################################################################################
##Checking the which clk and which edge should be used to present the address and command bits to the memory
if($enable_addr_cmd_clk eq "true")
{
	$device_clk = "addr_cmd_clk";

}
if($addr_cmd_negedge eq "true")
{
	$device_clk_edge =  "0";
	$device_clk_edge_s = "negative";
}

######################################################################################################################################################################
	$module->comment
	(
		"------------------------------------------------------------------------------\n
		 Title        : $header_title\n
		 Project      : RLDRAM II Controller\n\n
		 File         : $header_filename\n\n
		 Revision     : $header_revision\n\n
		 Abstract:\n$header_abstract\n\n		
		------------------------------------------------------------------------------\n
		 Parameters:\n\n		
		 Insert Negedge Register            : $insert_addr_cmd_negedge_reg\n
		 Address & Command Clock            : $device_clk\n
		 Address & Command Clocking Edge    : $device_clk_edge_s\n
		------------------------------------------------------------------------------"
	);
######################################################################################################################################################################
	$module->add_contents
	(
	#####	Ports declaration#	######
		e_port->new({name => "clk",direction => "input",}),
		e_port->new({name => "reset_clk_n",direction => "input"}),
		e_port->new({name => "$device_clk",direction => "input"}),
		e_port->new({name => "reset_addr_cmd_clk_n",direction => "input"}),
		e_port->new({name => "addr_cmd_clk",direction => "input"}),
		
	##Addr & Cmd Output Reg input and output signal
		e_port->new({name => "control_cs_n",direction => "input", width => 1}),
		e_port->new({name => "control_we_n",direction => "input", width => 1}),
		e_port->new({name => "control_ref_n",direction => "input", width => 1}),
		e_port->new({name => "control_a",direction => "input", width => $mem_addr_bits,declare_one_bit_as_std_logic_vector => 1}),
		e_port->new({name => "control_ba",direction => "input", width => 3,declare_one_bit_as_std_logic_vector => 1}),
		
		e_port->new({name => "rldramii_cs_n",direction => "output", width => 1}),
		e_port->new({name => "rldramii_we_n",direction => "output", width => 1}),
		e_port->new({name => "rldramii_ref_n",direction => "output", width => 1}),
		e_port->new({name => "rldramii_a",direction => "output", width => $mem_addr_bits,declare_one_bit_as_std_logic_vector => 1}),
		e_port->new({name => "rldramii_ba",direction => "output", width => 3,declare_one_bit_as_std_logic_vector => 1}),
	##Internal signal
	);
######################################################################################################################################################################

$module->add_contents
	 (
	 #####   signal generation #####
          	e_signal->news #: ["signal", width, export, never_export]
		(	 
	         	["out_reg_clk",1,	0,	1],
			["control_ba_nr",3,	0,	1],
			["control_a_nr",$mem_addr_bits,	0,	1],
			["control_cs_n_nr",1,	0,	1],
			["control_we_n_nr",1,	0,	1],
			["control_ref_n_nr",1,	0,	1],
			["control_ba_r",3,	0,	1],
			["control_a_r",$mem_addr_bits,	0,	1],
			["control_cs_n_r",1,	0,	1],
			["control_we_n_r",1,	0,	1],
			["control_ref_n_r",1,	0,	1],
			["control_ba_r_int",3,	0,	1],
			["control_a_r_int",$mem_addr_bits,	0,	1],
			["control_cs_n_r_int",1,	0,	1],
			["control_we_n_r_int",1,	0,	1],
			["control_ref_n_r_int",1,	0,	1],
		),
		
		#e_assign->new({lhs => "out_reg_clk", rhs => $device_clk}),
		
	);
	
######################################################################################################################################################################

	if($insert_addr_cmd_negedge_reg eq "true") {
		$module->add_contents
		(
			e_process->new
			({
				clock			=> "clk",
				reset			=> "reset_clk_n",
				clock_level		=> "0",
				_asynchronous_contents  =>
				[
					e_assign->new({lhs => "control_cs_n_nr", rhs => 1 }),
					e_assign->new({lhs => "control_we_n_nr", rhs => 1 }),
					e_assign->new({lhs => "control_ref_n_nr",rhs => 1 }),
					e_assign->new({lhs => "control_a_nr", rhs => 0 }),
					e_assign->new({lhs => "control_ba_nr", rhs => 0 }),
				],
				_contents		=>
				[
					e_assign->new({lhs => "control_cs_n_nr", rhs => "control_cs_n" }),
					e_assign->new({lhs => "control_we_n_nr", rhs => "control_we_n" }),
					e_assign->new({lhs => "control_ref_n_nr", rhs => "control_ref_n" }),
					e_assign->new({lhs => "control_a_nr", rhs => "control_a" }),
					e_assign->new({lhs => "control_ba_nr", rhs => "control_ba" }),
				],
			}),
		);
		
	
		$module->add_contents
		(
			e_process->new
			({
				clock			=> $device_clk,
				reset			=> "reset_addr_cmd_clk_n",
				clock_level		=> $device_clk_edge,
				_asynchronous_contents  =>
				[
					e_assign->new({lhs => "control_cs_n_r", rhs => 1 }),
					e_assign->new({lhs => "control_we_n_r", rhs => 1 }),
					e_assign->new({lhs => "control_ref_n_r",rhs => 1 }),
					e_assign->new({lhs => "control_a_r", rhs => 0 }),
					e_assign->new({lhs => "control_ba_r", rhs => 0 }),
				],
				_contents		=>
				[
					e_assign->new({lhs => "control_cs_n_r", rhs => "control_cs_n_nr" }),
					e_assign->new({lhs => "control_we_n_r", rhs => "control_we_n_nr" }),
					e_assign->new({lhs => "control_ref_n_r", rhs => "control_ref_n_nr" }),
					e_assign->new({lhs => "control_a_r", rhs => "control_a_nr" }),
					e_assign->new({lhs => "control_ba_r", rhs => "control_ba_nr" }),
					
				],
			}),
			
			e_assign->new({lhs => "rldramii_cs_n", rhs => "control_cs_n_r" }),
			e_assign->new({lhs => "rldramii_we_n", rhs => "control_we_n_r" }),
			e_assign->new({lhs => "rldramii_ref_n", rhs => "control_ref_n_r" }),
			e_assign->new({lhs => "rldramii_a", rhs => "control_a_r" }),
			e_assign->new({lhs => "rldramii_ba", rhs => "control_ba_r" }),
		);
	} else {
		$module->add_contents
		(
			#e_process->new
			#({
				
				e_register->new
				({
				     clock		=>	$device_clk,
				     reset		=>	"reset_addr_cmd_clk_n",
				     _async_value	=>	"1",
				     clock_level	=>	$device_clk_edge,
				     in			=>	"control_cs_n",
				     out		=>	"control_cs_n_r",
				     enable  		=> 	"1",
				     preserve_register  =>	"0", #SPR 304856 fix
				}),
				
				e_register->new
				({
				     clock		=>	$device_clk,
				     reset		=>	"reset_addr_cmd_clk_n",
				     _async_value	=>	"1",
				     clock_level	=>	$device_clk_edge,
				     in			=>	"control_we_n",
				     out		=>	"control_we_n_r",
				     enable  		=> 	"1",
				     preserve_register  =>	"0", #SPR 304856 fix
				}),
				
				e_register->new
				({
				     clock		=>	$device_clk,
				     reset		=>	"reset_addr_cmd_clk_n",
				     _async_value	=>	"1",
				     clock_level	=>	$device_clk_edge,
				     in			=>	"control_ref_n",
				     out		=>	"control_ref_n_r",
				     enable  		=> 	"1",
				     preserve_register  =>	"0", #SPR 304856 fix
				}),
				
				e_register->new
				({
				     clock		=>	$device_clk,
				     reset		=>	"reset_addr_cmd_clk_n",
				     clock_level	=>	$device_clk_edge,
				     in			=>	"control_ba",
				     out		=>	"control_ba_r",
				     enable  		=> 	"1",
				     preserve_register  =>	"0", #SPR 304856 fix
				}),
				
				e_register->new
				({
				     clock		=>	$device_clk,
				     reset		=>	"reset_addr_cmd_clk_n",
				     clock_level	=>	$device_clk_edge,
				     in			=>	"control_a",
				     out		=>	"control_a_r",
				     enable  		=> 	"1",
				     preserve_register  =>	"0", #SPR 304856 fix
				}),
				
				
				# clock			=> $device_clk,
				# #clock			=> "out_reg_clk",
				# reset			=> "reset_addr_cmd_clk_n",
				# clock_level		=> $device_clk_edge,
				# _asynchronous_contents  =>
				# [
					# e_assign->new({lhs => "control_cs_n_r", rhs => 1 }),
					# e_assign->new({lhs => "control_we_n_r", rhs => 1 }),
					# e_assign->new({lhs => "control_ref_n_r",rhs => 1 }),
					# e_assign->new({lhs => "control_a_r", rhs => 0 }),
					# e_assign->new({lhs => "control_ba_r", rhs => 0 }),
				# ],
				# _contents		=>
				# [
					# e_assign->new({lhs => "control_cs_n_r", rhs => "control_cs_n" }),
					# e_assign->new({lhs => "control_we_n_r", rhs => "control_we_n" }),
					# e_assign->new({lhs => "control_ref_n_r", rhs => "control_ref_n" }),
					# e_assign->new({lhs => "control_a_r", rhs => "control_a" }),
					# e_assign->new({lhs => "control_ba_r", rhs => "control_ba" }),
				# ],
			#}),
			
			
			e_assign->new({lhs => "rldramii_cs_n", rhs => "control_cs_n_r" }),
			e_assign->new({lhs => "rldramii_we_n", rhs => "control_we_n_r" }),
			e_assign->new({lhs => "rldramii_ref_n", rhs => "control_ref_n_r" }),
			e_assign->new({lhs => "rldramii_a", rhs => "control_a_r" }),
			e_assign->new({lhs => "rldramii_ba", rhs => "control_ba_r" }),
		);
	}
  
####################################################################################################################################################################
$project->output();
}

1;
#You're done.
