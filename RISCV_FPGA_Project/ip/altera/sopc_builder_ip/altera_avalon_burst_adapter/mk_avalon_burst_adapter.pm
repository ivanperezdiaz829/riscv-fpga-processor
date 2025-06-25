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

sub make_burst_adapter
{

  return if !@_;

  my $project = e_project->new(@_);
 
  make_adapter($project);

  $project->output();
}

sub validate_options($$$)
{
  my ($project, $module, $opt) = @_;
 


  validate_parameter({
    hash    => $opt,
    name    => "master_data_width",
    type    => "int",
    allowed_values => [8, 16, 32, 64, 128, ],
  });

  validate_parameter({
    hash    => $opt,
    name    => "master_interleave",
    type    => "bool",
  });

  validate_parameter({
    hash    => $opt,
    name    => "slave_interleave",
    type    => "bool",
  });

  validate_parameter({
    hash    => $opt,
    name    => "dynamic_slave",
    type    => "bool",
  });




  if ($opt->{master_linewrap_bursts})
  {


    if (!$opt->{master_always_burst_max_burst})
    {
      ribbit(
        "Incompatible settings: master Linewrap_Bursts: $opt->{master_linewrap_bursts}, " .
        "but Always_Burst_Max_Burst: $opt->{master_always_burst_max_burst}"
      );
    }

    if ($opt->{slave_linewrap_bursts})
    {






      if ($opt->{dbs_shift} < 0)
      {
        my ($adapter_master, $adapter_slave) = 
          get_connections($project, $module, $opt);
        ribbit(
          "Error: incompatible burst parameters between master and slave: " .
          "master and slave Linewrap_Bursts = 1 but master datawidth < slave datawidth.\n" . 
          "\tmaster: $adapter_master; master datawidth: $opt->{master_data_width}\n" .
          "\tslave: $adapter_slave; slave datawidth: $opt->{data_width}\n");
      }
    }
  }
}

sub assign_options($$$)
{
  my ($project, $module, $opt) = @_;


  $opt->{extra_sim_signals} = [];

  my $adapter_slave_SBI = $project->SBI('upstream');
  $opt->{data_width} = $adapter_slave_SBI->{Data_Width};



  my $width = 
    $adapter_slave_SBI->{Address_Width} + log2($opt->{data_width} / 8);

  $opt->{zero_address_width} = ($width == 0) ? 1 : 0;
  $opt->{byteaddr_width} = max(1, $width);
  $opt->{nativeaddr_width} = max(1, $adapter_slave_SBI->{Address_Width});


  $opt->{ceil_data_width} =
    round_up_to_next_computer_acceptable_bit_width($opt->{data_width});
    
  $opt->{downstream_addr_shift} = log2($opt->{ceil_data_width} / 8);
  $opt->{dbs_shift} = log2($opt->{master_data_width} / $opt->{ceil_data_width});
  




  my $upstream_SBI = $project->module_ptf()->{"SLAVE upstream"}{SYSTEM_BUILDER_INFO};
  $opt->{upstream_max_burstcount} = $upstream_SBI->{Maximum_Burst_Size};
  ribbit("Maximum_Burst_Size must be integer power of 2; is: $opt->{upstream_max_burstcount}\n")
    unless is_power_of_two($opt->{upstream_max_burstcount});

  my $downstream_SBI = $project->module_ptf()->{"MASTER downstream"}{SYSTEM_BUILDER_INFO};
  $opt->{downstream_max_burstcount} = $downstream_SBI->{Maximum_Burst_Size} || 1;
  ribbit("Maximum_Burst_Size must be integer power of 2; is: $opt->{downstream_max_burstcount}\n")
    unless is_power_of_two($opt->{downstream_max_burstcount});

  $opt->{downstream_burstcount_width} = 1 + &log2($opt->{downstream_max_burstcount});
  


  $opt->{upstream_burstcount_width} = 1 + &log2($opt->{upstream_max_burstcount});
  



  $opt->{dbs_upstream_burstcount_width} = $opt->{upstream_burstcount_width};
  $opt->{dbs_upstream_burstcount_width} += $opt->{dbs_shift} if ($opt->{dbs_shift} > 0);






  $opt->{master_linewrap_bursts} = $upstream_SBI->{Linewrap_Bursts};
  $opt->{slave_linewrap_bursts} = $downstream_SBI->{Linewrap_Bursts};


  $opt->{master_always_burst_max_burst} = 
    $upstream_SBI->{Always_Burst_Max_Burst};




  $opt->{upstream_burstcount} = "upstream_burstcount";
  if ($opt->{master_always_burst_max_burst})
  {
    $opt->{upstream_burstcount} = sprintf("%d'h%X", 
      $opt->{upstream_burstcount_width},
      $opt->{upstream_max_burstcount}
    );
  }



  $opt->{slave_always_burst_max_burst} = 
    $downstream_SBI->{Always_Burst_Max_Burst};
    

  $opt->{master_burst_on_burst_boundaries_only} = 
    $upstream_SBI->{Burst_On_Burst_Boundaries_Only};



  $opt->{slave_burst_on_burst_boundaries_only} = 
    $downstream_SBI->{Burst_On_Burst_Boundaries_Only};
}

