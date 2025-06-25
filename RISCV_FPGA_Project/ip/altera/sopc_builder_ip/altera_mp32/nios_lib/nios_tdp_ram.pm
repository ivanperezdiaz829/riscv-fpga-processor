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















=head1 NAME

nios_tdp_ram - description of the module goes here ...

=head1 SYNOPSIS

The nios_tdp_ram class implements ... detailed description of functionality

=head1 METHODS

=over 4

=cut

package nios_tdp_ram;

use europa_utils;
use e_instance;
use e_blind_instance;

@ISA = qw (e_instance);

use strict;

my %fields =
(

  a_data_width => 0,
  b_data_width => 0,
  a_address_width => 0,
  b_address_width => 0,
  a_num_words     => 0,
  b_num_words     => 0,
  


  read_latency => 1,
  implement_as_esb => 1,
  




  write_pass_through => 0,


  read_during_write_mode_mixed_ports => qq("OLD_DATA"),
  

  contents_file     => '',


  Opt => undef,


  ram_block_type => qq("AUTO"),
  intended_device_family => qq("Stratix"),
  maximum_depth => 0,
  _lpm_file_name => '',
);

my %pointers =
(
);

&package_setup_fields_and_pointers
    (__PACKAGE__,
     \%fields, 
     \%pointers,
     );







=item I<new()>

Object constructor

=cut

