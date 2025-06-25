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


















use strict;
use europa_all;
use e_adapter_downstream_pipeline;
use e_adapter_waitrequest_pipeline;
use e_adapter_upstream_pipeline;


sub make_pipeline_bridge
{



  my $project = e_project->new(@_);

  my $module = $project->top();
  my $module_name = $module->name();
  my $system_ptf = $project->system_ptf();
  my $module_ptf = $system_ptf->{"MODULE $module_name"};
  my $WSA = &copy_of_hash($module_ptf->{"WIZARD_SCRIPT_ARGUMENTS"});


  my $slave_ptf = $module_ptf->{"SLAVE s1"};
  my $slave_sbi = $slave_ptf->{"SYSTEM_BUILDER_INFO"};
  my $master_sbi = $module_ptf->{"MASTER m1"}->{"SYSTEM_BUILDER_INFO"};
  
  my $Opt;
  $Opt->{"Data_Width"} = $slave_sbi->{"Data_Width"};
  $Opt->{"Burstcount_Width"} = $slave_ptf->{"PORT_WIRING"}->{"PORT s1_burstcount"}->{"width"};





  $Opt->{"Adapter_Address_Width"} = $slave_sbi->{"Address_Width"} + log2($Opt->{"Data_Width"} / 8);
  $Opt->{"Nativeaddress_Width"} = $slave_ptf->{"PORT_WIRING"}->{"PORT s1_nativeaddress"}->{"width"};
  

  $Opt->{"Master_Address_Width"} = $master_sbi->{"Address_Width"};
  $Opt->{"Slave_Address_Width"} = $slave_sbi->{"Address_Width"};

  $Opt->{"Enable_Arbiterlock"} = $WSA->{"Enable_Arbiterlock"};
























  $project->spaceless_module_ptf()->{"SLAVE"}{"s1"}{"SYSTEM_BUILDER_INFO"}{"Address_Width"} = $Opt->{"Adapter_Address_Width"};
  $project->spaceless_module_ptf()->{"MASTER"}{"m1"}{"SYSTEM_BUILDER_INFO"}{"Address_Width"} = $Opt->{"Adapter_Address_Width"};



  &make_downstream ($project, $module, $Opt, $WSA->{"Is_Downstream"});
  &make_upstream   ($project, $module, $Opt, $WSA->{"Is_Upstream"});
  &make_waitrequest($project, $module, $Opt, $WSA->{"Is_Waitrequest"});


  &make_top_level_wiring($project, $module, $Opt);


  &create_connection_points($module, $Opt);   
  
  $project->output();

  my ($system_name) = keys (%{$project->ptf_hash()});
  




  $project->ptf_hash()->{$system_name}{"MODULE $module_name"}{"SLAVE s1"}{"SYSTEM_BUILDER_INFO"}{"Address_Width"} = $Opt->{"Slave_Address_Width"}; 
  $project->ptf_hash()->{$system_name}{"MODULE $module_name"}{"MASTER m1"}{"SYSTEM_BUILDER_INFO"}{"Address_Width"} = $Opt->{"Master_Address_Width"}; 
  
  $project->ptf_to_file();

}  


sub create_connection_points 
{

  my $module = shift;
  my $Opt = shift;

  &create_slave($module, $Opt);
  &create_master($module, $Opt);
}




sub get_upstream_signal_widths
{
  my $Opt = shift;
  my $data_width = $Opt->{"Data_Width"};

  my $upstream_signal_widths = {
    endofpacket => 	1,
    readdata 	=> 	$data_width,
    readdatavalid => 	1,
    waitrequest => 	1,
  };

  return $upstream_signal_widths;
}




sub get_downstream_signal_widths
{
  my $Opt = shift;
  my $address_width = $Opt->{"Adapter_Address_Width"};
  my $data_width = $Opt->{"Data_Width"};
  my $nativeaddress_width = $Opt->{"Nativeaddress_Width"};
  my $burstcount_width = $Opt->{"Burstcount_Width"};

  my $downstream_signal_widths = {
    address 	=>	$address_width,
    arbiterlock => 	1,
    arbiterlock2 => 	1,
    burstcount 	=> 	$burstcount_width,
    byteenable 	=> 	$data_width/8,
    chipselect 	=> 	1,
    debugaccess => 	1,
    nativeaddress =>	$nativeaddress_width,
    read 	=>	1,
    write 	=>	1,
    writedata	=> 	$data_width,
  };

  return $downstream_signal_widths;
}


