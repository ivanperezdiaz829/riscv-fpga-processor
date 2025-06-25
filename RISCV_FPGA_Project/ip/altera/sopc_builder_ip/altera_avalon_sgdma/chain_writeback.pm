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

sub make_descriptor_writeback_block {
  my $mod = shift;
  my $WSA = shift;
  

  my $DESC_DATA_WIDTH = $WSA->{"desc_data_width"};
  my $DESC_WIDTH = 256;
  my $ADDRESS_WIDTH = $WSA->{"address_width"};
  my $CHAIN_WRITEBACK_DATA_WIDTH = $WSA->{"descriptor_writeback_data_width"};


  $CHAIN_WRITEBACK_DATA_WIDTH = 32;
  print "Chain writeback : data width : $CHAIN_WRITEBACK_DATA_WIDTH\n" if $debug;
  my $BYTE_ENABLE_WIDTH = 4;
  my $STATUS_TOKEN_WIDTH = $WSA->{"status_token_data_width"};
  my $BYTES_TO_TRANSFER_WIDTH = $WSA->{"bytes_to_transfer_data_width"};
  my $STATUS_WIDTH = $WSA->{"status_data_width"};
  
  my $control_bits_fifo_width = 7;
  

  my $OFFSET = (($DESC_WIDTH / 32) - 1) * 4;
  my $prefix = "descriptor_write";
  my $write_master_name = "descriptor_write";
  
  &add_descriptor_writeback_ports($mod, $CHAIN_WRITEBACK_DATA_WIDTH, $ADDRESS_WIDTH, $STATUS_TOKEN_WIDTH);
  &make_descriptor_writeback_avalon_master($mod, $DESC_WIDTH, $ADDRESS_WIDTH, $write_master_name, 
  $prefix, $BYTE_ENABLE_WIDTH, $CHAIN_WRITEBACK_DATA_WIDTH);
  &add_descriptor_writeback_assignments($mod, $CHAIN_WRITEBACK_DATA_WIDTH, $STATUS_TOKEN_WIDTH, $OFFSET);
  &make_descriptor_writeback_registers($mod);
  $mod->add_contents(
    e_signal->new({name=>"descriptor_write_busy", width=>1}),
    e_assign->new({lhs=>"descriptor_write_busy", rhs=>"descriptor_write_write0 | descriptor_write_write"}),
  );
  &decode_the_status_token($mod, $BYTES_TO_TRANSFER_WIDTH, $STATUS_WIDTH);

  &make_readback_from_controlbits_fifo($mod, $control_bits_fifo_width); 
 
  return $mod;
}

sub make_readback_from_controlbits_fifo {
  my $mod = shift;
  my $control_bits_fifo_width = shift;

  $mod->add_contents(
    e_port->news(
      [controlbitsfifo_q=>$control_bits_fifo_width=>"input"],
      [controlbitsfifo_rdreq=>1=>"output"],
    ),

    e_assign->new({lhs=>"controlbitsfifo_rdreq", rhs=>"status_token_fifo_rdreq"}),

  );
}

sub get_descriptor_writeback_status_token_ports {
  my $CHAIN_WRITEBACK_DATA_WIDTH = shift;
  my $STATUS_TOKEN_WIDTH = shift;
  my @ports = (

    [status_token_fifo_empty=>1=>"input"],
    [status_token_fifo_q=>$STATUS_TOKEN_WIDTH=>"input"],
    [status_token_fifo_rdreq=>1=>"output"],
  );
  return @ports;
}

sub get_descriptor_writeback_desc_address_fifo_ports {
  my $ADDRESS_WIDTH = shift;
  my @ports = (

    [desc_address_fifo_empty=>1=>"input"],
    [desc_address_fifo_q=>$ADDRESS_WIDTH=>"input"],
    [desc_address_fifo_rdreq=>1=>"output"],
  );
  return @ports;
}

sub add_descriptor_writeback_ports {
  my $mod = shift;
  my $CHAIN_WRITEBACK_DATA_WIDTH = shift;
  my $ADDRESS_WIDTH = shift;
  my $STATUS_TOKEN_WIDTH =shift;
  
  my @ports = (
    [clk=>1=>"input"],
    [reset_n=>1=>"input"],


    [park=>1=>"input"],
    

    [descriptor_write_busy=>1=>"output"],
    

    [t_eop=>1=>"output"],
    [atlantic_error=>1=>"output"],
  );
  push (@ports, &get_descriptor_writeback_status_token_ports($CHAIN_WRITEBACK_DATA_WIDTH, $STATUS_TOKEN_WIDTH));
  push (@ports, &get_descriptor_writeback_desc_address_fifo_ports($ADDRESS_WIDTH));
  $mod->add_contents(
    e_port->news(@ports),
  );
}



