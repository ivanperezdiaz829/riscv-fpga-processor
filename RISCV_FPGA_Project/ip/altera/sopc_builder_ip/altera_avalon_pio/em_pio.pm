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
use strict;







my $has_tri = 0;
my $has_in = 0;
my $has_out = 1;
my $irq_type = "LEVEL";
my $edge_type = "RISING";
my $width = 8;
my $reset_value = 0;
my $bit_modifying_output_register = 1;
my $bit_clearing_edge_register = 1;
my $has_irq =0;                         

my $reset_value_bits;
my $has_any_input;
my $has_any_output;
my $has_edge;
my $irq_on_edge;                      







sub Validate_PIO_Options
{
  my ($Options) = (@_);
                                                             


  &validate_parameter ({hash    => $Options,
                        name    => "has_tri",
                        type    => "boolean",
                        default => 0,
                       });

  &validate_parameter ({hash    => $Options,
                        name    => "has_in",
                        type    => "boolean",
                        default => 0,
                       });

  &validate_parameter ({hash    => $Options,
                        name    => "has_out",
                        type    => "boolean",
                        default => 1,
                       });



  &validate_parameter ({hash         => $Options,
                        name         => "has_tri",
                        excludes_all => ["has_in", "has_out"],
                       });

  &validate_parameter ({hash    => $Options,
                        name    => "irq_type",
                        allowed => ["NONE", "LEVEL", "EDGE"],
                       });

  &validate_parameter ({hash    => $Options,
                        name    => "edge_type",
                        allowed => ["NONE", "RISING", "FALLING", "ANY"],
                       });

  &validate_parameter ({hash    => $Options,
                        name    => "width",
                        range   => [1, 32],
                       });

  &validate_parameter ({hash    => $Options,
                        name    => "reset_value",
                        type    => "long",
                        default => 0,
                       });                   
                                                         

  if ($Options->{has_tri} || $Options->{has_out})
  {
    $Options->{reset_value_bits} = &Bits_To_Encode($Options->{reset_value});
    &validate_parameter ({hash    => $Options,
                          name    => "reset_value_bits",
                          range   => [0, $Options->{width}],
                        });
  }



  $Options->{has_any_input}  = $Options->{has_tri} || $Options->{has_in};
  $Options->{has_any_output} = $Options->{has_tri} || $Options->{has_out};



  $Options->{has_edge}       = $Options->{edge_type} ne "NONE";
  $Options->{irq_on_edge}    = $Options->{irq_type}  eq "EDGE"; 

  &validate_parameter ({hash         => $Options,
                        name         => "has_irq",
                        optional     => 1,
                        requires     => "has_any_input",
                       });

  &validate_parameter ({hash         => $Options,
                        name         => "has_edge",
                        optional     => 1,
                        requires     => "has_any_input",
                       });

  &validate_parameter ({hash         => $Options,
                        name         => "irq_on_edge",
                        optional     => 1,
                        requires     => "has_edge",
                       });
  $has_tri             		 = $Options->{has_tri};
  $has_in         		 = $Options->{has_in};
  $has_out             		 = $Options->{has_out};
  $reset_value         		 = $Options->{reset_value};
  $width         		 = $Options->{width};
  $edge_type         		 = $Options->{edge_type};
  $irq_type         		 = $Options->{irq_type};                    
  $bit_modifying_output_register = $Options->{bit_modifying_output_register};
  $bit_clearing_edge_register    = $Options->{bit_clearing_edge_register};  
  $has_irq    			 = $Options->{has_irq};
  $reset_value_bits    		 = $Options->{reset_value_bits};
  $has_any_input    		 = $Options->{has_any_input};   
  $has_any_output    		 = $Options->{has_any_output};   
  $has_edge    			 = $Options->{has_edge};   
  $irq_on_edge    		 = $Options->{irq_on_edge};   
  






}








