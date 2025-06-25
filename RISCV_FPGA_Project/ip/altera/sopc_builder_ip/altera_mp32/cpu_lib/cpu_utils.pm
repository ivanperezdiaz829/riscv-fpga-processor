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



























package cpu_utils;
use Exporter;
@ISA = Exporter;
@EXPORT = qw(
    $error
    $progress

    $FMT_DEC
    $FMT_HEX
    $FMT_QUOTED_STR
    $FMT_UNQUOTED_STR

    $force_export
    $force_never_export

    &assert_array_ref
    &assert_hash_ref
    &assert_code_ref
    &assert_scalar
    &manditory
    &optional
    &manditory_scalar
    &optional_scalar
    &not_empty_scalar
    &manditory_int
    &optional_int
    &validate_int
    &manditory_bool
    &optional_bool
    &validate_bool
    &manditory_array
    &optional_array
    &manditory_hash
    &optional_hash
    &manditory_code
    &optional_code
    &validate_hash_keys
    &check_opt_value
    &sz2mask
    &num2sz
    &count2sz
    &compute_address_width
    &add_to_ref
    &format_c_macro
    &format_hash_as_c_macros
    &calc_num_ecc_bits
);

use strict;





our $test_mode = 0;             # Boolean set for p_unit tests

our $init_called = 0;   # Boolean set once init() routine called.


our $error = \&local_error;     # Called to report an error
our $progress = \&local_progress; # Called to display message about generation


our $FMT_DEC = 1;
our $FMT_HEX = 2;
our $FMT_QUOTED_STR = 3;
our $FMT_UNQUOTED_STR = 4;



our $force_export = 1;



our $force_never_export = 1;






sub
enable_test_mode
{
    $test_mode = 1;
}



sub
init
{
    my $args = shift;

    if ($init_called) {
        &$error("cpu_utils::init() routine called multiple times");
    }


    $error = manditory_code($args, "error");
    $progress = manditory_code($args, "progress");

    $init_called = 1;
}

sub
assert_array_ref
{
    my $value = shift;
    my $name = shift;       # Optional

    my $prefix = ($name eq "") ? "" : "'$name' ";

    if (!defined($value)) {
        return 
          &$error($prefix . "should be an array reference but is undefined");
    }

    if (ref($value) ne "ARRAY") {
        return 
          &$error($prefix . "should be an array reference but ref() returns '" .
            ref($value) . "'");
    }

    return 1;   # Some defined value
}

sub
assert_hash_ref
{
    my $value = shift;
    my $name = shift;   # Optional

    my $prefix = ($name eq "") ? "" : "'$name' ";

    if (!defined($value)) {
        return 
          &$error($prefix . "should be a hash reference but is undefined");
    }

    if (ref($value) ne "HASH") {
        return 
          &$error($prefix . "should be a hash reference but ref() returns '" .
            ref($value) . "'");
    }

    return 1;   # Some defined value
}

sub
assert_code_ref
{
    my $value = shift;
    my $name = shift;   # Optional

    my $prefix = ($name eq "") ? "" : "'$name' ";

    if (!defined($value)) {
        return &$error($prefix . "should be a code reference but is undefined");
    }

    if (ref($value) ne "CODE") {
        return 
          &$error($prefix . "should be a code reference but ref() returns '" .
            ref($value) . "'");
    }

    return 1;   # Some defined value
}

sub
assert_scalar
{
    my $value = shift;
    my $name = shift;   # Optional

    my $prefix = ($name eq "") ? "" : "'$name' ";

    if (!defined($value)) {
        return &$error($prefix . "should be a scalar but is undefined");
    }

    if ($value =~ 
      s/^(ARRAY|HASH|CODE|SCALAR)\(0x[a-fA-F0-9]+\)/$1(<hex-value>)/) {
        return &$error($prefix . "should be a scalar but '$value' looks like" .
          " a reference to me");
    }

    if (ref($value) ne "") {
        return 
          &$error($prefix . "should be a scalar but ref() returns '" .
            ref($value) . "'");
    }

    return 1;   # Some defined value
}



