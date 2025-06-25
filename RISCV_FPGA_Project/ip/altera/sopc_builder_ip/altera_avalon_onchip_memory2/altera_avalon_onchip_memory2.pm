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






















package altera_avalon_onchip_memory2;
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

sub validate_options
{
  my ($Opt, $project, $SBI) = @_;


  $Opt->{name} = $project->_target_module_name();



  validate_parameter({hash    => $Opt,
                       name    => "Writeable",
                       type    => "boolean",
                       default => 1,
                      });

  if (!is_computer_acceptable_bit_width($SBI->{Data_Width}))
  {
    ribbit(
      "ERROR:  Parameter validation failed.\n" .
      "  Parameter 'Data_Width' (= $SBI->{Data_Width})\n" .
      "  is not an allowed value.\n"
    );
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


  $project->WSA()->{Address_Span} = $Opt->{Address_Span};
  


  $project->WSA()->{Size} = $Opt->{Address_Span};

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
      if ($Opt->{Writeable} && $project->is_hardcopy_compatible)
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

  

  $Opt->{num_lanes}     = $SBI->{Data_Width} / 8;
  $Opt->{make_individual_byte_lanes} = $Opt->{ram_block_type} eq 'M512' && $Opt->{num_lanes} > 1;
  $Opt->{Address_Width} = $SBI->{Address_Width};
  $Opt->{Data_Width}    = $SBI->{Data_Width};




  my $byte_width = int($SBI->{Data_Width} / 8);
  $Opt->{num_words} = ceil ($Opt->{Address_Span} / $byte_width);




  validate_parameter({hash    => $SBI,
                       name    => "Address_Width",
                       type    => "integer",
                       range   => [ceil(log2($Opt->{num_words})), 32],
                       });

  $Opt->{base_addr_as_number} = $SBI->{Base_Address};
  $Opt->{base_addr_as_number} = oct($Opt->{base_addr_as_number})
    if ($Opt->{base_addr_as_number} =~ /^0/);
      
  validate_parameter({hash     => $SBI,
                       name     => "Read_Latency",
                       type     => "integer",
                       range    => [1, 2],
                       default  => 0,
                       });
  
  $Opt->{lang} =
    $project->system_ptf()->{WIZARD_SCRIPT_ARGUMENTS}{hdl_language};
  validate_parameter({hash    => $Opt,
                       name    => "lang",
                       type     => "string",
                       allowed => ["verilog", 
                                   "vhdl",],
                       default  => "verilog",
                      });
                       


  $Opt->{set_rand_contents} = $project->WSA()->{set_rand_contents};


  $Opt->{Base_Address} = $SBI->{Base_Address};
  $Opt->{Address_Span} = $SBI->{Address_Span};
  






  $Opt->{init_contents_file} = $Opt->{name} if ($Opt->{init_contents_file} eq '');
  



  if ($Opt->{init_mem_content} == 0)
  {
    $Opt->{init_contents_file} = $Opt->{name};
  }

}  
  



sub report_usage
{
  my $Opt = shift;
  
  print STDERR "  $Opt->{name} memory usage summary:\n";
  my %trimatrix_bits = (
    M512  => 512,
    M4K   => 4096,
    'M-RAM' => 512*1024,
  );
  my $bits_consumed = $Opt->{num_words} * $Opt->{Data_Width};
  my $block_granularity = $trimatrix_bits{$Opt->{ram_block_type}};
  if ($Opt->{make_individual_byte_lanes})
  {
    $block_granularity *= $Opt->{num_lanes};
  }

  print STDERR "$Opt->{num_words} words, $Opt->{Data_Width} bits wide ($bits_consumed bits) ";
  print STDERR "(@{[ceil($bits_consumed / $trimatrix_bits{$Opt->{ram_block_type}})]} $Opt->{ram_block_type} blocks.\n";
}








sub make_mem
{
  my ($module, $project) = (@_);
  my $Opt = &copy_of_hash ($project->WSA());
  my $SBI1 = &copy_of_hash ($project->SBI("s1"));

  $Opt->{name} = $module->name();

  validate_options($Opt, $project, $SBI1);

  if ($Opt->{dual_port})
  {
    my $SBI2 = &copy_of_hash ($project->SBI("s2"));

    validate_options($Opt, $project, $SBI2);
  }
  $project->do_makefile_target_ptf_assignments(
      's1',
      ['dat', 'hex', 'sym', ],
      $Opt,
  );
    

  $device_family_mapped = do_device_family_name_mapping($Opt->{device_family});





  
  instantiate_memory($module, $Opt, $project);



  e_port->new({within    => $module,
               name      => "address",
               width     => $Opt->{Address_Width},
               direction => "in",
              });

  e_port->new({within    => $module,
               name      => "reset",
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
  my ($module, $Opt, $project) = @_;

  my $marker = e_default_module_marker->new($module);

  my $SBI1 = $project->SBI("s1");
  my $SBI2 = $project->SBI("s2");


  e_port->adds(
    ['clk',        1,                     'in'],
    ['address',    $Opt->{Address_Width}, 'in'],
    ['readdata',   $Opt->{Data_Width},    'out'],
  );

  e_port->new({within    => $module,
              name      => "reset",
              width     => 1,
              direction => "in",
            });

  e_port->adds({name => "clken", width => 1, direction => "in",
    default_value => "1'b1"});


  my $in_port_map = {
    clock0      => 'clk',
    clocken0    => 'clken',
    address_a   => 'address',
    wren_a      => 'wren',
    data_a      => 'writedata',
  };

  my $out_port_map = 
    ($SBI1->{Read_Latency} == 1) ? 
      { q_a => 'readdata' } :
      { q_a => 'readdata_ram' };




  if ($SBI1->{Read_Latency} > 1) {
    e_register->add(
      {out => ["readdata", $Opt->{Data_Width}],            
       in => "readdata_ram",  
       enable => "clken",
	   reset => '',
       delay => ($SBI1->{Read_Latency} - 1),
      }
    );
  }


  e_port->adds(
    ['chipselect', 1,                     'in'],
    ['write',      1,                     'in'],
    ['writedata',  $Opt->{Data_Width},    'in'],
  );

  if ($Opt->{Writeable})
  {
    if ($Opt->{single_clock_operation})
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
    if ($project->is_hardcopy_compatible())
    {



      e_assign->add(['wren', 0]);
    }
    else
    {
      e_assign->add(['wren', and_array('chipselect', 'write', 'debugaccess')]);
    }
  }
  $Opt->{maximum_depth} = $Opt->{num_words};
  

  if($Opt->{ram_block_type} eq qq(M4K) && $Opt->{use_shallow_mem_blocks} eq "1")
  {
    	$Opt->{maximum_depth} = &calculate_maximum_depth($Opt);
  }
  my $parameter_map = {
    operation_mode            => qq("SINGLE_PORT"),
    width_a                   => $Opt->{Data_Width},
    widthad_a                 => $Opt->{Address_Width},
    numwords_a                => $Opt->{num_words},
    lpm_type                  => qq("altsyncram"),
    byte_size                 => 8,
    outdata_reg_a             => qq("UNREGISTERED"),
    read_during_write_mode_mixed_ports => qq("$Opt->{read_during_write_mode}"),
    ram_block_type            => qq("$Opt->{ram_block_type}"),
    maximum_depth             => $Opt->{maximum_depth}
  };






  if ($Opt->{allow_in_system_memory_content_editor})
  {
  	my $lpm_hint = "ENABLE_RUNTIME_MOD=YES, INSTANCE_NAME=$Opt->{instance_id}";
  	$parameter_map->{lpm_hint} = qq("$lpm_hint");
  }
  

  if ($Opt->{num_lanes} > 1)
  {

    e_port->adds(["byteenable", $Opt->{num_lanes},     "in" ],);
    if ($Opt->{ram_block_type} eq 'M512')
    {


    }
    else
    {
      $in_port_map->{byteena_a} = 'byteenable';
      $parameter_map->{width_byteena_a} = $Opt->{num_lanes};
    }
  }

  if ($Opt->{dual_port})
  {

    e_port->adds(
      ['address2',    $Opt->{Address_Width}, 'in'],
      ['readdata2',   $Opt->{Data_Width},    'out'],
    );

    if (!($Opt->{single_clock_operation}))
    {
      e_port->adds(
        ['clk2',        1,                     "in"],
        );

      e_port->new({within    => $module,
                name      => "reset2",
                width     => 1,
                direction => "in",
              });


    $in_port_map->{clock1}      = 'clk2';
    $in_port_map->{clocken1}    = 'clken2';




    } else { # single clock operation in dual port mode
    e_assign->add(['not_clken', '~clken']);	    
    e_assign->add(['not_clken2', '~clken2']);              
    
    $in_port_map->{addressstall_a} = "not_clken";
    $in_port_map->{addressstall_b} = "not_clken2";
    $in_port_map->{clocken0}    = "1'b1";
    }
 
    e_port->adds({name => "clken2", width => 1, direction => "in",
      default_value => "1'b1"});

    $in_port_map->{address_b}   = 'address2';
    $in_port_map->{wren_b}      = 'wren2';
    $in_port_map->{data_b}      = 'writedata2';

    $out_port_map->{q_b} = 
      ($SBI2->{Read_Latency} == 1) ? 'readdata2' : 'readdata2_ram';


    if ($SBI2->{Read_Latency} > 1) {
if ($Opt->{single_clock_operation})
{
e_register->add(
        {out => ["readdata2", $Opt->{Data_Width}],            
         in => "readdata2_ram",  
		 clock => "clk",
		 reset => '',
         enable => "clken2",
         delay => ($SBI2->{Read_Latency} - 1),
        }
      );

} else {





	  e_register->add(
        {out => ["readdata2", $Opt->{Data_Width}],            
         in => "readdata2_ram",  
		 clock => "clk2",
		 reset => '',
         enable => "clken2",
         delay => ($SBI2->{Read_Latency} - 1),
        }
      );
}
    }


    e_signal->adds(
      ['wren2', 1],
      ['write2', 1],
      ['chipselect2', 1],
      ['writedata2',  $Opt->{Data_Width}],
    );

    if ($Opt->{num_lanes} > 1)
    {
      e_signal->adds(
        ['byteenable', $Opt->{Data_Width} / 8],
        ['byteenable2', $Opt->{Data_Width} / 8],
      );
      $in_port_map->{byteena_b} = 'byteenable2';
      $parameter_map->{width_byteena_b} = $Opt->{num_lanes};
    }

    if ($Opt->{Writeable})
    {
      if ($Opt->{single_clock_operation})
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
      if ($project->is_hardcopy_compatible())
      {



        e_assign->add(['wren2', 0]);
      }
      else
      {
        e_assign->add(['wren2', and_array('chipselect2', 'write2', 'debugaccess')]);
      }
    }

if (!($Opt->{single_clock_operation}))
{


    $parameter_map->{operation_mode} = qq("BIDIR_DUAL_PORT");
    $parameter_map->{width_b} = $Opt->{Data_Width};
    $parameter_map->{widthad_b} = $Opt->{Address_Width};
    $parameter_map->{numwords_b} = $Opt->{num_words};
    $parameter_map->{outdata_reg_b} = qq("UNREGISTERED");
    $parameter_map->{byteena_reg_b} = qq("CLOCK1");
    $parameter_map->{indata_reg_b} = qq("CLOCK1");
    $parameter_map->{address_reg_b} = qq("CLOCK1");
    $parameter_map->{wrcontrol_wraddress_reg_b} = qq("CLOCK1");
    if ((($Opt->{ram_block_type} =~ /M9K/) or ($Opt->{ram_block_type} =~ /M144K/)) && (!($Opt->{read_during_write_mode} =~ /DONT_CARE/)))
    {
    $parameter_map->{read_during_write_mode_port_a} = qq("$Opt->{read_during_write_mode}");
    $parameter_map->{read_during_write_mode_port_b} = qq("$Opt->{read_during_write_mode}");
    }
} else {

    $parameter_map->{operation_mode} = qq("BIDIR_DUAL_PORT");
    $parameter_map->{width_b} = $Opt->{Data_Width};
    $parameter_map->{widthad_b} = $Opt->{Address_Width};
    $parameter_map->{numwords_b} = $Opt->{num_words};
    $parameter_map->{outdata_reg_b} = qq("UNREGISTERED");
    $parameter_map->{byteena_reg_b} = qq("CLOCK0");
    $parameter_map->{indata_reg_b} = qq("CLOCK0");
    $parameter_map->{address_reg_b} = qq("CLOCK0");
    $parameter_map->{wrcontrol_wraddress_reg_b} = qq("CLOCK0");

    if ((($Opt->{ram_block_type} =~ /M9K/) or ($Opt->{ram_block_type} =~ /M144K/)) && (!($Opt->{read_during_write_mode} =~ /DONT_CARE/))) 
    {   
    $parameter_map->{read_during_write_mode_port_a} = qq("$Opt->{read_during_write_mode}");
    $parameter_map->{read_during_write_mode_port_b} = qq("$Opt->{read_during_write_mode}");
    }



}
  }
  else
  {

  }



  

















  my $sim_parameter_map = {%$parameter_map};


  my $hdl_file_info = $Opt->{target_info}->{hex};
  my $sim_file_info = $Opt->{target_info}->{dat};
  
  if ($Opt->{make_individual_byte_lanes})
  {

    



    $parameter_map->{width_a} = 8;
    $sim_parameter_map->{width_a} = 8;
    
    for my $lane (0 .. $Opt->{num_lanes} - 1)
    {
      e_assign->add(["write_lane$lane", and_array('wren', "byteenable\[$lane\]")]);
      $in_port_map->{wren_a} = "write_lane$lane";
      $in_port_map->{data_a} = sprintf("writedata[%d : %d]", ($lane + 1) * 8 - 1, $lane * 8);
      

      $out_port_map->{q_a} = ($SBI1->{Read_Latency} == 1) ? 
      sprintf("readdata[%d : %d]", ($lane + 1) * 8 - 1, $lane * 8) :
      sprintf("readdata_ram[%d : %d]", ($lane + 1) * 8 - 1, $lane * 8);

      set_init_file_parameters(
        $Opt,
        $parameter_map,
        $sim_parameter_map,
        $hdl_file_info,
        $sim_file_info,
        $project,
      );


      e_blind_instance->add({
        tag    => 'synthesis',
        name   => "the_altsyncram_$lane",
        module => 'altsyncram',
        in_port_map => $in_port_map,
        out_port_map => $out_port_map,
        parameter_map => $parameter_map,
      });


      e_blind_instance->add({
        tag    => 'simulation',
        name   => "the_altsyncram_$lane",
        module => 'altsyncram',
        in_port_map => $in_port_map,
        out_port_map => $out_port_map,
        parameter_map => $sim_parameter_map,
        use_sim_models => 1,
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
      $project,
    );

    if ($Opt->{ram_block_type} =~ /M-RAM/ )
    {



      $sim_parameter_map->{ram_block_type} = qq("M4K");
    }


    e_blind_instance->add({
      tag    => 'synthesis',
      name   => 'the_altsyncram',
      module => 'altsyncram',
      in_port_map => $in_port_map,
      out_port_map => $out_port_map,
      parameter_map => $parameter_map,
    });


    e_blind_instance->add({
      tag    => 'simulation',
      name   => 'the_altsyncram',
      module => 'altsyncram',
      in_port_map => $in_port_map,
      out_port_map => $out_port_map,
      parameter_map => $sim_parameter_map,
      use_sim_models => 1,
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
    $project,
  ) = @_;  
  
  if ($hdl_file_info)
  {
    my $rec = shift @{$hdl_file_info->{targets}};

    
    my $stub = $Opt->{init_contents_file};
   


    $stub =~ s|\\|/|g;
      

    my $hex = "$stub.hex";
    

    if($Opt->{make_individual_byte_lanes})
    {

      split "lane", $rec->{ptf_key};
      $hex = $stub."_lane".$_[1].".hex";
    }
    
    $parameter_map->{init_file} = qq("$hex");
    

    my $file;
    $file = qq(../$hex);
    


    if (($stub =~ m|/|) || ($Opt->{sim_meminit_only_filename}) ) 
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
  }


  if ($Opt->{init_mem_content} == 0 )
  {
    $parameter_map->{init_file} = qq("UNUSED");
    $sim_parameter_map->{init_file} = qq("UNUSED");
  }
}






sub calculate_maximum_depth
{
	(my $Opt) = @_;


	if(&is_power_of_two($Opt->{num_words}))
	{
		return $Opt->{num_words};
	}
	else
	{
		my $next_power_of_2 = &next_higher_power_of_two($Opt->{num_words});


		
		my $gcd = &gcd_euclid($Opt->{num_words}, $next_power_of_2);

		return &max($gcd, int(4096/$Opt->{Data_Width}));
		
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
