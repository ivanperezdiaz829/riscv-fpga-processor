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

my $m_read_name = "m_read";

sub make_read_block {
  my $mod = shift;
  my $WSA = shift;
  

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
  my $read_burst_size = $WSA->{"read_burstcount_width"};
  my $ALWAYS_DO_MAX_BURST = $WSA->{"always_do_max_burst"};
  my $read_burst_size = $WSA->{"read_burstcount_width"};

  $UNALIGNED_TRANSFER &= ($SYMBOLS_PER_BEAT != 1);

  my $bits_to_encode_symbols_per_beat = Bits_To_Encode($SYMBOLS_PER_BEAT) -1;
  my $is_mtm = $HAS_READ_BLOCK && $HAS_WRITE_BLOCK;
  my $data_width_shift = log2($READ_BLOCK_DATA_WIDTH / 8);


  my $internal_fifo_depth = &get_readblock_internal_fifo_depth($READ_BLOCK_DATA_WIDTH, $WSA);

  my $internal_fifo_width = $READ_BLOCK_DATA_WIDTH + 2 + $bits_to_encode_symbols_per_beat;


  my $space_available_width = Bits_To_Encode($internal_fifo_depth) -1;

  my $read_master_name = $m_read_name;
  my $prefix = $m_read_name;

  my $latency_counter_width = Bits_To_Encode($internal_fifo_depth / 2);
 

  my $fsmbits = 7;
  my @FSM_states = &one_hot_encoding ($fsmbits);
  my ($STATE_IDLE, $STATE_GRAB_COMMAND, $STATE_COMPUTE_TRANSACTIONS, $STATE_TRANSFER,  $STATE_PAUSE, $STATE_WAIT_FOR_RESPONSE, $STATE_DONE) = @FSM_states; 


  my $remaining_transactions_load;
  my $bytes_to_transfer_lower;
  if ($SYMBOLS_PER_BEAT > 1) {
    $bytes_to_transfer_lower = "bytes_to_transfer[$bits_to_encode_symbols_per_beat-1:0]";
    my $one_less = $bits_to_encode_symbols_per_beat - 1;
    $bytes_to_transfer_lower = "bytes_to_transfer[$bits_to_encode_symbols_per_beat-1:0]";
    if ($UNALIGNED_TRANSFER) {
      $remaining_transactions_load = "(bytes_to_transfer >> $data_width_shift) + additional_transaction[$bits_to_encode_symbols_per_beat] + |additional_transaction[$one_less:0]";
    } else {
      $remaining_transactions_load = "(bytes_to_transfer >> $data_width_shift) + |$bytes_to_transfer_lower";
    }
  } else {
    $bytes_to_transfer_lower = "bytes_to_transfer";
    $remaining_transactions_load = "bytes_to_transfer";
  }
  my $transactions_left_to_post_load = $remaining_transactions_load;
    


  &add_read_block_ports($mod, $READ_BLOCK_DATA_WIDTH, $ADDRESS_WIDTH, $STREAM_DATA_WIDTH, $COMMAND_WIDTH, $SYMBOLS_PER_BEAT, $bits_to_encode_symbols_per_beat, $OUT_ERROR_WIDTH, $BURST_TRANSFER, $internal_fifo_depth);


  &make_read_block_avalon_master($mod, $READ_BLOCK_DATA_WIDTH, $ADDRESS_WIDTH, $read_master_name, $prefix, $BURST_TRANSFER, $read_burst_size);
  

  &make_read_block_command_input($mod, $ADDRESS_WIDTH, $BYTES_TO_TRANSFER_WIDTH, $COMMAND_WIDTH, $BURST_WIDTH, $BURST_TRANSFER, $ALWAYS_DO_MAX_BURST, $read_burst_size, $UNALIGNED_TRANSFER, $is_mtm);


  &make_read_block_request_path($mod, $BYTES_TO_TRANSFER_WIDTH, $STATE_COMPUTE_TRANSACTIONS, $STATE_TRANSFER, $STATE_DONE, $STATE_GRAB_COMMAND, $data_width_shift, $bits_to_encode_symbols_per_beat, $ADDRESS_WIDTH, $BURST_TRANSFER, $SYMBOLS_PER_BEAT, $READ_BLOCK_DATA_WIDTH, $UNALIGNED_TRANSFER, $transactions_left_to_post_load, $internal_fifo_depth, $BURST_WIDTH, $read_burst_size);


  &make_read_block_response_path($mod, $SYMBOLS_PER_BEAT, $STATE_GRAB_COMMAND, $STATE_COMPUTE_TRANSACTIONS, $BYTES_TO_TRANSFER_WIDTH, $data_width_shift, $bits_to_encode_symbols_per_beat, $UNALIGNED_TRANSFER, $remaining_transactions_load, $bytes_to_transfer_lower);


  &make_read_block_fsm($mod, $STATE_IDLE, $STATE_GRAB_COMMAND, $STATE_COMPUTE_TRANSACTIONS, $STATE_TRANSFER, $STATE_PAUSE, $STATE_WAIT_FOR_RESPONSE, $STATE_DONE, $fsmbits, $BURST_TRANSFER);


  &make_read_block_st_source($mod, $STATE_COMPUTE_TRANSACTIONS, $READ_BLOCK_DATA_WIDTH, $bits_to_encode_symbols_per_beat, $SYMBOLS_PER_BEAT, $is_mtm, $UNALIGNED_TRANSFER, $WSA->{"avalon_mm_byte_reorder_mode"});

  my $IS_MEM_TO_STREAM_MODE = $HAS_READ_BLOCK && !$HAS_WRITE_BLOCK;
  if ($IS_MEM_TO_STREAM_MODE) {
  	&make_m_read_status_token($mod, $STATUS_TOKEN_WIDTH, $BYTES_TO_TRANSFER_WIDTH, $STATUS_WIDTH, $STATE_DONE);
  }

  if ($UNALIGNED_TRANSFER) {
    &make_tx_barrel_shift_logic($mod, $bits_to_encode_symbols_per_beat, $STATE_GRAB_COMMAND, $is_mtm);
  }
  
  return $mod;
}