sub make_interfaces($$$)
{
  my ($project, $module, $opt) = @_;



  my @avalon_slave_signals;
  my @avalon_master_signals;
  
  my @avalon_signals = 
  (
    {name => 'writedata', width => $opt->{data_width}},
    {name => 'readdata',  width => $opt->{data_width}},
    {name => 'readdatavalid'},
    {name => 'write'},
    {name => 'read'},
    {name => 'waitrequest'},
    {name => 'byteenable', width => $opt->{ceil_data_width} / 8},
    {name => 'debugaccess',},
  );


  map {$_->{type} = $_->{name}} @avalon_signals;

  for my $sig (@avalon_signals)
  {
    my %sig_copy = %$sig;

    $sig->{name} = 'upstream_' . $sig->{name};
    push @avalon_slave_signals, $sig;
    $sig_copy{name} = 'downstream_' . $sig_copy{name};
    push @avalon_master_signals, \%sig_copy;
  }


  push @avalon_slave_signals,  (
    {name => 'upstream_address', width => $opt->{byteaddr_width}, type => 'byteaddress',},
    
    {name => 'upstream_burstcount', width => $opt->{upstream_burstcount_width}, type => 'burstcount',},
  );

  push @avalon_slave_signals,  (


    {name => 'upstream_nativeaddress', width => $opt->{nativeaddr_width}, type => 'address',},
  );
  e_assign->adds({
    lhs => {name => "sync_nativeaddress", never_export => 1,},
    rhs => "|upstream_nativeaddress",
  });


  push @avalon_master_signals, (
    {name => 'downstream_address', width => $opt->{nativeaddr_width}, type =>
    'address', never_export => $opt->{zero_address_width}},
    {name => 'downstream_nativeaddress', width => $opt->{nativeaddr_width}, type => 'nativeaddress', never_export => $opt->{zero_address_width}},
    {name => 'downstream_burstcount', width => $opt->{downstream_burstcount_width}, type => 'burstcount',},
    {name => 'downstream_arbitrationshare', width => $opt->{dbs_upstream_burstcount_width}, type => 'arbitrationshare',},
  );


  my @export_signals = qw(
    upstream_waitrequest
    upstream_readdatavalid
    downstream_write
    downstream_byteenable
    downstream_read
    downstream_burstcount
  );

  for my $sig (@avalon_slave_signals, @avalon_master_signals)
  {
    $sig->{copied} = 1;
    $sig->{never_export} = 0 if ($sig->{never_export} eq '');
    
    $sig->{export} =  0;
    if (grep {$sig->{name} eq $_} @export_signals)
    {
      $sig->{export} =  1;
    }
  }

  e_signal->adds(@avalon_slave_signals, @avalon_master_signals);


  my $slave_type_map = { map {$_->{name} => $_->{type}}
                         @avalon_slave_signals};
  my $master_type_map = { map {$_->{name} => $_->{type}}
                         (@avalon_master_signals)};

  my $downstream_master = e_avalon_master->add
  ({
    name => 'downstream',
    type_map => $master_type_map,
  });

  my $upstream_slave = e_avalon_slave->add
  ({
    name => 'upstream',
    type_map => $slave_type_map,
  });
  return ($upstream_slave, $downstream_master);
}

sub make_counters($$$)
{
  my ($project, $module, $opt) = @_;










  if (!$opt->{dynamic_slave})
  {









    






    e_register->add({
      out => {name => 'transactions_remaining', width => $opt->{upstream_burstcount_width} - 1,},
      in => 

        "(upstream_read & ~upstream_waitrequest) ? ($opt->{upstream_burstcount} - 1) : " .


        "(downstream_read & ~downstream_waitrequest & (|transactions_remaining)) ? (transactions_remaining - downstream_burstcount) : " .
        "transactions_remaining",
      enable => 1,
    });
    push @{$opt->{extra_sim_signals}}, qw(
      transactions_remaining
    );
    return;
  }
  
  e_register->add({
    out => ['atomic_counter', $opt->{downstream_burstcount_width}],
    in => 'downstream_burstdone ? 0 : p1_atomic_counter',
    enable => '(downstream_read | downstream_write) & ~downstream_waitrequest',
    async_value => 0,
  });
  push @{$opt->{extra_sim_signals}}, qw(
    atomic_counter
  );








  e_assign->adds(
    {
      lhs => "read_update_count",
      

      rhs => "current_upstream_read & ~downstream_waitrequest",
    },
    {
      lhs => "write_update_count",
      rhs => "current_upstream_write & downstream_write & downstream_burstdone",
    },
    {
      lhs => "update_count",
      rhs => "read_update_count | write_update_count",
    },
  );



  e_assign->add
  ({
    lhs => ['transactions_remaining', $opt->{dbs_upstream_burstcount_width}],
    rhs => "(state_idle & (upstream_read | upstream_write)) ? " .
      "dbs_adjusted_upstream_burstcount : transactions_remaining_reg",
  });
  
  e_register->add({
    out => ['transactions_remaining_reg', $opt->{dbs_upstream_burstcount_width}],
    in =>
      "(state_idle & (upstream_read | upstream_write)) ? dbs_adjusted_upstream_burstcount : " .
      "update_count ? transactions_remaining_reg - downstream_burstcount : " .
      "transactions_remaining_reg",
    enable => '1',
  });
  push @{$opt->{extra_sim_signals}}, qw(
    transactions_remaining
    transactions_remaining_reg
  );





  e_register->add({
    out => {name => 'data_counter', width => $opt->{dbs_upstream_burstcount_width}},
    in =>
      "state_idle & upstream_read & ~upstream_waitrequest ?  dbs_adjusted_upstream_burstcount : " .
      "downstream_readdatavalid ? data_counter - 1 : " .
      "data_counter",
    enable => 1,
  });

  push @{$opt->{extra_sim_signals}}, qw(
    data_counter
  );
}



sub get_linewrap_arbitrationshare_adjustment
{
  my ($project, $module, $opt) = @_;




  return "|" . get_current_burst_offset($project, $module, $opt);
}

sub get_current_burst_offset
{
  my ($project, $module, $opt) = @_;

  my $indices = "0";
  my $burstcount_width = min(
    $opt->{downstream_burstcount_width}, $opt->{upstream_burstcount_width}
  );
  if ($burstcount_width > 2)
  {
    $indices = $burstcount_width - 2 . " : 0";
  }

  return "burst_offset[$indices]";
}

