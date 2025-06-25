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






















package em_mutex_qsys;
use Exporter;
@ISA = Exporter;
@EXPORT = qw(
    &make_em_mutex
    &validate_mutex_options
);

use europa_all;
use europa_utils;



use strict;












my $mutex_data_width = 32;

my $max_value_bits = 16;
my $max_owner_bits = 16;

my $min_value_bit_position = 0;
my $max_value_bit_position = 15;
my $min_owner_bit_position = 16;
my $max_owner_bit_position = 31;
my $reset_reg_bit_position = 0;

my $mutex_value_init;
my $mutex_owner_init;

my $mutex_value_width;
my $mutex_value_bitrange;
my $mutex_value_pad_width;
my $mutex_value_pad_bitrange;

my $mutex_owner_width;
my $mutex_owner_bitrange;
my $mutex_owner_pad_width;
my $mutex_owner_pad_bitrange;





sub validate_mutex_options
{
    my ($Options) = (@_);

    validate_parameter({
        hash    => $Options,
        name    => "value_width",
        type    => "integer",
        range   => [1, $max_value_bits],
    });

    validate_parameter({
        hash    => $Options,
        name    => "owner_width",
        type    => "integer",
        range   => [1, $max_owner_bits],
   });

    validate_parameter({
        hash    => $Options,
        name    => "value_init",
        type    => "integer",
        range   => [0, (( 2 ** $max_value_bits ) - 1)],
    });

    validate_parameter({
        hash    => $Options,
        name    => "owner_init",
        type    => "integer",
        range   => [0, (( 2 ** $max_owner_bits ) - 1)],
    });
}































sub initialize_global_constants
{
    my ($Opt) = @_;


    $mutex_value_init = $Opt->{value_init};
    $mutex_owner_init = $Opt->{owner_init};

















    $mutex_value_width = $Opt->{value_width};
    $mutex_owner_width = $Opt->{owner_width};


    $mutex_value_bitrange = ($mutex_value_width - 1);
    if ( 1 < $mutex_value_width ) {
        $mutex_value_bitrange .= ':' . $min_value_bit_position;
    }


    $mutex_value_pad_width = $max_value_bits - $mutex_value_width;


    if (0 != $mutex_value_pad_width)
    {

        $mutex_value_pad_bitrange = $max_value_bit_position;
        if ( 1 < $mutex_value_pad_width ) {
            $mutex_value_pad_bitrange .= ':' . $mutex_value_width;
        }
    }


    $mutex_owner_bitrange =
        ($mutex_owner_width - 1) + $min_owner_bit_position;
    if ( 1 < $mutex_owner_width ) {
        $mutex_owner_bitrange .= ':' . $min_owner_bit_position;
    }


    $mutex_owner_pad_width = $max_owner_bits - $mutex_owner_width;


    if (0 != $mutex_owner_pad_width)
    {

        $mutex_owner_pad_bitrange = $max_owner_bit_position;
        if ( 1 < $mutex_owner_pad_width ) {
            $mutex_owner_pad_bitrange .=
                ':' . ($mutex_owner_width + $min_owner_bit_position);
        }
    }














}









sub make_em_mutex
{
    my ($Opt, $module) = (@_);


    initialize_global_constants($Opt);

    my $marker = e_default_module_marker->new($module);

    my @ports = (
        [clk            => 1,           "in" ],
        [reset_n        => 1,           "in" ],
        [chipselect     => 1,           "in" ],
        [data_from_cpu  => $mutex_data_width, "in" ],
        [data_to_cpu    => $mutex_data_width, "out"],
        [read           => 1,           "in" ],
        [write          => 1,           "in" ],
        [address        => 1,           "in" ]
    ); 

    e_port->adds(@ports);

    my $s1_type_map = {
        clk             => "clk",
        reset_n         => "reset_n",
        data_from_cpu   => "writedata",
        data_to_cpu     => "readdata",
        read            => "read",
        write           => "write",
        address         => "address",
    };

    e_avalon_slave->add({
        name     => "s1",
        type_map => $s1_type_map,
    }); 




    e_register->adds({
        name        => "mutex_value",
        out         => "mutex_value",
        in          => "data_from_cpu[$mutex_value_bitrange]",
        enable      => "mutex_reg_enable",
        async_value => $mutex_value_init,
    });


    e_register->adds({
        name        => "mutex_owner",
        out         => "mutex_owner",
        in          => "data_from_cpu[$mutex_owner_bitrange]",
        enable      => "mutex_reg_enable",
        async_value => $mutex_owner_init,
    });


    e_register->adds({
        name        => "reset_reg",
        out         => "reset_reg",
        in          => "1'b0",
        enable      => "reset_reg_enable",
        async_value => "1'b1",
    });


    e_signal->add (["mutex_free",   1]);
    e_assign->add (["mutex_free", "mutex_value == 0"]);


    e_signal->add (["owner_valid",   1]);


    if ($max_owner_bits == $mutex_owner_width) {
        e_assign->add (["owner_valid",
            "(mutex_owner == data_from_cpu[$mutex_owner_bitrange])"
        ]);
    }
    else {
        e_assign->add (["owner_valid",
            "(mutex_owner == data_from_cpu[$mutex_owner_bitrange]) &&
             (data_from_cpu[$mutex_owner_pad_bitrange] == $mutex_owner_pad_width\'b0)"
        ]);
    }


    e_signal->add (["mutex_reg_enable",   1]);
    e_assign->add (["mutex_reg_enable",
        "(mutex_free | owner_valid) & chipselect & write & ~address"]);


    e_signal->add (["reset_reg_enable",   1]);
    e_assign->add (["reset_reg_enable", "chipselect & write & address"]);





    e_signal->add (["mutex_state",   $mutex_data_width]);
    e_assign->add (["data_to_cpu", "address ? reset_reg : mutex_state"]);


    e_signal->add (["mutex_value",   $mutex_value_width]);

    e_assign->add (["mutex_state[$mutex_value_bitrange]", "mutex_value"]);
    if ($mutex_value_pad_width)
    {
        e_assign->add (["mutex_state[$mutex_value_pad_bitrange]", "$mutex_value_pad_width\'b0"]);
    }


    e_signal->add (["mutex_owner",   $mutex_owner_width]);
    e_assign->add (["mutex_state[$mutex_owner_bitrange]", "mutex_owner"]);
    if ($mutex_value_pad_width)
    {
        e_assign->add (["mutex_state[$mutex_owner_pad_bitrange]", "$mutex_owner_pad_width\'b0"]);
    }
};

1;
