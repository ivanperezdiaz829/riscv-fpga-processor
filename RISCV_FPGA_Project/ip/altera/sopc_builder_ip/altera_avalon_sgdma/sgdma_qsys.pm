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
use control_status_slave;
use chain_read;
use chain_writeback;
use chain;
use command_grabber;
use read_block;
use readblockfifo;
use writeblockfifo;
use write_block;
use e_efifo;
use scfifo;
use e_atlantic_master;
use e_atlantic_slave;
use rx_barrel;
use tx_barrel;


my $debug = 0;

my $csr_name = "csr";
my $descriptor_read_name = "descriptor_read";
my $descriptor_write_name = "descriptor_write";
my $m_read_name = "m_read";
my $m_write_name = "m_write";

sub make_sgdma {
  if (!@_) {
    return;
  }
  my ($proj, $mod, $WSA) = (@_);


  
  my $module_name = $mod->name;
  print "Module name : $module_name \n" if $debug;


  
  my $pre_elaborated_device_family = $WSA->{"Device_Family"};
  my $device_family = do_device_family_name_mapping($pre_elaborated_device_family);
  print "Dev Family : $device_family\n" if $debug;

  print "WSA : \n $WSA \n" if $debug;

  my $HAS_READ_BLOCK = $WSA->{"has_read_block"};
  my $HAS_WRITE_BLOCK = $WSA->{"has_write_block"};
  my $ADDRESS_WIDTH = $WSA->{"address_width"};
  my $STATUS_TOKEN_WIDTH = $WSA->{"status_token_data_width"};
  my $DESC_WIDTH = 256;
  my $COMMAND_FIFO_DATA_WIDTH = $WSA->{"command_fifo_data_width"};
  my $STREAM_DATA_WIDTH = $WSA->{"stream_data_width"};
  my $SYMBOLS_PER_BEAT = $WSA->{"symbols_per_beat"};
  my $SINK_ERROR_WIDTH = $WSA->{"in_error_width"};
  my $OUT_ERROR_WIDTH = $WSA->{"out_error_width"}; 
  my $UNALIGNED_TRANSFER = $WSA->{"unaligned_transfer"};
  my $READ_BLOCK_DATA_WIDTH = $WSA->{"read_block_data_width"};
  my $WRITE_BLOCK_DATA_WIDTH = $WSA->{"write_block_data_width"};
  my $DESCRIPTOR_READ_BURST = $WSA->{"descriptor_read_burst"};
  my $BURST_TRANSFER = $WSA->{"burst_transfer"};
  my $is_mtm = $HAS_READ_BLOCK && $HAS_WRITE_BLOCK;

  $UNALIGNED_TRANSFER &= ($SYMBOLS_PER_BEAT != 1);

  my $bits_to_encode_symbols_per_beat = Bits_To_Encode($SYMBOLS_PER_BEAT) - 1;




  my $DATA_WIDTH = $READ_BLOCK_DATA_WIDTH + 2 + $bits_to_encode_symbols_per_beat;

  &make_reset_n_mapping($mod);
  &instantiate_sgdma_sub_modules($WSA, $mod, $proj, $HAS_READ_BLOCK, $HAS_WRITE_BLOCK, $UNALIGNED_TRANSFER, $device_family, $DESCRIPTOR_READ_BURST, $is_mtm);
  &make_sgdma_fifos($proj, $mod, $DESC_WIDTH, $ADDRESS_WIDTH, $STATUS_TOKEN_WIDTH, $COMMAND_FIFO_DATA_WIDTH, $device_family);
  &make_avalon_masters_and_slaves($WSA, $mod, $module_name, $HAS_READ_BLOCK, $HAS_WRITE_BLOCK, $DESCRIPTOR_READ_BURST);
  if ($HAS_READ_BLOCK && !$HAS_WRITE_BLOCK) {
  	&make_mem_to_stream($mod, $STREAM_DATA_WIDTH, $SYMBOLS_PER_BEAT, $OUT_ERROR_WIDTH, $UNALIGNED_TRANSFER, $bits_to_encode_symbols_per_beat);
  }
  if ($HAS_WRITE_BLOCK && !$HAS_READ_BLOCK) {
  	&make_stream_to_mem($mod, $STREAM_DATA_WIDTH, $SYMBOLS_PER_BEAT, $SINK_ERROR_WIDTH, $UNALIGNED_TRANSFER, $bits_to_encode_symbols_per_beat);
  }
  


  print "Internal FIFO data_width : $DATA_WIDTH\n" if $debug;
  if ($HAS_READ_BLOCK && $HAS_WRITE_BLOCK) {
    if ($BURST_TRANSFER) {

      &wire_readfifo_to_writefifo($mod, $WSA);
    } else {
      &create_internal_fifo($proj, $mod, $DATA_WIDTH, $SYMBOLS_PER_BEAT, $bits_to_encode_symbols_per_beat, $READ_BLOCK_DATA_WIDTH, $device_family);
    }
  }
  print "Done creating internal fifo \n" if $debug;


  if ($UNALIGNED_TRANSFER) {
    &make_barrel_shifters($proj, $mod, $WSA, $HAS_READ_BLOCK, $HAS_WRITE_BLOCK, $is_mtm);
  }
  $proj->top($mod);
  return $proj;
  
}

