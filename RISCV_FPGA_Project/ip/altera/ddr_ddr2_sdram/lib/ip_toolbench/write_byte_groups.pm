use europa_all;
use europa_utils;
use e_comment;
use e_lpm_stratixii_io;
use e_lpm_stratix_io;
use e_lpm_altddio_bidir;
use e_lpm_altddio_out;

sub write_auk_ddr_dqs_group
{
my $top = e_module->new({name => $gWRAPPER_NAME . "_auk_ddr_dqs_group"});
my $project = e_project->new({top => $top, language => $language,__system_directory =>$output_directory, timescale => "1ps / 1ps"});
my $module = $project->top();
$module->vhdl_libraries()->{altera_mf} = all;
#$module->vhdl_libraries()->{altera} = "altera.altera_syn_attributes";
$module->add_attribute
	(ALTERA_ATTRIBUTE =>
		"MESSAGE_DISABLE=14130;SUPPRESS_DA_RULE_INTERNAL=C101;SUPPRESS_DA_RULE_INTERNAL=C103;SUPPRESS_DA_RULE_INTERNAL=C105;SUPPRESS_DA_RULE_INTERNAL=C106;SUPPRESS_DA_RULE_INTERNAL=R104;SUPPRESS_DA_RULE_INTERNAL=A102;SUPPRESS_DA_RULE_INTERNAL=A103;SUPPRESS_DA_RULE_INTERNAL=C104;SUPPRESS_DA_RULE_INTERNAL=D101;SUPPRESS_DA_RULE_INTERNAL=D102;SUPPRESS_DA_RULE_INTERNAL=D103;SUPPRESS_DA_RULE_INTERNAL=R102;SUPPRESS_DA_RULE_INTERNAL=R105");
#####   Parameters declaration  ######
my $header_title = "Datapath for the Altera DDR SDRAM Controller";
my $header_filename = $gWRAPPER_NAME . "_ddr_dqs_group" . $file_ext;
my $header_revision = "V" . $gWIZARD_VERSION;
my $header_abstract = "This file contains the datapath for the DDR SDRAM Controller.";
my $dqs_group_instname;
my $Stratix_Fam = "";
my %stratix_param  = "";
####  end parameter list  ######

my $insert_configurable_resynch_edge_logic = "false";

# If it's a Stratix II project and there's a companion device set or if it's HC2 first
# NB - gFAMILY is "Stratix II" for both S2 and HC2
if ($gFAMILY eq "Stratix II" and ($MIG_FAMILY ne "NONE" or $gIS_HARDCOPY2 eq "true")) {
    $insert_configurable_resynch_edge_logic = "true";
}
#print "insert_configurable_resynch_edge_logic = $insert_configurable_resynch_edge_logic\n";

######################################################################################################################################################################
    $module->comment
    (
        "------------------------------------------------------------------------------\n
         Parameters:\n\n
         Device Family                      : $gFAMILY\n
         DQ_PER_DQS                         : $gMEM_DQ_PER_DQS\n
         NON-DQS MODE                       : $gENABLE_CAPTURE_CLK\n
         use Resynch clock                  : $gENABLE_RESYNCH_CLK\n
         Resynch clock edge                 : $gRESYNCH_EDGE\n
         Postamble Clock Edge               : $gPOSTAMBLE_EDGE\n
         Postamble Clock Cycle              : $gPOSTAMBLE_CYCLE\n
         Intermediate Resynch               : $gINTER_RESYNCH\n
         Intermediate Postamble             : $gINTER_POSTAMBLE\n
         Pipeline read Data                 : $gPIPELINE_READDATA\n
         Enable Postamble Logic             : $gENABLE_POSTAMBLE_LOGIC\n
         Postamble Regs Per DQS             : $gPOSTAMBLE_REGS\n
         Stratix Insert DQS delay buffers   : $gSTRATIX_UNDELAYEDDQSOUT_INSERT_BUFFERS\n
        ------------------------------------------------------------------------------"
    );
######################################################################################################################################################################
    # $module->add_contents
    # (
    #####   Paramenter declaration# ######
        # e_parameter->add({name => "gMEM_DQ_PER_DQS", default => $gMEM_DQ_PER_DQS, vhdl_type => "integer"}),
        # e_parameter->add({name => "gPOSTAMBLE_CYCLE", default => $gPOSTAMBLE_CYCLE, vhdl_type => "integer"}),
        # e_parameter->add({name => "gINTER_RESYNCH", default => $gINTER_RESYNCH, vhdl_type => "string"}),
        # e_parameter->add({name => "gINTER_POSTAMBLE", default => $gINTER_POSTAMBLE, vhdl_type => "string"}),
        # e_parameter->add({name => "gPIPELINE_READDATA", default => $gPIPELINE_READDATA, vhdl_type => "string"}),
        # e_parameter->add({name => "gPOSTAMBLE_REGS", default => $gPOSTAMBLE_REGS, vhdl_type => "integer"}),
        #e_parameter->add({name => "none", default => "none", vhdl_type => "string"}),
    # );
######################################################################################################################################################################
    $module->add_contents
    (
    #####   Ports declaration#  ######
        e_port->new({name => "clk",direction => "input"}),
        e_port->new({name => "reset_n",direction => "input"}),
        e_port->new({name => "write_clk",direction => "input"}),
        e_port->new({name => "capture_clk",direction => "input"}),
        e_port->new({name => "resynch_clk",direction => "input"}),
        e_port->new({name => "postamble_clk",direction => "input"}),
        e_port->new({name => "ddr_dq",direction => "inout",width =>$gMEM_DQ_PER_DQS}),
        e_port->new({name => "ddr_dqs",direction => "inout",declare_one_bit_as_std_logic_vector => 0}),
        e_port->new({name => "ddr_dm",direction => "output",declare_one_bit_as_std_logic_vector => 0}),
        e_port->new({name => "control_doing_wr",direction => "input"}),
        e_port->new({name => "control_wdata_valid",direction => "input"}),
        e_port->new({name => "control_dqs_burst",direction => "input"}),
        e_port->new({name => "control_wdata",width=>$gMEM_DQ_PER_DQS * 2,direction => "input"}),
        e_port->new({name => "control_be",width=>2,direction => "input"}),
        e_port->new({name => "control_doing_rd",direction => "input"}),
        e_port->new({name => "control_rdata",width => $gMEM_DQ_PER_DQS * 2,direction => "output"}),
    );
#########################################################################################################################################################
    $module->add_contents
    (
    #####   signal generation #####
        e_signal->news #: ["signal", width, export, never_export]
        (
           ["control_rdata",$gMEM_DQ_PER_DQS * 2,   0,  1],
           ["ddr_dq",$gMEM_DQ_PER_DQS,  0,  1],
           ["ddr_dqs",1,    0,  1],
           ["ddr_dm",1, 0,  1],

          #["dqs_clk",1,    0,  1],
          #["not_dqs_clk",1,    0,  1],
          ["dqs_oe",1,  0,  1],
          #["dqs_oe_r",1,   0,  1],
          ["dq_oe",1,   0,  1],

          ["resynched_data",$gMEM_DQ_PER_DQS * 2,   0,  1],
          ["inter_rdata",$gMEM_DQ_PER_DQS * 2,  0,  1],
          ["dq_captured_rising",$gMEM_DQ_PER_DQS,       0,  1],
          ["dq_captured_falling",$gMEM_DQ_PER_DQS,      0,  1],

          ["chosen_resynch_clk",1,  0,  1],
          #["dqs_pin",1,    0,  1],

          ["dqs_postamble_clk",1,   0,  1],
          ["rdata",$gMEM_DQ_PER_DQS * 2,    0,  1],
          ["wdata",$gMEM_DQ_PER_DQS * 2,    0,  1],
          ["wdata_r",$gMEM_DQ_PER_DQS * 2,  0,  1],
          ["wdata_valid",1, 0,  1],
          ["doing_wr",1,    0,  1],
          ["doing_wr_r",1,  0,  1],
          ["doing_rd",1,    0,  1],
          ["doing_rd_pipe",$gPOSTAMBLE_CYCLE + 2,   0,  1],
          ["doing_rd_delayed",1,    0,  1],
          # ["dqs_burst_r",1, 0,  1],
          ["be",2,  0,  1],
          ["be_r",2,    0,  1],
          ["dm_out",2,  0,  1],

          #["ONE",1,    0,  1],
          ["ZERO",1,    0,  1],
          ["ZEROS",$gMEM_DQ_PER_DQS,    0,  1],
          ["ZEROS_14",14,    0,  1],

          ["NOCONNECT", 1, 0, 1], # acts like OPEN in VHDL
         ),
          e_signal->new({name => "dq_capture_clk",  width => 1,export => 0,never_export =>1,declare_one_bit_as_std_logic_vector => 0}),
          e_signal->new({name => "dq_enable",       width => $gPOSTAMBLE_REGS,export =>   0,never_export =>1,declare_one_bit_as_std_logic_vector => 1}),
          e_signal->new({name => "dq_enable_reset", width => $gPOSTAMBLE_REGS,export => 0,never_export =>1,declare_one_bit_as_std_logic_vector => 1}),
          e_signal->new({name => "reset",           width =>  1,export => 0,never_export => 1,declare_one_bit_as_std_logic_vector => 0}),
          e_signal->new({name => "dqs_clk",         width =>  1,export => 0,never_export => 1,declare_one_bit_as_std_logic_vector => 1}),
          e_signal->new({name => "dqs_oe_r",        width =>  1,export => 0,never_export => 1,declare_one_bit_as_std_logic_vector => 1}),
          e_signal->new({name => "dqs_twpst_ctrl",   width =>  1,export => 0,never_export => 1,declare_one_bit_as_std_logic_vector => 1}),
          e_signal->new({name => "dqs_pin",         width =>  1,export => 0,never_export => 1,declare_one_bit_as_std_logic_vector => 1}),
          e_signal->new({name => "undelayed_dqs",   width =>  1,export => 0,never_export => 1,declare_one_bit_as_std_logic_vector => 1}),
          e_signal->new({name => "not_dqs_clk",     width =>  1,export => 0,never_export => 1,declare_one_bit_as_std_logic_vector => 1}),
          e_comment->new({comment => "\n\n"}),
    );

    # some of the verilog models don't like being connected to a signal driven by 1'b1, so drive them directly.
    my $std_logic1;
    my $noconnect;

    if ($language eq "vhdl"){
        $noconnect = "OPEN";
        $std_logic1 = "ONE";
        $module->add_contents
        (
            e_signal->new({name => "ONE", width => 1, export => 0, never_export => 1}),
            e_assign->new({lhs => "ONE", rhs => "1'b1"}),
        );
    }else{
        $noconnect = "NOCONNECT";
        $std_logic1 = "1'b1";
    }
###############################################################################################################################################################
    $module->add_contents
    (
        e_assign->new(["ZERO" => "1'b0"]),
        e_assign->new(["ZEROS" => "0"]),
        e_assign->new(["ZEROS_14" => "0"]),
        e_assign->new(["reset" => "~reset_n"]),
        e_assign->new(["not_dqs_clk" => "~dqs_clk"]),
        e_assign->new({lhs => "control_rdata", rhs=> "rdata",comment => " rename user i/f signals, outputs"}),
        e_assign->new({lhs => "wdata", rhs=> "control_wdata",comment => " rename user i/f signals, inputs"}),
        e_assign->new(["wdata_valid" => "control_wdata_valid"]),
        e_assign->new(["doing_wr" => "control_doing_wr"]),
        e_assign->new(["doing_rd" => "control_doing_rd"]),
        e_assign->new(["be" => "control_be"]),
        e_assign->new(["dqs_burst" => "control_dqs_burst"]),
    );
###############################################################################################################################################################
    $module->add_contents
    (
         e_process->new
         ({
             clock          =>  "clk",
             reset          =>  "reset_n",
             _asynchronous_contents =>
             [
              e_assign->new(["dqs_oe_r[0]" => "1'b0"]),
              e_assign->new(["doing_wr_r" => "1'b0"]),
              # e_assign->new(["dqs_burst_r" => "1'b0"]),
             ],
             contents   =>
             [
              e_assign->new(["dqs_oe_r[0]" => "dqs_oe"]),
              e_assign->new(["doing_wr_r" => "doing_wr"]),
              # e_assign->new(["dqs_burst_r" => "dqs_burst"]),
             ],
             comment            =>
             "-----------------------------------------------------------------------------\n
               DQS pin and its logic\n\n
               Generate the output enable for DQS from the signal that indicates we're\n
               doing a write. The DQS burst signal is generated by the controller to keep\n
               the DQS toggling for the required burst length.\n
              -----------------------------------------------------------------------------\n",
         }),

         e_assign->new(["dqs_oe" => "(doing_wr | dqs_burst)"]),
    );
##################################################################################################################################################################
if ((($gFAMILY eq "Stratix" or $gFAMILY eq "Stratix II") and $gENABLE_CAPTURE_CLK ne "true") or $gREGTEST_ADD_DLL_PORTS == 1)
{
    $module->add_contents
    (

        e_port->new({comment =>"Stratix only",name => "dqs_delay_ctrl",direction => "input",width =>6,declare_one_bit_as_std_logic_vector => 1}),# $stratix_verilog_ports1 & $stratix_verilog_ports2 in the generator
        #e_parameter->add({name => "gDLL_INPUT_FREQUENCY", default => "${gCLOCK_PERIOD_IN_PS}ps", vhdl_type => "string"}),
        #e_parameter->add({name => "gSTRATIX_DQS_PHASE", default => $gDQS_PHASE_SHIFT, vhdl_type => "string"}),
    );#

    $Stratix_Fam = "dqs_delay_ctrl",
}else
{
    $Stratix_Fam = "",
}
my %stratisII_param;
my @stratisII_param;
my %dqsupdate;
my @dqsupdate;
my @dqsupdate_list;
my %dqsupdate_param;
my @dqsupdate_param;
my @dqsupdate_param_list;
if (($gFAMILY eq "Stratix II") and ($gENABLE_CAPTURE_CLK ne "true")) {
    if (($gBUFFER_DLL_DELAY_OUTPUT ne "true") and ($gDLL_REF_CLOCK__SWITCHED_OFF_DURING_READS ne "true"))
    {
	$dqsupdate{'dqsupdateen'} = "dqsupdate";
	$dqsupdate_param{'dqs_ctrl_latches_enable'} = "\"true\"";
	$module->add_contents(e_port->new({name=>"dqsupdate",direction=>"input",width=>1}),);
    }
}
@dqsupdate = %dqsupdate;
foreach my $param(@dqsupdate)
{
	print "->".$param."\n";
	push (@dqsupdate_list, $param);
}
#
@dqsupdate_param = %dqsupdate_param;
foreach my $params(@dqsupdate_param)
{
	print "->".$params."\n";
	push (@dqsupdate_param_list, $params);
}

if ($insert_configurable_resynch_edge_logic eq "true") {
    $module->add_contents
    (
        e_signal->new(["fedback_resynched_data_other_edge",$gMEM_DQ_PER_DQS * 2,   0,  1]),
        e_signal->new(["resynched_data_other_edge",$gMEM_DQ_PER_DQS * 2,   0,  1]),
        #e_signal->new(["select_opposite_resynch_edge", 1, 0, 1]),
    )        
}
if ($gFAMILY eq "Stratix II")
{
    # Stratix II only
    #%stratix_param = ("gDLL_INPUT_FREQUENCY", $gdll_input_frequency, "gSTRATIXII_DQS_PHASE", $gstratixii_dqs_phase,"gSTRATIXII_DLL_DELAY_BUFFER_MODE", $gstratixii_dll_delay_buffer_mode,"gSTRATIXII_DQS_OUT_MODE", $gstratixii_dqs_out_mode);
    my $gDLL_INPUT_FREQUENCY = "${gCLOCK_PERIOD_IN_PS}ps";
    my $gSTRATIXII_DQS_PHASE                = ${gSTRATIXII_DQS_PHASE_SHIFT}; # 9000/100 "90 degrees",  7200/100 "72 degrees"
    my $gSTRATIXII_DLL_DELAY_BUFFER_MODE    = "${gSTRATIXII_DLL_DELAY_BUFFER_MODE}";
    my $gSTRATIXII_DQS_OUT_MODE             = "${gSTRATIXII_DQS_OUT_MODE}";
    $module->vhdl_libraries()->{stratixii} = all;
    $module->add_contents
    (
        e_parameter->add({name => "gDLL_INPUT_FREQUENCY", default => "${gCLOCK_PERIOD_IN_PS}ps", vhdl_type => "string"}),
        e_parameter->add({name => "gSTRATIXII_DQS_PHASE", default => $gSTRATIXII_DQS_PHASE_SHIFT, vhdl_type => "natural"}),
        e_parameter->add({name => "gSTRATIXII_DLL_DELAY_BUFFER_MODE", default => $gSTRATIXII_DLL_DELAY_BUFFER_MODE, vhdl_type => "string"}),
        e_parameter->add({name => "gSTRATIXII_DQS_OUT_MODE", default => $gSTRATIXII_DQS_OUT_MODE, vhdl_type => "string"}),
        e_signal->new(["fedback_resynched_data",$gMEM_DQ_PER_DQS * 2,   0,  1]),
    );
    
    if ($gENABLE_CAPTURE_CLK ne "true") # DQS mode
    {
        $module->add_contents
        (
            e_lpm_stratixii_io->new # DQS mode, Stratix II, DQS pin, simulation
            ({
                name        => "dqs_io",
                module      => "stratixii_io",
                comment     => "DQS pin, Stratix II, DQS mode, simulation",
                tag         => "simulation", # Simulation version
                port_map    =>
                {
                    areset          => "$std_logic1", # Disable postamble control logic in simulation
                    datain          => "dqs_oe_r[0:0]",
                    ddiodatain      => "ZEROS[0]",
                    outclk          => "clk",
                    outclkena       => "$std_logic1",
                    oe              => "dqs_oe",
                    inclk           => "not_dqs_clk[0]",
                    inclkena        => "$std_logic1",
                    delayctrlin     => "dqs_delay_ctrl",
                    combout         => "undelayed_dqs[0]",
                    dqsbusout       => "dqs_clk[0]",
                    padio           => "ddr_dqs",
		    @dqsupdate	=>	@dqsupdate_list,
                },
                std_logic_vector_signals =>
                [
                    delayctrlin,
                ],
                parameter_map   =>
                {
		    @dqsupdate_param	=>	@dqsupdate_param_list,
                    ddio_mode => '"output"',
                    ddioinclk_input  =>'"inclk"',
                    dqs_delay_buffer_mode => gSTRATIXII_DLL_DELAY_BUFFER_MODE,
                    dqs_edge_detect_enable => '"false"',
                    dqs_input_frequency => gDLL_INPUT_FREQUENCY,
                    dqs_offsetctrl_enable => '"false"',
                    dqs_out_mode => gSTRATIXII_DQS_OUT_MODE,
                    dqs_phase_shift => $gSTRATIXII_DQS_PHASE,
                    extend_oe_disable => '"true"',
                    gated_dqs => '"true"',
                    inclk_input => '"dqs_bus"',
                    input_async_reset => '"preset"',
                    input_power_up => '"high"',
                    input_register_mode => '"register"',
                    input_sync_reset => '"clear"',
                    oe_register_mode => '"register"',
                    operation_mode => '"bidir"',
                    output_register_mode => '"register"',
                    sim_dqs_delay_increment => 36,
                    sim_dqs_intrinsic_delay => 900,
                    sim_dqs_offset_increment => 0,
                },
            }),
            e_lpm_stratixii_io->new # DQS mode, Stratix II, DQS pin, synthesis
            ({
                name        => "dqs_io",
                module      => "stratixii_io",
                comment     => "DQS pin, Stratix II, DQS mode, synthesis",
                tag     => "synthesis", # Synthesis version
                port_map    =>
                {
                    datain      => "dqs_oe_r[0:0]",
                    ddiodatain  => "ZEROS[0]",
                    outclk      => "clk",
                    outclkena   => "$std_logic1",
                    oe          => "dqs_oe",
                    inclk       => "not_dqs_clk[0]",
                    inclkena    => "$std_logic1",
                    areset      => "dq_enable_reset[0]", # Postamble control logic in synthesis only
                    sreset      => "$std_logic1",
                    delayctrlin => "dqs_delay_ctrl",
                    ddioregout  => "open",
                    regout      => "open",
                    combout     => "undelayed_dqs[0]",
                    dqsbusout   => "dqs_clk[0]",
                    padio       => "ddr_dqs",
                    @dqsupdate	=>	@dqsupdate_list,
                },
                std_logic_vector_signals =>
                [
                    delayctrlin,
                ],
                parameter_map   =>
                {
                    @dqsupdate_param	=>	@dqsupdate_param_list,
                    ddio_mode => '"output"',
                    ddioinclk_input  =>'"negated_inclk"',
                    dqs_delay_buffer_mode => gSTRATIXII_DLL_DELAY_BUFFER_MODE,
                    dqs_edge_detect_enable => '"false"',
                    dqs_input_frequency => gDLL_INPUT_FREQUENCY,
                    dqs_offsetctrl_enable => '"false"',
                    dqs_out_mode => gSTRATIXII_DQS_OUT_MODE,
                    dqs_phase_shift => $gSTRATIXII_DQS_PHASE,
                    extend_oe_disable => '"true"',
                    gated_dqs => '"true"',
                    inclk_input => '"dqs_bus"',
                    input_async_reset => '"preset"',
                    input_power_up => '"high"',
                    input_register_mode => '"register"',
                    input_sync_reset => '"clear"',
                    oe_register_mode => '"register"',
                    operation_mode => '"bidir"',
                    output_register_mode => '"register"',
                    sim_dqs_delay_increment => 36,
                    sim_dqs_intrinsic_delay => 900,
                    sim_dqs_offset_increment => 0,
                },

            }),
        );

    } else # non_dqs mode
    {
        $module->add_contents
        (
            e_lpm_stratixii_io->new # non-DQS mode, Stratix II, DQS pin
            ({
                name        => "dqs_io",
                module      => "stratixii_io",
                comment     => "DQS pin, Stratix II, non-DQS mode",
                #tag     => "synthesis",
                port_map    =>
                {
                    datain      => "dqs_oe_r[0:0]",
                    ddiodatain  => "ZEROS[0]",
                    outclk      => "clk",
                    outclkena   => "$std_logic1",
                    oe          => "dqs_oe",
                    ddioregout  => "open",
                    combout     => "open",
                    regout      => "open",
                    padio       => "ddr_dqs",
                },
                parameter_map   =>
                {
                    ddio_mode => '"output"',
                    extend_oe_disable => '"true"',
                    oe_register_mode => '"register"',
                    operation_mode => '"bidir"',
                    output_register_mode => '"register"',

                    dqs_input_frequency => '"none"',
                    dqs_delay_buffer_mode => '"none"',
                },
            }),
        );
    }
} elsif ($gFAMILY eq "Stratix")
{
# Stratix only
    my $gDLL_INPUT_FREQUENCY = "${gCLOCK_PERIOD_IN_PS}ps";
        my $gSTRATIX_DQS_PHASE = "${gDQS_PHASE_SHIFT}";#       //  "90" degrees,

    $module->vhdl_libraries()->{stratix} = all;
    $module->add_contents
    (
        e_parameter->add({name => "gDLL_INPUT_FREQUENCY", default => "${gCLOCK_PERIOD_IN_PS}ps", vhdl_type => "string"}),
        e_parameter->add({name => "gSTRATIX_DQS_PHASE", default => $gDQS_PHASE_SHIFT, vhdl_type => "string"}),
    );
    $module->add_contents
    (
    e_signal->new({name =>"stratix_dqs_delay_buffers",width => $gSTRATIX_UNDELAYEDDQSOUT_INSERT_BUFFERS+1,export =>0,never_export => 1,declare_one_bit_as_std_logic_vector => 1}),
    );

    if ($gENABLE_CAPTURE_CLK ne "true") # DQS mode
    {
        $module->add_contents
        (
            e_lpm_stratix_io->new # DQS pin, Stratix, DQS mode
            ({
                name        => "dqs_io",
                module      => "stratix_io",
                comment     => "DQS pin, Stratix, DQS mode",
                # tag         => "simulation",
                port_map    =>
                {
                    oe                => "dqs_oe",
                    outclk            => "clk",
                    outclkena         => "$std_logic1",
                    datain            => "dqs_oe_r[0]",
                    ddiodatain        => "ZEROS[0]",
                    delayctrlin       => "dqs_delay_ctrl[0]",

                    combout           => "dqs_clk[0]",
                    ddioregout        => "open",
                    dqsundelayedout   => "undelayed_dqs[0]",
                    regout            => "open",
                    padio             => "ddr_dqs",#"ddr_dqs[0]",
                },
                parameter_map   =>
                {
                    ddio_mode                     => '"output"',
                    extend_oe_disable             => '"true"',
                    oe_register_mode              => '"register"',
                    operation_mode                => '"bidir"',
                    output_register_mode          => '"register"',
                    sim_dll_phase_shift           => gSTRATIX_DQS_PHASE,
                    sim_dqs_input_frequency       => gDLL_INPUT_FREQUENCY,
                },
            }),
        );

    } else # non-DQS mode
    {
        $module->add_contents
        (
            e_lpm_stratix_io->new # DQS pin, Stratix, non-DQS mode
            ({
                name        => "dqs_io",
                comment => "DQS pin, Stratix, non-DQS mode",
                module      => "stratix_io",
                # tag         => "synthesis",
                port_map    =>
                {
                    oe                => "dqs_oe",
                    outclk            => "clk",
                    outclkena         => "$std_logic1",
                    datain            => "dqs_oe_r[0]",
                    ddiodatain        => "ZEROS[0]",
                    combout           => "dqs_clk[0]",
                    dqsundelayedout   => "undelayed_dqs[0]",
                    ddioregout        => "open",
                    regout            => "open",
                    padio             => "ddr_dqs",#"ddr_dqs[0]",
                },
                parameter_map   =>
                {
                    ddio_mode                     => '"output"',
                    extend_oe_disable             => '"true"',
                    oe_register_mode              => '"register"',
                    operation_mode                => '"bidir"',
                    output_register_mode          => '"register"',
                },
            }),
        );
    }
} elsif ($gFAMILY eq "Cyclone")
{

    $module->add_contents
    (
        e_lpm_altddio_bidir->new # DQS pin, Cyclone, DQS mode
        ({
            name        => "dqs_io",
            module      => "altddio_bidir",
            comment     => "DQS pin, Cyclone, DQS mode",
            port_map    =>
            {
                inclocken   => "$std_logic1",
                inclock     => "$std_logic1",
                aclr        => "reset",
                datain_h    => "dqs_oe_r[0]",
                datain_l    => "ZEROS[0:0]",
                oe          => "dqs_oe",
                outclock    => "clk",
                outclocken  => "$std_logic1",
                 combout     => "dqs_clk[0]",
                padio       => "ddr_dqs",#"ddr_dqs[0]",
            },
            parameter_map   =>
            {
                width                       => 1,
                intended_device_family      => '"Cyclone"',
                oe_reg                      => '"REGISTERED"',
                extend_oe_disable           => '"ON"',
            },
        }),
    );
} elsif ($gFAMILY eq "Cyclone II")
{
    my $gDLL_INPUT_FREQUENCY = $gDQS_CRAM_CYCLONE;
    $module->vhdl_libraries()->{cycloneii} = all;
    $module->add_contents
    (
        e_signal->new({name => "wire_dqs_clkctrl_outclk",width =>  1,export => 0,never_export => 1,declare_one_bit_as_std_logic_vector => 1}),
        e_signal->new({name => "delayed_dqs",width =>  4,export => 0,never_export => 1,declare_one_bit_as_std_logic_vector => 0}),
        e_signal->new({name => "dqs_oe_vector",width =>  1,export => 0,never_export => 1,declare_one_bit_as_std_logic_vector => 1}),

        e_assign->new(["dqs_oe_vector[0:0]" , "dqs_oe"]),

        # gate off the DQS at the end of a write burst to improve tWPST
        e_assign->new
        ({
            lhs => "dqs_twpst_ctrl",
            rhs => "(dqs_oe_vector & dqs_oe_r)",
            comment =>"Gate off the DQS at the end of a write burst to improve tWPST"
        }),

        e_comment->new({comment => "\n"}),
        e_lpm_altddio_bidir->new # DQS pin, Cyclone II, DQS mode
        ({
            name        => "dqs_io",
            module      => "altddio_bidir",
            comment     => "DQS pin, Cyclone II, DQS mode",
            port_map    =>
            {
                inclocken   => "$std_logic1",
                inclock     => "$std_logic1",
                aclr        => "reset",
                datain_h    => "dqs_twpst_ctrl[0]",#"dqs_oe_r[0]",
                datain_l    => "ZEROS[0:0]",
                oe          => "dqs_oe",
                outclock    => "clk",
                outclocken  => "$std_logic1",
                 combout     => "dqs_clk[0]",
                padio       => "ddr_dqs",#"ddr_dqs[0]",
            },
            parameter_map   =>
            {
                width                       => 1,
                intended_device_family      => '"Cyclone II"',
                oe_reg                      => '"REGISTERED"',
                extend_oe_disable           => '"ON"',
            },
        }),
        e_blind_instance->new
        ({
            name        => "dqs_delay_ctrl",
            module      => "cycloneii_clk_delay_ctrl",
            comment     => "Cyclone II clock delay control",
            in_port_map     =>
            {
                clk => "dqs_clk[0]",
            },
            out_port_map    =>
            {
                clkout  => "delayed_dqs[0]",#"wire_dqs_delay_ctrl_clkout[0]",
            },
            parameter_map   =>
            {
                delay_chain         => '"'.$gDLL_INPUT_FREQUENCY.'"',#$CYCLONE2_DQS_DELAY
                delay_chain_mode    => '"static"',
                lpm_type                => '"cycloneii_clk_delay_ctrl"',
            },
        }),

            e_assign->new(["delayed_dqs[3:1]" , "{1'b0,1'b0,1'b0}"]),

            e_blind_instance->new # synthesis version - include postamble control logic
            ({
                name        => "dqs_clkctrl",
                module      => "cycloneii_clkctrl",
                comment     => "Cyclone II clock control",
                tag     => "synthesis",            
                in_port_map     =>
                {
                    clkselect   => "2'b00",
                    ena     => "dq_enable[0]",
                    inclk       => "delayed_dqs",
                },
                out_port_map    =>
                {
                    outclk      => "wire_dqs_clkctrl_outclk[0]",
                },
                parameter_map   =>
                {
                    ena_register_mode       => '"none"',
                    lpm_type                => '"cycloneii_clkctrl"',
                },

            }),

            e_blind_instance->new # simulation version - does NOT include postamble control logic
            ({
                name        => "dqs_clkctrl",
                module      => "cycloneii_clkctrl",
                comment     => "Cyclone II clock control",
                tag     => "simulation",            
                in_port_map     =>
                {
                    clkselect   => "2'b00",
                    ena     => "$std_logic1", #"dq_enable[0]",
                    inclk       => "delayed_dqs",
                },
                out_port_map    =>
                {
                    outclk      => "wire_dqs_clkctrl_outclk[0]",
                },
                parameter_map   =>
                {
                    ena_register_mode       => '"none"',
                    lpm_type                => '"cycloneii_clkctrl"',
                },

            }),
            
    );
}
##################################################################################################################################################################
    $module->add_contents
    (
        e_comment->new({comment     =>
            "-----------------------------------------------------------------------------\n
             DM pins and their logic\n\n
             Although these don't get tristated like DQ, they do share the same IO timing.\n
            -----------------------------------------------------------------------------"}),
        e_assign->new([["tmp_dmout0",1],"dm_out[0]"]),
        e_assign->new([["tmp_dmout1",1],"dm_out[1]"]),
        e_lpm_altddio_out->new
        ({
            name        => "dm_pin",
            module      => "altddio_out",
            port_map    =>
            {
                aclr        => "reset",
                datain_h    => "tmp_dmout0",
                datain_l    => "tmp_dmout1",
                oe          => "$std_logic1",
                outclock    => "write_clk",
                outclocken  => "$std_logic1",
                dataout     => "ddr_dm",
            },
            parameter_map   =>
            {
                width                   => 5,
                intended_device_family  => '"'.$gFAMILY.'"',
            },
        }),
    );
    if(($gLOCAL_BURST_LEN == 1) and  ($gLOCAL_AVALON_IF ne "true"))
    {
        $module->add_contents
        (
            e_process->new
            ({
                 clock          =>  "clk",
                 reset          =>  "reset_n",
                 comment            =>
                 "-----------------------------------------------------------------------------\n
                   Data mask registers\n
                   \nThese are the last registers before the registers in the altddio_out. They\n
                   are clocked off the system clock but feed registers which are clocked off the\n
                   write clock, so their output is the beginning of 3/4 cycle path.\n
                  -----------------------------------------------------------------------------",
                 _asynchronous_contents =>
                 [
                e_assign->new(["be_r" => "{2{1'b0}}"]),
                 ],
                 contents   =>
                 [
                e_if->new
                ({
                    condition   => "wdata_valid",
                    then        =>
                    [
                    e_assign->new({lhs => "be_r",rhs => "~be",comment =>" don't latch in data unless it's valid"}),
                    ],
                }),
                 ],
            }),
            e_process->new
            ({
                 clock          =>  "",
                 reset          =>  "",
                 comment            =>
                 "-----------------------------------------------------------------------------\n
                   Hold DM output at 1 unless actually doing a write\n
                   This logic should pack into the same LE as be_r\n
                  -----------------------------------------------------------------------------",
                 sensitivity_list       =>["be_r","doing_wr_r"],
                 contents   =>
                 [
                e_if->new
                ({
                    condition   => "doing_wr_r",
                    then        => [ e_assign->new({lhs => "dm_out",rhs => "be_r"}), ],
                    else        => [ e_assign->new({lhs => "dm_out",rhs => "{2{1'b1}}"}), ],
                }),
                 ],
            }),
        );
    }else{
        $module->add_contents
        (
            e_process->new
            ({
                 clock          =>  "clk",
                 reset          =>  "reset_n",
                 comment            =>
                 "-----------------------------------------------------------------------------\n
                   Data mask registers\n
                   \nThese are the last registers before the registers in the altddio_out. They\n
                   are clocked off the system clock but feed registers which are clocked off the\n
                   write clock, so their output is the beginning of 3/4 cycle path.\n
                  -----------------------------------------------------------------------------",
                 _asynchronous_contents =>
                 [
                e_assign->new(["dm_out" => "{2{1'b1}}"]),
                 ],
                 contents   =>
                 [
                e_if->new
                ({
                    condition   => "doing_wr",
                    then        =>
                    [
                    e_assign->new({lhs => "dm_out",rhs => "~be",comment =>" don't latch in data unless it's valid"}),
                    ],
                    else        =>
                    [
                        e_assign->new(["dm_out" => "{2{1'b1}}"]),
                    ],
                }),
                 ],
            }),
        );
    }
    $module->add_contents
    (
        e_comment->new({comment =>"-----------------------------------------------------------------------------\n
                       Logic to disable the capture registers (particularly during DQS postamble)\n

                       The output of the dq_enable_reset register holds the dq_enable register in\n
                       reset (which *enables* the dq capture registers). The controller releases\n
                       the dq_enable register so that it is clocked by the last falling edge of the\n
                       read dqs signal. This disables the dq capture registers during and after the\n
                       dqs postamble so that the output of the dq capture registers can be safely\n
                       resynchronised.\n
                       Postamble Clock Cycle  : $gPOSTAMBLE_CYCLE
                       Postamble Clock Edge   : $gPOSTAMBLE_EDGE
                       Postamble Regs Per DQS : $gPOSTAMBLE_REGS
                      -----------------------------------------------------------------------------\n"
        }),
    );
##################################################################################################################################################################
if ($gENABLE_POSTAMBLE_LOGIC eq "true")
{
    for ($i=0; $i < $gPOSTAMBLE_REGS; $i++)
    {
        if ($gFAMILY ne "Stratix II")
        {
            $module->add_contents
            (
                e_process->new
                ({
                     clock          =>  "dqs_postamble_clk",
                     reset          =>  "dq_enable_reset[$i]",
                     reset_level        =>  1,
                     comment            =>
                     "Critical registers clocked on the falling edge of the DQS to\n
                      disable the DQ capture registers during the DQS postamble",
                     _asynchronous_contents =>
                     [
                    e_assign->new(["dq_enable[$i]" => "1'b1"]),
                     ],
                     contents   =>
                     [
                        e_assign->new(["dq_enable[$i]" => "1'b0"]),
                     ],
                }),
            );
        }
        if ($gPOSTAMBLE_EDGE eq "rising")
        {
            $module->add_contents
            (
                e_process->new
                ({
                     clock          =>  "postamble_clk",
                     reset          =>  "reset_n",
                     comment            =>
                     "Use a rising edge for postamble\n
                      The registers which generate the reset signal to the above registers\n
                      Can be clocked off the resynch or system clock",
                     _asynchronous_contents =>
                     [
                    e_assign->new(["dq_enable_reset[$i]" => "1'b0"]),
                     ],
                     contents   =>
                     [
                        e_assign->new(["dq_enable_reset[$i]" => "doing_rd_delayed"]),
                     ],
                }),
            );
        }else
        {
            $module->add_contents
            (
                e_process->new
                ({
                     clock          =>  "postamble_clk",
                     reset          =>  "reset_n",
                     clock_level        =>  0,
                     comment            =>
                     "Use a falling edge for postamble\n
                      The registers which generate the reset signal to the above registers\n
                      Can be clocked off the resynch or system clock",
                     _asynchronous_contents =>
                     [
                    e_assign->new(["dq_enable_reset[$i]" => "1'b0"]),
                     ],
                     contents   =>
                     [
                        e_assign->new(["dq_enable_reset[$i]" => "doing_rd_delayed"]),
                     ],
                }),
            );
        }
    }
##################################################################################################################################################################
    $module->add_contents
    (
        e_process->new
        ({
             clock          =>  "clk",
             reset          =>  "reset_n",
             comment            =>
             "pipeline the doing_rd signal to enable and disable the DQ capture regs at the right time",
             _asynchronous_contents =>
             [
            e_assign->new(["doing_rd_pipe" => "0"]),
             ],
             contents   =>
             [
                e_assign->new({lhs => "doing_rd_pipe", rhs => "{doing_rd_pipe[".$gPOSTAMBLE_CYCLE.":"."0], doing_rd}",comment => "shift bits up"}),
             ],
        }),

    );
##################################################################################################################################################################

    if ($gINTER_POSTAMBLE ne "true")
    {
        $module->add_contents
        (
            e_process->new
            ({
                 clock          =>  "clk",
                 reset          =>  "reset_n",
                 clock_level        =>  0,
                 comment            =>
                 "It's safe to clock from falling edge of clk to postamble_clk, so use falling edge clock",
                 _asynchronous_contents =>
                 [
                e_assign->new(["doing_rd_delayed" => "1'b0"]),
                 ],
                 contents   =>
                 [
                e_assign->new({lhs => "doing_rd_delayed", rhs => "doing_rd_pipe[$gPOSTAMBLE_CYCLE]"}),
                 ],
            }),
        );
    }else
    {
        $module->add_contents
        (
            e_process->new
            ({
                 clock          =>  "clk",
                 reset          =>  "reset_n",
                 clock_level        =>  1,
                 comment            =>
                 "It's unfortunately not safe to clock from falling edge of clk to postamble_clk, so use rising edge",
                 _asynchronous_contents =>
                 [
                e_assign->new(["doing_rd_delayed" => "1'b0"]),
                 ],
                 contents   =>
                 [
                e_assign->new({lhs => "doing_rd_delayed", rhs => "doing_rd_pipe[$gPOSTAMBLE_CYCLE]"}),
                 ],
            }),
        );
    }
##################################################################################################################################################################
    if ($gFAMILY eq "Stratix")
    {
        my $undelayed_dqs_phase_shift = int(($gCLOCK_PERIOD_IN_PS * (90 +30)) / 360);
        $module->add_contents
        (
            e_assign->new
            ({
                #lhs => "#($undelayed_dqs_phase_shift) dqs_postamble_clk"
                lhs => "dqs_postamble_clk",
                rhs => "~stratix_dqs_delay_buffers[0]",
                sim_delay => $undelayed_dqs_phase_shift,
                comment => "-----------------------------------------------------------------------------\n
                Decide which clock to use for the DQ enable register\sn
                \n
                Since Stratix needs to use the undelayed DQS, it may be necessary to insert\n
                some buffers in its path.\n
                \n
                DQS Delay Buffers Inserted : 0\n
                \n
                -----------------------------------------------------------------------------",
            }),
            e_assign->new({lhs => "stratix_dqs_delay_buffers[$gSTRATIX_UNDELAYEDDQSOUT_INSERT_BUFFERS]", rhs => "undelayed_dqs[0]"}),
        );

        for ($i=1; $i<=$gSTRATIX_UNDELAYEDDQSOUT_INSERT_BUFFERS; $i++)
        {

            $module->add_contents
            (
                e_comment->new({comment =>"RTL version is different to synthesis version...\nsynthesis translate_off"}),
                e_assign->new
                ({
                    lhs => "stratix_dqs_delay_buffers[$i-1]",

                    rhs => "stratix_dqs_delay_buffers[$i]",
                }),

                e_comment->new({comment =>"synthesis translate_on\n"}),
                #e_comment->new({comment =>"RTL version is different to synthesis version...\n"}),
                e_blind_instance->new
                ({
                    tag     => "synthesis",
                    name        => "dqs_buf$i",
                    module      => "stratix_lcell",
                    in_port_map =>
                    {
                        datad   => "stratix_dqs_delay_buffers[$i]",
                    },
                    out_port_map    =>
                    {
                        combout => "stratix_dqs_delay_buffers[$i-1]",

                    },
                    parameter_map   =>

                    {
                        operation_mode  => '"normal"',
                        lut_mask    => '"ff00"',
                    }
                }),
            );

        }
    }elsif (($gFAMILY eq "Cyclone") or ($gFAMILY eq "Cyclone II"))

    {
        $module->add_contents
        (
            e_assign->new({lhs => "dqs_postamble_clk", rhs => "dq_capture_clk", comment => "This copes with DQS mode"}),
        );
    }
}else # else disable postamble
{
    $module->add_contents
    (
        e_assign->new
        ({
            lhs => "dq_enable[".($gPOSTAMBLE_REGS -1).":0]",
            rhs => "{".$gPOSTAMBLE_REGS."{1'b1}}",
            comment => " hold high so capture regs are always enabled"
        }),
        e_assign->new({lhs => "dq_enable_reset[".($gPOSTAMBLE_REGS -1).":0]", rhs => "{".$gPOSTAMBLE_REGS."{1'b1}}", comment => " hold high so capture regs are always enabled"}),
    );
}
##################################################################################################################################################################
if ($gENABLE_CAPTURE_CLK ne "true")
{
    if($gFAMILY eq "Cyclone II")
    {
        $module->add_contents
        (
            e_assign->new
            ({
                lhs => "dq_capture_clk",
                rhs => "~wire_dqs_clkctrl_outclk[0]",
                comment => "-----------------------------------------------------------------------------\n
                         Decide which clock to use for capturing the DQ data\n
                        -----------------------------------------------------------------------------\n
                         Use DQS to capture DQ read data",

            }),
        );
    }else{ # not Cyclone II
        $module->add_contents
        (
            e_assign->new
            ({
                lhs => "dq_capture_clk",
                rhs => "~dqs_clk[0]",
                comment => "-----------------------------------------------------------------------------\n
                         Decide which clock to use for capturing the DQ data\n
                        -----------------------------------------------------------------------------\n
                         Use DQS to capture DQ read data",
            }),
        );
    }

}else # non-DQS mode
{
    # un-delay the non-DQS mode clock because the RTD model is *after* the capture regs now
    # Take the fractional part of the rtd, take away 1, then add this delay to the clock;
    # Eg rtd = 1.25 clocks, so add 0.75 delay to the clock to make it line up again
    # Uses 4* and %4 to extract the number of 1/4 clock cycles involved
    my $nondqs_capture_clk_delay = (4 * (1-$gRTL_ROUNDTRIP_CLOCKS) % 4);
    
    # print "Un-delaying the non-DQS mode capture clock by $nondqs_capture_clk_delay delays.\n";
    
        
    if ($nondqs_capture_clk_delay > 0) {
        
        $module->add_contents (e_assign->new({ lhs => "capture_clk_delayed_0", rhs => "capture_clk",}),);

        for ($x=0; $x < ($nondqs_capture_clk_delay); $x++) {            
            $module->add_contents
                (
                   e_assign->new ({ lhs => "capture_clk_delayed_".($x+1), rhs => "capture_clk_delayed_".($x), sim_delay => ($gCLOCK_PERIOD_IN_PS / 4),}),
                );                        
        }
        # connect up the last one
        $module->add_contents
        (
           e_assign->new 
           ({ 
                lhs => "dq_capture_clk", 
                rhs => "~capture_clk_delayed_".($nondqs_capture_clk_delay), 
                comment => "-----------------------------------------------------------------------------\n
                           Decide which clock to use for capturing the DQ data\n
                           -----------------------------------------------------------------------------\n
                           Use an external, user supplied capture clock (ie Non-DQS mode)",
           }),
        );
    } else { # as it was before
        $module->add_contents
        (
           e_assign->new 
           ({ 
               lhs => "dq_capture_clk", 
               rhs => "~capture_clk", 
               comment => "-----------------------------------------------------------------------------\n
                           Decide which clock to use for capturing the DQ data\n
                           -----------------------------------------------------------------------------\n
                           Use an external, user supplied capture clock (ie Non-DQS mode)",
           }),
        );
    }
         
}
##################################################################################################################################################################
    $module->add_contents
    (
            e_process->new
            ({
                 clock          =>  "clk",
                 reset          =>  "reset_n",
                 comment            =>
                 "-----------------------------------------------------------------------------\n
                  DQ pins and their logic
                  -----------------------------------------------------------------------------",
                 _asynchronous_contents => [ e_assign->new(["dq_oe" => "1'b0"]), ],
                 contents               => [ e_assign->new({lhs => "dq_oe", rhs => "doing_wr"}), ],
            }),

    );
##################################################################################################################################################################

# Create DQ pins

##################################################################################################################################################################

for ($i=0; $i < $gMEM_DQ_PER_DQS; $i++)
{
    if ($language eq "vhdl") {
        $dqs_group_instname = "\\g_dq_io\:$i\:dq_io\\";#"g_dq_io_".$i."_dq_io";
    } else {
        $dqs_group_instname = "\\g_dq_io\:$i\:dq_io ";#"g_dq_io_".$i."_dq_io";
    }
    my $wdata_r = $i + $gMEM_DQ_PER_DQS;

    if ($gFAMILY eq "Stratix II")
    {
        if ($gENABLE_CAPTURE_CLK ne "true")
            {
                $module->add_contents
                (
                    e_lpm_stratixii_io->new # DQS Mode, Stratix II DQ pin
                    ({
                        name        => $dqs_group_instname,
                        module      => stratixii_io,
                        suppress_open_ports   => 1,
                        # tag     => "synthesis",
                        port_map    =>
                        {
                            areset          => "reset",
                            datain          => "wdata_r[$i]",
                            ddiodatain      => "wdata_r[".$wdata_r."]",
                            inclkena        => "$std_logic1",
                            inclk           => "dq_capture_clk",
                            outclkena       => "$std_logic1",
                            outclk          => "write_clk",
                            oe              => "dq_oe",
                            ddioinclk       => "ZEROS[0]",
                            padio           => "ddr_dq[$i]",
                            ddioregout      => "dq_captured_rising[$i]",
                            regout          => "dq_captured_falling[$i]",
                        },
                        std_logic_vector_signals =>
                        [
                            delayctrlin,
                        ],
                        parameter_map   =>
                        {
                            ddio_mode            => '"bidir"',
                            ddioinclk_input      => '"negated_inclk"',
                            extend_oe_disable    => '"false"',
                            inclk_input          => '"dqs_bus"',
                            input_async_reset    => '"clear"',
                            input_power_up       => '"low"',

                            input_register_mode  => '"register"',
                            oe_async_reset       => '"clear"',

                            oe_power_up          => '"low"',
                            oe_register_mode     => '"register"',
                            operation_mode       => '"bidir"',
                            output_async_reset   => '"clear"',
                            output_power_up      => '"low"',
                            output_register_mode => '"register"',

                            dqs_input_frequency  =>  '"none"',
                            dqs_delay_buffer_mode  =>  '"none"',

                        },
                    }),
                );
             }

             else # non-DQS Mode, Stratix II DQ pin
             {

                 $module->add_contents
                 (
                    e_lpm_stratixii_io->new # non-DQS Mode, Stratix II DQ pin
                     ({
                         name       => $dqs_group_instname,
                         module         => stratixii_io,
                         suppress_open_ports    => 1,
                         # tag        => "synthesis",
                         in_port_map    =>
                         {
                             areset          => "reset",
                             datain          => "wdata_r[$i]",
                             ddiodatain      => "wdata_r[".$wdata_r."]",
                             inclkena        => "$std_logic1",
                             inclk           => "dq_capture_clk",
                             outclkena       => "$std_logic1",
                             outclk          => "write_clk",
                             oe              => "dq_oe",
                             padio           => "ddr_dq[$i]",
                             ddioregout  => "dq_captured_rising[$i]",
                             regout      => "dq_captured_falling[$i]",
                         },
                         parameter_map  =>
                         {
                             ddio_mode            => '"bidir"',
                             ddioinclk_input      => '"negated_inclk"',
                             extend_oe_disable    => '"false"',
                             inclk_input          => '"normal"',
                             input_async_reset    => '"clear"',
                             input_power_up       => '"low"',
                             input_register_mode  => '"register"',
                             oe_async_reset       => '"clear"',
                             oe_power_up          => '"low"',
                             oe_register_mode     => '"register"',
                             operation_mode       => '"bidir"',

                             output_async_reset   => '"clear"',
                             output_power_up      => '"low"',

                             output_register_mode => '"register"',

                             dqs_input_frequency => '"none"',
                             dqs_delay_buffer_mode => '"none"',

                         },
                     }),
                 );
             }
    }elsif ($gFAMILY eq "Stratix")
    {
        my $value = int $i * $gPOSTAMBLE_REGS / $gMEM_DQ_PER_DQS;
        $module->add_contents
        (
            e_lpm_stratix_io->new # Stratix DQ pin, DQS mode, synthesis
            ({
                name        => $dqs_group_instname, #
                module      => stratix_io,
                tag         => "synthesis",
                in_port_map =>
                {
                    inclkena   =>  "dq_enable[".$value."]", # Postamble control for synthesis
                    areset      => "reset",
                    datain      => "wdata_r[$i]",
                    ddiodatain  => "wdata_r[$wdata_r]",
                    inclk       => "dq_capture_clk",
                    oe          => "dq_oe",
                    outclkena   => "$std_logic1",
                    outclk      => "write_clk",
                    ddioregout  => "dq_captured_rising[$i]",
                    regout      => "dq_captured_falling[$i]",
                    padio       => "ddr_dq[$i]",
                },
                parameter_map   =>
                {
                    ddio_mode               => '"bidir"',
                    input_async_reset       => '"clear"',
                    input_register_mode     => '"register"',
                    oe_async_reset          => '"clear"',
                    oe_register_mode        => '"register"',
                    operation_mode          => '"bidir"',
                    output_async_reset      => '"clear"',
                    output_register_mode    => '"register"',
                },
            }),
            e_lpm_stratix_io->new # Stratix DQ pin, DQS mode, simulation
            ({
                name        => $dqs_group_instname,
                module      => stratix_io,
                tag         => "simulation",
                port_map    =>
                {
                    inclkena    => "$std_logic1", # Disable postamble control in simulation
                    areset      => "reset",
                    datain      => "wdata_r[$i]",
                    ddiodatain  => "wdata_r[$wdata_r]",
                    inclk       => "dq_capture_clk",
                    oe          => "dq_oe",
                    outclkena   => "$std_logic1",
                    outclk      => "write_clk",
                    ddioregout  => "dq_captured_rising[$i]",
                    regout      => "dq_captured_falling[$i]",
                    padio       => "ddr_dq[$i]",
                },
                parameter_map   =>
                {
                    ddio_mode               => '"bidir"',
                    input_async_reset       => '"clear"',
                    input_register_mode     => '"register"',
                    oe_async_reset          => '"clear"',
                    oe_register_mode        => '"register"',
                    operation_mode          => '"bidir"',
                    output_async_reset      => '"clear"',
                    output_register_mode    => '"register"',
                },
            }),
        );
    }elsif ($gFAMILY eq "Cyclone")
    {
        $module->add_contents
        (
            e_lpm_altddio_bidir->new # Cyclone DQ pin, DQS mode, simulation
            ({
                name        => $dqs_group_instname,
                module      => altddio_bidir,
                tag         => "simulation",
                port_map    =>
                {

                    inclocken   => "$std_logic1", # Disable postamble control in simulation
                    inclock     => "dq_capture_clk",
                    datain_h    => "wdata_r[$i : $i]",
                    datain_l    => "wdata_r[($i+$gMEM_DQ_PER_DQS):($i+$gMEM_DQ_PER_DQS)]",
                    aclr        => "reset",
                    oe          => "dq_oe",

                    outclocken  => "$std_logic1",
                    outclock    => "write_clk",

                     dataout_h   => "dq_captured_falling[$i:$i]",
                     dataout_l   => "dq_captured_rising[$i:$i]",
                     padio       => "ddr_dq[$i : $i]",
                },
                parameter_map   =>
                {
                    width                       => 1,
                    intended_device_family      => '"Cyclone"',
                    oe_reg                      => '"REGISTERED"',

                    extend_oe_disable           => '"UNUSED"',
                    implement_input_in_lcell    => '"UNUSED"',

                    lpm_type                    => '"altddio_bidir"',
                },
            }),
        );
        my $value = int $i * $gPOSTAMBLE_REGS / $gMEM_DQ_PER_DQS;
        $module->add_contents
        (
            e_lpm_altddio_bidir->new # Cyclone DQ pin, DQS mode, synthesis
            ({
                name        => $dqs_group_instname,
                module      => altddio_bidir,
                tag         => "synthesis",
                port_map    =>
                {
                    inclocken   => "dq_enable[".$value."]", # Postamble control for synthesis
                    inclock     => "dq_capture_clk",
                    datain_h    => "wdata_r[$i : $i]",
                    datain_l    => "wdata_r[($i+$gMEM_DQ_PER_DQS):($i+$gMEM_DQ_PER_DQS)]",
                    aclr        => "reset",
                    oe          => "dq_oe",
                    outclocken  => "$std_logic1",
                    outclock    => "write_clk",
                    dataout_h   => "dq_captured_falling[$i:$i]",
                    dataout_l   => "dq_captured_rising[$i:$i]",
                    padio       => "ddr_dq[$i : $i]",
                 },
                parameter_map   =>

                {
                    width                       => 1,
                    intended_device_family      => '"Cyclone"',
                    oe_reg                      => '"REGISTERED"',
                    extend_oe_disable           => '"UNUSED"',
                    implement_input_in_lcell    => '"UNUSED"',

                    lpm_type                    => '"altddio_bidir"',
                },
            }),
        );
    }
    elsif($gFAMILY eq "Cyclone II")
    {
        $module->add_contents
        (
            e_lpm_altddio_bidir->new # Cyclone II DQ pin, DQS mode, synthesis
            ({
                name        => $dqs_group_instname,
                module      => altddio_bidir,
                tag        => "synthesis",
                port_map    =>
                {
                    #inclocken   => "$std_logic1", # Postamble control done elsewhere unlike other families
                    inclocken   => "dq_enable[0]", # Postamble control both in the clock mux and here!
                    inclock     => "dq_capture_clk",
                    datain_h    => "wdata_r[$i : $i]",
                    datain_l    => "wdata_r[($i+$gMEM_DQ_PER_DQS):($i+$gMEM_DQ_PER_DQS)]",
                    aclr        => "reset",
                    oe          => "dq_oe",
                    outclocken  => "$std_logic1",
                    outclock    => "write_clk",
                     dataout_h   => "dq_captured_falling[$i:$i]",
                     dataout_l   => "dq_captured_rising[$i:$i]",
                     padio       => "ddr_dq[$i : $i]",
                },
                parameter_map   =>

                {
                    width                       => 1,
                    intended_device_family      => '"Cyclone II"',
                    oe_reg                      => '"REGISTERED"',
                    extend_oe_disable           => '"UNUSED"',
                    implement_input_in_lcell    => '"UNUSED"',
                    lpm_type                    => '"altddio_bidir"',
                },
            }),
            
            e_lpm_altddio_bidir->new # Cyclone II DQ pin, DQS mode, simulation (no postamble logic)
            ({
                name        => $dqs_group_instname,
                module      => altddio_bidir,
                tag        => "simulation",
                port_map    =>
                {
                    inclocken   => "$std_logic1", # Postamble control NOT enabled in simulation
                    inclock     => "dq_capture_clk",
                    datain_h    => "wdata_r[$i : $i]",
                    datain_l    => "wdata_r[($i+$gMEM_DQ_PER_DQS):($i+$gMEM_DQ_PER_DQS)]",
                    aclr        => "reset",
                    oe          => "dq_oe",
                    outclocken  => "$std_logic1",
                    outclock    => "write_clk",
                     dataout_h   => "dq_captured_falling[$i:$i]",
                     dataout_l   => "dq_captured_rising[$i:$i]",
                     padio       => "ddr_dq[$i : $i]",
                },
                parameter_map   =>

                {
                    width                       => 1,
                    intended_device_family      => '"Cyclone II"',
                    oe_reg                      => '"REGISTERED"',
                    extend_oe_disable           => '"UNUSED"',
                    implement_input_in_lcell    => '"UNUSED"',
                    lpm_type                    => '"altddio_bidir"',
                },
            }),
        );
        
    }
}
##################################################################################################################################################################

    $module->add_contents
    (

        e_process->new
        ({
             clock          =>  "clk",
             reset          =>  "reset_n",
             comment            =>
             "-----------------------------------------------------------------------------\n

              Write data registers\n
              \n

              These are the last registers before the registers in the altddio_bidir. They\n
              are clocked off the system clock but feed registers which are clocked off the\n
              write clock, so their output is the beginning of 3/4 cycle path.\n
              -----------------------------------------------------------------------------",
             _asynchronous_contents =>
             [
            e_assign->new(["wdata_r" => "0"]),
             ],
             contents   =>
             [
                e_if->new
            ({
                condition   => "wdata_valid",
                then        =>
                [
                    e_assign->new({lhs => "wdata_r", rhs => "wdata",comment => "don't latch in data unless it's valid"}),
                ],
            }),
             ],
        }),

    );

##################################################################################################################################################################

##################################################################################################################################################################
my $comment_fedback_resynch_regs = 
   "-----------------------------------------------------------------------------\n
    Fed-back resynchronisation registers\n
    \nThese registers resychronise the captured read data from the DQS clock\n
    domain back into the fed-back clock domain. \n
    -----------------------------------------------------------------------------\n
    Always use a rising edge for fed-back resynch";

my $comment_rising_post_fedback_regs = 
    "-----------------------------------------------------------------------------\n
    Resynchronisation registers\n
    \nThese registers resychronise the fed-back clock domain back into the system\n
    clock domain. \n
    -----------------------------------------------------------------------------\n
    Use a rising edge for resynch";

my $comment_falling_post_fedback_regs = 
    "-----------------------------------------------------------------------------\n
    Resynchronisation registers\n
    \nThese registers resychronise the fed-back clock domain back into the system\n
    clock domain. \n
    -----------------------------------------------------------------------------\n
    Use a falling edge for resynch";
    
my $comment_rising_resynch =  
    "-----------------------------------------------------------------------------\n
    Resynchronisation registers\n
    \nThese registers resychronise the captured read data from the DQS clock\n
    domain back into an internal PLL clock domain. \n
    -----------------------------------------------------------------------------\n
    Use a rising edge for resynch";

my $comment_falling_resynch =  
    "-----------------------------------------------------------------------------\n
    Resynchronisation registers\n
    \nThese registers resychronise the captured read data from the DQS clock\n
    domain back into an internal PLL clock domain. \n
    -----------------------------------------------------------------------------\n
    Use a falling edge for resynch";
    
##################################################################################################################################################################
# Model the effects of the roundtrip delay internally by delaying the captured read data before resynch. Removes the need to have it in the TB
#print "rtd in clocks is $gRTL_ROUNDTRIP_CLOCKS\n";
#print "clock tick in ps is $gCLOCK_PERIOD_IN_PS\n";

    my $num_90_deg_delays = int($gRTL_ROUNDTRIP_CLOCKS * 4);
    if ($num_90_deg_delays <= 0) { $num_90_deg_delays = 1;}; # zero or negative can't be right, so fix it.
    my $x = 0;
    
    # declare the necessary signals
    for ($x=0; $x < ($num_90_deg_delays); $x++) {            
        $module->add_contents
        (
            e_signal->new({name => "dq_captured_".$x,  width => $gMEM_DQ_PER_DQS * 2, export => 0, never_export => 1}),
        );
    };

    # concatenate the output of the two capture paths to make a signal, wider bus
    $module->add_contents
    (
        e_assign->new({lhs => "dq_captured_0", rhs => "{dq_captured_falling, dq_captured_rising}", comment => "Concatenate the rising and falling edge data to make a single bus"}),
    );

    if ($num_90_deg_delays > 1) {
        for ($x=0; $x < ($num_90_deg_delays - 1); $x++) {            
            #print "connecting 90 deg delay $x out of $num_90_deg_delays\n";
            $module->add_contents
                (
                    e_assign->new
                    ({
                        lhs => "dq_captured_".($x + 1),
                        rhs => "dq_captured_".($x),
                        sim_delay => ($gCLOCK_PERIOD_IN_PS / 4),
                    }),
                );
            }
        }
                        
    # connect up the last one
    #print "delay = $num_90_deg_delays\n";
    $module->add_contents
        (
            e_signal->new({name => "delayed_dq_captured",  width => $gMEM_DQ_PER_DQS * 2, export => 0, never_export => 1}),
            e_assign->new
            ({
                comment => "Apply delays in $num_90_deg_delays chunks to avoid having to use transport delays",
                lhs => "delayed_dq_captured",
                rhs => "dq_captured_".($num_90_deg_delays-1),
                sim_delay => ($gCLOCK_PERIOD_IN_PS / 4),
            }),
        );
                        
##################################################################################################################################################################
#} elsif ($gFAMILY eq "Stratix II" and ($MIG_FAMILY ne "NONE" or $gIS_HARDCOPY2 eq "true"))  {
if ($insert_configurable_resynch_edge_logic eq "true") {
# If targetting a 
#   - Stratix II and a companion device device is specified
#   - HardCopy II and a companion device device is specified
#   - HardCopy only
# the insert a second set of resynch registers that can be switched in and out 
    
    # Resynch registers for fed-back clock mode 
    if ($gFEDBACK_CLOCK_MODE eq "true" and $gENABLE_CAPTURE_CLK eq "false") {
        
        # note, the first reg is still called resynched_data for the sake of the timing script
        $module->add_contents (
            e_port->new({name => "fedback_resynch_clk",direction => "input"}),
            e_process->new
            ({
                 clock          =>  "fedback_resynch_clk",
                 reset          =>  "reset_n",
                 comment        =>  $comment_fedback_resynch_regs,
                 _asynchronous_contents => [ e_assign->new(["resynched_data" => "0"]), ],
                 #contents               => [ e_assign->new({lhs => "resynched_data", rhs => "{dq_captured_falling, dq_captured_rising}"}), ],
                 contents               => [ e_assign->new({lhs => "resynched_data", rhs => "delayed_dq_captured"}), ],
            }),
        );

        # this is secondary resynch on one of clocks from the system PLL but called fedback_resynched_data
        if ($gRESYNCH_EDGE eq "rising") {
            $module->add_contents (
                # "normal" registers
                e_process->new
                ({
                     clock          =>  "resynch_clk",
                     reset          =>  "reset_n",
                     comment        =>  $comment_rising_post_fedback_regs,
                     _asynchronous_contents => [ e_assign->new(["fedback_resynched_data" => "0"]), ],
                     contents               => [ e_assign->new({lhs => "fedback_resynched_data", rhs => "resynched_data"}), ],
                }),
                # extra set of registers on the opposite clock edge
                e_process->new
                ({
                     clock          =>  "resynch_clk",
                     reset          =>  "reset_n",
                     clock_level    =>  0,
                     comment        => "Insert an extra set of resynch registers on the opposite edge",
                     _asynchronous_contents => [ e_assign->new(["fedback_resynched_data_other_edge" => "0"]), ],
                     contents               => [ e_assign->new({lhs => "fedback_resynched_data_other_edge", rhs => "fedback_resynched_data"}), ],
                }),

            );
        } else { # falling edge resynch
            $module->add_contents (
                e_process->new
                ({
                     clock          =>  "resynch_clk",
                     reset          =>  "reset_n",
                     clock_level    =>  0,
                     comment        =>  $comment_falling_post_fedback_regs,
                     _asynchronous_contents => [ e_assign->new(["fedback_resynched_data" => "0"]), ],
                     contents               => [ e_assign->new({lhs => "fedback_resynched_data", rhs => "resynched_data"}), ],
                }),
                # extra set of registers on the opposite clock edge
                e_process->new
                ({
                     clock          =>  "resynch_clk",
                     reset          =>  "reset_n",
                     comment        =>  "Insert an extra set of resynch registers on the opposite edge",
                     _asynchronous_contents => [ e_assign->new(["fedback_resynched_data_other_edge" => "0"]), ],
                     contents               => [ e_assign->new({lhs => "fedback_resynched_data_other_edge", rhs => "fedback_resynched_data"}), ],
                }),
            );
        }
    } else { # Not in fed-back clock mode
        
        if ($gRESYNCH_EDGE eq "rising") {
            $module->add_contents (
                e_process->new
                ({
                     clock          =>  "resynch_clk",
                     reset          =>  "reset_n",
                     comment        =>  $comment_rising_resynch,
                     _asynchronous_contents => [ e_assign->new(["resynched_data" => "0"]), ],
                     # contents       =>         [ e_assign->new({lhs => "resynched_data", rhs => "{dq_captured_falling, dq_captured_rising}"}), ],
                     contents       =>         [ e_assign->new({lhs => "resynched_data", rhs => "delayed_dq_captured"}), ],
                }),
                e_process->new
                ({
                     clock          =>  "resynch_clk",
                     reset          =>  "reset_n",
                     clock_level    =>  0,
                     comment        => "Insert an extra set of resynch registers on the opposite edge",
                     _asynchronous_contents => [ e_assign->new(["resynched_data_other_edge" => "0"]), ],
                     contents       =>         [ e_assign->new({lhs => "resynched_data_other_edge", rhs => "resynched_data"}), ],
                }),
            );
        } else {
            $module->add_contents (
                e_process->new 
                ({
                     clock          =>  "resynch_clk",
                     reset          =>  "reset_n",
                     clock_level    =>  0,
                     comment        =>  $comment_falling_resynch,
                     _asynchronous_contents => [ e_assign->new(["resynched_data" => "0"]), ],
                     contents               => [ e_assign->new({lhs => "resynched_data", rhs => "delayed_dq_captured"}), ],
                     # contents               => [ e_assign->new({lhs => "resynched_data", rhs => "{dq_captured_falling, dq_captured_rising}"}), ],
                }),
                e_process->new
                ({
                     clock          =>  "resynch_clk",
                     reset          =>  "reset_n",
                     comment        =>  "Insert an extra set of resynch registers on the opposite edge",
                     _asynchronous_contents => [ e_assign->new(["resynched_data_other_edge" => "0"]), ],
                     contents       =>         [ e_assign->new({lhs => "resynched_data_other_edge", rhs => "resynched_data"}), ],
                }),
            );
        }
    }
}
elsif ($gFAMILY eq "Stratix II" and $MIG_FAMILY eq "NONE")
{
# Stratix II only, no HC companion device 
    
    # Resynch registers for fed-back clock mode 
    if ($gFEDBACK_CLOCK_MODE eq "true" and $gENABLE_CAPTURE_CLK eq "false") {
        
        # note, the first reg is still called resynched_data for the sake of the timing script
        $module->add_contents (
            e_port->new({name => "fedback_resynch_clk",direction => "input"}),
            e_process->new
            ({
                 clock          =>  "fedback_resynch_clk",
                 reset          =>  "reset_n",
                 comment        =>  $fedback_resynch_regs_comment, 
                 _asynchronous_contents => [ e_assign->new(["resynched_data" => "0"]), ],
                 contents               => [ e_assign->new({lhs => "resynched_data", rhs => "delayed_dq_captured"}), ],
                 # contents               => [ e_assign->new({lhs => "resynched_data", rhs => "{dq_captured_falling, dq_captured_rising}"}), ],
            }),
        );

        # this is secondary resynch on one of clocks from the system PLL but called fedback_resynched_data
        if ($gRESYNCH_EDGE eq "rising") {
            $module->add_contents (
                e_process->new
                ({
                     clock          =>  "resynch_clk",
                     reset          =>  "reset_n",
                     comment        =>  $comment_rising_post_fedback_regs,
                     _asynchronous_contents => [ e_assign->new(["fedback_resynched_data" => "0"]), ],
                     contents               => [ e_assign->new({lhs => "fedback_resynched_data", rhs => "resynched_data"}), ],
                }),
            );
        } else { # falling edge resynch
            $module->add_contents (
                e_process->new
                ({
                     clock          =>  "resynch_clk",
                     reset          =>  "reset_n",
                     clock_level        =>  0,
                     comment            => $comment_falling_post_fedback_regs,
                     _asynchronous_contents => [ e_assign->new(["fedback_resynched_data" => "0"]), ],
                     contents               => [ e_assign->new({lhs => "fedback_resynched_data", rhs => "resynched_data"}), ],
                }),
            );
        }
    } else { # Not in fed-back clock mode
        
        if ($gRESYNCH_EDGE eq "rising") {
            $module->add_contents (
                e_process->new
                ({
                     clock          =>  "resynch_clk",
                     reset          =>  "reset_n",
                     comment        =>  $comment_rising_resynch,
                     _asynchronous_contents => [ e_assign->new(["resynched_data" => "0"]), ],
                     contents       =>         [ e_assign->new({lhs => "resynched_data", rhs => "delayed_dq_captured"}), ],
                     # contents       =>         [ e_assign->new({lhs => "resynched_data", rhs => "{dq_captured_falling, dq_captured_rising}"}), ],
                }),
            );
        } else {
            $module->add_contents (
                e_process->new 
                ({
                     clock          =>  "resynch_clk",
                     reset          =>  "reset_n",
                     clock_level    =>  0,
                     comment        =>  $comment_falling_resynch,
                     _asynchronous_contents => [ e_assign->new(["resynched_data" => "0"]), ],
                     contents               => [ e_assign->new({lhs => "resynched_data", rhs => "delayed_dq_captured"}), ],
                     # contents               => [ e_assign->new({lhs => "resynched_data", rhs => "{dq_captured_falling, dq_captured_rising}"}), ],
                }),
            );
        }
    }
} else # not Stratix II
{
#already available block
    if ($gRESYNCH_EDGE eq "rising")
    {
        $module->add_contents
        (
            e_process->new
            ({
                 clock          =>  "resynch_clk",#"chosen_resynch_clk",
                 reset          =>  "reset_n",
                 comment        =>  $comment_rising_resynch,
                 _asynchronous_contents => [ e_assign->new(["resynched_data" => "0"]), ],
                 contents               => [ e_assign->new({lhs => "resynched_data", rhs => "delayed_dq_captured"}), ],
                 # contents               => [ e_assign->new({lhs => "resynched_data", rhs => "{dq_captured_falling, dq_captured_rising}"}), ],
            }),
        );
    }else
    {
        $module->add_contents
        (
            e_process->new
            ({
                 clock          =>  "resynch_clk",
                 reset          =>  "reset_n",
                 clock_level    =>  0,
                 comment        =>  $comment_falling_resynch,
                 _asynchronous_contents => [ e_assign->new(["resynched_data" => "0"]), ],
                 contents               => [ e_assign->new({lhs => "resynched_data", rhs => "delayed_dq_captured"}), ],
                 # contents               => [ e_assign->new({lhs => "resynched_data", rhs => "{dq_captured_falling, dq_captured_rising}"}), ],
            }),
        );
    }
}
my $resynched_data_reg_name = "resynched_data";
##################################################################################################################################################################
if ($gFEDBACK_CLOCK_MODE eq "true" and $gENABLE_CAPTURE_CLK eq "false")
{
    $resynched_data_reg_name = "fedback_resynched_data";
}


my $comment_inter_resynch =
    "-----------------------------------------------------------------------------\n
    Post-resynch negedge registers\n
    These optional registers can be inserted to make it easier to resynch between\n
    the resynch clock and the system clock by optionally inserting a negedge\n
    system clock register stage.\n
    Note that the rdata_valid signal is also pipelined if this is set.\n
    -----------------------------------------------------------------------------";
    

# ($gFAMILY eq "Stratix II" and ($MIG_FAMILY ne "NONE" or $gIS_HARDCOPY2 eq "true"))  {
if ($insert_configurable_resynch_edge_logic eq "true") {

    $module->add_contents
    (
        e_port->new({name => "resynch_clk_edge_select", direction => "input"}),
    );

    #insert a mux between the resynch and inter-resynch 
    if ($gINTER_RESYNCH eq "true")
    {
        $module->add_contents
        (
            e_comment->new ({comment => $comment_inter_resynch,}),
            e_process->new
            ({
                 clock          =>  "clk",
                 reset          =>  "reset_n",
                 _asynchronous_contents => [ e_assign->new(["inter_rdata" => "0"]), ],
                 contents               => 
                 [ 
                    e_if->new
                    ({
                        comment     => "mux between the two resynch edges",
                        condition   => "resynch_clk_edge_select",
                        then        => [ e_assign->new({lhs => "inter_rdata", rhs => $resynched_data_reg_name."_other_edge"}), ],
                        else        => [ e_assign->new({lhs => "inter_rdata", rhs => "$resynched_data_reg_name"}), ],
                    }),    
                ],
            }),
        );
    } else
    {
        $module->add_contents
        (
        e_process->new
            ({
                clock      =>  "",
                reset      =>  "",
                sensitivity_list    => ["resynch_clk_edge_select","$resynched_data_reg_name","$resynched_data_reg_name"."_other_edge"],
                contents   =>
                [
                    e_if->new
                    ({
                        comment     => "don't insert pipeline registers but mux between the two resynch edges",
                        condition   => "resynch_clk_edge_select",
                        then        => [ e_assign->new({lhs => "inter_rdata", rhs => $resynched_data_reg_name."_other_edge"}), ],
                        else        => [ e_assign->new({lhs => "inter_rdata", rhs => "$resynched_data_reg_name"}), ],
                    }),
                ],
            }),
        );
    }
} else {
    if ($gINTER_RESYNCH eq "true")
    {
        $module->add_contents
        (
            e_comment->new({comment => $comment_inter_resynch,}),
            e_process->new
            ({
                 clock          =>  "clk",
                 reset          =>  "reset_n",
                 clock_level    =>  0,
                 _asynchronous_contents => [ e_assign->new(["inter_rdata" => "0"]), ],
                 contents               => [ e_assign->new({lhs => "inter_rdata", rhs => "$resynched_data_reg_name"}), ],
            }),
        );
    } else
    {
        $module->add_contents
        (
            e_assign->new({lhs => "inter_rdata", rhs => "$resynched_data_reg_name",comment =>"don't insert pipeline registers"}),
        );
    }
}
##################################################################################################################################################################
    if ($gPIPELINE_READDATA eq "true")
    {
        $module->add_contents
        (
            e_process->new
            ({
                 clock          =>  "clk",
                 reset          =>  "reset_n",
                 clock_level        =>  1,
                 comment            =>
                 "-----------------------------------------------------------------------------\n
                  Pipeline read data registers\n
                  \n
                  These optional registers can be inserted to make it easier to meet timing
                  coming out of the local_rdata port of the core. It's especially necessary\n
                  if a falling edge resynch edge is being used..\n
                  Note that the rdata_valid signal is also pipelined if this is set.\n
                  -----------------------------------------------------------------------------\n",
                 _asynchronous_contents => [ e_assign->new(["rdata" => "0"]), ],
                 contents               => [ e_assign->new({lhs => "rdata", rhs => "inter_rdata"}), ],
            }),
        );
    } else
    {
        $module->add_contents
        (
            e_assign->new({lhs => "rdata", rhs => "inter_rdata",comment => "don't insert pipeline registers"}),
        );
    }
##################################################################################################################################################################
$project->output();
}
1;
#You're done.