sub create_slave 
{
  my $module = shift;
  my $slave_sbi = shift;



  my $upstream_signal_widths = &get_upstream_signal_widths($slave_sbi);
  my $downstream_signal_widths = &get_downstream_signal_widths($slave_sbi);
  my @clock_reset_signals = ("clk", "reset_n");
  

  foreach my $signal_type (keys %$upstream_signal_widths) {
    $module->add_contents(
      e_port->new(["s1_$signal_type", $upstream_signal_widths->{$signal_type}, "out"]),
    ); 
  }


  foreach my $signal_type (keys %$downstream_signal_widths) {
    
    if ($signal_type eq "address") {
      next;
    }

    $module->add_contents(
      e_port->new(["s1_$signal_type", $downstream_signal_widths->{$signal_type}, "in"]),
    );
  }


  $module->add_contents(
    e_port->new(["s1_address", $slave_sbi->{"Slave_Address_Width"}, "in"]),
  );


  foreach my $signal_type (@clock_reset_signals) {
    $module->add_contents(
      e_port->new([$signal_type, 1, "in"]),
    );
  }


  my @signal_types = (keys %$upstream_signal_widths, keys %$downstream_signal_widths);

  my %type_map = map {"s1_".$_, $_} @signal_types;

  $module->add_contents(
    e_avalon_slave->new ({
      name => "s1",
      type_map => \%type_map,
    }),
  );

}


sub create_master
{
  my $module = shift;
  my $master_sbi = shift;
  my $use_arblock = $master_sbi->{"Enable_Arbiterlock"};

  my $upstream_signal_widths = &get_upstream_signal_widths($master_sbi);
  my $downstream_signal_widths = &get_downstream_signal_widths($master_sbi);


  foreach my $signal_type (keys %$upstream_signal_widths) {
    $module->add_contents(
      e_port->new(["m1_$signal_type", $upstream_signal_widths->{$signal_type}, "in"]),
    ); 
  }


  foreach my $signal_type (keys %$downstream_signal_widths) {
    
    if ($signal_type eq "address") 
    {
      next;
    }
    















    my $never_export = "0";

    if (!$use_arblock)
    {
        if ($signal_type eq "arbiterlock" || $signal_type eq "arbiterlock2") 
        {
            $never_export = "1";
        }
    }
    if ($signal_type eq "nativeaddress")
    {
        $never_export = "1";
    }

    $module->add_contents(
        e_port->new({
            name => "m1_$signal_type", 
            width => $downstream_signal_widths->{$signal_type}, 
            direction => "out",
            never_export => "$never_export"
        }),
    );
  }


  $module->add_contents(
    e_port->new(["m1_address", $master_sbi->{"Master_Address_Width"}, "out"]),
  );


  my @signal_types = (keys %$upstream_signal_widths, keys %$downstream_signal_widths);

  my %type_map = map {"m1_".$_, $_} @signal_types;

  $module->add_contents(
    e_avalon_master->new ({
      name => "m1",
      type_map => \%type_map,
    }),
  );

}






sub do_default_adapter_port_mapping
{
  my $adapter_type = shift;
  my $Opt = shift;


  my $port_map;

  my $downstream_signal_widths = &get_downstream_signal_widths($Opt);
  my $upstream_signal_widths = &get_upstream_signal_widths($Opt);

  foreach my $downstream_signal (keys %$downstream_signal_widths) {
    $port_map->{"m1_$downstream_signal"} = "${adapter_type}_m1_$downstream_signal";
    $port_map->{"s1_$downstream_signal"} = "${adapter_type}_s1_$downstream_signal";
  }

  foreach my $upstream_signal (keys %$upstream_signal_widths) {
    $port_map->{"m1_$upstream_signal"} = "${adapter_type}_m1_$upstream_signal";
    $port_map->{"s1_$upstream_signal"} = "${adapter_type}_s1_$upstream_signal";
  }

  $port_map->{"m1_clk"} = "clk";
  $port_map->{"m1_reset_n"} = "reset_n";

  return $port_map;

}


sub make_downstream
{
  my $project = shift;
  my $module = shift;
  my $Opt = shift;
  my $use_downstream = shift;
  
  my $module_name = $module->name();
  

  my $fake_hash = {
    project => $project,
    name => "${module_name}_downstream_adapter",
  };

  my $adapter;
  if ($use_downstream == 1) {
    $adapter = e_adapter_downstream_pipeline->new($fake_hash);
  }
  else {
    $adapter = e_adapter->new($fake_hash);
  }

  my $port_map = &do_default_adapter_port_mapping("downstream", $Opt);


  $module->add_contents(
    e_instance->new({
      module => $adapter,
      port_map => $port_map,
    }),
  );

}



