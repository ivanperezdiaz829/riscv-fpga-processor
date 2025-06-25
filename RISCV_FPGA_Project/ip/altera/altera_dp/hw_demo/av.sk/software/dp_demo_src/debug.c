// ********************************************************************************
// DisplayPort Core test code debug routines
//
// All rights reserved. Property of Bitec.
// Restricted rights to use, duplicate or disclose this code are
// granted through contract.
//
// (C) Copyright Bitec 2012
//    All rights reserved
//
// Author         : $Author: dwang $ @ bitec-dsp.com
// Department     :
// Date           : $Date: 2013/09/05 $
// Revision       : $Revision: #1 $
// URL            : $URL: svn://10.8.0.1/share/svn/dp_sw/trunk/dp_demo/debug.c $
//
// Description:
//
// ********************************************************************************

#include <stdio.h>
#include <string.h>
#include <io.h>
#include "btc_dprx_syslib.h"
#include "btc_dptx_syslib.h"
#include "debug.h"
#include "altera_avalon_fifo_regs.h"
#include "altera_avalon_fifo_util.h"
#include "sys/alt_timestamp.h"
#include "config.h"

#define DEBUG_PRINT_ENABLED 0
#if DEBUG_PRINT_ENABLED
#define DGB_PRINTF printf
#else
#define DGB_PRINTF(format, args...) ((void)0)
#endif

#define AUX_NATIVE_WR     0x80
#define AUX_NATIVE_RD     0x90
#define AUX_I2C_WR        0x00
#define AUX_I2C_RD        0x10
#define AUX_I2C_UPDATE    0x20
#define AUX_I2C_MOT       0x40

#define AUX_ACK           0x00
#define AUX_NACK          0x10
#define AUX_DEFER         0x20
#define AUX_I2C_ACK       0x00
#define AUX_I2C_NACK      0x40
#define AUX_I2C_DEFER     0x80

#if BITEC_STATUS_DEBUG

void bitec_dp_dump_sink_msa(unsigned int base_addr)
{
    printf("------------------------------------------\n");
    printf("------   RX Main stream attributes   -----\n");
    printf("------------------------------------------\n");
    printf("CR Done  : %1.1X         SYM Done : %1.1X\n",   IORD(base_addr, DPRX_REG_RX_STATUS) & 0x0f, (IORD(base_addr, DPRX_REG_RX_STATUS) & 0xf0 ) >> 4);
    printf("Stream 0:\n");
    printf("VB-ID lock : %1.1X   MSA lock : %1.1X\n", (IORD(base_addr, DPRX0_REG_VBID) >> 6 ) & 1, (IORD(base_addr, DPRX0_REG_VBID) >> 7 ) & 1);
    printf("VB-ID : %2.2X  MISC0 : %2.2X  MISC1 : %2.2X\n", IORD(base_addr, DPRX0_REG_VBID) & 0x3F, IORD(base_addr, DPRX0_REG_MSA_MISC0), IORD(base_addr, DPRX0_REG_MSA_MISC1));
    printf("Mvid   : %4.4X     Nvid    : %4.4X\n", IORD(base_addr, DPRX0_REG_MSA_MVID), IORD(base_addr, DPRX0_REG_MSA_NVID));
    printf("Htotal : %4.4d     Vtotal  : %4.4d\n", IORD(base_addr, DPRX0_REG_MSA_HTOTAL), IORD(base_addr, DPRX0_REG_MSA_VTOTAL));
    printf("HSP    : %4.4d     HSW     : %4.4d\n", IORD(base_addr, DPRX0_REG_MSA_HSP), IORD(base_addr, DPRX0_REG_MSA_HSW));
    printf("Hstart : %4.4d     Vstart  : %4.4d\n", IORD(base_addr, DPRX0_REG_MSA_HSTART), IORD(base_addr, DPRX0_REG_MSA_VSTART));
    printf("VSP    : %4.4d     VSW     : %4.4d\n", IORD(base_addr, DPRX0_REG_MSA_VSP), IORD(base_addr, DPRX0_REG_MSA_VSW));
    printf("Hwidth : %4.4d     Vheight : %4.4d\n", IORD(base_addr, DPRX0_REG_MSA_HWIDTH), IORD(base_addr, DPRX0_REG_MSA_VHEIGHT));
    printf("Stream 1:\n");
    printf("VB-ID lock : %1.1X   MSA lock : %1.1X\n", (IORD(base_addr, DPRX1_REG_VBID) >> 6 ) & 1, (IORD(base_addr, DPRX1_REG_VBID) >> 7 ) & 1);
    printf("VB-ID : %2.2X  MISC0 : %2.2X  MISC1 : %2.2X\n", IORD(base_addr, DPRX1_REG_VBID) & 0x3F, IORD(base_addr, DPRX1_REG_MSA_MISC0), IORD(base_addr, DPRX1_REG_MSA_MISC1));
    printf("Mvid   : %4.4X     Nvid    : %4.4X\n", IORD(base_addr, DPRX1_REG_MSA_MVID), IORD(base_addr, DPRX1_REG_MSA_NVID));
    printf("Htotal : %4.4d     Vtotal  : %4.4d\n", IORD(base_addr, DPRX1_REG_MSA_HTOTAL), IORD(base_addr, DPRX1_REG_MSA_VTOTAL));
    printf("HSP    : %4.4d     HSW     : %4.4d\n", IORD(base_addr, DPRX1_REG_MSA_HSP), IORD(base_addr, DPRX1_REG_MSA_HSW));
    printf("Hstart : %4.4d     Vstart  : %4.4d\n", IORD(base_addr, DPRX1_REG_MSA_HSTART), IORD(base_addr, DPRX1_REG_MSA_VSTART));
    printf("VSP    : %4.4d     VSW     : %4.4d\n", IORD(base_addr, DPRX1_REG_MSA_VSP), IORD(base_addr, DPRX1_REG_MSA_VSW));
    printf("Hwidth : %4.4d     Vheight : %4.4d\n", IORD(base_addr, DPRX1_REG_MSA_HWIDTH), IORD(base_addr, DPRX1_REG_MSA_VHEIGHT));
    printf("------------------------------------------\n");
}

