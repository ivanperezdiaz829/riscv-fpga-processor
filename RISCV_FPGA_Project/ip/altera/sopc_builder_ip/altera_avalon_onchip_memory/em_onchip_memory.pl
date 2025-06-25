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









































































































use strict;
use europa_all;
use format_conversion_utils;
use wiz_utils;



my $project = e_project->new (@ARGV);
&make_mem ($project->top(), $project);
$project->output();









sub Validate_Memory_Options
{
  my ($Options, $SBI, $project) = (@_);


  $Options->{name} = $project->_target_module_name();



  &validate_parameter ({hash    => $Options,
                        name    => "Writeable",
                        type    => "boolean",
                        default => 1,
                       });











  $Options->{is_blank}  = ($Options->{CONTENTS}{srec}{Kind} =~ /^blank/i) ? 
      "1" : "0";

  $Options->{is_file}   = 
      ($Options->{CONTENTS}{srec}{Kind} =~ /^textfile/i) ? 
      "1" : "0";

  my $textfile = $Options->{CONTENTS}{srec}{Textfile_Info};
  

  my $system_directory = $project->_system_directory();
  $textfile =~ s/^(\w+)(\\|\/)/$system_directory$2$1$2/;

  $textfile =~ s/^(\w+)$/$system_directory\/$1/;

  $Options->{textfile}   = $textfile;

  &validate_parameter ({hash     => $Options,
                        name     => "is_blank",
                        requires => "Writeable",
                        severity => "warning",
                        message  => "Blank ROM:  Legal, but suspicious.",
                       });




  my $Initfile = $Options->{name} . "_contents.srec";





  if($Initfile !~ /^([a-zA-Z]:)?\/.*$/) # not start with X:/ or just slash...
  {
    $Initfile = $project->_system_directory() . "/" . $Initfile;
  }

  $Options->{Initfile} = $Initfile;


  &ribbit ("Memory-initialization files must be either .mif or .srec.\n",
           " not '$Options->{Initfile}'\n")
    unless $Options->{Initfile} =~ /\.(srec|mif)$/i;

  &validate_parameter ({hash     => $Options,
                        name     => "Shrink_to_fit_contents",
                        type     => "boolean",
                        default  => 0,
                     });

  $Options->{not_blank} = !$Options->{is_blank};
  &validate_parameter ({hash     => $Options,
                        name     => "Shrink_to_fit_contents",
                        requires => "not_blank",
                        message  => "How the heck can I shrink to fit blank?",
                       });

  &validate_parameter ({hash    => $SBI,
                        name    => "Data_Width",
                        type    => "integer",
                        allowed => [8, 16, 32, 64, 128,],
                       });



  &validate_parameter ({hash    => $Options,
                        name    => "Size_Multiple",
                        type    => "integer",
                        allowed => [1,1024],
                        default => 1,
                       });
  
  &validate_parameter ({hash    => $Options,
                        name    => "Size_Value",
                        type    => "integer",
                       });

  $Options->{Address_Span} = $Options->{Size_Multiple} * 
                             $Options->{Size_Value};



  $project->WSA()->{Address_Span} = $Options->{Address_Span};


  &validate_parameter ({hash     => $Options,
                        name     => "use_altsyncram",
                        type     => "boolean",
                        default  => 0,
                     });

  &validate_parameter ({hash    => $Options,
                        name    => "use_ram_block_type",
                        type     => "string",
                        allowed => ["M512", 
                                    "M4K", 
                                    "M-RAM"],
                        default  => "M4K",
                       });


  &validate_parameter ({hash    => $Options,
                        name    => "altsyncram_maximum_depth",
                        type    => "integer",
                        default  => 0,
                       });








  $Options->{lane_width}    = $Options->{Writeable} ? 8 : $SBI->{Data_Width};
  $Options->{num_lanes}     = $SBI->{Data_Width}/$Options->{lane_width};
  $Options->{Address_Width} = $SBI->{Address_Width};
  $Options->{Data_Width}    = $SBI->{Data_Width};




  my $byte_width = int($SBI->{Data_Width} / 8);
  $Options->{depth} = ceil ($Options->{Address_Span} / $byte_width);




  &validate_parameter ({hash    => $SBI,
                        name    => "Address_Width",
                        type    => "integer",
                        range   => [&Bits_To_Encode($Options->{depth}-1), 32],
                        });



  $Options->{base_addr_as_number} = $SBI->{Base_Address};
  $Options->{base_addr_as_number} = hex ($Options->{base_addr_as_number})
      if ($Options->{base_addr_as_number} =~ /^0x/i);
      


  &validate_parameter ({hash     => $SBI,
                        name     => "Read_Latency",
                        type     => "integer",
                        range    => [0, 10],
                        message  => "My, what a large Read_Latency you have.",
                        severity => "warning",
                        default  => 0,
                        });
  
  &validate_parameter ({hash     => $SBI,
                        name     => "Setup_Time",
                        type     => "integer",
                        range    => [0, 10],
                        message  => "My, what a large Setup_Time you have.",
                        severity => "warning",
                        default  => 0,
                        });
  &validate_parameter ({hash     => $SBI,
                        name     => "Hold_Time",
                        type     => "integer",
                        range    => [0, 10],
                        message  => "My, what a large Hold_Time you have.",
                        severity => "warning",
                        default  => 0,
                        });
  &validate_parameter ({hash     => $SBI,
                        name     => "Read_Wait_States",
                        type     => "integer",
                        range    => [0, 10],
                        message  =>
                          "My, what a lot of Read_Wait_States you have.",
                        severity => "warning",
                        default  => 0,
                        });
  &validate_parameter ({hash     => $SBI,
                        name     => "Write_Wait_States",
                        type     => "integer",
                        range    => [0, 10],
                        message  =>
                          "My, what a lot of Write_Wait_States you have.",
                        severity => "warning",
                        default  => 0,
                        });
                        
  $SBI->{no_latent_read} = $SBI->{Read_Latency} == 0;
  &validate_parameter ({hash     => $SBI,
                        name     => "Setup_Time",
                        requires => "no_latent_read",
                        message  => "setup time not allowed with latent read.",
                        });
  &validate_parameter ({hash     => $SBI,
                        name     => "Hold_Time",
                        requires => "no_latent_read",
                        message  => "hold time not allowed with latent read.",
                        });
  &validate_parameter ({hash     => $SBI,
                        name     => "Read_Wait_States",
                        requires => "no_latent_read",
                        message  =>
                          "read wait states not allowed with latent read.",
                        });
  &validate_parameter ({hash     => $SBI,
                        name     => "Write_Wait_States",
                        requires => "no_latent_read",
                        message  =>
                          "write wait states not allowed with latent read.",
                        });










  warn ("Software-only modification for shrink-to-fit memory.\n".
        "  Contents may or may not still fit in hardware memory.\n")
      if ($project->_software_only() && $Options->{Shrink_to_fit_contents});
}








