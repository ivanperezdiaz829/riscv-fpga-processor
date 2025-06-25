/******************************************************************************
*                                                                             *
* License Agreement                                                           *
*                                                                             *
* Copyright (c) 2009 Altera Corporation, San Jose, California, USA.           *
* All rights reserved.                                                        *
*                                                                             *
* Permission is hereby granted, free of charge, to any person obtaining a     *
* copy of this software and associated documentation files (the "Software"),  *
* to deal in the Software without restriction, including without limitation   *
* the rights to use, copy, modify, merge, publish, distribute, sublicense,    *
* and/or sell copies of the Software, and to permit persons to whom the       *
* Software is furnished to do so, subject to the following conditions:        *
*                                                                             *
* The above copyright notice and this permission notice shall be included in  *
* all copies or substantial portions of the Software.                         *
*                                                                             *
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR  *
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,    *
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE *
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER      *
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING     *
* FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER         *
* DEALINGS IN THE SOFTWARE.                                                   *
*                                                                             *
* This agreement shall be governed in all respects by the laws of the State   *
* of California and by the laws of the United States of America.              *
*                                                                             *
******************************************************************************/

#include "system.h"
#include "alt_mips32.h"

/* Setup header files to work with assembler code. */
#define ALT_ASM_SRC

/* Debug logging facility */
#include "sys/alt_log_printf.h"

/*************************************************************************\
|                                MACROS                                   |
\*************************************************************************/

/* Need to call alt_load() if any of these sections are being copied. */
#if defined(ALT_LOAD_COPY_RODATA) || defined(ALT_LOAD_COPY_RWDATA) || defined(ALT_LOAD_COPY_EXCEPTIONS)
#define CALL_ALT_LOAD
#endif

/*************************************************************************\
|                         EXTERNAL REFERENCES                             |
\*************************************************************************/

/*
 * The entry point for user code is either "main" in hosted mode, or
 * "alt_main" in standalone mode. These are explicitly referenced here,
 * to ensure they are built into the executable. This allows the user
 * to build them into libraries, rather than supplying them in object
 * files at link time.
 */
    .globl main
    .globl alt_main

/*
 * Create a reference to the software multiply/divide and trap handers,
 * so that if they are provided, they will appear in the executable.
 */
#ifndef ALT_NO_INSTRUCTION_EMULATION
    .globl alt_exception_muldiv
#endif
#ifdef ALT_TRAP_HANDLER
    .globl alt_exception_trap
#endif

/*
 * Linker defined symbols used to initialize bss.
 */
.globl __bss_start
.globl __bss_end

/*************************************************************************\
|                         RESET SECTION (.entry)                          |
\*************************************************************************/

/*
 * This is the reset entry point.
 */

    .section .entry, "xa"

/*
 * Some tools want to know where the reset vector is.
 * Code isn't always provided at the reset vector but at least the
 * __reset label always contains the reset vector address because
 * it is defined at the start of the .entry section.
 */

    .globl __reset
    .type __reset, @function
__reset:


/*
 * Initialize the instruction cache if present (i.e. size > 0) and
 * reset code is allowed unless optimizing for RTL simulation.
 * RTL simulations can ensure the instruction cache is already initialized
 * so skipping this loop speeds up RTL simulation.
 */

#if ALT_CPU_ICACHE_SIZE > 0 && defined(ALT_ALLOW_CODE_AT_RESET) && !defined(ALT_SIM_OPTIMIZE)
    .set noreorder

	/* Clear TagLo/TagHi registers in preparation for cache initialization. */
	mtc0 zero, C0_TagLo
	mtc0 zero, C0_TagHi
    ehb

    /* Set start address to first line below KSEG0 base address. */
    la r2, (A_K0BASE-ALT_CPU_ICACHE_LINE_SIZE)

    /* Set end address to highest line address. */
    la r3, A_K0BASE+ALT_CPU_ICACHE_SIZE-ALT_CPU_ICACHE_LINE_SIZE

0:
    /* Move up to the next line. */
    addiu r2, r2, ALT_CPU_ICACHE_LINE_SIZE

    /* Keep initialing lines until the highest address is reached. */
    bne r2, r3, 0b

    /* Write a zero tag to one I-cache line - in delay slot. */
	cache ICIndexStTag, 0(r2)

1:

    .set reorder

    /*
     * The following debug information tells the ISS not to run the loop above
     * but to perform its actions using faster internal code.
     */
    .pushsection .debug_alt_sim_info
    .int 1, 1, 0b, 1b
    .popsection
#endif /* Initialize Instruction Cache */

/*
 * Jump to the _start entry point in the .text section if reset code
 * is allowed or if optimizing for RTL simulation.
 */
#if defined(ALT_ALLOW_CODE_AT_RESET) || defined(ALT_SIM_OPTIMIZE)
    /* Jump to the _start entry point in the .text section. */
    la r2, _start
    jr r2

    .size __reset, . - __reset
#endif /* Jump to _start */

/*
 * When not using exit, provide an _exit symbol to prevent unresolved
 * references to _exit from the linker script.
 */
#ifdef ALT_NO_EXIT
    .globl _exit
_exit:
#endif

/*************************************************************************\
|                          TEXT SECTION (.text)                           |
\*************************************************************************/

/*
 * Start of the .text section, and also the code entry point when
 * the code is executed by a bootloader rather than directly from reset.
 */
    .section .text
    .align 2

    .globl _start
    .type _start, @function
_start:

/*
 * Ensure accesses to kseg0 are cacheable.
 */
    mfc0 r2, C0_Config
    ori r2, r2, (K_CacheAttrC << S_ConfigK0)
    mtc0 r2, C0_Config
    ehb

/*
 * Initialize the data cache if present (i.e. size > 0) and not
 * optimizing for RTL simulation.
 * RTL simulations can ensure the data cache is already initialized
 * so skipping this loop speeds up RTL simulation.
 */

#if ALT_CPU_DCACHE_SIZE > 0 && !defined(ALT_SIM_OPTIMIZE)
    .set noreorder

	/* Clear TagLo/TagHi registers in preparation for cache initialization. */
	mtc0 zero, C0_TagLo
	mtc0 zero, C0_TagHi
    ehb

    /* Set start address to first line below KSEG0 base address. */
    la r2, (A_K0BASE-ALT_CPU_DCACHE_LINE_SIZE)

    /* Set end address to highest line address. */
    la r3, A_K0BASE+ALT_CPU_DCACHE_SIZE-ALT_CPU_DCACHE_LINE_SIZE

0:
    /* Move up to the next line. */
    addiu r2, r2, ALT_CPU_DCACHE_LINE_SIZE

    /* Keep initialing lines until the highest address is reached. */
    bne r2, r3, 0b

    /* Write a zero tag to one D-cache line - in delay slot. */
	cache DCIndexStTag, 0(r2)

1:

    .set reorder

    /*
     * The following debug information tells the ISS not to run the loop above
     * but to perform its actions using faster internal code.
     */
    .pushsection .debug_alt_sim_info
    .int 2, 1, 0b, 1b
    .popsection

#endif /* Initialize Data Cache */

    /* Log that caches have been initialized. */
    ALT_LOG_PUTS(alt_log_msg_cache)

    /* Log that the stack pointer is about to be setup. */
    ALT_LOG_PUTS(alt_log_msg_stackpointer)

    /*
     * Now that the caches are initialized, set up the stack pointer.
     * The value provided by the linker is assumed to be correctly aligned.
     */
    la sp, __alt_stack_pointer

    /* Set up the global pointer. */
    la gp, _gp

/*
 * Clear the BSS if not optimizing for RTL simulation.
 *
 * This uses the symbols: __bss_start and __bss_end, which are defined
 * by the linker script. They mark the begining and the end of the bss
 * region. The linker script guarantees that these values are word aligned.
 */
#ifndef ALT_SIM_OPTIMIZE
    /* Log that the BSS is about to be cleared. */
    ALT_LOG_PUTS(alt_log_msg_bss)

    la r2, __bss_start
    la r3, __bss_end
    beq r2, r3, 1f

0:
    sw zero, 0(r2)
    addiu r2, r2, 4
    bltu r2, r3, 0b

1:

    /*
     * The following debug information tells the ISS not to run the loop above
     * but to perform its actions using faster internal code.
     */
    .pushsection .debug_alt_sim_info
    .int 3, 1, 0b, 1b
    .popsection
#endif /* ALT_SIM_OPTIMIZE */

/*
 * The alt_load() facility is normally used when there is no bootloader.
 * It copies some sections into RAM so it acts like a mini-bootloader.
 */
#ifdef CALL_ALT_LOAD

#ifdef ALT_STACK_CHECK
    /*
     * If the user has selected stack checking then we need to set up a safe
     * value in the stack limit register so that the relocation functions
     * don't think the stack has overflowed (the contents of the rwdata
     * section aren't defined until alt_load() has been called).
     */
    move   k1, zero
#endif /* ALT_STACK_CHECK */

    jal alt_load

#endif /* CALL_ALT_LOAD */

#ifdef ALT_STACK_CHECK
    /*
     * Set up the stack limit (if required).  The linker has set up the
     * copy of the variable which is in memory.
     */

    lw   k1, %gprel(alt_stack_limit_value)(gp)
#endif /* ALT_STACK_CHECK */

    /* Log that alt_main is about to be called. */
    ALT_LOG_PUTS(alt_log_msg_alt_main)

    /* Call the C entry point. It should never return. */
    jal alt_main

    /* Wait in infinite loop in case alt_main does return. */
alt_after_alt_main:
    b alt_after_alt_main

    .size _start, . - _start

/*
 * Add information about the stack base if stack overflow checking is enabled.
 */
#ifdef ALT_STACK_CHECK
    .globl  alt_stack_limit_value
    .section .sdata,"aws",@progbits
    .align  2
    .type   alt_stack_limit_value, @object
    .size   alt_stack_limit_value, 4
alt_stack_limit_value:
    .long   __alt_stack_limit
#endif /* ALT_STACK_CHECK */
