#sopc_builder free code
use europa_all; 
use europa_utils;
use e_comment;
use e_lpm_stratixii_io;
use e_lpm_stratixiigx_io;
use e_lpm_hardcopyii_io;
use e_component;

sub write_rldramii_dqs_group
{
print "\n\n/*-*-*-*-* gRLDRAMII_TYPE => $gRLDRAMII_TYPE -*-*-*-*-\\n\n";
my $top = e_module->new({name => $gWRAPPER_NAME . "_auk_rldramii_dqs_group"});#, output_file => "d:/OFadeyi/DATA_PATH/temp_gen/".$gWRAPPER_NAME."_auk_ddr_dqs_group"});
my $project = e_project->new({top => $top, language => $language,__system_directory =>$output_directory});#'temp_gen'});
my $module = $project->top();
#$module->vhdl_libraries()->{altera_mf} = all;
#$module->vhdl_libraries()->{$gFAMILY} = all;

#####   Parameters declaration  ######
my $header_title = "RLDRAM II Controller DQS Group";
my $header_filename = $gWRAPPER_NAME . "_auk_rldramii_dqs_group" . $file_ext;
my $header_revision = "V" . $gWIZARD_VERSION;
my $header_abstract = "This file contains the DQS delay logic and RLDRAM II data generation and 
		       capture logic for the RLDRAM II Controller.";
my $dqs_group_instname;# = "\\g_datapath:\$i:g_ddr_io ";
my $q_group_instname;
my $d_group_instname;
my $Stratix_Fam = "";
my %stratix_param  = "";

my $family = $gFAMILY;
my $familylc = $gFAMILYlc;

$module->vhdl_libraries()->{$familylc} = all;

my $io_elem = "e_lpm_".$familylc."_io";

my $rldramii_type = $gRLDRAMII_TYPE;
my $local_data_mode = $gLOCAL_DATA_MODE;
my $local_burst_len = $gLOCAL_BURST_LEN;
my $local_data_bits = $gLOCAL_DATA_BITS;
my $mem_dq_per_dqs = $gMEM_DQ_PER_DQS;
my $mem_addr_bits = $gMEM_ADDR_BITS;
my $num_clock_pairs = $gNUM_CLOCK_PAIRS;
my $mem_addr_bits = $gMEM_ADDR_BITS;
my $mem_num_devices = $gMEM_NUM_DEVICES;
my $rldramii_dw_interface;
my $capture_clk_width;
my $dll_input_frequency = "${gCLOCK_PERIOD_IN_PS}ps";
my $stratixii_dqs_phase                = ${gSTRATIXII_DQS_PHASE_SHIFT}; # 9000/100 "90 degrees",  7200/100 "72 degrees"
my $stratixii_dll_delay_buffer_mode    = "${gSTRATIXII_DLL_DELAY_BUFFER_MODE}";
my $stratixii_dqs_out_mode             = "${gSTRATIXII_DQS_OUT_MODE}";

my $ENABLE_CAPTURE_CLK = $gENABLE_CAPTURE_CLK;

if ($ENABLE_CAPTURE_CLK eq "true") {
	$CAPTURE_MODE = non_dqs;
	$inclk_input = normal;
}
else {
	$CAPTURE_MODE = dqs;
	$inclk_input = dqs_bus;
    }

my $port_num;
####  end parameter list  ######
my %ports_name;
my @ports_name;
my %ports_width;
my @ports_width;
my %ports_dir;
my @ports_dir;

if($local_data_mode eq "narrow")
{
	$rldramii_dw_interface = int($local_data_bits / 2) ;	
	$capture_clk_width = int($local_data_bits / $mem_dq_per_dqs / 2);
	
}elsif($local_data_mode eq "wide")
{
	$rldramii_dw_interface =  int($local_data_bits / $local_burst_len / 2);
	$capture_clk_width = int($local_data_bits / $local_burst_len / $mem_dq_per_dqs / 2);
}
my $local_rldramii_dw_interface = int($rldramii_dw_interface * 2);
if( $rldramii_type eq "cio" )
{
	$ports_name{'ddr_dq'} = "ddr_dq";
	$ports_dir{'inout'}   = "inout";
	$ports_width{'ddr_dq'} = $mem_dq_per_dqs;
	$port_num = 1;
}
elsif ( $rldramii_type eq "sio")
{
	$ports_name{'ddr_d'} = "ddr_d";
	$ports_dir{'output'}   = "output";
	$ports_width{'ddr_d_width'} = $mem_dq_per_dqs;
	$ports_name{'ddr_q'} = "ddr_q";
	$ports_dir{'input'}   = "input";
	$ports_width{'ddr_q_width'} = $mem_dq_per_dqs;
	$port_num = 4;
}
@ports_name = %ports_name;
@ports_width = %ports_width;
@ports_dir = %ports_dir;

my @port_list;my @dir_list;my @width_list;
my $i=1;#print "\n";
foreach my $port (@ports_name ) {
 #print "$i)-->  $port <----\t";
 push (@port_list, $port);
 $i += 1;
}
#print "\n";
$i =1;
foreach my $dir(@ports_dir) {
 #print "$i)-->  $dir <----\t";
 push (@dir_list, $dir);
 $i += 1;
}
#print "\n";
$i =1;
foreach my $width (@ports_width) {
 #print "$i)--> $width <----\t";
 push (@width_list, $width);
 $i += 1;
}
#print "\n";
for ($i=0; $i < $port_num; $i+=2){
	$module->add_contents
	(
		e_port->new({name => @port_list[$i] , direction => @dir_list[$i+1] , width => @width_list[$i+1] , declare_one_bit_as_std_logic_vector => 1}),
	);
}
######################################################################################################################################################################
	#$module->vhdl_libraries()->{stratixii} = all;
	$module->comment
	(
		"------------------------------------------------------------------------------\n
		 Title        : $header_title\n 
		 Project      : RLDRAM II Controller\n\n\n 
		 File         : $header_filename\n\n 
		 Revision     : $header_revision\n\n
		 Abstract:\n$header_abstract\n\n		
		 ----------------------------------------------------------------------------------\n
		 Parameters:\n
		 RLDRAM II Memory Type              : $rldramii_type\n
		 Number DQ Bits per DQS Input       : $mem_dq_per_dqs\n
		 Read Data Capture Mode             : $CAPTURE_MODE\n
		 ----------------------------------------------------------------------------------\n",
	);
######################################################################################################################################################################
if ($ENABLE_CAPTURE_CLK eq "false") {
	$module->add_contents
	(
	#####	Ports declaration#	######
		e_port->new({name => "clk",direction => "input"}),
		e_port->new({name => "reset_clk_n",direction => "input"}),
		e_port->new({name => "write_clk",direction => "input"}),
		e_port->new({name => "ddr_dqs",direction => "input", width => 1 , declare_one_bit_as_std_logic_vector => 0}),
		e_port->new({name => "control_doing_wr", direction => "input"}),
		e_port->new({name => "control_wdata_valid" , direction => "input"}),
		e_port->new({name => "control_wdata", width => $mem_dq_per_dqs * 2, direction => "input"}),
		e_port->new({name => "dqs_delay_ctrl" , direction => "input", width => 6, declare_one_bit_as_std_logic_vector => 1}),
		e_port->new({name => "control_rdata", width => $mem_dq_per_dqs * 2 ,direction => "output"}),
		e_port->new({name => "dqs_group_capture_clk", width => 1 ,direction => "output"}),
        e_port->new({name => "dq_capture_clk", width => 1 ,direction => "output"}),
	);
}
else
{
	$module->add_contents
	(
	#####	Ports declaration#	######
		e_port->new({name => "clk",direction => "input"}),
		e_port->new({name => "reset_clk_n",direction => "input"}),
		e_port->new({name => "write_clk",direction => "input"}),
		e_port->new({name => "non_dqs_capture_clk",direction => "input"}),
		e_port->new({name => "control_doing_wr", direction => "input"}),
		e_port->new({name => "control_wdata_valid" , direction => "input"}),
		e_port->new({name => "control_wdata", width => $mem_dq_per_dqs * 2, direction => "input"}),
		e_port->new({name => "control_rdata", width => $mem_dq_per_dqs * 2 ,direction => "output"}),
	);
}

#########################################################################################################################################################
	$module->add_contents
	(
	#####   signal generation #####
		e_signal->news #: ["signal", width, export, never_export]
		(
		  	["dqs_oe",1,	0,	1],
		  
		  	["rdata",$mem_dq_per_dqs * 2,	0,	1],
		  	["wdata",$mem_dq_per_dqs * 2,	0,	1],
		  	["wdata_r",$mem_dq_per_dqs * 2,	0,	1],
		  	["wdata_valid",1,	0,	1],
		  	["doing_wr",1,	0,	1],
		  
		  	["ONE",1,	0,	1],
		  	#["ZERO",1,	0,	1],
		  	["ZEROS",$mem_dq_per_dqs,	0,	1], 

		  	["dq_captured_rising",$mem_dq_per_dqs,		0,	1],
		  	["dq_captured_falling",$mem_dq_per_dqs,		0,	1],
            
            ["internal_ddr_dqs",1,	0,	1],
		),
		  	e_signal->new({name => "dq_capture_clk",width => 1,export => 0,never_export =>1,declare_one_bit_as_std_logic_vector => 0}),
		  	#e_signal->new({name => "reset",         width =>  1,export => 0,never_export => 1,declare_one_bit_as_std_logic_vector => 0}),
		  	e_signal->new({name => "dqs_clk",         width =>  1,export => 0,never_export => 1,declare_one_bit_as_std_logic_vector => 1}),
            e_signal->new({name => "dqs_clk_undelayed",         width =>  1,export => 0,never_export => 1,declare_one_bit_as_std_logic_vector => 1}),
		  	e_signal->new({name => "dqs_oe_r",         width =>  1,export => 0,never_export => 1,declare_one_bit_as_std_logic_vector => 1}),
		  	e_signal->new({name => "dqs_pin",         width =>  1,export => 0,never_export => 1,declare_one_bit_as_std_logic_vector => 1}),
		  	e_signal->new({name => "undelayed_dqs",   width =>  1,export => 0,never_export => 1,declare_one_bit_as_std_logic_vector => 1}),
		  	#e_signal->new({name => "not_dqs_clk",   width =>  1,export => 0,never_export => 1,declare_one_bit_as_std_logic_vector => 1}),
		 );
###############################################################################################################################################################
	$module->add_contents
	(
		e_assign->new({lhs => "ONE", rhs => "1'b1", comment => "\n\n"}),
		#e_assign->new(["ZERO" => "1'b0"]),
		e_assign->new(["ZEROS" => "0"]),
		#e_assign->new(["reset" => "~reset_clk_n"]),
		#e_assign->new(["not_dqs_clk" => "~dqs_clk"]),
		e_assign->new({lhs => "control_rdata", rhs=> "rdata",comment => " rename user i/f signals, outputs"}),
		e_assign->new({lhs => "wdata", rhs=> "control_wdata",comment => " rename user i/f signals, inputs"}),
		e_assign->new(["wdata_valid" => "control_wdata_valid"]),
		e_assign->new(["doing_wr" => "control_doing_wr"]),
		e_assign->new(["rdata" => "{dq_captured_falling, dq_captured_rising}"]),
	);
###############################################################################################################################################################
if ($ENABLE_CAPTURE_CLK eq "false") {
	$module->add_contents
	(
		e_signal->new({name => "not_dqs_clk",   width =>  1,export => 0,never_export => 1,declare_one_bit_as_std_logic_vector => 0}),
		e_assign->new(["not_dqs_clk" => "~dqs_clk[0:0]"]),
        e_assign->new(["internal_ddr_dqs" => "ddr_dqs"]),
	);
}

##############################################################################################################################################################
	if ($ENABLE_CAPTURE_CLK eq "false") {
		$module->add_contents
		(
			e_signal->new({name => "ZERO",   width =>  1,export => 0,never_export => 1}),
			e_assign->new(["ZERO" => "1'b0"]),
			e_comment->new({comment => "\nDQS Input\n"}),
		

			$io_elem->new
			({
				name 		=> "dqs_io",
				module 		=> $familylc."_io",
				comment 	=> "DQS pin",
				port_map 	=>
				{
					#areset          => "ONE",
					datain 		=> "ZEROS[0]",
					ddiodatain 	=> "ZEROS[0]",
					outclk 		=> "ZERO",
					outclkena 	=> "ZERO",
					oe 		=> "ZERO",
					#inclk       	=> "not_dqs_clk",#[]",#"ZERO",
                    #inclk       	=> "",#[]",#"ZERO",
					inclkena    	=> "ONE",
#					sreset      	=> "ZERO",
#					ddioinclk   	=> "ZEROS[0]",
					delayctrlin 	=> "dqs_delay_ctrl",
				# },
				# out_port_map	=>
				# {
	#				combout 	=> "open",
                    combout 	=> "dqs_clk_undelayed[0:0]",
					dqsbusout 	=> "dqs_clk[0:0]",
#					ddioregout        => "open",
#					regout            => "open",
				# },
				# inout_port_map 	=>
				# {
					padio 		=> "internal_ddr_dqs",
				},
				# _port_default_values =>
				# {
							 # delayctrlin	=> "6",
				# },
				std_logic_vector_signals =>
				[
					delayctrlin,
				],
				parameter_map 	=>
				{
					bus_hold  =>'"false"',
					#ddio_mode => '"bidir"',#'"input"',
                    ddio_mode => '"none"',#'"input"',
					ddioinclk_input  =>'"negated_inclk"',
	
#					dqs_ctrl_latches_enable => '"false"',
					dqs_delay_buffer_mode => '"'.$stratixii_dll_delay_buffer_mode.'"',
					dqs_edge_detect_enable => '"false"',
					dqs_input_frequency => '"'.$dll_input_frequency.'"',
					dqs_offsetctrl_enable => '"false"',
					dqs_out_mode => '"'.$stratixii_dqs_out_mode.'"',
	
					dqs_phase_shift => $stratixii_dqs_phase,
					extend_oe_disable => '"false"',
	
					gated_dqs => '"false"',#'"true"',
					#inclk_input => '"'.$inclk_input.'"',
                    inclk_input => '"normal"',
					input_async_reset => '"none"',
					input_power_up => '"high"',
					#input_register_mode => '"register"',
                    input_register_mode => '"none"',
#					input_sync_reset => '"clear"',
#					lpm_type  =>'"'.$familylc."_io".'"',
#					oe_async_reset => '"none"',
#					oe_power_up => '"low"',
#					oe_register_mode => '"none"',#'"register"',
#					oe_sync_reset => '"none"',
#					open_drain_output => '"false"',
					operation_mode => '"input"',#'"input"',
#					output_async_reset => '"none"',
	
#					output_power_up => '"low"',
					#output_register_mode => '"register"',#'"none"',
                    output_register_mode => '"none"',#'"none"',
#					output_sync_reset => '"none"',
					sim_dqs_delay_increment => 36,
					sim_dqs_intrinsic_delay => 900,
					sim_dqs_offset_increment => 0,
#					tie_off_oe_clock_enable => '"false"',
#					tie_off_output_clock_enable => '"false"',
				},
	
			}),
		);
	}

##################################################################################################################################################################
 
	 $module->add_contents
	 (
 
		 e_process->new
		 ({
		      clock			=>	"clk",
		      reset			=>	"reset_clk_n",
		      comment			=>
		      "-----------------------------------------------------------------------------\n
 
		       Write data registers\n
		       \n
 
		       These are the last registers before the registers in the altddio_bidir. They\n
		       are clocked off the system clock but feed registers which are clocked off the\n
		       write clock, so their output is the beginning of 3/4 cycle path.\n
		       -----------------------------------------------------------------------------",
		      _asynchronous_contents	=>	
		      [
			 e_assign->new(["wdata_r" => "0"]),
		      ],
		      contents	=>	
		      [
		     	 e_if->new
			 ({
				 condition	=> "wdata_valid",
				 then		=>
				 [
					 e_assign->new({lhs => "wdata_r", rhs => "wdata",comment => "don't latch in data unless it's valid"}),
				 ],
			 }),
		      ],
		 }),
		 
	 );

##################################################################################################################################################################


if ($ENABLE_CAPTURE_CLK eq "false") {
	$module->add_contents
	(
		#e_assign->new({lhs => "dqs_group_capture_clk" , rhs => "! dqs_clk_undelayed[0:0]", comment => "\nAssign system capture clock \n"}),
        e_assign->new({lhs => "dqs_group_capture_clk" , rhs => "! dqs_clk_undelayed[0:0]", comment => "\nAssign system capture clock \n"}),
		e_assign->new({lhs => "dq_capture_clk" , rhs => "! dqs_clk[0:0]" , comment => "\nRead data capture clock\n"}),
        #e_assign->new({lhs => "dq_capture_clk" , rhs => "dqs_group_capture_clk" , comment => "\nRead data capture clock\n"}),
	);
}
else
{
	$module->add_contents
	(
		e_assign->new({lhs => "dq_capture_clk" , rhs => "non_dqs_capture_clk" , comment => "\nRead data capture clock\n"}),
	);
}

if( $rldramii_type eq "cio" )
{
	$module->add_contents
	(
		e_signal->new(["dq_oe",1,	0,	1]),#enable signal for the dq pins
		# e_signal->new({name => "dq_oe", width => 1, export => 0, never_export => 1, attribute_string => "preserve"}),#enable signal for the dq pins
		# e_process->new
		# ({
		#      clock			=>	"clk",
		#      reset			=>	"reset_clk_n",
		#      comment			=>
		#      "-----------------------------------------------------------------------------\n
		#       DQ pins and their logic
		#      -----------------------------------------------------------------------------",
		#      _asynchronous_contents	=>	
		#      [

		# 	e_assign->new(["dq_oe" => "1'b0"]),
		#      ],
		#      contents	=>	
		#      [
		# 	e_assign->new({lhs => "dq_oe", rhs => "doing_wr"}),
		#      ],
		# }),
		
		e_comment->new({comment	=>
		     "-----------------------------------------------------------------------------\n
		      DQ pins and their logic
		     -----------------------------------------------------------------------------",
		}),
		e_register->new
		({
		     clock		=>	"clk",
		     reset		=>	"reset_clk_n",
		     in			=>	"doing_wr",
		     out		=>	"dq_oe",
		     enable  		=> 	"1",
		     preserve_register  =>	"1",
		}),
	);
	for ($i=0; $i < $mem_dq_per_dqs; $i++) 
	{
		if ($language eq "vhdl") {
		    $dqs_group_instname = "g_dq_io_".$i."_dq_io";
		} else {
		    $dqs_group_instname = "g_dq_io_".$i."_dq_io";
		}
		my $wdata_r = $i + $mem_dq_per_dqs;
		$module->add_contents
		(
			$io_elem->new
			({
				name 		=> $dqs_group_instname,
				module 		=> $familylc."_io",
				suppress_open_ports   => 1,
				#_use_generated_component=>0,
				tag		=> "synthesis",
				#in_port_map 	=>
				port_map 	=>
				{
					####areset          => "reset",
					datain          => "wdata_r[$i]",
					ddiodatain      => "wdata_r[".$wdata_r."]",
					inclkena        => "ONE",
					inclk           => "dq_capture_clk",
					outclkena       => "ONE",
					outclk          => "write_clk",
					oe              => "dq_oe",
#					ddioinclk	=> "ZEROS[0]",
					delayctrlin	=> "open",
#					sreset      	=> "ZEROS[0]"
				# },
				# inout_port_map	=>
				# {
					padio           => "ddr_dq[$i]",
				# },
				# out_port_map	=>
				# {
					ddioregout  => "dq_captured_rising[$i]",
					regout      => "dq_captured_falling[$i]",
				},
				# std_logic_vector_signals =>
				# [
					# delayctrlin,
				# ],
				# _port_default_values =>
				# {
					 # delayctrlin	=> "6",
				# },
				parameter_map 	=>
				{
					ddio_mode            => '"bidir"',
					ddioinclk_input      => '"negated_inclk"',
					extend_oe_disable    => '"false"',
					inclk_input          => '"'.$inclk_input.'"',
					input_async_reset    => '"none"',
					input_power_up       => '"low"',
					input_register_mode  => '"register"',
					input_sync_reset  =>  '"none"',
					
					oe_async_reset       => '"none"',
					oe_power_up          => '"low"',
					oe_register_mode     => '"register"',
					oe_sync_reset  =>  '"none"',
					
					operation_mode       => '"bidir"',
					output_async_reset   => '"none"',
					output_power_up      => '"low"',
					output_register_mode => '"register"',
					output_sync_reset =>  '"none"',
					
					bus_hold 		=> '"false"',

					sim_dqs_delay_increment =>  0,
					sim_dqs_intrinsic_delay =>  0,
					sim_dqs_offset_increment => 0,
					tie_off_oe_clock_enable => '"false"',
					tie_off_output_clock_enable => '"false"',
					dqs_input_frequency  =>  '"none"',
					dqs_out_mode  =>  '"none"',
					dqs_delay_buffer_mode  =>  '"none"',
					dqs_phase_shift => 0,
					dqs_offsetctrl_enable  =>  '"false"',
					dqs_ctrl_latches_enable  =>  '"false"',
					dqs_edge_detect_enable  =>  '"false"',
					gated_dqs  =>  '"false"',
					
					lpm_type  =>  '"'.$familylc."_io".'"',
					open_drain_output  =>  '"false"',
				},
			}),
			$io_elem->new
			({
				name 		=> $dqs_group_instname,
				module 		=> $familylc."_io",
				suppress_open_ports   => 1,
				#_use_generated_component=>0,
				tag		=> "simulation",
				#in_port_map 	=>
				port_map 	=>
				{
					datain          => "wdata_r[$i]",
					ddiodatain      => "wdata_r[".$wdata_r."]",
					inclkena        => "ONE",
					inclk           => "dq_capture_clk",
					outclkena       => "ONE",
					outclk          => "write_clk",
					oe              => "dq_oe",
#					ddioinclk	=> "ZEROS[0]",
#					delayctrlin	=> "ZEROS[5:0]",
#					sreset      	=> "ZEROS[0]"
				# },
				# inout_port_map	=>
				# {
					padio           => "ddr_dq[$i]",
				# },
				# out_port_map	=>
				# {
					ddioregout  => "dq_captured_rising[$i]",
					regout      => "dq_captured_falling[$i]",
				},
				# std_logic_vector_signals =>
				# [
					# delayctrlin,
				# ],
				# _port_default_values =>
				# {
					 # delayctrlin	=> "6",
				# },
				parameter_map 	=>
				{
					ddio_mode            => '"bidir"',
					ddioinclk_input      => '"negated_inclk"',
					extend_oe_disable    => '"false"',
					inclk_input          => '"'.$inclk_input.'"',
					input_async_reset    => '"none"',
					#input_async_reset    => '"clear"',
					input_power_up       => '"low"',
					input_register_mode  => '"register"',
					input_sync_reset  =>  '"none"',

					oe_async_reset       => '"none"',
					oe_power_up          => '"low"',
					oe_register_mode     => '"register"',
					oe_sync_reset  =>  '"none"',

					operation_mode       => '"bidir"',
					output_async_reset   => '"none"',
					output_power_up      => '"low"',
					output_register_mode => '"register"',
					output_sync_reset =>  '"none"',
	
					bus_hold 		=> '"false"',
					sim_dqs_delay_increment =>  0,
					sim_dqs_intrinsic_delay =>  0,
					sim_dqs_offset_increment => 0,
					tie_off_oe_clock_enable => '"false"',
					tie_off_output_clock_enable => '"false"',
					dqs_input_frequency  =>  '"none"',
					dqs_out_mode  =>  '"none"',
					dqs_delay_buffer_mode  =>  '"none"',
					dqs_phase_shift => 0,
					dqs_offsetctrl_enable  =>  '"false"',
					dqs_ctrl_latches_enable  =>  '"false"',
					dqs_edge_detect_enable  =>  '"false"',
					gated_dqs  =>  '"false"',
					lpm_type  =>  '"'.$familylc."_io".'"',
					open_drain_output  =>  '"false"',
				},
			}),
		);
	}
}
elsif ($rldramii_type eq "sio")
{
	if ($ENABLE_CAPTURE_CLK eq "true") {
		$module->add_contents
		(
			e_signal->new({name => "ZERO",   width =>  1,export => 0,never_export => 1}),
			e_assign->new(["ZERO" => "1'b0"]),
		),
	}
	
	$module->add_contents
	(
		e_signal->new(["d_oe", 1,	0,	1]),#enable signal for the d pins
		e_signal->new(["d_pin", $mem_dq_per_dqs,	0,	1]),#enable signal for the q pins
		e_signal->new(["q_pin", $mem_dq_per_dqs,	0,	1]),#enable signal for the q pins
		e_assign->new({rhs => "d_pin", lhs => "ddr_d"}),
		e_assign->new({lhs => "q_pin", rhs => "ddr_q"}),
		# e_process->new
		# ({
		#      clock			=>	"clk",
		#      reset			=>	"reset_clk_n",
		#      comment			=>
		#      "-----------------------------------------------------------------------------\n
		#       D pins and their logic
		#      -----------------------------------------------------------------------------",
		#      _asynchronous_contents	=>	
		#      [
		# 	e_assign->new(["d_oe" => "1'b0"]),
		#      ],
		#      contents	=>	
		#      [
		# 	e_assign->new({lhs => "d_oe", rhs => "doing_wr"}),
		#      ],
		# }),
		e_comment->new({comment	=>
		     "-----------------------------------------------------------------------------\n
		      D pins and their logic
		     -----------------------------------------------------------------------------",
		}),
		e_register->new
		({
		     clock		=>	"clk",
		     reset		=>	"reset_clk_n",
		     in			=>	"doing_wr",
		     out		=>	"d_oe",
		     enable  		=> 	"1",
		     preserve_register  =>	"1",
		}),
		e_comment->new({comment => "Instatiation of the stratixii io module for the write path in sio mode.\n
					 The 'ddio_mode' and the 'operation_mode' parameter have to be set to output\n
					 for the 'd' path and to input for the 'q' path\n"}),
	);
	for ($i=0; $i < $mem_dq_per_dqs; $i++) 
	{
		if ($language eq "vhdl") {
		    $d_group_instname = "g_d_io_".$i."_d_io";
		    $q_group_instname = "g_q_io_".$i."_q_io";
		} else {
		    $d_group_instname = "g_d_io_".$i."_d_io";
		    $q_group_instname = "g_q_io_".$i."_q_io";
		}
		my $wdata_r = $i + $mem_dq_per_dqs;
		$module->add_contents
		(
			#e_signal->new({name => "ZERO",   width =>  1,export => 0,never_export => 1}),
			#e_assign->new(["ZERO" => "1'b0"]),
			$io_elem->new
			({
				name 			=> $d_group_instname,
				module 			=> $familylc."_io",
				tag			=> "synthesis",
				#_use_generated_component=>0,
				#in_port_map 		=>
				port_map 		=>
				{
					####areset          => "reset",
					datain          => "wdata_r[$i]",
					ddiodatain      => "wdata_r[".$wdata_r."]",
					#inclkena        => "ZERO",
					#inclk           => "ZERO",
					outclkena       => "ONE",
					outclk          => "write_clk",#"ddr_dqs",#[]",
					oe              => "d_oe",#"dq_oe",
					#ddioinclk	=> "ZEROS[0]",
					delayctrlin	=> "open",#"ZEROS[5:0]",
					#sreset      	=> "ZEROS[0]"
				# },
				# inout_port_map	=>
				# {
					padio           => "d_pin[$i]",#"ddr_d[$i]",
				# },
				# out_port_map	=>
				# {
#					ddioregout  	=> "open",
#					regout      	=> "open",
#					dqsbusout   	=> "open",
#					combout	    => "open",
				},
				# std_logic_vector_signals =>
				# [
					# delayctrlin,
				# ],
				# _port_default_values =>
				# {
					 # delayctrlin	=> "6",
				# },
				parameter_map 	=>
				{
					ddio_mode            		=>  '"output"',#'"bidir"',
					ddioinclk_input      		=>  '"negated_inclk"',
					extend_oe_disable    		=>  '"false"',
					operation_mode       		=>  '"output"',#'"bidir"',
					
					inclk_input          		=>  '"normal"',
					input_async_reset   		=>  '"none"',
					input_power_up       		=>  '"low"',
					input_register_mode  		=>  '"none"',
					input_sync_reset  		=>  '"none"',
					
					oe_async_reset       		=>  '"none"',
					oe_power_up          		=>  '"low"',
					oe_register_mode     		=>  '"register"',
					oe_sync_reset 			=>  '"none"',
					
					output_async_reset   		=>  '"none"',
					output_power_up      		=>  '"low"',
					output_register_mode 		=>  '"register"',
					output_sync_reset 		=>  '"none"',
					
					bus_hold 			=>  '"false"',
					sim_dqs_delay_increment 	=>  0,
					sim_dqs_intrinsic_delay 	=>  0,
					sim_dqs_offset_increment 	=>  0,
					tie_off_oe_clock_enable 	=>  '"false"',
					tie_off_output_clock_enable 	=>  '"false"',
					dqs_input_frequency  		=>  '"none"',
					dqs_out_mode  			=>  '"none"',
					dqs_delay_buffer_mode  		=>  '"none"',
					dqs_phase_shift 		=>  0,
					dqs_offsetctrl_enable  		=>  '"false"',
					dqs_ctrl_latches_enable  	=>  '"false"',
					dqs_edge_detect_enable  	=>  '"false"',
					gated_dqs  			=>  '"false"',
					lpm_type  			=>  '"'.$familylc."_io".'"',
					open_drain_output  		=>  '"false"',
				},
			}),
			
			$io_elem->new
			({
				name 		=> $q_group_instname,
				module 		=> $familylc."_io",
				tag		=> "synthesis",
#				_use_generated_component=>0,
#				in_port_map 	=>
				port_map 	=>
				{
					#####areset          => "reset",
					#datain          => "ZERO",
					#ddiodatain      => "ZERO",
					inclkena        => "ONE",
					inclk           => "dq_capture_clk",
					#outclkena       => "ZERO",#"ONE",
					#outclk          => "ZERO",#"dq_capture_clk",#[]",
					#oe              => "ZERO",#"dq_oe",
					ddioinclk	=> "ZEROS[0]",
					delayctrlin	=> "open",#"ZEROS[5:0]",
					#sreset      	=> "ZEROS[0]",
				# },
				# inout_port_map	=>
				# {
					padio           => "q_pin[$i]",#"ddr_q[$i]",
				# },
				# out_port_map	=>
				# {
					ddioregout  	=> "dq_captured_rising[$i]",
					regout      	=> "dq_captured_falling[$i]",
#					dqsbusout   	=> "open",
#					combout	    	=> "open",
				},
				# std_logic_vector_signals =>
				# [
					# delayctrlin,
				# ],
				# _port_default_values =>
				# {
					 # delayctrlin	=> "6",
				# },
				parameter_map 	=>
				{
					ddio_mode            		=>  '"input"',#'"bidir"',
					ddioinclk_input      		=>  '"negated_inclk"',
					extend_oe_disable    		=>  '"false"',
					operation_mode       		=>  '"input"',#'"bidir"',
					
					inclk_input          		=> '"'.$inclk_input.'"',
					input_async_reset    		=>  '"none"',
					input_power_up      		=>  '"low"',
					input_register_mode  		=>  '"register"',
					input_sync_reset  		=>  '"none"',
					
					oe_async_reset       		=>  '"none"',#'"clear"',
					oe_power_up         		=>  '"low"',
					oe_register_mode     		=>  '"none"',#'"register"',
					oe_sync_reset  			=>  '"none"',
					
					output_async_reset   		=>  '"none"',
					output_power_up      		=>  '"low"',
					output_register_mode 		=>  '"none"',
					output_sync_reset 		=>  '"none"',
					
					bus_hold 			=>  '"false"',
					sim_dqs_delay_increment 	=>  0,
					sim_dqs_intrinsic_delay 	=>  0,
					sim_dqs_offset_increment 	=>  0,
					tie_off_oe_clock_enable 	=>  '"false"',
					tie_off_output_clock_enable 	=>  '"false"',
					dqs_input_frequency  		=>  '"none"',
					dqs_out_mode  			=>  '"none"',
					dqs_delay_buffer_mode  		=>  '"none"',
					dqs_phase_shift 		=>  0,
					dqs_offsetctrl_enable  		=>  '"false"',
					dqs_ctrl_latches_enable  	=>  '"false"',
					dqs_edge_detect_enable  	=>  '"false"',
					gated_dqs  			=>  '"false"',
					lpm_type  			=>  '"'.$familylc."_io".'"',
					open_drain_output  		=>  '"false"',
				},
			}),
			$io_elem->new
			({
				name 			=> $d_group_instname,
				module 			=> $familylc."_io",
				tag			=> "simulation",
#				_use_generated_component=>0,
#				in_port_map 		=>
				port_map 		=>
				{
					####areset          => "reset",
					datain          => "wdata_r[$i]",
					ddiodatain      => "wdata_r[".$wdata_r."]",
					inclkena        => "ZERO",
#					inclk           => "ZERO",
					outclkena       => "ONE",
					outclk          => "write_clk",#"ddr_dqs",#[]",
					oe              => "d_oe",#"dq_oe",
#					ddioinclk	=> "ZEROS[0]",
#					delayctrlin	=> "ZEROS[5:0]",
#					sreset      	=> "ZEROS[0]"
				# },
				# inout_port_map	=>
				# {
					padio           => "d_pin[$i]",#"ddr_d[$i]",
				# },
				# out_port_map	=>
				# {
					# ddioregout  	=> "open",
					# regout      	=> "open",
					# dqsbusout   	=> "open",
					# combout	    	=> "open",
				},
				# std_logic_vector_signals =>
				# [
					# delayctrlin,
				# ],
				# _port_default_values =>
				# {
					 # delayctrlin	=> "6",
				# },
				parameter_map 	=>
				{
					ddio_mode            		=>  '"output"',#'"bidir"',
					ddioinclk_input      		=>  '"negated_inclk"',
					extend_oe_disable    		=>  '"false"',
					operation_mode       		=>  '"output"',#'"bidir"',
					
					inclk_input          		=>  '"normal"',
					input_async_reset   		=>  '"none"',
					input_power_up       		=>  '"low"',
					input_register_mode  		=>  '"none"',
					input_sync_reset  		=>  '"none"',
						
					oe_async_reset       		=>  '"none"',
					oe_power_up          		=>  '"low"',
					oe_register_mode     		=>  '"register"',
					oe_sync_reset 			=>  '"none"',
						
					output_async_reset   		=>  '"none"',
					output_power_up      		=>  '"low"',
					output_register_mode 		=>  '"register"',
					output_sync_reset 		=>  '"none"',
						
					bus_hold 			=>  '"false"',
					sim_dqs_delay_increment 	=>  0,
					sim_dqs_intrinsic_delay 	=>  0,
					sim_dqs_offset_increment 	=>  0,
					tie_off_oe_clock_enable 	=>  '"false"',
					tie_off_output_clock_enable 	=>  '"false"',
					dqs_input_frequency  		=>  '"none"',
					dqs_out_mode  			=>  '"none"',
					dqs_delay_buffer_mode  		=>  '"none"',
					dqs_phase_shift 		=>  0,
					dqs_offsetctrl_enable  		=>  '"false"',
					dqs_ctrl_latches_enable  	=>  '"false"',
					dqs_edge_detect_enable  	=>  '"false"',
					gated_dqs  			=>  '"false"',
					lpm_type  			=>  '"'.$familylc."_io".'"',
					open_drain_output  		=>  '"false"',
				},
			}),
			$io_elem->new
			({
				name 		=> $q_group_instname,
				module 		=> $familylc."_io",
				tag		=> "simulation",
#				_use_generated_component=>0,
#				in_port_map 	=>
				port_map 		=>
				{
					####areset          => "reset",
#					datain          => "ZERO",
#					ddiodatain      => "ZERO",
					inclkena        => "ONE",
					inclk           => "dq_capture_clk",
#					outclkena       => "ONE",
#					outclk          => "ZERO",#"dq_capture_clk",#[]",
					oe              => "ZERO",#"dq_oe",
#					ddioinclk	=> "ZEROS[0]",
#					delayctrlin	=> "ZEROS[5:0]",
#					sreset      	=> "ZEROS[0]",
				# },
				# inout_port_map	=>
				# {
					padio           => "q_pin[$i]",#"ddr_q[$i]",
				# },
				# out_port_map	=>
				# {
					ddioregout  	=> "dq_captured_rising[$i]",
					regout      	=> "dq_captured_falling[$i]",
					# dqsbusout   	=> "open",
					# combout	    	=> "open",
				},
				# std_logic_vector_signals =>
				# [
					# delayctrlin,
				# ],
				# _port_default_values =>
				# {
					 # delayctrlin	=> "6",
				# },
				parameter_map 	=>
				{
					ddio_mode            		=>  '"input"',#'"bidir"',
					ddioinclk_input      		=>  '"negated_inclk"',
					extend_oe_disable    		=>  '"false"',
					operation_mode       		=>  '"input"',#'"bidir"',
					
					inclk_input          		=> '"'.$inclk_input.'"',
					input_async_reset    		=>  '"none"',
					input_power_up      		=>  '"low"',
					input_register_mode  		=>  '"register"',
					input_sync_reset  		=>  '"none"',
						
					oe_async_reset       		=>  '"none"',#'"clear"',
					oe_power_up         		=>  '"low"',
					oe_register_mode     		=>  '"none"',#'"register"',
					oe_sync_reset  			=>  '"none"',
						
					output_async_reset   		=>  '"none"',
					output_power_up      		=>  '"low"',
					output_register_mode 		=>  '"none"',
					output_sync_reset 		=>  '"none"',
						
					bus_hold 			=>  '"false"',
					sim_dqs_delay_increment 	=>  0,
					sim_dqs_intrinsic_delay 	=>  0,
					sim_dqs_offset_increment 	=>  0,
					tie_off_oe_clock_enable 	=>  '"false"',
					tie_off_output_clock_enable 	=>  '"false"',
					dqs_input_frequency  		=>  '"none"',
					dqs_out_mode  			=>  '"none"',
					dqs_delay_buffer_mode  		=>  '"none"',
					dqs_phase_shift 		=>  0,
					dqs_offsetctrl_enable  		=>  '"false"',
					dqs_ctrl_latches_enable  	=>  '"false"',
					dqs_edge_detect_enable  	=>  '"false"',
					gated_dqs  			=>  '"false"',
					lpm_type  			=>  '"'.$familylc."_io".'"',
					open_drain_output  		=>  '"false"',
				},
			}),
		);
	}
}
	

#################################################################################################################################################################
##################################################################################################################################################################
##################################################################################################################################################################
$project->output();
}
1;
#You're done.
