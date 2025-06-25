// ********************************************************************************
// DisplayPort Core test code TX utilities
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
// Date           : $Date: 2013/10/07 $
// Revision       : $Revision: #2 $
// URL            : $URL: file://nas-bitec/svn/dp_sw/trunk/dp_demo/tx_utils.c $
//
// Description:
//
// ********************************************************************************

#include <stdio.h>
#include <string.h>
#include <io.h> 
#include "btc_dptx_syslib.h"
#include "altera_avalon_fifo_regs.h"
#include "altera_avalon_fifo_util.h"
#include "sys/alt_irq.h"
#include "sys/alt_timestamp.h"
#include "../btc_dprx_syslib/btc_dp_dpcd.h" // For Eclipse to find symbols (Eclipse bug)
#include "../btc_dprx_syslib/btc_dp_types.h" // For Eclipse to find symbols (Eclipse bug)

#define DEBUG_PRINT_ENABLED 0
#if DEBUG_PRINT_ENABLED
#define DGB_PRINTF printf
#else
#define DGB_PRINTF(format, args...) ((void)0)
#endif

// Dashboard bitfields
#define DASH_LINK_RATE_540_MASK (0x2 << 17)
#define DASH_LINK_RATE_270_MASK (0x1 << 17)
#define DASH_LINK_RATE_162_MASK (0x0 << 17)
#define DASH_LANE1_MASK  (0x1 << 5)
#define DASH_LANE2_MASK  (0x2 << 5)
#define DASH_LANE4_MASK  (0x4 << 5)
#define DASH_BPP18_MASK    (0x0 << 2)
#define DASH_BPP24_MASK    (0x1 << 2)
#define DASH_BPP30_MASK    (0x2 << 2)
#define DASH_BPP36_MASK    (0x3 << 2)
#define DASH_BPP48_MASK    (0x4 << 2)

BYTE tx_edid_data[128*4]; // TX copy of Sink EDID
unsigned int T100uS = 0;

void bitec_dptx_hpd_isr(void* context);
void bitec_dptx_hpd_irq();

//***************************************************************
// Derived by legacy alt_irq_interruptible().
// Allows for nested interrupts using the Enhanced Interrupt API
// but without requiring the External Interrupt Controller (EIC)
// and the Vectored Interrupt Controller (VIC)
//
// Input: priority  IRQ number (priority) of the invoking ISR
//                  (IRQ0 has the highest priority)
//***************************************************************
static ALT_INLINE alt_u32 ALT_ALWAYS_INLINE bitec_alt_irq_interruptible(alt_u32 priority)
{
  extern volatile alt_u32 alt_priority_mask; // One bit for each unmasked IRQ (bit0 = IRQ0, bit1 = IRQ1, etc.)
  alt_u32 old_priority;
  int status;

  old_priority = alt_priority_mask;

#if 0
  {
    extern volatile alt_u32 alt_irq_active; // One bit for each instantiated and enabled IRQ (bit0 = IRQ0, bit1 = IRQ1, etc.)

    // Unmask (enable) only IRQs with higher priority than "priority"
    alt_priority_mask = (1 << priority) - 1;
    NIOS2_WRITE_IENABLE (alt_irq_active & alt_priority_mask);
  }
#endif

  // Re-enable global Nios interrupts
  NIOS2_READ_STATUS(status);
  status |= NIOS2_STATUS_PIE_MSK;
  NIOS2_WRITE_STATUS(status);
  return old_priority;
}

//***************************************************************
// Derived by legacy alt_irq_non_interruptible().
// Allows for nested interrupts using the Enhanced Interrupt API
// but without requiring the External Interrupt Controller (EIC)
// and the Vectored Interrupt Controller (VIC)
//
// Input: mask  the value returned by bitec_alt_irq_interruptible()
//***************************************************************
static ALT_INLINE void ALT_ALWAYS_INLINE bitec_alt_irq_non_interruptible(alt_u32 mask)
{
  extern volatile alt_u32 alt_priority_mask; // One bit for each unmasked IRQ (bit0 = IRQ0, bit1 = IRQ1, etc.)
  int status;

  // Disable global Nios interrupts
  NIOS2_READ_STATUS(status);
  status &= ~NIOS2_STATUS_PIE_MSK;
  NIOS2_WRITE_STATUS(status);

#if 0
  {
    extern volatile alt_u32 alt_irq_active; // One bit for each instantiated and enabled IRQ (bit0 = IRQ0, bit1 = IRQ1, etc.)

    // Restore the original IRQ mask
    alt_priority_mask = mask;
    NIOS2_WRITE_IENABLE (mask & alt_irq_active);
  }
#endif
}

