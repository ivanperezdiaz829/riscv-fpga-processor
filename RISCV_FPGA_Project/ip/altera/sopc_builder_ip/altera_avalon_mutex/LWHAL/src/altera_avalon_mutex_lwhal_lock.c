/******************************************************************************
*                                                                             *
* License Agreement                                                           *
*                                                                             *
* Copyright (c) 2010 Altera Corporation, San Jose, California, USA.           *
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
*****************************************************************************/
#include <errno.h>
#include "alt_types.h"
#include "altera_avalon_mutex_lwhal.h"
#include "altera_avalon_mutex_regs.h"


/** @Function Description:  Try to lock the hardware mutex.
  * @API Type:              Internal
  * @param base             Mutex base address
  * @param owner            Unique identifier value for mutex owner.
  * @param value            The new value to write to the mutex.  
  * @return                 0 = The mutex was successfully locked.
  *                         Non-zero = The mutex was not locked.
  */ 
static int alt_mutex_trylock(void *base, alt_u16 owner, alt_u16 value)
{
  alt_u32 data, check;

  /* the data we want the mutex to hold */
  data = (owner << ALTERA_AVALON_MUTEX_MUTEX_OWNER_OFST) | value;

  /* attempt to write to the mutex */
  IOWR_ALTERA_AVALON_MUTEX_MUTEX(base, data);
  
  check = IORD_ALTERA_AVALON_MUTEX_MUTEX(base);

  if (check == data)
  {
    return 0;
  }

  return -1;
}


/** @Function Description:  Locks the mutex. Will not return until it has 
  *                         successfully claimed the mutex (blocking).
  * @API Type:              External
  * @param base             Mutex base address
  * @param owner            Unique identifier value for mutex owner.
  * @param value            The new value to write to the mutex.  
  * @return                 0 = The mutex was successfully locked.
  *                         Non-zero = The mutex was not locked.
  */ 
void altera_avalon_mutex_lwhal_lock(void *base, alt_u16 owner, alt_u16 value)
{
  while ( alt_mutex_trylock( base, owner, value ) != 0);
}


/** @Function Description:  Tries once to lock the mutex. Return immediately 
  *                         if it fails to lock the mutex (non-blocking).
  * @API Type:              External
  * @param base             Mutex base address
  * @param owner            Unique identifier value for mutex owner.
  * @param value            The new value to write to the mutex.  
  * @return                 0 = The mutex was successfully locked.
  *                         Non-zero = The mutex was not locked.
  */ 
int altera_avalon_mutex_lwhal_trylock(void *base, alt_u16 owner, alt_u16 value)
{
  return alt_mutex_trylock(base, owner, value);
}
