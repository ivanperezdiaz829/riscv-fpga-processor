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






















package nios_frontend;
use Exporter;
@ISA = Exporter;
@EXPORT = qw(
);

use cpu_utils;
use cpu_wave_signals;
use cpu_file_utils;
use cpu_exception_gen;
use europa_all;
use europa_utils;
use nios_utils;
use nios_addr_utils;
use nios_avalon_masters;
use nios_isa;
use nios_icache;
use nios_common;
use strict;











sub 
gen_frontend
{
    my $Opt = shift;

    if ($icache_present) {
        nios_icache::gen_instruction_cache($Opt);
    }

    if ($instruction_master_present) {
        gen_instruction_master($Opt);
    }

    if ($itcm_present) {
        gen_instruction_tcm_masters($Opt);
    }
}














sub 
gen_instruction_master
{
    my $Opt = shift;

    my $whoami = "instruction master";

    if (!$instruction_master_present) {
        &$error("$whoami: Called when no instruction master present");
    }

    if (!$icache_present) {
        &$error("$whoami: I-cache must be present");
    }

    $Opt->{instruction_master}{port_map} = {
      i_readdata      => "readdata",
      i_address       => "address",
      i_read          => "read",
      i_waitrequest   => "waitrequest",
      i_readdatavalid => "readdatavalid",
    };

    if ($imaster_bursts) {
        $Opt->{instruction_master}{port_map}{i_burstcount} = "burstcount";
    }

    my $instruction_master_baddr_sz = $Opt->{instruction_master}{Address_Width};

    push(@{$Opt->{port_list}},

      [i_readdata       => $iw_sz,                          "in" ],
      [i_readdatavalid  => 1,                               "in" ],
      [i_waitrequest    => 1,                               "in" ],
      [i_address        => $instruction_master_baddr_sz,    "out"],
      [i_read           => 1,                               "out"],
    );

    if ($imaster_bursts) {
        push(@{$Opt->{port_list}},
          [i_burstcount     => $imaster_burstcount_sz,  "out"],
        );
    }


    if (manditory_bool($Opt, "hbreak_test")) {
        my $data_master_interrupt_sz = 
          manditory_int($Opt, "data_master_interrupt_sz");

        $Opt->{instruction_master}{port_map}{test_hbreak_req} = "irq";

        push(@{$Opt->{port_list}},

          [test_hbreak_req  => $data_master_interrupt_sz,  "in" ],
        );
    }

    e_register->adds(
      {out => ["i_readdatavalid_d1", 1],            in => "i_readdatavalid",
      enable => "1'b1"},


      {out => ["i_read", 1],                        in => "i_read_nxt",
      enable => "1'b1"},
    );

    if (manditory_bool($Opt, "cache_icache_allow_tag_wrt")) {
      e_register->adds(

        {out => ["i_readdata_d1", $iw_sz],            in => "i_readdata",
        enable => "i_readdatavalid"},
      );
    } else {
      e_register->adds(

        {out => ["i_readdata_d1", $iw_sz],            in => "i_readdata",
        enable => "1'b1"},
      );
    }

    my @instruction_master = (
        { divider => "instruction_master" },
        { radix => "x", signal => "i_read" },
        { radix => "x", signal => "i_waitrequest" },
        { radix => "x", signal => "i_address" },
        { radix => "x", signal => "i_readdatavalid_d1" },
        { radix => "x", signal => "i_readdata_d1" },
        $imaster_bursts ? {radix => "x", signal => "i_burstcount"} : "",
      );

    if ($Opt->{full_waveform_signals}) {
        push(@plaintext_wave_signals, @instruction_master);
    }
}





sub
gen_instruction_tcm_masters
{
    my $Opt = shift;

    if (!$itcm_present) {
        &$error(
          "Called when no instruction tightly-coupled masters are present");
    }

    my $num_tightly_coupled_instruction_masters =
      manditory_int($Opt, "num_tightly_coupled_instruction_masters");

    for (my $cmi = 0; $cmi < $num_tightly_coupled_instruction_masters; $cmi++) {
        gen_one_tightly_coupled_instruction_master($Opt, $cmi);
    }
}

