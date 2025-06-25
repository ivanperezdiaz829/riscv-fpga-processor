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

nios_altmult_add - e_lpm_base based object.  Used for implementing alt_multadd

=head1 SYNOPSIS

The nios_altmult_add class implements ... detailed description of functionality

=head1 METHODS

=over 4

=cut

package nios_altmult_add;
use e_lpm_base;
@ISA = ("e_lpm_base");

use strict;
use europa_utils;





=item I<vhdl_declare_component()>

Specifies the EXACT string you want to see in your vhdl component declaration

=cut

sub vhdl_declare_component
{
return q[
component altera_mult_add
GENERIC (
        addnsub_multiplier_pipeline_aclr1 : STRING;
        addnsub_multiplier_pipeline_register1 : STRING;
        addnsub_multiplier_register1 : STRING;
        dedicated_multiplier_circuitry : STRING;
        input_register_a0 : STRING;
        input_register_b0 : STRING;
        input_source_a0 : STRING;
        input_source_b0 : STRING;
        selected_device_family : STRING;
        lpm_type : STRING;
        multiplier1_direction : STRING;
        multiplier_aclr0 : STRING;
        multiplier_register0 : STRING;
        number_of_multipliers : NATURAL;
        output_register : STRING;
        port_addnsub1 : STRING;
        port_addnsub3 : STRING;
        port_signa : STRING;
        port_signb : STRING;
        representation_a : STRING;
        representation_b : STRING;
        signed_pipeline_aclr_a : STRING;
        signed_pipeline_aclr_b : STRING;
        signed_pipeline_register_a : STRING;
        signed_pipeline_register_b : STRING;
        signed_register_a : STRING;
        signed_register_b : STRING;
        width_a : NATURAL;
        width_b : NATURAL;
        width_result : NATURAL
      );
    PORT (
        clock0 : IN STD_LOGIC;
        result : OUT STD_LOGIC_VECTOR (width_result-1 DOWNTO 0);
        ena0   : IN STD_LOGIC;
        dataa : IN STD_LOGIC_VECTOR (width_a-1 DOWNTO 0);
        datab : IN STD_LOGIC_VECTOR (width_b-1 DOWNTO 0);
        aclr0 : IN STD_LOGIC
      );
  end component altera_mult_add;
         ];
}



=item I<set_port_map_defaults()>

method description goes here...
...remember: there must be a newline around each POD tag (e.g. =item, =cut etc)!

=cut

sub set_port_map_defaults
{


   my $this = shift;
   $this->port_map({
      clock0 => 'clk',
      ena0   => "1'b1",
   });

}



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

__PACKAGE__->DONE();
