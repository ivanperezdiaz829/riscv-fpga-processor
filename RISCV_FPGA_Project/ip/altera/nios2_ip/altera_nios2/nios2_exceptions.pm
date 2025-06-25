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






















package nios2_exceptions;
use Exporter;
@ISA = Exporter;
@EXPORT = qw(
    $none_exc
    $hbreak_exc
    $cpu_reset_exc
    $ext_intr_exc
    $norm_intr_exc
    $trap_inst_exc
    $unimp_inst_exc
    $illegal_inst_exc
    $break_inst_exc
    $misaligned_data_addr_exc
    $misaligned_target_pc_exc
    $div_error_exc
    $supervisor_inst_addr_exc
    $supervisor_inst_exc
    $supervisor_data_addr_exc
    $tlb_inst_miss_exc
    $tlb_data_miss_exc
    $tlb_x_perm_exc
    $tlb_r_perm_exc
    $tlb_w_perm_exc
    $mpu_inst_region_violation_exc
    $mpu_data_region_violation_exc
    $empty_slave_inst_access_error_exc
    $empty_slave_data_access_error_exc
    $readonly_slave_data_access_error_exc
    $ecc_itlb_error_exc
    $ecc_inst_error_exc
    $ecc_rf_error_exc
    $ecc_dtlb_error_exc
    $ecc_data_error_exc
    $ecc_dcache_async_error_exc
);

use cpu_utils;
use cpu_exception;

use strict;













our $none_exc;
our $hbreak_exc;
our $cpu_reset_exc;
our $ext_intr_exc;
our $norm_intr_exc;
our $trap_inst_exc;
our $unimp_inst_exc;
our $illegal_inst_exc;
our $break_inst_exc;
our $misaligned_data_addr_exc;
our $misaligned_target_pc_exc;
our $div_error_exc;
our $supervisor_inst_addr_exc;
our $supervisor_inst_exc;
our $supervisor_data_addr_exc;
our $tlb_inst_miss_exc;
our $tlb_data_miss_exc;
our $tlb_x_perm_exc;
our $tlb_r_perm_exc;
our $tlb_w_perm_exc;
our $mpu_inst_region_violation_exc;
our $mpu_data_region_violation_exc;
our $empty_slave_inst_access_error_exc;
our $empty_slave_data_access_error_exc;
our $readonly_slave_data_access_error_exc;
our $ecc_inst_error_exc;
our $ecc_itlb_error_exc;
our $ecc_rf_error_exc;
our $ecc_dtlb_error_exc;
our $ecc_data_error_exc;
our $ecc_dcache_async_error_exc;


our $NONE_EXC_ID;
our $HBREAK_EXC_ID;
our $CPU_RESET_EXC_ID;
our $EXT_INTR_EXC_ID;
our $NORM_INTR_EXC_ID;
our $TRAP_INST_EXC_ID;
our $UNIMP_INST_EXC_ID;
our $ILLEGAL_INST_EXC_ID;
our $BREAK_INST_EXC_ID;
our $MISALIGNED_DATA_ADDR_EXC_ID;
our $MISALIGNED_TARGET_PC_EXC_ID;
our $DIV_ERROR_EXC_ID;
our $SUPERVISOR_INST_ADDR_EXC_ID;
our $SUPERVISOR_INST_EXC_ID;
our $SUPERVISOR_DATA_ADDR_EXC_ID;
our $TLB_INST_MISS_EXC_ID;
our $TLB_DATA_MISS_EXC_ID;
our $TLB_X_PERM_EXC_ID;
our $TLB_R_PERM_EXC_ID;
our $TLB_W_PERM_EXC_ID;
our $MPU_INST_REGION_VIOLATION_EXC_ID;
our $MPU_DATA_REGION_VIOLATION_EXC_ID;
our $EMPTY_SLAVE_INST_ACCESS_ERROR_EXC_ID;
our $EMPTY_SLAVE_DATA_ACCESS_ERROR_EXC_ID;
our $READONLY_SLAVE_DATA_ACCESS_ERROR_EXC_ID;
our $ECC_ITLB_ERROR_EXC_ID;
our $ECC_INST_ERROR_EXC_ID;
our $ECC_RF_ERROR_EXC_ID;
our $ECC_DTLB_ERROR_EXC_ID;
our $ECC_DATA_ERROR_EXC_ID;
our $ECC_DCACHE_ASYNC_ERROR_EXC_ID;
our $NUM_EXC_IDS;








