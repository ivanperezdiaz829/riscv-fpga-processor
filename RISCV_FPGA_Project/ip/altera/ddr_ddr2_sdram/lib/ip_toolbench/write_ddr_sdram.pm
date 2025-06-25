use europa_all;
use europa_utils;
use e_auk_ddr_ctrl;


sub write_auk_ddr_sdram
{
my $top = e_module->new({name => $gWRAPPER_NAME . "_auk_ddr_sdram"});#,output_file => "/temp_gen/".$gWRAPPER_NAME."_auk_ddr_sdram"});
my $project = e_project->new({top => $top, language => $language,__system_directory =>$output_directory, timescale => "1ps / 1ps"});
#add contents to top,
my $header_revision = "V" . $gWIZARD_VERSION;
my $module = $project->top();
my %stratix_param;#  = ("gSTRATIXII_DQS_PHASE","open","gSTRATIXII_DLL_DELAY_BUFFER_MODE","open","gSTRATIXII_DQS_OUT_MODE","open");
my @stratix_param;
#my $gMEM_PCH_BIT = 10;
my %parameters;
my @parameters;
my %Stratix_Fam = ("dqs_delay_ctrl" => "open");
my%stratix_dll_control = ("stratix_dll_control" => "open");
my @stratix_dll_control;
# $module->vhdl_libraries()->{auk_ddr_lib} = "auk_ddr_functions.all";
$module->vhdl_libraries()->{work} = "auk_ddr_functions.all";
#28-01-05
my %fedback_resynch_clk;# = ("" => "");
my @fedback_resynch_clk;
my %fedback_clk_out;
my @fedback_clk_out;
my %resynch_edge_select;
my @resynch_edge_select;
#28-01-05
my $testbench_use_vector = $gTESTBENCH_USE_VECTOR;
my $std_logic_Value;
my $std_logic_bracket;
my $use_vlog_rtl_param ;
my %dqsupdate;
my @dqsupdate;
my @dqsupdate_list;
if ($testbench_use_vector eq "true") {
    $std_logic_Value = 1;
    $std_logic_bracket = "[0:0]";
    $use_vlog_rtl_param = "_use_vlog_rtl_param"
}else{
    $std_logic_Value = 0;
    $use_vlog_rtl_param = "use_sim_models"
}
if (((($gFAMILY eq "Stratix" or $gFAMILY eq "Stratix II") and $gENABLE_CAPTURE_CLK ne "true") or $gREGTEST_ADD_DLL_PORTS == 1) or ($testbench_use_vector eq "true"))
{
    $module->add_contents
    (
        e_port->new({comment =>"Stratix only",name => "dqs_delay_ctrl",direction => "input",width =>6}),# $stratix_verilog_ports1 & $stratix_verilog_ports2 in the generator
#       e_parameter->add({name => "gDLL_INPUT_FREQUENCY",       default => $gCLOCK_PERIOD_IN_PS."ps", vhdl_type => "string"}),
    );
    %Stratix_Fam = ("dqs_delay_ctrl" => "dqs_delay_ctrl");
}
if (($gFAMILY eq "Stratix II") and ($gENABLE_CAPTURE_CLK ne "true")) {
    if (($gBUFFER_DLL_DELAY_OUTPUT ne "true") and ($gDLL_REF_CLOCK__SWITCHED_OFF_DURING_READS ne "true"))
    {
	$dqsupdate{'dqsupdate'} = "dqsupdate";
	$module->add_contents(e_port->new({name=>"dqsupdate",direction=>"input",width=>1}),);
    }
}
    my @Stratix_Fam = %Stratix_Fam;
if (($gFAMILY eq "Stratix II"))#  and ($gENABLE_CAPTURE_CLK ne "true"))
{
    # Stratix II only
    $module->add_contents
    (
        e_parameter->add({name => "gSTRATIXII_DQS_PHASE",        default =>$gSTRATIXII_DQS_PHASE_SHIFT  , vhdl_type => "natural"    ,comment   =>  " 9000/100 '90 degrees',  7200/100 '72 degrees'"}),
        e_parameter->add({name => "gSTRATIXII_DLL_DELAY_BUFFER_MODE", default =>"$gSTRATIXII_DLL_DELAY_BUFFER_MODE" , vhdl_type => "string"}),
        e_parameter->add({name => "gSTRATIXII_DQS_OUT_MODE",          default =>"$gSTRATIXII_DQS_OUT_MODE"      , vhdl_type => "string"}),
        e_port->new({name => "stratix_dll_control",direction => "output", comment =>"optional, enables the DLL reference clock only during refreshes and initialisation"}),
    );
    $parameters{'gstratixii_dqs_phase'} = "$gSTRATIXII_DQS_PHASE_SHIFT";
    $parameters{'gstratixii_dll_delay_buffer_mode'} = "gSTRATIXII_DLL_DELAY_BUFFER_MODE";
    $parameters{'gstratixii_dqs_out_mode'} = "gSTRATIXII_DQS_OUT_MODE";
    %stratix_dll_control = ("stratix_dll_control" => "stratix_dll_control");
    #28-01-05
    if (($gENABLE_CAPTURE_CLK ne "true") and ($gFEDBACK_CLOCK_MODE eq "true")){
        # my %fedback_resynch_clk = (fedback_resynch_clk => "fedback_resynch_clk");
        # my @fedback_resynch_clk;
        $fedback_resynch_clk{'fedback_resynch_clk'} = "fedback_resynch_clk";
        # $in_param{'fedback_resynch_clk'} = "fedback_resynch_clk";
        # @fedback_resynch_clk = %fedback_resynch_clk;
    }
    #28-01-05
    
}
#elsif (($gFAMILY eq "Stratix") or ($testbench_use_vector eq "true"))
elsif (($gFAMILY eq "Stratix"))
{
# Stratix only
    $module->add_contents
    (
        e_parameter->add({name => "gSTRATIX_DQS_PHASE",   default =>"$gDQS_PHASE_SHIFT" , vhdl_type => "string"    ,comment   =>  " '90' degrees,  '72' degrees"}),
        e_port->new({name => "stratix_dll_control",direction => "output", comment =>"optional, enables the DLL reference clock only during refreshes and initialisation"}),
    );
    $parameters{'gstratix_dqs_phase'} = "gSTRATIX_DQS_PHASE";
    %stratix_dll_control = ("stratix_dll_control" => "stratix_dll_control");
}

if ($gFAMILY eq "Stratix II" and ($MIG_FAMILY ne "NONE" or $gIS_HARDCOPY2 eq "true")) {
    # insert_configurable_resynch_edge_logic
	if ($MIG_FAMILY ne "NONE" or $gIS_HARDCOPY2 eq "true") {
		$resynch_edge_select{'resynch_clk_edge_select'} = "resynch_clk_edge_select";
		$module->add_contents (e_port->new({name => "resynch_clk_edge_select", direction => "input"}),);
	}
}


@fedback_resynch_clk = %fedback_resynch_clk;
    @parameters = %parameters;
    @stratix_dll_control = %stratix_dll_control;
    @dqsupdate = %dqsupdate;
foreach my $param(@dqsupdate) {
	push (@dqsupdate_list, $param);
}
	
my @parameters_list;
foreach my $parameter (@parameters) {
 push (@parameters_list, $parameter);
}

my @fedback_resynch_clk_sig;my $i=1;
foreach my $sig (@fedback_resynch_clk) {
 # print "$i)-->  $sig  <--\n";
 push (@fedback_resynch_clk_sig, $sig);
 # $i += 1;
}
if ($gFEDBACK_CLOCK_MODE eq "true"){
    $fedback_clk_out{'fedback_clk_out'} = "fedback_clk_out";
}

@fedback_clk_out = %fedback_clk_out;
my @fedback_clk_out_sig;my $i=1;
foreach my $sign (@fedback_clk_out) {
 # print "$i)-->  $sign  <--\n";
 push (@fedback_clk_out_sig, $sign);
 # $i += 1;
}

@resynch_edge_select = %resynch_edge_select;
my @fedback_resynch_clk_sig;my $i=1;
foreach my $sig (@resynch_edge_select) {
# print "$i)-->  $sig  <--\n";
 push (@resynch_edge_select_sig, $sig);
# $i += 1;
}


my  $local_size_width = $gLOCAL_BURST_LEN_BITS;
if ($gMEM_TYPE eq "ddr2_sdram") {
    if ( $local_size_width < 2 ) {
        $local_size_width = 2
    }
}


#print "\n$std_logic_Value\n";
    $module->add_contents
    (
        # e_parameter->add({name => "gLOCAL_DATA_BITS", default => 16, vhdl_type => "integer",comment => "width of data port on user side"}),
        # e_parameter->add({name => "gLOCAL_BURST_LEN", default =>  4, vhdl_type => "integer"    ,comment   =>  "gMEM_BURST_LEN / 2, max valid size on user side, 1, 2, 3 or 4"}),
        # e_parameter->add({name => "gLOCAL_BURST_LEN_BITS", default => 3, vhdl_type => "integer"    ,comment   =>  "number of bits in the size port"}),
        e_parameter->add({name => "gLOCAL_AVALON_IF",   default => "false" ,vhdl_type => "string"}),

        e_parameter->add({name => "gMEM_TYPE",      default => "ddr_sdram"  , vhdl_type => "string"    ,}),
        # e_parameter->add({name => "gMEM_CHIPSELS",  default =>2 , vhdl_type => "integer"    ,comment   =>  "no. of chip selects"}),
        # e_parameter->add({name => "gMEM_CHIP_BITS", default =>1 , vhdl_type => "integer"    ,comment   =>  "no. of bits to encode MEM_CHIPSELS"}),
        # e_parameter->add({name => "gMEM_ROW_BITS",  default =>12    , vhdl_type => "integer"    ,comment   =>  "no. of row bits"}),
        # e_parameter->add({name => "gMEM_BANK_BITS", default =>2 , vhdl_type => "integer"    ,comment   =>  "no. of bank bits, always 4?"}),
        # e_parameter->add({name => "gMEM_COL_BITS",  default =>10    , vhdl_type => " integer"    ,comment   =>  "no. of col bits"}),
        # e_parameter->add({name => "gMEM_DQ_PER_DQS",    default =>8 , vhdl_type => "integer"    ,comment   =>  "no. of DQ bits per DQS/DM"}),
        # e_parameter->add({name => "gMEM_PCH_BIT",   default =>10    , vhdl_type => "integer"    ,comment   =>  "address bit to use for precharge, only 10 & 8 are valid"}),
        # e_parameter->add({name => "gMEM_ODT_RANKS",   default =>0    , vhdl_type => "integer"    ,comment   =>  "DDR2 only, the number of DIMMs used to create the chip selects (0, 1 or 2 supported)"}),

        e_parameter->add({name => "gREG_DIMM",      default => "false"  , vhdl_type => "string"    ,comment   =>  "(*TBD*) using registered DIMMs, default = FALSE"}),
        e_parameter->add({name => "gPIPELINE_COMMANDS", default => "true"       , vhdl_type => "string"    ,comment   =>  "Add pipeline registers on command and address outputs default = true FALSE"}),
        e_parameter->add({name => "gEXTRA_PIPELINE_REGS",       default => "false", vhdl_type => "string"    ,comment   =>  "Enable a separate resynch clock"}),
        e_parameter->add({name => "gFAMILY",            default => "Stratix"    , vhdl_type => "string"    ,comment   =>  "Stratix, Stratix GX and Cyclone"}),
#           e_parameter->add({name => "gRESYNCH_EDGE",      default => "rising"     , vhdl_type => "string"    ,comment   =>  "rising, falling"}),
        # e_parameter->add({name => "gRESYNCH_CYCLE",     default => 0        , vhdl_type => "integer"    ,comment   =>  "0,1,2"}),
        e_parameter->add({name => "gINTER_RESYNCH",     default => "false"      , vhdl_type => "string"    ,comment   =>  "Insert extra negedge sys_clk resynch register in the data path"}),
#           e_parameter->add({name => "gPOSTAMBLE_EDGE",    default => "falling"    , vhdl_type => "string"    ,comment   =>  "rising, falling"}),
        # e_parameter->add({name => "gPOSTAMBLE_CYCLE",   default => 0            , vhdl_type => "integer"    ,comment   =>  "0,1,2"}),
        # e_parameter->add({name => "gINTER_POSTAMBLE",   default => "false"      , vhdl_type => "string"    ,comment   =>  "Insert extra negedge sys_clk postamble register in the data path"}),

            # e_parameter->add({name => "gENABLE_CAPTURE_CLK",        default => "false", vhdl_type => "string"    ,comment   =>  "Enable a separate capture clock"}),
        e_parameter->add({name => "gPIPELINE_READDATA",         default => "true" , vhdl_type => "string"    ,comment   =>  "Insert pipeline registers to reclock the output of the resynch registers to the posedge"}),
        e_parameter->add({name => "gUSER_REFRESH",          default => "false", vhdl_type => "string"    ,comment   =>  "Allow the user to control the refresh themselves"}),
        e_parameter->add({name => "gADDR_CMD_NEGEDGE",      default => "false", vhdl_type => "string"    ,comment   =>  "Set the address and command output regs to be clocked on the negedge"}),
        # e_parameter->add({name => "gDLL_INPUT_FREQUENCY",       default => $gCLOCK_PERIOD_IN_PS."ps", vhdl_type => "string"}),
#           e_parameter->add({name => "gENABLE_POSTAMBLE_LOGIC",    default => "true" , vhdl_type => "string"    ,comment   =>  "Enable the DQS postamble logic"}),
#           e_parameter->add({name => "gPOSTAMBLE_REGS",            default =>  1     , vhdl_type => "integer"    ,comment   =>  "Number of regs feeding the inclocken of the capture registers (per dqs group)"}),
#S      e_parameter->add({name => "gSTRATIX_DQS_PHASE",        default =>"$gDQS_PHASE_SHIFT"            , vhdl_type => "string"    ,comment   =>  " '90' degrees,  '72' degrees"}),
#           e_parameter->add({name => "gSTRATIX_UNDELAYEDDQSOUT_INSERT_BUFFERS", default => 0           , vhdl_type => "integer"    ,comment   =>  "Insert N lcell buffers in undelayed dqs out path (determined by timing analysis)"}),
        e_parameter->add({name => "gSTRATIX_DLL_CONTROL",        default => "false"             , vhdl_type => "string"    ,comment   =>  "Enable the control signal for the Stratix DLL."}),
#S2     e_parameter->add({name => "gSTRATIXII_DQS_PHASE",        default =>$gSTRATIXII_DQS_PHASE_SHIFT  , vhdl_type => "natural"    ,comment   =>  " 9000/100 '90 degrees',  7200/100 '72 degrees'"}),
#S2     e_parameter->add({name => "gSTRATIXII_DLL_DELAY_BUFFER_MODE",        default =>"$gSTRATIXII_DLL_DELAY_BUFFER_MODE"  , vhdl_type => "string"}),
#S2     e_parameter->add({name => "gSTRATIXII_DQS_OUT_MODE",                 default =>"$gSTRATIXII_DQS_OUT_MODE"       , vhdl_type => "string"}),
######################################################################################################################################################################
        e_port->new({name => "clk",direction => "input"}),
        e_port->new({name => "reset_n",direction => "input"}),
        e_port->new({name => "write_clk",direction => "input"}),
        e_port->new({name => "capture_clk",direction => "input"}),
        e_port->new({name => "resynch_clk",direction => "input"}),
        e_port->new({name => "addrcmd_clk",direction => "input"}),
        e_port->new({name => "postamble_clk",direction => "input"}),
        e_port->new({name => "local_read_req",direction => "input"}),
        e_port->new({name => "local_write_req",direction => "input"}),
        e_port->new({name => "local_size",width =>$local_size_width,direction => "input",declare_one_bit_as_std_logic_vector => 1}),
        e_port->new({name => "local_ready",direction => "output"}),
        e_port->new({name => "local_burstbegin",direction => "input"}),
        e_port->new({name => "local_addr",direction => "input",width =>$gMEM_CHIP_BITS + $gMEM_ROW_BITS + $gMEM_BANK_BITS + $gMEM_COL_BITS - 1}),
        e_port->new({name => "local_rdata_valid",direction => "output"}),
        e_port->new({name => "local_rdvalid_in_n",direction => "output"}),
        e_port->new({name => "local_rdata",direction => "output",width =>$gLOCAL_DATA_BITS}),
        e_port->new({name => "local_wdata_req",direction => "output"}),
        e_port->new({name => "local_wdata",direction => "input",width =>$gLOCAL_DATA_BITS}),
        # e_port->new({name => "local_be",direction => "input",width =>$gLOCAL_DATA_BITS / $gMEM_DQ_PER_DQS }),
        e_port->new({name => "local_be",direction => "input",width =>$gLOCAL_DATA_BITS / 8 }), # fixed at 1 byte enable per *byte*
        e_port->new({name => "local_init_done",direction => "output"}),
        e_port->new({name => "local_refresh_req",direction => "input"}),
        e_port->new({name => "local_refresh_ack",direction => "output"}),
        e_port->new({name => "local_autopch_req",direction => "input"}),
        e_port->new({name => "ddr_cs_n",direction => "output",width =>$gMEM_CHIPSELS,declare_one_bit_as_std_logic_vector => $std_logic_Value}),
        e_port->new({name => "ddr_cke",direction => "output",width =>$gMEM_CHIPSELS,declare_one_bit_as_std_logic_vector => $std_logic_Value}),
        e_port->new({name => "ddr_odt",direction => "output",width =>$gMEM_CHIPSELS,declare_one_bit_as_std_logic_vector => $std_logic_Value}),
        e_port->new({name => "ddr_a",direction => "output",width =>$gMEM_ROW_BITS}),
        e_port->new({name => "ddr_ba",direction => "output",width =>$gMEM_BANK_BITS}),
        e_port->new({name => "ddr_ras_n",direction => "output"}),
        e_port->new({name => "ddr_cas_n",direction => "output"}),
        e_port->new({name => "ddr_we_n",direction => "output"}),
        e_port->new({name => "ddr_dq",direction => "inout",width =>$gLOCAL_DATA_BITS / 2}),
        e_port->new({name => "ddr_dqs",direction => "inout",width =>$gLOCAL_DATA_BITS / 2 / $gMEM_DQ_PER_DQS,declare_one_bit_as_std_logic_vector => $std_logic_Value}),
        e_port->new({name => "ddr_dm",direction => "output",width =>$gLOCAL_DATA_BITS / 2 / $gMEM_DQ_PER_DQS,declare_one_bit_as_std_logic_vector => $std_logic_Value}),
        e_port->new({name => "mem_tcl",direction => "input",width =>3, comment =>"CAS latency setting, 2.0 = '010', 2.5 = '110', 3.0 = '011'"}),
        e_port->new({name => "mem_bl",direction => "input",width =>3, comment =>"Burst length setting, 2 = '001', 4 = '010', 8 = '011'"}),
        e_port->new({name => "mem_odt",direction => "input",width =>2, comment =>"DDR2 ODT setting, Disabled = '00', 50 = '11', 75 = '01', 150 = '10'"}),
        e_port->new({name => "mem_btype",direction => "input", comment =>"Burst type, sequential = '0', interleaved = '1'"}),
        e_port->new({name => "mem_dll_en",direction => "input", comment =>"DLL enable, enable = '0', disable = '1'"}),
        e_port->new({name => "mem_drv_str",direction => "input", comment =>"Drive strength, normal = '0', reduced = '1'"}),
        e_port->new({name => "mem_trcd",direction => "input",width =>3, comment =>"integer := 2;         -- Range = 2 - 5"}),
        e_port->new({name => "mem_tras",direction => "input",width =>4, comment =>"integer := 4;         -- Range = 4 - 15"}),
        e_port->new({name => "mem_twtr",direction => "input",width =>2, comment =>"integer := 1;         -- Range = 1 - 2"}),
        e_port->new({name => "mem_twr",direction => "input",width =>3, comment =>"integer := 2;         -- Range = 2 - 5"}),
        e_port->new({name => "mem_trp",direction => "input",width =>3, comment =>"integer := 2;         -- Range = 2 - 5"}),
        e_port->new({name => "mem_trfc",direction => "input",width =>7, comment =>"integer := 7;         -- Range = 7 - 127"}),
        e_port->new({name => "mem_tmrd",direction => "input",width =>2, comment =>"integer := 2;         -- Range = 2 - 3"}),
        e_port->new({comment =>"integer := 1300;     -- 64ms / 8192 / 6ns, max = 2^16",name => "mem_trefi",direction => "input",width =>16}),
        e_port->new({name => "mem_tinit_time",direction => "input",width =>16}),


        e_port->new({name => "clk_to_sdram",direction => "output", width => $gNUM_CLOCK_PAIRS,declare_one_bit_as_std_logic_vector => $std_logic_Value}),
        e_port->new({name => "clk_to_sdram_n",direction => "output", width => $gNUM_CLOCK_PAIRS,declare_one_bit_as_std_logic_vector => $std_logic_Value}),

#########################################################################################################################################################

        e_signal->new
        ({
           name =>"control_doing_wr",
           width =>  1,
           export => 0,
           never_export => 1,
           comment => "control interface between controller and datapaths",
        }),
        e_signal->news #: ["signal", width, export, never_export]
        (
            ["control_wdata_valid", 1,      0,      1],
            ["control_dqs_burst",   1,      0,      1],
            ["control_wdata",       $gLOCAL_DATA_BITS,      0,      1],
#           ["control_be",      $gLOCAL_DATA_BITS / $gMEM_DQ_PER_DQS,      0,      1],
            ["control_be",      $gLOCAL_DATA_BITS / 8,      0,      1],
            ["control_doing_rd",    1,      0,      1],
            ["control_rdata",       $gLOCAL_DATA_BITS,      0,      1],
            ["local_row_addr",      $gMEM_ROW_BITS,      0,      1],
            ["local_bank_addr",     $gMEM_BANK_BITS,      0,      1],
        ),

        e_signal->new({name => "tmp_ddr_cs_n", width =>$gMEM_CHIPSELS,declare_one_bit_as_std_logic_vector => $std_logic_Value,export => 0,never_export => 1}),
        e_signal->new({name => "tmp_ddr_cke",  width =>$gMEM_CHIPSELS,declare_one_bit_as_std_logic_vector => $std_logic_Value,export => 0,never_export => 1}),
        e_signal->new({name => "tmp_ddr_odt",  width =>$gMEM_CHIPSELS,declare_one_bit_as_std_logic_vector => $std_logic_Value,export => 0,never_export => 1}),
        e_signal->new({name => "tmp_ddr_a",    width =>$gMEM_ROW_BITS, export => 0,never_export => 1}),
        e_signal->new({name => "tmp_ddr_ba",   width =>$gMEM_BANK_BITS, export => 0,never_export => 1}),
        e_signal->new({name => "tmp_ddr_ras_n",export => 0,never_export => 1}),
        e_signal->new({name => "tmp_ddr_cas_n",export => 0,never_export => 1}),
        e_signal->new({name => "tmp_ddr_we_n", export => 0,never_export => 1}),
        e_signal->new({name => "local_cs_addr",width => $gLEGAL_MEM_CHIP_BITS,export => 0, never_export => 1,declare_one_bit_as_std_logic_vector => 0}),

        e_signal->new
        ({
           name =>"local_col_addr",
           width => $gMEM_COL_BITS - 1,
           export => 0,
           never_export => 1,
           comment => "note dropping of column LSB!",
        }),
    );

###############################################################################################################################################
if (($gFEDBACK_CLOCK_MODE eq "true") or ($testbench_use_vector eq "true"))
{
    $module->add_contents
    (
        e_port->new({name => "fedback_clk_out",direction => "output", width => 1,declare_one_bit_as_std_logic_vector => 0}),
    );
}
#################################################################################################################################################################
if ( $gMEM_CHIP_BITS > 0 )
{
    $module->add_contents
    (
        e_assign->new(["local_cs_addr"   => "local_addr["."$gMEM_CHIP_BITS + $gMEM_BANK_BITS + $gMEM_ROW_BITS + $gMEM_COL_BITS - 2".":"."$gMEM_BANK_BITS + $gMEM_ROW_BITS + $gMEM_COL_BITS - 1"."]",]),
    );
}else
{
    $module->add_contents
    (
        e_assign->new({lhs => "local_cs_addr", rhs  => "0"}),
    );
}
################################################################################################################################################################
    #$module->add_attribute(ALTERA_ATTRIBUTE => "MESSAGE_DISABLE=14130");
    
    $module->add_contents
    (
        e_assign->new({lhs => "local_bank_addr", rhs => "local_addr["."$gMEM_BANK_BITS + $gMEM_ROW_BITS + $gMEM_COL_BITS - 2".":"."$gMEM_ROW_BITS + $gMEM_COL_BITS - 1"."]",comment => "\n\n"}),
        e_assign->new(["local_row_addr" => "local_addr["."$gMEM_ROW_BITS + $gMEM_COL_BITS - 2".":"."$gMEM_COL_BITS - 1"."]"]),
        e_assign->new(["local_col_addr" => "local_addr["."$gMEM_COL_BITS - 2".":"."0"."]"]),
        e_comment->new({comment     =>
             "-----------------------------------------------------------------------------\n
             Controller\n
             -----------------------------------------------------------------------------",
        }),
         #e_blind_instance->new
            e_auk_ddr_ctrl->new
        ({
            name        => "ddr_control",
            module      => "auk_ddr_controller",
            #$use_vlog_rtl_param => $std_logic_bracket,
            #_use_generated_component   => 0,
            #generate_component_package => 0,
            #in_port_map    =>
            port_map    =>
            {
                clk                     => "clk",
                reset_n                 => "reset_n",
                write_clk               => "write_clk",
                local_read_req          => "local_read_req",
                local_write_req         => "local_write_req",
                local_size              => "local_size[".($local_size_width-1).":0]",
                local_wdata             => "local_wdata",
                local_be                => "local_be",
                local_refresh_req       => "local_refresh_req",
                local_autopch_req       => "local_autopch_req",
                local_cs_addr           => "local_cs_addr",
                local_row_addr          => "local_row_addr",
                local_bank_addr         => "local_bank_addr",
                local_col_addr          => "local_col_addr",
                local_burstbegin    =>  "local_burstbegin",

                control_rdata           => "control_rdata",
                mem_tcl                 => "mem_tcl",
                mem_bl                  => "mem_bl",
                mem_odt                 => "mem_odt",
                mem_btype               => "mem_btype",
                mem_dll_en              => "mem_dll_en",
                mem_drv_str             => "mem_drv_str",
                mem_trcd                => "mem_trcd",
                mem_tras                => "mem_tras",
                mem_twtr                => "mem_twtr",
                mem_twr                 => "mem_twr",
                mem_trp                 => "mem_trp",
                mem_trfc                => "mem_trfc",
                mem_tmrd                => "mem_tmrd",
                mem_trefi               => "mem_trefi",
                mem_tinit_time          => "mem_tinit_time",
            #},
            #out_port_map =>
            #{
                @stratix_dll_control[0] =>  @stratix_dll_control[1],
                local_ready             =>  "local_ready",

                local_rdata_valid       =>  "local_rdata_valid",
                local_rdvalid_in_n      =>  "local_rdvalid_in_n",
                local_rdata             =>  "local_rdata",
                local_wdata_req         =>  "local_wdata_req",
                local_init_done         =>  "local_init_done",
                local_refresh_ack       =>  "local_refresh_ack",
                control_doing_wr        => "control_doing_wr",
                control_wdata_valid     => "control_wdata_valid",
                control_dqs_burst       => "control_dqs_burst",
                control_doing_rd        => "control_doing_rd",
                control_wdata           => "control_wdata",
                control_be              => "control_be",
                ddr_cs_n                =>  "tmp_ddr_cs_n[".($gMEM_CHIPSELS - 1).":0]",#$std_logic_bracket,#"ddr_cs_n[0:0]",
                ddr_cke                 =>  "tmp_ddr_cke[".($gMEM_CHIPSELS - 1).":0]",#$std_logic_bracket,#"ddr_cke[0:0]",
                ddr_odt                 =>  "tmp_ddr_odt[".($gMEM_CHIPSELS - 1).":0]",#$std_logic_bracket,#"ddr_odt[0:0]",
                ddr_a                   =>  "tmp_ddr_a",
                ddr_ba                  =>  "tmp_ddr_ba",
                ddr_ras_n               =>  "tmp_ddr_ras_n",
                ddr_cas_n               =>  "tmp_ddr_cas_n",
                ddr_we_n                =>  "tmp_ddr_we_n",
            },
            parameter_map =>
            {
                gLOCAL_DATA_BITS        => $gLOCAL_DATA_BITS,
                gLOCAL_BURST_LEN        => $gLOCAL_BURST_LEN,
                gLOCAL_BURST_LEN_BITS   => $gLOCAL_BURST_LEN_BITS,
                gLOCAL_AVALON_IF        => gLOCAL_AVALON_IF,

                gMEM_TYPE               => gMEM_TYPE,
                gMEM_CHIPSELS           => $gMEM_CHIPSELS,
                gMEM_CHIP_BITS          => $gMEM_CHIP_BITS,
                gMEM_ROW_BITS           => $gMEM_ROW_BITS,
                gMEM_BANK_BITS          => $gMEM_BANK_BITS,
                gMEM_COL_BITS           => $gMEM_COL_BITS,
                gMEM_DQ_PER_DQS         => $gMEM_DQ_PER_DQS,
                gMEM_PCH_BIT            => $gMEM_PCH_BIT,
                gMEM_ODT_RANKS          => $gMEM_ODT_RANKS,

                gREG_DIMM               => gREG_DIMM,
                gPIPELINE_COMMANDS      => gPIPELINE_COMMANDS,
                gEXTRA_PIPELINE_REGS    => gEXTRA_PIPELINE_REGS,
                gADDR_CMD_NEGEDGE       => gADDR_CMD_NEGEDGE,
                gFAMILY                 => gFAMILY,
                gRESYNCH_CYCLE          => $gRESYNCH_CYCLE,
                gINTER_RESYNCH          => gINTER_RESYNCH,
                gUSER_REFRESH           => gUSER_REFRESH,
                gPIPELINE_READDATA      => gPIPELINE_READDATA,
                gSTRATIX_DLL_CONTROL    => gSTRATIX_DLL_CONTROL,
            },
            #std_logic_vector_signals =>
            #[
            #   ddr_cs_n,
            #   ddr_cke,
            #   local_size,
            #   local_cs_addr,
            #   ddr_odt,
            #],
            # _port_default_values =>
            # {
                # local_size    => "$local_size_width",
            # },
        }),
    );
##################################################################################################################################################################
    

    if(@Stratix_Fam[1] eq "dqs_delay_ctrl")
    {
        $module->add_contents
        (
             e_blind_instance->new
            ({
                name        => "ddr_io",
                module      => ${gWRAPPER_NAME}."_auk_ddr_datapath",
                generate_component_package  => 1,
                in_port_map     =>
                {
                    clk                     => "clk",
                    reset_n                 => "reset_n",
                    write_clk               => "write_clk",
                    capture_clk             => "capture_clk",
                    resynch_clk             => "resynch_clk",

                    @fedback_resynch_clk    => @fedback_resynch_clk_sig,
                   @resynch_edge_select => @resynch_edge_select_sig,

                    @Stratix_Fam[0]         => @Stratix_Fam[1],
                    postamble_clk           => "postamble_clk",
                    control_doing_wr    => "control_doing_wr",
                    control_wdata_valid     => "control_wdata_valid",
                    control_dqs_burst       => "control_dqs_burst",
                    control_doing_rd        => "control_doing_rd",
                    control_wdata           => "control_wdata",
                    control_be              => "control_be",
		    @dqsupdate	    	    =>	@dqsupdate_list,
                },
                out_port_map    =>
                {
                    control_rdata           => "control_rdata",
                    ddr_dm                  => "ddr_dm[".(($gLOCAL_DATA_BITS / 2 / $gMEM_DQ_PER_DQS) - 1).":0]",#$std_logic_bracket,#"ddr_dm[0:0]",
                    clk_to_sdram        => "clk_to_sdram[".($gNUM_CLOCK_PAIRS - 1).":0]",#$std_logic_bracket,
                    clk_to_sdram_n      => "clk_to_sdram_n[".($gNUM_CLOCK_PAIRS - 1).":0]",#$std_logic_bracket,

                    @fedback_clk_out    => @fedback_clk_out_sig,

                },
                inout_port_map  =>
                {
                    ddr_dq                  => "ddr_dq",
                    ddr_dqs                 => "ddr_dqs[".(($gLOCAL_DATA_BITS / 2 / $gMEM_DQ_PER_DQS) - 1).":0]",#$std_logic_bracket,#"ddr_dqs[0:0]",
                },
                parameter_map =>
                {
                    @parameters               => @parameters_list,
                },
                std_logic_vector_signals =>
                [
                    # ddr_dm,
                    # ddr_dqs,
                ],
            }),
        );
    }else
    {
        $module->add_contents
        (
             e_blind_instance->new
            ({
                name        => "ddr_io",
                module      => ${gWRAPPER_NAME}."_auk_ddr_datapath",
                generate_component_package  => 1,
                in_port_map     =>
                {
                    clk                     => "clk",
                    reset_n                 => "reset_n",
                    write_clk               => "write_clk",
                    capture_clk             => "capture_clk",
                    resynch_clk             => "resynch_clk",
                    postamble_clk           => "postamble_clk",

                    @fedback_resynch_clk    => @fedback_resynch_clk_sig,
                   @resynch_edge_select => @resynch_edge_select_sig,

                    control_doing_wr    => "control_doing_wr",
                    control_wdata_valid     => "control_wdata_valid",
                    control_dqs_burst       => "control_dqs_burst",
                    control_doing_rd        => "control_doing_rd",
                    control_wdata           => "control_wdata",
                    control_be              => "control_be",
                },
                out_port_map    =>
                {
                    control_rdata           => "control_rdata",
                    ddr_dm                  => "ddr_dm[".(($gLOCAL_DATA_BITS / 2 / $gMEM_DQ_PER_DQS) - 1).":0]",#$std_logic_bracket,#"ddr_dm[0:0]",
                    clk_to_sdram        => "clk_to_sdram[".($gNUM_CLOCK_PAIRS - 1).":0]",#$std_logic_bracket,
                    clk_to_sdram_n      => "clk_to_sdram_n[".($gNUM_CLOCK_PAIRS - 1).":0]",#$std_logic_bracket,

                    @fedback_clk_out    => @fedback_clk_out_sig,

                },
                inout_port_map  =>
                {
                    ddr_dq                  => "ddr_dq",
                    ddr_dqs                 => "ddr_dqs[".(($gLOCAL_DATA_BITS / 2 / $gMEM_DQ_PER_DQS) - 1).":0]",#$std_logic_bracket,#"ddr_dqs[0:0]",
                },
                parameter_map =>
                {
                    @parameters               => @parameters_list,
                },
                std_logic_vector_signals =>
                [
                    # ddr_dm,
                    # ddr_dqs,
                ],
            }),
        );
    }

##################################################################################################################################################################
        #print "mem type = $gMEM_TYPE and CL = $gCASLATENCY\n";
if ($gEXTRA_PL_REG eq "true") {

    #$module->add_contents (e_port->new({name => "addrcmd_clk",direction => "input"}),);
    
    
    if ($gMEM_TYPE eq "ddr2_sdram") {
        
        if ($gCASLATENCY eq "4.0" or $gCASLATENCY eq "5.0") {
            if ($gNEGEDGE_ADDRCMD eq "true") {
    
                $module->add_contents (
                    e_process->new
                    ({
                        clock          =>  "addrcmd_clk",
                        reset          =>  "reset_n",
                        clock_level    =>  0,
                        comment        => "Clock out the ODT command using the falling edge of the addrcmd_clk",
                        _asynchronous_contents => [e_assign->new(["ddr_odt[$gMEM_CHIPSELS-1:0]"   => "0"]),],
                        contents       =>         [e_assign->new(["ddr_odt"   => "tmp_ddr_odt"]),]
                    }),
                );
            } else { # posedge addrcmd
                $module->add_contents (
                    e_process->new
                    ({
                        clock          =>  "addrcmd_clk",
                        reset          =>  "reset_n",
                        # clock_level    =>  1,
                        comment        => "Clock out the ODT command using the rising edge of the addrcmd_clk",
                        _asynchronous_contents => [e_assign->new(["ddr_odt[$gMEM_CHIPSELS-1:0]"   => "0"]),],
                        contents       =>         [e_assign->new(["ddr_odt"   => "tmp_ddr_odt"]),          ],
                    }),
                );
            }
        } else { # CAS3
            # print "DDR2 and CL = $gCASLATENCY so don't reg ODT\n";

            $module->add_contents ( 
                e_assign->new({lhs => "ddr_odt", rhs => "tmp_ddr_odt", comment => "Cannot have extra pipeline register on ODT signal if CL3 is used"}), 
                );
        }
    }
    
    if ($gNEGEDGE_ADDRCMD eq "true") {
        $module->add_contents (
            e_process->new
            ({
                clock          =>  "addrcmd_clk",
                reset          =>  "reset_n",
                clock_level    =>  0,
                comment        => "Clock out the address and commands using the falling edge of the addrcmd_clk",
                _asynchronous_contents =>
                [
                    e_assign->new(["ddr_cs_n[$gMEM_CHIPSELS-1:0]"  => "{".$gMEM_CHIPSELS."{1'b1}}"]),  
                    #e_assign->new(["ddr_cke[$gMEM_CHIPSELS-1:0]"   => "0"]),  
                    #e_assign->new(["ddr_odt[$gMEM_CHIPSELS-1:0]"   => "0"]),  
                    e_assign->new(["ddr_a"     => "0"]), #  
                    e_assign->new(["ddr_ba"    => "0"]), #  
                    e_assign->new(["ddr_ras_n" => "1"]), #  
                    e_assign->new(["ddr_cas_n" => "1"]), #  
                    e_assign->new(["ddr_we_n"  => "1"]), #  
                ],
                
                contents   =>
                [
                    e_assign->new(["ddr_cs_n"  => "tmp_ddr_cs_n"]),  
                    #e_assign->new(["ddr_cke"   => "tmp_ddr_cke"]),  
                    #e_assign->new(["ddr_odt"   => "tmp_ddr_odt"]),
                    e_assign->new(["ddr_a"     => "tmp_ddr_a"]),   
                    e_assign->new(["ddr_ba"    => "tmp_ddr_ba"]),   
                    e_assign->new(["ddr_ras_n" => "tmp_ddr_ras_n"]),   
                    e_assign->new(["ddr_cas_n" => "tmp_ddr_cas_n"]),   
                    e_assign->new(["ddr_we_n"  => "tmp_ddr_we_n"]),   
                ],
            }),
	    e_register->new
	    ({
		    out             => "ddr_cke",
		    in              => "tmp_ddr_cke",
		    clock           => "addrcmd_clk",
		    reset           => "reset_n",
		    clock_level     => 0,
		    _enable         => "1",
		    user_attributes => [
		    {
			    attribute_name => '-name POWER_UP_LEVEL',
			    attribute_operator => ' ',
			    attribute_values => ['LOW'],
		    },
		    ],
	    }),
        );
    } else { # posedge
        $module->add_contents (
            e_process->new
            ({
                clock          =>  "addrcmd_clk",
                reset          =>  "reset_n",
                clock_level    =>  1,
                comment        => "Clock out the address and commands using the rising edge of the addrcmd_clk",
                _asynchronous_contents =>
                [
                    e_assign->new(["ddr_cs_n[$gMEM_CHIPSELS-1:0]"  => "{".$gMEM_CHIPSELS."{1'b1}}"]),  
                    #e_assign->new(["ddr_cke[$gMEM_CHIPSELS-1:0]"   => "0"]),  
                    #e_assign->new(["ddr_odt[$gMEM_CHIPSELS-1:0]"   => "0"]),  
                    e_assign->new(["ddr_a"     => "0"]), #  
                    e_assign->new(["ddr_ba"    => "0"]), #  
                    e_assign->new(["ddr_ras_n" => "1"]), #  
                    e_assign->new(["ddr_cas_n" => "1"]), #  
                    e_assign->new(["ddr_we_n"  => "1"]), #  
                ],
                contents   =>
                [
                    e_assign->new(["ddr_cs_n"  => "tmp_ddr_cs_n"]),  
                    #e_assign->new(["ddr_cke"   => "tmp_ddr_cke"]),  
                    #e_assign->new(["ddr_odt"   => "tmp_ddr_odt"]),
                    e_assign->new(["ddr_a"     => "tmp_ddr_a"]),   
                    e_assign->new(["ddr_ba"    => "tmp_ddr_ba"]),   
                    e_assign->new(["ddr_ras_n" => "tmp_ddr_ras_n"]),   
                    e_assign->new(["ddr_cas_n" => "tmp_ddr_cas_n"]),   
                    e_assign->new(["ddr_we_n"  => "tmp_ddr_we_n"]),   
                ],
            }),
	    e_register->new
	    ({
		    out             => "ddr_cke",
		    in              => "tmp_ddr_cke",
		    clock           => "addrcmd_clk",
		    reset           => "reset_n",
		    clock_level     => 1,
		    _enable         => "1",
		    user_attributes => [
		    {
			    attribute_name => '-name POWER_UP_LEVEL',
			    attribute_operator => ' ',
			    attribute_values => ['LOW'],
		    },
		    ],
	    }),
        );
    }
} else {
    $module->add_contents
    (
        e_assign->new(["ddr_cs_n"  => "tmp_ddr_cs_n"]),  
        e_assign->new(["ddr_cke"   => "tmp_ddr_cke"]),  
        e_assign->new(["ddr_odt"   => "tmp_ddr_odt"]),
        e_assign->new(["ddr_a"     => "tmp_ddr_a"]),   
        e_assign->new(["ddr_ba"    => "tmp_ddr_ba"]),   
        e_assign->new(["ddr_ras_n" => "tmp_ddr_ras_n"]),   
        e_assign->new(["ddr_cas_n" => "tmp_ddr_cas_n"]),   
        e_assign->new(["ddr_we_n"  => "tmp_ddr_we_n"]),   
    );
    
}
##################################################################################################################################################################

$project->output();

}

1;

#You're done.



