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

nios_dpram - description of the module goes here ...

=head1 SYNOPSIS

The nios_dpram class implements ... detailed description of functionality

=head1 METHODS

=over 4

=cut

package nios_dpram;

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
  

  read_latency => 1,
  implement_as_esb => 1,
  

  Opt => undef,


  read_during_write_mode_mixed_ports => qq("DONT_CARE"),


  contents_file     => '',


  allow_mram_sim_contents_only_file => '',
  

  ram_block_type => qq("AUTO"),
  maximum_depth => 0,
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
    
  ribbit("Data width not specified") if $self->data_width() == 0;
  ribbit("Address width not specified") if $self->address_width() == 0;
  $self->num_words(2**$self->address_width()) if $self->num_words() == 0;
  
  $self->_create_module();
  $self->_lpm_file_name($self->name()."_lpm_file");

  $self->parameter_map({lpm_file => $self->_lpm_file_name()}); 
  $self->declare_parameters_as_variables(["lpm_file"]);

  return $self;
}



=item I<_byteenable_width()>

method description goes here...
...remember: there must be a newline around each POD tag (e.g. =item, =cut etc)!

=cut

sub _byteenable_width
{
  my $this = shift;
  
  return ceil($this->data_width() / 8.0);
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




















  




  for my $required_port (qw(rdclock rdaddress q))
  {
    if (!defined $this->port_map()->{$required_port})
    {
      ribbit("required port '$required_port' not specified in port map");
    }
  }
  

  my @allowed_ports = qw(
    rden
    rdclock
    rdclken
    rdaddress
    rdaddressstall
    q
    wren
    wrclock
    wrclken
    wraddress
    wraddressstall
    data
    byteenable
  );

  for my $port_name (keys %{$this->port_map()})
  {
    ribbit ("Illegal port '$port_name'") if !grep {/$port_name/} @allowed_ports;
    
    my $port = e_port->new({
      name => $port_name,
    });
    
    $module->add_contents($port);
    
    $port_name eq 'q' and do {
      $port->width($this->data_width()); $port->direction('out'); next;
    };
   
    $port_name eq 'data' and do {
      $port->width($this->data_width()); next;
    };

    $port_name =~ 'address$' and do {
      $port->width($this->address_width()); next;
    };
    
    $port_name eq 'byteenable' and do {
      $port->width($this->_byteenable_width()); next;
    };

    $port_name =~ 'clock$' and do {
      next;
    };

    $port_name eq 'rdclken' and do {
      next;
    };

    $port_name eq 'wrclken' and do {
      next;
    };

    $port_name eq 'rden' and do {
      next;
    };

    $port_name eq 'wren' and do {
      next;
    };
    
    $port_name =~ 'rdaddressstall' and do {
      next;
    };

    $port_name =~ 'wraddressstall' and do {
      next;
    };

    ribbit("Failed to handle port '$port_name'");
  }



  my @roms_dont_have_these_ports = qw(
    wren
    wrclock
    wraddress
    data
    byteenable
  );


  if (!defined $this->port_map()->{rdclken})
  {
    $module->add_contents(
      e_signal->new({
        name => 'rdclken',
        width => 1,
        never_export => 1,
      }),
      e_assign->new(['rdclken', "1'b1"]),
    );
  }


  if (!defined $this->port_map()->{wrclken})
  {
    $module->add_contents(
      e_signal->new({
        name => 'wrclken',
        width => 1,
        never_export => 1,
      }),
      e_assign->new(['wrclken', "1'b1"]),
    );
  }



  if (!defined $this->port_map()->{wren})
  {
    $module->add_contents(
      e_signal->new({
        name => 'wren',
        width => 1,
        never_export => 1,
      }),
      e_assign->new(['wren', "1'b0"]),
    );
  }

  if (!defined $this->port_map()->{wrclock})
  {
    $module->add_contents(
      e_signal->new({
        name => 'wrclock',
        width => 1,
        never_export => 1,
      }),
      e_assign->new(['wrclock', "1'b0"]),
    );
  }

  if (!defined $this->port_map()->{wraddress})
  {
    my $width = $this->address_width();
    $module->add_contents(
      e_signal->new({
        name => 'wraddress',
        width => $width,
        never_export => 1,
      }),
      e_assign->new(['wraddress', $width . "'b0"]),
    );
  }

  if (!defined $this->port_map()->{data})
  {
    my $width = $this->data_width();
    $module->add_contents(
      e_signal->new({
        name => 'data',
        width => $width,
        never_export => 1,
      }),
      e_assign->new(['data', $width . "'b0"]),
    );
  }

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

  $this->add_objects();

  my $ret = $this->SUPER::update(@_);
  
  return $ret;
}



