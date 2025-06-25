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
=head1 NAME

mk_clock_crossing.pl - Avalon bus clock crossing adaptor generator

=head1 VERSION

1.1

=head1 SYNOPSIS

This script generates the avalon bus clock crossing adaptor bridging
masters and slaves in two asynchronous clock domains.

=head1 DESCRIPTION

=head2 Overview

The purpose of the adaptor is to provide a safe, birectional
avalon bus bridge between two clock domains.  Filtering out of
metastability conditions via a bidirectional handshake protocol
ensures that data traversing this bridge will not be corrupted.
The bridge has a master and a slave interface. The master interface
consists of: master_wait_request(in), master_read(out), master_write(out),
master_writedata(out), master_byteenable(out), master_address(out) 
and master_readdata(in).
The slave interface
consists of: slave_waitrequest, slave_read(in), slave_write(in),
slave_writedata(in), slave_byteenable(in), slave_address(in) 
and slave_readdata(out).
Outgoing data toward the slave peripheral is address, writedata,
and byteenable and read/write control.
Incoming data from the slave is readdata and wait request.
All timing paths between the two clock domains
are cut using the Altera Quartus CUT synthesis attribute.

There are four handshake handshake tokens.  Read request and write request tokens
are passed from the slave state machine over the clock boundary to
the master state machine.  Read done and write done tokens are passed
back from the master to the slave state machine.  Tokens are encoded
on signal edges, not levels.  This is important to note since we need
to avoid using pulses as tokens, as these can disappear in synchronizers
when metastable events occur and the pulse is shorter in time than two 
periods of the receiving clock domain.  Using edges as tokens guarantees 
that this circuit works with any ratio of slave clock to master clock
frequencies.

=head2 Examples

=cut

use europa_all;
use e_std_synchronizer;
use strict;

my $proj = e_project->new(@ARGV);


my $system_name = $proj->{_system_name};


my $dont_cut_false_timing_paths =
  $proj->{ptf_hash}{"SYSTEM $system_name"}{WIZARD_SCRIPT_ARGUMENTS}{dont_cut_false_timing_paths};


my $bit1 = 1;
my $bit3 = 3;



my @FSM_states = &one_hot_encoding ($bit3);
my ($IDLE, $READ_WAIT, $WRITE_WAIT) = @FSM_states;



&make_proj($proj);
$proj->output();

sub get_sync_depth
{
  my $proj = shift;
  my $interface = shift;

  my $clock_name = $proj->module_ptf()->{$interface}->{SYSTEM_BUILDER_INFO}->{Clock_Source};
  my $user_sync_depth = $proj->get_clock_attribute($clock_name, "synchronizer_depth");
  my $sync_depth = ($user_sync_depth >= 2) ? $user_sync_depth : 2;

  return $sync_depth;
}


sub make_proj
{
   my $project = shift;

   my $top = $project->top();  # $top is top level module object
   $top->comment("Clock Domain Crossing Adapter" . $top->name() . "\n\n");

   my $thing = e_default_module_marker->new($top);

   my @special_avalon_signals =
       (
        [clk => 1],
        [waitrequest => 1],
        [reset_n => 1],
        );

   my $read_fifo_depth = 0;

   push (@special_avalon_signals, [readdatavalid => 1])
       if ($read_fifo_depth);

   my @write_and_control_signals = &get_write_and_control_signals($project);
   my @readdata_signals  = &get_readdata_signals($project);
   my @signals = (@write_and_control_signals,
                  @readdata_signals,
                  @special_avalon_signals,
		 [endofpacket => 1]);

   my $slave_type_map = { map {"slave_".$_->[0] => $_->[0] }
                          @signals};

   my $master_type_map = { map {"master_".$_->[0] => $_->[0] }
                           (@signals,[chipselect => 1])};

   e_avalon_slave->add({
			name => 'in',
			type_map => $slave_type_map,
			SBI_section => {Maximum_Pending_Read_Transactions => $read_fifo_depth},
		       });

   e_avalon_master->add({
			 name => 'out',
			 type_map => $master_type_map,
			});

   my $slave_SBI  = $project->module_ptf()->{"SLAVE in"}{SYSTEM_BUILDER_INFO};

   e_signal->adds(map {["master_".$_->[0],
                        $_->[1],0,0,0]} @signals);
   e_signal->adds(map {["slave_" .$_->[0],
                        $_->[1],0,0,0]} @signals);



    e_port->adds([master_read => 1, "output"],
                 [master_write => 1, "output"],
                 [slave_write => 1, "input"],
                 [slave_read => 1, "input"],
                 [slave_waitrequest => 1, "output"]);


   &define_bit_pipe($project);

   &define_edge_to_pulse($project);
   &define_slave_FSM($project);
   &define_master_FSM($project);

   &add_slave_logic($project);
   &add_master_logic($project);
   &add_eop_logic($project);

   &clock_cross_readdata_signals($project,@readdata_signals);
   &clock_cross_write_and_control_signals($project,@write_and_control_signals);
}