sub wire_readfifo_to_writefifo {
  my $mod = shift;
  my $WSA = shift;
  my $SYMBOLS_PER_BEAT = $WSA->{"symbols_per_beat"};
  my $IN_ERROR_WIDTH = $WSA->{"in_error_width"};
  my $READ_BLOCK_DATA_WIDTH = $WSA->{"read_block_data_width"};
  my $empty_signal_width = Bits_To_Encode($SYMBOLS_PER_BEAT) - 1;

  $mod->add_contents(
    e_assign->new({lhs=>"sink_stream_valid", rhs=>"source_stream_valid"}),
    e_signal->new({name=>"sink_stream_data", width=>$READ_BLOCK_DATA_WIDTH, never_export=>"1"}),
    e_assign->new({lhs=>"sink_stream_data", rhs=>"source_stream_data"}),
    e_assign->new({lhs=>"sink_stream_startofpacket", rhs=>"source_stream_startofpacket"}),
    e_assign->new({lhs=>"sink_stream_endofpacket", rhs=>"source_stream_endofpacket"}),
    e_assign->new({lhs=>"source_stream_ready", rhs=>"sink_stream_ready"}),
  );

  if ($SYMBOLS_PER_BEAT > 1) {
    $mod->add_contents(
      e_signal->new({name=>"sink_stream_empty", width=>$empty_signal_width, never_export=>"1"}),
      e_assign->new({lhs=>"sink_stream_empty", rhs=>"source_stream_empty"}),
    );
  }
  
  if ($IN_ERROR_WIDTH > 0) {
    $mod->add_contents(
      e_signal->new({name=>"sink_stream_error", width=>$IN_ERROR_WIDTH, never_export=>"1"}),
      e_assign->new({lhs=>"sink_stream_error", rhs=>"source_stream_error"}),
    );
  }

}

sub make_barrel_shifters {
  my $proj = shift;
  my $mod = shift;
  my $WSA = shift;
  my $HAS_READ_BLOCK = shift;
  my $HAS_WRITE_BLOCK = shift;
  my $is_mtm = shift;
  my $IN_ERROR_WIDTH = $WSA->{"in_error_width"};
  my $OUT_ERROR_WIDTH = $WSA->{"out_error_width"};

  if ($HAS_WRITE_BLOCK) {
    print "Make rx_barrel \n" if $debug;
    my $rx_barrel_mod = e_module->new({name=>$mod->name() . "_rx_barrel"});
    $proj->add_module($rx_barrel_mod);
    &make_rx_barrel($proj, $WSA, $rx_barrel_mod);
    print "Done making rx_barrel \n" if $debug;

    $mod->add_contents(
      e_signal->new({name=>"rx_out_error", width=> $IN_ERROR_WIDTH, never_export=>"1"}),
      e_signal->new({name=>"sink_stream_error", never_export=>"1"}),

      e_instance->new({module=>$rx_barrel_mod, 
        port_map => {

          "in_data" => "sink_stream_data",
          "in_eop" => "sink_stream_endofpacket",
          "in_error" => "sink_stream_error",
          "in_empty" => "sink_stream_empty",

          "in_sop" => "sink_stream_startofpacket",
          "in_valid" => "sink_stream_valid",
          "in_ready" => "sink_stream_ready",
          "shift"   => "rx_shift",


          "out_ready" => "rx_out_ready",
          "out_data" => "rx_out_dat",
          "out_eop" => "rx_out_eop",
          "out_error" => "rx_out_error",
          "out_empty" => "rx_out_empty",

          "out_sop" => "rx_out_sop",
          "out_valid" => "rx_out_valid",
        },
      }),
    );
  }

  if ($HAS_READ_BLOCK) {
    print "Make tx_barrel \n" if $debug;
    my $tx_barrel_mod = e_module->new({name=>$mod->name() . "_tx_barrel"});
    $proj->add_module($tx_barrel_mod);
    &make_tx_barrel($proj, $WSA, $tx_barrel_mod);
    print "Done making tx_barrel \n" if $debug;

    if ($is_mtm) {
    $mod->add_contents(
      e_signal->new({name=>"tx_in_error", width=>$OUT_ERROR_WIDTH, never_export=>"1"}),
      e_instance->new({module=>$tx_barrel_mod, 
        port_map => {

          "in_data" => "tx_in_data",
          "in_eop" => "tx_in_eop",
          "in_error" => "tx_in_error",
          "in_empty" => "tx_in_empty",
          "in_sop" => "tx_in_sop",
          "in_valid" => "tx_in_valid",
          "in_ready" => "tx_in_ready",
          "shift"   => "tx_in_shift", 
 

          "out_ready" => "source_stream_ready",
          "out_data" => "source_stream_data",
          "out_eop" => "source_stream_endofpacket",
          "out_error" => "source_stream_error",
          "out_empty" => "source_stream_empty",
          "out_sop" => "source_stream_startofpacket",
          "out_valid" => "source_stream_valid",
  	      },
           }),
    	);
    } else {
    $mod->add_contents(
      e_signal->new({name=>"tx_in_error", width=>$OUT_ERROR_WIDTH, never_export=>"1"}),
      e_instance->new({module=>$tx_barrel_mod, 
        port_map => {

          "in_data" => "tx_in_data",
          "in_eop" => "tx_in_eop",
          "in_error" => "tx_in_error",
          "in_empty" => "tx_in_empty",
          "in_sop" => "tx_in_sop",
          "in_valid" => "tx_in_valid",
          "in_ready" => "tx_in_ready",
	  "generate_eop" => "readfifo_txbarrel_generate_eop",
	  "generate_sop" => "readfifo_txbarrel_generate_sop",
          "shift"   => "tx_in_shift", 
 

          "out_ready" => "source_stream_ready",
          "out_data" => "source_stream_data",
          "out_eop" => "source_stream_endofpacket",
          "out_error" => "source_stream_error",
          "out_empty" => "source_stream_empty",
          "out_sop" => "source_stream_startofpacket",
          "out_valid" => "source_stream_valid",
        },
      }),
    );
  }
 }
}

sub make_reset_n_mapping {
	my $mod = shift;
	
	$mod->add_contents(
		e_port->new({name=>"system_reset_n", type=>"reset_n"}),
		e_register->new({out=>{name=>"reset_n", never_export=>"1"}, in=>"~(~system_reset_n | sw_reset_request)", enable=>"1", reset=>"system_reset_n"}),
		
		e_register->new({
			out=>"sw_reset_d1",
			in=>"sw_reset & ~sw_reset_request",
			enable=>"sw_reset | sw_reset_request",
			_reset=>"system_reset_n",
			}),
		e_register->new({
			out=>"sw_reset_request",
			in=>"sw_reset_d1 & ~sw_reset_request",
			enable=>"sw_reset | sw_reset_request",
			_reset=>"system_reset_n",
			}),


           e_assign->new({lhs=>"reset", rhs=>"~reset_n"}),

	);
}