sub make_pio
{
  my ($module, $Opt) = (@_);
  &Validate_PIO_Options ($Opt);





  my $marker = e_default_module_marker->new($module);





  my $bitrange = ($width > 1)? '[' . ($width - 1) . ':0]' : "";

  e_signal->adds (
                  [edge_capture_wr_strobe => 1],
                  [clk_en => 1,0,1],
                  [chipselect => 1],
                  [clk => 1],
                  [reset_n => 1],
                  );


  e_assign->add (["clk_en", 1]);




  e_port->add(["bidir_port", $width, "inout"]) if $has_tri;
  e_port->add(["in_port",    $width, "in"   ]) if $has_in;
  e_port->add(["out_port",   $width, "out"  ]) if $has_out;








  e_avalon_slave->add ({name => "s1",});  # I want my slave-ports seen by the SOPC-Builder.
  
  if ($bit_modifying_output_register) {
    e_port->add(["address", 3, "in"]);
  } else {
    e_port->add(["address", 2, "in"]);
  }




  if ($has_any_output || $has_irq || $has_edge) {

	e_port->adds(["writedata", 32 , "in"],
                 ["write_n"  ,            1 , "in"]);
  }

  my $read_mux;
  if ($has_any_input) 
  {

    e_port->add(["readdata",  32 , "output"]);
    $read_mux = e_mux->add ({lhs  => e_signal->add (["read_mux_out",
                                                     $width  ]),
                             type => "and-or",
                             });

    e_register->add ({out => "readdata",
                      in  => "{32'b0 | read_mux_out}"});
  }
  elsif ($has_any_output) {

    e_port->add(["readdata",  32 , "output"]);
    $read_mux = e_mux->add ({lhs  => e_signal->add (["read_mux_out",
                                                     $width  ]),
                             type => "and-or",
                             });
  }




  if ($has_any_output) {
   


    if ($bit_modifying_output_register) {

      e_assign->add (["wr_strobe",
                      "chipselect && ~write_n",
                     ]);

      e_register->add ({out         => e_signal->add (["data_out", $width]),
                        async_value => $reset_value, 
                        sync_set    => "wr_strobe",
                        set_value   => "(address == 5)? data_out & ~writedata $bitrange: (address == 4)? data_out | writedata $bitrange: (address == 0)? writedata $bitrange: data_out",
                       }) ;
    } else { 

      e_register->add ({out         => e_signal->add (["data_out", $width]),
                        in          => "writedata $bitrange",
                        enable      => "chipselect && ~write_n && (address == 0)",
                        async_value => $reset_value,
                       });
    }


    if ($has_tri) {


      if ($width == 1) {
        e_assign->add (["bidir_port", "data_dir ? data_out : 1'bZ"]);
      } else {
        for (my $i = 0; $i < $width; $i++) {
          e_assign->add (["bidir_port[$i]", 
                          "data_dir[$i] ? data_out[$i] : 1'bZ"]);
        }
      }
    } else {
      if  ($has_any_input == 0) {
        e_assign->add(["readdata","{32'b0 | read_mux_out}"]);
        $read_mux->add_table ("(address == 0)" => "data_out");   #modified
      }
    }

    e_assign->add (["out_port", "data_out"]) if $has_out;
  }




  if ($has_any_input) {
    e_signal->add(["data_in", $width]);

    e_assign->add(["data_in", "in_port"   ]) if $has_in;
    e_assign->add(["data_in", "bidir_port"]) if $has_tri;

    $read_mux->add_table ("(address == 0)" => "data_in");
  }




  if ($has_tri) {
    e_register->add ({out    => e_signal->add (["data_dir", $width]),
                      in     => "writedata $bitrange",
                      enable => "chipselect && ~write_n && (address == 1)",
                     });

    $read_mux->add_table ("(address == 1)" => "data_dir");
  }





  if ($has_irq) {
    e_register->add ({out    => e_signal->add (["irq_mask", $width]),
                      in     => "writedata $bitrange",
                      enable => "chipselect && ~write_n && (address == 2)",
                     });

    $read_mux->add_table ("(address == 2)" => "irq_mask");

    e_port->add(["irq" => 1, "output"]);


    if      ($irq_type eq "LEVEL") {
      e_assign->add (["irq", "|(data_in      & irq_mask)"]) 
    } elsif ($irq_type eq "EDGE") {
      e_assign->add (["irq", "|(edge_capture & irq_mask)"]) 
    } else {
      &ribbit ("Unexpected bad irq_type: $irq_type");
    }
  }






  if ($has_edge) {
    e_signal->add (["edge_capture", $width]);
    $read_mux->add_table ("(address == 3)" => "edge_capture");

    e_assign->add ([
                    "edge_capture_wr_strobe",
                    "chipselect && ~write_n && (address == 3)",
                    ]);



    if ($bit_clearing_edge_register){
        if ($width == 1) {
            e_register->add ({out        => "edge_capture",
                              sync_set   => "edge_detect",
                              sync_reset => "edge_capture_wr_strobe && writedata[0]",
                             });
        } else {
          for (my $i = 0; $i < $width; $i++) {
            e_register->add ({out        => "edge_capture[$i]",
                              sync_set   => "edge_detect[$i]",
                              sync_reset => "edge_capture_wr_strobe && writedata[$i]",
                             });
          }
        }
    }
    else{
      if ($width == 1) {
          e_register->add ({out        => "edge_capture",
                            sync_set   => "edge_detect",
                            sync_reset => "edge_capture_wr_strobe",
                           });
      } else {
        for (my $i = 0; $i < $width; $i++) {
          e_register->add ({out        => "edge_capture[$i]",
                            sync_set   => "edge_detect[$i]",
                            sync_reset => "edge_capture_wr_strobe",
                           });
        }
      }
    }






    e_register->add({in => "data_in", delay => 2});

    e_signal->add (["edge_detect", $width]);
    if ($edge_type      eq "RISING") {
      e_assign->add (["edge_detect", " d1_data_in & ~d2_data_in"]);
    } elsif ($edge_type eq "FALLING") {
      e_assign->add (["edge_detect", "~d1_data_in & d2_data_in"]);
    } elsif ($edge_type eq "ANY") {
      e_assign->add (["edge_detect", " d1_data_in ^  d2_data_in"]);
    } else {
      &ribbit ("Unexpected bad edge type: $edge_type");
    }
  }
  return $module;
}

1;