sub
manditory
{
    my $hash = shift;
    my $arg = shift;

    assert_hash_ref($hash) || return undef;

    my $ret = $hash->{$arg};

    if (!defined($ret)) {
        return &$error("Argument '$arg' missing from hash");
    }

    return $ret;
}



sub
optional
{
    my $hash = shift;
    my $arg = shift;

    assert_hash_ref($hash) || return undef;

    my $ret = $hash->{$arg};

    return $ret;
}




sub
manditory_scalar
{
    my $hash = shift;
    my $arg = shift;

    my $ret = manditory($hash, $arg);

    if (!defined($ret)) {
        return undef;
    }

    if (ref($ret) ne "") {
        return &$error("Argument '$arg' in a hash is a reference of type '" .
          ref($ret) . "' but should be a scalar.");
    }

    assert_scalar($ret) || return undef;

    return $ret;
}





sub
optional_scalar
{
    my $hash = shift;
    my $arg = shift;
    my $err_ref = shift;    # Optional error indication

    my $ret = optional($hash, $arg);
    if (!defined($ret)) {
        return $ret;
    }

    if (ref($ret) ne "") {

        if (ref($err_ref) eq "SCALAR") {
            ${$err_ref} = 1;
        }
        return &$error("Argument '$arg' in a hash is a reference of type '" .
          ref($ret) . "' but should be a scalar.");
    }

    if (!defined(assert_scalar($ret))) {

        if (ref($err_ref) eq "SCALAR") {
            ${$err_ref} = 1;
        }
        return undef;
    }

    return $ret;
}




sub
not_empty_scalar
{
    my $hash = shift;
    my $arg = shift;

    my $ret = manditory($hash, $arg);

    if (!defined($ret)) {
        return undef;
    }

    if (ref($ret) ne "") {
        return &$error("Argument '$arg' in a hash is a reference of type '" .
          ref($ret) . "' but should be a scalar.");
    }

    if ($ret eq "") {
        return &$error("Argument '$arg' has an empty value in a hash");
    }

    assert_scalar($ret) || return undef;

    return $ret;
}




sub
manditory_int
{
    my $hash = shift;
    my $arg = shift;

    my $ret = manditory($hash, $arg);
    if (!defined($ret)) {
        return undef;
    }

    if ($ret eq "") {
        return 
          &$error("Argument '$arg' should be an integer value but is an" .
            " empty string in a hash");
        return 0;   # default value
    }

    return optional_int($hash, $arg);
}




sub
optional_int
{
    my $hash = shift;
    my $arg = shift;

    assert_hash_ref($hash) || return undef;

    my $value = $hash->{$arg};

    if (ref($value) ne "") {
        return &$error("Argument '$arg' is a reference of type '" .
          ref($value) . "' in a hash but should be an integer value.");
    }

    if ($value eq "") {
        return 0;   # default value
    }

    my $ret = validate_int($value);

    if (!defined($ret)) {
        return 
          &$error("Argument '$arg' has non-integer value of '$value' in hash");
    }

    return $ret;
}



sub
validate_int
{
    my $value = shift;

    if ($value eq "") {
        return undef;
    }


    if ($value =~ /^[+-]?\d+$/) {
        return $value;
    }


    if ($value =~ /^0x[0-9a-fA-F]+$/) {
        return oct($value);
    }

    return undef;
}




sub
manditory_bool
{
    my $hash = shift;
    my $arg = shift;

    my $ret = manditory($hash, $arg);
    if (!defined($ret)) {
        return undef;
    }

    return optional_bool($hash, $arg);
}




