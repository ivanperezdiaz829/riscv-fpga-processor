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
use e_avalon_master;
use e_fsm;
use strict;

my $p4_revision = '$Revision: #1 $';
my $p4_datetime = '$DateTime: 2013/08/11 18:37:27 $';
$p4_revision =~ /#(\d+)/;
my $revision = $1;

my $read_master_name = "read_master";
my $write_master_name = "write_master";
my $control_port_name = "control_port_slave";

my @all_transactions = qw(
  quadword
  doubleword
  word
  hw
  byte_access
);

sub control_register
{
  my ($comment,
      $name,
      $width,
      $condition,
      $data,
      $else_if,
      $else_event,
      $reset_value) = @_;


  return () if ($width == 0);


  $reset_value =~ s/^[0-9]*\'h/$width\'h/;


  my @table = ($condition, $data);
  if ($else_if)
  {
    push @table, ($else_if, $name . $else_event);
  }


  my $mux = e_mux->new({
    lhs => e_signal->new(["p1_$name",]),
    table          => \@table,
    type           => "priority",
    default => $name,
  });


  my $reg = e_register->new({
    comment => $comment,
    in => "p1_$name",
    out => e_signal->new({name => $name, width => $width}),
    async_value => $reset_value,
  });

  return ($reg, $mux);
}

sub get_slave_port_data_width
{

  return max(map {$_->[2]} get_slave_port_registers(@_));
}

sub get_slave_port_addr_width
{
  my @registers = get_slave_port_registers(@_);

  my $addr_width = ceil(log2(0 + @registers));
  return $addr_width;
}

sub get_max_transaction_size_in_bits
{
  my @trans = reverse get_transaction_size_bit_names();
  my $size = 8;
  @trans = map {
    my $this_size = $size; $size *= 2; {trans => $_, size => $this_size}
  } @trans;

  my $max_size = -1;

  map {$max_size = $_->{size} if is_transaction_allowed($_->{trans})} @trans;

  ribbit("no possible transactions!") if $max_size == -1;

  return $max_size;
}



sub get_transaction_size_bit_names
{
  return @all_transactions;
}






sub get_transaction_size_bit_indices
{
  return get_slave_port_bits('control', get_transaction_size_bit_names());
}











sub get_transaction_size_expression
{
  return concatenate(
    map {is_transaction_allowed($_) ? $_ : "1'b0"}
    get_transaction_size_bit_names()
  );
}

sub get_slave_port_registers
{
  my $Options = shift;
















































  my @controlbits = get_control_bits();
  my @statusbits =  get_status_bits();
  my $control_register_width = 1 + max(map {$_->[2]} @controlbits);
  my $status_register_width =  1 + max(map {$_->[2]} @statusbits);

  my $transaction_size = get_transaction_size_expression();



  my $control_default_reset_string = 0;
  map {
    $control_default_reset_string += (($_->[1] =~ /(^word$)|(leen)/) ? 1 << $_->[2] : 0)
  } get_control_bits();



  my @reg_info = (
    [" status register",
      "status",
      $status_register_width,
      "",
      "0",
      "",
      "",
      0,
    ],
    [" read address",
      "readaddress",
      $Options->{readaddresswidth},
      "",
      "dma_ctl_writedata",
      "inc_read",
      " + readaddress_inc",
      0,
    ],
    [" write address",
      "writeaddress",
      $Options->{writeaddresswidth},
      "",
      "dma_ctl_writedata",
      "inc_write",
      " + writeaddress_inc",
      0,
    ],
    [" length in bytes",
      "length",


      min(
        $::g_max_address_width,
        max(
          $Options->{lengthwidth},
          Bits_To_Encode($Options->{max_slave_address_span}),
        ),
      ),
      "",
      "dma_ctl_writedata",
      "inc_read && (!length_eq_0)",
      $Options->{burst_enable} ? " - length" : " - $transaction_size",
      0,
    ],
    [" reserved",
      "reserved1",
      0,
      "",
      "dma_ctl_writedata",
      "",
      "",
      0,
    ],
    [" reserved",
      "reserved2",
      0,
      "",
      "dma_ctl_writedata",
      "",
      "",
      0,
    ],
    [" control register",
      "control",
      $control_register_width,
      "",
      "dma_ctl_writedata",
      "",
      "",
      $control_default_reset_string,
    ],
    [" control register alternate",
      "reserved3",
      $control_register_width,
      "",
      "dma_ctl_writedata",
      "",
      "",
      $control_default_reset_string,
    ],
  );




  my $index = 0;
  my $control_reg_index = -1;
  my $alt_control_reg_index = -1;
  for my $reg_spec (@reg_info)
  {

    $reg_spec->[3] = 
      "dma_ctl_chipselect & ~dma_ctl_write_n & (dma_ctl_address == $index)";

    $control_reg_index = $index if ($reg_spec->[1] eq "control");
    $alt_control_reg_index = $index if ($reg_spec->[1] eq "reserved3");
    $index++;

    my $name = $reg_spec->[1];
    my $reset_value = $Options->{$name . "_reset_value"};

    if (defined($reset_value))
    {
      $reset_value = eval($reset_value);


      $reg_spec->[7] = sprintf("%d'h%X", $::g_max_register_width, $reset_value);
    }
  }
  ribbit ("can't find control register\n") if (-1 == $control_reg_index);
  ribbit ("can't find alt_control register\n")
    if (-1 == $alt_control_reg_index);



  $reg_info[$control_reg_index]->[3] = 
    "dma_ctl_chipselect & ~dma_ctl_write_n & " .
    "((dma_ctl_address == $control_reg_index) || " .
    "(dma_ctl_address == $alt_control_reg_index))";




  my $cleared_bits = ~0;  # That is, all 1-bits.
  my $set_bits = 0;



  my $cur_reset = $reg_info[$control_reg_index]->[7];
  $cur_reset =~ s/[0-9]*\'h/0x/g;
  $cur_reset = eval($cur_reset);

  my $i = 0;
  for (get_control_bits())
  {
    my $bitname = $_->[1];  
    my $optionname = "control_" . $bitname . "_reset_value";

    my $override_bit = $Options->{"control_" . $bitname . "_reset_value"};
    if (defined($override_bit))
    {
      if ($override_bit)
      {
        $set_bits |= 1 << $i;
      }
      else
      {
        $cleared_bits &= ~(1 << $i);
      }
    }

    $i++;
  }

  $cur_reset |= $set_bits;
  $cur_reset &= $cleared_bits;







  my @check_bits = get_transaction_size_bit_indices();

  if (1 != grep {$cur_reset & (1 << $_)} @check_bits)
  {
    ribbit(
      sprintf(
        "Multiple bits set in bogus control register reset value 0x%X\n",
        $cur_reset)
    );
  }


  $reg_info[$control_reg_index]->[7] =
    sprintf("%d'h%X", $::g_max_register_width, $cur_reset);

  return @reg_info;
}

