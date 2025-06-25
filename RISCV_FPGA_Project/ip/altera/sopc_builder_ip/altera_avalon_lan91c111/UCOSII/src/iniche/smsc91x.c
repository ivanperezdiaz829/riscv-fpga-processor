/*
 * FILENAME: smsc91x.c
 *
 * Copyright  2002 By InterNiche Technologies Inc. All rights reserved
 *
 *
 *  This file contains the portable portions fo the Interniche SMSC91c111
 * ethernet chip family driver.
 * 
 *
 * MODULE: smsc91x
 *
 * ROUTINES: prep_s91(), s91_init(), s91_close(),
 * ROUTINES: s91_pkt_send(), s91_low_send(), s91_stats(), s91_rcv(), 
 * ROUTINES: s91_isr(), s91_reset(), s91_enable()
 *
 * PORTABLE: no
 */

#ifdef ALT_INICHE

#include "ipport.h"
#include "in_utils.h"
#include "netbuf.h"
#include "net.h"
#include "q.h"
#include "ether.h"
#include "altera_avalon_lan91c111_regs.h"
#include "smsc91x.h"
#include "unistd.h"

/* #define STATIC_TX   1 */

int SMSC_UP = FALSE;

struct smsc_parms smsc91s[S91_DEVICES];


#ifdef ALT_INICHE

#include <errno.h>
#include "alt_iniche_dev.h"

error_t alt_avalon_lan91c111_init(
    alt_iniche_dev              *p_dev)
{
    extern int prep_s91(int index);

    prep_s91(p_dev->if_num);

    return (0);
}

#endif /* ALT_INICHE */


/* FUNCTION: prep_s91()
 * 
 * PARAM1: int index
 *
 * RETURNS: 
 */

int
prep_s91(int index)
{
   int      i;
   unshort  bank;
   SMSC  smsc;
   NET ifp;

   for (i = 0; i < S91_DEVICES; i++)
   {
      smsc = &smsc91s[i];  /* get pointer to device structure */

      /* Call the per-port hardware setup. Speed settings should be
       * set in smsc->req_speed by the application prior to starting
       * the driver, else it will default to autoneg.
       */
      s91_port_prep(i);    /* set up device parameters (IObase, etc) */

      /* make sure SMSC chip appears at IO base. The bank select register always
       * has a "0x33" in it's high byte, so we use this as a rough test.
       */
      bank = IORD_ALTERA_AVALON_LAN91C111_BSR(smsc->regbase);
      if ( (bank & 0xff00) != 0x3300 )
      {
         dtrap();      /* programing or hardware setup error? */
         continue;
      }

      ifp = nets[index];
      ifp->n_mib->ifAdminStatus = 2;   /* status = down */
      ifp->n_mib->ifOperStatus = 2;    /* will be set up in init()  */
      ifp->n_mib->ifLastChange = cticks * (100/TPS);
      ifp->n_mib->ifPhysAddress = (u_char*)smsc->mac_addr;
      ifp->n_mib->ifDescr = (u_char*)"SMSC 9100 series ethernet";
      ifp->n_lnh = ETHHDR_SIZE;        /* ethernet header size */
      ifp->n_hal = 6;                  /* hardware address length */
      ifp->n_mib->ifType = ETHERNET;   /* device type */
      ifp->n_mtu = MTU;                /* max frame size */
      /* install our hardware driver routines */
      ifp->n_init = s91_init;
      ifp->pkt_send = s91_pkt_send;
      ifp->n_close = s91_close;
      ifp->n_stats = s91_stats;

#ifdef IP_V6
      ifp->n_flags |= (NF_NBPROT | NF_IPV6);
#else
      ifp->n_flags |= NF_NBPROT;
#endif

      nets[index]->n_mib->ifPhysAddress = (u_char*)smsc->mac_addr;   /* ptr to MAC address */

      /* set cross-pointers between iface and smsc structs */
      smsc->netp = ifp;
      ifp->n_local = (void*)smsc;

      index++;
   }

   return index;
}


