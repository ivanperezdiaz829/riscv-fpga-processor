/******************************************************************************
*                                                                             *
* License Agreement                                                           *
*                                                                             *
* Copyright (c) 2005 Altera Corporation, San Jose, California, USA.           *
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
* altera_avalon_compact_flash.c - compact flash IDE interface                 *
*                                                                             *
******************************************************************************/

#include "alt_types.h"
#include <unistd.h>

#include "altera_avalon_cf_regs.h"
#include "altera_avalon_cf.h"

/*
 * alt_avalon_ide_cf_init()
 * 
 * Power cycle interface & ensure that all interrupts are disabled.
 * 
 */
int alt_avalon_ide_cf_init( void* base )
{
  int ret_code = 0;
  
  /* Disable IDE interrupts in controller */
  IOWR_ALTERA_AVALON_CF_IDE_CTL(base, 0);

  /* Power down CF card */
  IOWR_ALTERA_AVALON_CF_CTL_CONTROL(base, 0);
   
#ifndef ALT_SIM_OPTIMIZE
  /* 0.5-second delay */
  usleep(500000);  
#endif
  
  /* Power up CF card */
  IOWR_ALTERA_AVALON_CF_CTL_CONTROL(base, 
    ALTERA_AVALON_CF_CTL_STATUS_POWER_MSK);

#ifndef ALT_SIM_OPTIMIZE
  /* 0.5-second delay */
  usleep(500000);
#endif

  /* Read ctl register to clear pending card insertion/removal interrupt */
  IORD_ALTERA_AVALON_CF_CTL_STATUS(base);
  
  return ret_code;
}

/* End of file */
