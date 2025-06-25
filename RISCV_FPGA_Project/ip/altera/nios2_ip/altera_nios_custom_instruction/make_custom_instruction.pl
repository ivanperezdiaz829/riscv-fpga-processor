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
use e_custom_instruction_slave;
use strict;

my @arguments =  (@ARGV);






&make_custom_instruction (@arguments);









sub validate_custom_instruction_options
{
  my ($Opt) = (@_);
  $Opt->{Data_Width} = $Opt->{SLAVE}{s1}{SYSTEM_BUILDER_INFO}{Data_Width};
  $Opt->{Cycle_Count} = $Opt->{SYSTEM_BUILDER_INFO}{Cycle_Count};
  $Opt->{ci_has_prefix} = $Opt->{SYSTEM_BUILDER_INFO}{ci_has_prefix};
  $Opt->{Module_Name} = $Opt->{WIZARD_SCRIPT_ARGUMENTS}{Module_Name};
  $Opt->{Synthesize_Imported_HDL} =
                    $Opt->{WIZARD_SCRIPT_ARGUMENTS}{Synthesize_Imported_HDL};
  $Opt->{Simulate_Imported_HDL} =
                    $Opt->{WIZARD_SCRIPT_ARGUMENTS}{Simulate_Imported_HDL};
  &validate_parameter ({hash    => $Opt,
                        name    => "Data_Width",
                        type    => "integer",
                        default => 32,
                       });
  &validate_parameter ({hash    => $Opt,
                        name    => "Cycle_Count",
                        type    => "integer",
                        default => 1,
                       });
  &validate_parameter ({hash    => $Opt,
                        name    => "Module_Name",
                        type    => "string",
                       });
  &validate_parameter ({hash    => $Opt,
                        name    => "Synthesize_Imported_HDL",
                        type    => "boolean",
                        default => 1,
                       });
  &validate_parameter ({hash    => $Opt,
                        name    => "Simulate_Imported_HDL",
                        type    => "boolean",
                        default => 1,
                       });
  &validate_parameter ({hash    => $Opt,
                        name    => "ci_has_prefix",
                        type    => "boolean",
                        default => 0,
                       });
  &validate_parameter ({hash    => $Opt,
                        name    => "wrapper_name",
                        type    => "boolean",
                        default => $Opt->{Module_Name} . "_wrapper",
                       });
}

sub make_custom_instruction 
{
  my (@arguments) = (@_);
  my $project = e_project->new(@arguments);

  my $target_module_name = $project->_target_module_name;
  my $module_ref = $project->spaceless_system_ptf()->{MODULE};
  my $Opt = $module_ref->{$target_module_name};

  my $top = $project->top();

  &validate_custom_instruction_options ($Opt);


  my $datawidth = $Opt->{Data_Width};

  my $wrapper_empty_module;
  my $slave;

  my @slave_port_map;   # list of slave ports (hash form) from the ptf.
  my @e_ports;          # list of all (CI module & slave) europa ports.


  (my $e_ports_ref, my $slave_ports_ref) = 
                                  &get_europa_lists_of_e_ports ($project);
  @e_ports          = @{$e_ports_ref};
  @slave_port_map   = @{$slave_ports_ref};






  if (scalar (@slave_port_map) == 0) {



    push @e_ports, (
          e_port->new (["dataa",  $datawidth, "in" ]),
          e_port->new (["datab",  $datawidth, "in" ]),
          e_port->new (["result", $datawidth, "out"]),
    );


    push @slave_port_map, 
                ( dataa  => "dataa",
                  datab  => "datab",
                  result => "result"
                );



    if ($Opt->{Cycle_Count} > 1) {
      push @slave_port_map, ( 
          clk     => "clk",
          clk_en  => "clk_en",
          start   => "start",
      );
      push @e_ports, ( 
          e_port->new (["clk",    1, "in" ]),
          e_port->new (["clk_en", 1, "in" ]),
          e_port->new (["start",  1, "in"]),
      );
    }
    
    if ($Opt->{ci_has_prefix}) {
      push @slave_port_map, ( 
          prefix  => "prefix",
      );
      push @e_ports, ( 
          e_port->new (["prefix", 11, "in" ]),
      );
    }
  }



  $slave = e_custom_instruction_slave->new ({
          name     => "s1",
          type_map => { @slave_port_map },
  });

  $top->add_contents ( @e_ports) if scalar (@e_ports);

  $top->add_contents ( $slave  ) if $slave;

  my $imported_module;
  $imported_module = e_module->new ({
    name  => $Opt->{Module_Name},
    contents  => [ @e_ports ],
    _hdl_generated  => 1,


    do_black_box  => !$Opt->{Simulate_Imported_HDL},
  });
  $top->add_contents (
      e_instance->new ({
        module  => $imported_module,
        tag  => ($Opt->{Simulate_Imported_HDL} ? "normal" : "synthesis"),
      }),
  );

  $project->output();







  my $imported_files=$Opt->{HDL_INFO}{Imported_HDL_Files};
  if ($Opt->{Simulate_Imported_HDL}) {
    foreach my $output_file (split ', ',$imported_files) {

      my $current_synth_files =
          $project->module_ptf()->{HDL_INFO}{Synthesis_HDL_Files};
      if ($current_synth_files !~ /$output_file/) {
        $project->module_ptf()->{HDL_INFO}{Synthesis_HDL_Files} = 
            ($current_synth_files eq "") ?      $output_file 
                        : join ", ", $output_file, $current_synth_files;
      }
    }
    $project->ptf_to_file();
  }
}