sub
optional_bool
{
    my $hash = shift;
    my $arg = shift;

    assert_hash_ref($hash) || return undef;

    my $value = $hash->{$arg};

    if (ref($value) ne "") {
        return &$error("Argument '$arg' is a reference of type '" .
          ref($value) . "' in a hash but should be a binary value.");
    }

    my $ret = validate_bool($value);

    if (!defined($ret)) {
        return 
          &$error("Argument '$arg' has non-boolean value of '$value' in hash");
    }

    return $ret;
}



sub
validate_bool
{
    my $value = shift;

    if ($value eq "") {
        return 0;   # false
    }

    if ($value eq "0") {
        return 0;   # false
    }

    if ($value eq "1") {
        return 1;   # true
    }


    if (!($value =~ /^[01]$/)) {
        return undef;
    }

    return ($value == 1) ? 1 : 0;
}



sub
manditory_array
{
    my $hash = shift;
    my $arg = shift;

    my $ret = manditory($hash, $arg);
    if (!defined($ret)) {
        return undef;
    }

    if ($ret eq "") {
        return 
          &$error("Argument '$arg' should be an array reference but is" .
            " an empty string in a hash");
    }

    if (ref($ret) eq "") {
        return &$error("Argument '$arg' in a hash has value '$ret' which" .
          " is supposed to be an array reference.");
    }

    if (ref($ret) ne "ARRAY") {
        return &$error("Argument '$arg' in a hash is a reference of type '" .
          ref($ret) . "' but should be an array reference.");
    }

    return $ret;
}





sub
optional_array
{
    my $hash = shift;
    my $arg = shift;
    my $err_ref = shift;    # Optional error indication

    my $ret = optional($hash, $arg);
    if (!defined($ret)) {
        return undef;
    }

    if (ref($ret) eq "") {

        if (ref($err_ref) eq "SCALAR") {
            ${$err_ref} = 1;
        }
        return &$error("Argument '$arg' in a hash has value '$ret' which" .
          " is supposed to be an array reference.");
    }

    if (ref($ret) ne "ARRAY") {

        if (ref($err_ref) eq "SCALAR") {
            ${$err_ref} = 1;
        }
        return &$error("Argument '$arg' in a hash is a reference of type '" .
          ref($ret) . "' but should be an array reference.");
    }

    return $ret;
}



sub
manditory_hash
{
    my $hash = shift;
    my $arg = shift;

    my $ret = manditory($hash, $arg);
    if (!defined($ret)) {
        return undef;
    }

    if ($ret eq "") {
        return 
          &$error("Argument '$arg' should be a hash reference but is" .
            " an empty string in a hash");
    }

    if (ref($ret) eq "") {
        return &$error("Argument '$arg' in a hash has value '$ret' which" .
          " is supposed to be a hash reference.");
    }

    if (ref($ret) ne "HASH") {
        return &$error("Argument '$arg' in a hash is a reference of type '" .
          ref($ret) . "' but should be a hash reference.");
    }

    return $ret;
}





sub
optional_hash
{
    my $hash = shift;
    my $arg = shift;
    my $err_ref = shift;    # Optional error indication

    my $ret = optional($hash, $arg);
    if (!defined($ret)) {
        return undef;
    }

    if (ref($ret) eq "") {

        if (ref($err_ref) eq "SCALAR") {
            ${$err_ref} = 1;
        }
        return &$error("Argument '$arg' in a hash has value '$ret' which" .
          " is supposed to be a hash reference.");
    }

    if (ref($ret) ne "HASH") {

        if (ref($err_ref) eq "SCALAR") {
            ${$err_ref} = 1;
        }
        return &$error("Argument '$arg' in a hash is a reference of type '" .
          ref($ret) . "' but should be a hash reference.");
    }

    return $ret;
}