sub new 
{
  my $this = shift;
  my $self = $this->SUPER::new(@_);


  my $read_latency = $self->read_latency();
  ribbit("Illegal read latency '$read_latency'")
    if ($read_latency != 1 and $read_latency != 2);
    
  ribbit("'A' Data Port width not specified") if $self->a_data_width() == 0;
  ribbit("'B' Data Port width not specified") if $self->b_data_width() == 0;
  ribbit("'A' Address Port width not specified") if $self->a_address_width() == 0;
  ribbit("'B' Address Port width not specified") if $self->b_address_width() == 0;



  if ($self->{num_words})  {
    if ($self->a_data_width() == $self->b_data_width() ) {
      $self->a_num_words($self->{num_words})
        if ($self->a_data_width() == 0 );
      $self->b_num_words($self->{num_words})
        if ($self->b_data_width() == 0 );
    } else {
      &ribbit ("Unable to convert e_dpram-style num_words into nios_tdp_ram
        a_num_words and b_num_words.  Either delete num_words parameter, or use
        a_num_words and b_num_words");  
    }
  }

  $self->a_num_words(2**($self->a_address_width())) 
      if $self->a_num_words() == 0;
  $self->b_num_words(2**($self->b_address_width())) 
      if $self->b_num_words() == 0;
  
  $self->_create_module();

  $self->_lpm_file_name($self->name()."_lpm_file");
  $self->parameter_map({lpm_file => $self->_lpm_file_name()}); 
  $self->declare_parameters_as_variables(["lpm_file"]);

  return $self;
}



=item I<_a_byteenable_width()>

method description goes here...
...remember: there must be a newline around each POD tag (e.g. =item, =cut etc)!

=cut

sub _a_byteenable_width
{
  my $this = shift;
  
  return ceil($this->a_data_width() / 8.0);
}



=item I<_b_byteenable_width()>

method description goes here...
...remember: there must be a newline around each POD tag (e.g. =item, =cut etc)!

=cut

sub _b_byteenable_width
{
  my $this = shift;
  
  return ceil($this->b_data_width() / 8.0);
}



=item I<_create_module()>

method description goes here...
...remember: there must be a newline around each POD tag (e.g. =item, =cut etc)!

=cut

sub _create_module
{
  my $this = shift;

  my $proto_name = $this->name() . "_module";
  my $module = e_module->new({name => $proto_name, });
  $module->do_black_box(0);





  my $a_data_width = $this->a_data_width();
  my $b_data_width = $this->b_data_width();



  my @bit_ports = ("wren_a", "wren_b", "clock", "clocken0", "clocken1");
  my $port;
  foreach $port (@bit_ports)
  {
      $module->add_contents(e_port->new([$port]));				
  }
      
  $module->add_contents(e_port->new(["data_a",$a_data_width]));
  $module->add_contents(e_port->new(["data_b",$b_data_width]));
      
  $module->add_contents(e_port->new(["address_a",$this->a_address_width()]));
  $module->add_contents(e_port->new(["address_b",$this->b_address_width()]));

  $module->add_contents(e_port->new(["q_a",$a_data_width,"out"]));
  $module->add_contents(e_port->new(["q_b",$b_data_width,"out"]));





  if (!defined $this->port_map()->{wren_a})
  {
    $module->add_contents(
      e_signal->new({
        name => 'wren_a',
        width => 1,
        never_export => 1,
      }),
      e_assign->new(['wren_a', "1'b0"]),
    );
  }

  if (!defined $this->port_map()->{wren_b})
  {
    $module->add_contents(
      e_signal->new({
        name => 'wren_b',
        width => 1,
        never_export => 1,
      }),
      e_assign->new(['wren_b', "1'b0"]),
    );
  }

  if (!defined $this->port_map()->{clocken0})
  {
    $module->add_contents(
      e_signal->new({
        name => 'clocken0',
        width => 1,
        never_export => 1,
      }),
      e_assign->new(['clocken0', "1'b1"]),
    );
  }

  if (!defined $this->port_map()->{clocken1})
  {
    $module->add_contents(
      e_signal->new({
        name => 'clocken1',
        width => 1,
        never_export => 1,
      }),
      e_assign->new(['clocken1', "1'b1"]),
    );
  }

  if ( (defined $this->port_map()->{aclr0}) || 
       (defined $this->port_map()->{aclr1}) )
  {
      ribbit ("'aclr's are not supported by this module.");
  }

  if (!defined $this->port_map()->{data_a})
  {
    $module->add_contents(
      e_signal->new({
        name => 'data_a',
        width => $a_data_width,
        never_export => 1,
      }),
      e_assign->new(['data_a', $a_data_width . "'b0"]),
    );
  }

  if (!defined $this->port_map()->{data_b})
  {
    $module->add_contents(
      e_signal->new({
        name => 'data_b',
        width => $b_data_width,
        never_export => 1,
      }),
      e_assign->new(['data_b', $b_data_width . "'b0"]),
    );
  }
  
  if ( (!defined $this->port_map()->{address_a}) || 
       (!defined $this->port_map()->{address_b}) )
  {
      ribbit ("Both address ports are REQUIRED for altsyncram");
  }
  
  if (!defined $this->port_map()->{clock})
  {
      ribbit ("clock port is REQUIRED for altsyncram");
  }

  my $a_data_width = $this->a_data_width();

  if ((defined $this->port_map()->{byteena_a} && ($a_data_width % 8)) ||
       (defined $this->port_map()->{byteena_b} && ($b_data_width % 8)))
  {
      ribbit ("byteenables require data width to be a multiple of 8.");
  }
  
  if ($a_data_width < $b_data_width)
  {
      ribbit ("a_data_width cannot be less than b_data_width");
  }




  $module->add_contents(
			e_signal->news(
				       {
					   name => 'q_a',
					   width => $a_data_width,
					   never_export => (!defined $this->port_map()->{q_a}),
				       },
				       {
					   name => 'q_b',
					   width => $b_data_width,
					   never_export => (!defined $this->port_map()->{q_b}),
				       },
				       ),
			);
  
  $this->module($module);
}


=item I<update()>

method description goes here...
...remember: there must be a newline around each POD tag (e.g. =item, =cut etc)!

=cut

sub update
{
  my $this = shift;  
  $this->parent(@_);











  $this->add_compilation_objects();

  my $ret = $this->SUPER::update(@_);
  
  return $ret;
}













=item I<to_verilog()>

method description goes here...
...remember: there must be a newline around each POD tag (e.g. =item, =cut etc)!

=cut

sub to_verilog
{
  my $this = shift;
  my $verilog_string = ($this->SUPER::to_verilog());
  

  if($this->contents_file()){
    my @mem_string_array;
    my $contents_file = $this->contents_file() if $this->contents_file();
    my $absolut_path = $this->Opt()->{system_directory}."/".$contents_file;


    if ( ( $this->Opt()->{asic_enabled} ) && ( $this->Opt()->{asic_third_party_synthesis} ) ) {
      push(@mem_string_array, "//".$this->Opt()->{translate_off});
      push(@mem_string_array, "`ifdef NO_PLI");
      push(@mem_string_array, "  defparam ".$this->name().".lpm_file = \"".$contents_file.".dat\";");
      push(@mem_string_array, "`else");
      push(@mem_string_array, "  defparam ".$this->name().".lpm_file = \"".$contents_file.".hex\";");
      push(@mem_string_array, "`endif");
      push(@mem_string_array, "//".$this->Opt()->{translate_on}."\n");
      push(@mem_string_array, "  defparam ".$this->name().".lpm_file = \"".$contents_file.".mif\";");
    } else {
      push(@mem_string_array, "//".$this->Opt()->{translate_off});
      push(@mem_string_array, "`ifdef NO_PLI");
      push(@mem_string_array, "defparam ".$this->name().".lpm_file = \"".$contents_file.".dat\";");
      push(@mem_string_array, "`else");
      push(@mem_string_array, "defparam ".$this->name().".lpm_file = \"".$contents_file.".hex\";");
      push(@mem_string_array, "`endif");
      push(@mem_string_array, "//".$this->Opt()->{translate_on});
      push(@mem_string_array, "//".$this->Opt()->{quartus_translate_on});
      push(@mem_string_array, "//defparam ".$this->name().".lpm_file = \"".$contents_file.".mif\";");
      push(@mem_string_array, "//".$this->Opt()->{quartus_translate_off});
    }
    @mem_string_array = map{ $_."\n" }@mem_string_array;
    
    $verilog_string .= join("",@mem_string_array);
  }
  return($verilog_string);
}








=item I<to_vhdl()>

method description goes here...
...remember: there must be a newline around each POD tag (e.g. =item, =cut etc)!

=cut

sub to_vhdl
{
  my $this = shift;
  




  my $vhdl_string;


  my @mem_string_array;    
  if($this->contents_file()){
    my $contents_file = $this->contents_file() if $this->contents_file();
    my $absolut_path = $this->Opt()->{system_directory}."/".$contents_file;

    push(@mem_string_array, "--".$this->Opt()->{translate_off});
    push(@mem_string_array, "constant ".$this->_lpm_file_name()." : string := \"".$contents_file.".hex\";");
    push(@mem_string_array, "--".$this->Opt()->{translate_on});
    push(@mem_string_array, "--".$this->Opt()->{quartus_translate_on});
    push(@mem_string_array, "--constant ".$this->_lpm_file_name()." : string := \"".$contents_file.".mif\";"); 
    push(@mem_string_array, "--".$this->Opt()->{quartus_translate_off});
    @mem_string_array = map{ $_."\n" }@mem_string_array;

  }else{
    push(@mem_string_array, "constant ".$this->_lpm_file_name()." : string := \"\";");
  }
  $this->parent_module()->vhdl_add_string(join("",@mem_string_array));   
  $vhdl_string = $this->SUPER::to_vhdl(@_);
  return $vhdl_string;
}



=item I<add_compilation_objects()>

method description goes here...
...remember: there must be a newline around each POD tag (e.g. =item, =cut etc)!

=cut

sub add_compilation_objects
{
  my $this = shift;
  my $module = $this->module();

  ribbit("bad usage") if (!$module or !$this or @_);

  my @things;
  
  my $contents_file;
  if ($this->Opt()->{is_hardcopy_compatible})
  {
    $contents_file = qq("UNUSED");
  }
  else
  {
    $contents_file = "lpm_file";
  }





  if ($this->write_pass_through())
  {
      ribbit ("pass thru logic not yet implemented for BIDIR_DUAL_PORT mode!");
  }
  





  push (@things,
  e_parameter->new(["lpm_file","UNUSED","STRING"]));


  my %in_ports = (
          wren_a    => 'wren_a',
          wren_b    => 'wren_b',
          data_a    => 'data_a',
          data_b    => 'data_b',
          address_a => 'address_a',
          address_b => 'address_b',
          clock0    => 'clock',
          clock1    => 'clock',
          clocken0  => 'clocken0',
          clocken1  => 'clocken1',





      );
  
  my %out_ports = (
          q_a       => 'q_a',
          q_b       => 'q_b',
      );

  my %parameters = (
      width_a               => $this->a_data_width(),
      widthad_a             => $this->a_address_width(),
      numwords_a            => $this->a_num_words(),
      outdata_reg_a         => $this->read_latency == 1 ? qq("UNREGISTERED") : qq("CLOCK0"),


      

      width_b               => $this->b_data_width(),
      widthad_b             => $this->b_address_width(),
      numwords_b            => $this->b_num_words(),
      outdata_reg_b         => $this->read_latency == 1 ? qq("UNREGISTERED") : qq("CLOCK1"),
      address_reg_b         => qq("CLOCK1"),
      

      operation_mode        => qq("BIDIR_DUAL_PORT"),
      lpm_type              => qq("altsyncram"),
      intended_device_family=> $this->intended_device_family(),
      ram_block_type        => $this->ram_block_type(),

      read_during_write_mode_mixed_ports => $this->read_during_write_mode_mixed_ports(),


      address_aclr_a => qq("NONE"),
      address_aclr_b => qq("NONE"),
      indata_aclr_a => qq("NONE"),
      indata_aclr_b => qq("NONE"),
      outdata_aclr_a => qq("NONE"),
      outdata_aclr_b => qq("NONE"),
      outdata_reg_a => qq("UNREGISTERED"),
      outdata_reg_b => qq("UNREGISTERED"),
      wrcontrol_aclr_a => qq("NONE"),
      wrcontrol_aclr_b => qq("NONE"),
      init_file        => $contents_file,
      );

  if (defined $this->port_map()->{byteena_a}) {
    $in_ports{"byteena_a"} = "byteena_a";
    $parameters{"width_byteena_a"} = $this->_a_byteenable_width();
  }

  if (defined $this->port_map()->{byteena_b}) {
    $in_ports{"byteena_b"} = "byteena_b";
    $parameters{"width_byteena_b"} = $this->_b_byteenable_width();
  }

  if (defined $this->port_map()->{addressstall_a}) {
    $in_ports{"addressstall_a"} = "addressstall_a";
  }

  if (defined $this->port_map()->{addressstall_b}) {
    $in_ports{"addressstall_b"} = "addressstall_b";
  }

  push @things,
  e_blind_instance->new({
      name => 'the_altsyncram',
      module => 'altsyncram',
      use_sim_models => 1,
      in_port_map => \%in_ports,
      out_port_map => \%out_ports,
      parameter_map => \%parameters,
      std_logic_vector_signals => 
          [
           'address_a',
           'address_b',
           'data_a',
           'data_b',
           'q_a',
           'q_b'
           ],
  });
  


  $module->add_contents(@things);
}

qq{
Careful! Even moonlit dewdrops,
If you are lured to watch,
Are a wall before the Truth.
 - Sogyo (1667 - 1731)
};

=back

=cut

=head1 EXAMPLE

Here is a usage example ...

=head1 AUTHOR

Santa Cruz Technology Center

=head1 BUGS AND LIMITATIONS

list them here ...

=head1 SEE ALSO

The inherited class e_instance

=begin html

<A HREF="e_instance.html">e_instance</A> webpage

=end html

=head1 COPYRIGHT

Copyright (C)2001-2005 Altera Corporation, All rights reserved.

=cut

1;