//******************************************************
// Initialize the TX
//******************************************************
void bitec_dptx_init()
{
  unsigned int tx_link_rate, tx_lane_count, dash_setup;

  // Get the core capabilities (defined in QSYS and ported to system.h)
  tx_link_rate = DP_TX_MGMT_BITEC_CFG_TX_MAX_LINK_RATE;
  tx_lane_count = DP_TX_MGMT_BITEC_CFG_TX_MAX_LANE_COUNT;

  // Write the capabilities as default settings for the Dashboard
  if(tx_link_rate == 0x14)
    dash_setup = DASH_LINK_RATE_540_MASK;
  else if(tx_link_rate == 0x0a)
    dash_setup = DASH_LINK_RATE_270_MASK;
  else
    dash_setup = DASH_LINK_RATE_162_MASK;

  if(tx_lane_count == 4)
    dash_setup |= DASH_LANE4_MASK;
  else if(tx_lane_count == 2)
    dash_setup |= DASH_LANE2_MASK;
  else
    dash_setup |= DASH_LANE1_MASK;

  dash_setup |= DASH_BPP24_MASK;

  IOWR(XDASH_BASE,0, dash_setup);

  // Register the interrupt handler
  alt_ic_isr_register(DP_TX_MGMT_IRQ_INTERRUPT_CONTROLLER_ID,
                      DP_TX_MGMT_IRQ,
                      bitec_dptx_hpd_isr,
                      NULL,
                      0x0);
}

//******************************************************
// Perform Link Training
//******************************************************
void bitec_dptx_linktrain()
{
  unsigned int link_rate, lane_count, bpc;

  // Read the TX configuration values from the dashboard
  link_rate = (IORD(XDASH_BASE,0) & 0x60000);
  lane_count = IORD(XDASH_BASE,0) & 0x3e0;
  bpc = IORD(XDASH_BASE,0) & 0x1c;

  link_rate >>= 17;
  lane_count >>= 5;
  bpc >>= 2;

  btc_dptx_edid_read(tx_edid_data); // Read the sink EDID
  btc_dptx_set_color_space(0,bpc,0,0); // Set TX video color space
  btc_dptx_link_training(link_rate,lane_count); // Do link training
}

//******************************************************
// HPD activity service routine
//******************************************************
void bitec_dptx_hpd_isr(void* context)
{
  unsigned int status_reg;
  unsigned int link_rate, lane_count, bpc;
  BYTE data;
  alt_u32 mask;

  // Disable TX Core HPD interrupts
  BTC_DPTX_DISABLE_HPD_IRQ();

  // Allow for nested interrupts
  mask = bitec_alt_irq_interruptible(DP_TX_MGMT_IRQ);

  // Read the TX configuration values from the dashboard
  link_rate = (IORD(XDASH_BASE,0) & 0x60000);
  lane_count = IORD(XDASH_BASE,0) & 0x3e0;
  bpc = IORD(XDASH_BASE,0) & 0x1c;

  link_rate >>= 17;
  lane_count >>= 5;
  bpc >>= 2;

  status_reg = IORD(btc_dptx_baseaddr(),DPTX_REG_TX_STATUS); // Reading SR clears IRQ
  if(status_reg & 0x1)
  {
    // Long HPD
    if(status_reg & 0x4)
    {
      // HPD is at '1'

      // Check Automated test request
      btc_dptx_aux_read(DPCP_ADDR_DEVICE_SERVICE_IRQ_VECTOR,1,&data);

      if(data & 0x02)
      {
        // Test Automation request
        btc_dptx_test_autom();
      }

      btc_dptx_edid_read(tx_edid_data); // Read the sink EDID
      btc_dptx_set_color_space(0,bpc,0,0); // Set TX video color space
      btc_dptx_link_training(link_rate,lane_count); // Do link training
    }
    else
    {
      // HPD is at '0'
      // Send the idle pattern
      btc_dptx_video_enable(0);
    }
  }
  else
  {
    // HPD short pulse (IRQ)
    bitec_dptx_hpd_irq();
  }

  // Prevent nested interrupts
  bitec_alt_irq_non_interruptible(mask);

  // Enable TX Core HPD interrupts
  BTC_DPTX_ENABLE_HPD_IRQ();
}

//******************************************************
// HPD IRQ (short pulse) handler
//******************************************************
void bitec_dptx_hpd_irq()
{
  BYTE data[8];
  unsigned int status_ok, lane_count, link_rate;
  BYTE edid_data[128 * 4];

  // Check Automated test request
  btc_dptx_aux_read(DPCP_ADDR_DEVICE_SERVICE_IRQ_VECTOR,1,data);

  if(data[0] & 0x02)
  {
    // Test Automation request
    btc_dptx_test_autom();
  }

  btc_dptx_aux_read(DPCP_ADDR_LINK_BW_SET,2,data);
  link_rate = data[0] & 0x1F;
  lane_count = data[1] & 0x1F;
  if(link_rate == 0x14)
    link_rate = 2;
  else if(link_rate == 0x0a)
    link_rate = 1;
  else
    link_rate = 0;

  btc_dptx_aux_read(DPCP_ADDR_SINK_COUNT,6,data); // Read link status

  // Check Downstream port status change
  if(data[4] & (1<<6))
    btc_dptx_edid_read(edid_data); // Read the sink EDID

  // Check link status
  status_ok = data[4] & 0x01; // Get inter-lane align
  switch(lane_count)
  {
    case 1 : status_ok &= ((data[2] & 0x07) == 0x07); break;
    case 2 : status_ok &= ((data[2] & 0x77) == 0x77); break;
    case 4 : status_ok &= ((data[2] & 0x77) == 0x77) & ((data[3] & 0x77) == 0x77); break;
    default : break;
  }
  if(!status_ok)
    btc_dptx_link_training(link_rate,lane_count);
}
