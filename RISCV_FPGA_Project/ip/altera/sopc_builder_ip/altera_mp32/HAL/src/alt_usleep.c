/*
 * Copyright (c) 2003 Altera Corporation, San Jose, California, USA.  
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
 * ------------
 *
 * Altera does not recommend, suggest or require that this reference design 
 * file be used in conjunction or combination with any other product.
 *
 * usleep.c - Microsecond delay routine 
 */

#include <unistd.h>

#include "priv/alt_busy_sleep.h"
#include "os/alt_syscall.h"

/*
 * This function simply calls alt_busy_sleep() to perform the delay. This 
 * function implements the delay as a calibrated "busy loop".
 *
 * ALT_USLEEP is mapped onto the usleep() system call in alt_syscall.h 
 */

#if defined (__GNUC__) && __GNUC__ >= 4
int ALT_USLEEP (useconds_t us)
#else
unsigned int ALT_USLEEP (unsigned int us)
#endif
{
  return alt_busy_sleep(us);
}
