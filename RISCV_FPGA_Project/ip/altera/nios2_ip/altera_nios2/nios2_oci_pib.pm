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






















use cpu_utils;
use europa_all;
use strict;











sub make_nios2_oci_pib
{
  my $Opt = shift;

  my $module = e_module->new ({
      name    => $Opt->{name}."_nios2_oci_pib",
  });



  $module->add_contents (

    e_signal->news (
      ["tr_clk",          1,                    1],
      ["tr_data",         $Opt->{oci_tr_width}, 1],
    ),

    e_signal->news (
      ["tw",              $Opt->{oci_tm_width}, 0],
    ),

  );





  $module->add_contents (

    e_signal->news (
      ["tr_data_reg",     $Opt->{oci_tr_width}, 0, 1],
    ),
  );























  $module->add_contents (
    e_assign->new ( ["phase" => "x1^x2"] ),
    e_process->new ({
      clock     => "clk",
      reset     => "jrst_n",
      user_attributes_names => ["x1"],
      user_attributes => [
        {
          attribute_name => 'SUPPRESS_DA_RULE_INTERNAL',
          attribute_operator => '=',
          attribute_values => [qw(R101)],
        },
      ],
      asynchronous_contents => [
        e_assign->new ( ["x1" => "0"],),
      ],
      contents => [
        e_assign->new ( ["x1" => "~x1"],),
      ],
    }),
    e_process->new ({
      clock     => "clkx2",
      reset     => "jrst_n",
      user_attributes_names => ["x2","tr_clk_reg", "tr_data_reg"],
      user_attributes => [
        {
          attribute_name => 'SUPPRESS_DA_RULE_INTERNAL',
          attribute_operator => '=',
          attribute_values => [qw(R101)],
        },
      ],
      asynchronous_contents => [
        e_assign->news (
          ["x2" => "0"],
          ["tr_clk_reg" => "0"],
          ["tr_data_reg" => "0"],
        ),
      ],
      contents => [
        e_assign->news (
          ["x2" => "x1"],
          ["tr_clk_reg" => "~phase"],
          ["tr_data_reg" => "phase ? ".
              "  tw[".$Opt->{oci_tr_width}."-1:0] : ".
              "  tw[".$Opt->{oci_tm_width}."-1 : ".$Opt->{oci_tr_width}."]"],
        ),
      ],
    }),
    e_assign->news (
      ["tr_clk" => $Opt->{oci_offchip_trace}." ? tr_clk_reg : 0"],
      ["tr_data" => $Opt->{oci_offchip_trace}." ? tr_data_reg : 0"],
    ),

  );

  return $module;
}



1;

