#sopc_builder free coderefre

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

sub write_rldramii_example_driver

{
#my $top = e_module->new({name => $gWRAPPER_NAME."_example_driver"});#,output_file => "/temp_gen/${gWRAPPER_NAME}_example_driver"});
my $top = e_module->new({name => $gWRAPPER_NAME."_example_driver"});#,output_file => "/temp_gen/${gWRAPPER_NAME}_example_driver"});
my $project = e_project->new({top => $top, language => $language,__system_directory =>$output_directory});#'temp_gen'});
my $module = $project->top();

$module->add_attribute(ALTERA_ATTRIBUTE =>"SUPPRESS_DA_RULE_INTERNAL=R105");
#####   Parameters declaration  ######
$header_title = "RLDRAM II Controller Example Driver";
$header_filename = $gWRAPPER_NAME . "_example_driver";
$header_revision = "V" . $gWIZARD_VERSION;
#my $verilog_dq_io_instname;# = "\\g_datapath:\$i:g_ddr_io ";
my $Stratix_Fam = "";
my %stratix_param  = "";
my $LOCAL_DATA_BITS = $gLOCAL_DATA_BITS;
my $LOCAL_DATA_MODE = $gLOCAL_DATA_MODE;
my $LOCAL_ADDR_BITS = 24;
my $LOCAL_BURST_LEN = $gLOCAL_BURST_LEN;
my $LOCAL_BURST_LEN_BITS = $gLOCAL_BURST_LEN_BITS;
my $MEM_ADDR_BITS = $gMEM_ADDR_BITS;
my $MEM_NUM_DEVICES = $gMEM_NUM_DEVICES;
my $MEM_TRC_CYCLES = $gMEM_TRC_CYCLES;
my $MEM_TWL_CYCLES = $gMEM_TWL_CYCLES;
my $RLDRAMII_TYPE = $gRLDRAMII_TYPE;
my $ADDR_SHIFT_BITS = $gADDR_SHIFT_BITS;
my $REFRESH_COMMAND = $gREFRESH_COMMAND;
my $MEM_DQ_PER_DQS = $gMEM_DQ_PER_DQS;
my $WRITE_ALL_MODE = 0;
my $RLDRAMII_CONFIGURATION = $gRLDRAMII_CONFIGURATION;

my $S_IDLE = 0;
my $S_WRITE = 1;
my $S_WR_RD_WAIT1 = 2;
my $S_WR_RD_WAIT2 = 3;
my $S_READ = 4;
my $S_RD_WR_WAIT = 5;
my $S_WAIT = 9;
my $S_PRE_REFRESH = 6;
my $S_REFRESH = 7;
my $S_POST_REFRESH = 8;
my $S_WAIT = 9;

my $NUMBER_DQS;
my $LOCAL_DM_WIDTH = $MEM_NUM_DEVICES * 2;
my $LOCAL_ADDR_BITS = $MEM_ADDR_BITS + $ADDR_SHIFT_BITS + 3;
my $REFRESH_COMMAND = $gREFRESH_COMMAND;
my $REFRESH_COUNT = $gREFRESH_COUNT;

my $ADDR_INCR = int(($LOCAL_DATA_BITS / $MEM_DQ_PER_DQS) * $LOCAL_BURST_LEN);
my $MEMORY_BURST_LEN = int($LOCAL_BURST_LEN * 2);

#### Calculate the number of dqs used ####
if ($LOCAL_DATA_MODE eq "narrow") {
    $NUMBER_DQS = int($LOCAL_DATA_BITS / $MEM_DQ_PER_DQS / 2); 
} else {
    $NUMBER_DQS = int($LOCAL_DATA_BITS / $LOCAL_BURST_LEN / $MEM_DQ_PER_DQS / 2);	
}

my $NUM_DQ_PER_DEVICE = int($NUMBER_DQS / $MEM_NUM_DEVICES);
my $WR_RD_IDLE_INSERT = $gWR_RD_IDLE_INSERT;
my $RD_WR_IDLE_INSERT = $gRD_WR_IDLE_INSERT;

my $CMD_FIFO_WIDTH = 3;

my $ENABLE_CAPTURE_CLK = $gENABLE_CAPTURE_CLK;

my $FIFO_WIDTH = $MEM_DQ_PER_DQS * 2;

if ($ENABLE_CAPTURE_CLK eq "true") {
	$CAPTURE_MODE = non_dqs;
}
else {
	$CAPTURE_MODE = dqs;
}

##### Setup command state machine for differing RLDRAMII configurations
if ($RLDRAMII_TYPE eq "cio") {
	if ($LOCAL_BURST_LEN == 1) {
		$NUMBER_WRITE_READ_CMDS = $MEM_TRC_CYCLES;
		$CMD_SEPARATION_CYCLES = 1;
	}
	elsif ($LOCAL_BURST_LEN == 2) {
		$NUMBER_WRITE_READ_CMDS = int($MEM_TRC_CYCLES/2);
		$CMD_SEPARATION_CYCLES = 2;
	}
	elsif ($LOCAL_BURST_LEN == 4) {
		if ($RLDRAMII_CONFIGURATION == 2) {
			$NUMBER_WRITE_READ_CMDS = 1;
			$CMD_SEPARATION_CYCLES = 5;
		}
		else 
		{
			$NUMBER_WRITE_READ_CMDS = int($MEM_TRC_CYCLES/4);
			$CMD_SEPARATION_CYCLES = 4;
		}
	}
}
else
{
	if ($LOCAL_BURST_LEN == 1) {
		if ($RLDRAMII_CONFIGURATION == 3) {
			$CMD_SEPARATION_CYCLES = 3;
		}
		else
		{
			$CMD_SEPARATION_CYCLES = 2;
		}
	}
	elsif ($LOCAL_BURST_LEN == 2) {
		if ($RLDRAMII_CONFIGURATION == 3) {
			$CMD_SEPARATION_CYCLES = 3;
		}
		else
		{
			$CMD_SEPARATION_CYCLES = 2;
		}
	}
	elsif ($LOCAL_BURST_LEN == 4) {
		$CMD_SEPARATION_CYCLES = 4;
	}


}

###  end parameter list  ######

#######################################################################################################################################
$module->vhdl_libraries()->{altera_mf} = all;
	$module->comment
	(
		"------------------------------------------------------------------------------\n
		\nTitle        : $header_title
		\nProject      : RLDRAM II Controller
		\nFile         : $header_filename
		\nRevision     : $header_revision
		\nAbstract:
		\nRLDRAM II memory controller driver example.
		\nPass Fail
		\n\t     - Per byte lane (non-persistent)
		\n\t     - Single failure (persistent)
		\n\t     - Test complete (persistent)										
		----------------------------------------------------------------------------------\n
		Parameters:\n
		Local Interface Data Width             : $LOCAL_DATA_BITS\n
		Local Interface Data Width Mode        : $LOCAL_DATA_MODE\n
		DQ Bits Per DQS                        : $MEM_DQ_PER_DQS\n
		Number RLDRAM II Address Bits          : $MEM_ADDR_BITS\n
		Local Interface Burst Length           : $LOCAL_BURST_LEN\n
		Number RLDRAM II Memory Devices        : $MEM_NUM_DEVICES\n
		RLDRAM II Memory Type                  : $RLDRAMII_TYPE\n
		Address Shift Bits                     : $ADDR_SHIFT_BITS\n
		Number of DQS Pins                     : $NUMBER_DQS\n
		Read Data Capture Mode                 : $CAPTURE_MODE\n
		Number of tRC Clock Cycles             : $MEM_TRC_CYCLES\n
		Number of tWL Clock Cycles             : $MEM_TWL_CYCLES\n
		Clock Cycles Between Refresh requests  : $REFRESH_COUNT\n
		----------------------------------------------------------------------------------\n",
	);
######################################################################################################################################################################
if ($ENABLE_CAPTURE_CLK eq "false") {
	$module->add_contents
	(
		#####	Ports declaration#	######
		e_port->new({name => "clk",direction => "input"}),
		e_port->new({name => "reset_clk_n",direction => "input"}),
		#e_port->new({name => "reset_read_clk_n",direction => "input"}),
		e_port->new({name => "capture_clk",direction => "input", width => $MEM_NUM_DEVICES}),		 
		e_port->new({name => "local_read_req",direction => "output"}),
		e_port->new({name => "local_write_req",direction => "output"}),
		e_port->new({name => "local_addr",direction => "output",width => $MEM_ADDR_BITS}),
		e_port->new({name => "local_bank_addr",direction => "output",width => 3}),
		e_port->new({name => "local_rdata_valid",direction => "input",width => $MEM_NUM_DEVICES}),
		e_port->new({name => "local_rdata",direction => "input",width => $LOCAL_DATA_BITS}),
		e_port->new({name => "local_wdata_req",direction => "input"}),
		e_port->new({name => "local_wdata",direction => "output",width => $LOCAL_DATA_BITS}),
		e_port->new({name => "local_dm",direction => "output",width => $MEM_NUM_DEVICES * 2}),
		e_port->new({name => "local_init_done",direction => "input"}),
		e_port->new({name => "local_refresh_req",direction => "output"}),
		e_port->new({name => "test_complete",direction => "output"}),
		e_port->new({name => "pnf_per_byte",direction => "output",width => $NUMBER_DQS * 2}),
		e_port->new({name => "pnf_persist",direction => "output"}),
	);
}
else {
	$module->add_contents
	(
		#####	Ports declaration#	######
		e_port->new({name => "clk",direction => "input"}),
		e_port->new({name => "reset_clk_n",direction => "input"}),
		#e_port->new({name => "reset_read_clk_n",direction => "input"}),
		e_port->new({name => "capture_clk",direction => "input", width => 1}),		 
		e_port->new({name => "local_read_req",direction => "output"}),
		e_port->new({name => "local_write_req",direction => "output"}),
		e_port->new({name => "local_addr",direction => "output",width => $MEM_ADDR_BITS}),
		e_port->new({name => "local_bank_addr",direction => "output",width => 3}),
		e_port->new({name => "local_rdata_valid",direction => "input",width => $MEM_NUM_DEVICES}),
		e_port->new({name => "local_rdata",direction => "input",width => $LOCAL_DATA_BITS}),
		e_port->new({name => "local_wdata_req",direction => "input"}),
		e_port->new({name => "local_wdata",direction => "output",width => $LOCAL_DATA_BITS}),
		e_port->new({name => "local_dm",direction => "output",width => $MEM_NUM_DEVICES * 2}),
		e_port->new({name => "local_init_done",direction => "input"}),
		e_port->new({name => "local_refresh_req",direction => "output"}),
		e_port->new({name => "test_complete",direction => "output"}),
		e_port->new({name => "pnf_per_byte",direction => "output",width => $NUMBER_DQS * 2}),
		e_port->new({name => "pnf_persist",direction => "output"}),
	);
}

######################################################################################################################################################################

    if ($ENABLE_CAPTURE_CLK eq "false") {
        $module->add_contents
        (
            #####   signal generation #####
            e_signal->news #: ["signal", width, export, never_export]
            (	
                # ["reset_clk",$MEM_NUM_DEVICES,	0,	1],
                # ["local_init_done_r1",$MEM_NUM_DEVICES,	0,	1],
                # ["local_init_done_r2",$MEM_NUM_DEVICES,	0,	1],
                ["reset_clk",$LOCAL_DATA_BITS / $MEM_DQ_PER_DQS,	0,	1],
                ["local_init_done_r1",$LOCAL_DATA_BITS / $MEM_DQ_PER_DQS,	0,	1],
                ["local_init_done_r2",$LOCAL_DATA_BITS / $MEM_DQ_PER_DQS,	0,	1],
            ),
        );
    } else {
        $module->add_contents
        (
            #####   signal generation #####
            e_signal->news #: ["signal", width, export, never_export]
            (	
                ["reset_clk",1,	0,	1],
                ["local_init_done_r1",1,	0,	1],
                ["local_init_done_r2",1,	0,	1],
            ),
        );
    };

######################################################################################################################################################################
 	$module->add_contents
	(
		#####   signal generation #####
		e_signal->news #: ["signal", width, export, never_export]
		(	
			#["reset_clk",$MEM_NUM_DEVICES,	0,	1],
			["local_init_done_r",1,	0,	1],
            #["local_init_done_r1",$MEM_NUM_DEVICES,	0,	1],
            #["local_init_done_r2",$MEM_NUM_DEVICES,	0,	1],
			["state",3,	0,	1],
			["writing",1,	0,	1],
			["dgen_enable",1,	0,	1],
			["dgen_load",1,	0,	1],
			["write_req",1,	0,	1],
			["read_req",1,	0,	1],
			["dm",$LOCAL_DM_WIDTH,	0,	1],
			["write_addr",$MEM_ADDR_BITS + 3,	0,	1],
			["read_addr",$MEM_ADDR_BITS + 3,	0,	1],
			["write_addr",$MEM_ADDR_BITS + 3,	0,	1],
			["read_addr",$MEM_ADDR_BITS + 3,	0,	1],
			["addr",$MEM_ADDR_BITS + 3,	0,	1],
			["separation_count",4,	0,	1],			
            ["local_rdata_0",($MEM_DQ_PER_DQS * 2),	0,	1],
            ["local_rdata_1",($MEM_DQ_PER_DQS * 2),	0,	1],
            ["local_rdata_2",($MEM_DQ_PER_DQS * 2),	0,	1],
            ["local_rdata_3",($MEM_DQ_PER_DQS * 2),	0,	1],
            ["local_rdata_4",($MEM_DQ_PER_DQS * 2),	0,	1],
            ["local_rdata_5",($MEM_DQ_PER_DQS * 2),	0,	1],
            ["local_rdata_6",($MEM_DQ_PER_DQS * 2),	0,	1],
            ["local_rdata_7",($MEM_DQ_PER_DQS * 2),	0,	1],
            ["local_rdata_8",($MEM_DQ_PER_DQS * 2),	0,	1],
            ["local_rdata_9",($MEM_DQ_PER_DQS * 2),	0,	1],
            ["local_rdata_10",($MEM_DQ_PER_DQS * 2),	0,	1],
            ["local_rdata_11",($MEM_DQ_PER_DQS * 2),	0,	1],
            ["local_rdata_12",($MEM_DQ_PER_DQS * 2),	0,	1],
            ["local_rdata_13",($MEM_DQ_PER_DQS * 2),	0,	1],
            ["local_rdata_14",($MEM_DQ_PER_DQS * 2),	0,	1],
            ["local_rdata_15",($MEM_DQ_PER_DQS * 2),	0,	1],
            ["local_rdata_16",($MEM_DQ_PER_DQS * 2),	0,	1],
            ["local_rdata_17",($MEM_DQ_PER_DQS * 2),	0,	1],
            ["fifo_rdata_0",($MEM_DQ_PER_DQS * 2),	0,	1],
            ["fifo_rdata_1",($MEM_DQ_PER_DQS * 2),	0,	1],
            ["fifo_rdata_2",($MEM_DQ_PER_DQS * 2),	0,	1],
            ["fifo_rdata_3",($MEM_DQ_PER_DQS * 2),	0,	1],
            ["fifo_rdata_4",($MEM_DQ_PER_DQS * 2),	0,	1],
            ["fifo_rdata_5",($MEM_DQ_PER_DQS * 2),	0,	1],
            ["fifo_rdata_6",($MEM_DQ_PER_DQS * 2),	0,	1],
            ["fifo_rdata_7",($MEM_DQ_PER_DQS * 2),	0,	1],
            ["fifo_rdata_8",($MEM_DQ_PER_DQS * 2),	0,	1],
            ["fifo_rdata_9",($MEM_DQ_PER_DQS * 2),	0,	1],
            ["fifo_rdata_10",($MEM_DQ_PER_DQS * 2),	0,	1],
            ["fifo_rdata_11",($MEM_DQ_PER_DQS * 2),	0,	1],
            ["fifo_rdata_12",($MEM_DQ_PER_DQS * 2),	0,	1],
            ["fifo_rdata_13",($MEM_DQ_PER_DQS * 2),	0,	1],
            ["fifo_rdata_14",($MEM_DQ_PER_DQS * 2),	0,	1],
            ["fifo_rdata_15",($MEM_DQ_PER_DQS * 2),	0,	1],
            ["fifo_rdata_16",($MEM_DQ_PER_DQS * 2),	0,	1],
            ["fifo_rdata_17",($MEM_DQ_PER_DQS * 2),	0,	1],
            ["fifo_rdata_0_r1",($MEM_DQ_PER_DQS * 2),	0,	1],
            ["fifo_rdata_1_r1",($MEM_DQ_PER_DQS * 2),	0,	1],
            ["fifo_rdata_2_r1",($MEM_DQ_PER_DQS * 2),	0,	1],
            ["fifo_rdata_3_r1",($MEM_DQ_PER_DQS * 2),	0,	1],
            ["fifo_rdata_4_r1",($MEM_DQ_PER_DQS * 2),	0,	1],
            ["fifo_rdata_5_r1",($MEM_DQ_PER_DQS * 2),	0,	1],
            ["fifo_rdata_6_r1",($MEM_DQ_PER_DQS * 2),	0,	1],
            ["fifo_rdata_7_r1",($MEM_DQ_PER_DQS * 2),	0,	1],
            ["fifo_rdata_8_r1",($MEM_DQ_PER_DQS * 2),	0,	1],
            ["fifo_rdata_9_r1",($MEM_DQ_PER_DQS * 2),	0,	1],
            ["fifo_rdata_10_r1",($MEM_DQ_PER_DQS * 2),	0,	1],
            ["fifo_rdata_11_r1",($MEM_DQ_PER_DQS * 2),	0,	1],
            ["fifo_rdata_12_r1",($MEM_DQ_PER_DQS * 2),	0,	1],
            ["fifo_rdata_13_r1",($MEM_DQ_PER_DQS * 2),	0,	1],
            ["fifo_rdata_14_r1",($MEM_DQ_PER_DQS * 2),	0,	1],
            ["fifo_rdata_15_r1",($MEM_DQ_PER_DQS * 2),	0,	1],
            ["fifo_rdata_16_r1",($MEM_DQ_PER_DQS * 2),	0,	1],
            ["fifo_rdata_17_r1",($MEM_DQ_PER_DQS * 2),	0,	1],
			["data_in_fifo",($LOCAL_DATA_BITS / $MEM_DQ_PER_DQS),	0,	1],
			["data_in_fifo_r",($LOCAL_DATA_BITS / $MEM_DQ_PER_DQS),	0,	1],
			["data_in_fifo_r1",($LOCAL_DATA_BITS / $MEM_DQ_PER_DQS),	0,	1],
            ["data_in_fifo_r2",($LOCAL_DATA_BITS / $MEM_DQ_PER_DQS),	0,	1],
            ["rdata",($LOCAL_DATA_BITS),	0,	1],
			["rdata_r1",($LOCAL_DATA_BITS),	0,	1],
			#["rd_en",1,	0,	1],
	    	["rd_en",($LOCAL_DATA_BITS / $MEM_DQ_PER_DQS),	0,	1],
			["wr_dgen_pause",1,	0,	1],
			["wr_dgen_enable",1,	0,	1],
			["wr_dgen_load",1,	0,	1],
			["wr_dgen_data",$LOCAL_DATA_BITS,	0,	1],
			["rd_dgen_pause",$MEM_NUM_DEVICES,	0,	1],
			["rd_dgen_enable",1,	0,	1],
			["rd_dgen_load",1,	0,	1],
			["rd_dgen_data",$LOCAL_DATA_BITS,	0,	1],
			["rd_compare_data",$LOCAL_DATA_BITS,	0,	1],
			["pnf_per_byte_int",$NUMBER_DQS * 2,	0,	1],
			["pnf_persist_int",($LOCAL_DATA_BITS / $MEM_DQ_PER_DQS)/2,	0,	1],
			["pnf_persist_int_and",($LOCAL_DATA_BITS / $MEM_DQ_PER_DQS)/2,	0,	1],
			["refresh_counter",11,	0,	1],
			["refresh_trc_count",3,	0,	1],
			["initial_trc_complete",1,	0,	1],
			["refresh_trc_completed",1,	0,	1],
			["refresh_request",1,	0,	1],
			["refresh_request_clr",1,	0,	1],
			["addr_after_refresh", $MEM_ADDR_BITS + 3,	0,	1],
			["refresh_ba",3,	0,	1],
			["refresh_req",1,	0,	1],
			["cmd_issued",1,	0,	1],
			["cmd_issued_r",4,	0,	1],
			["separation_pipeline",6,	0,	1],
			["cmd_enable",1,	1,	1],
			["trc_pipeline",6,	0,	1],
			["trc_start",1,	0,	1],
			["local_rdata_valid_r",$MEM_NUM_DEVICES,	0,	1],
			["local_rdata_valid_r1",$MEM_NUM_DEVICES,	0,	1],
			["local_rdata_r",$LOCAL_DATA_BITS,	0,	1],
			["local_rdata_r1",$LOCAL_DATA_BITS,	0,	1],
            ["rdata_valid_persist",($LOCAL_DATA_BITS / $MEM_DQ_PER_DQS)/2,	0,	1],
            ["rdata_valid_persist_r",($LOCAL_DATA_BITS / $MEM_DQ_PER_DQS)/2,	0,	1],
		),
	);	

#########################################################################################################################################################	
	if ($RLDRAMII_TYPE eq "sio") {
		$module->add_contents
		(
			#####   signal generation #####
			e_signal->news #: ["signal", width, export, never_export]
			(	
				["initial_trc_completed",1,	0,	1],
			),
		);
	}
	else
	{
		$module->add_contents
		(
			#####   signal generation #####
			e_signal->news #: ["signal", width, export, never_export]
			(	
				["cmd_count",4,	0,	1],
				["wr_rd_idle_insert",1,	0,	1],
				["rd_wr_idle_insert",1,	0,	1],
			),
		);
	}


#########################################################################################################################################################
	$module->add_contents
	(
		e_signal->new({name => "rd_compare", width => $NUMBER_DQS * 2, export => 0, never_export => 1, declare_one_bit_as_std_logic_vector => 1}),
	);

#########################################################################################################################################################

	$module->add_contents
	(
		e_assign->new({lhs => "local_dm", rhs => "{".$LOCAL_DM_WIDTH."{1'b0}}"}),
		#e_assign->new({lhs => "dm", rhs => "{".$LOCAL_DM_WIDTH."{1'b1}}"}),
		e_assign->new({lhs => "wr_dgen_pause", rhs => "! local_wdata_req"}),
		e_assign->new({lhs => "wr_dgen_load", rhs => "0"}),
		e_assign->new({lhs => "rd_dgen_load", rhs => "0"}),
		#e_assign->new({lhs => "rd_en[0]", rhs => "! data_in_fifo[0]"}),
		#e_assign->new({lhs => "rd_en", rhs => "1"}),
		e_assign->new({lhs => "local_wdata", rhs => "wr_dgen_data"}),
		e_assign->new({lhs => "rd_dgen_enable", rhs => "1"}),
		e_assign->new({lhs => "wr_dgen_enable", rhs => "1"}),
		e_assign->new({lhs => "pnf_per_byte", rhs => "pnf_per_byte_int"}),
		#e_assign->new({lhs => "reset_clk", rhs => "! reset_clk_n"}),
        #e_assign->new({lhs => "reset_clk", rhs => "local_init_done_r2"}),
	);
	
#########################################################################################################################################################
	
	# $module->add_contents
	# (
		# e_process->new
		# ({
			# clock			=> "clk",
			# reset			=> "reset_clk_n",
			# _asynchronous_contents  =>
			# [
				# e_assign->new({lhs => "local_dm", rhs => "0" }),
			# ],
			# _contents		=>
			# [
				# e_assign->new({lhs => "local_dm", rhs => "{".$LOCAL_DM_WIDTH."{local_wdata_req}}"}),
			# ],
		# }),
	# );

	
#################################################################################################################################################################
	for ($i = 0; $i <= $MEM_NUM_DEVICES - 1; $i++ ) {
		$module->add_contents
		(
			e_assign->new({lhs => "rd_dgen_pause[$i]", rhs => "! local_rdata_valid[$i]"}),
		),
	}
#################################################################################################################################################################
	for ($j = 0; $j <= ($LOCAL_DATA_BITS / $MEM_DQ_PER_DQS) - 1; $j++ ) {
		$module->add_contents
		(
			e_assign->new({lhs => "rd_en[$j]", rhs => "! data_in_fifo[$j]"}),
		),
	}
######################################################################################################################################################################
if ($RLDRAMII_TYPE eq "cio") {
	if ($WR_RD_IDLE_INSERT eq "true") {
		$module->add_contents
		(
			e_assign->new({lhs => "wr_rd_idle_insert", rhs => "1" }),
		);
	}	
	else {
		$module->add_contents
		(
			e_assign->new({lhs => "wr_rd_idle_insert", rhs => "0" }),
		);
	}
	
	if ($RD_WR_IDLE_INSERT eq "true") {
		$module->add_contents
		(
			e_assign->new({lhs => "rd_wr_idle_insert", rhs => "1" }),
		);
	}	
	else {
		$module->add_contents
		(
			e_assign->new({lhs => "rd_wr_idle_insert", rhs => "0" }),
		);
	}
}
	
################################################################################################################################################################

        $module->add_contents
	(
		e_process->new
		({
			clock			=> "clk",
			reset			=> "reset_clk_n",
			_asynchronous_contents  =>
			[
				e_assign->new({lhs => "local_init_done_r", rhs => "0" }),
			],
			_contents		=>
			[
				e_assign->new({lhs => "local_init_done_r", rhs => "local_init_done" }),
			],
		}),
	);

    
# ################################################################################################################################################################
# 
    # $module->add_contents
	# (
		# e_process->new
		# ({
			# clock			=> "capture_clk",
			# #reset			=> "reset_clk_n",
            # reset			=> "",
			# _asynchronous_contents  =>
			# [
				# #e_assign->new({lhs => "local_init_done_r1", rhs => "0" }),
                # #e_assign->new({lhs => "local_init_done_r2", rhs => "0" }),
			# ],
			# _contents		=>
			# [
                # e_assign->new({lhs => "local_init_done_r1", rhs => "! local_init_done" }),
				# e_assign->new({lhs => "local_init_done_r2", rhs => "local_init_done_r1" }),
			# ],
		# }),
	# );
    
    
################################################################################################################################################################


 
if ($ENABLE_CAPTURE_CLK eq "false") {
    $l = 0;
    $RVALID_COMPARE = $NUM_DQ_PER_DEVICE;
    
    for ($i = 0; $i <= $LOCAL_DATA_BITS / $MEM_DQ_PER_DQS - 1; $i++ ) {
            $module->add_contents
            (
                e_process->new
                ({
                    clock			=> "capture_clk[$l]",
                    reset			=> "",
                    _asynchronous_contents  =>
                    [
                    ],
                    _contents		=>
                    [
                        e_assign->new({lhs => "local_init_done_r1[$i]", rhs => "! local_init_done" }),
                        e_assign->new({lhs => "local_init_done_r2[$i]", rhs => "local_init_done_r1[$i]" }),
                    ],
                }),
            
                e_assign->new({lhs => "reset_clk[$i]", rhs => "local_init_done_r2[$i]" }),
            );
                
            if ($i == $RVALID_COMPARE - 1) {
                 $RVALID_COMPARE = $RVALID_COMPARE + $NUM_DQ_PER_DEVICE;
                 
                 if ($l == $MEM_NUM_DEVICES - 1) {
                     $l = 0;
                 }
                 else
                 {
                     $l = $l + 1;
                 }
                 
            }
        };
} else {
     $module->add_contents
	 (
		 e_process->new
		 ({
			 clock			=> "capture_clk",
			 reset			=> "",
			 _asynchronous_contents  =>
			 [
			 ],
			 _contents		=>
			 [
                 e_assign->new({lhs => "local_init_done_r1", rhs => "! local_init_done" }),
				 e_assign->new({lhs => "local_init_done_r2", rhs => "local_init_done_r1" }),
			 ],
		 }),
         e_assign->new({lhs => "reset_clk", rhs => "local_init_done_r2" }),
	 );
}
    


	
#################################################################################################################################################################
	for ($i = 0; $i <= $LOCAL_DATA_BITS / $MEM_DQ_PER_DQS - 1; $i++ ) {	 
		$module->add_contents
		(
			e_comment->new({comment => "Instantiate Write  Example_LFSR Module"}),
			e_blind_instance->new
			({
				name 		=> "WR_LFSRGEN_".$i."_lfsr_inst",
				module 		=> "example_lfsr",            
				comment 	=> "---------------------------------------------------------------------\n
				Write Example LFSR Module Instantiation\n
				---------------------------------------------------------------------\n",
				in_port_map 	=>
				{
					"clk"     	=> "clk",
					"reset_n" 	=> "reset_clk_n",
					"enable"  	=> "wr_dgen_enable",
					"pause"   	=> "wr_dgen_pause",
					"load"    	=> "wr_dgen_load",
				},

				out_port_map	=>
				{
					"data" 		=> "wr_dgen_data["."(($i + 1) * $MEM_DQ_PER_DQS) - 1".":"."$i * $MEM_DQ_PER_DQS"."]",
				},
			
				parameter_map 	=>
				{
					"seed" 		  => (10 * $i) + 1,
					"gMEM_DQ_PER_DQS" => $MEM_DQ_PER_DQS,
				},
			}),
		),
	};
	
################################################################################################################################################################	
	 
	 $module->add_contents
	 (
	 	 e_process->new
		 ({
			 clock			=> "clk",
			 reset			=> "reset_clk_n",
			 _asynchronous_contents  =>
			 [
				 e_assign->new({lhs => "refresh_counter", rhs => $REFRESH_COUNT }),
			 ],
			 _contents		=>
			 [
				  e_if->new
				  ({
					 condition	=> "local_init_done",
					 then		=>
					 [
						 e_if->new
						 ({
							 condition	=> "refresh_counter ==0",
							 then		=>
							 [
								 e_assign->new({lhs => "refresh_counter", rhs => "$REFRESH_COUNT" }),
							 ],
							 else =>
							 [
								 e_assign->new({lhs => "refresh_counter", rhs => "refresh_counter - 1" }),
							 ],
						 }),
					 ],
				  }),
			 ],
		 }),
	);
		
	$module->add_contents
	(
		e_process->new
		({
			clock			=> "clk",
			reset			=> "reset_clk_n",
			_asynchronous_contents  =>
			[
				e_assign->new({lhs => "refresh_request", rhs => "0" }),
			],
			_contents		=>
			[
				e_if->new
				({
					condition	=> "refresh_counter == 0",
					then		=>
					[
						e_assign->new({lhs => "refresh_request", rhs => "1" }),
					],
					else =>
					[
						e_if->new
						({
							condition	=> "refresh_request_clr",
							then		=>
							[
								e_assign->new({lhs => "refresh_request", rhs => "0" }),
							],
						}),
					],
				}),
			],
		}),
	);
	
	
################################################################################################################################################################
if ($RLDRAMII_TYPE eq "cio") {
	$module->add_contents
	(
	     e_process->new
	     ({
		      clock			=>	"clk",
		      reset			=>	"reset_clk_n",
		      comment			=>	
		      "\n\n-----------------------------------------------------------------\n
		      Main clocked process\n
		      -----------------------------------------------------------------\n
		      CIO Read / Write control state machine\n
		      -----------------------------------------------------------------",
		      _asynchronous_contents	=>	
		      [
				e_assign->new(["refresh_request_clr" => "0"]),
				e_assign->new(["state" => "0"]),
				e_assign->new(["writing" => "0"]),
				e_assign->new(["write_req" => "1'b0"]),
				e_assign->new(["read_req" => "1'b0"]),
				e_assign->new(["cmd_count" => "0"]),
				e_assign->new(["write_addr" => "0"]),
				e_assign->new(["read_addr" => "0"]),
				e_assign->new(["addr" => "0"]),
				e_assign->new(["cmd_issued" => "0"]),
				e_assign->new(["refresh_req" => "0"]),
				e_assign->new(["refresh_ba" => "0"]),
				e_assign->new(["trc_start" => "0"]),
		      ],
		      contents	=>	
		      [
				e_case->new   
				({
					switch	  => "state",
					parallel  => 0,
					full      => 0,
					contents  => 
					{
						$S_IDLE =>
						[
							e_if->new
							({
								condition	=> "local_init_done_r",
								then		=>
								[
									e_assign->new({lhs => "write_req", rhs => "1'b1"}),
									e_assign->new(["cmd_issued" => "1"]),
									e_assign->new(["writing" => "1"]),
									e_assign->new(["write_addr" => "write_addr + 1"]),
									e_assign->new(["writing" => "1"]),
									e_assign->new({lhs => "state", rhs => $S_WRITE}),
								],
							}),
						],
						
						$S_WRITE =>
						[
							e_if->new
							({
								condition	=> "cmd_enable",
								then		=>
								[
									e_if->new
									({
										 condition	=> "cmd_count == $NUMBER_WRITE_READ_CMDS - 1",
										 then		=>
										 [
										 	e_if->new
											({
												condition	=> "refresh_request",
												then		=>
													[
													e_assign->new(["trc_start" => "1"]),
													e_assign->new({lhs => "write_req", rhs => "0"}),
													e_assign->new({lhs => "state", rhs => $S_PRE_REFRESH}),
												],
												else =>
												[
													e_assign->new({lhs => "write_req", rhs => "0"}),
													e_assign->new(["addr" => "read_addr"]),
													e_assign->new({lhs => "cmd_count", rhs => "0"}),
													e_assign->new(["writing" => "0"]),
													e_assign->new({lhs => "state", rhs => $S_WR_RD_WAIT1}),
												],
											}),
										 ],
										 else =>
										 [
										 	e_assign->new({lhs => "cmd_issued", rhs => "1"}),
										 	e_assign->new({lhs => "write_req", rhs => "1"}),
										 	e_assign->new({lhs => "cmd_count", rhs => "cmd_count + 1"}),
											e_assign->new(["write_addr" => "write_addr + 1"]),
											e_assign->new(["addr" => "write_addr"]),
										 ],
									}),
								],
								else =>
								[
									e_assign->new({lhs => "cmd_issued", rhs => "0"}),
								 	e_assign->new({lhs => "write_req", rhs => "0"}),
								],
							}),
						],
						
						$S_WAIT =>
						[
							e_if->new
							({
								condition	=> "cmd_enable",
								then		=>
								[
									e_assign->new({lhs => "write_req", rhs => "1'b1"}),
									e_assign->new(["cmd_issued" => "1"]),
									e_assign->new(["addr" => "write_addr"]),
									e_assign->new(["writing" => "1"]),
									e_assign->new({lhs => "state", rhs => $S_WRITE}),
								],
							}),
						],
						
						$S_READ =>
						[
							e_if->new
							({
								condition	=> "cmd_enable",
								then		=>
								[
									e_if->new
									({
										 condition	=> "cmd_count == $NUMBER_WRITE_READ_CMDS - 1",
										 then		=>
										 [
										 	e_if->new
											({
												condition	=> "refresh_request",
												then		=>
												[
													e_assign->new(["trc_start" => "1"]),
													e_assign->new({lhs => "read_req", rhs => "0"}),
													e_assign->new({lhs => "state", rhs => $S_PRE_REFRESH}),
												],
												else =>
												[
													e_if->new
													({
														condition	=> "rd_wr_idle_insert",
														then		=>
														[
															e_assign->new(["writing" => "1"]),
															e_assign->new({lhs => "read_req", rhs => "0"}),
															e_assign->new({lhs => "cmd_count", rhs => "0"}),
															e_assign->new({lhs => "state", rhs => $S_RD_WR_WAIT}),
														],
														else =>
														[
															e_assign->new({lhs => "cmd_issued", rhs => "1"}),
															e_assign->new({lhs => "write_req", rhs => "1"}),
															e_assign->new({lhs => "read_req", rhs => "0"}),
															e_assign->new(["write_addr" => "write_addr + 1"]),
															e_assign->new(["addr" => "write_addr"]),
															e_assign->new({lhs => "cmd_count", rhs => "0"}),
															e_assign->new(["writing" => "1"]),
															e_assign->new({lhs => "state", rhs => $S_WRITE}),
														],
													}),
												],
											}),
										 ],
										 else =>
										 [
										 	e_assign->new({lhs => "cmd_issued", rhs => "1"}),
										 	e_assign->new({lhs => "read_req", rhs => "1"}),
										 	e_assign->new({lhs => "cmd_count", rhs => "cmd_count + 1"}),
											e_assign->new(["read_addr" => "read_addr + 1"]),
											e_assign->new(["addr" => "read_addr"]),
										 ],
									}),
								],
								else =>
								[
									e_assign->new({lhs => "cmd_issued", rhs => "0"}),
								 	e_assign->new({lhs => "read_req", rhs => "0"}),
								],
							}),
						],
						
						$S_WR_RD_WAIT1 =>
						[
							e_if->new
							({
								condition	=> "! wr_rd_idle_insert",
								then		=>
								[
									e_assign->new({lhs => "read_req", rhs => "1"}),
									e_assign->new(["cmd_issued" => "1"]),
									e_assign->new(["read_addr" => "read_addr + 1"]),
									e_assign->new({lhs => "state", rhs => $S_READ}),
								],
								else =>
								[
									e_assign->new({lhs => "state", rhs => $S_WR_RD_WAIT2}),
								],
							}),
						],
						
						$S_WR_RD_WAIT2 =>
						[
							e_assign->new({lhs => "read_req", rhs => "1"}),
							e_assign->new(["cmd_issued" => "1"]),
							e_assign->new(["read_addr" => "read_addr + 1"]),
							e_assign->new({lhs => "state", rhs => $S_READ}),
						],
						
						$S_RD_WR_WAIT =>
						[
							e_assign->new({lhs => "write_req", rhs => "1"}),
							e_assign->new(["cmd_issued" => "1"]),
							e_assign->new(["write_addr" => "write_addr + 1"]),
							e_assign->new(["addr" => "write_addr"]),
							e_assign->new(["writing" => "1"]),
							e_assign->new({lhs => "state", rhs => $S_WRITE}),
						],
						
						$S_PRE_REFRESH =>
						[
							e_assign->new(["trc_start" => "0"]),
							e_assign->new(["cmd_count" => "0"]),
							
							e_if->new
							({
								condition	=> "refresh_trc_completed",
								then		=>
								[
									e_assign->new(["refresh_req" => "1"]),
									e_assign->new(["refresh_ba" => "refresh_ba + 1"]),
									e_assign->new(["addr[2:0]" => "refresh_ba"]),
									e_assign->new(["refresh_request_clr" => "1"]),
									e_assign->new({lhs => "state", rhs => $S_REFRESH}),
								],
							}),
						],
						
						$S_REFRESH =>
						[
							e_assign->new(["refresh_request_clr" => "0"]),
							e_assign->new(["refresh_req" => "0"]),
							e_assign->new(["trc_start" => "1"]),
							e_assign->new({lhs => "state", rhs => $S_POST_REFRESH}),
						],
						
						$S_POST_REFRESH =>
						[
							e_assign->new(["trc_start" => "0"]),
													
							e_if->new
							({
								condition	=> "refresh_trc_completed",
								then		=>
								[
									e_if->new
									({
										condition	=> "writing",
										then		=>
										[
											e_assign->new(["read_req" => "1"]),
											e_assign->new(["writing" => "0"]),
											e_assign->new(["cmd_issued" => "1"]),
											e_assign->new(["read_addr" => "read_addr + 1"]),
											e_assign->new(["addr" => "read_addr"]),
											e_assign->new({lhs => "state", rhs => $S_READ}),
										],
										else =>
										[
											e_assign->new(["write_req" => "1"]),
											e_assign->new(["writing" => "1"]),
											e_assign->new(["cmd_issued" => "1"]),
											e_assign->new(["write_addr" => "write_addr + 1"]),
											e_assign->new(["addr" => "write_addr"]),
											e_assign->new({lhs => "state", rhs => $S_WRITE}),
										],
									}),
								],
							}),
						],
					},
				}),
			],
	    }),
      );
}
else
{
$module->add_contents
(
     e_process->new
     ({
	      clock			=>	"clk",
	      reset			=>	"reset_clk_n",
	      comment			=>	
	      "\n\n-----------------------------------------------------------------\n
	      Main clocked process\n
	      -----------------------------------------------------------------\n
	      SIO Read / Write control state machine\n
	      -----------------------------------------------------------------",
	      _asynchronous_contents	=>	
	      [
			e_assign->new(["refresh_request_clr" => "0"]),
			e_assign->new(["state" => "0"]),
			e_assign->new(["write_req" => "1'b0"]),
			e_assign->new(["read_req" => "1'b0"]),
			e_assign->new(["write_addr" => "0"]),
			e_assign->new(["read_addr" => "0"]),
			e_assign->new(["addr" => "0"]),
			e_assign->new(["cmd_issued" => "0"]),
			e_assign->new(["refresh_req" => "0"]),
			e_assign->new(["refresh_ba" => "0"]),
			e_assign->new(["trc_start" => "0"]),
	      ],
	      contents	=>	
	      [
			e_case->new   
			({
				switch	  => "state",
				parallel  => 0,
				full      => 0,
				contents  => 
				{
					$S_IDLE =>
					[
						e_if->new
						({
							condition	=> "local_init_done_r",
							then		=>
							[
								e_assign->new({lhs => "write_req", rhs => "1'b1"}),
								e_assign->new(["cmd_issued" => "1"]),
								e_assign->new(["trc_start" => "1"]),
								e_assign->new(["addr" => "write_addr"]),
								e_assign->new({lhs => "state", rhs => $S_WRITE}),
							],
						}),
					],
					
					$S_WRITE =>
					[
						e_assign->new(["cmd_issued" => "0"]),
						e_assign->new(["trc_start" => "0"]),
						e_assign->new(["write_addr" => "write_addr + 1"]),
						e_assign->new(["addr" => "write_addr"]),
						e_assign->new({lhs => "write_req", rhs => "1"}),
								
						e_if->new
						({
							condition	=> "initial_trc_completed",
							then		=>
							[
								e_assign->new({lhs => "write_req", rhs => "0"}),
								e_assign->new({lhs => "read_req", rhs => "1"}),
								e_assign->new(["addr" => "read_addr"]),
								e_assign->new({lhs => "state", rhs => $S_READ}),
							],
							else =>
							[
								e_assign->new({lhs => "write_req", rhs => "0"}),
								e_assign->new({lhs => "read_req", rhs => "0"}),
								e_assign->new({lhs => "state", rhs => $S_WAIT}),
							],
						}),
					],
					
					$S_WAIT =>
					[
						e_if->new
						({
							condition	=> "cmd_enable",
							then		=>
							[
								e_assign->new({lhs => "write_req", rhs => "1'b1"}),
								e_assign->new(["cmd_issued" => "1"]),
								e_assign->new(["addr" => "write_addr"]),
								e_assign->new({lhs => "state", rhs => $S_WRITE}),
							],
						}),
					],
					
					$S_READ =>
					[
						e_if->new
						({
							condition	=> "refresh_request",
							then		=>
							[
								e_assign->new(["trc_start" => "1"]),
								e_assign->new({lhs => "read_req", rhs => "0"}),
								e_assign->new(["read_addr" => "read_addr + 1"]),
								e_assign->new({lhs => "state", rhs => $S_PRE_REFRESH}),
							],
							else =>
							[
								e_if->new
								({
									condition	=> "cmd_enable",
									then		=>
									[
										e_assign->new({lhs => "write_req", rhs => "1'b1"}),
										e_assign->new({lhs => "read_req", rhs => "1'b0"}),
										e_assign->new(["cmd_issued" => "1"]),
										e_assign->new(["read_addr" => "read_addr + 1"]),
										e_assign->new(["addr" => "write_addr"]),
										e_assign->new({lhs => "state", rhs => $S_WRITE}),
									],
									else =>
									[
										e_assign->new({lhs => "read_req", rhs => "0"}),
										e_assign->new(["read_addr" => "read_addr + 1"]),
										e_assign->new({lhs => "state", rhs => $S_WAIT}),
									],
								}),
							],
						}),
					],
										
					$S_PRE_REFRESH =>
					[
						e_assign->new(["trc_start" => "0"]),
						e_assign->new(["refresh_trc_count" => "refresh_trc_count + 1"]),
						
						e_if->new
						({
							condition	=> "refresh_trc_completed",
							then		=>
							[
								e_assign->new(["refresh_req" => "1"]),
								e_assign->new(["refresh_ba" => "refresh_ba + 1"]),
								e_assign->new(["addr[2:0]" => "refresh_ba"]),
								e_assign->new(["refresh_request_clr" => "1"]),
								e_assign->new({lhs => "state", rhs => $S_REFRESH}),
							],
						}),
					],
					
					$S_REFRESH =>
					[
						e_assign->new(["refresh_request_clr" => "0"]),
						e_assign->new(["refresh_req" => "0"]),
						e_assign->new(["trc_start" => "1"]),
						e_assign->new({lhs => "state", rhs => $S_POST_REFRESH}),
					],
					
					$S_POST_REFRESH =>
					[
						e_assign->new(["trc_start" => "0"]),
												
						e_if->new
						({
							condition	=> "refresh_trc_completed",
							then		=>
							[
								e_assign->new(["write_req" => "1"]),
								e_assign->new(["cmd_issued" => "1"]),
								e_assign->new(["addr" => "write_addr"]),
								e_assign->new({lhs => "state", rhs => $S_WRITE}),
							],
						}),
					],
				},
			}),
		],
    }),
);
}


################################################################################################################################################################

	if ($CMD_SEPARATION_CYCLES == 1) {;
		$module->add_contents
		(
			e_assign->new({lhs => "cmd_enable", rhs => "cmd_issued" }),
		);
	}
	else {
		$module->add_contents
		(
			e_process->new
			({
				clock			=> "clk",
				reset			=> "reset_clk_n",
				_asynchronous_contents  =>
				[
					e_assign->new({lhs => "cmd_issued_r", rhs => "0" }),
				],
				_contents		=>
				[
					e_assign->new({lhs => "cmd_issued_r[0]", rhs => "cmd_issued" }),
					e_assign->new({lhs => "cmd_issued_r[1]", rhs => "cmd_issued_r[0]" }),
					e_assign->new({lhs => "cmd_issued_r[2]", rhs => "cmd_issued_r[1]" }),
					e_assign->new({lhs => "cmd_issued_r[3]", rhs => "cmd_issued_r[2]" }),
				],
			}),
			
			e_assign->new({lhs => "cmd_enable", rhs => "cmd_issued_r[$CMD_SEPARATION_CYCLES - 2]" }),
		);
	}
	
	  
################################################################################################################################################################

        $module->add_contents
	(
		e_process->new
		({
			clock			=> "clk",
			reset			=> "reset_clk_n",
			_asynchronous_contents  =>
			[
				e_assign->new({lhs => "trc_pipeline", rhs => "0" }),
			],
			_contents		=>
			[
				e_assign->new({lhs => "trc_pipeline[0]", rhs => "trc_start" }),
				e_assign->new({lhs => "trc_pipeline[1]", rhs => "trc_pipeline[0]" }),
				e_assign->new({lhs => "trc_pipeline[2]", rhs => "trc_pipeline[1]" }),
				e_assign->new({lhs => "trc_pipeline[3]", rhs => "trc_pipeline[2]" }),
				e_assign->new({lhs => "trc_pipeline[4]", rhs => "trc_pipeline[3]" }),
				e_assign->new({lhs => "trc_pipeline[5]", rhs => "trc_pipeline[4]" }),
			],
		}),
		
		e_assign->new({lhs => "refresh_trc_completed", rhs => "trc_pipeline[$MEM_TRC_CYCLES - 3]" }),
	);
	
################################################################################################################################################################
	if ($RLDRAMII_TYPE eq "sio") {
		$module->add_contents
		(
			e_process->new
			({
				clock			=> "clk",
				reset			=> "reset_clk_n",
				_asynchronous_contents  =>
				[
					e_assign->new({lhs => "initial_trc_completed", rhs => "0" }),
				],
				_contents		=>
				[
					e_if->new
					({
						condition	=> "trc_pipeline[$MEM_TRC_CYCLES - 3]",
						then		=>
						[
							e_assign->new({lhs => "initial_trc_completed", rhs => "1" }),
						],
					}),
				],
			}),
		);
	}

################################################################################################################################################################

        $module->add_contents
	(
		e_process->new
		({
			clock			=> "clk",
			reset			=> "reset_clk_n",
			_asynchronous_contents  =>
			[
				e_assign->new({lhs => "local_refresh_req", rhs => "0" }),
				e_assign->new({lhs => "local_write_req", rhs => "0" }),
				e_assign->new({lhs => "local_read_req", rhs => "0" }),
				e_assign->new({lhs => "local_addr", rhs => "0" }),
				e_assign->new({lhs => "local_bank_addr", rhs => "0" }),
			],
			_contents		=>
			[
				e_assign->new({lhs => "local_refresh_req", rhs => "refresh_req" }),
				e_assign->new({lhs => "local_write_req", rhs => "write_req" }),
				e_assign->new({lhs => "local_read_req", rhs => "read_req" }),
				e_assign->new({lhs => "local_addr", rhs => "addr[$MEM_ADDR_BITS + 2:3]" }),
				e_assign->new({lhs => "local_bank_addr", rhs => "addr[2:0]" }),
			],
		}),
	);

#################################################################################################################################################################

if ($ENABLE_CAPTURE_CLK eq "false") {
	$RVALID_COMPARE = $NUM_DQ_PER_DEVICE;
	
	for ($m = 0; $m <= $MEM_NUM_DEVICES - 1; $m++ ) {
		 # $module->add_contents
		 # (
			 # e_comment->new({comment => "Register local_rdata_valid"}),
			 # e_process->new
			 # ({
				# clock			=> "capture_clk[$m]",
				# reset			=> "reset_read_clk_n",
				# _asynchronous_contents  =>
				# [
					# e_assign->new({lhs => "local_rdata_valid_r[".$m."]", rhs => 0 }),
					# e_assign->new({lhs => "local_rdata_valid_r1[".$m."]", rhs => 0 }),
				# ],
				# _contents		=>
				# [
					# e_assign->new({lhs => "local_rdata_valid_r[".$m."]", rhs => "local_rdata_valid[".$m."]" }),
					# e_assign->new({lhs => "local_rdata_valid_r1[".$m."]", rhs => "local_rdata_valid_r[".$m."]" }),
				# ],
			 # }),
		# );
	}
	
    for ($i = 0; $i <= ($LOCAL_DATA_BITS / $MEM_DQ_PER_DQS) / 2 - 1; $i++ ) {	
        
        $module->add_contents
		(
			e_assign->new({lhs => "local_rdata_".$i."", rhs => "{local_rdata["."($MEM_DQ_PER_DQS * ($i + $NUMBER_DQS + 1)) - 1".":"."$MEM_DQ_PER_DQS * ($i + $NUMBER_DQS)"."], local_rdata["."($MEM_DQ_PER_DQS * ($i + 1)) - 1".":"."$MEM_DQ_PER_DQS * $i"."]}" }),
		);
        
        $module->add_contents
		(
			e_comment->new({comment => "Instantiate Read FIFO"}),
            e_blind_instance->new
			 ({
				 name 		=> "RD_FIFO_".$i."_inst",
				 module 	=> "dcfifo",            
				 comment 	=> "---------------------------------------------------------------------\n
				 Read Example LFSR Module Instantiation\n
				 ---------------------------------------------------------------------\n",
				 in_port_map 	=>
				 {
				   "wrclk"     => "capture_clk[$l]",
				   "rdreq"     => "rd_en[$i]",
				   "aclr"      => "reset_clk[$i]",
				   "rdclk"     => "clk",
				   "wrreq"     => "local_rdata_valid[".$l."]",
				   #"data"      => "{local_rdata["."($MEM_DQ_PER_DQS * ($i + $NUMBER_DQS + 1)) - 1".":"."$MEM_DQ_PER_DQS * ($i + $NUMBER_DQS)"."], local_rdata["."($MEM_DQ_PER_DQS * ($i + 1)) - 1".":"."$MEM_DQ_PER_DQS * $i"."]}",
                   "data"      => "local_rdata_".$i."[($MEM_DQ_PER_DQS * 2) -1 : 0]",
				 },
 
				 out_port_map	=>
				 {
				    "rdempty"   => "data_in_fifo[".$i."]",
				    "q"      => "fifo_rdata_".$i."[($MEM_DQ_PER_DQS * 2) -1 : 0]",
				 },
			 
				 parameter_map 	=>
				 {
					 intended_device_family     => '"'."Stratix II".'"',
                     lpm_hint                   => '"'."MAXIMIZE_SPEED=7".'"',
                     lpm_numwords               => "256",
                     lpm_showahead              => '"'."OFF".'"',
                     lpm_type                   => '"'."dcfifo".'"',
                     lpm_width                  => "$FIFO_WIDTH",
                     lpm_widthu                 => "8",
                     overflow_checking          => '"'."OFF".'"',
                     rdsync_delaypipe           => "5",
                     underflow_checking         => '"'."OFF".'"',
                     use_eab                    => '"'."ON".'"',
                     wrsync_delaypipe           => "5",
				 },
			 }),
            
            e_process->new
            ({
                clock			=> "clk",
                reset			=> "reset_clk_n",
                _asynchronous_contents  =>
                [
                    e_assign->new({lhs => "fifo_rdata_".$i."_r1[($MEM_DQ_PER_DQS * 2) - 1: 0]", rhs => "0" }),
                ],
                _contents		=>
                [
                    e_assign->new({lhs => "fifo_rdata_".$i."_r1[($MEM_DQ_PER_DQS * 2) - 1: 0]", rhs => "fifo_rdata_".$i."[($MEM_DQ_PER_DQS * 2) - 1: 0]" }),
                ],
            }),
            
            
			  e_comment->new({comment => "Instantiate Read Example_LFSR Module"}),
			  e_blind_instance->new
			  ({
				  name 		=> "RD_LFSRGEN_".$i."_lfsr_inst",
				  module 	=> "example_lfsr",            
				  comment 	=> "---------------------------------------------------------------------\n
				  Read Example LFSR Module Instantiation\n
				  ---------------------------------------------------------------------\n",
				  in_port_map 	=>
				  {
					  "clk"     	=> "clk",
					  "reset_n" 	=> "reset_clk_n",
					  "enable"  	=> "rd_dgen_enable",
					  "pause"   	=> "data_in_fifo_r[".$i."]",
					  "load"    	=> "rd_dgen_load",
				  },
  
				  out_port_map	=>
				  {
					  "data" 	=> "rd_dgen_data["."(($i + 1) * $MEM_DQ_PER_DQS) - 1".":"."$i * $MEM_DQ_PER_DQS"."]",
				  },
			  
				  parameter_map 	=>
				  {
					  "seed" 	=> (10 * $i) + 1,
					  gMEM_DQ_PER_DQS  => $MEM_DQ_PER_DQS,
				  },
			  }),
              
                           
              e_comment->new({comment => "Instantiate Read Example_LFSR Module"}),
			  e_blind_instance->new
			  ({
				  name 		=> "RD_LFSRGEN_".($i + $NUMBER_DQS)."_lfsr_inst",
				  module 	=> "example_lfsr",            
				  comment 	=> "---------------------------------------------------------------------\n
				  Read Example LFSR Module Instantiation\n
				  ---------------------------------------------------------------------\n",
				  in_port_map 	=>
				  {
					  "clk"     	=> "clk",
					  "reset_n" 	=> "reset_clk_n",
					  "enable"  	=> "rd_dgen_enable",
					  "pause"   	=> "data_in_fifo_r[".$i."]",
					  "load"    	=> "rd_dgen_load",
				  },
  
				  out_port_map	=>
				  {
					  "data" 	=> "rd_dgen_data["."(($i + $NUMBER_DQS + 1) * $MEM_DQ_PER_DQS) - 1".":"."$MEM_DQ_PER_DQS * ($i + $NUMBER_DQS)"."]",
				  },
			  
				  parameter_map 	=>
				  {
					  "seed" 	=> (10 * ($i + $NUMBER_DQS)) + 1,
					  gMEM_DQ_PER_DQS  => $MEM_DQ_PER_DQS,
				  },
			  }),

			 #e_assign->new(["rd_compare["."$i"."]" => "rd_dgen_data["."($MEM_DQ_PER_DQS * ($i + 1)) - 1".":"."$MEM_DQ_PER_DQS * $i"."] == rdata_r1["."($MEM_DQ_PER_DQS * ($i + 1)) - 1".":"."$MEM_DQ_PER_DQS * $i"."]"]),
             #e_assign->new(["rd_compare["."($i + $NUMBER_DQS)"."]" => "rd_dgen_data["."($MEM_DQ_PER_DQS * ($i + $NUMBER_DQS + 1)) - 1".":"."$MEM_DQ_PER_DQS * ($i + $NUMBER_DQS)"."] == rdata_r1["."($MEM_DQ_PER_DQS * ($i + $NUMBER_DQS + 1)) - 1".":"."$MEM_DQ_PER_DQS * ($i + $NUMBER_DQS)"."]"]),
                                                                                                    
             e_assign->new(["rd_compare["."$i"."]" => "rd_dgen_data["."($MEM_DQ_PER_DQS * ($i + 1)) - 1".":"."$MEM_DQ_PER_DQS * $i"."] == fifo_rdata_".$i."_r1[$MEM_DQ_PER_DQS - 1 : 0]"]),
             e_assign->new(["rd_compare["."($i + $NUMBER_DQS)"."]" => "rd_dgen_data["."($MEM_DQ_PER_DQS * ($i + $NUMBER_DQS + 1)) - 1".":"."$MEM_DQ_PER_DQS * ($i + $NUMBER_DQS)"."] == fifo_rdata_".$i."_r1[($MEM_DQ_PER_DQS * 2) - 1 : $MEM_DQ_PER_DQS]"]),
             
       
             
			 
			 e_comment->new({comment => "\nGenerate pnf_pef_byte($i)"}),
			 e_process->new
			 ({
				clock			=> "clk",
				reset			=> "reset_clk_n",
				_asynchronous_contents  =>
				[
					e_assign->new({lhs => "pnf_per_byte_int["."$i"."]", rhs => 0 }),
                    e_assign->new({lhs => "pnf_per_byte_int["."($i + $NUMBER_DQS)"."]", rhs => 0 }),
				],
				_contents		=>
				[
					e_if->new
					({
						condition	=> "! data_in_fifo_r1[".$i."]",
						then		=>
						[
							e_assign->new({lhs => "pnf_per_byte_int["."$i"."]", rhs => "rd_compare["."$i"."]" }),
                            e_assign->new({lhs => "pnf_per_byte_int["."($i + $NUMBER_DQS)"."]", rhs => "rd_compare["."($i + $NUMBER_DQS)"."]" }),
						],
						else		=>
						[
							e_assign->new({lhs => "pnf_per_byte_int["."$i"."]", rhs => "0" }),
                            e_assign->new({lhs => "pnf_per_byte_int["."($i + $NUMBER_DQS)"."]", rhs => "0" }),
						],
					}),
				],
			}),
		 );
		 
		 if ($i == $RVALID_COMPARE - 1) {
			 $RVALID_COMPARE = $RVALID_COMPARE + $NUM_DQ_PER_DEVICE;
			 
			 if ($l == $MEM_NUM_DEVICES - 1) {
				 $l = 0;
			 }
			 else
			 {
				 $l = $l + 1;
			 }
			 
		 }
		 
		 if ($j >= $NUMBER_DQS - 1) { 
			 $j = 0;
		 }
		 else
		 {
			 $j = $j + 1;
		 }
		 
	}
}
else
{
	
	$j = 0;
	$l = 0;
	$RVALID_COMPARE = $NUM_DQ_PER_DEVICE;
	for ($i = 0; $i <= $LOCAL_DATA_BITS / $MEM_DQ_PER_DQS - 1; $i++ ) {	 
		$module->add_contents
		(
        
        e_comment->new({comment => "Instantiate Read FIFO"}),
            e_blind_instance->new
			 ({
				 name 		=> "RD_FIFO_".$i."_inst",
				 module 	=> "dcfifo",            
				 comment 	=> "---------------------------------------------------------------------\n
				 Read Example LFSR Module Instantiation\n
				 ---------------------------------------------------------------------\n",
				 in_port_map 	=>
				 {
                    "wrclk"     => "capture_clk",
                    "rdreq"     => "rd_en[$i]",
				    "aclr"      => "reset_clk",
				    "rdclk"     => "clk",
				    "wrreq"     => "local_rdata_valid[".$l."]",
				    "data"      => "local_rdata["."($MEM_DQ_PER_DQS * ($i + 1)) - 1".":"."$MEM_DQ_PER_DQS * $i"."]",
                 },
 
				 out_port_map	=>
				 {
				    "rdempty"   => "data_in_fifo[".$i."]",
				    "q"         => "rdata["."($MEM_DQ_PER_DQS * ($i + 1)) - 1".":"."$MEM_DQ_PER_DQS * $i"."]",
				 },
			 
				 parameter_map 	=>
				 {
					 intended_device_family     => '"'."Stratix II".'"',
                     lpm_hint                   => '"'."MAXIMIZE_SPEED=7".'"',
                     lpm_numwords               => "256",
                     lpm_showahead              => '"'."OFF".'"',
                     lpm_type                   => '"'."dcfifo".'"',
                     lpm_width                  => "$MEM_DQ_PER_DQS",
                     lpm_widthu                 => "8",
                     overflow_checking          => '"'."OFF".'"',
                     rdsync_delaypipe           => "5",
                     underflow_checking         => '"'."OFF".'"',
                     use_eab                    => '"'."ON".'"',
                     wrsync_delaypipe           => "5",
				 },
			 }),
             
             
			 e_comment->new({comment => "Instantiate Read Example_LFSR Module"}),
			 e_blind_instance->new
			 ({
				 name 		=> "RD_LFSRGEN_".$i."_lfsr_inst",
				 module 	=> "example_lfsr",            
				 comment 	=> "---------------------------------------------------------------------\n
				 Read Example LFSR Module Instantiation\n
				 ---------------------------------------------------------------------\n",
				 in_port_map 	=>
				 {
					 "clk"     	=> "clk",
					 #"clk"     	=> "capture_clk",
					 "reset_n" 	=> "reset_clk_n",
					 "enable"  	=> "rd_dgen_enable",
					 "pause"   	=> "data_in_fifo_r[".$i."]",
					 "load"    	=> "rd_dgen_load",
				 },
 
				 out_port_map	=>
				 {
					 "data" 	=> "rd_dgen_data["."(($i + 1) * $MEM_DQ_PER_DQS) - 1".":"."$i * $MEM_DQ_PER_DQS"."]",
				 },
			 
				 parameter_map 	=>
				 {
					 "seed" 	=> (10 * $i) + 1,
					 "gMEM_DQ_PER_DQS"  => $MEM_DQ_PER_DQS,
				 },
			 }),
			 
			 e_assign->new(["rd_compare["."$i"."]" => "rd_dgen_data["."($MEM_DQ_PER_DQS * ($i + 1)) - 1".":"."$MEM_DQ_PER_DQS * $i"."] == rdata_r1["."($MEM_DQ_PER_DQS * ($i + 1)) - 1".":"."$MEM_DQ_PER_DQS * $i"."]"]),
			 
			 e_comment->new({comment => "\nGenerate pnf_pef_byte($i)"}),
			 e_process->new
			 ({
				clock			=> "clk",
				reset			=> "reset_clk_n",
				_asynchronous_contents  =>
				[
					e_assign->new({lhs => "pnf_per_byte_int["."$i"."]", rhs => 0 }),
				],
				_contents		=>
				[
					e_if->new
					({
						condition	=> "! data_in_fifo_r1[".$i."]",
						then		=>
						[
							e_assign->new({lhs => "pnf_per_byte_int["."$i"."]", rhs => "rd_compare["."$i"."]" }),
						],
						else		=>
						[
							e_assign->new({lhs => "pnf_per_byte_int["."$i"."]", rhs => "0" }),
						],
					}),
				],
			}),
		 );
		 
		 if ($i == $RVALID_COMPARE - 1) {
			 $RVALID_COMPARE = $RVALID_COMPARE + $NUM_DQ_PER_DEVICE;
			 
			 if ($l == $MEM_NUM_DEVICES - 1) {
				 $l = 0;
			 }
			 else
			 {
				 $l = $l + 1;
			 }
		 }
		 
		 if ($j >= $NUMBER_DQS - 1) { 
			 $j = 0;
		 }
		 else
		 {
			 $j = $j + 1;
		 }
		 
	}
}


################################################################################################################################################################

    $module->add_contents
	(
		e_process->new
		({
			clock			=> "clk",
			reset			=> "reset_clk_n",
			_asynchronous_contents  =>
			[
				e_assign->new({lhs => "data_in_fifo_r", rhs => "{".$LOCAL_DATA_BITS / $MEM_DQ_PER_DQS."{1'b1}}" }),
				e_assign->new({lhs => "data_in_fifo_r1", rhs => "{".$LOCAL_DATA_BITS / $MEM_DQ_PER_DQS."{1'b1}}" }),
                e_assign->new({lhs => "data_in_fifo_r2", rhs => "{".$LOCAL_DATA_BITS / $MEM_DQ_PER_DQS."{1'b1}}" }),
				#e_assign->new({lhs => "rdata_r1", rhs => "1" }),
			],
			_contents		=>
			[
				e_assign->new({lhs => "data_in_fifo_r", rhs => "data_in_fifo" }),
				e_assign->new({lhs => "data_in_fifo_r1", rhs => "data_in_fifo_r" }),
                e_assign->new({lhs => "data_in_fifo_r2", rhs => "data_in_fifo_r1" }),
				#e_assign->new({lhs => "rdata_r1", rhs => "rdata" }),
			],
		}),
	);


################################################################################################################################################################
if ($ENABLE_CAPTURE_CLK eq "true") {
    $module->add_contents
	(
		e_process->new
		({
			clock			=> "clk",
			reset			=> "reset_clk_n",
			_asynchronous_contents  =>
			[
				#e_assign->new({lhs => "data_in_fifo_r", rhs => "{".$LOCAL_DATA_BITS / $MEM_DQ_PER_DQS."{1'b1}}" }),
				#e_assign->new({lhs => "data_in_fifo_r1", rhs => "{".$LOCAL_DATA_BITS / $MEM_DQ_PER_DQS."{1'b1}}" }),
				e_assign->new({lhs => "rdata_r1", rhs => "1" }),
			],
			_contents		=>
			[
				#e_assign->new({lhs => "data_in_fifo_r", rhs => "data_in_fifo" }),
				#e_assign->new({lhs => "data_in_fifo_r1", rhs => "data_in_fifo_r" }),
				e_assign->new({lhs => "rdata_r1", rhs => "rdata" }),
			],
		}),
	);
}

#################################################################################################################################################################

for ($i = 0; $i <= ($LOCAL_DATA_BITS / $MEM_DQ_PER_DQS / 2) - 1 ; $i++ ) {
    $module->add_contents
    (
    	 e_comment->new({comment => "\nRead Data Valid Persist Flag"}),
    	 e_process->new
    	 ({
    		clock			=> "clk",
    		reset			=> "reset_clk_n",
    		_asynchronous_contents  =>
    		[
    			e_assign->new({lhs => "rdata_valid_persist[$i]", rhs => 0 }),
                e_assign->new({lhs => "rdata_valid_persist_r[$i]", rhs => 0 }),
    		],
    		_contents		=>
    		[
    			e_if->new
    			({
    				condition	=> "!data_in_fifo_r1[$i]",
    				then		=>
    				[
    					e_assign->new({lhs => "rdata_valid_persist[$i]", rhs => 1 }),
                        e_assign->new({lhs => "rdata_valid_persist_r[$i]", rhs => "rdata_valid_persist[$i]" }),
    				],
    			}),
    		],
    	}),
    );
}

#################################################################################################################################################################

if ($ENABLE_CAPTURE_CLK eq "false") {
	$j = 0;
	$NEXT_DQS = $NUM_DQ_PER_DEVICE;
	
	for ($i = 0; $i <= ($LOCAL_DATA_BITS / $MEM_DQ_PER_DQS / 2) - 1 ; $i++ ) {
		$module->add_contents
		(
			 e_comment->new({comment => "\nPnF_Persist Flag"}),
			 e_process->new
			 ({
				clock			=> "clk",
				reset			=> "reset_clk_n",
				_asynchronous_contents  =>
				[
					e_assign->new({lhs => "pnf_persist_int[$i]", rhs => 0 }),
				],
				_contents		=>
				[
					e_if->new
					({
                        condition	=> "rdata_valid_persist && !data_in_fifo_r2[0]",
						then		=>
						[
							e_if->new
			                ({
			                	condition	=> "(pnf_per_byte_int[$i] & pnf_per_byte_int[$i + ($MEM_NUM_DEVICES * $NUM_DQ_PER_DEVICE)]) && !rdata_valid_persist_r[$i]",
			                	then		=>
			                	[
						        	e_assign->new({lhs => "pnf_persist_int[$i]", rhs => "1" }),
						        ],
                                elsif     =>
                                {
                                    condition	=> "(pnf_per_byte_int[$i] & pnf_per_byte_int[$i + ($MEM_NUM_DEVICES * $NUM_DQ_PER_DEVICE)]) && pnf_persist_int[$i]",
						            then		=>
						            [
						            	e_assign->new({lhs => "pnf_persist_int[$i]", rhs => "1" }),
						            ],
                                else        =>
                                [
						        	e_assign->new({lhs => "pnf_persist_int[$i]", rhs => "0" }),
						        ],
                                }
			                }),
						],
					}),
				],
			}),
		);
		
		if ($i == $NEXT_DQS - 1) {
			$NEXT_DQS = $NEXT_DQS + $NUM_DQ_PER_DEVICE;
			$j = $j + 1;
		}
	}
}
else
{
	for ($i = 0; $i <= ($LOCAL_DATA_BITS / $MEM_DQ_PER_DQS / 2) - 1 ; $i++ ) {
		$module->add_contents
		(
			 e_comment->new({comment => "\nPnF_Persist Flag"}),
			 e_process->new
			 ({
				clock			=> "clk",
				reset			=> "reset_clk_n",
				_asynchronous_contents  =>
				[
					e_assign->new({lhs => "pnf_persist_int[$i]", rhs => 0 }),
				],
				_contents		=>
				[
					e_if->new
					({
                        condition	=> "rdata_valid_persist && !data_in_fifo_r2[0]",
						then		=>
						[
							e_if->new
			                ({
			                	condition	=> "(pnf_per_byte_int[$i] & pnf_per_byte_int[$i + ($MEM_NUM_DEVICES * $NUM_DQ_PER_DEVICE)]) && !rdata_valid_persist_r[$i]",
			                	then		=>
			                	[
						        	e_assign->new({lhs => "pnf_persist_int[$i]", rhs => "1" }),
						        ],
                                elsif     =>
                                {
                                    condition	=> "(pnf_per_byte_int[$i] & pnf_per_byte_int[$i + ($MEM_NUM_DEVICES * $NUM_DQ_PER_DEVICE)]) && pnf_persist_int[$i]",
						            then		=>
						            [
						            	e_assign->new({lhs => "pnf_persist_int[$i]", rhs => "1" }),
						            ],
                                else        =>
                                [
						        	e_assign->new({lhs => "pnf_persist_int[$i]", rhs => "0" }),
						        ],
                                }
			                }),
						],
					}),
				],
			}),
		);
	}	
}

#################################################################################################################################################################
$module->add_contents
(
	e_assign->new({lhs => "pnf_persist_int_and[0]", rhs => "pnf_persist_int[0]" }),
);

for ($i = 1; $i <= ($LOCAL_DATA_BITS / $MEM_DQ_PER_DQS / 2) - 1 ; $i++ ) {
	$module->add_contents
	(
		e_assign->new({lhs => "pnf_persist_int_and[$i]", rhs => "pnf_persist_int_and[$i - 1] & pnf_persist_int[$i]" }),
	);
	
	$p = $i;
}

$module->add_contents
(
	e_assign->new({lhs => "pnf_persist", rhs => "pnf_persist_int_and[$p]" }),
),

#################################################################################################################################################################
# $module->add_contents
# (
	# e_assign->new({lhs => "pnf_per_byte_int_and[0]", rhs => "pnf_per_byte_int[0] & pnf_per_byte_int[1]" }),
# );
# 
# for ($i = 1; $i <= $LOCAL_DATA_BITS / $MEM_DQ_PER_DQS - 2; $i++ ) {	 
	# $module->add_contents
	# (
		 # e_assign->new({lhs => "pnf_per_byte_int_and[$i]", rhs => "pnf_per_byte_int_and[$i - 1] & pnf_per_byte_int[$i + 1]" }),
	# ),
# }
################################################################################################################################################################
# if ($ENABLE_CAPTURE_CLK eq "false") {
	# $module->add_contents
	# (
		 # e_comment->new({comment => "\nPnF_Persist Flag"}),
		 # e_process->new
		 # ({
			# clock			=> "capture_clk[0]",
			# reset			=> "reset_read_clk_n",
			# _asynchronous_contents  =>
			# [
				# e_assign->new({lhs => "pnf_persist", rhs => 1 }),
			# ],
			# _contents		=>
			# [
				# e_if->new
				# ({
					# condition	=> "! pnf_per_byte_int_and[$LOCAL_DATA_BITS / $MEM_DQ_PER_DQS - 2]",
					# then		=>
					# [
						# e_assign->new({lhs => "pnf_persist", rhs => "0" }),
					# ],
				# }),
			# ],
		# }),
	# ),	
# }
# else
# {
	# $module->add_contents
	# (
		 # e_comment->new({comment => "\nPnF_Persist Flag"}),
		 # e_process->new
		 # ({
			# clock			=> "capture_clk",
			# reset			=> "reset_read_clk_n",
			# _asynchronous_contents  =>
			# [
				# e_assign->new({lhs => "pnf_persist", rhs => 1 }),
			# ],
			# _contents		=>
			# [
				# e_if->new
				# ({
					# condition	=> "! pnf_per_byte_int_and[$LOCAL_DATA_BITS / $MEM_DQ_PER_DQS - 2]",
					# then		=>
					# [
						# e_assign->new({lhs => "pnf_persist", rhs => "0" }),
					# ],
				# }),
			# ],
		# }),
	# ),	
# }

################################################################################################################################################################

$module->add_contents
(
	 e_comment->new({comment => "\nTest Complete Flag"}),
	 e_process->new
	 ({
		clock			=> "clk",
		reset			=> "reset_clk_n",
		_asynchronous_contents  =>
		[
			e_assign->new({lhs => "test_complete", rhs => 0 }),
		],
		_contents		=>
		[
			e_if->new
			({
				condition	=> "addr[$ADDR_SHIFT_BITS + 7]",
				then		=>
				[
					e_assign->new({lhs => "test_complete", rhs => "1" }),
				],
			}),
		],
	}),
),	 

$project->output();
}

1;
