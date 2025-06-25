=head1 NAME

e_lpm_dcfifo - description of the module goes here ...

=head1 SYNOPSIS

The e_lpm_dcfifo class implements ... detailed description of functionality

=head1 METHODS

=over 4

=cut

package e_auk_qdrii_avalon_write_if;
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
		component auk_qdrii_avalon_write_if
		    GENERIC(
			gAVL_DATA_WIDTH_MULTIPLY : natural := 2 ;
			gBURST_MODE              : natural := 4 ;
			gMEMORY_DATA_WIDTH       : natural := 18;
			gMEMORY_BYTEEN_WIDTH     : natural := 8;
			gIS_BURST4_NARROW	 : natural := 0; 
			gMEMORY_ADDRESS_WIDTH    : natural := 20
		    );
		    PORT (
			avl_addr_wr			: IN std_logic_vector (gMEMORY_ADDRESS_WIDTH -1 + gIS_BURST4_NARROW downto 0);
			avl_data_wr			: IN std_logic_vector ((gMEMORY_DATA_WIDTH * gAVL_DATA_WIDTH_MULTIPLY) -1 downto 0);
			avl_wait_request_wr		: OUT std_logic;
			avl_chipselect_wr		: IN std_logic;
			avl_write			: IN std_logic;
			avl_byteen_wr			: IN std_logic_vector ((gMEMORY_BYTEEN_WIDTH * gAVL_DATA_WIDTH_MULTIPLY) - 1 downto 0);
			
			control_addr_comb_wr		: OUT std_logic_vector (gMEMORY_ADDRESS_WIDTH -1 downto 0);
			control_d			: OUT std_logic_vector ((gMEMORY_DATA_WIDTH * 2) -1 downto 0);
			control_wpsn			: OUT std_logic;
			control_wpsn_comb		: OUT std_logic;
			control_bwsn			: OUT std_logic_vector ((gMEMORY_BYTEEN_WIDTH * 2) -1 downto 0);
			control_training_finished	: IN std_logic;
			
			avl_clock			: IN std_logic;
			avl_resetn			: IN std_logic
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
   #$this->port_map({});
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