sub 
gen_one_tightly_coupled_instruction_master
{
    my $Opt = shift;
    my $cmi = shift;

    my $whoami = "Tightly-coupled instruction master";

    my $fetch_npcb = not_empty_scalar($Opt, "fetch_npcb");

    check_opt_value($Opt, "inst_ram_output_stage", "F", $whoami);

    my $master_name = "tightly_coupled_instruction_master_${cmi}";
    my $slave_addr_width = 
      manditory_int($Opt->{$master_name}, "Slave_Address_Width");
    my $avalon_addr_width = 
      manditory_int($Opt->{$master_name}, "Address_Width");

















    my $ecc_recoverable = "";
    if ($itcm_ecc_present && $ecc_present) {
            $ecc_recoverable = "M_icm${cmi}_one_bit_err ? M_pcb[$slave_addr_width-1:0] :";
    }

    if ($slave_addr_width < $avalon_addr_width) {


        my $top_bits = 
           not_empty_scalar($Opt->{$master_name}, "Paddr_Base_Top_Bits");
        if ($itcm_ecc_present && $ecc_present) {
             $ecc_recoverable = "M_icm${cmi}_one_bit_err ? { $top_bits, " . "M_pcb[$slave_addr_width-1:0] } :";
        }
        e_assign->adds(
          ["icm${cmi}_address", 
            "$ecc_recoverable { $top_bits, " . $fetch_npcb . "[$slave_addr_width-1:0] }"],
        );
    } else {
        e_assign->adds(
          ["icm${cmi}_address", $ecc_recoverable . $fetch_npcb . "[$avalon_addr_width-1:0]"],
        );
    }



    if ($itcm_ecc_present && $ecc_present) {
        e_assign->adds(
          ["icm${cmi}_read", "~M_icm${cmi}_one_bit_err"],
          ["icm${cmi}_clken", "F_en | M_icm${cmi}_one_bit_err"],
        );   
    } else {
        e_assign->adds(
          ["icm${cmi}_read", "1'b1"],
          ["icm${cmi}_clken", "F_en"],
        );
    }

    my @ecc_write_port;
    if ($itcm_ecc_present && $ecc_present) {
        e_assign->adds(
           ["icm${cmi}_write", "M_icm${cmi}_one_bit_err"],
           ["icm${cmi}_writedata", "M_icm${cmi}_writedata"],
        );
        push(@ecc_write_port,
          "icm${cmi}_write"       => "write",
          "icm${cmi}_writedata"   => "writedata",
        );
    }

    $Opt->{$master_name}{port_map} = {
      "icm${cmi}_readdata"       => "readdata",
      "icm${cmi}_waitrequest"    => "waitrequest",
      "icm${cmi}_readdatavalid"  => "readdatavalid",
      "icm${cmi}_address"        => "address",
      "icm${cmi}_read"           => "read",
      "icm${cmi}_clken"          => "clken",
      @ecc_write_port
    };

    $Opt->{$master_name}{sideband_signals} = [
      "clken",
    ];

    if ($itcm_ecc_present && $ecc_present) {
        my $ecc_bits = calc_num_ecc_bits($datapath_sz);
        my $ecc_data_sz =  $datapath_sz + $ecc_bits;
        push(@{$Opt->{port_list}},
          ["icm${cmi}_readdata"      => $ecc_data_sz,            "in" ],
          ["icm${cmi}_write"         => 1,                       "out" ],
          ["icm${cmi}_writedata"     => $ecc_data_sz,            "out" ],
        );       
    } else {
        push(@{$Opt->{port_list}},
          ["icm${cmi}_readdata"      => $datapath_sz,            "in" ],
        );
    }
    
    push(@{$Opt->{port_list}},
      ["icm${cmi}_waitrequest"   => 1,                       "in" ],
      ["icm${cmi}_readdatavalid" => 1,                       "in" ],
      ["icm${cmi}_address"       => $avalon_addr_width,      "out"],
      ["icm${cmi}_read"          => 1,                       "out"],
      ["icm${cmi}_clken"         => 1,                       "out"],
    );
}

1;
