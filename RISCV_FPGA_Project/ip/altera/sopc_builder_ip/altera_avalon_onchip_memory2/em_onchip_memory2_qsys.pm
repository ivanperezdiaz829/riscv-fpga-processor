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






















package em_onchip_memory2_qsys;
use Exporter;
@ISA = Exporter;
use e_parameter;
@EXPORT = qw(
    &make_mem
);


use strict;
use europa_all;
use wiz_utils;
use format_conversion_utils;





my $device_family_mapped = qq("");

my $ram_block_type;
my $init_contents_file;
my $non_default_init_file_enabled;
my $gui_ram_block_type;
my $device_family;
my $Writeable;
my $dual_port;
my $single_clock_operation;
my $Size_Value;
my $Size_Multiple;
my $use_shallow_mem_blocks;
my $init_mem_content;
my $allow_in_system_memory_content_editor;
my $instance_id;
my $read_during_write_mode;
my $sim_meminit_only_filename;
my $ignore_auto_block_type_assignment;
my $Data_Width; 
my $Address_Width;
my $slave1Latency;
my $slave2Latency;
my $derived_is_hardcopy;               
my $ecc_enabled;

my $Address_Span;
my $num_lanes;
my $make_individual_byte_lanes;
my $num_words;
my $ecc_actual_data_width;
my $name;
my $maximum_depth;
my $make_individual_byte_lanes;