void bitec_dp_dump_sink_config(unsigned int base_addr)
{
    printf("------------------------------------------\n");
    printf("--------   RX Link configuration   -------\n");
    printf("------------------------------------------\n");
    printf("Lane count : %d\n",    IORD(base_addr, DPRX_REG_RX_CONTROL) & 0x001f);
    printf("Link rate  : %2.2X\n", (IORD(base_addr, DPRX_REG_RX_CONTROL) >> 5) & 0x03);
    printf("------------------------------------------\n");
}

void bitec_dp_dump_source_msa(unsigned int base_addr)
{
#ifdef BITEC_DPTX_RTL_4X
  printf("------------------------------------------\n");
  printf("------   TX Main stream attributes   -----\n");
  printf("------------------------------------------\n");
  printf("Mvid     : %4.4X\n",   IORD(base_addr, DPTX_REG_MSA_MVID));
  printf("Nvid     : %4.4X\n",   IORD(base_addr, DPTX_REG_MSA_NVID));
  printf("Htotal   : %d\n",      IORD(base_addr, DPTX_REG_MSA_HTOTAL));
  printf("Vtotal   : %d\n",      IORD(base_addr, DPTX_REG_MSA_VTOTAL));
  printf("HSP      : %d\n",      IORD(base_addr, DPTX_REG_MSA_HSP));
  printf("HSW      : %d\n",      IORD(base_addr, DPTX_REG_MSA_HSW));
  printf("Hstart   : %d\n",      IORD(base_addr, DPTX_REG_MSA_HSTART));
  printf("Vstart   : %d\n",      IORD(base_addr, DPTX_REG_MSA_VSTART));
  printf("VSP      : %d\n",      IORD(base_addr, DPTX_REG_MSA_VSP));
  printf("VSW      : %d\n",      IORD(base_addr, DPTX_REG_MSA_VSW));
  printf("Hwidth   : %d\n",      IORD(base_addr, DPTX_REG_MSA_HWIDTH));
  printf("Vheight  : %d\n",      IORD(base_addr, DPTX_REG_MSA_VHEIGHT));
  printf("MISC0    : %2.2X\n",   IORD(base_addr, DPTX_REG_MSA_MISC0));
  printf("MISC1    : %2.2X\n",   IORD(base_addr, DPTX_REG_MSA_MISC1));
  printf("------------------------------------------\n");
#else
  printf("------------------------------------------\n");
  printf("------   TX Stream 0 MSA attributes  -----\n");
  printf("------------------------------------------\n");
  printf("Mvid     : %4.4X\n",   IORD(base_addr, DPTX0_REG_MSA_MVID));
  printf("Nvid     : %4.4X\n",   IORD(base_addr, DPTX0_REG_MSA_NVID));
  printf("Htotal   : %d\n",      IORD(base_addr, DPTX0_REG_MSA_HTOTAL));
  printf("Vtotal   : %d\n",      IORD(base_addr, DPTX0_REG_MSA_VTOTAL));
  printf("HSP      : %d\n",      IORD(base_addr, DPTX0_REG_MSA_HSP));
  printf("HSW      : %d\n",      IORD(base_addr, DPTX0_REG_MSA_HSW));
  printf("Hstart   : %d\n",      IORD(base_addr, DPTX0_REG_MSA_HSTART));
  printf("Vstart   : %d\n",      IORD(base_addr, DPTX0_REG_MSA_VSTART));
  printf("VSP      : %d\n",      IORD(base_addr, DPTX0_REG_MSA_VSP));
  printf("VSW      : %d\n",      IORD(base_addr, DPTX0_REG_MSA_VSW));
  printf("Hwidth   : %d\n",      IORD(base_addr, DPTX0_REG_MSA_HWIDTH));
  printf("Vheight  : %d\n",      IORD(base_addr, DPTX0_REG_MSA_VHEIGHT));
  printf("MISC0    : %2.2X\n",   IORD(base_addr, DPTX0_REG_MSA_MISC0));
  printf("MISC1    : %2.2X\n",   IORD(base_addr, DPTX0_REG_MSA_MISC1));
  printf("------------------------------------------\n");
#endif
}