sub make_read_block_st_source {
  my $mod = shift;
  my $STATE_COMPUTE_TRANSACTIONS = shift;
  my $READ_BLOCK_DATA_WIDTH = shift;
  my $bits_to_encode_symbols_per_beat = shift;
  my $SYMBOLS_PER_BEAT = shift;
  my $is_mtm = shift;
  my $flipped_data_signal;
  my $UNALIGNED_TRANSFER = shift;
  my $avalon_mm_byte_reorder_mode = shift;
  my $empty_operand_width = $bits_to_encode_symbols_per_beat + 1;
  my $magic_number_sig = $empty_operand_width . "'b1";
  $magic_number_sig .= "0" for 1 .. $bits_to_encode_symbols_per_beat;
  
  my $sop = "(m_read_state == $STATE_COMPUTE_TRANSACTIONS)";
  if (!$is_mtm && !$UNALIGNED_TRANSFER) {
    $sop .= " & generate_sop";
  }

   if ($avalon_mm_byte_reorder_mode == 1){ 
	$flipped_data_signal = &swap_signals($SYMBOLS_PER_BEAT, "m_read_readdata");
   } else {
	$flipped_data_signal = "m_read_readdata";
   }
  $mod->add_contents(
    e_comment->new({comment=>"Output on the Av-ST Source"}),
    e_signal->new({name=>"source_stream_data", width=>"$READ_BLOCK_DATA_WIDTH"}),
     e_assign->new({lhs=>"source_stream_data", rhs=>$flipped_data_signal}),
     e_assign->new({lhs=>"source_stream_valid", rhs=>"read_go & m_read_readdatavalid"}),

    e_process->new({
      reset => "reset_n",
      reset_level => 0,
      asynchronous_contents => [e_assign->new(["source_stream_startofpacket" => "0"])],
      contents => [
        e_if->new({
          condition => "~source_stream_startofpacket",
          then => ["source_stream_startofpacket" => "$sop"],
          elsif => {
            condition => "source_stream_valid",
            then => ["source_stream_startofpacket" => "~source_stream_ready"],
          },
        }),
      ],
    }),


  );

  if (!$is_mtm && !$UNALIGNED_TRANSFER) {
    $mod->add_contents(
      e_assign->new({lhs=>"source_stream_endofpacket", rhs=>"read_go & endofpacket & m_read_readdatavalid & generate_eop"}),
     );
  } else {
    $mod->add_contents(
      e_assign->new({lhs=>"source_stream_endofpacket", rhs=>"read_go & endofpacket & m_read_readdatavalid"}),
     );
  }

  if ($SYMBOLS_PER_BEAT > 1) {
    $mod->add_contents(
      e_signal->new({name=>"source_stream_emtpy", width=>"$bits_to_encode_symbols_per_beat"}),
      e_assign->new({lhs=>"source_stream_empty", rhs=>"((endofpacket && source_stream_valid) ? empty_value : 0)"}),

      e_signal->new({name=>"empty_operand", width=>$empty_operand_width, never_export=>"1"}),
      e_assign->new({lhs=>"empty_operand", rhs=>"$magic_number_sig"}),
      e_signal->new({name=>"empty_value", width=>$empty_operand_width}),
    );
    if ($UNALIGNED_TRANSFER) {
      $mod->add_contents(
        e_register->new({out=>"empty_value", in=>"empty_operand - bytes_to_transfer[$bits_to_encode_symbols_per_beat-1:0] - tx_shift", enable=>"1"}),
      );
    } else {
      $mod->add_contents(
        e_register->new({out=>"empty_value", in=>"empty_operand - bytes_to_transfer[$bits_to_encode_symbols_per_beat-1:0]", enable=>"1"}),
      );
    }
  }
}