/* FUNCTION: s91_init()
 * 
 * Initialize a LAN91C111 device
 * 
 * PARAM1: int iface
 *
 * RETURNS: 0 if successful
 */

int
s91_init(int iface)
{
   unshort  mem_size;
   SMSC     smsc;

   /* get pointer to device structure */
   smsc = (SMSC)nets[iface]->n_local;

   s91_reset(smsc);     /* reset the chip */

   /* get the chip's memory information */
   IOWR_ALTERA_AVALON_LAN91C111_BSR(smsc->regbase, 0);
   mem_size = IORD_ALTERA_AVALON_LAN91C111_MIR(smsc->regbase);
   smsc->memory = (mem_size >> 8) * 2048;    /* bytes in device  */

   /* Get chip's rev ID */
   IOWR_ALTERA_AVALON_LAN91C111_BSR(smsc->regbase, 3);
   smsc->rev  = IORD_ALTERA_AVALON_LAN91C111_REV(smsc->regbase);

   s91_enable(smsc);       /* prepare for use */
   s91_port_init(smsc);    /* install ISR, etc */
   s91_phy_init(smsc);

   nets[iface]->n_mib->ifAdminStatus = 1;    /* status = UP */
   nets[iface]->n_mib->ifOperStatus = 1;

   dprintf("SMSC ethernet Rev: 0x%x, ram: %d\n", smsc->rev, smsc->memory);
#ifdef STATIC_TX
   dprintf("Static TX buffer: %d\n", smsc->snd_pnr);
#endif

   SMSC_UP = TRUE;

   return (0);
}




/* FUNCTION: s91_close()
 * 
 * PARAM1: int iface
 *
 * RETURNS: 
 */

int
s91_close(int iface)
{
   SMSC  smsc;

   nets[iface]->n_mib->ifAdminStatus = 2;    /* status = down */

   /* get pointer to device structure */
   smsc = (SMSC)nets[iface]->n_local;

   s91_port_close(smsc);   /* release the ISR */
   s91_reset(smsc);        /* reset the chip */

   nets[iface]->n_mib->ifOperStatus = 2;     /* status = down */
   return 0;
}


/* FUNCTION: s91_stats()
 * 
 * Display Ethernet controller statistics
 * 
 * PARAM1: void * pio
 * PARAM2: int iface
 *
 * RETURNS: void
 */

void
s91_stats(void * pio, int iface)
{
   SMSC  smsc;

   smsc = (SMSC)(nets[iface]->n_local);

   ns_printf(pio, "Interrupts: rx:%lu, tx:%lu alloc:%lu, total:%lu\n",
    smsc->rx_ints, smsc->tx_ints, smsc->alloc_ints, smsc->total_ints);
   ns_printf(pio, "coll1:%lu collx:%lu overrun:%lu mdint:%lu\n",
    smsc->coll1, smsc->collx, smsc->rx_overrun, smsc->mdint);
   ns_printf(pio, "Sendq max:%d, current %d. IObase: 0x%lx ISR %d\n", 
      smsc->tosend.q_max, smsc->tosend.q_len, smsc->regbase, smsc->intnum);

   return;
}


/* FUNCTION: s91_pkt_send()
 * 
 * The Interniche MAC packet send routine
 * This function puts the packet on the device's 'tosend' queue.
 * If the device is not currently sending, it starts the sending
 * process by requesting FIFO space.
 * 
 * PARAM1: PACKET pkt
 *
 * RETURNS: 0 if successful, otherwise an error code
 */

