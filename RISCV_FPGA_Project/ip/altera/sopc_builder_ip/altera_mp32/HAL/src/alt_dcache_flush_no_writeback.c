/******************************************************************************
*                                                                             *
* License Agreement                                                           *
*                                                                             *
* Copyright (c) 2007 Altera Corporation, San Jose, California, USA.           *
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

/* Perform a D-cache hit invalidate (no writeback if dirty). */
#define ALT_FLUSH_DATA_NO_WRITEBACK(addr) \
  __asm__ volatile ("cache ((0x4 << 2) | 0x1), 0(%0)" :: "r" (addr))

/*
 * alt_dcache_flush_no_writeback() is called to flush the data cache for a
 * memory region of length "len" bytes, starting at address "start".
 *
 * Any dirty lines in the data cache are NOT written back to memory.
 * Make sure you really want this behavior.  If you aren't 100% sure,
 * use the alt_dcache_flush() routine instead.
 */

void alt_dcache_flush_no_writeback (void* start, alt_u32 len)
{
#if ALT_CPU_DCACHE_SIZE > 0

    char* addr;
    char* end = ((char*) start) + len; 

    for (addr = start; addr < end; addr += ALT_CPU_DCACHE_LINE_SIZE) { 
        ALT_FLUSH_DATA_NO_WRITEBACK(addr);
    }

    /* 
     * For an unaligned flush request, we've got one more line left.
     * Note that this is dependent on ALT_CPU_DCACHE_LINE_SIZE to be a 
     * multiple of 2 (which it always is).
     */

    if (((alt_u32) start) & (ALT_CPU_DCACHE_LINE_SIZE - 1)) {
        ALT_FLUSH_DATA_NO_WRITEBACK(addr);
    }

#endif /* ALT_CPU_DCACHE_SIZE > 0 */
}