sub validate_options
{
  my ($Opt) = @_;






  validate_parameter({hash    => $Opt,
                       name    => "Writeable",
                       type    => "boolean",
                       default => 1,
                      });


  if (!$Opt->{ecc_enabled}) {
    if (!is_computer_acceptable_bit_width($Opt->{Data_Width}))
    {
      ribbit(
        "ERROR:  Parameter validation failed.\n" .
        "  Parameter 'Data_Width' (= $Opt->{Data_Width})\n" .
        "  is not an allowed value.\n"
      );
    }
  }



  validate_parameter({hash    => $Opt,
                       name    => "Size_Multiple",
                       type    => "integer",
                       allowed => [1,1024],
                       default => 1,
                      });
  
  validate_parameter({hash    => $Opt,
                       name    => "Size_Value",
                       type    => "integer",
                      });

  $Opt->{Address_Span} = $Opt->{Size_Multiple} * 
                             $Opt->{Size_Value};



      




  validate_parameter({hash    => $Opt,
                       name    => "ram_block_type",
                       type     => "string",
                       allowed => ["M512", 
                                   "M4K", 
                                   "M-RAM",              
                                   "M9K",
                                   "M144K",
                                   "M20K",
                                   "M10K",
                                   "MLAB",
                                   "AUTO"],
                       default  => "AUTO",
                      });
  




  if ($Opt -> {ignore_auto_block_type_assignment} == 1)
  {
    if ($Opt->{gui_ram_block_type} =~ "Automatic")
    {
      $Opt->{ram_block_type} = "AUTO";
    }
  }
  

  if (($Opt->{init_mem_content}) != 0 && ($Opt->{init_mem_content} != 1))
  {
  	  if ($Opt->{Writeable} && $Opt->{derived_is_hardcopy})
      {
          $Opt->{init_mem_content} = 0;
      }
      else
      {
        if ($Opt->{ram_block_type} =~ /M-RAM/)
        {
          $Opt->{init_mem_content} = 0;
        }                                                            
        else
        {
          $Opt->{init_mem_content} = 1;
        }
      }
  }

  

  if ( $Opt->{ecc_enabled} ) {
      $Opt->{num_lanes}     = 0;


      my $ecc_bits = 1;
      while ((2**$ecc_bits - 1) < $Opt->{Data_Width}) {
        $ecc_bits++;
      }

      $ecc_bits++;
      my $actual_data = $Opt->{Data_Width} - $ecc_bits;
      my $byte_width = int($actual_data/ 8);
      $Opt->{ecc_actual_data_width} = $actual_data;
      $Opt->{num_words} = ceil ($Opt->{Address_Span} / $byte_width);

  } else {
      $Opt->{num_lanes}     = $Opt->{Data_Width} / 8;
      



      my $byte_width = int($Opt->{Data_Width} / 8);
      $Opt->{num_words} = ceil ($Opt->{Address_Span} / $byte_width);
  }
  $Opt->{make_individual_byte_lanes} = $Opt->{ram_block_type} eq 'M512' && $Opt->{num_lanes} > 1;





  validate_parameter({hash    => $Opt,
                       name    => "Address_Width",
                       type    => "integer",
                       range   => [ceil(log2($Opt->{num_words})), 32],
                       });




      
  validate_parameter({hash     => $Opt,
                       name     => "slave1Latency",
                       type     => "integer",             
                       range    => [1, 2],                                   
                       default  => 0,
                       });
  
  if ($Opt->{dual_port})
  {
  validate_parameter({hash     => $Opt,
                       name     => "slave2Latency",
                       type     => "integer",
                       range    => [1, 2],
                       default  => 0,                
                       });
  }










                       







  






  $Opt->{init_contents_file} = $Opt->{name} if ($Opt->{init_contents_file} eq '');
  



  if ($Opt->{init_mem_content} == 0)
  {
    $Opt->{init_contents_file} = $Opt->{name};
  }                                
  



  $ram_block_type			= $Opt->{ram_block_type};
  $init_contents_file			= $Opt->{init_contents_file};
  $non_default_init_file_enabled	= $Opt->{non_default_init_file_enabled};
  $gui_ram_block_type			= $Opt->{gui_ram_block_type};
  $device_family			= $Opt->{device_family};
  $Writeable				= $Opt->{Writeable};
  $dual_port				= $Opt->{dual_port};
  $single_clock_operation		= $Opt->{single_clock_operation};
  $Size_Value				= $Opt->{Size_Value};
  $Size_Multiple			= $Opt->{Size_Multiple};
  $use_shallow_mem_blocks		= $Opt->{use_shallow_mem_blocks};
  $init_mem_content			= $Opt->{init_mem_content};
  $allow_in_system_memory_content_editor= $Opt->{allow_in_system_memory_content_editor};
  $instance_id				= $Opt->{instance_id};
  $read_during_write_mode		= $Opt->{read_during_write_mode};
  $sim_meminit_only_filename		= $Opt->{sim_meminit_only_filename};
  $ignore_auto_block_type_assignment	= $Opt->{ignore_auto_block_type_assignment};
  $Data_Width				= $Opt->{Data_Width}; 
  $Address_Width			= $Opt->{Address_Width};
  $slave1Latency			= $Opt->{slave1Latency};
  $slave2Latency			= $Opt->{slave2Latency};
  $derived_is_hardcopy			= $Opt->{derived_is_hardcopy};
  $ecc_enabled		       	        = $Opt->{ecc_enabled};

  $Address_Span				= $Opt->{Address_Span};
  $num_lanes				= $Opt->{num_lanes};
  $make_individual_byte_lanes		= $Opt->{make_individual_byte_lanes};
  $num_words				= $Opt->{num_words};
  $name					    = $Opt->{name};
  $ecc_actual_data_width    = $Opt->{ecc_actual_data_width};

}  
  



sub report_usage
{
  my $Opt = shift;
  
  print STDERR "  $name memory usage summary:\n";
  my %trimatrix_bits = (
    M512  => 512,
    M4K   => 4096,
    'M-RAM' => 512*1024,
  );
  my $bits_consumed = $num_words * $Data_Width;
  my $block_granularity = $trimatrix_bits{$ram_block_type};
  if ($make_individual_byte_lanes)
  {
    $block_granularity *= $num_lanes;
  }

  print STDERR "$num_words words, $Data_Width bits wide ($bits_consumed bits) ";
  print STDERR "(@{[ceil($bits_consumed / $trimatrix_bits{$ram_block_type})]} $ram_block_type blocks.\n";
}


          








