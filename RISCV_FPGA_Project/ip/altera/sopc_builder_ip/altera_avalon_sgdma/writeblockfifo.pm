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
use scfifo;

my $debug = 0;

sub make_write_block_fifo {
  my $mod = shift;
  my $WSA = shift;
  my $device_family = shift;


  my $DESC_WIDTH = $WSA->{"desc_data_width"};
  my $ADDRESS_WIDTH = $WSA->{"address_width"};
  my $WRITE_BLOCK_DATA_WIDTH = $WSA->{"write_block_data_width"};
  print "Read Block Data Width : $WRITE_BLOCK_DATA_WIDTH \n" if $debug;
  my $STREAM_DATA_WIDTH = $WSA->{"stream_data_width"};
  my $BYTES_TO_TRANSFER_WIDTH = $WSA->{"bytes_to_transfer_data_width"};
  my $COUNTER_WIDTH = $BYTES_TO_TRANSFER_WIDTH;
  my $BURST_WIDTH = $WSA->{"burst_data_width"};
  my $STATUS_TOKEN_WIDTH = $WSA->{"status_token_data_width"};
  my $STATUS_WIDTH = $WSA->{"status_data_width"};
  my $COMMAND_WIDTH = 1 + $BURST_WIDTH + $BYTES_TO_TRANSFER_WIDTH + $ADDRESS_WIDTH;
  my $HAS_READ_BLOCK = $WSA->{"has_read_block"};
  my $HAS_WRITE_BLOCK = $WSA->{"has_write_block"};
  my $SYMBOLS_PER_BEAT = $WSA->{"symbols_per_beat"};
  my $UNALIGNED_TRANSFER = $WSA->{"unaligned_transfer"};
  my $IN_ERROR_WIDTH = $WSA->{"in_error_width"};
  my $BURST_TRANSFER = $WSA->{"burst_transfer"};

  $UNALIGNED_TRANSFER &= ($SYMBOLS_PER_BEAT != 1);

  my $bits_to_encode_symbols_per_beat = Bits_To_Encode($SYMBOLS_PER_BEAT) -1;
  print "Bits to encode symbols per beat : $bits_to_encode_symbols_per_beat \n" if $debug;
  print "Source error width : $IN_ERROR_WIDTH\n" if $debug;

  my $is_mtm = $HAS_READ_BLOCK && $HAS_WRITE_BLOCK;


  my $internal_fifo_depth = &get_writeblock_internal_fifo_depth($WRITE_BLOCK_DATA_WIDTH, $WSA);

  my $internal_fifo_width = $WRITE_BLOCK_DATA_WIDTH + 2 + $bits_to_encode_symbols_per_beat + $IN_ERROR_WIDTH;
 
  print "Internal FIFO Width : $internal_fifo_width\n" if $debug;


  my $space_available_width = Bits_To_Encode($internal_fifo_depth) - 1;

  &add_write_block_fifo_ports($mod, $WRITE_BLOCK_DATA_WIDTH, $ADDRESS_WIDTH, $STREAM_DATA_WIDTH, $COMMAND_WIDTH, $SYMBOLS_PER_BEAT, $bits_to_encode_symbols_per_beat, $IN_ERROR_WIDTH, $BURST_TRANSFER, $internal_fifo_depth);

  &make_internal_m_write_fifo($mod, $internal_fifo_depth, $internal_fifo_width, $WRITE_BLOCK_DATA_WIDTH, $bits_to_encode_symbols_per_beat, $IN_ERROR_WIDTH, $SYMBOLS_PER_BEAT, $device_family, $BURST_TRANSFER, $space_available_width);

  &make_sop_eop_detector($mod);

  return $mod;
}

sub get_writeblock_internal_fifo_depth {
  my $WRITE_BLOCK_DATA_WIDTH = shift;  
  my $WSA = shift;
  my $BURST_TRANSFER = $WSA->{"burst_transfer"};
  my $write_burstcount_width = $WSA->{"write_burstcount_width"};
  my $write_fifo_depth = 2 ** ($write_burstcount_width + 1);
  my $IN_ERROR_WIDTH = $WSA->{"in_error_width"};
  my $SYMBOLS_PER_BEAT = $WSA->{"symbols_per_beat"};
  my $EMPTY_WIDTH = $SYMBOLS_PER_BEAT;



  my $next_power_of_two_depth = &next_power_of_two($WRITE_BLOCK_DATA_WIDTH + $IN_ERROR_WIDTH + $EMPTY_WIDTH + 2);
  
  my $internal_fifo_depth = 128 * 32 / ($next_power_of_two_depth);
  if ($BURST_TRANSFER) {
    return $write_fifo_depth;
  } else {
    return $internal_fifo_depth;
  }
}

