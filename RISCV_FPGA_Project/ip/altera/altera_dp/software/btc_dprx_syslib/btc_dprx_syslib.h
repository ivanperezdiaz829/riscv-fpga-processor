// ********************************************************************************
// DisplayPort Sink System Library public definitions
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
// URL            : $URL: svn://10.8.0.1/share/svn/dp_sw/trunk/btc_dprx_syslib/btc_dprx_syslib.h $
//
// Description:
//
// ********************************************************************************

#ifndef _BTC_DPRX_SYSLIB_H_
#define _BTC_DPRX_SYSLIB_H_

#include <stdio.h>
#include "btc_dp_dpcd.h"
#include "btc_dp_types.h"
#include "btc_dprx_regs.h"

#define BTC_100US_RXTICKS     1 //number of timer time ticks equ to 100 us

// Enable / Disable IRQ on AUX Requests from source
#define BTC_DPRX_ENABLE_IRQ(rx_idx)	    IOWR(btc_dprx_baseaddr(rx_idx),DPRX_REG_RX_CONTROL,IORD(btc_dprx_baseaddr(rx_idx),DPRX_REG_RX_CONTROL) | (1 << 30))
#define BTC_DPRX_DISABLE_IRQ(rx_idx)	  IOWR(btc_dprx_baseaddr(rx_idx),DPRX_REG_RX_CONTROL,IORD(btc_dprx_baseaddr(rx_idx),DPRX_REG_RX_CONTROL) & ~(1 << 30))
#define BTC_DPRX_ISENABLED_IRQ(rx_idx)  ((IORD(btc_dprx_baseaddr(rx_idx),DPRX_REG_RX_CONTROL) >> 30) & 0x01)

//********** btc_dprx_common.c *********//
int btc_dprx_syslib_add_rx(BYTE rx_idx,
                           unsigned int rx_base_addr,
                           unsigned int rx_irq_id,
                           unsigned int rx_irq_num,
                           unsigned int rx_num_of_sinks);
int btc_dprx_syslib_init(void);
int btc_dprx_syslib_monitor(void);
void btc_dprx_syslib_info(BYTE *max_sink_num, BYTE *mst_support);
unsigned int btc_dprx_baseaddr(BYTE rx_idx);

//********** btc_dprx_aux_ch.c *********//
int btc_dprx_aux_get_request(BYTE rx_idx,BYTE *cmd,unsigned int *address,BYTE *length,BYTE *data);
int btc_dprx_aux_post_reply(BYTE rx_idx,BYTE cmd,BYTE size,BYTE *data);
int btc_dprx_aux_handler(BYTE rx_idx,BYTE cmd,unsigned int address,BYTE length,BYTE *data);

//********** btc_dprx_dpcd.c *********//
int btc_dprx_dpcd_gpu_access(BYTE rx_idx,BYTE wrcmd,unsigned int address,BYTE length,BYTE *data);

//********** btc_dprx_edid.c *********//
int btc_dprx_edid_set(BYTE rx_idx,BYTE port,BYTE *edid_data,BYTE num_blocks);

//********** btc_dprx_hpd.c *********//
void btc_dprx_hpd_set(BYTE rx_idx,int level);
int btc_dprx_hpd_get(BYTE rx_idx);
void btc_dprx_hpd_pulse(BYTE rx_idx);

#endif /* _BTC_DPRX_SYSLIB_H_ */