sub make_mem
{
  my ($module, $Opt, $project) = (@_);



  $Opt->{name} = $module->name();

  validate_options($Opt);
  







                                                                        






  
  my $hex_data_width = $Data_Width;
  my $hex_address_span = $Address_Span;
  if ($Opt->{ecc_enabled}) {

      my $i = 0;
      $hex_data_width = 0;
      for ($i = 0 ; ($hex_data_width <= $Data_Width) ; $i = $i + 1) {
          $hex_data_width = $i * 8;
      }
      
      my $ecc_num_bytes = $ecc_actual_data_width / 8;
      my $depth_in_byte = $Address_Span / $ecc_num_bytes;
      $hex_address_span = $depth_in_byte * $hex_data_width / 8;
      
  }


  if (!$non_default_init_file_enabled) { 
      my %target_hash;
      if ($make_individual_byte_lanes) {
          for my $lane (0 .. -1 + $num_lanes) {
              my $stub = $init_contents_file . "_lane$lane";         
              $target_hash{full_path} = $Opt->{project_info}{system_directory} . $stub . ".hex"; 
              $project->make_placeholder_contents_files(           
                  {                    
                    name => $stub,
                    Base_Address => 0,
                    Address_Span => $hex_address_span,                   
                    Data_Width   => $hex_data_width,
                    set_rand_contents => 0,                                                
                    make_individual_byte_lanes => $make_individual_byte_lanes,                       
                    num_lanes => $num_lanes,
                    hdl_contents_file => { target => 'hex', targets => [\%target_hash]}
                  },
              );
          }                                                 
      }
      

      $target_hash{full_path} = $Opt->{project_info}{system_directory} . $init_contents_file . ".hex";
      $project->make_placeholder_contents_files(           
          {                    
            name => $init_contents_file,
            Base_Address => 0,
            Address_Span => $hex_address_span,                   
            Data_Width   => $hex_data_width,                                  
            set_rand_contents => 0,                                                
            make_individual_byte_lanes => $make_individual_byte_lanes,                       
            num_lanes => $num_lanes,
            hdl_contents_file => { target => 'hex', targets => [\%target_hash]} 
          },
      );
  } 
  

  $device_family_mapped = do_device_family_name_mapping($device_family);





  
  instantiate_memory($module, $Opt);



  e_port->new({within    => $module,
               name      => "address",
               width     => $Address_Width,
               direction => "in",
              });

  e_port->new({within    => $module,
               name      => "reset",
               width     => 1,
               direction => "in",
              });
  
  e_port->new({within    => $module,
               name      => "reset_req",
               width     => 1,
               direction => "in",
              });



  e_avalon_slave->new({within => $module,
                       name   => "s1",
                       sideband_signals => [ "clken" ],
                       type_map => {
                         debugaccess => 'debugaccess',
                         reset => 'reset',
                         },
                       });

  my %slave_2_type_map = reverse
  (                                            
     clk        => "clk2",
     clken      => "clken2",
     address    => "address2",
     readdata   => "readdata2",
     chipselect => "chipselect2",
     write      => "write2",
     writedata  => "writedata2",
     byteenable => "byteenable2",
     debugaccess=> 'debugaccess',
     reset      => 'reset2',
  );

  e_avalon_slave->new({within => $module,
                       name   => "s2",
                       sideband_signals => [ "clken" ],
                       type_map => \%slave_2_type_map,
                    });
} 