sub make_mem_to_stream {
  my $mod = shift;
  my $STREAM_DATA_WIDTH = shift;
  my $SYMBOLS_PER_BEAT = shift;
  my $OUT_ERROR_WIDTH = shift;
  my $UNALIGNED_TRANSFER = shift;
  my $bits_to_encode_symbols_per_beat = shift;
  my $prefix = "out";
  my $out_master_name = "out";

  if ($SYMBOLS_PER_BEAT > 1) {
    $mod->add_contents(
      e_port->new({name=>"out_empty", width=>$bits_to_encode_symbols_per_beat, direction=>"output", type=>"empty"}),
      e_assign->new({lhs=>"out_empty", rhs=>"source_stream_empty"}),
    );
  }

  if ($OUT_ERROR_WIDTH > 0) {
    $mod->add_contents(
      e_assign->new({lhs=>"out_error", rhs=>"source_stream_error"}),
      e_signal->new({name=>"out_error", width=>$OUT_ERROR_WIDTH}),

      e_signal->new({name=>"source_stream_error", width=>$OUT_ERROR_WIDTH}),
 
    );
  }
	

  $mod->add_contents(
    e_atlantic_master->new({
      name => $out_master_name,
      type_map => {&get_out_type_map($prefix, $SYMBOLS_PER_BEAT, $OUT_ERROR_WIDTH)},
    }),
    e_port->new({name=>"out_valid", width=>1, direction=>"output", type=>"valid"}),
    e_port->new({name=>"out_ready", width=>1, direction=>"input", type=>"ready"}),
    e_port->new({name=>"out_data", width=>$STREAM_DATA_WIDTH, direction=>"output", type=>"data"}),
    e_port->new({name=>"out_endofpacket", width=>1, direction=>"output", type=>"endofpacket"}),
    e_port->new({name=>"out_startofpacket", width=>1, direction=>"output", type=>"startofpacket"}),
 
  );

  if ($SYMBOLS_PER_BEAT > 1) {
    my $flipped_signal = &swap_signals($SYMBOLS_PER_BEAT, "source_stream_data");
    $mod->add_contents(
      e_assign->new({lhs=>"out_data", rhs=>$flipped_signal}),
    );
  } else {
    $mod->add_contents(
      e_assign->new({lhs=>"out_data", rhs=>"source_stream_data"}),
    );
  }

  $mod->add_contents(
    e_assign->new({lhs=>"out_valid", rhs=>"source_stream_valid"}),
    e_assign->new({lhs=>"source_stream_ready", rhs=>"out_ready"}),
    e_assign->new({lhs=>"out_endofpacket", rhs=>"source_stream_endofpacket"}),
    e_assign->new({lhs=>"out_startofpacket", rhs=>"source_stream_startofpacket"}),
  );
}

sub get_out_type_map {
  my $prefix = shift;
  my $SYMBOLS_PER_BEAT = shift;
  my $OUT_ERROR_WIDTH = shift;
  my @port_types = &get_out_type_list($SYMBOLS_PER_BEAT, $OUT_ERROR_WIDTH);
  return map {($prefix . "_$_" => $_)} @port_types
}

sub get_in_type_map {
  my $prefix = shift;
  my $SYMBOLS_PER_BEAT = shift;
  my $SINK_ERROR_WIDTH = shift;
  my @port_types = &get_in_type_list($SYMBOLS_PER_BEAT, $SINK_ERROR_WIDTH);
  return map {($prefix . "_$_" => $_)} @port_types
}

sub get_out_type_list {
  my $SYMBOLS_PER_BEAT = shift;
  my $OUT_ERROR_WIDTH = shift;
  my @signals = qw(
    data
    ready
    valid
    startofpacket 
    endofpacket
  );

  if ($SYMBOLS_PER_BEAT > 1) {
    push (@signals, "empty");
  }
  if ($OUT_ERROR_WIDTH > 0) {
    push (@signals, "error");
  }
  return @signals;
}

sub get_in_type_list {
  my $SYMBOLS_PER_BEAT = shift;
  my $SINK_ERROR_WIDTH = shift;
  my @signals = qw(
    endofpacket
    startofpacket
    valid
    ready
    data
  );

  if ($SYMBOLS_PER_BEAT > 1) {
    push (@signals, "empty");
  }
  if ($SINK_ERROR_WIDTH > 0) {
    push (@signals, "error");
  }
  return @signals;
}