sub make_downstream_burstcount($$$)
{
  my ($project, $module, $opt) = @_;
  if (!$opt->{dynamic_slave})
  {
    e_assign->add({
      lhs => e_signal->new({
        name => 'downstream_burstcount',
        width => $opt->{downstream_burstcount_width},
        never_export => 1,
      }),
      rhs => 1,
    });
    
    return;
  }
  




























































































































  if (($opt->{downstream_max_burstcount} > 1) && $opt->{slave_interleave})
  {








    my $interleave_onset_width = log2($opt->{downstream_max_burstcount});
    my $slave_burst_master_address_span;
    


    my $span_lsb = log2($opt->{ceil_data_width} / 8);
    my $span_msb = $span_lsb + $interleave_onset_width - 1;
    my @interleave_bits;
    for my $i ($span_lsb .. $span_msb)
    {



      unshift @interleave_bits,
        ($i < log2($opt->{master_data_width} / 8)) ?
          "1'b0" : "upstream_address[$i]"
    }
    my $upstream_address_wrt_slave_burst_boundary = concatenate(@interleave_bits);













    



    

    e_assign->add({
      lhs => {name => "mask_top_burst_address", width => $opt->{downstream_burstcount_width},},
      rhs => "$upstream_address_wrt_slave_burst_boundary + dbs_adjusted_upstream_burstcount - 1",
    });
    

    e_assign->add({
      lhs => {name => "mask_reversed_top_burst_address", width => $opt->{downstream_burstcount_width},},
      rhs => concatenate(
        map {"mask_top_burst_address[$_]"} (0 .. -1 + $opt->{downstream_burstcount_width})
      ),
    });
    

    e_assign->add({
      lhs => {name => "mask_reversed_bottom_bit", width => $opt->{downstream_burstcount_width},},
      rhs => "mask_reversed_top_burst_address & (~mask_reversed_top_burst_address+ 1)",
    });
    

    e_assign->add({
      lhs => {name => "mask_unreversed_bottom_bit", width => $opt->{downstream_burstcount_width},},
      rhs => concatenate(
        map {"mask_reversed_bottom_bit[$_]"} (0 .. -1 + $opt->{downstream_burstcount_width})
      )
    });
    

    e_assign->add({
      lhs => {name => "mask_interleave", width => $opt->{downstream_burstcount_width},},
      rhs => "mask_unreversed_bottom_bit | (mask_unreversed_bottom_bit - 1)",
    });

    push @{$opt->{extra_sim_signals}}, qw(
      mask_top_burst_address
      mask_reversed_top_burst_address
      mask_reversed_bottom_bit
      mask_unreversed_bottom_bit
      mask_interleave
    );

    e_assign->add({
      lhs => {name => "initial_interleave_onset", width => $interleave_onset_width,},
      rhs => "-($upstream_address_wrt_slave_burst_boundary) & " .
        "(mask_interleave)"
    });
    my $p1_interleave_onset = 
      "(state_idle & (upstream_read | upstream_write)) ? (initial_interleave_onset) :
      update_count ? (interleave_onset & ~downstream_burstcount) : " .
      "interleave_onset";
      

    my $p1_interleave_onset_bitcount =
      join(" + ", map {"initial_interleave_onset[$_]"} (0 .. -1 + $interleave_onset_width));
    e_register->add({
      out => {name => "interleave_onset", width => $interleave_onset_width,},
      in => $p1_interleave_onset,
      enable => 1,
    });
    e_register->add({
      out => {name => "interleave_onset_bitcount", width => ceil(1 + log2($interleave_onset_width)),},
      in => $p1_interleave_onset_bitcount,
      enable => "state_idle & (upstream_read | upstream_write)",
    });

    e_assign->adds(
      [
        {name => "burst_agenda", width => $opt->{downstream_burstcount_width},},
        "($opt->{downstream_max_burstcount} | interleave_onset)"
      ],
      [
        {name => "max_burst_size", width => $opt->{downstream_burstcount_width},}, 
        "(burst_agenda & (~burst_agenda + 1))"
      ]
    );

    push @{$opt->{extra_sim_signals}}, qw(
      max_burst_size
      burst_agenda
      initial_interleave_onset
      interleave_onset
      interleave_onset_bitcount
    );
  }
  else
  {


    if ($opt->{master_linewrap_bursts} && ($opt->{downstream_max_burstcount} > 1))
    {



      my $offset_within_burst = get_current_burst_offset($project, $module, $opt);








      my $burst_size = min(
        $opt->{downstream_max_burstcount}, $opt->{upstream_max_burstcount}
      );
      e_assign->add([
        {name => 
          "max_burst_size", 
          width => $opt->{downstream_burstcount_width},
        },
        "$burst_size - $offset_within_burst",
      ]);
    }
    else
    {
      e_assign->add([
        {name => 
          "max_burst_size", 
          width => $opt->{downstream_burstcount_width},
        },
        "$opt->{downstream_max_burstcount}"
      ]);
    }
  }




  my $downstream_burstcount = 
    "((transactions_remaining > max_burst_size) ? max_burst_size : " .
    "transactions_remaining)";

  if ($opt->{dbs_shift} < 0)
  {




    $downstream_burstcount = "current_upstream_read ? ($downstream_burstcount) : 1";
  }

  e_assign->add({
    lhs => e_signal->new({
      name => 'downstream_burstcount',
      width => $opt->{downstream_burstcount_width},
      never_export => 1,
    }),
    rhs => $downstream_burstcount,
  });
}

