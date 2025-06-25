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












package nios_ecc_decoder;

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


  standalone_decoder => 0,


  correct_parity => 0,
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
    one_bit_err
    two_bit_err
    one_two_or_three_bit_err
    corrected_data
  );

  for my $port_name (keys %{$this->port_map()})
  {
    &$error ("Illegal port '$port_name'") if !grep {/$port_name/} @allowed_ports;
    
    my $port = e_port->new({
      name => $port_name,
    });
    
    $module->add_contents($port);
    
    $port_name eq 'data' and do {
      $port->width($this->codeword_width()); next;
    };

    $port_name eq 'q' and do {
      $port->width($this->dataword_width()); $port->direction('out'); next;
    };

    my $corrected_data_width = $this->dataword_width();
    if ($this->correct_parity()) {
        $corrected_data_width = $this->codeword_width();
    }
    $port_name eq 'corrected_data' and do {
      $port->width($corrected_data_width); $port->direction('out'); next;
    };

    $port_name eq 'one_bit_err' and do {
      $port->direction('out'); next;
    };

    $port_name eq 'two_bit_err' and do {
      $port->direction('out'); next;
    };

    $port_name eq 'one_two_or_three_bit_err' and do {
      $port->direction('out'); next;
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

  push(@things, $this->create_altecc_decoder_instance());
  
  map {$_->tag($type)} @things if $type;

  $module->add_contents(@things);
}

sub
create_altecc_decoder_instance
{
    my $this = shift;

    my @things;

    my $ecc_bits= $this->codeword_width() - $this->dataword_width();
    my $ecc_msb = $ecc_bits - 1;
    my $ecc_msb_minus1 = $ecc_msb - 1;
    my $data_msb = $this->dataword_width() - 1;
    my $code_msb = $this->codeword_width() - 1;
    my $code_lsb = $this->codeword_width() - $ecc_bits;
    
    my $in_port_map = {
        data     => 'data_in',
    };

    my $out_port_map = {
        q             => '{expected_msb_parity,calculated_parity,data_out}',
    };

    push(@things,
        e_signal->new({
            name => "parity",
            width => $ecc_bits,
            never_export => 1,
        }),
        e_signal->new({
            name => "calculated_parity",
            width => $ecc_bits-1,
            never_export => 1,
        }),
        e_signal->new({
            name => "data_in",
            width => $this->dataword_width(),
            never_export => 1,
        }),
      

        e_signal->new({
            name => "data_out",
            width => $this->dataword_width(),
            never_export => 1,
        }),
        e_signal->new({
            name => "expected_msb_parity",
            width => 1,
            never_export => 1,
        }),
     

      e_assign->adds(
          [["parity",$ecc_bits],               "data[${code_msb}:${code_lsb}]"],
          [["data_in",$this->dataword_width()],"data[${data_msb}:0]"],
      ),
    );







    my $module_name = $this->name() . "_module";
    $module_name =~ s/_ecc_decoder/_altecc_encoder/;
    if ($this->standalone_decoder()) {
        push(@things,
        nios_altecc_encoder->new ({
          name => $module_name,
          width_codeword          => $this->codeword_width(),
          width_dataword          => $this->dataword_width(),
          port_map => {
            data          => "data_in",
            q             => "{expected_msb_parity,calculated_parity,data_out}",
          },
        }),
        );
    } else {
        push(@things,
            e_blind_instance->new({
              use_sim_models => 1,
              name => 'ecc_encoder_for_decoder',
              module => $module_name,
              in_port_map => $in_port_map,
              out_port_map => $out_port_map,
            }),
         );
    }

    my $xor_all_parity = "parity[0]";
    for (my $count=1; $count < ($ecc_bits-1) ; $count++ ) {
        $xor_all_parity = "parity[${count}] ^ " . $xor_all_parity;
    }



    push(@things,    
      e_assign->adds(
          [["data_in_parity",1],  "^data_in"],
          [["ecc_parity",1],  "${xor_all_parity}"],           
          [["extra_parity_calculated",1],  "data_in_parity ^ ecc_parity"],
      ),
      
      e_assign->adds(




          [["syndrome",$ecc_bits-1],  "parity[${ecc_msb_minus1}:0] ^ calculated_parity"],



          [["syndrome_err",1],  "syndrome != 0"],



          [["extra_parity_err",1],  "parity[${ecc_msb}] ^ extra_parity_calculated"],
      ),
    );







    push(@things,
        e_assign->adds(
            [["one_bit_err",1],  "extra_parity_err"],                                                         
            [["two_bit_err",1],  "syndrome_err & ~extra_parity_err"],
            [["one_two_or_three_bit_err",1],  "syndrome_err | extra_parity_err"],  
        ),
    );
    
    my @case_contents;
    my $parity_shifted = $this->dataword_width();
    my $data_bit_shifted = 0;
    my $powerof2 = 0;
    



    for (my $count=1; $count < $this->codeword_width() ; $count++ ) {
        my $count_powerof2 = 2 ** $powerof2;
        my $binarynum = dec2bin($count);
        if ( $count == $count_powerof2) {
            if ($this->correct_parity()) {
            push(@case_contents,
                 "${ecc_msb}'b${binarynum}" => ["corrected_bits" => "1'b1 << ${parity_shifted}"],
            );
            }
            $parity_shifted++;
            $powerof2++;
        } else {
            push(@case_contents,
                 "${ecc_msb}'b${binarynum}" => ["corrected_bits" => "1'b1 << ${data_bit_shifted}"],
            );
            $data_bit_shifted++
        }
    }
    
    push(@case_contents, 
        default => ["corrected_bits" => "0"],
    );

    my $corrected_bit_width = $this->dataword_width();
    if ($this->correct_parity()) {
       $corrected_bit_width = $this->codeword_width(); 
    }

    push(@things,
       e_signal->new({
         name => "corrected_bits",
         width => $corrected_bit_width,
         never_export => 1,
       }),
    
       e_process->new ({
         clock => "",
         contents  => [
           e_case->new ({
             switch  => "syndrome",
             parallel  => 0,
             full      => 0,
             contents  => {@case_contents},   
           }),
         ],
       }),
    );



    if ($this->correct_parity()) {
       push(@things,
             e_assign->new(["corrected_data", "data ^ corrected_bits"]),
        ); 
    } else {
        push(@things,
             e_assign->new(["corrected_data", "data_in ^ corrected_bits"]),
        );
    }


     push(@things,
         e_assign->new(["q", "data_in"]),
     );
     return @things;
}


sub dec2bin {
	my $str = unpack("B32", pack("N", shift));
	$str =~ s/^0+(?=\d)//;   # otherwise you'll get leading zeros
	return $str;
}

__PACKAGE__->DONE();

1;
