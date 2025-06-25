/******************************************************************************
*                                                                             *
* License Agreement                                                           *
*                                                                             *
* Copyright (c) 2003-2009 Altera Corporation, San Jose, California, USA.      *
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
 * This is the interrupt exception entry point code, which calls the interrupt
 * handler.  It should be pulled in using a .globl from alt_irq_register.c.
 * This scheme is used so that if an interrupt is never registered, then this
 * code will not appear in the generated executable, thereby improving code
 * footprint.
 *
 * Assumes that caller-saved registers have already been saved by by code in
 * section .exceptions.entry in alt_exception_entry.S and that the following
 * registers contain the following values:
 *     r7    C0_Cause
 */

        /*
         * Explicitly allow the use of r1 (the assembler temporary register)
         * within this code. This register is normally reserved for the use of
         * the compiler.
         */
        .set noat

        /*
         * Pull in the exception handler register save code.
         */
        .globl alt_exception

        .globl alt_irq_entry
        .section .exceptions.entry.label, "xa"
alt_irq_entry:

        .section .exceptions.irqtest, "xa"

        /*
         * Check Cause.ExcCode to see if we are here because of an interrupt.
         * The exception code for interrupt is zero.
         */
        andi  r2, r7, M_CauseExcCode
        bne   r2, zero, .Lnot_irq

        .section .exceptions.irqhandler, "xa"

        /*
         * Now that all necessary registers have been preserved, call 
         * alt_irq_handler() to process the interrupts.
         */

        jal alt_irq_handler

        .section .exceptions.irqreturn, "xa"

        b    .Lexception_exit

        .section .exceptions.notirq.label, "xa"

.Lnot_irq:

        /*
         * Section .exceptions.exit is in alt_exception_entry.S
         * This restores all the caller-saved registers
         */

        .section .exceptions.exit.label
.Lexception_exit:
