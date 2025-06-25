#sopc_builder free codec

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

sub write_rldramii_mw_wrapper

{
#my $top = e_module->new({name => $gTOPLEVEL_NAME});#,output_file => "/temp_gen/${gWRAPPER_NAME}_example_driver"});
my $top = e_module->new({name => $gWRAPPER_NAME."_wrapper"});#."_auk_rldramii"});#,output_file => "/temp_gen/${gWRAPPER_NAME}_example_driver"});
my $project = e_project->new({top => $top, language => $language,__system_directory =>$gWRAPPER_PATH});#'temp_gen'});
my $module = $project->top();
#####   Parameters declaration  ######
$header_title = "RLDRAM II Controller Wrapper";
$header_filename = $gWRAPPER_NAME;
$header_revision = "V" . $gWIZARD_VERSION;
#my $verilog_dq_io_instname;# = "\\g_datapath:\$i:g_ddr_io ";
my $Stratix_Fam = "";
my %stratix_param  = "";
my $CLOCK_PERIOD_IN_PS = $gCLOCK_PERIOD_IN_PS;
my $STRATIXII_DLL_DELAY_BUFFER_MODE = $gSTRATIXII_DLL_DELAY_BUFFER_MODE;
my $STRATIXII_DLL_DELAY_CHAIN_LENGTH = $gSTRATIXII_DLL_DELAY_CHAIN_LENGTH;
my $PREFIX_NAME = $gDDR_PREFIX_NAME;
my $LOCAL_DATA_BITS = $gLOCAL_DATA_BITS;
my $LOCAL_DATA_MODE = $gLOCAL_DATA_MODE;
my $LOCAL_ADDR_BITS = 24;
my $LOCAL_BURST_LEN = $gLOCAL_BURST_LEN;
my $MEM_ADDR_BITS = $gMEM_ADDR_BITS;
my $MEM_NUM_DEVICES = $gMEM_NUM_DEVICES;
my $MEM_TRC_CYCLES = $gMEM_TRC_CYCLES;
my $MEM_TWL_CYCLES = $gMEM_TWL_CYCLES;
my $RLDRAMII_TYPE = $gRLDRAMII_TYPE;
my $ADDR_SHIFT_BITS = $gADDR_SHIFT_BITS;
my $REFRESH_COMMAND = $gREFRESH_COMMAND;
my $MEM_DQ_PER_DQS = $gMEM_DQ_PER_DQS;
my $NUM_CLOCK_PAIRS = $gNUM_CLOCK_PAIRS;
my $enable_dm_pins = $gENABLE_DM_PINS;
#my $ddio_memory_clocks = $gDDIO_MEMORY_CLOCKS;
my $ddio_memory_clocks = $gDDIO_MEMORY_CLOCKS;
my $num_addr_cmd_buses = $gNUMBER_ADDR_CMD_BUSES;
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
my $NUM_PIPELINE_WDATA_STAGES = $gNUM_PIPELINE_WDATA_STAGES;
my $addr_cmd_negedge = $gADDR_CMD_NEGEDGE;
my $addr_cmd_clk = $gADDR_CMD_CLK;
my $enable_addr_cmd_clk = $gENABLE_ADDR_CMD_CLK;
my $NUM_PIPELINE_ADDR_CMD_STAGES = $gNUM_PIPELINE_ADDR_CMD_STAGES;
my $ENABLE_CAPTURE_CLK = $gENABLE_CAPTURE_CLK;
my $insert_addr_cmd_negedge_reg = $gINSERT_ADDR_CMD_NEGEDGE_REG;
my $odt = $gODT;
my $ime = $gIME;
my $dlle = $gDLLE;
my $init_time = $gINIT_TIME;

if ($odt eq "true") {
	$ondietermination = 1;
} else {
	$ondietermination = 0;
}

if ($ime eq "true") {
	$impedance_matching = 1;
} else {
	$impedance_matching = 0;
}

if ($dlle eq "true") {
	$dll_enable = 1;
} else {
	$dll_enable = 0;
}


# if (($addr_cmd_negedge eq "false") and ($enable_addr_cmd_clk eq "false")) {
	# $NUM_PIPELINE_ADDR_CMD_STAGES = $gNUM_PIPELINE_ADDR_CMD_STAGES + 1;
# }
# else
# {
	# $NUM_PIPELINE_ADDR_CMD_STAGES = $gNUM_PIPELINE_ADDR_CMD_STAGES;
# }

if ($ENABLE_CAPTURE_CLK eq "true") {
	$CAPTURE_MODE = non_dqs;
}
else {
	$CAPTURE_MODE = dqs;
}

my $ADDR_INCR = int(($LOCAL_DATA_BITS / $MEM_DQ_PER_DQS) * $LOCAL_BURST_LEN);
my $MEMORY_BURST_LEN = int($LOCAL_BURST_LEN * 2);

#### Calculate the number of dqs pins used and the memory interface width ####
if ($LOCAL_DATA_MODE eq "narrow") {
    $NUMBER_DQS = int($LOCAL_DATA_BITS / $MEM_DQ_PER_DQS / 2);
    $MEMORY_DATA_WIDTH = int($LOCAL_DATA_BITS / 2);
} else {
    $NUMBER_DQS = int($LOCAL_DATA_BITS / $LOCAL_BURST_LEN / $MEM_DQ_PER_DQS / 2);
    $MEMORY_DATA_WIDTH = int($LOCAL_DATA_BITS / $MEMORY_BURST_LEN / 2);	
}


#### Set burst length configuration bits based on burst length
if ($LOCAL_BURST_LEN eq "1") {
	$MEMORY_BURST_LEN_CONFIG = "0";
}
elsif ($LOCAL_BURST_LEN eq "2") {
	$MEMORY_BURST_LEN_CONFIG = "1";	
}
else
{
	$MEMORY_BURST_LEN_CONFIG = "2";
}

my $RLDRAMII_CONFIGURATION = $gRLDRAMII_CONFIGURATION;

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
	\nConfigurable RLDRAM II wrapper containing:
	\n\t     - RLDRAM II controller
	\n\t     - RLDRAM II datapath
	----------------------------------------------------------------------------------\n
	Parameters:\n
	Initialisation Clock Cycles        : $init_time\n 
	Local Interface Data Width         : $LOCAL_DATA_BITS\n
	Number Address/Command Buses       : $num_addr_cmd_buses\n
	Local Interface Burst Length       : $LOCAL_BURST_LEN\n
	Number DQS Inputs Used             : $NUMBER_DQS\n
	Number DQ Bits per DQS Input       : $MEM_DQ_PER_DQS\n
	Read Data Capture Mode             : $CAPTURE_MODE\n
	Enable DM Pins                     : $enable_dm_pins\n
	Number Memory Address Bits         : $MEM_ADDR_BITS\n
	Number RLDRAM II Memory Devices    : $MEM_NUM_DEVICES\n
	RLDRAM II Memory Type              : $RLDRAMII_TYPE\n
	RLDRAM II Memory Configuration     : $RLDRAMII_CONFIGURATION\n
	Local Address Number Shift Bits    : $ADDR_SHIFT_BITS\n
	Number RLDRAM II Memory tRC Cycles : $MEM_TRC_CYCLES\n
	Number RLDRAM II Memory tWL Cycles : $MEM_TWL_CYCLES\n
	Address and Command Clock          : $addr_cmd_clk\n
	DDIO Memory Clock Generation       : $ddio_memory_clocks\n
	On Die Termination                 : $odt\n
	Impedance Matching                 : $ime\n
	DLL Enable                         : $dlle\n
	----------------------------------------------------------------------------------\n",
);

