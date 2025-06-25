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


























package nios_addr_utils;
use Exporter;
@ISA = Exporter;
@EXPORT = qw(
    &make_master_address_decoder
    &make_address_range_detector
);

use europa_all;
use europa_utils;
use cpu_utils;
use strict;























sub 
make_master_address_decoder
{
    my $args = shift;       # Hash reference to all arguments

    my $avalon_master_info = manditory_hash($args, "avalon_master_info");
    my $normal_master_name = optional_scalar($args, "normal_master_name");
    my $tightly_coupled_master_names = 
      optional_array($args, "tightly_coupled_master_names");
    my $addr_signal = not_empty_scalar($args, "addr_signal");
    my $addr_sz = manditory_int($args, "addr_sz");
    my $sel_prefix = not_empty_scalar($args, "sel_prefix");
    my $mmu_present = manditory_bool($args, "mmu_present");
    my $master_paddr_mapper_func = 
      manditory_code($args, "master_paddr_mapper_func");



    my $master_names = [];
    push(@$master_names, @$tightly_coupled_master_names);
    if ($normal_master_name ne "") {
        push(@$master_names, $normal_master_name);
    }

    my $num_masters = scalar(@$master_names);

    my $full_range_decode_required;









    if (
      $mmu_present || 
      check_for_master_overlap($avalon_master_info, $master_names, 1)) {

        $full_range_decode_required = 1;

        if (!$mmu_present) {
            &$progress("  Generating non-optimal tightly-coupled master logic due to overlap");
        }


        if (check_for_master_overlap($avalon_master_info, 
          $tightly_coupled_master_names, 1)) {
            &$error("Change your slave address mappings to remove overlap between tightly-coupled slaves and regenerate");
        }
    } else {

        $full_range_decode_required = 0;


        my @sorted_master_names;
        @sorted_master_names = 
          sort { 
            manditory_int(manditory_hash($avalon_master_info, $b),
              "Paddr_Base") 
            <=> 
            manditory_int(manditory_hash($avalon_master_info, $a),
              "Paddr_Base")
          } 
          @$master_names;

        $master_names = \@sorted_master_names;
    }


    my @sel_signals;
    my @mux_table;

    for (my $index = 0; $index < $num_masters; $index++) {
        my $master_name = $master_names->[$index];
        my $master = manditory_hash($avalon_master_info, $master_name);
        my $sel_name = $sel_prefix . $master_name;
        my $mask_bin = sprintf($num_masters . "'b%0" . $num_masters . "b", 
          (0x1 << ($num_masters - 1 - $index)));

        e_signal->adds({name => $sel_name, never_export => 1, width => 1 });
        push(@sel_signals, $sel_name);

        if ($index == ($num_masters - 1)) {






            push(@mux_table, "1'b1" => $mask_bin);
        } else {
            my $base = &$master_paddr_mapper_func($master, "Paddr_Base");
            my $base_hex = sprintf($addr_sz . "'h%x", $base);

            if ($full_range_decode_required) {




                my $top = &$master_paddr_mapper_func($master, "Paddr_Top");
                my $top_hex = sprintf($addr_sz . "'h%x", $top);
                push(@mux_table,
                  "(($addr_signal >= $base_hex) && ($addr_signal <= $top_hex))"
                    => $mask_bin);
            } else {

                push(@mux_table, "$addr_signal >= $base_hex" => $mask_bin);
            }
        }
    }

    if ($num_masters > 1) {

        my $lhs = "{" . join(',', @sel_signals) . "}";
        e_mux->add({ lhs => $lhs, type => "priority", table => \@mux_table });
    } else {

        e_assign->add([$sel_signals[0], "1'b1"]);
    }

    return @sel_signals;
}











sub 
make_address_range_detector
{
    my $args = shift;       # Hash reference to all arguments

    my $slave_infos = manditory_hash($args, "slave_infos");
    my $addr_signal = not_empty_scalar($args, "addr_signal");
    my $addr_sz = manditory_int($args, "addr_sz");
    my $match_signal = not_empty_scalar($args, "match_signal");
    my $just_readonly = optional_bool($args, "just_readonly");

    my $hex_fmt = $addr_sz . "'h%x";


    my $sel_prefix = $addr_signal . "_sel_slave_";

    if ($just_readonly) {
        $sel_prefix .= "readonly_";
    }


    my @sel_signals;

    foreach my $slave_desc (sort(keys(%$slave_infos))) {
        my $avalon_slave = $slave_infos->{$slave_desc};
        my $slave_base_hex = sprintf($hex_fmt, $avalon_slave->{base});
        my $slave_end_hex = sprintf($hex_fmt, $avalon_slave->{end});
        my $slave_readonly = $avalon_slave->{readonly};

        if (($just_readonly == $slave_readonly) || !$just_readonly) {
            my $slave_unique_name = $slave_desc;
            $slave_unique_name =~ s!/!_!g;     # Replace / with _

            my $sel_name = $sel_prefix . $slave_unique_name;
            push(@sel_signals, $sel_name);


            e_signal->adds({name => $sel_name, never_export => 1, width => 1 });
            e_assign->add(
              [$sel_name, 
               "(($addr_signal >= $slave_base_hex) && 
                 ($addr_signal <= $slave_end_hex))"]
            );
        }
    }

    e_signal->adds({name => $match_signal, never_export => 1, width => 1 });

    if (scalar(@sel_signals) > 0) {

        e_assign->add([$match_signal, join('|', @sel_signals)]);
    } else {

        e_assign->add([$match_signal, "1'b0"]);
    }
}







sub
check_for_master_overlap
{
    my ($avalon_master_info, $master_names, $display) = @_;

    my $overlap = 0;

    foreach my $m1_name (@$master_names) {
        my $m1 = manditory_hash($avalon_master_info, $m1_name);

        my $m1_top = manditory_int($m1, "Paddr_Top");
        my $m1_base = manditory_int($m1, "Paddr_Base");

        foreach my $m2_name (@$master_names) {
            if ($m1_name eq $m2_name) { next; }

            my $m2 = manditory_hash($avalon_master_info, $m2_name);
            my $m2_top = manditory_int($m2, "Paddr_Top");
            my $m2_base = manditory_int($m2, "Paddr_Base");

            my $no_overlap = ($m1_top < $m2_base) || ($m1_base > $m2_top);

            if (!$no_overlap) {
                if ($display) {
                    my $msg = sprintf("  Master %s address range (0x%x, 0x%x)" .
                      " overlaps with master %s address range (0x%x, 0x%x)",
                      $m1_name, 
                      $m1_base,
                      $m1_top,
                      $m2_name, 
                      $m2_base,
                      $m2_top);
                    &$progress($msg);
                }
                $overlap = 1;
            }
        }
    }

    return $overlap;
}

1;

