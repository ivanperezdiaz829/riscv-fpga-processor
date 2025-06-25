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
use filename_utils;  # This is for to Perlcopy 'uart.pl'
use europa_all;      # This imports the entire Eurpoa object-library.
use strict;          # This spanks you when you're naughty.  That's












my $project = e_project->new(@ARGV);

&make_uart ($project);

$project->output() unless $project->_software_only();


















sub Validate_Uart_Options
{
  my ($Options, $project) = (@_);
  





































  &validate_parameter ({hash    => $Options,
                        name    => "fixed_baud",
                        type    => "boolean",
                        default => 1,
                       });



























  &validate_parameter ({hash    => $Options,
                        name    => "use_cts_rts",
                        type    => "boolean",
                        default => 0,
                       });
































  &validate_parameter ({hash    => $Options,
                        name    => "use_eop_register",
                        type    => "boolean",
                        default => 0,
                       });













  &validate_parameter ({hash      => $Options,
                        name      => "data_bits",
                        type      => "integer",
                        allowed   => [7, 8, 9],
                        default   => 8,
                       });













  &validate_parameter ({hash      => $Options,
                        name      => "stop_bits",
                        type      => "integer",
                        allowed   => [1, 2],
                        default   => 2,
                       });



































  &validate_parameter ({hash      => $Options,
                        name      => "parity",
                        type      => "string",
                        allowed   => ["S0", "S1", "E", "O", "N"],
                        default   => "N",
                       });










  &validate_parameter ({hash      => $Options,
                        name      => "sync_reg_depth",
                        type      => "integer",
                        allowed   => [2, 3, 4, 5],
                        default   => 2,
                        message   => "invalid synchronizer depth", 
                       });













  &validate_parameter ({hash      => $Options,
                        name      => "baud",
                        type      => "integer",
                        allowed   => [   300,
                                        1200,
                                        2400,
                                        4800,
                                        9600,
                                       14400,
                                       19200,
                                       28800,
                                       31250,
                                       38400,
                                       57600,
                                      115200,],
                        default  =>   115200,
                        severity => "warning",
                       });

  &validate_parameter ({hash      => $Options,
                        name      => "baud",
                        type      => "integer",
                       });

  &validate_parameter ({hash      => $Options,
                        name      => "clock_freq",
                        type      => "integer",
                       });

























  &validate_parameter ({hash      => $Options,
                        name      => "sim_true_baud",
                        type      => "boolean",
                        default   => "0",
                       });




  $Options->{baud_divisor_constant} =
    int ( ($Options->{clock_freq} / $Options->{baud}) + 0.5);

  $Options->{divisor_bits} = 
      &Bits_To_Encode ($Options->{baud_divisor_constant});


  if (!$Options->{fixed_baud}) {
    $Options->{divisor_bits} = max ($Options->{divisor_bits}, 16);
  }

  &validate_parameter ({hash    => $Options,
                        name    => "divisor_bits",
                        type    => "integer",
                        range   => [1,16],
                        message => "cannot make desired baud rate from clock",
                       });

  $Options->{num_control_reg_bits} =
    ($Options->{use_cts_rts} | $Options->{use_eop_register}) ? 13 : 10 ;





  $Options->{num_status_reg_bits} = 13;





  return 1;
}
