sub make_sop_eop_detector {
  my $mod = shift;

  $mod->add_contents(
    e_port->new(["eop_found"=>1=>"Output"]),

    e_assign->new({lhs=>"in_eop_found", rhs=>"sink_stream_really_valid & sink_stream_endofpacket"}),
    e_register->new({out=>"eop_found", in=>"eop_found ? ~(source_stream_ready) : in_eop_found", enable=>"1"}),

    e_register->new({out=>"pause_till_eop_out", in=>"pause_till_eop_out ? ~(source_stream_valid & source_stream_ready & source_stream_endofpacket): in_eop_found", enable=>"1"}),
  );
}

sub add_write_block_fifo_ports {
  my $mod = shift;
  my $WRITE_BLOCK_DATA_WIDTH = shift;
  my $ADDRESS_WIDTH = shift;
  my $STREAM_DATA_WIDTH = shift;
  my $COMMAND_WIDTH = shift;
  my $SYMBOLS_PER_BEAT = shift;
  my $bits_to_encode_symbols_per_beat = shift;
  my $IN_ERROR_WIDTH = shift;
  my $BURST_TRANSFER = shift;
  my $internal_fifo_depth = shift;

  my $bits_to_encode_internal_fifo_depth = Bits_To_Encode($internal_fifo_depth) -1;

  my @ports = (
    [clk=>1=>"input"],
    [reset_n=>1=>"input"],


    [source_stream_startofpacket=>1=>"output"],
    [source_stream_valid=>1=>"output"],
    [source_stream_data=>"$STREAM_DATA_WIDTH"=>"output"],
    [source_stream_ready=>"1"=>"input"],
    [source_stream_endofpacket=>1=>"output"],


    [sink_stream_startofpacket=>1=>"input"],
    [sink_stream_valid=>1=>"input"],
    [sink_stream_data=>"$STREAM_DATA_WIDTH"=>"input"],
    [sink_stream_ready=>"1"=>"output"],
    [sink_stream_endofpacket=>1=>"input"],

    [m_writefifo_fill=>$bits_to_encode_internal_fifo_depth=>"output"],

  );


  if ($SYMBOLS_PER_BEAT > 1) {
    push(@ports, [source_stream_empty=>$bits_to_encode_symbols_per_beat=>"output"]);
    push(@ports, [sink_stream_empty=>$bits_to_encode_symbols_per_beat=>"input"]);
  }

  if ($IN_ERROR_WIDTH > 0) {
    push(@ports, [source_stream_error=>$IN_ERROR_WIDTH=>"output"]);
    push(@ports, [sink_stream_error=>$IN_ERROR_WIDTH=>"input"]);
  }

  $mod->add_contents(
    e_port->news(@ports),
  );
}



