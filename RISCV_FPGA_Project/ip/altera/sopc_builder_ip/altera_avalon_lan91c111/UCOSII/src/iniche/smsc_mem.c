/*
 * Filename: smsc_mem.c
 *
 * Copyright 2003 by InterNiche Technologies Inc. All rights reserved.
 *
 * This is the Altera LAN91C111-specific portion of the 91C111 driver
 * demo port. Since this is not intended to high highly portable, it 
 * contains scraps of assembler where appropriate.
 */
#ifdef ALT_INICHE

#include "ipport.h"

#include "netbuf.h"
#include "net.h"
#include "q.h"
#include "ether.h"

#include "altera_avalon_lan91c111_regs.h"
#include "system.h"
#include "sys/alt_irq.h"
#include "sys/alt_dma.h"
#include "smsc91x.h"
#include "alt_iniche_dev.h"

/* #define STATIC_TX   1 */

void s91_isr(int);     /* only support one device for now */
void dma_rx_done(void *, void *);
void dma_tx_done(void *);

alt_dma_rxchan  dma_rx;         /* DMA channel structures */
alt_dma_txchan  dma_tx;

/* FUNCTION: mac2ip()
 * 
 * Map MAC addresses into IP addresses
 * 
 * PARAMS: none
 * 
 * RETURN: unsigned long ipaddr       IP address
 */
 u_long
 mac2ip(void)
 {
   BASE_TYPE base = (BASE_TYPE)(LAN91C111_BASE + LAN91C111_LAN91C111_REGISTERS_OFFSET);
   u_long ipaddr;
   u_char mac4, mac5;
    
   /* read the MAC address and assign either 10.103 or 10.101 */
   
   IOWR_ALTERA_AVALON_LAN91C111_BSR(base, 1);
   mac4 = IORD_ALTERA_AVALON_LAN91C111_IAR4(base);
   mac5 = IORD_ALTERA_AVALON_LAN91C111_IAR5(base);
   
   if ((mac4 == 0x63) && (mac5 == 0x5f))
      ipaddr = 0x0a000067;      /* 10.0.0.103 */
   else if ((mac4 == 0x63) && (mac5 == 0x55))
      ipaddr = 0x0a000065;      /* 10.0.0.101 */
   else
   {
      dtrap();
      ipaddr = 0x0a000067;      /* 10.0.0.103 */
   }
      
   return (ipaddr);
 }
 
/* FUNCTION: s91_prep_port()
 * 
 * Do port-specific device initialization
 * 
 * PARAM1: s91_dev         device index; 0..n-1
 * 
 * RETURN: 0 if successful, otherwise a non-zero error code
 * 
 * Initializes the SMSC device structure with the device's
 * base address, interrupt priority, MAC address.
 * 
 * For now, only support one device, which must be named "lan91c111" in the 
 * Altera SOPC Builder design.
 */
int
s91_port_prep(int s91_dev)
{
   SMSC smsc;

   if(s91_dev >= S91_DEVICES)
      return -1;

   smsc = &smsc91s[s91_dev];  /* get pointer to device structure */

   smsc->regbase = (u_long)(LAN91C111_BASE + LAN91C111_LAN91C111_REGISTERS_OFFSET);
   smsc->intnum = LAN91C111_IRQ;
   smsc->ic_id  = LAN91C111_IRQ_INTERRUPT_CONTROLLER_ID;

   /* read the MAC address from the chip (bank 1, regs 4 - 9) and save
    * it in the local device structure. The "portable" code in smsc91x.c
    * will later use this structure to (re)set the hardware address.
    */
   IOWR_ALTERA_AVALON_LAN91C111_BSR(smsc->regbase, 1);

#ifdef ALT_INICHE
   get_mac_addr(smsc->netp, smsc->mac_addr);
   IOWR_ALTERA_AVALON_LAN91C111_IAR0(smsc->regbase, smsc->mac_addr[0]);
   IOWR_ALTERA_AVALON_LAN91C111_IAR1(smsc->regbase, smsc->mac_addr[1]);
   IOWR_ALTERA_AVALON_LAN91C111_IAR2(smsc->regbase, smsc->mac_addr[2]);
   IOWR_ALTERA_AVALON_LAN91C111_IAR3(smsc->regbase, smsc->mac_addr[3]);
   IOWR_ALTERA_AVALON_LAN91C111_IAR4(smsc->regbase, smsc->mac_addr[4]);
   IOWR_ALTERA_AVALON_LAN91C111_IAR5(smsc->regbase, smsc->mac_addr[5]);
#else /* not ALT_INICHE */
   IOWR_ALTERA_AVALON_LAN91C111_IAR0(smsc->regbase, 0x00);
   IOWR_ALTERA_AVALON_LAN91C111_IAR1(smsc->regbase, 0x07);
   IOWR_ALTERA_AVALON_LAN91C111_IAR2(smsc->regbase, 0xed);
   IOWR_ALTERA_AVALON_LAN91C111_IAR3(smsc->regbase, 0x0f);
   IOWR_ALTERA_AVALON_LAN91C111_IAR4(smsc->regbase, 0x63);
   IOWR_ALTERA_AVALON_LAN91C111_IAR5(smsc->regbase, 0x5f);

   smsc->mac_addr[0] = IORD_ALTERA_AVALON_LAN91C111_IAR0(smsc->regbase);
   smsc->mac_addr[1] = IORD_ALTERA_AVALON_LAN91C111_IAR1(smsc->regbase);
   smsc->mac_addr[2] = IORD_ALTERA_AVALON_LAN91C111_IAR2(smsc->regbase);
   smsc->mac_addr[3] = IORD_ALTERA_AVALON_LAN91C111_IAR3(smsc->regbase);
   smsc->mac_addr[4] = IORD_ALTERA_AVALON_LAN91C111_IAR4(smsc->regbase);
   smsc->mac_addr[5] = IORD_ALTERA_AVALON_LAN91C111_IAR5(smsc->regbase);
#endif /* not ALT_INICHE */
   return 0;
}

