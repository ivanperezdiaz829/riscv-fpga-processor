/******************************************************************************
*                                                                             *
* License Agreement                                                           *
*                                                                             *
* Copyright (c) 2006 Altera Corporation, San Jose, California, USA.           *
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

#ifndef __DATA_SINK_REGS_H__
#define __DATA_SINK_REGS_H__

#include <io.h>

#define DATA_SINK_STATUS_REG                        0
#define DATA_SINK_CONTROL_REG                       1
#define DATA_SINK_UNUSED_REG                        2
#define DATA_SINK_EVENT_REG                         3
#define DATA_SINK_MASK_REG                          4
#define DATA_SINK_EXCEPTION_REG                     5
#define DATA_SINK_INDIRECT_SELECT_REG               6
#define DATA_SINK_INDIRECT_COUNT_REG                7

// Read slave
#define IORD_DATA_SINK_CONTROL(base)                \
        IORD(base, DATA_SINK_CONTROL)

#define IORD_DATA_SINK_STATUS(base)                 \
        IORD(base, DATA_SINK_STATUS)

// Write slave
#define IOWR_DATA_SINK_CONTROL(base, data)          \
        IOWR(base, DATA_SINK_DATA_CONTROL, data)

// Read command
#define IORD_DATA_SINK_CONTROL(base)                \
        IORD(base, DATA_SINK_CONTROL)

// Write command
#define IOWR_DATA_SINK_CMD_LO(base, data)          \
        IOWR(base, DATA_SINK_CMD_LO_REG, data)

#define IOWR_DATA_SINK_CMD_HI(base, data)          \
        IOWR(base, DATA_SINK_CMD_LO_HI, data)

// Status
#define DATA_SINK_ID_MSK             (0x0FFFF)
#define DATA_SINK_ID_RT              (0)
#define DATA_SINK_NUMCHANNELS_MSK    (0x00FF0000)
#define DATA_SINK_NUMCHANNELS_RT     (16)
#define DATA_SINK_NUMSYMBOLS_MSK     (0x7F000000)
#define DATA_SINK_NUMSYMBOLS_RT      (24)
#define DATA_SINK_SUPPORTPACKETS_MSK (0x80000000)
#define DATA_SINK_SUPPORTPACKETS_RT  (31)

// Control
#define DATA_SINK_ENABLE_MSK            (0x00000001)
#define DATA_SINK_INTERRUPT_ENABLE_MSK  (0x00000002)
#define DATA_SINK_THROTTLE_MSK          (0x0001FF00)
#define DATA_SINK_RESET_MSK             (0x00020000)

#define DATA_SINK_ENABLE_RT         (0)
#define DATA_SINK_IGNORE_READY_RT   (1)
#define DATA_SINK_THROTTLE_RT       (8)
#define DATA_SINK_RESET_RT          (17)
// Exception
#define DATA_SINK_EXC_DATAERROR_MSK   (0x00000001)
#define DATA_SINK_EXC_DATAERROR_MSK   (0x00000001)

#define DATA_SINK_EXC_DATAERROR_MSK   (0x00000001)
#define DATA_SINK_EXC_MISSINGSOP_MSK  (0x00000002)
#define DATA_SINK_EXC_MISSINGEOP_MSK  (0x00000004)
#define DATA_SINK_EXC_SIGERROR_MSK    (0x0000FF00)
#define DATA_SINK_EXC_CHANNEL_MSK     (0xFF000000)

#define DATA_SINK_EXC_DATAERROR_RT   (0)
#define DATA_SINK_EXC_MISSINGSOP_RT  (1)
#define DATA_SINK_EXC_MISSINGEOP_RT  (2)
#define DATA_SINK_EXC_SIGERROR_RT    (8)
#define DATA_SINK_EXC_CHANNEL_RT     (24)

// Indirect Select
#define DATA_SINK_IND_CHANNEL_MSK   (0x0000FFFF)
#define DATA_SINK_IND_ERROR_MSK     (0xFFFF0000)

#define DATA_SINK_IND_CHANNEL_RT   (0)
#define DATA_SINK_IND_ERROR_RT     (16)


// Indirect Counters
#define DATA_SINK_IND_PACKET_MSK   (0x0000FFFF)
#define DATA_SINK_IND_SYMBOL_MSK   (0xFFFF0000)

#define DATA_SINK_IND_PACKET_RT     (0)
#define DATA_SINK_IND_SYMBOL_RT     (16)

#endif /* __DATA_SINK_REGS_H__ */