sub make_read_block_response_path {
  my $mod = shift;
  my $SYMBOLS_PER_BEAT = shift;
  my $STATE_GRAB_COMMAND = shift;
  my $STATE_COMPUTE_TRANSACTIONS = shift;
  my $BYTES_TO_TRANSFER_WIDTH = shift;
  my $data_width_shift = shift;
  my $bits_to_encode_symbols_per_beat = shift;
  my $UNALIGNED_TRANSFER = shift;
  my $remaining_transactions_load = shift;
  my $bytes_to_transfer_lower = shift;


  my $received_data_counter_increment;
  my $single_transfer_increment;
  if ($SYMBOLS_PER_BEAT > 1) {
    my $one_less = $bits_to_encode_symbols_per_beat - 1;
    $single_transfer_increment = "$SYMBOLS_PER_BEAT - tx_shift - source_stream_empty";

    if ($UNALIGNED_TRANSFER) {
      $received_data_counter_increment = "($SYMBOLS_PER_BEAT - source_stream_empty)";
      $mod->add_contents(
        e_assign->new({lhs=>"additional_transaction", rhs=>"$bytes_to_transfer_lower + tx_shift"}),
        e_signal->new({name=>"additional_transaction", width=>$bits_to_encode_symbols_per_beat+1, never_export=>"1"}),
      );
    } else {
      $received_data_counter_increment = "(|$bytes_to_transfer_lower ? $bytes_to_transfer_lower : $SYMBOLS_PER_BEAT)";
    }
  } else {
    $single_transfer_increment = "$SYMBOLS_PER_BEAT";
    $received_data_counter_increment = "1";
  }
  if (!$UNALIGNED_TRANSFER) {
    $mod->add_contents(
      e_comment->new({comment=>"Unaligned transfer not supported, tx_shift is always 0."}),
      e_signal->new({name=>"tx_shift", never_export=>"1"}),
      e_assign->new({lhs=>"tx_shift", rhs=>"0"}),
    );
  }
  $mod->add_contents(
    e_comment->new({comment=>"Response Path"}),
    e_signal->new({name=>"single_transfer", width=>"1"}),
    e_assign->new({lhs=>"single_transfer", rhs=>"source_stream_startofpacket & source_stream_endofpacket"}), 
    e_signal->new({name=>"received_data_counter", width=>"$BYTES_TO_TRANSFER_WIDTH", never_export=>"1"}),
    e_process->new({
      reset => "reset_n",
      reset_level => 0,
      asynchronous_contents => [e_assign->new(["received_data_counter" => "0"])],
      contents => [
        e_if->new({
          condition => "m_read_readdatavalid",
          then => [
            e_if->new({
              condition => "single_transfer",
              then => [
		e_assign->new({lhs=>"received_data_counter",
                rhs => "received_data_counter + $single_transfer_increment",
                }),
              ],
              elsif => { 
                  condition =>"endofpacket",
                  then => ["received_data_counter" => "received_data_counter + $received_data_counter_increment"],
              elsif => { 
                  condition =>"~|received_data_counter",
                  then => ["received_data_counter"=>"received_data_counter + $SYMBOLS_PER_BEAT - tx_shift"],                 
                        else => ["received_data_counter"=>"received_data_counter + $SYMBOLS_PER_BEAT"],
		},
              },
            }),
          ],
          elsif => {
            condition => "(m_read_state == $STATE_GRAB_COMMAND)",
            then => ["received_data_counter" => "0"],
          },
        }),
      ],
    }),

    e_signal->new({name=>"remaining_transactions", width=>"$BYTES_TO_TRANSFER_WIDTH", never_export=>"1"}),
    e_process->new({
      reset => "reset_n",
      reset_level => 0,
      asynchronous_contents => [e_assign->new(["remaining_transactions" => "0"])],
      contents => [
        e_if->new({
          condition => "(m_read_state == $STATE_COMPUTE_TRANSACTIONS)", 
          then =>["remaining_transactions" => "$remaining_transactions_load"], 
          elsif => {
            condition => "read_go & m_read_readdatavalid",
            then => ["remaining_transactions" => "remaining_transactions -1"],
          },
        }),
      ],
    }),

    e_assign->new({lhs=>"endofpacket", rhs=>"(remaining_transactions == 1)"}),
  );
}