sub add_eop_logic {
  my $project = shift;

  my $top_name = $project->top->name();

  my $name = "endofpacket";
  my $width = 1;

  if ($dont_cut_false_timing_paths eq "1") {
    e_assign->add([["slave_$name" => $width],
		   ["master_$name" => $width]]);
  } else {
    e_instance->add({
		   name => "$name\_bit_pipe",
			  module => $project->top()->name()."_bit_pipe",
			  port_map => {data_out => "slave_$name",
				       data_in => "master_$name",
				       clk1 => "slave_clk",
				       reset_clk1_n => "slave_reset_n",
				       clk2 => "master_clk",
				       reset_clk2_n => "master_reset_n"
				      }
		  });
  }
}

sub add_slave_logic {
  my $project = shift;

  my $top_name = $project->top->name();
  my $sync_depth = get_sync_depth($project, "SLAVE in");

   e_std_synchronizer->adds(
     {
      data_in  => "master_read_done",
      data_out => "master_read_done_sync",
      clock    => "slave_clk",
       reset_n  => "slave_reset_n",
      depth => $sync_depth,
     },
     {
      data_in  => "master_write_done",
      data_out => "master_write_done_sync",
      clock    => "slave_clk",
       reset_n  => "slave_reset_n",
      depth => $sync_depth,
     }
  );

  e_instance->add({
		   name => "read_done_edge_to_pulse",
		   module => $project->top()->name()."_edge_to_pulse",
		   port_map => {
				"clock"     => "slave_clk",
				"reset_n"   => "slave_reset_n",
				"data_in"   => "master_read_done_sync",
				"data_out"  => "master_read_done_token",
			       }
		  });
  e_instance->add({
		   name => "write_done_edge_to_pulse",
		   module => $project->top()->name()."_edge_to_pulse",
		   port_map => {
				"clock"     => "slave_clk",
				"reset_n"   => "slave_reset_n",
				"data_in"   => "master_write_done_sync",
				"data_out"  => "master_write_done_token",
			       }
		  });
  e_instance->add({
		   name => "slave_FSM",
		   module => $project->top()->name()."_slave_FSM",
		   port_map => {
				slave_read => "slave_read",
				slave_write => "slave_write",
				master_read_done_token => "master_read_done_token",
				master_write_done_token => "master_write_done_token",
				slave_waitrequest => "slave_waitrequest",
				slave_read_request => "slave_read_request",
				slave_write_request => "slave_write_request"
			       }
		  });
}