int
s91_pkt_send(PACKET pkt)
{
   SMSC smsc = (SMSC)pkt->net->n_local;
   BASE_TYPE base = (BASE_TYPE)smsc->regbase;
   u_char mask;

   ENTER_S91_SECTION(smsc);

   /* Add this packet to the queue, issue the TX memory alloc command, and
    * return. The memory alloc interrupt will take care of the send.
    */
   putq(&smsc->tosend, (qp)pkt);    /* new packet goes in the back */

   /* If this is the only packet, start the transmit sequence */
   if (smsc->tosend.q_len == 1)
   {
#ifndef STATIC_TX
      /* send out the memory alloc command - will interrupt when ready */
      IOWR_ALTERA_AVALON_LAN91C111_BSR(base, 2);
      IOWR_ALTERA_AVALON_LAN91C111_MMUCR(base, 
                           ALTERA_AVALON_LAN91C111_MMUCR_ALLOC_MSK);
                           
      /* turn on the ALLOC interrupt unless we are in the middle of a DMA */
      smsc->mask |= ALTERA_AVALON_LAN91C111_INT_ALLOC_INT_MSK;
      mask = IORD_ALTERA_AVALON_LAN91C111_MSK(base);
      if (mask != 0)
      {
        IOWR_ALTERA_AVALON_LAN91C111_MSK(base, smsc->mask);
      }
#else
      /* enable the TX_EMPTY interrupt to start the send 
       * unless we are in the middle of a DMA */
      smsc->mask |= ALTERA_AVALON_LAN91C111_INT_TX_EMPTY_INT_MSK;
      IOWR_ALTERA_AVALON_LAN91C111_BSR(base, 2);
      mask = IORD_ALTERA_AVALON_LAN91C111_MSK(base);
      if (mask != 0)
      {
        IOWR_ALTERA_AVALON_LAN91C111_MSK(base, smsc->mask);
      }
#endif
      smsc->sending = TRUE;   /* start of send operation */
   }

   EXIT_S91_SECTION(smsc);
   
   return (0);      /* alloc done interrupt will start xmit */
}


/* FUNCTION: s91_low_send()
 * 
 * This is called from the ISR when a TX buffer ALLOC command has 
 * completed or the TX buffer is EMPTY. It moves the next packet of
 * data to be sent into the SMSC device and does related transmit setup.
 * 
 * PARAM1: SMSC smsc
 *
 * RETURNS: 
 */

void
s91_low_send(SMSC smsc)
{
   PACKET    pkt;     /* Interniche pkt structure */
   BASE_TYPE base = (BASE_TYPE) smsc->regbase;    /* SMSC register base */
   unsigned  sendlen; /* length to send - may be padded */
   unshort   tmp;

   if ((pkt = (PACKET)getq(&smsc->tosend)) == NULL)
   {
      dtrap();    /* no packet to send? */
      smsc->sending = FALSE;
      return;
   }
   smsc->snd_pkt = pkt;
   
   /* update packet statistics */
   smsc->netp->n_mib->ifOutOctets += (u_long)pkt->nb_plen;
   if(*pkt->nb_prot & 0x80)
	    smsc->netp->n_mib->ifOutNUcastPkts++;
   else
	    smsc->netp->n_mib->ifOutUcastPkts++;

#ifndef STATIC_TX
   /* get the SMSC chip's packet "number" (sort of a handle) for it's newly
    * allocated send buffer and set the device up to use it.
    */
   IOWR_ALTERA_AVALON_LAN91C111_BSR(base, 2);
   smsc->snd_pnr = IORD_ALTERA_AVALON_LAN91C111_ARR(base);
/*   write_7seg(smsc->snd_pnr); */
   if (smsc->snd_pnr & ALTERA_AVALON_LAN91C111_ARR_FAILED_MSK)
   {
      dtrap();      /* bad hardware? */
      smsc->sending = FALSE;
      return;
   }
#endif

   /* tell the card to use this packet number */
   do
   {
      tmp = IORD_ALTERA_AVALON_LAN91C111_PTR(base);
   } while (tmp & ALTERA_AVALON_LAN91C111_PTR_NOT_EMPTY_MSK);
   IOWR_ALTERA_AVALON_LAN91C111_PNR(base, smsc->snd_pnr);
   
   /* tell the card to auto-increment the data ptr */
   IOWR_ALTERA_AVALON_LAN91C111_PTR(base, ALTERA_AVALON_LAN91C111_PTR_AUTO_INCR_MSK);
 
   sendlen = pkt->nb_plen - ETHHDR_BIAS;
   if (sendlen < 60) /* pad to minimum length */
      sendlen = 60;
   s91_senddata(smsc, (u_char *)(pkt->nb_prot + ETHHDR_BIAS), sendlen);
}



