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
use em_asmi;
use em_spi;
use strict;

if (!@ARGV)
{
  make_asmi();
}
else
{









  my $project = make_spi(@ARGV);

  my $top_module = $project->top();
  


  my $top_level_module_name = $top_module->name();


  $top_module->update();


  my @inner_ports = $top_module->get_object_names("e_port");


  my $new_name = $top_level_module_name . "_sub";
  my $inner_mod = $project->module_hash()->{$top_level_module_name};
  $inner_mod->name($new_name);
  $project->module_hash()->{$new_name} = $inner_mod;
  delete $project->module_hash()->{$top_level_module_name};
  

  my $module = e_module->new({
    name => $top_level_module_name,
    project => $project,
  });

  $module->add_contents(
    e_instance->new({
      module => $new_name,
    }),
  );


  my @port_list = ();
  foreach my $port_name (@inner_ports)
  {
    my $port = $top_module->get_object_by_name($port_name);

    ribbit() if not $port;
    ribbit() if not ref($port) eq "e_port";

    next if ($port->type() eq '') || ($port->type() eq 'export');

    push @port_list, e_port->new({
        name => $port->name(),
        width => $port->width(), 
        direction => $port->direction(),
        type => $port->type(),
      });
  }
  $module->add_contents(@port_list);


  my %type_map = ();
  map {$type_map{$_->name()} = $_->type()} @port_list;
  

  $module->add_contents(
    e_avalon_slave->new({
      name => $top_level_module_name . '_control_port',
      type_map => \%type_map,
    })
  );




  my $tspi_name = 'tornado_' . $top_level_module_name . '_atom';
  my $tspi_module = e_module->new({
    name => $tspi_name,
    project => $project,
  });
  $tspi_module->do_black_box(1);
  



  
  $tspi_module->add_contents(
    e_port->new(['dclkin', 1, 'input',]),
    e_port->new(['scein', 1, 'input',]),
    e_port->new(['sdoin', 1, 'input',]),
    e_port->new(['oe', 1, 'input',]),
    e_port->new(['data0out', 1, 'output',]),
    e_blind_instance->new({
      tag => 'synthesis',
      name => 'the_tornado_spiblock',
      module => 'tornado_spiblock',
      in_port_map => {
        dclkin => 'dclkin',
        scein => 'scein',
        sdoin => 'sdoin',
        oe => 'oe',
      },
      out_port_map => {
        data0out => 'data0out',
      },
    }),


    e_assign->new({
      tag => 'simulation',
      lhs => 'data0out',
      rhs => 'sdoin | scein | dclkin | oe',
    }),
  );
  

  $module->add_contents(
    e_instance->new({
      module => $tspi_name,
      port_map => {
        dclkin => 'SCLK',
        scein => 'SS_n',
        sdoin => 'MOSI',





        oe => "1'b0",
        data0out => 'MISO',
      },
    }),
  );

  $project->add_module($module);  
  $project->top($module);
  
  $project->output();
}
