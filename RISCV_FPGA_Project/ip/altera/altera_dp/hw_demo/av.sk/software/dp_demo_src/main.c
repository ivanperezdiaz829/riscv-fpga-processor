// ********************************************************************************
// DisplayPort Core test code main
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
// URL            : $URL: svn://10.8.0.1/share/svn/dp_sw/trunk/dp_demo/main.c $
//
// Description:
//
// ********************************************************************************

#include <stdio.h>
#include <unistd.h>
#include <io.h>
#include <unistd.h>
#include <fcntl.h>
#include <string.h>
#include "sys/alt_timestamp.h"
#include "alt_types.h"
#include "sys/alt_irq.h"
#include "btc_dprx_syslib.h"
#include "btc_dptx_syslib.h"
#include "debug.h"
#include "i2c.h"
#include "config.h"

void bitec_dptx_init();
void bitec_dptx_linktrain();
void bitec_dprx_init();

int main()
{
  // Force non-blocking jtag uart
  fcntl(STDOUT_FILENO, F_SETFL, O_NONBLOCK);
  printf("Started...\n");

  // Enable TPG Background : Disable DP image
  IOWR(MIX_BASE, 0, 0); // Stop
  IOWR(MIX_BASE, 2, 0); // Stream 0 offset X
  IOWR(MIX_BASE, 3, 0); // Stream 0 offset Y
  IOWR(MIX_BASE, 4, 0); // Stream 0 off
  IOWR(MIX_BASE, 5, 1920/2); // Stream 1 offset X
  IOWR(MIX_BASE, 6, 0); // Stream 1 offset Y
  IOWR(MIX_BASE, 7, 0); // Stream 1 off
  IOWR(MIX_BASE, 8, 0); // Stream 2 offset X
  IOWR(MIX_BASE, 9, 600); // Stream 2 offset Y
  IOWR(MIX_BASE, 10, 0); // Stream 2 off
  IOWR(MIX_BASE, 11, 1920/2); // Stream 3 offset X
  IOWR(MIX_BASE, 12, 600); // Stream 3 offset Y
  IOWR(MIX_BASE, 13, 0); // Stream 3 off
  IOWR(MIX_BASE, 0, 1); // Go

  // Init Bitec DP system library
  btc_dptx_syslib_init(DP_TX_MGMT_BASE,
                       DP_TX_MGMT_IRQ_INTERRUPT_CONTROLLER_ID,
                       DP_TX_MGMT_IRQ);
  btc_dprx_syslib_add_rx(0,
                       DP_RX_MGMT_BASE,
                       DP_RX_MGMT_IRQ_INTERRUPT_CONTROLLER_ID,
                       DP_RX_MGMT_IRQ,
                       DP_RX_MGMT_BITEC_CFG_RX_MAX_NUM_OF_STREAMS);
#if BITEC_RX_GPUMODE
  btc_dprx_syslib_init();
#endif

  // Init the SN75DP130 on the Bitec Sink main link input
  // (on the Bitec daughter board)
  // Set the SN75DP130 equaliser as required by your design
  {
    unsigned char data[32];

    bitec_i2c_init(I2C_BASE);

    bitec_i2c_write(0x58, 0x01, 0x01);
    bitec_i2c_write(0x58, 0x03, 0x18); //disable squelch
    bitec_i2c_write(0x58, 0x05, 0xC2); //force EQ for lane 0, pre-emph 0_1, EQ_I2C_ENABLE
    bitec_i2c_write(0x58, 0x06, 0x10); //force EQ for lane 0, pre-emph 2_3
    bitec_i2c_write(0x58, 0x07, 0x52); //force EQ for lane 1, pre-emph 0_1
    bitec_i2c_write(0x58, 0x08, 0x10); //force EQ for lane 1, pre-emph 2_3
    bitec_i2c_write(0x58, 0x09, 0x52); //force EQ for lane 2, pre-emph 0_1
    bitec_i2c_write(0x58, 0x0A, 0x10); //force EQ for lane 2, pre-emph 2_3
    bitec_i2c_write(0x58, 0x0B, 0x52); //force EQ for lane 3, pre-emph 0_1
    bitec_i2c_write(0x58, 0x0C, 0x10); //force EQ for lane 3, pre-emph 2_3
    bitec_i2c_write(0x58, 0x00, 0x00); //reset the RD reg. address

    bitec_i2c_read(0x59, data, 32);
  }

  // Init sink and source
  bitec_dptx_init();
#if BITEC_RX_GPUMODE
  btc_dprx_hpd_set(0,0); // HPD = 0
  bitec_dprx_init();

  BTC_DPRX_ENABLE_IRQ(0); // Enable IRQ on AUX Requests from the source

  // Wait for 500 ms to have a long HPD
  {
    unsigned int tout;
    alt_timestamp_start();
    tout = alt_timestamp_freq()/2;
    while(alt_timestamp() < tout);
  }
  btc_dprx_hpd_set(0,1); // HPD = 1
#endif

#if BITEC_AUX_DEBUG
  bitec_dp_dump_aux_debug_init(AUX_RX_DEBUG_FIFO_IN_CSR_BASE);
  bitec_dp_dump_aux_debug_init(AUX_TX_DEBUG_FIFO_IN_CSR_BASE);
#endif

  // Perform Link Training if a Sink is connected
  {
    unsigned int sr;
    sr = IORD(btc_dptx_baseaddr(),DPTX_REG_TX_STATUS); // Reading SR clears IRQ
    if(sr & 0x04)
      bitec_dptx_linktrain();
  }

  BTC_DPTX_ENABLE_HPD_IRQ(); // Enable IRQ on HPD changes from the sink

  // Main loop
  while(1)
  {
    if(IORD(btc_dprx_baseaddr(0), DPRX0_REG_VBID) & 0x80)
      IOWR(MIX_BASE, 4, 1); // MSA lock -> Enable DP image
    else
      IOWR(MIX_BASE, 4, 0); // MSA not locked -> Disable DP image

    if(IORD(btc_dprx_baseaddr(0), DPRX1_REG_VBID) & 0x80)
      IOWR(MIX_BASE, 7, 1); // MSA lock -> Enable DP image
    else
      IOWR(MIX_BASE, 7, 0); // MSA not locked -> Disable DP image

    if(IORD(btc_dprx_baseaddr(0), DPRX2_REG_VBID) & 0x80)
      IOWR(MIX_BASE, 10, 1); // MSA lock -> Enable DP image
    else
      IOWR(MIX_BASE, 10, 0); // MSA not locked -> Disable DP image

    if(IORD(btc_dprx_baseaddr(0), DPRX3_REG_VBID) & 0x80)
      IOWR(MIX_BASE, 13, 1); // MSA lock -> Enable DP image
    else
      IOWR(MIX_BASE, 13, 0); // MSA not locked -> Disable DP image

    // Serve Syslib periodic tasks
    btc_dptx_syslib_monitor();
#if BITEC_RX_GPUMODE
    btc_dprx_syslib_monitor();
#endif

#if BITEC_AUX_DEBUG
    // Dump AUX channel traffic
    bitec_dp_dump_aux_debug(AUX_RX_DEBUG_FIFO_IN_CSR_BASE, AUX_RX_DEBUG_FIFO_OUT_BASE, 1);
    bitec_dp_dump_aux_debug(AUX_TX_DEBUG_FIFO_IN_CSR_BASE, AUX_TX_DEBUG_FIFO_OUT_BASE, 0);
#endif

    if(IORD(MSA_DUMP_PIO_BASE,0))
    {
      // User pushbutton pressed
#if 0
#if BITEC_RX_GPUMODE
      btc_dprx_hpd_set(0,0); // HPD = 0

      // Wait for 500 ms to have a long HPD
      {
        unsigned int tout;
        alt_timestamp_start();
        tout = alt_timestamp_freq()/2;
        while(alt_timestamp() < tout);
      }
      btc_dprx_hpd_set(0,1); // HPD = 1
#endif
#else

      // Wait for 500 ms to avoid bouncing
      {
        unsigned int tout;
        alt_timestamp_start();
        tout = alt_timestamp_freq()/2;
        while(alt_timestamp() < tout);
      }

#if BITEC_STATUS_DEBUG
      // Dump MSA
      bitec_dp_dump_source_msa(btc_dptx_baseaddr());
      bitec_dp_dump_source_config(btc_dptx_baseaddr());
      bitec_dp_dump_sink_msa(btc_dprx_baseaddr(0));
      bitec_dp_dump_sink_config(btc_dprx_baseaddr(0));
#endif

#endif
    }
  }

  return 0; // Should never get here
}





