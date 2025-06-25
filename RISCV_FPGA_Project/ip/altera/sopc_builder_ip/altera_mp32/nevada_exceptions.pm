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






















package nevada_exceptions;
use Exporter;
@ISA = Exporter;
@EXPORT = qw(
    $none_exc
    $soft_reset_exc
    $debug_single_step_exc
    $debug_interrupt_exc
    $debug_hwbp_exc
    $nmi_exc
    $machine_check_exc
    $interrupt_exc
    $inst_addr_err_exc
    $tlb_inst_refill_exc
    $tlb_inst_invalid_exc
    $sdbpp_inst_exc
    $cop0_unusable_exc
    $cop1_unusable_exc
    $cop2_unusable_exc
    $reserved_inst_exc
    $arith_overflow_exc
    $trap_inst_exc
    $syscall_inst_exc
    $break_inst_exc
    $load_addr_err_exc
    $store_addr_err_exc
    $tlb_load_refill_exc
    $tlb_load_invalid_exc
    $tlb_store_refill_exc
    $tlb_store_invalid_exc
    $tlb_store_mod_exc
);

use cpu_utils;
use cpu_exception;
use nevada_common;
use strict;













our $none_exc;
our $soft_reset_exc;
our $debug_single_step_exc;
our $debug_interrupt_exc;
our $debug_hwbp_exc;
our $nmi_exc;
our $machine_check_exc;
our $interrupt_exc;
our $inst_addr_err_exc;
our $tlb_inst_refill_exc;
our $tlb_inst_invalid_exc;
our $sdbpp_inst_exc;
our $cop0_unusable_exc;
our $cop1_unusable_exc;
our $cop2_unusable_exc;
our $reserved_inst_exc;
our $arith_overflow_exc;
our $trap_inst_exc;
our $syscall_inst_exc;
our $break_inst_exc;
our $load_addr_err_exc;
our $store_addr_err_exc;
our $tlb_load_refill_exc;
our $tlb_load_invalid_exc;
our $tlb_store_refill_exc;
our $tlb_store_invalid_exc;
our $tlb_store_mod_exc;


our $NONE_EXC_ID;
our $SOFT_RESET_EXC_ID;
our $DEBUG_SINGLE_STEP_EXC_ID;
our $DEBUG_INTERRUPT_EXC_ID;
our $DEBUG_HWBP_EXC_ID;
our $NMI_EXC_ID;
our $MACHINE_CHECK_EXC_ID;
our $INTERRUPT_EXC_ID;
our $INST_ADDR_ERR_EXC_ID;
our $TLB_INST_REFILL_EXC_ID;
our $TLB_INST_INVALID_EXC_ID;
our $SDBBP_INST_EXC_ID;
our $COP0_UNUSABLE_EXC_ID;
our $COP1_UNUSABLE_EXC_ID;
our $COP2_UNUSABLE_EXC_ID;
our $RESERVED_INST_EXC_ID;
our $ARITH_OVERFLOW_EXC_ID;
our $TRAP_INST_EXC_ID;
our $SYSCALL_INST_EXC_ID;
our $BREAK_INST_EXC_ID;
our $LOAD_ADDR_ERR_EXC_ID;
our $STORE_ADDR_ERR_EXC_ID;
our $TLB_LOAD_REFILL_EXC_ID;
our $TLB_LOAD_INVALID_EXC_ID;
our $TLB_STORE_REFILL_EXC_ID;
our $TLB_STORE_INVALID_EXC_ID;
our $TLB_STORE_MOD_EXC_ID;








sub
validate_and_elaborate
{
    my $exception_constants = create_exception_constants();
    my $exceptions = create_exceptions($exception_constants);

    my $elaborated_exception_info = {
      exception_constants   => $exception_constants,
      exceptions            => $exceptions,
      advanced_exc          => 1,
    };

    return $elaborated_exception_info;
}