######################################################################################################################################################################
	if($RLDRAMII_TYPE eq "cio")
	{
		if ($ENABLE_CAPTURE_CLK eq "false") {
			if($enable_addr_cmd_clk eq "true") {
				if($enable_dm_pins eq "true") {
					$module->add_contents
					(
						#####	Ports declaration#	######
						e_port->new({name => "clk",direction => "input"}),
						e_port->new({name => "write_clk",direction => "input"}),
						e_port->new({name => "addr_cmd_clk",direction => "input"}),
						e_port->new({name => "reset_clk_n",direction => "input"}),
						e_port->new({name => "reset_addr_cmd_clk_n",direction => "input"}),
						e_port->new({name => "reset_read_clk_n",direction => "input", width => $MEM_NUM_DEVICES}),
						e_port->new({name => "dqs_delay_ctrl",direction => "input", width => 6}),
						e_port->new({name => "local_write_req",direction => "input"}),
						e_port->new({name => "local_read_req",direction => "input"}),
						e_port->new({name => "local_addr",direction => "input", width => $MEM_ADDR_BITS}),
						e_port->new({name => "local_bank_addr",direction => "input", width => 3}),
						e_port->new({name => "local_wdata_req",direction => "output"}),
						e_port->new({name => "local_wdata",direction => "input", width => $LOCAL_DATA_BITS}),
						e_port->new({name => "local_dm",direction => "input", width => $MEM_NUM_DEVICES * 2}),
						e_port->new({name => "local_refresh_req",direction => "input"}),
						e_port->new({name => $PREFIX_NAME."qk",direction => "input", width => $NUMBER_DQS, declare_one_bit_as_std_logic_vector => 0}),
						e_port->new({name => $PREFIX_NAME."qvld",direction => "input", width => $MEM_NUM_DEVICES, declare_one_bit_as_std_logic_vector => 0}),
						e_port->new({name => "capture_clk",direction => "output", width => $MEM_NUM_DEVICES, declare_one_bit_as_std_logic_vector => 0}),
						e_port->new({name => "local_rdata_valid",direction => "output", width => $MEM_NUM_DEVICES, declare_one_bit_as_std_logic_vector => 0}),
						e_port->new({name => "local_rdata",direction => "output", width => $LOCAL_DATA_BITS}),
						e_port->new({name => "local_init_done",direction => "output"}),
						e_port->new({name => $PREFIX_NAME."a_0",direction => "output", width => $MEM_ADDR_BITS}),
						e_port->new({name => $PREFIX_NAME."ba_0",direction => "output", width => 3}),
					);
					if($num_addr_cmd_buses > 1) {
						$module->add_contents
						(
							e_port->new({name => $PREFIX_NAME."cs_n_1",direction => "output", width => 1}),
							e_port->new({name => $PREFIX_NAME."we_n_1",direction => "output", width => 1}),
							e_port->new({name => $PREFIX_NAME."ref_n_1",direction => "output", width => 1}),
							e_port->new({name => $PREFIX_NAME."a_1",direction => "output", width => $MEM_ADDR_BITS}),
							e_port->new({name => $PREFIX_NAME."ba_1",direction => "output", width => 3}),
						);
					}
					$module->add_contents
						(
						e_port->new({name => $PREFIX_NAME."dm",direction => "output", width => $MEM_NUM_DEVICES, declare_one_bit_as_std_logic_vector => 0}),
						e_port->new({name => $PREFIX_NAME."cs_n_0",direction => "output", width => 1}),
						e_port->new({name => $PREFIX_NAME."we_n_0",direction => "output", width => 1}),
						e_port->new({name => $PREFIX_NAME."ref_n_0",direction => "output", width => 1}),
						e_port->new({name => $PREFIX_NAME."dq",direction => "inout", width => $MEMORY_DATA_WIDTH}),
						#e_port->new({name => $PREFIX_NAME."clk",direction => "output", width => $NUM_CLOCK_PAIRS, declare_one_bit_as_std_logic_vector => 0}),
						#e_port->new({name => $PREFIX_NAME."clk_n",direction => "output", width => $NUM_CLOCK_PAIRS, declare_one_bit_as_std_logic_vector => 0}),
					);
					 if ($ddio_memory_clocks eq "true") {
						 $module->add_contents
						 (
							 e_port->new({name => $PREFIX_NAME."clk",direction => "output", width => $NUM_CLOCK_PAIRS, declare_one_bit_as_std_logic_vector => 0}),
							 e_port->new({name => $PREFIX_NAME."clk_n",direction => "output", width => $NUM_CLOCK_PAIRS, declare_one_bit_as_std_logic_vector => 0}),
						 );
					 }
				} else {
					$module->add_contents
					(
						#####	Ports declaration#	######
						e_port->new({name => "clk",direction => "input"}),
						e_port->new({name => "write_clk",direction => "input"}),
						e_port->new({name => "addr_cmd_clk",direction => "input"}),
						e_port->new({name => "reset_clk_n",direction => "input"}),
						e_port->new({name => "reset_addr_cmd_clk_n",direction => "input"}),
						e_port->new({name => "reset_read_clk_n",direction => "input", width => $MEM_NUM_DEVICES}),
						e_port->new({name => "dqs_delay_ctrl",direction => "input", width => 6}),
						e_port->new({name => "local_write_req",direction => "input"}),
						e_port->new({name => "local_read_req",direction => "input"}),
						e_port->new({name => "local_addr",direction => "input", width => $MEM_ADDR_BITS}),
						e_port->new({name => "local_bank_addr",direction => "input", width => 3}),
						e_port->new({name => "local_wdata_req",direction => "output"}),
						e_port->new({name => "local_wdata",direction => "input", width => $LOCAL_DATA_BITS}),
						#e_port->new({name => "local_dm",direction => "input", width => $MEM_NUM_DEVICES * 2}),
						e_port->new({name => "local_refresh_req",direction => "input"}),
						e_port->new({name => $PREFIX_NAME."qk",direction => "input", width => $NUMBER_DQS, declare_one_bit_as_std_logic_vector => 0}),
						e_port->new({name => $PREFIX_NAME."qvld",direction => "input", width => $MEM_NUM_DEVICES, declare_one_bit_as_std_logic_vector => 0}),
						e_port->new({name => "capture_clk",direction => "output", width => $MEM_NUM_DEVICES, declare_one_bit_as_std_logic_vector => 0}),
						e_port->new({name => "local_rdata_valid",direction => "output", width => $MEM_NUM_DEVICES, declare_one_bit_as_std_logic_vector => 0}),
						e_port->new({name => "local_rdata",direction => "output", width => $LOCAL_DATA_BITS}),
						e_port->new({name => "local_init_done",direction => "output"}),
						e_port->new({name => $PREFIX_NAME."a_0",direction => "output", width => $MEM_ADDR_BITS}),
						e_port->new({name => $PREFIX_NAME."ba_0",direction => "output", width => 3}),
					);
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
					$module->add_contents
						(
						e_port->new({name => $PREFIX_NAME."cs_n_0",direction => "output", width => 1}),
						e_port->new({name => $PREFIX_NAME."we_n_0",direction => "output", width => 1}),
						e_port->new({name => $PREFIX_NAME."ref_n_0",direction => "output", width => 1}),
						e_port->new({name => $PREFIX_NAME."dq",direction => "inout", width => $MEMORY_DATA_WIDTH}),
						#e_port->new({name => $PREFIX_NAME."clk",direction => "output", width => $NUM_CLOCK_PAIRS, declare_one_bit_as_std_logic_vector => 0}),
						#e_port->new({name => $PREFIX_NAME."clk_n",direction => "output", width => $NUM_CLOCK_PAIRS, declare_one_bit_as_std_logic_vector => 0}),
					);
					 if ($ddio_memory_clocks eq "true") {
						 $module->add_contents
						 (
							 e_port->new({name => $PREFIX_NAME."clk",direction => "output", width => $NUM_CLOCK_PAIRS, declare_one_bit_as_std_logic_vector => 0}),
							 e_port->new({name => $PREFIX_NAME."clk_n",direction => "output", width => $NUM_CLOCK_PAIRS, declare_one_bit_as_std_logic_vector => 0}),
						 );
					 }
				}
			}
			else
			{
				if($enable_dm_pins eq "true") {
					$module->add_contents
					(
						#####	Ports declaration#	######
						e_port->new({name => "clk",direction => "input"}),
						e_port->new({name => "write_clk",direction => "input"}),
						e_port->new({name => "reset_clk_n",direction => "input"}),
						e_port->new({name => "reset_addr_cmd_clk_n",direction => "input"}),
						e_port->new({name => "reset_read_clk_n",direction => "input", width => $MEM_NUM_DEVICES}),
						e_port->new({name => "dqs_delay_ctrl",direction => "input", width => 6}),
						e_port->new({name => "local_write_req",direction => "input"}),
						e_port->new({name => "local_read_req",direction => "input"}),
						e_port->new({name => "local_addr",direction => "input", width => $MEM_ADDR_BITS}),
						e_port->new({name => "local_bank_addr",direction => "input", width => 3}),
						e_port->new({name => "local_wdata_req",direction => "output"}),
						e_port->new({name => "local_wdata",direction => "input", width => $LOCAL_DATA_BITS}),
						e_port->new({name => "local_dm",direction => "input", width => $MEM_NUM_DEVICES * 2}),
						e_port->new({name => "local_refresh_req",direction => "input"}),
						e_port->new({name => $PREFIX_NAME."qk",direction => "input", width => $NUMBER_DQS, declare_one_bit_as_std_logic_vector => 0}),
						e_port->new({name => $PREFIX_NAME."qvld",direction => "input", width => $MEM_NUM_DEVICES, declare_one_bit_as_std_logic_vector => 0}),
						e_port->new({name => "capture_clk",direction => "output", width => $MEM_NUM_DEVICES, declare_one_bit_as_std_logic_vector => 0}),
						e_port->new({name => "local_rdata_valid",direction => "output", width => $MEM_NUM_DEVICES, declare_one_bit_as_std_logic_vector => 0}),
						e_port->new({name => "local_rdata",direction => "output", width => $LOCAL_DATA_BITS}),
						e_port->new({name => "local_init_done",direction => "output"}),
						e_port->new({name => $PREFIX_NAME."a_0",direction => "output", width => $MEM_ADDR_BITS}),
						e_port->new({name => $PREFIX_NAME."ba_0",direction => "output", width => 3}),
					);
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
					$module->add_contents
						(
						e_port->new({name => $PREFIX_NAME."dm",direction => "output", width => $MEM_NUM_DEVICES, declare_one_bit_as_std_logic_vector => 0}),
						e_port->new({name => $PREFIX_NAME."cs_n_0",direction => "output", width => 1}),
						e_port->new({name => $PREFIX_NAME."we_n_0",direction => "output", width => 1}),
						e_port->new({name => $PREFIX_NAME."ref_n_0",direction => "output", width => 1}),
						e_port->new({name => $PREFIX_NAME."dq",direction => "inout", width => $MEMORY_DATA_WIDTH}),
						#e_port->new({name => $PREFIX_NAME."clk",direction => "output", width => $NUM_CLOCK_PAIRS, declare_one_bit_as_std_logic_vector => 0}),
						#e_port->new({name => $PREFIX_NAME."clk_n",direction => "output", width => $NUM_CLOCK_PAIRS, declare_one_bit_as_std_logic_vector => 0}),
					);
					if ($ddio_memory_clocks eq "true") {
						 $module->add_contents
						 (
							 e_port->new({name => $PREFIX_NAME."clk",direction => "output", width => $NUM_CLOCK_PAIRS, declare_one_bit_as_std_logic_vector => 0}),
							 e_port->new({name => $PREFIX_NAME."clk_n",direction => "output", width => $NUM_CLOCK_PAIRS, declare_one_bit_as_std_logic_vector => 0}),
						 );
					}
				} else {
					$module->add_contents
					(
						#####	Ports declaration#	######
						e_port->new({name => "clk",direction => "input"}),
						e_port->new({name => "write_clk",direction => "input"}),
						e_port->new({name => "reset_clk_n",direction => "input"}),
						e_port->new({name => "reset_addr_cmd_clk_n",direction => "input"}),
						e_port->new({name => "reset_read_clk_n",direction => "input", width => $MEM_NUM_DEVICES}),
						e_port->new({name => "dqs_delay_ctrl",direction => "input", width => 6}),
						e_port->new({name => "local_write_req",direction => "input"}),
						e_port->new({name => "local_read_req",direction => "input"}),
						e_port->new({name => "local_addr",direction => "input", width => $MEM_ADDR_BITS}),
						e_port->new({name => "local_bank_addr",direction => "input", width => 3}),
						e_port->new({name => "local_wdata_req",direction => "output"}),
						e_port->new({name => "local_wdata",direction => "input", width => $LOCAL_DATA_BITS}),
						#e_port->new({name => "local_dm",direction => "input", width => $MEM_NUM_DEVICES * 2}),
						e_port->new({name => "local_refresh_req",direction => "input"}),
						e_port->new({name => $PREFIX_NAME."qk",direction => "input", width => $NUMBER_DQS, declare_one_bit_as_std_logic_vector => 0}),
						e_port->new({name => $PREFIX_NAME."qvld",direction => "input", width => $MEM_NUM_DEVICES, declare_one_bit_as_std_logic_vector => 0}),
						e_port->new({name => "capture_clk",direction => "output", width => $MEM_NUM_DEVICES, declare_one_bit_as_std_logic_vector => 0}),
						e_port->new({name => "local_rdata_valid",direction => "output", width => $MEM_NUM_DEVICES, declare_one_bit_as_std_logic_vector => 0}),
						e_port->new({name => "local_rdata",direction => "output", width => $LOCAL_DATA_BITS}),
						e_port->new({name => "local_init_done",direction => "output"}),
						e_port->new({name => $PREFIX_NAME."a_0",direction => "output", width => $MEM_ADDR_BITS}),
						e_port->new({name => $PREFIX_NAME."ba_0",direction => "output", width => 3}),
					);
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
					$module->add_contents
						(
						e_port->new({name => $PREFIX_NAME."cs_n_0",direction => "output", width => 1}),
						e_port->new({name => $PREFIX_NAME."we_n_0",direction => "output", width => 1}),
						e_port->new({name => $PREFIX_NAME."ref_n_0",direction => "output", width => 1}),
						e_port->new({name => $PREFIX_NAME."dq",direction => "inout", width => $MEMORY_DATA_WIDTH}),
						#e_port->new({name => $PREFIX_NAME."clk",direction => "output", width => $NUM_CLOCK_PAIRS, declare_one_bit_as_std_logic_vector => 0}),
						#e_port->new({name => $PREFIX_NAME."clk_n",direction => "output", width => $NUM_CLOCK_PAIRS, declare_one_bit_as_std_logic_vector => 0}),
					);
					 if ($ddio_memory_clocks eq "true") {
						 $module->add_contents
						 (
							 e_port->new({name => $PREFIX_NAME."clk",direction => "output", width => $NUM_CLOCK_PAIRS, declare_one_bit_as_std_logic_vector => 0}),
							 e_port->new({name => $PREFIX_NAME."clk_n",direction => "output", width => $NUM_CLOCK_PAIRS, declare_one_bit_as_std_logic_vector => 0}),
						 );
					 }
				}
			}
		}
		else
		{
			if($enable_addr_cmd_clk eq "true") {
				if($enable_dm_pins eq "true") {
					$module->add_contents
					(
						#####	Ports declaration#	######
						e_port->new({name => "clk",direction => "input"}),
						e_port->new({name => "write_clk",direction => "input"}),
						e_port->new({name => "addr_cmd_clk",direction => "input"}),
						e_port->new({name => "reset_clk_n",direction => "input"}),
						e_port->new({name => "reset_addr_cmd_clk_n",direction => "input"}),
						e_port->new({name => "reset_read_clk_n",direction => "input"}),
						e_port->new({name => "non_dqs_capture_clk",direction => "input", width => 1}),
						e_port->new({name => "local_write_req",direction => "input"}),
						e_port->new({name => "local_read_req",direction => "input"}),
						e_port->new({name => "local_addr",direction => "input", width => $MEM_ADDR_BITS}),
						e_port->new({name => "local_bank_addr",direction => "input", width => 3}),
						e_port->new({name => "local_wdata_req",direction => "output"}),
						e_port->new({name => "local_wdata",direction => "input", width => $LOCAL_DATA_BITS}),
						e_port->new({name => "local_dm",direction => "input", width => $MEM_NUM_DEVICES * 2}),
						e_port->new({name => "local_refresh_req",direction => "input"}),
						e_port->new({name => $PREFIX_NAME."qvld",direction => "input", width => $MEM_NUM_DEVICES, declare_one_bit_as_std_logic_vector => 0}),
						e_port->new({name => "local_rdata_valid",direction => "output", width => $MEM_NUM_DEVICES, declare_one_bit_as_std_logic_vector => 0}),
						e_port->new({name => "local_rdata",direction => "output", width => $LOCAL_DATA_BITS}),
						e_port->new({name => "local_init_done",direction => "output"}),
						e_port->new({name => $PREFIX_NAME."a_0",direction => "output", width => $MEM_ADDR_BITS}),
						e_port->new({name => $PREFIX_NAME."ba_0",direction => "output", width => 3}),
					);
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
					$module->add_contents
						(
						e_port->new({name => $PREFIX_NAME."dm",direction => "output", width => $MEM_NUM_DEVICES, declare_one_bit_as_std_logic_vector => 0}),
						e_port->new({name => $PREFIX_NAME."cs_n_0",direction => "output", width => 1}),
						e_port->new({name => $PREFIX_NAME."we_n_0",direction => "output", width => 1}),
						e_port->new({name => $PREFIX_NAME."ref_n_0",direction => "output", width => 1}),
						e_port->new({name => $PREFIX_NAME."dq",direction => "inout", width => $MEMORY_DATA_WIDTH}),
						#e_port->new({name => $PREFIX_NAME."clk",direction => "output", width => $NUM_CLOCK_PAIRS, declare_one_bit_as_std_logic_vector => 0}),
						#e_port->new({name => $PREFIX_NAME."clk_n",direction => "output", width => $NUM_CLOCK_PAIRS, declare_one_bit_as_std_logic_vector => 0}),
					);
					 if ($ddio_memory_clocks eq "true") {
						 $module->add_contents
						 (
							 e_port->new({name => $PREFIX_NAME."clk",direction => "output", width => $NUM_CLOCK_PAIRS, declare_one_bit_as_std_logic_vector => 0}),
							 e_port->new({name => $PREFIX_NAME."clk_n",direction => "output", width => $NUM_CLOCK_PAIRS, declare_one_bit_as_std_logic_vector => 0}),
						 );
					 }
				} else {
					$module->add_contents
					(
						#####	Ports declaration#	######
						e_port->new({name => "clk",direction => "input"}),
						e_port->new({name => "write_clk",direction => "input"}),
						e_port->new({name => "addr_cmd_clk",direction => "input"}),
						e_port->new({name => "reset_clk_n",direction => "input"}),
						e_port->new({name => "reset_addr_cmd_clk_n",direction => "input"}),
						e_port->new({name => "reset_read_clk_n",direction => "input"}),
						e_port->new({name => "non_dqs_capture_clk",direction => "input", width => 1}),
						e_port->new({name => "local_write_req",direction => "input"}),
						e_port->new({name => "local_read_req",direction => "input"}),
						e_port->new({name => "local_addr",direction => "input", width => $MEM_ADDR_BITS}),
						e_port->new({name => "local_bank_addr",direction => "input", width => 3}),
						e_port->new({name => "local_wdata_req",direction => "output"}),
						e_port->new({name => "local_wdata",direction => "input", width => $LOCAL_DATA_BITS}),
						#e_port->new({name => "local_dm",direction => "input", width => $MEM_NUM_DEVICES * 2}),
						e_port->new({name => "local_refresh_req",direction => "input"}),
						e_port->new({name => $PREFIX_NAME."qvld",direction => "input", width => $MEM_NUM_DEVICES, declare_one_bit_as_std_logic_vector => 0}),
						e_port->new({name => "local_rdata_valid",direction => "output", width => $MEM_NUM_DEVICES, declare_one_bit_as_std_logic_vector => 0}),
						e_port->new({name => "local_rdata",direction => "output", width => $LOCAL_DATA_BITS}),
						e_port->new({name => "local_init_done",direction => "output"}),
						e_port->new({name => $PREFIX_NAME."a_0",direction => "output", width => $MEM_ADDR_BITS}),
						e_port->new({name => $PREFIX_NAME."ba_0",direction => "output", width => 3}),
					);
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
					$module->add_contents
						(
						e_port->new({name => $PREFIX_NAME."cs_n_0",direction => "output", width => 1}),
						e_port->new({name => $PREFIX_NAME."we_n_0",direction => "output", width => 1}),
						e_port->new({name => $PREFIX_NAME."ref_n_0",direction => "output", width => 1}),
						e_port->new({name => $PREFIX_NAME."dq",direction => "inout", width => $MEMORY_DATA_WIDTH}),
						#e_port->new({name => $PREFIX_NAME."clk",direction => "output", width => $NUM_CLOCK_PAIRS, declare_one_bit_as_std_logic_vector => 0}),
						#e_port->new({name => $PREFIX_NAME."clk_n",direction => "output", width => $NUM_CLOCK_PAIRS, declare_one_bit_as_std_logic_vector => 0}),
					);
					 if ($ddio_memory_clocks eq "true") {
						 $module->add_contents
						 (
							 e_port->new({name => $PREFIX_NAME."clk",direction => "output", width => $NUM_CLOCK_PAIRS, declare_one_bit_as_std_logic_vector => 0}),
							 e_port->new({name => $PREFIX_NAME."clk_n",direction => "output", width => $NUM_CLOCK_PAIRS, declare_one_bit_as_std_logic_vector => 0}),
						 );
					 }
				}
			}
			else
			{
				if($enable_dm_pins eq "true") {
					$module->add_contents
					(
						#####	Ports declaration#	######
						e_port->new({name => "clk",direction => "input"}),
						e_port->new({name => "write_clk",direction => "input"}),
						e_port->new({name => "reset_clk_n",direction => "input"}),
						e_port->new({name => "reset_addr_cmd_clk_n",direction => "input"}),
						e_port->new({name => "reset_read_clk_n",direction => "input"}),
						e_port->new({name => "non_dqs_capture_clk",direction => "input", width => 1}),
						e_port->new({name => "local_write_req",direction => "input"}),
						e_port->new({name => "local_read_req",direction => "input"}),
						e_port->new({name => "local_addr",direction => "input", width => $MEM_ADDR_BITS}),
						e_port->new({name => "local_bank_addr",direction => "input", width => 3}),
						e_port->new({name => "local_wdata_req",direction => "output"}),
						e_port->new({name => "local_wdata",direction => "input", width => $LOCAL_DATA_BITS}),
						e_port->new({name => "local_dm",direction => "input", width => $MEM_NUM_DEVICES * 2}),
						e_port->new({name => "local_refresh_req",direction => "input"}),
						e_port->new({name => $PREFIX_NAME."qvld",direction => "input", width => $MEM_NUM_DEVICES, declare_one_bit_as_std_logic_vector => 0}),
						e_port->new({name => "local_rdata_valid",direction => "output", width => $MEM_NUM_DEVICES, declare_one_bit_as_std_logic_vector => 0}),
						e_port->new({name => "local_rdata",direction => "output", width => $LOCAL_DATA_BITS}),
						e_port->new({name => "local_init_done",direction => "output"}),
						e_port->new({name => $PREFIX_NAME."a_0",direction => "output", width => $MEM_ADDR_BITS}),
						e_port->new({name => $PREFIX_NAME."ba_0",direction => "output", width => 3}),
					);
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
					$module->add_contents
						(
						e_port->new({name => $PREFIX_NAME."dm",direction => "output", width => $MEM_NUM_DEVICES, declare_one_bit_as_std_logic_vector => 0}),
						e_port->new({name => $PREFIX_NAME."cs_n_0",direction => "output", width => 1}),
						e_port->new({name => $PREFIX_NAME."we_n_0",direction => "output", width => 1}),
						e_port->new({name => $PREFIX_NAME."ref_n_0",direction => "output", width => 1}),
						e_port->new({name => $PREFIX_NAME."dq",direction => "inout", width => $MEMORY_DATA_WIDTH}),
						#e_port->new({name => $PREFIX_NAME."clk",direction => "output", width => $NUM_CLOCK_PAIRS, declare_one_bit_as_std_logic_vector => 0}),
						#e_port->new({name => $PREFIX_NAME."clk_n",direction => "output", width => $NUM_CLOCK_PAIRS, declare_one_bit_as_std_logic_vector => 0}),
					);
					 if ($ddio_memory_clocks eq "true") {
						 $module->add_contents
						 (
							 e_port->new({name => $PREFIX_NAME."clk",direction => "output", width => $NUM_CLOCK_PAIRS, declare_one_bit_as_std_logic_vector => 0}),
							 e_port->new({name => $PREFIX_NAME."clk_n",direction => "output", width => $NUM_CLOCK_PAIRS, declare_one_bit_as_std_logic_vector => 0}),
						 );
					 }
				} else {
					$module->add_contents
					(
						#####	Ports declaration#	######
						e_port->new({name => "clk",direction => "input"}),
						e_port->new({name => "write_clk",direction => "input"}),
						e_port->new({name => "reset_clk_n",direction => "input"}),
						e_port->new({name => "reset_addr_cmd_clk_n",direction => "input"}),
						e_port->new({name => "reset_read_clk_n",direction => "input"}),
						e_port->new({name => "non_dqs_capture_clk",direction => "input", width => 1}),
						e_port->new({name => "local_write_req",direction => "input"}),
						e_port->new({name => "local_read_req",direction => "input"}),
						e_port->new({name => "local_addr",direction => "input", width => $MEM_ADDR_BITS}),
						e_port->new({name => "local_bank_addr",direction => "input", width => 3}),
						e_port->new({name => "local_wdata_req",direction => "output"}),
						e_port->new({name => "local_wdata",direction => "input", width => $LOCAL_DATA_BITS}),
						#e_port->new({name => "local_dm",direction => "input", width => $MEM_NUM_DEVICES * 2}),
						e_port->new({name => "local_refresh_req",direction => "input"}),
						e_port->new({name => $PREFIX_NAME."qvld",direction => "input", width => $MEM_NUM_DEVICES, declare_one_bit_as_std_logic_vector => 0}),
						e_port->new({name => "local_rdata_valid",direction => "output", width => $MEM_NUM_DEVICES, declare_one_bit_as_std_logic_vector => 0}),
						e_port->new({name => "local_rdata",direction => "output", width => $LOCAL_DATA_BITS}),
						e_port->new({name => "local_init_done",direction => "output"}),
						e_port->new({name => $PREFIX_NAME."a_0",direction => "output", width => $MEM_ADDR_BITS}),
						e_port->new({name => $PREFIX_NAME."ba_0",direction => "output", width => 3}),
					);
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
					$module->add_contents
						(
						e_port->new({name => $PREFIX_NAME."cs_n_0",direction => "output", width => 1}),
						e_port->new({name => $PREFIX_NAME."we_n_0",direction => "output", width => 1}),
						e_port->new({name => $PREFIX_NAME."ref_n_0",direction => "output", width => 1}),
						e_port->new({name => $PREFIX_NAME."dq",direction => "inout", width => $MEMORY_DATA_WIDTH}),
						#e_port->new({name => $PREFIX_NAME."clk",direction => "output", width => $NUM_CLOCK_PAIRS, declare_one_bit_as_std_logic_vector => 0}),
						#e_port->new({name => $PREFIX_NAME."clk_n",direction => "output", width => $NUM_CLOCK_PAIRS, declare_one_bit_as_std_logic_vector => 0}),
					);
					 if ($ddio_memory_clocks eq "true") {
						 $module->add_contents
						 (
							 e_port->new({name => $PREFIX_NAME."clk",direction => "output", width => $NUM_CLOCK_PAIRS, declare_one_bit_as_std_logic_vector => 0}),
							 e_port->new({name => $PREFIX_NAME."clk_n",direction => "output", width => $NUM_CLOCK_PAIRS, declare_one_bit_as_std_logic_vector => 0}),
						 );
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
					$module->add_contents
					(
						#####	Ports declaration#	######
						e_port->new({name => "clk",direction => "input"}),
						e_port->new({name => "write_clk",direction => "input"}),
						e_port->new({name => "addr_cmd_clk",direction => "input"}),
						e_port->new({name => "reset_clk_n",direction => "input"}),
						e_port->new({name => "reset_addr_cmd_clk_n",direction => "input"}),
						e_port->new({name => "reset_read_clk_n",direction => "input", width => $MEM_NUM_DEVICES}),
						e_port->new({name => "dqs_delay_ctrl",direction => "input", width => 6}),
						e_port->new({name => "local_write_req",direction => "input"}),
						e_port->new({name => "local_read_req",direction => "input"}),
						e_port->new({name => "local_addr",direction => "input", width => $MEM_ADDR_BITS}),
						e_port->new({name => "local_bank_addr",direction => "input", width => 3}),
						e_port->new({name => "local_wdata_req",direction => "output"}),
						e_port->new({name => "local_wdata",direction => "input", width => $LOCAL_DATA_BITS}),
						e_port->new({name => "local_dm",direction => "input", width => $MEM_NUM_DEVICES * 2}),
						e_port->new({name => "local_refresh_req",direction => "input"}),
						e_port->new({name => $PREFIX_NAME."qk",direction => "input", width => $NUMBER_DQS, declare_one_bit_as_std_logic_vector => 0}),
						e_port->new({name => $PREFIX_NAME."qvld",direction => "input", width => $MEM_NUM_DEVICES, declare_one_bit_as_std_logic_vector => 0}),
						e_port->new({name => $PREFIX_NAME."q",direction => "input", width => $MEMORY_DATA_WIDTH}),
						e_port->new({name => "capture_clk",direction => "output", width => $MEM_NUM_DEVICES, declare_one_bit_as_std_logic_vector => 0}),
						e_port->new({name => "local_rdata_valid",direction => "output", width => $MEM_NUM_DEVICES, declare_one_bit_as_std_logic_vector => 0}),
						e_port->new({name => "local_rdata",direction => "output", width => $LOCAL_DATA_BITS}),
						e_port->new({name => "local_init_done",direction => "output"}),
						e_port->new({name => $PREFIX_NAME."a_0",direction => "output", width => $MEM_ADDR_BITS}),
						e_port->new({name => $PREFIX_NAME."ba_0",direction => "output", width => 3}),
					);
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
					$module->add_contents
						(
						e_port->new({name => $PREFIX_NAME."dm",direction => "output", width => $MEM_NUM_DEVICES, declare_one_bit_as_std_logic_vector => 0}),
						e_port->new({name => $PREFIX_NAME."cs_n_0",direction => "output", width => 1}),
						e_port->new({name => $PREFIX_NAME."we_n_0",direction => "output", width => 1}),
						e_port->new({name => $PREFIX_NAME."ref_n_0",direction => "output", width => 1}),
						e_port->new({name => $PREFIX_NAME."d",direction => "output", width => $MEMORY_DATA_WIDTH}),
						#e_port->new({name => $PREFIX_NAME."clk",direction => "output", width => $NUM_CLOCK_PAIRS, declare_one_bit_as_std_logic_vector => 0}),
						#e_port->new({name => $PREFIX_NAME."clk_n",direction => "output", width => $NUM_CLOCK_PAIRS, declare_one_bit_as_std_logic_vector => 0}),
					);
					 if ($ddio_memory_clocks eq "true") {
						 $module->add_contents
						 (
							 e_port->new({name => $PREFIX_NAME."clk",direction => "output", width => $NUM_CLOCK_PAIRS, declare_one_bit_as_std_logic_vector => 0}),
							 e_port->new({name => $PREFIX_NAME."clk_n",direction => "output", width => $NUM_CLOCK_PAIRS, declare_one_bit_as_std_logic_vector => 0}),
						 );
					 }
				} else {
					$module->add_contents
					(
						#####	Ports declaration#	######
						e_port->new({name => "clk",direction => "input"}),
						e_port->new({name => "write_clk",direction => "input"}),
						e_port->new({name => "addr_cmd_clk",direction => "input"}),
						e_port->new({name => "reset_clk_n",direction => "input"}),
						e_port->new({name => "reset_addr_cmd_clk_n",direction => "input"}),
						e_port->new({name => "reset_read_clk_n",direction => "input", width => $MEM_NUM_DEVICES}),
						e_port->new({name => "dqs_delay_ctrl",direction => "input", width => 6}),
						e_port->new({name => "local_write_req",direction => "input"}),
						e_port->new({name => "local_read_req",direction => "input"}),
						e_port->new({name => "local_addr",direction => "input", width => $MEM_ADDR_BITS}),
						e_port->new({name => "local_bank_addr",direction => "input", width => 3}),
						e_port->new({name => "local_wdata_req",direction => "output"}),
						e_port->new({name => "local_wdata",direction => "input", width => $LOCAL_DATA_BITS}),
						#e_port->new({name => "local_dm",direction => "input", width => $MEM_NUM_DEVICES * 2}),
						e_port->new({name => "local_refresh_req",direction => "input"}),
						e_port->new({name => $PREFIX_NAME."qk",direction => "input", width => $NUMBER_DQS, declare_one_bit_as_std_logic_vector => 0}),
						e_port->new({name => $PREFIX_NAME."qvld",direction => "input", width => $MEM_NUM_DEVICES, declare_one_bit_as_std_logic_vector => 0}),
						e_port->new({name => $PREFIX_NAME."q",direction => "input", width => $MEMORY_DATA_WIDTH}),
						e_port->new({name => "capture_clk",direction => "output", width => $MEM_NUM_DEVICES, declare_one_bit_as_std_logic_vector => 0}),
						e_port->new({name => "local_rdata_valid",direction => "output", width => $MEM_NUM_DEVICES, declare_one_bit_as_std_logic_vector => 0}),
						e_port->new({name => "local_rdata",direction => "output", width => $LOCAL_DATA_BITS}),
						e_port->new({name => "local_init_done",direction => "output"}),
						e_port->new({name => $PREFIX_NAME."a_0",direction => "output", width => $MEM_ADDR_BITS}),
						e_port->new({name => $PREFIX_NAME."ba_0",direction => "output", width => 3}),
					);
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
					$module->add_contents
						(
						e_port->new({name => $PREFIX_NAME."cs_n_0",direction => "output", width => 1}),
						e_port->new({name => $PREFIX_NAME."we_n_0",direction => "output", width => 1}),
						e_port->new({name => $PREFIX_NAME."ref_n_0",direction => "output", width => 1}),
						e_port->new({name => $PREFIX_NAME."d",direction => "output", width => $MEMORY_DATA_WIDTH}),
						#e_port->new({name => $PREFIX_NAME."clk",direction => "output", width => $NUM_CLOCK_PAIRS, declare_one_bit_as_std_logic_vector => 0}),
						#e_port->new({name => $PREFIX_NAME."clk_n",direction => "output", width => $NUM_CLOCK_PAIRS, declare_one_bit_as_std_logic_vector => 0}),
					);
					 if ($ddio_memory_clocks eq "true") {
						 $module->add_contents
						 (
							 e_port->new({name => $PREFIX_NAME."clk",direction => "output", width => $NUM_CLOCK_PAIRS, declare_one_bit_as_std_logic_vector => 0}),
							 e_port->new({name => $PREFIX_NAME."clk_n",direction => "output", width => $NUM_CLOCK_PAIRS, declare_one_bit_as_std_logic_vector => 0}),
						 );
					 }
				}
			}
			else
			{
				if($enable_dm_pins eq "true") {
					$module->add_contents
					(
						#####	Ports declaration#	######
						e_port->new({name => "clk",direction => "input"}),
						e_port->new({name => "write_clk",direction => "input"}),
						e_port->new({name => "reset_clk_n",direction => "input"}),
						e_port->new({name => "reset_addr_cmd_clk_n",direction => "input"}),
						e_port->new({name => "reset_read_clk_n",direction => "input", width => $MEM_NUM_DEVICES}),
						e_port->new({name => "dqs_delay_ctrl",direction => "input", width => 6}),
						e_port->new({name => "local_write_req",direction => "input"}),
						e_port->new({name => "local_read_req",direction => "input"}),
						e_port->new({name => "local_addr",direction => "input", width => $MEM_ADDR_BITS}),
						e_port->new({name => "local_bank_addr",direction => "input", width => 3}),
						e_port->new({name => "local_wdata_req",direction => "output"}),
						e_port->new({name => "local_wdata",direction => "input", width => $LOCAL_DATA_BITS}),
						e_port->new({name => "local_dm",direction => "input", width => $MEM_NUM_DEVICES * 2}),
						e_port->new({name => "local_refresh_req",direction => "input"}),
						e_port->new({name => $PREFIX_NAME."qk",direction => "input", width => $NUMBER_DQS, declare_one_bit_as_std_logic_vector => 0}),
						e_port->new({name => $PREFIX_NAME."qvld",direction => "input", width => $MEM_NUM_DEVICES, declare_one_bit_as_std_logic_vector => 0}),
						e_port->new({name => $PREFIX_NAME."q",direction => "input", width => $MEMORY_DATA_WIDTH}),
						e_port->new({name => "capture_clk",direction => "output", width => $MEM_NUM_DEVICES, declare_one_bit_as_std_logic_vector => 0}),
						e_port->new({name => "local_rdata_valid",direction => "output", width => $MEM_NUM_DEVICES, declare_one_bit_as_std_logic_vector => 0}),
						e_port->new({name => "local_rdata",direction => "output", width => $LOCAL_DATA_BITS}),
						e_port->new({name => "local_init_done",direction => "output"}),
						e_port->new({name => $PREFIX_NAME."a_0",direction => "output", width => $MEM_ADDR_BITS}),
						e_port->new({name => $PREFIX_NAME."ba_0",direction => "output", width => 3}),
					);
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
					$module->add_contents
						(
						e_port->new({name => $PREFIX_NAME."dm",direction => "output", width => $MEM_NUM_DEVICES, declare_one_bit_as_std_logic_vector => 0}),
						e_port->new({name => $PREFIX_NAME."cs_n_0",direction => "output", width => 1}),
						e_port->new({name => $PREFIX_NAME."we_n_0",direction => "output", width => 1}),
						e_port->new({name => $PREFIX_NAME."ref_n_0",direction => "output", width => 1}),
						e_port->new({name => $PREFIX_NAME."d",direction => "output", width => $MEMORY_DATA_WIDTH}),
						#e_port->new({name => $PREFIX_NAME."clk",direction => "output", width => $NUM_CLOCK_PAIRS, declare_one_bit_as_std_logic_vector => 0}),
						#e_port->new({name => $PREFIX_NAME."clk_n",direction => "output", width => $NUM_CLOCK_PAIRS, declare_one_bit_as_std_logic_vector => 0}),
					);
					 if ($ddio_memory_clocks eq "true") {
						 $module->add_contents
						 (
							 e_port->new({name => $PREFIX_NAME."clk",direction => "output", width => $NUM_CLOCK_PAIRS, declare_one_bit_as_std_logic_vector => 0}),
							 e_port->new({name => $PREFIX_NAME."clk_n",direction => "output", width => $NUM_CLOCK_PAIRS, declare_one_bit_as_std_logic_vector => 0}),
						 );
					 }
				} else {
					$module->add_contents
					(
						#####	Ports declaration#	######
						e_port->new({name => "clk",direction => "input"}),
						e_port->new({name => "write_clk",direction => "input"}),
						e_port->new({name => "reset_clk_n",direction => "input"}),
						e_port->new({name => "reset_addr_cmd_clk_n",direction => "input"}),
						e_port->new({name => "reset_read_clk_n",direction => "input", width => $MEM_NUM_DEVICES}),
						e_port->new({name => "dqs_delay_ctrl",direction => "input", width => 6}),
						e_port->new({name => "local_write_req",direction => "input"}),
						e_port->new({name => "local_read_req",direction => "input"}),
						e_port->new({name => "local_addr",direction => "input", width => $MEM_ADDR_BITS}),
						e_port->new({name => "local_bank_addr",direction => "input", width => 3}),
						e_port->new({name => "local_wdata_req",direction => "output"}),
						e_port->new({name => "local_wdata",direction => "input", width => $LOCAL_DATA_BITS}),
						#e_port->new({name => "local_dm",direction => "input", width => $MEM_NUM_DEVICES * 2}),
						e_port->new({name => "local_refresh_req",direction => "input"}),
						e_port->new({name => $PREFIX_NAME."qk",direction => "input", width => $NUMBER_DQS, declare_one_bit_as_std_logic_vector => 0}),
						e_port->new({name => $PREFIX_NAME."qvld",direction => "input", width => $MEM_NUM_DEVICES, declare_one_bit_as_std_logic_vector => 0}),
						e_port->new({name => $PREFIX_NAME."q",direction => "input", width => $MEMORY_DATA_WIDTH}),
						e_port->new({name => "capture_clk",direction => "output", width => $MEM_NUM_DEVICES, declare_one_bit_as_std_logic_vector => 0}),
						e_port->new({name => "local_rdata_valid",direction => "output", width => $MEM_NUM_DEVICES, declare_one_bit_as_std_logic_vector => 0}),
						e_port->new({name => "local_rdata",direction => "output", width => $LOCAL_DATA_BITS}),
						e_port->new({name => "local_init_done",direction => "output"}),
						e_port->new({name => $PREFIX_NAME."a",direction => "output", width => $MEM_ADDR_BITS}),
						e_port->new({name => $PREFIX_NAME."ba",direction => "output", width => 3}),
						e_port->new({name => $PREFIX_NAME."cs_n",direction => "output", width => $num_addr_cmd_buses, declare_one_bit_as_std_logic_vector => 0}),
						e_port->new({name => $PREFIX_NAME."we_n",direction => "output", width => $num_addr_cmd_buses, declare_one_bit_as_std_logic_vector => 0}),
						e_port->new({name => $PREFIX_NAME."ref_n",direction => "output", width => $num_addr_cmd_buses, declare_one_bit_as_std_logic_vector => 0}),
						e_port->new({name => $PREFIX_NAME."d",direction => "output", width => $MEMORY_DATA_WIDTH}),
						#e_port->new({name => $PREFIX_NAME."clk",direction => "output", width => $NUM_CLOCK_PAIRS, declare_one_bit_as_std_logic_vector => 0}),
						#e_port->new({name => $PREFIX_NAME."clk_n",direction => "output", width => $NUM_CLOCK_PAIRS, declare_one_bit_as_std_logic_vector => 0}),
					);
					if ($ddio_memory_clocks eq "true") {
						 $module->add_contents
						 (
							 e_port->new({name => $PREFIX_NAME."clk",direction => "output", width => $NUM_CLOCK_PAIRS, declare_one_bit_as_std_logic_vector => 0}),
							 e_port->new({name => $PREFIX_NAME."clk_n",direction => "output", width => $NUM_CLOCK_PAIRS, declare_one_bit_as_std_logic_vector => 0}),
						 );
					}
				}
			}
		}
		else
		{
			if($enable_addr_cmd_clk eq "true") {
				if($enable_dm_pins eq "true") {
					$module->add_contents
					(
						#####	Ports declaration#	######
						e_port->new({name => "clk",direction => "input"}),
						e_port->new({name => "write_clk",direction => "input"}),
						e_port->new({name => "addr_cmd_clk",direction => "input"}),
						e_port->new({name => "reset_clk_n",direction => "input"}),
						e_port->new({name => "reset_addr_cmd_clk_n",direction => "input"}),
						e_port->new({name => "reset_read_clk_n",direction => "input"}),
						e_port->new({name => "non_dqs_capture_clk",direction => "input", width => 1}),
						e_port->new({name => "local_write_req",direction => "input"}),
						e_port->new({name => "local_read_req",direction => "input"}),
						e_port->new({name => "local_addr",direction => "input", width => $MEM_ADDR_BITS}),
						e_port->new({name => "local_bank_addr",direction => "input", width => 3}),
						e_port->new({name => "local_wdata_req",direction => "output"}),
						e_port->new({name => "local_wdata",direction => "input", width => $LOCAL_DATA_BITS}),
						e_port->new({name => "local_dm",direction => "input", width => $MEM_NUM_DEVICES * 2}),
						e_port->new({name => "local_refresh_req",direction => "input"}),
						e_port->new({name => $PREFIX_NAME."qvld",direction => "input", width => $MEM_NUM_DEVICES, declare_one_bit_as_std_logic_vector => 0}),
						e_port->new({name => $PREFIX_NAME."q",direction => "input", width => $MEMORY_DATA_WIDTH}),
						e_port->new({name => "local_rdata_valid",direction => "output", width => $MEM_NUM_DEVICES, declare_one_bit_as_std_logic_vector => 0}),
						e_port->new({name => "local_rdata",direction => "output", width => $LOCAL_DATA_BITS}),
						e_port->new({name => "local_init_done",direction => "output"}),
						e_port->new({name => $PREFIX_NAME."a_0",direction => "output", width => $MEM_ADDR_BITS}),
						e_port->new({name => $PREFIX_NAME."ba_0",direction => "output", width => 3}),
					);
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
					$module->add_contents
						(
						e_port->new({name => $PREFIX_NAME."dm",direction => "output", width => $MEM_NUM_DEVICES, declare_one_bit_as_std_logic_vector => 0}),
						e_port->new({name => $PREFIX_NAME."cs_n_0",direction => "output", width => 1}),
						e_port->new({name => $PREFIX_NAME."we_n_0",direction => "output", width => 1}),
						e_port->new({name => $PREFIX_NAME."ref_n_0",direction => "output", width => 1}),
						e_port->new({name => $PREFIX_NAME."d",direction => "output", width => $MEMORY_DATA_WIDTH}),
						#e_port->new({name => $PREFIX_NAME."clk",direction => "output", width => $NUM_CLOCK_PAIRS, declare_one_bit_as_std_logic_vector => 0}),
						#e_port->new({name => $PREFIX_NAME."clk_n",direction => "output", width => $NUM_CLOCK_PAIRS, declare_one_bit_as_std_logic_vector => 0}),
					);
					 if ($ddio_memory_clocks eq "true") {
						 $module->add_contents
						 (
							 e_port->new({name => $PREFIX_NAME."clk",direction => "output", width => $NUM_CLOCK_PAIRS, declare_one_bit_as_std_logic_vector => 0}),
							 e_port->new({name => $PREFIX_NAME."clk_n",direction => "output", width => $NUM_CLOCK_PAIRS, declare_one_bit_as_std_logic_vector => 0}),
						 );
					 }
				} else {
					$module->add_contents
					(
						#####	Ports declaration#	######
						e_port->new({name => "clk",direction => "input"}),
						e_port->new({name => "write_clk",direction => "input"}),
						e_port->new({name => "addr_cmd_clk",direction => "input"}),
						e_port->new({name => "reset_clk_n",direction => "input"}),
						e_port->new({name => "reset_addr_cmd_clk_n",direction => "input"}),
						e_port->new({name => "reset_read_clk_n",direction => "input"}),
						e_port->new({name => "non_dqs_capture_clk",direction => "input", width => 1}),
						e_port->new({name => "local_write_req",direction => "input"}),
						e_port->new({name => "local_read_req",direction => "input"}),
						e_port->new({name => "local_addr",direction => "input", width => $MEM_ADDR_BITS}),
						e_port->new({name => "local_bank_addr",direction => "input", width => 3}),
						e_port->new({name => "local_wdata_req",direction => "output"}),
						e_port->new({name => "local_wdata",direction => "input", width => $LOCAL_DATA_BITS}),
						#e_port->new({name => "local_dm",direction => "input", width => $MEM_NUM_DEVICES * 2}),
						e_port->new({name => "local_refresh_req",direction => "input"}),
						e_port->new({name => $PREFIX_NAME."qvld",direction => "input", width => $MEM_NUM_DEVICES, declare_one_bit_as_std_logic_vector => 0}),
						e_port->new({name => $PREFIX_NAME."q",direction => "input", width => $MEMORY_DATA_WIDTH}),
						e_port->new({name => "local_rdata_valid",direction => "output", width => $MEM_NUM_DEVICES, declare_one_bit_as_std_logic_vector => 0}),
						e_port->new({name => "local_rdata",direction => "output", width => $LOCAL_DATA_BITS}),
						e_port->new({name => "local_init_done",direction => "output"}),
						e_port->new({name => $PREFIX_NAME."a_0",direction => "output", width => $MEM_ADDR_BITS}),
						e_port->new({name => $PREFIX_NAME."ba_0",direction => "output", width => 3}),
					);
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
					$module->add_contents
						(
						e_port->new({name => $PREFIX_NAME."cs_n_0",direction => "output", width => 1}),
						e_port->new({name => $PREFIX_NAME."we_n_0",direction => "output", width => 1}),
						e_port->new({name => $PREFIX_NAME."ref_n_0",direction => "output", width => 1}),
						e_port->new({name => $PREFIX_NAME."d",direction => "output", width => $MEMORY_DATA_WIDTH}),
						#e_port->new({name => $PREFIX_NAME."clk",direction => "output", width => $NUM_CLOCK_PAIRS, declare_one_bit_as_std_logic_vector => 0}),
						#e_port->new({name => $PREFIX_NAME."clk_n",direction => "output", width => $NUM_CLOCK_PAIRS, declare_one_bit_as_std_logic_vector => 0}),
					);
					 if ($ddio_memory_clocks eq "true") {
						 $module->add_contents
						 (
							 e_port->new({name => $PREFIX_NAME."clk",direction => "output", width => $NUM_CLOCK_PAIRS, declare_one_bit_as_std_logic_vector => 0}),
							 e_port->new({name => $PREFIX_NAME."clk_n",direction => "output", width => $NUM_CLOCK_PAIRS, declare_one_bit_as_std_logic_vector => 0}),
						 );
					 }
				}
			}
			else
			{
				if($enable_dm_pins eq "true") {
					$module->add_contents
					(
						#####	Ports declaration#	######
						e_port->new({name => "clk",direction => "input"}),
						e_port->new({name => "write_clk",direction => "input"}),
						e_port->new({name => "reset_clk_n",direction => "input"}),
						e_port->new({name => "reset_addr_cmd_clk_n",direction => "input"}),
						e_port->new({name => "reset_read_clk_n",direction => "input"}),
						e_port->new({name => "non_dqs_capture_clk",direction => "input", width => 1}),
						e_port->new({name => "local_write_req",direction => "input"}),
						e_port->new({name => "local_read_req",direction => "input"}),
						e_port->new({name => "local_addr",direction => "input", width => $MEM_ADDR_BITS}),
						e_port->new({name => "local_bank_addr",direction => "input", width => 3}),
						e_port->new({name => "local_wdata_req",direction => "output"}),
						e_port->new({name => "local_wdata",direction => "input", width => $LOCAL_DATA_BITS}),
						e_port->new({name => "local_dm",direction => "input", width => $MEM_NUM_DEVICES * 2}),
						e_port->new({name => "local_refresh_req",direction => "input"}),
						e_port->new({name => $PREFIX_NAME."qvld",direction => "input", width => $MEM_NUM_DEVICES, declare_one_bit_as_std_logic_vector => 0}),
						e_port->new({name => $PREFIX_NAME."q",direction => "input", width => $MEMORY_DATA_WIDTH}),
						e_port->new({name => "local_rdata_valid",direction => "output", width => $MEM_NUM_DEVICES, declare_one_bit_as_std_logic_vector => 0}),
						e_port->new({name => "local_rdata",direction => "output", width => $LOCAL_DATA_BITS}),
						e_port->new({name => "local_init_done",direction => "output"}),
						e_port->new({name => $PREFIX_NAME."a_0",direction => "output", width => $MEM_ADDR_BITS}),
						e_port->new({name => $PREFIX_NAME."ba_0",direction => "output", width => 3}),
					);
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
					$module->add_contents
						(
						e_port->new({name => $PREFIX_NAME."dm",direction => "output", width => $MEM_NUM_DEVICES, declare_one_bit_as_std_logic_vector => 0}),
						e_port->new({name => $PREFIX_NAME."cs_n_0",direction => "output", width => 1}),
						e_port->new({name => $PREFIX_NAME."we_n_0",direction => "output", width => 1}),
						e_port->new({name => $PREFIX_NAME."ref_n_0",direction => "output", width => 1}),
						e_port->new({name => $PREFIX_NAME."d",direction => "output", width => $MEMORY_DATA_WIDTH}),
						#e_port->new({name => $PREFIX_NAME."clk",direction => "output", width => $NUM_CLOCK_PAIRS, declare_one_bit_as_std_logic_vector => 0}),
						#e_port->new({name => $PREFIX_NAME."clk_n",direction => "output", width => $NUM_CLOCK_PAIRS, declare_one_bit_as_std_logic_vector => 0}),
					);
					 if ($ddio_memory_clocks eq "true") {
						 $module->add_contents
						 (
							 e_port->new({name => $PREFIX_NAME."clk",direction => "output", width => $NUM_CLOCK_PAIRS, declare_one_bit_as_std_logic_vector => 0}),
							 e_port->new({name => $PREFIX_NAME."clk_n",direction => "output", width => $NUM_CLOCK_PAIRS, declare_one_bit_as_std_logic_vector => 0}),
						 );
					 }
				} else {
					$module->add_contents
					(
						#####	Ports declaration#	######
						e_port->new({name => "clk",direction => "input"}),
						e_port->new({name => "write_clk",direction => "input"}),
						e_port->new({name => "reset_clk_n",direction => "input"}),
						e_port->new({name => "reset_addr_cmd_clk_n",direction => "input"}),
						e_port->new({name => "reset_read_clk_n",direction => "input"}),
						e_port->new({name => "non_dqs_capture_clk",direction => "input", width => 1}),
						e_port->new({name => "local_write_req",direction => "input"}),
						e_port->new({name => "local_read_req",direction => "input"}),
						e_port->new({name => "local_addr",direction => "input", width => $MEM_ADDR_BITS}),
						e_port->new({name => "local_bank_addr",direction => "input", width => 3}),
						e_port->new({name => "local_wdata_req",direction => "output"}),
						e_port->new({name => "local_wdata",direction => "input", width => $LOCAL_DATA_BITS}),
						#e_port->new({name => "local_dm",direction => "input", width => $MEM_NUM_DEVICES * 2}),
						e_port->new({name => "local_refresh_req",direction => "input"}),
						e_port->new({name => $PREFIX_NAME."qvld",direction => "input", width => $MEM_NUM_DEVICES, declare_one_bit_as_std_logic_vector => 0}),
						e_port->new({name => $PREFIX_NAME."q",direction => "input", width => $MEMORY_DATA_WIDTH}),
						e_port->new({name => "local_rdata_valid",direction => "output", width => $MEM_NUM_DEVICES, declare_one_bit_as_std_logic_vector => 0}),
						e_port->new({name => "local_rdata",direction => "output", width => $LOCAL_DATA_BITS}),
						e_port->new({name => "local_init_done",direction => "output"}),
						e_port->new({name => $PREFIX_NAME."a_0",direction => "output", width => $MEM_ADDR_BITS}),
						e_port->new({name => $PREFIX_NAME."ba_0",direction => "output", width => 3}),
					);
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
					$module->add_contents
						(
						e_port->new({name => $PREFIX_NAME."cs_n_0",direction => "output", width => 1}),
						e_port->new({name => $PREFIX_NAME."we_n_0",direction => "output", width => 1}),
						e_port->new({name => $PREFIX_NAME."ref_n_0",direction => "output", width => 1}),
						e_port->new({name => $PREFIX_NAME."d",direction => "output", width => $MEMORY_DATA_WIDTH}),
						#e_port->new({name => $PREFIX_NAME."clk",direction => "output", width => $NUM_CLOCK_PAIRS, declare_one_bit_as_std_logic_vector => 0}),
						#e_port->new({name => $PREFIX_NAME."clk_n",direction => "output", width => $NUM_CLOCK_PAIRS, declare_one_bit_as_std_logic_vector => 0}),
					);
					 if ($ddio_memory_clocks eq "true") {
						 $module->add_contents
						 (
							 e_port->new({name => $PREFIX_NAME."clk",direction => "output", width => $NUM_CLOCK_PAIRS, declare_one_bit_as_std_logic_vector => 0}),
							 e_port->new({name => $PREFIX_NAME."clk_n",direction => "output", width => $NUM_CLOCK_PAIRS, declare_one_bit_as_std_logic_vector => 0}),
						 );
					 }
				}
			}
		}
	};

#################################################################################################################################################################
if($enable_dm_pins eq "false") {
	$module->add_contents
	(
		e_signal->news #: ["signal", width, export, never_export]
		(	 
			["local_dm", $MEM_NUM_DEVICES * 2,	0,	1],
		),
		e_assign->new({lhs => "local_dm", rhs => "0"}),
	);
}
	 
	
	$module->add_contents
	 (
	 #####   signal generation #####
         	e_signal->news #: ["signal", width, export, never_export]
		(	 
			#["local_ba",3,	0,	1],
			["capture_clk",$MEM_NUM_DEVICES,	0,	1],
	     	 	["control_doing_wr",1,	0,	1],
			["control_wdata_valid",1,	0,	1],
			["control_wdata",$MEMORY_DATA_WIDTH * 2,	0,	1],
			["control_cs_n",1,	0,	1],
			["control_we_n",1,	0,	1],
			["control_ref_n",1,	0,	1],
			["control_a",$MEM_ADDR_BITS,	0,	1],
			["control_ba",3,	0,	1],
			["control_dm",$MEM_NUM_DEVICES * 2,	0,	1],
			["control_qvld",$MEM_NUM_DEVICES,	0,	1],
			["control_rdata_valid",1,	0,	1],
			["control_rdata",$MEMORY_DATA_WIDTH * 2,	0,	1],
			["mem_odt_en",1,	0,	1],
			["mem_impedance_matching_en",1,	0,	1],
			["mem_dll_en",1,	0,	1],
			["mem_tinit_burst_len",2,	0,	1],
			["mem_configuration",3,	0,	1],
			["mem_tinit_time",16,	0,	1],
		),
		# e_parameter->new(["gADDR_CMD_NEGEDGE",$addr_cmd_negedge,"string"]),
		# e_parameter->new(["gENABLE_ADDR_CMD_CLK",$enable_addr_cmd_clk,"string"]),
		# e_parameter->new(["gINSERT_ADDR_CMD_NEGEDGE_REG",$insert_addr_cmd_negedge_reg,"string"]),
		# e_parameter->new(["gLOCAL_DATA_BITS",$LOCAL_DATA_BITS,"integer"]),
		# e_parameter->new(["gLOCAL_DATA_MODE",$LOCAL_DATA_MODE,"string"]),
		# e_parameter->new(["gLOCAL_BURST_LEN",$LOCAL_BURST_LEN,"integer"]),
		# e_parameter->new(["gCONTROL_DATA_BITS",$MEMORY_DATA_WIDTH * 2,"integer"]),
		# e_parameter->new(["gMEM_ADDR_BITS",$MEM_ADDR_BITS,"integer"]),
		# e_parameter->new(["gMEM_DQ_PER_DQS",$MEM_DQ_PER_DQS,"integer"]),
		# e_parameter->new(["gMEM_NUM_DEVICES",$MEM_NUM_DEVICES,"integer"]),
		# e_parameter->new(["gMEM_TRC_CYCLES",$MEM_TRC_CYCLES,"integer"]),
		# e_parameter->new(["gMEM_TWL_CYCLES",$MEM_TWL_CYCLES,"integer"]),
		# e_parameter->new(["gRLDRAMII_TYPE",$RLDRAMII_TYPE,"string"]),
		# e_parameter->new(["gREFRESH_COMMAND",$REFRESH_COMMAND,"string"]),
		# e_parameter->new(["gNUM_PIPELINE_WDATA_STAGES",$NUM_PIPELINE_WDATA_STAGES,"integer"]),
		# e_parameter->new(["gNUM_PIPELINE_ADDR_CMD_STAGES",$NUM_PIPELINE_ADDR_CMD_STAGES,"integer"]),
	 );	
	 

#########################################################################################################################################################	 

	$module->add_contents
	(
		 e_assign->new({lhs => "mem_odt_en", rhs => "$ondietermination"}),
		 e_assign->new({lhs => "mem_impedance_matching_en", rhs => "$impedance_matching"}),
		 e_assign->new({lhs => "mem_dll_en", rhs => "$dll_enable"}),
		 e_assign->new({lhs => "mem_tinit_burst_len", rhs => "$MEMORY_BURST_LEN_CONFIG"}),
		 e_assign->new({lhs => "mem_configuration", rhs => "$RLDRAMII_CONFIGURATION"}),
		 e_assign->new({lhs => "mem_tinit_time", rhs => "$init_time"}),
		 #e_assign->new({lhs => "mem_tinit_time", rhs => "60006"}),
	 );
#################################################################################################################################################################
	 
	$module->add_contents
       		(
			e_comment->new({comment => "Instantiate RLDRAM II Controller"}),
			e_blind_instance->new
			({
				name 		=> "rldramii_control",            
				module 		=> $gWRAPPER_NAME."_auk_rldramii_controller_ipfs_wrapper",
				_use_vlog_rtl_param =>   1,
				comment 	=> "---------------------------------------------------------------------\n
				RLDRAM II Controller\n
				---------------------------------------------------------------------\n",
				in_port_map 	=>
				{
					clk => "clk",
					reset_clk_n => "reset_clk_n",
					local_write_req => "local_write_req",
					local_read_req => "local_read_req",
					local_addr => "local_addr",
					local_bank_addr => "local_bank_addr",
					local_wdata => "local_wdata",
					local_dm => "local_dm",
					local_refresh_req => "local_refresh_req",
					control_qvld => "control_qvld",#[]",
					control_rdata => "control_rdata",
					mem_odt_en => "mem_odt_en",
					mem_impedance_matching_en => "mem_impedance_matching_en",
					mem_dll_en => "mem_dll_en",
					mem_tinit_burst_len => "mem_tinit_burst_len",
					mem_configuration => "mem_configuration",
					mem_tinit_time => "mem_tinit_time",
				},

				out_port_map	=>
				{
					local_wdata_req => "local_wdata_req",
					local_rdata_valid => "local_rdata_valid",#[]",
					local_rdata => "local_rdata",
					local_init_done => "local_init_done",
					control_doing_wr => "control_doing_wr",
					control_wdata_valid => "control_wdata_valid",
					control_wdata => "control_wdata",
					control_cs_n => "control_cs_n",
					control_we_n => "control_we_n",
					control_ref_n => "control_ref_n",
					control_a => "control_a",
					control_ba => "control_ba",
					control_dm => "control_dm",
				},
				
				# parameter_map 	=>
				# {
				# 	gMEM_ADDR_BITS		=> $MEM_ADDR_BITS,
				# 	gMEM_DQ_PER_DQS		=> $MEM_DQ_PER_DQS,
				# 	gMEM_NUM_DEVICES	=> $MEM_NUM_DEVICES,
				# 	gMEM_TRC_CYCLES		=> $MEM_TRC_CYCLES,
				# 	gMEM_TWL_CYCLES		=> $MEM_TWL_CYCLES,
					
				# 	gLOCAL_DATA_BITS	=> $LOCAL_DATA_BITS,
				# 	gLOCAL_DATA_MODE	=> '"'.$LOCAL_DATA_MODE.'"',
				# 	gLOCAL_BURST_LEN	=> $LOCAL_BURST_LEN,
				# 	gCONTROL_DATA_BITS	=> $MEMORY_DATA_WIDTH * 2,
					
				# 	gADDR_CMD_NEGEDGE	=> '"'.$addr_cmd_negedge.'"',
				# 	gENABLE_ADDR_CMD_CLK	=> '"'.$enable_addr_cmd_clk.'"',
				# 	gINSERT_ADDR_CMD_NEGEDGE_REG => '"'.$insert_addr_cmd_negedge_reg.'"',
				# 	gNUM_PIPELINE_ADDR_CMD_STAGES => $NUM_PIPELINE_ADDR_CMD_STAGES,
				# 	gNUM_PIPELINE_WDATA_STAGES => $NUM_PIPELINE_WDATA_STAGES,
				# 	gRLDRAMII_TYPE		=> '"'.$RLDRAMII_TYPE.'"',
				# 	gREFRESH_COMMAND	=> '"'.$REFRESH_COMMAND.'"',
				# },
				
				# std_logic_vector_signals	=>
				# [
				# 	control_qvld, local_rdata_valid,
				# ]
			}),
		);

#################################################################################################################################################################		
	if($RLDRAMII_TYPE eq "cio")
	{
		if ($ENABLE_CAPTURE_CLK eq "false") {
			if($enable_addr_cmd_clk eq "false") {
				if($enable_dm_pins eq "true") {
					if($num_addr_cmd_buses == 1) {
						if ($ddio_memory_clocks eq "true") {
							$module->add_contents
							(
								e_comment->new({comment => "Instantiate CIO RLDRAM II Datapath"}),
								e_blind_instance->new
								({
									name 		=> "rldramii_io",            
									module 		=> $gWRAPPER_NAME."_auk_rldramii_datapath",
									comment 	=> "---------------------------------------------------------------------\n
									RLDRAM II Controller Datapath\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk 		=> "clk",
										write_clk 	=> "write_clk",
										reset_clk_n	=> "reset_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										dqs_delay_ctrl 	=> "dqs_delay_ctrl",
										rldramii_qvld	=> $PREFIX_NAME."qvld",
										control_doing_wr => "control_doing_wr",
										control_wdata_valid => "control_wdata_valid",
										control_wdata	=> "control_wdata",
										control_cs_n	=> "control_cs_n",
										control_we_n	=> "control_we_n",
										control_ref_n	=> "control_ref_n",
										control_a	=> "control_a",
										control_ba	=> "control_ba",
										control_dm	=> "control_dm",
                                        rldramii_qk	=> $PREFIX_NAME."qk",
									},
					
									out_port_map	=>
									{
										capture_clk 	=> "capture_clk",#[]",
										rldramii_clk    => $PREFIX_NAME."clk",
										rldramii_clk_n  => $PREFIX_NAME."clk_n",
										rldramii_cs_n_0	=> $PREFIX_NAME."cs_n_0",
										rldramii_we_n_0	=> $PREFIX_NAME."we_n_0",
										rldramii_ref_n_0 => $PREFIX_NAME."ref_n_0",
										rldramii_dm	=> $PREFIX_NAME."dm",#[]",
										rldramii_a_0	=> $PREFIX_NAME."a_0",
										rldramii_ba_0	=> $PREFIX_NAME."ba_0",
										control_qvld	=> "control_qvld",#[]",
										control_rdata	=> "control_rdata",
									},
									
									inout_port_map	=>
									{
										#rldramii_qk	=> $PREFIX_NAME."qk",#[]",
										rldramii_dq 	=> $PREFIX_NAME."dq",					
									},
								}),
							);
						} else {
							$module->add_contents
							(
								e_comment->new({comment => "Instantiate CIO RLDRAM II Datapath"}),
								e_blind_instance->new
								({
									name 		=> "rldramii_io",            
									module 		=> $gWRAPPER_NAME."_auk_rldramii_datapath",
									comment 	=> "---------------------------------------------------------------------\n
									RLDRAM II Controller Datapath\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk 		=> "clk",
										write_clk 	=> "write_clk",
										reset_clk_n	=> "reset_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										dqs_delay_ctrl 	=> "dqs_delay_ctrl",
										rldramii_qvld	=> $PREFIX_NAME."qvld",
										control_doing_wr => "control_doing_wr",
										control_wdata_valid => "control_wdata_valid",
										control_wdata	=> "control_wdata",
										control_cs_n	=> "control_cs_n",
										control_we_n	=> "control_we_n",
										control_ref_n	=> "control_ref_n",
										control_a	=> "control_a",
										control_ba	=> "control_ba",
										control_dm	=> "control_dm",
                                        rldramii_qk	=> $PREFIX_NAME."qk",
									},
					
									out_port_map	=>
									{
										capture_clk 	=> "capture_clk",#[]",
										rldramii_cs_n_0	=> $PREFIX_NAME."cs_n_0",
										rldramii_we_n_0	=> $PREFIX_NAME."we_n_0",
										rldramii_ref_n_0 => $PREFIX_NAME."ref_n_0",
										rldramii_dm	=> $PREFIX_NAME."dm",#[]",
										rldramii_a_0	=> $PREFIX_NAME."a_0",
										rldramii_ba_0	=> $PREFIX_NAME."ba_0",
										control_qvld	=> "control_qvld",#[]",
										control_rdata	=> "control_rdata",
									},
									
									inout_port_map	=>
									{
										#rldramii_qk	=> $PREFIX_NAME."qk",#[]",
										rldramii_dq 	=> $PREFIX_NAME."dq",					
									},
								}),
							);
						}
					}
					
					if($num_addr_cmd_buses > 1) {
						if ($ddio_memory_clocks eq "true") {
							$module->add_contents
							(
								e_comment->new({comment => "Instantiate CIO RLDRAM II Datapath"}),
								e_blind_instance->new
								({
									name 		=> "rldramii_io",            
									module 		=> $gWRAPPER_NAME."_auk_rldramii_datapath",
									comment 	=> "---------------------------------------------------------------------\n
									RLDRAM II Controller Datapath\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk 		=> "clk",
										write_clk 	=> "write_clk",
										reset_clk_n	=> "reset_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										dqs_delay_ctrl 	=> "dqs_delay_ctrl",
										rldramii_qvld	=> $PREFIX_NAME."qvld",
										control_doing_wr => "control_doing_wr",
										control_wdata_valid => "control_wdata_valid",
										control_wdata	=> "control_wdata",
										control_cs_n	=> "control_cs_n",
										control_we_n	=> "control_we_n",
										control_ref_n	=> "control_ref_n",
										control_a	=> "control_a",
										control_ba	=> "control_ba",
										control_dm	=> "control_dm",
                                        rldramii_qk	=> $PREFIX_NAME."qk",
									},
					
									out_port_map	=>
									{
										capture_clk 	=> "capture_clk",#[]",
										rldramii_clk    => $PREFIX_NAME."clk",
										rldramii_clk_n  => $PREFIX_NAME."clk_n",
										rldramii_cs_n_0	=> $PREFIX_NAME."cs_n_0",
										rldramii_we_n_0	=> $PREFIX_NAME."we_n_0",
										rldramii_ref_n_0 => $PREFIX_NAME."ref_n_0",
										rldramii_cs_n_1	=> $PREFIX_NAME."cs_n_1",
										rldramii_we_n_1	=> $PREFIX_NAME."we_n_1",
										rldramii_ref_n_1 => $PREFIX_NAME."ref_n_1",
										rldramii_dm	=> $PREFIX_NAME."dm",#[]",
										rldramii_a_0	=> $PREFIX_NAME."a_0",
										rldramii_ba_0	=> $PREFIX_NAME."ba_0",
										rldramii_a_1	=> $PREFIX_NAME."a_1",
										rldramii_ba_1	=> $PREFIX_NAME."ba_1",
										control_qvld	=> "control_qvld",#[]",
										control_rdata	=> "control_rdata",
									},
									
									inout_port_map	=>
									{
										#rldramii_qk	=> $PREFIX_NAME."qk",#[]",
										rldramii_dq 	=> $PREFIX_NAME."dq",					
									},
								}),
							);
						} else {
							$module->add_contents
							(
								e_comment->new({comment => "Instantiate CIO RLDRAM II Datapath"}),
								e_blind_instance->new
								({
									name 		=> "rldramii_io",            
									module 		=> $gWRAPPER_NAME."_auk_rldramii_datapath",
									comment 	=> "---------------------------------------------------------------------\n
									RLDRAM II Controller Datapath\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk 		=> "clk",
										write_clk 	=> "write_clk",
										reset_clk_n	=> "reset_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										dqs_delay_ctrl 	=> "dqs_delay_ctrl",
										rldramii_qvld	=> $PREFIX_NAME."qvld",
										control_doing_wr => "control_doing_wr",
										control_wdata_valid => "control_wdata_valid",
										control_wdata	=> "control_wdata",
										control_cs_n	=> "control_cs_n",
										control_we_n	=> "control_we_n",
										control_ref_n	=> "control_ref_n",
										control_a	=> "control_a",
										control_ba	=> "control_ba",
										control_dm	=> "control_dm",
                                        rldramii_qk	=> $PREFIX_NAME."qk",
									},
					
									out_port_map	=>
									{
										capture_clk 	=> "capture_clk",#[]",
										rldramii_cs_n_0	=> $PREFIX_NAME."cs_n_0",
										rldramii_we_n_0	=> $PREFIX_NAME."we_n_0",
										rldramii_ref_n_0 => $PREFIX_NAME."ref_n_0",
										rldramii_cs_n_1	=> $PREFIX_NAME."cs_n_1",
										rldramii_we_n_1	=> $PREFIX_NAME."we_n_1",
										rldramii_ref_n_1 => $PREFIX_NAME."ref_n_1",
										rldramii_dm	=> $PREFIX_NAME."dm",#[]",
										rldramii_a_0	=> $PREFIX_NAME."a_0",
										rldramii_ba_0	=> $PREFIX_NAME."ba_0",
										rldramii_a_1	=> $PREFIX_NAME."a_1",
										rldramii_ba_1	=> $PREFIX_NAME."ba_1",
										control_qvld	=> "control_qvld",#[]",
										control_rdata	=> "control_rdata",
									},
									
									inout_port_map	=>
									{
										#rldramii_qk	=> $PREFIX_NAME."qk",#[]",
										rldramii_dq 	=> $PREFIX_NAME."dq",					
									},
								}),
							);							
						}
					}
				} else {
					if($num_addr_cmd_buses == 1) {
						if ($ddio_memory_clocks eq "true") {
							$module->add_contents
							(
								e_comment->new({comment => "Instantiate CIO RLDRAM II Datapath"}),
								e_blind_instance->new
								({
									name 		=> "rldramii_io",            
									module 		=> $gWRAPPER_NAME."_auk_rldramii_datapath",
									comment 	=> "---------------------------------------------------------------------\n
									RLDRAM II Controller Datapath\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk 		=> "clk",
										write_clk 	=> "write_clk",
										reset_clk_n	=> "reset_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										dqs_delay_ctrl 	=> "dqs_delay_ctrl",
										rldramii_qvld	=> $PREFIX_NAME."qvld",
										control_doing_wr => "control_doing_wr",
										control_wdata_valid => "control_wdata_valid",
										control_wdata	=> "control_wdata",
										control_cs_n	=> "control_cs_n",
										control_we_n	=> "control_we_n",
										control_ref_n	=> "control_ref_n",
										control_a	=> "control_a",
										control_ba	=> "control_ba",
                                        rldramii_qk	=> $PREFIX_NAME."qk",
									},
					
									out_port_map	=>
									{
										capture_clk 	=> "capture_clk",#[]",
										rldramii_clk    => $PREFIX_NAME."clk",
										rldramii_clk_n  => $PREFIX_NAME."clk_n",
										rldramii_cs_n_0	=> $PREFIX_NAME."cs_n_0",
										rldramii_we_n_0	=> $PREFIX_NAME."we_n_0",
										rldramii_ref_n_0 => $PREFIX_NAME."ref_n_0",
										rldramii_a_0	=> $PREFIX_NAME."a_0",
										rldramii_ba_0	=> $PREFIX_NAME."ba_0",
										control_qvld	=> "control_qvld",#[]",
										control_rdata	=> "control_rdata",
									},
									
									inout_port_map	=>
									{
										#rldramii_qk	=> $PREFIX_NAME."qk",#[]",
										rldramii_dq 	=> $PREFIX_NAME."dq",					
									},
								}),
							);
						} else {
							$module->add_contents
							(
								e_comment->new({comment => "Instantiate CIO RLDRAM II Datapath"}),
								e_blind_instance->new
								({
									name 		=> "rldramii_io",            
									module 		=> $gWRAPPER_NAME."_auk_rldramii_datapath",
									comment 	=> "---------------------------------------------------------------------\n
									RLDRAM II Controller Datapath\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk 		=> "clk",
										write_clk 	=> "write_clk",
										reset_clk_n	=> "reset_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										dqs_delay_ctrl 	=> "dqs_delay_ctrl",
										rldramii_qvld	=> $PREFIX_NAME."qvld",
										control_doing_wr => "control_doing_wr",
										control_wdata_valid => "control_wdata_valid",
										control_wdata	=> "control_wdata",
										control_cs_n	=> "control_cs_n",
										control_we_n	=> "control_we_n",
										control_ref_n	=> "control_ref_n",
										control_a	=> "control_a",
										control_ba	=> "control_ba",
                                        rldramii_qk	=> $PREFIX_NAME."qk",
									},
					
									out_port_map	=>
									{
										capture_clk 	=> "capture_clk",#[]",
										rldramii_cs_n_0	=> $PREFIX_NAME."cs_n_0",
										rldramii_we_n_0	=> $PREFIX_NAME."we_n_0",
										rldramii_ref_n_0 => $PREFIX_NAME."ref_n_0",
										rldramii_a_0	=> $PREFIX_NAME."a_0",
										rldramii_ba_0	=> $PREFIX_NAME."ba_0",
										control_qvld	=> "control_qvld",#[]",
										control_rdata	=> "control_rdata",
									},
									
									inout_port_map	=>
									{
										#rldramii_qk	=> $PREFIX_NAME."qk",#[]",
										rldramii_dq 	=> $PREFIX_NAME."dq",					
									},
								}),
							);
						}
					}
					
					if($num_addr_cmd_buses > 1) {
						if ($ddio_memory_clocks eq "true") {
							$module->add_contents
							(
								e_comment->new({comment => "Instantiate CIO RLDRAM II Datapath"}),
								e_blind_instance->new
								({
									name 		=> "rldramii_io",            
									module 		=> $gWRAPPER_NAME."_auk_rldramii_datapath",
									comment 	=> "---------------------------------------------------------------------\n
									RLDRAM II Controller Datapath\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk 		=> "clk",
										write_clk 	=> "write_clk",
										reset_clk_n	=> "reset_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										dqs_delay_ctrl 	=> "dqs_delay_ctrl",
										rldramii_qvld	=> $PREFIX_NAME."qvld",
										control_doing_wr => "control_doing_wr",
										control_wdata_valid => "control_wdata_valid",
										control_wdata	=> "control_wdata",
										control_cs_n	=> "control_cs_n",
										control_we_n	=> "control_we_n",
										control_ref_n	=> "control_ref_n",
										control_a	=> "control_a",
										control_ba	=> "control_ba",
                                        rldramii_qk	=> $PREFIX_NAME."qk",
									},
					
									out_port_map	=>
									{
										capture_clk 	=> "capture_clk",#[]",
										rldramii_clk    => $PREFIX_NAME."clk",
										rldramii_clk_n  => $PREFIX_NAME."clk_n",
										rldramii_cs_n_0	=> $PREFIX_NAME."cs_n_0",
										rldramii_we_n_0	=> $PREFIX_NAME."we_n_0",
										rldramii_ref_n_0 => $PREFIX_NAME."ref_n_0",
										rldramii_cs_n_1	=> $PREFIX_NAME."cs_n_1",
										rldramii_we_n_1	=> $PREFIX_NAME."we_n_1",
										rldramii_ref_n_1 => $PREFIX_NAME."ref_n_1",
										rldramii_a_0	=> $PREFIX_NAME."a_0",
										rldramii_ba_0	=> $PREFIX_NAME."ba_0",
										rldramii_a_1	=> $PREFIX_NAME."a_1",
										rldramii_ba_1	=> $PREFIX_NAME."ba_1",
										control_qvld	=> "control_qvld",#[]",
										control_rdata	=> "control_rdata",
									},
									
									inout_port_map	=>
									{
										#rldramii_qk	=> $PREFIX_NAME."qk",#[]",
										rldramii_dq 	=> $PREFIX_NAME."dq",					
									},
								}),
							);
						} else {
							$module->add_contents
							(
								e_comment->new({comment => "Instantiate CIO RLDRAM II Datapath"}),
								e_blind_instance->new
								({
									name 		=> "rldramii_io",            
									module 		=> $gWRAPPER_NAME."_auk_rldramii_datapath",
									comment 	=> "---------------------------------------------------------------------\n
									RLDRAM II Controller Datapath\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk 		=> "clk",
										write_clk 	=> "write_clk",
										reset_clk_n	=> "reset_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										dqs_delay_ctrl 	=> "dqs_delay_ctrl",
										rldramii_qvld	=> $PREFIX_NAME."qvld",
										control_doing_wr => "control_doing_wr",
										control_wdata_valid => "control_wdata_valid",
										control_wdata	=> "control_wdata",
										control_cs_n	=> "control_cs_n",
										control_we_n	=> "control_we_n",
										control_ref_n	=> "control_ref_n",
										control_a	=> "control_a",
										control_ba	=> "control_ba",
                                        rldramii_qk	=> $PREFIX_NAME."qk",
									},
					
									out_port_map	=>
									{
										capture_clk 	=> "capture_clk",#[]",
										rldramii_cs_n_0	=> $PREFIX_NAME."cs_n_0",
										rldramii_we_n_0	=> $PREFIX_NAME."we_n_0",
										rldramii_ref_n_0 => $PREFIX_NAME."ref_n_0",
										rldramii_cs_n_1	=> $PREFIX_NAME."cs_n_1",
										rldramii_we_n_1	=> $PREFIX_NAME."we_n_1",
										rldramii_ref_n_1 => $PREFIX_NAME."ref_n_1",
										rldramii_a_0	=> $PREFIX_NAME."a_0",
										rldramii_ba_0	=> $PREFIX_NAME."ba_0",
										rldramii_a_1	=> $PREFIX_NAME."a_1",
										rldramii_ba_1	=> $PREFIX_NAME."ba_1",
										control_qvld	=> "control_qvld",#[]",
										control_rdata	=> "control_rdata",
									},
									
									inout_port_map	=>
									{
										#rldramii_qk	=> $PREFIX_NAME."qk",#[]",
										rldramii_dq 	=> $PREFIX_NAME."dq",					
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
					if($num_addr_cmd_buses == 1) {
						if ($ddio_memory_clocks eq "true") {
							$module->add_contents
							(
								e_comment->new({comment => "Instantiate CIO RLDRAM II Datapath"}),
								e_blind_instance->new
								({
									name 		=> "rldramii_io",            
									module 		=> $gWRAPPER_NAME."_auk_rldramii_datapath",
									comment 	=> "---------------------------------------------------------------------\n
									RLDRAM II Controller Datapath\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk 		=> "clk",
										write_clk 	=> "write_clk",
										addr_cmd_clk 	=> "addr_cmd_clk",
										reset_clk_n	=> "reset_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										dqs_delay_ctrl 	=> "dqs_delay_ctrl",
										rldramii_qvld	=> $PREFIX_NAME."qvld",
										control_doing_wr => "control_doing_wr",
										control_wdata_valid => "control_wdata_valid",
										control_wdata	=> "control_wdata",
										control_cs_n	=> "control_cs_n",
										control_we_n	=> "control_we_n",
										control_ref_n	=> "control_ref_n",
										control_a	=> "control_a",
										control_ba	=> "control_ba",
										control_dm	=> "control_dm",
                                        rldramii_qk	=> $PREFIX_NAME."qk",
									},
					
									out_port_map	=>
									{
										capture_clk 	=> "capture_clk",#[]",
										rldramii_clk    => $PREFIX_NAME."clk",
										rldramii_clk_n  => $PREFIX_NAME."clk_n",
										rldramii_cs_n_0	=> $PREFIX_NAME."cs_n_0",
										rldramii_we_n_0	=> $PREFIX_NAME."we_n_0",
										rldramii_ref_n_0 => $PREFIX_NAME."ref_n_0",
										rldramii_dm	=> $PREFIX_NAME."dm",#[]",
										rldramii_a_0	=> $PREFIX_NAME."a_0",
										rldramii_ba_0	=> $PREFIX_NAME."ba_0",
										control_qvld	=> "control_qvld",#[]",
										control_rdata	=> "control_rdata",
									},
									
									inout_port_map	=>
									{
										#rldramii_qk	=> $PREFIX_NAME."qk",#[]",
										rldramii_dq 	=> $PREFIX_NAME."dq",					
									},
								}),
							);
						} else {
							$module->add_contents
							(
								e_comment->new({comment => "Instantiate CIO RLDRAM II Datapath"}),
								e_blind_instance->new
								({
									name 		=> "rldramii_io",            
									module 		=> $gWRAPPER_NAME."_auk_rldramii_datapath",
									comment 	=> "---------------------------------------------------------------------\n
									RLDRAM II Controller Datapath\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk 		=> "clk",
										write_clk 	=> "write_clk",
										addr_cmd_clk 	=> "addr_cmd_clk",
										reset_clk_n	=> "reset_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										dqs_delay_ctrl 	=> "dqs_delay_ctrl",
										rldramii_qvld	=> $PREFIX_NAME."qvld",
										control_doing_wr => "control_doing_wr",
										control_wdata_valid => "control_wdata_valid",
										control_wdata	=> "control_wdata",
										control_cs_n	=> "control_cs_n",
										control_we_n	=> "control_we_n",
										control_ref_n	=> "control_ref_n",
										control_a	=> "control_a",
										control_ba	=> "control_ba",
										control_dm	=> "control_dm",
                                        rldramii_qk	=> $PREFIX_NAME."qk",
									},
					
									out_port_map	=>
									{
										capture_clk 	=> "capture_clk",#[]",
										rldramii_cs_n_0	=> $PREFIX_NAME."cs_n_0",
										rldramii_we_n_0	=> $PREFIX_NAME."we_n_0",
										rldramii_ref_n_0 => $PREFIX_NAME."ref_n_0",
										rldramii_dm	=> $PREFIX_NAME."dm",#[]",
										rldramii_a_0	=> $PREFIX_NAME."a_0",
										rldramii_ba_0	=> $PREFIX_NAME."ba_0",
										control_qvld	=> "control_qvld",#[]",
										control_rdata	=> "control_rdata",
									},
									
									inout_port_map	=>
									{
										#rldramii_qk	=> $PREFIX_NAME."qk",#[]",
										rldramii_dq 	=> $PREFIX_NAME."dq",					
									},
								}),
							);
						}
					}
					
					if($num_addr_cmd_buses > 1) {
						if ($ddio_memory_clocks eq "true") {
							$module->add_contents
							(
								e_comment->new({comment => "Instantiate CIO RLDRAM II Datapath"}),
								e_blind_instance->new
								({
									name 		=> "rldramii_io",            
									module 		=> $gWRAPPER_NAME."_auk_rldramii_datapath",
									comment 	=> "---------------------------------------------------------------------\n
									RLDRAM II Controller Datapath\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk 		=> "clk",
										write_clk 	=> "write_clk",
										addr_cmd_clk 	=> "addr_cmd_clk",
										reset_clk_n	=> "reset_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										dqs_delay_ctrl 	=> "dqs_delay_ctrl",
										rldramii_qvld	=> $PREFIX_NAME."qvld",
										control_doing_wr => "control_doing_wr",
										control_wdata_valid => "control_wdata_valid",
										control_wdata	=> "control_wdata",
										control_cs_n	=> "control_cs_n",
										control_we_n	=> "control_we_n",
										control_ref_n	=> "control_ref_n",
										control_a	=> "control_a",
										control_ba	=> "control_ba",
										control_dm	=> "control_dm",
                                        rldramii_qk	=> $PREFIX_NAME."qk",
									},
					
									out_port_map	=>
									{
										capture_clk 	=> "capture_clk",#[]",
										rldramii_clk    => $PREFIX_NAME."clk",
										rldramii_clk_n  => $PREFIX_NAME."clk_n",
										rldramii_cs_n_0	=> $PREFIX_NAME."cs_n_0",
										rldramii_we_n_0	=> $PREFIX_NAME."we_n_0",
										rldramii_ref_n_0 => $PREFIX_NAME."ref_n_0",
										rldramii_cs_n_1	=> $PREFIX_NAME."cs_n_1",
										rldramii_we_n_1	=> $PREFIX_NAME."we_n_1",
										rldramii_ref_n_1 => $PREFIX_NAME."ref_n_1",
										rldramii_dm	=> $PREFIX_NAME."dm",#[]",
										rldramii_a_0	=> $PREFIX_NAME."a_0",
										rldramii_ba_0	=> $PREFIX_NAME."ba_0",
										rldramii_a_1	=> $PREFIX_NAME."a_1",
										rldramii_ba_1	=> $PREFIX_NAME."ba_1",
										control_qvld	=> "control_qvld",#[]",
										control_rdata	=> "control_rdata",
									},
									
									inout_port_map	=>
									{
										#rldramii_qk	=> $PREFIX_NAME."qk",#[]",
										rldramii_dq 	=> $PREFIX_NAME."dq",					
									},
								}),
							);
						} else {
							$module->add_contents
							(
								e_comment->new({comment => "Instantiate CIO RLDRAM II Datapath"}),
								e_blind_instance->new
								({
									name 		=> "rldramii_io",            
									module 		=> $gWRAPPER_NAME."_auk_rldramii_datapath",
									comment 	=> "---------------------------------------------------------------------\n
									RLDRAM II Controller Datapath\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk 		=> "clk",
										write_clk 	=> "write_clk",
										addr_cmd_clk 	=> "addr_cmd_clk",
										reset_clk_n	=> "reset_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										dqs_delay_ctrl 	=> "dqs_delay_ctrl",
										rldramii_qvld	=> $PREFIX_NAME."qvld",
										control_doing_wr => "control_doing_wr",
										control_wdata_valid => "control_wdata_valid",
										control_wdata	=> "control_wdata",
										control_cs_n	=> "control_cs_n",
										control_we_n	=> "control_we_n",
										control_ref_n	=> "control_ref_n",
										control_a	=> "control_a",
										control_ba	=> "control_ba",
										control_dm	=> "control_dm",
                                        rldramii_qk	=> $PREFIX_NAME."qk",
									},
					
									out_port_map	=>
									{
										capture_clk 	=> "capture_clk",#[]",
										rldramii_cs_n_0	=> $PREFIX_NAME."cs_n_0",
										rldramii_we_n_0	=> $PREFIX_NAME."we_n_0",
										rldramii_ref_n_0 => $PREFIX_NAME."ref_n_0",
										rldramii_cs_n_1	=> $PREFIX_NAME."cs_n_1",
										rldramii_we_n_1	=> $PREFIX_NAME."we_n_1",
										rldramii_ref_n_1 => $PREFIX_NAME."ref_n_1",
										rldramii_dm	=> $PREFIX_NAME."dm",#[]",
										rldramii_a_0	=> $PREFIX_NAME."a_0",
										rldramii_ba_0	=> $PREFIX_NAME."ba_0",
										rldramii_a_1	=> $PREFIX_NAME."a_1",
										rldramii_ba_1	=> $PREFIX_NAME."ba_1",
										control_qvld	=> "control_qvld",#[]",
										control_rdata	=> "control_rdata",
									},
									
									inout_port_map	=>
									{
										#rldramii_qk	=> $PREFIX_NAME."qk",#[]",
										rldramii_dq 	=> $PREFIX_NAME."dq",					
									},
								}),
							);
						}
					}
				} else {
					if($num_addr_cmd_buses == 1) {
						if ($ddio_memory_clocks eq "true") {
							$module->add_contents
							(
								e_comment->new({comment => "Instantiate CIO RLDRAM II Datapath"}),
								e_blind_instance->new
								({
									name 		=> "rldramii_io",            
									module 		=> $gWRAPPER_NAME."_auk_rldramii_datapath",
									comment 	=> "---------------------------------------------------------------------\n
									RLDRAM II Controller Datapath\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk 		=> "clk",
										write_clk 	=> "write_clk",
										addr_cmd_clk 	=> "addr_cmd_clk",
										reset_clk_n	=> "reset_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										dqs_delay_ctrl 	=> "dqs_delay_ctrl",
										rldramii_qvld	=> $PREFIX_NAME."qvld",
										control_doing_wr => "control_doing_wr",
										control_wdata_valid => "control_wdata_valid",
										control_wdata	=> "control_wdata",
										control_cs_n	=> "control_cs_n",
										control_we_n	=> "control_we_n",
										control_ref_n	=> "control_ref_n",
										control_a	=> "control_a",
										control_ba	=> "control_ba",
                                        rldramii_qk	=> $PREFIX_NAME."qk",
									},
					
									out_port_map	=>
									{
										capture_clk 	=> "capture_clk",#[]",
										rldramii_clk    => $PREFIX_NAME."clk",
										rldramii_clk_n  => $PREFIX_NAME."clk_n",
										rldramii_cs_n_0	=> $PREFIX_NAME."cs_n_0",
										rldramii_we_n_0	=> $PREFIX_NAME."we_n_0",
										rldramii_ref_n_0 => $PREFIX_NAME."ref_n_0",
										rldramii_a_0	=> $PREFIX_NAME."a_0",
										rldramii_ba_0	=> $PREFIX_NAME."ba_0",
										control_qvld	=> "control_qvld",#[]",
										control_rdata	=> "control_rdata",
									},
									
									inout_port_map	=>
									{
										#rldramii_qk	=> $PREFIX_NAME."qk",#[]",
										rldramii_dq 	=> $PREFIX_NAME."dq",					
									},
								}),
							);
						} else {
							$module->add_contents
							(
								e_comment->new({comment => "Instantiate CIO RLDRAM II Datapath"}),
								e_blind_instance->new
								({
									name 		=> "rldramii_io",            
									module 		=> $gWRAPPER_NAME."_auk_rldramii_datapath",
									comment 	=> "---------------------------------------------------------------------\n
									RLDRAM II Controller Datapath\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk 		=> "clk",
										write_clk 	=> "write_clk",
										addr_cmd_clk 	=> "addr_cmd_clk",
										reset_clk_n	=> "reset_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										dqs_delay_ctrl 	=> "dqs_delay_ctrl",
										rldramii_qvld	=> $PREFIX_NAME."qvld",
										control_doing_wr => "control_doing_wr",
										control_wdata_valid => "control_wdata_valid",
										control_wdata	=> "control_wdata",
										control_cs_n	=> "control_cs_n",
										control_we_n	=> "control_we_n",
										control_ref_n	=> "control_ref_n",
										control_a	=> "control_a",
										control_ba	=> "control_ba",
                                        rldramii_qk	=> $PREFIX_NAME."qk",
									},
					
									out_port_map	=>
									{
										capture_clk 	=> "capture_clk",#[]",
										rldramii_cs_n_0	=> $PREFIX_NAME."cs_n_0",
										rldramii_we_n_0	=> $PREFIX_NAME."we_n_0",
										rldramii_ref_n_0 => $PREFIX_NAME."ref_n_0",
										rldramii_a_0	=> $PREFIX_NAME."a_0",
										rldramii_ba_0	=> $PREFIX_NAME."ba_0",
										control_qvld	=> "control_qvld",#[]",
										control_rdata	=> "control_rdata",
									},
									
									inout_port_map	=>
									{
										#rldramii_qk	=> $PREFIX_NAME."qk",#[]",
										rldramii_dq 	=> $PREFIX_NAME."dq",					
									},
								}),
							);
						}
					}
					
					if($num_addr_cmd_buses > 1) {
						if ($ddio_memory_clocks eq "true") {
							$module->add_contents
							(
								e_comment->new({comment => "Instantiate CIO RLDRAM II Datapath"}),
								e_blind_instance->new
								({
									name 		=> "rldramii_io",            
									module 		=> $gWRAPPER_NAME."_auk_rldramii_datapath",
									comment 	=> "---------------------------------------------------------------------\n
									RLDRAM II Controller Datapath\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk 		=> "clk",
										write_clk 	=> "write_clk",
										addr_cmd_clk 	=> "addr_cmd_clk",
										reset_clk_n	=> "reset_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										dqs_delay_ctrl 	=> "dqs_delay_ctrl",
										rldramii_qvld	=> $PREFIX_NAME."qvld",
										control_doing_wr => "control_doing_wr",
										control_wdata_valid => "control_wdata_valid",
										control_wdata	=> "control_wdata",
										control_cs_n	=> "control_cs_n",
										control_we_n	=> "control_we_n",
										control_ref_n	=> "control_ref_n",
										control_a	=> "control_a",
										control_ba	=> "control_ba",
                                        rldramii_qk	=> $PREFIX_NAME."qk",
									},
					
									out_port_map	=>
									{
										capture_clk 	=> "capture_clk",#[]",
										rldramii_clk    => $PREFIX_NAME."clk",
										rldramii_clk_n  => $PREFIX_NAME."clk_n",
										rldramii_cs_n_0	=> $PREFIX_NAME."cs_n_0",
										rldramii_we_n_0	=> $PREFIX_NAME."we_n_0",
										rldramii_ref_n_0 => $PREFIX_NAME."ref_n_0",
										rldramii_cs_n_1	=> $PREFIX_NAME."cs_n_1",
										rldramii_we_n_1	=> $PREFIX_NAME."we_n_1",
										rldramii_ref_n_1 => $PREFIX_NAME."ref_n_1",
										rldramii_a_0	=> $PREFIX_NAME."a_0",
										rldramii_ba_0	=> $PREFIX_NAME."ba_0",
										rldramii_a_1	=> $PREFIX_NAME."a_1",
										rldramii_ba_1	=> $PREFIX_NAME."ba_1",
										control_qvld	=> "control_qvld",#[]",
										control_rdata	=> "control_rdata",
									},
									
									inout_port_map	=>
									{
										#rldramii_qk	=> $PREFIX_NAME."qk",#[]",
										rldramii_dq 	=> $PREFIX_NAME."dq",					
									},
								}),
							);
						} else {
							$module->add_contents
							(
								e_comment->new({comment => "Instantiate CIO RLDRAM II Datapath"}),
								e_blind_instance->new
								({
									name 		=> "rldramii_io",            
									module 		=> $gWRAPPER_NAME."_auk_rldramii_datapath",
									comment 	=> "---------------------------------------------------------------------\n
									RLDRAM II Controller Datapath\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk 		=> "clk",
										write_clk 	=> "write_clk",
										addr_cmd_clk 	=> "addr_cmd_clk",
										reset_clk_n	=> "reset_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										dqs_delay_ctrl 	=> "dqs_delay_ctrl",
										rldramii_qvld	=> $PREFIX_NAME."qvld",
										control_doing_wr => "control_doing_wr",
										control_wdata_valid => "control_wdata_valid",
										control_wdata	=> "control_wdata",
										control_cs_n	=> "control_cs_n",
										control_we_n	=> "control_we_n",
										control_ref_n	=> "control_ref_n",
										control_a	=> "control_a",
										control_ba	=> "control_ba",
                                        rldramii_qk	=> $PREFIX_NAME."qk",
									},
					
									out_port_map	=>
									{
										capture_clk 	=> "capture_clk",#[]",
										rldramii_cs_n_0	=> $PREFIX_NAME."cs_n_0",
										rldramii_we_n_0	=> $PREFIX_NAME."we_n_0",
										rldramii_ref_n_0 => $PREFIX_NAME."ref_n_0",
										rldramii_cs_n_1	=> $PREFIX_NAME."cs_n_1",
										rldramii_we_n_1	=> $PREFIX_NAME."we_n_1",
										rldramii_ref_n_1 => $PREFIX_NAME."ref_n_1",
										rldramii_a_0	=> $PREFIX_NAME."a_0",
										rldramii_ba_0	=> $PREFIX_NAME."ba_0",
										rldramii_a_1	=> $PREFIX_NAME."a_1",
										rldramii_ba_1	=> $PREFIX_NAME."ba_1",
										control_qvld	=> "control_qvld",#[]",
										control_rdata	=> "control_rdata",
									},
									
									inout_port_map	=>
									{
										#rldramii_qk	=> $PREFIX_NAME."qk",#[]",
										rldramii_dq 	=> $PREFIX_NAME."dq",					
									},
								}),
							);
						}
					}
				}
			}
		}
		else
		{
			if($enable_addr_cmd_clk eq "false") {
				if($enable_dm_pins eq "true") {
					if($num_addr_cmd_buses == 1) {
						if ($ddio_memory_clocks eq "true") {
							$module->add_contents
							(
								e_comment->new({comment => "Instantiate CIO RLDRAM II Datapath"}),
								e_blind_instance->new
								({
									name 		=> "rldramii_io",            
									module 		=> $gWRAPPER_NAME."_auk_rldramii_datapath",
									comment 	=> "---------------------------------------------------------------------\n
									RLDRAM II Controller Datapath\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk 		=> "clk",
										write_clk 	=> "write_clk",
										reset_clk_n	=> "reset_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										non_dqs_capture_clk => "non_dqs_capture_clk",
										rldramii_qvld	=> $PREFIX_NAME."qvld",
										control_doing_wr => "control_doing_wr",
										control_wdata_valid => "control_wdata_valid",
										control_wdata	=> "control_wdata",
										control_cs_n	=> "control_cs_n",
										control_we_n	=> "control_we_n",
										control_ref_n	=> "control_ref_n",
										control_a	=> "control_a",
										control_ba	=> "control_ba",
										control_dm	=> "control_dm",
									},
					
									out_port_map	=>
									{
										rldramii_clk    => $PREFIX_NAME."clk",
										rldramii_clk_n  => $PREFIX_NAME."clk_n",
										rldramii_cs_n_0	=> $PREFIX_NAME."cs_n_0",
										rldramii_we_n_0	=> $PREFIX_NAME."we_n_0",
										rldramii_ref_n_0 => $PREFIX_NAME."ref_n_0",
										rldramii_dm	=> $PREFIX_NAME."dm",#[]",
										rldramii_a_0	=> $PREFIX_NAME."a_0",
										rldramii_ba_0	=> $PREFIX_NAME."ba_0",
										control_qvld	=> "control_qvld",#[]",
										control_rdata	=> "control_rdata",
									},
									
									inout_port_map	=>
									{
										rldramii_dq 	=> $PREFIX_NAME."dq",					
									},
								}),
							);
						} else {
							$module->add_contents
							(
								e_comment->new({comment => "Instantiate CIO RLDRAM II Datapath"}),
								e_blind_instance->new
								({
									name 		=> "rldramii_io",            
									module 		=> $gWRAPPER_NAME."_auk_rldramii_datapath",
									comment 	=> "---------------------------------------------------------------------\n
									RLDRAM II Controller Datapath\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk 		=> "clk",
										write_clk 	=> "write_clk",
										reset_clk_n	=> "reset_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										non_dqs_capture_clk => "non_dqs_capture_clk",
										rldramii_qvld	=> $PREFIX_NAME."qvld",
										control_doing_wr => "control_doing_wr",
										control_wdata_valid => "control_wdata_valid",
										control_wdata	=> "control_wdata",
										control_cs_n	=> "control_cs_n",
										control_we_n	=> "control_we_n",
										control_ref_n	=> "control_ref_n",
										control_a	=> "control_a",
										control_ba	=> "control_ba",
										control_dm	=> "control_dm",
									},
					
									out_port_map	=>
									{
										rldramii_cs_n_0	=> $PREFIX_NAME."cs_n_0",
										rldramii_we_n_0	=> $PREFIX_NAME."we_n_0",
										rldramii_ref_n_0 => $PREFIX_NAME."ref_n_0",
										rldramii_dm	=> $PREFIX_NAME."dm",#[]",
										rldramii_a_0	=> $PREFIX_NAME."a_0",
										rldramii_ba_0	=> $PREFIX_NAME."ba_0",
										control_qvld	=> "control_qvld",#[]",
										control_rdata	=> "control_rdata",
									},
									
									inout_port_map	=>
									{
										rldramii_dq 	=> $PREFIX_NAME."dq",					
									},
								}),
							);
						}
					}
					
					if($num_addr_cmd_buses > 1) {
						if ($ddio_memory_clocks eq "true") {
							$module->add_contents
							(
								e_comment->new({comment => "Instantiate CIO RLDRAM II Datapath"}),
								e_blind_instance->new
								({
									name 		=> "rldramii_io",            
									module 		=> $gWRAPPER_NAME."_auk_rldramii_datapath",
									comment 	=> "---------------------------------------------------------------------\n
									RLDRAM II Controller Datapath\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk 		=> "clk",
										write_clk 	=> "write_clk",
										reset_clk_n	=> "reset_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										non_dqs_capture_clk => "non_dqs_capture_clk",
										rldramii_qvld	=> $PREFIX_NAME."qvld",
										control_doing_wr => "control_doing_wr",
										control_wdata_valid => "control_wdata_valid",
										control_wdata	=> "control_wdata",
										control_cs_n	=> "control_cs_n",
										control_we_n	=> "control_we_n",
										control_ref_n	=> "control_ref_n",
										control_a	=> "control_a",
										control_ba	=> "control_ba",
										control_dm	=> "control_dm",
									},
					
									out_port_map	=>
									{
										rldramii_clk    => $PREFIX_NAME."clk",
										rldramii_clk_n  => $PREFIX_NAME."clk_n",
										rldramii_cs_n_0	=> $PREFIX_NAME."cs_n_0",
										rldramii_we_n_0	=> $PREFIX_NAME."we_n_0",
										rldramii_ref_n_0 => $PREFIX_NAME."ref_n_0",
										rldramii_cs_n_1	=> $PREFIX_NAME."cs_n_1",
										rldramii_we_n_1	=> $PREFIX_NAME."we_n_1",
										rldramii_ref_n_1 => $PREFIX_NAME."ref_n_1",
										rldramii_dm	=> $PREFIX_NAME."dm",#[]",
										rldramii_a_0	=> $PREFIX_NAME."a_0",
										rldramii_ba_0	=> $PREFIX_NAME."ba_0",
										rldramii_a_1	=> $PREFIX_NAME."a_1",
										rldramii_ba_1	=> $PREFIX_NAME."ba_1",
										control_qvld	=> "control_qvld",#[]",
										control_rdata	=> "control_rdata",
									},
									
									inout_port_map	=>
									{
										rldramii_dq 	=> $PREFIX_NAME."dq",					
									},
								}),
							);
						} else {
							$module->add_contents
							(
								e_comment->new({comment => "Instantiate CIO RLDRAM II Datapath"}),
								e_blind_instance->new
								({
									name 		=> "rldramii_io",            
									module 		=> $gWRAPPER_NAME."_auk_rldramii_datapath",
									comment 	=> "---------------------------------------------------------------------\n
									RLDRAM II Controller Datapath\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk 		=> "clk",
										write_clk 	=> "write_clk",
										reset_clk_n	=> "reset_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										non_dqs_capture_clk => "non_dqs_capture_clk",
										rldramii_qvld	=> $PREFIX_NAME."qvld",
										control_doing_wr => "control_doing_wr",
										control_wdata_valid => "control_wdata_valid",
										control_wdata	=> "control_wdata",
										control_cs_n	=> "control_cs_n",
										control_we_n	=> "control_we_n",
										control_ref_n	=> "control_ref_n",
										control_a	=> "control_a",
										control_ba	=> "control_ba",
										control_dm	=> "control_dm",
									},
					
									out_port_map	=>
									{
										rldramii_cs_n_0	=> $PREFIX_NAME."cs_n_0",
										rldramii_we_n_0	=> $PREFIX_NAME."we_n_0",
										rldramii_ref_n_0 => $PREFIX_NAME."ref_n_0",
										rldramii_cs_n_1	=> $PREFIX_NAME."cs_n_1",
										rldramii_we_n_1	=> $PREFIX_NAME."we_n_1",
										rldramii_ref_n_1 => $PREFIX_NAME."ref_n_1",
										rldramii_dm	=> $PREFIX_NAME."dm",#[]",
										rldramii_a_0	=> $PREFIX_NAME."a_0",
										rldramii_ba_0	=> $PREFIX_NAME."ba_0",
										rldramii_a_1	=> $PREFIX_NAME."a_1",
										rldramii_ba_1	=> $PREFIX_NAME."ba_1",
										control_qvld	=> "control_qvld",#[]",
										control_rdata	=> "control_rdata",
									},
									
									inout_port_map	=>
									{
										rldramii_dq 	=> $PREFIX_NAME."dq",					
									},
								}),
							);
						}
					}
				} else {
					if($num_addr_cmd_buses == 1) {
						if ($ddio_memory_clocks eq "true") {
							$module->add_contents
							(
								e_comment->new({comment => "Instantiate CIO RLDRAM II Datapath"}),
								e_blind_instance->new
								({
									name 		=> "rldramii_io",            
									module 		=> $gWRAPPER_NAME."_auk_rldramii_datapath",
									comment 	=> "---------------------------------------------------------------------\n
									RLDRAM II Controller Datapath\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk 		=> "clk",
										write_clk 	=> "write_clk",
										reset_clk_n	=> "reset_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										non_dqs_capture_clk => "non_dqs_capture_clk",
										rldramii_qvld	=> $PREFIX_NAME."qvld",
										control_doing_wr => "control_doing_wr",
										control_wdata_valid => "control_wdata_valid",
										control_wdata	=> "control_wdata",
										control_cs_n	=> "control_cs_n",
										control_we_n	=> "control_we_n",
										control_ref_n	=> "control_ref_n",
										control_a	=> "control_a",
										control_ba	=> "control_ba",
									},
					
									out_port_map	=>
									{
										rldramii_clk    => $PREFIX_NAME."clk",
										rldramii_clk_n  => $PREFIX_NAME."clk_n",
										rldramii_cs_n_0	=> $PREFIX_NAME."cs_n_0",
										rldramii_we_n_0	=> $PREFIX_NAME."we_n_0",
										rldramii_ref_n_0 => $PREFIX_NAME."ref_n_0",
										rldramii_a_0	=> $PREFIX_NAME."a_0",
										rldramii_ba_0	=> $PREFIX_NAME."ba_0",
										control_qvld	=> "control_qvld",#[]",
										control_rdata	=> "control_rdata",
									},
									
									inout_port_map	=>
									{
										rldramii_dq 	=> $PREFIX_NAME."dq",					
									},
								}),
							);
						} else {
							$module->add_contents
							(
								e_comment->new({comment => "Instantiate CIO RLDRAM II Datapath"}),
								e_blind_instance->new
								({
									name 		=> "rldramii_io",            
									module 		=> $gWRAPPER_NAME."_auk_rldramii_datapath",
									comment 	=> "---------------------------------------------------------------------\n
									RLDRAM II Controller Datapath\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk 		=> "clk",
										write_clk 	=> "write_clk",
										reset_clk_n	=> "reset_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										non_dqs_capture_clk => "non_dqs_capture_clk",
										rldramii_qvld	=> $PREFIX_NAME."qvld",
										control_doing_wr => "control_doing_wr",
										control_wdata_valid => "control_wdata_valid",
										control_wdata	=> "control_wdata",
										control_cs_n	=> "control_cs_n",
										control_we_n	=> "control_we_n",
										control_ref_n	=> "control_ref_n",
										control_a	=> "control_a",
										control_ba	=> "control_ba",
									},
					
									out_port_map	=>
									{
										rldramii_cs_n_0	=> $PREFIX_NAME."cs_n_0",
										rldramii_we_n_0	=> $PREFIX_NAME."we_n_0",
										rldramii_ref_n_0 => $PREFIX_NAME."ref_n_0",
										rldramii_a_0	=> $PREFIX_NAME."a_0",
										rldramii_ba_0	=> $PREFIX_NAME."ba_0",
										control_qvld	=> "control_qvld",#[]",
										control_rdata	=> "control_rdata",
									},
									
									inout_port_map	=>
									{
										rldramii_dq 	=> $PREFIX_NAME."dq",					
									},
								}),
							);
						}
					}
					
					if($num_addr_cmd_buses > 1) {
						if ($ddio_memory_clocks eq "true") {
							$module->add_contents
							(
								e_comment->new({comment => "Instantiate CIO RLDRAM II Datapath"}),
								e_blind_instance->new
								({
									name 		=> "rldramii_io",            
									module 		=> $gWRAPPER_NAME."_auk_rldramii_datapath",
									comment 	=> "---------------------------------------------------------------------\n
									RLDRAM II Controller Datapath\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk 		=> "clk",
										write_clk 	=> "write_clk",
										reset_clk_n	=> "reset_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										non_dqs_capture_clk => "non_dqs_capture_clk",
										rldramii_qvld	=> $PREFIX_NAME."qvld",
										control_doing_wr => "control_doing_wr",
										control_wdata_valid => "control_wdata_valid",
										control_wdata	=> "control_wdata",
										control_cs_n	=> "control_cs_n",
										control_we_n	=> "control_we_n",
										control_ref_n	=> "control_ref_n",
										control_a	=> "control_a",
										control_ba	=> "control_ba",
									},
					
									out_port_map	=>
									{
										rldramii_clk    => $PREFIX_NAME."clk",
										rldramii_clk_n  => $PREFIX_NAME."clk_n",
										rldramii_cs_n_0	=> $PREFIX_NAME."cs_n_0",
										rldramii_we_n_0	=> $PREFIX_NAME."we_n_0",
										rldramii_ref_n_0 => $PREFIX_NAME."ref_n_0",
										rldramii_cs_n_1	=> $PREFIX_NAME."cs_n_1",
										rldramii_we_n_1	=> $PREFIX_NAME."we_n_1",
										rldramii_ref_n_1 => $PREFIX_NAME."ref_n_1",
										rldramii_a_0	=> $PREFIX_NAME."a_0",
										rldramii_ba_0	=> $PREFIX_NAME."ba_0",
										rldramii_a_1	=> $PREFIX_NAME."a_1",
										rldramii_ba_1	=> $PREFIX_NAME."ba_1",
										control_qvld	=> "control_qvld",#[]",
										control_rdata	=> "control_rdata",
									},
									
									inout_port_map	=>
									{
										rldramii_dq 	=> $PREFIX_NAME."dq",					
									},
								}),
							);
						} else {
							$module->add_contents
							(
								e_comment->new({comment => "Instantiate CIO RLDRAM II Datapath"}),
								e_blind_instance->new
								({
									name 		=> "rldramii_io",            
									module 		=> $gWRAPPER_NAME."_auk_rldramii_datapath",
									comment 	=> "---------------------------------------------------------------------\n
									RLDRAM II Controller Datapath\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk 		=> "clk",
										write_clk 	=> "write_clk",
										reset_clk_n	=> "reset_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										non_dqs_capture_clk => "non_dqs_capture_clk",
										rldramii_qvld	=> $PREFIX_NAME."qvld",
										control_doing_wr => "control_doing_wr",
										control_wdata_valid => "control_wdata_valid",
										control_wdata	=> "control_wdata",
										control_cs_n	=> "control_cs_n",
										control_we_n	=> "control_we_n",
										control_ref_n	=> "control_ref_n",
										control_a	=> "control_a",
										control_ba	=> "control_ba",
									},
					
									out_port_map	=>
									{
										rldramii_cs_n_0	=> $PREFIX_NAME."cs_n_0",
										rldramii_we_n_0	=> $PREFIX_NAME."we_n_0",
										rldramii_ref_n_0 => $PREFIX_NAME."ref_n_0",
										rldramii_cs_n_1	=> $PREFIX_NAME."cs_n_1",
										rldramii_we_n_1	=> $PREFIX_NAME."we_n_1",
										rldramii_ref_n_1 => $PREFIX_NAME."ref_n_1",
										rldramii_a_0	=> $PREFIX_NAME."a_0",
										rldramii_ba_0	=> $PREFIX_NAME."ba_0",
										rldramii_a_1	=> $PREFIX_NAME."a_1",
										rldramii_ba_1	=> $PREFIX_NAME."ba_1",
										control_qvld	=> "control_qvld",#[]",
										control_rdata	=> "control_rdata",
									},
									
									inout_port_map	=>
									{
										rldramii_dq 	=> $PREFIX_NAME."dq",					
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
					if($num_addr_cmd_buses == 1) {
						if ($ddio_memory_clocks eq "true") {
							$module->add_contents
							(
								e_comment->new({comment => "Instantiate CIO RLDRAM II Datapath"}),
								e_blind_instance->new
								({
									name 		=> "rldramii_io",            
									module 		=> $gWRAPPER_NAME."_auk_rldramii_datapath",
									comment 	=> "---------------------------------------------------------------------\n
									RLDRAM II Controller Datapath\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk 		=> "clk",
										write_clk 	=> "write_clk",
										addr_cmd_clk 	=> "addr_cmd_clk",
										reset_clk_n	=> "reset_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										non_dqs_capture_clk => "non_dqs_capture_clk",
										rldramii_qvld	=> $PREFIX_NAME."qvld",
										control_doing_wr => "control_doing_wr",
										control_wdata_valid => "control_wdata_valid",
										control_wdata	=> "control_wdata",
										control_cs_n	=> "control_cs_n",
										control_we_n	=> "control_we_n",
										control_ref_n	=> "control_ref_n",
										control_a	=> "control_a",
										control_ba	=> "control_ba",
										control_dm	=> "control_dm",
									},
					
									out_port_map	=>
									{
										rldramii_clk    => $PREFIX_NAME."clk",
										rldramii_clk_n  => $PREFIX_NAME."clk_n",
										rldramii_cs_n_0	=> $PREFIX_NAME."cs_n_0",
										rldramii_we_n_0	=> $PREFIX_NAME."we_n_0",
										rldramii_ref_n_0 => $PREFIX_NAME."ref_n_0",
										rldramii_dm	=> $PREFIX_NAME."dm",#[]",
										rldramii_a_0	=> $PREFIX_NAME."a_0",
										rldramii_ba_0	=> $PREFIX_NAME."ba_0",
										control_qvld	=> "control_qvld",#[]",
										control_rdata	=> "control_rdata",
									},
									
									inout_port_map	=>
									{
										rldramii_dq 	=> $PREFIX_NAME."dq",					
									},
								}),
							);
						} else {
							$module->add_contents
							(
								e_comment->new({comment => "Instantiate CIO RLDRAM II Datapath"}),
								e_blind_instance->new
								({
									name 		=> "rldramii_io",            
									module 		=> $gWRAPPER_NAME."_auk_rldramii_datapath",
									comment 	=> "---------------------------------------------------------------------\n
									RLDRAM II Controller Datapath\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk 		=> "clk",
										write_clk 	=> "write_clk",
										addr_cmd_clk 	=> "addr_cmd_clk",
										reset_clk_n	=> "reset_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										non_dqs_capture_clk => "non_dqs_capture_clk",
										rldramii_qvld	=> $PREFIX_NAME."qvld",
										control_doing_wr => "control_doing_wr",
										control_wdata_valid => "control_wdata_valid",
										control_wdata	=> "control_wdata",
										control_cs_n	=> "control_cs_n",
										control_we_n	=> "control_we_n",
										control_ref_n	=> "control_ref_n",
										control_a	=> "control_a",
										control_ba	=> "control_ba",
										control_dm	=> "control_dm",
									},
					
									out_port_map	=>
									{
										rldramii_cs_n_0	=> $PREFIX_NAME."cs_n_0",
										rldramii_we_n_0	=> $PREFIX_NAME."we_n_0",
										rldramii_ref_n_0 => $PREFIX_NAME."ref_n_0",
										rldramii_dm	=> $PREFIX_NAME."dm",#[]",
										rldramii_a_0	=> $PREFIX_NAME."a_0",
										rldramii_ba_0	=> $PREFIX_NAME."ba_0",
										control_qvld	=> "control_qvld",#[]",
										control_rdata	=> "control_rdata",
									},
									
									inout_port_map	=>
									{
										rldramii_dq 	=> $PREFIX_NAME."dq",					
									},
								}),
							);
						}
					}
					
					if($num_addr_cmd_buses > 1) {
						if ($ddio_memory_clocks eq "true") {
							$module->add_contents
							(
								e_comment->new({comment => "Instantiate CIO RLDRAM II Datapath"}),
								e_blind_instance->new
								({
									name 		=> "rldramii_io",            
									module 		=> $gWRAPPER_NAME."_auk_rldramii_datapath",
									comment 	=> "---------------------------------------------------------------------\n
									RLDRAM II Controller Datapath\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk 		=> "clk",
										write_clk 	=> "write_clk",
										addr_cmd_clk 	=> "addr_cmd_clk",
										reset_clk_n	=> "reset_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										non_dqs_capture_clk => "non_dqs_capture_clk",
										rldramii_qvld	=> $PREFIX_NAME."qvld",
										control_doing_wr => "control_doing_wr",
										control_wdata_valid => "control_wdata_valid",
										control_wdata	=> "control_wdata",
										control_cs_n	=> "control_cs_n",
										control_we_n	=> "control_we_n",
										control_ref_n	=> "control_ref_n",
										control_a	=> "control_a",
										control_ba	=> "control_ba",
										control_dm	=> "control_dm",
									},
					
									out_port_map	=>
									{
										rldramii_clk    => $PREFIX_NAME."clk",
										rldramii_clk_n  => $PREFIX_NAME."clk_n",
										rldramii_cs_n_0	=> $PREFIX_NAME."cs_n_0",
										rldramii_we_n_0	=> $PREFIX_NAME."we_n_0",
										rldramii_ref_n_0 => $PREFIX_NAME."ref_n_0",
										rldramii_cs_n_1	=> $PREFIX_NAME."cs_n_1",
										rldramii_we_n_1	=> $PREFIX_NAME."we_n_1",
										rldramii_ref_n_1 => $PREFIX_NAME."ref_n_1",
										rldramii_dm	=> $PREFIX_NAME."dm",#[]",
										rldramii_a_0	=> $PREFIX_NAME."a_0",
										rldramii_ba_0	=> $PREFIX_NAME."ba_0",
										rldramii_a_1	=> $PREFIX_NAME."a_1",
										rldramii_ba_1	=> $PREFIX_NAME."ba_1",
										control_qvld	=> "control_qvld",#[]",
										control_rdata	=> "control_rdata",
									},
									
									inout_port_map	=>
									{
										rldramii_dq 	=> $PREFIX_NAME."dq",					
									},
								}),
							);
						} else {
							$module->add_contents
							(
								e_comment->new({comment => "Instantiate CIO RLDRAM II Datapath"}),
								e_blind_instance->new
								({
									name 		=> "rldramii_io",            
									module 		=> $gWRAPPER_NAME."_auk_rldramii_datapath",
									comment 	=> "---------------------------------------------------------------------\n
									RLDRAM II Controller Datapath\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk 		=> "clk",
										write_clk 	=> "write_clk",
										addr_cmd_clk 	=> "addr_cmd_clk",
										reset_clk_n	=> "reset_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										non_dqs_capture_clk => "non_dqs_capture_clk",
										rldramii_qvld	=> $PREFIX_NAME."qvld",
										control_doing_wr => "control_doing_wr",
										control_wdata_valid => "control_wdata_valid",
										control_wdata	=> "control_wdata",
										control_cs_n	=> "control_cs_n",
										control_we_n	=> "control_we_n",
										control_ref_n	=> "control_ref_n",
										control_a	=> "control_a",
										control_ba	=> "control_ba",
										control_dm	=> "control_dm",
									},
					
									out_port_map	=>
									{
										rldramii_cs_n_0	=> $PREFIX_NAME."cs_n_0",
										rldramii_we_n_0	=> $PREFIX_NAME."we_n_0",
										rldramii_ref_n_0 => $PREFIX_NAME."ref_n_0",
										rldramii_cs_n_1	=> $PREFIX_NAME."cs_n_1",
										rldramii_we_n_1	=> $PREFIX_NAME."we_n_1",
										rldramii_ref_n_1 => $PREFIX_NAME."ref_n_1",
										rldramii_dm	=> $PREFIX_NAME."dm",#[]",
										rldramii_a_0	=> $PREFIX_NAME."a_0",
										rldramii_ba_0	=> $PREFIX_NAME."ba_0",
										rldramii_a_1	=> $PREFIX_NAME."a_1",
										rldramii_ba_1	=> $PREFIX_NAME."ba_1",
										control_qvld	=> "control_qvld",#[]",
										control_rdata	=> "control_rdata",
									},
									
									inout_port_map	=>
									{
										rldramii_dq 	=> $PREFIX_NAME."dq",					
									},
								}),
							);
						}
					}
				} else {
					if($num_addr_cmd_buses == 1) {
						if ($ddio_memory_clocks eq "true") {
							$module->add_contents
							(
								e_comment->new({comment => "Instantiate CIO RLDRAM II Datapath"}),
								e_blind_instance->new
								({
									name 		=> "rldramii_io",            
									module 		=> $gWRAPPER_NAME."_auk_rldramii_datapath",
									comment 	=> "---------------------------------------------------------------------\n
									RLDRAM II Controller Datapath\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk 		=> "clk",
										write_clk 	=> "write_clk",
										addr_cmd_clk 	=> "addr_cmd_clk",
										reset_clk_n	=> "reset_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										non_dqs_capture_clk => "non_dqs_capture_clk",
										rldramii_qvld	=> $PREFIX_NAME."qvld",
										control_doing_wr => "control_doing_wr",
										control_wdata_valid => "control_wdata_valid",
										control_wdata	=> "control_wdata",
										control_cs_n	=> "control_cs_n",
										control_we_n	=> "control_we_n",
										control_ref_n	=> "control_ref_n",
										control_a	=> "control_a",
										control_ba	=> "control_ba",
									},
					
									out_port_map	=>
									{
										rldramii_clk    => $PREFIX_NAME."clk",
										rldramii_clk_n  => $PREFIX_NAME."clk_n",
										rldramii_cs_n_0	=> $PREFIX_NAME."cs_n_0",
										rldramii_we_n_0	=> $PREFIX_NAME."we_n_0",
										rldramii_ref_n_0 => $PREFIX_NAME."ref_n_0",
										rldramii_a_0	=> $PREFIX_NAME."a_0",
										rldramii_ba_0	=> $PREFIX_NAME."ba_0",
										control_qvld	=> "control_qvld",#[]",
										control_rdata	=> "control_rdata",
									},
									
									inout_port_map	=>
									{
										rldramii_dq 	=> $PREFIX_NAME."dq",					
									},
								}),
							);
						} else {
							$module->add_contents
							(
								e_comment->new({comment => "Instantiate CIO RLDRAM II Datapath"}),
								e_blind_instance->new
								({
									name 		=> "rldramii_io",            
									module 		=> $gWRAPPER_NAME."_auk_rldramii_datapath",
									comment 	=> "---------------------------------------------------------------------\n
									RLDRAM II Controller Datapath\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk 		=> "clk",
										write_clk 	=> "write_clk",
										addr_cmd_clk 	=> "addr_cmd_clk",
										reset_clk_n	=> "reset_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										non_dqs_capture_clk => "non_dqs_capture_clk",
										rldramii_qvld	=> $PREFIX_NAME."qvld",
										control_doing_wr => "control_doing_wr",
										control_wdata_valid => "control_wdata_valid",
										control_wdata	=> "control_wdata",
										control_cs_n	=> "control_cs_n",
										control_we_n	=> "control_we_n",
										control_ref_n	=> "control_ref_n",
										control_a	=> "control_a",
										control_ba	=> "control_ba",
									},
					
									out_port_map	=>
									{
										rldramii_cs_n_0	=> $PREFIX_NAME."cs_n_0",
										rldramii_we_n_0	=> $PREFIX_NAME."we_n_0",
										rldramii_ref_n_0 => $PREFIX_NAME."ref_n_0",
										rldramii_a_0	=> $PREFIX_NAME."a_0",
										rldramii_ba_0	=> $PREFIX_NAME."ba_0",
										control_qvld	=> "control_qvld",#[]",
										control_rdata	=> "control_rdata",
									},
									
									inout_port_map	=>
									{
										rldramii_dq 	=> $PREFIX_NAME."dq",					
									},
								}),
							);
						}
					}
					
					if($num_addr_cmd_buses > 1) {
						if ($ddio_memory_clocks eq "true") {
							$module->add_contents
							(
								e_comment->new({comment => "Instantiate CIO RLDRAM II Datapath"}),
								e_blind_instance->new
								({
									name 		=> "rldramii_io",            
									module 		=> $gWRAPPER_NAME."_auk_rldramii_datapath",
									comment 	=> "---------------------------------------------------------------------\n
									RLDRAM II Controller Datapath\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk 		=> "clk",
										write_clk 	=> "write_clk",
										addr_cmd_clk 	=> "addr_cmd_clk",
										reset_clk_n	=> "reset_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										non_dqs_capture_clk => "non_dqs_capture_clk",
										rldramii_qvld	=> $PREFIX_NAME."qvld",
										control_doing_wr => "control_doing_wr",
										control_wdata_valid => "control_wdata_valid",
										control_wdata	=> "control_wdata",
										control_cs_n	=> "control_cs_n",
										control_we_n	=> "control_we_n",
										control_ref_n	=> "control_ref_n",
										control_a	=> "control_a",
										control_ba	=> "control_ba",
									},
					
									out_port_map	=>
									{
										rldramii_clk    => $PREFIX_NAME."clk",
										rldramii_clk_n  => $PREFIX_NAME."clk_n",
										rldramii_cs_n_0	=> $PREFIX_NAME."cs_n_0",
										rldramii_we_n_0	=> $PREFIX_NAME."we_n_0",
										rldramii_ref_n_0 => $PREFIX_NAME."ref_n_0",
										rldramii_cs_n_1	=> $PREFIX_NAME."cs_n_1",
										rldramii_we_n_1	=> $PREFIX_NAME."we_n_1",
										rldramii_ref_n_1 => $PREFIX_NAME."ref_n_1",
										rldramii_a_0	=> $PREFIX_NAME."a_0",
										rldramii_ba_0	=> $PREFIX_NAME."ba_0",
										rldramii_a_1	=> $PREFIX_NAME."a_1",
										rldramii_ba_1	=> $PREFIX_NAME."ba_1",
										control_qvld	=> "control_qvld",#[]",
										control_rdata	=> "control_rdata",
									},
									
									inout_port_map	=>
									{
										rldramii_dq 	=> $PREFIX_NAME."dq",					
									},
								}),
							);
						} else {
							$module->add_contents
							(
								e_comment->new({comment => "Instantiate CIO RLDRAM II Datapath"}),
								e_blind_instance->new
								({
									name 		=> "rldramii_io",            
									module 		=> $gWRAPPER_NAME."_auk_rldramii_datapath",
									comment 	=> "---------------------------------------------------------------------\n
									RLDRAM II Controller Datapath\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk 		=> "clk",
										write_clk 	=> "write_clk",
										addr_cmd_clk 	=> "addr_cmd_clk",
										reset_clk_n	=> "reset_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										non_dqs_capture_clk => "non_dqs_capture_clk",
										rldramii_qvld	=> $PREFIX_NAME."qvld",
										control_doing_wr => "control_doing_wr",
										control_wdata_valid => "control_wdata_valid",
										control_wdata	=> "control_wdata",
										control_cs_n	=> "control_cs_n",
										control_we_n	=> "control_we_n",
										control_ref_n	=> "control_ref_n",
										control_a	=> "control_a",
										control_ba	=> "control_ba",
									},
					
									out_port_map	=>
									{
										rldramii_cs_n_0	=> $PREFIX_NAME."cs_n_0",
										rldramii_we_n_0	=> $PREFIX_NAME."we_n_0",
										rldramii_ref_n_0 => $PREFIX_NAME."ref_n_0",
										rldramii_cs_n_1	=> $PREFIX_NAME."cs_n_1",
										rldramii_we_n_1	=> $PREFIX_NAME."we_n_1",
										rldramii_ref_n_1 => $PREFIX_NAME."ref_n_1",
										rldramii_a_0	=> $PREFIX_NAME."a_0",
										rldramii_ba_0	=> $PREFIX_NAME."ba_0",
										rldramii_a_1	=> $PREFIX_NAME."a_1",
										rldramii_ba_1	=> $PREFIX_NAME."ba_1",
										control_qvld	=> "control_qvld",#[]",
										control_rdata	=> "control_rdata",
									},
									
									inout_port_map	=>
									{
										rldramii_dq 	=> $PREFIX_NAME."dq",					
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
			if($enable_addr_cmd_clk eq "false") {
				if($enable_dm_pins eq "true") {
					if($num_addr_cmd_buses == 1) {
						if ($ddio_memory_clocks eq "true") {
							$module->add_contents
							(
								e_comment->new({comment => "Instantiate SIO RLDRAM II Datapath"}),
								e_blind_instance->new
								({
									name 		=> "rldramii_io",            
									module 		=> $gWRAPPER_NAME."_auk_rldramii_datapath",
									comment 	=> "---------------------------------------------------------------------\n
									RLDRAM II Controller Datapath\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk 		=> "clk",
										write_clk 	=> "write_clk",
										reset_clk_n	=> "reset_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										dqs_delay_ctrl 	=> "dqs_delay_ctrl",
										rldramii_q	=> $PREFIX_NAME."q",
										rldramii_qvld	=> $PREFIX_NAME."qvld",
										control_doing_wr => "control_doing_wr",
										control_wdata_valid => "control_wdata_valid",
										control_wdata	=> "control_wdata",
										control_cs_n	=> "control_cs_n",
										control_we_n	=> "control_we_n",
										control_ref_n	=> "control_ref_n",
										control_a	=> "control_a",
										control_ba	=> "control_ba",
										control_dm	=> "control_dm",
                                        rldramii_qk	=> $PREFIX_NAME."qk",
									},
					
									out_port_map	=>
									{
										capture_clk 	=> "capture_clk",#[]",
										rldramii_d	=> $PREFIX_NAME."d",
										rldramii_clk    => $PREFIX_NAME."clk",
										rldramii_clk_n  => $PREFIX_NAME."clk_n",
										rldramii_cs_n_0	=> $PREFIX_NAME."cs_n_0",
										rldramii_we_n_0	=> $PREFIX_NAME."we_n_0",
										rldramii_ref_n_0 => $PREFIX_NAME."ref_n_0",
										rldramii_a_0	=> $PREFIX_NAME."a_0",
										rldramii_ba_0	=> $PREFIX_NAME."ba_0",
										rldramii_dm	=> $PREFIX_NAME."dm",#[]",
										control_qvld	=> "control_qvld",#[]",
										control_rdata	=> "control_rdata",
									},
									
									inout_port_map	=>
									{
										#rldramii_qk	=> $PREFIX_NAME."qk",#[]",
									},
								}),
							);
						} else {
							$module->add_contents
							(
								e_comment->new({comment => "Instantiate SIO RLDRAM II Datapath"}),
								e_blind_instance->new
								({
									name 		=> "rldramii_io",            
									module 		=> $gWRAPPER_NAME."_auk_rldramii_datapath",
									comment 	=> "---------------------------------------------------------------------\n
									RLDRAM II Controller Datapath\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk 		=> "clk",
										write_clk 	=> "write_clk",
										reset_clk_n	=> "reset_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										dqs_delay_ctrl 	=> "dqs_delay_ctrl",
										rldramii_q	=> $PREFIX_NAME."q",
										rldramii_qvld	=> $PREFIX_NAME."qvld",
										control_doing_wr => "control_doing_wr",
										control_wdata_valid => "control_wdata_valid",
										control_wdata	=> "control_wdata",
										control_cs_n	=> "control_cs_n",
										control_we_n	=> "control_we_n",
										control_ref_n	=> "control_ref_n",
										control_a	=> "control_a",
										control_ba	=> "control_ba",
										control_dm	=> "control_dm",
                                        rldramii_qk	=> $PREFIX_NAME."qk",
									},
					
									out_port_map	=>
									{
										capture_clk 	=> "capture_clk",#[]",
										rldramii_d	=> $PREFIX_NAME."d",
										rldramii_cs_n_0	=> $PREFIX_NAME."cs_n_0",
										rldramii_we_n_0	=> $PREFIX_NAME."we_n_0",
										rldramii_ref_n_0 => $PREFIX_NAME."ref_n_0",
										rldramii_a_0	=> $PREFIX_NAME."a_0",
										rldramii_ba_0	=> $PREFIX_NAME."ba_0",
										rldramii_dm	=> $PREFIX_NAME."dm",#[]",
										control_qvld	=> "control_qvld",#[]",
										control_rdata	=> "control_rdata",
									},
									
									inout_port_map	=>
									{
										#rldramii_qk	=> $PREFIX_NAME."qk",#[]",
									},
								}),
							);
						}
					}
					
					if($num_addr_cmd_buses > 1) {
						if ($ddio_memory_clocks eq "true") {
							$module->add_contents
							(
								e_comment->new({comment => "Instantiate SIO RLDRAM II Datapath"}),
								e_blind_instance->new
								({
									name 		=> "rldramii_io",            
									module 		=> $gWRAPPER_NAME."_auk_rldramii_datapath",
									comment 	=> "---------------------------------------------------------------------\n
									RLDRAM II Controller Datapath\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk 		=> "clk",
										write_clk 	=> "write_clk",
										reset_clk_n	=> "reset_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										dqs_delay_ctrl 	=> "dqs_delay_ctrl",
										rldramii_q	=> $PREFIX_NAME."q",
										rldramii_qvld	=> $PREFIX_NAME."qvld",
										control_doing_wr => "control_doing_wr",
										control_wdata_valid => "control_wdata_valid",
										control_wdata	=> "control_wdata",
										control_cs_n	=> "control_cs_n",
										control_we_n	=> "control_we_n",
										control_ref_n	=> "control_ref_n",
										control_a	=> "control_a",
										control_ba	=> "control_ba",
										control_dm	=> "control_dm",
                                        rldramii_qk	=> $PREFIX_NAME."qk",
									},
					
									out_port_map	=>
									{
										capture_clk 	=> "capture_clk",#[]",
										rldramii_d	=> $PREFIX_NAME."d",
										rldramii_clk    => $PREFIX_NAME."clk",
										rldramii_clk_n  => $PREFIX_NAME."clk_n",
										rldramii_cs_n_0	=> $PREFIX_NAME."cs_n_0",
										rldramii_we_n_0	=> $PREFIX_NAME."we_n_0",
										rldramii_ref_n_0 => $PREFIX_NAME."ref_n_0",
										rldramii_cs_n_1	=> $PREFIX_NAME."cs_n_1",
										rldramii_we_n_1	=> $PREFIX_NAME."we_n_1",
										rldramii_ref_n_1 => $PREFIX_NAME."ref_n_1",
										rldramii_a_0	=> $PREFIX_NAME."a_0",
										rldramii_ba_0	=> $PREFIX_NAME."ba_0",
										rldramii_a_1	=> $PREFIX_NAME."a_1",
										rldramii_ba_1	=> $PREFIX_NAME."ba_1",
										rldramii_dm	=> $PREFIX_NAME."dm",#[]",
										control_qvld	=> "control_qvld",#[]",
										control_rdata	=> "control_rdata",
									},
									
									inout_port_map	=>
									{
										#rldramii_qk	=> $PREFIX_NAME."qk",#[]",
									},
								}),
							);
						} else {
							$module->add_contents
							(
								e_comment->new({comment => "Instantiate SIO RLDRAM II Datapath"}),
								e_blind_instance->new
								({
									name 		=> "rldramii_io",            
									module 		=> $gWRAPPER_NAME."_auk_rldramii_datapath",
									comment 	=> "---------------------------------------------------------------------\n
									RLDRAM II Controller Datapath\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk 		=> "clk",
										write_clk 	=> "write_clk",
										reset_clk_n	=> "reset_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										dqs_delay_ctrl 	=> "dqs_delay_ctrl",
										rldramii_q	=> $PREFIX_NAME."q",
										rldramii_qvld	=> $PREFIX_NAME."qvld",
										control_doing_wr => "control_doing_wr",
										control_wdata_valid => "control_wdata_valid",
										control_wdata	=> "control_wdata",
										control_cs_n	=> "control_cs_n",
										control_we_n	=> "control_we_n",
										control_ref_n	=> "control_ref_n",
										control_a	=> "control_a",
										control_ba	=> "control_ba",
										control_dm	=> "control_dm",
                                        rldramii_qk	=> $PREFIX_NAME."qk",
									},
					
									out_port_map	=>
									{
										capture_clk 	=> "capture_clk",#[]",
										rldramii_d	=> $PREFIX_NAME."d",
										rldramii_cs_n_0	=> $PREFIX_NAME."cs_n_0",
										rldramii_we_n_0	=> $PREFIX_NAME."we_n_0",
										rldramii_ref_n_0 => $PREFIX_NAME."ref_n_0",
										rldramii_cs_n_1	=> $PREFIX_NAME."cs_n_1",
										rldramii_we_n_1	=> $PREFIX_NAME."we_n_1",
										rldramii_ref_n_1 => $PREFIX_NAME."ref_n_1",
										rldramii_a_0	=> $PREFIX_NAME."a_0",
										rldramii_ba_0	=> $PREFIX_NAME."ba_0",
										rldramii_a_1	=> $PREFIX_NAME."a_1",
										rldramii_ba_1	=> $PREFIX_NAME."ba_1",
										rldramii_dm	=> $PREFIX_NAME."dm",#[]",
										control_qvld	=> "control_qvld",#[]",
										control_rdata	=> "control_rdata",
									},
									
									inout_port_map	=>
									{
										#rldramii_qk	=> $PREFIX_NAME."qk",#[]",
									},
								}),
							);
						}
					}
					
				} else {
					if($num_addr_cmd_buses == 1) {
						if ($ddio_memory_clocks eq "true") {
							$module->add_contents
							(
								e_comment->new({comment => "Instantiate SIO RLDRAM II Datapath"}),
								e_blind_instance->new
								({
									name 		=> "rldramii_io",            
									module 		=> $gWRAPPER_NAME."_auk_rldramii_datapath",
									comment 	=> "---------------------------------------------------------------------\n
									RLDRAM II Controller Datapath\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk 		=> "clk",
										write_clk 	=> "write_clk",
										reset_clk_n	=> "reset_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										dqs_delay_ctrl 	=> "dqs_delay_ctrl",
										rldramii_q	=> $PREFIX_NAME."q",
										rldramii_qvld	=> $PREFIX_NAME."qvld",
										control_doing_wr => "control_doing_wr",
										control_wdata_valid => "control_wdata_valid",
										control_wdata	=> "control_wdata",
										control_cs_n	=> "control_cs_n",
										control_we_n	=> "control_we_n",
										control_ref_n	=> "control_ref_n",
										control_a	=> "control_a",
										control_ba	=> "control_ba",
                                        rldramii_qk	=> $PREFIX_NAME."qk",
									},
					
									out_port_map	=>
									{
										capture_clk 	=> "capture_clk",#[]",
										rldramii_d	=> $PREFIX_NAME."d",
										rldramii_clk    => $PREFIX_NAME."clk",
										rldramii_clk_n  => $PREFIX_NAME."clk_n",
										rldramii_cs_n_0	=> $PREFIX_NAME."cs_n_0",
										rldramii_we_n_0	=> $PREFIX_NAME."we_n_0",
										rldramii_ref_n_0 => $PREFIX_NAME."ref_n_0",
										rldramii_a_0	=> $PREFIX_NAME."a_0",
										rldramii_ba_0	=> $PREFIX_NAME."ba_0",
										control_qvld	=> "control_qvld",#[]",
										control_rdata	=> "control_rdata",
									},
									
									inout_port_map	=>
									{
										#rldramii_qk	=> $PREFIX_NAME."qk",#[]",
									},
								}),
							);
						} else {
							$module->add_contents
							(
								e_comment->new({comment => "Instantiate SIO RLDRAM II Datapath"}),
								e_blind_instance->new
								({
									name 		=> "rldramii_io",            
									module 		=> $gWRAPPER_NAME."_auk_rldramii_datapath",
									comment 	=> "---------------------------------------------------------------------\n
									RLDRAM II Controller Datapath\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk 		=> "clk",
										write_clk 	=> "write_clk",
										reset_clk_n	=> "reset_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										dqs_delay_ctrl 	=> "dqs_delay_ctrl",
										rldramii_q	=> $PREFIX_NAME."q",
										rldramii_qvld	=> $PREFIX_NAME."qvld",
										control_doing_wr => "control_doing_wr",
										control_wdata_valid => "control_wdata_valid",
										control_wdata	=> "control_wdata",
										control_cs_n	=> "control_cs_n",
										control_we_n	=> "control_we_n",
										control_ref_n	=> "control_ref_n",
										control_a	=> "control_a",
										control_ba	=> "control_ba",
                                        rldramii_qk	=> $PREFIX_NAME."qk",
									},
					
									out_port_map	=>
									{
										capture_clk 	=> "capture_clk",#[]",
										rldramii_d	=> $PREFIX_NAME."d",
										rldramii_cs_n_0	=> $PREFIX_NAME."cs_n_0",
										rldramii_we_n_0	=> $PREFIX_NAME."we_n_0",
										rldramii_ref_n_0 => $PREFIX_NAME."ref_n_0",
										rldramii_a_0	=> $PREFIX_NAME."a_0",
										rldramii_ba_0	=> $PREFIX_NAME."ba_0",
										control_qvld	=> "control_qvld",#[]",
										control_rdata	=> "control_rdata",
									},
									
									inout_port_map	=>
									{
										#rldramii_qk	=> $PREFIX_NAME."qk",#[]",
									},
								}),
							);
						}
					}
					
					if($num_addr_cmd_buses > 1) {
						if ($ddio_memory_clocks eq "true") {
							$module->add_contents
							(
								e_comment->new({comment => "Instantiate SIO RLDRAM II Datapath"}),
								e_blind_instance->new
								({
									name 		=> "rldramii_io",            
									module 		=> $gWRAPPER_NAME."_auk_rldramii_datapath",
									comment 	=> "---------------------------------------------------------------------\n
									RLDRAM II Controller Datapath\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk 		=> "clk",
										write_clk 	=> "write_clk",
										reset_clk_n	=> "reset_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										dqs_delay_ctrl 	=> "dqs_delay_ctrl",
										rldramii_q	=> $PREFIX_NAME."q",
										rldramii_qvld	=> $PREFIX_NAME."qvld",
										control_doing_wr => "control_doing_wr",
										control_wdata_valid => "control_wdata_valid",
										control_wdata	=> "control_wdata",
										control_cs_n	=> "control_cs_n",
										control_we_n	=> "control_we_n",
										control_ref_n	=> "control_ref_n",
										control_a	=> "control_a",
										control_ba	=> "control_ba",
                                        rldramii_qk	=> $PREFIX_NAME."qk",
									},
					
									out_port_map	=>
									{
										capture_clk 	=> "capture_clk",#[]",
										rldramii_d	=> $PREFIX_NAME."d",
										rldramii_clk    => $PREFIX_NAME."clk",
										rldramii_clk_n  => $PREFIX_NAME."clk_n",
										rldramii_cs_n_0	=> $PREFIX_NAME."cs_n_0",
										rldramii_we_n_0	=> $PREFIX_NAME."we_n_0",
										rldramii_ref_n_0 => $PREFIX_NAME."ref_n_0",
										rldramii_cs_n_1	=> $PREFIX_NAME."cs_n_1",
										rldramii_we_n_1	=> $PREFIX_NAME."we_n_1",
										rldramii_ref_n_1 => $PREFIX_NAME."ref_n_1",
										rldramii_a_0	=> $PREFIX_NAME."a_0",
										rldramii_ba_0	=> $PREFIX_NAME."ba_0",
										rldramii_a_1	=> $PREFIX_NAME."a_1",
										rldramii_ba_1	=> $PREFIX_NAME."ba_1",
										control_qvld	=> "control_qvld",#[]",
										control_rdata	=> "control_rdata",
									},
									
									inout_port_map	=>
									{
										#rldramii_qk	=> $PREFIX_NAME."qk",#[]",
									},
								}),
							);
						} else {
							$module->add_contents
							(
								e_comment->new({comment => "Instantiate SIO RLDRAM II Datapath"}),
								e_blind_instance->new
								({
									name 		=> "rldramii_io",            
									module 		=> $gWRAPPER_NAME."_auk_rldramii_datapath",
									comment 	=> "---------------------------------------------------------------------\n
									RLDRAM II Controller Datapath\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk 		=> "clk",
										write_clk 	=> "write_clk",
										reset_clk_n	=> "reset_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										dqs_delay_ctrl 	=> "dqs_delay_ctrl",
										rldramii_q	=> $PREFIX_NAME."q",
										rldramii_qvld	=> $PREFIX_NAME."qvld",
										control_doing_wr => "control_doing_wr",
										control_wdata_valid => "control_wdata_valid",
										control_wdata	=> "control_wdata",
										control_cs_n	=> "control_cs_n",
										control_we_n	=> "control_we_n",
										control_ref_n	=> "control_ref_n",
										control_a	=> "control_a",
										control_ba	=> "control_ba",
                                        rldramii_qk	=> $PREFIX_NAME."qk",
									},
					
									out_port_map	=>
									{
										capture_clk 	=> "capture_clk",#[]",
										rldramii_d	=> $PREFIX_NAME."d",
										rldramii_cs_n_0	=> $PREFIX_NAME."cs_n_0",
										rldramii_we_n_0	=> $PREFIX_NAME."we_n_0",
										rldramii_ref_n_0 => $PREFIX_NAME."ref_n_0",
										rldramii_cs_n_1	=> $PREFIX_NAME."cs_n_1",
										rldramii_we_n_1	=> $PREFIX_NAME."we_n_1",
										rldramii_ref_n_1 => $PREFIX_NAME."ref_n_1",
										rldramii_a_0	=> $PREFIX_NAME."a_0",
										rldramii_ba_0	=> $PREFIX_NAME."ba_0",
										rldramii_a_1	=> $PREFIX_NAME."a_1",
										rldramii_ba_1	=> $PREFIX_NAME."ba_1",
										control_qvld	=> "control_qvld",#[]",
										control_rdata	=> "control_rdata",
									},
									
									inout_port_map	=>
									{
										#rldramii_qk	=> $PREFIX_NAME."qk",#[]",
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
					if($num_addr_cmd_buses == 1) {
						if ($ddio_memory_clocks eq "true") {
							$module->add_contents
							(
								e_comment->new({comment => "Instantiate SIO RLDRAM II Datapath"}),
								e_blind_instance->new
								({
									name 		=> "rldramii_io",            
									module 		=> $gWRAPPER_NAME."_auk_rldramii_datapath",
									comment 	=> "---------------------------------------------------------------------\n
									RLDRAM II Controller Datapath\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk 		=> "clk",
										write_clk 	=> "write_clk",
										addr_cmd_clk 	=> "addr_cmd_clk",
										reset_clk_n	=> "reset_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										dqs_delay_ctrl 	=> "dqs_delay_ctrl",
										rldramii_q	=> $PREFIX_NAME."q",
										rldramii_qvld	=> $PREFIX_NAME."qvld",
										control_doing_wr => "control_doing_wr",
										control_wdata_valid => "control_wdata_valid",
										control_wdata	=> "control_wdata",
										control_cs_n	=> "control_cs_n",
										control_we_n	=> "control_we_n",
										control_ref_n	=> "control_ref_n",
										control_a	=> "control_a",
										control_ba	=> "control_ba",
										control_dm	=> "control_dm",
                                        rldramii_qk	=> $PREFIX_NAME."qk",
									},
					
									out_port_map	=>
									{
										capture_clk 	=> "capture_clk",#[]",
										rldramii_d	=> $PREFIX_NAME."d",
										rldramii_clk    => $PREFIX_NAME."clk",
										rldramii_clk_n  => $PREFIX_NAME."clk_n",
										rldramii_cs_n_0	=> $PREFIX_NAME."cs_n_0",
										rldramii_we_n_0	=> $PREFIX_NAME."we_n_0",
										rldramii_ref_n_0 => $PREFIX_NAME."ref_n_0",
										rldramii_a_0	=> $PREFIX_NAME."a_0",
										rldramii_ba_0	=> $PREFIX_NAME."ba_0",
										rldramii_dm	=> $PREFIX_NAME."dm",#[]",
										control_qvld	=> "control_qvld",#[]",
										control_rdata	=> "control_rdata",
									},
									
									inout_port_map	=>
									{
										#rldramii_qk	=> $PREFIX_NAME."qk",#[]",
									},
								}),
							);
						} else {
							$module->add_contents
							(
								e_comment->new({comment => "Instantiate SIO RLDRAM II Datapath"}),
								e_blind_instance->new
								({
									name 		=> "rldramii_io",            
									module 		=> $gWRAPPER_NAME."_auk_rldramii_datapath",
									comment 	=> "---------------------------------------------------------------------\n
									RLDRAM II Controller Datapath\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk 		=> "clk",
										write_clk 	=> "write_clk",
										addr_cmd_clk 	=> "addr_cmd_clk",
										reset_clk_n	=> "reset_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										dqs_delay_ctrl 	=> "dqs_delay_ctrl",
										rldramii_q	=> $PREFIX_NAME."q",
										rldramii_qvld	=> $PREFIX_NAME."qvld",
										control_doing_wr => "control_doing_wr",
										control_wdata_valid => "control_wdata_valid",
										control_wdata	=> "control_wdata",
										control_cs_n	=> "control_cs_n",
										control_we_n	=> "control_we_n",
										control_ref_n	=> "control_ref_n",
										control_a	=> "control_a",
										control_ba	=> "control_ba",
										control_dm	=> "control_dm",
                                        rldramii_qk	=> $PREFIX_NAME."qk",
									},
					
									out_port_map	=>
									{
										capture_clk 	=> "capture_clk",#[]",
										rldramii_d	=> $PREFIX_NAME."d",
										rldramii_cs_n_0	=> $PREFIX_NAME."cs_n_0",
										rldramii_we_n_0	=> $PREFIX_NAME."we_n_0",
										rldramii_ref_n_0 => $PREFIX_NAME."ref_n_0",
										rldramii_a_0	=> $PREFIX_NAME."a_0",
										rldramii_ba_0	=> $PREFIX_NAME."ba_0",
										rldramii_dm	=> $PREFIX_NAME."dm",#[]",
										control_qvld	=> "control_qvld",#[]",
										control_rdata	=> "control_rdata",
									},
									
									inout_port_map	=>
									{
										#rldramii_qk	=> $PREFIX_NAME."qk",#[]",
									},
								}),
							);
						}
					}
					
					if($num_addr_cmd_buses > 1) {
						if ($ddio_memory_clocks eq "true") {
							$module->add_contents
							(
								e_comment->new({comment => "Instantiate SIO RLDRAM II Datapath"}),
								e_blind_instance->new
								({
									name 		=> "rldramii_io",            
									module 		=> $gWRAPPER_NAME."_auk_rldramii_datapath",
									comment 	=> "---------------------------------------------------------------------\n
									RLDRAM II Controller Datapath\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk 		=> "clk",
										write_clk 	=> "write_clk",
										addr_cmd_clk 	=> "addr_cmd_clk",
										reset_clk_n	=> "reset_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										dqs_delay_ctrl 	=> "dqs_delay_ctrl",
										rldramii_q	=> $PREFIX_NAME."q",
										rldramii_qvld	=> $PREFIX_NAME."qvld",
										control_doing_wr => "control_doing_wr",
										control_wdata_valid => "control_wdata_valid",
										control_wdata	=> "control_wdata",
										control_cs_n	=> "control_cs_n",
										control_we_n	=> "control_we_n",
										control_ref_n	=> "control_ref_n",
										control_a	=> "control_a",
										control_ba	=> "control_ba",
										control_dm	=> "control_dm",
                                        rldramii_qk	=> $PREFIX_NAME."qk",
									},
					
									out_port_map	=>
									{
										capture_clk 	=> "capture_clk",#[]",
										rldramii_d	=> $PREFIX_NAME."d",
										rldramii_clk    => $PREFIX_NAME."clk",
										rldramii_clk_n  => $PREFIX_NAME."clk_n",
										rldramii_cs_n_0	=> $PREFIX_NAME."cs_n_0",
										rldramii_we_n_0	=> $PREFIX_NAME."we_n_0",
										rldramii_ref_n_0 => $PREFIX_NAME."ref_n_0",
										rldramii_cs_n_1	=> $PREFIX_NAME."cs_n_1",
										rldramii_we_n_1	=> $PREFIX_NAME."we_n_1",
										rldramii_ref_n_1 => $PREFIX_NAME."ref_n_1",
										rldramii_a_0	=> $PREFIX_NAME."a_0",
										rldramii_ba_0	=> $PREFIX_NAME."ba_0",
										rldramii_a_1	=> $PREFIX_NAME."a_1",
										rldramii_ba_1	=> $PREFIX_NAME."ba_1",
										rldramii_dm	=> $PREFIX_NAME."dm",#[]",
										control_qvld	=> "control_qvld",#[]",
										control_rdata	=> "control_rdata",
									},
									
									inout_port_map	=>
									{
										#rldramii_qk	=> $PREFIX_NAME."qk",#[]",
									},
								}),
							);
						} else {
							$module->add_contents
							(
								e_comment->new({comment => "Instantiate SIO RLDRAM II Datapath"}),
								e_blind_instance->new
								({
									name 		=> "rldramii_io",            
									module 		=> $gWRAPPER_NAME."_auk_rldramii_datapath",
									comment 	=> "---------------------------------------------------------------------\n
									RLDRAM II Controller Datapath\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk 		=> "clk",
										write_clk 	=> "write_clk",
										addr_cmd_clk 	=> "addr_cmd_clk",
										reset_clk_n	=> "reset_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										dqs_delay_ctrl 	=> "dqs_delay_ctrl",
										rldramii_q	=> $PREFIX_NAME."q",
										rldramii_qvld	=> $PREFIX_NAME."qvld",
										control_doing_wr => "control_doing_wr",
										control_wdata_valid => "control_wdata_valid",
										control_wdata	=> "control_wdata",
										control_cs_n	=> "control_cs_n",
										control_we_n	=> "control_we_n",
										control_ref_n	=> "control_ref_n",
										control_a	=> "control_a",
										control_ba	=> "control_ba",
										control_dm	=> "control_dm",
                                        rldramii_qk	=> $PREFIX_NAME."qk",
									},
					
									out_port_map	=>
									{
										capture_clk 	=> "capture_clk",#[]",
										rldramii_d	=> $PREFIX_NAME."d",
										rldramii_cs_n_0	=> $PREFIX_NAME."cs_n_0",
										rldramii_we_n_0	=> $PREFIX_NAME."we_n_0",
										rldramii_ref_n_0 => $PREFIX_NAME."ref_n_0",
										rldramii_cs_n_1	=> $PREFIX_NAME."cs_n_1",
										rldramii_we_n_1	=> $PREFIX_NAME."we_n_1",
										rldramii_ref_n_1 => $PREFIX_NAME."ref_n_1",
										rldramii_a_0	=> $PREFIX_NAME."a_0",
										rldramii_ba_0	=> $PREFIX_NAME."ba_0",
										rldramii_a_1	=> $PREFIX_NAME."a_1",
										rldramii_ba_1	=> $PREFIX_NAME."ba_1",
										rldramii_dm	=> $PREFIX_NAME."dm",#[]",
										control_qvld	=> "control_qvld",#[]",
										control_rdata	=> "control_rdata",
									},
									
									inout_port_map	=>
									{
										#rldramii_qk	=> $PREFIX_NAME."qk",#[]",
									},
								}),
							);
						}
					}
				} else {
					if($num_addr_cmd_buses == 1) {
						if ($ddio_memory_clocks eq "true") {
							$module->add_contents
							(
								e_comment->new({comment => "Instantiate SIO RLDRAM II Datapath"}),
								e_blind_instance->new
								({
									name 		=> "rldramii_io",            
									module 		=> $gWRAPPER_NAME."_auk_rldramii_datapath",
									comment 	=> "---------------------------------------------------------------------\n
									RLDRAM II Controller Datapath\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk 		=> "clk",
										write_clk 	=> "write_clk",
										addr_cmd_clk 	=> "addr_cmd_clk",
										reset_clk_n	=> "reset_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										dqs_delay_ctrl 	=> "dqs_delay_ctrl",
										rldramii_q	=> $PREFIX_NAME."q",
										rldramii_qvld	=> $PREFIX_NAME."qvld",
										control_doing_wr => "control_doing_wr",
										control_wdata_valid => "control_wdata_valid",
										control_wdata	=> "control_wdata",
										control_cs_n	=> "control_cs_n",
										control_we_n	=> "control_we_n",
										control_ref_n	=> "control_ref_n",
										control_a	=> "control_a",
										control_ba	=> "control_ba",
                                        rldramii_qk	=> $PREFIX_NAME."qk",
									},
					
									out_port_map	=>
									{
										capture_clk 	=> "capture_clk",#[]",
										rldramii_d	=> $PREFIX_NAME."d",
										rldramii_clk    => $PREFIX_NAME."clk",
										rldramii_clk_n  => $PREFIX_NAME."clk_n",
										rldramii_cs_n_0	=> $PREFIX_NAME."cs_n_0",
										rldramii_we_n_0	=> $PREFIX_NAME."we_n_0",
										rldramii_ref_n_0 => $PREFIX_NAME."ref_n_0",
										rldramii_a_0	=> $PREFIX_NAME."a_0",
										rldramii_ba_0	=> $PREFIX_NAME."ba_0",
										control_qvld	=> "control_qvld",#[]",
										control_rdata	=> "control_rdata",
									},
									
									inout_port_map	=>
									{
										#rldramii_qk	=> $PREFIX_NAME."qk",#[]",
									},
								}),
							);
						} else {
							$module->add_contents
							(
								e_comment->new({comment => "Instantiate SIO RLDRAM II Datapath"}),
								e_blind_instance->new
								({
									name 		=> "rldramii_io",            
									module 		=> $gWRAPPER_NAME."_auk_rldramii_datapath",
									comment 	=> "---------------------------------------------------------------------\n
									RLDRAM II Controller Datapath\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk 		=> "clk",
										write_clk 	=> "write_clk",
										addr_cmd_clk 	=> "addr_cmd_clk",
										reset_clk_n	=> "reset_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										dqs_delay_ctrl 	=> "dqs_delay_ctrl",
										rldramii_q	=> $PREFIX_NAME."q",
										rldramii_qvld	=> $PREFIX_NAME."qvld",
										control_doing_wr => "control_doing_wr",
										control_wdata_valid => "control_wdata_valid",
										control_wdata	=> "control_wdata",
										control_cs_n	=> "control_cs_n",
										control_we_n	=> "control_we_n",
										control_ref_n	=> "control_ref_n",
										control_a	=> "control_a",
										control_ba	=> "control_ba",
                                        rldramii_qk	=> $PREFIX_NAME."qk",
									},
					
									out_port_map	=>
									{
										capture_clk 	=> "capture_clk",#[]",
										rldramii_d	=> $PREFIX_NAME."d",
										rldramii_cs_n_0	=> $PREFIX_NAME."cs_n_0",
										rldramii_we_n_0	=> $PREFIX_NAME."we_n_0",
										rldramii_ref_n_0 => $PREFIX_NAME."ref_n_0",
										rldramii_a_0	=> $PREFIX_NAME."a_0",
										rldramii_ba_0	=> $PREFIX_NAME."ba_0",
										control_qvld	=> "control_qvld",#[]",
										control_rdata	=> "control_rdata",
									},
									
									inout_port_map	=>
									{
										#rldramii_qk	=> $PREFIX_NAME."qk",#[]",
									},
								}),
							);
						}
					}
					
					if($num_addr_cmd_buses > 1) {
						if ($ddio_memory_clocks eq "true") {
							$module->add_contents
							(
								e_comment->new({comment => "Instantiate SIO RLDRAM II Datapath"}),
								e_blind_instance->new
								({
									name 		=> "rldramii_io",            
									module 		=> $gWRAPPER_NAME."_auk_rldramii_datapath",
									comment 	=> "---------------------------------------------------------------------\n
									RLDRAM II Controller Datapath\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk 		=> "clk",
										write_clk 	=> "write_clk",
										addr_cmd_clk 	=> "addr_cmd_clk",
										reset_clk_n	=> "reset_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										dqs_delay_ctrl 	=> "dqs_delay_ctrl",
										rldramii_q	=> $PREFIX_NAME."q",
										rldramii_qvld	=> $PREFIX_NAME."qvld",
										control_doing_wr => "control_doing_wr",
										control_wdata_valid => "control_wdata_valid",
										control_wdata	=> "control_wdata",
										control_cs_n	=> "control_cs_n",
										control_we_n	=> "control_we_n",
										control_ref_n	=> "control_ref_n",
										control_a	=> "control_a",
										control_ba	=> "control_ba",
                                        rldramii_qk	=> $PREFIX_NAME."qk",
									},
					
									out_port_map	=>
									{
										capture_clk 	=> "capture_clk",#[]",
										rldramii_d	=> $PREFIX_NAME."d",
										rldramii_clk    => $PREFIX_NAME."clk",
										rldramii_clk_n  => $PREFIX_NAME."clk_n",
										rldramii_cs_n_0	=> $PREFIX_NAME."cs_n_0",
										rldramii_we_n_0	=> $PREFIX_NAME."we_n_0",
										rldramii_ref_n_0 => $PREFIX_NAME."ref_n_0",
										rldramii_cs_n_1	=> $PREFIX_NAME."cs_n_1",
										rldramii_we_n_1	=> $PREFIX_NAME."we_n_1",
										rldramii_ref_n_1 => $PREFIX_NAME."ref_n_1",
										rldramii_a_0	=> $PREFIX_NAME."a_0",
										rldramii_ba_0	=> $PREFIX_NAME."ba_0",
										rldramii_a_1	=> $PREFIX_NAME."a_1",
										rldramii_ba_1	=> $PREFIX_NAME."ba_1",
										control_qvld	=> "control_qvld",#[]",
										control_rdata	=> "control_rdata",
									},
									
									inout_port_map	=>
									{
										#rldramii_qk	=> $PREFIX_NAME."qk",#[]",
									},
								}),
							);
						} else {
							$module->add_contents
							(
								e_comment->new({comment => "Instantiate SIO RLDRAM II Datapath"}),
								e_blind_instance->new
								({
									name 		=> "rldramii_io",            
									module 		=> $gWRAPPER_NAME."_auk_rldramii_datapath",
									comment 	=> "---------------------------------------------------------------------\n
									RLDRAM II Controller Datapath\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk 		=> "clk",
										write_clk 	=> "write_clk",
										addr_cmd_clk 	=> "addr_cmd_clk",
										reset_clk_n	=> "reset_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										dqs_delay_ctrl 	=> "dqs_delay_ctrl",
										rldramii_q	=> $PREFIX_NAME."q",
										rldramii_qvld	=> $PREFIX_NAME."qvld",
										control_doing_wr => "control_doing_wr",
										control_wdata_valid => "control_wdata_valid",
										control_wdata	=> "control_wdata",
										control_cs_n	=> "control_cs_n",
										control_we_n	=> "control_we_n",
										control_ref_n	=> "control_ref_n",
										control_a	=> "control_a",
										control_ba	=> "control_ba",
                                        rldramii_qk	=> $PREFIX_NAME."qk",
									},
					
									out_port_map	=>
									{
										capture_clk 	=> "capture_clk",#[]",
										rldramii_d	=> $PREFIX_NAME."d",
										rldramii_cs_n_0	=> $PREFIX_NAME."cs_n_0",
										rldramii_we_n_0	=> $PREFIX_NAME."we_n_0",
										rldramii_ref_n_0 => $PREFIX_NAME."ref_n_0",
										rldramii_cs_n_1	=> $PREFIX_NAME."cs_n_1",
										rldramii_we_n_1	=> $PREFIX_NAME."we_n_1",
										rldramii_ref_n_1 => $PREFIX_NAME."ref_n_1",
										rldramii_a_0	=> $PREFIX_NAME."a_0",
										rldramii_ba_0	=> $PREFIX_NAME."ba_0",
										rldramii_a_1	=> $PREFIX_NAME."a_1",
										rldramii_ba_1	=> $PREFIX_NAME."ba_1",
										control_qvld	=> "control_qvld",#[]",
										control_rdata	=> "control_rdata",
									},
									
									inout_port_map	=>
									{
										#rldramii_qk	=> $PREFIX_NAME."qk",#[]",
									},
								}),
							);
						}
					}
				}
			}
		}
		else
		{
			if($enable_addr_cmd_clk eq "false") {
				if($enable_dm_pins eq "true") {
					if($num_addr_cmd_buses == 1) {
						if ($ddio_memory_clocks eq "true") {
							$module->add_contents
							(
								e_comment->new({comment => "Instantiate SIO RLDRAM II Datapath"}),
								e_blind_instance->new
								({
									name 		=> "rldramii_io",            
									module 		=> $gWRAPPER_NAME."_auk_rldramii_datapath",
									comment 	=> "---------------------------------------------------------------------\n
									RLDRAM II Controller Datapath\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk 		=> "clk",
										write_clk 	=> "write_clk",
										reset_clk_n	=> "reset_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										non_dqs_capture_clk => "non_dqs_capture_clk",
										rldramii_q	=> $PREFIX_NAME."q",
										rldramii_qvld	=> $PREFIX_NAME."qvld",
										control_doing_wr => "control_doing_wr",
										control_wdata_valid => "control_wdata_valid",
										control_wdata	=> "control_wdata",
										control_cs_n	=> "control_cs_n",
										control_we_n	=> "control_we_n",
										control_ref_n	=> "control_ref_n",
										control_a	=> "control_a",
										control_ba	=> "control_ba",
										control_dm	=> "control_dm",
									},
					
									out_port_map	=>
									{
										rldramii_d	=> $PREFIX_NAME."d",
										rldramii_clk    => $PREFIX_NAME."clk",
										rldramii_clk_n  => $PREFIX_NAME."clk_n",
										rldramii_cs_n_0	=> $PREFIX_NAME."cs_n_0",
										rldramii_we_n_0	=> $PREFIX_NAME."we_n_0",
										rldramii_ref_n_0 => $PREFIX_NAME."ref_n_0",
										rldramii_a_0	=> $PREFIX_NAME."a_0",
										rldramii_ba_0	=> $PREFIX_NAME."ba_0",
										rldramii_dm	=> $PREFIX_NAME."dm",#[]",
										control_qvld	=> "control_qvld",#[]",
										control_rdata	=> "control_rdata",
									},
								}),
							);
						} else {
							$module->add_contents
							(
								e_comment->new({comment => "Instantiate SIO RLDRAM II Datapath"}),
								e_blind_instance->new
								({
									name 		=> "rldramii_io",            
									module 		=> $gWRAPPER_NAME."_auk_rldramii_datapath",
									comment 	=> "---------------------------------------------------------------------\n
									RLDRAM II Controller Datapath\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk 		=> "clk",
										write_clk 	=> "write_clk",
										reset_clk_n	=> "reset_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										non_dqs_capture_clk => "non_dqs_capture_clk",
										rldramii_q	=> $PREFIX_NAME."q",
										rldramii_qvld	=> $PREFIX_NAME."qvld",
										control_doing_wr => "control_doing_wr",
										control_wdata_valid => "control_wdata_valid",
										control_wdata	=> "control_wdata",
										control_cs_n	=> "control_cs_n",
										control_we_n	=> "control_we_n",
										control_ref_n	=> "control_ref_n",
										control_a	=> "control_a",
										control_ba	=> "control_ba",
										control_dm	=> "control_dm",
									},
					
									out_port_map	=>
									{
										rldramii_d	=> $PREFIX_NAME."d",
										rldramii_cs_n_0	=> $PREFIX_NAME."cs_n_0",
										rldramii_we_n_0	=> $PREFIX_NAME."we_n_0",
										rldramii_ref_n_0 => $PREFIX_NAME."ref_n_0",
										rldramii_a_0	=> $PREFIX_NAME."a_0",
										rldramii_ba_0	=> $PREFIX_NAME."ba_0",
										rldramii_dm	=> $PREFIX_NAME."dm",#[]",
										control_qvld	=> "control_qvld",#[]",
										control_rdata	=> "control_rdata",
									},
								}),
							);
						}
					}
					
					if($num_addr_cmd_buses > 1) {
						if ($ddio_memory_clocks eq "true") {
							$module->add_contents
							(
								e_comment->new({comment => "Instantiate SIO RLDRAM II Datapath"}),
								e_blind_instance->new
								({
									name 		=> "rldramii_io",            
									module 		=> $gWRAPPER_NAME."_auk_rldramii_datapath",
									comment 	=> "---------------------------------------------------------------------\n
									RLDRAM II Controller Datapath\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk 		=> "clk",
										write_clk 	=> "write_clk",
										reset_clk_n	=> "reset_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										non_dqs_capture_clk => "non_dqs_capture_clk",
										rldramii_q	=> $PREFIX_NAME."q",
										rldramii_qvld	=> $PREFIX_NAME."qvld",
										control_doing_wr => "control_doing_wr",
										control_wdata_valid => "control_wdata_valid",
										control_wdata	=> "control_wdata",
										control_cs_n	=> "control_cs_n",
										control_we_n	=> "control_we_n",
										control_ref_n	=> "control_ref_n",
										control_a	=> "control_a",
										control_ba	=> "control_ba",
										control_dm	=> "control_dm",
									},
					
									out_port_map	=>
									{
										rldramii_d	=> $PREFIX_NAME."d",
										rldramii_clk    => $PREFIX_NAME."clk",
										rldramii_clk_n  => $PREFIX_NAME."clk_n",
										rldramii_cs_n_0	=> $PREFIX_NAME."cs_n_0",
										rldramii_we_n_0	=> $PREFIX_NAME."we_n_0",
										rldramii_ref_n_0 => $PREFIX_NAME."ref_n_0",
										rldramii_cs_n_1	=> $PREFIX_NAME."cs_n_1",
										rldramii_we_n_1	=> $PREFIX_NAME."we_n_1",
										rldramii_ref_n_1 => $PREFIX_NAME."ref_n_1",
										rldramii_a_0	=> $PREFIX_NAME."a_0",
										rldramii_ba_0	=> $PREFIX_NAME."ba_0",
										rldramii_a_1	=> $PREFIX_NAME."a_1",
										rldramii_ba_1	=> $PREFIX_NAME."ba_1",
										rldramii_dm	=> $PREFIX_NAME."dm",#[]",
										control_qvld	=> "control_qvld",#[]",
										control_rdata	=> "control_rdata",
									},
								}),
							);
						} else {
							$module->add_contents
							(
								e_comment->new({comment => "Instantiate SIO RLDRAM II Datapath"}),
								e_blind_instance->new
								({
									name 		=> "rldramii_io",            
									module 		=> $gWRAPPER_NAME."_auk_rldramii_datapath",
									comment 	=> "---------------------------------------------------------------------\n
									RLDRAM II Controller Datapath\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk 		=> "clk",
										write_clk 	=> "write_clk",
										reset_clk_n	=> "reset_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										non_dqs_capture_clk => "non_dqs_capture_clk",
										rldramii_q	=> $PREFIX_NAME."q",
										rldramii_qvld	=> $PREFIX_NAME."qvld",
										control_doing_wr => "control_doing_wr",
										control_wdata_valid => "control_wdata_valid",
										control_wdata	=> "control_wdata",
										control_cs_n	=> "control_cs_n",
										control_we_n	=> "control_we_n",
										control_ref_n	=> "control_ref_n",
										control_a	=> "control_a",
										control_ba	=> "control_ba",
										control_dm	=> "control_dm",
									},
					
									out_port_map	=>
									{
										rldramii_d	=> $PREFIX_NAME."d",
										rldramii_cs_n_0	=> $PREFIX_NAME."cs_n_0",
										rldramii_we_n_0	=> $PREFIX_NAME."we_n_0",
										rldramii_ref_n_0 => $PREFIX_NAME."ref_n_0",
										rldramii_cs_n_1	=> $PREFIX_NAME."cs_n_1",
										rldramii_we_n_1	=> $PREFIX_NAME."we_n_1",
										rldramii_ref_n_1 => $PREFIX_NAME."ref_n_1",
										rldramii_a_0	=> $PREFIX_NAME."a_0",
										rldramii_ba_0	=> $PREFIX_NAME."ba_0",
										rldramii_a_1	=> $PREFIX_NAME."a_1",
										rldramii_ba_1	=> $PREFIX_NAME."ba_1",
										rldramii_dm	=> $PREFIX_NAME."dm",#[]",
										control_qvld	=> "control_qvld",#[]",
										control_rdata	=> "control_rdata",
									},
								}),
							);
						}
					}
				} else {
					if($num_addr_cmd_buses == 1) {
						if ($ddio_memory_clocks eq "true") {
							$module->add_contents
							(
								e_comment->new({comment => "Instantiate SIO RLDRAM II Datapath"}),
								e_blind_instance->new
								({
									name 		=> "rldramii_io",            
									module 		=> $gWRAPPER_NAME."_auk_rldramii_datapath",
									comment 	=> "---------------------------------------------------------------------\n
									RLDRAM II Controller Datapath\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk 		=> "clk",
										write_clk 	=> "write_clk",
										reset_clk_n	=> "reset_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										non_dqs_capture_clk => "non_dqs_capture_clk",
										rldramii_q	=> $PREFIX_NAME."q",
										rldramii_qvld	=> $PREFIX_NAME."qvld",
										control_doing_wr => "control_doing_wr",
										control_wdata_valid => "control_wdata_valid",
										control_wdata	=> "control_wdata",
										control_cs_n	=> "control_cs_n",
										control_we_n	=> "control_we_n",
										control_ref_n	=> "control_ref_n",
										control_a	=> "control_a",
										control_ba	=> "control_ba",
									},
					
									out_port_map	=>
									{
										rldramii_d	=> $PREFIX_NAME."d",
										rldramii_clk    => $PREFIX_NAME."clk",
										rldramii_clk_n  => $PREFIX_NAME."clk_n",
										rldramii_cs_n_0	=> $PREFIX_NAME."cs_n_0",
										rldramii_we_n_0	=> $PREFIX_NAME."we_n_0",
										rldramii_ref_n_0 => $PREFIX_NAME."ref_n_0",
										rldramii_a_0	=> $PREFIX_NAME."a_0",
										rldramii_ba_0	=> $PREFIX_NAME."ba_0",
										control_qvld	=> "control_qvld",#[]",
										control_rdata	=> "control_rdata",
									},
								}),
							);
						} else {
							$module->add_contents
							(
								e_comment->new({comment => "Instantiate SIO RLDRAM II Datapath"}),
								e_blind_instance->new
								({
									name 		=> "rldramii_io",            
									module 		=> $gWRAPPER_NAME."_auk_rldramii_datapath",
									comment 	=> "---------------------------------------------------------------------\n
									RLDRAM II Controller Datapath\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk 		=> "clk",
										write_clk 	=> "write_clk",
										reset_clk_n	=> "reset_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										non_dqs_capture_clk => "non_dqs_capture_clk",
										rldramii_q	=> $PREFIX_NAME."q",
										rldramii_qvld	=> $PREFIX_NAME."qvld",
										control_doing_wr => "control_doing_wr",
										control_wdata_valid => "control_wdata_valid",
										control_wdata	=> "control_wdata",
										control_cs_n	=> "control_cs_n",
										control_we_n	=> "control_we_n",
										control_ref_n	=> "control_ref_n",
										control_a	=> "control_a",
										control_ba	=> "control_ba",
									},
					
									out_port_map	=>
									{
										rldramii_d	=> $PREFIX_NAME."d",
										rldramii_cs_n_0	=> $PREFIX_NAME."cs_n_0",
										rldramii_we_n_0	=> $PREFIX_NAME."we_n_0",
										rldramii_ref_n_0 => $PREFIX_NAME."ref_n_0",
										rldramii_a_0	=> $PREFIX_NAME."a_0",
										rldramii_ba_0	=> $PREFIX_NAME."ba_0",
										control_qvld	=> "control_qvld",#[]",
										control_rdata	=> "control_rdata",
									},
								}),
							);
						}
					}
					
					if($num_addr_cmd_buses > 1) {
						if ($ddio_memory_clocks eq "true") {
							$module->add_contents
							(
								e_comment->new({comment => "Instantiate SIO RLDRAM II Datapath"}),
								e_blind_instance->new
								({
									name 		=> "rldramii_io",            
									module 		=> $gWRAPPER_NAME."_auk_rldramii_datapath",
									comment 	=> "---------------------------------------------------------------------\n
									RLDRAM II Controller Datapath\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk 		=> "clk",
										write_clk 	=> "write_clk",
										reset_clk_n	=> "reset_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										non_dqs_capture_clk => "non_dqs_capture_clk",
										rldramii_q	=> $PREFIX_NAME."q",
										rldramii_qvld	=> $PREFIX_NAME."qvld",
										control_doing_wr => "control_doing_wr",
										control_wdata_valid => "control_wdata_valid",
										control_wdata	=> "control_wdata",
										control_cs_n	=> "control_cs_n",
										control_we_n	=> "control_we_n",
										control_ref_n	=> "control_ref_n",
										control_a	=> "control_a",
										control_ba	=> "control_ba",
									},
					
									out_port_map	=>
									{
										rldramii_d	=> $PREFIX_NAME."d",
										rldramii_clk    => $PREFIX_NAME."clk",
										rldramii_clk_n  => $PREFIX_NAME."clk_n",
										rldramii_cs_n_0	=> $PREFIX_NAME."cs_n_0",
										rldramii_we_n_0	=> $PREFIX_NAME."we_n_0",
										rldramii_ref_n_0 => $PREFIX_NAME."ref_n_0",
										rldramii_cs_n_1	=> $PREFIX_NAME."cs_n_1",
										rldramii_we_n_1	=> $PREFIX_NAME."we_n_1",
										rldramii_ref_n_1 => $PREFIX_NAME."ref_n_1",
										rldramii_a_0	=> $PREFIX_NAME."a_0",
										rldramii_ba_0	=> $PREFIX_NAME."ba_0",
										rldramii_a_1	=> $PREFIX_NAME."a_1",
										rldramii_ba_1	=> $PREFIX_NAME."ba_1",
										control_qvld	=> "control_qvld",#[]",
										control_rdata	=> "control_rdata",
									},
								}),
							);
						} else {
							$module->add_contents
							(
								e_comment->new({comment => "Instantiate SIO RLDRAM II Datapath"}),
								e_blind_instance->new
								({
									name 		=> "rldramii_io",            
									module 		=> $gWRAPPER_NAME."_auk_rldramii_datapath",
									comment 	=> "---------------------------------------------------------------------\n
									RLDRAM II Controller Datapath\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk 		=> "clk",
										write_clk 	=> "write_clk",
										reset_clk_n	=> "reset_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										non_dqs_capture_clk => "non_dqs_capture_clk",
										rldramii_q	=> $PREFIX_NAME."q",
										rldramii_qvld	=> $PREFIX_NAME."qvld",
										control_doing_wr => "control_doing_wr",
										control_wdata_valid => "control_wdata_valid",
										control_wdata	=> "control_wdata",
										control_cs_n	=> "control_cs_n",
										control_we_n	=> "control_we_n",
										control_ref_n	=> "control_ref_n",
										control_a	=> "control_a",
										control_ba	=> "control_ba",
									},
					
									out_port_map	=>
									{
										rldramii_d	=> $PREFIX_NAME."d",
										rldramii_cs_n_0	=> $PREFIX_NAME."cs_n_0",
										rldramii_we_n_0	=> $PREFIX_NAME."we_n_0",
										rldramii_ref_n_0 => $PREFIX_NAME."ref_n_0",
										rldramii_cs_n_1	=> $PREFIX_NAME."cs_n_1",
										rldramii_we_n_1	=> $PREFIX_NAME."we_n_1",
										rldramii_ref_n_1 => $PREFIX_NAME."ref_n_1",
										rldramii_a_0	=> $PREFIX_NAME."a_0",
										rldramii_ba_0	=> $PREFIX_NAME."ba_0",
										rldramii_a_1	=> $PREFIX_NAME."a_1",
										rldramii_ba_1	=> $PREFIX_NAME."ba_1",
										control_qvld	=> "control_qvld",#[]",
										control_rdata	=> "control_rdata",
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
					if($num_addr_cmd_buses == 1) {
						if ($ddio_memory_clocks eq "true") {
							$module->add_contents
							(
								e_comment->new({comment => "Instantiate SIO RLDRAM II Datapath"}),
								e_blind_instance->new
								({
									name 		=> "rldramii_io",            
									module 		=> $gWRAPPER_NAME."_auk_rldramii_datapath",
									comment 	=> "---------------------------------------------------------------------\n
									RLDRAM II Controller Datapath\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk 		=> "clk",
										write_clk 	=> "write_clk",
										addr_cmd_clk 	=> "addr_cmd_clk",
										reset_clk_n	=> "reset_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										non_dqs_capture_clk => "non_dqs_capture_clk",
										rldramii_q	=> $PREFIX_NAME."q",
										rldramii_qvld	=> $PREFIX_NAME."qvld",
										control_doing_wr => "control_doing_wr",
										control_wdata_valid => "control_wdata_valid",
										control_wdata	=> "control_wdata",
										control_cs_n	=> "control_cs_n",
										control_we_n	=> "control_we_n",
										control_ref_n	=> "control_ref_n",
										control_a	=> "control_a",
										control_ba	=> "control_ba",
										control_dm	=> "control_dm",
									},
					
									out_port_map	=>
									{
										rldramii_d	=> $PREFIX_NAME."d",
										rldramii_clk    => $PREFIX_NAME."clk",
										rldramii_clk_n  => $PREFIX_NAME."clk_n",
										rldramii_cs_n_0	=> $PREFIX_NAME."cs_n_0",
										rldramii_we_n_0	=> $PREFIX_NAME."we_n_0",
										rldramii_ref_n_0 => $PREFIX_NAME."ref_n_0",
										rldramii_a_0	=> $PREFIX_NAME."a_0",
										rldramii_ba_0	=> $PREFIX_NAME."ba_0",
										rldramii_dm	=> $PREFIX_NAME."dm",#[]",
										control_qvld	=> "control_qvld",#[]",
										control_rdata	=> "control_rdata",
									},
								}),
							);
						} else {
							$module->add_contents
							(
								e_comment->new({comment => "Instantiate SIO RLDRAM II Datapath"}),
								e_blind_instance->new
								({
									name 		=> "rldramii_io",            
									module 		=> $gWRAPPER_NAME."_auk_rldramii_datapath",
									comment 	=> "---------------------------------------------------------------------\n
									RLDRAM II Controller Datapath\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk 		=> "clk",
										write_clk 	=> "write_clk",
										addr_cmd_clk 	=> "addr_cmd_clk",
										reset_clk_n	=> "reset_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										non_dqs_capture_clk => "non_dqs_capture_clk",
										rldramii_q	=> $PREFIX_NAME."q",
										rldramii_qvld	=> $PREFIX_NAME."qvld",
										control_doing_wr => "control_doing_wr",
										control_wdata_valid => "control_wdata_valid",
										control_wdata	=> "control_wdata",
										control_cs_n	=> "control_cs_n",
										control_we_n	=> "control_we_n",
										control_ref_n	=> "control_ref_n",
										control_a	=> "control_a",
										control_ba	=> "control_ba",
										control_dm	=> "control_dm",
									},
					
									out_port_map	=>
									{
										rldramii_d	=> $PREFIX_NAME."d",
										rldramii_cs_n_0	=> $PREFIX_NAME."cs_n_0",
										rldramii_we_n_0	=> $PREFIX_NAME."we_n_0",
										rldramii_ref_n_0 => $PREFIX_NAME."ref_n_0",
										rldramii_a_0	=> $PREFIX_NAME."a_0",
										rldramii_ba_0	=> $PREFIX_NAME."ba_0",
										rldramii_dm	=> $PREFIX_NAME."dm",#[]",
										control_qvld	=> "control_qvld",#[]",
										control_rdata	=> "control_rdata",
									},
								}),
							);
						}
					}
					
					if($num_addr_cmd_buses > 1) {
						if ($ddio_memory_clocks eq "true") {
							$module->add_contents
							(
								e_comment->new({comment => "Instantiate SIO RLDRAM II Datapath"}),
								e_blind_instance->new
								({
									name 		=> "rldramii_io",            
									module 		=> $gWRAPPER_NAME."_auk_rldramii_datapath",
									comment 	=> "---------------------------------------------------------------------\n
									RLDRAM II Controller Datapath\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk 		=> "clk",
										write_clk 	=> "write_clk",
										addr_cmd_clk 	=> "addr_cmd_clk",
										reset_clk_n	=> "reset_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										non_dqs_capture_clk => "non_dqs_capture_clk",
										rldramii_q	=> $PREFIX_NAME."q",
										rldramii_qvld	=> $PREFIX_NAME."qvld",
										control_doing_wr => "control_doing_wr",
										control_wdata_valid => "control_wdata_valid",
										control_wdata	=> "control_wdata",
										control_cs_n	=> "control_cs_n",
										control_we_n	=> "control_we_n",
										control_ref_n	=> "control_ref_n",
										control_a	=> "control_a",
										control_ba	=> "control_ba",
										control_dm	=> "control_dm",
									},
					
									out_port_map	=>
									{
										rldramii_d	=> $PREFIX_NAME."d",
										rldramii_clk    => $PREFIX_NAME."clk",
										rldramii_clk_n  => $PREFIX_NAME."clk_n",
										rldramii_cs_n_0	=> $PREFIX_NAME."cs_n_0",
										rldramii_we_n_0	=> $PREFIX_NAME."we_n_0",
										rldramii_ref_n_0 => $PREFIX_NAME."ref_n_0",
										rldramii_cs_n_1	=> $PREFIX_NAME."cs_n_1",
										rldramii_we_n_1	=> $PREFIX_NAME."we_n_1",
										rldramii_ref_n_1 => $PREFIX_NAME."ref_n_1",
										rldramii_a_0	=> $PREFIX_NAME."a_0",
										rldramii_ba_0	=> $PREFIX_NAME."ba_0",
										rldramii_a_1	=> $PREFIX_NAME."a_1",
										rldramii_ba_1	=> $PREFIX_NAME."ba_1",
										rldramii_dm	=> $PREFIX_NAME."dm",#[]",
										control_qvld	=> "control_qvld",#[]",
										control_rdata	=> "control_rdata",
									},
								}),
							);
						} else {
							$module->add_contents
							(
								e_comment->new({comment => "Instantiate SIO RLDRAM II Datapath"}),
								e_blind_instance->new
								({
									name 		=> "rldramii_io",            
									module 		=> $gWRAPPER_NAME."_auk_rldramii_datapath",
									comment 	=> "---------------------------------------------------------------------\n
									RLDRAM II Controller Datapath\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk 		=> "clk",
										write_clk 	=> "write_clk",
										addr_cmd_clk 	=> "addr_cmd_clk",
										reset_clk_n	=> "reset_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										non_dqs_capture_clk => "non_dqs_capture_clk",
										rldramii_q	=> $PREFIX_NAME."q",
										rldramii_qvld	=> $PREFIX_NAME."qvld",
										control_doing_wr => "control_doing_wr",
										control_wdata_valid => "control_wdata_valid",
										control_wdata	=> "control_wdata",
										control_cs_n	=> "control_cs_n",
										control_we_n	=> "control_we_n",
										control_ref_n	=> "control_ref_n",
										control_a	=> "control_a",
										control_ba	=> "control_ba",
										control_dm	=> "control_dm",
									},
					
									out_port_map	=>
									{
										rldramii_d	=> $PREFIX_NAME."d",
										rldramii_cs_n_0	=> $PREFIX_NAME."cs_n_0",
										rldramii_we_n_0	=> $PREFIX_NAME."we_n_0",
										rldramii_ref_n_0 => $PREFIX_NAME."ref_n_0",
										rldramii_cs_n_1	=> $PREFIX_NAME."cs_n_1",
										rldramii_we_n_1	=> $PREFIX_NAME."we_n_1",
										rldramii_ref_n_1 => $PREFIX_NAME."ref_n_1",
										rldramii_a_0	=> $PREFIX_NAME."a_0",
										rldramii_ba_0	=> $PREFIX_NAME."ba_0",
										rldramii_a_1	=> $PREFIX_NAME."a_1",
										rldramii_ba_1	=> $PREFIX_NAME."ba_1",
										rldramii_dm	=> $PREFIX_NAME."dm",#[]",
										control_qvld	=> "control_qvld",#[]",
										control_rdata	=> "control_rdata",
									},
								}),
							);
						}
					}
				} else {
					if($num_addr_cmd_buses == 1) {
						if ($ddio_memory_clocks eq "true") {
							$module->add_contents
							(
								e_comment->new({comment => "Instantiate SIO RLDRAM II Datapath"}),
								e_blind_instance->new
								({
									name 		=> "rldramii_io",            
									module 		=> $gWRAPPER_NAME."_auk_rldramii_datapath",
									comment 	=> "---------------------------------------------------------------------\n
									RLDRAM II Controller Datapath\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk 		=> "clk",
										write_clk 	=> "write_clk",
										addr_cmd_clk 	=> "addr_cmd_clk",
										reset_clk_n	=> "reset_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										non_dqs_capture_clk => "non_dqs_capture_clk",
										rldramii_q	=> $PREFIX_NAME."q",
										rldramii_qvld	=> $PREFIX_NAME."qvld",
										control_doing_wr => "control_doing_wr",
										control_wdata_valid => "control_wdata_valid",
										control_wdata	=> "control_wdata",
										control_cs_n	=> "control_cs_n",
										control_we_n	=> "control_we_n",
										control_ref_n	=> "control_ref_n",
										control_a	=> "control_a",
										control_ba	=> "control_ba",
									},
					
									out_port_map	=>
									{
										rldramii_d	=> $PREFIX_NAME."d",
										rldramii_clk    => $PREFIX_NAME."clk",
										rldramii_clk_n  => $PREFIX_NAME."clk_n",
										rldramii_cs_n_0	=> $PREFIX_NAME."cs_n_0",
										rldramii_we_n_0	=> $PREFIX_NAME."we_n_0",
										rldramii_ref_n_0 => $PREFIX_NAME."ref_n_0",
										rldramii_a_0	=> $PREFIX_NAME."a_0",
										rldramii_ba_0	=> $PREFIX_NAME."ba_0",
										control_qvld	=> "control_qvld",#[]",
										control_rdata	=> "control_rdata",
									},
								}),
							);
						} else {
							$module->add_contents
							(
								e_comment->new({comment => "Instantiate SIO RLDRAM II Datapath"}),
								e_blind_instance->new
								({
									name 		=> "rldramii_io",            
									module 		=> $gWRAPPER_NAME."_auk_rldramii_datapath",
									comment 	=> "---------------------------------------------------------------------\n
									RLDRAM II Controller Datapath\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk 		=> "clk",
										write_clk 	=> "write_clk",
										addr_cmd_clk 	=> "addr_cmd_clk",
										reset_clk_n	=> "reset_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										non_dqs_capture_clk => "non_dqs_capture_clk",
										rldramii_q	=> $PREFIX_NAME."q",
										rldramii_qvld	=> $PREFIX_NAME."qvld",
										control_doing_wr => "control_doing_wr",
										control_wdata_valid => "control_wdata_valid",
										control_wdata	=> "control_wdata",
										control_cs_n	=> "control_cs_n",
										control_we_n	=> "control_we_n",
										control_ref_n	=> "control_ref_n",
										control_a	=> "control_a",
										control_ba	=> "control_ba",
									},
					
									out_port_map	=>
									{
										rldramii_d	=> $PREFIX_NAME."d",
										rldramii_cs_n_0	=> $PREFIX_NAME."cs_n_0",
										rldramii_we_n_0	=> $PREFIX_NAME."we_n_0",
										rldramii_ref_n_0 => $PREFIX_NAME."ref_n_0",
										rldramii_a_0	=> $PREFIX_NAME."a_0",
										rldramii_ba_0	=> $PREFIX_NAME."ba_0",
										control_qvld	=> "control_qvld",#[]",
										control_rdata	=> "control_rdata",
									},
								}),
							);
						}
					}
					
					if($num_addr_cmd_buses > 1) {
						if ($ddio_memory_clocks eq "true") {
							$module->add_contents
							(
								e_comment->new({comment => "Instantiate SIO RLDRAM II Datapath"}),
								e_blind_instance->new
								({
									name 		=> "rldramii_io",            
									module 		=> $gWRAPPER_NAME."_auk_rldramii_datapath",
									comment 	=> "---------------------------------------------------------------------\n
									RLDRAM II Controller Datapath\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk 		=> "clk",
										write_clk 	=> "write_clk",
										addr_cmd_clk 	=> "addr_cmd_clk",
										reset_clk_n	=> "reset_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										non_dqs_capture_clk => "non_dqs_capture_clk",
										rldramii_q	=> $PREFIX_NAME."q",
										rldramii_qvld	=> $PREFIX_NAME."qvld",
										control_doing_wr => "control_doing_wr",
										control_wdata_valid => "control_wdata_valid",
										control_wdata	=> "control_wdata",
										control_cs_n	=> "control_cs_n",
										control_we_n	=> "control_we_n",
										control_ref_n	=> "control_ref_n",
										control_a	=> "control_a",
										control_ba	=> "control_ba",
									},
					
									out_port_map	=>
									{
										rldramii_d	=> $PREFIX_NAME."d",
										rldramii_clk    => $PREFIX_NAME."clk",
										rldramii_clk_n  => $PREFIX_NAME."clk_n",
										rldramii_cs_n_0	=> $PREFIX_NAME."cs_n_0",
										rldramii_we_n_0	=> $PREFIX_NAME."we_n_0",
										rldramii_ref_n_0 => $PREFIX_NAME."ref_n_0",
										rldramii_cs_n_1	=> $PREFIX_NAME."cs_n_1",
										rldramii_we_n_1	=> $PREFIX_NAME."we_n_1",
										rldramii_ref_n_1 => $PREFIX_NAME."ref_n_1",
										rldramii_a_0	=> $PREFIX_NAME."a_0",
										rldramii_ba_0	=> $PREFIX_NAME."ba_0",
										rldramii_a_1	=> $PREFIX_NAME."a_1",
										rldramii_ba_1	=> $PREFIX_NAME."ba_1",
										control_qvld	=> "control_qvld",#[]",
										control_rdata	=> "control_rdata",
									},
								}),
							);
						} else {
							$module->add_contents
							(
								e_comment->new({comment => "Instantiate SIO RLDRAM II Datapath"}),
								e_blind_instance->new
								({
									name 		=> "rldramii_io",            
									module 		=> $gWRAPPER_NAME."_auk_rldramii_datapath",
									comment 	=> "---------------------------------------------------------------------\n
									RLDRAM II Controller Datapath\n
									---------------------------------------------------------------------\n",
									in_port_map 	=>
									{
										clk 		=> "clk",
										write_clk 	=> "write_clk",
										addr_cmd_clk 	=> "addr_cmd_clk",
										reset_clk_n	=> "reset_clk_n",
										reset_read_clk_n => "reset_read_clk_n",
										reset_addr_cmd_clk_n => "reset_addr_cmd_clk_n",
										non_dqs_capture_clk => "non_dqs_capture_clk",
										rldramii_q	=> $PREFIX_NAME."q",
										rldramii_qvld	=> $PREFIX_NAME."qvld",
										control_doing_wr => "control_doing_wr",
										control_wdata_valid => "control_wdata_valid",
										control_wdata	=> "control_wdata",
										control_cs_n	=> "control_cs_n",
										control_we_n	=> "control_we_n",
										control_ref_n	=> "control_ref_n",
										control_a	=> "control_a",
										control_ba	=> "control_ba",
									},
					
									out_port_map	=>
									{
										rldramii_d	=> $PREFIX_NAME."d",
										rldramii_cs_n_0	=> $PREFIX_NAME."cs_n_0",
										rldramii_we_n_0	=> $PREFIX_NAME."we_n_0",
										rldramii_ref_n_0 => $PREFIX_NAME."ref_n_0",
										rldramii_cs_n_1	=> $PREFIX_NAME."cs_n_1",
										rldramii_we_n_1	=> $PREFIX_NAME."we_n_1",
										rldramii_ref_n_1 => $PREFIX_NAME."ref_n_1",
										rldramii_a_0	=> $PREFIX_NAME."a_0",
										rldramii_ba_0	=> $PREFIX_NAME."ba_0",
										rldramii_a_1	=> $PREFIX_NAME."a_1",
										rldramii_ba_1	=> $PREFIX_NAME."ba_1",
										control_qvld	=> "control_qvld",#[]",
										control_rdata	=> "control_rdata",
									},
								}),
							);
						}
						
					}
				}
			}
		}
	};

#################################################################################################################################################################		
                    
$project->output();

}

1;