/* FUNCTION: s91_rcv()
 * 
 * Process received packet from within ISR
 * 
 * PARAM1: smsc            SMSC structure pointer
 *
 * RETURNS: none
 * 
 * Note: Bank 2 is selected by the ISR prior to calling s91_rcv(). 
 */

void
s91_rcv(SMSC smsc)
{
   unshort   pkt_num;    /* chip's handle for received pkt */
   BASE_TYPE base = (BASE_TYPE)smsc->regbase;
   unshort   pkstatus;   /* status word for received pkt */
   unshort   pklen;      /* length of received pkt */
   PACKET    pkt;

   pkt_num = IORD_ALTERA_AVALON_LAN91C111_RX_FIFO(base);
   if (pkt_num & ALTERA_AVALON_LAN91C111_RX_FIFO_REMPTY_MSK)
   {
      smsc->rx_empty++;
      return;
   }
   pkt_num >>= 8;    /* convert into RX number */
   smsc->rcv_pnr = pkt_num;

   /* Set chip's pointer to pkt data */
   IOWR_ALTERA_AVALON_LAN91C111_PTR(base, 
                        ALTERA_AVALON_LAN91C111_PTR_READ_MSK |
                        ALTERA_AVALON_LAN91C111_PTR_RCV_MSK  |
                        ALTERA_AVALON_LAN91C111_PTR_AUTO_INCR_MSK);

   /* First two words are status and packet_length */ 
   pkstatus = IORD_ALTERA_AVALON_LAN91C111_DATA_HW(base);
   pklen = IORD_ALTERA_AVALON_LAN91C111_DATA_HW(base);
   pklen &= 0x07FF;     /* mask out high bits */

#ifdef REV_A_SILICON
   /* Rev A chip doesn't set RX_ODDSIZE so assume we received an
    * extra byte and pad the length by 1.
    */
   pklen += 1;
#endif

   if (pkstatus & ALTERA_AVALON_LAN91C111_RS_ODD_FRM_MSK)
      pklen -= 5;      /* adjust for status, length and control byte */
   else
      pklen -= 6;      /* adjust for status, length and control words */

   if (pkstatus & (ALTERA_AVALON_LAN91C111_RS_ALGN_ERR_MSK |
                   ALTERA_AVALON_LAN91C111_RS_BAD_CRC_MSK  |
                   ALTERA_AVALON_LAN91C111_RS_TOO_LONG_MSK |
                   ALTERA_AVALON_LAN91C111_RS_TOO_SHORT_MSK) )
   {
      smsc->rx_errors++;
      /* flush the error packet */
      MMUCR_WAIT(base);
      IOWR_ALTERA_AVALON_LAN91C111_MMUCR(base, 
                           ALTERA_AVALON_LAN91C111_MMUCR_REMOVE_RELEASE_MSK);
   }

   if ((pkt = pk_alloc(pklen + ETHHDR_BIAS)) == NULL)   /* couldn't get a free buffer for rx */
   {
      smsc->netp->n_mib->ifInDiscards++;

      /* flush the packet so the card doesn't int us again (or get stuck) */
      MMUCR_WAIT(base);
      IOWR_ALTERA_AVALON_LAN91C111_MMUCR(base, 
                           ALTERA_AVALON_LAN91C111_MMUCR_REMOVE_RELEASE_MSK);
      return;
   }
   smsc->rcv_pkt = pkt;
   
   /* move the received packet into the buffer. We align it so that the
    * data is front aligned if ETHHDR_SIZE is 14, and start 2 bytes
    * into the buffer (nb_buff) if it's 16.
    */
   s91_rcvdata(smsc, (u_char *)(pkt->nb_buff + (ETHHDR_BIAS)), pklen);

   smsc->netp->n_mib->ifInOctets += (u_long)pklen;
}



/* FUNCTION: s91_isr()
 * 
 * LAN 91C111 Interrupt Service Routine
 * 
 * PARAM1: int devnum
 *
 * RETURNS: none
 */
