

################################################################
# CLASS: e_clk_gen
#
################################################################


=head1 NAME

e_clk_gen - description of the module goes here ...

=head1 SYNOPSIS

The e_clk_gen class implements ... detailed description of functionality

=head1 METHODS

=over 4

=cut

package e_clk;
use e_expression;
use e_process;
@ISA = ("e_process");
use strict;
use europa_utils;

#done because of comment stripper.
my $__HASH_CHARACTER__ = '#';

################################################################
# e_module::new
#
# Constructor copied straight out of the tutorial.
#
################################################################
my %fields = (
              _clk => e_expression->new("clk"),
              ns_period => 30,
              );

my %pointers = (
               );

&package_setup_fields_and_pointers
    (__PACKAGE__,
     \%fields, 
     \%pointers,
     );

################################################################################

=item I<clk()>

method description goes here...
...remember: there must be a newline around each POD tag (e.g. =item, =cut etc)!

=cut

sub clk
{
   my $this = shift;
   my $clk = $this->_clk();
   if (@_)
   {
      $clk->set(@_);
      $clk->direction('output');
      $clk->parent($this);
   }
   return $clk;
}

################################################################################

=item I<_ns_timescale_multiplier()>

References the current timescale, and returns a multiplier to convert the base
period. 

Example: 
If the current timescale is "1ps", then it would return 1000. (1ns=1000ps).
If the current timescale is "1s", then it would return 0.000000001 (1ns=0.000000001s).

=cut

sub _ns_timescale_multiplier
{
  my $this = shift;
  my $timescale_directive =  shift || $this->project()->timescale();
  my ($base_delay, $timescale) = $this->split_timescale($timescale_directive);
  # print "timescale: $timescale <-> base_delay: $base_delay\n";

  my $base_multi;
  if ($timescale =~ /^s/)   { $base_multi = 0.000000001; }
  elsif($timescale =~ /^ms/){ $base_multi = 0.000001; }
  elsif($timescale =~ /^us/){ $base_multi = 0.001; }
  elsif($timescale =~ /^ns/){ $base_multi = 1; }
  elsif($timescale =~ /^ps/){ $base_multi = 1000; }
  elsif($timescale =~ /^fs/){ $base_multi = 1000000; }

  my $multiplier = $base_multi / $base_delay;
  return $multiplier;
}

################################################################################

=item I<split_timescale()>

Given a timescale, separates passed-in timescale into 2-element list of (base,
time unit).

=cut

sub split_timescale
{
  my $this = shift;
  my $timescale_directive = shift or &ribbit ("no timescale provided");
  $timescale_directive =~ /^\s*(\d+)\s*(s|ms|us|ns|ps|fs)\s*\/.*$/;
  return ($1, $2);
}

################################################################################

=item I<convert_ns_period_to_local_timescale_delay()>

Given a ns period (simple number), it converts it into a string based on the
current timescale. Needed by VHDL to specify in absolute terms how long a delay
is.

=cut

sub convert_ns_period_to_local_timescale_delay
{
  my $this = shift;
  my $ns_period = shift || $this->ns_period();
  my $timescale_directive = $this->project()->timescale();
  my ($base_delay, $timescale) = $this->split_timescale($timescale_directive);
  my $ns_conversion = $this->_ns_timescale_multiplier($timescale_directive);
  # base_delay is considered in _ns_timescale_multiplier, so we need to take it
  # back out of the equation.
  my $delay = $ns_period * $ns_conversion * $base_delay;
  return "$delay $timescale";
}

################################################################################

=item I<convert_ns_period_to_local_timescale_ticks()>

Returns a number representing the period according to the local timescale.
Verilog needs to express periods as units in terms things in terms of the local
timescale. 

You are NOT allowed to set the period with this method, because most
likely a project and parent are not associated with this e_clk_gen, so we
won't be able to fetch the current timescale, so we won't be able to
figure out the correct period<->ns_period calculations. 

=cut

sub convert_ns_period_to_local_timescale_ticks
{
  my $this = shift;
  my $ns_period = shift || $this->ns_period();
  my $timescale_directive = $this->project()->timescale();
  my $ns_conversion = $this->_ns_timescale_multiplier($timescale_directive);
  my $number = $ns_period * $ns_conversion;
  return $number;
}


################################################################################

=item I<to_verilog()>

method description goes here...
...remember: there must be a newline around each POD tag (e.g. =item, =cut etc)!

=cut

sub to_verilog
{
   my $this = shift;
   my $indent = shift;
   
   my $clk_name = $this->clk()->expression();
   # Verilog is easy.  It takes increments of whatever the timescale is.  
   my $ns_period = $this->ns_period();
   my $period = $this->convert_ns_period_to_local_timescale_ticks($ns_period);
   my $half_period = &ceil($period/2 - .5);

   my $vs =
"initial
  $clk_name = 1'b0;
always
  $__HASH_CHARACTER__$half_period $clk_name <= ~$clk_name;

";

  if ($half_period != int(($period/2) + .5)) {
    my $half_period_plus_one = int(($period/2) + .5);
#print "XXXXXXX ns: $period, half: $half_period, plus_one: $half_period_plus_one\n";
    $vs =
"initial
  $clk_name = 1'b0;
always
   if ($clk_name == 1'b1) 
  $__HASH_CHARACTER__$half_period $clk_name <= ~$clk_name;
   else 
  $__HASH_CHARACTER__$half_period_plus_one $clk_name <= ~$clk_name;

";
      
  } else {
#print "XXXXXXX ns: $period, half: $half_period, evenly divisible\n";
  }

# Please note the escape character (backslash hash \#).  
# The above has an escape character added to it so that the "comment-stripper" program
# won't trounce it.   Don't expect this message to make it into the final version.


   #indent it.
   $vs =~ s/^/$indent/mg;
   return ($vs);
}

################################################################################

=item I<to_vhdl()>

method description goes here...
...remember: there must be a newline around each POD tag (e.g. =item, =cut etc)!

=cut

sub to_vhdl
{
   my $this = shift;
   my $indent = shift;

   my $clk_name = $this->clk()->expression();
   my $ns = $this->ns_period();
   my $period = $this->convert_ns_period_to_local_timescale_ticks($ns);
   my $multiplier = $ns/$period;
   my $half_period = &ceil($period/2 - .5);
   my $half_ns = $half_period * $multiplier;

   # convert period to local timescale
   my $half_ns_str = 
      $this->convert_ns_period_to_local_timescale_delay($half_ns);

   my $vs = 
"process
begin
  $clk_name <= '0';
  loop
     wait for $half_ns_str;
     $clk_name <= not $clk_name;
  end loop;
end process;
";
  
  if ($half_period != int(($period/2) + .5)) {
    my $half_period_plus_one = int(($period/2) + .5);
    my $half_ns_plus_one = $half_period_plus_one * $multiplier;
    # convert period to local timescale
    my $half_ns_plus_one_str =
        $this->convert_ns_period_to_local_timescale_delay($half_ns_plus_one);
#print "XXXXXXX ns: $ns, half: $half_ns, plus_one: $half_ns_plus_one\n";
    $vs =
"process
begin
  $clk_name <= '0';
  loop
     if ($clk_name = '1') then
        wait for $half_ns_str;
        $clk_name <= not $clk_name;
     else
        wait for $half_ns_plus_one_str;
        $clk_name <= not $clk_name;
     end if;
  end loop;
end process;
";
  } else {
#print "XXXXXXX ns: $ns, half: $half_ns, evenly divisible\n";
  }

   #indent it.
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
