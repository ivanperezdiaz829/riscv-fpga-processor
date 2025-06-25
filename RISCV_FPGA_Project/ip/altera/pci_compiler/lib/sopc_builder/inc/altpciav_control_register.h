/******************************************************************************
*                                                                             *
* License Agreement                                                           *
*                                                                             *
* Copyright (c) 2004 Altera Corporation, San Jose, California, USA.           *
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

#ifndef __ALTPCIAV_CONTROL_REGISTER_H__
#define __ALTPCIAV_CONTROL_REGISTER_H__

#include <io.h>

#define IORD_ALTPCIAV_PCI_INTR_STATUS(base)       IORD_32DIRECT(base, 0x0040) 
#define IOWR_ALTPCIAV_PCI_INTR_STATUS(base, data) IOWR_32DIRECT(base, 0x0040, data)
#define IORD_ALTPCIAV_PCI_INTR_ENABLE(base)       IORD_32DIRECT(base, 0x0050) 
#define IOWR_ALTPCIAV_PCI_INTR_ENABLE(base, data) IOWR_32DIRECT(base, 0x0050, data)
#define MASK_ALTPCIAV_PCI_INTR_ERR_PCI_WRITE_FAIL    0x00000001
#define MASK_ALTPCIAV_PCI_INTR_ERR_PCI_READ_FAIL     0x00000002
#define MASK_ALTPCIAV_PCI_INTR_ERR_NONP_DATA_DISCARD 0x00000004
#define MASK_ALTPCIAV_PCI_INTR_AV_IRQ_ASSERTED       0x00000080
#define MASK_ALTPCIAV_PCI_INTR_PCI_PERR_REP          0x00000100
#define MASK_ALTPCIAV_PCI_INTR_PCI_TABORT_SIG        0x00000200
#define MASK_ALTPCIAV_PCI_INTR_PCI_TABORT_RCVD       0x00000400
#define MASK_ALTPCIAV_PCI_INTR_PCI_MABORT_RCVD       0x00000800
#define MASK_ALTPCIAV_PCI_INTR_PCI_SERR_SIG	     0x00001000
#define MASK_ALTPCIAV_PCI_INTR_PCI_PERR_DET          0x00002000
#define MASK_ALTPCIAV_PCI_INTR_A2P_MAILBOX0          0x00010000
#define MASK_ALTPCIAV_PCI_INTR_A2P_MAILBOX1          0x00020000
#define MASK_ALTPCIAV_PCI_INTR_A2P_MAILBOX2          0x00040000
#define MASK_ALTPCIAV_PCI_INTR_A2P_MAILBOX3          0x00080000
#define MASK_ALTPCIAV_PCI_INTR_A2P_MAILBOX4          0x00100000
#define MASK_ALTPCIAV_PCI_INTR_A2P_MAILBOX5          0x00200000
#define MASK_ALTPCIAV_PCI_INTR_A2P_MAILBOX6          0x00400000
#define MASK_ALTPCIAV_PCI_INTR_A2P_MAILBOX7          0x00800000

#define IORD_ALTPCIAV_P2A_MAILBOX_RW(base, mbnum)       IORD_32DIRECT(base, 0x0800+((mbnum)*4))
#define IOWR_ALTPCIAV_P2A_MAILBOX_RW(base, mbnum, data) IOWR_32DIRECT(base, 0x0800+((mbnum)*4), data)

#define IORD_ALTPCIAV_A2P_MAILBOX_RO(base, mbnum)      IORD_32DIRECT(base, 0x0900+((mbnum)*4))

#define IORD_ALTPCIAV_A2P_ADDR_TRANS_LO(base, entrynum)       IORD_32DIRECT(base, 0x1000+((entrynum)*8))
#define IORD_ALTPCIAV_A2P_ADDR_TRANS_HI(base, entrynum)       IORD_32DIRECT(base, 0x1004+((entrynum)*8))
#define IOWR_ALTPCIAV_A2P_ADDR_TRANS_LO(base, entrynum, data) IOWR_32DIRECT(base, 0x1000+((entrynum)*8), data)
#define IOWR_ALTPCIAV_A2P_ADDR_TRANS_HI(base, entrynum, data) IOWR_32DIRECT(base, 0x1004+((entrynum)*8), data)
#define MASK_ALTPCIAV_ADDR_TRANS_SPACE        0x00000003 
#define CODE_ALTPCIAV_ADDR_TRANS_SPACE_MEM32  0x00000000
#define CODE_ALTPCIAV_ADDR_TRANS_SPACE_MEM64  0x00000001
#define CODE_ALTPCIAV_ADDR_TRANS_SPACE_IO     0x00000002
#define CODE_ALTPCIAV_ADDR_TRANS_SPACE_CONFIG 0x00000003

#define IORD_ALTPCIAV_GEN_CONFIG_PARAM(base)        IORD_32DIRECT(base, 0x2c00)
#define MASK_ALTPCIAV_GEN_PCI_ADDR_WIDTH      0x0000007F
#define MASK_ALTPCIAV_GEN_TARGET_ONLY         0x00000100
#define MASK_ALTPCIAV_GEN_HOST_BRIDGE_MODE    0x00000200
#define MASK_ALTPCIAV_GEN_PCI_BUS_64          0x00000400 
#define MASK_ALTPCIAV_GEN_COMMON_CLOCK_MODE   0x00000800
#define MASK_ALTPCIAV_GEN_IMPL_PREF_PORT      0x00001000
#define MASK_ALTPCIAV_GEN_IMPL_NONP_PORT      0x00002000
#define MASK_ALTPCIAV_GEN_NUM_A2P_MAILBOX     0x000F0000
#define MASK_ALTPCIAV_GEN_NUM_P2A_MAILBOX     0x00F00000
#define READ_ALTPCIAV_GEN_PCI_ADDR_WIDTH(base)      ((IORD_32DIRECT(base, 0x2c00) & 0x0000007F) >> 0)
#define READ_ALTPCIAV_GEN_TARGET_ONLY(base)         ((IORD_32DIRECT(base, 0x2c00) & 0x00000100) >> 8)
#define READ_ALTPCIAV_GEN_HOST_BRIDGE_MODE(base)    ((IORD_32DIRECT(base, 0x2c00) & 0x00000200) >> 9)
#define READ_ALTPCIAV_GEN_PCI_BUS_64(base)          ((IORD_32DIRECT(base, 0x2c00) & 0x00000400) >> 10) 
#define READ_ALTPCIAV_GEN_COMMON_CLOCK_MODE(base)   ((IORD_32DIRECT(base, 0x2c00) & 0x00000800) >> 11)
#define READ_ALTPCIAV_GEN_IMPL_PREF_PORT(base)      ((IORD_32DIRECT(base, 0x2c00) & 0x00001000) >> 12)
#define READ_ALTPCIAV_GEN_IMPL_NONP_PORT(base)      ((IORD_32DIRECT(base, 0x2c00) & 0x00002000) >> 13)
#define READ_ALTPCIAV_GEN_NUM_A2P_MAILBOX(base)     ((IORD_32DIRECT(base, 0x2c00) & 0x000F0000) >> 16)
#define READ_ALTPCIAV_GEN_NUM_P2A_MAILBOX(base)     ((IORD_32DIRECT(base, 0x2c00) & 0x00F00000) >> 20)


#define IORD_ALTPCIAV_PERF_PARAM(base)              IORD_32DIRECT(base, 0x2c04)
#define MASK_ALTPCIAV_PERF_A2P_WRITE_CD_DEPTH 0x0000FFFF
#define READ_ALTPCIAV_PERF_A2P_WRITE_CD_DEPTH(base) ((IORD_32DIRECT(base, 0x2c04) & 0x0000FFFF) >> 0)

#define IORD_ALTPCIAV_ADDR_TRANS_PARAM(base)        IORD_32DIRECT(base, 0x2c08)
#define MASK_ALTPCIAV_AT_A2P_ADDR_MAP_IS_FIXED       0x00000001
#define MASK_ALTPCIAV_AT_A2P_ADDR_MAP_IS_READABLE    0x00000002
#define MASK_ALTPCIAV_AT_A2P_ADDR_MAP_PASS_THRU_BITS 0x00003F00
#define MASK_ALTPCIAV_AT_A2P_ADDR_MAP_NUM_ENTRIES    0xFFFF0000 
#define READ_ALTPCIAV_AT_A2P_ADDR_MAP_IS_FIXED(base)       ((IORD_32DIRECT(base, 0x2c08) & 0x00000001) >> 0)
#define READ_ALTPCIAV_AT_A2P_ADDR_MAP_IS_READABLE(base)    ((IORD_32DIRECT(base, 0x2c08) & 0x00000002) >> 1)
#define READ_ALTPCIAV_AT_A2P_ADDR_MAP_PASS_THRU_BITS(base) ((IORD_32DIRECT(base, 0x2c08) & 0x00003F00) >> 8)
#define READ_ALTPCIAV_AT_A2P_ADDR_MAP_NUM_ENTRIES(base)    ((IORD_32DIRECT(base, 0x2c08) & 0xFFFF0000) >> 16) 

#define IORD_ALTPCIAV_AVL_INTR_STATUS(base)       IORD_32DIRECT(base, 0x3060) 
#define IOWR_ALTPCIAV_AVL_INTR_STATUS(base, data) IOWR_32DIRECT(base, 0x3060, data)
#define IORD_ALTPCIAV_AVL_INTR_ENABLE(base)       IORD_32DIRECT(base, 0x3070) 
#define IOWR_ALTPCIAV_AVL_INTR_ENABLE(base, data) IOWR_32DIRECT(base, 0x3070, data)
#define MASK_ALTPCIAV_AVL_INTR_ERR_PCI_WRITE_FAIL    0x00000001
#define MASK_ALTPCIAV_AVL_INTR_ERR_PCI_READ_FAIL     0x00000002
#define MASK_ALTPCIAV_AVL_INTR_ERR_NONP_DATA_DISCARD 0x00000004
#define MASK_ALTPCIAV_AVL_INTR_MASTER_ENABLE_FELL    0x00000008
#define MASK_ALTPCIAV_AVL_INTR_MASTER_ENABLE_ROSE    0x00000010
#define MASK_ALTPCIAV_AVL_INTR_INTAN_FELL            0x00000040
#define MASK_ALTPCIAV_AVL_INTR_INTAN_ROSE            0x00000080
#define MASK_ALTPCIAV_AVL_INTR_PCI_PERR_REP          0x00000100
#define MASK_ALTPCIAV_AVL_INTR_PCI_TABORT_SIG        0x00000200
#define MASK_ALTPCIAV_AVL_INTR_PCI_TABORT_RCVD       0x00000400
#define MASK_ALTPCIAV_AVL_INTR_PCI_MABORT_SIG        0x00000800
#define MASK_ALTPCIAV_AVL_INTR_PCI_MABORT_RCVD       0x00001000
#define MASK_ALTPCIAV_AVL_INTR_PCI_PERR_DET          0x00002000
#define MASK_ALTPCIAV_AVL_INTR_RSTN_FELL             0x00004000
#define MASK_ALTPCIAV_AVL_INTR_RSTN_ROSE             0x00008000
#define MASK_ALTPCIAV_AVL_INTR_P2A_MAILBOX0          0x00010000
#define MASK_ALTPCIAV_AVL_INTR_P2A_MAILBOX1          0x00020000
#define MASK_ALTPCIAV_AVL_INTR_P2A_MAILBOX2          0x00040000
#define MASK_ALTPCIAV_AVL_INTR_P2A_MAILBOX3          0x00080000
#define MASK_ALTPCIAV_AVL_INTR_P2A_MAILBOX4          0x00100000
#define MASK_ALTPCIAV_AVL_INTR_P2A_MAILBOX5          0x00200000
#define MASK_ALTPCIAV_AVL_INTR_P2A_MAILBOX6          0x00400000
#define MASK_ALTPCIAV_AVL_INTR_P2A_MAILBOX7          0x00800000
#define IORD_ALTPCIAV_CURR_PCI_STATUS(base)       IORD_32DIRECT(base, 0x306C)
#define MASK_ALTPCIAV_CURR_PCI_MASTER_ENABLE         0x00000008
#define MASK_ALTPCIAV_CURR_PCI_A2P_WR_IN_PROG        0x00000020
#define MASK_ALTPCIAV_CURR_PCI_INTAN                 0x00000040


#define IORD_ALTPCIAV_A2P_MAILBOX_RW(base, mbnum)       IORD_32DIRECT(base, 0x3A00+((mbnum)*4))
#define IOWR_ALTPCIAV_A2P_MAILBOX_RW(base, mbnum, data) IOWR_32DIRECT(base, 0x3A00+((mbnum)*4), data)

#define IORD_ALTPCIAV_P2A_MAILBOX_RO(base, mbnum)      IORD_32DIRECT(base, 0x3B00+((mbnum)*4))

#endif /* __ALTPCIAV_CONTROL_REGISTER_H__ */
