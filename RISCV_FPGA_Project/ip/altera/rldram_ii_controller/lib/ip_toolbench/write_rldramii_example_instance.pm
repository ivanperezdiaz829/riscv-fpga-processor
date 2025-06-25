#sopc_builder free codeclk

use europa_all; 
use europa_utils;
use e_comment;

sub get_value{
	my $input = shift;
	my $var = 1;
	for ($i=0;$i<$input; $i++) 
	{
		$var *= 2;
	}
	return $var;
}

sub write_rldramii_example_instance

{
#my $top = e_module->new({name => $gTOPLEVEL_NAME});#,output_file => "/temp_gen/${gWRAPPER_NAME}_example_driver"});
my $top = e_module->new({name => $gTOPLEVEL_NAME});#,output_file => "/temp_gen/${gWRAPPER_NAME}_example_driver"});
my $project = e_project->new({top => $top, language => $language,__system_directory =>$output_directory});#'temp_gen'});
my $module = $project->top();
#####   Parameters declaration  ######
$header_title = "RLDRAM II Controller Example Instance";
$header_filename = $gTOPLEVEL_NAME;
$header_revision = "V" . $gWIZARD_VERSION;
#my $verilog_dq_io_instname;# = "\\g_datapath:\$i:g_ddr_io ";
my $Stratix_Fam = "";
my %stratix_param  = "";
my $family = $gFAMILY;
my $familylc = $gFAMILYlc;

$module->vhdl_libraries()->{$familylc} = all;
my $CLOCK_PERIOD_IN_PS = $gCLOCK_PERIOD_IN_PS;
my $FEDBACK_PHASE_SHIFT = $gFEDBACK_PHASE_SHIFT;
my $STRATIXII_DLL_DELAY_BUFFER_MODE = $gSTRATIXII_DLL_DELAY_BUFFER_MODE;
my $STRATIXII_DLL_DELAY_CHAIN_LENGTH = $gSTRATIXII_DLL_DELAY_CHAIN_LENGTH;
my $PREFIX_NAME = $gDDR_PREFIX_NAME;
my $LOCAL_DATA_BITS = $gLOCAL_DATA_BITS;
my $LOCAL_DATA_MODE = $gLOCAL_DATA_MODE;
my $LOCAL_ADDR_BITS = 24;
my $LOCAL_BURST_LEN = $gLOCAL_BURST_LEN;
my $LOCAL_BURST_LEN_BITS = $gLOCAL_BURST_LEN_BITS;
my $MEM_ADDR_BITS = $gMEM_ADDR_BITS;
my $MEM_NUM_DEVICES = $gMEM_NUM_DEVICES;
my $MEM_CHIPSELS = $gMEM_CHIPSELS;
my $MEM_TRC_CYCLES = $gMEM_TRC_CYCLES;
my $RLDRAMII_TYPE = $gRLDRAMII_TYPE;
my $ADDR_SHIFT_BITS = $gADDR_SHIFT_BITS;
my $REFRESH_COMMAND = $gREFRESH_COMMAND;
my $MEM_DQ_PER_DQS = $gMEM_DQ_PER_DQS;
my $NUM_CLOCK_PAIRS = $gNUM_CLOCK_PAIRS;
my $enable_dm_pins = $gENABLE_DM_PINS;
my $num_addr_cmd_buses = $gNUMBER_ADDR_CMD_BUSES;
my $ddio_memory_clocks = $gDDIO_MEMORY_CLOCKS;
#my $ddio_memory_clocks = true;
my $ddio_memory_clocks_output = $gDDIO_MEMORY_CLOCKS;
my $WRITE_ALL_MODE = 0;
my $S_WRITE = 1;
my $S_WRITE_WAIT = 2;
my $S_READ = 3;
my $S_READ_WAIT = 4;
my $S_IDLE = 0;
my $S_INIT = 5;
my $NUMBER_DQS;
my $clock_pos_pin_name = $gCLOCK_POS_PIN_NAME;
my $clock_neg_pin_name = $gCLOCK_NEG_PIN_NAME;
my $addr_cmd_clk = $gADDR_CMD_CLK;

my $ENABLE_CAPTURE_CLK = $gENABLE_CAPTURE_CLK;

if ($ENABLE_CAPTURE_CLK eq "true") {
	$CAPTURE_MODE = non_dqs;
}
else {
	$CAPTURE_MODE = dqs;
}

my $FEDBACK_CLOCK_NAME = $gFEDBACK_CLOCK_NAME;


my $ADDR_INCR = int(($LOCAL_DATA_BITS / $MEM_DQ_PER_DQS) * $LOCAL_BURST_LEN);
my $MEMORY_BURST_LEN = $LOCAL_BURST_LEN * 2;

#### Calculate the number of dqs pins used and the memory interface width ####
if ($LOCAL_DATA_MODE eq "narrow") {
    $NUMBER_DQS = int($LOCAL_DATA_BITS / $MEM_DQ_PER_DQS / 2);
    $MEMORY_DATA_WIDTH = int($LOCAL_DATA_BITS / 2);
} else {
    $NUMBER_DQS = int($LOCAL_DATA_BITS / $LOCAL_BURST_LEN / $MEM_DQ_PER_DQS / 2);
    $MEMORY_DATA_WIDTH = int($LOCAL_DATA_BITS / $MEMORY_BURST_LEN / 2);	
}

my $enable_addr_cmd_clk = $gENABLE_ADDR_CMD_CLK;
my $addr_cmd_negedge = $gADDR_CMD_NEGEDGE;

######################################################################################################################################################################
##Checking the which clk and which edge should be used to present the address and command bits to the memory

$device_clk = "addr_cmd_clk";
    
if($addr_cmd_negedge eq "true")
{
	$device_clk_edge =  "0";
	$device_clk_edge_s = "negative";
} else {
  	$device_clk_edge =  "1";
	$device_clk_edge_s = "positive";
}

######################################################################################################################################################################

####  end parameter list  ######

#######################################################################################################################################

$module->comment
(
	"------------------------------------------------------------------------------\n
	\nTitle        : $header_title
	\nProject      : RLDRAM II Controller
	\nFile         : $header_filename
	\nRevision     : $header_revision
	\nAbstract:
	\nConfigurable example instance containing:.
	\n\t     - RLDRAM II controller
	\n\t     - Example driver
	\n\t     - DLL
	\n\t     - PLL
	----------------------------------------------------------------------------------\n
	<< START MEGAWIZARD INSERT PARAMETER_LIST\n
	Parameters:\n
	DLL Input Clock Frequency          : $CLOCK_PERIOD_IN_PS ps\n
	DLL Delay Buffer Mode              : $STRATIXII_DLL_DELAY_BUFFER_MODE\n
	DLL Delay Chain Length             : $STRATIXII_DLL_DELAY_CHAIN_LENGTH\n
	Local Interface Data Width         : $LOCAL_DATA_BITS\n
	Local Interface Burst Length       : $LOCAL_BURST_LEN\n
	Number Address/Command Buses       : $num_addr_cmd_buses\n
	Address/Command Clock              : $addr_cmd_clk
	RLDRAM II Memory Type              : $RLDRAMII_TYPE\n
	DDIO Memory Clock Generation       : $ddio_memory_clocks\n
	Number Memory Clock Pairs          : $NUM_CLOCK_PAIRS\n
	Number DQS Inputs Used             : $NUMBER_DQS\n
	Number DQ Bits per DQS Input       : $MEM_DQ_PER_DQS\n
	Read Data Capture Mode             : $CAPTURE_MODE\n
	Enable DM Pins                     : $enable_dm_pins\n
	Number Memory Address Bits         : $MEM_ADDR_BITS\n
	Number RLDRAM II Memory Devices    : $MEM_NUM_DEVICES\n
	Local Address Number Shift Bits    : $ADDR_SHIFT_BITS\n
	----------------------------------------------------------------------------------\n
	<< END MEGAWIZARD INSERT PARAMETER_LIST\n
	<< MEGAWIZARD PARSE FILE RLDRAMII${gWIZARD_VERSION}\n"
);

######################################################################################################################################################################
	$module->comment($module->comment()."\n\n\n\n\n\n<< START MEGAWIZARD INSERT MODULE\n");
	if($RLDRAMII_TYPE eq "cio")
	{
		$module->add_contents
		(
			#####	Ports declaration#	######
			e_port->new({name => "clock_source",direction => "input"}),
			e_port->new({name => "system_reset_n",direction => "input"}),
			#e_port->new({name => $PREFIX_NAME."a",direction => "output", width => $MEM_ADDR_BITS}),
			e_port->new({name => $PREFIX_NAME."clk",direction => "output", width => $NUM_CLOCK_PAIRS, declare_one_bit_as_std_logic_vector => 1}),
			e_port->new({name => $PREFIX_NAME."clk_n",direction => "output", width => $NUM_CLOCK_PAIRS, declare_one_bit_as_std_logic_vector => 1}),
			e_port->new({name => $PREFIX_NAME."a_0",direction => "output", width => $MEM_ADDR_BITS}),
			e_port->new({name => $PREFIX_NAME."ba_0",direction => "output", width => 3}),
			e_port->new({name => $PREFIX_NAME."cs_n_0",direction => "output", width => 1}),
			e_port->new({name => $PREFIX_NAME."we_n_0",direction => "output", width => 1}),
			e_port->new({name => $PREFIX_NAME."ref_n_0",direction => "output", width => 1}),
			e_port->new({name => $PREFIX_NAME."dq",direction => "inout", width => $MEMORY_DATA_WIDTH}),
			e_port->new({name => $PREFIX_NAME."qvld",direction => "input", width => $MEM_NUM_DEVICES, declare_one_bit_as_std_logic_vector => 1}),
			e_port->new({name => "test_complete",direction => "output"}),
			e_port->new({name => "pnf_per_byte",direction => "output",width => $NUMBER_DQS * 2}),
			e_port->new({name => "pnf_persist",direction => "output"}),
		);
		
#		if ($ddio_memory_clocks eq "true") {
#			$module->add_contents
#			(
#				e_port->new({name => $PREFIX_NAME."clk_n",direction => "output", width => $NUM_CLOCK_PAIRS, declare_one_bit_as_std_logic_vector => 1}),
#			);
#		}
		
		if($num_addr_cmd_buses > 1) {
			$module->add_contents
			(
				e_port->new({name => $PREFIX_NAME."a_1",direction => "output", width => $MEM_ADDR_BITS}),
				e_port->new({name => $PREFIX_NAME."ba_1",direction => "output", width => 3}),
				e_port->new({name => $PREFIX_NAME."cs_n_1",direction => "output", width => 1}),
				e_port->new({name => $PREFIX_NAME."we_n_1",direction => "output", width => 1}),
				e_port->new({name => $PREFIX_NAME."ref_n_1",direction => "output", width => 1}),
			);
		}
		
		if($enable_dm_pins eq "true") {
			$module->add_contents
			(
				e_port->new({name => $PREFIX_NAME."dm",direction => "output", width => $MEM_NUM_DEVICES, declare_one_bit_as_std_logic_vector => 1}),
			);
		}
		
		if ($ENABLE_CAPTURE_CLK eq "false") {
			$module->add_contents
			(
				e_port->new({name => $PREFIX_NAME."qk",direction => "input", width => $NUMBER_DQS, declare_one_bit_as_std_logic_vector => 1}),
			),
		}
		else {
			$module->add_contents
			(
				e_port->new({name => $PREFIX_NAME."fb_clk_in",direction => "input", width => 1}),
			),
		}
	}
	else
	{
		$module->add_contents
		(
			#####	Ports declaration#	######
			e_port->new({name => "clock_source",direction => "input"}),
			e_port->new({name => "system_reset_n",direction => "input"}),
			#e_port->new({name => $PREFIX_NAME."a",direction => "input", width => $MEM_ADDR_BITS}),
			e_port->new({name => $PREFIX_NAME."clk",direction => "output", width => $NUM_CLOCK_PAIRS, declare_one_bit_as_std_logic_vector => 1}),
			e_port->new({name => $PREFIX_NAME."clk_n",direction => "output", width => $NUM_CLOCK_PAIRS, declare_one_bit_as_std_logic_vector => 1}),
			e_port->new({name => $PREFIX_NAME."a_0",direction => "output", width => $MEM_ADDR_BITS}),
			e_port->new({name => $PREFIX_NAME."ba_0",direction => "output", width => 3}),
			e_port->new({name => $PREFIX_NAME."cs_n_0",direction => "output", width => 1}),
			e_port->new({name => $PREFIX_NAME."we_n_0",direction => "output", width => 1}),
			e_port->new({name => $PREFIX_NAME."ref_n_0",direction => "output", width => 1}),
			#e_port->new({name => $PREFIX_NAME."dm",direction => "output", width => $MEM_NUM_DEVICES, declare_one_bit_as_std_logic_vector => 1}),
			e_port->new({name => $PREFIX_NAME."d",direction => "output", width => $MEMORY_DATA_WIDTH}),
			e_port->new({name => $PREFIX_NAME."q",direction => "input", width => $MEMORY_DATA_WIDTH}),
			e_port->new({name => $PREFIX_NAME."qvld",direction => "input", width => $MEM_NUM_DEVICES, declare_one_bit_as_std_logic_vector => 1}),
			e_port->new({name => "test_complete",direction => "output"}),
			e_port->new({name => "pnf_per_byte",direction => "output",width => $NUMBER_DQS * 2}),
			e_port->new({name => "pnf_persist",direction => "output"}),
		);	
		
#		if ($ddio_memory_clocks eq "true") {
#			$module->add_contents
#			(
#				e_port->new({name => $PREFIX_NAME."clk_n",direction => "output", width => $NUM_CLOCK_PAIRS, declare_one_bit_as_std_logic_vector => 1}),
#			);
#		}
		
		if($num_addr_cmd_buses > 1) {
			$module->add_contents
			(
				e_port->new({name => $PREFIX_NAME."a_1",direction => "output", width => $MEM_ADDR_BITS}),
				e_port->new({name => $PREFIX_NAME."ba_1",direction => "output", width => 3}),
				e_port->new({name => $PREFIX_NAME."cs_n_1",direction => "output", width => 1}),
				e_port->new({name => $PREFIX_NAME."we_n_1",direction => "output", width => 1}),
				e_port->new({name => $PREFIX_NAME."ref_n_1",direction => "output", width => 1}),
			);
		}
		
		if($enable_dm_pins eq "true") {
			$module->add_contents
			(
				e_port->new({name => $PREFIX_NAME."dm",direction => "output", width => $MEM_NUM_DEVICES, declare_one_bit_as_std_logic_vector => 1}),
			);
		}
		
		if ($ENABLE_CAPTURE_CLK eq "false") {
			$module->add_contents
			(
				e_port->new({name => $PREFIX_NAME."qk",direction => "input", width => $NUMBER_DQS, declare_one_bit_as_std_logic_vector => 1}),
			),
		}
		else {
			$module->add_contents
			(
				e_port->new({name => $PREFIX_NAME."fb_clk_in",direction => "input", width => 1}),
			),
		}
	};

#################################################################################################################################################################
	$module->add_contents
	(
	#####   signal generation #####
	 	e_signal->news #: ["signal", width, export, never_export]
		(	 
			 [$PREFIX_NAME."local_init_done",1,	0,	1],
			 [$PREFIX_NAME."local_init_done_r",1,	0,	1],
			 [$PREFIX_NAME."local_rdata",$LOCAL_DATA_BITS,	0,	1],
			 [$PREFIX_NAME."local_rdata_valid",$MEM_NUM_DEVICES,	0,	1],
			 [$PREFIX_NAME."local_refresh_req",1,	0,	1],
			 [$PREFIX_NAME."local_wdata_req",1,	0,	1],
			 ["reset_n",1,	0,	1],
			 ["reset_n_read_clk_r1",$MEM_NUM_DEVICES,	0,	1],
			 ["reset_n_read_clk_r2",$MEM_NUM_DEVICES,	0,	1],
			 ["reset_n_ac_r1",1,	0,	1],
			 ["reset_n_ac_r2",1,	0,	1],
			 ["reset_clk_n",1,	0,	1],
			 # ["reset_n_clk_r1",1,	0,	1],
			 # ["reset_n_clk_r2",1,	0,	1],
			 ["reset_addr_cmd_clk_n",1,	0,	1],
			 ["addr_cmd_clk",1,	0,	1],
			 ["memory_clk_0",1,	0,	1],
			 ["memory_clk_1",1,	0,	1],
			 ["memory_clk_2",1,	0,	1],
			 [$PREFIX_NAME."local_read_req",1,	0,	1],
			 [$PREFIX_NAME."local_write_req",1,	0,	1],
			 [$PREFIX_NAME."local_addr",$MEM_ADDR_BITS,	0,	1],
			 [$PREFIX_NAME."local_bank_addr",3,	0,	1],
			 [$PREFIX_NAME."local_wdata",$LOCAL_DATA_BITS,	0,	1],
			 [$PREFIX_NAME."local_dm",$MEM_NUM_DEVICES * 2,	0,	1],
			 ["reset",1,	0,	1],
			 ["pll_locked",1,	0,	1],
		),
	);	

#########################################################################################################################################################	 

	$module->add_contents
	(
		 #e_assign->new({lhs => "reset", rhs => "! system_reset_n"}),
		 e_assign->new({lhs => "reset_n", rhs => "system_reset_n & pll_locked"}),
	);

    
################################################################################################################################################################
if ($ENABLE_CAPTURE_CLK eq "false") {
	for ($i = 0; $i <= $MEM_NUM_DEVICES - 1; $i++ ) {
		$module->add_contents
		(
			e_process->new
			({
					clock			=> "read_clk[$i]",
					#reset			=> "reset_clk_n",
					reset			=> "",
					_asynchronous_contents  =>
					[
					#e_assign->new({lhs => "local_init_done_r1", rhs => "0" }),
					#e_assign->new({lhs => "local_init_done_r2", rhs => "0" }),
					],
					_contents		=>
					[
					e_assign->new({lhs => "reset_n_read_clk_r1[$i]", rhs => "reset_n" }),
					e_assign->new({lhs => "reset_n_read_clk_r2[$i]", rhs => "reset_n_read_clk_r1[$i]" }),
					],
			}),
			
			e_assign->new({lhs => "reset_read_clk_n[$i]", rhs => "reset_n_read_clk_r2[$i]" }),
			),
	};
} else {
	$module->add_contents
	(
		e_process->new
		({
				clock			=> "read_clk",
				reset			=> "",
				_asynchronous_contents  =>
				[
				],
				_contents		=>
				[
				e_assign->new({lhs => "reset_n_read_clk_r1", rhs => "reset_n" }),
				e_assign->new({lhs => "reset_n_read_clk_r2", rhs => "reset_n_read_clk_r1" }),
				],
		}),
		
		e_assign->new({lhs => "reset_read_clk_n", rhs => "reset_n_read_clk_r2" }),
	);
};



################################################################################################################################################################

	# $module->add_contents
	# (
		# e_process->new
		# ({
			# clock			=> clk,
			# reset			=> "",
			# #clock_level		=> $device_clk_edge,
			# _asynchronous_contents  =>
			# [
			# ],
			# _contents		=>
			# [
				# e_assign->new({lhs => "reset_n_clk_r1", rhs => "reset_n" }),
				# e_assign->new({lhs => "reset_n_clk_r2", rhs => "reset_n_clk_r1" }),
			# ],
		# }),
       # );


################################################################################################################################################################

		$module->add_contents
		(
			e_process->new
			({
				clock			=> $device_clk,
				reset			=> "",
				clock_level		=> $device_clk_edge,
				_asynchronous_contents  =>
				[
				],
				_contents		=>
				[
					e_assign->new({lhs => "reset_n_ac_r1", rhs => "reset_n" }),
					e_assign->new({lhs => "reset_n_ac_r2", rhs => "reset_n_ac_r1" }),
				],
			}),
       );
    
################################################################################################################################################################


	 if ($ENABLE_CAPTURE_CLK eq "false") {
		 $module->add_contents
		 (
			 e_signal->news #: ["signal", width, export, never_export]
			 (	 
			 	 [$PREFIX_NAME."capture_clk",$MEM_NUM_DEVICES,	0,	1],
				 ["read_clk",$MEM_NUM_DEVICES,	0,	1],
				 #["reset_read_clk_n",1,	0,	1],
				 ["reset_read_clk_n",$MEM_NUM_DEVICES,	0,	1],
				 ["reset_driver_read_clk_n",1,	0,	1],
				 ["dqs_delay_ctrl",6,	0,	1],
				 ["dqs_ref_clk",1,	0,	1],
			 ),
			 e_assign->new({lhs => "read_clk", rhs => $PREFIX_NAME."capture_clk[$MEM_NUM_DEVICES - 1:0]"}),
		);
	}
	else
	{
		$module->add_contents
		(
			e_signal->news #: ["signal", width, export, never_export]
			(	 
				["reset_read_clk_n",1,	0,	1],
				["reset_driver_read_clk_n",1,	0,	1],
			 	["non_dqs_capture_clk",1,	0,	1],
				["example_driver_clk",1,	0,	1],
				["fb_pll_clk",1,	0,	1],
				["fb_pll_reset",1,	0,	1],
			),
			e_assign->new({lhs => "read_clk", rhs => "! fb_pll_clk"}),
			e_assign->new({lhs => "fb_pll_reset", rhs => "! pll_locked"}),
		);
	}
	 	 
#########################################################################################################################################################	 

	$module->add_contents
	(
		 e_assign->new({lhs => "reset", rhs => "! system_reset_n"}),
		 #e_assign->new({lhs => "reset_n", rhs => "system_reset_n & pll_locked"}),
	);

################################################################################################################################################################
if ($ENABLE_CAPTURE_CLK eq "false") {
        $module->add_contents
	(
		e_comment->new({comment => "Assign Reset Signals"}),
		#e_assign->new({lhs => "reset_clk_n", rhs => "reset_n_clk_r2" }),
        e_assign->new({lhs => "reset_clk_n", rhs => "reset_n" }),
		e_assign->new({lhs => "reset_addr_cmd_clk_n", rhs => "reset_n_ac_r2" }),
		#e_assign->new({lhs => "reset_read_clk_n", rhs => "{".$MEM_NUM_DEVICES."{reset_n}}" }),
		e_assign->new({lhs => "reset_driver_read_clk_n", rhs => "{reset_n}" }),
	);
}
else
{
	$module->add_contents
	(
		e_comment->new({comment => "Assign Reset Signals"}),
		e_assign->new({lhs => "reset_clk_n", rhs => "reset_n" }),
		e_assign->new({lhs => "reset_addr_cmd_clk_n", rhs => "reset_n_ac_r2" }),
		#e_assign->new({lhs => "reset_addr_cmd_clk_n", rhs => "reset_n" }),reset_n_ac_r2
		e_assign->new({lhs => "reset_driver_read_clk_n", rhs => "{reset_n}" }),
	);
}
$module->add_contents
(
	e_comment->new({comment => "<< END MEGAWIZARD INSERT MODULE"}),
	e_comment->new({comment => "<< START MEGAWIZARD INSERT WRAPPER_NAME"}),
);


#########################################################################################################################################################
	if($RLDRAMII_TYPE eq "cio")
	{
		if ($ENABLE_CAPTURE_CLK eq "false") {
			if($enable_addr_cmd_clk eq "true") {
				if($enable_dm_pins eq "true") {
					if($num_addr_cmd_buses > 1) {
						if ($ddio_memory_clocks eq "true") {
							$module->add_contents
							(
								e_blind_instance->new
								({
									name 		=> $gWRAPPER_NAME,
									module 		=> $gWRAPPER_NAME."_wrapper",
									comment 	=> "---------------------------------------------------------------------\n
									CIO RLDRAM II Controller\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk => "clk",
										write_clk => "write_clk",
										addr_cmd_clk => "addr_cmd_clk",
										reset_clk_n => "reset_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										dqs_delay_ctrl => "dqs_delay_ctrl",
										local_write_req =>$PREFIX_NAME."local_write_req",
										local_read_req => $PREFIX_NAME."local_read_req",
										local_addr => $PREFIX_NAME."local_addr",
										local_bank_addr => $PREFIX_NAME."local_bank_addr",
										local_wdata => $PREFIX_NAME."local_wdata",
										local_dm => $PREFIX_NAME."local_dm",
										local_refresh_req => $PREFIX_NAME."local_refresh_req",
										$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld[".($MEM_NUM_DEVICES - 1).":0]",
										#$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld",
                                        $PREFIX_NAME."qk" => $PREFIX_NAME."qk[".($NUMBER_DQS - 1).":0]",
									},
					
									out_port_map	=>
									{
										capture_clk     => $PREFIX_NAME."capture_clk",
										local_wdata_req => $PREFIX_NAME."local_wdata_req",
										local_rdata_valid => $PREFIX_NAME."local_rdata_valid",#[]",
										local_rdata     => $PREFIX_NAME."local_rdata",
										local_init_done => $PREFIX_NAME."local_init_done",
										#$PREFIX_NAME."clk"   => $PREFIX_NAME."clk",
										#$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n",
										$PREFIX_NAME."clk"   => $PREFIX_NAME."clk[".($NUM_CLOCK_PAIRS - 1).":0]",
										$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n[".($NUM_CLOCK_PAIRS - 1).":0]",
										$PREFIX_NAME."cs_n_0"  => $PREFIX_NAME."cs_n_0",
										$PREFIX_NAME."we_n_0"  => $PREFIX_NAME."we_n_0",
										$PREFIX_NAME."ref_n_0" => $PREFIX_NAME."ref_n_0",
										$PREFIX_NAME."cs_n_1"  => $PREFIX_NAME."cs_n_1",
										$PREFIX_NAME."we_n_1"  => $PREFIX_NAME."we_n_1",
										$PREFIX_NAME."ref_n_1" => $PREFIX_NAME."ref_n_1",
										$PREFIX_NAME."a_0"  => $PREFIX_NAME."a_0",
										$PREFIX_NAME."ba_0" => $PREFIX_NAME."ba_0",
										$PREFIX_NAME."a_1"  => $PREFIX_NAME."a_1",
										$PREFIX_NAME."ba_1" => $PREFIX_NAME."ba_1",
										#$PREFIX_NAME."dm" => $PREFIX_NAME."dm",
										$PREFIX_NAME."dm" => $PREFIX_NAME."dm[".($MEM_NUM_DEVICES - 1).":0]",
									},
									inout_port_map	=>
									{
										#$PREFIX_NAME."qk" => $PREFIX_NAME."qk",
										#$PREFIX_NAME."qk" => $PREFIX_NAME."qk[".($NUMBER_DQS - 1).":0]",
										$PREFIX_NAME."dq" => $PREFIX_NAME."dq",					
									},
								}),
							);
						} else {
							$module->add_contents
							(
								e_blind_instance->new
								({
									name 		=> $gWRAPPER_NAME,
									module 		=> $gWRAPPER_NAME."_wrapper",
									comment 	=> "---------------------------------------------------------------------\n
									CIO RLDRAM II Controller\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk => "clk",
										write_clk => "write_clk",
										addr_cmd_clk => "addr_cmd_clk",
										reset_clk_n => "reset_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										dqs_delay_ctrl => "dqs_delay_ctrl",
										local_write_req =>$PREFIX_NAME."local_write_req",
										local_read_req => $PREFIX_NAME."local_read_req",
										local_addr => $PREFIX_NAME."local_addr",
										local_bank_addr => $PREFIX_NAME."local_bank_addr",
										local_wdata => $PREFIX_NAME."local_wdata",
										local_dm => $PREFIX_NAME."local_dm",
										local_refresh_req => $PREFIX_NAME."local_refresh_req",
										$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld[".($MEM_NUM_DEVICES - 1).":0]",
										#$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld",
                                        $PREFIX_NAME."qk" => $PREFIX_NAME."qk[".($NUMBER_DQS - 1).":0]",
									},
					
									out_port_map	=>
									{
										capture_clk     => $PREFIX_NAME."capture_clk",
										local_wdata_req => $PREFIX_NAME."local_wdata_req",
										local_rdata_valid => $PREFIX_NAME."local_rdata_valid",#[]",
										local_rdata     => $PREFIX_NAME."local_rdata",
										local_init_done => $PREFIX_NAME."local_init_done",
										#$PREFIX_NAME."clk"   => $PREFIX_NAME."clk",
										#$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n",
										#$PREFIX_NAME."clk"   => $PREFIX_NAME."clk[".($NUM_CLOCK_PAIRS - 1).":0]",
										#$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n[".($NUM_CLOCK_PAIRS - 1).":0]",
										$PREFIX_NAME."cs_n_0"  => $PREFIX_NAME."cs_n_0",
										$PREFIX_NAME."we_n_0"  => $PREFIX_NAME."we_n_0",
										$PREFIX_NAME."ref_n_0" => $PREFIX_NAME."ref_n_0",
										$PREFIX_NAME."cs_n_1"  => $PREFIX_NAME."cs_n_1",
										$PREFIX_NAME."we_n_1"  => $PREFIX_NAME."we_n_1",
										$PREFIX_NAME."ref_n_1" => $PREFIX_NAME."ref_n_1",
										$PREFIX_NAME."a_0"  => $PREFIX_NAME."a_0",
										$PREFIX_NAME."ba_0" => $PREFIX_NAME."ba_0",
										$PREFIX_NAME."a_1"  => $PREFIX_NAME."a_1",
										$PREFIX_NAME."ba_1" => $PREFIX_NAME."ba_1",
										#$PREFIX_NAME."dm" => $PREFIX_NAME."dm",
										$PREFIX_NAME."dm" => $PREFIX_NAME."dm[".($MEM_NUM_DEVICES - 1).":0]",
									},
									inout_port_map	=>
									{
										#$PREFIX_NAME."qk" => $PREFIX_NAME."qk",
										#$PREFIX_NAME."qk" => $PREFIX_NAME."qk[".($NUMBER_DQS - 1).":0]",
										$PREFIX_NAME."dq" => $PREFIX_NAME."dq",					
									},
								}),
							);
						}
					} else {
						if ($ddio_memory_clocks eq "true") {
							$module->add_contents
							(
								e_blind_instance->new
								({
									name 		=> $gWRAPPER_NAME,            
									module 		=> $gWRAPPER_NAME."_wrapper",
									comment 	=> "---------------------------------------------------------------------\n
									CIO RLDRAM II Controller\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk => "clk",
										write_clk => "write_clk",
										addr_cmd_clk => "addr_cmd_clk",
										reset_clk_n => "reset_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										dqs_delay_ctrl => "dqs_delay_ctrl",
										local_write_req =>$PREFIX_NAME."local_write_req",
										local_read_req => $PREFIX_NAME."local_read_req",
										local_addr => $PREFIX_NAME."local_addr",
										local_bank_addr => $PREFIX_NAME."local_bank_addr",
										local_wdata => $PREFIX_NAME."local_wdata",
										local_dm => $PREFIX_NAME."local_dm",
										local_refresh_req => $PREFIX_NAME."local_refresh_req",
										#$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld",
										$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld[".($MEM_NUM_DEVICES - 1).":0]",
                                        $PREFIX_NAME."qk" => $PREFIX_NAME."qk[".($NUMBER_DQS - 1).":0]",
									},
					
									out_port_map	=>
									{
										capture_clk     => $PREFIX_NAME."capture_clk",#[]",
										local_wdata_req => $PREFIX_NAME."local_wdata_req",
										local_rdata_valid => $PREFIX_NAME."local_rdata_valid",#[]",
										local_rdata     => $PREFIX_NAME."local_rdata",
										local_init_done => $PREFIX_NAME."local_init_done",
										#$PREFIX_NAME."clk"   => $PREFIX_NAME."clk",
										#$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n",
										$PREFIX_NAME."clk"   => $PREFIX_NAME."clk[".($NUM_CLOCK_PAIRS - 1).":0]",
										$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n[".($NUM_CLOCK_PAIRS - 1).":0]",
										$PREFIX_NAME."cs_n_0"  => $PREFIX_NAME."cs_n_0",
										$PREFIX_NAME."we_n_0"  => $PREFIX_NAME."we_n_0",
										$PREFIX_NAME."ref_n_0" => $PREFIX_NAME."ref_n_0",
										$PREFIX_NAME."a_0"  => $PREFIX_NAME."a_0",
										$PREFIX_NAME."ba_0" => $PREFIX_NAME."ba_0",
										#$PREFIX_NAME."dm" => $PREFIX_NAME."dm",
										$PREFIX_NAME."dm" => $PREFIX_NAME."dm[".($MEM_NUM_DEVICES - 1).":0]",
									},
									inout_port_map	=>
									{
										#$PREFIX_NAME."qk" => $PREFIX_NAME."qk",
										#$PREFIX_NAME."qk" => $PREFIX_NAME."qk[".($NUMBER_DQS - 1).":0]",
										$PREFIX_NAME."dq" => $PREFIX_NAME."dq",					
									},
								}),
							);
						} else {
							$module->add_contents
							(
								e_blind_instance->new
								({
									name 		=> $gWRAPPER_NAME,            
									module 		=> $gWRAPPER_NAME."_wrapper",
									comment 	=> "---------------------------------------------------------------------\n
									CIO RLDRAM II Controller\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk => "clk",
										write_clk => "write_clk",
										addr_cmd_clk => "addr_cmd_clk",
										reset_clk_n => "reset_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										dqs_delay_ctrl => "dqs_delay_ctrl",
										local_write_req =>$PREFIX_NAME."local_write_req",
										local_read_req => $PREFIX_NAME."local_read_req",
										local_addr => $PREFIX_NAME."local_addr",
										local_bank_addr => $PREFIX_NAME."local_bank_addr",
										local_wdata => $PREFIX_NAME."local_wdata",
										local_dm => $PREFIX_NAME."local_dm",
										local_refresh_req => $PREFIX_NAME."local_refresh_req",
										#$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld",
										$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld[".($MEM_NUM_DEVICES - 1).":0]",
                                        $PREFIX_NAME."qk" => $PREFIX_NAME."qk[".($NUMBER_DQS - 1).":0]",
									},
					
									out_port_map	=>
									{
										capture_clk     => $PREFIX_NAME."capture_clk",#[]",
										local_wdata_req => $PREFIX_NAME."local_wdata_req",
										local_rdata_valid => $PREFIX_NAME."local_rdata_valid",#[]",
										local_rdata     => $PREFIX_NAME."local_rdata",
										local_init_done => $PREFIX_NAME."local_init_done",
										#$PREFIX_NAME."clk"   => $PREFIX_NAME."clk",
										#$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n",
										#$PREFIX_NAME."clk"   => $PREFIX_NAME."clk[".($NUM_CLOCK_PAIRS - 1).":0]",
										#$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n[".($NUM_CLOCK_PAIRS - 1).":0]",
										$PREFIX_NAME."cs_n_0"  => $PREFIX_NAME."cs_n_0",
										$PREFIX_NAME."we_n_0"  => $PREFIX_NAME."we_n_0",
										$PREFIX_NAME."ref_n_0" => $PREFIX_NAME."ref_n_0",
										$PREFIX_NAME."a_0"  => $PREFIX_NAME."a_0",
										$PREFIX_NAME."ba_0" => $PREFIX_NAME."ba_0",
										#$PREFIX_NAME."dm" => $PREFIX_NAME."dm",
										$PREFIX_NAME."dm" => $PREFIX_NAME."dm[".($MEM_NUM_DEVICES - 1).":0]",
									},
									inout_port_map	=>
									{
										#$PREFIX_NAME."qk" => $PREFIX_NAME."qk",
										#$PREFIX_NAME."qk" => $PREFIX_NAME."qk[".($NUMBER_DQS - 1).":0]",
										$PREFIX_NAME."dq" => $PREFIX_NAME."dq",					
									},
								}),
							);
						}
					}
				} else {
					if($num_addr_cmd_buses > 1) {
						if ($ddio_memory_clocks eq "true") {
							$module->add_contents
							(
								e_blind_instance->new
								({
									name 		=> $gWRAPPER_NAME,            
									module 		=> $gWRAPPER_NAME."_wrapper",
									comment 	=> "---------------------------------------------------------------------\n
									CIO RLDRAM II Controller\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk => "clk",
										write_clk => "write_clk",
										addr_cmd_clk => "addr_cmd_clk",
										reset_clk_n => "reset_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										dqs_delay_ctrl => "dqs_delay_ctrl",
										local_write_req =>$PREFIX_NAME."local_write_req",
										local_read_req => $PREFIX_NAME."local_read_req",
										local_addr => $PREFIX_NAME."local_addr",
										local_bank_addr => $PREFIX_NAME."local_bank_addr",
										local_wdata => $PREFIX_NAME."local_wdata",
										#local_dm => $PREFIX_NAME."local_dm",
										local_refresh_req => $PREFIX_NAME."local_refresh_req",
										#$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld",
										$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld[".($MEM_NUM_DEVICES - 1).":0]",
                                        $PREFIX_NAME."qk" => $PREFIX_NAME."qk[".($NUMBER_DQS - 1).":0]",
									},
					
									out_port_map	=>
									{
										capture_clk => $PREFIX_NAME."capture_clk",#[]",
										local_wdata_req => $PREFIX_NAME."local_wdata_req",
										local_rdata_valid => $PREFIX_NAME."local_rdata_valid",#[]",
										local_rdata => $PREFIX_NAME."local_rdata",
										local_init_done => $PREFIX_NAME."local_init_done",
										#$PREFIX_NAME."clk" => $PREFIX_NAME."clk",
										#$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n",
										$PREFIX_NAME."clk" => $PREFIX_NAME."clk[".($NUM_CLOCK_PAIRS - 1).":0]",
										$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n[".($NUM_CLOCK_PAIRS - 1).":0]",
										$PREFIX_NAME."cs_n_0"  => $PREFIX_NAME."cs_n_0",
										$PREFIX_NAME."we_n_0"  => $PREFIX_NAME."we_n_0",
										$PREFIX_NAME."ref_n_0" => $PREFIX_NAME."ref_n_0",
										$PREFIX_NAME."cs_n_1"  => $PREFIX_NAME."cs_n_1",
										$PREFIX_NAME."we_n_1"  => $PREFIX_NAME."we_n_1",
										$PREFIX_NAME."ref_n_1" => $PREFIX_NAME."ref_n_1",
										$PREFIX_NAME."a_0" => $PREFIX_NAME."a_0",
										$PREFIX_NAME."ba_0" => $PREFIX_NAME."ba_0",
										$PREFIX_NAME."a_1" => $PREFIX_NAME."a_1",
										$PREFIX_NAME."ba_1" => $PREFIX_NAME."ba_1",
									},
									inout_port_map	=>
									{
										#$PREFIX_NAME."qk" => $PREFIX_NAME."qk",
										#$PREFIX_NAME."qk" => $PREFIX_NAME."qk[".($NUMBER_DQS - 1).":0]",
										$PREFIX_NAME."dq" => $PREFIX_NAME."dq",					
									},
								}),
							);
						} else {
							$module->add_contents
							(
								e_blind_instance->new
								({
									name 		=> $gWRAPPER_NAME,            
									module 		=> $gWRAPPER_NAME."_wrapper",
									comment 	=> "---------------------------------------------------------------------\n
									CIO RLDRAM II Controller\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk => "clk",
										write_clk => "write_clk",
										addr_cmd_clk => "addr_cmd_clk",
										reset_clk_n => "reset_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										dqs_delay_ctrl => "dqs_delay_ctrl",
										local_write_req =>$PREFIX_NAME."local_write_req",
										local_read_req => $PREFIX_NAME."local_read_req",
										local_addr => $PREFIX_NAME."local_addr",
										local_bank_addr => $PREFIX_NAME."local_bank_addr",
										local_wdata => $PREFIX_NAME."local_wdata",
										#local_dm => $PREFIX_NAME."local_dm",
										local_refresh_req => $PREFIX_NAME."local_refresh_req",
										#$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld",
										$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld[".($MEM_NUM_DEVICES - 1).":0]",
                                        $PREFIX_NAME."qk" => $PREFIX_NAME."qk[".($NUMBER_DQS - 1).":0]",
									},
					
									out_port_map	=>
									{
										capture_clk => $PREFIX_NAME."capture_clk",#[]",
										local_wdata_req => $PREFIX_NAME."local_wdata_req",
										local_rdata_valid => $PREFIX_NAME."local_rdata_valid",#[]",
										local_rdata => $PREFIX_NAME."local_rdata",
										local_init_done => $PREFIX_NAME."local_init_done",
										#$PREFIX_NAME."clk" => $PREFIX_NAME."clk",
										#$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n",
										#$PREFIX_NAME."clk" => $PREFIX_NAME."clk[".($NUM_CLOCK_PAIRS - 1).":0]",
										#$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n[".($NUM_CLOCK_PAIRS - 1).":0]",
										$PREFIX_NAME."cs_n_0"  => $PREFIX_NAME."cs_n_0",
										$PREFIX_NAME."we_n_0"  => $PREFIX_NAME."we_n_0",
										$PREFIX_NAME."ref_n_0" => $PREFIX_NAME."ref_n_0",
										$PREFIX_NAME."cs_n_1"  => $PREFIX_NAME."cs_n_1",
										$PREFIX_NAME."we_n_1"  => $PREFIX_NAME."we_n_1",
										$PREFIX_NAME."ref_n_1" => $PREFIX_NAME."ref_n_1",
										$PREFIX_NAME."a_0" => $PREFIX_NAME."a_0",
										$PREFIX_NAME."ba_0" => $PREFIX_NAME."ba_0",
										$PREFIX_NAME."a_1" => $PREFIX_NAME."a_1",
										$PREFIX_NAME."ba_1" => $PREFIX_NAME."ba_1",
									},
									inout_port_map	=>
									{
										#$PREFIX_NAME."qk" => $PREFIX_NAME."qk",
										#$PREFIX_NAME."qk" => $PREFIX_NAME."qk[".($NUMBER_DQS - 1).":0]",
										$PREFIX_NAME."dq" => $PREFIX_NAME."dq",					
									},
								}),
							);
						}
					} else {
						if ($ddio_memory_clocks eq "true") {
							$module->add_contents
							(
								e_blind_instance->new
								({
									name 		=> $gWRAPPER_NAME,            
									module 		=> $gWRAPPER_NAME."_wrapper",
									comment 	=> "---------------------------------------------------------------------\n
									CIO RLDRAM II Controller\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk => "clk",
										write_clk => "write_clk",
										addr_cmd_clk => "addr_cmd_clk",
										reset_clk_n => "reset_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										dqs_delay_ctrl => "dqs_delay_ctrl",
										local_write_req =>$PREFIX_NAME."local_write_req",
										local_read_req => $PREFIX_NAME."local_read_req",
										local_addr => $PREFIX_NAME."local_addr",
										local_bank_addr => $PREFIX_NAME."local_bank_addr",
										local_wdata => $PREFIX_NAME."local_wdata",
										#local_dm => $PREFIX_NAME."local_dm",
										local_refresh_req => $PREFIX_NAME."local_refresh_req",
										#$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld",
										$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld[".($MEM_NUM_DEVICES - 1).":0]",
                                        $PREFIX_NAME."qk" => $PREFIX_NAME."qk[".($NUMBER_DQS - 1).":0]",
									},
					
									out_port_map	=>
									{
										capture_clk => $PREFIX_NAME."capture_clk",#[]",
										local_wdata_req => $PREFIX_NAME."local_wdata_req",
										local_rdata_valid => $PREFIX_NAME."local_rdata_valid",#[]",
										local_rdata => $PREFIX_NAME."local_rdata",
										local_init_done => $PREFIX_NAME."local_init_done",
										#$PREFIX_NAME."clk" => $PREFIX_NAME."clk",
										#$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n",
										$PREFIX_NAME."clk" => $PREFIX_NAME."clk[".($NUM_CLOCK_PAIRS - 1).":0]",
										$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n[".($NUM_CLOCK_PAIRS - 1).":0]",
										$PREFIX_NAME."cs_n_0"  => $PREFIX_NAME."cs_n_0",
										$PREFIX_NAME."we_n_0"  => $PREFIX_NAME."we_n_0",
										$PREFIX_NAME."ref_n_0" => $PREFIX_NAME."ref_n_0",
										$PREFIX_NAME."a_0" => $PREFIX_NAME."a_0",
										$PREFIX_NAME."ba_0" => $PREFIX_NAME."ba_0",
									},
									inout_port_map	=>
									{
										#$PREFIX_NAME."qk" => $PREFIX_NAME."qk",
										#$PREFIX_NAME."qk" => $PREFIX_NAME."qk[".($NUMBER_DQS - 1).":0]",
										$PREFIX_NAME."dq" => $PREFIX_NAME."dq",					
									},
								}),
							);
						} else {
							$module->add_contents
							(
								e_blind_instance->new
								({
									name 		=> $gWRAPPER_NAME,            
									module 		=> $gWRAPPER_NAME."_wrapper",
									comment 	=> "---------------------------------------------------------------------\n
									CIO RLDRAM II Controller\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk => "clk",
										write_clk => "write_clk",
										addr_cmd_clk => "addr_cmd_clk",
										reset_clk_n => "reset_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										dqs_delay_ctrl => "dqs_delay_ctrl",
										local_write_req =>$PREFIX_NAME."local_write_req",
										local_read_req => $PREFIX_NAME."local_read_req",
										local_addr => $PREFIX_NAME."local_addr",
										local_bank_addr => $PREFIX_NAME."local_bank_addr",
										local_wdata => $PREFIX_NAME."local_wdata",
										#local_dm => $PREFIX_NAME."local_dm",
										local_refresh_req => $PREFIX_NAME."local_refresh_req",
										#$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld",
										$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld[".($MEM_NUM_DEVICES - 1).":0]",
                                        $PREFIX_NAME."qk" => $PREFIX_NAME."qk[".($NUMBER_DQS - 1).":0]",
									},
					
									out_port_map	=>
									{
										capture_clk => $PREFIX_NAME."capture_clk",#[]",
										local_wdata_req => $PREFIX_NAME."local_wdata_req",
										local_rdata_valid => $PREFIX_NAME."local_rdata_valid",#[]",
										local_rdata => $PREFIX_NAME."local_rdata",
										local_init_done => $PREFIX_NAME."local_init_done",
										#$PREFIX_NAME."clk" => $PREFIX_NAME."clk",
										#$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n",
										#$PREFIX_NAME."clk" => $PREFIX_NAME."clk[".($NUM_CLOCK_PAIRS - 1).":0]",
										#$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n[".($NUM_CLOCK_PAIRS - 1).":0]",
										$PREFIX_NAME."cs_n_0"  => $PREFIX_NAME."cs_n_0",
										$PREFIX_NAME."we_n_0"  => $PREFIX_NAME."we_n_0",
										$PREFIX_NAME."ref_n_0" => $PREFIX_NAME."ref_n_0",
										$PREFIX_NAME."a_0" => $PREFIX_NAME."a_0",
										$PREFIX_NAME."ba_0" => $PREFIX_NAME."ba_0",
									},
									inout_port_map	=>
									{
										#$PREFIX_NAME."qk" => $PREFIX_NAME."qk",
										#$PREFIX_NAME."qk" => $PREFIX_NAME."qk[".($NUMBER_DQS - 1).":0]",
										$PREFIX_NAME."dq" => $PREFIX_NAME."dq",					
									},
								}),
							);
						}
					}
				}
			}
			else
			{
				if($enable_dm_pins eq "true") {
					if($num_addr_cmd_buses > 1) {
						if ($ddio_memory_clocks eq "true") {
							$module->add_contents
							(
								e_blind_instance->new
								({
									name 		=> $gWRAPPER_NAME,            
									module 		=> $gWRAPPER_NAME."_wrapper",
									comment 	=> "---------------------------------------------------------------------\n
									CIO RLDRAM II Controller\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk => "clk",
										write_clk => "write_clk",
										reset_clk_n => "reset_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										dqs_delay_ctrl => "dqs_delay_ctrl",
										local_write_req =>$PREFIX_NAME."local_write_req",
										local_read_req => $PREFIX_NAME."local_read_req",
										local_addr => $PREFIX_NAME."local_addr",
										local_bank_addr => $PREFIX_NAME."local_bank_addr",
										local_wdata => $PREFIX_NAME."local_wdata",
										local_dm => $PREFIX_NAME."local_dm",
										local_refresh_req => $PREFIX_NAME."local_refresh_req",
										#$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld",
										$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld[".($MEM_NUM_DEVICES - 1).":0]",
                                        $PREFIX_NAME."qk" => $PREFIX_NAME."qk[".($NUMBER_DQS - 1).":0]",
									},
					
									out_port_map	=>
									{
										capture_clk => $PREFIX_NAME."capture_clk",#[]",
										local_wdata_req => $PREFIX_NAME."local_wdata_req",
										local_rdata_valid => $PREFIX_NAME."local_rdata_valid",#[]",
										local_rdata => $PREFIX_NAME."local_rdata",
										local_init_done => $PREFIX_NAME."local_init_done",
										#$PREFIX_NAME."clk" => $PREFIX_NAME."clk",
										#$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n",
										$PREFIX_NAME."clk" => $PREFIX_NAME."clk[".($NUM_CLOCK_PAIRS - 1).":0]",
										$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n[".($NUM_CLOCK_PAIRS - 1).":0]",
										$PREFIX_NAME."cs_n_0"  => $PREFIX_NAME."cs_n_0",
										$PREFIX_NAME."we_n_0"  => $PREFIX_NAME."we_n_0",
										$PREFIX_NAME."ref_n_0" => $PREFIX_NAME."ref_n_0",
										$PREFIX_NAME."cs_n_1"  => $PREFIX_NAME."cs_n_1",
										$PREFIX_NAME."we_n_1"  => $PREFIX_NAME."we_n_1",
										$PREFIX_NAME."ref_n_1" => $PREFIX_NAME."ref_n_1",
										$PREFIX_NAME."a_0" => $PREFIX_NAME."a_0",
										$PREFIX_NAME."ba_0" => $PREFIX_NAME."ba_0",
										$PREFIX_NAME."a_1" => $PREFIX_NAME."a_1",
										$PREFIX_NAME."ba_1" => $PREFIX_NAME."ba_1",
										$PREFIX_NAME."dm" => $PREFIX_NAME."dm",
										#$PREFIX_NAME."dm" => $PREFIX_NAME."dm[".($MEM_NUM_DEVICES - 1).":0]",
									},
								
									inout_port_map	=>
									{
										#$PREFIX_NAME."qk" => $PREFIX_NAME."qk",
										#$PREFIX_NAME."qk" => $PREFIX_NAME."qk[".($NUMBER_DQS - 1).":0]",
										$PREFIX_NAME."dq" => $PREFIX_NAME."dq",					
									},
								}),
							);
						} else {
							$module->add_contents
							(
								e_blind_instance->new
								({
									name 		=> $gWRAPPER_NAME,            
									module 		=> $gWRAPPER_NAME."_wrapper",
									comment 	=> "---------------------------------------------------------------------\n
									CIO RLDRAM II Controller\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk => "clk",
										write_clk => "write_clk",
										reset_clk_n => "reset_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										dqs_delay_ctrl => "dqs_delay_ctrl",
										local_write_req =>$PREFIX_NAME."local_write_req",
										local_read_req => $PREFIX_NAME."local_read_req",
										local_addr => $PREFIX_NAME."local_addr",
										local_bank_addr => $PREFIX_NAME."local_bank_addr",
										local_wdata => $PREFIX_NAME."local_wdata",
										local_dm => $PREFIX_NAME."local_dm",
										local_refresh_req => $PREFIX_NAME."local_refresh_req",
										#$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld",
										$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld[".($MEM_NUM_DEVICES - 1).":0]",
                                        $PREFIX_NAME."qk" => $PREFIX_NAME."qk[".($NUMBER_DQS - 1).":0]",
									},
					
									out_port_map	=>
									{
										capture_clk => $PREFIX_NAME."capture_clk",#[]",
										local_wdata_req => $PREFIX_NAME."local_wdata_req",
										local_rdata_valid => $PREFIX_NAME."local_rdata_valid",#[]",
										local_rdata => $PREFIX_NAME."local_rdata",
										local_init_done => $PREFIX_NAME."local_init_done",
										#$PREFIX_NAME."clk" => $PREFIX_NAME."clk",
										#$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n",
										#$PREFIX_NAME."clk" => $PREFIX_NAME."clk[".($NUM_CLOCK_PAIRS - 1).":0]",
										#$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n[".($NUM_CLOCK_PAIRS - 1).":0]",
										$PREFIX_NAME."cs_n_0"  => $PREFIX_NAME."cs_n_0",
										$PREFIX_NAME."we_n_0"  => $PREFIX_NAME."we_n_0",
										$PREFIX_NAME."ref_n_0" => $PREFIX_NAME."ref_n_0",
										$PREFIX_NAME."cs_n_1"  => $PREFIX_NAME."cs_n_1",
										$PREFIX_NAME."we_n_1"  => $PREFIX_NAME."we_n_1",
										$PREFIX_NAME."ref_n_1" => $PREFIX_NAME."ref_n_1",
										$PREFIX_NAME."a_0" => $PREFIX_NAME."a_0",
										$PREFIX_NAME."ba_0" => $PREFIX_NAME."ba_0",
										$PREFIX_NAME."a_1" => $PREFIX_NAME."a_1",
										$PREFIX_NAME."ba_1" => $PREFIX_NAME."ba_1",
										$PREFIX_NAME."dm" => $PREFIX_NAME."dm",
										#$PREFIX_NAME."dm" => $PREFIX_NAME."dm[".($MEM_NUM_DEVICES - 1).":0]",
									},
								
									inout_port_map	=>
									{
										#$PREFIX_NAME."qk" => $PREFIX_NAME."qk",
										#$PREFIX_NAME."qk" => $PREFIX_NAME."qk[".($NUMBER_DQS - 1).":0]",
										$PREFIX_NAME."dq" => $PREFIX_NAME."dq",					
									},
								}),
							);
						}
					} else {
						if ($ddio_memory_clocks eq "true") {
							$module->add_contents
							(
								e_blind_instance->new
								({
									name 		=> $gWRAPPER_NAME,            
									module 		=> $gWRAPPER_NAME."_wrapper",
									comment 	=> "---------------------------------------------------------------------\n
									CIO RLDRAM II Controller\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk => "clk",
										write_clk => "write_clk",
										reset_clk_n => "reset_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										dqs_delay_ctrl => "dqs_delay_ctrl",
										local_write_req =>$PREFIX_NAME."local_write_req",
										local_read_req => $PREFIX_NAME."local_read_req",
										local_addr => $PREFIX_NAME."local_addr",
										local_bank_addr => $PREFIX_NAME."local_bank_addr",
										local_wdata => $PREFIX_NAME."local_wdata",
										local_dm => $PREFIX_NAME."local_dm",
										local_refresh_req => $PREFIX_NAME."local_refresh_req",
										#$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld",
										$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld[".($MEM_NUM_DEVICES - 1).":0]",
                                        $PREFIX_NAME."qk" => $PREFIX_NAME."qk[".($NUMBER_DQS - 1).":0]",
									},
					
									out_port_map	=>
									{
										capture_clk => $PREFIX_NAME."capture_clk",#[]",
										local_wdata_req => $PREFIX_NAME."local_wdata_req",
										local_rdata_valid => $PREFIX_NAME."local_rdata_valid",#[]",
										local_rdata => $PREFIX_NAME."local_rdata",
										local_init_done => $PREFIX_NAME."local_init_done",
										#$PREFIX_NAME."clk" => $PREFIX_NAME."clk",
										#$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n",
										$PREFIX_NAME."clk" => $PREFIX_NAME."clk[".($NUM_CLOCK_PAIRS - 1).":0]",
										$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n[".($NUM_CLOCK_PAIRS - 1).":0]",
										$PREFIX_NAME."cs_n_0"  => $PREFIX_NAME."cs_n_0",
										$PREFIX_NAME."we_n_0"  => $PREFIX_NAME."we_n_0",
										$PREFIX_NAME."ref_n_0" => $PREFIX_NAME."ref_n_0",
										$PREFIX_NAME."a_0" => $PREFIX_NAME."a_0",
										$PREFIX_NAME."ba_0" => $PREFIX_NAME."ba_0",
										#$PREFIX_NAME."dm" => $PREFIX_NAME."dm",
										$PREFIX_NAME."dm" => $PREFIX_NAME."dm[".($MEM_NUM_DEVICES - 1).":0]",
									},
								
									inout_port_map	=>
									{
										#$PREFIX_NAME."qk" => $PREFIX_NAME."qk",
										#$PREFIX_NAME."qk" => $PREFIX_NAME."qk[".($NUMBER_DQS - 1).":0]",
										$PREFIX_NAME."dq" => $PREFIX_NAME."dq",					
									},
								}),
							);
						} else {
							$module->add_contents
							(
								e_blind_instance->new
								({
									name 		=> $gWRAPPER_NAME,            
									module 		=> $gWRAPPER_NAME."_wrapper",
									comment 	=> "---------------------------------------------------------------------\n
									CIO RLDRAM II Controller\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk => "clk",
										write_clk => "write_clk",
										reset_clk_n => "reset_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										dqs_delay_ctrl => "dqs_delay_ctrl",
										local_write_req =>$PREFIX_NAME."local_write_req",
										local_read_req => $PREFIX_NAME."local_read_req",
										local_addr => $PREFIX_NAME."local_addr",
										local_bank_addr => $PREFIX_NAME."local_bank_addr",
										local_wdata => $PREFIX_NAME."local_wdata",
										local_dm => $PREFIX_NAME."local_dm",
										local_refresh_req => $PREFIX_NAME."local_refresh_req",
										#$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld",
										$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld[".($MEM_NUM_DEVICES - 1).":0]",
                                        $PREFIX_NAME."qk" => $PREFIX_NAME."qk[".($NUMBER_DQS - 1).":0]",
									},
					
									out_port_map	=>
									{
										capture_clk => $PREFIX_NAME."capture_clk",#[]",
										local_wdata_req => $PREFIX_NAME."local_wdata_req",
										local_rdata_valid => $PREFIX_NAME."local_rdata_valid",#[]",
										local_rdata => $PREFIX_NAME."local_rdata",
										local_init_done => $PREFIX_NAME."local_init_done",
										#$PREFIX_NAME."clk" => $PREFIX_NAME."clk",
										#$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n",
										#$PREFIX_NAME."clk" => $PREFIX_NAME."clk[".($NUM_CLOCK_PAIRS - 1).":0]",
										#$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n[".($NUM_CLOCK_PAIRS - 1).":0]",
										$PREFIX_NAME."cs_n_0"  => $PREFIX_NAME."cs_n_0",
										$PREFIX_NAME."we_n_0"  => $PREFIX_NAME."we_n_0",
										$PREFIX_NAME."ref_n_0" => $PREFIX_NAME."ref_n_0",
										$PREFIX_NAME."a_0" => $PREFIX_NAME."a_0",
										$PREFIX_NAME."ba_0" => $PREFIX_NAME."ba_0",
										#$PREFIX_NAME."dm" => $PREFIX_NAME."dm",
										$PREFIX_NAME."dm" => $PREFIX_NAME."dm[".($MEM_NUM_DEVICES - 1).":0]",
									},
								
									inout_port_map	=>
									{
										#$PREFIX_NAME."qk" => $PREFIX_NAME."qk",
										#$PREFIX_NAME."qk" => $PREFIX_NAME."qk[".($NUMBER_DQS - 1).":0]",
										$PREFIX_NAME."dq" => $PREFIX_NAME."dq",					
									},
								}),
							);
						}
					}
				} else {
					if($num_addr_cmd_buses > 1) {
						if ($ddio_memory_clocks eq "true") {
							$module->add_contents
							(
								e_blind_instance->new
								({
									name 		=> $gWRAPPER_NAME,            
									module 		=> $gWRAPPER_NAME."_wrapper",
									comment 	=> "---------------------------------------------------------------------\n
									CIO RLDRAM II Controller\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk => "clk",
										write_clk => "write_clk",
										reset_clk_n => "reset_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										dqs_delay_ctrl => "dqs_delay_ctrl",
										local_write_req =>$PREFIX_NAME."local_write_req",
										local_read_req => $PREFIX_NAME."local_read_req",
										local_addr => $PREFIX_NAME."local_addr",
										local_bank_addr => $PREFIX_NAME."local_bank_addr",
										local_wdata => $PREFIX_NAME."local_wdata",
										#local_dm => $PREFIX_NAME."local_dm",
										local_refresh_req => $PREFIX_NAME."local_refresh_req",
										#$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld",
										$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld[".($MEM_NUM_DEVICES - 1).":0]",
                                        $PREFIX_NAME."qk" => $PREFIX_NAME."qk[".($NUMBER_DQS - 1).":0]",
									},
					
									out_port_map	=>
									{
										capture_clk => $PREFIX_NAME."capture_clk",#[]",
										local_wdata_req => $PREFIX_NAME."local_wdata_req",
										local_rdata_valid => $PREFIX_NAME."local_rdata_valid",#[]",
										local_rdata => $PREFIX_NAME."local_rdata",
										local_init_done => $PREFIX_NAME."local_init_done",
										#$PREFIX_NAME."clk" => $PREFIX_NAME."clk",
										#$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n",
										$PREFIX_NAME."clk" => $PREFIX_NAME."clk[".($NUM_CLOCK_PAIRS - 1).":0]",
										$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n[".($NUM_CLOCK_PAIRS - 1).":0]",
										$PREFIX_NAME."cs_n_0"  => $PREFIX_NAME."cs_n_0",
										$PREFIX_NAME."we_n_0"  => $PREFIX_NAME."we_n_0",
										$PREFIX_NAME."ref_n_0" => $PREFIX_NAME."ref_n_0",
										$PREFIX_NAME."cs_n_1"  => $PREFIX_NAME."cs_n_1",
										$PREFIX_NAME."we_n_1"  => $PREFIX_NAME."we_n_1",
										$PREFIX_NAME."ref_n_1" => $PREFIX_NAME."ref_n_1",
										$PREFIX_NAME."a_0" => $PREFIX_NAME."a_0",
										$PREFIX_NAME."ba_0" => $PREFIX_NAME."ba_0",
										$PREFIX_NAME."a_1" => $PREFIX_NAME."a_1",
										$PREFIX_NAME."ba_1" => $PREFIX_NAME."ba_1",
									},
								
									inout_port_map	=>
									{
										#$PREFIX_NAME."qk" => $PREFIX_NAME."qk",
										#$PREFIX_NAME."qk" => $PREFIX_NAME."qk[".($NUMBER_DQS - 1).":0]",
										$PREFIX_NAME."dq" => $PREFIX_NAME."dq",					
									},
								}),
							);
						} else {
							$module->add_contents
							(
								e_blind_instance->new
								({
									name 		=> $gWRAPPER_NAME,            
									module 		=> $gWRAPPER_NAME."_wrapper",
									comment 	=> "---------------------------------------------------------------------\n
									CIO RLDRAM II Controller\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk => "clk",
										write_clk => "write_clk",
										reset_clk_n => "reset_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										dqs_delay_ctrl => "dqs_delay_ctrl",
										local_write_req =>$PREFIX_NAME."local_write_req",
										local_read_req => $PREFIX_NAME."local_read_req",
										local_addr => $PREFIX_NAME."local_addr",
										local_bank_addr => $PREFIX_NAME."local_bank_addr",
										local_wdata => $PREFIX_NAME."local_wdata",
										#local_dm => $PREFIX_NAME."local_dm",
										local_refresh_req => $PREFIX_NAME."local_refresh_req",
										#$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld",
										$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld[".($MEM_NUM_DEVICES - 1).":0]",
                                        $PREFIX_NAME."qk" => $PREFIX_NAME."qk[".($NUMBER_DQS - 1).":0]",
									},
					
									out_port_map	=>
									{
										capture_clk => $PREFIX_NAME."capture_clk",#[]",
										local_wdata_req => $PREFIX_NAME."local_wdata_req",
										local_rdata_valid => $PREFIX_NAME."local_rdata_valid",#[]",
										local_rdata => $PREFIX_NAME."local_rdata",
										local_init_done => $PREFIX_NAME."local_init_done",
										#$PREFIX_NAME."clk" => $PREFIX_NAME."clk",
										#$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n",
										#$PREFIX_NAME."clk" => $PREFIX_NAME."clk[".($NUM_CLOCK_PAIRS - 1).":0]",
										#$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n[".($NUM_CLOCK_PAIRS - 1).":0]",
										$PREFIX_NAME."cs_n_0"  => $PREFIX_NAME."cs_n_0",
										$PREFIX_NAME."we_n_0"  => $PREFIX_NAME."we_n_0",
										$PREFIX_NAME."ref_n_0" => $PREFIX_NAME."ref_n_0",
										$PREFIX_NAME."cs_n_1"  => $PREFIX_NAME."cs_n_1",
										$PREFIX_NAME."we_n_1"  => $PREFIX_NAME."we_n_1",
										$PREFIX_NAME."ref_n_1" => $PREFIX_NAME."ref_n_1",
										$PREFIX_NAME."a_0" => $PREFIX_NAME."a_0",
										$PREFIX_NAME."ba_0" => $PREFIX_NAME."ba_0",
										$PREFIX_NAME."a_1" => $PREFIX_NAME."a_1",
										$PREFIX_NAME."ba_1" => $PREFIX_NAME."ba_1",
									},
								
									inout_port_map	=>
									{
										#$PREFIX_NAME."qk" => $PREFIX_NAME."qk",
										#$PREFIX_NAME."qk" => $PREFIX_NAME."qk[".($NUMBER_DQS - 1).":0]",
										$PREFIX_NAME."dq" => $PREFIX_NAME."dq",					
									},
								}),
							);
						}
					} else {
						if ($ddio_memory_clocks eq "true") {
							$module->add_contents
							(
								e_blind_instance->new
								({
									name 		=> $gWRAPPER_NAME,            
									module 		=> $gWRAPPER_NAME."_wrapper",
									comment 	=> "---------------------------------------------------------------------\n
									CIO RLDRAM II Controller\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk => "clk",
										write_clk => "write_clk",
										reset_clk_n => "reset_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										dqs_delay_ctrl => "dqs_delay_ctrl",
										local_write_req =>$PREFIX_NAME."local_write_req",
										local_read_req => $PREFIX_NAME."local_read_req",
										local_addr => $PREFIX_NAME."local_addr",
										local_bank_addr => $PREFIX_NAME."local_bank_addr",
										local_wdata => $PREFIX_NAME."local_wdata",
										#local_dm => $PREFIX_NAME."local_dm",
										local_refresh_req => $PREFIX_NAME."local_refresh_req",
										#$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld",
										$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld[".($MEM_NUM_DEVICES - 1).":0]",
                                        $PREFIX_NAME."qk" => $PREFIX_NAME."qk[".($NUMBER_DQS - 1).":0]",
									},
					
									out_port_map	=>
									{
										capture_clk => $PREFIX_NAME."capture_clk",#[]",
										local_wdata_req => $PREFIX_NAME."local_wdata_req",
										local_rdata_valid => $PREFIX_NAME."local_rdata_valid",#[]",
										local_rdata => $PREFIX_NAME."local_rdata",
										local_init_done => $PREFIX_NAME."local_init_done",
										#$PREFIX_NAME."clk" => $PREFIX_NAME."clk",
										#$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n",
										$PREFIX_NAME."clk" => $PREFIX_NAME."clk[".($NUM_CLOCK_PAIRS - 1).":0]",
										$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n[".($NUM_CLOCK_PAIRS - 1).":0]",
										$PREFIX_NAME."cs_n_0"  => $PREFIX_NAME."cs_n_0",
										$PREFIX_NAME."we_n_0"  => $PREFIX_NAME."we_n_0",
										$PREFIX_NAME."ref_n_0" => $PREFIX_NAME."ref_n_0",
										$PREFIX_NAME."a_0" => $PREFIX_NAME."a_0",
										$PREFIX_NAME."ba_0" => $PREFIX_NAME."ba_0",
									},
								
									inout_port_map	=>
									{
										#$PREFIX_NAME."qk" => $PREFIX_NAME."qk",
										#$PREFIX_NAME."qk" => $PREFIX_NAME."qk[".($NUMBER_DQS - 1).":0]",
										$PREFIX_NAME."dq" => $PREFIX_NAME."dq",					
									},
								}),
							);
						} else {
							$module->add_contents
							(
								e_blind_instance->new
								({
									name 		=> $gWRAPPER_NAME,            
									module 		=> $gWRAPPER_NAME."_wrapper",
									comment 	=> "---------------------------------------------------------------------\n
									CIO RLDRAM II Controller\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk => "clk",
										write_clk => "write_clk",
										reset_clk_n => "reset_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										dqs_delay_ctrl => "dqs_delay_ctrl",
										local_write_req =>$PREFIX_NAME."local_write_req",
										local_read_req => $PREFIX_NAME."local_read_req",
										local_addr => $PREFIX_NAME."local_addr",
										local_bank_addr => $PREFIX_NAME."local_bank_addr",
										local_wdata => $PREFIX_NAME."local_wdata",
										#local_dm => $PREFIX_NAME."local_dm",
										local_refresh_req => $PREFIX_NAME."local_refresh_req",
										#$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld",
										$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld[".($MEM_NUM_DEVICES - 1).":0]",
                                        $PREFIX_NAME."qk" => $PREFIX_NAME."qk[".($NUMBER_DQS - 1).":0]",
									},
					
									out_port_map	=>
									{
										capture_clk => $PREFIX_NAME."capture_clk",#[]",
										local_wdata_req => $PREFIX_NAME."local_wdata_req",
										local_rdata_valid => $PREFIX_NAME."local_rdata_valid",#[]",
										local_rdata => $PREFIX_NAME."local_rdata",
										local_init_done => $PREFIX_NAME."local_init_done",
										#$PREFIX_NAME."clk" => $PREFIX_NAME."clk",
										#$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n",
										#$PREFIX_NAME."clk" => $PREFIX_NAME."clk[".($NUM_CLOCK_PAIRS - 1).":0]",
										#$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n[".($NUM_CLOCK_PAIRS - 1).":0]",
										$PREFIX_NAME."cs_n_0"  => $PREFIX_NAME."cs_n_0",
										$PREFIX_NAME."we_n_0"  => $PREFIX_NAME."we_n_0",
										$PREFIX_NAME."ref_n_0" => $PREFIX_NAME."ref_n_0",
										$PREFIX_NAME."a_0" => $PREFIX_NAME."a_0",
										$PREFIX_NAME."ba_0" => $PREFIX_NAME."ba_0",
									},
								
									inout_port_map	=>
									{
										#$PREFIX_NAME."qk" => $PREFIX_NAME."qk",
										#$PREFIX_NAME."qk" => $PREFIX_NAME."qk[".($NUMBER_DQS - 1).":0]",
										$PREFIX_NAME."dq" => $PREFIX_NAME."dq",					
									},
								}),
							);
						}
					}
				}
			}
		}
		else {
			if($enable_addr_cmd_clk eq "true") {
				if($enable_dm_pins eq "true") {
					if($num_addr_cmd_buses > 1) {
						if ($ddio_memory_clocks eq "true") {
							$module->add_contents
							(
								e_blind_instance->new
								({
									name 		=> $gWRAPPER_NAME,            
									module 		=> $gWRAPPER_NAME."_wrapper",
									comment 	=> "---------------------------------------------------------------------\n
									CIO RLDRAM II Controller\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk => "clk",
										write_clk => "write_clk",
										addr_cmd_clk => "addr_cmd_clk",
										non_dqs_capture_clk => "read_clk",#$FEDBACK_CLOCK_NAME,
										reset_clk_n => "reset_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										local_write_req =>$PREFIX_NAME."local_write_req",
										local_read_req => $PREFIX_NAME."local_read_req",
										local_addr => $PREFIX_NAME."local_addr",
										local_bank_addr => $PREFIX_NAME."local_bank_addr",
										local_wdata => $PREFIX_NAME."local_wdata",
										local_dm => $PREFIX_NAME."local_dm",
										local_refresh_req => $PREFIX_NAME."local_refresh_req",
										#$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld",
										$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld[".($MEM_NUM_DEVICES - 1).":0]",
									},
					
									out_port_map	=>
									{
										local_wdata_req => $PREFIX_NAME."local_wdata_req",
										local_rdata_valid => $PREFIX_NAME."local_rdata_valid",#[]",
										local_rdata => $PREFIX_NAME."local_rdata",
										local_init_done => $PREFIX_NAME."local_init_done",
										#$PREFIX_NAME."clk" => $PREFIX_NAME."clk",
										#$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n",
										$PREFIX_NAME."clk" => $PREFIX_NAME."clk[".($NUM_CLOCK_PAIRS - 1).":0]",
										$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n[".($NUM_CLOCK_PAIRS - 1).":0]",
										$PREFIX_NAME."cs_n_0"  => $PREFIX_NAME."cs_n_0",
										$PREFIX_NAME."we_n_0"  => $PREFIX_NAME."we_n_0",
										$PREFIX_NAME."ref_n_0" => $PREFIX_NAME."ref_n_0",
										$PREFIX_NAME."cs_n_1"  => $PREFIX_NAME."cs_n_1",
										$PREFIX_NAME."we_n_1"  => $PREFIX_NAME."we_n_1",
										$PREFIX_NAME."ref_n_1" => $PREFIX_NAME."ref_n_1",
										$PREFIX_NAME."a_0" => $PREFIX_NAME."a_0",
										$PREFIX_NAME."ba_0" => $PREFIX_NAME."ba_0",
										$PREFIX_NAME."a_1" => $PREFIX_NAME."a_1",
										$PREFIX_NAME."ba_1" => $PREFIX_NAME."ba_1",
										#$PREFIX_NAME."dm" => $PREFIX_NAME."dm",
										$PREFIX_NAME."dm" => $PREFIX_NAME."dm[".($MEM_NUM_DEVICES - 1).":0]",
									},
								
									inout_port_map	=>
									{
										$PREFIX_NAME."dq" => $PREFIX_NAME."dq",					
									},
								}),
							);
						} else {
							$module->add_contents
							(
								e_blind_instance->new
								({
									name 		=> $gWRAPPER_NAME,            
									module 		=> $gWRAPPER_NAME."_wrapper",
									comment 	=> "---------------------------------------------------------------------\n
									CIO RLDRAM II Controller\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk => "clk",
										write_clk => "write_clk",
										addr_cmd_clk => "addr_cmd_clk",
										non_dqs_capture_clk => "read_clk",#$FEDBACK_CLOCK_NAME,
										reset_clk_n => "reset_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										local_write_req =>$PREFIX_NAME."local_write_req",
										local_read_req => $PREFIX_NAME."local_read_req",
										local_addr => $PREFIX_NAME."local_addr",
										local_bank_addr => $PREFIX_NAME."local_bank_addr",
										local_wdata => $PREFIX_NAME."local_wdata",
										local_dm => $PREFIX_NAME."local_dm",
										local_refresh_req => $PREFIX_NAME."local_refresh_req",
										#$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld",
										$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld[".($MEM_NUM_DEVICES - 1).":0]",
									},
					
									out_port_map	=>
									{
										local_wdata_req => $PREFIX_NAME."local_wdata_req",
										local_rdata_valid => $PREFIX_NAME."local_rdata_valid",#[]",
										local_rdata => $PREFIX_NAME."local_rdata",
										local_init_done => $PREFIX_NAME."local_init_done",
										#$PREFIX_NAME."clk" => $PREFIX_NAME."clk",
										#$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n",
										#$PREFIX_NAME."clk" => $PREFIX_NAME."clk[".($NUM_CLOCK_PAIRS - 1).":0]",
										#$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n[".($NUM_CLOCK_PAIRS - 1).":0]",
										$PREFIX_NAME."cs_n_0"  => $PREFIX_NAME."cs_n_0",
										$PREFIX_NAME."we_n_0"  => $PREFIX_NAME."we_n_0",
										$PREFIX_NAME."ref_n_0" => $PREFIX_NAME."ref_n_0",
										$PREFIX_NAME."cs_n_1"  => $PREFIX_NAME."cs_n_1",
										$PREFIX_NAME."we_n_1"  => $PREFIX_NAME."we_n_1",
										$PREFIX_NAME."ref_n_1" => $PREFIX_NAME."ref_n_1",
										$PREFIX_NAME."a_0" => $PREFIX_NAME."a_0",
										$PREFIX_NAME."ba_0" => $PREFIX_NAME."ba_0",
										$PREFIX_NAME."a_1" => $PREFIX_NAME."a_1",
										$PREFIX_NAME."ba_1" => $PREFIX_NAME."ba_1",
										#$PREFIX_NAME."dm" => $PREFIX_NAME."dm",
										$PREFIX_NAME."dm" => $PREFIX_NAME."dm[".($MEM_NUM_DEVICES - 1).":0]",
									},
								
									inout_port_map	=>
									{
										$PREFIX_NAME."dq" => $PREFIX_NAME."dq",					
									},
								}),
							);
						}
					} else {
						if ($ddio_memory_clocks eq "true") {
							$module->add_contents
							(
								e_blind_instance->new
								({
									name 		=> $gWRAPPER_NAME,            
									module 		=> $gWRAPPER_NAME."_wrapper",
									comment 	=> "---------------------------------------------------------------------\n
									CIO RLDRAM II Controller\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk => "clk",
										write_clk => "write_clk",
										addr_cmd_clk => "addr_cmd_clk",
										non_dqs_capture_clk => "read_clk",#$FEDBACK_CLOCK_NAME,
										reset_clk_n => "reset_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										local_write_req =>$PREFIX_NAME."local_write_req",
										local_read_req => $PREFIX_NAME."local_read_req",
										local_addr => $PREFIX_NAME."local_addr",
										local_bank_addr => $PREFIX_NAME."local_bank_addr",
										local_wdata => $PREFIX_NAME."local_wdata",
										local_dm => $PREFIX_NAME."local_dm",
										local_refresh_req => $PREFIX_NAME."local_refresh_req",
										#$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld",
										$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld[".($MEM_NUM_DEVICES - 1).":0]",
									},
					
									out_port_map	=>
									{
										local_wdata_req => $PREFIX_NAME."local_wdata_req",
										local_rdata_valid => $PREFIX_NAME."local_rdata_valid",#[]",
										local_rdata => $PREFIX_NAME."local_rdata",
										local_init_done => $PREFIX_NAME."local_init_done",
										#$PREFIX_NAME."clk" => $PREFIX_NAME."clk",
										#$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n",
										$PREFIX_NAME."clk" => $PREFIX_NAME."clk[".($NUM_CLOCK_PAIRS - 1).":0]",
										$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n[".($NUM_CLOCK_PAIRS - 1).":0]",
										$PREFIX_NAME."cs_n_0"  => $PREFIX_NAME."cs_n_0",
										$PREFIX_NAME."we_n_0"  => $PREFIX_NAME."we_n_0",
										$PREFIX_NAME."ref_n_0" => $PREFIX_NAME."ref_n_0",
										$PREFIX_NAME."a_0" => $PREFIX_NAME."a_0",
										$PREFIX_NAME."ba_0" => $PREFIX_NAME."ba_0",
										#$PREFIX_NAME."dm" => $PREFIX_NAME."dm",
										$PREFIX_NAME."dm" => $PREFIX_NAME."dm[".($MEM_NUM_DEVICES - 1).":0]",
									},
								
									inout_port_map	=>
									{
										$PREFIX_NAME."dq" => $PREFIX_NAME."dq",					
									},
								}),
							);
						} else {
							$module->add_contents
							(
								e_blind_instance->new
								({
									name 		=> $gWRAPPER_NAME,            
									module 		=> $gWRAPPER_NAME."_wrapper",
									comment 	=> "---------------------------------------------------------------------\n
									CIO RLDRAM II Controller\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk => "clk",
										write_clk => "write_clk",
										addr_cmd_clk => "addr_cmd_clk",
										non_dqs_capture_clk => "read_clk",#$FEDBACK_CLOCK_NAME,
										reset_clk_n => "reset_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										local_write_req =>$PREFIX_NAME."local_write_req",
										local_read_req => $PREFIX_NAME."local_read_req",
										local_addr => $PREFIX_NAME."local_addr",
										local_bank_addr => $PREFIX_NAME."local_bank_addr",
										local_wdata => $PREFIX_NAME."local_wdata",
										local_dm => $PREFIX_NAME."local_dm",
										local_refresh_req => $PREFIX_NAME."local_refresh_req",
										#$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld",
										$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld[".($MEM_NUM_DEVICES - 1).":0]",
									},
					
									out_port_map	=>
									{
										local_wdata_req => $PREFIX_NAME."local_wdata_req",
										local_rdata_valid => $PREFIX_NAME."local_rdata_valid",#[]",
										local_rdata => $PREFIX_NAME."local_rdata",
										local_init_done => $PREFIX_NAME."local_init_done",
										#$PREFIX_NAME."clk" => $PREFIX_NAME."clk",
										#$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n",
										#$PREFIX_NAME."clk" => $PREFIX_NAME."clk[".($NUM_CLOCK_PAIRS - 1).":0]",
										#$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n[".($NUM_CLOCK_PAIRS - 1).":0]",
										$PREFIX_NAME."cs_n_0"  => $PREFIX_NAME."cs_n_0",
										$PREFIX_NAME."we_n_0"  => $PREFIX_NAME."we_n_0",
										$PREFIX_NAME."ref_n_0" => $PREFIX_NAME."ref_n_0",
										$PREFIX_NAME."a_0" => $PREFIX_NAME."a_0",
										$PREFIX_NAME."ba_0" => $PREFIX_NAME."ba_0",
										#$PREFIX_NAME."dm" => $PREFIX_NAME."dm",
										$PREFIX_NAME."dm" => $PREFIX_NAME."dm[".($MEM_NUM_DEVICES - 1).":0]",
									},
								
									inout_port_map	=>
									{
										$PREFIX_NAME."dq" => $PREFIX_NAME."dq",					
									},
								}),
							);
						}
					}
				} else {
					if($num_addr_cmd_buses > 1) {
						if ($ddio_memory_clocks eq "true") {
							$module->add_contents
							(
								e_blind_instance->new
								({
									name 		=> $gWRAPPER_NAME,            
									module 		=> $gWRAPPER_NAME."_wrapper",
									comment 	=> "---------------------------------------------------------------------\n
									CIO RLDRAM II Controller\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk => "clk",
										write_clk => "write_clk",
										addr_cmd_clk => "addr_cmd_clk",
										non_dqs_capture_clk => "read_clk",#$FEDBACK_CLOCK_NAME,
										reset_clk_n => "reset_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										local_write_req =>$PREFIX_NAME."local_write_req",
										local_read_req => $PREFIX_NAME."local_read_req",
										local_addr => $PREFIX_NAME."local_addr",
										local_bank_addr => $PREFIX_NAME."local_bank_addr",
										local_wdata => $PREFIX_NAME."local_wdata",
										#local_dm => $PREFIX_NAME."local_dm",
										local_refresh_req => $PREFIX_NAME."local_refresh_req",
										#$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld",
										$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld[".($MEM_NUM_DEVICES - 1).":0]",
									},
					
									out_port_map	=>
									{
										local_wdata_req => $PREFIX_NAME."local_wdata_req",
										local_rdata_valid => $PREFIX_NAME."local_rdata_valid",#[]",
										local_rdata => $PREFIX_NAME."local_rdata",
										local_init_done => $PREFIX_NAME."local_init_done",
										#$PREFIX_NAME."clk" => $PREFIX_NAME."clk",
										#$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n",
										$PREFIX_NAME."clk" => $PREFIX_NAME."clk[".($NUM_CLOCK_PAIRS - 1).":0]",
										$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n[".($NUM_CLOCK_PAIRS - 1).":0]",
										$PREFIX_NAME."cs_n_0"  => $PREFIX_NAME."cs_n_0",
										$PREFIX_NAME."we_n_0"  => $PREFIX_NAME."we_n_0",
										$PREFIX_NAME."ref_n_0" => $PREFIX_NAME."ref_n_0",
										$PREFIX_NAME."cs_n_1"  => $PREFIX_NAME."cs_n_1",
										$PREFIX_NAME."we_n_1"  => $PREFIX_NAME."we_n_1",
										$PREFIX_NAME."ref_n_1" => $PREFIX_NAME."ref_n_1",
										$PREFIX_NAME."a_0" => $PREFIX_NAME."a_0",
										$PREFIX_NAME."ba_0" => $PREFIX_NAME."ba_0",
										$PREFIX_NAME."a_1" => $PREFIX_NAME."a_1",
										$PREFIX_NAME."ba_1" => $PREFIX_NAME."ba_1",
									},
								
									inout_port_map	=>
									{
										$PREFIX_NAME."dq" => $PREFIX_NAME."dq",					
									},
								}),
							);
						} else {
							$module->add_contents
							(
								e_blind_instance->new
								({
									name 		=> $gWRAPPER_NAME,            
									module 		=> $gWRAPPER_NAME."_wrapper",
									comment 	=> "---------------------------------------------------------------------\n
									CIO RLDRAM II Controller\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk => "clk",
										write_clk => "write_clk",
										addr_cmd_clk => "addr_cmd_clk",
										non_dqs_capture_clk => "read_clk",#$FEDBACK_CLOCK_NAME,
										reset_clk_n => "reset_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										local_write_req =>$PREFIX_NAME."local_write_req",
										local_read_req => $PREFIX_NAME."local_read_req",
										local_addr => $PREFIX_NAME."local_addr",
										local_bank_addr => $PREFIX_NAME."local_bank_addr",
										local_wdata => $PREFIX_NAME."local_wdata",
										#local_dm => $PREFIX_NAME."local_dm",
										local_refresh_req => $PREFIX_NAME."local_refresh_req",
										#$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld",
										$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld[".($MEM_NUM_DEVICES - 1).":0]",
									},
					
									out_port_map	=>
									{
										local_wdata_req => $PREFIX_NAME."local_wdata_req",
										local_rdata_valid => $PREFIX_NAME."local_rdata_valid",#[]",
										local_rdata => $PREFIX_NAME."local_rdata",
										local_init_done => $PREFIX_NAME."local_init_done",
										#$PREFIX_NAME."clk" => $PREFIX_NAME."clk",
										#$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n",
										#$PREFIX_NAME."clk" => $PREFIX_NAME."clk[".($NUM_CLOCK_PAIRS - 1).":0]",
										#$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n[".($NUM_CLOCK_PAIRS - 1).":0]",
										$PREFIX_NAME."cs_n_0"  => $PREFIX_NAME."cs_n_0",
										$PREFIX_NAME."we_n_0"  => $PREFIX_NAME."we_n_0",
										$PREFIX_NAME."ref_n_0" => $PREFIX_NAME."ref_n_0",
										$PREFIX_NAME."cs_n_1"  => $PREFIX_NAME."cs_n_1",
										$PREFIX_NAME."we_n_1"  => $PREFIX_NAME."we_n_1",
										$PREFIX_NAME."ref_n_1" => $PREFIX_NAME."ref_n_1",
										$PREFIX_NAME."a_0" => $PREFIX_NAME."a_0",
										$PREFIX_NAME."ba_0" => $PREFIX_NAME."ba_0",
										$PREFIX_NAME."a_1" => $PREFIX_NAME."a_1",
										$PREFIX_NAME."ba_1" => $PREFIX_NAME."ba_1",
									},
								
									inout_port_map	=>
									{
										$PREFIX_NAME."dq" => $PREFIX_NAME."dq",					
									},
								}),
							);
						}
					} else {
						if ($ddio_memory_clocks eq "true") {
							$module->add_contents
							(
								e_blind_instance->new
								({
									name 		=> $gWRAPPER_NAME,            
									module 		=> $gWRAPPER_NAME."_wrapper",
									comment 	=> "---------------------------------------------------------------------\n
									CIO RLDRAM II Controller\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk => "clk",
										write_clk => "write_clk",
										addr_cmd_clk => "addr_cmd_clk",
										non_dqs_capture_clk => "read_clk",#$FEDBACK_CLOCK_NAME,
										reset_clk_n => "reset_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										local_write_req =>$PREFIX_NAME."local_write_req",
										local_read_req => $PREFIX_NAME."local_read_req",
										local_addr => $PREFIX_NAME."local_addr",
										local_bank_addr => $PREFIX_NAME."local_bank_addr",
										local_wdata => $PREFIX_NAME."local_wdata",
										#local_dm => $PREFIX_NAME."local_dm",
										local_refresh_req => $PREFIX_NAME."local_refresh_req",
										#$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld",
										$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld[".($MEM_NUM_DEVICES - 1).":0]",
									},
					
									out_port_map	=>
									{
										local_wdata_req => $PREFIX_NAME."local_wdata_req",
										local_rdata_valid => $PREFIX_NAME."local_rdata_valid",#[]",
										local_rdata => $PREFIX_NAME."local_rdata",
										local_init_done => $PREFIX_NAME."local_init_done",
										#$PREFIX_NAME."clk" => $PREFIX_NAME."clk",
										#$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n",
										$PREFIX_NAME."clk" => $PREFIX_NAME."clk[".($NUM_CLOCK_PAIRS - 1).":0]",
										$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n[".($NUM_CLOCK_PAIRS - 1).":0]",
										$PREFIX_NAME."cs_n_0"  => $PREFIX_NAME."cs_n_0",
										$PREFIX_NAME."we_n_0"  => $PREFIX_NAME."we_n_0",
										$PREFIX_NAME."ref_n_0" => $PREFIX_NAME."ref_n_0",
										$PREFIX_NAME."a_0" => $PREFIX_NAME."a_0",
										$PREFIX_NAME."ba_0" => $PREFIX_NAME."ba_0",
									},
								
									inout_port_map	=>
									{
										$PREFIX_NAME."dq" => $PREFIX_NAME."dq",					
									},
								}),
							);
						} else {
							$module->add_contents
							(
								e_blind_instance->new
								({
									name 		=> $gWRAPPER_NAME,            
									module 		=> $gWRAPPER_NAME."_wrapper",
									comment 	=> "---------------------------------------------------------------------\n
									CIO RLDRAM II Controller\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk => "clk",
										write_clk => "write_clk",
										addr_cmd_clk => "addr_cmd_clk",
										non_dqs_capture_clk => "read_clk",#$FEDBACK_CLOCK_NAME,
										reset_clk_n => "reset_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										local_write_req =>$PREFIX_NAME."local_write_req",
										local_read_req => $PREFIX_NAME."local_read_req",
										local_addr => $PREFIX_NAME."local_addr",
										local_bank_addr => $PREFIX_NAME."local_bank_addr",
										local_wdata => $PREFIX_NAME."local_wdata",
										#local_dm => $PREFIX_NAME."local_dm",
										local_refresh_req => $PREFIX_NAME."local_refresh_req",
										#$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld",
										$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld[".($MEM_NUM_DEVICES - 1).":0]",
									},
					
									out_port_map	=>
									{
										local_wdata_req => $PREFIX_NAME."local_wdata_req",
										local_rdata_valid => $PREFIX_NAME."local_rdata_valid",#[]",
										local_rdata => $PREFIX_NAME."local_rdata",
										local_init_done => $PREFIX_NAME."local_init_done",
										#$PREFIX_NAME."clk" => $PREFIX_NAME."clk",
										#$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n",
										#$PREFIX_NAME."clk" => $PREFIX_NAME."clk[".($NUM_CLOCK_PAIRS - 1).":0]",
										#$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n[".($NUM_CLOCK_PAIRS - 1).":0]",
										$PREFIX_NAME."cs_n_0"  => $PREFIX_NAME."cs_n_0",
										$PREFIX_NAME."we_n_0"  => $PREFIX_NAME."we_n_0",
										$PREFIX_NAME."ref_n_0" => $PREFIX_NAME."ref_n_0",
										$PREFIX_NAME."a_0" => $PREFIX_NAME."a_0",
										$PREFIX_NAME."ba_0" => $PREFIX_NAME."ba_0",
									},
								
									inout_port_map	=>
									{
										$PREFIX_NAME."dq" => $PREFIX_NAME."dq",					
									},
								}),
							);
						}
					}
				}
			}
			else
			{
				if($enable_dm_pins eq "true") {
					if($num_addr_cmd_buses > 1) {
						if ($ddio_memory_clocks eq "true") {
							$module->add_contents
							(
								e_blind_instance->new
								({
									name 		=> $gWRAPPER_NAME,            
									module 		=> $gWRAPPER_NAME."_wrapper",
									comment 	=> "---------------------------------------------------------------------\n
									CIO RLDRAM II Controller\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk => "clk",
										write_clk => "write_clk",
										non_dqs_capture_clk => "read_clk",#$FEDBACK_CLOCK_NAME,
										reset_clk_n => "reset_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										local_write_req =>$PREFIX_NAME."local_write_req",
										local_read_req => $PREFIX_NAME."local_read_req",
										local_addr => $PREFIX_NAME."local_addr",
										local_bank_addr => $PREFIX_NAME."local_bank_addr",
										local_wdata => $PREFIX_NAME."local_wdata",
										local_dm => $PREFIX_NAME."local_dm",
										local_refresh_req => $PREFIX_NAME."local_refresh_req",
										#$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld",
										$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld[".($MEM_NUM_DEVICES - 1).":0]",
									},
					
									out_port_map	=>
									{
										local_wdata_req => $PREFIX_NAME."local_wdata_req",
										local_rdata_valid => $PREFIX_NAME."local_rdata_valid",#[]",
										local_rdata => $PREFIX_NAME."local_rdata",
										local_init_done => $PREFIX_NAME."local_init_done",
										#$PREFIX_NAME."clk" => $PREFIX_NAME."clk",
										#$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n",
										$PREFIX_NAME."clk" => $PREFIX_NAME."clk[".($NUM_CLOCK_PAIRS - 1).":0]",
										$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n[".($NUM_CLOCK_PAIRS - 1).":0]",
										$PREFIX_NAME."cs_n_0"  => $PREFIX_NAME."cs_n_0",
										$PREFIX_NAME."we_n_0"  => $PREFIX_NAME."we_n_0",
										$PREFIX_NAME."ref_n_0" => $PREFIX_NAME."ref_n_0",
										$PREFIX_NAME."cs_n_1"  => $PREFIX_NAME."cs_n_1",
										$PREFIX_NAME."we_n_1"  => $PREFIX_NAME."we_n_1",
										$PREFIX_NAME."ref_n_1" => $PREFIX_NAME."ref_n_1",
										$PREFIX_NAME."a_0" => $PREFIX_NAME."a_0",
										$PREFIX_NAME."ba_0" => $PREFIX_NAME."ba_0",
										$PREFIX_NAME."a_1" => $PREFIX_NAME."a_1",
										$PREFIX_NAME."ba_1" => $PREFIX_NAME."ba_1",
										#$PREFIX_NAME."dm" => $PREFIX_NAME."dm",
										$PREFIX_NAME."dm" => $PREFIX_NAME."dm[".($MEM_NUM_DEVICES - 1).":0]",
									},
								
									inout_port_map	=>
									{
										$PREFIX_NAME."dq" => $PREFIX_NAME."dq",					
									},
								}),
							);
						} else {
							$module->add_contents
							(
								e_blind_instance->new
								({
									name 		=> $gWRAPPER_NAME,            
									module 		=> $gWRAPPER_NAME."_wrapper",
									comment 	=> "---------------------------------------------------------------------\n
									CIO RLDRAM II Controller\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk => "clk",
										write_clk => "write_clk",
										non_dqs_capture_clk => "read_clk",#$FEDBACK_CLOCK_NAME,
										reset_clk_n => "reset_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										local_write_req =>$PREFIX_NAME."local_write_req",
										local_read_req => $PREFIX_NAME."local_read_req",
										local_addr => $PREFIX_NAME."local_addr",
										local_bank_addr => $PREFIX_NAME."local_bank_addr",
										local_wdata => $PREFIX_NAME."local_wdata",
										local_dm => $PREFIX_NAME."local_dm",
										local_refresh_req => $PREFIX_NAME."local_refresh_req",
										#$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld",
										$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld[".($MEM_NUM_DEVICES - 1).":0]",
									},
					
									out_port_map	=>
									{
										local_wdata_req => $PREFIX_NAME."local_wdata_req",
										local_rdata_valid => $PREFIX_NAME."local_rdata_valid",#[]",
										local_rdata => $PREFIX_NAME."local_rdata",
										local_init_done => $PREFIX_NAME."local_init_done",
										#$PREFIX_NAME."clk" => $PREFIX_NAME."clk",
										#$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n",
										#$PREFIX_NAME."clk" => $PREFIX_NAME."clk[".($NUM_CLOCK_PAIRS - 1).":0]",
										#$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n[".($NUM_CLOCK_PAIRS - 1).":0]",
										$PREFIX_NAME."cs_n_0"  => $PREFIX_NAME."cs_n_0",
										$PREFIX_NAME."we_n_0"  => $PREFIX_NAME."we_n_0",
										$PREFIX_NAME."ref_n_0" => $PREFIX_NAME."ref_n_0",
										$PREFIX_NAME."cs_n_1"  => $PREFIX_NAME."cs_n_1",
										$PREFIX_NAME."we_n_1"  => $PREFIX_NAME."we_n_1",
										$PREFIX_NAME."ref_n_1" => $PREFIX_NAME."ref_n_1",
										$PREFIX_NAME."a_0" => $PREFIX_NAME."a_0",
										$PREFIX_NAME."ba_0" => $PREFIX_NAME."ba_0",
										$PREFIX_NAME."a_1" => $PREFIX_NAME."a_1",
										$PREFIX_NAME."ba_1" => $PREFIX_NAME."ba_1",
										#$PREFIX_NAME."dm" => $PREFIX_NAME."dm",
										$PREFIX_NAME."dm" => $PREFIX_NAME."dm[".($MEM_NUM_DEVICES - 1).":0]",
									},
								
									inout_port_map	=>
									{
										$PREFIX_NAME."dq" => $PREFIX_NAME."dq",					
									},
								}),
							);
						}
					} else {
						if ($ddio_memory_clocks eq "true") {
							$module->add_contents
							(
								e_blind_instance->new
								({
									name 		=> $gWRAPPER_NAME,            
									module 		=> $gWRAPPER_NAME."_wrapper",
									comment 	=> "---------------------------------------------------------------------\n
									CIO RLDRAM II Controller\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk => "clk",
										write_clk => "write_clk",
										non_dqs_capture_clk => "read_clk",#$FEDBACK_CLOCK_NAME,
										reset_clk_n => "reset_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										local_write_req =>$PREFIX_NAME."local_write_req",
										local_read_req => $PREFIX_NAME."local_read_req",
										local_addr => $PREFIX_NAME."local_addr",
										local_bank_addr => $PREFIX_NAME."local_bank_addr",
										local_wdata => $PREFIX_NAME."local_wdata",
										local_dm => $PREFIX_NAME."local_dm",
										local_refresh_req => $PREFIX_NAME."local_refresh_req",
										#$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld",
										$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld[".($MEM_NUM_DEVICES - 1).":0]",
									},
					
									out_port_map	=>
									{
										local_wdata_req => $PREFIX_NAME."local_wdata_req",
										local_rdata_valid => $PREFIX_NAME."local_rdata_valid",#[]",
										local_rdata => $PREFIX_NAME."local_rdata",
										local_init_done => $PREFIX_NAME."local_init_done",
										#$PREFIX_NAME."clk" => $PREFIX_NAME."clk",
										#$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n",
										$PREFIX_NAME."clk" => $PREFIX_NAME."clk[".($NUM_CLOCK_PAIRS - 1).":0]",
										$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n[".($NUM_CLOCK_PAIRS - 1).":0]",
										$PREFIX_NAME."cs_n_0"  => $PREFIX_NAME."cs_n_0",
										$PREFIX_NAME."we_n_0"  => $PREFIX_NAME."we_n_0",
										$PREFIX_NAME."ref_n_0" => $PREFIX_NAME."ref_n_0",
										$PREFIX_NAME."a_0" => $PREFIX_NAME."a_0",
										$PREFIX_NAME."ba_0" => $PREFIX_NAME."ba_0",
										#$PREFIX_NAME."dm" => $PREFIX_NAME."dm",
										$PREFIX_NAME."dm" => $PREFIX_NAME."dm[".($MEM_NUM_DEVICES - 1).":0]",
									},
								
									inout_port_map	=>
									{
										$PREFIX_NAME."dq" => $PREFIX_NAME."dq",					
									},
								}),
							);
						} else {
							$module->add_contents
							(
								e_blind_instance->new
								({
									name 		=> $gWRAPPER_NAME,            
									module 		=> $gWRAPPER_NAME."_wrapper",
									comment 	=> "---------------------------------------------------------------------\n
									CIO RLDRAM II Controller\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk => "clk",
										write_clk => "write_clk",
										non_dqs_capture_clk => "read_clk",#$FEDBACK_CLOCK_NAME,
										reset_clk_n => "reset_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										local_write_req =>$PREFIX_NAME."local_write_req",
										local_read_req => $PREFIX_NAME."local_read_req",
										local_addr => $PREFIX_NAME."local_addr",
										local_bank_addr => $PREFIX_NAME."local_bank_addr",
										local_wdata => $PREFIX_NAME."local_wdata",
										local_dm => $PREFIX_NAME."local_dm",
										local_refresh_req => $PREFIX_NAME."local_refresh_req",
										#$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld",
										$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld[".($MEM_NUM_DEVICES - 1).":0]",
									},
					
									out_port_map	=>
									{
										local_wdata_req => $PREFIX_NAME."local_wdata_req",
										local_rdata_valid => $PREFIX_NAME."local_rdata_valid",#[]",
										local_rdata => $PREFIX_NAME."local_rdata",
										local_init_done => $PREFIX_NAME."local_init_done",
										#$PREFIX_NAME."clk" => $PREFIX_NAME."clk",
										#$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n",
										#$PREFIX_NAME."clk" => $PREFIX_NAME."clk[".($NUM_CLOCK_PAIRS - 1).":0]",
										#$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n[".($NUM_CLOCK_PAIRS - 1).":0]",
										$PREFIX_NAME."cs_n_0"  => $PREFIX_NAME."cs_n_0",
										$PREFIX_NAME."we_n_0"  => $PREFIX_NAME."we_n_0",
										$PREFIX_NAME."ref_n_0" => $PREFIX_NAME."ref_n_0",
										$PREFIX_NAME."a_0" => $PREFIX_NAME."a_0",
										$PREFIX_NAME."ba_0" => $PREFIX_NAME."ba_0",
										#$PREFIX_NAME."dm" => $PREFIX_NAME."dm",
										$PREFIX_NAME."dm" => $PREFIX_NAME."dm[".($MEM_NUM_DEVICES - 1).":0]",
									},
								
									inout_port_map	=>
									{
										$PREFIX_NAME."dq" => $PREFIX_NAME."dq",					
									},
								}),
							);
						}
					}
				} else {
					if($num_addr_cmd_buses > 1) {
						if ($ddio_memory_clocks eq "true") {
							$module->add_contents
							(
								e_blind_instance->new
								({
									name 		=> $gWRAPPER_NAME,            
									module 		=> $gWRAPPER_NAME."_wrapper",
									comment 	=> "---------------------------------------------------------------------\n
									CIO RLDRAM II Controller\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk => "clk",
										write_clk => "write_clk",
										non_dqs_capture_clk => "read_clk",#$FEDBACK_CLOCK_NAME,
										reset_clk_n => "reset_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										local_write_req =>$PREFIX_NAME."local_write_req",
										local_read_req => $PREFIX_NAME."local_read_req",
										local_addr => $PREFIX_NAME."local_addr",
										local_bank_addr => $PREFIX_NAME."local_bank_addr",
										local_wdata => $PREFIX_NAME."local_wdata",
										#local_dm => $PREFIX_NAME."local_dm",
										local_refresh_req => $PREFIX_NAME."local_refresh_req",
										#$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld",
										$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld[".($MEM_NUM_DEVICES - 1).":0]",
									},
					
									out_port_map	=>
									{
										local_wdata_req => $PREFIX_NAME."local_wdata_req",
										local_rdata_valid => $PREFIX_NAME."local_rdata_valid",#[]",
										local_rdata => $PREFIX_NAME."local_rdata",
										local_init_done => $PREFIX_NAME."local_init_done",
										#$PREFIX_NAME."clk" => $PREFIX_NAME."clk",
										#$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n",
										$PREFIX_NAME."clk" => $PREFIX_NAME."clk[".($NUM_CLOCK_PAIRS - 1).":0]",
										$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n[".($NUM_CLOCK_PAIRS - 1).":0]",
										$PREFIX_NAME."cs_n_0"  => $PREFIX_NAME."cs_n_0",
										$PREFIX_NAME."we_n_0"  => $PREFIX_NAME."we_n_0",
										$PREFIX_NAME."ref_n_0" => $PREFIX_NAME."ref_n_0",
										$PREFIX_NAME."cs_n_1"  => $PREFIX_NAME."cs_n_1",
										$PREFIX_NAME."we_n_1"  => $PREFIX_NAME."we_n_1",
										$PREFIX_NAME."ref_n_1" => $PREFIX_NAME."ref_n_1",
										$PREFIX_NAME."a_0" => $PREFIX_NAME."a_0",
										$PREFIX_NAME."ba_0" => $PREFIX_NAME."ba_0",
										$PREFIX_NAME."a_1" => $PREFIX_NAME."a_1",
										$PREFIX_NAME."ba_1" => $PREFIX_NAME."ba_1",
									},
								
									inout_port_map	=>
									{
										$PREFIX_NAME."dq" => $PREFIX_NAME."dq",					
									},
								}),
							);
						} else {
							$module->add_contents
							(
								e_blind_instance->new
								({
									name 		=> $gWRAPPER_NAME,            
									module 		=> $gWRAPPER_NAME."_wrapper",
									comment 	=> "---------------------------------------------------------------------\n
									CIO RLDRAM II Controller\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk => "clk",
										write_clk => "write_clk",
										non_dqs_capture_clk => "read_clk",#$FEDBACK_CLOCK_NAME,
										reset_clk_n => "reset_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										local_write_req =>$PREFIX_NAME."local_write_req",
										local_read_req => $PREFIX_NAME."local_read_req",
										local_addr => $PREFIX_NAME."local_addr",
										local_bank_addr => $PREFIX_NAME."local_bank_addr",
										local_wdata => $PREFIX_NAME."local_wdata",
										#local_dm => $PREFIX_NAME."local_dm",
										local_refresh_req => $PREFIX_NAME."local_refresh_req",
										#$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld",
										$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld[".($MEM_NUM_DEVICES - 1).":0]",
									},
					
									out_port_map	=>
									{
										local_wdata_req => $PREFIX_NAME."local_wdata_req",
										local_rdata_valid => $PREFIX_NAME."local_rdata_valid",#[]",
										local_rdata => $PREFIX_NAME."local_rdata",
										local_init_done => $PREFIX_NAME."local_init_done",
										#$PREFIX_NAME."clk" => $PREFIX_NAME."clk",
										#$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n",
										#$PREFIX_NAME."clk" => $PREFIX_NAME."clk[".($NUM_CLOCK_PAIRS - 1).":0]",
										#$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n[".($NUM_CLOCK_PAIRS - 1).":0]",
										$PREFIX_NAME."cs_n_0"  => $PREFIX_NAME."cs_n_0",
										$PREFIX_NAME."we_n_0"  => $PREFIX_NAME."we_n_0",
										$PREFIX_NAME."ref_n_0" => $PREFIX_NAME."ref_n_0",
										$PREFIX_NAME."cs_n_1"  => $PREFIX_NAME."cs_n_1",
										$PREFIX_NAME."we_n_1"  => $PREFIX_NAME."we_n_1",
										$PREFIX_NAME."ref_n_1" => $PREFIX_NAME."ref_n_1",
										$PREFIX_NAME."a_0" => $PREFIX_NAME."a_0",
										$PREFIX_NAME."ba_0" => $PREFIX_NAME."ba_0",
										$PREFIX_NAME."a_1" => $PREFIX_NAME."a_1",
										$PREFIX_NAME."ba_1" => $PREFIX_NAME."ba_1",
									},
								
									inout_port_map	=>
									{
										$PREFIX_NAME."dq" => $PREFIX_NAME."dq",					
									},
								}),
							);
						}
					} else {
						if ($ddio_memory_clocks eq "true") {
							$module->add_contents
							(
								e_blind_instance->new
								({
									name 		=> $gWRAPPER_NAME,            
									module 		=> $gWRAPPER_NAME."_wrapper",
									comment 	=> "---------------------------------------------------------------------\n
									CIO RLDRAM II Controller\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk => "clk",
										write_clk => "write_clk",
										non_dqs_capture_clk => "read_clk",#$FEDBACK_CLOCK_NAME,
										reset_clk_n => "reset_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										local_write_req =>$PREFIX_NAME."local_write_req",
										local_read_req => $PREFIX_NAME."local_read_req",
										local_addr => $PREFIX_NAME."local_addr",
										local_bank_addr => $PREFIX_NAME."local_bank_addr",
										local_wdata => $PREFIX_NAME."local_wdata",
										#local_dm => $PREFIX_NAME."local_dm",
										local_refresh_req => $PREFIX_NAME."local_refresh_req",
										#$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld",
										$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld[".($MEM_NUM_DEVICES - 1).":0]",
									},
					
									out_port_map	=>
									{
										local_wdata_req => $PREFIX_NAME."local_wdata_req",
										local_rdata_valid => $PREFIX_NAME."local_rdata_valid",#[]",
										local_rdata => $PREFIX_NAME."local_rdata",
										local_init_done => $PREFIX_NAME."local_init_done",
										#$PREFIX_NAME."clk" => $PREFIX_NAME."clk",
										#$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n",
										$PREFIX_NAME."clk" => $PREFIX_NAME."clk[".($NUM_CLOCK_PAIRS - 1).":0]",
										$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n[".($NUM_CLOCK_PAIRS - 1).":0]",
										$PREFIX_NAME."cs_n_0"  => $PREFIX_NAME."cs_n_0",
										$PREFIX_NAME."we_n_0"  => $PREFIX_NAME."we_n_0",
										$PREFIX_NAME."ref_n_0" => $PREFIX_NAME."ref_n_0",
										$PREFIX_NAME."a_0" => $PREFIX_NAME."a_0",
										$PREFIX_NAME."ba_0" => $PREFIX_NAME."ba_0",
									},
								
									inout_port_map	=>
									{
										$PREFIX_NAME."dq" => $PREFIX_NAME."dq",					
									},
								}),
							);
						} else {
							$module->add_contents
							(
								e_blind_instance->new
								({
									name 		=> $gWRAPPER_NAME,            
									module 		=> $gWRAPPER_NAME."_wrapper",
									comment 	=> "---------------------------------------------------------------------\n
									CIO RLDRAM II Controller\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk => "clk",
										write_clk => "write_clk",
										non_dqs_capture_clk => "read_clk",#$FEDBACK_CLOCK_NAME,
										reset_clk_n => "reset_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										local_write_req =>$PREFIX_NAME."local_write_req",
										local_read_req => $PREFIX_NAME."local_read_req",
										local_addr => $PREFIX_NAME."local_addr",
										local_bank_addr => $PREFIX_NAME."local_bank_addr",
										local_wdata => $PREFIX_NAME."local_wdata",
										#local_dm => $PREFIX_NAME."local_dm",
										local_refresh_req => $PREFIX_NAME."local_refresh_req",
										#$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld",
										$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld[".($MEM_NUM_DEVICES - 1).":0]",
									},
					
									out_port_map	=>
									{
										local_wdata_req => $PREFIX_NAME."local_wdata_req",
										local_rdata_valid => $PREFIX_NAME."local_rdata_valid",#[]",
										local_rdata => $PREFIX_NAME."local_rdata",
										local_init_done => $PREFIX_NAME."local_init_done",
										#$PREFIX_NAME."clk" => $PREFIX_NAME."clk",
										#$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n",
										#$PREFIX_NAME."clk" => $PREFIX_NAME."clk[".($NUM_CLOCK_PAIRS - 1).":0]",
										#$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n[".($NUM_CLOCK_PAIRS - 1).":0]",
										$PREFIX_NAME."cs_n_0"  => $PREFIX_NAME."cs_n_0",
										$PREFIX_NAME."we_n_0"  => $PREFIX_NAME."we_n_0",
										$PREFIX_NAME."ref_n_0" => $PREFIX_NAME."ref_n_0",
										$PREFIX_NAME."a_0" => $PREFIX_NAME."a_0",
										$PREFIX_NAME."ba_0" => $PREFIX_NAME."ba_0",
									},
								
									inout_port_map	=>
									{
										$PREFIX_NAME."dq" => $PREFIX_NAME."dq",					
									},
								}),
							);
						}
					}
				}
			}
		}
	}
	else
	{
		if ($ENABLE_CAPTURE_CLK eq "false") {
			if($enable_addr_cmd_clk eq "true") {
				if($enable_dm_pins eq "true") {
					if($num_addr_cmd_buses > 1) {
						if ($ddio_memory_clocks eq "true") {
							$module->add_contents
							(
								e_blind_instance->new
								({
									name 		=> $gWRAPPER_NAME,            
									module 		=> $gWRAPPER_NAME."_wrapper",
									comment 	=> "---------------------------------------------------------------------\n
									SIO RLDRAM II Controller\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk => "clk",
										write_clk => "write_clk",
										addr_cmd_clk => "addr_cmd_clk",
										reset_clk_n => "reset_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										dqs_delay_ctrl => "dqs_delay_ctrl",
										local_write_req => $PREFIX_NAME."local_write_req",
										local_read_req => $PREFIX_NAME."local_read_req",
										local_addr => $PREFIX_NAME."local_addr",
										local_bank_addr => $PREFIX_NAME."local_bank_addr",
										local_wdata => $PREFIX_NAME."local_wdata",
										local_dm => $PREFIX_NAME."local_dm",
										local_refresh_req => $PREFIX_NAME."local_refresh_req",
										#$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld",
										$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld[".($MEM_NUM_DEVICES - 1).":0]",
										$PREFIX_NAME."q" => $PREFIX_NAME."q",
                                        $PREFIX_NAME."qk" => $PREFIX_NAME."qk[".($NUMBER_DQS - 1).":0]",
									},
					
									out_port_map	=>
									{
										capture_clk => $PREFIX_NAME."capture_clk",
										local_wdata_req => $PREFIX_NAME."local_wdata_req",
										local_rdata_valid => $PREFIX_NAME."local_rdata_valid",#[]",
										local_rdata => $PREFIX_NAME."local_rdata",
										local_init_done => $PREFIX_NAME."local_init_done",
										#$PREFIX_NAME."clk" => $PREFIX_NAME."clk",
										#$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n",
										$PREFIX_NAME."clk" => $PREFIX_NAME."clk[".($NUM_CLOCK_PAIRS - 1).":0]",
										$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n[".($NUM_CLOCK_PAIRS - 1).":0]",
										$PREFIX_NAME."cs_n_0"  => $PREFIX_NAME."cs_n_0",
										$PREFIX_NAME."we_n_0"  => $PREFIX_NAME."we_n_0",
										$PREFIX_NAME."ref_n_0" => $PREFIX_NAME."ref_n_0",
										$PREFIX_NAME."cs_n_1"  => $PREFIX_NAME."cs_n_1",
										$PREFIX_NAME."we_n_1"  => $PREFIX_NAME."we_n_1",
										$PREFIX_NAME."ref_n_1" => $PREFIX_NAME."ref_n_1",
										$PREFIX_NAME."a_0" => $PREFIX_NAME."a_0",
										$PREFIX_NAME."ba_0" => $PREFIX_NAME."ba_0",
										$PREFIX_NAME."a_1" => $PREFIX_NAME."a_1",
										$PREFIX_NAME."ba_1" => $PREFIX_NAME."ba_1",
										#$PREFIX_NAME."dm" => $PREFIX_NAME."dm",
										$PREFIX_NAME."dm" => $PREFIX_NAME."dm[".($MEM_NUM_DEVICES - 1).":0]",
										$PREFIX_NAME."d" => $PREFIX_NAME."d",
									},
									
									inout_port_map	=>
									{
										#$PREFIX_NAME."qk" => $PREFIX_NAME."qk",
										#$PREFIX_NAME."qk" => $PREFIX_NAME."qk[".($NUMBER_DQS - 1).":0]",
									},
								}),
							);
						} else {
							$module->add_contents
							(
								e_blind_instance->new
								({
									name 		=> $gWRAPPER_NAME,            
									module 		=> $gWRAPPER_NAME."_wrapper",
									comment 	=> "---------------------------------------------------------------------\n
									SIO RLDRAM II Controller\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk => "clk",
										write_clk => "write_clk",
										addr_cmd_clk => "addr_cmd_clk",
										reset_clk_n => "reset_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										dqs_delay_ctrl => "dqs_delay_ctrl",
										local_write_req => $PREFIX_NAME."local_write_req",
										local_read_req => $PREFIX_NAME."local_read_req",
										local_addr => $PREFIX_NAME."local_addr",
										local_bank_addr => $PREFIX_NAME."local_bank_addr",
										local_wdata => $PREFIX_NAME."local_wdata",
										local_dm => $PREFIX_NAME."local_dm",
										local_refresh_req => $PREFIX_NAME."local_refresh_req",
										#$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld",
										$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld[".($MEM_NUM_DEVICES - 1).":0]",
										$PREFIX_NAME."q" => $PREFIX_NAME."q",
                                        $PREFIX_NAME."qk" => $PREFIX_NAME."qk[".($NUMBER_DQS - 1).":0]",
									},
					
									out_port_map	=>
									{
										capture_clk => $PREFIX_NAME."capture_clk",
										local_wdata_req => $PREFIX_NAME."local_wdata_req",
										local_rdata_valid => $PREFIX_NAME."local_rdata_valid",#[]",
										local_rdata => $PREFIX_NAME."local_rdata",
										local_init_done => $PREFIX_NAME."local_init_done",
										#$PREFIX_NAME."clk" => $PREFIX_NAME."clk",
										#$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n",
										#$PREFIX_NAME."clk" => $PREFIX_NAME."clk[".($NUM_CLOCK_PAIRS - 1).":0]",
										#$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n[".($NUM_CLOCK_PAIRS - 1).":0]",
										$PREFIX_NAME."cs_n_0"  => $PREFIX_NAME."cs_n_0",
										$PREFIX_NAME."we_n_0"  => $PREFIX_NAME."we_n_0",
										$PREFIX_NAME."ref_n_0" => $PREFIX_NAME."ref_n_0",
										$PREFIX_NAME."cs_n_1"  => $PREFIX_NAME."cs_n_1",
										$PREFIX_NAME."we_n_1"  => $PREFIX_NAME."we_n_1",
										$PREFIX_NAME."ref_n_1" => $PREFIX_NAME."ref_n_1",
										$PREFIX_NAME."a_0" => $PREFIX_NAME."a_0",
										$PREFIX_NAME."ba_0" => $PREFIX_NAME."ba_0",
										$PREFIX_NAME."a_1" => $PREFIX_NAME."a_1",
										$PREFIX_NAME."ba_1" => $PREFIX_NAME."ba_1",
										#$PREFIX_NAME."dm" => $PREFIX_NAME."dm",
										$PREFIX_NAME."dm" => $PREFIX_NAME."dm[".($MEM_NUM_DEVICES - 1).":0]",
										$PREFIX_NAME."d" => $PREFIX_NAME."d",
									},
									
									inout_port_map	=>
									{
										#$PREFIX_NAME."qk" => $PREFIX_NAME."qk",
										#$PREFIX_NAME."qk" => $PREFIX_NAME."qk[".($NUMBER_DQS - 1).":0]",
									},
								}),
							);
						}
					} else {
						if ($ddio_memory_clocks eq "true") {
							$module->add_contents
							(
								e_blind_instance->new
								({
									name 		=> $gWRAPPER_NAME,            
									module 		=> $gWRAPPER_NAME."_wrapper",
									comment 	=> "---------------------------------------------------------------------\n
									SIO RLDRAM II Controller\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk => "clk",
										write_clk => "write_clk",
										addr_cmd_clk => "addr_cmd_clk",
										reset_clk_n => "reset_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										dqs_delay_ctrl => "dqs_delay_ctrl",
										local_write_req => $PREFIX_NAME."local_write_req",
										local_read_req => $PREFIX_NAME."local_read_req",
										local_addr => $PREFIX_NAME."local_addr",
										local_bank_addr => $PREFIX_NAME."local_bank_addr",
										local_wdata => $PREFIX_NAME."local_wdata",
										local_dm => $PREFIX_NAME."local_dm",
										local_refresh_req => $PREFIX_NAME."local_refresh_req",
										#$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld",
										$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld[".($MEM_NUM_DEVICES - 1).":0]",
										$PREFIX_NAME."q" => $PREFIX_NAME."q",
                                        $PREFIX_NAME."qk" => $PREFIX_NAME."qk[".($NUMBER_DQS - 1).":0]",
									},
					
									out_port_map	=>
									{
										capture_clk => $PREFIX_NAME."capture_clk",
										local_wdata_req => $PREFIX_NAME."local_wdata_req",
										local_rdata_valid => $PREFIX_NAME."local_rdata_valid",#[]",
										local_rdata => $PREFIX_NAME."local_rdata",
										local_init_done => $PREFIX_NAME."local_init_done",
										#$PREFIX_NAME."clk" => $PREFIX_NAME."clk",
										#$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n",
										$PREFIX_NAME."clk" => $PREFIX_NAME."clk[".($NUM_CLOCK_PAIRS - 1).":0]",
										$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n[".($NUM_CLOCK_PAIRS - 1).":0]",
										$PREFIX_NAME."cs_n_0"  => $PREFIX_NAME."cs_n_0",
										$PREFIX_NAME."we_n_0"  => $PREFIX_NAME."we_n_0",
										$PREFIX_NAME."ref_n_0" => $PREFIX_NAME."ref_n_0",
										$PREFIX_NAME."a_0" => $PREFIX_NAME."a_0",
										$PREFIX_NAME."ba_0" => $PREFIX_NAME."ba_0",
										#$PREFIX_NAME."dm" => $PREFIX_NAME."dm",
										$PREFIX_NAME."dm" => $PREFIX_NAME."dm[".($MEM_NUM_DEVICES - 1).":0]",
										$PREFIX_NAME."d" => $PREFIX_NAME."d",
									},
									
									inout_port_map	=>
									{
										#$PREFIX_NAME."qk" => $PREFIX_NAME."qk",
										#$PREFIX_NAME."qk" => $PREFIX_NAME."qk[".($NUMBER_DQS - 1).":0]",
									},
								}),
							);
						} else {
							$module->add_contents
							(
								e_blind_instance->new
								({
									name 		=> $gWRAPPER_NAME,            
									module 		=> $gWRAPPER_NAME."_wrapper",
									comment 	=> "---------------------------------------------------------------------\n
									SIO RLDRAM II Controller\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk => "clk",
										write_clk => "write_clk",
										addr_cmd_clk => "addr_cmd_clk",
										reset_clk_n => "reset_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										dqs_delay_ctrl => "dqs_delay_ctrl",
										local_write_req => $PREFIX_NAME."local_write_req",
										local_read_req => $PREFIX_NAME."local_read_req",
										local_addr => $PREFIX_NAME."local_addr",
										local_bank_addr => $PREFIX_NAME."local_bank_addr",
										local_wdata => $PREFIX_NAME."local_wdata",
										local_dm => $PREFIX_NAME."local_dm",
										local_refresh_req => $PREFIX_NAME."local_refresh_req",
										#$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld",
										$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld[".($MEM_NUM_DEVICES - 1).":0]",
										$PREFIX_NAME."q" => $PREFIX_NAME."q",
                                        $PREFIX_NAME."qk" => $PREFIX_NAME."qk[".($NUMBER_DQS - 1).":0]",
									},
					
									out_port_map	=>
									{
										capture_clk => $PREFIX_NAME."capture_clk",
										local_wdata_req => $PREFIX_NAME."local_wdata_req",
										local_rdata_valid => $PREFIX_NAME."local_rdata_valid",#[]",
										local_rdata => $PREFIX_NAME."local_rdata",
										local_init_done => $PREFIX_NAME."local_init_done",
										#$PREFIX_NAME."clk" => $PREFIX_NAME."clk",
										#$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n",
										#$PREFIX_NAME."clk" => $PREFIX_NAME."clk[".($NUM_CLOCK_PAIRS - 1).":0]",
										#$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n[".($NUM_CLOCK_PAIRS - 1).":0]",
										$PREFIX_NAME."cs_n_0"  => $PREFIX_NAME."cs_n_0",
										$PREFIX_NAME."we_n_0"  => $PREFIX_NAME."we_n_0",
										$PREFIX_NAME."ref_n_0" => $PREFIX_NAME."ref_n_0",
										$PREFIX_NAME."a_0" => $PREFIX_NAME."a_0",
										$PREFIX_NAME."ba_0" => $PREFIX_NAME."ba_0",
										#$PREFIX_NAME."dm" => $PREFIX_NAME."dm",
										$PREFIX_NAME."dm" => $PREFIX_NAME."dm[".($MEM_NUM_DEVICES - 1).":0]",
										$PREFIX_NAME."d" => $PREFIX_NAME."d",
									},
									
									inout_port_map	=>
									{
										#$PREFIX_NAME."qk" => $PREFIX_NAME."qk",
										#$PREFIX_NAME."qk" => $PREFIX_NAME."qk[".($NUMBER_DQS - 1).":0]",
									},
								}),
							);
						}
					}
				} else {
					if($num_addr_cmd_buses > 1) {
						if ($ddio_memory_clocks eq "true") {
							$module->add_contents
							(
								e_blind_instance->new
								({
									name 		=> $gWRAPPER_NAME,            
									module 		=> $gWRAPPER_NAME."_wrapper",
									comment 	=> "---------------------------------------------------------------------\n
									SIO RLDRAM II Controller\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk => "clk",
										write_clk => "write_clk",
										addr_cmd_clk => "addr_cmd_clk",
										reset_clk_n => "reset_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										dqs_delay_ctrl => "dqs_delay_ctrl",
										local_write_req => $PREFIX_NAME."local_write_req",
										local_read_req => $PREFIX_NAME."local_read_req",
										local_addr => $PREFIX_NAME."local_addr",
										local_bank_addr => $PREFIX_NAME."local_bank_addr",
										local_wdata => $PREFIX_NAME."local_wdata",
										#local_dm => $PREFIX_NAME."local_dm",
										local_refresh_req => $PREFIX_NAME."local_refresh_req",
										#$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld",
										$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld[".($MEM_NUM_DEVICES - 1).":0]",
										$PREFIX_NAME."q" => $PREFIX_NAME."q",
                                        $PREFIX_NAME."qk" => $PREFIX_NAME."qk[".($NUMBER_DQS - 1).":0]",
									},
					
									out_port_map	=>
									{
										capture_clk => $PREFIX_NAME."capture_clk",
										local_wdata_req => $PREFIX_NAME."local_wdata_req",
										local_rdata_valid => $PREFIX_NAME."local_rdata_valid",#[]",
										local_rdata => $PREFIX_NAME."local_rdata",
										local_init_done => $PREFIX_NAME."local_init_done",
										#$PREFIX_NAME."clk" => $PREFIX_NAME."clk",
										#$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n",
										$PREFIX_NAME."clk" => $PREFIX_NAME."clk[".($NUM_CLOCK_PAIRS - 1).":0]",
										$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n[".($NUM_CLOCK_PAIRS - 1).":0]",
										$PREFIX_NAME."cs_n_0"  => $PREFIX_NAME."cs_n_0",
										$PREFIX_NAME."we_n_0"  => $PREFIX_NAME."we_n_0",
										$PREFIX_NAME."ref_n_0" => $PREFIX_NAME."ref_n_0",
										$PREFIX_NAME."cs_n_1"  => $PREFIX_NAME."cs_n_1",
										$PREFIX_NAME."we_n_1"  => $PREFIX_NAME."we_n_1",
										$PREFIX_NAME."ref_n_1" => $PREFIX_NAME."ref_n_1",
										$PREFIX_NAME."a_0" => $PREFIX_NAME."a_0",
										$PREFIX_NAME."ba_0" => $PREFIX_NAME."ba_0",
										$PREFIX_NAME."a_1" => $PREFIX_NAME."a_1",
										$PREFIX_NAME."ba_1" => $PREFIX_NAME."ba_1",
										$PREFIX_NAME."d" => $PREFIX_NAME."d",
									},
									
									inout_port_map	=>
									{
										#$PREFIX_NAME."qk" => $PREFIX_NAME."qk",
										#$PREFIX_NAME."qk" => $PREFIX_NAME."qk[".($NUMBER_DQS - 1).":0]",
									},
								}),
							);
						} else {
							$module->add_contents
							(
								e_blind_instance->new
								({
									name 		=> $gWRAPPER_NAME,            
									module 		=> $gWRAPPER_NAME."_wrapper",
									comment 	=> "---------------------------------------------------------------------\n
									SIO RLDRAM II Controller\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk => "clk",
										write_clk => "write_clk",
										addr_cmd_clk => "addr_cmd_clk",
										reset_clk_n => "reset_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										dqs_delay_ctrl => "dqs_delay_ctrl",
										local_write_req => $PREFIX_NAME."local_write_req",
										local_read_req => $PREFIX_NAME."local_read_req",
										local_addr => $PREFIX_NAME."local_addr",
										local_bank_addr => $PREFIX_NAME."local_bank_addr",
										local_wdata => $PREFIX_NAME."local_wdata",
										#local_dm => $PREFIX_NAME."local_dm",
										local_refresh_req => $PREFIX_NAME."local_refresh_req",
										#$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld",
										$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld[".($MEM_NUM_DEVICES - 1).":0]",
										$PREFIX_NAME."q" => $PREFIX_NAME."q",
                                        $PREFIX_NAME."qk" => $PREFIX_NAME."qk[".($NUMBER_DQS - 1).":0]",
									},
					
									out_port_map	=>
									{
										capture_clk => $PREFIX_NAME."capture_clk",
										local_wdata_req => $PREFIX_NAME."local_wdata_req",
										local_rdata_valid => $PREFIX_NAME."local_rdata_valid",#[]",
										local_rdata => $PREFIX_NAME."local_rdata",
										local_init_done => $PREFIX_NAME."local_init_done",
										#$PREFIX_NAME."clk" => $PREFIX_NAME."clk",
										#$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n",
										#$PREFIX_NAME."clk" => $PREFIX_NAME."clk[".($NUM_CLOCK_PAIRS - 1).":0]",
										#$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n[".($NUM_CLOCK_PAIRS - 1).":0]",
										$PREFIX_NAME."cs_n_0"  => $PREFIX_NAME."cs_n_0",
										$PREFIX_NAME."we_n_0"  => $PREFIX_NAME."we_n_0",
										$PREFIX_NAME."ref_n_0" => $PREFIX_NAME."ref_n_0",
										$PREFIX_NAME."cs_n_1"  => $PREFIX_NAME."cs_n_1",
										$PREFIX_NAME."we_n_1"  => $PREFIX_NAME."we_n_1",
										$PREFIX_NAME."ref_n_1" => $PREFIX_NAME."ref_n_1",
										$PREFIX_NAME."a_0" => $PREFIX_NAME."a_0",
										$PREFIX_NAME."ba_0" => $PREFIX_NAME."ba_0",
										$PREFIX_NAME."a_1" => $PREFIX_NAME."a_1",
										$PREFIX_NAME."ba_1" => $PREFIX_NAME."ba_1",
										$PREFIX_NAME."d" => $PREFIX_NAME."d",
									},
									
									inout_port_map	=>
									{
										#$PREFIX_NAME."qk" => $PREFIX_NAME."qk",
										#$PREFIX_NAME."qk" => $PREFIX_NAME."qk[".($NUMBER_DQS - 1).":0]",
									},
								}),
							);
						}
					} else {
						if ($ddio_memory_clocks eq "true") {
							$module->add_contents
							(
								e_blind_instance->new
								({
									name 		=> $gWRAPPER_NAME,            
									module 		=> $gWRAPPER_NAME."_wrapper",
									comment 	=> "---------------------------------------------------------------------\n
									SIO RLDRAM II Controller\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk => "clk",
										write_clk => "write_clk",
										addr_cmd_clk => "addr_cmd_clk",
										reset_clk_n => "reset_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										dqs_delay_ctrl => "dqs_delay_ctrl",
										local_write_req => $PREFIX_NAME."local_write_req",
										local_read_req => $PREFIX_NAME."local_read_req",
										local_addr => $PREFIX_NAME."local_addr",
										local_bank_addr => $PREFIX_NAME."local_bank_addr",
										local_wdata => $PREFIX_NAME."local_wdata",
										#local_dm => $PREFIX_NAME."local_dm",
										local_refresh_req => $PREFIX_NAME."local_refresh_req",
										#$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld",
										$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld[".($MEM_NUM_DEVICES - 1).":0]",
										$PREFIX_NAME."q" => $PREFIX_NAME."q",
                                        $PREFIX_NAME."qk" => $PREFIX_NAME."qk[".($NUMBER_DQS - 1).":0]",
									},
					
									out_port_map	=>
									{
										capture_clk => $PREFIX_NAME."capture_clk",
										local_wdata_req => $PREFIX_NAME."local_wdata_req",
										local_rdata_valid => $PREFIX_NAME."local_rdata_valid",#[]",
										local_rdata => $PREFIX_NAME."local_rdata",
										local_init_done => $PREFIX_NAME."local_init_done",
										#$PREFIX_NAME."clk" => $PREFIX_NAME."clk",
										#$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n",
										$PREFIX_NAME."clk" => $PREFIX_NAME."clk[".($NUM_CLOCK_PAIRS - 1).":0]",
										$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n[".($NUM_CLOCK_PAIRS - 1).":0]",
										$PREFIX_NAME."cs_n_0"  => $PREFIX_NAME."cs_n_0",
										$PREFIX_NAME."we_n_0"  => $PREFIX_NAME."we_n_0",
										$PREFIX_NAME."ref_n_0" => $PREFIX_NAME."ref_n_0",
										$PREFIX_NAME."a_0" => $PREFIX_NAME."a_0",
										$PREFIX_NAME."ba_0" => $PREFIX_NAME."ba_0",
										$PREFIX_NAME."d" => $PREFIX_NAME."d",
									},
									
									inout_port_map	=>
									{
										#$PREFIX_NAME."qk" => $PREFIX_NAME."qk",
										#$PREFIX_NAME."qk" => $PREFIX_NAME."qk[".($NUMBER_DQS - 1).":0]",
									},
								}),
							);
						} else {
							$module->add_contents
							(
								e_blind_instance->new
								({
									name 		=> $gWRAPPER_NAME,            
									module 		=> $gWRAPPER_NAME."_wrapper",
									comment 	=> "---------------------------------------------------------------------\n
									SIO RLDRAM II Controller\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk => "clk",
										write_clk => "write_clk",
										addr_cmd_clk => "addr_cmd_clk",
										reset_clk_n => "reset_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										dqs_delay_ctrl => "dqs_delay_ctrl",
										local_write_req => $PREFIX_NAME."local_write_req",
										local_read_req => $PREFIX_NAME."local_read_req",
										local_addr => $PREFIX_NAME."local_addr",
										local_bank_addr => $PREFIX_NAME."local_bank_addr",
										local_wdata => $PREFIX_NAME."local_wdata",
										#local_dm => $PREFIX_NAME."local_dm",
										local_refresh_req => $PREFIX_NAME."local_refresh_req",
										#$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld",
										$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld[".($MEM_NUM_DEVICES - 1).":0]",
										$PREFIX_NAME."q" => $PREFIX_NAME."q",
                                        $PREFIX_NAME."qk" => $PREFIX_NAME."qk[".($NUMBER_DQS - 1).":0]",
									},
					
									out_port_map	=>
									{
										capture_clk => $PREFIX_NAME."capture_clk",
										local_wdata_req => $PREFIX_NAME."local_wdata_req",
										local_rdata_valid => $PREFIX_NAME."local_rdata_valid",#[]",
										local_rdata => $PREFIX_NAME."local_rdata",
										local_init_done => $PREFIX_NAME."local_init_done",
										#$PREFIX_NAME."clk" => $PREFIX_NAME."clk",
										#$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n",
										#$PREFIX_NAME."clk" => $PREFIX_NAME."clk[".($NUM_CLOCK_PAIRS - 1).":0]",
										#$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n[".($NUM_CLOCK_PAIRS - 1).":0]",
										$PREFIX_NAME."cs_n_0"  => $PREFIX_NAME."cs_n_0",
										$PREFIX_NAME."we_n_0"  => $PREFIX_NAME."we_n_0",
										$PREFIX_NAME."ref_n_0" => $PREFIX_NAME."ref_n_0",
										$PREFIX_NAME."a_0" => $PREFIX_NAME."a_0",
										$PREFIX_NAME."ba_0" => $PREFIX_NAME."ba_0",
										$PREFIX_NAME."d" => $PREFIX_NAME."d",
									},
									
									inout_port_map	=>
									{
										#$PREFIX_NAME."qk" => $PREFIX_NAME."qk",
										#$PREFIX_NAME."qk" => $PREFIX_NAME."qk[".($NUMBER_DQS - 1).":0]",
									},
								}),
							);
						}
					}
				}
			}
			else
			{
				if($enable_dm_pins eq "true") {
					if($num_addr_cmd_buses > 1) {
						if ($ddio_memory_clocks eq "true") {
							$module->add_contents
							(
								e_blind_instance->new
								({
									name 		=> $gWRAPPER_NAME,            
									module 		=> $gWRAPPER_NAME."_wrapper",
									comment 	=> "---------------------------------------------------------------------\n
									SIO RLDRAM II Controller\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk => "clk",
										write_clk => "write_clk",
										reset_clk_n => "reset_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										dqs_delay_ctrl => "dqs_delay_ctrl",
										local_write_req => $PREFIX_NAME."local_write_req",
										local_read_req => $PREFIX_NAME."local_read_req",
										local_addr => $PREFIX_NAME."local_addr",
										local_bank_addr => $PREFIX_NAME."local_bank_addr",
										local_wdata => $PREFIX_NAME."local_wdata",
										local_dm => $PREFIX_NAME."local_dm",
										local_refresh_req => $PREFIX_NAME."local_refresh_req",
										#$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld",
										$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld[".($MEM_NUM_DEVICES - 1).":0]",
										$PREFIX_NAME."q" => $PREFIX_NAME."q",
                                        $PREFIX_NAME."qk" => $PREFIX_NAME."qk[".($NUMBER_DQS - 1).":0]",
									},
					
									out_port_map	=>
									{
										capture_clk => $PREFIX_NAME."capture_clk",#[]",
										local_wdata_req => $PREFIX_NAME."local_wdata_req",
										local_rdata_valid => $PREFIX_NAME."local_rdata_valid",#[]",
										local_rdata => $PREFIX_NAME."local_rdata",
										local_init_done => $PREFIX_NAME."local_init_done",
										#$PREFIX_NAME."clk" => $PREFIX_NAME."clk",
										#$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n",
										$PREFIX_NAME."clk" => $PREFIX_NAME."clk[".($NUM_CLOCK_PAIRS - 1).":0]",
										$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n[".($NUM_CLOCK_PAIRS - 1).":0]",
										$PREFIX_NAME."cs_n_0"  => $PREFIX_NAME."cs_n_0",
										$PREFIX_NAME."we_n_0"  => $PREFIX_NAME."we_n_0",
										$PREFIX_NAME."ref_n_0" => $PREFIX_NAME."ref_n_0",
										$PREFIX_NAME."cs_n_1"  => $PREFIX_NAME."cs_n_1",
										$PREFIX_NAME."we_n_1"  => $PREFIX_NAME."we_n_1",
										$PREFIX_NAME."ref_n_1" => $PREFIX_NAME."ref_n_1",
										$PREFIX_NAME."a_0" => $PREFIX_NAME."a_0",
										$PREFIX_NAME."ba_0" => $PREFIX_NAME."ba_0",
										$PREFIX_NAME."a_1" => $PREFIX_NAME."a_1",
										$PREFIX_NAME."ba_1" => $PREFIX_NAME."ba_1",
										#$PREFIX_NAME."dm" => $PREFIX_NAME."dm",
										$PREFIX_NAME."dm" => $PREFIX_NAME."dm[".($MEM_NUM_DEVICES - 1).":0]",
										$PREFIX_NAME."d" => $PREFIX_NAME."d",
									},
									
									inout_port_map	=>
									{
										#$PREFIX_NAME."qk" => $PREFIX_NAME."qk",
										#$PREFIX_NAME."qk" => $PREFIX_NAME."qk[".($NUMBER_DQS - 1).":0]",
									},
								}),
							);
						} else {
							$module->add_contents
							(
								e_blind_instance->new
								({
									name 		=> $gWRAPPER_NAME,            
									module 		=> $gWRAPPER_NAME."_wrapper",
									comment 	=> "---------------------------------------------------------------------\n
									SIO RLDRAM II Controller\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk => "clk",
										write_clk => "write_clk",
										reset_clk_n => "reset_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										dqs_delay_ctrl => "dqs_delay_ctrl",
										local_write_req => $PREFIX_NAME."local_write_req",
										local_read_req => $PREFIX_NAME."local_read_req",
										local_addr => $PREFIX_NAME."local_addr",
										local_bank_addr => $PREFIX_NAME."local_bank_addr",
										local_wdata => $PREFIX_NAME."local_wdata",
										local_dm => $PREFIX_NAME."local_dm",
										local_refresh_req => $PREFIX_NAME."local_refresh_req",
										#$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld",
										$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld[".($MEM_NUM_DEVICES - 1).":0]",
										$PREFIX_NAME."q" => $PREFIX_NAME."q",
                                        $PREFIX_NAME."qk" => $PREFIX_NAME."qk[".($NUMBER_DQS - 1).":0]",
									},
					
									out_port_map	=>
									{
										capture_clk => $PREFIX_NAME."capture_clk",#[]",
										local_wdata_req => $PREFIX_NAME."local_wdata_req",
										local_rdata_valid => $PREFIX_NAME."local_rdata_valid",#[]",
										local_rdata => $PREFIX_NAME."local_rdata",
										local_init_done => $PREFIX_NAME."local_init_done",
										#$PREFIX_NAME."clk" => $PREFIX_NAME."clk",
										#$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n",
										#$PREFIX_NAME."clk" => $PREFIX_NAME."clk[".($NUM_CLOCK_PAIRS - 1).":0]",
										#$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n[".($NUM_CLOCK_PAIRS - 1).":0]",
										$PREFIX_NAME."cs_n_0"  => $PREFIX_NAME."cs_n_0",
										$PREFIX_NAME."we_n_0"  => $PREFIX_NAME."we_n_0",
										$PREFIX_NAME."ref_n_0" => $PREFIX_NAME."ref_n_0",
										$PREFIX_NAME."cs_n_1"  => $PREFIX_NAME."cs_n_1",
										$PREFIX_NAME."we_n_1"  => $PREFIX_NAME."we_n_1",
										$PREFIX_NAME."ref_n_1" => $PREFIX_NAME."ref_n_1",
										$PREFIX_NAME."a_0" => $PREFIX_NAME."a_0",
										$PREFIX_NAME."ba_0" => $PREFIX_NAME."ba_0",
										$PREFIX_NAME."a_1" => $PREFIX_NAME."a_1",
										$PREFIX_NAME."ba_1" => $PREFIX_NAME."ba_1",
										#$PREFIX_NAME."dm" => $PREFIX_NAME."dm",
										$PREFIX_NAME."dm" => $PREFIX_NAME."dm[".($MEM_NUM_DEVICES - 1).":0]",
										$PREFIX_NAME."d" => $PREFIX_NAME."d",
									},
									
									inout_port_map	=>
									{
										#$PREFIX_NAME."qk" => $PREFIX_NAME."qk",
										#$PREFIX_NAME."qk" => $PREFIX_NAME."qk[".($NUMBER_DQS - 1).":0]",
									},
								}),
							);
						}
					} else {
						if ($ddio_memory_clocks eq "true") {
							$module->add_contents
							(
								e_blind_instance->new
								({
									name 		=> $gWRAPPER_NAME,            
									module 		=> $gWRAPPER_NAME."_wrapper",
									comment 	=> "---------------------------------------------------------------------\n
									SIO RLDRAM II Controller\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk => "clk",
										write_clk => "write_clk",
										reset_clk_n => "reset_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										dqs_delay_ctrl => "dqs_delay_ctrl",
										local_write_req => $PREFIX_NAME."local_write_req",
										local_read_req => $PREFIX_NAME."local_read_req",
										local_addr => $PREFIX_NAME."local_addr",
										local_bank_addr => $PREFIX_NAME."local_bank_addr",
										local_wdata => $PREFIX_NAME."local_wdata",
										local_dm => $PREFIX_NAME."local_dm",
										local_refresh_req => $PREFIX_NAME."local_refresh_req",
										#$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld",
										$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld[".($MEM_NUM_DEVICES - 1).":0]",
										$PREFIX_NAME."q" => $PREFIX_NAME."q",
                                        $PREFIX_NAME."qk" => $PREFIX_NAME."qk[".($NUMBER_DQS - 1).":0]",
									},
					
									out_port_map	=>
									{
										capture_clk => $PREFIX_NAME."capture_clk",#[]",
										local_wdata_req => $PREFIX_NAME."local_wdata_req",
										local_rdata_valid => $PREFIX_NAME."local_rdata_valid",#[]",
										local_rdata => $PREFIX_NAME."local_rdata",
										local_init_done => $PREFIX_NAME."local_init_done",
										#$PREFIX_NAME."clk" => $PREFIX_NAME."clk",
										#$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n",
										$PREFIX_NAME."clk" => $PREFIX_NAME."clk[".($NUM_CLOCK_PAIRS - 1).":0]",
										$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n[".($NUM_CLOCK_PAIRS - 1).":0]",
										$PREFIX_NAME."cs_n_0"  => $PREFIX_NAME."cs_n_0",
										$PREFIX_NAME."we_n_0"  => $PREFIX_NAME."we_n_0",
										$PREFIX_NAME."ref_n_0" => $PREFIX_NAME."ref_n_0",
										$PREFIX_NAME."a_0" => $PREFIX_NAME."a_0",
										$PREFIX_NAME."ba_0" => $PREFIX_NAME."ba_0",
										#$PREFIX_NAME."dm" => $PREFIX_NAME."dm",
										$PREFIX_NAME."dm" => $PREFIX_NAME."dm[".($MEM_NUM_DEVICES - 1).":0]",
										$PREFIX_NAME."d" => $PREFIX_NAME."d",
									},
									
									inout_port_map	=>
									{
										#$PREFIX_NAME."qk" => $PREFIX_NAME."qk",
										#$PREFIX_NAME."qk" => $PREFIX_NAME."qk[".($NUMBER_DQS - 1).":0]",
									},
								}),
							);
						} else {
							$module->add_contents
							(
								e_blind_instance->new
								({
									name 		=> $gWRAPPER_NAME,            
									module 		=> $gWRAPPER_NAME."_wrapper",
									comment 	=> "---------------------------------------------------------------------\n
									SIO RLDRAM II Controller\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk => "clk",
										write_clk => "write_clk",
										reset_clk_n => "reset_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										dqs_delay_ctrl => "dqs_delay_ctrl",
										local_write_req => $PREFIX_NAME."local_write_req",
										local_read_req => $PREFIX_NAME."local_read_req",
										local_addr => $PREFIX_NAME."local_addr",
										local_bank_addr => $PREFIX_NAME."local_bank_addr",
										local_wdata => $PREFIX_NAME."local_wdata",
										local_dm => $PREFIX_NAME."local_dm",
										local_refresh_req => $PREFIX_NAME."local_refresh_req",
										#$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld",
										$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld[".($MEM_NUM_DEVICES - 1).":0]",
										$PREFIX_NAME."q" => $PREFIX_NAME."q",
                                        $PREFIX_NAME."qk" => $PREFIX_NAME."qk[".($NUMBER_DQS - 1).":0]",
									},
					
									out_port_map	=>
									{
										capture_clk => $PREFIX_NAME."capture_clk",#[]",
										local_wdata_req => $PREFIX_NAME."local_wdata_req",
										local_rdata_valid => $PREFIX_NAME."local_rdata_valid",#[]",
										local_rdata => $PREFIX_NAME."local_rdata",
										local_init_done => $PREFIX_NAME."local_init_done",
										#$PREFIX_NAME."clk" => $PREFIX_NAME."clk",
										#$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n",
										#$PREFIX_NAME."clk" => $PREFIX_NAME."clk[".($NUM_CLOCK_PAIRS - 1).":0]",
										#$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n[".($NUM_CLOCK_PAIRS - 1).":0]",
										$PREFIX_NAME."cs_n_0"  => $PREFIX_NAME."cs_n_0",
										$PREFIX_NAME."we_n_0"  => $PREFIX_NAME."we_n_0",
										$PREFIX_NAME."ref_n_0" => $PREFIX_NAME."ref_n_0",
										$PREFIX_NAME."a_0" => $PREFIX_NAME."a_0",
										$PREFIX_NAME."ba_0" => $PREFIX_NAME."ba_0",
										#$PREFIX_NAME."dm" => $PREFIX_NAME."dm",
										$PREFIX_NAME."dm" => $PREFIX_NAME."dm[".($MEM_NUM_DEVICES - 1).":0]",
										$PREFIX_NAME."d" => $PREFIX_NAME."d",
									},
									
									inout_port_map	=>
									{
										#$PREFIX_NAME."qk" => $PREFIX_NAME."qk",
										#$PREFIX_NAME."qk" => $PREFIX_NAME."qk[".($NUMBER_DQS - 1).":0]",
									},
								}),
							);
						}
					}
				} else {
					if($num_addr_cmd_buses > 1) {
						if ($ddio_memory_clocks eq "true") {
							$module->add_contents
							(
								e_blind_instance->new
								({
									name 		=> $gWRAPPER_NAME,            
									module 		=> $gWRAPPER_NAME."_wrapper",
									comment 	=> "---------------------------------------------------------------------\n
									SIO RLDRAM II Controller\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk => "clk",
										write_clk => "write_clk",
										reset_clk_n => "reset_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										dqs_delay_ctrl => "dqs_delay_ctrl",
										local_write_req => $PREFIX_NAME."local_write_req",
										local_read_req => $PREFIX_NAME."local_read_req",
										local_addr => $PREFIX_NAME."local_addr",
										local_bank_addr => $PREFIX_NAME."local_bank_addr",
										local_wdata => $PREFIX_NAME."local_wdata",
										#local_dm => $PREFIX_NAME."local_dm",
										local_refresh_req => $PREFIX_NAME."local_refresh_req",
										#$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld",
										$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld[".($MEM_NUM_DEVICES - 1).":0]",
										$PREFIX_NAME."q" => $PREFIX_NAME."q",
                                        $PREFIX_NAME."qk" => $PREFIX_NAME."qk[".($NUMBER_DQS - 1).":0]",
									},
					
									out_port_map	=>
									{
										capture_clk => $PREFIX_NAME."capture_clk",#[]",
										local_wdata_req => $PREFIX_NAME."local_wdata_req",
										local_rdata_valid => $PREFIX_NAME."local_rdata_valid",#[]",
										local_rdata => $PREFIX_NAME."local_rdata",
										local_init_done => $PREFIX_NAME."local_init_done",
										#$PREFIX_NAME."clk" => $PREFIX_NAME."clk",
										#$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n",
										$PREFIX_NAME."clk" => $PREFIX_NAME."clk[".($NUM_CLOCK_PAIRS - 1).":0]",
										$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n[".($NUM_CLOCK_PAIRS - 1).":0]",
										$PREFIX_NAME."cs_n_0"  => $PREFIX_NAME."cs_n_0",
										$PREFIX_NAME."we_n_0"  => $PREFIX_NAME."we_n_0",
										$PREFIX_NAME."ref_n_0" => $PREFIX_NAME."ref_n_0",
										$PREFIX_NAME."cs_n_1"  => $PREFIX_NAME."cs_n_1",
										$PREFIX_NAME."we_n_1"  => $PREFIX_NAME."we_n_1",
										$PREFIX_NAME."ref_n_1" => $PREFIX_NAME."ref_n_1",
										$PREFIX_NAME."a_0" => $PREFIX_NAME."a_0",
										$PREFIX_NAME."ba_0" => $PREFIX_NAME."ba_0",
										$PREFIX_NAME."a_1" => $PREFIX_NAME."a_1",
										$PREFIX_NAME."ba_1" => $PREFIX_NAME."ba_1",
										$PREFIX_NAME."d" => $PREFIX_NAME."d",
									},
									
									inout_port_map	=>
									{
										#$PREFIX_NAME."qk" => $PREFIX_NAME."qk",
										#$PREFIX_NAME."qk" => $PREFIX_NAME."qk[".($NUMBER_DQS - 1).":0]",
									},
								}),
							);
						} else {
							$module->add_contents
							(
								e_blind_instance->new
								({
									name 		=> $gWRAPPER_NAME,            
									module 		=> $gWRAPPER_NAME."_wrapper",
									comment 	=> "---------------------------------------------------------------------\n
									SIO RLDRAM II Controller\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk => "clk",
										write_clk => "write_clk",
										reset_clk_n => "reset_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										dqs_delay_ctrl => "dqs_delay_ctrl",
										local_write_req => $PREFIX_NAME."local_write_req",
										local_read_req => $PREFIX_NAME."local_read_req",
										local_addr => $PREFIX_NAME."local_addr",
										local_bank_addr => $PREFIX_NAME."local_bank_addr",
										local_wdata => $PREFIX_NAME."local_wdata",
										#local_dm => $PREFIX_NAME."local_dm",
										local_refresh_req => $PREFIX_NAME."local_refresh_req",
										#$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld",
										$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld[".($MEM_NUM_DEVICES - 1).":0]",
										$PREFIX_NAME."q" => $PREFIX_NAME."q",
                                        $PREFIX_NAME."qk" => $PREFIX_NAME."qk[".($NUMBER_DQS - 1).":0]",
									},
					
									out_port_map	=>
									{
										capture_clk => $PREFIX_NAME."capture_clk",#[]",
										local_wdata_req => $PREFIX_NAME."local_wdata_req",
										local_rdata_valid => $PREFIX_NAME."local_rdata_valid",#[]",
										local_rdata => $PREFIX_NAME."local_rdata",
										local_init_done => $PREFIX_NAME."local_init_done",
										#$PREFIX_NAME."clk" => $PREFIX_NAME."clk",
										#$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n",
										#$PREFIX_NAME."clk" => $PREFIX_NAME."clk[".($NUM_CLOCK_PAIRS - 1).":0]",
										#$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n[".($NUM_CLOCK_PAIRS - 1).":0]",
										$PREFIX_NAME."cs_n_0"  => $PREFIX_NAME."cs_n_0",
										$PREFIX_NAME."we_n_0"  => $PREFIX_NAME."we_n_0",
										$PREFIX_NAME."ref_n_0" => $PREFIX_NAME."ref_n_0",
										$PREFIX_NAME."cs_n_1"  => $PREFIX_NAME."cs_n_1",
										$PREFIX_NAME."we_n_1"  => $PREFIX_NAME."we_n_1",
										$PREFIX_NAME."ref_n_1" => $PREFIX_NAME."ref_n_1",
										$PREFIX_NAME."a_0" => $PREFIX_NAME."a_0",
										$PREFIX_NAME."ba_0" => $PREFIX_NAME."ba_0",
										$PREFIX_NAME."a_1" => $PREFIX_NAME."a_1",
										$PREFIX_NAME."ba_1" => $PREFIX_NAME."ba_1",
										$PREFIX_NAME."d" => $PREFIX_NAME."d",
									},
									
									inout_port_map	=>
									{
										#$PREFIX_NAME."qk" => $PREFIX_NAME."qk",
										#$PREFIX_NAME."qk" => $PREFIX_NAME."qk[".($NUMBER_DQS - 1).":0]",
									},
								}),
							);
						}
					} else {
						if ($ddio_memory_clocks eq "true") {
							$module->add_contents
							(
								e_blind_instance->new
								({
									name 		=> $gWRAPPER_NAME,            
									module 		=> $gWRAPPER_NAME."_wrapper",
									comment 	=> "---------------------------------------------------------------------\n
									SIO RLDRAM II Controller\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk => "clk",
										write_clk => "write_clk",
										reset_clk_n => "reset_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										dqs_delay_ctrl => "dqs_delay_ctrl",
										local_write_req => $PREFIX_NAME."local_write_req",
										local_read_req => $PREFIX_NAME."local_read_req",
										local_addr => $PREFIX_NAME."local_addr",
										local_bank_addr => $PREFIX_NAME."local_bank_addr",
										local_wdata => $PREFIX_NAME."local_wdata",
										#local_dm => $PREFIX_NAME."local_dm",
										local_refresh_req => $PREFIX_NAME."local_refresh_req",
										#$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld",
										$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld[".($MEM_NUM_DEVICES - 1).":0]",
										$PREFIX_NAME."q" => $PREFIX_NAME."q",
                                        $PREFIX_NAME."qk" => $PREFIX_NAME."qk[".($NUMBER_DQS - 1).":0]",
									},
					
									out_port_map	=>
									{
										capture_clk => $PREFIX_NAME."capture_clk",#[]",
										local_wdata_req => $PREFIX_NAME."local_wdata_req",
										local_rdata_valid => $PREFIX_NAME."local_rdata_valid",#[]",
										local_rdata => $PREFIX_NAME."local_rdata",
										local_init_done => $PREFIX_NAME."local_init_done",
										#$PREFIX_NAME."clk" => $PREFIX_NAME."clk",
										#$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n",
										$PREFIX_NAME."clk" => $PREFIX_NAME."clk[".($NUM_CLOCK_PAIRS - 1).":0]",
										$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n[".($NUM_CLOCK_PAIRS - 1).":0]",
										$PREFIX_NAME."cs_n_0"  => $PREFIX_NAME."cs_n_0",
										$PREFIX_NAME."we_n_0"  => $PREFIX_NAME."we_n_0",
										$PREFIX_NAME."ref_n_0" => $PREFIX_NAME."ref_n_0",
										$PREFIX_NAME."a_0" => $PREFIX_NAME."a_0",
										$PREFIX_NAME."ba_0" => $PREFIX_NAME."ba_0",
										$PREFIX_NAME."d" => $PREFIX_NAME."d",
									},
									
									inout_port_map	=>
									{
										#$PREFIX_NAME."qk" => $PREFIX_NAME."qk",
										#$PREFIX_NAME."qk" => $PREFIX_NAME."qk[".($NUMBER_DQS - 1).":0]",
									},
								}),
							);
						} else {
							$module->add_contents
							(
								e_blind_instance->new
								({
									name 		=> $gWRAPPER_NAME,            
									module 		=> $gWRAPPER_NAME."_wrapper",
									comment 	=> "---------------------------------------------------------------------\n
									SIO RLDRAM II Controller\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk => "clk",
										write_clk => "write_clk",
										reset_clk_n => "reset_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										dqs_delay_ctrl => "dqs_delay_ctrl",
										local_write_req => $PREFIX_NAME."local_write_req",
										local_read_req => $PREFIX_NAME."local_read_req",
										local_addr => $PREFIX_NAME."local_addr",
										local_bank_addr => $PREFIX_NAME."local_bank_addr",
										local_wdata => $PREFIX_NAME."local_wdata",
										#local_dm => $PREFIX_NAME."local_dm",
										local_refresh_req => $PREFIX_NAME."local_refresh_req",
										#$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld",
										$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld[".($MEM_NUM_DEVICES - 1).":0]",
										$PREFIX_NAME."q" => $PREFIX_NAME."q",
                                        $PREFIX_NAME."qk" => $PREFIX_NAME."qk[".($NUMBER_DQS - 1).":0]",
									},
					
									out_port_map	=>
									{
										capture_clk => $PREFIX_NAME."capture_clk",#[]",
										local_wdata_req => $PREFIX_NAME."local_wdata_req",
										local_rdata_valid => $PREFIX_NAME."local_rdata_valid",#[]",
										local_rdata => $PREFIX_NAME."local_rdata",
										local_init_done => $PREFIX_NAME."local_init_done",
										#$PREFIX_NAME."clk" => $PREFIX_NAME."clk",
										#$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n",
										#$PREFIX_NAME."clk" => $PREFIX_NAME."clk[".($NUM_CLOCK_PAIRS - 1).":0]",
										#$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n[".($NUM_CLOCK_PAIRS - 1).":0]",
										$PREFIX_NAME."cs_n_0"  => $PREFIX_NAME."cs_n_0",
										$PREFIX_NAME."we_n_0"  => $PREFIX_NAME."we_n_0",
										$PREFIX_NAME."ref_n_0" => $PREFIX_NAME."ref_n_0",
										$PREFIX_NAME."a_0" => $PREFIX_NAME."a_0",
										$PREFIX_NAME."ba_0" => $PREFIX_NAME."ba_0",
										$PREFIX_NAME."d" => $PREFIX_NAME."d",
									},
									
									inout_port_map	=>
									{
										#$PREFIX_NAME."qk" => $PREFIX_NAME."qk",
										#$PREFIX_NAME."qk" => $PREFIX_NAME."qk[".($NUMBER_DQS - 1).":0]",
									},
								}),
							);
						}
					}
				}
			}
		}
		else {
			if($enable_addr_cmd_clk eq "true") {
				if($enable_dm_pins eq "true") {
					if($num_addr_cmd_buses > 1) {
						if ($ddio_memory_clocks eq "true") {
							$module->add_contents
							(
								e_blind_instance->new
								({
									name 		=> $gWRAPPER_NAME,            
									module 		=> $gWRAPPER_NAME."_wrapper",
									comment 	=> "---------------------------------------------------------------------\n
									SIO RLDRAM II Controller\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk => "clk",
										write_clk => "write_clk",
										addr_cmd_clk => "addr_cmd_clk",
										non_dqs_capture_clk => "read_clk",#$FEDBACK_CLOCK_NAME,
										reset_clk_n => "reset_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										local_write_req => $PREFIX_NAME."local_write_req",
										local_read_req => $PREFIX_NAME."local_read_req",
										local_addr => $PREFIX_NAME."local_addr",
										local_bank_addr => $PREFIX_NAME."local_bank_addr",
										local_wdata => $PREFIX_NAME."local_wdata",
										local_dm => $PREFIX_NAME."local_dm",
										local_refresh_req => $PREFIX_NAME."local_refresh_req",
										#$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld",
										$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld[".($MEM_NUM_DEVICES - 1).":0]",
										$PREFIX_NAME."q" => $PREFIX_NAME."q",
									},
					
									out_port_map	=>
									{
										local_wdata_req => $PREFIX_NAME."local_wdata_req",
										local_rdata_valid => $PREFIX_NAME."local_rdata_valid",#[]",
										local_rdata => $PREFIX_NAME."local_rdata",
										local_init_done => $PREFIX_NAME."local_init_done",
										#$PREFIX_NAME."clk" => $PREFIX_NAME."clk",
										#$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n",
										$PREFIX_NAME."clk" => $PREFIX_NAME."clk[".($NUM_CLOCK_PAIRS - 1).":0]",
										$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n[".($NUM_CLOCK_PAIRS - 1).":0]",
										$PREFIX_NAME."cs_n_0"  => $PREFIX_NAME."cs_n_0",
										$PREFIX_NAME."we_n_0"  => $PREFIX_NAME."we_n_0",
										$PREFIX_NAME."ref_n_0" => $PREFIX_NAME."ref_n_0",
										$PREFIX_NAME."cs_n_1"  => $PREFIX_NAME."cs_n_1",
										$PREFIX_NAME."we_n_1"  => $PREFIX_NAME."we_n_1",
										$PREFIX_NAME."ref_n_1" => $PREFIX_NAME."ref_n_1",
										$PREFIX_NAME."a_0" => $PREFIX_NAME."a_0",
										$PREFIX_NAME."ba_0" => $PREFIX_NAME."ba_0",
										$PREFIX_NAME."a_1" => $PREFIX_NAME."a_1",
										$PREFIX_NAME."ba_1" => $PREFIX_NAME."ba_1",
										#$PREFIX_NAME."dm" => $PREFIX_NAME."dm",
										$PREFIX_NAME."dm" => $PREFIX_NAME."dm[".($MEM_NUM_DEVICES - 1).":0]",
										$PREFIX_NAME."d" => $PREFIX_NAME."d",
									},
								}),
							);
						} else {
							$module->add_contents
							(
								e_blind_instance->new
								({
									name 		=> $gWRAPPER_NAME,            
									module 		=> $gWRAPPER_NAME."_wrapper",
									comment 	=> "---------------------------------------------------------------------\n
									SIO RLDRAM II Controller\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk => "clk",
										write_clk => "write_clk",
										addr_cmd_clk => "addr_cmd_clk",
										non_dqs_capture_clk => "read_clk",#$FEDBACK_CLOCK_NAME,
										reset_clk_n => "reset_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										local_write_req => $PREFIX_NAME."local_write_req",
										local_read_req => $PREFIX_NAME."local_read_req",
										local_addr => $PREFIX_NAME."local_addr",
										local_bank_addr => $PREFIX_NAME."local_bank_addr",
										local_wdata => $PREFIX_NAME."local_wdata",
										local_dm => $PREFIX_NAME."local_dm",
										local_refresh_req => $PREFIX_NAME."local_refresh_req",
										#$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld",
										$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld[".($MEM_NUM_DEVICES - 1).":0]",
										$PREFIX_NAME."q" => $PREFIX_NAME."q",
									},
					
									out_port_map	=>
									{
										local_wdata_req => $PREFIX_NAME."local_wdata_req",
										local_rdata_valid => $PREFIX_NAME."local_rdata_valid",#[]",
										local_rdata => $PREFIX_NAME."local_rdata",
										local_init_done => $PREFIX_NAME."local_init_done",
										#$PREFIX_NAME."clk" => $PREFIX_NAME."clk",
										#$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n",
										#$PREFIX_NAME."clk" => $PREFIX_NAME."clk[".($NUM_CLOCK_PAIRS - 1).":0]",
										#$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n[".($NUM_CLOCK_PAIRS - 1).":0]",
										$PREFIX_NAME."cs_n_0"  => $PREFIX_NAME."cs_n_0",
										$PREFIX_NAME."we_n_0"  => $PREFIX_NAME."we_n_0",
										$PREFIX_NAME."ref_n_0" => $PREFIX_NAME."ref_n_0",
										$PREFIX_NAME."cs_n_1"  => $PREFIX_NAME."cs_n_1",
										$PREFIX_NAME."we_n_1"  => $PREFIX_NAME."we_n_1",
										$PREFIX_NAME."ref_n_1" => $PREFIX_NAME."ref_n_1",
										$PREFIX_NAME."a_0" => $PREFIX_NAME."a_0",
										$PREFIX_NAME."ba_0" => $PREFIX_NAME."ba_0",
										$PREFIX_NAME."a_1" => $PREFIX_NAME."a_1",
										$PREFIX_NAME."ba_1" => $PREFIX_NAME."ba_1",
										#$PREFIX_NAME."dm" => $PREFIX_NAME."dm",
										$PREFIX_NAME."dm" => $PREFIX_NAME."dm[".($MEM_NUM_DEVICES - 1).":0]",
										$PREFIX_NAME."d" => $PREFIX_NAME."d",
									},
								}),
							);
						}
					} else {
						if ($ddio_memory_clocks eq "true") {
							$module->add_contents
							(
								e_blind_instance->new
								({
									name 		=> $gWRAPPER_NAME,            
									module 		=> $gWRAPPER_NAME."_wrapper",
									comment 	=> "---------------------------------------------------------------------\n
									SIO RLDRAM II Controller\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk => "clk",
										write_clk => "write_clk",
										addr_cmd_clk => "addr_cmd_clk",
										non_dqs_capture_clk => "read_clk",#$FEDBACK_CLOCK_NAME,
										reset_clk_n => "reset_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										local_write_req => $PREFIX_NAME."local_write_req",
										local_read_req => $PREFIX_NAME."local_read_req",
										local_addr => $PREFIX_NAME."local_addr",
										local_bank_addr => $PREFIX_NAME."local_bank_addr",
										local_wdata => $PREFIX_NAME."local_wdata",
										local_dm => $PREFIX_NAME."local_dm",
										local_refresh_req => $PREFIX_NAME."local_refresh_req",
										#$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld",
										$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld[".($MEM_NUM_DEVICES - 1).":0]",
										$PREFIX_NAME."q" => $PREFIX_NAME."q",
									},
					
									out_port_map	=>
									{
										local_wdata_req => $PREFIX_NAME."local_wdata_req",
										local_rdata_valid => $PREFIX_NAME."local_rdata_valid",#[]",
										local_rdata => $PREFIX_NAME."local_rdata",
										local_init_done => $PREFIX_NAME."local_init_done",
										#$PREFIX_NAME."clk" => $PREFIX_NAME."clk",
										#$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n",
										$PREFIX_NAME."clk" => $PREFIX_NAME."clk[".($NUM_CLOCK_PAIRS - 1).":0]",
										$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n[".($NUM_CLOCK_PAIRS - 1).":0]",
										$PREFIX_NAME."cs_n_0"  => $PREFIX_NAME."cs_n_0",
										$PREFIX_NAME."we_n_0"  => $PREFIX_NAME."we_n_0",
										$PREFIX_NAME."ref_n_0" => $PREFIX_NAME."ref_n_0",
										$PREFIX_NAME."a_0" => $PREFIX_NAME."a_0",
										$PREFIX_NAME."ba_0" => $PREFIX_NAME."ba_0",
										#$PREFIX_NAME."dm" => $PREFIX_NAME."dm",
										$PREFIX_NAME."dm" => $PREFIX_NAME."dm[".($MEM_NUM_DEVICES - 1).":0]",
										$PREFIX_NAME."d" => $PREFIX_NAME."d",
									},
								}),
							);
						} else {
							$module->add_contents
							(
								e_blind_instance->new
								({
									name 		=> $gWRAPPER_NAME,            
									module 		=> $gWRAPPER_NAME."_wrapper",
									comment 	=> "---------------------------------------------------------------------\n
									SIO RLDRAM II Controller\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk => "clk",
										write_clk => "write_clk",
										addr_cmd_clk => "addr_cmd_clk",
										non_dqs_capture_clk => "read_clk",#$FEDBACK_CLOCK_NAME,
										reset_clk_n => "reset_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										local_write_req => $PREFIX_NAME."local_write_req",
										local_read_req => $PREFIX_NAME."local_read_req",
										local_addr => $PREFIX_NAME."local_addr",
										local_bank_addr => $PREFIX_NAME."local_bank_addr",
										local_wdata => $PREFIX_NAME."local_wdata",
										local_dm => $PREFIX_NAME."local_dm",
										local_refresh_req => $PREFIX_NAME."local_refresh_req",
										#$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld",
										$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld[".($MEM_NUM_DEVICES - 1).":0]",
										$PREFIX_NAME."q" => $PREFIX_NAME."q",
									},
					
									out_port_map	=>
									{
										local_wdata_req => $PREFIX_NAME."local_wdata_req",
										local_rdata_valid => $PREFIX_NAME."local_rdata_valid",#[]",
										local_rdata => $PREFIX_NAME."local_rdata",
										local_init_done => $PREFIX_NAME."local_init_done",
										#$PREFIX_NAME."clk" => $PREFIX_NAME."clk",
										#$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n",
										#$PREFIX_NAME."clk" => $PREFIX_NAME."clk[".($NUM_CLOCK_PAIRS - 1).":0]",
										#$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n[".($NUM_CLOCK_PAIRS - 1).":0]",
										$PREFIX_NAME."cs_n_0"  => $PREFIX_NAME."cs_n_0",
										$PREFIX_NAME."we_n_0"  => $PREFIX_NAME."we_n_0",
										$PREFIX_NAME."ref_n_0" => $PREFIX_NAME."ref_n_0",
										$PREFIX_NAME."a_0" => $PREFIX_NAME."a_0",
										$PREFIX_NAME."ba_0" => $PREFIX_NAME."ba_0",
										#$PREFIX_NAME."dm" => $PREFIX_NAME."dm",
										$PREFIX_NAME."dm" => $PREFIX_NAME."dm[".($MEM_NUM_DEVICES - 1).":0]",
										$PREFIX_NAME."d" => $PREFIX_NAME."d",
									},
								}),
							);
						}
					}
				} else {
					if($num_addr_cmd_buses > 1) {
						if ($ddio_memory_clocks eq "true") {
							$module->add_contents
							(
								e_blind_instance->new
								({
									name 		=> $gWRAPPER_NAME,            
									module 		=> $gWRAPPER_NAME."_wrapper",
									comment 	=> "---------------------------------------------------------------------\n
									SIO RLDRAM II Controller\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk => "clk",
										write_clk => "write_clk",
										addr_cmd_clk => "addr_cmd_clk",
										non_dqs_capture_clk => "read_clk",#$FEDBACK_CLOCK_NAME,
										reset_clk_n => "reset_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										local_write_req => $PREFIX_NAME."local_write_req",
										local_read_req => $PREFIX_NAME."local_read_req",
										local_addr => $PREFIX_NAME."local_addr",
										local_bank_addr => $PREFIX_NAME."local_bank_addr",
										local_wdata => $PREFIX_NAME."local_wdata",
										#local_dm => $PREFIX_NAME."local_dm",
										local_refresh_req => $PREFIX_NAME."local_refresh_req",
										#$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld",
										$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld[".($MEM_NUM_DEVICES - 1).":0]",
										$PREFIX_NAME."q" => $PREFIX_NAME."q",
									},
					
									out_port_map	=>
									{
										local_wdata_req => $PREFIX_NAME."local_wdata_req",
										local_rdata_valid => $PREFIX_NAME."local_rdata_valid",#[]",
										local_rdata => $PREFIX_NAME."local_rdata",
										local_init_done => $PREFIX_NAME."local_init_done",
										#$PREFIX_NAME."clk" => $PREFIX_NAME."clk",
										#$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n",
										$PREFIX_NAME."clk" => $PREFIX_NAME."clk[".($NUM_CLOCK_PAIRS - 1).":0]",
										$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n[".($NUM_CLOCK_PAIRS - 1).":0]",
										$PREFIX_NAME."cs_n_0"  => $PREFIX_NAME."cs_n_0",
										$PREFIX_NAME."we_n_0"  => $PREFIX_NAME."we_n_0",
										$PREFIX_NAME."ref_n_0" => $PREFIX_NAME."ref_n_0",
										$PREFIX_NAME."cs_n_1"  => $PREFIX_NAME."cs_n_1",
										$PREFIX_NAME."we_n_1"  => $PREFIX_NAME."we_n_1",
										$PREFIX_NAME."ref_n_1" => $PREFIX_NAME."ref_n_1",
										$PREFIX_NAME."a_0" => $PREFIX_NAME."a_0",
										$PREFIX_NAME."ba_0" => $PREFIX_NAME."ba_0",
										$PREFIX_NAME."a_1" => $PREFIX_NAME."a_1",
										$PREFIX_NAME."ba_1" => $PREFIX_NAME."ba_1",
										$PREFIX_NAME."d" => $PREFIX_NAME."d",
									},
								}),
							);
						} else {
							$module->add_contents
							(
								e_blind_instance->new
								({
									name 		=> $gWRAPPER_NAME,            
									module 		=> $gWRAPPER_NAME."_wrapper",
									comment 	=> "---------------------------------------------------------------------\n
									SIO RLDRAM II Controller\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk => "clk",
										write_clk => "write_clk",
										addr_cmd_clk => "addr_cmd_clk",
										non_dqs_capture_clk => "read_clk",#$FEDBACK_CLOCK_NAME,
										reset_clk_n => "reset_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										local_write_req => $PREFIX_NAME."local_write_req",
										local_read_req => $PREFIX_NAME."local_read_req",
										local_addr => $PREFIX_NAME."local_addr",
										local_bank_addr => $PREFIX_NAME."local_bank_addr",
										local_wdata => $PREFIX_NAME."local_wdata",
										#local_dm => $PREFIX_NAME."local_dm",
										local_refresh_req => $PREFIX_NAME."local_refresh_req",
										#$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld",
										$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld[".($MEM_NUM_DEVICES - 1).":0]",
										$PREFIX_NAME."q" => $PREFIX_NAME."q",
									},
					
									out_port_map	=>
									{
										local_wdata_req => $PREFIX_NAME."local_wdata_req",
										local_rdata_valid => $PREFIX_NAME."local_rdata_valid",#[]",
										local_rdata => $PREFIX_NAME."local_rdata",
										local_init_done => $PREFIX_NAME."local_init_done",
										#$PREFIX_NAME."clk" => $PREFIX_NAME."clk",
										#$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n",
										#$PREFIX_NAME."clk" => $PREFIX_NAME."clk[".($NUM_CLOCK_PAIRS - 1).":0]",
										#$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n[".($NUM_CLOCK_PAIRS - 1).":0]",
										$PREFIX_NAME."cs_n_0"  => $PREFIX_NAME."cs_n_0",
										$PREFIX_NAME."we_n_0"  => $PREFIX_NAME."we_n_0",
										$PREFIX_NAME."ref_n_0" => $PREFIX_NAME."ref_n_0",
										$PREFIX_NAME."cs_n_1"  => $PREFIX_NAME."cs_n_1",
										$PREFIX_NAME."we_n_1"  => $PREFIX_NAME."we_n_1",
										$PREFIX_NAME."ref_n_1" => $PREFIX_NAME."ref_n_1",
										$PREFIX_NAME."a_0" => $PREFIX_NAME."a_0",
										$PREFIX_NAME."ba_0" => $PREFIX_NAME."ba_0",
										$PREFIX_NAME."a_1" => $PREFIX_NAME."a_1",
										$PREFIX_NAME."ba_1" => $PREFIX_NAME."ba_1",
										$PREFIX_NAME."d" => $PREFIX_NAME."d",
									},
								}),
							);
						}
					} else {
						if ($ddio_memory_clocks eq "true") {
							$module->add_contents
							(
								e_blind_instance->new
								({
									name 		=> $gWRAPPER_NAME,            
									module 		=> $gWRAPPER_NAME."_wrapper",
									comment 	=> "---------------------------------------------------------------------\n
									SIO RLDRAM II Controller\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk => "clk",
										write_clk => "write_clk",
										addr_cmd_clk => "addr_cmd_clk",
										non_dqs_capture_clk => "read_clk",#$FEDBACK_CLOCK_NAME,
										reset_clk_n => "reset_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										local_write_req => $PREFIX_NAME."local_write_req",
										local_read_req => $PREFIX_NAME."local_read_req",
										local_addr => $PREFIX_NAME."local_addr",
										local_bank_addr => $PREFIX_NAME."local_bank_addr",
										local_wdata => $PREFIX_NAME."local_wdata",
										#local_dm => $PREFIX_NAME."local_dm",
										local_refresh_req => $PREFIX_NAME."local_refresh_req",
										#$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld",
										$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld[".($MEM_NUM_DEVICES - 1).":0]",
										$PREFIX_NAME."q" => $PREFIX_NAME."q",
									},
					
									out_port_map	=>
									{
										local_wdata_req => $PREFIX_NAME."local_wdata_req",
										local_rdata_valid => $PREFIX_NAME."local_rdata_valid",#[]",
										local_rdata => $PREFIX_NAME."local_rdata",
										local_init_done => $PREFIX_NAME."local_init_done",
										#$PREFIX_NAME."clk" => $PREFIX_NAME."clk",
										#$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n",
										$PREFIX_NAME."clk" => $PREFIX_NAME."clk[".($NUM_CLOCK_PAIRS - 1).":0]",
										$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n[".($NUM_CLOCK_PAIRS - 1).":0]",
										$PREFIX_NAME."cs_n_0"  => $PREFIX_NAME."cs_n_0",
										$PREFIX_NAME."we_n_0"  => $PREFIX_NAME."we_n_0",
										$PREFIX_NAME."ref_n_0" => $PREFIX_NAME."ref_n_0",
										$PREFIX_NAME."a_0" => $PREFIX_NAME."a_0",
										$PREFIX_NAME."ba_0" => $PREFIX_NAME."ba_0",
										$PREFIX_NAME."d" => $PREFIX_NAME."d",
									},
								}),
							);
						} else {
							$module->add_contents
							(
								e_blind_instance->new
								({
									name 		=> $gWRAPPER_NAME,            
									module 		=> $gWRAPPER_NAME."_wrapper",
									comment 	=> "---------------------------------------------------------------------\n
									SIO RLDRAM II Controller\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk => "clk",
										write_clk => "write_clk",
										addr_cmd_clk => "addr_cmd_clk",
										non_dqs_capture_clk => "read_clk",#$FEDBACK_CLOCK_NAME,
										reset_clk_n => "reset_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										local_write_req => $PREFIX_NAME."local_write_req",
										local_read_req => $PREFIX_NAME."local_read_req",
										local_addr => $PREFIX_NAME."local_addr",
										local_bank_addr => $PREFIX_NAME."local_bank_addr",
										local_wdata => $PREFIX_NAME."local_wdata",
										#local_dm => $PREFIX_NAME."local_dm",
										local_refresh_req => $PREFIX_NAME."local_refresh_req",
										#$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld",
										$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld[".($MEM_NUM_DEVICES - 1).":0]",
										$PREFIX_NAME."q" => $PREFIX_NAME."q",
									},
					
									out_port_map	=>
									{
										local_wdata_req => $PREFIX_NAME."local_wdata_req",
										local_rdata_valid => $PREFIX_NAME."local_rdata_valid",#[]",
										local_rdata => $PREFIX_NAME."local_rdata",
										local_init_done => $PREFIX_NAME."local_init_done",
										#$PREFIX_NAME."clk" => $PREFIX_NAME."clk",
										#$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n",
										#$PREFIX_NAME."clk" => $PREFIX_NAME."clk[".($NUM_CLOCK_PAIRS - 1).":0]",
										#$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n[".($NUM_CLOCK_PAIRS - 1).":0]",
										$PREFIX_NAME."cs_n_0"  => $PREFIX_NAME."cs_n_0",
										$PREFIX_NAME."we_n_0"  => $PREFIX_NAME."we_n_0",
										$PREFIX_NAME."ref_n_0" => $PREFIX_NAME."ref_n_0",
										$PREFIX_NAME."a_0" => $PREFIX_NAME."a_0",
										$PREFIX_NAME."ba_0" => $PREFIX_NAME."ba_0",
										$PREFIX_NAME."d" => $PREFIX_NAME."d",
									},
								}),
							);
						}
					}
				}
			}
			else
			{
				if($enable_dm_pins eq "true") {
					if($num_addr_cmd_buses > 1) {
						if ($ddio_memory_clocks eq "true") {
							$module->add_contents
							(
								e_blind_instance->new
								({
									name 		=> $gWRAPPER_NAME,            
									module 		=> $gWRAPPER_NAME."_wrapper",
									comment 	=> "---------------------------------------------------------------------\n
									SIO RLDRAM II Controller\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk => "clk",
										write_clk => "write_clk",
										non_dqs_capture_clk => "read_clk",#$FEDBACK_CLOCK_NAME,
										reset_clk_n => "reset_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										local_write_req => $PREFIX_NAME."local_write_req",
										local_read_req => $PREFIX_NAME."local_read_req",
										local_addr => $PREFIX_NAME."local_addr",
										local_bank_addr => $PREFIX_NAME."local_bank_addr",
										local_wdata => $PREFIX_NAME."local_wdata",
										local_dm => $PREFIX_NAME."local_dm",
										local_refresh_req => $PREFIX_NAME."local_refresh_req",
										#$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld",
										$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld[".($MEM_NUM_DEVICES - 1).":0]",
										$PREFIX_NAME."q" => $PREFIX_NAME."q",
									},
					
									out_port_map	=>
									{
										local_wdata_req => $PREFIX_NAME."local_wdata_req",
										local_rdata_valid => $PREFIX_NAME."local_rdata_valid",#[]",
										local_rdata => $PREFIX_NAME."local_rdata",
										local_init_done => $PREFIX_NAME."local_init_done",
										#$PREFIX_NAME."clk" => $PREFIX_NAME."clk",
										#$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n",
										$PREFIX_NAME."clk" => $PREFIX_NAME."clk[".($NUM_CLOCK_PAIRS - 1).":0]",
										$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n[".($NUM_CLOCK_PAIRS - 1).":0]",
										$PREFIX_NAME."cs_n_0"  => $PREFIX_NAME."cs_n_0",
										$PREFIX_NAME."we_n_0"  => $PREFIX_NAME."we_n_0",
										$PREFIX_NAME."ref_n_0" => $PREFIX_NAME."ref_n_0",
										$PREFIX_NAME."cs_n_1"  => $PREFIX_NAME."cs_n_1",
										$PREFIX_NAME."we_n_1"  => $PREFIX_NAME."we_n_1",
										$PREFIX_NAME."ref_n_1" => $PREFIX_NAME."ref_n_1",
										$PREFIX_NAME."a_0" => $PREFIX_NAME."a_0",
										$PREFIX_NAME."ba_0" => $PREFIX_NAME."ba_0",
										$PREFIX_NAME."a_1" => $PREFIX_NAME."a_1",
										$PREFIX_NAME."ba_1" => $PREFIX_NAME."ba_1",
										#$PREFIX_NAME."dm" => $PREFIX_NAME."dm",
										$PREFIX_NAME."dm" => $PREFIX_NAME."dm[".($MEM_NUM_DEVICES - 1).":0]",
										$PREFIX_NAME."d" => $PREFIX_NAME."d",
									},
								}),
							);
						} else {
							$module->add_contents
							(
								e_blind_instance->new
								({
									name 		=> $gWRAPPER_NAME,            
									module 		=> $gWRAPPER_NAME."_wrapper",
									comment 	=> "---------------------------------------------------------------------\n
									SIO RLDRAM II Controller\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk => "clk",
										write_clk => "write_clk",
										non_dqs_capture_clk => "read_clk",#$FEDBACK_CLOCK_NAME,
										reset_clk_n => "reset_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										local_write_req => $PREFIX_NAME."local_write_req",
										local_read_req => $PREFIX_NAME."local_read_req",
										local_addr => $PREFIX_NAME."local_addr",
										local_bank_addr => $PREFIX_NAME."local_bank_addr",
										local_wdata => $PREFIX_NAME."local_wdata",
										local_dm => $PREFIX_NAME."local_dm",
										local_refresh_req => $PREFIX_NAME."local_refresh_req",
										#$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld",
										$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld[".($MEM_NUM_DEVICES - 1).":0]",
										$PREFIX_NAME."q" => $PREFIX_NAME."q",
									},
					
									out_port_map	=>
									{
										local_wdata_req => $PREFIX_NAME."local_wdata_req",
										local_rdata_valid => $PREFIX_NAME."local_rdata_valid",#[]",
										local_rdata => $PREFIX_NAME."local_rdata",
										local_init_done => $PREFIX_NAME."local_init_done",
										#$PREFIX_NAME."clk" => $PREFIX_NAME."clk",
										#$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n",
										#$PREFIX_NAME."clk" => $PREFIX_NAME."clk[".($NUM_CLOCK_PAIRS - 1).":0]",
										#$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n[".($NUM_CLOCK_PAIRS - 1).":0]",
										$PREFIX_NAME."cs_n_0"  => $PREFIX_NAME."cs_n_0",
										$PREFIX_NAME."we_n_0"  => $PREFIX_NAME."we_n_0",
										$PREFIX_NAME."ref_n_0" => $PREFIX_NAME."ref_n_0",
										$PREFIX_NAME."cs_n_1"  => $PREFIX_NAME."cs_n_1",
										$PREFIX_NAME."we_n_1"  => $PREFIX_NAME."we_n_1",
										$PREFIX_NAME."ref_n_1" => $PREFIX_NAME."ref_n_1",
										$PREFIX_NAME."a_0" => $PREFIX_NAME."a_0",
										$PREFIX_NAME."ba_0" => $PREFIX_NAME."ba_0",
										$PREFIX_NAME."a_1" => $PREFIX_NAME."a_1",
										$PREFIX_NAME."ba_1" => $PREFIX_NAME."ba_1",
										#$PREFIX_NAME."dm" => $PREFIX_NAME."dm",
										$PREFIX_NAME."dm" => $PREFIX_NAME."dm[".($MEM_NUM_DEVICES - 1).":0]",
										$PREFIX_NAME."d" => $PREFIX_NAME."d",
									},
								}),
							);
						}
					} else {
						if ($ddio_memory_clocks eq "true") {
							$module->add_contents
							(
								e_blind_instance->new
								({
									name 		=> $gWRAPPER_NAME,            
									module 		=> $gWRAPPER_NAME."_wrapper",
									comment 	=> "---------------------------------------------------------------------\n
									SIO RLDRAM II Controller\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk => "clk",
										write_clk => "write_clk",
										non_dqs_capture_clk => "read_clk",#$FEDBACK_CLOCK_NAME,
										reset_clk_n => "reset_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										local_write_req => $PREFIX_NAME."local_write_req",
										local_read_req => $PREFIX_NAME."local_read_req",
										local_addr => $PREFIX_NAME."local_addr",
										local_bank_addr => $PREFIX_NAME."local_bank_addr",
										local_wdata => $PREFIX_NAME."local_wdata",
										local_dm => $PREFIX_NAME."local_dm",
										local_refresh_req => $PREFIX_NAME."local_refresh_req",
										#$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld",
										$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld[".($MEM_NUM_DEVICES - 1).":0]",
										$PREFIX_NAME."q" => $PREFIX_NAME."q",
									},
					
									out_port_map	=>
									{
										local_wdata_req => $PREFIX_NAME."local_wdata_req",
										local_rdata_valid => $PREFIX_NAME."local_rdata_valid",#[]",
										local_rdata => $PREFIX_NAME."local_rdata",
										local_init_done => $PREFIX_NAME."local_init_done",
										#$PREFIX_NAME."clk" => $PREFIX_NAME."clk",
										#$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n",
										$PREFIX_NAME."clk" => $PREFIX_NAME."clk[".($NUM_CLOCK_PAIRS - 1).":0]",
										$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n[".($NUM_CLOCK_PAIRS - 1).":0]",
										$PREFIX_NAME."cs_n_0"  => $PREFIX_NAME."cs_n_0",
										$PREFIX_NAME."we_n_0"  => $PREFIX_NAME."we_n_0",
										$PREFIX_NAME."ref_n_0" => $PREFIX_NAME."ref_n_0",
										$PREFIX_NAME."a_0" => $PREFIX_NAME."a_0",
										$PREFIX_NAME."ba_0" => $PREFIX_NAME."ba_0",
										#$PREFIX_NAME."dm" => $PREFIX_NAME."dm",
										$PREFIX_NAME."dm" => $PREFIX_NAME."dm[".($MEM_NUM_DEVICES - 1).":0]",
										$PREFIX_NAME."d" => $PREFIX_NAME."d",
									},
								}),
							);
						} else {
							$module->add_contents
							(
								e_blind_instance->new
								({
									name 		=> $gWRAPPER_NAME,            
									module 		=> $gWRAPPER_NAME."_wrapper",
									comment 	=> "---------------------------------------------------------------------\n
									SIO RLDRAM II Controller\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk => "clk",
										write_clk => "write_clk",
										non_dqs_capture_clk => "read_clk",#$FEDBACK_CLOCK_NAME,
										reset_clk_n => "reset_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										local_write_req => $PREFIX_NAME."local_write_req",
										local_read_req => $PREFIX_NAME."local_read_req",
										local_addr => $PREFIX_NAME."local_addr",
										local_bank_addr => $PREFIX_NAME."local_bank_addr",
										local_wdata => $PREFIX_NAME."local_wdata",
										local_dm => $PREFIX_NAME."local_dm",
										local_refresh_req => $PREFIX_NAME."local_refresh_req",
										#$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld",
										$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld[".($MEM_NUM_DEVICES - 1).":0]",
										$PREFIX_NAME."q" => $PREFIX_NAME."q",
									},
					
									out_port_map	=>
									{
										local_wdata_req => $PREFIX_NAME."local_wdata_req",
										local_rdata_valid => $PREFIX_NAME."local_rdata_valid",#[]",
										local_rdata => $PREFIX_NAME."local_rdata",
										local_init_done => $PREFIX_NAME."local_init_done",
										#$PREFIX_NAME."clk" => $PREFIX_NAME."clk",
										#$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n",
										#$PREFIX_NAME."clk" => $PREFIX_NAME."clk[".($NUM_CLOCK_PAIRS - 1).":0]",
										#$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n[".($NUM_CLOCK_PAIRS - 1).":0]",
										$PREFIX_NAME."cs_n_0"  => $PREFIX_NAME."cs_n_0",
										$PREFIX_NAME."we_n_0"  => $PREFIX_NAME."we_n_0",
										$PREFIX_NAME."ref_n_0" => $PREFIX_NAME."ref_n_0",
										$PREFIX_NAME."a_0" => $PREFIX_NAME."a_0",
										$PREFIX_NAME."ba_0" => $PREFIX_NAME."ba_0",
										#$PREFIX_NAME."dm" => $PREFIX_NAME."dm",
										$PREFIX_NAME."dm" => $PREFIX_NAME."dm[".($MEM_NUM_DEVICES - 1).":0]",
										$PREFIX_NAME."d" => $PREFIX_NAME."d",
									},
								}),
							);
						}
					}
				} else {
					if($num_addr_cmd_buses > 1) {
						if ($ddio_memory_clocks eq "true") {
							$module->add_contents
							(
								e_blind_instance->new
								({
									name 		=> $gWRAPPER_NAME,            
									module 		=> $gWRAPPER_NAME."_wrapper",
									comment 	=> "---------------------------------------------------------------------\n
									SIO RLDRAM II Controller\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk => "clk",
										write_clk => "write_clk",
										non_dqs_capture_clk => "read_clk",#$FEDBACK_CLOCK_NAME,
										reset_clk_n => "reset_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										local_write_req => $PREFIX_NAME."local_write_req",
										local_read_req => $PREFIX_NAME."local_read_req",
										local_addr => $PREFIX_NAME."local_addr",
										local_bank_addr => $PREFIX_NAME."local_bank_addr",
										local_wdata => $PREFIX_NAME."local_wdata",
										#local_dm => $PREFIX_NAME."local_dm",
										local_refresh_req => $PREFIX_NAME."local_refresh_req",
										#$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld",
										$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld[".($MEM_NUM_DEVICES - 1).":0]",
										$PREFIX_NAME."q" => $PREFIX_NAME."q",
									},
					
									out_port_map	=>
									{
										local_wdata_req => $PREFIX_NAME."local_wdata_req",
										local_rdata_valid => $PREFIX_NAME."local_rdata_valid",#[]",
										local_rdata => $PREFIX_NAME."local_rdata",
										local_init_done => $PREFIX_NAME."local_init_done",
										#$PREFIX_NAME."clk" => $PREFIX_NAME."clk",
										#$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n",
										$PREFIX_NAME."clk" => $PREFIX_NAME."clk[".($NUM_CLOCK_PAIRS - 1).":0]",
										$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n[".($NUM_CLOCK_PAIRS - 1).":0]",
										$PREFIX_NAME."cs_n_0"  => $PREFIX_NAME."cs_n_0",
										$PREFIX_NAME."we_n_0"  => $PREFIX_NAME."we_n_0",
										$PREFIX_NAME."ref_n_0" => $PREFIX_NAME."ref_n_0",
										$PREFIX_NAME."cs_n_1"  => $PREFIX_NAME."cs_n_1",
										$PREFIX_NAME."we_n_1"  => $PREFIX_NAME."we_n_1",
										$PREFIX_NAME."ref_n_1" => $PREFIX_NAME."ref_n_1",
										$PREFIX_NAME."a_0" => $PREFIX_NAME."a_0",
										$PREFIX_NAME."ba_0" => $PREFIX_NAME."ba_0",
										$PREFIX_NAME."a_1" => $PREFIX_NAME."a_1",
										$PREFIX_NAME."ba_1" => $PREFIX_NAME."ba_1",
										$PREFIX_NAME."d" => $PREFIX_NAME."d",
									},
								}),
							);
						} else {
							$module->add_contents
							(
								e_blind_instance->new
								({
									name 		=> $gWRAPPER_NAME,            
									module 		=> $gWRAPPER_NAME."_wrapper",
									comment 	=> "---------------------------------------------------------------------\n
									SIO RLDRAM II Controller\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk => "clk",
										write_clk => "write_clk",
										non_dqs_capture_clk => "read_clk",#$FEDBACK_CLOCK_NAME,
										reset_clk_n => "reset_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										local_write_req => $PREFIX_NAME."local_write_req",
										local_read_req => $PREFIX_NAME."local_read_req",
										local_addr => $PREFIX_NAME."local_addr",
										local_bank_addr => $PREFIX_NAME."local_bank_addr",
										local_wdata => $PREFIX_NAME."local_wdata",
										#local_dm => $PREFIX_NAME."local_dm",
										local_refresh_req => $PREFIX_NAME."local_refresh_req",
										#$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld",
										$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld[".($MEM_NUM_DEVICES - 1).":0]",
										$PREFIX_NAME."q" => $PREFIX_NAME."q",
									},
					
									out_port_map	=>
									{
										local_wdata_req => $PREFIX_NAME."local_wdata_req",
										local_rdata_valid => $PREFIX_NAME."local_rdata_valid",#[]",
										local_rdata => $PREFIX_NAME."local_rdata",
										local_init_done => $PREFIX_NAME."local_init_done",
										#$PREFIX_NAME."clk" => $PREFIX_NAME."clk",
										#$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n",
										#$PREFIX_NAME."clk" => $PREFIX_NAME."clk[".($NUM_CLOCK_PAIRS - 1).":0]",
										#$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n[".($NUM_CLOCK_PAIRS - 1).":0]",
										$PREFIX_NAME."cs_n_0"  => $PREFIX_NAME."cs_n_0",
										$PREFIX_NAME."we_n_0"  => $PREFIX_NAME."we_n_0",
										$PREFIX_NAME."ref_n_0" => $PREFIX_NAME."ref_n_0",
										$PREFIX_NAME."cs_n_1"  => $PREFIX_NAME."cs_n_1",
										$PREFIX_NAME."we_n_1"  => $PREFIX_NAME."we_n_1",
										$PREFIX_NAME."ref_n_1" => $PREFIX_NAME."ref_n_1",
										$PREFIX_NAME."a_0" => $PREFIX_NAME."a_0",
										$PREFIX_NAME."ba_0" => $PREFIX_NAME."ba_0",
										$PREFIX_NAME."a_1" => $PREFIX_NAME."a_1",
										$PREFIX_NAME."ba_1" => $PREFIX_NAME."ba_1",
										$PREFIX_NAME."d" => $PREFIX_NAME."d",
									},
								}),
							);
						}
					} else {
						if ($ddio_memory_clocks eq "true") {
							$module->add_contents
							(
								e_blind_instance->new
								({
									name 		=> $gWRAPPER_NAME,            
									module 		=> $gWRAPPER_NAME."_wrapper",
									comment 	=> "---------------------------------------------------------------------\n
									SIO RLDRAM II Controller\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk => "clk",
										write_clk => "write_clk",
										non_dqs_capture_clk => "read_clk",#$FEDBACK_CLOCK_NAME,
										reset_clk_n => "reset_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										local_write_req => $PREFIX_NAME."local_write_req",
										local_read_req => $PREFIX_NAME."local_read_req",
										local_addr => $PREFIX_NAME."local_addr",
										local_bank_addr => $PREFIX_NAME."local_bank_addr",
										local_wdata => $PREFIX_NAME."local_wdata",
										#local_dm => $PREFIX_NAME."local_dm",
										local_refresh_req => $PREFIX_NAME."local_refresh_req",
										#$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld",
										$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld[".($MEM_NUM_DEVICES - 1).":0]",
										$PREFIX_NAME."q" => $PREFIX_NAME."q",
									},
					
									out_port_map	=>
									{
										local_wdata_req => $PREFIX_NAME."local_wdata_req",
										local_rdata_valid => $PREFIX_NAME."local_rdata_valid",#[]",
										local_rdata => $PREFIX_NAME."local_rdata",
										local_init_done => $PREFIX_NAME."local_init_done",
										#$PREFIX_NAME."clk" => $PREFIX_NAME."clk",
										#$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n",
										$PREFIX_NAME."clk" => $PREFIX_NAME."clk[".($NUM_CLOCK_PAIRS - 1).":0]",
										$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n[".($NUM_CLOCK_PAIRS - 1).":0]",
										$PREFIX_NAME."cs_n_0"  => $PREFIX_NAME."cs_n_0",
										$PREFIX_NAME."we_n_0"  => $PREFIX_NAME."we_n_0",
										$PREFIX_NAME."ref_n_0" => $PREFIX_NAME."ref_n_0",
										$PREFIX_NAME."a_0" => $PREFIX_NAME."a_0",
										$PREFIX_NAME."ba_0" => $PREFIX_NAME."ba_0",
										$PREFIX_NAME."d" => $PREFIX_NAME."d",
									},
								}),
							);
						} else {
							$module->add_contents
							(
								e_blind_instance->new
								({
									name 		=> $gWRAPPER_NAME,            
									module 		=> $gWRAPPER_NAME."_wrapper",
									comment 	=> "---------------------------------------------------------------------\n
									SIO RLDRAM II Controller\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk => "clk",
										write_clk => "write_clk",
										non_dqs_capture_clk => "read_clk",#$FEDBACK_CLOCK_NAME,
										reset_clk_n => "reset_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										local_write_req => $PREFIX_NAME."local_write_req",
										local_read_req => $PREFIX_NAME."local_read_req",
										local_addr => $PREFIX_NAME."local_addr",
										local_bank_addr => $PREFIX_NAME."local_bank_addr",
										local_wdata => $PREFIX_NAME."local_wdata",
										#local_dm => $PREFIX_NAME."local_dm",
										local_refresh_req => $PREFIX_NAME."local_refresh_req",
										#$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld",
										$PREFIX_NAME."qvld" => $PREFIX_NAME."qvld[".($MEM_NUM_DEVICES - 1).":0]",
										$PREFIX_NAME."q" => $PREFIX_NAME."q",
									},
					
									out_port_map	=>
									{
										local_wdata_req => $PREFIX_NAME."local_wdata_req",
										local_rdata_valid => $PREFIX_NAME."local_rdata_valid",#[]",
										local_rdata => $PREFIX_NAME."local_rdata",
										local_init_done => $PREFIX_NAME."local_init_done",
										#$PREFIX_NAME."clk" => $PREFIX_NAME."clk",
										#$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n",
										#$PREFIX_NAME."clk" => $PREFIX_NAME."clk[".($NUM_CLOCK_PAIRS - 1).":0]",
										#$PREFIX_NAME."clk_n" => $PREFIX_NAME."clk_n[".($NUM_CLOCK_PAIRS - 1).":0]",
										$PREFIX_NAME."cs_n_0"  => $PREFIX_NAME."cs_n_0",
										$PREFIX_NAME."we_n_0"  => $PREFIX_NAME."we_n_0",
										$PREFIX_NAME."ref_n_0" => $PREFIX_NAME."ref_n_0",
										$PREFIX_NAME."a_0" => $PREFIX_NAME."a_0",
										$PREFIX_NAME."ba_0" => $PREFIX_NAME."ba_0",
										$PREFIX_NAME."d" => $PREFIX_NAME."d",
									},
								}),
							);
						}
					}
				}
			}
		}
	};

