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






















package nevada_isa;
use Exporter;
@ISA = Exporter;
@EXPORT = qw(
    $interrupt_sz

    $at_regnum
    $k0_regnum
    $k1_regnum
    $gp_regnum
    $sp_regnum
    $fp_regnum
    $ra_regnum

    $default_reset_paddr
    $exception_boot_reset_offset
    $debug_probe_trap_disabled_reset_offset
    $debug_probe_trap_enabled_addr
    $tlb_refill_ebase_offset
    $cache_error_ebase_offset
    $general_exc_ebase_offset
    $vectored_interrupt_ebase_offset
);

use cpu_utils;
use strict;












our $interrupt_sz;

our $at_regnum;
our $k0_regnum;
our $k1_regnum;
our $gp_regnum;
our $sp_regnum;
our $fp_regnum;
our $ra_regnum;

our $default_reset_paddr;
our $exception_boot_reset_offset;
our $debug_probe_trap_disabled_reset_offset;
our $debug_probe_trap_enabled_addr;
our $tlb_refill_ebase_offset;
our $cache_error_ebase_offset;
our $general_exc_ebase_offset;
our $vectored_interrupt_ebase_offset;




sub
validate_and_elaborate
{
    my $isa_constants = create_isa_constants();


    my $nevada_isa_info = {
      isa_constants => $isa_constants,
    };



    foreach my $var (keys(%$isa_constants)) {
        eval_cmd('$' . $var . ' = "' . $isa_constants->{$var} . '"');
    }

    return $nevada_isa_info;
}


sub
convert_to_c
{
    my $nevada_isa_info = shift;
    my $c_lines = shift;        # Reference to array of lines for *.c file
    my $h_lines = shift;        # Reference to array of lines for *.h file

    push(@$h_lines, "");
    push(@$h_lines, "/* Generic ISA Constants */");
    return format_hash_as_c_macros($nevada_isa_info->{isa_constants}, $h_lines,
      "MIPS32_");
}





sub
create_isa_constants
{
    my %constants;

    $constants{interrupt_sz} = 6;





    $constants{at_regnum} = 1;
    $constants{k0_regnum} = 26;
    $constants{k1_regnum} = 27;
    $constants{gp_regnum} = 28;
    $constants{sp_regnum} = 29;
    $constants{fp_regnum} = 30;
    $constants{ra_regnum} = 31;













    $constants{default_reset_paddr} = 0x1fc00000; 
    $constants{exception_boot_reset_offset} = 0x200;    # STATUS.BEV=1
    $constants{debug_probe_trap_disabled_reset_offset} = 0x480;



    $constants{debug_probe_trap_enabled_addr} = 0xff200200;


    $constants{tlb_refill_ebase_offset} = 0x000;           # STATUS.EXL=0
    $constants{cache_error_ebase_offset} = 0x100;
    $constants{general_exc_ebase_offset} = 0x180;
    $constants{vectored_interrupt_ebase_offset} = 0x200;   # CAUSE.IV=1

    return \%constants;
}

sub
eval_cmd
{
    my $cmd = shift;

    eval($cmd);
    if ($@) {
        &$error("nevada_isa.pm: eval($cmd) returns '$@'\n");
    }
}

1;
