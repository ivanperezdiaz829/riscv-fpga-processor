use europa_all;
use europa_utils;
use e_comment;
use e_lpm_altddio_out;

sub write_ddr_clk_gen
{
my $top = e_module->new({name => $gWRAPPER_NAME."_auk_ddr_clk_gen"});
my $project = e_project->new({top => $top, language => $language,__system_directory =>$output_directory , timescale => "1ps / 1ps"});
my $module = $project->top();

#$module->vhdl_libraries()->{$gFAMILY} = all;
$module->vhdl_libraries()->{altera_mf} = all;

my $num_clock_pairs = $gNUM_CLOCK_PAIRS;
my $clkP_in_h = "vcc_signal";
my $clkP_in_l = "gnd_signal";
my $clkP = "clk";
if($gFAMILY eq "Stratix II"){
	$clkP_in_h = "gnd_signal";
	$clkP_in_l = "vcc_signal";
	$clkP = "clk_n";
	$module->add_contents(e_assign->new({lhs => "clk_n", rhs => "~clk"}),);
}
######################################################################################################################################################################
	$module->comment
	(
		"----------------------------------------------------------------------------------\n
		 Parameters:\n
		 Number of memory clock output pairs    : $gNUM_CLOCK_PAIRS\n
		 ----------------------------------------------------------------------------------\n",
	);
#####################################################################################################################################################################
	 $module->add_contents
	 (
	 #####	Ports declaration#	######
		 e_port->new({name => "clk",direction => "input"}),
		 e_port->new({name => "clk_to_sdram",direction => "output", width => $num_clock_pairs,declare_one_bit_as_std_logic_vector => 0}),
		 e_port->new({name => "clk_to_sdram_n",direction => "output", width => $num_clock_pairs,declare_one_bit_as_std_logic_vector => 0}),
		 e_port->new({name => "reset_n",direction => "input"}),

		 e_signal->new({name => "vcc_signal" , width => $num_clock_pairs, export => 0, never_export => 1, declare_one_bit_as_std_logic_vector => 0}),
		 e_signal->new({name => "gnd_signal" , width => $num_clock_pairs, export => 0, never_export => 1, declare_one_bit_as_std_logic_vector => 0}),

		 e_assign->new(["vcc_signal" => "{".$gNUM_CLOCK_PAIRS."{1'b1}}"]),
		 e_assign->new({lhs => "gnd_signal", rhs => "0"}),
	);
###############################################################################################################################################
if($gFEDBACK_CLOCK_MODE eq "true"){
	$module->add_contents
	(
		e_port->new({name => "fedback_clk_out",direction => "output", width => 1,declare_one_bit_as_std_logic_vector => 0}),
		e_comment->new
		({
			comment =>
			"------------------------------------------------------------\n
			Clock Driver for Fed-back clock\n
			------------------------------------------------------------\n"
		}),
		e_lpm_altddio_out->new
		({
			name 		=> "ddr_fbclk_out_p",
			module 		=> "altddio_out",
			port_map 	=>
			{
				datain_h 	=> $clkP_in_h."[0:0]",
				datain_l	=> $clkP_in_l."[0:0]",
				outclock 	=> $clkP,
			# },
			# out_port_map	=>
			# {
				dataout  => "fedback_clk_out",
			},
			parameter_map	=>
			{
			    width => 1,
#			    power_up_high => '"OFF"',
			    intended_device_family => '"'.$gFAMILY.'"',
#			    oe_reg => '"UNUSED"',
#			    extend_oe_disable => '"UNUSED"',
			    lpm_type => '"altddio_out"',
			},
		}),
	);
}
if ($gFAMILY eq "Cyclone II" )
{
	$module->add_contents
	(
		e_comment->new
		({
			comment => "------------------------------------------------------------\n
			Stratix/Cyclone can drive clocks out on normal pins using\n
			ALTDDIO_OUT megafunction\n
			------------------------------------------------------------\n
			Instantiate DDR IOs for driving the SDRAM clock off-chip\n"
		}),
		e_lpm_altddio_out->new
		({
			name 		=> "ddr_clk_out_p",
			module 		=> "altddio_out",
			port_map 	=>
			{
				datain_h 	=> "vcc_signal",
				datain_l	=> "gnd_signal",
				## aset		=> "gnd_signal[0:0]",
				outclock 	=> "clk",
			# },
			# out_port_map	=>
			# {
				dataout  => "clk_to_sdram",
			},
			parameter_map	=>
			{
			    width => $gNUM_CLOCK_PAIRS,
#			    power_up_high => '"OFF"',
			    intended_device_family => '"'.$gFAMILY.'"',
#			    oe_reg => '"UNUSED"',
#			    extend_oe_disable => '"UNUSED"',
#			    lpm_type => '"altddio_out"',
#			    invert_output => '"OFF"',
			},
			# std_logic_vector_signals =>
			# [
				# datain_h,
				# datain_l,
				# dataout,
			# ],
			# _port_default_values =>
			# {
				# datain_l,	=> $gNUM_CLOCK_PAIRS,
				# datain_h,	=> $gNUM_CLOCK_PAIRS,
				# dataout,	=> $gNUM_CLOCK_PAIRS,
			# },

		}),
	);
}else
{
	$module->add_contents
	(
		e_comment->new
		({
			comment => "------------------------------------------------------------\n
			Stratix/Cyclone can drive clocks out on normal pins using\n
			ALTDDIO_OUT megafunction\n
			------------------------------------------------------------\n
			Instantiate DDR IOs for driving the SDRAM clock off-chip\n"
		}),
		e_lpm_altddio_out->new
		({
			name 		=> "ddr_clk_out_p",
			module 		=> "altddio_out",
			port_map 	=>
			{
				datain_h 	=> $clkP_in_h,
				datain_l	=> $clkP_in_l,
				## aset		=> "gnd_signal[0:0]",
				outclock 	=> $clkP,
			# },
			# out_port_map	=>
			# {
				dataout  => "clk_to_sdram",
			},
			parameter_map	=>
			{
			    width => $gNUM_CLOCK_PAIRS,
#			    power_up_high => '"OFF"',
			    intended_device_family => '"'.$gFAMILY.'"',
#			    oe_reg => '"UNUSED"',
#			    extend_oe_disable => '"UNUSED"',
#			    lpm_type => '"altddio_out"',
			},
			# std_logic_vector_signals =>
			# [
				# datain_h,
				# datain_l,
				# dataout,
			# ],
			# _port_default_values =>
			# {
				# datain_l,	=> $gNUM_CLOCK_PAIRS,
				# datain_h,	=> $gNUM_CLOCK_PAIRS,
				# dataout,	=> $gNUM_CLOCK_PAIRS,
			# },

		}),
	);
}
########################################### cyclone II clk_n generation ##############################

if ($gpllFAMILY eq "Cyclone II")
{
	$module->add_contents
	(
		e_lpm_altddio_out->new
		({
			name 		=> "ddr_clk_out_n",
			module 		=> "altddio_out",
			port_map 	=>
			{
				datain_h 	=> "vcc_signal",#"gnd_signal[]",
				datain_l	=> "gnd_signal",#"vcc_signal",
				## aset		=> "gnd_signal[0:0]",
				outclock 	=> "clk",
			# },
			# out_port_map	=>
			# {
				dataout  => "clk_to_sdram_n",
			},
			parameter_map	=>
			{
			    width => $gNUM_CLOCK_PAIRS,
#			    power_up_high => '"OFF"',
			    intended_device_family => '"'.$gFAMILY.'"',
#			    oe_reg => '"UNUSED"',
#			    extend_oe_disable => '"UNUSED"',
#			    lpm_type => '"altddio_out"',
			    invert_output => '"ON"',
			},
			# std_logic_vector_signals =>
			# [
				# datain_h,
				# datain_l,
				# dataout,
			# ],
			# _port_default_values =>
			# {
				# datain_l,	=> $gNUM_CLOCK_PAIRS,
				# datain_h,	=> $gNUM_CLOCK_PAIRS,
				# dataout,	=> $gNUM_CLOCK_PAIRS,
			# },
		}),
#				e_comment->new({comment => "<< END MEGAWIZARD INSERT DDR_CLK_OUT\n\n"}),
	);
}
else
{
	if($gFAMILY eq "Stratix II")
	{
		$module->add_contents
		(
			
			e_lpm_altddio_out->new
			({
				name 		=> "ddr_clk_out_n",
				module 		=> "altddio_out",
				port_map 	=>
				{
					datain_h 	=> "gnd_signal",
					datain_l	=> "vcc_signal",
					## aset		=> "gnd_signal[0:0]",
					outclock 	=> "clk",
				# },
				# out_port_map	=>
				# {
					dataout  => "clk_to_sdram_n",
				},
				parameter_map	=>
				{
				    width => $gNUM_CLOCK_PAIRS,
#				    power_up_high => '"OFF"',
				    intended_device_family => '"'.$gFAMILY.'"',
#				    oe_reg => '"UNUSED"',
#				    extend_oe_disable => '"UNUSED"',
#				    lpm_type => '"altddio_out"',
				},
				# std_logic_vector_signals =>
				# [
					# datain_h,
					# datain_l,
					# dataout,
				# ],
				# _port_default_values =>
				# {
					# datain_l,	=> $gNUM_CLOCK_PAIRS,
					# datain_h,	=> $gNUM_CLOCK_PAIRS,
					# dataout,	=> $gNUM_CLOCK_PAIRS,
				# },
			}),
			#e_comment->new({comment => "<< END MEGAWIZARD INSERT DDR_CLK_OUT\n\n"}),
			#e_comment->new({comment => "<< START MEGAWIZARD INSERT DQS_REF_CLK"}),
		);
	}else
	{
		$module->add_contents
		(
			e_lpm_altddio_out->new
			({
				name 		=> "ddr_clk_out_n",
				module 		=> "altddio_out",
				port_map 	=>
				{
					datain_h 	=> "gnd_signal",
					datain_l	=> "vcc_signal",
					## aset		=> "gnd_signal[0:0]",
					outclock 	=> "clk",
				# },
				# out_port_map	=>
				# {
					dataout  => "clk_to_sdram_n",
				},
				parameter_map	=>
				{
				    width => $gNUM_CLOCK_PAIRS,
#				    power_up_high => '"OFF"',
				    intended_device_family => '"'.$gFAMILY.'"',
#				    oe_reg => '"UNUSED"',
#				    extend_oe_disable => '"UNUSED"',
#				    lpm_type => '"altddio_out"',
				},
				# std_logic_vector_signals =>
				# [
					# datain_h,
					# datain_l,
					# dataout,
				# ],
				# _port_default_values =>
				# {
					# datain_l,	=> $gNUM_CLOCK_PAIRS,
					# datain_h,	=> $gNUM_CLOCK_PAIRS,
					# dataout,	=> $gNUM_CLOCK_PAIRS,
				# },
			}),
			#e_comment->new({comment => "<< END MEGAWIZARD INSERT DDR_CLK_OUT\n\n"}),
			#e_comment->new({comment => "<< START MEGAWIZARD INSERT DQS_REF_CLK"}),
		);
	}
}
###############################################################################################################################################
$project->output();
}

1;
#You're done.
