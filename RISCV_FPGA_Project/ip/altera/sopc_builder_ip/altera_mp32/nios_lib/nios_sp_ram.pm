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












package nios_sp_ram;

use cpu_utils;
use europa_utils;
use e_instance;
use e_blind_instance;

@ISA = qw (e_instance);

use strict;

my %fields =
(

  data_width => 0,
  address_width => 0,
  num_words    => 0,
  

  contents_file     => '',


  Opt => undef,


  ram_block_type => qq("AUTO"),
  _memory_instance_name => '',
  _already_declared_file => 0,
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

sub 
new 
{
  my $this = shift;
  my $self = $this->SUPER::new(@_);


  &$error("Data width not specified") if $self->data_width() == 0;
  &$error("Address width not specified") if $self->address_width() == 0;
  $self->num_words(2**$self->address_width()) if $self->num_words() == 0;
  
  $self->_create_module();

  $self->_lpm_file_name($self->name()."_lpm_file");
  $self->parameter_map({lpm_file => $self->_lpm_file_name()}); 
  $self->declare_parameters_as_variables(["lpm_file"]);

  return $self;
}

sub 
_byteenable_width
{
  my $this = shift;
  
  return ceil($this->data_width() / 8.0);
}

sub 
_create_module
{
  my $this = shift;

  my $proto_name = $this->name() . "_module";
  my $module = e_module->new({name => $proto_name, });

  $module->do_black_box(0);















  for my $required_port (qw(clock address q wren data))
  {
    if (!defined $this->port_map()->{$required_port})
    {
      &$error("required port '$required_port' not specified in port map");
    }
  }
  

  my @allowed_ports = qw(
    clock
    reset_req
    rden
    address
    addressstall
    q
    wren
    data
    byteenable
  );

  for my $port_name (keys %{$this->port_map()})
  {
    &$error ("Illegal port '$port_name'") if !grep {/$port_name/} @allowed_ports;
    
    my $port = e_port->new({
      name => $port_name,
    });
    
    $module->add_contents($port);
    
    $port_name eq 'clock' and do {
      next;
    };

    $port_name eq 'rden' and do {
      next;
    };

    $port_name =~ 'address' and do {
      $port->width($this->address_width()); next;
    };

    $port_name eq 'addressstall' and do {
      next;
    };

    $port_name eq 'reset_req' and do {
      next;
    };

    $port_name eq 'q' and do {
      $port->width($this->data_width()); $port->direction('out'); next;
    };
   
    $port_name eq 'wren' and do {
      next;
    };
    
    $port_name eq 'data' and do {
      $port->width($this->data_width()); next;
    };

    $port_name eq 'byteenable' and do {
      $port->width($this->_byteenable_width()); next;
    };

    &$error("Failed to handle port '$port_name'");
  }

  if (!defined $this->port_map()->{reset_req})
  {
    $module->add_contents(
      e_signal->new({
        name => 'reset_req',
        width => 1,
        never_export => 1,
      }),
      e_assign->new(['reset_req', "1'b0"]),
    );
  }

  $this->module($module);
}


sub 
update
{
  my $this = shift;  
  $this->parent(@_);

  $this->add_objects();

  my $ret = $this->SUPER::update(@_);
  
  return $ret;
}

sub 
to_vhdl
{
  my $this = shift;
  




  
  my $vhdl_string;


  my @mem_string_array;    
  if($this->contents_file()){
    my $contents_file = $this->contents_file();
    my $absolut_path = $this->Opt()->{system_directory}."/".$contents_file;

    push(@mem_string_array, "--".$this->Opt()->{translate_off});
    push(@mem_string_array, "constant ".$this->_lpm_file_name()." : string := \"".$contents_file.".hex\";");
    push(@mem_string_array, "--".$this->Opt()->{translate_on});
    push(@mem_string_array, "--".$this->Opt()->{quartus_translate_on});
    push(@mem_string_array, "--constant ".$this->_lpm_file_name()." : string := \"".$contents_file.".mif\";");
    push(@mem_string_array, "--".$this->Opt()->{quartus_translate_off});
    @mem_string_array = map{ $_."\n" }@mem_string_array;
      $vhdl_string .= join("",@mem_string_array);
  }else{
    push(@mem_string_array, "constant ".$this->_lpm_file_name()." : string := \"\";");
  }

  $this->parent_module()->vhdl_add_string(join("",@mem_string_array));   
  $vhdl_string = $this->SUPER::to_vhdl(@_);
  return $vhdl_string;
}

sub 
to_verilog
{
  my $this = shift;
  my $verilog_string = ($this->SUPER::to_verilog());
  
  if ($this->contents_file()){
    my @mem_string_array;
    my $contents_file = $this->contents_file();
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

sub 
add_objects
{
  my ($this, $type) = (@_);
  
  my $module = $this->module();

  &$error("bad usage") if (!$module or !$this);

  my @things;

  $this->_memory_instance_name("the_altsyncram");

  push(@things,
	  e_signal->new({
	    name => "ram_q",
		width => $this->data_width(),
		never_export => 1,
      }),


      e_assign->new(['q', 'ram_q']),

      e_signal->new({
	    name => "clocken",
		width => 1,
		never_export => 1,
      }),


      e_assign->new(['clocken', '~reset_req']),


	  e_parameter->new(["lpm_file","UNUSED","STRING"]),
  );


  &$error("M512 RAMs don't support byte-enables") 
    if (defined($this->port_map()->{byteenable}) && 
      $this->ram_block_type() =~ /M512/);

  push(@things, $this->create_altsyncram_instance());
  
  map {$_->tag($type)} @things if $type;

  $module->add_contents(@things);
}

sub
create_altsyncram_instance
{
    my $this = shift;

    my $in_port_map = {
        clock0    => 'clock',
        clocken0  => 'clocken',
        address_a => 'address',
        data_a    => 'data',
        wren_a    => 'wren',
    };

    if (defined($this->port_map()->{addressstall})) {
      $in_port_map->{addressstall_a} = 'addressstall';
    }

    if (defined($this->port_map()->{rden})) {
      $in_port_map->{rden_a} = 'rden';
    }

    if (defined($this->port_map()->{byteenable})) {
      $in_port_map->{byteena_a} = 'byteenable';
    }

    my $out_port_map = {
        q_a       => 'ram_q',
    };

    my $parameter_map = {
        operation_mode        => qq("SINGLE_PORT"),
        ram_block_type        => $this->ram_block_type(),
        maximum_depth         => 0,
        width_a               => $this->data_width(),
        widthad_a             => $this->address_width(),
        numwords_a            => $this->num_words(),
        outdata_reg_a         => qq("UNREGISTERED"),
    };


    if (defined($this->port_map()->{byteenable})) {
      $parameter_map->{width_byteena_a} = $this->_byteenable_width();
    }


    if ($this->contents_file() && !$this->Opt()->{is_hardcopy_compatible}) {
      $parameter_map->{init_file} = "lpm_file";
    }

    return
        e_blind_instance->new({
          use_sim_models => 1,
          name => 'the_altsyncram',
          module => 'altsyncram',
          in_port_map => $in_port_map,
          out_port_map => $out_port_map,
          parameter_map => $parameter_map,
        });
}

__PACKAGE__->DONE();

1;
