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
use europa_utils;
use strict;






my $how_many_sections = 3;
my $how_many_counters = 4;
my $highest_addressable_byte = 15;
my $address_width = 4;








sub Validate_Options 
{
  my ($Options) = (@_);

   &validate_parameter ({hash    => $Options,
                         name    => "how_many_sections",
                         type    => "integer",
                         default => 3,
                      });

   $how_many_sections = $Options->{how_many_sections};
   $how_many_counters = $how_many_sections + 1;
   $highest_addressable_byte = ($how_many_counters * 4) - 1; 
   $address_width = &Bits_To_Encode($highest_addressable_byte);
}











sub make_performance_counter
{
   my ($module, $Opt) = (@_);
   
   &Validate_Options ($Opt);





   my $marker = e_default_module_marker->new($module);

   e_port->adds(["address",       $address_width,        "in" ],
                ["writedata",     32,                    "in"],
                ["readdata",      32,                    "out"],
                ["write",         1,                     "in" ],
                ["begintransfer", 1,                     "in" ],
                );
   
   e_avalon_slave->add ({name => "control_slave",});  
   e_assign->add (["clk_en", "-1"]);
   e_assign->add (["write_strobe", "write & begintransfer"]);





   my @read_mux_table = ();

   for (my $i = 0; $i < $how_many_counters; $i++) {
      my $time_counter_signal = "time_counter_$i";
      my $event_counter_signal = "event_counter_$i";
      my $enable_signal  = "time_counter_enable_$i";
      my $stop_strobe = "stop_strobe_$i";
      my $go_strobe   = "go_strobe_$i";



      e_register->add 
          ({out        => e_signal->add([$time_counter_signal, 64]),
            in         => "$time_counter_signal + 1",
            sync_reset => "global_reset",
            enable     => "($enable_signal & global_enable) | global_reset",
         });



      e_register->add 
          ({out        => e_signal->add([$event_counter_signal, 64]),
            in         => "$event_counter_signal + 1",
            sync_reset => "global_reset",
            enable     => "($go_strobe & global_enable) | global_reset",
         });


      my $lo_A    = $i * 4;
      my $hi_A    = $lo_A + 1;
      my $event_A = $hi_A + 1;
      push (@read_mux_table, 
            "(address == $lo_A)",     "$time_counter_signal \[31: 0]",
            "(address == $hi_A)",     "$time_counter_signal \[63:32]",
            "(address == $event_A)",  "$event_counter_signal"         );


      e_assign->adds 
          ([$stop_strobe, "(address == $lo_A) && write_strobe"],
           [$go_strobe,   "(address == $hi_A) && write_strobe"] );



      e_register->add 
          ({out        => $enable_signal,
            sync_reset => "$stop_strobe | global_reset",
            sync_set   => $go_strobe,
            priority   => "reset",
         });





      if ($i == 0) {
         e_assign->adds
             (["global_enable", "$enable_signal | $go_strobe" ],
              ["global_reset",  "$stop_strobe && writedata[0]"] );
      }
   }






   e_mux->add ({out   => e_signal->add(["read_mux_out", 32]),
                table => \@read_mux_table,
                type  => "and-or"
               });

  e_register->add ({out => "readdata",
                    in  => "read_mux_out"});
}

1;
