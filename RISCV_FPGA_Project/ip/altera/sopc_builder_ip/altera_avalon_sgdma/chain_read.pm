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

sub make_descriptor_read_block {
	my $mod = shift;
  my $WSA = shift;
  my $device_family = shift;


  my $DESC_WIDTH = 256;
  my $DESC_DATA_WIDTH = $WSA->{"desc_data_width"};
  my $ADDRESS_WIDTH = $WSA->{"address_width"};
  my $BYTES_TO_TRANSFER_WIDTH = $WSA->{"bytes_to_transfer_data_width"};
  my $BURST_WIDTH = $WSA->{"burst_data_width"};
  my $CONTROL_WIDTH = $WSA->{"control_data_width"};
  my $COMMAND_FIFO_DATA_WIDTH = $WSA->{"command_fifo_data_width"};
  my $DESCRIPTOR_READ_BURST = $WSA->{"descriptor_read_burst"};
  
  my $read_master_name = "descriptor_read";
  my $prefix = "descriptor_read";
  
  my $control_bits_fifo_depth = 2;
  my $control_bits_fifo_width = 7;


  &get_descriptor_read_port_list($mod, $DESC_WIDTH, $ADDRESS_WIDTH, $COMMAND_FIFO_DATA_WIDTH);
  &make_descriptor_read_avalon_master($mod, $DESC_DATA_WIDTH, $ADDRESS_WIDTH, $read_master_name, $prefix, $DESCRIPTOR_READ_BURST);
  &make_descriptor_read_assignments($mod, $ADDRESS_WIDTH, $BYTES_TO_TRANSFER_WIDTH, $BURST_WIDTH, $CONTROL_WIDTH, $DESCRIPTOR_READ_BURST);
  &make_descriptor_read_descriptor_assignments($mod);
  &make_descriptor_read_descriptor_registers($mod, $DESC_WIDTH, $ADDRESS_WIDTH);
  &make_descriptor_read_run_rising_edge($mod);
  
  &make_descriptor_read_control_fifo($mod, $control_bits_fifo_depth, $control_bits_fifo_width, $device_family);

  return $mod;
}


sub make_descriptor_read_control_fifo {
  my $mod = shift;
  my $control_bits_fifo_depth = shift;
  my $control_bits_fifo_width = shift;
  my $device_family = shift;

  my $control_bits_fifo_mod = e_module->new({name=>$mod->name() . "_control_bits_fifo"});
  &define_scfifo($control_bits_fifo_mod, "controlbitsfifo", $control_bits_fifo_depth, $control_bits_fifo_width, 1, 0, $device_family);

  $mod->add_contents(
    e_instance->new({name=>"the_" . $mod->name() . "_control_bits_fifo", module=>$control_bits_fifo_mod}),
    e_assign->new({lhs=>"controlbitsfifo_data", rhs=>"control[6:0]"}),
    e_assign->new({lhs=>"controlbitsfifo_wrreq", rhs=>"command_fifo_wrreq"}),

    e_signal->new({name=>"controlbitsfifo_empty", never_export=>"1"}),
    e_signal->new({name=>"controlbitsfifo_full", never_export=>"1"}),
  );
}

sub get_clock_reset_ports {
  my @ports = (
    [clk=>1=>"input"],
    [reset_n=>1=>"input"],
  ); 
  return @ports;
}
  
sub get_descriptor_read_desc_address_fifo_ports {
  my $DESC_WIDTH = shift;
  my $ADDRESS_WIDTH = shift;
  
  my @ports = (
    [desc_address_fifo_full=>1=>"input"],
    [desc_address_fifo_wrreq=>1=>"output"],
    [desc_address_fifo_data=>$ADDRESS_WIDTH=>"output"],  
  );
  return @ports;
}
  
sub get_descriptor_component_output_ports {
  my $ADDRESS_WIDTH = shift;
  my @ports = (


    [next_desc=>$ADDRESS_WIDTH=>"output"],





    [control=>8=>"output"],
    [chain_run=>1=>"output"],
  ); 
  return @ports;
}
  
