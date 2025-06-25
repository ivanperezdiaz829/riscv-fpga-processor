#sopc_builder free code
use europa_all; 
use europa_utils;
use e_comment;

my $pipeline_width;
my $pipeline_depth;
my $postfix;
my $mem_num_devices = $gMEM_NUM_DEVICES;
my $local_data_mode = $gLOCAL_DATA_MODE;
my $local_burst_len = $gLOCAL_BURST_LEN;
my $local_data_bits = $gLOCAL_DATA_BITS;
my $mem_num_devices = $gLOCAL_DATA_BITS;
my $reset_port;

sub gen_pipelines{
	for(my $i = 0; $i < 4; $i++){
		if( $i == 0)
		{
			$pipeline_width = int($gMEM_ADDR_BITS+6);
			$pipeline_depth = $gNUM_PIPELINE_ADDR_CMD_STAGES;
			if($pipeline_depth > 0){
				$post_title = " Address and Command Pipeline Module";
				$postfix = "addr_cmd";
				$reset_value = "7";
				$reset_port = "reset_clk_n";
				&write_auk_rldramii_pipeline();
				#print "\n--------------------> doing : $postfix\n";
			}
		}
		if( $i == 1)
		{
			$enable_dm_pins =  $gENABLE_DM_PINS;
			#if($local_data_mode eq "narrow") { 
			if($enable_dm_pins eq "true") {
				$pipeline_width = int(($gLOCAL_DATA_BITS) + ($gMEM_NUM_DEVICES * 2) + 2);
			} else {
				$pipeline_width = int(($gLOCAL_DATA_BITS) + 2);
			}
			#}
			#else {
			#	$pipeline_width = ($gLOCAL_DATA_BITS / $gLOCAL_BURST_LEN) + ($gMEM_NUM_DEVICES * 2) + 2;
			#};
			$pipeline_depth = $gNUM_PIPELINE_WDATA_STAGES;
			
			if($pipeline_depth > 0){	
				$post_title = " Write Data Pipeline Module";
				$postfix = "wdata";
				$reset_value = "0";
				$reset_port = "reset_clk_n";
				#print "\n--------------------> doing : $postfix\n";
				&write_auk_rldramii_pipeline();
			}
		}
		if( $i == 2)
		{
			$pipeline_width = $gMEM_DQ_PER_DQS * 2;
			$pipeline_depth = $gNUM_PIPELINE_RDATA_STAGES;
			if($pipeline_depth > 0){
				$post_title = " Read Data Pipeline Module";
				$postfix = "rdata";
				$reset_value = "0";
				$reset_port = "reset_read_clk_n";
				#print "\n--------------------> doing : $postfix\n";
				&write_auk_rldramii_pipeline();
			}
		}
		if( $i == 3)
		{
			$pipeline_width = 1;
			$pipeline_depth = $gNUM_PIPELINE_QVLD_STAGES;
			if($pipeline_depth > 0){
				$post_title = " QVLD Pipeline Module";
				$postfix = "qvld";
				$reset_value = "0";
				$reset_port = "reset_read_clk_n";
				#print "\n--------------------> doing : $postfix\n";
				&write_auk_rldramii_pipeline();
			}
		}
	}
}


sub write_auk_rldramii_pipeline
{
my $header_title = "RLDRAM II Controller".$post_title;
my $header_filename = $gWRAPPER_NAME . "_auk_rldramii_pipeline_".$postfix. $file_ext;
my $header_revision = "V" . $gWIZARD_VERSION;
my $header_abstract = "This file contains pipelining for the RLDRAM II Controller.";
my $verilog_dq_io_instname;# = "\\g_datapath:\$i:g_ddr_io ";
my $enable_dm_pins =  $gENABLE_DM_PINS;

#####   Parameters declaration  ######
my $top = e_module->new({name => $gWRAPPER_NAME . "_auk_rldramii_pipeline_".$postfix});
my $project = e_project->new({top => $top, language => $language,__system_directory =>$output_directory, timescale => "1ps / 1ps"});
my $module = $project->top();

$module->vhdl_libraries()->{altera_mf} = all;



######################################################################################################################################################################
	$module->comment
	(
		"------------------------------------------------------------------------------\n
		 Title        : $header_title\n Project      : RLDRAM II Controller\n\n\n 
		 File         : $header_filename\n\n 
		 Revision     : $header_revision\n\n
		 Abstract:\n $header_abstract\n\n
		------------------------------------------------------------------------------\nParameters:\n\n		
		 Pipeline for                       : $postfix\n
		 Enable DM Pins                     : $enable_dm_pins\n
		 Pipeline Data Width                : $pipeline_width\n
		 Number of Pipeline Stages          : $pipeline_depth\n
		 ------------------------------------------------------------------------------\n"
	);
#####################################################################################################################################################################
	 $module->add_contents
	 (
	 #####	Ports declaration#	######
		 e_port->new({name => "clk",direction => "input"}),
		 e_port->new({name => $reset_port,direction => "input"}),
		 e_port->new({name => "pipeline_data_in",direction => "input", width => $pipeline_width,declare_one_bit_as_std_logic_vector => 0}),
		 e_port->new({name => "pipeline_data_out",direction => "output", width => $pipeline_width,declare_one_bit_as_std_logic_vector => 0}),
		 e_assign->new({lhs => "reset_n", rhs => $reset_port}),
	 );
#########################################################################################################################################################
$module->add_contents
(
	e_signal->new({name=>"reset_n",width=>1,export=>0,never_export=>1}),
);

#########################################################################################################################################################
my $in;
my $i = 0;
#if($pipeline_depth > 0){
	for( $i = 1; $i < ($pipeline_depth+1); $i++){
		my $j = $i -1;
		if( $i == 1)
		{
			$in = "pipeline_data_in";
		}else
		{
			$in = "pipeline_data_r"."$j";
		}
		 $module->add_contents
		 (
			e_signal->new({name=>"pipeline_data_r"."$i",width=>"$pipeline_width",export=>0,never_export=>1}),
			# e_register->new({
				# q   		=> "pipeline_data_r"."$i",
				# d   		=> $in,
				# async_set   	=> "reset_n",
				# #async_value 	=> "-1",
				# async_value 	=> $reset_value,
				# enable	    	=> 1,
			# })
			
			e_register->new
			({
			     clock		=>	"clk",
			     reset		=>	"reset_n",
			     _async_value	=>	"$reset_value",
			     #clock_level	=>	$device_clk_edge,
                 clock_level	=>	"1",
			     in			=>	"$in",
			     out		=>	"pipeline_data_r"."$i",
			     enable  		=> 	"1",
			     preserve_register  =>	"1",
			}),
		
			# e_process->new
			# ({
				# clock			=>	"clk",
				# reset			=>	"reset_n",
				# comment			=>
				# "-----------------------------------------------------------------------------\n
				# Pipeline register $i
				# -----------------------------------------------------------------------------",
				# _asynchronous_contents	=>	
				# [
					# e_assign->new(["pipeline_data_r"."$i" => "$reset_value"]),
				# ],
				# contents	=>	
				# [
					# e_assign->new({lhs => "pipeline_data_r"."$i", rhs => $in}),
				# ],
			# }),
		 );
		 
	}
	 $module->add_contents
	 (
		e_assign->new(["pipeline_data_out","pipeline_data_r".($i-1)]),
	 );
#}

######################################################################################################################################################################

$project->output();
}
1;
#You're done.
