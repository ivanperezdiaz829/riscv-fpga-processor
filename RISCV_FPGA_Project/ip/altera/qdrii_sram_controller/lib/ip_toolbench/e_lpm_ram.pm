=head1 NAME

e_lpm_dcfifo - description of the module goes here ...

=head1 SYNOPSIS

The e_lpm_dcfifo class implements ... detailed description of functionality

=head1 METHODS

=over 4

=cut

package e_lpm_ram;
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
			COMPONENT altsyncram
			GENERIC (
				intended_device_family			: STRING;
				operation_mode				: STRING;
				width_a					: NATURAL;
				widthad_a				: NATURAL;
				numwords_a				: NATURAL;
				width_b					: NATURAL;
				widthad_b				: NATURAL;
				numwords_b				: NATURAL;
				lpm_type				: STRING;
				width_byteena_a				: NATURAL;
				outdata_reg_b				: STRING;
				address_reg_b				: STRING;
				outdata_aclr_b				: STRING;
				read_during_write_mode_mixed_ports	: STRING;
				power_up_uninitialized			: STRING
			);
			PORT (
			        clocken0  : in std_logic ;
                    clocken1  : in std_logic ;

					wren_a			: IN STD_LOGIC ;
					clock0			: IN STD_LOGIC ;
					clock1			: IN STD_LOGIC ;
					address_a		: IN STD_LOGIC_VECTOR (widthad_a - 1 DOWNTO 0);
					address_b		: IN STD_LOGIC_VECTOR (widthad_b - 1 DOWNTO 0);
					q_b			: OUT STD_LOGIC_VECTOR (width_b - 1 DOWNTO 0);
					data_a			: IN STD_LOGIC_VECTOR (width_a - 1 DOWNTO 0)
			);
			END COMPONENT;
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
   # $this->port_map
   # ({
	# byteena_a	=> (others => 'Z'),
	# byteena_b	=> (others => 'Z'),
   # });
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
   #$this->parameter_map({"gREG_DIMM" => "false"});
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