sub Setup_Input_Stream
{
  my ($Options, $project) = (@_);

  if (($Options->{sim_char_file}   ne "") && 
      ($Options->{sim_char_stream} ne "")) {
    &ribbit
      ("Cannot set 'sim_char_stream' parameter when using 'sim_char_file'");
  }

  my $char_stream = $Options->{sim_char_stream};

  if ($Options->{sim_char_file} ne "") {
    $char_stream = "";
    open (CHARFILE, "< $Options->{sim_char_file}")
      or &ribbit ("Cannot open input-file $Options->{sim_char_file} ($!)");
    while (<CHARFILE>) {
      $char_stream .= $_;
    }
    close CHARFILE;
  }




  my $newline      = "\n";
  my $cr           = "\n";
  my $double_quote = "\"";
  


  $char_stream =~ s/\\n\\r/\n/sg;
  
  $char_stream     =~ s/\\n/$newline/sg;
  $char_stream     =~ s/\\r/$cr/sg;
  $char_stream     =~ s/\\\"/$double_quote/sg;

  my $crlf = "\n\r";
  $char_stream =~ s/\n/$crlf/smg;

  $Options->{stream_length} = length ($char_stream);
  
  $Options->{char_data_file} = $Options->{name} . "_input_data_stream.dat";
  $Options->{char_mutex_file} = $Options->{name} . "_input_data_mutex.dat";

  my $sim_dir_name = $project->simulation_directory();
  &Create_Dir_If_Needed($sim_dir_name);

  open (DATFILE, "> $sim_dir_name/$Options->{char_data_file}") 
    or &ribbit ("couldn't open $sim_dir_name/$Options->{char_data_file} ($!)");

  my $addr = 0;
  foreach my $char (split (//, $char_stream)) {
    printf DATFILE "\@%X\n", $addr; 
    printf DATFILE "%X\n", ord($char);
    $addr++;
  }

  printf DATFILE "\@%X\n", $addr;
  printf DATFILE "%X\n", 0;

  close DATFILE;

  open (MUTFILE, "> $sim_dir_name/$Options->{char_mutex_file}") 
   or &ribbit ("couldn't open $sim_dir_name/$Options->{char_mutex_file} ($!)");
  

  if ($Options->{interactive_in})
  { # force user to use interactive window if selected by making mutex 0
      printf MUTFILE "0\n";
  }
  else
  { # set up proper stream file size in Mutex:
      printf MUTFILE "%X\n", $addr;
  }

  close MUTFILE;
  $Options->{mutex_file_size} = $addr;
}


































sub make_uart
{
  my ($project) = (@_);

  my $module  = $project->top();
  my $Options = &copy_of_hash ($project->WSA());




  $Options->{name}       = $module->name();
  my $clock_freq = $project->get_module_clock_frequency();
  $clock_freq || &ribbit ("Couldn't find Clock frequency\n");
  $Options->{clock_freq} = $clock_freq;


  my $int_in_section = 
$project->spaceless_module_ptf($Options->{name})->{SIMULATION}{INTERACTIVE_IN};
  my $int_out_section=
$project->spaceless_module_ptf($Options->{name})->{SIMULATION}{INTERACTIVE_OUT};
  my $interactive_in = 0; # default to non-interactive mode.
  my $interactive_out= 0;

  my $int_key;
  my $this_int_section;

  foreach $int_key (sort(keys (%{$int_in_section}))) {
      $this_int_section = $int_in_section->{$int_key};
      $interactive_in = $this_int_section->{enable};

  }


  foreach $int_key (sort(keys (%{$int_out_section}))) {
      $this_int_section = $int_out_section->{$int_key};
      $interactive_out = $this_int_section->{enable};

  }

  $Options->{interactive_in} = $interactive_in;
  $Options->{interactive_out}= $interactive_out;

  &Validate_Uart_Options ($Options, $project);




  &Setup_Input_Stream ($Options, $project);
  




  return if $project->_software_only();







  $Options->{tx_module_name}  = $Options->{name} . "_tx";
  $Options->{rx_module_name}  = $Options->{name} . "_rx";
  $Options->{reg_module_name} = $Options->{name} . "_regs";
  $Options->{log_module_name} = $Options->{name} . "_log";

  my $tx_module  = &make_uart_tx  ($Options);
  my $rx_module  = &make_uart_rx  ($Options);
  my $reg_module = &make_uart_regs($Options);
  my $log_instance = &make_uart_log ($Options);






  my $marker = e_default_module_marker->new ($module);
  $module->add_attribute (altera_attribute => "-name SYNCHRONIZER_IDENTIFICATION OFF");







  e_assign->add(["clk_en", 1]);

  e_instance->add ({module => $tx_module });
  e_instance->add ({module => $rx_module });
  e_instance->add ({module => $reg_module});

  $module->add_contents ( $log_instance );



  if ($Options->{interactive_in})
  {
      &Perlcopy ($project->_module_lib_dir . "/uart.pl",
		 $project->simulation_directory () . "/uart.pl" );
  }


  if ($Options->{interactive_out})
  {
      &Perlcopy ($project->_module_lib_dir . "/tail-f.pl",
                 $project->simulation_directory () . "/tail-f.pl" );
  }
  










  e_avalon_slave->add ({name => "s1"});

  return $module;
}







sub make_uart_log {
    my ($Options) = (@_);
    return e_log->new ({
	name            => $Options->{"log_module_name"},
	tag             => "simulation",
	relativepath    => $Options->{"relativepath"},
	port_map        => {
	    "valid"	=> "~tx_ready",
	    "strobe"	=> "tx_wr_strobe",
	    "data"	=> "tx_data",
	    "log_file"	=> $Options->{log_file},
	},
    });
    
};

sub make_uart_tx
{
  my ($Options) = (@_);


  my $module = e_module->new ({name  => $Options->{tx_module_name}});
  my $marker = e_default_module_marker->new ($module);









  e_assign->add (["tx_wr_strobe_onset",  "tx_wr_strobe && begintransfer"]),




  my $parity_expr = "";
     $parity_expr = "1'b0"        if ($Options->{parity} =~ /^S0$/i);
     $parity_expr = "1'b1"        if ($Options->{parity} =~ /^S1$/i);
     $parity_expr = "  ^tx_data " if ($Options->{parity} =~ /^E$/i );
     $parity_expr = "~(^tx_data)" if ($Options->{parity} =~ /^O$/i );


  my $tx_shift_bits = 
    ($Options->{stop_bits}             )  +   # stop bits.
    ($Options->{parity} =~ /N/i ? 0 : 1)  +   # parity bit (opt.)
    ($Options->{data_bits}             )  +   # "payload"
    (1                                 )  ;   # start-bit


  e_signal->add(["tx_data", $Options->{data_bits}]);

  my $load_val_expr = &concatenate ("\{$Options->{stop_bits} \{1'b1\}\}",
                                    $parity_expr,
                                    "tx_data",
                                    "1'b0",
                                   );

  e_assign->add ({lhs => e_signal->add (["tx_load_val", $tx_shift_bits]),
                  rhs => $load_val_expr,
  });










  e_assign->add (["shift_done", "~(|tx_shift_register_contents)"]);

  e_register->add ({out => "do_load_shifter",
                     in  => "(~tx_ready) && shift_done",
                    });











  e_register->add ({
    out         => e_port->add (["tx_ready", 1, "out"]),
    sync_set    => "do_load_shifter",
    sync_reset  => "tx_wr_strobe_onset",
    async_value => "1'b1",
  });




  e_register->add ({
    out        => "tx_overrun",
    sync_set   => "(~tx_ready && tx_wr_strobe_onset)",
    sync_reset => "status_wr_strobe",
  });

  e_register->add ({
    out         => "tx_shift_empty",
    in          => "tx_ready && shift_done",
    async_value => "1'b1",
  });













  e_register->add ({
      out        => e_signal->add({name  => "baud_rate_counter",
                                   width => $Options->{divisor_bits}
                                  }),
      in         => "baud_rate_counter - 1",
      sync_set   => "baud_rate_counter_is_zero || do_load_shifter",
      set_value  => "baud_divisor",
    });

  e_assign->add(["baud_rate_counter_is_zero", "baud_rate_counter == 0"]);

  e_register->add ({out    => "baud_clk_en",
                    in     => "baud_rate_counter_is_zero",
                   });









  e_assign->add(["do_shift", "baud_clk_en  && 
                             (~shift_done) && 
                             (~do_load_shifter)"
   ]);

  e_shift_register->add ({
    serial_out   => "tx_shift_reg_out",
    serial_in    => "1'b0",
    parallel_in  => "tx_load_val",
    parallel_out => "tx_shift_register_contents",
    shift_length => $tx_shift_bits,
    direction    => "LSB-first",
    load         => "do_load_shifter",
    shift_enable => "do_shift",
  });










  e_register->add({
    out         => "pre_txd",
    in          => "tx_shift_reg_out",
    enable      => "~shift_done",
    async_value => "1",
  });

  e_register->add ({
    out         => "txd",
    in          => "pre_txd & ~do_force_break",
    async_value => "1",
  });

  return $module;
}
















































sub make_uart_rx
{
  my ($Options) = (@_);






  $Options->{rx_source_module_name} = 
  $Options->{rx_module_name} . "_stimulus_source";
  my $stim_module = &make_uart_rxd_source($Options);


  my $module = e_module->new ({name  => $Options->{rx_module_name}});
  my $marker = e_default_module_marker->new ($module);
  my $depth;

  if ($Options->{sync_reg_depth}) {
     $depth  = $Options->{sync_reg_depth};
  } else {
     $depth  = "2";
  }

  e_instance->add ({module => $stim_module});











  e_std_synchronizer->add({
     data_in  => "source_rxd",
     data_out => "sync_rxd",
     clock    => "clk",
     reset_n  => "reset_n",
     depth    => "$depth",
     comment  => "e_std_synchronizer",
  });


  e_edge_detector->add({
    in     => "sync_rxd",
    out    => "rxd_falling",
    edge   => "falling",
  });

  e_edge_detector->add({
    in     => "sync_rxd",
    out    => "rxd_edge",
    edge   => "any",
  });










  e_assign->add (["rx_rd_strobe_onset", "rx_rd_strobe && begintransfer"]);


























  e_signal->add (["half_bit_cell_divisor", $Options->{divisor_bits} - 1]);
  e_assign->add ({
    lhs => "half_bit_cell_divisor",
    rhs => 'baud_divisor [baud_divisor.msb : 1]',
  });

  e_mux->add ({
    lhs     => e_signal->add (["baud_load_value", $Options->{divisor_bits}]),
    table   => [rxd_edge => "half_bit_cell_divisor"],
    default => "baud_divisor",
  });

  e_register->add ({
    out       => e_signal->add(["baud_rate_counter",$Options->{divisor_bits}]),
    in        => "baud_rate_counter - 1",
    sync_set  => "baud_rate_counter_is_zero || rxd_edge",
    set_value => "baud_load_value",
  });

  e_assign->add (["baud_rate_counter_is_zero", "baud_rate_counter == 0"]);

  e_register->add ({
    in        => "baud_rate_counter_is_zero",
    out       => "baud_clk_en",
    sync_set  => "rxd_edge",
    set_value => "0",
  });










  e_assign->add (["sample_enable", "baud_clk_en && rx_in_process"]);

  e_register->add ({
    out         => "do_start_rx",
    in          => "0",
    sync_set    => "(~rx_in_process && rxd_falling)",
    set_value   => "1",
    async_value => "0",
  });







  my $rx_shift_bits = 
    (1                                 )  +   # stop bit.
    ($Options->{parity} =~ /N/i ? 0 : 1)  +   # parity bit (opt.)
    ($Options->{data_bits}             )  +   # "payload"
    (1                                 )  ;

  e_shift_register->add ({
    parallel_out => "rxd_shift_reg",
    serial_in    => "sync_rxd",
    serial_out   => "shift_reg_start_bit_n",
    parallel_in  => "\{$rx_shift_bits\{1'b1\}\}",
    shift_length => $rx_shift_bits,
    direction    => "LSB-first",
    load         => "do_start_rx",
    shift_enable => "sample_enable",
  });

  e_assign->add (["rx_in_process", "shift_reg_start_bit_n"]);



  e_signal->add (["raw_data_in", $Options->{data_bits}]);








  my $start_bit_sig = e_signal->add(["unused_start_bit", 1]);
  $start_bit_sig->never_export(1);

  my    @register_segments = ("stop_bit"  );
  push (@register_segments,   "parity_bit") unless $Options->{parity} =~/^N$/i;
  push (@register_segments,   "raw_data_in",
                              "unused_start_bit");

  e_assign->add([&concatenate (@register_segments), "rxd_shift_reg"]);









  e_assign->adds(["is_break",         "~(|rxd_shift_reg)"      ],
                 ["is_framing_error", "~stop_bit && ~is_break" ]);




  e_edge_detector->add ({
    out    => "got_new_char",
    in     => "rx_in_process",
    edge   => "falling",
  });

  e_register->add({
    in     => "raw_data_in",
    out    => e_signal->add(["rx_data", $Options->{data_bits}]),
    enable => "got_new_char",
  });

  e_register->add({
    out        => "framing_error",
    sync_set   => "(got_new_char && is_framing_error)",
    sync_reset => "status_wr_strobe",
  });

  e_register->add({
    out        => "break_detect",
    sync_set   => "(got_new_char && is_break)",
    sync_reset => "status_wr_strobe",
  });

  e_register->add({
    out        => "rx_overrun",
    sync_set   => "(got_new_char && rx_char_ready)",
    sync_reset => "status_wr_strobe",
  });

  e_register->add({
    out        => e_port->add (["rx_char_ready", 1, "out"]),
    sync_set   => "got_new_char",
    sync_reset => "rx_rd_strobe_onset",
    priority   => "reset",
  });



  if ($Options->{parity} =~ /^N$/i) {
    e_assign->add (["parity_error", "0"]);
  } else {
    my $correct_parity_expr = "";
    $correct_parity_expr = "0"               if $Options->{parity} =~ /^S0$/i;
    $correct_parity_expr = "1"               if $Options->{parity} =~ /^S1$/i;
    $correct_parity_expr = " (^raw_data_in)" if $Options->{parity} =~ /^E$/i;
    $correct_parity_expr = "~(^raw_data_in)" if $Options->{parity} =~ /^O$/i;

    e_assign->add (["correct_parity", $correct_parity_expr]);

    e_assign->add ({
      lhs    => "is_parity_error",
      rhs    => "(correct_parity != parity_bit) && ~is_break",
    });

    e_register->add ({
      out        => "parity_error",
      sync_set   => "got_new_char && is_parity_error",
      sync_reset => "status_wr_strobe",
    });
  }

  return $module;
}



























sub make_uart_regs
{


  my ($Options) = (@_);


  my $module = e_module->new ({name  => $Options->{reg_module_name}});
  my $marker = e_default_module_marker->new ($module);







  e_register->add({
   out => e_signal->add (["readdata",           16]),
   in  => e_signal->add (["selected_read_data", 16]),
  });

  e_register->add({
    out    => "irq",
    in     => "qualified_irq",
  });










  e_port->adds (
    ["address",          3,                        "in" ],
    ["writedata",       16,                        "in" ],
    ["tx_wr_strobe",     1,                        "out"],
    ["status_wr_strobe", 1,                        "out"],
    ["rx_rd_strobe",     1,                        "out"],
    ["baud_divisor",     $Options->{divisor_bits}, "out"],
  );

  e_assign->adds(
    ["rx_rd_strobe",      "chipselect && ~read_n  && (address == 3'd0)"],
    ["tx_wr_strobe",      "chipselect && ~write_n && (address == 3'd1)"],
    ["status_wr_strobe",  "chipselect && ~write_n && (address == 3'd2)"],
    ["control_wr_strobe", "chipselect && ~write_n && (address == 3'd3)"],
  );
  e_assign->add([
     "divisor_wr_strobe", "chipselect && ~write_n  && (address == 3'd4)",
  ]) if !$Options->{fixed_baud};
  e_assign->add([
     "eop_char_wr_strobe","chipselect && ~write_n  && (address == 3'd5)",
  ]) if  $Options->{use_eop_register};




  my $tx_data_sig = e_signal->add(["tx_data", $Options->{data_bits}]);
  $tx_data_sig->export(1);

  e_register->add ({
    out    => $tx_data_sig,
    in     => "writedata\[tx_data.msb : 0\]",
    enable => "tx_wr_strobe",
  });

  e_register->add ({
    out    => e_signal->add(["control_reg", $Options->{num_control_reg_bits}]),
    in     => "writedata\[control_reg.msb:0\]",
    enable => "control_wr_strobe",
  });

  e_register->add ({
    out    => e_signal->add(["eop_char_reg", $Options->{data_bits}]),
    in     => "writedata\[eop_char_reg.msb:0\]",
    enable => "eop_char_wr_strobe",
  }) if $Options->{use_eop_register};







  e_edge_detector->add ({
    tag  => "simulation",
    out  => "do_write_char",
    in   => "tx_ready",
  });

  e_process->add ({ 
    tag  => "simulation",
    contents => [
      e_if->new ({
      tag  => "simulation",
      condition       => "do_write_char",
      then            => [
        e_sim_write->new ({
          spec_string => '%c', 
          expressions => ["tx_data"],
        })
      ],
    }),
  ]});



  e_signal->add (["divisor_constant", $Options->{divisor_bits}]);
  e_assign->add ({
    tag  => $Options->{sim_true_baud} ? "normal" : "synthesis",
    lhs  => "divisor_constant",
    rhs  => $Options->{baud_divisor_constant}
  });
  e_assign->add ({
    tag   => "simulation",
    lhs   => "divisor_constant",
    rhs   => 4,
  }) if !$Options->{sim_true_baud};




  if ($Options->{fixed_baud}) {
    e_assign->add(["baud_divisor", "divisor_constant"]);
  } else {
    e_register->add ({
      in          => "writedata\[baud_divisor.msb:0\]",
      out         => "baud_divisor",
      enable      => "divisor_wr_strobe",
      async_value => "divisor_constant",
    });
  }







  if ($Options->{use_cts_rts}) {
    e_register->add ({
      in          => "~cts_n",
      out         => "cts_status_bit",
      async_value => 1,
    });

    e_edge_detector->add ({
      in     => "cts_status_bit",
      out    => "cts_edge",
      edge   => "any",
    });

    e_register->add ({
      out         => "dcts_status_bit",
      sync_set    => "cts_edge",
      sync_reset  => "status_wr_strobe",
      async_value => 0,
    });




    e_assign->add (["rts_n", "~rts_control_bit"]);
  } else {


    e_assign->adds (["cts_status_bit",  0],
                    ["dcts_status_bit", 0]);
  }







  e_signal->adds({name => "rts_control_bit", never_export => 1},
                 {name => "ie_dcts",         never_export => 1});

  my @control_reg_bits = ();

  push (@control_reg_bits, "ie_eop"  ) if $Options->{use_eop_register};
  push (@control_reg_bits, "rts_control_bit",
                           "ie_dcts" ) if ($Options->{use_cts_rts} |
                                           $Options->{use_eop_register});

  push (@control_reg_bits, "do_force_break",
                           "ie_any_error",
                           "ie_rx_char_ready",
                           "ie_tx_ready",
                           "ie_tx_shift_empty",
                           "ie_tx_overrun",
                           "ie_rx_overrun",
                           "ie_break_detect",
                           "ie_framing_error",
                           "ie_parity_error",
       );

  e_assign->add([&concatenate(@control_reg_bits), "control_reg"]);




  e_assign->add ({
    lhs    => "any_error",
    rhs    => join (" ||\n", "tx_overrun",
                             "rx_overrun",
                             "parity_error",
                             "framing_error",
                             "break_detect",
                   ),
  });

  my @status_reg_bits = ();
  push (@status_reg_bits, "eop_status_bit",
                          "cts_status_bit",
                          "dcts_status_bit",
                          "1'b0",
                          "any_error",
                          "rx_char_ready",
                          "tx_ready",
                          "tx_shift_empty",
                          "tx_overrun",
                          "rx_overrun",
                          "break_detect",
                          "framing_error",
                          "parity_error",
       );

  e_assign->add ({
    lhs => e_signal->add(["status_reg", $Options->{num_status_reg_bits}]),
    rhs => &concatenate (@status_reg_bits),
  });































































  e_register->add({
    in => "rx_char_ready",
  });
  e_register->add({
    in => "tx_ready",
  });

  e_assign->adds 
    ([e_port->new (["dataavailable", 1, "out"]),  "d1_rx_char_ready"],
     [e_port->new (["readyfordata",  1, "out"]),  "d1_tx_ready"     ] );














  if ($Options->{use_eop_register}) {
     e_register->add ({
        out         => "eop_status_bit",

        sync_set    => "(rx_rd_strobe && (eop_char_reg == rx_data)) ||
                        (tx_wr_strobe && 
                          (eop_char_reg == writedata\[tx_data.msb:0\]))",
        sync_reset  => "status_wr_strobe",
        async_value => 0,
     });
     e_assign->add 
         ([e_port->new (["endofpacket", 1, "out"]), "eop_status_bit"]);
  } else {

     e_assign->add (["eop_status_bit", "1'b0"]);
  }




  my @read_mux_table = (
    "(address == 3'd0)" => "rx_data",
    "(address == 3'd1)" => "tx_data",
    "(address == 3'd2)" => "status_reg",
    "(address == 3'd3)" => "control_reg",
  );

  push (@read_mux_table, "(address == 3'd4)" => "baud_divisor") 
    if !$Options->{fixed_baud};

  push (@read_mux_table, "(address == 3'd5)" => "eop_char_reg") 
    if  $Options->{use_eop_register};

  e_mux->add ({
    lhs    => e_signal->add(["selected_read_data", 16]),
    table  => \@read_mux_table,
    type   => "and-or",
  });




  my @irq_terms = ();
  push (@irq_terms, "(ie_dcts           && dcts_status_bit )")
    if $Options->{use_cts_rts};
  push (@irq_terms, "(ie_eop            && eop_status_bit  )")
    if $Options->{use_eop_register};

  push (@irq_terms, "(ie_any_error      && any_error      )",
                    "(ie_tx_shift_empty && tx_shift_empty )",
                    "(ie_tx_overrun     && tx_overrun     )",
                    "(ie_rx_overrun     && rx_overrun     )",
                    "(ie_break_detect   && break_detect   )",
                    "(ie_framing_error  && framing_error  )",
                    "(ie_parity_error   && parity_error   )",
                    "(ie_rx_char_ready  && rx_char_ready  )",
                    "(ie_tx_ready       && tx_ready       )",
       );

  e_assign->add (["qualified_irq", join (" ||\n", @irq_terms)]);

  return $module,
}




















sub make_uart_rxd_source
{
  my ($Options) = (@_);
  my $module = e_module->new ({name  => $Options->{rx_source_module_name}});
  my $marker = e_default_module_marker->new ($module);






  e_port->adds(
    ["rxd",           1,                        "in"],
    ["source_rxd",    1,                       "out"],
    ["rx_char_ready", 1,                        "in"],
    ["clk",           1,                        "in"],
    ["clk_en",        1,                        "in"],
    ["reset_n",       1,                        "in"],
    ["rx_char_ready", 1,                        "in"],
    ["baud_divisor",  $Options->{divisor_bits}, "in"],
  );





  e_assign->add({
   tag  => "synthesis",
   lhs  => "source_rxd",
   rhs  => "rxd",
  });








  my @dummies = e_signal->adds (
    ["unused_overrun"],
    ["unused_ready"  ],
    ["unused_empty"  ],
  );

  foreach my $dummy_sig (@dummies) {
    $dummy_sig->never_export   (1);
  }

  e_instance->add ({
    module             => $Options->{"tx_module_name"},
    name               => "stimulus_transmitter",
    tag                => "simulation",
    port_map           => {
      txd                => "source_rxd",
      tx_overrun         => "unused_overrun",
      tx_ready           => "unused_ready",
      tx_shift_empty     => "unused_empty",
      do_force_break     => "1'b0",
      status_wr_strobe   => "1'b0",
      tx_data            => "d1_stim_data",
      begintransfer      => "do_send_stim_data",
      tx_wr_strobe       => "1'b1",
    },
  });





  e_signal->add ({
    tag             => "simulation",
    name            => "stim_data",
    width           => $Options->{data_bits},
  });


  e_register->add ({
    tag    => "simulation",
    in     => "stim_data",
    out    => e_signal->add(["d1_stim_data", $Options->{data_bits}]),
    enable => "do_send_stim_data",
  });
















  my $size = &max ($Options->{mutex_file_size} + 1, 1024);  

  e_drom->add ({
     name	    => $module->name()."_character_source_rom",
     rom_size       => $size,
     dat_name	    => $Options->{char_data_file},
     mutex_name	    => $Options->{char_mutex_file},
     interactive    => $Options->{interactive_in},
     relativepath   => $Options->{"relativepath"},
     allow_missing_mutex_file => 1,
     port_map	    => {"q"         => "stim_data",
			"new_rom"   => "new_rom_pulse",
			"incr_addr" => "do_send_stim_data",
		    }
  });





















  e_edge_detector->add ({
    tag             => "simulation",
    out             => "pickup_pulse",
    in              => "rx_char_ready",
    edge            => "falling",
  });





  e_assign->add ({
    tag             => "simulation",
    lhs             => "do_send_stim_data",
    rhs             => "(pickup_pulse || new_rom_pulse) && safe",
  });

  return $module;
}