sub
manditory_code
{
    my $hash = shift;
    my $arg = shift;

    my $ret = manditory($hash, $arg);
    if (!defined($ret)) {
        return undef;
    }

    if ($ret eq "") {
        return 
          &$error("Argument '$arg' should be a code reference but is" .
            " an empty string in a hash");
        return 0;   # default value
    }

    if (ref($ret) eq "") {
        return &$error("Argument '$arg' in a hash has value '$ret' which" .
          " is supposed to be an code reference.");
    }

    if (ref($ret) ne "CODE") {
        return &$error("Argument '$arg' in a hash is a reference of type '" .
          ref($ret) . "' but should be a code reference.");
    }

    return $ret;
}





sub
optional_code
{
    my $hash = shift;
    my $arg = shift;
    my $err_ref = shift;    # Optional error indication

    my $ret = optional($hash, $arg);
    if (!defined($ret)) {
        return undef;
    }

    if (ref($ret) eq "") {

        if (ref($err_ref) eq "SCALAR") {
            ${$err_ref} = 1;
        }
        return &$error("Argument '$arg' in a hash has value '$ret' which" .
          " is supposed to be a code reference.");
    }

    if (ref($ret) ne "CODE") {

        if (ref($err_ref) eq "SCALAR") {
            ${$err_ref} = 1;
        }
        return &$error("Argument '$arg' in a hash is a reference of type '" .
          ref($ret) . "' but should be a code reference.");
    }

    return $ret;
}




sub
validate_hash_keys
{
    my $name = shift;           # Name of hash for error messages
    my $hash = shift;           # Hash reference to check
    my $allowed_keys = shift;   # Array of strings

    assert_scalar($name, "name") || return undef;
    assert_hash_ref($hash, $name) || return undef;
    assert_array_ref($allowed_keys, "allowed_keys") || return undef;

    foreach my $key (keys(%$hash)) {
        my $found = 0;
        
        foreach my $allowed_key (@$allowed_keys) {
            if ($key eq $allowed_key) {
                $found = 1;
                last;
            }
        }

        if (!$found) {
            return 
              &$error("Hash '$name' contains key '$key' which isn't allowed.");
        }
    }

    return 1;   # Some defined value
}




sub 
check_opt_value
{
    my ($hash, $arg, $expected, $whoami) = @_;

    my $actual = manditory($hash, $arg);
    if (!defined($actual)) {
        return undef;
    }

    my $expected_ref_type = ref($expected);

    if ($expected_ref_type eq "ARRAY") {

        my @expected_values = @$expected;

        my $match = 0;

        foreach my $expected_value (@expected_values) {
            if ($actual eq $expected_value) {
                $match = 1;
            }
        }

        if (!$match) {
            return &$error("$whoami: '$arg' is '$actual' but must be one of" .
              " [" . join(",", @expected_values) . "]");
        }
    } elsif ($expected_ref_type eq "") {

        if ($actual ne $expected) {
            return 
              &$error("$whoami: '$arg' is '$actual' but must be '$expected'");
        }
    } else {
        return &$error("check_opt_value: called with arg $arg and unknown" .
          " reference type $expected_ref_type");
    }

    return $actual;
}





sub
sz2mask
{
    my $sz = shift;

    if (!defined($sz)) {
        return &$error("sz2mask: Attempt to make mask undefined sz");
    }

    if (($sz <= 0) || ($sz > 32)) {
        return &$error("sz2mask: Attempt to make mask for sz of $sz");
    }

    return ($sz == 32) ? 0xffffffff : ((0x1 << $sz) - 1);
}





sub 
num2sz
{
    my $num = shift;

    if (!defined($num)) {
        return &$error("num2sz: Called with undefined num");
    }

    if ($num < 0) {
        return &$error("num2sz: Called with negative num of $num");
    }

    for (my $lsb = 0; $lsb < 32; $lsb++) {
        if ($num < (0x1 << $lsb)) {
            return $lsb;
        }
    }

    if ($num >= 0x80000000) {
        return 32;
    }

    return &$error("num2sz: Couldn't figure out what to do with num of $num");
}