sub make_stream_to_mem {
  my $mod = shift;
  my $STREAM_DATA_WIDTH = shift;
  my $SYMBOLS_PER_BEAT = shift;
  my $SINK_ERROR_WIDTH = shift;
  my $UNALIGNED_TRANSFER = shift;
  my $bits_to_encode_symbols_per_beat = shift;
  my $prefix = "in";
  my $in_slave_name = "in";

  if ($SYMBOLS_PER_BEAT > 1) {
    $mod->add_contents(
      e_port->new({name=>"in_empty", width=>$bits_to_encode_symbols_per_beat, direction=>"input", type=>"empty"}),
      e_assign->new({lhs=>"sink_stream_empty", rhs=>"in_empty"}),
    );
  } else {
    $mod->add_contents(
      e_signal->new({name=>"sink_stream_startofpacket", never_export=>"1"}),
    );
  }

  if ($SINK_ERROR_WIDTH > 0) {
    $mod->add_contents(
      e_port->new({name=>"in_error", width=>$SINK_ERROR_WIDTH, direction=>"input", type=>"error"}),
      e_assign->new({lhs=>"sink_stream_error", rhs=>"sink_stream_valid ? in_error : 0"}),
      e_signal->new({name=>"sink_stream_error", width=>$SINK_ERROR_WIDTH}),
    );
  }

  $mod->add_contents(
    e_atlantic_slave->new({
      name => $in_slave_name,
      type_map => {&get_in_type_map($prefix, $SYMBOLS_PER_BEAT, $SINK_ERROR_WIDTH)},
    }),
    e_port->new({name=>"in_endofpacket", width=>1, direction=>"input", type=>"endofpacket"}),
    e_port->new({name=>"in_startofpacket", width=>1, direction=>"input", type=>"startofpacket"}),
    e_port->new({name=>"in_valid", width=>1, direction=>"input", type=>"valid"}),
    e_port->new({name=>"in_ready", width=>1, direction=>"output", type=>"ready"}),
    e_port->new({name=>"in_data", width=>$STREAM_DATA_WIDTH, direction=>"input", type=>"data"}),
  );

  $mod->add_contents(
    e_assign->new({lhs=>"sink_stream_endofpacket", rhs=>"in_endofpacket"}),
    e_assign->new({lhs=>"sink_stream_startofpacket", rhs=>"in_startofpacket"}),
    e_assign->new({lhs=>"sink_stream_valid", rhs=>"in_valid"}),
    e_assign->new({lhs=>"in_ready", rhs=>"sink_stream_ready"}),
    e_signal->new({name=>"generate_eop", never_export=>"1"}),
  );


  if ($SYMBOLS_PER_BEAT > 1) {
    my $flipped_data_signal = &swap_signals($SYMBOLS_PER_BEAT, "in_data"); 
    
    $mod->add_contents(
      e_assign->new({lhs=>"sink_stream_data", rhs=>$flipped_data_signal}),

    );
  } else {
    $mod->add_contents(
      e_assign->new({lhs=>"sink_stream_data", rhs=>"in_data"}),
    );
  }


}

sub swap_signals {
  my $SYMBOLS_PER_BEAT = shift;
  my $indata = shift;

  my $flipped_data_signal = "{";
  for (my $i=0; $i < $SYMBOLS_PER_BEAT; $i++) {
    my $lower_bound = ($i*8);
    my $upper_bound = $lower_bound + 7;
      $flipped_data_signal .= "$indata" ."[$upper_bound:$lower_bound]";
    if ($i == ($SYMBOLS_PER_BEAT -1)) {
      $flipped_data_signal .= "}";
    } else {
      $flipped_data_signal .= ", ";
    }
  }
  return $flipped_data_signal;
}


