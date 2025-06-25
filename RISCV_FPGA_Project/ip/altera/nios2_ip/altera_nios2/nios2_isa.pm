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






















package nios2_isa;
use Exporter;
@ISA = Exporter;
@EXPORT = qw(
    $interrupt_sz
    $max_control_regs
    $max_register_sets
    $max_shadow_register_sets

    $eic_port_ril_lsb
    $eic_port_ril_sz
    $eic_port_ril_msb
    $eic_port_rnmi_lsb
    $eic_port_rnmi_sz
    $eic_port_rnmi_msb
    $eic_port_rrs_lsb
    $eic_port_rrs_sz
    $eic_port_rrs_msb
    $eic_port_rha_lsb
    $eic_port_rha_sz
    $eic_port_rha_msb
    $eic_port_lsb
    $eic_port_sz
    $eic_port_msb

    $retaddr_regnum_int
    $bretaddr_regnum_int
    $sstatus_regnum_int
    $eretaddr_regnum_int
    $fp_regnum_int
    $sp_regnum_int
    $gp_regnum_int
    $bt_regnum_int
    $et_regnum_int
    $at_regnum_int

    $retaddr_regnum
    $bretaddr_regnum
    $sstatus_regnum
    $eretaddr_regnum
    $fp_regnum
    $sp_regnum
    $gp_regnum
    $bt_regnum
    $et_regnum
    $at_regnum
);

use cpu_utils;
use strict;












our $interrupt_sz;
our $max_control_regs;
our $max_register_sets;
our $max_shadow_register_sets;

our $eic_port_ril_lsb;
our $eic_port_ril_sz;
our $eic_port_ril_msb;
our $eic_port_rnmi_lsb;
our $eic_port_rnmi_sz;
our $eic_port_rnmi_msb;
our $eic_port_rrs_lsb;
our $eic_port_rrs_sz;
our $eic_port_rrs_msb;
our $eic_port_rha_lsb;
our $eic_port_rha_sz;
our $eic_port_rha_msb;
our $eic_port_lsb;
our $eic_port_sz;
our $eic_port_msb;

our $retaddr_regnum_int;
our $bretaddr_regnum_int;
our $sstatus_regnum_int;
our $eretaddr_regnum_int;
our $fp_regnum_int;
our $sp_regnum_int;
our $gp_regnum_int;
our $bt_regnum_int;
our $et_regnum_int;
our $at_regnum_int;

our $retaddr_regnum;
our $bretaddr_regnum;
our $sstatus_regnum;
our $eretaddr_regnum;
our $fp_regnum;
our $sp_regnum;
our $gp_regnum;
our $bt_regnum;
our $et_regnum;
our $at_regnum;




sub
validate_and_elaborate
{
    my $isa_constants = create_isa_constants();


    my $nios2_isa_info = {
      isa_constants => $isa_constants,
    };



    foreach my $var (keys(%$isa_constants)) {
        eval_cmd('$' . $var . ' = "' . $isa_constants->{$var} . '"');
    }

    return $nios2_isa_info;
}


sub
convert_to_c
{
    my $nios2_isa_info = shift;
    my $c_lines = shift;        # Reference to array of lines for *.c file
    my $h_lines = shift;        # Reference to array of lines for *.h file

    push(@$h_lines, "");
    push(@$h_lines, "/* Generic ISA Constants */");
    return format_hash_as_c_macros($nios2_isa_info->{isa_constants}, $h_lines);
}





sub
create_isa_constants
{
    my %constants;

    $constants{interrupt_sz} = 32;
    $constants{max_control_regs} = 32;
    $constants{max_register_sets} = 64;
    $constants{max_shadow_register_sets} = 63;

    $constants{eic_port_ril_lsb} = 0;
    $constants{eic_port_ril_sz} = 6;
    $constants{eic_port_ril_msb} = 
      $constants{eic_port_ril_lsb} + $constants{eic_port_ril_sz} - 1;
    $constants{eic_port_rnmi_lsb} = $constants{eic_port_ril_msb} + 1;
    $constants{eic_port_rnmi_sz} = 1;
    $constants{eic_port_rnmi_msb} =
      $constants{eic_port_rnmi_lsb} + $constants{eic_port_rnmi_sz} - 1;
    $constants{eic_port_rrs_lsb} = $constants{eic_port_rnmi_msb} + 1;
    $constants{eic_port_rrs_sz} = 6;
    $constants{eic_port_rrs_msb} =
      $constants{eic_port_rrs_lsb} + $constants{eic_port_rrs_sz} - 1;
    $constants{eic_port_rha_lsb} = $constants{eic_port_rrs_msb} + 1;
    $constants{eic_port_rha_sz} = 32;
    $constants{eic_port_rha_msb} = 
      $constants{eic_port_rha_lsb} + $constants{eic_port_rha_sz} - 1;
    $constants{eic_port_lsb} = $constants{eic_port_ril_lsb};
    $constants{eic_port_msb} = $constants{eic_port_rha_msb};
    $constants{eic_port_sz} = 
      $constants{eic_port_rha_msb} - $constants{eic_port_ril_lsb} + 1;

    $constants{retaddr_regnum_int} =  31;
    $constants{bretaddr_regnum_int} = 30;  # BA in the normal register set
    $constants{sstatus_regnum_int} = 30;   # SSTATUS in shadow register sets
    $constants{eretaddr_regnum_int} = 29;
    $constants{fp_regnum_int} = 28;
    $constants{sp_regnum_int} = 27;
    $constants{gp_regnum_int} = 26;
    $constants{bt_regnum_int} = 25;
    $constants{et_regnum_int} = 24;
    $constants{at_regnum_int} = 1;

    $constants{retaddr_regnum} =  "5'd" . $constants{retaddr_regnum_int};
    $constants{bretaddr_regnum} = "5'd" . $constants{bretaddr_regnum_int};
    $constants{sstatus_regnum}  = "5'd" . $constants{sstatus_regnum_int};
    $constants{eretaddr_regnum} = "5'd" . $constants{eretaddr_regnum_int};
    $constants{fp_regnum} =       "5'd" . $constants{fp_regnum_int};
    $constants{sp_regnum} =       "5'd" . $constants{sp_regnum_int};
    $constants{gp_regnum} =       "5'd" . $constants{gp_regnum_int};
    $constants{bt_regnum} =       "5'd" . $constants{bt_regnum_int};
    $constants{et_regnum} =       "5'd" . $constants{et_regnum_int};
    $constants{at_regnum} =       "5'd" . $constants{at_regnum_int};
    
    return \%constants;
}

sub
eval_cmd
{
    my $cmd = shift;

    eval($cmd);
    if ($@) {
        &$error("nios2_isa.pm: eval($cmd) returns '$@'\n");
    }
}

1;
