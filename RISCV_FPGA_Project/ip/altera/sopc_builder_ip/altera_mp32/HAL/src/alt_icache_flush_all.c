/******************************************************************************
*                                                                             *
* License Agreement                                                           *
*                                                                             *
* Copyright (c) 2003 Altera Corporation, San Jose, California, USA.           *
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

#include "alt_types.h"
#include "sys/alt_cache.h" 

/*
 * alt_icache_flush_all() is called to flush the entire instruction cache.
 */

void alt_icache_flush_all (void)
{
#if ALT_CPU_ICACHE_SIZE > 0
    alt_u32 addr;

    for (
      addr = A_K0BASE+(ALT_CPU_ICACHE_SIZE-ALT_CPU_ICACHE_LINE_SIZE);
      ((alt_32)addr) >= 0; 
      addr -= ALT_CPU_ICACHE_LINE_SIZE) {

      /* Perform an I-cache index invalidate. */
        __asm__ volatile ("cache ((0x0 << 2) | 0x0), 0(%0)" :: "r" (addr));
    }
#endif /* ALT_CPU_ICACHE_SIZE > 0 */
}
