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
#  File         : $RCSfile: auk_rldramii_controller_ipfs_wrapper.pm,v $
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


sub auk_rldramii_controller_ipfs_wrapper
{
my $top = e_module->new({name => $gWRAPPER_NAME."_auk_rldramii_controller_ipfs_wrapper"});
my $project = e_project->new({top => $top, language => $language,__system_directory =>$output_directory,timescale => "1ps / 1ps"});
my $module = $project->top();



my $header_title = "Altera RLDRAM II Controller";
my $project_title = "RLDRAM II Controller";
my $header_filename = "auk_rldramii_controller_ipfs_wrapper" . $file_ext;
my $header_revision = "V" . $gWIZARD_VERSION;
my $header_abstract = "This file contains the instantiation of the Avalon controllers for the RLDRAM II Controller";

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
my $enable_addr_cmd_clk = $gENABLE_ADDR_CMD_CLK;
my $NUM_PIPELINE_ADDR_CMD_STAGES = $gNUM_PIPELINE_ADDR_CMD_STAGES;
my $ENABLE_CAPTURE_CLK = $gENABLE_CAPTURE_CLK;
my $insert_addr_cmd_negedge_reg = $gINSERT_ADDR_CMD_NEGEDGE_REG;
my $addr_cmd_clk = $gADDR_CMD_CLK;

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

my $ADDR_INCR = ($LOCAL_DATA_BITS / $MEM_DQ_PER_DQS) * $LOCAL_BURST_LEN;
my $MEMORY_BURST_LEN = $LOCAL_BURST_LEN * 2;

#### Calculate the number of dqs pins used and the memory interface width ####
if ($LOCAL_DATA_MODE eq "narrow") {
    $NUMBER_DQS = $LOCAL_DATA_BITS / $MEM_DQ_PER_DQS / 2;
    $MEMORY_DATA_WIDTH = $LOCAL_DATA_BITS / 2;
} else {
    $NUMBER_DQS = $LOCAL_DATA_BITS / $LOCAL_BURST_LEN / $MEM_DQ_PER_DQS / 2;
    $MEMORY_DATA_WIDTH = $LOCAL_DATA_BITS / $MEMORY_BURST_LEN / 2;	
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
		 Address and Command Clock          : $addr_cmd_clk\n
		 ----------------------------------------------------------------------------------\n",
	);
######################################################################################################################################################################
	$module->add_contents
	(
	#####	Ports Avalon Write Declaration	######
		e_port->new({name => "local_write_req",direction => "input" }),
		e_port->new({name => "local_read_req",direction => "input"}), # ($mem_dq_per_dqs * 2)
		e_port->new({name => "local_addr",direction => "input" ,width => $MEM_ADDR_BITS}),
		e_port->new({name => "local_bank_addr",direction => "input" , width => 3}),
		e_port->new({name => "local_wdata",direction => "input", width => $LOCAL_DATA_BITS}),
		e_port->new({name => "local_dm",direction => "input", width => $MEM_NUM_DEVICES * 2}),
		e_port->new({name => "local_refresh_req",direction => "input"}),
		e_port->new({name => "control_qvld",direction => "input" ,width => $MEM_NUM_DEVICES}), # ($mem_dq_per_dqs * 2)
		e_port->new({name => "control_rdata",direction => "input" ,width => $MEMORY_DATA_WIDTH * 2}),
		e_port->new({name => "mem_odt_en",direction => "input"}),
		e_port->new({name => "mem_impedance_matching_en",direction => "input"}),
		e_port->new({name => "mem_dll_en",direction => "input"}),
		e_port->new({name => "mem_tinit_burst_len",direction => "input", width => 2}),
		e_port->new({name => "mem_configuration",direction => "input", width => 3}),
		e_port->new({name => "mem_tinit_time",direction => "input", width => 16}),
		
		e_port->new({name => "local_wdata_req",direction => "output"}),
		e_port->new({name => "local_rdata_valid",direction => "output",width => $MEM_NUM_DEVICES}),
		e_port->new({name => "local_rdata",direction => "output",width => $LOCAL_DATA_BITS}),
		e_port->new({name => "local_init_done",direction => "output"}),
		e_port->new({name => "control_doing_wr",direction => "output"}),		
		e_port->new({name => "control_wdata_valid",direction => "output"}),
		e_port->new({name => "control_wdata",direction => "output", width => $MEMORY_DATA_WIDTH * 2}),
		e_port->new({name => "control_cs_n",direction => "output"}),
		e_port->new({name => "control_we_n",direction => "output"}),
		e_port->new({name => "control_ref_n",direction => "output"}),
		e_port->new({name => "control_a",direction => "output",width => $MEM_ADDR_BITS}),
		e_port->new({name => "control_ba",direction => "output",width => 3}),
		e_port->new({name => "control_dm",direction => "output",width => $MEM_NUM_DEVICES * 2}),		
		e_port->new({name => "clk",direction => "input"}),
		e_port->new({name => "reset_clk_n",direction => "input"}),
	);
	$module->add_contents
	(
		e_comment->new({comment => "Instantiate RLDRAM II Controller"}),
		e_blind_instance->new
		({
			name 		=> "rldramii_control",            
			module 		=> "auk_rldramii_controller",
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
				local_ba => "local_bank_addr",
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
			
			parameter_map 	=>
			{
				gMEM_ADDR_BITS		=> $MEM_ADDR_BITS,
				gMEM_DQ_PER_DQS		=> $MEM_DQ_PER_DQS,
				gMEM_NUM_DEVICES	=> $MEM_NUM_DEVICES,
				gMEM_TRC_CYCLES		=> $MEM_TRC_CYCLES,
				gMEM_TWL_CYCLES		=> $MEM_TWL_CYCLES,
				
				gLOCAL_DATA_BITS	=> $LOCAL_DATA_BITS,
				gLOCAL_DATA_MODE	=> '"'.$LOCAL_DATA_MODE.'"',
				gLOCAL_BURST_LEN	=> $LOCAL_BURST_LEN,
				gCONTROL_DATA_BITS	=> $MEMORY_DATA_WIDTH * 2,
				
				gADDR_CMD_CLK           => '"'.$addr_cmd_clk.'"',
				gADDR_CMD_NEGEDGE	=> '"'.$addr_cmd_negedge.'"',
				gENABLE_ADDR_CMD_CLK	=> '"'.$enable_addr_cmd_clk.'"',
				gINSERT_ADDR_CMD_NEGEDGE_REG => '"'.$insert_addr_cmd_negedge_reg.'"',
				gNUM_PIPELINE_ADDR_CMD_STAGES => $NUM_PIPELINE_ADDR_CMD_STAGES,
				gNUM_PIPELINE_WDATA_STAGES => $NUM_PIPELINE_WDATA_STAGES,
				gRLDRAMII_TYPE		=> '"'.$RLDRAMII_TYPE.'"',
				gREFRESH_COMMAND	=> '"'.$REFRESH_COMMAND.'"',
			},
			
			std_logic_vector_signals	=>
			[
				control_qvld, local_rdata_valid,
			]
		}),
	);
##################################################################################################################################################################
$project->output();
}

1;
#You're done.
