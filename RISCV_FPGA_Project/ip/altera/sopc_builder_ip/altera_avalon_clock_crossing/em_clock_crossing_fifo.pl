#Copyright (C)2001-2010 Altera Corporation
#Any megafunction design, and related net list (encrypted or decrypted),
#support information, device programming or simulation file, and any other
#associated documentation or information provided by Altera or a partner
#under Altera's Megafunction Partnership Program may be used only to
#program PLD devices (but not masked PLD devices) from Altera.  Any other
#use of such megafunction design, net list, support information, device
#programming or simulation file, or any other related documentation or
#information is prohibited for any other purpose, including, but not
#limited to modification, reverse engineering, de-compiling, or use with
#any other silicon devices, unless such use is explicitly licensed under
#a separate agreement with Altera or a megafunction partner.  Title to
#the intellectual property, including patents, copyrights, trademarks,
#trade secrets, or maskworks, embodied in any such megafunction design,
#net list, support information, device programming or simulation file, or
#any other related documentation or information provided by Altera or a
#megafunction partner, remains with Altera, the megafunction partner, or
#their respective licensors.  No other licenses, including any licenses
#needed under any third party's intellectual property, are provided herein.
#Copying or modifying any file, or portion thereof, to which this notice
#is attached violates this copyright.
use europa_all;
use strict;

my $proj = e_project->new(@ARGV);

&make_proj($proj);
$proj->output();

sub make_proj
{
    my $proj = shift;
    my $top_mod = $proj->top();
    my $marker = e_default_module_marker->new($top_mod);
    my $options = &copy_of_hash($proj->WSA());

    &define_derived_options($proj, $options);
    my @avalon_signals = &get_avalon_special_signals;
    my @write_and_control_signals = &get_write_and_control_signals($proj, $options);
    my @readdata_signals = &get_readdata_signals($proj, $options);

    my @signals = (@write_and_control_signals,
                   @readdata_signals,
                   @avalon_signals);

    my $slave_type_map = { map {"slave_".$_->[0] => $_->[0] }
                           @signals};

    my $master_type_map = { map {"master_".$_->[0] => $_->[0] }
                            @signals};

    e_avalon_slave->add({
                            name => 's1',
                            type_map => $slave_type_map,
                        });

    e_avalon_master->add({
                             name => 'm1',
                             type_map => $master_type_map,
                         });

    foreach (@signals)
    {
	if($_->[0] eq "address") {
	    next;
	}

	e_signal->adds(
	    ["master_".$_->[0], $_->[1],0,0,0],
	    ["slave_".$_->[0], $_->[1],0,0,0],
	);
    }

    e_signal->adds(
	["master_address", $options->{Master_Address_Width},0,0,0],
	["slave_address", $options->{Slave_Address_Width},0,0,0],
    );

    my $upstream_data_in_signals;
    my $upstream_data_out_signals;
    my $downstream_data_in_signals;
    my $downstream_data_out_signals;

    my @upstream_slave = ();
    my @upstream_master = ();
    my @downstream_slave = ();
    my @downstream_master = ();

    foreach (@write_and_control_signals)
    {
        push(@downstream_slave, "slave_".$_->[0]);
        if($_->[0] eq "read" || $_->[0] eq "write" || $_->[0] eq "address")
        {
            push(@downstream_master, "internal_master_".$_->[0]);
        }
        else
        {
            push(@downstream_master, "master_".$_->[0]);
        }
        $options->{downstream_fifo_width} = $options->{downstream_fifo_width} + $_->[1];
    }

    foreach (@readdata_signals)
    {
        push(@upstream_slave, "slave_".$_->[0]);
        push(@upstream_master, "master_".$_->[0]);
        $options->{upstream_fifo_width} = $options->{upstream_fifo_width} + $_->[1];
    }




    $upstream_data_in_signals = join ", ", @upstream_master;
    $upstream_data_out_signals = join ", ", @upstream_slave;
    $downstream_data_in_signals = join ", ", @downstream_slave;
    $downstream_data_out_signals = join ", ", @downstream_master;

    e_assign->adds
    (
        {lhs => "upstream_data_in",
         rhs => qq({$upstream_data_in_signals})},
        {lhs => qq({$upstream_data_out_signals}),
         rhs => "upstream_data_out"},
        {lhs => "downstream_data_in",
         rhs => qq({$downstream_data_in_signals})},
        {lhs => qq({$downstream_data_out_signals}),
         rhs => "downstream_data_out"},
    )

    &define_downstream_fifo($proj, $options);
    &define_upstream_fifo($proj, $options);

    &make_downstream_logic($proj, $options);
    &make_upstream_logic($proj, $options);
}

