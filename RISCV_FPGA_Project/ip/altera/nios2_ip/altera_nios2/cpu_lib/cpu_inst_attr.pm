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






















package cpu_inst_attr;
use Exporter;
@ISA = Exporter;
@EXPORT = qw(
    &add_inst_attr
    &validate_inst_attr
    &get_inst_attrs
    &get_inst_attr_names
    &get_inst_attr_by_name
    &get_inst_attr_name
    &get_inst_attr_insts
    &get_inst_attr_attrs
);

use cpu_utils;
use strict;














our @inst_attrs;
















sub
add_inst_attr
{
    my $props = shift;          # Hash reference with arguments

    my $name = not_empty_scalar($props, "name");
    my $insts = optional($props, "insts");
    my $attrs = optional($props, "attrs");

    if (!defined($name)) {
        return undef;
    }
    if (!defined($insts)) {
        $insts = [];
    }
    if (!defined($attrs)) {
        $attrs = [];
    }

    if (defined(get_inst_attr_by_name_or_undef($name))) {
        return &$error("Instruction attribute $name already exists");
    }

    if (ref($insts) ne "ARRAY") {
        return &$error("Instruction attribute $name insts property must be" .
          " an array reference but ref() returns '" . ref($insts) . "'");
    }

    if (ref($attrs) ne "ARRAY") {
        return &$error("Instruction attribute $name attrs property must be" .
          " an array reference but ref() returns '" . ref($attrs) . "'");
    }


    my $inst_attr = {
        type        => "inst_attr",
        name        => $name,
        insts       => $insts,
        attrs       => $attrs,
    };


    push(@inst_attrs, $inst_attr);

    return $inst_attr;
}




sub
validate_inst_attr
{
    my $inst_attr = shift;

    if (!defined($inst_attr)) {
        return &$error("Instruction attribute reference is undefined");
    }

    if ($inst_attr == 0) {
        return &$error("Instruction attribute reference is 0");
    }

    my $ref_type = ref($inst_attr);
    if ($ref_type ne "HASH") {
        return &$error("Instruction attribute reference is to a $ref_type" .
          " but must be to a HASH");
    }

    my $type = $inst_attr->{type};

    if (!defined($type)) {
        return &$error("Instruction attribute hash reference has" .
          " no \"type\" member");
    }

    if ($type ne "inst_attr") {
        return &$error("Instruction attribute hash reference has incorrect type"
          . " of \"$type\"");
    }

    return $inst_attr;
}


sub
get_inst_attrs
{
    return \@inst_attrs;
}


sub
get_inst_attr_names
{
    my @names;

    foreach my $inst_attr (@inst_attrs) {
        push(@names, $inst_attr->{name});
    }

    my @sorted_names = sort(@names);

    return \@sorted_names;
}



sub
get_inst_attr_by_name
{
    my $name = shift;   # lower-case name (e.g. "arithmetic")

    my $inst_attr = get_inst_attr_by_name_or_undef($name);

    if (defined($inst_attr)) {
        return $inst_attr;
    }
    
    return &$error("Instruction attribute name $name not found.");
}



sub
get_inst_attr_by_name_or_undef
{
    my $name = shift;   # lower-case name (e.g. "arithmetic")

    foreach my $inst_attr (@inst_attrs) {
        if ($name eq $inst_attr->{name}) {
            return $inst_attr;
        }
    }

    return undef;
}


sub
get_inst_attr_name
{
    my $inst_attr = shift;

    if (!defined(validate_inst_attr($inst_attr))) {
        return undef;
    }

    return $inst_attr->{name};
}


sub
get_inst_attr_insts
{
    my $inst_attr = shift;

    if (!defined(validate_inst_attr($inst_attr))) {
        return undef;
    }

    return $inst_attr->{insts};
}


sub
get_inst_attr_attrs
{
    my $inst_attr = shift;

    if (!defined(validate_inst_attr($inst_attr))) {
        return undef;
    }

    return $inst_attr->{attrs};
}

1;