void bitec_dp_dump_source_config(unsigned int base_addr)
{
    printf("------------------------------------------\n");
    printf("--------   TX Link configuration   -------\n");
    printf("------------------------------------------\n");
    printf("Lane count : %d\n",    (IORD(base_addr, DPTX_REG_TX_CONTROL) >> 5) & 0x1f);
    printf("Link rate  : %2.2X\n", (IORD(base_addr, DPTX_REG_TX_CONTROL) >> 17) & 0x03);
    printf("------------------------------------------\n");
}

#endif // BITEC_STATUS_DEBUG

#if BITEC_AUX_DEBUG

char *bitec_dp_aux2string( unsigned int  addr )
{
  switch(addr) {
    case    0       :       return("DPCD_REV"); break;
    case    1       :       return("MAX_LINK_RATE"); break;
    case    2       :       return("MAX_LANE_COUNT"); break;
    case    3       :       return("MAX_DOWNSPREAD"); break;
    case    4       :       return("NORP"); break;
    case    5       :       return("DOWNSTREAMPORT_PRESENT"); break;
    case    6       :       return("MAIN_LINK_CHANNEL_CODING"); break;
    case    7       :       return("DPCD"); break;
    case    8       :       return("RECEIVE_PORT0_CAP_0"); break;
    case    9       :       return("RECEIVE_PORT0_CAP_1"); break;
    case    10      :       return("RECEIVE_PORT1_CAP_0"); break;
    case    11      :       return("RECEIVE_PORT1_CAP_1"); break;
    case    128     :       return("DPCD"); break;
    case    256     :       return("LINK_BW_SET"); break;
    case    257     :       return("LANE_COUNT_SET"); break;
    case    258     :       return("TRAINING_PATTERN_SET"); break;
    case    259     :       return("TRAINING_LANE0_SET"); break;
    case    260     :       return("TRAINING_LANE1_SET"); break;
    case    261     :       return("TRAINING_LANE2_SET"); break;
    case    262     :       return("TRAINING_LANE3_SET"); break;
    case    263     :       return("DOWNSPREAD_CTRL"); break;
    case    264     :       return("MAIN_LINK_CHANNEL_CODING_SET"); break;
    case    512     :       return("SINK_COUNT"); break;
    case    513     :       return("DEVICE_SERVICE_IRQ_VECTOR"); break;
    case    514     :       return("LANE0_1_STATUS"); break;
    case    515     :       return("LANE2_3_STATUS"); break;
    case    516     :       return("LANE_ALIGN__STATUS_UPDATED"); break;
    case    517     :       return("SINK_STATUS"); break;
    case    518     :       return("ADJUST_REQUEST_LANE0_1"); break;
    case    519     :       return("ADJUST_REQUEST_LANE2_3"); break;
    case    520     :       return("TRAINING_SCORE_LANE0"); break;
    case    521     :       return("TRAINING_SCORE_LANE1"); break;
    case    522     :       return("TRAINING_SCORE_LANE2"); break;
    case    523     :       return("TRAINING_SCORE_LANE3"); break;
    case    528     :       return("SYMBOL_ERROR_COUNT_LANE0_lsb"); break;
    case    529     :       return("SYMBOL_ERROR_COUNT_LANE0_msb"); break;
    case    530     :       return("SYMBOL_ERROR_COUNT_LANE1_lsb"); break;
    case    531     :       return("SYMBOL_ERROR_COUNT_LANE1_msb"); break;
    case    532     :       return("SYMBOL_ERROR_COUNT_LANE2_lsb"); break;
    case    533     :       return("SYMBOL_ERROR_COUNT_LANE2_msb"); break;
    case    534     :       return("SYMBOL_ERROR_COUNT_LANE3_lsb"); break;
    case    535     :       return("SYMBOL_ERROR_COUNT_LANE3_msb"); break;
    case    536     :       return("TEST_REQUEST"); break;
    case    537     :       return("TEST_LINK_RATE"); break;
    case    544     :       return("TEST_LANE_COUNT"); break;
    case    545     :       return("TEST_PATTERN"); break;
    case    546     :       return("TEST_H_TOTAL_lsb"); break;
    case    547     :       return("TEST_H_TOTAL_msb"); break;
    case    548     :       return("TEST_V_TOTAL_lsb"); break;
    case    549     :       return("TEST_V_TOTAL_msb"); break;
    case    550     :       return("TEST_H_START_lsb"); break;
    case    551     :       return("TEST_H_START_msb"); break;
    case    552     :       return("TEST_V_START_lsb"); break;
    case    553     :       return("TEST_V_START_msb"); break;
    case    554     :       return("TEST_HSYNC_lsb"); break;
    case    555     :       return("TEST_HSYNC_msb"); break;
    case    556     :       return("TEST_VSYNC_lsb"); break;
    case    557     :       return("TEST_VSYNC_msb"); break;
    case    558     :       return("TEST_H_WIDTH_lsb"); break;
    case    559     :       return("TEST_H_WIDTH_msb"); break;
    case    560     :       return("TEST_V_HEIGHT_lsb"); break;
    case    561     :       return("TEST_V_HEIGHT_msb"); break;
    case    562     :       return("TEST_MISC_lsb"); break;
    case    563     :       return("TEST_MISC_msb"); break;
    case    564     :       return("TEST_REFRESH_RATE_NUMERATOR"); break;
    case    576     :       return("TEST_CRC_R_Cr_lsb"); break;
    case    577     :       return("TEST_CRC_R_Cr_msb"); break;
    case    578     :       return("TEST_CRC_G_Y_lsb"); break;
    case    579     :       return("TEST_CRC_G_Y_msb"); break;
    case    580     :       return("TEST_CRC_B_Cb_lsb"); break;
    case    581     :       return("TEST_CRC_B_Cb_msb"); break;
    case    582     :       return("TEST_SINK_MISC"); break;
    case    584     :       return("DPCD"); break;
    case    608     :       return("TEST_RESPONSE"); break;
    case    609     :       return("TEST_EDID_CHECKSUM"); break;
    case    624     :       return("TEST_SINK"); break;
    case    1536    :       return("DPCD"); break;
    default : return(" "); break;
  }
}