sub
convert_to_c
{
    my $elaborated_exception_info = shift;
    my $c_lines = shift;        # Reference to array of lines for *.c file
    my $h_lines = shift;        # Reference to array of lines for *.h file

    my $constants = 
      manditory_hash($elaborated_exception_info, "exception_constants");
    my $exceptions = 
      manditory_array($elaborated_exception_info, "exceptions");

    push(@$h_lines, "");
    push(@$h_lines, "/* Exception Constants */");
    format_hash_as_c_macros($constants, $h_lines, $global_prefix);

    my $num_exc_ids = manditory_int($constants, "NUM_EXC_IDS");

    push(@$h_lines, "");
    push(@$h_lines, "/* Exception Information */");
    push(@$h_lines, "#ifndef ALT_ASM_SRC");
    push(@$h_lines, "typedef struct {");
    push(@$h_lines, "    const char* name;");
    push(@$h_lines, "    int priority;");
    push(@$h_lines, "    int subPriority; /* -1 if none */");
    push(@$h_lines, "    int causeId; /* -1 if none */");
    push(@$h_lines, "    int recordAddr;");
    push(@$h_lines, "} Mips32ExcInfo;");
    push(@$h_lines, "");
    push(@$h_lines, 
      "extern Mips32ExcInfo ${global_prefix}exc_info[MIPS32_NUM_EXC_IDS];");
    push(@$h_lines, "#endif /* ALT_ASM_SRC */");

    push(@$c_lines, "");
    push(@$c_lines, "/* Exception information */");
    push(@$c_lines, 
      "Mips32ExcInfo ${global_prefix}exc_info[MIPS32_NUM_EXC_IDS] = {");

    for (my $excId = 0; $excId < $num_exc_ids; $excId++) {
        my $exception = get_exception_by_id($exceptions, $excId);

        push(@$c_lines, sprintf("    { /* excId=%d */", $excId));
        push(@$c_lines, sprintf("        \"%s\", /* name */", 
          get_exception_name($exception)));
        push(@$c_lines, sprintf("        %d, /* priority */", 
          get_exception_priority($exception)));
        push(@$c_lines, sprintf("        %d, /* subPriority */", 
          defined(get_exception_sub_priority($exception)) ?
            get_exception_sub_priority($exception) :
            -1));
        push(@$c_lines, sprintf("        %d, /* causeId */", 
          defined(get_exception_cause_code($exception)) ?
            get_exception_cause_code($exception) :
            -1));

        my $recordAddr;
        if (get_exception_record_addr($exception) == $RECORD_TARGET_PCB) {
            $recordAddr = "RECORD_TARGET_PCB";    
        } elsif (get_exception_record_addr($exception) == $RECORD_DATA_ADDR) {
            $recordAddr = "RECORD_DATA_ADDR";    
        } elsif (get_exception_record_addr($exception) == $RECORD_INST_ADDR) {
            $recordAddr = "RECORD_INST_ADDR";    
        } elsif (get_exception_record_addr($exception) == $RECORD_NOTHING) {
            $recordAddr = "RECORD_NOTHING";
        } else {
            &$error("record_addr has unsupported value for '" .
              get_exception_name($exception) . "'");
        }
        push(@$c_lines, sprintf("        MIPS32_%s /* recordAddr */",
          $recordAddr));

        if ($excId < ($num_exc_ids-1)) {
            push(@$c_lines, "    },");
        } else {
            push(@$c_lines, "    }");
        }
    }
    push(@$c_lines, "};");
}