sub add_master_logic {
  my $project = shift;

  my $top_name = $project->top->name();
  my $sync_depth = get_sync_depth($project, "MASTER out");

   e_std_synchronizer->adds(
     {
      data_in  => "slave_read_request",
      data_out => "slave_read_request_sync",
      clock    => "master_clk",
      reset_n  => "master_reset_n",
      depth => $sync_depth,
     },
     {
      data_in  => "slave_write_request",
      data_out => "slave_write_request_sync",
      clock    => "master_clk",
      reset_n  => "master_reset_n",
      depth => $sync_depth,
     }
  );

  e_instance->add({
		   name => "read_request_edge_to_pulse",
		   module => $project->top()->name()."_edge_to_pulse",
		   port_map => {
				"clock" => "master_clk",
				"reset_n" => "master_reset_n",
				"data_in" => "slave_read_request_sync",
				"data_out" => "slave_read_request_token"
			       }
		  });
  e_instance->add({
		   name => "write_request_edge_to_pulse",
		   module => $project->top()->name()."_edge_to_pulse",
		   port_map => {
				"clock" => "master_clk",
				"reset_n" => "master_reset_n",
				"data_in" => "slave_write_request_sync",
				"data_out" => "slave_write_request_token"
			       }
		  });
  e_instance->add({
		   name => "master_FSM",
		   module => $project->top()->name()."_master_FSM",
		   port_map => {
				master_waitrequest => "master_waitrequest",
				slave_read_request_token => "slave_read_request_token",
				slave_write_request_token => "slave_write_request_token",
				master_read => "master_read",
				master_write => "master_write",
				master_read_done => "master_read_done",
				master_write_done => "master_write_done"
			       }
		  });
}



sub clock_cross_readdata_signals {
   my ($project, @readdata_signals) = @_;

   my @master_concatenation = ();
   my @slave_concatenation = ();
   my $width = 0;

   foreach my $signal (@readdata_signals) {
     my ($name, $width) = @$signal;

     if ($name eq 'readdata') {
       e_register->add({out    => ["slave_$name\_p1" => $width],
			in     => ["master_$name" => $width],
			enable => "master_read & ~master_waitrequest",
			clock  => 'master_clk',
			reset => 'master_reset_n',
		       });
       if ($dont_cut_false_timing_paths eq "1") {


	 e_assign->add([["slave_$name" => $width],
			["slave_$name\_p1" => $width]]);
       } else {


	 e_register->add({
			  out => ["slave_$name" => $width],
			  in => ["slave_$name\_p1" => $width],
			  clock => 'slave_clk',
			  reset => 'slave_reset_n',
			  enable => "1",
			  cut_from_timing => "1",
			 });
       }
     } elsif ($name ne 'waitrequest') {
	 e_assign->add([["slave_$name" => $width],
			["master_$name" => $width]]);
     }
   }
 }

sub clock_cross_write_and_control_signals {

   my ($project,@write_and_control_signals) = @_;

   my @master_concatenation = ();
   my @slave_concatenation = ();
   my $width = 0;

   foreach my $signal (@write_and_control_signals) {
     my ($name, $width) = @$signal;

     if (($name ne 'read') && ($name ne 'write')) {
       if ($dont_cut_false_timing_paths eq "1") {


	 e_assign->add([["master_$name" => $width],
			["slave_$name" => $width]]);
       } else {

         e_register->add({
                          out => "slave_$name\_d1",
                          in => "slave_$name",
                          clock => "slave_clk",
	                  reset => "slave_reset_n",
                          enable => "1",
                          cut_to_timing => 1,
                          preserve_register => 1,
			 }),
         e_register->add({
                          out => "master_$name",
                          in => "slave_$name\_d1",
                          clock => "master_clk",
                          reset => "master_reset_n",
                          enable => "1",
                          preserve_register => 1,
			 })
       }
     }
   }
 }


