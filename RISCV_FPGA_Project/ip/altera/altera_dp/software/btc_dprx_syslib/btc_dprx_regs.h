// ********************************************************************************
// DisplayPort Core Sink register map
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
// URL            : $URL: svn://10.8.0.1/share/svn/dp_sw/trunk/btc_dprx_syslib/btc_dprx_regs.h $
//
// Description:
//
// ********************************************************************************

#define DPRX_REG_RX_CONTROL    0x00
#define DPRX_REG_RX_STATUS     0x01
#define DPRX_REG_MST_CONTROL1  0x02
#define DPRX_REG_MST_STATUS1   0x03
#define DPRX_REG_MST_VCPTAB0   0x04
#define DPRX_REG_MST_VCPTAB1   0x05
#define DPRX_REG_MST_VCPTAB2   0x06
#define DPRX_REG_MST_VCPTAB3   0x07
#define DPRX_REG_MST_VCPTAB4   0x08
#define DPRX_REG_MST_VCPTAB5   0x09
#define DPRX_REG_MST_VCPTAB6   0x0a
#define DPRX_REG_MST_VCPTAB7   0x0b
#define DPRX_REG_BER_CONTROL   0x10
#define DPRX_REG_BER_CNT0      0x11
#define DPRX_REG_BER_CNT1      0x12
#define DPRX_REG_TIMESTAMP     0x13

#define DPRX0_REG_MSA_MVID     0x20
#define DPRX0_REG_MSA_NVID     0x21
#define DPRX0_REG_MSA_HTOTAL   0x22
#define DPRX0_REG_MSA_VTOTAL   0x23
#define DPRX0_REG_MSA_HSP      0x24
#define DPRX0_REG_MSA_HSW      0x25
#define DPRX0_REG_MSA_HSTART   0x26
#define DPRX0_REG_MSA_VSTART   0x27
#define DPRX0_REG_MSA_VSP      0x28
#define DPRX0_REG_MSA_VSW      0x29
#define DPRX0_REG_MSA_HWIDTH   0x2a
#define DPRX0_REG_MSA_VHEIGHT  0x2b
#define DPRX0_REG_MSA_MISC0    0x2c
#define DPRX0_REG_MSA_MISC1    0x2d
#define DPRX0_REG_VBID         0x2e
#define DPRX0_REG_AUD_MAUD     0x30
#define DPRX0_REG_AUD_NAUD     0x31
#define DPRX0_REG_AUD_AIF0     0x32
#define DPRX0_REG_AUD_AIF1     0x33
#define DPRX0_REG_AUD_AIF2     0x34
#define DPRX0_REG_AUD_AIF3     0x35
#define DPRX0_REG_AUD_AIF4     0x36

#define DPRX1_REG_MSA_MVID     0x40
#define DPRX1_REG_MSA_NVID     0x41
#define DPRX1_REG_MSA_HTOTAL   0x42
#define DPRX1_REG_MSA_VTOTAL   0x43
#define DPRX1_REG_MSA_HSP      0x44
#define DPRX1_REG_MSA_HSW      0x45
#define DPRX1_REG_MSA_HSTART   0x46
#define DPRX1_REG_MSA_VSTART   0x47
#define DPRX1_REG_MSA_VSP      0x48
#define DPRX1_REG_MSA_VSW      0x49
#define DPRX1_REG_MSA_HWIDTH   0x4a
#define DPRX1_REG_MSA_VHEIGHT  0x4b
#define DPRX1_REG_MSA_MISC0    0x4c
#define DPRX1_REG_MSA_MISC1    0x4d
#define DPRX1_REG_VBID         0x4e
#define DPRX1_REG_AUD_MAUD     0x50
#define DPRX1_REG_AUD_NAUD     0x51
#define DPRX1_REG_AUD_AIF0     0x52
#define DPRX1_REG_AUD_AIF1     0x53
#define DPRX1_REG_AUD_AIF2     0x54
#define DPRX1_REG_AUD_AIF3     0x55
#define DPRX1_REG_AUD_AIF4     0x56

