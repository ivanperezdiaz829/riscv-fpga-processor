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

sub make_read_block_fifo {
  my $mod = shift;
  my $WSA = shift;
  my $device_family = shift;


  my $DESC_WIDTH = $WSA->{"desc_data_width"};
  my $ADDRESS_WIDTH = $WSA->{"address_width"};
  my $READ_BLOCK_DATA_WIDTH = $WSA->{"read_block_data_width"};
  print "Read Block Data Width : $READ_BLOCK_DATA_WIDTH \n" if $debug;
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
  my $OUT_ERROR_WIDTH = $WSA->{"out_error_width"};
  my $BURST_TRANSFER = $WSA->{"burst_transfer"};

  $UNALIGNED_TRANSFER &= ($SYMBOLS_PER_BEAT != 1);

  my $bits_to_encode_symbols_per_beat = Bits_To_Encode($SYMBOLS_PER_BEAT) -1;
  print "Bits to encode symbols per beat : $bits_to_encode_symbols_per_beat \n" if $debug;
  print "Source error width : $OUT_ERROR_WIDTH\n" if $debug;

  my $is_mtm = $HAS_READ_BLOCK && $HAS_WRITE_BLOCK;


  my $internal_fifo_depth = &get_readblock_internal_fifo_depth($READ_BLOCK_DATA_WIDTH, $WSA);

  my $internal_fifo_width;
  if ($UNALIGNED_TRANSFER) {
  if ($is_mtm) {

  $internal_fifo_width =  $bits_to_encode_symbols_per_beat +  $READ_BLOCK_DATA_WIDTH + 2 + $bits_to_encode_symbols_per_beat + $OUT_ERROR_WIDTH;
   } else {

  $internal_fifo_width =  2 + $bits_to_encode_symbols_per_beat +  $READ_BLOCK_DATA_WIDTH + 2 + $bits_to_encode_symbols_per_beat + $OUT_ERROR_WIDTH;
  }
  } else {

  $internal_fifo_width =  $READ_BLOCK_DATA_WIDTH + 2 + $bits_to_encode_symbols_per_beat + $OUT_ERROR_WIDTH;
  }
  print "Internal FIFO Width : $internal_fifo_width\n" if $debug;


  my $space_available_width = Bits_To_Encode($internal_fifo_depth) - 1;

  &add_read_block_fifo_ports($mod, $READ_BLOCK_DATA_WIDTH, $ADDRESS_WIDTH, $STREAM_DATA_WIDTH, $COMMAND_WIDTH, $SYMBOLS_PER_BEAT, $bits_to_encode_symbols_per_beat, $OUT_ERROR_WIDTH, $BURST_TRANSFER, $space_available_width, $UNALIGNED_TRANSFER, $is_mtm, $internal_fifo_depth);

  &make_internal_m_read_fifo($mod, $internal_fifo_depth, $internal_fifo_width, $READ_BLOCK_DATA_WIDTH, $bits_to_encode_symbols_per_beat, $OUT_ERROR_WIDTH, $SYMBOLS_PER_BEAT, $device_family, $BURST_TRANSFER, $space_available_width, $UNALIGNED_TRANSFER, $is_mtm);

  return $mod;
}

sub get_readblock_internal_fifo_depth {
  my $READ_BLOCK_DATA_WIDTH = shift;  
  my $WSA = shift;
  my $read_burstcount_width = $WSA->{"read_burstcount_width"};
  my $read_burst_fifo_depth = 2 ** ($read_burstcount_width + 1);
  my $BURST_TRANSFER = $WSA->{"burst_transfer"};







  my $internal_fifo_depth = 128 * 32 / ($READ_BLOCK_DATA_WIDTH << 1);
  if ($BURST_TRANSFER) {
    return $read_burst_fifo_depth;
  } else {
    return $internal_fifo_depth;
  }
}