void bitec_dp_dump_aux_debug_init(unsigned int base_addr_csr)
{
  altera_avalon_fifo_init(base_addr_csr, 0, 0, 0);
}

int cnt = 0;
void bitec_dp_dump_aux_debug(unsigned int base_addr_csr, unsigned int base_addr_fifo, unsigned int is_sink)
{
  unsigned int fifo_data, fifo_status, data_TX;
  unsigned int cmd, aux_addr;
  static unsigned int time_stamp_old[2] = {123456,123456};
  static BYTE last_req_native[2] = {0,0};

  while(altera_avalon_fifo_read_status(base_addr_csr, ALTERA_AVALON_FIFO_STATUS_E_MSK) == 0){ // Is data available in DEBUG FIFO?
	fifo_data   = IORD(base_addr_fifo,0);
	fifo_status = IORD(base_addr_fifo,1);
	is_sink &= 1;

	if(fifo_status & 1)
	{
	  // Check for start of packet
	  if(time_stamp_old[is_sink] == 123456)
	    printf("%8.8d ", 0); // Print time stamp
	  else
	    printf("%8.8d ", (fifo_data >> 8) - time_stamp_old[is_sink]); // Print time stamp
    time_stamp_old[is_sink] = (fifo_data >> 8);
    data_TX = fifo_status & (1 << 8);
    if((data_TX && !is_sink) || (!data_TX && is_sink))
    {
      // We are source and sent a Request or we are a sink and got a Request
      cmd = fifo_data;
      cmd = cmd & 0xFF;
      if(is_sink)
        printf("[SNK] Req got    ");
      else
        printf("[SRC] Req sent   ");
      if(cmd & 0x80)
      {
        // Native
        last_req_native[is_sink] = 1;
        if(cmd & 0x10)
          printf("AUX_RD @ ");
        else
          printf("AUX_WR @ ");

        aux_addr = (cmd & 0x0F) << 16;
        while(altera_avalon_fifo_read_status(base_addr_csr, ALTERA_AVALON_FIFO_STATUS_E_MSK)); // Wait for addr1
        aux_addr |= (IORD(base_addr_fifo,0) & 0xFF) << 8;
        while(altera_avalon_fifo_read_status(base_addr_csr, ALTERA_AVALON_FIFO_STATUS_E_MSK)); // Wait for addr2
        aux_addr |= (IORD(base_addr_fifo,0) & 0xFF);
        printf("%04X (%s)", aux_addr, bitec_dp_aux2string(aux_addr));

        printf(" %02X %02X %02X",cmd,(aux_addr >> 8) & 0xFF,aux_addr & 0xFF);
      }
      else
      {
        // I2C
        last_req_native[is_sink] = 0;
        if((cmd & 0x30) == AUX_I2C_WR)
          printf("I2C_WR ");
        else if((cmd & 0x30) == AUX_I2C_RD)
          printf("I2C_RD ");
        else if((cmd & 0x30) == AUX_I2C_UPDATE)
          printf("I2C_UPD ");
        else
          printf("I2C_?? ");

        if(cmd & AUX_I2C_MOT)
          printf("MOT=1");
        else
          printf("MOT=0");

        printf(" %02X",cmd);
      }
    }
    else if((!data_TX && !is_sink) || (data_TX && is_sink))
    {
      // We are a source and got a Reply or we are a sink and send a Reply
      cmd = fifo_data;
      cmd = cmd & 0xFF;
      if(is_sink)
        printf("[SNK] Reply sent ");
      else
        printf("[SRC] Reply got  ");
      if((cmd & 0x30) == AUX_ACK)
        printf("AUX_ACK");
      else if((cmd & 0x30) == AUX_NACK)
        printf("AUX_NACK");
      else if((cmd & 0x30) == AUX_DEFER)
        printf("AUX_DEFER");
      if(! last_req_native[is_sink])
      {
        if((cmd & 0xC0) == AUX_I2C_ACK)
          printf("|I2C_ACK");
        else if((cmd & 0xC0) == AUX_I2C_NACK)
          printf("|I2C_NACK");
        else if((cmd & 0xC0) == AUX_I2C_DEFER)
          printf("|I2C_DEFER");
      }
      printf(" %02X",cmd);
    }
	} //if(fifo_status & 1)
	else if(fifo_status & 2)
  {
    // Discard EOP
    printf("\n");
  }
  else
    printf(" %02X",fifo_data & 0xFF);
  }
}

#endif // BITEC_AUX_DEBUG