#########################################################################################################################################################
	
	$module->add_contents
	(
		e_comment->new({comment => "<< END MEGAWIZARD INSERT WRAPPER_NAME"}),
		e_comment->new({comment => "<< START MEGAWIZARD INSERT EXAMPLE_DRIVER"}),
		e_blind_instance->new
		({
			name 		=> $gWRAPPER_NAME."_driver",            
			module 		=> $gWRAPPER_NAME."_example_driver",
			comment 	=> "---------------------------------------------------------------------\n
			RLDRAM II Example Driver\n
			---------------------------------------------------------------------\n",
			in_port_map 	=>
			{
			    capture_clk => "read_clk",
			    clk => "clk",
			    local_init_done => $PREFIX_NAME."local_init_done",
			    local_rdata => $PREFIX_NAME."local_rdata",
			    local_rdata_valid => $PREFIX_NAME."local_rdata_valid",
			    local_wdata_req => $PREFIX_NAME."local_wdata_req",
			    reset_clk_n => "reset_clk_n",
			    #reset_read_clk_n => "reset_driver_read_clk_n",
			    #reset_read_clk_n => $PREFIX_NAME."local_init_done",
			},

			out_port_map	=>
			{
			    local_read_req => $PREFIX_NAME."local_read_req",
			    local_write_req => $PREFIX_NAME."local_write_req",
			    local_addr => $PREFIX_NAME."local_addr",
			    local_bank_addr => $PREFIX_NAME."local_bank_addr",
			    local_wdata => $PREFIX_NAME."local_wdata",
			    local_dm => $PREFIX_NAME."local_dm",
			    local_refresh_req => $PREFIX_NAME."local_refresh_req",
			    test_complete => "test_complete",
			    pnf_per_byte => "pnf_per_byte",
			    pnf_persist => "pnf_persist",
			},
		}),
		e_comment->new({comment => "<< END MEGAWIZARD INSERT EXAMPLE_DRIVER"}),
		e_comment->new({comment => "<< START MEGAWIZARD INSERT PLL"}),
	);
	