sub instantiate_memory     
{
  my ($module, $Opt) = @_;

  my $marker = e_default_module_marker->new($module);





  e_port->adds(
    ['clk',        1,              'in'],
    ['address',    $Address_Width, 'in'],
    ['readdata',   $Data_Width,    'out'],
  );

  e_port->new({within    => $module,
              name      => "reset",
              width     => 1,
              direction => "in",
            });

  e_port->adds({name => "clken", width => 1, direction => "in",
    default_value => "1'b1"});
  e_signal->adds(
        ['clocken0', 1],
      );


  my $in_port_map = {
    clock0      => 'clk',
    clocken0    => 'clocken0',
    address_a   => 'address',
    wren_a      => 'wren',
    data_a      => 'writedata',
  };

  my $out_port_map = 
    ($slave1Latency == 1) ? 
      { q_a => 'readdata' } :
      { q_a => 'readdata_ram' };
                                             



  if ($slave1Latency > 1) {
    e_register->add(
      {out => ["readdata", $Data_Width],            
       in => "readdata_ram",  
       enable => "clken",
	   reset => '',
       delay => ($slave1Latency - 1),
      }
    );
  }


  e_port->adds(
    ['chipselect', 1,              'in'],
    ['write',      1,              'in'],
    ['writedata',  $Data_Width,    'in'],
  );

  if ($Writeable)
  {
    if ($single_clock_operation)
    {
      e_assign->add(['wren', and_array('chipselect', 'write', 'clken')]);
    }
    else                                                                    
    {
      e_assign->add(['wren', and_array('chipselect', 'write')]);
    }
  }
  else                                         
  {


    e_port->adds(
      ['debugaccess', 1, 'in'],                            
    );
    if ($derived_is_hardcopy)
    {



      e_assign->add(['wren', 0]);
    }
    else
    {
      e_assign->add(['wren', and_array('chipselect', 'write', 'debugaccess')]);
    }
  }
  $maximum_depth = $num_words;
  

  if($ram_block_type eq qq(M4K) && $use_shallow_mem_blocks eq "1")
  {
    	$maximum_depth = &calculate_maximum_depth($Opt);
  }
  my $parameter_map = {
    operation_mode            => qq("SINGLE_PORT"),
    width_a                   => $Data_Width,
    widthad_a                 => $Address_Width,
    numwords_a                => $num_words,
    lpm_type                  => qq("altsyncram"),
    byte_size                 => 8,
    outdata_reg_a             => qq("UNREGISTERED"),
    read_during_write_mode_mixed_ports => qq("$read_during_write_mode"),
    ram_block_type            => qq("$ram_block_type"),
    maximum_depth             => $maximum_depth
  };






  if ($allow_in_system_memory_content_editor)
  {
  	my $lpm_hint = "ENABLE_RUNTIME_MOD=YES, INSTANCE_NAME=$instance_id";
  	$parameter_map->{lpm_hint} = qq("$lpm_hint");
  }
  

  if ($num_lanes > 1)
  {

    e_port->adds(["byteenable", $num_lanes,     "in" ],);
    if ($ram_block_type eq 'M512')
    {


    }
    else
    {
      $in_port_map->{byteena_a} = 'byteenable';
      $parameter_map->{width_byteena_a} = $num_lanes;
    }
  }

  if ($dual_port)
  {

    e_port->adds(
      ['address2',    $Address_Width, 'in'],
      ['readdata2',   $Data_Width,    'out'],
    );

    if (!($single_clock_operation))
    {
      e_port->adds(
        ['clk2',        1,                     "in"],
        );

      e_port->new({within    => $module,
                name      => "reset2",
                width     => 1,
                direction => "in",
              });
      e_port->new({within    => $module,
                name      => "reset_req2",
                width     => 1,
                direction => "in",
              });
      e_signal->adds(
        ['clocken1', 1],
       );
      e_assign->add(['clocken0', 'clken & ~reset_req']);
      e_assign->add(['clocken1', 'clken2 & ~reset_req2']);


    $in_port_map->{clock1}      = 'clk2';
    $in_port_map->{clocken1}    = 'clocken1';




    } else { # single clock operation in dual port mode
    e_assign->add(['not_clken', '~clken']);	    
    e_assign->add(['not_clken2', '~clken2']);
    e_assign->add(['clocken0', '~reset_req']);
    
    $in_port_map->{addressstall_a} = "not_clken";
    $in_port_map->{addressstall_b} = "not_clken2";
    $in_port_map->{clocken0}    = "clocken0";
    }
 
    e_port->adds({name => "clken2", width => 1, direction => "in",
      default_value => "1'b1"});

    $in_port_map->{address_b}   = 'address2';
    $in_port_map->{wren_b}      = 'wren2';
    $in_port_map->{data_b}      = 'writedata2';

    $out_port_map->{q_b} = 
      ($slave2Latency == 1) ? 'readdata2' : 'readdata2_ram';


    if ($slave2Latency > 1) {
	if ($single_clock_operation)
	{
	e_register->add(
        {out => ["readdata2", $Data_Width],            
         in => "readdata2_ram",  
		 clock => "clk",
		 reset => '',
         enable => "clken2",
         delay => ($slave2Latency - 1),     
        }
      );  

} else {





	  e_register->add(
        {out => ["readdata2", $Data_Width],            
         in => "readdata2_ram",  
		 clock => "clk2",
		 reset => '',
         enable => "clken2",
         delay => ($slave2Latency - 1),
        }
      );
}
    }


    e_signal->adds(
      ['wren2', 1],
      ['write2', 1],
      ['chipselect2', 1],
      ['writedata2',  $Data_Width],
    );

    if ($num_lanes > 1)
    {
      e_signal->adds(
        ['byteenable', $Data_Width / 8],
        ['byteenable2', $Data_Width / 8],
      );
      $in_port_map->{byteena_b} = 'byteenable2';
      $parameter_map->{width_byteena_b} = $num_lanes;
    }

    if ($Writeable)
    {
      if ($single_clock_operation)
      {
        e_assign->add(['wren2', and_array('chipselect2', 'write2', 'clken2')]);
      }
      else
      {
        e_assign->add(['wren2', and_array('chipselect2', 'write2')]);
      }
    }
    else
    {
      if ($derived_is_hardcopy)
      {



        e_assign->add(['wren2', 0]);
      }
      else
      {
        e_assign->add(['wren2', and_array('chipselect2', 'write2', 'debugaccess')]);
      }
    }

if (!($single_clock_operation))
{


    $parameter_map->{operation_mode} = qq("BIDIR_DUAL_PORT");
    $parameter_map->{width_b} = $Data_Width;
    $parameter_map->{widthad_b} = $Address_Width;
    $parameter_map->{numwords_b} = $num_words;
    $parameter_map->{outdata_reg_b} = qq("UNREGISTERED");
    $parameter_map->{byteena_reg_b} = qq("CLOCK1");
    $parameter_map->{indata_reg_b} = qq("CLOCK1");
    $parameter_map->{address_reg_b} = qq("CLOCK1");
    $parameter_map->{wrcontrol_wraddress_reg_b} = qq("CLOCK1");
    if ((($ram_block_type =~ /M9K/) or ($ram_block_type =~ /M144K/)) && (!($read_during_write_mode =~ /DONT_CARE/)))
    {
    $parameter_map->{read_during_write_mode_port_a} = qq("$read_during_write_mode");
    $parameter_map->{read_during_write_mode_port_b} = qq("$read_during_write_mode");
    }
} else {

    $parameter_map->{operation_mode} = qq("BIDIR_DUAL_PORT");
    $parameter_map->{width_b} = $Data_Width;
    $parameter_map->{widthad_b} = $Address_Width;
    $parameter_map->{numwords_b} = $num_words;
    $parameter_map->{outdata_reg_b} = qq("UNREGISTERED");
    $parameter_map->{byteena_reg_b} = qq("CLOCK0");
    $parameter_map->{indata_reg_b} = qq("CLOCK0");
    $parameter_map->{address_reg_b} = qq("CLOCK0");
    $parameter_map->{wrcontrol_wraddress_reg_b} = qq("CLOCK0");

    if ((($ram_block_type =~ /M9K/) or ($ram_block_type =~ /M144K/)) && (!($read_during_write_mode =~ /DONT_CARE/))) 
    {   
    $parameter_map->{read_during_write_mode_port_a} = qq("$read_during_write_mode");
    $parameter_map->{read_during_write_mode_port_b} = qq("$read_during_write_mode");
    }



}
  }
  else
  {

    e_assign->add(['clocken0', 'clken & ~reset_req']);
  }



  

















  my $sim_parameter_map = {%$parameter_map};


  my $hdl_file_info = $Opt->{target_info}->{hex};
  my $sim_file_info = $Opt->{target_info}->{dat};
  
  if ($make_individual_byte_lanes)
  {

    



    $parameter_map->{width_a} = 8;
    $sim_parameter_map->{width_a} = 8;
    
    for my $lane (0 .. $num_lanes - 1)
    {
      e_assign->add(["write_lane$lane", and_array('wren', "byteenable\[$lane\]")]);
      $in_port_map->{wren_a} = "write_lane$lane";
      $in_port_map->{data_a} = sprintf("writedata[%d : %d]", ($lane + 1) * 8 - 1, $lane * 8);
      

      $out_port_map->{q_a} = ($slave1Latency == 1) ? 
      sprintf("readdata[%d : %d]", ($lane + 1) * 8 - 1, $lane * 8) :
      sprintf("readdata_ram[%d : %d]", ($lane + 1) * 8 - 1, $lane * 8);

      set_init_file_parameters(
        $Opt,
        $parameter_map,
        $sim_parameter_map,
        $hdl_file_info,
        $sim_file_info,
        $lane,

      );


      e_blind_instance->add({

        name   => "the_altsyncram_$lane",
        module => 'altsyncram',
        in_port_map => $in_port_map,
        out_port_map => $out_port_map,
        parameter_map => $parameter_map,
      });











    }      
  }
  else
  {                
    set_init_file_parameters(
      $Opt,
      $parameter_map,
      $sim_parameter_map,
      $hdl_file_info,
      $sim_file_info,

    );

    if ($ram_block_type =~ /M-RAM/ )
    {



      $sim_parameter_map->{ram_block_type} = qq("M4K");
    }


    e_blind_instance->add({

      name   => 'the_altsyncram',
      module => 'altsyncram',
      in_port_map => $in_port_map,
      out_port_map => $out_port_map,
      parameter_map => $parameter_map,
    });











  }
  return $module;
}

