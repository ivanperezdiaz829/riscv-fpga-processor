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

my $debug = 0;

sub make_chain_block {
	my $proj = shift;
  my $WSA = shift;
  my $mod = shift;
  my $device_family = shift;

  print "WSA : $WSA\n" if $debug;
  

  my $CONTROL_SLAVE_DATA_WIDTH = $WSA->{"control_slave_data_width"};
  my $CONTROL_SLAVE_ADDRESS_WIDTH = $WSA->{"control_slave_address_width"};
  print "Control_slave_data_width : $CONTROL_SLAVE_DATA_WIDTH\n" if $debug;
  my $DESC_WIDTH = $WSA->{"desc_data_width"};
  my $ADDRESS_WIDTH = $WSA->{"address_width"};
  my $DATA_WIDTH = 32;
  my $BYTE_ENABLE_WIDTH = 4;
  my $STATUS_TOKEN_WIDTH = $WSA->{"status_token_data_width"};
  my $OFFSET = (($DESC_WIDTH / 32) - 1) * 4;
  my $CHAIN_WRITEBACK_DATA_WIDTH = $WSA->{"descriptor_writeback_data_width"};
  my $COMMAND_FIFO_DATA_WIDTH = $WSA->{"command_fifo_data_width"};
  
  my $descriptor_read_prefix = "descriptor_read";
  my $descriptor_write_prefix = "descriptor_write";
  my $control_slave_prefix = "csr";
  
  print "Make chain control_status_slave\n" if $debug;
  my $chain_control_slave_mod = $proj->make_new_private_module("control_status_slave");
  &make_chain_control_status_slave($chain_control_slave_mod, $WSA);
  print "Make descriptor_read_block\n" if $debug;
  my $descriptor_read_mod = $proj->make_new_private_module("descriptor_read");
  &make_descriptor_read_block($descriptor_read_mod, $WSA, $device_family);
  print "Make descriptor_writeback_block\n"  if $debug;
  my $descriptor_writeback_mod = $proj->make_new_private_module("descriptor_write");
  &make_descriptor_writeback_block($descriptor_writeback_mod, $WSA);
  
  print "Add chain components\n" if $debug;
  &add_chain_components($mod, $chain_control_slave_mod, $descriptor_read_mod, $descriptor_writeback_mod);
  print "Get ports that should go up the top\n" if $debug;
  &get_ports_that_should_go_up_the_top($mod, $DATA_WIDTH, $ADDRESS_WIDTH, $DESC_WIDTH, $descriptor_read_prefix, 
    $descriptor_write_prefix, $control_slave_prefix, $BYTE_ENABLE_WIDTH, $STATUS_TOKEN_WIDTH, $CONTROL_SLAVE_DATA_WIDTH, 
    $CHAIN_WRITEBACK_DATA_WIDTH, $CONTROL_SLAVE_ADDRESS_WIDTH, $COMMAND_FIFO_DATA_WIDTH);
  print "Done making chain \n" if $debug;
  print "Setting top mod back to \$mod \n" if $debug;
  
  return $mod;
}

sub add_chain_components {
  my $mod = shift;
  my $chain_control_slave_mod = shift;
  my $descriptor_read_mod = shift;
  my $descriptor_writeback_mod = shift;
  
  $mod->add_contents(
    e_instance->new({module=>$chain_control_slave_mod}),
    e_instance->new({module=>$descriptor_read_mod}),
    e_instance->new({module=>$descriptor_writeback_mod}),
    
  );
  

  &make_wires_out_of_these_ports($mod, $chain_control_slave_mod);
  &make_wires_out_of_these_ports($mod, $descriptor_read_mod);
  &make_wires_out_of_these_ports($mod, $descriptor_writeback_mod);
  
}

sub make_wires_out_of_these_ports {
  my $mod = shift;
  my $inner_mod = shift;
  
  my @inner_port_names = $inner_mod->get_object_names("e_port");
  foreach my $inner_port_name (@inner_port_names) {
    
    next if (!&is_internal_signal($inner_port_name));
    
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


sub is_internal_signal {
  my $debug = 0;
  my $signal = shift;
  my @internal_signal_list = &get_internal_signal_list();
  
  foreach my $internal_signal (@internal_signal_list) { 
    if ($internal_signal =~ /$signal/ ) { 
      print "Internal : $signal \n" if $debug;
      return 1; 
    } 
  } 
  print "External : $signal \n" if $debug; 
  return 0; 
}

sub get_ports_that_should_go_up_the_top {
  my $mod = shift;
  my $DATA_WIDTH = shift;
  my $ADDRESS_WIDTH = shift;
  my $DESC_WIDTH = shift;
  my $descriptor_read_prefix = shift;
  my $descriptor_write_prefix = shift;
  my $control_slave_prefix = shift;
  my $BYTE_ENABLE_WIDTH = shift;
  my $STATUS_TOKEN_WIDTH = shift;
  my $CONTROL_SLAVE_DATA_WIDTH = shift;
  my $CHAIN_WRITEBACK_DATA_WIDTH = shift;
  my $CONTROL_SLAVE_ADDRESS_WIDTH = shift;
  my $COMMAND_FIFO_DATA_WIDTH = shift;
  
  my @top_level_ports;
  push (@top_level_ports, &get_descriptor_read_desc_address_fifo_ports($DESC_WIDTH, $ADDRESS_WIDTH));
  push (@top_level_ports, &get_descriptor_read_command_fifo_ports($DESC_WIDTH, $COMMAND_FIFO_DATA_WIDTH));
  push (@top_level_ports, &get_descriptor_writeback_status_token_ports($DATA_WIDTH, $STATUS_TOKEN_WIDTH));
  push (@top_level_ports, &get_descriptor_writeback_desc_address_fifo_ports($ADDRESS_WIDTH));
  
  $mod->add_contents(
    e_port->news(@top_level_ports),
    &get_descriptor_read_master_ports($descriptor_read_prefix, $DESC_WIDTH, $ADDRESS_WIDTH),
    &get_descriptor_write_master_ports($descriptor_write_prefix, $DESC_WIDTH, $ADDRESS_WIDTH, $BYTE_ENABLE_WIDTH, $CHAIN_WRITEBACK_DATA_WIDTH),
    &get_control_slave_ports($control_slave_prefix, $CONTROL_SLAVE_DATA_WIDTH, $CONTROL_SLAVE_ADDRESS_WIDTH),
  );
}

sub get_internal_signal_list {
  my @signals = (
    "atlantic_channel", 
    "eop_encountered",
    "error",
    "owned_by_hw",
    "run",
    "desc_write_burst",
    "desc_read_burst",
    "desc_write_address",
    "desc_read_address",
    "control_reg_out",
    "desc_actual_bytes_transferred",
    "desc_bytes_to_transfer",
    "desc_control",
    "desc_next_desc",
    "desc_status",
    "descriptor_pointer_lower_reg_out",
    "descriptor_pointer_upper_reg_out",
    "e_00",
    "e_05",
    "e_06",
    "e_02",
    "e_01",
    "e_03",
    "e_04",
    "fifo_out_of_sync_error",
    "generate_eop",
    "ie_chain_completed",
    "ie_descriptor_completed",
    "ie_eop_encountered",
    "ie_error",
    "ie_global",
    "ie_max_desc_processed",
    "max_desc_processed",
    "read_fixed_address",
    "status_reg_out",
    "stop_dma_error",
    "t_eop",
    "write_fixed_address"
  );
  return @signals;
}

1;
