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




























use europa_global_project;
use europa_all;
use strict; 

use e_avalon_slave;

my %exclusively_named_port;

sub get_exclusively_named_port
{
   my $port_name = shift;

   while ($exclusively_named_port{$port_name})
   {
      $port_name = $port_name."_1"
          unless ($port_name =~ s/(\d+)$/$1 + 1/e);
   }

   $exclusively_named_port{$port_name}++;
   return ($port_name);
}            

sub get_slave_port_of_type
{
   my ($slave, $type) = @_;
   my $ports = $slave->{ports};

   my $complement = $type;

   unless ($complement =~ s/_n$//)
   {
      $complement .= "_n";
   }
   foreach my $port (keys (%$ports))
   {
      return ("$port")
          if ($ports->{$port}{type} eq $type);

      return ("~".$port)
          if ($ports->{$port}{type} eq $complement);
   }
   return;
}

sub build_mirrors
{
   my $avalon_slaves = shift or die ("no avalon slaves\n");

   my $gp               = $GLOBAL_PROJECT;
   my $module_ptf       = $gp->module_ptf();
   my $this_module_name = $gp->_target_module_name();






   my $added_clock_and_reset = 0;
   foreach my $slave (@$avalon_slaves)
   { 
      my $slave_spaced_pw = $slave->{slave_hash}{PORT_WIRING};
      my $slave_name = "$slave->{module_name}_$slave->{slave_name}";
      my $slave_unique_name = &get_exclusively_named_port
          ($slave_name);

      my $slave_select = &get_slave_port_of_type($slave,"chipselect")
          || &get_slave_port_of_type($slave,"registeredselect");

      if (!$slave_select)
      {
         if (@$avalon_slaves == 1)
         {
            $slave_select = &get_slave_port_of_type($slave,"write");
         }
      }
      $slave_select or
          &ribbit ("cannot find a slave select port for ",
                   "$slave->{module_name}/$slave->{slave_name}");

      foreach my $port_name (keys (%{$slave->{ports}}))
      {
         my $port  = $slave_spaced_pw->{"PORT $port_name"} or &ribbit
             ("no port name");
         my $width = $port->{width};
         my $tristate_width = $width;
         my $type  = $port->{type} || $port->{avalon_role};
         my $is_shared = $port->{is_shared};

         my $exclusive_port_name =
             &get_exclusively_named_port($port_name);

         e_signal->new([$exclusive_port_name => $width])
             ->within($gp->top());

         next unless $type; #port lives completely externally of the module
         next if ($type =~ /^clk/);
         next if ($type =~ /^reset/);

         my $slave_direction = $port->{direction};


         my $name_filler;
         my $re_direction = $slave_direction;
         if ($re_direction =~ s/^input$/output/i)
         {
            $name_filler = "_to_the_";
         }
         elsif ($re_direction =~ s/^output$/input/i)
         {
            $name_filler = "_from_the_";
         }

         my $tristate_port_name;
         if ($is_shared)
         {
            $tristate_port_name = join ("_", $this_module_name,
                                        $type);

            $tristate_port_name =~ s/\_n$/n/;
         }
         else
         {
            $tristate_port_name = 
                $port_name.$name_filler.$slave->{module_name};
         }

         if ($re_direction eq "output")
         {
            my $p1 = &get_exclusively_named_port
                ("p1_$tristate_port_name");
            my $mux_value = $exclusive_port_name;
            if ($type =~ /^address/)
            {
               my $slave_dw =
                   $slave->{slave_hash}{SYSTEM_BUILDER_INFO}
               {Data_Width}
               or &ribbit ("no data width for $slave_name");

               my $shift_amount;
               if ($slave_dw <= 8)
               {
                  $shift_amount = 0; 
               }
               elsif ($slave_dw <= 16)
               {
                  $shift_amount = 1;
               }
               elsif ($slave_dw <= 32)
               {
                  $shift_amount = 2;
               }
               else
               {
                  &ribbit ("$slave_name data width ($slave_dw)",
                           "is greater than 32 bits");
               }
               if ($shift_amount)
               {
                  $mux_value = "$mux_value << $shift_amount";
                  $tristate_width += $shift_amount;
               }
            }

            elsif ($type =~ /^write(_n)?$/i)
            {
               my $write_sig = (($1)? "~":"").$p1;
               $gp->top()->get_and_set_thing_by_name
                   ({
                      thing => "mux",
                      name  => "p1_write_to_control_writestate mux",
                      lhs   => [p1_write_to_control_tristate => 1],
                      add_table_ref => [$slave_select,
                                        $write_sig],
                });

               $gp->top()->get_and_set_once_by_name
                   ({
                      name     => "tristate enable register",
                      thing    => "register",
                      out      => [write_to_control_tristate => 1],
                      in       => "p1_write_to_control_tristate",
                      enable   => 1,

                   });
            }

            $gp->top()->get_and_set_thing_by_name
                ({
                   thing => "mux",
                   comment => "$tristate_port_name",
                   name  => "$tristate_port_name mux",
                   lhs   => $p1,
                   add_table_ref => [$slave_select,
                                     $mux_value],
                });

            my $async_value = ($type =~ /_n$/)? -1:0;
            my $in = $p1;
            $gp->top()->get_and_set_thing_by_name
                ({
                   thing    => "register",
                   async_value => $async_value,
                   fast_out => 1,
                   comment  => "FastOut register for $type",
                   name     => "$tristate_port_name register",
                   in       => $p1,
                   out      => $tristate_port_name,
                   reset    => "reset_n",
                   enable   => 1,
                });
         }
         if ($re_direction eq "input")
         {
            e_register->new({
               in      => [$tristate_port_name  => $width],
               out     => [$exclusive_port_name => $width],
               fast_in => 1,
               enable  => 1,
            })->within($gp->top());
         }

         if ($re_direction eq "inout")
         {
            die ("dir: inout is illegal for $port_name, of $type\n")
                unless ($type eq "data");

            &add_to_module_port_wiring_and_declare_signal
                ($tristate_port_name,
                 {direction => $re_direction,
                  width     => $width}
                 );

            $gp->top()->get_and_set_thing_by_name
            ({
               name  => "tristate drive enable",
               thing => "assign",
               lhs   => $tristate_port_name,
               rhs   => "write_to_control_tristate? tristate_writedata :".
                   "{tristate_writedata.width{1\'bz}}",
                });

            my $write_unique =
                &get_exclusively_named_port("write_data");
            my $read_unique =
                &get_exclusively_named_port("read_data");

            $gp->top()->get_and_set_once_by_name
                ({
                   thing   => "register",
                   fast_in => 1,
                   comment => "FastIn register for readdata",
                   name    => "$tristate_port_name register",
                   in      => $tristate_port_name,
                   out     => "tristate_readdata",
                   reset   => "reset_n",
                   enable  => 1,
                });

            e_assign->new([[$read_unique => $width], 
                           "tristate_readdata"
                          ])->within($gp->top());

            $gp->top()->get_and_set_thing_by_name
                ({
                   name  => "tristate_writedata muxarooni",
                   thing => "mux",
                   lhs   => "p1_tristate_writedata",
                   add_table_ref => [$slave_select, 
                                     [$write_unique => $width]
                                     ],
                });

            $gp->top()->get_and_set_thing_by_name
                ({
                   name  => "tristate_writedata register",
                   thing => "register",
                   out   => "tristate_writedata",
                   in    => "p1_tristate_writedata",
                   enable   => 1,
                   fast_out => 1,
                });

            $module_ptf->{"SLAVE $slave_unique_name"}
            {PORT_WIRING}{"PORT $write_unique"} =
            { 
               direction => "input",
               width     => $width,
               type      => "writedata",
            };

            $module_ptf->{"SLAVE $slave_unique_name"}
            {PORT_WIRING}{"PORT $read_unique"} =
            { 
               direction => "output",
               width     => $width,
               type      => "readdata",
            };
         }
         else
         {
            &add_to_module_port_wiring_and_declare_signal
                ($tristate_port_name,
                 {direction => $re_direction,
                  width     => $tristate_width}
                 );

            $module_ptf->{"SLAVE $slave_unique_name"}
            {PORT_WIRING}{"PORT $exclusive_port_name"} =
            { 
               direction => $slave_direction,
               width     => $width,
               type      => $type,
            };

            e_signal->new
                ({
                   name => $slave_unique_name,
                   width => $width,
                   copied => 1,
                })->within($gp->top());
         }
      }



      my $slave_spaced_sbi = $slave->{slave_hash}{SYSTEM_BUILDER_INFO};

      my %slave_sbi = %$slave_spaced_sbi;

      $slave_sbi{Read_Latency}       += 2;
      $slave_sbi{Bus_Type}            = "Avalon";
      
      $module_ptf->{"SLAVE $slave_unique_name"}->
      {SYSTEM_BUILDER_INFO} = \%slave_sbi;



      my $spaceless_masters = 
          $gp->spaceless_module_ptf()
               ->{SLAVE}{avalon_slave}
               ->{SYSTEM_BUILDER_INFO}
               ->{MASTERED_BY};

      foreach my $master (keys %$spaceless_masters)
      {
         $slave_sbi{"MASTERED_BY $master"} = 
             $module_ptf->{"SLAVE avalon_slave"}->
             {SYSTEM_BUILDER_INFO}{"MASTERED_BY $master"};
      }

      my $old_imb = "MASTERED_BY $this_module_name/tristate_master";
      delete $slave_sbi{$old_imb};   

      my $mod_ptf = $gp->ptf_hash->
      {"SYSTEM ".$gp->_system_name()}
      {"MODULE $slave->{module_name}"};

      delete $mod_ptf->{"SLAVE $slave->{slave_name}"};


      my $spaceless_mod = $gp->spaceless_system_ptf()->
      {MODULE};

      delete
          $spaceless_mod->{$slave->{module_name}}{SLAVE}{$slave->{slave_name}};

      die "MODULE $slave->{module_name} has more than one slave ",
      "(and/or) master, which is not allowed for the tri-state data bus\n"
          if (keys (%{$spaceless_mod->{SLAVE}}) + 
              keys (%{$spaceless_mod->{MASTER}})
              );
      delete $gp->system_ptf()->{"MODULE $slave->{module_name}"};

      unless ($added_clock_and_reset)
      {
         &add_clock_and_reset($module_ptf->{"SLAVE $slave_unique_name"}
                              {PORT_WIRING});
      }
      $added_clock_and_reset = 1;





   }
}









sub add_to_module_port_wiring_and_declare_signal
{
   my $name = shift or &ribbit ("no name");
   my $p_hash = shift or &ribbit ("no hash");

   $p_hash->{_do_not_rename} = 1;

   my $gp               = $GLOBAL_PROJECT;
   my $module_ptf       = $gp->module_ptf();
   my $this_module_name = $gp->_target_module_name();

   my $width = $p_hash->{width};
   my $direction = $p_hash->{direction};
   my $old_width = 
       $module_ptf->{PORT_WIRING}
   {"PORT $name"}{width};
   
   if ($width > $old_width)
   {
      $module_ptf->{PORT_WIRING}{"PORT $name"}
      = $p_hash;

      my $is_inout = 0;

      $is_inout = 1
          if ($direction =~ /inout/);
      e_signal->new
          ({
             name => $name,
             width => $width,
             copied => 1,
             _is_inout => $is_inout,
          })->within($gp->top());
   }
}
sub add_clock_and_reset
{
   my $gp               = $GLOBAL_PROJECT;
   my $port_wiring      = shift;

   $port_wiring->{"PORT clk"}
   = { direction => "input",
       width     => 1,
       type      => "clk",
    };

   $port_wiring->{"PORT reset_n"}
   = { direction => "input",
       width     => 1,
       type      => "reset_n",
    };

   e_signal->new([clk     => 1])->within($gp->top);
   e_signal->new([reset_n => 1])->within($gp->top);

}

sub get_module_name
{
   my $slave = shift or die ("no slaves");
   my $module_name = $slave->{module_name};
   return ($module_name);
}

sub find_my_slaves
{
   my $gp = $GLOBAL_PROJECT;
   my $sys_hash =
       $gp->spaceless_ptf_hash->{SYSTEM}{$gp->_system_name()} or
           die ("could not find system hash");

   my @my_slaves;
   my @modules = keys %{$sys_hash->{MODULE}};

   my $module_name = $gp->_target_module_name();

   foreach my $module (@modules)
   {
      next if ($module eq $module_name);
      my $slave_hash = $sys_hash->{MODULE}{$module}{SLAVE};
      my @slaves = keys (%$slave_hash);

      foreach my $slave_name (@slaves)
      {
         my @is_mastered_by = keys
             (%{$slave_hash->{$slave_name}->{SYSTEM_BUILDER_INFO}{MASTERED_BY}});
         foreach my $imb (@is_mastered_by)
         {
            my $spaced_slave_hash = $gp->system_ptf()->
            {"MODULE $module"}{"SLAVE $slave_name"};
            if ($imb eq "$module_name/tristate_master")
            {
               my $p_hash = 
               {
                  module_name => $module, 
                  slave_name  => $slave_name,
                  slave_hash  => $spaced_slave_hash,#$slave_hash->{$slave_name},
                  ports       =>
                      $slave_hash->{$slave_name}{PORT_WIRING}{PORT},
               };
               push (@my_slaves, $p_hash);
            }
         }
      }
   }
   
   return (@my_slaves);
}

sub clean_up_and_add_signals
{
   my $gp = $GLOBAL_PROJECT;   
   my $module_ptf = $gp->module_ptf();
   my $module_name = $gp->top()->name();
   my $port_name = "${module_name}_data";

   my $width = $module_ptf->{PORT_WIRING}
   {"PORT $port_name"}{width}
   or &ribbit ("could not find $port_name in ptf\n",
               join ("\n",keys (%{$module_ptf->{PORT_WIRING}})));

   e_signal->new([tristate_writedata => $width])
       ->within($gp->top());
   e_signal->new([p1_tristate_writedata => $width])
       ->within($gp->top());
   e_signal->new([tristate_readdata => $width])
       ->within($gp->top());
   
   delete $gp->module_ptf()->{"MASTER tristate_master"};
   delete $gp->module_ptf()->{"SLAVE avalon_slave"};
}

sub copy_hash
{
   my $hash = shift or &ribbit ("no_hash");
   ref ($hash) eq "HASH" 
       or &ribbit ("$hash is not a hash");

   my %new_hash = %$hash;

   foreach my $key (keys (%new_hash))
   {
      my $value = $new_hash{$key};
      $new_hash{$key} = &copy_hash($value)
          if (ref ($value) eq "HASH");
   }
   return (\%new_hash);
}



$GLOBAL_PROJECT->handle_args(@ARGV);

my $gp = $GLOBAL_PROJECT;


$exclusively_named_port{clk}++;
$exclusively_named_port{reset_n}++;
$exclusively_named_port{p1_write_to_control_tristate}++;
$exclusively_named_port{write_to_control_tristate}++;
$exclusively_named_port{tristate_readdata}++;
$exclusively_named_port{tristate_writedata}++;
$exclusively_named_port{p1_tristate_writedata}++;



$gp->ptf_hash()->{__REPLACE__THIS__} = &copy_hash($gp->ptf_hash());

my $sys_hash = $gp->spaceless_ptf_hash->{SYSTEM}{$gp->_system_name()}
or die ("can't find sys hash");

$gp->top()->do_ptf(0); #we'll do ptf mods ourselves, thank you very much.

my $mod_hash = $sys_hash->{MODULE}{$gp->_target_module_name()} or
    die ("can't find mod hash");

my @slave_tristates = &find_my_slaves();





&build_mirrors (
                [@slave_tristates]
                );


&clean_up_and_add_signals();

$gp->output();