sub
create_exception_constants
{
    my %constants;

    $constants{RECORD_NOTHING} = $RECORD_NOTHING;
    $constants{RECORD_TARGET_PCB} = $RECORD_TARGET_PCB;
    $constants{RECORD_DATA_ADDR} = $RECORD_DATA_ADDR;
    $constants{RECORD_INST_ADDR} = $RECORD_INST_ADDR;







    $constants{NONE_EXC_ID} = 0;


    $constants{SOFT_RESET_EXC_ID} = 1;


    $constants{DEBUG_SINGLE_STEP_EXC_ID} = 2;


    $constants{DEBUG_INTERRUPT_EXC_ID} = 3;


    $constants{NMI_EXC_ID} = 4;


    $constants{MACHINE_CHECK_EXC_ID} = 5;


    $constants{INTERRUPT_EXC_ID} = 6;



    $constants{INST_ADDR_ERR_EXC_ID} = 7;



    $constants{TLB_INST_REFILL_EXC_ID} = 8;


    $constants{TLB_INST_INVALID_EXC_ID} = 9;


    $constants{SDBBP_INST_EXC_ID} = 10;


    $constants{COP0_UNUSABLE_EXC_ID} = 11;



    $constants{COP1_UNUSABLE_EXC_ID} = 12;


    $constants{COP2_UNUSABLE_EXC_ID} = 13;


    $constants{RESERVED_INST_EXC_ID} = 14;


    $constants{ARITH_OVERFLOW_EXC_ID} = 15;


    $constants{TRAP_INST_EXC_ID} = 16;


    $constants{SYSCALL_INST_EXC_ID} = 17;


    $constants{BREAK_INST_EXC_ID} = 18;



    $constants{LOAD_ADDR_ERR_EXC_ID} = 19;



    $constants{STORE_ADDR_ERR_EXC_ID} = 20;



    $constants{TLB_LOAD_REFILL_EXC_ID} = 21;


    $constants{TLB_LOAD_INVALID_EXC_ID} = 22;



    $constants{TLB_STORE_REFILL_EXC_ID} = 23;


    $constants{TLB_STORE_INVALID_EXC_ID} = 24;


    $constants{TLB_STORE_MOD_EXC_ID} = 25;

    $constants{NUM_EXC_IDS} = 26;


    $constants{DEBUG_HWBP_EXC_ID} = 27;







    $constants{INTERRUPT_CAUSE_CODE} = 0;



    $constants{TLB_MOD_CAUSE_CODE} = 1;          




    $constants{TLB_READ_CAUSE_CODE} = 2;




    $constants{TLB_WRITE_CAUSE_CODE} = 3;




    $constants{READ_ADDR_ERR_CAUSE_CODE} = 4;




    $constants{WRITE_ADDR_ERR_CAUSE_CODE} = 5;



    $constants{INST_BUS_ERR_CAUSE_CODE} = 6;



    $constants{DATA_BUS_ERR_CAUSE_CODE} = 7;



    $constants{SYSCALL_INST_CAUSE_CODE} = 8;








    $constants{BREAK_INST_CAUSE_CODE} = 9;



    $constants{RESERVED_INST_CAUSE_CODE} = 10;



    $constants{COP_UNUSABLE_CAUSE_CODE} = 11;



    $constants{ARITH_OVERFLOW_CAUSE_CODE} = 12;



    $constants{TRAP_INST_CAUSE_CODE} = 13;



    $constants{FP_CAUSE_CODE} = 15;



    $constants{COP2_CAUSE_CODE} = 18;



    $constants{MDMX_UNUSABLE_CAUSE_CODE} = 22;



    $constants{WATCH_CAUSE_CODE} = 23;



    $constants{MACHINE_CHECK_CAUSE_CODE} = 24;



    $constants{THREAD_CAUSE_CODE} = 25;






    $constants{CACHE_ERR_CAUSE_CODE} = 30;

    $constants{MAX_CAUSE_CODE} = 31;

    return \%constants;
}



