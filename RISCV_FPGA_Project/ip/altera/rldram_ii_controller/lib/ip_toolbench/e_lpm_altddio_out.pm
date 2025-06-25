# For all those of you out there who bag on europa and its "Winchester
# Mystery House Architecture" I present the Smith and Wesson solution.

# e_lpm_base: A new class which helps insert lpm_instances into your
# europa code.  Don't muck around in here.  The only reason why I bring
# it up is so that you can set @ISA = qw (e_lpm_base) in your coolio new
# europa class.

# e_lpm_dcfifo: An example class which uses e_lpm_base.  Check it out.

# e_lpm_base parses the vhdl component declaration (Which I copied
# directly from Quartus LPM Megafunction Documentation) and uses its
# info to figure out width_matches based upon parameter map
# declarations. E.g. In the dcfifo example, e_lpm_base notes that both d
# and q are of width (LPM_WIDTH).  When somebody later on defines a
# signal q of width 24, e_lpm_width automatically propogates the width
# to the "d" pin (unless d has also been defined.  See: standard europa
# signal matching.  e_lpm_base is also smart enough to set the component
# LPM_WIDTH value before outputing as HDL.

# Another cool advantage here is that different tools sometime have
# different ideas about which default settings are actually the default
# settings.  By copying the component directly, europa directly
# specifies ALL component settings.  The tools no longer have any say
# about defaults since europa specifies them directly.


=head1 NAME

e_lpm_dcfifo - description of the module goes here ...

=head1 SYNOPSIS

The e_lpm_dcfifo class implements ... detailed description of functionality

=head1 METHODS

=over 4

=cut

package e_lpm_altddio_out;
use e_lpm_base;
@ISA = ("e_lpm_base");

use strict;
use europa_utils;

#You must declare your vhdl component declaration for this class to
#work
################################################################################

=item I<vhdl_declare_component()>

method description goes here...
...remember: there must be a newline around each POD tag (e.g. =item, =cut etc)!

=cut

sub vhdl_declare_component
{
	return q[
		component altddio_out
		 generic (
			width                  : positive;  
			power_up_high          : string := "OFF";
			oe_reg                 : string := "UNUSED";
			extend_oe_disable      : string := "UNUSED";
			invert_output          : string := "OFF";
			intended_device_family : string := "MERCURY";
			lpm_hint               : string := "UNUSED";
			lpm_type               : string := "altddio_out" 
		);
		 port (
			datain_h   : in std_logic_vector(width-1 downto 0);
			datain_l   : in std_logic_vector(width-1 downto 0);
			outclock   : in std_logic;
			outclocken : in std_logic := '1';
			aset       : in std_logic := '0';
			aclr       : in std_logic := '0';
			oe         : in std_logic := '1';
			dataout    : out std_logic_vector(width-1 downto 0) 
		 );
		end component;
		];
}

################################################################################

=item I<set_port_map_defaults()>

method description goes here...
...remember: there must be a newline around each POD tag (e.g. =item, =cut etc)!

=cut

sub set_port_map_defaults
{
   # redefine the default port map here if you wish
   # set things you don't want popping out to "open"
   my $this = shift;
   $this->port_map({dataout => "open",});
}

################################################################################

=item I<set_parameter_map_defaults()>

method description goes here...
...remember: there must be a newline around each POD tag (e.g. =item, =cut etc)!

=cut

sub set_parameter_map_defaults
{
   # redefine the default parameter map here if you wish
   my $this = shift;
   #$this->parameter_map({});
}

################################################################################

=item I<set_autoparameters()>

method description goes here...
...remember: there must be a newline around each POD tag (e.g. =item, =cut etc)!

=cut

sub set_autoparameters
{
   my $this = shift;
   my $return = $this->SUPER::set_autoparameters(@_);
# 
   # my $device = $this->parent_module()->project()->device_family();
   # my $Device = $device;
   # $Device =~ s/^(\w)(.*)$/$1.lc($2)/e;
   # $this->parameter_map({intended_device_family => $Device});
   return $return;
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

The inherited class e_lpm_base

=begin html

<A HREF="e_lpm_base.html">e_lpm_base</A> webpage

=end html

=head1 COPYRIGHT

Copyright (C)2001-2005 Altera Corporation, All rights reserved.

=cut

1;