sub make_downstream_arbitrationshare($$$)
{
  my ($project, $module, $opt) = @_;

  if (!$opt->{dynamic_slave})
  {


    e_assign->add({
      lhs => 'downstream_arbitrationshare',
      rhs => "$opt->{upstream_burstcount}",
    });

    return;
  }
  














  


  my $read_arbshare_expression = "dbs_adjusted_upstream_burstcount";
  if ($opt->{downstream_max_burstcount} > 1)
  {
    my $ds_burstcount_bits = log2($opt->{downstream_max_burstcount});




    $ds_burstcount_bits = $opt->{dbs_upstream_burstcount_width}
      if ($ds_burstcount_bits > $opt->{dbs_upstream_burstcount_width});

    my $ds_select = ($ds_burstcount_bits > 1) ? "@{[$ds_burstcount_bits - 1]} : 0" : "0";
    




    my $interleave_onset_bitcount;
    my $interleave_onset;
    if ($opt->{slave_interleave})
    {
      $interleave_onset_bitcount = "interleave_onset_bitcount";
      $interleave_onset = "interleave_onset";
    }
    elsif ($opt->{master_linewrap_bursts})
    {


      if (!$opt->{master_always_burst_max_burst})
      {
        ribbit("require master_always_burst_max_burst with master_linewrap_bursts\n");
      }

      $interleave_onset_bitcount = 
        get_linewrap_arbitrationshare_adjustment($project, $module, $opt);
      $interleave_onset = 0;
    } 
    else
    {
      $interleave_onset_bitcount = 0;
      $interleave_onset = 0;
    }
    e_assign->add([
      {name => "interleave_end", width => $opt->{dbs_upstream_burstcount_width},},
      "(dbs_adjusted_upstream_burstcount > $interleave_onset) ? (dbs_adjusted_upstream_burstcount - $interleave_onset) : 0",
    ]);
    
    $read_arbshare_expression = "$interleave_onset_bitcount + " .
      "(interleave_end >> $ds_burstcount_bits) + " .
      "|(interleave_end[$ds_select])";
  }
    
  e_assign->add({
    lhs => 'downstream_arbitrationshare',
    rhs => "current_upstream_read ? ($read_arbshare_expression) : dbs_adjusted_upstream_burstcount",
  });

  push @{$opt->{extra_sim_signals}}, qw(
    downstream_arbitrationshare
  );
}

sub make_burstdone_signals($$$)
{
  my ($project, $module, $opt) = @_;
  
  if (!$opt->{dynamic_slave})
  {
    return;
  }

  e_assign->adds(







    {
      lhs => 'upstream_burstdone',
      rhs => "current_upstream_read ? " .
        "(transactions_remaining == downstream_burstcount) & downstream_read & ~downstream_waitrequest : " .
        "(transactions_remaining == (atomic_counter + 1)) & downstream_write & ~downstream_waitrequest",
    },
    {
      lhs => {name => 'p1_atomic_counter', width => $opt->{downstream_burstcount_width}},
      rhs => "atomic_counter + (downstream_read ? downstream_burstcount : 1)",
    },
    {
      lhs => 'downstream_burstdone',
      rhs => '(downstream_read | downstream_write) & ~downstream_waitrequest & (p1_atomic_counter == downstream_burstcount)',
    }
  );
  
  push @{$opt->{extra_sim_signals}}, qw(
    upstream_burstdone
    downstream_burstdone
  );
}

sub make_downstream_address($$$)
{
  my ($project, $module, $opt) = @_;


  if (!$opt->{dynamic_slave})
  {
    e_assign->add({
      lhs => "downstream_address",
      rhs => "current_upstream_address",
    });




    e_assign->add({
      lhs => "downstream_nativeaddress",
      rhs => "upstream_nativeaddress",
    });

    return;
  }

  if ($opt->{dynamic_slave})
  {

    my @write_transaction_increment_and_terms =
      ("downstream_write", "~downstream_waitrequest", "downstream_burstdone");
    if ($opt->{dbs_shift} < 0)
    {





      my $slave_be_bits = $opt->{ceil_data_width} / 8;
      my $master_be_bits = $opt->{master_data_width} / 8;

      my $top_index = $slave_be_bits - 1;
      my $bottom_index = $top_index - $master_be_bits + 1;
      my $range = "[$top_index : $bottom_index]";

      push @write_transaction_increment_and_terms,
        "|downstream_byteenable$range";
    }
    my $write_transaction_increment_enable = and_array(@write_transaction_increment_and_terms);

    e_register->add({
      out => ['write_address_offset', -1 + $opt->{dbs_upstream_burstcount_width}],
      in =>
        "state_idle & upstream_write ? 0 : " .
        "($write_transaction_increment_enable) ? write_address_offset + downstream_burstcount : " .
        "write_address_offset",
      enable => 1,
    });

    e_register->add({
      out => ['read_address_offset', -1 + $opt->{dbs_upstream_burstcount_width}],
      in =>
        "state_idle & upstream_read ? 0 : " .
        "(downstream_read & ~downstream_waitrequest) ? read_address_offset + downstream_burstcount : " .
        "read_address_offset",
      enable => 1,
    });






    my $shifted_native_address = "registered_upstream_nativeaddress";
    my $master_shift = log2($opt->{master_data_width} / 8);
    if ($master_shift > 0)
    {
      $shifted_native_address .= " >> $master_shift";
    }

    e_assign->add({
      lhs => "downstream_nativeaddress",
      rhs => $shifted_native_address,
    });
  }
  else
  {

    e_assign->adds(
      [{name => 'read_address_offset', never_export => 1,}, 0,],
      [{name => 'write_address_offset', never_export => 1,}, 0,],
    );
  }

  e_assign->add({
    lhs => ['address_offset', -1 + $opt->{dbs_upstream_burstcount_width}],
    rhs => 'current_upstream_read ? read_address_offset : write_address_offset',
  });
  
  push @{$opt->{extra_sim_signals}}, qw(
    read_address_offset
    address_offset
    write_address_offset
  );




  my $address_selection;
  my $master_aligned_0_bits = log2($opt->{master_data_width} / 8);
  if (($opt->{byteaddr_width} > $master_aligned_0_bits) && $opt->{dynamic_slave} && ($opt->{dbs_shift} > 0))
  {
    $address_selection = 
      sprintf("{current_upstream_address[%d:%d], %d'b%s}",
        $opt->{byteaddr_width} - 1,
        $master_aligned_0_bits,
        $master_aligned_0_bits,
        '0' x $master_aligned_0_bits
      );
  }
  else
  {
    $address_selection = 'current_upstream_address';
  }











  e_assign->add({
    lhs => {
      name => "downstream_address_base", 
      width => $opt->{byteaddr_width}, 
      never_export => 1,
    },
    rhs => $address_selection,
  });
  
  if ($opt->{master_linewrap_bursts})
  {



    my $burst_count_segment_width = -1 + $opt->{dbs_upstream_burstcount_width};
    my $top_segment = 
      sprintf(
        "downstream_address_base[%d : %d]",
        $opt->{byteaddr_width} - 1, 
        $opt->{downstream_addr_shift} + $burst_count_segment_width
      );
    my $middle_segment = 
      sprintf(
        "downstream_address_base[%d : %d]",
        -1 + $opt->{downstream_addr_shift} + $burst_count_segment_width,
        $opt->{downstream_addr_shift}
      );

    my $burst_offset_width =
        -1 + $opt->{downstream_addr_shift} + $burst_count_segment_width - 
        $opt->{downstream_addr_shift} + 1;
    e_assign->add({
      lhs => {name => "burst_offset", width => $burst_offset_width,},
      rhs => "$middle_segment + address_offset",
    });

    my @terms = ($top_segment, "burst_offset",);
    if ($opt->{downstream_addr_shift} > 0)
    {
      push @terms, sprintf(
        "%d'b%s", 
        $opt->{downstream_addr_shift}, '0' x $opt->{downstream_addr_shift}
      );
    }
    e_assign->add({
      lhs => "downstream_address",
      rhs => concatenate(@terms)
    });
  }
  else
  {
    my $adjusted_address_offset = 'address_offset';
    if ($opt->{downstream_addr_shift} > 0)
    {
      $adjusted_address_offset = "{$adjusted_address_offset, " .
        sprintf(
          "%d'b%s}", 
          $opt->{downstream_addr_shift}, '0' x $opt->{downstream_addr_shift}
        );
    }
    e_assign->add({
      lhs => "downstream_address",
      rhs => "downstream_address_base + $adjusted_address_offset", 
    });
  }
}