sub make_read_block_fsm {
  my $mod = shift;
  my $STATE_IDLE = shift;
  my $STATE_GRAB_COMMAND = shift;
  my $STATE_COMPUTE_TRANSACTIONS = shift;
  my $STATE_TRANSFER = shift;
  my $STATE_PAUSE = shift;
  my $STATE_WAIT_FOR_RESPONSE = shift;
  my $STATE_DONE = shift;
  my $fsmbits = shift;
  my $BURST_TRANSFER = shift;
  my $pause_state_compute_transactions;
  my $pause_state_transfer;
  my $resume_read;

  if ($BURST_TRANSFER) {
    $pause_state_compute_transactions = "maximum_transactions_in_queue";
    $pause_state_transfer =  "~m_read_waitrequest & maximum_transactions_in_queue";
    $resume_read = "~m_read_waitrequest & ~maximum_transactions_in_queue";
  } else {
    $pause_state_compute_transactions = "~source_stream_ready";
    $pause_state_transfer =  "~source_stream_ready | maximum_transactions_in_queue";
    $resume_read = "source_stream_ready & ~m_read_waitrequest & ~maximum_transactions_in_queue";
  }


  $mod->add_contents(
    e_comment->new({comment=>"FSM"}),
    e_assign->new({lhs=>"received_enough_data", rhs=>"received_data_counter >= bytes_to_transfer"}),

    e_signal->new({name=>"m_read_state", width=>"$fsmbits", never_export=>"1"}),

    e_process->new({
      reset => "reset_n",
      reset_level => 0,
      asynchronous_contents => [e_assign->new(["m_read_state" => "$STATE_IDLE"]),],
      contents => [
        e_if->new({
          condition => "1",
          then => [
            e_case->new({
              switch => "m_read_state",
              parallel => "1",
              default_sim => 0,
              contents => {
                $STATE_IDLE => [
                  e_if->new({
                    condition => "read_command_valid",
                    then => ["m_read_state" => "$STATE_GRAB_COMMAND"],
                  }),
                ],
                $STATE_GRAB_COMMAND => [
                  e_assign->new({lhs=>"m_read_state", rhs=>"$STATE_COMPUTE_TRANSACTIONS"}),
                ],
                $STATE_COMPUTE_TRANSACTIONS => [
                  e_if->new({
                    condition => "$pause_state_compute_transactions",
                    then => ["m_read_state" => "$STATE_PAUSE"],
                    else => ["m_read_state" => "$STATE_TRANSFER"],
                  }),
                ],
                $STATE_TRANSFER => [
                  e_if->new({
                    condition => "$pause_state_transfer",
                    then => ["m_read_state" => "$STATE_PAUSE"],
                    elsif => {
                      condition => "~has_transactions_to_post",
                      then => ["m_read_state" => "$STATE_WAIT_FOR_RESPONSE"],
                      elsif => {
                        condition => "received_enough_data",
                        then => ["m_read_state" => "$STATE_DONE"],
                      },
                    },
                  }),
                ],
                $STATE_PAUSE => [
                  e_if->new({
                    condition => "received_enough_data",
                    then => ["m_read_state" => "$STATE_DONE"],
                    elsif => {
                      condition => "~has_transactions_to_post",
                      then => ["m_read_state" => "$STATE_WAIT_FOR_RESPONSE"],
                      elsif => {
                        condition => "$resume_read",
                        then => ["m_read_state" => "$STATE_TRANSFER"],
                      },
                    },
                  }),
                ],
                $STATE_WAIT_FOR_RESPONSE => [
                  e_if->new({
                    condition => "received_enough_data",
                    then => ["m_read_state" => "$STATE_DONE"],
                  }),
                ],
                $STATE_DONE => [
                  e_assign->new({lhs=>"m_read_state", rhs=>"$STATE_IDLE"}),
                ],
                default=> [
                  e_assign->new(["m_read_state" => "$STATE_IDLE"]),
                ], # default
              },  # contents
            }),  # e_case
          ],  # then
        }),  # e_if
      ],  # contents
    }),  # e_process

    e_assign->new({lhs=>"read_go", rhs=>"|(m_read_state & ($STATE_TRANSFER | $STATE_PAUSE | $STATE_WAIT_FOR_RESPONSE | $STATE_DONE))"}),

  );
}

sub log2 {
  my $n = shift;
  return (log($n)/log(2));
}