sub get_control_bit_output_ports {
  my @ports = (
    [generate_eop=>1=>"output"],
    [read_fixed_address=>1=>"output"],
    [write_fixed_address=>1=>"output"],
    [atlantic_channel=>4=>"output"],
    [owned_by_hw=>1=>"output"],
  );
  return @ports;
}  

sub get_status_bit_output_ports {
  my @ports = (
    [e_00=>1=>"output"],
    [e_01=>1=>"output"],
    [e_02=>1=>"output"],
    [e_03=>1=>"output"],
    [e_04=>1=>"output"],
    [e_05=>1=>"output"],
    [e_06=>1=>"output"],
    [t_eop=>1=>"output"],
  );
  return @ports; 
}
  
sub get_control_signal_ports {
 my @ports = (
    [run=>1=>"input"],
    [pollen_clear_run=>1=>"input"],
  );
  return @ports;
}
  

sub get_descriptor_read_command_fifo_ports {
  my $DESC_WIDTH = shift;
  my $COMMAND_FIFO_DATA_WIDTH = shift;
  
  my @ports = (
    [command_fifo_full=>1=>"input"],
    [command_fifo_data=>$COMMAND_FIFO_DATA_WIDTH=>"output"],
    [command_fifo_wrreq=>1=>"output"],
  );
  return @ports;
}

  

sub get_descriptor_read_port_list {
  my $mod = shift;
  my $DESC_WIDTH = shift;
  my $ADDRESS_WIDTH = shift;
  my $COMMAND_FIFO_DATA_WIDTH = shift;
  
  my @ports;
  push(@ports, &get_clock_reset_ports());
  push(@ports, &get_descriptor_read_desc_address_fifo_ports($DESC_WIDTH, $ADDRESS_WIDTH));
  push(@ports, &get_descriptor_read_command_fifo_ports($DESC_WIDTH, $COMMAND_FIFO_DATA_WIDTH));
  push(@ports, &get_other_descriptor_read_ports($ADDRESS_WIDTH));
  
  $mod->add_contents(
  	e_port->news(@ports),
  );
}

sub get_other_descriptor_read_ports {
  my $ADDRESS_WIDTH = shift;
  my @ports;
  
  push(@ports, &get_next_descriptor_pointer_from_control_slave($ADDRESS_WIDTH));
  push(@ports, &get_descriptor_component_output_ports($ADDRESS_WIDTH));
  push(@ports, &get_control_bit_output_ports());

  push(@ports, &get_control_signal_ports());
  return @ports;
}

sub get_next_descriptor_pointer_from_control_slave{
	my $ADDRESS_WIDTH = shift;
	my @ports = (
		[descriptor_pointer_lower_reg_out=>32=>"input"],
		[descriptor_pointer_upper_reg_out=>32=>"input"],
	);
	return @ports;
}