sub make_custom_instruction_black_box 
{
  my (@arguments) = (@_);


  my $wrapper_project = e_project->new(@arguments);
  my $target_module_name = $wrapper_project->_target_module_name;
  my $module_ref = $wrapper_project->spaceless_system_ptf()->{MODULE};
  my $Opt = $module_ref->{$target_module_name};

  &validate_custom_instruction_options ($Opt);

  return if ($Opt->{Synthesize_Imported_HDL}); 

  my $datawidth = $Opt->{Data_Width};


  my @slave_ports;  # list of slave ports (hash form) from the ptf.
  my @e_ports;      # list of europa ports.
  my @e_slave_ports;  # list of ports for the slave.


  @slave_ports = 
        &get_list_of_ptf_custom_instruction_slave_ports ($wrapper_project); 




  if (scalar (@slave_ports) > 0) {
    (my $e_ports_ref, my $slave_ports_ref) = 
                                &get_europa_lists_of_e_ports ($wrapper_project);
    @e_ports      = @{$e_ports_ref};
  } else {

    @e_ports = ( 
        e_port->new (["dataa",  $datawidth, "in" ]),
        e_port->new (["datab",  $datawidth, "in" ]),
        e_port->new (["result", $datawidth, "out"]),
    );
    if ($Opt->{Cycle_Count} > 1) {
      push @e_ports,  (
          e_port->new (["clk",    1, "in" ]),
          e_port->new (["clk_en", 1, "in" ]),
          e_port->new (["start",  1, "in"]),
      );
    }
    if ($Opt->{ci_has_prefix}) {
      push @e_ports,  (
          e_port->new (["prefix",  11, "in"]),
      );
    }
  }


  $wrapper_project->_target_module_name($Opt->{wrapper_name});

  my $wrapper_top = $wrapper_project->top();
  my $datawidth = $Opt->{Data_Width};



  my $imported_module = e_module->new ({
    name  => $Opt->{Module_Name},
    contents  => [
      @e_ports,
    ],
    _explicitly_empty_module    => 1,
    do_black_box                => 1,

  });



  $wrapper_top->_explicitly_empty_module(0);
  $wrapper_top->_hdl_generated(0);
  $wrapper_top->add_contents (
        e_instance->new ({
          module  => $imported_module,
        }),
  );




  my $output_file = $wrapper_project->hdl_output_filename();
  $wrapper_project->_update_ptf($output_file);

  $wrapper_project->do_write_ptf(0);
  $wrapper_project->output();
}





sub get_list_of_ptf_ports {
  my ($project, $ref) = (@_);
  my @discovered_ports = ();
  foreach my $s (values (%$ref))
  {
    my $ptf_ports = $s->{PORT_WIRING}{PORT};
    push (@discovered_ports, 
      map {
          my $a = $ptf_ports->{$_};
          $a->{name} = $_;
          $a;
      } keys(%$ptf_ports)
    );
  }
  return @discovered_ports;
}


sub get_list_of_ptf_custom_instruction_slave_ports
{
  my ($project) = (@_);
  my $slave_ref = $project->spaceless_module_ptf()->{SLAVE};
  return &get_list_of_ptf_ports($project, $slave_ref);
}

sub get_list_of_ptf_custom_instruction_module_ports 
{
  my ($project) = (@_);
  my %port_wiring = $project->spaceless_module_ptf()->{PORT_WIRING};
  my $module_ref = \%port_wiring;

  return &get_list_of_ptf_ports($project, $module_ref);
}


sub get_europa_lists_of_e_ports 
{
  my ($project) = (@_);
  my @ports;        # list of all ports (hash form) from the ptf.
  my @slave_ports;  # list of only slave ports (hash form) from the ptf.
  my $module_port_wiring = 
      $project->spaceless_module_ptf()->{PORT_WIRING}{PORT};


  push @slave_ports,&get_list_of_ptf_custom_instruction_slave_ports ($project); 
  push @ports, @slave_ports;
  push @ports, &get_list_of_ptf_custom_instruction_module_ports ($project);



  my @e_ports = 
    map {
        e_port->new
            ({
              name      => $_->{name},
              width     => $_->{width},
              direction => $_->{direction},
            }),
    } @ports;
  my @slave_port_map =  map {
                      $_->{name} => $_->{type},
                    } @slave_ports; 

  return \@e_ports, \@slave_port_map;
}