sub get_control_bits
{
  my @control_bits = (
    ["byte_access",                  "Byte transaction", ],
    ["hw",                    "Half-word transaction", ],
    ["word",                  "Word transaction", ],
    ["go",                    "enable execution", ],
    ["i_en",                  "enable interrupt", ],
    ["reen",                  "Enable read end-of-packet", ],
    ["ween",                  "Enable write end-of-packet", ],
    ["leen",                  "Enable length=0 transaction end", ],
    ["rcon",                  "Read from a fixed address", ],
    ["wcon",                  "Write to a fixed address", ],
    ["doubleword",            "Double-word transaction", ],
    ["quadword",              "Quad-word transaction", ],
    ["softwarereset",         "Software reset - write twice in succession to reset", ],
  );



  my $i = 0;
  return map {["control", $_->[0], $i++, $_->[1]]} @control_bits;
}

sub get_status_bits
{
  my @status_bits = (
    [ "done",           "1 when done.  Status write clears.", ],
    [ "busy",           "1 when busy.", ],
    [ "reop",           "read-eop received",],
    [ "weop",           "write-eop received",],
    [ "len",            "requested length transacted",],
  );



  my $i = 0;
  return map {["status", $_->[0], $i++, $_->[1]]} @status_bits;
}

sub get_slave_port_bit_definitions
{



  return (get_control_bits(), get_status_bits());  
}



sub get_slave_port_bits
{
  my ($reg_name, @bit_names) = @_;

  my @bits = ();

  my @reg_spec;
  {
    $reg_name eq "control" and do {@reg_spec = get_control_bits(); last;};
    $reg_name eq "status"  and do {@reg_spec = get_status_bits();  last;};
  }

  ribbit("bad register-bit request '$reg_name'\n") if !@reg_spec;


  for my $bit_name (@bit_names)
  {
    push @bits, (map {$_->[1] eq $bit_name ? $_->[2] : ()} @reg_spec);
  }

  return undef if (0 + @bits != @bit_names);  
  return @bits;
}

sub get_slave_port_register_indices
{
  my ($Options, @names) = @_;
  my @regs = get_slave_port_registers($Options);
  my @indices;
  
  for my $name (@names)
  {
    my $register_index = '';
    my $i = 0;
    for my $reg (@regs)
    {
      if ($reg->[1] eq $name)
      {
        $register_index = $i;
        last;
      }
      
      $i++;
    }
    

    push @indices, $register_index;
  }
  
  return @indices;
}










sub make_read_master_data_mux
{







  my ($Options, $module, $project) = @_;

  my $read_data_mux_module = e_module->new({
    name => $module->name() . "_read_data_mux",
  });

  my @contents = ();

  my $mux_select_bits = log2($Options->{readdatawidth} / 8);
  if (get_allowed_transactions() == 1 or $mux_select_bits == 0)
  {





    push @contents, 
      e_assign->new({
        lhs => "fifo_wr_data[@{[$Options->{readdatawidth} - 1]} : 0]",
        rhs =>  "read_readdata[@{[$Options->{readdatawidth} - 1]} : 0]",
      });
  }
  else
  {

    my $address_select_range = "0";
    if ($mux_select_bits > 1)
    {
      $address_select_range = "@{[$mux_select_bits - 1]}: 0";
    }

    push @contents, (
      e_signal->new({name => "readdata_mux_select", width => $mux_select_bits,}),
    );



      my @reg_info = get_slave_port_registers($Options);


      my ($control_index, $readaddress_index, $length_index) =
        get_slave_port_register_indices($Options, "control", "readaddress", "length");

      ribbit("No control register!") if ('' eq $control_index);
      ribbit("No readaddress register!") if ('' eq $readaddress_index);
      ribbit("No readaddress register!") if ('' eq $length_index);

      push @contents, (
        e_assign->new([
          e_signal->new(["control_write"]), $reg_info[$control_index]->[3]
        ]),
      );
      push @contents, (
        e_assign->new([
          e_signal->new(["length_write"]), $reg_info[$length_index]->[3]
        ]),
      );


      my ($go_bit_pos) = get_slave_port_bits("control", "go");
      ribbit("no go bit!\n") if (!defined($go_bit_pos));


      my @trans_bits = get_transaction_size_bit_indices();



      my $readaddress_reset_val = $reg_info[$readaddress_index]->[7];
      $readaddress_reset_val =~ s/([0-9]*)\'h/0x/g;
      $readaddress_reset_val = hex($readaddress_reset_val);

      if ($readaddress_reset_val)
      {

        $readaddress_reset_val .=
          sprintf(" & %d\'b%s", $mux_select_bits, '1' x $mux_select_bits);
      }        








      push @contents, (
        e_mux->new({
          lhs => e_signal->new({name => "read_data_mux_input", width => $mux_select_bits,}),
          table => [
            "control_write && dma_ctl_writedata[$go_bit_pos] || length_write",
            "readaddress[1:0]",

            "read_readdatavalid",
            "readdata_mux_select + readaddress_inc",
          ],
          default => "readdata_mux_select",
          type           => "priority",
        }),
        e_register->new({
          comment =>
            " Reset value: the transaction size bits of the read address reset value.",
          out => "readdata_mux_select",
          in => "read_data_mux_input[$address_select_range]",
          async_value => $readaddress_reset_val,
        }),
      );






















    push @contents, e_signal->new({
      name => "fifo_wr_data",
      width => $Options->{fifodatawidth},
    });


    my @trans_names = reverse get_transaction_size_bit_names();
    my $msb = $Options->{fifodatawidth} - 1;
    my $lsb = $Options->{fifodatawidth} / 2;

    while (1)
    {

      my @mux_table;

      for my $trans_index (0 .. @trans_names - 1)
      {
        my $trans_name = $trans_names[$trans_index];
        next if not is_transaction_allowed($trans_name);

        my $trans_size_in_bits = transaction_size_in_bits($trans_name);

        next if $trans_size_in_bits <= $lsb;

        my $multiple = $Options->{readdatawidth} / $trans_size_in_bits;
        my $mux_select_msb = log2($Options->{readdatawidth} / 8) - 1;
        my $mux_select_lsb = $trans_index;
        my $mux_select;
        if ($mux_select_msb >= $mux_select_lsb)
        {
          $mux_select = "readdata_mux_select[$mux_select_msb : $mux_select_lsb]";
        }

        for my $i (0 .. $multiple - 1)
        {
          my $select = $trans_name;
          if ($mux_select)
          {
            $select .= " & ($mux_select == $i)";
          }
          my $basic_selection = 
            "read_readdata[@{[$i * $trans_size_in_bits + $msb]} : @{[$i * $trans_size_in_bits + $lsb]}]";
          my $full_selection;
          my $excess_bits = $Options->{fifodatawidth} - $trans_size_in_bits;

          my $top_half = sprintf("read_readdata[%d : %d]", 
            $Options->{fifodatawidth} - 1, $Options->{fifodatawidth} / 2);
          my $dont_care_part;
          my $dont_care_bits = $excess_bits - $Options->{fifodatawidth} / 2;
          if ($dont_care_bits > 0)
          {
            $dont_care_part =
              sprintf("{%d{1'b%s}}, ", $dont_care_bits, $::g_dont_care_value);
          }
          push @mux_table, ($select, $basic_selection);
        }

      }

      if (@mux_table == 2)
      {
        push @contents, 
          e_assign->new({
            lhs  => "fifo_wr_data[$msb : $lsb]",
            rhs => $mux_table[1],
          });
      }
      else
      {

        push @contents, 
          e_mux->new({
            lhs  => "fifo_wr_data[$msb : $lsb]",
            type => "and_or",
            table => \@mux_table,
          });
      }



      last if $lsb == 0;
      $msb -= $lsb;
      $lsb /= 2;
      $lsb = 0 if $lsb < 8;
    }
  }

  $read_data_mux_module->add_contents(@contents);
  return e_instance->new({module => $read_data_mux_module});
}

