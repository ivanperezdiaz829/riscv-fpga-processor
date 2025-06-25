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

my $debug = 0;

sub make_tx_barrel {
  my $proj = shift;
  my $WSA = shift;
  my $mod = shift;
  my $rig = 1;

  my $HAS_WRITE_BLOCK = $WSA->{"has_write_block"};
  my $HAS_READ_BLOCK = $WSA->{"has_read_block"};
  my $is_mtm = $HAS_READ_BLOCK && $HAS_WRITE_BLOCK;

  my $SYMBOLS_PER_BEAT = $WSA->{"symbols_per_beat"};
  my $bits_to_encode_symbols_per_beat = Bits_To_Encode($SYMBOLS_PER_BEAT) - 1;
  my $EMPTY_WIDTH = $bits_to_encode_symbols_per_beat;
  my $OUT_ERROR_WIDTH = $WSA->{"out_error_width"}; 
  my $DATA_WIDTH = $WSA->{"read_block_data_width"};

  &make_tx_barrel_ports($DATA_WIDTH, $EMPTY_WIDTH, $OUT_ERROR_WIDTH, $is_mtm);
  &make_tx_barrel_logic($mod, $DATA_WIDTH, $SYMBOLS_PER_BEAT, $bits_to_encode_symbols_per_beat, $EMPTY_WIDTH, $OUT_ERROR_WIDTH, $is_mtm);
  return $mod;
}