sub make_downstream_logic
{
    my $project = shift;
    my $option = shift;
    e_instance->add
    ({
        name => "the_downstream_fifo",
        module => $project->top()->name()."_downstream_fifo",
        port_map =>
            {
            wrclk => 'slave_clk',
            wrreq => 'downstream_wrreq',
            data  => 'downstream_data_in',
            rdreq => 'downstream_rdreq',
            rdclk => 'master_clk',

            aclr  => '~slave_reset_n',
            wrfull => 'downstream_wrfull',
            q      => 'downstream_data_out',
            rdempty => 'downstream_rdempty',
            },
    });








    my $upstream_write_almost_full_string = "";
    my $almost_full_threshold = $option->{Downstream_FIFO_Depth} - 1;

    if($option->{Use_Burst_Count})
    {

	$almost_full_threshold = ($option->{Downstream_FIFO_Depth} * $option->{Max_Burst_Size}) - 1;
    }
    $upstream_write_almost_full_string = "upstream_wrusedw >= $almost_full_threshold";

    e_assign->adds
    (
        {lhs => "downstream_wrreq",
         rhs => "slave_read | slave_write | downstream_wrreq_delayed"},
        {lhs => "slave_waitrequest",
         rhs => "downstream_wrfull"},
        {lhs => "downstream_rdreq",
         rhs => "!downstream_rdempty & !master_waitrequest & !upstream_write_almost_full"},
        {lhs => "upstream_write_almost_full",
         rhs => $upstream_write_almost_full_string},
    );

    e_register->add({
                       out => "downstream_wrreq_delayed",
                       in  => "slave_read | slave_write",
                       clock => "slave_clk",

                       reset => "slave_reset_n",
                       enable => 1,
                   });




    my $master_new_read_term_one = "internal_master_read & downstream_rdempty_delayed_n";
    my $master_new_read_term_two = "!master_read_write_unchanged_on_wait & !upstream_write_almost_full_delayed";
    my $master_hold_read = "master_read_write_unchanged_on_wait & internal_master_read";
    my $master_new_read = "master_new_read_term_one & master_new_read_term_two";
 
    e_assign->adds
    (
        {lhs => "master_new_read_term_one",
         rhs => $master_new_read_term_one},

        {lhs => "master_new_read_term_two",
         rhs => $master_new_read_term_two},

        {lhs => "master_new_read",
         rhs => $master_new_read},

        {lhs => "master_hold_read",
         rhs => $master_hold_read},
    );

    my $master_new_write_term_one = "internal_master_write & downstream_rdempty_delayed_n";
    my $master_new_write_term_two = "!master_read_write_unchanged_on_wait & !upstream_write_almost_full_delayed";
    my $master_new_write = "master_new_write_term_one & master_new_write_term_two";
    my $master_hold_write = "master_read_write_unchanged_on_wait & internal_master_write";

    e_assign->adds
    (
        {lhs => "master_new_write_term_one",
         rhs => $master_new_write_term_one},

        {lhs => "master_new_write_term_two",
         rhs => $master_new_write_term_two},

        {lhs => "master_new_write",
         rhs => $master_new_write},

        {lhs => "master_hold_write",
         rhs => $master_hold_write},
    );

    my $master_read_string = "master_new_read | master_hold_read";
    my $master_write_string = "master_new_write | master_hold_write";

    e_assign->adds
    (
	{lhs => "master_read_write_unchanged_on_wait",
	 rhs => "master_waitrequest_delayed"},

    );

    e_register->add({
		       out => "master_waitrequest_delayed",
		       in  => "master_waitrequest",
		       clock => "master_clk",
		       reset => "master_reset_n",
		       enable => 1,
		   });

    e_assign->adds
    (
        {lhs => "master_read",

         rhs => $master_read_string},

        {lhs => "master_write",

         rhs => $master_write_string},
    );

    e_register->add({
                       out => "downstream_rdempty_delayed_n",
                       in  => "!downstream_rdempty",
                       clock => "master_clk",
                       reset => "master_reset_n",
                       enable => 1,
                   });

    e_register->add({
                       out => "upstream_write_almost_full_delayed",
                       in  => "upstream_write_almost_full",
                       clock => "master_clk",
                       reset => "master_reset_n",
                       enable => 1,
                   });




    my $base_address = eval($option->{Base_Address});
    my $word_to_byte_address_shift = log2($option->{Data_Width} / 8);

    my $byte_address_width = $option->{Slave_Address_Width} + log2($option->{Data_Width}/8);
    my $constant_base_address_segment = sprintf("%x", $base_address >> $byte_address_width);
    my $width_difference = $option->{Master_Address_Width} - $byte_address_width;

    my $master_address_expr = "";



    if($width_difference > 0)
    {
	$master_address_expr = "{$width_difference\'h0, master_byte_address}";
    }
    else
    {


	$master_address_expr = "master_byte_address";
    }


    e_signal->add(["internal_master_address" => $option->{Slave_Address_Width}]);

    if($word_to_byte_address_shift > 0)
    {
	e_assign->add(
	    {lhs => e_signal->add(["master_byte_address" => $byte_address_width]),
	     rhs => "{internal_master_address, $word_to_byte_address_shift\'b0}"}
	);
    }
    else
    {
	e_assign->add(
	    {lhs => e_signal->add(["master_byte_address" => $byte_address_width]),
	     rhs => "{internal_master_address}"}
	);
    }

    e_assign->add(
	{lhs => "master_address",
	 rhs => $master_address_expr}
    );

}

