/******************************************************************************
*                                                                             *
* License Agreement                                                           *
*                                                                             *
* Copyright (c) 2009 Altera Corporation, San Jose, California, USA.      *
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

#include "alt_mips32.h"
#include "system.h"

/*
 * This is the exception entry point code, which saves all the caller saved
 * registers and then handles the appropriate exception.  It should be pulled
 * in using a .globl from all the exception handler routines.  This scheme is
 * used so that if an interrupt is never registered, then this code will not
 * appear in the generated executable, thereby improving code footprint.
 */

        /*
         * Explicitly allow the use of r1 (the assembler temporary register)
         * within this code. This register is normally reserved for the use of
         * the assembler.
         */
        .set noat

        /*
         * The top and bottom of the exception stack
         */
#ifdef ALT_EXCEPTION_STACK

        .globl __alt_exception_stack_pointer

#ifdef ALT_STACK_CHECK

        .globl __alt_exception_stack_limit

        /*
         * We need to store the value of the stack limit after interrupt somewhere.
         */
        .globl  alt_exception_old_stack_limit

#endif /* ALT_STACK_CHECK */
#endif /* ALT_EXCEPTION_STACK */

        .section .exceptions.entry.label, "xa"

        .globl alt_exception
        .type alt_exception, @function
alt_exception:

        .section .exceptions.entry, "xa"

#ifdef ALT_EXCEPTION_STACK

#ifdef ALT_STACK_CHECK
        sw      k1, %gprel(alt_exception_old_stack_limit)(gp)
#endif /* ALT_STACK_CHECK */

        lui     k1, %hi(__alt_exception_stack_pointer - 80)
        addiu   k1, k1, %lo(__alt_exception_stack_pointer - 80) 
        sw      sp, 76(k1)
        move    sp, k1

#ifdef ALT_STACK_CHECK
        lui     k1, %hi(__alt_exception_stack_limit)
        addiu   k1, k1, %lo(__alt_exception_stack_limit) 
        sw      k1, %gprel(alt_stack_limit_value)(gp)
#endif /* ALT_STACK_CHECK */

#else /* !ALT_EXCEPTION_STACK */
        /* 
         * Process an exception.  For all exceptions we must preserve all
         * caller saved registers on the stack (See the MIPS32 ABI
         * documentation for details).
         */

        addiu   sp, sp, -72

#ifdef ALT_STACK_CHECK

        /* Stack has overflowed if sp < k1. */
        sltu k0, sp, k1
        bne  k0, zero, .Lstack_overflow

#endif /* ALT_STACK_CHECK */

#endif /* !ALT_EXCEPTION_STACK */

        sw   ra,  0(sp)
        sw   r1,  4(sp)
        sw   r2,  8(sp)
        sw   r3,  12(sp)
        sw   r4,  16(sp)
        sw   r5,  20(sp)
        sw   r6,  24(sp)
        sw   r7,  28(sp)

        /* Read these before required to avoid a potential pipeline stall. */
        mfc0 r5, C0_Status
        mfc0 r6, C0_EPC
        mfc0 r7, C0_Cause

        sw   r8,  32(sp)
        sw   r9,  36(sp)
        sw   r10, 40(sp)
        sw   r11, 44(sp)
        sw   r12, 48(sp)
        sw   r13, 52(sp)
        sw   r14, 56(sp)
        sw   r15, 60(sp)

        sw   r5,  64(sp)  /* status */
        sw   r6,  68(sp)  /* epc */

        /*
         * The interrupt testing code (.exceptions.irqtest) will be
         * linked here here. If an interrupt is active, it calls the HAL
         * IRQ handler (alt_irq_handler()) which successively calls
         * registered interrupt handler(s) until no interrupts remain
         * pending. It then jumps to .exceptions.exit. If there is no
         * interrupt then it continues to .exception.notirq, below.
         */

        .section .exceptions.notirq, "xa"

        /*
         * Prepare to service non-interrupt exceptions.  The code for this
         * is optionally linked into section .exceptions.soft,
         * which will preceed .exceptions.unknown below.
         *
         * Unlike interrupts, we want to skip the exception-causing instruction
         * upon completion, so we increment the EPC copy stored on the stack.
         */
        lw    r8, 68(sp)
        addiu r8, r8, 4
        sw    r8,  68(sp)

        /*
         * Other exception handling code, if enabled, will be linked here.
         * This includes a trap handler (that would typically
         * be augmented with user-specific code). These are not linked in by
         * default.
         */

        /*
         * In the context of linker sections, "unknown" are all exceptions
         * not handled by the built-in handlers above (interrupt and trap).
         *
         * Advanced exception types can be serviced by registering a handler.
         * To do so, enable the "Enable Instruction-related Exception API" HAL
         * BSP setting. If this setting is disabled, this handler code will
         * either break (if the debug port core is present) or enter an infinite
         * loop because we don't how how to handle the exception.
         */
        .section .exceptions.unknown