sub
count2sz
{
    my $count = shift;

    if (!defined($count)) {
        return &$error("count2sz: Called with undefined count");
    }

    if ($count < 0) {
        return &$error("count2sz: Called with negative count of $count");
    }

    if ($count == 0) {
        return &$error("count2sz: Called with zero count");
    }

    return num2sz($count-1);
}





sub
add_to_ref
{
    my $dst = shift;

    if (!defined($dst)) {
        return &$error("Destination is undefined");
    }

    my $dst_ref = ref($dst);
    
    foreach my $src (@_) {

        if (!defined($src)) {
            next;
        }
    
        my $src_ref = ref($src);
    
        if ($src_ref eq "HASH") {
            if (!defined(assert_hash_ref($dst, "Destination"))) {
                return undef;
            }
            if (!defined(add_to_hash($dst, $src))) {
                return undef;
            }
        } elsif ($src_ref eq "ARRAY") {
            if (!defined(assert_array_ref($dst, "Destination"))) {
                return undef;
            }
            if (!defined(add_to_array($dst, $src))) {
                return undef;
            }
        } else {
            return &$error("Source must be a reference to a hash or an array" .
              " but ref() is '" . $src_ref . "'");
        }
    }

    return 1;       # Some defined value
}



sub
format_c_macro
{
    my $name = shift;
    my $value = shift;
    my $fmt = shift;      # Optional format

    my $uc_name = uc($name);    # converted to upper-case
    my $int_value;
    my $default_fmt;


    if ($value =~ /^[0-9]+'h([0-9a-f]+)$/) {

        $int_value = hex($1);
        $default_fmt = $FMT_HEX;
    } elsif ($value =~ /^[0-9]+'d([0-9]+)$/) {

        $int_value = eval($1);
        $default_fmt = $FMT_DEC;
    } elsif ($value =~ /^[0-9]+'b([01]+)$/) {

        $int_value = oct("0b" . $1);
        $default_fmt = $FMT_HEX;
    } elsif (!($value =~ /^[0-9]+$/)) {

        $default_fmt = $FMT_QUOTED_STR;
    } else {

        $int_value = $value;
        $default_fmt = $FMT_DEC;
    }

    if (!defined($fmt)) {
        $fmt = $default_fmt;
    }

    if (!defined($fmt)) {
        return &$error("Can't determine format for macro '$name'");
    }

    my $str_value;

    if ($fmt == $FMT_DEC) {
        $str_value = ($int_value & (0x1 << 31)) ?
          sprintf("%uu", $int_value) :
          sprintf("%u", $int_value);
    } elsif ($fmt == $FMT_HEX) {
        $str_value = sprintf("0x%x", $int_value);
    } elsif ($fmt == $FMT_QUOTED_STR) {
        $str_value = '"' . $value . '"';
    } elsif ($fmt == $FMT_UNQUOTED_STR) {
        $str_value = $value;
    } else {
        return &$error("Bogus format of '$fmt' for macro '$name'");
    }


    return "#define $uc_name $str_value";
}



sub
format_hash_as_c_macros
{
    my $hash = shift;       # What will be converted into #define macros
    my $macros = shift;     # Array reference
    my $prefix = shift;     # Optional prefix

    for my $name (sort(keys(%$hash))) {
        my $value = $hash->{$name};

        push(@$macros, format_c_macro($prefix . $name, $value));
    }

    return 1;   # Some defined value
}


sub
calc_num_ecc_bits
{
    my $data_width = shift;


    if ($data_width > 64) {
        return &$error("ECC does not support data width larger than 64 bits");
    }



    my $ecc_bits = 0;


    while ((2**$ecc_bits - $ecc_bits - 1) < $data_width) {
        $ecc_bits++;
    }
    $ecc_bits++;

    return $ecc_bits;
}







