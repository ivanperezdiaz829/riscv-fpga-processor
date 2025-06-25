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

#ifndef __ALTERA_AVALON_CF_REGS_H__
#define __ALTERA_AVALON_CF_REGS_H__

#include <io.h>


/* IDE Slave I/O RD/WR/ADDR macros */
#define IOADDR_ALTERA_AVALON_CF_IDE_DATA(base)               __IO_CALC_ADDRESS_NATIVE(base, 0)
#define IORD_ALTERA_AVALON_CF_IDE_DATA(base)                 IORD(base, 0) 
#define IOWR_ALTERA_AVALON_CF_IDE_DATA(base, data)           IOWR(base, 0, data)

#define IOADDR_ALTERA_AVALON_CF_IDE_ERROR(base)              __IO_CALC_ADDRESS_NATIVE(base, 1)
#define IORD_ALTERA_AVALON_CF_IDE_ERROR(base)                IORD(base, 1) 
#define IOWR_ALTERA_AVALON_CF_IDE_FEATURES(base, data)       IOWR(base, 1, data)

#define IOADDR_ALTERA_AVALON_CF_IDE_SECTOR_COUNT(base)       __IO_CALC_ADDRESS_NATIVE(base, 2)
#define IORD_ALTERA_AVALON_CF_IDE_SECTOR_COUNT(base)         IORD(base, 2) 
#define IOWR_ALTERA_AVALON_CF_IDE_SECTOR_COUNT(base, data)   IOWR(base, 2, data)

#define IOADDR_ALTERA_AVALON_CF_IDE_SECTOR_NUMBER(base)      __IO_CALC_ADDRESS_NATIVE(base, 3)
#define IORD_ALTERA_AVALON_CF_IDE_SECTOR_NUMBER(base)        IORD(base, 3) 
#define IOWR_ALTERA_AVALON_CF_IDE_SECTOR_NUMBER(base, data)  IOWR(base, 3, data)

#define IOADDR_ALTERA_AVALON_CF_IDE_CYLINDER_LOW(base)       __IO_CALC_ADDRESS_NATIVE(base, 4)
#define IORD_ALTERA_AVALON_CF_IDE_CYLINDER_LOW(base)         IORD(base, 4) 
#define IOWR_ALTERA_AVALON_CF_IDE_CYLINDER_LOW(base, data)   IOWR(base, 4, data)

#define IOADDR_ALTERA_AVALON_CF_IDE_CYLINDER_HIGH(base)      __IO_CALC_ADDRESS_NATIVE(base, 5)
#define IORD_ALTERA_AVALON_CF_IDE_CYLINDER_HIGH(base)        IORD(base, 5) 
#define IOWR_ALTERA_AVALON_CF_IDE_CYLINDER_HIGH(base, data)  IOWR(base, 5, data)

#define IOADDR_ALTERA_AVALON_CF_IDE_DEVICE_HEAD(base)        __IO_CALC_ADDRESS_NATIVE(base, 6)
#define IORD_ALTERA_AVALON_CF_IDE_DEVICE_HEAD(base)          IORD(base, 6) 
#define IOWR_ALTERA_AVALON_CF_IDE_DEVICE_HEAD(base, data)    IOWR(base, 6, data)

#define IOADDR_ALTERA_AVALON_CF_IDE_STATUS(base)             __IO_CALC_ADDRESS_NATIVE(base, 7)
#define IOADDR_ALTERA_AVALON_CF_IDE_COMMAND(base)            __IO_CALC_ADDRESS_NATIVE(base, 7)
#define IORD_ALTERA_AVALON_CF_IDE_STATUS(base)               IORD(base, 7) 
#define IOWR_ALTERA_AVALON_CF_IDE_COMMAND(base, data)        IOWR(base, 7, data)

#define IOADDR_ALTERA_AVALON_CF_IDE_ALTERNATE_STATUS(base)   __IO_CALC_ADDRESS_NATIVE(base, 14)
#define IOADDR_ALTERA_AVALON_CF_IDE_DEVICE_CONTROL(base)     __IO_CALC_ADDRESS_NATIVE(base, 14)
#define IORD_ALTERA_AVALON_CF_IDE_ALTERNATE_STATUS(base)     IORD(base, 14) 
#define IOWR_ALTERA_AVALON_CF_IDE_DEVICE_CONTROL(base, data) IOWR(base, 14, data)


/* CTL slave I/O RD/WR macros */
#define IORD_ALTERA_AVALON_CF_CTL_STATUS(base)               IORD(base, 0) 
#define IOWR_ALTERA_AVALON_CF_CTL_CONTROL(base, data)        IOWR(base, 0, data)

#define IORD_ALTERA_AVALON_CF_IDE_CTL(base)                  IORD(base, 1) 
#define IOWR_ALTERA_AVALON_CF_IDE_CTL(base, data)            IOWR(base, 1, data)

/* CTL slave register bit-masks & bit-offsets */
#define ALTERA_AVALON_CF_CTL_STATUS_PRESENT_MSK       (0x1)
#define ALTERA_AVALON_CF_CTL_STATUS_PRESENT_OFST      (0)
#define ALTERA_AVALON_CF_CTL_STATUS_POWER_MSK         (0x2)
#define ALTERA_AVALON_CF_CTL_STATUS_POWER_OFST        (1)
#define ALTERA_AVALON_CF_CTL_STATUS_RESET_MSK         (0x4)
#define ALTERA_AVALON_CF_CTL_STATUS_RESET_OFST        (2)
#define ALTERA_AVALON_CF_CTL_STATUS_IRQ_EN_MSK        (0x8)
#define ALTERA_AVALON_CF_CTL_STATUS_IRQ_EN_OFST       (3)

#define ALTERA_AVALON_CF_IDE_CTL_IRQ_EN_MSK           (0x1)
#define ALTERA_AVALON_CF_IDE_CTL_IRQ_EN_OFST          (0)

#endif /* __ALTERA_AVALON_CF_REGS_H__ */

/* End of file */
