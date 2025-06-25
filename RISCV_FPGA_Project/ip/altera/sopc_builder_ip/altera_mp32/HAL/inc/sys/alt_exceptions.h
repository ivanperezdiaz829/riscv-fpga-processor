#ifndef __ALT_EXCEPTIONS_H__
#define __ALT_EXCEPTIONS_H__

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
******************************************************************************/
#include "alt_mips32.h"
#include "alt_types.h"
#include "system.h"

#ifdef __cplusplus
extern "C"
{
#endif /* __cplusplus */

/*
 * This file defines instruction-generated exception handling and registry
 * API, exception type enumeration, and handler return value enumeration for
 * MIPS32.
 */

/*
 * The following enumeration describes the value in COP0 Cause.ExcCode field.
 * Not all exception types will cause the processor to go to the general 
 * exception vector; these are provided for reference.
 */
enum alt_exception_cause_e {
  MIPS32_EXCEPTION_INTERRUPT        = EX_INT,   /* Interrupt */
  MIPS32_EXCEPTION_TLB_MODIFIED     = EX_MOD,   /* TLB modified */
  MIPS32_EXCEPTION_TLB_LOAD         = EX_TLBL,  /* TLB exception load/inst */
  MIPS32_EXCEPTION_TLB_STORE        = EX_TLBS,  /* TLB exception store */
  MIPS32_EXCEPTION_LOAD_ADDR_ERROR  = EX_ADEL,  /* Load/inst address error */
  MIPS32_EXCEPTION_STORE_ADDR_ERROR = EX_ADES,  /* Store address error */
  MIPS32_EXCEPTION_INST_BUS_ERROR   = EX_IBE,   /* Instruction bus error */
  MIPS32_EXCEPTION_DATA_BUS_ERROR   = EX_DBE,   /* Data bus error */
  MIPS32_EXCEPTION_SYSCALL_INST     = EX_SYS,   /* Syscall instruction */
  MIPS32_EXCEPTION_SDBBP_INST       = EX_BP,    /* Breakpoint instruction */
  MIPS32_EXCEPTION_RESERVED_INST    = EX_RI,    /* Reserved instruction */
  MIPS32_EXCEPTION_COP_UNUSABLE     = EX_CPU,   /* Coprocessor unusable */
  MIPS32_EXCEPTION_OVERFLOW         = EX_OV,    /* Overflow */
  MIPS32_EXCEPTION_TRAP_INST        = EX_TR,    /* Trap instruction */
  MIPS32_EXCEPTION_FLOAT            = EX_FPE,   /* Floating point exception */
  MIPS32_EXCEPTION_COP2             = EX_C2E,   /* COP2 exception */
  MIPS32_EXCEPTION_MDMX             = EX_MDMX,  /* MDMX exception */
  MIPS32_EXCEPTION_WATCH            = EX_WATCH, /* Watch exception */
  MIPS32_EXCEPTION_MCHECK           = EX_MCHECK, /* Machine check exception */
  MIPS32_EXCEPTION_THREAD           = EX_THREAD, /* MT Thread exception */
  MIPS32_EXCEPTION_CACHE_ERROR      = EX_CacheErr /* Cache error */
};
typedef enum alt_exception_cause_e alt_exception_cause;

/*
 * These define valid return values for a user-defined instruction-generated
 * exception handler. The handler should return one of these to indicate
 * whether to re-issue the instruction that triggered the exception, or to
 * skip it.
 */
enum alt_exception_result_e {
  MIPS32_EXCEPTION_RETURN_REISSUE_INST = 0,
  MIPS32_EXCEPTION_RETURN_SKIP_INST    = 1
};
typedef enum alt_exception_result_e alt_exception_result;

/*
 * alt_instruction_exception_register() can be used to register an exception
 * handler for instruction-generated exceptions that are not handled by the
 * built-in exception handler (i.e. for interrupts).
 *
 * The registry API is optionally enabled through the "Enable
 * Instruction-related Exception API" HAL BSP setting, which will
 * define the macro below.
 */
#ifdef ALT_INCLUDE_INSTRUCTION_RELATED_EXCEPTION_API
void alt_instruction_exception_register (
  alt_exception_result (*exception_handler)(
    alt_exception_cause cause,
    alt_u32 exception_pc,
    alt_u32 bad_addr) );
#endif /*ALT_INCLUDE_INSTRUCTION_RELATED_EXCEPTION_API */

/*
 * alt_exception_cause_generated_bad_addr() indicates whether a particular
 * exception cause value was from an exception-type that generated a valid
 * address in the BADVADDR register. The contents of BADVADDR is passed to
 * a user-registered exception handler in all cases, whether valid or not.
 * This routine should be called to validate the bad_addr argument to
 * your exception handler.
 */
int alt_exception_cause_generated_bad_addr(alt_exception_cause cause);

#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif /* __ALT_EXCEPTIONS_H__ */