#ifdef ALT_INCLUDE_INSTRUCTION_RELATED_EXCEPTION_API
        /*
         * The C-based HAL routine alt_instruction_exception_entry() will
         * attempt to service the exception by calling a user-registered
         * exception handler using alt_instruction_exception_register().
         * If no handler was registered it will either break (if the
         * debugger is present) or go into an infinite loop since the
         * handling behavior is undefined; in that case we will not return here.
         */

        /* Load exception-causing address as first argument (r4) */
        lw     r4, 68(sp)

        /* Call the instruction-exception entry */
        jal   alt_instruction_exception_entry
        nop

        /*
         * If alt_instruction_exception_entry() returned, the exception was
         * serviced by a user-registered routine. Its return code (now in r2)
         * indicates whether to re-issue or skip the exception-causing
         * instruction.
         *
         * Return code was 0: Skip. The address of the instruction after the
         * exception is already stored in 68(sp).
         */
        bne   r2, r0, .Lexception_exit

        /*
         * Otherwise, decrement 68(sp) to re-issue the instruction that caused
         * the exception.
         */
        lw    r6, 68(sp)
        addiu r6, r6, -4
        sw    r6, 68(sp)

#else /* ALT_INCLUDE_INSTRUCTION_RELATED_EXCEPTION_API disabled */

        /*
         * We got here because an instruction-related exception occured, but the
         * handler API was not compiled in. We do not presume to know how to
         * handle it. If the debugger is present, break, otherwise hang.
         *
         *  If you get here then one of the following could have happened:
         *
         *  - An instruction-generated exception occured and you
         *    have not registered a handler using
         *    alt_instruction_exception_register().
         *
         *  Some examples of instruction-generated exceptions and why they
         *  might occur:
         *
         *  - Your program has executed a trap instruction, but has not
         *    implemented a handler for this instruction.
         *
         *  - Your program has executed an illegal instruction (one which is
         *    not defined in the instruction set).
         *
         *  - Your processor includes an MMU or MPU, and you have enabled it
         *    before registering an exception handler to service exceptions it
         *    generates.
         *
         * The problem could also be hardware related:
         *  - If your hardware is broken and is generating spurious interrupts
         *    (a peripheral which negates its interrupt output before its
         *    interrupt handler has been executed will cause spurious
         *    interrupts)
         */
#ifdef ALT_CPU_DEBUG_PORT_PRESENT
       /*
        *  Either tell the user now (if there is a debugger attached) or go into
        *  the debug monitor which will loop until a debugger is attached.
        */
        sdbbp
#else
       /*
        *  If there is no debug stub then a SDBBP instruction isn't available.
        *  An infinate loop will probably be more useful.
        */
0:
        b   0b
#endif /* ALT_CPU_DEBUG_PORT_PRESENT */

#endif /* ALT_INCLUDE_INSTRUCTION_RELATED_EXCEPTION_API */

        .section .exceptions.exit.label
.Lexception_exit:

        .section .exceptions.exit, "xa"

        /* 
         * Restore the saved registers, so that all general purpose registers 
         * have been restored to their state at the time the interrupt occured.
         */

        lw   r5,  64(sp)  /* status */
        lw   r6,  68(sp)  /* epc */
        lw   ra,   0(sp)

        mtc0 r5, C0_Status
        mtc0 r6, C0_EPC

        lw   r1,   4(sp)
        lw   r2,   8(sp)
        lw   r3,  12(sp)
        lw   r4,  16(sp)
        lw   r5,  20(sp)
        lw   r6,  24(sp)
        lw   r7,  28(sp)

#ifdef ALT_EXCEPTION_STACK
#ifdef ALT_STACK_CHECK
        lw   k1, %gprel(alt_exception_old_stack_limit)(gp)
#endif /* ALT_STACK_CHECK */
#endif /* ALT_EXCEPTION_STACK */

        lw   r8,  32(sp)
        lw   r9,  36(sp)
        lw   r10, 40(sp)
        lw   r11, 44(sp)
        lw   r12, 48(sp)
        lw   r13, 52(sp)
        lw   r14, 56(sp)
        lw   r15, 60(sp)

#ifdef ALT_EXCEPTION_STACK

#ifdef ALT_STACK_CHECK
        sw   k1, %gprel(alt_stack_limit_value)(gp)
        sw   zero, %gprel(alt_exception_old_stack_limit)(gp)
#endif /* ALT_STACK_CHECK */

        lw   sp,  72(sp)

#else /* !ALT_EXCEPTION_STACK */
        addiu  sp, sp, 72

#endif /* ALT_EXCEPTION_STACK */

        /*
         * Return to the interrupted instruction.
         */

        eret

#ifdef ALT_STACK_CHECK

.Lstack_overflow:
        sdbbp 3

#endif /* ALT_STACK_CHECK */