sub add_read_block_fifo_ports {
  my $mod = shift;
  my $READ_BLOCK_DATA_WIDTH = shift;
  my $ADDRESS_WIDTH = shift;
  my $STREAM_DATA_WIDTH = shift;
  my $COMMAND_WIDTH = shift;
  my $SYMBOLS_PER_BEAT = shift;
  my $bits_to_encode_symbols_per_beat = shift;
  my $OUT_ERROR_WIDTH = shift;
  my $BURST_TRANSFER = shift;
  my $space_available_width = shift;
  my $UNALIGNED_TRANSFER = shift;
  my $is_mtm = shift;
  my $internal_fifo_depth = shift;
  my $bits_to_encode_internal_fifo_depth = Bits_To_Encode($internal_fifo_depth) -1;

  my @ports;

  @ports = (
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
    );

  if ($UNALIGNED_TRANSFER) {
    push(@ports, [tx_shift_out=>"$bits_to_encode_symbols_per_beat"=>"output"]);
    push(@ports, [tx_shift_in=>"$bits_to_encode_symbols_per_beat"=>"input"]);
  }

    if ($BURST_TRANSFER) {
    push(@ports, [m_readfifo_usedw=>"$bits_to_encode_internal_fifo_depth"=>"output"]);
  }

  if ($SYMBOLS_PER_BEAT > 1) {
    push(@ports, [source_stream_empty=>$bits_to_encode_symbols_per_beat=>"output"]);
    push(@ports, [sink_stream_empty=>$bits_to_encode_symbols_per_beat=>"input"]);
  }

  if (!$is_mtm && $UNALIGNED_TRANSFER) {
    push(@ports, [generate_sop_in=>1=>"input"]);
    push(@ports, [generate_eop_in=>1=>"input"]);
    push(@ports, [generate_sop_out=>1=>"output"]);
    push(@ports, [generate_eop_out=>1=>"output"]);
  }

  if ($OUT_ERROR_WIDTH > 0) {
    push(@ports, [source_stream_error=>$OUT_ERROR_WIDTH=>"output"]);
    push(@ports, [sink_stream_error=>$OUT_ERROR_WIDTH=>"input"]);
  }


  $mod->add_contents(
    e_port->news(@ports),
  );
}