sub
add_to_hash
{
    my $dst = shift;
    my $src = shift;

    if (!defined($src)) {
        return &$error("Source is undefined");
    }

    if (!defined($dst)) {
        return &$error("Destination is undefined");
    }

    if (!defined(assert_hash_ref($src, "Source"))) {
        return undef;
    }
    if (!defined(assert_hash_ref($dst, "Destination"))) {
        return undef;
    }

    my $src_ref = ref($src);
    my $dst_ref = ref($dst);

    foreach my $key (keys(%$src)) {
        my $src_val = $src->{$key};
        my $src_val_ref = ref($src_val);
        my $dst_val = $dst->{$key};
        my $dst_val_ref = ref($dst_val);

        if (defined($dst_val)) {

            if ($src_val_ref eq "HASH") {
                if ($dst_val_ref ne "HASH") {
                    return &$error("Destination should be empty or have" .
                      " a HASH ref at hash key '$key' but" .
                      " has ref() of '$dst_val_ref'");
                }
    

                if (!defined(add_to_hash($dst_val, $src_val))) {
                    return undef;
                }
            } elsif ($src_val_ref eq "ARRAY") {
                if ($dst_val_ref ne "ARRAY") {
                    return &$error("Destination should be empty or have" .
                      " an ARRAY ref at hash key '$key' but" .
                      " has ref() of '$dst_val_ref'");
                }
    

                if (!defined(add_to_array($dst_val, $src_val))) {
                    return undef;
                }
            } else {
                return &$error("Destination already contains scalar value" .
                  " '$dst_val' at hash key '$key' and attempt to replace it" .
                  " with value '$src_val' has failed");
            }
        } else {

            $dst->{$key} = $src_val;
        }
    }

    return 1;       # Some defined value
}



sub
add_to_array
{
    my $dst = shift;
    my $src = shift;

    if (!defined($src)) {
        return &$error("Source is undefined");
    }

    if (!defined($dst)) {
        return &$error("Destination is undefined");
    }

    if (!defined(assert_array_ref($src, "Source"))) {
        return undef;
    }
    if (!defined(assert_array_ref($dst, "Destination"))) {
        return undef;
    }

    my $src_ref = ref($src);
    my $dst_ref = ref($dst);

    foreach my $src_val (@$src) {
        my $src_val_ref = ref($src_val);

        if ($src_val_ref eq "HASH") {

            my $dst_hash = {};
            push(@$dst, $dst_hash);


            if (!defined(add_to_hash($dst_hash, $src_val))) {
                return undef;
            }
        } elsif ($src_val_ref eq "ARRAY") {

            my $dst_array = [];
            push(@$dst, $dst_array);


            if (!defined(add_to_array($dst_array, $src_val))) {
                return undef;
            }
        } else {

            push(@$dst, $src_val);
        }
    }

    return 1;       # Some defined value
}


sub
local_error
{
    my ($package, $pathname, $line, $func, $has_args, $wantarray) = caller(1);

    $func =~ s/^.*:://;     # Remove package name prefix
    $pathname =~ s!^.*/(.*)$!$1!;   # Basename equivalent

    print "ERROR: $pathname:$line - ", @_, "\n";

    if ($test_mode) {

        return undef;
    }

    print_backtrace();

    exit(1);
}


sub
local_progress
{
    foreach my $msg (@_) { 
	    print "# (*) $msg\n";
    }
}

sub 
print_backtrace
{


    my @frames;
    my $i = 2;      # Skip over print_backtrace and its caller
    my ($package, $pathname, $line, $func, $has_args, $wantarray);

    print "BACKTRACE:\n";

    while (($package, $pathname, $line, $func, $has_args, $wantarray) = 
      caller($i++)) {
        $func =~ s/^.*:://;     # Remove package name prefix
        $pathname =~ s!^.*/(.*)$!$1!;   # Basename equivalent
        print("$pathname:$line - $func()\n");
    }

    print "\n";
}

1;