sub make_mem
{
  my ($module, $project) = (@_);
  my $Opt = &copy_of_hash ($project->WSA());
  my $SBI = &copy_of_hash ($project->SBI("s1"));
  $Opt->{name} = $module->name();

  if ($Opt->{dual_port})
  {


     my $SBI2 = &copy_of_hash ($project->SBI("s2"));
     if (eval($SBI2->{Base_Address}) > eval($SBI->{Base_Address}))
     {
        $SBI = $SBI2;
     }
  }

  &Validate_Memory_Options ($Opt, $SBI, $project);






  &process_mem_contents ($module->name(), $Opt, $SBI);

  if ($Opt->{use_altsyncram}) {
    &instantiate_altsyncram($module, $Opt, $project);
  } else {




    &Figure_Out_Best_Depth ($Opt);




    my @d_lane_list = ();
    my @q_lane_list = ();

    for (my $i = $Opt->{num_lanes} - 1; $i >= 0; $i--) {
      my $lane_d_sig = e_signal->new (["d_lane_$i", $Opt->{lane_width}]);
      my $lane_q_sig = e_signal->new (["q_lane_$i", $Opt->{lane_width}]);
      push (@d_lane_list, $lane_d_sig->name());
      push (@q_lane_list, $lane_q_sig->name());

      my $write_sig  = "0";   # Start with non-writeable assumption.
      if ($Opt->{Writeable}) {
        $write_sig = e_signal->new (["write_lane_$i", 1]);



        my $lane_wbe =  ($Opt->{num_lanes} == 1)    ? 
                            "writebyteenable"       : 
                            "writebyteenable\[$i\]" ;

        e_assign->new({within => $module,
                      lhs    => $write_sig,
                      rhs    => $lane_wbe,
                      });

        $module->add_contents 
          (e_signal->new (["writebyteenable", $Opt->{num_lanes}]));
      }






      my $whole_mem_select_signal = e_signal->new (["select_all_chunks", 1,0,1]);
      e_assign->new ({within => $module,
                      lhs    => $whole_mem_select_signal,
                      rhs    => 1
                    });




      my $initfile_base_address = 
          ($Opt->{Initfile} =~ /\.mif/i) ? 0 : $Opt->{base_addr_as_number};

      $module->add_contents
        ($lane_d_sig,
        $lane_q_sig,
        &make_chunked_memory ({name           => $module->name() . "_lane$i",
                                Writeable      => $Opt->{Writeable},
                                write          => $write_sig,
                                wrclock        => "clk",
                                d              => $lane_d_sig,
                                "q"            => $lane_q_sig,
                                outer_select   => $whole_mem_select_signal,
                                width          => $Opt->{lane_width},
                                depth          => $Opt->{depth},
                                Initfile       => $Opt->{Initfile},
                                address_width  => $SBI->{Address_Width},
                                lane           => $i,
                                num_top_lanes  => $Opt->{num_lanes},
                                base           => $initfile_base_address,
                                bytes_per_word => $SBI->{Data_Width} / 8,
                                Read_Latency   => $SBI->{Read_Latency},
                                project        => $project,
                                }),
        );
    }


    e_assign->new
      ({within => $module,
        lhs    => e_port->new(["readdata", $SBI->{Data_Width}, "out"]),
        rhs    => &concatenate(@q_lane_list),
      });

    e_assign->new
      ({within => $module,
        lhs    => &concatenate(@d_lane_list),
        rhs    => e_port->new(["writedata", $SBI->{Data_Width}, "in"]),
      }) if $Opt->{Writeable};
  }



  e_port->new({within    => $module,
               name      => "address",
               width     => $SBI->{Address_Width},
               direction => "in",
              });



  my $s1_args = {
     within => $module, 
     name   => "s1",
     sideband_signals => [ "clken" ],
  };

  e_avalon_slave->new($s1_args);

  my %slave_2_type_map = reverse
  (
     address    => "address2",
     readdata   => "readdata2",
     chipselect => "chipselect2",
     write      => "write2",
     writedata  => "writedata2",
     byteenable => "byteenable2",
     clken      => "clken2",
  );

  my $s2_args = {
     within => $module,
     name   => "s2",
     type_map => \%slave_2_type_map,
     sideband_signals => [ "clken" ],
  };

  e_avalon_slave->new($s2_args);

  return $module;
}
