sub make_registers
{
  my ($module, $Options) = @_;

  my $burst_enable = $Options->{burst_enable};

Progress("DMA burst enable state: $burst_enable") if $Options->{europa_debug};


  my @reg_info = get_slave_port_registers($Options);



  my @write_regdesc;
  my $length_index = -1;
  for my $i (0 .. @reg_info - 1)
  {
    my $reg = $reg_info[$i];




    if ($reg->[1] eq "status")
    {



      $module->add_contents(
        e_assign->new({
          lhs => e_signal->new(["status_register_write"]),
          rhs =>
            "dma_ctl_chipselect & ~dma_ctl_write_n & (dma_ctl_address == $i)",
        }),
      );

      next;
    }




    next if ($reg->[1] eq "reserved3");





    if ($reg->[1] eq "length")
    {
      $length_index = $i;
      @write_regdesc = @{$reg};
    }

    $module->add_contents(
      control_register(@{$reg})
    );
  }

  ribbit ("length not found: can't make writelength register!\n")
    if (!@write_regdesc or ($length_index == -1));


  $write_regdesc[0] = " write master length";
  $write_regdesc[1] = "writelength";
  $write_regdesc[5] = "inc_write && (!writelength_eq_0)";
  $write_regdesc[6] = " - " . get_transaction_size_expression();
  $module->add_contents(control_register(@write_regdesc));




  $module->add_contents(
    e_assign->new({
      lhs => e_signal->new({name => "p1_writelength_eq_0",}),
      rhs => "$write_regdesc[5] && ((writelength $write_regdesc[6]) == 0)",
    }),
    e_assign->new({
      lhs => e_signal->new({name => "p1_length_eq_0",}),
      rhs => "$reg_info[$length_index]->[5] && " .
        "((length $reg_info[$length_index]->[6]) == 0)",
    }),
  );







  my $length_reset_as_number;
  ($length_reset_as_number = $reg_info[$length_index]->[7]) =~ s/[0-9]*\'h/0x/g;
  $length_reset_as_number = eval($length_reset_as_number);

  my $writelength_reset_as_number;
  ($writelength_reset_as_number = $write_regdesc[7]) =~ s/[0-9]*\'h/0x/g;
  $writelength_reset_as_number = eval($writelength_reset_as_number);

  $module->add_contents(
    e_register->new({
      out => "length_eq_0",
      async_value => 0 + ($length_reset_as_number == 0),
      sync_set => "p1_length_eq_0",
      sync_reset => $reg_info[$length_index]->[3],
    }),
    e_register->new({
      out => "writelength_eq_0",
      async_value => 0 + ($writelength_reset_as_number == 0),
      sync_set => "p1_writelength_eq_0",
      sync_reset => $write_regdesc[3],
    }),
  );




















  if ($Options->{readincovwidth})
  {
    my $is0_p1_rhs;
    my $readinc_index = -1;
    map {
      $readinc_index = $_ if ($reg_info[$_]->[1] eq "readincov")
    } (0 .. -1 + @reg_info);
    ribbit("no readincov register!") if $readinc_index == -1;

    my $incov_clken = $reg_info[$readinc_index]->[3];
    my $reset_val;
    ($reset_val = $reg_info[$readinc_index]->[7]) =~ s/[0-9]*\'h/0x/g;
    $reset_val = eval($reset_val);
    my $async_val = $reset_val == 0 ? "1" : "0";

    $is0_p1_rhs =
      sprintf("dma_ctl_writedata[%d:0] == 0", $Options->{readincovwidth} - 1);
    $module->add_contents(
      e_assign->new({
        lhs => e_signal->new({
          name => "p1_readincov_eq_0", never_export => 1,
        }),
        rhs => $is0_p1_rhs,
      }),
      e_register->new({
        out => "readincov_eq_0",
        in => "p1_readincov_eq_0",
        enable => $incov_clken,
        async_value => $async_val,
      }),
    );
  }

  if ($Options->{writeincovwidth})
  {
    my $is0_p1_rhs;
    my $writeinc_index = -1;
    map {
      $writeinc_index = $_ if ($reg_info[$_]->[1] eq "writeincov")
    } (0 .. -1 + @reg_info);
    ribbit("no writeincov register!") if $writeinc_index == -1;

    my $incov_clken = $reg_info[$writeinc_index]->[3];
    my $reset_val;
    ($reset_val = $reg_info[$writeinc_index]->[7]) =~ s/[0-9]*\'h/0x/g;
    $reset_val = eval($reset_val);
    my $async_val = $reset_val == 0 ? "1" : "0";

    $is0_p1_rhs = sprintf("dma_ctl_writedata[%d:0] == 0",
      $Options->{writeincovwidth} - 1);

    $module->add_contents(
      e_assign->new({
        lhs => ["p1_writeincov_eq_0", 1, 0, 1],
        rhs => $is0_p1_rhs,
      }),
      e_register->new({
        out                => ["writeincov_eq_0", 1, 0, 1],
        in                 => "p1_writeincov_eq_0",
        enable             => $incov_clken,
        async_value        => $async_val,
      }),
    );
  }

  my $transaction_size = get_transaction_size_expression();

  my @top_priority =
    $Options->{writeincovwidth} ? ("~writeincov_eq_0", "writeincov") : ();

  $module->add_contents(
    e_mux->new({
      lhs => e_signal->new({
        name => "writeaddress_inc",


        width => max(
          scalar(get_transaction_size_bit_indices()),
          $Options->{writeincovwidth}
        ),
      }),
      type           => "priority",
      table          => [
        @top_priority,
        "wcon", "0",
        "$burst_enable", "0",
      ],
      default => "$transaction_size",
    }),
  );

  @top_priority =
    $Options->{readincovwidth} ? ("~readincov_eq_0", "readincov") : ();
  $module->add_contents(
    e_mux->new({
      lhs => e_signal->new({
        name => "readaddress_inc",


        width => max(
          scalar(get_transaction_size_bit_indices()),
          $Options->{readincovwidth}
        ),
      }),
      type           => "priority",
      table          => [
        @top_priority,
        "rcon", "0",
        "$burst_enable", "0",
      ],
      default => "$transaction_size",
    }),
  );


  my @muxtable = ();
  for (my $i = 0; $i < @reg_info; ++$i)
  {

    next if $reg_info[$i]->[1] =~ /reserved/;


    next if $reg_info[$i]->[2] == 0;


    push @muxtable, "dma_ctl_address == $i";


    my $reg_name = @{$reg_info[$i]}->[1];


    $reg_name = "control" if ($reg_name eq "reserved3");






    $reg_name = "writelength" if ($reg_name eq "length");

    push @muxtable, $reg_name;
  }

  my $data_width = get_slave_port_data_width($Options);

  $module->add_contents(
    e_mux->new({
      lhs => ["p1_dma_ctl_readdata", $data_width, ],
      type => "and_or",
      table => \@muxtable,
    }),
    e_register->new({
      in => "p1_dma_ctl_readdata",
      out => "dma_ctl_readdata",
    }),
  );

  $module->add_contents(
    e_assign->new({
      lhs => e_signal->new({name => "done_transaction", width => 1}),    
      rhs => "go & done_write",
    })
  );

  $module->add_contents(
    e_register->new({
      out                => "done",
      sync_set           => "done_transaction & ~d1_done_transaction",
      sync_reset         => "status_register_write",
      clock              => "clk",
      async_value        => 0,
    }),
  );

  $module->add_contents(
    e_register->new({
      out                => "d1_done_transaction",
      in                 => "done_transaction",
      clock              => "clk",
      async_value        => 0,
    }),
  );

  $module->add_contents(
    e_assign->new({
      lhs => e_signal->new({name => "busy", width => 1}),
      rhs => "go & ~done_write",
    })
  );



  my @status_bits;
  map {

    $status_bits[$_->[2]] = $_->[1];
  } get_status_bits();

  my @control_bits;
  map {

    $control_bits[$_->[2]] = $_->[1];
  } get_control_bits();

  $module->add_contents(
    e_signal->new({
      name => "status",
      width => 0 + @status_bits,
      never_export => 1,
    }),
  );


  for my $i (0 .. @status_bits - 1)
  {
    $module->add_contents(
      e_assign->new({
        rhs => "$status_bits[$i]",
        lhs => "status[$i]",
      })
    );
  }


  for my $i (0 .. @control_bits - 1)
  {
    my $bit_name = $control_bits[$i];
    my $rhs = "control[$i]";
    if ($Options->{burst_enable} && ($bit_name =~ /^[rw]een$/))
    {







      $rhs = "1'b0";
    }
    $module->add_contents(
      e_assign->new({
        lhs => e_signal->new({
          name => $bit_name,
          never_export => 1
        }),
        rhs => $rhs,
      })
    );
  }


  $module->add_contents(
    e_assign->new({
      lhs => "dma_ctl_irq",
      rhs => "i_en & done",
    })
  );
}

