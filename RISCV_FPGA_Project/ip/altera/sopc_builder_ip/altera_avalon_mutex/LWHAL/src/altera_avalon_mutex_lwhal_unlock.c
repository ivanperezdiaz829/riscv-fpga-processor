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


/** @Function Description:  Releases mutex. Upon release, the value stored in 
  *                         the mutex is set to zero. If the caller does not 
  *                         hold the mutex, the behavior of this function is 
  *                         undefined.
  * @API Type:              External
  * @param base             Mutex base address
  * @param owner            Unique identifier value for mutex owner.
  * @return                 void
  */  
void altera_avalon_mutex_lwhal_unlock(void *base, alt_u16 owner)
{
  /*
  * This Mutex has been claimed and released since Reset so clear the Reset bit
  * This MUST happen before we release the MUTEX
  */
  IOWR_ALTERA_AVALON_MUTEX_RESET(base, 
                                  ALTERA_AVALON_MUTEX_RESET_RESET_MSK);
  IOWR_ALTERA_AVALON_MUTEX_MUTEX(base, 
                                  owner << ALTERA_AVALON_MUTEX_MUTEX_OWNER_OFST);

}

