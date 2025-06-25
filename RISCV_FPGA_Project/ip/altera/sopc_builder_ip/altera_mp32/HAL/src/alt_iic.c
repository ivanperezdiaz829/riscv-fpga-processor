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

/*
 * This file implements the HAL Enhanced interrupt API for MIPS processors
 * with an internal interrupt controller (IIC).
 *
 * If an EIC is present, the EIC device driver must provide these routines, 
 * because their operation will be specific to that EIC type. 
 */
#ifndef ALT_CPU_EIC_PRESENT

#include "alt_mips32.h"
#include "sys/alt_irq.h"
#include "priv/alt_iic_isr_register.h"
                            
/** @Function Description:  This function registers an interrupt handler. 
  * If the function is succesful, then the requested interrupt will be enabled upon 
  * return. Registering a NULL handler will disable the interrupt.
  * @API Type:              External
  * @param ic_id            Ignored.
  * @param irq              IRQ number
  * @return                 0 if successful, else error (-1)
  */
int alt_ic_isr_register(alt_u32 ic_id, alt_u32 irq, alt_isr_func isr, 
  void *isr_context, void *flags)
{
  return alt_iic_isr_register(ic_id, irq, isr, isr_context, flags);
}  
                        
/** @Function Description:  This function enables a single interrupt.
  * @API Type:              External
  * @param ic_id            Ignored.
  * @param irq              IRQ number
  * @return                 0 if successful, else error (-1)
  */
int alt_ic_irq_enable (alt_u32 ic_id, alt_u32 irq)
{
  alt_irq_context context;
  alt_u32 status;
  extern volatile alt_u32 alt_irq_active;

  context = alt_irq_disable_all();
  MIPS32_READ_STATUS(status);
  alt_irq_active |= (1 << irq);             /* Set IRQ in global mask */
  status &= ~M_StatusIM;                    /* Clear STATUS.IM */
  status |= alt_irq_active << S_StatusIM;   /* Set STATUS.IM to global mask */
  status |= context << S_StatusIE;          /* Restore STATUS.IE to original */
  MIPS32_WRITE_STATUS(status);
  MIPS32_EHB();

  return 0;
}

/** @Function Description:  This function disables a single interrupt.
  * @API Type:              External
  * @param ic_id            Ignored.
  * @param irq              IRQ number
  * @return                 0 if successful, else error (-1)
  */
int alt_ic_irq_disable(alt_u32 ic_id, alt_u32 irq)
{
  alt_irq_context context;
  alt_u32 status;
  extern volatile alt_u32 alt_irq_active;

  context = alt_irq_disable_all();
  MIPS32_READ_STATUS(status);
  alt_irq_active &= ~(1 << irq);            /* Clear IRQ in global mask */
  status &= ~M_StatusIM;                    /* Clear STATUS.IM */
  status |= alt_irq_active << S_StatusIM;   /* Set STATUS.IM to global mask */
  status |= context << S_StatusIE;          /* Restore STATUS.IE to original */
  MIPS32_WRITE_STATUS(status);
  MIPS32_EHB();

  return 0;
}

/** @Function Description:  This function to determine if corresponding
  *                         interrupt is enabled.
  * @API Type:              External
  * @param ic_id            Ignored.
  * @param irq              IRQ number
  * @return                 Zero if corresponding interrupt is disabled and
  *                         non-zero otherwise.
  */
alt_u32 alt_ic_irq_enabled(alt_u32 ic_id, alt_u32 irq)
{
    alt_u32 status;

    MIPS32_READ_STATUS(status);

    return (status & (0x1 << (irq + S_StatusIM))) ? 1: 0;
}

#endif /* ALT_CPU_EIC_PRESENT */