sub make_descriptor_read_assignments {
  my $mod = shift;
  my $ADDRESS_WIDTH = shift;
  my $BYTES_TO_TRANSFER_WIDTH = shift;
  my $BURST_WIDTH = shift;
  my $CONTROL_WIDTH = shift;
  my $DESCRIPTOR_READ_BURST = shift;
  






   
   my $write_add_offset = 32 * 2;
	 my $next_desc_offset = 32 * 4;
	 my $bytes_to_transfer_offset = 32 * 6;
	 my $actual_bytes_transfered_offset = 32 * 7;
	 my $read_burst_offset = $bytes_to_transfer_offset + $BYTES_TO_TRANSFER_WIDTH;
	 my $write_burst_offset = $read_burst_offset + $BURST_WIDTH;
	 my $control_offset = $BYTES_TO_TRANSFER_WIDTH + $CONTROL_WIDTH + $actual_bytes_transfered_offset;
  
  $mod->add_contents(
    e_comment->new({comment=>"Control assignments"}),
    
    e_assign->new({lhs=>"command_fifo_wrreq_in", 
	    rhs=>"chain_run && fifos_not_full && delayed_desc_reg_en && owned_by_hw"}),
	  e_register->new({out=>"command_fifo_wrreq", in=>"command_fifo_wrreq_in", enable=>"1"}),
		e_assign->new({lhs=>"desc_address_fifo_wrreq", rhs=>"command_fifo_wrreq"}),
	  e_assign->new({lhs=>"fifos_not_full", rhs=>"~command_fifo_full && ~desc_address_fifo_full"}),
    
	  e_register->new({out=>"delayed_desc_reg_en", in=>"desc_reg_en", enable=>"1"}),
	  







	  
	  e_assign->new({lhs=>"read_address", rhs=>"desc_reg[$ADDRESS_WIDTH-1:0]"}),
	  e_assign->new({lhs=>"write_address", rhs=>"desc_reg[$write_add_offset+$ADDRESS_WIDTH-1:$write_add_offset]"}),
	  e_assign->new({lhs=>"next_desc", rhs=>"desc_reg[$next_desc_offset+$ADDRESS_WIDTH-1:$next_desc_offset]"}),
	  e_assign->new({lhs=>"bytes_to_transfer", rhs=>"desc_reg[$bytes_to_transfer_offset+$BYTES_TO_TRANSFER_WIDTH-1:$bytes_to_transfer_offset]"}),
	  e_assign->new({lhs=>"read_burst", rhs=>"desc_reg[$read_burst_offset+$BURST_WIDTH-1:$read_burst_offset]"}),
	  e_assign->new({lhs=>"write_burst", rhs=>"desc_reg[$write_burst_offset+$BURST_WIDTH-1:$write_burst_offset]"}),
	  e_assign->new({lhs=>"control", rhs=>"desc_reg[$control_offset+$CONTROL_WIDTH-1:$control_offset]"}),

	  
	  e_assign->new({lhs=>"command_fifo_data", 
      rhs=>"{control, write_burst, read_burst, bytes_to_transfer, write_address, read_address}"}),
    
	  e_register->new({out=>"desc_address_fifo_data", in=>"next_desc", enable=>"desc_reg_en"}),
	  
    e_signal->new({name=>"received_desc_counter", width=>"4", never_export=>"1"}),
    e_register->new({out=>"received_desc_counter", in=>"(received_desc_counter == 8)? 0 : (descriptor_read_readdatavalid ? (received_desc_counter + 1) : received_desc_counter)", enable=>"1"}),


    

    e_signal->new({name=>"next_desc", width=>$ADDRESS_WIDTH, never_export=>"1"}),
    e_signal->new({name=>"descriptor_read_address", width=>$ADDRESS_WIDTH}),
    e_signal->new({name=>"read_address", width=>"$ADDRESS_WIDTH", never_export=>"1"}),
    e_signal->new({name=>"write_address", width=>"$ADDRESS_WIDTH", never_export=>"1"}),
    e_signal->new({name=>"bytes_to_transfer", width=>"$BYTES_TO_TRANSFER_WIDTH", never_export=>"1"}),
    e_signal->new({name=>"read_burst", width=>"$BURST_WIDTH", never_export=>"1"}),
    e_signal->new({name=>"write_burst", width=>"$BURST_WIDTH", never_export=>"1"}),
    e_signal->new({name=>"control", width=>"$CONTROL_WIDTH", never_export=>"1"}),
    
  );

  if ($DESCRIPTOR_READ_BURST) {
    $mod->add_contents(
      e_register->new({out=>"descriptor_read_burstcount", in=>"8", enable=>"1"}),
      e_register->new({out=>"descriptor_read_read", in=>"descriptor_read_read ? 0 : ((~(desc_reg_en | delayed_desc_reg_en | command_fifo_wrreq)) ? (chain_run & owned_by_hw & fifos_not_full & desc_read_start) : 0)", enable=>"~descriptor_read_waitrequest"}),
      e_register->new({out=>"descriptor_read_address", in=>"next_desc", enable=>"~descriptor_read_waitrequest"}),
      e_register->new({out=>"desc_read_start", in=>"desc_read_start ? 0 : ((~(desc_reg_en | delayed_desc_reg_en | command_fifo_wrreq | |received_desc_counter)) ? (chain_run & fifos_not_full & ~posted_read_queued & owned_by_hw) : 0)", enable=>"~descriptor_read_waitrequest"}),
      e_register->new({out=>"chain_run", in=>"(run && owned_by_hw | (delayed_desc_reg_en | desc_reg_en) | |received_desc_counter) || run_rising_edge_in", enable=>"1"}),
      e_assign->new({lhs=>"descriptor_read_completed_in", rhs=>"started ? (run && ~owned_by_hw) : descriptor_read_completed"}),
      e_register->new({out=>"posted_read_queued", in=>"posted_read_queued ? ~(got_one_descriptor) : (desc_read_start)", enable=>"1"}),
    );
  } else {
    $mod->add_contents(
      e_register->new({out=>"posted_desc_counter", in=>"(desc_read_start & owned_by_hw & (posted_desc_counter != 8)) ? 8 : ((|posted_desc_counter & ~descriptor_read_waitrequest & fifos_not_full) ? (posted_desc_counter - 1) : posted_desc_counter)", enable=>"1"}),
      e_signal->new({name=>"posted_desc_counter", width=>"4", never_export=>"1"}),
      e_register->new({out=>"desc_read_start", in=>"desc_read_start ? 0 : ((~(desc_reg_en | delayed_desc_reg_en | command_fifo_wrreq | |received_desc_counter)) ? (chain_run & fifos_not_full & ~|posted_desc_counter & ~posted_read_queued) : 0)", enable=>"~descriptor_read_waitrequest"}),
      e_register->new({out=>"chain_run", in=>"(run && owned_by_hw | (delayed_desc_reg_en | desc_reg_en) | |posted_desc_counter | |received_desc_counter) || run_rising_edge_in", enable=>"1"}),
      e_register->new({out=>"descriptor_read_read", in=>"|posted_desc_counter & fifos_not_full", enable=>"~descriptor_read_waitrequest"}),
 

      e_register->new({out=>"descriptor_read_address", in=>"(descriptor_read_read)? (descriptor_read_address + 4) : next_desc", enable=>"~descriptor_read_waitrequest"}),
      e_assign->new({lhs=>"descriptor_read_completed_in", rhs=>"started ? (run && ~owned_by_hw && ~|posted_desc_counter) : descriptor_read_completed"}),
      e_register->new({out=>"posted_read_queued", in=>"posted_read_queued ? ~(got_one_descriptor) : (descriptor_read_read)", enable=>"1"}),
    );
  }
  
}