sub get_write_and_control_signals {
   my $project = shift;

   my $master_SBI = $project->module_ptf()->{"MASTER out"}{SYSTEM_BUILDER_INFO};
   my @write_and_control_signals = ();

   my $data_width       = $master_SBI->{Data_Width} ||  &ribbit ("bad data width");
   my $use_byteenables  = ($data_width > 8) || ($master_SBI->{Address_Alignment} eq 'dynamic');

   my $address_width = max(
     $master_SBI->{Address_Width},
     1
   );


   my $nativeaddress_width = max(
     $master_SBI->{Address_Width} - log2($master_SBI->{Data_Width} / 8),
     1
   );

   push (@write_and_control_signals,
         [writedata => $data_width],
         [address   => $address_width],
         [read      => 1],
         [write     => 1],
         [nativeaddress => $nativeaddress_width],
         );

   if ($use_byteenables)
   {
      my $byteenable_width = $data_width / 8;
      push (@write_and_control_signals,
            [byteenable => $byteenable_width]);
   }

   my $max_size = 0; #$master_ptf->{Maximum_Burst_Size};
   my $burstcount_width = ($max_size)? &log2($max_size):0;
   if ($burstcount_width)
   {
      push (@write_and_control_signals,
            [burstcount => $burstcount_width]);
   }
   return @write_and_control_signals;
}

sub get_readdata_signals
{
   my $project = shift;

   my $Data_Width = $project->module_ptf()->{"SLAVE in"}
   {SYSTEM_BUILDER_INFO}{Data_Width} || &ribbit ("bad datawidth");
   return [readdata => $Data_Width];
}






sub define_slave_FSM {
    my $project = shift;
    my $module = e_module->new({name => $project->top()->name()."_slave_FSM"});


    $project->add_module($module);

    $module->add_contents (

	   e_port->news(
		[slave_read => $bit1, "input"],
                [slave_write => $bit1, "input"],
                [master_read_done_token => $bit1, "input"],
                [master_write_done_token => $bit1, "input"],
                [slave_waitrequest => $bit1, "output"],
		[slave_read_request => $bit1, "output"],
		[slave_write_request => $bit1, "output"]
		       ),


	   e_signal->news
		   ([slave_read_request => $bit1],
		    [slave_write_request => $bit1]
		   ),


	   e_register->news
		   ({out => "slave_read_request",
		     in => "next_slave_read_request",
		     clock => "slave_clk",
		     reset => "slave_reset_n",
		     enable => undef,
		     async_value => 0}
		   ),
	   e_register->news
		   ({out => "slave_write_request",
		     in => "next_slave_write_request",
		     clock => "slave_clk",
		     reset => "slave_reset_n",
		     enable => undef,
		     async_value => 0}
		   ),


	   e_signal->news
		   ([slave_state      => $bit3],
		    [next_slave_state => $bit3],
		   ),


	   e_register->news
		   ({out => "slave_state",
		     in => "next_slave_state",
		     clock => "slave_clk",
		     reset => "slave_reset_n",
		     enable => undef,
		     async_value => $IDLE}
		   ),

	   e_process->new({
		   clock   => undef,  # this is a purely combinatorial block
		   contents => [

















		       e_case->new ({
		           switch   => "slave_state",
			   parallel => 1,
			   default_sim => 0,
			   contents => {

	                   $IDLE => [
				    e_if->new({
				        comment  => "read request: go from IDLE state to READ_WAIT state",
					condition=> "slave_read",
					then     => [
						     "next_slave_state" => $READ_WAIT,
						     "slave_waitrequest" => 1,
						     "next_slave_read_request" => "!slave_read_request",
						     "next_slave_write_request" => "slave_write_request"
						    ],
					elsif => {
						  condition => "slave_write",
						  then => [
							   "next_slave_state" => $WRITE_WAIT,
							   "slave_waitrequest" => 1,
							   "next_slave_read_request" => "slave_read_request",
							   "next_slave_write_request" => "!slave_write_request"
							   ],

						  else => [
							   "next_slave_state" => "slave_state",
							   "slave_waitrequest" => 0,
							   "next_slave_read_request" => "slave_read_request",
							   "next_slave_write_request" => "slave_write_request"
							  ]
						  },
					      })
				    ],
                           $READ_WAIT => [
                                    e_if->new({
				        comment  => "stay in READ_WAIT state until master passes read done token",
	 			        condition=> "master_read_done_token",
					then     => [
						     "next_slave_state" => $IDLE,
						     "slave_waitrequest" => 0,
						    ],
					else     => [
						     "next_slave_state" => $READ_WAIT,
						     "slave_waitrequest" => 1,
						    ]
					      }),

				     e_assign->new({out => "next_slave_read_request",
						    in  => "slave_read_request"
						   }),
				     e_assign->new({out => "next_slave_write_request",
						    in  => "slave_write_request"
						   })
				    ],
                           $WRITE_WAIT => [
                                    e_if->new({
				        comment  => "stay in WRITE_WAIT state until master passes write done token",
	 			        condition=> "master_write_done_token",
					then     => [
						     "next_slave_state" => $IDLE,
						     "slave_waitrequest" => 0,
						    ],
					else     => [
						     "next_slave_state" => $WRITE_WAIT,
						     "slave_waitrequest" => 1,
						    ]
					      }),

				     e_assign->new({out => "next_slave_read_request",
						    in  => "slave_read_request"
						   }),
				     e_assign->new({out => "next_slave_write_request",
						    in  => "slave_write_request"
						   })

				    ],
			   default=> [
				      "next_slave_state" => $IDLE,
				      "slave_waitrequest" => 0,
				      "next_slave_read_request" => "slave_read_request",
				      "next_slave_write_request" => "slave_write_request"
				     ]
			   } # case contents
		    }), # e_case
		], # add contents
	  }) # e_process
    ) # module
} # sub define_slave_FSM




