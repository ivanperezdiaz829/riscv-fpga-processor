/*
 * Copyright (c) 2009 Altera Corporation, San Jose, California, USA.  
 * All rights reserved.
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to 
 * deal in the Software without restriction, including without limitation the 
 * rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
 * sell copies of the Software, and to permit persons to whom the Software is 
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in 
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING 
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
 * DEALINGS IN THE SOFTWARE.
 * 
 * altera_mp32_irq.c - Support for MIPS32 internal interrupt controller.
 *
 */

#include "sys/alt_irq.h"
#include "altera_mp32_irq.h"
#include "alt_mips32.h"

/*
 * To initialize the internal interrupt controller, just clear the STATUS.IM
 * field so that all possible IRQs are disabled.
 */
void altera_mp32_irq_init(void) 
{
    alt_u32 status;

    MIPS32_READ_STATUS(status);

    status &= ~M_StatusIM;

    MIPS32_WRITE_STATUS(status);
    MIPS32_EHB();
}