sub decode_the_status_token {
	my $mod = shift;
	my $BYTES_TO_TRANSFER_WIDTH = shift;
  my $STATUS_WIDTH = shift;
  
	my $status_reg_upper_limit = $BYTES_TO_TRANSFER_WIDTH + $STATUS_WIDTH -1;
	
	$mod->add_contents(
		e_assign->new({lhs=>"status_reg", rhs=>"status_token_fifo_data[$status_reg_upper_limit:$BYTES_TO_TRANSFER_WIDTH]"}),
		e_signal->new({name=>"status_reg", width=>8}),
		
		e_assign->new({lhs=>"t_eop", rhs=>"status_reg[7]"}),
		e_assign->new({lhs=>"atlantic_error", rhs=>"status_reg[6] | status_reg[5] | status_reg[4] | status_reg[3] | status_reg[2] | status_reg[1] | status_reg[0]"}),	  
	);
}

sub add_descriptor_writeback_assignments {
  my $mod = shift;
  my $CHAIN_WRITEBACK_DATA_WIDTH = shift;
  my $STATUS_TOKEN_WIDTH = shift;
  my $OFFSET = shift;
  my $write_data_padding = $CHAIN_WRITEBACK_DATA_WIDTH - $STATUS_TOKEN_WIDTH;
  
  $mod->add_contents(
    e_register->new({out=>"descriptor_write_writedata", in=>"{park, controlbitsfifo_q, status_token_fifo_q}", enable=>"~descriptor_write_waitrequest"}),
    e_register->new({out=>"descriptor_write_address", in=>"desc_address_fifo_q + $OFFSET", enable=>"~descriptor_write_waitrequest"}),
                   
    e_assign->new({lhs=>"fifos_not_empty", rhs=>"~status_token_fifo_empty && ~desc_address_fifo_empty"}),
    e_assign->new({lhs=>"can_write", rhs=>"~descriptor_write_waitrequest && fifos_not_empty"}),
    
  ); 
}

sub make_descriptor_writeback_registers {
  my $mod = shift; 
  
  $mod->add_contents(

    e_comment->new({comment=>"write register"}),
    e_register->new({out=>"descriptor_write_write0", in=>"status_token_fifo_rdreq", enable=>"~descriptor_write_waitrequest"}),
    e_register->new({out=>"descriptor_write_write", in=>"descriptor_write_write0", enable=>"~descriptor_write_waitrequest"}),


    e_comment->new({comment=>"status_token_fifo_rdreq register"}),
    e_assign->new({lhs=>"status_token_fifo_rdreq_in", rhs=>"status_token_fifo_rdreq ? 1'b0 : can_write"}),
    e_register->new({out=>"status_token_fifo_rdreq", in=>"status_token_fifo_rdreq_in", enable=>"1"}),
  
    e_assign->new({lhs=>"desc_address_fifo_rdreq", rhs=>"status_token_fifo_rdreq"}),
    
  );
}
  

sub make_descriptor_writeback_avalon_master {
  my $mod = shift;
  my $DESC_WIDTH = shift;
  my $ADDRESS_WIDTH = shift;
  my $write_master_name = shift;
  my $prefix = shift;
  my $BYTE_ENABLE_WIDTH = shift;
  my $CHAIN_WRITEBACK_DATA_WIDTH = shift;
  
  $mod->add_contents(
    e_avalon_master->new({
      name => $write_master_name,
      type_map => {get_descriptor_write_master_type_map($prefix)},
    }),
    &get_descriptor_write_master_ports($prefix, $DESC_WIDTH, $ADDRESS_WIDTH, $BYTE_ENABLE_WIDTH, $CHAIN_WRITEBACK_DATA_WIDTH),
  );
}

sub get_descriptor_write_master_type_map {
  my $prefix = shift;
  my @port_types = &get_descriptor_write_master_type_list();
  return map {($prefix . "_$_" => $_)} @port_types
}

sub get_descriptor_write_master_type_list {
  return qw(
    address
    writedata
    write
    waitrequest  
  );
}

sub get_descriptor_write_master_ports {
  my $prefix = shift;
  my $DESC_WIDTH = shift;
  my $ADDRESS_WIDTH = shift;
  my $BYTE_ENABLE_WIDTH = shift;
  my $CHAIN_WRITEBACK_DATA_WIDTH = shift;
  my @ports;
  my $burst_enable = 0;  # TODO : get this from somewhere
  my $max_burstcount_width = 16;
  
  push @ports, (
    e_port->new({
      name => $prefix . "_address",
      direction => "output",
      width => $ADDRESS_WIDTH,
      type => "address",
    }),

    e_port->new({
      name => $prefix . "_writedata",
      direction => "output",
      width => $CHAIN_WRITEBACK_DATA_WIDTH,
      type => "writedata",
    }),

    e_port->new({
      name => $prefix . "_write",
      direction => "output",
      type => "write",
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
      width => "$max_burstcount_width"
    })
  ) if ($burst_enable);

  return @ports;
}

1;
