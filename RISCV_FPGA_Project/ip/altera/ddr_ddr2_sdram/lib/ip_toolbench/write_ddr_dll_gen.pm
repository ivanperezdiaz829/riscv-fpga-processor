use europa_all;
use europa_utils;
use e_comment;
use e_component;
use e_lpm_stratix_dll;
use e_lpm_stratixii_dll;

sub write_ddr_dll_gen
{


    if (($gFAMILY eq "Stratix II")  or ($gFAMILY eq "Stratix")){# and ($gENABLE_CAPTURE_CLK ne "true" this condition is not checked so the file gets generated but not added to the project
        my $top = e_module->new({name => $gWRAPPER_NAME."_auk_ddr_dll"});
        my $project = e_project->new({top => $top, language => $language,__system_directory =>$output_directory , timescale => "1ps / 1ps"});
        my $module = $project->top();

        $module->vhdl_libraries()->{$gFAMILYlc} = all;
        $module->vhdl_libraries()->{altera_mf} = all;
	$module->add_attribute(ALTERA_ATTRIBUTE=>"MESSAGE_DISABLE=14130;MESSAGE_DISABLE=14110");

        my %params;
        my $delayctrlout_sig;
        my $comment = "------------------------------------------------------------\n
        Instantiate $gFAMILY DLL\n
        ------------------------------------------------------------\n";

        # the signals to export from this DLL wrapper
        $module->add_contents(e_port->new({name=>"clk",width=>1,direction=>"input"}),);
        $module->add_contents(e_port->new({name=>"delayctrlout",width=>6,direction=>"output"}),);
        $module->add_contents(e_port->new({name=>"reset_n",width=>1,direction=>"input"}),);
        $module->add_contents(e_port->new({name=>"stratix_dll_control",width=>1,direction=>"input"}),);
        if ($gFAMILY eq "Stratix") {

            $params{'input_frequency'} = "\"$gCLOCK_PERIOD_IN_PS"."ps\"";
            $params{'phase_shift'} = "\"$gDQS_PHASE_SHIFT\"";
            $params{'sim_invalid_lock'} = 10000;
            $params{'sim_valid_lock'} = 1;

            $module->add_contents(e_assign->new({lhs => "delayctrlout[5 : 1]", rhs => "0", comment => "tie off unused bits in Stratix"}));

            $module->add_contents
            (
                e_comment->new({comment => $comment}),
                e_lpm_stratix_dll->new
                ({
                    name            => "dll",
                    module          => $gFAMILYlc."_dll",
                    port_map        =>
                    {
                        clk => "clk",
                    	delayctrlout => "delayctrlout[0]"
                    },
                    parameter_map   => {%params},
                }),
            );


    } elsif ($gFAMILY eq "Stratix II"){
	    my %dqsupdate;
	    my @dqsupdate;
	    my @dqsupdate_list;

            $params{'delay_buffer_mode'} = "\"$gSTRATIXII_DLL_DELAY_BUFFER_MODE\"";
            $params{'delay_chain_length'} = "$gSTRATIXII_DLL_DELAY_CHAIN_LENGTH";
            $params{'delayctrlout_mode'} = "\"normal\"";
            $params{'input_frequency'} = "\"$gCLOCK_PERIOD_IN_PS"."ps\"";
            $params{'jitter_reduction'} = "\"false\"";
            $params{'offsetctrlout_mode'} = "\"dynamic_addnsub\""; # "\"static\"";
            $params{'sim_loop_delay_increment'} = "144";
            $params{'sim_loop_intrinsic_delay'} = "3600";
            $params{'sim_valid_lock'} = "1";
            $params{'sim_valid_lockcount'} = "27";
            $params{'static_offset'} = "\"0\"";
            $params{'use_upndnin'} = "\"false\"";
            $params{'use_upndninclkena'} = "\"false\"";

	    $module->add_contents(e_port->new({name=>"dqsupdate",width=>1,direction=>"output"}),);
	    $module->add_contents(e_port->new({name=>"offset",width=>6,direction=>"input"}),);
	    $module->add_contents(e_port->new({name=>"addnsub",width=>1,direction=>"input"}),);

            if ($gBUFFER_DLL_DELAY_OUTPUT ne "true")
            {
		if ($gDLL_REF_CLOCK__SWITCHED_OFF_DURING_READS eq "true")
		{
			$delayctrlout_sig = "tmp_delayctrlout";
			$module->add_contents
			(
#			    e_port->new({name=>"stratix_dll_control",width=>1,direction=>"input"}),
			    e_signal->new({name => "tmp_delayctrlout",width => 6,export => 0,never_export =>1}),
			    e_register->new
			    ({
				clock       => "clk",
				d	    => "tmp_delayctrlout",
				q	    => "delayctrlout",
				enable	    => "stratix_dll_control",
				reset	    => "reset_n",
			    }),
			);
		}else
		{
			$delayctrlout_sig = "delayctrlout";
			$dqsupdate{'dqsupdate'} = "dqsupdate";
			@dqsupdate = %dqsupdate;
			foreach my $param(@dqsupdate) {push (@dqsupdate_list, $param);}
		}
	    }else
	    {
		    $delayctrlout_sig = "tmp_delayctrlout";
		    if ($gDLL_REF_CLOCK__SWITCHED_OFF_DURING_READS eq "true")
		    {
			$module->add_contents
			(
			    #e_port->new({name=>"stratix_dll_control",width=>1,direction=>"input"}),
			    e_signal->new({name => "tmp_delayctrlout",width => 6,export => 0,never_export =>1}),
			    e_register->new
			    ({
				clock       => "clk",
				d	    => "tmp_delayctrlout",
				q	    => "delayctrlout",
				enable	    => "stratix_dll_control",
				reset	    => "reset_n",
			    }),
			);
		    }else
		    {
			$module->add_contents
			(
			    e_signal->new({name => "tmp_delayctrlout",width => 6,export => 0,never_export =>1}),
			    e_register->new
			    ({
				clock       => "clk",
				d	    => "tmp_delayctrlout",
				q	    => "delayctrlout",
				enable  => "",
				reset	    => "reset_n",
			    }),
			);
		    }
	    }
            $module->add_contents
            (
                e_comment->new({comment => $comment}),
                e_lpm_stratixii_dll->new
                ({
                    name        => "dll",
                    module      => "stratixii_dll",
                    port_map    => {
                        clk             => "clk",
                        addnsub         => "addnsub",
                        offset          => "offset",
                        delayctrlout    => "$delayctrlout_sig",
                        @dqsupdate	     => @dqsupdate_list,
                    },
                    parameter_map   => {%params},
                }),
            );


        }
#####################################################################################################################################################################

        $project->output();
    }
}

1;
#You're done.