sub make_upstream_logic
{
    my $project = shift;
    my $option = shift;

    e_instance->add
    ({
        name => "the_upstream_fifo",
        module => $project->top()->name()."_upstream_fifo",
        port_map =>
            {
                wrclk => 'master_clk',
                wrreq => 'upstream_wrreq',
                data  => 'upstream_data_in',
                rdreq => 'upstream_rdreq',
                rdclk => 'slave_clk',

                aclr  => '~master_reset_n',







                q      => 'upstream_data_out',
                rdempty => 'upstream_rdempty',





                wrusedw => 'upstream_wrusedw',
            },
    });

    e_assign->adds
    (
        {lhs => "upstream_wrreq",
         rhs => "master_readdatavalid"},
        {lhs => "upstream_rdreq",
         rhs => "!upstream_rdempty"},


    ),

    e_register->add({
                       out => "slave_readdatavalid",
                       in  => "!upstream_rdempty",
                       clock => "slave_clk",

                       reset => "slave_reset_n",
                       enable => 1,
                   });
}

sub define_derived_options
{
    my $project = shift;
    my $options = shift;

    if($options->{Use_Byte_Enable})
    {
        $options->{Byteenable_Width} =  $options->{Data_Width} / 8;
    }

    if($options->{Use_Burst_Count})
    {
        $options->{Burstcount_Width} = log2($options->{Maximum_Burst_Size}) + 1;
    }

    $options->{Upstream_Widthu} = log2($options->{Upstream_FIFO_Depth});
    $options->{Downstream_Widthu} = log2($options->{Downstream_FIFO_Depth});





    my $masterSBI = $project->module_ptf()->{"MASTER m1"}{SYSTEM_BUILDER_INFO};
    my $slaveSBI = $project->module_ptf()->{"SLAVE s1"}{SYSTEM_BUILDER_INFO};
    $options->{Master_Address_Width} = $masterSBI->{Address_Width};
    $options->{Slave_Address_Width} = $slaveSBI->{Address_Width};
    $options->{Base_Address} = $slaveSBI->{Base_Address};
    $options->{defined} = 1;
}

sub get_avalon_special_signals
{
    my @avalon_signals = ();
    push(@avalon_signals,
        [clk => 1],
        [reset_n => 1],
        [readdatavalid => 1],
        [waitrequest => 1],
        );
    return @avalon_signals;
}

sub get_write_and_control_signals
{
    my $project = shift;
    my $options = shift;

    my $options_derived = $options->{defined} || &ribbit("Must call define_derived_options first");
    my @write_and_control_signals = ();

    push (@write_and_control_signals,
         [writedata => $options->{Data_Width}],
         [address   => $options->{Slave_Address_Width}],
         [read      => 1],
         [write     => 1],
         [nativeaddress => $options->{Native_Address_Width}],
         );

    if($options->{Use_Byte_Enable})
    {
        push(@write_and_control_signals,
            [byteenable => $options->{Byteenable_Width}]);
    }

    if($options->{Use_Burst_Count})
    {
        push(@write_and_control_signals,
            [burstcount => $options->{Burstcount_Width}]);
    }

    return @write_and_control_signals;
}

sub get_readdata_signals
{
    my $project = shift;
    my $options = shift;
    my $options_derived = $options->{defined} || &ribbit("Must call define_derived_options first");
    my @readdata_signals = ();

    push (@readdata_signals,
         [readdata => $options->{Data_Width}],
         [endofpacket => 1],
         );
    return @readdata_signals;
}