#########################################################################################################################################################
if ($ENABLE_CAPTURE_CLK eq "false") {
	
	if ($addr_cmd_clk eq "dedicated_clk") {
		$module->add_contents
		(
			e_blind_instance->new
			({
				name 		=> "g_".$familylc."_pll_rldramii_pll_inst",            
				module 		=> "rldramii_pll_".$familylc,
				comment 	=> "---------------------------------------------------------------------\n
				$family PLL\n
				---------------------------------------------------------------------\n",
				in_port_map 	=>
				{
					inclk0 	=> "clock_source",
					areset 	=> "reset",
				},
	
				out_port_map	=>
				{
					c0	=> clk,
					c1	=> write_clk,
					c2	=> dedicated_addr_cmd_clk,
					c3	=> "memory_clk_0",
					c4	=> "memory_clk_1",
					c5	=> "memory_clk_2",
					locked	=> pll_locked,
				},
			}),
		);
	} else {
		$module->add_contents
		(
			e_blind_instance->new
			({
				name 		=> "g_".$familylc."_pll_rldramii_pll_inst",            
				module 		=> "rldramii_pll_".$familylc,
				comment 	=> "---------------------------------------------------------------------\n
				$family PLL\n
				---------------------------------------------------------------------\n",
				in_port_map 	=>
				{
					inclk0 	=> "clock_source",
					areset 	=> "reset",
				},
	
				out_port_map	=>
				{
					c0	=> clk,
					c1	=> write_clk,
					c2	=> "open",
					c3	=> "memory_clk_0",
					c4	=> "memory_clk_1",
					c5	=> "memory_clk_2",
					locked	=> pll_locked,
				},
			}),
		);
	}
	
	$module->add_contents
	(
		e_assign->new({lhs => "dqs_ref_clk", rhs => "clk"}),
	);
}
else
{
	if ($addr_cmd_clk eq "dedicated_clk") {
		$module->add_contents
		(
			e_blind_instance->new
			({
				name 		=> "g_".$familylc."_pll_rldramii_pll_inst",            
				module 		=> "rldramii_pll_".$familylc,
				comment 	=> "---------------------------------------------------------------------\n
				$family PLL\n
				---------------------------------------------------------------------\n",
				in_port_map 	=>
				{
					inclk0 	=> "clock_source",
					areset 	=> "reset",
				},
	
				out_port_map	=>
				{
					c0	=> clk,
					c1	=> write_clk,
					c2	=> dedicated_addr_cmd_clk,
					c3	=> "memory_clk_0",
					c4	=> "memory_clk_1",
					c5	=> "memory_clk_2",
					locked	=> pll_locked,
				},
			}),
		);
	} else {
		$module->add_contents
		(
			e_blind_instance->new
			({
				name 		=> "g_".$familylc."_pll_rldramii_pll_inst",            
				module 		=> "rldramii_pll_".$familylc,
				comment 	=> "---------------------------------------------------------------------\n
				$family PLL\n
				---------------------------------------------------------------------\n",
				in_port_map 	=>
				{
					inclk0 	=> "clock_source",
					areset 	=> "reset",
				},
	
				out_port_map	=>
				{
					c0	=> clk,
					c1	=> write_clk,
					c2	=> "open",
					c3	=> "memory_clk_0",
					c4	=> "memory_clk_1",
					c5	=> "memory_clk_2",
					locked	=> pll_locked,
				},
			}),
		);
	}
}
	
#if ($ddio_memory_clocks eq "false") {
if ($ddio_memory_clocks_output eq "false") {
	if($NUM_CLOCK_PAIRS eq "1") {	
		$module->add_contents
		(
			e_assign->new({lhs => $PREFIX_NAME."clk[0]", rhs => "memory_clk_0"}),
            e_assign->new({lhs => $PREFIX_NAME."clk_n[0]", rhs => "~memory_clk_0"}),
		);
	} elsif($NUM_CLOCK_PAIRS eq "2") {	
		$module->add_contents
		(
			e_assign->new({lhs => $PREFIX_NAME."clk[0]", rhs => "memory_clk_0"}),
			e_assign->new({lhs => $PREFIX_NAME."clk[1]", rhs => "memory_clk_1"}),
            e_assign->new({lhs => $PREFIX_NAME."clk_n[0]", rhs => "~memory_clk_0"}),
            e_assign->new({lhs => $PREFIX_NAME."clk_n[1]", rhs => "~memory_clk_1"}),
		);
	} elsif($NUM_CLOCK_PAIRS eq "3") {	
		$module->add_contents
		(
			e_assign->new({lhs => $PREFIX_NAME."clk[0]", rhs => "memory_clk_0"}),
			e_assign->new({lhs => $PREFIX_NAME."clk[1]", rhs => "memory_clk_1"}),
			e_assign->new({lhs => $PREFIX_NAME."clk[2]", rhs => "memory_clk_2"}),
            e_assign->new({lhs => $PREFIX_NAME."clk_n[0]", rhs => "~memory_clk_0"}),
            e_assign->new({lhs => $PREFIX_NAME."clk_n[1]", rhs => "~memory_clk_1"}),
            e_assign->new({lhs => $PREFIX_NAME."clk_n[2]", rhs => "~memory_clk_2"}),
		);
	}
}