#ifdef ALTERA_NIOS2
/* FUNCTION: s91_isr_wrap
 * 
 * Wrapper Function for Altera Nios-II HAL BSP's use.
 * 
 * PARAM1: context         device-specific context value
 * PARAM2: intnum          interrupt number
 * 
 * RETURN: none
 * 
 * The "context" parameter is the LAN91C111 device index: 0..n-1.
 * Interrupts are disabled on entry, so don't need to do anything
 * unless we want to reenable higher pirority interrupts for performance
 * reasons.
 */
#ifdef ALT_ENHANCED_INTERRUPT_API_PRESENT
void s91_isr_wrap(void *context)
#else
void s91_isr_wrap(void *context, u_long intnum)
#endif
{
/*   ENTER_S91_SECTION(0); */

   s91_isr((int)context);
   
/*   EXIT_S91_SECTION(0); */
}
#endif  /* ALTERA_NIOS2 */


/* FUNCTION: s91_port_init
 * 
 * Initializes the Interrupt Service Routine for the device
 * 
 * PARAM1: smsc            SMSC structure pointer
 * 
 * RETURN: 0 if successful, otherwise a non-zero error code
 */
int
s91_port_init(SMSC smsc)
{
#ifndef SMSC_POLLED
   int err;

   /* register the ISR with the ALTERA HAL interface */
#ifdef ALT_ENHANCED_INTERRUPT_API_PRESENT
   err = alt_ic_isr_register(smsc->ic_id, smsc->intnum, s91_isr_wrap, 
     (void *)0, 0x0);
#else
   err = alt_irq_register (smsc->intnum, (void *)0, s91_isr_wrap);
#endif  

   if (err)
      return (err);

#ifdef NOT_USED
   if (s91_sleepfactor > 2)
   {
      s91_sleepfactor = 1;
      dprintf("SMSC91x: New sleep factor is %ld\n", s91_sleepfactor);
   }
#endif

#endif  /* SMSC_POLLED */

#ifdef ALTERA_DMA
   /* create the DMA channels for reading/writing the 91C111 FIFO */
   
   if (((dma_tx = alt_dma_txchan_open(DMA_NAME)) == NULL) ||
       ((dma_rx = alt_dma_rxchan_open(DMA_NAME)) == NULL))
      return (-ENODEV);
   
   /* setup channels to be 16-bits wide, memory <-> peripheral */
   err = alt_dma_rxchan_ioctl(dma_rx, ALT_DMA_SET_MODE_32, 0);
   if (err)
      return (err);

   err = alt_dma_rxchan_ioctl(dma_rx, ALT_DMA_RX_ONLY_ON,
                    (void *)(smsc->regbase + 8));
   if (err)
      return (err); 

   err = alt_dma_txchan_ioctl(dma_tx, ALT_DMA_SET_MODE_32, 0);
   if (err)
      return (err);

   err = alt_dma_txchan_ioctl(dma_tx, ALT_DMA_TX_ONLY_ON,
                    (void *)(smsc->regbase + 8));
   if (err)
      return (err); 
#endif  /* ALTERA_DMA */     

   return (0);
}

/* FUNCTION: s91_port_close
 * 
 * Close the LAN91C111 device
 * 
 * PARAM1: smsc            SMSC structure pointer
 * 
 * RETURN: 0
 */
int
s91_port_close(SMSC smsc)
{
   return (0);
}