sub make_read_block_request_path {
  my $mod = shift;
  my $BYTES_TO_TRANSFER_WIDTH = shift;
  my $STATE_COMPUTE_TRANSACTIONS = shift;
  my $STATE_TRANSFER = shift;
  my $STATE_DONE = shift;
  my $STATE_GRAB_COMMAND = shift;
  my $data_width_shift = shift;
  my $bits_to_encode_symbols_per_beat = shift;
  my $ADDRESS_WIDTH = shift;
  my $BURST_TRANSFER = shift;
  my $SYMBOLS_PER_BEAT = shift;
  my $DATA_WIDTH = shift;
  my $UNALIGNED_TRANSFER = shift;
  my $transactions_left_to_post_load = shift;
  my $internal_fifo_depth = shift;
  my $BURST_WIDTH = shift;
  my $read_burst_size = shift;
  my $lower_address_zero = $bits_to_encode_symbols_per_beat . "\'b0";
  my $address_increment;
  my $address_load;
  my $burst_size_widen_width = $read_burst_size + $data_width_shift;
  my $burst_size_widen_padding = $data_width_shift . "\'b0";
  my $burst_m_read_read;
  my $issue_read_req;


  if ($BURST_TRANSFER) {
  $burst_m_read_read = "& m_read_read";
  } else {
  $burst_m_read_read = "";
  }

  if ($SYMBOLS_PER_BEAT > 1) {
    $mod->add_contents(
    e_signal->new({name=>"burst_size_right_shifted", width=>"$burst_size_widen_width", never_export=>"1"}),
    e_assign->new({lhs=>"burst_size_right_shifted", rhs=>"{burst_size, $burst_size_widen_padding}"}),
    );
    $address_increment = "burst_size_right_shifted";
    $address_load = "{start_address[$ADDRESS_WIDTH-1:$bits_to_encode_symbols_per_beat], $lower_address_zero}";
  } else {
    $address_increment = "burst_size";
    $address_load = "start_address";
  }
  $mod->add_contents(
    e_comment->new({comment=>"Request Path"}),
    e_signal->new({name=>"transactions_left_to_post", width=>"$BYTES_TO_TRANSFER_WIDTH", never_export=>"1"}),
    
    e_process->new({
      reset => "reset_n",
      reset_level => 0,
      asynchronous_contents => [e_assign->new(["transactions_left_to_post" => "0"]),],
      contents => [
        e_if->new({
          condition => "(m_read_state == $STATE_COMPUTE_TRANSACTIONS)",
          then => [
            e_assign->new({lhs=>"transactions_left_to_post", 
              rhs=>"$transactions_left_to_post_load"
            }),
          ],
          elsif => { 
            condition => "~m_read_waitrequest",
            then => [
              e_if->new({
                condition => "(m_read_state == $STATE_TRANSFER $burst_m_read_read)",
                then => ["transactions_left_to_post" => "(transactions_left_to_post - burst_value)"],
              }),
            ],
            elsif => {
              condition => "(m_read_state == $STATE_DONE)",
              then => ["transactions_left_to_post" => "0"],
            },
          },
        }),
      ],
    }),

    e_assign->new({lhs=>"still_got_full_burst", rhs=>"transactions_left_to_post >= burst_size"}),
    e_assign->new({lhs=>"burst_value", rhs=>"still_got_full_burst ? burst_size : transactions_left_to_post"}),
    e_assign->new({lhs=>"has_transactions_to_post", rhs=>"|transactions_left_to_post"}),


  );

  if ($debug) {
    $mod->add_contents(
      e_signal->new({name=>"posted_burst_transactions", width=>"$BYTES_TO_TRANSFER_WIDTH", never_export=>"1"}),
      e_register->new({out=>"posted_burst_transactions", in=>"(m_read_state == $STATE_GRAB_COMMAND) ? 0 : ((read_go & (m_read_state == $STATE_TRANSFER) ? (posted_burst_transactions + 1) : posted_burst_transactions))", enable=>"~m_read_waitrequest"}),
    );
  }


  my $max_pending_read = $internal_fifo_depth / 2 - 1;
  my $transactions_in_queue_width = ceil(log2($max_pending_read)) + 2;
  $mod->add_contents(
    e_signal->new({name=>"transactions_in_queue", width=>"$transactions_in_queue_width", never_export=>"1"}),
    e_assign->new({lhs=>"read_posted", rhs=>"m_read_read & ~m_read_waitrequest"}),
  );
  if ($BURST_TRANSFER) {
    $mod->add_contents(
      e_register->new({out=>"transactions_in_queue", in=>"(read_posted & ~m_read_readdatavalid) ? (transactions_in_queue + m_read_burstcount) : ((~read_posted & m_read_readdatavalid) ? (transactions_in_queue - 1) : ((read_posted & m_read_readdatavalid) ? (transactions_in_queue -1 + m_read_burstcount) : (transactions_in_queue)))", enable=>"1"}),
    e_assign->new({lhs=>"readfifo_remaining_space", rhs=>"$internal_fifo_depth-m_readfifo_usedw-transactions_in_queue-1"}),
    e_assign->new({lhs=>"maximum_transactions_in_queue", rhs=>"burst_value >= readfifo_remaining_space"}),
    );
  $issue_read_req = "m_read_read? 0: read_go & (m_read_state == $STATE_TRANSFER) & has_transactions_to_post & ~maximum_transactions_in_queue";
  } else {
    $mod->add_contents(
      e_register->new({out=>"transactions_in_queue", in=>"(read_posted & ~m_read_readdatavalid) ? (transactions_in_queue + 1) : ((~read_posted & m_read_readdatavalid) ? (transactions_in_queue - 1) : transactions_in_queue)", enable=>"1"}),
    e_assign->new({lhs=>"maximum_transactions_in_queue", rhs=>"transactions_in_queue >= ($max_pending_read - 1)"}),
    );
  $issue_read_req = "read_go & (m_read_state == $STATE_TRANSFER) & has_transactions_to_post";
  }



  $mod->add_contents(
    e_register->new({out=>"m_read_read", in=>"$issue_read_req", enable=>"~m_read_waitrequest"}),
    e_signal->new({name=>"m_read_address_inc", width=>"$ADDRESS_WIDTH", never_export=>"1"}),
    e_assign->new({lhs=>"m_read_address_inc", rhs=>"increment_address ? (m_read_address + $address_increment) : m_read_address"}),
    e_process->new({
      reset => "reset_n",
      reset_level => 0,
      asynchronous_contents => [e_assign->new(["m_read_address" => "0"]),],
      contents => [
        e_if->new({
          condition => "(m_read_state == $STATE_COMPUTE_TRANSACTIONS)",
          then => ["m_read_address" => "$address_load",
          ],
          elsif => {
            condition => "~m_read_waitrequest",
            then => [
              e_if->new({
                condition => "read_go & m_read_read",
                then => ["m_read_address" => "m_read_address_inc"],
              }),
            ],
          },
        }),
      ],
    }),
  );
  
  if ($BURST_TRANSFER) {
    $mod->add_contents(
      e_register->new({out=>"m_read_burstcount", in=>"burst_value", enable=>"~m_read_waitrequest"}),
    );
  }
}