sub make_waitrequest
{

  my $project = shift;
  my $module = shift;
  my $Opt = shift;
  my $use_waitrequest = shift;
  
  my $module_name = $module->name();


  my $fake_hash = {
    project => $project,
    name => "${module_name}_waitrequest_adapter",
  };

  my $adapter;
  if ($use_waitrequest == 1) {
    $adapter = e_adapter_waitrequest_pipeline->new($fake_hash);
  }
  else {
    $adapter = e_adapter->new($fake_hash);
  }

  my $port_map = &do_default_adapter_port_mapping("waitrequest", $Opt);


  $module->add_contents(
    e_instance->new({
      module => $adapter,
      port_map => $port_map,
    }),
  );

}


sub make_upstream
{

  my $project = shift;
  my $module = shift;
  my $Opt = shift;
  my $use_upstream = shift;

  my $module_name = $module->name();
  
  my $fake_hash = {
    project => $project,
    name => "${module_name}_upstream_adapter",
  };

  my $adapter;
  if ($use_upstream == 1) {
    $adapter = e_adapter_upstream_pipeline->new($fake_hash);
  }
  else {
    $adapter = e_adapter->new($fake_hash);
  }

  my $port_map = &do_default_adapter_port_mapping("upstream", $Opt);


  $port_map->{"s1_clk"} = "clk";
  $port_map->{"s1_reset_n"} = "reset_n";




  $port_map->{"s1_flush"} = "1'b0";
  

  $module->add_contents(
    e_instance->new({
      module => $adapter,
      port_map => $port_map,
    }),
  );

}



sub make_top_level_wiring 
{

  my $project = shift;
  my $module = shift;
  my $Opt = shift;

  my $downstream_signal_widths = &get_downstream_signal_widths($Opt);
  my $upstream_signal_widths = &get_upstream_signal_widths($Opt);


  foreach my $downstream_signal (keys %$downstream_signal_widths) {
    
    if ($downstream_signal eq "address") {
      next;
    }

    $module->add_contents(
      e_assign->new(["m1_".$downstream_signal => "downstream_m1_$downstream_signal"]),
      e_assign->new(["downstream_s1_$downstream_signal" => "upstream_m1_$downstream_signal"]),
      e_assign->new(["upstream_s1_$downstream_signal", => "waitrequest_m1_$downstream_signal"]),
      e_assign->new(["waitrequest_s1_".$downstream_signal => "s1_$downstream_signal"]),

    );
  }





  my $word_to_byte_address_shift = log2 ($Opt->{"Data_Width"} / 8);
  my $width_difference = $Opt->{"Master_Address_Width"} - $Opt->{"Adapter_Address_Width"};

  my $master_address_expr = "";



  if ($width_difference > 0) {
    $master_address_expr = "{$width_difference\'h0, downstream_m1_address}";
  }
  else {
  


    $master_address_expr = "downstream_m1_address";
  }


  my $slave_address_expr = "{s1_address, $word_to_byte_address_shift\'b0}";
  if ($word_to_byte_address_shift == 0) {
    $slave_address_expr = "s1_address";
  }

  $module->add_contents(



    e_assign->new(["waitrequest_s1_address" => $slave_address_expr]),
    e_assign->new(["upstream_s1_address" => "waitrequest_m1_address"]),
    e_assign->new(["downstream_s1_address" => "upstream_m1_address"]),


    e_assign->new(["m1_address" => "$master_address_expr"]), 
  );


  foreach my $upstream_signal (keys %$upstream_signal_widths) {
    $module->add_contents(
      e_assign->new(["downstream_m1_".$upstream_signal => "m1_$upstream_signal"]),
      e_assign->new(["upstream_m1_".$upstream_signal => "downstream_s1_$upstream_signal"]),
      e_assign->new(["waitrequest_m1_$upstream_signal" => "upstream_s1_$upstream_signal"]),
      e_assign->new(["s1_$upstream_signal" => "waitrequest_s1_$upstream_signal"]),

    );
  }

}

qq{Once there was a way to get back homewards,
Once there was a way to get back home,
Sleep pretty darlin' do not cry, 
And I will sing a lullaby,

};