sub make_descriptor_read_descriptor_assignments {
  my $mod = shift;
  
  $mod->add_contents(
    

    e_comment->new({comment=>"control bits"}),
    e_assign->new({lhs=>"generate_eop", rhs=>"control[0]"}),
    e_assign->new({lhs=>"read_fixed_address", rhs=>"control[1]"}),
    e_assign->new({lhs=>"write_fixed_address", rhs=>"control[2]"}),
    e_assign->new({lhs=>"atlantic_channel", rhs=>"control[6:3]"}),
    e_assign->new({lhs=>"owned_by_hw", rhs=>"control[7]"}),
    
  );
}

sub make_descriptor_read_descriptor_registers {
  my $mod = shift;
  my $DESC_WIDTH = shift;
  my $ADDRESS_WIDTH = shift;
   
  $mod->add_contents(

    e_assign->new({lhs=>"got_one_descriptor", rhs=>"received_desc_counter == 8"}),

    e_comment->new({comment=>"read descriptor"}),
    e_assign->new({lhs=>"desc_reg_en", rhs=>"chain_run && got_one_descriptor"}),

    e_assign->new({lhs=>"init_descriptor", rhs=>"{1'b1, 31'b0, 32'b0, descriptor_pointer_upper_reg_out, descriptor_pointer_lower_reg_out, 128'b0}"}),
    e_signal->new({name=>"init_descriptor", width=>"256", never_export=>"1"}),

    e_comment->new({comment=>"Clear owned_by_hw bit when run is clear in Descriptor Polling Mode"}),
    e_assign->new({lhs=>"pollen_clear_run_desc", rhs=>"{1'b0, 31'b0, 32'b0, descriptor_pointer_upper_reg_out, descriptor_pointer_lower_reg_out, 128'b0}"}),
    e_signal->new({name=>"pollen_clear_run_desc", width=>"256", never_export=>"1"}),

    e_signal->new({name=>"desc_reg", width=>$DESC_WIDTH}),
    e_register->new({out=>"desc_reg", in=>"run_rising_edge_in ? init_descriptor : pollen_clear_run ? pollen_clear_run_desc: desc_assembler", enable=>"desc_reg_en || run_rising_edge_in || pollen_clear_run "}),
    

    e_signal->new({name=>"desc_assembler", width=>$DESC_WIDTH}),
    e_register->new({out=>"desc_assembler", in=>"(desc_assembler >> 32 | {descriptor_read_readdata, 224'b0})", enable=>"descriptor_read_readdatavalid"}),


    e_comment->new({comment=>"descriptor_read_completed register"}),
    e_register->new({out=>"descriptor_read_completed", in=>"descriptor_read_completed_in", enable=>"1"}),
    

    e_comment->new({comment=>"started register"}),
    e_assign->new({lhs=>"started_in", rhs=>"(run_rising_edge || run_rising_edge_in) ? 1'b1 : (descriptor_read_completed ? 1'b0 : started)"}),
    e_register->new({out=>"started", in=>"started_in", enable=>"1"}),


  );
  
}


