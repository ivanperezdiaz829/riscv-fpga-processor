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












package nios_ecc_encoder;

use cpu_utils;
use europa_utils;
use e_instance;
use e_blind_instance;
use nios_altecc_encoder;

@ISA = qw (e_instance);

use strict;

my %fields =
(

  codeword_width => 0,
  dataword_width => 0,
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


  &$error("Codeword width not specified") if $self->codeword_width() == 0;
  &$error("Dataword width not specified") if $self->dataword_width() == 0;
  
  $self->_create_module();

  return $self;
}

sub 
_create_module
{
  my $this = shift;

  my $proto_name = $this->name() . "_module";
  my $module = e_module->new({name => $proto_name, });

  $module->do_black_box(0);












  for my $required_port (qw(q data))
  {
    if (!defined $this->port_map()->{$required_port})
    {
      &$error("required port '$required_port' not specified in port map");
    }
  }
  

  my @allowed_ports = qw(
    data
    q
    injs
    injd
    corrected_data
    wrsel
    test_invert
  );

  for my $port_name (keys %{$this->port_map()})
  {
    &$error ("Illegal port '$port_name'") if !grep {/$port_name/} @allowed_ports;
    
    my $port = e_port->new({
      name => $port_name,
    });
    
    $module->add_contents($port);
    
    $port_name eq 'wrsel' and do {
      next;
    };

    $port_name eq 'data' and do {
      $port->width($this->dataword_width()); next;
    };

    $port_name eq 'corrected_data' and do {
      $port->width($this->dataword_width()); next;
    };

    $port_name eq 'q' and do {
      $port->width($this->dataword_width()); $port->direction('out'); next;
    };
   
    $port_name eq 'injs' and do {
      next;
    };
    
    $port_name eq 'injd' and do {
      next;
    };
    $port_name eq 'test_invert' and do {
      $port->width($this->codeword_width()); next;
    };

    &$error("Failed to handle port '$port_name'");
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
add_objects
{
  my ($this, $type) = (@_);
  
  my $module = $this->module();

  &$error("bad usage") if (!$module or !$this);

  my @things;

  push(@things, $this->create_altecc_encoder_instance());
  
  map {$_->tag($type)} @things if $type;

  $module->add_contents(@things);
}

sub
create_altecc_encoder_instance
{
    my $this = shift;
    my @things;
    
    my $ecc_bits= $this->codeword_width() - $this->dataword_width();
    my $codeword_sz = $this->codeword_width();
    my $dataword_sz = $this->dataword_width();
    my $data_msb = $this->dataword_width() - 1;
    my $ecc_msb = $this->codeword_width() - 1;
    my $ecc_lsb = $this->dataword_width();



    my $module_name = $this->name();
    $module_name =~ s/_ecc_encoder/_altecc_encoder/;

    push(@things,
        nios_altecc_encoder->new ({
          name => $module_name,
          width_codeword          => $codeword_sz,
          width_dataword          => $dataword_sz,
          port_map => {
            data          => "data_in",
            q             => "{parity_bits,data_out}",
          },
        }),
    );

    push(@things,
        e_signal->new({
            name => "parity_bits",
            width => $ecc_bits,
            never_export => 1,
        }),

        e_signal->new({
            name => "data_out",
            width => $this->dataword_width(),
            never_export => 1,
        }),
    );




    push(@things,
        e_signal->new({
            name => "data_in",
            width => $this->dataword_width(),
            never_export => 1,
        }),
        e_assign->adds(
            [["data_in", 1],  "wrsel? corrected_data : data"],
        ),

        e_signal->new({
            name => "data_inj_bit0",
            width => 1,
            never_export => 1,
        }),
        e_assign->adds(
           [["data_inj_bit0", 1],  "(injs | injd) ^ data_in[0]"],
        ),
    );

    if ($this->dataword_width() > 1) {
        push(@things,
            e_signal->new({
                name => "data_inj_bit1",
                width => 1,
                never_export => 1,
            }),
            e_assign->adds(
               [["data_inj_bit1", 1],  "injd ^ data_in[1]"],
            ),
        );
    }





    push(@things,
         e_signal->new({ name => "q", width => $this->codeword_width(), }),
         e_signal->new({ name => "test_invert", width => $this->codeword_width(), }),
    );

    if ($this->dataword_width() == 1) {
        push(@things,
            e_assign->new(["q", "{(parity_bits^test_invert[3:1]),(data_inj_bit0^test_invert[0])}"]),
        );
    } elsif ($this->dataword_width() == 2) {
        push(@things,
            e_assign->new(["q", "{(parity_bits^test_invert[5:2]),(data_inj_bit1^test_invert[1]),(data_inj_bit0^test_invert[0])}"]),
        );
    } else {
        push(@things,
            e_assign->new(["q", "{(parity_bits^test_invert[${ecc_msb}:${ecc_lsb}]),(data_in[${data_msb}:2]^test_invert[${data_msb}:2]),(data_inj_bit1^test_invert[1]),(data_inj_bit0^test_invert[0])}"]),
        );
    }
     return @things;
        
}

__PACKAGE__->DONE();

1;
