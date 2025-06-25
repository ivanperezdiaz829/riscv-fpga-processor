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




























use e_std_synchronizer;
use europa_all;
use strict;


my $Read_Wait_States = 1;
my $Write_Wait_States = 1;
my $Address_Width = 3;

my $Data_Width = 16;


my $default_databits      = "8";
my $default_targetclock   = "128";
my $default_clockunits   = "kHz";
my $default_numslaves     = "1";
my $default_ismaster      = "1";
my $default_clockpolarity = "0";
my $default_clockphase    = "0";
my $default_sync_reg_depth = "2";
my $default_insert_sync   = "0";
my $default_lsbfirst      = "0";
my $default_extradelay    = "0";
my $default_targetssdelay = "100";
my $default_delayunits   = "us";
my $default_disableAvalonFlowControl = "0";

my $INPUT_CLOCK;
my $ISMASTER;
my $DATABITS;
my $TARGETCLOCK;
my $NUMSLAVES;
my $CPOL;
my $CPHA;
my $LSBFIRST;
my $EXTRADELAY;
my $TARGETSSDELAY;
my $NOAVALONFLOWCONTROL;
my $DEPTH; 
my $INSERT_SYNC; 
my $SYNC_REG_DEPTH;
my $DATA_WIDTH;
my $ALLOW_LEGACY_SIGNALS;
my $clock_freq;     
  

my $default_clockmult;
($default_clockmult = $default_clockunits) =~ s/Hz//;
$default_clockmult = unit_prefix_to_num($default_clockmult);

my $default_delaymult;
($default_delaymult = $default_delayunits) =~ s/s//;
$default_delaymult = unit_prefix_to_num($default_delaymult);

my $prefix = 'spi_';

sub validate_SPI_parameters
{
  my ($Options) = @_;

  validate_parameter ({
    hash => $Options,
    name => "ismaster",
    type => "boolean",
    default => $default_ismaster,
  });
  
  validate_parameter ({
    hash => $Options,
    name => "databits",
    type => "integer",
    range   => [1,32],
    default => $default_databits,
  });
  
  validate_parameter ({
    hash => $Options,
    name => "targetclock",
    type => "string",
    default => $default_targetclock,
  });
  
  validate_parameter ({
    hash => $Options,
    name => "numslaves",
    type => "integer",
    range => [1, 32],
    default => $default_numslaves,
  });
  
  validate_parameter ({
    hash => $Options,
    name => "clockpolarity",
    type => "boolean",
    default => $default_clockpolarity,
  });
  
  validate_parameter ({
    hash => $Options,
    name => "clockphase",
    type => "boolean",
    default => $default_clockphase,
  });

  validate_parameter ({
    hash => $Options,
    name => "sync_reg_depth",
    type => "integer",
    allowed => [2, 3, 4, 5],
    default => $default_sync_reg_depth,
    message => "invalid synchronizer depth",
  });

  validate_parameter ({
    hash => $Options,
    name => "insert_sync",
    type => "boolean",
    default => $default_insert_sync,
  });

  validate_parameter ({
    hash => $Options,
    name => "lsbfirst",
    type => "boolean",
    default => $default_lsbfirst,
  });

  validate_parameter ({
    hash => $Options,
    name => "extradelay",
    type => "boolean",
    default => $default_extradelay,
  });
  
  validate_parameter ({
    hash => $Options,
    name => "targetssdelay",
    type => "string",
    default => $default_targetssdelay,
  });

  validate_parameter ({
    hash => $Options,
    name => "delayunit",
    type => "string",
    default => $default_delayunits,
    allowed => ["s", "ms", "us", "ns"],
  });


  validate_parameter ({
    hash => $Options,
    name => "clockunit",
    type => "string",
    allowed => ["Hz", "kHz", "MHz", ],
    default => $default_clockunits,
  });
  
  validate_parameter ({
    hash => $Options,
    name => "prefix",
    type => "string",
    default => 'spi_',
  });
  
  validate_parameter ({
    hash => $Options,
    name => "disableAvalonFlowControl",
    type => "boolean",
    default => $default_disableAvalonFlowControl,
  });
}