sub make_read_block_command_input {
  my $mod = shift;
  my $ADDRESS_WIDTH = shift;
  my $BYTES_TO_TRANSFER_WIDTH = shift;
  my $COMMAND_WIDTH = shift;
  my $BURST_WIDTH = shift;
  my $BURST_TRANSFER = shift;
  my $ALWAYS_DO_MAX_BURST = shift;
  my $read_burst_size = shift;
  my $UNALIGNED_TRANSFER = shift;
  my $is_mtm = shift;

  my $BYTES_OFFSET = $ADDRESS_WIDTH;
  my $BURST_OFFSET = $BYTES_OFFSET + $BYTES_TO_TRANSFER_WIDTH;
  my $INCREMENT_OFFSET = $BURST_OFFSET + $BURST_WIDTH;

  my $read_command_data_width = $COMMAND_WIDTH + 2;

  $mod->add_contents(

    e_comment->new({comment=>"read_command_data_reg"}),
    e_signal->new({name=>"read_command_data_reg", width=>"$read_command_data_width"}),
    e_register->new({out=>"read_command_data_reg", in=>"read_command_data", enable=>"read_command_valid"}),


    e_signal->new({name=>"start_address", width=>"$ADDRESS_WIDTH", never_export=>"1"}),
    e_signal->new({name=>"bytes_to_transfer", width=>"$BYTES_TO_TRANSFER_WIDTH", never_export=>"1"}),
    e_signal->new({name=>"burst_size", width=>"$read_burst_size", never_export=>"1"}),
    e_signal->new({name=>"increment_address", width=>"1", never_export=>"1"}),


    e_comment->new({comment=>"command input"}),
    e_assign->new({lhs=>"start_address", rhs=>"read_command_data_reg[$ADDRESS_WIDTH-1:0]"}),
    e_assign->new({lhs=>"bytes_to_transfer", 
      rhs=>"read_command_data_reg[$BYTES_TO_TRANSFER_WIDTH+$BYTES_OFFSET-1:$BYTES_OFFSET]"}),
    e_assign->new({lhs=>"increment_address", rhs=>"read_command_data_reg[$INCREMENT_OFFSET]"}),
    e_assign->new({lhs=>"generate_eop", rhs=>"read_command_data_reg[$INCREMENT_OFFSET + 1]"}),
    e_assign->new({lhs=>"generate_sop", rhs=>"read_command_data_reg[$INCREMENT_OFFSET + 2]"}),

  );

    if ($UNALIGNED_TRANSFER && !$is_mtm) {
    $mod->add_contents(
    	e_signal->new({name=>"generate_eop", width=>"1", export=>"1"}),
    	e_signal->new({name=>"generate_sop", width=>"1", export=>"1"}),
	 	);
    } else {
    $mod->add_contents(
    	e_signal->new({name=>"generate_eop", width=>"1", never_export=>"1"}),
    	e_signal->new({name=>"generate_sop", width=>"1", never_export=>"1"}),
	 	);
	}

  if ($BURST_TRANSFER) {
    if ($ALWAYS_DO_MAX_BURST) {
      my $max_burst = 2 ** ($read_burst_size-1);
      $mod->add_contents(
        e_assign->new({lhs=>"burst_size", rhs=>"$max_burst"}),
      );
    } else {
      $mod->add_contents(
        e_assign->new({lhs=>"burst_size", rhs=>"read_command_data_reg[$BURST_WIDTH+$BURST_OFFSET-1:$BURST_OFFSET]"}),
      );
    }
  } else {
    $mod->add_contents(
      e_assign->new({lhs=>"burst_size", rhs=>"1"}),
    );
  }
}