sub make_tx_barrel_logic {
  my $mod = shift;
  my $DATA_WIDTH = shift;
  my $SYMBOLS_PER_BEAT = shift;
  my $bits_to_encode_symbols_per_beat = shift;
  my $EMPTY_WIDTH = shift;
  my $OUT_ERROR_WIDTH = shift;
  my $is_mtm = shift;
  my $MSB = $bits_to_encode_symbols_per_beat;
  my $shift_plus_empty_width = $bits_to_encode_symbols_per_beat + 1;

  
  my $symbol = $DATA_WIDTH / $SYMBOLS_PER_BEAT;


  my $fsmbits = 4;
  my @FSM_states = &one_hot_encoding ($fsmbits);
  my ($STATE_IDLE, $STATE_VALID, $STATE_PAUSE, $STATE_EOP) = @FSM_states;



  my %out_data_content;

  for (my $i=0; $i<$SYMBOLS_PER_BEAT; $i++) {
    if ($i == 0) {
      $out_data_content{$i} = [e_assign->new({lhs=>"out_data", rhs=>"data_levelone"})];
    } else {
      my $upper_leveltwo = $i * $symbol -1;
      my $upper_levelone = $DATA_WIDTH - 1;
      my $lower_levelone = $i * $symbol;
      $out_data_content{$i} = [e_assign->new({lhs=>"out_data", rhs=>"{data_levelone[$upper_leveltwo:0], data_leveltwo[$upper_levelone:$lower_levelone]}" })];
    }
  }

  if ($OUT_ERROR_WIDTH > 1) {
    $mod->add_contents(
      e_signal->new({name=>"error_levelone", width=>$OUT_ERROR_WIDTH, never_export=>"1"}),
      e_signal->new({name=>"error_leveltwo", width=>$OUT_ERROR_WIDTH, never_export=>"1"}),

      e_register->new({out=>"error_levelone", in=>"in_error", enable=>"pipeline_valid"}),
      e_register->new({out=>"error_leveltwo", in=>"error_levelone", enable=>"pipeline_valid"}),
      e_register->new({out=>"out_error", in=>"error_leveltwo", enable=>"pipeline_valid"}),
    );
  }

  if ($is_mtm) {
     $mod->add_contents(
        e_assign->new({lhs=>"out_eop", rhs=>"out_eop_int"}),
        e_assign->new({lhs=>"out_sop", rhs=>"out_sop_int"}),
       );
  } else {
  $mod->add_contents(

    e_comment->new({comment=>"Now we generate the outputs based on the given shift input"}),
    e_signal->new({name=>"transmitted_sop", never_export=>"1"}),
    e_assign->new({lhs=>"transmitted_sop", rhs=>"out_sop & out_ready & out_valid"}),
    e_signal->new({name=>"set_out_sop", never_export=>"1"}),
    e_assign->new({lhs=>"set_out_sop", rhs=>"(|shift_reg & sop_leveltwo & generate_sop_leveltwo) | (~|shift_reg & sop_levelone & generate_sop_levelone)"}),
    e_signal->new({name=>"out_sop", export=>"1"}),
    e_process->new({
        reset => "reset_n",
        reset_level => 0,
        asynchronous_contents => [e_assign->new(["out_sop" => "0"])],
        contents => [
          e_if->new({
            condition => "pipeline_valid & set_out_sop",
            then => ["out_sop" => "1"],
            elsif => {
              condition => "transmitted_sop",
              then => ["out_sop" => "0"],
            },
          }),
         ]
        }),
    e_signal->new({name=>"discard_following_packet", never_export=>"1"}),
    e_assign->new({lhs=>"discard_following_packet", rhs=>"generate_eop_levelone & pipeline_valid & ((|shift_reg & shift_plus_empty[$MSB] & eop_levelone)|(~|shift_reg & eop_levelone))"}),
    e_signal->new({name=>"discard_following_packet_rise_edge", never_export=>"1"}),
    e_assign->new({lhs=>"discard_following_packet_rise_edge", rhs=>"discard_following_packet & ~discard_following_packet_delayed"}),
    e_register->new({out=>"discard_following_packet_delayed", in=>"discard_following_packet", enable=>"1"}),
    e_register->new({out=>"discard_following_packet_reg", in=>"(discard_following_packet_reg & pipeline_valid) ? 0: discard_following_packet_rise_edge ? discard_following_packet : discard_following_packet_reg", enable=>"pipeline_valid"}),

    e_signal->new({name=>"transmitted_eop", never_export=>"1"}),
    e_assign->new({lhs=>"transmitted_eop", rhs=>"out_eop & out_ready & out_valid"}),
    e_signal->new({name=>"set_out_eop", never_export=>"1"}),
    e_assign->new({lhs=>"set_out_eop", rhs=>"(|shift_reg & shift_plus_empty[$MSB] & eop_levelone & generate_eop_levelone) | (|shift_reg & ~shift_plus_empty_leveltwo[$MSB] & eop_leveltwo & generate_eop_leveltwo) | (~|shift_reg & eop_levelone & generate_eop_levelone)"}),
    e_signal->new({name=>"out_eop", export=>"1"}),
    e_process->new({
        reset => "reset_n",
        reset_level => 0,
        asynchronous_contents => [e_assign->new(["out_eop" => "0"])],
        contents => [
          e_if->new({
            condition => "pipeline_valid & set_out_eop & ~discard_following_packet_reg",
            then => ["out_eop" => "1"],
            elsif => {
              condition => "transmitted_eop",
              then => ["out_eop" => "0"],
            },
          }),
         ]
        }),
 );
}

if (!$is_mtm) {
  $mod->add_contents(
    e_signal->new({name=>"generate_eop_levelone", width=>"1", never_export=>"1"}),
    e_register->new({out=>"generate_eop_levelone", in=>"generate_eop", enable=>"pipeline_valid"}),
    e_signal->new({name=>"generate_eop_leveltwo", width=>"1", never_export=>"1"}),
    e_register->new({out=>"generate_eop_leveltwo", in=>"generate_eop_levelone", enable=>"pipeline_valid"}),
    e_signal->new({name=>"generate_sop_levelone", width=>"1", never_export=>"1"}),
    e_register->new({out=>"generate_sop_levelone", in=>"generate_sop", enable=>"pipeline_valid"}),
    e_signal->new({name=>"generate_sop_leveltwo", width=>"1", never_export=>"1"}),
    e_register->new({out=>"generate_sop_leveltwo", in=>"generate_sop_levelone", enable=>"pipeline_valid"}),
      );
   }   


  $mod->add_contents(
    e_signal->new({name=>"shift_reg", width=>$bits_to_encode_symbols_per_beat, never_export=>"1"}),
    e_register->new({out=>"shift_reg", in=>"shift", enable=>"in_valid & in_ready"}),
    e_signal->new({name=>"empty_reg", width=>$EMPTY_WIDTH, never_export=>"1"}),
    e_register->new({out=>"empty_reg", in=>"in_empty", enable=>"pipeline_valid"}),
    e_signal->new({name=>"empty", width=>$EMPTY_WIDTH, never_export=>"1"}),
    e_comment->new({comment=>"Empty generation"}),
    e_signal->new({name=>"shift_plus_empty", width=>$shift_plus_empty_width, never_export=>"1"}),
    e_assign->new({lhs=>"shift_plus_empty", rhs=>"empty_reg + shift_reg"}),
    e_signal->new({name=>"shift_plus_empty_leveltwo", width=>$shift_plus_empty_width, never_export=>"1"}),
    e_register->new({out=>"shift_plus_empty_leveltwo", in=>"shift_plus_empty", enable=>"pipeline_valid"}),

    e_signal->new({name=>"empty_levelone", width=>$bits_to_encode_symbols_per_beat, never_export=>"1"}),
    e_signal->new({name=>"empty_leveltwo", width=>$bits_to_encode_symbols_per_beat, never_export=>"1"}),

    e_assign->new({lhs=>"empty_levelone[$bits_to_encode_symbols_per_beat-1:0]", rhs=>"shift_plus_empty[$bits_to_encode_symbols_per_beat -1:0]"}),
    e_assign->new({lhs=>"empty_leveltwo[$bits_to_encode_symbols_per_beat-1:0]", rhs=>"shift_plus_empty_leveltwo[$bits_to_encode_symbols_per_beat -1:0]"}),

    e_comment->new({comment=>"Pipe ready signal right through"}),
    e_assign->new({lhs=>"in_ready", rhs=>"out_ready & ~has_remaining_packet"}),

    e_signal->new({name=>"in_ready", width=>"1", export=>"1"}),
    
    e_register->new({out=>"has_remaining_packet", in=>"has_remaining_packet ? ~(out_ready & out_valid & out_eop_int)  : (in_valid & in_ready & in_eop)", enable=>"1"}),
    e_comment->new({comment=>"Start off with a 2 level shift register"}),
    e_assign->new({lhs=>"has_valid_data", rhs=>"(in_valid | eop_levelone | eop_leveltwo)"}),
    e_assign->new({lhs=>"pipeline_valid", rhs=>"has_valid_data & out_ready"}),


    e_comment->new({comment=>"Level One Shift Registers"}),
    e_register->new({out=>"sop_levelone", in=>"in_sop & in_ready & in_valid", enable=>"pipeline_valid"}),
    e_register->new({out=>"eop_levelone", in=>"in_eop & in_ready & in_valid", enable=>"pipeline_valid"}),
    e_signal->new({name=>"data_levelone", width=>"$DATA_WIDTH", never_export=>"1"}),
    e_register->new({out=>"data_levelone", in=>"in_data", enable=>"pipeline_valid"}),
    
    e_comment->new({comment=>"Level Two Shift Registers"}),   
    e_register->new({out=>"sop_leveltwo", in=>"sop_levelone", enable=>"pipeline_valid"}),
    e_register->new({out=>"eop_leveltwo", in=>"eop_levelone", enable=>"pipeline_valid"}),
    e_signal->new({name=>"data_leveltwo", width=>"$DATA_WIDTH", never_export=>"1"}),
    e_register->new({out=>"data_leveltwo", in=>"data_levelone", enable=>"pipeline_valid"}),


    e_comment->new({comment=>"Now we generate the outputs based on the given shift input"}),
    e_signal->new({name=>"transmitted_sop_int", never_export=>"1"}),
    e_assign->new({lhs=>"transmitted_sop_int", rhs=>"out_sop_int & out_ready & out_valid"}),
    e_signal->new({name=>"set_out_sop_int", never_export=>"1"}),
    e_assign->new({lhs=>"set_out_sop_int", rhs=>"(|shift_reg & sop_leveltwo) | (~|shift_reg & sop_levelone)"}),
    e_signal->new({name=>"out_sop_int", never_export=>"1"}),
    e_process->new({
        reset => "reset_n",
        reset_level => 0,
        asynchronous_contents => [e_assign->new(["out_sop_int" => "0"])],
        contents => [
          e_if->new({
            condition => "pipeline_valid & set_out_sop_int",
            then => ["out_sop_int" => "1"],
            elsif => {
              condition => "transmitted_sop_int",
              then => ["out_sop_int" => "0"],
            },
          }),
	 ]
        }),
    e_signal->new({name=>"discard_following_packet_int", never_export=>"1"}),
    e_assign->new({lhs=>"discard_following_packet_int", rhs=>"pipeline_valid & ((|shift_reg & shift_plus_empty[$MSB] & eop_levelone)|(~|shift_reg & eop_levelone))"}),
    e_signal->new({name=>"discard_following_packet_rise_edge_int", never_export=>"1"}),
    e_assign->new({lhs=>"discard_following_packet_rise_edge_int", rhs=>"discard_following_packet_int & ~discard_following_packet_delayed_int"}),
    e_register->new({out=>"discard_following_packet_delayed_int", in=>"discard_following_packet_int", enable=>"1"}),
    e_register->new({out=>"discard_following_packet_reg_int", in=>"(discard_following_packet_reg_int & pipeline_valid) ? 0: discard_following_packet_rise_edge_int ? discard_following_packet_int : discard_following_packet_reg_int", enable=>"pipeline_valid"}),

    e_signal->new({name=>"transmitted_eop_int", never_export=>"1"}),
    e_assign->new({lhs=>"transmitted_eop_int", rhs=>"out_eop_int & out_ready & out_valid"}),
    e_signal->new({name=>"set_out_eop_int", never_export=>"1"}),
    e_assign->new({lhs=>"set_out_eop_int", rhs=>"(|shift_reg & shift_plus_empty[$MSB] & eop_levelone) | (|shift_reg & ~shift_plus_empty_leveltwo[$MSB] & eop_leveltwo) | (~|shift_reg & eop_levelone)"}),
    e_signal->new({name=>"out_eop_int", never_export=>"1"}),
    e_process->new({
        reset => "reset_n",
        reset_level => 0,
        asynchronous_contents => [e_assign->new(["out_eop_int" => "0"])],
        contents => [
          e_if->new({
            condition => "pipeline_valid & set_out_eop_int & ~discard_following_packet_reg_int",
            then => ["out_eop_int" => "1"],
            elsif => {
              condition => "transmitted_eop_int",
              then => ["out_eop_int" => "0"],
            },
          }),
	 ]
        }),


    e_signal->new({name=>"out_empty", width=>"$EMPTY_WIDTH", export=>"1"}),
    e_register->new({out=>"out_empty", in=>"((|shift_reg & shift_plus_empty[$MSB] & eop_levelone) | (~|shift_reg & eop_levelone)) ? empty_levelone: empty_leveltwo", enable=>"out_ready & pipeline_valid"}),

    e_process->new({
      reset => "reset_n",
      reset_level => 0,
      asynchronous_contents => [e_assign->new(["out_data" => "0"]),],
      contents => [
        e_if->new({
          condition => "pipeline_valid",
          then => [
            e_case->new({
              switch => "shift_reg",
              parallel => "1",
              default_sim => 0,
              contents => {%out_data_content},
            }), # e_case
          ], # then
        }), # e_if
      ], # process contents
    }), # e_process


    e_signal->new({name=>"state", width=>"4", never_export=>"1"}),
    e_process->new({
      reset => "reset_n",
      reset_level => 0,
      asynchronous_contents => [e_assign->new(["state" => "$STATE_IDLE"]),],
      contents => [
        e_if->new({
          condition => "1",
          then => [
            e_case->new({
              switch => "state",
              parallel => "1",
              default_sim => 0,
              contents => {
                $STATE_IDLE => [
                  e_if->new({
                    condition => "sop_levelone & ~|shift_reg & pipeline_valid",
                    then => ["state" => "$STATE_VALID"],
                    elsif => {
                      condition => "sop_leveltwo & |shift_reg & pipeline_valid",
                      then => ["state" => "$STATE_VALID"],
                    },
                  }),
                ],
                $STATE_VALID => [
                  e_if->new({
                    condition => "out_eop_int & out_sop_int",
                    then => ["state" => "$STATE_IDLE"],
                    elsif => {
                      condition => "eop_leveltwo | eop_levelone",
                      then => ["state" => "$STATE_EOP"],
                    elsif => {
                      condition => "pipeline_valid",
                      then => ["state" => "$STATE_VALID"],
                      elsif => {
                        condition => "(~pipeline_valid & out_ready)",
                        then => ["state" => "$STATE_PAUSE"],
                        elsif => {
                          condition => "(~pipeline_valid & ~out_ready)",
                          then => ["state" => "$STATE_VALID"],
                          else => ["state" => "$STATE_PAUSE"],
			  }, # elsif
                        }, # elsif
                      }, # elsif
                    }, # elsif 
                  }),
                ],
                $STATE_PAUSE => [
                  e_if->new({ 
                    condition => "(out_ready & pipeline_valid)",
                    then => ["state" => "$STATE_VALID"],
                  }),
                ],
                $STATE_EOP => [
                  e_if->new({
                    condition => "((sop_levelone & ~|shift_reg) || (sop_leveltwo & |shift_reg))",
                    then => ["state" => "$STATE_VALID"],
                    elsif => { 
                      condition => "out_ready & out_eop_int",
                      then => ["state" => "$STATE_IDLE"],
                    },
                  }),
                ],
                default=> [
                  e_assign->new(["state" => "$STATE_IDLE"]),
                ], # default
              },  # contents
            }),  # e_case
          ], # then
        }), # e_if
      ],  # contents
    }),  # e_process


    e_assign->new({lhs=>"out_valid", rhs=>"(state == $STATE_VALID) | (state == $STATE_EOP)"}),

    e_signal->new({name=>"out_valid", width=>"1", export=>"1"}),
  );

}