/* FUNCTION: s91_senddata
 * 
 * Transfer data from the packet to the LAN91C111 internal memory
 * 
 * PARAM1: smsc         SMSC structure pointer
 * PARAM2: data         pointer to packet data
 * PARAM3: len          packet data length
 * 
 * RETURN: none
 * 
 * The actual length required by the LAN91C111 includes the status
 * word, length word, and control byte. There is space reserved before
 * and after the data for building the header and trailer information
 * used by the MAC.
 */
void
s91_senddata(SMSC smsc, unsigned char *data, int len)
{
   u_long   base = smsc->regbase;       /* device base address */

   void s91_dma_tx_done(void *);

   /* sanity check */
   if ((len < 60) || (((int)data) & 0x1))
   {
      dtrap();
   }
   
   /* Send status word first. This seems to be just a required
    * placeholder in the devices memory. It's filled in by the
    * device upon TX complete. 
    */
   IOWR_ALTERA_AVALON_LAN91C111_DATA_HW(base, 0);

   /* Followed by the byte count; count includes the 6 control bytes.
    */
   IOWR_ALTERA_AVALON_LAN91C111_DATA_HW(base, (len & ~0x1) + 6);

#ifndef ALTERA_DMA_TX
   if (((u_long)data) & 0x02)
   {
      IOWR_ALTERA_AVALON_LAN91C111_DATA_HW(base, *(unshort *)data);
      data += 2;
      len -= 2;
   }

   while ((len -= 4) >= 0)
   {
      IOWR_ALTERA_AVALON_LAN91C111_DATA_WORD(base, *(unsigned int *)data);
      data += 4;
   }
   
   smsc->snd_odd = len + 4;
   smsc->snd_data = data;
   s91_dma_tx_done((void *)smsc);
#else
   /* disable 91C111 interrupts until DMA completes */
   IOWR_ALTERA_AVALON_LAN91C111_MSK(base, 0);
   
   /* do the odd half-word at the beginning by PIO */
   if (((u_long)data) & 0x02)
   {
      IOWR_ALTERA_AVALON_LAN91C111_DATA_HW(base, *(unshort *)data);
      data += 2;
      len -= 2;
   }

   alt_dma_txchan_send(dma_tx, (void *)(((u_long)data) & ~0x80000000), len & ~0x3, 
                       s91_dma_tx_done, (void *)smsc);
   smsc->snd_odd = len & 0x3;
   smsc->snd_data = data + (len & ~0x3);
#endif  /* ALTERA_DMA_TX */
}

/* FUNCTION: s91_dma_tx_done
 * 
 * Callback routine when TX DMA is done
 * 
 * PARAM1: void *handle     callback parameter
 * 
 * RETURN: void
 */
void
s91_dma_tx_done(void *handle)
{
   SMSC smsc = (SMSC)handle;
   BASE_TYPE base = (BASE_TYPE)smsc->regbase;
   PACKET pkt = smsc->snd_pkt;
   unshort stats;
   
   ENTER_S91_SECTION(smsc);
   
   /* get the packet number and queue the packet for transmission */
   IOWR_ALTERA_AVALON_LAN91C111_BSR(base, 2);
   
   /* process the odd halfword at the end */
   switch (smsc->snd_odd)
   {
   case 3:
      IOWR_ALTERA_AVALON_LAN91C111_DATA_HW(base, *(unshort *)(smsc->snd_data));
      smsc->snd_data += 2;
      /* fall through for the last byte and control byte */
      
   case 1:
      IOWR_ALTERA_AVALON_LAN91C111_DATA_BYTE(base, *smsc->snd_data);
      IOWR_ALTERA_AVALON_LAN91C111_DATA_BYTE(base, 
                            ALTERA_AVALON_LAN91C111_CONTROL_ODD_MSK);
      break;
 
   case 2:
      IOWR_ALTERA_AVALON_LAN91C111_DATA_HW(base, *(unshort *)(smsc->snd_data));
      /* fall through to write the control byte */
      
   case 0:
      IOWR_ALTERA_AVALON_LAN91C111_DATA_HW(base, 0);
      break;
   }

   IOWR_ALTERA_AVALON_LAN91C111_MMUCR(base, ALTERA_AVALON_LAN91C111_MMUCR_ENQUEUE_MSK);
   
   /* update stats from error counter reg */
   IOWR_ALTERA_AVALON_LAN91C111_BSR(base, 0);
   stats = IORD_ALTERA_AVALON_LAN91C111_ECR(base);
   IOWR_ALTERA_AVALON_LAN91C111_BSR(base, 2);

   /* single collisions */
   smsc->coll1 += (u_long)(stats & 0xf);
   /* multiple collisions */
   smsc->collx += (u_long)((stats >> 4) & 0xf);

   /* free the transmitted packet */
   pk_free(pkt);
   
   /* if there is more to transmit, allocate the next TX buffer */
   smsc->sending = FALSE;
   if(smsc->tosend.q_len > 0)  /* more packets queued to send? */
   {
#ifndef STATIC_TX
      /* send out the memory alloc command - will interrupt when ready */
      IOWR_ALTERA_AVALON_LAN91C111_MMUCR(base, 
                           ALTERA_AVALON_LAN91C111_MMUCR_ALLOC_MSK);
                           
      /* turn on the ALLOC interrupt */
      smsc->mask |= ALTERA_AVALON_LAN91C111_INT_ALLOC_INT_MSK;
#else
      /* turn on the TX_EMPTY interrupt */
      smsc->mask |= ALTERA_AVALON_LAN91C111_INT_TX_EMPTY_INT_MSK;
#endif
      smsc->sending = TRUE;   /* start of send operation */
   }
   
   /* re-enable 91C111 interrupts */
   IOWR_ALTERA_AVALON_LAN91C111_MSK(base, smsc->mask);
   
   EXIT_S91_SECTION(smsc);
}