sub
validate_and_elaborate
{
    my $exception_constants = create_exception_constants();
    my $exceptions = create_exceptions($exception_constants);

    my $elaborated_exception_info = {
      exception_constants   => $exception_constants,
      exceptions            => $exceptions,
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
    format_hash_as_c_macros($constants, $h_lines);

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
    push(@$h_lines, "    int invalidatesInstValue; /* boolean */");
    push(@$h_lines, "} ExcInfo;");
    push(@$h_lines, "");
    push(@$h_lines, "extern ExcInfo excInfo[NUM_EXC_IDS];");
    push(@$h_lines, "#endif /* ALT_ASM_SRC */");

    push(@$c_lines, "");
    push(@$c_lines, "/* Exception information */");
    push(@$c_lines, "ExcInfo excInfo[NUM_EXC_IDS] = {");

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
        } elsif (get_exception_record_addr($exception) == $RECORD_NOTHING) {
            $recordAddr = "RECORD_NOTHING";
        } else {
            &$error("record_addr has unsupported value for '" .
              get_exception_name($exception) . "'");
        }
        push(@$c_lines, sprintf("        %s, /* recordAddr */", $recordAddr));

        push(@$c_lines, sprintf("        %d  /* invalidatesInstValue */", 
            get_exception_invalidates_inst_value($exception)));

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



    $constants{NONE_EXC_ID} = 0;                 # No exception active
    $constants{CPU_RESET_EXC_ID} = 1;            # CPU-only reset request
    $constants{HBREAK_EXC_ID} = 2;               # Hardware break
    $constants{EXT_INTR_EXC_ID} = 3;             # External interrupt
    $constants{NORM_INTR_EXC_ID} = 4;            # Normal interrupt
    $constants{TRAP_INST_EXC_ID} = 5;            # TRAP instruction
    $constants{UNIMP_INST_EXC_ID} = 6;           # Unimplemented instruction
    $constants{ILLEGAL_INST_EXC_ID} = 7;         # Illegal instruction
    $constants{BREAK_INST_EXC_ID} = 8;           # BREAK instruction
    $constants{MISALIGNED_DATA_ADDR_EXC_ID} = 9; # Misaligned data addr
    $constants{MISALIGNED_TARGET_PC_EXC_ID} = 10;# Misaligned target PC
    $constants{DIV_ERROR_EXC_ID} = 11;           # Division error
    $constants{SUPERVISOR_INST_ADDR_EXC_ID} = 12; # Supervisor-region fetch in 

    $constants{SUPERVISOR_INST_EXC_ID} = 13;     # Supervisor-only inst in user

    $constants{SUPERVISOR_DATA_ADDR_EXC_ID} = 14;# Supervisor-only data addr in

    $constants{TLB_INST_MISS_EXC_ID} = 15;       # TLB instruction miss 

    $constants{TLB_DATA_MISS_EXC_ID} = 16;       # TLB data miss (fast/double)
    $constants{TLB_X_PERM_EXC_ID} = 17;          # TLB execute perm violation
    $constants{TLB_R_PERM_EXC_ID} = 18;          # TLB read perm violation
    $constants{TLB_W_PERM_EXC_ID} = 19;          # TLB write perm violation
    $constants{MPU_INST_REGION_VIOLATION_EXC_ID} = 20;  # MPU inst region 

    $constants{MPU_DATA_REGION_VIOLATION_EXC_ID} = 21;  # MPU data region

    $constants{EMPTY_SLAVE_INST_ACCESS_ERROR_EXC_ID} = 22;  # Fetch from empty

    $constants{EMPTY_SLAVE_DATA_ACCESS_ERROR_EXC_ID} = 23;  # Load/store to

    $constants{READONLY_SLAVE_DATA_ACCESS_ERROR_EXC_ID} = 24;  # Write to 

    $constants{ECC_ITLB_ERROR_EXC_ID} = 25;   # ECC error on itlb
    $constants{ECC_INST_ERROR_EXC_ID} = 26;   # ECC error on inst
    $constants{ECC_RF_ERROR_EXC_ID} = 27;   # ECC error on rf
    $constants{ECC_DTLB_ERROR_EXC_ID} = 28;   # ECC error on dtlb
    $constants{ECC_DATA_ERROR_EXC_ID} = 29;   # ECC error on data
    $constants{ECC_DCACHE_ASYNC_ERROR_EXC_ID} = 30;   # ECC error on data
    $constants{NUM_EXC_IDS} = 31;


    $constants{RESET_CAUSE_CODE} = 0;                # Hard reset
    $constants{CPU_RESET_CAUSE_CODE} = 1;            # CPU-only reset request
    $constants{NORM_INTR_CAUSE_CODE} = 2;            # Normal interrupt
    $constants{TRAP_INST_CAUSE_CODE} = 3;            # TRAP instruction
    $constants{UNIMP_INST_CAUSE_CODE} = 4;           # Unimplemented instruction
    $constants{ILLEGAL_INST_CAUSE_CODE} = 5;         # Illegal instruction
    $constants{MISALIGNED_DATA_ADDR_CAUSE_CODE} = 6; # Misaligned data addr
    $constants{MISALIGNED_TARGET_PC_CAUSE_CODE} = 7; # Misaligned target PC
    $constants{DIV_ERROR_CAUSE_CODE} = 8;            # Division error
    $constants{SUPERVISOR_INST_ADDR_CAUSE_CODE} = 9; # Supervisor-region fetch

    $constants{SUPERVISOR_INST_CAUSE_CODE} = 10;     # Supervisor-only inst

    $constants{SUPERVISOR_DATA_ADDR_CAUSE_CODE} = 11;# Supervisor-only data addr

    $constants{TLB_MISS_CAUSE_CODE} = 12;            # TLB miss (fast/double)
    $constants{TLB_X_PERM_CAUSE_CODE} = 13;          # TLB execute perm 

    $constants{TLB_R_PERM_CAUSE_CODE} = 14;          # TLB read perm violation
    $constants{TLB_W_PERM_CAUSE_CODE} = 15;          # TLB write perm violation
    $constants{MPU_INST_REGION_VIOLATION_CAUSE_CODE} = 16;  # MPU inst region

    $constants{MPU_DATA_REGION_VIOLATION_CAUSE_CODE} = 17;  # MPU data region 

    $constants{ECC_TLB_ERROR_CAUSE_CODE} = 18;       # ECC error on TLB
    $constants{ECC_INST_ERROR_CAUSE_CODE} = 19;      # ECC error on inst
    $constants{ECC_RF_ERROR_CAUSE_CODE} = 20;        # ECC error on RF
    $constants{ECC_DATA_ERROR_CAUSE_CODE} = 21;      # ECC error on data access
    $constants{ECC_DCACHE_ASYNC_ERROR_CAUSE_CODE} = 22;      # ECC error on Dcache Async

    $constants{EMPTY_SLAVE_INST_ACCESS_ERROR_CAUSE_CODE} = 29; # Fetch from 

    $constants{EMPTY_SLAVE_DATA_ACCESS_ERROR_CAUSE_CODE} = 30; # Load/store to

    $constants{READONLY_SLAVE_DATA_ACCESS_ERROR_CAUSE_CODE} = 31; # Write to 

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
    $hbreak_exc = add_exception($exceptions, {
        name        => "hbreak",
        id          => manditory_int($constants, "HBREAK_EXC_ID"),
        priority    => 1
    });
    $cpu_reset_exc = add_exception($exceptions, {
        name        => "cpu_reset",
        id          => manditory_int($constants, "CPU_RESET_EXC_ID"),
        priority    => 2,
        cause_code  => manditory_int($constants, "CPU_RESET_CAUSE_CODE"),
    });
    $ecc_dcache_async_error_exc = add_exception($exceptions, {
        name        => "dcache_async_error",
        id          => manditory_int($constants, "ECC_DCACHE_ASYNC_ERROR_EXC_ID"),
        priority    => 3,
        cause_code  => manditory_int($constants, "ECC_DCACHE_ASYNC_ERROR_CAUSE_CODE"),
    });
    $ext_intr_exc = add_exception($exceptions, {
        name        => "ext_intr",
        id          => manditory_int($constants, "EXT_INTR_EXC_ID"),
        priority    => 4,
    });
    $norm_intr_exc = add_exception($exceptions, {
        name        => "norm_intr",
        id          => manditory_int($constants, "NORM_INTR_EXC_ID"),
        priority    => 5,
        cause_code  => manditory_int($constants, "NORM_INTR_CAUSE_CODE"),
    });
    $supervisor_inst_addr_exc = add_exception($exceptions, {
        name        => "super_inst_addr",
        id          => manditory_int($constants, "SUPERVISOR_INST_ADDR_EXC_ID"),
        priority    => 6,
        invalidates_inst_value  => 1,
        cause_code  => 
          manditory_int($constants, "SUPERVISOR_INST_ADDR_CAUSE_CODE"),
    });
    $ecc_itlb_error_exc = add_exception($exceptions, {
        name        => "ecc_itlb_error",
        id          => manditory_int($constants, "ECC_ITLB_ERROR_EXC_ID"),
        priority    => 7,
        invalidates_inst_value  => 1,
        cause_code  => manditory_int($constants, "ECC_TLB_ERROR_CAUSE_CODE"),
    });
    $tlb_inst_miss_exc = add_exception($exceptions, {
        name        => "tlb_inst_miss",
        id          => manditory_int($constants, "TLB_INST_MISS_EXC_ID"),
        priority    => 8,
        invalidates_inst_value  => 1,
        cause_code  => manditory_int($constants, "TLB_MISS_CAUSE_CODE"),
    });
    $tlb_x_perm_exc = add_exception($exceptions, {
        name        => "tlb_x_perm",
        id          => manditory_int($constants, "TLB_X_PERM_EXC_ID"),
        priority    => 9,
        invalidates_inst_value  => 1,
        cause_code  => manditory_int($constants, "TLB_X_PERM_CAUSE_CODE"),
    });
    $mpu_inst_region_violation_exc = add_exception($exceptions, {
        name        => "mpu_inst_region_violation",
        id          => manditory_int($constants, 
                         "MPU_INST_REGION_VIOLATION_EXC_ID"),
        priority    => 10,
        invalidates_inst_value  => 1,
        cause_code  => 
          manditory_int($constants, "MPU_INST_REGION_VIOLATION_CAUSE_CODE"),
    });
    $empty_slave_inst_access_error_exc = add_exception($exceptions, {
        name        => "empty_slave_inst_access_error",
        id          => manditory_int($constants, 
                         "EMPTY_SLAVE_INST_ACCESS_ERROR_EXC_ID"),
        priority    => 11,
        invalidates_inst_value  => 1,
        cause_code  => 
          manditory_int($constants, "EMPTY_SLAVE_INST_ACCESS_ERROR_CAUSE_CODE"),
    });
    $ecc_inst_error_exc = add_exception($exceptions, {
        name        => "ecc_inst_error",
        id          => manditory_int($constants, "ECC_INST_ERROR_EXC_ID"),
        priority    => 12,
        invalidates_inst_value  => 1,
        cause_code  => manditory_int($constants, "ECC_INST_ERROR_CAUSE_CODE"),
    });
    $ecc_rf_error_exc = add_exception($exceptions, {
        name        => "ecc_rf_error",
        id          => manditory_int($constants, "ECC_RF_ERROR_EXC_ID"),
        priority    => 13,
        cause_code  => manditory_int($constants, "ECC_RF_ERROR_CAUSE_CODE"),
    });
    $supervisor_inst_exc = add_exception($exceptions, {
        name        => "super_inst",
        id          => manditory_int($constants, "SUPERVISOR_INST_EXC_ID"),
        priority    => 14,
        cause_code  => manditory_int($constants, "SUPERVISOR_INST_CAUSE_CODE"),
    });
    $trap_inst_exc = add_exception($exceptions, {
        name        => "trap_inst",
        id          => manditory_int($constants, "TRAP_INST_EXC_ID"),
        priority    => 15, sub_priority => 0,
        cause_code  => manditory_int($constants, "TRAP_INST_CAUSE_CODE"),
    });
    $illegal_inst_exc = add_exception($exceptions, {
        name        => "illegal_inst",
        id          => manditory_int($constants, "ILLEGAL_INST_EXC_ID"),
        priority    => 15, sub_priority => 1,
        cause_code  => manditory_int($constants, "ILLEGAL_INST_CAUSE_CODE"),
    });
    $unimp_inst_exc = add_exception($exceptions, {
        name        => "unimp_inst",
        id          => manditory_int($constants, "UNIMP_INST_EXC_ID"),
        priority    => 15, sub_priority => 2,
        cause_code  => manditory_int($constants, "UNIMP_INST_CAUSE_CODE"),
    });
    $break_inst_exc = add_exception($exceptions, {
        name        => "break_inst",
        id          => manditory_int($constants, "BREAK_INST_EXC_ID"),
        priority    => 15, sub_priority => 3,
    });
    $supervisor_data_addr_exc = add_exception($exceptions, {
        name        => "super_data_addr",
        id          => manditory_int($constants, "SUPERVISOR_DATA_ADDR_EXC_ID"),
        priority    => 15, sub_priority => 4,
        cause_code  => 
          manditory_int($constants, "SUPERVISOR_DATA_ADDR_CAUSE_CODE"),
        record_addr => $RECORD_DATA_ADDR,
    });
    $misaligned_data_addr_exc = add_exception($exceptions, {
        name        => "misaligned_data_addr",
        id          => manditory_int($constants, "MISALIGNED_DATA_ADDR_EXC_ID"),
        priority    => 15, sub_priority => 5,
        cause_code  => 
          manditory_int($constants, "MISALIGNED_DATA_ADDR_CAUSE_CODE"),
        record_addr => $RECORD_DATA_ADDR,
    });
    $misaligned_target_pc_exc = add_exception($exceptions, {
        name        => "misaligned_target_pc",
        id          => manditory_int($constants, "MISALIGNED_TARGET_PC_EXC_ID"),
        priority    => 15, sub_priority => 6,
        cause_code  => 
          manditory_int($constants, "MISALIGNED_TARGET_PC_CAUSE_CODE"),
        record_addr => $RECORD_TARGET_PCB,
    });
    $div_error_exc = add_exception($exceptions, {
        name        => "div_error",
        id          => manditory_int($constants, "DIV_ERROR_EXC_ID"),
        priority    => 15, sub_priority => 7,
        cause_code  => manditory_int($constants, "DIV_ERROR_CAUSE_CODE"),
    });
    $ecc_dtlb_error_exc = add_exception($exceptions, {
        name        => "ecc_dtlb_error",
        id          => manditory_int($constants, "ECC_DTLB_ERROR_EXC_ID"),
        priority    => 16,
        cause_code  => manditory_int($constants, "ECC_TLB_ERROR_CAUSE_CODE"),
        record_addr => $RECORD_DATA_ADDR,
    });
    $tlb_data_miss_exc = add_exception($exceptions, {
        name        => "tlb_miss",
        id          => manditory_int($constants, "TLB_DATA_MISS_EXC_ID"),
        priority    => 17,
        cause_code  => manditory_int($constants, "TLB_MISS_CAUSE_CODE"),
        record_addr => $RECORD_DATA_ADDR,
    });
    $tlb_r_perm_exc = add_exception($exceptions, {
        name        => "tlb_r_perm",
        id          => manditory_int($constants, "TLB_R_PERM_EXC_ID"),
        priority    => 18, sub_priority => 0,
        cause_code  => manditory_int($constants, "TLB_R_PERM_CAUSE_CODE"),
        record_addr => $RECORD_DATA_ADDR,
    });
    $tlb_w_perm_exc = add_exception($exceptions, {
        name        => "tlb_w_perm",
        id          => manditory_int($constants, "TLB_W_PERM_EXC_ID"),
        priority    => 18, sub_priority => 1,
        cause_code  => manditory_int($constants, "TLB_W_PERM_CAUSE_CODE"),
        record_addr => $RECORD_DATA_ADDR,
    });
    $mpu_data_region_violation_exc = add_exception($exceptions, {
        name        => "mpu_data_region_violation",
        id          => manditory_int($constants, 
                         "MPU_DATA_REGION_VIOLATION_EXC_ID"),
        priority    => 19,
        cause_code  => 
          manditory_int($constants, "MPU_DATA_REGION_VIOLATION_CAUSE_CODE"),
        record_addr => $RECORD_DATA_ADDR,
    });
    $empty_slave_data_access_error_exc = add_exception($exceptions, {
        name        => "empty_slave_data_access_error",
        id          => manditory_int($constants, 
                         "EMPTY_SLAVE_DATA_ACCESS_ERROR_EXC_ID"),
        priority    => 20, sub_priority => 0,
        cause_code  => 
          manditory_int($constants, "EMPTY_SLAVE_DATA_ACCESS_ERROR_CAUSE_CODE"),
        record_addr => $RECORD_DATA_ADDR,
    });
    $readonly_slave_data_access_error_exc = add_exception($exceptions, {
        name        => "readonly_slave_data_access_error",
        id          => manditory_int($constants, 
                         "READONLY_SLAVE_DATA_ACCESS_ERROR_EXC_ID"),
        priority    => 20, sub_priority => 1,
        cause_code  => 
          manditory_int($constants, 
            "READONLY_SLAVE_DATA_ACCESS_ERROR_CAUSE_CODE"),
        record_addr => $RECORD_DATA_ADDR,
    });
    $ecc_data_error_exc = add_exception($exceptions, {
        name        => "ecc_data_error",
        id          => manditory_int($constants, "ECC_DATA_ERROR_EXC_ID"),
        priority    => 21,
        cause_code  => manditory_int($constants, "ECC_DATA_ERROR_CAUSE_CODE"),
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