#define DPRX2_REG_MSA_MVID     0x60
#define DPRX2_REG_MSA_NVID     0x61
#define DPRX2_REG_MSA_HTOTAL   0x62
#define DPRX2_REG_MSA_VTOTAL   0x63
#define DPRX2_REG_MSA_HSP      0x64
#define DPRX2_REG_MSA_HSW      0x65
#define DPRX2_REG_MSA_HSTART   0x66
#define DPRX2_REG_MSA_VSTART   0x67
#define DPRX2_REG_MSA_VSP      0x68
#define DPRX2_REG_MSA_VSW      0x69
#define DPRX2_REG_MSA_HWIDTH   0x6a
#define DPRX2_REG_MSA_VHEIGHT  0x6b
#define DPRX2_REG_MSA_MISC0    0x6c
#define DPRX2_REG_MSA_MISC1    0x6d
#define DPRX2_REG_VBID         0x6e
#define DPRX2_REG_AUD_MAUD     0x70
#define DPRX2_REG_AUD_NAUD     0x71
#define DPRX2_REG_AUD_AIF0     0x72
#define DPRX2_REG_AUD_AIF1     0x73
#define DPRX2_REG_AUD_AIF2     0x74
#define DPRX2_REG_AUD_AIF3     0x75
#define DPRX2_REG_AUD_AIF4     0x76

#define DPRX3_REG_MSA_MVID     0x80
#define DPRX3_REG_MSA_NVID     0x81
#define DPRX3_REG_MSA_HTOTAL   0x82
#define DPRX3_REG_MSA_VTOTAL   0x83
#define DPRX3_REG_MSA_HSP      0x84
#define DPRX3_REG_MSA_HSW      0x85
#define DPRX3_REG_MSA_HSTART   0x86
#define DPRX3_REG_MSA_VSTART   0x87
#define DPRX3_REG_MSA_VSP      0x88
#define DPRX3_REG_MSA_VSW      0x89
#define DPRX3_REG_MSA_HWIDTH   0x8a
#define DPRX3_REG_MSA_VHEIGHT  0x8b
#define DPRX3_REG_MSA_MISC0    0x8c
#define DPRX3_REG_MSA_MISC1    0x8d
#define DPRX3_REG_VBID         0x8e
#define DPRX3_REG_AUD_MAUD     0x90
#define DPRX3_REG_AUD_NAUD     0x91
#define DPRX3_REG_AUD_AIF0     0x92
#define DPRX3_REG_AUD_AIF1     0x93
#define DPRX3_REG_AUD_AIF2     0x94
#define DPRX3_REG_AUD_AIF3     0x95
#define DPRX3_REG_AUD_AIF4     0x96

#define DPRX_REG_AUX_CONTROL  0x100
#define DPRX_REG_AUX_COMMAND  0x101
#define DPRX_REG_AUX_BYTE0    0x102
#define DPRX_REG_AUX_BYTE1    0x103
#define DPRX_REG_AUX_BYTE2    0x104
#define DPRX_REG_AUX_BYTE3    0x105
#define DPRX_REG_AUX_BYTE4    0x106
#define DPRX_REG_AUX_BYTE5    0x107
#define DPRX_REG_AUX_BYTE6    0x108
#define DPRX_REG_AUX_BYTE7    0x109
#define DPRX_REG_AUX_BYTE8    0x10a
#define DPRX_REG_AUX_BYTE9    0x10b
#define DPRX_REG_AUX_BYTE10   0x10c
#define DPRX_REG_AUX_BYTE11   0x10d
#define DPRX_REG_AUX_BYTE12   0x10e
#define DPRX_REG_AUX_BYTE13   0x10f
#define DPRX_REG_AUX_BYTE14   0x110
#define DPRX_REG_AUX_BYTE15   0x111
#define DPRX_REG_AUX_BYTE16   0x112
#define DPRX_REG_AUX_BYTE17   0x113
#define DPRX_REG_AUX_BYTE18   0x114
#define DPRX_REG_AUX_RESET    0x117