sub instantiate_sgdma_sub_modules {
  my $WSA = shift;
  my $mod = shift;
  my $proj = shift;
  my $HAS_READ_BLOCK = shift;
  my $HAS_WRITE_BLOCK = shift;
  my $UNALIGNED_TRANSFER = shift;
  my $device_family = shift;
  my $DESCRIPTOR_READ_BURST = shift;
  my $is_mtm = shift;
  my $IN_ERROR_WIDTH = $WSA->{"in_error_width"};
  my $OUT_ERROR_WIDTH = $WSA->{"out_error_width"};
  

  my $BURST_TRANSFER = $WSA->{"burst_transfer"};


  print "making sub_modules\n" if $debug;
  
  print "Make chain_block \n" if $debug;
  my $chain_block_mod = e_module->new({name=>$mod->name() . "_chain"});
  $proj->add_module($chain_block_mod);
  &make_chain_block($proj, $WSA, $chain_block_mod, $device_family);
  print "Done making chain_block\n" if $debug;
  
  print "Make command_grabber\n" if $debug;
  my $command_grabber_mod = e_module->new({name=>$mod->name() . "_command_grabber"});
  $proj->add_module($command_grabber_mod);
  &make_command_grabber($command_grabber_mod, $WSA);
  print "Done making command_grabber \n" if $debug;
  
  print "Adding chain block and command_grabber to top\n" if $debug;
  my @command_grabber_mod_ports = ();
  if ($HAS_READ_BLOCK) {
    push (@command_grabber_mod_ports, ("m_read_waitrequest"=>"m_read_waitrequest & m_read_read"));
  }
  if ($HAS_WRITE_BLOCK) {
    push (@command_grabber_mod_ports, ("m_write_waitrequest"=>"m_write_waitrequest & m_write_write"));
  }
  $mod->add_contents(
    e_instance->new({module=>$chain_block_mod,
            port_map => {
              "descriptor_read_waitrequest" => "descriptor_read_waitrequest & descriptor_read_read",
              "descriptor_write_waitrequest" => "descriptor_write_waitrequest & descriptor_write_write",
            },
          }),
    e_instance->new({module=>$command_grabber_mod,
            port_map => {@command_grabber_mod_ports},
          }),
  );
  
  print "Initializing variables\n" if $debug;
  my $read_block_mod;
  my $write_block_mod;
  
  print "Making read block\n" if $debug;
  if ($HAS_READ_BLOCK) {
    $read_block_mod = e_module->new({name=>$mod->name() . "_" . $m_read_name});
    $proj->add_module($read_block_mod);
    &make_read_block($read_block_mod, $WSA);
    if ($UNALIGNED_TRANSFER) {
      if ($is_mtm) {
      $mod->add_contents(
      e_instance->new({module=>$read_block_mod, 
        port_map => {
          "source_stream_data" => "data_to_fifo",
          "source_stream_empty"=> "empty_to_fifo",
          "source_stream_endofpacket"=> "eop_to_fifo",
          "source_stream_ready"=> "ready_from_fifo",
          "source_stream_startofpacket"=> "sop_to_fifo",
          "source_stream_valid"=> "valid_to_fifo",
          "source_stream_error"=> "error_to_fifo",
          "tx_shift"=>"tx_shift_to_fifo",
          "m_read_waitrequest"=>"m_read_waitrequest & m_read_read",
        },
      }),
      );
      } else {
      $mod->add_contents(
      e_instance->new({module=>$read_block_mod, 
        port_map => {
          "source_stream_data" => "data_to_fifo",
          "source_stream_empty"=> "empty_to_fifo",
          "source_stream_endofpacket"=> "eop_to_fifo",
          "source_stream_ready"=> "ready_from_fifo",
          "source_stream_startofpacket"=> "sop_to_fifo",
          "source_stream_valid"=> "valid_to_fifo",
          "source_stream_error"=> "error_to_fifo",
          "generate_sop"=>"mread_readfifo_generate_sop",
	  "generate_eop"=>"mread_readfifo_generate_eop",
          "tx_shift"=>"tx_shift_to_fifo",
          "m_read_waitrequest"=>"m_read_waitrequest & m_read_read",
        },
      }),
      );
     }
    } else {
      $mod->add_contents(
      e_instance->new({module=>$read_block_mod,
        port_map => {
          "source_stream_data" => "data_to_fifo",
          "source_stream_empty"=> "empty_to_fifo",
          "source_stream_endofpacket"=> "eop_to_fifo",
          "source_stream_ready"=> "ready_from_fifo",
          "source_stream_startofpacket"=> "sop_to_fifo",
          "source_stream_valid"=> "valid_to_fifo",
          "source_stream_error"=> "error_to_fifo",
          "m_read_waitrequest"=>"m_read_waitrequest & m_read_read",
         },
       }),
      );
    }


    my $m_readfifo_mod = e_module->new({name=>$mod->name() . "_m_readfifo"});
    $proj->add_module($m_readfifo_mod);
    &make_read_block_fifo($m_readfifo_mod, $WSA, $device_family);
 
    if ($UNALIGNED_TRANSFER) {  
      $mod->add_contents(
        e_signal->new({name=>"tx_in_error", width=>$IN_ERROR_WIDTH, never_export=>"1"}),
        e_signal->new({name=>"m_readfifo_full", never_export=>"1"}),
      ); 

    if ($is_mtm) {
      $mod->add_contents(
        e_instance->new({module=>$m_readfifo_mod, 
          port_map => {
           "source_stream_data" => "tx_in_data",
           "source_stream_startofpacket" => "tx_in_sop",
           "source_stream_endofpacket" => "tx_in_eop",
           "source_stream_empty" => "tx_in_empty",
           "source_stream_valid" => "tx_in_valid",
           "source_stream_ready" => "tx_in_ready",
           "source_stream_error" => "tx_in_error",
	   "tx_shift_out"        => "tx_in_shift",

           "sink_stream_data" => "data_to_fifo",
           "sink_stream_startofpacket" => "sop_to_fifo",
           "sink_stream_endofpacket" => "eop_to_fifo",
           "sink_stream_empty" => "empty_to_fifo",
           "sink_stream_valid" => "valid_to_fifo",
           "sink_stream_ready" => "ready_from_fifo",
           "sink_stream_error" => "error_to_fifo",
           "tx_shift_in"       => "tx_shift_to_fifo",
            },
          }),
	);
   } else {
      $mod->add_contents(
        e_instance->new({module=>$m_readfifo_mod, 
          port_map => {
           "source_stream_data" => "tx_in_data",
           "source_stream_startofpacket" => "tx_in_sop",
           "source_stream_endofpacket" => "tx_in_eop",
           "source_stream_empty" => "tx_in_empty",
           "source_stream_valid" => "tx_in_valid",
           "source_stream_ready" => "tx_in_ready",
           "source_stream_error" => "tx_in_error",
	   "generate_sop_out"	 => "readfifo_txbarrel_generate_sop",
	   "generate_eop_out"	 => "readfifo_txbarrel_generate_eop",
	   "tx_shift_out"        => "tx_in_shift",

           "sink_stream_data" => "data_to_fifo",
           "sink_stream_startofpacket" => "sop_to_fifo",
           "sink_stream_endofpacket" => "eop_to_fifo",
           "sink_stream_empty" => "empty_to_fifo",
           "sink_stream_valid" => "valid_to_fifo",
           "sink_stream_ready" => "ready_from_fifo",
           "sink_stream_error" => "error_to_fifo",
	   "generate_sop_in"   => "mread_readfifo_generate_sop",
           "generate_eop_in"   => "mread_readfifo_generate_eop",
           "tx_shift_in"       => "tx_shift_to_fifo",
            },
          }),
        );
      }
    } else {
      $mod->add_contents(
        e_instance->new({module=>$m_readfifo_mod, 
          port_map => {
           "source_stream_data" => "source_stream_data",
           "source_stream_startofpacket" => "source_stream_startofpacket",
           "source_stream_endofpacket" => "source_stream_endofpacket",
           "source_stream_empty" => "source_stream_empty",
           "source_stream_valid" => "source_stream_valid",
           "source_stream_ready" => "source_stream_ready",
           "source_stream_error" => "source_stream_error",

           "sink_stream_data" => "data_to_fifo",
           "sink_stream_startofpacket" => "sop_to_fifo",
           "sink_stream_endofpacket" => "eop_to_fifo",
           "sink_stream_empty" => "empty_to_fifo",
           "sink_stream_valid" => "valid_to_fifo",
           "sink_stream_ready" => "ready_from_fifo",
           "sink_stream_error" => "error_to_fifo",
          },
        }),
      );
    }
  }
  
  print "Making write block\n" if $debug;
  if ($HAS_WRITE_BLOCK) {
    $write_block_mod = e_module->new({name=>$mod->name() . "_" . $m_write_name});
    $proj->add_module($write_block_mod);
    &make_write_block($write_block_mod, $WSA, $proj);
    if ($UNALIGNED_TRANSFER) {
      $mod->add_contents(
        e_signal->new({name=>"rx_out_error", width=> $OUT_ERROR_WIDTH, never_export=>"1"}),
        e_instance->new({module=>$write_block_mod,
          port_map => {
            "sink_stream_data" => "rx_out_dat",
            "sink_stream_empty"=> "rx_out_empty",
            "sink_stream_endofpacket"=> "rx_out_eop",
            "sink_stream_ready"=> "rx_out_ready",
            "sink_stream_startofpacket"=> "rx_out_sop",
            "sink_stream_valid"=> "rx_out_valid",
            "sink_stream_error"=> "rx_out_error",
            "m_write_waitrequest"=>"m_write_waitrequest & m_write_write",
          },
        }),
      );  
    } else {
      if ($BURST_TRANSFER) {
        my $m_writefifo_mod = e_module->new({name=>$mod->name() . "_m_writefifo"});
        $proj->add_module($m_writefifo_mod);
        &make_write_block_fifo($m_writefifo_mod, $WSA, $device_family);

        $mod->add_contents(
          e_instance->new({module=>$m_writefifo_mod,
            port_map => {
             "source_stream_data" => "write_fifo_out_data",
             "source_stream_startofpacket" => "write_fifo_out_startofpacket",
             "source_stream_endofpacket" => "write_fifo_out_endofpacket",
             "source_stream_empty" => "write_fifo_out_empty",
             "source_stream_valid" => "write_fifo_out_valid",
             "source_stream_ready" => "write_fifo_out_ready",
             "source_stream_error" => "write_fifo_out_error",
             "eop_found" => "eop_found",

             "sink_stream_data" => "sink_stream_data",
             "sink_stream_startofpacket" => "sink_stream_startofpacket",
             "sink_stream_endofpacket" => "sink_stream_endofpacket",
             "sink_stream_empty" => "sink_stream_empty",
             "sink_stream_valid" => "sink_stream_valid",
             "sink_stream_ready" => "sink_stream_ready",
             "sink_stream_error" => "sink_stream_error",
            },
          }),
          e_instance->new({module=>$write_block_mod,
            port_map => {
              "sink_stream_data" => "write_fifo_out_data",
              "sink_stream_empty"=> "write_fifo_out_empty",
              "sink_stream_startofpacket"=> "write_fifo_out_startofpacket",
              "sink_stream_endofpacket"=> "write_fifo_out_endofpacket",
              "sink_stream_ready"=> "write_fifo_out_ready",
              "sink_stream_valid"=> "write_fifo_out_valid",
              "sink_stream_error"=> "write_fifo_out_error",
              "eop_found" => "eop_found",
            "m_write_waitrequest"=>"m_write_waitrequest & m_write_write",
            },
          }),
        );
      } else {
        $mod->add_contents(
          e_instance->new({module=>$write_block_mod,
            port_map => {
              "eop_found" => "1'b0",
              "enough_data" => "1'b1",
            "m_write_waitrequest"=>"m_write_waitrequest & m_write_write",
            },
          }),
        );
      }
    }
  }
  
  print "Making wires for internal stuff in the SG-DMA \n\n\n\n\n" if $debug;

  &make_sgdma_external_ports($mod, $chain_block_mod, $HAS_READ_BLOCK, $HAS_WRITE_BLOCK, $BURST_TRANSFER, $DESCRIPTOR_READ_BURST);
  &make_sgdma_external_ports($mod, $command_grabber_mod, $HAS_READ_BLOCK, $HAS_WRITE_BLOCK, $BURST_TRANSFER);
  &make_sgdma_external_ports($mod, $read_block_mod, $HAS_READ_BLOCK, $HAS_WRITE_BLOCK, $BURST_TRANSFER) if $HAS_READ_BLOCK;
  &make_sgdma_external_ports($mod, $write_block_mod, $HAS_READ_BLOCK, $HAS_WRITE_BLOCK, $BURST_TRANSFER) if $HAS_WRITE_BLOCK;
  
}

