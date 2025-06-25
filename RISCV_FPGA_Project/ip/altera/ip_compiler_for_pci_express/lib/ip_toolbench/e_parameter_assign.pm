


################################################################
# CLASS: e_parameter_assign
#
################################################################

=head1 NAME

e_parameter_assign - description of the module goes here ...

=head1 SYNOPSIS

Sub-class of e_assign.

Allows parameters to be assigned to real signals.

lhs: an expression just like assign.
rhs: a string which maps to parameter name.
vhdl_conversion: a string which converts rhs type to 
  lhs std_logic or std_logic_vector.

=head1 METHODS

=over 4

=cut

package e_parameter_assign;
use europa_utils;
use e_expression;
use e_lcell;
use e_if;
use e_thing_that_can_go_in_a_module;
use e_assign;
@ISA = ("e_assign");

use strict;

my %fields = (
              _rhs_parameter     => '',
              _vhdl_conversion   => '',
              );

my %pointers = ();

&package_setup_fields_and_pointers
    (__PACKAGE__,
     \%fields, 
     \%pointers,
     );


=item I<rhs()>

rhs takes in a string input which is used for a parameter declaration.

=cut

sub rhs
{
   my $this = shift;
   my $rhs = $this->_rhs_parameter(@_);
   return $rhs;
}

=item I<vhdl_conversion()>

The proper function to call for converting parameter declaration into
    an assignment.  If set to "X", result in vhdl will be

    lhs <= X($this->rhs());  

    If null, result in vhdl (and verilog) will be

    lhs <= ($this->rhs());

=cut

sub vhdl_conversion
{
   my $this = shift;
   return $this->_vhdl_conversion(@_);
}

=item I<to_verilog()>

=cut

sub to_verilog
{
  my $this   = shift;
  my $indent = shift;

  $this->_make_expressions_decent();
  my $lhs = $this->lhs()->to_verilog();
  my $rhs = $this->rhs();

  # now determine if lhs was defined within a process in which case its
  # a register, otherwise its an assignment
  my $preamble;
  my $assignment;
  if ($this->is_in_process())
  {
     $preamble   = "";
     $assignment = " \<\= ";
  }
  else
  {
     $preamble   = "assign ";
     $assignment = " \= ";
  }

  if ($this->sim_delay()) {
     $preamble   .= "#".$this->sim_delay()." ";
  }

  my $lhs_stuff = "";
  
  # If there's a comment, convert it to verilog and prepend it to the 
  # left-hand-side term.
  if ($this->comment() ne "")
  {
    $lhs_stuff = $this->string_to_verilog_comment($indent, $this->comment());
  }

  $lhs_stuff .= $indent.$preamble.$lhs.$assignment;
  
  my $subsequent_indent = $indent.$indent;#" " x length($lhs_stuff);
  my $new_line = "";
  $new_line = "\n"
      if (($rhs =~ s/\n\s*/\n$subsequent_indent/g) ||
          $this->comment());

  my $return_string = $lhs_stuff.$rhs.";\n$new_line";

  if (@{$this->cascade()})
  {     
     my $pm = $this->parent_module();
     my $wsa = $pm->project()->spaceless_system_ptf()->
     {WIZARD_SCRIPT_ARGUMENTS};
     my $device_family = $wsa->{device_family};
     if (($device_family =~ /apex/i) &&
         !$this->no_lcell())
     {
        $this->_make_lcell_module("verilog",$indent);
        $pm->simulation_strings($return_string);
        return;
     }
     else
     {
        $pm->normal_strings($return_string);
     }
  }
  else
  {
     return ($return_string);
  }
}

sub _make_expressions_decent
{
    return;
}

################################################################################

=item I<to_vhdl()>

method description goes here...
...remember: there must be a newline around each POD tag (e.g. =item, =cut etc)!

=cut

sub to_vhdl
{
  my $this  = shift;

  my $indent = shift;

  my $lhs = $this->lhs()->to_vhdl();
  my $rhs = $this->rhs();
  $rhs->de_ambigiousize(1)
    if ($lhs =~ /\,/);

  my $rhs_vhdl = $this->vhdl_conversion().'('.$this->rhs().')';

  my $assignment = ' <= '; 

  my $lhs_stuff = "";
  $lhs_stuff = $this->string_to_vhdl_comment($indent, $this->comment())
      if (defined($this->comment()) and $this->comment());

  my $delay_vhdl = "";
  if ($this->sim_delay()) {
     my $timescale_directive = $this->parent_module()->project()->timescale();
     # expected format is 'resolution / accuracy', i.e. '1ns / 100ps'
     $timescale_directive =~ /^\s*(10{0,2})\s*(s|ms|us|ns|ps|fs)\s*\/.*$/;
     my $base_delay = $1;
     my $timescale= $2;
     my $delay = $base_delay * $this->sim_delay();
     $delay_vhdl = " after ".$delay." ".$timescale." ";
     $assignment .= ' transport '; 
  }

  $lhs_stuff .= $indent.$lhs.$assignment;
  my $subsequent_indent = " " x length($lhs_stuff);

  my $new_line;
  $new_line = "\n"
      if ($rhs_vhdl =~ s/\n\s*/\n$subsequent_indent/g);

  my $return_string = $lhs_stuff.$rhs_vhdl.$delay_vhdl.";\n$new_line";
  if (@{$this->cascade()})
  {     
     my $pm = $this->parent_module();
     my $wsa = $pm->project()->spaceless_system_ptf()->
     {WIZARD_SCRIPT_ARGUMENTS};
     if (($wsa->{device_family} =~ /apex/i) &&
         !$this->no_lcell)
     {
        $this->_make_lcell_module("vhdl",$indent);
        $pm->simulation_strings($return_string);
        return;
     }
     else
     {
        $pm->normal_strings($return_string);
     }
  }
  else
  {
     return ($return_string);
  }
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

The inherited class e_thing_that_can_go_in_a_module

=begin html

<A HREF="e_thing_that_can_go_in_a_module.html">e_thing_that_can_go_in_a_module</A> webpage

=end html

=head1 COPYRIGHT

Copyright (C)2001-2005 Altera Corporation, All rights reserved.

=cut

1;
