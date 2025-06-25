use europa_all;
use europa_utils;
use e_comment;
use e_lpm_altddio_out;
sub write_example_instance
{

my $top = e_module->new({name => $gTOPLEVEL_NAME});#,output_file => "/temp_gen/$gTOPLEVEL_NAME"});
my $project = e_project->new({top => $top, language => $language,__system_directory =>$output_directory, timescale => "1ps / 1ps"});
my $module = $project->top();

#$module->vhdl_libraries()->{$gFAMILY} = all;
$module->vhdl_libraries()->{altera_mf} = all;

my $verilog_dq_io_instname;# = "\\g_datapath:\$i:g_ddr_io ";

#####   Parameters declaration  ######
my %in_param;
my @in_param;
my %out_param;
my @out_param;
my @driver_param_in;
my %driver_param_in;
my @driver_param_out;
my %driver_param_out;

my $stratixii_dll_verilog_buffer = "";
my %Stratix_Fam = ("dqs_delay_ctrl" => "open"),;
my @Stratix_Fam;
my %DDR_PREFIX_NAMEodt = ($gDDR_PREFIX_NAME."odt" => "open"),
my @DDR_PREFIX_NAMEodt;
my $DDR_DEFAULT_NAME;
my %local_refresh_req = (local_refresh_req => "open");
my %local_size = (local_size => "open");
my %capture_clk = (capture_clk => "open");
my %resynch_clk = (resynch_clk => "open");
my %fedback_resynch_clk;
my @fedback_resynch_clk;
# my %resynch_edge_select;
# my @resynch_edge_select;

my %postamble_clk = (postamble_clk => "open");
my %stratix_dll_control = (stratix_dll_control=> "open");
my @local_refresh_req;
my @local_size;
my @capture_clk;
my @resynch_clk;
my @postamble_clk;
my @stratix_dll_control;
my %dqsupdate;
my @dqsupdate;
my @dqsupdate_list;
my @stratix2_syspll_outputs;

my $clockfeedback_in_pin_name = $gCLOCKFEEDBACK_IN_PIN_NAME;
my $clock_pos_pin_name = $gCLOCK_POS_PIN_NAME;
my $clock_neg_pin_name = $gCLOCK_NEG_PIN_NAME;
$clock_pos_pin_name = $` if ($clock_pos_pin_name =~ /\[/);
$clock_neg_pin_name = $` if ($clock_neg_pin_name =~ /\[/);
####  end parameter list  ######
######################################################################################################################################################################


    $module->comment
    (
        "------------------------------------------------------------------------------\n
        \n
         *************** This is a MegaWizard generated file ****************\n
        \n
         Automatically generated example top level design to allow compilation\n
        of your DDR SDRAM Controller instance in Quartus.\n
        \n .
         This module instantiates your configured Altera DDR SDRAM Controller,\n
         some example driver logic, and a suitably configured PLL and DLL (where needed).\n
        \n .
        \n .
         Altera strongly recommends that you use this file as the starting point of your\n
         own project top level. This is because the IP Toolbench wizard parses this file\n
         to update parameters or generics, pin prefixes and other settings to match any\n
         changes you make in the wizard. The wizard will only update sections of code\n
         between its special tags so it is safe to edit this file and add your own logic\n
         to it. This is the recommended design flow for using the megacore.\n
        \n
         If you create your own top level or remove the tags, then you must make sure that\n
         any changes you make in the wizard are also applied to this file.\n
        \n
         Whilst editing this file make sure the edits are not inside any 'MEGAWIZARD'\n
         text insertion areas.\n
         (between "."<<START MEGAWIZARD INSERT"." and". "<<END MEGAWIZARD INSERT comments)\n
        \n
         Any edits inside these delimiters will be overwritten by the megawizard if you\n
         re-run it.\n
        \n
         If you really need to make changes inside these delimiters then delete\n
         both 'START' and 'END' delimiters.  This will stop the megawizard updating this\n
         section again.\n
        \n
        ----------------------------------------------------------------------------------\n
         << START MEGAWIZARD INSERT PARAMETER_LIST\n
         Parameters:\n
         Device Family                      : $gFAMILY\n
         local Interface Data Width         : $gLOCAL_DATA_BITS\n
         DQ_PER_DQS                         : $gMEM_DQ_PER_DQS\n
         LOCAL_AVALON_IF                    : ${gLOCAL_AVALON_IF}\n
         MEM_CHIPSELS                       : $gMEM_CHIPSELS\n
         MEM_CHIP_BITS                      : $gMEM_CHIP_BITS\n
         MEM_BANK_BITS                      : $gMEM_BANK_BITS\n
         MEM_ROW_BITS                       : $gMEM_ROW_BITS\n
         MEM_COL_BITS                       : $gMEM_COL_BITS\n
         LOCAL_BURST_LEN                    : $gLOCAL_BURST_LEN\n
         LOCAL_BURST_LEN_BITS               : $gLOCAL_BURST_LEN_BITS\n
         Number Of Output Clock Pairs       : $gNUM_CLOCK_PAIRS\n
         << END MEGAWIZARD INSERT PARAMETER_LIST\n
        ----------------------------------------------------------------------------------\n
        << MEGAWIZARD PARSE FILE DDR${gWIZARD_VERSION}\n\n
          .
        << START MEGAWIZARD INSERT MODULE\n"
    );

     $module->add_contents
     (
        e_comment->new({comment => "\n "}),
        e_comment->new({comment => "\n "}),
    );
    ##########################################################################################################################################################################
     $module->add_contents
     (
     #####	Ports declaration#	######
         e_port->new({name => "clock_source",direction => "input"}),
         e_port->new({name => "$clock_pos_pin_name",direction => "output", width => $gNUM_CLOCK_PAIRS,declare_one_bit_as_std_logic_vector => 1}),
         e_port->new({name => "$clock_neg_pin_name",direction => "output", width => $gNUM_CLOCK_PAIRS,declare_one_bit_as_std_logic_vector => 1}),
         e_port->new({name => "reset_n",direction => "input"}),

         e_port->new({name => $gDDR_PREFIX_NAME."cke",direction => "output",width =>$gMEM_CHIPSELS,declare_one_bit_as_std_logic_vector => 1}),
         e_port->new({name => $gDDR_PREFIX_NAME."cs_n",direction => "output",width =>$gMEM_CHIPSELS,declare_one_bit_as_std_logic_vector => 1}),
         e_port->new({name => $gDDR_PREFIX_NAME."ras_n",direction => "output"}),
         e_port->new({name => $gDDR_PREFIX_NAME."cas_n",direction => "output"}),
         e_port->new({name => $gDDR_PREFIX_NAME."we_n",direction => "output"}),
         e_port->new({name => $gDDR_PREFIX_NAME."ba",direction => "output",width =>$gMEM_BANK_BITS}),
         e_port->new({name => $gDDR_PREFIX_NAME."a",width=>$gMEM_ROW_BITS,direction => "output"}),
         e_port->new({name => $gDDR_PREFIX_NAME."dq",direction => "inout",width =>$gLOCAL_DATA_BITS / 2}),
         e_port->new({name => $gDDR_PREFIX_NAME."dqs",direction => "inout",width =>$gLOCAL_DATA_BITS / $gMEM_DQ_PER_DQS/ 2,declare_one_bit_as_std_logic_vector => 1}),
         e_port->new({name => $gDDR_PREFIX_NAME."dm",width => $gLOCAL_DATA_BITS / $gMEM_DQ_PER_DQS/ 2,direction => "output",declare_one_bit_as_std_logic_vector => 1}),

         e_port->new({name => "test_complete",direction => "output"}),
         e_port->new({name => "pnf_per_byte",direction => "output", width => $gLOCAL_DATA_BITS / 8}),
         e_port->new({name => "pnf",direction => "output"}),
    );
#########################################################################################################################################################
     $module->add_contents
     (
     # #####   signal generation #####
         e_signal->news #: ["signal", width, export, never_export]
         (
            ["clk",	1,	0,	1],
            #["dummy",	1,	0,	1],
            ["dedicated_resynch_or_capture_clk",	1,	0,	1],
            ["dedicated_postamble_clk",1,	0,	1],
            ["write_clk",1,	0,	1],
            ["resynch_clk",	1,	0,	1],
            ["postamble_clk",1,	0,	1],
            ["dqs_ref_clk",1,	0,	1],
         #e_comment->new({comment => "<< START MEGAWIZARD INSERT LOCAL_SIGNALS"}),
            [ $gDDR_PREFIX_NAME."local_addr",	$gMEM_CHIP_BITS + $gMEM_ROW_BITS + $gMEM_BANK_BITS + $gMEM_COL_BITS - 1,	0,	1],
            [ $gDDR_PREFIX_NAME."local_col_addr",	$gMEM_COL_BITS,	0,	1],
            [ $gDDR_PREFIX_NAME."local_cs_addr",	$gLEGAL_MEM_CHIP_BITS,	0,	1],
            [ $gDDR_PREFIX_NAME."local_wdata",		$gLOCAL_DATA_BITS,	0,	1],
            [ $gDDR_PREFIX_NAME."local_rdata",		$gLOCAL_DATA_BITS,	0,	1],
            [ $gDDR_PREFIX_NAME."local_be",		$gLOCAL_DATA_BITS/8,	0,	1],
#            [ $gDDR_PREFIX_NAME."local_be",		$gLOCAL_DATA_BITS/$gMEM_DQ_PER_DQS,	0,	1],

            [ $gDDR_PREFIX_NAME."local_read_req",	1,	0,	1],
            [ $gDDR_PREFIX_NAME."local_write_req",	1,	0,	1],

            [ $gDDR_PREFIX_NAME."local_size",		$gLOCAL_BURST_LEN_BITS,	0,	1],
            [ $gDDR_PREFIX_NAME."local_ready",1,	0,	1],
            [ $gDDR_PREFIX_NAME."local_rdata_valid",1,	0,	1],
            [ $gDDR_PREFIX_NAME."local_refresh_req",1,	0,	1],
         ),
         e_signal->new({name => "gnd_signal", width => $gNUM_CLOCK_PAIRS, export => 0,never_export => 1,declare_one_bit_as_std_logic_vector => 0}),
         #e_comment->new({comment => " << END MEGAWIZARD INSERT LOCAL_SIGNALS"}),
      );
######################################################################################################################################################################
     $module->add_contents
     (
        e_comment->new({comment => "<< END MEGAWIZARD INSERT MODULE\n"}),
        e_comment->new({comment => "<< START MEGAWIZARD INSERT REFRESH_REQ"}),
        e_comment->new({comment => " Custom logic to implement user controlled refreshes can be added here...."}),
        e_assign->new({lhs => $gDDR_PREFIX_NAME."local_refresh_req", rhs => "1'b0", comment => " refreshes disabled"}),
        e_comment->new({comment => "<< END MEGAWIZARD INSERT REFRESH_REQ\n"}),
     );

   

    #decide whether to insert the resynch edge select logic or not, also appears later!
    #print "gFAMILY = $gFAMILY, MIG_FAMILY = $MIG_FAMILY, gIS_HARDCOPY2 = $gIS_HARDCOPY2\n";
    if ($gFAMILY eq "Stratix II" and ($MIG_FAMILY ne "NONE" or $gIS_HARDCOPY2 eq "true")) {

        $in_param{'resynch_clk_edge_select'} = "resynch_clk_edge_select";
    }

######################################################################################################################################################################

if (($gFAMILY eq "Stratix") and ($gENABLE_CAPTURE_CLK ne "true")) {
    $module->add_contents
    (
        e_port->new({name => "stratix_dqs_ref_clk_out",direction => "output"}),
        e_port->new({name => "stratix_dqs_ref_clk",direction => "input"}),
    );
}

if ($gFEDBACK_CLOCK_MODE eq "true") {
    $module->add_contents
    (
        e_port->new({name => "$clockfeedback_in_pin_name",direction => "input"}),
        e_port->new({name => "fedback_clk_out",direction => "output"}),
    );


    if ($gCLOCK_GENERATION eq "dedicated") {
        # START OF should be able to get rid of these lines if the wizard doesn't include the clk_to_sdram's on the wrapper
        $out_param{'fedback_clk_out'} = "unused_fb_clk";
        $module->add_contents
        (
            e_signal->new({name => "unused_fb_clk", width => 1, export => 0, never_export => 1,}),
        );
        # END OF should be able to get rid of these lines if the wizard doesn't include the clk_to_sdram's on the wrapper
    } else {
        # connect fedback_clk_out output from core to top-level pin
        $out_param{'fedback_clk_out'} = "fedback_clk_out";
    }

}

# if the final stage of registers is in the datapath, we need to bring out that clock.
if ($gEXTRA_PL_REG eq "true") {
    $in_param{'addrcmd_clk'} = "clk";
}

######################################################################################################################################################################
# if the clock outputs are generated from ALTDDIOs then we need to wire them up to the outputs on the wrapper
# else, they are left open and driven straight from the PLL (lower down in the PLL instantiation)
######################################################################################################################################################################
if ($gCLOCK_GENERATION eq "dedicated" and $gFAMILY eq "Stratix II") {

    # START OF should be able to get rid of these lines if the wizard doesn't include the clk_to_sdram's on the wrapper
    $out_param{'clk_to_sdram'} = "unused_clk"."[($gNUM_CLOCK_PAIRS-1):0]"; 
    $out_param{'clk_to_sdram_n'} = "unused_clk_n"."[($gNUM_CLOCK_PAIRS-1):0]";
    
    $module->add_contents
    (
        e_signal->new({name => "unused_clk", width => $gNUM_CLOCK_PAIRS,	 export => 0, never_export => 1, declare_one_bit_as_std_logic_vector => 1}),
        e_signal->new({name => "unused_clk_n", width => $gNUM_CLOCK_PAIRS,	 export => 0, never_export => 1, declare_one_bit_as_std_logic_vector => 1}),
    );
    # END OF should be able to get rid of these lines if the wizard doesn't include the clk_to_sdram's on the wrapper

    # Since we have a dedicated PLL phase tap for dedicated clock outputs, we need a signal to fan out to the outputs
    $module->add_contents
    (
        e_signal->new({name => "dedicated_output_clk", width => 1, export => 0, never_export => 1}),
    );
    
} else {
    $out_param{'clk_to_sdram'} = $clock_pos_pin_name."[($gNUM_CLOCK_PAIRS-1):0]"; 
    $out_param{'clk_to_sdram_n'} = $clock_neg_pin_name."[($gNUM_CLOCK_PAIRS-1):0]"; 
}
######################################################################################################################################################################


if ((($gFAMILY eq "Stratix" or $gFAMILY eq "Stratix II") and $gENABLE_CAPTURE_CLK ne "true") or $gREGTEST_ADD_DLL_PORTS == 1) {
    $Stratix_Fam{'dqs_delay_ctrl'} = "dqs_delay_ctrl";
    @Stratix_Fam = %Stratix_Fam;
    $in_param{'dqs_delay_ctrl'} = "dqs_delay_ctrl";
    if ($gFAMILY eq "Stratix II")
    {
    # Stratix II only
        my $gDLL_INPUT_FREQUENCY = "${gCLOCK_PERIOD_IN_PS}ps";
        my $gSTRATIXII_DQS_PHASE                = ${gSTRATIXII_DQS_PHASE_SHIFT}; # 9000/100 "90 degrees",  7200/100 "72 degrees"
        my $gSTRATIXII_DLL_DELAY_BUFFER_MODE    = "${gSTRATIXII_DLL_DELAY_BUFFER_MODE}";
        my $gSTRATIXII_DQS_OUT_MODE             = "${gSTRATIXII_DQS_OUT_MODE}";
        #$module->vhdl_libraries()->{stratixii} = all;
        $stratix_dll_control{'stratix_dll_control'} = "stratix_dll_control";
        $out_param{'stratix_dll_control'} = "stratix_dll_control";
        #$module->add_contents
        #(
            #e_parameter->add({name => "gDLL_INPUT_FREQUENCY", default => "${gCLOCK_PERIOD_IN_PS}ps", vhdl_type => "string"}),
            #e_parameter->add({name => "gSTRATIXII_DQS_PHASE", default => $gSTRATIXII_DQS_PHASE_SHIFT, vhdl_type => "natural"}),
            #e_parameter->add({name => "gSTRATIXII_DLL_DELAY_BUFFER_MODE", default => $gSTRATIXII_DLL_DELAY_BUFFER_MODE, vhdl_type => "string"}),
            #e_parameter->add({name => "gSTRATIXII_DQS_OUT_MODE", default => $gSTRATIXII_DQS_OUT_MODE, vhdl_type => "string"}),
        #);
    }elsif ($gFAMILY eq "Stratix")
    {
    # Stratix only
        my $gDLL_INPUT_FREQUENCY = "${gCLOCK_PERIOD_IN_PS}ps";
        my $gSTRATIX_DQS_PHASE = "${gDQS_PHASE_SHIFT}";#       //  "90" degrees,
        #$module->vhdl_libraries()->{stratix} = all;
        $stratix_dll_control{'stratix_dll_control'} = "stratix_dll_control";
        $out_param{'stratix_dll_control'} = "stratix_dll_control";
        #$module->add_contents
        #(
            #e_parameter->add({name => "gDLL_INPUT_FREQUENCY", default => "${gCLOCK_PERIOD_IN_PS}ps", vhdl_type => "string"}),
            #e_parameter->add({name => "gSTRATIX_DQS_PHASE", default => $gDQS_PHASE_SHIFT, vhdl_type => "string"}),
        #);
    }
}
if (($gFAMILY eq "Stratix II") and ($gENABLE_CAPTURE_CLK ne "true")) {
    if (($gBUFFER_DLL_DELAY_OUTPUT ne "true") and ($gDLL_REF_CLOCK__SWITCHED_OFF_DURING_READS ne "true"))
    {
	$dqsupdate{'dqsupdate'} = "dqsupdate";
	@dqsupdate = %dqsupdate;
	foreach my $param(@dqsupdate) {push (@dqsupdate_list, $param);}
	$module->add_contents(e_signal->new(["dqsupdate",1,0,1]),);
    }
}
if ($gUSER_REFRESH eq "true") {
    $local_refresh_req{'local_refresh_req'} = $gDDR_PREFIX_NAME."local_refresh_req";
    $in_param{'local_refresh_req'} = $gDDR_PREFIX_NAME."local_refresh_req";
}
    @local_refresh_req = %local_refresh_req;

if ($gLOCAL_BURST_LEN > 1){
    $local_size{'local_size'} = $gDDR_PREFIX_NAME."local_size";
    $in_param{'local_size'} = $gDDR_PREFIX_NAME."local_size";
}
if (($gLOCAL_BURST_LEN > 1) and ($gLOCAL_AVALON_IF eq "true")) {
    $local_size{'local_burstbegin'} = $gDDR_PREFIX_NAME."local_burstbegin";
    $in_param{'local_burstbegin'} = $gDDR_PREFIX_NAME."local_burstbegin";
    $driver_param_out{'local_burstbegin'} = $gDDR_PREFIX_NAME."local_burstbegin";
}

if ($gENABLE_CAPTURE_CLK eq "true") {
    $capture_clk{'capture_clk'} = "dedicated_resynch_or_capture_clk";
    $in_param{'capture_clk'} = "dedicated_resynch_or_capture_clk";
}
if ($gCONNECT_RESYNCH_CLK_TO eq "dedicated") {
    $resynch_clk{'resynch_clk'} = "dedicated_resynch_or_capture_clk";
    $in_param{'resynch_clk'} = "dedicated_resynch_or_capture_clk";
}
if ($gCONNECT_POSTAMBLE_CLK_TO eq "dedicated") {
    $postamble_clk{'postamble_clk'} = "dedicated_postamble_clk";
    $in_param{'postamble_clk'} = "dedicated_postamble_clk";
}
if ($gFAMILY eq "Stratix II") {
    $module->vhdl_libraries()->{stratixii} = all;
    if (($gENABLE_CAPTURE_CLK ne "true") and ($gFEDBACK_CLOCK_MODE eq "true")){
        $fedback_resynch_clk{'fedback_resynch_clk'} = "fedback_resynch_clk";
        $in_param{'fedback_resynch_clk'} = "fedback_resynch_clk";
    }
}


if ($gFAMILY eq "Stratix") {
    $module->vhdl_libraries()->{stratix} = all;
}

if ($gMEM_TYPE eq "ddr2_sdram") {
    $DDR_DEFAULT_NAME = "ddr2_";
    $module->add_contents
    (
        e_port->new({name => $gDDR_PREFIX_NAME."odt",direction => "output",width => "$gMEM_CHIPSELS",declare_one_bit_as_std_logic_vector => 1}),
    );
    %DDR_PREFIX_NAMEodt = ($DDR_DEFAULT_NAME."odt" => $gDDR_PREFIX_NAME."odt"),
    $out_param{$DDR_DEFAULT_NAME."odt"} = $gDDR_PREFIX_NAME."odt[($gMEM_CHIPSELS-1):0]";#$gDDR_PREFIX_NAME."odt[0:0]";
}
else
{  
    $DDR_DEFAULT_NAME = "ddr_";  
}

if ($gLOCAL_AVALON_IF ne "true") {
    $module->add_contents
    (
        e_signal->news #: ["signal", width, export, never_export]
        (
            [ $gDDR_PREFIX_NAME."local_wdata_req",	1,	0,	1],
            [ $gDDR_PREFIX_NAME."local_refresh_ack",	1,	0,	1],
            [ $gDDR_PREFIX_NAME."local_init_done",	1,	0,	1],
            [ $gDDR_PREFIX_NAME."local_rdvalid_in_n",	1,	0,	1],
        ),
    );
    $out_param{'local_refresh_ack'} = "open";
    $out_param{'local_init_done'} = "open";
    $out_param{'local_rdvalid_in_n'} = "open";
    $out_param{'local_wdata_req'} = $gDDR_PREFIX_NAME."local_wdata_req";
    $driver_param_in{'local_wdata_req'} = $gDDR_PREFIX_NAME."local_wdata_req";
}
    @in_param = %in_param;
    @out_param = %out_param;
    @driver_param_in = %driver_param_in;
    @driver_param_out = %driver_param_out;

    @local_refresh_req = %local_refresh_req;
    @local_size = %local_size;
    @capture_clk = %capture_clk;
    @resynch_clk = %resynch_clk;
    @postamble_clk = %postamble_clk;
    @stratix_dll_control = %stratix_dll_control;
    @fedback_resynch_clk = %fedback_resynch_clk;
    # @resynch_edge_select = %resynch_edge_select;
    @DDR_PREFIX_NAMEodt = %DDR_PREFIX_NAMEodt;

if (($gBUFFER_DLL_DELAY_OUTPUT eq "true") and ($gENABLE_CAPTURE_CLK ne "true")) {
    $stratixii_dll_verilog_buffer ="keep";
}
if (($gFAMILY eq "Stratix") and ($gENABLE_CAPTURE_CLK ne "true") ) {
    $module->add_contents
    (
           ## the width of this signal is actually  but because it connects to  datain_h which will be declared with width of $gNUM_CLOCK_PAIRS in the altddrio_out component
           # e_signal->new({name => "stratix_dll_control_vector", width => $gNUM_CLOCK_PAIRS, export => 0, never_export =>  1, declare_one_bit_as_std_logic_vector => 1}),
           e_signal->new({name => "stratix_dll_control", width => 1, export => 0, never_export =>  1, declare_one_bit_as_std_logic_vector => 0}),
           ## the width of this signal is actually  but because it connects to  dataout which will be declared with width of $gNUM_CLOCK_PAIRS in the altddrio_out component
           # e_signal->new({name => "stratix_dqs_ref_clk_out_vector", width => $gNUM_CLOCK_PAIRS, export => 0, never_export => 1, declare_one_bit_as_std_logic_vector => 1}),
           e_signal->new({name => "dqs_delay_ctrl", width => 6,	 export => 0, never_export => 1, declare_one_bit_as_std_logic_vector => 0}),
    );
}
my @in_parameter_list;my $i=1;
foreach my $parameter (@in_param) {
#print "$i)-->  $parameter  <--\n";
 push (@in_parameter_list, $parameter);
 $i += 1;
}

my @out_parameter_list;
foreach my $parameter (@out_param) {
#	print "$i)-->  $parameter  <--\n";
 push (@out_parameter_list, $parameter);
}

my @driver_parameter_list;
foreach my $parameter (@driver_param_in) {
#	print "$i)-->  $parameter  <--\n";
 push (@driver_parameter_list, $parameter);
}

my @driver_parameter_out_list;
foreach my $parameter (@driver_param_out) {
#	print "$i)-->  $parameter  <--\n";
 push (@driver_parameter_out_list, $parameter);
}



######################################################################################################################################################################
    $module->add_contents
    (
        e_comment->new({comment => "<< START MEGAWIZARD INSERT WRAPPER_NAME"}),
        e_blind_instance->new
        ({
            name 		=> $gWRAPPER_NAME."_ddr_sdram",
            module 		=> $gWRAPPER_NAME,
            in_port_map 	=>
            {
                clk     		=>     "clk",
                write_clk     		=>     "write_clk",
                reset_n     		=>     "soft_reset_reg2_n",
                local_addr     		=>     $gDDR_PREFIX_NAME."local_addr",
                local_wdata     	=>     $gDDR_PREFIX_NAME."local_wdata",
                local_be     		=>     $gDDR_PREFIX_NAME."local_be",
                local_read_req     	=>     $gDDR_PREFIX_NAME."local_read_req",
                local_write_req     	=>     $gDDR_PREFIX_NAME."local_write_req",
                # @local_refresh_req[0] 	=> @local_refresh_req[1],
                # @local_size[0] 		=> @local_size[1],
                # @capture_clk[0] 	=> @capture_clk[1],
                # @resynch_clk[0] 	=> @resynch_clk[1],
                # @postamble_clk[0] 	=> @postamble_clk[1],
                # @Stratix_Fam[0]		=> @Stratix_Fam[1],
                @in_param		=>	@in_parameter_list,
                @dqsupdate	    	=>	@dqsupdate_list,
            },
            out_port_map 	=>
            {
                # @DDR_PREFIX_NAMEodt[0]    => @DDR_PREFIX_NAMEodt[1],
                $DDR_DEFAULT_NAME."a"  	  =>    $gDDR_PREFIX_NAME."a",
                $DDR_DEFAULT_NAME."ba"    =>    $gDDR_PREFIX_NAME."ba",
                $DDR_DEFAULT_NAME."cs_n"  =>    $gDDR_PREFIX_NAME."cs_n[($gMEM_CHIPSELS-1):0]",#$gDDR_PREFIX_NAME."cs_n[0:0]",
                $DDR_DEFAULT_NAME."dm"    =>    $gDDR_PREFIX_NAME."dm[".(($gLOCAL_DATA_BITS / $gMEM_DQ_PER_DQS / 2 )-1).":0]",#$gDDR_PREFIX_NAME."dm[0:0]",
                $DDR_DEFAULT_NAME."cke"   =>    $gDDR_PREFIX_NAME."cke[($gMEM_CHIPSELS-1):0]",#$gDDR_PREFIX_NAME."cke[0:0]",
                $DDR_DEFAULT_NAME."ras_n" =>    $gDDR_PREFIX_NAME."ras_n",
                $DDR_DEFAULT_NAME."cas_n" =>    $gDDR_PREFIX_NAME."cas_n",
                $DDR_DEFAULT_NAME."we_n"  =>    $gDDR_PREFIX_NAME."we_n",
                local_ready     	=>     $gDDR_PREFIX_NAME."local_ready",
                local_rdata_valid     	=>     $gDDR_PREFIX_NAME."local_rdata_valid",
                local_rdata     	=>     $gDDR_PREFIX_NAME."local_rdata",
                @out_param		=>	@out_parameter_list,
                # clocks now programatically added if ddio clocks in on
                #clk_to_sdram		=> $clock_pos_pin_name."[($gNUM_CLOCK_PAIRS-1):0]",
                #clk_to_sdram_n		=> $clock_neg_pin_name."[($gNUM_CLOCK_PAIRS-1):0]",
            },
            inout_port_map  	=>
            {
                $DDR_DEFAULT_NAME."dq"    =>    $gDDR_PREFIX_NAME."dq",
                $DDR_DEFAULT_NAME."dqs"   =>    $gDDR_PREFIX_NAME."dqs[".(($gLOCAL_DATA_BITS / $gMEM_DQ_PER_DQS / 2)-1).":0]",#$gDDR_PREFIX_NAME."dqs[0:0]",
            },
        }),
        e_comment->new({comment => "<< END MEGAWIZARD INSERT WRAPPER_NAME\n"}),
    );
######################################################################################################################################################################
# Chipselect Address Mapping
######################################################################################################################################################################
    $module->add_contents
    (
        e_comment->new({comment => "<< START MEGAWIZARD INSERT CS_ADDR_MAP"}),
        e_assign->new({
            lhs => $gDDR_PREFIX_NAME."local_addr["."$gMEM_COL_BITS - 2".":"."0"."]", 
            rhs => $gDDR_PREFIX_NAME."local_col_addr["."$gMEM_COL_BITS - 1".":"."1"."]", 
            comment => "connect up the column address bits"}
        ),
    );
    if ($gMEM_CHIP_BITS > 0) {
        $module->add_contents
        (
            e_assign->new
                ({
                    lhs => $gDDR_PREFIX_NAME."local_addr["."$gMEM_CHIP_BITS+$gMEM_BANK_BITS+$gMEM_ROW_BITS+$gMEM_COL_BITS-2".":"."$gMEM_BANK_BITS+$gMEM_ROW_BITS+$gMEM_COL_BITS-1"."]",
                        rhs => $gDDR_PREFIX_NAME."local_cs_addr",
                        comment => "Chipselect Address Mapping",
                }),
        );
    }
    $module->add_contents
    (
        e_comment->new({comment => "<< END MEGAWIZARD INSERT CS_ADDR_MAP\n"}),
    );

######################################################################################################################################################################
# Decide whether to insert the resynch edge select logic or not, also appears earlier!
######################################################################################################################################################################

    if ($gFAMILY eq "Stratix II" and ($MIG_FAMILY ne "NONE" or $gIS_HARDCOPY2 eq "true")) {

        $module->add_contents
        (
            e_comment->new({comment => "<< START MEGAWIZARD INSERT RESYNCH_EDGE_SELECT"}),
            e_comment->new({comment => " Custom logic to select between edges of the resynch edge can be added here..."}),
            e_assign->new({lhs => "resynch_clk_edge_select", rhs => "0"}),
            e_comment->new({comment => "<< END MEGAWIZARD INSERT RESYNCH_EDGE_SELECT"}),
        );

    }

######################################################################################################################################################################
# Insert example driver
######################################################################################################################################################################



    $module->add_contents
    (
        e_comment->new({comment => "<< START MEGAWIZARD INSERT EXAMPLE_DRIVER"}),
        e_comment->new({comment => "Self-test, synthesisable code to exercise the DDR SDRAM Controller"}),

        e_blind_instance->new
        ({
            name 		=> "driver",
            module 		=> $gWRAPPER_NAME."_example_driver",
            in_port_map 	=>
            {
                clk                  => "clk",
                reset_n              => "soft_reset_reg2_n",
                local_rdata_valid    => $gDDR_PREFIX_NAME."local_rdata_valid",
                local_ready          => $gDDR_PREFIX_NAME."local_ready",
                local_rdata          => $gDDR_PREFIX_NAME."local_rdata",
                @driver_param_in	     =>	@driver_parameter_list,
            },
            out_port_map	=>
            {
                local_read_req       => $gDDR_PREFIX_NAME."local_read_req",
                local_write_req      => $gDDR_PREFIX_NAME."local_write_req",
                local_size           => $gDDR_PREFIX_NAME."local_size",
                local_cs_addr        => $gDDR_PREFIX_NAME."local_cs_addr",
                local_bank_addr      => $gDDR_PREFIX_NAME."local_addr["."$gMEM_BANK_BITS+$gMEM_ROW_BITS+$gMEM_COL_BITS-2".":"."$gMEM_ROW_BITS+$gMEM_COL_BITS - 1"."]",
                local_row_addr       => $gDDR_PREFIX_NAME."local_addr["."$gMEM_ROW_BITS+$gMEM_COL_BITS-2".":"."$gMEM_COL_BITS - 1"."]",
                local_col_addr       => $gDDR_PREFIX_NAME."local_col_addr",
                local_wdata          => $gDDR_PREFIX_NAME."local_wdata",
                local_be             => $gDDR_PREFIX_NAME."local_be",
                test_complete        => "test_complete",
                pnf_per_byte         => "pnf_per_byte",
                pnf_persist          => "pnf",
                @driver_param_out    => @driver_parameter_out_list,
            },
        }),

        e_comment->new({comment => "<< END MEGAWIZARD INSERT EXAMPLE_DRIVER\n"}),
    );

######################################################################################################################################################################
# PLL section
######################################################################################################################################################################
    $module->add_contents
    (
        e_comment->new({comment => "<< START MEGAWIZARD INSERT PLL"}),
    );
		
##### Added cascade registers for reset_n
	$module->add_contents
	(
		#####   Internal signal    ######
		e_signal->new({name => "pll_locked", width => 1, export => 0, never_export => 1}),
		e_signal->new({name => "soft_reset_reg_n", width => 1, export => 0, never_export => 1}),
		e_signal->new({name => "soft_reset_reg2_n", width => 1, export => 0, never_export => 1}),	
	);

	$module->add_contents
	(
    e_process->new
	    ({
				clock		=> "clk",
				reset		=> "pll_locked",
				_asynchronous_contents	=>
				[
			  	e_assign->new(["soft_reset_reg_n", "1'b0"]),
			  	e_assign->new(["soft_reset_reg2_n", "1'b0"]),
				],
				contents	=>
				[
					e_assign->new(["soft_reset_reg_n", "1'b1"]),
					e_assign->new(["soft_reset_reg2_n", "soft_reset_reg_n"]),

				],
	    }),

	);

    # All Stratix II system PLL's have at least these outputs! 
    @stratix2_syspll_outputs = ("c0","clk",
                                "c1", "write_clk",
                                locked => "pll_locked");
    
######################################################################################################################################################################
# Insert dedicated clock outputs immediately before the PLL 
######################################################################################################################################################################
    if ($gCLOCK_GENERATION eq "dedicated") {
        $module->add_contents(e_comment->new({comment => "\nDedicated clock outputs:"}));
        $module->add_contents(e_comment->new({comment => "You should assign the clock ouptuts to dedicated clock output pins."}));
        $module->add_contents(e_comment->new({comment => "You should edit the PLL and adjust the output driving these to keep the \ntCO of the DQS and ${clock_pos_pin_name} pins the same."}));
        
        for $x (0 .. $gNUM_CLOCK_PAIRS - 1) {
           # print "lhs => $clock_pos_pin_name [$x], rhs => dedicated_output_clk\n";
           $module->add_contents(e_assign->new({lhs => $clock_pos_pin_name."[".$x."]", rhs => "dedicated_output_clk"}));
           $module->add_contents(e_assign->new({lhs => $clock_neg_pin_name."[".$x."]", rhs => "~dedicated_output_clk"}));
        }
        
        if ($gFEDBACK_CLOCK_MODE eq "true") {   # fedback mode
           $module->add_contents(e_assign->new({lhs => "fedback_clk_out", rhs => "dedicated_output_clk"}));
        }
    }
    

    
    
##########################   STRATIX     #####################
$module->add_contents(e_assign->new({lhs => "pll_reset", rhs => "!reset_n"}));

if ($gFAMILY eq "Stratix") {
    if ($gFEDBACK_CLOCK_MODE eq "true") {   # fedback mode
        $module->add_contents 
        (
            e_blind_instance->new
            ({
                name 		=> "g_stratixpll_ddr_pll_inst",
                module 		=> "ddr_pll_stratix",				
                comment 	=> " ",
                in_port_map 	=>
                {
                    inclk0 	=> "clock_source",
                    areset  => "pll_reset",	
                },
                out_port_map	=>
                {
                    c0 => "clk",
                    c1 => "write_clk",
                    locked => "pll_locked",
                },
            }),
            e_blind_instance->new
            ({
                name 		=> "g_stratixpll_ddr_fedback_pll_inst",
                module 		=> "ddr_fedback_pll_stratix",		
                comment 	=> " ",
                in_port_map 	=>
                {

                inclk0 	=> "$clockfeedback_in_pin_name",
				areset  => "pll_reset",
                },
                out_port_map	=>
                {
                    c0 => "dedicated_resynch_or_capture_clk",
                    c1 => "dedicated_postamble_clk",
					locked => "open",
                },
            }),
        );
    } else {   # all other modes (DQS and non-DQS)
        $module->add_contents
        (
            e_blind_instance->new
            ({
                name 		=> "g_stratixpll_ddr_pll_inst",
                module 		=> "ddr_pll_stratix",				
                comment 	=> " ",
                in_port_map 	=>
                {
                    inclk0 	=> "clock_source",
                    areset  => "pll_reset",								
                },
                out_port_map	=>
                {
                    c0 => "clk",
                    c1 => "write_clk",
                    c2 => "dedicated_resynch_or_capture_clk",
                    c3 => "dedicated_postamble_clk",
                    locked => "pll_locked",								
                },
            }),

            #			e_comment->new({comment => "<< END MEGAWIZARD INSERT PLL\n"}),
        );
    }
} # end of Stratix PLL section

##########################  STRATIX_II   #####################
if ($gFAMILY eq "Stratix II") {
    if ($gFEDBACK_CLOCK_MODE eq "true") {
        if ($gENABLE_CAPTURE_CLK eq "true") {      # fed-back non-DQS mode (generate an internal capture clk from a fed-back clock) 

            if ($gCLOCK_GENERATION eq "dedicated") {
                push (@stratix2_syspll_outputs, ("c4", "dedicated_output_clk"));
            };

            $module->add_contents
            (
                e_blind_instance->new
                ({
                    name 		=> "g_stratixpll_ddr_pll_inst",
                    module 		=> "ddr_pll_stratixii",
                    comment 	=> " ",
                    in_port_map 	=>
                    {
                        inclk0 	=> "clock_source",
                        areset  => "pll_reset",
                    },
                    out_port_map	=>
                    {
                        @stratix2_syspll_outputs, # clk and write_clk and pll_locked
                        #c0 => "clk",
                        #c1 => "write_clk",
                    },
                }),
                e_blind_instance->new
                ({
                    name 		=> "g_stratixpll_ddr_fedback_pll_inst",
                    module 		=> "ddr_pll_fb_stratixii",
                    comment 	=> " ",
                    in_port_map 	=>
                    {
                        inclk0 	=> "$clockfeedback_in_pin_name",
						areset  => "pll_reset",
                    },
                    out_port_map	=>
                    {
                        c0 => "dedicated_resynch_or_capture_clk",
						locked => "open",	
                    },
                }),
            );
        }else{

            # DQS-mode, fed-back clock mode  (use DQS for capture, then two stages of resynch)
            push (@stratix2_syspll_outputs, ("c2", "dedicated_resynch_or_capture_clk"));
            if ($gCLOCK_GENERATION eq "dedicated") {
                push (@stratix2_syspll_outputs, ("c4", "dedicated_output_clk"));
            };

            $module->add_contents 
            (
                e_blind_instance->new # main PLL, generates system, write and secondary resynch clocks. 
                ({
                    name 		=> "g_stratixpll_ddr_pll_inst",
                    module 		=> "ddr_pll_stratixii",
                    comment 	=> "",
                    in_port_map 	=>
                    {
                        inclk0 	=> "clock_source",
                        areset  => "pll_reset",
                    },
                    out_port_map	=>
                    {
                        @stratix2_syspll_outputs,
                        # c0 => "clk",
                        # c1 => "write_clk",
                        # c2 => "dedicated_resynch_or_capture_clk",
                    },
                }),
                e_blind_instance->new # fed back PLL, generates first stage of resynch
                ({
                    name 		=> "g_stratixpll_ddr_fedback_pll_inst",
                    module 		=> "ddr_pll_fb_stratixii",
                    comment 	=> "",
                    in_port_map 	=>
                    {
                        inclk0 	=> "$clockfeedback_in_pin_name",
						areset  => "pll_reset",
                    },
                    out_port_map	=>
                    {
                        c0 => "fedback_resynch_clk",
                        c1 => "dedicated_postamble_clk",
						locked => "open",	
                    },
                }),
            );
        }
    } else {                               

        # normal mode (no fed-back clock), covers DQS and non-DQS modes        
        push (@stratix2_syspll_outputs, ("c2", "dedicated_resynch_or_capture_clk"));
        push (@stratix2_syspll_outputs, ("c3", "dedicated_postamble_clk"));
        if ($gCLOCK_GENERATION eq "dedicated") {
            push (@stratix2_syspll_outputs, ("c4", "dedicated_output_clk"));
        };
        
        $module->add_contents
        (
            e_blind_instance->new
            ({
                name 		=> "g_stratixpll_ddr_pll_inst",
                module 		=> "ddr_pll_stratixii",
                comment 	=> "Main PLL, generates system clock, write clock and resynchronization, postamble and (optional) capture clocks",
                comment 	=> " ",
                in_port_map 	=>
                {
                    inclk0 	=> "clock_source",
		    areset  => "pll_reset",								
                },
                out_port_map	=>
                {
                    @stratix2_syspll_outputs,
                    #c0 => "clk",
                    #c1 => "write_clk",
                    #c2 => "dedicated_resynch_or_capture_clk",
                    #c3 => "dedicated_postamble_clk",
                    #c4 => "dedicated_output_clk",							
                },
            }),
        );
    }
} # end of Stratix II PLL section

##########################  CYCLONE   #####################
if ($gpllFAMILY eq "Cyclone") {
    $module->add_contents
    (
        e_blind_instance->new
        ({
            name 		=> "g_cyclonepll_ddr_pll_inst",
            module 		=> "ddr_pll_cyclone",
            comment 	=> " ",
            in_port_map 	=>
            {
                inclk0 	=> "clock_source",
		areset  => "pll_reset",								
            },
            out_port_map	=>
            {
                c0 => "clk",
                c1 => "write_clk",
		locked => "pll_locked",								
            },
        }),
    );
    if ($gFEDBACK_CLOCK_MODE eq "true") {
        $module->add_contents
        (
            e_blind_instance->new
            ({
                name 		=> "g_cyclonepll_ddr_fedback_pll_inst",
                module 		=> "ddr_fedback_pll_cyclone",
                comment 	=> " ",
                in_port_map 	=>
                {
                    inclk0 	=> "$clockfeedback_in_pin_name",
					areset  => "pll_reset",
                },
                out_port_map	=>
                {
                    c0 => "dedicated_resynch_or_capture_clk",
                    c1 => "dedicated_postamble_clk",
					locked => "open",	
                },
            }),
            #e_comment->new({comment => "<< END MEGAWIZARD INSERT PLL\n"}),
        );
    }
} # end of Cyclone PLL section

##########################  CYCLONE II  #####################
if ($gpllFAMILY eq "Cyclone II") {
    if ($gFEDBACK_CLOCK_MODE eq "true") {
        $module->add_contents
        (
            e_blind_instance->new
            ({
                name 		=> "g_cyclonepll_ddr_pll_inst",
                module 		=> "ddr_pll_cycloneii",
                comment 	=> "need to replace the cyclone PLL with cycloneII PLL",
                in_port_map 	=>
                {
                    inclk0 	=> "clock_source",
                    areset  => "pll_reset",	
                },
                out_port_map	=>
                {
                    c0 => "clk",
                    c1 => "write_clk",
                    locked => "pll_locked",	
                    #c2 => "dedicated_resynch_or_capture_clk",
                },
            }),
            e_blind_instance->new
            ({
                name 		=> "g_cyclonepll_ddr_fedback_pll_inst",
                module 		=> "ddr_fedback_pll_cyclone",
                comment 	=> " ",
                in_port_map 	=>
                {
                    inclk0 	=> "$clockfeedback_in_pin_name",
					areset  => "pll_reset",	
                },
                out_port_map	=>
                {
                    c0 => "dedicated_resynch_or_capture_clk",
                    c1 => "dedicated_postamble_clk",
		    		locked => "open",	
                },
            }),
            #e_comment->new({comment => "<< END MEGAWIZARD INSERT PLL\n"}),
        );
    }else
    {
        $module->add_contents
        (
            e_blind_instance->new
            ({
                name 		=> "g_cyclonepll_ddr_pll_inst",
                module 		=> "ddr_pll_cycloneii",
                comment 	=> "need to replace the cyclone PLL with cycloneII PLL",
                in_port_map 	=>
                {
                    inclk0 	=> "clock_source",
		    areset  => "pll_reset",								
                },
                out_port_map	=>
                {
                    c0 => "clk",
                    c1 => "write_clk",
                    c2 => "dedicated_resynch_or_capture_clk",
		    locked => "pll_locked",								
                },
            }),
            #e_comment->new({comment => "<< END MEGAWIZARD INSERT PLL\n"}),
        );
    }
} # end of Cyclone II PLL section

$module->add_contents(
    e_comment->new({comment => "<< END MEGAWIZARD INSERT PLL\n"}),
    e_comment->new({comment => "<< START MEGAWIZARD INSERT DLL\n"}),
);


###############################################################################################################################################
# DLL section
###############################################################################################################################################

# Moving DLL to example instance
if ((($gFAMILY eq "Stratix II")  or ($gFAMILY eq "Stratix")) and ($gENABLE_CAPTURE_CLK ne "true")) {
    
    
    
    if ($gFAMILY eq "Stratix") {
        $module->add_contents
        (
            e_comment->new({comment => "------------------------------------------------------------\n
                    Instantiate Stratix Series DLL for Read DQS Phase shift\n
                    ------------------------------------------------------------\n"}),
            e_blind_instance->new
            ({
                name	 	=> "dll",
                module		=> $gWRAPPER_NAME."_auk_ddr_dll",
                in_port_map		 =>
                {
                    clk 		 => "dqs_ref_clk",
                    reset_n		 => "soft_reset_reg2_n",
                    stratix_dll_control => "stratix_dll_control",
                    # offset      => "6'b000000",
                    # addnsub     => "1'b0",
            
                },
                out_port_map	=>
                {
                    delayctrlout        => "dqs_delay_ctrl",
                    @dqsupdate	    =>	@dqsupdate_list,
                }
            }),
        );
        
    } else {
        
        $module->add_contents
        (
            e_comment->new({comment => "------------------------------------------------------------\n
                    Instantiate Stratix Series DLL for Read DQS Phase shift\n
                    ------------------------------------------------------------\n"}),
            e_blind_instance->new
            ({
                name	 	=> "dll",
                module		=> $gWRAPPER_NAME."_auk_ddr_dll",
                in_port_map		 =>
                {
                    clk 		 => "dqs_ref_clk",
                    reset_n		 => "soft_reset_reg2_n",
                    stratix_dll_control => "stratix_dll_control",
                    offset      => "6'b000000",
                    addnsub     => "1'b0",
            
                },
                out_port_map	=>
                {
                    delayctrlout        => "dqs_delay_ctrl",
                    @dqsupdate	    =>	@dqsupdate_list,
                }
            }),
        );
    }
}

$module->add_contents(e_comment->new({comment => "<< END MEGAWIZARD INSERT DLL\n"}),);

###############################################################################################################################################

if (($gFAMILY eq "Stratix") and ($gENABLE_CAPTURE_CLK ne "true") ) {
    $module->add_contents
    (
        e_comment->new({comment => "<< START MEGAWIZARD INSERT DQS_REF_CLK"}),
        e_comment->new
        ({
            comment => "------------------------------------------------------------\n
            Drive Stratix dqs_ref_clk_out on normal pins using\n
            ALTDDIO_OUT megafunction\n
            ------------------------------------------------------------\n"
        }),
        e_lpm_altddio_out->new
        ({
            name 		=> "dqs_ref_clk_out_p",
            module 		=> "altddio_out",
            port_map 	=>
            {
                datain_h 	=> "stratix_dll_control",
                datain_l	=> "gnd_signal[0]",
                outclock 	=> "clk",
            },
            out_port_map	=>
            {
                dataout  => "stratix_dqs_ref_clk_out",
            },
            parameter_map	=>
            {
                width => 1,#$gNUM_CLOCK_PAIRS,#actual size is 1 but to match the component declaration the width is set to $gNUM_CLOCK_PAIRS
#			    power_up_high => '"OFF"',
                intended_device_family => '"'.$gFAMILY.'"',
#			    oe_reg => '"UNUSED"',
#			    extend_oe_disable => '"UNUSED"',
#			    invert_output => '"OFF"',
#			    lpm_type => '"altddio_out"',
            },
        }),
        e_assign->new({lhs => "gnd_signal[0:0]", rhs => "0"}),
        e_comment->new({comment =>"  \nDQS Reference clock connection for Stratix"}),
        e_assign->new({lhs => "dqs_ref_clk", rhs => "stratix_dqs_ref_clk"}),
        e_comment->new({comment => "<< END MEGAWIZARD INSERT DQS_REF_CLK\n"}),
    );
} elsif (($gFAMILY eq "Stratix II") and ($gENABLE_CAPTURE_CLK ne "true")) 
{
    $module->add_contents
    (
        e_comment->new({comment => "<< START MEGAWIZARD INSERT DQS_REF_CLK"}),
        e_signal->new({name => "stratix_dll_control", width => 1, export => 0, never_export =>  1, declare_one_bit_as_std_logic_vector => 0}),
        e_signal->new({name =>"dqs_delay_ctrl",attribute_string => "$stratixii_dll_verilog_buffer",width => 6,export =>	0,never_export => 1}),
    );
    if ($gFEDBACK_CLOCK_MODE eq "false")
    {
	    $module->add_contents
	    (
		e_assign->new
		({
			lhs => "dqs_ref_clk",
			    rhs => "clk",
			    comment =>"---------------------------------------------------------------\n
			    DQS Reference clock connection for Stratix II\n
			    ---------------------------------------------------------------\n",
		}),
		e_comment->new({comment => "<< END MEGAWIZARD INSERT DQS_REF_CLK\n"}),
	    );
    }else{
	    $module->add_contents
	    (
		e_assign->new
		({
			lhs => "dqs_ref_clk",
			    rhs => "fedback_resynch_clk",
			    comment =>"---------------------------------------------------------------\n
			    DQS Reference clock connection for Stratix II\n
			    ---------------------------------------------------------------\n",
		}),
		e_comment->new({comment => "<< END MEGAWIZARD INSERT DQS_REF_CLK\n"}),
	    );
    }
} else # put in the tags anyway so that the parsing works.  
{
    $module->add_contents
    (
        e_comment->new({comment => "<< START MEGAWIZARD INSERT DQS_REF_CLK"}),
        e_comment->new({comment => "   No reference clock required in non-DQS mode"}),
        e_comment->new({comment => "<< END MEGAWIZARD INSERT DQS_REF_CLK\n"}),
    );
}

######################################################################################################################################################################
# Mark the end of our stuff - everything after this is autogenerated
######################################################################################################################################################################

$module->add_contents(e_comment->new({comment => "<< start europa"}),);

######################################################################################################################################################################
######################################################################################################################################################################
$project->output();
}
1;
#You're done.

