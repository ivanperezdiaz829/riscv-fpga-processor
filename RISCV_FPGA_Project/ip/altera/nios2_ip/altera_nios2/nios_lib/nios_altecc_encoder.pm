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








package nios_altecc_encoder;

use cpu_utils;
use europa_utils;
use e_instance;
use e_blind_instance;

@ISA = qw (e_instance);

use strict;

my %fields =
(

  width_dataword => 0,
  width_codeword => 0,
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


  &$error("Codeword width not specified") if $self->width_dataword() == 0;
  &$error("Dataword width not specified") if $self->width_codeword() == 0;
  
  my $width_dataword = $self->width_dataword();
  my $width_codeword = $self->width_codeword();

  my @dataword_to_codeword =
  (
    4, 6, 7, 8, 10,11,12,13,
    14,15,16,18,19,20,21,22,
    23,24,25,26,27,28,29,30,
    31,32,34,35,36,37,38,39,
    40,41,42,43,44,45,46,47,
    48,49,50,51,52,53,54,55,
    56,57,58,59,60,61,62,63,
    64,66,67,68,69,70,71,72
  );

  if (($width_dataword < 1) || ($width_dataword > 64))
  {
  	&$error("Width_dataword is out of range: $width_dataword")
  }
  
  if (($width_codeword < 4) || ($width_codeword > 72))
  {
  	&$error("Width_codeword is out of range: $width_codeword")
  }

  if($width_dataword <= 64)
  {
  	if ($width_codeword != @dataword_to_codeword[$width_dataword - 1])
  	{
  	    my $codeword = @dataword_to_codeword[$width_dataword - 1];
  	    &$error("Please assign the correct codeword: $codeword")
  	}
  }

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
  );

  for my $port_name (keys %{$this->port_map()})
  {
    &$error ("Illegal port '$port_name'") if !grep {/$port_name/} @allowed_ports;
    
    my $port = e_port->new({
      name => $port_name,
    });
    
    $module->add_contents($port);
    
    $port_name eq 'data' and do {
      $port->width($this->width_dataword()); next;
    };

    $port_name eq 'q' and do {
      $port->width($this->width_codeword()); $port->direction('out'); next;
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
    
    my $width_dataword = $this->width_dataword();
    my $width_codeword = $this->width_codeword();

    my @q_wire = "data_wire";
    my @parity_01_wire;
    my @parity_02_wire;
    my @parity_03_wire;
    my @parity_04_wire;
    my @parity_05_wire;
    my @parity_06_wire;
    my @parity_07_wire;
    my @parity_final_wire;
    

    my @encode_connection2 =
    	(
    		-1,-1, 0,-1, 1, 2, 3,-1,
    		 4, 5, 6, 7, 8, 9,10,-1,
    		11,12,13,14,15,16,17,18,
    		19,20,21,22,23,24,25,-1,
    		26,27,28,29,30,31,32,33,
    		34,35,36,37,38,39,40,41,
    		42,43,44,45,46,47,48,49,
    		50,51,52,53,54,55,56,-1,
    		57,58,59,60,61,62,63,64
    	);
    my $parity_01_size = ($width_codeword / 2 ) - 1;
    my $parity_02_size = (($width_codeword - 3) / 4 ) + 1;
    my $parity_03_size;
    my $parity_04_size;
    my $parity_05_size;
    my $parity_06_size;
    my $parity_07_size = $width_dataword - 57;
    my $parity_final_wire_size = $width_codeword - 1;


    my $encode_connection;
    my $encode_connection_plus1;
    my $encode_connection_plus2;
    my $encode_connection_plus3;
    my $encode_connection_plus4;
    my $encode_connection_plus5;
    my $encode_connection_plus6;
    my $encode_connection_plus7;
    my $encode_connection_plus8;
    my $encode_connection_plus9;
    my $encode_connection_plus10;
    my $encode_connection_plus11;
    my $encode_connection_plus12;
    my $encode_connection_plus13;
    my $encode_connection_plus14;
    my $encode_connection_plus15;

    my $j;
    my $k;
    my $kminus;
    {
        if ($width_dataword == 1)
        {
        	push(@q_wire, "data_wire[0]");
        }
        else
        {
            @parity_01_wire = "data_wire[0]";
        	$k = 1;
        	for ($j = 4; (($j < $width_codeword) & (@encode_connection2[$j] < $width_dataword)); $j = $j + 2)
        	{
        	    $kminus = $k - 1;
        	    $encode_connection = @encode_connection2[$j];
        	    push(@parity_01_wire, "(data_wire[${encode_connection}] ^ parity_01_wire[${kminus}])");
        		$k = $k + 1;
        	}
        	$kminus = $k - 1;
        	push(@q_wire, "parity_01_wire[${kminus}]");
        }
    }

    {
    	$k = 1;
    	@parity_02_wire = "data_wire[0]";
    	if ($width_dataword > 1)
    	{
    	    
    		for ($j = 5; (($j < $width_codeword) && (@encode_connection2[$j] < $width_dataword)); $j = $j + 4)
    		{
    		    $kminus = $k - 1;
    		    $encode_connection = @encode_connection2[$j];
    			$encode_connection_plus1 = $encode_connection + 1;
    			if ($encode_connection == ($width_dataword - 1))
    			{
    				push(@parity_02_wire, "(data_wire[${encode_connection}] ^ parity_02_wire[${kminus}])");
    			}
    			elsif ($encode_connection_plus1 <= ($width_dataword - 1))
    			{
    				push(@parity_02_wire, "((data_wire[${encode_connection}] ^ data_wire[${encode_connection_plus1}]) ^ parity_02_wire[${kminus}])");
    			}
    			$k ++;
    		}
    	}
    	$kminus = $k - 1;
    	push(@q_wire, "parity_02_wire[${kminus}]");
    }
    

    if ($width_dataword >= 2)
    {

    	if ($width_codeword > 68)
    	{
    		$parity_03_size = 9;
    	}
    	elsif ($width_codeword > 60)
    	{
    		$parity_03_size = 8;
    	}
    	elsif ($width_codeword > 52)
    	{
    		$parity_03_size = 7;
    	}
    	elsif ($width_codeword > 44)
    	{
    		$parity_03_size = 6;
    	}
    	elsif ($width_codeword > 36)
    	{
    		$parity_03_size = 5;
    	}
    	elsif ($width_codeword > 28)
    	{
    		$parity_03_size = 4;
    	}
    	elsif ($width_codeword > 20)
    	{
    		$parity_03_size = 3;
    	}
    	elsif ($width_codeword > 12)
    	{
    		$parity_03_size = 2;
    	}
    	else
    	{
    		$parity_03_size = 1;
    	}
    
    
    
    	if ($width_dataword == 2)
    	{
    		@parity_03_wire = "data_wire[1]";
    	}
    
    	if ($width_dataword == 3)
    	{
    		@parity_03_wire = "(data_wire[1] ^ data_wire[2])";
    	}
    
    	if ($width_dataword >= 4)
    	{
    		@parity_03_wire = "((data_wire[1] ^ data_wire[2]) ^ data_wire[3])";
    	}
    
    	$k = 1;
    
    	if ($width_dataword > 4)
    	{
    		for ($j = 11; (($j < $width_codeword) && (@encode_connection2[$j] < $width_dataword)); $j = $j + 8)
    		{
    		    $kminus = $k - 1;
    		    $encode_connection = @encode_connection2[$j];
    			$encode_connection_plus1 = $encode_connection + 1;
    			$encode_connection_plus2 = $encode_connection + 2;
    			$encode_connection_plus3 = $encode_connection + 3;
    			if ($encode_connection == ($width_dataword - 1))
    			{
    				push(@parity_03_wire, "(data_wire[${encode_connection}] ^ parity_03_wire[${kminus}])");
    			}
    			elsif ($encode_connection_plus1 == ($width_dataword - 1))
    			{
    				push(@parity_03_wire, "((data_wire[${encode_connection}] ^ data_wire[${encode_connection_plus1}]) ^ parity_03_wire[${kminus}])");
    			}
    			elsif ($encode_connection_plus2 == ($width_dataword - 1))
    			{
    				push(@parity_03_wire, "(((data_wire[${encode_connection}] ^ data_wire[${encode_connection_plus1}]) ^ data_wire[${encode_connection_plus2}]) ^ parity_03_wire[${kminus}])");
    			}
    			elsif ($encode_connection_plus3 <= ($width_dataword - 1))
    			{
    				push(@parity_03_wire, "((((data_wire[${encode_connection}] ^ data_wire[${encode_connection_plus1}]) ^ data_wire[${encode_connection_plus2}]) ^ data_wire[${encode_connection_plus3}]) ^ parity_03_wire[${kminus}])");
    			}
    
    			$k ++;
    		}
    	}
    	$kminus = $k - 1;
    	push(@q_wire, "parity_03_wire[${kminus}]");
    }
    

    if ($width_dataword >= 5)
    {

    
    	if ($width_codeword > 56)
    	{
    		$parity_04_size = 4;
    	}
    	elsif ($width_codeword > 40)
    	{
    		$parity_04_size = 3;
    	}
    	elsif ($width_codeword > 24)
    	{
    		$parity_04_size = 2;
    	}
    	else # > 9
    	{
    		$parity_04_size = 1;
    	}
    
    	if ($width_dataword == 5)
    	{
    		@parity_04_wire = "data_wire[4]";
    	}
    
    	if ($width_dataword == 6)
    	{
    		@parity_04_wire = "(data_wire[4] ^ data_wire[5])";
    	}
    
    	if ($width_dataword == 7)
    	{
    		@parity_04_wire = "((data_wire[4] ^ data_wire[5]) ^ data_wire[6])";
    	}
    
    	if ($width_dataword == 8)
    	{
    		@parity_04_wire = "(((data_wire[4] ^ data_wire[5]) ^ data_wire[6]) ^ data_wire[7])";
    	}
    
    	if ($width_dataword == 9)
    	{
    		@parity_04_wire = "((((data_wire[4] ^ data_wire[5]) ^ data_wire[6]) ^ data_wire[7]) ^ data_wire[8])";
    	}
    
    	if ($width_dataword == 10)
    	{
    		@parity_04_wire = "(((((data_wire[4] ^ data_wire[5]) ^ data_wire[6]) ^ data_wire[7]) ^ data_wire[8]) ^ data_wire[9])";
    	}
    
    	if ($width_dataword >= 11)
    	{
    		@parity_04_wire = "((((((data_wire[4] ^ data_wire[5]) ^ data_wire[6]) ^ data_wire[7]) ^ data_wire[8]) ^ data_wire[9]) ^ data_wire[10])";
    	}
    
    	$k = 1;
    
    	if ($width_dataword > 11)
    	{
    		for ($j = 23; (($j < $width_codeword) && (@encode_connection2[$j] < $width_dataword)); $j = $j + 16)
    		{
    		    $kminus = $k - 1;
    		    $encode_connection = @encode_connection2[$j];
    			$encode_connection_plus1 = $encode_connection + 1;
    			$encode_connection_plus2 = $encode_connection + 2;
    			$encode_connection_plus3 = $encode_connection + 3;
    			$encode_connection_plus4 = $encode_connection + 4;
    			$encode_connection_plus5 = $encode_connection + 5;
    			$encode_connection_plus6 = $encode_connection + 6;
    			$encode_connection_plus7 = $encode_connection + 7;
    			if ($encode_connection == ($width_dataword - 1))
    			{
    				push(@parity_04_wire, "(data_wire[${encode_connection}] ^ parity_04_wire[${kminus}])");
    			}
    			elsif ($encode_connection_plus1 == ($width_dataword - 1))
    			{
    				push(@parity_04_wire, "((data_wire[${encode_connection}] ^ data_wire[${encode_connection_plus1}]) ^ parity_04_wire[${kminus}])");
    			}
    			elsif ($encode_connection_plus2 == ($width_dataword - 1))
    			{
    				push(@parity_04_wire, "(((data_wire[${encode_connection}] ^ data_wire[${encode_connection_plus1}]) ^ data_wire[${encode_connection_plus2}]) ^ parity_04_wire[${kminus}])");
    			}
    			elsif ($encode_connection_plus3 == ($width_dataword - 1))
    			{
    			    push(@parity_04_wire, "((((data_wire[${encode_connection}] ^ data_wire[${encode_connection_plus1}]) ^ data_wire[${encode_connection_plus2}]) ^ data_wire[${encode_connection_plus3}]) ^ parity_04_wire[${kminus}])");
    			}
    			elsif ($encode_connection_plus4 == ($width_dataword - 1))
    			{
    			    push(@parity_04_wire, "(((((data_wire[${encode_connection}] ^ data_wire[${encode_connection_plus1}]) ^ data_wire[${encode_connection_plus2}]) ^ data_wire[${encode_connection_plus3}]) ^ data_wire[${encode_connection_plus4}]) ^ parity_04_wire[${kminus}])");
    			}
    			elsif ($encode_connection_plus5 == ($width_dataword - 1))
    			{
    			    push(@parity_04_wire, "((((((data_wire[${encode_connection}] ^ data_wire[${encode_connection_plus1}]) ^ data_wire[${encode_connection_plus2}]) ^ data_wire[${encode_connection_plus3}]) ^ data_wire[${encode_connection_plus4}]) ^ data_wire[${encode_connection_plus5}]) ^ parity_04_wire[${kminus}])");
    			}
    			elsif ($encode_connection_plus6 == ($width_dataword - 1))
    			{
    			    push(@parity_04_wire, "(((((((data_wire[${encode_connection}] ^ data_wire[${encode_connection_plus1}]) ^ data_wire[${encode_connection_plus2}]) ^ data_wire[${encode_connection_plus3}]) ^ data_wire[${encode_connection_plus4}]) ^ data_wire[${encode_connection_plus5}]) ^ data_wire[${encode_connection_plus6}]) ^ parity_04_wire[${kminus}])");
    			}
    			elsif ($encode_connection_plus7 == ($width_dataword - 1))
    			{
    			    push(@parity_04_wire, "((((((((data_wire[${encode_connection}] ^ data_wire[${encode_connection_plus1}]) ^ data_wire[${encode_connection_plus2}]) ^ data_wire[${encode_connection_plus3}]) ^ data_wire[${encode_connection_plus4}]) ^ data_wire[${encode_connection_plus5}]) ^ data_wire[${encode_connection_plus6}]) ^ data_wire[${encode_connection_plus7}]) ^ parity_04_wire[${kminus}])");
    			}
    			else
    			{
    				push(@parity_04_wire, "((((((((data_wire[${encode_connection}] ^ data_wire[${encode_connection_plus1}]) ^ data_wire[${encode_connection_plus2}]) ^ data_wire[${encode_connection_plus3}]) ^ data_wire[${encode_connection_plus4}]) ^ data_wire[${encode_connection_plus5}]) ^ data_wire[${encode_connection_plus6}]) ^ data_wire[${encode_connection_plus7}]) ^ parity_04_wire[${kminus}])");
    			}
    
    			$k ++;
    		}
    	}
    	$kminus = $k - 1;
    	push(@q_wire, "parity_04_wire[${kminus}]");
    }
    

    if ($width_dataword >= 12)
    {

    
    	if ($width_codeword > 48)
    	{
    		$parity_05_size = 2;
    	}
    	else
    	{
    		$parity_05_size = 1;
    	}
    
    	
    
    	if ($width_dataword == 12)
    	{
    		@parity_05_wire = "data_wire[11]";
    	}
    
    	if ($width_dataword == 13)
    	{
    		@parity_05_wire = "(data_wire[11] ^ data_wire[12])";
    	}
    
    	if ($width_dataword == 14)
    	{
    		@parity_05_wire = "((data_wire[11] ^ data_wire[12]) ^ data_wire[13])";
    	}
    
    	if ($width_dataword == 15)
    	{
    		@parity_05_wire = "(((data_wire[11] ^ data_wire[12]) ^ data_wire[13]) ^ data_wire[14])";
    	}
    
    	if ($width_dataword == 16)
    	{
    		@parity_05_wire = "((((data_wire[11] ^ data_wire[12]) ^ data_wire[13]) ^ data_wire[14]) ^ data_wire[15])";
    	}
    
    	if ($width_dataword == 17)
    	{
    		@parity_05_wire = "(((((data_wire[11] ^ data_wire[12]) ^ data_wire[13]) ^ data_wire[14]) ^ data_wire[15]) ^ data_wire[16])";
    	}
    
    	if ($width_dataword == 18)
    	{
    		@parity_05_wire = "((((((data_wire[11] ^ data_wire[12]) ^ data_wire[13]) ^ data_wire[14]) ^ data_wire[15]) ^ data_wire[16]) ^ data_wire[17])";
    	}
    
    	if ($width_dataword == 19)
    	{
    		@parity_05_wire = "(((((((data_wire[11] ^ data_wire[12]) ^ data_wire[13]) ^ data_wire[14]) ^ data_wire[15]) ^ data_wire[16]) ^ data_wire[17]) ^ data_wire[18])";
    	}
    
    	if ($width_dataword == 20)
    	{
    		@parity_05_wire = "((((((((data_wire[11] ^ data_wire[12]) ^ data_wire[13]) ^ data_wire[14]) ^ data_wire[15]) ^ data_wire[16]) ^ data_wire[17]) ^ data_wire[18]) ^ data_wire[19])";
    	}
    
    	if ($width_dataword == 21)
    	{
    		@parity_05_wire = "(((((((((data_wire[11] ^ data_wire[12]) ^ data_wire[13]) ^ data_wire[14]) ^ data_wire[15]) ^ data_wire[16]) ^ data_wire[17]) ^ data_wire[18]) ^ data_wire[19]) ^ data_wire[20])";
    	}
    
    	if ($width_dataword == 22)
    	{
    		@parity_05_wire = "((((((((((data_wire[11] ^ data_wire[12]) ^ data_wire[13]) ^ data_wire[14]) ^ data_wire[15]) ^ data_wire[16]) ^ data_wire[17]) ^ data_wire[18]) ^ data_wire[19]) ^ data_wire[20]) ^ data_wire[21])";
    	}
    
    	if ($width_dataword == 23)
    	{
    		@parity_05_wire = "(((((((((((data_wire[11] ^ data_wire[12]) ^ data_wire[13]) ^ data_wire[14]) ^ data_wire[15]) ^ data_wire[16]) ^ data_wire[17]) ^ data_wire[18]) ^ data_wire[19]) ^ data_wire[20]) ^ data_wire[21]) ^ data_wire[22])";
    	}
    
    	if ($width_dataword == 24)
    	{
    		@parity_05_wire = "((((((((((((data_wire[11] ^ data_wire[12]) ^ data_wire[13]) ^ data_wire[14]) ^ data_wire[15]) ^ data_wire[16]) ^ data_wire[17]) ^ data_wire[18]) ^ data_wire[19]) ^ data_wire[20]) ^ data_wire[21]) ^ data_wire[22]) ^ data_wire[23])";
    	}
    
    	if ($width_dataword == 25)
    	{
    		@parity_05_wire = "(((((((((((((data_wire[11] ^ data_wire[12]) ^ data_wire[13]) ^ data_wire[14]) ^ data_wire[15]) ^ data_wire[16]) ^ data_wire[17]) ^ data_wire[18]) ^ data_wire[19]) ^ data_wire[20]) ^ data_wire[21]) ^ data_wire[22]) ^ data_wire[23]) ^ data_wire[24])";
    	}
    
    	if ($width_dataword >= 26)
    	{
    		@parity_05_wire = "((((((((((((((data_wire[11] ^ data_wire[12]) ^ data_wire[13]) ^ data_wire[14]) ^ data_wire[15]) ^ data_wire[16]) ^ data_wire[17]) ^ data_wire[18]) ^ data_wire[19]) ^ data_wire[20]) ^ data_wire[21]) ^ data_wire[22]) ^ data_wire[23]) ^ data_wire[24]) ^ data_wire[25])";
    	}
    
    	$k = 1;
    
    	for ($j = 47; (($j < $width_codeword) && (@encode_connection2[$j] < $width_dataword)); $j = $j + 32)
    	{
    		$kminus = $k - 1;
    		$encode_connection = @encode_connection2[$j];
    		$encode_connection_plus1 = $encode_connection + 1;
    		$encode_connection_plus2 = $encode_connection + 2;
    		$encode_connection_plus3 = $encode_connection + 3;
    		$encode_connection_plus4 = $encode_connection + 4;
    		$encode_connection_plus5 = $encode_connection + 5;
    		$encode_connection_plus6 = $encode_connection + 6;
    		$encode_connection_plus7 = $encode_connection + 7;
    		$encode_connection_plus8 = $encode_connection + 8;
    		$encode_connection_plus9 = $encode_connection + 9;
    		$encode_connection_plus10 = $encode_connection + 10;
    		$encode_connection_plus11 = $encode_connection + 11;
    		$encode_connection_plus12 = $encode_connection + 12;
    		$encode_connection_plus13 = $encode_connection + 13;
    		$encode_connection_plus14 = $encode_connection + 14;
    		$encode_connection_plus15 = $encode_connection + 15;
    		if ($encode_connection == ($width_dataword - 1))
    		{
    			push(@parity_05_wire, "(data_wire[${encode_connection}] ^ parity_05_wire[${kminus}])");
    		}
    		elsif ($encode_connection_plus1 == ($width_dataword - 1))
    		{
    			push(@parity_05_wire, "((data_wire[${encode_connection}] ^ data_wire[${encode_connection_plus1}]) ^ parity_05_wire[${kminus}])");
    		}
    		elsif ($encode_connection_plus2 == ($width_dataword - 1))
    		{
    			push(@parity_05_wire, "(((data_wire[${encode_connection}] ^ data_wire[${encode_connection_plus1}]) ^ data_wire[${encode_connection_plus2}]) ^ parity_05_wire[${kminus}])");
    		}
    		elsif ($encode_connection_plus3 == ($width_dataword - 1))
    		{
    			push(@parity_05_wire, "((((data_wire[${encode_connection}] ^ data_wire[${encode_connection_plus1}]) ^ data_wire[${encode_connection_plus2}]) ^ data_wire[${encode_connection_plus3}]) ^ parity_05_wire[${kminus}])");
    		}
    		elsif ($encode_connection_plus4 == ($width_dataword - 1))
    		{
    			push(@parity_05_wire, "(((((data_wire[${encode_connection}] ^ data_wire[${encode_connection_plus1}]) ^ data_wire[${encode_connection_plus2}]) ^ data_wire[${encode_connection_plus3}]) ^ data_wire[${encode_connection_plus4}]) ^ parity_05_wire[${kminus}])");
    		}
    		elsif ($encode_connection_plus5 == ($width_dataword - 1))
    		{
    			push(@parity_05_wire, "((((((data_wire[${encode_connection}] ^ data_wire[${encode_connection_plus1}]) ^ data_wire[${encode_connection_plus2}]) ^ data_wire[${encode_connection_plus3}]) ^ data_wire[${encode_connection_plus4}]) ^ data_wire[${encode_connection_plus5}]) ^ parity_05_wire[${kminus}])");
    		}
    		elsif ($encode_connection_plus6 == ($width_dataword - 1))
    		{
    			push(@parity_05_wire, "(((((((data_wire[${encode_connection}] ^ data_wire[${encode_connection_plus1}]) ^ data_wire[${encode_connection_plus2}]) ^ data_wire[${encode_connection_plus3}]) ^ data_wire[${encode_connection_plus4}]) ^ data_wire[${encode_connection_plus5}]) ^ data_wire[${encode_connection_plus6}]) ^ parity_05_wire[${kminus}])");
    		}
    		elsif ($encode_connection_plus7 == ($width_dataword - 1))
    		{
    			push(@parity_05_wire, "((((((((data_wire[${encode_connection}] ^ data_wire[${encode_connection_plus1}]) ^ data_wire[${encode_connection_plus2}]) ^ data_wire[${encode_connection_plus3}]) ^ data_wire[${encode_connection_plus4}]) ^ data_wire[${encode_connection_plus5}]) ^ data_wire[${encode_connection_plus6}]) ^ data_wire[${encode_connection_plus7}]) ^ parity_05_wire[${kminus}])");
    		}
    		elsif ($encode_connection_plus8 == ($width_dataword - 1))
    		{
    			push(@parity_05_wire, "(((((((((data_wire[${encode_connection}] ^ data_wire[${encode_connection_plus1}]) ^ data_wire[${encode_connection_plus2}]) ^ data_wire[${encode_connection_plus3}]) ^ data_wire[${encode_connection_plus4}]) ^ data_wire[${encode_connection_plus5}]) ^ data_wire[${encode_connection_plus6}]) ^ data_wire[${encode_connection_plus7}]) ^ data_wire[${encode_connection_plus8}]) ^ parity_05_wire[${kminus}])");
    		}
    		elsif ($encode_connection_plus9 == ($width_dataword - 1))
    		{
    			push(@parity_05_wire, "((((((((((data_wire[${encode_connection}] ^ data_wire[${encode_connection_plus1}]) ^ data_wire[${encode_connection_plus2}]) ^ data_wire[${encode_connection_plus3}]) ^ data_wire[${encode_connection_plus4}]) ^ data_wire[${encode_connection_plus5}]) ^ data_wire[${encode_connection_plus6}]) ^ data_wire[${encode_connection_plus7}]) ^ data_wire[${encode_connection_plus8}]) ^ data_wire[${encode_connection_plus9}]) ^ parity_05_wire[${kminus}])");
    		}
    		elsif ($encode_connection_plus10 == ($width_dataword - 1))
    		{
    			push(@parity_05_wire, "(((((((((((data_wire[${encode_connection}] ^ data_wire[${encode_connection_plus1}]) ^ data_wire[${encode_connection_plus2}]) ^ data_wire[${encode_connection_plus3}]) ^ data_wire[${encode_connection_plus4}]) ^ data_wire[${encode_connection_plus5}]) ^ data_wire[${encode_connection_plus6}]) ^ data_wire[${encode_connection_plus7}]) ^ data_wire[${encode_connection_plus8}]) ^ data_wire[${encode_connection_plus9}]) ^ data_wire[${encode_connection_plus10}]) ^ parity_05_wire[${kminus}])");
    		}
    		elsif ($encode_connection_plus11 == ($width_dataword - 1))
    		{
    			push(@parity_05_wire, "((((((((((((data_wire[${encode_connection}] ^ data_wire[${encode_connection_plus1}]) ^ data_wire[${encode_connection_plus2}]) ^ data_wire[${encode_connection_plus3}]) ^ data_wire[${encode_connection_plus4}]) ^ data_wire[${encode_connection_plus5}]) ^ data_wire[${encode_connection_plus6}]) ^ data_wire[${encode_connection_plus7}]) ^ data_wire[${encode_connection_plus8}]) ^ data_wire[${encode_connection_plus9}]) ^ data_wire[${encode_connection_plus10}]) ^ data_wire[${encode_connection_plus11}]) ^ parity_05_wire[${kminus}])");
    		}
    		elsif ($encode_connection_plus12 == ($width_dataword - 1))
    		{
    			push(@parity_05_wire, "(((((((((((((data_wire[${encode_connection}] ^ data_wire[${encode_connection_plus1}]) ^ data_wire[${encode_connection_plus2}]) ^ data_wire[${encode_connection_plus3}]) ^ data_wire[${encode_connection_plus4}]) ^ data_wire[${encode_connection_plus5}]) ^ data_wire[${encode_connection_plus6}]) ^ data_wire[${encode_connection_plus7}]) ^ data_wire[${encode_connection_plus8}]) ^ data_wire[${encode_connection_plus9}]) ^ data_wire[${encode_connection_plus10}]) ^ data_wire[${encode_connection_plus11}]) ^ data_wire[${encode_connection_plus12}]) ^ parity_05_wire[${kminus}])");
    		}
    		elsif ($encode_connection_plus13 == ($width_dataword - 1))
    		{
    			push(@parity_05_wire, "((((((((((((((data_wire[${encode_connection}] ^ data_wire[${encode_connection_plus1}]) ^ data_wire[${encode_connection_plus2}]) ^ data_wire[${encode_connection_plus3}]) ^ data_wire[${encode_connection_plus4}]) ^ data_wire[${encode_connection_plus5}]) ^ data_wire[${encode_connection_plus6}]) ^ data_wire[${encode_connection_plus7}]) ^ data_wire[${encode_connection_plus8}]) ^ data_wire[${encode_connection_plus9}]) ^ data_wire[${encode_connection_plus10}]) ^ data_wire[${encode_connection_plus11}]) ^ data_wire[${encode_connection_plus12}]) ^ data_wire[${encode_connection_plus13}]) ^ parity_05_wire[${kminus}])");
    		}
    		elsif ($encode_connection_plus14 == ($width_dataword - 1))
    		{
    			push(@parity_05_wire, "(((((((((((((((data_wire[${encode_connection}] ^ data_wire[${encode_connection_plus1}]) ^ data_wire[${encode_connection_plus2}]) ^ data_wire[${encode_connection_plus3}]) ^ data_wire[${encode_connection_plus4}]) ^ data_wire[${encode_connection_plus5}]) ^ data_wire[${encode_connection_plus6}]) ^ data_wire[${encode_connection_plus7}]) ^ data_wire[${encode_connection_plus8}]) ^ data_wire[${encode_connection_plus9}]) ^ data_wire[${encode_connection_plus10}]) ^ data_wire[${encode_connection_plus11}]) ^ data_wire[${encode_connection_plus12}]) ^ data_wire[${encode_connection_plus13}]) ^ data_wire[${encode_connection_plus14}]) ^ parity_05_wire[${kminus}])");
    		}
    		elsif ($encode_connection_plus15 == ($width_dataword - 1))
    		{
    			push(@parity_05_wire, "((((((((((((((((data_wire[${encode_connection}] ^ data_wire[${encode_connection_plus1}]) ^ data_wire[${encode_connection_plus2}]) ^ data_wire[${encode_connection_plus3}]) ^ data_wire[${encode_connection_plus4}]) ^ data_wire[${encode_connection_plus5}]) ^ data_wire[${encode_connection_plus6}]) ^ data_wire[${encode_connection_plus7}]) ^ data_wire[${encode_connection_plus8}]) ^ data_wire[${encode_connection_plus9}]) ^ data_wire[${encode_connection_plus10}]) ^ data_wire[${encode_connection_plus11}]) ^ data_wire[${encode_connection_plus12}]) ^ data_wire[${encode_connection_plus13}]) ^ data_wire[${encode_connection_plus14}]) ^ data_wire[${encode_connection_plus15}]) ^ parity_05_wire[${kminus}])");
    		}
    		else
    		{
    			push(@parity_05_wire, "((((((((((((((((data_wire[${encode_connection}] ^ data_wire[${encode_connection_plus1}]) ^ data_wire[${encode_connection_plus2}]) ^ data_wire[${encode_connection_plus3}]) ^ data_wire[${encode_connection_plus4}]) ^ data_wire[${encode_connection_plus5}]) ^ data_wire[${encode_connection_plus6}]) ^ data_wire[${encode_connection_plus7}]) ^ data_wire[${encode_connection_plus8}]) ^ data_wire[${encode_connection_plus9}]) ^ data_wire[${encode_connection_plus10}]) ^ data_wire[${encode_connection_plus11}]) ^ data_wire[${encode_connection_plus12}]) ^ data_wire[${encode_connection_plus13}]) ^ data_wire[${encode_connection_plus14}]) ^ data_wire[${encode_connection_plus15}]) ^ parity_05_wire[${kminus}])");
    		}
    
    		$k++;
    	}
    	$kminus = $k - 1;
    	push(@q_wire, "parity_05_wire[${kminus}]");
    }
    

    if ($width_dataword >= 27)
    {
    	if ($width_dataword > 57) {
    		$parity_06_size = 31;
    	} else {
    		$parity_06_size = $width_dataword - 26;
    	}
    
    	@parity_06_wire = "data_wire[26]";
    	if ($width_dataword > 27)
    	{
    		$k = 1;
    		for ($j = 27; ($j - 26) < $parity_06_size; $j = $j + 1)
    		{
    		    $kminus = $k - 1;
    			push(@parity_06_wire, "(data_wire[${j}] ^ parity_06_wire[${kminus}])");
    			$k ++;
    		}
    	}
    	$kminus = $k - 1;
    	push(@q_wire, "parity_06_wire[${kminus}]");
    }
    

    if ($width_dataword >= 58)
    {
    	
    	@parity_07_wire = "data_wire[57]";
    
    	$k = 1;
    
    	if ($width_dataword > 58)
    	{
    		for ($j = 58; $j < $width_dataword; $j = $j + 1)
    		{
    		    $kminus = $k - 1;
    			push(@parity_07_wire, "(data_wire[${j}] ^ parity_07_wire[${kminus}])");
    			$k ++;
    		}
    	}
    	$kminus = $k - 1;
    	push(@q_wire, "parity_07_wire[${kminus}]");
    }
    

    {
    	
    	@parity_final_wire = "q_wire[0]";
    	{
    		$k = 1;
    		for ($j = 1; $j < ($width_codeword - 1); $j = $j + 1)
    		{
    		    $kminus = $k - 1;
    			push(@parity_final_wire, "(q_wire[${j}] ^ parity_final_wire[${kminus}])");
    			$k ++;
    		}
    	}
    	$kminus = $k - 1;
    	push(@q_wire, "parity_final_wire[${kminus}]");
    }
    
    my @parity_final_wire_reverse = reverse @parity_final_wire;
    my @parity_07_wire_reverse = reverse @parity_07_wire;
    my @parity_06_wire_reverse = reverse @parity_06_wire;
    my @parity_05_wire_reverse = reverse @parity_05_wire;
    my @parity_04_wire_reverse = reverse @parity_04_wire;
    my @parity_03_wire_reverse = reverse @parity_03_wire;
    my @parity_02_wire_reverse = reverse @parity_02_wire;
    my @parity_01_wire_reverse = reverse @parity_01_wire;
    my @q_wire_reverse = reverse @q_wire;

    

    push(@things,
        e_signal->new({
            name => "data_wire",
            width => $width_dataword,
            never_export => 1,
        }),
        e_assign->adds(
            [["data_wire", $width_dataword],  "data"],
        ),
    );


    if ( scalar(@parity_01_wire_reverse) != 0) {
        push(@things,
            e_signal->new({
                name => "parity_01_wire",
                width => $parity_01_size,
                never_export => 1,
            }),
            e_assign->adds(
                [["parity_01_wire", $parity_01_size],  "{" . join(",", @parity_01_wire_reverse) . "}"],
            ),
        );
    }

    if ( scalar(@parity_02_wire_reverse) != 0) {
        push(@things,
            e_signal->new({
                name => "parity_02_wire",
                width => $parity_02_size,
                never_export => 1,
            }),
            e_assign->adds(
                [["parity_02_wire", $parity_02_size],  "{" . join(",", @parity_02_wire_reverse) . "}"],
            ),
        );
    }

    if ( scalar(@parity_03_wire_reverse) != 0) {
        push(@things,
            e_signal->new({
                name => "parity_03_wire",
                width => $parity_03_size,
                never_export => 1,
            }),
            e_assign->adds(
                [["parity_03_wire", $parity_03_size],  "{" . join(",", @parity_03_wire_reverse) . "}"],
            ),
        );
    }
    
    if ( scalar(@parity_04_wire_reverse) != 0) {
        push(@things,
            e_signal->new({
                name => "parity_04_wire",
                width => $parity_04_size,
                never_export => 1,
            }),
            e_assign->adds(
                [["parity_04_wire", $parity_04_size],  "{" . join(",", @parity_04_wire_reverse) . "}"],
            ),
        );
    }
    
    if ( scalar(@parity_05_wire_reverse) != 0) {
        push(@things,
            e_signal->new({
                name => "parity_05_wire",
                width => $parity_05_size,
                never_export => 1,
            }),
            e_assign->adds(
                [["parity_05_wire", $parity_05_size],  "{" . join(",", @parity_05_wire_reverse) . "}"],
            ),
        );
    }
    
    if ( scalar(@parity_06_wire_reverse) != 0) {
        push(@things,
            e_signal->new({
                name => "parity_06_wire",
                width => $parity_06_size,
                never_export => 1,
            }),
            e_assign->adds(
                [["parity_06_wire", $parity_06_size],  "{" . join(",", @parity_06_wire_reverse) . "}"],
            ),
        );
    }
    
    if ( scalar(@parity_07_wire_reverse) != 0) {
        push(@things,
            e_signal->new({
                name => "parity_07_wire",
                width => $parity_07_size,
                never_export => 1,
            }),
            e_assign->adds(
                [["parity_07_wire", $parity_07_size],  "{" . join(",", @parity_07_wire_reverse) . "}"],
            ),
        );
    }
    
    if ( scalar(@parity_final_wire_reverse) != 0) {
        push(@things,
            e_signal->new({
                name => "parity_final_wire",
                width => $parity_final_wire_size,
                never_export => 1,
            }),
            e_assign->adds(
                [["parity_final_wire", $parity_final_wire_size],  "{" . join(",", @parity_final_wire_reverse) . "}"],
            ),
        );
    }


    push(@things,
        e_signal->new({
            name => "q_wire",
            width => $width_codeword,
            never_export => 1,
        }),
        e_assign->adds(
            [["q_wire", $width_codeword],  "{" . join(",", @q_wire_reverse) . "}"],
        ),

        e_assign->adds(
           [["q", $width_codeword],  "q_wire"],
        ),
    );
    return @things;
        
}

__PACKAGE__->DONE();

1;