sub make_chunked_memory
{
  my ($arg) = (@_);


  $arg->{depth} = max($arg->{minimum_chunk_size}, $arg->{depth});


  if (&is_power_of_two($arg->{depth})) {
    return &make_one_memory_chunk ($arg);
  }








  my $chunk_size         = &next_lower_power_of_two ($arg->{depth});
  my $leftover_size      = $arg->{depth} - $chunk_size;
  my $chunk_addr_bits    = &Bits_To_Encode($chunk_size - 1);
  my $leftover_base      = $arg->{base} + $chunk_size * $arg->{bytes_per_word};
  my $chunk_name         = $arg->{name} . "_chunk_$chunk_size";
  my $leftover_name      = $arg->{name} . "_leftover";

  my $chunk_select_sig    = e_signal->new(["select_$chunk_name",       1]);
  my $chunk_mux_select_sig= e_signal->new(["mux_select_$chunk_name",   1]);
  my $leftover_select_sig = e_signal->new(["select_$leftover_name",    1]);
  my $chunk_write_sig     = e_signal->new(["write_$chunk_name",        1]);
  my $leftover_write_sig  = e_signal->new(["write_$leftover_name",     1]);
  my $chunk_q_sig         = e_signal->new(["q_$chunk_name",    $arg->{width}]);
  my $leftover_q_sig      = e_signal->new(["q_$leftover_name", $arg->{width}]);

  &ribbit ("Odd.  leftover size < 0 ($arg->{depth} - $chunk_size\n") 
    if $leftover_size < 0;



  my %chunk_arg    = %{$arg};
  my %leftover_arg = %{$arg};

  $chunk_arg{name}             = $chunk_name;
  $chunk_arg{write}            = $chunk_write_sig;
  $chunk_arg{"q"}              = $chunk_q_sig;
  $chunk_arg{depth}            = $chunk_size;
  $chunk_arg{address_width}    = &Bits_To_Encode ($chunk_size - 1);
  $chunk_arg{outer_select}     = $chunk_select_sig;
  
  $leftover_arg{name}          = $leftover_name;
  $leftover_arg{write}         = $leftover_write_sig;
  $leftover_arg{"q"}           = $leftover_q_sig;
  $leftover_arg{depth}         = $leftover_size;
  $leftover_arg{address_width} = &Bits_To_Encode ($leftover_size - 1);
  $leftover_arg{base}          = $leftover_base;
  $leftover_arg{outer_select}  = $leftover_select_sig;





  my @result = ();
  push 
    (@result, 
     e_signal->news ({name         => "$chunk_name\_lo_addr",
                      width        => $chunk_addr_bits,
                      never_export => 1,
                     },
                     {name         => "$chunk_name\_hi_addr",
                      width        => $arg->{address_width} - $chunk_addr_bits,
                      never_export => 1,
                     },
                    ),

     e_assign->new (["{$chunk_name\_hi_addr, $chunk_name\_lo_addr}", 
                     "address"]),
    );

  push (@result, 
    $chunk_select_sig,
    $leftover_select_sig,
    $chunk_q_sig,
    $leftover_q_sig,




    e_assign->news 
      ({lhs => $chunk_select_sig,
        rhs => "(~|($chunk_name\_hi_addr)) && ". $arg->{outer_select}->name(),
       },
       { lhs => $leftover_select_sig,
         rhs => "( |($chunk_name\_hi_addr)) &&". $arg->{outer_select}->name(),
       }),

    e_mux->new ({lhs     => $arg->{"q"},
                 table   => [$chunk_mux_select_sig => $chunk_q_sig],
                 default => $leftover_q_sig,
                }),
  );







  if ($arg->{Read_Latency}) {
     push (@result, 
           e_register->new ({out    => $chunk_mux_select_sig,
                             in     => $chunk_select_sig->name(),
                             delay  => $arg->{Read_Latency},
                             enable => "1'b1",
                          }),
           );
  } else { 
     push (@result,
           e_assign->new ({lhs => $chunk_mux_select_sig,
                           rhs => $chunk_select_sig->name(),
                        }),
           );
  }
                               





  $leftover_select_sig->never_export(1);



  if ($arg->{Writeable}) {
    push (@result,

      e_assign->new 
        ({lhs => $chunk_write_sig,
          rhs => $chunk_select_sig->name() . "&&" . $arg->{write}->name(),
        }),



      e_assign->new 
        ({lhs => $leftover_write_sig,
          rhs => $leftover_select_sig->name() . "&&" . $arg->{write}->name(),
         }),
    );
  }

  push (@result,

    &make_chunked_memory (\%chunk_arg),


    &make_chunked_memory (\%leftover_arg),
  );
  return @result;
}














