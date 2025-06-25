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






















package cpu_assignment;

use cpu_utils;
use Exporter;
@ISA = Exporter;
@EXPORT = qw(
    &create_assignment
    &validate_assignment
    &get_assignment_lhs
    &get_assignment_rhs
    &get_assignment_sz
    &get_assignment_never_export
    &get_assignment_simulation
);
use strict;

























sub
create_assignment
{
    my $props = shift;          # Hash reference with arguments

    my $lhs = not_empty_scalar($props, "lhs");
    if (!defined($lhs)) {
        return undef;
    }
    my $rhs = not_empty_scalar($props, "rhs");
    if (!defined($rhs)) {
        return undef;
    }
    my $sz = manditory_int($props, "sz");
    if (!defined($sz)) {
        return undef;
    }
    my $never_export = optional_bool($props, "never_export");
    my $simulation = optional_bool($props, "simulation");


    my $assignment = {
        type            => "assignment",
        lhs             => $lhs,
        rhs             => $rhs,
        sz              => $sz,
        never_export    => $never_export,
        simulation      => $simulation,
    };

    return $assignment;
}




sub
validate_assignment
{
    my $assignment = shift;

    if (!defined($assignment)) {
        return &$error("Assignment reference is undefined");
    }

    if ($assignment == 0) {
        return &$error("Assignment reference is 0");
    }

    my $ref_type = ref($assignment);
    if ($ref_type ne "HASH") {
        return &$error("Assignment reference is to a $ref_type" .
          " but must be to a HASH");
    }

    my $type = $assignment->{type};

    if (!defined($type)) {
        return &$error("Assignment hash reference has" .
          " no \"type\" member");
    }

    if ($type ne "assignment") {
        return &$error("Assignment hash reference has" .
          " incorrect type of \"$type\"");
    }

    return $assignment;
}


sub
get_assignment_lhs
{
    my $assignment = shift;

    if (!defined(validate_assignment($assignment))) {
        return undef;
    }

    return $assignment->{lhs};
}


sub
get_assignment_rhs
{
    my $assignment = shift;

    if (!defined(validate_assignment($assignment))) {
        return undef;
    }

    return $assignment->{rhs};
}


sub
get_assignment_sz
{
    my $assignment = shift;

    if (!defined(validate_assignment($assignment))) {
        return undef;
    }

    return $assignment->{sz};
}


sub
get_assignment_never_export
{
    my $assignment = shift;

    if (!defined(validate_assignment($assignment))) {
        return undef;
    }

    return $assignment->{never_export};
}


sub
get_assignment_simulation
{
    my $assignment = shift;

    if (!defined(validate_assignment($assignment))) {
        return undef;
    }

    return $assignment->{simulation};
}

1;