void
s91_isr(int devnum)
{
   SMSC      smsc;
   BASE_TYPE base;		/* base address for IO */
   u_char    status;  /* current interrupt status word at device */

   smsc = &smsc91s[devnum];
   base = (BASE_TYPE) smsc->regbase;

   smsc->total_ints++;

   /* get current active interrupt bits; ISR only uses Bank 2 registers */
   IOWR_ALTERA_AVALON_LAN91C111_BSR(base, 2);

   /* get the current interrupt status */
   status = IORD_ALTERA_AVALON_LAN91C111_IST(base);
/*   write_leds(status); */

   /* receive has priority over transmit */
   if (status & ALTERA_AVALON_LAN91C111_INT_RCV_INT_MSK)
   {
      smsc->rx_ints++;
      s91_rcv(smsc);
   }
#ifdef NOT_USED
   else if (status & ALTERA_AVALON_LAN91C111_INT_TX_INT_MSK)
   {
      smsc->tx_ints++;
      
         /* If you hit this, then you need to implement the recovery
          * logic in page 74 of the databook. Most hardware doesn't
          * seem to need it.
          */
      dtrap();
   }
#endif
#ifndef STATIC_TX
   else if (status & smsc->mask & ALTERA_AVALON_LAN91C111_INT_ALLOC_INT_MSK)
   {
      smsc->alloc_ints++;

      /* turn off the ALLOC interrupt */
      smsc->mask &= ~ALTERA_AVALON_LAN91C111_INT_ALLOC_INT_MSK;
           
      /* we've got a transmit buffer, copy the data into the buffer */
      s91_low_send(smsc);
   }
#else
   else if (status & smsc->mask & ALTERA_AVALON_LAN91C111_INT_TX_EMPTY_INT_MSK)
   {
      smsc->tx_ints++;
      
      IOWR_ALTERA_AVALON_LAN91C111_ACK(base, 
                           ALTERA_AVALON_LAN91C111_INT_TX_EMPTY_INT_MSK);

      /* turn off the TX_EMPTY interrupt */
      smsc->mask &= ~ALTERA_AVALON_LAN91C111_INT_TX_EMPTY_INT_MSK;
           
      /* if we've got more packets, copy the packet data into the buffer */
      if (smsc->tosend.q_len > 0)
         s91_low_send(smsc);
      else
         smsc->sending = FALSE;
   }
#endif
    
    /* count receive overflows */
   if (status & ALTERA_AVALON_LAN91C111_INT_RX_OVRN_INT_MSK)
   {
      smsc->rx_overrun++;
      
      IOWR_ALTERA_AVALON_LAN91C111_ACK(base, 
                           ALTERA_AVALON_LAN91C111_INT_RX_OVRN_INT_MSK);
   }
   
   /* count MD status changes */
   if (status & ALTERA_AVALON_LAN91C111_INT_MDINT_MSK)
   {
      smsc->mdint++;
      
      /* update the PHY status register info */
      smsc->phyreg18 = s91_readphy(smsc, ALTERA_AVALON_LAN91C111_PHY_INT_STATUS_REG);      

      IOWR_ALTERA_AVALON_LAN91C111_ACK(base, 
                           ALTERA_AVALON_LAN91C111_INT_MDINT_MSK);
   }
}


/* FUNCTION: s91_reset()
 * 
 * s91_reset() - resets the chip and leaves it in an idle state
 *
 * PARAM1: smsc            SMSC structure pointer
 *
 * RETURNS: none
 */

