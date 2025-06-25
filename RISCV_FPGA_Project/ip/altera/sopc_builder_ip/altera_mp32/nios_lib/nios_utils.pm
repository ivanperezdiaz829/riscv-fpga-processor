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


























package nios_utils;
use Exporter;
@ISA = Exporter;
@EXPORT = qw(
    &create_x_filter
);

use europa_all;
use europa_utils;
use cpu_utils;
use strict;











sub 
create_x_filter
{
    my $args = shift;   # Reference to all arguments

    validate_hash_keys("args", $args, 
      ["lhs", "rhs", "sz", "qual_expr"]);

    my $lhs = not_empty_scalar($args, "lhs");
    my $rhs = not_empty_scalar($args, "rhs");
    my $sz = manditory_int($args, "sz");
    my $qual_expr = optional_scalar($args, "qual_expr");
    

    e_assign->adds({
      comment => "Never clear 'X' data bits for synthesis",
      lhs => $lhs,
      rhs => $rhs,
      tag => 'synthesis',
    });

    my $scalar = ($sz == 1);


    for my $bit_position (0 .. ($sz-1)) {
        my $comment;

        if ($bit_position == 0) {

            $comment = "Clearing 'X' data bits"
        }

        my $bit = $scalar ? 
          "$lhs" : 
          "$lhs\[$bit_position\]";
        my $unfiltered_bit = $scalar ? 
          "$rhs" : 
          "$rhs\[$bit_position\]";
        my $bit_is_x = $scalar ? 
          "$rhs\_is_x" : 
          "$rhs\_$bit_position\_is_x";

        e_signal->adds([$bit_is_x, 1]);

        e_assign_is_x->adds({
            comment => $comment,
            lhs => $bit_is_x,
            rhs => $unfiltered_bit,
            tag => 'simulation',
        });

        my $condition = $qual_expr ? 
          ("(" . $bit_is_x . " & (" . $qual_expr . "))") : 
          $bit_is_x;

        e_assign->adds({
            lhs => $bit,
            rhs => "$condition ? 1'b0 : $unfiltered_bit",
            tag => 'simulation',
        });
    }
}





1;