sub set_init_file_parameters
{ 
  my (
    $Opt,
    $parameter_map,
    $sim_parameter_map,
    $hdl_file_info,
    $sim_file_info,
    $lane,
    $project,
  ) = @_;  
  

  if (1)
  {           
    my $rec = shift @{$hdl_file_info->{targets}};

    
    my $stub = $init_contents_file;
   


    $stub =~ s|\\|/|g;


    my $hex = "$stub";

    if (!$non_default_init_file_enabled) {
        $hex = "$stub.hex";
    }
    


    if($make_individual_byte_lanes)
    {



      $hex = $stub."_lane".$lane.".hex";
    }
    

    my $file;
    $file = qq($hex);
    


    if (($stub =~ m|/|) || ($sim_meminit_only_filename) ) 
    {
      $file = qq($hex);
    }
    













        e_parameter->adds(
          {
            name => "INIT_FILE",
            default => $file,
            vhdl_type => "STRING",   
          },                              
        );
        
        $sim_parameter_map->{init_file} = 'INIT_FILE';   
        $parameter_map->{init_file} = 'INIT_FILE';

  }                                                         


  if ($init_mem_content == 0 )
  {
    $parameter_map->{init_file} = qq("UNUSED");
    $sim_parameter_map->{init_file} = qq("UNUSED");
  } 
}  