sub make_descriptor_read_run_rising_edge {
  my $mod = shift;
  
  $mod->add_contents(

    e_comment->new({comment=>"delayed_run signal for the rising edge detector"}),
    e_register->new({out=>"delayed_run", in=>"run", enable=>"1"}),
    

    e_comment->new({comment=>"Run rising edge detector"}),
    e_assign->new({lhs=>"run_rising_edge_in", rhs=>"run & ~delayed_run"}),
    e_register->new({in=>"run_rising_edge_in", out=>"run_rising_edge", enable=>"run_rising_edge_in || desc_reg_en"}),
  );

}

sub make_descriptor_read_avalon_master {
  my $mod = shift;
  my $DESC_DATA_WIDTH = shift;
  my $ADDRESS_WIDTH = shift;
  my $read_master_name = shift;
  my $prefix = shift;
  my $DESCRIPTOR_READ_BURST = shift;
  
  $mod->add_contents(
    e_avalon_master->new({
      name => $read_master_name,
      type_map => {get_descriptor_read_master_type_map($prefix)},
    }),
    &get_descriptor_read_master_ports($prefix, $DESC_DATA_WIDTH, $ADDRESS_WIDTH, $DESCRIPTOR_READ_BURST),
  );
}

sub get_descriptor_read_master_type_map {
  my $prefix = shift;
  my @port_types = &get_descriptor_read_master_type_list();
  return map {($prefix . "_$_" => $_)} @port_types
}

sub get_descriptor_read_master_type_list {
  return qw(
    address
    readdata
    read
    readdatavalid
    waitrequest  
    burstcount
  );
}

sub get_descriptor_read_master_ports {
  my $prefix = shift;
  my $DESC_DATA_WIDTH = shift;
  my $ADDRESS_WIDTH = shift;
  my $DESCRIPTOR_READ_BURST = shift; 
  my @ports;
  my $max_burstcount_width = 16;
  
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
      width => $DESC_DATA_WIDTH,
      type => 'readdata',
    }),

    e_port->new({
      name => $prefix . "_readdatavalid",
      direction => "input",
      width => 1,
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
      width => "4"
    })
  ) if ($DESCRIPTOR_READ_BURST);

  return @ports;
}

1;