sub make_one_memory_chunk
{
  my ($arg) = (@_);



  &ribbit ("Memory-chunk created which is not a power-of-two size")
    if !is_power_of_two($arg->{depth});



  my $addr_bits   = &Bits_To_Encode ($arg->{depth} - 1);
  my $address_sig = e_signal->new ([$arg->{name} . "_address", $addr_bits]);




  my $chunk_mif_filename = &create_mif_file_for_chunk ($arg);

  my @result = ();
  push (@result, e_assign->new ([$address_sig, "address"]));

  my $comment = 
    "Atomic memory instance: $arg->{name}\n" . 
    "  Size: $arg->{depth}(words) X $arg->{width}(bits)\n";




  push (@result, $arg->{"q"},  $arg->{d});

  if ($arg->{Writeable}) {
    push (@result,
      e_ram->new({name     => $arg->{name},
                  comment  => $comment,
                  port_map => {
                               wren      => $arg->{write},
                               wrclock   => $arg->{wrclock},
                               data      => $arg->{d},
                               rdaddress => $address_sig,
                               wraddress => $address_sig,
                               "q"       => $arg->{"q"},

                              },
                  mif_file => $chunk_mif_filename,
                  Read_Latency      => $arg->{Read_Latency},
                  })
         );
  } else {
    push (@result,
      e_rom->new({name     => $arg->{name},
                  comment  => $comment,
                  port_map => {
                               address   => $address_sig,
                               "q"       => $arg->{"q"},
                              },
                  mif_file => $chunk_mif_filename,
                  Read_Latency      => $arg->{Read_Latency},
                 })
         );
  }
  return @result;
}






