sub define_master_FSM {
    my $project = shift;
    my $module = e_module->new({name => $project->top()->name()."_master_FSM"});


    $project->add_module($module);

    $module->add_contents (

	   e_port->news(
		[master_waitrequest => $bit1, "input"],
                [slave_read_request_token => $bit1, "input"],
                [slave_write_request_token => $bit1, "input"],
		[master_read => $bit1, "output"],
                [master_write => $bit1, "output"],
                [master_read_done => $bit1, "output"],
                [master_write_done => $bit1, "output"]
		       ),


	   e_signal->news
		   ([master_read_done => $bit1],
		    [master_read_done => $bit1]
		   ),


	   e_register->news
		   ({out => "master_read_done",
		     in => "next_master_read_done",
		     clock => "master_clk",
		     reset => "master_reset_n",
		     enable => undef,
		     async_value => 0}
		   ),
	   e_register->news 
		   ({out => "master_write_done",
		     in => "next_master_write_done",
		     clock => "master_clk",
		     reset => "master_reset_n",
		     enable => undef,
		     async_value => 0}
		   ),


	   e_signal->news
		   ([master_read => $bit1],
		    [master_read => $bit1]
		   ),


	   e_register->news 
		   ({out => "master_read",
		     in => "next_master_read",
		     clock => "master_clk",
		     reset => "master_reset_n",
		     enable => undef,
		     async_value => 0}
		   ),
	   e_register->news 
		   ({out => "master_write",
		     in => "next_master_write",
		     clock => "master_clk",
		     reset => "master_reset_n",
		     enable => undef,
		     async_value => 0}
		   ),


	   e_signal->news
		   ([master_state      => $bit3],
		    [next_master_state => $bit3],
		   ),


	   e_register->news
		   ({out => "master_state",
		     in => "next_master_state",
		     clock => "master_clk",
		     reset => "master_reset_n",
		     enable => undef,
		     async_value => $IDLE}
		   ),

	   e_process->new({
		   clock   => undef,  # this is a purely combinatorial block
		   contents=> [























		       e_case->new ({
		           switch   => "master_state",
			   parallel => 1,
			   default_sim => 0,
			   contents => {

	                   $IDLE => [
				    e_if->new({
				        comment  => "if read request token from slave then goto READ_WAIT state",
					condition=> "slave_read_request_token",
					then     => [
						     "next_master_state" => $READ_WAIT,
						     "next_master_read" => 1,
						     "next_master_write" => 0
						    ],
					elsif => {
						  condition => "slave_write_request_token",
						  then => [
							   "next_master_state" => $WRITE_WAIT,
							   "next_master_read" => 0,
							   "next_master_write" => 1
							   ],
						  else => [
							   "next_master_state" => "master_state",
							   "next_master_read" => 0,
							   "next_master_write" => 0
							  ]
						  },
					      }),

				     e_assign->new({out => "next_master_read_done",
						    in  => "master_read_done"
						   }),
				     e_assign->new({out => "next_master_write_done",
						    in  => "master_write_done"
						   })
				    ],
                           $READ_WAIT => [
                                    e_if->new({
				        comment  => "stay in READ_WAIT state until master wait is deasserted",
	 			        condition=> "!master_waitrequest",
					then     => [

						     "next_master_state" => $IDLE,
						     "next_master_read_done" => "!master_read_done",
						     "next_master_read" => 0
						    ],
					else     => [

						     "next_master_state" => $READ_WAIT,
						     "next_master_read_done" => "master_read_done",
						     "next_master_read" => "master_read"
						    ]
					      }),

				     e_assign->new({out => "next_master_write_done",
						    in  => "master_write_done"
						   }),
				     e_assign->new({out => "next_master_write",
						    in  => 0
						   })
				    ],
                           $WRITE_WAIT => [
                                    e_if->new({
				        comment  => "stay in WRITE_WAIT state until slave wait is deasserted",
	 			        condition=> "!master_waitrequest",
					then     => [

						     "next_master_state" => $IDLE,
						     "next_master_write" => 0,
						     "next_master_write_done" => "!master_write_done"
						    ],
					else     => [

						     "next_master_state" => $WRITE_WAIT,
						     "next_master_write" => "master_write",
						     "next_master_write_done" => "master_write_done"
						    ]
					      }),

				     e_assign->new({out => "next_master_read_done",
						    in  => "master_read_done"
						   }),
				     e_assign->new({out => "next_master_read",
						    in  => 0
						   })
				    ],
			   default=> [

				      "next_master_state" => $IDLE,
				      "next_master_write" => 0,
				      "next_master_write_done" => "master_write_done",
				      "next_master_read" => 0,
				      "next_master_read_done" => "master_read_done"
				     ]
			   } # case contents
		    }), # e_case
		], # add contents
	  }), # e_process
    ) # module
} # sub define_master_FSM