sub push_global_ports
{
  my $module = shift;

  $module->add_contents(
    e_port->new({name => "clk", type => "clk",}),
    e_port->new({name => "system_reset_n", type => "reset_n",}),


  );
}


sub get_control_interface_map
{
  my $Options = shift;


  my @map = (
    "dma_ctl_irq" => "irq",

  );




    push @map, (
      "dma_ctl_chipselect" => "chipselect",
      "dma_ctl_address" => "address",
      "dma_ctl_write_n" => "write_n",
      "dma_ctl_writedata" => "writedata",
      "dma_ctl_readdata" => "readdata",
      "clk" => "clk",
      "system_reset_n" => "reset_n",
    );


  return @map;
}


















sub push_control_interface_ports
{
  my ($project, $module, $Options) = @_;

  my $data_width = get_slave_port_data_width($Options);
  my $addr_width = get_slave_port_addr_width($Options);




  my $module_name = $module->name();














    $module->add_contents(
      e_port->new({name => "dma_ctl_irq", type => "irq", direction => "output"}),
    );











    $module->add_contents(
      e_port->new({name => "dma_ctl_chipselect", type => "chipselect",}),
      e_port->new({
        name => "dma_ctl_address", type => "address", width => $addr_width,
      }),
      e_port->new({name => "dma_ctl_write_n", type => "write_n",}),
      e_port->new({
        name => "dma_ctl_writedata",
        width => $data_width,
        type => "writedata",
      }),
      e_port->new({
        name => "dma_ctl_readdata",
        width => $data_width,
        type => "readdata",
        direction => "output",
      },),
    );    





























}

sub get_read_master_type_list
{
  return qw(
    readdata
    readdatavalid
    read_n
  );
}

sub get_write_master_type_list
{
  return qw(
    write_n
    writedata
    byteenable
  );
}

sub get_master_type_list
{
  my $Options = shift;
  my $burst_enable = $Options->{burst_enable};

  my @master_type_list = qw(
    address
    chipselect
    waitrequest
    endofpacket
  );
  push @master_type_list, "burstcount" if $burst_enable;
  return @master_type_list;
}

sub get_write_master_type_map
{
  my $Options = shift;
  ribbit("no Options hash\n") if (!$Options);

  my $port_prefix = 'write';

  my @types = get_master_type_list($Options);



  push @types,
    grep {has_byteenables($Options) or $_ ne 'byteenable'}
      get_write_master_type_list();


  return map {($port_prefix . "_$_" => $_)} @types;
}

sub get_read_master_type_map
{
  my $Options = shift;
  ribbit("no Options hash\n") if (!$Options);

  my $port_prefix = 'read';

  my @types = get_master_type_list($Options);
  push @types, get_read_master_type_list();


  return map {($port_prefix . "_$_" => $_)} @types;
}

sub has_byteenables
{
  my $Options = shift;



  my $has_byteenables = scalar(get_allowed_transactions()) > 1;

  return $has_byteenables;
}
