sub make_tx_barrel_shift_logic {
  my $mod = shift;
  my $bits_to_encode_symbols_per_beat = shift;
  my $STATE_GRAB_COMMAND = shift;
  my $is_mtm = shift;


  if (!$is_mtm) {
    $mod->add_contents(
    e_port->new([generate_sop=>1=>"output"]),
    e_port->new([generate_eop=>1=>"output"]),
    );
  }
  $mod->add_contents(
    e_port->new([tx_shift=>$bits_to_encode_symbols_per_beat=>"output"]),
    e_register->new({out=>"tx_shift",
      in=>"start_address[$bits_to_encode_symbols_per_beat-1:0]", 
      enable=>"(m_read_state == $STATE_GRAB_COMMAND)"}),
  );

 }


sub add_read_block_ports {
  my $mod = shift;
  my $READ_BLOCK_DATA_WIDTH = shift;
  my $ADDRESS_WIDTH = shift;
  my $STREAM_DATA_WIDTH = shift;
  my $COMMAND_WIDTH = shift;
  my $SYMBOLS_PER_BEAT = shift;
  my $bits_to_encode_symbols_per_beat = shift;
  my $OUT_ERROR_WIDTH = shift;
  my $BURST_TRANSFER = shift;
  my $internal_fifo_depth = shift;
  my $m_readfifo_usedw_width = Bits_To_Encode($internal_fifo_depth);

  my $read_command_data_width = $COMMAND_WIDTH + 2;
  
  my @ports = (
    [clk=>1=>"input"],
    [reset_n=>1=>"input"],
    
    [read_command_data=>$read_command_data_width=>"input"],
    [read_command_valid=>1=>"input"],
      

    [source_stream_startofpacket=>1=>"output"],
    [source_stream_valid=>1=>"output"],
    [source_stream_data=>"$STREAM_DATA_WIDTH"=>"output"],
    [source_stream_ready=>"1"=>"input"],
    [source_stream_endofpacket=>1=>"output"],
    

    [read_go=>1=>"output"],
  
  );
    
   
  if ($SYMBOLS_PER_BEAT > 1) {
    push(@ports, [source_stream_empty=>$bits_to_encode_symbols_per_beat=>"output"]);
  }
  
  if ($OUT_ERROR_WIDTH > 0) {
    push(@ports, [source_stream_error=>$OUT_ERROR_WIDTH=>"output"]);

    $mod->add_contents(
      e_assign->new({lhs=>"source_stream_error", rhs=>"0"}),
    );
  }

  if ($BURST_TRANSFER) {
     push(@ports, [m_readfifo_usedw=>$m_readfifo_usedw_width-1=>"input"]);  
    $mod->add_contents(
    e_signal->new({name=>"readfifo_remaining_space", width=>$m_readfifo_usedw_width, never_export=>"1"}),
    );
  }
  
  $mod->add_contents(
    e_port->news(@ports),
  );
}


