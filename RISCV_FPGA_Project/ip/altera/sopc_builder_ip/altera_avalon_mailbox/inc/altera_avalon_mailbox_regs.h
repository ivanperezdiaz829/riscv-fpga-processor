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
******************************************************************************/

#ifndef __ALTERA_AVALON_MAILBOX_REGS_H__
#define __ALTERA_AVALON_MAILBOX_REGS_H__

#include <io.h>

#define IOADDR_ALTERA_AVALON_MAILBOX_MUTEX0(base)      __IO_CALC_ADDRESS_NATIVE(base, 0)
#define IOWR_ALTERA_AVALON_MAILBOX_MUTEX0(base, data)  IOWR(base, 0, data)
#define IORD_ALTERA_AVALON_MAILBOX_MUTEX0(base)        IORD(base, 0) 

#define ALTERA_AVALON_MAILBOX_MUTEX_VALUE_MSK         (0xFFFF)
#define ALTERA_AVALON_MAILBOX_MUTEX_VALUE_OFST        (0)
#define ALTERA_AVALON_MAILBOX_MUTEX_OWNER_MSK         (0xFFFF0000)
#define ALTERA_AVALON_MAILBOX_MUTEX_OWNER_OFST        (16)

#define IOADDR_ALTERA_AVALON_MAILBOX_RESET0(base)     __IO_CALC_ADDRESS_NATIVE(base, 1)
#define IOWR_ALTERA_AVALON_MAILBOX_RESET0(base, data)  IOWR(base, 1, data)
#define IORD_ALTERA_AVALON_MAILBOX_RESET0(base)        IORD(base, 1) 

#define IOADDR_ALTERA_AVALON_MAILBOX_MUTEX1(base)      __IO_CALC_ADDRESS_NATIVE(base, 2)
#define IOWR_ALTERA_AVALON_MAILBOX_MUTEX1(base, data)  IOWR(base, 2, data)
#define IORD_ALTERA_AVALON_MAILBOX_MUTEX1(base)        IORD(base, 2) 

#define IOADDR_ALTERA_AVALON_MAILBOX_RESET(base)      __IO_CALC_ADDRESS_NATIVE(base, 3)
#define IOWR_ALTERA_AVALON_MAILBOX_RESET(base, data)  IOWR(base, 3, data)
#define IORD_ALTERA_AVALON_MAILBOX_RESET(base)        IORD(base, 3) 

#define ALTERA_AVALON_MAILBOX_RESET_RESET_MSK         (0x1)
#define ALTERA_AVALON_MAILBOX_RESET_RESET_OFST        (0)


#endif /* __ALTERA_AVALON_MAILBOX_REGS_H__ */