sub make_write_byteenables
{
  my ($Options, $module, $project) = @_;
  my $port_prefix = 'write';
  my $num_byteenables = $Options->{writedatawidth} / 8;


  return () if not has_byteenables($Options);

  my $byteenable_module = e_module->new({
    name => $module->name() . "_byteenables",
  });

  my @contents = ();

  my @muxtable;

  my @trans_bit_names = get_transaction_size_bit_names();



  for (my $trans_size = 1; $trans_size <= $num_byteenables; $trans_size <<= 1)
  {





    my $trans_bit_name = pop @trans_bit_names;
    ribbit("unexpected error") if !$trans_bit_name;

    next if !is_transaction_allowed($trans_bit_name);

    ribbit("ran out of transaction bit names!") if !$trans_bit_name;

    my $be_expression;



    my $num_important_address_bits = log2($num_byteenables / $trans_size);
    if ($num_important_address_bits == 0)
    {
      $be_expression =
        sprintf("%d'b%s", $num_byteenables, '1' x $num_byteenables);
    }
    else
    {
      my @terms;
      my $address_msb = log2($num_byteenables) - 1;
      my $address_lsb = $address_msb - $num_important_address_bits + 1;

      my $addr_sel =
        $address_msb == $address_lsb ? "$address_msb" : "$address_msb : $address_lsb";
      my $addr_sel_for_signal;
      ($addr_sel_for_signal = $addr_sel) =~ s/ : /_to_/;
      my $sig_name_prefix = "wa_$addr_sel_for_signal\_is_";

      my %sel_signals;  # Avoid redundant signal names.      
      for my $sel (reverse(0 .. $num_byteenables - 1))
      {
        my $sig_name = "$sig_name_prefix@{[$sel >> $address_lsb]}";
        if (!defined($sel_signals{$sig_name}))
        {

          push @contents, e_assign->new({
            lhs => [$sig_name, 1,],
            rhs => sprintf("($port_prefix\_address\[$addr_sel] == %d'h%X)",
              $num_important_address_bits, $sel >> $address_lsb),
          });


          $sel_signals{$sig_name} = 1;
        }
        push @terms, $sig_name;
      }

      $be_expression = "{@{[join(', ', @terms)]}}";

    }
    if (get_allowed_transactions() > 1)
    {
      push @muxtable, ($trans_bit_name, $be_expression);
    }
    else
    {

      push @contents, (
        e_assign->new({
          lhs => "$port_prefix\_byteenable",
          rhs => $be_expression,
        }),
      );
    }
  }

  if (get_allowed_transactions() > 1)
  {
    push @contents, (
      e_mux->new({
        lhs => "$port_prefix\_byteenable",
        table => \@muxtable,
        type => "and_or",
      }),
    );
  }

  $byteenable_module->add_contents(@contents);

  return e_instance->new({module => $byteenable_module});

}

sub get_write_master_ports
{
  my ($Options, $burst_enable, $max_burstcount_width) = @_;
  my $port_prefix = 'write';
  my @ports = get_master_ports($Options, $port_prefix);


  if (has_byteenables($Options))
  {
    my $num_byteenables = $Options->{writedatawidth} / 8;

    push @ports, (
      e_port->new({
        name => $port_prefix . "_byteenable",
        width => $num_byteenables,
        direction => "output",
        type => 'byteenable',
      }),
    );
  }

  push @ports, (
    e_port->new({
      name => $port_prefix . "_address",
      direction => "output",
      width => $Options->{writeaddresswidth},
      type => 'address',
    }),

    e_port->new({
      name => $port_prefix . "_writedata",
      direction => "output",
      width => $Options->{writedatawidth},
      type => 'writedata',
    }),

    e_port->new({
      name => $port_prefix . "_write_n",
      direction => "output",
      type => 'write_n',
    }),

  );

  push @ports, (
    e_port->new({
      name => $port_prefix . "_burstcount",
      type => "burstcount",
      direction => "output",
      width => "$max_burstcount_width"
    })
   ) if ($burst_enable);

  return @ports;
}

sub get_read_master_ports
{
  my ($Options, $burst_enable, $max_burstcount_width) = @_;
  my $port_prefix = 'read';
  my @ports = get_master_ports($Options, $port_prefix);

  push @ports, (
    e_port->new({
      name => $port_prefix . "_address",
      direction => "output",
      width => $Options->{readaddresswidth},
      type => 'address',
    }),

    e_port->new({
      name => $port_prefix . "_readdata",
      direction => "input",
      width => $Options->{readdatawidth},
      type => 'readdata',
    }),

    e_port->new({
      name => $port_prefix . "_read_n",
      direction => "output",
      type => 'read_n',
    }),

    e_port->new({
      name => $port_prefix . "_readdatavalid",
      direction => "input",
      type => 'readdatavalid',
    }),






  );

  push @ports, (
    e_port->new({
      name => $port_prefix . "_burstcount",
      type => "burstcount",
      direction => "output",
      width => "$max_burstcount_width"
    })
  ) if ($burst_enable);

  return @ports;
}

sub get_master_ports
{
  my ($Options, $port_prefix) = @_;

  my @master_ports = (
    e_port->new({
      name => $port_prefix . "_chipselect",
      direction => "output",
      type => 'chipselect',
    }),
    e_port->new({
      name => $port_prefix . "_waitrequest",
      direction => "input",
      type => 'waitrequest',
    }),
    e_port->new({
      name => $port_prefix . "_endofpacket",
      direction => "input",
      type => 'endofpacket',
    })
  );
  return @master_ports;
}

sub make_fifo
{
  my ($top_module, $Options) = @_;

  $top_module->add_contents(
    e_assign->new([
      "flush_fifo",
      "~d1_done_transaction & done_transaction"
    ]),
  );

  my $fifo_module = e_fifo->new({
    device_family => $Options->{device_family},
    name_stub => $top_module->name(),
    data_width => $Options->{fifodatawidth},
    fifo_depth => $Options->{fifo_depth},
    flush => "flush_fifo",
    full_port => 0,
    p1_full_port => 1,
    empty_port => 1,
    implement_as_esb => $Options->{fifo_in_logic_elements} ? 0 : 1,
    Read_Latency => $Options->{fifo_read_latency},
  });

  return $fifo_module;
}

sub make_fsm
{
  my (
    $name,
    $go,
    $p1_done,
    $mem_wait,
    $p1_fifo_stall,
    $select,
    $access_n,
    $inc,
    $fifo_access,
    $extra_latency,
    ) = @_;

  my $fsm = e_fsm->new({
    name => $name,
    start_state => "idle",
  });


  my $p1_select = "p1_" . $select;
  $fsm->add_contents(
    e_signal->new({
      name => $p1_select, never_export => 1,
    }),
    e_assign->new({
      lhs => e_signal->new({name => $access_n, export => 1,}),
      rhs => "~$select",
    }),
    e_register->new({
      delay => 1 + $extra_latency,
      in => $p1_select,
      out => e_signal->new({name => $select, never_export => 1,}),
    }),
  );


  if ($fifo_access)
  {
    $fsm->add_contents(
      e_signal->new({name => $inc, export => 1,}),

      e_assign->new({
        lhs => e_signal->new({name => $fifo_access,}),
        rhs => "$name\_access & ~$mem_wait",
      }),
    );
  }

  $fsm->OUTPUT_DEFAULTS({
    $p1_select => 0,
  });
  $fsm->OUTPUT_WIDTHS({
    $p1_select => 1,
  });

  $fsm->add_state(
    "idle",
    [
      {$go => 0,},
      "idle",
      {}
    ],
    [
      {$p1_done => 1,},
      "idle",
      {}
    ],

    [
      {$p1_fifo_stall => 1,},
      "idle",
      {}
    ],
    [







      {
        $go => 1,
        $p1_done => 0,
        $p1_fifo_stall => 0,
      },
      "access",
      {$p1_select => 1,},
    ],
  );

  $fsm->add_state(
    "access",


    [
      {$p1_fifo_stall => 1, $mem_wait => 0,},
      "idle",
      {},
    ],


    [
      {$p1_done => 1, $mem_wait => 0,},
      "idle",
      {},
    ],


    [
      {$mem_wait => 1, },
      "access",
      {$p1_select => 1,},
    ],


    [
      {
        $mem_wait => 0,
        $p1_fifo_stall => 0,
        $p1_done => 0,
      },
      "access",
      {$p1_select => 1,},
    ],
  );



  $fsm->add_contents(
    e_assign->new({

      lhs => [$inc, 1,],
      rhs => "$select & ~$mem_wait",
    }),
  );

  return $fsm;
}