sub Figure_Out_Best_Depth
{
  my ($Opt) = (@_);

  if ($Opt->{minimum_chunk_size} eq "")  # If user-set, leave it alone.
  {
    $Opt->{minimum_chunk_size} = int (max (128, $Opt->{depth} * 0.07));
  }


  $Opt->{minimum_chunk_size} = 
    &next_higher_power_of_two($Opt->{minimum_chunk_size});



  my $next_higher_power_of_two = &next_higher_power_of_two($Opt->{depth});
  my $num_total_chunks = ceil ($Opt->{depth} / $Opt->{minimum_chunk_size});
  my $next_chunk_multiple = $num_total_chunks * $Opt->{minimum_chunk_size};
  $Opt->{depth} = min ($next_higher_power_of_two, $next_chunk_multiple);
}












sub create_mif_file_for_chunk
{
  my ($arg) = (@_);
  
  
  my $mif_filename = $arg->{name} . ".mif";
  my $mif_pathname = $arg->{project}->_system_directory() . "/" . 
                     $mif_filename;
  my $chunk_addr_span = $arg->{depth} * $arg->{bytes_per_word};






  my $chunk_offset_into_file = $arg->{base};
  if ($arg->{Initfile} =~ /\.mif$/i) { 
     $chunk_offset_into_file -= $arg->{Base_Address};
  }
  
  my $convert_args = {0            => $arg->{Initfile},
                      "1"          => $mif_pathname,
                      comments     => "0",
                      lane         => $arg->{lane},
                      lanes        => $arg->{num_top_lanes},
                      width        => $arg->{width},
                      address_low  => $arg->{base},
                      address_high => $arg->{base} + $chunk_addr_span - 1,
                   };

  $convert_args->{oformat}  = "mif";
  $convert_args->{destfile} = $mif_pathname;

  &fcu_convert ($convert_args);

  return $mif_filename;
}





sub create_mif_file_for_altsyncram
{
  my ($Opt, $project) = (@_);
  
  my $mif_filename = $Opt->{name} . ".mif";
  my $mif_pathname = $project->_system_directory() . "/" . 
                     $mif_filename;






  my $convert_args = {0            => $Opt->{Initfile},
                      "1"          => $mif_pathname,
                      comments     => "0",
                      width        => $Opt->{Data_Width},
                   };

  $convert_args->{oformat}  = "mif";
  $convert_args->{destfile} = $mif_pathname;

  &fcu_convert ($convert_args);

  return $mif_filename;
}





sub create_hex_file_for_altsyncram
{
  my ($Opt, $project) = (@_);
  
  
  my $hex_filename = $Opt->{name} . ".hex";
  my $hex_pathname = $project->simulation_directory() . "/" . 
                     $hex_filename;






  my $convert_args = {0            => $Opt->{Initfile},
                      "1"          => $hex_pathname,
                      comments     => "0",
                      width        => $Opt->{Data_Width},
                   };

  $convert_args->{oformat}  = "hex";
  $convert_args->{destfile} = $hex_pathname;

  &fcu_convert ($convert_args);


  $hex_pathname =~ s/^(\.[\\\/])/\.$1/s;
  return $hex_filename;
}














sub run_contents_process
{
  my ($mem_name, $Opt) = (@_);

  my $original_file_date = &get_file_modified_date ($Opt->{initfile});

                        type     => "boolean",
                        requires => "content_creation_program",

  my $return_code = &System_Win98_Safe ($Opt->{content_creation_program});
  if ($return_code != 0) {
    &ribbit ("Error executing content-creation program.\n",
             "  On-chip memory named: '$mem_name'\n",
             "  Command was:          '$Opt->{content_creation_program}\n",
             "  Error was:            '$?\n");
  }

  my $later_file_date = &get_file_modified_date($Opt->{initfile});
  if ($later_file_date <= $original_file_date) {
    &ribbit ("Suspicious content-creation process for on-chip memory.\n",
             " Initialization-file did not appear to get modified.\n",
             "  On-chip memory named: '$mem_name'\n",
             "  Command was:          '$Opt->{content_creation_program}\n",
             "  Initialization file:  '$Opt->{initfile}\n",
             "  Error was:            '$?\n");
  }
}











