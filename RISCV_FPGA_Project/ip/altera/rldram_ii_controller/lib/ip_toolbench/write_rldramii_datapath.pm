#sopc_builder free code
use europa_all; 
use europa_utils;


sub write_auk_rldramii_datapath
{
my $top = e_module->new({name => $gWRAPPER_NAME."_auk_rldramii_datapath"});#, output_file => 'd:/OFadeyi/DATA_PATH/temp_gen/'});
my $project = e_project->new({top => $top, language => $language,__system_directory =>$output_directory,timescale => "1ps / 1ps"});#'temp_gen'});
my $module = $project->top();


$module->add_attribute(ALTERA_ATTRIBUTE =>"SUPPRESS_DA_RULE_INTERNAL=C106;SUPPRESS_DA_RULE_INTERNAL=C104");

my $header_title = "Datapath for the Altera DDR SDRAM Controller";
my $project_title = "RLDRAM II Controller";
my $header_filename = $gWRAPPER_NAME . "_auk_rldramii_datapath" . $file_ext;
my $header_revision = "V" . $gWIZARD_VERSION;
my $header_abstract = "This file contains the datapath for the RLDRAM II Controller";

my $local_data_mode = $gLOCAL_DATA_MODE;
my $local_burst_len = $gLOCAL_BURST_LEN;
my $local_data_bits = $gLOCAL_DATA_BITS;
my $mem_dq_per_dqs = $gMEM_DQ_PER_DQS;
my $mem_addr_bits = $mem_addr_bits;
my $num_clock_pairs = $gNUM_CLOCK_PAIRS;
my $mem_addr_bits = $gMEM_ADDR_BITS;
my $mem_num_devices = $gMEM_NUM_DEVICES;
my $rldramii_type = $gRLDRAMII_TYPE;
my $num_pipeline_addr_cmd_stages = $gNUM_PIPELINE_ADDR_CMD_STAGES;
my $num_pipeline_wdata_stages = $gNUM_PIPELINE_WDATA_STAGES;
my $num_pipeline_rdata_stages = $gNUM_PIPELINE_RDATA_STAGES;
my $num_pipeline_qvld_stages = $gNUM_PIPELINE_QVLD_STAGES;
my $rldramii_dw_interface;
my $clock_pos_pin_name = $gCLOCK_POS_PIN_NAME;
my $clock_neg_pin_name = $gCLOCK_NEG_PIN_NAME;
my $enable_dm_pins = $gENABLE_DM_PINS;
my $num_addr_cmd_buses = $gNUMBER_ADDR_CMD_BUSES;
my $ddio_memory_clocks = $gDDIO_MEMORY_CLOCKS;
my $capture_clk_width;
my $port_num;
my %ports_name;
my @ports_name;
my %ports_width;
my @ports_width;
my %ports_dir;
my @ports_dir;


my $enable_addr_cmd_clk = $gENABLE_ADDR_CMD_CLK;
my $device_clk = "clk";
if($enable_addr_cmd_clk eq "true")
{
	$device_clk = "addr_cmd_clk";

}
#### Calculate the number of dqs pins used and the memory interface width ####
if ($local_data_mode eq "narrow") {
    $number_dqs = int($local_data_bits / $mem_dq_per_dqs / 2);
    $memory_data_width = int($local_data_bits / 2);
} else {
    $number_dqs = int($local_data_bits / $local_burst_len / $mem_dq_per_dqs / 2);
    $memory_data_width = int($local_data_bits / $local_burst_len / 2);	
}

my $control_data_width = int($memory_data_width * 2);

my $ENABLE_CAPTURE_CLK = $gENABLE_CAPTURE_CLK;

if ($ENABLE_CAPTURE_CLK eq "true") {
	$CAPTURE_MODE = non_dqs;
}
else {
	$CAPTURE_MODE = dqs;
}


##Checking the local data mode(Narrow or Wide)
if($local_data_mode eq "narrow")
{
	$rldramii_dw_interface = int($local_data_bits / 2);	
	$capture_clk_width = int($local_data_bits / $mem_dq_per_dqs / 2);
	
}elsif($local_data_mode eq "wide")
{
	$rldramii_dw_interface =  int($local_data_bits / $local_burst_len / 2);
	$capture_clk_width = int($local_data_bits / $local_burst_len / $mem_dq_per_dqs / 2);
}

if( $rldramii_type eq "cio" )
{
	$ports_name{'rldramii_dq'} = "rldramii_dq";
	$ports_dir{'inout'}   = "inout";
	$ports_width{$rldramii_dw_interface} = $rldramii_dw_interface;
	$port_num = 1;
}
elsif ( $rldramii_type eq "sio")
{
	$ports_name{'rldramii_d'} = "d";
	$ports_dir{'output'}   = "output";
	$ports_width{'ddr_d_width'} = $rldramii_dw_interface;
	$ports_name{'rldramii_q'} = "q";
	$ports_dir{'input'}   = "input";
	$ports_width{'ddr_q_width'} = $rldramii_dw_interface;
	$port_num = 4;
}
@ports_name = %ports_name;
@ports_width = %ports_width;
@ports_dir = %ports_dir;

my @port_list;my @dir_list;my @width_list;
my $i=1;
#print "\n";
foreach my $port (@ports_name ) {
# print "$i)-->  $port <----\t";
 push (@port_list, $port);
 $i += 1;
}
#print "\n";
$i =1;
foreach my $dir(@ports_dir) {
# print "$i)-->  $dir <----\t";
 push (@dir_list, $dir);
 $i += 1;
}
#print "\n";
$i =1;
foreach my $width (@ports_width) {
# print "$i)--> $width <----\t";
 push (@width_list, $width);
 $i += 1;
}
#print "\n";
for ($i=0; $i < $port_num; $i+=2){
	$module->add_contents
	(
		e_port->new({name => @port_list[$i] , direction => @dir_list[$i+1] , width => @width_list[$i+1] , declare_one_bit_as_std_logic_vector => 1}),
		#e_signal->new({name => @port_list[$i+1] , width => @width_list[$i+1] , declare_one_bit_as_std_logic_vector => 1}),
	);
}

my $addr_cmd_bus_width = $mem_addr_bits + 6;

if($enable_dm_pins eq "true") {
	$wdata_bus_width = ($rldramii_dw_interface * 2) + ($mem_num_devices * 2) + 2;
} else {
	$wdata_bus_width = ($rldramii_dw_interface * 2) + 2;
}

my $rdata_bus_width = int($rldramii_dw_interface * 2);
my $qvld_bus_width  = $mem_num_devices;
my $number_dqs_per_memory = $number_dqs / $mem_num_devices;

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
		 Control Interface Data Width       : $control_data_width\n
		 RLDRAM II Interface Data Width     : $memory_data_width\n
		 RLDRAM II Memory Type              : $rldramii_type\n
		 DDIO Memory Clock Generation       : $ddio_memory_clocks\n
		 Number Memory Clock Pairs          : $num_clock_pairs\n
		 Number Address/Command Buses       : $num_addr_cmd_buses\n
		 Number Attached Memory Devices     : $mem_num_devices\n
		 Number DQS Inputs Used             : $number_dqs\n
		 Number DQS Inputs Per Memory       : $number_dqs_per_memory\n
		 Number DQ Bits per DQS Input       : $mem_dq_per_dqs\n
		 Enable DM Pins                     : $enable_dm_pins\n
		 Read Data Capture Mode             : $CAPTURE_MODE\n
		 Address and Command Pipeline Depth : $num_pipeline_addr_cmd_stages\n
		 Write Data Pipeline Depth          : $num_pipeline_wdata_stages\n
		 Read Data Pipeline Depth           : $num_pipeline_rdata_stages\n
		 QVLD Pipeline Depth                : $num_pipeline_qvld_stages\n
		 Local Burst Length                 : $local_burst_len\n
		 ----------------------------------------------------------------------------------\n",
	);