sub set_synchronizer_depths
{
    my $options         = shift;
    my $fifo_parameters = shift;
    my $is_downstream   = shift;

    my $slave_sync_depth  = $options->{Slave_Synchronizer_Depth};
    my $master_sync_depth = $options->{Master_Synchronizer_Depth};

    my $is_stratix   = ($options->{Device_Family} =~ m/^stratix$/i) ||
                       ($options->{Device_Family} =~ m/^stratix\s*gx$/i);
    my $is_cyclone   = ($options->{Device_Family} =~ m/^cyclone$/i);
    my $is_stratixii = ($options->{Device_Family} =~ m/^stratix\s*ii$/i) ||
                       ($options->{Device_Family} =~ m/^stratix\s*ii\s*gx/i);
    my $is_cycloneii = ($options->{Device_Family} =~ m/^cyclone\s*ii$/i);





    if ($is_stratix || $is_cyclone)
    {
        $fifo_parameters->{"add_ram_output_register"} = qq("ON");
        $fifo_parameters->{"clocks_are_synchronized"} = qq("FALSE");
    }













    else
    {
        if ($is_downstream)
        {
            $fifo_parameters->{"rdsync_delaypipe"} = 2 + $slave_sync_depth;
            $fifo_parameters->{"wrsync_delaypipe"} = 2 + $master_sync_depth;
        }
        else
        {
            $fifo_parameters->{"rdsync_delaypipe"} = 2 + $master_sync_depth;
            $fifo_parameters->{"wrsync_delaypipe"} = 2 + $slave_sync_depth;
        }
    }




    if ($is_stratixii || $is_cycloneii)
    {
        $fifo_parameters->{"lpm_hint"} = qq("MAXIMIZE_SPEED=7,");
    }
}


sub define_downstream_fifo
{
    my $project = shift;
    my $options = shift;

    my $use_eab = $options->{Downstream_Use_Register} ? qq("OFF") : qq("ON");

    my $mod = e_module->new({name => $project->top()->name()."_downstream_fifo"});
    $project->add_module($mod);

    my %parameter_map_hash = 
    (
        intended_device_family => qq("$options->{Device_Family}"),
        lpm_numwords => $options->{Downstream_FIFO_Depth},
        lpm_showahead => qq("OFF"),
        lpm_type    => qq("dcfifo"),
        lpm_width   => $options->{downstream_fifo_width},
        lpm_widthu  => $options->{Downstream_Widthu},
        overflow_checking => qq("ON"),
        underflow_checking => qq("ON"),
        use_eab => $use_eab,
    );

    &set_synchronizer_depths($options, \%parameter_map_hash, 1);

    $mod->add_contents(
        e_blind_instance->new
        ({
            name => 'downstream_fifo',
            module => 'dcfifo',
            use_sim_models => 1,
            in_port_map =>
            {
                wrclk => 'wrclk',
                wrreq => 'wrreq',
                data  => e_signal->new([data => $options->{downstream_fifo_width}]),
                rdreq => 'rdreq',
                rdclk => 'rdclk',
                aclr  => 'aclr',
            },
            out_port_map =>
            {
                wrfull => 'wrfull',
                q      => e_signal->new([q => $options->{downstream_fifo_width}]),
                rdempty => 'rdempty',
            },
            parameter_map =>
            {
		%parameter_map_hash,
            },
        }),
    );
}

sub define_upstream_fifo
{
    my $project = shift;
    my $options = shift;

    my $use_eab = $options->{Upstream_Use_Register} ? qq("OFF") : qq("ON");

    my $mod = e_module->new({name => $project->top()->name()."_upstream_fifo"});
    $project->add_module($mod);

    my %parameter_map_hash = 
    (
	intended_device_family => qq("$options->{Device_Family}"),
	lpm_numwords => $options->{Upstream_FIFO_Depth},
	lpm_showahead => qq("OFF"),
	lpm_type    => qq("dcfifo"),
        lpm_width   => $options->{upstream_fifo_width},
        lpm_widthu  => $options->{Upstream_Widthu},
	overflow_checking => qq("ON"),
	underflow_checking => qq("ON"),
	use_eab => $use_eab,
    );

    &set_synchronizer_depths($options, \%parameter_map_hash, 0);

    $mod->add_contents(
        e_blind_instance->new
        ({
            name => 'upstream_fifo',
            module => 'dcfifo',
            use_sim_models => 1,
            in_port_map =>
            {
                wrclk => 'wrclk',
                wrreq => 'wrreq',
                data  => e_signal->new([data => $options->{upstream_fifo_width}]),
                rdreq => 'rdreq',
                rdclk => 'rdclk',
                aclr  => 'aclr',
            },
            out_port_map =>
            {





                q      => e_signal->new([q => $options->{upstream_fifo_width}]),
                rdempty => 'rdempty',





                wrusedw => e_signal->new([wrusedw => $options->{Upstream_Widthu}]),
            },
            parameter_map =>
            {
		%parameter_map_hash,
            },
        }),
    )
}