sub
create_exceptions
{
    my $constants = shift;

    my $exceptions = [];

    $none_exc = add_exception($exceptions, {
        name        => "none",
        id          => manditory_int($constants, "NONE_EXC_ID"),
        priority    => 0,
    });
    $soft_reset_exc = add_exception($exceptions, {
        name        => "soft_reset",
        id          => manditory_int($constants, "SOFT_RESET_EXC_ID"),
        priority    => 1,
    });
    $debug_single_step_exc = add_exception($exceptions, {
        name        => "debug_single_step",
        id          => manditory_int($constants, "DEBUG_SINGLE_STEP_EXC_ID"),
        priority    => 2,
        sub_priority => 0,
    });
    $debug_hwbp_exc = add_exception($exceptions, {
        name        => "debug_hwbp",
        id          => manditory_int($constants, "DEBUG_HWBP_EXC_ID"),
        priority    => 2,
        sub_priority => 2,
    });
    $debug_interrupt_exc = add_exception($exceptions, {
        name        => "debug_interrupt",
        id          => manditory_int($constants, "DEBUG_INTERRUPT_EXC_ID"),
        priority    => 2,
        sub_priority => 1,
    });
    $nmi_exc = add_exception($exceptions, {
        name        => "nmi",
        id          => manditory_int($constants, "NMI_EXC_ID"),
        priority    => 3,
    });
    $machine_check_exc = add_exception($exceptions, {
        name        => "machine_check",
        id          => manditory_int($constants, "MACHINE_CHECK_EXC_ID"),
        priority    => 4,
        cause_code  => manditory_int($constants, "MACHINE_CHECK_CAUSE_CODE"),
    });
    $interrupt_exc = add_exception($exceptions, {
        name        => "interrupt",
        id          => manditory_int($constants, "INTERRUPT_EXC_ID"),
        priority    => 5,
        cause_code  => manditory_int($constants, "INTERRUPT_CAUSE_CODE"),
    });
    $inst_addr_err_exc = add_exception($exceptions, {
        name        => "inst_addr_err",
        id          => manditory_int($constants, "INST_ADDR_ERR_EXC_ID"),
        priority    => 6,
        invalidates_inst_value  => 1,
        cause_code  => manditory_int($constants, "READ_ADDR_ERR_CAUSE_CODE"),
        record_addr => $RECORD_INST_ADDR,
    });
    $tlb_inst_refill_exc = add_exception($exceptions, {
        name        => "tlb_inst_refill",
        id          => manditory_int($constants, "TLB_INST_REFILL_EXC_ID"),
        priority    => 7,
        invalidates_inst_value  => 1,
        cause_code  => manditory_int($constants, "TLB_READ_CAUSE_CODE"),
        record_addr => $RECORD_INST_ADDR,
    });
    $tlb_inst_invalid_exc = add_exception($exceptions, {
        name        => "tlb_inst_invalid",
        id          => manditory_int($constants, "TLB_INST_INVALID_EXC_ID"),
        priority    => 8,
        invalidates_inst_value  => 1,
        cause_code  => manditory_int($constants, "TLB_READ_CAUSE_CODE"),
        record_addr => $RECORD_INST_ADDR,
    });
    $sdbpp_inst_exc = add_exception($exceptions, {
        name        => "sdbpp_inst",
        id          => manditory_int($constants, "SDBBP_INST_EXC_ID"),
        priority    => 9,
        sub_priority => 0,
        cause_code  => manditory_int($constants, "BREAK_INST_CAUSE_CODE"),
    });
    $cop0_unusable_exc = add_exception($exceptions, {
        name        => "cop0_unusable",
        id          => manditory_int($constants, "COP0_UNUSABLE_EXC_ID"),
        priority    => 9,
        sub_priority => 1,
        cause_code  => manditory_int($constants, "COP_UNUSABLE_CAUSE_CODE"),
    });
    $cop1_unusable_exc = add_exception($exceptions, {
        name        => "cop1_unusable",
        id          => manditory_int($constants, "COP1_UNUSABLE_EXC_ID"),
        priority    => 9,
        sub_priority => 2,
        cause_code  => manditory_int($constants, "COP_UNUSABLE_CAUSE_CODE"),
    });
    $cop2_unusable_exc = add_exception($exceptions, {
        name        => "cop2_unusable",
        id          => manditory_int($constants, "COP2_UNUSABLE_EXC_ID"),
        priority    => 9,
        sub_priority => 3,
        cause_code  => manditory_int($constants, "COP_UNUSABLE_CAUSE_CODE"),
    });
    $reserved_inst_exc = add_exception($exceptions, {
        name        => "reserved_inst",
        id          => manditory_int($constants, "RESERVED_INST_EXC_ID"),
        priority    => 9,
        sub_priority => 4,
        cause_code  => manditory_int($constants, "RESERVED_INST_CAUSE_CODE"),
    });
    $arith_overflow_exc = add_exception($exceptions, {
        name        => "arith_overflow",
        id          => manditory_int($constants, "ARITH_OVERFLOW_EXC_ID"),
        priority    => 9,
        sub_priority => 5,
        cause_code  => manditory_int($constants, "ARITH_OVERFLOW_CAUSE_CODE"),
    });
    $trap_inst_exc = add_exception($exceptions, {
        name        => "trap_inst",
        id          => manditory_int($constants, "TRAP_INST_EXC_ID"),
        priority    => 9,
        sub_priority => 6,
        cause_code  => manditory_int($constants, "TRAP_INST_CAUSE_CODE"),
    });
    $syscall_inst_exc = add_exception($exceptions, {
        name        => "syscall_inst",
        id          => manditory_int($constants, "SYSCALL_INST_EXC_ID"),
        priority    => 9,
        sub_priority => 7,
        cause_code  => manditory_int($constants, "SYSCALL_INST_CAUSE_CODE"),
    });
    $break_inst_exc = add_exception($exceptions, {
        name        => "break_inst",
        id          => manditory_int($constants, "BREAK_INST_EXC_ID"),
        priority    => 9,
        sub_priority => 8,
        cause_code  => manditory_int($constants, "BREAK_INST_CAUSE_CODE"),
    });
    $load_addr_err_exc = add_exception($exceptions, {
        name        => "load_addr_err",
        id          => manditory_int($constants, "LOAD_ADDR_ERR_EXC_ID"),
        priority    => 9,
        sub_priority => 9,
        cause_code  => manditory_int($constants, "READ_ADDR_ERR_CAUSE_CODE"),
        record_addr => $RECORD_DATA_ADDR,
    });
    $store_addr_err_exc = add_exception($exceptions, {
        name        => "store_addr_err",
        id          => manditory_int($constants, "STORE_ADDR_ERR_EXC_ID"),
        priority    => 9,
        sub_priority => 10,
        cause_code  => manditory_int($constants, "WRITE_ADDR_ERR_CAUSE_CODE"),
        record_addr => $RECORD_DATA_ADDR,
    });
    $tlb_load_refill_exc = add_exception($exceptions, {
        name        => "tlb_load_refill",
        id          => manditory_int($constants, "TLB_LOAD_REFILL_EXC_ID"),
        priority    => 10,
        sub_priority => 0,
        cause_code  => manditory_int($constants, "TLB_READ_CAUSE_CODE"),
        record_addr => $RECORD_DATA_ADDR,
    });
    $tlb_store_refill_exc = add_exception($exceptions, {
        name        => "tlb_store_refill",
        id          => manditory_int($constants, "TLB_STORE_REFILL_EXC_ID"),
        priority    => 10,
        sub_priority => 1,
        cause_code  => manditory_int($constants, "TLB_WRITE_CAUSE_CODE"),
        record_addr => $RECORD_DATA_ADDR,
    });
    $tlb_load_invalid_exc = add_exception($exceptions, {
        name        => "tlb_load_invalid",
        id          => manditory_int($constants, "TLB_LOAD_INVALID_EXC_ID"),
        priority    => 11,
        sub_priority => 0,
        cause_code  => manditory_int($constants, "TLB_READ_CAUSE_CODE"),
        record_addr => $RECORD_DATA_ADDR,
    });
    $tlb_store_invalid_exc = add_exception($exceptions, {
        name        => "tlb_store_invalid",
        id          => manditory_int($constants, "TLB_STORE_INVALID_EXC_ID"),
        priority    => 11,
        sub_priority => 1,
        cause_code  => manditory_int($constants, "TLB_WRITE_CAUSE_CODE"),
        record_addr => $RECORD_DATA_ADDR,
    });
    $tlb_store_mod_exc = add_exception($exceptions, {
        name        => "tlb_store_mod",
        id          => manditory_int($constants, "TLB_STORE_MOD_EXC_ID"),
        priority    => 12,
        cause_code  => manditory_int($constants, "TLB_MOD_CAUSE_CODE"),
        record_addr => $RECORD_DATA_ADDR,
    });

    return $exceptions;
}



sub
add_exception
{
    my $exceptions = shift;
    my $props = shift;

    my $name = not_empty_scalar($props, "name");
    my $id = manditory_int($props, "id");

    if (defined(get_exception_by_name_or_undef($exceptions, $name))) {
        return &$error("Exception name '$name' already exists");
    }

    if (defined(get_exception_by_id_or_undef($exceptions, $id))) {
        return &$error("Exception ID '$id' (name is '$name') already exists");
    }

    my $exception = create_exception($props);


    push(@$exceptions, $exception);

    return $exception;
}

1;