sub process_mem_contents
{
  my ($mem_name, $Opt, $SBI) = (@_);

  my @arg_o_list = ($Opt, $SBI, $project);






  my $base_address = $Opt->{base_addr_as_number};
  my $end_address = $base_address + $Opt->{Address_Span} - 1;

  if ($Opt->{is_blank} || $Opt->{is_file})
  {      
     my $convert_hash = {
        1            => $Opt->{Initfile},
        address_low  => $base_address,
        address_high => $end_address,
     };

     $convert_hash->{0} = $Opt->{textfile}
     if ($Opt->{is_file});

     &fcu_convert($convert_hash);
  }




  my ($size, $lo_addr, $hi_addr) =
    &fcu_get_address_range ($Opt->{Initfile});










  if ( ($Opt->{Initfile} =~ /.mif$/i) && ($lo_addr == 0) ) {
     $lo_addr += $Opt->{base_addr_as_number};
     $hi_addr += $Opt->{base_addr_as_number};
  }

  &ribbit ("Contents for memory named '$mem_name' contains data outside\n",
           " the memory's specified address-range\n",
           "   Contents file (init_file) is: $Opt->{Initfile}\n",
           "      Contains data between addresses [0x",
           sprintf("%X,",$lo_addr), "..0x", sprintf("%X",$hi_addr), "]",
           " (", sprintf ("%.3g", $size / 1024.0), "Kbytes)\n",
           "   Specified address range for memory is\n",
           "                                      [0x",
           sprintf("%X",$Opt->{base_addr_as_number}), "..0x", 
           sprintf("%X",$end_address), "]",
           " (", sprintf ("%.3g", $Opt->{Address_Span} / 1024.0), 
           "Kbytes)\n")
    if (($lo_addr < $Opt->{base_addr_as_number}) ||
        ($hi_addr > $end_address               )  );
  if ($Opt->{Shrink_to_fit_contents}) {
    $Opt->{depth} = ceil ($size / ($SBI->{Data_Width} / 8));
  }
}

sub figger_sdk_dir
{
   my ($project) = (@_);
   return $project->_system_directory() . "/".
          $project->_system_name()      . "_sdk";
}











sub run_default_build_process
{
  my ($Opt, $SBI, $project) = (@_);


  return unless ($Opt->{run_nios_build});




  my $sdk_dir = &figger_sdk_dir($project);

  my $cmd = "";
     $cmd .= $project->_sopc_directory();
     $cmd .= '\bin\nios-build';
     $cmd .= " -b $SBI->{Base_Address}";
     $cmd .= " -o $Opt->{Initfile}";
     $cmd .= " -sdk_directory=$sdk_dir";
     $cmd .= " $Opt->{extra_build_flags}";


  foreach my $fname (split(/\s*,\s*/, $Opt->{Source_files})) {
     $cmd .= " $fname";
  }

  print STDERR ("about to try this: '$cmd'\n");
  my $error_code = 
    &Run_Command_In_Unix_Like_Shell ($project->_sopc_directory(), $cmd);
  &ribbit ("Default build-process failed.\n".
           " Attempted command: ($cmd).\n") 
    if $error_code != 0;
}

sub run_custom_build_process
{
  my ($Opt, $SBI, $project) = (@_);

  my $cmd = $Opt->{Custom_build_command};
  
  print STDERR ("about to try this: '$cmd'\n");
  my $error_code = 
    &Run_Command_In_Unix_Like_Shell ($project->_sopc_directory(), $cmd);
  &ribbit ("Custom build-process failed.\n".
           " Attempted command: ($cmd).\n" .
           "error code: '$error_code'") 
    if $error_code != 0;
}














