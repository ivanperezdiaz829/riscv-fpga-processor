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













































use strict;
use europa_all;















sub define_scfifo
{
    my $mod = shift;
    my $fifo_name = shift;
    my $fifo_depth = shift;
    my $fifo_width = shift;
    my $use_register = shift;
    my $use_usedw = shift;
    my $device_family = shift;
    my $showahead_mode = shift;

    my $use_eab = $use_register ? qq("OFF") : qq("ON");
    my $showahead = $showahead_mode ? qq("ON") : qq("OFF");
    my $fifo_widthu = log2($fifo_depth);
    my $fifo_widthu_ceil = ceil (log2($fifo_depth));

    if ($fifo_widthu != $fifo_widthu_ceil)
    {
        &ribbit("FIFO depth need to be power of 2.");
    }

    my %out_port_map_hash =
    (
        empty => "${fifo_name}_empty",
        full => "${fifo_name}_full",
        q => e_signal->new(["${fifo_name}_q"=>$fifo_width]),
    );

    if($use_usedw)
    {
         $out_port_map_hash{"usedw"} = e_signal->new(["${fifo_name}_usedw"=> $fifo_widthu]);
    }

    $mod->add_contents(
        e_blind_instance->new({
            name => $mod->name() . "_" . $fifo_name,
            module => "scfifo",
            use_sim_models => 1,
            in_port_map =>
            {
                aclr => "reset",
                clock => "clk",
                data => e_signal->new(["${fifo_name}_data"=>$fifo_width]),
                rdreq => "${fifo_name}_rdreq",
                wrreq => "${fifo_name}_wrreq",
            },
            out_port_map =>
            {
                 %out_port_map_hash,
            },

            parameter_map =>
            {
                add_ram_output_register => qq("ON"),
                intended_device_family => qq("$device_family"),
                lpm_numwords => $fifo_depth,
                lpm_showahead => $showahead,
                lpm_type => qq("scfifo"),
                lpm_width => $fifo_width,
                lpm_widthu => $fifo_widthu,
                overflow_checking => qq("ON"),
                underflow_checking => qq("ON"),
                use_eab => $use_eab,
            },
        }),
    );
}

1;
