use europa_all;
use europa_utils;

sub write_auk_ddr_datapath
{
my $top = e_module->new({name => $gWRAPPER_NAME."_auk_ddr_datapath"});
my $project = e_project->new({top => $top, language => $language,__system_directory =>$output_directory, timescale => "1ps / 1ps"});
my $module = $project->top();

my $dqs_group_instname;# = "\\g_datapath:\$i:g_ddr_io ";
my $Stratix_Fam = "";
#####   Parameters declaration  ######
my $glocal_data_bits 	=     $gLOCAL_DATA_BITS;
my $gmem_dq_per_dqs	=     $gMEM_DQ_PER_DQS;
my $gfamily  	 	=     $gFAMILY;
my $ginter_resynch     =     $gINTER_RESYNCH;
my $gpostamble_cycle   =     $gPOSTAMBLE_CYCLE;
my $gpostamble_regs    =     $gPOSTAMBLE_REGS;
my $ginter_postamble   =     $gINTER_POSTAMBLE;
my $gpipeline_readdata =     $gPIPELINE_READDATA;
my $gdll_input_frequency      =     $gCLOCK_PERIOD_IN_PS."ps";
my $gstratix_dqs_phase        =     $gDQS_PHASE_SHIFT;
my $gstratixii_dqs_phase      =     $gSTRATIXII_DQS_PHASE_SHIFT;
my $gstratixii_dll_delay_buffer_mode        =     $gSTRATIXII_DLL_DELAY_BUFFER_MODE;
my $gstratixii_dqs_out_mode                 =     $gSTRATIXII_DQS_OUT_MODE;
my $cfamily = $gfamily;
my $cpostamble_cycle = $gpostamble_cycle;
my %fedback_resynch_clk;
my @fedback_resynch_clk;

my %resynch_edge_select;
my @resynch_edge_select;

my %stratix_param;
my @stratix_param;
my %stratixII_param;
my @stratixII_param;

my %dqsupdate;
my @dqsupdate;
my @dqsupdate_list;
if ((($gFAMILY eq "Stratix" or $gFAMILY eq "Stratix II") and $gENABLE_CAPTURE_CLK ne "true") or $gREGTEST_ADD_DLL_PORTS == 1)
{
	$module->add_contents
	(
		e_port->new({comment =>"Stratix only",name => "dqs_delay_ctrl",direction => "input",width =>6}),# $stratix_verilog_ports1 & $stratix_verilog_ports2 in the generator
	);
	%Stratix_Fam = ("dqs_delay_ctrl" => "dqs_delay_ctrl");
}	my @Stratix_Fam = %Stratix_Fam;

if (($gFAMILY eq "Stratix II"))# and ($gENABLE_CAPTURE_CLK ne "true"))
{
# Stratix II only
	$module->add_contents
	(
	#####	Paramenter declaration#	######
		e_parameter->add({name => "gstratixii_dqs_phase", default => $gSTRATIXII_DQS_PHASE_SHIFT, vhdl_type => "NATURAL"}),
		e_parameter->add({name => "gstratixii_dll_delay_buffer_mode", default => $gSTRATIXII_DLL_DELAY_BUFFER_MODE, vhdl_type => "string"}),
		e_parameter->add({name => "gstratixii_dqs_out_mode", default => $gSTRATIXII_DQS_OUT_MODE, vhdl_type => "string"}),
	);
	#28-01-05
	if (($gENABLE_CAPTURE_CLK ne "true") and ($gFEDBACK_CLOCK_MODE eq "true")){
		$fedback_resynch_clk{'fedback_resynch_clk'} = "fedback_resynch_clk";
		$module->add_contents
		(e_port->new({name => "fedback_resynch_clk",direction => "input"}),);
	}
	#28-01-05
	$stratixII_param{'gDLL_INPUT_FREQUENCY'} = '"'.$gdll_input_frequency.'"';
	$stratixII_param{'gSTRATIXII_DLL_DELAY_BUFFER_MODE'} = $gSTRATIXII_DQS_PHASE_SHIFT;
	$stratixII_param{'gSTRATIXII_DLL_DELAY_BUFFER_MODE'} = '"'.$gSTRATIXII_DLL_DELAY_BUFFER_MODE.'"';
	$stratixII_param{'gSTRATIXII_DQS_OUT_MODE'} = '"'.$gSTRATIXII_DQS_OUT_MODE.'"';

    # insert_configurable_resynch_edge_logic
	if ($MIG_FAMILY ne "NONE" or $gIS_HARDCOPY2 eq "true") {
		$resynch_edge_select{'resynch_clk_edge_select'} = "resynch_clk_edge_select";
		$module->add_contents
        (e_port->new({name => "resynch_clk_edge_select", direction => "input"}),);
	}
    
    
}
elsif (($gFAMILY eq "Stratix"))#  and ($gENABLE_CAPTURE_CLK ne "true"))
{
# Stratix only
	$module->add_contents
	(
		e_parameter->add({name => "gstratix_dqs_phase", default => $gDQS_PHASE_SHIFT, vhdl_type => "string"}),
	);
	$stratix_param{'gDLL_INPUT_FREQUENCY'} = '"'.$gdll_input_frequency.'"';
	$stratix_param{'gSTRATIX_DQS_PHASE'} = '"'.$gDQS_PHASE_SHIFT.'"';
}
if (($gFAMILY eq "Stratix II") and ($gENABLE_CAPTURE_CLK ne "true")) {
    if (($gBUFFER_DLL_DELAY_OUTPUT ne "true") and ($gDLL_REF_CLOCK__SWITCHED_OFF_DURING_READS ne "true"))
    {
	$dqsupdate{'dqsupdate'} = "dqsupdate";
	$module->add_contents(e_port->new({name=>"dqsupdate",direction=>"input",width=>1}),);
    }
}
@stratix_param = %stratix_param;
my @stratix_param_sig;my $i=1;
foreach my $sig (@stratix_param) {
# print "$i)-->  $sig  <--\n";
 push (@stratix_param_sig, $sig);
# $i += 1;
}

@stratixII_param = %stratixII_param;
my @stratixII_param_sig;my $i=1;
foreach my $sig (@stratixII_param) {
# print "$i)-->  $sig  <--\n";
 push (@stratixII_param_sig, $sig);
# $i += 1;
}

@fedback_resynch_clk = %fedback_resynch_clk;
my @fedback_resynch_clk_sig;my $i=1;
foreach my $sig (@fedback_resynch_clk) {
# print "$i)-->  $sig  <--\n";
 push (@fedback_resynch_clk_sig, $sig);
# $i += 1;
}

@resynch_edge_select = %resynch_edge_select;
my @fedback_resynch_clk_sig;my $i=1;
foreach my $sig (@resynch_edge_select) {
# print "$i)-->  $sig  <--\n";
 push (@resynch_edge_select_sig, $sig);
# $i += 1;
}



@dqsupdate = %dqsupdate;
foreach my $param(@dqsupdate) {
	push (@dqsupdate_list, $param);
}

######################################################################################################################################################################
	$module->add_contents
	(
	#####	Ports declaration#	######
		e_port->new({name => "clk",direction => "input"}),
		e_port->new({name => "reset_n",direction => "input"}),
		e_port->new({name => "write_clk",direction => "input"}),
		e_port->new({name => "capture_clk",direction => "input"}),
		e_port->new({name => "resynch_clk",direction => "input"}),
		e_port->new({name => "postamble_clk",direction => "input"}),
		e_port->new({name => "ddr_dq",direction => "inout",width =>$gLOCAL_DATA_BITS / 2}),
		e_port->new({name => "ddr_dqs",direction => "inout",width =>$gLOCAL_DATA_BITS / 2 / $gMEM_DQ_PER_DQS,declare_one_bit_as_std_logic_vector => 0}),
		e_port->new({name => "ddr_dm",direction => "output",width =>$gLOCAL_DATA_BITS / 2 / $gMEM_DQ_PER_DQS,declare_one_bit_as_std_logic_vector => 0}),
		e_port->new({name => "control_doing_wr",direction => "input",width =>1}),
		e_port->new({name => "control_wdata_valid",direction => "input",width =>1}),
		e_port->new({name => "control_dqs_burst",direction => "input",width =>1}),
		e_port->new({name => "control_wdata",width=>$gLOCAL_DATA_BITS,direction => "input"}),
#		e_port->new({name => "control_be",width=>$gLOCAL_DATA_BITS / $gMEM_DQ_PER_DQS,direction => "input"}),
		e_port->new({name => "control_be",width=>$gLOCAL_DATA_BITS / 8,direction => "input"}),
		e_port->new({name => "control_doing_rd",direction => "input",width =>1}),
		e_port->new({name => "control_rdata",width => $gLOCAL_DATA_BITS,direction => "output"}),
		e_port->new({name => "clk_to_sdram",direction => "output", width => $gNUM_CLOCK_PAIRS,declare_one_bit_as_std_logic_vector => 0}),
		e_port->new({name => "clk_to_sdram_n",direction => "output", width => $gNUM_CLOCK_PAIRS,declare_one_bit_as_std_logic_vector => 0}),
#########################################################################################################################################################

		e_signal->news #: ["signal", width, export, never_export]
		(
		   ["wdata_temp",$glocal_data_bits,	0,	1],
		   ["rdata_temp",$glocal_data_bits,	0,	1],
		   ["be_temp",$glocal_data_bits / $gmem_dq_per_dqs,	0,	1],
		),
		e_assign->new({lhs => "write_clk_int", rhs => "write_clk", tag => "synthesis"}),
		e_assign->new({lhs => "write_clk_int", rhs => "~clk",,sim_delay => ($gCLOCK_PERIOD_IN_PS/4), tag => "simulation"}),
	);

###############################################################################################################################################################
if ($gFEDBACK_CLOCK_MODE eq "true"){
	$module->add_contents
	(
		e_comment->new({comment => "\n************************"}),
		e_comment->new({comment => " Clock generator module "}),

		e_port->new({name => "fedback_clk_out",direction => "output", width => 1,declare_one_bit_as_std_logic_vector => 0}),
		e_blind_instance->new
		({
			name 		=> "ddr_clk_gen",
			module 		=> $gWRAPPER_NAME."_auk_ddr_clk_gen",
			in_port_map 	=>
			{
				clk                     => "clk",
				reset_n                 => "reset_n",
			},
			out_port_map	=>
			{
				clk_to_sdram     	=> "clk_to_sdram",
				clk_to_sdram_n     	=> "clk_to_sdram_n",
				fedback_clk_out		=> "fedback_clk_out",
			},
		}),
	);
}else
{
	$module->add_contents
	(
		e_comment->new({comment => "\n************************"}),
		e_comment->new({comment => " Clock generator module "}),
        
        e_blind_instance->new
		({
			name 		=> "ddr_clk_gen",
			module 		=> $gWRAPPER_NAME."_auk_ddr_clk_gen",
			in_port_map 	=>
			{
				clk                     => "clk",
				reset_n                 => "reset_n",
			},
			out_port_map	=>
			{
				clk_to_sdram     	=> "clk_to_sdram",
				clk_to_sdram_n     	=> "clk_to_sdram_n",
			},
		}),
	);
}

##################################################################################################################################################################
$module->add_contents(
	e_assign->new({lhs => "resynch_clk_int", rhs => "resynch_clk", tag => "synthesis"}),
	e_assign->new({lhs => "postamble_clk_int", rhs => "postamble_clk", tag => "synthesis"}),
	e_assign->new({lhs => "capture_clk_int", rhs => "capture_clk", tag => "synthesis"}),
);
if($gCONNECT_RESYNCH_CLK_TO eq "write_clk"){
	$module->add_contents(
		e_assign->new({lhs => "resynch_clk_int", rhs => "~clk",sim_delay => ($gCLOCK_PERIOD_IN_PS/4), tag => "simulation"}),
	);
}else{
	$module->add_contents(
		e_assign->new({lhs => "resynch_clk_int", rhs => "resynch_clk",tag => "simulation"}),
	);
}
if($gCONNECT_POSTAMBLE_CLK_TO eq "write_clk"){
	$module->add_contents(
		e_assign->new({lhs => "postamble_clk_int", rhs => "~clk",sim_delay => ($gCLOCK_PERIOD_IN_PS/4), tag => "simulation"}),
	);
}else{
	$module->add_contents(
		e_assign->new({lhs => "postamble_clk_int", rhs => "postamble_clk", tag => "simulation"}),
	);
}
if($gCONNECT_CAPTURE_CLK_TO eq "write_clk"){
	$module->add_contents(
		e_assign->new({lhs => "capture_clk_int", rhs => "~clk",sim_delay => ($gCLOCK_PERIOD_IN_PS/4), tag => "simulation"}),
	);
}else{
	$module->add_contents(
		e_assign->new({lhs => "capture_clk_int", rhs => "capture_clk", tag => "simulation"}),
	);
}
for ($i=0;$i<$gLOCAL_DATA_BITS / 2 /  $gMEM_DQ_PER_DQS; $i++) {

#    $_ = $verilog_bg_inst;
#    s/\$i/$i/g;
#    print DP_OUT  $_;

if ($language eq "vhdl")
{
	$dqs_group_instname = "\\g_datapath\:$i\:g_ddr_io\\";#"g_datapath_".$i."_g_ddr_io";
} else
{
	$dqs_group_instname = "\\g_datapath\:$i\:g_ddr_io ";#"g_datapath_".$i."_g_ddr_io";
}

#################################################################################################################################################################

    my $be_to_dm_mapping = 8 / $gmem_dq_per_dqs; # should be 1 for x8 mode, 2 for for x4 mode
    
	$module->add_contents
	(
		e_comment->new({comment => "\n **********************************"}),
		e_comment->new({comment => " DQS group instantiation for dqs[".$i."] "}),

        e_assign->new(["wdata_temp["."($gmem_dq_per_dqs * 2) * ($i + 1) - 1".":"."($gmem_dq_per_dqs * 2) * $i"."]"
		=> "{control_wdata["."$glocal_data_bits / 2 + $gmem_dq_per_dqs * ($i + 1) - 1".":"."$glocal_data_bits / 2 + $gmem_dq_per_dqs * $i"."],control_wdata["."$gmem_dq_per_dqs * ($i + 1) - 1".":"."$gmem_dq_per_dqs * $i"."]}"]),

		e_assign->new(["control_rdata["."$glocal_data_bits / 2 + $gmem_dq_per_dqs * ($i + 1) - 1".":"."$glocal_data_bits / 2 + $gmem_dq_per_dqs * $i"."]"
		=> "rdata_temp["."$i * ($gmem_dq_per_dqs * 2) + ($gmem_dq_per_dqs * 2) - 1".":"."$i * ($gmem_dq_per_dqs * 2) + $gmem_dq_per_dqs"."]"]),

		e_assign->new(["control_rdata["."$gmem_dq_per_dqs * ($i + 1) - 1".":"."$gmem_dq_per_dqs * $i"."]"
		=> "rdata_temp["."$i * ($gmem_dq_per_dqs * 2) + $gmem_dq_per_dqs - 1".":"."$i * ($gmem_dq_per_dqs * 2)"."]"]),

		e_assign->new(["be_temp["."$i * 2 + 1".":"."$i * 2"."]" => "{control_be[".  int(($i + ($glocal_data_bits / 2) / $gmem_dq_per_dqs)/$be_to_dm_mapping ) ."], control_be[". int($i/$be_to_dm_mapping) ."]}"]),
		#e_assign->new(["be_temp["."$i * 2 + 1".":"."$i * 2"."]" => "{control_be["."$i + ($glocal_data_bits / 2) / $gmem_dq_per_dqs / $be_to_dm_mapping "."], control_be["."$i / $be_to_dm_mapping "."]}"]),

    );


    if(@Stratix_Fam[1] eq "dqs_delay_ctrl")
	{
		$module->add_contents
		(
			e_blind_instance->new
			({
				name 		=> $dqs_group_instname,
				module 		=> $gWRAPPER_NAME."_auk_ddr_dqs_group",
				in_port_map 	=>
				{
					clk                     => "clk",
					reset_n                 => "reset_n",
					write_clk               => "write_clk_int",
					capture_clk         	=> "capture_clk_int",
					resynch_clk         	=> "resynch_clk_int",
					@Stratix_Fam[0]      	=> @Stratix_Fam[1],
					@fedback_resynch_clk	=> @fedback_resynch_clk_sig,
					@dqsupdate	    	=>	@dqsupdate_list,
                   @resynch_edge_select => @resynch_edge_select_sig,
					postamble_clk       	=> "postamble_clk_int",
					control_doing_wr   	=> "control_doing_wr",
					control_wdata_valid 	=> "control_wdata_valid",
					control_dqs_burst   	=> "control_dqs_burst",
					control_doing_rd    	=> "control_doing_rd",

					control_wdata       	=> "wdata_temp["."($gMEM_DQ_PER_DQS * 2) * ($i + 1) - 1".":"."($gMEM_DQ_PER_DQS * 2) * $i"."]",
					control_be          	=> "be_temp["."(($i + 1) * 2) - 1".":"."($i * 2)"."]",
				},
				out_port_map	=>
				{
					control_rdata       	=> "rdata_temp["."($gMEM_DQ_PER_DQS * 2) * ($i + 1) - 1".":"."($gMEM_DQ_PER_DQS * 2) * $i"."]",
					ddr_dm              	=> "ddr_dm["."$i".":"."$i"."]",
				},
				inout_port_map	=>
				{
					ddr_dq              	=> "ddr_dq["."(($i + 1) * $gMEM_DQ_PER_DQS) - 1".":"."($i * $gMEM_DQ_PER_DQS)"."]",
					ddr_dqs             	=> "ddr_dqs["."$i".":"."$i"."]",
				},
				parameter_map 	=>
				{
					# gMEM_DQ_PER_DQS         => $gmem_dq_per_dqs,
					# gPOSTAMBLE_CYCLE        => $cpostamble_cycle,
					# gINTER_RESYNCH          => '"'.$ginter_resynch.'"',
					# gINTER_POSTAMBLE        => '"'.$ginter_postamble.'"',
					# gPIPELINE_READDATA      => '"'.$gpipeline_readdata.'"',
					# gPOSTAMBLE_REGS		=> $gpostamble_regs,
					@stratix_param		=> @stratix_param_sig,
					@stratixII_param	=> @stratixII_param_sig,
				},
			}),
		);
	}else
	{
		$module->add_contents
		(
			e_blind_instance->new
			({
				name 		=> $dqs_group_instname,
				module 		=> $gWRAPPER_NAME."_auk_ddr_dqs_group",
				in_port_map 	=>
				{
					clk                     => "clk",
					reset_n                 => "reset_n",
					write_clk               => "write_clk_int",
					capture_clk         	=> "capture_clk_int",
					resynch_clk         	=> "resynch_clk_int",
					@fedback_resynch_clk	=> @fedback_resynch_clk_sig,
                   @resynch_edge_select => @resynch_edge_select_sig,
					postamble_clk       	=> "postamble_clk_int",
					control_doing_wr   	=> "control_doing_wr",
					control_wdata_valid 	=> "control_wdata_valid",
					control_dqs_burst   	=> "control_dqs_burst",
					control_doing_rd    	=> "control_doing_rd",
					control_wdata       	=> "wdata_temp["."($gMEM_DQ_PER_DQS * 2) * ($i + 1) - 1".":"."($gMEM_DQ_PER_DQS * 2) * $i"."]",
					control_be          	=> "be_temp["."(($i + 1) * 2) - 1".":"."($i * 2)"."]",
				},
				out_port_map	=>
				{
					control_rdata       	=> "rdata_temp["."($gMEM_DQ_PER_DQS * 2) * ($i + 1) - 1".":"."($gMEM_DQ_PER_DQS * 2) * $i"."]",
					ddr_dm              	=> "ddr_dm["."$i".":"."$i"."]",
				},
				inout_port_map	=>
				{
					ddr_dq              	=> "ddr_dq["."(($i + 1) * $gMEM_DQ_PER_DQS) - 1".":"."($i * $gMEM_DQ_PER_DQS)"."]",
					ddr_dqs             	=> "ddr_dqs["."$i".":"."$i"."]",
				},
				parameter_map 	=>
				{
					# gMEM_DQ_PER_DQS         => $gmem_dq_per_dqs,
					# gPOSTAMBLE_CYCLE        => $cpostamble_cycle,
					# gINTER_RESYNCH          => '"'.$ginter_resynch.'"',
					# gINTER_POSTAMBLE        => '"'.$ginter_postamble.'"',
					# gPIPELINE_READDATA      => '"'.$gpipeline_readdata.'"',
					# gPOSTAMBLE_REGS		=> $gpostamble_regs,
					@stratix_param		=> @stratix_param_sig,
					@stratixII_param	=> @stratixII_param_sig,
				},
				std_logic_vector_signals =>
				[
					# # ddr_dm,
					# ddr_dqs,
				],
			}),
		);
	}

};

##################################################################################################################################################################
$project->output();
}
1;

#You're done.

