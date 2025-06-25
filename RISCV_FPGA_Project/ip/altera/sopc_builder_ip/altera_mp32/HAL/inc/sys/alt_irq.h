#ifndef __ALT_IRQ_H__
#define __ALT_IRQ_H__

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

/*
 * alt_irq.h is the MIPS32 specific implementation of the interrupt controller 
 * interface.
 */

#include <errno.h>

#include "alt_mips32.h"
#include "alt_types.h"

#ifdef __cplusplus
extern "C"
{
#endif /* __cplusplus */

/*
 * Macros used by alt_irq_enabled
 */

#define ALT_IRQ_ENABLED  1
#define ALT_IRQ_DISABLED 0  

/* 
 * number of available interrupts
 */

#define ALT_NIRQ MIPS32_NIRQ

/*
 * Used by alt_irq_disable_all() and alt_irq_enable_all().
 * Contains a boolean indicating if interrupts should be enabled.
 */

typedef int alt_irq_context;

/* ISR Prototype */
typedef void (*alt_isr_func)(void* isr_context);

/*
 * alt_irq_enabled can be called to determine if the processor's global
 * interrupt enable is asserted. The return value is zero if interrupts 
 * are disabled, and non-zero otherwise.
 *
 * Whether the internal or external interrupt controller is present, 
 * individual interrupts may still be disabled. Use the other API to query
 * a specific interrupt. 
 */
static ALT_INLINE int ALT_ALWAYS_INLINE alt_irq_enabled (void)
{
  int status;

  MIPS32_READ_STATUS (status);

  return status & M_StatusIE; 
}

/*
 * alt_irq_disable_all() inhibits all interrupts.
 * It returns the previous IRQ context which can be used to restore
 * the IRQ context to the original state before this routine was called.
 * The context is just the STATUS.IE bit.
 */
static ALT_INLINE alt_irq_context ALT_ALWAYS_INLINE 
       alt_irq_disable_all (void)
{
  alt_irq_context context;

  /* 
   * Invoke DI instruction. It returns the previous value of STATUS.IE.
   */
  MIPS32_DI_RETURN_IE(context);

  return context;
}

/*
 * alt_irq_enable_all() re-enable all interrupts that currently have registered
 * interrupt handlers (and which have not been masked by a call to 
 * alt_irq_disable()).
 * It accepts a context to restore the IRQ context to the original state.
 */
static ALT_INLINE void ALT_ALWAYS_INLINE 
       alt_irq_enable_all (alt_irq_context context)
{
    if (context) {
        MIPS32_EI();
    } else {
        MIPS32_DI();
    }
}

/*
 * The function alt_irq_init() is defined within the auto-generated file
 * alt_sys_init.c. This function calls the initilization macros for all
 * interrupt controllers in the system at config time, before any other
 * non-interrupt controller driver is initialized.
 *
 * The "base" parameter is ignored and only present for backwards-compatibility.
 * It is recommended that NULL is passed in for the "base" parameter.
 */
extern void alt_irq_init (const void* base);

/*
 * alt_irq_cpu_enable_interrupts() enables the CPU to start taking interrupts.
 */
static ALT_INLINE void ALT_ALWAYS_INLINE 
       alt_irq_cpu_enable_interrupts ()
{
  /* Set C0_STATUS to default value:
   *   - BEV=0 (normal exception vector location)
   *   - IM7..IM0=0 (all interrupts are masked)
   *   - UM=0 (kernel mode)
   *   - ERL=0 (non-error level)
   *   - EXL=0 (non-exception level)
   *   - IE=1 (interrupts enabled)
   */
  MIPS32_WRITE_STATUS(M_StatusIE);
  MIPS32_EHB();
}

/*
 * alt_ic_isr_register() can be used to register an interrupt handler. If the
 * function is succesful, then the requested interrupt will be enabled upon 
 * return.
 */
extern int alt_ic_isr_register(alt_u32 ic_id,
                        alt_u32 irq,
                        alt_isr_func isr,
                        void *isr_context,
                        void *flags);

/* 
 * alt_ic_irq_enable() and alt_ic_irq_disable() enable/disable a specific 
 * interrupt by using IRQ port and interrupt controller instance.
 */
int alt_ic_irq_enable (alt_u32 ic_id, alt_u32 irq);
int alt_ic_irq_disable(alt_u32 ic_id, alt_u32 irq);        

 /* 
 * alt_ic_irq_enabled() indicates whether a specific interrupt, as
 * specified by IRQ port and interrupt controller instance is enabled.
 */        
alt_u32 alt_ic_irq_enabled(alt_u32 ic_id, alt_u32 irq);

/*
 * alt_irq_pending() returns a bit list of the current pending interrupts.
 * This is used by alt_irq_handler() to determine which registered interrupt
 * handlers should be called.
 *
 * This routine is only available for interrupt compatibility mode.
 */
#ifndef ALT_CPU_EIC_PRESENT
static ALT_INLINE alt_u32 ALT_ALWAYS_INLINE alt_irq_pending (void)
{
  alt_u32 cause;
  alt_u32 status;

  MIPS32_READ_CAUSE(cause);
  MIPS32_READ_STATUS(status);

  /* Return CAUSE.IP field ANDed with STATUS.IM */
  return (cause & status & M_CauseIP) >> S_CauseIP;
}
#endif /* ALT_CPU_EIC_PRESENT */

#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif /* __ALT_IRQ_H__ */
