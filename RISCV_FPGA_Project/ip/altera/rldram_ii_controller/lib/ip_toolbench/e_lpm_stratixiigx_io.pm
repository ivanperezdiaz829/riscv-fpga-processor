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

package e_lpm_stratixiigx_io;
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
		component  stratixiigx_io 
		generic (
			 bus_hold : string := "false";
			 operation_mode : string := "input";
			 ddio_mode : string := "none";
			 open_drain_output : string := "false";
			 output_register_mode : string := "none";
			 output_async_reset : string := "none";
			 output_power_up : string := "low";
			 output_sync_reset : string := "none";
			 tie_off_output_clock_enable : string := "false";
			 oe_register_mode : string := "none";
			 oe_async_reset : string := "none";
			 oe_power_up : string := "low";
			 oe_sync_reset : string := "none";
			 tie_off_oe_clock_enable : string := "false";
			 input_register_mode : string := "none";
			 input_async_reset : string := "none";
			 input_power_up : string := "low";
			 input_sync_reset : string := "none";
			 extend_oe_disable : string := "false";
			 dqs_input_frequency : string := "unused";
			 dqs_out_mode : string := "none";
			 dqs_delay_buffer_mode : string := "none";
			 dqs_phase_shift : integer := 0;
			 inclk_input : string := "normal";
			 ddioinclk_input : string := "negated_inclk";
			 dqs_offsetctrl_enable : string := "false";
			 dqs_ctrl_latches_enable : string := "false";
			 dqs_edge_detect_enable : string := "false";
			 gated_dqs : string := "false";
			 sim_dqs_intrinsic_delay : integer := 0;
			 sim_dqs_delay_increment : integer := 0;
			 sim_dqs_offset_increment : integer := 0;
			 lpm_type : string := "stratixiigx_io"
			);
		port (
		      datain          : in std_logic := '0';
		      ddiodatain      : in std_logic := '0';
		      oe              : in std_logic := '1';
		      outclk          : in std_logic := '0';
		      outclkena       : in std_logic := '1';
		      inclk           : in std_logic := '0';
		      inclkena        : in std_logic := '1';
		      areset          : in std_logic := '0';
		      sreset          : in std_logic := '0';
		      ddioinclk       : in std_logic := '0';
		      delayctrlin     : in std_logic_vector(5 downto 0) := "000000";
		      offsetctrlin    : in std_logic_vector(5 downto 0) := "000000";
		      dqsupdateen     : in std_logic := '0';
		      linkin		  : in std_logic := '0';
		      terminationcontrol : in std_logic_vector(13 downto 0) := "00000000000000";      
		      padio           : inout std_logic;
		      combout         : out std_logic;
		      regout          : out std_logic;
		      ddioregout      : out std_logic;
		      dqsbusout	      : out std_logic;
		      linkout		  : out std_logic
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
   $this->port_map
   	({
		      combout         => "open",
		      regout          => "open",
		      ddioregout      => "open",
		      dqsbusout	      => "open",
		      linkout	      => "open",
		      padio	      => "open",
	});
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