sub define_edge_to_pulse {
   my $project = shift;

   my $module = e_module->new({name => $project->top()->name()."_edge_to_pulse"});


    $project->add_module($module);

    $module->add_contents (
	e_register->new({
			 out => "data_in_d1",
			 in => "data_in",
			 clock => "clock",
			 reset => "reset_n",
			 enable => "1"
			}),
        e_assign->new({
		       out => "data_out",
		       in  => "data_in ^ data_in_d1"
		      })
    );
}







sub define_bit_pipe {
    my $project = shift;
    my $module = e_module->new({name => $project->top()->name()."_bit_pipe"});


    $project->add_module($module);

    $module->add_contents (
         e_register->new({
                          out => "data_in_d1",
                          in => "data_in",
                          clock => "clk1",
	                  reset => "reset_clk1_n",
                          enable => "1",
                          cut_to_timing => 1,
                          preserve_register => 1,
			 }),
         e_register->new({
                          out => "data_out",
                          in => "data_in_d1",
                          clock => "clk2",
                          reset => "reset_clk2_n",
                          enable => "1",
                          preserve_register => 1,
			 })
    );
}

=head1 BUGS AND LIMITATIONS

We need a better way to cut timing paths on signal nets. Currently
only flop and chip IOs can be used as -to and -from timing path
endpoints. Module ports cannot be used since they may disappear
during the synthesis flattening process.  This forces us to
gratuitously instantiate flops soley to satisfy the static timing
analyzer.

=head1 SEE ALSO

e_synchronizer.pm

=head1 AUTHOR

Orion and Paul

=head2 History

Added false path timing assertions. (PS 10-5-04).
Swapped e_clock_crossing.pm with e_synchronizer.pm module (PS 01-12-05)

=head1 COPYRIGHT

Copyright (c) 2004-2005, Altera Corporation. All Rights Reserved.

=cut