sub make_downstream_read($$$)
{
  my ($project, $module, $opt) = @_;

  if (!$opt->{dynamic_slave})
  {
    e_assign->add([
      'downstream_read',
      'upstream_read | (|transactions_remaining)',
    ]);

    return;
  }
  
  e_register->adds(
    {
      out => 'downstream_read',
      enable => "~downstream_read | ~downstream_waitrequest",
      in =>

        "state_idle & upstream_read ? 1 : " .

        "(transactions_remaining == downstream_burstcount) ? 0 : " .

        "downstream_read",
    },
  );
}

sub make_upstream_readdata($$$)
{
  my ($project, $module, $opt) = @_;

  if (!$opt->{dynamic_slave})
  {

    e_register->adds 
    (






      {out => "upstream_readdatavalid", in => "downstream_readdatavalid", enable => 1,},
      {out => "upstream_readdata", in => "downstream_readdata", enable => 1,},
    );
      
    push @{$opt->{extra_sim_signals}}, qw(downstream_readdatavalid upstream_readdatavalid);

    return;
  }

  if ($opt->{dbs_shift} >= 0)
  {
    e_assign->adds 
    (
      ["upstream_readdatavalid", "downstream_readdatavalid"],
      ["upstream_readdata", "downstream_readdata"],   
    );




    e_assign->add([{name => 'fifo_empty', never_export => 1,}, 1]);
    e_assign->add([{name => 'p1_fifo_empty', never_export => 1,}, 1]);
  }
  else
  {










    my $num_segments = $opt->{ceil_data_width} / $opt->{master_data_width};
    my $last_segment = $num_segments - 1;
    
    my $negative_dbs_bits = -$opt->{dbs_shift};
    my $negative_dbs_base = log2($opt->{master_data_width} / 8);
    my $upstream_negative_dbs_address_index =
      $negative_dbs_bits == 1 ? "$negative_dbs_base" :
      sprintf("%d : %d", $negative_dbs_bits - 1 + $negative_dbs_base, $negative_dbs_base);
    my $readdatavalid_counter = "negative_dbs_rdv_counter";
    my $readdatavalid_counter_enable = "fifo_datavalid";
    e_register->add({
      out => {name => $readdatavalid_counter, width => log2($num_segments),},
      in => "(state_idle & upstream_read & ~upstream_waitrequest) ? upstream_address[$upstream_negative_dbs_address_index] : $readdatavalid_counter_enable ? $readdatavalid_counter + 1 : $readdatavalid_counter",
      enable => 1,
    });





    e_assign->adds(
      ["fifo_read", "~fifo_empty && (($readdatavalid_counter == $last_segment) || ((full_width_rdv_counter + 1) == current_upstream_burstcount))"],
      ["fifo_write", "downstream_readdatavalid"],
      [{name => "fifo_wr_data", width => $opt->{data_width}}, "downstream_readdata"],
    );

    my $fifo_numwords = ceil($opt->{upstream_max_burstcount} * 2**$opt->{dbs_shift});




    $fifo_numwords *= 2;

    my $fifo_module = e_fifo->new({
      device_family => $module->project()->device_family(),
      name_stub => $module->name(),
      data_width => $opt->{data_width},
      fifo_depth => $fifo_numwords,
      implement_as_esb => ($opt->{data_width} * $fifo_numwords) > 256 ? 1 : 0,
      full_port => 1,
      empty_port => 1,
      p1_empty_port => 1,
      flush => "flush_fifo",
    });
    
    e_assign->add(["flush_fifo", "1'b0"]);
    e_signal->add({name => "fifo_empty", never_export => 1, });
    e_instance->add({
      module => $fifo_module,
      port_map => {
        inc_pending_data => "fifo_write",
        clk_en => "1'b1",
      },
    });


    my $condition = "fifo_full && fifo_write";
    my $then = [
      e_sim_write->new({
        show_time => 1,
        spec_string => "simulation assertion failed: " . $module->name() . ": illegal write into full fifo.",
      }),
      e_stop->new(),
    ];
    e_process->add({
      contents => [
        e_if->new({
          condition => $condition,
          then => $then,
        }),
      ],
      tag => 'simulation',
    });

    push @{$opt->{extra_sim_signals}}, qw(fifo_read fifo_full fifo_empty p1_fifo_empty fifo_write fifo_datavalid fifo_rd_data fifo_wr_data);



    e_register->add({
      out => {name => "full_width_rdv_counter", width => $opt->{upstream_burstcount_width},},
      enable => 1,
      in => "(state_idle & upstream_read & ~upstream_waitrequest) ? 0 : " .
        "upstream_readdatavalid ? full_width_rdv_counter + 1 : " .
        "full_width_rdv_counter",



    });
    push @{$opt->{extra_sim_signals}}, "full_width_rdv_counter";




    e_assign->adds(["upstream_readdatavalid", "$readdatavalid_counter_enable"]);

    my @u_read_table;
    for my $i (0 .. -1 + $num_segments)
    {
      my $segment_select =
        sprintf("[%d : %d]", -1 + ($i + 1) * $opt->{master_data_width}, $i * $opt->{master_data_width});
      push @u_read_table, "($i == $readdatavalid_counter)", "{" . join(", ", ("fifo_rd_data$segment_select") x $num_segments) . "}"
    }
   
    e_mux->add({
      lhs => "upstream_readdata",
      table => [@u_read_table],
    });

    push @{$opt->{extra_sim_signals}}, ($readdatavalid_counter);
  }

  push @{$opt->{extra_sim_signals}}, qw(downstream_readdatavalid upstream_readdatavalid);
}