sub instantiate_altsyncram
{
    my ($module, $Opt, $project) = (@_);






    my $contents_file = $Opt->{name};

    if ($Opt->{use_ram_block_type} =~ /M-RAM/ && 
      !$Opt->{allow_mram_sim_contents_only_file})
    {
      $contents_file = '';
    }

    if ($contents_file)
    {
      $Opt->{mif_file} = &create_mif_file_for_altsyncram ($Opt, $project);
      $Opt->{hex_file} = &create_hex_file_for_altsyncram ($Opt, $project);
      $Opt->{dat_file} = $Opt->{name} . ".dat";
    }                       

    my $marker = e_default_module_marker->new ($module);

    e_port->adds(
        ["clk",        1,                     "in" ],
        ["address",    $Opt->{Address_Width}, "in" ],
        ["readdata",   $Opt->{Data_Width},    "out"],
        );

    e_port->adds({name => "clken", width => 1, direction => "in",
      default_value => "1'b1"});


    $contents_file =~ s/^(\.[\\\/])/\.$1/s;



    if ($Opt->{Writeable}) {      # it's a RAM
      e_assign->add (["chipselect_and_write", "chipselect & write"]);
      e_port->adds(
        ["chipselect", 1,                     "in" ],
        ["write",      1,                     "in" ],
        ["writedata",  $Opt->{Data_Width},    "in" ],
        );

    } else {                      # it's a ROM

    }


    my $lane_uniqueness_ref = {};
    if ($Opt->{num_lanes} > 1) {
        e_port->adds(
            ["byteenable", $Opt->{num_lanes},     "in" ],
            );
        $lane_uniqueness_ref = {
            ram_block_type       => qq(") . $Opt->{use_ram_block_type} . qq("),
            maximum_depth        => $Opt->{altsyncram_maximum_depth},
            port_map => {
                byteenable => "byteenable",
            },
        };
    } else {    # only one byte lane.

    }

    if ($Opt->{dual_port}) {






       e_port->adds(["address2",    $Opt->{Address_Width}, "in" ],
                    ["readdata2",   $Opt->{Data_Width},    "out" ],
                    );

       e_port->adds({name => "clken2", width => 1, direction => "in",
         default_value => "1'b1"});

       my $in_port_map = {
                address_a  => 'address',
                address_b  => 'address2',
                clock0     => 'clk',
                clock1     => 'clk',
                clocken0   => 'clken',
                clocken1   => 'clken2',
             };

       my $out_port_map = {
                q_a       => 'readdata',
                q_b       => 'readdata2',
             };

       my $wren;
       my $wren2;
       my $be2;
       my $be;
       if ($Opt->{Writeable})
       {
          e_signal->adds([write2 => 1],
                         [chipselect2 => 1],
                         ["writedata2",  $Opt->{Data_Width}],
                         [byteenable  => ($Opt->{Data_Width} / 8)],
                         [byteenable2 => ($Opt->{Data_Width} / 8)],
                         );

          e_assign->adds([[wren => 1], 'chipselect_and_write'],
                         [[wren2 => 1], &and_array("chipselect2","write2")],
                         );

          $in_port_map->{byteena_a} = 'byteenable';
          $in_port_map->{byteena_b} = 'byteenable2';
          $in_port_map->{wren_a}    = 'wren';
          $in_port_map->{wren_b}    = 'wren2';
          $in_port_map->{data_a}    = 'writedata',
          $in_port_map->{data_b}    = 'writedata2',
       }

       my $num_words = $Opt->{depth} || die ("no depth");
       my $block_type = $Opt->{use_ram_block_type};

       my $parameter_map = {
          operation_mode            => qq("BIDIR_DUAL_PORT"),
          width_a                   => $Opt->{Data_Width},
          widthad_a                 => $Opt->{Address_Width},
          numwords_a                => $num_words,
          width_b                   => $Opt->{Data_Width},
          widthad_b                 => $Opt->{Address_Width},
          numwords_b                => $num_words,
          lpm_type                  => qq("altsyncram"),
          width_byteena_a           => $Opt->{num_lanes},
          width_byteena_b           => $Opt->{num_lanes},
          byte_size                 => 8,
          outdata_reg_a             => qq("UNREGISTERED"),
          outdata_aclr_a            => qq("NONE"),
          outdata_reg_b             => qq("UNREGISTERED"),
          indata_aclr_a             => qq("NONE"),
          wrcontrol_aclr_a          => qq("NONE"),
          address_aclr_a            => qq("NONE"),
          byteena_aclr_a            => qq("NONE"),
          indata_reg_b              => qq("CLOCK1"),
          address_reg_b             => qq("CLOCK1"),
          wrcontrol_wraddress_reg_b => qq("CLOCK1"),
          indata_aclr_b             => qq("NONE"),
          wrcontrol_aclr_b          => qq("NONE"),
          address_aclr_b            => qq("NONE"),
          byteena_reg_b             => qq("CLOCK1"),
          byteena_aclr_b            => qq("NONE"),
          outdata_aclr_b            => qq("NONE"),
          ram_block_type            => '"'.$Opt->{use_ram_block_type}.'"',
          intended_device_family    => qq("Stratix"),
       };

       if ((!$project->is_hardcopy_compatible() || !$Opt->{Writeable}) &&
         ($Opt->{use_ram_block_type} eq 'M4K' ||
           ($Opt->{use_ram_block_type} eq 'M-RAM' && 
            $Opt->{allow_mram_sim_contents_only_file})))
       {

          my %comp_parameter = %$parameter_map;


          if ($Opt->{use_ram_block_type} eq 'M4K') {
            $comp_parameter{init_file} = '"'.$Opt->{mif_file}.'"';
          }

          e_blind_instance->add({
             tag            => 'compilation',
             use_sim_models => 1,
             name           => 'the_altsyncram',
             module         => 'altsyncram',
             in_port_map    => $in_port_map,
             out_port_map   => $out_port_map,
             parameter_map  => \%comp_parameter,
          });


          my %sim_parameter = %$parameter_map;
          my $sim_file;
          if ($project->language() eq 'vhdl')
          {
             $sim_file = '"'.$Opt->{hex_file}.'"';
          }
          elsif ($project->language() eq 'verilog')
          {
             $sim_file = join ("\n",'',
                               '`ifdef NO_PLI',
                               '"'.$Opt->{dat_file}.'"',
                               '`else',
                               '"'.$Opt->{hex_file}.'"',
                               "\`endif\n");
          }
          else
          {
             die "unknown language ($project->language())\n";
          }





          $sim_parameter{ram_block_type} = '"M4K"';

          $sim_parameter{init_file} = $sim_file;
          e_blind_instance->add({
             tag            => 'simulation',
             use_sim_models => 1,
             name           => 'the_altsyncram',
             module         => 'altsyncram',
             in_port_map    => $in_port_map,
             out_port_map   => $out_port_map,
             parameter_map  => \%sim_parameter,
          });
       }
       else
       {
          e_blind_instance->add({
             use_sim_models => 1,
             name   => 'the_altsyncram',
             module => 'altsyncram',
             in_port_map => $in_port_map,
             out_port_map => $out_port_map,
             parameter_map => $parameter_map,
          });
       }
    } else {






       my $basic_dpram_hashref = {
           name                 => $Opt->{name} . "_memory_array",
           stratix_style_memory => 1,
           data_width           => $Opt->{Data_Width},
           address_width        => $Opt->{Address_Width},
           write_pass_through   => 0,
           contents_file        => $contents_file,
           allow_mram_sim_contents_only_file => 
             $Opt->{allow_mram_sim_contents_only_file},
           port_map => {


               rdclock   => "clk",
               rdclken   => 'clken',
               rdaddress => "address",
               q         => "readdata",
               },
       };

       if ($Opt->{Writeable}) {      # it's a RAM
          my $write_port_mappings = {
                wrclock   => "clk",
                wrclken   => "clken",
                data      => "writedata",
                wren      => "chipselect_and_write",
                wraddress => "address",
          };

          map {     # map all write ports into both 
            $basic_dpram_hashref->{port_map}{$_} = $$write_port_mappings{$_};
          } keys (%$write_port_mappings);
       }



       foreach my $key (keys (%$lane_uniqueness_ref)) {
         if (ref ($lane_uniqueness_ref->{$key}) eq "HASH")  {



           foreach my $key2 (keys (%{$lane_uniqueness_ref->{$key}})) {
             $basic_dpram_hashref->{$key}{$key2} = 
                           $lane_uniqueness_ref->{$key}{$key2};
           }
         } else {    # key is not a hash; it's just a humdrum key.
           $basic_dpram_hashref->{$key} = $lane_uniqueness_ref->{$key};
         }
       }


       e_dpram->add( $basic_dpram_hashref );
    }
    return $module;
}