void
s91_reset(SMSC smsc) 
{
   BASE_TYPE base;
   unshort   tmp;
   PACKET    pkt;     /* Interniche pkt structure */

   base = (BASE_TYPE)smsc->regbase;

   IOWR_ALTERA_AVALON_LAN91C111_BSR(base, 0);
   IOWR_ALTERA_AVALON_LAN91C111_RCR(base, 
                     ALTERA_AVALON_LAN91C111_RCR_SOFTRST_MSK);
                     
   /* define the reset pulse width */
   usleep(1000);

   /* Clear the transmit and receive configuration registers */
   IOWR_ALTERA_AVALON_LAN91C111_RCR(base, 0);
   IOWR_ALTERA_AVALON_LAN91C111_TCR(base, 0);
   
   /* wait awhile for things to settle */
   usleep(5000);

#ifndef STATIC_TX
   /* Automatically release succesfully transmitted packets */
   IOWR_ALTERA_AVALON_LAN91C111_BSR(base, 1);
   tmp = IORD_ALTERA_AVALON_LAN91C111_CTR(base);
   tmp |= ALTERA_AVALON_LAN91C111_CTR_AUTO_RELEASE_MSK;
   IOWR_ALTERA_AVALON_LAN91C111_CTR(base, tmp);
#endif

   /* Reset the MMU */
   IOWR_ALTERA_AVALON_LAN91C111_BSR(base, 2);
   IOWR_ALTERA_AVALON_LAN91C111_MMUCR(base, 
                     ALTERA_AVALON_LAN91C111_MMUCR_RESET_MSK);
   /* wait for completion */
   MMUCR_WAIT(base);
   
   /* disable interrupts (probably already done by RESET) */
   IOWR_ALTERA_AVALON_LAN91C111_MSK(base ,0);
   smsc->mask = 0;

   while ((pkt = (PACKET)getq(&smsc->tosend)))
   {
      pk_free(pkt);
   }
}


/* FUNCTION: s91_enable()
 * 
 * s91_enable() - sets it up for normal use
 *
 * PARAM1: smsc            SMSC structure pointer
 *
 * RETURNS: none
 */

void
s91_enable(SMSC smsc) 
{
   BASE_TYPE base = (BASE_TYPE) smsc->regbase;
   unshort   tmp;
#ifdef STATIC_TX
   u_char    status;
#endif

   IOWR_ALTERA_AVALON_LAN91C111_BSR(base, 0);

   /* Set it up to autonegotiate link */
   tmp = IORD_ALTERA_AVALON_LAN91C111_RPCR(base);     /* tmp debug */
 
   IOWR_ALTERA_AVALON_LAN91C111_RPCR(base, 
                        ALTERA_AVALON_LAN91C111_RPCR_ANEG_MSK); 

   /* Set the transmit and receive configuration registers */
   IOWR_ALTERA_AVALON_LAN91C111_RCR(base,
                        ALTERA_AVALON_LAN91C111_RCR_STRIP_CRC_MSK |
                        ALTERA_AVALON_LAN91C111_RCR_RXEN_MSK      |
                        ALTERA_AVALON_LAN91C111_RCR_ALMUL_MSK );
   IOWR_ALTERA_AVALON_LAN91C111_TCR(base,
                        ALTERA_AVALON_LAN91C111_TCR_PAD_EN_MSK |
                        ALTERA_AVALON_LAN91C111_TCR_TXENA_MSK );

   IOWR_ALTERA_AVALON_LAN91C111_BSR(base, 2);
#ifdef STATIC_TX
   
   /* get the statically allocated TX buffer if we need one */
   IOWR_ALTERA_AVALON_LAN91C111_MMUCR(base,
                        ALTERA_AVALON_LAN91C111_MMUCR_ALLOC_MSK);
   do
   {
      usleep(5000);
      status = IORD_ALTERA_AVALON_LAN91C111_IST(base);
   } while ((status & ALTERA_AVALON_LAN91C111_INT_TX_EMPTY_INT_MSK) == 0);
   smsc->snd_pnr = IORD_ALTERA_AVALON_LAN91C111_ARR(base);
/*   write_7seg(smsc->snd_pnr); */
#endif   

   /* enable receive interrupts at the smsc chip */
   smsc->mask |= ( ALTERA_AVALON_LAN91C111_INT_RCV_INT_MSK |
                   ALTERA_AVALON_LAN91C111_INT_RX_OVRN_INT_MSK );
   IOWR_ALTERA_AVALON_LAN91C111_MSK(base, smsc->mask);
}

#endif /* ALT_INICHE */