sub make_downstream_write($$$)
{
  my ($project, $module, $opt) = @_;
  if (!$opt->{dynamic_slave})
  {
    e_assign->adds 
    (
      ["downstream_write", "upstream_write & !downstream_read"],
      ["downstream_byteenable", "upstream_byteenable"],
    );
    return;
  }
  
  if ($opt->{dbs_shift} >= 0)
  {
    e_register->add({
      out => 'downstream_write_reg',
      enable => "~downstream_write_reg | ~downstream_waitrequest",
      in =>

        "state_idle & upstream_write ? 1 : " .



        "((transactions_remaining == downstream_burstcount) & downstream_burstdone) ? 0 : " .

        "downstream_write_reg",
    });
    my $be_width = $opt->{ceil_data_width} / 8;


    e_register->add({
      async_value => sprintf("%d'b%s", $be_width, '1' x $be_width),
      enable => "pending_register_enable",
      out => {name => "registered_upstream_byteenable", width => $be_width,},
      in => "upstream_byteenable",
    });
    e_assign->adds 
    (
      ["downstream_write", "downstream_write_reg & upstream_write & !downstream_read",],
      ["downstream_byteenable", "downstream_write_reg ? upstream_byteenable : registered_upstream_byteenable"],
    );
  }
  else
  {



    e_assign->add([
      {name => "downstream_byteenable", width => $opt->{ceil_data_width} / 8,},
      "upstream_byteenable",
    ]);
    e_assign->add([
      "downstream_write", 
      "upstream_write & state_busy & !pending_upstream_read & fifo_empty"
    ]);
  }
}

sub make_downstream_writedata($$$)
{
  my ($project, $module, $opt) = @_;

  e_assign->add(["downstream_writedata", "upstream_writedata"]);
}

sub make_state_machine($$$)
{
  my ($project, $module, $opt) = @_;

  if (!$opt->{dynamic_slave})
  {
    return;
  }






  e_assign->adds(
    {
      lhs => 'p1_state_idle',
      rhs =>
      "state_idle & ~upstream_read & ~upstream_write | " .
      "state_busy & (data_counter == 0) & p1_fifo_empty & ~pending_upstream_read & ~pending_upstream_write",
    },
    {
      lhs => 'p1_state_busy',
      rhs =>
      "state_idle & (upstream_read | upstream_write) | " .
      "state_busy & (~(data_counter == 0) | ~p1_fifo_empty | pending_upstream_read | pending_upstream_write)",
    },
  );

  e_assign->adds(
    {
      lhs => 'enable_state_change',
      rhs => "~(downstream_read | downstream_write) | ~downstream_waitrequest",
    }
  );
  e_register->adds(
    {
      out => 'pending_upstream_read_reg',
      enable => 1,
      sync_set => "upstream_read & state_idle",
      sync_reset => $opt->{dbs_shift} < 0 ? "downstream_readdatavalid" : "upstream_burstdone",
      priority => "set",
    },
    {
      out => 'pending_upstream_write_reg',
      enable => 1,
      sync_set => "upstream_write & (state_idle | ~upstream_waitrequest)",
      sync_reset => "upstream_burstdone",
    },
    {
      out => 'state_idle',
      in => 'p1_state_idle',
      enable => "enable_state_change",
      async_value => 1,
    },
    {
      out => 'state_busy',
      in => 'p1_state_busy',
      enable => "enable_state_change",
      async_value => 0,
    },
  );
  e_assign->adds(
    [
      "pending_upstream_read",
      "pending_upstream_read_reg",
    ],
    [
      "pending_upstream_write",
      "pending_upstream_write_reg & ~upstream_burstdone",
    ],
    [
      "pending_register_enable",
      "state_idle | ((upstream_read | upstream_write) & ~upstream_waitrequest)"
    ],
  );

  push @{$opt->{extra_sim_signals}}, qw(
    state_idle
    state_busy
    pending_register_enable
    pending_upstream_read
    pending_upstream_read_reg
    pending_upstream_write
    pending_upstream_write_reg
  );
}