=item I<add_compilation_objects()>

method description goes here...
...remember: there must be a newline around each POD tag (e.g. =item, =cut etc)!

=cut

sub add_compilation_objects
{
  my $this = shift;
  $this->add_objects("compilation");
}




=item I<add_simulation_objects()>

method description goes here...
...remember: there must be a newline around each POD tag (e.g. =item, =cut etc)!

=cut

sub add_simulation_objects
{
  my $this   = shift;
  my $module = $this->module();

  ribbit("bad usage") if (!$module or !$this or @_);

  $module->add_contents(
      e_signal->new({
        tag => 'simulation',
        name => "mem_array",
        width => $this->data_width(),
        depth => $this->num_words(),
        never_export => 1,
    })
  );

  if ($this->contents_file())
  {
    my $dat_name = $this->contents_file() . '.dat';
    
    my $readmem =  e_readmem->new({
      file         => $dat_name,
      mem_variable => "mem_array",
      hex_output   => 1,
    });

    my @things;
    push @things,
      e_initial_block->new({


        clock => '',
        clock_level => 'none',
        

        contents => [$readmem],
      });
  
    map {$_->tag("simulation")} @things;

    $module->add_contents(@things);
  }

  my $language = $this->Opt()->{language};
  if ($language =~ /vhdl/i)
  {
    $this->add_vhdl_simulation_objects();
  }
  elsif ($language =~ /verilog/i)
  {
    $this->add_verilog_simulation_objects();
  }
  else
  {
    ribbit("unknown language '$language'\n");
  }
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
    my $absolut_path = 
      $this->Opt()->{system_directory} . "/" . $contents_file;

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




=item I<big_string()>

method description goes here...
...remember: there must be a newline around each POD tag (e.g. =item, =cut etc)!

=cut

sub big_string
{
  my $this = shift;



  my $mem_type = "mem_array";
  my $mem_variable = "mem_array";

  my $mem_sig = "mem_array";
  $mem_variable = "Marc_Gaucherons_Memory_Variable";

  my $depth = $this->num_words();

  my $width = $this->data_width();
  my $mem_width_bytes = $width / 8;
  my $mem_width_nibbles = $width / 4;
  my $file = "";

  $file = $this->contents_file() . ".dat" if $this->contents_file();

  my $read_dependent_variable = "rdaddress";
  my $write_dependent_variable = "wrclock";
  my $read_address = "rdaddress";
  my $write_address = "wraddress";
  my $read_variable;
  my $write_variable;
  my $read_addr_process;

  my $address_width = $this->address_width();
  my $address_msb   = $address_width - 1;
  $read_dependent_variable = "rdclock";
  $read_address = "rd_address_internal";

  if($address_width > 1)
  {
    $read_variable = 
      'VARIABLE '.$read_address.' : STD_LOGIC_VECTOR ('.$address_msb.' DOWNTO 0) := (others => \'0\');';
  }
  else
  {
    $read_variable = 
      'VARIABLE '.$read_address.' : STD_LOGIC;';
  }

  $read_addr_process = qq[
  IF rdclock'event AND rdclock = '1' AND rdclken = '1' THEN
    $read_address := rdaddress;
  END IF;
];
   if (1)
   {
     $write_dependent_variable = "wrclock";
     $write_address = "wr_address_internal";
     
     if($address_width > 1){
       $write_variable = 
         'VARIABLE '.$write_address.' : STD_LOGIC_VECTOR ('.$address_msb.' DOWNTO 0) := (others => \'0\');';
     }else{
       $write_variable = 
         'VARIABLE '.$write_address.' : STD_LOGIC;';
     }
   }

   my $width_dependent_write_part; 

   if($address_width > 1){
    $width_dependent_write_part = $mem_variable.'(CONV_INTEGER(UNSIGNED('.$write_address.')))'; 
   }else{
    $width_dependent_write_part = $mem_variable.'(CONV_INTEGER('.$write_address.'))';
   }

   my $read_process;
   my $write_process;
   $write_process = 
       'if wrclock\'event and wrclock = \'1\' then
        '.$write_address.' := wraddress;
        if wren = \'1\' then 
          '.$width_dependent_write_part.' := data;
        end if;
      end if;';
   
   if($address_width > 1){           
     $read_process = 'q <= '.$mem_variable.'(CONV_INTEGER(UNSIGNED('.$read_address.')));';
   }else{
     $read_process = 'q <= '.$mem_variable.'(CONV_INTEGER('.$read_address.'));';
   }

   my $memory_initialization_routines;

   if($file eq ""){
      $memory_initialization_routines = "";

   }else{
      $memory_initialization_routines = qq[
FUNCTION convert_string_to_number(string_to_convert : STRING;
      final_char_index : NATURAL := 0)
RETURN NATURAL IS
   VARIABLE result: NATURAL := 0;
   VARIABLE current_index : NATURAL := 1;
   VARIABLE the_char : CHARACTER;

   BEGIN
      IF final_char_index = 0 THEN
         result := 0;
   ELSE
         WHILE current_index <= final_char_index LOOP
            the_char := string_to_convert(current_index);
            IF    '0' <= the_char AND the_char <= '9' THEN
               result := result * 16 + character'pos(the_char) - character'pos('0');
            ELSIF 'A' <= the_char AND the_char <= 'F' THEN
               result := result * 16 + character'pos(the_char) - character'pos('A') + 10;
            ELSIF 'a' <= the_char AND the_char <= 'f' THEN
               result := result * 16 + character'pos(the_char) - character'pos('a') + 10;
            ELSE
               report "Ack, a formatting error!";
            END IF;
            current_index := current_index + 1;
         END LOOP;
      END IF; 
   RETURN result;
END convert_string_to_number;


 FUNCTION convert_string_to_std_logic(value : STRING; num_chars : INTEGER; mem_width_chars : INTEGER)
 RETURN STD_LOGIC_VECTOR is        
     VARIABLE num_bits: integer := mem_width_chars * 4;
     VARIABLE result: std_logic_vector(num_bits-1 downto 0);
     VARIABLE curr_char : integer;
     VARIABLE min_width : integer := mem_width_chars;
     VARIABLE num_nibbles : integer := 0;
              
     BEGIN
     result := (others => '0');
     num_nibbles := mem_width_chars;
     IF (mem_width_chars > num_chars) THEN
    num_nibbles := num_chars;
     END IF;

          FOR I IN 1 TO num_nibbles LOOP
       curr_char := num_nibbles - (I-1);

             CASE value(I) IS
               WHEN '0' =>  result((4*curr_char)-1  DOWNTO 4*(curr_char-1)) := "0000";
               WHEN '1' =>  result((4*curr_char)-1  DOWNTO 4*(curr_char-1)) := "0001";
               WHEN '2' =>  result((4*curr_char)-1  DOWNTO 4*(curr_char-1)) := "0010";
               WHEN '3' =>  result((4*curr_char)-1  DOWNTO 4*(curr_char-1)) := "0011";
               WHEN '4' =>  result((4*curr_char)-1  DOWNTO 4*(curr_char-1)) := "0100";
               WHEN '5' =>  result((4*curr_char)-1  DOWNTO 4*(curr_char-1)) := "0101";
               WHEN '6' =>  result((4*curr_char)-1  DOWNTO 4*(curr_char-1)) := "0110";
               WHEN '7' =>  result((4*curr_char)-1  DOWNTO 4*(curr_char-1)) := "0111";
               WHEN '8' =>  result((4*curr_char)-1  DOWNTO 4*(curr_char-1)) := "1000";
               WHEN '9' =>  result((4*curr_char)-1  DOWNTO 4*(curr_char-1)) := "1001";
               WHEN 'A' | 'a' => result((4*curr_char)-1  DOWNTO 4*(curr_char-1)) := "1010";
               WHEN 'B' | 'b' => result((4*curr_char)-1  DOWNTO 4*(curr_char-1)) := "1011";
               WHEN 'C' | 'c' => result((4*curr_char)-1  DOWNTO 4*(curr_char-1)) := "1100";
               WHEN 'D' | 'd' => result((4*curr_char)-1  DOWNTO 4*(curr_char-1)) := "1101";
               WHEN 'E' | 'e' => result((4*curr_char)-1  DOWNTO 4*(curr_char-1)) := "1110";
               WHEN 'F' | 'f' => result((4*curr_char)-1  DOWNTO 4*(curr_char-1)) := "1111";
               WHEN ' ' => EXIT;
               WHEN HT  => exit;
               WHEN others =>
                  ASSERT False
                  REPORT "function From_Hex: string """ & value & """ contains non-hex character"
                       severity Error;
                  EXIT;
               END case;
            END loop;
          RETURN result;
        END convert_string_to_std_logic;
];} #End memory initialization routines...


my $memory_process;
my $depth_top = $this->num_words() - 1;
my $width_top = $this->data_width() - 1;
my $type_spec = 
  "TYPE $mem_sig is ARRAY( $depth_top DOWNTO 0) of STD_LOGIC_VECTOR($width_top DOWNTO 0)";



if($file eq ""){





    $memory_process = qq[
    $type_spec;
    

begin
   process ($write_dependent_variable, $read_dependent_variable) -- MG
    $read_variable
    $write_variable
    variable $mem_variable : $mem_type; -- MG
    
    begin
      -- Write data
      $write_process

      -- read data
      $read_process
      $read_addr_process


    end process;
];
}else{
    $memory_process = qq[
      $memory_initialization_routines
$type_spec;
begin
   process ($write_dependent_variable, $read_dependent_variable) -- MG
    VARIABLE data_line : LINE;
    VARIABLE the_character_from_data_line : CHARACTER;
    VARIABLE b_munging_address : BOOLEAN := FALSE;
    VARIABLE converted_number : NATURAL := 0;
    VARIABLE found_string_array : STRING(1 TO 128);
    VARIABLE string_index : NATURAL := 0;
    VARIABLE line_length : NATURAL := 0;
    VARIABLE b_convert : BOOLEAN := FALSE;
    VARIABLE b_found_new_val : BOOLEAN := FALSE;
    VARIABLE load_address : NATURAL := 0;
    VARIABLE mem_index : NATURAL := 0;
    VARIABLE mem_init : BOOLEAN := FALSE;
    $read_variable
    $write_variable
    FILE memory_contents_file : TEXT OPEN read_mode IS "$file";  
    variable $mem_variable : $mem_type; -- MG
    
    begin
   -- need an initialization process
   -- this process initializes the whole memory array from a named file by copying the
   -- contents of the *.dat file to the memory array.

   -- find the \@<address> thingy to load the memory from this point 
IF(NOT mem_init) THEN
   WHILE NOT(endfile(memory_contents_file)) LOOP

      readline(memory_contents_file, data_line);
      line_length := data_line'LENGTH;


      WHILE line_length > 0 LOOP
         read(data_line, the_character_from_data_line);

         -- check for the \@ character indicating a new address wad
         -- if not found, we're either still reading the new address _or_loading data
         IF '\@' = the_character_from_data_line AND NOT b_munging_address THEN
        b_munging_address := TRUE;
            b_found_new_val := TRUE; 
      -- get the rest of characters before white space and then convert them
      -- to a number
   ELSE 

            IF (' ' = the_character_from_data_line AND b_found_new_val) 
    OR (line_length = 1) THEN
               b_convert := TRUE;
      END IF;

            IF NOT(' ' = the_character_from_data_line) THEN
               string_index := string_index + 1;
               found_string_array(string_index) := the_character_from_data_line;
--               IF NOT(b_munging_address) THEN
--                 dat_string_array(string_index) := the_character_from_data_line;
--               END IF;
         b_found_new_val := TRUE;
            END IF;
   END IF;

     IF b_convert THEN

       IF b_munging_address THEN
          converted_number := convert_string_to_number(found_string_array, string_index);    
          load_address := converted_number;
          mem_index := load_address / $mem_width_bytes;
          b_munging_address := FALSE;
       ELSE
    IF (mem_index < $depth) THEN
      $mem_variable(mem_index) := convert_string_to_std_logic(found_string_array, string_index, $mem_width_nibbles);
            mem_index := mem_index + 1;
          END IF;
       END IF; 
       b_convert := FALSE;
       b_found_new_val := FALSE;
       string_index := 0;
    END IF;
    line_length := line_length - 1; 
    END LOOP;

END LOOP;
-- get the first _real_ block of data, sized to our memory width
-- and keep on loading.
  mem_init := TRUE;
END IF;
-- END OF READMEM



      -- Write data
      $write_process

      -- read data
      $read_process
      $read_addr_process


    end process;
];
};

return ($memory_process);
}











=item I<add_verilog_simulation_objects()>

method description goes here...
...remember: there must be a newline around each POD tag (e.g. =item, =cut etc)!

=cut

sub add_verilog_simulation_objects
{
  my $this   = shift;
  my $module = $this->module();

  ribbit("bad usage") if (!$module or !$this or @_);
  my @things = ();


  my @read_contents;
  
  push @read_contents, 

    e_register->new({
      in => 'rdaddress',
      out => e_signal->new({
        name => 'd1_rdaddress',
        width => $this->address_width(),
        never_export => 1,
      }),
      enable => 'rdclken',
      clock => "rdclock",
      async_set => "1'b1",
    });
    

  my $read_latency = $this->read_latency();
  if ($read_latency == 1)
  {

    push @read_contents, 
      e_assign->new({
        lhs => "q",
        rhs => "mem_array[d1_rdaddress]",
      });
  }
  elsif ($read_latency == 2)
  {

    push @read_contents, 
      e_register->new({
        in => "mem_array[d1_rdaddress]",
        out => 'q',
        enable => 'rdclken',
        clock => "rdclock",
        async_set => "1'b1",
      });
  }
  else
  {
    ribbit("Illegal read latency '$read_latency'");
  }

  map {$_->tag("simulation")} @read_contents;
  $module->add_contents(@read_contents);


  my @write_contents = (
    e_register->new({
      in => 'wraddress',
      out => e_signal->new({
        name => 'd1_wraddress', 
        width => $this->address_width(),
        never_export => 1,
      }),
    }),    
    
    e_register->new({
      in => 'wren',
      out => e_signal->new({
        name => 'd1_wren', 
        width => 1,
        never_export => 1,
      }),
    }),    

    e_register->new({
      in => 'data',
      out => e_signal->new({
        name => 'd1_data', 
        width => $this->data_width(),
        never_export => 1,
      }),
    }),    
  );

  map {
    $_->tag('simulation'),
    $_->clock('wrclock'),
    $_->enable("1'b1"),
    $_->async_set ("1'b1"),
  } @write_contents;
  
  push @things, @write_contents;
  
  push @things, 
    e_process->new({
      clock => "wrclock",
      clock_level => 0,
      contents => [
        e_if->new({
          comment => " Write data",
          tag => 'simulation',
          condition => "d1_wren",
          then => [
            e_assign->new({
              lhs => "mem_array[d1_wraddress]",
              rhs => "d1_data",
            }),
          ],
        }),
      ],
    });


  map {$_->tag("simulation")} @things;

  $module->add_contents(@things);
}



=item I<add_vhdl_simulation_objects()>

method description goes here...
...remember: there must be a newline around each POD tag (e.g. =item, =cut etc)!

=cut

sub add_vhdl_simulation_objects
{



  my $this   = shift;
  my $module = $this->module();

  $module->add_contents(
    e_register->new({
      tag => 'simulation',
      clock => 'rdclock',
      enable => 1,
      in => 'wren',
      out => e_signal->new({
        name => 'd1_wren', 
        width => 1,
        never_export => 1,
      }),
    }),
  );

  return;
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





=item I<add_objects()>

method description goes here...
...remember: there must be a newline around each POD tag (e.g. =item, =cut etc)!

=cut

sub add_objects
{
  my ($this, $type) = (@_);
  
  my $module = $this->module();

  ribbit("bad usage") if (!$module or !$this);

  my @things;
  





  my $contents_file = "UNUSED";
  my $tag_type;
  my $language = $this->Opt()->{language};





  my %init_file;





  $this->_memory_instance_name("the_altsyncram");


  push (@things,
	  e_signal->new({
			 name => "ram_q",
			 width => $this->data_width(),
			 never_export => 1,
			}),
	  e_parameter->new(["lpm_file","UNUSED","STRING"]));

  if($this->contents_file()){
    $contents_file = $this->contents_file();
  }
  

  if ($this->Opt()->{is_hardcopy_compatible})
  {
    $contents_file = qq("UNUSED");
  }
  
  if ($contents_file !~/UNUSED/) {
    %init_file = ("init_file" => qq(lpm_file));
  }
    

  push @things, e_assign->new(['q', 'ram_q']);

  if (!defined $this->port_map()->{byteenable})
  {







    my %additional_parameters = %init_file;

    push @things, 
      $this->create_altsyncram_special_instance(
        \%additional_parameters
      );
  }
  else
  {
    if ($this->ram_block_type() !~ /M512/)
    {


      my %additional_parameters = %init_file;

      $additional_parameters{width_byteena_a} = $this->_byteenable_width();

      my %additional_in_ports = ( byteena_a => 'byteenable');

      push @things, 
        $this->create_altsyncram_special_instance(
          \%additional_parameters,
          \%additional_in_ports
        );
    }
    else
    {




      my $num_byte_lanes = $this->_byteenable_width();
      my $lane_width     = $this->data_width() / $num_byte_lanes;


      for (my $lane = 0; $lane < $num_byte_lanes; $lane++) {
        my $lane_lsb = $lane_width * $lane;               # 0,  8, 16, 24
        my $lane_msb = $lane_lsb + $lane_width - 1;       # 7, 15, 23, 31

        my $in_port_map = {
          clock0    => 'wrclock',
          clocken0  => "wrclken",
          data_a    => "data[$lane_msb:$lane_lsb]",
          wren_a    => "wren$lane",
          address_a => 'wraddress',
          clock1    => 'rdclock',
          clocken1  => 'rdclken',
          address_b => 'rdaddress',
        };

        if (defined($this->port_map()->{wraddressstall})) {
          $in_port_map->{addressstall_a} = 'wraddressstall';
        }

        if (defined($this->port_map()->{rdaddressstall})) {
          $in_port_map->{addressstall_b} = 'rdaddressstall';
        }
        
        if (defined($this->port_map()->{rden})) {
          $in_port_map->{rden_b} = 'rden';
        }


        push @things, (
          e_assign->new([["wren$lane", 1], "wren & byteenable[$lane]",]),
          e_blind_instance->new({
            use_sim_models => 1,
            name => "altsyncram$lane",
            module => 'altsyncram',
            in_port_map => $in_port_map,
            out_port_map => {
              q_b       => "ram_q[$lane_msb:$lane_lsb]",
            },
            parameter_map => {

              width_a               => $lane_width,
              widthad_a             => $this->address_width(),
              numwords_a            => $this->num_words(),


              width_b               => $lane_width,
              widthad_b             => $this->address_width(),
              numwords_b            => $this->num_words(),
              outdata_reg_b         =>
                $this->read_latency == 1 ? qq("UNREGISTERED") : qq("CLOCK1"),
              address_reg_b         => qq("CLOCK1"),


              ram_block_type        => $this->ram_block_type(),
              maximum_depth         => $this->maximum_depth(),



              operation_mode        => qq("DUAL_PORT"),
              },
            }),
          );
      }
    }
  }
  
  map {$_->tag($type)} @things if $type;

  $module->add_contents(@things);
}

sub
create_altsyncram_special_instance
{
    my $this = shift;
    my $additional_parameters_href = shift || {};
    my $additional_in_ports_href = shift || {};
    my $additional_out_ports_href = shift || {};
    my @ret = ();

    my %sim_parameters = %$additional_parameters_href;
    my %comp_parameters = %$additional_parameters_href;

    if ($this->ram_block_type() eq qq("M-RAM") && 
      $this->allow_mram_sim_contents_only_file() &&
      $this->contents_file()) {
        print "Changing simulation model of memory from M-RAM to M4K to allow contents initialization\n";
        $sim_parameters{ram_block_type} = qq("M4K");
        delete $comp_parameters{init_file};
    }

    my $sim_instance = $this->create_altsyncram_base_instance(
        \%sim_parameters,
        $additional_in_ports_href,
        $additional_out_ports_href
      );
    $sim_instance->tag('simulation');

    my $comp_instance = $this->create_altsyncram_base_instance(
        \%comp_parameters,
        $additional_in_ports_href,
        $additional_out_ports_href
      );
    $comp_instance->tag('compilation');

    return ($sim_instance, $comp_instance);
}


sub
create_altsyncram_base_instance
{
    my $this = shift;
    my $additional_parameters_href = shift || {};
    my $additional_in_ports_href = shift || {};
    my $additional_out_ports_href = shift || {};

    my $in_port_map = {
        clock0    => 'wrclock',
        clocken0  => "wrclken",
        data_a    => 'data',
        wren_a    => 'wren',
        address_a => 'wraddress',
        clock1    => 'rdclock',
        clocken1  => 'rdclken',
        address_b => 'rdaddress',
        };

    if (defined($this->port_map()->{wraddressstall})) {
      $in_port_map->{addressstall_a} = 'wraddressstall';
    }

    if (defined($this->port_map()->{rdaddressstall})) {
      $in_port_map->{addressstall_b} = 'rdaddressstall';
    }

    if (defined($this->port_map()->{rden})) {
      $in_port_map->{rden_b} = 'rden';
    }

    my $out_port_map = {
        q_b       => 'ram_q',
        };

    my $parameter_map = {

        width_a               => $this->data_width(),
        widthad_a             => $this->address_width(),
        numwords_a            => $this->num_words(),


        width_b               => $this->data_width(),
        widthad_b             => $this->address_width(),
        numwords_b            => $this->num_words(),
        outdata_reg_b         =>
          $this->read_latency == 1 ? qq("UNREGISTERED") : qq("CLOCK1"),
        address_reg_b         => qq("CLOCK1"),


        ram_block_type        => $this->ram_block_type(),
        maximum_depth         => $this->maximum_depth(),

        read_during_write_mode_mixed_ports => $this->read_during_write_mode_mixed_ports(),



        operation_mode        => qq("DUAL_PORT"),
        };


    foreach my $key (keys(%$additional_in_ports_href)) {
        $in_port_map->{$key} = $additional_in_ports_href->{$key};
    }


    foreach my $key (keys(%$additional_out_ports_href)) {
        $out_port_map->{$key} = $additional_out_ports_href->{$key};
    }


    foreach my $key (keys(%$additional_parameters_href)) {
        $parameter_map->{$key} = $additional_parameters_href->{$key};
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