sub make_write_machine
{
  my ($Options, $name) = @_;













  my $write_fsm_module = e_module->new({
    name => $name,
  });

  $write_fsm_module->add_contents(
    e_assign->new({
      lhs => e_signal->new({name => "write_select", export => 1,}),
      rhs => 'fifo_datavalid & ~d1_enabled_write_endofpacket',
    }),
    e_assign->new({
      lhs => e_signal->new({name => "mem_write_n", export => 1,}),
      rhs => "~write_select",
    }),
    e_assign->new({
      lhs => e_signal->new({name => "fifo_read", export => 1,}),
      rhs => "write_select & ~write_waitrequest",
    }),
    e_assign->new({
      lhs => "inc_write",
      rhs => "fifo_read",
    }),
  );

  return $write_fsm_module;
}

sub make_fsms
{
  my ($top_module, $Options) = @_;



















  my $fsm_read = make_fsm(
    $top_module->name() . "_mem_read",
    "go",
    "p1_done_read",
    "read_waitrequest",
    "p1_fifo_full",
    "read_select",
    "mem_read_n",
    "inc_read"
  );

  $top_module->add_contents(
    e_instance->new({
      name => "the_" . $fsm_read->name(),
      module => $fsm_read,
    })
  );

  $top_module->add_contents(
    e_assign->new({
      lhs => "fifo_write",
      rhs => "fifo_write_data_valid",
    }),
  );
  
  $top_module->add_contents(
    e_assign->new({
      lhs => "enabled_write_endofpacket",
      rhs => "write_endofpacket & ween",
    }),
    e_register->new({
      out => 'd1_enabled_write_endofpacket',
      in => 'enabled_write_endofpacket',
    })
  );
  


  my $fsm_write =
    make_write_machine($Options, $top_module->name() . "_mem_write");
  $top_module->add_contents(e_instance->new({module => $fsm_write,}));
}
















sub learn_about_the_masters_of_my_slave_port
{
  my ($module, $project, $Options) = @_;








  $Options->{masters_of_my_slave_port} = "control_slave_port";
  $module->comment($module->comment() . "Mastered by:\n");
  for my $master_name (@{$Options->{masters_of_my_slave_port}})
  {
    $module->comment(" " . $module->comment() . "$master_name; ");
  }
  $module->comment($module->comment() . "\n");









}

