/******************************************************************************
*                                                                             *
* License Agreement                                                           *
*                                                                             *
* Copyright (c) 2008 Altera Corporation, San Jose, California, USA.           *
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
* Altera does not recommend, suggest or require that this reference design    *
* file be used in conjunction or combination with any other product.          *
******************************************************************************/
#include "sys/alt_exceptions.h"
#include "alt_mips32.h"
#include "alt_types.h"
#include "system.h"

/*
 * This file implements support for calling user-registered handlers for
 * instruction-generated exceptions. This handler could also be reached
 * in the event of a spurious interrupt.
 *
 * The handler code is optionally enabled through the "Enable
 * Instruction-related Exception API" HAL BSP setting, which will
 * define the macro below.
 */
#ifdef ALT_INCLUDE_INSTRUCTION_RELATED_EXCEPTION_API

/* Function pointer to exception callback routine */
alt_exception_result (*alt_instruction_exception_handler)
  (alt_exception_cause, alt_u32, alt_u32) = 0x0;

/* Link entry routine to .exceptions section */
int alt_instruction_exception_entry (alt_u32 exception_pc)
  __attribute__ ((section (".exceptions")));

/*
 * This is the entry point for instruction-generated exceptions handling.
 * This routine will be called by alt_exceptions_entry.S, after it determines
 * that an exception could not be handled by handlers that preceed that
 * of instruction-generated exceptions (such as interrupts).
 *
 * For this to function properly, you must register an exception handler
 * using alt_instruction_exception_register(). This routine will call
 * that handler if it has been registered. Absent a handler, it will
 * break break or hang as discussed below.
 */
int alt_instruction_exception_entry (alt_u32 exception_pc)
{
  alt_u32 cause, exc_code, bad_vaddr;

  MIPS32_READ_CAUSE(cause);
  exc_code = ((cause & M_CauseExcCode) >> S_CauseExcCode);

  MIPS32_READ_BAD_VADDR(bad_vaddr);

  if (alt_instruction_exception_handler) {
    /*
     * Call handler. Its return value indicates whether the exception-causing
     * instruction should be re-issued. The code that called us,
     * alt_eceptions_entry.S, will look at this value and adjust the ea
     * register as necessary
     */
    return alt_instruction_exception_handler(cause, exception_pc, bad_vaddr);
  }
  /*
   * We got here because an instruction-generated exception occured, but no
   * handler is present. We do not presume to know how to handle it. If the
   * debugger is present, break, otherwise hang.
   *
   * If you've reached here in the debugger, consider examining the
   * CAUSE register ExcCode bit-field, which was read into the 'exc_code'
   * variable above, and compare it against the exceptions-type enumeration
   * in alt_exceptions.h.
   *
   *  If you get here then one of the following could have happened:
   *
   *  - An instruction-generated exception occured and you have not
   *    registered a handler using alt_instruction_exception_register().
   *
   *  Some examples of instruction-generated exceptions and why they
   *  might occur:
   *
   *  - Your program has executed a trap instruction, but has not
   *    implemented a handler for this instruction.
   *
   *  - Your program has executed a reserved instruction (one which is
   *    not defined in the instruction set).
   *
   * The problem could also be hardware related:
   *  - If your hardware is broken and is generating spurious interrupts
   *    (a peripheral which negates its interrupt output before its
   *    interrupt handler has been executed will cause spurious interrupts)
   */
  else {
#ifdef ALT_CPU_DEBUG_PORT_PRESENT
    MIPS32_BREAK();
#else
    while(1)
      ;
#endif /* ALT_CPU_DEBUG_PORT_PRESENT */
  }

  /* // We should not get here. Remove compiler warning. */
  return MIPS32_EXCEPTION_RETURN_REISSUE_INST;
}

#endif /* ALT_INCLUDE_INSTRUCTION_RELATED_EXCEPTION_API */

/*
 * This routine indicates whether a particular exception cause will have
 * set a valid address into the BADVADDR register, which is included
 * in the arguments to a user-registered instruction-generated exception
 * handler. Many exception types do not set valid contents in BADVADDR;
 * this is a convenience routine to easily test the validity of that
 * argument in your handler.
 *
 * Arguments:
 * cause:  The cause enum which is the ExcCode field of the Cause register.
 *
 * Return: 1: BAD_VADDR (bad_addr argument to handler) is valid
 *         0: BAD_VADDR is not valid
 */
int alt_exception_cause_generated_bad_addr(alt_exception_cause cause)
{
  switch (cause) {
  case MIPS32_EXCEPTION_TLB_MODIFIED:
  case MIPS32_EXCEPTION_TLB_LOAD:
  case MIPS32_EXCEPTION_TLB_STORE:
  case MIPS32_EXCEPTION_LOAD_ADDR_ERROR:
  case MIPS32_EXCEPTION_STORE_ADDR_ERROR:
    return 1;

  default:
    return 0;
  }
}
