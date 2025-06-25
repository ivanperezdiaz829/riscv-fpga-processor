#sopc_builder free code

use europa_all; 
use europa_utils;

use e_testbench;
use e_reset;
use e_clk;

sub get_value{
	my $input = shift;
	my $var = 1;
	for ($i=0;$i<$input; $i++) 
	{
		$var *= 2;
	}
	return $var;
}

sub write_rldramii_test_bench

{
my $top = e_module->new({name => $gTOPLEVEL_NAME."_tb"});#,output_file => "/temp_gen/${gWRAPPER_NAME}_example_driver"});
my $project = e_project->new({top => $top, language => $language,__system_directory =>$output_directory."testbench",timescale   => "1 ps/ 1 ps"});#'temp_gen'});
my $module = $project->top();
#####   Parameters declaration  ######
$header_title = "RLDRAM II Controller Test Bench";
$header_filename = $gTOPLEVEL_NAME . "_tb";
$header_revision = "V" . $gWIZARD_VERSION;
#my $verilog_dq_io_instname;# = "\\g_datapath:\$i:g_ddr_io ";
my $Stratix_Fam = "";
my %stratix_param  = "";
my $PREFIX_NAME = $gDDR_PREFIX_NAME;
my $LOCAL_DATA_BITS = $gLOCAL_DATA_BITS;
my $LOCAL_DATA_MODE = $gLOCAL_DATA_MODE;
my $LOCAL_ADDR_BITS = 24;
my $LOCAL_BURST_LEN = $gLOCAL_BURST_LEN;
my $LOCAL_BURST_LEN_BITS = $gLOCAL_BURST_LEN_BITS;
my $MEM_CHIPSELS = $gMEM_CHIPSELS;
my $MEM_CHIP_BITS = $gMEM_CHIP_BITS;
my $MEM_ROW_BITS = $gMEM_ROW_BITS;
my $MEM_BANK_BITS = $gMEM_BANK_BITS;
my $MEM_COL_BITS = $gMEM_COL_BITS;
my $MEM_ADDR_BITS = $gMEM_ADDR_BITS;
my $MEM_NUM_DEVICES = $gMEM_NUM_DEVICES;
my $RLDRAMII_TYPE = $gRLDRAMII_TYPE;
my $ADDR_SHIFT_BITS = $gADDR_SHIFT_BITS;
my $REFRESH_COMMAND = $gREFRESH_COMMAND;
my $MEM_DQ_PER_DQS = $gMEM_DQ_PER_DQS;
my $NUM_CLOCK_PAIRS = $gNUM_CLOCK_PAIRS;
my $CLOCK_FREQ_IN_MHZ = $gCLOCK_FREQ_IN_MHZ;
my $MEMORY_DEVICE = $gMEMORY_DEVICE;
#my $ddio_memory_clocks = $gDDIO_MEMORY_CLOCKS;
my $ddio_memory_clocks = true;
my $enable_dm_pins = $gENABLE_DM_PINS;
my $num_addr_cmd_buses = $gNUMBER_ADDR_CMD_BUSES;
my $WRITE_ALL_MODE = 1;
my $S_WRITE_ALL = 1;
my $S_WRITE = 5;
my $S_WRITE_ALL_WAIT = 2;
my $S_WRITE_WAIT = 6;
my $S_READ_ALL = 3;
my $S_READ = 7;
my $S_READ_ALL_WAIT = 4;
my $S_READ_WAIT = 8;
my $S_IDLE = 0;
my $S_INIT = 9;
my $NUMBER_DQS;
#my $CLK_PERIOD = 10;
my $clock_pos_pin_name = $gCLOCK_POS_PIN_NAME;
my $clock_neg_pin_name = $gCLOCK_NEG_PIN_NAME;
my $USE_DENALI_MEMORY_MODELS = $gUSE_DENALI_MEMORY_MODELS;
my $clock_period_in_ps = $gCLOCK_PERIOD_IN_PS/1000;
my $CLK_PERIOD = $clock_period_in_ps; 

my $MEMORY_BURST_LENGTH = $LOCAL_BURST_LEN * 2;

#### Calculate the number of dqs pins used and the memory interface width ####
if ($LOCAL_DATA_MODE eq "narrow") {
    $NUMBER_DQS = int($LOCAL_DATA_BITS / $MEM_DQ_PER_DQS / 2);
    $MEMORY_DATA_WIDTH = int($LOCAL_DATA_BITS / 2);
} else {
    $NUMBER_DQS = int($LOCAL_DATA_BITS / $LOCAL_BURST_LEN / $MEM_DQ_PER_DQS / 2);
    $MEMORY_DATA_WIDTH = int($LOCAL_DATA_BITS / $MEMORY_BURST_LEN / 2);	
}

my $RLDRAMII_WIDTH = int($MEMORY_DATA_WIDTH / $MEM_NUM_DEVICES);
my $NUMBER_DQS_PER_DEVICE = int($NUMBER_DQS / $MEM_NUM_DEVICES);
my $ENABLE_CAPTURE_CLK = $gENABLE_CAPTURE_CLK;

if ($ENABLE_CAPTURE_CLK eq "true") {
	$CAPTURE_MODE = non_dqs;
}
else {
	$CAPTURE_MODE = dqs;
}

my $FEDBACK_CLOCK_NAME = $gFEDBACK_CLOCK_NAME;

my $NUMBER_DEVICES_PER_CLOCK = ceil($MEM_NUM_DEVICES / $NUM_CLOCK_PAIRS);
#### Select the memory based on device width and cio/sio mode


## Set the path to where the DENALI RLDRAM II memory models are saved
my $DENALI_PATH = "d:/data/mem/rldramii_core/test/models/denali/";

if ($RLDRAMII_TYPE eq "cio") {
	if (($RLDRAMII_WIDTH == 8) or ($RLDRAMII_WIDTH == 9)) {
		if ($USE_DENALI_MEMORY_MODELS eq "true") {
			$MEMORY_COMPONENT_NAME = mt49h32m.$RLDRAMII_WIDTH;
		} else {
            if ($MEMORY_DEVICE eq "MT49H64M9HU") {
                $MEMORY_COMPONENT_NAME = mt49h64m9;
            } else {
                $MEMORY_COMPONENT_NAME = mt49h32m9;
            }
		}
		$DENALI_MEMORY_COMPONENT_NAME = cio_x8_x9_rldramii;
		$MEMORY_SPEC = "$DENALI_PATH$RLDRAMII_TYPE/x9/".$MEMORY_COMPONENT_NAME."_2.5.soma";
	} elsif (($RLDRAMII_WIDTH == 16) or ($RLDRAMII_WIDTH == 18)) {
		if ($USE_DENALI_MEMORY_MODELS eq "true") {
			$MEMORY_COMPONENT_NAME = mt49h16m.$RLDRAMII_WIDTH;
		} else {
            if ($MEMORY_DEVICE eq "MT49H32M18HU") {
                $MEMORY_COMPONENT_NAME = mt49h32m18;
            } else {
                $MEMORY_COMPONENT_NAME = mt49h16m18;
            }
		}
		$DENALI_MEMORY_COMPONENT_NAME = cio_x16_x18_rldramii;
		$MEMORY_SPEC = "$DENALI_PATH$RLDRAMII_TYPE/x18/".$MEMORY_COMPONENT_NAME."_2.5.soma";
	} else {
		if ($USE_DENALI_MEMORY_MODELS eq "true") {
			$MEMORY_COMPONENT_NAME = mt49h8m.$RLDRAMII_WIDTH;
		} else {
            if ($MEMORY_DEVICE eq "MT49H16M36HU") {
                $MEMORY_COMPONENT_NAME = mt49h16m36;
            } else {
                $MEMORY_COMPONENT_NAME = mt49h8m36;
            }
		}
		$DENALI_MEMORY_COMPONENT_NAME = cio_x32_x36_rldramii;
		$MEMORY_SPEC ="$DENALI_PATH$RLDRAMII_TYPE/x36/".$MEMORY_COMPONENT_NAME."_2.5.soma";
	}
}
else {
	if (($RLDRAMII_WIDTH == 8) or ($RLDRAMII_WIDTH == 9)) {
		if ($USE_DENALI_MEMORY_MODELS eq "true") {
			$MEMORY_COMPONENT_NAME = mt49h32m.$RLDRAMII_WIDTH.c;
		} else {
            if ($MEMORY_DEVICE eq "MT49H64M9CHU") {
                $MEMORY_COMPONENT_NAME = mt49h64m9c;
            } else {
                $MEMORY_COMPONENT_NAME = mt49h32m9c;
            }
		}
		$DENALI_MEMORY_COMPONENT_NAME = sio_x8_x9_rldramii;
		$MEMORY_SPEC ="$DENALI_PATH$RLDRAMII_TYPE/x9/".$MEMORY_COMPONENT_NAME."_2.5.soma";
	} elsif (($RLDRAMII_WIDTH == 16) or ($RLDRAMII_WIDTH == 18)) {
		if ($USE_DENALI_MEMORY_MODELS eq "true") {
			$MEMORY_COMPONENT_NAME = mt49h16m.$RLDRAMII_WIDTH.c;
		} else {
            if ($MEMORY_DEVICE eq "MT49H32M18CHU") {
                $MEMORY_COMPONENT_NAME = mt49h32m18c;
            } else {
                $MEMORY_COMPONENT_NAME = mt49h16m18c;
            }
		}
		$DENALI_MEMORY_COMPONENT_NAME = sio_x16_x18_rldramii;
		$MEMORY_SPEC = "$DENALI_PATH$RLDRAMII_TYPE/x18/".$MEMORY_COMPONENT_NAME."_2.5.soma";
	}
}

my $cs_addr_max = get_value($gLEGAL_MEM_CHIP_BITS)-1;
my $bank_addr_max = get_value($MEM_BANK_BITS)-1;
my $row_addr_max = get_value($MEM_ROW_BITS)-1;
my $col_addr_max = get_value($MEM_COL_BITS)-1;

####  end parameter list  ######

my $sig_num;
my %sig_name;
my @sig_name;
my %sig_width;
my @sig_width;


if( $RLDRAMII_TYPE eq "cio" )
{
	$module->add_contents(
		e_signal->new(["rldramii_dq" , $MEMORY_DATA_WIDTH, 0,1]),
		e_signal->new(["dq" , $MEMORY_DATA_WIDTH, 0,1]),
		e_assign->new(["rldramii_dq","dq"]),
	);
}
elsif ( $RLDRAMII_TYPE eq "sio")
{
	$module->add_contents(
		e_signal->new(["rldramii_d" , $MEMORY_DATA_WIDTH, 0,1]),
		e_signal->new(["rldramii_q" , $MEMORY_DATA_WIDTH, 0,1]),
	);
}
#######################################################################################################################################

$module->comment
(
	"------------------------------------------------------------------------------\n
	\nTitle        : $header_title
	\nProject      : RLDRAM II Controller
	\nFile         : $header_filename
	\nRevision     : $header_revision
	\nAbstract:
	\nRLDRAM II Test Bench										
	----------------------------------------------------------------------------------\n
	Memory Interface Setup:\n
	Memory Interface Data Width         : $MEMORY_DATA_WIDTH\n
	Number DQ Bits per DQS Input        : $MEM_DQ_PER_DQS\n
	Number Memory Address Bits          : $MEM_ADDR_BITS\n
	Memory Burst Length                 : $MEMORY_BURST_LENGTH\n
	Number Memory Devices               : $MEM_NUM_DEVICES\n
	Number Address/Command Buses        : $num_addr_cmd_buses\n
	Number of Qk, Qk_n Pairs Per Memory : $NUMBER_DQS_PER_DEVICE\n
	Read Data Capture Mode              : $CAPTURE_MODE\n
	Width of Memory Devices             : $RLDRAMII_WIDTH\n
	RLDRAM II Type                      : $RLDRAMII_TYPE\n
	Enable DM Pins                      : $enable_dm_pins\n
	DDIO Memory Clock Generation        : $ddio_memory_clocks\n
	Number Memory Clock Pairs           : $NUM_CLOCK_PAIRS\n
	Refresh Type                        : $REFRESH_COMMAND\n
	CLOCK SOURCE PERIOD                 : $clock_period_in_ps ns\n
	Denali Memory Models                : $USE_DENALI_MEMORY_MODELS\n
    Memory Device                       : $MEMORY_DEVICE\n
	----------------------------------------------------------------------------------\n",
);

#########################################################################################################################################################
	 $module->add_contents
	 (
	 #####   signal generation #####
          	e_signal->news #: ["signal", width, export, never_export]
		(	 
	         	["clock_source",1,	0,	1],
			["system_reset_n",1,	0,	1],
			#["rldramii_clk",$NUM_CLOCK_PAIRS,	0,	1],
			#["rldramii_clk_n",$NUM_CLOCK_PAIRS,	0,	1],
			["rldramii_a_0",$MEM_ADDR_BITS,	0,	1],
			["rldramii_ba_0",3,	0,	1],
			["rldramii_cs_n_0",1,	0,	1],
			["rldramii_we_n_0",1,	0,	1],
			["rldramii_ref_n_0",1,	0,	1],
			#["rldramii_dm",$MEM_NUM_DEVICES,	0,	1],		 
			#["rldramii_qk",$NUMBER_DQS,	0,	1],
			#["rldramii_qk_n",$NUMBER_DQS,	0,	1],
			#["rldramii_qvld",$MEM_NUM_DEVICES,	0,	1],
			# ["rldramii_a_delayed",$MEM_ADDR_BITS,	0,	1],
			# ["rldramii_ba_delayed",3,	0,	1],
			# ["rldramii_cs_n_delayed",1,	0,	1],
			# ["rldramii_we_n_delayed",1,	0,	1],
			# ["rldramii_ref_n_delayed",1,	0,	1],
			# ["rldramii_dm_delayed",$MEM_NUM_DEVICES,	0,	1],
			["rldramii_a",$MEM_ADDR_BITS,	0,	1],
			["rldramii_ba",3,	0,	1],
			["rldramii_cs_n",1,	0,	1],
			["rldramii_we_n",1,	0,	1],
			["rldramii_ref_n",1,	0,	1],
			["test_complete",1,	0,	1],
			["pnf_per_byte",$NUMBER_DQS * 2,	0,	1],
			["pnf_persist",1,	0,	1],
		),
		
		e_signal->new({name => "rldramii_clk" , width => $NUM_CLOCK_PAIRS , export => 0, never_export => 1, declare_one_bit_as_std_logic_vector => 1}),
		e_signal->new({name => "rldramii_clk_n" , width => $NUM_CLOCK_PAIRS , export => 0, never_export => 1, declare_one_bit_as_std_logic_vector => 1}),
		e_signal->new({name => "rldramii_dm" , width => $MEM_NUM_DEVICES , export => 0, never_export => 1, declare_one_bit_as_std_logic_vector => 1}),
		e_signal->new({name => "rldramii_qk" , width => $NUMBER_DQS , export => 0, never_export => 1, declare_one_bit_as_std_logic_vector => 1}),
		e_signal->new({name => "rldramii_qk_n" , width => $NUMBER_DQS , export => 0, never_export => 1, declare_one_bit_as_std_logic_vector => 1}),
		e_signal->new({name => "rldramii_qvld" , width => $MEM_NUM_DEVICES , export => 0, never_export => 1, declare_one_bit_as_std_logic_vector => 1}),
		
	);	

	if($num_addr_cmd_buses > 1) {
		$module->add_contents
	 (
	 #####   signal generation #####
          	e_signal->news #: ["signal", width, export, never_export]
		(	 
	         	["rldramii_a_1",$MEM_ADDR_BITS,	0,	1],
			["rldramii_ba_1",3,	0,	1],
			["rldramii_cs_n_1",1,	0,	1],
			["rldramii_we_n_1",1,	0,	1],
			["rldramii_ref_n_1",1,	0,	1],
		),
		
	);
	}
	
#########################################################################################################################################################

 	$module->add_contents
	(
		 e_comment->new({comment => "Delay RLDRAM II Control Signals"}),
		 # e_assign->new({lhs => "rldramii_a_delayed", rhs => "rldramii_a_0"}),
		 # e_assign->new({lhs => "rldramii_ba_delayed", rhs => "rldramii_ba_0"}),
		 # e_assign->new({lhs => "rldramii_cs_n_delayed", rhs => "rldramii_cs_n_0"}),
		 # e_assign->new({lhs => "rldramii_we_n_delayed", rhs => "rldramii_we_n_0"}),
		 # e_assign->new({lhs => "rldramii_ref_n_delayed", rhs => "rldramii_ref_n_0"}),
		 e_assign->new({lhs => "rldramii_a", rhs => "rldramii_a_0", sim_delay => 1}),
		 e_assign->new({lhs => "rldramii_ba", rhs => "rldramii_ba_0", sim_delay => 1}),
		 e_assign->new({lhs => "rldramii_cs_n", rhs => "rldramii_cs_n_0", sim_delay => 1}),
		 e_assign->new({lhs => "rldramii_we_n", rhs => "rldramii_we_n_0", sim_delay => 1}),
		 e_assign->new({lhs => "rldramii_ref_n", rhs => "rldramii_ref_n_0", sim_delay => 1}),
	);
	
	if ($ddio_memory_clocks eq "false") {
		$module->add_contents
		(
			e_assign->new({lhs => "rldramii_clk_n", rhs => "~rldramii_clk"}),
		);
	}

	
#########################################################################################################################################################
#if ($USE_DENALI_MEMORY_MODELS eq "true") {
	$module->add_contents
	(
		e_signal->news #: ["signal", width, export, never_export]
		(	 
			["ZERO",1,	0,	1],
		),
		e_assign->new({lhs => "ZERO", rhs => "0"}),
	);
#}

#########################################################################################################################################################
if($enable_dm_pins eq "false") {
 	$module->add_contents
	(
		#e_signal->new({name => "DM_ZERO" , width => $MEM_NUM_DEVICES , export => 0, never_export => 1, declare_one_bit_as_std_logic_vector => }),
		#e_assign->new({lhs => "DM_ZERO", rhs => "0"}),
		#e_assign->new({lhs => "rldramii_dm", rhs => "DM_ZERO[".($MEM_NUM_DEVICES - 1).":0]"}),
		e_assign->new({lhs => "rldramii_dm[".($MEM_NUM_DEVICES - 1).":0]", rhs => "{".$MEM_NUM_DEVICES."{1'b0}}"}),
	);
} 
	
#########################################################################################################################################################
if (($MEM_DQ_PER_DQS == 16)  or ($MEM_DQ_PER_DQS == 18)) 
{
	$module->add_contents
	(
		e_signal->news #: ["signal", width, export, never_export]
		(	 
			#["dk_rldramii_clk",$NUM_CLOCK_PAIRS * 2,	0,	1],
			#["dk_rldramii_clk_n",$NUM_CLOCK_PAIRS * 2,	0,	1],
			["dk_rldramii_clk", 2,	0,	1],
			["dk_rldramii_clk_n", 2,	0,	1],
		),
	);
	
	for ($n = 0; $n < 2; $n++ ) 
	{
		$module->add_contents
		(
			e_assign->new({lhs => "dk_rldramii_clk[$n]", rhs => "rldramii_clk[0]"}),
			e_assign->new({lhs => "dk_rldramii_clk_n[$n]", rhs => "rldramii_clk_n[0]"}),
			# e_assign->new({lhs => "dk_rldramii_clk[$n * 2]", rhs => "rldramii_clk[$n]"}),
			# e_assign->new({lhs => "dk_rldramii_clk_n[$n * 2]", rhs => "rldramii_clk_n[$n]"}),
			# e_assign->new({lhs => "dk_rldramii_clk[($n * 2) + 1]", rhs => "rldramii_clk[$n]"}),
			# e_assign->new({lhs => "dk_rldramii_clk_n[($n * 2) + 1]", rhs => "rldramii_clk_n[$n]"}),
		);
	}
}

#########################################################################################################################################################
for (my $i=0; $i < $sig_num; $i+=2){
	$module->add_contents
	(
		e_signal->new({name => @sig_list[$i] , width => @width_list[$i+1] , export => 0, never_export => 1, declare_one_bit_as_std_logic_vector => 1}),
	);
}
		
#################################################################################################################################################################
	 
	if ($RLDRAMII_TYPE eq "cio") 
	{
		if ($ENABLE_CAPTURE_CLK eq "false") {
			if($enable_dm_pins eq "true") {
				if($num_addr_cmd_buses > 1) {
					if ($ddio_memory_clocks eq "true") {
						$module->add_contents
						(
							e_comment->new({comment => "Instantiate CIO RLDRAM II Controller Example Instance"}),
							e_blind_instance->new
							({
								name 		=> "dut",
								module 		=> $gTOPLEVEL_NAME,            
								comment 	=> "---------------------------------------------------------------------\n
								RLDRAM II Example Instance\n
								---------------------------------------------------------------------\n",
								in_port_map 	=>
								{
									clock_source => "clock_source",
									system_reset_n => "system_reset_n",
									$PREFIX_NAME."qvld" => "rldramii_qvld[".($MEM_NUM_DEVICES - 1).":0]",
								},
				
								out_port_map	=>
								{
									$PREFIX_NAME."clk" => "rldramii_clk[".($NUM_CLOCK_PAIRS - 1).":0]",
									$PREFIX_NAME."clk_n" => "rldramii_clk_n[".($NUM_CLOCK_PAIRS - 1).":0]",
									$PREFIX_NAME."cs_n_0" => "rldramii_cs_n_0",
									$PREFIX_NAME."we_n_0" => "rldramii_we_n_0",
									$PREFIX_NAME."ref_n_0" => "rldramii_ref_n_0",
									$PREFIX_NAME."cs_n_1" => "rldramii_cs_n_1",
									$PREFIX_NAME."we_n_1" => "rldramii_we_n_1",
									$PREFIX_NAME."ref_n_1" => "rldramii_ref_n_1",
									$PREFIX_NAME."a_0" => "rldramii_a_0",
									$PREFIX_NAME."ba_0" => "rldramii_ba_0",
									$PREFIX_NAME."a_1" => "rldramii_a_1",
									$PREFIX_NAME."ba_1" => "rldramii_ba_1",
									$PREFIX_NAME."dm" => "rldramii_dm[".($MEM_NUM_DEVICES - 1).":0]",
									test_complete => "test_complete",
									pnf_per_byte => "pnf_per_byte",
									pnf_persist => "pnf_persist",
								},
								
								inout_port_map	=>
								{
									$PREFIX_NAME."qk" => "rldramii_qk[".($NUMBER_DQS - 1).":0]",
									$PREFIX_NAME."dq" => "dq",					
								},
								
								 std_logic_vector_signals	=>
								 [
									 $PREFIX_NAME."clk", $PREFIX_NAME."clk_n", $PREFIX_NAME."dm",$PREFIX_NAME."qvld", $PREFIX_NAME."qk" 
								 ]
							}),
						),
					} else {
						$module->add_contents
						(
							e_comment->new({comment => "Instantiate CIO RLDRAM II Controller Example Instance"}),
							e_blind_instance->new
							({
								name 		=> "dut",
								module 		=> $gTOPLEVEL_NAME,            
								comment 	=> "---------------------------------------------------------------------\n
								RLDRAM II Example Instance\n
								---------------------------------------------------------------------\n",
								in_port_map 	=>
								{
									clock_source => "clock_source",
									system_reset_n => "system_reset_n",
									$PREFIX_NAME."qvld" => "rldramii_qvld[".($MEM_NUM_DEVICES - 1).":0]",
								},
				
								out_port_map	=>
								{
									$PREFIX_NAME."clk" => "rldramii_clk[".($NUM_CLOCK_PAIRS - 1).":0]",
									$PREFIX_NAME."cs_n_0" => "rldramii_cs_n_0",
									$PREFIX_NAME."we_n_0" => "rldramii_we_n_0",
									$PREFIX_NAME."ref_n_0" => "rldramii_ref_n_0",
									$PREFIX_NAME."cs_n_1" => "rldramii_cs_n_1",
									$PREFIX_NAME."we_n_1" => "rldramii_we_n_1",
									$PREFIX_NAME."ref_n_1" => "rldramii_ref_n_1",
									$PREFIX_NAME."a_0" => "rldramii_a_0",
									$PREFIX_NAME."ba_0" => "rldramii_ba_0",
									$PREFIX_NAME."a_1" => "rldramii_a_1",
									$PREFIX_NAME."ba_1" => "rldramii_ba_1",
									$PREFIX_NAME."dm" => "rldramii_dm[".($MEM_NUM_DEVICES - 1).":0]",
									test_complete => "test_complete",
									pnf_per_byte => "pnf_per_byte",
									pnf_persist => "pnf_persist",
								},
								
								inout_port_map	=>
								{
									$PREFIX_NAME."qk" => "rldramii_qk[".($NUMBER_DQS - 1).":0]",
									$PREFIX_NAME."dq" => "dq",					
								},
								
								 std_logic_vector_signals	=>
								 [
									 $PREFIX_NAME."clk", $PREFIX_NAME."dm",$PREFIX_NAME."qvld", $PREFIX_NAME."qk" 
								 ]
							}),
						),
					}
				} else {
					if ($ddio_memory_clocks eq "true") {
						$module->add_contents
						(
							e_comment->new({comment => "Instantiate CIO RLDRAM II Controller Example Instance"}),
							e_blind_instance->new
							({
								name 		=> "dut",
								module 		=> $gTOPLEVEL_NAME,            
								comment 	=> "---------------------------------------------------------------------\n
								RLDRAM II Example Instance\n
								---------------------------------------------------------------------\n",
								in_port_map 	=>
								{
									clock_source => "clock_source",
									system_reset_n => "system_reset_n",
									$PREFIX_NAME."qvld" => "rldramii_qvld[".($MEM_NUM_DEVICES - 1).":0]",
								},
				
								out_port_map	=>
								{
									$PREFIX_NAME."clk" => "rldramii_clk[".($NUM_CLOCK_PAIRS - 1).":0]",
									$PREFIX_NAME."clk_n" => "rldramii_clk_n[".($NUM_CLOCK_PAIRS - 1).":0]",
									$PREFIX_NAME."cs_n_0" => "rldramii_cs_n_0",
									$PREFIX_NAME."we_n_0" => "rldramii_we_n_0",
									$PREFIX_NAME."ref_n_0" => "rldramii_ref_n_0",
									$PREFIX_NAME."a_0" => "rldramii_a_0",
									$PREFIX_NAME."ba_0" => "rldramii_ba_0",
									$PREFIX_NAME."dm" => "rldramii_dm[".($MEM_NUM_DEVICES - 1).":0]",
									test_complete => "test_complete",
									pnf_per_byte => "pnf_per_byte",
									pnf_persist => "pnf_persist",
								},
								
								inout_port_map	=>
								{
									$PREFIX_NAME."qk" => "rldramii_qk[".($NUMBER_DQS - 1).":0]",
									$PREFIX_NAME."dq" => "dq",					
								},
								
								std_logic_vector_signals	=>
								[
									 $PREFIX_NAME."clk", $PREFIX_NAME."clk_n",  $PREFIX_NAME."dm",$PREFIX_NAME."qvld", $PREFIX_NAME."qk" 
								]
							}),
						),
					} else {
						$module->add_contents
						(
							e_comment->new({comment => "Instantiate CIO RLDRAM II Controller Example Instance"}),
							e_blind_instance->new
							({
								name 		=> "dut",
								module 		=> $gTOPLEVEL_NAME,            
								comment 	=> "---------------------------------------------------------------------\n
								RLDRAM II Example Instance\n
								---------------------------------------------------------------------\n",
								in_port_map 	=>
								{
									clock_source => "clock_source",
									system_reset_n => "system_reset_n",
									$PREFIX_NAME."qvld" => "rldramii_qvld[".($MEM_NUM_DEVICES - 1).":0]",
								},
				
								out_port_map	=>
								{
									$PREFIX_NAME."clk" => "rldramii_clk[".($NUM_CLOCK_PAIRS - 1).":0]",
									$PREFIX_NAME."cs_n_0" => "rldramii_cs_n_0",
									$PREFIX_NAME."we_n_0" => "rldramii_we_n_0",
									$PREFIX_NAME."ref_n_0" => "rldramii_ref_n_0",
									$PREFIX_NAME."a_0" => "rldramii_a_0",
									$PREFIX_NAME."ba_0" => "rldramii_ba_0",
									$PREFIX_NAME."dm" => "rldramii_dm[".($MEM_NUM_DEVICES - 1).":0]",
									test_complete => "test_complete",
									pnf_per_byte => "pnf_per_byte",
									pnf_persist => "pnf_persist",
								},
								
								inout_port_map	=>
								{
									$PREFIX_NAME."qk" => "rldramii_qk[".($NUMBER_DQS - 1).":0]",
									$PREFIX_NAME."dq" => "dq",					
								},
								
								std_logic_vector_signals	=>
								[
									 $PREFIX_NAME."clk", $PREFIX_NAME."dm",$PREFIX_NAME."qvld", $PREFIX_NAME."qk" 
								]
							}),
						),
					}
				}
			} else {
				if($num_addr_cmd_buses > 1) {
					if ($ddio_memory_clocks eq "true") {
						$module->add_contents
						(
							e_comment->new({comment => "Instantiate CIO RLDRAM II Controller Example Instance"}),
							e_blind_instance->new
							({
								name 		=> "dut",
								module 		=> $gTOPLEVEL_NAME,            
								comment 	=> "---------------------------------------------------------------------\n
								RLDRAM II Example Instance\n
								---------------------------------------------------------------------\n",
								in_port_map 	=>
								{
									clock_source => "clock_source",
									system_reset_n => "system_reset_n",
									$PREFIX_NAME."qvld" => "rldramii_qvld[".($MEM_NUM_DEVICES - 1).":0]",
								},
				
								out_port_map	=>
								{
									$PREFIX_NAME."clk" => "rldramii_clk[".($NUM_CLOCK_PAIRS - 1).":0]",
									$PREFIX_NAME."clk_n" => "rldramii_clk_n[".($NUM_CLOCK_PAIRS - 1).":0]",
									$PREFIX_NAME."cs_n_0" => "rldramii_cs_n_0",
									$PREFIX_NAME."we_n_0" => "rldramii_we_n_0",
									$PREFIX_NAME."ref_n_0" => "rldramii_ref_n_0",
									$PREFIX_NAME."cs_n_1" => "rldramii_cs_n_1",
									$PREFIX_NAME."we_n_1" => "rldramii_we_n_1",
									$PREFIX_NAME."ref_n_1" => "rldramii_ref_n_1",
									$PREFIX_NAME."a_0" => "rldramii_a_0",
									$PREFIX_NAME."ba_0" => "rldramii_ba_0",
									$PREFIX_NAME."a_1" => "rldramii_a_1",
									$PREFIX_NAME."ba_1" => "rldramii_ba_1",
									#$PREFIX_NAME."dm" => "rldramii_dm",
									test_complete => "test_complete",
									pnf_per_byte => "pnf_per_byte",
									pnf_persist => "pnf_persist",
								},
								
								inout_port_map	=>
								{
									$PREFIX_NAME."qk" => "rldramii_qk[".($NUMBER_DQS - 1).":0]",
									$PREFIX_NAME."dq" => "dq",					
								},
								
								 std_logic_vector_signals	=>
								 [
									 $PREFIX_NAME."clk", $PREFIX_NAME."clk_n", $PREFIX_NAME."qvld", $PREFIX_NAME."qk" 
								 ]
							}),
						),
					} else {
						$module->add_contents
						(
							e_comment->new({comment => "Instantiate CIO RLDRAM II Controller Example Instance"}),
							e_blind_instance->new
							({
								name 		=> "dut",
								module 		=> $gTOPLEVEL_NAME,            
								comment 	=> "---------------------------------------------------------------------\n
								RLDRAM II Example Instance\n
								---------------------------------------------------------------------\n",
								in_port_map 	=>
								{
									clock_source => "clock_source",
									system_reset_n => "system_reset_n",
									$PREFIX_NAME."qvld" => "rldramii_qvld[".($MEM_NUM_DEVICES - 1).":0]",
								},
				
								out_port_map	=>
								{
									$PREFIX_NAME."clk" => "rldramii_clk[".($NUM_CLOCK_PAIRS - 1).":0]",
									$PREFIX_NAME."cs_n_0" => "rldramii_cs_n_0",
									$PREFIX_NAME."we_n_0" => "rldramii_we_n_0",
									$PREFIX_NAME."ref_n_0" => "rldramii_ref_n_0",
									$PREFIX_NAME."cs_n_1" => "rldramii_cs_n_1",
									$PREFIX_NAME."we_n_1" => "rldramii_we_n_1",
									$PREFIX_NAME."ref_n_1" => "rldramii_ref_n_1",
									$PREFIX_NAME."a_0" => "rldramii_a_0",
									$PREFIX_NAME."ba_0" => "rldramii_ba_0",
									$PREFIX_NAME."a_1" => "rldramii_a_1",
									$PREFIX_NAME."ba_1" => "rldramii_ba_1",
									#$PREFIX_NAME."dm" => "rldramii_dm",
									test_complete => "test_complete",
									pnf_per_byte => "pnf_per_byte",
									pnf_persist => "pnf_persist",
								},
								
								inout_port_map	=>
								{
									$PREFIX_NAME."qk" => "rldramii_qk[".($NUMBER_DQS - 1).":0]",
									$PREFIX_NAME."dq" => "dq",					
								},
								
								 std_logic_vector_signals	=>
								 [
									 $PREFIX_NAME."clk", $PREFIX_NAME."qvld", $PREFIX_NAME."qk" 
								 ]
							}),
						),
					}
				} else {
					if ($ddio_memory_clocks eq "true") {
						$module->add_contents
						(
							e_comment->new({comment => "Instantiate CIO RLDRAM II Controller Example Instance"}),
							e_blind_instance->new
							({
								name 		=> "dut",
								module 		=> $gTOPLEVEL_NAME,            
								comment 	=> "---------------------------------------------------------------------\n
								RLDRAM II Example Instance\n
								---------------------------------------------------------------------\n",
								in_port_map 	=>
								{
									clock_source => "clock_source",
									system_reset_n => "system_reset_n",
									$PREFIX_NAME."qvld" => "rldramii_qvld[".($MEM_NUM_DEVICES - 1).":0]",
								},
				
								out_port_map	=>
								{
									$PREFIX_NAME."clk" => "rldramii_clk[".($NUM_CLOCK_PAIRS - 1).":0]",
									$PREFIX_NAME."clk_n" => "rldramii_clk_n[".($NUM_CLOCK_PAIRS - 1).":0]",
									$PREFIX_NAME."cs_n_0" => "rldramii_cs_n_0",
									$PREFIX_NAME."we_n_0" => "rldramii_we_n_0",
									$PREFIX_NAME."ref_n_0" => "rldramii_ref_n_0",
									$PREFIX_NAME."a_0" => "rldramii_a_0",
									$PREFIX_NAME."ba_0" => "rldramii_ba_0",
									#$PREFIX_NAME."dm" => "rldramii_dm",
									test_complete => "test_complete",
									pnf_per_byte => "pnf_per_byte",
									pnf_persist => "pnf_persist",
								},
								
								inout_port_map	=>
								{
									$PREFIX_NAME."qk" => "rldramii_qk[".($NUMBER_DQS - 1).":0]",
									$PREFIX_NAME."dq" => "dq",					
								},
								
								 std_logic_vector_signals	=>
								 [
									 $PREFIX_NAME."clk", $PREFIX_NAME."clk_n", $PREFIX_NAME."qvld", $PREFIX_NAME."qk" 
								 ]
							}),
						),
					} else {
						$module->add_contents
						(
							e_comment->new({comment => "Instantiate CIO RLDRAM II Controller Example Instance"}),
							e_blind_instance->new
							({
								name 		=> "dut",
								module 		=> $gTOPLEVEL_NAME,            
								comment 	=> "---------------------------------------------------------------------\n
								RLDRAM II Example Instance\n
								---------------------------------------------------------------------\n",
								in_port_map 	=>
								{
									clock_source => "clock_source",
									system_reset_n => "system_reset_n",
									$PREFIX_NAME."qvld" => "rldramii_qvld[".($MEM_NUM_DEVICES - 1).":0]",
								},
				
								out_port_map	=>
								{
									$PREFIX_NAME."clk" => "rldramii_clk[".($NUM_CLOCK_PAIRS - 1).":0]",
									$PREFIX_NAME."cs_n_0" => "rldramii_cs_n_0",
									$PREFIX_NAME."we_n_0" => "rldramii_we_n_0",
									$PREFIX_NAME."ref_n_0" => "rldramii_ref_n_0",
									$PREFIX_NAME."a_0" => "rldramii_a_0",
									$PREFIX_NAME."ba_0" => "rldramii_ba_0",
									#$PREFIX_NAME."dm" => "rldramii_dm",
									test_complete => "test_complete",
									pnf_per_byte => "pnf_per_byte",
									pnf_persist => "pnf_persist",
								},
								
								inout_port_map	=>
								{
									$PREFIX_NAME."qk" => "rldramii_qk[".($NUMBER_DQS - 1).":0]",
									$PREFIX_NAME."dq" => "dq",					
								},
								
								 std_logic_vector_signals	=>
								 [
									 $PREFIX_NAME."clk", $PREFIX_NAME."qvld", $PREFIX_NAME."qk" 
								 ]
							}),
						),
					}
				}
			}
		}
		else {
			if($enable_dm_pins eq "true") {
				if($num_addr_cmd_buses > 1) {
					if ($ddio_memory_clocks eq "true") {
						$module->add_contents
						(
							e_comment->new({comment => "Instantiate CIO RLDRAM II Controller Example Instance"}),
							e_blind_instance->new
							({
								name 		=> "dut",
								module 		=> $gTOPLEVEL_NAME,            
								comment 	=> "---------------------------------------------------------------------\n
								RLDRAM II Example Instance\n
								---------------------------------------------------------------------\n",
								in_port_map 	=>
								{
									clock_source => "clock_source",
									system_reset_n => "system_reset_n",
									$PREFIX_NAME."fb_clk_in" => "rldramii_qk[0]",
									$PREFIX_NAME."qvld" => "rldramii_qvld[".($MEM_NUM_DEVICES - 1).":0]",
								},
				
								out_port_map	=>
								{
									$PREFIX_NAME."clk" => "rldramii_clk[".($NUM_CLOCK_PAIRS - 1).":0]",
									$PREFIX_NAME."clk_n" => "rldramii_clk_n[".($NUM_CLOCK_PAIRS - 1).":0]",
									$PREFIX_NAME."cs_n_0" => "rldramii_cs_n_0",
									$PREFIX_NAME."we_n_0" => "rldramii_we_n_0",
									$PREFIX_NAME."ref_n_0" => "rldramii_ref_n_0",
									$PREFIX_NAME."cs_n_1" => "rldramii_cs_n_1",
									$PREFIX_NAME."we_n_1" => "rldramii_we_n_1",
									$PREFIX_NAME."ref_n_1" => "rldramii_ref_n_1",
									$PREFIX_NAME."a_0" => "rldramii_a_0",
									$PREFIX_NAME."ba_0" => "rldramii_ba_0",
									$PREFIX_NAME."a_1" => "rldramii_a_1",
									$PREFIX_NAME."ba_1" => "rldramii_ba_1",
									$PREFIX_NAME."dm" => "rldramii_dm[".($MEM_NUM_DEVICES - 1).":0]",
									test_complete => "test_complete",
									pnf_per_byte => "pnf_per_byte",
									pnf_persist => "pnf_persist",
								},
								
								inout_port_map	=>
								{
									$PREFIX_NAME."dq" => "dq",					
								},
								
								 std_logic_vector_signals	=>
								 [
									 $PREFIX_NAME."clk", $PREFIX_NAME."clk_n",  $PREFIX_NAME."dm", $PREFIX_NAME."qvld", $PREFIX_NAME."qk" 
								 ]
							}),
						),
					} else {
						$module->add_contents
						(
							e_comment->new({comment => "Instantiate CIO RLDRAM II Controller Example Instance"}),
							e_blind_instance->new
							({
								name 		=> "dut",
								module 		=> $gTOPLEVEL_NAME,            
								comment 	=> "---------------------------------------------------------------------\n
								RLDRAM II Example Instance\n
								---------------------------------------------------------------------\n",
								in_port_map 	=>
								{
									clock_source => "clock_source",
									system_reset_n => "system_reset_n",
									$PREFIX_NAME."fb_clk_in" => "rldramii_qk[0]",
									$PREFIX_NAME."qvld" => "rldramii_qvld[".($MEM_NUM_DEVICES - 1).":0]",
								},
				
								out_port_map	=>
								{
									$PREFIX_NAME."clk" => "rldramii_clk[".($NUM_CLOCK_PAIRS - 1).":0]",
									$PREFIX_NAME."cs_n_0" => "rldramii_cs_n_0",
									$PREFIX_NAME."we_n_0" => "rldramii_we_n_0",
									$PREFIX_NAME."ref_n_0" => "rldramii_ref_n_0",
									$PREFIX_NAME."cs_n_1" => "rldramii_cs_n_1",
									$PREFIX_NAME."we_n_1" => "rldramii_we_n_1",
									$PREFIX_NAME."ref_n_1" => "rldramii_ref_n_1",
									$PREFIX_NAME."a_0" => "rldramii_a_0",
									$PREFIX_NAME."ba_0" => "rldramii_ba_0",
									$PREFIX_NAME."a_1" => "rldramii_a_1",
									$PREFIX_NAME."ba_1" => "rldramii_ba_1",
									$PREFIX_NAME."dm" => "rldramii_dm[".($MEM_NUM_DEVICES - 1).":0]",
									test_complete => "test_complete",
									pnf_per_byte => "pnf_per_byte",
									pnf_persist => "pnf_persist",
								},
								
								inout_port_map	=>
								{
									$PREFIX_NAME."dq" => "dq",					
								},
								
								 std_logic_vector_signals	=>
								 [
									 $PREFIX_NAME."clk",  $PREFIX_NAME."dm", $PREFIX_NAME."qvld", $PREFIX_NAME."qk" 
								 ]
							}),
						),
					}
				} else {
					if ($ddio_memory_clocks eq "true") {
						$module->add_contents
						(
							e_comment->new({comment => "Instantiate CIO RLDRAM II Controller Example Instance"}),
							e_blind_instance->new
							({
								name 		=> "dut",
								module 		=> $gTOPLEVEL_NAME,            
								comment 	=> "---------------------------------------------------------------------\n
								RLDRAM II Example Instance\n
								---------------------------------------------------------------------\n",
								in_port_map 	=>
								{
									clock_source => "clock_source",
									system_reset_n => "system_reset_n",
									$PREFIX_NAME."fb_clk_in" => "rldramii_qk[0]",
									$PREFIX_NAME."qvld" => "rldramii_qvld[".($MEM_NUM_DEVICES - 1).":0]",
								},
				
								out_port_map	=>
								{
									$PREFIX_NAME."clk" => "rldramii_clk[".($NUM_CLOCK_PAIRS - 1).":0]",
									$PREFIX_NAME."clk_n" => "rldramii_clk_n[".($NUM_CLOCK_PAIRS - 1).":0]",
									$PREFIX_NAME."cs_n_0" => "rldramii_cs_n_0",
									$PREFIX_NAME."we_n_0" => "rldramii_we_n_0",
									$PREFIX_NAME."ref_n_0" => "rldramii_ref_n_0",
									$PREFIX_NAME."a_0" => "rldramii_a_0",
									$PREFIX_NAME."ba_0" => "rldramii_ba_0",
									$PREFIX_NAME."dm" => "rldramii_dm[".($MEM_NUM_DEVICES - 1).":0]",
									test_complete => "test_complete",
									pnf_per_byte => "pnf_per_byte",
									pnf_persist => "pnf_persist",
								},
								
								inout_port_map	=>
								{
									$PREFIX_NAME."dq" => "dq",					
								},
								
								 std_logic_vector_signals	=>
								 [
									 $PREFIX_NAME."clk", $PREFIX_NAME."clk_n",  $PREFIX_NAME."dm",$PREFIX_NAME."qvld", $PREFIX_NAME."qk" 
								 ]
							}),
						),
					} else {
						$module->add_contents
						(
							e_comment->new({comment => "Instantiate CIO RLDRAM II Controller Example Instance"}),
							e_blind_instance->new
							({
								name 		=> "dut",
								module 		=> $gTOPLEVEL_NAME,            
								comment 	=> "---------------------------------------------------------------------\n
								RLDRAM II Example Instance\n
								---------------------------------------------------------------------\n",
								in_port_map 	=>
								{
									clock_source => "clock_source",
									system_reset_n => "system_reset_n",
									$PREFIX_NAME."fb_clk_in" => "rldramii_qk[0]",
									$PREFIX_NAME."qvld" => "rldramii_qvld[".($MEM_NUM_DEVICES - 1).":0]",
								},
				
								out_port_map	=>
								{
									$PREFIX_NAME."clk" => "rldramii_clk[".($NUM_CLOCK_PAIRS - 1).":0]",
									#$PREFIX_NAME."clk_n" => "rldramii_clk_n[".($NUM_CLOCK_PAIRS - 1).":0]",
									$PREFIX_NAME."cs_n_0" => "rldramii_cs_n_0",
									$PREFIX_NAME."we_n_0" => "rldramii_we_n_0",
									$PREFIX_NAME."ref_n_0" => "rldramii_ref_n_0",
									$PREFIX_NAME."a_0" => "rldramii_a_0",
									$PREFIX_NAME."ba_0" => "rldramii_ba_0",
									$PREFIX_NAME."dm" => "rldramii_dm[".($MEM_NUM_DEVICES - 1).":0]",
									test_complete => "test_complete",
									pnf_per_byte => "pnf_per_byte",
									pnf_persist => "pnf_persist",
								},
								
								inout_port_map	=>
								{
									$PREFIX_NAME."dq" => "dq",					
								},
								
								 std_logic_vector_signals	=>
								 [
									 $PREFIX_NAME."clk", $PREFIX_NAME."clk_n",  $PREFIX_NAME."dm",$PREFIX_NAME."qvld", $PREFIX_NAME."qk" 
								 ]
							}),
						),
					}
				}
			} else {
				if($num_addr_cmd_buses > 1) {
					if ($ddio_memory_clocks eq "true") {
						$module->add_contents
						(
							e_comment->new({comment => "Instantiate CIO RLDRAM II Controller Example Instance"}),
							e_blind_instance->new
							({
								name 		=> "dut",
								module 		=> $gTOPLEVEL_NAME,            
								comment 	=> "---------------------------------------------------------------------\n
								RLDRAM II Example Instance\n
								---------------------------------------------------------------------\n",
								in_port_map 	=>
								{
									clock_source => "clock_source",
									system_reset_n => "system_reset_n",
									$PREFIX_NAME."fb_clk_in" => "rldramii_qk[0]",
									$PREFIX_NAME."qvld" => "rldramii_qvld[".($MEM_NUM_DEVICES - 1).":0]",
								},
				
								out_port_map	=>
								{
									$PREFIX_NAME."clk" => "rldramii_clk[".($NUM_CLOCK_PAIRS - 1).":0]",
									$PREFIX_NAME."clk_n" => "rldramii_clk_n[".($NUM_CLOCK_PAIRS - 1).":0]",
									$PREFIX_NAME."cs_n_0" => "rldramii_cs_n_0",
									$PREFIX_NAME."we_n_0" => "rldramii_we_n_0",
									$PREFIX_NAME."ref_n_0" => "rldramii_ref_n_0",
									$PREFIX_NAME."cs_n_1" => "rldramii_cs_n_1",
									$PREFIX_NAME."we_n_1" => "rldramii_we_n_1",
									$PREFIX_NAME."ref_n_1" => "rldramii_ref_n_1",
									$PREFIX_NAME."a_0" => "rldramii_a_0",
									$PREFIX_NAME."ba_0" => "rldramii_ba_0",
									$PREFIX_NAME."a_1" => "rldramii_a_1",
									$PREFIX_NAME."ba_1" => "rldramii_ba_1",
									#$PREFIX_NAME."dm" => "rldramii_dm",
									test_complete => "test_complete",
									pnf_per_byte => "pnf_per_byte",
									pnf_persist => "pnf_persist",
								},
								
								inout_port_map	=>
								{
									$PREFIX_NAME."dq" => "dq",					
								},
								
								 std_logic_vector_signals	=>
								 [
									 $PREFIX_NAME."clk", $PREFIX_NAME."clk_n", $PREFIX_NAME."qvld", $PREFIX_NAME."qk" 
								 ]
							}),
						),
					} else {
						$module->add_contents
						(
							e_comment->new({comment => "Instantiate CIO RLDRAM II Controller Example Instance"}),
							e_blind_instance->new
							({
								name 		=> "dut",
								module 		=> $gTOPLEVEL_NAME,            
								comment 	=> "---------------------------------------------------------------------\n
								RLDRAM II Example Instance\n
								---------------------------------------------------------------------\n",
								in_port_map 	=>
								{
									clock_source => "clock_source",
									system_reset_n => "system_reset_n",
									$PREFIX_NAME."fb_clk_in" => "rldramii_qk[0]",
									$PREFIX_NAME."qvld" => "rldramii_qvld[".($MEM_NUM_DEVICES - 1).":0]",
								},
				
								out_port_map	=>
								{
									$PREFIX_NAME."clk" => "rldramii_clk[".($NUM_CLOCK_PAIRS - 1).":0]",
									$PREFIX_NAME."cs_n_0" => "rldramii_cs_n_0",
									$PREFIX_NAME."we_n_0" => "rldramii_we_n_0",
									$PREFIX_NAME."ref_n_0" => "rldramii_ref_n_0",
									$PREFIX_NAME."cs_n_1" => "rldramii_cs_n_1",
									$PREFIX_NAME."we_n_1" => "rldramii_we_n_1",
									$PREFIX_NAME."ref_n_1" => "rldramii_ref_n_1",
									$PREFIX_NAME."a_0" => "rldramii_a_0",
									$PREFIX_NAME."ba_0" => "rldramii_ba_0",
									$PREFIX_NAME."a_1" => "rldramii_a_1",
									$PREFIX_NAME."ba_1" => "rldramii_ba_1",
									#$PREFIX_NAME."dm" => "rldramii_dm",
									test_complete => "test_complete",
									pnf_per_byte => "pnf_per_byte",
									pnf_persist => "pnf_persist",
								},
								
								inout_port_map	=>
								{
									$PREFIX_NAME."dq" => "dq",					
								},
								
								 std_logic_vector_signals	=>
								 [
									 $PREFIX_NAME."clk", $PREFIX_NAME."qvld", $PREFIX_NAME."qk" 
								 ]
							}),
						),
					}
				} else {
					if ($ddio_memory_clocks eq "true") {
						$module->add_contents
						(
							e_comment->new({comment => "Instantiate CIO RLDRAM II Controller Example Instance"}),
							e_blind_instance->new
							({
								name 		=> "dut",
								module 		=> $gTOPLEVEL_NAME,            
								comment 	=> "---------------------------------------------------------------------\n
								RLDRAM II Example Instance\n
								---------------------------------------------------------------------\n",
								in_port_map 	=>
								{
									clock_source => "clock_source",
									system_reset_n => "system_reset_n",
									$PREFIX_NAME."fb_clk_in" => "rldramii_qk[0]",
									$PREFIX_NAME."qvld" => "rldramii_qvld[".($MEM_NUM_DEVICES - 1).":0]",
								},
				
								out_port_map	=>
								{
									$PREFIX_NAME."clk" => "rldramii_clk[".($NUM_CLOCK_PAIRS - 1).":0]",
									$PREFIX_NAME."clk_n" => "rldramii_clk_n[".($NUM_CLOCK_PAIRS - 1).":0]",
									$PREFIX_NAME."cs_n_0" => "rldramii_cs_n_0",
									$PREFIX_NAME."we_n_0" => "rldramii_we_n_0",
									$PREFIX_NAME."ref_n_0" => "rldramii_ref_n_0",
									$PREFIX_NAME."a_0" => "rldramii_a_0",
									$PREFIX_NAME."ba_0" => "rldramii_ba_0",
									#$PREFIX_NAME."dm" => "rldramii_dm",
									test_complete => "test_complete",
									pnf_per_byte => "pnf_per_byte",
									pnf_persist => "pnf_persist",
								},
								
								inout_port_map	=>
								{
									$PREFIX_NAME."dq" => "dq",					
								},
								
								 std_logic_vector_signals	=>
								 [
									 $PREFIX_NAME."clk", $PREFIX_NAME."clk_n", $PREFIX_NAME."qvld", $PREFIX_NAME."qk" 
								 ]
							}),
						),
					} else {
						$module->add_contents
						(
							e_comment->new({comment => "Instantiate CIO RLDRAM II Controller Example Instance"}),
							e_blind_instance->new
							({
								name 		=> "dut",
								module 		=> $gTOPLEVEL_NAME,            
								comment 	=> "---------------------------------------------------------------------\n
								RLDRAM II Example Instance\n
								---------------------------------------------------------------------\n",
								in_port_map 	=>
								{
									clock_source => "clock_source",
									system_reset_n => "system_reset_n",
									$PREFIX_NAME."fb_clk_in" => "rldramii_qk[0]",
									$PREFIX_NAME."qvld" => "rldramii_qvld[".($MEM_NUM_DEVICES - 1).":0]",
								},
				
								out_port_map	=>
								{
									$PREFIX_NAME."clk" => "rldramii_clk[".($NUM_CLOCK_PAIRS - 1).":0]",
									$PREFIX_NAME."cs_n_0" => "rldramii_cs_n_0",
									$PREFIX_NAME."we_n_0" => "rldramii_we_n_0",
									$PREFIX_NAME."ref_n_0" => "rldramii_ref_n_0",
									$PREFIX_NAME."a_0" => "rldramii_a_0",
									$PREFIX_NAME."ba_0" => "rldramii_ba_0",
									#$PREFIX_NAME."dm" => "rldramii_dm",
									test_complete => "test_complete",
									pnf_per_byte => "pnf_per_byte",
									pnf_persist => "pnf_persist",
								},
								
								inout_port_map	=>
								{
									$PREFIX_NAME."dq" => "dq",					
								},
								
								 std_logic_vector_signals	=>
								 [
									 $PREFIX_NAME."clk", $PREFIX_NAME."qvld", $PREFIX_NAME."qk" 
								 ]
							}),
						),
					
					}
				}
			}
		}
	}
	else
	{
		if ($ENABLE_CAPTURE_CLK eq "false") {
			if($enable_dm_pins eq "true") {
				if($num_addr_cmd_buses > 1) {
					if ($ddio_memory_clocks eq "true") {
						$module->add_contents
						(
							e_comment->new({comment => "Instantiate SIO RLDRAM II Controller Example Instance"}),
							e_blind_instance->new
							({
								name 		=> "dut",
								module 		=> $gTOPLEVEL_NAME,            
								comment 	=> "---------------------------------------------------------------------\n
								RLDRAM II Example Instance\n
								---------------------------------------------------------------------\n",
								in_port_map 	=>
								{
									clock_source => "clock_source",
									system_reset_n => "system_reset_n",
									$PREFIX_NAME."q" => "rldramii_q",
									$PREFIX_NAME."qvld" => "rldramii_qvld[".($MEM_NUM_DEVICES - 1).":0]",
								},
				
								out_port_map	=>
								{
									$PREFIX_NAME."clk" => "rldramii_clk[".($NUM_CLOCK_PAIRS - 1).":0]",
									$PREFIX_NAME."clk_n" => "rldramii_clk_n[".($NUM_CLOCK_PAIRS - 1).":0]",
									$PREFIX_NAME."cs_n_0" => "rldramii_cs_n_0",
									$PREFIX_NAME."we_n_0" => "rldramii_we_n_0",
									$PREFIX_NAME."ref_n_0" => "rldramii_ref_n_0",
									$PREFIX_NAME."cs_n_1" => "rldramii_cs_n_1",
									$PREFIX_NAME."we_n_1" => "rldramii_we_n_1",
									$PREFIX_NAME."ref_n_1" => "rldramii_ref_n_1",
									$PREFIX_NAME."a_0" => "rldramii_a_0",
									$PREFIX_NAME."ba_0" => "rldramii_ba_0",
									$PREFIX_NAME."a_1" => "rldramii_a_1",
									$PREFIX_NAME."ba_1" => "rldramii_ba_1",
									$PREFIX_NAME."dm" => "rldramii_dm[".($MEM_NUM_DEVICES - 1).":0]",
									$PREFIX_NAME."d" => "rldramii_d",
									test_complete => "test_complete",
									pnf_per_byte => "pnf_per_byte",
									pnf_persist => "pnf_persist",
								},
								
								inout_port_map	=>
								{
									$PREFIX_NAME."qk" => "rldramii_qk[".($NUMBER_DQS - 1).":0]",
								},
								
								 std_logic_vector_signals	=>
								 [
									 $PREFIX_NAME."clk", $PREFIX_NAME."clk_n",  $PREFIX_NAME."dm",$PREFIX_NAME."qvld", $PREFIX_NAME."qk" 
								 ]
							}),
						),
					} else {
						$module->add_contents
						(
							e_comment->new({comment => "Instantiate SIO RLDRAM II Controller Example Instance"}),
							e_blind_instance->new
							({
								name 		=> "dut",
								module 		=> $gTOPLEVEL_NAME,            
								comment 	=> "---------------------------------------------------------------------\n
								RLDRAM II Example Instance\n
								---------------------------------------------------------------------\n",
								in_port_map 	=>
								{
									clock_source => "clock_source",
									system_reset_n => "system_reset_n",
									$PREFIX_NAME."q" => "rldramii_q",
									$PREFIX_NAME."qvld" => "rldramii_qvld[".($MEM_NUM_DEVICES - 1).":0]",
								},
				
								out_port_map	=>
								{
									$PREFIX_NAME."clk" => "rldramii_clk[".($NUM_CLOCK_PAIRS - 1).":0]",
									$PREFIX_NAME."cs_n_0" => "rldramii_cs_n_0",
									$PREFIX_NAME."we_n_0" => "rldramii_we_n_0",
									$PREFIX_NAME."ref_n_0" => "rldramii_ref_n_0",
									$PREFIX_NAME."cs_n_1" => "rldramii_cs_n_1",
									$PREFIX_NAME."we_n_1" => "rldramii_we_n_1",
									$PREFIX_NAME."ref_n_1" => "rldramii_ref_n_1",
									$PREFIX_NAME."a_0" => "rldramii_a_0",
									$PREFIX_NAME."ba_0" => "rldramii_ba_0",
									$PREFIX_NAME."a_1" => "rldramii_a_1",
									$PREFIX_NAME."ba_1" => "rldramii_ba_1",
									$PREFIX_NAME."dm" => "rldramii_dm[".($MEM_NUM_DEVICES - 1).":0]",
									$PREFIX_NAME."d" => "rldramii_d",
									test_complete => "test_complete",
									pnf_per_byte => "pnf_per_byte",
									pnf_persist => "pnf_persist",
								},
								
								inout_port_map	=>
								{
									$PREFIX_NAME."qk" => "rldramii_qk[".($NUMBER_DQS - 1).":0]",
								},
								
								 std_logic_vector_signals	=>
								 [
									 $PREFIX_NAME."clk", $PREFIX_NAME."dm",$PREFIX_NAME."qvld", $PREFIX_NAME."qk" 
								 ]
							}),
						),
					}
				} else {
					if ($ddio_memory_clocks eq "true") {
						$module->add_contents
						(
							e_comment->new({comment => "Instantiate SIO RLDRAM II Controller Example Instance"}),
							e_blind_instance->new
							({
								name 		=> "dut",
								module 		=> $gTOPLEVEL_NAME,            
								comment 	=> "---------------------------------------------------------------------\n
								RLDRAM II Example Instance\n
								---------------------------------------------------------------------\n",
								in_port_map 	=>
								{
									clock_source => "clock_source",
									system_reset_n => "system_reset_n",
									$PREFIX_NAME."q" => "rldramii_q",
									$PREFIX_NAME."qvld" => "rldramii_qvld[".($MEM_NUM_DEVICES - 1).":0]",
								},
				
								out_port_map	=>
								{
									$PREFIX_NAME."clk" => "rldramii_clk[".($NUM_CLOCK_PAIRS - 1).":0]",
									$PREFIX_NAME."clk_n" => "rldramii_clk_n[".($NUM_CLOCK_PAIRS - 1).":0]",
									$PREFIX_NAME."cs_n_0" => "rldramii_cs_n_0",
									$PREFIX_NAME."we_n_0" => "rldramii_we_n_0",
									$PREFIX_NAME."ref_n_0" => "rldramii_ref_n_0",
									$PREFIX_NAME."a_0" => "rldramii_a_0",
									$PREFIX_NAME."ba_0" => "rldramii_ba_0",
									$PREFIX_NAME."dm" => "rldramii_dm[".($MEM_NUM_DEVICES - 1).":0]",
									$PREFIX_NAME."d" => "rldramii_d",
									test_complete => "test_complete",
									pnf_per_byte => "pnf_per_byte",
									pnf_persist => "pnf_persist",
								},
								
								inout_port_map	=>
								{
									$PREFIX_NAME."qk" => "rldramii_qk[".($NUMBER_DQS - 1).":0]",
								},
								
								 std_logic_vector_signals	=>
								 [
									 $PREFIX_NAME."clk", $PREFIX_NAME."clk_n",  $PREFIX_NAME."dm",$PREFIX_NAME."qvld", $PREFIX_NAME."qk" 
								 ]
							}),
						),
					} else {
						$module->add_contents
						(
							e_comment->new({comment => "Instantiate SIO RLDRAM II Controller Example Instance"}),
							e_blind_instance->new
							({
								name 		=> "dut",
								module 		=> $gTOPLEVEL_NAME,            
								comment 	=> "---------------------------------------------------------------------\n
								RLDRAM II Example Instance\n
								---------------------------------------------------------------------\n",
								in_port_map 	=>
								{
									clock_source => "clock_source",
									system_reset_n => "system_reset_n",
									$PREFIX_NAME."q" => "rldramii_q",
									$PREFIX_NAME."qvld" => "rldramii_qvld[".($MEM_NUM_DEVICES - 1).":0]",
								},
				
								out_port_map	=>
								{
									$PREFIX_NAME."clk" => "rldramii_clk[".($NUM_CLOCK_PAIRS - 1).":0]",
									$PREFIX_NAME."cs_n_0" => "rldramii_cs_n_0",
									$PREFIX_NAME."we_n_0" => "rldramii_we_n_0",
									$PREFIX_NAME."ref_n_0" => "rldramii_ref_n_0",
									$PREFIX_NAME."a_0" => "rldramii_a_0",
									$PREFIX_NAME."ba_0" => "rldramii_ba_0",
									$PREFIX_NAME."dm" => "rldramii_dm[".($MEM_NUM_DEVICES - 1).":0]",
									$PREFIX_NAME."d" => "rldramii_d",
									test_complete => "test_complete",
									pnf_per_byte => "pnf_per_byte",
									pnf_persist => "pnf_persist",
								},
								
								inout_port_map	=>
								{
									$PREFIX_NAME."qk" => "rldramii_qk[".($NUMBER_DQS - 1).":0]",
								},
								
								 std_logic_vector_signals	=>
								 [
									 $PREFIX_NAME."clk",  $PREFIX_NAME."dm",$PREFIX_NAME."qvld", $PREFIX_NAME."qk" 
								 ]
							}),
						),
					}
				}
			} else {
				if($num_addr_cmd_buses > 1) {
					if ($ddio_memory_clocks eq "true") {
						$module->add_contents
						(
							e_comment->new({comment => "Instantiate SIO RLDRAM II Controller Example Instance"}),
							e_blind_instance->new
							({
								name 		=> "dut",
								module 		=> $gTOPLEVEL_NAME,            
								comment 	=> "---------------------------------------------------------------------\n
								RLDRAM II Example Instance\n
								---------------------------------------------------------------------\n",
								in_port_map 	=>
								{
									clock_source => "clock_source",
									system_reset_n => "system_reset_n",
									$PREFIX_NAME."q" => "rldramii_q",
									$PREFIX_NAME."qvld" => "rldramii_qvld[".($MEM_NUM_DEVICES - 1).":0]",
								},
				
								out_port_map	=>
								{
									$PREFIX_NAME."clk" => "rldramii_clk[".($NUM_CLOCK_PAIRS - 1).":0]",
									$PREFIX_NAME."clk_n" => "rldramii_clk_n[".($NUM_CLOCK_PAIRS - 1).":0]",
									$PREFIX_NAME."cs_n_0" => "rldramii_cs_n_0",
									$PREFIX_NAME."we_n_0" => "rldramii_we_n_0",
									$PREFIX_NAME."ref_n_0" => "rldramii_ref_n_0",
									$PREFIX_NAME."cs_n_1" => "rldramii_cs_n_1",
									$PREFIX_NAME."we_n_1" => "rldramii_we_n_1",
									$PREFIX_NAME."ref_n_1" => "rldramii_ref_n_1",
									$PREFIX_NAME."a_0" => "rldramii_a_0",
									$PREFIX_NAME."ba_0" => "rldramii_ba_0",
									$PREFIX_NAME."a_1" => "rldramii_a_1",
									$PREFIX_NAME."ba_1" => "rldramii_ba_1",
									#$PREFIX_NAME."dm" => "rldramii_dm",
									$PREFIX_NAME."d" => "rldramii_d",
									test_complete => "test_complete",
									pnf_per_byte => "pnf_per_byte",
									pnf_persist => "pnf_persist",
								},
								
								inout_port_map	=>
								{
									$PREFIX_NAME."qk" => "rldramii_qk[".($NUMBER_DQS - 1).":0]",
								},
								
								 std_logic_vector_signals	=>
								 [
									 $PREFIX_NAME."clk", $PREFIX_NAME."clk_n", $PREFIX_NAME."qvld", $PREFIX_NAME."qk" 
								 ]
							}),
						),
					} else {
						$module->add_contents
						(
							e_comment->new({comment => "Instantiate SIO RLDRAM II Controller Example Instance"}),
							e_blind_instance->new
							({
								name 		=> "dut",
								module 		=> $gTOPLEVEL_NAME,            
								comment 	=> "---------------------------------------------------------------------\n
								RLDRAM II Example Instance\n
								---------------------------------------------------------------------\n",
								in_port_map 	=>
								{
									clock_source => "clock_source",
									system_reset_n => "system_reset_n",
									$PREFIX_NAME."q" => "rldramii_q",
									$PREFIX_NAME."qvld" => "rldramii_qvld[".($MEM_NUM_DEVICES - 1).":0]",
								},
				
								out_port_map	=>
								{
									$PREFIX_NAME."clk" => "rldramii_clk[".($NUM_CLOCK_PAIRS - 1).":0]",
									$PREFIX_NAME."cs_n_0" => "rldramii_cs_n_0",
									$PREFIX_NAME."we_n_0" => "rldramii_we_n_0",
									$PREFIX_NAME."ref_n_0" => "rldramii_ref_n_0",
									$PREFIX_NAME."cs_n_1" => "rldramii_cs_n_1",
									$PREFIX_NAME."we_n_1" => "rldramii_we_n_1",
									$PREFIX_NAME."ref_n_1" => "rldramii_ref_n_1",
									$PREFIX_NAME."a_0" => "rldramii_a_0",
									$PREFIX_NAME."ba_0" => "rldramii_ba_0",
									$PREFIX_NAME."a_1" => "rldramii_a_1",
									$PREFIX_NAME."ba_1" => "rldramii_ba_1",
									#$PREFIX_NAME."dm" => "rldramii_dm",
									$PREFIX_NAME."d" => "rldramii_d",
									test_complete => "test_complete",
									pnf_per_byte => "pnf_per_byte",
									pnf_persist => "pnf_persist",
								},
								
								inout_port_map	=>
								{
									$PREFIX_NAME."qk" => "rldramii_qk[".($NUMBER_DQS - 1).":0]",
								},
								
								 std_logic_vector_signals	=>
								 [
									 $PREFIX_NAME."clk", $PREFIX_NAME."qvld", $PREFIX_NAME."qk" 
								 ]
							}),
						),
					}
				} else {
					if ($ddio_memory_clocks eq "true") {
						$module->add_contents
						(
							e_comment->new({comment => "Instantiate SIO RLDRAM II Controller Example Instance"}),
							e_blind_instance->new
							({
								name 		=> "dut",
								module 		=> $gTOPLEVEL_NAME,            
								comment 	=> "---------------------------------------------------------------------\n
								RLDRAM II Example Instance\n
								---------------------------------------------------------------------\n",
								in_port_map 	=>
								{
									clock_source => "clock_source",
									system_reset_n => "system_reset_n",
									$PREFIX_NAME."q" => "rldramii_q",
									$PREFIX_NAME."qvld" => "rldramii_qvld[".($MEM_NUM_DEVICES - 1).":0]",
								},
				
								out_port_map	=>
								{
									$PREFIX_NAME."clk" => "rldramii_clk[".($NUM_CLOCK_PAIRS - 1).":0]",
									$PREFIX_NAME."clk_n" => "rldramii_clk_n[".($NUM_CLOCK_PAIRS - 1).":0]",
									$PREFIX_NAME."cs_n_0" => "rldramii_cs_n_0",
									$PREFIX_NAME."we_n_0" => "rldramii_we_n_0",
									$PREFIX_NAME."ref_n_0" => "rldramii_ref_n_0",
									$PREFIX_NAME."a_0" => "rldramii_a_0",
									$PREFIX_NAME."ba_0" => "rldramii_ba_0",
									#$PREFIX_NAME."dm" => "rldramii_dm",
									$PREFIX_NAME."d" => "rldramii_d",
									test_complete => "test_complete",
									pnf_per_byte => "pnf_per_byte",
									pnf_persist => "pnf_persist",
								},
								
								inout_port_map	=>
								{
									$PREFIX_NAME."qk" => "rldramii_qk[".($NUMBER_DQS - 1).":0]",
								},
								
								 std_logic_vector_signals	=>
								 [
									 $PREFIX_NAME."clk", $PREFIX_NAME."clk_n", $PREFIX_NAME."qvld", $PREFIX_NAME."qk" 
								 ]
							}),
						),
					} else {
						$module->add_contents
						(
							e_comment->new({comment => "Instantiate SIO RLDRAM II Controller Example Instance"}),
							e_blind_instance->new
							({
								name 		=> "dut",
								module 		=> $gTOPLEVEL_NAME,            
								comment 	=> "---------------------------------------------------------------------\n
								RLDRAM II Example Instance\n
								---------------------------------------------------------------------\n",
								in_port_map 	=>
								{
									clock_source => "clock_source",
									system_reset_n => "system_reset_n",
									$PREFIX_NAME."q" => "rldramii_q",
									$PREFIX_NAME."qvld" => "rldramii_qvld[".($MEM_NUM_DEVICES - 1).":0]",
								},
				
								out_port_map	=>
								{
									$PREFIX_NAME."clk" => "rldramii_clk[".($NUM_CLOCK_PAIRS - 1).":0]",
									$PREFIX_NAME."cs_n_0" => "rldramii_cs_n_0",
									$PREFIX_NAME."we_n_0" => "rldramii_we_n_0",
									$PREFIX_NAME."ref_n_0" => "rldramii_ref_n_0",
									$PREFIX_NAME."a_0" => "rldramii_a_0",
									$PREFIX_NAME."ba_0" => "rldramii_ba_0",
									#$PREFIX_NAME."dm" => "rldramii_dm",
									$PREFIX_NAME."d" => "rldramii_d",
									test_complete => "test_complete",
									pnf_per_byte => "pnf_per_byte",
									pnf_persist => "pnf_persist",
								},
								
								inout_port_map	=>
								{
									$PREFIX_NAME."qk" => "rldramii_qk[".($NUMBER_DQS - 1).":0]",
								},
								
								 std_logic_vector_signals	=>
								 [
									 $PREFIX_NAME."clk", $PREFIX_NAME."qvld", $PREFIX_NAME."qk" 
								 ]
							}),
						),
					}
				}
			}
		}
		else {
			if($enable_dm_pins eq "true") {
				if($num_addr_cmd_buses > 1) {
					if ($ddio_memory_clocks eq "true") {
						$module->add_contents
						(
							e_comment->new({comment => "Instantiate SIO RLDRAM II Controller Example Instance"}),
							e_blind_instance->new
							({
								name 		=> "dut",
								module 		=> $gTOPLEVEL_NAME,            
								comment 	=> "---------------------------------------------------------------------\n
								RLDRAM II Example Instance\n
								---------------------------------------------------------------------\n",
								in_port_map 	=>
								{
									clock_source => "clock_source",
									system_reset_n => "system_reset_n",
									$PREFIX_NAME."fb_clk_in" => "rldramii_qk[0]",
									$PREFIX_NAME."q" => "rldramii_q",
									$PREFIX_NAME."qvld" => "rldramii_qvld[".($MEM_NUM_DEVICES - 1).":0]",
								},
				
								out_port_map	=>
								{
									$PREFIX_NAME."clk" => "rldramii_clk[".($NUM_CLOCK_PAIRS - 1).":0]",
									$PREFIX_NAME."clk_n" => "rldramii_clk_n[".($NUM_CLOCK_PAIRS - 1).":0]",
									$PREFIX_NAME."cs_n_0" => "rldramii_cs_n_0",
									$PREFIX_NAME."we_n_0" => "rldramii_we_n_0",
									$PREFIX_NAME."ref_n_0" => "rldramii_ref_n_0",
									$PREFIX_NAME."cs_n_1" => "rldramii_cs_n_1",
									$PREFIX_NAME."we_n_1" => "rldramii_we_n_1",
									$PREFIX_NAME."ref_n_1" => "rldramii_ref_n_1",
									$PREFIX_NAME."a_0" => "rldramii_a_0",
									$PREFIX_NAME."ba_0" => "rldramii_ba_0",
									$PREFIX_NAME."a_1" => "rldramii_a_1",
									$PREFIX_NAME."ba_1" => "rldramii_ba_1",
									$PREFIX_NAME."dm" => "rldramii_dm[".($MEM_NUM_DEVICES - 1).":0]",
									$PREFIX_NAME."d" => "rldramii_d",
									test_complete => "test_complete",
									pnf_per_byte => "pnf_per_byte",
									pnf_persist => "pnf_persist",
								},
								
								 std_logic_vector_signals	=>
								 [
									 $PREFIX_NAME."clk", $PREFIX_NAME."clk_n",  $PREFIX_NAME."dm",$PREFIX_NAME."qvld", $PREFIX_NAME."qk" 
								 ]
							}),
						),
					} else {
						$module->add_contents
						(
							e_comment->new({comment => "Instantiate SIO RLDRAM II Controller Example Instance"}),
							e_blind_instance->new
							({
								name 		=> "dut",
								module 		=> $gTOPLEVEL_NAME,            
								comment 	=> "---------------------------------------------------------------------\n
								RLDRAM II Example Instance\n
								---------------------------------------------------------------------\n",
								in_port_map 	=>
								{
									clock_source => "clock_source",
									system_reset_n => "system_reset_n",
									$PREFIX_NAME."fb_clk_in" => "rldramii_qk[0]",
									$PREFIX_NAME."q" => "rldramii_q",
									$PREFIX_NAME."qvld" => "rldramii_qvld[".($MEM_NUM_DEVICES - 1).":0]",
								},
				
								out_port_map	=>
								{
									$PREFIX_NAME."clk" => "rldramii_clk[".($NUM_CLOCK_PAIRS - 1).":0]",
									$PREFIX_NAME."cs_n_0" => "rldramii_cs_n_0",
									$PREFIX_NAME."we_n_0" => "rldramii_we_n_0",
									$PREFIX_NAME."ref_n_0" => "rldramii_ref_n_0",
									$PREFIX_NAME."cs_n_1" => "rldramii_cs_n_1",
									$PREFIX_NAME."we_n_1" => "rldramii_we_n_1",
									$PREFIX_NAME."ref_n_1" => "rldramii_ref_n_1",
									$PREFIX_NAME."a_0" => "rldramii_a_0",
									$PREFIX_NAME."ba_0" => "rldramii_ba_0",
									$PREFIX_NAME."a_1" => "rldramii_a_1",
									$PREFIX_NAME."ba_1" => "rldramii_ba_1",
									$PREFIX_NAME."dm" => "rldramii_dm[".($MEM_NUM_DEVICES - 1).":0]",
									$PREFIX_NAME."d" => "rldramii_d",
									test_complete => "test_complete",
									pnf_per_byte => "pnf_per_byte",
									pnf_persist => "pnf_persist",
								},
								
								 std_logic_vector_signals	=>
								 [
									 $PREFIX_NAME."clk", $PREFIX_NAME."dm",$PREFIX_NAME."qvld", $PREFIX_NAME."qk" 
								 ]
							}),
						),
					}
				} else {
					if ($ddio_memory_clocks eq "true") {
						$module->add_contents
						(
							e_comment->new({comment => "Instantiate SIO RLDRAM II Controller Example Instance"}),
							e_blind_instance->new
							({
								name 		=> "dut",
								module 		=> $gTOPLEVEL_NAME,            
								comment 	=> "---------------------------------------------------------------------\n
								RLDRAM II Example Instance\n
								---------------------------------------------------------------------\n",
								in_port_map 	=>
								{
									clock_source => "clock_source",
									system_reset_n => "system_reset_n",
									$PREFIX_NAME."fb_clk_in" => "rldramii_qk[0]",
									$PREFIX_NAME."q" => "rldramii_q",
									$PREFIX_NAME."qvld" => "rldramii_qvld[".($MEM_NUM_DEVICES - 1).":0]",
								},
				
								out_port_map	=>
								{
									$PREFIX_NAME."clk" => "rldramii_clk[".($NUM_CLOCK_PAIRS - 1).":0]",
									$PREFIX_NAME."clk_n" => "rldramii_clk_n[".($NUM_CLOCK_PAIRS - 1).":0]",
									$PREFIX_NAME."cs_n_0" => "rldramii_cs_n_0",
									$PREFIX_NAME."we_n_0" => "rldramii_we_n_0",
									$PREFIX_NAME."ref_n_0" => "rldramii_ref_n_0",
									$PREFIX_NAME."a_0" => "rldramii_a_0",
									$PREFIX_NAME."ba_0" => "rldramii_ba_0",
									$PREFIX_NAME."dm" => "rldramii_dm[".($MEM_NUM_DEVICES - 1).":0]",
									$PREFIX_NAME."d" => "rldramii_d",
									test_complete => "test_complete",
									pnf_per_byte => "pnf_per_byte",
									pnf_persist => "pnf_persist",
								},
								
								 std_logic_vector_signals	=>
								 [
									 $PREFIX_NAME."clk", $PREFIX_NAME."clk_n",  $PREFIX_NAME."dm",$PREFIX_NAME."qvld", $PREFIX_NAME."qk" 
								 ]
							}),
						),
					} else {
						$module->add_contents
						(
							e_comment->new({comment => "Instantiate SIO RLDRAM II Controller Example Instance"}),
							e_blind_instance->new
							({
								name 		=> "dut",
								module 		=> $gTOPLEVEL_NAME,            
								comment 	=> "---------------------------------------------------------------------\n
								RLDRAM II Example Instance\n
								---------------------------------------------------------------------\n",
								in_port_map 	=>
								{
									clock_source => "clock_source",
									system_reset_n => "system_reset_n",
									$PREFIX_NAME."fb_clk_in" => "rldramii_qk[0]",
									$PREFIX_NAME."q" => "rldramii_q",
									$PREFIX_NAME."qvld" => "rldramii_qvld[".($MEM_NUM_DEVICES - 1).":0]",
								},
				
								out_port_map	=>
								{
									$PREFIX_NAME."clk" => "rldramii_clk[".($NUM_CLOCK_PAIRS - 1).":0]",
									$PREFIX_NAME."cs_n_0" => "rldramii_cs_n_0",
									$PREFIX_NAME."we_n_0" => "rldramii_we_n_0",
									$PREFIX_NAME."ref_n_0" => "rldramii_ref_n_0",
									$PREFIX_NAME."a_0" => "rldramii_a_0",
									$PREFIX_NAME."ba_0" => "rldramii_ba_0",
									$PREFIX_NAME."dm" => "rldramii_dm[".($MEM_NUM_DEVICES - 1).":0]",
									$PREFIX_NAME."d" => "rldramii_d",
									test_complete => "test_complete",
									pnf_per_byte => "pnf_per_byte",
									pnf_persist => "pnf_persist",
								},
								
								 std_logic_vector_signals	=>
								 [
									 $PREFIX_NAME."clk",  $PREFIX_NAME."dm",$PREFIX_NAME."qvld", $PREFIX_NAME."qk" 
								 ]
							}),
						),
					}
				}
			} else {
				if($num_addr_cmd_buses > 1) {
					if ($ddio_memory_clocks eq "true") {
						$module->add_contents
						(
							e_comment->new({comment => "Instantiate SIO RLDRAM II Controller Example Instance"}),
							e_blind_instance->new
							({
								name 		=> "dut",
								module 		=> $gTOPLEVEL_NAME,            
								comment 	=> "---------------------------------------------------------------------\n
								RLDRAM II Example Instance\n
								---------------------------------------------------------------------\n",
								in_port_map 	=>
								{
									clock_source => "clock_source",
									system_reset_n => "system_reset_n",
									$PREFIX_NAME."fb_clk_in" => "rldramii_qk[0]",
									$PREFIX_NAME."q" => "rldramii_q",
									$PREFIX_NAME."qvld" => "rldramii_qvld[".($MEM_NUM_DEVICES - 1).":0]",
								},
				
								out_port_map	=>
								{
									$PREFIX_NAME."clk" => "rldramii_clk[".($NUM_CLOCK_PAIRS - 1).":0]",
									$PREFIX_NAME."clk_n" => "rldramii_clk_n[".($NUM_CLOCK_PAIRS - 1).":0]",
									$PREFIX_NAME."cs_n_0" => "rldramii_cs_n_0",
									$PREFIX_NAME."we_n_0" => "rldramii_we_n_0",
									$PREFIX_NAME."ref_n_0" => "rldramii_ref_n_0",
									$PREFIX_NAME."cs_n_1" => "rldramii_cs_n_1",
									$PREFIX_NAME."we_n_1" => "rldramii_we_n_1",
									$PREFIX_NAME."ref_n_1" => "rldramii_ref_n_1",
									$PREFIX_NAME."a_0" => "rldramii_a_0",
									$PREFIX_NAME."ba_0" => "rldramii_ba_0",
									$PREFIX_NAME."a_1" => "rldramii_a_1",
									$PREFIX_NAME."ba_1" => "rldramii_ba_1",
									#$PREFIX_NAME."dm" => "rldramii_dm",
									$PREFIX_NAME."d" => "rldramii_d",
									test_complete => "test_complete",
									pnf_per_byte => "pnf_per_byte",
									pnf_persist => "pnf_persist",
								},
								
								 std_logic_vector_signals	=>
								 [
									 $PREFIX_NAME."clk", $PREFIX_NAME."clk_n", $PREFIX_NAME."qvld", $PREFIX_NAME."qk" 
								 ]
							}),
						),
					} else {
						$module->add_contents
						(
							e_comment->new({comment => "Instantiate SIO RLDRAM II Controller Example Instance"}),
							e_blind_instance->new
							({
								name 		=> "dut",
								module 		=> $gTOPLEVEL_NAME,            
								comment 	=> "---------------------------------------------------------------------\n
								RLDRAM II Example Instance\n
								---------------------------------------------------------------------\n",
								in_port_map 	=>
								{
									clock_source => "clock_source",
									system_reset_n => "system_reset_n",
									$PREFIX_NAME."fb_clk_in" => "rldramii_qk[0]",
									$PREFIX_NAME."q" => "rldramii_q",
									$PREFIX_NAME."qvld" => "rldramii_qvld[".($MEM_NUM_DEVICES - 1).":0]",
								},
				
								out_port_map	=>
								{
									$PREFIX_NAME."clk" => "rldramii_clk[".($NUM_CLOCK_PAIRS - 1).":0]",
									$PREFIX_NAME."cs_n_0" => "rldramii_cs_n_0",
									$PREFIX_NAME."we_n_0" => "rldramii_we_n_0",
									$PREFIX_NAME."ref_n_0" => "rldramii_ref_n_0",
									$PREFIX_NAME."cs_n_1" => "rldramii_cs_n_1",
									$PREFIX_NAME."we_n_1" => "rldramii_we_n_1",
									$PREFIX_NAME."ref_n_1" => "rldramii_ref_n_1",
									$PREFIX_NAME."a_0" => "rldramii_a_0",
									$PREFIX_NAME."ba_0" => "rldramii_ba_0",
									$PREFIX_NAME."a_1" => "rldramii_a_1",
									$PREFIX_NAME."ba_1" => "rldramii_ba_1",
									#$PREFIX_NAME."dm" => "rldramii_dm",
									$PREFIX_NAME."d" => "rldramii_d",
									test_complete => "test_complete",
									pnf_per_byte => "pnf_per_byte",
									pnf_persist => "pnf_persist",
								},
								
								 std_logic_vector_signals	=>
								 [
									 $PREFIX_NAME."clk", $PREFIX_NAME."qvld", $PREFIX_NAME."qk" 
								 ]
							}),
						),
					}
				} else {
					if ($ddio_memory_clocks eq "true") {
						$module->add_contents
						(
							e_comment->new({comment => "Instantiate SIO RLDRAM II Controller Example Instance"}),
							e_blind_instance->new
							({
								name 		=> "dut",
								module 		=> $gTOPLEVEL_NAME,            
								comment 	=> "---------------------------------------------------------------------\n
								RLDRAM II Example Instance\n
								---------------------------------------------------------------------\n",
								in_port_map 	=>
								{
									clock_source => "clock_source",
									system_reset_n => "system_reset_n",
									$PREFIX_NAME."fb_clk_in" => "rldramii_qk[0]",
									$PREFIX_NAME."q" => "rldramii_q",
									$PREFIX_NAME."qvld" => "rldramii_qvld[".($MEM_NUM_DEVICES - 1).":0]",
								},
				
								out_port_map	=>
								{
									$PREFIX_NAME."clk" => "rldramii_clk[".($NUM_CLOCK_PAIRS - 1).":0]",
									$PREFIX_NAME."clk_n" => "rldramii_clk_n[".($NUM_CLOCK_PAIRS - 1).":0]",
									$PREFIX_NAME."cs_n_0" => "rldramii_cs_n_0",
									$PREFIX_NAME."we_n_0" => "rldramii_we_n_0",
									$PREFIX_NAME."ref_n_0" => "rldramii_ref_n_0",
									$PREFIX_NAME."a_0" => "rldramii_a_0",
									$PREFIX_NAME."ba_0" => "rldramii_ba_0",
									#$PREFIX_NAME."dm" => "rldramii_dm",
									$PREFIX_NAME."d" => "rldramii_d",
									test_complete => "test_complete",
									pnf_per_byte => "pnf_per_byte",
									pnf_persist => "pnf_persist",
								},
								
								 std_logic_vector_signals	=>
								 [
									 $PREFIX_NAME."clk", $PREFIX_NAME."clk_n", $PREFIX_NAME."qvld", $PREFIX_NAME."qk" 
								 ]
							}),
						),
					} else {
						$module->add_contents
						(
							e_comment->new({comment => "Instantiate SIO RLDRAM II Controller Example Instance"}),
							e_blind_instance->new
							({
								name 		=> "dut",
								module 		=> $gTOPLEVEL_NAME,            
								comment 	=> "---------------------------------------------------------------------\n
								RLDRAM II Example Instance\n
								---------------------------------------------------------------------\n",
								in_port_map 	=>
								{
									clock_source => "clock_source",
									system_reset_n => "system_reset_n",
									$PREFIX_NAME."fb_clk_in" => "rldramii_qk[0]",
									$PREFIX_NAME."q" => "rldramii_q",
									$PREFIX_NAME."qvld" => "rldramii_qvld[".($MEM_NUM_DEVICES - 1).":0]",
								},
				
								out_port_map	=>
								{
									$PREFIX_NAME."clk" => "rldramii_clk[".($NUM_CLOCK_PAIRS - 1).":0]",
									$PREFIX_NAME."cs_n_0" => "rldramii_cs_n_0",
									$PREFIX_NAME."we_n_0" => "rldramii_we_n_0",
									$PREFIX_NAME."ref_n_0" => "rldramii_ref_n_0",
									$PREFIX_NAME."a_0" => "rldramii_a_0",
									$PREFIX_NAME."ba_0" => "rldramii_ba_0",
									#$PREFIX_NAME."dm" => "rldramii_dm",
									$PREFIX_NAME."d" => "rldramii_d",
									test_complete => "test_complete",
									pnf_per_byte => "pnf_per_byte",
									pnf_persist => "pnf_persist",
								},
								
								 std_logic_vector_signals	=>
								 [
									 $PREFIX_NAME."clk", $PREFIX_NAME."qvld", $PREFIX_NAME."qk" 
								 ]
							}),
						),
					}
				}
			}
		}
	};
	
#################################################################################################################################################################
	if ($RLDRAMII_TYPE eq "cio") {
		$s = 0;
		$t = 0;
		$NUMBER_DEVICES_REMAINING = $MEM_NUM_DEVICES;
		
		for ($i = 0; $i < $NUM_CLOCK_PAIRS; $i++ ) {
			for ($j = 0; $j < $NUMBER_DEVICES_PER_CLOCK; $j++ ) {
				
			if (($MEM_DQ_PER_DQS == 16) or ($MEM_DQ_PER_DQS == 18)) 
			{
				if ($USE_DENALI_MEMORY_MODELS eq "false") {
					$module->add_contents
					(
						e_comment->new({comment => "Instantiate CIO RLDRAM II Memory"}),
						e_blind_instance->new
						({
							name 		=> "rldramii".$s."_w".$RLDRAMII_WIDTH."_inst",
							module 		=> $MEMORY_COMPONENT_NAME,            
							comment 	=> "---------------------------------------------------------------------\n
							RLDRAM II Memory Instance\n
							---------------------------------------------------------------------\n",
							in_port_map 	=>
							{
                                ck 	    => "rldramii_clk[0]",
								ck_n 	=> "rldramii_clk_n[0]",
								dk	    => "dk_rldramii_clk[1:0]",
								dk_n	=> "dk_rldramii_clk_n[1:0]",
								cs_n	=> "rldramii_cs_n",
								we_n	=> "rldramii_we_n",
								ref_n	=> "rldramii_ref_n",
								a	    => "rldramii_a",
								ba    	=> "rldramii_ba",
								dm	    => "rldramii_dm["."$t".":"."$t"."]",
                                tck     => "ZERO",
                                tms     => "ZERO",
                                tdi     => "ZERO",
							},
							out_port_map	=>
							{
								qvld	=> "rldramii_qvld["."$t".":"."$t"."]",
								qk	    => "rldramii_qk["."(($t + 1) * $NUMBER_DQS_PER_DEVICE) - 1".":"."$t * $NUMBER_DQS_PER_DEVICE"."]",
								qk_n	=> "rldramii_qk_n["."(($t + 1) * $NUMBER_DQS_PER_DEVICE) - 1".":"."$t * $NUMBER_DQS_PER_DEVICE"."]",
                                tdo     => "open",
							},
						 
							inout_port_map	=>
							{
								dq 	=> "dq["."(($s + 1) * $RLDRAMII_WIDTH) - 1".":"."$s * $RLDRAMII_WIDTH"."]",
							},
								
                            std_logic_vector_signals	=>
							[
							   dm
							],    
                                
							# parameter_map 	=>
							# {
								# # addr_bits	=> $MEM_ADDR_BITS,
								# DQ_BITS	=> $RLDRAMII_WIDTH,
							# },
						}),
					),
				}
				else
				{
					$module->add_contents
					(
						e_comment->new({comment => "Instantiate CIO RLDRAM II Memory"}),
						e_blind_instance->new
						({
							name 		=> "rldramii".$s."_w".$RLDRAMII_WIDTH."_inst",
							module 		=> $MEMORY_COMPONENT_NAME,      
							comment 	=> "---------------------------------------------------------------------\n
							RLDRAM II Memory Instance\n
							---------------------------------------------------------------------\n",
							in_port_map 	=>
							{
                                ck 	    => "rldramii_clk["."$i".":"."$i"."]",
                                ck_n    => "rldramii_clk_n["."$i".":"."$i"."]",
                                cs_n    => "rldramii_cs_n",
                                #dk	    => "dk_rldramii_clk["."(($i + 1)* 2) - 1".":"."$i * 2"."]",
                                #dk_n	=> "dk_rldramii_clk_n["."(($i + 1)* 2) - 1".":"."$i * 2"."]",
                                dk	    => "dk_rldramii_clk",
                                dk_n	=> "dk_rldramii_clk_n",
                                we_n 	=> "rldramii_we_n",	
                                ref_n	=> "rldramii_ref_n",		
                                ba	    => "rldramii_ba",   		
                                a	    => "rldramii_a",
                                dm	    => "rldramii_dm["."$t".":"."$t"."]",
                                   		# tck	=> "ZERO",
                                  		# tms	=> "ZERO",
                                 		# tdi	=> "ZERO",
                            },
							out_port_map	=>
							{
								qvld	=> "rldramii_qvld["."$t".":"."$t"."]",
								qk	    => "rldramii_qk["."(($t + 1) * $NUMBER_DQS_PER_DEVICE) - 1".":"."$t * $NUMBER_DQS_PER_DEVICE"."]",
								qk_n	=> "rldramii_qk_n["."(($t + 1) * $NUMBER_DQS_PER_DEVICE) - 1".":"."$t * $NUMBER_DQS_PER_DEVICE"."]",
								#tdo	=> "open",
							},
						 
							inout_port_map	=>
							{
								dq 	=> "dq["."(($s + 1) * $RLDRAMII_WIDTH) - 1".":"."$s * $RLDRAMII_WIDTH"."]",
								#ZQ	=> "open",
							},
								
							# parameter_map 	=>
							# {
								# memory_spec	=> 	'"'."$MEMORY_SPEC".'"',
								# init_file	=>	'"'.'"',
							# },
							
						}),
					),
				}
			}
			else
			{
				if ($USE_DENALI_MEMORY_MODELS eq "true") {
					$module->add_contents
					(
						e_comment->new({comment => "Instantiate CIO RLDRAM II Memory"}),
						e_blind_instance->new
						({
							name 		=> "rldramii".$s."_w".$RLDRAMII_WIDTH."_inst",
							module 		=> $MEMORY_COMPONENT_NAME."_2_5",      
							#_use_vlog_rtl_param =>   1,
							comment 	=> "---------------------------------------------------------------------\n
							RLDRAM II Memory Instance\n
							---------------------------------------------------------------------\n",
							in_port_map 	=>
							{
								#ck 	=> "rldramii_clk["."$i".":"."$i"."]",
								#ckbar 	=> "rldramii_clk_n["."$i".":"."$i"."]",
								ck 	=> "rldramii_clk[0]",
								ckbar 	=> "rldramii_clk_n[0]",
								dk	=> "rldramii_clk["."$i".":"."$i"."]",
								dkbar	=> "rldramii_clk_n["."$i".":"."$i"."]",
								csbar	=> "rldramii_cs_n",
								webar	=> "rldramii_we_n",
								refbar	=> "rldramii_ref_n",
								a	=> "rldramii_a",
								ba	=> "rldramii_ba",
								dm	=> "rldramii_dm["."$t".":"."$t"."]",
								tck	=> "ZERO",
								tms	=> "ZERO",
								tdi	=> "ZERO",
							},
							out_port_map	=>
							{
								qvld	=> "rldramii_qvld["."$t".":"."$t"."]",
								qk	=> "rldramii_qk["."(($t + 1) * $NUMBER_DQS_PER_DEVICE) - 1".":"."$t * $NUMBER_DQS_PER_DEVICE"."]",
								qkbar	=> "rldramii_qk_n["."(($t + 1) * $NUMBER_DQS_PER_DEVICE) - 1".":"."$t * $NUMBER_DQS_PER_DEVICE"."]",
								tdo	=>"open",
							},
						 
							inout_port_map	=>
							{
								dq 	=> "dq["."(($s + 1) * $RLDRAMII_WIDTH) - 1".":"."$s * $RLDRAMII_WIDTH"."]",
								ZQ	=> "open",
							},
								
							# parameter_map 	=>
							# {
								# memory_spec	=> 	'"'."$MEMORY_SPEC".'"',
								# init_file	=>	'"'.'"',
							# },
							
						}),
					),
				}
				else
				{
					$module->add_contents
					(
						e_comment->new({comment => "Instantiate CIO RLDRAM II Memory"}),
						e_blind_instance->new
						({
							name 		=> "rldramii".$s."_w".$RLDRAMII_WIDTH."_inst",
							module 		=> $MEMORY_COMPONENT_NAME,            
							comment 	=> "---------------------------------------------------------------------\n
							RLDRAM II Memory Instance\n
							---------------------------------------------------------------------\n",
							in_port_map 	=>
							{
								ck 	    => "rldramii_clk[0]",
								ck_n 	=> "rldramii_clk_n[0]",
								dk	    => "rldramii_clk["."0".":"."0"."]",
								dk_n	=> "rldramii_clk_n["."0".":"."0"."]",
                                #dk	    => "rldramii_clk[0]",
								#dk_n	=> "rldramii_clk_n[0]",
								cs_n	=> "rldramii_cs_n",
								we_n	=> "rldramii_we_n",
								ref_n	=> "rldramii_ref_n",
								a    	=> "rldramii_a",
								ba    	=> "rldramii_ba",
								dm      => "rldramii_dm["."$t".":"."$t"."]",
                                tck     => "ZERO",
                                tms     => "ZERO",
                                tdi     => "ZERO",

							},  
							out_port_map	=>
							{
								qvld	=> "rldramii_qvld["."$t".":"."$t"."]",
								qk	    => "rldramii_qk["."(($t + 1) * $NUMBER_DQS_PER_DEVICE) - 1".":"."$t * $NUMBER_DQS_PER_DEVICE"."]",
								qk_n	=> "rldramii_qk_n["."(($t + 1) * $NUMBER_DQS_PER_DEVICE) - 1".":"."$t * $NUMBER_DQS_PER_DEVICE"."]",
                                tdo     => "open",
							},
						 
							inout_port_map	=>
							{
								dq 	=> "dq["."(($s + 1) * $RLDRAMII_WIDTH) - 1".":"."$s * $RLDRAMII_WIDTH"."]",
							},
                            
                            std_logic_vector_signals	=>
							[
							    dk, dk_n, qk, qk_n, dm
							],
								
                        # parameter_map 	=>
                        # {
                            # # addr_bits	=> $MEM_ADDR_BITS,
                            # DQ_BITS	=> $RLDRAMII_WIDTH,
                        # },
							
						}),
					),
				}
			}
			$s = $s + 1;
			$t = $t + 1;
			}
			#print "DpC..........$NUMBER_DEVICES_PER_CLOCK\n";
			#print "DR.......$i)..........$NUMBER_DEVICES_REMAINING\n";
			$NUMBER_DEVICES_REMAINING = $NUMBER_DEVICES_REMAINING - $NUMBER_DEVICES_PER_CLOCK;
			if ($NUMBER_DEVICES_REMAINING <= $NUMBER_DEVICES_PER_CLOCK)
			{
				$NUMBER_DEVICES_PER_CLOCK = $NUMBER_DEVICES_REMAINING;
			}
		}
	}
	else
	{
		$s = 0;
		$t = 0;
		$NUMBER_DEVICES_REMAINING = $MEM_NUM_DEVICES;
		
		for ($i = 0; $i < $NUM_CLOCK_PAIRS; $i++ ) {
			for ($j = 0; $j < $NUMBER_DEVICES_PER_CLOCK; $j++ ) {
				if ($USE_DENALI_MEMORY_MODELS eq "false") {
					$module->add_contents
					(
						e_comment->new({comment => "Instantiate SIO RLDRAM II Memory"}),
						e_blind_instance->new
						({
							name 		=> "rldramii".$s."_w".$RLDRAMII_WIDTH."_inst",
							module 		=> $MEMORY_COMPONENT_NAME,            
							comment 	=> "---------------------------------------------------------------------\n
							RLDRAM II Memory Instance\n
							---------------------------------------------------------------------\n",
							in_port_map 	=>
							{
                                d 	    => "rldramii_d["."(($s + 1) * $RLDRAMII_WIDTH) - 1".":"."$s * $RLDRAMII_WIDTH"."]",
								ck 	    => "rldramii_clk[0]",
								ck_n 	=> "rldramii_clk_n[0]",
								dk	    => "rldramii_clk[0]",
								dk_n	=> "rldramii_clk_n[0]",
								cs_n	=> "rldramii_cs_n",
								we_n	=> "rldramii_we_n",
								ref_n	=> "rldramii_ref_n",
								a	    => "rldramii_a",
								ba	    => "rldramii_ba",
								dm	    => "rldramii_dm["."$t".":"."$t"."]",
                                tck     => "ZERO",
                                tms     => "ZERO",
                                tdi     => "ZERO",

							},
		
							out_port_map	=>
							{
								q 	    => "rldramii_q["."(($s + 1) * $RLDRAMII_WIDTH) - 1".":"."$s * $RLDRAMII_WIDTH"."]",
								qvld	=> "rldramii_qvld["."$t".":"."$t"."]",
								qk	    => "rldramii_qk["."(($t + 1) * $NUMBER_DQS_PER_DEVICE) - 1".":"."$t * $NUMBER_DQS_PER_DEVICE"."]",
								qk_n	=> "rldramii_qk_n["."(($t + 1) * $NUMBER_DQS_PER_DEVICE) - 1".":"."$t * $NUMBER_DQS_PER_DEVICE"."]",
                                tdo     => "open",
							},
						 
                            std_logic_vector_signals	=>
							[
							    dk, dk_n, qk, qk_n, dm
							],
								
							# parameter_map 	=>
							# {
								# # addr_bits	=> $MEM_ADDR_BITS,
								# DQ_BITS	=> $RLDRAMII_WIDTH,
							# },
						}),
					),
				}
				else
				{
					$module->add_contents
					(
						e_comment->new({comment => "Instantiate CIO RLDRAM II Memory"}),
						e_blind_instance->new
						({
							name 		=> "rldramii".$s."_w".$RLDRAMII_WIDTH."_inst",
							module 		=> $MEMORY_COMPONENT_NAME."_2_5",      
							#_use_vlog_rtl_param =>   1,
							comment 	=> "---------------------------------------------------------------------\n
							RLDRAM II Memory Instance\n
							---------------------------------------------------------------------\n",
							in_port_map 	=>
							{
								ck 	=> "rldramii_clk["."$i".":"."$i"."]",
								ckbar 	=> "rldramii_clk_n["."$i".":"."$i"."]",
								dk	=> "rldramii_clk["."$i".":"."$i"."]",
								dkbar	=> "rldramii_clk_n["."$i".":"."$i"."]",
								csbar	=> "rldramii_cs_n",
								webar	=> "rldramii_we_n",
								refbar	=> "rldramii_ref_n",
								d 	=> "rldramii_d["."(($s + 1) * $RLDRAMII_WIDTH) - 1".":"."$s * $RLDRAMII_WIDTH"."]",
								a	=> "rldramii_a",
								ba	=> "rldramii_ba",
								dm	=> "rldramii_dm["."$t".":"."$t"."]",
								tck	=> "ZERO",
								tms	=> "ZERO",
								tdi	=> "ZERO",
							},
							out_port_map	=>
							{
								q 	=> "rldramii_q["."(($s + 1) * $RLDRAMII_WIDTH) - 1".":"."$s * $RLDRAMII_WIDTH"."]",
								qvld	=> "rldramii_qvld["."$t".":"."$t"."]",
								qk	=> "rldramii_qk["."(($t + 1) * $NUMBER_DQS_PER_DEVICE) - 1".":"."$t * $NUMBER_DQS_PER_DEVICE"."]",
								qkbar	=> "rldramii_qk_n["."(($t + 1) * $NUMBER_DQS_PER_DEVICE) - 1".":"."$t * $NUMBER_DQS_PER_DEVICE"."]",
								tdo	=> "open",
							},
						 
							inout_port_map	=>
							{
								ZQ	=> "open",
							},
								
							parameter_map 	=>
							{
								memory_spec	=> 	'"'."$MEMORY_SPEC".'"',
								init_file	=>	'"'.'"',
							},
							
						}),
					),
				}
			$s = $s + 1;
			$t = $t + 1;
			}
			
			#print "DpC..........$NUMBER_DEVICES_PER_CLOCK\n";
			#print "DR.......$i)..........$NUMBER_DEVICES_REMAINING\n";
			$NUMBER_DEVICES_REMAINING = $NUMBER_DEVICES_REMAINING - $NUMBER_DEVICES_PER_CLOCK;
			if ($NUMBER_DEVICES_REMAINING <= $NUMBER_DEVICES_PER_CLOCK)
			{
				$NUMBER_DEVICES_PER_CLOCK = $NUMBER_DEVICES_REMAINING;
			}
		}
	};
		
	 
#########################################################################################################################################################
	$module->add_contents
	(
	    e_clk->add({clk => "clock_source",
		    	      ns_period => $CLK_PERIOD}),
	                      #clk_speed_in_mhz => $CLOCK_FREQ_IN_MHZ}),
            e_reset->add({reset => "system_reset_n",
			      clk_speed_in_mhz => $CLOCK_FREQ_IN_MHZ,}),			      
             e_process->new
	     ({
		 clock	=> "clock_source",
		 reset	=> "system_reset_n",
		 contents	=>
		 [
			 e_if->new
			 ({
			     condition	=> "test_complete",
			     then	=>
			     [
				 e_if->new
				 ({
					 condition	=> "pnf_persist",
					 then		=>
					 [
						 e_testbench->new({display =>"          --- SIMULATION PASSED --- ",severity_level => "FAILURE"}),
					 ],
					 else		=>
					 [
						 e_testbench->new({display =>"          --- SIMULATION FAILED --- ",severity_level => "FAILURE"}),
					 ],
				 }),
			     ],
			     #else		=>
			     #[
				# e_testbench->new({display =>"          --- SIMULATION FAILED, DID NOT COMPLETE --- "}),
			     #],
			 }),
		 ],
	     }),
        );
	 
#################################################################################################################################################################

$project->output();

}

1;



