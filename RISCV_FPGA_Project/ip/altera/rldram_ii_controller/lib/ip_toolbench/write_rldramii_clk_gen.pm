#sopc_builder free code
use europa_all; 
use europa_utils;
use e_comment;
use e_lpm_altddio_out;

sub write_auk_rldramii_clk_gen
{

my $top = e_module->new({name => $gWRAPPER_NAME."_auk_rldramii_clk_gen"});
my $project = e_project->new({top => $top, language => $language,__system_directory =>$output_directory , timescale => "1ps / 1ps"});#'temp_gen'});
my $module = $project->top();

#$module->vhdl_libraries()->{$gFAMILY} = all;
$module->vhdl_libraries()->{altera_mf} = all;


my $header_title = "RLDRAM II Controller Clock Generator";
my $project_title = "RLDRAM II Controller";
my $header_filename = $gWRAPPER_NAME."_auk_rldramii_clk_gen". $file_ext;
my $header_revision = "V" . $gWIZARD_VERSION;
my $header_abstract = "This file contains the memory clock generation for the RLDRAM II Controller.";
my $verilog_dq_io_instname;# = "\\g_datapath:\$i:g_ddr_io ";
#####   Parameters declaration  ######
my $num_clock_pairs = $gNUM_CLOCK_PAIRS;
my $family = $gFAMILY;
my $vcc_signal = (2 ** $num_clock_pairs) - 1;
my $PREFIX_NAME = $gDDR_PREFIX_NAME;

######################################################################################################################################################################
	$module->comment
	(
		"------------------------------------------------------------------------------\n
		 Title        : $header_title\n 
		 Project      : $project_title\n\n\n 
		 File         : $header_filename\n\n 
		 Revision     : $header_revision\n\n
		 Abstract:\n $header_abstract\n\n
		----------------------------------------------------------------------------------\n
		 Parameters:\n
		 Number Memory Clock Pairs          : $num_clock_pairs\n
		 ----------------------------------------------------------------------------------\n",
	);
#####################################################################################################################################################################
	 $module->add_contents
	 (
	 #####	Ports declaration#	######
		 e_port->new({name => "clk",direction => "input"}),
		 e_port->new({name => rldramii_clk,direction => "output", width => $num_clock_pairs,declare_one_bit_as_std_logic_vector => 0}),
		 e_port->new({name => rldramii_clk_n,direction => "output", width => $num_clock_pairs,declare_one_bit_as_std_logic_vector => 0}),
		 #e_port->new({name => "reset_n",direction => "input"}),
	 );
#########################################################################################################################################################
	 $module->add_contents
	 (
	# #####   signal generation #####
		 #e_signal->news #: ["signal", width, export, never_export]
		 e_signal->new({name => "clk_n" , width => 1, export => 0, never_export => 1}),
		 e_signal->new({name => "clk_p" , width => 1, export => 0, never_export => 1}),
		 e_signal->new({name => "clk_out" , width => $num_clock_pairs, export => 0, never_export => 1, declare_one_bit_as_std_logic_vector => 0}),
		 e_signal->new({name => "clk_out_n" , width => $num_clock_pairs, export => 0, never_export => 1, declare_one_bit_as_std_logic_vector => 0}),
		 e_signal->new({name => "vcc_signal" , width => $num_clock_pairs, export => 0, never_export => 1, declare_one_bit_as_std_logic_vector => 0}),
		 e_signal->new({name => "gnd_signal" , width => $num_clock_pairs, export => 0, never_export => 1, declare_one_bit_as_std_logic_vector => 0}),
	 );
######################################################################################################################################################################
	$module->add_contents
	(
	
		 e_assign->new({lhs => "clk_n", rhs => "~clk"}),
		 e_assign->new({lhs => "clk_p", rhs => "clk"}),
		 e_assign->new(["vcc_signal" => "{".$gNUM_CLOCK_PAIRS."{1'b1}}"]),
		 e_assign->new({lhs => "gnd_signal", rhs => "0"}),
				
		e_comment->new({comment => "Instantiate DDR IOs for driving the RLDRAM II clock off-chip"}),
		#e_blind_instance->new
		e_lpm_altddio_out->new
		({
			name 		=> "ddr_clk_out_p",
			module 		=> "altddio_out",
			port_map 	=>
			{
				#aset 		=> "gnd_signal",#[0:0]",
				datain_h 	=> "gnd_signal",
				datain_l	=> "vcc_signal",
				outclock 	=> "clk_n",
				dataout  	=> "clk_out",
			},
			parameter_map	=>
			{
			    width => $num_clock_pairs,
#			    power_up_high => '"OFF"',
			    intended_device_family => '"'.$family.'"',
#			    oe_reg => '"UNUSED"',
#			    extend_oe_disable => '"UNUSED"',
			    lpm_type => '"altddio_out"',
			},
		}),
		
		e_lpm_altddio_out->new
		({
			name 		=> "ddr_clk_out_n",
			module 		=> "altddio_out",
			port_map 	=>
			{
				#aset 		=> "gnd_signal",#[0:0]",
				datain_h 	=> "gnd_signal",
				datain_l	=> "vcc_signal",
				outclock 	=> "clk_p",
				dataout  	=> "clk_out_n",
			},
			parameter_map	=>
			{
			    width => $num_clock_pairs,
#			    power_up_high => '"OFF"',
			    intended_device_family => '"'.$family.'"',
#			    oe_reg => '"UNUSED"',
#			    extend_oe_disable => '"UNUSED"',
			    lpm_type => '"altddio_out"',
			},
		}),

		e_assign->new({lhs => rldramii_clk, rhs => "clk_out"}),
		e_assign->new({lhs => rldramii_clk_n, rhs => "clk_out_n"}),
	);
######################################################################################################################################################################
$project->output();
}
1;
#You're done.