sub make_avalon_masters_and_slaves {
  my $WSA = shift;
  my $mod = shift;
  my $module_name = shift;
  my $HAS_READ_BLOCK = shift;
  my $HAS_WRITE_BLOCK = shift;
  my $DESCRIPTOR_READ_BURST = shift;
	
  my $READ_BLOCK_DATA_WIDTH = $WSA->{"read_block_data_width"};
  my $WRITE_BLOCK_DATA_WIDTH = $WSA->{"write_block_data_width"};
  my $DESC_WIDTH = 256;
  my $DESC_DATA_WIDTH = $WSA->{"desc_data_width"};
  my $ADDRESS_WIDTH = $WSA->{"address_width"};
  my $BYTE_ENABLE_WIDTH = 4;
  my $CHAIN_WRITEBACK_DATA_WIDTH = $WSA->{"descriptor_writeback_data_width"};
  my $CONTROL_SLAVE_DATA_WIDTH = $WSA->{"control_slave_data_width"};
  my $CONTROL_SLAVE_ADDRESS_WIDTH = $WSA->{"control_slave_address_width"};
  my $UNALIGNED_TRANSFER = $WSA->{"unaligned_transfer"};
  my $SYMBOLS_PER_BEAT = $WSA->{"symbols_per_beat"};

  my $BURST_TRANSFER = $WSA->{"burst_transfer"};
  my $read_burst_size = $WSA->{"read_burstcount_width"};
  my $write_burst_size = $WSA->{"write_burstcount_width"};
  
	my $prefix = $descriptor_read_name;
  my $descriptor_read_master_name = $prefix;
  &make_descriptor_read_avalon_master($mod, $DESC_DATA_WIDTH, $ADDRESS_WIDTH, $descriptor_read_master_name, $prefix, $DESCRIPTOR_READ_BURST);
  
  $prefix = $descriptor_write_name;
  my $write_master_name = $prefix;
  &make_descriptor_writeback_avalon_master($mod, $DESC_WIDTH, $ADDRESS_WIDTH, $write_master_name, 
    $prefix, $BYTE_ENABLE_WIDTH, $CHAIN_WRITEBACK_DATA_WIDTH);
  
  $prefix = $csr_name;
  my $read_slave_name = $prefix;
  &make_chain_control_avalon_slave($mod, $CONTROL_SLAVE_DATA_WIDTH, $CONTROL_SLAVE_ADDRESS_WIDTH, $read_slave_name, $prefix);

	if ($HAS_READ_BLOCK) {
 		$prefix = $m_read_name; 
	  my $read_master_name = $prefix;
          &make_read_block_avalon_master($mod, $READ_BLOCK_DATA_WIDTH, $ADDRESS_WIDTH, $read_master_name, $prefix, $BURST_TRANSFER, $read_burst_size);
	}
  
  if ($HAS_WRITE_BLOCK) {
  	$prefix = $m_write_name;
  	my $write_master_name = $prefix;
  	&make_write_block_avalon_master($mod, $WRITE_BLOCK_DATA_WIDTH, $ADDRESS_WIDTH, $write_master_name, $prefix, $BURST_TRANSFER, $write_burst_size);
  }
}