sub make_internal_m_read_fifo {
  my $mod = shift;
  my $internal_fifo_depth = shift;
  my $internal_fifo_width = shift;
  my $DATA_WIDTH = shift;
  my $bits_to_encode_symbols_per_beat = shift;
  my $OUT_ERROR_WIDTH = shift;
  my $SYMBOLS_PER_BEAT = shift;
  my $device_family = shift;
  my $BURST_TRANSFER = shift;
  my $space_available_width = shift;
  my $UNALIGNED_TRANSFER = shift;
  my $is_mtm = shift;

  my $bits_to_encode_internal_fifo_depth = Bits_To_Encode($internal_fifo_depth) -1;
  my $source_stream_error_width;
  my $source_stream_empty_width;
  my $source_stream_startofpacket_width = 1;
  my $source_stream_endofpacket_width = 1;
  my $tx_shift_width;
  my $generate_sop_width;
  my $generate_eop_width;
  my $fifo_data_in;
  my $readfifo_ready_condition;

  my $m_read_fifo_mod = e_module->new({name=>$mod->name() . "_m_readfifo"});
  &define_scfifo($m_read_fifo_mod, "m_readfifo", $internal_fifo_depth, $internal_fifo_width, 0, 1, $device_family);

	if ($BURST_TRANSFER) {
	$readfifo_ready_condition = "~m_readfifo_full";
	} else {
	$readfifo_ready_condition = "~m_readfifo_usedw[$bits_to_encode_internal_fifo_depth-1] && ~m_readfifo_full";
	}

  $mod->add_contents(
    e_instance->new({name=>"the_" . $mod->name() . "_m_readfifo",
      module=>$m_read_fifo_mod}),


    e_assign->new({lhs=>"sink_stream_ready", rhs=>$readfifo_ready_condition}),

    e_assign->new({lhs=>"m_readfifo_rdreq", rhs=>"~m_readfifo_empty & source_stream_ready | m_readfifo_empty_fall & ~hold_condition"}),
    e_register->new({out=>"delayed_m_readfifo_empty", in=>"m_readfifo_empty", enable=>"1"}),
    e_assign->new({lhs=>"m_readfifo_empty_fall", rhs=>"~m_readfifo_empty & delayed_m_readfifo_empty"}),

    e_register->new({out=>"source_stream_valid_reg", in=>"m_readfifo_rdreq", enable=>"source_stream_ready | m_readfifo_rdreq"}),
    e_assign->new({lhs=>"source_stream_valid", rhs=>"source_stream_valid_reg"}),
    e_signal->new({name=>"source_stream_valid", export=>"1"}),

    e_register->new({out=>"m_readfifo_wrreq", in=>"sink_stream_valid", enable=>"1"}),
    e_register->new({out=>"m_readfifo_rdreq_delay", in=>"m_readfifo_rdreq", enable=>"1"}),

    e_register->new({out=>"transmitted_eop", in=>"transmitted_eop ? ~m_readfifo_rdreq : source_stream_endofpacket & source_stream_ready & source_stream_valid", enable=>"1"}),
    e_assign->new({lhs=>"source_stream_endofpacket_sig", rhs=>"m_readfifo_rdreq_delay? source_stream_endofpacket_from_fifo | source_stream_endofpacket_hold : (source_stream_endofpacket_from_fifo & ~transmitted_eop) | source_stream_endofpacket_hold"}),

    e_assign->new({lhs=>"source_stream_endofpacket", rhs=>"source_stream_endofpacket_sig"}),


    e_assign->new({lhs=>"hold_condition", rhs=>"source_stream_valid & ~source_stream_ready"}),
    e_register->new({out=>"source_stream_endofpacket_hold", in=>"hold_condition ? source_stream_endofpacket_sig : (source_stream_ready ? 0 : source_stream_endofpacket_hold)", enable=>"1"}),

  );

  if ($SYMBOLS_PER_BEAT > 1) {
    $mod->add_contents(
      e_assign->new({lhs=>"source_stream_empty_sig", rhs=>"m_readfifo_q[$DATA_WIDTH + $bits_to_encode_symbols_per_beat -1:$DATA_WIDTH]"}),
      e_signal->new({name=>"source_stream_empty_sig", width=>$bits_to_encode_symbols_per_beat}),
      e_assign->new({lhs=>"source_stream_empty", rhs=>"source_stream_empty_sig | source_stream_empty_hold"}),
      e_register->new({out=>"source_stream_empty_hold", in=>"hold_condition ? source_stream_empty_sig : (source_stream_ready ? 0 : source_stream_empty_hold)", enable=>"1"}),
      e_signal->new({name=>"source_stream_empty_hold", width=>$bits_to_encode_symbols_per_beat}),

    );
  }

  if ($UNALIGNED_TRANSFER) {
     if ($is_mtm) {
       $fifo_data_in = "{tx_shift_in, sink_stream_startofpacket, sink_stream_endofpacket, ";
       $tx_shift_width =  $bits_to_encode_symbols_per_beat;
       $generate_sop_width = 0;
       $generate_eop_width = 0;
       } else {
       $fifo_data_in = "{generate_eop_in, generate_sop_in, tx_shift_in, sink_stream_startofpacket, sink_stream_endofpacket, ";
       $tx_shift_width =  $bits_to_encode_symbols_per_beat;
       $generate_sop_width = 1;
       $generate_eop_width = 1;
	}
  } else {
  $fifo_data_in = "{sink_stream_startofpacket, sink_stream_endofpacket, ";
  $generate_sop_width 	= 0;
  $generate_eop_width 	= 0;
  $tx_shift_width 	= 0;
  }

  if ($OUT_ERROR_WIDTH > 0) {
    $fifo_data_in .= "sink_stream_error, ";
    $source_stream_error_width = $OUT_ERROR_WIDTH;
  } else {
    $source_stream_error_width = 0;
  }
  if ($SYMBOLS_PER_BEAT > 1) {
    $fifo_data_in .= "sink_stream_empty, ";
    $source_stream_empty_width = $bits_to_encode_symbols_per_beat;
  } else {
    $source_stream_empty_width = 0;
  }
  $fifo_data_in .= "sink_stream_data}";

  if ($OUT_ERROR_WIDTH > 0) {
    $mod->add_contents(
      e_assign->new({lhs=>"source_stream_error_sig", rhs=>"m_readfifo_q[$DATA_WIDTH+$source_stream_empty_width+$source_stream_error_width-1:$DATA_WIDTH+$source_stream_empty_width]"}),
      e_signal->new({name=>"source_stream_error_sig", width=>$source_stream_error_width}),
      e_assign->new({lhs=>"source_stream_error", rhs=>"source_stream_error_sig | source_stream_error_hold"}),
      e_register->new({out=>"source_stream_error_hold", in=>"hold_condition ? source_stream_error_sig : (source_stream_ready ? 0 : source_stream_error_hold)", enable=>"1"}),
      e_signal->new({name=>"source_stream_error_hold", width=>$source_stream_error_width}),
     );
   }

  if ($UNALIGNED_TRANSFER) {


    $mod->add_contents(
      e_assign->new({lhs=>"tx_shift_out", rhs=>"m_readfifo_q[$DATA_WIDTH+$source_stream_empty_width+$source_stream_error_width+$source_stream_endofpacket_width+$source_stream_startofpacket_width+$tx_shift_width-1:$DATA_WIDTH+$source_stream_empty_width+$source_stream_error_width+$source_stream_endofpacket_width+$source_stream_startofpacket_width]"}),
    );


  	if (!$is_mtm) {
    	$mod->add_contents(
      		e_assign->new({lhs=>"generate_sop_out", rhs=>"m_readfifo_q[$DATA_WIDTH+$source_stream_empty_width+$source_stream_error_width+$source_stream_endofpacket_width+$source_stream_startofpacket_width+$tx_shift_width+$generate_sop_width-1:$DATA_WIDTH+$source_stream_empty_width+$source_stream_error_width+$source_stream_endofpacket_width+$source_stream_startofpacket_width+$tx_shift_width]"}),
      	e_assign->new({lhs=>"generate_eop_out", rhs=>"m_readfifo_q[$DATA_WIDTH+$source_stream_empty_width+$source_stream_error_width+$source_stream_endofpacket_width+$source_stream_startofpacket_width+$tx_shift_width+$generate_sop_width+$generate_eop_width-1:$DATA_WIDTH+$source_stream_empty_width+$source_stream_error_width+$source_stream_endofpacket_width+$source_stream_startofpacket_width+$tx_shift_width+$generate_sop_width]"}),
  		);
    	}
  }

    $mod->add_contents(
      e_assign->new({lhs=>"source_stream_data", rhs=>"m_readfifo_q[$DATA_WIDTH-1:0]"}),
      e_assign->new({lhs=>"source_stream_endofpacket_from_fifo", rhs=>"m_readfifo_q[$DATA_WIDTH+$source_stream_empty_width+$source_stream_error_width+$source_stream_endofpacket_width-1]"}),
      e_assign->new({lhs=>"source_stream_startofpacket", rhs=>"m_readfifo_q[$DATA_WIDTH+$source_stream_empty_width+$source_stream_error_width+$source_stream_endofpacket_width+$source_stream_startofpacket_width-1]"}),

      e_register->new({out=>"m_readfifo_data", in=>"$fifo_data_in", enable=>"1"}),
  );
}

1;
