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


























package nios2_custom_insts;

use cpu_utils;
use strict;










sub
has_insts
{
    my $custom_instructions = shift;

    return (scalar(keys(%$custom_instructions)) > 0);
}


sub
has_combo_insts
{
    my $custom_instructions = shift;

    my @combo_ci_names = @{get_combo_ci_names($custom_instructions)};

    return (scalar(@combo_ci_names) > 0);
}


sub
has_multi_insts
{
    my $custom_instructions = shift;

    my @multi_ci_names = @{get_multi_ci_names($custom_instructions)};

    return (scalar(@multi_ci_names) > 0);
}


sub
get_ci_names
{
    my $custom_instructions = shift;

    my @ci_names = sort(keys(%$custom_instructions));

    return \@ci_names;
}


sub
get_combo_ci_names
{
    my $custom_instructions = shift;

    my @ci_names;

    foreach my $ci_name (sort(keys(%$custom_instructions))) {
        my $custom_instruction = $custom_instructions->{$ci_name};
        if ($custom_instruction->{type} eq "combo") {
            push(@ci_names, $ci_name);
        }
    }

    return \@ci_names;
}


sub
get_multi_ci_names
{
    my $custom_instructions = shift;

    my @ci_names;

    foreach my $ci_name (sort(keys(%$custom_instructions))) {
        my $custom_instruction = $custom_instructions->{$ci_name};
        if ($custom_instruction->{type} eq "multi") {
            push(@ci_names, $ci_name);
        }
    }

    return \@ci_names;
}



sub
get_n_decode_expr
{
    my $custom_instructions = shift;
    my $ci_name = shift;
    my $n_field_signal_name = shift;

    my $master_n_field_decode_sz = 
      get_master_n_field_decode_sz($custom_instructions);

    if ($master_n_field_decode_sz == 0) {

        return "1'b1";
    } else {

        my $custom_instruction = manditory_hash($custom_instructions, $ci_name);
        my $addr_base = manditory_int($custom_instruction, "addr_base");
        my $addr_width = manditory_int($custom_instruction, "addr_width");
        my $msb = $master_n_field_decode_sz - 1;
        my $lsb = $addr_width;

        if ($msb < $lsb) {
            &$error("msb of '$msb' is less than lsb of '$lsb' for custom" .
              " instruction '$ci_name' (addr_base='$addr_base'," .
              " addr_width='$addr_width'," .
              " master_n_field_decode_sz='$master_n_field_decode_sz'");
        }

        my $padded_zeroes = ($lsb == 0) ? "" : (" , " . $lsb. "\'b0");

        return
          "({$n_field_signal_name\[$msb:$lsb\]" . $padded_zeroes .  "} == " .
          "${master_n_field_decode_sz}\'h" . sprintf("%x", $addr_base) . ")";
    }
}







sub
get_master_n_field_decode_sz
{
    my $custom_instructions = shift;

    my @custom_inst_keys = keys(%$custom_instructions);

    if (scalar(@custom_inst_keys) == 1) {
        return 0;
    }

    my $max_addr_top;
    foreach my $ci_name (@custom_inst_keys) {
        my $custom_instruction = manditory_hash($custom_instructions, $ci_name);
        my $addr_base = manditory_int($custom_instruction, "addr_base");
        my $addr_width = manditory_int($custom_instruction, "addr_width");

        my $addr_top = $addr_base + (0x1 << $addr_width) - 1;

        if (!defined($max_addr_top) || ($addr_top > $max_addr_top)) {
            $max_addr_top = $addr_top;
        }
    }


    return num2sz($max_addr_top);
}

1;

