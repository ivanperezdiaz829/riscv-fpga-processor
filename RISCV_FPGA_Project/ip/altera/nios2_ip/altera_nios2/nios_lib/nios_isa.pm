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






















package nios_isa;
use Exporter;
@ISA = Exporter;
@EXPORT = qw(
    $iw_sz $regnum_sz
    $datapath_log2_sz $datapath_sz $datapath_lsb $datapath_msb
    $rf_addr_sz $rf_num_reg 
    $cache_max_bytes $cache_max_line_bytes $cache_min_line_bytes
    $NIOS_DISPLAY_INST_TRACE $NIOS_DISPLAY_MEM_TRAFFIC
    $mmu_present
    $tlb_present
    $mpu_present
);

use cpu_utils;
use cpu_bit_field;
use strict;













our $iw_sz;
our $regnum_sz;
our $datapath_log2_sz;
our $datapath_sz;
our $datapath_lsb;
our $datapath_msb;
our $rf_addr_sz;
our $rf_num_reg;
our $cache_max_bytes;
our $cache_max_line_bytes;
our $cache_min_line_bytes;
our $NIOS_DISPLAY_INST_TRACE;
our $NIOS_DISPLAY_MEM_TRAFFIC;

our $mmu_present;       # Virtual addressses exist and are mapped to physical
our $tlb_present;       # Uses a TLB to map virtual to physical
our $mpu_present;       # No concept of virtual address




sub
validate_and_elaborate
{
    my $local_mmu_present = shift;
    my $local_tlb_present = shift;
    my $local_mpu_present = shift;

    assert_scalar($local_mmu_present, "local_mmu_present") || return undef;
    assert_scalar($local_tlb_present, "local_tlb_present") || return undef;
    assert_scalar($local_mpu_present, "local_mpu_present") || return undef;

    if ($local_tlb_present && !$local_mmu_present) {
        &$error("tlb_present is true but mmu_present is false");
    }

    my $isa_constants = 
      create_isa_constants($local_mmu_present, $local_tlb_present, 
        $local_mpu_present);


    my $isa_info = {
      isa_constants => $isa_constants,
    };



    foreach my $var (keys(%$isa_constants)) {
        eval_cmd('$' . $var . ' = "' . $isa_constants->{$var} . '"');
    }

    return $isa_info;
}


sub
convert_to_c
{
    my $isa_info = shift;
    my $c_lines = shift;        # Reference to array of lines for *.c file
    my $h_lines = shift;        # Reference to array of lines for *.h file

    push(@$h_lines, "");
    push(@$h_lines, "#ifndef _NIOS_ISA_CONSTANTS_");
    push(@$h_lines, "#define _NIOS_ISA_CONSTANTS_");
    push(@$h_lines, "/* Nios-based CPU ISA Constants */");


    my %constants = %{$isa_info->{isa_constants}};

    delete($constants{mmu_present});
    delete($constants{mpu_present});

    format_hash_as_c_macros(\%constants, $h_lines) || return undef;

    push(@$h_lines, "#endif /* _NIOS_ISA_CONSTANTS_ */");

    return 1;   # Some defined value
}





sub
create_isa_constants
{
    my $local_mmu_present = shift;
    my $local_tlb_present = shift;
    my $local_mpu_present = shift;

    my %constants;


    $constants{iw_sz} = 32;        


    $constants{regnum_sz} = 5;     


    $constants{datapath_log2_sz} = 5;
    $constants{datapath_sz} = (1 << $constants{datapath_log2_sz});
    $constants{datapath_lsb} = 0;
    $constants{datapath_msb} = 
      $constants{datapath_lsb} + $constants{datapath_sz} - 1;
    

    $constants{rf_addr_sz} = $constants{regnum_sz}; # Addr bits
    $constants{rf_num_reg} = 1 << $constants{rf_addr_sz}; # Num regs




    $constants{cache_max_bytes} = 65536;
    $constants{cache_max_line_bytes} = 32;
    $constants{cache_min_line_bytes} = 4;



    $constants{NIOS_DISPLAY_INST_TRACE} = (0x1 << 0);
    $constants{NIOS_DISPLAY_MEM_TRAFFIC} = (0x1 << 1);

    $constants{mmu_present} = $local_mmu_present ? 1 : 0;
    $constants{tlb_present} = $local_tlb_present ? 1 : 0;
    $constants{mpu_present} = $local_mpu_present ? 1 : 0;
    
    return \%constants;
}

sub
eval_cmd
{
    my $cmd = shift;

    eval($cmd);
    if ($@) {
        &$error("nios_isa.pm: eval($cmd) returns '$@'\n");
    }
}

1;