sub make_dbs_adjusted_upstream_burstcount($$$)
{
  my ($project, $module, $opt) = @_;
  
  if (!$opt->{dynamic_slave})
  {
    return;
  }

  my $adjusted_upstream_burstcount;
  if (!$opt->{dynamic_slave} || ($opt->{dbs_shift} == 0))
  {

    $adjusted_upstream_burstcount = "$opt->{upstream_burstcount}";
  }
  elsif ($opt->{dbs_shift} > 0)
  {

    $adjusted_upstream_burstcount = concatenate(
      "$opt->{upstream_burstcount}",
      sprintf("%d'b%s", $opt->{dbs_shift}, '0' x $opt->{dbs_shift})
    );
  }
  else
  {

    


    my $slave_mask_bits = (1 << $opt->{downstream_addr_shift}) - 1;
    my $master_shift = log2($opt->{master_data_width} / 8);
    my $upstream_byte_burst_count = concatenate(
      "$opt->{upstream_burstcount}",
      $master_shift ? sprintf("%d'b%s", $master_shift, '0' x $master_shift) : ''
    );



    e_assign->add([
      {
        name => "quantized_burst_base",
        width => $opt->{byteaddr_width}
      },
      "upstream_address & ~$slave_mask_bits"
    ]);
    my $master_mask_bits = (1 << $master_shift) - 1;
    e_assign->add([
      {name => "quantized_burst_limit", width => $opt->{byteaddr_width}},
      "(((upstream_address & ~$master_mask_bits) + $upstream_byte_burst_count - 1) | $slave_mask_bits) + 1"
    ]);

    e_assign->add([
      {name => "negative_dbs_read_expression", width => $opt->{dbs_upstream_burstcount_width}},
      "(quantized_burst_limit - quantized_burst_base) >> " . log2($opt->{ceil_data_width} / 8)
    ]);

    push @{$opt->{extra_sim_signals}}, qw(
      quantized_burst_base
      quantized_burst_limit
      negative_dbs_read_expression
    );
    



    $adjusted_upstream_burstcount = 
      "upstream_read ? negative_dbs_read_expression : $opt->{upstream_burstcount}";
  }

  e_assign->adds(
    {
      lhs => {name => 'dbs_adjusted_upstream_burstcount', width => $opt->{dbs_upstream_burstcount_width},},
      rhs => "pending_register_enable ? read_write_dbs_adjusted_upstream_burstcount : registered_read_write_dbs_adjusted_upstream_burstcount",
    },
    {
      lhs => {name => 'read_write_dbs_adjusted_upstream_burstcount', width => $opt->{dbs_upstream_burstcount_width},},
      rhs => $adjusted_upstream_burstcount,
    },
  );

   e_register->add({
      out => {name => 'registered_read_write_dbs_adjusted_upstream_burstcount', width => $opt->{dbs_upstream_burstcount_width},},
      in => "read_write_dbs_adjusted_upstream_burstcount",
      enable => 'pending_register_enable',
    });

  push @{$opt->{extra_sim_signals}}, qw(
    read_write_dbs_adjusted_upstream_burstcount
    registered_read_write_dbs_adjusted_upstream_burstcount
    dbs_adjusted_upstream_burstcount
  );
}

sub make_current_upstream_signals($$$)
{
  my ($project, $module, $opt) = @_;
  
  if (!$opt->{dynamic_slave})
  {
    e_register->adds(
      {
        out => {name => 'registered_upstream_address', width => $opt->{byteaddr_width}, never_export => 1,},
        in => 'upstream_address',
        enable => '~|transactions_remaining',
      },
    );
    e_assign->adds(
      {
        lhs => {name => 'current_upstream_address', width => $opt->{byteaddr_width}, never_export => 1,},
        rhs => "~|transactions_remaining ? upstream_address : registered_upstream_address",
      },
    );

    push @{$opt->{extra_sim_signals}}, qw(
      registered_upstream_address
      current_upstream_address
    );

    return;
  }

  e_register->adds(
    {
      out => 'registered_upstream_read',
      in => 'upstream_read',
      enable => 'pending_register_enable',
    },
    {
      out => 'registered_upstream_write',
      in => 'upstream_write',
      enable => 'pending_register_enable',
    },
    {
      out => {name => 'registered_upstream_burstcount', width => $opt->{upstream_burstcount_width},},
      in => "$opt->{upstream_burstcount}",
      enable => 'pending_register_enable',
    },
    {
      out => {name => 'registered_upstream_address', width => $opt->{byteaddr_width},},
      in => 'upstream_address',
      enable => 'pending_register_enable',
    },
    {
      out => {name => 'registered_upstream_nativeaddress', width => $opt->{nativeaddr_width},},
      in => 'upstream_nativeaddress',
      enable => 'pending_register_enable',
    },
  );

  e_assign->adds(
    {
      lhs => 'current_upstream_read',
      rhs => "registered_upstream_read & !downstream_write",
    },
    {
      lhs => 'current_upstream_write',
      rhs => "registered_upstream_write",
    },
    {
      lhs => {name => 'current_upstream_address', width => $opt->{byteaddr_width},},
      rhs => "registered_upstream_address",
    },




    {
      lhs => {
        name => 'current_upstream_burstcount',
        width => $opt->{upstream_burstcount_width},
        never_export => 1,
      },
      rhs => "pending_register_enable ? $opt->{upstream_burstcount} : registered_upstream_burstcount",
    },
  );
  
  push @{$opt->{extra_sim_signals}}, qw(
    current_upstream_read
    current_upstream_burstcount
    current_upstream_address
    registered_upstream_read
    registered_upstream_address
  );
}

sub make_upstream_waitrequest($$$)
{
  my ($project, $module, $opt) = @_;

  if (!$opt->{dynamic_slave})
  {

    e_assign->adds([
      'upstream_waitrequest',
      'downstream_waitrequest | (|transactions_remaining)',
    ]);

    return;
  }

  e_assign->adds 
  (
    ["upstream_read_run", "state_idle & upstream_read"],
    ["upstream_write_run", "state_busy & upstream_write & "
     ."~downstream_waitrequest & !downstream_read",],
    ["upstream_waitrequest", 
      "(upstream_read | current_upstream_read) ? ~upstream_read_run : " .
      "current_upstream_write ? ~upstream_write_run : " .
       "1"
     ],
  );    
}