sub make_m_read_status_token {
  my $mod = shift;
  my $STATUS_TOKEN_WIDTH = shift;
  my $BYTES_TO_TRANSFER_WIDTH = shift;
  my $STATUS_WIDTH = shift;
  my $STATE_DONE = shift;
  
  $mod->add_contents(


    e_port->news(&get_atlantic_error_signals()),
    


    e_port->news(&get_status_token_fifo_ports($STATUS_TOKEN_WIDTH)),
    


    

    e_comment->new({comment=>"status register"}),
    e_signal->new({name=>"status_reg", width=>"$STATUS_WIDTH"}),
    

    e_comment->new({comment=>"T_EOP does not exist for a M-T-S configuration."}),
    e_assign->new({lhs=>"t_eop", rhs=>"1'b0"}),
    e_assign->new({lhs=>"status_word", rhs=>"{t_eop, e_06, e_05, e_04, e_03, e_02, e_01, e_00}"}),
    

    e_assign->new({lhs=>"e_00", rhs=>"1'b0"}),
    e_assign->new({lhs=>"e_01", rhs=>"1'b0"}),
    e_assign->new({lhs=>"e_02", rhs=>"1'b0"}),
    e_assign->new({lhs=>"e_03", rhs=>"1'b0"}),
    e_assign->new({lhs=>"e_04", rhs=>"1'b0"}),
    e_assign->new({lhs=>"e_05", rhs=>"1'b0"}),
    e_assign->new({lhs=>"e_06", rhs=>"1'b0"}),

	  e_signal->new({name=>"status_word", width=>"$STATUS_WIDTH"}),
    e_assign->new({lhs=>"status_reg_in", rhs=>"(m_read_state == $STATE_DONE) ? 0 : (status_word | status_reg)"}),
    e_register->new({out=>"status_reg", in=>"status_reg_in", enable=>"1"}),
    

    e_comment->new({comment=>"actual_bytes_transferred register"}),
    e_signal->new({name=>"actual_bytes_transferred", width=>"$BYTES_TO_TRANSFER_WIDTH"}),
    e_assign->new({lhs=>"actual_bytes_transferred", rhs=>"received_data_counter"}),
    

    e_comment->new({comment=>"status_token consists of the status signals and actual_bytes_transferred"}),
    e_assign->new({lhs=>"status_token_fifo_data", rhs=>"{status_reg, actual_bytes_transferred}"}),
    e_assign->new({lhs=>"status_token_fifo_wrreq", rhs=>"(m_read_state == $STATE_DONE)"}),
  );
}


sub make_read_block_avalon_master {
  my $mod = shift;
  my $READ_BLOCK_DATA_WIDTH = shift;
  my $ADDRESS_WIDTH = shift;
  my $read_master_name = shift;
  my $prefix = shift;
  my $BURST_TRANSFER = shift;
  my $read_burst_size = shift;
  
  $mod->add_contents(
    e_avalon_master->new({
      name => $read_master_name,
      type_map => {get_read_master_type_map($prefix, $BURST_TRANSFER)},
    }),
    &get_read_master_ports($prefix, $READ_BLOCK_DATA_WIDTH, $ADDRESS_WIDTH, $BURST_TRANSFER, $read_burst_size),
  );
}

sub get_read_master_type_map {
  my $prefix = shift;
  my $BURST_TRANSFER = shift;

  my @port_types = &get_read_master_type_list($BURST_TRANSFER);
  return map {($prefix . "_$_" => $_)} @port_types
}

sub get_read_master_type_list {
  my $BURST_TRANSFER = shift;
  my @ports = qw(
    address
    readdata
    readdatavalid
    read
    waitrequest  
  );

  push (@ports, "burstcount") if $BURST_TRANSFER;
  return @ports;
}

sub get_read_master_ports {
  my $prefix = shift;
  my $READ_BLOCK_DATA_WIDTH = shift;
  my $ADDRESS_WIDTH = shift;
  my $BURST_TRANSFER = shift;
  my $read_burst_size = shift;
  my @ports;

  push @ports, (
    e_port->new({
      name => $prefix . "_address",
      direction => "output",
      width => $ADDRESS_WIDTH,
      type => 'address',
    }),

    e_port->new({
      name => $prefix . "_readdata",
      direction => "input",
      width => $READ_BLOCK_DATA_WIDTH,
      type => 'readdata',
    }),

    e_port->new({
      name => $prefix . "_readdatavalid",
      direction => "input",
      type => 'readdatavalid',
    }),

    e_port->new({
      name => $prefix . "_read",
      direction => "output",
      type => 'read',
    }),

    e_port->new({
      name => $prefix . "_waitrequest",
      direction => "input",
      type => "waitrequest",
    }),
  );
    
  push @ports, (
    e_port->new({
      name => $prefix . "_burstcount",
      type => "burstcount",
      direction => "output",
      width => "$read_burst_size"
    })
  ) if ($BURST_TRANSFER);

  return @ports;
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
1;    