sub make_tx_barrel_ports {
  my $DATA_WIDTH = shift;
  my $EMPTY_WIDTH = shift;
  my $ERROR_WIDTH = shift;
  my $is_mtm = shift;  

  my @ports = (
    ["clk"=>1=>"input"],
    ["reset_n"=>1=>"input"],
    ["in_data"=>$DATA_WIDTH=>"input"],
    ["in_valid"=>1=>"input"],
    ["in_ready"=>1=>"output"],
    ["in_sop"=>1=>"input"],
    ["in_eop"=>1=>"input"],
    ["in_empty"=>$EMPTY_WIDTH=>"input"],

    ["out_data"=>$DATA_WIDTH=>"output"],
    ["out_valid"=>1=>"output"],
    ["out_ready"=>1=>"input"],
    ["out_sop"=>1=>"output"],
    ["out_eop"=>1=>"output"],
    ["out_empty"=>$EMPTY_WIDTH=>"output"]

  );

  if ($ERROR_WIDTH > 1) {
    push (@ports, ["in_error"=>$ERROR_WIDTH=>"input"]);
    push (@ports, ["out_error"=>$ERROR_WIDTH=>"output"]);
  }

if (!$is_mtm) {
    push (@ports, ["generate_eop"=>1=>"input"]);
    push (@ports, ["generate_sop"=>1=>"input"]);
  }

}

1;
