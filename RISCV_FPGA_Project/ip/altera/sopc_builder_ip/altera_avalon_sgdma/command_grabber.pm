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

sub make_command_grabber {
	my $mod = shift;
  my $WSA = shift;
  

  my $DESC_WIDTH = $WSA->{"desc_data_width"};
  my $ADDRESS_WIDTH = $WSA->{"address_width"};
  my $HAS_READ_BLOCK = $WSA->{"has_read_block"};
  my $HAS_WRITE_BLOCK = $WSA->{"has_write_block"};
  my $BYTES_TO_TRANSFER_WIDTH = $WSA->{"bytes_to_transfer_data_width"};
  my $BURST_WIDTH = $WSA->{"burst_data_width"};
  my $CONTROL_WIDTH = $WSA->{"control_data_width"};
  my $ATLANTIC_CHANNEL_WIDTH = $WSA->{"atlantic_channel_data_width"};
  my $COMAMND_FIFO_DATA_WIDTH = $WSA->{"command_fifo_data_width"};
  my $COMMAND_WIDTH = 1 + $BURST_WIDTH + $BYTES_TO_TRANSFER_WIDTH + $ADDRESS_WIDTH;
  
  &add_command_grabber_ports($mod, $DESC_WIDTH, $COMMAND_WIDTH, $HAS_READ_BLOCK, $HAS_WRITE_BLOCK, $COMAMND_FIFO_DATA_WIDTH);
  &make_command_grabber_assignments($mod, $HAS_READ_BLOCK, $HAS_WRITE_BLOCK, $ADDRESS_WIDTH, 
    $BYTES_TO_TRANSFER_WIDTH, $BURST_WIDTH, $CONTROL_WIDTH, $ATLANTIC_CHANNEL_WIDTH, $COMMAND_WIDTH);
  &make_command_grabber_registers($mod, $HAS_READ_BLOCK, $HAS_WRITE_BLOCK);
  
  return $mod;
}

sub add_command_grabber_ports {
  my $mod = shift;
  my $DESC_WIDTH = shift;
  my $COMMAND_WIDTH = shift;
  my $HAS_READ_BLOCK = shift;
  my $HAS_WRITE_BLOCK = shift;
  my $COMAMND_FIFO_DATA_WIDTH = shift;
  
  my @ports = (

    [command_fifo_q=>"$COMAMND_FIFO_DATA_WIDTH"=>"input"],
    [command_fifo_rdreq=>1=>"output"],
    [command_fifo_empty=>1=>"input"],
  );
  
  my $read_command_data_width = $COMMAND_WIDTH + 2;

  if ($HAS_READ_BLOCK) {
    push (@ports, [read_go=>1=>"input"]);
    push (@ports, [m_read_waitrequest=>1=>"input"]);
    push (@ports, [read_command_data=>$read_command_data_width=>"output"]);
    push (@ports, [read_command_valid=>1=>"ouput"]);
  }
  
  if ($HAS_WRITE_BLOCK) {
    push (@ports, [write_go=>1=>"input"]);
    push (@ports, [m_write_waitrequest=>1=>"input"]);
    push (@ports, [write_command_data=>$COMMAND_WIDTH=>"output"]);
    push (@ports, [write_command_valid=>1=>"output"]);
  }
  
  $mod->add_contents(
    e_port->new(@ports),
  );
}