{






  my @allowed_transactions;
  my %transaction_size;

  sub transaction_size_in_bits
  {
    my $t = shift;
    return $transaction_size{$t} if exists($transaction_size{$t});

    my @t = reverse @all_transactions;
    for (0 .. @t - 1)
    {
      my $width = 8 * (1 << $_);
      my $transaction = $t[$_];
      $transaction_size{$transaction} = $width;
    }

    return $transaction_size{$t} if exists($transaction_size{$t});
    ribbit("transaction_size(): I never heard of transaction '$t'\n");
  }

  sub set_allowed_transactions
  {
    my ($lr) = @_;
    @allowed_transactions = @{$lr};


    map {s/^\s+//g; s/\s+$//} @allowed_transactions;

    @allowed_transactions = grep {
      my $t = $_;
      if (not grep {$t eq $_} get_transaction_size_bit_names())
      {
        print STDERR "Ignoring request to allow transaction '$t'\n";
        0;
      }
      else
      {
        1;
      }
    } @allowed_transactions;

  }

  sub limit_max_allowed_transaction
  {
    my $max = shift;


    @allowed_transactions = grep {
      $max >= transaction_size_in_bits($_)      
    } @allowed_transactions;
  }

  sub is_transaction_allowed
  {
    my $trans = shift;
    return 0 + grep {$trans eq $_} @allowed_transactions;
  }

  sub get_allowed_transactions
  {
    return @allowed_transactions;
  }
}

sub get_options
{
  my ($Options, $module, $project) = @_;




























  my $read_master_address;
  my $write_master_address;

  my @read_byteaddr_widths;
  my @write_byteaddr_widths;

  my @read_data_widths;
  my @write_data_widths;

  my @read_slave_names = $Options->{read_slave_name};
  my @write_slave_names = $Options->{write_slave_name};


  $module->comment($module->comment() . "Read slaves:\n");
  for (@read_slave_names)
  {
    $module->comment($module->comment() . "$_; ");
  }
  $module->comment($module->comment() . "\n\n");

  $module->comment($module->comment() . "Write slaves:\n");
  for (@write_slave_names)
  {
    $module->comment($module->comment() . "$_; ");
  }
  $module->comment($module->comment() . "\n\n");







  if ($Options->{user_defined_fifo_depth}) {
    
    push @read_byteaddr_widths, $Options->{read_address_width};
    push @read_data_widths, $Options->{read_data_width};
    push @write_byteaddr_widths, $Options->{write_address_width};
    push @write_data_widths, $Options->{write_data_width};
    
    $Options->{max_read_latency} = 0;
  } 











































  my $wsa_fifo_depth = $Options->{fifo_depth};

  $Options->{fifo_depth} = max(4,
    $wsa_fifo_depth,
    $Options->{burst_enable} ? $Options->{max_burst_size} : 0 ,
    $Options->{max_read_latency});




  if ($Options->{fifo_depth} < 1)
  {
    $Options->{fifo_depth} = 1;
  }

  if (not is_power_of_two($Options->{fifo_depth}))
  {
    $Options->{fifo_depth} = next_higher_power_of_two($Options->{fifo_depth});
  }


  $Options->{fifo_read_latency} = 1;









  delete $Options->{allowed_transactions};


  map {
    my $key = "allow_$_\_transactions";
    $Options->{$key} = 1 if not exists($Options->{$key})
  } @all_transactions;

  my @allowed_transactions = grep {
    my $key = "allow_$_\_transactions";
    $Options->{$key}
  } @all_transactions;

  set_allowed_transactions(\@allowed_transactions);




  $Options->{writedatawidth} =
    round_up_to_next_computer_acceptable_bit_width(max(@write_data_widths));
  $Options->{readdatawidth} =
    round_up_to_next_computer_acceptable_bit_width(max(@read_data_widths));






  map {$_ = min($_, get_max_transaction_size_in_bits())}
    ($Options->{writedatawidth}, $Options->{readdatawidth});














  $Options->{fifodatawidth} = max(
    $Options->{writedatawidth}, $Options->{readdatawidth}
  );




  $Options->{writedatawidth} = $Options->{fifodatawidth};
  $Options->{readdatawidth} = $Options->{fifodatawidth};



  limit_max_allowed_transaction($Options->{fifodatawidth});

  Progress("  @{[$module->name()]}: allowing these transactions: " .
    "@{[join(', ', get_allowed_transactions())]}");

  Progress("P4 $p4_revision $p4_datetime") if $Options->{europa_debug};




  $Options->{readaddresswidth} = max(@read_byteaddr_widths, 5);
  $Options->{writeaddresswidth} = max(@write_byteaddr_widths, 5);


}






























sub set_sim_ptf
{
  my ($Options, $module, $project) = @_;



  my @bus_signals = qw(
    length
    address
    data$
    byteenable
  );

  my $module_name = $module->name();
  my $sys_ptf = $project->system_ptf();
  my $mod_ptf = $sys_ptf->{"MODULE $module_name"};
  $mod_ptf->{SIMULATION} = {} if (!defined($mod_ptf->{SIMULATION}));
  $mod_ptf->{SIMULATION}->{DISPLAY} = {} if (!defined($mod_ptf->{SIMULATION}->{DISPLAY}));

  my $sig_ptf = $mod_ptf->{SIMULATION}->{DISPLAY};



  my @signals;

  push @signals, qw(
    busy
    done
    length
    fifo_empty
    p1_fifo_full
  );

  push @signals, "Divider $module_name $read_master_name";
  my %read_signals = get_read_master_type_map($Options);
  push @signals, sort keys %read_signals;

  push @signals, "Divider $module_name $write_master_name";
  my %write_signals = get_write_master_type_map($Options);
  push @signals, sort keys %write_signals;

  $project->set_sim_wave_signals(\@signals);
}

sub make_write_master_data_mux
{
  my ($Options, $input, $output) = @_;
  my @things;





  my @trans_names = reverse get_transaction_size_bit_names();  


  my $mux = e_mux->new({
    lhs => "write_writedata",
    type => "and_or",
  });

  my @mux_table;

  for my $trans_index (0 .. @trans_names - 1)
  {
    my $trans_name = $trans_names[$trans_index];
    next if !is_transaction_allowed($trans_name);

    my $trans_size_in_bits = transaction_size_in_bits($trans_name);


    last if $trans_size_in_bits > $Options->{fifodatawidth};

    my $signame = "fifo_rd_data_as_$trans_name";
    my $sig_value;
    my $dont_care_bits = $trans_size_in_bits - $Options->{fifodatawidth};

    if ($dont_care_bits <= 0)
    {
      $sig_value = "fifo_rd_data[@{[$trans_size_in_bits - 1]} : 0]";
    }
    else
    {
      $sig_value = sprintf("{{%d{1'b%s}}, fifo_rd_data}",
        $dont_care_bits, $::g_dont_care_value);
    }


    my $multiple = $Options->{writedatawidth} / $trans_size_in_bits;

    $sig_value = concatenate(($sig_value) x $multiple) if ($multiple != 1);

    push @things, e_assign->new([
      e_signal->new({
        name => $signame,
        width => $Options->{writedatawidth},
        never_export => 1,
      }),
      $sig_value,
    ]);


    push @mux_table, ($trans_name, $signame);
  }

  $mux->table(\@mux_table);
  push @things, $mux;

  return @things;
}

sub make_dma
{






  local *g_max_address_width = \32;
  local *g_max_register_width = \$::g_max_address_width;
  local *g_max_data_width = \128;
  local *g_dont_care_value = \qq(X);

  my ($project, $Options, $module) = @_;










  $module->comment("DMA peripheral " . $module->name() . "\n\n");




  get_options($Options, $module, $project);
  

  my $language = $Options->{project_info}{language};
  if ($language =~ /verilog/i) {
      $module->add_attribute ( ALTERA_ATTRIBUTE => qq(SUPPRESS_DA_RULE_INTERNAL=\\"R101\\")); 
  }
  else {
      $module->add_attribute ( ALTERA_ATTRIBUTE => qq(SUPPRESS_DA_RULE_INTERNAL=""R101""));
  }

  $Options->{device_family} = $project->{device_family};
  my $europa_debug = 0;
  $Options->{europa_debug} = 1 if $europa_debug;


  my $burst_enable = $Options->{burst_enable};
  my $max_burst_size = $burst_enable ? $Options->{max_burst_size} : 1;
  ribbit "DMA maximum burst size must be greater than zero when burst mode is enabled. Please assign a larger value in the DMA configuration GUI."
    if $max_burst_size < 1;
  my $max_burstcount_width = $burst_enable ? log2($max_burst_size)+1 : 1;






  $module->add_contents(
    e_assign->new({
      lhs => e_signal->new({name => "clk_en", never_export => 1,}),
      rhs => 1,
    })
  );





    $module->add_contents(
      e_avalon_slave->new({
        name => $control_port_name,
        type_map => {get_control_interface_map($Options, $module, $project)},
      })
    );




















  $module->add_contents(
    e_avalon_master->new({
      name => $read_master_name,
      type_map => {get_read_master_type_map($Options)},
    }),
    get_read_master_ports($Options, $burst_enable, $max_burstcount_width)
  );


  $module->add_contents(
    make_read_master_data_mux($Options, $module, $project),
  );


  $module->add_contents(
    e_avalon_master->new({
      name => $write_master_name,
      type_map => {get_write_master_type_map($Options)},
    }),
    get_write_master_ports($Options, $burst_enable, $max_burstcount_width)
  );

  $module->add_contents(
    make_write_byteenables($Options, $module, $project),
  );

  push_global_ports($module);
  push_control_interface_ports($project, $module, $Options);



  if ($burst_enable)
  {

    my $length_reset_value = $Options->{length_reset_value};
    $length_reset_value = eval($length_reset_value);

    my $burstcount_reset_value = 1;
    if ($length_reset_value)
    {
      $burstcount_reset_value = $length_reset_value >> log2($Options->{readdatawidth} / 8);
    }

    $module->add_contents(
      e_assign->new({
        lhs => "length_register_write",
        rhs =>
        "dma_ctl_chipselect & ~dma_ctl_write_n & (dma_ctl_address == 3)",
      }),







      e_register->new({
        in => "dma_ctl_writedata >> " .
          log2($Options->{readdatawidth} / 8), # value in words!
        out => e_signal->new({name => "burstcount_update",
          width => $max_burstcount_width
        }),
        enable => "length_register_write",


        async_value        => 1,
      }),


      e_register->new({
        in => "burstcount_update",
        out => "burstcount",
        enable => "~busy",
        async_value        => $burstcount_reset_value,
      }),
      e_assign->new({
        lhs => "read_burstcount",
        rhs => "burstcount"
      }),
      e_assign->new({
        lhs => "write_burstcount",
        rhs => "burstcount"
      }),




      e_register->new({
        comment => "read burst request cycle",
        in => " ~mem_read_n",
        out => "burst_read_waitrequest_s1",
        async_value => "0"
      }),
      e_register->new({
        in => "read_waitrequest",
        out => "read_waitrequest_s1",
        async_value => "0"
      }),
      e_assign->new({
        lhs => "read_read_n",
        rhs => "(~read_waitrequest_s1 & burst_read_waitrequest_s1) || mem_read_n"
      })
    );
  } else { # not burst mode
    $module->add_contents(
      e_assign->new({
        lhs => "read_read_n",
        rhs => "mem_read_n"
      })
    );
  }



  make_registers($module, $Options);


  $module->add_contents(
    e_assign->new({
      lhs => "p1_read_got_endofpacket",
      rhs => "~status_register_write && " .
        "(read_got_endofpacket || (read_endofpacket & reen))",
    }),
  );

  $module->add_contents(
    e_assign->new({
      lhs => "p1_write_got_endofpacket",
      rhs => "~status_register_write && " .
        "(write_got_endofpacket || (inc_write & write_endofpacket & ween))",
    }),
  );

  $module->add_contents(
    e_register->new({
      in => "p1_read_got_endofpacket",
      out => e_signal->new(["read_got_endofpacket",]),
    }),
    e_register->new({
      in => "p1_write_got_endofpacket",
      out => e_signal->new(["write_got_endofpacket",]),
    }),
  );

  my $fifo_module = make_fifo($module, $Options);
  $module->add_contents(
    e_instance->new({
      module => $fifo_module,
      port_map => {
        inc_pending_data => "inc_read",
      },
    })
  );

  make_fsms($module, $Options);  




  $module->add_contents(
    e_assign->new({
      lhs => "p1_done_read",
      rhs =>
        "(leen && (p1_length_eq_0 || (length_eq_0))) | " .
        "p1_read_got_endofpacket | " .
        "p1_done_write",
    }),
  );





  $module->add_contents(
    e_register->new({
      out => "len",
      sync_reset => "status_register_write",
      sync_set =>
        "~d1_done_transaction & done_transaction && (writelength_eq_0)",
      priority => "reset",
      clock              => "clk",
      async_value        => 0,
    }),
  );







  $module->add_contents(
    e_register->new({
      out => "reop",
      sync_reset => "status_register_write",
      sync_set => "fifo_empty & read_got_endofpacket & d1_read_got_endofpacket",
      clock              => "clk",
      async_value        => 0,
    }),
  );

  $module->add_contents(
    e_register->new({
      out => "weop",
      sync_reset => "status_register_write",
      sync_set => "write_got_endofpacket",
      clock              => "clk",
      async_value        => 0,
    }),
  );

  $module->add_contents(






    e_assign->new({
      lhs => "p1_done_write",
      rhs => 
        "(leen && (p1_writelength_eq_0 || writelength_eq_0)) | " .
        "p1_write_got_endofpacket | " .
        "fifo_empty & d1_read_got_endofpacket",
    }),
    e_register->new({
      in => "read_got_endofpacket",
      out => e_signal->new(["d1_read_got_endofpacket"]),
    }),
    e_register->new({
      comment =>
        " Write has completed when the length goes to 0, or\n" .
        " the write source said end-of-packet, or\n" .
        " the read source said end-of-packet and the fifo has emptied.",
      out => "done_write",
      in => "p1_done_write",
    })
  );




  $module->add_contents(
    e_assign->news(['read_address','readaddress',]),
    e_assign->news(['write_address','writeaddress',])
  );

  $module->add_contents(
    e_assign->new({
      lhs => "write_chipselect",
      rhs => "write_select",
    })
  );

  $module->add_contents(
    e_assign->new({
      lhs => "read_chipselect",
      rhs => "~read_read_n",
    })
  );


  $module->add_contents(
    e_assign->new({
      lhs => "write_write_n",
      rhs => "mem_write_n",
    })
  );



 


  $module->add_contents(
    make_write_master_data_mux(
      $Options,
      "fifo_rd_data",
      "write_writedata", ),
  );

  $module->add_contents(
    e_assign->new({
      lhs => e_signal->new({
        name => "fifo_write_data_valid",
        never_export => 1,
      }),
      rhs => "read_readdatavalid",
    })
  );



  

  my @reg_info = get_slave_port_registers($Options);
  my ($control_index) = get_slave_port_register_indices($Options, "control");
  my ($alt_control_index) = get_slave_port_register_indices($Options, "reserved3");
  my $control_register_write_expression = "($reg_info[$control_index]->[3])";


  my $sr_bit_position = -1;
  map {$sr_bit_position = $_->[2] if $_->[1] eq 'softwarereset'} get_control_bits();
  ribbit("Can't find 'softwarereset' bit") if ($sr_bit_position == -1);
  













  $module->add_contents(
    e_assign->new({
      lhs => {name => "set_software_reset_bit", never_export => 1,},
      rhs => # Set this register if someone writes the control register...
        "($control_register_write_expression)" .

        " & (dma_ctl_address != $alt_control_index)" .

        " & dma_ctl_writedata[$sr_bit_position] ",
    }),
    e_register->news(
      {
        out => "d1_softwarereset",
        in => "softwarereset & ~software_reset_request",
        enable => "set_software_reset_bit | software_reset_request",
        _reset => "system_reset_n",
      },
      {
        out => "software_reset_request",
        in => "d1_softwarereset & ~software_reset_request",
        enable => "set_software_reset_bit | software_reset_request",
        _reset => "system_reset_n",
      },
      {
        out => "reset_n",
        in => "~(~system_reset_n | software_reset_request)",
        enable => "1",
        _reset => "system_reset_n",
      },
    )         
  );



  if (!$Options->{allow_legacy_signals}) {
    $module->add_contents(
	  e_signal->new({name=>"read_endofpacket", width=>1, never_export=>1}),
	  e_signal->new({name=>"write_endofpacket", width=>1, never_export=>1}),


	  e_assign->add(["read_endofpacket"=>"0"]),
	  e_assign->add(["write_endofpacket"=>"0"])
    );
  }
  


}





















































































































































































































































































































































































































































































































































































































































































1;