#########################################################################################################################################################	

if ($addr_cmd_clk eq "system_clk") {
	$module->add_contents
	(
		e_assign->new({lhs => "addr_cmd_clk", rhs => "clk"}),
	),
}

if ($addr_cmd_clk eq "write_clk") {
	$module->add_contents
	(
		e_assign->new({lhs => "addr_cmd_clk", rhs => "write_clk"}),
	),
}

if ($addr_cmd_clk eq "dedicated_clk") {
	$module->add_contents
	(
		e_assign->new({lhs => "addr_cmd_clk", rhs => "dedicated_addr_cmd_clk"}),
	),
}
$module->add_contents
(
    e_comment->new({comment => "<< END MEGAWIZARD INSERT PLL\n"}),
);
#########################################################################################################################################################

if ($ENABLE_CAPTURE_CLK eq "false") {	
	$module->add_contents
	(
		e_comment->new({comment => "<< START MEGAWIZARD INSERT DLL\n"}),
		e_blind_instance->new
		({
			name 		=> $gWRAPPER_NAME."_stxii_dll",            
			module 		=> "".$familylc."_dll",
			comment 	=> "---------------------------------------------------------------------\n
			$family DLL\n
			---------------------------------------------------------------------\n",
			in_port_map 	=>
			{
				#aload => "reset",
				clk => "dqs_ref_clk",
			},

			out_port_map	=>
			{
				delayctrlout => dqs_delay_ctrl
			},
			
			parameter_map 	=>
			{
				delay_buffer_mode	=> '"'.$gSTRATIXII_DLL_DELAY_BUFFER_MODE.'"',
				delay_chain_length  	=> $STRATIXII_DLL_DELAY_CHAIN_LENGTH,
				delayctrlout_mode  	=> '"'."normal".'"',
				input_frequency   	=> '"'.$CLOCK_PERIOD_IN_PS."ps".'"',
				jitter_reduction   	=> '"'."false".'"',
				offsetctrlout_mode	=> '"'."static".'"',
				sim_loop_delay_increment => "144",
				sim_loop_intrinsic_delay => "3600",
				sim_valid_lock		=> "1",
				sim_valid_lockcount	=> "27",
				static_offset		=> '"'."0".'"',
				use_upndnin		=> '"'."false".'"',
				use_upndninclkena	=> '"'."false".'"',
			},
		}),
		e_comment->new({comment => "<< END MEGAWIZARD INSERT DLL\n"}),
	);
} else {
	$module->add_contents
	(
		e_comment->new({comment => "<< START MEGAWIZARD INSERT FB_PLL"}),
		e_signal->news #: ["signal", width, export, never_export]
		(["resynced_clk",	1,	0,	1]),
		e_blind_instance->new
		({
			name 		=> "g_".$familylc."_fbpll_rldramii_pll_inst",            
			module 		=> "rldramii_fbpll_".$familylc,
			comment 	=> "---------------------------------------------------------------------\n
			$family PLL\n
			---------------------------------------------------------------------\n",
			in_port_map 	=>
			{
				inclk0 	=> $PREFIX_NAME."fb_clk_in",
                areset 	=> "fb_pll_reset",
			},
			out_port_map	=>
			{
				c0	=> "fb_pll_clk",
			},
			# parameter_map	=>
			# {
				# clock_period_in_ps 		=> $CLOCK_PERIOD_IN_PS,
				# fedback_clock_phase_shift 	=> '"'.$FEDBACK_PHASE_SHIFT.'"',
			# }
		}),
		e_comment->new({comment => "<< END MEGAWIZARD INSERT FB_PLL\n"}),
	);
}
	
$module->add_contents(e_comment->new({comment => "<< START  EUROPA  RENAMEROO"}),);
#########################################################################################################################################################
                    
$project->output();

}

1;