sub make_command_grabber_assignments {
  my $mod = shift;
  my $HAS_READ_BLOCK = shift;
  my $HAS_WRITE_BLOCK = shift;
  my $ADDRESS_WIDTH = shift;
  my $BYTES_TO_TRANSFER_WIDTH = shift;
  my $BURST_WIDTH = shift;
  my $CONTROL_WIDTH = shift;
  my $ATLANTIC_CHANNEL_WIDTH = shift;
  my $COMMAND_WIDTH = shift;
  
  my $read_command_data_width = $COMMAND_WIDTH + 2;
  
  my $bytes_offset = 2*$ADDRESS_WIDTH;
  my $read_burst_offset = $BYTES_TO_TRANSFER_WIDTH + $bytes_offset;
  my $write_burst_offset = $BURST_WIDTH + $read_burst_offset;
  my $control_offset = $BURST_WIDTH + $write_burst_offset;
  
  $mod->add_contents(

    e_comment->new({comment=>"Descriptor components"}),
    e_assign->new({lhs=>"read_address", rhs=>"command_fifo_q[$ADDRESS_WIDTH-1:0]"}),
    e_assign->new({lhs=>"write_address", rhs=>"command_fifo_q[$bytes_offset-1:$ADDRESS_WIDTH]"}),
    e_assign->new({lhs=>"bytes_to_transfer", rhs=>"command_fifo_q[$read_burst_offset-1:$bytes_offset]"}),
    e_assign->new({lhs=>"read_burst", rhs=>"command_fifo_q[$write_burst_offset-1:$read_burst_offset]"}),
    e_assign->new({lhs=>"write_burst", rhs=>"command_fifo_q[$control_offset-1:$write_burst_offset]"}),
    e_assign->new({lhs=>"control", rhs=>"command_fifo_q[$CONTROL_WIDTH+$control_offset-1:$control_offset]"}),
    

    e_comment->new({comment=>"control bits"}),
    e_assign->new({lhs=>"generate_eop", rhs=>"control[0]"}),
    e_assign->new({lhs=>"read_fixed_address", rhs=>"control[1]"}),
    e_assign->new({lhs=>"write_fixed_address", rhs=>"control[2]"}),
    e_assign->new({lhs=>"atlantic_channel", rhs=>"control[6:3]"}),

    
    

    e_signal->new({name=>"read_address", width=>"$ADDRESS_WIDTH", never_export=>"1"}),
    e_signal->new({name=>"write_address", width=>"$ADDRESS_WIDTH", never_export=>"1"}),
    e_signal->new({name=>"bytes_to_transfer", width=>"$BYTES_TO_TRANSFER_WIDTH", never_export=>"1"}),
    e_signal->new({name=>"read_burst", width=>"$BURST_WIDTH", never_export=>"1"}),
    e_signal->new({name=>"write_burst", width=>"$BURST_WIDTH", never_export=>"1"}),
    e_signal->new({name=>"control", width=>"$CONTROL_WIDTH", never_export=>"1"}),
    
    e_signal->new({name=>"read_fixed_address", width=>"1", never_export=>"1"}),
    e_signal->new({name=>"write_fixed_address", width=>"1", never_export=>"1"}),
    e_signal->new({name=>"atlantic_channel", width=>"$ATLANTIC_CHANNEL_WIDTH", never_export=>"1"}),    
  );
  
  $mod->add_contents(
    e_signal->new({name=>"read_command_data", width=>"$read_command_data_width"}),
    e_register->new({out=>"read_command_data", in=>"{write_fixed_address, generate_eop, ~read_fixed_address, read_burst, bytes_to_transfer, read_address}", 
      enable=>"1"}),
  ) if $HAS_READ_BLOCK;
  
  $mod->add_contents(
    e_signal->new({name=>"write_command_data", width=>"$COMMAND_WIDTH"}),
    e_register->new({out=>"write_command_data", in=>"{~write_fixed_address, write_burst, bytes_to_transfer, write_address}", 
      enable=>"1"}),
  ) if $HAS_WRITE_BLOCK;
}

sub make_command_grabber_registers {
  my $mod = shift;
  my $HAS_READ_BLOCK = shift;
  my $HAS_WRITE_BLOCK = shift;
  
  
  my $condition;
  if ($HAS_READ_BLOCK && $HAS_WRITE_BLOCK) {
  	$condition = "~read_go && ~write_go && ~m_read_waitrequest && ~m_write_waitrequest";
  } elsif ($HAS_WRITE_BLOCK) {
  	$condition = "~write_go && ~m_write_waitrequest";
  } elsif ($HAS_READ_BLOCK) {
  	$condition = "~read_go && ~m_read_waitrequest";
  }
  

  $mod->add_contents(  
    e_assign->new({lhs=>"read_command_valid", rhs=>"command_valid"}),
  ) if $HAS_READ_BLOCK;
  
  $mod->add_contents(
    e_assign->new({lhs=>"write_command_valid", rhs=>"command_valid"}),
  ) if $HAS_WRITE_BLOCK;

  $mod->add_contents(

    e_comment->new({comment=>"command_fifo_rdreq register"}),
    e_assign->new({lhs=>"command_fifo_rdreq_in", 
      rhs=>"(command_fifo_rdreq_reg || command_valid) ? 1'b0 : ($condition)"}),
    e_register->new({out=>"command_fifo_rdreq_reg", in=>"command_fifo_rdreq_in", enable=>"~command_fifo_empty"}),
    e_assign->new({lhs=>"command_fifo_rdreq", rhs=>"command_fifo_rdreq_reg"}),


    e_comment->new({comment=>"command_valid register"}),
    e_register->new({out=>"delay1_command_valid", in=>"command_fifo_rdreq_reg", enable=>"1"}),
    e_register->new({out=>"command_valid", in=>"delay1_command_valid", enable=>"1"}),
  
  );
}


1;

