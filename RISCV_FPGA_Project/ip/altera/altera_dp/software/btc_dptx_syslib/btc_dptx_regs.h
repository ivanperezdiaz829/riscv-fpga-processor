// ********************************************************************************
// DisplayPort Core Source register map
//
// All rights reserved. Property of Bitec.
// Restricted rights to use, duplicate or disclose this code are
// granted through contract.
//
// (C) Copyright Bitec 2012
//    All rights reserved
//
// Author         : $Author: jschleic $ @ bitec-dsp.com
// Department     :
// Date           : $Date: 2013/08/13 $
// Revision       : $Revision: #1 $
// URL            : $URL: svn://10.8.0.1/share/svn/dp_sw/trunk/btc_dptx_syslib/btc_dptx_regs.h $
//
// Description:
//
// ********************************************************************************

#define DPTX_REG_TX_CONTROL   0x0
#define DPTX_REG_TX_STATUS    0x1
#ifdef BITEC_DPTX_RTL_4X
#define DPTX_REG_MSA_MVID     0x2
#define DPTX_REG_MSA_NVID     0x3
#define DPTX_REG_MSA_HTOTAL   0x4
#define DPTX_REG_MSA_VTOTAL   0x5
#define DPTX_REG_MSA_HSP      0x6
#define DPTX_REG_MSA_HSW      0x7
#define DPTX_REG_MSA_HSTART   0x8
#define DPTX_REG_MSA_VSTART   0x9
#define DPTX_REG_MSA_VSP      0xa
#define DPTX_REG_MSA_VSW      0xb
#define DPTX_REG_MSA_HWIDTH   0xc
#define DPTX_REG_MSA_VHEIGHT  0xd
#define DPTX_REG_MSA_MISC0    0xe
#define DPTX_REG_MSA_MISC1    0xf
#endif

#define DPTX_REG_PRE_VOLT0    0x10
#define DPTX_REG_PRE_VOLT1    0x11
#define DPTX_REG_PRE_VOLT2    0x12
#define DPTX_REG_PRE_VOLT3    0x13
#define DPTX_REG_RECONFIG     0x14
#define DPTX_REG_LINK_QUALITY_PATTERN 0x14

#define DPTX_REG_TIMESTAMP    0x1f

#define DPTX0_REG_MSA_MVID    0x20
#define DPTX0_REG_MSA_NVID    0x21
#define DPTX0_REG_MSA_HTOTAL  0x22
#define DPTX0_REG_MSA_VTOTAL  0x23
#define DPTX0_REG_MSA_HSP     0x24
#define DPTX0_REG_MSA_HSW     0x25
#define DPTX0_REG_MSA_HSTART  0x26
#define DPTX0_REG_MSA_VSTART  0x27
#define DPTX0_REG_MSA_VSP     0x28
#define DPTX0_REG_MSA_VSW     0x29
#define DPTX0_REG_MSA_HWIDTH  0x2a
#define DPTX0_REG_MSA_VHEIGHT 0x2b
#define DPTX0_REG_MSA_MISC0   0x2c
#define DPTX0_REG_MSA_MISC1   0x2d
#define DPTX0_REG_MSA_COLOUR  0x2e
#define DPTX0_REG_AUD_CONTROL 0x2f
#define DPTX0_REG_CRC_R       0x30
#define DPTX0_REG_CRC_G       0x31
#define DPTX0_REG_CRC_B       0x32

#define DPTX_REG_AUX_CONTROL  0x100
#define DPTX_REG_AUX_COMMAND  0x101
#define DPTX_REG_AUX_BYTE0    0x102
#define DPTX_REG_AUX_BYTE1    0x103
#define DPTX_REG_AUX_BYTE2    0x104
#define DPTX_REG_AUX_BYTE3    0x105
#define DPTX_REG_AUX_BYTE4    0x106
#define DPTX_REG_AUX_BYTE5    0x107
#define DPTX_REG_AUX_BYTE6    0x108
#define DPTX_REG_AUX_BYTE7    0x109
#define DPTX_REG_AUX_BYTE8    0x10a
#define DPTX_REG_AUX_BYTE9    0x10b
#define DPTX_REG_AUX_BYTE10   0x10c
#define DPTX_REG_AUX_BYTE11   0x10d
#define DPTX_REG_AUX_BYTE12   0x10e
#define DPTX_REG_AUX_BYTE13   0x10f
#define DPTX_REG_AUX_BYTE14   0x110
#define DPTX_REG_AUX_BYTE15   0x111
#define DPTX_REG_AUX_BYTE16   0x112
#define DPTX_REG_AUX_BYTE17   0x113
#define DPTX_REG_AUX_BYTE18   0x114
#define DPTX_REG_AUX_RESET    0x117