######################################################################################################################################################################
if ($ENABLE_CAPTURE_CLK eq "false") {
	if($enable_addr_cmd_clk eq "false") {
		if($enable_dm_pins eq "true") {
			$module->add_contents
			(
			#####	Ports declaration#	######
				e_port->new({name => "clk",direction => "input"}),
				e_port->new({name => "reset_clk_n",direction => "input"}),
				e_port->new({name => "reset_addr_cmd_clk_n",direction => "input"}),
				e_port->new({name => "reset_read_clk_n",direction => "input",width => $mem_num_devices}),
				e_port->new({name => "write_clk",direction => "input"}),
				e_port->new({name => "dqs_delay_ctrl",direction => "input", width => 6}),
				# e_port->new({name => "rldramii_clk",direction => "output", width => $num_clock_pairs,declare_one_bit_as_std_logic_vector => 0}),
				# e_port->new({name => "rldramii_clk_n",direction => "output", width => $num_clock_pairs,declare_one_bit_as_std_logic_vector => 0}),
				
			##Addr & Cmd Output Reg input and output signal
				e_port->new({name => "control_cs_n",direction => "input", width => 1}),
				e_port->new({name => "control_we_n",direction => "input", width => 1}),
				e_port->new({name => "control_ref_n",direction => "input", width => 1}),
				e_port->new({name => "control_a",direction => "input", width => $mem_addr_bits,declare_one_bit_as_std_logic_vector => 1}),
				e_port->new({name => "control_ba",direction => "input", width => 3}),
			
				e_port->new({name => "rldramii_cs_n_0",direction => "output", width => 1}),
				e_port->new({name => "rldramii_we_n_0",direction => "output", width => 1}),
				e_port->new({name => "rldramii_ref_n_0",direction => "output", width => 1}),
				e_port->new({name => "rldramii_a_0",direction => "output", width => $mem_addr_bits,declare_one_bit_as_std_logic_vector => 1}),
				e_port->new({name => "rldramii_ba_0",direction => "output", width => 3,declare_one_bit_as_std_logic_vector => 1}),
			);
			
			if ($ddio_memory_clocks eq "true") {
				$module->add_contents
				(
					e_port->new({name => "rldramii_clk",direction => "output", width => $num_clock_pairs,declare_one_bit_as_std_logic_vector => 0}),
					e_port->new({name => "rldramii_clk_n",direction => "output", width => $num_clock_pairs,declare_one_bit_as_std_logic_vector => 0}),
				);
			}
			
			if($num_addr_cmd_buses > 1) {
				$module->add_contents
				(
					e_port->new({name => "rldramii_cs_n_1",direction => "output", width => 1}),
					e_port->new({name => "rldramii_we_n_1",direction => "output", width => 1}),
					e_port->new({name => "rldramii_ref_n_1",direction => "output", width => 1}),
					e_port->new({name => "rldramii_a_1",direction => "output", width => $mem_addr_bits,declare_one_bit_as_std_logic_vector => 1}),
					e_port->new({name => "rldramii_ba_1",direction => "output", width => 3,declare_one_bit_as_std_logic_vector => 1}),
				);
			}
				
			$module->add_contents
				(
				##Write Data Path input and output signal
				e_port->new({name => "control_wdata_valid",direction => "input", width => 1}),
				e_port->new({name => "control_doing_wr",direction => "input", width => 1}),
				e_port->new({name => "control_wdata",direction => "input", width => int($rldramii_dw_interface * 2) , declare_one_bit_as_std_logic_vector => 1}),
				e_port->new({name => "control_dm",direction => "input", width => int($mem_num_devices * 2),declare_one_bit_as_std_logic_vector => 1}),
				
				#e_port->new({name => "rldramii_dq",direction => "output", width => $rldramii_dw_interface , declare_one_bit_as_std_logic_vector => 1}),
				#e_port->new({name => "rldramii_d",direction => "output", width => $rldramii_dw_interface , declare_one_bit_as_std_logic_vector => 1}),
				
			##Read Data Path input and output signal
				e_signal->new({name => "rdata_temp" , width => $rdata_bus_width , export => 0, never_export => 1, declare_one_bit_as_std_logic_vector => 1}),
				e_signal->new({name => "dqs_group_capture_clk" , width => $capture_clk_width , export => 0, never_export => 1, declare_one_bit_as_std_logic_vector => 1}),
                e_signal->new({name => "dq_capture_clk" , width => $capture_clk_width , export => 0, never_export => 1, declare_one_bit_as_std_logic_vector => 1}),
				e_port->new({name => "control_rdata",direction => "output", width => $rdata_bus_width , declare_one_bit_as_std_logic_vector => 1}),
				e_port->new({name => "capture_clk",direction => "output", width => $mem_num_devices , declare_one_bit_as_std_logic_vector => 0}),
				
				e_port->new({name => "rldramii_qk",direction => "input", width => int($rldramii_dw_interface / $mem_dq_per_dqs), declare_one_bit_as_std_logic_vector => 0}),
				
			##Qvld_group Path input and output signal
				e_port->new({name => "control_qvld",direction => "output", width => $qvld_bus_width , declare_one_bit_as_std_logic_vector => 0}),
				
				e_port->new({name => "rldramii_qvld",direction => "input", width => $qvld_bus_width , declare_one_bit_as_std_logic_vector => 0}),
		
			##DM_group Path input and output signal
				e_port->new({name => "rldramii_dm",direction => "output", width => $mem_num_devices , declare_one_bit_as_std_logic_vector => 0}),
		
			## DQS group signals
				e_signal->new({name => "wdata_temp"  , width => int($rldramii_dw_interface * 2) , export => 0, never_export => 1}),
				
			## DM group signals
				e_signal->new({name => "dm_temp"  , width => int($mem_num_devices * 2) , export => 0, never_export => 1}),
			);
		} else {
			$module->add_contents
			(
			#####	Ports declaration#	######
				e_port->new({name => "clk",direction => "input"}),
				e_port->new({name => "reset_clk_n",direction => "input"}),
				e_port->new({name => "reset_addr_cmd_clk_n",direction => "input"}),
				e_port->new({name => "reset_read_clk_n",direction => "input",width => $mem_num_devices}),
				e_port->new({name => "write_clk",direction => "input"}),
				e_port->new({name => "dqs_delay_ctrl",direction => "input", width => 6}),
				#e_port->new({name => "rldramii_clk",direction => "output", width => $num_clock_pairs,declare_one_bit_as_std_logic_vector => 0}),
				#e_port->new({name => "rldramii_clk_n",direction => "output", width => $num_clock_pairs,declare_one_bit_as_std_logic_vector => 0}),
				
			##Addr & Cmd Output Reg input and output signal
				e_port->new({name => "control_cs_n",direction => "input", width => 1}),
				e_port->new({name => "control_we_n",direction => "input", width => 1}),
				e_port->new({name => "control_ref_n",direction => "input", width => 1}),
				e_port->new({name => "control_a",direction => "input", width => $mem_addr_bits,declare_one_bit_as_std_logic_vector => 1}),
				e_port->new({name => "control_ba",direction => "input", width => 3}),
				
				e_port->new({name => "rldramii_cs_n_0",direction => "output", width => 1}),
				e_port->new({name => "rldramii_we_n_0",direction => "output", width => 1}),
				e_port->new({name => "rldramii_ref_n_0",direction => "output", width => 1}),
				e_port->new({name => "rldramii_a_0",direction => "output", width => $mem_addr_bits,declare_one_bit_as_std_logic_vector => 1}),
				e_port->new({name => "rldramii_ba_0",direction => "output", width => 3,declare_one_bit_as_std_logic_vector => 1}),
			);
			
			if ($ddio_memory_clocks eq "true") {
				$module->add_contents
				(
					e_port->new({name => "rldramii_clk",direction => "output", width => $num_clock_pairs,declare_one_bit_as_std_logic_vector => 0}),
					e_port->new({name => "rldramii_clk_n",direction => "output", width => $num_clock_pairs,declare_one_bit_as_std_logic_vector => 0}),
				);
			}
			
			if($num_addr_cmd_buses > 1) {
				$module->add_contents
				(
					e_port->new({name => "rldramii_cs_n_1",direction => "output", width => 1}),
					e_port->new({name => "rldramii_we_n_1",direction => "output", width => 1}),
					e_port->new({name => "rldramii_ref_n_1",direction => "output", width => 1}),
					e_port->new({name => "rldramii_a_1",direction => "output", width => $mem_addr_bits,declare_one_bit_as_std_logic_vector => 1}),
					e_port->new({name => "rldramii_ba_1",direction => "output", width => 3,declare_one_bit_as_std_logic_vector => 1}),
				);
			}
				
			$module->add_contents
				(
				##Write Data Path input and output signal
				e_port->new({name => "control_wdata_valid",direction => "input", width => 1}),
				e_port->new({name => "control_doing_wr",direction => "input", width => 1}),
				e_port->new({name => "control_wdata",direction => "input", width => int($rldramii_dw_interface * 2) , declare_one_bit_as_std_logic_vector => 1}),
				#e_port->new({name => "control_dm",direction => "input", width => int($mem_num_devices * 2),declare_one_bit_as_std_logic_vector => 1}),
				
				#e_port->new({name => "rldramii_dq",direction => "output", width => $rldramii_dw_interface , declare_one_bit_as_std_logic_vector => 1}),
				#e_port->new({name => "rldramii_d",direction => "output", width => $rldramii_dw_interface , declare_one_bit_as_std_logic_vector => 1}),
				
			##Read Data Path input and output signal
				e_signal->new({name => "rdata_temp" , width => $rdata_bus_width , export => 0, never_export => 1, declare_one_bit_as_std_logic_vector => 1}),
				e_signal->new({name => "dqs_group_capture_clk" , width => $capture_clk_width , export => 0, never_export => 1, declare_one_bit_as_std_logic_vector => 1}),
                e_signal->new({name => "dq_capture_clk" , width => $capture_clk_width , export => 0, never_export => 1, declare_one_bit_as_std_logic_vector => 1}),
				e_port->new({name => "control_rdata",direction => "output", width => $rdata_bus_width , declare_one_bit_as_std_logic_vector => 1}),
				e_port->new({name => "capture_clk",direction => "output", width => $mem_num_devices , declare_one_bit_as_std_logic_vector => 0}),
				
				e_port->new({name => "rldramii_qk",direction => "input", width => int($rldramii_dw_interface / $mem_dq_per_dqs), declare_one_bit_as_std_logic_vector => 0}),
				
			##Qvld_group Path input and output signal
				e_port->new({name => "control_qvld",direction => "output", width => $qvld_bus_width , declare_one_bit_as_std_logic_vector => 0}),
				
				e_port->new({name => "rldramii_qvld",direction => "input", width => $qvld_bus_width , declare_one_bit_as_std_logic_vector => 0}),
		
			## DQS group signals
				e_signal->new({name => "wdata_temp"  , width => int($rldramii_dw_interface * 2) , export => 0, never_export => 1}),
				
			## DM group signals
				e_signal->new({name => "dm_temp"  , width => int($mem_num_devices * 2) , export => 0, never_export => 1}),
			);
		}
	}
	else
	{
		if($enable_dm_pins eq "true") {
			$module->add_contents
			(
			#####	Ports declaration#	######
				e_port->new({name => "clk",direction => "input"}),
				e_port->new({name => "reset_clk_n",direction => "input"}),
				e_port->new({name => "reset_addr_cmd_clk_n",direction => "input"}),
				e_port->new({name => "reset_read_clk_n",direction => "input",width => $mem_num_devices}),
				e_port->new({name => "addr_cmd_clk",direction => "input"}),
				e_port->new({name => "write_clk",direction => "input"}),
				e_port->new({name => "dqs_delay_ctrl",direction => "input", width => 6}),
				#e_port->new({name => "rldramii_clk",direction => "output", width => $num_clock_pairs,declare_one_bit_as_std_logic_vector => 0}),
				#e_port->new({name => "rldramii_clk_n",direction => "output", width => $num_clock_pairs,declare_one_bit_as_std_logic_vector => 0}),
				
			##Addr & Cmd Output Reg input and output signal
				e_port->new({name => "control_cs_n",direction => "input", width => 1}),
				e_port->new({name => "control_we_n",direction => "input", width => 1}),
				e_port->new({name => "control_ref_n",direction => "input", width => 1}),
				e_port->new({name => "control_a",direction => "input", width => $mem_addr_bits,declare_one_bit_as_std_logic_vector => 1}),
				e_port->new({name => "control_ba",direction => "input", width => 3}),
				
				e_port->new({name => "rldramii_cs_n_0",direction => "output", width => 1}),
				e_port->new({name => "rldramii_we_n_0",direction => "output", width => 1}),
				e_port->new({name => "rldramii_ref_n_0",direction => "output", width => 1}),
				e_port->new({name => "rldramii_a_0",direction => "output", width => $mem_addr_bits,declare_one_bit_as_std_logic_vector => 1}),
				e_port->new({name => "rldramii_ba_0",direction => "output", width => 3,declare_one_bit_as_std_logic_vector => 1}),
			);
				
			if ($ddio_memory_clocks eq "true") {
				$module->add_contents
				(
					e_port->new({name => "rldramii_clk",direction => "output", width => $num_clock_pairs,declare_one_bit_as_std_logic_vector => 0}),
					e_port->new({name => "rldramii_clk_n",direction => "output", width => $num_clock_pairs,declare_one_bit_as_std_logic_vector => 0}),
				);
			}
				
			if($num_addr_cmd_buses > 1) {
				$module->add_contents
				(
					e_port->new({name => "rldramii_cs_n_1",direction => "output", width => 1}),
					e_port->new({name => "rldramii_we_n_1",direction => "output", width => 1}),
					e_port->new({name => "rldramii_ref_n_1",direction => "output", width => 1}),
					e_port->new({name => "rldramii_a_1",direction => "output", width => $mem_addr_bits,declare_one_bit_as_std_logic_vector => 1}),
					e_port->new({name => "rldramii_ba_1",direction => "output", width => 3,declare_one_bit_as_std_logic_vector => 1}),
				);
			}
				
			$module->add_contents
				(
				##Write Data Path input and output signal
				e_port->new({name => "control_wdata_valid",direction => "input", width => 1}),
				e_port->new({name => "control_doing_wr",direction => "input", width => 1}),
				e_port->new({name => "control_wdata",direction => "input", width => int($rldramii_dw_interface * 2) , declare_one_bit_as_std_logic_vector => 1}),
				e_port->new({name => "control_dm",direction => "input", width => int($mem_num_devices * 2),declare_one_bit_as_std_logic_vector => 1}),
				
				#e_port->new({name => "rldramii_dq",direction => "output", width => $rldramii_dw_interface , declare_one_bit_as_std_logic_vector => 1}),
				#e_port->new({name => "rldramii_d",direction => "output", width => $rldramii_dw_interface , declare_one_bit_as_std_logic_vector => 1}),
				
			##Read Data Path input and output signal
				e_signal->new({name => "rdata_temp" , width => $rdata_bus_width , export => 0, never_export => 1, declare_one_bit_as_std_logic_vector => 1}),
				e_signal->new({name => "dqs_group_capture_clk" , width => $capture_clk_width , export => 0, never_export => 1, declare_one_bit_as_std_logic_vector => 1}),
                e_signal->new({name => "dq_capture_clk" , width => $capture_clk_width , export => 0, never_export => 1, declare_one_bit_as_std_logic_vector => 1}),
				e_port->new({name => "control_rdata",direction => "output", width => $rdata_bus_width , declare_one_bit_as_std_logic_vector => 1}),
				e_port->new({name => "capture_clk",direction => "output", width => $mem_num_devices , declare_one_bit_as_std_logic_vector => 0}),
				
				e_port->new({name => "rldramii_qk",direction => "input", width => int($rldramii_dw_interface / $mem_dq_per_dqs), declare_one_bit_as_std_logic_vector => 0}),
				
			##Qvld_group Path input and output signal
				e_port->new({name => "control_qvld",direction => "output", width => $qvld_bus_width , declare_one_bit_as_std_logic_vector => 0}),
				
				e_port->new({name => "rldramii_qvld",direction => "input", width => $qvld_bus_width , declare_one_bit_as_std_logic_vector => 0}),
		
			##DM_group Path input and output signal
				e_port->new({name => "rldramii_dm",direction => "output", width => $mem_num_devices , declare_one_bit_as_std_logic_vector => 0}),
		
			## DQS group signals
				e_signal->new({name => "wdata_temp"  , width => int($rldramii_dw_interface * 2) , export => 0, never_export => 1}),
				
			## DM group signals
				e_signal->new({name => "dm_temp"  , width => int($mem_num_devices * 2) , export => 0, never_export => 1}),
			);
		} else {
			$module->add_contents
			(
			#####	Ports declaration#	######
				e_port->new({name => "clk",direction => "input"}),
				e_port->new({name => "reset_clk_n",direction => "input"}),
				e_port->new({name => "reset_addr_cmd_clk_n",direction => "input"}),
				e_port->new({name => "reset_read_clk_n",direction => "input",width => $mem_num_devices}),
				e_port->new({name => "addr_cmd_clk",direction => "input"}),
				e_port->new({name => "write_clk",direction => "input"}),
				e_port->new({name => "dqs_delay_ctrl",direction => "input", width => 6}),
				#e_port->new({name => "rldramii_clk",direction => "output", width => $num_clock_pairs,declare_one_bit_as_std_logic_vector => 0}),
				#e_port->new({name => "rldramii_clk_n",direction => "output", width => $num_clock_pairs,declare_one_bit_as_std_logic_vector => 0}),
				
			##Addr & Cmd Output Reg input and output signal
				e_port->new({name => "control_cs_n",direction => "input", width => 1}),
				e_port->new({name => "control_we_n",direction => "input", width => 1}),
				e_port->new({name => "control_ref_n",direction => "input", width => 1}),
				e_port->new({name => "control_a",direction => "input", width => $mem_addr_bits,declare_one_bit_as_std_logic_vector => 1}),
				e_port->new({name => "control_ba",direction => "input", width => 3}),
				
				e_port->new({name => "rldramii_cs_n_0",direction => "output", width => 1}),
				e_port->new({name => "rldramii_we_n_0",direction => "output", width => 1}),
				e_port->new({name => "rldramii_ref_n_0",direction => "output", width => 1}),
				e_port->new({name => "rldramii_a_0",direction => "output", width => $mem_addr_bits,declare_one_bit_as_std_logic_vector => 1}),
				e_port->new({name => "rldramii_ba_0",direction => "output", width => 3,declare_one_bit_as_std_logic_vector => 1}),
			);
			
			if ($ddio_memory_clocks eq "true") {
				$module->add_contents
				(
					e_port->new({name => "rldramii_clk",direction => "output", width => $num_clock_pairs,declare_one_bit_as_std_logic_vector => 0}),
					e_port->new({name => "rldramii_clk_n",direction => "output", width => $num_clock_pairs,declare_one_bit_as_std_logic_vector => 0}),
				);
			}
				
			if($num_addr_cmd_buses > 1) {
				$module->add_contents
				(
					e_port->new({name => "rldramii_cs_n_1",direction => "output", width => 1}),
					e_port->new({name => "rldramii_we_n_1",direction => "output", width => 1}),
					e_port->new({name => "rldramii_ref_n_1",direction => "output", width => 1}),
					e_port->new({name => "rldramii_a_1",direction => "output", width => $mem_addr_bits,declare_one_bit_as_std_logic_vector => 1}),
					e_port->new({name => "rldramii_ba_1",direction => "output", width => 3,declare_one_bit_as_std_logic_vector => 1}),
				);
			}
				
			$module->add_contents
				(
				##Write Data Path input and output signal
				e_port->new({name => "control_wdata_valid",direction => "input", width => 1}),
				e_port->new({name => "control_doing_wr",direction => "input", width => 1}),
				e_port->new({name => "control_wdata",direction => "input", width => int($rldramii_dw_interface * 2) , declare_one_bit_as_std_logic_vector => 1}),
				#e_port->new({name => "control_dm",direction => "input", width => int($mem_num_devices * 2),declare_one_bit_as_std_logic_vector => 1}),
				
				#e_port->new({name => "rldramii_dq",direction => "output", width => $rldramii_dw_interface , declare_one_bit_as_std_logic_vector => 1}),
				#e_port->new({name => "rldramii_d",direction => "output", width => $rldramii_dw_interface , declare_one_bit_as_std_logic_vector => 1}),
				
			##Read Data Path input and output signal
				e_signal->new({name => "rdata_temp" , width => $rdata_bus_width , export => 0, never_export => 1, declare_one_bit_as_std_logic_vector => 1}),
				e_signal->new({name => "dqs_group_capture_clk" , width => $capture_clk_width , export => 0, never_export => 1, declare_one_bit_as_std_logic_vector => 1}),
                e_signal->new({name => "dq_capture_clk" , width => $capture_clk_width , export => 0, never_export => 1, declare_one_bit_as_std_logic_vector => 1}),
				e_port->new({name => "control_rdata",direction => "output", width => $rdata_bus_width , declare_one_bit_as_std_logic_vector => 1}),
				e_port->new({name => "capture_clk",direction => "output", width => $mem_num_devices , declare_one_bit_as_std_logic_vector => 0}),
				
				e_port->new({name => "rldramii_qk",direction => "input", width => int($rldramii_dw_interface / $mem_dq_per_dqs), declare_one_bit_as_std_logic_vector => 0}),
				
			##Qvld_group Path input and output signal
				e_port->new({name => "control_qvld",direction => "output", width => $qvld_bus_width , declare_one_bit_as_std_logic_vector => 0}),
				
				e_port->new({name => "rldramii_qvld",direction => "input", width => $qvld_bus_width , declare_one_bit_as_std_logic_vector => 0}),
		
			## DQS group signals
				e_signal->new({name => "wdata_temp"  , width => int($rldramii_dw_interface * 2) , export => 0, never_export => 1}),
				
			## DM group signals
				e_signal->new({name => "dm_temp"  , width => int($mem_num_devices * 2) , export => 0, never_export => 1}),
			);
		}
	}
}
else
{
	if($enable_addr_cmd_clk eq "false") {
		if($enable_dm_pins eq "true") {
			$module->add_contents
			(
			#####	Ports declaration#	######
				e_port->new({name => "clk",direction => "input"}),
				e_port->new({name => "reset_clk_n",direction => "input"}),
				e_port->new({name => "reset_addr_cmd_clk_n",direction => "input"}),
				e_port->new({name => "reset_read_clk_n",direction => "input"}),
				e_port->new({name => "write_clk",direction => "input"}),
				e_port->new({name => "non_dqs_capture_clk",direction => "input", width => 1}),
				#e_port->new({name => "rldramii_clk",direction => "output", width => $num_clock_pairs,declare_one_bit_as_std_logic_vector => 0}),
				#e_port->new({name => "rldramii_clk_n",direction => "output", width => $num_clock_pairs,declare_one_bit_as_std_logic_vector => 0}),
				
			##Addr & Cmd Output Reg input and output signal
				e_port->new({name => "control_cs_n",direction => "input", width => 1}),
				e_port->new({name => "control_we_n",direction => "input", width => 1}),
				e_port->new({name => "control_ref_n",direction => "input", width => 1}),
				e_port->new({name => "control_a",direction => "input", width => $mem_addr_bits,declare_one_bit_as_std_logic_vector => 1}),
				e_port->new({name => "control_ba",direction => "input", width => 3}),
				
				e_port->new({name => "rldramii_cs_n_0",direction => "output", width => 1}),
				e_port->new({name => "rldramii_we_n_0",direction => "output", width => 1}),
				e_port->new({name => "rldramii_ref_n_0",direction => "output", width => 1}),
				e_port->new({name => "rldramii_a_0",direction => "output", width => $mem_addr_bits,declare_one_bit_as_std_logic_vector => 1}),
				e_port->new({name => "rldramii_ba_0",direction => "output", width => 3,declare_one_bit_as_std_logic_vector => 1}),
			);
				
			if ($ddio_memory_clocks eq "true") {
				$module->add_contents
				(
					e_port->new({name => "rldramii_clk",direction => "output", width => $num_clock_pairs,declare_one_bit_as_std_logic_vector => 0}),
					e_port->new({name => "rldramii_clk_n",direction => "output", width => $num_clock_pairs,declare_one_bit_as_std_logic_vector => 0}),
				);
			}	
			
			if($num_addr_cmd_buses > 1) {
				$module->add_contents
				(
					e_port->new({name => "rldramii_cs_n_1",direction => "output", width => 1}),
					e_port->new({name => "rldramii_we_n_1",direction => "output", width => 1}),
					e_port->new({name => "rldramii_ref_n_1",direction => "output", width => 1}),
					e_port->new({name => "rldramii_a_1",direction => "output", width => $mem_addr_bits,declare_one_bit_as_std_logic_vector => 1}),
					e_port->new({name => "rldramii_ba_1",direction => "output", width => 3,declare_one_bit_as_std_logic_vector => 1}),
				);
			}
				
			$module->add_contents
				(
				##Write Data Path input and output signal
				e_port->new({name => "control_wdata_valid",direction => "input", width => 1}),
				e_port->new({name => "control_doing_wr",direction => "input", width => 1}),
				e_port->new({name => "control_wdata",direction => "input", width => int($rldramii_dw_interface * 2) , declare_one_bit_as_std_logic_vector => 1}),
				e_port->new({name => "control_dm",direction => "input", width => int($mem_num_devices * 2),declare_one_bit_as_std_logic_vector => 1}),
				
			##Read Data Path input and output signal
				e_signal->new({name => "rdata_temp" , width => $rdata_bus_width , export => 0, never_export => 1, declare_one_bit_as_std_logic_vector => 1}),
				e_signal->new({name => "dqs_group_capture_clk" , width => $capture_clk_width , export => 0, never_export => 1, declare_one_bit_as_std_logic_vector => 1}),
                e_signal->new({name => "dq_capture_clk" , width => $capture_clk_width , export => 0, never_export => 1, declare_one_bit_as_std_logic_vector => 1}),
				e_port->new({name => "control_rdata",direction => "output", width => $rdata_bus_width , declare_one_bit_as_std_logic_vector => 1}),
				#e_port->new({name => "rldramii_qk",direction => "inout", width => int($rldramii_dw_interface / $mem_dq_per_dqs), declare_one_bit_as_std_logic_vector => 1}),
				
			##Qvld_group Path input and output signal
				e_port->new({name => "control_qvld",direction => "output", width => $qvld_bus_width , declare_one_bit_as_std_logic_vector => 0}),
				
				e_port->new({name => "rldramii_qvld",direction => "input", width => $qvld_bus_width , declare_one_bit_as_std_logic_vector => 0}),
		
			##DM_group Path input and output signal
				e_port->new({name => "rldramii_dm",direction => "output", width => $mem_num_devices , declare_one_bit_as_std_logic_vector => 0}),
		
			## DQS group signals
				e_signal->new({name => "wdata_temp"  , width => int($rldramii_dw_interface * 2) , export => 0, never_export => 1}),
				
			## DM group signals
				e_signal->new({name => "dm_temp"  , width => int($mem_num_devices * 2) , export => 0, never_export => 1}),
			);
		} else {
			$module->add_contents
			(
			#####	Ports declaration#	######
				e_port->new({name => "clk",direction => "input"}),
				e_port->new({name => "reset_clk_n",direction => "input"}),
				e_port->new({name => "reset_addr_cmd_clk_n",direction => "input"}),
				e_port->new({name => "reset_read_clk_n",direction => "input"}),
				e_port->new({name => "write_clk",direction => "input"}),
				e_port->new({name => "non_dqs_capture_clk",direction => "input", width => 1}),
				#e_port->new({name => "rldramii_clk",direction => "output", width => $num_clock_pairs,declare_one_bit_as_std_logic_vector => 0}),
				#e_port->new({name => "rldramii_clk_n",direction => "output", width => $num_clock_pairs,declare_one_bit_as_std_logic_vector => 0}),
				
			##Addr & Cmd Output Reg input and output signal
				e_port->new({name => "control_cs_n",direction => "input", width => 1}),
				e_port->new({name => "control_we_n",direction => "input", width => 1}),
				e_port->new({name => "control_ref_n",direction => "input", width => 1}),
				e_port->new({name => "control_a",direction => "input", width => $mem_addr_bits,declare_one_bit_as_std_logic_vector => 1}),
				e_port->new({name => "control_ba",direction => "input", width => 3}),
				
				e_port->new({name => "rldramii_cs_n_0",direction => "output", width => 1}),
				e_port->new({name => "rldramii_we_n_0",direction => "output", width => 1}),
				e_port->new({name => "rldramii_ref_n_0",direction => "output", width => 1}),
				e_port->new({name => "rldramii_a_0",direction => "output", width => $mem_addr_bits,declare_one_bit_as_std_logic_vector => 1}),
				e_port->new({name => "rldramii_ba_0",direction => "output", width => 3,declare_one_bit_as_std_logic_vector => 1}),
			);
				
			if ($ddio_memory_clocks eq "true") {
				$module->add_contents
				(
					e_port->new({name => "rldramii_clk",direction => "output", width => $num_clock_pairs,declare_one_bit_as_std_logic_vector => 0}),
					e_port->new({name => "rldramii_clk_n",direction => "output", width => $num_clock_pairs,declare_one_bit_as_std_logic_vector => 0}),
				);
			}
				
			if($num_addr_cmd_buses > 1) {
				$module->add_contents
				(
					e_port->new({name => "rldramii_cs_n_1",direction => "output", width => 1}),
					e_port->new({name => "rldramii_we_n_1",direction => "output", width => 1}),
					e_port->new({name => "rldramii_ref_n_1",direction => "output", width => 1}),
					e_port->new({name => "rldramii_a_1",direction => "output", width => $mem_addr_bits,declare_one_bit_as_std_logic_vector => 1}),
					e_port->new({name => "rldramii_ba_1",direction => "output", width => 3,declare_one_bit_as_std_logic_vector => 1}),
				);
			}
				
			$module->add_contents
				(
				##Write Data Path input and output signal
				e_port->new({name => "control_wdata_valid",direction => "input", width => 1}),
				e_port->new({name => "control_doing_wr",direction => "input", width => 1}),
				e_port->new({name => "control_wdata",direction => "input", width => int($rldramii_dw_interface * 2) , declare_one_bit_as_std_logic_vector => 1}),
				#e_port->new({name => "control_dm",direction => "input", width => int($mem_num_devices * 2),declare_one_bit_as_std_logic_vector => 1}),
				
			##Read Data Path input and output signal
				e_signal->new({name => "rdata_temp" , width => $rdata_bus_width , export => 0, never_export => 1, declare_one_bit_as_std_logic_vector => 1}),
				e_signal->new({name => "dqs_group_capture_clk" , width => $capture_clk_width , export => 0, never_export => 1, declare_one_bit_as_std_logic_vector => 1}),
                e_signal->new({name => "dq_capture_clk" , width => $capture_clk_width , export => 0, never_export => 1, declare_one_bit_as_std_logic_vector => 1}),
				e_port->new({name => "control_rdata",direction => "output", width => $rdata_bus_width , declare_one_bit_as_std_logic_vector => 1}),
				#e_port->new({name => "rldramii_qk",direction => "inout", width => int($rldramii_dw_interface / $mem_dq_per_dqs), declare_one_bit_as_std_logic_vector => 1}),
				
			##Qvld_group Path input and output signal
				e_port->new({name => "control_qvld",direction => "output", width => $qvld_bus_width , declare_one_bit_as_std_logic_vector => 0}),
				
				e_port->new({name => "rldramii_qvld",direction => "input", width => $qvld_bus_width , declare_one_bit_as_std_logic_vector => 0}),
		
			## DQS group signals
				e_signal->new({name => "wdata_temp"  , width => int($rldramii_dw_interface * 2) , export => 0, never_export => 1}),
				
			## DM group signals
				e_signal->new({name => "dm_temp"  , width => int($mem_num_devices * 2) , export => 0, never_export => 1}),
			);
		}
	}
	else
	{
		if($enable_dm_pins eq "true") {
			$module->add_contents
			(
			#####	Ports declaration#	######
				e_port->new({name => "clk",direction => "input"}),
				e_port->new({name => "reset_clk_n",direction => "input"}),
				e_port->new({name => "reset_addr_cmd_clk_n",direction => "input"}),
				#e_port->new({name => "reset_read_clk_n",direction => "input",width => $mem_num_devices}),
				e_port->new({name => "reset_read_clk_n",direction => "input"}),
				e_port->new({name => "addr_cmd_clk",direction => "input"}),
				e_port->new({name => "write_clk",direction => "input"}),
				e_port->new({name => "non_dqs_capture_clk",direction => "input", width => 1}),
				#e_port->new({name => "rldramii_clk",direction => "output", width => $num_clock_pairs,declare_one_bit_as_std_logic_vector => 0}),
				#e_port->new({name => "rldramii_clk_n",direction => "output", width => $num_clock_pairs,declare_one_bit_as_std_logic_vector => 0}),
				
			##Addr & Cmd Output Reg input and output signal
				e_port->new({name => "control_cs_n",direction => "input", width => 1}),
				e_port->new({name => "control_we_n",direction => "input", width => 1}),
				e_port->new({name => "control_ref_n",direction => "input", width => 1}),
				e_port->new({name => "control_a",direction => "input", width => $mem_addr_bits,declare_one_bit_as_std_logic_vector => 1}),
				e_port->new({name => "control_ba",direction => "input", width => 3}),
				e_port->new({name => "rldramii_cs_n_0",direction => "output", width => 1}),
				e_port->new({name => "rldramii_we_n_0",direction => "output", width => 1}),
				e_port->new({name => "rldramii_ref_n_0",direction => "output", width => 1}),
				e_port->new({name => "rldramii_a_0",direction => "output", width => $mem_addr_bits,declare_one_bit_as_std_logic_vector => 1}),
				e_port->new({name => "rldramii_ba_0",direction => "output", width => 3,declare_one_bit_as_std_logic_vector => 1}),
			);
				
			if ($ddio_memory_clocks eq "true") {
				$module->add_contents
				(
					e_port->new({name => "rldramii_clk",direction => "output", width => $num_clock_pairs,declare_one_bit_as_std_logic_vector => 0}),
					e_port->new({name => "rldramii_clk_n",direction => "output", width => $num_clock_pairs,declare_one_bit_as_std_logic_vector => 0}),
				);
			}
				
			if($num_addr_cmd_buses > 1) {
				$module->add_contents
				(
					e_port->new({name => "rldramii_cs_n_1",direction => "output", width => 1}),
					e_port->new({name => "rldramii_we_n_1",direction => "output", width => 1}),
					e_port->new({name => "rldramii_ref_n_1",direction => "output", width => 1}),
					e_port->new({name => "rldramii_a_1",direction => "output", width => $mem_addr_bits,declare_one_bit_as_std_logic_vector => 1}),
					e_port->new({name => "rldramii_ba_1",direction => "output", width => 3,declare_one_bit_as_std_logic_vector => 1}),
				);
			}
				
			$module->add_contents
				(
				##Write Data Path input and output signal
				e_port->new({name => "control_wdata_valid",direction => "input", width => 1}),
				e_port->new({name => "control_doing_wr",direction => "input", width => 1}),
				e_port->new({name => "control_wdata",direction => "input", width => int($rldramii_dw_interface * 2) , declare_one_bit_as_std_logic_vector => 1}),
				e_port->new({name => "control_dm",direction => "input", width => int($mem_num_devices * 2),declare_one_bit_as_std_logic_vector => 1}),
				
			##Read Data Path input and output signal
				e_signal->new({name => "rdata_temp" , width => $rdata_bus_width , export => 0, never_export => 1, declare_one_bit_as_std_logic_vector => 1}),
				e_signal->new({name => "dqs_group_capture_clk" , width => $capture_clk_width , export => 0, never_export => 1, declare_one_bit_as_std_logic_vector => 1}),
                e_signal->new({name => "dq_capture_clk" , width => $capture_clk_width , export => 0, never_export => 1, declare_one_bit_as_std_logic_vector => 1}),
				e_port->new({name => "control_rdata",direction => "output", width => $rdata_bus_width , declare_one_bit_as_std_logic_vector => 1}),
				#e_port->new({name => "rldramii_qk",direction => "inout", width => int($rldramii_dw_interface / $mem_dq_per_dqs), declare_one_bit_as_std_logic_vector => 1}),
				
			##Qvld_group Path input and output signal
				e_port->new({name => "control_qvld",direction => "output", width => $qvld_bus_width , declare_one_bit_as_std_logic_vector => 0}),
				
				e_port->new({name => "rldramii_qvld",direction => "input", width => $qvld_bus_width , declare_one_bit_as_std_logic_vector => 0}),
		
			##DM_group Path input and output signal
				e_port->new({name => "rldramii_dm",direction => "output", width => $mem_num_devices , declare_one_bit_as_std_logic_vector => 0}),
		
			## DQS group signals
				e_signal->new({name => "wdata_temp"  , width => int($rldramii_dw_interface * 2) , export => 0, never_export => 1}),
				
			## DM group signals
				e_signal->new({name => "dm_temp"  , width => int($mem_num_devices * 2) , export => 0, never_export => 1}),
			);
		} else {
			$module->add_contents
			(
			#####	Ports declaration#	######
				e_port->new({name => "clk",direction => "input"}),
				e_port->new({name => "reset_clk_n",direction => "input"}),
				e_port->new({name => "reset_addr_cmd_clk_n",direction => "input"}),
				#e_port->new({name => "reset_read_clk_n",direction => "input",width => $mem_num_devices}),
				e_port->new({name => "reset_read_clk_n",direction => "input"}),
				e_port->new({name => "addr_cmd_clk",direction => "input"}),
				e_port->new({name => "write_clk",direction => "input"}),
				e_port->new({name => "non_dqs_capture_clk",direction => "input", width => 1}),
				#e_port->new({name => "rldramii_clk",direction => "output", width => $num_clock_pairs,declare_one_bit_as_std_logic_vector => 0}),
				#e_port->new({name => "rldramii_clk_n",direction => "output", width => $num_clock_pairs,declare_one_bit_as_std_logic_vector => 0}),
				
			##Addr & Cmd Output Reg input and output signal
				e_port->new({name => "control_cs_n",direction => "input", width => 1}),
				e_port->new({name => "control_we_n",direction => "input", width => 1}),
				e_port->new({name => "control_ref_n",direction => "input", width => 1}),
				e_port->new({name => "control_a",direction => "input", width => $mem_addr_bits,declare_one_bit_as_std_logic_vector => 1}),
				e_port->new({name => "control_ba",direction => "input", width => 3}),
				
				e_port->new({name => "rldramii_cs_n_0",direction => "output", width => 1}),
				e_port->new({name => "rldramii_we_n_0",direction => "output", width => 1}),
				e_port->new({name => "rldramii_ref_n_0",direction => "output", width => 1}),
				e_port->new({name => "rldramii_a_0",direction => "output", width => $mem_addr_bits,declare_one_bit_as_std_logic_vector => 1}),
				e_port->new({name => "rldramii_ba_0",direction => "output", width => 3,declare_one_bit_as_std_logic_vector => 1}),
			);
				
			if ($ddio_memory_clocks eq "true") {
				$module->add_contents
				(
					e_port->new({name => "rldramii_clk",direction => "output", width => $num_clock_pairs,declare_one_bit_as_std_logic_vector => 0}),
					e_port->new({name => "rldramii_clk_n",direction => "output", width => $num_clock_pairs,declare_one_bit_as_std_logic_vector => 0}),
				);
			}
				
			if($num_addr_cmd_buses > 1) {
				$module->add_contents
				(
					e_port->new({name => "rldramii_cs_n_1",direction => "output", width => 1}),
					e_port->new({name => "rldramii_we_n_1",direction => "output", width => 1}),
					e_port->new({name => "rldramii_ref_n_1",direction => "output", width => 1}),
					e_port->new({name => "rldramii_a_1",direction => "output", width => $mem_addr_bits,declare_one_bit_as_std_logic_vector => 1}),
					e_port->new({name => "rldramii_ba_1",direction => "output", width => 3,declare_one_bit_as_std_logic_vector => 1}),
				);
			}
				
			$module->add_contents
				(
			##Write Data Path input and output signal
				e_port->new({name => "control_wdata_valid",direction => "input", width => 1}),
				e_port->new({name => "control_doing_wr",direction => "input", width => 1}),
				e_port->new({name => "control_wdata",direction => "input", width => int($rldramii_dw_interface * 2) , declare_one_bit_as_std_logic_vector => 1}),
				#e_port->new({name => "control_dm",direction => "input", width => int($mem_num_devices * 2),declare_one_bit_as_std_logic_vector => 1}),
				
			##Read Data Path input and output signal
				e_signal->new({name => "rdata_temp" , width => $rdata_bus_width , export => 0, never_export => 1, declare_one_bit_as_std_logic_vector => 1}),
				e_signal->new({name => "dqs_group_capture_clk" , width => $capture_clk_width , export => 0, never_export => 1, declare_one_bit_as_std_logic_vector => 1}),
                e_signal->new({name => "dq_capture_clk" , width => $capture_clk_width , export => 0, never_export => 1, declare_one_bit_as_std_logic_vector => 1}),
				e_port->new({name => "control_rdata",direction => "output", width => $rdata_bus_width , declare_one_bit_as_std_logic_vector => 1}),
				#e_port->new({name => "rldramii_qk",direction => "inout", width => int($rldramii_dw_interface / $mem_dq_per_dqs), declare_one_bit_as_std_logic_vector => 1}),
				
			##Qvld_group Path input and output signal
				e_port->new({name => "control_qvld",direction => "output", width => $qvld_bus_width , declare_one_bit_as_std_logic_vector => 0}),
				
				e_port->new({name => "rldramii_qvld",direction => "input", width => $qvld_bus_width , declare_one_bit_as_std_logic_vector => 0}),
		
			## DQS group signals
				e_signal->new({name => "wdata_temp"  , width => int($rldramii_dw_interface * 2) , export => 0, never_export => 1}),
				
			## DM group signals
				e_signal->new({name => "dm_temp"  , width => int($mem_num_devices * 2) , export => 0, never_export => 1}),
			);
		}
	}
}