sub make_spi
{
	
  my ($project, $Opt, $module) = (@_);
	













  
  





  validate_SPI_parameters($Opt);

  my $delay_unit;                                          
  $prefix = $Opt->{prefix};
  
  ($delay_unit = $Opt->{delayunits}) =~ s/s//g;
  $Opt->{delaymult} = unit_prefix_to_num($delay_unit);

  my $clock_unit;
  ($clock_unit = $Opt->{clockunits}) =~ s/Hz//g;
  $Opt->{clockmult} = unit_prefix_to_num($clock_unit);
  



  $INPUT_CLOCK = $Opt->{inputClockRate};
  $INPUT_CLOCK = ($INPUT_CLOCK == 0) ? 1 : $INPUT_CLOCK;
  $ISMASTER = $Opt->{ismaster};
  $DATABITS = $Opt->{databits};
  $TARGETCLOCK = $Opt->{targetclock} * $Opt->{clockmult};
  $NUMSLAVES = $Opt->{numslaves};
  $CPOL = $Opt->{clockpolarity};
  $CPHA = $Opt->{clockphase};
  $LSBFIRST = $Opt->{lsbfirst};
  $EXTRADELAY = $Opt->{extradelay};
  $TARGETSSDELAY = $Opt->{targetssdelay} * $Opt->{delaymult};
  $NOAVALONFLOWCONTROL = $Opt->{disableAvalonFlowControl};
  $INSERT_SYNC = $Opt->{insert_sync};
  $SYNC_REG_DEPTH = $Opt->{sync_reg_depth};
  $DATA_WIDTH = $Opt->{datawidth};
  $ALLOW_LEGACY_SIGNALS = $Opt->{allow_legacy_signals};
  $clock_freq = $INPUT_CLOCK;        



  if (exists $Opt->{insert_sync} & exists $Opt->{sync_reg_depth}) {
    if ($INSERT_SYNC) {
      $DEPTH = $SYNC_REG_DEPTH;
    } else {
      $DEPTH = "1";
    }
  } else {
    $DEPTH = "1";
  }





  if (exists $Opt->{datawidth}) {
    $Data_Width = $DATA_WIDTH;
  }
  









  my $div = $clock_freq / $TARGETCLOCK;


  if (int($div) != $div)
  {
    $div = int($div);
    $div++;
  }



  $div++ if ($div & 1);



  $div = 2 if ($div < 2);
  my $CLOCKDIV = $div;


  if ($CLOCKDIV & 1 or $CLOCKDIV < 2)
  {
    ribbit("Bogus CLOCKDIV ($CLOCKDIV): CLOCKDIV must be even");
  }






  my $ss_delay_quantum = $CLOCKDIV / $clock_freq / 2;
  my $DELAYAFTERSS;

  if ($EXTRADELAY)
  {

    my $numSSQuanta = $TARGETSSDELAY / $ss_delay_quantum;


    if (int($numSSQuanta) != $numSSQuanta)
    {
      $numSSQuanta = int($numSSQuanta);
      $numSSQuanta++;
    }


    if ($numSSQuanta < 1)
    {
      $numSSQuanta = 1;
    }

    $DELAYAFTERSS = $numSSQuanta;
  }
  else
  {


    $DELAYAFTERSS = 1;
  }

  my $EXTRADELAYAFTERSS = $DELAYAFTERSS - 1;
  if ($DELAYAFTERSS < 1)
  {
    ribbit("Bogus parameter: DELAYAFTERSS: $DELAYAFTERSS.");
  }

  my $clockDivWithDiv2 = $CLOCKDIV / 2;
  my $lastDataBit = $DATABITS - 1;


  my @port_list = (
    e_port->new({name => "clk",                        type => "clk",}),
    e_port->new({name => "reset_n",                    type => "reset_n",}),
    e_port->new({name => "${prefix}select",                 type => "chipselect",}),
    e_port->new({name => "mem_addr",       width => 3, type => "address", }),
    e_port->new({name => "write_n",                    type => "write_n",}),
    e_port->new({name => "read_n",                     type => "read_n",}),
    e_port->new({name => "data_from_cpu", width => $Data_Width, type => "writedata",}),
    e_port->new({name => "data_to_cpu",   width => $Data_Width, type => "readdata",      direction => "output",}),
    e_port->new({name => "irq",                        type => "irq",           direction => "output",}),
  );
  $module->add_contents(@port_list);
  
  if (!$NOAVALONFLOWCONTROL)
  {
  my @flow_control_port_list = (
    e_port->new({name => "dataavailable",              type => "dataavailable", direction => "output",}),
    e_port->new({name => "readyfordata",               type => "readyfordata",  direction => "output",}),
    e_port->new({name => "endofpacket",                type => "endofpacket",   direction => "output",}),
  );
      $module->add_contents(@flow_control_port_list);
  }




  my $data_from_cpu_for_eop_purposes = "data_from_cpu";
  if ($Data_Width > $DATABITS)
  {
    $data_from_cpu_for_eop_purposes =
      sprintf("data_from_cpu[%d : 0]", $DATABITS - 1);
  }
  

  my %type_map = ();
  for (@port_list)
  {
    $type_map{$_->name()} = $_->type();
  }


  $module->add_contents(
    e_avalon_slave->new({
      name => "${prefix}control_port",
      type_map => \%type_map,
    })
  );

  if ($ISMASTER)
  {

    $module->add_contents(
      e_port->new({name => "MOSI", width => 1, direction => "output"}),
      e_port->new({name => "MISO", width => 1, direction =>  "input"}),
      e_port->new({name => "SCLK", width => 1, direction => "output"}),
      e_port->new({name => "SS_n", width => $NUMSLAVES, direction => "output"}),
    );
  }
  else
  {

    $module->add_contents(
      e_port->new(["MOSI", 1,  "input"]),
      e_port->new(["MISO", 1, "output"]),
      e_port->new(["SCLK", 1,  "input"]),
      e_port->new(["SS_n", 1, "input"]),
    );
  }


  my $readDatamem_addr = 0;
  my $writeDatamem_addr = 1;
  my $statusmem_addr = 2;
  my $controlmem_addr = 3;
  my $reservedmem_addr = 4;
  my $slaveSelectmem_addr = 5;
  my $endOfPacketValuemem_addr = 6;
  my $last_reg = 6;

  if (ceil(log2($last_reg)) != $Address_Width)
  {
    ribbit(
      "Mismatch: Address_Width: $Address_Width, but last reg is $last_reg");
  }

  $module->{comment} .= "Register map:\n";
  $module->{comment} .= "addr      register      type\n";
  $module->{comment} .= "$readDatamem_addr         read data     r\n";
  $module->{comment} .= "$writeDatamem_addr         write data    w\n";
  $module->{comment} .= "$statusmem_addr         status        r/w\n";
  $module->{comment} .= "$controlmem_addr         control       r/w\n";

  if ($ISMASTER)
  {
    $module->{comment} .= "$reservedmem_addr         reserved\n";
    $module->{comment} .= "$slaveSelectmem_addr         slave-enable  r/w\n";
  }


  $module->{comment} .= "$endOfPacketValuemem_addr         end-of-packet-value r/w\n";


  $module->{comment} .= "\n";

  $module->{comment} .= "INPUT_CLOCK: $INPUT_CLOCK\n";
  $module->{comment} .= "ISMASTER: $ISMASTER\n";
  $module->{comment} .= "DATABITS: $DATABITS\n";
  $module->{comment} .= "TARGETCLOCK: $TARGETCLOCK\n";
  $module->{comment} .= "NUMSLAVES: $NUMSLAVES\n";
  $module->{comment} .= "CPOL: $CPOL\n";
  $module->{comment} .= "CPHA: $CPHA\n";
  $module->{comment} .= "LSBFIRST: $LSBFIRST\n";
  $module->{comment} .= "EXTRADELAY: $EXTRADELAY\n";
  $module->{comment} .= "TARGETSSDELAY: $TARGETSSDELAY\n";






  if ($Read_Wait_States == 1)
  {
    $module->add_contents(
      e_assign->new({
        lhs => ["p1_rd_strobe", 1, 0, 1],
        rhs => "~rd_strobe & ${prefix}select & ~read_n",
      }),
      e_register->new({
        comment => " Read is a two-cycle event.",
        enable => 1,
        async_value => 0,
        in => "p1_rd_strobe",
        out => e_signal->new(["rd_strobe", 1, 0, 1]),
      }),
      e_assign->new({
        lhs => ["p1_data_rd_strobe", 1, 0, 1],
        rhs => "p1_rd_strobe & (mem_addr == $readDatamem_addr)",
      }),
      e_register->new({
        enable => 1,
        async_value => 0,
        out => e_signal->new(["data_rd_strobe", 1, 0, 1]),
        in => "p1_data_rd_strobe",
      }),
    );
  }
  else
  {
    ribbit("Expected Read_Wait_States = 1, got $Read_Wait_States");
  }

  if ($Write_Wait_States == 1)
  {
    $module->add_contents(
      e_assign->new({
        lhs => ["p1_wr_strobe", 1, 0, 1],
        rhs => "~wr_strobe & ${prefix}select & ~write_n",
      }),
      e_register->new({
        comment => " Write is a two-cycle event.",
        enable => 1,
        async_value => 0,
        out => ["wr_strobe", 1, 0, 1],
        in => "p1_wr_strobe",
      }),
      e_assign->new({
        lhs => ["p1_data_wr_strobe", 1, 0, 1],
        rhs => "p1_wr_strobe & (mem_addr == $writeDatamem_addr)",
      }),
      e_register->new({
        enable => 1,
        async_value => 0,
        out => ["data_wr_strobe", 1, 0, 1],
        in => "p1_data_wr_strobe",
      }),
    );
  }
  else
  {
    ribbit("Expected Write_Wait_States = 1, got $Write_Wait_States");
  }

  $module->add_contents(
    e_assign->new({
      lhs => e_signal->new(["control_wr_strobe", 1, 0, 1]),
      rhs => "wr_strobe & (mem_addr == $controlmem_addr)",
    })
  );

  $module->add_contents(
    e_assign->new({
      lhs => e_signal->new(["status_wr_strobe", 1, 0, 1]),
      rhs => "wr_strobe & (mem_addr == $statusmem_addr)",
    })
  );

  if ($ISMASTER)
  {
    $module->add_contents(
      e_assign->new({
        lhs => e_signal->new(["slaveselect_wr_strobe", 1, 0, 1]),
        rhs => "wr_strobe & (mem_addr == $slaveSelectmem_addr)",
      })
    );
  }
  $module->add_contents(
    e_assign->new({
      lhs => e_signal->new(["endofpacketvalue_wr_strobe", 1, 0, 1]),
      rhs => "wr_strobe & (mem_addr == $endOfPacketValuemem_addr)",
    })
  );


  my $numStatusAndControlBits = 11;
  my %status_and_control_bits = (
    SSO  => 10,
    EOP  => 9,
    E    => 8,
    RRDY => 7,
    TRDY => 6,
    TMT  => 5,
    TOE  => 4,
    ROE  => 3,
  );
  my $SSO_bit = 10;
  my $EOP_bit = 9;
  my $E_bit    = 8;
  my $RRDY_bit = 7;
  my $TRDY_bit = 6;
  my $TMT_bit  = 5;
  my $TOE_bit  = 4;
  my $ROE_bit  = 3;








  if ($ISMASTER)
  {
    $module->add_contents(
      e_assign->new({
        comment => "",
        lhs => e_signal->new({
          name => "TMT",
          never_export => 1,
        }),
        rhs => "~transmitting & ~tx_holding_primed",
      })
    );
  }
  else
  {

    $module->add_contents(
      e_assign->new({
        lhs => e_signal->new({
          name => "TMT",
          never_export => 1,
        }),
        rhs => "SS_n & TRDY",
      })  
    );
  }







  $module->add_contents(
    e_assign->new({
      lhs => e_signal->new({
        name => "E",
        never_export => 1,
      }),
      rhs => "ROE | TOE",
    })
  );

  $module->add_contents(
    e_assign->new({
      lhs => e_signal->new({
        name => "${prefix}status",
        never_export => 1,
        width => $numStatusAndControlBits,
      }),
      rhs => "{EOP, E, RRDY, TRDY, TMT, TOE, ROE, 3'b0}",
    })
  );



  if (!$NOAVALONFLOWCONTROL)
  {
      $module->add_contents(
        e_assign->new({
          comment => " Streaming data ready for pickup.",
          lhs => "dataavailable",
          rhs => "RRDY"
        }),
        e_assign->new({
          comment => " Ready to accept streaming data.",
          lhs => "readyfordata",
          rhs => "TRDY"
        }),
        e_assign->new({
          comment => " Endofpacket condition detected.",
          lhs => "endofpacket",
          rhs => "EOP"
        }),
      );
  }











  my $interrupt_enable_process = e_process->new();

  my $interrupt_enable_if = e_if->new({condition => "control_wr_strobe"});
  for (sort {$status_and_control_bits{$b} cmp $status_and_control_bits{$a}} keys %status_and_control_bits)
  {
    my $regname = "i" . $_ . "_reg";
    
    if ($_ eq 'SSO')
    {
      next if !$ISMASTER;  # Slaves have no SSO_reg bit.
      

      $regname = 'SSO_reg';
    }
    
    my $regindex = $status_and_control_bits{$_};

    push @{$interrupt_enable_if->then()},
      e_assign->new({
        lhs => e_signal->new({
          name => $regname,
          never_export => 1,
        }),
        rhs => "data_from_cpu[$regindex]",
      });

    push @{$interrupt_enable_process->asynchronous_contents()},
      e_assign->new([$regname, 0]);
  }


  push @{$interrupt_enable_process->contents()}, $interrupt_enable_if;


  $module->add_contents($interrupt_enable_process);


  my @control_reg_bits = qw(
    iEOP_reg iE_reg iRRDY_reg iTRDY_reg 1'b0 iTOE_reg iROE_reg 3'b0  
  );
  unshift @control_reg_bits, 'SSO_reg' if $ISMASTER;
  my $control_reg_rhs = "{" . join(", ", @control_reg_bits) . "}";
  $module->add_contents(
    e_assign->new({
      lhs => e_signal->new([$prefix . "control", $numStatusAndControlBits]),
      rhs => $control_reg_rhs,
    })
  );


  $module->add_contents(
    e_register->new({
      comment => " IRQ output.",
      in =>
        "(EOP & iEOP_reg) | " .
        "((TOE | ROE) & iE_reg) | " .
        "(RRDY & iRRDY_reg) | " .
        "(TRDY & iTRDY_reg) | " .
        "(TOE & iTOE_reg) | " .
        "(ROE & iROE_reg)",
      out => e_signal->new({
        name => "irq_reg",
        never_export => 1,
      }),
      enable => 1,
    })
  );

  $module->add_contents(
    e_assign->new(["irq", "irq_reg"])
  );


  if ($ISMASTER)
  {

    $module->add_contents(
      e_register->new({
        comment => " Slave select register.",


        enable => "write_shift_reg || " .
          "control_wr_strobe & data_from_cpu[10] & ~SSO_reg",
        in => "${prefix}slave_select_holding_reg",
        out => e_signal->new({
          name => "${prefix}slave_select_reg",
          never_export => 1,
          width => $NUMSLAVES,
        }),

        async_value => 1,
      })
    );

    $module->add_contents(
      e_register->new({
        comment => " Slave select holding register.",
        enable => "slaveselect_wr_strobe",
        in => "data_from_cpu",
        out => e_signal->new({
            name => "${prefix}slave_select_holding_reg",
            never_export => 1,
            width => $NUMSLAVES,
        }),

        async_value => 1,
      })
    );


    if ($clockDivWithDiv2 == 1)
    {
      $module->add_contents(
        e_assign->new({
          comment => " SPI clock is sys_clk/2.",
          lhs => e_signal->new(["slowclock"]),
          rhs => 1,
        })
      );
    }
    else
    {
      my $terminal_slowcount_value =
        sprintf("%d'h%X", Bits_To_Encode($clockDivWithDiv2), $clockDivWithDiv2 - 1);
      $module->add_contents(
        e_assign->new({
          comment => " slowclock is active once every $clockDivWithDiv2 system clock pulses.",
          lhs => e_signal->new(["slowclock"]),
          rhs => "slowcount == $terminal_slowcount_value",
        })
      );

      $module->add_contents(
        e_mux->new({
          out => e_signal->new([
            "p1_slowcount",
            Bits_To_Encode($clockDivWithDiv2)
          ]),
          type => "and-or",
          table => ["transmitting && !slowclock", "slowcount + 1",],
          default => 0,
        }),
      );
      $module->add_contents(
        e_register->new({
          enable => 1,
          comment => " Divide counter for SPI clock.",
          in => "p1_slowcount", # "transmitting & ~slowclock & (slowcount + 1)",
          out => e_signal->new([
            "slowcount",
            Bits_To_Encode($clockDivWithDiv2)
          ]),
        })
      );
    }
  } # ISMASTER


  $module->add_contents(
    e_register->new({
      comment => " End-of-packet value register.",
      enable => "endofpacketvalue_wr_strobe",
      in => "data_from_cpu",
      out => e_signal->new({
        name => "endofpacketvalue_reg",
        never_export => 1,
        width => $DATABITS,
      }),
      async_value => 0,
    })
  );




  my @muxtable = (
    "(mem_addr == $statusmem_addr)", "${prefix}status",
    "(mem_addr == $controlmem_addr)", "${prefix}control",
    "(mem_addr == $endOfPacketValuemem_addr)", "endofpacketvalue_reg"
  );

  if ($ISMASTER)
  {
    push @muxtable, (
      "(mem_addr == $slaveSelectmem_addr)", "${prefix}slave_select_reg"
    );
  }

  $module->add_contents(
    e_mux->new({
      lhs => e_signal->new(["p1_data_to_cpu", $Data_Width]),
      table => \@muxtable,
      default => "rx_holding_reg",
    })
  );

  push @{$module->{contents}},
    e_process->new({
      asynchronous_contents => [
        e_assign->new({
          lhs => e_signal->new(["data_to_cpu", $Data_Width]),
          rhs => 0,
        }),
      ],
      contents => [
        e_assign->new({
          comment => " Data to cpu.",
          lhs => "data_to_cpu",
          rhs => "p1_data_to_cpu",
        }),
      ],
    });

    e_register->new({
      enable => 1,
      comment => " Data to cpu.",
      in => "p1_data_to_cpu",
      out => e_signal->new(["data_to_cpu", $Data_Width]),
    });

  if ($ISMASTER)
  {
    my $numStates = 2 * $DATABITS + 2;
    my $lastState = $numStates - 1;

    if ($EXTRADELAYAFTERSS)
    {

      $module->add_contents(
        e_process->new({
          comment => " Extra-delay counter.",
          contents => [
            e_if->new({



              condition => "write_shift_reg",
              then => [e_assign->new({
                lhs => "delayCounter",
                rhs => $EXTRADELAYAFTERSS,
              })],
              else => [],
            }),
            e_if->new({
              condition => "transmitting & slowclock & (delayCounter != 0)",
              then => [e_assign->new({
                lhs => "delayCounter",
                rhs => "delayCounter - 1",
              })],
              else => [],
            }),
          ],
          asynchronous_contents => [
            e_assign->new({
              lhs => e_signal->new({
                name => "delayCounter",
                width => Bits_To_Encode($EXTRADELAYAFTERSS),
              }),
              rhs => $EXTRADELAYAFTERSS,
            }),
          ],
        })
      );

      $module->add_contents(
        e_process->new({
            comment => " 'state' counts from 0 to $lastState.",
            contents => [
              e_if->new({
                condition => "transmitting & slowclock & (delayCounter == 0)",
                then => [
                  e_if->new({
                    condition => "(state == $lastState)",
                    then => [e_assign->new(["state", 0])],
                    else => [e_assign->new(["state", "state + 1"])],
                  }),
                ],
                else => [],
              }),
            ],
            asynchronous_contents => [
              e_assign->new({
                lhs => e_signal->new(["state",Bits_To_Encode($lastState)]),
                rhs => 0
              }),
            ],
        })
      );

      $module->add_contents(
        e_assign->new({
          lhs => e_signal->new({
            name => "enableSS",
            never_export => 1,
          }),
          rhs => "transmitting & (delayCounter != $EXTRADELAYAFTERSS)",
        })
      );
    }
    else
    {

      $module->add_contents(
        e_process->new({
          comment => " 'state' counts from 0 to $lastState.",
          contents => [
            e_if->new({
              condition => "transmitting & slowclock",
              then => [
                e_assign->new(["stateZero", "(state == $lastState)",]),
                e_if->new({
                  condition => "(state == $lastState)",
                  then => [e_assign->new(["state", 0])],
                  else => [e_assign->new(["state", "state + 1"])],
                }),
              ],
              else => [],
            }),
          ],
          asynchronous_contents => [
            e_assign->new([
              e_signal->new(["state", Bits_To_Encode($lastState)]),
              0
            ]),
            e_assign->new([
              e_signal->new(["stateZero"]),
              1
            ]),
          ],
        })
      );

      $module->add_contents(
        e_assign->new({
          lhs => e_signal->new({
            name => "enableSS",
            never_export => 1,
          }),
          rhs => "transmitting & ~stateZero",
        })
      );
    }


    $module->add_contents(
      e_assign->new([
        "MOSI",
        $LSBFIRST ? "shift_reg[0]" : "shift_reg[$lastDataBit]",
      ])
    );

    $module->add_contents(
      e_assign->new([
        "SS_n",
        "(enableSS | SSO_reg) ? ~${prefix}slave_select_reg : {$NUMSLAVES {1'b1} }",
      ])
    );

    $module->add_contents(
      e_assign->new([
        "SCLK",
        "SCLK_reg",
      ])
    );

    my @async_contents = (
      e_assign->new({
        lhs => e_signal->new(["shift_reg", $DATABITS,]),
        rhs => 0
      }),
      e_assign->new({
        lhs => e_signal->new(["rx_holding_reg",$DATABITS]),
        rhs => 0
      }),
      e_assign->new({
        lhs => e_signal->new(["EOP"]),
        rhs => 0
      }),
      e_assign->new({
        lhs => e_signal->new(["RRDY"]),
        rhs => 0
      }),
      e_assign->new({
        lhs => e_signal->new(["ROE"]),
        rhs => 0
      }),
      e_assign->new({
        lhs => e_signal->new(["TOE"]),
        rhs => 0
      }),
      e_assign->new({
        lhs => e_signal->new(["tx_holding_reg", $DATABITS]),
        rhs => 0
      }),
      e_assign->new({
        lhs => e_signal->new(["tx_holding_primed"]),
        rhs => 0
      }),
      e_assign->new({
        lhs => e_signal->new(["transmitting"]),
        rhs => 0
      }),
      e_assign->new({
        lhs => e_signal->new(["SCLK_reg"]),
        rhs => $CPOL
      }),
    );

    if ($CLOCKDIV > 2)
    {
      push @async_contents,
        e_assign->new({
          lhs => e_signal->new(["MISO_reg"]),
          rhs => 0
        });
    }

    if ($CPHA)
    {
      push @async_contents,
        e_assign->new({
          lhs => e_signal->new(["transaction_primed"]),
          rhs => 0
        });
    }

    my @contents = ();



    $module->add_contents(
      e_assign->new({
        comment => " As long as there's an empty spot somewhere,\n" .
          "it's safe to write data.",
        lhs => e_signal->new(["TRDY",]),
        rhs => "~(transmitting & tx_holding_primed)",
      })
    );




    $module->add_contents(
      e_assign->new({
        comment => " Enable write to tx_holding_register.",
        lhs => e_signal->new(["write_tx_holding"]),
        rhs => "data_wr_strobe & TRDY",
      })
    );


    $module->add_contents(
      e_assign->new({
        comment => " Enable write to shift register.",
        lhs => e_signal->new(["write_shift_reg"]),
        rhs => "tx_holding_primed & ~transmitting",
      })
    );

    push @contents,
      e_if->new({
        condition => "write_tx_holding",
        then => [
          e_assign->new(["tx_holding_reg", "data_from_cpu"]),
          e_assign->new(["tx_holding_primed", 1]),
        ],
      });


    push @contents,
      e_if->new({
        condition => "data_wr_strobe & ~TRDY",
        then => [
          e_assign->new({
            comment => " You wrote when I wasn't ready.",
            lhs => "TOE",
            rhs => 1
          }),
        ],
      });

    push @contents,
      e_if->new({
        comment => " EOP must be updated by the last (2nd) cycle of access.",
        condition => 
          "(p1_data_rd_strobe && (rx_holding_reg == endofpacketvalue_reg)) || " .
          "(p1_data_wr_strobe && ($data_from_cpu_for_eop_purposes == endofpacketvalue_reg))",
        then => [
          e_assign->new(["EOP", 1]),
        ],
      });




    push @contents,
      e_if->new({
        condition => "write_shift_reg",
        then => [
          e_assign->new(["shift_reg", "tx_holding_reg"]),
          e_assign->new(["transmitting", 1]),
        ]
      });




    push @contents,
      e_if->new({
        condition => "write_shift_reg & ~write_tx_holding",
        then => [
          e_assign->new({
            comment => " Clear tx_holding_primed",
            lhs => "tx_holding_primed",
            rhs => 0
          }),
        ],
      });


    push @contents,
      e_if->new({
        condition => "data_rd_strobe",
        then => [
          e_assign->new({
            comment => " On data read, clear the RRDY bit.",
            lhs => "RRDY",
            rhs => "0"
          }),
        ],
      });



    push @contents,
      e_if->new({
        condition => "status_wr_strobe",
        then => [
          e_assign->new({
            comment => " On status write, clear all status bits (ignore the data).",
            lhs => "EOP",
            rhs => "0"
          }),
          e_assign->new(["RRDY", 0]),

          e_assign->new(["ROE",  0]),
          e_assign->new(["TOE",  0]),
        ],
      });

    if ($CPHA)
    {
      push @contents,
        e_if->new({
          condition => "transaction_primed",
        then => [
          e_assign->new(["transaction_primed", "0"]),
          e_assign->new({
            comment => "A transaction has just completed.  Shift the rx data into the " .
              "rx holding register, and flag the read overrun error if rx holding" .
              "was already occupied.",
            lhs => "transmitting",
            rhs => "0",
          }),
          e_assign->new(["RRDY", "1"]),
          e_assign->new({
            comment => " Transfer the rx data to the holding register.",
            lhs => "rx_holding_reg", rhs => "shift_reg",
          }),
          e_assign->new({
            comment => "This may be unnecessary...",
            lhs => "SCLK_reg", rhs => "$CPOL",
          }),
          e_if->new({
            condition => "RRDY",
            then => [
              e_assign->new(["ROE", "1"]),
            ],
          }),
        ],
      });
    }



    my $shiftRegExpression;
    my $MISOExpression;
    if ($CLOCKDIV > 2)
    {


      $MISOExpression = "MISO_reg";
    }
    else
    {


      $MISOExpression = "ds_MISO";
    }
    
    $shiftRegExpression = "$MISOExpression"; # True if $DATABITS == 1.
    if ($LSBFIRST)
    {
      if ($DATABITS == 2)
      {
        $shiftRegExpression = "{$MISOExpression, shift_reg[1]}";
      }
      elsif ($DATABITS > 2)
      {
        $shiftRegExpression = "{$MISOExpression, shift_reg[$lastDataBit : 1]}";
      }
    }
    else
    {
      if ($DATABITS == 2)
      {
        $shiftRegExpression = "{shift_reg[0], $MISOExpression}";
      }
      elsif ($DATABITS > 2)
      {
        my $dataBit2 = $DATABITS - 2;
        $shiftRegExpression = "{shift_reg[$dataBit2 : 0], $MISOExpression}";
      }
    }

    push @contents,
      e_if->new({
        condition => $EXTRADELAYAFTERSS ?
          "slowclock && (delayCounter == 0)" : "slowclock",
      then => [
        e_if->new({
          condition => "state == $lastState",
          then => [
            $CPHA ?
            (
              e_assign->new(["transaction_primed", "1"]),
            ) :

            (
              e_assign->new(["transmitting","0"]),
              e_assign->new(["RRDY","1"]),
              e_assign->new(["rx_holding_reg", "shift_reg"]),
              e_assign->new(["SCLK_reg", $CPOL]),
              e_if->new({
                condition => "RRDY",
                then => [e_assign->new(["ROE", 1]),],
              }),
            ),
          ],
          else => [
            e_if->new({
              condition => "state != 0",
              then => [
                e_if->new({
                  condition => "transmitting",
                  then => [e_assign->new(["SCLK_reg", "~SCLK_reg"])],
                }),
              ],
            }),
          ],
        }),























      e_if->new({
        condition => "SCLK_reg ^ $CPHA ^ $CPOL",
        then => [
          e_if->new({
            condition => $CPHA ? "state != 0 && state != 1" : "1",
            then => [
              e_assign->new(["shift_reg","$shiftRegExpression"]),
            ],
          }),
        ],
        else => ($CLOCKDIV > 2) ?
        [e_assign->new(["MISO_reg", "ds_MISO"])]
        :
        [],
        }),
      ],
    });

    $module->add_contents(
      e_process->new({
        comment => "",
        contents => \@contents,
        asynchronous_contents => \@async_contents,
      })
    );

    if ($DEPTH == 1) {
      $module->add_contents(
        e_assign->new(["ds_MISO", "MISO"]),
      );
    } else {
      $module->add_contents(
        e_std_synchronizer->add({
          data_in  => "MISO",
          data_out => e_signal->new(["ds_MISO"]),
          clock    => "clk",
          reset_n  => "reset_n",
          depth    => "$DEPTH",
        }),
      );
    }

  }
  else
  {








    $module->add_contents(
      e_assign->new({
        lhs => e_signal->new({name => "forced_shift", never_export => 1,}),
        rhs => "ds2_SS_n & ~ds3_SS_n",
      })
    );
    
    my @sys_clk_contents = ();
    my @sys_clk_async_contents = ();

    if ($DEPTH == 1) {
      $module->add_contents(
        e_assign->new(["ds1_SS_n", "SS_n"]),
      );
    } else {
      $module->add_contents(
        e_std_synchronizer->add({
          data_in  => "~SS_n",
          data_out => "ds1_SS_nn",
          clock    => "clk",
          reset_n  => "reset_n",
          depth    => "$DEPTH",
        }),
        e_assign->new(["ds1_SS_n", "~ds1_SS_nn"]),
      );
    }

    push @sys_clk_async_contents, (
      e_assign->new({
        lhs => e_signal->new(["ds2_SS_n"]),
        rhs => 1,
      }),
      e_assign->new({
        lhs => e_signal->new(["ds3_SS_n"]),
        rhs => 1,
      }),

      e_assign->new({
        lhs => e_signal->new(["transactionEnded"]),
        rhs => 0,
      }),
      e_assign->new({
        lhs => e_signal->new(["EOP"]),
        rhs => 0
      }),
      e_assign->new({
        lhs => e_signal->new(["RRDY"]),
        rhs => 0,
      }),
      e_assign->new({
        lhs => e_signal->new(["TRDY"]),
        rhs => 1,
      }),
      e_assign->new({
        lhs => e_signal->new(["TOE"]),
        rhs => 0,
      }),
      e_assign->new({
        lhs => e_signal->new(["ROE"]),
        rhs => 0,
      }),
      e_assign->new({
        lhs => e_signal->new(["tx_holding_reg", $DATABITS]),
        rhs => 0,
      }),
      e_assign->new({
        lhs => e_signal->new(["rx_holding_reg", $DATABITS]),
        rhs => 0,
      }),
      e_assign->new({
        lhs => e_signal->new(["d1_tx_holding_emptied"]),
        rhs => 0,
      }),
    );

    push @sys_clk_contents, (
      e_assign->new(["ds2_SS_n", "ds1_SS_n"]),
      e_assign->new(["ds3_SS_n", "ds2_SS_n"]),
      e_assign->new(["transactionEnded", "forced_shift"]),
      e_assign->new(["d1_tx_holding_emptied", "tx_holding_emptied"]),
    );

    push @sys_clk_contents,
      e_if->new({
        condition => "tx_holding_emptied & ~d1_tx_holding_emptied",
        then => [
          e_assign->new(["TRDY", 1]),
        ],
      });

    push @sys_clk_contents,
      e_if->new({
        comment => " EOP must be updated by the last (2nd) cycle of access.",
        condition => 
          "(p1_data_rd_strobe && (rx_holding_reg == endofpacketvalue_reg)) || " .
          "(p1_data_wr_strobe && ($data_from_cpu_for_eop_purposes == endofpacketvalue_reg))",
        then => [
          e_assign->new(["EOP", 1]),
        ],
      });

    push @sys_clk_contents,
      e_if->new({
        condition => "forced_shift",
        then => [
          e_if->new({
            condition => "RRDY",
            then => [e_assign->new(["ROE", 1])],
            else => [e_assign->new(["rx_holding_reg", "shift_reg"]),],
          }),
          e_assign->new(["RRDY", 1]),
        ],
        else => [],
      });

    push @sys_clk_contents,
      e_if->new({
        comment => " On data read, clear the RRDY bit. ",
        condition => "data_rd_strobe",
        then => [
          e_assign->new(["RRDY", 0]),
        ],
      });

    push @sys_clk_contents,
      e_if->new({
        comment => " On status write, clear all status bits (ignore the data).",
        condition => "status_wr_strobe",
        then => [
          e_assign->new(["EOP",  0]),
          e_assign->new(["RRDY", 0]),
          e_assign->new(["ROE",  0]),
          e_assign->new(["TOE",  0]),
        ],
      });

    push @sys_clk_contents,
      e_if->new({
        comment => " On data write, load the transmit holding register and prepare to execute.\n" .
          "Safety feature: if tx_holding_reg is already occupied, ignore this write, and generate\n" .
          "the write-overrun error.",
        condition => "data_wr_strobe",
        then => [
          e_if->new({
            condition => "TRDY",
            then => [
              e_assign->new(["tx_holding_reg", "data_from_cpu"]),
            ],
          }),
          e_if->new({
            condition => "~TRDY",
            then => [
              e_assign->new(["TOE", "1"]),
            ],
          }),
          e_assign->new(["TRDY",  "0"]),
        ],
        else => [],
      });

    $module->add_contents(
      e_process->new({
        comment => " System clock domain events.",
        contents => \@sys_clk_contents,
        asynchronous_contents => \@sys_clk_async_contents,
      })
    );



















    my $numStates = $DATABITS + 1;
    my $lastState = $DATABITS;
    my $lastDataBit = $DATABITS - 1;


    $module->add_contents(
      e_assign->new({
          lhs => e_signal->new(["resetShiftSample"]),
          rhs => "~reset_n | transactionEnded",
      })
    );

    $module->add_contents(
      e_assign->new({
        lhs => "MISO",
        rhs =>
          $LSBFIRST ?
            "~SS_n & shift_reg[0]" :
            "~SS_n & shift_reg[$lastDataBit]",
      })
    );






    my $SCLK_edge_detector_reset_value;
    if ($CPOL == 0) {
      $SCLK_edge_detector_reset_value = 0;
    }
    else {
      $SCLK_edge_detector_reset_value = 1;
    }

    if ($DEPTH == 1) {
      $module->add_contents(
        e_assign->new(["ds1_SCLK", "SCLK"]),
      );
    } else {
      if ($SCLK_edge_detector_reset_value == 1) {
        $module->add_contents(
          e_std_synchronizer->add({
            data_in  => "~SCLK",
            data_out => "ds1_SCLK_n",
            clock    => "clk",
            reset_n  => "reset_n",
            depth    => "$DEPTH",
          }),
          e_assign->new(["ds1_SCLK", "~ds1_SCLK_n"]),
        );
      } else {
        $module->add_contents(
          e_std_synchronizer->add({
            data_in  => "SCLK",
            data_out => "ds1_SCLK",
            clock    => "clk",
            reset_n  => "reset_n",
            depth    => "$DEPTH",
          }),
        );
      }
    }

   $module->add_contents(
      e_register->new({
        enable => 1,
        in => "ds1_SCLK",
        out => "ds2_SCLK",
        async_value => $SCLK_edge_detector_reset_value,
      }),
   );
 



    my $shift_input1;
    my $sample_input1;
    my $shift_input2;
    my $sample_input2;
    my $shift_clock;
    my $sample_clock;
    {
      ($CPHA == 0 and $CPOL == 0) &&
      do {
        $shift_input1 = "(~ds1_SS_n & ~ds1_SCLK)";
        $sample_input1 = "~" . $shift_input1;
        last;
      };
      ($CPHA == 0 and $CPOL == 1) &&
      do {
        $shift_input1 = "(~ds1_SS_n & ds1_SCLK)";
        $sample_input1 = "~" . $shift_input1;
        last;
      };
      ($CPHA == 1 and $CPOL == 0) &&
      do {
        $sample_input1 = "(~ds1_SS_n & ~ds1_SCLK)";
        $shift_input1 = "~" . $sample_input1;
        last;
      };
      ($CPHA == 1 and $CPOL == 1) &&
      do {
        $sample_input1 = "(~ds1_SS_n & ds1_SCLK)";
        $shift_input1 = "~" . $sample_input1;
        last;
      };
    }
    ($shift_input2 = $shift_input1) =~ s/ds1/ds2/g;
    $shift_clock = "($shift_input1) & ~($shift_input2)";
    ($sample_input2 = $sample_input1) =~ s/ds1/ds2/g;
    $sample_clock = "($sample_input1) & ~($sample_input2)";

    $module->add_contents(
      e_assign->new({
        lhs => e_signal->new(["shift_clock"]),
        rhs => $shift_clock,
      })
    );

    $module->add_contents(
      e_assign->new({
        lhs => e_signal->new(["sample_clock"]),
        rhs => $sample_clock,
      })
    );
    
    $module->add_contents(
      e_register->new(
        {
          enable => 1,
          out => {name => "state", width => Bits_To_Encode($DATABITS)},
          in => "resetShiftSample ? 0 : (sample_clock & (state != $lastState)) ? (state + 1) : state",
          async_value => 0,
        },
      ),
    );

    if ($DEPTH == 1) {
      $module->add_contents(
        e_assign->new(["ds_MOSI", "MOSI"]),
      );
    } else {
      $module->add_contents(
        e_std_synchronizer->add({
          data_in  => "MOSI",
          data_out => "ds_MOSI",
          clock    => "clk",
          reset_n  => "reset_n",
          depth    => "$DEPTH",
        }),
      );
    }

    $module->add_contents(
      e_register->new(
        {
          enable => 1,
          out => {name => "MOSI_reg"},
          in => "resetShiftSample ? 0 : sample_clock ? ds_MOSI : MOSI_reg",
          async_value => 0,
        },
      ),
    );




    my $shiftRegExpression = "MOSI_reg";  # True if $DATABITS == 1.
    if ($LSBFIRST)
    {
      if ($DATABITS == 2)
      {
        $shiftRegExpression = "{MOSI_reg, shift_reg[1]}";
      }
      elsif ($DATABITS > 2)
      {
        $shiftRegExpression = "{MOSI_reg, shift_reg[$lastDataBit : 1]}";
      }
    }
    else
    {
      if ($DATABITS == 2)
      {
        $shiftRegExpression = "{shift_reg[0], MOSI_reg}";
      }
      elsif ($DATABITS > 2)
      {
        my $dataBit2 = $DATABITS - 2;
        $shiftRegExpression = "{shift_reg[$dataBit2 : 0], MOSI_reg}";
      }
    }
    
    $module->add_contents(
      e_register->news(
        {
          enable => 1,
          out => {name => "shift_reg", width => $DATABITS},
          in => "resetShiftSample ? 0 : shift_clock ? (shiftStateZero ? tx_holding_reg : $shiftRegExpression) : shift_reg",
          async_value => 0,
        },
        {
          enable => 1,
          out => {name => "shiftStateZero"},
          in => "resetShiftSample ? 1 : shift_clock? 0 : shiftStateZero",
          async_value => 1,
        },
        {
          enable => 1,
          out => {name => "tx_holding_emptied"},
          in => "resetShiftSample ? 0 : shift_clock ? (shiftStateZero ? 1 : 0) : tx_holding_emptied",
          async_value => 0,
        },
      ),
    );
  }
  
  if($ALLOW_LEGACY_SIGNALS) {
    	$module->add_contents(
    	 	e_signal->new({name => "dataavailable", width => 1}),
    	 	e_signal->new({name=>"endofpacket", width=>1}),
	  		e_signal->new({name=>"readyfordata", width=>1}),
    	);
    }     



  return $project;

}

1;