sub make_internal_m_write_fifo {
  my $mod = shift;
  my $internal_fifo_depth = shift;
  my $internal_fifo_width = shift;
  my $DATA_WIDTH = shift;
  my $bits_to_encode_symbols_per_beat = shift;
  my $IN_ERROR_WIDTH = shift;
  my $SYMBOLS_PER_BEAT = shift;
  my $device_family = shift;
  my $BURST_TRANSFER = shift;
  my $space_available_width = shift;

  my $bits_to_encode_internal_fifo_depth = Bits_To_Encode($internal_fifo_depth) -1;
  my $error_offset = $DATA_WIDTH + $bits_to_encode_symbols_per_beat;

  my $m_write_fifo_mod = e_module->new({name=>$mod->name() . "_m_writefifo"});
  &define_scfifo($m_write_fifo_mod, "m_writefifo", $internal_fifo_depth, $internal_fifo_width, 0, 1, $device_family, 1);

  $mod->add_contents(
    e_instance->new({name=>"the_" . $mod->name() . "_m_writefifo",
      module=>$m_write_fifo_mod}),



    e_assign->new({lhs=>"sink_stream_ready", rhs=>"~m_writefifo_usedw[$bits_to_encode_internal_fifo_depth-1] && ~m_writefifo_full && ~pause_till_eop_out"}),

    e_assign->new({lhs=>"m_writefifo_rdreq", rhs=>"~m_writefifo_empty & source_stream_ready"}),


    e_assign->new({lhs=>"source_stream_valid", rhs=>"~m_writefifo_empty"}),
    e_signal->new({name=>"source_stream_valid", export=>"1"}),

    e_register->new({out=>"m_writefifo_wrreq", in=>"sink_stream_really_valid", enable=>"1"}),
    e_assign->new({lhs=>"sink_stream_really_valid", rhs=>"sink_stream_valid & sink_stream_ready"}),


    e_register->new({out=>"transmitted_eop", in=>"source_stream_endofpacket & source_stream_ready & source_stream_valid", enable=>"1"}),
    e_assign->new({lhs=>"source_stream_endofpacket_sig", rhs=>"(source_stream_endofpacket_from_fifo & ~transmitted_eop) | source_stream_endofpacket_hold"}),

    e_assign->new({lhs=>"source_stream_endofpacket", rhs=>"source_stream_endofpacket_sig"}),


    e_assign->new({lhs=>"hold_condition", rhs=>"source_stream_valid & ~source_stream_ready"}),
    e_register->new({out=>"source_stream_endofpacket_hold", in=>"hold_condition ? source_stream_endofpacket_sig : (source_stream_ready ? 0 : source_stream_endofpacket_hold)", enable=>"1"}),


    e_assign->new({lhs=>"m_writefifo_fill", rhs=>"m_writefifo_empty ? 0 : m_writefifo_usedw"}),


  );

  if ($SYMBOLS_PER_BEAT > 1) {
    $mod->add_contents(
      e_assign->new({lhs=>"source_stream_empty_sig", rhs=>"m_writefifo_q[$DATA_WIDTH + $bits_to_encode_symbols_per_beat -1:$DATA_WIDTH]"}),
      e_signal->new({name=>"source_stream_empty_sig", width=>$bits_to_encode_symbols_per_beat}),
      e_assign->new({lhs=>"source_stream_empty", rhs=>"source_stream_empty_sig | source_stream_empty_hold"}),
      e_register->new({out=>"source_stream_empty_hold", in=>"hold_condition ? source_stream_empty_sig : (source_stream_ready ? 0 : source_stream_empty_hold)", enable=>"1"}),
      e_signal->new({name=>"source_stream_empty_hold", width=>$bits_to_encode_symbols_per_beat}),

    );
  }

  my $fifo_data_in = "{sink_stream_startofpacket, sink_stream_endofpacket, ";
  if ($IN_ERROR_WIDTH > 0) {
    $fifo_data_in .= "sink_stream_error, ";
  }
  if ($SYMBOLS_PER_BEAT > 1) {
    $fifo_data_in .= "sink_stream_empty, ";
  }
  $fifo_data_in .= "sink_stream_data}";

  if ($IN_ERROR_WIDTH > 0) {
    $mod->add_contents(
      e_assign->new({lhs=>"source_stream_data", rhs=>"m_writefifo_q[$DATA_WIDTH-1:0]"}),

      e_assign->new({lhs=>"source_stream_error_sig", rhs=>"m_writefifo_q[$error_offset + $IN_ERROR_WIDTH -1:$error_offset]"}),
      e_signal->new({name=>"source_stream_error_sig", width=>$IN_ERROR_WIDTH}),
      e_assign->new({lhs=>"source_stream_error", rhs=>"source_stream_error_sig | source_stream_error_hold"}),
      e_register->new({out=>"source_stream_error_hold", in=>"hold_condition ? source_stream_error_sig : (source_stream_ready ? 0 : source_stream_error_hold)", enable=>"1"}),
      e_signal->new({name=>"source_stream_error_hold", width=>$IN_ERROR_WIDTH}),

      e_assign->new({lhs=>"source_stream_startofpacket", rhs=>"m_writefifo_q[$internal_fifo_width-1]"}),
      e_assign->new({lhs=>"source_stream_endofpacket_from_fifo", rhs=>"m_writefifo_q[$internal_fifo_width-2]"}),

    );
  } else {
    $mod->add_contents(
      e_assign->new({lhs=>"source_stream_data", rhs=>"m_writefifo_q[$DATA_WIDTH-1:0]"}),
      e_assign->new({lhs=>"source_stream_startofpacket", rhs=>"m_writefifo_q[$internal_fifo_width-1]"}),
      e_assign->new({lhs=>"source_stream_endofpacket_from_fifo", rhs=>"m_writefifo_q[$internal_fifo_width-2]"}),
    );
  }

  $mod->add_contents(
      e_register->new({out=>"m_writefifo_data", in=>"$fifo_data_in", enable=>"1"}),
  );
}

sub next_power_of_two {
  my $val = shift;
  my $power_of_two_num = 2;

  while ($power_of_two_num < $val) {
    $power_of_two_num = $power_of_two_num << 1;
  }
  return $power_of_two_num;
}

1;
