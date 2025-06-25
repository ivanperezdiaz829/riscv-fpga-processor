#Copyright (C)2001-2004 Altera Corporation
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

e_reset_gen - description of the module goes here ...

=head1 SYNOPSIS

The e_reset_gen class implements ... detailed description of functionality

=head1 METHODS

=over 4

=cut

package e_reset;
use e_process;
@ISA = ("e_process");
use strict;
use europa_utils;


my $__HASH_CHARACTER__ = '#';







my %fields = (
              reset_active 	=> 0,
              clk_speed_in_mhz  => 300,
              );

my %pointers = (
               );

&package_setup_fields_and_pointers
    (__PACKAGE__,
     \%fields, 
     \%pointers,
     );



=item I<new()>

Object constructor

=cut

sub new
{
   my $this = shift;
   $this = $this->SUPER::new(@_);
   $this->_reset()->direction('output');
   return $this;
}



=item I<reset_inactive()>

method description goes here...
...remember: there must be a newline around each POD tag (e.g. =item, =cut etc)!

=cut

sub reset_inactive
{
   my $this = shift;
   return 1
       if ($this->reset_active() == 0);
   return 0
       if ($this->reset_active() == 1);

   &ribbit ("illegal value for reset_active, try 0 or 1");
}




=item I<to_verilog()>

method description goes here...
...remember: there must be a newline around each POD tag (e.g. =item, =cut etc)!

=cut

sub to_verilog
{
   my $this = shift;
   my $indent = shift;
   my $reset_name = $this->reset()->expression();
   my $reset_active = $this->reset_active();
   my $reset_inactive = $this->reset_inactive();
   my $clk_speed_in_mhz = $this->clk_speed_in_mhz();
   my $period;
   my $base_multi;
   my $timescale_directive = $this->parent_module()->project()->timescale();
   my $three_clock_cycle;

   $timescale_directive =~ /^\s*(10{0,2})\s*(s|ms|us|ns|ps|fs)\s*\/.*$/;
   my $base_delay = $1;
   my $timescale= $2;

   if ($timescale =~ /^s/)   { $base_multi = 1; }
   elsif($timescale =~ /^ms/){ $base_multi = 0.001; }
   elsif($timescale =~ /^us/){ $base_multi = 0.000001; }
   elsif($timescale =~ /^ns/){ $base_multi = 0.000000001; }
   elsif($timescale =~ /^ps/){ $base_multi = 0.000000000001; }
   elsif($timescale =~ /^fs/){ $base_multi = 0.000000000000001; }
   
   $period = ((1 / ($clk_speed_in_mhz * (10 ** 6))) / $base_multi);
   $three_clock_cycle = int($period * 3);
	   
   my $vs = qq
[initial 
  begin
    $reset_name <= $reset_active;
    $__HASH_CHARACTER__$three_clock_cycle $reset_name <= $reset_inactive;
  end
];








   $vs =~ s/^/$indent/mg;
   return ($vs);
}



=item I<to_vhdl()>

method description goes here...
...remember: there must be a newline around each POD tag (e.g. =item, =cut etc)!

=cut

sub to_vhdl
{
   my $this = shift;
   my $indent = shift;
   my $reset_name = $this->reset()->expression();
   my $reset_active = $this->reset_active();
   my $reset_inactive = $this->reset_inactive();
   my $clk_speed_in_mhz = $this->clk_speed_in_mhz();
   my $period;
   my $base_multi;
   my $timescale_directive = $this->parent_module()->project()->timescale();
   my $three_clock_cycle;

   $timescale_directive =~ /^\s*(10{0,2})\s*(s|ms|us|ns|ps|fs)\s*\/.*$/;
   my $base_delay = $1;
   my $timescale= $2;

   if ($timescale =~ /^s/)   { $base_multi = 1; }
   elsif($timescale =~ /^ms/){ $base_multi = 0.001; }
   elsif($timescale =~ /^us/){ $base_multi = 0.000001; }
   elsif($timescale =~ /^ns/){ $base_multi = 0.000000001; }
   elsif($timescale =~ /^ps/){ $base_multi = 0.000000000001; }
   elsif($timescale =~ /^fs/){ $base_multi = 0.000000000000001; }
   
   $period = ((1 / ($clk_speed_in_mhz * (10 ** 6))) / $base_multi);
   $three_clock_cycle = int($period * 3);
   
   my $vs = qq
[PROCESS
  BEGIN
     $reset_name <= '$reset_active';
     wait for $three_clock_cycle $timescale;
     $reset_name <= '$reset_inactive'; 
  WAIT;
END PROCESS;
];


   $vs =~ s/^/$indent/mg;
   return ($vs);
}

1;

=back

=cut

=head1 EXAMPLE

Here is a usage example ...

=head1 AUTHOR

Santa Cruz Technology Center

=head1 BUGS AND LIMITATIONS

list them here ...

=head1 SEE ALSO

The inherited class e_process

=begin html

<A HREF="e_process.html">e_process</A> webpage

=end html

=head1 COPYRIGHT

Copyright (C)2001-2005 Altera Corporation, All rights reserved.

=cut

1;