sub make_sgdma_external_ports {
  my $mod = shift;
  my $inner_mod = shift;
  my $HAS_READ_BLOCK = shift;
  my $HAS_WRITE_BLOCK = shift;
  my $BURST_TRANSFER = shift;
  my $DESCRIPTOR_READ_BURST = shift;
	
  my $mod_name = $inner_mod->name();
  print "Inner module name : $mod_name\n" if $debug;
  my @inner_port_names = $inner_mod->get_object_names("e_port");
  foreach my $inner_port_name (@inner_port_names) {
    
    next if (&is_sgdma_external_signal($inner_port_name, $HAS_READ_BLOCK, $HAS_WRITE_BLOCK, $BURST_TRANSFER, $DESCRIPTOR_READ_BURST));
    
    my $inner_port = $inner_mod->get_object_by_name($inner_port_name);
    $mod->add_contents(
      e_signal->new({
        name=>$inner_port->name(), 
        width=>$inner_port->width(),
        never_export=>"1",
      }),
    );
  }
}

sub is_sgdma_external_signal {
  my $debug = 0;
  my $signal = shift;
  my $HAS_READ_BLOCK = shift;
  my $HAS_WRITE_BLOCK = shift;
  my $BURST_TRANSFER = shift;
  my $DESCRIPTOR_READ_BURST = shift;
	
  my @external_port_list = &get_sgdma_external_port_list($HAS_READ_BLOCK, $HAS_WRITE_BLOCK, $BURST_TRANSFER, $DESCRIPTOR_READ_BURST);
  
  foreach my $external_ports (@external_port_list) { 
    if ($external_ports =~ /$signal/ ) { 
      print "External : $signal \n" if $debug;
      return 1; 
    } 
  } 
  print "Internal : $signal \n" if $debug;
  return 0; 
}

sub get_sgdma_external_port_list {
  my $HAS_READ_BLOCK = shift;
  my $HAS_WRITE_BLOCK = shift;
  my $BURST_TRANSFER = shift;
  my $DESCRIPTOR_READ_BURST = shift;
	
  my @ports = (
    "descriptor_read_readdata",
    "descriptor_read_readdatavalid",
    "descriptor_read_waitrequest",
    "descriptor_write_waitrequest",
    "clk",
    "csr_address",
    "csr_chipselect",
    "csr_read",
    "csr_write",
    "csr_writedata",
    "reset_n",
    
    "descriptor_read_address",
    "descriptor_read_read",
    "descriptor_write_address",
    "descriptor_write_write",
    "descriptor_write_writedata",
    "csr_readdata",
    "csr_readdatavalid",
    
  );


  if ($DESCRIPTOR_READ_BURST) {
    push (@ports, "descriptor_read_burstcount");
  }



  if (!($HAS_READ_BLOCK && $HAS_WRITE_BLOCK)) {
  	push (@ports, "e_00"); 
    push (@ports, "e_05");
    push (@ports, "e_06");
    push (@ports, "e_02");
    push (@ports, "e_01");
    push (@ports, "e_03");
    push (@ports, "e_04");
    push (@ports, "t_eop");
  }
  
  if ($HAS_READ_BLOCK) {
    push (@ports, $m_read_name . "_address");
    push (@ports, $m_read_name . "_read");
    push (@ports, $m_read_name . "_readdata");
    push (@ports, $m_read_name . "_readdatavalid");
    push (@ports, $m_read_name . "_waitrequest");
    if ($BURST_TRANSFER) {
      push (@ports, $m_read_name . "_burstcount");
    }
  }
  if ($HAS_WRITE_BLOCK) {
    push (@ports, $m_write_name . "_address");
    push (@ports, $m_write_name . "_write");
    push (@ports, $m_write_name . "_writedata");
    push (@ports, $m_write_name . "_waitrequest");
    push (@ports, $m_write_name . "_byteenable");
    if ($BURST_TRANSFER) {
      push (@ports, $m_write_name . "_burstcount");
    }
  }
  return @ports;
}