/* FUNCTION: s91_rcvdata
 * 
 * Move packet data from the card into local memory
 * 
 * PARAM1: smsc            SMSC structure pointer
 * PARAM2: data            destination data pointer (even address)
 * PARAM3: len             data length (bytes)
 * 
 * RETURN: none
 * 
 * The data pointer is assumed to be 16-bit aligned. An even
 * number of bytes will be transfered to the destination memory.
 */
void
s91_rcvdata(SMSC smsc, unsigned char *data, int len)
{
   u_long  base = smsc->regbase;
   void s91_dma_rx_done(void *, void *);
   
   smsc->rcv_len = len;
   len = (len + 1) & ~0x1;        /* round up */
   
#ifndef ALTERA_DMA_RX
   if (((u_long)data) & 0x02)
   {
      *(unshort *)data = IORD_ALTERA_AVALON_LAN91C111_DATA_HW(base);
      data += 2;
      len -= 2;
   }

   while ((len -= 4) >= 0)
   {
      *(unsigned int *)data = IORD_ALTERA_AVALON_LAN91C111_DATA_WORD(base);
      data += 4;
   }  

   smsc->rcv_odd = len & 0x3;
   smsc->rcv_data = data;
   s91_dma_rx_done((void *)smsc, (void *)data);
#else
   /* disable 91C111 interrupts while DMA is in progress */
   IOWR_ALTERA_AVALON_LAN91C111_MSK(base, 0);
   
   /* do the odd half-word at the beginning by PIO */
   if (((u_long)data) & 0x02)
   {
      *(unshort *)data = IORD_ALTERA_AVALON_LAN91C111_DATA_HW(base);
      data += 2;
      len -= 2;
   }

   alt_dma_rxchan_prepare(dma_rx, (void *)(((u_long)data) & ~0x80000000), len & ~0x3, 
                          dma_rx_done, (void *)smsc);
   smsc->rcv_odd = len & 0x3;
   smsc->rcv_data = data + (len & ~0x3);
#endif  /* ALTERA_DMA_RX */
}

/* FUNCTION: s91_dma_rx_done
 * 
 * Callback routine when RX DMA is done
 * 
 * PARAM1: void *handle     callback parameter
 * PARAM2: void *data       receive buffer pointer
 * 
 * RETURN: void
 */
void
s91_dma_rx_done(void *handle, void *data)
{
   SMSC smsc = (SMSC)handle;
   BASE_TYPE base = (BASE_TYPE)smsc->regbase;
   PACKET pkt;
   struct ethhdr * eth;
   
   ENTER_S91_SECTION(smsc);

   /* process the odd halfword at the end */
   if (smsc->rcv_odd)
   {
      *(unshort *)(smsc->rcv_data) = IORD_ALTERA_AVALON_LAN91C111_DATA_HW(base);     
   }

   pkt = smsc->rcv_pkt;
   pkt->nb_prot = pkt->nb_buff + ETHHDR_SIZE;
   pkt->nb_plen = smsc->rcv_len - 14;
   pkt->nb_tstamp = cticks;
   pkt->net = smsc->netp;

   /* set packet type for demux routine */
   eth = (struct ethhdr *)(pkt->nb_buff + ETHHDR_BIAS);
   pkt->type = eth->e_type;

   /* queue the received packet */
   putq(&rcvdq, pkt);
   SignalPktDemux();
      
   /* flush the packet so the card doesn't int us again (or get stuck) */
   IOWR_ALTERA_AVALON_LAN91C111_BSR(base, 2);
   MMUCR_WAIT(base);
   IOWR_ALTERA_AVALON_LAN91C111_MMUCR(base, 
                        ALTERA_AVALON_LAN91C111_MMUCR_REMOVE_RELEASE_MSK);
                        
   /* restore the 91C111 interrupts */
   IOWR_ALTERA_AVALON_LAN91C111_MSK(base, smsc->mask);
                     
   EXIT_S91_SECTION(smsc);   
}
#endif /*ALT_INICHE*/
