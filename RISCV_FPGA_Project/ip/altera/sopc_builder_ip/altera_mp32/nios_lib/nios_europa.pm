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



























package nios_europa;
use Exporter;
@ISA = Exporter;
@EXPORT = qw(
    &nios_europa_assignment
    &nios_europa_register
    &nios_europa_binary_mux
    &nios_europa_sim_wave_text
);

use cpu_utils;
use europa_all;
use strict;










sub
nios_europa_assignment
{
    my $args = shift;
    my $whoami = "nios_europa_assignment";

    validate_hash_keys("args", $args, 
      ["lhs", "rhs", "sz", "never_export", "simulation"]);

    my $lhs = not_empty_scalar($args, "lhs");
    my $rhs = manditory($args, "rhs");
    my $sz = manditory_int($args, "sz");
    my $never_export = optional_bool($args, "never_export");
    my $simulation = optional_bool($args, "simulation");

    if ($sz < 1) { &$error("$whoami: sz less than 1"); }


    my $rhs_empty = ($rhs eq "") || ($rhs =~ /^\s*$/);
    if ($rhs_empty) {
        $rhs = "${sz}'b0";
    }

    my @signal = ($lhs, $sz);
    if ($never_export) {
        push(@signal, 0, $force_never_export);
    }

    my $props = {};
    $props->{lhs} = \@signal;
    $props->{rhs} = $rhs;
    if ($simulation) {
        $props->{tag} = "simulation";
    }

    e_assign->add($props);
}


sub
nios_europa_register
{
    my $args = shift;
    my $whoami = "nios_europa_register";

    validate_hash_keys("args", $args, 
      ["lhs", "rhs", "sz", "en", "reset_value", "never_export", "simulation"]);

    my $lhs = not_empty_scalar($args, "lhs");
    my $rhs = not_empty_scalar($args, "rhs");
    my $sz = manditory_int($args, "sz");
    my $en = not_empty_scalar($args, "en");
    my $reset_value = optional_scalar($args, "reset_value");
    my $never_export = optional_bool($args, "never_export");
    my $simulation = optional_bool($args, "simulation");

    assert_scalar("lhs", $lhs);
    assert_scalar("rhs", $rhs);
    if ($sz < 1) { &$error("$whoami: sz less than 1"); }

    my @signal = ($lhs, $sz);
    if ($never_export) {
        push(@signal, 0, $force_never_export);
    }

    if (!defined($reset_value)) {
        $reset_value = "0";
    }

    my $props = {};
    $props->{out} = \@signal;
    $props->{in} = $rhs;
    $props->{enable} = $en;
    $props->{async_value} = $reset_value;
    if ($simulation) {
        $props->{tag} = "simulation";
    }

    e_register->add($props);
}


sub
nios_europa_binary_mux
{
    my $args = shift;
    my $whoami = "nios_europa_binary_mux";

    my $lhs = manditory($args, "lhs");
    my $sel = manditory($args, "sel");
    my $sz = manditory_int($args, "sz");
    my $table = manditory_array($args, "table");
    my $default = optional_scalar($args, "default");
    my $never_export = optional_bool($args, "never_export");
    my $simulation = optional_bool($args, "simulation");

    validate_hash_keys("args", $args, 
      ["lhs", "sel", "sz", "table", "default", "never_export", "simulation"]);

    assert_scalar("lhs", $lhs);
    if ($sz < 1) { &$error("$whoami: sz less than 1"); }
    my $msb = $sz - 1;

    my $num_table_entries = scalar(@$table);
    if ($num_table_entries < 2) { &$error("$whoami: table too small"); }
    if ($num_table_entries & 0x1) { &$error("$whoami: table has odd num"); }

    my $props = {};

    my @signal = ($lhs, $sz);
    if ($never_export) {
        push(@signal, 0, $force_never_export);
    }

    $props->{lhs} = \@signal;
    $props->{selecto} = $sel;
    $props->{table} = $table;
    if (defined($default)) {
        $props->{default} = $default;
    }
    if ($simulation) {
        $props->{tag} = "simulation";
    }

    e_mux->add($props);
}







sub
nios_europa_sim_wave_text
{
    my $args = shift;
    my $whoami = "nios_europa_sim_wave_text";

    my $lhs = not_empty_scalar($args, "lhs");
    my $sz = manditory_int($args, "sz");
    my $table = manditory_array($args, "table");
    my $default_name = not_empty_scalar($args, "default_name");
    my $never_export = optional_bool($args, "never_export");

    validate_hash_keys("args", $args, 
      ["lhs", "sz", "table", "default_name", "never_export"]);

    assert_scalar("lhs", $lhs);
    if ($sz < 1) { &$error("$whoami: sz less than 1"); }


    my $max_len = 0;
    foreach my $entry (@$table) {
        if (!defined($entry->{name})) {
            return &$error("$whoami: Missing 'name' key in table");
        }

        if (length($entry->{name}) > $max_len) {
            $max_len = length($entry->{name});
        }
    }

    if ($max_len == 0) {
        return &$error("$whoami: maximum name length is 0");
    }


    my @e_sim_wave_text_table;

    foreach my $entry (@$table) {
        if (!defined($entry->{decode_expr})) {
            return &$error("$whoami: Missing 'decode_expr' key in table");
        }



        push(@e_sim_wave_text_table,
          $entry->{decode_expr},
          strpad($entry->{name}, $max_len, ' '));
    }

    e_signal->new({
      name => $lhs,
      width => $sz,
      never_export => $never_export,
    });

    e_sim_wave_text->add({
      out     => $lhs,
      table   => \@e_sim_wave_text_table,
      default => strpad("BAD", $max_len, ' '),
    });
}







sub 
strpad 
{
    my $string = shift;
    my $length = shift;
    my $padder = shift;


    if ($padder eq "") {$padder = " ";}

    while ($length > length($string)) {
        $string = $padder.$string;
    }
    return ($string);
}

1;