sub create_internal_fifo {
  my $proj = shift;
  my $mod = shift;
  my $DATA_WIDTH = shift;
  my $SYMBOLS_PER_BEAT = shift;
  my $bits_to_encode_symbols_per_beat = shift;
  my $real_data_width = shift;
  my $device_family = shift;

  my $empty_output_lower_bound = $DATA_WIDTH-1 -$bits_to_encode_symbols_per_beat -1;
  
  &add_sgdma_lpm_fifo($proj, $mod, "stream_fifo", $DATA_WIDTH, 4, 0, $device_family);
  
  
  my $fifo_data = "{source_stream_startofpacket, source_stream_endofpacket, ";
  $fifo_data .= "source_stream_empty, " if ($SYMBOLS_PER_BEAT > 1);
  $fifo_data .= "source_stream_data}";



  $mod->add_contents(

    e_comment->new({comment=>"connect up the source to the stream_fifo"}),
    e_assign->new({lhs=>"source_stream_ready", rhs=>"~stream_fifo_full"}),
    e_assign->new({lhs=>"stream_fifo_data", rhs=>"$fifo_data"}),
    e_assign->new({lhs=>"stream_fifo_wrreq", rhs=>"source_stream_valid & source_stream_ready"}),
    

    e_comment->new({comment=>"connect up the sink to the stream_fifo"}),
    e_assign->new({lhs=>"stream_fifo_rdreq", rhs=>"~stream_fifo_empty && sink_stream_ready"}),

    e_assign->new({lhs=>"sink_stream_startofpacket", rhs=>"stream_fifo_q[$DATA_WIDTH-1]"}),
    e_assign->new({lhs=>"sink_stream_endofpacket_from_fifo", rhs=>"stream_fifo_q[$DATA_WIDTH-2]"}),
    

    e_signal->new({name=>"source_stream_valid", export=>"1"}),
    e_assign->new({lhs=>"sink_stream_endofpacket_sig", rhs=>"(sink_stream_endofpacket_from_fifo & sink_stream_valid) | sink_stream_endofpacket_hold"}),  #SPR305092 



    e_assign->new({lhs=>"sink_stream_endofpacket", rhs=>"sink_stream_endofpacket_sig"}),
    e_register->new({out=>"sink_stream_endofpacket_hold", in=>"(sink_stream_endofpacket_sig & ~sink_stream_ready) ? 1 : (sink_stream_ready ? 0 : sink_stream_endofpacket_hold)", enable=>"1"}),

    e_assign->new({lhs=>"sink_stream_data", rhs=>"stream_fifo_q[$real_data_width -1:0]"}),

    e_signal->new({name=>"sink_stream_data", width=>"$real_data_width"}),

    e_register->new({out=>"sink_stream_valid_reg", in=>"stream_fifo_rdreq", enable=>"1"}),
    e_assign->new({lhs=>"sink_stream_valid_out", rhs=>"sink_stream_valid_reg | sink_stream_valid_hold"}),
    e_assign->new({lhs=>"sink_stream_valid", rhs=>"sink_stream_valid_out"}),

    e_register->new({out=>"sink_stream_valid_hold", in=>"(sink_stream_valid_out & ~sink_stream_ready) ? 1 : (sink_stream_ready ? 0 : sink_stream_valid_hold)", enable=>"1"}),
    
    
  );

  if ($SYMBOLS_PER_BEAT > 1) {
    $mod->add_contents(
      e_assign->new({lhs=>"sink_stream_empty", rhs=>"stream_fifo_q[$DATA_WIDTH-3:$empty_output_lower_bound]"}),
    );
  } else {
    $mod->add_contents(
      e_signal->new({name=>"sink_stream_startofpacket", never_export=>"1"}),
    );
  }
}


sub make_sgdma_fifos {
  my $proj = shift;
  my $mod = shift;
  my $DESC_WIDTH = shift;
  my $ADDRESS_WIDTH = shift;
  my $STATUS_TOKEN_WIDTH = shift;
  my $COMMAND_FIFO_DATA_WIDTH = shift;
  my $device_family = shift;

  &add_sgdma_lpm_fifo($proj, $mod, "command_fifo", $COMMAND_FIFO_DATA_WIDTH, 2, 0, $device_family);


  &add_sgdma_lpm_fifo($proj, $mod, "desc_address_fifo", $ADDRESS_WIDTH, 2, 1, $device_family);
  &add_sgdma_lpm_fifo($proj, $mod, "status_token_fifo", $STATUS_TOKEN_WIDTH, 2, 0, $device_family);
 
}

sub add_sgdma_fifo {
  my $mod = shift;
  my $FIFO_NAME = shift;
  my $FIFO_WIDTH = shift;
  my $depth = shift;
  
  $mod->add_contents(
    e_instance->new({ 
      name => $mod->name() . "_" . $FIFO_NAME,
      _module_name =>
        e_efifo->new({
          name_stub  => $mod->name() . "_" . $FIFO_NAME,
          data_width => $FIFO_WIDTH,
          depth      => $depth,
          }),
        port_map  => {
          "wr"          => "${FIFO_NAME}_wrreq",
          "rd"          => "${FIFO_NAME}_rdreq",
          "wr_data"     => "${FIFO_NAME}_data",
          "rd_data"     => "${FIFO_NAME}_q",
          "empty"       => "${FIFO_NAME}_empty",
          "full"        => "${FIFO_NAME}_full",
        },
    }),
    

    e_signal->news (
      {name => "almost_full",      never_export => 1},
      {name => "almost_empty",     never_export => 1},
    ),
  );
}

sub add_sgdma_lpm_fifo {
  my $proj = shift;
  my $mod = shift;
  my $FIFO_NAME = shift;
  my $FIFO_WIDTH = shift;
  my $depth = shift;
  my $use_les = shift;
  my $device_family = shift;
  
  print "Make fifo $FIFO_NAME \n" if $debug;
  my $fifo_mod = e_module->new({name=>$mod->name() . "_" . $FIFO_NAME});
  &define_scfifo($fifo_mod, $FIFO_NAME, $depth, $FIFO_WIDTH, $use_les, 0, $device_family);
  print "Done making fifo $FIFO_NAME \n" if $debug;

  $mod->add_contents(
    e_instance->new({name=>"the_" . $mod->name() . "_" . $FIFO_NAME, 
      module=>$fifo_mod}),
  );  
  
}
 
   




  sub do_device_family_name_mapping
  {
  	my $device_name = @_[0];
  	
		my %translate_device_name = (
			"CYCLONE" => "Cyclone",
			"CYCLONEII" => "Cyclone II",
			"CYCLONEIII" => "Cyclone III",
			"STRATIX" => "Stratix",
			"STRATIXGX" => "Stratix GX",
			"STRATIXII" => "Stratix II",
			"STRATIXIII" => "Stratix III",
			"STRATIXIIGX" => "Stratix II GX",
			"ARRIAGX" => "Arria GX",
			"STRATIXIIGXLITE" => "Arria GX",
		);
		
		my $tr_device_name = $translate_device_name{$device_name};
		
		if($tr_device_name ne ""){
			return $tr_device_name;
		}else{
			return $device_name;
		}
  } 
  
1;
