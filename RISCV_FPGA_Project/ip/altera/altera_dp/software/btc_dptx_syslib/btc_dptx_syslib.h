// ********************************************************************************
// DisplayPort System Library public definitions
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
// URL            : $URL: svn://10.8.0.1/share/svn/dp_sw/trunk/btc_dptx_syslib/btc_dptx_syslib.h $
//
// Description:
//
// ********************************************************************************

#ifndef _BTC_DPTX_SYSLIB_H_
#define _BTC_DPTX_SYSLIB_H_

#include <stdio.h>
#include "btc_dp_types.h"
#include "btc_dp_dpcd.h"
#include "btc_dptx_regs.h"

#define BTC_100US_TXTICKS     1 //number of timer time ticks equ to 100 us

// Enable / Disable IRQ on HPD events
#define BTC_DPTX_ENABLE_HPD_IRQ()     IOWR(btc_dptx_baseaddr(),DPTX_REG_TX_CONTROL,IORD(btc_dptx_baseaddr(),DPTX_REG_TX_CONTROL) | (1 << 31))
#define BTC_DPTX_DISABLE_HPD_IRQ()    IOWR(btc_dptx_baseaddr(),DPTX_REG_TX_CONTROL,IORD(btc_dptx_baseaddr(),DPTX_REG_TX_CONTROL) & ~(1 << 31))
#define BTC_DPTX_ISENABLED_HPD_IRQ()  ((IORD(btc_dptx_baseaddr(),DPTX_REG_TX_CONTROL) >> 31) & 0x01)

// Enable / Disable IRQ on AUX Replies from sink
#define BTC_DPTX_ENABLE_AUX_IRQ()     IOWR(btc_dptx_baseaddr(),DPTX_REG_TX_CONTROL,IORD(btc_dptx_baseaddr(),DPTX_REG_TX_CONTROL) | (1 << 30))
#define BTC_DPTX_DISABLE_AUX_IRQ()    IOWR(btc_dptx_baseaddr(),DPTX_REG_TX_CONTROL,IORD(btc_dptx_baseaddr(),DPTX_REG_TX_CONTROL) & ~(1 << 30))
#define BTC_DPTX_ISENABLED_AUX_IRQ()  ((IORD(btc_dptx_baseaddr(),DPTX_REG_TX_CONTROL) >> 30) & 0x01)

typedef struct  // MST Relative Address
{
  BYTE length; // Address (addr[]) length
  BYTE addr[15];
}BTC_RAD;

typedef struct
{
  BYTE input_port : 1;
  BYTE peer_device_type : 3;
  BYTE port_number : 4;
  BYTE messaging_capability_status : 1;
  BYTE displayport_device_plug_status : 1;
  BYTE legacy_device_plug_status : 1;
  BYTE padding : 5;
  BYTE DPCD_revision;
  BYTE peer_GUID[16];
  BYTE number_SDP_streams : 4;
  BYTE number_SDP_stream_sinks : 4;
}BTC_MST_DEVICE_PORT;

typedef struct
{
  BYTE GUID[16];
  BYTE number_of_ports;
  BTC_MST_DEVICE_PORT port[15];
}BTC_MST_DEVICE;

typedef struct
{
  BYTE port_number;
  unsigned int full_PBN;
  unsigned int available_PBN;
}BTC_MST_PATH_PBN;

typedef struct
{
  BYTE write_i2c_device_identifier;
  BYTE num_of_bytes_to_write;
  BYTE i2c_data_to_write[5];
  BYTE no_stop_bit;
  BYTE i2c_transaction_delay;
}BTC_MST_I2C_WR_TRANS;

typedef struct
{
  BYTE port_number;
  BYTE num_of_bytes_read;
  BYTE i2c_read_data[255];
}BTC_MST_I2C_RD_DATA;

//********** btc_dptx_common.c *********//
int btc_dptx_syslib_init(unsigned int tx_base_addr,
                         unsigned int tx_irq_id,
                         unsigned int tx_irq_num);
int btc_dptx_syslib_monitor(void);
unsigned int btc_dptx_baseaddr(void);

//********** btc_dptx_aux_ch.c *********//
int btc_dptx_aux_write(unsigned int address,BYTE size,BYTE *data);
int btc_dptx_aux_read(unsigned int address,BYTE size,BYTE *data);
int btc_dptx_aux_i2c_write(BYTE address,BYTE size,BYTE *data,BYTE mot);
int btc_dptx_aux_i2c_read(BYTE address,BYTE size,BYTE *data,BYTE mot);

//********** btc_dptx_utils.c *********//
int btc_dptx_set_color_space(BYTE format,BYTE bpc,BYTE range,BYTE colorimetry);
int btc_dptx_video_enable(BYTE enabled);
int btc_dptx_edid_read(BYTE *data);
int btc_dptx_edid_block_read(BYTE block,BYTE *data);

//********** btc_dptx_lt.c *********//
int btc_dptx_link_training(unsigned int link_rate,unsigned int lane_count);
int btc_dptx_fast_link_training(unsigned int link_rate, unsigned int lane_count,
                                unsigned int volt_swing, unsigned int pre_emph,
                                unsigned int new_cfg);

//********** btc_dptx_ta.c *********//
int btc_dptx_test_autom(void);

//********** btc_dptx_mst.c *********//
int btc_dptx_mst_down_rep_irq();
int btc_dptx_mst_link_address_req(BTC_RAD *RAD);
int btc_dptx_mst_enum_path_req(BTC_RAD *RAD,BYTE port_number);
int btc_dptx_mst_remote_i2c_rd_req(BTC_RAD *RAD,
                                   BYTE port_number,
                                   BYTE num_of_wr_trans,
                                   BTC_MST_I2C_WR_TRANS *wr_trans,
                                   BYTE rd_i2c_dev_id,
                                   BYTE num_of_rd_bytes);
int btc_dptx_mst_clear_paylod_table_req(BTC_RAD *RAD);
int btc_dptx_mst_remote_dpcd_wr_req(BTC_RAD *RAD,BYTE port_number,unsigned int addr,BYTE length,BYTE *data);
int btc_dptx_mst_link_address_rep(BTC_MST_DEVICE *device,BYTE *GUID,BYTE *reas_for_nak,BYTE *nak_data);
int btc_dptx_mst_enum_path_rep(BTC_MST_PATH_PBN *path_pbn,BYTE *GUID,BYTE *reas_for_nak,BYTE *nak_data);
int btc_dptx_mst_remote_i2c_rd_rep(BTC_MST_I2C_RD_DATA *data,BYTE *GUID,BYTE *reas_for_nak,BYTE *nak_data);
int btc_dptx_mst_clear_paylod_table_rep(BYTE *GUID,BYTE *reas_for_nak,BYTE *nak_data);
int btc_dptx_mst_remote_dpcd_wr_rep(BYTE *GUID,BYTE *reas_for_nak,BYTE *nak_data);

#endif /* _BTC_DPTX_SYSLIB_H_ */