sub calculate_maximum_depth
{
	(my $Opt) = @_;


	if(&is_power_of_two($num_words))
	{
		return $num_words;
	}
	else
	{
		my $next_power_of_2 = &next_higher_power_of_two($num_words);


		
		my $gcd = &gcd_euclid($num_words, $next_power_of_2);

		return &max($gcd, int(4096/$Data_Width));
		
	}

}

sub gcd_euclid
{
	my $p = shift;
	my $q = shift;
	my $mod_val = 0;
	while ($p > 0)
        {
          $mod_val = $q % $p;
          $q = $p;
          $p = $mod_val;
        }
        return $q;
}




sub do_device_family_name_mapping
  {
  	my $device_name = @_[0];
  	
		my %translate_device_name = (
			"CYCLONE" => "Cyclone",
			"CYCLONEII" => "Cyclone II",
			"CYCLONEIII" => "Cyclone III",
			"TARPON" => "Cyclone III LPS",
			"STINGRAY" => "Cyclone IV GX",
			"CYCLONEIVE" => "Cyclone IV E",
			"STRATIX" => "Stratix",
			"STRATIXGX" => "Stratix GX",
			"STRATIXII" => "Stratix II",
			"STRATIXIII" => "Stratix III",
			"STRATIXIIGX" => "Stratix II GX",
			"STRATIXIV" => "Stratix IV",
			"STRATIXV" => "Stratix V",
			"ARRIAGX" => "Arria GX",
			"ARRIAII" => "Arria II",
			"ARRIAIIGZ" => "Arria II GZ",
			"HARDCOPYII" => "HardCopy II",
			"HARDCOPYIII" => "HardCopy III",
			"HARDCOPYIV" => "HardCopy IV",
		);
		
		my $tr_device_name = $translate_device_name{$device_name};
		
		if($tr_device_name ne ""){
			return $tr_device_name;
		}else{
			return $device_name;
		}
  } 

1;  