######################################################################################################################################################################

if ($ENABLE_CAPTURE_CLK eq "false") {
	$s = 0;
	
	for (my $r = 0; $r < $mem_num_devices; $r++)
	{
		$module->add_contents
		(
			e_assign->new(["capture_clk[$r]","dqs_group_capture_clk[$s]"]),
            #e_assign->new(["capture_clk[$r]","dq_capture_clk[$s]"]),
		);
		$s = $s + $number_dqs_per_memory;
	}
}
		
######################################################################################################################################################################		
if ($ddio_memory_clocks eq "true") {
	 $module->add_contents
	 (
		 e_blind_instance->new
		 ({
			 name 		=> "rldramii_clk_gen",
			 module 		=> $gWRAPPER_NAME."_auk_rldramii_clk_gen",
			 in_port_map 	=>
			 {
				 clk                     => "clk",
			 },
			 out_port_map	=>
			 {
				 "rldramii_clk"     => "rldramii_clk",
				 "rldramii_clk_n"   => "rldramii_clk_n",
			 },
		 }),
	 );
}
##################################################################################################################################################################
if( $num_pipeline_addr_cmd_stages > 0)
{
	$module->add_contents
	(
		e_signal->new({name => "control_addr_cmd_bus", width => $addr_cmd_bus_width , export => 0, never_export => 1, declare_one_bit_as_std_logic_vector => 1}),
		e_signal->new({name => "pipeline_addr_cmd_bus_0", width => $addr_cmd_bus_width , export => 0, never_export => 1, declare_one_bit_as_std_logic_vector => 1}),
		e_comment->new({comment=>"\nCreation of control_addr_cmd_bus by concatenation of all the input signal of the Addr_Cmd_Pipeline\n
				  control_cs_n the MSB and the last bit of control_ba the LSB.\n"}),
		e_assign->new(["control_addr_cmd_bus","{control_a,control_ba,control_cs_n,control_we_n,control_ref_n}"]),
		e_comment->new({comment => "\nInstantiating the pipeline module for the address and command signals\n"}),
		e_blind_instance->new
		({
			 name 		=> "rldramii_addr_cmd_pipeline_0",
			 module 	=> $gWRAPPER_NAME."_auk_rldramii_pipeline_addr_cmd",
			 in_port_map 	=>
			 {
				 clk                  	=> "clk",
				 reset_clk_n           	=> "reset_clk_n",
				 pipeline_data_in      	=> "control_addr_cmd_bus",
			 },
			 out_port_map	=>
			 {
				 pipeline_data_out      => "pipeline_addr_cmd_bus_0",
			 },
		}),
		 
		e_comment->new({comment => "\nInstantiating the address & command output register module\n"}),
		 
		 
		 e_blind_instance->new
		 ({
			 name 		=> "rldramii_addr_cmd_output_0",
			 module 	=> $gWRAPPER_NAME."_auk_rldramii_addr_cmd_reg",
			 in_port_map 	=>
			 {
				 clk                  	=> "clk",
				 reset_clk_n           	=> "reset_clk_n",
				 $device_clk            => "$device_clk",
				 reset_addr_cmd_clk_n	=> "reset_addr_cmd_clk_n",
				 control_cs_n      	=> "pipeline_addr_cmd_bus_0[2]",
				 control_we_n      	=> "pipeline_addr_cmd_bus_0[1]",
				 control_ref_n      	=> "pipeline_addr_cmd_bus_0[0]",
				 control_a 	     	=> "pipeline_addr_cmd_bus_0[$addr_cmd_bus_width-1:6]",
				 control_ba      	=> "pipeline_addr_cmd_bus_0[5:3]",
			 },
			 out_port_map	=>
			 {
				 rldramii_cs_n      	=> "rldramii_cs_n_0",
				 rldramii_we_n      	=> "rldramii_we_n_0",
				 rldramii_ref_n      	=> "rldramii_ref_n_0",
				 rldramii_a 	     	=> "rldramii_a_0",
				 rldramii_ba      	=> "rldramii_ba_0",
			 },
		 }),
	);
		 
	 if($num_addr_cmd_buses > 1) {
		 $module->add_contents
		 (
		 	 e_signal->new({name => "pipeline_addr_cmd_bus_1", width => $addr_cmd_bus_width , export => 0, never_export => 1, declare_one_bit_as_std_logic_vector => 1}),
			 
			 e_comment->new({comment => "\nInstantiating the pipeline module for the address and command signals\n"}),
			 e_blind_instance->new
			 ({
				 name 		=> "rldramii_addr_cmd_pipeline_1",
				 module 	=> $gWRAPPER_NAME."_auk_rldramii_pipeline_addr_cmd",
				 in_port_map 	=>
				 {
					 clk                  	=> "clk",
					 reset_clk_n           	=> "reset_clk_n",
					 pipeline_data_in      	=> "control_addr_cmd_bus",
				 },
				 out_port_map	=>
				 {
					 pipeline_data_out      => "pipeline_addr_cmd_bus_1",
				 },
			}),
			
			e_blind_instance->new
			({
				 name 		=> "rldramii_addr_cmd_output_1",
				 module 	=> $gWRAPPER_NAME."_auk_rldramii_addr_cmd_reg",
				 in_port_map 	=>
				 {
					 clk                  	=> "clk",
					 reset_clk_n           	=> "reset_clk_n",
					 $device_clk            => "$device_clk",
					 reset_addr_cmd_clk_n	=> "reset_addr_cmd_clk_n",
					 control_cs_n      	=> "pipeline_addr_cmd_bus_1[2]",
					 control_we_n      	=> "pipeline_addr_cmd_bus_1[1]",
					 control_ref_n      	=> "pipeline_addr_cmd_bus_1[0]",
					 control_a 	     	=> "pipeline_addr_cmd_bus_1[$addr_cmd_bus_width-1:6]",
					 control_ba      	=> "pipeline_addr_cmd_bus_1[5:3]",
				 },
				 out_port_map	=>
				 {
					 rldramii_cs_n      	=> "rldramii_cs_n_1",
					 rldramii_we_n      	=> "rldramii_we_n_1",
					 rldramii_ref_n      	=> "rldramii_ref_n_1",
					 rldramii_a 	     	=> "rldramii_a_1",
					 rldramii_ba      	=> "rldramii_ba_1",
				 },
			}),
		);
	 }
	 #);
}else
{
	$module->add_contents
	(
		e_comment->new({comment => "\nInstantiating the address & command output register module\n"}),
		e_blind_instance->new
		 ({
			 name 		=> "rldramii_addr_cmd_output_0",
			 module 	=> $gWRAPPER_NAME."_auk_rldramii_addr_cmd_reg",
			 in_port_map 	=>
			 {
				 clk                  	=> "clk",
				 reset_clk_n           	=> "reset_clk_n",
				 $device_clk            => "$device_clk",
				 reset_addr_cmd_clk_n	=> "reset_addr_cmd_clk_n",
				 control_cs_n      	=> "control_cs_n",
				 control_we_n      	=> "control_we_n",
				 control_ref_n      	=> "control_ref_n",
				 control_a 	     	=> "control_a",
				 control_ba      	=> "control_ba",
			 },
			 out_port_map	=>
			 {
				 rldramii_cs_n      	=> "rldramii_cs_n_0",
				 rldramii_we_n      	=> "rldramii_we_n_0",
				 rldramii_ref_n      	=> "rldramii_ref_n_0",
				 rldramii_a 	     	=> "rldramii_a_0",
				 rldramii_ba      	=> "rldramii_ba_0",
			 },
		 }),
	);
	
	 
	 if( $num_addr_cmd_buses > 1) {
		 $module->add_contents
		 (
			 e_blind_instance->new
			 ({
				 
				 name 		=> "rldramii_addr_cmd_output_1",
				 module 	=> $gWRAPPER_NAME."_auk_rldramii_addr_cmd_reg",
				 in_port_map 	=>
				 {
					 clk                  	=> "clk",
					 reset_clk_n           	=> "reset_clk_n",
					 $device_clk            => "$device_clk",
					 reset_addr_cmd_clk_n	=> "reset_addr_cmd_clk_n",
					 control_cs_n      	=> "control_cs_n",
					 control_we_n      	=> "control_we_n",
					 control_ref_n      	=> "control_ref_n",
					 control_a 	     	=> "control_a",
					 control_ba      	=> "control_ba",
				 },
				 out_port_map	=>
				 {
					 rldramii_cs_n      	=> "rldramii_cs_n_1",
					 rldramii_we_n      	=> "rldramii_we_n_1",
					 rldramii_ref_n      	=> "rldramii_ref_n_1",
					 rldramii_a 	     	=> "rldramii_a_1",
					 rldramii_ba      	=> "rldramii_ba_1",
				 },
			 }),
		);
	}
	
};
 
######################################################################################################################################################################
 
if( $num_pipeline_wdata_stages > 0)
{
	 $module->add_contents
	 (
	 	e_signal->new({name => "control_wdata_bus" , width => $wdata_bus_width, export => 0, never_export => 1}),
		e_signal->new({name => "pipeline_wdata_bus" , width => $wdata_bus_width , export => 0, never_export => 1}),
		e_signal->new({name => "pipeline_dm" , width => int($mem_num_devices * 2) , export => 0, never_export => 1}),
		e_signal->new({name => "pipeline_wdata" , width => int($rldramii_dw_interface * 2) , export => 0, never_export => 1}),
		e_signal->new({name => "pipeline_wdata_valid" , width => 1 , export => 0, never_export => 1}),
		e_signal->new({name => "pipeline_doing_wr" , width => 1 , export => 0, never_export => 1}),
	);
		
	 if($enable_dm_pins eq "true") {
		 $module->add_contents
		 (
			 e_comment->new({comment=>"\nCreation of control_wdata_bus by concatenation of all the write data signals: control_dm, control_wdata,
					control_wdata_valid, control_doing_wr\n"}),
			 e_assign->new(["control_wdata_bus","{control_dm, control_wdata, control_wdata_valid, control_doing_wr}"]),
		 );
	 } else {
		 $module->add_contents
		 (
			e_comment->new({comment=>"\nCreation of control_wdata_bus by concatenation of all the write data signals: control_wdata,
				       control_wdata_valid, control_doing_wr\n"}),
			e_assign->new(["control_wdata_bus","{control_wdata, control_wdata_valid, control_doing_wr}"]),
		 );
	 }
	
	 $module->add_contents
	 (
		#e_assign->new(["control_wdata_bus","{control_dm, control_wdata, control_wdata_valid, control_doing_wr}"]),
		e_comment->new({comment => "\nInstantiating the pipeline stages for the Write Data Path\n"}),
		e_blind_instance->new
		({
			name 		=> "rldramii_wdata_pipeline",
			module 	=> $gWRAPPER_NAME."_auk_rldramii_pipeline_wdata",
			in_port_map 	=>
			{
				clk               	=> "clk",
				reset_clk_n             => "reset_clk_n",
				pipeline_data_in    	=> "control_wdata_bus",
			},
			out_port_map	=>
			{
				pipeline_data_out      => "pipeline_wdata_bus",
			},
		}),
		 
	);
	
	if($enable_dm_pins eq "true") {
		$module->add_contents
		(
			e_comment->new({comment => "\nRe-map the Pipelined Data\n"}),	
			e_assign->new(["pipeline_dm","pipeline_wdata_bus["."($wdata_bus_width - 1)"." : "."($wdata_bus_width - ($mem_num_devices * 2))"."]"]),
			e_assign->new(["pipeline_wdata","pipeline_wdata_bus["."($wdata_bus_width - ($mem_num_devices * 2) - 1)"." : "."2"."]"]),
		);
	} else {
		$module->add_contents
		(
			e_comment->new({comment => "\nRe-map the Pipelined Data\n"}),
			e_assign->new(["pipeline_wdata","pipeline_wdata_bus["."($wdata_bus_width - 1)"." : "."2"."]"]),
		);
	}
	
	$module->add_contents
	(
		
		e_assign->new(["pipeline_wdata_valid","pipeline_wdata_bus[1]"]),
		e_assign->new(["pipeline_doing_wr","pipeline_wdata_bus[0]"]),
	);
 
###################################################################################################################################################################### 

 	if($num_pipeline_rdata_stages > 0)
	{
		$module->add_contents
		(		        
			e_signal->new({name => "control_rdata_bus" , width => $rdata_bus_width , export => 0, never_export => 1, declare_one_bit_as_std_logic_vector => 1}),
		);
		
		if( $rldramii_type eq "cio" )
		{
			for (my $i = 0; $i < (int($rldramii_dw_interface / $mem_dq_per_dqs)); $i++)
			{
				if ($ENABLE_CAPTURE_CLK eq "false") {
					
					$module->add_contents
					(		        
							e_assign->new(["wdata_temp["."($mem_dq_per_dqs * 2) * ($i + 1) - 1".":"."($mem_dq_per_dqs * 2) * $i"."]"
							  => "{pipeline_wdata["."$rldramii_dw_interface + $mem_dq_per_dqs * ($i + 1) - 1".":"."$rldramii_dw_interface + $mem_dq_per_dqs * $i"."],
							       pipeline_wdata["."$mem_dq_per_dqs * ($i + 1) - 1".":"."$mem_dq_per_dqs * $i"."]}"]),				       
								 
						e_comment->new({comment => "\nInstantiating DQS GROUP $i in CIO mode\n"}),
						e_blind_instance->new
						({
							name 		=> "auk_rldramii_dqs_group_$i",
							module 		=> $gWRAPPER_NAME."_auk_rldramii_dqs_group",
							in_port_map 	=>
							{
								clk			=> "clk",
								reset_clk_n		=> "reset_clk_n",
								write_clk		=> "write_clk",
								control_doing_wr	=> "pipeline_doing_wr",
								control_wdata_valid	=> "pipeline_wdata_valid",
								control_wdata      	=> "wdata_temp["."($mem_dq_per_dqs * 2) * ($i + 1) - 1".":"."($mem_dq_per_dqs * 2) * $i"."]",
								dqs_delay_ctrl		=> "dqs_delay_ctrl",
                                ddr_dqs			=> "rldramii_qk[$i]",
							},
							out_port_map	=>
							{
								control_rdata		=> "control_rdata_bus["."($mem_dq_per_dqs * 2) * ($i + 1) - 1".":"."($mem_dq_per_dqs * 2) * $i"."]",
								dqs_group_capture_clk	=> "dqs_group_capture_clk[$i]",
                                dq_capture_clk	    => "dq_capture_clk[$i]",
							},
							inout_port_map	=>
							{
								#ddr_dqs			=> "rldramii_qk[$i]",
								ddr_dq			=> "rldramii_dq["."(($i + 1) * $mem_dq_per_dqs) - 1".":"."($i * $mem_dq_per_dqs)"."]",
							},
							# std_logic_vector_signals	=>
							# [
								# ddr_dqs,
							# ],
						}),
					),
					
				}
				else
				{
					$module->add_contents
					(		        
							e_assign->new(["wdata_temp["."($mem_dq_per_dqs * 2) * ($i + 1) - 1".":"."($mem_dq_per_dqs * 2) * $i"."]"
							  => "{pipeline_wdata["."$rldramii_dw_interface + $mem_dq_per_dqs * ($i + 1) - 1".":"."$rldramii_dw_interface + $mem_dq_per_dqs * $i"."],
							       pipeline_wdata["."$mem_dq_per_dqs * ($i + 1) - 1".":"."$mem_dq_per_dqs * $i"."]}"]),				       
								 
						e_comment->new({comment => "\nInstantiating DQS GROUP $i in CIO mode\n"}),
						e_blind_instance->new
						({
							name 		=> "auk_rldramii_dqs_group_$i",
							module 		=> $gWRAPPER_NAME."_auk_rldramii_dqs_group",
							in_port_map 	=>
							{
								clk			=> "clk",
								non_dqs_capture_clk 	=> "non_dqs_capture_clk",
								reset_clk_n		=> "reset_clk_n",
								write_clk		=> "write_clk",
								control_doing_wr	=> "pipeline_doing_wr",
								control_wdata_valid	=> "pipeline_wdata_valid",
								control_wdata      	=> "wdata_temp["."($mem_dq_per_dqs * 2) * ($i + 1) - 1".":"."($mem_dq_per_dqs * 2) * $i"."]",
							},
							out_port_map	=>
							{
								control_rdata		=> "control_rdata_bus["."($mem_dq_per_dqs * 2) * ($i + 1) - 1".":"."($mem_dq_per_dqs * 2) * $i"."]",
							},
							inout_port_map	=>
							{
								#ddr_dqs			=> "rldramii_qk[$i]",
								ddr_dq			=> "rldramii_dq["."(($i + 1) * $mem_dq_per_dqs) - 1".":"."($i * $mem_dq_per_dqs)"."]",
							},
							#std_logic_vector_signals	=>
							#[
							#	ddr_dqs,
							#],
						}),
					),
				}
			}
		}
		elsif( $rldramii_type eq "sio" )
		{
			for (my $i = 0; $i < (int($rldramii_dw_interface / $mem_dq_per_dqs)); $i++)
			{
				if ($ENABLE_CAPTURE_CLK eq "false") {
					$module->add_contents
					(		        
							e_assign->new(["wdata_temp["."($mem_dq_per_dqs * 2) * ($i + 1) - 1".":"."($mem_dq_per_dqs * 2) * $i"."]"
							 => "{pipeline_wdata["."$rldramii_dw_interface + $mem_dq_per_dqs * ($i + 1) - 1".":"."$rldramii_dw_interface + $mem_dq_per_dqs * $i"."],
							       pipeline_wdata["."$mem_dq_per_dqs * ($i + 1) - 1".":"."$mem_dq_per_dqs * $i"."]}"]),				       
								  
						e_comment->new({comment => "\nInstantiating DQS GROUP $i in CIO mode\n"}),
						e_blind_instance->new
						({
							name 		=> "auk_rldramii_dqs_group_$i",
							module 		=> $gWRAPPER_NAME."_auk_rldramii_dqs_group",
							in_port_map 	=>
							{
								clk			=> "clk",
								reset_clk_n		=> "reset_clk_n",
								write_clk		=> "write_clk",
								control_doing_wr	=> "pipeline_doing_wr",
								control_wdata_valid	=> "pipeline_wdata_valid",
								control_wdata      	=> "wdata_temp["."($mem_dq_per_dqs * 2) * ($i + 1) - 1".":"."($mem_dq_per_dqs * 2) * $i"."]",
								dqs_delay_ctrl	=> "dqs_delay_ctrl",
								ddr_q			=> "rldramii_q["."(($i + 1) * $mem_dq_per_dqs) - 1".":"."($i * $mem_dq_per_dqs)"."]",
                                ddr_dqs			=> "rldramii_qk[$i]",
							},
							out_port_map	=>
							{
								control_rdata		=> "control_rdata_bus["."($mem_dq_per_dqs * 2) * ($i + 1) - 1".":"."($mem_dq_per_dqs * 2) * $i"."]",
								dqs_group_capture_clk	=> "dqs_group_capture_clk[$i]",
                                dq_capture_clk	 => "dq_capture_clk[$i]",
								ddr_d			    => "rldramii_d["."(($i + 1) * $mem_dq_per_dqs) - 1".":"."($i * $mem_dq_per_dqs)"."]",
							},
							inout_port_map	=>
							{
								#ddr_dqs			=> "rldramii_qk[$i]",
							},
							# std_logic_vector_signals	=>
							# [
								# ddr_dqs,
							# ],
						}),
					),
				}
				else
				{
					$module->add_contents
					(		        
							e_assign->new(["wdata_temp["."($mem_dq_per_dqs * 2) * ($i + 1) - 1".":"."($mem_dq_per_dqs * 2) * $i"."]"
							 => "{pipeline_wdata["."$rldramii_dw_interface + $mem_dq_per_dqs * ($i + 1) - 1".":"."$rldramii_dw_interface + $mem_dq_per_dqs * $i"."],
							       pipeline_wdata["."$mem_dq_per_dqs * ($i + 1) - 1".":"."$mem_dq_per_dqs * $i"."]}"]),				       
								  
						e_comment->new({comment => "\nInstantiating DQS GROUP $i in CIO mode\n"}),
						e_blind_instance->new
						({
							name 		=> "auk_rldramii_dqs_group_$i",
							module 		=> $gWRAPPER_NAME."_auk_rldramii_dqs_group",
							in_port_map 	=>
							{
								clk			=> "clk",
								reset_clk_n		=> "reset_clk_n",
								write_clk		=> "write_clk",
								non_dqs_capture_clk 	=> "non_dqs_capture_clk",
								control_doing_wr	=> "pipeline_doing_wr",
								control_wdata_valid	=> "pipeline_wdata_valid",
								control_wdata      	=> "wdata_temp["."($mem_dq_per_dqs * 2) * ($i + 1) - 1".":"."($mem_dq_per_dqs * 2) * $i"."]",
								ddr_q			=> "rldramii_q["."(($i + 1) * $mem_dq_per_dqs) - 1".":"."($i * $mem_dq_per_dqs)"."]",
							},
							out_port_map	=>
							{
								control_rdata		=> "control_rdata_bus["."($mem_dq_per_dqs * 2) * ($i + 1) - 1".":"."($mem_dq_per_dqs * 2) * $i"."]",
								ddr_d			=> "rldramii_d["."(($i + 1) * $mem_dq_per_dqs) - 1".":"."($i * $mem_dq_per_dqs)"."]",
							},
							#inout_port_map	=>
							#{
							#	ddr_dqs			=> "rldramii_qk[$i]",
							#},
							#std_logic_vector_signals	=>
							#[
							#	ddr_dqs,
							#],
						}),
					),
				}
			}
		}
	}
	else
	{
		if( $rldramii_type eq "cio" )
		{
			for (my $i = 0; $i < (int($rldramii_dw_interface / $mem_dq_per_dqs)); $i++)
			{
				if ($ENABLE_CAPTURE_CLK eq "false") {
					$module->add_contents
					(		        
						e_assign->new(["wdata_temp["."($mem_dq_per_dqs * 2) * ($i + 1) - 1".":"."($mem_dq_per_dqs * 2) * $i"."]"
							  => "{pipeline_wdata["."$rldramii_dw_interface + $mem_dq_per_dqs * ($i + 1) - 1".":"."$rldramii_dw_interface + $mem_dq_per_dqs * $i"."],
							       pipeline_wdata["."$mem_dq_per_dqs * ($i + 1) - 1".":"."$mem_dq_per_dqs * $i"."]}"]),				       
								 
						e_comment->new({comment => "\nInstantiating DQS GROUP $i in CIO mode\n"}),
						e_blind_instance->new
						({
							name 		=> "auk_rldramii_dqs_group_$i",
							module 		=> $gWRAPPER_NAME."_auk_rldramii_dqs_group",
							in_port_map 	=>
							{
								clk			=> "clk",
								reset_clk_n		=> "reset_clk_n",
								write_clk		=> "write_clk",
								control_doing_wr	=> "pipeline_doing_wr",
								control_wdata_valid	=> "pipeline_wdata_valid",
								control_wdata      	=> "wdata_temp["."($mem_dq_per_dqs * 2) * ($i + 1) - 1".":"."($mem_dq_per_dqs * 2) * $i"."]",
								dqs_delay_ctrl		=> "dqs_delay_ctrl",
                                ddr_dqs			=> "rldramii_qk[$i]",
							},
							out_port_map	=>
							{
								control_rdata		=> "rdata_temp["."($mem_dq_per_dqs * 2) * ($i + 1) - 1".":"."($mem_dq_per_dqs * 2) * $i"."]",
								dqs_group_capture_clk	=> "dqs_group_capture_clk[$i]",
                                dq_capture_clk	=> "dq_capture_clk[$i]",
							},
							inout_port_map	=>
							{
								#ddr_dqs			=> "rldramii_qk[$i]",
								ddr_dq			=> "rldramii_dq["."(($i + 1) * $mem_dq_per_dqs) - 1".":"."($i * $mem_dq_per_dqs)"."]",
							},
							# std_logic_vector_signals	=>
							# [
								# ddr_dqs,
							# ],
						}),
						e_assign->new(["control_rdata["."$rldramii_dw_interface + ($mem_dq_per_dqs * ($i + 1)) - 1".":"."$rldramii_dw_interface + ($mem_dq_per_dqs * $i)"."]"
							=> "rdata_temp["."($i * ($mem_dq_per_dqs * 2)) + ($mem_dq_per_dqs * 2) - 1".":"."(($mem_dq_per_dqs * 2) * $i) + $mem_dq_per_dqs"."]"]),
				  
						e_assign->new(["control_rdata["."$mem_dq_per_dqs * ($i + 1) - 1".":"."$mem_dq_per_dqs * $i"."]"
							=> "rdata_temp["."($i * ($mem_dq_per_dqs * 2)) + $mem_dq_per_dqs - 1".":"."(($mem_dq_per_dqs * 2) * $i)"."]"]),
					),
				}
				else
				{
					$module->add_contents
					(		        
						e_assign->new(["wdata_temp["."($mem_dq_per_dqs * 2) * ($i + 1) - 1".":"."($mem_dq_per_dqs * 2) * $i"."]"
							  => "{pipeline_wdata["."$rldramii_dw_interface + $mem_dq_per_dqs * ($i + 1) - 1".":"."$rldramii_dw_interface + $mem_dq_per_dqs * $i"."],
							       pipeline_wdata["."$mem_dq_per_dqs * ($i + 1) - 1".":"."$mem_dq_per_dqs * $i"."]}"]),				       
								 
						e_comment->new({comment => "\nInstantiating DQS GROUP $i in CIO mode\n"}),
						e_blind_instance->new
						({
							name 		=> "auk_rldramii_dqs_group_$i",
							module 		=> $gWRAPPER_NAME."_auk_rldramii_dqs_group",
							in_port_map 	=>
							{
								clk			=> "clk",
								reset_clk_n		=> "reset_clk_n",
								write_clk		=> "write_clk",
								non_dqs_capture_clk	=> "non_dqs_capture_clk",
								control_doing_wr	=> "pipeline_doing_wr",
								control_wdata_valid	=> "pipeline_wdata_valid",
								control_wdata      	=> "wdata_temp["."($mem_dq_per_dqs * 2) * ($i + 1) - 1".":"."($mem_dq_per_dqs * 2) * $i"."]",
							},
							out_port_map	=>
							{
								control_rdata		=> "rdata_temp["."($mem_dq_per_dqs * 2) * ($i + 1) - 1".":"."($mem_dq_per_dqs * 2) * $i"."]",
							},
							inout_port_map	=>
							{
								#ddr_dqs			=> "rldramii_qk[$i]",
								ddr_dq			=> "rldramii_dq["."(($i + 1) * $mem_dq_per_dqs) - 1".":"."($i * $mem_dq_per_dqs)"."]",
							},
							#std_logic_vector_signals	=>
							#[
							#	ddr_dqs,
							#],
						}),
						e_assign->new(["control_rdata["."$rldramii_dw_interface + ($mem_dq_per_dqs * ($i + 1)) - 1".":"."$rldramii_dw_interface + ($mem_dq_per_dqs * $i)"."]"
							=> "rdata_temp["."($i * ($mem_dq_per_dqs * 2)) + ($mem_dq_per_dqs * 2) - 1".":"."(($mem_dq_per_dqs * 2) * $i) + $mem_dq_per_dqs"."]"]),
				  
						e_assign->new(["control_rdata["."$mem_dq_per_dqs * ($i + 1) - 1".":"."$mem_dq_per_dqs * $i"."]"
							=> "rdata_temp["."($i * ($mem_dq_per_dqs * 2)) + $mem_dq_per_dqs - 1".":"."(($mem_dq_per_dqs * 2) * $i)"."]"]),
					),
				}
			}
		}
		elsif( $rldramii_type eq "sio" )
		{
			for (my $i = 0; $i < (int($rldramii_dw_interface / $mem_dq_per_dqs)); $i++)
			{
				if ($ENABLE_CAPTURE_CLK eq "false") {
					$module->add_contents
					(		        
						e_assign->new(["wdata_temp["."($mem_dq_per_dqs * 2) * ($i + 1) - 1".":"."($mem_dq_per_dqs * 2) * $i"."]"
							  => "{pipeline_wdata["."$rldramii_dw_interface + $mem_dq_per_dqs * ($i + 1) - 1".":"."$rldramii_dw_interface + $mem_dq_per_dqs * $i"."],
							       pipeline_wdata["."$mem_dq_per_dqs * ($i + 1) - 1".":"."$mem_dq_per_dqs * $i"."]}"]),				       
								 
						e_comment->new({comment => "\nInstantiating DQS GROUP $i in CIO mode\n"}),
						e_blind_instance->new
						({
							name 		=> "auk_rldramii_dqs_group_$i",
							module 		=> $gWRAPPER_NAME."_auk_rldramii_dqs_group",
							in_port_map 	=>
							{
								clk			=> "clk",
								reset_clk_n		=> "reset_clk_n",
								write_clk		=> "write_clk",
								control_doing_wr	=> "pipeline_doing_wr",
								control_wdata_valid	=> "pipeline_wdata_valid",
								control_wdata      	=> "wdata_temp["."($mem_dq_per_dqs * 2) * ($i + 1) - 1".":"."($mem_dq_per_dqs * 2) * $i"."]",
								dqs_delay_ctrl	=> "dqs_delay_ctrl",
								ddr_q			=> "rldramii_q["."(($i + 1) * $mem_dq_per_dqs) - 1".":"."($i * $mem_dq_per_dqs)"."]",
                                ddr_dqs			=> "rldramii_qk[$i]",
							},
							out_port_map	=>
							{
								control_rdata		=> "rdata_temp["."($mem_dq_per_dqs * 2) * ($i + 1) - 1".":"."($mem_dq_per_dqs * 2) * $i"."]",
								dqs_group_capture_clk	=> "dqs_group_capture_clk[$i]",
                                dq_capture_clk	=> "dq_capture_clk[$i]",
								ddr_d			=> "rldramii_d["."(($i + 1) * $mem_dq_per_dqs) - 1".":"."($i * $mem_dq_per_dqs)"."]",
							},
							inout_port_map	=>
							{
								#ddr_dqs			=> "rldramii_qk[$i]",
							},
							# std_logic_vector_signals	=>
							# [
								# ddr_dqs,
							# ],
						}),
						e_assign->new(["control_rdata["."$rldramii_dw_interface + ($mem_dq_per_dqs * ($i + 1)) - 1".":"."$rldramii_dw_interface + ($mem_dq_per_dqs * $i)"."]"
							=> "rdata_temp["."($i * ($mem_dq_per_dqs * 2)) + ($mem_dq_per_dqs * 2) - 1".":"."(($mem_dq_per_dqs * 2) * $i) + $mem_dq_per_dqs"."]"]),
				  
						e_assign->new(["control_rdata["."$mem_dq_per_dqs * ($i + 1) - 1".":"."$mem_dq_per_dqs * $i"."]"
							=> "rdata_temp["."($i * ($mem_dq_per_dqs * 2)) + $mem_dq_per_dqs - 1".":"."(($mem_dq_per_dqs * 2) * $i)"."]"]),
					),
				}
				else
				{
					$module->add_contents
					(		        
						e_assign->new(["wdata_temp["."($mem_dq_per_dqs * 2) * ($i + 1) - 1".":"."($mem_dq_per_dqs * 2) * $i"."]"
							  => "{pipeline_wdata["."$rldramii_dw_interface + $mem_dq_per_dqs * ($i + 1) - 1".":"."$rldramii_dw_interface + $mem_dq_per_dqs * $i"."],
							       pipeline_wdata["."$mem_dq_per_dqs * ($i + 1) - 1".":"."$mem_dq_per_dqs * $i"."]}"]),				       
								 
						e_comment->new({comment => "\nInstantiating DQS GROUP $i in CIO mode\n"}),
						e_blind_instance->new
						({
							name 		=> "auk_rldramii_dqs_group_$i",
							module 		=> $gWRAPPER_NAME."_auk_rldramii_dqs_group",
							in_port_map 	=>
							{
								clk			=> "clk",
								reset_clk_n		=> "reset_clk_n",
								write_clk		=> "write_clk",
								non_dqs_capture_clk	=> "non_dqs_capture_clk",
								control_doing_wr	=> "pipeline_doing_wr",
								control_wdata_valid	=> "pipeline_wdata_valid",
								control_wdata      	=> "wdata_temp["."($mem_dq_per_dqs * 2) * ($i + 1) - 1".":"."($mem_dq_per_dqs * 2) * $i"."]",
								ddr_q			=> "rldramii_q["."(($i + 1) * $mem_dq_per_dqs) - 1".":"."($i * $mem_dq_per_dqs)"."]",
							},
							out_port_map	=>
							{
								control_rdata		=> "rdata_temp["."($mem_dq_per_dqs * 2) * ($i + 1) - 1".":"."($mem_dq_per_dqs * 2) * $i"."]",
								ddr_d			=> "rldramii_d["."(($i + 1) * $mem_dq_per_dqs) - 1".":"."($i * $mem_dq_per_dqs)"."]",
							},
							#inout_port_map	=>
							#{
							#	ddr_dqs			=> "rldramii_qk[$i]",
							#},
							#std_logic_vector_signals	=>
							#[
							#	ddr_dqs,
							#],
						}),
						e_assign->new(["control_rdata["."$rldramii_dw_interface + ($mem_dq_per_dqs * ($i + 1)) - 1".":"."$rldramii_dw_interface + ($mem_dq_per_dqs * $i)"."]"
							=> "rdata_temp["."($i * ($mem_dq_per_dqs * 2)) + ($mem_dq_per_dqs * 2) - 1".":"."(($mem_dq_per_dqs * 2) * $i) + $mem_dq_per_dqs"."]"]),
				  
						e_assign->new(["control_rdata["."$mem_dq_per_dqs * ($i + 1) - 1".":"."$mem_dq_per_dqs * $i"."]"
							=> "rdata_temp["."($i * ($mem_dq_per_dqs * 2)) + $mem_dq_per_dqs - 1".":"."(($mem_dq_per_dqs * 2) * $i)"."]"]),
					),
				}
			}
		}
	}
}
else
{
	if( $num_pipeline_rdata_stages > 0)
	{
		$module->add_contents
		(		        
			e_signal->new({name => "control_rdata_bus" , width => $rdata_bus_width , export => 0, never_export => 1, declare_one_bit_as_std_logic_vector => 1}),
		);
		
		if( $rldramii_type eq "cio" )
		{
			for (my $i = 0; $i < (int($rldramii_dw_interface / $mem_dq_per_dqs)); $i++)
			{
				if ($ENABLE_CAPTURE_CLK eq "false") {
					$module->add_contents
					(		        
						e_assign->new(["wdata_temp["."($mem_dq_per_dqs * 2) * ($i + 1) - 1".":"."($mem_dq_per_dqs * 2) * $i"."]"
							=> "{control_wdata["."$rldramii_dw_interface + $mem_dq_per_dqs * ($i + 1) - 1".":"."$rldramii_dw_interface + $mem_dq_per_dqs * $i"."],
							control_wdata["."$mem_dq_per_dqs * ($i + 1) - 1".":"."$mem_dq_per_dqs * $i"."]}"]),				       
								 
						e_comment->new({comment => "\nInstantiating DQS GROUP $i in CIO mode\n"}),
						e_blind_instance->new
						({
							name 		=> "auk_rldramii_dqs_group_$i",
							module 		=> $gWRAPPER_NAME."_auk_rldramii_dqs_group",
							in_port_map 	=>
							{
								clk			=> "clk",
								reset_clk_n		=> "reset_clk_n",
								write_clk		=> "write_clk",
								control_doing_wr	=> "control_doing_wr",
								control_wdata_valid	=> "control_wdata_valid",
								control_wdata      	=> "wdata_temp["."($mem_dq_per_dqs * 2) * ($i + 1) - 1".":"."($mem_dq_per_dqs * 2) * $i"."]",
								dqs_delay_ctrl		=> "dqs_delay_ctrl",
                                ddr_dqs			=> "rldramii_qk[$i]",
							},
							out_port_map	=>
							{
								control_rdata		=> "control_rdata_bus["."($mem_dq_per_dqs * 2) * ($i + 1) - 1".":"."($mem_dq_per_dqs * 2) * $i"."]",
								dqs_group_capture_clk	=> "dqs_group_capture_clk[$i]",
                                dq_capture_clk	=> "dq_capture_clk[$i]",
							},
							inout_port_map	=>
							{
								#ddr_dqs			=> "rldramii_qk[$i]",
								ddr_dq			=> "rldramii_dq["."(($i + 1) * $mem_dq_per_dqs) - 1".":"."($i * $mem_dq_per_dqs)"."]",
							},
							# std_logic_vector_signals	=>
							# [
								# ddr_dqs,
							# ],
						}),
					),
				}
				else
				{
					$module->add_contents
					(		        
						e_assign->new(["wdata_temp["."($mem_dq_per_dqs * 2) * ($i + 1) - 1".":"."($mem_dq_per_dqs * 2) * $i"."]"
							=> "{control_wdata["."$rldramii_dw_interface + $mem_dq_per_dqs * ($i + 1) - 1".":"."$rldramii_dw_interface + $mem_dq_per_dqs * $i"."],
							control_wdata["."$mem_dq_per_dqs * ($i + 1) - 1".":"."$mem_dq_per_dqs * $i"."]}"]),				       
								 
						e_comment->new({comment => "\nInstantiating DQS GROUP $i in CIO mode\n"}),
						e_blind_instance->new
						({
							name 		=> "auk_rldramii_dqs_group_$i",
							module 		=> $gWRAPPER_NAME."_auk_rldramii_dqs_group",
							in_port_map 	=>
							{
								clk			=> "clk",
								reset_clk_n		=> "reset_clk_n",
								write_clk		=> "write_clk",
								non_dqs_capture_clk	=> "non_dqs_capture_clk",
								control_doing_wr	=> "control_doing_wr",
								control_wdata_valid	=> "control_wdata_valid",
								control_wdata      	=> "wdata_temp["."($mem_dq_per_dqs * 2) * ($i + 1) - 1".":"."($mem_dq_per_dqs * 2) * $i"."]",
							},
							out_port_map	=>
							{
								control_rdata		=> "control_rdata_bus["."($mem_dq_per_dqs * 2) * ($i + 1) - 1".":"."($mem_dq_per_dqs * 2) * $i"."]",
							},
							inout_port_map	=>
							{
								#ddr_dqs			=> "rldramii_qk[$i]",
								ddr_dq			=> "rldramii_dq["."(($i + 1) * $mem_dq_per_dqs) - 1".":"."($i * $mem_dq_per_dqs)"."]",
							},
							#std_logic_vector_signals	=>
							#[
							#	ddr_dqs,
							#],
						}),
					),
				}
			}
		}
		elsif( $rldramii_type eq "sio" )
		{
			for (my $i = 0; $i < (int($rldramii_dw_interface / $mem_dq_per_dqs)); $i++)
			{
				if ($ENABLE_CAPTURE_CLK eq "false") {
					$module->add_contents
					(		        
						e_assign->new(["wdata_temp["."($mem_dq_per_dqs * 2) * ($i + 1) - 1".":"."($mem_dq_per_dqs * 2) * $i"."]"
							=> "{control_wdata["."$rldramii_dw_interface + $mem_dq_per_dqs * ($i + 1) - 1".":"."$rldramii_dw_interface + $mem_dq_per_dqs * $i"."],
							control_wdata["."$mem_dq_per_dqs * ($i + 1) - 1".":"."$mem_dq_per_dqs * $i"."]}"]),				       
								 
						e_comment->new({comment => "\nInstantiating DQS GROUP $i in CIO mode\n"}),
						e_blind_instance->new
						({
							name 		=> "auk_rldramii_dqs_group_$i",
							module 		=> $gWRAPPER_NAME."_auk_rldramii_dqs_group",
							in_port_map 	=>
							{
								clk			=> "clk",
								reset_clk_n		=> "reset_clk_n",
								write_clk		=> "write_clk",
								control_doing_wr	=> "control_doing_wr",
								control_wdata_valid	=> "control_wdata_valid",
								control_wdata      	=> "wdata_temp["."($mem_dq_per_dqs * 2) * ($i + 1) - 1".":"."($mem_dq_per_dqs * 2) * $i"."]",
								dqs_delay_ctrl	=> "dqs_delay_ctrl",
								ddr_q			=> "rldramii_q["."(($i + 1) * $mem_dq_per_dqs) - 1".":"."($i * $mem_dq_per_dqs)"."]",
                                ddr_dqs			=> "rldramii_qk[$i]",
							},
							out_port_map	=>
							{
								control_rdata		=> "control_rdata_bus["."($mem_dq_per_dqs * 2) * ($i + 1) - 1".":"."($mem_dq_per_dqs * 2) * $i"."]",
								dqs_group_capture_clk	=> "dqs_group_capture_clk[$i]",
                                dq_capture_clk	=> "dq_capture_clk[$i]",
								ddr_d			=> "rldramii_d["."(($i + 1) * $mem_dq_per_dqs) - 1".":"."($i * $mem_dq_per_dqs)"."]",
							},
							inout_port_map	=>
							{
								#ddr_dqs			=> "rldramii_qk[$i]",
							},
							# std_logic_vector_signals	=>
							# [
								# ddr_dqs,
							# ],
						}),
					),
				}
				else
				{
					$module->add_contents
					(		        
						e_assign->new(["wdata_temp["."($mem_dq_per_dqs * 2) * ($i + 1) - 1".":"."($mem_dq_per_dqs * 2) * $i"."]"
							=> "{control_wdata["."$rldramii_dw_interface + $mem_dq_per_dqs * ($i + 1) - 1".":"."$rldramii_dw_interface + $mem_dq_per_dqs * $i"."],
							control_wdata["."$mem_dq_per_dqs * ($i + 1) - 1".":"."$mem_dq_per_dqs * $i"."]}"]),				       
								 
						e_comment->new({comment => "\nInstantiating DQS GROUP $i in CIO mode\n"}),
						e_blind_instance->new
						({
							name 		=> "auk_rldramii_dqs_group_$i",
							module 		=> $gWRAPPER_NAME."_auk_rldramii_dqs_group",
							in_port_map 	=>
							{
								clk			=> "clk",
								reset_clk_n		=> "reset_clk_n",
								write_clk		=> "write_clk",
								non_dqs_capture_clk	=> "non_dqs_capture_clk",
								control_doing_wr	=> "control_doing_wr",
								control_wdata_valid	=> "control_wdata_valid",
								control_wdata      	=> "wdata_temp["."($mem_dq_per_dqs * 2) * ($i + 1) - 1".":"."($mem_dq_per_dqs * 2) * $i"."]",
								ddr_q			=> "rldramii_q["."(($i + 1) * $mem_dq_per_dqs) - 1".":"."($i * $mem_dq_per_dqs)"."]",
							},
							out_port_map	=>
							{
								control_rdata		=> "control_rdata_bus["."($mem_dq_per_dqs * 2) * ($i + 1) - 1".":"."($mem_dq_per_dqs * 2) * $i"."]",
								ddr_d			=> "rldramii_d["."(($i + 1) * $mem_dq_per_dqs) - 1".":"."($i * $mem_dq_per_dqs)"."]",
							},
							#inout_port_map	=>
							#{
							#	ddr_dqs			=> "rldramii_qk[$i]",
							#},
							#std_logic_vector_signals	=>
							#[
							#	ddr_dqs,
							#],
						}),
					),
				}
			}
		}
	}
	else
	{
		if( $rldramii_type eq "cio" )
		{
			for (my $i = 0; $i < (int($rldramii_dw_interface / $mem_dq_per_dqs)); $i++)
			{
				if ($ENABLE_CAPTURE_CLK eq "false") {
					$module->add_contents
					(		        
						e_assign->new(["wdata_temp["."($mem_dq_per_dqs * 2) * ($i + 1) - 1".":"."($mem_dq_per_dqs * 2) * $i"."]"
							=> "{control_wdata["."$rldramii_dw_interface + $mem_dq_per_dqs * ($i + 1) - 1".":"."$rldramii_dw_interface + $mem_dq_per_dqs * $i"."],
							control_wdata["."$mem_dq_per_dqs * ($i + 1) - 1".":"."$mem_dq_per_dqs * $i"."]}"]),				       
								 
						e_comment->new({comment => "\nInstantiating DQS GROUP $i in CIO mode\n"}),
						e_blind_instance->new
						({
							name 		=> "auk_rldramii_dqs_group_$i",
							module 		=> $gWRAPPER_NAME."_auk_rldramii_dqs_group",
							in_port_map 	=>
							{
								clk			=> "clk",
								reset_clk_n		=> "reset_clk_n",
								write_clk		=> "write_clk",
								control_doing_wr	=> "control_doing_wr",
								control_wdata_valid	=> "control_wdata_valid",
								control_wdata      	=> "wdata_temp["."($mem_dq_per_dqs * 2) * ($i + 1) - 1".":"."($mem_dq_per_dqs * 2) * $i"."]",
								dqs_delay_ctrl		=> "dqs_delay_ctrl",
                                ddr_dqs			=> "rldramii_qk[$i]",
							},
							out_port_map	=>
							{
								control_rdata		=> "rdata_temp["."($mem_dq_per_dqs * 2) * ($i + 1) - 1".":"."($mem_dq_per_dqs * 2) * $i"."]",
								dqs_group_capture_clk	=> "dqs_group_capture_clk[$i]",
                                dq_capture_clk	=> "dq_capture_clk[$i]",
							},
							inout_port_map	=>
							{
								#ddr_dqs			=> "rldramii_qk[$i]",
								ddr_dq			=> "rldramii_dq["."(($i + 1) * $mem_dq_per_dqs) - 1".":"."($i * $mem_dq_per_dqs)"."]",
							},
							# std_logic_vector_signals	=>
							# [
								# ddr_dqs,
							# ],
						}),
						e_assign->new(["control_rdata["."$rldramii_dw_interface + ($mem_dq_per_dqs * ($i + 1)) - 1".":"."$rldramii_dw_interface + ($mem_dq_per_dqs * $i)"."]"
							=> "rdata_temp["."($i * ($mem_dq_per_dqs * 2)) + ($mem_dq_per_dqs * 2) - 1".":"."(($mem_dq_per_dqs * 2) * $i) + $mem_dq_per_dqs"."]"]),
				  
						e_assign->new(["control_rdata["."$mem_dq_per_dqs * ($i + 1) - 1".":"."$mem_dq_per_dqs * $i"."]"
							=> "rdata_temp["."($i * ($mem_dq_per_dqs * 2)) + $mem_dq_per_dqs - 1".":"."(($mem_dq_per_dqs * 2) * $i)"."]"]),
					),
				}
				else
				{
					$module->add_contents
					(		        
						e_assign->new(["wdata_temp["."($mem_dq_per_dqs * 2) * ($i + 1) - 1".":"."($mem_dq_per_dqs * 2) * $i"."]"
							=> "{control_wdata["."$rldramii_dw_interface + $mem_dq_per_dqs * ($i + 1) - 1".":"."$rldramii_dw_interface + $mem_dq_per_dqs * $i"."],
							control_wdata["."$mem_dq_per_dqs * ($i + 1) - 1".":"."$mem_dq_per_dqs * $i"."]}"]),				       
								 
						e_comment->new({comment => "\nInstantiating DQS GROUP $i in CIO mode\n"}),
						e_blind_instance->new
						({
							name 		=> "auk_rldramii_dqs_group_$i",
							module 		=> $gWRAPPER_NAME."_auk_rldramii_dqs_group",
							in_port_map 	=>
							{
								clk			=> "clk",
								reset_clk_n		=> "reset_clk_n",
								write_clk		=> "write_clk",
								non_dqs_capture_clk	=> "non_dqs_capture_clk",
								control_doing_wr	=> "control_doing_wr",
								control_wdata_valid	=> "control_wdata_valid",
								control_wdata      	=> "wdata_temp["."($mem_dq_per_dqs * 2) * ($i + 1) - 1".":"."($mem_dq_per_dqs * 2) * $i"."]",
							},
							out_port_map	=>
							{
								control_rdata		=> "rdata_temp["."($mem_dq_per_dqs * 2) * ($i + 1) - 1".":"."($mem_dq_per_dqs * 2) * $i"."]",
							},
							inout_port_map	=>
							{
								#ddr_dqs			=> "rldramii_qk[$i]",
								ddr_dq			=> "rldramii_dq["."(($i + 1) * $mem_dq_per_dqs) - 1".":"."($i * $mem_dq_per_dqs)"."]",
							},
							#std_logic_vector_signals	=>
							#[
							#	ddr_dqs,
							#],
						}),
						e_assign->new(["control_rdata["."$rldramii_dw_interface + ($mem_dq_per_dqs * ($i + 1)) - 1".":"."$rldramii_dw_interface + ($mem_dq_per_dqs * $i)"."]"
							=> "rdata_temp["."($i * ($mem_dq_per_dqs * 2)) + ($mem_dq_per_dqs * 2) - 1".":"."(($mem_dq_per_dqs * 2) * $i) + $mem_dq_per_dqs"."]"]),
				  
						e_assign->new(["control_rdata["."$mem_dq_per_dqs * ($i + 1) - 1".":"."$mem_dq_per_dqs * $i"."]"
							=> "rdata_temp["."($i * ($mem_dq_per_dqs * 2)) + $mem_dq_per_dqs - 1".":"."(($mem_dq_per_dqs * 2) * $i)"."]"]),
					),
				}
			}
		}
		elsif( $rldramii_type eq "sio" )
		{
			for (my $i = 0; $i < (int($rldramii_dw_interface / $mem_dq_per_dqs)); $i++)
			{
				if ($ENABLE_CAPTURE_CLK eq "false") {
					$module->add_contents
					(		        
						e_assign->new(["wdata_temp["."($mem_dq_per_dqs * 2) * ($i + 1) - 1".":"."($mem_dq_per_dqs * 2) * $i"."]"
							=> "{control_wdata["."$rldramii_dw_interface + $mem_dq_per_dqs * ($i + 1) - 1".":"."$rldramii_dw_interface + $mem_dq_per_dqs * $i"."],
							control_wdata["."$mem_dq_per_dqs * ($i + 1) - 1".":"."$mem_dq_per_dqs * $i"."]}"]),				       
								 
						e_comment->new({comment => "\nInstantiating DQS GROUP $i in CIO mode\n"}),
						e_blind_instance->new
						({
							name 		=> "auk_rldramii_dqs_group_$i",
							module 		=> $gWRAPPER_NAME."_auk_rldramii_dqs_group",
							in_port_map 	=>
							{
								clk			=> "clk",
								reset_clk_n		=> "reset_clk_n",
								write_clk		=> "write_clk",
								control_doing_wr	=> "control_doing_wr",
								control_wdata_valid	=> "control_wdata_valid",
								control_wdata      	=> "wdata_temp["."($mem_dq_per_dqs * 2) * ($i + 1) - 1".":"."($mem_dq_per_dqs * 2) * $i"."]",
								dqs_delay_ctrl		=> "dqs_delay_ctrl",
								ddr_q			=> "rldramii_q["."(($i + 1) * $mem_dq_per_dqs) - 1".":"."($i * $mem_dq_per_dqs)"."]",
                                ddr_dqs			=> "rldramii_qk[$i]",
							},
							out_port_map	=>
							{
								control_rdata		=> "rdata_temp["."($mem_dq_per_dqs * 2) * ($i + 1) - 1".":"."($mem_dq_per_dqs * 2) * $i"."]",
								dqs_group_capture_clk	=> "dqs_group_capture_clk[$i]",
                                dq_capture_clk	=> "dq_capture_clk[$i]",
								ddr_d			=> "rldramii_d["."(($i + 1) * $mem_dq_per_dqs) - 1".":"."($i * $mem_dq_per_dqs)"."]",
							},
							inout_port_map	=>
							{
								#ddr_dqs			=> "rldramii_qk[$i]",
							},
							# std_logic_vector_signals	=>
							# [
								# ddr_dqs,
							# ],
						}),
						e_assign->new(["control_rdata["."$rldramii_dw_interface + ($mem_dq_per_dqs * ($i + 1)) - 1".":"."$rldramii_dw_interface + ($mem_dq_per_dqs * $i)"."]"
							=> "rdata_temp["."($i * ($mem_dq_per_dqs * 2)) + ($mem_dq_per_dqs * 2) - 1".":"."(($mem_dq_per_dqs * 2) * $i) + $mem_dq_per_dqs"."]"]),
				  
						e_assign->new(["control_rdata["."$mem_dq_per_dqs * ($i + 1) - 1".":"."$mem_dq_per_dqs * $i"."]"
							=> "rdata_temp["."($i * ($mem_dq_per_dqs * 2)) + $mem_dq_per_dqs - 1".":"."(($mem_dq_per_dqs * 2) * $i)"."]"]),
					),
				}
				else
				{
					$module->add_contents
					(		        
						e_assign->new(["wdata_temp["."($mem_dq_per_dqs * 2) * ($i + 1) - 1".":"."($mem_dq_per_dqs * 2) * $i"."]"
							=> "{control_wdata["."$rldramii_dw_interface + $mem_dq_per_dqs * ($i + 1) - 1".":"."$rldramii_dw_interface + $mem_dq_per_dqs * $i"."],
							control_wdata["."$mem_dq_per_dqs * ($i + 1) - 1".":"."$mem_dq_per_dqs * $i"."]}"]),				       
								 
						e_comment->new({comment => "\nInstantiating DQS GROUP $i in CIO mode\n"}),
						e_blind_instance->new
						({
							name 		=> "auk_rldramii_dqs_group_$i",
							module 		=> $gWRAPPER_NAME."_auk_rldramii_dqs_group",
							in_port_map 	=>
							{
								clk			=> "clk",
								reset_clk_n		=> "reset_clk_n",
								write_clk		=> "write_clk",
								non_dqs_capture_clk	=> "non_dqs_capture_clk",
								control_doing_wr	=> "control_doing_wr",
								control_wdata_valid	=> "control_wdata_valid",
								control_wdata      	=> "wdata_temp["."($mem_dq_per_dqs * 2) * ($i + 1) - 1".":"."($mem_dq_per_dqs * 2) * $i"."]",
								ddr_q			=> "rldramii_q["."(($i + 1) * $mem_dq_per_dqs) - 1".":"."($i * $mem_dq_per_dqs)"."]",
							},
							out_port_map	=>
							{
								control_rdata		=> "rdata_temp["."($mem_dq_per_dqs * 2) * ($i + 1) - 1".":"."($mem_dq_per_dqs * 2) * $i"."]",
								ddr_d			=> "rldramii_d["."(($i + 1) * $mem_dq_per_dqs) - 1".":"."($i * $mem_dq_per_dqs)"."]",
							},
							#inout_port_map	=>
							#{
							#	ddr_dqs			=> "rldramii_qk[$i]",
							#},
							#std_logic_vector_signals	=>
							#[
							#	ddr_dqs,
							#],
						}),
						e_assign->new(["control_rdata["."$rldramii_dw_interface + ($mem_dq_per_dqs * ($i + 1)) - 1".":"."$rldramii_dw_interface + ($mem_dq_per_dqs * $i)"."]"
							=> "rdata_temp["."($i * ($mem_dq_per_dqs * 2)) + ($mem_dq_per_dqs * 2) - 1".":"."(($mem_dq_per_dqs * 2) * $i) + $mem_dq_per_dqs"."]"]),
				  
						e_assign->new(["control_rdata["."$mem_dq_per_dqs * ($i + 1) - 1".":"."$mem_dq_per_dqs * $i"."]"
							=> "rdata_temp["."($i * ($mem_dq_per_dqs * 2)) + $mem_dq_per_dqs - 1".":"."(($mem_dq_per_dqs * 2) * $i)"."]"]),
					),
				}
			}
			
		}
	}
};

if( $num_pipeline_rdata_stages > 0)
{
	$j = 0;
	$k = 0;
	$device_compare = $number_dqs_per_memory;
	
	for (my $i = 0; $i < (int($rldramii_dw_interface / $mem_dq_per_dqs)); $i++)
	{
		if ($ENABLE_CAPTURE_CLK eq "false") {
			$module->add_contents
			(
				  e_comment->new({comment => "\n\nInstantiating the pipeline stage $i for the Read Data Path\n"}),
				  e_blind_instance->new
				  ({
					  name 		=> "auk_rldramii_pipeline_rdata_$i",
					  module 	=> $gWRAPPER_NAME."_auk_rldramii_pipeline_rdata",
					  in_port_map 	=>
					  {
						  clk                 	=> "dqs_group_capture_clk[$j]",
						  reset_read_clk_n      => "reset_read_clk_n[$k]",
						  pipeline_data_in    	=> "control_rdata_bus["."($mem_dq_per_dqs * 2) * ($i + 1) - 1".":"."($mem_dq_per_dqs * 2) * $i"."]",
					  },
					  out_port_map	=>
					  {
						  pipeline_data_out     => "rdata_temp["."($mem_dq_per_dqs * 2) * ($i + 1) - 1".":"."($mem_dq_per_dqs * 2) * $i"."]",
					  },
				  }),
				  
				  e_assign->new(["control_rdata["."$rldramii_dw_interface + ($mem_dq_per_dqs * ($i + 1)) - 1".":"."$rldramii_dw_interface + ($mem_dq_per_dqs * $i)"."]"
						=> "rdata_temp["."($i * ($mem_dq_per_dqs * 2)) + ($mem_dq_per_dqs * 2) - 1".":"."(($mem_dq_per_dqs * 2) * $i) + $mem_dq_per_dqs"."]"]),
				  
				  e_assign->new(["control_rdata["."$mem_dq_per_dqs * ($i + 1) - 1".":"."$mem_dq_per_dqs * $i"."]"
						=> "rdata_temp["."($i * ($mem_dq_per_dqs * 2)) + $mem_dq_per_dqs - 1".":"."(($mem_dq_per_dqs * 2) * $i)"."]"]),
			);
		}
		else
		{
			$module->add_contents
			(
				  e_comment->new({comment => "\n\nInstantiating the pipeline stage $i for the Read Data Path\n"}),
				  e_blind_instance->new
				  ({
					  name 		=> "auk_rldramii_pipeline_rdata_$i",
					  module 	=> $gWRAPPER_NAME."_auk_rldramii_pipeline_rdata",
					  in_port_map 	=>
					  {
						  clk                 	=> "non_dqs_capture_clk",
						  reset_read_clk_n      => "reset_read_clk_n",
						  pipeline_data_in    	=> "control_rdata_bus["."($mem_dq_per_dqs * 2) * ($i + 1) - 1".":"."($mem_dq_per_dqs * 2) * $i"."]",
					  },
					  out_port_map	=>
					  {
						  pipeline_data_out     => "rdata_temp["."($mem_dq_per_dqs * 2) * ($i + 1) - 1".":"."($mem_dq_per_dqs * 2) * $i"."]",
					  },
				  }),
				  
				  e_assign->new(["control_rdata["."$rldramii_dw_interface + ($mem_dq_per_dqs * ($i + 1)) - 1".":"."$rldramii_dw_interface + ($mem_dq_per_dqs * $i)"."]"
						=> "rdata_temp["."($i * ($mem_dq_per_dqs * 2)) + ($mem_dq_per_dqs * 2) - 1".":"."(($mem_dq_per_dqs * 2) * $i) + $mem_dq_per_dqs"."]"]),
				  
				  e_assign->new(["control_rdata["."$mem_dq_per_dqs * ($i + 1) - 1".":"."$mem_dq_per_dqs * $i"."]"
						=> "rdata_temp["."($i * ($mem_dq_per_dqs * 2)) + $mem_dq_per_dqs - 1".":"."(($mem_dq_per_dqs * 2) * $i)"."]"]),
			);
		}
		
		if ($i == $device_compare - 1) {
			$device_compare = $device_compare + $number_dqs_per_memory;
			$j = $j + $number_dqs_per_memory;
			$k = $k + 1;
		}
	}	
}

if($num_pipeline_qvld_stages > 0)
{
	$module->add_contents
	(		        
		e_signal->new({name => "control_qvld_bus" , width => $mem_num_devices , export => 0, never_export => 1, declare_one_bit_as_std_logic_vector => 0}),
	);
	
	$j = 0;
	for (my $i = 0; $i < $mem_num_devices; $i++ )
	{
		if ($ENABLE_CAPTURE_CLK eq "false") {
			$module->add_contents
			  (
				  e_comment->new({comment => "\nInstantiating the QVLD Group $i module\n"}),
				  e_blind_instance->new
				  ({
					  name 		=> "auk_rldramii_qvld_group_$i",
					  module 	=> $gWRAPPER_NAME."_auk_rldramii_qvld_group",
					  in_port_map 	=>
					  {
						  clk          		=> "dq_capture_clk[$j]",
						  reset_read_clk_n     	=> "reset_read_clk_n[$i]",
						  rldramii_qvld     	=> "rldramii_qvld[$i]",
					  },
					  out_port_map	=>
					  {
						  control_qvld		=> "control_qvld_bus[$i]",
					  },
				  }),
			 );
		}
		else
		{
			$module->add_contents
			  (
				  e_comment->new({comment => "\nInstantiating the QVLD Group $i module\n"}),
				  e_blind_instance->new
				  ({
					  name 		=> "auk_rldramii_qvld_group_$i",
					  module 	=> $gWRAPPER_NAME."_auk_rldramii_qvld_group",
					  in_port_map 	=>
					  {
						  clk          		=> "non_dqs_capture_clk",
						  reset_read_clk_n     	=> "reset_read_clk_n",
						  rldramii_qvld     	=> "rldramii_qvld[$i]",
					  },
					  out_port_map	=>
					  {
						  control_qvld		=> "control_qvld_bus[$i]",
					  },
				  }),
			 );
		}
		 $j = $j + $number_dqs_per_memory;
	}
	
	$l = 0;
	for (my $k = 0; $k < $mem_num_devices; $k++ )
	{
		if ($ENABLE_CAPTURE_CLK eq "false") {
			$module->add_contents
			(
				  e_comment->new({comment => "\nInstantiating the pipeline stage $k for the QVLD_Group\n"}),
				  e_blind_instance->new
				  ({
					  name 		=> "auk_rldramii_pipeline_qvld_$k",
					  module 	=> $gWRAPPER_NAME."_auk_rldramii_pipeline_qvld",
					  in_port_map 	=>
					  {
						  clk                   => "dqs_group_capture_clk[$l]",
						  reset_read_clk_n      => "reset_read_clk_n[$k]",
						  pipeline_data_in     	=> "control_qvld_bus[$k]",
					  },
					  out_port_map	=>
					  {
						  pipeline_data_out     => "control_qvld[$k]",
					  },
				  }),
			 );
		}
		else {
			$module->add_contents
			(
				  e_comment->new({comment => "\nInstantiating the pipeline stage $k for the QVLD_Group\n"}),
				  e_blind_instance->new
				  ({
					  name 		=> "auk_rldramii_pipeline_qvld_$k",
					  module 	=> $gWRAPPER_NAME."_auk_rldramii_pipeline_qvld",
					  in_port_map 	=>
					  {
						  clk                   => "non_dqs_capture_clk",
						  reset_read_clk_n      => "reset_read_clk_n",
						  pipeline_data_in     	=> "control_qvld_bus[$k]",
					  },
					  out_port_map	=>
					  {
						  pipeline_data_out     => "control_qvld[$k]",
					  },
				  }),
			 );
		}
		 $l = $l + $number_dqs_per_memory;
	}
}	
else 
{
	$j = 0;
	for (my $i = 0; $i < $mem_num_devices; $i++ )
	{
		if ($ENABLE_CAPTURE_CLK eq "false") {
			$module->add_contents
			(
				  e_comment->new({comment => "\nInstantiating the QVLD group module\n"}),
				  e_blind_instance->new
				  ({
					  name 		=> "auk_rldramii_qvld_group_$i",
					  module 	=> $gWRAPPER_NAME."_auk_rldramii_qvld_group",
					  in_port_map 	=>
					  {
						  clk          		=> "dq_capture_clk[$j]",
						  reset_read_clk_n     	=> "reset_read_clk_n[$i]",
						  rldramii_qvld     	=> "rldramii_qvld[$i]",
					  },
					  out_port_map	=>
					  {
						  control_qvld		=> "control_qvld[$i]",
					  },
				  }),
			 );
		}
		else
		{
			$module->add_contents
			(
				  e_comment->new({comment => "\nInstantiating the QVLD group module\n"}),
				  e_blind_instance->new
				  ({
					  name 		=> "auk_rldramii_qvld_group_$i",
					  module 	=> $gWRAPPER_NAME."_auk_rldramii_qvld_group",
					  in_port_map 	=>
					  {
						  clk          		=> "non_dqs_capture_clk",
						  reset_read_clk_n     	=> "reset_read_clk_n",
						  rldramii_qvld     	=> "rldramii_qvld[$i]",
					  },
					  out_port_map	=>
					  {
						  control_qvld		=> "control_qvld[$i]",
					  },
				  }),
			 );
		}
		 $j = $j + $number_dqs_per_memory;
	}
}

for (my $i = 0; $i < $mem_num_devices; $i++ )
{
	if ($enable_dm_pins eq "true") {
		 if($num_pipeline_wdata_stages > 0)
		 {
			 $module->add_contents
			 (
				e_assign->new(["dm_temp["."($i * 2) + 1".":"."$i * 2"."]"
						  => "{pipeline_dm[$i + $mem_num_devices], pipeline_dm["."$i"."]}"]),
						 
				e_comment->new({comment => "\nInstantiating the DM Group $i module\n"}),
				e_blind_instance->new
				({
					name 		=> "auk_rldramii_dm_group_$i",
					module 	=> $gWRAPPER_NAME."_auk_rldramii_dm_group",
					in_port_map 	=>
					{
						clk                  	=> "clk",
						write_clk           	=> "write_clk",
						#reset_n               	=> "reset_clk_n",
						control_doing_wr	=> "pipeline_doing_wr", 
						control_dm		=> "dm_temp[(($i+1) * 2) - 1 : $i * 2]",
					},
					out_port_map	=>
					{
						rldramii_dm      	=> "rldramii_dm[$i]",
					},
				}),
			),
		}
		else
		{
			$module->add_contents
			 (
				e_assign->new(["dm_temp["."($i * 2) + 1".":"."$i * 2"."]"
						  => "{control_dm[$i + $mem_num_devices], control_dm["."$i"."]}"]),
						 
				e_comment->new({comment => "\nInstantiating the DM Group $i module\n"}),
				e_blind_instance->new
				({
					name 		=> "auk_rldramii_dm_group_$i",
					module 	=> $gWRAPPER_NAME."_auk_rldramii_dm_group",
					in_port_map 	=>
					{
						clk                  	=> "clk",
						write_clk           	=> "write_clk",
						#reset_n               	=> "reset_clk_n",
						control_doing_wr	=> "control_doing_wr", 
						control_dm		=> "dm_temp[(($i+1) * 2) - 1 : $i * 2]",
					},
					out_port_map	=>
					{
						rldramii_dm      	=> "rldramii_dm[$i]",
					},
				}),
			),
		}
	}
 }

##################################################################################################################################################################
$project->output();
}

1;
#You're done.