sub make_debugaccess
{
  my ($project, $module, $opt) = @_;
  e_assign->add(["downstream_debugaccess", "upstream_debugaccess"]);    
}

sub set_sim_wave_signals
{
  my ($project, $module, $opt) = @_;

  if ($project->system_ptf()->{WIZARD_SCRIPT_ARGUMENTS}->{do_burst_adapter_sim_wave})
  {
    my @sim_signals = qw(
        downstream_address
        downstream_burstcount
        downstream_byteenable
        downstream_read
        downstream_readdata
        downstream_waitrequest
        downstream_write
        downstream_writedata

        upstream_address
        upstream_burstcount
        upstream_byteenable
        upstream_read
        upstream_readdata
        upstream_waitrequest
        upstream_write
        upstream_writedata
    );
    
    push @sim_signals, @{$opt->{extra_sim_signals}};
    
    my %uniq = map {$_ => 1} @sim_signals;

    set_sim_ptf(
      [sort keys %uniq],
      $module,
      $project);
  }
}

sub set_sim_ptf
{
  my ($signals, $module, $project) = @_;
  


  my @bus_signals = qw(
    address
    data$
  );
  
  my $module_name = $module->name();
  my $sys_ptf = $project->system_ptf();
  my $mod_ptf = $sys_ptf->{"MODULE $module_name"};
  $mod_ptf->{SIMULATION} = {} if (!defined($mod_ptf->{SIMULATION}));
  $mod_ptf->{SIMULATION}->{DISPLAY} = {} if (!defined($mod_ptf->{SIMULATION}->{DISPLAY})); 
  
  my $sig_ptf = $mod_ptf->{SIMULATION}->{DISPLAY};

  my $signum = 0;
  my $tag;
  for my $sig (@$signals)
  {
    my $tag = to_base_26($signum);
    my $radix;
    my $format;
    my $name;
    
    if ($sig =~ /Divider\s*(.*)/)
    {
      $name = $1;
      $format = 'Divider';
      $radix = '';
    }
    else
    {
      $name = $sig;
      $radix = 'hexadecimal';
      $format = 'Logic';
      if (grep {$sig =~ /$_/} @bus_signals)
      {
        $format = 'Literal';
      }
    }

    $sig_ptf->{"SIGNAL $tag"} = {name => $name, radix => $radix, format => $format};
    $signum++;  
  }
}



sub get_connections
{
  my ($project, $module, $opt) = @_;

  my @masters = $project->get_my_masters_through_bridges(
    $module->name(), 
    "upstream",
    0,
    1,
  );
  if (@masters != 1)
  {
    ribbit("Unexpected: number of masters is not 1: ", join("; ", @masters),
    "\n");
  }

  my @slaves = 
    $project->get_slaves_by_master_name($module->name(), "downstream");
  if (@masters != 1)
  {
    ribbit("Unexpected: number of slaves is not 1: ", join("; ", @slaves),
    "\n");
  }

  return ($masters[0], $slaves[0]);
}













sub make_downstream_pipeline
{
  my ($project, $module, $opt, $upstream_slave, $downstream_master) = @_;

  return if !$opt->{downstream_pipeline};

  my @downstream_output_names = 
    grep {/^downstream_/} ($module->get_output_names());
  my @downstream_outputs = ();

  for my $sig (@downstream_output_names)
  {
    my $obj = $module->get_object_by_name($sig);
    if ($obj)
    {
      push @downstream_outputs, $obj;
    }
    else
    {
      ribbit("didn't find signal '$sig'");
    }
  }

  my $downstream_type_map = $downstream_master->type_map();

  for my $obj (@downstream_outputs)
  {
    my $name = $obj->name();
    my $width = $obj->width();
    my $type = $obj->type();
    $obj->never_export(1);
    $obj->export(0);
    $obj->type('');
 
    my $new_name = "reg_" . $name;


    e_register->add({
      out => {name => $new_name, width => $width, export => 1, type => $type,},
      in => $name,
      enable => complement("downstream_waitrequest"),
    });

    delete $downstream_type_map->{$name};
    $downstream_type_map->{$new_name} = $type;
  }
}

sub make_adapter
{
  my $project = shift;
  my $module = $project->top();
  my $marker = e_default_module_marker->new($module);
  my $opt = copy_of_hash($project->WSA());

  assign_options($project, $module, $opt);
  validate_options($project, $module, $opt);

  my ($adapter_master, $adapter_slave) = 
    get_connections($project, $module, $opt);



  my @printable_keys = grep {"" eq ref($opt->{$_})} keys %$opt;
  $module->comment(
    $module->comment() .
    "\nBurst adapter parameters:\n" .
    "adapter is mastered by: $adapter_master\n" .
    "adapter masters: $adapter_slave\n" .
    join("\n", (map {"$_: $opt->{$_}"} sort @printable_keys)) .
    "\n\n"
  );
  
  my ($upstream_slave, $downstream_master) = 
    make_interfaces($project, $module, $opt);
  make_burstdone_signals($project, $module, $opt);
  make_dbs_adjusted_upstream_burstcount($project, $module, $opt);
  make_state_machine($project, $module, $opt);
  make_current_upstream_signals($project, $module, $opt);
  make_counters($project, $module, $opt);
  make_downstream_burstcount($project, $module, $opt);
  make_downstream_arbitrationshare($project, $module, $opt);
  make_downstream_address($project, $module, $opt);
  make_downstream_read($project, $module, $opt);
  make_upstream_readdata($project, $module, $opt);
  make_downstream_write($project, $module, $opt);
  make_downstream_writedata($project, $module, $opt);
  make_upstream_waitrequest($project, $module, $opt);
  make_debugaccess($project, $module, $opt);
  make_downstream_pipeline($project, $module, $opt, $upstream_slave,
    $downstream_master);


  set_sim_wave_signals($project, $module, $opt);
} 

1;

